# Survey: MT3 The Revenge of Kang (TSR6891)

> **DRAFT.** Written through the stat blocks of printed 1-16 (plan row
> 10a). The chapters' grids, *Names the Codex already has*, *Quote marks*,
> *Which reader fits* and *Decisions* are not finished.

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
  GO) is in printed 1-16. Row 10b adds any code the chapters print.
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

As `page:name:field printed->corrected`: `5:Moon Knight:P (Normal) EX->RM`,
`13:Ko-Kri:Resources PR(6)->?`, `15:Mandarin:Resources AM(30)->?`. The two
Resources are the Decisions' to settle (not finished).

## The chapters' grids and named blocks (printed 17-63)

Not finished (plan row 10b): the 38 chapters' one-line grids and any named
block. A 35 dpi look at printed 47 shows a one-line grid in column 3.

## Names the Codex already has

Not finished (plan row 10b).

## Quote marks

Not finished (plan row 10b).

## Which reader fits

Not finished (plan rows 10b and 10c).

## Decisions this survey leaves open

Not finished (plan row 10b). Already ruled: characters only (Nate,
2026-10-21), second cards with `-mt3` ids (2026-09-28) and a leading The
dropped from a name (2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mt3 --probe
python scripts/msh/ocr-book.py mt3
python scripts/msh/survey.py mt3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-220 dpi into the scratchpad.
