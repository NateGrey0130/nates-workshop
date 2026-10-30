# Survey: MH7 The Last Resort (TSR6864)

> **DRAFT.** Measured up to *Which reader fits*, which is not finished: the
> trial parse is the next row's. Nothing here is data yet.

Marvel Super Heroes adventure module, Kim Eastland. Registry entry:
`scripts/msh/books.json` -> `mh7`. Measured 2026-10-29.

**Rows citing this book:** none yet (no data imported).

Everything here was measured and read on the page images unless it says it
was read in the OCR.

The seventh module of the MH series, through `scripts/msh/` only. Characters
only (decision 3): the adventure, items and places are not imported.

## The scan

- 23 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-29 into the main
  checkout's `.cache/msh/books/mh7/` (23 pages OCR'd).
- The print is clean and every card's rank rows OCR well. Tesseract reads
  the chapter titles except Chapter 6's (set under the chapter's art), and
  most folios not at all (faint).
- **PDF 20 is set sideways** (the card backs), as MH5's is; Tesseract reads
  it anyway, two cards with their labels and values in separate runs.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 598 x 772 | Cover (outside front) | - |
| 2 | 594 x 767 | Inside front cover: Hawkeye, Tigra | - |
| 3-18 | 594 x 767 | Adventure Book | 1-16 |
| 19 | 594 x 767 | Inside back cover: Mockingbird, Wonder Man | - |
| 20 | 552 x 767 | Card sheet, backs: seven cards' stat lines, sideways | - |
| 21 | 552 x 767 | Card sheet, fronts: seven portraits and an Avengers identicard | - |
| 22 | 598 x 772 | Back cover (product code 6864XXX1401) | - |
| 23 | 1515 x 2303 | Map | - |

So the 594 x 767 run of PDF 2-19 is not an 18-page booklet: it is the
16-page booklet between the cover's two inside panels, which share its size.
The two narrower pages (PDF 20-21) are the gatefold's cut-out character
cards. Unlike MH5's scan, the panels sit before and after the booklet, so
they are named in PDF order, inside front then inside back (decision 2).

## Offset

`survey.py` votes **printed = PDF - 2 on 8 pages** (PDF 6 and 12-18), and no
page votes otherwise. Folios 1, 2, 3, 5, 6, 8 and 9 were read on crops of
the feet of PDF 3, 4, 5, 7, 8, 10 and 11. **Pages that print no folio:**
the two panels (PDF 2, 19), the card sheet (20, 21), the cover (1, 22) and
the map (23), and printed 7 (PDF 9) shows none, its chapter art running to
the foot. Printed 16 (PDF 18) prints the product code `6864XXX1501` at the
foot of its first column beside its folio. So `parts`, with the panels, the
card sheet, the cover and the map as parts of their own with `offset` null.

## The book's own authority lists

No Contents and no index. The banners: Introduction (printed 1, the title
page, no banner), *The Mandarin's Plan* (2, with *Using the Map* beside it),
then eight chapters, each a small `CHAPTER N:` line over a title in large
capitals: 1 *The Phantom Jamboree* (3), 2 *Floral Fiends!* (5), 3
*Avengers on Ice* (6), 4 *Beware the Pyro-Maniac!* (7, printed in double
quotes), 5 *Tornado Alley!* (8, read in the OCR and its Karma table), 6
*If One Should Betray...* (9), 7 *The Caverns of Chu* (10) and 8
*Vacation's End* (11). Chapters 1-7 run Campaign, Battle and Aftermath
(Chapter 7 twice over, Campaign 1 to Battle 2) and end on Karma Tables 3-9;
Chapter 8 prints none of them. The cards follow on printed 12-16,
unbannered. The coverage checklist is this survey's list, carried as
`cards` and `opponents`.

## Stat blocks: 13 full and 1 grid

**Full blocks** print a name in capitals with a trademark sign, one or two
identity lines, seven `Fighting: GOOD` rows in rank words, `Health:`,
`Karma:`, `Resources:`, `Popularity:`, then labelled sections.

| card | where | Health | Karma | checks |
|---|---|---|---|---|
| Rick Jones | printed 12 | 24 | 22 | yes |
| Mesmerized Scouts | 12 | 24 | 22 | yes |
| Blizzard | 12 | 46 | 44 | yes |
| Plantman | 13 | 24 | 22 | yes |
| Pyro | 13 | 56 | 26 | yes |
| Radioactive Man | 14 | 66 | 32 | yes |
| Whirlwind | 14 | 90 | 18 | yes |
| Mandarin | 15 | 90 | 50 | yes |
| Iron Man | 16 | 155 | 36 | yes |
| Hawkeye | inside front cover | 70 | 22 | yes |
| Tigra | inside front cover | 130 | 56 | yes |
| Mockingbird | inside back cover | 56 | 32 | yes |
| Wonder Man | inside back cover | 215 | 18 | yes |

**Every block holds**: Health = F+A+S+E and Karma = R+I+P on `ranks.json`'s
standard numbers, all 26 values. **No misprint**, so no override.

**One grid**, with no name line, inside Pyro's card under his FIRE CONTROL.
power: the maximum abilities of the creatures of flame he forms, a letter
row, `In In In In` with a dash for each of R, I and P, and `Health = 160
(maximum)`. It holds (4 x 40).

**Shapes the parser must accept**, read on the page images:

- the sections are labels ending in a colon, in no fixed order, any absent:
  Rick Jones prints only Background; the Mesmerized Scouts print Background
  before Talents; Plantman prints Equipment/Possessions and no Powers;
  Mockingbird prints Talents (with run-ins) and Equipment/Possessions and no
  Powers; Hawkeye, Tigra, Wonder Man print Powers then
  Equipment/Possessions; Tigra's Equipment/Possessions ends in a full stop.
  So `section_labels` carries Equipment/Possessions as well as Powers,
  Talents and Background;
- Pyro's Popularity is negative (`-10`);
- the Mandarin's MAKLUAN RINGS. power holds `Left hand:` and `Right hand:`
  and ten ring entries, each a name, a dash and a finger;
- Hawkeye's ARROWS. holds a list of fourteen arrow types, one per line;
- Iron Man's powers run from printed 16's first column past its folio into
  the third column (IMAGE PROJECTOR., DIGGING ABILITY.);
- **specks**: a small mark after `BATTLE` in Mockingbird's BATTLE STAVE.
  head (read `BATTLE'`; seen on the page image), and two stray single marks
  read in the OCR and not yet looked at, at the start of a line of Wonder
  Man's ENVIRONMENTAL INDEPENDENCE. and after Iron Man's header.

**Printed 15 also prints an item block**, the Mandarin's Mento Intensifier
Selective Concentrator (Body, Controls, Size, Complexity, Power Source and a
power), under the Mandarin's card. It is not a character (decision 9).

**Variants in prose only, with no block:** Plantman's plants (Chapter 2,
vines, roots and trees given a rank or two each) and the wildlife table of
printed 2. Not imported.

## The card sheet

PDF 20 repeats seven cards (Hawkeye, Tigra, Mockingbird, Wonder Man, Iron
Man, Radioactive Man, Rick Jones) with each rank in words. Its ranks, Health,
Karma and Popularity agree with the blocks (read in the OCR, Mockingbird's
and Wonder Man's in column order). **It differs once:** Iron Man's Resources
is GOOD on the sheet and TYPICAL in the booklet, both read on the page
images. The booklet's block is the one imported (decision 8).

## Names the Codex already has

| MH7 card | already a card in | note |
|---|---|---|
| Hawkeye | MHSP1, MHSP2 (West Coast Avengers) | |
| Tigra | MHSP2 (West Coast Avengers) | |
| Mockingbird | MHSP2 (West Coast Avengers) | |
| Wonder Man | MHSP2 (West Coast Avengers) | |
| Iron Man | MHSP1, MHSP2 (West Coast Avengers) | MH7's is James Rhodes |
| Blizzard | MH5 | the same ranks, Health and Karma |
| Pyro | MA1 (Freedom Force) | |
| Whirlwind | MA1 (Miscellaneous Mutants) | |

Each MH7 card is a card of its own with a `-mh7` id (Nate, 2026-09-28).
Rick Jones, the Mesmerized Scouts, Plantman, Radioactive Man and the
Mandarin are new to the Codex. The team **West Coast Avengers** already
exists (MHSP2).

## Quote marks

On the cards every single mark is an apostrophe inside or after a word, or
a misread: Hawkeye's quoted pin and Pyro's quoted critics' phrase are double
quotes on the page (read on crops), which the OCR reads with a single mark
at one end; Mockingbird's nickname closes on a double quote the OCR reads as
two singles. No card prints a single-quoted phrase. A trademark sign follows
every card's name and many names in the prose.

## Which reader fits

**Not finished.** The trial parse is row 1b's. What is measured so far:

- **The panels are cropped close at the top**, as MH5's are: MOCKINGBIRD on
  PDF 19 boxes at 2.4% of the page's height, above the 3% head band
  `booklet.stream_of` keeps (MH5's `panel_head`). HAWKEYE (4.4%), TIGRA and
  WONDER MAN are inside it. No panel line falls below the 95.5% foot.
- On the booklet pages every header is inside the band (3.7-4.3% at the
  top of a column).
- The candidate is `cover-panels` (`scripts/msh/coverpanels.py`), MH5's and
  MH6's reader: the cards are on the cover's panels and the booklet's last
  five pages, in rank words with no ability numbers.

This survey sets no `layout`: that is the parser row's choice.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-29: take the survey's recommendations).

1. **Teams:** West Coast Avengers for Hawkeye, Tigra, Mockingbird, Wonder
   Man and Iron Man (James Rhodes), the team MHSP2 already files them under,
   as MH1-3 and MH5 file their heroes under their team; every other card under **MH7
   The Last Resort** (recommended), Rick Jones, an honorary Avenger, included.
2. **The panels' names:** PDF 2 the inside front cover, PDF 19 the inside
   back (recommended, PDF order: one before the booklet, one after).
3. **Characters only** (recommended).
4. **Misprints:** none found, so no override.
5. **The Mesmerized Scouts** as a card (recommended, as MH5's Hammer's
   Mercenaries).
6. **Pyro's fire creatures** as an entry of their own, **Fire Creatures**,
   cut from his FIRE CONTROL. text (recommended, as MH5's Humanoids were cut
   from the Leader's card), or left in the power's text.
7. **Names:** as printed, no leading The to drop (the Mandarin's header is
   MANDARIN); Mesmerized Scouts as printed.
8. **The card sheet** checked against the blocks and not imported
   (recommended); the booklet's Iron Man Resources (TYPICAL) is the one
   played.
9. **The Mento Intensifier Selective Concentrator** not imported, an item
   (recommended, decision 3).
10. **The fire creatures' Karma and R, I, P** (printed as dashes): left unset
    (recommended, as MH5's grids that print none).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mh7 --probe
python scripts/msh/ocr-book.py mh7
python scripts/msh/survey.py mh7
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-200 dpi into the scratchpad.
