# Survey: MSL3 Spore of Arthros (TSR6902)

Marvel Super Heroes adventure, product code 6902 on the cover (PDF 1) and
6902XXX1401 on the back cover (PDF 34). By Rick Swan, 1991 (the title page).
Registry entry: `scripts/msh/books.json` -> `msl3`. Measured 2026-11-02.

**Rows citing this book:** 21 `msh_book_text` rows over 8 character entries
in production (`DB_MARVEL`, read back 2026-11-02).

Everything here was measured and read on the page images by plan row 28a
(renders at 30-160 dpi, PyMuPDF), and recorded in the registry entry.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 34 PDF pages, a pure scan with no text layer (`--probe`: median 0
  text-layer characters over 20 sampled pages; PyMuPDF reads 0 characters on
  every page), cached into the main checkout's `.cache/msh/books/msl3/`
  (34 pages OCR'd, 106 KB of text).
- **The booklet is 32 pages** (PDF 2-33, 594 x 767 pt), printed 1-32.
- **The scan holds the outside covers only**: no inside cover, no map sheet,
  and so none of the stat panels the booklet sends the reader to (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 600 x 772 | Cover (MSL3, ADVENTURE and 6902) | - |
| 2-33 | 594 x 767 | Adventure Book | 1-32 |
| 34 | 600 x 772 | Back cover (the blurb, the address and 6902XXX1401) | - |

The three maps are booklet pages (printed 4, 14 and 15) and no map is
imported.

## Offset

`survey.py` casts **two votes**, printed = PDF - 1 (PDF 26 and 30), and one
that is not a folio: PDF 2's 756 is the P.O. Box number in TSR's address at
the foot of the title page. Tesseract reads few folios because each body
page sets a small folio centred under a strip of comic panels at its foot.
Read on a strip of every booklet page's foot at 100 dpi, **28 pages print
their folio, every one PDF - 1**, from printed 2 (PDF 3) to 32 (PDF 33),
with no outlier. **Four print none**: the title page (printed 1) and the
three whole-page maps (printed 4, 14 and 15; PDF 5, 15 and 16), each at the
page the Contents gives it. So `parts`, as MSL1 and MSL2, with the two
covers as parts of their own with `offset` null.

## The book's own authority lists

**Contents (printed 1).** Two columns under Table of Contents, the chapters
at the left and Maps at the right, transcribed from a render at 160 dpi,
then each entry checked against its page. **Every entry agrees with its
page**, so there are no `contents_errata`. Stored as `sections` in the
Contents' order, the maps included, as MSL1's.

| printed | Contents entry | on the page |
|---|---|---|
| 2 | Chapter One: Mysterious Island | banner mid-page, under half a page of art |
| 10 | Chapter Two: Ominous Realm | banner mid-page, under half a page of art |
| 25 | Chapter Three: Dangerous Corridors | banner mid-page, under half a page of art |
| 30 | Chapter Four: Hideous Visitor | banner at the top, under the masthead, no art |
| 4 | Map 1: Nop Yaan | the whole page, its title on it |
| 14 | Map 2: Negative Zone (Region 1) | the whole page, its title on it |
| 15 | Map 3: Negative Zone (Region 2) | the whole page, its title on it |

- **The banners** are bold capitals and print the Contents' titles.
  **Tesseract reads all four.**
- **Inside the chapters** the text is set as subheads in a display face and
  numbered encounter keys (Encounter Key-Map 1 on printed 6, Map 2 on 12,
  Map 3 on 21), each encounter a bold run-in, `N. Name.`. Every grid sits
  inside one of these (below).
- **No index.** The Contents names no character. The coverage checklist will
  be this survey's list.

## Columns, labels and ranks

- **Two columns** on every body page (printed 2-32 on a 30 dpi sheet, and
  the grid pages, printed 5, 6, 13, 18, 21, 22 and 30, at 100-110 dpi), a
  grid spanning one column. The title page and the maps are not set in
  columns. **No grid breaks across a column**, but Torr's grid ends column 2
  of printed 18 and his text goes on at the top of column 1 of printed 19.
- **One grid shape** in the whole book, MSL1's and MSL2's: three stacked
  rows across the column, the letters F A S E R I P, the rank codes in
  capitals, then the numbers, each code above its number with no brackets.
  Under them **one line**: `Health =` at the left and `Karma =` at the
  right, a space either side of each `=` (MSL2 prints `Health:`). The
  Flying Robotic Snake (printed 6) and the Robotic Dragon (30) print
  `Health =` and **no Karma line**; the Dragon's Health is `See text`.
  **No grid prints Resources or Popularity**, and the OCR holds neither
  word anywhere in the book.
- **Headers.** Each grid has a title-case header in the display face of the
  chapters' subheads: Nop Yaan Peasant, Flying Robotic Snake, Ice Bat,
  Alien Trader (Torr), Bubble Beast, Flying Stallion (Ashta), Robotic
  Dragon. **The Vapor Wasp's (printed 18) is set in plain body type.**
  Measured on the TSV at 300 dpi, the headers box at 44-46 px and the
  Robotic Dragon's at 56, while the subheads around them box at 45
  (Encounter Key-Map 1, Mind-Controlled Peasants) and 57 (Events, after the
  Dragon). **No size separates a header from a subhead**: the grid under it
  does (`gridbooks.mark_headers`, as ME1's). No grid prints a real-name line.
- **Section labels.** `KNOWN POWERS` in bold capitals with no colon heads
  the powers of four grids: **run into the first power** on its line on the
  Ice Bat (printed 13) and the Vapor Wasp (18), and on a line of its own on
  the Bubble Beast (21) and Ashta (22). Each power is an italic run-in with
  a colon. **The other four grids print no label at all**: the Nop Yaan
  Peasant (5), the Flying Robotic Snake (6), Torr (18-19) and the Robotic
  Dragon (30) give their weapons, armour and movement in prose paragraphs
  after the grid. **No grid prints TALENTS, CONTACTS, IN BRIEF, Real Name,
  Background or Weakness.**
- **Every paragraph after a grid is indented**, as the chapter's own
  paragraphs are: the prose of the four unlabelled grids, and the
  paragraph that resumes the encounter after the labelled ones' powers.
- **Ranks.** Every code is in capitals: FE, PR, TY, GD, EX, RM, IN and MN
  (the Robotic Dragon's F, the only Monstrous). **No FB, AM, UN, Class or
  Shift code, no title-case code.** So `rank_aliases` is those eight.
- **Rank words in prose** give the stats of things with no grid: the
  canoes (printed 6), Torr's shuttle (18) and Annihilus' shuttle (28) as
  Control and Speed in words, and the arena's pounder, flame tank and
  robotic sponge (27) as the ranks of their attacks. None is a character's
  grid (decision 6).
- **`survey.py` finds all 8 `Health =` lines**, each with a header above
  it, and checks none: its ability-row pattern is MA1's one-row-per-ability
  layout. Its block count is this book's, its checks are not.

## Cover-panel cards and appendix

**None in the scan.** The OCR of PDF 1 and 34 holds no `Health`, `Karma` or
rank row, and their images show the cover and the back cover's blurb. So
`panels` is empty, as MSL1's, MSL2's and MT3's.

**The booklet sends the reader elsewhere for statistics this scan does not
hold**, each pointer read in the OCR and its page:

| printed | sends the reader to | for |
|---|---|---|
| 3 | the appendix | a generic SHIELD operative (Taylor) |
| 12 | the inner cover panel | Annihilus' minions |
| 19 | the inner cover panel, his entry | Quasimodo's humanoid body |
| 23 | the appendix | Volstagg |
| 27 | the inner panel cover | the minions again |
| 28 | the appendix, generic statistics | the SHIELD operatives and the Asgardian youths |

The adventure's two villains, Yellow Claw and Annihilus, print no grid in
the booklet either. **Those panels and that appendix are missing from this
scan**, as Xiticix Invasion's printed 136 was missing from its PDF. The
survey records them as missing and the import takes what the booklet prints
(decision 4).

## Stat blocks

**8 grids**, every one read on the page image at 110 dpi, each three stacked
rows under a title-case header, each inside a chapter's encounter text:

| printed | name as printed | where | Health | Karma |
|---|---|---|---|---|
| 5 | Nop Yaan Peasant | Chapter One, column 2, under the subhead Mind-Controlled Peasants | 22 | 10 |
| 6 | Flying Robotic Snake | Chapter One, column 1, encounter 3 | 80 | none printed |
| 13 | Ice Bat | Chapter Two, column 1, encounter 4 | 90 | 12 |
| 18 | Vapor Wasp | Chapter Two, column 1, encounter 12 | 60 | 8 |
| 18 | Alien Trader (Torr) | Chapter Two, foot of column 2, encounter 13; his text on printed 19 | 46 | 42 |
| 21 | Bubble Beast | Chapter Two, column 2, encounter 17 | 70 | 16 |
| 22 | Flying Stallion (Ashta) | Chapter Two, column 2, encounter 21 | 90 | 10 |
| 30 | Robotic Dragon | Chapter Four, column 2, before the subhead Events | See text | none printed |

**Where each one's text ends**, read on the OCR and the images: the
Peasant's at the foot of printed 5 (Encounter Key-Map 1 opens printed 6);
the Snake's at encounter 4 (printed 6); the Ice Bat's at encounter 5
(printed 13); the Vapor Wasp's at encounter 13 (18); Torr's at encounter 14
(printed 19, after a column of his bargaining); the Bubble Beast's at
encounter 18 (printed 22); Ashta's at encounter 22 (printed 23); the
Robotic Dragon's at the subhead Events (30). Between grid and end each runs
on into the encounter's play (how it attacks, what it wants), which the
reader has to cut or keep (*Which reader fits*).

The grids' numbers are not copied into this survey; the trial parse reads
them and the overrides file records the misprint below.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **6 of 7** printed Health numbers: Ashta fails; the Dragon prints `See text` |
| Karma = R+I+P | **6 of 6** printed: the Snake and the Dragon print no Karma line |
| every ability number within its rank code's range (`ranks.json`) | **7 of 8**: Ashta's A |

Every other number on the eight grids is its code's standard number.

**The misprint, read on the page image at 110 dpi:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Flying Stallion (Ashta), printed 22 | A prints code EX over the number 10, under Health 90 | EX's range is 16-25 (standard 20), and with A at 20 Health holds, 10+20+30+30 = 90; with the printed 10 it is 80 |

As `page:name:field printed->corrected`: `22:Flying Stallion (Ashta):A 10->20`.

**The Robotic Dragon's Health is not a misprint.** It prints `See text`, and
its text gives its current Health after Annihilus' attacks, 120; its four
physical numbers sum to 175, the full Health its code row gives (decision
8). Its Karma would be 6 by its mental numbers, and the book prints none,
as for the Snake (both machines).

**The whole book, counted:** 8 grids, 8 cards (decision 3); no forms, no
tiers, no vehicle grid.

**Card pages and the chapters' grids.** The book prints no roster and no
full card, so **`character_ranges` is empty** (MH6's form) and every grid is
in `opponents`, MSL1's form with its `part`, named by its header as printed.
The registry sets no `one_line_grids` and no `tiers`: every grid has a
header, and none is a form or a headerless type. Which reader takes them is
*Which reader fits*.

**Text defects** read on the images, both the book's own: `Yellow Fang` for
Yellow Claw twice on printed 30, in Chapter Four's overview, which no card
takes; and `He rubbery hide` for His on printed 19, in Torr's text
(decision 9).

## Names the Codex already has

Read from `apps/marvel-heroes/data/npcs.json` at `85df911d` (1090 cards),
by name and id: **none of the eight**. No card is named Torr, Ashta, Ice
Bat, Vapor Wasp, Bubble Beast, Robotic Dragon, Flying Robotic Snake or Nop
Yaan Peasant. The near names are other beings: the Wasp (six cards over
five books), MLA2's Dragon Robots, MT3's Snakes and ME1's Trader. Of the
characters whose stats the scan lacks, the Codex has Annihilus (MA4) only.
Each MSL3 card is a card of its own with a `-msl3` id (Nate, 2026-09-28).

## Quote marks

**The book prints no single quotes of its own on any page read.** Every
mark Tesseract reads as a single, or as a single beside a double, was read
on the image, seven of them (printed 13, 18, 19 twice, 26, 30 and 32):
every one is a double. The text the cards take, to the ends listed under
*Stat blocks*, holds four quotations, all in Torr's (printed 19): Tesseract
reads three as doubles and one with a single beside a double, which the
image shows is a double. So MHSP1's rule fits (every single mark a
misread), as it fits MSL1, MSL2 and MT3; the trial parse checks that the
chain builds each as a pair of doubles (decision 7).

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`, MSL1's and MSL2's), with
six things taught to it.** Measured 2026-11-02 (plan rows 28c and 28c1): a
scratch copy of `scripts/msh/` and `apps/marvel-heroes/data` at this
branch's `b0c76ba7` (`main` at `85df911d`), the msl3 entry as row 28a left
it (`parts`, `character_ranges` empty, `opponents`) given `"layout":
"grid-booklets"`, the fields `main`'s `gridbooks.py` already reads set for
this book, the trial's own reader fields below, and a trial
`msl3-overrides.json`, run on a copy of the cache under its own
`WORKSHOP_MSH_CACHE`. Eight runs (run0 to run7), each run's whole output
kept, then an ablation that turned each field of the last run off in turn.

**`code-grids` was not tried.** `codegrids.py` reads one `offset` and one
`character_pages`, and MSL3's entry is a `parts` entry with neither, which
is where it stopped on MT2 and MT3 (MSL1's *Which reader fits*). `main`'s
`gridbooks.py` reads `parts`, `character_ranges` and `opponents` already,
so the trial went there. The other readers fit less: `roster.py` (MA1)
reads one offset; `booklet.py` (MHSP1) and `coverpanels.py` (MH1, MH2) read
rank words with no numbers.

**The stock grid-booklets finds no grid.** With `layout` alone (run0),
`roster.py msl3` exits 1: 560 stream lines, **0 entries and 0 blocks**, all
8 opponents on no entry. The `=` in `Health = n` gives the line-grid parser
no anchor (item 1). With MSL2's fields set (`codes_over_numbers`,
`subhead_labels`, `cards`, `teams`, `one_line_grids`; run1) it stops at
once, `one_line_grids not found: Nop Yaan Peasant` (printed 5), for the
same reason.

| measure | stock (run0) | with every trial change (run7) |
|---|---|---|
| stream lines | 560 | 708 (Torr's printed 19, the Bubble Beast's 22 and Ashta's 23 read on) |
| entries | 0 | 8, every one with a block |
| stat blocks | 0 | 8 |
| blocks passing every check | 0 | 5, and 3 known from the overrides (2 `as_printed`, 1 `misprint`) |
| failing | 0 | 0 |
| checklist names with no entry | 8 (every opponent) | 0 (8 opponents, all found) |
| powers | 0 | 13 across 4 entries |
| exit code | 1 | 0 |

`npcs.py msl3` on run7's roster exits 0: **8 cards** (8 blocks, 13 powers,
8 of them linked to the UPB), **21 text rows over 21 distinct keys**, the
1090 cards of other books kept. Torr and Ashta are `torr-msl3` and
`ashta-msl3`, named per decision 5 with Alien Trader and Flying Stallion
as their identity lines. Torr's four quotations (printed 19) build as four
pairs of doubles, so decision 7 needs no `text` verdict. The 8 blocks are
this survey's 8 cards (decision 3).

What grid-booklets must learn. Each reader change was made in the scratch
copy, marked as the trial's, R1-R4 and R6 behind a field of their own, in
the diff kept in the plan's store:

1. **`Health = n` and `Karma = n`** on every grid's label line (printed
   5-30), with a space either side of the `=`: the stock reads only
   `Health:` and `Karma:`, so no grid is found. Reader (R1):
   `equals_labels`, which reads the line as MSL2's.
2. **`Health = See text`** (the Robotic Dragon, printed 30): with R1 alone
   the Dragon is an entry with no block, on no checklist (run2). Reader
   (R2): `text_health`, a `[part, page, words]` the line grid keeps as
   printed, with an anchor for it in `roster.read_entries`.
3. **No Karma line** (the Flying Robotic Snake, printed 6, and the Robotic
   Dragon, 30): the stock writes Karma as the string `'None'`, and the
   check reports `KARMA IS NOT A NUMBER` (run2). Reader (R3):
   `no_karma_line`, which leaves Karma null.
4. **An indented paragraph after the last power** (the Ice Bat, printed
   13; the Vapor Wasp, 18; the Bubble Beast, 21-22; Ashta, 22-23): every
   paragraph after a grid is indented (*Columns, labels and ranks*), and
   the stock gives the resumed encounter text to the last power (Vapor
   Form 1143 characters, Sphere Projection 2057, run5). Reader (R4):
   `run_on_prose`, which in an `opponent_indented_paragraphs` entry reads
   an indented paragraph after a power's sentence as prose.
5. **A book whose every grid is an opponent** (`character_ranges` empty):
   `npcs.py` stops with `KeyError: 'character_pages'` twice, in
   `source_pages` and `book_listing`. Reader (R5, `npcs.py`, no field):
   read the book's span from `npcs.ranges()`.
6. **A bracket giving the being's own name** (Alien Trader (Torr), printed
   18; Flying Stallion (Ashta), 22; decision 5): `card_names` refuses a
   bracketed header and `npcs.base_name` drops the bracket, so the cards
   come out as Alien Trader and Flying Stallion. Reader (R6, `npcs.py`):
   `bracket_given_names`, a `[part, page, header]` that names the card from
   the bracket and makes the rest its identity line.

**So the reader must learn 6 things**, R1-R6, all made in the trial. The
rest is registry-only, fields `main`'s reader already reads, and the
overrides file. The trial did not run the proof that every earlier book
builds byte-identical (`marvel-book`, *Prove every earlier book did not
move*); the reader row does.

**The registry-only fields and the overrides, and which are needed.** The
ablation (row 28c1) reproduced run7 byte for byte, then ran it with each
field off in turn, comparing `roster.json`, the msl3 records of
`npcs.json` and `book-text.sql` with run7's:

| field | without it |
|---|---|
| `codes_over_numbers` | all 8 blocks read `rank_only`, every number taken from its code (Ashta's A 10 becomes 20 with no override) |
| `subhead_labels` (`KNOWN POWERS`, no colon) | exit 1: `subhead_line_powers` finds no Body Armor on printed 13 |
| `teams` (every card under MSL3 Spore of Arthros, decision 1) | `npcs.py` exits 1, `KeyError: 'side'` |
| `one_line_grids` (the 8 grids, MX1's form, by header as read) | exit 1: `opponent_indented_paragraphs` finds no entry for the Peasant |
| `bracketed_card_names` (Torr's and Ashta's headers) | exit 1: both on no checklist |
| `opponent_indented_paragraphs` (all 8) | every entry's prose empty; printed 19, 22 and 23 lost |
| `entry_ends` (7: encounters 4, 5, 13, 14, 18 and 22, and the subhead Events) | 7 entries run on into the encounters (the Ice Bat's prose 300 characters to 2954, Ashta's 525 to 4314) |
| `opponents` `continues` (Torr 19, Ashta 23) and `runs_on` (the Bubble Beast 22) | Torr's prose 2940 characters to 0, the Bubble Beast's 1590 to 293, Ashta's 525 to 178 |
| `speck_lines` (6: `Booy` for Body on printed 13 and 18; `\t` and `\|t` for It on 13, 18 and 21) | exit 1: the same Body Armor not found on printed 13 |
| `subhead_line_powers` (`KNOWN POWERS` run into Body Armor on printed 13 and 18) | 5 powers across 2 entries, not 13 across 4; the Ice Bat and the Vapor Wasp keep none |
| `cards` (the 8 headers as read) | **not needed**: every output byte-identical; kept only as the record of the cards as read |
| `msl3-overrides.json` | exit 1: 1 failing (Ashta) and Health or Karma not a number on the Snake and the Dragon |

Every reader field (R1-R4, R6) is needed in the same way: without
`equals_labels` or `text_health` the run exits 1, without `no_karma_line`
the two machines' Karma is `'None'`, without `run_on_prose` the last power
swallows four entries' prose, and without `bracket_given_names` Torr and
Ashta keep their kinds as names. R5 has no field.

**The overrides**, 3 entries, each matching one block (decision 8):
Ashta's `A 10->20` a `misprint` (printed 22), with printed and corrected
kept; the Snake's Karma `as_printed` null (printed 6); the Robotic Dragon's
Health `as_printed` `See text`, with its Karma `as_printed` null in `also`
(printed 30).

**What the trial did not check:** the six speck fixes and the seven entry
ends were read off the stream, not on a render of the page; and the prose
above each grid, which introduces it, is the encounter's and is in no
entry. The trial's registry patches, the reader diff, the overrides and
every run are kept in the plan's store (rows 28c and 28c1,
`trial/msl3/`), not the repo.

**Verdict: grid-booklets.** It reads this book's `parts`, empty
`character_ranges` and `opponents` as row 28a wrote them, and every field
an earlier book taught it carries over; code-grids reads no `parts` entry.

**The decision it settles** (the reader row sets it): `"layout":
"grid-booklets"`, with the fields above (`cards` optional), the three
overrides, a field of its own for each of R1-R4 and R6, R5 in `npcs.py`,
and the byte-identical proof for every earlier book. This survey sets no
`layout`.

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-31: take the survey's recommendations). Characters only is already
ruled (Nate, 2026-10-21), and so are second cards with `-msl3` ids
(2026-09-28) and a leading The dropped from a name (2026-10-21).

1. **Teams:** every card under **MSL3 Spore of Arthros** (recommended, as
   MSL1's and MSL2's chapter opponents and MT3's other cards under the
   book's title). No card is a team member: the heroes (the Fantastic Four,
   or four heroes of the GM's choosing) print no grid. Not taken: a team for
   Annihilus' or Yellow Claw's creatures, which the book does not name as a
   group.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure,
   items, vehicles, places or maps.
3. **Every grid a card** (recommended, as MSL1 and MSL2 decision 3 and MT3's
   chapter creatures and robots): the Peasant, the Snake, the Ice Bat, the
   Vapor Wasp, Torr, the Bubble Beast, Ashta and the Robotic Dragon, 8 in
   all. Not taken: leaving the two machines or the generic peasant in the
   chapters' text, since each prints a full grid of its own.
4. **The stat panels missing from the scan** (Yellow Claw, Annihilus,
   Quasimodo, Volstagg, the SHIELD operatives, the Asgardian youths and
   Annihilus' minions) (recommended): recorded here as missing and not
   built, as Xiticix Invasion's missing printed 136 was. A scan of the
   inside covers would be a row of its own. Not taken: cards built from
   the prose's scattered ranks, which would be this app's stats, not the
   book's.
5. **Names** (recommended): the headers as printed, title case already,
   but **Alien Trader (Torr) as Torr** and **Flying Stallion (Ashta) as
   Ashta**, the bracket holding the being's own name and the rest its
   kind, which becomes the card's identity line (MSL2's `card_names` and
   `line_identity`). No header starts with The. Not taken: the bracket kept
   in the name as MSL1's clones keep (Clone), whose bracket qualifies a
   name rather than giving one.
6. **Things statted only in prose** (recommended): the arena's pounder,
   flame tank and robotic sponge (printed 27), the canoes (6) and the two
   shuttles (18 and 28) left in the chapters' text, not cards (characters
   only; none prints a grid).
7. **Quote marks** (recommended): MHSP1's rule for the imported text, since
   the book prints no single of its own; Torr's four quotations built as
   doubles, with a `text` verdict for any the chain builds as singles. Not
   taken: keeping a single the chain makes, which would leave an unpaired
   mark in the Codex.
8. **Ashta's A and the Dragon's Health** (recommended, as MSL1 decision 6,
   MSL2 decision 6 and MT3 decision 7): Ashta's `A 10 -> 20` a `misprint`
   override with printed and corrected kept, since the code and the
   printed Health agree on 20. Not taken: the code changed to GD to fit the
   10, which leaves Health 90 wrong. The Robotic Dragon's `Health = See
   text` left as printed (the check skips a Health that is not a number,
   as MA1's robots' `Karma = -`), and no Karma derived for it or the Snake,
   since the book prints none. Not taken: 120 as its Health, which is its
   damaged state in this one scene, or 175 written in as if printed.
9. **The two text defects** (recommended): kept as printed. `Yellow Fang`
   is in no card's text; `He rubbery hide` in Torr's is the book's own
   slip and reads plainly. Not taken: a `text` verdict, which is for a mark
   the OCR got wrong, not the book.

## How to reproduce

```bash
python scripts/msh/ocr-book.py msl3 --probe
python scripts/msh/ocr-book.py msl3
python scripts/msh/survey.py msl3
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
