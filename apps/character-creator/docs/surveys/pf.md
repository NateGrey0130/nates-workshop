# Palladium Fantasy RPG Main Book — survey

Slug `pf`. Cached from `Palladium RPG - Main Book.pdf`, 339 PDF pages,
**text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28.** This is the most-cited book in the
database and it has no import history to reconstruct — its rows accumulated
across the whole project rather than in one book-shaped run, so there is no
ledger to recover. What the repo *does* know about it is recorded here, and the
offset section is the part worth reading.

## Page offset

**This is the one book whose offset is not constant, and it is the worked
example the skill is thirty lines about.**

From `scripts/books.json`:

- `page_offset: 2` — printed folio F is `p<F+2>.txt`
- `page_offset_exceptions: [{ printed_through: 16, offset: 1 }]` — printed 1-16
  are at **+1**

An extra page sits at cache `p018`/`p019`: `p019` holds `p018`'s text plus a
Throwing Objects table. So printed 1-16 are at +1 and printed 18-336 at +2 —
**11 votes against 287**, which is why a majority vote over the whole book
cannot see the split. Printed 17 is left to the +2 rule on purpose: that lands
on `p019`, the fuller of the two.

`printed_pages: 336`, `cached_range` `p001-p339`, all 339 cached.

**A printed→cache mapping must call `offsetForPrintedPage` per page**, not apply
one number to a range — the rule `INGESTION-AUDIT` F11 left behind when it was
closed as moot. `class-check --field-sources` reports every offset region it
detects, so the next book with a split announces itself.

The worked example in `book-survey` 0d — the Attribute Bonus Chart at printed 16
— is **inside the exception**.

## The book's authority tables

**Not recorded** as page numbers. One property of the book *is* recorded, in
`ww`'s survey by contrast: **Palladium Fantasy prints spell costs twice**, so a
cost here is reconciled between two readings rather than transcribed from one.

## Inventory

**Not counted.** Never surveyed as a book.

## Classes

One published class cites this book by name in a form worth flagging: Wormwood's
Priest of Light collided with the Palladium Fantasy Priest of Light already in
the catalog (`palladium-fantasy-core p.63-67`), and Wormwood's took the id
`wormwood-priest-of-light`. Check ids against production before cutting a branch.

## Catalog diff

**Not run.** 544 rows already trace to this book; a diff would be a re-audit of
what is here rather than a gate on what is coming.

The 312 gear rows spelling this book `Palladium RPG Main Book` are the reason
`books.json` has an `aliases` list at all. Every word of that title is generic,
so the word-overlap route is disabled by design and the initialism route needs a
`pf` the title never spells — before the registry those 312 rows resolved to
nothing.

## Extraction plan

None. This book has no open import.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | rows accumulated across the project; no book-shaped import run |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `pf` registered in `books.json` with four aliases — 312 gear rows start resolving |
| 2026-08-27 | [#340](https://github.com/NateGrey0130/nates-workshop/pull/340) | the `printed_through: 16` exception recorded, per printed page |
| 2026-08-28 | — | this file, backfilled offline |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  pf                 544 / 42
```

**544 traceable, 42 not** — the best ratio of any large book here. The 42 are
rows with no page range, not rows pointing outside the cache: the whole book is
cached, so anything with a folio resolves.
