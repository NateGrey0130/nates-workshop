# Rifts Dimension Book 1: Wormwood — survey

Slug `ww`. Cached 2026-08-27 from `Rifts- Dimension Book 1 Wormwood.pdf`,
161 PDF pages, **scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7.*

## Page offset is ZERO

`page_offset: 0` — printed folio N is cache `pNNN.txt` and `read-columns.py N`.
Verified on printed 3, 4, 5, 6, 83 and 157 by reading the folio off the render.
`ocr-book.py` measured the same thing independently and wrote 0 into the
manifest. Only the second book here with a zero offset (`potm` is +1) — see
`book-survey` 0d on why zero is the awkward case, not the easy one.

The OCR is unusually clean for a scan: median ~5k chars/page, headings intact,
stat-block labels (`P.P.E.:`, `Range:`, `Duration:`) survived. No page needed a
re-render to read. Curly quotes and em-dashes are present throughout and must be
stripped before any SQL.

## The book's two authority tables

| page | table | states |
|---|---|---|
| **83** | *List of Priestly Prayers & Spells* | the 37 prayer NAMES, and nothing else |
| **157** | *Experience Tables* | which classes are PLAYABLE, and their XP ladders |

Page 157 is the more valuable of the two, because it settles a question the
class pages do not: alongside the ladders it names eleven kinds of creature as
**not available as player characters** — the dark priest, the Unholy, the Host,
air fish, beast guards, demon hounds, feathered serpents, skelter bats, worm
zombies, parasites and symbiotes. That list is the authority every exclusion
below cites.

Pages 4-6 additionally carry a full Contents plus a *Quick Find Table* — a
second index that repeats every section with its page. It is a useful
cross-check and it is **not clean**: it prints `Crawler: Half Mast` where the
book's own symbiote list (p.91) and the description heading (p.97) both say
**Half Mask**. Two readings against one; Half Mask wins.

There is no P.P.E. index. A prayer's cost is stated once, in its own stat block,
so there is only ONE reading of each cost in this book — unlike Palladium
Fantasy, which prints costs twice. Costs are therefore transcribed, not
reconciled.

## Inventory

Counted by structure over all 161 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Comic strip | 9-28 | fiction, nothing to import |
| World / locations / history | 29-51 | lore only |
| **O.C.C.s** | **52-76** | 8 playable occupations + High Priest (NPC) |
| Non-player heroes | 77-81 | 3 named NPCs |
| **Prayers & Spells** | **82-90** | **37 prayers**, all with stat blocks |
| **Symbiotes & slimes** | **91-100** | 25 symbiotes + 8 evil symbiotes |
| Parasites | 101-108 | 8 creatures (mounts/monsters, not gear) |
| **Blood stones & magic crystals** | **109-114** | 12 stones + 18 crystals/gems |
| Forces of Darkness | 115-121 | Dark Priest (NPC) + hierarchy |
| **R.C.C.s** | **122-137** | 9 playable races + 5 NPC-only monsters |
| Lords of Darkness / The Host | 138-156 | NPC villains |
| **Experience tables** | **157** | XP ladders for every playable class |
| Character sheets | 158-159 | forms |

### Psionics: this book defines ZERO new powers

Deliberately checked, because "no new psionics" reads like a gap. An `I.S.P.:`
stat-block scan over all 161 pages returns **four hits, all of them monster
POOLS** — `I.S.P.: 800` for Lord Lesion (p.143), `2D4x100` for the Host (p.141),
600 and 700 for two others. Not one power definition anywhere in the book.
Wormwood's magic is priestly prayers; its psychics use the Rifts core list.

This matches [[pantheons-of-the-megaverse-survey]]: a book adding no psionics is
a fact about the book, not a hole in the extraction.

## Classes

### Playable O.C.C.s (8) — pages 52-76

| class | pages | XP table on p.157 |
|---|---|---|
| Priest of Light | 52-54 | Priests of Light |
| Apok | 55-58 | Apok |
| Monk | 59-62 | Monk & Entrancer |
| Wormspeaker | 63-64 | Wormspeaker |
| Symbiotic Warrior | 64-66 | Freelancer & Symbiotic Warrior |
| Freelancer | 68-70 | Freelancer & Symbiotic Warrior |
| Knight of the Order of the Temple | 70-73 | Templar Knights |
| Knight of the Order of the Hospital | 73-76 | Hospitaller Knights |

**`priest-of-light` is TAKEN.** The catalog already holds a published
Palladium Fantasy Priest of Light (`palladium-fantasy-core p.63-67`), a
completely different class. Wormwood's needs its own id —
`wormwood-priest-of-light`.

### Playable R.C.C.s (9) — pages 66-68 and 122-137

| class | pages | XP table on p.157 |
|---|---|---|
| Holy Terror | 66-68 | Morphworm, Rumbler & Holy Terror |
| Demon Goblin | 122-124 | Demon Goblin, Demon Hound Rider, Ram-Rat & Sky Rider |
| Demon Hound Rider | 125-126 | same |
| Entrancer | 126-129 | Monk & Entrancer |
| Morphworms | 129-131 | Morphworm, Rumbler & Holy Terror |
| Ram-Rat | 131-132 | same as Demon Goblin |
| Rumbler | 132-133 | Morphworm, Rumbler & Holy Terror |
| Shade | 133-135 | Shade |
| Sky Riders | 135-136 | same as Demon Goblin |

The Holy Terror sits in the Contents under *Champions of Light* but its stat
block on p.67 is headed **R.C.C. Skills** and its XP ladder is grouped with the
monsters. It is an R.C.C.

**Temporal Raider is NOT importable from this book.** It has an XP table on
p.157 and a section on pp.136-137, and both point elsewhere: the section
refers the reader to **Rifts World Book Three: England** for the temporal
raider's character data. The pages here are lore. Left out, and the reason recorded.

### NPC-only, excluded by the book's own rule (p.157)

Dark Priest (117-119), Air Fish (119), Beast Guard Type One (120), Beast Guard
Type Two (122), Demon Hound (124), Feathered Serpent (128), Skelter Bats (134),
Worm Zombie (137), The Host (138-146), The Unholy (141), Lord Lesion (143),
Lord Krikton (144), Salome (145), High Priest (54), and the three named
non-player heroes (77-81).

These are not "missing classes" — the book states they are not player
characters, and importing them into `imported_classes` would contradict its own
authority table.

## Catalog diff

Run against **production** (`--remote`): 333 skills, 570 spells, 101 psionic
powers, 902 gear, 109 classes.

### Spells: 37 missing, 0 false gaps

`node scripts/catalog-diff.mjs --remote --table spells --entries ww-prayers.json`
returns **matched 0, missing 37**. Every near-match was hand-checked and none is
real — `Create Wall`/`Create Wood` (3), `Create Shelter`/`Create Steel` (4),
`Summon Flies`/`Summon Ally` (4) are the closest, and all three are different
spells. This is the rare clean diff: the book's magic shares no vocabulary at
all with the Rifts invocation list.

**These prayers have no LEVEL.** They are not invocations on a numbered ladder;
a priest starts with eight and picks more on a schedule. The catalog has no
level-0 spell today (`SELECT COUNT(*) FROM spells WHERE level = 0` returns 0),
so importing them at level 0 establishes that convention. It is safe because
every class that grants them will name them through `magic.spells_from`, and
`leveling.js` states outright that a named list REPLACES the spell-level gate.

The book spells three prayer names two ways between its list and its
description headings — `Summon and use Angel Hair` / `Summon & Use Angel Hair`,
`Summon and Command Parasites` / `Summon & Command Parasites`, `Summon and use
Spirits of Wormwood` / `Summon & Use Spirits of Wormwood`. The p.83 list is the
authority for membership; the description-page spelling goes in a note.

### Skills: renames, not new rows, except three

Checked against `SELECT name FROM skills`:

| book prints | catalog holds | action |
|---|---|---|
| `Lore: Monsters & Demons` | `Lore: Demons & Monsters` | **rename** — cite the catalog |
| `Language: American` | `Language: Native Tongue` | **rename** — the Juicer sets this precedent |
| `Literacy: American` | `Literacy: Native Language` | **rename** |
| `Math: Basic` | `Mathematics: Basic` | **rename** |
| `Lore: Wormwood` | — | **new row** |
| `Language: Demongogian` | — | **new row** |
| `Language: Gobblely` | — | **new row** |

W.P. Blunt, W.P. Sword and the hand-to-hand rows all already exist.

### Gear: ~63 new rows, no false gaps possible

Nothing in the catalog cites Wormwood, so every row is new. The book's own list
on **p.91** is the authority — it names every symbiote, slime, parasite, stone
and crystal in one place, and it caught a name the description pages lost:
**Spell Gem of Magic**'s heading fell on the p.113/p.114 break, so reading the
description pages alone finds four spell gems where the list names five.

| group | count | pages |
|---|---|---|
| Symbiotes (saints, spirits, claws, crawlers, stars, worms) | 25 | 91-99 |
| Evil symbiotes (life force batteries/cauldrons, 6 slimes) | 8 | 99-100 |
| Greater blood stones | 6 | 109-110 |
| Lesser blood stones | 6 | 110-111 |
| Greater magic crystals & spell gems | 12 | 111-114 |
| Lesser magic crystals | 6 | 114 |

**Parasites (8) are excluded.** Battler, Tick, Beetle, Monster Worm, Tangle
Worm and the three Kriktons are creatures with attacks and horror factors, and
p.157 names parasites among the things that are not player characters. They are
monsters, not equipment.

**None of these items has a price.** The book says so directly (p.52): Wormwood
runs on barter, and the Priest of Light's `Money:` line records no figure at
all — it states the field does not apply. `cost` stays NULL and `cost_note` records why. That is a real
property of the book, not a failed extraction — see `book-survey` 0e on
sections that price by band or not at all.

The spells listed under each spell gem (`Armor of Ithan`, `Eyes of Thoth`,
`Mystic Portal`, `Call Lightning`, ...) are **cross-references to existing Rifts
invocations**, not new spells. So are the prayers listed under the Eye and Heart
of Wormwood. Nothing there gets imported.

## Extraction plan

Phase 4 costs money; everything above was free. What gets extracted:

1. **37 prayers** from pp.83-90 — name, P.P.E., range, duration, saving throw,
   time required, description. One batch per 2 pages. Level 0.
2. **3 new skills** — Lore: Wormwood, Language: Demongogian, Language: Gobblely.
3. **~63 gear rows** from pp.91-100 and 109-114.
4. **17 classes** — 8 O.C.C.s and 9 R.C.C.s, one PR each per the
   one-class-per-`add-<id>-class.sql` rule, XP ladders from p.157.

What is deliberately left:

- every NPC-only monster (the book's own rule, p.157)
- the Temporal Raider's mechanics (they are in World Book 3, not here)
- the 8 parasites (monsters, not gear)
- pp.9-28 comic strip and pp.29-51 world lore (no mechanics)

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-27 | — | cache built (161 pp), survey written, offset 0 verified |
| 2026-08-27 | #352 | `ww` registered in books.json; 3 skills (336 total); 37 prayers at level 0 (607 spells). Applied `--remote` before the PR. MERGED. |
| 2026-08-27 | #353 | 71 gear rows (973 total): 25 symbiotes, 8 evil symbiotes, 8 parasites, 12 blood stones, 18 crystals. Applied `--remote` before the PR. MERGED. |
| 2026-08-27 | #354 | 4 Cathedral O.C.C.s (117 classes): `wormwood-priest-of-light` p.52-54, `apok` p.55-59 (NOT 55-58 - printed 56 and 58 are full-page art and a third of the class is on 59), `monk` p.59-62, `wormspeaker` p.63-64. No new gear: angel-hair-rope shipped in #355. Applied `--remote` before the PR. MERGED. |
| 2026-08-27 | #355 | 4 warrior O.C.C.s (113 classes): `symbiotic-warrior` p.64-65, `freelancer` p.68-70, `knight-of-the-order-of-the-temple` p.70-73, `knight-of-the-order-of-the-hospital` p.73-76. Plus 2 gear rows, `angel-hair-rope` and `resin-spike` from p.42 (975 total). Applied `--remote` before the PR. MERGED. |
| 2026-08-27 | #356 | 5 R.C.C.s (122 classes): `holy-terror` p.66-68, `demon-goblin` p.122-124, `demon-hound-rider` p.125-126, `entrancer` p.126-127 (NOT 126-129 - 128 and the top of 129 are the NPC-only feathered serpent), `morphworm` p.129-131. NO xp_table on any of them: regression pins that a race carries none, so the p.157 ladders are recorded in extraction_notes instead. No new catalog rows. Applied `--remote` before the PR. MERGED. |
| 2026-08-27 | #357 | 4 R.C.C.s (126 classes): `ram-rat` p.131-132, `rumbler` p.132-133, `shade` p.133-134 (NOT 133-135 - the rest of 134 and all of 135 are the NPC-only skelter bat), `sky-rider` p.135-136. No new catalog rows: the rumbler's eight earth elemental spells only LOOKED missing, because the catalog files elemental magic under an `Earth:` prefix. **THE IMPORT IS COMPLETE: 17 of 17 classes live.** Applied `--remote` before the PR. MERGED. |

Each draft branch carries ONE EMPTY COMMIT and nothing else. That is what lets
a PR exist before the work does; `git commit --allow-empty` keeps the scope in
the commit message rather than in a plan file that would then need deleting.

All 17 class ids were checked against production before the branches were cut.
Only `priest-of-light` collides. `monk` is free despite a `warrior-monk`
existing, and `knight` exists but neither Wormwood knight order uses it.

Decisions taken 2026-08-27, on Nate's call:

- **NPC-only races stay out.** Only the 17 classes p.157 gives XP ladders to.
- **The 8 parasites ARE gear** — overriding this survey's first recommendation.
  They go in with the symbiotes, on the grounds that *Ride Giant Parasites* and
  *Summon and Command Parasites* make them player-reachable. So the gear PR is
  ~71 rows, not ~63.
- **Standing authorisation to apply `--remote`** for the rest of this import.
