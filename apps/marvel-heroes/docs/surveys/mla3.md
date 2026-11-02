# Survey: MLA3 Night Life (TSR6897)

> **DRAFT.** Written through the stat blocks of the Player Characters, the
> factions and the Non-Player Character Roster from Ammo to Mentallo (plan
> row 19a). The rest of the roster, the chapters' grids, the vehicle lines,
> *Names the Codex already has*, *Quote marks*, *Which reader fits* and
> *Decisions* are not finished.

Marvel Super Heroes Official Advanced Game Adventure, Anthony Herring,
1990, the third module of the Gang Wars trilogy (the MLA series, after MLA1
After Midnight and MLA2 Night Moves). Registry entry:
`scripts/msh/books.json` -> `mla3`. Measured 2026-11-02.

**Rows citing this book:** none yet (no data is built).

Everything here was measured and read on the page images.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 69 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-11-02 into the main
  checkout's `.cache/msh/books/mla3/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, 69 pages OCR'd).
- **The booklet is printed 1-63** (PDF 2-64). The print is clean: the
  grids' codes and numbers OCR well but for `(30)`, which reads `(80)` on
  11 of the 27 grids read (and Fu Manchu's R `AM (50)` reads `(80)` too),
  so no number here is taken from the OCR. The row letters read worse:
  Tesseract drops the whole letter column of eight grids (the Typical
  Batboy's and Si Fan Assassin's, printed 7; the Typical Wildboy's, 8;
  Ammo's, 50; Fixer's, 51; Gator's, 52; Mad-Dog's, 55; Rocko's, 57) and on
  Gator's and Rocko's reads the dropped letters as one garbled word after
  the grid. A negative
  Popularity's minus sign reads as a replacement character.
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 598 x 772 | Cover (outside front; MLA3 ADVENTURE and product code 6897) | - |
| 2-64 | 594 x 767 | Adventure Book | 1-63 |
| 65 | 594 x 767 | Advertisement: RPGA Network | - |
| 66-67 | 594 x 767 | Maps: Coney Island and Sacred Trinity Cathedral (66), Gorilla Compound and Gator's Lair (67) | - |
| 68 | 598 x 772 | Back cover (8.95 U.S., 6897, ISBN 0-88038-893-5) | - |
| 69 | 2238 x 1503 | Map sheet: Orbison Warehouse, Liberty's Crown, Roxxon Laboratory, Hammerhead's Mansion, Lifelike Manikin Factory | - |

**PDF 65** is a full-page advertisement for the RPGA Network, with no
folio. **PDF 66-67** are booklet-sized, grey-framed floor plans, two to a
page, each map named on its frame, with no folio. Printed 1-63 and the
advertisement make 64 pages, a multiple of four, so the advertisement is
most likely the booklet's last leaf and the two map pages the inside of the
cover, but the scan does not show it. Each is a part of its own with
`offset` null, as MLA1's and MLA2's map pages. None prints a statistic, and
no map is imported.

## Offset

`survey.py` votes **printed = PDF - 1 on 52 pages** (PDF 3 and 11-64 but
22, 32 and 33), and no booklet page disagrees. One vote is not a folio:
PDF 69's (k = 67), a digit on the map sheet.

Ten more booklet pages print their folio, PDF - 1, read on a strip of each
page's foot, Tesseract missing it: PDF 4-10, 22, 32 and 33. Printed 1 (PDF
2) is the title page, with the Contents, the credits and the fine print, and
is the only booklet page with no folio. So `parts`, as MLA1 and MLA2, with
the cover, the advertisement, the map pages, the back cover and the map
sheet as parts of their own with `offset` null. The planner's guess
(printed = PDF - 1, PDF 2-64) holds.

## The book's own authority lists

**Contents (printed 1, headed Table of Contents).** Transcribed from a
render, then each entry checked against its banner on the page. **Every
entry's page agrees with its banner**, so there are no `contents_errata`.
Two banners word their title differently (below); `sections` stores the
Contents' wording.

| printed | Contents entry | banner |
|---|---|---|
| 2 | Introduction | top |
| 3 | The Player Characters | top |
| 7 | Non-Player Character Factions | top |
| 9 | The Spirit Bombs | top |
| 10 | Chapter 1: Museum Robbed! | top |
| 10 | Chapter 2: At the Scene | mid-page |
| 12 | Chapter 3: The Evening News | top |
| 13 | Chapter 4: Mongoose Wants Blood | top |
| 15 | Chapter 5: The House of Pasta | top |
| 16 | Chapter 6: Cameron Come Home | top |
| 17 | Chapter 7: Trouble at Sammy's | top |
| 18 | Chapter 8: Roxxon Oil | top |
| 20 | Chapter 9: Mayhem in Midtown | top |
| 21 | Chapter 10: Some Time Off | top |
| 22 | Chapter 11: The Dead Shall Rise | top |
| 23 | Chapter 12: A Hot Tip | mid-page |
| 24 | Chapter 13: Rumble in the Jungle | top |
| 26 | Chapter 14: Strange Headlines | top |
| 27 | Chapter 15: The Wildboys | top |
| 28 | Chapter 16: Hiram Blows a Fuse | top |
| 31 | Chapter 17: Into the Nether Realm | top |
| 33 | Chapter 18: The Persuader | top |
| 34 | Chapter 19: An Invitation | top |
| 35 | Chapter 20: A Meeting of Minds | top; the banner prints A MEETING OF THE MINDS |
| 37 | Chapter 21: Dancing Manikins | top |
| 40 | Chapter 22: A Barrel of Monkeys | top |
| 41 | Chapter 23: Gator Lays an Egg | top |
| 42 | Chapter 24: A Test of Strength | mid-page |
| 44 | Chapter 25: Give Me Liberty | top; the banner adds a spaced ellipsis, GIVE ME LIBERTY . . . |
| 45 | Chapter 26: A Giant Walks! | top |
| 48 | Epilogue: The War is Over | top |
| 50 | Non-Player Character Roster | top |

- **The banners.** Every section opens with a white-on-black bar across the
  page in capitals; a chapter's prints `CHAPTER N: TITLE`. Each was found on
  a 30 dpi render of every booklet page, and each prints the Contents'
  number; every title but Chapter 20's and Chapter 25's matches it word for
  word. A bar with no words tops every page that opens no section
  (printed 51-57 among them): decoration, not a banner. Chapter 19's banner
  (printed 34) is printed faint, but reads on a 60 dpi render.
- **Tesseract reads every banner whole but six**: Chapters 2, 3, 7, 12, 24
  and 26 lose their title (the line holds `CHAPTER N:` alone). It places
  Chapter 5's banner (printed 15, at the page's top) lower in the page's
  text, after a column of prose, so a reader cannot take a banner's place in
  the text stream as its place on the page.
- **Inside Non-Player Character Factions**, four bold title-case subheads
  name the groups: The Faces of Fear, The Maggia and The Si Fan (printed 7)
  and The Wildboys (printed 8, column 1, under the end of the Si Fan's
  text). None is in the Contents. Each carries one Typical grid. The
  section's opening lists the four again, each a dash and the name in lower
  case (printed 7, column 1), as MLA1's list did.
- **The Spirit Bombs** (printed 9) is a device section and prints no grid;
  its one `Health` is in a sentence of prose.
- **No index.** The Contents names no character. The coverage checklist
  will be this survey's list.

## Columns, labels and ranks

- **Three columns** on every booklet page read (printed 2-8 and 50-57 on
  the page images, every chapter page on a 30 dpi render), a block's rank
  rows and its labels as two sub-columns of one column.
- **One block shape** on every page read: a bold header, an identity line
  under most, then seven rows of row letter, rank CODE in capitals, number
  in brackets (`F IN (40)`), with `Health:`, `Karma:`, `Resources:` and
  `Popularity:` in bold to the right of rows F, S, R and P, Resources as a
  code and its number in brackets (`GD (10)`). MLA1's and MLA2's shape.
  **Colossal Deathlok** (printed 51) and **the Guardsmen** (printed 53)
  print `Health:` and `Karma:` only, no Resources and no Popularity.
- **Headers.** The Player Characters' and the faction grids' are bold title
  case, the faction grids' each `Typical <member>` with no identity line.
  **The roster's are bold CAPITALS**, where MLA1's and MLA2's were title
  case, alphabetical and inverted where a surname leads (`MANCHU, FU`,
  printed 56), a bracketed variant in title case (`CAPTAIN AMERICA
  (Original)`, printed 50; `IRON MAN (Mark VIII Armor)`, printed 54), and
  one with a leading The (`THE FLY`, printed 52).
- **Identity lines.** `Real Name:` under all 6 Player Characters and 14 of
  the 15 roster cards read; the Guardsmen (printed 53) print none.
  `Unrevealed` for Ammo (printed 50) and Hammerhead (53), `Varies` for the
  Mandroid (57). Three wrap onto a second line in the narrow column:
  Mockingbird's (printed 4, a nickname in double quotes and a married name),
  Colossal Deathlok's (printed 51, not a name but a short sentence naming the
  original Deathlok) and Fu Manchu's (printed 56, an alias in brackets);
  Mad-Dog's (printed 55) carries a nickname in double quotes on one
  line.
- **Section labels**, counted on the OCR of PDF 4-9 and 51-58 and read on
  the images: `KNOWN POWERS:` in capitals (21, one per card), each power an
  italic title-case run-in under it; Ammo's (printed 50) prints `None`.
  **The Player Characters print `Talents:` and `Background:` in bold title
  case (6 each); the roster prints them in capitals, `TALENTS:` and
  `BACKGROUND:`** (13 each on PDF 51-58; the Guardsmen print neither, and
  Mentallo's run on to printed 58). Colossal Deathlok (printed 51) and Fu
  Manchu (56) add `Weakness:` under their powers. The four faction grids
  print `Talents:` and `Weaponry:` (4) under the grid and no powers or
  background; the Typical Batboy's Talents is `None`, and the Typical Si Fan
  Assassin adds `Mental Barrier:` (printed 7). **Kingpin's `Weaponry:`**
  (printed 55) is an italic power under `KNOWN POWERS:`, not a section, as
  MLA1's Whirlwind's was. No `Contacts:` on the pages read.
- **Ranks.** FB, PR, TY, GD, EX, RM, IN, AM, MN and UN. **FB is the book's
  spelling of Feeble on these pages**, always `FB (2)`: Colossal Deathlok's
  I and P (printed 51) and Gator's Resources (52). **UN** is Colossal
  Deathlok's S, `UN (100)` (printed 51). The OCR of PDF 43 holds an `FE`
  code and of PDF 16, 29 and 31 a Shift 0 (`SH-0`, `Sh-0`), all in chapter
  grids: row 19b reads them on the images.
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1 and 65-69 holds no `Health`, `Karma` or rank
row, and their images show the cover, the advertisement, the two pages of
floor plans, the back cover's blurb and the map sheet. So `panels` is
empty, as MLA1's and MLA2's.

## Stat blocks: the Player Characters, the factions and the roster to Mentallo

Every block of printed 3-8 and 50-57 was read on the page image (130 dpi,
and 250 dpi for the Guardsmen) and checked against the book's own
arithmetic and `apps/marvel-heroes/data/ranks.json`. Printed 2 (the
Introduction) and printed 6 (the end of Spider-Man's text over a full-width
picture) hold none.

**6 Player Characters, 4 faction grids, 15 roster cards and 2 sub-grids.**

| printed (PDF) | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 3 (4) | Daredevil (Matthew Murdock) | IN 40, IN 40, GD 10, EX 20, TY 6, MN 75, GD 10 | 110 | 91 | PR (4) | 6 |
| 3 (4) | Hawkeye (Clint Barton) | GD 10, RM 30, GD 10, EX 20, TY 6, GD 10, TY 6 | 70 | 22 | GD (10) | 45 |
| 4 (5) | Mockingbird (Barbara "Bobbi" Morse Barton) | EX 20, EX 20, TY 6, GD 10, EX 20, TY 6, TY 6 | 56 | 32 | TY (6) | 50 |
| 4 (5) | Moon Knight (Marc Spector) | RM 30, EX 20, EX 20, EX 20, GD 10, EX 20, RM 30 | 90 | 60 | RM (30) | 10 |
| 5 (6) | Shang-Chi (Shang-Chi) | AM 50, RM 30, EX 20, RM 30, GD 10, RM 30, IN 40 | 130 | 80 | TY (6) | 20 |
| 5 (6) | Spider-Man (Peter Parker) | RM 30, AM 50, IN 40, IN 40, EX 20, GD 10, IN 40 | 160 | 70 | TY (6) | 30/6 |
| 7 (8) | Typical Batboy (The Faces of Fear) | TY 6, GD 10, TY 6, GD 10, PR 4, TY 6, PR 4 | 32 | 14 | TY (6) | 0 |
| 7 (8) | Typical Maggia Thug (The Maggia) | GD 10, TY 6, TY 6, GD 10, TY 6, PR 4, TY 6 | 32 | 16 | GD (10) | 0 |
| 7 (8) | Typical Si Fan Assassin (The Si Fan) | EX 20, EX 20, GD 10, GD 10, TY 6, TY 6, EX 20 | 60 | 32 | PR (4) | 0 |
| 8 (9) | Typical Wildboy (The Wildboys) | GD 10, GD 10, TY 6, GD 10, TY 6, TY 6, TY 6 | 36 | 18 | TY (6) | -2 |
| 50 (51) | AMMO (Unrevealed) | RM 30, EX 20, GD 10, EX 20, GD 10, GD 10, TY 6 | 80 | 26 | TY (6) | -10 |
| 50 (51) | CAPTAIN AMERICA (Original) (Steve Rogers) | AM 50, IN 40, RM 30, RM 30, EX 20, EX 20, AM 50 | 150 | 90 | TY (6) | 100/6 |
| 51 (52) | COLOSSAL DEATHLOK (the original Deathlok, Luther Manning) | RM 30, GD 10, UN 100, MN 75, GD 10, FB 2, FB 2 | 215 | 14 | - | - |
| 51 (52) | FIXER (Norbert Ebersol) | GD 10, GD 10, TY 6, TY 6, IN 40, EX 20, GD 10 | 32 | 70 | RM (30) | -10 |
| 52 (53) | THE FLY (Richard Deacon) | EX 20, IN 40, RM 30, IN 40, PR 4, MN 75, GD 10 | 130 | 89 | PR (4) | -5 |
| 52 (53) | GATOR (Bart Buckle) | GD 10, RM 30, RM 30, IN 40, PR 4, TY 6, PR 4 | 110 | 14 | FB (2) | 0 |
| 53 (54) | GOLIATH (Erik Josten) | EX 20, GD 10, IN 40, MN 75, TY 6, PR 4, PR 4 | 145 | 14 | GD (10) | -10 |
| 53 (54) | GUARDSMEN (no identity line) | EX 20, EX 20, RM 30, RM 30, TY 6, TY 6, TY 6 | **70** | 18 | - | - |
| 53 (54) | HAMMERHEAD (Unrevealed) | EX 20, GD 10, GD 10, EX 20, GD 10, GD 10, RM 30 | 60 | 50 | EX (20) | -3 |
| 54 (55) | IRON MAN (Mark VIII Armor) (Anthony Stark) | EX 20, RM 30, IN 40, MN 75, IN 40, EX 20, TY 6 | 165 | 66 | EX (20) | 25 |
| 54 (55) | Tony Stark (sub-grid) | TY 6, TY 6, PR 4, TY 6, IN 40, EX 20, TY 6 | 22 | 66 | - | - |
| 55 (56) | KINGPIN (Wilson Fisk) | RM 30, GD 10, EX 20, IN 40, GD 10, EX 20, GD 10 | 100 | 40 | IN (40) | 0 |
| 55 (56) | MAD-DOG (Robert "Buzz" Baxter) | RM 30, IN 40, RM 30, IN 40, GD 10, EX 20, TY 6 | 140 | 36 | TY (6) | -10 |
| 56 (57) | MANCHU, FU (Fu Manchu, alias the Celestial One) | EX 20, GD 10, TY 6, GD 10, AM 50, IN 40, AM 50 | 46 | 140 | IN (40) | -20 |
| 57 (58) | MANDROID (Varies) | RM 30, EX 20, IN 40, RM 30, TY 6, TY 6, TY 6 | 120 | 18 | GD (10) | 0 |
| 57 (58) | Rocko (sub-grid) | EX 20, GD 10, GD 10, GD 10, TY 6, TY 6, TY 6 | 50 | 18 | GD (10) | 0 |
| 57 (58) | MENTALLO (Marvin Flumm) | TY 6, GD 10, TY 6, RM 30, GD 10, RM 30, AM 50 | 52 | 90 | TY (6) | 5 |

The identity in brackets is the card's `Real Name:` line, as printed
(Colossal Deathlok's summarised, being a sentence); the faction grids' is
their subhead. A `-` is a label the grid does not print.

**Where each card sits**, for the reader: Daredevil (printed 3, column 1)
and Hawkeye (column 3), whose text runs on to printed 4, column 1;
Mockingbird (printed 4, column 2) and Moon Knight (column 3, his text on to
printed 5, column 1); Shang-Chi and Spider-Man (printed 5, columns 2 and 3),
Spider-Man's text on to the top of printed 6. The Typical Batboy, Maggia
Thug and Si Fan Assassin (printed 7, columns 1, 2 and 3), the Typical
Wildboy (printed 8, column 2). On the roster: Ammo and Captain America
(printed 50, columns 1 and 2); Colossal Deathlok (printed 51, column 1) and
Fixer (column 3, his text on to printed 52, column 1); the Fly and Gator
(printed 52, columns 2 and 3); Goliath (printed 53, column 1, running into
column 2), the Guardsmen (column 2, their powers on to the top of column
3) and Hammerhead (column 3, his text on to printed 54, column 1); Iron Man
(printed 54, column 1, his text through columns 2 and 3 and on to printed
55, column 1); Kingpin (printed 55, column 2) and Mad-Dog (column 3, his
text on to printed 56, column 1); Fu Manchu (printed 56, column 2, his text
on to printed 57, column 1); the Mandroid (printed 57, column 1, his text
through column 2) and Mentallo (column 3, his text on to printed 58,
column 1, where the next row's cards start).

**The two sub-grids**, each without a header of its own:

- **Tony Stark's grid** (printed 54, column 1) is inside Iron Man (Mark VIII
  Armor)'s KNOWN POWERS, introduced by a line of prose as the man's own
  statistics out of the armor, with `Health:` and `Karma:` only, as MLA2's.
- **Rocko's grid** (printed 57, column 2) is inside the Mandroid's KNOWN
  POWERS, under its `Wearer:` power. That power names Rocko, a Maggia
  hitman, as the wearer the Mandroid grid above is statted for, and gives
  this second grid as his statistics without the suit. It prints all four
  labels. The Mandroid's `TALENTS:` and `BACKGROUND:` follow it; the
  talents are Rocko's.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **26 of 27**; the Guardsmen's fails (100, printed 70) |
| Karma = R+I+P | **27 of 27** |
| every ability number within its rank code's range (FB as Feeble) | **27 of 27** (189 numbers) |
| every Resources number within its code's range | **24 of 24** that print one (Colossal Deathlok, the Guardsmen and Tony Stark's sub-grid print none) |
| a number inside its range but not the rank's standard | **none**; every number read is its rank's standard |

**The misprints so far, each read on the page image** (printed page: name:
field printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 53:Guardsmen:Health 70 -> 100 | F `EX (20)`, A `EX (20)`, S `RM (30)`, E `RM (30)`, each code agreeing with its number (read at 250 dpi); 20+20+30+30 is 100, and their Karma 18 holds. The alternative, rows summing to 70, would change two rows whose codes and numbers agree, so the Health is the misprint, as MLA1 decision 5 (the Decisions' to confirm, not finished) |

**Noted, not a block:** Hammerhead's `Exoskeleton` power (printed 53,
column 3) gives a second Health for him while the device is worn, as in
MLA1 and MLA2; it is prose, not a grid. The Spirit Bombs (printed 9) and
the chapter pages print `Health` in prose too (printed 12, 26, 32 and 47
among them); row 19b reads every chapter page.

## The rest of the roster and the chapters' grids

Not finished (plan row 19b): the roster from Mongoose to Vortex (printed
58-63, PDF 59-64; Mongoose's header is in column 1 of printed 58, under
the end of Mentallo's text), the grids inside the chapters (PDF 14, 16, 29,
31, 41, 43, 44 and 45, printed 13, 15, 28, 30, 40, 42, 43 and 44; the OCR
places a `Health` on each) and the vehicle lines (Control, Speed, Body,
Protection; PDF 14, 16 and 34).

## Names the Codex already has

Not finished (plan row 19b).

## Quote marks

Not finished (plan row 19b).

## Which reader fits

Not finished (plan rows 19b and 19c).

## Decisions this survey leaves open

Not finished (plan row 19b). Already ruled: characters only (Nate,
2026-10-21), second cards with `-mla3` ids (2026-09-28), a leading The
dropped from a name (2026-10-21), and each decision taken as this survey
recommends (Nate, 2026-10-31).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mla3 --probe
python scripts/msh/ocr-book.py mla3
python scripts/msh/survey.py mla3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 25-250 dpi into the scratchpad.
