# Survey: MLA2 Night Moves (TSR6895)

> **DRAFT.** Written through the stat blocks of the Player Characters, the
> factions and the Non-Player Character Roster from Beetle to Iron Man (Mark
> VIII Armor) (plan row 16a). The rest of the roster, the chapters' grids,
> the vehicle lines, *Names the Codex already has*, *Quote marks*, *Which
> reader fits* and *Decisions* are not finished.

Marvel Super Heroes Official Advanced Game Adventure, Anthony Herring,
1990, the second module of the Gang Wars trilogy (the MLA series, after MLA1
After Midnight). Registry entry: `scripts/msh/books.json` -> `mla2`.
Measured 2026-11-01.

**Rows citing this book:** none yet (no data is built).

Everything here was measured and read on the page images.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 69 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 characters on
  every page), cached 2026-11-01 into the main checkout's
  `.cache/msh/books/mla2/` (`manifest.json`: 300 dpi, `--psm 3`, Tesseract
  5.4.0, 69 pages OCR'd).
- **The booklet is printed 1-64** (PDF 2-65); the text ends half-way down
  printed 64. The print is clean: the grids' codes and numbers OCR well, the
  row letters badly. Tesseract drops most of a grid's letter column (Cloak's,
  printed 3, keeps F to R and loses I and P; Daredevil's, printed 4, and
  Beetle's, printed 54, keep none), and on those two reads the dropped
  letters as one garbled word after the grid. A negative Popularity's minus sign reads as an
  em dash.
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 596 x 765 | Cover (outside front; MLA2 ADVENTURE and product code 6895) | - |
| 2-65 | 594 x 767 | Adventure Book | 1-64 |
| 66-67 | 594 x 767 | Maps: Inperial Theater (Map #3, so printed) and Chiang Warehouse (Map #1) (66), House of Madness (Map #6) and Waterfront Warehouse (67) | - |
| 68 | 598 x 772 | Back cover (8.95 U.S., 6895, ISBN 0-88038-874-9, barcode 0 46363 06895 0) | - |
| 69 | 2245 x 1493 | Map sheet: Oriental Garden (Map #2), Maggia Laboratory (Map #5), Shuttle System (Map #4), Si Fan Hideout (Map #8) | - |

**PDF 66-67** are booklet-sized, grey-framed floor plans under the MARVEL
SUPER HEROES logo, two to a page, each map named on the frame, with no
folio. Printed 1-64 is a multiple of four, so they are most likely the
inside of the cover, but the scan does not show it. They are one part of
their own with `offset` null, as MLA1's. None prints a statistic, and no map
is imported.

## Offset

`survey.py` votes **printed = PDF - 1 on 48 pages** (PDF 11-65 but 20, 24,
30, 33, 37, 44 and 45), and no page disagrees.

Fifteen more booklet pages print their folio, PDF - 1, read on a strip of
each page's foot, Tesseract missing it: PDF 3-10, 20, 24, 30, 33, 37, 44 and
45. Printed 1 (PDF 2) is the title page, with the Contents, the credits and
the fine print, and is the only booklet page with no folio. So `parts`, as
MLA1, with the cover, the map pages, the back cover and the map sheet as
parts of their own with `offset` null. The planner's guess (printed = PDF -
1, PDF 2-65) holds.

## The book's own authority lists

**Contents (printed 1, headed Table of Contents).** Transcribed from a
render, then each entry checked against its banner on the page. **Every
entry agrees with its page**, so there are no `contents_errata`. Stored as
`sections`.

| printed | Contents entry | banner |
|---|---|---|
| 2 | Introduction | top |
| 3 | The Player Characters | top |
| 7 | Non-Player Character Factions | top |
| 9 | Chapter 1: Museum Piece Stolen! | top |
| 10 | Chapter 2: The Curator Tells a Tale | top |
| 11 | Chapter 3: Do Ghosts Get Hungry? | top |
| 11 | Chapter 4: The China Star | mid-page |
| 12 | Chapter 5: What's in the Box? | mid-page |
| 14 | Chapter 6: Oriental Curiosities | top |
| 15 | Chapter 7: Eddie Takes a Dive | top |
| 15 | Chapter 8: ZOOM! BANG! - Fireworks! | mid-page |
| 17 | Chapter 9: Mei Li Takes a Plunge | top |
| 17 | Chapter 10: A Day Off | mid-page |
| 18 | Chapter 11: The Oriental Garden | top |
| 20 | Chapter 12: Night Moves | top |
| 21 | Chapter 13: Coils of the Constrictor | top |
| 22 | Chapter 14: A City's Poison | top |
| 23 | Chapter 15: Bite of the Beetle | top |
| 24 | Chapter 16: Runaway Garbage | top |
| 25 | Chapter 17: Ice of the Blizzard | mid-page |
| 26 | Chapter 18: A Crack House Crumbles | top |
| 27 | Chapter 19: Smugglers' Blues | top |
| 30 | Chapter 20: Avengers Assemble! | top |
| 33 | Chapter 21: Rest and Relaxation? | top |
| 36 | Chapter 22: Breakout! | top |
| 37 | Chapter 23: Tak's in Trouble | top |
| 38 | Chapter 24: The Face of Fear | top |
| 44 | Chapter 25: The Informant | mid-page |
| 45 | Chapter 26: Midnight Meetings | top |
| 48 | Chapter 27: A Celebration | top |
| 50 | Chapter 28: Lee Min's Treachery | top |
| 52 | Chapter 29: Fu Manchu Lives! | top |
| 54 | Non-Player Character Roster | top |

- **The banners.** Every section opens with a white-on-black bar across the
  page in capitals; a chapter's prints `CHAPTER N: TITLE`. Each was found on
  a 40 dpi render of every booklet page, and each prints the Contents'
  number and title. A bar with no words tops every page that opens no
  section: decoration, not a banner.
- **Chapter 8's dash.** The Contents prints a spaced em dash in its title,
  the banner an unspaced one. The registry is ASCII, so `sections` stores a
  spaced hyphen.
- **Tesseract reads every banner whole but Chapter 28's**, whose title it
  loses (the line holds `CHAPTER 28:` alone). It places the banners of
  Chapters 1, 2, 26 and 29 lower in the page's text than the page prints
  them (after a column of prose), so a reader cannot take a banner's place in
  the text stream as its place on the page.
- **Inside Non-Player Character Factions**, five bold title-case subheads
  name the groups: The Dragonlords, The Faces of Fear and The Maggia
  (printed 7), The Si Fan and The Tiger's Claw (printed 8). None is in the
  Contents. The Maggia carries two Typical grids, each of the others one.
- **No index.** The Contents names no character. The coverage checklist
  will be this survey's list.

## Columns, labels and ranks

- **Three columns** on every booklet page read (printed 2-8 and 54-58 on
  the page images, every chapter page on a 40 dpi render), a block's rank
  rows and its labels as two sub-columns of one column.
- **One block shape** on every page read: a bold title-case header, an
  identity line under most, then seven rows of row letter, rank CODE in
  capitals, number in brackets (`F IN (40)`), with `Health:`, `Karma:`,
  `Resources:` and `Popularity:` in bold to the right of rows F, S, R and P,
  Resources as a code and its number in brackets (`GD (10)`). MLA1's shape.
- **One horizontal row, codes only.** Beetle's KNOWN POWERS (printed 54)
  give his statistics out of the armor as a row of the seven letters over a
  row of seven codes, no numbers, no Health and no Karma. It is not a block;
  nothing in it can be checked.
- **Headers.** The Player Characters' and the roster's are bold title case,
  the roster's alphabetical, two with a bracketed variant (`Captain America
  (Original)`, `Iron Man (Mark VIII Armor)`). The faction grids' headers
  are the same type, each `Typical <member>`, with no identity line. One
  header holds an apostrophe: `Typical Tiger's Claw` (printed 8).
- **Spacing differs by section.** In The Player Characters a blank line
  separates header, identity line and grid, and each run-in label; in the
  roster the identity line sits directly under the header and `Talents:` and
  `Background:` follow the text above them with no blank line.
- **Identity lines.** `Real Name:` under 16 of the 17 cards read; the
  Dreadnoughts (printed 57) print none. Hammerhead's reads `Unrevealed`. The
  Deathlok Simulacrum's (printed 56) is not a name but a short sentence
  naming the original Deathlok, wrapped onto a second, indented line.
- **Section labels**, counted on the OCR of PDF 4-9 and 55-60 and read on
  the images: `KNOWN POWERS:` in capitals (17, one per card), each power an
  italic title-case run-in under it; on Captain America (Original) (printed
  54), Constrictor (56) and Iron Man (Mark VIII Armor) (58) a line of prose
  runs on after the label before the first power. `Talents:` (17) and
  `Background:` (17) are bold title-case run-ins; Iron Man's two run on to
  the top of printed 59, column 1. Dagger adds `Weakness:` (printed 4) and
  the Dreadnoughts `Weaknesses:` (printed 57). The six faction grids print
  `Talents:` and `Weaponry:` (6) under the grid and no powers or
  background; the Typical Si Fan Assassin adds `Mental Barrier:` (printed
  8). No `Contacts:` on the pages read.
- **Ranks.** FB, PR, TY, GD, EX, RM, IN, AM and MN. **FB is the book's
  spelling of Feeble**, always `FB (2)`: Dagger's Resources (printed 3), the
  Deathlok Simulacrum's Resources and P (56), the Dreadnoughts' R and P (57).
  No block read prints FE, and the OCR of no booklet page holds an FE code,
  so `rank_aliases` maps FB to feeble. Resources prints `None` on the
  Dreadnoughts, who print `Karma: None` too (printed 57).
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1 and 66-69 holds no `Health`, `Karma` or rank
row, and their images show the cover, the two pages of floor plans, the
back cover's blurb and the map sheet. So `panels` is empty, as MLA1's.

## Stat blocks: the Player Characters, the factions and the roster to Iron Man

Every block of printed 3-8 and 54-58 was read on the page image (120 dpi,
and 220 dpi for the two marks below) and checked against the book's own
arithmetic and `apps/marvel-heroes/data/ranks.json`. Printed 2 (the
Introduction) holds none.

**7 Player Characters, 6 faction grids, 10 roster cards and 1 sub-grid.**

| printed (PDF) | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 3 (4) | Cloak (Tyrone Johnson) | TY 6, GD 10, EX 20, IN 40, TY 6, EX 20, GD 10 | 76 | 36 | PR (4) | 3 |
| 3 (4) | Dagger (Tandy Bowen) | PR 4, PR 4, TY 6, RM 30, GD 10, GD 10, GD 10 | 44 | 30 | FB (2) | 2 |
| 4 (5) | Daredevil (Matthew Murdock) | IN 40, IN 40, GD 10, EX 20, TY 6, MN 75, GD 10 | 110 | 91 | PR (4) | 6 |
| 4 (5) | Iron Fist (Daniel Rand) | IN 40, RM 30, GD 10, EX 20, GD 10, IN 40, **AM 75** | 100 | 125 | PR (4) | 20 |
| 5 (6) | Moon Knight (Marc Spector) | RM 30, EX 20, EX 20, EX 20, GD 10, EX 20, RM 30 | 90 | 60 | RM (30) | 10 |
| 5 (6) | Power Man (Luke Cage) | RM 30, GD 10, IN 40, AM 50, GD 10, EX 20, TY 6 | 130 | 36 | PR (4) | 18 |
| 6 (7) | Spider-Man (Peter Parker) | RM 30, AM 50, IN 40, IN 40, EX 20, GD 10, IN 40 | 160 | 70 | TY (6) | 30/6 |
| 7 (8) | Typical Dragonlord (The Dragonlords) | GD 10, GD 10, TY 6, GD 10, PR 4, TY 6, TY 6 | 36 | 16 | PR (4) | 0 |
| 7 (8) | Typical Batboy (The Faces of Fear) | TY 6, GD 10, TY 6, GD 10, PR 4, TY 6, PR 4 | 32 | 14 | TY (6) | 0 |
| 7 (8) | Typical Maggia Thug (The Maggia) | GD 10, TY 6, TY 6, GD 10, TY 6, PR 4, TY 6 | 32 | 16 | GD (10) | 0 |
| 7 (8) | Typical Maggia Technician (The Maggia) | TY 6, TY 6, TY 6, TY 6, EX 20, GD 10, TY 6 | 24 | 36 | GD (10) | 0 |
| 8 (9) | Typical Si Fan Assassin (The Si Fan) | EX 20, EX 20, GD 10, GD 10, TY 6, TY 6, EX 20 | 60 | 32 | PR (4) | 0 |
| 8 (9) | Typical Tiger's Claw (The Tiger's Claw) | GD 10, GD 10, TY 6, GD 10, TY 6, TY 6, TY 6 | 36 | 18 | TY (6) | 0 |
| 54 (55) | Beetle (Abner Jenkins) | GD 10, GD 10, RM 30, EX 20, EX 20, RM 30, TY 6 | 70 | 56 | EX (20) | -10 |
| 54 (55) | Blizzard (Donny Gill) | GD 10, GD 10, GD 10, EX 20, TY 6, GD 10, TY 6 | 50 | 22 | TY (6) | 0 |
| 54 (55) | Captain America (Original) (Steve Rogers) | AM 50, IN 40, RM 30, RM 30, EX 20, EX 20, AM 50 | 150 | 90 | TY (6) | 100/6 |
| 55 (56) | Chemist (Ulysses Greitzer) | TY 6, TY 6, PR 4, TY 6, RM 30, EX 20, EX 20 | 22 | 70 | EX (20) | 0 |
| 56 (57) | Constrictor (Frank Schlichting) | GD 10, GD 10, GD 10, EX 20, PR 4, GD 10, GD 10 | 50 | 24 | GD (10) | -3 |
| 56 (57) | Deathlok Simulacrum (Luther Manning, the original) | RM 30, EX 20, AM 50, IN 40, GD 10, GD 10, FB 2 | 140 | 22 | FB (2) | 0 |
| 57 (58) | Dreadnoughts (no identity line) | RM 30, EX 20, IN 40, MN 75, FB 2, EX 20, FB 2 | 165 | None | None | -10 |
| 57 (58) | Fixer (Norbert Ebersol) | GD 10, GD 10, TY 6, TY 6, IN 40, EX 20, GD 10 | 32 | 70 | RM (30) | -10 |
| 58 (59) | Hammerhead (Unrevealed) | EX 20, GD 10, GD 10, EX 20, GD 10, GD 10, RM 30 | 60 | 50 | EX (20) | -3 |
| 58 (59) | Iron Man (Mark VIII Armor) (Anthony Stark) | EX 20, RM 30, IN 40, MN 75, IN 40, EX 20, TY 6 | 165 | 66 | EX (20) | 25 |
| 58 (59) | Tony Stark (sub-grid) | TY 6, TY 6, PR 4, TY 6, IN 40, EX 20, TY 6 | 22 | 66 | - | - |

The identity in brackets is the card's `Real Name:` line, as printed (the
Deathlok Simulacrum's summarised, being a sentence); the faction grids' is
their subhead. Moon Knight's header and identity line are at the foot of
printed 5, column 1, his grid at the top of column 2. Iron Man's text runs
on to the top of printed 59, column 1, where his `Talents:` and
`Background:` are; Killer Shrike's card starts under them in column 2 and is
the next row's. **Tony Stark's grid** is a sub-grid inside Iron Man's KNOWN
POWERS, introduced as the man's own statistics out of the armor, with
`Health:` and `Karma:` only and no header of its own.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **24 of 24** |
| Karma = R+I+P | **23 of 23** that print a number; the Dreadnoughts print `Karma: None` (R+I+P is 24; printed that way, below) |
| every ability number within its rank code's range (FB as Feeble) | **23 of 24**; Iron Fist's P prints `AM (75)` (Amazing is 46-62) |
| every Resources number within its code's range | **22 of 22** that print one (the Dreadnoughts' `None` and Tony Stark's sub-grid print none) |
| a number inside its range but not the rank's standard | **none** |

**The misprints so far, each read on the page image** (printed page: name:
field printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 4:Iron Fist:P AM (75) -> MN (75) | 75 is Monstrous's standard number and outside Amazing's range; his Karma 125 holds on 75 (10+40+75), so the number is right and the code is the misprint. The alternative, AM (50), would break a Karma that holds (the Decisions' to confirm, not finished) |

**Printed on purpose:** the Dreadnoughts (printed 57) print `Karma: None`
and `Resources: None`. They are robots; their card says they have no
personality. Their R, I and P print `FB (2)`, `EX (20)` and `FB (2)`, so
R+I+P would be 24. A `None` is not a number to check; whether the GM tools
play 24 or none is the Decisions' (not finished).

**Noted, not a block:** Hammerhead's text (printed 58) gives a second
Health for him while his exoskeleton is worn; it is prose, not a grid. Captain
America (Original)'s Background, run on to the top of printed 55, column 1,
breaks one word across two lines with no hyphen (`taki` / `ng`); a fact for
the text build, not the grid.

## The rest of the roster and the chapters' grids

Not finished (plan row 16b): the roster from Killer Shrike to White Dragon
(printed 59-64, PDF 60-65; Killer Shrike's header is in column 2 of printed
59, under the end of Iron Man's text), the grids inside the chapters (PDF 24,
26, 37, 40-43 and 50, printed 23, 25, 36, 39-42 and 49) and the vehicle
lines (Control, Speed, Body, Protection; PDF 25, 28, 29 and 32).

## Names the Codex already has

Not finished (plan row 16b).

## Quote marks

Not finished (plan row 16b).

## Which reader fits

Not finished (plan rows 16b and 16c).

## Decisions this survey leaves open

Not finished (plan row 16b). Already ruled: characters only (Nate,
2026-10-21), second cards with `-mla2` ids (2026-09-28), a leading The
dropped from a name (2026-10-21), and each decision taken as this survey
recommends (Nate, 2026-10-31).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mla2 --probe
python scripts/msh/ocr-book.py mla2
python scripts/msh/survey.py mla2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 25-220 dpi into the scratchpad.
