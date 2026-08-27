// Can a row still be traced back to the page it came from?
//
// `class-check --field-sources` can trace a class IF you run it, IF its
// `source_book` resolves, and IF its page window is in the cache. Nothing asked
// that question across the corpus, so nobody knew the answer - and it is
// exactly the kind of answer that quietly stops being yes as books are cached
// partially, re-sliced, or cited under a new spelling.
//
// The pure half: text and numbers in, a bucket out. The CLI does the D1 query
// and the directory listing, so the smoke test can drive this against a
// fixture rather than against whatever caches happen to be on the machine.
import {
  isNotABook, offsetForPrintedPage, parseSourcePages, registryBookSlug, resolveBookSlug,
} from './class-check-lib.mjs';

/**
 * Seven buckets, one action each. The audit asked for four; two of them split
 * and one is new, because the actions differ:
 *
 *   traceable       the window is in the cache. Nothing to do.
 *   no-source-book  the row cites nothing at all.
 *   no-page-range   a book, but no ` p.N-M`. Nothing can locate it in one.
 *   unknown-book    a spelling scripts/books.json has never seen (F1 warns
 *                   about these on the way in; these are the ones already in).
 *   not-cached      the registry KNOWS the book and this machine has no cache.
 *                   `dragon-hatchling` is the live case, and the fix is one
 *                   ocr-book.py run, not an edit to any row.
 *   outside-cache   the cache exists and does not hold those pages.
 *                   `stone-master` cites Book of Magic p.223-228 and that
 *                   cache holds six pages.
 *   not-a-book      the row records where a value came from rather than which
 *                   book -- `Estimate - no published price found`. Not a gap.
 *
 * Lumping not-cached and outside-cache together would hide that one is fixed by
 * caching a book and the other by finishing one, and lumping not-a-book in
 * with them would report 133 gaps that are not gaps.
 */
export const BUCKETS = [
  'traceable', 'not-a-book', 'no-source-book', 'no-page-range', 'unknown-book',
  'not-cached', 'outside-cache',
];

/**
 * Which bucket one `source_book` string falls in.
 *
 * `caches` is { slug: Set<number> } — the pNNN.txt page numbers each cache
 * actually holds. `registry` is the books.json `books` map. `manifests` is
 * { slug: manifest } for the page_offset fallback, and may be empty.
 *
 * The offset comes from the same places `class-check --field-sources` takes it
 * from, in the same order (registry per printed page, then the manifest), minus
 * live detection: this walks thousands of rows and re-voting every book's
 * folios per row would cost minutes to reproduce a number the registry already
 * holds. A book with no recorded offset is reported as such rather than
 * silently traced at zero.
 */
export function bucketFor(sourceBook, { registry, caches, manifests = {}, notBooks = [] }) {
  const cachedBooks = Object.keys(caches).map((slug) => ({
    slug, sourcePdf: registry[slug]?.source_pdf ?? null,
  }));

  if (sourceBook == null || String(sourceBook).trim() === '') {
    return { bucket: 'no-source-book', slug: null };
  }
  if (isNotABook(sourceBook, notBooks)) return { bucket: 'not-a-book', slug: null };

  const slug = resolveBookSlug(sourceBook, cachedBooks, registry, notBooks);
  if (!slug) {
    const known = registryBookSlug(sourceBook, registry);
    return known
      ? { bucket: 'not-cached', slug: known }
      : { bucket: 'unknown-book', slug: null };
  }

  const range = parseSourcePages(sourceBook);
  if (!range) return { bucket: 'no-page-range', slug };

  const recorded = offsetForPrintedPage(range.first, registry[slug]);
  const offset = recorded?.offset
    ?? (Number.isInteger(manifests[slug]?.page_offset) ? manifests[slug].page_offset : null);
  if (offset === null) {
    return { bucket: 'outside-cache', slug, range, reason: 'no page_offset recorded' };
  }

  const want = [];
  for (let p = range.first + offset; p <= range.last + offset; p++) want.push(p);
  const have = want.filter((p) => caches[slug].has(p));
  if (have.length === want.length) {
    return { bucket: 'traceable', slug, range, offset, window: [want[0], want[want.length - 1]] };
  }
  return {
    bucket: 'outside-cache', slug, range, offset,
    window: [want[0], want[want.length - 1]],
    reason: have.length ? `${have.length} of ${want.length} pages cached` : 'no page of it cached',
  };
}

/**
 * Roll a list of { label, sourceBook } into counts and offender lists.
 *
 * Offenders are capped per bucket by the caller printing them, not here — the
 * whole list is the useful artefact when a book turns out to be missing and
 * forty rows cite it.
 */
export function summarise(rows, opts) {
  const counts = Object.fromEntries(BUCKETS.map((b) => [b, 0]));
  const offenders = Object.fromEntries(BUCKETS.map((b) => [b, []]));
  const byBook = new Map();
  for (const row of rows) {
    const r = bucketFor(row.sourceBook, opts);
    counts[r.bucket]++;
    if (r.bucket !== 'traceable') {
      offenders[r.bucket].push({ ...row, ...r });
    }
    const key = r.slug ?? '(unresolved)';
    if (!byBook.has(key)) byBook.set(key, Object.fromEntries(BUCKETS.map((b) => [b, 0])));
    byBook.get(key)[r.bucket]++;
  }
  return { total: rows.length, counts, offenders, byBook };
}
