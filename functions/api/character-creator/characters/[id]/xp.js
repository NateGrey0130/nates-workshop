// POST /api/character-creator/characters/:id/xp — owner/GM only.
// Body: { delta } (add to current) or { total } (set absolute). Updates
// characters.xp immediately; if the new total crosses level threshold(s) the
// response carries a PROPOSED diff — nothing else is applied until the player
// confirms (or tweaks) it via level-confirm.

import { json, requireCharacter } from '../../_lib/auth.js';
import { loadCharacterClass } from '../../_lib/class-loader.js';
import { xpTableFor, levelForXp, thresholdFor, buildProposal } from '../../_lib/leveling.js';
import { loadCharacter } from '../../_lib/character-json.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await request.json();
  const character = await loadCharacter(env, params.id);
  let newXp;
  if ('total' in b) newXp = parseInt(b.total, 10);
  else if ('delta' in b) newXp = character.xp + parseInt(b.delta, 10);
  if (!Number.isFinite(newXp)) return json({ error: 'Body needs a numeric delta or total' }, 400);
  newXp = Math.max(0, newXp);

  await env.DB.prepare("UPDATE characters SET xp = ?, updated_at = datetime('now') WHERE id = ?")
    .bind(newXp, params.id).run();

  const cls = await loadCharacterClass(env, request.url, character);
  if (!cls) {
    return json({ xp: newXp, level: character.level, next_threshold: null, proposal: null,
                  warning: `Class definition '${character.class_id}' not found — level check skipped` });
  }

  const table = xpTableFor(cls);
  const earnedLevel = levelForXp(table, newXp);
  let proposal = null;
  if (earnedLevel > character.level) {
    proposal = buildProposal(character, cls, earnedLevel);
  }
  return json({
    xp: newXp,
    level: character.level,
    next_threshold: thresholdFor(table, character.level + 1),
    proposal,
  });
}
