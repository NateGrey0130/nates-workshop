// POST /api/character-creator/characters/:id/xp — owner/GM only.
// Body: { delta } (add to current) or { total } (set absolute). Updates
// characters.xp immediately; if the new total crosses level threshold(s) the
// response carries a PROPOSED diff — nothing else is applied until the player
// confirms (or tweaks) it via level-confirm.

import { getUserEmail, unauthorized, json, forbidden, characterAccess } from '../../_lib/auth.js';
import { loadClass } from '../../_lib/class-loader.js';
import { xpTableFor, levelForXp, thresholdFor, buildProposal } from '../../_lib/leveling.js';

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const access = await characterAccess(env, params.id, email);
  if (!access.found) return json({ error: 'Character not found' }, 404);
  if (!access.canWrite) return forbidden();

  const b = await request.json();
  const character = await env.DB.prepare('SELECT * FROM characters WHERE id = ?').bind(params.id).first();
  let newXp;
  if ('total' in b) newXp = parseInt(b.total, 10);
  else if ('delta' in b) newXp = character.xp + parseInt(b.delta, 10);
  if (!Number.isFinite(newXp)) return json({ error: 'Body needs a numeric delta or total' }, 400);
  newXp = Math.max(0, newXp);

  await env.DB.prepare("UPDATE characters SET xp = ?, updated_at = datetime('now') WHERE id = ?")
    .bind(newXp, params.id).run();

  const cls = await loadClass(env, request.url, character.class_id);
  if (!cls) {
    return json({ xp: newXp, level: character.level, next_threshold: null, proposal: null,
                  warning: `Class definition '${character.class_id}' not found — level check skipped` });
  }

  const table = xpTableFor(cls);
  const earnedLevel = levelForXp(table, newXp);
  let proposal = null;
  if (earnedLevel > character.level) {
    try { character.skills = JSON.parse(character.skills); } catch { character.skills = []; }
    proposal = buildProposal(character, cls, earnedLevel);
  }
  return json({
    xp: newXp,
    level: character.level,
    next_threshold: thresholdFor(table, character.level + 1),
    proposal,
  });
}
