# Rifts World Book 16: Federation of Magic — survey

Slug `fom`. Cached from `Rifts- World Book 16 Federation of Magic.pdf`,
161 PDF pages, **text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28. Nothing has been imported from this book.**
It is cached in full and cited by nothing — the cleanest starting position of
the nine, and the obvious next book after `rifts-core`.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1,
so printed folio F is `p<F+1>.txt`. `printed_pages: 159`, `cached_range`
`p001-p161`.

**The cache holds all 161 pages.** It stopped at file `p073` — printed 72,
mid-word and mid-class — until the `F2` resume fix read the remaining 88 pages
off the source PDF. **The figure 73 appears in older audit text and is stale.**

## The book's authority tables

**Not found — the book has not been opened.** Step 4 of the runbook.

## Inventory

**Not counted.** Step 3 of the runbook.

## Classes

None imported. None known.

## Catalog diff

**Not run.** It would be a clean one: nothing in production cites this book, so
every entry it defines is either new or a rename of something already held. Step
5 of the runbook, and it is free.

## Extraction plan

None agreed. The runbook's steps 0-6 are all free and none has been done for
this book; do them before spending anything on step 7.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | cached (stopped at printed 72) |
| 2026-08-27 | [#338](https://github.com/NateGrey0130/nates-workshop/pull/338) | the resume fix read the remaining 88 pages — the cache now holds all 161 |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `fom` registered in `books.json` |
| 2026-08-28 | — | this file, backfilled offline |

### What remains

`node scripts/source-coverage.mjs --remote` on 2026-08-28 does **not list this
book at all** — a book with zero rows has no line in the BY BOOK table. That is
the correct reading of "nothing has been imported yet", not a missing number.

All of it remains.
