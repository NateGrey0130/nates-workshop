// POST /api/media-vault/items/bulk-update { ids: [...], set: { … } }
// — what the bulk bar's type buttons, format buttons and text-field form all
// call. The settable fields are a whitelist: everything else on an item goes
// through the single-item upsert, which validates the whole object.
//
// A field carries a KIND rather than only a list of allowed values. The
// original shape was a bare value whitelist, which works for two closed
// vocabularies and cannot express a field like `location` at all — there is no
// list of every shelf a person owns.
//
// WHAT IS DELIBERATELY ABSENT MATTERS AS MUCH AS WHAT IS HERE. `title`,
// `author`, `cover` and `notes` are not bulk-settable and should not become so:
// setting every selected row's title to one string is destructive by
// definition, and there is no use for it that is not a mistake. The three text
// fields below are the ones where a single shared value is the POINT — a shelf,
// a series, a genre.
import { getUserEmail, json, MAX_ITEMS, MAX_FIELD_LEN } from '../_lib/common.js';

const SETTABLE = {
  type: { values: ['audiobook', 'movie', 'series'] },
  format: { values: ['digital', 'physical'] },
  location: { text: true },
  series: { text: true },
  genre: { text: true },
};

// D1 allows 100 bound parameters per query, and the batch below binds
// `...values, email, ...chunk`: one per field being set, one for the email, and
// 90 ids. With every field above set at once that is 5 + 1 + 90 = 96. The
// headroom is four more fields, not unlimited — the smoke test does this
// arithmetic against the chunk size it reads out of this file, so adding a
// sixth and a seventh field fails the suite rather than failing in production
// against a query D1 refuses.
//
// The chunk size stays a literal in the loop, matching bulk.js and
// bulk-delete.js, because it is pinned to the README by a check that reads all
// three files the same way.

// Trimmed, and only here. The single-item save does not trim, because someone
// editing one row can see the box they typed into. A bulk set propagates one
// value to hundreds of rows at once, so a trailing space becomes hundreds of
// rows whose `location` looks identical to `Shelf B` and does not group,
// filter or search with it. One accident, multiplied — which is the whole
// character of a bulk edit, and worth a `.trim()` here.
//
// The empty string survives on purpose: clearing a location across a selection
// is a legitimate bulk edit, so this must not reject blanks.
function cleanText(v) {
  return v.trim().slice(0, MAX_FIELD_LEN);
}

export async function onRequestPost(context) {
  const email = getUserEmail(context.request);
  if (!email) return json({ error: 'Not authenticated' }, 401);

  let body;
  try {
    body = await context.request.json();
  } catch {
    return json({ error: 'Invalid JSON body' }, 400);
  }
  if (!body || !Array.isArray(body.ids) || body.ids.length === 0) {
    return json({ error: 'Body must be { ids: [...], set: {...} }' }, 400);
  }
  if (body.ids.length > MAX_ITEMS) return json({ error: `Too many ids (max ${MAX_ITEMS})` }, 400);
  if (body.ids.some((id) => typeof id !== 'string' || !id || id.length > 100)) {
    return json({ error: 'Every id must be a string' }, 400);
  }
  const set = body.set;
  if (!set || typeof set !== 'object') return json({ error: 'Missing set object' }, 400);
  const fields = Object.keys(set);
  if (fields.length === 0) return json({ error: 'set names no fields' }, 400);
  for (const f of fields) {
    const rule = SETTABLE[f];
    if (!rule) return json({ error: `Field not bulk-settable: ${f}` }, 400);
    if (rule.values) {
      if (!rule.values.includes(set[f])) return json({ error: `Invalid value for ${f}: ${set[f]}` }, 400);
    } else if (typeof set[f] !== 'string') {
      // Named rather than reported as a generic invalid value: a client sending
      // a number or null here has a bug, and `Invalid value for location: null`
      // reads as "your shelf name is wrong".
      return json({ error: `${f} must be a string` }, 400);
    }
  }

  const assignments = fields.map((f) => `${f} = ?`).join(', ');
  const values = fields.map((f) => (SETTABLE[f].values ? set[f] : cleanText(set[f])));
  const db = context.env.DB;
  try {
    // Chunked because D1 caps bound parameters per query.
    const statements = [];
    for (let i = 0; i < body.ids.length; i += 90) {
      const chunk = body.ids.slice(i, i + 90);
      const placeholders = chunk.map(() => '?').join(', ');
      statements.push(
        db.prepare(`UPDATE media_items SET ${assignments} WHERE user_email = ? AND item_id IN (${placeholders})`)
          .bind(...values, email, ...chunk)
      );
    }
    const results = await db.batch(statements);
    const changed = results.reduce((n, r) => n + (r.meta?.changes || 0), 0);
    return json({ ok: true, count: changed });
  } catch (err) {
    return json({ error: 'DB error: ' + err.message }, 500);
  }
}
