# Rifts World Book 35: Megaverse in Flames — survey

**Status:** `importing` — Soulmancy spells levels one to five shipped; the rest of the spells next. (2026-11-17)

**Rows citing this book:** spells 18

Slug `megaverse-in-flames`. Cached 2026-11-17 from
`Rifts - World Book 35 - Megaverse in Flames - PAL876P.pdf`, 194 PDF pages,
**text layer** (`--probe` median 5,557 chars/page, 37.7% stop words).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. One region, no exceptions.

| cache page | folio printed on it |
|---|---|
| `p005` | 4 |
| `p008` | 7 |
| `p092` | 91 |
| `p186` | 185 |
| `p193` | 192 |

`printed_pages` is 192, the last numbered folio. Cache `p194` is the back
cover.

Text-layer damage, by cache page (the manifest's three keys):

- welded: 77 and 194. Printed 76 carries the Canadian Tundra Hell Pit and the
  head of the Terror Army's troop table; nothing in the plan reads a figure
  off it. 194 is the back cover.
- glyph-corrupt: none
- digit-substituted: none detected. The detector has missed this publisher's
  text layers before (Northern Gun Two, the same year), so any figure that
  reads oddly is checked on a render.

The text layer loses column geometry on *M.D.C. by Location* blocks and on
the troop tables: a figure that sits oddly is read off a render.

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-6** | Contents | every section, Hell Lord, overlord, class, weapon, vehicle and artifact by name and page; the Soulmancy spells one by one under a heading for each spell level |
| **6-7** | *Quick Find Index* | a second index by keyword, about 110 lines; it names each Hell Lord's and overlord's region |
| **91** | Soulmancy spell list | the 55 spells under level headings, each with its P.P.E. cost in parentheses |

Spell levels are printed three times (the Contents, the list on 91, and the
level headings inside the descriptions on 92-111) and costs twice (the list
and each description's own line). The list on 91 is the one to work from; the
other two check it. Two names differ between the list and the Contents: the
first-level soul-reading spell carries an article in the list and none in the
Contents, and the fourth-level thirst spell is one word in the list and two in
the Contents. The description heading settles each at extraction.

The Contents omits one Deevil artifact that has its own heading on 138 (a
locust poison), so the artifacts are counted off the pages, not the Contents.

**Two Experience Tables are printed**, each at the end of its class: the
Soulmancer's on 88 and the Blood Warrior's on 91. The reprinted Anti-Monster
(185-188) prints none; the held class keeps the ladder it has.

Costs of gear are printed once, in each entry.

## Inventory

Counted by stat-block markers over all 194 cached pages, not by reading prose.
The book holds 3 class blocks, 55 spell blocks, 16 full NPC blocks and 9
*M.D.C. by Location* blocks.

| section | printed pages | what is there |
|---|---|---|
| Reports, the war in brief, why Earth | 8-17 | prose |
| Demon Plagues | 17-22 | random tables for the size and make-up of a roving demon force; no stat block |
| Hell Pits | 23-29 | rules for creating, living near and destroying one; dimensional anomaly tables |
| Hell Plagues | 29-38 | **7 magical diseases**, each with symptoms, stages and cures |
| Calgary, Kingdom of Monsters | 39-51 | city prose, encounter and loot tables, a troop table |
| The seven Hell Lords | 51-84 | **7 full NPC blocks** (Doom 53, Pain 58, Heart Ripper 62, Rune 68, Zugard 74, Fury 79, Siren 82), each followed by a named army as prose and a troop table. Pain's block continues into the slave barge that is his lower body (59-60). Rune's rune armour has its own entry (69). A mercenary company is given as an organisation sheet (70-71) |
| The Art of Soulmancy | 84-91 | **2 classes**: Soulmancer O.C.C. (85-88) and Blood Warrior O.C.C. (88-91), both marked by the book as NPC villains |
| Soulmancy Magic | 91-111 | the spell list (91) and **55 spells**: levels one to fifteen (52) and three Spells of Legend (110-111). One thirteenth-level spell (106) prints a stat block for what it creates |
| Lord Kreelo | 111-113 | **1 full NPC block** |
| Megaverse Armaments | 113-124 | **4 Blood Energy weapons** (114-115), **2 body armours** (115-116), **1 power armour** with its own weapon systems (116-118), **3 war vehicles** (118-124) |
| Minion War Arms Race | 125-129 | demon melee weapons, bows, arrows and magic arrowheads as price lists (125); **2 Techno-Wizard iron-bolt guns** (126); **3 bone-shard guns** (126-127); **5 demon magic artifacts** (127-129) |
| Dyval weapons and vessels | 130-136 | **3 Hell guns** (130); **3 flying ships** (131-136) |
| Deevil magic artifacts | 136-139 | **8 artifacts** |
| Rifts Cuba | 141-151 | islands, the Deevil city, its defences and a troop table; prose and a map (143) |
| The Deevil overlords | 152-174 | **8 full NPC blocks** (Shard 154, Necroskull 157, Shade 160, Dai 162, Spike 163, Sindel 165, Sthena 169, Queen Marauder 172), each overlord followed by a named army as prose and a troop table. Sindel's rune axe has its own entry (167) |
| Epilogue | 175-185, 188-192 | how each nation responds; possible outcomes; prose |
| The South American Anti-Monster O.C.C. | 185-188 | **1 class**, headed as a reprint from South America, updated |

That is **16 NPCs** (7 + 1 + 8), **3 classes**, **55 spells**, **7
vehicle-shaped entries** (1 power armour, 3 war vehicles, 3 ships) and about
**33 priced or statted items** before the four price lists on 125 are counted.

**No psionic power, no new skill and no creature entry is defined.** The scan
for an I.S.P. cost line found none outside the NPC blocks, and no page prints
a creature block of its own: the troop tables name demon and Deevil kinds
that other books stat.

## Classes

### O.C.C.s (2 new, 1 held) — pages 85-91 and 185-188

| class | pages | XP table |
|---|---|---|
| Soulmancer | 85-88 | its own, on 88 |
| Blood Warrior | 88-91 | its own, on 91 |
| Anti-Monster | 185-188 | none printed here; held as `anti-monster` |

No id collides: production holds no class named Soulmancer or Blood Warrior.
The ids are `soulmancer` and `blood-warrior`.

Both new classes carry the book's note that they are NPC villains and not
meant as player characters, and both restrict alignment to evil. They are
imported anyway, flagged, by ruling (below).

The Anti-Monster is held from South America as `anti-monster`, published.
This book's entry says it is that class reprinted and updated; what changed
is not known until the two are read side by side.

## Catalog diff

Run against **production** (`--remote`), 2026-11-17, `origin/main` 33e327cc.
Production holds 0 rows citing this book in gear, vehicles, spells and
notable NPCs.

### spells: 55 new rows, 3 of them retellings of held invocations

`node scripts/catalog-diff.mjs --remote --table spells` over the 55 names
returns **matched 4, missing 51**. Hand-checked:

| the book prints | level | production holds | verdict |
|---|---|---|---|
| Death Trance | 1 | `Death Trance`, level 1, no tradition, RUE p.198 | the same invocation, retold by this tradition at the same level |
| Life Drain | 7 | `Life Drain`, level 7, no tradition, RUE p.213 | the same |
| Soultwist | 12 | `Soultwist`, level 12, no tradition, Book of Magic p.145 | the same |
| Permanency (a ritual) | 15 | `Nazca: Permanency`, level 0, South America 2 | matched by alias only; a different tradition's spell, not the same row |

Soulmancy is a tradition of its own, so by the catalog's convention each of
the 55 is a row named with the tradition's prefix, in a new `soulmancy`
tradition. The three retellings point at the held invocation through
`same_spell_as`, and the held rows are not touched. No near-match among the
other 51 is the same spell (the nearest were a blood-named spell to a
rift-closing spell at distance 3 and a soul spell to a transfer spell at
distance 4; all different).

This import establishes one convention rather than following it: the three
Spells of Legend. Production's highest spell level is 15, so they follow
whatever the held Spells of Legend from RUE carry, read at extraction.

### gear: about 33 new, 0 held

`node scripts/catalog-diff.mjs --remote --table gear` over 33 names returns
**matched 0, missing 33**. Checked and not the same item: `mutant-bone-armor`
(Madhaven), `ew-skin-and-bone-armor` (Dinosaur Swamp), the Nuhr rune armours
and axe (D-Bees of North America), the Palladium Fantasy demon blood and
bones rows. Not diffed by name because they are counted at extraction: the
melee weapon, bow, arrow and arrowhead lists on 125.

### vehicles: 7 new, 1 held and left

Seven names return missing and are new. The eighth, the slave barge on 59-60,
matches `eylor-slave-barge` (Atlantis p.124-125) by alias. This book's barge
is not a second printing of that vehicle: it is one Hell Lord's own body,
with his statistics, and goes into his NPC row. The held row is left alone.
`demon-black-ship` (South America p.165-167) is the vessel this book's first
ship says it resembles; it is a different row and is left alone.

### notable NPCs and classes

None of the 16 is held; the nearest names are other books' lords. Two classes
missing, one held (above).

## Extraction plan

One branch per line; gear, vehicles and spells go before the classes that
name them, and the classes before the NPCs levelled in them.

1. `pal/data/megaverse-in-flames-spells-a` to `-d`: the 55 Soulmancy spells
   (91-111) in four batches by level, through `scripts/rows-sql.mjs`.
2. `pal/data/megaverse-in-flames-kreelo-arms`: the four Blood Energy weapons
   and two body armours (114-116) as gear; the power armour and three war
   vehicles (116-124) through `scripts/vessel-sql.mjs`.
3. `pal/data/megaverse-in-flames-arms-race`: the price lists, five guns and
   five demon artifacts (125-129).
4. `pal/data/megaverse-in-flames-dyval-arms`: the three Hell guns (130), the
   three ships (131-136) and the eight Deevil artifacts (136-139).
5. `pal/data/megaverse-in-flames-rune-items`: the rune armour (69) and the
   rune axe (167).
6. `pal/data/megaverse-in-flames-class-soulmancer` and
   `-class-blood-warrior`: one class each.
7. `pal/data/megaverse-in-flames-class-anti-monster-compare`: the held class
   read against this printing.
8. `pal/data/megaverse-in-flames-npcs-a` to `-e`: the 16 NPCs, three or four
   to a batch, through `scripts/bestiary-sql.mjs`.
9. `pal/docs/megaverse-in-flames-close-out`.

Rulings that govern it:

- **The Soulmancer and Blood Warrior are imported, flagged. RULED (Nate,
  2026-11-17).** Both are published classes tagged `evil`, with the book's
  NPC-villain note carried in the class, on the African Witch and Hidden
  Witch precedent. Not taken: leaving both out, as Arzno's Blood Priest was.
- **The Anti-Monster is brought to this printing. RULED (Nate, 2026-11-17).**
  Where this book's figures differ, the held `anti-monster` class takes them
  and this book's citation, with the older figure in its notes; if nothing
  differs it keeps its South America citation. Not taken: leaving the held
  class unread. This is the 2026-10-04 ruling (newest printing wins) applied
  to a class.
- **Soulmancy is its own tradition.** Taken on the recommendation,
  2026-11-17: 55 rows under the tradition's prefix, the three retellings
  joined to the held invocations by `same_spell_as`. Not taken: re-citing or
  rewriting the three held invocations.
- **Hell Lord Pain and his barge are one NPC row carrying both blocks.**
  Taken on the recommendation, 2026-11-17, as Northern Gun Two's Frankenstein
  Cyborg was. Not taken: a second vehicles row beside the held Atlantis barge.
- **The power armour is a vehicles row; the two body armours are gear.**
  Taken on the recommendation, 2026-11-17: the catalog keeps anything with a
  speed and weapon-system block in vehicles. Not taken: all three as gear.
- **The thirteenth-level spell's creation stays in its spell row.** Taken on
  the recommendation, 2026-11-17. Not taken: a creatures row for it as well.
- **The rune armour and rune axe are gear rows of their own**, also named in
  their owners' NPC rows. Taken on the recommendation, 2026-11-17, as the
  Nuhr rune items were. Not taken: text inside the NPC rows only.

What is deliberately left, with the reason for each:

- the demon plague tables (17-22), the Hell Pit rules and anomaly tables
  (23-29): rules for a Game Master, no stat block;
- the seven Hell Plagues (29-38): diseases with staged effects, which no
  catalog table holds. Left as prose in the book, not filed as a gap: nothing
  in the creator applies a disease;
- Calgary (39-51) and Cuba (141-151): gazetteer prose, encounter and loot
  tables, a map;
- the fourteen named armies and their troop tables: head-counts by kind of
  demon, with no block of their own. Each army is named in its lord's NPC row;
- the mercenary company's organisation sheet (70-71): an organisation, not a
  person;
- the epilogue and outcomes (175-192), apart from the class it carries.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-11-17 | `pal/docs/megaverse-in-flames-register-survey` | cache built (194 pp, text layer), offset +1 verified by folio at five points, inventory and production diff; `megaverse-in-flames` registered in `books.json` |
| 2026-11-17 | `pal/data/megaverse-in-flames-spells-a` | `~340`: 18 spells rows, Soulmancy levels one to five (91-96), new tradition `soulmancy`; Death Trance not joined to the RUE row by `same_spell_as` (the duration differs; ruled 2026-11-17), the RUE figure in its `variant_note` |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-11-17, after `~340`
was applied: the book's *BY BOOK* line (traceable / other) is

```
  megaverse-in-flames  18 / 0
```

That run's `BACKLOG` block, which this book has not moved:

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            13   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           56   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

Everything in *Extraction plan* remains except the first spell batch (levels
one to five, `-spells-a`).
