# Rifts World Book 29: Madhaven — survey

Slug `madhaven`. Cached 2026-09-24 from
`974230361-Rifts-World-Book-29-Madhaven.pdf`, 136 PDF pages, **text layer**
(no OCR). `--probe` median 4,786 chars/page, 36.8% stop words, so this is a real
text layer and not the glyph-dropped kind (`BOOK-INGEST-AUDIT` F73).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on four pages rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p024` | 23 | +1 |
| `p078` | 77 | +1 |
| `p100` | 99 | +1 |
| `p129` | 128 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 128.**
`ocr-book.py` wrote 99 into the manifest, which is a max-folio misread. The
registry outranks the manifest. Cache `p130`-`p135` are house ads and an order
form, and `p136` is the back cover.

## Cache health

| key | pages | where it matters |
|---|---|---|
| `welded_pages` | 113, 130, 132, 133 | **cache p113 = printed 112**, the Beautiful Ghost / Harmful Ghost stat blocks. Read it from a render. The other three are ads |
| `corrupt_pages` | 28, 64, 75, 96 (one hit each) | p064 = Dyno-Men, p075 = Quill Men, p096 = Devil Kraken. Render and read their numbers |
| `substituted_digits` | 26 pages | classes, monsters and ghosts all carry `lD6`, `I D4x l O` and `3 1` for 31. **Read the ink the way the dice have to read.** A render does not fix it |

`read-columns.py` crashes on this book when it prints to a cp1252 console (a
`\x9d` byte on printed 27). Read the cache files, or set
`PYTHONIOENCODING=utf-8`.

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-5** (cache p005-p006) | *Contents* and *Quick Find Table* | page of every class, gear item, monster and ghost |
| **60** | Haven Mutants as NPCs / as Player Characters | all eight mutant R.C.C.s may be player characters with the G.M.'s approval. They take no O.C.C., cannot use Juicer or M.O.M. conversion, and never pilot power armor or robots |
| **79** | *Experience Tables* | four ladders: Haven Mutant R.C.C. (all except the Shaman); Knight of the White Rose & Keeper of the Garden; Gateway Knight & Mutant Shaman; Squire of the White Rose |

Every class has a printed XP ladder, so all twelve are playable by the rule
`book-survey` and past imports use.

## Inventory

Counted by structure over all 136 cached pages.

| section | printed pages | what is there |
|---|---|---|
| History, setting, sectors of the ruins | 6-21 | lore. The psychic imprint rule on printed 15-16 is a setting mechanic (M.E. saves in the ruins) and **not** a class |
| Order of the White Rose | 22-37 | **4 O.C.C.s**, plus the White Rose healing items (printed 35-36), plus **2 named knights** with full stat blocks (printed 37-43) |
| The Garden, Cleopatra's Needle | 38-51 | locations, lore. No stat blocks |
| Mutant clans and society | 51-59 | lore. Estimated numbers and a table of clans |
| Haven Mutant R.C.C.s | 60-79 | **8 R.C.C.s**, the **Shaman** overlay (printed 79), the four XP ladders (79) |
| Raving Lunatic NPC | 79-80 | a template applied to any O.C.C. No dice of its own, and no XP ladder |
| Weapons of Note | 80-91 | **about 30 gear rows**: 10 bone weapons and Bone Armor; 6 White Rose TW weapons and a shield; 6 TW body armors and barding; and 7 TW devices, the Curtain among them |
| Monsters of Madhaven | 92-108 | **11 creatures**: Caterpillar Men, Devil Kraken, Giant Ruin Worm, Head Worms, Onion Heads, Phantom Wolf, Ruin Lizard, Ruin Rats, Toothback Wallcrawler, Undead Horrors (optional), War Birds |
| Ghosts of Madhaven | 109-123 | **7 Entities**: Gluttonous, Beautiful Ghost, Harmful Ghost, Madness Ghost, Conglomerate, Contagion, Rotting |
| Conversion notes, 51 encounter ideas | 124-128 | tables for the G.M. Nothing to import |

### Things this book has zero of, checked rather than assumed

- **Spells: none defined.** No page carries a spell stat block. The
  White Knight's and Keeper's spells are all named from the catalog. Only five
  pages carry `Duration:`, and those are TW devices and two creature powers.
- **Psionic powers: none defined.** Every `I.S.P.` hit is a class or creature
  naming existing powers.
- **Skills: none defined.** The two `Base Skill:` hits (cache p097, p102) are
  creature abilities (the Devil Kraken's sense, the Onion Heads' acid).

## Classes

### Playable O.C.C.s (4): Order of the White Rose

| class | printed | XP ladder (printed 79) | proposed id |
|---|---|---|---|
| Knight of the White Rose (the White Knight O.C.C.) | 26-30 | Knight & Keeper | `knight-of-the-white-rose` |
| Squire of the White Rose | 30-32 | Squire | `squire-of-the-white-rose`, because **`squire` is taken** by the Palladium Fantasy class |
| Gateway Knight | 32-35 | Gateway & Shaman | `gateway-knight` |
| Keeper of the Garden | 35-37 | Knight & Keeper | `keeper-of-the-garden` |

The Knight is a Mystic Knight of good alignment. Its seven fixed spells (printed
28) and its psionic picks come from existing catalogs. **No `mystic-knight`
class exists in production**, so nothing collides with it. The Squire has ten
MOS specialties (printed 30-31) and a rule that lets it take a second MOS by
giving up its other O.C.C. skills. **Expect that to be a choice group plus
prose.**

### Playable R.C.C.s (8): the Haven Mutants

| class | printed | proposed id |
|---|---|---|
| Beast Men | 60-62 | `beast-men` |
| Dyno-Men | 62-64 | `dyno-men` |
| Leopard Men | 64-66 | `leopard-men` |
| Mantis Men | 66-68 | `mantis-men` |
| Metal Morph | 68-71 | `metal-morph` |
| Pseudo Men | 71-73 | `pseudo-men`. It carries its own random special-abilities table (printed 72) |
| Quill Men | 73-76 | `quill-men` |
| Savage Lummox | 76-79 | `savage-lummox` |

All eight use the Haven Mutant ladder. **Check each id against production before
emitting**, because a check on 2026-09-24 was by name only.

### The Mutant Shaman (printed 79): an overlay, and the app cannot fully express it

A Shaman is any of the eight mutants with extra attribute and P.P.E. bonuses,
a fixed skill list that **replaces** all secondary, piloting and modern-W.P.
skills, two prayers to Isis, and **its own XP ladder** (Gateway & Shaman).

A `variant` may override attribute dice, pools and `bonuses`, and since
`BOOK-INGEST-AUDIT` F31 (PR #834) it may **add** skills through
`skills_additional`. It still **cannot remove** a parent skill, and it
**cannot carry its own `xp_table`**, which is not on `VARIANT_OVERRIDES` in
`apps/character-creator/js/parser.js`. Read at line 64 on 2026-09-24. The plan,
with the variant-plus-prose approach Nate chose on 2026-09-24:

- a `shaman` variant on each of the eight R.C.C.s, carrying the attribute and
  P.P.E. changes, and adding the Shaman skill list through `skills_additional`;
- the removal of Secondary, Piloting and modern-W.P. skills, the two prayers
  and the ladder as prose on each class, plus an `extraction_notes` line;
- a finding filed in `BOOK-INGEST-AUDIT.md` for a variant that has to remove
  skills and use its own ladder. That is Tier 3: filed, not built.

### Not a class

- **Raving Lunatic NPC** (printed 79-80) is a madness template over any
  O.C.C. It has no attributes of its own and no ladder. Left out.

## Notable NPCs (2)

| name | printed | note |
|---|---|---|
| Sir Geoffrey Colt | stat block 39-40 | 15th level Mystic Knight. Full attributes and combat |
| Sir Gabriel Prescott Davenport | stat block 42-43 | 1st level Mega-Hero **and** 8th level Mystic Knight |

Isis ("the Mighty Lady") and Pharaoh Rama-Set are named but carry no stat block
in this book. Left out.

## Catalog diff

Run against **production** on 2026-09-24, by name:

| table | result |
|---|---|
| `imported_classes` | **0 of 12** present. `squire` is a different class (see above) |
| `creatures` | **0 of 18** present (no Phantom Wolf, Ruin, War Bird, Entity, Ghost, Caterpillar, Onion, Kraken, Head Worm or Wallcrawler row) |
| `notable_npcs` | **0 of 2** present |
| `gear` | **0** Madhaven items. Near-names found and ruled out: `Bone Knife` (an S.D.C. estimate row, no book), `TW Hellfire Shotgun` (New West), `Cavalry Armor (Barding)` (New West) |

**Gear naming, decided at survey:** the book heads its bone weapons as bare
`Bone Axe`, `Bone Knife`, and so on. `Bone Knife` already exists as an unrelated
S.D.C. row, so **all ten are imported as `Mutant Bone <X>`**, with the book's
own heading recorded in the description. The prefix is applied to all ten
rather than just the colliding one, so the set sorts and reads together.

Run `scripts/catalog-diff.mjs --remote` on the extracted gear before writing SQL.
The name check above is not a matcher.

## Extraction plan

Everything above cost nothing. The work in order, one PR each, applied
`--remote` before the PR:

1. **Registry and survey**: this file, the `books.json` entry and the queue row.
2. **Gear**: 40 rows from printed 36-37 and 81-91. Moved ahead of the classes
   on 2026-09-24, because the O.C.C. drafts name TW Inferno Blade, Gateway TW
   Body Armor, the bone weapons and more. Shipping the gear first means
   `class-check --remote` finds real rows instead of emitting stubs, and a
   stub that sorts before this file would win on a rebuild.
3. **The four White Rose O.C.C.s**.
4. **The eight Haven Mutant R.C.C.s**, with the Shaman as a variant on each and
   the finding filed.
5. **Creatures**: 10 monsters (Undead Horrors prints no stat block), 7 ghosts
   and the 8 mutants as their NPC view, with `stat_attacks`. Through the
   Phase 3 pipeline: worker by NAME, reconcile, and a shingle copy-check.
6. **Notable NPCs**: Colt and Davenport. Small enough to ride with PR 5.

What is deliberately left, with the reason:

- Raving Lunatic: a template, not a class or a creature.
- Isis and Rama-Set: no stat block here.
- The 51 encounter ideas and the Madhaven random tables: G.M. prose.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-24 | — | cache built (136 pp, text layer), survey written, offset +1 verified at four folios, `madhaven` registered in `books.json` |
| 2026-09-24 | [#1337](https://github.com/NateGrey0130/nates-workshop/pull/1337) | registry, survey and queue row. MERGED |
| 2026-09-24 | [#1338](https://github.com/NateGrey0130/nates-workshop/pull/1338) | `add-madhaven-gear.sql`: 40 gear rows (15 weapon, 9 armor, 6 gear, 10 magic). All 40 missing in `catalog-diff --remote` against 2830 rows; every number from a render; `book-reconcile` 40 of 40 agree. Applied `--remote` before the PR, both read-backs hold |

### What remains

Steps 3-6 of the extraction plan: the O.C.C.s, the R.C.C.s, the creatures and the notables.
