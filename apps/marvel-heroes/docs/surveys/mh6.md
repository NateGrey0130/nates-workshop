# Survey: MH6 Thunder Over Jotunheim (TSR6862)

Marvel Super Heroes solo adventure module, Bruce Nesmith, 1985. Registry
entry: `scripts/msh/books.json` -> `mh6`. Measured 2026-10-23.

**Rows citing this book:** none yet (survey only; no data imported).

**DRAFT (2026-10-23).** Everything above *Which reader fits* was measured
and read on the page images. The trial parse is the next row's, and the
Marvel smoke suite has not been run on this branch.

The sixth module of the MH series, through `scripts/msh/` only. Characters
only (decision 3): the adventure, items and places are not imported.

## The scan

- 23 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-23 into the main
  checkout's `.cache/msh/books/mh6/` (23 pages OCR'd).
- The print is clean where it is black on white, and the seven cover cards
  OCR well. **Most of the booklet is printed under a red pattern** (below),
  and the cached OCR reads almost none of that.
- The scan is reduced: a code under the red pattern is a few pixels high
  even at 300-400 dpi, and a channel split does not sharpen it.

| PDF | part | printed |
|---|---|---|
| 1 | Cover (outside front) | - |
| 2 | Inside cover 1: Thor | - |
| 3 | Inside cover 2: the combat sequence and magical combat rules | - |
| 4-19 | Adventure Book | 1-16 |
| 20 | Inside cover 3: Loki, Geirrodur, Rock Troll | - |
| 21 | Inside cover 4: Ulik, Storm Giant, Executioner | - |
| 22 | Back cover | - |
| 23 | Map sheet, with the Karnilla's Gifts chart and the combat tables | - |

PDF 1-3 and 20-22 are 612 x 772 pt, the booklet 576 x 756, the map
2327 x 1526. Printed 2 says the inside cover holds the combat and magic
rules, which is PDF 3; which panel faces which the scan does not show, so
the four inside panels are named in PDF order (decision 2).

## Offset

`survey.py` votes **printed = PDF - 3 on 8 pages** (PDF 4 and 13-19), and
no page votes otherwise. Printed 8 was read on the image of PDF 11. Printed
1 (PDF 4) is the title page. PDF 22 prints the product code `6862XXX1401` at
its foot. So `parts`, with the cover panels and the map as parts of their
own with `offset` null.

## The book's own authority lists

No Contents, no index and no chapters: a solo adventure of 156 numbered
encounters, reached by moving a marker on the map. The banners, read on the
page images: the title page (printed 1), how to play and *Frey's Tale* (2),
*The Search for Frey's Sword* with *A Gift in the Night* under it (3), then
*Encounters* 1-156 over printed 3-16. Printed 5 is a page of comic art.
Printed 16 ends with the descriptions of Karnilla's gifts and two other
magic items. The coverage checklist is this survey's list, carried as
`cards` and `opponents`.

## The red pattern

This is a MAGIC VIEWER module: every choice's outcome is printed in a dark
red under a red dot pattern, read through a red film. In the scan each such
box is a pink field with the text a few shades darker.

- **Measured:** pink regions on every booklet page (red over green and blue
  by 40 or more, closed and labelled; boxes over 60 x 300 px at 300 dpi):
  88 boxes on PDF 6-19, none on PDF 4, 5 or 8. Each was viewed.
- **24 of the 25 stat grids are under it**, and six of their name lines
  (Stone Gargoyle, Burning House, Whip Vines, Half-Trolls, Lizard, Wereboar).
  Only Flame Wing's grid is printed in black.
- **The cached OCR reads none of the hidden grids** but Wereboar's, partly
  and wrongly. Tesseract on a contrast-stretched green channel of each box
  (`--psm 6`) reads the letter row as noise and about half of the codes.
- **By eye the grids can be read** on a contrast-stretched 300 dpi crop:
  every code row and Health below was read that way, and the arithmetic
  holds on every one.
- The grids' prose (each creature's special ability, two to six lines under
  its Health line) is under the pattern too, and no pass tried here reads it
  well enough to import (decision 4).

## Stat blocks: 7 full and 25 grids

**Full blocks** are the cover cards: a name in capitals with a trademark
sign, an identity line, seven `Fighting: REMARKABLE` rows in rank words,
`Health:`, `Karma:`, `Resources:`, `Popularity:`, then `Powers:` with
run-in powers ending in a full stop (`DENSE FLESH.`), `Talents.` (Thor only)
and a story run-in (`Thor's Story.`). Thor's card alone prints each rank's
number in brackets (`UNEARTHLY (100)`).

| card | where | Health | Karma | checks |
|---|---|---|---|---|
| Thor | Inside cover 1 | 320 | 76 | yes |
| Loki | Inside cover 3 | 150 | 115 | yes |
| Geirrodur | Inside cover 3 | 106 | 26 | yes |
| Rock Troll | Inside cover 3 | 104 | 10 | yes |
| Ulik | Inside cover 4 | 285 | 50 | yes |
| Storm Giant | Inside cover 4 | 140 | 14 | yes |
| Executioner | Inside cover 4 | 245 | 36 | yes |

Shapes for the parser: Rock Troll and Storm Giant print no identity line
and no trademark sign; the Executioner's identity line is `Skurge, Warlord`;
Ulik's `Popularity:` 20 sits on his portrait's art and the cached OCR loses
it; Geirrodur's identity line runs straight into `Fighting:` with no blank
line.

**Grids** print a bold name line, a letter row (`F A S E R I P`), a code row,
and a Health line with no Karma; the Health line may carry one more label
and rank (`Body Armor: Mn`, `Special attack`, `Flight: Rm`).

| name (registry) | printed, encounter | codes | Health |
|---|---|---|---|
| Giant Wolf | 3, 1 | Ex Gd Ex Rm Fb Fb Fb | 80 |
| Crystal Lion | 3, 4 | In Ex In Rm Fb Fb Fb | 130 |
| Sunflower | 3, 5 | Gd Mn Rm Un Fb Fb Fb | 215 |
| Giant Spider | 3, 10 | Ex In Rm Ex Fb Fb Fb | 110 |
| Moltens | 3, 13 | Ex Rm Ex Rm Pr Pr Gd | 100 |
| Stone Gargoyle | 4, 16 | In Gd In Un Fb Fb Fb | 190 |
| Burning House | 4, 19 | Ex Ex Mn Mn Fb Fb Pr | 190 |
| Monster of the Sphere | 6, 39 | Gd In In Mn Ex Ex In | 165 |
| Flame Wing | 8, 59 | Ex Am Gd In Rm Ex Am | 120 |
| Whip Vines | 8, 61 | Am Ex Rm Rm Pr Fb Fb | 130 |
| Crystal serpent | 8, 62 | Rm Ex Mn Am Fb Fb Rm | 175 |
| Thorn Giant | 8, 63 | Ex In Rm Mn Rm Gd Gd | 165 |
| Thorn Trap | 8, 64 | Am Gd Rm Un Fb Fb Fb | 190 |
| Half-Trolls | 9, 71 | Ex Fb Am Rm Pr Pr Fb | 102 |
| Lizard | 9, 79 | Gd Rm Rm Rm Gd Ex Rm | 100 |
| Wereboar | 10, 83 | Ex Ex In In Fb Pr Rm | 120 |
| Gisla | 12, 102 | Pr Ty Pr Ty Gd Ex Rm | 20 |
| Living Fire | 13, 117 | Rm Un Fb Un Ty Ty Gd | 232 |
| Crystal Giant | 13, 118 | Am Ex Am Mn Ex Fb Ty | 195 |
| Giant Vulture | 13, 122 | Rm Ex In Rm Fb Fb Fb | 120 |
| Maurglon the Cavern Troll | 13, 125 | Mn Rm Mn Mn Pr Pr Pr | 255 |
| Nightmare Witherer | 14, 136 | Gd Ex In Un Rm Rm Am | 170 |
| Granite Guardian | 15, 147 | In Gd Am Rm Pr Pr In | 130 |
| (Moltens, repeated) | 16, 153 | Ex Rm Ex Rm Pr Pr Gd | 100 |
| (a giant bird, unnamed) | 16, Egg of the Giantess | Ex Pr In Ex Fb Fb Fb | 84 |

**Every Health holds** on ranks.json `standard`, and every full block's
Karma holds. **No misprint was found**, so no override is proposed.

**Where the image does not settle a code**, what it does show:
- Living Fire's Fighting is blurred between Am and Rm; Rm is the one that
  gives the printed 232 (Am gives 252), and it is listed as Rm.
- Crystal Giant's Reason and Monster of the Sphere's Reason and Intuition
  are blurred (read as Ex); no grid prints a Karma, so nothing checks them.
- Giant Spider's 110, Giant Vulture's 120 and Maurglon's 255 are blurred
  digits whose shapes fit those values and which the codes reproduce. On
  those three the Health check could not have failed.

The data row is held to these by eye, so these six values are the ones to
look at again on the image.

**Named in the prose with no block:** Skrog the boatman and the giant
general Bilzak (each said to have a storm giant's statistics), Karnilla,
Frey, Skirnir, Volla, Muninn, Hermod, and three opponents given only a
Health in an outcome (a troll hag, a dwarf, a small giant). Not imported
(decision 9).

## Names the Codex already has

Thor (MHSP1, ME1, MHSP2, ME2), Loki (ME2), Geirrodur (ME2) and the rock troll
(ME2, as Rock Troll, Typical). Each MH6 card is a card of its own with a
`-mh6` id (Nate, 2026-09-28). MHSP1's Lizard is Spider-Man's villain, not
this giant lizard; the ids differ by book. Ulik, the Executioner, the storm
giant and every grid are new.

## Quote marks

The cover cards print double quotes only (Thor's and the Executioner's
stories); every single mark on them is an apostrophe. The booklet's speech
is in double quotes, which the cached OCR often reads as two single marks
or one, so a quote in a grid's text needs the image, not the OCR. The one
single-quoted phrase seen is a nickname in the title page's credits, which
nothing imports.

## Which reader fits

**Not finished.** Row 1b runs the trial parse. What is measured so far:

- The seven cover cards are the shape `cover-panels`
  (`scripts/msh/coverpanels.py`) reads for MH4 and MH5: rank-word rows with
  colons, `Powers:` and run-ins, three columns to a panel.
- The grids are not MH5's one-line grids: each has its own bold name line
  and a letter row, as MH1-4's grids do, but sits inside an encounter's
  text, after a bold choice heading (`Attack`, `Talk`) that is not a name.
- Under the red pattern the cached OCR has no grid to read (above), so the
  reader cannot find 24 of the 25 grids in the stream it is given.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule.

1. **Teams:** every card under **MH6 Thunder Over Jotunheim**
   (recommended), as a book with no team sections files its characters
   under its title (MH4). Not taken: the cover's Asgard characters under
   ME2's Asgardians group.
2. **The panels' names:** Inside cover 1-4 in PDF order (recommended),
   since the scan does not show which faces which.
3. **Characters only** (recommended).
4. **The red-pattern grids:** the 24 hidden grids' codes and Health carried
   in the registry as read here by eye, and their cards built with the
   Health line's label and no prose, unless the reader row can make the
   prose read cleanly (recommended). Not taken: leaving the hidden grids
   out, which keeps 1 of 25.
5. **Moltens** as one card, the second grid checked against it
   (recommended, as MH4's 2 Minions).
6. **The giant bird** inside the Egg of the Giantess left out (recommended):
   it is an item's effect and items are not imported.
7. **Rock Troll and Storm Giant** as cards, named as printed (recommended).
   Not taken: ME2's `Rock Troll, Typical` form.
8. **Every statted opponent a card**, the house and the plants included
   (Burning House, Sunflower, Whip Vines, Thorn Trap, Living Fire)
   (recommended, as MH1-5 imported every statted grid).
9. **No card for the named characters with no block** (recommended).
10. **Names:** as printed (Executioner, Crystal serpent, Maurglon the
    Cavern Troll), with the leading The dropped (Nightmare Witherer).
11. **Karma on the grids**, which print none: left unset (recommended).

## How to reproduce

```bash
python scripts/msh/survey.py mh6
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
`survey.py` finds no block in this book (it looks for `Health =`), so its
use here is the offset vote. Page images were rendered with PyMuPDF at
50-400 dpi into the scratchpad; each red box was cropped and its green
channel contrast-stretched to read it.
