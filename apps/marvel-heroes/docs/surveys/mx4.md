# Survey: MX4 Flames of Doom (TSR6888)

> **DRAFT** (rows 7a and 7c, 2026-11-01). Every section is measured,
> *Which reader fits* by a trial parse on a scratch copy; the Marvel smoke
> suite has not yet run over it. No data has been built from this book.

Official Game Adventure for Marvel Super Heroes, David "Zeb" Cook, 1987; the
fourth module of the MX series (the back cover).
Registry entry: `scripts/msh/books.json` -> `mx4`. Measured 2026-11-01.

**Rows citing this book:** 0 `msh_book_text` rows (no data row has run).

Everything here was measured and read on the page images.

The fourth module of the MX series, through `scripts/msh/` only. Characters
only (Nate, 2026-10-21): the adventure, items and places are not imported.

## The scan

- 36 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 on every page),
  cached 2026-11-01 into the main checkout's `.cache/msh/books/mx4/`
  (36 pages OCR'd, 0 already cached).
- **One 32-page booklet**, its two outside covers, one spread the width of
  two covers, and one map sheet. The back cover names the package as a
  32-page book and one map. The print is clean; the grids and run-in labels
  OCR well, the banners (capitals in a brick band) mostly do too.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 599 x 775 | Cover (outside front; prints MX4 and 6888) | - |
| 2-33 | 594 x 767 | Adventure Book | 1-32 |
| 34 | 599 x 775 | Back cover (code 6888XXX1401, ISBN 0-88038-482-4) | - |
| 35 | 1206 x 774 | North America Map (brigade zones, Sentinel regional HQs, internment camps) | - |
| 36 | 2378 x 1578 | Map sheet: SenSatCom Compound Map, Shopping Mall Battle Map, Ceasefire Handout, CRA Resources Table | - |

PDF 35 is twice a cover's width, so by its size it is the inside of the
cover as one spread; the back cover's one map is PDF 36. Neither map prints
a statistic (the CRA Resources Table lists unit names and a team type). None
is imported.

**Pages that are not body text** (each read on the image): PDF 4 (printed 3)
a full-page comic, PDF 12 (printed 11) half a page of comic, PDF 24 (printed
23) half a page of art, PDF 33 (printed 32) the Great Debate Cards, a
handout the text says to photocopy and cut apart.

## Offset

`survey.py` votes **printed = PDF - 1 on 22 pages** (PDF 11-33 but 21). The
rest, each read on the page image:

- PDF 3-10 and 21: their folios (2-9 and 20) are at the foot, missed by
  Tesseract. PDF 4 is the full-page comic and still prints its folio.
- PDF 2 (printed 1): the title and Contents page, no folio. The Contents'
  first entry is printed 2, and PDF 3 opens it.
- PDF 34: a vote of 2 (k = 32), the digit after the bar code. Not a folio.
- PDF 36: a vote of 7 (k = 29), a speck in the map sheet's border of stars.
  Not a folio.

So `parts`, as MX1's single booklet, with the covers and both maps as parts
of their own.

## The book's own authority lists

**A Contents** on printed 1 (PDF 2), in two columns, transcribed from the
page image (the OCR mangles the dot leaders) and stored as `sections`. Every
entry was read on its page:

| printed | Contents | on the page |
|---|---|---|
| 2 | The Cruelest of Dreams | banner THE CRUELEST OF DREAMS |
| 5 | Choices, Choices | banner CHOICES, CHOICES |
| 7 | Loose Ends Encounters | banner LOOSE ENDS ENCOUNTERS |
| 12 | How the Worlds End | banner HOW THE WORLDS END |
| 12 | (indented) The Peoples' Revolution | subhead **The People's Revolution**, column 1 |
| 18 | (indented) The Teleporters' Railroad | subhead The Teleporters' Railroad |
| 22 | (indented) Salvation | subhead Salvation |
| 25 | The Arm of the State | banner THE ARM OF THE STATE, then the subhead Appendix #1: Sentinels |
| 27 | Non-Player Characters | banner NON-PLAYER CHARACTERS, then the subhead Appendix #2: Non-Player Characters |
| 32 | The Great Debate Cards | a brick band with no words, then the subhead Appendix 3: The Great Debate Cards |

**Every page agrees**, so there is no `contents_errata`. The registry keeps
the Contents as printed (`Peoples'`), as MX1's does its one banner that
reads otherwise. Two subheads in the same bold title case have no Contents
line: **Life in Hell** (printed 24, column 3; the fourth ending, beside the
three the Contents indents) and **The Hardware of Hell** (printed 31, column
1, after Sunspot's entry; gear).

**No index.** The coverage checklist is this survey's list, carried as
`cards` (*Stat blocks*).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's rows and its
  totals are two sub-columns of one column. The title page sets its
  Contents in two.
- **One grid shape in the whole book**, MA1's, read on the page images of
  printed 25-30 at 110-200 dpi: seven rows of a row letter, the **number,
  then its code** (`20 Ex`, `150 Shift X`), with `Health =`, `Karma =`,
  `Resources =` and `Popularity =` beside rows F, S, R and P, under a header
  in **bold title case**. The six sentinels print no identity line; the
  seven NPCs print an **italic identity line** of one to four lines under the
  header (`Sam Guthrie, Rebel, Mutant`; Mystique's runs to four). Four NPC
  grids (Magma, Mirage, Mystique, Marco Pene) set the row letters well apart
  from the numbers; the rest set them close. The OCR welds number and code
  (`50Am`) and reads the I row's letter as `|`.
- **Alternates in brackets**: Cannonball's S `10 Gd (30 Rm)` (the bracket
  wraps onto a second line), Sunspot's S `6 Ty (40 In)`, Cannonball's
  Resources `Pr (Ex)` and Lila Cheney's `Pr (In)`. Nimrod's Resources wraps
  `In` / `(40)`. Mystique's Karma prints `150*`, the asterisk keyed to a
  footnote under her grid giving the reason.
- **Section labels**, counted on the OCR of printed 25-31 and read on the
  images: `Known Powers:` (13, one per block, a bold line of its own), then
  italic run-ins ending in a colon, **set in the same italic as the power
  names**: `Talents:` (7, every NPC), `Contacts:` (6, all but Marco Pene),
  `Background:` (6, all but Mystique) and `Equipment:` once (Mirage, printed
  29, after her last power and before her Talents). Mystique's `Weapons:`
  (printed 29) sits among her powers (decision 5). The sentinels print
  `Known Powers:` only.
- **Ranks**: Pr (Resources only), Ty, Gd, Ex, Rm, In, Am, Mn (the Mark IV's
  Endurance, Mystique's Resources), Un (the Mark V's Endurance) and
  `Shift X` (the Endurance of the Mark VI, Alpha, Omega and Nimrod). No Fb,
  Fe or Shift 0. In `rank_aliases`. Nimrod's codes are misprints, not
  aliases (below).
- **`survey.py` finds 13 blocks and reads none of them**: it finds every
  `Health =` line, but its header rule wants capitals (it takes the NPC
  banner for Cannonball's header and finds no other) and its row pattern a
  space between number and code. Its block count is this book's; its checks
  are not.

## Where the blocks are

Printed 25-26 (The Arm of the State, Appendix #1: the six sentinels) and
printed 27-30 (Non-Player Characters, Appendix #2: seven NPCs), Sunspot's
text running on to printed 31, column 1, where The Hardware of Hell begins.
Stored as one `character_ranges`, printed 25-31. The Health and Karma the OCR
finds anywhere else are prose (printed 4, 9, 11, 16, 18 and 22: Karma the
hero's name in a list, a satellite's Health, Karma awards and the CRA's own
Karma), not grids; no page outside the two appendices holds a rank row.
**No being is statted inside a chapter's prose**, so the book has no
`opponents`, `one_line_grids` or `tiers`.

## Stat blocks: 13, all with a header

| printed (PDF) | name | F A S E R I P as printed | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|
| 25 (26) | Mark IV Sentinel | 20 Ex, 20 Ex, 50 Am, 75 Mn, 6 Ty, 6 Ty, 6 Ty | 165 | 0 | 0 | 0 |
| 25 (26) | Mark V Sentinel | 20 Ex, 20 Ex, 50 Am, 100 Un, 10 Gd, 6 Ty, 6 Ty | 190 | 0 | 0 | 0 |
| 25 (26) | Mark VI Sentinel | 30 Rm, 20 Ex, 50 Am, 150 Shift X, 10 Gd, 10 Gd, 6 Ty | 250 | 0 | 0 | 0 |
| 25 (26) | Alpha Sentinel | 50 Am, 40 In, 50 Am, 150 Shift X, 20 Ex, 10 Gd, 10 Gd | **250** | 0 | 0 | 0 |
| 26 (27) | Omega Sentinel | 50 Am, 40 In, 50 Am, 150 Shift X, 30 Rm, 20 Ex, 10 Gd | 290 | 0 | 0 | 0 |
| 26 (27) | Nimrod | 50 Am, 50 Am, 50 Am, 150 Shift X, 30 **Ex**, 30 **Gd**, 10 **Ty** | 300 | 70 | In (40) | 0 |
| 27 (28) | Cannonball (Sam Guthrie) | 30 Rm, 10 Gd, 10 Gd (30 Rm), 40 In, 10 Gd, 10 Gd, 20 Ex | 90 | **10** | Pr (Ex) | -10 |
| 27 (28) | Lila Cheney | 10 Gd, 20 Ex, 6 Ty, 30 Rm, 20 Ex, 10 Gd, 10 Gd | 66 | **20** | Pr (In) | 10 |
| 28 (29) | Magma (Amara Aquilla) | 16 Ex, 20 Ex, 10 Gd, 40 In, 30 Rm, 20 Ex, 20 Ex | **100** | **60** | Gd | 10 |
| 28 (29) | Mirage (Danielle Moonstar) | 30 Rm, 20 Ex, 10 Gd, 30 Rm, 10 Gd, 20 Ex, 40 In | **80** | **20** | Pr | -10 |
| 29 (30) | Mystique (Raven Darkholme) | 20 Ex, 20 Ex, 10 Gd, 40 In, 30 Rm, 20 Ex, 40 In | 90 | 150* | Mn | 20 |
| 30 (31) | Marco Pene | 16 Ex, 20 Ex, 10 Gd, 15 Gd, 10 Gd, 16 Ex, 20 Ex | **35** | **60** | 0 | 0 |
| 30 (31) | Sunspot (Roberto Da Costa) | 20 Ex, 10 Gd, 6 Ty (40 In), 40 In, 16 Ex, 10 Gd, 20 Ex | 76 | **30** | Ex | 10 |

**The book checks itself**, each value read on a crop of the page image (Nimrod,
Cannonball, Magma, Mirage, Marco Pene and Sunspot at 160-200 dpi, the rest at
110):

| measure | count |
|---|---|
| Health = F+A+S+E | **9 of 13**; the Alpha Sentinel (290, printed 250), Magma (86, printed 100), Mirage (90, printed 80) and Marco Pene (61, printed 35) fail. Cannonball's 90 and Sunspot's 76 hold on the S before the bracket |
| Karma = R+I+P | **1 of 13** (Nimrod); the five other sentinels' `Karma = 0` (printed on purpose, below), Mystique's `150*` (footnoted, below), and Cannonball (40, printed 10), Lila Cheney (40, printed 20), Magma (70, printed 60), Mirage (70, printed 20), Marco Pene (46, printed 60) and Sunspot (46, printed 30) |
| every number its rank code's standard | **9 of 13**; not Nimrod (codes), Magma, Marco Pene or Sunspot (in range, below) |
| every number within its rank code's range | **12 of 13**; Nimrod's three codes are not his numbers' ranks |

**Five numbers are inside their code's range and not its standard**
(`ranks.json`): Magma's F 16 Ex, Marco Pene's F 16 Ex, E 15 Gd and I 16 Ex,
and Sunspot's R 16 Ex (decision 6).

**The misprints, each read on the page image** (printed page: name: field
printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 25:Alpha Sentinel:Health 250 -> 290 | 50+40+50+150 = 290; MX1, MX2 and MX3 print the same seven numbers and Health 290 |
| 26:Nimrod:R code Ex -> Rm (30) | Karma 70 = 30+30+10 holds on the numbers; 30 is Remarkable; MA1 prints his R 30 Rm, and MX1's override is the same |
| 26:Nimrod:I code Gd -> Rm (30) | as above; MA1 prints I 30 Rm |
| 26:Nimrod:P code Ty -> Gd (10) | 10 is Good; MA1 prints P 10 Gd (MX1 misprints the same row Gy) |
| 27:Cannonball:Karma 10 -> 40 | R+I+P = 10+10+20 |
| 27:Lila Cheney:Karma 20 -> 40 | R+I+P = 20+10+10 |
| 28:Magma:Health 100 -> 86 | F+A+S+E = 16+20+10+40 |
| 28:Magma:Karma 60 -> 70 | R+I+P = 30+20+20 |
| 28:Mirage:Health 80 -> 90 | F+A+S+E = 30+20+10+30 |
| 28:Mirage:Karma 20 -> 70 | R+I+P = 10+20+40 |
| 30:Marco Pene:Health 35 -> 61 | F+A+S+E = 16+20+10+15; MX3 prints the same seven numbers, misprints his Health another way (55) and its data row corrected it to 61 |
| 30:Marco Pene:Karma 60 -> 46 | R+I+P = 10+16+20; MX3's corrected Karma is 46 too |
| 30:Sunspot:Karma 30 -> 46 | R+I+P = 16+10+20 |

Each correction is to the sum of the printed numbers, the numbers kept, as
MX1's Typical Rogue, MX3's four chapter grids and MT3's Franklin and Tyler
were (decision 4). No reading of Magma's or Mirage's numbers makes both her
Health and her Karma hold with one change, so neither is read as a single
mistyped row.

**Printed on purpose:** the five sentinels other than Nimrod print `Karma =
0`, `Resources = 0` and `Popularity = 0` (robots, as MX1, MX2 and MX3
print theirs). Mystique's `Karma = 150*` is footnoted under her grid as
reflecting her standing as Raven Darkholme, not her R, I and P.

## Entry kinds

1. **A robot type with a full grid**: the five sentinel marks, a header and
   no identity line.
2. **A named robot**: Nimrod, the same shape, with Karma and Resources.
3. **A named character with a full grid and an identity line**: Cannonball,
   Lila Cheney, Magma, Mirage, Mystique, Marco Pene and Sunspot. Mirage's
   steed Brightwind is described among her powers, ranks in the prose and
   no grid of its own.
4. **Characters in the prose only**, named and not statted: the fallen and
   missing heroes listed on printed 4, Nick Fury (the back cover), the
   chapters' rebels and officials.
5. **Gear and places with ranks**, out of scope by Nate's ruling: the ASAT
   satellites (printed 11, a Health each), The Hardware of Hell's jammers,
   wild weasels, masks, minutemen and I.D. cards (printed 31), the maps, the
   CRA Resources Table and the Great Debate Cards.

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
a `-mx4` id:

- **The sentinels**: MA1's `Mark IV & V Sentinels`, `Alpha Sentinel`,
  `Omega Sentinel` and `Nimrod`; MX1's and MX2's six and MX3's five, each a
  card. **Every MX4 sentinel prints MX1's numbers and codes** but the Alpha's
  Health (above) and Nimrod's P code (`Ty` here, `Gy` in MX1, `Gd` in MA1).
  The Omega's sixth row prints `I` here, where MX1 prints `U`.
- **Marco Pene**: MX3's `marco-pene-mx3`, the same seven numbers and codes
  (above).
- **The NPCs**: MA1's `Cannonball`, `Magma`, `Mirage`, `Sunspot`, `Mystique`
  and `Cheney, Lila`, and MHSP2's `Cannonball`, `Magma`, `Mirage`, `Sunspot`
  and `Lila Cheney`, read against `npcs.json`. **MX4's are other blocks**:
  this future's older characters print higher ranks (Cannonball F 30 Rm
  and E 40 In against MA1's 10 Gd and 30 Rm; Magma's F 16 Ex against 10 Gd;
  Mirage's A 20 Ex against 6 Ty; Sunspot's F 20 Ex against 10 Gd).
  Mystique's are MA1's but R (30 Rm, MA1 20 Ex), and her Karma; Lila Cheney's
  are MA1's but P (10 Gd, MA1 6 Ty).

No name is new to the Codex; every block is.

## Quote marks

**No single-quoted phrase of the book's own was found.** Measured on the OCR
of all 36 pages: 81 opening and 72 closing curly doubles, 8 straight doubles,
27 opening singles, 165 closing singles (mostly apostrophes) and 8 straight
singles. Every opening single is half of a double read as two marks (a pair
of singles, or a single either side of a double) or a speck in a banner
(printed 27, PDF 28's first line); three read on the images were doubles
(printed 8, around a phrase; printed 16, around the handout's title;
printed 20, a double then a single in the OCR, a plain double on the page).
Printed 24's double-then-single was not read on the image. The 8 straight
singles: four in the comic's lettering (printed 3), two contractions, the
banner speck and a mark in the bar code. On the
character pages, the one mark that is not an apostrophe or a double is an
**elision**, a closing single before a clipped word in Lila Cheney's
Specialized Teleport (printed 27). So the rule looks like MX1's and MHSP1's
(every single that is not an apostrophe or that elision is half of a
double), and **the data row must confirm it on the character pages** before
relying on it.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with MX1's and MX2's
registry fields, two registry-only workarounds and two things taught to the
reader.** Measured, not argued: a scratch copy of `scripts/msh/` and
`apps/marvel-heroes/data` at `818681bb` (`main`'s scripts at `f1c92595` plus
this entry), the entry given `"layout": "grid-booklets"`, run on a copy of
the cache under its own `WORKSHOP_MSH_CACHE` (no page re-OCR'd; only grid
crops were added, to the copy). Without MX3's `code_rows`: every grid is the
number-first shape.

- **Stock, `layout` alone:** `roster.py mx4` runs to the end and exits 1.
  15 entries, 13 blocks, 1 passing (Mystique's, only because the check skips
  a Karma that is not a number), 12 failing, **no power in any entry**; ten
  cards with no entry (the Mark IV, V and VI, and all seven NPCs, each named
  by a line of its identity, `Mutant` alone three times);
  Cannonball's Health not a number (`90 (30 Rm)`), Mystique's Karma not a
  number (`150*`).
- **Stock, with the MX family's fields** (`card_headers`,
  `title_case_labels`, `rank_ranges`, `teams` with every card under MX4 Flames
  of Doom): exit 1. 70 powers across the 13 entries, every NPC but two named;
  five cards with no entry (the Mark IV, V and VI, Mystique, Sunspot) and
  Cannonball's Health still not a number.
- **With the workarounds and reader changes below:** exit 0.

| measure | trial, last run |
|---|---|
| entries | 16: 13 with a block, 3 without (the headings The Arm of the State, Non-Player Characters and The Hardware of Hell) |
| stat blocks | 13 of 13, every value as *Stat blocks* lists it, Cannonball's and Sunspot's S alternates read as alternates |
| blocks passing every check | 0, and 13 known from trial overrides (5 `as_printed`, 8 `misprint`): the survey's misprints and printed-on-purpose Karmas, each matching one block; failing 0 |
| powers | 70 across 13 entries, each NPC's power names as the page's run-ins give them (Cannonball 2, Lila Cheney 2, Magma 4, Mirage 4 with Brightwind, Mystique 5 with Weapons, Marco Pene 2, Sunspot 1) |
| checklist | 13 cards, all found |
| exit code | 0 |

Every block carries a trial override, so no block passes on its own: the
survey's thirteen (decision 4: the five robots' `Karma = 0` and Mystique's
`150*` `as_printed`, the Alpha's Health, Nimrod's three codes and the six
NPCs' Health and Karma `misprint`), written for the trial only and not
re-read on the images; the data row writes the real file.

**Registry-only workarounds** (no reader change; each worked in the trial,
and each was dropped in turn to see what it holds):

1. **Three sentinel headers lose their first word.** Tesseract boxes `Mark`
   and the F row's letter below it as one word two lines tall, read `a`,
   `mark` and a dash at confidence 17-39 (PDF 26), so the stream reads `IV Sentinel`, `V Sentinel` and `VI Sentinel`, which
   `card_headers` does not match. MX1's `speck_lines` (`[part, page, as read,
   as printed]`) puts each back. Dropped: exit 1, three cards with no entry
   and their three `as_printed` overrides matching nothing.
2. **The Hardware of Hell** (printed 31, column 1) is a title the Contents
   does not list and not a character: MX1's `extra_titles` ends Sunspot's
   entry at it. Dropped: **exit 0, silently**, 15 entries, the gear's text
   in Sunspot's entry.
3. **The MX family's fields:** `card_headers` (dropped: exit 1, every NPC
   named by its identity line); `title_case_labels` (dropped: **exit 0, 0
   powers**, every run-in a paragraph); `rank_ranges` (decision 6; no change
   to `roster.py`'s counts, since every block it covers carries an override
   that marks the whole block explained, so it is the Marvel smoke suite's
   Health/Karma check that needs it); `teams` (no change to `roster.py`;
   `npcs.py` files by it).
4. **The misprints and printed-on-purpose Karmas**: overrides, as above.

**What the reader must learn: two things**, both applied in the trial behind
registry fields that every earlier book leaves unset (`gridbooks.py` 12
changed lines, `roster.py` 18; not yet proved byte-identical on the earlier
books, which is the parser row's to do):

1. **An identity line of four lines** (Mystique, printed 29; Sunspot's is
   three). `mark_headers` looks three non-row lines above the grid for a
   card's name and `roster.read_entries` keeps three identity lines, so
   Sunspot's header (four lines up) and Mystique's (five) are not found and
   each entry takes its identity line's last line for a name (`Mutant`,
   `cy), Mutant`); Mystique's fourth line lands in her prose. The trial adds
   `identity_lines` (4): a card's name is looked for that many lines plus
   one above the grid, and that many identity lines are kept. Dropped: exit
   1, Mystique and Sunspot with no entry.
2. **A bracketed alternate wrapped onto the next line** (Cannonball's S,
   printed 27: the crop reads `S 10 Gd (30` and then `Rm) Karma = 10`).
   `roster.ROW` wants the closing bracket on the row's line, so the `(30` and
   `Rm)` join the rows' remainder and his Health reads `90 (30 Rm)`. The
   trial adds `wrapped_alternates`, a `GridReader` mend that joins the code
   and its bracket back onto the row before it is read; his S reads `10 Gd`
   with the alternate `30 Rm`, and his Health 90. Dropped: exit 1, his Health
   not a number.

Read and fine as it is: the number-first rows and `Health =` read with
`roster.grid_at` unchanged, `Shift X` included, from the grid crops (the
stream's F rows of the Mark IV, V and VI carry the welded `Mark` as a stray
letter; the crops read clean); the I row read as `|` is taken by position;
Sunspot's S `6 Ty (40 In)` reads as an alternate on one line; Nimrod's
`In` / `(40)` and the NPC Resources `Pr` / `(Ex)` join their rows; the
minus of Cannonball's and Mirage's Popularity reads as a dash, which
`npcs.minus` already takes; Mystique's `150*` is kept as printed for its
`as_printed` override, and her footnote under the grid lands in her prose.
`KNOWN POWERS:` reads in capitals in the stream, so `title_case_labels` is
needed for the run-ins only. Mirage's `Equipment:` ends her powers and
lands in a `notes` section with its label, as MX3's does (decision 5);
Mystique's `Weapons:` stays a power. Brightwind is a power run-in, as
printed (*Entry kinds*).

The other readers fit less: `codegrids.py` (MA4) reads one offset and
`page_stream`, not booklet `parts`, and MT3's trial found it stops at a
missing `offset`; `roster.py` (MA1) reads no booklet; `booklet.py`,
`rosterbook.py` and `coverpanels.py` read rank words or cover panels. The
entry still sets no `layout`: that is the parser row's to write, with the
two reader items behind the registry and every earlier book's build proved
byte-identical. The scratch registry patch, the trial overrides, both
reader diffs (CRs stripped), each stock run, the field-by-field ablation
and the last run's output are kept in the plan store, `trial\mx4\`.

## Decisions this survey leaves open

Each has a recommendation, the one MX1, MX2, MX3 and MT3 took where they had
the same question (Nate 2026-10-31: take the survey's recommendations).

1. **Teams.** The book has no team sections. Recommendation: every card
   under the book's title, **MX4 Flames of Doom**, as MX1, MX2 and MX3 filed
   theirs; the six sentinels each a card of their own, as each prints its
   own header. Not written to the registry until decided.
2. **Page citations.** Recommendation: MX1's single-booklet shape,
   `MX4 Adventure p.27` (the part's `cite` is `Adventure`).
3. **Names.** Recommendation: each header as printed (the six sentinels,
   **Cannonball**, **Lila Cheney**, **Magma**, **Mirage**, **Mystique**,
   **Marco Pene**, **Sunspot**), the identity line kept as the card's
   identity, as MX1 kept its NPCs'. Lila Cheney under the name MX4 prints,
   as MHSP2's card is, not MA1's surname-first index form.
4. **The misprints.** Recommendation: overrides keeping printed and
   corrected, as listed under *Stat blocks*: Nimrod's three codes (as MA1
   prints them, MX1's override), the Alpha Sentinel's Health 250 to 290, and
   each other failing Health or Karma corrected to the sum of the printed
   numbers, the numbers kept, as MX1, MX3 and MT3 corrected theirs; a block
   with two faults carries the second in its `also`. The five robots'
   `Karma = 0` kept `as_printed`, as MX1's, MX2's and MX3's sentinels (the
   Alpha's in the `also` of its Health). Mystique's `Karma = 150*` kept
   `as_printed`, with the footnote's reason (MT3's Kang `Varies` shape). The
   alternative not recommended: the six failing NPC Karmas `as_printed` as a
   current Karma, on the ground that not one NPC's adds up; but the book
   explains the one Karma it sets by hand (Mystique's footnote) and no
   other, and MX3 corrected the same Marco Pene to the same sums.
5. **Mirage's `Equipment:` and Mystique's `Weapons:`.** Recommendation:
   `Equipment` a section label, as MX3's, so Mirage's plasma rifle paragraph
   ends her powers; `Weapons` kept a power as printed, since it sits between
   two of Mystique's powers with her other gear (Combat Suit, Personal
   Mask). Characters only either way: neither is imported as an item.
6. **The five numbers inside a range but not its standard** (Magma, Marco
   Pene, Sunspot). Recommendation: `rank_ranges` for this book, as MX3 took
   for twelve (Marco Pene's same three among them), rather than five `also`
   entries.
7. **The bracketed alternates.** Recommendation: kept as printed, the
   card showing the alternate beside the value (Cannonball's and Sunspot's
   S, the two NPC Resources), and the checks read on the value before the
   bracket, on which both Healths hold, as MA1's Sunspot keeps `52 (76)`.
8. **Characters only.** The Hardware of Hell's gear, the ASATs, the Great
   Debate Cards, the CRA Resources Table and both maps are not imported
   (Nate, 2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mx4 --probe
python scripts/msh/ocr-book.py mx4
python scripts/msh/survey.py mx4
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 30-200
dpi into the scratchpad, never into the repo.
