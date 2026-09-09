// /api/media-vault/shares — who may read this caller's library, and whose they
// may read. SHARE-AUDIT.md V1.
//
// EVERY STATEMENT HERE IS SCOPED TO THE CALLER, exactly like the rest of this
// app. A caller reads and writes grants where they are the OWNER, and reads
// (never writes) grants where they are the VIEWER. Nothing in this file reads a
// media_items row, and that is deliberate: the cross-user library read is V2's
// single endpoint, so there stays exactly ONE place in MediaVault that returns
// rows the caller does not own.
//
// The pair is the primary key, so POST is an upsert and granting twice is
// idempotent; DELETE names one known row rather than searching for it.

import { getUserEmail, json } from './_lib/common.js';

// A ceiling, not a policy. V4 replaces the open POST below with a closed list
// derived from the Access allow list, which bounds this to five or so - until
// it lands, the endpoint accepts any address that looks like an email, and this
// is what stops an authenticated caller filling the table. Deliberately far
// above any real use: five friends, and the picker will offer four.
const MAX_SHARES = 50;

// Enough to reject a typo and a paste of something that is not an address at
// all. NOT a validity test - whether an address can actually sign in is a
// question only the Access policy can answer, and no Function here can read it
// (CLAUDE.md, Three credentials). V4 answers it from the mirrored list instead.
const looksLikeEmail = (s) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(s);

// Owner is stored EXACTLY as the identity header gives it, because that is what
// media_items.user_email holds and V2's read joins the two. Viewer is stored
// lowercased, because it is compared against a different request's identity
// rather than used as a key into existing rows, and the middleware already
// treats the two cases as one identity
// (functions/api/_middleware.js compares header and token lowercased).
const normalizeViewer = (s) => String(s || '').trim().toLowerCase();

// GET → { email, sharedByMe, sharedWithMe }
export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  try {
    const db = context.env.DB;
    const [mine, theirs] = await db.batch([
      db.prepare('SELECT viewer_email, created_at FROM media_shares WHERE owner_email = ? ORDER BY created_at')
        .bind(email),
      db.prepare('SELECT owner_email, created_at FROM media_shares WHERE viewer_email = ? ORDER BY created_at')
        .bind(normalizeViewer(email)),
    ]);
    return json({
      email,
      sharedByMe: (mine.results || []).map((r) => ({ email: r.viewer_email, createdAt: r.created_at })),
      sharedWithMe: (theirs.results || []).map((r) => ({ email: r.owner_email, createdAt: r.created_at })),
    });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// POST { email } → let that address read the caller's library
export async function onRequestPost(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  let body;
  try {
    body = await context.request.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }

  const viewer = normalizeViewer(body && body.email);
  if (!looksLikeEmail(viewer)) return json({ error: 'Needs an email address to share with' }, 400);
  // Sharing with yourself is not a grant, it is a no-op that would then appear
  // in your own "shared with me" list as your own library.
  if (viewer === normalizeViewer(email)) return json({ error: 'That is your own library' }, 400);

  const db = context.env.DB;
  try {
    const existing = await db
      .prepare('SELECT 1 FROM media_shares WHERE owner_email = ? AND viewer_email = ?')
      .bind(email, viewer)
      .first();
    if (!existing) {
      const row = await db
        .prepare('SELECT count(*) AS n FROM media_shares WHERE owner_email = ?')
        .bind(email)
        .first();
      if ((row ? row.n : 0) >= MAX_SHARES) {
        return json({ error: `You can share with at most ${MAX_SHARES} people` }, 400);
      }
    }
    await db
      .prepare(`INSERT INTO media_shares (owner_email, viewer_email, created_at)
                VALUES (?, ?, ?)
                ON CONFLICT (owner_email, viewer_email) DO NOTHING`)
      .bind(email, viewer, Date.now())
      .run();
    return json({ ok: true, email: viewer });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}

// DELETE ?email=<viewer> → stop sharing with that address
//
// Takes effect on the viewer's NEXT request. Whatever is already painted on
// their screen survives until they reload, because this app holds the whole
// library in memory (apps/media-vault/app.js) - the same honest contract the
// bulk-delete undo toast makes about its buffer.
export async function onRequestDelete(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  const viewer = normalizeViewer(new URL(context.request.url).searchParams.get('email'));
  if (!viewer) return json({ error: 'Missing email query parameter' }, 400);

  try {
    await context.env.DB
      .prepare('DELETE FROM media_shares WHERE owner_email = ? AND viewer_email = ?')
      .bind(email, viewer)
      .run();
    return json({ ok: true });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
