# Survey: MH9 Gates of What If (TSR6867)

> **DRAFT.** Measured up to *Decisions*, but for *Which reader fits*, which
> is not finished: it needs the trial parse (row 7c). Nothing here is
> imported yet.

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
`world`). The coverage checklist is this survey's list, carried as
`cards`, `opponents` and `repeat_grids` (*Stat blocks*).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's labels and values
  are two sub-columns of one column.
- **The blocks are the MH series' labelled blocks with numbers**: seven
  `Fighting: Excellent` rows (rank words in title case, not MH1-8's
  capitals), then `Health:`, `Karma:`, `Resources:` and `Popularity:` with
  numbers, then labelled sections. **Ten blocks print `Karma` with no
  colon**: Mephisto's (printed 29) and all nine Marvel Universe PC Heroes'
  (printed 36-39), read on the page image of printed 36.
- **Section labels**, counted on the OCR of printed 21-40 and read on the
  images of printed 23 and 29: `Known Powers:` (33), `Background:` (22),
  `Personality:` (22), `Talents:` (21), `Background and personality:` (13,
  one label: Valor's on printed 29) and `Equipment/Possessions:` (5). The
  Wasp (printed 23) prints Background and Personality as two.
- **Ranks**: the words Feeble to Unearthly, plus `Shift X` (a Strength,
  printed 27) and `Class 1000` (an Endurance, printed 29).
- **The chapters' one-line grids** print an `F A S E R I P` row over
  two-letter codes in capitals, and `Health:` and `Karma:` (or `Karma:
  None`) under them. The codes printed are FE, PR, TY, GD, EX, RM, IN and
  MN (once, printed 7, which the OCR reads as `IN-~`), and
  two of the book's own: **RE** for Remarkable (the guardsmen robots,
  printed 10: four RE, and their Health of 120 holds on 30 each) and **GO**
  for Good (Valor's four-code FASE row, printed 29: GO GO TY GO, where every
  other grid prints GD). All are in `rank_aliases`. No AM or UN code is
  printed (every grid read on the page images).
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Where the blocks are

One-line grids inside the chapters, on printed 4, 7, 8, 10 (two) and 20
(four), and labelled blocks on printed 21-40: the Non-Player Character
Roster (21-29), New PC Heroes (30-35) and Marvel Universe PC Heroes
(36-40). The Health lines the OCR finds on printed 5, 13 and 17 are prose
(a Health given in a sentence), not grids. Not one page outside the
booklet holds a Health, Karma or rank row. Every one is listed under *Stat
blocks*.

## Cover-panel cards

**None.** The OCR of PDF 1 and 42-46 holds no `Health`, `Karma`,
`Fighting` or rank row, and their images show the cover art, the back
cover's blurb and the five maps. So `panels` is empty, as MH8's, and there
is no cover card to hold to Health = F+A+S+E and Karma = R+I+P. Every
block is in the booklet (*Stat blocks*).

## Stat blocks: 35 cards and 12 grids

Every block and grid was read in the OCR of printed 1-40 and checked on
`apps/marvel-heroes/data/ranks.json` `standard` (Shift X 150, Class 1000
1000). Every failure, the Swordsman's Health (a speck read as a dash), all
twelve grids' code rows and the three FASE rows were read on the page
images (130-200 dpi crops). Measured 2026-10-30.

**The cards**, printed 21-39, each a header, identity lines and a labelled
block (the Skrulls' block is a one-line grid). Names as printed; the four
printed more than once carry the identity line's real name here (decision
4):

| card | printed | Health | Karma | checks |
|---|---|---|---|---|
| Super-Adaptoid | 21 | 150 | 18 | Health: ranks give 24 (printed on purpose, below) |
| Swordsman | 21 | 70 | 18 | yes |
| Attuma | 22 | 165 | 20 | yes |
| Klaw | 22 | 36 | 22 | yes |
| Wasp (Janet Pym) | 22 | 28 | 34 | yes |
| Captain America (Jeffrey Mace) | 23 | 36 | 36 | Karma: ranks give 26 |
| Super Skrull | 24 | 275 | 30 | yes |
| Skrulls | 24 | 28 | 22 | yes (a grid: GD TY TY TY GD TY TY) |
| Nick Fury | 25 | 70 | 50 | yes |
| Henry Pym | 25 | 70 | 36 | Health: ranks give 28; Karma: ranks give 46 |
| Captain America (Jack Monroe) | 26 | 100 | 22 | yes |
| Hercules | 26 | 320 | 50 | yes |
| Scarlet Witch | 27 | 46 | 60 | yes |
| Hulk | 27 | 285 | 6 | yes (Strength Shift X) |
| Mad Thinker | 27 | 24 | 62 | yes |
| Victor | 28 | 120 | 140 | yes |
| Valor | 29 | 100 | 32 | Karma: ranks give 22 |
| Mephisto | 29 | 1225 | 250 | yes (Endurance Class 1000) |
| Thing (Divergent Earth) | 30 | 220 | 50 | yes |
| Crystal | 31 | 60 | 26 | yes |
| Daredevil | 31 | 110 | 91 | yes |
| Human Torch (Jim Hammond) | 32 | 100 | 22 | yes |
| Quicksilver | 33 | 150 | 36 | yes |
| Hawkeye | 33 | 70 | 22 | yes |
| Flare | 34 | 66 | 20 | yes |
| Nomad | 35 | 130 | 36 | yes |
| Mister Fantastic | 36 | 42 | 100 | yes |
| Invisible Woman | 36 | 46 | 40 | yes |
| She-Hulk | 36 | 175 | 36 | yes |
| Thing | 37 | 200 | 50 | yes |
| Human Torch (Johnny Storm) | 37 | 60 | 26 | yes |
| Wasp (Janet Van Dyne) | 38 | 46 | 50 | yes |
| Sub-Mariner | 39 | 185 | 76 | yes |
| Captain America (Steve Rogers) | 39 | 140 | 60 | yes |
| Spider-Man | 39 | 160 | 110 | yes |

**Four values fail, in three blocks, each read on the page image**
(`page:name:field printed->corrected`):

- `23:Captain America (Jeffrey Mace):Karma 36->26` (Good, Good, Typical)
- `25:Henry Pym:Health 70->28` (Typical, Typical, Typical, Good)
- `25:Henry Pym:Karma 36->46` (Remarkable, Good, Typical). His printed
  Health is Nick Fury's, the block above his on the same page.
- `29:Valor:Karma 32->22` (Typical, Typical, Good)

**Printed on purpose:** `21:Super-Adaptoid:Health 150` against ranks of
24. All seven ranks are Typical and the Health line says see below: its
Known Powers fix its Health at 150 whatever form it copies. An `as_printed`
with that reason (decision 9).

**The grids**, each an `F A S E R I P` row over two-letter codes and a
`Health:`/`Karma:` line, none with a name line:

| grid (registry name) | printed | codes | Health | Karma | checks |
|---|---|---|---|---|---|
| A.I.M. Soldiers | 4 | GD TY TY GD TY PR FE | 32 | 12 | yes |
| Golden Robots | 7 | EX EX IN MN EX IN TY | 155 | None | Health yes |
| Demons | 8 | IN EX IN RM TY TY RM | 130 | 42 | yes |
| Guardsmen Robots | 10 | RE RE RE RE TY EX TY | 120 | None | Health yes |
| A.I.M. Gunmen | 10 | EX GD GD EX TY PR FE | 60 | 12 | yes |
| A.I.M. Soldiers (repeat) | 20 | GD TY TY GD TY PR FE | 32 | 12 | yes; printed 4's code for code |
| A.I.M. Scientists | 20 | TY TY TY TY Var Var TY | 24 | Variable | Health yes |
| A.I.M. Technicians | 20 | TY TY TY GD TY TY PR | 28 | 16 | yes |
| Geoff Krubb | 20 | EX GD GD EX GD GD TY | 60 | 26 | yes |
| Sound Objects | 22 | TY TY RM RM FE FE FE | 72 | 6 | yes |
| Skrulls (the card's block) | 24 | GD TY TY TY GD TY TY | 28 | 22 | yes |
| Mad Thinker's Androids | 27 | RM EX EX RM PR FE FE | 100 | 8 | yes |

**Every grid's Health holds.** The robots print `Karma: None` over a full
R, I and P row, and the scientists `Var` for Reason and Intuition (the text
under the grid gives each a range) and `Karma: Variable` (decision 6). The
Sound Objects grid is set inside Klaw's SOUND OBJECTS power and the
androids' inside the Mad Thinker's text, as MH5's Humanoids and MH7's Fire
Creatures sat inside a card. Krubb's Karma line is printed beside his
Health; the A.I.M. soldiers' Karma on printed 20 is read by the OCR four
lines away from its grid, and the TSV puts it on the Health's line.

**Not grids, and not cards** (decisions 5, 7 and 8):

- **Three FASE rows** inside cards, each the character out of armor, with
  no Health: Victor (printed 28, EX TY GD EX), Valor (29, GO GO TY GO) and
  the divergent Thing (30, EX GD GD GD).
- **A header with no block:** the divergent SUB-MARINER (printed 22), a
  header and three identity lines over a paragraph that sends the reader to
  the Marvel Universe Namor's block (printed 39).
- **Ranks in prose only, with no grid:** a Roxxon guard (all Typical,
  Health 24, Karma 18, printed 4), a warehouse guard (all Typical, found at
  Health 3), the A.I.M. soldiers again, a family (Typical and Poor) and five
  S.W.A.T. men (Good but for Excellent Fighting and Typical Reason and
  Psyche, Health 50, Karma 22: both hold), all printed 5; a crowd (printed
  7); three A.I.M. scientists (printed 16). The Super-Adaptoid's current
  Health of 110 (printed 5) is a state, not a block.

**Shapes the parser must accept**, read on the OCR and the page images:

- **Art captions in the header's type.** Each portrait is captioned with its
  character's name in bold capitals and a trademark sign, the same as a
  header: KLAW, SWORDSMAN, SUB-MARINER, SUPER-ADAPTOID and ATTUMA over the
  art on printed 21; CAPTAIN AMERICA (JEFFREY MACE) on 23; NICK FURY and
  HENRY PYM on 25; CAPTAIN AMERICA (JACK MONROE), HERCULES and SCARLET
  WITCH on 26; VALOR on 28; MEPHISTO on 29; and so on through printed 40
  (PETER PARKER and SPIDER-MAN). A caption has no identity line or block
  under it.
- **`Karma` with no colon** on ten blocks (Mephisto's and printed 36-39).
- **`Known Powers: None`** (Nomad, printed 35) and blocks with no Known
  Powers text before Talents (Captain America (Jeffrey Mace), printed 23).
- **One label or two** for background and personality (*Columns, labels and
  ranks*), and `Equipment/Possessions:` before `Talents:` on Nick Fury's.
- **Values that run on:** Resources with a bracket (Swordsman's over two
  lines; Attuma's, Klaw's and the Super Skrull's on one), Popularity with one (Captain America (Jeffrey
  Mace), Nomad), negative Popularity (Swordsman -5, Attuma -8, Super Skrull
  -15, Hulk -15, Mephisto -100, Klaw -2).
- **The trademark sign read as a closing double quote** after HERCULES,
  SUPER SKRULL and SKRULLS, and after names in the prose.
- **A CHAPTER N subhead** between cards on printed 21-25, and THE FANTASTIC
  FOUR and THE AVENGERS subheads, each over a paragraph of its own, on 36
  and 38.

## Names the Codex already has

Super-Adaptoid (MH3), Swordsman (MH8), Sub-Mariner (MA4, MHSP2), Attuma
(MA4), Klaw (MHSP1), Wasp (MHSP1, MH2, MHSP2, MH8), Captain America (MHSP1,
MH2, MHSP2, MH8), Super-Skrull (MA4, MH2: hyphened there, not here),
Skrulls (MH2, MHSP2; Skrull MA4), Hercules (MHSP2, ME2), Scarlet Witch
(MA1, MH2), Hulk (MHSP1), Mad Thinker (MA4, with Mad Thinker's Awesome
Android), Mephisto (MA4, MHSP2), Thing (MHSP1, MA4, MH3, MHSP2), Crystal
(ME1, MA4), Daredevil (MHSP2, MH4), Human Torch (MHSP1, MA4, MH3, MHSP2),
Quicksilver (MA1), Hawkeye (MHSP1, MHSP2, MH7), Mister Fantastic (MHSP1,
MA4, MHSP2; Mr. Fantastic MH3), Invisible Woman (MA4, MHSP2), She-Hulk
(MHSP1, MA4, MH3, MHSP2) and Spider-Man (MHSP1, MHSP2, MH8). Under other
names: Nomad is Rick Jones (MH7), Victor is this world's Doctor Doom
(MHSP1, MA4, MH3, MHSP2) and Flare its Dazzler (MA1, MHSP2).

Each MH9 card is a card of its own with a `-mh9` id (Nate, 2026-09-28),
and most of the divergent Earth's are other people under a known name
(three Captains America, an android Human Torch). New: Nick Fury, Henry
Pym, Victor, Valor, Flare, Nomad and every grid.

## Quote marks

**The book prints no single quotes of its own.** It prints its double
quotes as two straight strokes, which Tesseract reads as two singles, a
single and a double, or a double. Eleven marks the OCR reads as a lone
single were read on the page images (printed 2, 7, 9, 10, 13 twice, 14, 20
twice, 23 and 32): every one is a double quote but the apostrophe of SPIRIT
OF '76.

**Apostrophes stand where a quote could be read:** that one, inside
Captain America (Jeffrey Mace)'s background (printed 23, read on the
image); the elision at the end of a word in the Thing's battle cry
(printed 30) and in the title page's credits (printed 1); and dialect
elisions in a chapter's dialogue (printed 14), the last three read in the
OCR. MHSP1's rule (every single mark is a misread) fits the book, with the
two in cards as `text` verdicts if the chain turns them into quotes. A
line of Hawkeye's card (printed 33) prints the fraction one half, read as
a single quote, a slash and a 2, as MH8's Wasp's did. The trademark sign
read as a closing double quote (above) will unbalance the double quotes in
several rows.

## Which reader fits

**Not finished.** This survey sets no `layout`.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-29: take the survey's recommendations).

1. **Teams:** Fantastic Four for the five cards under THE FANTASTIC FOUR
   (Mister Fantastic, Invisible Woman, She-Hulk, Human Torch (Johnny Storm)
   and the Thing of printed 37, whose identity line calls him independent
   but whom MA4 and MH3 file there too); Avengers for the Wasp (Janet Van
   Dyne), Sub-Mariner and Captain America (Steve Rogers), whose identity
   lines name the team; every other card, Spider-Man and the whole divergent
   Earth included, under **MH9 Gates of What If** (recommended, as MH7 and
   MH8 filed only under a team the Codex already has). Not taken: the
   divergent teams the identity lines name (Defenders East, Defenders West,
   New Invaders, S.H.I.E.L.D. Special Forces) as new filter groups that no
   other book shares.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure, items,
   places or maps.
3. **Every grid a card** (recommended, as MH1-6 imported every statted
   grid), named by what the prose calls them, as MH7's Fire Creatures: A.I.M.
   Soldiers, Golden Robots, Demons, Guardsmen Robots, A.I.M. Gunmen, A.I.M.
   Scientists, A.I.M. Technicians, Geoff Krubb (his name, printed; the
   Commander left out), Sound Objects and Mad Thinker's Androids. The A.I.M.
   soldiers' second grid (printed 20) one card with printed 4's, checked
   against it and not an entry (recommended, as MH4's 2 Minions and MH6's
   Moltens).
4. **Names printed twice:** each card of a name the book prints more than
   once carries the real name from its identity line in brackets, as the
   book's own captions do for Captain America: Captain America (Jeffrey
   Mace), (Jack Monroe) and (Steve Rogers); Human Torch (Jim Hammond) and
   (Johnny Storm); Wasp (Janet Pym) and (Janet Van Dyne). Both Things are
   Benjamin J. Grimm, so the divergent one is Thing (Divergent Earth) and
   the Marvel Universe one Thing (recommended). Without it two or three
   cards would share one id. Not taken: every divergent card marked
   (Divergent Earth), which would leave the two divergent Captains America
   one id.
5. **No card for the divergent Sub-Mariner** (recommended, as MH6 decision 9
   and MA1's cross-references): its header prints no block and its text
   points at the Marvel Universe Namor's.
6. **Karma None and Variable, and the scientists' Var:** left unset as
   printed (recommended, as MH5 decision 10 and MH6 decision 11); the Health
   holds on the codes printed.
7. **The three FASE rows** (Victor, Valor, the divergent Thing) kept in
   their cards' powers text and not made cards (recommended): each is the
   card's own character out of armor, with no Health.
8. **No card for ranks given in prose only** (recommended, as MH1-7's
   variants in prose only).
9. **The four failing values** as `misprint` overrides, printed and
   corrected kept, Henry Pym's Karma in his Health override's `also`
   (recommended); the Super-Adaptoid's Health 150 as `as_printed`, its own
   text being the reason.
10. **Names:** as printed (recommended): Super Skrull with no hyphen, though
    MA4 and MH2 print Super-Skrull; Victor and Flare, not Doctor Doom and
    Dazzler; Nomad, not Rick Jones; Skrulls for the Skrull warrior's card;
    the leading The dropped from THE THING (Nate, 2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mh9 --probe
python scripts/msh/ocr-book.py mh9
python scripts/msh/survey.py mh9
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
Page images were rendered with PyMuPDF at 30-110 dpi into the scratchpad.
