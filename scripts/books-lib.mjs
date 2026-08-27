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

/**
 * The strings that are NOT books - `Estimate - no published price found` and
 * `Web reference (not book-verified)`. They record where a value came from,
 * not which book, and they have to be named somewhere: left to the
 * heuristics, the first of them resolved to `pf` for 104 gear rows, because
 * the initialism route reads e-n-p-p-f and finds `pf` inside it.
 */
export function loadNotBooks(file = path.join(here, 'books.json')) {
  try {
    const parsed = JSON.parse(readFileSync(file, 'utf8'));
    return Array.isArray(parsed?.not_books) ? parsed.not_books : [];
  } catch {
    return [];
  }
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

/**
 * Is a book's cache complete enough to be believed?
 *
 * The question a citation check has to answer before it accuses anything. Run
 * against 81 of 382 pages it once accused four gear rows whose page simply had
 * not been cached yet, so the gate that followed compared the file count
 * against `manifest.pages`. That number is `doc.page_count` of whatever PDF was
 * handed over — a property of the FILE, not of the book. A 73-page cache of a
 * 161-page book, built from a truncated PDF, recorded `"pages": 73` and passed:
 * half a book read as all of it.
 *
 * So the comparison is against the book's own last printed folio, plus the
 * offset that turns it into a cache page number.
 *
 * THE REGISTRY WINS over the manifest, and that ordering is the point.
 * `ocr-book.py` derives `printed_pages` by reading the last folio it can SEE,
 * which on a truncated cache is the last folio of the truncation — a 73-page
 * cache derives "72 printed, offset 1, needs 73" and passes itself. A number
 * that comes from the cache cannot judge the cache. scripts/books.json is a
 * human statement about the BOOK, so it is the authority whenever it has one.
 *
 * `cachedPages` is the count of pages on disk NOW, not `manifest.cached_pages`
 * — the manifest is a snapshot and the directory is the fact. Comparing a
 * count against a page number is exact for a gapless cache starting at p001,
 * and conservative for a gappy one (`bom` holds p090-p095: six files, last
 * number 95). It can only under-claim completeness, which is the safe
 * direction for a gate whose failure mode is believing half a book.
 *
 * Returns { cached, needed, complete, basis, printedFrom, offsetFrom }.
 * `complete` is false when nothing can be established — unknown is not
 * complete.
 */
export function cacheCoverage({ cachedPages, manifest, registryEntry }) {
  const pick = (field) => {
    const r = registryEntry?.[field];
    if (Number.isInteger(r)) return { value: r, from: 'scripts/books.json' };
    const m = manifest?.[field];
    if (Number.isInteger(m)) return { value: m, from: 'the manifest' };
    return { value: null, from: null };
  };
  const cached = Number.isInteger(cachedPages) ? cachedPages : null;
  const printed = pick('printed_pages');
  const offset = pick('page_offset');

  if (printed.value === null || offset.value === null) {
    // Neither source knows the book's own length. Fall back to the old, weaker
    // test rather than to nothing — it catches `bom` correctly and is only
    // blind to the truncated-PDF case, which is what the fields above fix.
    const needed = Number.isInteger(manifest?.pages) ? manifest.pages : null;
    return {
      cached, needed, printedFrom: null, offsetFrom: null,
      basis: 'the PDF page count, which is a property of the file not the book',
      complete: cached !== null && needed !== null && cached >= needed,
    };
  }

  const needed = printed.value + offset.value;
  return {
    cached, needed, printedFrom: printed.from, offsetFrom: offset.from,
    basis: `printed ${printed.value} + offset ${offset.value}`,
    complete: cached !== null && cached >= needed,
  };
}
