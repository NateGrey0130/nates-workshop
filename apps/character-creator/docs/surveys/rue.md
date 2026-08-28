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

**Recorded 2026-08-28.** This book's authority is its **table of contents,
printed 8 and 9** (cache `p008`, `p009`), and it is unusually good: it gives a
page for every spell level, every psionic category and every skill category.

| printed | table | states |
|---|---|---|
| **8** | contents, first half | psionic categories and all fifteen spell levels |
| **9** | contents, second half | the skill categories |
| 197-198 | compact spell list, by level | name + P.P.E., **no page** |
| 226-228 | *List of Spells in Rifts Book of Magic* | which spells RUE points at another book for |

### The contents and the body agree everywhere they can

Checked entry by entry, and this is what made the re-provenance pass safe:
**all fifteen spell levels, all four psionic categories and all seventeen skill
categories are on the page the contents claims.**

| section | printed |
|---|---|
| spell levels One-Fifteen | 198, 199, 202, 204, 206, 209, 211, 214, 217, 218, 221, 223, 224, 224, 225 |
| Healing / Physical / Sensitive / Super psionics | 164, 166, 171, 177 |
| skill categories, Communication → Wilderness | 304 … 329 |

**The body carries one section the contents omits entirely: `Domestic Skills`
at printed 307.** The OCR of printed 9 drops the line. Five catalog rows sit in
that section, and a band table built from the contents alone would have put
them in Cowboy's.

### The compact spell list is NOT usable as an authority

Printed 197-198 lists every spell by level with its P.P.E. cost. **Its columns
came out of this OCR in scrambled reading order** — `Level Three` is printed
before `Level One`, so a parse that tracks the current level assigns spells to
whichever heading it happened to read last. That is the same corrupting read
`ju`'s cache has, met here in one table rather than a whole book.

It was tried as a second reading, gave five spells a level three pages away
from where the body prints them, and was dropped. **The contents-versus-body
agreement above is the second reading instead**, and it is a better one.

One older reconciliation finding is worth keeping: four RUE spells parsed to a
level that contradicted expectation, every one was checked against its
description section, and **the book agreed with itself both times** — the
expectations came from a different edition. A failed probe is a question, not a
verdict.

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

**Not run, and not the right tool here.** Nothing in this book is an import:
every row it is credited with already shipped. The question is where the
shipped rows came from, which is a provenance audit.

## Extraction plan

**Done, 2026-08-28** — see the ledger. The pass was exactly what the earlier
version of this file predicted: a re-provenance over existing rows, with the
cache already complete, reading nothing new.

### How each kind of row was located

The book formats its three catalogs differently, and each needed its own
matcher:

| catalog | how an entry looks | printed |
|---|---|---|
| spells, psionics | the name on its own line, then `Range:` / `Duration:` / `P.P.E.` / `I.S.P.` | 164-184, 198-225 |
| skills | the name **opening a paragraph**, then a colon or a full stop — `Barter: A skill at bargaining…` | 304-329 |
| gear | the name opening a paragraph, in the equipment sections | 240-273 |

**A skill name is not a heading, and matching one with a regex that splits on
the first punctuation is wrong.** These names carry their own dots and colons —
`W.P. Archery`, `Hand to Hand: Basic`, `Lore: Dimensions` — and a non-greedy
split reads `W.P. Archery. An expertise with bow weapons…` as a skill called
`W.P`. That mistake cost 36 false misses on the first run. Test the line's
PREFIX against the name instead.

**114 of the 115 rue spells are the only occurrence of their name in the whole
description section**, so the level band never had to disambiguate them. The
exception is `Dimensional Portal`, which appears at 198 inside the compact list
and at 225 as its own entry; the band chose 225.

## What this book does not print

Three groups, all found by looking rather than inferred, and all **held back
from the repair** because attributing them means choosing a different book:

**Three spells RUE only MENTIONS.** `Sustain`, `Time Slip` and `Summon and
Control Canines` appear at printed 120 in a class's spell list and are
described nowhere in this book. RUE's own *List of Spells in Rifts Book of
Magic* gives the first two as bom 109 and 114; the bom cache carries all three
as headings with their stat blocks (109, 114 and 131). **These three were
re-cited to the Book of Magic** — the only rows in the repair whose book
changed.

**Three psionic powers that are not in this book at all**: `Float`,
`Lust for Life` and `Cause Insanity`. The last two turn up in `cb1`, `dag` and
`pf`. Choosing between them is not a re-provenance decision.

**Nine skills RUE prints no entry for**, five of them W.P.s at a granularity
this book does not use — RUE prints `W.P. Handguns`, `W.P. Rifles` and
`W.P. Shotgun` where the catalog has `W.P. Automatic Pistol`, `W.P. Revolver`,
`W.P. Bolt Action Rifle`, `W.P. Automatic and Semi-automatic Rifles` and
`W.P. Heavy M.D. Weapons`. Also `M.D. in Cybernetics` (RUE prints
`Cybernetic Medicine`), `Helicopter`, `Robot Combat: Basic` (RUE describes
basic piloting only inside `Robot Combat: Elite`) and `Lore: Dimensions`.

**Eleven gear rows** under names RUE does not print, mostly Northern Gun
weapons and Dog Pack items.

### And two rows the catalog files under the wrong section

Not repaired here, because the citation is right either way and the category is
a separate question. `Creative Writing` and `Sensory Equipment` are printed
under **Communication Skills** (304 and 305); the catalog files them as
Technical and Pilot Related. `Spontaneous Combustion` is printed at 182 as
sub-ability 2 of **Pyrokinesis**, a Super-psionic; the catalog files it as
Physical.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | rows accumulated across the project; no book-shaped import run |
| — | `5c66a60` | RUE's six dragon hatchling species |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `rue` registered in `books.json` |
| 2026-08-28 | — | this file, backfilled offline |
| 2026-08-28 | [#N](https://github.com/NateGrey0130/nates-workshop/pull/N) | `fix-rue-citations.sql` — **304 of 327** rows cited by page: 118 spells (3 of them re-attributed to the Book of Magic), 79 psionic powers, 84 skills, 23 gear. 23 held back, listed above. Applied `--remote` before the PR. **`rue` is 647 / 23.** |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-08-28:

```
  rue                346 / 327
```

**346 traceable, 327 not** — the largest untraceable block after `bom`, and a
different problem from `bom`'s. Nothing here is `outside-cache`: all 382 pages
are cached, so the 327 are rows carrying **no page range at all**. They can be
traced without reading anything new.

### After the repair, 2026-08-28

```
  rue                647 / 23
```

Catalog-wide the same run moved skills **130 → 214**, psionic powers
**7 → 86**, spells **445 → 563** and gear **800 → 823**.

**The 23 that remain are the ones this book does not print**, listed above.
They are not a page-range problem and will not be fixed by reading RUE again.
