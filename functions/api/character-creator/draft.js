// GET    /api/character-creator/draft — the caller's unfinished build, if any
// PUT    /api/character-creator/draft — save it (upsert; one per person)
// DELETE /api/character-creator/draft — discard it
//
// Any authenticated user, and always scoped to the caller's own email. There is
// no id in the route on purpose: a draft belongs to a person, not a collection,
// and admitting an id would invite fetching someone else's half-built character.
//
// Top-level rather than under `characters/`, which routes `[id]` dynamically —
// a literal `draft` segment there would work, but "is /characters/draft the
// draft or a character called draft" is a question worth not having.
//
// The wizard writes here on a debounce while you build. It is deliberately
// tolerant: a draft is a convenience, so a save that fails must never interrupt
// the build, and a draft that cannot be read is discarded rather than mourned.

import { getUserEmail, unauthorized, readJson, json } from './_lib/auth.js';
import { safeParse } from './_lib/character-json.js';

// Bound on the stored blob. The wizard sends its own build state, not the
// catalogs, so a real draft is a few KB — anything approaching this is a bug or
// a caller doing something else, and either way should not reach the database.
const MAX_STATE_BYTES = 256 * 1024;

const str = (v) => (typeof v === 'string' && v.trim() ? v.trim().slice(0, 200) : null);

export async function onRequestGet({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const row = await env.DB.prepare(
    `SELECT id, system, class_id, class_name, char_name, step, state, created_at, updated_at
     FROM character_drafts WHERE owner_email = ?`
  ).bind(email).first();

  if (!row) return json({ draft: null });

  // A blob we cannot parse is worse than no draft: restoring half of it would
  // put the wizard in a state the user never built. Report it as absent.
  const state = safeParse(row.state, null);
  if (!state || typeof state !== 'object') return json({ draft: null, unreadable: true });

  return json({ draft: { ...row, state } });
}

export async function onRequestPut({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  const body = await readJson(request);
  if (!body || typeof body.state !== 'object' || body.state === null) {
    return json({ error: 'state must be an object' }, 400);
  }

  const state = JSON.stringify(body.state);
  if (state.length > MAX_STATE_BYTES) {
    return json({ error: 'Draft is too large to store' }, 413);
  }

  const step = Number.isFinite(body.step) ? Math.max(0, Math.min(20, Math.trunc(body.step))) : 0;

  // Upsert on the owner: one draft each, and a newer build replaces the older
  // one without the client having to know which it is.
  await env.DB.prepare(
    `INSERT INTO character_drafts (owner_email, system, class_id, class_name, char_name, step, state)
     VALUES (?, ?, ?, ?, ?, ?, ?)
     ON CONFLICT (owner_email) DO UPDATE SET
       system = excluded.system, class_id = excluded.class_id, class_name = excluded.class_name,
       char_name = excluded.char_name, step = excluded.step, state = excluded.state,
       updated_at = datetime('now')`
  ).bind(email, str(body.system), str(body.class_id), str(body.class_name), str(body.char_name), step, state).run();

  return json({ ok: true });
}

export async function onRequestDelete({ request, env }) {
  const email = getUserEmail(request);
  if (!email) return unauthorized();

  // No 404 when there is nothing to delete. Discarding is idempotent by
  // nature, and the wizard fires it after every successful save without
  // caring whether a draft was ever written.
  await env.DB.prepare(`DELETE FROM character_drafts WHERE owner_email = ?`).bind(email).run();
  return json({ ok: true });
}
