# Rifts World Book 35: Megaverse in Flames — survey

**Status:** `importing` — all 55 Soulmancy spells, Lord Kreelo's arms, the Minion War arms race, the Dyval arms, the two rune items, the Soulmancer and the Blood Warrior shipped, the held Anti-Monster brought to this printing, and the first three Hell Lords. (2026-11-18)

**Rows citing this book:** classes 3, gear 39, vehicles 7, spells 55, notable_npcs 3

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
This book's entry says it is that class reprinted and updated. Read side by
side (2026-11-18), the two differ on eleven points, listed in the ledger, so
the held class takes this printing's figures and citation (`~350`), with
each South America figure kept in its notes.

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
| 2026-11-17 | `pal/data/megaverse-in-flames-spells-b` | `~341`: 14 spells rows, Soulmancy levels six to nine (96-100); `Soulmancy: Life Drain` joined to the RUE `Life Drain` by `same_spell_as` (same level, cost, range, duration and save) |
| 2026-11-17 | `pal/data/megaverse-in-flames-spells-c` | `~342`: 10 spells rows, Soulmancy levels ten to twelve (100-105); `Soulmancy: Soultwist` joined to the Book of Magic `Soultwist` by `same_spell_as` (same level, cost, range, duration and save) |
| 2026-11-17 | `pal/data/megaverse-in-flames-spells-d` | `~343`: 13 spells rows, Soulmancy levels thirteen to fifteen (105-110) and the three Spells of Legend (110-111), which take level 15 and a `ppe_note` opening "A Spell of Legend, beyond the fifteen levels"; no `same_spell_as` (`Soulmancy: Permanency (Ritual)` is not Nazca's); Summon Demon Planet costs 2,000 by its description, the list's 5,000 +35,600 in its `variant_note` |
| 2026-11-17 | `pal/data/megaverse-in-flames-kreelo-arms` | `~344`: 4 vehicles rows with 36 locations and 19 weapon entries, the Chaos Trooper power armour and three war vehicles (116-124); `~345`: 6 gear rows, the four Blood Energy weapons and the Flesh and Bone Armors (114-116), the rolled main-body M.D.C. of each armour left out of `mdc` and stated in its description |
| 2026-11-18 | `pal/data/megaverse-in-flames-arms-race` | `~346`: 20 gear rows, the Minion War arms race (125-129): three Demon Bows, the plain Bone Arrowhead and six Magic Bone Arrowheads, two TW Iron Bolt guns, three Bone Shard guns and five Demon Magic Artifacts; the Demon Bows' rolled 4D6+34 M.D.C. left out of `mdc` and stated in each description; the Demon Melee Weapons heading prints no weapon of its own, so it adds none |
| 2026-11-18 | `pal/data/megaverse-in-flames-dyval-arms` | `~347`: 3 vehicles rows with 43 locations and 14 weapon entries, the Hell Galleon, Hell Schooner and Hell Battle Barge (131-136), each with three main-body sections as locations and `mdc_main_body` empty; the Barge's rear 8,600, the Schooner's "150-20" tons and the Galleon's 55 m stored as printed with a note; `~348`: 11 gear rows, the three Hell guns (130) and the eight Deevil artifacts (136-139) |
| 2026-11-18 | `pal/data/megaverse-in-flames-rune-items` | `~349`: 2 gear rows, Hell Lord Rune's armor Soul Steel (69-70) and Overlord Sindel's Rune axe Deceiver (167-168); Soul Steel's `mdc` holds the chest plate's 1,000 (the book's main body) with every location in its description; neither prints a price, so `cost` is empty |
| 2026-11-18 | `pal/data/megaverse-in-flames-class-soulmancer` | `add-soulmancer-class.sql`: 1 classes row, the Soulmancer O.C.C. (85-88), published, tagged `evil`, the book's NPC-villain note as its first restriction; nine starting spells and a named list of the 52 Soulmancy spells that are not Spells of Legend; the class page's Read Soul (30), Create Soul Crystal (30), Consume Soul (35) and Pseudo Life stored by their catalog names and costs; Literacy: Demongogian a Literacy: Other pick; Soul Crystals, the lesser magical knife, cauldron, ice pick and saw are prose, with no gear row |
| 2026-11-18 | `pal/data/megaverse-in-flames-class-blood-warrior` | `add-blood-warrior-class.sql`: 1 classes row, the Blood Warrior O.C.C. (88-91), published, tagged `evil`, the book's NPC-villain note as its first restriction; occ_group magic off the *Magic Powers* heading; Soulmancy picks as two named lists (levels 1-3 and 1-7); `mdc_from_hp_sdc` with the level-one 1D6 M.D.C. as a bonus and the further 1D6 per level as prose, so `regression`'s converting-classes pin now names the Blood Warrior; Literacy: Demongogian a Literacy: Other pick; the demonic symbol is `holy-symbol`, the rest of the gear in restrictions |
| 2026-11-18 | `pal/data/megaverse-in-flames-class-anti-monster-compare` | `~350`: the held `anti-monster` class (South America 34-37) brought to the reprint (185-188) and re-cited to this book, so South America's class count drops by one; the markdown replaced whole, guarded on the old spell sentence and production's length 19884. What differed: spells four times a day at a 5th level Ley Line Walker (was three, at a 5th level wizard; `trackable_resources` max 3 to 4); weight 400-800 lbs; alignment percentages (Scrupulous 30%, Unprincipled 30%, Anarchist 15%, Aberrant 15%); Sense Psychic and Magic Energy tripled along ley lines; the identify list (demons, Deevils, vampires, Soulmancers, Blood Warriors); obsession 61-80 and the P.S. damage table pointed at Rifts Ultimate Edition (p.332, p.285); Cowboy (any) and Horsemanship (any +5%) among the related skills; the H2H upgrade paid with an O.C.C. Related skill; a silver cross, wooden cross, 20 wooden stakes, mallet and flashlight in the equipment; salves in the potion restriction. Secondary skills keep South America's list limit (this printing states none), recorded in the notes. Applied `--remote` before the merge |
| 2026-11-18 | `pal/data/megaverse-in-flames-npcs-a` | `~351`: 3 notable_npcs rows with 18 stat_attacks, Hell Lords Doom (51-54), Pain (56-60) and Heart Ripper (62-65); Pain's Eylor Slave Barge carried in his row by ruling, the held Atlantis barge untouched; S.D.C.-setting Hit Points, S.D.C. and A.R. kept with a note. Applied `--remote` before the merge |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-11-18, after
`~350-megaverse-in-flames-anti-monster.sql` was applied: the book's *BY BOOK*
line (traceable / other) is

```
  megaverse-in-flames 104 / 0
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

Everything in *Extraction plan* remains except its first seven lines: the four
spell batches (levels one to five, `-spells-a`; six to nine, `-spells-b`; ten
to twelve, `-spells-c`; thirteen to fifteen and the Spells of Legend,
`-spells-d`), Lord Kreelo's arms (`-kreelo-arms`), the arms race
(`-arms-race`), the Dyval arms (`-dyval-arms`), the rune items
(`-rune-items`), the Soulmancer (`-class-soulmancer`) and the Blood Warrior
(`-class-blood-warrior`), and the Anti-Monster comparison
(`-class-anti-monster-compare`). Of the eighth line, the first NPC batch
(`-npcs-a`: Doom, Pain and Heart Ripper) is in; thirteen NPCs remain.
