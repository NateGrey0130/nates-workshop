# Rifts World Book 11: Coalition War Campaign — survey

**Status:** `importing` — gear, the nine CS military O.C.C.s and the six ISS/NTSET/Psi-Net O.C.C.s shipped; the D-Bees, vehicles and creatures are next. (2026-09-25)

**Rows citing this book:** classes 15, gear 25

**MOS:** cs-rcsg-scientist 7, cs-special-forces 8, iss-peacekeeper 7, iss-specter 8, iss-intel-specter 10, ntset-protector 7, psi-net-agent 10

*Each class's MOS packages, pinned by `test/regression.mjs` against a clean build. Every one of these classes takes four skills from ONE area of specialty, stored as a pick of four inside each area. The Psi-Net Agent's ten include the book's two named packages, Tracker and Spotter (printed 195).*

Slug `cwc`. Cached 2026-09-25 from
`Rifts- World Book 11 Coalition War Campaign.pdf`, 226 PDF pages, **text layer**
(no OCR). `--probe` median 3,666 chars/page, 35.2% stop words, 0.0%
private-use glyphs, so this is a real text layer and not the glyph-dropped kind
(`BOOK-INGEST-AUDIT` F73). The PDF was handed over from `Downloads` and copied
to `C:\Users\natha\Projects\workshop\books`, where `books.json` records it.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on five pages rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p020` | 19 | +1 |
| `p100` | 99 | +1 |
| `p200` | 199 | +1 |
| `p223` | 222 | +1 |
| `p225` | 224 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 224**, the
Experience Tables at cache `p225`. `ocr-book.py` wrote 222 into the manifest,
because cache `p224` (printed 223, adventure hooks) carries no bare folio line.
The registry outranks the manifest. Cache `p226` is the blank back cover.

## Cache health

| key | cache pages | where it matters |
|---|---|---|
| `welded_pages` | 9, 72, 90, 151 | **p072 = printed 71, the CS Commando's attributes and skills.** p090 = printed 89, the C-5 Pump Pistol. p151 = printed 150, the Mark VII Slayer APC. p009 is lore. Read all three from a render |
| `corrupt_pages` | 39 (3), 136 (1), 146 (1) | p136 = printed 135 (IAR-3 Skull Smasher), p146 = printed 145 (IAR-5 Hellfire). Render and read their numbers. p039 is lore |
| `substituted_digits` | 54 pages | the whole equipment and vehicle run carries it. **p098 (printed 97, the missile chart) has 19**, p161 (160, Death Bringer) 8, p075 (74, EOD) 6. Money lines read `!D4xlOOO`. Read the token as the dice it can only be; a render does not fix it |

## The book's authority tables

| cache page | printed | table | states |
|---|---|---|---|
| **p004-p007** | 3-6 | *Contents* and a second, alphabetical index | the page of every class, weapon, armor, power armor, robot and vehicle. The alphabetical index (cache p007) carries **no page numbers** in the text layer; use the first |
| **p068** | 67 | the CS O.C.C. roster | fifteen CS military O.C.C.s, **six of them marked as defined in the Rifts RPG** (Psi-Hound/Dog Pack, Grunt, Military Specialist, Psi-Stalker, RPA Elite/SAMAS Pilot, Technical Officer). The other nine are defined here |
| **p059-p061** | 58-60 | *Alphabetical List of Skills* | every skill the military O.C.C.s draw on, 27 of them marked new |
| **p098** | 97 | *Missile Chart* | short, medium and long range missile warheads with damage, range and blast radius |
| **p225** | 224 | *Experience Tables* | the XP ladders, grouped by class. Every class defined here has one |

## Inventory

Counted by structure over all 226 cached pages.

| section | printed | what is there |
|---|---|---|
| Campaign, enemies, allies, CS law, slang | 8-34 | lore. **2 notable NPCs** with full stat blocks: Erin Tarn (15, cache p016) and Sir Winslow Thorpe (17, cache p018) |
| The CS Army, hierarchy, missions, GM tips | 35-49 | lore |
| Chain of command, salaries, hazard pay, brevet rank, specialists, uniforms, medals | 50-58 | tables for play. Nothing the schema holds |
| Shell-shock rules | 58 | a setting rule, prose |
| Skills: list and new-skill descriptions | 58-66 | **27 skills marked new** (see the diff) |
| CS military O.C.C.s | 67-88 | **9 O.C.C.s** plus the Hand to Hand: Commando skill (71-72) |
| CS weapons and equipment | 89-104 | **about 30 gear rows**: pistols, rifles, heavy weapons, the C-200 rail gun, CR-1 rocket launcher, explosives, grenades, vibro-blades, the Neural Mace; the missile chart (97); **six body armors** CA-1/2 (old style), CA-3, CA-4, CA-5 with the CAJ-5 weapon arm, CA-6C, CA-6EX, CA-7 |
| Power armor | 105-121 | **7**: Mauler, Terror Trooper, Glitter Boy Killer, Old Style Death's Head SAMAS, Smiling Jack light assault SAMAS, Super SAMAS, Special Forces Striker SAMAS |
| Skelebots | 122-133 | old and new style Skelebots, and three experimental: Hunter, Hellion, Centaur |
| Robot vehicles | 134-149 | **6**: IAR-2 Abolisher, IAR-3 Skull Smasher, IAR-4 Hellraiser, IAR-5 Hellfire, CR-004 Scout Spider-Skull Walker, CR-005 Scorpion-Skull Walker |
| Ground vehicles | 150-159 | **5**: Mark VII Slayer APC, Mark IX EPC, CTX-50 Line Backer, CTX-52 Sky Sweeper, CTX-54 Fire Storm mobile fortress |
| Aircraft and hovercraft | 160-177 | **11**: Death Bringer APC, APC Sky Lifter, Command Car, Scarab Officer's Car, Skull Patrol Car, Scout Rocket Cycle, Warbird Rocket Cycle, Wind Jammer Sky Cycle, Black Lightning and Demon Locust helicopters, Talon stealth jet |
| ISS, NTSET, Psi-Net | 178-196 | **6 O.C.C.s** and **1 notable NPC**, Lt. Jack "Crazy" Cavanaugh (NTSET, stat block 189-190, cache p190-p191) |
| The Burbs | 197-201 | lore |
| Burbs D-Bees | 202-210 | **6 R.C.C.s** |
| Burbs monsters | 211-213 | **3 creatures**: Devil Sloth, Vampire Flat Worm, Spiny Ravager |
| The Prosek regime | 214-219 | **4 notable NPCs**: Emperor Karl Prosek, Joseph Prosek II (both cache p216), General Joseph Cabot (cache p218), General Ross Underhill (cache p219). The Prosek family (216) and General Renton (19) are prose, no stat block |
| Adventures | 220-223 | hooks. Nothing to import |

### Things this book has zero of, checked rather than assumed

- **Spells: none defined.** Sixteen cache pages carry `P.P.E.`. Every one is
  a notable NPC's, a D-Bee's or a monster's pool, or prose (the RCSG
  Scientist's ley-line abilities on p084, a Psi-Net aside on p194). None is a
  spell stat block.
- **Psionic powers: none defined.** The Psi-Net and NTSET O.C.C.s pick from
  the existing catalog.

## Classes

### Playable CS military O.C.C.s (9) — printed 67-88

Pages are from the Contents (cache p005) and the `Attribute Requirements`
line, which is the one marker every class carries.

| class | printed | attributes line (cache) | proposed id |
|---|---|---|---|
| CS Cyborg Strike Trooper | 69-70 | p070 | `cs-cyborg-strike-trooper` |
| CS Commando | 71-73 | **p072, welded** | `cs-commando` |
| CS EOD Specialist | 73-75 | p076 | `cs-eod-specialist` |
| CS Juicer | 76-78 | p078 | **decision needed**, see below |
| CS Nautical Specialist | 79-80 | p080 | `cs-nautical-specialist` |
| CS Ranger / Wilderness Scout | 80-82 | p081 | `cs-ranger` (`ranger` is taken) |
| CS RCSG Scientist | 82-84 | p084 | `cs-rcsg-scientist` |
| CS RPA "Fly Boy" Ace | 84-86 | p085 | `cs-rpa-fly-boy-ace` |
| CS Special Forces | 86-88 | p088 | `cs-special-forces` |

**The CS Juicer collides.** Production holds `coalition-juicer`, imported from
Juicer Uprising p.41-45. Coalition War Campaign is the later book and reprints
the class at printed 76-78. The rule here is *the later book wins and the
losing number is recorded*, which means **re-citing and correcting the
existing row**, not adding a second one. Diff the two at class-import time.

The six **"see Rifts RPG"** classes on p068 are not defined here. Five are in
production from RUE (`coalition-grunt`, `coalition-samas-pilot`,
`coalition-technical-officer`, `dog-boy`, `psi-stalker`). **CS Military
Specialist is not**, and it belongs to `rue`, not to this book.

### Playable ISS / NTSET / Psi-Net O.C.C.s (6) — printed 178-196

| class | printed | attributes line (cache) | proposed id |
|---|---|---|---|
| ISS Peacekeeper | 180-182 | p182 | `iss-peacekeeper` |
| ISS Specter | 182-184 | p184 | `iss-specter` |
| ISS Intel Specter | 184-185 | p185 | `iss-intel-specter` |
| NTSET Psi-Hound | 187-188 | p188 | `ntset-psi-hound` |
| NTSET Protector / Hunter | 188-189 | p189 | `ntset-protector` |
| Psi-Net Agent (Special Agent) | 193-196 | p195 | `psi-net-agent` |

### Playable D-Bee R.C.C.s (6) — printed 202-210

| class | printed | XP ladder (printed 224) | proposed id |
|---|---|---|---|
| N'mbyr Gorilla Man | 202-203 | D-Bee Vagabond | `nmbyr-gorilla-man` |
| Tirrvol Sword Fist | 203-205 | D-Bee Vagabond | `tirrvol-sword-fist` |
| Quick-Flex Alien (Rogue) | 205-207 | Quick Flex Rogue | `quick-flex-alien` |
| Vanguard Brawler | 207-208 | Vanguard Brawler Thug | `vanguard-brawler` |
| Trimadore | 208-209 | Trimadore Mechanic | `trimadore` |
| Kremin Cyborg | 209-210 | D-Bee Vagabond | `kremin-cyborg` |

Each prints an *Available O.C.C.s (optional)* paragraph letting the race take
an O.C.C. instead of its R.C.C. skills. That is prose.

**Check every id against production before emitting.** The check on
2026-09-25 was a `LIKE` over `class_id`, not a matcher.

## Catalog diff

Run against **production** (`--remote`) on 2026-09-25.

### skills: 27 marked new, 0 genuinely missing

`node scripts/catalog-diff.mjs --remote --table skills --entries <the 27>`
against 390 rows returned **matched 20** (two by alias: Boat: Warships & Patrol
Boats and Boat: Water Scooters), **missing 7**. Six of the seven are false gaps,
held under RUE's names:

| the book prints | the catalog holds |
|---|---|
| Field Armorer | Field Armorer & Munitions Expert |
| Find Contraband, Weapons & Cybernetics | Find Contraband |
| Imitate Voices/Impersonation | Impersonation, and Imitate Voices & Sounds (RUE split it) |
| Lore: Psychic | Lore: Psychics & Psionics |
| Nuclear, Biological, & Chemical Warfare | NBC Warfare |
| Underwater Demolitions | Demolitions: Underwater |

**Armorer is a false gap too**, settled 2026-09-25 by reading printed 61: the
book's *Military: Armorer* is 40% +5% and includes Basic Mechanics, which is the
skill RUE renamed Field Armorer & Munitions Expert (40/5 in the catalog). **This
book adds no skills.** A class naming Armorer grants the catalog row.

### classes: 20 new, 1 collision

No class from this book is in `imported_classes`. `ranger` exists (RUE, the
wilderness scout) and is a different class, hence `cs-ranger`. The CS Juicer
collides with `coalition-juicer`, above.

### gear: almost everything new; two estimate rows this book prices

Production had 2,900 gear rows. By name: `C-10`, `C-12` and `C-18` are in from
RUE (257-258), with `Neural Mace` and the RUE vibro-blades; `CA-1`/`CA-2` and a
generic `Coalition Dead Boy Body Armor` are in from RUE 261-270. Everything else
in printed 89-104 is absent, including the C-5, C-20, CP-30, CP-40, CP-50,
C-29, CV-212, CTT-M20, CTT-P40, C-200, CR-1 and CA-3 through CA-7.

Two rows are **estimates this book replaces**: `C-14 Fire Breather Assault
Rifle` and `C-27 Heavy Plasma Cannon` both cite *Estimate - no published price
found*, and Juicer Uprising names them without stats. CWC prints both (91 and
93). Update those rows rather than adding new ones.

The **missile chart** (printed 97) has no gear-row equivalent in the catalog.
No `* Missile` rows exist, and vehicles name their missiles in prose.

**Run `catalog-diff --remote --table gear` on the extracted list before writing
SQL.** The name check above is not a matcher.

### vehicles: 0 of about 35 present

No CS power armor, Skelebot, robot, ground vehicle or aircraft is in `vehicles`.
The only SAMAS rows are other books' variants (New West, Free Quebec, Spirit
West), and the one SAMAS in `gear` is an estimate row (`Samas Power Armor`).
Free Quebec's survey records the **QR-2 Abolisher Prime** as redirecting here,
to the IAR-2 Abolisher (printed 134).

### creatures and notable NPCs: 0 present

No row in `creatures` or `notable_npcs` for any of the three monsters, the six
D-Bees, or the seven named NPCs.

## Extraction plan

Everything above was free. Proposed, one PR each, applied `--remote` before the
PR, in this order so that class-check finds real gear rows instead of stubs:

1. **Registry and survey**: this file and the `books.json` entry.
2. **Weapons and armor** (printed 89-104): about 30
   gear rows, the two estimate rows updated, every number read off a render for
   the welded p090 and the substituted-digit pages.
3. **The nine CS military O.C.C.s**, plus the CS Juicer resolution.
4. **The six ISS / NTSET / Psi-Net O.C.C.s.**
5. **The six Burbs D-Bee R.C.C.s.**
6. **Power armor and Skelebots** (printed 105-133), into `vehicles` with
   `vehicle_weapons`.
7. **Robots, ground vehicles and aircraft** (printed 134-177), same tables.
   Probably two PRs; the aircraft run is long.
8. **Creatures and notable NPCs**: the 3 monsters, the 6 D-Bees as their NPC
   view, and the 7 named NPCs, through the Phase 3 pipeline.

What is deliberately left, with the reason:

- The six "see Rifts RPG" O.C.C.s. They are defined in RUE, and CS Military
  Specialist's absence is RUE's gap.
- Salaries, hazard pay, brevet rank, uniforms and medals (50-58): campaign
  tables, nothing the schema holds.
- Shell-shock rules (58): a setting rule.
- The missile chart (97) as rows: no missile table exists. Vehicle payloads cite
  it in prose.
- General Renton and the Prosek family: prose, no stat block.
- Adventures (220-223): G.M. prose.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-25 | — | cache built (226 pp, text layer), survey written, offset +1 verified at five folios, `cwc` registered in `books.json` |
| 2026-09-25 | [#1377](https://github.com/NateGrey0130/nates-workshop/pull/1377) | registry and survey. MERGED |
| 2026-09-25 | [#1388](https://github.com/NateGrey0130/nates-workshop/pull/1388) | `add-cwc-gear.sql`: 20 new rows (11 weapons, the micro-fusion rifle grenade, the giant vibro-sword, CA-3 through CA-7, the CAJ-5 arm). `zzzzzzzzzzzzz-cwc-fill-estimate-gear.sql`: C-14, C-27 and the explosive, fragmentation and smoke grenades filled from estimate or web-reference rows. RUE's C-10, C-12, C-18, Neural Mace, vibro-blades and CA-1/CA-2 stand, RUE being the later book. Every number off a render; `book-reconcile` 25 rows, one short citation fixed. Applied `--remote` before the PR: gear 2900 -> 2920, 25 rows cite the book |
| 2026-09-25 | [#1398](https://github.com/NateGrey0130/nates-workshop/pull/1398) | eight new classes, one `add-<id>-class.sql` each: `cs-cyborg-strike-trooper` (the book heads it Coalition Cyborg Strike Trooper; Light and Heavy chassis as variants), `cs-commando` (Hand to Hand: Commando, unchangeable), `cs-eod-specialist`, `cs-nautical-specialist`, `cs-ranger`, `cs-rcsg-scientist` and `cs-special-forces` (their pick-four specialty areas as `skills.mos`), `cs-rpa-fly-boy-ace`. `zzzzzzzzzzzzzzz-cwc-recite-coalition-juicer.sql` replaces `coalition-juicer`'s markdown with the CWC printing (p.76-78), Juicer Uprising's differing figures kept in its extraction_notes; the class_id is unchanged. All men-of-arms, humans only. 0 stub rows. `book-reconcile` over all nine: one fix (the Fly Boy's armor choice is CA-3 or CA-4; CA-1 is the ISS's, printed 104). Applied `--remote` before the PR: 9 live classes cite the book |
| 2026-09-25 | ISS/NTSET PR | six new classes, one `add-<id>-class.sql` each: `iss-peacekeeper`, `iss-specter`, `iss-intel-specter` (printed 180-185), `ntset-psi-hound`, `ntset-protector` (187-189) and `psi-net-agent` (193-195, headed PRP/Psi-Net Agent). The Psi-Hound is a mutant dog taking an NTSET O.C.C.; the book defers the dog's powers to the Rifts RPG, so it carries `dog-boy`'s racial package plus the NTSET skills and bonuses, standalone like `dog-boy`, `occ_group: psychic`. The ISS classes and the Protector are men-of-arms; Psi-Net is psychic and stores no psionics block, because the book prints none for the class. The Intel Specter's save line is misprinted in the book (printed 184); stored as +1 vs magic illusion, mind control and possession at levels 1 and 12, the reading recorded in its extraction_notes. Investigation (ISS and Psi-Net) has no catalog skill row and is special-ability prose. 0 stub rows. `book-reconcile` over all six: no disagreements. Applied `--remote` before the PR: 15 live classes cite the book |
