// /api/marvel-heroes/book-text?book=ma1&entry=nightcrawler - the book's own
// text for one sourcebook entry, from msh_book_text: every power's
// description, its talents, contacts and "Running" notes, its members' and
// cross-references' text, in the order the book prints them.
//
// GET only: this route reads a table that nothing on the site writes. Pages
// answers any other method with a 405 because onRequestGet is the only handler.
//
// The table is EMPTY on any database built from the repo - its rows come from
// a gitignored parse of the book (migration 087) - so an entry with no rows is
// a normal answer, not an error: 404 with `missing: true`, and the codex shows
// the committed facts (apps/marvel-heroes/data/npcs.json) without the prose.
//
// Signed-in users only. The site is behind Access; this is the second check,
// because the text is TSR's and the endpoint is the only way to read it.

import { getAccessEmail } from '../_lib/access.js';

// A registry slug (scripts/msh/books.json) and an entry id as npcs.json writes
// them: lower-case words joined by hyphens, a cross-reference ending -p<page>.
export const BOOK = /^[a-z][a-z0-9]{0,15}$/;
export const ENTRY = /^[a-z0-9]+(?:-[a-z0-9]+){0,12}$/;

// The book's order within an entry. An item's, a location's and an
// adventure section's rows are every one numbered in print order
// (scripts/msh/extras.py), so the number is the order. A character's are not:
// its powers as printed, then the sections in the order they follow the
// powers, then members and cross-references.
const PART_ORDER = ['powers-intro', 'power', 'talents', 'contacts', 'background', 'notes', 'running', 'prose', 'member', 'appearance'];

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', 'Cache-Control': 'private, max-age=3600' },
  });
}

function orderRows(rows) {
  const n = (k) => Number(k.split(':')[3] || 0);
  if (rows.every((r) => n(r.key) > 0)) return [...rows].sort((a, b) => n(a.key) - n(b.key));
  return [...rows].sort((a, b) => PART_ORDER.indexOf(a.part) - PART_ORDER.indexOf(b.part) || n(a.key) - n(b.key));
}

export async function onRequestGet({ request, env }) {
  const url = new URL(request.url);
  const local = url.hostname === 'localhost' || url.hostname === '127.0.0.1';
  if (!getAccessEmail(request) && !local) return json({ error: 'not signed in' }, 401);

  const book = url.searchParams.get('book') || '';
  const entry = url.searchParams.get('entry') || '';
  if (!BOOK.test(book) || !ENTRY.test(entry)) return json({ error: 'not a book and entry' }, 400);

  const { results } = await env.DB_MARVEL.prepare(
    'SELECT key, part, name, page, body FROM msh_book_text WHERE book = ? AND entry = ?',
  ).bind(book, entry).all();
  if (!results || !results.length) return json({ book, entry, missing: true }, 404);
  return json({ book, entry, parts: orderRows(results) });
}
