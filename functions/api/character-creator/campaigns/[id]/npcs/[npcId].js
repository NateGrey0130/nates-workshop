// GET    …/npcs/:npcId — the dossier, plus every entry that mentions them, in
//        date order. The backlinks are the point: they are what actually
//        answers "what do we know about him?".
// PATCH  …/npcs/:npcId — edit the fields.
// DELETE …/npcs/:npcId — remove the dossier. Its mentions cascade; the notes
//        themselves are untouched, because the @ in the text is just text.

import { json, readJson, requireCampaign } from '../../../_lib/auth.js';
import { STATUSES, trim, serialiseAliases, parseAliases } from '../npcs.js';

export async function onRequestGet({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id, { write: false });
  if (guard.res) return guard.res;
  if (!guard.access.isMember) {
    return json({ error: 'Only the GM or a player with a character in this campaign can do that' }, 403);
  }
  const npc = await found(env, params);
  if (!npc) return json({ error: 'NPC not found' }, 404);
  npc.aliases = parseAliases(npc.aliases);

  const { results } = await env.DB.prepare(
    `SELECT j.id, j.title, j.body, j.author_email, j.session_date, j.created_at, m.source
     FROM npc_mentions m JOIN journal_entries j ON j.id = m.journal_entry_id
     WHERE m.npc_id = ? ORDER BY j.created_at, j.id`
  ).bind(params.npcId).all();

  return json({ npc, mentions: results, can_write: guard.access.isMember });
}

export async function onRequestPatch({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  const npc = await found(env, params);
  if (!npc) return json({ error: 'NPC not found' }, 404);

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];

  if ('name' in b) {
    const name = trim(b.name);
    if (!name) return json({ error: 'name cannot be emptied' }, 400);
    // Renaming onto a name already taken is a merge, not an insert - and a
    // merge is a bigger decision than a PATCH should make silently, so it is
    // refused with the id of the dossier standing in the way.
    const clash = await env.DB.prepare(
      'SELECT id FROM npcs WHERE campaign_id = ? AND name COLLATE NOCASE = ? AND id != ?'
    ).bind(params.id, name, params.npcId).first();
    if (clash) {
      return json({ error: `${name} already has a dossier — merging two is not something a rename does`,
                    npc_id: clash.id }, 409);
    }
    sets.push('name = ?'); binds.push(name);
  }
  if ('aliases' in b) { sets.push('aliases = ?'); binds.push(serialiseAliases(b.aliases)); }
  for (const field of ['faction', 'disposition', 'description']) {
    if (field in b) { sets.push(`${field} = ?`); binds.push(trim(b[field])); }
  }
  if ('status' in b) {
    if (!STATUSES.includes(b.status)) {
      return json({ error: `status must be one of ${STATUSES.join(', ')}` }, 400);
    }
    sets.push('status = ?'); binds.push(b.status);
  }
  if (!sets.length) return json({ error: 'Nothing to update' }, 400);
  sets.push("updated_at = datetime('now')");

  const row = await env.DB.prepare(
    `UPDATE npcs SET ${sets.join(', ')} WHERE id = ? RETURNING *`
  ).bind(...binds, params.npcId).first();
  row.aliases = parseAliases(row.aliases);
  return json({ npc: row });
}

export async function onRequestDelete({ request, env, params }) {
  const guard = await requireCampaign(request, env, params.id);
  if (guard.res) return guard.res;
  const npc = await found(env, params);
  if (!npc) return json({ error: 'NPC not found' }, 404);

  // The portrait goes with it. An orphaned object in R2 costs money forever and
  // is referenced by nothing, which is the one case where deleting is clearly
  // right. Best-effort: a dossier that would not delete because its image
  // could not be reached is worse than an object nobody points at.
  if (npc.portrait_key && env.MEDIA) {
    try { await env.MEDIA.delete(npc.portrait_key); } catch { /* see above */ }
  }
  await env.DB.prepare('DELETE FROM npcs WHERE id = ?').bind(params.npcId).run();
  return json({ ok: true });
}

async function found(env, params) {
  return env.DB.prepare('SELECT * FROM npcs WHERE id = ? AND campaign_id = ?')
    .bind(params.npcId, params.id).first();
}
