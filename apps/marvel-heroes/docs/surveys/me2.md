# Survey: ME2 Ragnarok and Roll (TSR6880)

Official Advanced Game Adventure for Marvel Super Heroes, Troy Denning, 1988.
Registry entry: `scripts/msh/books.json` -> `me2`. Measured 2026-10-21.

**Rows citing this book:** 273 `msh_book_text` rows over 36 character entries
in production (`DB_MARVEL`, read back 2026-10-21); the other four, Nova,
Thor, the Silver Surfer and Doc Strange, are on the Summary alone and print
no text.

Committed: 40 characters in `apps/marvel-heroes/data/npcs.json` (33 full
grids, Actus, Charon and Modgud from the chapters' one-line grids, and the
four Summary-only heroes), with 222 powers, 94 of them linked to the Ultimate
Powers Book, read by the `grid-booklets` layout. The chapter's Titans and
powerless Zeus are second blocks on their Resource Book cards, and Beta Ray
Bill's humanoid form a form on his. No items, no places and no adventure.

This is the eighth Marvel book, and the fifth of the five registered together
by the kickoff PR (#1917). It goes through `scripts/msh/` only. **It is laid
out as ME1 is**, the module before it in the same series: a boxed module of an
Adventure Book and a Resource Book, each numbered from 1, whose blocks are
MA1's numbered grids. [me1.md](me1.md) is the nearest worked example, and
`grid-booklets` (`scripts/msh/gridbooks.py`) the nearest reader. **What differs
from ME1** is listed under *Which reader fits*.

Characters only (Nate, 2026-10-21): the adventure is not imported, and
neither are items or places, even the two craft with stat lines of their own
(below).

## The scan

- 53 PDF pages, a pure scan, already cached by the kickoff PR into the main
  checkout's `.cache/msh/books/me2/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, written 2026-10-21).
- The print is clean. Tesseract reads the body text and the grids well. It
  does not read the chapter banners (lettering in a textured band) or the
  Contents' dot leaders, and it lost two character headers outright (below).
- **One page is set sideways:** the Pregenerated Heroes Summary (PDF 51).
  Tesseract reads it as noise, so it was transcribed by eye (below).

**The PDF is two booklets, their covers and one map sheet.** Recorded as
`parts`:

| PDF | part | printed |
|---|---|---|
| 1 | cover | - |
| 2 | Map of the Nine Worlds (the Adventure Book's inside front cover) | - |
| 3-34 | Adventure Book | 1-32 |
| 35-50 | Resource Book | 1-16 |
| 51 | Pregenerated Heroes Summary (inside back cover), sideways | - |
| 52 | back cover | - |
| 53 | the map sheet: Asgard: The Continent and Olympus, side by side | - |

The Adventure Book's Contents names a Map of Asgard and a Map of Olympus on
the map sheet; the scan has one sheet page carrying both.

## Offset: two of them

`scripts/msh/survey.py`'s folio reader finds 33 folios:
- **26 vote printed = PDF - 2**: the Adventure Book.
- **7 vote printed = PDF - 34**: the Resource Book.
- None votes otherwise.

So the entry carries `parts` and no `offset`, as ME1's does, with the same
`cite`s: `Adventure`, `Resource`, `Pregenerated Heroes Summary`.

## The book's own authority lists

- **Two Contents**, one on each booklet's printed page 1 (PDF 3 and 35),
  transcribed from the page images (the OCR mangles the dot leaders and five
  Resource names). Stored as `sections`, each entry with its booklet as the
  fourth field.
- **Every Contents entry was checked on its page, and all agree**: the
  Introduction and the 20 chapter banners and the Epilogue (from a strip of
  each page), the four Resource Book section banners (The Entities 2, The
  Olympians 6, The Asgardians 10, The Heliopolitans 16), and each
  character's header on its printed page.
- **The Adventure Book's Contents prints `Pregenerated Heroes:` as a heading
  with no page**, over Beta Ray Bill (4), Firelord (5), Gladiator (6) and
  Mantis (7). ME1 called the same four "Non-pregenerated Heroes". So the
  registry has no null-subsection line for it.
- **The Resource Book's Contents inverts some names**: `Chimaera, The`,
  `Fenris Wolf, The`, and the four types as `Olympian, Typical`, `Rock Troll,
  Typical`, `Asgardian, Typical`, `Frost Giant, Typical`. The headers print
  `CHIMAERA`, `The FENRIS WOLF`, `OLYMPIAN, Typical`, `Typical ASGARDIAN`. The
  registry keeps the Contents as printed; matching them is the parser's job.
- **No index.** The Resource Book's Contents names every character it stats,
  one line each (29), so it is that booklet's checklist. The Adventure Book's
  names its four heroes. Neither names the opponents statted inside the
  chapters (below), which the registry lists as `opponents`.
- **The Pregenerated Heroes Summary (PDF 51)** lists 8 heroes, each with seven
  ranks (number and code), Health, Karma, powers and talents. **Transcribed by
  eye** from a render turned 90 degrees and stored as `reference_summary`.
  **It is ME1's chart again, value for value**: the same eight heroes, ranks,
  Health, Karma and power names, Firelord's misprinted Karma 90 included.
  Four rows have a full block in the Adventure Book; **Nova, Thor, the Silver
  Surfer and Doctor Strange ("Doc Strange") are statted only here.**

## What an entry looks like

ME1's, line for line: a bold capital header, an identity line in bold mixed
case (`Galan of Taa`), MA1's seven rows of number and rank code with
`Health:`, `Karma:`, `Resources:` and `Popularity:` to the right on rows F,
S, R and P, then `KNOWN POWERS:` with italic run-in powers, and `TALENTS:`,
`CONTACTS:`, `BACKGROUND:` as run-in capitals. Three columns a page, one to
three entries a page.

Run-ins inside an entry that are not sections, counted on the OCR of the
character pages: `WEAKNESS:` 12 times, `WEAKNESSES:`, `LIMITATION:`,
`LIMITATIONS:` (2), `WEAPON:`, `WEAPONS:`, `ITEMS:` and `IMPORTANT:`.
`gridbooks.py` already files these under the entry's notes.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `F 5000 Cl 5000` on all seven rows, `Health: 20,000` with a comma, `Karma: Unlimited`, `Resources: Unlimited`, `Popularity: -1000` | Death, Resource p.2 |
| `Cl 1000`, `Cl 3000` and `Cl 5000` rows | Death, Galactus, Gal, Ac, Tus, Hela (E 1000) |
| `500 Sh Z`, a two-letter Shift code | Gladiator's E and P, Adventure p.6 |
| `R 2 Fb` and `Resources: Fe(2)`, two spellings of Feeble in one block | Typical Rock Troll, Resource p.12 |
| numbers inside a rank's range, not its standard: `25 Ex`, `250 Shift Y` | Gal, Ac, Tus, Cerberus, Chimaera, Hydra, Pluto, Titans, Zeus (below) |
| `Resources: Cl` / `1000` and `Resources: Shift` / `X(150)`, wrapped onto a second line | Ac, Tus; Osiris |
| `Resources: N.A.` | Gaea, Cerberus, Hydra, the Fenris Wolf, Garm |
| a negative Popularity, `-5` to `-1000`, the minus read as a dash or a dash pair | Death, Galactus, Gal, Ac, Tus, Cerberus, the Chimaera, Hydra, Pluto, the Fenris Wolf, Garm and others |
| `MANTIS (Update)` | Adventure p.7, as in ME1 |
| a one-line grid of codes only, inside an entry | Beta Ray Bill's humanoid form, Adventure p.4 |

## Stat blocks: 33 full grids, 5 one-line grids, 8 Summary rows

| where | blocks |
|---|---|
| Adventure Book, Pregenerated Heroes (printed 4-7) | 4: Beta Ray Bill, Firelord, Gladiator, Mantis |
| Resource Book, The Entities (printed 2-5) | 6: Death, Gaea, Galactus, Gal, Ac, Tus |
| Resource Book, The Olympians (printed 6-9) | 9: Ares, Cerberus, the Chimaera, Hercules, Hydra, Pluto, Titans, Zeus, Typical Olympian |
| Resource Book, The Asgardians (printed 10-15) | 12: Balder, the Fenris Wolf, Garm, Geirrodur, Typical Rock Troll, Hela, Loki, Muspelheim Demon, Sif, Typical Asgardian, Ymir, Typical Frost Giant |
| Resource Book, The Heliopolitans (printed 16) | 2: Osiris, Isis |
| **full grids** | **33** |

**One-line grids inside the chapters (5)**, each the seven letters, a row of
numbers, a row of codes, then `Health:` and `Karma:` on lines of their own:

| name | printed | chapter | Health | Karma |
|---|---|---|---|---|
| Actus (Ac and Tus added together) | 16 | 7 | 2600 | 2250 |
| Titans (the two tormenting Zeus) | 18 | 8 | 350 | 60 |
| Zeus, powerless in Hades | 18 | 8 | 151 | 56 |
| Charon | 18 | 8 | 270 | 140 |
| Modgud | 21 | 10 | 205 | 175 |

**None has a name line above it.** Each is introduced in the chapter's prose,
and the grid follows the sentence that names it. Charon and Modgud are statted
only here; Actus is the merged form of two Resource Book entries; the Titans
and Zeus here are second blocks beside their Resource Book entries (Titans
Health 600 there, Zeus 1100), different numbers on purpose.

**One grid of codes only:** Beta Ray Bill's humanoid form (Adventure p.4),
`Ex Ex Ex Ex Rm Ex Am`, Health 80, Karma 100, inside his entry.

**The book checks itself.** Every full grid was read by a trial run of
`gridbooks.py` (*Which reader fits*) and every value below by its own
arithmetic; each block the run could not read cleanly, and each one-line
grid, was read on a crop of the page image.

| measure | count |
|---|---|
| full grids, Health = F+A+S+E | **33 of 33** |
| full grids, Karma = R+I+P, or explained | **33**: 32 hold; Death prints `Karma: Unlimited` (his R, I and P are 5000 each) |
| one-line grids, Health and Karma both hold | **5 of 5** (Beta Ray Bill's form, on standard numbers, too) |
| every number within its rank code's range | **32 of 33** blocks; the Chimaera's A and E are not |
| Summary rows passing their own arithmetic | 7 of 8 (Firelord's Karma) |
| Summary rows with a block, agreeing with it in all nine values | 3 of 4 (Firelord's Karma) |

**The misprints, each read on the page image:**

| entry | printed | the book's own arithmetic |
|---|---|---|
| Chimaera, Resource p.7 | `A 100 Shift X` and `E 100 Shift X` | 100 is Unearthly (Shift X is 126-175); Health 950 = 500+100+250+100 agrees with the 100s |
| Summary, Firelord | Karma 90 | his chart row sums to 110, and his block (Adventure p.5) prints 110; ME1's chart has the same misprint |

**Numbers inside a rank's range, not its standard,** printed on purpose and
used by the Health or Karma: `25 Ex` (Gal's, Ac's and Tus's F and A),
`250 Shift Y` (Gal R and I; Ac S, I and P; Tus S, R and P; Cerberus F, A and
E; the Chimaera S; Hydra S; Pluto E; the Titans E; Zeus F and A).
Twenty-three rows over nine blocks. ME1 had one (the Superkree's 275) and kept it by an
override; that many here wants the check to read a rank's range rather than
an override each (decision 3).

**Actus adds up from its parts**, value for value: Ac's and Tus's grids sum to
F 50 Am, A 50 Am, S 500 Z, E 2000 Cl 1000, R, I and P 750 Z, Health 2600,
Karma 2250. That grid prints a bare `Z` for Shift Z, in `rank_aliases`.

`survey.py`, unchanged, finds **0** blocks in this book. It keys on
`Health =`, and this book prints `Health:`, as ME1 does.

## Which reader fits

**`grid-booklets` (`scripts/msh/gridbooks.py`), with things taught to it.**
Measured, not argued: a scratch copy of `scripts/msh/` at `origin/main`
(`92528fc3`) with this entry plus `"layout": "grid-booklets"` and trial
`teams`, run on a copy of the cache under its own `WORKSHOP_MSH_CACHE`.
`roster.py me2` exits 1:

| measure | trial |
|---|---|
| entries | 39: 35 with a block, 4 without (the three section banners and a stray `1000`) |
| stat blocks | 37: 33 grids and the 4 chart-only heroes |
| blocks passing every check | 28 |
| failing | 9, all on the rank-range check above (8 in range, the Chimaera's misprint) |
| Contents names with no entry | 6: Gal, Chimaera, Balder, Fenris Wolf, Typical Asgardian, Ymir |
| opponents with no entry | 3 of 5: Actus, Charon, Modgud (Titans and Zeus matched their Resource entries) |
| Health or Karma not a number | 2: Death's `Unlimited`, and Galactus's Karma welded to the next row |
| Summary | 8 of 8 placed; Firelord's Karma flagged |

What the parser row needs, all behind the registry, with ME1's `roster.json`,
`book-text.sql` and `npcs.json` rows proved byte-identical before and after:

1. **Two headers Tesseract lost.** `BALDER` (Resource p.10) and `YMIR`
   (p.15) are printed, plainly, on the page images, and are in neither the
   TSV nor the text. So Balder's block lands in the section banner's entry
   (`The Asgardians`), and Ymir's in the Typical Asgardian's. A registry list
   of headers to place above a grid, in the way MA4's `grid_headers` does.
2. **Gal's header** (Resource p.4, top of the third column) is not split from
   Galactus's entry, so Gal's grid is read as a second Galactus block.
3. **The Contents' inverted names** (`Chimaera, The`, `Fenris Wolf, The`,
   `Asgardian, Typical`) against the headers as printed.
4. **The chapters' one-line grids, which have no name line.** ME1's opponents
   are full grids under a name; these are found by `Health:` but there is no
   header to take. A registry field giving each grid's name by page and
   order, or its first line, like MH2's nameless grid.
5. **Death's `Karma: Unlimited`**, and Galactus's Karma line, which the
   column cut welds to his `I` row. ME1 asserts that every Health and Karma
   is a number (`gridbooks.coverage`); Death's is not, by design.
6. **The rank-range check** (decision 3), and Beta Ray Bill's codes-only form
   grid (decision 5).

The other readers do not fit: `roster.py` (MA1) reads one offset, not two
booklets; `codegrids.py` (MA4) reads a code before the number; `booklet.py`
(MHSP1) and `coverpanels.py` (MH1, MH2) read rank words with no numbers.

This survey sets no `layout`, as ME1's did not: that is the parser's choice.
It does write `character_ranges`, `opponents` and `roster_sections`, which
`grid-booklets` reads and which are measurements of the book, and no `teams`
and no Summary `team` (decision 1).

## Entry kinds

1. **Character with a full block.** 33, including the types below.
2. **Character with a Summary row only.** 4: Nova, Thor, the Silver Surfer and
   Doctor Strange, as in ME1.
3. **Generic type.** Typical Olympian, Typical Rock Troll, Typical Asgardian,
   Typical Frost Giant, the Muspelheim Demon; the Titans block is two named
   beings (Coeus and Crius) under one grid.
4. **A chapter's opponent with a one-line grid** and no header: Charon and
   Modgud.
5. **A merged form**: Actus, Ac and Tus added together (printed 16), whose
   text says he has the powers of both. Gal, Ac and Tus are Galactus split in
   three, each a Resource entry of its own.
6. **A second block for a Resource character**, in a chapter: the Titans and
   the powerless Zeus (printed 18).
7. **A form inside an entry**: Beta Ray Bill's humanoid form (printed 4).
8. **An update**: Mantis's block is headed `(Update)`, as in ME1.
9. **Characters in the prose only**, named and not statted: Odin, Surtur,
   Eternity, Uatu the Watcher, Karnilla and others.
10. **Two craft with stat lines**, out of scope by Nate's ruling: the canoe
    Uatu provides (Body, Control, Speed, Protection and Shields, printed 8)
    and the Olympian ships (printed 27).

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with
a `-me2` id:

- **All eight heroes are ME1's**, and the four with a block print ME1's
  numbers (checked against `npcs.json`): Beta Ray Bill, Firelord, Gladiator,
  Mantis, Nova, Thor, the Silver Surfer, Doc Strange. Several are in other
  books too (Thor in MHSP1 and MHSP2, Firelord in MA4 and MHSP2, Gladiator
  in MA1, the Silver Surfer in MA4, Beta Ray Bill in MHSP2).
- Galactus (MHSP1, MA4), Death (MHSP2) and Hercules (MHSP2).
- **MA1's Fenris is a different being**: the von Strucker twins, not the
  Fenris Wolf.

Every other name is new to the Codex.

## Quote marks

No single-quoted phrase of the book's own was found. Measured on the OCR of
all 53 pages: 237 double marks and 24 opening single marks. None of the 24
is on a character page (Adventure 4-7, Resource 2-16): they are on the
sideways chart and the map, which are noise, and in the chapters' prose.
The three read in context (printed 16 and 17) are opening double marks read
as singles. So the rule looks like MHSP1's and ME1's (every single that is
not an apostrophe is half of a double), and **the data row must confirm it on
the opponents' pages** before relying on it. Apostrophes after a name ending
in s (`Galactus'`, `Osiris'`) are real.

## Decisions this survey leaves open

For Nate. Each has a recommendation.

1. **Teams.** Recommendation: the Resource Book's own banners without the
   leading The, as MHSP2's were (Nate, 2026-10-21): **Entities**,
   **Olympians**, **Asgardians**, **Heliopolitans**, none of them a group yet;
   the eight heroes as **Ragnarok and Roll Heroes**, as ME1's are Cosmos
   Cubed Heroes; Actus under Entities; Charon and Modgud under the book's
   title, **ME2 Ragnarok and Roll**, ME1's rule for a chapter's opponent. The
   alternative for the heroes is to file both books' eight under one shared
   group. Not written to the registry until decided.
2. **Page citations.** Recommendation: ME1's shape, `ME2 Adventure p.4`,
   `ME2 Resource p.10`, and `ME2 Pregenerated Heroes Summary` with no page.
3. **The twenty-three in-range numbers.** Recommendation: teach the check a rank's
   range (`ranks.json` `min` and `max`) for a book that prints them, so a
   number in range passes and the card shows it as printed; the alternative
   is an override per block, as ME1's Superkree has.
4. **The misprints.** Recommendation: overrides keeping printed and corrected:
   the Chimaera's two codes corrected to Unearthly (the numbers are what the
   Health adds), Firelord's chart Karma to 110, and Death's `Karma:
   Unlimited` kept as printed (`as_printed`).
5. **The second blocks and the form.** Recommendation: the chapter's Titans
   and powerless Zeus as second blocks on the Resource Book's cards, and Beta
   Ray Bill's humanoid form as a second block on his, each labelled; Actus
   an entry of his own; Charon and Modgud entries of their own.
6. **The four Summary-only heroes.** Recommendation: cards marked
   Summary-only, as ME1's four are.

## The parser and the data (done 2026-10-21)

The parser (#1928) taught `gridbooks.py` this book and wrote
`scripts/msh/me2-overrides.json`, with decisions 2, 4 and 6 as recommended.
Decision 3 went the other way for now: the in-range numbers are `as_printed`
overrides, one per block, as ME1's Superkree's is, and the Codex says each is
inside its rank's range.

`python scripts/msh/npcs.py me2` writes the 40 characters and 273 rows of
`msh_book_text`, applied to production before the merge. Nate's answer to
decisions 1 and 5 (2026-10-21) is in the registry: `teams` as recommended
(Actus, alone on Adventure p.16, is an Entity; Charon and Modgud file under
ME2 Ragnarok and Roll), and a new `second_blocks` field, read only for a
grid-booklets book, makes the chapter's Titans and Zeus labelled second
blocks ("Tormenting Zeus in Hades", "Powerless in Hades") on their Resource
Book cards, so the GM picks either; the Titans' three run-in powers there go
to D1 as the card's powers 9-11, named for the block. Two readings were
added to `npcs.py`: a minus read as a hyphen beside a dash (the Fenris Wolf's
Popularity -5) and a header printed with a trailing comma (`MUSPELHEIM
DEMON,`, read on the page image). Every earlier book's `npcs.json` rows and
`book-text.sql` were built with `origin/main`'s scripts and the branch's and
compared byte for byte: identical.

## How to reproduce

```bash
python scripts/msh/survey.py me2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page images were rendered from the PDF with PyMuPDF at 30-170
dpi into the scratchpad, never into the repo, and the trial parse wrote its
`roster.json` into a scratch copy of the cache, never the main checkout's.
