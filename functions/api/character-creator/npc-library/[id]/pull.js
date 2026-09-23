// POST /api/character-creator/npc-library/:id/pull {campaign_id, force?}
//
// Pull a library entry into a campaign as an INDEPENDENT copy: a new
// kind = 'npc' characters row there, with its picks, grants, items and
// vehicles. Later edits in either place never touch the other.
//
// Two guards, both checked before anything is written:
//   - the entry is the caller's (404 otherwise, as for any entry);
//   - the caller is the TARGET campaign's G.M. (requireCampaign gm).
// And the game has to match: a Rifts NPC in a Palladium Fantasy campaign is
// refused with a 409 that says so, and goes in only when the request says
// `force` - the page asks the G.M. first.
//
// Where the copy came from is written at the end of the sheet's notes, which
// costs no column.

import { json, readJson, requireCampaign } from '../../_lib/auth.js';
import { restoreSnapshot } from '../../_lib/npc-snapshot.js';

export async function onRequestPost({ request, env, params }) {
  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const campaignId = Number(b.campaign_id);
  if (!Number.isInteger(campaignId) || campaignId < 1) return json({ error: 'campaign_id is required' }, 400);

  const guard = await requireCampaign(request, env, campaignId, { gm: true });
  if (guard.res) return guard.res;
  const entry = await env.DB.prepare('SELECT * FROM npc_library WHERE id = ?').bind(params.id).first();
  if (!entry || entry.owner_email !== guard.email) return json({ error: 'Not found' }, 404);

  const camp = await env.DB.prepare('SELECT system FROM campaigns WHERE id = ?').bind(campaignId).first();
  if (entry.system && camp?.system && entry.system !== camp.system && !b.force) {
    return json({ error: `${entry.name} is a ${entry.system} NPC and this is a ${camp.system} campaign`,
      code: 'system_mismatch', entry_system: entry.system, campaign_system: camp.system }, 409);
  }

  let snap;
  try { snap = JSON.parse(entry.sheet); } catch { return json({ error: 'This entry\'s sheet cannot be read' }, 500); }
  const from = `Pulled from your NPC library (entry ${entry.id}, "${entry.name}") on ${new Date().toISOString().slice(0, 10)}.`;
  const notes = [snap.character?.notes, from].filter(Boolean).join('\n\n');
  const id = await restoreSnapshot(env, snap, { campaignId, email: guard.email, name: entry.name, notes });
  return json({ character: { id, name: entry.name } }, 201);
}
