# Survey: MH5 Cat's Paw (TSR6857)

Marvel Super Heroes adventure module, Jeff Grubb, 1984. Registry entry:
`scripts/msh/books.json` -> `mh5`. Measured 2026-10-23.

**Rows citing this book:** none yet (survey only; no data imported).

**DRAFT, stopped mid-row (2026-10-23).** Everything above *Which reader fits*
was measured and read on the page images. The trial parse is begun, not
finished, and the Marvel smoke suite has not been run on this branch.

The fifth module of the MH series, through `scripts/msh/` only. Characters
only (decision 3): the adventure, items and places are not imported.

## The scan

- 23 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-23 into the main
  checkout's `.cache/msh/books/mh5/` (23 pages OCR'd).
- The print is clean and the cards' rank rows OCR well. Tesseract does not
  read the titles of Chapters 3-6 (display lettering) or most folios (faint).
- **PDF 20 is set sideways** (the card backs); Tesseract's page segmentation
  reads it upright anyway. Northstar's card there loses no row in the OCR:
  the card prints none (below).

| PDF | part | printed |
|---|---|---|
| 1 | Cover (outside front) | - |
| 2-17 | Adventure Book | 1-16 |
| 18 | Inside front cover: Shaman, Snowbird, Sasquatch | - |
| 19 | Inside back cover: Puck, Heather, Aurora, Gary Cody | - |
| 20 | Card sheet, backs: eight cards' stat lines, sideways | - |
| 21 | Card sheet, fronts: eight portraits | - |
| 22 | Back cover | - |
| 23 | Map | - |

Printed 1 says the inside cover describes the heroes and that cut-out cards
are on the gatefold. Which of PDF 18 and 19 is the front panel the scan does
not show; they are named in PDF order (decision 2).

## Offset

`survey.py` votes **printed = PDF - 1 on 6 pages** (PDF 11-16), and no page
votes otherwise. Folios 2 and 9 were read on crops of PDF 3 and 10; printed 1
(the title page) prints none; PDF 17 prints the product code `6857XXX1501` at
its foot, as MH4's printed 16 does. So `parts`, with the panels and the card
sheet as parts of their own with `offset` null.

## The book's own authority lists

No Contents and no index. The banners, read on the page images: Introduction
(printed 1, the title page), Chapter 1 *The Haunting of Harris House* (2),
Chapter 2 *Enter...The Hulk?* (4), Chapter 3 *When the Hammer Falls* (6),
Chapter 4 *White Water, White Death* (8), Chapter 5 *Ice Station Gamma* (9,
running to 10 as Campaign 1, Battle 1, Campaign 2, Battle 2, Aftermath) and
Chapter 6 *Endings* (11). The cards follow on printed 12-16, unbannered. The
coverage checklist is this survey's list, carried as `cards` and `opponents`.

## Stat blocks: 20 full and 5 one-line grids

**Full blocks** print seven `Fighting: GOOD` rows in rank words, `Health:`,
`Karma:`, `Resources:`, `Popularity:`, then `Powers:` with run-in powers,
`Talents:` and `Background:`.

| card | where | Health | Karma | checks |
|---|---|---|---|---|
| Kimara, the Cloudstalker | printed 10, Ch. 5 Battle 2 | 350 | 110 | yes |
| The Leader | printed 12 | 56 | 125 | Karma: ranks give 120 |
| Cascade | 12 | 100 | 18 | yes |
| Constrictor | 13 | 50 | 26 | Karma: ranks give 24 |
| Sabertooth | 13 | 120 | 22 | yes |
| Justin Hammer | 13 | 28 | 26 | Health: ranks give 30; Karma: 36 |
| Mauler | 14 | 140 | 36 | yes |
| Raider Armor | 14 | 110 | 22 | yes |
| Melter | 15 | 46 | 40 | yes |
| Blizzard | 15 | 46 | 44 | yes |
| Marrina | 16 | 80 | 26 | Health: ranks give 90 |
| Northstar | 16 | 90 | 22 | Health: ranks give 70 |
| Shaman | inside front cover | 50 | 110 | yes |
| Snowbird | inside front cover | 110 | 131 | yes |
| Sasquatch | inside front cover | 70 (185) | 70 | yes, both forms |
| Puck | inside back cover | 80 | 36 | yes |
| Heather | inside back cover | 42 | 40 | yes |
| Aurora | inside back cover | 66 | 18 | yes |
| Gary Cody | inside back cover | 28 | 26 | yes |

That is 19 cards; the twentieth block is Kimara's fully powered form, a
one-line grid under its card (`Un Un Un C1 Gd Am Am`, `Total Health: 1300`:
100 + 100 + 100 + Class 1000, which holds). `C1` is the book's code for
Class 1000.

**Shapes the parser must accept:** Kimara's header on two lines (`KIMARA,` /
`THE CLOUDSTALKER`) and its rank rows printed with no colon (`Fighting
MONSTROUS`); Sasquatch's bracketed second form on the line under three rows
(`GOOD (REMARK-` / `ABLE)` wraps); Northstar's block prints `Reason:` a second
time where `Resources:` belongs (EXCELLENT, which his card gives as
Resources); Marrina's Resources in title case (`Typical`); Raider Armor
prints no identity line; Heather and Gary Cody print `Powers: none`;
Sabertooth `Talents: none.`; Justin Hammer's Powers is prose with no run-in;
Snowbird's powers hold two four-row rank sets (her White Owl and Polar Bear
forms, F A S E only, no Health); the Raider's `WEAPONS:` run-in holds three
sub-run-ins (`RAIDER #1:` and so on).

**Six values fail on two Health and four Karma lines, all read on the page
images**, in five blocks: the Leader's Karma 125 (120), Constrictor's Karma 26
(24), Justin Hammer's Health 28 (30) and Karma 26 (36), Marrina's Health 80
(90) and Northstar's Health 90 (70). Each is printed unambiguously.
Hammer's two would both hold if his Fighting were Feeble and his Reason Good;
Northstar's card on the sheet prints no Endurance row and Strength EXCELLENT
where the booklet prints GOOD, so the sheet does not settle his 90 either.
Recommended as `misprint` overrides, printed and corrected kept (decision 4),
with Hammer's second value in the override's `also`.

**One-line grids**, every one with no name line, following a sentence of the
chapter's prose:

| name (registry) | printed | codes | Health | Karma |
|---|---|---|---|---|
| Synthetic Hulk | 5, Ch. 2 Battle | Ex Gd Mn Mn Pr Pr Pr | 180 | - |
| Hammer's Mercenaries | 7, Ch. 3 Battle | Ex Gd Gd Ty Ty Pr Pr | 46 | 14 (on the Health line) |
| Improved Synthetic Hulks | 9, Ch. 5 Battle 1 | Rm Ex Mn Mn Pr Pr Pr | 200 | - |
| Humanoids | 12, inside the Leader's card | Ty Ty Ex Gd Fb Fb Fb | 42 | - |
| (Kimara, powered) | 10, under its card | Un Un Un C1 Gd Am Am | 1300 | - |

All hold. **The card sheet (PDF 20)** repeats eight cards (no Gary Cody)
with each rank's number in brackets: its Health and Karma agree with the
blocks, and it differs from them only on Northstar (above) and in short power
lists (Marrina's sheet names a power the booklet names otherwise).

**Variants in prose only, with no block:** a boy (all Poor, Health 16, printed
2), Ross Kinkaid (Cascade's human form, printed 4) and Professor Anders
(printed 4). Not imported.

## Names the Codex already has

Aurora, Northstar and Sabertooth (MA1) and Sabertooth (MH4). Each MH5 card is
a card of its own with a `-mh5` id (Nate, 2026-09-28). The rest are new.

## Quote marks

On the cards every single mark is an apostrophe inside or after a word
(read in the OCR of printed 12-16 and the panels); no card prints a
single-quoted phrase. Two traps for the data row: Shaman's card prints inch
marks as two closing double quotes, and Sasquatch's card has a trademark sign
read as a double quote after Hulk.

## Which reader fits

**Not finished.** `cover-panels` (`scripts/msh/coverpanels.py`), at
`origin/main` `348f92d8`, on a scratch copy with this entry plus
`"layout": "cover-panels"` and `"opponent_names": "title"`, exits 1 at once:
`a block with no header above it, Inside front cover PDF 18`. The stream it
builds for that panel begins at Shaman's identity line: the header line
SHAMAN is not in it (cause not yet found). Nothing after that was run.

Known so far for the parser row: the panel header; Kimara as a card in a
chapter in capitals with colonless rows; four grids with no name line
(`unnamed_grids`); Kimara's powered grid (`form_grids`); the Humanoids grid
inside a card; Northstar's second `Reason:`; `C1`; the card sheet (no reader
should read PDF 20-21).

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule.

1. **Teams:** Alpha Flight for its eight members (Shaman, Snowbird,
   Sasquatch, Puck, Heather, Aurora, Northstar, Marrina), as MH1-3 file their
   heroes under their team; every other card under **MH5 Cat's Paw**
   (recommended). Gary Cody, the former liaison, under the book's title.
2. **The panels' names:** PDF 18 the inside front cover, PDF 19 the inside
   back (recommended, PDF order), since the scan does not show which.
3. **Characters only** (recommended).
4. **The six misprints** as `misprint` overrides (recommended), or
   `as_printed`.
5. **The two synthetic Hulk grids** as two cards, Synthetic Hulk and
   Improved Synthetic Hulks (recommended), the Sasquatch replicas not a card
   of their own.
6. **Hammer's Mercenaries** as a card (recommended).
7. **Humanoids** as a card of their own, though the module does not use them
   (recommended, as MH4's statted cats), or left in the Leader's text.
8. **The card sheet** checked against the blocks and not imported
   (recommended).
9. **Names:** leading The dropped (Leader); Raider Armor as printed;
   Kimara, the Cloudstalker as printed.
10. **Karma on the grids that print none:** left unset (recommended).

## How to reproduce

```bash
python scripts/msh/survey.py mh5
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 40-150 dpi into the scratchpad.
