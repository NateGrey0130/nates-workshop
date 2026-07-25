// POST /api/character-creator/characters/:id/level-confirm — owner/GM only.
// Applies a level-up the player confirmed (possibly tweaked from the proposal):
// Body: { to_level, pools: {hp_max: n, ...}, skills: [{name, pct}], grants, note }
// Updates the characters row and logs a level_history entry with what was
// ACTUALLY applied. Pool current values rise by the same amount as their max.

import { getUserEmail, unauthorized, json, forbidden, characterAccess } from '../../_lib/auth.js';
import { loadClass } from '../../_lib/class-loader.js';
import { xpTableFor, thresholdFor } from '../../_lib/leveling.js';

const POOL_FIELDS = ['hp_max', 'sdc_max', 'mdc_max', 'ppe_max', 'isp_max'];

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const b = await request.json();
  const character = await env.DB.prepare('SELECT * FROM characters WHERE id = ?').bind(params.id).first();
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

  let skills = [];
  try { skills = JSON.parse(character.skills); } catch { /* leave empty */ }
  if (Array.isArray(b.skills) && b.skills.length) {
    const byName = new Map(b.skills.filter((s) => s && typeof s.pct === 'number').map((s) => [s.name, s.pct]));
    for (const s of skills) {
      const to = byName.get(s.name);
      if (to == null || to === s.pct) continue;
      changes.skills.push({ name: s.name, from: s.pct, to });
      s.pct = to;
    }
    sets.push('skills = ?'); binds.push(JSON.stringify(skills));
  }

  sets.push("updated_at = datetime('now')");
  await env.DB.prepare(`UPDATE characters SET ${sets.join(', ')} WHERE id = ?`)
    .bind(...binds, params.id).run();
  await env.DB.prepare(
    `INSERT INTO level_history (character_id, from_level, to_level, xp_at_levelup, changes)
     VALUES (?, ?, ?, ?, ?)`
  ).bind(params.id, character.level, toLevel, character.xp, JSON.stringify(changes)).run();

  return json({ ok: true, level: toLevel, changes });
}
