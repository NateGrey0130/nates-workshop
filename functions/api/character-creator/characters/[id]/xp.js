// POST /api/character-creator/characters/:id/xp — owner/GM only.
// Body: { delta } (add to current) or { total } (set absolute). Updates
// characters.xp immediately; if the new total crosses level threshold(s) the
// response carries a PROPOSED diff — nothing else is applied until the player
// confirms (or tweaks) it via level-confirm.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { loadCharacterClass } from '../../_lib/class-loader.js';
import { xpTableFor, levelForXp, thresholdFor, buildProposal } from '../../_lib/leveling.js';
import { loadCharacter } from '../../_lib/character-json.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const character = await loadCharacter(env, params.id);
  const isTotal = 'total' in b;
  const n = parseInt(isTotal ? b.total : b.delta, 10);
  if (!Number.isFinite(n)) return json({ error: 'Body needs a numeric delta or total' }, 400);

  // A delta is added IN the statement, not to the value read above: the G.M.
  // and a player awarding at the same moment would each add to the same
  // starting number and one award would be lost.
  const row = await env.DB.prepare(
    `UPDATE characters SET xp = max(0, ${isTotal ? '?' : 'xp + ?'}), updated_at = datetime('now')
     WHERE id = ? RETURNING xp`
  ).bind(n, params.id).first();
  const newXp = row ? row.xp : Math.max(0, isTotal ? n : character.xp + n);

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
