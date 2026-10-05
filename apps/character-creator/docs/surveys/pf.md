# Palladium Fantasy RPG Main Book — survey

**Status:** `backfilled` — rows accumulated across the project, not in one import, and no full inventory has been taken. (2026-09-24)

**Rows citing this book:** classes 39, gear 511, enchantments 62, skills 8, skill_system_bases 1, spells 79, psionic_powers 2, creatures 36

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

**Counted by structure on 2026-10-03**, over all 339 cached pages: stat-block
markers per page, and the text layer's own headings read by font size (chapter
titles at 24pt and up, entry headings at 17pt, ward and circle names at
11-13pt). No page was read for its figures.

| printed | what is there | how it compares with production (2026-10-03) |
|---|---|---|
| 49-61 | skill descriptions | not diffed; `skills` holds 8 rows citing this book, the rest by name under other books |
| 63-99 | clergy, men of arms and optional O.C.C.s | held (the classes line above) |
| 104-117 | Wizard, Warlock, Witch, Diabolist | held as classes |
| **120-133** | **Ward magic**: ten symbol kinds on printed 126 (Alarms, Area Affect, Permanence, Power, Protection, Inflict, Trigger, Conditions, Colors, Numbers) and 22 condition wards on 128-132 | **nothing held.** No `spells` or `enchantments` row is a ward; the `diabolist` class note says there is no ward catalog |
| **135-155** | Summoner O.C.C., then **51 circles**: 18 protection circles (138-140), 14 summoning circles (146-148), 19 power circles (149-155) | **nothing held** as rows; the `summoner` class note says there is no circle catalog. Two invocations share a name with a protection circle and are not it |
| 156-161 | four Psychic Character Classes | held as classes |
| 163-179 | psionic powers, 78 entry headings | all 78 match a `psionic_powers` row by name; two cite this book |
| 187-188 | the two spell authority tables (by level, by page) | 182 entries; `catalog-diff.mjs --remote` matches 180, and the other two are near-names (`Swim as a Fish (lesser)`, `Invulnerability`) |
| 189-218 | wizard spell descriptions, levels 1-15 and Spells of Legend | as the index above |
| 221-244 | Air, Earth, Fire and Water elemental magic, about 200 stat blocks | not diffed here; the `warlock` tradition's 231 rows cite the Book of Magic, which reprints these lists |
| 249-253 | magic weapon, armour and charm enchantments | `enchantments` 62 |
| 257-260, 267 | weapons, armour, goods and prices | `gear` (the 511 above, under two spellings of the title) |
| 289-333 | races, creatures and monsters | `creatures` 36, and the race classes |

**A ward is not one row.** The book builds a ward from a sequence of symbols -
a kind, a condition, optionally an area, a trigger and a permanence - so the
32 headings on printed 126-132 are parts, not finished spells. A circle is one
entry with its own P.P.E. cost and power words, the shape a `spells` row in
its own tradition already holds.

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
| 2026-08-28 | [#376](https://github.com/NateGrey0130/nates-workshop/pull/376) | `zzzz-cite-pf-rows.sql` — **39 of 42** rows cited by page: 28 spells, 6 skills, 5 armor. Three spellings of the book's name normalised to the canonical title. 3 held back. Applied `--remote` before the PR. **`pf` is 583 / 3.** |
| 2026-09-18 | #1172 | **creatures** (NPC and bestiary plan, Phase 3): `add-creatures-palladium-fantasy.sql`, 36 `creatures` rows, attacks in `stat_attacks`. Row added 2026-09-27; the PR did not write one. |
| 2026-09-27 | `pal/data/rebuild-audit-f16-f25-f26` | **`Falconry` cites this book**, by `~040-rifts-skill-list-recitations.sql` (REBUILD-AUDIT F16): it moves from the non-book `Rifts Skill List` to `Palladium Fantasy RPG Main Book p.54`, where it prints under Military at 30%+5%, as the row stores (its `systems` carries both `rifts` and `palladium-fantasy`). `Locate Secret Compartments` is **not** moved: printed 57 prints 15%+5% against the stored 20, and the row's note already says so. Skills citing this book 7 -> **8**. `--remote` is applied before the merge. |
| 2026-10-03 | `pal/docs/retro-open-questions` | **Inventory counted by structure**, the first this book has had. No rows. The spell index diffs 180 of 182 against production and all 78 psionic headings match; the ward symbols (printed 126-132) and the 51 circles (138-155) are held nowhere. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **The Summoner's 51 circles as spells** in tradition `circle` (`~091`): 18 protection, 15 summoning, 18 power, by the book's own list on printed 137 (the inventory above counted 14 and 19 from headings). Level 0, each with its printed P.P.E. Nothing grants the tradition yet, and the Summoner's note says so (`~092`). The wards are not rows. Read off renders and checked again by `book-reconcile`; applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a7-wire-classes` | **The Summoner is granted its circles** (`~113`): a `magic` block granting the 18 protection and 15 summoning circles by name, because printed 135 says the Summoner knows all protection and summoning circles and starts with no power circles. The 18 power circles are not granted and no pick offers them; the class learns nothing by level. Its Circle Magic ability and its note no longer say the sheet has no circle list. Not stored: the Deciphering Circles percentage and the circle strength rule. No row count moves. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a13-category-bonuses` | **Related-skill category bonuses that lived only in a note now apply** (`~122`, `~123`): 22 of this book's classes (`assassin`, `druid`, `knight`, `mercenary-fighter`, `merchant`, `mind-mage`, `noble`, `palladin`, `priest-of-darkness`, `psi-healer`, `psi-mystic`, `psychic-sensitive`, `ranger`, `scholar`, `soldier`, `squire`, `summoner`, `thief`, `vagabond-peasant`, `warrior-monk`, `witch`, `wizard`). `categoryBonus` reads an entry's `bonus` key and nothing else, so a bonus written only in the entry's note reached no character. A plain one gains the key; a bonus for part of a category gains a second entry naming those skills (`BOOK-INGEST-AUDIT` F109's shape). Taken from each class's own stored note; no page was reopened. No row count moves. Applied `--remote` before the merge. |

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

**Re-measured 2026-09-27**, after later work cited this book (the creatures of
#1172 among it):

```
  pf                 685 / 1
```

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
