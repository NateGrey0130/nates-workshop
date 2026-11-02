# Survey: MLA2 Night Moves (TSR6895)

> **DRAFT.** Every stat block of the book is measured (plan rows 16a and
> 16b), with *Names the Codex already has*, *Quote marks* and *Decisions*.
> *Which reader fits* is not finished (plan row 16c).

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
  8). No `Contacts:` on the pages read. The rest of the roster (printed
  59-64) adds Fu Manchu's `Weakness:` and Mentallo's `Weaknesses:` (printed
  60), and no other label; the chapters' grids print `KNOWN POWERS:` or
  nothing (below).
- **Ranks.** FB, PR, TY, GD, EX, RM, IN, AM and MN on printed 3-8 and
  54-58; the rest of the book adds `UN (100)` (Thor's F, printed 62) and
  `Sh0`, Shift 0, with no number (the House of Madness robots' I and P,
  printed 39-42), and one misprinted `RP (4)` (printed 41). **FB is the book's
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

## Where the blocks are

Printed 3-8 (the Player Characters and the factions), printed 54-64 (the
Non-Player Character Roster; printed 64 holds only the end of White
Dragon's text) and eight chapter pages: printed 23, 25, 36, 39, 40, 41, 42
and 49. Found by counting `Health`, `Karma`, `Resources`, `KNOWN POWERS` and
a rank code before a bracketed number on the OCR of all 69 pages, each page
with a hit then read on its image. Every other `Health` the OCR finds
(printed 11, 16, 18, 20, 37, 43 and 46) is a word of the prose, not a grid.
The card pages are the registry's `character_ranges`; the chapters' grids
are its `opponents`, each statted inside a chapter's prose.

**The vehicle lines** are four rows of `Control Speed Body Protection` over
four rank codes, no numbers, each under a line of prose naming the vehicle:
the garbage truck (printed 24, Chapter 16), PR, TY, EX, GD; the shuttles
(printed 27, Chapter 19), EX, RM, GD, TY; the borer machine (printed 28,
Chapter 19), PR, TY, RM, RM; the hydrofoil (printed 31, Chapter 20), TY,
IN, TY, TY. Read on the page images. Vehicles are not characters, and none
is imported (decision 11).

**The book prints no one-line grid.** Every grid is a vertical column of
seven rows. Beetle's codes-only row (printed 54, above) is the only
horizontal one, and prints no Health or Karma.

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
| 4:Iron Fist:P AM (75) -> MN (75) | 75 is Monstrous's standard number and outside Amazing's range; his Karma 125 holds on 75 (10+40+75), so the number is right and the code is the misprint. The alternative, AM (50), would break a Karma that holds. MLA1's card for him (printed 5) prints `MN (75)` (decision 5) |

**Printed on purpose:** the Dreadnoughts (printed 57) print `Karma: None`
and `Resources: None`. They are robots; their card says they have no
personality. Their R, I and P print `FB (2)`, `EX (20)` and `FB (2)`, so
R+I+P would be 24. A `None` is not a number to check (decision 6).

**Noted, not a block:** Hammerhead's text (printed 58) gives a second
Health for him while his exoskeleton is worn; it is prose, not a grid. Captain
America (Original)'s Background, run on to the top of printed 55, column 1,
breaks one word across two lines with no hyphen (`taki` / `ng`); a fact for
the text build, not the grid.

## Stat blocks: the rest of the roster and the chapters

Every block of printed 59-63 (PDF 60-64) and the thirteen grids inside the
chapters (PDF 24, 26, 37 and 40-43, and 50) was read on a crop of the page
image (150 dpi, and 220-250 dpi for the marks below) and checked the same
way. Killer Shrike's header is in column 2 of printed 59, under the end of
Iron Man's text; White Dragon's `Talents:` and `Background:` run on to the
top of printed 64, column 1, where the book's text ends.

**11 roster cards, 1 grid inside a card and 13 chapter grids.**

| printed (PDF) | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 59 (60) | Killer Shrike (Simon Maddicks) | RM 30, RM 30, RM 30, RM 30, TY 6, GD 10, TY 6 | 120 | 22 | TY (6) | 0 |
| 59 (60) | Manchu, Fu (Fu Manchu, alias the Celestial One) | EX 20, GD 10, TY 6, GD 10, AM 50, IN 40, AM 50 | 46 | 140 | IN (40) | -20 |
| 60 (61) | Mentallo (Marvin Flumm) | TY 6, GD 10, TY 6, RM 30, GD 10, RM 30, AM 50 | 52 | 90 | TY (6) | 5 |
| 60 (61) | Min, Lee (Lee Min) | EX 20, EX 20, TY 6, EX 20, TY 6, AM 50, RM 30 | 66 | 86 | RM (30) | 0 |
| 61 (62) | Sersi (Sersi) | GD 10, RM 30, AM 50, AM 50, EX 20, RM 30, IN 40 | 140 | 90 | RM (30) | 25 |
| 61 (62) | Shang-Chi (Shang-Chi) | AM 50, RM 30, EX 20, RM 30, GD 10, RM 30, IN 40 | 130 | 80 | TY (6) | 20 |
| 61 (62) | Silver Samurai (Kenuichio Harada) | RM 30, RM 30, EX 20, RM 30, GD 10, RM 30, RM 30 | 110 | 70 | EX (20) | -10 |
| 62 (63) | Starfox (Eros) | GD 10, EX 20, IN 40, AM 50, EX 20, TY 6, RM 30 | 120 | 56 | EX (20) | 75 |
| 62 (63) | Thor (Thor; Dr. Donald Blake; Sigurd Jarlson; Eric Masterson) | UN 100, EX 20, MN 75, MN 75, GD 10, GD 10, RM 30 | **200** | 50 | EX (20) | 50 |
| 62 (63) | Eric Masterson (grid inside Thor's card) | TY 6, TY 6, TY 6, GD 10, GD 10, TY 6, RM 30 | 28 | 46 | RM (30) | 0 |
| 63 (64) | Vision (Vision) | RM 30, EX 20, AM 50, IN 40, EX 20, GD 10, RM 30 | 140 | 60 | PR (4) | 30 |
| 63 (64) | White Dragon (Unrevealed) | EX 20, EX 20, GD 10, EX 20, GD 10, GD 10, GD 10 | 70 | 30 | GD (10) | -10 |
| 23 (24) | the old man (Chapter 15; no header) | PR 4, TY 6, TY 6, TY 6, TY 6, GD 10, TY 6 | 22 | 22 | - | - |
| 25 (26) | Tak (Chapter 17; no header) | TY 6, GD 10, TY 6, TY 6, PR 4, TY 6, PR 4 | 28 | 14 | - | - |
| 36 (37) | Guardsmen (Chapter 22) | EX 20, EX 20, RM 30, RM 30, TY 6, TY 6, TY 6 | **70** | 18 | - | - |
| 39 (40) | the mechanical monster (Chapter 24, exhibit 2; no header) | GD 10, PR 4, IN 40, AM 50, PR 4, Sh0, Sh0 | 104 | 0 | - | - |
| 39 (40) | the werewolf (exhibit 3; no header) | EX 20, GD 10, EX 20, IN 40, PR 4, Sh0, Sh0 | 90 | 0 | - | - |
| 40 (41) | the clown (exhibit 4; no header) | GD 10, RM 30, GD 10, **EX 30**, TY 6, Sh0, Sh0 | 80 | 0 | - | - |
| 40 (41) | the two robot children (exhibit 4; no header) | TY 6, EX 20, TY 6, EX 20, PR 4, Sh0, Sh0 | 52 | 0 | - | - |
| 40 (41) | the vampire (exhibit 5; no header) | GD 10, EX 20, EX 20, IN 40, PR 4, Sh0, Sh0 | 90 | 0 | - | - |
| 41 (42) | ten mechanical skeletons (exhibit 6; no header) | GD 10, PR 4, GD 10, GD 10, PR 4, Sh0, Sh0 | 34 | 0 | - | - |
| 41 (42) | the mechanical mummy (exhibit 7; no header) | RM 30, GD 10, IN 40, RM 30, **RP 4**, Sh0, Sh0 | 110 | 0 | - | - |
| 42 (43) | the dragons (exhibit 8; no header) | RM 30, EX 20, EX 20, RM 30, PR 4, Sh0, Sh0 | 100 | 0 | - | - |
| 42 (43) | the dragons' control device (exhibit 8; no header) | Sh0, Sh0, Sh0, RM 30, GD 10, Sh0, Sh0 | 30 | 0 | - | - |
| 49 (50) | ten skeletal ghosts (Chapter 27; no header) | EX 20, GD 10, EX 20, GD 10, TY 6, GD 10, TY 6 | 60 | 0 | - | - |

A `-` is a label the grid does not print. A chapter grid's name in lower
case is what the prose before it calls the being; only the Guardsmen have a
bold header. **Entry kinds** beyond the first half's:

- **Eric Masterson** (printed 62): a full grid inside Thor's KNOWN POWERS,
  introduced by a line of prose as Thor's mortal form, with no header,
  Health, Karma, Resources and Popularity all printed.
- **The chapters' grids**: each a vertical column of seven rows with
  `Health:` and `Karma:` beside F and S, and no Resources or Popularity. The
  old man (the restaurant owner of Chapter 15, printed 23) and Tak (the
  graffiti artist of Chapter 17, printed 25) print nothing under the grid.
  The Guardsmen (Vault security officers, Chapter 22, printed 36) and every
  grid of printed 39-42 and 49 print `KNOWN POWERS:` under it, with italic
  run-ins. Exhibit 3's prose (printed 39) gives a second werewolf the
  first one's grid in words; it prints no grid of its own.
- **The House of Madness exhibits** (Chapter 24, printed 39-42): nine
  robots, each under the numbered exhibit it stands in (2 to 8), each
  printing `Sh0` for I and P (the control device for F, A and S too) and
  `Karma: 0`.
- **Characters in the prose only**, named and not statted, are not
  entries.
- **No grid repeats another**; none of the chapters' grids repeats a card.

**The book checks itself, the whole book counted** (49 blocks: 28 cards,
6 faction grids, 2 grids inside cards and 13 chapter grids; no one-line
grid):

| measure | count |
|---|---|
| Health = F+A+S+E | **47 of 49**; Thor's (270, printed 200) and the Guardsmen's (100, printed 70). The control device's 30 holds on Sh0 as 0 |
| Karma = R+I+P | **38 of 38** that print a number other than 0 or `None`; the Dreadnoughts print `None` (R+I+P 24), and the nine House of Madness robots and the skeletal ghosts print `0` (R+I+P 4 to 22; printed that way, below) |
| every ability number within its rank code's range (FB as Feeble, Sh0 as Shift 0) | **46 of 49**; Iron Fist's P `AM (75)`, the clown's E `EX (30)` (Excellent is 16-25) and the mechanical mummy's R `RP (4)`, a code the book prints nowhere else |
| every Resources number within its code's range | **34 of 34** that print one |
| a number inside its range but not the rank's standard | **none** |

**The misprints of these pages, each read on the page image:**

| misprint | the book's own arithmetic |
|---|---|
| 62:Thor:Health 200 -> 270 | F `UN (100)`, A `EX (20)`, S and E `MN (75)`, each code agreeing with its number; 100+20+75+75 is 270, and his Karma 50 holds (decision 5) |
| 36:Guardsmen:Health 70 -> 100 | F and A `EX (20)`, S and E `RM (30)`, each code agreeing with its number; 20+20+30+30 is 100, and the Karma 18 holds (decision 5) |
| 40:the clown:E EX (30) -> RM (30) | 30 is Remarkable's standard number and outside Excellent's range; the Health 80 holds on 30 (10+30+10+30), so the number is right and the code is the misprint, as Iron Fist's (decision 5) |
| 41:the mechanical mummy:R RP (4) -> PR (4) | `RP` is no rank code; 4 is Poor's standard number, so the letters are transposed (decision 5) |

So the book's misprints, whole: **4:Iron Fist:P AM (75)->MN (75),
36:Guardsmen:Health 70->100, 40:the clown:E EX (30)->RM (30), 41:the
mechanical mummy:R RP (4)->PR (4), 62:Thor:Health 200->270**.

**Printed on purpose:** 57:Dreadnoughts:Karma and Resources `None` (above);
39-42:the nine House of Madness robots:Karma `0`, every one a machine in
the exhibits (their R prints PR, TY or GD); 49:the skeletal ghosts:Karma
`0`, a summoned horde from the spirit world (R+I+P is 22). The book prints
the same `0` on ten grids and no other grid of a living being fails Karma,
so it is the book's way of giving these beings no Karma, not a slip
(decision 6).

**Noted, not a block:** Thor's text (printed 62) rules on his Karma when he
uses one attack; it is prose, not a second Karma.

## Names the Codex already has

Read against `apps/marvel-heroes/data/npcs.json` (971 cards) by name. By
the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with a
`-mla2` id:

- **The seven Player Characters:** Cloak (MHSP2: the same seven ranks,
  Health 76, Karma 36 and Popularity 3; MHSP2's Resources Feeble, this
  book's `PR (4)`); Dagger (MHSP2: F and A Excellent where this book prints
  `PR (4)`, Health 76 there, 44 here; R, I and P agree); Daredevil (MHSP2,
  MH4, MH9, MT3, MLA1: the same ranks); Iron Fist (MHSP2 and MH4 print P
  Amazing 50 and Karma 100; MLA1 prints `MN (75)` and Karma 125, as this
  book's numbers do); Moon Knight (MT2, MT3, MLA1); Power Man (MA4, MHSP2,
  MH4, MLA1); Spider-Man (MHSP1, MHSP2, MH8, MH9, MT3, MLA1; MT3's and
  MLA1's I `GD (10)` and Karma 70 as here, the others' Amazing and 110).
- **Typical Batboy and Typical Maggia Thug** (MLA1): the same numbers.
- **Beetle** (MT3, MLBA1): the same numbers, Health 70, Karma 56.
- **Blizzard** (MH5, MH7): neither agrees; they print R Remarkable and P
  Poor (Health 46, Karma 44), this book's Donny Gill F `GD (10)`, R and P
  `TY (6)` (Health 50, Karma 22).
- **Captain America (Original)**: MHSP1, MH2, MHSP2, MH8 and MH9 (as
  Captain America (Steve Rogers)) each print another block (S Excellent, R
  Good, P Good; Health 140, Karma 60), this book's S `RM (30)`, R and I
  `EX (20)`, P `AM (50)` (Health 150, Karma 90).
- **Constrictor** (MH5): the same seven ranks, Health 50; MH5's Popularity
  3, this book's -3.
- **Fixer** (MH1, MLA1): MLA1's the same numbers; MH1's F and A Typical.
- **Hammerhead** (MLA1): the same numbers.
- **Iron Man (Mark VIII Armor)**: MHSP2's Iron Man prints the same ranks,
  Health 165, Karma 66, Resources Excellent and Popularity 25. MHSP1's,
  MH7's and MT3's are other armors. No book has a Tony Stark card.
- **Mentallo** (MH1, MLA1): the same ranks, Health 52, Karma 90,
  Popularity 5.
- **Silver Samurai** (MA1): MA1 prints A and S Excellent, E Incredible, I
  and P Excellent (Health 110, Karma 50, Popularity -20); this book A, E, I
  and P Remarkable and S Excellent (Health 110, Karma 70, Popularity -10).
- **Starfox** (MH2, MHSP2): E Incredible there (Health 110), `AM (50)` here
  (Health 120); the rest agree, Karma 56, Popularity 75.
- **Thor** (MHSP1, ME1, MHSP2, ME2, MH6, ME3): every one prints S and E
  Unearthly, R Typical, I Excellent and P Amazing (Health 320, Karma 76);
  this book S and E `MN (75)`, R and I `GD (10)`, P `RM (30)` (Karma 50).
- **Vision** (MH2, MT2, MT3): MT2's and MT3's the same numbers, Health 140,
  Karma 60, Resources `PR (4)`; MH2's I Typical (Karma 56).

Not the same beings: MA4's Guardsman (another block, F and A Excellent, S
Incredible, E Amazing) and MH9's Guardsmen Robots, MLA1's Black Talon's
Skeleton, MA4's Red Ghost, MT2's Ghost Riders, MA1's and MH1's Lockheed the
Dragon and every robot of other books. Every other name (Chemist, Deathlok
Simulacrum, Dreadnoughts, Tony Stark, Killer Shrike, Fu Manchu, Lee Min,
Sersi, Shang-Chi, Eric Masterson, White Dragon, the four new faction grids
and every chapter grid) is new to the Codex.

## Quote marks

**The book prints single quotes of its own**, so MA1's rule holds, not
MHSP1's. Measured on the OCR of all 69 pages: 247 opening and 238 closing
curly doubles, 1 straight double, 12 opening and 490 closing curly singles
(mostly apostrophes) and 15 straight singles. 31 single marks are neither
inside a word nor a possessive s's: most are a dropped g's apostrophe in
dialogue, feet marks on distances, the map pages' noise or the back cover's
blurb. Read on the page images:

- **Real single quotes** around a note read out in Chapter 7's prose,
  printed 15, opening and closing.
- **A double read as a single:** a sign's closing double, printed 21.
- **On the character pages** no lone single read on the image is a mark of
  the book: printed 25 (Tak's chapter) adds a stray single to a closing
  double, and printed 58 (Iron Man's text) reads a speck left of a line of
  column 3 as an opening single.

So a single mark may be real, and a lost closing single on a character page
is a `text` override, never a rule (as `ma1.md` *Quote marks*). The data
row confirms the count on the character pages, where `npcs.unpaired` stops
on an odd double.

## Which reader fits

Not finished (plan row 16c).

## Decisions this survey leaves open

Each has a recommendation, the one MLA1 and MT3 took where they had the
same question (Nate 2026-10-31: take the survey's recommendations).
Already ruled: characters only (Nate, 2026-10-21), second cards with
`-mla2` ids (2026-09-28) and a leading The dropped from a name
(2026-10-21).

1. **Teams.** Recommendation: **Night Moves Heroes** for the seven Player
   Characters (as MLA1's After Midnight Heroes and MT3's Revenge of Kang
   Heroes), and every other card, the faction grids, the roster and the
   chapters' grids, under the book's title, **MLA2 Night Moves** (as MLA1,
   MX1 and MT3 filed theirs). Not taken: a team per faction subhead, five
   teams of one or two grids each; the faction stays in the grid's name.
2. **Page citations.** Recommendation: MLA1's single-booklet shape,
   `MLA2 Adventure p.59` (the part's `cite` is `Adventure`).
3. **Names as printed** (recommended, as MLA1 decision 3): the roster's
   inverted headers kept (`Manchu, Fu`, `Min, Lee`), the bracketed variants
   kept (`Captain America (Original)`, `Iron Man (Mark VIII Armor)`), and
   `Dreadnoughts` and `Guardsmen` plural as printed. Not taken: uninverting
   them to Fu Manchu and Lee Min.
4. **The grids inside cards** (recommended, as MLA1 decision 4 and MT3's
   Ben): Tony Stark's grid a second block on Iron Man (Mark VIII Armor)'s
   card, labelled **Tony Stark**, and Eric Masterson's a second block on
   Thor's, labelled **Eric Masterson**; each is the character's own other
   form. Beetle's codes-only row (printed 54) stays in his text and is not a
   block: it prints no number, Health or Karma, so nothing in it could be
   checked. Not taken: a ranks-only block for it with derived numbers
   (MHSP1's `rank_only`), since this book prints numbers on every other
   grid.
5. **The misprints** as `misprint` overrides keeping printed and corrected
   (recommended, as MLA1 decision 5 and MT3 decision 7): Iron Fist's P code
   `AM` to `MN` and the clown's E code `EX` to `RM`, each number kept
   because the Health or Karma holds on it; Thor's Health 200 to 270 and the
   Guardsmen's 70 to 100, each total corrected because every row's code and
   number agree. The mechanical mummy's `RP (4)`: a `rank_aliases` entry
   `RP` to poor, as MA1 aliased its misprinted codes (`Po`, `Go`, `Re`), and
   no override, since the number is right and only the spelling is not. Not
   taken: an override for the spelling, which would show a printed value
   equal to the corrected one.
6. **Karma printed as None or 0** (recommended, as MLA1's Sentinels, Mark
   IV `NA` and MX1's sentinels' `Karma = 0`): `as_printed` for the
   Dreadnoughts' `None` Karma and Resources (printed 57), the nine House of
   Madness robots' `Karma: 0` (printed 39-42) and the skeletal ghosts'
   (printed 49), the GM tools playing the printed value. Not taken: R+I+P
   derived for them, which would give machines and a summoned horde a Karma
   the book withholds on all eleven.
7. **Totals a grid does not print** (recommended, as MLA1 decision 7): the
   chapters' thirteen grids' Resources and Popularity left unset, and Tony
   Stark's block the same. Every chapter grid prints its Health and Karma,
   so nothing is derived.
8. **The chapters' grids with no header** (recommended, as MLA1 decision 8
   and MT3 decision 3, every grid a card), named for what the prose calls
   them: **Old Man** (printed 23, the restaurant owner), **Tak** (25),
   **Mechanical Monster** and **Werewolf Robot** (39), **Clown Robot**,
   **Robot Children** and **Vampire Robot** (40), **Mechanical Skeletons**
   and **Mechanical Mummy** (41), **Dragon Robots** and **Dragons' Control
   Device** (42) and **Skeletal Ghosts** (49); **Guardsmen** (36) keeps its
   header. The control device is a card too: the heroes fight it to end the
   dragons, and it prints a full grid. Not taken: the device left out as an
   item, or a count in a name (the prose gives ten skeletons and ten
   ghosts, but no header prints a count, unlike MLA1's `Rat, pack of 10`).
9. **Spider-Man's Popularity 30/6 and Captain America (Original)'s 100/6**
   kept as printed, the card showing both values (recommended, as MLA1
   decision 9).
10. **The faction grids and the generic types** as `tiers`, the checklist
    (recommended, as MLA1's): the six Typical grids, the Dreadnoughts and
    the Guardsmen, the headed types; the headerless chapter grids are named
    in `opponents` only, as MLA1's Bartholomew Jacobs.
11. **Characters only.** The four vehicles (the garbage truck, the
    shuttles, the borer machine and the hydrofoil), the faction and chapter
    gear, the floor plans and the map sheet are not imported (Nate,
    2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mla2 --probe
python scripts/msh/ocr-book.py mla2
python scripts/msh/survey.py mla2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 25-250 dpi into the scratchpad.
