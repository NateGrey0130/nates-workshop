# Survey: MLA3 Night Life (TSR6897)

Marvel Super Heroes Official Advanced Game Adventure, Anthony Herring,
1990, the third module of the Gang Wars trilogy (the MLA series, after MLA1
After Midnight and MLA2 Night Moves). Registry entry:
`scripts/msh/books.json` -> `mla3`. Measured 2026-11-02.

**Rows citing this book:** 214 `msh_book_text` rows over 41 character entries
in production (`DB_MARVEL`, read back 2026-11-04).

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
  Deathlok's S, `UN (100)` (printed 51). **The chapters' grids add three
  spellings**, read on the images: `FE (2)` for Feeble on the Alligators'
  R, I and P (printed 42), where every other Feeble in the book prints
  `FB`; and Shift 0 as `SH-0 (0)` on the Hammerhead Robot's I and P
  (printed 15) and as `Sh-0 (0)` on the Security Robots' (printed 28) and
  Cameron's Machine's (printed 30). The registry aliases all three.
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
| 53:Guardsmen:Health 70 -> 100 | F `EX (20)`, A `EX (20)`, S `RM (30)`, E `RM (30)`, each code agreeing with its number (read at 250 dpi); 20+20+30+30 is 100, and their Karma 18 holds. The alternative, rows summing to 70, would change two rows whose codes and numbers agree, so the Health is the misprint (decision 5) |

**Noted, not a block:** Hammerhead's `Exoskeleton` power (printed 53,
column 3) gives a second Health for him while the device is worn, as in
MLA1 and MLA2; it is prose, not a grid. The Spirit Bombs (printed 9) and
the chapter pages print `Health` in prose too (printed 9, 12, 26, 30, 32
and 47); none of those mentions is a grid (next section).

## Where the blocks are

Printed 3-8 (the Player Characters and the factions), printed 50-63 (the
Non-Player Character Roster) and eight chapter pages: printed 13, 15, 28,
30, 40, 42, 43 and 44. Found by counting `Health`, `Karma`, `KNOWN POWERS`
and a rank code before a bracketed number on the OCR of all 69 pages, each
page with a hit then read on its image: no other page holds a grid. Printed
9 (The Spirit Bombs), 12, 26, 32 and 47 print `Health` in a sentence (as
printed 30 does beside its grid), and
printed 2, 18, 19, 21, 24, 33 and 48 `Karma`; none is a grid. The card
pages are the registry's `character_ranges`; the chapters' grids are its
`opponents`, each statted inside a chapter's prose. No chapter prints a
one-line grid, so the entry has no `one_line_grids`.

## Stat blocks: the rest of the roster and the chapters

Every block of printed 58-63 (PDF 59-64) and the nine grids inside the
chapters (PDF 14, 16, 29, 31, 41, 43, 44 and 45) was read on the page image
(150 dpi, and 250 dpi for Thor) and checked the same way. Mongoose's header
is in column 1 of printed 58, under the end of Mentallo's text.

**11 roster cards, 2 grids inside cards and 9 chapter grids.**

| printed (PDF) | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 58 (59) | MONGOOSE (Unknown) | RM 30, UN 100, RM 30, RM 30, TY 6, EX 20, GD 10 | 190 | 36 | GD (10) | 0 |
| 58 (59) | PERSUADER (Roland Rayburn) | TY 6, TY 6, TY 6, GD 10, GD 10, GD 10, IN 40 | 28 | 60 | GD (10) | 0 |
| 58 (59) | PHANTOM TONG (Varies) | RM 30, EX 20, GD 10, RM 30, TY 6, TY 6, EX 20 | 90 | 32 | PR (4) | 0 |
| 59 (60) | RHINO (Unrevealed) | RM 30, EX 20, MN 75, AM 50, GD 10, TY 6, PR 4 | 175 | 20 | PR (4) | -15 |
| 59 (60) | SEAVER, CAMERON (Cameron Seaver) | PR 4, TY 6, PR 4, TY 6, AM 50, GD 10, TY 6 | 20 | 66 | EX (20) | 0 |
| 59 (60) | SERSI (Sersi) | GD 10, RM 30, AM 50, AM 50, EX 20, RM 30, IN 40 | 140 | 90 | RM (30) | 25 |
| 60 (61) | STARFOX (Eros) | GD 10, EX 20, IN 40, AM 50, EX 20, TY 6, RM 30 | 120 | 56 | EX (20) | 75 |
| 60 (61) | THOR (Thor; Dr. Donald Blake; Sigurd Jarlson; Eric Masterson) | UN 100, EX 20, MN 75, MN 75, GD 10, GD 10, RM 30 | **200** | 50 | EX (20) | 50 |
| 61 (62) | Eric Masterson (grid inside Thor's card) | TY 6, TY 6, TY 6, GD 10, GD 10, TY 6, RM 30 | 28 | 46 | RM (30) | 0 |
| 61 (62) | TYPHOID MARY (Mary, last name unrevealed) | IN 40, IN 40, GD 10, RM 30, TY 6, GD 10, PR 4 | 120 | 20 | GD (10) | 0 |
| 62 (63) | Mary (grid inside Typhoid Mary's card) | PR 4, TY 6, PR 4, TY 6, TY 6, GD 10, PR 4 | 20 | 20 | GD (10) | 0 |
| 62 (63) | VISION (Vision) | RM 30, EX 20, AM 50, IN 40, EX 20, GD 10, RM 30 | 140 | 60 | PR (4) | 30 |
| 63 (64) | VORTEX (no identity line) | IN 40, AM 50, MN 75, IN 40, PR 4, PR 4, AM 50 | 205 | 58 | - | - |
| 13 (14) | Typical Policeman (Chapter 4) | GD 10, GD 10, TY 6, GD 10, TY 6, TY 6, TY 6 | 36 | 18 | - | - |
| 15 (16) | Hammerhead Robot (Chapter 5) | EX 20, RM 30, RM 30, IN 40, TY 6, SH-0 0, SH-0 0 | 120 | 0 | - | - |
| 28 (29) | Security Robots (Chapter 16) | EX 20, EX 20, RM 30, IN 40, TY 6, Sh-0 0, Sh-0 0 | 110 | 0 | - | - |
| 30 (31) | Cameron's Machine (Chapter 16) | Sh-0 0, Sh-0 0, Sh-0 0, RM 30, EX 20, Sh-0 0, Sh-0 0 | 30 | 0 | - | - |
| 40 (41) | Bertha the Gorilla (Chapter 22) | TY 6, TY 6, EX 20, EX 20, FB 2, TY 6, PR 4 | 52 | - | - | - |
| 42 (43) | Alligators (Chapter 23) | PR 4, GD 10, RM 30, EX 20, FE 2, FE 2, FE 2 | 64 | - | - | - |
| 43 (44) | Hound Dog (Chapter 24) | GD 10, TY 6, GD 10, GD 10, FB 2, PR 4, TY 6 | 36 | 12 | - | - |
| 44 (45) | The Security Guards (Chapter 25) | GD 10, GD 10, TY 6, GD 10, TY 6, TY 6, TY 6 | 36 | 18 | - | - |
| 44 (45) | Creature From the Void (Chapter 25) | EX 20, RM 30, EX 20, RM 30, PR 4, TY 6, TY 6 | 100 | 16 | - | - |

A `-` is a label the grid does not print. The identity in brackets is the
card's `Real Name:` line, as printed (Typhoid Mary's wraps over two lines,
`Mary (last name unrevealed)`, and Thor's lists four names over two); the
chapter grids' is the chapter they sit in.

**Where each card sits**, for the reader: Mongoose (printed 58, column 1)
and the Persuader (column 2); the Phantom Tong (printed 58, column 3, its
text on to printed 59, column 1) and the Rhino (printed 59, column 1, his
text through column 2); Cameron Seaver and Sersi (printed 59, column 3, her
text through printed 60, columns 1 and 2); Starfox (printed 60, column 2)
and Thor (column 3, his text on to printed 61, columns 1 and 2); Typhoid
Mary (printed 61, column 3, her text on to printed 62, column 1); the
Vision (printed 62, column 2, under a picture across the top half of the
page, his text on to printed 63, column 1) and Vortex (printed 63, column
2, his text through column 3). Printed 63 ends the book's text.

**Entry kinds** beyond the first half's:

- **Eric Masterson's grid** (top of printed 61, column 1) is inside Thor's
  KNOWN POWERS, introduced by a line of prose as Thor's statistics in that
  mortal form, and prints all four labels. It is MLA2's Eric Masterson
  grid, number for number.
- **Mary's grid** (printed 62, column 1, under the picture) is inside
  Typhoid Mary's KNOWN POWERS, under her `Alter-Ego:` power, which names
  Mary as her other personality; a line of prose introduces the grid as
  Mary's statistics. It prints all four labels. Typhoid Mary's `TALENTS:`
  and `BACKGROUND:` follow it.
- **The chapters' grids**: each a bold title-case header over a vertical
  column of seven rows as the cards print, with `Health:` and `Karma:`
  beside F and S and no Resources or Popularity, and no identity line.
  Bertha the Gorilla and the Alligators print no `Karma:` at all. Under the
  grid, the Typical Policeman and the Security Guards print `Talents:` and
  `Weaponry:`; the Hammerhead Robot, the Security Robots and the Creature
  From the Void print `KNOWN POWERS:` with italic run-ins; Cameron's
  Machine, Bertha the Gorilla, the Alligators and Hound Dog are followed by
  the chapter's prose (plan row 19c measures how each resumes).
- **Cameron's Machine** (printed 30) is the device the heroes fight in
  Chapter 16, a full grid with Shift 0 on every row but E and R. Its
  header prints a curly apostrophe.
- **Hound Dog's companions** (printed 43): the prose gives his four
  companions the Typical Batboy's statistics by reference and prints no
  grid for them. Not an entry.
- **Characters in the prose only**, named and not statted, are not
  entries.
- **No grid repeats another inside the book.** The Hammerhead Robot is not
  Hammerhead's card (other numbers: a machine made to look like him).

**More labels on these pages**, read on the images: every card prints
`KNOWN POWERS:`, `TALENTS:` and `BACKGROUND:` in capitals. The Phantom Tong
add `Mental Barrier:` (under the grid's powers, pointing to the Typical Si
Fan Assassin's) and `Weaponry:` (between `TALENTS:` and `BACKGROUND:`),
each in bold as the faction grids print them. Typhoid Mary's `Weaponry:`
and `Alter-Ego:` are italic powers under `KNOWN POWERS:`. Mentallo's
`Weaknesses:` (top of printed 58, the end of his powers) prints in roman,
the body's weight, neither bold nor italic. Vortex and the Guardsmen are
the two cards with no `Real Name:` line.

**The OCR**, as on the first half's pages: it reads `(30)` as `(80)` on
these grids too (Mongoose, the Phantom Tong, the Rhino, Starfox, Thor, the
Vision, Cameron's Machine and the Alligators among them), and drops the row
letters of the Persuader's, the Phantom Tong's, Cameron Seaver's, Thor's,
Eric Masterson's and Mary's grids. So every number here was read on the
image.

**The book checks itself, the whole book counted** (49 blocks: 32 cards,
4 faction grids, 4 grids inside cards and 9 chapter grids; no one-line
grid):

| measure | count |
|---|---|
| Health = F+A+S+E | **47 of 49**; the Guardsmen's (100, printed 70) and Thor's (270, printed 200). Cameron's Machine's 30 holds on Shift 0 as 0 |
| Karma = R+I+P | **44 of 44** that print a number other than 0; the Hammerhead Robot, the Security Robots and Cameron's Machine print `Karma: 0` (R+I+P 6, 6 and 20; printed that way, below), and Bertha the Gorilla and the Alligators print no Karma (R+I+P 12 and 6) |
| every ability number within its rank code's range (FB and FE as Feeble, SH-0 and Sh-0 as Shift 0) | **49 of 49** (343 numbers) |
| every Resources number within its code's range | **36 of 36** that print one |
| a number inside its range but not the rank's standard | **none**; every number in the book is its rank's standard |

**The misprint of these pages, read on the page image (250 dpi):**

| misprint | the book's own arithmetic |
|---|---|
| 60:Thor:Health 200 -> 270 | F `UN (100)`, A `EX (20)`, S `MN (75)`, E `MN (75)`, each code agreeing with its number; 100+20+75+75 is 270, and his Karma 50 holds. The alternative, rows summing to 200, would change rows whose codes and numbers agree, so the Health is the misprint (decision 5) |

So the book's misprints, whole: **53:Guardsmen:Health 70->100,
60:Thor:Health 200->270**. Both are the same misprints MLA2 printed on the
same two cards (`mla2.md` decision 5): the cards are reprinted. Printed on
purpose: the Karma 0 of the Hammerhead Robot (printed 15), the Security
Robots (28) and Cameron's Machine (30), machines as MLA2's House of Madness
robots.

**The vehicle lines** (not characters; decision 11): three one-line rows
of codes under a bold name, `Control`, `Speed`, `Body` and `Protection`
over them, read on the images: the Armored Truck (printed 13, Chapter 4)
`TY TY RM RM`, the Limousine (printed 15, Chapter 5) `PR GD EX GD` (the
OCR loses its codes) and the Security Limo (printed 33, Chapter 18) `TY EX
RM RM`. None prints a Health or a Karma.

## Names the Codex already has

Read against `apps/marvel-heroes/data/npcs.json` (1,018 cards) by name. By
the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with a
`-mla3` id:

- **The six Player Characters:** Daredevil (MHSP2, MH4, MH9, MT3, MLA1 and
  MLA2: the same ranks; MLA1's and MLA2's Resources `PR (4)` and
  Popularity 6 as here), Hawkeye (MHSP1, MHSP2, MH7, MH9: the same ranks;
  their Resources Typical or Good, this book's `GD (10)`), Mockingbird
  (MHSP2, MH7: the same), Moon Knight (MT2, MT3, MLA1, MLA2: the same,
  MT2's and MT3's normal form), Shang-Chi (MLA2: the same) and Spider-Man
  (MLA1, MLA2 and MT3's Spider-Man block: the same; MHSP1, MHSP2, MH8 and
  MH9 print I `Am 50`, Karma 110).
- **MLA2's cards, reprinted number for number:** the Typical Batboy, the
  Typical Maggia Thug (MLA1 too), the Typical Si Fan Assassin, Captain
  America (Original), Fixer (MLA1 too; MH1's ranks-only line prints F and A
  Typical), the Guardsmen (with the same Health 70 misprint), Hammerhead
  (MLA1 too), Iron Man (Mark VIII Armor) and its Tony Stark grid (MHSP2's
  Iron Man block too; MT3's Tony Stark), Fu Manchu (MLA2's `Manchu, Fu`),
  Mentallo (MH1 and MLA1 too), Sersi, Starfox (MH2's and MHSP2's print E
  `In 40`, Health 110), Thor and its Eric Masterson grid (with the same
  Health 200 misprint; every other book's Thor prints Health 320), and the
  Vision (MT2 and MT3 too; MH2's prints I `Ty 6`, Karma 56).
- **MLBA1's cards:** Goliath and Mad-Dog, the same numbers.
- **Kingpin** (MHSP2, MH4): the same ranks and Health 100; this book's
  Karma 40 as MHSP2's (MH4's 120), Resources `IN (40)`, Popularity 0
  (theirs 31).
- **Rhino** (MHSP2): another block, S `In 40` and I `Ex 20` (Health 140,
  Karma 34; here 175 and 20).
- **Typical Policeman** (MX1, MX2): the same numbers.
- **Alligators**: MLA1's `Alligator` (printed 42 there), the same numbers,
  this book's header plural.

Not the same beings: MA1's Cameron Hodge (not Cameron Seaver), MT3's
Security Robots (another block), MA4's Guardsman and MH9's Guardsmen
Robots, MLA2's Deathlok Simulacrum (not Colossal Deathlok), MT3's Alligator
Creatures. Every other name (Ammo, Colossal Deathlok, the Fly, Gator, the
Mandroid and Rocko's grid, Mongoose, the Persuader, the Phantom Tong,
Cameron Seaver, Typhoid Mary and Mary's grid, Vortex, the Typical Wildboy,
and the chapters' Hammerhead Robot, Security Robots, Cameron's Machine,
Bertha the Gorilla, Hound Dog, Security Guards and Creature From the Void)
is new to the Codex.

## Quote marks

**The book prints single quotes of its own**, so MA1's rule holds, not
MHSP1's. Measured on the OCR of all 69 pages: 285 opening and 228 closing
curly doubles, 4 straight doubles, 73 opening and 521 closing curly
singles (mostly apostrophes) and 8 straight singles. 128 single marks are
neither inside a word nor a plural possessive: most are dropped-g
apostrophes in the chapters' dialogue, or a double read as a single or as
a pair of singles. Read on the page images:

- **Real single quotes**, each a quotation inside a quotation in the
  chapters' prose: printed 11 and printed 12 (a news report quoting a
  phrase) and printed 36 (dialogue quoting a word).
- **On the character pages** every lone single read on the image was half
  of a double: printed 3 (Daredevil's text), printed 4 (Mockingbird's
  identity line, a nickname in doubles that the OCR reads as doubles and
  singles together), printed 7 (the factions' text), printed 50 (Captain
  America (Original)'s), printed 53 (Goliath's, a name opened as a single
  and closed as a double) and printed 56 (Fu Manchu's powers). The one on
  printed 8 is the OCR of a picture, not a mark. Printed 58-63 hold none.

So a single mark may be real, and a lost closing single on a character page
is a `text` override, never a rule (as `ma1.md` *Quote marks*). The data
row confirms the count on the character pages, where `npcs.unpaired` stops
on an odd double.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with MLA2's fields and
four things taught to it.** Measured 2026-11-02 (plan rows 19c and 19c1):
a scratch copy of `scripts/msh/` and `apps/marvel-heroes/data` at this
branch's `162a65c7` (`main` at `d94b50ac`, MLA2's reader #2055 on it), the
entry given `"layout": "grid-booklets"`, run on a copy of the cache under
its own `WORKSHOP_MSH_CACHE` (no page re-OCR'd; only grid crops were added,
to the copy). Twelve runs. `code-grids` was not tried, since this one fits
(as MLA1).

- **Stock, `layout` alone:** exit 1. 46 entries, 36 blocks, **none
  passing**: the grids read as number-then-code rows, entries are named by
  their identity line, and the nine chapter grids, the Guardsmen, Colossal
  Deathlok and Vortex have no entry.
- **With the MX1 family** (workaround 1): exit 1. 47 entries, 36 blocks,
  35 passing, 1 failing.
- **With MLA2's fields as well** (workaround 2) and the trial overrides:
  exit 1. 51 entries, 46 blocks, 43 passing and 3 known, 0 failing; the
  Hammerhead Robot (printed 15), Cameron's Machine (printed 30) and the
  Creature From the Void (printed 44) have no block.
- **With every registry workaround and reader change below:** exit 0.

| measure | trial, last run |
|---|---|
| entries | 51: the 45 characters (36 cards and the nine chapter grids) and 6 without a block |
| stat blocks | 49: one per character, and a second grid on Iron Man (Mark VIII Armor), the Mandroid, Thor and Typhoid Mary (decision 4) |
| blocks passing every check | 44, and 5 known from the trial overrides (2 `misprint`, 3 `as_printed`); failing 0 |
| powers | 133 across 34 entries |
| checklist | every card and tier found |
| exit code | 0 |

The trial overrides are the survey's decisions 4, 5 and 6 written for the
trial only, not re-read on the images: the Guardsmen's and Thor's Health
`misprint`s, the three machines' Karma 0 `as_printed`, and the four second
grids' labels (Tony Stark, Eric Masterson, Mary, Rocko), each matching one
block. The data row writes the real file.

`npcs.py mla3` on the copy exits 0: 45 characters, 49 blocks, 133 powers
(33 linked to the UPB), 212 book-text rows, and the 1,018 cards of the
other books kept.

**Registry-only workarounds** (fields `scripts/msh/` already reads; each
worked in the trial):

1. **The MX1 family.** `code_rows`, `card_headers` with the 36 card
   headers as `cards`, `title_case_labels`, and `teams` as decision 1.
   0 passing became 35.
2. **MLA2's fields:** `bracketed_card_names`, `code_row_specks`,
   `trailing_marks`, `dash_marks`, `dash_shift_codes`, `override_values`,
   `code_grids_by_pitch`, `rising_row_pitch`, `inner_grids`,
   `code_rank_aliases`, `s_before_number`, `mend_by_health`,
   `subhead_exact_case`, `body_top` 0.08, `identity_lines` 2 and
   `opponent_grid_ends`; MLA1's `derived_karma` (Bertha the Gorilla's 12
   and the Alligators' 6, decision 7); `extra_titles` for the four faction
   subheads (The Faces of Fear, The Maggia and The Si Fan on printed 7, The
   Wildboys on printed 8); and `card_names` for Cameron's Machine's curly
   apostrophe (decision 8). `rising_row_pitch` is needed: without it Bertha
   the Gorilla, Hound Dog, the Security Guards and Vortex lose their blocks.
3. **`undashed_shift_zero`**, for Cameron's Machine's S, which reads
   `Sh-O0` (printed 30). Needed alone: without it the Hammerhead Robot and
   Cameron's Machine lose their blocks, two overrides match nothing and the
   build exits 1 (47 blocks).
4. **Seven text checks, each fixed by a field alone** (run on the last
   run's parse against the one before; nothing else moved, powers 126 to
   133):
   - the Typical Batboy (printed 7): `entry_ends` where the Faces of Fear's
     own text resumes; his notes 76 words to 18;
   - Iron Man (Mark VIII Armor) (printed 55): `power_heads` ECM with
     `power_heads_not_run_ins`; notes 105 words to none, powers 12 to 15;
   - the Kingpin (printed 55) and Typhoid Mary (printed 61): `label_powers`
     Weaponry, so the italic run-in is a power and not notes (Mary's
     Weaponry and Alter-Ego);
   - the Vision (printed 62): `power_heads` with its fourth field, the line
     as read. `roster.POWER_HEAD` does not read the em dash in his Density
     Manipulation-Self head, so 165 words sat under the powers section; the
     power is named with a hyphen, as the Vision card `main` already has
     (`vision-mla2`), and his powers go 3 to 4;
   - the Alligators (printed 42): `entry_ends` at the chapter's flush line
     under the grid; 19 words of chapter text out of the card;
   - the Hammerhead Robot (printed 15): `speck_lines`, its power read
     `Boay Armor` and printed Body Armor (read on the render), so the data
     row needs no `text` verdict for it.

   Left as MLA2 left them: the Typical Si Fan Assassin's notes (117 words,
   Weaponry and Mental Barrier) and the 34 words before Captain America
   (Original)'s first power.
5. **The overrides**, as above.

Not used: `grid_headers` (every MLA3 grid prints a header).

**What the reader must learn: four things**, the first three applied in
the trial (`codegrids.py` and `gridbooks.py`, ungated), the fourth not:

1. **The least row gap, as a last pitch** (the Creature From the Void,
   printed 44). `rising_row_pitch` tries 45 and 46 px, and both crops read
   the I row with no number; a crop at the least gap, 44 px, reads it.
   Without it the Creature has no block. It adds a pitch, never replaces
   one: without `rising_row_pitch` four other grids are lost (workaround
   2). Suggested field `least_row_pitch`.
2. **`SH-O` in capitals** (the Hammerhead Robot's I, printed 15).
   `codegrids.code_of` folds `Sh-O` to `Sh-0` under `fold_shift`, but only
   in that case, so the capitals give no code. Needed alone: without it
   the counts do not move and the build exits 0, but the I is unread and
   the block passes only because `roster.check` skips a value it cannot
   read. Suggested field `upper_shift_zero`.
3. **The stream's own lines when no crop gives seven rows** (the
   Hammerhead Robot's P, printed 15). Every crop reads a bar before the
   row letter, so `code_grids_by_pitch` finds no grid and has no fallback.
   The trial reads the stream's lines over seven of the first pitch.
   Without it the Hammerhead Robot has no block. Suggested field
   `stream_row_fallback`.
4. **A shortened card identity** (Colossal Deathlok, printed 51, decision
   12). **The chain has no field for it.** `npcs.py`'s identity fields are
   `identity_to_block`, `line_identity` (needs no identity line and the
   prose to match), `bracket_identity` (needs a parenthesis in the header
   and no identity line) and `identity_lines` (joins lines, never shortens
   them); none commits Luther Manning as the identity while the printed
   line goes to D1 with the prose. MLA2's Deathlok Simulacrum ships the
   same Real Name sentence as its identity on `main` today. Suggested field
   `short_identity` (part, printed page, header, identity). Not applied.

**So grid-booklets must learn 4 things: 3 reader changes** (1-3, each
shown needed alone) **and 1 `npcs.py` field** (4); the parse leaves
nothing unfixed. Items 1-3 are ungated in the trial: the reader row gives
each a field of its own, or builds every earlier book byte-identical
(`marvel-book`, *Prove every earlier book did not move*). The trial did not
run that proof.

**Verdict: grid-booklets.** **The decision it settles** (the reader row
sets it): `"layout": "grid-booklets"`, with the fields above, the nine
overrides, and a field for each of items 1-4. This survey sets no
`layout`. The registry patch, the trial overrides, the reader diff (LF,
ASCII; it applies to `162a65c7`) and every run's output are kept in the
plan store, `trial\mla3\`, not the repo.

## Decisions this survey leaves open

Each has a recommendation, the one MLA1 and MT3 took where they had the
same question (Nate 2026-10-31: take the survey's recommendations).
Already ruled: characters only (Nate, 2026-10-21), second cards with
`-mla3` ids (2026-09-28) and a leading The dropped from a name
(2026-10-21).

1. **Teams.** Recommendation: **Night Life Heroes** for the six Player
   Characters (as MLA1's After Midnight Heroes and MLA2's Night Moves
   Heroes), and every other card, the faction grids, the roster and the
   chapters' grids, under the book's title, **MLA3 Night Life** (as MLA1,
   MLA2 and MT3 filed theirs). Not taken: a team per faction subhead, four
   teams of one grid each; the faction stays in the grid's name.
2. **Page citations.** Recommendation: MLA1's single-booklet shape,
   `MLA3 Adventure p.58` (the part's `cite` is `Adventure`).
3. **Names as printed** (recommended, as MLA1 and MLA2 decision 3), in
   title case: the roster prints its headers in capitals where MLA1's and
   MLA2's print title case, and the cards MLA2 already has keep MLA2's
   spelling (`Manchu, Fu`, `Captain America (Original)`, `Iron Man (Mark
   VIII Armor)`, `Guardsmen`). The inverted `Seaver, Cameron` is kept as
   `Manchu, Fu` is; `THE FLY` is `Fly` and `The Security Guards` is
   `Security Guards` (the leading The ruled). The plurals print as they
   are (`Phantom Tong`, `Security Robots`, `Alligators`). Not taken: the
   capitals as printed, which no other book's card names use.
4. **The grids inside cards** (recommended, as MLA2 decision 4 and MLA1's
   Werewolf): Tony Stark's grid a second block on Iron Man (Mark VIII
   Armor)'s card, labelled **Tony Stark**; Eric Masterson's on Thor's,
   labelled **Eric Masterson**; Mary's on Typhoid Mary's, labelled
   **Mary** (her other personality, the same body); and Rocko's on the
   Mandroid's, labelled **Rocko** (the wearer out of the suit, as Tony
   Stark out of the armor). Not taken: Rocko a card of his own, since the
   Mandroid grid above it is statted for him in the suit.
5. **The misprints** as `misprint` overrides keeping printed and corrected
   (recommended, as MLA2 decision 5, where the same two cards carry the
   same two misprints): the Guardsmen's Health 70 to 100 and Thor's 200 to
   270, each total corrected because every row's code and number agree.
   The book's other Feeble and Shift 0 spellings (`FE`, `SH-0`, `Sh-0`) are
   `rank_aliases`, not overrides: the numbers are right.
6. **Karma printed as 0** (recommended, as MLA2 decision 6):
   `as_printed` for the Hammerhead Robot's, the Security Robots' and
   Cameron's Machine's `Karma: 0` (printed 15, 28 and 30), the GM tools
   playing the printed value. Not taken: R+I+P derived for them, which
   would give three machines a Karma the book withholds.
7. **Totals a grid does not print** (recommended, as MLA1 decision 7, for
   the same Alligator grid): Bertha the Gorilla's Karma derived, R+I+P =
   12, and the Alligators', 6, each flagged as not printed. Resources and
   Popularity left unset where a grid prints neither: the nine chapter
   grids, Colossal Deathlok, the Guardsmen, Vortex and Tony Stark's grid.
   Not taken: the two Karma left unset, which leaves cards the GM tools
   cannot play.
8. **The chapters' grids, every one a card** (recommended, as MLA1 and
   MLA2 decision 8): all nine print a header, so each is named by it:
   **Typical Policeman**, **Hammerhead Robot**, **Security Robots**,
   **Cameron's Machine**, **Bertha the Gorilla**, **Alligators**, **Hound
   Dog**, **Security Guards** and **Creature From the Void**. Cameron's
   Machine is a card as MLA2's Dragons' Control Device was: the heroes
   fight it, and it prints a full grid. Its curly apostrophe is renamed to
   the straight mark through `card_names`, as MLA2's Typical Tiger's Claw.
   Not taken: the machine left out as an item; a card for Hound Dog's
   companions, which the book states by reference to the Typical Batboy
   (MT3 decision 11).
9. **Spider-Man's Popularity 30/6 and Captain America (Original)'s 100/6**
   kept as printed, the card showing both values (recommended, as MLA1
   decision 9 and MLA2's).
10. **The faction grids and the generic types** as `tiers`, the checklist
    (recommended, as MLA1's and MLA2's): the four Typical grids, the
    roster's Guardsmen and Phantom Tong (`Real Name: Varies`, a band of
    assassins), and the chapters' Typical Policeman, Security Robots,
    Alligators and Security Guards. Not taken: the Mandroid as a tier,
    though its `Real Name:` is `Varies` too, since its card is statted for
    one wearer, Rocko.
11. **Characters only.** The three vehicles (the Armored Truck, the
    Limousine and the Security Limo), the Spirit Bombs, the faction and
    chapter gear, the floor plans and the map sheet are not imported (Nate,
    2026-10-21).
12. **Colossal Deathlok's identity line** is a short sentence, not a name.
    Recommendation: commit only the name it gives, **Luther Manning**, as
    the card's identity (the repo commits short identity lines, never a
    sentence of the book), the line itself going to D1 with the prose. If
    the chain has no field for a shortened identity, plan row 19c says so.

## How to reproduce

```bash
python scripts/msh/ocr-book.py mla3 --probe
python scripts/msh/ocr-book.py mla3
python scripts/msh/survey.py mla3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 25-250 dpi into the scratchpad.
