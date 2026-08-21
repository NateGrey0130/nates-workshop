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
//
// `power_picks` does the same for the spells and psionic powers a level earns,
// banked in pending_power_picks. A spell pick names the level that granted it,
// because the spell LEVELS it may draw from belong to that grant rather than to
// the character.

import { json, requireCharacter } from '../../_lib/auth.js';
import { loadCharacterClass } from '../../_lib/class-loader.js';
import { xpTableFor, thresholdFor, skillGrantsFor } from '../../_lib/leveling.js';
import { insertGrantStatements, remainingGrants, resolvePicks, pickErrors, dedupeCategories } from '../../_lib/skill-picks.js';
import { powerGrantsFor, resolvePowerPicks, remainingPowerGrants, insertPowerGrantStatements,
         powerPickErrors } from '../../_lib/power-picks.js';
import { validateCharacter, loadSkillCategories } from '../../_lib/validate-character.js';
import { loadCharacter } from '../../_lib/character-json.js';

const POOL_FIELDS = ['hp_max', 'sdc_max', 'mdc_max', 'ppe_max', 'isp_max'];

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await request.json();
  const character = await loadCharacter(env, params.id);
  const toLevel = parseInt(b.to_level, 10);
  if (!Number.isFinite(toLevel) || toLevel <= character.level) {
    return json({ error: `to_level must be greater than current level (${character.level})` }, 400);
  }
  const cls = await loadCharacterClass(env, request.url, character);
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
  // Related and secondary grants are kept apart: a secondary grant is
  // unrestricted, and folding it into the same list would unrestrict the
  // related picks with it.
  const related = grants.filter((g) => g.kind !== 'secondary');
  const secondaryAllowance = grants
    .filter((g) => g.kind === 'secondary')
    .reduce((n, g) => n + g.count, 0);
  const categories = related.some((g) => !g.categories)
    ? null // one unrestricted related grant makes the related picks unrestricted
    : dedupeCategories(related.flatMap((g) => g.categories || []));

  const picked = await resolvePicks(env, {
    picks: b.picks,
    existingSkills: skills,
    allowance,
    categories,
    secondaryAllowance,
    level: toLevel,
  });
  if (picked.errors?.length) return pickErrors(picked.errors);

  if (picked.skills.length) {
    skills = skills.concat(picked.skills);
    skillsChanged = true;
    changes.picked = picked.skills.map((s) => ({ name: s.name, pct: s.pct, override: !!s.override }));
  }
  if (skillsChanged) { sets.push('skills = ?'); binds.push(JSON.stringify(skills)); }

  // Spells and psionic powers the crossed levels earn. Same shape as the skill
  // grants above and banked the same way, but validated against the cap the
  // granting level carries rather than against a category list.
  const powerGrants = powerGrantsFor(cls, character.level, toLevel);
  // loadCharacter does not join campaigns, so the system has to be fetched.
  // Without it the catalog filter is a silent no-op and a Rifts caster can
  // learn a Palladium-only spell - the kind of permissiveness that looks
  // exactly like a working feature.
  const campaign = powerGrants.length
    ? await env.DB.prepare('SELECT system FROM campaigns WHERE id = ?')
        .bind(character.campaign_id).first()
    : null;
  let pickedPowers = [];
  let powers = character.powers;
  if (powerGrants.length && Array.isArray(b.power_picks) && b.power_picks.length) {
    const resolved = await resolvePowerPicks(env, {
      picks: b.power_picks,
      grants: powerGrants,
      existingPowers: powers,
      system: campaign?.system ?? null,
    });
    if (resolved.errors?.length) return powerPickErrors(resolved.errors);
    pickedPowers = resolved.powers;
  }
  if (pickedPowers.length) {
    powers = powers.concat(pickedPowers);
    sets.push('powers = ?'); binds.push(JSON.stringify(powers));
    changes.powers = pickedPowers.map((p) => ({ type: p.type, name: p.name, level: p.gained_at_level }));
  }

  // Check the result, not the request: the allowance grows with the level being
  // reached, so validate against toLevel rather than the level being left.
  const { violations } = validateCharacter({
    character: { level: toLevel }, cls, skills, attributes: character.attributes,
    abilities: character.abilities,
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

  // Bank only what was not spent in this same request. The consume-from-the-
  // earliest rule is shared with the create path, which banks the same way for
  // a character that starts above level 1.
  const unspent = allowance - picked.skills.length;
  if (unspent > 0) {
    statements.push(...insertGrantStatements(env, params.id,
      remainingGrants(grants, picked.skills.length)));
  }

  // The same for powers, counted PER GRANT rather than as one total: a spell
  // grant is identified by the level that earned it, and banking two level-4
  // spells against a level-2 grant would hand them the wrong cap when they are
  // eventually spent.
  const spentByKey = new Map();
  for (const p of pickedPowers) {
    const key = `${p.type === 'psionic' ? 'psionic' : 'spell'}:${p.gained_at_level}`;
    spentByKey.set(key, (spentByKey.get(key) || 0) + 1);
  }
  const powerRemaining = remainingPowerGrants(powerGrants, spentByKey);
  if (powerRemaining.length) {
    statements.push(...insertPowerGrantStatements(env, params.id, powerRemaining));
  }

  await env.DB.batch(statements);

  return json({
    ok: true,
    level: toLevel,
    changes,
    picks_granted: allowance,
    picks_spent: picked.skills.length,
    picks_pending: unspent,
    powers_granted: powerGrants.reduce((n, g) => n + g.count, 0),
    powers_spent: pickedPowers.length,
    powers_pending: powerRemaining.reduce((n, g) => n + g.count, 0),
  });
}
