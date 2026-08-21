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
import { parseMentions, resolveMentions, reconcileStatements, existingMentions } from '../_lib/mentions.js';

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

  // An edit that removes a name must stop listing the entry under that NPC. A
  // mention list that only ever grows is one that lies about the current text.
  //
  // Only the mentions a PERSON typed are reconciled — a link the sweep made is
  // the model's reading of an entry that never contained an @, and rewriting the
  // body must not silently delete it.
  if ('body' in b) {
    try {
      const names = parseMentions(row.body);
      const byName = await resolveMentions(env, {
        campaignId: guard.entry.campaign_id, names, email: guard.email,
      });
      const statements = reconcileStatements(env, {
        entryId: row.id,
        npcIdsByName: byName,
        existingMentionNpcIds: await existingMentions(env, row.id),
      });
      if (statements.length) await env.DB.batch(statements);
    } catch { /* a note is the thing being saved; see journal.js */ }
  }
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
