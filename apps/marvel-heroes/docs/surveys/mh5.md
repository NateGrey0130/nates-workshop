# Survey: MH5 Cat's Paw (TSR6857)

Marvel Super Heroes adventure module, Jeff Grubb, 1984. Registry entry:
`scripts/msh/books.json` -> `mh5`. Measured 2026-10-23.

**Rows citing this book:** 0 `msh_book_text` rows (survey only; no data
imported).

Everything here was measured and read on the page images, the trial parse
included.

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

**`cover-panels` (`scripts/msh/coverpanels.py`), with things taught to it.**
Measured, not argued: a scratch copy of `scripts/msh/` at `ca75b7d2` (this
branch; its scripts are `origin/main` `348f92d8`'s) with this entry plus
`"layout": "cover-panels"` and `"opponent_names": "title"`, run on a copy of
the cache under its own `WORKSHOP_MSH_CACHE`. The stock reader exits 1 at
once: `a block with no header above it, Inside front cover PDF 18`.

**Why SHAMAN is missing.** `booklet.stream_of` keeps a page's words between
3% and 95.5% of its height (`0.03 * H < y`), a band written for pages with
a running head and a folio. This scan crops the panels close: every header
at the top of a panel column boxes at y 50-56 of 3197 (1.6-1.8%), so all six
are cut, though Tesseract reads each one cleanly (confidence 90-92): SHAMAN,
SNOWBIRD and SASQUATCH on PDF 18, PUCK, HEATHER and AURORA on PDF 19. Only
GARY CODY, mid-column, survives. Without them Shaman's stream starts at his
identity line, and Snowbird's and Sasquatch's blocks fall to the card above.
The foot is cut the same way: Snowbird's and Gary Cody's last two lines sit
below 95.5%, which MH4's `panel_foot` already restores (four lines; tried).

With registry-only workarounds in the scratch copy (`lost_headers` for the
six, `panel_foot`, `unnamed_grids` for the four nameless grids, `prose_cards`
and `form_grids` for Kimara) and five trial-only patches (named below),
`roster.py mh5` reads every entry and exits 1 on the checklist:

- **23 entries, 25 blocks; 18 pass, 7 fail.** Five fail on the six misprinted
  values above (the Leader, Constrictor, Justin Hammer, Marrina, Northstar);
  Snowbird and Sasquatch are the reader's (below). Kimara's block passes, and
  its powered grid holds at 1300 once `C1` is read.
- **The panel headers** (above): six `lost_headers` place them, or the reader
  keeps a panel's head band as `panel_foot` keeps its foot.
- **The Humanoids grid stops the reader** (`unnamed_grids names 1 grid(s) on
  Adventure Book p.12 that no unnamed grid matched`): its letter row reads
  `F A S E R IP`, and `letter_xs` takes a fused pair only when the last word
  is `P`. Patched in the trial. Once read it is an entry, but its letter row,
  codes, Health and the sentence under it stay inside the Leader's HUMANOIDS
  power text, and its own entry has no text: the sentence is two body lines
  below the Health line, past the gap that ends a grid's text.
- **Kimara is not found** (`prose_cards finds 'Kimara, the Cloudstalker' over
  a block 0 times`): its header is two lines in capitals (`KIMARA,` / `THE
  CLOUDSTALKER` and the trademark sign), which `stream()` does not join off
  the panels, and its rank rows print no colon (`Fighting MONSTROUS`), which
  neither `prose_card` nor `booklet.full_grid` reads. Both patched in the
  trial. Then the block passes, but the card prints no Resources, Popularity
  or `Powers:` line, so its two run-ins, which end in a colon (`BODY ARMOR:`,
  `REGENERATION:`), and the chapter's paragraph after them all land in the
  card's prose, which runs on to the powered grid's letter row.
- **Kimara's powered grid:** `C1` is read as `C` (the code is cut to its
  letters) and `Total Health:` is no stat line, so the grid has an unread
  Endurance and no Health. Both patched in the trial (`C1` is already in
  `rank_aliases`).
- **Snowbird's forms:** her `EXAMPLES:` run-in prints two four-row sets (F A
  S E only, each under a form's name). The first is read as a second full
  block with R, I and P unread and no Health (`HEALTH None: SNOWBIRD`, and
  `BLOCKS: 20 full ... the checklist has 19`); the second is lost; `EXAMPLES`
  is read as a power; and her FLIGHT., POSTCOGNITION. and LIMITATION. after
  the sets land in the card's prose, not its powers.
- **Sasquatch's alternates** are in round brackets, two on the line under
  their row (`(MONSTROUS)`, `(AMAZING)`) and one wrapped mid-word after its
  rank (`GOOD (REMARK-` / `ABLE)`). `wrapped_alternates` reads only a square
  bracket on a line of its own, so no alternate is read and the bracketed
  Health fails (`HEALTH '70 (185)': SASQUATCH`). Read as printed, Remarkable,
  Remarkable, Monstrous and Amazing give 185.
- **Justin Hammer's `Powers:` is a sentence with no run-in**:
  `POWERS: TEXT AND NO RUN-IN POWER: JUSTIN HAMMER`. Only `none` is exempt.
- **Northstar's second `Reason:`** (where Resources belongs) leaves his
  Resources unset; no check reports it.
- **The Raider's BODY ARMOR.** is read into FLIGHT.'s text: a speck after the
  sentence's end (2 x 3 px, read as `-`; seen on the page image) leaves the
  sentence open, so the head is taken as text.
- **Not the reader's:** a handwritten mark in the scan's margin beside the
  improved synthetic Hulks' text (a pencilled number, seen on the page
  image) is read as `*:` into their prose (a `text` verdict); and Melter's
  MELTING DEVICE. prints four settings as colon run-ins (`METAL:`, `STONE:`,
  `WOOD:`, `FLESH:`), read as four powers of their own, while the Raider's
  `RAIDER #1:` to `#3:` stay inside WEAPONS: (decision 11).
- The card sheet (PDF 20-21) is in no range and reaches no entry, as it
  should (decision 8).

The other readers do not fit, for MH1-4's reasons (mh4.md, *Which reader
fits*): this book prints rank words and no ability numbers, and its cards are
on the cover's panels.

So the parser row is next. What it needs, all in `coverpanels.py` behind the
registry, with MH1-4's `roster.json`, `book-text.sql` and `npcs.json` rows
proved byte-identical before and after. Twelve things:

1. **A panel's head band**: a header above 3% of a panel's height (or six
   `lost_headers`, the registry's way, if the parser row prefers it).
2. **A fused `IP` at the end of a letter row.**
3. **A two-line header in capitals on a prose card** (Kimara's).
4. **Rank rows with no colon** on a prose card.
5. **A prose card with no `Powers:` line**: its colon run-ins read as its
   powers, and the card ended before the chapter's prose resumes.
6. **`C1` in a grid's codes, and `Total Health:`** as its Health.
7. **Four-row form sets inside a power** (Snowbird's two), and the run-in
   powers after them.
8. **Round-bracket alternates**, on the line under a row and wrapped
   mid-word after it (Sasquatch's).
9. **A `Powers:` sentence with no run-in** (Justin Hammer's), without
   loosening the check for the books that need it.
10. **A second `Reason:` read as Resources** (Northstar's), as printed with
    the correction kept, or as an override.
11. **A speck after a sentence's end** not holding it open (the Raider's).
12. **A grid inside a card that is an entry of its own** (the Humanoids):
    cut from the Leader's power text, with the sentence under it as its text.

Registry and overrides, no reader change: `panel_foot`, the four
`unnamed_grids`, Kimara's `prose_cards` and `form_grids`, five `misprint`
overrides (six values), and the `text` verdict for the margin mark.

This survey sets no `layout`, as MH1-4's did not: that is the parser's
choice.

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
11. **Melter's four settings** kept inside MELTING DEVICE as its text, as the
    Raider's three weapons stay inside WEAPONS (recommended), or four powers
    of their own, as the stock reader reads them.

## How to reproduce

```bash
python scripts/msh/survey.py mh5
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 40-150 dpi into the scratchpad.
