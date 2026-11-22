# Rifts World Book 36: Sovietski — survey

**Status:** `importing` — skills, weapons and armor shipped, bionics, the Cyberlink section and the bionic weapons and tools shipped (pp.157-168); all eighteen vehicles (the Volkhov and Sadko ekranoplans, the Red Squall, the Stormbringer, the Firefang, the Snow Leopard, the Red Lightning, the Street Sickle, the Road Hammer, the Black Water, the Thunderspear, the Earthquake, the Shockwave, the Tunguska, the Iron Forge, the Torrent, the Storm Swell and the Typhoon II, pp.169-212) and the 11 tank rounds (pp.190-192) shipped; all ten cyborg bodies (the Proletariat Light Machine, the Sovietski Heavy Machine, the Firebird, the Whirlwind, the Rusalka, the Thunderfist, the Tsar "Big Ivan", the Bionic Birds of Prey and the Canine and Bear Cyborgs, pp.128-155) shipped; the Gridgitz and the Shu-Shuum D-Bees (pp.64-68) shipped as creatures rows and R.C.C.s, the Wolverine People and the Yaganar next. (2026-11-22)

**Rows citing this book:** classes 2, gear 106, vehicles 29, skills 7, creatures 2

Slug `sovietski`. Cached 2026-11-22 from
`Rifts - World Book 36 - Sovietski.pdf`, 221 PDF pages, **text layer** (no OCR).
`--probe` median 5,849 chars/page, 34.4% stop words, 0.0% private-use glyphs, so
the words survive. First printing March 2018, by Aten, Orr and Siembieda.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

This is the **third Russia book**, and it is a re-do, not a sequel. `warlords-of-russia`
(WB17) already printed "the Sovietski" as its last 24 pages (printed 201-224: one
NPC, three class blocks, five cyborg bodies, three weapons). WB36 rebuilds that
setting as a whole book: its Police Officer and Infantry Soldier carry the very
same XP ladder and attribute floor as the held WB17 rows, while its cyborg
bodies, vehicles, armor and weapons are almost all new names. `mystic-russia`
(WB18) holds the Sovietski's magic and the Warlords' tanks; WB36 uses none of it.
**The book defines no spell and no psionic power as a catalog row**: the only
`I.S.P.:` lines are the Cold Born's own class powers (printed 92-94, about eight)
and the D-Bee racial blocks (Gridgitz healing at 65, Wolverine People at 72), and
the `P.P.E.:` lines are D-Bee racial stats, the Cold Born's remainder (94) and
one Spetsnaz M.O.S. at 122 whose practitioners choose their spells from the
catalog's existing lists (the book prints no new spell for it).

## Page offset

**Read from `scripts/books.json`**, which records `page_offset` **-4** (the last
region's, so that printed 224 + offset = cache 220 fits the 221 cached files) and
`page_offset_exceptions` that resolve every printed page below to its cache
page, both halves of each spread included. The measured reading, so nobody
re-derives it:

`page_offset` is **not constant**: five cache pages are **double-page spreads**
(PDF page width 1,166 pt against 605 pt for every other page), each holding two
printed pages. Found with `pymupdf` page rects over all 221 pages, then
confirmed by folio. The spreads are cache `p037` (printed 36-37, a full-spread
art page, 6 characters), `p178` (printed 178-179), `p193` (printed 194-195),
`p194` (printed 196-197) and `p197` (printed 200-201, art, 8 characters).
**No printed page is missing**: the folio gaps are the spreads.

| printed pages | cache page for printed F | offset (cache = F + k) |
|---|---|---|
| 1-35 (cache `p002` reads 1) | `p<F+1>` | **+1** |
| 36-37 | `p037` | spread |
| 38-177 | `p<F>` | **0** |
| 178-179 | `p178` | spread |
| 180-193 | `p<F-1>` | **-1** |
| 194-195 | `p193` | spread |
| 196-197 | `p194` | spread |
| 198-199 | `p<F-3>` | **-3** |
| 200-201 | `p197` | spread |
| 202-224 | `p<F-4>` | **-4** |

Checked at the folio on: `p005` reads 4, `p037` (spread), `p100` reads 100,
`p177` reads 177, `p179` reads 180, `p192` reads 193, `p194` reads 197,
`p195` reads 198, `p198` reads 202, `p220` is the Experience Tables (printed
224). `printed_pages` is 224; cache `p221` is the back-cover ad page (no folio),
and `p001` is the cover (0 characters). **A spread's cache file holds both
printed pages' text in one run**, so a stat block that crosses the fold needs a
render; `read-columns.py` on a spread splits more than two columns.

## Cache health

| key | value |
|---|---|
| `text_layer` | true |
| `welded_pages` | **2** — cache `p009` and `p024`, both history prose, no stat block |
| `corrupt_pages` | **0** |
| `substituted_digits` | **46 pages**; worst are `p177` (6), `p195` (5), `p205` (5), then `p174`, `p188`, `p189`, `p192`, `p207` (4 each) |

**The digit cipher lands on the vehicle weapon blocks** (the worst seven pages
are all in the vehicles chapter), so every damage, range and payload figure there
is read as the dice expression it can only be, and every *M.D.C. by Location*
block is read off a render. The cache loses column geometry on those blocks
(`p193` shows an Earthquake weapon block running on into `p194`).

## The book's authority tables

| printed | table | states |
|---|---|---|
| **224** (cache `p220`) | *Experience Tables* | **twelve ladders** — the roster of what levels |
| **4-7** | Contents | section pages, with the sub-entries (every vehicle, armor, weapon and bionic section named with its page) |
| **6-8** | *Quick Find Index* | a second index, alphabetical by topic, with the page of each entry |

**The Experience Tables are the more valuable page.** The twelve ladders:

| ladder | covers |
|---|---|
| 1 | Cold Born and Wolverine People |
| 2 | Cyborg Soldier: Light Machine |
| 3 | Cyborg Soldier: Heavy Machine |
| 4 | Cyborg Soldier: Superheavy Machine |
| 5 | Sovietski Police Officer, Gridgitz and Infantry Soldier |
| 6 | Tanker |
| 7 | Spetsnaz / Special Forces |
| 8 | Vedmak Cyber-Doc |
| 9 | Commissar |
| 10 | Citizen |
| 11 | Shu-Shuum |
| 12 | Yaganar (Elemental Being) |

(Counted by heading on 2026-11-22: twelve ladders, and the Spetsnaz and the
Cyborg Soldier's three bodies each carry their own.) **Every class and playable
D-Bee the book defines has a ladder.** Ladder 5 lines up with the held
`sovietski-police-officer` and `sovietski-soldier` (WB17 printed 210-214): its
level thresholds are identical to the held `xp_table` through level 12, and the
Police Officer's attribute floor (I.Q. 9, P.S. 9, P.E. 10, printed 100) is the
held row's.

**Costs and levels are printed once**, in the entry. Nothing here has a second
table to reconcile against except the Contents and Quick Find for page numbers.

## Inventory

Counted by stat-block marker over all 221 cached pages, never by name.

| section | printed pages | what is there |
|---|---|---|
| setting, history, government, foreign relations | 8-31 | prose only; no stat block (General Goll, the Warlords and the Politburo are lore) |
| cities, towns | 32-43 | prose; the Crypt, Kaliningrad, Kurlensk, Volga Fortress |
| underground bunkers | 43-50 | seven random tables (size, components, secondary function, accommodations, vehicles, condition, occupants) |
| life in the Sovietski | 51-63 | views on magic and psionics, seven religious enclaves (53-56), the Dead Zone Effect Table (56-60), holidays, veterans, the Small Talk Table (62) |
| D-Bees accepted | 64-78 | **4 playable D-Bees**: Gridgitz (64-66), Shu-Shuum (66-68), Wolverine People (68-73, with a Military Training / M.O.S. package block at 71-72), Yaganar (73-78); others named at 78 |
| the Sovietski Army | 79-86 | prose, branch descriptions, a ranks table (86) |
| new and revised skills | 87-90 | **4**: Contacts - Social Connections, Falconry, Skiing and Snowboarding, Law - Loopholes |
| O.C.C.s | 90-128 | **9 classes**: Cold Born (90, with an M.O.S. package block at 94), Cyborg Soldier (95), Police Officer (98), Infantry Soldier (101), Tanker (106), Vedmak Cyber-Doc (108), Spetsnaz Intel (115), Commissar (124, non-combatant), Citizen (127, non-combatant) |
| cyborg bodies | 128-155 | **10 bodies**: Proletariat Light Machine (128), Sovietski Heavy Machine (132), Firebird (134), Whirlwind (136), Rusalka (139), Thunderfist (142), Tsar "Big Ivan" (145), plus three enhanced-animal groups: Bionic Birds of Prey (148), Canine Cyborgs (150), Bear Cyborgs (153) |
| cybernetics and bionics | 155-169 | a salvage rule and an installation table (156), notable systems (157), **Cyberlink** (159), bionic weapons and tools (163); **84 `Cost:` lines** across 155-168 |
| combat vehicles | 169-212 | **18 vehicles**: 2 ekranoplans, Red Squall, Stormbringer, Firefang (air); Snow Leopard, Red Lightning, Street Sickle, Road Hammer, Black Water (ground); Thunderspear, Earthquake, Shockwave, Tunguska, Iron Forge (tanks); Torrent, Storm Swell, Typhoon II (water); plus tank rounds (190-192, 11 kinds), Sunburst missile, Chaff Dispenser, Smoke Launcher, Mini-Torpedo Launchers, Medium Torpedo, sonar and decoy systems |
| body armor | 212-216 | **7**: SA-107, SA-108, SA-109, SA-110, SSA-213, SSA-213H, SA-301EBA |
| weapons | 217-223 | special ammo (4), grenades (9) and flares, **8 attachments**, **8 rifles**, **8 unusual weapons** |
| Experience Tables | 224 | the 12 ladders above |

Marker counts that back this (cache pages in each range): `M.D.C. by Location`
headers 44 over the cyborg and bionic pages and 69 over the vehicle pages;
`Weapon Systems` blocks 25 and 27; `Attribute Requirements` 8 across the nine
O.C.C.s, with the Citizen's printed differently; `M.O.S.` 155 hits in 90-127.

### Zero, and checked

- **No spells.** Zero spell blocks outside the Yaganar's elemental powers
  (printed 75-77), which are racial abilities.
- **No new psionic powers as catalog rows.** The Cold Born's eight-odd frost and
  weather powers (printed 92-94) are class abilities with their own I.S.P. cost,
  the same shape as the Gridgitz healing. By the `ability-grants` rule they go in
  the class, not in `psionic_powers`.
- **No notable NPC stat block.** General Goll, the Warlords and the Politburo
  appear with no `Alignment:` line; the history chapters carry no stat block.
- **No new O.C.C.-skill-list** beyond the nine classes' own.

## Classes

### Playable and non-combatant O.C.C.s (9) — pages 90-128

| class | printed | XP ladder (printed 224) | held in production? |
|---|---|---|---|
| Cold Born (Psychic) | 90-95 | 1 | no |
| Cyborg Soldier (Light, Heavy, Superheavy Machine) | 95-98 | 2, 3 and 4 | **partly**: the held WB17 `Sovietski Light Machine Cyborg` and `Sovietski Heavy Cyborg Soldier` bodies are vehicles rows, and `warlord-light-machine`/`warlord-heavy-machine` are Warlord classes; no Sovietski Cyborg Soldier O.C.C. class is held |
| Police Officer | 98-101 | 5 | **yes**: `sovietski-police-officer`, WB17 p.210-212, same ladder |
| Infantry Soldier | 101-106 | 5 | **yes**: `sovietski-soldier`, WB17 p.212-214, same ladder |
| Tanker | 106-108 | 6 | no |
| Vedmak Cyber-Doc | 108-115 | 8 | no |
| Spetsnaz Intel / KGB | 115-124 | 7 | no |
| Commissar (non-combatant) | 124-127 | 9 | no |
| Citizen (non-combatant) | 127-128 | 10 | no |

### Playable D-Bees (4) — pages 64-78

Gridgitz (ladder 5, shared with the Police Officer and Infantry Soldier),
Shu-Shuum (ladder 11), Wolverine People (ladder 1) and Yaganar (ladder 12).
Each has a creature block and a racial R.C.C. page; the Wolverine People carry
a Military Training / M.O.S. package block of their own (71-72). Whether each
is a creatures row, a classes row or both follows the Free Quebec and WB17
precedents and is the row's own check.

**Excluded by the book itself:** none stated as NPC-only. The Commissar and the
Citizen are marked non-combatant, which is a class flag and not an exclusion.

## Catalog diff

Run against **production** (`--remote`) on 2026-11-22, by the table, with
entries typed from the Contents, so each count is of **named entries**:

| table | book entries | matched | missing |
|---|---|---|---|
| vehicles (741 rows) | 18 | 0 | **18** |
| gear (4,976 rows) | 29 | 1 | 28 |
| skills (512 rows) | 4 | 1 | 3 |
| creatures (817 rows) | 4 | 0 | 4 |

### Hand-checked: false gaps and overlaps

- **vehicles: 18 missing, 0 false gaps.** The nearest names are other books'
  machines at distance 11 and up, and none is the same machine. The held Russian
  vehicles are `mystic-russia`'s six (Thunderbolt, Bull Dog, Thundersword,
  Groundthunder, Hailstorm, Maelstrom) and `warlords-of-russia`'s Sovietski
  bodies (`Sovietski Light Machine Cyborg`, `Sovietski Heavy Cyborg Soldier`,
  `Thunderhammer`, `Thunderstrike`, `Thunderstorm`). **WB36 renames the Sovietski
  bodies** (Proletariat, Sovietski Heavy Machine, Firebird, Whirlwind, Rusalka,
  Thunderfist, Tsar): none of the names match a held row, but whether a body here
  is the same machine as a held one is each cyborg row's first check.
- **gear: 28 missing, 1 matched** (the Vibro-Bayonet). Real overlaps with held
  rows the cyborg, armor and weapons rows must decide on, never merge by name:
  `Sovietski "Red Star" Medium Body Armor` (WB17 p.173) against SA-109;
  `Dragunov Sniper (SVD)` (Revised Heroes Unlimited p.201-206 and Nightbane p.216)
  against the Dragunov SVD; `Cyberlink Vehicle Interfacing` (WB17 p.100) against
  the Cyberlink section. `Silencer` and `Flash Suppressor` are held only as
  revolver variants, so the book's are generic attachments and a distance-0 match is
  a false match. Everything else (the Kalashnikovs, the Groza, the Vibro-Sickle,
  the Chainsaw Glaive, the Vibro-Scythe, the Bear Tooth, the Harpoon Laser Pistol,
  the Ballistic Knife) has no held counterpart.
- **skills: 3 missing, 1 matched.** `Falconry` matched the held `Falconry`
  (Palladium Fantasy main book p.54), so it is a revision or a reprint, not a gap.
  `Skiing and Snowboarding` is **not clean**: production holds `Snow Skiing` with
  three sub-skills including a snowboarding one (WB20 Canada p.36-37). The row
  decides whether this skill is the same one under a new name. `Law - Loopholes`
  follows the held `Law: <subject>` pattern (`Law: CCW`, Phase World p.151).
  `Contacts - Social Connections` has no counterpart.
- **creatures: 4 missing, 0 false gaps.**

### Not diffed here (a row's first act)

Bionic systems (about 84 priced entries), tank rounds, the bunker and Dead Zone
tables, and the class ability lists are diffed by the row that extracts them,
`--remote`, right before its data script is written.

## Extraction plan

Phase 4 costs money; everything above was free. What gets extracted, in the
order the plan runs it (skills and gear first, since classes cite them, and the
classes last):

1. **4 skills** from pp.87-90 — the held-skill overlaps above decide new row or revision.
2. **Weapons, ammo, grenades, attachments** from pp.217-223 (about 37 entries).
3. **7 body armors** from pp.212-216.
4. **Bionics, Cyberlink and bionic weapons** from pp.155-169 (about 84 priced entries).
5. **18 vehicles** and their sub-systems from pp.169-212, eight rows of two or three.
6. **10 cyborg bodies** from pp.128-155, on the WB17 cyborg precedent (`vehicles` rows of class `borg`).
7. **4 D-Bees** from pp.64-78.
8. **9 O.C.C.s** from pp.90-128, with the 12 ladders on p.224 (cache `p220`).

What is deliberately left, with the reason for each:

- History, government, foreign relations, cities and the Army chapter (8-43,
  79-86) — prose; no catalog table holds setting text.
- The bunker tables (43-50), the Dead Zone Effect Table (56-60), the Small Talk
  Table (62) and the religious enclaves (53-56) — random tables and lore with no
  table to land in; the plan's last row (58) files them as a gap in
  `BOOK-INGEST-AUDIT.md`, not implemented.
- The Mad Doctor Table (110) and the Soldier's Motivation/Origin Table (102) —
  class-specific roll tables; left out and filed in the same gap by row 58, not
  imported as rows.
- The Experience Tables as their own rows — each ladder is stored on its class.

## Ledger

One line per PR, written in that PR before it opens. The second column is the
PR's **branch**, which exists before the PR does.

| date | branch | what went in |
|---|---|---|
| 2026-11-22 | — | cache built (221 pp, text layer), five spread pages and the offset map found, survey drafted |
| 2026-11-22 | `pal/docs/sovietski-register-survey` | book registered in `scripts/books.json` (`page_offset` -4 with five `page_offset_exceptions`, the map also in its `note`; `cacheCoverage` reads 221 cached against 220 needed, complete); this survey committed; no rows |
| 2026-11-22 | `pal/data/sovietski-skills` | 7 skills rows from pp.87-90 in `~379-sovietski-skills.sql`: Contacts - Social Connections, Ballet, Biathlon, Ice Skating (Sovietski), Skiing and Snowboarding, Kremlinology, Law: Loopholes. The pages print 8 skills, not the 4 the inventory counted; Falconry matches the held row and adds nothing |
| 2026-11-22 | `pal/data/sovietski-weapons` | 34 gear rows from pp.217-223 in `~380-sovietski-weapons.sql`: 5 special rounds, 4 grenades and a parachute flare, 8 attachments, 8 rifles and 8 unusual weapons. 39 items printed; the plasma, stun/flash, tear gas and smoke grenades and the handheld flare are left out as held with the same figures. Where a held row of the same name prints different figures (fragmentation grenade, parachute flare, Vibro-Bayonet, Dragunov SVD, silencer, flash suppressor) this book's item is its own row |
| 2026-11-22 | `pal/data/sovietski-armor` | 9 gear rows from pp.212-216 in `~381-sovietski-armor.sql`: the 7 body armors, SA-110 Red Nova as its three printed grades (HMA, HMB, HMC). SA-109LMM is a new row beside the held WB17 Red Star Medium Body Armor, which prints different figures |
| 2026-11-22 | `pal/data/sovietski-bionics-a` | 9 gear rows (category cybernetics) from pp.157-159 in `~382-sovietski-bionics-a.sql`: Advanced Remote Hand, Built-In Loudspeaker, Video Finger Camera, Climb Cord, the pirated-Triax Combat Computer with its CCREP and CCMEP programs, Cyber-Crampons and CNRRS. Camera Finger is left out as a reprint of the held Universal Finger Camera; the pirated Combat Computer is its own row beside the held New West one, which prints different figures. The section opening's salvage rule and Unauthorized Vendors table (pp.155-157) are not rows; Cyberlink and Cyber-Skates are a later row's |
| 2026-11-22 | `pal/data/sovietski-cyberlink` | 22 gear rows (category cybernetics) from pp.159-163 in `~383-sovietski-cyberlink.sql`, the Cyberlink entry through Stabilizing Anchors: the revised Cyberlink Vehicle Interface, Cyber-Skates, -Skis and -Snowshoes, two finger systems, four eye systems, Hardened Circuits, Internal Energy Supply, four medical systems, the NAMC, the Oxygen Storage Cell, Secret Compartments, the standard Sensor Hand, the Speedometer and the Stabilizing Anchors. Six of them (the Cyberlink, Wide-Angle Vision, Epidermic Analyzer, Internal Energy Supply, Medical Sensor Hand, Stabilizing Anchors) print figures a held row does not and are their own rows beside it; 17 reprints of held rows with the same figures are left out (named in the script header). Bionic Weapons and Tools (p.163 on) is a later row's |
| 2026-11-22 | `pal/data/sovietski-bionic-weapons` | 21 gear rows (category cybernetics) from pp.163-168 in `~384-sovietski-bionic-weapons.sql`, the Bionic Weapons and Tools section from its heading to the Weapon to Cyborg Energy Link: three forearm blasters, Bulletdusters, the M.D. Chainsaw, the Chemical Spray (named `Chemical Spray (Sovietski)` beside the held New West mining tool), Clawed Feet, Crab Claw hands, the Cyber-Bow and Cyber-Quiver, the E-Clip Port, Extendible Legs, three ammo drums, Legs of Leaping, the Net Launcher, Quick Draw Holsters (Triax Tech), the Shoulder Turret and its Auto-Attack Program, and Tentacles. Seven reprints of held rows with the same figures are left out (named in the script header) |
| 2026-11-22 | `pal/data/sovietski-v1` | 3 vehicles rows from pp.169-176 in `~385-sovietski-v1.sql`: the Novyet N-1051 Volkhov and N-1082 Sadko ekranoplans and the SUMi-185 Red Squall, with 28 `vehicle_locations` and 10 `vehicle_weapons` rows |
| 2026-11-22 | `pal/data/sovietski-v2` | 2 vehicles rows from pp.176-182 in `~386-sovietski-v2.sql`: the SUMi-224 Stormbringer gunship and the SUT-93 Firefang fighter, with 24 `vehicle_locations` and 13 `vehicle_weapons` rows. The Sunburst bays and the Chaff Dispenser are weapon rows on the Firefang, not vehicles |
| 2026-11-22 | `pal/data/sovietski-v3` | 3 vehicles rows from pp.182-187 in `~387-sovietski-v3.sql`: the SM-150 Snow Leopard combat snowmobile, the SM-212 Red Lightning fast-attack motorcycle (its three sidecars as locations and weapon rows) and the SM-349 Street Sickle cyborg trike, with 23 `vehicle_locations` and 9 `vehicle_weapons` rows |
| 2026-11-22 | `pal/data/sovietski-v4` | 13 rows in two scripts. `~388-sovietski-v4.sql`: 2 vehicles rows from pp.187-189, the SM-420 Road Hammer assault squad vehicle and the SM-451 Black Water amphibious APC, with 26 `vehicle_locations` and 7 `vehicle_weapons` rows. `~389-sovietski-v4-rounds.sql`: 11 gear rows from pp.190-192, the 11 kinds of tank round |
| 2026-11-22 | `pal/data/sovietski-v5` | 2 vehicles rows from pp.192-197 in `~390-sovietski-v5.sql`: the SU-40 Thunderspear anti-aircraft tank and the SU-45 Earthquake medium battle tank (its SU-45b EarthARK bridge-layer variant described in the row, not a row of its own), with 28 `vehicle_locations` and 9 `vehicle_weapons` rows |
| 2026-11-22 | `pal/data/sovietski-v6` | 2 vehicles rows from pp.197-203 in `~391-sovietski-v6.sql`: the SU-56 Shockwave heavy tank and the SU-58 Tunguska super-tank and mobile command center, with 41 `vehicle_locations` and 12 `vehicle_weapons` rows |
| 2026-11-22 | `pal/data/sovietski-v7` | 2 vehicles rows from pp.204-207 in `~392-sovietski-v7.sql`: the SU-90 Iron Forge mobile cyborg hospital and the SN-247 Torrent fast-attack gunboat (its medium torpedoes a weapon row, not gear), with 25 `vehicle_locations` and 8 `vehicle_weapons` rows |
| 2026-11-22 | `pal/data/sovietski-v8` | 2 vehicles rows from pp.207-212 in `~393-sovietski-v8.sql`: the SN-357 Storm Swell submarine and transport and the SN-686 Typhoon II ballistic missile submarine, with 29 `vehicle_locations` and 7 `vehicle_weapons` rows. The sonar, decoy and stealth systems print no cost, so they are features in each description, not gear rows |
| 2026-11-22 | `pal/data/sovietski-cyborgs-a` | 2 vehicles rows (class `borg`) from pp.128-133 in `~394-sovietski-cyborgs-a.sql`: the Proletariat Light Machine and the Sovietski Heavy Machine Combat Cyborg, with 17 `vehicle_locations` and 4 `vehicle_weapons` rows. They are new rows beside the held WB17 `sovietski-light-machine-cyborg` and `sovietski-heavy-machine-cyborg`, which print different figures and stay untouched |
| 2026-11-22 | `pal/data/sovietski-cyborgs-b` | 2 vehicles rows (class `borg`) from pp.134-138 in `~395-sovietski-cyborgs-b.sql`: the Firebird and the Whirlwind Heavy Machines, with 20 `vehicle_locations` and 9 `vehicle_weapons` rows. Neither has a held WB17 counterpart |
| 2026-11-22 | `pal/data/sovietski-cyborgs-c` | 2 vehicles rows (class `borg`) from pp.139-145 in `~396-sovietski-cyborgs-c.sql`: the Rusalka and the Thunderfist Superheavy Machines, with 21 `vehicle_locations` and 9 `vehicle_weapons` rows. Neither matches a held WB17 body by M.D.C. The Thunderfist's M.D.C. table prints `Arms (4)` twice (150 and 210), stored as two locations with the doubling noted |
| 2026-11-22 | `pal/data/sovietski-cyborgs-d` | 3 vehicles rows (class `borg`) from pp.145-150 in `~397-sovietski-cyborgs-d.sql`: the Tsar "Big Ivan" Superheavy Machine and the Bionic Birds of Prey as two rows (falcon or hawk, and steppe eagle), because every figure differs between them, with 21 `vehicle_locations` and 8 `vehicle_weapons` rows. The 70,000-credit partial cyborg bird has no M.D.C. and is a cost note, not a row |
| 2026-11-22 | `pal/data/sovietski-cyborgs-e` | 2 vehicles rows (class `borg`) from pp.150-155 in `~398-sovietski-cyborgs-e.sql`: the Canine Cyborg and the Bear Cyborg full conversions, with 10 `vehicle_locations` and 6 `vehicle_weapons` rows. Neither matches a held WB17 body; each partial conversion is a cost note, not a row |
| 2026-11-22 | `pal/data/sovietski-dbees-a` | 4 rows in three scripts. `~399-sovietski-dbees-a.sql`: 2 creatures rows from pp.64-68, the Gridgitz and the Shu-Shuum. `add-sovietski-gridgitz-class.sql` and `add-sovietski-shu-shuum-class.sql`: their R.C.C.s, `sovietski-gridgitz` (ladder 5) and `sovietski-shu-shuum` (ladder 11, with `pairing_counts` cutting a paired O.C.C.'s Related and Secondary skills to zero, so regression's pinned `pairing_counts` list gains it) |

### What remains

Everything but the skills, weapons, armor, the bionics chapter (pp.155-168),
all eighteen vehicles (pp.169-212), the tank rounds (pp.190-192) and the
ten cyborg bodies (pp.128-155) and the Gridgitz and Shu-Shuum (pp.64-68): the
Wolverine People and the Yaganar, and the classes (extraction plan steps 7-8).
`node scripts/source-coverage.mjs --remote` on 2026-11-22, after
`~398-sovietski-cyborgs-e.sql` was applied to production, with `WORKSHOP_OCR_CACHE` at the main checkout's `.cache/books`,
prints the book's line under `BY BOOK` (traceable / other) as:

```
  sovietski          142 / 0
```

Its `BACKLOG` block is catalog-wide, not per book, and none of it is this
book's. As it read before this book had rows:

```
BACKLOG       rows an importer created and nobody finished
  gear stubs            13   description still says STUB — created by class import
  skill stubs            5   created by an import and never given a base %, a bonus or a note
  spell stubs           57   level 0 and 0 P.P.E.
  psionic stubs          1   0 I.S.P.
  spell text missing     0   nothing for the codex to show
  psionic text missing   0   nothing for the codex to show
```
