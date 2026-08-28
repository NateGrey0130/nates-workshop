# Rifts Conversion Book Two: Pantheons of the Megaverse — survey

Slug `potm`. Cached from `Pantheons of the Megaverse.pdf`, 210 PDF pages,
**text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28.** The import predates `book-survey` §7. A
partial survey of this book does exist outside the repo — it is the source of
the "no new skills, spells or psionics" finding below — and what could be
recovered from the repo and from `git log` is written here.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1.
`printed_pages: 208`; content ends at printed 203 and the index runs to 208.

`cached_range` is `p001-p210` — **all 210 PDF pages**. The cache held 202 until
the `F2` resume fix read the remaining 8 off the source PDF and topped it up.
The 202 figure appears in older audit text and is stale.

The PDF went missing for a period and returned; it was re-cached and F12/F18
re-verified against the page in
[#303](https://github.com/NateGrey0130/nates-workshop/pull/303).

## The book's authority tables

**Not recorded** as a page number. The book is organised by pantheon, and the
imports were cut that way — a Norse block, then the remainder.

## Inventory

| section | printed pages | what is there |
|---|---|---|
| Rifts Priest O.C.C. | — | the one O.C.C. in the book |
| Norse pantheon | — | 6 classes |
| remaining pantheons | — | 5 classes |
| Godling / Demigod | — | 2 R.C.C.s, imported earlier and later corrected against the book |
| index | 204-208 | no mechanics |

Printed page ranges per section were not recorded at import time.

### This book defines ZERO new skills, spells or psionic powers

Checked deliberately, because "no new" reads like a gap. It is a fact about the
book: its classes draw on the Rifts core lists. The four `skills` rows citing
`pantheons-of-the-megaverse` are catalog rows the classes *use*, not new
definitions, and they carry no page range — which is why they read as `other`
below.

## Classes

14 classes trace to this book: the Rifts Priest, six Norse, five more, and the
Godling and Demigod.

The **Godling and Demigod were published before the book was on hand** and
guessed from the web; they were later corrected against the page
(`4c33352`). That is the pattern this whole pipeline exists to end, and it is
worth keeping in front of the next session.

## Catalog diff

**Not recorded.** The four skills above were not diffed with
`catalog-diff.mjs`; that script postdates this import.

## Extraction plan

Complete — the book was finished in
[#268](https://github.com/NateGrey0130/nates-workshop/pull/268).

## Ledger

| date | PR | what went in |
|---|---|---|
| — | [#264](https://github.com/NateGrey0130/nates-workshop/pull/264) | the Rifts Priest, the one O.C.C. in the book |
| — | [#266](https://github.com/NateGrey0130/nates-workshop/pull/266) | the six Norse classes |
| — | [#268](https://github.com/NateGrey0130/nates-workshop/pull/268) | the last five classes — **the book is finished** |
| — | [#303](https://github.com/NateGrey0130/nates-workshop/pull/303) | the PDF returned: re-cached, F12/F18 re-verified against the page |
| 2026-08-28 | — | this file, backfilled offline |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  potm                14 / 4
```

**14 traceable, 4 not.** The 4 are the skills citing `pantheons-of-the-megaverse`
with **no page range** — the alias resolves to this book, so they are attributed
correctly, but nothing says where in it they came from. Giving them a page range
is the whole of what is left here.
