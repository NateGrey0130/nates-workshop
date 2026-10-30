# Survey: MH8 Fault Line (TSR6866)

> **DRAFT.** Measured up to *Which reader fits*, which is not finished: the
> trial parse is the next row's. Nothing here is imported yet.

Marvel Super Heroes adventure module, Kim Eastland, 1985. Registry entry:
`scripts/msh/books.json` -> `mh8`. Measured 2026-10-29.

**Rows citing this book:** none yet (no data has been built).

Everything here was measured and read on the page images.

The eighth module of the MH series, through `scripts/msh/` only. Characters
only (decision 2): the adventure, items and places are not imported.

## The scan

- 22 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-29 into the main
  checkout's `.cache/msh/books/mh8/` (22 pages OCR'd).
- The print is clean and every card's rank rows OCR whole: each of the 16
  blocks reads all seven ranks and its Health from the page text.
- **The scan holds no inside cover.** PDF 1 and 18 are the outside of the
  cover, and the back cover lists the package as the booklet, a city map and
  the fold-up figures. So, unlike MH1-7, no card is on a cover panel: every
  card is in the booklet, on printed 12-16.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 601 x 774 | Cover (outside front) | - |
| 2-17 | 594 x 767 | Adventure Book | 1-16 |
| 18 | 601 x 774 | Back cover (product code 6866XXX1401) | - |
| 19 | 612 x 792 | Instructions for the fold-up figures | - |
| 20 | 612 x 791 | Fold-up figure sheet | - |
| 21 | 1188 x 767 | Daily Bugle newspaper prop, a double-width spread | - |
| 22 | 2335 x 1511 | Map: City Map 3 | - |

**The two letter-size pages** are the module's ADVENTURE FOLD-UP figures:
PDF 19 says how to cut, fold and glue them and how they stand in for the
game's counters, and PDF 20 is the sheet itself. It prints 19 stand-ups:
every card's character but Joseph Merrir, the Police as Policeman Type A and
B, the Crooks as Punk Type A and B and Hood Type A and B, no SWAT member, and
a crowd and a bomb. It prints no statistics.

**The double-width page** (PDF 21) is a front page of the Daily Bugle, a
player handout that printed 3 tells the Judge to give the players. It prints
no statistics. Neither it nor the figures is imported (decision 7).

## Offset

`survey.py` votes **printed = PDF - 1 on 12 pages** (PDF 4-8 and 11-17), and
no page votes otherwise. Folios 2, 8 and 9 were read on crops of PDF 3, 9
and 10 (faint, small, centred at the foot). Printed 1 (PDF 2) is the title
page, which also prints the product code 6866XXX1501. So `parts`, as MH5-7,
with the covers, the figure pages, the newspaper and the map as parts of
their own with `offset` null.

## The book's own authority lists

No Contents and no index. The banners, read on the page images: printed 1 the
title page (HOW TO USE THE SETTING), **SECTION 1: THE ADVENTURE** (printed 2,
INTRODUCTION under it), INITIAL ENCOUNTERS (3), CLUES & INFORMATION (4),
ADVENTURE TIMETABLE (5), **SECTION 2: EVENTS** (6; Events 1-11 over printed
6-8, then The Matter of Karma and The Final Event) and **SECTION 3: LOCATION
DESCRIPTIONS** (9-11). The cards follow on printed 12-16, unbannered. The
coverage checklist is this survey's list, carried as `cards`.

## Stat blocks: 16 blocks under 15 headers

Every block prints seven `Fighting: GOOD` rows in rank words (a label column
and a value column), then `Health:`, `Karma:`, `Resources:`, `Popularity:`
and labelled sections. No rank code and no one-line grid anywhere in the
book. Checked on `apps/marvel-heroes/data/ranks.json` `standard`.

| card | printed | Health | Karma | checks |
|---|---|---|---|---|
| Grim Reaper | 12 | 36 | 18 | yes |
| Thunderball | 12 | 130 | 36 | yes |
| Mastermind | 12 | 44 | 120 | yes |
| Swordsman | 13 | 70 | 18 | yes |
| Living Laser | 13 | 50 | 32 | Karma: ranks give 18 |
| Juggernaut | 13 | 234 | 30 | Karma: ranks give 20 |
| Frankie the Snitch | 14 | 22 | 40 | yes |
| Joseph Merrir | 14 | 60 | 24 | yes |
| Crooks: Punks | 14 | 28 | 1216 | Karma: ranks give 12 |
| Crooks: Hoods | 14 | 50 | (none) | Karma: ranks give 16 |
| Black Knight | 15 | 60 | 22 | yes |
| Spider-Man | 15 | 160 | 110 | yes |
| Captain America | 15 | 140 | 60 | yes |
| Wasp | 16 | 46 | 50 | yes |
| Police | 16 | 36 | - | Health yes; no Karma printed |
| SWAT Team Member | 16 | 50 | - | Health yes; no Karma printed |

**Every Health holds. Three Karma values fail, in three blocks, all read on
the page images** (150 dpi crops of PDF 14 and 15):

- `13:Living Laser:Karma 32->18` (Typical, Typical, Typical)
- `13:Juggernaut:Karma 30->20` (Typical, Poor, Good)
- `14:Crooks:Karma 1216->12 (Punks) and 16 (Hoods)`: the Karma row prints
  one number, 1216, in the Punks column and nothing in the Hoods'. Both
  halves agree with their column's ranks, so it is the two values set
  together, not a wrong value.

Recommended as `misprint` overrides, printed and corrected kept (decision
3); the Crooks' as one override of the Punks' block with the Hoods' 16 in
its `also`, or however the reader splits the block (decision 4).

**Shapes the parser must accept**, measured on the TSV and the page images:

- **Headers are no taller than the stat rows.** The card headers box at
  1.52-1.72 times the body's height; the bold `Fighting:` to `Popularity:`
  rows box at 1.48-1.72. Height cannot tell them apart (as ME1's could not).
- **Four headers print no trademark sign** (FRANKIE THE SNITCH, JOSEPH
  MERRIR, CROOKS, POLICE) and one is mixed case (`SWAT Team Member`).
- **`; dead` after a header** (SWORDSMAN, LIVING LASER), and a speck after
  the Living Laser's read as `>`. The trademark sign after a header and
  after names in the prose is often read as a closing double quote (the
  Swordsman's header, and four names in Thunderball's background).
- **A portrait between the identity line and the ranks**: the Grim Reaper's
  and the Black Knight's headers are at the top of column 1 (TSV y 118-137
  of 3197) and their `Fighting:` rows at y 1615-1668.
- **A card that runs into the next column**: the Grim Reaper's powers go on
  at the top of column 2 above Thunderball's header; the Black Knight's
  Talents at the top of column 2 above Spider-Man's.
- **A full-width note across the top of printed 13**, over the three
  illusion cards (Swordsman, Living Laser, Juggernaut), belonging to none
  of them.
- **A two-column block** (CROOKS: Punks and Hoods), the Karma row welded
  (above), and the Hoods' Popularity a rank word (TYPICAL).
- **Identity lines over one, two or three lines**, or none (Joseph Merrir,
  Crooks); Mastermind's runs to three.
- **Negative Popularity** (Mastermind -10, Juggernaut -30).
- **Sections in no fixed order, any absent**: Swordsman prints Talents,
  Equipment/Possessions, Important People and Background and no Powers;
  Merrir and the Crooks print Comments; Police and the SWAT Team Member
  print `Talent:` (singular) and `Comments and Equipment:` and no Karma,
  Resources, Popularity or Powers; Frankie prints `Powers: None` and Talents
  as run-ins (`Contacts:` with a colon, `Disguise.`, `Acting.`); Juggernaut
  prints `BACKGROUND.` as a run-in inside Powers, and a `NOTE:` after it.
- **The SWAT member's weapon table** (a member number and a weapon per row):
  the number column is read as one string of letters.

## Names the Codex already has

Mastermind (MA1), Juggernaut (MA1, MHSP2), Thunderball (MHSP1), Black Knight
(MHSP2), Spider-Man (MHSP1, MHSP2), Captain America (MHSP1, MH2, MHSP2) and
Wasp (MHSP1, MH2, MHSP2). Each MH8 card is a card of its own with a `-mh8`
id (Nate, 2026-09-28). Grim Reaper, Swordsman, Living Laser, Frankie the
Snitch, Joseph Merrir, the Crooks, Police and the SWAT Team Member are new.

## Quote marks

On the cards every single mark is an apostrophe inside or after a word, or
a misread: two read on the page images are double quotes (Merrir's
Comments and the Crooks' Comments both print an opening double quote read
as a double and a single, or two singles), and the Wasp's FLIGHT prints the
fraction one half twice, read as a single quote, a slash and a 2. No card
prints a single-quoted phrase. The trademark sign read as a closing double
quote (above) will unbalance the double quotes in several rows.

## Which reader fits

**Not finished.** The trial parse is the next row's. What is measured: the
book is MH7's booklet cards (printed 12-16, three columns, rank words, full
labelled blocks) with no cover panel at all, so `cover-panels`
(`scripts/msh/coverpanels.py`) reading `character_ranges` with `panels`
empty is the likely reader, and the shapes above are what it has to be
taught or told in the registry. This survey sets no `layout`.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-29: take the survey's recommendations).

1. **Teams:** Avengers for Captain America, the Wasp and the Black Knight,
   as MH2 and MHSP2 file them, MH1-3 filing their heroes under their team;
   every other card, Spider-Man included, under **MH8 Fault Line**
   (recommended).
2. **Characters only** (recommended; Nate, 2026-10-21).
3. **The two Karma misprints** (Living Laser, Juggernaut) as `misprint`
   overrides, printed and corrected kept (recommended), or `as_printed`.
4. **The Crooks** as two cards, Punks and Hoods, each with its own block and
   its own Karma (12 and 16) out of the welded 1216 (recommended, as MH5's
   grids were each a card), or one card with two blocks.
5. **Police and the SWAT Team Member** as cards (recommended, as MH5's
   Hammer's Mercenaries), with Karma left unset as printed (as MH5 decision
   10).
6. **Names:** `; dead` left out of the Swordsman's and the Living Laser's
   names and kept in their prose (recommended); Frankie the Snitch, Joseph
   Merrir and SWAT Team Member as printed.
7. **The fold-up figures, their instructions and the Daily Bugle** not
   imported (recommended): no statistics, and the figures are counters.
8. **The note over the three illusion cards** left out of every card
   (recommended): it is the scenario's, not a character's.

## How to reproduce

```bash
python scripts/msh/ocr-book.py mh8 --probe
python scripts/msh/ocr-book.py mh8
python scripts/msh/survey.py mh8
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-150 dpi into the scratchpad.
