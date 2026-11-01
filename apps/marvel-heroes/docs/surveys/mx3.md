# Survey: MX3 Reap the Whirlwind (TSR6877)

> **DRAFT** (row 4a, 2026-10-31). Everything down to *Quote marks* is
> measured; *Which reader fits* is not finished and is the trial parse's
> (row 4c). No data has been built from this book.

Official Game Adventure for Marvel Super Heroes, Caroline and Warren Spector,
1987; the third chapter of the Future in Flames series (the back cover).
Registry entry: `scripts/msh/books.json` -> `mx3`. Measured 2026-10-31.

**Rows citing this book:** 0 `msh_book_text` rows (no data row has run).

Everything here was measured and read on the page images.

The third module of the MX series, through `scripts/msh/` only. Characters
only (Nate, 2026-10-21): the adventure, items and places are not imported.

## The scan

- 37 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 on every page),
  cached 2026-10-31 into the main checkout's `.cache/msh/books/mx3/`
  (`manifest.json`: 300 dpi, `--psm 3`, Tesseract 5.4.0, 37 pages OCR'd).
- **One 32-page booklet**, its covers, two inside covers and one map sheet.
  The back cover names the package as a 32-page book and a full-colour map.
  The print is clean; the grids, the headers and the run-in labels OCR well,
  the banners (capitals in a brick band) mostly do not.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 589 x 772 | Cover (outside front) | - |
| 2 | 589 x 772 | Stark Enterprises Canada floor plan (the inside front cover) | - |
| 3-34 | 594 x 767 | Adventure Book | 1-32 |
| 35 | 589 x 772 | Train car plans (the inside back cover): sleeper, coach, mutant containment car, engine | - |
| 36 | 589 x 772 | Back cover (product code 6877, ISBN 0-88038-481-6) | - |
| 37 | 1538 x 2352 | Map sheet: a station master's house, a train station, the Automated Sentinel Assembly Plant | - |

The Contents names neither inside cover, unlike MX1's, but each is a part of
its own with `offset` null, as MX1's are. Neither inside cover, nor the map
sheet, prints a statistic. None is imported.

## Offset

`survey.py` votes **printed = PDF - 2 on 23 pages** (PDF 10, 12-21 and
23-34). The rest, each read on the page image:

- PDF 4-9, 11 and 22: their folios (2-7, 9 and 20) are at the foot, missed
  by Tesseract. PDF 22 is full-page art and still prints its folio.
- PDF 3 (printed 1): the title and Contents page, no folio.
- PDF 36: a vote of 30 (folio 6), the bar code's leading digit. Not a folio.
- PDF 2: a vote of -5 (folio 7), a mark on the floor plan read at
  confidence 0. Not a folio.

So every booklet page but the title page prints its folio, and every one
agrees. `parts`, as MX1's and MX2's single booklet, with the covers, the
inside covers and the map sheet as parts of their own.

## The book's own authority lists

**A Contents** on printed 1 (PDF 3), one column, transcribed from the page
image (the OCR mangles the dot leaders) and stored as `sections`. Every
entry was read on its page, its banner across the top of the page:

| printed | Contents | banner as printed |
|---|---|---|
| 2 | Mutants Arise | MUTANTS ARISE! |
| 4 | For Judges Only | FOR JUDGES ONLY |
| 6 | Mutie, Mutie, Who's Got the Mutie? | MUTIE, MUTIE, WHO'S GOT THE MUTIE? |
| 12 | Ghost in the Machine | GHOST IN THE MACHINE |
| 22 | You're In the Army Now | YOU'RE IN THE ARMY NOW |
| 31 | Sentinels and SWAT:AM Teams | SENTINELS AND SWAT:AM TEAMS |

**Every page agrees**, so there is no `contents_errata`. The first banner
adds an exclamation mark; the registry keeps the Contents as printed, as
MX1's does. The banners are the only text on the six pages set that way.

**No index, no PC roster and no rank chart.** The coverage checklist is this
survey's list, carried as `cards`, `opponents` and `tiers` (*Stat blocks*).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's rows and its
  totals are two sub-columns of one column.
- **Two grid shapes, both code first** (read on the page images of printed
  6, 9, 16, 23, 27, 31 and 32):
  1. **The full grids** (all but SWAT:AM): a bold title-case header, no
     identity line, then seven rows of the row letter, **the code, then the
     number in brackets**, with `Health =`, `Karma =`, `Resources =` and
     `Popularity =` beside rows F, S, R and P. The five grids inside the
     chapters print **no space** before the bracket (`PR(4)`, `M(30)`,
     `Shift 0(0)`); the five sentinels in the roster section print **one
     space** (`EX (20)`, `Shift X (150)`), as MX2's cards do. MX1's sentinels
     printed the number first; these do not.
  2. **One codes-only grid** (SWAT:AM, printed 32): an `F A S E R I P` row,
     a row of seven codes, then `Health: 46` and `Karma: 22` on lines of
     their own, under its bold subhead, as MX1's and MX2's.
- **Totals**: every full grid prints `Resources = 0` and `Popularity = 0`
  but Sebastian Shaw's, whose `Resources =` wraps its `IN(40)` onto a line of
  its own below row R, and whose Popularity is 15. The Omega Sentinel's
  `Resources =` carries a speck the OCR reads as a colon.
- **Section labels**, counted on the OCR of all 37 pages and read on the
  images: `Known Powers:` (12: the four narrative cards, the Maintenance
  Robots, the five sentinels, and two AS-1A armor entries, which are items),
  `Talents:` (5), `Contacts:` (4), `Background:` (4) and `Equipment:` (1,
  SWAT:AM's gear). Bold title-case run-ins; SWAT:AM's two are plain. Powers
  are italic run-in heads ending in a colon. The Maintenance Robots' first
  power runs on the `Known Powers:` line.
- **Ranks**: PR, TY, GD, EX, RM, IN, AM, MN, UN, `Shift X` (the Mark VI's,
  Alpha's and Omega's Endurance) and `Shift 0` (the Maintenance Robots'
  Intuition and Psyche, printed `Shift 0(0)`). In `rank_aliases`. No FE or
  Fb is printed. Gilda Ginsel's `M(30)` is a misprint, not an alias (below).
- **What the OCR does to the grids**, for the reader row: row S reads `Ss`
  or `iS)` and row I `|` or `l`; `RM (30)` reads `RM (80)` twice (the Mark
  VI's F, the Omega's R); the Alpha's header reads `Aipha`; SWAT:AM's
  letters row is not read as a row of letters by a strict pattern.
- **`survey.py` finds 10 blocks and reads none of them**: it finds the ten
  `Health =` lines (SWAT:AM prints `Health:`), but its header rule wants
  capitals and its row pattern the number before the code. Its block count
  is not this book's measure.

## Where the blocks are

- **Inside the chapters** (opponents): printed 6 (Gilda Ginsel, near the
  foot of column 3; her powers run on to printed 7, where her talents,
  contacts and background are), printed 9 (Bill Gregson, foot of column 3;
  his text runs on to printed 10), printed 16 (Marco Pene, column 1),
  printed 23 (Sebastian Shaw, column 1; his Background runs on to printed
  24, ending at the subhead This Ain't No Summer Camp) and printed 27 (the
  Maintenance Robots, column 2).
- **The roster section**, Sentinels and SWAT:AM Teams (printed 31-32): the
  Mark IV and Mark V (printed 31), the Mark VI, Alpha and Omega (printed 32,
  columns 1-2) and SWAT:AM (printed 32, column 3).

The Health the OCR finds anywhere else is rules and power prose (printed 23,
24, 27 and 31) and the AS-1A armor's (printed 21, an item). Not one page outside the booklet holds a
Health, Karma or rank row, and no NPC is statted in prose (no rank word
before an ability name anywhere but the armor's).

## Stat blocks: 11, all with a header

| printed (PDF) | name | shape | F A S E R I P as printed | Health | Karma |
|---|---|---|---|---|---|
| 6 (8) | Gilda Ginsel | 1, no space | PR 4, TY 6, TY 5, TY 7, GD 10, GD 15, **M** 30 | **50** | **35** |
| 9 (11) | Bill Gregson | 1, no space | TY 7, TY 5, GD 8, TY 7, GD 10, GD 10, TY 5 | **40** | **20** |
| 16 (18) | Marco Pene | 1, no space | EX 16, EX 20, GD 10, GD 15, GD 10, EX 16, EX 20 | **55** | **10** |
| 23 (25) | Sebastian Shaw | 1, no space | RM 30, GD 10, GD 10, AM 50, EX 20, EX 20, RM 30 | 100 | 70 |
| 27 (29) | Maintenance Robots | 1, no space | GD 15, EX 20, EX 20, MN 75, PR 4, Shift 0 0, Shift 0 0 | **35** | 0 |
| 31 (33) | Mark IV Sentinel | 1, space | EX 20, EX 20, AM 50, MN 75, TY 6, TY 6, TY 6 | 165 | 0 |
| 31 (33) | Mark V Sentinel | 1, space | EX 20, EX 20, AM 50, UN 100, GD 10, TY 6, TY 6 | 190 | 0 |
| 32 (34) | Mark VI Sentinel | 1, space | RM 30, EX 20, AM 50, Shift X 150, GD 10, GD 10, TY 6 | 250 | 0 |
| 32 (34) | Alpha Sentinel | 1, space | AM 50, IN 40, AM 50, Shift X 150, EX 20, GD 10, GD 10 | 290 | 0 |
| 32 (34) | Omega Sentinel | 1, space | AM 50, IN 40, AM 50, Shift X 150, RM 30, EX 20, GD 10 | 290 | 0 |
| 32 (34) | SWAT:AM | 2 | EX GD GD TY TY TY GD | 46 | 22 |

Resources and Popularity: Shaw `IN (40)` and 15; every other full grid 0
and 0; SWAT:AM prints neither.

**The book checks itself**, each value read on a crop of the page image at
110-300 dpi, the codes-only grid on each code's standard number
(`ranks.json`):

| measure | count |
|---|---|
| Health = F+A+S+E | **7 of 11**; Gilda Ginsel (22, printed 50), Bill Gregson (27, printed 40), Marco Pene (61, printed 55) and the Maintenance Robots (130, printed 35) fail |
| Karma = R+I+P | **2 of 11** (Shaw, SWAT:AM); the five sentinels' and the Maintenance Robots' `Karma = 0` (printed on purpose, below), and Gilda (55, printed 35), Bill (25, printed 20) and Marco (46, printed 10) |
| every number within its rank code's range | **10 of 11**; Gilda's P prints `M`, which is no code |
| every number its rank code's standard | **7 of 11** (Shaw, the sentinels, SWAT:AM); twelve values are inside their range but not the standard: Gilda's S 5, E 7 and I 15; Bill's F 7, A 5, S 8, E 7 and P 5; Marco's F 16, E 15 and I 16; the Robots' F 15 |

**No reading saves the four failing grids.** Each fails on its printed
numbers, on each code's standard number and on each code's lowest number
(the reading MX2's Braddock held on); no single wrong value explains any of
them. Gilda's and Marco's printed Karma fall short of their sums by 20 and
36; Bill's Health is 13 over its sum and his Karma 5 under. The Robots'
Health 35 is their F and A alone.

**The misprints, each read on the page image** (printed page: name: field
printed -> corrected, the correction the book's own arithmetic on the
printed numbers, as decision 4 recommends):

| misprint | the book's own arithmetic |
|---|---|
| 6:Gilda Ginsel:P code M -> RM (30) | M is no code; 30 is Remarkable's standard |
| 6:Gilda Ginsel:Health 50 -> 22 | 4+6+5+7; no reading of her codes makes 50 |
| 6:Gilda Ginsel:Karma 35 -> 55 | 10+15+30 |
| 9:Bill Gregson:Health 40 -> 27 | 7+5+8+7 |
| 9:Bill Gregson:Karma 20 -> 25 | 10+10+5 |
| 16:Marco Pene:Health 55 -> 61 | 16+20+10+15 |
| 16:Marco Pene:Karma 10 -> 46 | 10+16+20 |
| 27:Maintenance Robots:Health 35 -> 130 | 15+20+20+75 |

**Printed on purpose:** the five sentinels and the Maintenance Robots print
`Karma = 0`, `Resources = 0` and `Popularity = 0` (robots, as MX1's and
MX2's sentinels). Their R, I and P are printed, so Karma = R+I+P cannot
hold.

## Entry kinds

1. **A named character with a full grid inside a chapter**: Gilda Ginsel (a
   mutant who masks other mutants), Bill Gregson (a mutant prisoner), Marco
   Pene (a hound, a psychic mutant tracker) and Sebastian Shaw. Each header
   follows the prose that introduces the character; Gilda's Background
   run-in only points back to that prose.
2. **A robot type with a full grid inside a chapter**: the Maintenance
   Robots (printed 27).
3. **A robot type with a full grid in the roster section**: the five
   sentinel marks, a header and no identity line.
4. **A type with a codes-only grid**: SWAT:AM, under its subhead.
5. **Characters in the prose only**, named and not statted: the three
   Non-Player Characters subsections (printed 10-11, 14-15 and 18-19, about
   twenty names; the last is Stark Enterprises Canada's staff, whose
   offices are the inside front cover's), and Nick Fury, Jim Rhodes and
   Tony Stark in the chapters.
6. **Gear with ranks**, out of scope by Nate's ruling: the AS-1A armor
   (the helmet, printed 17; the whole armor, printed 21, whose prose gives
   its wearer four ranks and a Health that are not their sum) and SWAT:AM's
   equipment.

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
a `-mx3` id:

- **The five sentinels**: MX1's and MX2's cards of the same names, and MA1's
  `Mark IV & V Sentinels`, `Alpha Sentinel` and `Omega Sentinel` (The Mutant
  Menace), read against `npcs.json`. **Every MX3 sentinel prints MX1's and
  MX2's numbers and codes**, row for row and Health for Health. MH1's and
  MHSP2's `Sentinels` are other blocks of the same machines. MX3 has no
  Nimrod.
- **SWAT:AM**: MX1's and MX2's, the same seven codes, Health and Karma.
- **Sebastian Shaw** is MA1's `Black King` (Hellfire Club, MA1 p.24, whose
  identity line names him): the same seven numbers and codes, Health 100,
  Karma 70 and Resources In (40); MA1 prints Popularity `15*`, MX3 `15`. No
  card is named Sebastian Shaw today.

Every other name (Gilda Ginsel, Bill Gregson, Marco Pene, the Maintenance
Robots) is new to the Codex.

## Quote marks

**The book prints single quotes of its own, once that was found.** Measured
on the OCR of all 37 pages: 59 opening and 57 closing curly doubles, 6
straight doubles, 13 opening and 416 closing curly singles (mostly
apostrophes) and 16 straight singles. The book sets its double marks as two
strokes, which the OCR often splits into a double and a single or two
singles. The 26 lines holding a single mark that is not an apostrophe inside
or after a word were each read on the image or placed by their text:

- doubles split by the OCR: printed 3, 4, 6, 12, 19, 21, 22 and 25;
- apostrophes for a dropped letter (`'em`, `ol'`, `lookin'`) or a misread
  one: printed 7, 13, 17 and 22;
- foot marks (a 20-foot gap, a 100-foot drop): printed 26 and 28;
- art, maps and the covers: two lines of PDF 2, printed 25 (a drawing's
  edge), PDF 36 and seven lines of PDF 37;
- **one pair of the book's own**: printed 13, a nickname in single quotes
  inside a double-quoted line, in Rhodey's Story (adventure prose, not a
  character's text).

So the rule is MA1's, not MHSP1's: a single mark may be the book's, and a
lost closing single is a `text` override read off the page, never a rule.
The one pair found is in prose this import does not take, so **the data row
must confirm** on the character pages that no card's text holds another.

## Which reader fits

**Not finished.** The trial parse is row 4c's. What this survey measured
for it: every grid is code first, as MX2's, so the nearest reader is
`grid-booklets` (`scripts/msh/gridbooks.py`) with MX2's `code_rows`; the
chapter grids' missing space before the bracket, Shaw's wrapped Resources,
the opponents whose text runs on to the next page (`continues`), the
Maintenance Robots' `Shift 0(0)` rows and SWAT:AM's subhead read as a
run-in (MX1 reader item 7, MX2's `not_run_ins`) are the places to look.
The entry sets no `layout` until then.

## Decisions this survey leaves open

Each has a recommendation, the one MX1, MX2 and MT3 took where they had the
same question (Nate 2026-10-31: take the survey's recommendations).

1. **Teams.** The book has no team sections. Recommendation: every card
   under the book's title, **MX3 Reap the Whirlwind**, as MX1 and MX2 filed
   theirs; the five sentinels each a card of their own, as each prints its
   own header. Not written to the registry until decided.
2. **Page citations.** Recommendation: MX1's single-booklet shape,
   `MX3 Adventure p.23` (the part's `cite` is `Adventure`).
3. **Names.** Recommendation: each header as printed (**Gilda Ginsel**,
   **Bill Gregson**, **Marco Pene**, **Sebastian Shaw**, **Maintenance
   Robots**, the five sentinels) and SWAT:AM's subhead, as MX1 and MX2 kept
   theirs. Shaw is a card of his own under the name MX3 prints, not MA1's
   Black King.
4. **The misprints.** Recommendation: overrides keeping printed and
   corrected, as listed under *Stat blocks*: Gilda's `M` to RM (30), and each
   failing Health or Karma corrected to the sum of the printed numbers, the
   numbers kept, as MX1's Typical Rogue and MX2's codes-only grids were
   corrected to the sum of what they print; a block with two faults carries
   the second in its `also`. The six robots' `Karma = 0` kept `as_printed`,
   as MX1's and MX2's sentinels. The alternative not recommended: all four
   failing grids `as_printed`, on the ground that no reading of any of them
   adds up, which would leave the GM tools playing a Health the book's own
   ranks contradict.
5. **The twelve numbers inside a range but not its standard** (Gilda,
   Bill, Marco, the Robots). Recommendation: `rank_ranges` for this book, as
   MX2 took for fourteen values and ME2 for twenty-seven, rather than twelve
   `also` entries.
6. **Gilda Ginsel's Background**, which only points back to the chapter's
   prose. Recommendation: the card keeps the run-in as printed; the prose
   above her grid is the adventure's and is not imported (Nate, 2026-10-21).
7. **Characters only.** The AS-1A armor, SWAT:AM's equipment, the floor
   plan, the train cars and the map are not imported (Nate, 2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mx3 --probe
python scripts/msh/ocr-book.py mx3
python scripts/msh/survey.py mx3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at
20-300 dpi into the scratchpad, never into the repo.
