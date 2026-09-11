# Rifts World Book 15: Spirit West — survey

Slug `spirit-west`. Cached 2026-08-28 from `Rifts- World Book 15 Spirit West.pdf`,
210 PDF pages, **text layer** (median ~5,468 chars/page — no OCR, no cost).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

Surveyed 2026-09-10. The cache was **re-run through `ocr-book.py` first**, which
skipped all 210 cached pages and recomputed the manifest's `welded_pages`,
`corrupt_pages` and `substituted_digits` keys — none of the three existed when
this book was cached. All three are non-empty. Read *Pages that need a render*
before extracting anything.

## Page offset

**Read from `scripts/books.json`; not re-derived.**

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. No `page_offset_exceptions`.
`printed_pages: 208`, and `ocr-book.py` agrees: last printed folio 208, cache
`p001`-`p210`.

Checked in passing rather than assumed: the Tribal Warrior's section heading,
which the Contents puts on printed 37, is on cache `p038`, and the Wendigo's
heading, printed 127, is on cache `p128` with folio 127 at its foot.

## Pages that need a render

`ocr-book.py` reports one welded page, eight glyph-corrupt pages and 85 pages
with a letter in a digit slot.

| cache | printed | fault | matters? |
|---|---|---|---|
| `p202` | 201 | WELDED | no — the Iron Bear's introduction and plate, which carry no figure. **This row said "the War Chief's second page" until the vessel import**; the War Chief's stat block is all on printed 200 |
| `p052` | **51** | GLYPHS (1) | **yes** — Plant Shaman O.C.C. abilities |
| `p085` | **84** | GLYPHS (1) | **yes** — fetish general rules |
| `p106` | **105** | GLYPHS (1) | **yes** — the Turtle, Whale and Wolf totems |
| `p194` | **193** | GLYPHS (1) | **yes** — Thunderbird Assault Robot |
| `p123` | 122 | GLYPHS (2) | no — Stone Giant / Teepowka, both NPC |
| `p127` | 126 | GLYPHS (1) | no — the Wendigo's lore page, before its stat block |
| `p135` | 134 | GLYPHS (1) | no — lesser spirits, NPC |
| `p004` | 3 | GLYPHS (1) | no — credits page |

**`substituted_digits` covers 85 pages and it reaches STARTING MONEY.** Every
O.C.C. in this book prints its trade-goods allowance as `2D6xlOO` or `3D6xlOO`,
and printed 44 prints the Totem Warrior's P.P.E. as `!D4xlO+P.E.`.
`BOOK-INGEST-AUDIT` F53: the fault is in the ink, a render does not cure it, and
each token is read as the only dice expression it can be — `2D6x100`,
`1D4x10`.

**Cache `p046` (printed 45) is empty**, inside the Spirit Warrior's range.
Render it during that class's batch rather than assuming it is a plate.

## The book's authority tables

| printed | table | states |
|---|---|---|
| **7** | the experience tables | the playable roster, and which classes share a ladder |
| **72** | the shaman spell index | every shaman spell's name, P.P.E. cost and **spell level**, twice — once alphabetically by page, once grouped by level |
| **3-5** | Contents and Quick Find | section ranges |

**The spell index is printed twice on one page and each description repeats
both figures.** Every spell has an alphabetical entry carrying its cost, a
by-level entry carrying its cost and level, and a stat block carrying a
`P.P.E.:` line and a `Level:` line. That is four readings of each cost and two
of each level, so the spell import is a reconciliation, not a transcription.
`book-survey` §4b.

**The experience tables are NOT the roster, and this book is the third to prove
it.** Printed 7 prints ladders for Great Little Ones, Two-Faced Star People,
Man-Monsters, Man-Eagles, Stone Giants and Black-Winged Monster Men, and says
the Ukt Water Serpent uses the dragon table — and every one of those entries is
tagged NPC on its own heading line (below). `new-west` recorded the same trap.
Playability here is stated **per entry**, on the tag line beside the name.

## Inventory

Counted by structure over all 210 cached pages, not by reading prose.

| section | printed | what is there |
|---|---|---|
| front matter, setting, tribes, factions | 1-36 | narrative; printed 33-35 list existing O.C.C.s suited to traditional characters and define none |
| **Warrior O.C.C.s** | **36-47** | **4 classes** |
| **Shaman O.C.C.s** | **48-69** | **7 classes**, plus shaman blessings and fetish creation rules |
| Bad Medicine | 70-71 | shaman rules, prose |
| **Shaman spells** | **72-82** | index + **34 invocations**, levels 1-13 |
| **Fetishes** | **82-94** | ~45 magic items in four tiers — minor, major, tattoo, legendary — **none priced** |
| **Totems** | **94-105** | rules + **48 totem animals**, each with skills, bonuses and Totem Warrior powers |
| Monsters | 106-127 | 11 entries; **one playable** (Wendigo, 126-128) |
| Spirits | 128-171 | lesser and greater spirits, all NPC |
| Gods | 172-188 | 7 entries, all NPC |
| **Robots and power armor** | **189-203** | **6 vessels**, none sold on any market |
| **Weapons of Note** | **203** | 2 bows, arrowheads, bow prices, 2 vibro weapons |
| Preserves | 204-208 | setting |

### Categories this book defines ZERO of

- **Psionic powers.** No `I.S.P.` stat-block section anywhere; the `I.S.P.`
  lines are pool lines inside class and creature entries. **No psionic
  import.**
- **Skills.** No new-skills section and no `Base Skill:` definition. The
  percentage pairs the scan finds all sit inside class abilities (Spirit Warrior
  realm senses, Elemental Shaman senses), totem skills or creature abilities.
  **No skills import** — but the class batches must still run `class-check
  --remote`, because Triax proved a class can grant a catalog-absent skill the
  book never calls new.
- **Spells outside printed 72-82.** The `P.P.E. Cost:` lines on printed 125-189
  are creature and god abilities.
- **Rifts Skill List re-citations.** None of that phantom book's 34 rows is
  defined here; `trap construction` and `locate secret compartments` appear only
  inside skill lists.

## Classes

### Playable O.C.C.s (11) — printed 36-69

| class | printed | ladder (p.7) |
|---|---|---|
| Tribal Warrior O.C.C. | 37-39 | own |
| Mystic Warrior O.C.C. | 39-41 | shared with Animal and Plant Shaman |
| Totem Warrior O.C.C. | 42-44 | shared with Great Little Ones (NPC) |
| Spirit Warrior O.C.C. | 44-47 | shared with Two-Faced Star People (NPC) |
| Plant Shaman O.C.C. | 50-53 | shared with Animal Shaman and Mystic Warrior |
| Animal Shaman O.C.C. | 53-56 | shared with Plant Shaman and Mystic Warrior |
| Mask Shaman O.C.C. | 56-60 | shared with Fetish Shaman and Man-Monsters |
| Healing Shaman O.C.C. | 60-62 | own |
| Paradox Shaman O.C.C. | 62-65 | own |
| Elemental Shaman O.C.C. | 65-67 | own |
| Fetish Shaman O.C.C. | 67-69 | shared with Mask Shaman and Man-Monsters |

Each entry opens with its abilities and ends in the stat block —
`Attribute Requirements` through `Cybernetics` — on the last page or two of its
range. **The `Money:` line is prose in every one**: trade goods worth `2D6x100`
or `3D6x100` credits. That is coin-equivalent and goes in `starting_money`.

`occ_group`: the four warriors are `men-of-arms`, the seven shamans `magic`.
Both are among the five legal values, so the Underseas substitution is not
needed.

**No id collides.** Production holds `noro-mystic-warrior`, `warrior-monk` and
three other `*-warrior` ids; none of this book's eleven. `mystic-warrior` and
`shaman` alone are free, but prefer the book's full names.

### Playable R.C.C. (1)

| class | printed | ladder (p.7) |
|---|---|---|
| **Wendigo R.C.C.** | 126-128 | own |

Tagged on its own heading as **NPC and optional R.C.C.**, and it names the five
O.C.C.s a player Wendigo may take. Its mega-damage pool is P.E. times a
multiplier plus a die per level — `mdc_base` — and its S.D.C. therefore needs no
`CORE_SDC_BY_CLASS` entry.

### Not classes

- **Kachina Dancer (printed 143-145).** The Quick Find files it under the
  shaman O.C.C.s, marked special. The entry itself says the Dancer's level is
  the character's first O.C.C.'s and its powers do not count as a shaman
  O.C.C. — a role layered on an existing class, with no ladder on printed 7. Not
  imported.
- **Printed 33-35** lists existing O.C.C.s (Wilderness Scout, Vagabond,
  Bandit, and others) as suitable for traditional characters, with equipment
  substitutions. It defines none.

### NPC-only, by the book's own per-entry tag

Monsters, printed 106-127: Black-Winged Monster-Men, Man-Eagles, the Animal,
Plant and Spirit Man-Monsters, Plumed Serpent, Stone Giant, Teepowka,
Two-Faced Star-People, Ukt Water Serpent. Printed 134 states outright that
spirits are not recommended as player characters, and every spirit entry
(printed 128-171) and every god (172-188) carries an NPC tag.

## What the classes will need

**Totems — `BOOK-INGEST-AUDIT` F56.** Nine of the eleven O.C.C.s must pick one
of 48 totem animals (printed 96-105), and the Elemental Shaman picks one of four
elements instead. A totem grants skills and bonuses to the character, plus
giant-form powers to the Totem Warrior alone. Abilities can carry bonuses but
not skills, and the table would have to be repeated in every class that uses
it. Each class records the pick in prose and cites the finding.

**Fetishes are starting equipment.** The warriors and shamans start with one or
more minor and major fetishes of choice. Import the fetish rows **before** the
classes, so the equipment lines have rows to point at.

**Spells the catalog does not hold.** The Paradox Shaman draws on the temporal
spells of Rifts England, which the catalog does not hold — the Time Master
precedent from `phase-world` batch 9: grant the half that exists and say so. The
Elemental Shaman's elemental spells are the Conversion Book's list, and the
catalog holds the Book of Magic warlock rows (`Air:`, `Earth:`, `Fire:`,
`Water:`). Check that they are the same spells at class time rather than
assuming it.

**Several shamans may also learn Ley Line Walker spells.** Printed 72 notes it;
each class states the terms.

## Catalog diff

Run against **production** (`--remote`). Catalog at survey time: 250 classes,
371 skills, 739 spells, 116 psionic powers, 1349 gear, 158 vehicles. **No row in
any of the five catalogs cites this book.**

### spells: 34 missing, 0 false gaps

`catalog-diff --remote --table spells --compare level,ppe` over the 34 index
entries returns **matched 0, disagree 0, missing 34**.

Every nearest candidate was checked and none is the same spell: `Ears of the
Wolf` against RUE's `Eyes of the Wolf` (distance 2), `Contact Spirits` against
`Commune with Spirits`, and `Dowsing` against the warlock's `Earth: Dowsing` and
`Water: Dowsing` — a different tradition at a different cost, and no bare
`Dowsing` row exists for this one to collide with.

**No name prefix.** These are leveled invocations, like the Book of Magic's, and
no name collides. A prefix would not keep them out of other casters' pickers
either: spells carry no category, so a class whose pool is a level range already
admits every leveled spell from every tradition — `BOOK-INGEST-AUDIT` F57. The
shaman grants are explicit name lists, which work unprefixed.

### gear, printed 203: diffed by name

| the book prints | the catalog holds | action |
|---|---|---|
| NA-LB1 Laser Bow | — | new |
| NA-SW4 M.D.C. Bow | — | new; the M.D.C. arrows are a second row |
| Vibro-Axe or Tomahawk | — | new |
| Vibro-Spear | — | new |
| 7 of 9 high-tech arrowheads | `arrowhead-*`, Triax p.150 | **none** — already held |
| Neural Disrupter and Tracer Bug arrowheads | — | new |
| Smoke arrowhead, **80** credits | `arrowhead-smoke`, **60**, Triax | not overwritten; the disagreement goes in `cost_note` |
| short, long, modern bows and crossbows, in credits | `short-bow` / `long-bow` / `cross-bow`, Palladium Fantasy, in gold | new Rifts rows — a gold price is not a credit price |

### vessels: 6, none priced

Uktena Combat Robot (189), Thunderbird Assault Robot (192), Wolf Assault Robot
(194), U.S.A. SAMAS (197), War Chief (199-200), Iron Bear (201-202). **This
said the War Chief ran onto welded page 201; it does not** - printed 201 is the
Iron Bear's introduction and plate, and the War Chief's stat block is entirely
on printed 200. Each `Market Cost:` line says the machine is not sold outside the
preserves, and most give a figure it **would** sell for. Following `underseas`,
an estimate is not a price: `cost` stays NULL and the figure goes in
`cost_note`.

### fetishes: ~45, none priced

Printed 82-94. A fetish is a shaman-made magic item with no market, so each row
is `gear` category `magic` with a NULL `cost` and a `cost_note` saying so. That
is the existing convention: 61 of the catalog's 235 `magic` rows are unpriced,
and every one of the 61 carries a `cost_note`.

## Extraction plan

1. **Shaman spells, printed 72-82** — 34 rows at their printed levels, each cost
   reconciled across its four readings. One PR.
2. **Fetishes, printed 82-94** — ~45 `gear` rows, `magic`, unpriced. One PR,
   before the classes.
3. **The four warriors, printed 36-47.** One PR.
4. **Plant, Animal, Mask and Healing Shaman, printed 50-62.** One PR.
5. **Paradox, Elemental and Fetish Shaman, printed 62-69, and the Wendigo,
   126-128.** One PR.
6. **Weapons of Note, printed 203, and the six vessels, printed 189-203.** One
   or two PRs.

What is deliberately left, with the reason for each:

- **The 48 totems as catalog rows** — F56; each class carries the pick in prose.
- **The Kachina Dancer** — a role on top of an O.C.C., not an O.C.C.
- **Every NPC monster, spirit and god, printed 106-188** — the book tags each
  one NPC.
- **Setting: history, tribes, factions, the Spirit Realm, the preserves** —
  narrative.
- **The Mask Shaman's masks and the shamans' blessings and Bad Medicine** —
  class abilities, stored on the classes that have them, not catalog rows.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-28 | [#400](https://github.com/NateGrey0130/nates-workshop/pull/400) | cached (210 pp, text layer), registered in `books.json`, offset +1 verified |
| 2026-09-10 | [#934](https://github.com/NateGrey0130/nates-workshop/pull/934) | cache re-run for `welded_pages`/`corrupt_pages`/`substituted_digits`; survey written; no data shipped. Filed `BOOK-INGEST-AUDIT` F56 and F57 |
| 2026-09-10 | [#935](https://github.com/NateGrey0130/nates-workshop/pull/935) | Shaman spells, printed 72-82: **34 rows** at their printed levels, unprefixed (spells 739 -> **773**). 33 of 34 agree across all four cost readings; Nose of the Wolf's stat block prints 4 against the index's 6, confirmed in the ink, 6 stored. Applied `--remote` before the PR. |
| 2026-09-10 | [#936](https://github.com/NateGrey0130/nates-workshop/pull/936) | Fetishes, printed 85-94: **46 `magic` gear rows** - 18 minor, 18 major (three tattoos), 10 legendary (gear 1349 -> **1395**). None priced and none given a price; each `cost_note` cites printed 84. Landed before the classes so their starting-fetish lines have rows to point at. Applied `--remote` before the PR. |
| 2026-09-10 | [#937](https://github.com/NateGrey0130/nates-workshop/pull/937) | The four warriors, printed 36-47: **Tribal, Mystic, Totem and Spirit Warrior** (classes 250 -> **254**), plus **W.P. Tomahawk** (skills 371 -> **372**) - the one skill this book grants that the catalog lacked, which the survey's zero-skills count could not see. Four `CORE_SDC_BY_CLASS` entries at 3D6. Every totem pick is prose citing F56. Applied `--remote` before the PR. |
| 2026-09-10 | [#938](https://github.com/NateGrey0130/nates-workshop/pull/938) | Shamans 1 of 2, printed 48-62: **Plant, Animal, Mask and Healing Shaman** (classes 254 -> **258**). The first consumers of the #935 spells: Plant and Animal pick five of their own Shamanistic spells at level 1 and get the rest at level 2, then one a level from the book's list; the Healing Shaman's master psionics run a 33-entry schedule. Printed 51 is glyph-corrupt and its hit point multiplier was read off a render (P.E. x5). Three `CORE_SDC_BY_CLASS` entries at 1D6; the Plant Shaman states its own. Applied `--remote` before the PR. |
| 2026-09-10 | [#939](https://github.com/NateGrey0130/nates-workshop/pull/939) | The last four classes: **Paradox, Elemental and Fetish Shaman** (printed 62-69) and the **Wendigo R.C.C.** (printed 126-128) (classes 258 -> **262**). **ALL TWELVE PLAYABLE CLASSES ARE IN.** The Paradox Shaman is granted the five Paradox spells and draws on a 35-spell list; the Rifts England temporal spells it may also take are not held (the Time Master precedent). The Elemental Shaman picks one element as its totem; its three starting Warlock spells are offered from all four elements with a note, because a pick cannot be tied to the element chosen. The Wendigo's M.D.C. line prints `P.E.xS` and was read off a render as P.E. x5. Three `CORE_SDC_BY_CLASS` entries at 1D6. Applied `--remote` before the PR. `regression.mjs` failed twice with "cannot build a database": the bootstrap build now takes 251 s and the harness kills it at 180 s - filed as `BOOK-INGEST-AUDIT` F58, not fixed here; the pins were verified by one run with the timeout raised in the working tree only. (The CI regression job builds the same database in 18 s and passed this PR unmodified - the 251 s is this machine, under load; see F58's correction.) |
| 2026-09-10 | [#940](https://github.com/NateGrey0130/nates-workshop/pull/940) | Weapons of Note, printed 203: **13 gear rows** (gear 1395 -> **1408**) - the two Modern Indian bows and the NA-SW4's M.D.C. arrows, two new arrowheads, six bows and crossbows priced in credits, and two vibro weapons; seven arrowheads already held from Triax were not duplicated, and the smoke arrowhead's 80 credits went in `cost_note` beside Triax's 60. Vessels, printed 189-202: **6 vehicles, 60 M.D.C. locations, 32 weapon entries** (vehicles 158 -> **164**), none priced. **THE BOOK IS FULLY IMPORTED.** Applied `--remote` before the PR. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-09-10, before any import:
`spirit-west` has no line, because **no row cites it**.

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs             6   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs            2   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

None of these is this book's. This is the baseline the imports are measured
against: a line that moves after a Spirit West PR is that PR's.

**After the last PR, 2026-09-10:**

```
  spirit-west        112 / 0
```

112 is exactly what shipped - 12 classes, 34 spells, 1 skill, 59 gear rows
(46 fetishes and 13 Weapons of Note) and 6 vessels - and every one is
traceable. **Every BACKLOG line is unchanged from the baseline above**, which is
the answer to "did we finish?": no row from this book landed as a stub, and no
spell without text.

The `NO PRICE` counters did not move either (gear 29, vessels 0), although
46 fetishes and 6 vessels have no `cost`. That is correct rather than missed:
every one of them carries a `cost_note` saying why, and those counters count
unpriced rows with nothing said.

## The book is fully imported

| what | printed | rows | PRs |
|---|---|---|---|
| Shaman spells | 72-82 | 34 | #935 |
| Fetishes | 85-94 | 46 | #936 |
| Warrior O.C.C.s, and W.P. Tomahawk | 36-47 | 4 classes, 1 skill | #937 |
| Shaman O.C.C.s | 48-69 | 7 | #938, #939 |
| Wendigo R.C.C. | 126-128 | 1 | #939 |
| Weapons of Note | 203 | 13 | #940 |
| Robots and power armor | 189-202 | 6 vehicles, 60 locations, 32 weapons | #940 |

**Still open, and none of it this book's to fix:** `BOOK-INGEST-AUDIT` F56
(the totem table nine classes carry as prose), F57 (level-gated spell pools
admit every tradition). F58 (the regression harness's local timeout) was taken
in PR #942 - the timeout now says it is one; the 180 s limit stays.
