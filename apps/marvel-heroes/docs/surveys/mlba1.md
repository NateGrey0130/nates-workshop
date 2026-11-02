# Survey: MLBA1 Mutating Mutants (TSR6893)

Official Advanced Game Adventure for Marvel Super Heroes (the cover and the
title page), Bruce Nesmith, 1990; the first MLBA module (the cover prints
MLBA1 over 6893).
Registry entry: `scripts/msh/books.json` -> `mlba1`. Measured 2026-11-01.

**Rows citing this book:** 90 `msh_book_text` rows over 23 character entries
in production (`DB_MARVEL`, read back 2026-11-01).

Everything here was measured and read on the page images.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 38 PDF pages, a pure scan (`ocr-book.py --probe`: a median of 0
  text-layer characters over 20 samples; PyMuPDF reads 0 on every page),
  cached 2026-11-01 into the main checkout's `.cache/msh/books/mlba1/`
  (`manifest.json`: 300 dpi, `--psm 3`, Tesseract 5.4.0, 38 pages OCR'd, 0
  already cached).
- **One 32-page booklet**, its two outside covers, three larger prints of
  the booklet's maps and one floor plan. The print is clean; the grids, the
  headers and the run-in labels OCR well, the banners (white on a grey band)
  mostly do not.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 592 x 784 | Cover (outside front; prints MLBA1 and 6893) | - |
| 2-33 | 594 x 767 | Adventure Book | 1-32 |
| 34 | 592 x 784 | Back cover (code 6893XXX1401, ISBN 0-88038-841-2) | - |
| 35 | 1188 x 1535 | Maps: I. Shaw Industries and IV. Jeenex Grounds | - |
| 36 | 1188 x 1535 | Map: II. Castle Plastics | - |
| 37 | 1188 x 1535 | Map: III. Bulk Rifle Corporation | - |
| 38 | 1191 x 773 | Map: V. Jeenex Building (a floor plan) | - |

PDF 35-37 are larger prints of the maps the booklet prints on PDF 10, 14,
20 and 25; PDF 38's floor plan is in the booklet nowhere. None prints a
statistic, and none is imported.

**Pages that are not body text** (each read on the image): PDF 6 (printed
5) half a page of art and the Karma Awards table; PDF 10 (printed 9) the
lower half, the Shaw Industries map; PDF 12 (printed 11) three company-list
handouts; PDF 14 (printed 13) the full-page Castle Plastics map; PDF 20
(printed 19) the full-page Bulk Rifle Corporation map; PDF 25 (printed 24)
the Jeenex Grounds map; art on PDF 4, 7, 16, 17, 23, 29 and 32.

## Offset

`survey.py` votes **printed = PDF - 1 on 18 pages** (PDF 11-32 but 14, 20,
23 and 30). The rest, each read on the page image:

- PDF 3-10, 23 and 30: their folios (2-9, 22 and 29) are at the foot,
  missed by Tesseract. PDF 30's one vote (k = -209) is its folio misread.
- PDF 2 (printed 1): the title and Contents page, no folio. The Contents'
  first entry is printed 2, and PDF 3 opens it.
- PDF 14 and 20 (printed 13 and 19): full-page maps, no folio.
- PDF 33 (printed 32): the Player Character Cards, no folio (the foot
  prints three copyright lines, one per card column). Printed 32 by
  position and by the Contents.

So `parts`, as MX1's and MX4's single booklet, with the covers and each
map page as parts of their own.

## The book's own authority lists

**A Contents** on printed 1 (PDF 2), in two columns, transcribed from the
page image (the OCR mangles the dot leaders and the roman numerals) and
stored as `sections`. Every entry was read on its page:

| printed | Contents | on the page |
|---|---|---|
| 2 | Introduction | banner INTRODUCTION |
| 4 | I. Hot Time in the Old Town Tonight | banner, same words |
| 6 | II. It's One of Those Nights | banner, same words |
| 8 | III. Arms and Armor | banner, same words |
| 12 | IV. Fight Like Cats and Dogs | banner, same words |
| 17 | V. Mutants, Just Say No! | banner, same words |
| 23 | VI. Mountain and the Mole Hill | banner, same words |
| 26 | VII. King's Pawn | banner, same words, **mid-page**, under Goliath's text |
| 32 | Player Character Cards | no heading: the six cards fill the lower half of the page |

**Every page agrees**, so there is no `contents_errata`. The banners of
printed 2-23 are at the top of their pages. One heading has no Contents
line: **VIII. Conclusion** (printed 32, column 2), a bold title-case
subhead, not a banner, between the villain doubles' prose and the cards.

**No index**, no rank chart. The coverage checklist is this survey's list,
carried as `cards` and `opponents` (*Stat blocks*).

## Columns, labels and ranks

- **Three columns** on every booklet page read; a block's rows and its
  labels are two sub-columns of one column. Two grids break across columns:
  Mauler's F and A at the foot of column 1 of printed 9, his S-P at the top
  of column 2; Mad-Dog's seven rows at the foot of column 1 of printed 12,
  his Health to Popularity at the top of column 2. The cards' half of
  printed 32 is three boxes across, two deep.
- **Four grid shapes in one book** (read on the page images of every grid
  page at 70-220 dpi):
  - **(a) The nine villains**: a bold title-case header, then seven rows
    that print the **ability's whole name**, the code in capitals and its
    number in brackets (`Fighting RM (30)`), then `Health:`, `Karma:`,
    `Resources:` and `Popularity:` as **four lines under the grid**, not
    beside its rows. Resources is a code and its number in brackets. New to
    every reader.
  - **(b) The five minor grids** (printed 4 and 6): a bold header, a column
    of row letters with the code and its number in brackets (`GD (10)`),
    `Health:` beside row E and `Karma:` beside row P. No Resources or
    Popularity, and no text label under the grid.
  - **(c) The three animals** (printed 31): a bold room key
    (`R1. Chimpanzee`), a paragraph, then a row of the seven letters, a row
    of seven **title-case codes and no numbers**, and `Health:` on a line of
    its own. **No Karma.**
  - **(d) The six Player Character Cards** (printed 32): a bold header, a
    bold real-name line (none on Rusty Collins's), a column of row letters
    with the code in capitals and its number **with no brackets**
    (`GD 10`), `Health:` beside F, `Karma:` beside S, `Resources:` beside R
    (a code and its number in brackets) and `Popularity:` beside P.
    Sunspot's Health prints `52(76)`.
- **Section labels**, counted on the OCR of every booklet page and read on
  the images. The villains: `Background` (9) and `Known Powers` (9), bold
  title-case headings on lines of their own **with no colon**, Background
  first; under it the identity run-ins (`Real Name:`, `Occupation:`,
  `Identity:`, `Legal Status:`, `Other Known Aliases:`, `Place of Birth:`,
  or `Place of Construction:` for the Sentinel, `Marital Status:`,
  `Known Relatives:`, `Base of Operations:`, `Group Affiliation:`, and
  `Present Group Affiliation:` on five); each power an italic run-in under
  Known Powers; `Talents:` a bold run-in on three (Mauler, printed 10;
  Mad-Dog, 12; Sabretooth, 14, on a line of its own). The cards:
  `Summarized Powers:` (6) and `Talents:` (4) bold run-ins, and Sunspot's
  `Weakness:` an italic run-in among his powers. No `Contacts:` anywhere.
- **Ranks**: capitals in shapes (a), (b) and (d): FE (Resources only), PR,
  TY, GD, EX, RM, IN, AM and MN; title case in the animals' rows: Fe, Pr,
  Ty, Gd, Ex and Am. No UN, no Shift rank and no misspelt code in a grid.
  In `rank_aliases`. `NA` is not a rank: the Sentinel, Mark IV prints it
  for Karma, Resources and Popularity.
- **`survey.py` finds 0 blocks**: its block rule wants `Health =` with an
  equals sign, and this book prints `Health:` everywhere. Its offset vote
  is this book's; its block count is not.

## Where the blocks are

**Only the cards have a page of their own.** Printed 32's lower half holds
the six Player Character Cards, stored as one `character_ranges`, printed
32; the upper half of the same page is adventure prose (the villain doubles
and VIII. Conclusion).

**Every other grid sits inside a chapter's prose** (the Black King inside
the Introduction), introduced by the text where the heroes meet it, so
each is an opponent, stored in `opponents` by page:

| printed | chapter | grids | text runs on to |
|---|---|---|---|
| 3 | Introduction | Black King | - |
| 4 | I | Generic Punk, Schiz, Ee-ha, Rocco | - |
| 6 | II | Generic Goon | - |
| 8 | III | Beetle | printed 9, top of column 1 |
| 9 | III | Mauler | printed 10 (Talents) |
| 12 | IV | Mad-Dog, Sabretooth | printed 14 (Sabretooth's last powers and Talents), past the map of printed 13 |
| 18 | V | Sentinel, Mark IV | - |
| 25 | VI | Armadillo, Goliath | printed 26 (Goliath's Background and powers) |
| 29 | VI | Ramhorn (under the room key L. Ramhorn) | - |
| 31 | VI | Chimpanzee, Giant Dalmatian, Chicken (one-line grids) | - |

The Health and Karma the OCR finds anywhere else are prose (the Black
King's power, printed 3; a sentence of printed 22; the Karma Awards and
other Karma rules, printed 4-16 and 25-29),
not grids; no page but these holds a rank row. Not one page outside the
booklet holds a Health, Karma or rank row.

## Stat blocks: 23

| printed (PDF) | name | shape | F A S E R I P as printed | Health | Karma | Resources | Popularity |
|---|---|---|---|---|---|---|---|
| 3 (4) | Black King | a | RM 30, GD 10, GD 10, AM 50, EX 20, EX 20, RM 30 | 100 | 70 | IN (40) | 15 |
| 4 (5) | Generic Punk | b | GD 10, TY 6, TY 6, GD 10, PR 4, TY 6, PR 4 | 32 | **4** | - | - |
| 4 (5) | Schiz | b | GD 10, GD 10, TY 6, GD 10, PR **6**, TY **4**, PR 4 | 36 | **6** | - | - |
| 4 (5) | Ee-ha | b | EX 20, GD 10, TY 6, GD 10, PR **6**, TY 6, PR 4 | 46 | **6** | - | - |
| 4 (5) | Rocco | b | GD 10, PR 4, EX 20, GD 10, PR 4, TY 6, PR 4 | 44 | **4** | - | - |
| 6 (7) | Generic Goon | b | TY 6, GD 10, TY 6, GD 10, PR 4, TY 6, PR 4 | 32 | **10** | - | - |
| 8 (9) | Beetle | a | GD 10, GD 10, RM 30, EX 20, EX 20, RM 30, TY 6 | 70 | 56 | EX (20) | -10 |
| 9 (10) | Mauler | a | IN 40, EX 20, IN 40, IN 40, GD 10, EX 20, TY 6 | 140 | 36 | GD (10) | 0 |
| 12 (13) | Mad-Dog | a | RM 30, IN 40, RM 30, IN 40, GD 10, EX 20, TY 6 | 140 | 36 | TY (6) | -10 |
| 12 (13) | Sabretooth | a | IN 40, IN 40, EX 20, RM 30, TY 6, GD 10, RM 30 | 130 | 46 | TY (6) | -5 |
| 18 (19) | Sentinel, Mark IV | a | EX 20, EX 20, AM 50, MN 75, TY 6, TY 6, PR 4 | 165 | NA | NA | NA |
| 25 (26) | Armadillo | a | EX 20, GD 10, IN 40, RM 30, TY 6, TY 6, TY 6 | 100 | 18 | GD (10) | -10 |
| 25 (26) | Goliath | a | EX 20, GD 10, IN 40, MN 75, TY 6, PR 4, PR 4 | 145 | 14 | GD (10) | -10 |
| 29 (30) | Ramhorn | a | EX 20, EX 20, IN 40, IN 40, PR 4, TY 6, PR 4 | 120 | 14 | PR (4) | 0 |
| 31 (32) | Chimpanzee | c | Ty Ty Gd Am Fe Ty Pr | 72 | - | - | - |
| 31 (32) | Giant Dalmatian | c | Gd Ty Gd Ex Fe Gd Fe | 46 | - | - | - |
| 31 (32) | Chicken | c | Ty Ex Fe Gd Fe Fe Fe | 38 | - | - | - |
| 32 (33) | Cannonball (Sam Guthrie) | d | GD 10, **TY 6**, GD 10, RM 30, TY 6, TY 6, GD 10 | **54** | 22 | PR (4) | 4 |
| 32 (33) | Boom-Boom (Tabitha) | d | PR 4, TY 6, PR 4, EX 20, PR 4, TY 6, TY 6 | 34 | 16 | PR (4) | 0 |
| 32 (33) | Rusty (Russell) Collins | d | TY 6, TY 6, TY 6, GD 10, TY 6, TY 6, GD 10 | 28 | 22 | FE (2) | -3 |
| 32 (33) | Wolverine (Logan) | d | IN 40, RM 30, GD 10, RM 30, TY 6, MN 75, IN 40 | 110 | 121 | TY (6) | 0 |
| 32 (33) | Richtor | d | TY 6, TY 6, TY 6, EX 20, TY 6, GD 10, GD 10 | 38 | 26 | FE (2) | -5 |
| 32 (33) | Sunspot (Roberto Da Costa) | d | GD 10, TY 6, TY 6, RM 30, TY 6, PR 4, GD 10 | 52(76) | 20 | EX (20) | 3 |

Shapes (a) and (b) print `CODE (n)`, shape (d) `CODE n`; the table writes
each as code and number. The animals' codes-only grids print no numbers.

**The book checks itself**, each value read on a crop of the page image
(the cards at 130-220 dpi, the rest at 70-150), codes-only grids on each
code's standard number (`ranks.json`):

| measure | count |
|---|---|
| Health = F+A+S+E | **22 of 23**; Cannonball's fails (56, printed 54). Sunspot's 52 holds, and his 76 holds on his S at RM 30 (his power, Strength) |
| Karma = R+I+P | **14 of 19** printed as numbers (the 8 numeric villains and the 6 cards); **none of the 5 minor grids** (Generic Punk 14, printed 4; Schiz 14 on his codes, 14 on his numbers, printed 6; Ee-ha 14 on the codes, 16 on the numbers, printed 6; Rocco 14, printed 4; Generic Goon 14, printed 10). The Sentinel prints NA; the 3 animals print no Karma |
| every number its rank code's standard | **21 of 23**; Schiz and Ee-ha are not |
| every number within its rank code's range | **the same 21**: Schiz's R 6 is outside Poor (3-4), his I 4 outside Typical (5-7), Ee-ha's R 6 outside Poor. No number in the book is inside its code's range and not its standard |

**The misprints, each read on the page image** (printed page: name: field
printed -> corrected):

| misprint | the book's own arithmetic |
|---|---|
| 4:Schiz:R PR (6) -> PR (4) | 6 is not Poor; the other three punks and the goon print R PR (4) |
| 4:Schiz:I TY (4) -> TY (6) | 4 is not Typical; the other four minor grids print I TY (6). The two numbers are swapped |
| 4:Ee-ha:R PR (6) -> PR (4) | 6 is not Poor; as Schiz's R |
| 4:Generic Punk:Karma 4 -> 14 | R+I+P = 4+6+4 |
| 4:Schiz:Karma 6 -> 14 | R+I+P = 4+6+4 once his R and I are corrected (and 14 on his printed numbers too) |
| 4:Ee-ha:Karma 6 -> 14 | R+I+P = 4+6+4 once his R is corrected |
| 4:Rocco:Karma 4 -> 14 | R+I+P = 4+6+4 |
| 6:Generic Goon:Karma 10 -> 14 | R+I+P = 4+6+4 |
| 32:Cannonball:A TY 6 -> PR 4 | Health 54 = 10+4+10+30 holds with Poor; MA1 and MHSP2 print his A Pr 4 and Health 54, every other row as here |

Schiz's two rows resolve by the codes because no Karma can arbitrate them
(his printed Karma 6 holds on no reading) and the codes give the R PR (4),
I TY (6), P PR (4) that the other four minor grids print. Cannonball's
resolves by the row, not the Health, because two other books print the same
card with A Pr 4 (decision 4).

**Printed on purpose:** the Sentinel, Mark IV prints `Karma: NA`,
`Resources: NA` and `Popularity: NA` (a robot, as MLA1's Sentinels, Mark IV
print theirs; MX1-MX4 print 0 for the same machine). Its R, I and P are
printed, so Karma = R+I+P cannot hold.

## Entry kinds

1. **A named villain with a full block**: the Black King, Beetle, Mauler,
   Mad-Dog, Sabretooth, Armadillo, Goliath and Ramhorn, each introduced in a
   chapter's prose and statted there, with Background and Known Powers.
2. **A robot type with a full block**: the Sentinel, Mark IV.
3. **A named minor character with a short grid**: Schiz, Ee-ha and Rocco
   (printed 4), each with a paragraph of prose under the grid.
4. **A type with a short grid**: Generic Punk (the ten others of the gang,
   printed 4) and Generic Goon (four goons, printed 6).
5. **An animal with a codes-only grid**: the three of printed 31, each under
   a room key, with its powers as italic run-ins under the grid.
6. **A Player Character Card**: the six of printed 32 (Wolverine and five
   New Mutants and friends).
7. **Characters in the prose only**, named and not statted: Dr. Karl Malus,
   the minor staff of each location, and the six villain doubles of printed
   31-32 (each hero's hallucinated counterpart, named in a run-in such as
   Boom-Boom/Hobgoblin; the text gives them no statistics).
8. **Gear and places with ranks**, out of scope by Nate's ruling: the X-Gene
   ray gun and its numbered effect and mutation tables (printed 6 to 26), the locations' rooms and walls, the maps and the handouts.

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
an `-mlba1` id. Read against `npcs.json` 2026-11-01:

- **The same block as another book's card**: MA1's `Black King`, `Wolverine`
  and `Sunspot` (Health 52 (76)), MT3's `Beetle`, MH5's `Mauler`, and MA1's
  Mark IV block of `Mark IV & V Sentinels` and MLA1's `Sentinels, Mark IV`
  (P 4 Pr, where MX1-MX4's Mark IV prints 6 Ty): every row, Health and Karma
  as here.
- **The same character, another block**: MA1's `Cannonball` and MHSP2's
  `Cannonball` print this card's rows but A (Pr 4 there; the misprint here);
  MA1's `Collins, Rusty` prints E Ty 6 and Health 24, where MLBA1 prints E
  GD 10 and Health 28, and both hold. MX4's `Cannonball` and `Sunspot` are
  that book's older future selves, other blocks.
- **Other characters of the same kind**: MH8's `Punks`, MA1's and MX1-MX4's
  other sentinel marks.

Every other name (Mad-Dog, Sabretooth, Armadillo, Goliath, Ramhorn,
Boom-Boom, Richtor, Generic Punk, Schiz, Ee-ha, Rocco, Generic Goon, the
three animals) is new to the Codex.

## Quote marks

**No single-quoted phrase of the book's own was found.** Measured on the OCR
of all 38 pages: 31 opening and 32 closing curly doubles, 1 straight double,
20 opening singles, 105 closing singles (109 marks inside a word, mostly
apostrophes) and 21 straight singles. Of the 33 lines holding a single mark
that is not inside a word: every opening single read on the image is half
of a double read as two marks (printed 2, five places; printed 4, two),
or the elision of a clipped word (printed 2, and the back cover); the
closing singles after a word are plural possessives (read on the images of
printed 4, 8 and 25; the OCR words of printed 16, 21 and 23 are the same
shape and were not read on the image), and printed 5 prints a height in
feet and inches; the rest are specks in the maps' lettering (PDF 10, 14, 20 and
35-38) and in art. So the rule looks like MX1's and MX4's (every single that
is not an apostrophe or an elision is half of a double, and Tesseract reads
an opening double as a single: trust the image), and **the data row must
confirm it on the character pages** before relying on it.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with things taught to
it.** Measured 2026-11-01 (plan rows 13c and 13c1): a scratch copy of
`scripts/msh/` and `apps/marvel-heroes/data` at `main`'s `8676101c`, this
branch's `scripts/msh/books.json` (`0ec45561`), the mlba1 entry given
`"layout": "grid-booklets"` and the fields `main`'s `gridbooks.py` already
reads for earlier books, set for this one: `code_rows`, `card_headers`,
`title_case_labels`, trial `teams` (decision 1), `cards` (the six card
headers, decision 3's `Rusty Collins`), `subhead_labels` (MT3's),
`lost_letters` (MT2's), `derived_totals` (MT3's),
`code_rows_end_at_popularity` (MX3's), `code_grids_by_pitch` (MLA1's),
`opponent_indented_paragraphs` (MT2's) and `entry_ends` (MT3's); a trial
`mlba1-overrides.json`; and the reader changes below in a scratch module,
run on a copy of the cache under its own `WORKSHOP_MSH_CACHE` (no page
re-OCR'd). Ten runs, 0 to 9. No other reader was tried: `codegrids.py`
reads one `offset` and no `parts` (MT3's code-grids stop), and the
rank-word readers do not read numbers.

**The stock grid-booklets stops at the animals.** With `layout` alone, and
again with MX1's `code_rows`, `card_headers`, `title_case_labels` and
`teams`, `roster.py mlba1` exits 1 on `one_line_grids not found:
Chimpanzee, Giant Dalmatian, Chicken` (printed 31: the letters row is lost
from the stream). `lost_letters` and `derived_totals` take it past the stop.

| measure | stock (runs 0, 1) | past the stop (run 2) | with every trial change (run 9) |
|---|---|---|---|
| entries | none (stops) | 23 | 24: 23 with a block, 1 without (the Player Character Cards heading) |
| stat blocks | none | 16 | 23 of 23 |
| blocks passing every check | none | 3 | 15, and 8 known from the overrides (6 `misprint`, 2 `as_printed`) |
| failing | none | 13 | 0 |
| checklist names with no entry | not reached | 17 (every opponent but the animals, and three cards) | 0 (17 opponents, 6 cards, all found) |
| powers | not reached | 14 across 4 entries | 50 across 14 entries |
| exit code | 1 | 1 | 0 |

At run 2 the ten shape (a) blocks were entries named by their Psyche row
(`Psyche RM (30)`, on no checklist) and four cards' Health and Karma ran on
into the next rows. Read off run 9's `roster.json` by row 13c2: **every
block's rows, Health and printed Karma are the *Stat blocks* table's**;
Beetle's S reads `80` and is stored RM 30 (`read_as` keeps the 80). The 15 passing are the eight villains with no
override, Wolverine, Boom-Boom, Rusty Collins, Richtor and the three animals
(Karma derived and marked `derived`).

**The overrides** are 8 entries, each matching one block: decision 4's
nine misprints (Generic Punk's, Rocco's and Generic Goon's Karma; Schiz's R
with his I and Karma in its `also`; Ee-ha's R with his Karma; Cannonball's
A), the Sentinel, Mark IV's Karma `NA` `as_printed`, and Sunspot's Health
`52(76)` `as_printed`. They were written from the survey's tables and not
re-read on the images, except Sunspot's (printed 32); the data row writes
the real file. Sunspot's `as_printed` is the trial's: decision 6 reads the
value before the bracket, which no reader does yet (coverpanels'
`health_note` keeps such a bracket); without it run 5 exits 1, `HEALTH IS
NOT A NUMBER`.

**Registry-only workarounds** (no reader change; each worked in the trial):

1. **The animals' grids** (printed 31): `lost_letters` for the lost letters
   row and `derived_totals` for the Karma they do not print (decision 5).
2. **`code_rows_end_at_popularity`** and **`code_grids_by_pitch`** for the
   cards' code-first rows (printed 32).
3. **Beetle's opponent** reads printed 9 by `runs_on: [9]`, not
   `continues` (printed 9 is Mauler's opponents page too).
4. **`cards` names `Rusty Collins`**; the header reads `Rusty (Russell)
   Collins` and the roster entry keeps that header, so the card's name is
   the data row's to set (decision 3; not measured past the roster).
5. **The overrides**, above.
6. **`opponent_indented_paragraphs` for Mad-Dog alone** (printed 12): an
   indented paragraph inside his Known Powers ended his entry (1 power;
   with it, 4 and his Talents). Set for all nine statted opponents (run 7),
   every one swallows the adventure after it (Mauler's Talents 3,986
   characters, the Sentinel's last power 2,250, Ramhorn's 2,203). Rejected.
7. **`entry_ends`** on printed 14 (an unindented line after Sabretooth's
   last power, Tumbling, with no full stop between them) and printed 29 (the
   room key `M. Isolation Chambers` after Ramhorn).

**What the reader must learn: 13 things**, 1-9 written in the trial
(`trial_mends.py`, 162 lines, each change named by a `trial_` field in the
trial's registry patch, and 9 lines of `gridbooks.py`) and run green, 10-13
not written:

1. **Shape (a)'s full-word rows** (`Fighting RM (30)`) with Health, Karma,
   Resources and Popularity as four lines under the grid (printed 3, 8, 9,
   12, 18, 25, 29).
2. **That grid split across columns with map lettering between** (Mauler,
   printed 9: the trial skips two lines of the Shaw Industries map read
   among his rows).
3. **Shape (b)'s low grids**: Health beside E, Karma beside P, the letters
   read sideways in the stream, so the rows come from a `--psm 6` crop
   (printed 4, 6). The trial names the five grids in a field of their own.
4. **A code welded to its number** (`TY6`, `GD10`; the cards, printed 32,
   and printed 4, 6).
5. **`Health;` and `Karma;` read with semicolons** (printed 32).
6. **Card portraits read beside the rows and totals** in the crop
   (Wolverine, Rusty Collins and Sunspot, printed 32).
7. **A 1 read as i in a row's number** (Richtor's P `GD i0`, printed 32;
   MT3's item 1 is the same misread in a code).
8. **A minus read as U+FFFD, a dash or a spaced hyphen in Popularity**
   (printed 12, 25).
9. **Title-case subheads with no colon** (Background, Known Powers) raised
   to capitals after `subhead_labels` adds the colon, so `roster.RUN_IN`
   and `SECTION` read them (every villain): MT3's item 10 needed a
   `speck_lines` entry for Kang alone; here it is all nine.
10. **A page-wide chapter banner cuts the columns into bands**, and the
    stream reads each column top to bottom across it. Printed 26: the
    banner VII. King's Pawn ends Goliath's Background at the foot of
    column 1's upper band, and his Known Powers, at the top of column 2,
    never join him: **Goliath has 0 powers**. Printed 32: the Conclusion's
    upper band runs into Richtor's last power and Wolverine's Talents.
    Cause read off the stream and the render. No registry field orders
    bands. Not written.
11. **Card power lines end with no full stop**, so a power head is found
    only after a line that ends a sentence: Wolverine has 2 of 6 powers
    (Resistance, Claws and Adamantium Skeleton welded into Regeneration,
    Invisibility into Tracking), Richtor 2 of 3 (his lower-case `Vibration
    touch:` is no head) (printed 32). Read off the stream, not traced in
    the code. Not written.
12. **The card's copyright footer** (OCR `TSA`, `TER`, `79990`) is read into
    each card's last section: Cannonball's, Boom-Boom's and Rusty
    Collins's (printed 32). Not written.
13. **`Talents;` with a semicolon is no label** (item 5 covers Health and
    Karma only): Boom-Boom's Talents weld into Energy Bombs (printed 32).
    Not written.

**`roster.py` exits 0 with items 10-13 misread**: it gates the numbers and
the checklists, not the prose. The Player Character Cards heading entry
(no block) also carries adventure text as its identity and prose. Two more
were read off run 9's `roster.json` by row 13c2 and are on no list above.
**Cause not found** for either; nothing was tried beyond reading that
file (the trial was not re-run):

- **Rocco has no prose** (printed 4), where Schiz, Ee-ha and the two
  generic grids have theirs; whether his paragraph went to another entry
  was not measured.
- **The three animals have 0 powers** (printed 31), where *Entry kinds*
  reads italic power run-ins under each grid; each entry holds 405 to 857
  characters of prose, and whether the run-ins are in it was not read.

**Failing blocks with cause not found: none.**

**So grid-booklets must learn 13 things, 9 written and 4 not, beside 7
registry-only workarounds**, and the two misreads above are the reader
row's to trace. No earlier book was built with the trial's scripts, so the
byte-identical proof (`marvel-book`, *Prove every earlier book did not
move*) was not measured; the trial's changes are gated only by their
`trial_` fields.

**Verdict: grid-booklets.** It reads this book's `parts`,
`character_ranges` and `opponents` as row 13a wrote them, and every field
the earlier books taught it carries over; it reaches every block, every
checklist name and exit 0 with items 1-9.

**The decision it settles** (the reader row sets it): `"layout":
"grid-booklets"`, with the fields above, the overrides' eight, and a field
of its own for each of reader changes 1-13 or the byte-identical proof.
This survey sets no `layout`. The registry patches (`p0.json` to
`p9.json`), the trial overrides, the reader changes and every run's output
are kept in the plan's store (rows 13c and 13c1, `trial/mlba1/`), not the
repo.

## Decisions this survey leaves open

Each has a recommendation, the one MX1, MX4, MT3 and MLA1 took where they
had the same question (Nate 2026-10-31: take the survey's recommendations).

1. **Teams.** The book has no team sections. Recommendation, as MLA1 and
   MT3 filed theirs: the six Player Character Cards under **Mutating Mutants
   Heroes**, and every other card under the book's title, **MLBA1 Mutating
   Mutants**. Not written to the registry until decided.
2. **Page citations.** Recommendation: MX1's single-booklet shape,
   `MLBA1 Adventure p.12` (the part's `cite` is `Adventure`).
3. **Names.** Recommendation: each header as printed, the real-name line kept
   as the card's identity: **Sentinel, Mark IV** as MLA1 kept its
   Sentinels, Mark IV; **Richtor** as printed (MLA1 named SWF as printed);
   **Rusty Collins**, the bracket of `Rusty (Russell) Collins` dropped from
   the name as `gridbooks.base` drops MT3's `(Typical)`, Russell kept in the
   identity; the animals without their room keys (**Chimpanzee**, **Giant
   Dalmatian**, **Chicken**); **Generic Punk** and **Generic Goon** as
   printed. Each grid an entry of its own.
4. **The misprints.** Recommendation: overrides keeping printed and
   corrected, as listed under *Stat blocks*: Schiz's R and I and Ee-ha's R
   to their codes, the five minor grids' Karma to R+I+P on the corrected
   rows (14 each), as MX3, MX4 and MT3 corrected theirs, each second fault
   in its block's `also`; Cannonball's A code to PR 4, as MA1 and MHSP2
   print it (MX1's Nimrod shape). The Sentinel, Mark IV's NA Karma kept
   `as_printed` (a robot, as MLA1's). The alternatives not recommended: the
   five minor Karmas `as_printed` as a current Karma, on the ground that
   not one adds up (the book never says so, and MX4 declined the same);
   Cannonball's Health 54 to 56, which keeps a row two books print
   otherwise.
5. **The animals' Karma.** Recommendation: derived from R+I+P on the codes'
   standard numbers (Chimpanzee 12, Giant Dalmatian 14, Chicken 6) and
   flagged derived on the card, as MT3's Snakes and Scorpions and MLA1's
   Alligator, Rat and Mosquito Swarm.
6. **Sunspot's `52(76)`.** Recommendation: kept as printed, the checks read
   on the value before the bracket, as MA1's Sunspot keeps `52 (76)`.
7. **The villain doubles.** Recommendation: no cards; they are the heroes'
   hallucinations, named and not statted.
8. **Characters only.** The X-Gene ray gun and its tables, the locations,
   the handouts and the maps are not imported (Nate, 2026-10-21).

## How to reproduce

```bash
python scripts/msh/ocr-book.py mlba1 --probe
python scripts/msh/ocr-book.py mlba1
python scripts/msh/survey.py mlba1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 30-220
dpi into the scratchpad, never into the repo.
