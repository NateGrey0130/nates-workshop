# Rifts Conversion Book Two: Pantheons of the Megaverse — survey

**Status:** `imported` — finished in #268, before surveys existed; this file was written afterwards. (2026-09-24)

**Rows citing this book:** classes 14, vehicles 2, skills 4, notable_npcs 140, creatures 6

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
| 2026-09-18 | [#1167](https://github.com/NateGrey0130/nates-workshop/pull/1167) | **notable NPCs - the gods** (NPC and bestiary plan, Phase 2b): `add-notable-npcs-pantheons.sql`, 140 `notable_npcs` rows citing this book. Row added 2026-09-27; the PR did not write one. |
| 2026-09-25 | [#1374](https://github.com/NateGrey0130/nates-workshop/pull/1374) | the four languages cited to their pages: `fix-potm-language-citations.sql` |
| 2026-09-26 | #1444 | `norse-giant` copies the dragon ladder, by `~011-borrowed-xp-ladders.sql`: printed 163 says *"Experience: Use same table as the Dragon R.C.C."*, and `dragon-hatchling` has stored RUE's dragon ladder since #1415. The import stored none because both rows then fell through to the app default. Nate's rule, 2026-09-26: a class whose book names another class's table copies that ladder. The note is rewritten as the decision. No row count moves. `--remote` is applied before the merge. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **Six minion species as creatures** (`~076`: Galla, the Hundred-Handed, the Furies, Asurkan, Kravyads, the Average Evil Immortal) **and two machines as vessels** (`~084`: the Atlas Mark I and the Ahriman Mark I Rune Assault Suit). The first creature and vehicle rows this book has. Odin's ravens are a unique pair with one stat block, not a species, and were left for a notable-NPC filing. Read off renders and checked again by `book-reconcile`; applied `--remote` before the merge. |

### What remains

**Nothing.** `node scripts/source-coverage.mjs --remote`, 2026-09-25, after
`fix-potm-language-citations.sql` was applied:

```
  potm               158 / 0
```

The 4 that were not traceable were the languages two class imports created
with `source_book` set to the bare alias `pantheons-of-the-megaverse`, which
named the book and no page. The book gives none of them an entry of its own:
each is named in the "Skills of Note" of the class that needed it, and that page
is now the citation - `Language: Troll/Giant` and `Language: Ancient Greek`
from the Greater Cyclops (printed 92), `Language: Dwarven` and
`Language: Old Norse` from the Asgardian Dwarf (printed 166).

It stood at 14 / 4 on 2026-08-28; the 140 notable NPCs added since are all
traceable.
