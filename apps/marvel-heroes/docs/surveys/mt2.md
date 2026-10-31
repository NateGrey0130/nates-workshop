# Survey: MT2 The Weird, Weird West (TSR6886)

Marvel Super Heroes Official Advanced Game Adventure, Ray Winninger, 1988,
the second module of the three-part Time Warp series. Registry entry:
`scripts/msh/books.json` -> `mt2`. Measured 2026-10-30.

**Rows citing this book:** 127 `msh_book_text` rows over 27 character entries
in production (`DB_MARVEL`, read back 2026-10-30).

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
(printed 28, 29 and 36 carry `Resources:` and `Popularity:` too). Read on
the images, the chapters hold eight blocks on printed 12, 21, 24, 28, 29
(two), 33 and 36, and the other pages' `Health` lines are prose (*The
chapters' grids and named blocks*). Not one page outside the booklet holds
a Health, Karma or rank row.

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

**The misprints in these two sections, each read on the page image** (the
whole book's are under *The chapters' grids and named blocks*):

| entry | printed | the book's own arithmetic |
|---|---|---|
| Genghis Khan, printed 6 | `A GD 6` and `S GD 6` | 6 is Typical (Good is 8-15); Health 52 = 20+6+6+20 agrees with the 6s, so the code is the misprint: TY |

As `page:name:field printed->corrected`: `6:Genghis Khan:A GD->TY`,
`6:Genghis Khan:S GD->TY`.

## The chapters' grids and named blocks (printed 9-51)

Every chapter page, printed 9-51, was looked at on a 40 dpi render, and the
OCR of each was searched for a row of rank codes, a row of the seven
letters, `Health:` and `Karma:`. Both found the same **eight blocks on seven
pages**, and each was then read on a crop of the page image (100-130 dpi).
The `Health` lines 7a counted on printed 18-20, 23, 25, 37, 43 and 47 are
prose (damage, Karma awards), not blocks. Printed 49-50 (Event Cards) and
51 hold none.

**Four one-line grids**, each the seven letters, a row of numbers, a row of
title-case codes, then `Health:` and `Karma:` on lines of their own. Unlike
ME3's codes-only grids, these print the number over the code. **None
prints a name line**; each is named here by what its prose calls it.

| printed | column | name (from the prose) | F A S E R I P | Health | Karma |
|---|---|---|---|---|---|
| 12 | 2 | Tyrannosaur (Chapter 3) | 30 Rm, 10 Gd, 40 In, 100 Un, 2 Fe, 2 Fe, 2 Fe | 180 | 6 |
| 21 | 2, top | Hoplites (Chapter 10, a force of twelve) | 10 Gd, 10 Gd, 10 Gd, 10 Gd, 6 Ty, 6 Ty, 6 Ty | 40 | 18 |
| 24 | 1, top | Cavemen (Chapter 11, five; introduced at the foot of printed 23, column 3) | 10 Gd, 4 Pr, 10 Gd, 20 Ex, 4 Pr, 4 Pr, 4 Pr | 44 | 12 |
| 33 | 2 | Khan's Champion (Chapter 18, the arena) | 10 Gd, 10 Gd, 10 Gd, 20 Ex, 4 Pr, 6 Ty, 4 Pr | 50 | **10** |

The tyrannosaur's grid is followed by `KNOWN POWERS:`, the hoplites' by
`Armor:` and `Weaponry:` run-ins, the other two by prose.

**Four named blocks of the first shape** (letter, CODE, number; the four
labels to the right), set inside a chapter's prose:

| printed | column | header as printed | F A S E R I P | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|---|
| 28 | 3 | `"Faro" John Hobart`, under a capital line THE HOBART GANG (Chapter 13) | PR 3, EX 16, TY 5, GD 8, EX 16, GD 8, EX 16 | 32 | 40 | TY (5) | -5 |
| 29 | 1 | Average Rifleman (2) | TY 5, GD 8, TY 5, GD 8, TY 5, TY 5, PR 3 | 26 | 13 | 0 | 0 |
| 29 | 2 | Average Mounted Desperado (3) | GD 8, GD 8, GD 8, TY 5, TY 5, TY 5, PR 3 | 29 | 13 | 0 | 0 |
| 36 | 3 | none: the prose names it the Twain android (Chapter 21) | RM 30, GD 10, RM 30, RM 30, GD 10, TY 6, PR 4 | 100 | 20 | FE (2) | 0 |

- **The headers.** Hobart's is a bold title-case line with the nickname in
  double quotes (OCR: `**Faro` and a double and single after it); the two
  gang members' are bold title case with the encounter's count in brackets;
  the android has none, only a sentence ending `statistics:` above its grid.
- **The run-ins.** The three Hobart Gang blocks print `KNOWN POWERS:`,
  `Talents:`, `Background:` and **`Role Playing Notes:`**, a bold run-in
  printed 3-8 does not have (the Western Heroes print ROLE-PLAYING NOTES as
  a subhead). The android's prints `KNOWN POWERS:`, then `Talents.` and
  `Contacts.` with a full stop, not a colon (read on the image).
- **Resources** prints `TY (5)` and `FE (2)`, with a space before the
  bracket, where printed 3-8 print `EX(20)`; the two gang members print a
  bare `0`.
- **OCR misreads** in these blocks: the Rifleman's F `TY 5` is read
  `.-TY ..6`; the letter I as `|`, `1` and `!`; S as `$` and a section sign.
  Each value above is the image's.

**The book checks itself, in the chapters.**

| measure | count |
|---|---|
| Health = F+A+S+E | **8 of 8** |
| Karma = R+I+P | **7 of 8**: Khan's Champion prints 10, and 4+6+4 is 14 |
| every number within its rank code's range | **8 of 8** (the one-line grids print number and code, and every pair agrees) |
| a number inside its range but not the rank's standard | **three blocks, every value of each**: the Hobart Gang's (printed 28-29). Each is the lowest number of its rank (`ranks.json` `initial`): PR 3, TY 5, GD 8, EX 16, and Hobart's Resources TY (5) |

**No grid is repeated.** The Krozzar soldiers of Chapters 4-25 are printed
8's block; Chapter 18 sends Genghis Khan to printed 6. **Beings statted by
reference only**, to the Advanced Set's Judge's Book (typical soldiers,
dogs, dinosaurs) or to an earlier chapter, are on printed 22-24, 32, 34,
35, 38, 39 and 43; none prints a rank. Printed 23 also prints the German
biplanes' vehicle line (Control, Speed, Body, Protection: Rm, Gd, Pr and
Shift 0), not a character.

**The misprints, the whole book, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Genghis Khan, printed 6 | `A GD 6` and `S GD 6` | 6 is Typical; Health 52 agrees with the 6s, so the code is the misprint: TY |
| Khan's Champion, printed 33 | `Karma: 10` | R+I+P = 4+6+4 = 14; every number agrees with its code, so the total is the misprint |

As `page:name:field printed->corrected`: `6:Genghis Khan:A GD->TY`,
`6:Genghis Khan:S GD->TY`, `33:Khan's Champion:Karma 10->14`.

**The whole book, counted:** 25 full blocks (13 on printed 3-8, 8 on
printed 52-63, 4 in the chapters) and 7 one-line grids (3 inside blocks,
on printed 8, 53 and 57; 4 in the chapters).

**Card pages and the chapters' blocks.** Printed 3-8 and 52-64 are card
pages: every grid there is a character's, and the Western Heroes' text runs
to printed 64. The chapters' eight blocks are statted inside the prose, on
printed 12, 21, 24, 28, 29, 33 and 36. The registry records them as ME3's
entry does (`character_ranges` and `opponents`, each with its `part`),
because MT2's entry is already a `parts` entry and the chapters' blocks are
ME1's chapter opponents in shape; which reader takes them is *Which reader
fits*.

## Names the Codex already has

Read from `apps/marvel-heroes/data/npcs.json`, 2026-10-30 (780 cards):
Vision (MH2), Scarlet Witch (MA1, MH2, MH9; MH1's False Scarlet Witch is
someone else), Doctor Doom (MHSP1, MA4, MH3, MHSP2) and the Sandman (MA4,
William Baker, the same man). **Black Knight** is carded by MHSP2 and MH8,
both Dane Whitman: MT2's is Nathan Garrett, another person under the name.
Not the same: MA1's Alexander Flynn, and the Champion of ME1 (Tryco
Slatterus) and MH2.

New: Moon Knight, Einstein, Alexander, Napoleon, Genghis Khan, Mysterio,
Scorpion, the Krozzar, all eight Western Heroes, Hamilton Slade, Lobo and
every chapter block. Each MT2 card is a card of its own with a `-mt2` id
(Nate, 2026-09-28).

## Quote marks

**The book prints no single quotes of its own.** The OCR of printed 1-64
reads a lone single mark at a word's edge in eight places (printed 3, 5,
10, 26 twice, 32, 36 and 48); each was read on the page image, and every
one is a double quote (`"chronovores,"`, `"power puzzle"`, `"Diplomacy
Points."`, a film's title, and dialogue). The only singles printed are
apostrophes: possessives and contractions, in the chapter banners too
(WHO'S, YOU'RE, ALEXANDER'S, DOOM'S) and in JUDGE'S NOTE. Hobart's
nickname (printed 28) is in double quotes, which the OCR reads as a double
and a single. So MHSP1's rule (every single mark a misread) fits, as it
fits MA4 and MH9.

## Which reader fits

**`code-grids` (`scripts/msh/codegrids.py`, MA4's), with things taught to
it**: its half of the comparison. Measured 2026-10-30 (plan rows 7c and
7c1): a scratch copy of `scripts/msh/` and `apps/marvel-heroes/data` at
this branch's `e89cba0e`, the mt2 entry given `"layout": "code-grids"`,
`offset` 2 and `character_pages` [3, 64] beside its `parts`,
`rank_ranges: true` (decision 8), `sections` cut to The Player Characters
(3) and Western Heroes (52), trial `teams` (decision 1), the index's 22
names, `statted_pages` for printed 12, 21, 24, 28, 29, 33 and 36,
`one_line_grids` for 12, 21, 24, 33, 53 and 57, and a trial
`mt2-overrides.json` holding decision 7's two, run on a copy of the cache
under its own `WORKSHOP_MSH_CACHE`.

**The stock reader stops at once.** `roster.py mt2` exits 1 in
`roster.section_starts`, which unpacks three fields from each `sections`
entry where a parts entry carries four (item 1), and writes nothing. So the
stock column below is that run's; there is no "past the stop" one, because
each later stop needed a reader change to pass.

| measure | stock | with every trial change |
|---|---|---|
| entries | none (stops) | 31: 30 with a block, 1 without (The Player Characters' banner) |
| stat blocks | none | 31: 21 grids and 2 one-line grids (Lobo, Hamilton Slade's form) on the character pages, 8 in the chapters (4 one-line) |
| blocks passing every check | none | 29, and 2 known from the overrides |
| failing | none | 0 |
| Contents names with no entry | not reached | 0 (the index's 22 names all found) |
| Health or Karma not a number | not reached | 1 block (Moon Knight's, item 12) |
| exit code | 1 | 1 |

What code-grids must learn. Each change was made in the scratch copy,
marked as the trial's, except 12 and 19:

1. **A parts entry's `sections` carry a fourth field** (its part).
   `roster.section_starts` wants three. Reader: one line.
2. **Two card ranges** (printed 3-8 and 52-64) in a parts entry.
   code-grids reads one `offset` and one `character_pages`; read as [3, 64],
   every chapter became a heading entry and its blocks were read twice.
   Reader: read `character_ranges`.
3. **Contents sub-entries** (each hero, Friendly and Enemy NPCs, printed
   3-8) get their synthetic header at the top of the page, which cuts the
   entry above it (the Vision's page-4 text went to a Moon Knight heading).
   Registry: `sections` cut to the two banners.
4. **The Western Heroes' `STATISTICS` subhead** (capitals, no colon, printed
   52-63) was taken as every hero's header. Reader: a registry list of lines
   that are never headers (`not_headers`, the trial's name), which
   `mark_headers` skips. It still lands as each grid's block label, which
   the reader row clears.
5. **A name over a real-name line** (Doctor Doom, The Sandman, Mysterio,
   Black Knight, Scorpion, printed 6-8): the real name became the header.
   Reader: the upper of two short title-case lines is the header (behind a
   registry flag in the trial), skipping item 4's list, or Alexander's
   header became Enemy NPCs.
6. **A title-case header under a capital line** (THE HOBART GANG over
   Hobart, printed 28): the capital line won. Reader: on a statted page, the
   line that reads as a name the page states is the header. The header
   still reads with its quote misread, so its card name is the registry's
   (decision 3).
7. **A header carrying the encounter's count**, `Average Rifleman (2)` and
   `Average Mounted Desperado (3)` (29): `statted()` found no entry for the
   name. Reader: strip the count.
8. **Twain Android prints no header** (36). Registry only: `grid_headers`.
9. **`rank_ranges` is never passed** to `read_entries`, so the Hobart Gang's
   numbers off standard (28-29) all fail. Reader: pass
   `roster.rank_ranges(book)`, as `gridbooks.py` does.
10. **Marks the crop re-read hangs in a row**: Einstein's A and E (5), Ghost
    Rider I & II's S (52), Red Wolf's R, a 1 read as `i` (57). The page
    images print them clean. Reader: `FY` read for TY, `*` and two currency
    signs in `JUNK`, `i` for 1 inside the brackets.
11. **GHOST RIDER I & II reads as I & Ill**, which `printed()` turns into
    I & III (52). Registry: the teams key and an `index_aliases` entry as
    read, and the card name is the real fix (decision 11).
12. **Moon Knight's two forms** (4) print two values on each row (code and
    number, a slash, code and number) and Health `90/150`. Cause, read on
    the page image: code-grids reads one code and number per row, so the
    Normal form reads and the Moonlight form's values are carried on the
    rows' rest into the Health and Karma labels, which then hold no number
    and are not checked. Both forms add up (Health 90 and 150, Karma 60).
    **Not made in the trial.** Reader: split each row at the slash into two
    blocks labelled Normal and Moonlight (decision 6).
13. **One-line grids** (Tyrannosaur 12, Hoplites 21, Cavemen 24, Khan's
    Champion 33, Lobo 57, and Hamilton Slade 53): code-grids reads none.
    Reader: call `gridbooks.line_grids` (with `letters_marks`) and let
    `grid_at` take its line grid.
14. **A one-line grid whose letters line is lost** (Khan's Champion 33,
    Lobo 57): the letters read below confidence (`FA SES CUR | P` on 57) and
    leave the stream, so `line_grids` finds no grid and stops at
    `one_line_grids not found: Lobo`. Reader: start the grid at its row of
    numbers or codes when a Health line follows within two lines.
15. **A form's Health and Karma printed in a sentence** under its grid, not
    on labelled lines (Hamilton Slade, 53; both hold: 46 and 36). Reader:
    read the sentence, and add a form with `entry` and `label` to its entry
    as a block, as `gridbooks.py` does and code-grids does not.
16. **Section subheads with no colon** (`KNOWN POWERS`, `BACKGROUND`,
    printed 52-63): every Western Hero read no powers section. Reader: a
    capital line that names a section opens it as a run-in does.
17. **Title-case run-ins that open a section** (`Talents:` or `Talents.`,
    `Contacts:`, `Role Playing Notes:`, on the Western Heroes and the
    chapters' blocks): read as powers. Reader: read them as sections.
18. **A mark after Twain Android's Resources** (`FE (2)` and a mark, 36).
    Reader: strip a mark after the bracketed number.
19. **A card's grid inside another hero's entry** (Lobo, 57, inside Red
    Wolf's): Lobo's entry runs on and takes the rest of Red Wolf's entry,
    his Talents, Contacts and notes. **Not made in the trial.** Reader: end
    a named one-line grid's entry where its host's text resumes. As a check,
    the trial read Lobo once as a labelled block of Red Wolf's, which keeps
    Red Wolf whole, but decision 4 makes him a card of his own.

**Read right with nothing changed:** every grid but Moon Knight's on the
character pages, once headed (items 3-5) and marked (item 10); Lobo's grid
on standard numbers once found (item 14); and the Black Knight's flying
horse, left in his text as decision 4 wants.

**So code-grids must learn 19 things: 14 reader changes** (1, 2, 4-7, 9,
10, 13-18; 4 and 5 each beside a registry field), **3 registry-only**
(3, 8, 11) **and 2 left unfixed** (12, 19). The overrides file holds 2
entries (decision 7). The trial did not run `npcs.py`. Its registry patch,
its three reader diffs and its last run are kept in the plan's store (rows
7c and 7c1, `trial/mt2/`), not the repo.

**`grid-booklets` (`scripts/msh/gridbooks.py`, ME1's, ME2's and ME3's),
with things taught to it**: the other half. Measured 2026-10-30 (plan row
7c2): a scratch copy of `scripts/msh/` and `apps/marvel-heroes/data` at
this branch's `ef61d5b1`, the mt2 entry as row 7b left it (`parts`,
`character_ranges`, `opponents`) given `"layout": "grid-booklets"`,
`rank_ranges: true` (decision 8) and trial `teams` (decision 1), and the
same trial `mt2-overrides.json` (decision 7), run on a copy of the cache
under its own `WORKSHOP_MSH_CACHE`. Four runs and four working-arounds.

**The stock reader does not stop.** It runs to the end and exits 1: every
grid of the first and second shapes is unread (item 1), no one-line grid
is read (item 4), and the Western Heroes' entries are each headed
`STATISTICS` (item 7).

| measure | stock | with every trial change |
|---|---|---|
| entries | 31: 25 with a block, 6 without | 34: 30 with a block, 4 without (The Player Characters as its banner and as its Contents line, Non-Player Characters, Friendly NPCs) |
| stat blocks | 25: 21 grids on the character pages, 4 named blocks in the chapters; no one-line grid | 31: 21 grids and 2 one-line grids (Lobo, Hamilton Slade's form) on the character pages, 8 in the chapters (4 one-line) |
| blocks passing every check | none, and 1 known (Genghis Khan's override) | 28, and 2 known from the overrides |
| failing | 24 (every one unread) | 1 (Einstein's, unread: item 3) |
| checklist names with no entry | 6 of the 8 opponents; 24 statted entries on no checklist (no `roster_sections` or `cards`) | 0 (the 23 cards and 8 opponents all found) |
| Health or Karma not a number | 24 blocks | 1 block (Moon Knight's, item 14) |
| exit code | 1 | 1 |

What grid-booklets must learn. Items 1, 2, 10 and the registry items were
made in the scratch copy, marked as the trial's; 5 and 6 are row 7c1's
changes to `gridbooks.py`, already written; the rest were not made:

1. **Rows that print the code, in capitals, before the number**, bare (`F
   RM 30`: printed 3-8, 28, 29 and 36) or bracketed (`F GD (10)`: printed
   52-63). `roster.ROW` wants the number first, and ME3's `code_first_rows`
   turns round title-case codes only, so 24 of the stock run's 25 blocks
   were unread. Reader: a mend beside ME3's, behind a registry field.
2. **What the crop re-read hangs in such a row**: a mark and an underscore
   between code and number (`RM_~ 30`, the Vision's P, printed 3), `i` for
   1 inside the brackets (Red Wolf's R, 57), and a 3 read as 8 inside them
   (`RM(80)`: Ghost Rider IV's P, 53; Red Wolf's F, 57; Shooting Star's A,
   59; Texas Twister's E, 61), where 80 is outside Remarkable's range and
   30 is its number. Reader: part of item 1's mend.
3. **Einstein's rows** (printed 5): the crop reads his A and E as marks
   and `FY` round the 6s, and the stream reads no better, so his grid is
   unread. **Not made in the trial.** Reader: code-grids' item 10 (`FY` for
   TY, marks in a row).
4. **One-line grids** (Tyrannosaur 12, Hoplites 21, Cavemen 24, Khan's
   Champion 33, Lobo 57, and Hamilton Slade 53 as Ghost Rider IV's form).
   Registry only: `one_line_grids`, with `letters_marks`, which this reader
   already reads (a form's `entry` and `label` too).
5. **A one-line grid whose letters line is lost** (Khan's Champion 33,
   Lobo 57). Reader: code-grids' item 14, a change to `gridbooks.line_grids`
   itself.
6. **A form's Health and Karma printed in a sentence** (Hamilton Slade,
   53; 46 and 36, both hold). Reader: code-grids' item 15, the same
   function.
7. **The header above a grid**: a name over a real-name line (Doctor Doom,
   The Sandman, Mysterio, Black Knight, Scorpion, printed 6-8: the real name
   became the header), `STATISTICS` over each Western Hero's grid (52-63)
   and THE HOBART GANG over Hobart (28). Registry only: MX1's `card_headers`
   and `cards`, the 22 card-page names and Hobart, which are the checklist
   too, so no `roster_sections` is needed.
8. **Twain Android prints no header** (36). Registry only: `grid_headers`.
9. **Two headers misread**: GHOST RIDER I & II as `I & Ill` (52) and
   Hobart's quote marks (28). Registry only: MX1's `speck_lines`, the line
   as read and as printed.
10. **Section subheads with no colon** (KNOWN POWERS, BACKGROUND,
    ROLE-PLAYING NOTES and HISTORY, printed 52-63). Reader: a capital line
    that is one of the registry's `section_labels` opens its section, as a
    run-in does. With it off (run 4), every Western Hero reads no powers and
    no background.
11. **Title-case run-ins** (`Talents:`, `Contacts:`, `Background:`, `Role
    Playing Notes:`, printed 3-8, 28-29 and 52-63). Registry only: MX1's
    `title_case_labels`.
12. **A mark after a Health** (Ghost Rider I & II's `46` and a bracket,
    52). Registry only: ME3's `trailing_marks`.
13. **`STATISTICS` lands as each Western Hero's block label** (52-63):
    `read_entries` takes a capital line right above a grid as a sub-block's
    name. **Not made.** Reader: clear it, as code-grids' item 4 must.
14. **Moon Knight's two forms** (4): the Normal form reads and the
    Moonlight form's values are carried into the Health and Karma labels,
    as under code-grids. **Not made.** Reader: code-grids' item 12.
15. **Lobo's entry takes the rest of Red Wolf's** (57): his Talents,
    Contacts and notes, as under code-grids. **Not made.** Reader:
    code-grids' item 19.
16. **Teams split on printed 5** (the Scarlet Witch, a Player Character,
    and Einstein, the Friendly NPC): `gridbooks.team_of` reads a team from
    a page on, so the Scarlet Witch files under MT2 The Weird, Weird West.
    **Not made.** Reader: a team that starts at a header (code-grids' teams
    name one).
17. **Twain Android's `Talents.` and `Contacts.`** with a full stop (36)
    read as powers. **Not made.** Reader: code-grids' item 17.
18. **A mark after Twain Android's Resources** (`FE (2)`, then an
    underscore and a mark, 36): `trailing_marks` strips a mark, not an
    underscore. **Not made.** Reader: code-grids' item 18.

**Read right with nothing changed:** every grid's Resources and
Popularity but the android's once its rows read (item 1), Kid Colt's
Popularity note and Two-Gun Kid's bare `GD` among them; the Hobart Gang's
numbers off standard, under `rank_ranges`; the chapters' four named blocks
as opponents; and the Black Knight's flying horse, left in his text as
decision 4 wants.

**So grid-booklets must learn 18 things: 10 reader changes** (1-3, 5, 6,
10, 13, 16-18; 5 and 6 already written), **6 registry-only** (4, 7-9, 11,
12; every field one an earlier book already reads) **and 2 left unfixed**
(14, 15, code-grids' 12 and 19). The overrides file holds the same 2
entries. The trial did not run `npcs.py`, so the encounter's count in
`Average Rifleman (2)` and `Average Mounted Desperado (3)` (decision 3) is
untried. Its registry patch, its two reader diffs and its runs are kept in
the plan's store (row 7c2, `trial/mt2/gridbooks-*`), not the repo.

**Verdict: grid-booklets.** It needs 10 reader changes where code-grids
needs 14, two of them already written in `gridbooks.py`, and six of its
fixes are fields an earlier book's entry already sets; it reads MT2's
`parts`, `character_ranges` and `opponents` as row 7b wrote them, where
code-grids had to be taught a parts entry, two card ranges, one-line grids
and forms. Both leave the same two unfixed (Moon Knight's forms, Lobo's
entry), and code-grids' one lead, Einstein's grid, is its item 10, which
grid-booklets takes as item 3.

**The decision it settles** (row 8a sets it): `"layout": "grid-booklets"`,
with `rank_ranges`, `teams` (decision 1, with item 16's split),
`letters_marks`, `one_line_grids` (the six above), `card_headers` and
`cards` (23), `grid_headers` (Twain Android), `speck_lines` (2),
`title_case_labels` and `trailing_marks`, and a field of its own for each
of the reader changes 1-2 and 10. Not set: `roster_sections`, and none of
code-grids' `offset`, `character_pages`, `index` or cut `sections`.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-30: take the survey's recommendations). Characters only is already
ruled (Nate, 2026-10-21), and so are second cards with `-mt2` ids
(2026-09-28) and a leading The dropped from a name (2026-10-21: THE VISION
is Vision).

1. **Teams:** Weird, Weird West Heroes for the three Player Characters
   (recommended, as ME2's and ME3's pregenerated heroes are Ragnarok and
   Roll Heroes and Left Hand of Eternity Heroes); **Western Heroes** for the
   eight Western Heroes and Lobo, the book's own banner (as ME3's Entities
   and Death Gods); every other card, the Non-Player Characters and the
   chapters' blocks, under **MT2 The Weird, Weird West** (as ME3's
   opponents). Not taken: West Coast Avengers, a team the Codex has, for
   the Vision, the Scarlet Witch and Moon Knight, since no block of theirs
   prints an identity line naming it.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure,
   items, places, maps or Event Cards; the biplanes' vehicle line (printed
   23) is not imported.
3. **Every grid a card** (recommended, as MH9 decision 3 and ME3's
   opponents), named by what the prose calls them: Tyrannosaur, Hoplites,
   Cavemen, Khan's Champion and Twain Android; Hobart as printed, `"Faro"
   John Hobart` (card names keep a printed quote, as Galactus's "Cat");
   Average Rifleman and Average Mounted Desperado with the encounter's
   count, `(2)` and `(3)`, dropped from the name and left in the text. Not
   taken: the count in the name, which says how many the encounter fields,
   not who the card is.
4. **The grids inside other blocks** (recommended): Hamilton Slade (printed
   53) a block of Ghost Rider IV's card labelled with his name, as ME3's
   Beta Ray Bill's humanoid form, its Health 46 and Karma 36 taken from the
   sentence that prints them (both hold); Lobo (printed 57) a card of his
   own under Western Heroes, a being of his own with a grid (as decision 3),
   his codes-only grid on standard numbers and `rank_only`, as ME3's
   codes-only grids; Black Knight's flying horse (printed 8) left in his
   card's text, not a card or a block, as MH9 decision 7's FASE rows, since
   it prints neither Health nor Karma and the adventure leaves it in the
   future. Not taken: a horse card with a derived Health and Karma (MH2's
   `no_health`).
5. **Black Knight (Nathan Garrett)** as the card's name (recommended, by
   Nate's ruling on MA1's and MH1's Ariel, 2026-10-21, that each card's name
   says which person, as ME3's Captain Marvel (Mar-Vell)): MHSP2's and
   MH8's Black Knight is Dane Whitman. Only this card is renamed; the two
   Dane Whitman cards keep their names.
6. **Moon Knight's two forms** one card with two blocks labelled Normal and
   Moonlight, as the block prints them in two columns of values, with
   Health 90 and 150 (recommended, as ME3's Mephisto's two grids are one
   card). Not taken: two cards for one man.
7. **The three failing values** as `misprint` overrides, printed and
   corrected kept (recommended, as MA4, ME3 and MH9): Genghis Khan's A and
   S codes, GD to TY, one override with the S in its `also`; Khan's
   Champion's Karma, 10 to 14.
8. **The Hobart Gang's numbers** (printed 28-29), every one inside its
   rank's range and none its standard, pass as printed under
   `rank_ranges`, as ME2's and ME3's (recommended). Not taken: an override
   per value (21 of them, plus Hobart's Resources).
9. **No card for beings statted by reference only** (recommended, as MH9
   decision 8): the Judge's Book's soldiers, dogs and dinosaurs in the
   chapters print no rank.
10. **Values printed as words** (recommended, as ME3's popularity notes and
    MH9 decision 6): Two-Gun Kid's Resources the code GD with no number,
    left with no number; Kid Colt's Popularity 20, the clause after it
    (-30 with the authorities) kept as the note it is, not the value.
11. **Names otherwise as printed** (recommended): Alexander The Great,
    Napoleon Bonaparte, Albert Einstein, Ghost Rider I & II (one card: one
    block for the two riders), Ghost Rider IV, Two-Gun Kid; the leading The
    dropped from THE VISION, THE SCARLET WITCH and The Sandman (Nate,
    2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mt2 --probe
python scripts/msh/ocr-book.py mt2
python scripts/msh/survey.py mt2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 28-130 dpi into the scratchpad.
