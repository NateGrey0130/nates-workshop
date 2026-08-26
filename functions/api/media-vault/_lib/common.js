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

// ─── ISBN input ───
// Four questions about a typed or pasted string, kept apart because each one
// needs the user told a different sentence: what is it really (normalizeIsbn),
// could it be an ISBN at all (isIsbnShape), was the person even trying to type
// one (looksLikeIsbn), and did they get it right (isbnCheckDigitValid).
//
// THE PROXY USES ONLY THE FIRST TWO. The other two are here anyway so that all
// four have one definition the smoke test can exercise directly: app.js has no
// module loader and has to copy them, and the copy of an untested function is
// worse than the copy of a tested one. Every copy is pinned byte-for-byte.

// Everything that is not an ISBN character is noise. Deleting all of it beats
// listing the separators worth allowing, because the list is long and keeps
// growing: the ASCII hyphen, the soft hyphen, the whole U+2010-U+2015 dash
// block a publisher's page uses, non-breaking spaces, the zero-width characters
// a copy-paste drags along, a sentence's trailing period, and the word ISBN
// itself. One character class cannot be got wrong the way six can.
//
// The upper-case is load-bearing. OpenLibrary returns a full record for
// `ISBN:043935806X` and nothing at all for `ISBN:043935806x`, so a lower-case
// x reaching the query would turn a loud error into a silent "no results
// found" — which is the failure this app is worst at explaining.
export function normalizeIsbn(raw) {
  return String(raw || '').replace(/[^0-9Xx]/g, '').toUpperCase();
}

// An ISBN-10 is nine digits and a check character that may be X; an ISBN-13 is
// thirteen digits and is never X. This replaced `/^\d{10,13}$/`, which was
// wrong in both directions. It rejected every X check digit — 9.6% of ISBN-10s,
// measured across 1,233 of them, about one book in eleven — so real books came
// back "Invalid ISBN". And it accepted 11- and 12-digit strings that are not
// ISBNs in any scheme, so a truncated paste was sent to OpenLibrary and
// reported back as a book nobody has.
export function isIsbnShape(isbn) {
  return /^(?:\d{9}[\dX]|\d{13})$/.test(isbn);
}

// Client-side ROUTING only, where the alternative is a film-title search. The
// question is "was this an attempt at an ISBN", not "is this a valid one" — a
// truncated or mistyped number has to reach the path that can say so.
//
// The letter test is what makes it safe now that normalizeIsbn deletes
// everything non-numeric: `Apollo 13 1995 1080p` reduces to ten digits, which
// is a perfectly good ISBN-10 shape, and without this it would be looked up as
// a book. An attempt at an ISBN carries no letters at all beyond the optional
// `ISBN` label and a trailing X check digit. `The Matrix` and `Malcolm X` stay
// film searches because stripping the trailing x still leaves letters behind.
export function looksLikeIsbn(raw) {
  const body = String(raw || '').replace(/^\s*ISBN[\s:-]*/i, '');
  if (/[A-Za-z]/.test(body.replace(/[Xx]\s*$/, ''))) return false;
  return normalizeIsbn(raw).length >= 9;
}

// ISBN-10 is mod 11 over descending weights with X standing for ten; ISBN-13 is
// mod 10 over weights alternating 1 and 3. Deliberately NOT used by the proxy:
// a checksum there would refuse numbers OpenLibrary may hold under a mis-keyed
// record, and the whole point of knowing is to tell the user "you mistyped it"
// rather than "no results found" — which only the client can do, before the
// request goes out at all.
export function isbnCheckDigitValid(isbn) {
  if (/^\d{9}[\dX]$/.test(isbn)) {
    let sum = 0;
    for (let i = 0; i < 9; i++) sum += (10 - i) * Number(isbn[i]);
    sum += isbn[9] === 'X' ? 10 : Number(isbn[9]);
    return sum % 11 === 0;
  }
  if (/^\d{13}$/.test(isbn)) {
    let sum = 0;
    for (let i = 0; i < 13; i++) sum += Number(isbn[i]) * (i % 2 ? 3 : 1);
    return sum % 10 === 0;
  }
  return false;
}

// Every text column on media_items except the keys and added_at. Adding one
// here is most of the work of adding a column: sanitizeItem, rowToItem,
// UPSERT_SQL and bindUpsert all build themselves from this list, so they move
// together or not at all.
//
// `source_id` is where the row came from — the normalised ISBN for a book,
// `tmdb:movie:1234` / `tmdb:tv:1234` for video. It is a FACT about the row's
// origin rather than a field anybody edits, which is why it is not in the add
// form and not bulk-settable; it is here because it round-trips like the rest.
export const ITEM_FIELDS = ['type', 'format', 'title', 'author', 'actors', 'producers', 'genre', 'series', 'location', 'cover', 'notes', 'source_id'];
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
    source_id: row.source_id,
    addedAt: row.added_at,
  };
}

// What counts as "the same item" when no id is available to say so: the title,
// case-folded, and the type. It lives here rather than in migrate.js — where it
// was written — because the duplicate scanner needs the same answer, and two
// definitions of "the same item" that disagreed would let the scanner flag a
// pair the migration had already decided was distinct. migrate.js re-exports it
// so its existing callers are unaffected.
//
// The type half is what keeps the paperback and the audiobook of one title
// apart, which is the commonest honest repeat in this data.
export function mergeKey(item) {
  return String(item.title || '').toLowerCase() + '|' + item.type;
}

// 15 bound parameters now rather than 14, still far under D1's 100.
export const UPSERT_SQL =
  `INSERT INTO media_items (user_email, item_id, type, format, title, author, actors, producers, genre, series, location, cover, notes, source_id, added_at)
   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
   ON CONFLICT (user_email, item_id) DO UPDATE SET
     type = excluded.type, format = excluded.format, title = excluded.title,
     author = excluded.author, actors = excluded.actors, producers = excluded.producers,
     genre = excluded.genre, series = excluded.series, location = excluded.location,
     cover = excluded.cover, notes = excluded.notes, source_id = excluded.source_id,
     added_at = excluded.added_at`;

export function bindUpsert(stmt, email, it) {
  return stmt.bind(
    email, it.id, it.type, it.format, it.title, it.author, it.actors,
    it.producers, it.genre, it.series, it.location, it.cover, it.notes,
    it.source_id, it.addedAt
  );
}

export async function countItems(db, email) {
  const row = await db
    .prepare('SELECT count(*) AS n FROM media_items WHERE user_email = ?')
    .bind(email)
    .first();
  return row ? row.n : 0;
}
