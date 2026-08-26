// Shared by MediaVault's endpoints: identity, the JSON response shape, and
// the item sanitizer. Identity comes from the site-wide Access helper with the
// same dev@localhost fallback FilamentForge and the character creator use —
// local dev (wrangler pages dev) has no Access in front of it to inject the
// header.

import { getAccessEmail } from '../../_lib/access.js';

export function getUserEmail(request) {
  const email = getAccessEmail(request);
  if (email) return email;
  const host = new URL(request.url).hostname;
  if (host === 'localhost' || host === '127.0.0.1') return 'dev@localhost';
  return null;
}

export function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

// ISBN input, in two jobs kept separate on purpose. normalizeIsbn makes what a
// person typed or pasted comparable; isIsbnShape says whether the result could
// be an ISBN at all. Neither validates the check digit — that is a different
// question with a different answer for the user ("you mistyped it", not "we
// don't have it"), and it belongs in the client, where it can be said before a
// request is made rather than after one comes back empty.
//
// The upper-case is load-bearing. OpenLibrary returns a full record for
// `ISBN:043935806X` and nothing at all for `ISBN:043935806x`, so a lower-case
// x reaching the query would turn a loud error into a silent "no results
// found" — which is the failure this app is worst at explaining.
export function normalizeIsbn(raw) {
  return String(raw || '').replace(/[-\s]/g, '').toUpperCase();
}

// An ISBN-10 is nine digits and a check character that may be X; an ISBN-13 is
// thirteen digits and is never X. This replaced `/^\d{10,13}$/`, which was
// wrong in both directions. It rejected every X check digit — 9.6% of ISBN-10s,
// measured across 1,233 of them, about one book in eleven — so real books came
// back "Invalid ISBN". And it accepted 11- and 12-digit strings that are not
// ISBNs in any scheme, so a truncated paste was sent to OpenLibrary and
// reported back as a book nobody has. The same regex was copied into app.js
// where it decided ROUTING, so an ISBN ending in X, typed and entered, was
// searched for as a film title.
export function isIsbnShape(isbn) {
  return /^(?:\d{9}[\dX]|\d{13})$/.test(isbn);
}

export const ITEM_FIELDS = ['type', 'format', 'title', 'author', 'actors', 'producers', 'genre', 'series', 'location', 'cover', 'notes'];
export const MAX_ITEMS = 5000;
export const MAX_FIELD_LEN = 4000;

export function sanitizeItem(item) {
  if (!item || typeof item !== 'object') return null;
  if (typeof item.id !== 'string' || !item.id || item.id.length > 100) return null;
  if (typeof item.title !== 'string' || !item.title.trim()) return null;
  const clean = { id: item.id, addedAt: Number.isFinite(item.addedAt) ? item.addedAt : Date.now() };
  for (const f of ITEM_FIELDS) {
    const v = item[f];
    clean[f] = typeof v === 'string' ? v.slice(0, MAX_FIELD_LEN) : '';
  }
  if (!clean.type) clean.type = 'audiobook';
  if (!clean.format) clean.format = 'digital';
  return clean;
}

export function rowToItem(row) {
  return {
    id: row.item_id,
    type: row.type,
    format: row.format,
    title: row.title,
    author: row.author,
    actors: row.actors,
    producers: row.producers,
    genre: row.genre,
    series: row.series,
    location: row.location,
    cover: row.cover,
    notes: row.notes,
    addedAt: row.added_at,
  };
}

export const UPSERT_SQL =
  `INSERT INTO media_items (user_email, item_id, type, format, title, author, actors, producers, genre, series, location, cover, notes, added_at)
   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
   ON CONFLICT (user_email, item_id) DO UPDATE SET
     type = excluded.type, format = excluded.format, title = excluded.title,
     author = excluded.author, actors = excluded.actors, producers = excluded.producers,
     genre = excluded.genre, series = excluded.series, location = excluded.location,
     cover = excluded.cover, notes = excluded.notes, added_at = excluded.added_at`;

export function bindUpsert(stmt, email, it) {
  return stmt.bind(
    email, it.id, it.type, it.format, it.title, it.author, it.actors,
    it.producers, it.genre, it.series, it.location, it.cover, it.notes, it.addedAt
  );
}

export async function countItems(db, email) {
  const row = await db
    .prepare('SELECT count(*) AS n FROM media_items WHERE user_email = ?')
    .bind(email)
    .first();
  return row ? row.n : 0;
}
