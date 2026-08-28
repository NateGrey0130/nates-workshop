# Rifts Ultimate Edition — survey

Slug `rue`. Cached from `Rifts - Ultimate Edition.pdf`, 382 PDF pages,
**scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28.** Like `pf`, this book's rows accumulated
across the project rather than in one book-shaped import, so there is no ledger
to recover. It is the second-most-cited book here and the one with the largest
untraceable tail.

## Page offset

`page_offset: 3` from `scripts/books.json` — cache file page = printed folio + 3,
so printed folio F is `p<F+3>.txt`. `printed_pages: 374`, `cached_range`
`p001-p382`, all 382 cached. Constant across the book; no exceptions recorded.

## The book's authority tables

**Not recorded** as page numbers. One reconciliation finding from this book is
worth carrying: four RUE spells parsed to a level that contradicted expectation,
every one was checked against its description section, and **the book agreed
with itself both times** — the expectations came from a different edition. A
failed probe is a question, not a verdict.

## Inventory

**Not counted.** Never surveyed as a book. Six dragon hatchling species were
imported from it (`5c66a60`); the hand-cut PDF slices that import used —
`142-159`, `264-277`, `329-332`, `347-356` — are debris in `Downloads` now, not
a record, and `INGESTION-AUDIT` F11 is closed as moot.

## Classes

Multiple published classes cite this book, including the six dragon hatchling
species. One class citing `rifts-core` — `dragon-hatchling` — reads `not-cached`
because that book has never been cached; it is not a `rue` problem.

## Catalog diff

**Not run.**

## Extraction plan

None agreed. If this book is opened properly, the 327 untraceable rows below are
the work, and they are a re-provenance pass over existing rows rather than an
import: the cache is complete, so every one of them could be given a page range
from the pages already here.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | rows accumulated across the project; no book-shaped import run |
| — | `5c66a60` | RUE's six dragon hatchling species |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `rue` registered in `books.json` |
| 2026-08-28 | — | this file, backfilled offline |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  rue                346 / 327
```

**346 traceable, 327 not** — the largest untraceable block after `bom`, and a
different problem from `bom`'s. Nothing here is `outside-cache`: all 382 pages
are cached, so the 327 are rows carrying **no page range at all**. They can be
traced without reading anything new.
