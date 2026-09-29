# Survey: ME1 Cosmos Cubed (TSR6879)

Official Advanced Game Adventure for Marvel Super Heroes, Troy Denning, 1988. Registry
entry: `scripts/msh/books.json` -> `me1`. Measured 2026-09-29.

**Rows citing this book:** none yet. This is the survey PR: a registry entry
and this file, no characters, items or D1 rows.

This is the third Marvel book. It went through `scripts/msh/` only. The two
worked examples are [ma1.md](ma1.md) and [mhsp1.md](mhsp1.md), and **this book
sits between them**: a boxed module of two booklets each numbered from 1, like
MHSP1, whose stat blocks are MA1's numbered grids.

## The scan

- 54 PDF pages, a pure scan: `scripts/msh/ocr-book.py me1 --probe` medians
  0 text-layer characters over 20 sampled pages.
- Cached with `python scripts/msh/ocr-book.py me1` into the main checkout's
  `.cache/msh/books/me1/`: all 54 pages in 1m09s.
- The print is clean. Tesseract reads the body text and the grids' lines well;
  the chapter banners are set in a textured band and are not read at all.
- **One page is set sideways:** the Pregenerated Heroes Summary (PDF 51).
  Tesseract reads it as noise, so it was transcribed by eye (below).
- The PDF was copied to `C:\Users\natha\Projects\workshop\books\`, beside
  MA1's and MHSP1's.

**The PDF is two booklets and their covers.** Recorded as `parts`:

| PDF | part | printed |
|---|---|---|
| 1 | cover | - |
| 2 | Flowchart (the Adventure Book's inside front cover) | - |
| 3-34 | Adventure Book | 1-32 |
| 35-50 | Resource Book | 1-16 |
| 51 | Pregenerated Heroes Summary (inside back cover), sideways | - |
| 52 | back cover | - |
| 53-54 | two map sheets: Attilan, and the section maps | - |

## Offset: two of them

`scripts/msh/survey.py`'s folio reader finds 33 folios:
- **24 vote printed = PDF - 2**: the Adventure Book.
- **7 vote printed = PDF - 34**: the Resource Book.
- 2 are noise: PDF 11 and the sideways Summary (PDF 51).

So the entry carries `parts` and no `offset`, as MHSP1's does, and each part
has the `cite` a card would show: `Adventure`, `Resource`,
`Pregenerated Heroes Summary`, `Flowchart`.

## The book's own authority lists

- **Two Contents**, one on each booklet's printed page 1 (PDF 3 and 35).
  Stored as `sections`, each entry with its booklet as a fourth field, since
  printed pages repeat (1-16 in both). **Every entry was read on its page
  image, and all agree** - unlike MA1's seven wrong ones. The chapter banners
  were checked from a strip of each page's top, and Chapter 10's from its
  mid-page band (printed 20).
- **No index.** The Resource Book's Contents names every character it stats,
  one line each, so it is that booklet's checklist. The Adventure Book's
  Contents names its four non-pregenerated heroes. Neither names the
  opponents statted inside the chapters (below).
- **The Pregenerated Heroes Summary (PDF 51)** lists 8 heroes, each with seven
  ranks (number and code), Health, Karma, powers and talents. **Transcribed by
  eye** from a render turned 90 degrees and stored as `reference_summary`.
  Four of its rows (Mantis, Gladiator, Firelord, Beta Ray Bill) have a full
  block in the Adventure Book. **The other four - Nova, Thor, the Silver
  Surfer and Doctor Strange (printed "Doc Strange") - are statted only here.**

## What an entry looks like

```
GRANDMASTER                    bold capitals (mixed case for a chapter's
En Dwi Gast                    opponent); then an identity line
F  10 Gd     Health: 80        MA1's seven rows of number then rank code,
A  20 Ex                       with MHSP1's colon labels to the right on
S  20 Ex     Karma: 190        rows F, S, R and P
E  30 Rm
R 100 Un     Resources: Un (100)
I  40 In
P  50 Am     Popularity: 0
KNOWN POWERS:                  then italic "Name:" run-ins, some bulleted
TALENTS:  CONTACTS:  BACKGROUND:   run-in capitals, in this order
```

Three columns a page, headers above the grid. A Resource Book page holds one
to three entries; an entry can run into the next column and onto the next
page (the Collector starts on printed 8 and ends on 9).

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `500 Shift` on one line and `Z` on the next | Contemplator (Resource p.13), Possessor (p.14), Astronomer (p.16) |
| `1000 Cl 1000`, `5000 Cl 5000`, `A 2 Fe` | Ego, Resource p.10 |
| `F 275 Shift Y`, a number inside the rank's range (176-350), not its standard 200; Health 575 uses the 275 | Superkree, Adventure p.15 |
| `Resources: Cl1000 (1000)` | Trader, Resource p.16 |
| `Resources: Feeble 2` (the word, no parentheses) | Typical Oolafat, Adventure p.11 |
| `Resources: N.A.` | Ego; Sentry 9168 (Adventure p.28) |
| `Reason, Intuition, Psyche: Linked to Ego` in place of three rows, Karma 0 | Typical Oolafat, Adventure p.11 |
| `Popularity: 0 (And dropping)`; `Popularity: -20`, `-50` | Superkree; Maximus (Resource p.7); Ghoul Captain (Adventure p.12) |
| `MANTIS (Update)`, a header with a mixed-case qualifier | Adventure p.3 |

**Quote marks.** The book sets its double quotes as two single marks, and
Tesseract reads them as a pair of singles (`''Superkree's Curse''`, Adventure
p.15; the Runner's speech, Resource p.12, both read on the page image). **No
single-quoted phrase of its own was found** among the OCR's candidates, so
the rule is MHSP1's: every single mark that is not an apostrophe is half of a
double. The data PR must confirm that on its pages before relying on it.

## Stat blocks: 33 full grids, plus 8 Summary rows

Found by a scratch reader of the OCR's lines (not committed), and every block
it could not read cleanly was read off a crop of the page image:

| where | blocks |
|---|---|
| Adventure Book, the non-pregenerated heroes (printed 3-6) | 4: Mantis, Gladiator, Firelord, Beta Ray Bill |
| Adventure Book, inside the chapters | 7: Typical Oolafat (p.11), Ghoul Captain (p.12), Superkree (p.15), Common Inhuman (p.18), Garnet Cato and Claud Victor (p.27), Sentry 9168 (p.28) |
| Resource Book, How to Use this Book (printed 2-3) | 2: Typical Skrull Warrior, Typical Kree Warrior (Blue or Pink) |
| Resource Book, Inhumans (printed 4-7) | 9: Black Bolt, Medusa, Crystal, Gorgon, Karnak, Triton, Lockjaw, Maximus, Alpha Primitives |
| Resource Book, Elders (printed 8-16) | 11: Collector, Grandmaster, Ego, Champion, Runner, Gardener, Contemplator, Possessor, Obliterator, Astronomer, Trader |
| **total** | **33** |

| measure | count |
|---|---|
| full grids | 33 |
| Health = F+A+S+E | **33** |
| Karma = R+I+P, or explained below | **33**: 31 hold; the Oolafat prints no R, I or P; the Ghoul Captain prints 0 |
| every number within its rank code's range | 32; the Ghoul Captain's Agility is not |
| Summary rows | 8 |
| of those, pass their own arithmetic | 7 |
| of the 4 with a block, agree with it in all nine values | 3 |

**The misprints, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Ghoul Captain, Adventure p.12 | `A 50 Mn` | 50 is Am; Health 400 = 150+50+100+100 agrees with 50 |
| Ghoul Captain, Adventure p.12 | Karma 0 | R+I+P = 300; perhaps deliberate, as MA1's Miss Locke and Mr. Chambers print 0 |
| Collector, Resource p.8 | the last row is labelled `R` | it is P: Karma 130 = 50 + 30 + 50 |
| Summary, Firelord | Karma 90 | his own chart row sums to 110, and his block (Adventure p.5) prints 110 |

The Typical Oolafat's Karma 0 is not a misprint: its text links its mind to
Ego's.

`survey.py`, unchanged, finds **1** block in this book, and it is not one. It
keys on `Health =`, and this book prints `Health:`, as MHSP1 does.

## The parser dry run

`python scripts/msh/roster.py me1 --failures`, run from a scratch copy of the
registry with `columns` 3, the section labels above, MA1's `rank_aliases`,
and one booklet at a time: `offset` 2 with `character_pages` [3, 6], then
`offset` 34 with [2, 16]. `roster.py` is unchanged in this PR, and the
`roster.json` each run wrote was deleted afterwards.

| measure | Adventure p.3-6 | Resource p.2-16 |
|---|---|---|
| stat blocks found | 4 of 4 | 22 of 22 |
| blocks passing every check | 3 | 12 |
| entries | 4 | **1** |
| exit | 1 | 1 |

**MA1's grid reader nearly fits,** which MHSP1's did not: every grid is found
by its rows, and 15 of 26 read cleanly. The failures, measured:

1. **Headers are not tall enough.** Measured on the TSV, headers box at 38-39
   px against a body height of 32, a ratio of 1.19-1.22, and `is_header` wants
   1.35. So the Resource Book's 22 characters merge into one entry. That wants
   a per-book header ratio (the marvel-book skill's rule), not a looser global
   one.
2. **Rank codes the grid crop misses.** Ten Resource grids and Mantis come back
   with one to three codes unread, four of them outright unreadable: the
   Contemplator's, Possessor's and Astronomer's Shift ranks set across two
   lines, and Ego's `Cl 1000`. Every one reads
   correctly on the image.
3. **Two numberings.** The same as MHSP1, and `parts` already solves it for
   `booklet.py`; `roster.py`'s MA1 path reads one `offset`.

## Entry kinds

1. **Character with a full block.** 33, including the generic tiers below.
2. **Character with a Summary row only.** 4: Nova, Thor, the Silver Surfer and
   Doctor Strange. Seven ranks, Health, Karma, and the chart's power and
   talent names with their ranks; no Resources, Popularity or prose.
3. **Generic tier.** A block for an unnamed type: Typical Skrull Warrior,
   Typical Kree Warrior, Typical Oolafat, Common Inhuman, Alpha Primitives.
4. **A chapter's opponent.** Statted where the heroes meet it, with no Contents
   line: the Ghoul Captain, the Superkree, Garnet Cato, Claud Victor and
   Sentry 9168, plus the Oolafat and the Common Inhuman above. These are the
   only blocks the Contents does not name.
5. **An update.** Mantis's block is headed `(Update)`, under the
   introduction's Updates note (printed 3).
6. **Characters in the prose only.** Uatu the Watcher runs the adventure and
   has a section of his own (Adventure p.8) with no block; the Supreme
   Intelligence and Galactus are named, not statted.

## What is not character-shaped

- **The adventure is chaptered,** as MA1's *Dreamchild* is: 16 chapters and
  an Epilogue (Adventure printed 9-32), each opening with a banner. The OCR
  finds 17 `SUMMARY:`, `STARTING:`, `ENCOUNTER:` and `AFTERMATH:` run-ins and
  16 `KARMA:`; the seventeenth reads as mixed case (Chapter 9's awards,
  printed 20), to read on the image in the data PR.
- **The chapters branch.** The Flowchart (PDF 2) orders them as a graph, not
  a line: a chapter's AFTERMATH names the next one, sometimes one of two.
- **The introduction** (Adventure printed 2-8): the Judge's Summary, the
  Rollcall (whose heading Tesseract does not read), an Updates note, the four
  non-pregenerated heroes, Cosmic Indifference, Running a
  Cosmic Adventure, Uatu, and the Kree Cosmic Cube - the adventure's item.
- **A statted vehicle in prose:** the Ancient Skrull Saucer-Ship (Chapter 1,
  printed 9) prints Body, Control, Speed, Protection and Shields as lines.
- **Maps** (PDF 53-54): Attilan, and the section maps named in the Contents.
  Not text.
- **The Resource Book's introductions** to the Skrulls and the Kree (printed
  2-3) and to the Inhumans and the Elders are prose around the blocks.

## Decisions this survey leaves open

1. **Page citations.** Recommendation: MHSP1's shape, the part's cite plus the
   printed page: `ME1 Adventure p.5`, `ME1 Resource p.10`, and
   `ME1 Pregenerated Heroes Summary` with no page.
2. **The four Summary-only heroes** (Nova, Thor, the Silver Surfer, Doctor
   Strange). Recommendation: cards marked Summary-only, as MHSP1's seven are.
3. **The misprints.** Recommendation: MA1's override shape for all four,
   printed and corrected, with the Ghoul Captain's Karma 0 kept as printed
   (`as_printed`) unless the text says otherwise, as MA1's two Karma 0 blocks
   were.
4. **Teams.** Recommendation: the book's own divisions - `Inhumans`,
   `Elders of the Universe`, `Skrulls`, `Kree` - and `Cosmos Cubed Heroes`
   for the eight pregenerated and non-pregenerated heroes. The chapters'
   opponents file under the book's title, the rule for a book with no team
   section. None of these names is taken by MA1 or MHSP1.
5. **The reader.** The grid is MA1's and the numbering is MHSP1's.
   Recommendation: MA1's path in `roster.py`, taught `parts` and a per-book
   header ratio behind the registry, with MA1's output proved byte-identical
   (the skill's rule), rather than a third reader. The alternative, teaching
   `booklet.py` numeric grids, moves MHSP1's reader instead.
6. **The adventure.** Recommendation: the 16 chapters and the Epilogue as the
   adventure's sections with their run-ins, as *Dreamchild*'s are; the Kree
   Cosmic Cube as an item; the Saucer-Ship as a vehicle. The flowchart's
   branches as data is a later question.
7. **Two characters already have cards:** Gladiator (MA1, p.73) and Thor
   (MHSP1's Reference Summary). By #1520's rule each becomes a second card
   with a `-me1` id. Listed so nobody is surprised.

## The next PRs

1. **Parser (`msh/feat/me1-parser`):** `roster.py` reads `parts` and a
   per-book header ratio; the grid crop reads two-line Shift ranks and Class
   ranks; the Resource Book's Contents and the Summary are the checklists.
   Expected: 33 blocks plus 8 Summary rows, every one passing or explained by
   an override, and MA1 and MHSP1 byte-identical.
2. **Data (`msh/data/me1-cosmos-cubed`):** the characters, the adventure's 17
   sections, the Cube and the Saucer-Ship, applied to production before the
   merge, and the Rows line above filled in.

## How to reproduce

```bash
python scripts/msh/ocr-book.py me1
```

```bash
python scripts/msh/survey.py me1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from a
worktree.
