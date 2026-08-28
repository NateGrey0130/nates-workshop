# Rifts World Book 10: Juicer Uprising — survey

Slug `ju`. Cached from `Rifts- World Book 10 Juicer Uprising.pdf`, 162 PDF
pages, **text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28, after the fact.** This book was imported to
completion before `book-survey` §7 existed, so there was no survey to write it
from; everything below was reconstructed from `scripts/books.json`, the cache
manifest, `git log` and `source-coverage --remote`. The inventory, the authority
table and the catalog diff are the sections a real survey would carry and this
one does not — the next session to open this book fills them in.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1,
so printed folio F is `p<F+1>.txt`. `printed_pages: 159`, `cached_range`
`p001-p162`, all 162 cached. The manifest agrees with the registry on both.

## The book's authority tables

**Not recorded.** The import predates §7 and nobody wrote down which page
carries the book's own lists.

## Inventory

Not counted by structure. What shipped, by the page ranges the rows cite:

| printed pages | what came out |
|---|---|
| 30-41 | five Juicer variants |
| 40 | 1 gear row |
| 57 | 1 skill |
| 61-71 | 18 gear rows — drugs, accessories, body armor |
| 64-66 | 4 skills |
| 71-76 | 16 gear rows — weapons |
| 77-88 | 7 gear rows — vehicles |

## Classes

15 classes trace to this book. The five Juicer variants from printed 30-41 are
the block this import was cut for; the rest arrived alongside them.

Two corrections this book produced are worth carrying:

- **`starting_money` was wrong on two classes**, and the error was found by
  reading the *next* page. A figure that falls near a page break can be read off
  the wrong side of it — see the ledger entry for
  [#280](https://github.com/NateGrey0130/nates-workshop/pull/280).
- **The Juicer stopped being human-only** as a result of this book.

## Catalog diff

**Not recorded.** Four skills were found missing and added
([#275](https://github.com/NateGrey0130/nates-workshop/pull/275)); whether any
near-match was hand-checked for a false gap is not written down anywhere.

## Extraction plan

Complete. Nothing outstanding.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | [#275](https://github.com/NateGrey0130/nates-workshop/pull/275) | the four Juicer Uprising skills the catalog was missing; the Juicer stops being human-only |
| — | — | the five new Juicer variants, printed 30-41 |
| — | [#280](https://github.com/NateGrey0130/nates-workshop/pull/280) | two wrong `starting_money` figures corrected, found by reading the next page |
| — | [#281](https://github.com/NateGrey0130/nates-workshop/pull/281) | the drugs, accessories and body armor |
| — | [#282](https://github.com/NateGrey0130/nates-workshop/pull/282) | the sixteen Juicer weapons, printed 71-76 |
| — | [#283](https://github.com/NateGrey0130/nates-workshop/pull/283) | the vehicles — **the book is finished** |
| — | [#284](https://github.com/NateGrey0130/nates-workshop/pull/284) | the classes wired to their gear rows |
| — | [#285](https://github.com/NateGrey0130/nates-workshop/pull/285) | stats for the blank gear rows, and the slug-cased names fixed |
| 2026-08-28 | — | this file, backfilled offline |

Dates are absent because these merged before the ledger existed; the PR numbers
are the durable handle and `git log` carries the dates.

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  ju                  62 / 0
```

**62 traceable, nothing untraceable.** One of two books here that read clean —
`ww` is the other. Every row cites this book with a page range the cache can
confirm.
