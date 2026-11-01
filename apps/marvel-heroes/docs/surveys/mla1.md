# Survey: MLA1 After Midnight (TSR6892)

> **DRAFT.** Written through the stat blocks of the Player Characters, the
> factions and the Non-Player Character Roster from Arclight to Mentallo
> (plan row 10a). The rest of the roster, the chapters' grids, *Names the
> Codex already has*, *Quote marks*, *Which reader fits* and *Decisions*
> are not finished.

Marvel Super Heroes Official Game Adventure, Anthony Herring, 1990, the
first module of the Gang Wars trilogy (the MLA series). Registry entry:
`scripts/msh/books.json` -> `mla1`. Measured 2026-11-01.

**Rows citing this book:** none yet (no data is built).

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
  second shape (code then number in brackets) with MT3's capital codes. **No
  horizontal one-line grid** on the pages read.
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
  and no powers or background.
- **Ranks.** FE (Callisto's Resources), PR, TY, GD, EX, RM, IN, AM and MN,
  and `Sh-0` for the R, I and P of the Black Talon's zombie and skeleton
  (printed 53). Resources prints `NA` on those two and `None` on
  Frankenstein's Monster (printed 56). No book-specific spelling. Marks on
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
to the top of printed 59, column 1, where Mister Fear's card starts under it:
his card is the next row's. Printed 58 holds Harpoon and Mentallo only. **The Black
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

**The misprints so far, each read on the page image** (printed page: name:
field printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 8:Typical Buzz Cut:Karma 11 -> 12 | R, I and P each print `PR (4)`, and every row's code agrees with its number; 4+4+4 is 12, and its Health 28 holds |
| 55:Eel:Karma 22 -> 32 | R `EX (20)`, I `TY (6)`, P `TY (6)`, each code agreeing with its number; 20+6+6 is 32. The alternative, R `GD (10)` for 22, would change a row whose code and number agree, so the Karma is the misprint (the Decisions' to confirm, not finished) |

**Printed on purpose:** the Black Talon's zombie prints `Health: 80` over
four `RM (30)` rows (F+A+S+E is 120). His Necromancy text gives a zombie's
Health as his own Power rank number, and states that number as 80; the
skeleton's Health is half of it, 40, which F+A+S+E also gives. So the
zombie's 80 is the book's rule, an `as_printed` with that reason, not a
misprint.

**Noted, not a block:** Hammerhead's text (printed 58) gives a second
Health for him while a device is worn; it is prose, not a grid.

## The rest of the roster and the chapters' grids

Not finished (plan row 10b): the roster from Mister Fear to Whirlwind
(printed 59-63, PDF 60-64; Mister Fear's header is in column 1 of printed
59, under the end of Mentallo's text) and the grids inside the chapters (PDF 19, 33,
37, 41 and 43, printed 18, 32, 36, 40 and 42).

## Names the Codex already has

Not finished (plan row 10b).

## Quote marks

Not finished (plan row 10b).

## Which reader fits

Not finished (plan rows 10b and 10c).

## Decisions this survey leaves open

Not finished (plan row 10b). Already ruled: characters only (Nate,
2026-10-21), second cards with `-mla1` ids (2026-09-28) and a leading The
dropped from a name (2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mla1 --probe
python scripts/msh/ocr-book.py mla1
python scripts/msh/survey.py mla1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-250 dpi into the scratchpad.
