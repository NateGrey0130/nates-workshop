# Rifts World Book 10: Juicer Uprising — survey

**Status:** `imported` — imported to completion before surveys existed; this file was written afterwards. (2026-09-24)

**Rows citing this book:** classes 14, gear 42, vehicles 7, skills 5, notable_npcs 9, creatures 5

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

14 classes cite this book (the Rows line above is the count a clean build gives; this sentence said 15 until 2026-10-04). The five Juicer variants from printed 30-41 are
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

Complete for the book's own content. The seven vehicles of printed 77-88 were 
re-read into `vehicles` on 2026-09-09 under `BOOK-INGEST-AUDIT` F41 — they had 
been imported as `gear` rows in PR #283, before migration 048 gave vessels 
three tables of their own. The Experience Tables of printed 156 were the last
piece of the book's own content not stored: every class ran on the app's
default ladder until 2026-09-26, when `~008-rue-ju-xp-ladders.sql` gave each
its printed column. The Murder-Wraith stores none, because the page lists it
as an NPC Villain with no column and its experience is frozen at death.

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
| 2026-09-09 | #857 | the seven vessels of printed 77-88 re-read from the book into `vehicles` (43 M.D.C. locations, 21 weapon systems); the seven `gear` rows STAY and now point at them. `BOOK-INGEST-AUDIT` F41, taken for this book. Read from the PDF with `read-columns.py`, **not** from this book's OCR cache — `book-survey` section 0b names `ju`'s cache as one built by throwaway code, and it is welded across the gutter. |
| 2026-09-18 | #1164 | **notable NPCs** (NPC and bestiary plan, Phase 2a): `add-notable-npcs.sql`, 2 `notable_npcs` rows citing this book. Row added 2026-09-27; the PR did not write one. |
| 2026-09-19 | #1180 | **creatures** (Phase 3): `add-creatures-juicer-uprising-and-triax.sql`, 4 `creatures` rows citing this book. Row added 2026-09-27. |
| 2026-09-19 | #1183 | **notable NPCs**: `add-notable-npcs-juicer-uprising-and-others.sql`, 7 `notable_npcs` rows citing this book. Row added 2026-09-27. |
| 2026-09-26 | #1439 | `~008-rue-ju-xp-ladders.sql`: the Experience Tables of printed 156 as `xp_table` on 13 of the 14 classes, each read off a 200 dpi render and reconciled against it - Standard & Gladiator (Gladiator), Juicer Scout, Titan/Hyperion/Delphi/Phaeton, Psycho-Stalker & Juicer Assassin, Mega-Juicer & Maxi-Killer, Dragon Juicer, and Juicer Wannabe & Gambler. The Murder-Wraith has no column and stores none. Two printed lower bounds that repeat the previous band's upper bound are stored plus one (Dragon Juicer level 11, Wannabe level 5). Applied `--remote` before the merge. |
| 2026-09-26 | #1444 | The two other names in printed 156's columns, settled. **Coalition Juicer** (in the Psycho-Stalker & Juicer Assassin column): `coalition-juicer` cites Coalition War Campaign, the later book, whose printed 224 prints it a different ladder (*CS Juicer, CS Commando, CS Strike Cyborg*); `~010-own-book-xp-ladders.sql` stores CWC's, and the class note records this column. **Vallax (alien) and Newcomer Android**: no class of either name exists in the catalog, so there is nothing to store. `--remote` is applied before the merge. |
| 2026-09-27 | `pal/data/rebuild-audit-f16-f25-f26` | **`Juicer Technology` cites this book**, by `~040-rifts-skill-list-recitations.sql` (REBUILD-AUDIT F16): it moves from the non-book `Rifts Skill List` to `Rifts World Book 10: Juicer Uprising p.65`, where *Medical: Juicer Technology* prints 40%+5%, as the row stores. RUE prints no entry for it. Skills citing this book 4 -> **5**. `--remote` is applied before the merge. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **Newcomer Androids as a creature** (`~081`), printed 152-153. The book says 3,000 androids in one place and 4,000 in another; the row uses the later, fuller count. Read off renders and checked again by `book-reconcile`; applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-a14-stale-notes` | **Stale "no catalog row" sentences corrected** (`~124`, `~125`), the last sweep of the close-out: 2 classes of this book (`mega-juicer`, `titan-juicer`) said the catalog lacked an item, skill, spell, class or vehicle that it now holds. Each sentence was checked against production and now names the row; nothing a class grants changes. Applied `--remote` before the merge. |

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

**Re-measured 2026-09-27**, after the vessels (#857), creatures and notable
NPCs above: `ju                  80 / 0` - still nothing untraceable.
