# Rifts Conversion Book One — survey

Slug `cb1`. Cached from
`595586607-Rifts-Conversion-Book-1-Revised-and-Updated-PAL803P.pdf`,
200 PDF pages, **text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28.** One row traces to this book. It was cached
and registered but never surveyed.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1.
`printed_pages: 172`, `cached_range` `p001-p200`, all 200 cached.

**The PDF has 200 pages and the book has 172.** The tail is a Palladium
catalogue and order form the book does not number, so the last folio is 172 and
`printed_pages` says 172 rather than 200. `dag` has the same appended catalogue.

## The book's authority tables

**Not found — the book has not been surveyed.**

## Inventory

**Not counted.**

## Classes

One class traces to this book. The Warlock was closed against it as class-audit
item **CB1** in [#304](https://github.com/NateGrey0130/nates-workshop/pull/304).

## Catalog diff

**Not run.**

## Extraction plan

None agreed. A conversion book is mostly rules for moving characters between
systems rather than new classes, so an inventory pass (step 3) should come
before any assumption that there is a lot here.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | cached, 200 pages |
| — | [#304](https://github.com/NateGrey0130/nates-workshop/pull/304) | the Warlock closed against this book (class audit CB1) |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `cb1` registered in `books.json` |
| 2026-08-28 | — | this file, backfilled offline |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  cb1                  1 / 0
```

**1 traceable, nothing untraceable.** Everything this book has ever been asked
for resolves. Whether there is more in it to take is an open question nobody has
asked.
