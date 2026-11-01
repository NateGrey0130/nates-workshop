# Survey: MX2 The X-Potential (TSR6875)

Official Advanced Game Accessory for Marvel Super Heroes, Mark Acres, 1987.
Registry entry: `scripts/msh/books.json` -> `mx2`. Measured 2026-10-31.

**Rows citing this book:** 103 `msh_book_text` rows over 24 character entries
in production (`DB_MARVEL`, read back 2026-10-31).

Everything here was measured and read on the page images.

The second module of the MX series, through `scripts/msh/` only. Characters
only (Nate, 2026-10-21): the adventure, items and places are not imported.

## The scan

- 35 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples), cached 2026-10-31 into the main
  checkout's `.cache/msh/books/mx2/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, 35 pages OCR'd).
- **One 32-page booklet**, its two covers and one sheet of handouts. There
  are no inside covers: the booklet's first page is its title page. The
  print is clean; the grids and the run-in labels OCR well, the banners
  (capitals in a brick band) mostly do not, and the folios of printed 2-9
  not at all.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 596 x 774 | Cover (outside front) | - |
| 2-33 | 594 x 767 | Adventure Book | 1-32 |
| 34 | 596 x 774 | Back cover (product code 6875 in the bar code, ISBN 0-88038-403-4) | - |
| 35 | 1513 x 2335 | Newspaper handouts: four front pages of one daily paper | - |

None of PDF 1, 34 and 35 prints a statistic or a rank, and none is
imported. The handouts name the adventure's characters in their headlines.

## Offset

`survey.py` votes **printed = PDF - 1 on 23 pages** (PDF 11-33, every one).
The rest, each read on the page image:

- PDF 3-10: their folios (2-9) are printed at the foot, faint, and missed
  by Tesseract.
- PDF 2 (printed 1): the title and Contents page, no folio. The Contents
  puts the Introduction at 2, and its banner opens PDF 3.
- PDF 34: a vote of 34 (folio 0), the bar code's leading digit. Not a folio.

So `parts`, as MX1's single booklet, with the covers and the handouts as
parts of their own. **Only PDF 2 of the booklet prints no folio**; no page
of it is full-page art.

## The book's own authority lists

**A Contents** on printed 1 (PDF 2), in two columns, transcribed from the
page image (the OCR mangles the dot leaders) and stored as `sections`. Every
entry was read on its page, its banner at the top of column 1:

| printed | Contents | banner as printed |
|---|---|---|
| 2 | Introduction | INTRODUCTION |
| 3 | The Nightmare World of the Future | THE NIGHTMARE WORLD OF THE FUTURE |
| 9 | Special Rules | SPECIAL RULES |
| 10 | Villains, NPCs, and Equipment | VILLAINS, NPCS, AND EQUIPMENT |
| 19 | Running the Adventure | RUNNING THE ADVENTURE |
| 22 | The Rally | THE RALLY |
| 25 | The Mutant Affairs Committee | THE MUTANT AFFAIRS COMMITTEE |
| 27 | The Mutant Resettlement Center | THE MUTANT RESETTLEMENT CENTER |
| 28 | The Army Base | THE ARMY BASE |
| 29 | McGrafton Industries, Inc. | McGRAFTON INDUSTRIES, INC. |
| 31 | The McGrafton Committee Hearings | THE McGRAFTON COMMITTEE HEARINGS |

**Every page agrees and every banner's words match**, so there is no
`contents_errata`. No other banner is printed (every booklet page read at
30-50 dpi).

**No index.** The coverage checklist is this survey's list, carried as
`cards`, `one_line_grids` and `tiers` (*Stat blocks*).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a full card's rows and its
  labels are two sub-columns of one column.
- **Three grid shapes in one book** (read on the page images of printed
  10-17):
  1. **The full cards** (McGrafton, printed 10; the five sentinels, 11;
     Nimrod, 12; Lorelei, 15): **the code, then the number in brackets**
     (`TY (5)`, `Shift X (150)`), in a vertical column under a header in
     bold title case. The six sentinels and Nimrod print `Health =`,
     `Karma =`, `Resources =` and `Popularity =` beside rows F, S, R and P
     (MX1's sentinels printed the number first; these print the code first);
     McGrafton and Lorelei print the same four with a colon. Only Lorelei has
     an identity line (her real name).
  2. **Codes-only grids** (printed 13-16, eleven of them): an
     `F A S E R I P` row, a row of seven codes, then `Health:` and `Karma:`
     on lines of their own. None prints a number. Each is under a bold
     title-case subhead: the five types' (Typical Policeman, SWAT:AM,
     Soldiers and Camp Guards, Secret Service Anti-Mutant Teams, Knights of
     Genetic Purity) with an introducing paragraph between subhead and grid,
     the six named characters' (Vincent Scarlesi, General William B.
     Braddock, the doctors Fuchido and Hernandez, Jay Atkinson and William
     Shiver) with one or two identity lines under it. SWAT:AM's subhead is
     on printed 13 and its grid on 14. Braddock's subhead runs to two lines
     (his rank and name with a comma, then `U.S. Army`).
  3. **A committee table** (printed 15): a letters row headed `Mutant`, five
     rows each a member's first name and seven codes (Chuck, Martha, Bob,
     Phil, Jenny), then **one** `Health:` and `Karma:` under all five. Each
     member then has a run-in paragraph headed by the name and a colon.
- **Subheads inside the character chapter that are not characters**, bold
  title case in a larger size: Villains (printed 10), The Sentinels (10),
  Notes on Sentinels and Non-Player Characters (13), The Mutant Affairs
  Committee (15) and Equipment (17), with smaller ones (Sentinel Law,
  Sentinel Organization, Sentinel Organic Scanners, 13). **The Mutant
  Affairs Committee subhead has the words of the chapter at printed 25.**
  Five prose lines start with `SWAT:AM` (printed 13 and 14, on the OCR),
  the run-in trap MX1's reader item 7 names.
- **Section labels**, counted on the OCR of printed 10-17 and read on the
  images: `Known Powers:` (8, the full cards), `Talents:` (11), `Talent:`
  (2), `Contacts:` (8), `Background:` (8) and `Equipment:` (4, the types'
  gear). Bold on the full cards and on Scarlesi's grid, plain under the
  other codes-only grids. The sentinels' and Nimrod's powers are italic
  run-in heads ending in a colon, as are Lorelei's four.
- **Ranks**: FE (Phil's Agility only), PR, TY, GD, EX, RM, IN, AM, MN, UN
  (the Mark V's Endurance) and `Shift X` (four sentinels' and Nimrod's
  Endurance), all in capitals. In `rank_aliases`. Nimrod's `EX (30)` is a
  misprint, not an alias (below).
- **Resources and Popularity**: McGrafton `MN (75)` with the number wrapped
  onto the next line, and 85; the five sentinels 0 and 0; Nimrod `IN (40)`
  on the line under `Resources =`, and 0; Lorelei `TY` with no number, and
  -30. Of the codes-only grids only Scarlesi's prints them: `IN` and 20.
- **`survey.py` finds 6 blocks and reads none of them**: it finds the
  sentinels' and Nimrod's `Health =` lines (no other block prints `=`), but
  its header rule wants capitals and its row pattern the number before the
  code. Its block count is not this book's measure.

## Where the blocks are

All in Villains, NPCs, and Equipment: printed 10 (McGrafton), 11 (the five
sentinels, the Omega's powers running on to 12), 12 (Nimrod), 13 (the
Typical Policeman, under Non-Player Characters), 14 (SWAT:AM, Soldiers and
Camp Guards, the Secret Service Anti-Mutant Teams, the Knights of Genetic
Purity, Scarlesi, whose text runs on to 15), 15 (Lorelei, the committee
table, Braddock, whose text runs on to 16) and 16 (Fuchido, Hernandez,
Shiver, Atkinson, whose text runs on to 17, where the Equipment subhead ends
the characters). **No other page of the book prints a Health, Karma or rank
row** (the OCR of all 35 pages), so `character_ranges` is printed 10-17 and
there are no `opponents`.

## Stat blocks: 8 cards, 11 grids and a committee of 5

| printed (PDF) | name | shape | F A S E R I P as printed | Health | Karma |
|---|---|---|---|---|---|
| 10 (11) | Senator Joseph McGrafton | 1 | TY 5, GD 8, GD 8, IN 36, AM 46, IN 36, AM 46 | 57 | 128 |
| 11 (12) | Mark IV Sentinel | 1 | EX 20, EX 20, AM 50, MN 75, TY 6, TY 6, TY 6 | 165 | 0 |
| 11 (12) | Mark V Sentinel | 1 | EX 20, EX 20, AM 50, UN 100, GD 10, TY 6, TY 6 | 190 | 0 |
| 11 (12) | Mark VI Sentinel | 1 | RM 30, EX 20, AM 50, Shift X 150, GD 10, GD 10, TY 6 | 250 | 0 |
| 11 (12) | Alpha Sentinel | 1 | AM 50, IN 40, AM 50, Shift X 150, EX 20, GD 10, GD 10 | 290 | 0 |
| 11 (12) | Omega Sentinel | 1 | AM 50, IN 40, AM 50, Shift X 150, RM 30, EX 20, GD 10 | 290 | 0 |
| 12 (13) | Nimrod | 1 | AM 50, AM 50, AM 50, Shift X 150, **EX** 30, RM 30, GD 10 | 300 | 70 |
| 15 (16) | Lorelei (Laura Lee Masters) | 1 | EX 16, RM 26, EX 16, IN 36, GD 8, IN 36, RM 26 | 94 | 70 |
| 13 (14) | Typical Policeman | 2 | GD GD TY GD TY TY TY | 36 | 18 |
| 14 (15) | SWAT:AM | 2 | EX GD GD TY TY TY GD | 46 | 22 |
| 14 (15) | Soldiers and Camp Guards | 2 | EX GD TY GD TY TY PR | 46 | 16 |
| 14 (15) | Secret Service Anti-Mutant Teams | 2 | GD EX GD GD GD GD GD | 50 | 30 |
| 14 (15) | Knights of Genetic Purity | 2 | GD GD GD GD PR PR PR | **32** | **14** |
| 14 (15) | Vincent Scarlesi | 2 | GD PR PR TY GD GD EX | **20** | **30** |
| 15 (16) | General William B. Braddock | 2 | GD TY GD GD EX TY EX | **29** | **37** |
| 16 (17) | Dr. Yagami Fuchido | 2 | PR TY PR TY RM GD TY | 20 | 46 |
| 16 (17) | Dr. Paolo Hernandez | 2 | PR TY PR TY RM RM TY | 20 | **56** |
| 16 (17) | William Shiver | 2 | TY TY TY GD EX GD EX | 28 | 50 |
| 16 (17) | Jay Atkinson | 2 | PR TY TY TY GD GD TY | 22 | **32** |
| 15 (16) | Chuck | 3 | PR TY PR PR GD TY TY | **20** | **10** |
| 15 (16) | Martha | 3 | TY TY TY GD TY GD EX | **20** | **10** |
| 15 (16) | Bob | 3 | GD GD GD EX TY TY TY | **20** | **10** |
| 15 (16) | Phil | 3 | TY FE EX TY EX PR EX | **20** | **10** |
| 15 (16) | Jenny | 3 | PR EX GD TY TY EX TY | **20** | **10** |

The committee's Health 20 and Karma 10 are printed once, under the five
rows. Resources and Popularity are under *Columns, labels and ranks*.

**The Omega Sentinel's sixth row prints the letter `U`, not `I`** (printed
11, read on the image), as in MX1: its value, EX (20), is the Intuition
row's. A row letter, not a value; the reader takes the row by position.

**The book checks itself**, each value read on a crop of the page image,
and the codes-only grids and the committee on each code's standard number
(`ranks.json`):

| measure | count |
|---|---|
| Health = F+A+S+E | **16 of 24**: every full card; the grids but the Knights (40, printed 32), Scarlesi (24, printed 20) and Braddock (36, printed 29); none of the committee (18, 28, 50, 34 and 40, printed 20) |
| Karma = R+I+P | **9 of 24**: McGrafton, Nimrod, Lorelei and six grids; not the five sentinels' `Karma = 0` (printed on purpose, below), the Knights (12, printed 14), Scarlesi (40, printed 30), Braddock (46, printed 37), Hernandez (66, printed 56), Atkinson (26, printed 32), nor the committee (22, 36, 18, 44 and 32, printed 10) |
| every number its rank code's standard | **5 of 8 full cards** (the sentinels); not Nimrod's R, nor any of McGrafton's or Lorelei's seven |
| every number within its rank code's range | **7 of 8 full cards**; Nimrod's R 30 is outside EX (16-25) |

**McGrafton's and Lorelei's numbers are inside their codes' ranges and not
the standard**: each of the fourteen is its rank's lowest number (TY 5,
GD 8, EX 16, RM 26, IN 36, AM 46), and both cards' Health and Karma add up
with them. Not misprints (decision 5). **Braddock's grid adds up the same
way**: Health 29 = 8+5+8+8 and Karma 37 = 16+5+16 on each code's lowest
number, which no other grid does; the Knights' Health 32 holds that way too
(four GD 8) and their Karma 14 on no reading (three PR are 12 at most).

**The misprints, each read on the page image** (printed page: name: field
printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 12:Nimrod:R code EX -> RM (30) | Karma 70 = 30+30+10 holds on the numbers; 30 is Remarkable; MA1 (p.81) prints his R 30 Rm |
| 14:Knights of Genetic Purity:Health 32 -> 40 | a codes-only grid: GD+GD+GD+GD = 40 |
| 14:Knights of Genetic Purity:Karma 14 -> 12 | PR+PR+PR = 12; 14 is out of reach of three PR |
| 14:Vincent Scarlesi:Health 20 -> 24 | GD+PR+PR+TY = 10+4+4+6 |
| 14:Vincent Scarlesi:Karma 30 -> 40 | GD+GD+EX = 10+10+20; 30 is below the codes' lowest sum, 32 |
| 15:General William B. Braddock:Health 29 -> 36 | GD+TY+GD+GD = 10+6+10+10; 29 holds on the lowest numbers (decision 4) |
| 15:General William B. Braddock:Karma 37 -> 46 | EX+TY+EX = 20+6+20; 37 holds on the lowest numbers (decision 4) |
| 16:Dr. Paolo Hernandez:Karma 56 -> 66 | RM+RM+TY = 30+30+6; his Health 20 holds; 56 is below the codes' lowest sum, 57 |
| 16:Jay Atkinson:Karma 32 -> 26 | GD+GD+TY = 10+10+6; his Health 22 holds |
| 15:Chuck:Health 20 -> 18, Karma 10 -> 22 | the committee's one Health and Karma (decision 6) |
| 15:Martha:Health 20 -> 28, Karma 10 -> 36 | as above |
| 15:Bob:Health 20 -> 50, Karma 10 -> 18 | as above |
| 15:Phil:Health 20 -> 34, Karma 10 -> 44 | as above |
| 15:Jenny:Health 20 -> 40, Karma 10 -> 32 | as above |

**Printed on purpose:** the five sentinels other than Nimrod print `Karma =
0`, `Resources = 0` and `Popularity = 0` (robots, as in MX1). Their R, I and
P are printed, so Karma = R+I+P cannot hold.

## Entry kinds

1. **A robot type with a code-number card**: the five sentinel marks, a
   header and no identity line.
2. **A named robot**: Nimrod, the same shape, with Karma and Resources.
3. **A named character with a code-number card**: McGrafton (no identity
   line) and Lorelei (her real name under the header).
4. **A type with a codes-only grid**, under a subhead and an introducing
   paragraph: the Typical Policeman, SWAT:AM, Soldiers and Camp Guards, the
   Secret Service Anti-Mutant Teams and the Knights of Genetic Purity (their
   subhead's second line, in brackets, gives two other names for them).
5. **A named character with a codes-only grid**, under a subhead and
   identity lines: Scarlesi, Braddock, Fuchido, Hernandez, Shiver, Atkinson.
6. **A committee table**: five members, one row each, one Health and Karma,
   a run-in paragraph each.
7. **Characters in the prose only**, named and not statted: the history's
   figures (printed 3-8) and the newspaper handouts' (PDF 35).
8. **Gear with ranks**, out of scope by Nate's ruling: the Equipment
   section (printed 17-18: jammers, wild weasels and more) and the types'
   equipment lists (printed 13-14).

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
a `-mx2` id:

- **MX1's Sentinels** (`mark-iv-sentinel-mx1` and the rest): **every MX2
  sentinel prints MX1's numbers and codes**, in the other order (code
  first). The two books differ only in Nimrod's R, I and P codes: MX1
  printed `Ex`, `Gd` and `Gy` and MX2 prints `EX`, `RM` and `GD`, so MX2's I
  and P are right where MX1's were not, and its R is wrong as MX1's was.
  MA1's `Mark IV & V Sentinels`, `Alpha Sentinel`, `Omega Sentinel` and
  `Nimrod` are the same machines; MH1's and MHSP2's `Sentinels` are other
  blocks of them.
- **MX1's `Typical Policeman` and `SWAT:AM`**: MX2 prints the same codes,
  Health and Karma for both.
- **MA1's `Lorelei`** (Brotherhood of Evil Mutants) is another character
  with the same name; MX2's is Laura Lee Masters of this future. The ids
  differ (`lorelei`, `lorelei-mx2`) and the GM list tells them apart by book.
- MH8's `Police` and `SWAT Team Member` are other books' police, with other
  ranks.

Every other name (McGrafton, the Soldiers and Camp Guards, the Secret
Service Anti-Mutant Teams, the Knights of Genetic Purity, the six named
grids, the five committee members) is new to the Codex.

## Quote marks

**No single-quoted phrase of the book's own was found.** The book sets
every double quote as **two single marks** (read on the images of printed
6, 7 and 13), so the OCR reads most doubles as a pair of singles or a
double and a single. Measured on the OCR of PDF 1-34: 31 opening and 45
closing doubles, 59 opening and 214 closing singles (most closing ones
apostrophes), 1 straight single. Of the 53 lines holding a single mark that
is not an apostrophe, every one sampled on the image was half of a double
or the pair itself; the one lone single on a character page (printed 13)
is a plural possessive. So the rule looks like MX1's (every single that is
not an apostrophe is half of a double), and **the data row must confirm it
on the character pages** before relying on it.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with MX1's fields, four
things taught to it and one to `scripts/msh/codegrids.py`'s row reader, and
three more it must learn.** Measured on a trial parse, not argued: a scratch
copy of `scripts/msh/` and `apps/marvel-heroes/data` at `b33ebd72` (`main`'s
scripts at `e7fa7a02` plus this entry), the entry given
`"layout": "grid-booklets"`, run on a copy of the cache under its own
`WORKSHOP_MSH_CACHE`. No page was re-OCR'd; only grid crops were added, to
the copy.

- **Stock, `layout` alone:** `roster.py mx2` stops at
  `one_line_grids: Adventure Book p.14 Health 46 names 2 grids, not 1`,
  exit 1 (reader item 1).
- **Past the first three stops** (reader items 1-3, registry items 1 and 3),
  with none of MX1's fields: it runs to the end and exits 1. 21 entries, 19
  blocks, 6 passing and 13 failing. Every full card's Health and Karma read
  as not a number, because the rows beside them were read into those lines
  (`57 A GD (8) S GD (8)`). No entry had a power, and Lorelei's entry was
  named by her identity line.
- **With the registry workarounds and reader items 1-4:** it runs to the end.
  It exits 0 until the committee's five names join the checklist, then
  exits 1 on those five (reader item 6).

| measure | trial, last run |
|---|---|
| entries | 26: 19 with a block, 7 without (the chapter's heading, The Sentinels, Notes on Sentinels, Non-Player Characters, The Mutant Affairs Committee, the committee's table read as one entry, Equipment) |
| stat blocks | 19 of 24, every value as *Stat blocks* lists it; the committee's 5 unread |
| blocks passing every check | 8, and 11 known from trial overrides (5 `as_printed`, 6 `misprint`): the survey's, each matching one block; failing 0 |
| powers | 61 across 8 entries (the eight full cards) |
| checklist | 16 `tiers` and 8 `cards`; Chuck, Martha, Bob, Phil and Jenny `CHECKLIST NAME WITH NO ENTRY` |
| exit code | 1 (0 with the five left out of `tiers`) |

The trial overrides are the survey's (decision 4: Nimrod's R, the Knights,
Scarlesi, Braddock, Hernandez and Atkinson; the five sentinels' `Karma = 0`).
They were written for the trial only and not re-read on the images; the data
row writes the real file.

**Registry-only workarounds** (no reader change; each worked in the trial):

1. **`opponents` is required.** `gridbooks.parse` stops on a `KeyError`
   for a book with none. The trial set `opponents: []`; reader item 5 makes
   it optional.
2. **MX1's fields**, as MX1's entry sets them: `code_rows` (the full cards'
   code-first rows), `card_headers` (Lorelei over her identity line),
   `title_case_labels`, `letters_marks`, `not_run_ins` `SWAT:AM` (five prose
   lines start with it) and `teams` (the book's title, decision 1). Set
   together, they took the powers from 0 to 58 and every card's Health and
   Karma to a number. The trial did not set `column_left_quantile`,
   `art_boxes` or `bullet_marks`. Whether the data row needs them is for its
   reading of the text.
3. **Fuchido's letters row** (printed 16) reads `F A S`, a section sign
   (U+00A7), then `ER | P`, with E and R welded, which `LETTERS_MARKS` does
   not match, so
   `one_line_grids not found: Dr. Yagami Fuchido`. A `speck_lines` entry
   reads it as `F A S E R I P`. The other ten letters rows match as read.
4. **Six `extra_titles`**: Villains and The Sentinels (printed 10), Notes on
   Sentinels and Non-Player Characters (13), The Mutant Affairs Committee
   (15) and Equipment (17). Without them McGrafton's Background ran on
   through the sentinels' introduction (2,564 characters, 332 with them), and
   Atkinson's through the Equipment section (4,164, then 612).
5. **The Mutant Affairs Committee's subhead is set on two lines**
   (`The Mutant Affairs` / `Committee`), and an `extra_titles` entry matches
   one line, so ME3's `two_line_headers` joins them first.
6. **Lorelei's powers** (printed 15): each is one line ending in no full
   stop, so the three after Flight read as Flight's text (1 power). ME3's
   `power_heads` marks Pheromones, Blending and Phasing, which gives 4.
7. **`rank_ranges`** (decision 5): McGrafton's and Lorelei's fourteen
   numbers pass on their ranks' ranges.
8. **The misprints and the robots' `Karma = 0`**: overrides, as above.

Braddock's subhead needs nothing: the registry's first line without its
comma matches the printed line, because `roster.norm` drops the comma.

**What the reader must learn: seven things.** The first four were applied in
the trial (`gridbooks.py` 12 lines, `codegrids.py` 4); the last three were
not:

1. **Health and Karma tie a codes-only grid to its name** (printed 14: two
   grids print 46; printed 16: two print 20). `line_grids` ties by `health`
   alone and stops. The trial also matches the registry's `karma` where an
   entry records one. No earlier book's `one_line_grids` records a `karma`,
   so none can move.
2. **A subhead on the page before its grid** (SWAT:AM: subhead printed 13,
   grid 14). `line_grids` looks on the grid's page only. The trial reads a
   grid's `subhead_page` from the registry, set on SWAT:AM's grid.
3. **A subhead and a prose line with the same words** (printed 14: the
   Secret Service's subhead, and a line of the paragraph under it holding
   the same four words in lower case). `roster.norm` makes them equal, so
   `subhead ... is on 2 lines`. Where two lines match, the trial keeps the
   one whose text is the subhead as written. This was a stop before, so no
   earlier build reaches it.
4. **A code-first card's Resources set on the line under its label**
   (Nimrod, printed 12: `R EX (30) Resources =`, then `IN (40)` in the right
   half of the column). `codegrids.rows_from` read `IN (40)` as the I row,
   which moved I and P down a row and made P his Resources. The trial
   refuses a row with no letter right after a row whose text ends in
   `Resources =` or `Resources:`. `codegrids.py` is MA4's reader too, so the
   parser row puts this behind a registry field and proves MA4, MX1 and MT3
   unmoved. McGrafton's wrapped `MN` / `(75)` and Lorelei's `TY` read right
   unchanged.
5. **`opponents` optional** (registry item 1).
6. **The committee table** (printed 15, decision 6), a shape no reader has.
   Not applied. The page stream drops the letters row's I and P and all of
   Chuck's codes, and welds code pairs (`GDTY`). So `mark_headers` takes
   Phil's row for a header. Its entry holds Jenny's row and the shared
   Health and Karma as identity lines, then all five run-in paragraphs as
   prose (2,103 characters). The letters row, Chuck's name and Martha's and
   Bob's rows land in the prose under The Mutant Affairs Committee. A `--psm 6` crop of the column
   from the letters row to `Karma: 10` reads every row (kept in the plan
   store). Only Chuck's and Jenny's `GDTY` stay welded, and each splits into
   two codes. What the reader needs: a registry field naming the table
   (part, page, the five names, the shared Health and Karma as printed); the
   rows read from that crop, with a welded pair split; one entry per member,
   from its row and its run-in `Name:` paragraph to the next member's run-in,
   with Braddock's subhead ending Jenny's; Health and Karma at the codes'
   standard sums, with the printed 20 and 10 kept in an override.
7. **A codes-only grid's Resources and Popularity** (Scarlesi, printed 14:
   `Resources: IN`, `Popularity: 20` under his Karma line). `read_line_grid`
   reads Health and Karma only, so both lines land in his prose and the
   block has none. Not applied.

Read and fine as it is: the full cards' `Health =` with the code first,
`Shift X (150)` included, through `code_rows`. So are the Omega's `U` row,
taken by position, and the text that runs past a page (the Omega's powers to
12, Scarlesi's to 15, Braddock's to 16, Atkinson's to 17) or past a column
(Lorelei). Not reader matters, for the data row:

- Lorelei's Popularity reads with an em dash (U+2014) for its minus, then
  30, and `npcs.py` must read it as -30.
- Each type's `Equipment:` list is a run-in that is no section, so it lands
  in the entry's notes (gear, decision 8).
- The Soldiers' talents run on into their equipment and duties (545
  characters), MX1's `talents_end` shape.
- Braddock's second subhead line `U.S. Army` lands in his prose
  (decision 3).
- Shiver's Background ends in a speck (`j`).

The other readers fit less, as MX1's survey found: `codegrids.py` (MA4)
reads one offset and not booklet `parts`; `roster.py` (MA1) reads only
number-first rows; `booklet.py`, `rosterbook.py` and `coverpanels.py` read
rank words. The entry still sets no `layout`: that is the parser row's to
write, with items 1-7 behind the registry and every earlier book's build
proved byte-identical. The plan store's `trial\mx2\` keeps the scratch
registry patch, the trial overrides and both reader diffs (CRs stripped). It
also keeps the committee crop's lines, the output of every stop and the last
run's output.

## Decisions this survey leaves open

Each has a recommendation, the one MX1 and MT3 took where they had the same
question (Nate 2026-10-31: take the survey's recommendations).

1. **Teams.** The book has no team sections. Recommendation: every card
   under the book's title, **MX2 The X-Potential**, as MX1 filed its
   sentinels and NPCs; the six sentinels each a card of their own, as each
   prints its own header. Not written to the registry until decided.
2. **Page citations.** Recommendation: MX1's single-booklet shape,
   `MX2 Adventure p.15` (the part's `cite` is `Adventure`).
3. **Names.** Recommendation: each header or subhead as printed, titles
   kept (**Senator Joseph McGrafton**, **Dr. Yagami Fuchido**, **Dr. Paolo
   Hernandez**), as MX1 kept its headers; **General William B. Braddock**,
   his subhead's first line without its comma, `U.S. Army` going to the
   identity line with his post; **Knights of Genetic Purity**, its bracketed
   line an identity line. Each type an entry of its own, as MX1's.
4. **The misprints.** Recommendation: overrides keeping printed and
   corrected, as listed under *Stat blocks*: Nimrod's R code (as MA1 prints
   it), and each codes-only grid's Health or Karma that its codes do not
   add up to, corrected to the standard sum with its codes kept, as MX1's
   Typical Rogue. Braddock's two included: that both hold on each code's
   lowest number goes in the override's reason, as the reading not taken
   (it would make a codes-only grid print numbers it does not). The five
   sentinels' `Karma = 0` kept `as_printed` (robots), as MX1's. The Omega's
   `U` row letter is a reading matter for the parser, not an override.
5. **McGrafton's and Lorelei's numbers**, fourteen inside a rank's range and
   not its standard, every Health and Karma adding up with them.
   Recommendation: `rank_ranges` for this book, as ME2 took for twenty-seven
   values and ME3 for one, rather than fourteen `also` entries (MX1's choice
   for a single value).
6. **The Mutant Affairs Committee.** Recommendation: five cards, **Chuck**,
   **Martha**, **Bob**, **Phil** and **Jenny**, each with its own row of
   codes and its run-in paragraph, Health and Karma at the standard sums of
   its codes, and the printed shared 20 and 10 kept as printed in an
   override on each (no member's codes add up to them). The alternative not
   recommended: one card, The Mutant Affairs Committee, with five blocks.
7. **Lorelei's Resources `TY` with no number.** Recommendation: kept as
   printed, the card showing the code alone, as MX1's Oliver Pierce.
8. **Characters only.** The Equipment section, the types' gear, the
   handouts and the places are not imported (Nate, 2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mx2 --probe
python scripts/msh/ocr-book.py mx2
python scripts/msh/survey.py mx2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 30-150
dpi into the scratchpad, never into the repo.
