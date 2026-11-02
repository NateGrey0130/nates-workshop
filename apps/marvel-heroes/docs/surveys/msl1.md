# Survey: MSL1 X-Terminate (TSR6899)

> **DRAFT.** Written up to *Which reader fits*, which is not finished: the
> trial parse (plan row 22c) runs a reader over this book and writes it. No
> `layout` is set, and nothing of the book is imported yet.

Marvel Super Heroes adventure, product code 6899 on the cover (PDF 1). The
author and the year are not read. Registry entry: `scripts/msh/books.json`
-> `msl1`. Measured 2026-11-02.

**Rows citing this book:** 0 `msh_book_text` rows in production: nothing is
imported yet, and the data row sets this line from production.

Everything here was measured and read on the page images by plan row 22a,
and recorded in its registry commit (`a700fcf6`); this document was written
from that record and the registry entry, with no page read again.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 36 PDF pages, a pure scan with no text layer, cached into the main
  checkout's `.cache/msh/books/msl1/` (36 pages OCR'd). The `--probe`
  figures were not recorded.
- **The booklet is 32 pages** (PDF 2-33, 594 x 767 pt), printed 1-32.
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 597 x 772 | Cover (outside front; MSL1, ADVENTURE and 6899) | - |
| 2-33 | 594 x 767 | Adventure Book | 1-32 |
| 34 | 597 x 772 | Back cover (product code 6899XXX1401 and the price) | - |
| 35 | 1086 x 594 | Map: Apocalypse's Headquarters (Map 1, rooms 1-5) | - |
| 36 | 1161 x 496 | Map: Factor Three Headquarters (the floor plan of printed 22-23, untitled) | - |

**PDF 35** is the map printed in the lower half of printed 9, on a page of
its own. **PDF 36** is the two-page floor plan of printed 22-23 (rooms
numbered 1-66, no title) on one page. None of PDF 1 and 34-36 prints a
folio or a stat block, and none of the map pages is imported.

## Offset

`survey.py` votes **printed = PDF - 1 on 4 pages** (PDF 16, 26, 29 and
30), and no booklet page disagrees. Two votes are not folios, each read on
its page:

- PDF 28 (k = 21): a `7` that is a speck in the strip of art at the page's
  foot, above the folio.
- PDF 32 (k = 28): a `4`, the same.

Every other booklet page prints its folio, PDF - 1, on a strip of each
page's foot (read at 60 dpi), Tesseract missing it: PDF 3-15, 17-22, 25,
27, 31 and 33. Three booklet pages print none: printed 1 (PDF 2) is the
title page, with the Contents, the credits and the fine print (the code
6899XXX1401 and the ISBN), and printed 22-23 (PDF 23-24) are the floor plan,
counted by position. So `parts`, as MT3, with the cover, the back cover and
the two maps as parts of their own with `offset` null.

## The book's own authority lists

**Contents (printed 1).** One column, transcribed from a render, then each
entry checked against its page. **Every entry agrees with its page**, so
there are no `contents_errata`. Stored as `sections` in the Contents'
order.

| printed | Contents entry (title from the banner) |
|---|---|
| 2 | Introduction |
| 4 | Chapter 1: Interlude |
| 5 | Chapter 2: Avengers Disassembled! |
| 6 | Chapter 3: X-Terminate Mark I |
| 7 | Chapter 4: The X-Clones Regroup |
| 9 | Chapter 5: Apocalypse Now |
| 12 | Chapter 6: The Domain of Dominus |
| 13 | Chapter 7: The Malignant Mister Sinister |
| 15 | Chapter 8: The Arizona Robotics Farm |
| 17 | Chapter 9: The Lay of the Land |
| 20 | Chapter 10: An Apocalyptic Epitaph |
| 24 | New Gadgetry and Equipment |
| 26 | The NPC Bad-Guy Roster |
| 31 | Player Character Roster |
| 9 | Apocalypse's Headquarters |
| 22 | Factor Three Headquarters |

- **The banners.** The Contents prints each chapter as `Chapter N` alone;
  its title is the banner's, a bold line in capitals at the top of the page
  under the masthead, `CHAPTER N: TITLE`, stored in title case. All ten are
  at the top of their page; none opens mid-page. **Tesseract reads all ten**,
  the I of MARK I as a bar.
- **INTRODUCTION** (printed 2) and **NEW GADGETRY AND EQUIPMENT** (24) head
  their pages in the same style. The NPC Bad-Guy Roster (26) is headed The
  NON-PLAYER CHARACTER ROSTER on its page, and Player Character Roster (31)
  THE PLAYER CHARACTER ROSTER.
- **The last two entries are maps, not text.** Apocalypse's Headquarters
  (printed 9) is Map 1 in the lower half of Chapter 5's page, and Factor
  Three Headquarters (printed 22) is the untitled floor plan across printed
  22-23. **Apocalypse's Headquarters shares printed 9 with Chapter 5's
  banner, and Caliban's grid is on that page**, so the trial must see which
  section a reader gives printed 9.
- **No index.** The Contents names no character. The coverage checklist will
  be this survey's list.

## Columns, labels and ranks

- **Two columns** on every booklet page but the title page and the floor
  plan (printed 2-32 at 30 dpi, and the grid pages, printed 4, 9, 12-14 and
  26-32, at 100-130 dpi), a grid spanning one column. **No grid breaks
  across a column.**
- **One grid shape** in the whole book: three stacked rows across the
  column, the letters F A S E R I P, the rank codes in capitals, then the
  numbers, each code above its number with no brackets, and two lines of
  labels under them in two columns. Resources is a code and its number in
  brackets (`RM (30)`); Pestilence's is set with no space (`FB(2)`).
  Popularity runs from -40 (Dominus) to 26 (Iceman).
- **The labels' order varies:**

| grids | first line | second line |
|---|---|---|
| the fifteen roster cards (printed 26-32) and Pestilence (4) | Health, Karma | Resources, Popularity |
| War (4), Caliban (9), Sunstroke (12), X-Terminator Mark III (13) | Health, Resources | Karma, Popularity |
| Mister Sinister inside Chapter 7 (14) | Health, Popularity | Karma, Resources |

- **Headers.** The roster's are title case over the grid; PESTILENCE
  (printed 4) is in capitals. Each chapter grid is a header over the
  roster's grid shape.
- **Section labels**, counted on the OCR of PDF 5-15 and 27-33 and read on
  the images: `KNOWN POWERS` in bold capitals with no colon heads the powers
  of every grid with powers (Angel (Clone), printed 26, prints `KNOWN
  POWER`), each power an italic run-in under it, stunts as bulleted lines.
  `TALENTS:` in bold capitals is a run-in on every roster card (Dominus's
  broken over a line as `TAL- ENTS`, printed 30) and on Caliban (9), the
  X-Terminator Mark III (13) and Mister Sinister (14).
- **The roster's identity block**, bold run-ins: `Real Name:` (14 cards; the
  X-Terminator Robots print none), `Occupation:`, `Identity:`, `Legal
  Status:`, `Place of Birth:`, `Marital Status:`, `Base of Operations:` and
  `GROUPS:` in capitals; the robots print only `Occupation:`, `Place of
  Birth:`, `Base of Operations:` and `GROUPS:`. Cyclops (Clone) adds `IN
  BRIEF:` (printed 27), and Professor X (Clone) `Equipment:` and
  `Limitations:` (printed 28), his Equipment items as italic run-ins.
- **The chapter grids print no identity block**: after their powers the
  chapter resumes, with `AFTERMATH:`, `KARMA:` and `POPULARITY:` as bold
  capital run-ins of the adventure.
- **Ranks.** Every code is in capitals: FB and FE both for Feeble (FB on
  Pestilence's Resources and War's S and Resources, printed 4; FE on
  Caliban's Resources, 9, and Archangel's, 31), PR, TY, GD, EX, RM, IN, AM,
  MN and UN. Dominus (printed 30) adds `CL1000` over 1000 on E and `Shift-
  X` over 150 on R (set with a space after the hyphen), Class 1000 and
  Shift X in `ranks.json`, and `N/A` over a dash on S. **No title-case
  code.** So `rank_aliases` gains FB beside FE, CL1000 and Shift-X.
- **Two item grids** print Control, Speed, Body and Protection as four codes
  and no number: the wheelchair inside Professor X (Clone)'s card (printed
  28) and the Mind Shields (printed 25). Neither is a character's
  (decision 8).
- **`survey.py` finds 0 blocks** (rerun 2026-11-02): it looks for MA1's
  `Health =`, and this book prints `Health:`. Its block count is not this
  book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1 and 34-36 holds no `Health`, `Karma` or rank
row, and their images show the cover, the back cover's blurb and two maps.
So `panels` is empty, as MT3's.

## Stat blocks

**21 grids**, every one read on the page image (110-130 dpi), each three
stacked rows, and **no headerless grid**, so no one-line grids and no
tiers. Fifteen are the roster's cards (printed 26-32) and six are inside
the chapters (printed 4-14).

| printed | name as printed | where | already carded by |
|---|---|---|---|
| 4 | PESTILENCE | Chapter 1, column 1 | - |
| 4 | War | Chapter 1, column 2 | - |
| 9 | Caliban | Chapter 5, column 2 | MA1 (Morlocks), a different grid |
| 12 | Sunstroke | Chapter 6, column 2 | - |
| 13 | X-Terminator Mark III | Chapter 7, column 1 | not a card (decision 4) |
| 14 | Mister Sinister | Chapter 7, column 1 | not a card (decision 4) |
| 26 | Angel (Clone) | NPC roster | its grid equals the Angel's of MA1, MHSP2 and MT3 |
| 26-27 | Beast (Clone) | NPC roster | - |
| 27 | Cyclops (Clone) | NPC roster | - |
| 27 | Iceman (Clone) | NPC roster | - |
| 27-28 | Marvel Girl (Clone) | NPC roster | - |
| 28 | Professor X (Clone) | NPC roster | its grid equals MA1's Professor X |
| 29 | Mister Sinister | NPC roster | - |
| 29 | Apocalypse | NPC roster | MA1 (Alliance of Evil), the same grid |
| 30 | Dominus | NPC roster | - |
| 30 | X-Terminator Robots | NPC roster | - |
| 31 | Archangel | Player Character Roster | - |
| 31 | Beast | Player Character Roster | MA1 (X-Factor), MHSP2, MT3 |
| 31-32 | Cyclops | Player Character Roster | MA1 (X-Factor), MHSP1, MHSP2, MT3 |
| 32 | Iceman | Player Character Roster | MA1 (X-Factor), MHSP2, MT3 |
| 32 | Marvel Girl | Player Character Roster | MA1 (X-Factor), MT3 |

The NPC roster's ten cards run from Angel (Clone) to the X-Terminator
Robots, whose text ends partway down the right column of printed 30; the
Player Character Roster's five run from Archangel to Marvel Girl. Each card
is a title-case header over a grid, KNOWN POWERS, TALENTS: and an identity
block. The grids' numbers are not copied into this survey; the trial parse
reads them and the overrides file records the misprints below.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **18 of 21**: Iceman (Clone), X-Terminator Mark III and Mister Sinister (printed 14) fail |
| Karma = R+I+P | **18 of 21**: the same three |
| every ability number within its rank code's range | **18 of 21**: Cyclops (Clone)'s F, the X-Terminator Robots' F and the X-Terminator Mark III's F |

**The misprints, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Cyclops (Clone), printed 27 | `F EX` over 6 | 6 is Typical (Excellent is 16-25); Health 42 agrees with the 6, so the code is the misprint: TY |
| Iceman (Clone), printed 27 | `Health: 56`, `Karma: 20` | the rows add to 42 and 16; 56 and 20 are the Player Character Iceman's totals, so both totals are the misprint: 42 and 16 |
| X-Terminator Robots, printed 30 | `F IN` over 50 | 50 is Amazing (Incredible is 36-45); Health 255 agrees with the 50, so the code is the misprint: AM |
| X-Terminator Mark III, printed 13 | numbers 50 75 30 10 30 100 20 under Health 255 and Karma 60 | the rows add to 165 and 150. They are the X-Terminator Robots' seven numbers in another order, under the robots' totals, with the same power names, and its F is `IN` over 50 as the robots' is: not a card of its own (decision 4) |
| Mister Sinister, printed 14 | numbers 30 40 40 100 30 50 30 under Health 150 and Karma 170 | the rows add to 210 and 110. They are printed 29's Mister Sinister's seven numbers in another order, under that card's totals, and its Telepathy matches: not a card of its own (decision 4) |
| Dominus, printed 30 | `S N/A` over a dash | Health 1020 holds with S as 0; printed that way on purpose (decision 7) |

As `page:name:field printed->corrected`: `27:Cyclops (Clone):F EX->TY`,
`27:Iceman (Clone):Health 56->42, Karma 20->16`, `30:X-Terminator
Robots:F IN->AM`, `13:X-Terminator Mark III` and `14:Mister Sinister` (not
cards, decision 4), `30:Dominus:S N/A` (as printed, decision 7).

**Two more things printed on the cards**, neither a total: Feeble is
printed both FB and FE (above, aliased), and Marvel Girl's Real Name is
printed Jean Gray on both of her cards, the clone's (printed 28) and the
Player Character's (32) (decision 9).

**The whole book, counted:** 21 grids, 19 of them cards (the fifteen roster
cards and Pestilence, War, Caliban and Sunstroke), and 2 item grids of four
codes (the wheelchair and the Mind Shields), which are not characters'.

**Card pages and the chapters' grids.** Printed 26-32 are card pages
(`character_ranges`, printed 26-32). The chapter grids are statted inside
the prose, and the registry records them as MT3's entry does
(`opponents`, each with its `part`): Pestilence and War (printed 4),
Caliban (9) and Sunstroke (12). The X-Terminator Mark III and Mister
Sinister of printed 13-14 are left out of `opponents` (decision 4). Which
reader takes them is *Which reader fits*.

## Names the Codex already has

Read from `apps/marvel-heroes/data/npcs.json` at `b944eb39` (1063 cards),
each the same person unless said; the grid comparisons are row 22a's,
read on the images:

| MSL1 card | already carded by |
|---|---|
| Angel (Clone) | a clone of the Angel of MA1 (X-Factor), MHSP2 and MT3; its grid equals theirs |
| Beast (Clone), Beast | MA1 (X-Factor), MHSP2, MT3 |
| Cyclops (Clone), Cyclops | MA1 (X-Factor), MHSP1, MHSP2, MT3 |
| Iceman (Clone), Iceman | MA1 (X-Factor), MHSP2, MT3 |
| Marvel Girl (Clone), Marvel Girl | MA1 (X-Factor), MT3 |
| Professor X (Clone) | a clone of the Professor X of MA1, MHSP1, MH1, MHSP2 and MT3; its grid equals MA1's |
| Apocalypse | MA1 (Alliance of Evil), the same grid |
| Caliban | MA1 (Morlocks), a different grid |

New: Archangel, Mister Sinister, Dominus, the X-Terminator Robots,
Pestilence, War, Sunstroke and the six clones. Each clone is a being of its
own, not its original (decision 3). Each MSL1 card is a card of its own
with a `-msl1` id (Nate, 2026-09-28).

## Quote marks

**The book prints no single quotes of its own in the text a card takes.**
Every mark read on the images is a double quote, a feet mark (`10'` on
printed 9, `30'` on printed 31) or an apostrophe, but **one stray single
after Archangel's Flight line** (printed 31). So for the imported text
MHSP1's rule (every single mark a misread) fits, as it fits MT3, with two
things for the trial parse to check: that a feet mark after a number stays
a single mark and is not paired into a double (MT3's trial found
`pair_quotes` skips a mark after a digit), and what the chain makes of
Archangel's stray single (decision 10).

## Which reader fits

**Not finished.** Plan row 22c runs the trial parse and writes this
section. What it has to see, from the measurements above:

- MT3's verdict was `grid-booklets` (`scripts/msh/gridbooks.py`), for a
  `parts` entry with `character_ranges` and `opponents`, which MSL1's entry
  is too. MSL1's grids are a different shape from MT3's: three stacked rows
  (letters, codes, numbers) rather than a row per ability, with labels in
  two lines under the grid in three orders.
- Every code is in capitals over its number; FB, CL1000 and Shift-X are
  aliases, and Dominus's `N/A` over a dash must read as a value the check
  takes as 0 (decision 7).
- The 19 cards are the checklist (decision 3): fifteen on printed 26-32 and
  four opponents on printed 4, 9 and 12. The grids on printed 13 and 14 and
  the two item grids must not become cards.
- Printed 9 carries Chapter 5's banner, Map 1 and Caliban's grid, and two
  Contents entries start there.
- `KNOWN POWERS` has no colon, and Angel (Clone) prints `KNOWN POWER`;
  `TALENTS:` is broken over a line on Dominus's card.
- The chapter grids end where the adventure resumes, at an `AFTERMATH:`,
  `KARMA:` or `POPULARITY:` run-in.
- The overrides the trial will need: decisions 6 and 7.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-31: take the survey's recommendations). Characters only is already
ruled (Nate, 2026-10-21), and so are second cards with `-msl1` ids
(2026-09-28) and a leading The dropped from a name (2026-10-21).

1. **Teams:** **X-Factor** for the five Player Characters, Archangel,
   Beast, Cyclops, Iceman and Marvel Girl (recommended: the Codex files
   MA1's Angel, Beast, Cyclops, Iceman and Marvel Girl there already, as
   MT3's X-Men and Fantastic Four took the team the Codex already has);
   every other card, the clones, the NPC roster and the four opponents,
   under **MSL1 X-Terminate** (as MT3's other cards under its title). Not
   taken: X-Men for the clones (they are Apocalypse's side here), or a team
   of their own for the Horsemen.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure,
   items, places or maps.
3. **Every character grid a card** (recommended, as MT3 decision 3): the
   fifteen roster cards and Pestilence, War, Caliban and Sunstroke, 19 in
   all. **The clones keep `(Clone)` in their names** (Angel (Clone) and the
   rest), each a card of its own, so the parenthesis is not read as a
   version of the Player Character's card of the same name. Not taken: the
   clones as versions of Beast, Cyclops, Iceman and Marvel Girl, who are
   other beings on the other side.
4. **The two chapter grids that are not cards** (recommended): the
   X-Terminator Mark III (printed 13) and Mister Sinister (printed 14) each
   print a roster card's seven numbers in another order under that card's
   totals, so neither is a card; the X-Terminator Robots (printed 30) and
   Mister Sinister (printed 29) are. Their text stays in the chapter. Not
   taken: a card for each with its totals as overrides, since the rows add
   to no total the book prints and the roster already cards the same being.
5. **Names as printed**, title case for the capitals (recommended):
   PESTILENCE is Pestilence; Mister Sinister and the X-Terminator Robots as
   printed. No header here starts with The.
6. **The failing totals and codes** as `misprint` overrides, printed and
   corrected kept (recommended, as MT3 decision 7): Cyclops (Clone)'s F, EX
   to TY; the X-Terminator Robots' F, IN to AM; Iceman (Clone)'s Health, 56
   to 42, with his Karma, 20 to 16, in the same override's `also` (one
   override matches one block). Not taken: Iceman (Clone)'s rows changed to
   fit the Player Character's totals, since each row's number and code
   agree.
7. **Dominus's `S N/A`** (recommended): an `as_printed` override with that
   reason, S read as 0 for the check, which Health 1020 bears out, and no
   number shown as printed; as MA1's robots' `Karma = -` passes unread. Not
   taken: a rank derived for S, which the book does not give.
8. **The two item grids** (recommended): the wheelchair (printed 28) left in
   Professor X (Clone)'s card text and the Mind Shields (printed 25) in New
   Gadgetry and Equipment, neither a card (characters only, Nate,
   2026-10-21).
9. **Jean Gray** (recommended): Marvel Girl's Real Name left as printed on
   both cards, since it is printed the same on both and is the book's
   spelling, not an OCR misread; the card's name is Marvel Girl, so no id
   or filter depends on it. Not taken: a `text` verdict to Grey, which would
   change the book's prose rather than mend a misread.
10. **Archangel's stray single** (printed 31, after his Flight line)
    (recommended): dropped by a `text` verdict, printed kept, if the trial
    finds it in his text, since the book prints no single quotes of its own
    in a card's text. Not taken: kept, which would leave an unpaired mark in
    the Codex.

## How to reproduce

```bash
python scripts/msh/ocr-book.py msl1 --probe
python scripts/msh/ocr-book.py msl1
python scripts/msh/survey.py msl1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
