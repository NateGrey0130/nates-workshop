// POST /api/character-creator/characters/:id/ppe-burn — burn a spell's permanent
//      P.P.E. out of the character's base. Body: { name }.
//
// BOOK-INGEST-AUDIT F101 (3 of 3). Six catalog spells take P.P.E. out of the
// CASTER'S BASE - Close Rift 2 on every attempt, Ley Line Resurrection 2D6 when
// it succeeds - and `spells.ppe_permanent` (migration 067) holds that number as a
// dice expression. This rolls it and adds it to `characters.ppe_base_spent`.
//
// THE NUMBER IS AUTOMATED AND THE CONDITION IS NOT, which was Nate's answer
// (2026-09-16). Whether this occasion burns anything - the spell succeeded, the
// enchantment was made permanent, the moon is full - is the player's call from
// the description, so nothing here fires on its own: the sheet's use button
// spends the activation cost as it always did, and this is a separate press.
//
// ROLLED HERE, NOT ON THE SHEET. `ppe_base_spent` is not player-editable (065),
// so a client that could name the amount could set it to anything; a client that
// can only name the spell gets the book's dice.
//
// NOT A PLAY EVENT. Play events can be undone, and the undo route restores pool
// columns it knows about - it would put `ppe_current` back and leave the burn in
// the base, which is a state no press produced. A burn is permanent by the book's
// own word, so it has no undo either.

import { json, readJson, requireCharacter } from '../../_lib/auth.js';
import { loadCharacter } from '../../_lib/character-json.js';
import { evalDice, diceBounds } from '../../../../../apps/character-creator/js/dice.js';

export async function onRequestPost({ request, env, params }) {
  const guard = await requireCharacter(request, env, params.id);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  const name = String(b?.name ?? '').trim();
  if (!name) return json({ error: 'name is required' }, 400);

  const character = await loadCharacter(env, params.id);
  // Only a spell the character HOLDS. Burning for a spell nobody knows would be
  // a free way to spend a base, which is not a thing the book has.
  const held = (character.powers || []).find((p) => p?.type === 'spell'
    && String(p.name ?? '').toLowerCase() === name.toLowerCase());
  if (!held) return json({ error: `${name} is not a spell this character knows` }, 400);

  const row = await env.DB.prepare('SELECT name, ppe_permanent FROM spells WHERE name = ? COLLATE NOCASE')
    .bind(name).first();
  if (!row?.ppe_permanent) return json({ error: `${name} burns no P.P.E. from the base` }, 400);
  // A catalog value that is not dice is refused rather than read as zero: a
  // silent zero is a burn the book prints and the sheet never takes.
  if (!diceBounds(row.ppe_permanent)) {
    return json({ error: `${row.name}'s permanent cost "${row.ppe_permanent}" is not a dice expression` }, 422);
  }
  if (character.ppe_max == null) return json({ error: 'This character has no P.P.E. to burn' }, 400);

  const rolled = evalDice(row.ppe_permanent);
  const spent = Number(character.ppe_base_spent) || 0;
  // A base cannot lose more than it has left, so a roll past it burns the rest.
  const burned = Math.max(0, Math.min(rolled, character.ppe_max - spent));
  const nextSpent = spent + burned;
  const cap = character.ppe_max - nextSpent;
  const current = character.ppe_current == null ? null : Math.min(character.ppe_current, cap);

  await env.DB.prepare(
    "UPDATE characters SET ppe_base_spent = ?, ppe_current = ?, updated_at = datetime('now') WHERE id = ?"
  ).bind(nextSpent, current, params.id).run();

  return json({
    ok: true, spell: row.name, dice: row.ppe_permanent, rolled, burned,
    ppe_base_spent: nextSpent, ppe_current: current, ppe_max_effective: cap,
  });
}
