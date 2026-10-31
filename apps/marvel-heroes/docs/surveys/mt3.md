# Survey: MT3 The Revenge of Kang (TSR6891)

> **DRAFT.** Written through every stat block of the book (plan rows 10a
> and 10b), and *Which reader fits* from the trial parse (plan row 10c).
> Not yet run through the Marvel smoke suite.

Marvel Super Heroes Official Advanced Game Adventure, Ray Winninger, 1989,
the third module of the Time Warp series. Registry entry:
`scripts/msh/books.json` -> `mt3`. Measured 2026-10-30.

**Rows citing this book:** none yet (no data is built).

Everything here was measured and read on the page images.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 68 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 characters on
  every page), cached 2026-10-30 into the main checkout's
  `.cache/msh/books/mt3/` (68 pages OCR'd).
- **The booklet is 64 pages** (PDF 3-66). The print is clean, and the
  grids' codes and numbers OCR well; the rank rows' letters less so (`|`
  for I, `S$` and `S_` for S, `FIN` and `RIN` for an F or R row whose code
  is IN), and marks hang between code and number (`RM _ 30 _~`).
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 596 x 776 | Cover (outside front; MT3 and product code 6891) | - |
| 2 | 594 x 767 | Map: Main Complex (Levels 1 and 2), Kang's Fortress (Levels 1 and 2), Pocket Dimension Map | - |
| 3-66 | 594 x 767 | Adventure Book | 1-64 |
| 67 | 596 x 776 | Back cover (product code 6891) | - |
| 68 | 2231 x 1491 | Map sheet: X-Men Mansion, Pocket Dimension Map, Well of Pain, Wong Chu's Camp, Kang's Basement Hideout, Aerodyne, Inc. (product code 6891XXX0701) | - |

**PDF 2** is booklet-sized and prints no folio; the booklet is 64 pages
without it (a booklet's page count is a multiple of four), so it is the
inside of the cover or a leaf of its own, which the scan does not show.
**PDF 66** is printed 64 by position: a page of comic panels whose speech
balloons are empty in the scan, with no folio. Neither prints a statistic.
None of the three map pages is imported.

## Offset

`survey.py` votes **printed = PDF - 2 on 55 pages** (PDF 9-65 but 11),
and no booklet page disagrees. Three votes are not folios, each read on its
page:

- PDF 7 (k = 4): a `3` in a sentence at the foot of column 1; the page
  prints 5.
- PDF 11 (k = 1): the `10` of the Invisible Girl's R row at the foot of
  column 2; the page prints 9.
- PDF 68 (k = 67): a digit on the map sheet.

Seven more booklet pages print their folio, PDF - 2, on a strip of each
page's foot, Tesseract missing it: PDF 4-8, 10 and 11. Printed 1 (PDF 3) is
the title page, with the Contents, the credits and the fine print, and
prints no folio; printed 64 (PDF 66) prints none either. Every other booklet
page prints its folio. So `parts`, as MT2 and MH9, with the cover, the map
page, the back cover and the map sheet as parts of their own with `offset`
null.

## The book's own authority lists

**Contents (printed 1).** Transcribed from a render, then each entry checked
against its banner or subhead on the page. **Every entry agrees with its
page**, so there are no `contents_errata`. Stored as `sections`, the
sub-entries under their section. The planner's reading put The Player
Characters at printed 3; the Contents prints 4, and its subhead is on
printed 4.

| printed | Contents entry |
|---|---|
| 2 | Introduction |
| 4 | The Player Characters |
| 6 | Non-Player Characters: Friendly NPCs (6), Enemy NPCs (13) |
| 17 | Chapter 1: Something Rotten in Manhattan |
| 19 | Chapter 2: A Strange New World |
| 21 | Chapter 3: Across the Bay |
| 22 | Chapter 4: Through the Swamp |
| 22 | Chapter 5: Up the Spire |
| 25 | Chapter 6: The Ko-Kri Tribunal |
| 26 | Chapter 7: The Test of Skill |
| 27 | Chapter 8: The Great Escape |
| 27 | Chapter 9: The Test of Wisdom |
| 28 | Chapter 10: Return to the Spire |
| 30 | Chapter 11: The Test of Courage |
| 34 | Chapter 12: The Well of Pain |
| 35 | Chapter 13: The First of Many Kangs |
| 37 | Chapter 14: The Uncanny X-Men |
| 39 | Chapter 15: The Fantastic Four |
| 40 | Chapter 16: Getting Into Aerodyne |
| 41 | Chapter 17: A Touch of Gray |
| 41 | Chapter 18: Back to School |
| 42 | Chapter 19: Lunch Time |
| 43 | Chapter 20: Big Man on Campus |
| 44 | Chapter 21: Peter Parker |
| 45 | Chapter 22: The Big Dance |
| 45 | Chapter 23: Again, Kang |
| 46 | Chapter 24: The Man Without Fear |
| 47 | Chapter 25: Down Through the Alley |
| 48 | Chapter 26: Title Fight |
| 50 | Chapter 27: Good Afternoon, Mister Tyler |
| 51 | Chapter 28: The Nam |
| 52 | Chapter 29: Mister Stark, I Presume |
| 53 | Chapter 30: Wong Chu's Camp |
| 54 | Chapter 31: Yet Another Kang |
| 55 | Chapter 32: The Master Kang |
| 57 | Chapter 33: Here Comes the Bride |
| 60 | Chapter 34: A Brave, New World |
| 61 | Chapter 35: The House of Ideas |
| 61 | Chapter 36: Kleinberg's Penthouse |
| 62 | Chapter 37: The Supreme Kang! |
| 63 | Chapter 38: Wrapping It All Up |

- **The banners.** Every chapter's is a white-on-black bar across the page,
  printed `N: TITLE` in capitals with no word Chapter. Twenty-four are at
  the top of their page; fourteen open mid-page: Chapters 5, 9, 10, 18-21,
  23-26, 28, 29 and 36. Each was found on its page image (a 50 dpi strip of
  every page's top, and the mid-page ones on their page), and each prints
  the Contents' number and title.
- **Tesseract reads none of the 38 chapter banners.** The OCR of printed
  17-63 holds `Chapter N` only inside sentences. A reader that finds a
  chapter by its banner's words will find nothing here.
- **The character sections' heads are subheads, not bars**: INTRODUCTION
  (printed 2, top of column 1), The Player Characters (printed 4, bold
  title case at the foot of column 1), NON-PLAYER CHARACTERS (printed 6,
  column 1, in capitals), Friendly NPCs (printed 6, column 1, title case)
  and ENEMY NPCs (printed 13, column 1, capitals). Tesseract reads all
  five.
- **Inside Friendly NPCs**, a bold title-case subhead The X-Men (printed 6)
  opens the X-Men, and four capital subheads close a team's or a hero's
  cards with notes on their part in the adventure: THE X-MEN IN THE
  ADVENTURE (printed 9, with a colon), THE FANTASTIC FOUR IN THE ADVENTURE
  (printed 11, over two lines), SPIDER-MAN IN THE ADVENTURE (printed 11) and
  DAREDEVIL IN THE ADVENTURE (printed 12). None is in the Contents, and
  none is a character.
- **No index.** The coverage checklist will be this survey's list.

## Columns, labels and ranks

- **Three columns** on every booklet page read (printed 4-16, and the
  chapter pages of printed 17, 28, 43, 44, 47, 52 and 61), a block's rank
  rows and its labels as two sub-columns of one column. A grid can break
  across columns: the Invisible Girl's rows I and P (printed 9) and the
  Human Torch's rows A-P (printed 10) are at the top of the next column,
  and Peter Parker's non-powered rows R-P (printed 11) at the top of
  column 2.
- **One block shape** on printed 4-16: a header in capitals, an identity
  line under most, then seven rows of letter, rank CODE, number, no
  parentheses (`F RM 30`), with `Health:`, `Karma:`, `Resources:` and
  `Popularity:` to the right on rows F, S, R and P, Resources as a code and
  its number in brackets (`PR(4)`). This is MT2's first shape. The Moon
  Knight and the Mandarin blocks print `Res:` for Resources.
- **Headers.** All 29 are capitals. The Player Characters' (THE VISION,
  MOON KNIGHT, THE SCARLET WITCH) carry an `alias` line under two of them
  (alias Marc Spector, alias Wanda). **The Non-Player Characters' headers
  are capitals too**, where MT2's are title case, each with a real name in
  bold title case under it but for Marty Jenkins, Ko-Kri, the Super-Skrull,
  the Mad Thinker, the Mandarin and Attuma; Kang's is Kang the Conqueror.
  KO-KRI (Typical) carries its note in title case inside the brackets.
- **Second forms** are a bold title-case line over a second grid, in the
  same column: Ben (human form) under the Thing (printed 10), Peter Parker
  (Non-Powered Form) under Spider-Man (11), Matt Murdock (pre-accident)
  under Daredevil (11) and Tony Stark (without armor) under Iron Man (12).
  Moon Knight's two forms are one grid with two values on each row, under
  a line `Normal / Moonlight` (printed 5), as in MT2.
- **Section labels**, counted on the OCR of printed 4-16 and read on the
  images of printed 6, 13 and 14: `KNOWN POWERS:` in capitals (27 of the
  29 headers; Marty Jenkins prints none, and Kang prints `Known Powers` in
  bold title case with no colon), and `Talents:` (25), `Contacts:` (16,
  all on printed 4-13) and `Background:` (28) as bold run-ins; the Human
  Torch adds `Weakness:` (printed 10). Marty Jenkins's text (printed
  12-13) is prose with no label. Each power is an italic run-in under
  KNOWN POWERS.
- **Ranks.** The labelled blocks print codes in capitals: FE, PR, TY, GD,
  EX, RM, IN, AM, MN and UN (the Executioner's Endurance, printed 14).
  Title case appears in Moon Knight's grid alone of the labelled blocks
  (his Moonlight F, `In 40`, and `Res: Rm(30)`, printed 5), and in two of
  the three one-line grids (below: Gd, Ex, Rm, In, Ty). No book-specific spelling (MA4's RE, MH9's
  GO) is in printed 1-16.
- **The chapters' grids** (printed 21-63) print every code in title case
  under its number: Fe, Pr, Ty, Gd, Ex, Rm, In, Am, and `Cl1000` for the
  fish's Endurance of 1000 (printed 21, read on the image), Class 1000 in
  `ranks.json`. So `rank_aliases` gains Fe, Pr, Am and Cl1000. No chapter
  prints a capital code or a book-specific spelling.
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1, 2, 67 and 68 holds no `Health`, `Karma` or rank
row, and their images show the cover, the back cover's blurb and two pages
of maps. So `panels` is empty, as MT2's and MH9's.

## Stat blocks: printed 1-16

Every block of printed 1-16 was read on a crop of the page image (110-220
dpi) and checked against the book's own arithmetic and
`apps/marvel-heroes/data/ranks.json`. Printed 1-3 (the title page and the
Introduction) hold none; the blocks are on printed 4-16.

**33 labelled grids**: 29 headers and 4 second forms.

| printed | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 4 | THE VISION | RM 30, EX 20, AM 50, IN 40, EX 20, GD 10, RM 30 | 140 | 60 | PR(4) | 30 |
| 5 | MOON KNIGHT, Normal / Moonlight | RM 30/In 40, EX 20/RM 30, EX 20/IN 40, EX 20/IN 40, GD 10/GD 10, EX 20/EX 20, **EX 30**/RM 30 | 90/150 | 60 | Rm(30), as `Res:` | 10 |
| 5 | THE SCARLET WITCH | GD 10, GD 10, TY 6, EX 20, GD 10, EX 20, RM 30 | 46 | 60 | TY(6) | 30 |
| 6 | CYCLOPS (Scott Summers) | EX 20, EX 20, TY 6, RM 30, EX 20, RM 30, EX 20 | 76 | 70 | GD(10) | 6 |
| 6 | THE BEAST (Hank McCoy) | IN 40, IN 40, RM 30, EX 20, EX 20, GD 10, EX 20 | 130 | 50 | RM(30) | 0 |
| 7 | ANGEL (Warren Worthington III) | EX 20, RM 30, GD 10, RM 30, GD 10, TY 6, GD 10 | 90 | 26 | RM(30) | 12 |
| 7 | ICEMAN (Bobby Drake) | GD 10, GD 10, TY 6, RM 30, GD 10, PR 4, TY 6 | 56 | 20 | TY(6) | 16 |
| 8 | MARVEL GIRL (Jean Grey) | GD 10, GD 10, PR 4, RM 30, GD 10, EX 20, AM 50 | 54 | 80 | GD(10) | 20 |
| 8 | PROFESSOR X (Charles Xavier) | PR 4, GD 10, TY 6, RM 30, IN 40, AM 50, MN 75 | 50 | 165 | RM(30) | 20 |
| 9 | MISTER FANTASTIC (Reed Richards) | GD 10, TY 6, TY 6, EX 20, AM 50, EX 20, RM 30 | 42 | 100 | RM(30) | 50 |
| 9 | INVISIBLE GIRL (Sue Storm) | GD 10, GD 10, TY 6, EX 20, GD 10, EX 20, GD 10 | 46 | 40 | RM(30) | 50 |
| 10 | THE THING (Benjamin Grimm) | IN 40, GD 10, MN 75, MN 75, GD 10, GD 10, RM 30 | 200 | 50 | RM(30) | 10 |
| 10 | Ben (human form) | EX 20, GD 10, GD 10, GD 10, GD 10, GD 10, RM 30 | 50 | 50 | RM(30) | 10 |
| 10 | THE HUMAN TORCH (Johnny Storm) | GD 10, EX 20, GD 10, EX 20, GD 10, GD 10, TY 6 | 60 | 26 | RM(30) | 50 |
| 11 | SPIDER-MAN (Peter Parker) | RM 30, AM 50, IN 40, IN 40, EX 20, GD 10, IN 40 | 160 | 70 | TY(6) | 20 |
| 11 | Peter Parker (Non-Powered Form) | TY 6, TY 6, TY 6, TY 6, EX 20, GD 10, EX 20 | 24 | 50 | PR(3) | 0 |
| 11 | DAREDEVIL (Matt Murdock) | IN 40, IN 40, GD 10, EX 20, TY 6, MN 75, GD 10 | 110 | 91 | EX(20) | 10 |
| 11 | Matt Murdock (pre-accident) | GD 10, GD 10, GD 10, GD 10, TY 6, GD 10, GD 10 | 40 | 26 | TY(6) | 10 |
| 12 | IRON MAN (Tony Stark) | GD 10, PR 4, RM 30, IN 40, IN 40, EX 20, TY 6 | 84 | 66 | IN(40) | 20 |
| 12 | Tony Stark (without armor) | TY 6, TY 6, PR 4, TY 6, IN 40, EX 20, TY 6 | 22 | 66 | IN(40) | 20 |
| 12 | MARTY JENKINS | PR 4, TY 6, TY 6, TY 6, TY 6, TY 6, TY 6 | 22 | 18 | GD(10) | 5 |
| 13 | KANG (Kang the Conqueror) | TY 6, GD 10, RM 30, IN 40, IN/AM 40/50, TY/RM 6/30, GD/IN 10/40 | 86 | `Varies` | MN(75) | -30 |
| 13 | KO-KRI (Typical) | GD 10, GD 10, GD 10, IN 40, TY 6, EX 20, AM 50 | 70 | 76 | **PR(6)** | 0 |
| 14 | SUPER-SKRULL | RM 30, EX 20, AM 50, AM 50, TY 6, TY 6, GD 10 | 150 | 22 | FE(2) | 0 |
| 14 | MAD THINKER | TY 6, TY 6, TY 6, TY 6, AM 50, TY 6, TY 6 | 24 | 62 | RM(30) | 7 |
| 14 | EXECUTIONER (Skurge) | MN 75, EX 20, AM 50, UN 100, GD 10, TY 6, EX 20 | 245 | 36 | GD(10) | -20 |
| 15 | THE UNICORN (Milos Masaryk) | RM 30, EX 20, IN 40, IN 40, TY 6, EX 20, FE 2 | 130 | 28 | GD(10) | -15 |
| 15 | MELTER (Bruno Horgan) | GD 10, TY 6, TY 6, GD 10, EX 20, TY 6, TY 6 | 32 | 32 | EX(20) | -20 |
| 15 | MANDARIN | RM 30, EX 20, GD 10, RM 30, IN 40, GD 10, GD 10 | 90 | 60 | **AM(30)**, as `Res:` | -12 |
| 15 | BLACK KNIGHT (Nathan Garret) | EX 20, EX 20, GD 10, GD 10, GD 10, TY 6, PR 4 | 60 | 20 | EX(20) | -5 |
| 16 | ELECTRO (Maxwell Dillon) | GD 10, EX 20, EX 20, AM 50, GD 10, EX 20, TY 6 | 100 | 36 | TY(6) | -12 |
| 16 | THE BEETLE (Abner Jenkins) | GD 10, GD 10, RM 30, EX 20, EX 20, RM 30, TY 6 | 70 | 56 | EX(20) | -10 |
| 16 | ATTUMA | IN 40, GD 10, MN 75, AM 50, TY 6, TY 6, EX 20 | 175 | 32 | EX(20) | -20 |

The three Player Characters are the Contents' (printed 4-5); the fourteen
Friendly NPCs are on printed 6-13 (the X-Men, the Fantastic Four,
Spider-Man, Daredevil, Iron Man and Marty Jenkins), and the twelve Enemy
NPCs on printed 13-16. Moon Knight's one grid carries his two forms in two
columns of values; the Moonlight form's Health is the second.
**Kang prints two ranks on each of R, I and P** (`IN/AM 40/50`,
`TY/RM 6/30`, `GD/IN 10/40`) and `Karma: Varies`: R+I+P is 56 on the first
values and 120 on the second.

**Three one-line grids inside these blocks**, each the seven letters over
its values, with no header of its own:

| printed | inside | what | values | Health | Karma |
|---|---|---|---|---|---|
| 14 | Mad Thinker | his android | codes only: GD GD AM RM FE FE FE | 100 | 6 |
| 15 | Black Knight | his winged horse | 10 Gd, 20 Ex, 30 Rm, 40 In, 6 Ty, 10 Gd, 6 Ty | not printed (100 by F+A+S+E) | not printed (22 by R+I+P) |
| 16 | Attuma | his sea minions | codes only: Ex Ex Rm Rm Ty Ty Ty | 100 | 18 |

The android's codes are capitals and the minions' title case; both print
`Health:` and `Karma:` on lines under the codes. The horse's grid is
MT2's, printed the same way.

**The book checks itself.**

| measure | count |
|---|---|
| labelled grids, Health = F+A+S+E | **34 of 34** (Moon Knight's in both forms) |
| labelled grids, Karma = R+I+P | **33 of 33** that print a number (Moon Knight's in both forms); Kang prints `Varies` |
| every ability number within its rank code's range | **33 of 34**: Moon Knight's Normal P is not |
| every Resources number within its code's range | **31 of 33**: Ko-Kri's and the Mandarin's are not |
| a number inside its range but not the rank's standard | **one**: Peter Parker's non-powered Resources PR(3), Poor's lowest number (`ranks.json` `initial`) |
| one-line grids, Health and Karma both hold | **2 of 2** that print them (both on standard numbers); the horse prints neither |

**The misprints in printed 1-16, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Moon Knight, printed 5 | `P EX 30` (Normal form) | 30 is Remarkable (Excellent is 16-25); Karma 60 = 10+20+30 agrees with the 30, and the Moonlight form prints `RM 30`, so the code is the misprint: RM |
| Ko-Kri (Typical), printed 13 | `Resources: PR(6)` | 6 is Typical (Poor is 3-4). Resources enters no total, so the arithmetic does not say which half is wrong |
| Mandarin, printed 15 | `Res: AM(30)` | 30 is Remarkable (Amazing is 46-62). The same: no total settles it |

Two other books bear on these. MT2's Moon Knight (printed 4 there) is the
same block with `P RM 30`, so its RM agrees with the correction. MH7's
Mandarin (printed 15 there) prints Resources as the word Amazing, which
backs this block's code AM over its 30. Nothing else cards Ko-Kri.

As `page:name:field printed->corrected`: `5:Moon Knight:P (Normal) EX->RM`,
`13:Ko-Kri:Resources PR(6)` (left as printed, decision 8) and
`15:Mandarin:Resources AM(30)->AM(50)` (decision 8).

## The chapters' grids and named blocks (printed 17-63)

Every chapter page, printed 17-63, was looked at on a 45 dpi render, and
the OCR of each was searched for a row of rank codes, a row of the seven
letters, `Health:` and `Karma:`. Both found the same **twelve grids on
eleven pages**, and each was then read on a crop of the page image (130
dpi). The other `Health` and `Karma` lines of printed 18, 21, 26, 32, 36,
38, 48, 49, 53, 55, 57 and 59 are prose (damage, Karma awards), not
blocks. **No chapter prints a named block** of the first shape (letter,
CODE, number, labels to the right), and no grid prints a name line.

**Twelve one-line grids**, each the seven letters, a row of numbers, a row
of title-case codes under them, then `Health:` and `Karma:` on lines of
their own or on one line. This is MT2's chapter shape. Each is named here
by what its prose calls it (decision 3).

| printed | column | name (from the prose) | F A S E R I P | Health | Karma |
|---|---|---|---|---|---|
| 21 | 1, foot | Fish (Chapter 3) | 6 Ty, 4 Pr, 50 Am, 1000 Cl1000, 2 Fe, 2 Fe, 2 Fe | 1060 | 6 |
| 21 | 3 | Giant Insect (Chapter 3, living inside the fish) | 10 Gd, 6 Ty, 10 Gd, 10 Gd, 2 Fe, 2 Fe, 2 Fe | 36 | 6 |
| 22 | 2, top | Alligator Creatures (Chapter 4, a pack) | 10 Gd, 20 Ex, 10 Gd, 20 Ex, 2 Fe, 2 Fe, 2 Fe | 60 | 6 |
| 33 | 1, top | Snakes (Chapter 11, ten to an area; introduced at the foot of printed 32) | 10 Gd, 10 Gd, 2 Fe, 6 Ty, 2 Fe, 6 Ty, 2 Fe | 28 | not printed (10 by R+I+P) |
| 34 | 2 | Scorpions (Chapter 12; the prose puts the word in double quotes) | 10 Gd, 10 Gd, 10 Gd, 10 Gd, 2 Fe, 10 Gd, 6 Ty | not printed (40 by F+A+S+E) | not printed (18 by R+I+P) |
| 46 | 2 | Battle Robots (Chapter 23, two, the Kang duplicate's) | 20 Ex, 20 Ex, 30 Rm, 40 In, 6 Ty, 6 Ty, 6 Ty | **90** | 18 |
| 47 | 3, foot | Thugs (Chapter 25, with baseball bats) | 6 Ty, 6 Ty, 6 Ty, 10 Gd, 4 Pr, 6 Ty, 6 Ty | 28 | 16 |
| 49 | 2, top | Mike Franklin (Chapter 26, the boxer) | 30 Rm, 30 Rm, 20 Ex, 40 In, 6 Ty, 6 Ty, 2 Fe | 120 | **18** |
| 50 | 2 | Tom Tyler (Chapter 27; the prose names him Tom Tyler on printed 49) | 30 Rm, 20 Ex, 20 Ex, 30 Rm, 10 Gd, 6 Ty, 2 Fe | 100 | **22** |
| 56 | 1, top | Security Robots (Chapter 32, four; introduced at the foot of printed 55) | 30 Rm, 20 Ex, 30 Rm, 40 In, 6 Ty, 4 Pr, 4 Pr | 120 | 14 |
| 62 | 2, foot | Battle Robots (Chapter 37, eight, the Supreme Kang's) | 30 Rm, 30 Rm, 40 In, 30 Rm, 6 Ty, 6 Ty, 6 Ty | 130 | 18 |
| 63 | 1, foot | O'Malley (Chapter 38, in his augmented form) | 40 In, 40 In, 40 In, 40 In, 6 Ty, 6 Ty, 6 Ty | 160 | 18 |

- **After the grid**, the fish prints `Hide:`, the insect, the alligators
  and the snakes `Bite:`, the scorpions `Bite:` and `Chitinous Hide:`, the
  two battle robots `Armor:` and `Blasters:`, and the security robots
  `Armor:`, `Plasma Cannons:` and `Entwining Nets:`, each an italic run-in
  as a power is under KNOWN POWERS. The thugs, Franklin, Tyler and O'Malley
  are followed by prose. No chapter grid prints `KNOWN POWERS`, `Talents`,
  `Contacts` or `Background`.
- **OCR misreads**: the letter I as `|` on every grid, S as a section sign
  (printed 21, 22, 47, 50, 56 and 62), the fish's `Cl1000` as `Cli000`, and
  a mark before the robots' last `Ty` (printed 46). Each value above is the
  image's.
- **Two grids print the same name.** The battle robots of Chapters 23 and
  37 are different grids (decision 3 names them apart).

**The book checks itself, in the chapters.**

| measure | count |
|---|---|
| Health = F+A+S+E | **10 of 11** that print it: Chapter 23's battle robots print 90, and 20+20+30+40 is 110 |
| Karma = R+I+P | **8 of 10** that print it: Franklin prints 18 (6+6+2 is 14) and Tyler 22 (10+6+2 is 18) |
| every number within its rank code's range | **12 of 12** (every grid prints number and code, and every pair agrees) |
| a number inside its range but not the rank's standard | none |

Franklin's and Tyler's Karma both miss by 4, and each would hold were its P
`6 Ty` rather than the `2 Fe` both print. Each P's number and code agree,
so by MT2's rule (Khan's Champion) the total is the misprint.

**No grid is repeated**, in the chapters or against printed 4-16. **Beings
statted by reference only**, to the Advanced Set's Judge's Book (typical
soldiers, printed 39 and 52-54; a typical thug, 60; a typical policeman,
61), to all-Typical ranks (bystanders, 18 and 57; tough guys, 43; a clerk,
60) or to a block of printed 4-16 (the Ko-Kri, 21; Kang's duplicates,
Chapters 13-37), print no rank row and are not here.

**The misprints, the whole book, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Moon Knight, printed 5 | `P EX 30` (Normal form) | 30 is Remarkable; Karma 60 agrees with the 30, and MT2's same block prints RM: RM |
| Ko-Kri (Typical), printed 13 | `Resources: PR(6)` | 6 is Typical; no total and no other book settles it (decision 8) |
| Mandarin, printed 15 | `Res: AM(30)` | 30 is Remarkable; MH7's Mandarin prints Amazing, so the number is the misprint: AM(50) (decision 8) |
| Battle Robots, printed 46 | `Health: 90` | F+A+S+E = 20+20+30+40 = 110; every number agrees with its code, so the total is the misprint |
| Mike Franklin, printed 49 | `Karma: 18` | R+I+P = 6+6+2 = 14; the same: the total |
| Tom Tyler, printed 50 | `Karma: 22` | R+I+P = 10+6+2 = 18; the same: the total |

As `page:name:field printed->corrected`: `5:Moon Knight:P (Normal) EX->RM`,
`13:Ko-Kri:Resources PR(6)` (as printed), `15:Mandarin:Resources
AM(30)->AM(50)`, `46:Battle Robots:Health 90->110`, `49:Mike
Franklin:Karma 18->14`, `50:Tom Tyler:Karma 22->18`.

**The whole book, counted:** 33 full blocks (the labelled grids of printed
4-16: 29 headers and 4 second forms) and 15 one-line grids (3 inside
blocks, on printed 14, 15 and 16; 12 in the chapters, on printed 21-63).

**Card pages and the chapters' grids.** Printed 4-16 are card pages: every
grid there is a character's, Attuma's text ends on printed 16, and Chapter
1's banner tops printed 17. The chapters' twelve grids are statted inside
the prose, on printed 21, 22, 33, 34, 46, 47, 49, 50, 56, 62 and 63. The
registry records them as MT2's entry does (`character_ranges` and
`opponents`, each with its `part`), because MT3's entry is a `parts` entry
and the chapters' grids are MT2's chapter grids in shape; which reader
takes them is *Which reader fits*.

## Names the Codex already has

Read from `apps/marvel-heroes/data/npcs.json`, 2026-10-30 (810 cards), each
the same person unless said:

| MT3 card | already carded by |
|---|---|
| Vision | MH2, MT2 |
| Moon Knight | MT2 (Marc Spector) |
| Scarlet Witch | MA1, MH2, MH9, MT2 (MH1's False Scarlet Witch is someone else) |
| Cyclops | MA1, MHSP1, MHSP2 |
| Beast | MA1, MHSP2 |
| Angel | MA1, MHSP2 (Warren Worthington III) |
| Iceman | MA1, MHSP2 |
| Marvel Girl | MA1 (Jean Grey) |
| Professor X | MA1, MHSP1, MH1, MHSP2 |
| Mister Fantastic | MHSP1, MA4, MHSP2, MH9, and MH3's Mr. Fantastic |
| Invisible Girl | MH3; MA4, MHSP2 and MH9 card Sue Storm as Invisible Woman |
| Thing | MHSP1, MA4, MH3, MHSP2, MH9 (MH9's Thing (Divergent Earth) is another Earth's) |
| Human Torch | MHSP1, MA4, MH3, MHSP2, MH9's Human Torch (Johnny Storm); not MA4's Human Torch I or MH9's Jim Hammond |
| Spider-Man | MHSP1, MHSP2, MH8, MH9 |
| Daredevil | MHSP2, MH4, MH9 |
| Iron Man | MHSP2 (Tony Stark); MHSP1's and MH7's Iron Man is James Rhodes, someone else |
| Kang | MHSP1, MH2 (and MH2's Kang's Minions) |
| Super-Skrull | MA4, MH2, and MH9's Super Skrull |
| Mad Thinker | MA4, MH9 (and their androids' cards: MA4's Mad Thinker's Awesome Android, MH9's Mad Thinker's Androids) |
| Executioner | MH6 (Skurge) |
| Melter | MH5 (Bruno Horgan) |
| Mandarin | MH7 |
| Black Knight | MT2's Black Knight (Nathan Garrett), the same block; MHSP2's and MH8's are Dane Whitman |
| Electro | MHSP2 (Maxwell Dillon) |
| Attuma | MA4, MH9 |

New: Marty Jenkins, Ko-Kri, the Unicorn, the Beetle, the Mad Thinker's
android, Attuma's minions and all twelve chapter grids. MT2's Scorpion is
MacDonald Gargan, not this book's scorpions. Each MT3 card is a card of its
own with a `-mt3` id (Nate, 2026-09-28).

## Quote marks

**The book prints single quotes of its own, but not in any text a card
takes.** The OCR of printed 1-64 reads a single mark at a word's edge in 76
places. Read on the page images:

- **Two real pairs of singles**, both nested inside dialogue in Chapter
  33's read-aloud box (printed 57, columns 1 and 3): a phrase and a
  sentence quoted inside a speech. Chapter prose is not imported.
- **Every mark on the card pages (printed 4-16) is a double quote**, a
  feet mark or a speck: the OCR's singles beside doubles round the Time and
  Space series (printed 13), the Supreme and Master Kang run-ins (13) and
  the power horn (15), Grant's (5) and Iceman's iced up (7) are doubles on
  the image; `(30')` and `1500'` (printed 6 and 9) are feet marks on the
  image, and the OCR reads the chapters' `16'`, `10,000'`, `500'` and the
  like the same way; and a mark the OCR hangs before `Popularity:` on the
  Spider-Man's P row (printed 11) is not on the block row 10a read on the
  image. The others on printed 4 and 16 pair as doubles in the OCR and were
  not read on the image.
- **The chapters' marks near a grid** (printed 46's battle robots, printed
  49's gym bag label, printed 62's message) are doubles on the image, and
  `'em` (printed 43) is an apostrophe.

So for the imported text MHSP1's rule (every single mark a misread) fits,
as it fits MT2, with one thing for the trial parse (row 10c) to check: a
feet mark after a number (`30'`, `1500'`) must stay a single mark and not
be paired into a double. It does (*Which reader fits*).

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`, MT2's), with things taught
to it.** Measured 2026-10-30 (plan rows 10c and 10c1): a scratch copy of
`scripts/msh/` and `apps/marvel-heroes/data` at this branch's `7f56391d`
(`main` at `b8c2221c`), the mt3 entry as rows 10a and 10b left it
(`parts`, `character_ranges`, `opponents`) given `"layout":
"grid-booklets"` and the fields `main`'s `gridbooks.py` already reads for
MT2, set for this book: `rank_ranges`, `code_first_caps`, `row_marks`,
`bracket_tail`, `letters_marks`, `lost_letters`, `title_case_labels`,
`trailing_marks`, `card_headers`, `card_names` (decision 5), trial `teams`
(decision 1, four of them, the third and fourth starting at a header),
`cards` (31: the 29 headers, the Mad Thinker's Android and Attuma's
Minions, decision 4), `header_blocks` (the four second forms),
`one_line_grids` (14: the android and the minions with their host, and the
twelve chapter grids by decision 3's names), `slash_forms` (Moon Knight,
printed 5, decision 6), `subhead_labels` and `speck_lines`; and a trial
`mt3-overrides.json`, run on a copy of the cache under its own
`WORKSHOP_MSH_CACHE`. Six runs.

**`code-grids` stops at once**, as it did on MT2: `roster.py mt3` exits 1
in `roster.page_stream` with `KeyError: 'offset'`, because `codegrids.py`
reads one `offset` and `character_pages`, and a parts entry carries
neither (MT2's code-grids items 1 and 2). MT2's verdict went to
grid-booklets, and `main`'s `gridbooks.py` now reads MT2's fields, so the
trial went there and no further with code-grids. The other readers fit
less: `roster.py` (MA1) reads one offset; `booklet.py` (MHSP1) and
`coverpanels.py` (MH1, MH2) read rank words with no numbers.

**The stock grid-booklets stops at the first chapter grid.** With MT2's
fields and nothing taught, `roster.py mt3` exits 1 at the fish (printed
21), `a one-line grid read wrong`, and writes nothing (item 1). Each later
stop needed a reader change to pass, so there is no "past the stop" column.

| measure | stock | with every trial change |
|---|---|---|
| entries | none (stops) | 48: 43 with a block, 5 without (The Player Characters twice, Non-Player Characters, NON-PLAYER CHARACTERS, Friendly NPCs, all blockless headings) |
| stat blocks | none | 48 |
| blocks passing every check | none | 42, and 6 known from the overrides (5 `misprint`, 1 `as_printed`) |
| failing | none | 0 |
| checklist names with no entry | not reached | 0 (31 cards, 12 opponents, all found) |
| powers | not reached | 85 across 28 entries |
| exit code | 1 | 0 |

The 48 blocks are this survey's count: the 33 labelled grids with Moon
Knight's read as his two forms (34), the two one-line grids carded inside
their hosts' blocks, and the twelve chapter grids. The Black Knight's horse
is not read as a block, as decision 4 wants. The run before the last fixes
exited 1 with 2 failing (Moon Knight's P, matched twice by its override;
Peter Parker's non-powered form, every row unread), Spider-Man's Health
and Karma and Kang's Karma not numbers, and Ko-Kri (Typical) on no
checklist.

What grid-booklets must learn. Each reader change was made in the scratch
copy, marked as the trial's:

1. **Class 1000 read `Cli000`** (the fish's E, printed 21): `roster.CANON`
   has no `i` for a 1. Reader, ungated in the trial.
2. **A one-line grid that prints neither Health nor Karma** (the
   scorpions, printed 34): `read_line_grid` wants a Health line. Reader,
   ungated.
3. **An underscore token and a mark in a codes row** (the Kang Duplicate's
   Battle Robots, printed 46): `line_codes` strips marks but not this.
   Reader, ungated.
4. **A title-case second value on a slash row** (Moon Knight's Moonlight
   F, `/In 40`, printed 5): the `slash_forms` mend wants capitals. Reader,
   inside the `slash_forms` gate.
5. **A mark set off by spaces between code and number** (the Vision's R,
   printed 4; the Thing's P, 10; Ko-Kri's P and A, 13; Electro's E, 16):
   `row_marks`' marks allow no space, so four grids were unread. Reader,
   inside `code_first_caps`, which MT2 sets too.
6. **Two ranks on one row** (Kang's R, I and P, `IN/AM 40/50`, printed
   13): read as rank plus alternate (decision 9). Reader, inside
   `code_first_caps`.
7. **A grid broken across a column** (the Invisible Girl, printed 9; the
   Human Torch, 10; Peter Parker's non-powered form, 11): `grid_at` wants
   Popularity in the same column. The trial's `split_grids` takes the
   stream's rows, then re-reads the first column's part from a `--psm 6`
   crop as every whole grid is; Peter Parker's A, S and E read sideways in
   the TSV, and the image prints TY 6 on each. Reader, gated by
   `split_grids`.
8. **`Res:` for Resources** (the Mandarin, printed 15): only `slash_forms`
   renamed it, which covered Moon Knight alone. The trial's `res_label`.
   Reader, gated.
9. **Totals a grid does not print** (the snakes' Karma, printed 33; the
   scorpions' Health and Karma, 34) are derived from the rows (decision
   10), so the check on them cannot fail. The block should be marked
   derived, as `rank_only` marks a derived number. Reader, ungated.
10. **Kang's `Known Powers`** (printed 13, no colon in the OCR) stays title
    case: `subhead_labels` adds the colon after `title_case_labels` has
    run, so his powers went to prose. Registry only: a `speck_lines` entry,
    the line after `subhead_labels` (`Known Powers:`) as `KNOWN POWERS:`.
    Kang then has his 5 powers.
11. **Kang's `Karma: Varies`** (printed 13). Registry only: an
    `as_printed` override on his Karma (ME2 Death's shape; decision 9).
12. **`Ko-Kri (Typical)`** (printed 13): `gridbooks.base` strips the
    bracket from the header but the card name kept it, so neither list
    found the other. Registry only: the card named `Ko-Kri` (decision 12).
13. **Moon Knight's P override matched both slash forms** (printed 5).
    Registry only: `"label": "Normal"` in its match (decision 7).

**Read right with nothing changed** (MT2's fields): the four second forms
by `header_blocks`; the android and the minions by `one_line_grids` with
their host; every card header by `cards`; the teams' fourth field
(MISTER FANTASTIC, SPIDER-MAN); and every chapter grid but items 1-3 and
9.

**So grid-booklets must learn 13 things: 9 reader changes** (1-9) **and 4
registry-only** (10-13), **none left unfixed**. Items 1, 2, 3 and 9 are
ungated in the trial and 5 and 6 sit inside `code_first_caps`, which an
earlier book already sets: the reader row gives each a field of its own,
or builds every earlier book byte-identical (`marvel-book`, *Prove every
earlier book did not move*). The trial did not run that proof. The
overrides file holds 6 entries, each matching one block (no `OVERRIDE
MATCHES` line): Moon Knight's P (label Normal), the Mandarin's Resources
AM(30) to AM(50), Kang's Karma `as_printed`, the Kang Duplicate's Battle
Robots' Health 90 to 110, Mike Franklin's Karma 18 to 14 and Tom Tyler's
22 to 18. Ko-Kri's PR(6) needs none: no check reads Resources (decision
8). Its registry patch, its two reader diffs and its runs are kept in the
plan's store (rows 10c and 10c1, `trial/mt3/`), not the repo.

**The open checks, answered by the trial:**

- **Peter Parker's non-powered block** (printed 11) reads only with item
  7's crop re-read: F, A, S and E TY 6, R EX 20, I GD 10, P EX 20, Health
  24, Karma 50, Resources PR(3), Popularity 0, and it passes.
- **No Enemy NPCs heading entry**, and the book needs none: the stream
  reads `ENEMY NPCs` (printed 13, column 1, above KANG), but mixed case
  fails the header test. MT2's roster has none either, and `npcs.py` reads
  only entries with a block. The registry's `sections` carry Enemy NPCs
  already.
- **The feet marks under `npcs.pair_quotes`** (a scratch `npcs.py`):
  the Beast's `(30')` (printed 6), the Angel's `16'`, `10,000'` and
  `29,000'` (7) and Mister Fantastic's `1500'` (9) each stay a single mark,
  since each follows a digit, which `pair_quotes` skips. No `text` verdict
  is needed for them. The Beast's text gains one double elsewhere (two
  left singles read for an opening double, printed 6, now paired with its
  closing double), not read on the image by the trial.

**Verdict: grid-booklets.** It reads this book's `parts`,
`character_ranges` and `opponents` as rows 10a and 10b wrote them, and
every field MT2 taught it carries over; code-grids cannot start.

**The decision it settles** (the reader row sets it): `"layout":
"grid-booklets"`, with the fields above, the overrides' six, and a field
of its own for each of the reader changes 1-9 or the byte-identical proof
for the ungated ones. This survey sets no `layout`.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-30: take the survey's recommendations). Characters only is already
ruled (Nate, 2026-10-21), and so are second cards with `-mt3` ids
(2026-09-28) and a leading The dropped from a name (2026-10-21: THE VISION
is Vision).

1. **Teams:** Revenge of Kang Heroes for the three Player Characters
   (recommended, as MT2's Weird, Weird West Heroes for the same three);
   **X-Men** for the six cards under the book's own subhead The X-Men
   (printed 6-8), and **Fantastic Four** for the four on printed 9-10,
   which the book closes with its own THE FANTASTIC FOUR IN THE ADVENTURE
   (as MT2's Western Heroes took the book's own head; the Codex files
   MA1's, MH1's and MHSP2's X-Men and MA4's, MH3's, MHSP2's and MH9's
   Fantastic Four there); every other card, Spider-Man to Marty Jenkins,
   the Enemy NPCs and the chapters' grids, under **MT3 The Revenge of
   Kang** (as MT2's). Not taken: West Coast Avengers for the Player
   Characters (MT2 decision 1's reason holds: no identity line names it),
   or every NPC under the book's title.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure,
   items, places or maps.
3. **Every grid a card** (recommended, as MT2 decision 3), named by what
   the prose calls them: Fish, Giant Insect, Alligator Creatures, Snakes,
   Scorpions (the prose's double quotes dropped: they mark a word, not a
   nickname as Hobart's in MT2), Thugs, Mike Franklin, Tom Tyler, Security
   Robots and O'Malley (a straight apostrophe). The two grids the prose
   calls battle robots are named by whose they are, **Kang Duplicate's
   Battle Robots** (printed 46) and **Supreme Kang's Battle Robots**
   (printed 62), since one book's two cards of one name would share an id.
   Not taken: a chapter number in a name.
4. **The grids inside other blocks** (recommended, as MT2 decision 4): the
   Mad Thinker's android (printed 14) a card of its own, **Mad Thinker's
   Android**, and Attuma's minions (printed 16) one, **Attuma's Minions**,
   each a being with a grid whose Health and Karma hold (100 and 6, 100
   and 18), codes only, so on standard numbers and `rank_only`, filed with
   its host's team, as MT2's Lobo; the Black Knight's winged horse (printed
   15) left in his card's text, as MT2 decided for the same horse, since it
   prints neither Health nor Karma.
5. **Black Knight (Nathan Garrett)** as the card's name (recommended, as
   MT2 decision 5 for the same block): MHSP2's and MH8's Black Knight is
   Dane Whitman.
6. **Moon Knight's two forms** one card with two blocks labelled Normal
   and Moonlight, Health 90 and 150 (recommended, as MT2 decision 6 for the
   same block).
7. **The failing totals and code** as `misprint` overrides, printed and
   corrected kept (recommended, as MT2 decision 7): Moon Knight's Normal P
   code, EX to RM; Kang Duplicate's Battle Robots' Health, 90 to 110; Mike
   Franklin's Karma, 18 to 14; Tom Tyler's Karma, 22 to 18. Not taken:
   Franklin's and Tyler's P as `6 Ty` (both Karma would hold), since each
   printed P's number and code agree and the rule is MT2's for Khan's
   Champion.
8. **The two Resources** (recommended): the Mandarin's `AM(30)` a
   `misprint` override to AM(50), printed and corrected kept, on MH7's
   Mandarin, whose Resources is the word Amazing; Ko-Kri's `PR(6)` left as
   printed, since no total and no other book says which half is wrong (an
   `as_printed` with that reason if a check reads Resources; none did for
   MT2, per its `bracket_tail` note). Not taken: Ko-Kri's code to TY or
   its number to 4, either of which is a guess.
9. **Kang** (recommended): one card, one block, the first value of R, I and
   P its ranks and the second each row's alternate (as MT2's Moon Knight
   rows carry theirs), Health 86, and `Karma: Varies` left unset, as MH3's
   Super-Adaptoid (MH3 decision 4: the card says so in a word, and a
   derived 56 or 120 would be a guess at what it means). Not taken: two
   blocks by `slash_forms`, since the block prints one Health and only
   three rows print two values.
10. **Totals a chapter grid does not print** (recommended, as MH3 decision
    4's derived Karma, after MH2's Kang's Minions): the snakes' Karma 10
    and the scorpions' Health 40 and Karma 18, derived and flagged as not
    printed. Not taken: left unset, which leaves two cards the GM tools
    cannot play.
11. **No card for beings statted by reference only** (recommended, as MT2
    decision 9): the Judge's Book's soldiers, thug and policeman, the
    all-Typical bystanders, tough guys and clerk, and the Ko-Kri and Kang
    duplicates the chapters send back to printed 13.
12. **Ko-Kri (Typical)** a card named Ko-Kri with its block labelled
    Typical, the parenthesis read as a version as `npcs.py` reads one
    (recommended). Not taken: MT2's `count_headers`, which is for a count,
    and Typical is not one.
13. **Names otherwise as printed**, title case for the capitals
    (recommended): the leading The dropped from THE VISION, THE SCARLET
    WITCH, THE BEAST, THE THING, THE HUMAN TORCH, THE UNICORN and THE
    BEETLE (Nate, 2026-10-21); Mister Fantastic and Invisible Girl as this
    book prints them, not MH3's Mr. Fantastic or the later Invisible Woman;
    the four second forms (Ben, Peter Parker, Matt Murdock, Tony Stark)
    blocks of their hero's card labelled with the line over the grid, as
    MT2's Hamilton Slade.

## How to reproduce

```bash
python scripts/msh/ocr-book.py mt3 --probe
python scripts/msh/ocr-book.py mt3
python scripts/msh/survey.py mt3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-220 dpi into the scratchpad.
