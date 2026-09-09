// /api/media-vault/vault — read SOMEBODY ELSE'S library, if they said you may.
// SHARE-AUDIT.md V2.
//
// THIS IS THE ONLY FILE IN MEDIAVAULT THAT RETURNS ROWS THE CALLER DOES NOT OWN,
// and that is the point of it being its own file rather than a parameter on
// items.js. Every other statement in this app binds the caller's own email, and
// apps/media-vault/test/smoke.mjs asserts two things about that: no media_items
// SELECT/UPDATE/DELETE anywhere is missing `WHERE user_email = ?`, and this is
// the one file that consults media_shares to decide whose email to bind.
//
// A sibling app made the other choice and it is worth knowing about rather than
// discovering: functions/api/character-creator/characters/[id].js:2 says "Reads
// are open to any authenticated friend", and keeps that open read in the same
// file as its owner-only writes, guarded by a helper with a write flag. That is
// a live, documented, opposite decision. MediaVault splits instead because its
// libraries are private by default - a character is shared with a table, a
// media library is not shared with anyone until a row here says so.
//
// READ-ONLY BY CONSTRUCTION. This file makes exactly one kind of statement, a
// SELECT, and exports only onRequestGet - so a POST or DELETE to this path is
// answered 405 by the router rather than by a check somebody has to remember.

import { getUserEmail, json, rowToItem } from './_lib/common.js';

// The two columns carry two case conventions, and mixing them up is the bug
// this endpoint is most likely to have. media_shares.owner_email is stored
// EXACTLY as the identity header gave it, because that is what
// media_items.user_email holds and these two are joined; viewer_email is stored
// lowercased, because it is compared against a DIFFERENT request's identity.
// So: match the caller lowercased, then bind the owner verbatim.
const normalizeViewer = (s) => String(s || '').trim().toLowerCase();

// GET ?owner=<email> → { owner, items }
export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  const owner = (new URL(context.request.url).searchParams.get('owner') || '').trim();
  if (!owner) return json({ error: 'Missing owner query parameter' }, 400);

  const db = context.env.DB;
  try {
    // The grant is checked FIRST and separately, so the library read below can
    // never run without one. Bundling the two into a single joined statement
    // would work and would make "did this caller have permission" a property of
    // a WHERE clause somebody could later loosen while fixing something else.
    const grant = await db
      .prepare('SELECT 1 FROM media_shares WHERE owner_email = ? AND viewer_email = ?')
      .bind(owner, normalizeViewer(email))
      .first();
    // The same answer whether the grant never existed or was revoked a second
    // ago, and whether or not that library exists. A viewer learning which
    // addresses have libraries is a small leak, and it is free not to have.
    if (!grant) return json({ error: 'That library is not shared with you' }, 403);

    const { results } = await db
      .prepare('SELECT * FROM media_items WHERE user_email = ? ORDER BY added_at')
      .bind(owner)
      .all();
    return json({ owner, items: results.map(rowToItem) });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
