// /api/marvel-heroes/campaigns/:id/npcs/:npcId - one dossier.
//
//   GET    -> { npc, mentions }: the dossier and every note that mentions them,
//             oldest first, which is the story. Members only.
//   PATCH  -> any member edits the fields. `sheet_id` links the GM's statted
//             sheet (msh_npc_sheets in this campaign) or unlinks it with null:
//             GM only. A rename onto a name already in People is a 409.
//   DELETE -> any member. Its mentions cascade; the notes are untouched, since
//             the @ in the text is just text. The portrait goes from R2 too.

import { requireMember, json, readJson, dropObject } from '../../../_lib/campaigns.js';
import { STATUSES, trim, serialiseAliases, dossierFor } from '../../../_lib/notes.js';

const ROW_ID = /^[1-9]\d{0,11}$/;
const found = (db, campaignId, npcId) => (ROW_ID.test(String(npcId))
  ? db.prepare('SELECT * FROM msh_npcs WHERE id = ? AND campaign_id = ?').bind(Number(npcId), campaignId).first()
  : null);

export async function onRequestGet({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const npc = await found(db, g.campaign.id, params.npcId);
  if (!npc) return json({ error: 'Not in People' }, 404);
  const { results } = await db.prepare(`SELECT j.id, j.title, j.body, j.author_email, j.session_date, j.created_at, m.source
    FROM msh_npc_mentions m JOIN msh_journal_entries j ON j.id = m.journal_entry_id
    WHERE m.npc_id = ? ORDER BY j.created_at, j.id`).bind(npc.id).all();
  return json({ npc: dossierFor(npc, g.isGm), mentions: results, can_write: true });
}

export async function onRequestPatch({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const npc = await found(db, g.campaign.id, params.npcId);
  if (!npc) return json({ error: 'Not in People' }, 404);
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('name' in b) {
    const name = trim(b.name);
    if (!name) return json({ error: 'name cannot be emptied' }, 400);
    const clash = await db.prepare('SELECT id FROM msh_npcs WHERE campaign_id = ? AND name = ? COLLATE NOCASE AND id != ?')
      .bind(g.campaign.id, name, npc.id).first();
    if (clash) return json({ error: `${name} already has a dossier; a rename does not merge two`, npc_id: clash.id }, 409);
    sets.push('name = ?'); binds.push(name);
  }
  if ('aliases' in b) { sets.push('aliases = ?'); binds.push(serialiseAliases(b.aliases)); }
  for (const f of ['faction', 'disposition', 'description']) if (f in b) { sets.push(`${f} = ?`); binds.push(trim(b[f])); }
  if ('status' in b) {
    if (!STATUSES.includes(b.status)) return json({ error: `status must be one of ${STATUSES.join(', ')}` }, 400);
    sets.push('status = ?'); binds.push(b.status);
  }
  if ('sheet_id' in b) {
    if (!g.isGm) return json({ error: 'Only the campaign GM can link a statted NPC' }, 403);
    if (b.sheet_id === null) sets.push('sheet_id = NULL');
    else {
      const sheet = Number.isInteger(b.sheet_id) && await db.prepare('SELECT id FROM msh_npc_sheets WHERE id = ? AND campaign_id = ?')
        .bind(b.sheet_id, g.campaign.id).first();
      if (!sheet) return json({ error: 'sheet_id must be an NPC sheet in this campaign' }, 400);
      sets.push('sheet_id = ?'); binds.push(sheet.id);
    }
  }
  if (!sets.length) return json({ error: 'Nothing to update' }, 400);
  const row = await db.prepare(`UPDATE msh_npcs SET ${sets.join(', ')}, updated_at = datetime('now') WHERE id = ? RETURNING *`)
    .bind(...binds, npc.id).first();
  return json({ npc: dossierFor(row, g.isGm) });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await requireMember(request, env, params.id);
  if (g.res) return g.res;
  const db = env.DB_MARVEL;
  const npc = await found(db, g.campaign.id, params.npcId);
  if (!npc) return json({ error: 'Not in People' }, 404);
  await dropObject(env, npc.portrait_key);
  await db.prepare('DELETE FROM msh_npcs WHERE id = ?').bind(npc.id).run();
  return json({ ok: true });
}
