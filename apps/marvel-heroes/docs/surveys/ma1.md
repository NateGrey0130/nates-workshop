# Survey: MA1 Children of the Atom (TSR6872)

Marvel Super Heroes Advanced Set, Official Guidebook to Mutants, Kim Eastland,
1986. Registry entry: `scripts/msh/books.json` -> `ma1`. Measured 2026-09-28.

**Rows citing this book:** none yet. The first rows land with the Notable NPCs
section (phase 4 of the plan below).

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
  **One error:** it puts The Mutant Menace at 79, but the banner is on printed
  77, above the Sentinels that the index also puts at 77. The page wins
  (`contents_errata`).
- **Index (printed p.3).** 183 names and 190 page references, stored as
  `index`. Seven names have two pages: Blob, Lorelei, Magneto, Quicksilver,
  Rogue, Scarlet Witch and Warlock. The index misprints Nightcrawler as
  "Nightrawler", which is kept as printed and mapped by `index_aliases`.

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

## Stat blocks: 184

`scripts/msh/survey.py ma1` finds one `Health =` line per stat block, and
**184** of them. That number is the target every later step is held to.

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
     Stunts. Quicksilver and Scarlet Witch (p.31) are the same shape: "the
     early version of Quicksilver should move at Incredible Land Speed, have
     no Power Stunts...".
   - **A cross-reference with no stats.** Blob (p.30, "can be found in that
     section"), Rogue (p.34), Warlock (p.38), Lorelei (p.66, "See her
     description in the Brotherhood of Evil Mutants section").

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

- **Locations and Items (printed 83-87):** the X-Men mansion, its Danger Room
  and special items; the banner art shows aircraft. Not yet read closely.
  Phase 6 surveys this section before choosing a parser mode.
- **Dreamchild (printed 88-95) and maps (96-100):** a mini-adventure "for
  four or five medium-level characters", in numbered encounters. Not yet read
  for statted NPCs.

## Decisions this survey leaves open

1. **Book misprints (Northstar's Health, Poltergeist's code).** Store them as
   printed with a flag, or store the corrected value with the printed one
   kept alongside? The recommendation is corrected-plus-printed, so the GM tools
   compute with the right number and the Codex can still show what the page
   says.
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
   is a judgement where the text is loose ("often attributed her powers to
   magic").
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
