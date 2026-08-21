// PATCH  /api/character-creator/journal/:entryId — { title?, body?, session_date? }
//        The author edits their own entry; the G.M. may edit any.
// DELETE /api/character-creator/journal/:entryId — the author deletes their
//        own; the G.M. deletes any.
//
// A hard delete, unlike the party stash's soft one. A note is somebody's
// writing and "unsend" should mean it: keeping a tombstone of what a player
// asked to remove would be the opposite of what they asked for. The FTS index
// follows via the AFTER DELETE trigger, and campaign_items.journal_entry_id is
// ON DELETE SET NULL, so an item keeps its place in the stash and simply stops
// pointing at an explanation that no longer exists.

import { getUserEmail, unauthorized, json, readJson, campaignAccess } from '../_lib/auth.js';

export async function onRequestPatch({ request, env, params }) {
  const guard = await entryGuard(request, env, params.entryId);
  if (guard.res) return guard.res;

  const b = await readJson(request);
  if (!b) return json({ error: 'Invalid JSON body' }, 400);
  const sets = [], binds = [];
  if ('title' in b) { sets.push('title = ?'); binds.push(b.title ?? null); }
  if ('session_date' in b) { sets.push('session_date = ?'); binds.push(b.session_date ?? null); }
  if ('body' in b) {
    if (typeof b.body !== 'string' || !b.body.trim()) {
      return json({ error: 'body cannot be emptied — delete the entry instead' }, 400);
    }
    sets.push('body = ?'); binds.push(b.body);
  }
  if (!sets.length) return json({ error: 'Nothing to update' }, 400);

  const row = await env.DB.prepare(
    `UPDATE journal_entries SET ${sets.join(', ')} WHERE id = ? RETURNING *`
  ).bind(...binds, params.entryId).first();
  return json({ entry: row });
}

export async function onRequestDelete({ request, env, params }) {
  const guard = await entryGuard(request, env, params.entryId);
  if (guard.res) return guard.res;
  await env.DB.prepare('DELETE FROM journal_entries WHERE id = ?').bind(params.entryId).run();
  return json({ ok: true });
}

// Who may change an entry: the person who wrote it, or the campaign's G.M.
//
// Narrower than membership on purpose. Everyone in a campaign can WRITE notes,
// and letting any of them rewrite each other's account of a session is a
// different thing — the G.M. keeps the moderator's key because somebody has to
// have it, and nobody else does.
async function entryGuard(request, env, entryId) {
  const email = getUserEmail(request);
  if (!email) return { res: unauthorized() };
  const entry = await env.DB.prepare(
    'SELECT id, campaign_id, author_email FROM journal_entries WHERE id = ?'
  ).bind(entryId).first();
  // 404 before 403, so probing ids cannot distinguish an entry that exists.
  if (!entry) return { res: json({ error: 'Entry not found' }, 404) };

  const access = await campaignAccess(env, entry.campaign_id, email);
  if (entry.author_email !== email && !access.isGm) {
    return { res: json({ error: 'Only the author or the campaign GM can change an entry' }, 403) };
  }
  return { email, entry, access };
}
