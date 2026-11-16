# Rifts World Book 34: Northern Gun Two — survey

**Status:** `importing` — both new-armour batches shipped (armored clothing, the EB-20, the five Ride Armors and twelve body armours) and the held armours compared against this printing, and all eight power-armour batches shipped (the 29 new power armours), and both hovercycle batches shipped (the nine new hovercycles and the 21 modular hovercycle weapons, housings and radar), and both aquatic batches shipped (the eight vessels and the AquaWalker Tires); the rest of the *Extraction plan* follows. (2026-11-16)

**Rows citing this book:** gear 117, vehicles 46

Slug `northern-gun-2`. Cached 2026-11-16 from
`Rifts - World Book 34 - Northern Gun 2 - PAL888P.pdf`, 258 PDF pages,
**text layer** (`--probe` median 4,324 chars/page, 33.6% stop words).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. One region, no exceptions.

| cache page | folio printed on it |
|---|---|
| `p009` | 8 |
| `p030` | 29 |
| `p081` | 80 |
| `p100` | 99 |
| `p150` | 149 |
| `p200` | 199 |
| `p225` | 224 |
| `p257` | 256 |

`printed_pages` is 256, **set by hand**. The manifest says 79: from printed 80
on, the text layer sets each folio with a space between its digits, and the
folio reader in `ocr-book.py` stops matching. The offset it measured is still
right. Cache `p258` is a back-cover advertisement.

Text-layer damage, by cache page (the manifest's three keys):

- welded: 201, 225 and 258. Printed 200 carries the end of the Sky Wolf's
  weapons and the start of the Alley Cat; printed 224 carries the end of the
  Wolftrack and the start of the Badger. **Read both off a render.** 258 is
  the advertisement.
- glyph-corrupt: none
- digit-substituted: none detected, and the detector misses the kind this
  book has. Cache `p080` prints a weight in `1bs`, a digit standing for a
  letter, which is the reverse of what the detector looks for. Read any odd
  token as the unit or dice expression it can only be.

The text layer loses column geometry on every *M.D.C. by Location* block, as
it did in Northern Gun One: read those off a render when a figure sits oddly.

## The book's authority tables

| page | table | states |
|---|---|---|
| **5-7** | Contents | every armour, power armour, vehicle and drone by name and page, with `(new)` marking the ones first printed here; a power armour's own named weapons and systems are listed under it |
| **7** | *Quick Find Index* | a second index by keyword; a *Notable Power Armor Weapons* list of 36 lines, and four lists of power armour by kind (amphibious, flying, oversized, Xiticix hunters) |
| **161** | *Alphabetical List of Hovercycles* | the 14 hovercycle names with model numbers and the same seven `(new)` marks; it gives the Windshark as NG-SU640-EX where the Contents and the entry's own `Model Type:` line (176) give NG-640, so two readings to one and the entry wins |
| **22** | *Top Fifty Gladiators* | names and standings only; no stats |

The Contents is the one to work from. It is the only place that marks what is
new: 24 of the 32 power armours and 7 of the 14 hovercycles carry the mark.
It has no mark on any body armour, aquatic vehicle, aircraft, land vehicle or
drone, so for those the catalog diff below is the only test of what is new.

**There is no Experience Table.** No page in the book prints a ladder for its
one class, and no sentence points to another class's ladder (searched across
all 258 cached pages for the table's name and for an experience-point
reference: no hit). Northern Gun One's table on its printed 220 has six
ladders and none is this class's. This is the one question the plan needs a
ruling on.

Costs are printed once, in each entry.

## Inventory

Counted by stat-block markers over all 258 cached pages, not by reading prose.
The book holds 135 *M.D.C. by Location* blocks, 79 `Model Type:` lines, 1
class block and 9 full NPC blocks.

| section | printed pages | what is there |
|---|---|---|
| The Robodome | 8-19 | prose and rules for arena matches, purses (15), the sports book (18), restricted robots (18), customising arena robots (19); no stat block |
| Robo-Gladiator O.C.C. | 20-22 | **1 class** |
| Notable Robo-Gladiators | 22-31 | the Top Fifty list (22); **9 full NPC blocks** (23-31), one of them a robot with its own vehicle-style block (the Frankenstein Cyborg, 27-28) |
| Pirates of the Great Lakes | 31-36 | four pirate groups in prose; 8 people given as one line each (level, class, alignment) and nothing else |
| Clientele and the 'Burbs | 37-38 | prose |
| NG armored clothing | 39-43 | **6 clothing lines** and the EB-20 backpack (43) |
| Hovercycle ride armor | 44-47 | **5 suits**, after a shared helmet-features list (44) |
| Other non-environmental armor | 47-51 | **10 suits**, one of them horse barding (47) |
| NG environmental body armor | 52-60 | **18 suits**, after a shared features list (52) |
| Northern Gun power armor | 61-156 | **32 power armours**, each with an *M.D.C. by Location* block and its weapon systems; shared features (61), the UEL system (62, 65) |
| Hovercycles | 157-176 | modular weapon rules and **11 priced modular weapons** (158-160); **14 hovercycles** (161-176) |
| Aquatic vehicles | 177-193 | **8 vessels**; AquaWalker Tires (182) is an option, not a vehicle |
| Jet packs | 193-194 | **4 jet packs** |
| Aircraft | 194-200 | **4 aircraft** |
| Motorcycles | 200-205 | **8 motorcycles** |
| Trucks and cars | 206-224 | **15 vehicles**, the first being the All-Purpose Trailers (206) |
| Combat vehicles | 224-235 | **6 vehicles** |
| Robot drones | 235-250 | **10 drones**; the Cargo Walker's combat kit (239) and the drone control gauntlet (245) are priced extras |
| Adventuring gear | 251-254 | named, priced items: a survival pack and its contents, a lock pick, display glasses, binoculars, rocket boots, a perimeter warning system, tents; counted at extraction |
| Medical Bio-Brace | 254-255 | one item with its own rules |
| Robot and vehicle upgrades | 255-256 | priced options: crew-compartment comforts, storage, a harpoon; counted at extraction |

That is **101 vehicle-shaped entries** (32 + 14 + 8 + 4 + 4 + 8 + 15 + 6 +
10) and **39 armours** (6 + 5 + 10 + 18).

Named weapons a power armour carries in its hands are printed inside that
armour's entry with their own price: the Contents names 6 of them and the
Quick Find's weapon list reaches 36 lines, counting built-in systems too.

**No spell, no psionic power, no creature and no new skill is defined.** The
scan for a P.P.E. or I.S.P. cost line found none. The eight `Psionics:` lines
in the book are the NPC blocks' own.

## Classes

### Playable O.C.C.s (1) — pages 20-22

| class | pages | XP table |
|---|---|---|
| Robo-Gladiator | 20-22 | **none printed**; the Robot Pilot's by ruling (see *Extraction plan*) |

No id collides: production holds no class named Robo-Gladiator. It holds
`Juicer Gladiator`, `Robot Pilot` and two NGR pilot classes, all different
classes from other books.

The class is not marked NPC-only. Three of the nine notable gladiators are
levelled in it.

## Catalog diff

Run against **production** (`--remote`), 2026-11-16, `origin/main` ff7ac6dc.
Production holds 0 rows citing this book.

### vehicles: 87 new, 14 held from older printings

`node scripts/catalog-diff.mjs --remote --table vehicles` over the 101 names
returns **matched 0, missing 101**. Fourteen of the 101 are false gaps, held
under a longer or differently set name:

| the book prints | page | production holds | held row cites |
|---|---|---|---|
| Defender (JAPE II) | 78 | `bm-japeii-defender-exoskeleton` | Juicer Uprising p.80-81 |
| Juicer Killer Power Armor | 106 | `ng-jk1-juicer-killer-power-armor` | Juicer Uprising p.77-79 |
| Samson | 140 | `ng-x9-samson-power-armor` | RUE p.271-272 |
| NG-230 Prowler | 166 | `ng-230-prowler-hovercycle` | Lone Star p.58-59 |
| NG-220 Rocket | 169 | `ng-220-rocket-hovercycle` | Lone Star p.57-58 |
| NG-300 Speedster | 169 | `speedster-hovercycle` | RUE p.266 |
| NG-400 Stinger | 170 | `ng-400-stinger-hovercycle` | Lone Star p.59-60 |
| NG-480 Turbo | 171 | `ng-480-turbo-hovercycle` | Lone Star p.60-61 |
| Sky King Sky Cycle | 197 | `northern-gun-sky-king`, **a gear row, not a vehicle** | original Rifts core book p.228 |
| Highwayman | 202 | `the-highway-man-motorcycle` | RUE p.266 |
| Wastelander | 204 | `the-wastelander-motorcycle` | RUE p.266 |
| Big Boss | 209 | `big-boss-atv` | RUE p.266 |
| Mountaineer Exploration ATV | 213 | `mountaineer-atv` | RUE p.266-267 |
| Rolling Thunder | 217 | `rolling-thunder-apv` | Juicer Uprising p.84-85 |

This book is the newest printing of all 14. The Juicer Killer is also held a
second time as a gear row of the same slug, and the Highwayman likewise.

Checked and not the same machine: the Triax XM-350 Rhino and XM-180
Dragonfly, the Triax X-2750 Talon, the Triax VX-635 Prowler, the Lazlo-area
`old-mule` bicycle, the Phase World Silverhawk. The four jet packs match no
held row; production keeps other makers' jet packs in **gear** (Triax, Japan,
Russia) and one in vehicles (the Techno-Wizard Wing Pack).

### gear (armour): 23 new, 16 held

`node scripts/catalog-diff.mjs --remote --table gear` over the 39 armours
matched one by alias. Hand-checked by family name, sixteen are held:

| the book prints | page | production holds | held row cites |
|---|---|---|---|
| Cavalry Armor for Horses | 47 | `cavalry-armor-barding` | New West p.181 |
| Huntsman | 48 | `huntsman-plate-padded-armor-non-environmental` and `huntsman-armor`, two rows at the same figures | RUE |
| Juicer Assassin Plate Armor | 48 | `juicer-assassin-plate-armor-non-environmental` | RUE |
| Maverick Riding Armor | 49 | `ng-maverick-riding-armor` | New West p.179 |
| Range Rider Armor | 50 | `ng-range-rider-riding-armor` | New West p.179-180 |
| Buffalo Riding EBA | 54 | `ng-buffalo-riding-armor` | New West p.180-181 |
| Bushman Composite EBA | 55 | `bushman-full-composite-environmental-body-armor` | RUE |
| Bushman Trooper EBA | 55 | `bushman-trooper` | RUE |
| Crusader EBA | 55 | `crusader-full-environmental-body-armor` | RUE |
| Explorer EBA | 56 | `explorer-armor`, **no book cited and no M.D.C.; its price is an estimate** | none |
| Gladiator EBA | 56 | `gladiator-full-environmental-body-armor` | RUE |
| Mega-Juicer Combat EBA | 57 | `mega-juicer-combat-armor` | Juicer Uprising |
| Plastic-Man EBA | 58 | `plastic-man-full-environmental-body-armor` | RUE |
| Titan Plate Armor | 59 | `titan-plate-armor` | Juicer Uprising |
| Vibro-Spike Juicer EBA | 60 | `vibro-spike-armor` | Juicer Uprising |
| Urban Warrior Light EBA | 60 | `urban-warrior-padded-environmental-body-armor` | RUE |

Checked and not the same item: `juicer-flex-plate-armor` (an estimate row;
the book's Juicer Ultra-Armor is a different suit), the six `NG "Hunter"`
clothing rows from Adventures in Dinosaur Swamp (a different product line
from this book's Huntsman's Choice clothing), `mdc-armored-trench-coat`
(Australia), `rocket-boots` (Juicer Uprising; compared against the NG-RB-5 at
extraction).

Not diffed by name, because they are counted at extraction: the 11 modular
hovercycle weapons, the power armours' handheld weapons, the adventuring gear
and the upgrades. Production already holds generic tents, canteens, climbing
kits and survival kits from other books; an NG-branded item is a new row only
where the book gives it its own figures.

### classes, NPCs

One class missing, none held. None of the nine gladiators is held.

## Extraction plan

**Approved by Nate 2026-11-16, as written.** One branch per line; gear and
vehicles go before the class that names them.

1. `pal/data/northern-gun-2-armor-a` and `-b`: the 23 new armours and the
   EB-20 backpack (39-60), through `scripts/rows-sql.mjs`.
2. `pal/data/northern-gun-2-armor-held-compare`: the 16 held armours compared
   against this printing; `explorer-armor` takes this book's figures and its
   first citation.
3. `pal/data/northern-gun-2-power-armor-a` to `-h`: the 29 new power armours
   in batches of three or four by page (61-156), through
   `scripts/vessel-sql.mjs`, each batch followed by the handheld weapons its
   armours print with a price, as gear rows.
4. `pal/data/northern-gun-2-hovercycles-a` and `-b`: the 9 new hovercycles
   and the 11 modular weapons (158-176).
5. `pal/data/northern-gun-2-aquatic`, `-jet-packs-aircraft`, `-motorcycles`,
   `-trucks-a` and `-b`, `-combat-vehicles`, `-drones-a` and `-b`: the rest
   of the 87 new vehicles (177-250).
6. `pal/data/northern-gun-2-vehicles-held-compare`: the 14 held vehicles
   compared against this printing.
7. `pal/data/northern-gun-2-adventuring-gear`: the gear, the Bio-Brace and
   the upgrades (251-256).
8. `pal/data/northern-gun-2-npcs-a` and `-b`: the nine gladiators, through
   `scripts/bestiary-sql.mjs`.
9. `pal/data/northern-gun-2-class-robo-gladiator`.
10. `pal/docs/northern-gun-2-close-out`.

Rulings that govern it (Nate, 2026-11-16: the ladder ruled as stated, the
other five taken as proposed):

- **The Robo-Gladiator's experience ladder. RULED (Nate, 2026-11-16): it
  uses the Robot Pilot's.** The book prints none, so this is a ruling and
  not a reading of the page; the class's `extraction_notes` say so, and the
  ladder is copied from production's `Robot Pilot` class (RUE) at import.
- **The 30 held rows.** Proposed as Northern Gun One's were: the newest
  printing that states a figure wins (the 2026-10-04 ruling); a row whose
  figures differ takes this book's figure and citation with the older figure
  in its description, and a row that agrees keeps its older citation.
- **The Sky King.** Held as a gear row citing the original core book.
  Proposed: a vehicles row from this book's block, and the gear row re-cited
  beside it rather than deleted.
- **Jet packs.** Proposed as gear, where production keeps every other
  maker's.
- **Handheld power-armour weapons.** Proposed as gear rows where the book
  prints a separate price, and as that armour's weapon entry where it does
  not.
- **The Frankenstein Cyborg.** A robot NPC with both an NPC block and a
  vehicle-style block. Proposed: one notable NPC row carrying both.

What is deliberately left, with the reason for each:

- the Robodome rules, purses, betting and customising tables (8-19): rules
  for a Game Master, no stat block;
- the Top Fifty list (22): names and standings only;
- the four pirate groups and their 8 one-line people (31-36): organisations,
  and people with a level and class but no block, left as Northern Gun One's
  66 quick-stat people were;
- the clientele and 'Burbs prose (37-38);
- the shared feature lists (44, 52, 61): they describe what every suit of a
  kind has, and go into the rows' descriptions rather than rows of their own.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-11-16 | `pal/docs/northern-gun-2-register-survey` | cache built (258 pp, text layer), offset +1 verified by folio at eight points, inventory and production diff; `northern-gun-2` registered in `books.json` |
| 2026-11-16 | `pal/data/northern-gun-2-armor-a` | 28 gear rows, `~296-northern-gun-2-armor-a.sql`: the 22 Huntsman's Choice and Streetwolf clothing lines (pp.39-43; the survey's count of 6 named the lines, not the priced items), the EB-20 backpack and the five Ride Armors (pp.44-47) |
| 2026-11-16 | `pal/data/northern-gun-2-armor-b` | 12 gear rows, `~297-northern-gun-2-armor-b.sql`: five non-environmental suits (Juicer Ultra-Armor, Patrol, Robot Command, NG-A8 Scout, NG-A10 Soldier) and seven environmental ones (NG-A12 Anti-Ballistic, A25 Bullfrog, Deep Zone Walker, Mud-Skipper, Peacekeeper, Stalker Suit, Trekker Pilot), pp.49-60; the JBA330 and JBA335 share one row, as printed under one heading |
| 2026-11-16 | `pal/data/northern-gun-2-armor-held-compare` | 8 held gear rows re-cited to this book, `~298-northern-gun-2-armor-held-compare.sql`, each taking this printing's figures with the older figure in its description: Juicer Assassin, Maverick, Bushman Trooper, Explorer (first citation; the estimate retired), Gladiator, Mega-Juicer, Titan, Vibro-Spike. The other 9 held rows (Cavalry barding, both Huntsman rows, Range Rider, Buffalo, Bushman Composite, Crusader, Plastic-Man, Urban Warrior) agree with this printing and keep their older citation |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-a` | 4 vehicles, `~299-northern-gun-2-power-armor-a.sql` (pp.61-72): NG-X30 Aurora Blazer (10 locations, 2 weapons), NG-NX12 Beach-Stormer (9, 2), NG-X44 Blue Boy (8, 2), NG-AX19 Blue Hawk (14, 3); 41 locations and 9 weapon entries in all. 2 gear rows, `~300-northern-gun-2-power-armor-a-gear.sql`: the Beach-Stormer's separately priced NG-P67 Particle Beam Short-Gun and NG-M100 Multi-Weapon Underwater Rifle (pp.66-67) |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-b` | 3 vehicles, `~301-northern-gun-2-power-armor-b.sql` (pp.72-77, 80-82): NG-X114 Cougar (15 locations, 7 weapons), NG-X32 Coyote (7, 3), NG-X11 Delilah and Del (13, 4); 35 locations and 14 weapon entries in all. 3 gear rows, `~302-northern-gun-2-power-armor-b-gear.sql`: the Cougar's separately priced forearm flamethrower, the Coyote's NG-X132 Deathmark Dual Sniper Rifle and the Wild Coyote Jet Pack (pp.75-77) |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-c` | 3 vehicles, `~303-northern-gun-2-power-armor-c.sql` (pp.83-94): NG-X44 Demon Slayer (18 locations, 7 weapons), NG-XP54 Enforcer Guardsman (16, 2), NG-XF103 Firefighter (10, 3); 44 locations and 12 weapon entries in all. 8 gear rows, `~304-northern-gun-2-power-armor-c-gear.sql`: the Demon Slayer's seven separately priced Techno-Wizard conversions (p.88) and the Enforcer Guardsman's Advanced Helmet Camera (p.92) |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-d` | 4 vehicles, `~305-northern-gun-2-power-armor-d.sql` (pp.94-106): NG-X33 Forester (11 locations, 5 weapons), NG-EX10 Gladius Light (5, 0), NG-MRU886 Grease Monkey (16, 3), NG-XF17 Ironwing (13, 5); 45 locations and 13 weapon entries in all. 8 gear rows, `~306-northern-gun-2-power-armor-d-gear.sql`: the Hex grenade, the Forester's smoke flares, replacement electronic trail markers and UV paint refills, and the Gladius Light's four priced helmet options (helmet light, head cam, language translator, voice modulation), pp.94-100 |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-e` | 3 vehicles, `~307-northern-gun-2-power-armor-e.sql` (pp.110-123): NG-X112 Lynx (13 locations, 4 weapons), NG-X39 Mantis (13, 4), NG-MRU876 Med-Rec "White Knight" (17, 4); 43 locations and 12 weapon entries in all. 1 gear row, `~308-northern-gun-2-power-armor-e-gear.sql`: the White Knight's separately priced replacement Electronic Med-EVAC Marker (pp.119, 122); its six nano-robot systems are held RUE/Triax rows at the same prices and were left alone |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-f` | 4 vehicles, `~309-northern-gun-2-power-armor-f.sql` (pp.123-133): NG-X16 Midas (13 locations, 5 weapons), NG-UELX45 Night Reaper (6, 1), GCCPA-03 Pit Fighter (9, 13), NG-X67 Prophet (10, 3); 38 locations and 22 weapon entries in all. 20 gear rows, `~310-northern-gun-2-power-armor-f-gear.sql`: the Midas's separately sold giant Vibro-Blade, the Night Reaper's extra thigh UEL, the Prophet's silver plating and the Pit Fighter's seventeen priced options (jump jets, plasma breath, eye lasers, three forearm blasters, grenade launcher, grappling hook, vibro short sword and claws, vibro spikes, two whipping cables, two net launchers and a replacement net, vibro chainsaw sword), pp.123-132 |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-g` | 4 vehicles, `~311-northern-gun-2-power-armor-g.sql` (pp.133-140, 144-146): NG-X209 Protege (14 locations, 3 weapons), NG-11F Red Hawk (14, 4), NG-UELX42 Sabre (5, 1), NG-X13 Samson Missileman (10, 6); 43 locations and 14 weapon entries in all. 2 gear rows, `~312-northern-gun-2-power-armor-g-gear.sql`: the Protege's silver plating and the Sabre's extra thigh UEL (pp.133-140) |
| 2026-11-16 | `pal/data/northern-gun-2-power-armor-h` | 4 vehicles, `~313-northern-gun-2-power-armor-h.sql` (printed 146-156): NG-NX14 Sea Demon (11 locations, 3 weapons), NG-UELX49 Silent Shadow (7, 3), NG-X40 Storm Hammer (9, 4), NG-DX001 Thunder Hound (9, 4); 36 locations and 14 weapon entries in all. 3 gear rows, `~314-northern-gun-2-power-armor-h-gear.sql`: the Sea Demon's two separately priced silver platings (bayonet and blade) and the Silent Shadow's extra thigh UEL (printed 148 and 151) |
| 2026-11-16 | `pal/data/northern-gun-2-hovercycles-a` | 4 vehicles, `~315-northern-gun-2-hovercycles-a.sql` (printed 161-166): NG-488 Cobra Turbo (11 locations, 1 weapon), NG-424 Hornet (8, 3), NG-277 Jouster (12, 3), NG-357 Magnum-Turbo (8, 0); 39 locations and 7 weapon entries in all. 21 gear rows, `~316-northern-gun-2-hovercycles-a-gear.sql`: every separately priced modular hovercycle item of printed 158-160, namely nine guns (NG-HM10 to NG-HPART), the OUE2 dual-weapon system and DH2 housing, five housings (HT01 to HT09), four missile launchers (MM62, MM64, MM68, WS604) and the radar and comms unit |
| 2026-11-16 | `pal/data/northern-gun-2-hovercycles-b` | 5 vehicles, `~317-northern-gun-2-hovercycles-b.sql` (printed 167-176): NG-320 Rampage (12 locations, 2 weapons), NG-150 Streetrunner (7, 0), NG-500 Windfire (13, 3), NG-SU600-EX Wave Cutter (9, 2), NG-640 Windshark (12, 2); 53 locations and 9 weapon entries in all |
| 2026-11-16 | `pal/data/northern-gun-2-aquatic-a` | 4 vehicles, `~318-northern-gun-2-aquatic-a.sql` (printed 177-186): NG-AMP-007 Alligator APC (8 locations, 3 weapons), NG-AQUA-212 Aquapod with its Geo-Explorer mini-sub (24 locations, 14 of them prefixed `Mini-Sub:`, 6 weapons), NG-AMP6 Beachcomber ATV (6, 3), NG-SU2 Bluestorm Submarine (6, 3); 44 locations and 15 weapon entries in all. 1 gear row, `~319-northern-gun-2-aquatic-a-gear.sql`: the separately priced AquaWalker Tires (printed 182-183) |
| 2026-11-16 | `pal/data/northern-gun-2-aquatic-b` | 4 vehicles, `~320-northern-gun-2-aquatic-b.sql` (printed 186-192): NG-AMP8 Crocodile Amphibious Tank (10 locations, 4 weapons), NG-SU7 Crayfish Amphibious Submersible (12, 3), NG-S3 Harbormaster Missile Boat (7, 3), NG-S1 Sandfish Cargo Landing Craft (6, 2); 35 locations and 12 weapon entries in all. The Crayfish's laser prints "46 M.D." and is stored as 4D6 with that noted |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-11-16, after
`~318-northern-gun-2-aquatic-a.sql` and its gear script were applied
(traceable / other):

    northern-gun-2     159 / 0

Lines 1 to 3 of the *Extraction plan* (the two new-armour batches, the
held-armour compare and the eight power-armour batches `-a` to `-h`) and all
of line 4 (`hovercycles-a`, printed 158-166, and `hovercycles-b`, printed
167-176) have shipped, and of line 5 `aquatic-a` (printed 177-186, four of
the eight vessels): the rest of line 5 and lines 6 to 10 follow.
