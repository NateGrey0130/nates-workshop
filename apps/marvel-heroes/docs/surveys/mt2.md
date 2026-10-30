# Survey: MT2 The Weird, Weird West (TSR6886)

> **DRAFT.** Measured up to *Stat blocks: the two character sections*. The
> 28 chapters' grids and named blocks (printed 9-51), *Names the Codex
> already has*, *Quote marks*, *Which reader fits* and *Decisions* are not
> finished: the booklet is 64 pages, so its survey is two rows. Nothing here
> is imported yet.

Marvel Super Heroes Official Advanced Game Adventure, Ray Winninger, 1988,
the second module of the three-part Time Warp series. Registry entry:
`scripts/msh/books.json` -> `mt2`. Measured 2026-10-30.

**Rows citing this book:** none yet (no data has been built).

Everything here was measured and read on the page images.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 70 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-30 into the main
  checkout's `.cache/msh/books/mt2/` (70 pages OCR'd).
- **The booklet is 64 pages** (PDF 3-66). The print is clean; the grids'
  codes and numbers OCR well, the rank rows' letters less so (`|` and `1`
  for I, `S$` for S).
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 600 x 775 | Cover (outside front; product code 6886) | - |
| 2 | 594 x 767 | Map: Krozzar Camp, a battle flowchart for the Krozzar assault, Research Shack | - |
| 3-66 | 594 x 767 | Adventure Book | 1-64 |
| 67 | 594 x 767 | Map: Chronovore's Brain, and a Chronovore encounters chart | - |
| 68 | 600 x 775 | Back cover (product code 6886; the Time Warp series' second) | - |
| 69 | 1470 x 1134 | Players' Map (Dodge City and its surroundings) | - |
| 70 | 1470 x 1134 | Judge's Map (the same ground with the three conquerors' territories; product code 6886XXX0701) | - |

**The two booklet-sized maps** (PDF 2 and 67) print no folio and are the
booklet's size, not the cover's; whether they are the inside covers or the
booklet's own first and last leaves the scan does not show. Neither prints a
statistic. None of the five map pages is imported.

## Offset

`survey.py` votes **printed = PDF - 2 on 43 pages**, and no booklet page
disagrees. Twenty more booklet pages print their folio, PDF - 2, at the foot,
read on a strip of each page's foot because Tesseract missed it: PDF 4-11,
18, 20, 25, 31, 36, 41, 43, 46, 47, 48, 52 and 53. PDF 70's vote of 1
(k = 69) is a digit on the Judge's Map, not a folio.

Printed 1 (PDF 3) is the title page, with the Contents and the credits, and
prints no folio. Every other booklet page prints its folio. So `parts`, as
MH9 and ME3, with the cover, the four map pages and the back cover as parts
of their own with `offset` null.

## The book's own authority lists

**Contents (printed 1).** Transcribed from a render, then each entry checked
against its banner or header on the page. **Every entry agrees with its
page**, so there are no `contents_errata`. Stored as `sections`, the
sub-entries under their section.

| printed | Contents entry |
|---|---|
| 2 | Introduction |
| 3 | The Player Characters: The Vision (3), Moon Knight (4), The Scarlet Witch (5) |
| 5 | Non-Player Characters: Friendly NPCs (5), Enemy NPCs (6) |
| 9 | Chapter 1: No Time Like The Present |
| 11 | Chapter 2: Eddie? . . . Who's Eddie? |
| 11 | Chapter 3: There Be Dinosaurs! |
| 12 | Chapter 4: Meet The Krozzar |
| 13 | Chapter 5: The Krozzar Base |
| 15 | Chapter 6: The Research Shack |
| 17 | Chapter 7: Captured! |
| 18 | Chapter 8: Not The Mind Probe! |
| 19 | Chapter 9: You're In The Army Now |
| 21 | Chapter 10: Patrol And Probe |
| 22 | Chapter 11: Traveling Cross-Country |
| 26 | Chapter 12: Desperados Afoot |
| 28 | Chapter 13: The Hobart Gang |
| 30 | Chapter 14: Uncle Albert |
| 31 | Chapter 15: Back To The Krozzar Camp |
| 31 | Chapter 16: Back To The Timeship |
| 32 | Chapter 17: Genghis Khan |
| 33 | Chapter 18: Arena Combat |
| 34 | Chapter 19: The Royal Hunt |
| 35 | Chapter 20: Great Alexander |
| 36 | Chapter 21: Alexander's Feast |
| 38 | Chapter 22: Alexander's Assault |
| 39 | Chapter 23: Le Petit Empereur |
| 41 | Chapter 24: Can We Talk? |
| 42 | Chapter 25: The Krozzar Assault |
| 45 | Chapter 26: Uncle Albert, Again |
| 46 | Chapter 27: Doom's Doorway |
| 47 | Chapter 28: Time Amok |
| 52 | Western Heroes: Ghost Rider I & II (52), Ghost Rider IV (53), Kid Colt (54), Rawhide Kid (56), Red Wolf (57), Shooting Star (59), Texas Twister (61), Two-Gun Kid (63) |

- **The banners.** INTRODUCTION is a white-on-black bar at the top of
  printed 2, and every chapter's is the same bar across the page: at the top
  of its page but for Chapters 3, 4, 5, 9, 16 and 21, which open mid-page.
  WESTERN HEROES is the bar on printed 52, and each hero's header is a
  capital line on the Contents' page. The Player Characters (printed 3),
  Non-Player Characters and Friendly NPCs (5) and Enemy NPCs (6) are
  subheads in the column, not bars.
- **Tesseract drops six chapter titles** after the colon (Chapters 10, 15,
  16, 17, 24 and 26); each was read on the page image. Chapter 8's italic
  `Mind` reads `M/ND`.
- **One banner is not in the Contents: Event Cards**, on printed 49 and 50,
  a page of captioned cards and a page of pictured cards, three by five, no
  character among them. Chapter 28 runs on printed 47-48 and resumes on
  printed 51 (its AFTERMATH and KARMA parts).
- **No index.** The coverage checklist will be this survey's list.

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's rank rows and its
  labels are two sub-columns of one column. Printed 52 sets Ghost Rider I &
  II's block in column 1 beside a portrait two columns wide, with HISTORY in
  three columns under both.
- **Two block shapes**, one for each character section:
  - **The Player and Non-Player Characters (printed 3-8)**: a header, then
    seven rows of letter, rank CODE, number, no parentheses (`F RM 30`), with
    `Health:`, `Karma:`, `Resources:` and `Popularity:` to the right on rows
    F, S, R and P, Resources as a code and its number in brackets (`EX(20)`).
    Moon Knight's block prints `Res:` for Resources. Then `KNOWN POWERS:` in
    capitals and `Talents:`, `Contacts:` and `Background:` as bold run-ins.
  - **The Western Heroes (printed 52-64)**: a header, a `STATISTICS`
    subhead, then rows of letter, CODE, (number) (`F GD (10)`), the four
    labels in bold beside them, Resources as `TY (6)`; then the subheads
    BACKGROUND (ten identity run-ins: Real Name, Occupation, Legal Status,
    Identity, Place of Birth, Marital Status, Known Relatives, Base of
    Operations, Past and Present Group Affiliation(s), printed with and
    without the s), KNOWN POWERS (with `Talents:` and `Contacts:` run-ins),
    `ADDITIONAL NOTES:`, ROLE-PLAYING NOTES and HISTORY. The grid is MA4's
    (code, then the number in parentheses); the subheads are not MA4's
    run-ins.
- **Headers.** The three Player Characters' headers are capitals (THE
  VISION, MOON KNIGHT, THE SCARLET WITCH), two with an `alias` line under
  them (Moon Knight's and the Scarlet Witch's). **The Non-Player Characters'
  headers are bold title case, not capitals** (Albert Einstein, Alexander
  The Great, Doctor Doom), and five have a real-name line under them, also
  bold title case (Victor von Doom, William Baker, Quentin Black, Nathan
  Garret, MacDonald Gargan). The Western Heroes' headers are capitals.
- **Section labels**, counted on the OCR of printed 3-8 and 52-64 and read on
  the images of printed 4, 6, 8 and 52: in printed 3-8, `KNOWN POWERS:` (9
  of the 13 blocks; Einstein, Alexander, Napoleon and Genghis Khan print
  none), `Talents:` (11), `Background:` (13), `Contacts:` (2),
  `Weaknesses:` (the Sandman's) and a `NOTE:` run-in in the Vision's block;
  in printed 52-64, STATISTICS, BACKGROUND, KNOWN POWERS, `ADDITIONAL NOTES:`
  and ROLE-PLAYING NOTES eight times each, and HISTORY as a ruled head across
  the columns.
- **Ranks.** Both sections' labelled blocks print codes in capitals: PR,
  TY, GD, EX, RM, IN, AM and MN (the Sandman's Endurance, printed 7), and FE
  on Lobo's grid (printed 57). The one-line grid inside Black Knight's block
  (printed 8) prints its codes in title case (`Gd Ex Rm In Ty`), and so do
  the chapters' grids in the OCR of printed 12, 21 and 33 (Fe, Pr, Ty, Gd,
  Ex, Rm, In, Un). Both spellings are in `rank_aliases`. No book-specific
  spelling (MA4's RE, MH9's GO) is in the two character sections.
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Where the blocks are

From the OCR's label counts: labelled blocks on printed 3-8 (13) and 52-63
(8), and in the chapters a `Health` line on printed 12, 18-21, 23-25, 28,
29, 33, 36, 37, 43 and 47, with named blocks of the first shape among them
(printed 28, 29 and 36 carry `Resources:` and `Popularity:` too). Row 7b
reads every chapter grid and block. Not one page outside the booklet holds a
Health, Karma or rank row.

## Cover-panel cards

**None.** The OCR of PDF 1, 2 and 67-70 holds no `Health`, `Karma` or rank
row, and their images show the cover, the back cover's blurb and four maps.
So `panels` is empty, as MH8's and MH9's.

## Stat blocks: the two character sections

Every block of printed 1-10 and 52-64 was read on a crop of the page image
(100-130 dpi) and checked against the book's own arithmetic and
`apps/marvel-heroes/data/ranks.json`. Printed 1-2 and 9-10 hold none.

**The Player and Non-Player Characters (printed 3-8): 13 labelled blocks.**

| printed | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 3 | THE VISION | RM 30, EX 20, AM 50, IN 40, EX 20, GD 10, RM 30 | 140 | 60 | PR(4) | 30 |
| 4 | MOON KNIGHT, Normal / Moonlight | RM 30/IN 40, EX 20/RM 30, EX 20/IN 40, EX 20/IN 40, GD 10/GD 10, EX 20/EX 20, RM 30/RM 30 | 90/150 | 60 | RM(30), as `Res:` | 10 |
| 5 | THE SCARLET WITCH | GD 10, GD 10, TY 6, EX 20, GD 10, EX 20, RM 30 | 46 | 60 | TY(6) | 30 |
| 5 | Albert Einstein | PR 4, TY 6, PR 4, TY 6, AM 50, EX 20, GD 10 | 20 | 80 | GD(10) | 25 |
| 6 | Alexander The Great | EX 20, GD 10, GD 10, GD 10, EX 20, EX 20, GD 10 | 50 | 50 | EX(20) | 40 |
| 6 | Napoleon Bonaparte | TY 6, TY 6, TY 6, GD 10, GD 10, EX 20, GD 10 | 28 | 40 | GD(10) | 30 |
| 6 | Genghis Khan | EX 20, **GD 6**, **GD 6**, EX 20, GD 10, EX 20, GD 10 | 52 | 40 | EX(20) | 30 |
| 6 | Doctor Doom (Victor von Doom) | RM 30, EX 20, RM 30, IN 40, AM 50, IN 40, AM 50 | 120 | 140 | AM(50) | 40 |
| 7 | The Sandman (William Baker) | RM 30, RM 30, IN 40, MN 75, TY 6, GD 10, RM 30 | 175 | 46 | TY(6) | 0 |
| 7 | Mysterio (Quentin Black) | EX 20, GD 10, GD 10, EX 20, EX 20, EX 20, RM 30 | 60 | 70 | EX(20) | -15 |
| 8 | Black Knight (Nathan Garret) | EX 20, EX 20, GD 10, GD 10, GD 10, TY 6, PR 4 | 60 | 20 | EX(20) | -5 |
| 8 | Scorpion (MacDonald Gargan) | RM 30, IN 40, IN 40, IN 40, TY 6, TY 6, GD 10 | 150 | 22 | TY(6) | -15 |
| 8 | Krozzar | EX 20, GD 10, EX 20, GD 10, GD 10, PR 4, GD 10 | 60 | 24 | TY(6) | 0 |

The three Player Characters are the Contents' (printed 3-5); Einstein is the
one Friendly NPC (printed 5); the other nine are the Enemy NPCs (printed
6-8). Moon Knight's one block carries his two forms in two columns of
values; the Moonlight form's Health is the second.

**The Western Heroes (printed 52-64): 8 STATISTICS blocks.**

| printed | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 52 | GHOST RIDER I & II | GD (10), EX (20), TY (6), GD (10), TY (6), GD (10), EX (20) | 46 | 36 | TY (6) | 20 |
| 53 | GHOST RIDER IV | TY (6), EX (20), EX (20), IN (40), GD (10), EX (20), RM (30) | 86 | 60 | TY (6) | 5 |
| 54 | KID COLT | EX (20), EX (20), GD (10), EX (20), TY (6), EX (20), GD (10) | 70 | 36 | PR (4) | 20, and -30 with the authorities |
| 56 | RAWHIDE KID | EX (20), EX (20), GD (10), EX (20), TY (6), EX (20), GD (10) | 70 | 36 | PR (4) | 20 |
| 57 | RED WOLF | RM (30), EX (20), GD (10), EX (20), GD (10), IN (40), EX (20) | 80 | 70 | TY (6) | 5 |
| 59 | SHOOTING STAR | GD (10), RM (30), TY (6), EX (20), TY (6), TY (6), TY (6) | 66 | 18 | TY (6) | 10 |
| 61 | TEXAS TWISTER | GD (10), EX (20), TY (6), RM (30), TY (6), TY (6), TY (6) | 66 | 18 | TY (6) | 10 |
| 63 | TWO-GUN KID | EX (20), GD (10), GD (10), EX (20), TY (6), EX (20), GD (10) | 60 | 36 | GD, no number | 10 |

Two-Gun Kid's history ends on printed 64, which holds no block.

**Three one-line grids inside these blocks**, each the seven letters over
its values, with no header of its own:

| printed | inside | what | values | Health | Karma |
|---|---|---|---|---|---|
| 8 | Black Knight | his flying horse, which this adventure leaves in the future | 10 Gd, 20 Ex, 30 Rm, 40 In, 6 Ty, 10 Gd, 6 Ty | not printed (100 by F+A+S+E) | not printed (22 by R+I+P) |
| 53 | Ghost Rider IV | Hamilton Slade, his human form | 6 TY, 10 GD, 20 EX, 10 GD, 10 GD, 20 EX, 6 TY | 46, in a sentence | 36, in a sentence |
| 57 | Red Wolf | Lobo, his wolf | codes only: EX GD GD GD FE FE TY | 50 | 10 |

**The book checks itself.**

| measure | count |
|---|---|
| labelled blocks, Health = F+A+S+E | **21 of 21** (Moon Knight's in both forms) |
| labelled blocks, Karma = R+I+P | **21 of 21** |
| every number within its rank code's range | **20 of 21**: Genghis Khan's A and S are not |
| a number inside its range but not the rank's standard | none |
| one-line grids, Health and Karma both hold | **2 of 2** that print them (Lobo's on standard numbers); the horse prints neither |

**The misprints so far, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Genghis Khan, printed 6 | `A GD 6` and `S GD 6` | 6 is Typical (Good is 8-15); Health 52 = 20+6+6+20 agrees with the 6s, so the code is the misprint: TY |

As `page:name:field printed->corrected`: `6:Genghis Khan:A GD->TY`,
`6:Genghis Khan:S GD->TY`.

## The chapters' grids and named blocks (printed 9-51)

**Not finished** (row 7b).

## Names the Codex already has

**Not finished** (row 7b).

## Quote marks

**Not finished** (row 7b).

## Which reader fits

**Not finished.** This survey sets no `layout`.

## Decisions this survey leaves open

**Not finished** (row 7b). Characters only is already ruled (Nate,
2026-10-21), and so are second cards with `-mt2` ids (2026-09-28) and a
leading The dropped from a name (2026-10-21: THE VISION is Vision).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mt2 --probe
python scripts/msh/ocr-book.py mt2
python scripts/msh/survey.py mt2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 28-130 dpi into the scratchpad.
