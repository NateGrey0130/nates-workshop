# Survey: MH9 Gates of What If (TSR6867)

> **DRAFT.** Measured up to *Cover-panel cards*. The booklet's blocks and
> grids, *Names the Codex already has*, *Quote marks*, *Which reader fits*
> and *Decisions* are not finished: the booklet is twice MH1-8's length, so
> its survey is two rows. Nothing here is imported yet.

Marvel Super Heroes adventure module, Roger E. Moore, 1986. Registry entry:
`scripts/msh/books.json` -> `mh9`. Measured 2026-10-30.

**Rows citing this book:** none yet (no data has been built).

Everything here was measured and read on the page images.

The ninth module of the MH series, through `scripts/msh/` only. Characters
only (Nate, 2026-10-21): the adventure, items and places are not imported.

## The scan

- 46 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-30 into the main
  checkout's `.cache/msh/books/mh9/` (46 pages OCR'd).
- **The booklet is 40 pages** (PDF 2-41), twice MH1-8's 16, and the back
  cover says so. The print is clean; the blocks' labels and rank words OCR
  well.
- **The scan holds no cover-panel card.** PDF 1 and 42 are the outside of
  the cover; no other page outside the booklet prints a stat block (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 606 x 772 | Cover (outside front) | - |
| 2-41 | 594 x 767 | Adventure Book | 1-40 |
| 42 | 606 x 772 | Back cover (product code 6867XXX1401) | - |
| 43 | 547 x 773 | Map: Helicarrier Combat Operations Center (colour) | - |
| 44 | 547 x 773 | Map: Plucien, Indiana Home, the entry to a prison (grey) | - |
| 45 | 1194 x 763 | Map: Latverian Embassy, NYC, a double-width spread (grey) | - |
| 46 | 2362 x 1629 | Map sheet: Castle Doom Grounds, A.I.M. Interdimensional Facility, UPC Underground Prison Complex (product code 6867XXX0701) | - |

**The two narrow pages** (PDF 43 and 44) are maps, each one page, and so is
the double-width one (PDF 45, Chapter 3's starting point marked on it).
Where each sits in the package (an inside cover, the map sheet's other side)
the scan does not show: the back cover names only the booklet and one colour
map sheet. Not one of them prints a statistic; the maps' material strengths
(Excellent walls and the like) are rank words in a legend, not a character.
None is imported.

## Offset

`survey.py` votes **printed = PDF - 1 on 37 pages** (PDF 3-41 but 7 and
30). The outliers, each read on the page image:

- PDF 7: no vote; its folio, 6, is at the foot, missed by Tesseract.
- PDF 30: a vote of 250 (k = -220), Mephisto's Karma at the foot of
  column 1; the folio under it prints 29.
- PDF 42: 47 (k = -5), the bar code's digits. PDF 46: 5 (k = 41), on the
  map sheet. Neither is a folio.

Printed 1 (PDF 2) is the title page, which prints no folio and the product
code 6867XXX1501. Every other booklet page prints its folio. So `parts`, as
MH5-8, with the covers and the four map pages as parts of their own with
`offset` null.

## The book's own authority lists

No Contents and no index. The banners, read on the page images:

| printed | banner |
|---|---|
| 1 | (title page: no banner; the Watcher's greeting and the credits) |
| 2 | Judge's Introduction (to 3) |
| 4 | Chapter 1: Night Moves |
| 7 | Chapter 2: The Visitors |
| 9 | Chapter 3: The Victor's Circle |
| 12 | Chapter 4: Helicarrier Hurricane |
| 14 | Chapter 5: Otherworld Allies |
| 16 | Chapter 6: A Nice Place, But... |
| 17 | Chapter 7: Highway to Hell |
| 19 | Chapter 8: Taking A.I.M. |
| 21 | Non-Player Character Roster (mid column 1, under art) |
| 30 | New PC Heroes |
| 36 | Marvel Universe PC Heroes |

Each chapter opens with a `Chapter N:` line and its title over two lines at
the top of column 1, then `NPC ROSTER:`, `SUMMARY:` and `SETTING:` run-ins
and ADVENTURE, AFTERMATH and `KARMA:` parts. The Non-Player Character Roster
groups its characters under `CHAPTER N` subheads; New PC Heroes are the
divergent world's heroes and Marvel Universe PC Heroes the visiting ones
(THE FANTASTIC FOUR a subhead under it). Tesseract reads every banner, the
chapter titles split over two lines (`Heli-` / `carrier`, `Other-` /
`world`). The coverage checklist will be this survey's list, carried as
`cards` and `opponents` (row 7b).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's labels and values
  are two sub-columns of one column.
- **The blocks are the MH series' labelled blocks with numbers**: seven
  `Fighting: Excellent` rows (rank words in title case, not MH1-8's
  capitals), then `Health:`, `Karma:`, `Resources:` and `Popularity:` with
  numbers, then labelled sections. Mephisto's Karma (printed 29) prints no
  colon.
- **Section labels**, counted on the OCR of printed 21-40 and read on the
  images of printed 23 and 29: `Known Powers:` (33), `Background:` (22),
  `Personality:` (22), `Talents:` (21), `Background and personality:` (13,
  one label: Valor's on printed 29) and `Equipment/Possessions:` (5). The
  Wasp (printed 23) prints Background and Personality as two.
- **Ranks**: the words Feeble to Unearthly, plus `Shift X` (a Strength,
  printed 27) and `Class 1000` (an Endurance, printed 29).
- **The chapters' one-line grids** print an `F A S E R I P` row over
  two-letter codes in capitals, and `Health:` and `Karma:` (or `Karma:
  None`) under them. The codes read are FE, PR, TY, GD, EX, RM and IN, and
  two of the book's own: **RE** for Remarkable (the guardsmen robots,
  printed 10: four RE, and their Health of 120 holds on 30 each) and **GO**
  for Good (Valor's four-code FASE row, printed 29: GO GO TY GO, where every
  other grid read prints GD). Both are in `rank_aliases`. No AM, MN or UN
  code is in the OCR.
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Where the blocks are

From the OCR's label counts (row 7b reads each one): one-line grids inside
the chapters (a code row read on printed 4, 8, 10 and 20, and a Health
line with no code row read on printed 5, 7, 13 and 17), and labelled blocks on printed 21-40: the Non-Player
Character Roster (21-29), New PC Heroes (30-35) and Marvel Universe PC
Heroes (36-40). Not one page outside the booklet holds a Health, Karma or
rank row.

## Cover-panel cards

**None.** The OCR of PDF 1 and 42-46 holds no `Health`, `Karma`,
`Fighting` or rank row, and their images show the cover art, the back
cover's blurb and the five maps. So `panels` is empty, as MH8's, and there
is no cover card to hold to Health = F+A+S+E and Karma = R+I+P. No
misprint is recorded yet: every block is in the booklet (row 7b).

## The booklet's grids

**Not finished** (row 7b).

## Names the Codex already has

**Not finished** (row 7b).

## Quote marks

**Not finished** (row 7b).

## Which reader fits

**Not finished.** This survey sets no `layout`.

## Decisions this survey leaves open

**Not finished** (row 7b). Characters only is already ruled (Nate,
2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mh9 --probe
python scripts/msh/ocr-book.py mh9
python scripts/msh/survey.py mh9
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-110 dpi into the scratchpad.
