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

/**
 * ── the VALUES pass (BOOK-INGEST-AUDIT.md F1) ───────────────────────────────
 *
 * `bucketFor` above answers *is the cited page one this machine holds*. This
 * answers the next question — *is this number printed on that page* — for the
 * numeric columns nothing else touches.
 *
 * ADVISORY, AND IT HAS TO BE. The throwaway script that verified the ju gear
 * called 3 of 42 rows missing and all three were prices the book states in
 * WORDS ("3.6 million credits"). A ~7% false-positive rate on a first attempt
 * is why this reports a list and a rate and never an exit code.
 *
 * Three spellings of the same number are tried, and the third is an addition
 * beyond what F1 proposed:
 *
 *   18000    bare
 *   18,000   comma-grouped, as a book prints it
 *   18.000   dot-grouped, which is what THIS repo's OCR produces for the comma
 *            form - `book-survey` records it scoring 93-97, i.e. the scan is
 *            confident about it. Without this a scanned book's prices read as
 *            missing in bulk, which is the false positive the finding is most
 *            worried about.
 *
 * Word forms are NOT attempted. "3.6 million" is a real miss this cannot see
 * past, and inventing a numeral-to-words expansion would trade a visible false
 * positive for an invisible false negative.
 */
export function valueSpellings(value) {
  if (value == null) return [];
  const n = Number(value);
  if (!Number.isFinite(n) || n === 0) return [];
  const bare = String(Math.abs(n) === Math.trunc(Math.abs(n)) ? Math.trunc(n) : n);
  const grouped = bare.replace(/\B(?=(\d{3})+(?!\d))/g, ',');
  const out = new Set([bare]);
  if (grouped !== bare) {
    out.add(grouped);
    out.add(grouped.replace(/,/g, '.'));
  }
  return [...out];
}

/**
 * Is any spelling of `value` present in `text`?
 *
 * Digit-bounded rather than word-bounded: `\b` treats a comma as a boundary, so
 * a bare `18000` would match inside `118,000`.
 *
 * A `.` or `,` is a boundary character ONLY BETWEEN DIGITS. The first version
 * of this excluded them outright, and the page that caught it prints
 * `(A.R. 12,` - the comma is punctuation, the value is right there, and the
 * check called it missing. That single rule accounted for a large share of an
 * apparent 24% miss rate on the first run.
 */
export function valuePresent(value, text) {
  if (!text) return false;
  for (const s of valueSpellings(value)) {
    const re = new RegExp(String.raw`(?<!\d|\d[.,])`
      + s.replace(/[.]/g, String.raw`\.`)
      + String.raw`(?!\d|[.,]\d)`);
    if (re.test(text)) return true;
  }
  return false;
}

/**
 * Roll a list of rows into per-column tested/missed counts.
 *
 * `rows` is [{ label, sourceBook, values: { column: number } }]. `pageText` is
 * (slug, pageNumber) => string | null, supplied by the caller so this stays
 * drivable from a fixture. Only rows `bucketFor` calls `traceable` have a
 * window to test against; everything else is counted as `noWindow` and is a
 * coverage problem rather than a value problem.
 *
 * EVERY MISS IS CLASSIFIED, and this is an addition beyond what F1 proposed.
 * A value not on the cited pages is checked against the page either side, and
 * the answer is `late`, `early` or `absent`. The reason is that the first run
 * of this pass reported 213 missing gear costs and the largest single cause was
 * not a wrong number at all: the NG-101 Rail Gun cites `rue p.273`, its entry
 * runs onto 274, and its Black Market Cost is printed there. A one-page
 * citation on a two-page entry is a fixable defect in the CITATION; a value the
 * book does not print anywhere near it is a different problem entirely, and a
 * single "not found" pile hides which one you have.
 *
 * The window is NOT silently widened to compensate. Widening would make the
 * short citation invisible, which is the thing worth seeing. `class-check
 * --field-sources` already reads the next page for the same reason and reports
 * it rather than absorbing it.
 */
export function summariseValues(rows, opts, pageText) {
  const columns = new Map();
  let noWindow = 0;
  for (const r of rows) {
    const b = bucketFor(r.sourceBook, opts);
    if (b.bucket !== 'traceable') { noWindow++; continue; }
    let text = '';
    for (let p = b.window[0]; p <= b.window[1]; p++) text += (pageText(b.slug, p) ?? '') + '\n';
    const after = pageText(b.slug, b.window[1] + 1);
    const before = pageText(b.slug, b.window[0] - 1);
    for (const [col, value] of Object.entries(r.values ?? {})) {
      if (!valueSpellings(value).length) continue;
      if (!columns.has(col)) columns.set(col, { tested: 0, misses: [] });
      const c = columns.get(col);
      c.tested++;
      if (valuePresent(value, text)) continue;
      const where = valuePresent(value, after) ? 'late'
        : valuePresent(value, before) ? 'early'
          : 'absent';
      c.misses.push({ label: r.label, value, slug: b.slug, window: b.window, where });
    }
  }
  let tested = 0;
  let missed = 0;
  const byWhere = { late: 0, early: 0, absent: 0 };
  for (const c of columns.values()) {
    tested += c.tested;
    missed += c.misses.length;
    for (const m of c.misses) byWhere[m.where]++;
  }
  return { columns, tested, missed, byWhere, noWindow };
}
