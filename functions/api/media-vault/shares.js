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
import { looksLikeEmail, normalizeEmail, shareCandidates } from '../_lib/people.js';

// A ceiling, not a policy. The real bound is the candidate list below, which
// holds one entry per person who can sign in to the Workshop - a number this
// comment deliberately does not state, because nothing here can recompute it
// and the last one written down was wrong within a day. Kept anyway because a
// ceiling that is never reached costs nothing, and because it is the only
// thing standing between a misconfigured environment and an unbounded table.
const MAX_SHARES = 50;

// The candidate list, the address test and the case rule live in
// functions/api/_lib/people.js, with the reasons the list is a hand-kept mirror
// of the Access policy and why unset means nobody.

// Owner is stored EXACTLY as the identity header gives it, because that is what
// media_items.user_email holds and V2's read joins the two. Viewer is stored
// lowercased, because it is compared against a different request's identity
// rather than used as a key into existing rows, and the middleware already
// treats the two cases as one identity
// (functions/api/_middleware.js compares header and token lowercased).
const normalizeViewer = normalizeEmail;

// GET → { email, sharedByMe, sharedWithMe }
export async function onRequestGet(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  try {
    const db = context.env.DB_TOOLS;
    const [mine, theirs] = await db.batch([
      db.prepare('SELECT viewer_email, created_at FROM media_shares WHERE owner_email = ? ORDER BY created_at')
        .bind(email),
      db.prepare('SELECT owner_email, created_at FROM media_shares WHERE viewer_email = ? ORDER BY created_at')
        .bind(normalizeViewer(email)),
    ]);
    const granted = new Set((mine.results || []).map((r) => r.viewer_email));
    const self = normalizeViewer(email);
    return json({
      email,
      sharedByMe: (mine.results || []).map((r) => ({ email: r.viewer_email, createdAt: r.created_at })),
      sharedWithMe: (theirs.results || []).map((r) => ({ email: r.owner_email, createdAt: r.created_at })),
      // What the picker may offer: everyone who can sign in, less yourself and
      // less the people already granted. The client renders these and nothing
      // else, and POST re-checks the same list - a picker is UI, and a grant
      // endpoint that accepts whatever it is handed makes a closed picker
      // decorative.
      candidates: shareCandidates(context.env).filter((c) => c !== self && !granted.has(c)),
      // How many addresses the MIRROR holds, before yourself and the existing
      // grants are taken out - so it can be compared against the Access policy's
      // rule count, which is the only way to see that the hand-kept mirror has
      // fallen behind. A number, never the addresses: `MV_SHARE_CANDIDATES` is
      // `secret_text` precisely so the list does not leave the deployment, and a
      // length does not. SHARE-AUDIT V8.
      candidateCount: shareCandidates(context.env).length,
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

  // THE HALF MOST LIKELY TO BE SKIPPED, and the reason the picker is worth
  // anything. Without it the closed list is a suggestion the client is free to
  // ignore. Fails closed when MV_SHARE_CANDIDATES is unset: no candidates, no
  // grants, and a message that says which knob is wrong rather than "forbidden".
  const candidates = shareCandidates(context.env);
  if (!candidates.includes(viewer)) {
    return json({
      error: candidates.length
        ? 'That address cannot sign in to the Workshop, so sharing with it would do nothing. Ask Nate to add them first.'
        : 'Sharing is not configured on this deployment (MV_SHARE_CANDIDATES is unset)',
    }, 400);
  }

  const db = context.env.DB_TOOLS;
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
    await context.env.DB_TOOLS
      .prepare('DELETE FROM media_shares WHERE owner_email = ? AND viewer_email = ?')
      .bind(email, viewer)
      .run();
    return json({ ok: true });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
