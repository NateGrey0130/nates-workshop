# Survey: MA1 Children of the Atom (TSR6872)

Marvel Super Heroes Advanced Set, Official Guidebook to Mutants, Kim Eastland,
1986. Registry entry: `scripts/msh/books.json` -> `ma1`. Measured 2026-09-28.

**Rows citing this book:** 967 `msh_book_text` rows over 212 entries in
production (`DB_MARVEL`, read back 2026-09-28):
- 894 over 181 character entries
- 73 over 20 items and 11 adventure sections

Committed:
- 172 characters in `apps/marvel-heroes/data/npcs.json`: 174 versions, 189
  stat blocks, 7 cross-reference appearances and 434 powers, 105 of them
  linked to the Ultimate Powers Book
- 20 items in `data/items.json`
- the *Dreamchild* adventure's 11 sections in `data/adventures.json`

This is the first Marvel book surveyed, and nothing here touches the Palladium
book pipeline: the cache, the registry, the scripts and this file are all
Marvel's own (`scripts/msh/`, `.cache/msh/books/`, `apps/marvel-heroes/docs/`).

## The scan

- 103 PDF pages, a pure scan: `scripts/msh/ocr-book.py ma1 --probe` medians
  0 text-layer characters over 20 sampled pages.
- Cached with `python scripts/msh/ocr-book.py ma1`: Tesseract 5.4, `--psm 3`,
  300 dpi, TSV + text, into `$WORKSHOP_MSH_CACHE/books/ma1/` (the main
  checkout's `.cache/msh`). All 103 pages in 1m41s at 8 jobs.
- The print is clean: three columns, a wide gutter, headers in larger bold
  capitals. Tesseract reads body text and stat blocks well.
- **One page it cannot read at all: the index (PDF 5).** `--psm 3` returns
  nothing and `--psm 6` on column crops drops or garbles about a fifth of the
  lines, because of the dot leaders. The index was transcribed by eye instead
  (below).

## Offset

**printed = PDF - 2.** `scripts/msh/survey.py` reads a folio from TSV geometry
(bare digits in the bottom tenth of the page) on 85 pages; 81 of them, PDF 12-97,
all agree. The other four (PDF 10, 11, 100, 102) are OCR noise, and PDF 9 reads
folio 7 on the image. The Ultimate Powers Book has the same offset
(`scripts/msh-extract.py`).

## The book's own authority lists

- **Contents (printed p.2).** Seven sections, and fourteen teams under
  Mutant Teams. Stored as `sections` in the registry.
  **Seven entries are wrong, each by one or two pages.** Every banner through
  printed 82 was read on its page image, and these differ from the Contents:
  Hellfire Club 23 (Contents 21), Miscellaneous Mutants 50 (51), Supporting
  Characters 68 (69), Aliens 71 (72), The Mutant Menace 77 (79), Locations and
  Items 82 (83), Dreamchild 87 (88). The page wins (`contents_errata`). The
  first survey caught only the Mutant Menace. The parser found the rest,
  because a section header placed at the Contents' page cut the Brood's entry
  in half.
- **Index (printed p.3).** 183 names and 190 page references, stored as
  `index`. Seven names have two pages: Blob, Lorelei, Magneto, Quicksilver,
  Rogue, Scarlet Witch and Warlock. The index misprints Nightcrawler as
  "Nightrawler", which is kept as printed and mapped by `index_aliases`.
  Two more aliases cover names the index spells differently from the entry's
  header: Agents (VILLAINOUS AGENTS) and Neramani, Lilandra (NERAMANI,
  PRINCESS-MAJESTRIX LILANDRA).

## What an entry looks like

```
NAME (variant)                 bold capitals; the variant is mixed case
Real name / description line   "Kurt Wagner", "(real name unrevealed)"
Status line                    "Mutant hero", "Non-mutant hero (deceased)"
F  20  Ex    Health = 106      seven rows: number, then rank code;
A  50  Am                      Health, Karma, Resources and Popularity
S   6  Ty    Karma = 50        sit to the right, on rows F, S, R and P
E  30  Rm
R  10  Gd    Resources = Pr (4)
I  20  Ex
P  20  Ex    Popularity = 5
KNOWN POWERS:                  then "Italic Name: text" paragraphs
TALENTS:  CONTACTS:  RUNNING <NAME>:   run-in capitals, in this order
```

**Entries cross columns and pages.** Magneto starts on p.6 and ends
mid-column on p.7. Phoenix (original) has its stat block at the foot of
column 1 and its KNOWN POWERS at the head of column 2. So the parser must read
the book as one stream: columns left to right, then pages in order, cut at
headers. A column boundary is never an entry boundary.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `P 3000 C-3000`, `Resources = C-3000 (3000)` | Phoenix (original), p.8 |
| `Popularity = 50 to -100`, `-5 to +5` | Phoenix (original); Top Fighters, p.45 |
| `Karma = -`, `Resources = -`, `Popularity = -` | Mark I Sentinel, p.77 (robots) |
| `Resources = None` | Ursa Major's Bear Form, p.44 |
| `Popularity = 10 (60 in the Soviet Union)` | Ursa Major, p.44 |
| `Resources: Fb (2)` (a colon, not `=`) | Average Fighters, p.45 |
| rank codes `Fb`, `Po`, `Go`, `Re` | this book's misprints of Fe, Pr, Gd, Rm (`rank_aliases`) |

## Stat blocks: 188, plus one table

**The count is 188 printed grids**, plus the Further Morlocks generation table.
That is the number from the parser (below), which the first survey
undercounted. `scripts/msh/survey.py` finds 184, missing five:
- Binary's two forms, whose `Health =` OCRs as `Health " 110` and `Health 2080`
- two blocks on p.57, where its twelve-line header window lost Nekra and Nuklo
- the table, which is not a grid

The first survey's measurements are kept below as they were taken.

| measure | count |
|---|---|
| stat blocks | 184 |
| all seven ability rows readable from the OCR'd lines | 136 |
| of those, Health = F+A+S+E | 133 |
| of those, Karma = R+I+P | 128 |
| of those, every number agrees with its rank code | 133 |

**The 48 blocks with fewer than seven readable rows** are, in every one looked
at, an OCR reading-order effect and not missing data. `--psm 3` sometimes splits
the grid into a column of letters, a column of numbers and a column of codes
(the block on p.68 comes out as a run of `Ty / Gd / Ty ...` lines above its
`Health = 32`). The parser reads the grid
from TSV word geometry, keyed by row, so it does not depend on line order.

**Seven blocks fail a check.** Two are **misprints in the book**, confirmed on
the page image:

- **Northstar (p.57):** Health is printed 70, but F+A+S+E = 20+20+20+30 = 90.
- **Poltergeist (p.46):** `S 4 Ty`, but 4 is Poor, not Typical.

The other five need the image before anyone decides: Ursa Major's Human Form
(p.44), Miss Locke and Mr. Chambers (p.63), and Brood Hunter and Brood Queen
(p.72). Andreas's block on p.63 was also checked on the image, and it is
correct.

*Resolved by the parser; see [The parser](#the-parser): Human Form was an OCR
misread; Brood Hunter and Brood Queen are misprints; Miss Locke and Mr.
Chambers print Karma 0.*

## The parser

`python scripts/msh/roster.py ma1` turns the cache into entries and writes
`$WORKSHOP_MSH_CACHE/books/ma1/roster.json`. That file holds the book's prose,
so it stays in the local cache and is never committed. It exits 1 on any
failed check, any override that no longer matches exactly one block, or any
index name it cannot place. Its docstring gives the method; the short version:
- words come from TSV geometry
- columns are cut at the two least-inked gutters, and the book is read as one
  stream, so an entry never breaks at a column or a page
- headers are lines set 1.35 times the page's word height or more, in capitals
  or short title case
- each grid is re-read from a crop of the page image with `--psm 6`

**Why the grid crop.** On some blocks the page-layout pass had read the grid's
letter and number columns as sideways junk (Changeling, p.5:
`v-pDmorn DMAAMDAMAAAD`), so the numbers were not in the TSV at all. This is
part of the 48 that the survey could not read from lines. Read from the crop,
all 188 grids have all seven numbers.

Measured 2026-09-28:

| measure | count |
|---|---|
| entries | 205 (174 with a block, 31 headings and cross-references) |
| stat blocks | 189: 188 grids and the Further Morlocks table |
| pass rank, Health and Karma checks | 180 |
| explained by an override read off the page | 9: six misprints, two as printed, one table |
| failing | 0 |
| members without a block (run-in names) | 37: Gladiators 5, Savage Land Mutates 9, Imperial Guard 19, Starjammers 4 |
| powers named | 434, across 143 entries |
| index names in printed 4-81 found | 182 of 182 (the Danger Room, p.85, is phase 6) |

**Every misprint, read off the page.** Each is in
`scripts/msh/ma1-overrides.json`, with the printed value and the corrected one:

| entry | printed | the book's own arithmetic |
|---|---|---|
| Northstar, p.57 | Health 70 | F+A+S+E = 90 |
| Poltergeist, p.46 | S 4 Ty | 4 is Pr |
| Corbeau, p.69 | F 4 Fb | 4 is Pr |
| Brood Hunter, p.72 | Health 60 | F+A+S+E = 70 |
| Brood Queen, p.72 | F 30 In | 30 is Rm; Health 110 agrees with 30 |
| Nimrod, p.81 | A 50 In | 50 is Am; Health 300 agrees with 50 |
| Miss Locke, Mr. Chambers, p.63 | Karma 0 | R+I+P = 30 and 32; kept as printed, perhaps deliberate |

**Decision 1 below is taken the recommended way:** the override stores both
values. The data phase uses the corrected one for play and shows the printed
one on the Codex card.

**Alternate values in parentheses** (`S 10 Gd(30Rm)`, the book's own convention
for an altered statistic, printed p.2) are kept on the row as `alt`. So are
Class ranks (`C-1000`, `C-3000`) and Shift Y (`200 ShiftY`, Acanti).

**Resources and Popularity stay as printed**, lightly cleaned:
`Am (50) (through his agency)`, `0 on Earth (30 in the Empire)`,
`see Corsair`, `N/A`. Parsing them into a rank and a number is the data
phase's job, and no rule for it is guessed here.

## Entry kinds

Reconciling the 184 blocks against the 183 index names sorts the book into six
kinds. The survey script matches **153** index names to a block header.
Every one of the other 30, and every one of the 26 headers the index does not
name, falls under a kind below.

1. **Character.** One printed block for one being. This is most of the book.
2. **Versions.** Only two names have two printed blocks, and in both the two
   blocks are two different people: Phoenix (original, the entity, and
   current, Rachel Summers, p.8) and Thunderbird (original p.12, current
   p.29). **The seven index names with two pages are something else**, read on
   each page:
   - **An early version, given as a modifier with no block.** Magneto (p.30)
     takes -1 CS on all Magnetic and Energy Control powers and has no Power
     Stunts. Quicksilver and Scarlet Witch (p.31) are the same shape: each
     early version is described by what it lacks against the current block
     (a lower Land Speed, no Power Stunts).
   - **A cross-reference with no stats.** Blob (p.30), Rogue (p.34), Warlock
     (p.38) and Lorelei (p.66) each point to the section where the character
     is statted.

   *This paragraph quoted the book at more than ten words until the Notable
   NPCs PR, whose leak check compares every file here with the parsed text;
   it is now paraphrased.*

   So a version is either a printed block or a derived one: the character's
   block with the book's stated modifiers applied.
3. **Forms.** One character whose blocks are states of itself. These map to
   the hero snapshot's existing `forms` field, not to versions:
   - Wolfsbane: WOLF, WOLFOID (p.22)
   - Ursa Major: HUMAN FORM, BEAR FORM (p.44)
   - Living Monolith: PHASE I, II, III (p.64)
4. **Generic tier.** A reusable block for an unnamed type:
   - Operatives, Sub-Commanders, Commanders, Cybernetic Agents (p.67)
   - Top Fighters, Average Fighters (p.45)
   - Average Mutate Abilities (p.66)
   - Average Brood Member, Brood Hunter, Brood Queen (pp. 71-72)
   - Guardsman (p.73), Other Starjammers (p.76)
   - Sentinels Mark I-VI, X-Sentinels, Alpha, Omega (pp. 77-81)
5. **Member without a block.** A run-in paragraph, `AMPHIBUS: Amphibus looked
   like a large frog...`, that inherits a generic tier and changes it in
   prose ("Monstrous Leaping rank", "Amazing Strength ... a 106 Health"). None
   of these has stats of its own:
   - Savage Land Mutates (p.66): Amphibus, Barbarus, Brainchild, Equilibrius, Gaza, Lupo, Vertigo
   - Gladiators (pp. 45-46): Axe, Horns, Ivich, Lexi, Max Rocker
6. **Group heading.** An index name that points at a team or organisation,
   not at one block: Agents (printed "Villainous Agents"), Brood, Fenris (the
   twins Andreas and Andrea), Heartbreak Hotel, Imperial Guard, Morlocks,
   Savage Land Mutates, Sentinels, Shi'ar, Starjammers. And one location, the
   Danger Room (p.85).

Beyond those, three named blocks the index leaves out (Andreas, Andrea and
Licorice), and three statted beings inside another entry with no header of
their own:
- S'ym, the demon inside Magik's entry (p.19, "whose statistics are:")
- the Mark II Sentinels (p.79)
- Lang's Sentinels (p.79)

**Why the other 30 index names did not match a header**, all now accounted for:
- 12 are members without a block (kind 5)
- 10 are group headings (kind 6)
- 7 have a header the measurement did not reach: Binary, Calhoun, Nuklo,
  Cooper, Flynn, Lilandra and Ursa Major. The header is more than twelve OCR
  lines above the grid, or printed name-first ("ALEXANDER FLYNN" against
  "Flynn, Alexander"), or carries a trademark glyph ("LILANDRA (c)").
- 1 is a location, the Danger Room

Among the 153 that did match, the seven two-page names match only their
statted page. That is correct: the other page is a modifier or a
cross-reference (kind 2).

## Two sections that are not character-shaped

*These two paragraphs were written before the pages were read, with the
Contents' page numbers. Both are corrected below from the pages themselves.*

- **Items and Locations (printed 82-86):**
  - **Twenty run-in entries** (`ACID BOMB:`) under two headings, Special
    Items and Locations: 15 special items, 2 vehicles and 3 locations.
  - The vehicles (the Blackbird, the X-Factor plane) follow the run-in with
    Control:, Speed: and Body: lines.
  - The Danger Room's entry lists six kinds of event as run-ins of its own
    (Energy Weapons ... Traps), which `item_parts` in the registry names.
    It also prints rules for programming the room (floor-plate codes like
    `A1 - FLYING BOMB (Hit-Ex, Rng-4, Dam-Re)`), kept as its text.
  - No item has a stat grid; mechanics are ranks in the prose.
- **Dreamchild (printed 87-95) and maps (96-100):**
  - The adventure is **eleven sections**: an introduction, the background,
    seven numbered encounters, a floating encounter and the Federal
    Building.
  - Each section divides into run-ins (Summary, Starting, Encounter,
    Aftermath, Karma).
  - **It has no stat blocks of its own**; its opponents are the book's
    Notable NPCs.
  - One encounter title (Encounter 4) is set tall but reads as prose to the
    header test, because its apostrophe OCRs as U+FFFD, so the extractor takes
    the tall line after "Encounter N" as the title.
- Both are built by `scripts/msh/extras.py` into `data/items.json` and
  `data/adventures.json` (facts) and 73 `msh_book_text` rows (prose).

## Decisions this survey leaves open

1. **Book misprints (Northstar's Health, Poltergeist's code).** Store them as
   printed with a flag, or store the corrected value with the printed one
   kept alongside? The recommendation is corrected-plus-printed, so the GM tools
   compute with the right number and the Codex can still show what the page
   says. **Taken that way in the parser PR:** `scripts/msh/ma1-overrides.json`
   holds both, for all six misprints.
2. **Members without a block** (kind 5). Store each as a character whose
   stats are its tier's block, with the prose changes applied by hand
   (Barbarus's "106 Health" and Amazing Strength), or as a name and text under
   the tier with no stats of its own? Applying the changes by hand is a
   judgement per member, and the text says what to change.
3. **Statted beings with no header** (S'ym, Mark II and Lang's Sentinels):
   separate Codex rows, or part of the entry they sit in?
4. **Early versions given only as modifiers** (Magneto, Quicksilver, Scarlet
   Witch). Derive a version block by applying the stated modifiers, or show
   the modifier text on the main character's card with no second block? The
   plan chose "one character with versions", which fits either. Deriving one
   is a judgement where the text is loose (the Scarlet Witch's early version
   is described by attitude, not numbers). **Taken without a derived block**
   in the Notable NPCs PR: the p.30-31 text is an appearance on the card.
5. **Cross-references** (Blob p.30, Rogue p.34, Warlock p.38, Lorelei p.66):
   these carry no data, only a second team membership. The recommendation is
   to record them as a team listing on the character, not as a version.

## How to reproduce

```bash
python scripts/msh/ocr-book.py ma1
```

```bash
python scripts/msh/survey.py ma1
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from a
worktree.
