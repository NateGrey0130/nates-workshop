// POST /api/character-creator/npc-library/:id/transfer {to_email, campaign_id, force?}
//      -> 201 { character: { id, name, player_email, kind } }
//
// A G.M. MOVES a library entry to a player (_lib/transfer.js has the rulings):
// it becomes that player's character - kind 'pc' - in a campaign the G.M.
// runs, and the entry is gone from the library. The pull (pull.js) is the
// same restore into the G.M.'s own hands, and keeps the entry.
//
// Every guard is checked before anything is written:
//   - the recipient is on the list and is not the caller (before any read);
//   - the caller is the TARGET campaign's G.M. (requireCampaign gm);
//   - the entry is the caller's (404 otherwise, as for any entry);
//   - the game matches, unless the request says `force` - pull.js's rule and
//     its 409, so the page can ask the same question.
//
// What arrives: the sheet and its picks, grants, gear and vehicles, as a pull
// brings them. What does not: the sheet's notes, replaced by one line saying
// where the character came from; the entry's own notes, deleted with it; and
// the notes on its gear and vehicles, which an NPC's G.M. alone could read.
//
// AS CLOSE TO ATOMIC AS D1 ALLOWS. The new characters row is one statement,
// because its id is what the rest bind to; the child rows and the entry's
// DELETE are then one batch, which is one transaction. If that batch fails,
// restoreSnapshot takes the new row back out, and the entry is untouched. If
// the DELETE matched nothing - a second transfer or a delete got there first -
// the new row is taken back out the same way and the answer is 404. What is
// left uncovered is the Function dying between the two steps: the player then
// has the character and the G.M. still has the entry, a copy rather than a
// move, which the G.M. can delete. Nothing is ever lost.

import { getUserEmail, unauthorized, json, readJson, requireCampaign } from '../../_lib/auth.js';
import { restoreSnapshot } from '../../_lib/npc-snapshot.js';
import { checkRecipient, ownerSpelling, transferNote } from '../../_lib/transfer.js';

export async function onRequestPost({ request, env, params }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const recipient = checkRecipient(env, email, b.to_email);
  if (recipient.res) return recipient.res;
  const campaignId = Number(b.campaign_id);
  if (!Number.isInteger(campaignId) || campaignId < 1) return json({ error: 'campaign_id is required' }, 400);

  const guard = await requireCampaign(request, env, campaignId, { gm: true });
  if (guard.res) return guard.res;
  const entry = await env.DB.prepare('SELECT * FROM npc_library WHERE id = ?').bind(params.id).first();
  if (!entry || entry.owner_email !== email) return json({ error: 'Not found' }, 404);

  const camp = await env.DB.prepare('SELECT system FROM campaigns WHERE id = ?').bind(campaignId).first();
  if (entry.system && camp?.system && entry.system !== camp.system && !b.force) {
    return json({ error: `${entry.name} is a ${entry.system} NPC and this is a ${camp.system} campaign`,
      code: 'system_mismatch', entry_system: entry.system, campaign_system: camp.system }, 409);
  }

  let snap;
  try { snap = JSON.parse(entry.sheet); } catch { return json({ error: 'This entry\'s sheet cannot be read' }, 500); }
  const unnoted = (rows) => (rows || []).map((r) => ({ ...r, notes: null }));
  snap = { ...snap, items: unnoted(snap.items), vehicles: unnoted(snap.vehicles) };
  const owner = await ownerSpelling(env, recipient.to);
  const { id, extra } = await restoreSnapshot(env, snap, {
    campaignId, email: owner, name: entry.name, notes: transferNote(), kind: 'pc',
    extraWrites: [env.DB.prepare('DELETE FROM npc_library WHERE id = ? AND owner_email = ?').bind(entry.id, email)],
  });
  if (!extra[0]?.meta?.changes) {
    await env.DB.prepare('DELETE FROM characters WHERE id = ?').bind(id).run();
    return json({ error: 'Not found' }, 404);
  }
  return json({ character: { id, name: entry.name, player_email: owner, kind: 'pc' } }, 201);
}
