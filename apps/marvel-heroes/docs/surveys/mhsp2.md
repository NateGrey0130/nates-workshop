# Survey: MHSP2 Secret Wars II (TSR6869)

Marvel Super Heroes special module. Registry entry: `scripts/msh/books.json`
-> `mhsp2`. Measured 2026-10-21.

**Rows citing this book:** 0 `msh_book_text` rows. Nothing is imported yet:
this is the survey, with no data and no parser.

This is one of the five books registered together by the kickoff PR (#1917).
It goes through `scripts/msh/` only. **It is MHSP1's sequel, and the same kind
of object:** a boxed module of booklets each numbered from 1, a Roster Book
whose blocks print rank words and no numbers, and a Reference Summary chart.
So [mhsp1.md](mhsp1.md) is the nearest worked example, and this file follows
its order. **Its Roster Book is not set as MHSP1's**: three columns and no
heavy rule, `Known Powers` with run-ins ending in a colon, a `RUNNING <NAME>:`
note inside each entry (MA1's shape, not MHSP1's separate booklet), and team
banners.

Characters only (Nate, 2026-10-21): the adventure is not imported, and
neither are items or places, even where they have entries.

## The scan

- 70 PDF pages, a pure scan, already cached by the kickoff PR into the main
  checkout's `.cache/msh/books/mhsp2/` (`manifest.json`: 300 dpi, `--psm 3`,
  Tesseract 5.4.0, written 2026-10-21).
- Tesseract reads the Roster Book's label lines and headers well; 96 of 98
  headers carry the trademark sign and read with it. It reads none of the
  Reference Summary in order, which was transcribed by eye (below).

**The PDF is two booklets, a folder and three maps.** Recorded as `parts` in
the registry:

| PDF | part | printed |
|---|---|---|
| 1 | Module cover | - |
| 2-33 | Campaign Book | 1-32 |
| 34-65 | Roster Book | 1-32 |
| 66 | Module back cover | - |
| 67 | Reference Summary (a two-page spread on one PDF page) | - |
| 68-70 | Maps 1-3 | - |

## Offset: two of them

`scripts/msh/survey.py`'s folio reader (TSV geometry):
- **26 pages vote printed = PDF - 1**: PDF 4-33, the Campaign Book.
- **20 vote printed = PDF - 33**: PDF 43-64, the Roster Book.
- 4 are noise, each read on its image: table references at the foot of PDF 7
  and 10, the Summary's numbers (PDF 67) and a map label (PDF 68).

The Roster folios Tesseract missed (printed 2-9, 13, 20 and 32) were read on
their page images. As in MHSP1, the entry carries `parts` with a `cite` each
(`Campaign`, `Roster`, `Reference Summary`) and no `offset`.

## The book's own authority lists

- **No Contents and no index** in either booklet.
- **Team banners** in the Roster Book, recorded as `teams` in the registry
  (`[printed page, first entry's header, team]`, the code-grids form, because
  three teams start mid-page): The X-Men (4), The New Mutants (7), The
  Avengers (10), The Fantastic Four (12), The West Coast Avengers (14), Power
  Pack (16), Defenders (17), Heroes and Others (19), The Bad Guys (24),
  Nebula's Crew (25), The Bad Guys again (25, from the Skrulls), And of Course
  (32). **No banner is printed over printed 2-3** (the Beyonder, Mephisto,
  Eternity, Death). Nebula's Crew is a sub-heading below Nebula's own entry;
  the Skrulls after the crew are not under it. Kingpin's Organization (26)
  heads five tiers inside the Kingpin's page, not a run of entries.
- **The Reference Summary (PDF 67)** is the nearest thing to an index: one
  undivided chart of 65 rows in the Roster Book's order, from the Beyonder to
  the Molecule Man. **Transcribed by eye** from 170 dpi renders and stored as
  `reference_summary`, all 65 under `heroes` because the chart has no second
  list. It leaves out every entry of The Bad Guys (printed 24-31) and Volcana.
  Three power names were shortened so that no ten words of a row run as the
  page does (the entry's note says which).

## What an entry looks like

```
CYCLOPS(tm)                  bold capitals with a trademark sign
<identity line>              real name
Fighting:    EXCELLENT       seven rows: label, then a rank NAME;
...                          no numbers anywhere in the block
Health:      76              Health, Karma, Resources, Popularity
Karma        80              Karma often printed WITHOUT a colon
Resources:   ...
Popularity:  ...
Known Powers:                then run-ins ending in a COLON (not MHSP1's
                             period), Talents:, and RUNNING <NAME>: in the entry
```

Three columns a page, no heavy rule on any of the 31 Roster pages. The
Beyonder (printed 2) prints four states, each a full block.

**Values the parser must accept as printed:**

| printed | where |
|---|---|
| `BEYOND`, `NOT APPLICABLE`, `NONE` (Shift 0) as ranks or Health | the Beyonder's states, printed 2 |
| `UNLIMITED` | Health or Karma of the cosmic entries, printed 2-3 |
| `Health: 60 (145)` as the OCR reads it: the other form's value after the first | Colossus, printed 5 |
| a header read without its trademark sign (`COLOSSUS"`, `ROSE"`) | printed 5, 26 |
| `Fighting TYPICAL`, read with no colon | Wolfsbane 9, Gee, Lightspeed and Mass Master 16, Rose 26 |
| a one-line grid: `F A S E R I P` over seven two-letter codes, then `Health = n Karma = n` or `Health: n` | *Stat blocks* below |

**Rank spellings.** The Roster Book spells ranks in full capitals (with
`EXCELENT` aliased too), the Summary abbreviates them to four letters (`Feeb` ... `Unea`,
`C1000`, `Beyo`), and the one-line grids use two-letter codes in capitals
(`FB`, `PR`, `TY` ... `UN`). All three sets are in `rank_aliases`.

## Stat blocks: 90 full, 21 one-line, 65 summary rows

**87 characters in 90 full blocks** (the Beyonder's four states), all in the
Roster Book. Where each is, from the headers in the cache's OCR:

| printed | entries |
|---|---|
| 2 | The Beyonder (4 blocks: original, human, transition and final states) |
| 3 | Mephisto, Eternity, Death |
| 4 | Cyclops, Professor X, Magneto |
| 5 | Colossus, Rogue, Wolverine |
| 6 | Nightcrawler, Shadowcat, Phoenix II |
| 7 | Sunspot, Warlock, Magma |
| 8 | Cannonball, Karma, Mirage |
| 9 | Wolfsbane, Magik, Cypher |
| 10 | Captain Marvel, Captain America, Black Knight |
| 11 | Hercules, Starfox, Sub-Mariner |
| 12 | Wasp, She-Hulk |
| 13 | Mister Fantastic, Invisible Woman, Human Torch |
| 14 | Wonder Man, Hawkeye, Tigra |
| 15 | Mockingbird, Iron Man |
| 16 | Gee, Lightspeed, Mass Master, Energizer, Tattletale |
| 17 | Angel, Beast, Iceman |
| 18 | Gargoyle, Valkyrie, Andromeda |
| 19 | The Thing, Thor, Beta Ray Bill |
| 20 | Dazzler, Power Man, Iron Fist |
| 21 | Spider-Man, Cloak, Dagger |
| 22 | Daredevil, Lila Cheney, Firelord |
| 23 | Time Bomb, Puma, The Watcher |
| 24 | Armidillo, Thundersword, Kurse |
| 25 | Nebula |
| 26 | Kingpin, Rose |
| 27 | Psycho-Man, Hate-Monger, Juggernaut |
| 28 | Rhino, Electro, Vulture, Ultron |
| 29 | Doctor Octopus, Kraven, Titania |
| 30 | Absorbing Man, Blastaar, Wizard |
| 31 | Doctor Doom, Sentinels |
| 32 | Molecule Man, Volcana |

**21 one-line grids:** 20 in the Roster Book and one in the Campaign Book.

| where | grid |
|---|---|
| Roster 9 | Wolfsbane's wolf form, and her wolfoid transition form |
| Roster 18 | Aragorn, Valkyrie's steed |
| Roster 19 | Beta Ray Bill's humanoid form |
| Roster 24 | Boromir, Thundersword's mount |
| Roster 25 | Nebula's Crew: Kehl, Levan, Gunthar, Skunge; then the Skrulls (a typical warrior) and General Zedrao |
| Roster 26 | Kingpin's Organization, five tiers: Henchmen, Enforcers, Hit Men, Undercover Agents, Middle Management (Health, no Karma) |
| Roster 27 | Psycho-Man's suit, Earth-sized and giant-sized versions (four physical codes) |
| Roster 32 | Volcana's normal form |
| Campaign 25 | a lesser demon |

**The book checks itself, on each rank's standard number** (`ranks.json`
`standard`, as MHSP1's blocks are checked):

| measure | count |
|---|---|
| full blocks passing Health and Karma | **76** |
| full blocks printing no number to check (`BEYOND`, `NOT APPLICABLE`, `UNLIMITED`) | 5 |
| full blocks failing | 9: eight Karma misprints and Wolfsbane |
| one-line grids failing | 2, both Karma misprints |

**Ten Karma misprints**, each read on its page image. The second number is
what the block's own ranks give:

| entry | page | printed | ranks give |
|---|---|---|---|
| Rogue | Roster 5 | 54 | 58 |
| Phoenix II | Roster 6 | 90 | 115 |
| Karma | Roster 8 | 111 | 101 |
| Tattletale | Roster 16 | 91 | 101 |
| Iceman | Roster 17 | 30 | 20 |
| Firelord | Roster 22 | 90 | 110 |
| Time Bomb | Roster 23 | 22 | 16 |
| Skunge (one-line) | Roster 25 | 30 | 20 |
| General Zedrao (one-line) | Roster 25 | 30 | 60 |
| Juggernaut | Roster 27 | 30 | 20 |

**Wolfsbane (Roster 9) is printed that way on purpose**, not a misprint: her
block's Health 50 is the wolf form's (the wolf grid's physical ranks give 50),
with her human Karma 24.

**The Reference Summary agrees with the Roster Book** in every value of all 65
rows, but four:
- **the Beyonder's Health**;
- **Colossus, Sunspot and Puma**, where the chart prints the other form's
  ranks.

So the chart repeats the Roster's Karma misprints rather than correcting
them (Rogue 54, Phoenix 90, Karma 111 and the rest), and cannot settle one.

## Which reader fits

Measured by row 1a of the 2026-10-21 Marvel books plan, on a scratch copy of
`scripts/msh` with `layout: roster-booklet` set in memory and nothing written
to the cache. **`booklet.py` (MHSP1) is the only reader that reads this
book's grids, and it does not fit as it stands.**

- **`roster.py` (MA1), `gridbooks.py` (ME1) and `codegrids.py` (MA4)** are
  ruled out by the grid: this book prints rank words and no numbers.
  `roster.ROW`, which `gridbooks.py` and `codegrids.py`'s `read_entries` path
  also use, matches 0 of the 90 `Fighting` lines; `codegrids.ROW` wants a code
  then a number per lettered row.
- **`booklet.py` as is** exits 1 at `booklet.unpaired`, on 5 pieces, before
  any count.
- **Read past that stop** (in the driver only): 4768 stream lines, 98 entries
  (91 entry, 7 team), 95 blocks (81 full, 14 one-line), 12 failing on unread
  ranks; 79 of 81 full blocks pass Health. `booklet.coverage()` then raises
  `IndexError`: 5 Summary rows match an entry with no block (Gee, Lightspeed,
  Mass Master, Cloak, Puma). 60 of 65 rows match an entry with a block, none
  unmatched.

What the parser row has to change, each measured on the stream:
1. **Karma with no colon** (85 lines): `STAT_LINE` wants punctuation, so
   `full_grid` stops at Karma, and Karma, Resources and Popularity read None
   on all 81 full blocks. Every Karma check passes vacuously.
2. **`Known Powers:` (91 lines) and run-ins ending in a colon (339 lines):**
   `SECTION_LINE` knows only Powers, Talents and Background, and `POWER_HEAD`
   wants a period, so 0 powers are read. `roster.py`'s `SECTION` and
   `POWER_HEAD` have both shapes. `Talents:` is read (34 entries).
3. **`RUNNING <NAME>:` inside each entry** (89 run-in lines):
   `booklet.running()` reads another booklet; `roster.section_of()` is the
   shape that fits.
4. **Quote marks.** MHSP1's rule that any single mark is a double quote is
   false here: **this book prints apostrophes of its own** (elisions such as
   a dropped `and` or a decade). The 5 pieces that stop the build
   (Nightcrawler, Sub-Mariner, Tigra, Andromeda, Puma) hold those turned into
   double quotes, beside real double quotes.
5. **9 of 90 full grids are not attached to an entry** (81 read). 96 of 98
   headers carry the trademark sign, so `is_header()` finds them; height
   alone would not (median 1.23 times the body, 2 over `roster.py`'s 1.35).
6. **Kingpin's Organization**'s five tiers read as 5 one-line grids with every
   rank unread, and printed 32 ends in 4 garbage headers (a list of names
   read as capitals).

`rules()` finds no heavy rule on any of the 31 Roster pages, which is
harmless. So the parser row is the second PR, as the skill sets out for a new
layout: teach `booklet.py` these things behind the registry, or give the book
a reader of its own, and prove MHSP1's outputs byte-identical. This survey
sets no `layout`: that is the parser's choice.

## Entry kinds

1. **A character with a full block:** 87, above. The Sentinels and the Skrulls
   are types (one block for many).
2. **A character in several states, each a full block:** the Beyonder (4).
3. **Forms.** In parentheses inside one block (Colossus); as a one-line grid
   inside the entry (Wolfsbane's wolf and wolfoid, Beta Ray Bill's humanoid
   form, Volcana's normal form, Psycho-Man's two suits).
4. **A crew under one entry, each a one-line grid:** Nebula's Crew (Kehl,
   Levan, Gunthar, Skunge), the Skrulls' General Zedrao.
5. **Tiers of an organisation:** Kingpin's five, with a Health and no Karma.
6. **Steeds:** Aragorn and Boromir, one-line grids inside their riders'
   entries.
7. **A Campaign Book opponent:** the lesser demon (Campaign 25), the one block
   outside the Roster Book.

## Names the Codex already has

By the rule #1520 pinned (Nate, 2026-09-28), each is a card of its own with a
`-mhsp2` id. Many of this book's characters share a name with an MA1, MHSP1,
MA4 or ME1 card (the X-Men, the Fantastic Four, Magneto, Doctor Doom, the
Molecule Man, Volcana and others), and some with one of the books registered
alongside it. Listed only so that nobody is surprised by the pairs.

## Open questions

These are Nate's.

1. **A team for the four entries on Roster pp.2-3 that print no banner** (the
   Beyonder, Mephisto, Eternity, Death). The options: the book's title, **MHSP2
   Secret Wars II**, as the skill says for a book with no team sections; or a
   team named for the book's cosmic cast. The recommendation is the book's
   title.
2. **The team names that collide.** A team name is a filter group shared by
   every book (MHSP1's sides became "Secret Wars Heroes" and "Secret Wars
   Villains" for that reason). **"The Bad Guys"** is printed twice (24, and
   again from the Skrulls on 25 after Nebula's Crew), and is the kind of
   generic name another book's villains would share. **"The Avengers"** is
   the group every later book's Avengers would join, and sits beside "The
   West Coast Avengers". The banners also print a leading "The" where
   MA1's and MA4's groups do not (`X-Men`, `New Mutants`, `Fantastic Four`),
   so taken as printed they make second filter groups for the same teams.
3. **Whether to import the Campaign Book's lesser demon** (Campaign 25), the
   one block outside the Roster Book: a one-line grid with a Health, inside
   the adventure, which is not imported.
4. **How to record the ten Karma misprints.** MHSP1's Summary misprints went
   to `scripts/msh/mhsp1-overrides.json` with `printed` and `corrected`; here
   the misprints are in the blocks themselves and the chart repeats them.
   The recommendation is the same override shape, read off each page, with
   Wolfsbane's wolf-form Health as `as_printed`.

## The next PRs

1. **Parser:** the six changes above, behind the registry; expected 90 full
   blocks and 21 one-line grids (or 20, by question 3), every Health and
   Karma passing or explained by an override, 65 of 65 Summary rows placed,
   and MHSP1's outputs byte-identical.
2. **Data:** `npcs.py mhsp2`, the rows of `msh_book_text`, this file's Rows
   line and `node scripts/sourcebooks.mjs`.

## How to reproduce

```bash
python scripts/msh/survey.py mhsp2
```

Set `WORKSHOP_MSH_CACHE` to the main checkout's `.cache/msh` when running from
a worktree. The page lists above were read off the cache's OCR headers and
`Fighting` lines; the misprints and the Summary off the page images.
