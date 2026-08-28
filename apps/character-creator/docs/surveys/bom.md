# Rifts Book of Magic — survey

Slug `bom`. Cached 2026-08-26 from `526065744-Rifts-Book-of-Magic.pdf`,
360 PDF pages, **scan (no text layer)**, OCR at 300 dpi, psm 3, table pages
re-rendered at 500 dpi.

*Facts about this book, not prose from it — see `book-survey` §7.*

**This is a stub. Six of 360 pages are cached and 409 catalog rows point into
this book.** It is the largest untraceable block in the catalog and nobody has
opened it — see `INGESTION-AUDIT` **F24**. Everything below came out of the
repo, offline; nothing here was read off a page.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1.
`printed_pages: 352`.

**The registry's values are the authority and the manifest's are NULL here on
purpose.** `manifest.json` records `printed_pages: null` and `page_offset: null`
because no folio in the six cached pages survived OCR; the offset in the registry
was read off the source PDF's own sparse text layer instead, 14 pages agreeing.
A manifest derived from a truncated cache reports the truncation, which is why
`books.json` outranks it — see that file's `_doc`.

This book **has** a text layer and was OCR'd anyway. `ocr-book.py` now refuses to
rebuild it as a text-layer book without `--force`, because that would overwrite
the OCR cache the six kept pages live in.

## The book's authority tables

**Not found — nothing has been surveyed.** A spell compendium of this size
almost certainly prints a master list; finding it is step 4 of the runbook and
has not been done.

## Inventory

| section | printed pages | what is there |
|---|---|---|
| **cached** | **89-94** | six pages, `p090-p095`, kept for one extraction |
| everything else | 1-88, 95-352 | **not cached** |

The cache was never built for a survey. It was built to answer one question, and
`cached_range` is `p090-p095` — 6 of the PDF's 360 pages. It is the one partial
cache of the nine.

## Classes

One class cites this book: `stone-master`. Its citation resolves to a page the
cache does not hold, so it reads `outside-cache` in `source-coverage`.

## Catalog diff

**Not run.** It cannot be: a diff needs the book's own list, and 346 of its 352
pages are not here.

What production holds today, by citation:

| citation | rows |
|---|---|
| `Rifts Book of Magic p.71-72` | **231 spells** |
| `Rifts Book of Magic` (no page range) | 177 spells |
| `Rifts Book of Magic` | 1 class (`stone-master`) |

**The 231 are the finding.** Two printed pages cannot hold 231 spell
definitions, so that citation is a bulk stamp rather than a reading — the rows
were given a page range they do not individually come from. It is the single
largest provenance question left in the catalog, and it is `INGESTION-AUDIT`
**F24**.

## Extraction plan

None agreed. What a real survey of this book would have to do first:

1. Cache it properly — `ocr-book.py bom --force`, all 352 printed pages.
2. Find the master spell list and parse it.
3. Establish where each of the 231 `p.71-72` spells actually is, and correct the
   citation per row. This is a re-provenance pass over existing rows, not an
   import.
4. Only then diff for what is genuinely missing.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-26 | — | six pages cached (`p090-p095`) for one extraction; no survey written |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `bom` registered in `books.json` with the offset read off the source PDF |
| 2026-08-28 | — | this file, backfilled offline from the registry, the manifest and `source-coverage --remote` |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  bom                  0 / 409
```

**Zero traceable of 409.** All 409 are `outside-cache` or carry a citation the
six cached pages cannot confirm: 231 spells stamped `p.71-72`, 177 spells with
no page range at all, and one class. Nothing here is traceable until the book is
cached in full.
