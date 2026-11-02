# Survey: MSL4 Stygian Knight (TSR6904)

> **DRAFT.** Written up to *Which reader fits*, which is not finished: the
> trial parse (plan row 31c) runs a reader over this book and writes it. No
> `layout` is set, and nothing of the book is imported yet.

Marvel Super Heroes adventure, product code 6904 on the cover (PDF 1). By
Anthony Herring (the title page), 1991, MSL2's author. Registry entry:
`scripts/msh/books.json` -> `msl4`. Measured 2026-11-02.

**Rows citing this book:** 0 `msh_book_text` rows in production: nothing is
imported yet, and the data row sets this line from production.

Everything here was measured and read on the page images by plan row 31a
(renders at 24-150 dpi, PyMuPDF), and recorded in the registry entry.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 36 PDF pages, a pure scan with no text layer (`--probe`: median 0
  text-layer characters over 20 sampled pages; PyMuPDF reads 0 characters on
  every page), cached into the main checkout's `.cache/msh/books/msl4/`
  (36 pages OCR'd, 100 KB of text).
- **The booklet is 32 pages** (PDF 3-34, 596 x 768 pt), printed 1-32.
- **The inside covers are maps**, one each side of the booklet.

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 595 x 772 | Cover (MSL4, ADVENTURE and 6904) | - |
| 2 | 594 x 767 | Map: Ryker's Island of Tomorrow (inside front cover, with its key) | - |
| 3-34 | 596 x 768 | Adventure Book | 1-32 |
| 35 | 594 x 767 | Map: Ryker's Island of Today (inside back cover) | - |
| 36 | 595 x 772 | Back cover (the blurb and the ISBN, no product code read) | - |

None of PDF 1, 2, 35 and 36 prints a folio or a stat block, and no map is
imported. **Printed 32 (PDF 34) is a whole-page advertisement** for the
Basic Set, with no folio and no text of the adventure.

## Offset

`survey.py` casts **four votes, printed = PDF - 2** (PDF 14, 22, 24 and
27), and no vote disagrees. Tesseract reads few folios because each body
page sets a small folio centred under a strip of comic panels at its foot.
Read on a strip of every booklet page's foot at 45 dpi, **30 pages print
their folio, every one PDF - 2**, from printed 2 (PDF 4) to 31 (PDF 33),
with no outlier. **Two print none**: the title page (printed 1, PDF 3, the
Contents, the credits and the ISBN) and the advertisement (printed 32, PDF
34). So `parts`, as MSL1, MSL2 and MSL3, with the cover, the back cover and
the two inside-cover maps as parts of their own with `offset` null.

## The book's own authority lists

**Contents (printed 1).** Two columns under Table of Contents, transcribed
from a render at 130 dpi, then each entry checked against its page. **Every
entry agrees with its page**, so there are no `contents_errata`. Stored as
`sections` in the Contents' order.

| printed | Contents entry | on the page |
|---|---|---|
| 2 | Introduction | banner at the top, under the masthead |
| 3 | Ryker's Island of Today | banner at the top |
| 5 | Ryker's Island of Tomorrow | banner at the top |
| 7 | Chapter 1: An Invitation | banner at the top |
| 8 | Chapter 2: Guest Appearance | banner at the top |
| 10 | Chapter 3: Man and Machine | banner at the top |
| 14 | Chapter 4: Into Darkness | banner at the top |
| 16 | Chapter 5: Deathtrap! | banner mid-page, under a large piece of art |
| 21 | Chapter 6: Attack of the Cyborgs! | banner at the top |
| 23 | Chapter 7: The Resistance | banner mid-page, under a large piece of art |
| 25 | Chapter 8: Stygian Knight | banner at the top |
| 27 | Non-Player Character Roster | banner mid-page, under a large piece of art |

- **The banners** are bold capitals and print the Contents' titles.
  **Tesseract reads all twelve.**
- **The two Ryker's Island entries are text sections**; the maps of the
  same names are the inside covers (PDF 2 and 35), not booklet pages.
- **Inside the chapters** the text is set as bold capital run-ins
  (`SUMMARY:`, `STARTING:`, `ENCOUNTER:`), bold title-case run-in subheads
  and numbered traps. A Bounce Direction Table is printed on printed 18.
- **No index.** The Contents names no character. The coverage checklist will
  be this survey's list.

## Columns, labels and ranks

- **Two columns** on every booklet page but the title page and the
  advertisement (printed 2-31 on 24-30 dpi sheets, and the grid pages,
  printed 14, 17 and 27-31, at 60-120 dpi), a grid spanning one column.
  **No grid breaks across a column**, but the Phase-Bot's grid ends column 2
  of printed 17 and its `KNOWN POWERS` opens column 1 of printed 18.
- **One grid shape** in the whole book, MSL1's, MSL2's and MSL3's: three
  stacked rows across the column, the letters F A S E R I P, the rank codes
  in capitals, then the numbers, each code above its number with no
  brackets. Under them `Health:` at the left and `Karma:` at the right on
  one line. **The eight roster grids add a second line**, `Resources:` at
  the left (a code and its number in brackets, `FB (2)`) and `Popularity:`
  at the right; **the three adventure grids print Health and Karma only.**
  Annihilus's Karma is set with no space after the colon (`Karma:70`) and
  his Popularity is a minus, a space, then 30 (printed 27); Tesseract reads
  the minus as a dash. Every other Popularity is 0.
- **Roster headers** (printed 27-31) are capitals in a large display face,
  **surname-first where a comma inverts them**: `CYBORG, MARK I
  (HUNTER-WORKER)`, `CYBORG, MARK II (GATHERER)`, `CYBORG, MARK III (MAYOR
  AND WARDEN)` (set over two lines, the second `WARDEN)`), `DUNBAR, FIONA
  (CITY SCOUT)`, beside `ANNIHILUS`, `RIGGER (CITY SCOUT)` and `STYGORR`.
  **Each is followed by a title-case line in a subhead face reading `Real
  Name:` and the name**, MSL2's real-name line with the label printed:
  Annihilus; Irrelevant (the Mark I and Mark II); two names over two lines
  (the Mark III, below); Fiona Dunbar; Ramone Webber; Stygorr/Lew Shiner.
- **Adventure headers** (printed 14 and 17) are bold body type, title case:
  Spy-Eye, Spray-Bots, Phase-Bot (Shugnaggorak). They print no real-name
  line.
- **Section labels.** `KNOWN POWERS` in bold capitals with no colon heads
  the powers of all eleven grids, on a line of its own, but Fiona Dunbar's,
  which runs into `None.` on its line (printed 29). Each power is an italic
  run-in with a colon, stunts and options as bulleted lines. On the roster
  cards, all bold run-ins with a colon:

| label | cards |
|---|---|
| `LIMITATION:` | Annihilus (printed 27) |
| `Equipment:` (title case) | Fiona Dunbar (29), her three items italic run-ins on printed 29-30 |
| `TALENTS:` | all seven |
| `ROLE-PLAYING NOTES:` | all seven; the Mark I's set as `ROLE-PLAYING NOTES (for all Cyborgs):` (printed 28), the Mark II's and Mark III's pointing to it (29). MT2 prints the same label |
| `IN BRIEF:` | Annihilus (27-28), Fiona Dunbar (30), Rigger (30-31), Stygorr (31); no cyborg |

  No CONTACTS, Background or Weakness anywhere.
- **Ranks.** Every code is in capitals: **FB and FE both for Feeble** (FB on
  Rigger's F and S, printed 30, and in five cards' Resources; FE on the
  Spray-Bots' and the Phase-Bot's I and P, printed 17), PR, TY, GD, EX, RM,
  IN, AM and MN (Annihilus's E and Resources, the only Monstrous). **No UN,
  no Class or Shift code on a grid, no title-case code.** So `rank_aliases`
  is those ten. Annihilus's Flight names Cl1000 in his power text, not on a
  grid.
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1, 2, 35 and 36 holds no `Health`, `Karma` or rank
row, and their images show the cover, two maps and the back cover's blurb.
So `panels` is empty, as MSL1's, MSL2's and MSL3's.

**Who has no grid, by the book's own pointers:** the Fantastic Four, the
player characters, are sent to the Basic and Advanced games (printed 2),
and the police and civilians of Chapter 3 to the same books (printed 12).
Neither is missing from the scan.

## Stat blocks

**11 grids**, every one read on the page image at 110-120 dpi, each three
stacked rows: seven roster cards (printed 27-31), Stygorr's human form
inside his card, and three inside the chapters (printed 14 and 17).

| printed | name as printed | where | Health | Karma | already carded by |
|---|---|---|---|---|---|
| 14 | Spy-Eye | Chapter 4, column 2, after the ENCOUNTER: run-in | 48 | 18 | - |
| 17 | Spray-Bots | Chapter 5, column 1, trap 1 | 58 | 10 | - |
| 17 | Phase-Bot (Shugnaggorak) | Chapter 5, foot of column 2, trap 3; its powers on printed 18 | 80 | 10 | - |
| 27-28 | ANNIHILUS | NPC roster, column 1; IN BRIEF to the top of printed 28 | 205 | 70 | MA4 (Fiends and Foes), the same grid |
| 28 | CYBORG, MARK I (HUNTER-WORKER) | NPC roster, column 1 | 110 | 18 | - |
| 28-29 | CYBORG, MARK II (GATHERER) | NPC roster, column 2 | 90 | 18 | - |
| 29 | CYBORG, MARK III (MAYOR AND WARDEN) | NPC roster, column 1 | 130 | 18 | - |
| 29-30 | DUNBAR, FIONA (CITY SCOUT) | NPC roster, column 2 | 36 | 18 | - |
| 30-31 | RIGGER (CITY SCOUT) | NPC roster, column 2 | 14 | 52 | - |
| 31 | STYGORR | NPC roster, column 1, to the foot of column 2 | 110 | 100 | MSL2, the same grid |
| 31 | (Stygorr's human form, no header) | inside Stygorr's KNOWN POWERS, after Alter Ego | 28 | 100 | MSL2, the same grid |

**Where each adventure grid's text ends**, read on the OCR and the images:
the Spy-Eye's at the run-in subhead A Talk with the Nightlord. (printed
14); the Spray-Bots' at trap 2, the top of column 2 of printed 17; the
Phase-Bot's on printed 18, after its powers and the trap's play. Between
the powers and that end each runs on into the encounter's play, which the
reader has to cut or keep (*Which reader fits*).

**Two cards hold more than one person or more than one grid:**

- **The Mark III's one grid is two people's.** Its `Real Name:` line names
  two, over two lines: Mayor Timothy Cummins and Warden Bennett "Big Ben"
  Stanford (decision 5).
- **Stygorr's second grid is his human form**, Lew Shiner, printed inside
  his KNOWN POWERS with its own Resources AM (50) and Popularity 0, as in
  MSL2 (decision 4). Unlike MSL2's, **this numbers row prints all seven
  numbers.**

The grids' numbers are not copied into this survey; the trial parse reads
them.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **11 of 11** |
| Karma = R+I+P | **11 of 11** |
| every ability number within its rank code's range (`ranks.json`) | **11 of 11**, and every number is its code's standard number |

**No misprint.** No grid fails, and nothing needs an override. As
`page:name:field printed->corrected`: none.

**The whole book, counted:** 11 grids, 10 cards (decision 3) and Stygorr's
human form (a block of his card, decision 4); no tier, no item or vehicle
grid.

**Card pages and the chapters' grids.** Printed 27-31 are card pages
(`character_ranges`, printed 27-31, from the roster's banner mid-page on
printed 27; Chapter 8 ends above it). The three adventure grids are statted
inside the prose, and the registry records them in `opponents`, MSL1's
form with its `part`, named by the header as printed. Stygorr's human form
is in `one_line_grids` in MSL2's form (`entry` Stygorr, `label` Lew
Shiner). No `tiers`: every grid has a header but the human form, and Fiona
Dunbar's card stands for the other City Scouts by the book's own pointer
(printed 30), not as a headerless type. Which reader takes them is *Which
reader fits*.

## Names the Codex already has

Read from `apps/marvel-heroes/data/npcs.json` at `ebf46fb7` (1098 cards), by
name, real name and id:

| MSL4 card | already carded by |
|---|---|
| Annihilus | MA4 (Fiends and Foes), printed 56 there: the same codes, numbers, Health, Karma, Resources and Popularity |
| Stygorr | MSL2 (MSL2 Warlord of Baluur), printed 31 there: the same grid as MSL2's after its misprint override (MSL2 printed six numbers under seven codes; this book prints all seven), and the same human-form grid |

New: the three cyborgs, Fiona Dunbar, Rigger, the Spy-Eye, the Spray-Bots
and the Phase-Bot. No card is named for a cyborg, a City Scout,
Shugnaggorak, Ramone Webber or a Spy-Eye. Each MSL4 card is a card of its
own with a `-msl4` id (Nate, 2026-09-28).

## Quote marks

**The book prints single quotes of its own, in the adventure's prose**: a
quoted map letter `'X'` (printed 14, column 1, in STARTING:, above the
Spy-Eye's grid) and a quotation nested in a quotation, `'hell.'`, inside
Fiona's answers (printed 24), both read on the images. The OCR shows more
of the same in the chapters (paired singles on printed 5), not rendered by
this row.

**None is in a card's text.** The roster pages (printed 27-31) hold no
single mark in the OCR but feet marks after a number (`10'` on printed 28
and 29) and one closing mark Tesseract reads as a single: the quotation marks
round a two-word phrase in Stygorr's Matter Fluctuation (printed 31,
column 2) are **both doubles** on the image, the closing one read as a
single. The Spy-Eye's
run-on text (printed 14) holds one quotation, its opening double read as a
single beside a double; the image shows a double.

So for the imported text **MHSP1's rule fits** (every single mark a
misread), as it fits MSL1, MSL2 and MSL3, with three things for the trial
parse to check: that the feet marks after a digit stay singles
(`pair_quotes` skips a mark after a digit, MT3's and MSL1's finding), that
Stygorr's closing double is built as a double (a `text` verdict with
printed kept if not), and that no adventure entry reaches back to the
`'X'` above the Spy-Eye's grid (decision 9).

## Which reader fits

**Not finished.** Plan row 31c runs the trial parse and writes this
section. What it has to see, from the measurements above:

- MSL1's, MSL2's and MSL3's verdict was `grid-booklets`
  (`scripts/msh/gridbooks.py`) with the fields their reader rows added, for
  the same three-row grid in a `parts` entry. MSL4's layout is MSL2's
  nearest: an NPC roster of capitals headers with a real-name line under
  each, Stygorr's human form inside his card, and a few chapter grids.
- The roster grids print `Health:`/`Karma:` over `Resources:`/`Popularity:`
  (MSL1's and MSL2's `line_grid_resources`); Annihilus's `Karma:70` has no
  space, and his Popularity's minus reads as a dash (MSL1's
  `line_popularity_minus`). The adventure grids print no Resources line.
- The human form prints all seven numbers (MSL2's needed
  `short_number_rows`) and its own Resources and Popularity (MSL2's
  `form_resources`).
- Two headers are surname-first (`CYBORG, MARK ...`, `DUNBAR, FIONA`), one
  is set over two lines (the Mark III), and every roster header but
  Annihilus's and Stygorr's carries a role in brackets (decision 6). The
  Mark III's `Real Name:` line runs over two lines and names two people.
- The `Real Name:` line is a subhead-face line with its label printed,
  where MSL2's was the name alone (MSL2's `line_identity`) and MSL1's a
  bold run-in.
- `KNOWN POWERS None.` runs into its line on Fiona Dunbar's card (MSL2's
  `subhead_line_powers`, for a power-less card). `Equipment:` is title case
  (MX1's and MT2's `title_case_labels`). `LIMITATION:` and `ROLE-PLAYING
  NOTES:` are labels no MSL book has printed; MT2 printed the second, and
  the Mark I's carries `(for all Cyborgs)` before its colon.
- The adventure grids' entries run on into the chapter's play, each to a
  different end (above), and the Phase-Bot's powers open the next page.
- The OCR reads `|t` and `\t` for It at the start of power lines (printed
  14 and 18), as MSL3's did.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-31: take the survey's recommendations). Characters only is already
ruled (Nate, 2026-10-21), and so are second cards with `-msl4` ids
(2026-09-28) and a leading The dropped from a name (2026-10-21).

1. **Teams:** every card under **MSL4 Stygian Knight** (recommended, as
   MSL2's roster and chapter opponents, MSL3's cards and MT3's other cards
   under the book's title). Annihilus and Stygorr included: MSL2 filed its
   Stygorr under its own title, and MA4's Fiends and Foes is that book's
   section, not a team. Not taken: a team of City Scouts for Fiona Dunbar
   and Rigger, or of Cyborgs for the three Marks, which the book names as
   groups only in prose.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure,
   items, places or maps.
3. **Every character grid a card** (recommended, as MSL1, MSL2 and MSL3
   decision 3): the seven roster cards and the Spy-Eye, the Spray-Bots and
   the Phase-Bot, 10 in all. The three robots of the chapters are cards as
   MSL3's Robotic Dragon and Flying Robotic Snake and MSL1's X-Terminator
   Robots are; the Spray-Bots keep the plural, as the Robots do. Not taken:
   leaving the robots in the chapters' text, since each prints a full grid
   of its own.
4. **Stygorr's human form** (recommended, as MSL2 decision 4): a second
   block of Stygorr's card labelled Lew Shiner, not a card of its own. Not
   taken: a Lew Shiner card, which would split one being (one mind, by the
   card's own text) over two cards.
5. **The Mark III's two people** (recommended): one card for the one grid,
   its identity the two names as its `Real Name:` line prints them. Not
   taken: two cards with the same grid, which the book does not print.
6. **Names** (recommended, as MSL2 decision 5's `FURY, NICK` as Nick Fury):
   the surname-first headers turned, **Fiona Dunbar**, and the cyborgs as
   the chapters' prose names them, **Mark I Cyborg**, **Mark II Cyborg** and
   **Mark III Cyborg** (printed 6 and 12); the capitals in title case,
   **Annihilus**, **Rigger** and **Stygorr**. **Every bracket is a role or a
   kind, not a name**, and is dropped from the card's name: Hunter-Worker,
   Gatherer, Mayor and Warden, City Scout (twice) and Shugnaggorak, which is
   the monster the Phase-Bot's illusion shows, not the robot's own name. So
   **Phase-Bot**, not MSL3's bracket-as-given-name (Torr, Ashta). No header
   starts with The. Not taken: the comma-inverted headers as printed, which
   no Codex name uses; the brackets kept in the names as MSL1's clones keep
   (Clone), whose bracket tells two beings of one name apart (the Mark
   numbers already do that here).
7. **No overrides** (recommended): every grid adds up and every number is
   its code's standard, so `msl4-overrides.json` is not needed unless the
   trial finds a misread the chain cannot fix (a `text` verdict, decision
   9).
8. **`Real Name: Irrelevant`** (the Mark I and Mark II, printed 28)
   (recommended): kept as printed, as the card's identity line. Not taken:
   an empty identity, which would drop the book's own word.
9. **Quote marks** (recommended, as MSL1 decision 10 and MSL3 decision 7):
   MHSP1's rule for the imported text, since no card's text holds a single
   of the book's own; Stygorr's closing double, read as a single, built as
   a double, with a `text` verdict and printed kept if the chain builds a
   single; the feet marks after a number left as singles. Not taken:
   keeping a single the chain makes, which would leave an unpaired mark in
   the Codex.

## How to reproduce

```bash
python scripts/msh/ocr-book.py msl4 --probe
python scripts/msh/ocr-book.py msl4
python scripts/msh/survey.py msl4
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
