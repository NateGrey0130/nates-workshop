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
| 2026-08-28 | [#376](https://github.com/NateGrey0130/nates-workshop/pull/376) | `fix-pf-citations.sql` — **39 of 42** rows cited by page: 28 spells, 6 skills, 5 armor. Three spellings of the book's name normalised to the canonical title. 3 held back. Applied `--remote` before the PR. **`pf` is 583 / 3.** |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  pf                 544 / 42
```

**544 traceable, 42 not** — the best ratio of any large book here. The 42 are
rows with no page range, not rows pointing outside the cache: the whole book is
cached, so anything with a folio resolves.

### After the repair, 2026-08-28

```
  pf                 583 / 3
```

**Catalog-wide, `spells` with no page range went to ZERO** in the same run:
every spell in this database that names a book now names a page.

## The 42, and how each kind was located

**The book's name was written three ways**, and all three were in these rows:
`Palladium Fantasy RPG Main Book`, `palladium-fantasy-core` and
`Palladium Fantasy RPG 2nd Ed.` All three are registered aliases so all three
resolved, but two of them are **a slug and an edition name sitting in a title
column**. Every row the repair touched was rewritten to the canonical title, so
it normalised the vocabulary as well as adding the page.

### Spells — the book's own two tables, already parsed

`scripts/parse-pf-spell-index.mjs` existed for this and needed no changes. It
reads both tables — the alphabetical list **by level** at printed 187 and the
one **by page** at printed 188 — and reconciles them: 182 entries, and it
reports on its own that the two tables **disagree on exactly two costs**
(`See the Invisible`, `Curse: Phobia`) and that `Swords to Snakes` is in the
level table only.

All 28 catalog rows matched a by-page entry whose **level agreed with the
catalog's own level column**, and all 28 were then read on the page named.
`The Finger of Lictalon` is the only name the book spells differently — it
keeps the article the catalog drops.

**The offset exception did not bite, and it was still used.** Every page here
was resolved through `offsetForPrintedPage`, not by adding `page_offset`.
Nothing in this repair is below printed 50, so +2 applied throughout — but a
verifier that hard-codes +2 is wrong for this book and would have said so
nowhere.

### Skills and gear

Skills are **paragraph entries** here — `History: This is a basic historical
knowledge…` — so they are matched by the line's prefix, never by a heading.
Six were read on their pages: History 58, Horsemanship: Knight and Palladin 53,
Sign Language 50, Recognize Magic 107 (the book prints `Recognize magic`),
W.P. Targeting 84.

Gear is the **`Types of Armor` table at printed 270**, which prints its rows as
`Soft Leather (full)`, `Chain Mail (full)`, `Scale (full)`. Five of the six
armor rows are there; the catalog's `Scale Mail` is the book's `Scale`.

## What this book does not print

Three rows, held back rather than guessed:

- **`W.P. Lance`** — appears only as a mention at printed 85, *"the equivalent
  of W.P. Lance"*, never as an entry of its own.
- **`Language: Native Tongue`** — nowhere in the book.
- **`Small Shield`** — not in the armor table. pf has the **skill**
  `W.P. Shield`, not the item.
