# Survey: MLA1 After Midnight (TSR6892)

Marvel Super Heroes Official Game Adventure, Anthony Herring, 1990, the
first module of the Gang Wars trilogy (the MLA series). Registry entry:
`scripts/msh/books.json` -> `mla1`. Measured 2026-11-01.

**Rows citing this book:** 189 `msh_book_text` rows over 43 character entries
in production (`DB_MARVEL`, read back 2026-11-03).

Everything here was measured and read on the page images.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 69 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 characters on
  every page), cached 2026-11-01 into the main checkout's
  `.cache/msh/books/mla1/` (`manifest.json`: 300 dpi, `--psm 3`, Tesseract
  5.4.0, 69 pages OCR'd).
- **The booklet is printed 1-63** (PDF 2-64). The print is clean: the
  grids' codes, numbers and labels OCR well, the row letters less so (`S$`
  for S, `|` for I), and the second card on a page can lose its row letters
  altogether (Daredevil's, printed 4).
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 598 x 772 | Cover (outside front; MLA1 ADVENTURE and product code 6892) | - |
| 2-64 | 594 x 767 | Adventure Book | 1-63 |
| 65-67 | 594 x 767 | Maps: East River Savings and Loan and Marauders' Hideout (65), Hank's Tavern and Starky's Pool Hall (66), The Roarin' Twenties and Waterfront Warehouse (67) | - |
| 68 | 598 x 772 | Back cover (product code 6892, ISBN 0-88038-832-3) | - |
| 69 | 2241 x 1503 | Map sheet: Washington Square Park, Faces of Fear Hideout, Ellis Island, Aurora Chocolate Mill | - |

**PDF 65-67** are booklet-sized, grey-framed floor plans, two to a page,
with no folio. Printed 1-63 and these three make 66 pages, not a multiple of
four, so at least one is not a booklet page; whether they are the booklet's
last leaves or the inside of the cover the scan does not show. They are one
part of their own with `offset` null. None prints a statistic, and no map is
imported.

## Offset

`survey.py` votes **printed = PDF - 1 on 48 pages** (PDF 10-64 but 11, 17,
22, 25, 30, 39 and 41), and no booklet page disagrees. One vote is not a
folio: PDF 69's (k = 62), a digit on the map sheet.

Fourteen more booklet pages print their folio, PDF - 1, read on a strip of
each page's foot, Tesseract missing it: PDF 3-9, 11, 17, 22, 25, 30, 39 and
41. Printed 1 (PDF 2) is the title page, with the Contents, the credits and
the fine print, and is the only booklet page with no folio. So `parts`, as
MT3 and MX1, with the cover, the map pages, the back cover and the map
sheet as parts of their own with `offset` null. The planner's guess
(printed = PDF - 1, PDF 2-64) holds.

## The book's own authority lists

**Contents (printed 1).** Transcribed from a render, then each entry checked
against its banner on the page. **Every entry agrees with its page**, so
there are no `contents_errata`. Stored as `sections`.

| printed | Contents entry | banner |
|---|---|---|
| 2 | Introduction | top |
| 4 | The Player Characters | top |
| 7 | Non-Player Character Factions | top |
| 9 | The Hypnoporter Machine | top |
| 11 | Chapter 1: Recent Headlines | top |
| 11 | Chapter 2: At the Met | mid-page |
| 13 | Chapter 3: A Walk in the Park | top |
| 13 | Chapter 4: Screams in the Dark | mid-page |
| 14 | Chapter 5: Trouble at Hank's | top |
| 15 | Chapter 6: Big News | mid-page |
| 16 | Chapter 7: A Drink on the House | top |
| 17 | Chapter 8: A Day Off | mid-page |
| 18 | Chapter 9: The Roarin' Twenties | top |
| 19 | Chapter 10: But I Wanna Be Sam Evans! | mid-page |
| 20 | Chapter 11: The Big Game | top |
| 21 | Chapter 12: Washington Square | top |
| 22 | Chapter 13: More Big News | mid-page |
| 23 | Chapter 14: A Talk With Johnny | top |
| 23 | Chapter 15: On the Waterfront | mid-page |
| 25 | Chapter 16: Back to the Twenties | mid-page |
| 26 | Chapter 17: Shocking Headlines | top |
| 27 | Chapter 18: Bellevue Hospital | top |
| 28 | Chapter 19: A Talk With Felicia | top |
| 28 | Chapter 20: Johnny's Apartment | mid-page |
| 30 | Chapter 21: Chocolate Zombies | top |
| 32 | Chapter 22: Bank Heist | mid-page |
| 33 | Chapter 23: Go To Jail, Go Directly... | mid-page |
| 33 | Chapter 24: Here Comes the Judge | mid-page |
| 35 | Chapter 25: Bad News | top |
| 35 | Chapter 26: A Meeting | mid-page |
| 36 | Chapter 27: Wideawake | top |
| 39 | Chapter 28: A Message From Max | top |
| 39 | Chapter 29: To the Met Once More | mid-page |
| 40 | Chapter 30: The Burning Ghost | top |
| 41 | Chapter 31: The World Below | mid-page |
| 43 | Chapter 32: Morlocks and Marauders | top |
| 45 | Chapter 33: This Isn't Kansas Anymore | top |
| 45 | Chapter 34: The Rescue of Callisto | mid-page |
| 46 | Chapter 35: The Defeat of Mister Fear | mid-page |
| 48 | Epilogue: The Story Continues | mid-page |
| 51 | Non-Player Character Roster | top |

- **The banners.** Every section opens with a white-on-black bar across the
  page in capitals; a chapter's prints `CHAPTER N: TITLE`. Each was found on
  a 45 dpi render of every booklet page, and each prints the Contents' number
  and title. A bar with no words tops many pages that open no section
  (printed 8, 53 and 58 among them): decoration, not a banner.
- **Tesseract reads every banner's `CHAPTER N`**, and its title too, but for
  Chapters 10, 13, 16, 18, 20, 23, 24, 26, 27, 34 and 35, whose title it
  loses (the line holds `CHAPTER N:` alone). The other banners read whole.
- **Inside Non-Player Character Factions**, six bold title-case subheads
  name the groups: The Faces of Fear, The Maggia and The Crimson Smiles Gang
  (printed 7), The Flashing Blades Gang, The Buzz Cuts Gang and Contacts and
  Other NPCs (printed 8). None is in the Contents. The first five each carry
  one Typical grid; the sixth names roster characters and has no grid.
- **No index.** The Contents names no character. The coverage checklist
  will be this survey's list.

## Columns, labels and ranks

- **Three columns** on every booklet page read (printed 2-9 and 50-58 on
  the page images, every chapter page on a 45 dpi render), a block's rank
  rows and its labels as two sub-columns of one column.
- **One block shape** on every page read: a bold title-case header, an
  identity line under most, then seven rows of row letter, rank CODE in
  capitals, number in brackets (`F IN (40)`), with `Health:`, `Karma:`,
  `Resources:` and `Popularity:` in bold to the right of rows F, S, R and P,
  Resources as a code and its number in brackets (`GD (10)`). This is MX1's
  second shape (code then number in brackets) with MT3's capital codes. The
  chapters' grids are the same column with fewer labels (*Stat blocks: the
  rest of the roster and the chapters*). **No horizontal one-line grid**
  anywhere in the book.
- **Headers.** The Player Characters' and the roster's are bold title case;
  the roster's are alphabetical and inverted where a surname leads
  (`Bifrost, Felicia`, `Bifrost, Johnny`). The faction grids' headers are
  the same type, each `Typical <member>`, with no identity line.
- **Identity lines.** `Real Name:` under 19 of the 22 cards read (an
  unknown name printed `Unrevealed`, Frankenstein's Monster's in double
  quotes), `Real Names:` under the Brothers Grimm (printed 54), `Alias:`
  under Felicia Bifrost (printed 51). Johnny Bifrost (printed 52) prints no
  identity line.
- **Section labels**, counted on the OCR of PDF 5-9 and 52-59 and read on
  the images: `KNOWN POWERS:` in capitals (22, one per card), each power an
  italic title-case run-in under it; `Talents:` (27) and `Background:` (22)
  as bold title-case run-ins; Mentallo adds `Weaknesses:` (printed 58). The
  five faction grids print `Talents:` and `Weaponry:` (5) under the grid,
  and no powers or background. The rest of the roster (PDF 60-64) adds no
  label: `KNOWN POWERS:` (10), `Talents:` (11), `Background:` (11) and
  `Real Name:` (10) on its eleven cards, Pride, Mr. Maximilian (printed 59)
  printing no identity line and no powers. The Whirlwind's `Weaponry:`
  (printed 63) is an italic power under `KNOWN POWERS:`, not a section.
  Over the book's 33 cards: `KNOWN POWERS:` 32, `Background:` 33,
  `Real Name:` 29. The chapters' grids add **`Abilities:`** (Jack the
  Bartender, printed 18; Security Officers, printed 36), found nowhere
  else, each with `Weaponry:`, and SWF Operatives (printed 32) prints
  `Talents:` and `Weaponry:`.
- **Ranks.** FE (Callisto's Resources), PR, TY, GD, EX, RM, IN, AM and MN,
  and `Sh-0` for the R, I and P of the Black Talon's zombie and skeleton
  (printed 53). Resources prints `NA` on those two and `None` on
  Frankenstein's Monster (printed 56), and the Sentinels, Mark IV print `NA`
  for Karma, Resources and Popularity (printed 60). The rest of the roster
  and the chapters print no other code. No book-specific spelling. Marks on
  the page, not spellings: a speck before Johnny Bifrost's P code (`.TY`,
  printed 52), a square closing bracket on Hammerhead's P (`RM (30]`,
  printed 57), and the Typical Flashing Blade's A printed `GD 12` with no
  brackets (printed 8).
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1 and 65-69 holds no `Health`, `Karma` or rank
row, and their images show the cover, the three pages of floor plans, the
back cover's blurb and the map sheet. So `panels` is empty, as MT3's.

## Where the blocks are

Printed 4-8 (the Player Characters and the factions), printed 51-63 (the
Non-Player Character Roster) and five chapter pages: printed 18, 32, 36, 40
and 42. Found by counting `Health:`, `Karma:`, `Resources:`, `KNOWN POWERS`
and a rank code before a bracketed number on the OCR of all 69 pages, each
page with a hit then read on its image: no other page holds a grid. The
Hypnoporter Machine (printed 9) is a device and prints none. The card pages
are the registry's `character_ranges`; the chapters' grids are its
`opponents`, each statted inside a chapter's prose.

## Stat blocks: the Player Characters, the factions and the roster to Mentallo

Every block of printed 4-8 and 51-58 was read on a crop of the page image
(130-250 dpi) and checked against the book's own arithmetic and
`apps/marvel-heroes/data/ranks.json`. Printed 2-3 (the Introduction) hold
none.

**6 Player Characters, 5 faction grids, 16 roster cards and 2 sub-grids.**

| printed (PDF) | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 4 (5) | Black Widow (Natalia Alianova Romanova) | IN 40, RM 30, GD 10, EX 20, GD 10, IN 40, EX 20 | 100 | 70 | GD (10) | 30 |
| 4 (5) | Daredevil (Matthew Michael Murdock) | IN 40, IN 40, GD 10, EX 20, TY 6, MN 75, GD 10 | 110 | 91 | PR (4) | 6 |
| 5 (6) | Iron Fist (Daniel Rand) | IN 40, RM 30, GD 10, EX 20, GD 10, IN 40, MN 75 | 100 | 125 | PR (4) | 20 |
| 5 (6) | Moon Knight (Marc Spector) | RM 30, EX 20, EX 20, EX 20, GD 10, EX 20, RM 30 | 90 | 60 | RM (30) | 10 |
| 6 (7) | Power Man (Luke Cage) | RM 30, GD 10, IN 40, AM 50, GD 10, EX 20, TY 6 | 130 | 36 | PR (4) | 18 |
| 6 (7) | Spider-Man (Peter Parker) | RM 30, AM 50, IN 40, IN 40, EX 20, GD 10, IN 40 | 160 | 70 | TY (6) | 30/6 |
| 7 (8) | Typical Batboy (The Faces of Fear) | TY 6, GD 10, TY 6, GD 10, PR 4, TY 6, PR 4 | 32 | 14 | TY (6) | 0 |
| 7 (8) | Typical Maggia Thug (The Maggia) | GD 10, TY 6, TY 6, GD 10, TY 6, PR 4, TY 6 | 32 | 16 | GD (10) | 0 |
| 7 (8) | Typical Crimson Smile (The Crimson Smiles Gang) | TY 6, GD 10, TY 6, GD 10, PR 4, PR 4, PR 4 | 32 | 12 | PR (4) | 0 |
| 8 (9) | Typical Flashing Blade (The Flashing Blades Gang) | TY 6, **GD 12**, TY 6, **TY 7**, TY 6, PR 4, TY 6 | 31 | 16 | PR (4) | 0 |
| 8 (9) | Typical Buzz Cut (The Buzz Cuts Gang) | GD 10, TY 6, TY 6, TY 6, PR 4, PR 4, PR 4 | 28 | **11** | PR (4) | 0 |
| 51 (52) | Arclight (Phillipa Sontag) | RM 30, EX 20, RM 30, IN 40, TY 6, EX 20, EX 20 | 120 | 46 | GD (10) | -10 |
| 51 (52) | Bifrost, Felicia (alias Lady Anguish) | TY 6, GD 10, TY 6, GD 10, GD 10, RM 30, IN 40 | 32 | 80 | TY (6) | 0 |
| 52 (53) | Bifrost, Johnny | EX 20, GD 10, TY 6, GD 10, TY 6, TY 6, TY 6 | 46 | 18 | PR (4) | 0 |
| 52 (53) | Black Panther (T'Challa) | AM 50, IN 40, EX 20, RM 30, GD 10, RM 30, EX 20 | 140 | 60 | AM (50) | 66 |
| 53 (54) | Black Talon (Unrevealed) | TY 6, TY 6, GD 10, EX 20, TY 6, EX 20, RM 30 | 42 | 56 | TY (6) | -10 |
| 53 (54) | Black Talon's zombie (sub-grid) | RM 30, RM 30, RM 30, RM 30, Sh-0, Sh-0, Sh-0 | **80** | 0 | NA | -30 |
| 53 (54) | Black Talon's skeleton (sub-grid) | GD 10, GD 10, GD 10, GD 10, Sh-0, Sh-0, Sh-0 | 40 | 0 | NA | -30 |
| 54 (55) | Blacklash (Mark Scarlotti) | RM 30, GD 10, GD 10, RM 30, EX 20, GD 10, PR 4 | 80 | 34 | TY (6) | -8 |
| 54 (55) | Boomerang (Fred Myers) | EX 20, RM 30, GD 10, EX 20, GD 10, GD 10, TY 6 | 80 | 26 | GD (10) | -5 |
| 54 (55) | Brothers Grimm (Percy and Barton Grimes) | TY 6, GD 10, TY 6, RM 30, GD 10, GD 10, EX 20 | 52 | 40 | EX (20) | -5 |
| 55 (56) | Callisto (Unrevealed) | IN 40, EX 20, GD 10, EX 20, GD 10, IN 40, GD 10 | 90 | 60 | FE (2) | 6 |
| 55 (56) | Eel (Edward Lavell) | EX 20, RM 30, TY 6, EX 20, EX 20, TY 6, TY 6 | 76 | **22** | TY (6) | -2 |
| 56 (57) | Fixer (Norbert Ebersol) | GD 10, GD 10, TY 6, TY 6, IN 40, EX 20, GD 10 | 32 | 70 | RM (30) | -10 |
| 56 (57) | Frankenstein's Monster ("Adam") | EX 20, GD 10, IN 40, AM 50, PR 4, TY 6, GD 10 | 120 | 20 | None | -2 |
| 57 (58) | Gypsy Moth (Sybil Dvorak) | TY 6, GD 10, TY 6, EX 20, PR 4, GD 10, PR 4 | 42 | 18 | RM (30) | 0 |
| 57 (58) | Hammerhead (Unrevealed) | EX 20, GD 10, GD 10, EX 20, GD 10, GD 10, RM 30 | 60 | 50 | EX (20) | -3 |
| 58 (59) | Harpoon (Unrevealed) | EX 20, IN 40, EX 20, RM 30, TY 6, TY 6, GD 10 | 110 | 22 | GD (10) | -10 |
| 58 (59) | Mentallo (Marvin Flumm) | TY 6, GD 10, TY 6, RM 30, GD 10, RM 30, AM 50 | 52 | 90 | TY (6) | 5 |

The identity in brackets is the card's `Real Name:` line (or `Real Names:`,
or `Alias:`), as printed; the faction grids' is their subhead. Hammerhead's
text runs on to the top of printed 58, column 1, and Mentallo's (column 3)
to the top of printed 59, column 1, where Mister Fear's card starts under it
(the next section). Printed 58 holds Harpoon and Mentallo only. **The Black
Talon's zombie and skeleton** are sub-grids inside his Necromancy power,
each introduced as the typical creature he raises, with no header of their
own.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **28 of 29**; the zombie's fails as printed (120, printed 80; printed on purpose, below) |
| Karma = R+I+P | **27 of 29**; the Typical Buzz Cut's (12, printed 11) and Eel's (32, printed 22). The zombie's and skeleton's `Karma: 0` hold on Sh-0's 0 |
| every ability number within its rank code's range | **29 of 29** |
| every Resources number within its code's range | **26 of 26** that print one (the zombie's and skeleton's `NA` and Frankenstein's Monster's `None` print none) |
| a number inside its range but not the rank's standard | **two**, both the Typical Flashing Blade's (printed 8): A `GD 12` (Good is 8-15) and E `TY (7)` (Typical is 5-7). Its Health 31 holds on them |

**The misprints of these pages, each read on the page image** (printed
page: name: field printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 8:Typical Buzz Cut:Karma 11 -> 12 | R, I and P each print `PR (4)`, and every row's code agrees with its number; 4+4+4 is 12, and its Health 28 holds |
| 55:Eel:Karma 22 -> 32 | R `EX (20)`, I `TY (6)`, P `TY (6)`, each code agreeing with its number; 20+6+6 is 32. The alternative, R `GD (10)` for 22, would change a row whose code and number agree, so the Karma is the misprint (decision 5) |

**Printed on purpose:** the Black Talon's zombie prints `Health: 80` over
four `RM (30)` rows (F+A+S+E is 120). His Necromancy text gives a zombie's
Health as his own Power rank number, and states that number as 80; the
skeleton's Health is half of it, 40, which F+A+S+E also gives. So the
zombie's 80 is the book's rule, an `as_printed` with that reason, not a
misprint.

**Noted, not a block:** Hammerhead's text (printed 58) gives a second
Health for him while a device is worn; it is prose, not a grid.

## Stat blocks: the rest of the roster and the chapters

Every block of printed 59-63 (PDF 60-64) and the seven grids inside the
chapters (PDF 19, 33, 37, 41 and 43) was read on a crop of the page image
(120-200 dpi) and checked the same way. Mister Fear's header is in column 1
of printed 59, under the end of Mentallo's text.

**11 roster cards, 1 grid inside a card and 7 chapter grids.**

| printed (PDF) | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 59 (60) | Mister Fear (Alan Fagan) | TY 6, GD 10, TY 6, GD 10, GD 10, EX 20, GD 10 | 32 | 40 | RM (30) | -5 |
| 59 (60) | Pride, Mr. Maximilian (no identity line) | PR 4, TY 6, PR 4, TY 6, EX 20, GD 10, GD 10 | 20 | 40 | GD (10) | 10 |
| 59 (60) | Scarecrow (Ebenezer Laughton) | EX 20, RM 30, GD 10, GD 10, TY 6, EX 20, FE 2 | 70 | 28 | TY (6) | -6 |
| 60 (61) | Scorpion (MacDonald Gargan) | RM 30, IN 40, IN 40, IN 40, TY 6, TY 6, GD 10 | 150 | 22 | TY (6) | -15 |
| 60 (61) | Sentinels, Mark IV (Not applicable) | EX 20, EX 20, AM 50, MN 75, TY 6, TY 6, PR 4 | 165 | NA | NA | NA |
| 60 (61) | Shroud (Unrevealed) | RM 30, EX 20, GD 10, EX 20, GD 10, IN 40, EX 20 | 80 | 70 | GD (10) | -10 |
| 61 (62) | Skids (Sally Blevins) | GD 10, TY 6, PR 4, GD 10, PR 4, GD 10, EX 20 | 30 | 34 | PR (4) | 1 |
| 61 (62) | Tatterdemalion (Arnold Paffenroth) | EX 20, EX 20, GD 10, EX 20, TY 6, PR 4, FE 2 | 70 | **8** | FE (2) | -1 |
| 62 (63) | Vertigo (Unrevealed) | GD 10, GD 10, TY 6, EX 20, TY 6, GD 10, IN 40 | 46 | 56 | GD (10) | -10 |
| 62 (63) | Werewolf (Jack Russell) | RM 30, EX 20, RM 30, IN 40, TY 6, MN 75, GD 10 | 120 | 91 | EX (20) | -2 |
| 62 (63) | Werewolf's human statistics (grid inside the card) | TY 6, TY 6, TY 6, GD 10, TY 6, GD 10, GD 10 | 28 | 26 | EX (20) | 0 |
| 63 (64) | Whirlwind (David Cannon) | GD 10, IN 40, GD 10, RM 30, TY 6, TY 6, TY 6 | 90 | 18 | TY (6) | -8 |
| 18 (19) | Jack the Bartender (Chapter 9) | GD 10, GD 10, GD 10, GD 10, PR 4, TY 6, PR 4 | 40 | 14 | PR (4) | 0 |
| 32 (33) | SWF Operatives (Chapter 22) | EX 20, GD 10, GD 10, TY 6, TY 6, TY 6, GD 10 | 46 | 22 | GD (10) | 4 |
| 36 (37) | Security Officers (Chapter 27) | GD 10, GD 10, TY 6, GD 10, TY 6, TY 6, TY 6 | 36 | 18 | - | - |
| 40 (41) | Bartholomew Jacobs (Chapter 30; no header) | -, -, -, -, RM 30, GD 10, MN 75 | - | 115 | - | - |
| 42 (43) | Alligator (Chapter 31) | PR 4, GD 10, RM 30, EX 20, FE 2, FE 2, FE 2 | 64 | - | - | - |
| 42 (43) | Rat, pack of 10 (Chapter 31) | EX 20, TY 6, FE 2, EX 20, FE 2, FE 2, FE 2 | 48 | - | - | - |
| 42 (43) | Mosquito Swarm (Chapter 31) | EX 20, FE 2, FE 2, EX 20, FE 2, FE 2, FE 2 | 44 | - | - | - |

A `-` is a label the grid does not print. **Entry kinds** beyond the first
half's:

- **The Werewolf's human statistics** (printed 62): a full grid under his
  powers, introduced by a line of prose, with no header: Jack Russell's
  form when he is not transformed.
- **The chapters' types** (Jack the Bartender, SWF Operatives, Security
  Officers, the Alligator, Rat, pack of 10 and Mosquito Swarm): a bold
  header over the grid in a chapter's column, no identity line, the chapter
  resuming under it. Jack the Bartender and Security Officers print
  `Abilities:` and `Weaponry:` under the grid, SWF Operatives `Talents:`
  and `Weaponry:`, the chapter 31 three nothing.
- **Bartholomew Jacobs** (printed 40): three rows, R, I and P, with
  `Karma:` beside R, under a line of prose naming him and with no header.
  The chapter gives him the physical abilities of the hero he possesses,
  so the book prints no F, A, S, E or Health for him.
- **Characters in the prose only**, named and not statted, are not
  entries.

**The book checks itself, the whole book counted** (48 blocks: 33 cards, 5
faction grids, 3 grids inside cards and 7 chapter grids):

| measure | count |
|---|---|
| Health = F+A+S+E | **46 of 47** that print one; the zombie's as printed (above). Bartholomew Jacobs prints none |
| Karma = R+I+P | **41 of 44** that print a number; the Typical Buzz Cut's, Eel's and Tatterdemalion's (12, printed 8). The Sentinels, Mark IV print `NA`; the chapter 31 three print no Karma |
| every ability number within its rank code's range | **48 of 48** |
| every Resources number within its code's range | **39 of 39** that print one |
| a number inside its range but not the rank's standard | still **two**, the Typical Flashing Blade's (printed 8) |

**The misprint of these pages, read on the page image:**

| misprint | the book's own arithmetic |
|---|---|
| 61:Tatterdemalion:Karma 8 -> 12 | R `TY (6)`, I `PR (4)`, P `FE (2)`, each code agreeing with its number; 6+4+2 is 12, and his Health 70 holds. The alternative, R `FE (2)` for 8, would change a row whose code and number agree, as for Eel (decision 5) |

So the book's misprints, whole: **8:Typical Buzz Cut:Karma 11->12,
55:Eel:Karma 22->32, 61:Tatterdemalion:Karma 8->12**. Printed on purpose:
53:Black Talon's zombie:Health 80 (his Necromancy rule) and
60:Sentinels, Mark IV:Karma, Resources and Popularity NA (a robot, as MA1
prints `-` for the same machine).

## Names the Codex already has

Read against `apps/marvel-heroes/data/npcs.json` (901 cards) by name. By
the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with a
`-mla1` id:

- **The six Player Characters:** Black Widow (MH4), Daredevil (MHSP2, MH4,
  MH9, MT3), Iron Fist (MHSP2, MH4), Moon Knight (MT2, MT3), Power Man (MA4,
  MHSP2, MH4) and Spider-Man (MHSP1, MHSP2, MH8, MH9, MT3).
- **Callisto** (MA1): the same seven ranks, Health 90 and Karma 60; MA1's
  Resources `Ty (6)` and Popularity -10, this book's `FE (2)` and 6.
- **Fixer** (MH1, a ranks-only line): F and A Typical where this book
  prints GD 10 (Health 24 there, 32 here); S, E, R, I and P agree.
- **Gypsy Moth** (MA1): F, A, S, E and I agree; MA1's R Ty and P Ex (Karma
  36, Popularity 70), this book's R and P `PR (4)` (Karma 18, Popularity 0).
- **Mentallo** (MH1): the same ranks, Health 52, Karma 90, Popularity 5.
- **Scorpion** (MT2): the same numbers, Health 150, Karma 22, Popularity -15.
- **Sentinels, Mark IV**: MA1's Mark IV & V Sentinels card, its Mark IV
  block, prints the same numbers and codes, P `4 Pr` as here, where MX1's
  Mark IV prints `6 Ty`; MX1, MX2, MX3 and MX4 each have a Mark IV
  Sentinel card too.
- **Skids** (MA1): the same seven ranks, Health 30 and Karma 34; MA1's
  Resources `Fb (2)` and Popularity 0, this book's `PR (4)` and 1.
- **Vertigo** (MA1, MA4): neither agrees. MA1 prints A Ty and R Pr (Health
  42, Karma 54); MA4 another block (Health 48, Karma 40).
- **Whirlwind** (MA1, MH7): the same ranks, Health 90, Karma 18; MA1's
  Popularity -8 as here, MH7's 8.

Not the same beings: MA4's Dr. Jacob Grimm and Penny Grimm (not the
Brothers Grimm), MT3's Alligator Creatures and Security Robots, MH1's
Crimson Dynamo. Every other name (Arclight, Felicia and Johnny Bifrost,
Black Panther, Black Talon and his zombie and skeleton, Blacklash,
Boomerang, Brothers Grimm, Eel, Frankenstein's Monster, Hammerhead,
Harpoon, Mister Fear, Pride, Scarecrow, Shroud, Tatterdemalion, Werewolf,
the five faction grids and the seven chapter grids) is new to the Codex.

## Quote marks

**The book prints single quotes of its own**, so MA1's rule holds, not
MHSP1's. Measured on the OCR of all 69 pages: 113 opening and 108 closing
curly doubles, 6 straight doubles, 41 opening and 415 closing curly singles
(mostly apostrophes) and 8 straight singles. 88 single marks are neither
inside a word nor a possessive s's: most are the apostrophe of the Roarin'
Twenties, feet marks on room sizes, or a double read as a pair of singles
(19 sit next to another mark). Read on the page images:

- **Real single quotes** around a word in the chapters' prose, printed 22
  and printed 33, each read on the image.
- **On the character pages** every lone single read on the image was half
  of a double: printed 5 (Iron Fist's text), printed 61 (Shroud's) and
  printed 62 (the Werewolf's).

So a single mark may be real, and a lost closing single on a character page
is a `text` override, never a rule (as `ma1.md` *Quote marks*). The data
row confirms the count on the character pages, where `npcs.unpaired` stops
on an odd double.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with the MX1 family's
fields and ten things taught to it.** Measured, not argued: a scratch copy
of `scripts/msh/` and `apps/marvel-heroes/data` at `e8c5195b` (`main`'s
scripts at `1c871815` plus this entry), the entry given
`"layout": "grid-booklets"`, run on a copy of the cache under its own
`WORKSHOP_MSH_CACHE` (no page re-OCR'd; only grid crops were added, to the
copy). `code-grids` (MA4's) was not tried, since this one fits.

- **Stock, `layout` alone:** it runs to the end and exits 1. 46 entries,
  43 blocks, **none passing**: every grid's Health and Karma lines carry the
  next rows' text (number-then-code rows read nothing), 32 entries are named
  by their identity line, and four chapter grids and Bartholomew Jacobs have
  no block.
- **Stock, with the MX1 family** (`code_rows`, `card_headers` with the 38
  headers as `cards`, `title_case_labels`, `teams`): exit 1. 46 entries, 43
  blocks, 36 passing, 7 failing.
- **With the registry workarounds and reader changes below:** exit 1, on one
  line: `CHECKLIST NAME WITH NO ENTRY: Bartholomew Jacobs` (reader item 7,
  not applied).

| measure | trial, last run |
|---|---|
| entries | 52: 44 with a block, 8 without (The Player Characters, Non-Player Character Factions and its six subheads) |
| stat blocks | 47 of the book's 48, every value as *Stat blocks* lists it; Bartholomew Jacobs's is the one missing |
| blocks passing every check | 41, and 6 known from trial overrides (3 `misprint`, 3 `as_printed`): the survey's six, each matching one block; failing 0 |
| powers | 96 across 32 entries (every card but Pride, Mr. Maximilian, who prints none) |
| checklist | 38 cards, 11 tiers and 7 opponents, all found but Bartholomew Jacobs |
| exit code | 1 |

The overrides are the survey's (decisions 5 and 6) written for the trial
only, not re-read on the images; the data row writes the real file. The
zombie's is matched by its codes, since the Black Talon's three blocks
share his header.

**Registry-only workarounds** (no reader change; each worked in the trial):

1. **The MX1 family.** `code_rows` reads `F IN (40)`: MX1's
   `ROW_TITLE_CASE` is case-free, so capitals read too. `card_headers` with
   the 33 cards and 5 faction grids as `cards` names every entry by its
   header, not its identity line. `title_case_labels` raises `Talents:`,
   `Background:`, `Weaknesses:`, `Weaponry:` and `Abilities:`. `teams` as
   decision 1. 0 passing became 36.
2. **Specks and marks, as MX3 and ME3.** `code_row_specks` reads Johnny
   Bifrost's P (`.TY`, printed 52), whose grid was unread;
   `trailing_marks` strips a mark after Mister Fear's Karma (`40 -`, printed
   59). `code_rows_end_at_popularity` was set with them, as MX3's, and not
   measured alone.
3. **`speck_lines`:** Iron Fist's header reads `lron Fist` (printed 5), so
   his entry was named by his identity line.
4. **`extra_titles` for the six faction subheads** (The Faces of Fear, The
   Maggia, The Crimson Smiles Gang on printed 7; The Flashing Blades Gang,
   The Buzz Cuts Gang, Contacts and Other NPCs on printed 8), so each
   faction's introduction is a heading entry of its own and not the notes of
   the grid above it (the Typical Batboy's notes went from 209 words to 72,
   his Weaponry alone). Needs reader item 6.
5. **`opponent_section_labels`** `{"ABILITIES": "notes", "WEAPONRY":
   "notes"}`: an opponent's entry ends at a run-in that is not one of its
   sections, so Jack the Bartender's and Security Officers' `Abilities:` and
   `Weaponry:` and SWF Operatives' `Weaponry:` were dropped. Which section
   `Abilities:` belongs in is the data row's.
6. **`grids_end_at_p` and `derived_totals`**, the fields reader items 4 and
   5 sit behind.
7. **The misprints and printed-on-purpose values**: overrides, as above.

**What the reader must learn: ten things**, the first six applied in the
trial (`gridbooks.py` 35 lines, `roster.py` 2, `codegrids.py` 1), the last
four not:

1. **The column's top.** `stream_of` drops every word above 10% of the page
   height, and this book sets a column's first line at 9.6-10% (y 306-319 of
   3197). The headers of Gypsy Moth (printed 57) and Mentallo (printed 58)
   were lost, each entry named by its identity line, and words of a
   column's first line are cut on 15 booklet pages, the Typical Crimson
   Smile's `Weaponry:` label among them (printed 8). The trial reads a
   registry `body_top` of 0.09; no word of any booklet page lies between 7%
   and 9.6%.
2. **`Sh-0` as a code-first row's code** (the Black Talon's zombie and
   skeleton, printed 53). `codegrids.CODE` reads `Shift 0`, not `Sh-0`, so
   both grids were unread.
3. **A dash hard against a number** (the Fixer's Health `32-`, printed
   56). `trailing_marks` wants a space before the mark.
4. **A code-first grid with no Popularity and its row letters lost**
   (Security Officers, printed 36; the Alligator, printed 42), **or no
   Karma either** (Rat, pack of 10 and Mosquito Swarm, printed 42).
   `roster.grid_at` wants a Popularity line, and `grids_end_at_p` finds the
   P row by its letter and reads number-then-code rows, so two grids had no
   entry and two no rows. The trial crops seven row pitches down and reads
   the rows with `codegrids`' row; a crop at 6.9 pitches cut the Mosquito
   Swarm's P `(2)`, read as `(9)`.
5. **Karma derived for a vertical grid** (the chapter 31 three, decision
   7). `derived_totals` derives only a one-line grid's; the trial gives the
   same `derived` flag to a block that prints no Karma.
6. **An extra title in its printed case.** The factions' list on printed 7
   names each faction again, a dash and the name in lower case, and
   `roster.norm` folds case, so `extra_titles` finds each twice and the
   build stops. The trial keeps the line printed in the title's own case,
   under MX2's `subhead_exact_case`.
7. **Bartholomew Jacobs** (printed 40): three rows, R, I and P, with
   `Karma:` beside R, no header and no Health. `roster.ANCHOR` is a Health
   line, so there is no grid and no entry. Needs a grid read at a Karma
   line, a name for it (`grid_headers` keys on a Health) and F, A, S and E
   null, as the `rows` override does for ME1's Oolafat once a block exists
   (decision 8). Not applied.
8. **A grid inside a card that is a card of its own** (decision 4). The
   Black Talon's zombie and skeleton read as his second and third blocks.
   `one_line_grids`' `host` gives a one-line grid an entry of its own;
   nothing does that for a vertical grid. Not applied. The Werewolf's human
   statistics, a second block on his card, need only a `label` override.
9. **The text after a grid inside a card falls to the entry's prose**: the
   Black Talon's (337 words, the rest of his Necromancy power) and the
   Werewolf's (153 words, the run-in Claws among them), not their powers.
   Not applied.
10. **The Whirlwind's `Weaponry:`** (printed 63) is a power under
    `KNOWN POWERS:`, but `title_case_labels` raises it as a section label,
    because the faction grids print it as one; it reads as 82 words of notes
    and his powers list Spinning alone. Not applied.

Read and fine as it is: the Player Characters' and the roster's grids read
from their crops, the second card on a page included; Spider-Man's
Popularity `30/6`; the Sentinels, Mark IV's `NA` values; Callisto's and
Tatterdemalion's `FE`; Frankenstein's Monster's `None`; the Werewolf's human
statistics as a second block; every identity line, Johnny Bifrost's and
Pride's none. Not a reader matter: a printed minus reads as an em dash
(`-10` as a dash and 10), which `npcs.py` folds already; a stray `q` after
the Typical Flashing Blade's Talents and a speck after Blacklash's identity
line are `text` verdicts for the data row.

The entry still sets no `layout`: that is the parser row's to write, with
items 1-10 behind the registry and every earlier book's build proved
byte-identical. The scratch registry patch, the trial overrides, the three
reader diffs (CRs stripped) and the last run's output are kept in the plan
store, `trial\mla1\`.

## Decisions this survey leaves open

Each has a recommendation, the one MX1 and MT3 took where they had the
same question (Nate 2026-10-31: take the survey's recommendations).
Already ruled: characters only (Nate, 2026-10-21), second cards with
`-mla1` ids (2026-09-28) and a leading The dropped from a name
(2026-10-21).

1. **Teams.** Recommendation: **After Midnight Heroes** for the six Player
   Characters (as MT3's Revenge of Kang Heroes and MT2's Weird, Weird West
   Heroes), and every other card, the faction grids, the roster and the
   chapters' grids, under the book's title, **MLA1 After Midnight** (as
   MX1 and MT3 filed theirs). Not taken: a team per faction subhead, five
   teams of one grid each; the faction stays in the grid's name.
2. **Page citations.** Recommendation: MX1's single-booklet shape,
   `MLA1 Adventure p.59` (the part's `cite` is `Adventure`).
3. **Names as printed** (recommended, as MT3 decision 13 and ME2's
   `Olympian, Typical`): the roster's inverted headers kept
   (`Bifrost, Felicia`, `Bifrost, Johnny`, `Pride, Mr. Maximilian`,
   `Sentinels, Mark IV`), and `Rat, pack of 10` as printed. Not taken:
   uninverting them, or MT2's `count_headers` for the rats, which reads a
   count in parentheses, not after a comma.
4. **The grids inside cards** (recommended, as MT3 decisions 4 and 13): the
   Werewolf's human statistics a second block on his card, labelled **Jack
   Russell** (as MT3's Ben and MT2's Hamilton Slade); the Black Talon's
   zombie and skeleton each a card of its own, **Black Talon's Zombie** and
   **Black Talon's Skeleton**, filed with the Black Talon (as MT3's Mad
   Thinker's Android). Not taken: blocks on the Black Talon's card, since
   they are beings he raises, not a form of him.
5. **The misprints** as `misprint` overrides keeping printed and corrected
   (recommended, as MT3 decision 7): the Typical Buzz Cut's Karma 11 to 12,
   Eel's 22 to 32 and Tatterdemalion's 8 to 12, each the total corrected
   because every row's code and number agree. `as_printed`: the zombie's
   Health 80 (the Necromancy rule) and the Sentinels, Mark IV's `NA`
   Karma, Resources and Popularity (a robot, as MX1's sentinels' `Karma =
   0`).
6. **The Typical Flashing Blade's A 12 and E 7**, the two numbers inside a
   rank's range but not its standard. Recommendation: one `as_printed`
   override on its A with the E in its `also` (both in range, and its
   Health 31 holds on them), as MX1 decision 5 kept one value in one
   block. Not taken: `rank_ranges` for the book, which ME2 took for
   twenty-seven values.
7. **Totals a chapter grid does not print** (recommended, as MT3 decision
   10): the Alligator's, Rat, pack of 10's and Mosquito Swarm's Karma
   derived, R+I+P = 6 each, flagged as not printed. Security Officers'
   Resources and Popularity left unset, as MX1's codes-only grids print
   neither. Not taken: the three Karma left unset, which leaves cards the
   GM tools cannot play.
8. **Bartholomew Jacobs** (recommended, as MT3 decision 3, every grid a
   card): a card with his R, I, P and Karma 115 as printed, and F, A, S, E
   and Health unset, since the book gives him the possessed hero's. Not
   taken: no card, as MT3 decision 11 for beings statted by reference only,
   since this one prints three rows of his own. If the reader cannot carry
   a block with four rows absent, row 10c says so.
9. **Spider-Man's Popularity 30/6** kept as printed, the card showing both
   values (recommended).
10. **Characters only.** The Hypnoporter Machine, the faction and chapter
    gear, the floor plans and the map sheet are not imported (Nate,
    2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mla1 --probe
python scripts/msh/ocr-book.py mla1
python scripts/msh/survey.py mla1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-250 dpi into the scratchpad.
