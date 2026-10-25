// POST /api/character-creator/characters/:id/transfer {to_email}
//      -> { character: { id, player_email, kind } }
//
// The campaign's G.M. MOVES a character they own to a player on the
// Workshop's list (_lib/transfer.js has the rulings). It lands as that
// player's character - kind 'pc', in the same campaign - and shows in their
// GET /characters?mine=1 at once.
//
// Every guard is checked before anything is written:
//   - the recipient is on the list and is not the caller (before any read);
//   - the character is live and visible to the caller (404 otherwise, so a
//     hidden NPC stays as missing as it always is);
//   - the caller is the campaign's G.M. - a player cannot transfer, even
//     their own character;
//   - the caller OWNS the row. A G.M. can never transfer a player's character.
// A closed campaign is no bar: the G.M. still owns what is in it.
//
// WHAT IS CLEARED, because a player can now read what only the G.M. could:
//   - `notes`, replaced by one line saying where the character came from;
//   - the play log (play_events), which held the G.M.'s rolls - private ones
//     included - and its commentary. A transferred character starts with no
//     past, as a copy pulled from the library does;
//   - for a statted NPC, the notes on its gear and vehicles, which were as
//     hidden as the sheet. A G.M.'s own PC's gear notes were readable by
//     anyone already, and stay.
// The NPC dossier (`npcs.character_id`) is left linked: it is a campaign row
// the G.M. alone reads, and it describes the person, not the sheet.
//
// One batch, so it is one transaction: the child writes are each bound to the
// row still being the caller's, and the UPDATE that moves it goes last.

import { getUserEmail, unauthorized, json, readJson, requireCharacter } from '../../_lib/auth.js';
import { checkRecipient, ownerSpelling, transferNote } from '../../_lib/transfer.js';

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const recipient = checkRecipient(env, email, b.to_email);
  if (recipient.res) return recipient.res;
  const guard = await requireCharacter(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  const { access } = guard;
  if (!access.isGm) return json({ error: 'Only the campaign\'s G.M. can transfer a character' }, 403);
  if (access.character.player_email !== email) {
    return json({ error: 'Only a character the G.M. owns can be transferred - this one is a player\'s' }, 403);
  }

  const owner = await ownerSpelling(env, recipient.to);
  const id = access.character.id;
  const stillMine = 'EXISTS (SELECT 1 FROM characters WHERE id = ? AND player_email = ? AND deleted_at IS NULL)';
  const writes = [
    env.DB.prepare(`DELETE FROM play_events WHERE character_id = ? AND ${stillMine}`).bind(id, id, email),
  ];
  if (access.character.kind === 'npc') {
    for (const table of ['character_items', 'character_vehicles']) {
      writes.push(env.DB.prepare(`UPDATE ${table} SET notes = NULL WHERE character_id = ? AND ${stillMine}`)
        .bind(id, id, email));
    }
  }
  writes.push(env.DB.prepare(
    `UPDATE characters SET player_email = ?, kind = 'pc', notes = ?, updated_at = datetime('now')
     WHERE id = ? AND player_email = ? AND deleted_at IS NULL
     RETURNING id, player_email, kind`
  ).bind(owner, transferNote(), id, email));
  const results = await env.DB.batch(writes);
  const moved = results.at(-1).results?.[0];
  // Only a request racing this one can get here (a delete, or a second
  // transfer), and its own batch has already said what happened.
  if (!moved) return json({ error: 'Character not found' }, 404);
  return json({ character: moved });
}
