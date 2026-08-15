// POST /api/character-creator/characters/:id/level-confirm — owner/GM only.
// Applies a level-up the player confirmed (possibly tweaked from the proposal):
// Body: { to_level, pools: {hp_max: n, ...}, skills: [{name, pct}],
//         picks: [{name, override?}], grants, note }
// Updates the characters row and logs a level_history entry with what was
// ACTUALLY applied. Pool current values rise by the same amount as their max.
//
// Skill picks the class grants for crossing a level are banked in
// pending_skill_picks. `picks` spends some or all of them now; anything left
// unspent waits on the sheet. Levelling up is never blocked on choosing.

import { getUserEmail, unauthorized, json, forbidden, characterAccess } from '../../_lib/auth.js';
import { loadClass } from '../../_lib/class-loader.js';
import { xpTableFor, thresholdFor, skillGrantsFor } from '../../_lib/leveling.js';
import { insertGrantStatements, resolvePicks, pickErrors } from '../../_lib/skill-picks.js';
import { validateCharacter, loadSkillCategories } from '../../_lib/validate-character.js';
import { loadCharacter } from '../../_lib/character-json.js';

const POOL_FIELDS = ['hp_max', 'sdc_max', 'mdc_max', 'ppe_max', 'isp_max'];

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const b = await request.json();
  const character = await loadCharacter(env, params.id);
  const toLevel = parseInt(b.to_level, 10);
  if (!Number.isFinite(toLevel) || toLevel <= character.level) {
    return json({ error: `to_level must be greater than current level (${character.level})` }, 400);
  }
  const cls = await loadClass(env, request.url, character.class_id);
  const table = xpTableFor(cls);
  const needed = thresholdFor(table, toLevel);
  if (needed == null) return json({ error: `to_level ${toLevel} is past the level cap (${table.length})` }, 400);
  if (character.xp < needed) return json({ error: `Not enough XP for level ${toLevel} (need ${needed}, have ${character.xp})` }, 400);

  const changes = { pools: {}, skills: [], grants: b.grants ?? [], note: b.note ?? null };
  const sets = ['level = ?'], binds = [toLevel];

  for (const field of POOL_FIELDS) {
    const to = b.pools?.[field];
    if (typeof to !== 'number' || to === character[field] || character[field] == null) continue;
    const delta = to - character[field];
    changes.pools[field] = { from: character[field], to };
    sets.push(`${field} = ?`); binds.push(to);
    const curField = field.replace('_max', '_current');
    if (character[curField] != null) {
      sets.push(`${curField} = ?`); binds.push(character[curField] + delta);
    }
  }

  let skills = character.skills;
  let skillsChanged = false;
  if (Array.isArray(b.skills) && b.skills.length) {
    const byName = new Map(b.skills.filter((s) => s && typeof s.pct === 'number').map((s) => [s.name, s.pct]));
    for (const s of skills) {
      const to = byName.get(s.name);
      if (to == null || to === s.pct) continue;
      changes.skills.push({ name: s.name, from: s.pct, to });
      s.pct = to;
    }
    skillsChanged = true;
  }

  // What this level-up earns. Banked whether or not it is spent right now.
  const grants = skillGrantsFor(cls, character.level, toLevel);
  const allowance = grants.reduce((n, g) => n + g.count, 0);
  const categories = grants.some((g) => !g.categories)
    ? null // one unrestricted grant makes the whole allowance unrestricted
    : [...new Set(grants.flatMap((g) => g.categories || []))];

  const picked = await resolvePicks(env, {
    picks: b.picks,
    existingSkills: skills,
    allowance,
    categories,
    level: toLevel,
  });
  if (picked.errors?.length) return pickErrors(picked.errors);

  if (picked.skills.length) {
    skills = skills.concat(picked.skills);
    skillsChanged = true;
    changes.picked = picked.skills.map((s) => ({ name: s.name, pct: s.pct, override: !!s.override }));
  }
  if (skillsChanged) { sets.push('skills = ?'); binds.push(JSON.stringify(skills)); }

  // Check the result, not the request: the allowance grows with the level being
  // reached, so validate against toLevel rather than the level being left.
  const { violations } = validateCharacter({
    character: { level: toLevel }, cls, skills, attributes: character.attributes,
    catalog: cls ? await loadSkillCategories(env) : null,
  });
  if (violations.length) {
    return json({ error: 'That level-up would break the class rules', violations }, 422);
  }

  sets.push("updated_at = datetime('now')");

  // One batch. A level-up that raised the level but lost its picks, or banked
  // grants against a level-up that did not land, would both be worse than a
  // clean failure.
  const statements = [
    env.DB.prepare(`UPDATE characters SET ${sets.join(', ')} WHERE id = ?`).bind(...binds, params.id),
    env.DB.prepare(
      `INSERT INTO level_history (character_id, from_level, to_level, xp_at_levelup, changes)
       VALUES (?, ?, ?, ?, ?)`
    ).bind(params.id, character.level, toLevel, character.xp, JSON.stringify(changes)),
  ];

  // Bank only what was not spent in this same request, consuming ACROSS grants
  // from the earliest first. Taking whole grants instead would keep the right
  // total but attribute it to the wrong level — spending 1 of a level-3 pair
  // would bank "level 3 x 2" and lose the level-6 grant entirely.
  const unspent = allowance - picked.skills.length;
  if (unspent > 0) {
    let toSpend = picked.skills.length;
    const remaining = [];
    for (const g of grants) {
      const consumed = Math.min(g.count, toSpend);
      toSpend -= consumed;
      const left = g.count - consumed;
      if (left > 0) remaining.push({ ...g, count: left });
    }
    statements.push(...insertGrantStatements(env, params.id, remaining));
  }

  await env.DB.batch(statements);

  return json({
    ok: true,
    level: toLevel,
    changes,
    picks_granted: allowance,
    picks_spent: picked.skills.length,
    picks_pending: unspent,
  });
}
