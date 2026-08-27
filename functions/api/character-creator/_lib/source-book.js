// Composing the `source_book` value a confirmed import writes.
//
// The session importers have always known which pages a row came from — the
// operator types a page range per extraction and it is persisted on
// `import_staged.page_range` — and then dropped it one function call short of
// the column it belongs in, because `applyDecisions` took the book once for
// the whole batch. Every row imported that way is a row `class-check
// --field-sources` and `scripts/source-coverage.mjs` can never trace back to a
// page.
//
// Two things have to happen at the moment the value is first written, and
// nowhere else is cheap:
//
//   the BOOK   resolved through scripts/books.json rather than taken verbatim,
//              so a session labelled with a sixth spelling of a book the
//              registry already knows does not mint rows in it. The session's
//              own string is a free-text `prompt()` in import.js; the registry
//              is the vocabulary every reader downstream shares.
//
//   the PAGES  normalised to the `p.N-M` shape `parseSourcePages` reads. The
//              staged page range is a LABEL, not a range — import.js prompts
//              for it with the placeholder `pp. 180-181` — so appending it raw
//              produces `... p.pp. 180-181`, which nothing downstream can
//              parse. A value that looks traceable and is not is worse than a
//              bare title, because the bare title at least reports itself as
//              missing.
//
// Pure string work, no I/O: the smoke test pins it directly.

import BOOKS from '../../../../scripts/books.json' with { type: 'json' };
// The same resolver `class-check`, `drift-check` and `source-coverage` use.
// Re-implementing the normalisation here is how one vocabulary becomes two:
// these are pure functions over strings with no Node dependency, so esbuild
// bundles them into the Worker the same as anything else.
import { isNotABook, registryBookSlug } from '../../../../scripts/class-check-lib.mjs';

// The printed pages out of a free-text page-range LABEL.
//
// Deliberately more permissive than `parseSourcePages`, which requires the
// canonical `p.N` and correctly refuses `pp. 180-181` — that regex is reading
// values this repo wrote, and this one is reading what a human typed into a
// text box. A range anywhere in the string wins over a lone number, so
// "Ch. 3, pages 180-181" reads as 180-181 rather than as page 3.
//
// Nothing numeric means no page range, not a guess. A label like "spell
// chapter" composes to the book alone.
function parsePageLabel(label) {
  const s = String(label ?? '');
  const range = s.match(/(\d+)\s*[-–—]\s*(\d+)/);
  if (range) {
    const a = Number(range[1]);
    const b = Number(range[2]);
    return a <= b ? { first: a, last: b } : { first: b, last: a };
  }
  const one = s.match(/\d+/);
  if (!one) return null;
  const n = Number(one[0]);
  return { first: n, last: n };
}

/**
 * The `source_book` one confirmed row should carry.
 *
 * `sessionBook` is `import_sessions.source_book`, `pageLabel` is that row's
 * `import_staged.page_range`. Returns null when the session carries no book
 * label at all — there is nothing to attribute the pages to, and a bare page
 * range is not a provenance. `buildUpdate` COALESCEs on that null, so a
 * re-import out of an unlabelled session leaves whatever the row already has.
 *
 * A `not_books` marker (`Estimate - no published price found`) is returned
 * verbatim: it says where a value came from instead of a book, and composing
 * pages onto it would claim a printing that does not exist.
 */
export function composeSourceBook(sessionBook, pageLabel) {
  const raw = typeof sessionBook === 'string' ? sessionBook.trim() : '';
  if (!raw) return null;
  if (isNotABook(raw, BOOKS.not_books)) return raw;

  const slug = registryBookSlug(raw, BOOKS.books);
  // The registry title carries no page range; the session's own string might,
  // if the operator labelled the whole session with one. Strip it either way
  // so the range below is appended once rather than twice.
  const title = slug
    ? BOOKS.books[slug].title
    : raw.replace(/\bpp?\.?\s*\d+(?:\s*[-–—]\s*\d+)?/i, '').replace(/[\s,;:]+$/, '').trim();
  if (!title) return raw;

  // Per staged row first, because one session covers many page ranges. A
  // session labelled "Rifts Ultimate Edition p.180-190" and a range-less row
  // still lands on the session's own pages rather than losing them.
  const pages = parsePageLabel(pageLabel) ?? parsePageLabel(raw);
  if (!pages) return title;
  return pages.first === pages.last
    ? `${title} p.${pages.first}`
    : `${title} p.${pages.first}-${pages.last}`;
}
