// /api/marvel-heroes/journal/:entryId - one note.
//
//   PATCH  { title?, body?, session_date? } -> { entry }. An edited body has its
//          @mentions reconciled: a name taken out stops listing the note.
//   DELETE -> a hard delete; the search index follows by trigger.
// Its author, or the campaign's GM, and nobody else: everyone at the table can
// write notes, and letting any of them rewrite another's is a different thing.

import { owner, json, readJson } from '../_lib/campaigns.js';
import { reconcileMentions } from '../_lib/notes.js';

const ROW_ID = /^[1-9]\d{0,11}$/;

async function guard(request, env, entryId) {
  const email = owner(request);
  if (!email) return { res: json({ error: 'not signed in' }, 401) };
  const entry = ROW_ID.test(String(entryId)) && await env.DB_MARVEL.prepare(`SELECT e.id, e.campaign_id, e.author_email, c.gm_email
    FROM msh_journal_entries e JOIN msh_campaigns c ON c.id = e.campaign_id WHERE e.id = ?`).bind(Number(entryId)).first();
  // 404 before 403, so probing ids cannot tell which exist.
  if (!entry) return { res: json({ error: 'Entry not found' }, 404) };
  if (entry.author_email !== email && entry.gm_email !== email) {
    return { res: json({ error: 'Only the author or the campaign GM can change a note' }, 403) };
  }
  return { email, entry };
}

export async function onRequestPatch({ request, env, params }) {
  const g = await guard(request, env, params.entryId);
  if (g.res) return g.res;
  const b = await readJson(request);
  if (!b || typeof b !== 'object') return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('title' in b) { sets.push('title = ?'); binds.push(typeof b.title === 'string' ? b.title.slice(0, 200) : null); }
  if ('session_date' in b) { sets.push('session_date = ?'); binds.push(typeof b.session_date === 'string' ? b.session_date.slice(0, 40) : null); }
  if ('body' in b) {
    if (typeof b.body !== 'string' || !b.body.trim()) return json({ error: 'body cannot be emptied; delete the note instead' }, 400);
    sets.push('body = ?'); binds.push(b.body.slice(0, 20000));
  }
  if (!sets.length) return json({ error: 'Nothing to update' }, 400);
  const db = env.DB_MARVEL;
  const row = await db.prepare(`UPDATE msh_journal_entries SET ${sets.join(', ')} WHERE id = ? RETURNING *`)
    .bind(...binds, g.entry.id).first();
  if ('body' in b) {
    try {
      const statements = await reconcileMentions(db, { entryId: row.id, campaignId: row.campaign_id, body: row.body, email: g.email });
      if (statements.length) await db.batch(statements);
    } catch { /* the note is the thing being saved */ }
  }
  return json({ entry: row });
}

export async function onRequestDelete({ request, env, params }) {
  const g = await guard(request, env, params.entryId);
  if (g.res) return g.res;
  await env.DB_MARVEL.prepare('DELETE FROM msh_journal_entries WHERE id = ?').bind(g.entry.id).run();
  return json({ ok: true });
}
