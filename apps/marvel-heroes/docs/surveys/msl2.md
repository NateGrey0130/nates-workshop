# Survey: MSL2 Warlord of Baluur (TSR6901)

> **DRAFT.** Written up to *Which reader fits*, which is not finished: the
> trial parse (plan row 25c) runs a reader over this book and writes it. No
> `layout` is set, and nothing of the book is imported yet.

Marvel Super Heroes adventure, product code 6901 on the cover (PDF 1) and on
the title page. By Anthony Herring, 1991 (the title page). Registry entry:
`scripts/msh/books.json` -> `msl2`. Measured 2026-11-02.

**Rows citing this book:** 0 `msh_book_text` rows in production: nothing is
imported yet, and the data row sets this line from production.

Everything here was measured and read on the page images by plan row 25a
(renders at 20-200 dpi, PyMuPDF), and recorded in the registry entry.

Through `scripts/msh/` only. Characters only (Nate, 2026-10-21): the
adventure, items and places are not imported.

## The scan

- 36 PDF pages, a pure scan with no text layer (`--probe`: median 0
  text-layer characters over 20 sampled pages), cached into the main
  checkout's `.cache/msh/books/msl2/` (36 pages OCR'd, 91 KB of text).
- **The booklet is 32 pages** (PDF 3-34, 596 x 769 pt), printed 1-32.
- **The scan holds no cover-panel card** (below).

| PDF | size (pt) | part | printed |
|---|---|---|---|
| 1 | 605 x 774 | Cover (MSL2, ADVENTURE and 6901) | - |
| 2 | 594 x 767 | Inside front cover: maps, Negative Zone Portal and Watch Station, and Domain of the Negalisk | - |
| 3-34 | 596 x 769 | Adventure Book | 1-32 |
| 35 | 594 x 767 | Inside back cover: maps, Features of the Negative Zone, and Lew Shiner's Skyscraper | - |
| 36 | 605 x 774 | Back cover (the blurb, the ISBN and the price; no product code read) | - |

Neither inside cover prints a folio or a stat block, and no map is imported.
The book has no map sheet.

## Offset

`survey.py` casts **no vote**: Tesseract reads no word at all in the bottom
tenth of any booklet page, where each page prints a four-panel strip of art
and, centred under it, a small folio. Read on a strip of every page's foot
at 60 dpi, **all 32 booklet pages print their folio, PDF - 2**, from printed
1 on the title page (PDF 3) to printed 32 (PDF 34), with no page missing
one and no outlier. So `parts`, as MSL1, with the cover, the two inside
covers and the back cover as parts of their own with `offset` null.

## The book's own authority lists

**Contents (printed 1).** One column beside the credits, transcribed from a
render, then each entry checked against its page. **Every entry agrees with
its page**, so there are no `contents_errata`. Stored as `sections` in the
Contents' order.

| printed | Contents entry | banner on the page |
|---|---|---|
| 2 | Introduction | top, under the masthead |
| 3 | The Player Characters | mid-page, under art |
| 6 | About the Negative Zone | top |
| 7 | The Cosmic Control Rod | top |
| 8 | Chapter 1: Red Alert! | mid-page, under art |
| 11 | Chapter 2: A Hole in the Sky | mid-page, under art |
| 15 | Chapter 3: By the Rocket's Red Glare | mid-page, under art |
| 17 | Chapter 4: Into the Negative Zone | mid-page, under art |
| 21 | Chapter 5: To Battle Above the World! | top |
| 25 | Chapter 6: The Living Bombburst! | mid-page, under art |
| 28 | Non-Player Character Roster | top, under the masthead |

- **The banners** are bold capitals and print the Contents' titles, the
  chapters' titles included (unlike MSL1, whose Contents prints
  `Chapter N` alone). **Tesseract misses three**: Chapter 1's (printed 8),
  Chapter 2's (11) and the roster's (28). Six banners open mid-page under a
  large piece of art, so a section starts partway down its page.
- **The Player Characters** (printed 3-5) holds a subsection, Equipping the
  Heroes (printed 4, column 1 and the top of column 2: the heroes' gear),
  before Power Man's card. Its gear is not imported (characters only).
- **No index.** The Contents names no character. The coverage checklist will
  be this survey's list.

## Columns, labels and ranks

- **Two columns** on every booklet page (printed 1-32 on a 20 dpi sheet, and
  the grid pages, printed 4-5, 19 and 28-32, at 100-200 dpi), a grid
  spanning one column. **No grid breaks across a column.**
- **One grid shape** in the whole book, MSL1's: three stacked rows across
  the column, the letters F A S E R I P, the rank codes in capitals, then
  the numbers, each code above its number with no brackets, and two lines of
  labels under them. **The labels' order is the same on all nine**: Health:
  and Karma: on the first line, Resources: and Popularity: on the second.
  Resources is a code and its number in brackets (`PR (4)`); Blastaar's is
  set with no space (`EX(20)`) and his Popularity with none after the colon
  (`Popularity:2`), printed 28; the Debris Creature (printed 19) and the
  Negalisk (30) print `Resources: 0`. Popularity runs from 0 to 50 (Nick
  Fury).
- **Headers.** Each card's header is in capitals, about 1.8 times the body
  type (58-67 px against 32 at 300 dpi), and the inverted `FURY, NICK`
  among them. Under it a real-name line in title case, about 1.4 times the
  body (45-47 px; Stygorr's, with its slash, 57): Luke Cage, Jennifer Walters, Blastaar of Baluur,
  Nicholas Joseph Fury, Crotakeetok, Stygorr/Lew Shiner. The Typical SHIELD
  Operative prints none. The DEBRIS CREATURE (printed 19), inside a
  chapter, is capitals at the size of the chapter's subheads (46 px; the
  subhead after it is 44-45) with no real-name line.
- **Section labels**, counted on the OCR of PDF 6-7, 21 and 30-34 and read
  on the images: `KNOWN POWERS` in bold capitals with no colon heads the
  powers of every grid, on a line of its own on Power Man (printed 4),
  She-Hulk (5), Blastaar (28) and the Negalisk (30), and **run into the
  first italic power** on the Debris Creature (19), Nick Fury (29), Stygorr
  (31) and the operative (32). Each power is an italic run-in, stunts and
  grenades as bulleted lines. `TALENTS:` and `IN BRIEF:` in bold capitals
  are run-ins on every card but She-Hulk's, which prints `Talents:` and
  `In BRIEF:` (printed 5); `IN BRIEF:` is set with no space after the colon
  on Blastaar (28), Nick Fury (29) and the operative (32). **No card prints
  Real Name:, Contacts, Background or Weakness.**
- **The Debris Creature prints no TALENTS: or IN BRIEF:**: after its powers
  Chapter 4 resumes under the subhead An Alien's Wrath (printed 19, column
  2).
- **Ranks.** Every code is in capitals: FE (the Debris Creature's R, the
  only Feeble), PR, TY, GD, EX, RM, IN, AM, MN (She-Hulk's S) and UN. **No
  FB, no Class or Shift code, no title-case code** on a character's grid.
  So `rank_aliases` is the ten plain codes.
- **Three vehicle lines** print Control, Speed and Body (and Protection) as
  codes with no number: the Nuclear Warhead (printed 16), the BRAVE and the
  Fist of Power (printed 22), the last with CL5000 on Speed. None is a
  character's (decision 7).
- **`survey.py` finds 0 blocks**: it looks for MA1's `Health =`, and this
  book prints `Health:`. Its block count is not this book's measure.

## Cover-panel cards

**None.** The OCR of PDF 1, 2, 35 and 36 holds no `Health`, `Karma` or rank
row, and their images show the cover, four maps and the back cover's blurb.
So `panels` is empty, as MSL1's and MT3's.

## Stat blocks

**9 grids**, every one read on the page image (110-200 dpi), each three
stacked rows. Eight are under a header of their own; the ninth is Stygorr's
human form, a second full grid with no header, inside his KNOWN POWERS
after the Alter Ego power's text (decision 4). The Fantastic Four print no
grid: The Player Characters points to the Basic and Advanced sets for
them.

| printed | name as printed | where | already carded by |
|---|---|---|---|
| 4-5 | POWER MAN (Luke Cage) | The Player Characters, column 2 of printed 4 to the top of column 1 of 5 | MA4, MHSP2, MH4, MLA1, MLA2, the same grid |
| 5 | SHE-HULK (Jennifer Walters) | The Player Characters, column 1 | MA4, MHSP2, MH9, the same grid; MHSP1 and MH3, another |
| 19 | DEBRIS CREATURE | Chapter 4, column 2 | - |
| 28 | BLASTAAR (Blastaar of Baluur) | NPC roster | MA4, MH3, MHSP2, the same grid |
| 29 | FURY, NICK (Nicholas Joseph Fury) | NPC roster | MH9, another grid |
| 30 | NEGALISK (Crotakeetok) | NPC roster | - |
| 31-32 | STYGORR (Stygorr/Lew Shiner) | NPC roster; his IN BRIEF ends in column 1 of printed 32 | - |
| 31 | (Stygorr's human form, no header) | inside Stygorr's KNOWN POWERS | - |
| 32 | TYPICAL SHIELD OPERATIVE | NPC roster, column 2 | - |

The roster's five cards each start at the top of column 1 but the
operative's, which follows the end of Stygorr's text in column 1 of printed
32. The grids' numbers are not copied into this survey; the trial parse
reads them and the overrides file records the misprint below.

**The book checks itself.**

| measure | count |
|---|---|
| Health = F+A+S+E | **8 of 9**: Stygorr fails |
| Karma = R+I+P | **8 of 9**: Stygorr fails |
| every ability number within its rank code's range | **8 of 9**: Stygorr's E and R, and his P prints no number |

Every number on the other eight is its code's standard number.

**The misprint, read on the page image at 200 dpi:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Stygorr, printed 31 | codes RM IN EX EX IN RM RM over **six** numbers, 30 40 20 40 30 30, P blank, under Health 110 and Karma 100 | the numbers row has lost one number: with E's 20 restored and R, I and P's numbers each moved one column right (E 20, R 40, I 30, P 30) every number is its code's standard, Health 30+40+20+20 = 110 and Karma 40+30+30 = 100. His human form's grid (same page) prints R IN 40, I RM 30, P RM 30 and the same Karma 100, the one mind shared by both forms |

As `page:name:field printed->corrected`: `31:Stygorr:E 40->20, R 30->40,
P (none)->30` (I prints 30, which is P's 30 moved left, and stays 30).

**The whole book, counted:** 9 grids, 8 cards (decision 3) and Stygorr's
human form as a block of his card (decision 4), and 3 vehicle lines of
codes, which are not characters'.

**Card pages and the chapters' grids.** Printed 4-5 and 28-32 are card
pages (`character_ranges`). Power Man's header is a third of the way down
column 2 of printed 4, after Equipping the Heroes, so the first range opens
on gear text the reader must not give a card. The Debris Creature is
statted inside Chapter 4 and the registry records it as MSL1's entry does
(`opponents`, with its `part`), printed 19. Stygorr's human form is in
`one_line_grids` in ME2's form (`entry` and `label`), and the operative is
in `tiers`, the generic type's checklist, as MLA1's and MLA3's. Which
reader takes them is *Which reader fits*.

## Names the Codex already has

Read from `apps/marvel-heroes/data/npcs.json` at `0eb32541` (1082 cards),
each the same person unless said; the grid comparisons are by the cards'
seven numbers, Health and Karma against this book's, read on the images:

| MSL2 card | already carded by |
|---|---|
| Power Man | MA4 (Fantastic Four), MHSP2 (Secret Wars II Heroes), MH4, MLA1, MLA2; every one the same grid |
| She-Hulk | MA4, MHSP2 and MH9 (each Fantastic Four), the same grid; MHSP1 and MH3 another (S 50, Health 150) |
| Blastaar | MA4 (Fiends and Foes), MH3, MHSP2; every one the same grid |
| Nick Fury | MH9 (a divergent Earth's Fury), another grid |

New: the Debris Creature, the Negalisk, Stygorr and the Typical SHIELD
Operative. No card in the Codex is a SHIELD agent, Stygorr or a Negalisk.
Each MSL2 card is a card of its own with a `-msl2` id (Nate, 2026-09-28).

## Quote marks

**The book prints single quotes of its own, but none in the text a card
takes.** Read on the images: the adventure nests a quote inside dialogue in
singles (printed 12 and 25) and quotes a map letter, `'X'`, in singles
(printed 19 and 25). Every mark inside a card's text is a double: Nick
Fury's two quoted phrases (printed 29), the Negalisk's two quoted words
(30) and Stygorr's quoted phrase (31). Tesseract reads four of the five
with a single at one end or both (a pair of singles, or a double and a
single); only one of Fury's reads as doubles. So for the
imported text MHSP1's rule fits (every single mark a misread), as it fits
MSL1 and MT3; the trial parse checks that the chain builds each of the five
as a pair of doubles (decision 8).

## Which reader fits

**Not finished.** Plan row 25c runs the trial parse and writes this
section. What it has to see, from the measurements above:

- MSL1's verdict was `grid-booklets` (`scripts/msh/gridbooks.py`) with the
  fields its reader row added, for the same three-row grid in a `parts`
  entry with `character_ranges` and `opponents`, which MSL2's entry is too.
- MSL2's grids print the labels in one order only, and no Class, Shift,
  `N/A` or FB code, so fewer of MSL1's reader fields may be needed.
- Each card's real name is a title-case line under the capitals header,
  not a `Real Name:` run-in, and no card prints an identity block.
- `KNOWN POWERS` run into the first power on four grids; She-Hulk's
  `Talents:` and `In BRIEF:` are mixed case; `IN BRIEF:` with no space
  after the colon on three.
- Stygorr's second grid has no header (decision 4) and his numbers row
  holds six numbers (the misprint above); the reader must not take it as a
  one-line grid or a welded row.
- The first character range opens on Equipping the Heroes (printed 4), and
  the Debris Creature's entry ends at a subhead, An Alien's Wrath.
- `FURY, NICK` and `TYPICAL SHIELD OPERATIVE` need their names set
  (decision 5).

## Decisions this survey leaves open

Each applied as recommended, unanswered, if Nate does not rule (Nate,
2026-10-31: take the survey's recommendations). Characters only is already
ruled (Nate, 2026-10-21), and so are second cards with `-msl2` ids
(2026-09-28) and a leading The dropped from a name (2026-10-21).

1. **Teams:** **Fantastic Four** for Power Man and She-Hulk (recommended:
   the book presents them as the team's temporary members, and the Codex
   files MA4's Power Man and She-Hulk there already, as MSL1's Player
   Characters took X-Factor and MT3's took the teams the Codex already
   has); every other card, Blastaar, Nick Fury, the Negalisk, Stygorr, the
   operative and the Debris Creature, under **MSL2 Warlord of Baluur** (as
   MSL1's and MT3's other cards under the book's title). Not taken: a team
   of their own for the roster, or SHIELD for Nick Fury and the operative,
   a team no other book files.
2. **Characters only** (recommended; Nate, 2026-10-21): no adventure,
   items, vehicles, places or maps.
3. **Every character grid with a header a card** (recommended, as MSL1 and
   MT3 decision 3): the two Player Characters, the roster's five and the
   Debris Creature, 8 in all. Not taken: the Debris Creature left in the
   chapter's text, since it is a grid with its own powers, as MT3's chapter
   creatures are cards.
4. **Stygorr's human form** (recommended): a second block of Stygorr's card
   labelled Lew Shiner, as ME2's and ME3's Beta Ray Bill (humanoid form) and
   MT2's Hamilton Slade, since it has no header, sits inside his powers,
   and his text calls it the same being's other form. Not taken: a card of
   its own for Lew Shiner, who is not a separate being in this book.
5. **Names**, title case for the capitals (recommended): Power Man,
   She-Hulk, Debris Creature, Blastaar, Negalisk, Stygorr; `FURY, NICK` as
   **Nick Fury** (the Codex's name for MH9's card, the header being
   surname-first); `TYPICAL SHIELD OPERATIVE` as **Typical SHIELD
   Operative**, keeping the acronym in capitals as the book's text prints
   it, and keeping Typical as MLA1's and MLA3's typed cards do. No header
   here starts with The.
6. **Stygorr's numbers row** as a `misprint` override, printed and
   corrected kept (recommended, as MSL1 decision 6 and MT3 decision 7): E 40 to 20,
   R 30 to 40, P none to 30, one override matching his block, since the
   codes, Health, Karma and his human form's mental numbers all agree on
   the corrected row. Not taken: the codes changed to fit the printed
   numbers (E IN, R RM), which agrees with neither total and leaves P
   empty.
7. **The three vehicle lines** (recommended): the Nuclear Warhead (printed
   16), the BRAVE and the Fist of Power (22) left in the chapters' text,
   not cards (characters only, Nate, 2026-10-21).
8. **Quote marks** (recommended): MHSP1's rule for the imported text, since
   every mark in a card's text is a double; the five quoted words and
   phrases on printed 29-31 built as doubles, with a `text` verdict for any
   the chain builds as singles. Not taken: keeping a single the chain
   makes, which would leave an unpaired mark in the Codex.
9. **The Equipping the Heroes gear** (printed 4: the antimatter harnesses,
   the gyro-homing devices, the inhibitor helmet, the stasis ray and the
   universal translator) (recommended): not imported, and kept out of Power
   Man's card by the reader (characters only). Not taken: items, which
   Nate has ruled out for now.

## How to reproduce

```bash
python scripts/msh/ocr-book.py msl2 --probe
python scripts/msh/ocr-book.py msl2
python scripts/msh/survey.py msl2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` from a worktree.
