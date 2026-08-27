// The book registry, read from scripts/books.json.
//
// One file answers "which book does this `source_book` string mean" for the
// three mechanisms that used to answer it separately: resolveBookSlug (a row
// -> its cached pages), drift-check's citation check, and the extraction
// prompt that writes the field. The matching itself lives in
// class-check-lib.mjs, which stays free of file I/O so the smoke test can
// drive it against a fixture; this module is the I/O half.
//
// A registry entry does NOT imply a cache. `triax` and `new-west` have no PDF
// on hand at all, and resolveBookSlug still returns null for them - being
// known vocabulary and being readable are different questions.
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));

/**
 * The `books` map out of scripts/books.json — { slug: { title, aliases, ... } }.
 * Throws with the path in the message: every caller of this is a CLI, and a
 * bare ENOENT for a file the caller never named reads as a bug in the caller.
 */
export function loadBookRegistry(file = path.join(here, 'books.json')) {
  let raw;
  try {
    raw = readFileSync(file, 'utf8');
  } catch (e) {
    throw new Error(`cannot read the book registry at ${file}: ${e.message}`);
  }
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (e) {
    throw new Error(`${file} is not valid JSON: ${e.message}`);
  }
  if (!parsed || typeof parsed.books !== 'object' || parsed.books === null) {
    throw new Error(`${file} has no "books" object`);
  }
  return parsed.books;
}

/** Every canonical title, in registry order. What the extraction prompt offers. */
export function bookTitles(registry) {
  return Object.values(registry).map((b) => b.title);
}

/**
 * Every spelling of one book — its title first, then its aliases. The `IN`
 * list drift-check selects with, and the answer to "what does this book get
 * called in the wild".
 */
export function bookSpellings(registry, slug) {
  const b = registry[slug];
  if (!b) return [];
  return [b.title, ...(b.aliases ?? [])];
}
