# Rifts World Book 33: Northern Gun One — survey

**Status:** `importing` — the 28 new energy weapons (191-204), the 15 new rail guns and non-energy weapons (204-212) and the 37 other weapons, ammunition, mines, fuel cells and batteries (101-103, 213-218) and the first 4 robots (103-116) are in; the rest of the approved plan under *Extraction plan* remains. (2026-11-13)

**Rows citing this book:** gear 84, vehicles 4

Slug `northern-gun-1`. Cached 2026-11-12 from
`Rifts - World Book 33 - Northern Gun 1.pdf`, 226 PDF pages, **text layer**
(`--probe` median 5,766 chars/page, 33.4% stop words).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. One region, no exceptions.

| cache page | folio printed on it |
|---|---|
| `p027` | 26 |
| `p050` | 49 |
| `p101` | 100 |
| `p150` | 149 |
| `p200` | 199 |
| `p221` | 220 |
| `p225` | 224 |

`printed_pages` is 224, as the manifest measured. Cache `p226` is a back-cover
advertisement.

Text-layer damage, by cache page (the manifest's three keys):

- welded: 226 only (the advertisement; nothing rests on it)
- glyph-corrupt: none
- digit-substituted: none detected. The detector sees only what it can map, so
  a dice expression that reads oddly is still read as the expression it can
  only be.

The text layer loses column geometry on the chart pages. Printed 220 (the
Experience Tables) comes out with three ladders intact and three as bare level
numbers with their figures elsewhere: **read it off a render.** The same holds
for every *M.D.C. by Location* block.

## The book's authority tables

| page | table | states |
|---|---|---|
| **220** | *Experience Tables* | one ladder per class, six ladders |
| **100** | *Alphabetical List of NG Combat Robots* | 27 robot names with model numbers; the canonical spelling of each |
| **6-7** | Contents | every weapon by model number and page, with `(new)` marking the ones first printed here |
| **221-223** | *Quick Find Index* | a second index, by keyword; cross-references weapon systems to the robot that carries them |

The Contents is the most useful: it is the only place that marks which weapons
are new to this book (28 of the 64 model-number entries carry the mark), and it names every robot's
sub-systems under the robot. The robot list on 100 and the Contents agree on
all 27 names; the two spell some differently (the list leads with the name,
the Contents with the model number), so names are matched by model number.

Costs are printed once, in each entry. Ladders are printed once, on 220.

## Inventory

Counted by stat-block markers over all 226 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Northern Gun, the company | 8-28 | prose; people given as one-paragraph quick stats (alignment, attributes, level, class) |
| Republic of Ishpeming, the city, the region | 29-61 | gazetteer prose; more quick-stat people; two maps (42, 52) |
| Ishpeming Military Contract Network | 62-72 | pay rates (63), four mercenary companies (66-72); **one full NPC stat block**: Philip Reeves (65-66) |
| NG Bounty Registry | 73-75 | bounty price tables; no stat block |
| Northern Gun O.C.C.s | 76-89 | **6 classes**; inside the Police Officer, **2 vehicles** (Police Interceptor Rocket Bike 85, Light Police Power Armor 86) |
| Freighters and tugboats | 90-93 | random-generation tables; no vessel stat block |
| Hovertrains | 93-99 | **3 vehicle blocks** (Locomotive 95, Boxcar/Flatbed/Passenger 96, Weapon Car 97, whose weapon list is on 98); random tables 98-99 |
| Robot features and fuel | 100-102 | the robot list; solid oxide fuel cells and electric batteries, priced (101-102) |
| Northern Gun Robots | 103-189 | **27 robots**, each with an *M.D.C. by Location* block and its weapon systems |
| NG Weapons | 190-212 | **54 weapons** by model number: lasers 191-198, ion 198-200, particle beam 201-203, plasma 203-204, rail guns and non-energy 204-212 |
| Other weapons and ammo | 213-218 | 4 rail-gun round kinds, 4 hand grenades, plastic explosives, Grenade Knife and NG-GL10 (214), mini-missiles and 2 launchers (215), 8 mine kinds (216-218), Vibro-Blades (218) |
| Experience Tables | 220 | the authority table |

Quick-stat people: 66 lines carry the marker, on printed 18-72. Each gives
alignment, the eight attributes and a level and class, and nothing else: no
hit points, no combat line, no equipment.

**No spell, no psionic power, no creature and no new skill is defined.** The
scan for a P.P.E. or I.S.P. cost line found none; the six classes' special
abilities (one block each, printed 77-89) are class features, not skill rows.

## Classes

### Playable O.C.C.s (6) — pages 76-89

| class | pages | XP table on p.220 |
|---|---|---|
| Bush Pilot | 76-78 | Bush Pilot O.C.C. |
| NG Loss Prevention Officer (LPO) | 78-80 | NG Loss Prevention Officer (LPO) |
| Monster Responder | 80-82 | Monster Responder O.C.C. |
| NG Police Officer | 82-86 | NG Police Officer O.C.C. |
| NG Robot Control | 86-88 | NG Robot Control O.C.C. |
| NG Sales Rep | 88-89 | NG Sales Rep O.C.C. |

No id collides: production holds no class under any of the six names. It
holds `NGR Police Officer` and three other police classes, which are different
classes from other books.

No class in this book is marked NPC-only.

## Catalog diff

Run against **production** (`--remote`), 2026-11-12, `origin/main` 67058ae1.
Production holds 0 rows citing this book.

### vehicles: 32 missing, 0 false gaps

`node scripts/catalog-diff.mjs --remote --table vehicles` over the 27 robots,
the two police vehicles and the three hovertrain blocks returns **matched 0,
missing 32**. Hand-checked by a name search for every robot's family name:
production holds none of them. What it does hold from Northern Gun is all
other machines: four `NG-` hovercycles (Lone Star), the Juicer Killer (Juicer
Uprising), the NG-X9 Samson (RUE), the Sky King, and the Bandito Tarantula.
The Lazlo Model Behemoth (Adventures in Dinosaur Swamp) is a different machine
from this book's two Behemoth Explorers.

### gear: 53 new weapons, 11 held from older printings

`node scripts/catalog-diff.mjs --remote --table gear` over the 64 model-number
entries on 191-218 returns **matched 6, missing 58**. Five of the 58 are false
gaps, held under a longer name:

| the book prints | production holds | held row cites |
|---|---|---|
| NG-33 Laser Pistol | NG-33 Northern Gun Laser Pistol | RUE p.269 |
| NG-Super Laser & Grenade Pistol | NG-Super Laser Pistol and Grenade Launcher | RUE |
| NG-L5 Laser Rifle | NG-L5 Northern Gun Laser Rifle | RUE |
| NG-57 Heavy Duty Ion Blaster | NG-57 Northern Gun Heavy-Duty Ion Blaster | RUE p.269 |
| NG-P7 Particle Beam Rifle | NG-P7 Northern Gun Particle Beam Rifle | RUE p.270 |

The six matched outright: NG-45LP, NG-H5, NG-IP7 and NG-11S (Juicer Uprising),
NG-101 and NG-202 Rail Gun (RUE). So **11 held, 53 new**. This book is the
newest printing of all 11.

**The comparison is done** (`~284`, 2026-11-13). Four of the 11 differed and
now cite this book, with the older printing's figures in their description:
the NG-Super, the NG-11S, the NG-101 and the NG-202. The other seven print
no differing figure here and keep their older citation.

Not diffed by name, because the book prints them as kinds under one heading
rather than as named products: the rail-gun rounds, hand grenades, plastic
explosives, mini-missiles, the two generic mine kinds, the Vibro-Blades and
the fuel cells. They are counted at extraction, against the generic rows
production already holds.

### classes, NPCs

Six classes missing, none held. Philip Reeves is not held.

## Extraction plan

**Approved by Nate 2026-11-13, as written.** One branch per line; gear and
vehicles go before the classes that name them.

1. `pal/data/northern-gun-1-weapons-energy`: the new laser, ion, particle
   beam and plasma weapons (191-204).
2. `pal/data/northern-gun-1-weapons-rail-and-other`: the new rail guns,
   tranquilizer guns, Mega-Crossbow, Bangsticks, Grenade Knife, launchers and
   the six named mines (204-218), with the ammunition, grenade, explosive and
   Vibro-Blade lines that production does not already hold.
3. `pal/data/northern-gun-1-held-compare`: the 11 held weapons compared
   against this printing.
4. `pal/data/northern-gun-1-robots-a` to `-d`: the 27 robots in four batches
   by page (103-125, 126-153, 154-174, 175-189), through
   `scripts/vessel-sql.mjs`.
5. `pal/data/northern-gun-1-vehicles-police-hovertrain`: the Rocket Bike, the
   Light Police Power Armor and the three hovertrain blocks.
6. `pal/data/northern-gun-1-npc-reeves`: Philip Reeves.
7. `pal/data/northern-gun-1-classes-a`: Bush Pilot, LPO, Monster Responder.
8. `pal/data/northern-gun-1-classes-b`: NG Police Officer, NG Robot Control,
   NG Sales Rep.
9. `pal/docs/northern-gun-1-close-out`.

Rulings that govern it (Nate, 2026-11-13: all three taken as proposed):

- **The 11 held weapons.** The 2026-10-04 ruling is that the newest printing
  that states a figure wins, and this book is the newest. Where a
  figure differs, the row takes this book's figure and its citation, and the
  older figure goes in the description.
- **The 66 quick-stat people.** Left, as England's 15
  attribute-only people were (D21 as Nate read it on 2026-11-12).
- **Fuel cells and batteries (101-102).** Gear rows in batch 2.

What is deliberately left, with the reason for each:

- the freighter, tugboat and hovertrain random-generation tables (90-93,
  98-99): tables for a Game Master, no stat block;
- the bounty and pay-rate tables (63, 73-75): prices for services, not items;
- the four mercenary companies (66-72): organisations, no block;
- the gazetteer and the two maps;
- the CS-equivalent hand grenades the book points to RUE for (213).

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-11-12 | `pal/docs/northern-gun-1-register-survey` | cache built (226 pp, text layer), offset +1 verified by folio at seven points, inventory and production diff; `northern-gun-1` registered in `books.json` |
| 2026-11-13 | `pal/data/northern-gun-1-weapons-energy` | 28 gear rows, the new laser, ion, particle beam and plasma weapons (191-204), `~281`, through `scripts/rows-sql.mjs` |
| 2026-11-13 | `pal/data/northern-gun-1-weapons-rail` | 15 gear rows, the new rail guns and non-energy weapons (204-212), `~282`, through `scripts/rows-sql.mjs` |
| 2026-11-13 | `pal/data/northern-gun-1-weapons-other` | 37 gear rows, the other weapons, ammunition, explosives, mines, fuel cells and batteries (101-103, 213-218), `~283`, through `scripts/rows-sql.mjs`; left because production holds them: the NG smoke hand grenade (`smoke-grenade`) and the NG Vibro-Blades (held as `vibro-knife`, `vibro-saber`, `vibro-sword`, `vibro-claws`, `vibro-bayonet`, `giant-vibro-sword`) at the same damage and price; the vehicle mine detector (216) is held as `vehicle-mine-detector` at the same price, and the Solid Oxide conversion kits are carried in the two fuel cells' `cost_note` |
| 2026-11-13 | `pal/data/northern-gun-1-held-compare` | 4 of the 11 held weapons re-cited to this book where its figures differ (`ng-super-laser-pistol-and-grenade-launcher`, `ng-11s-sawed-off`, `ng-101-rail-gun`, `ng-202-rail-gun`), `~284`, hand-written; left as agreeing: `ng-33-northern-gun-laser-pistol`, `ng-45lp-long-pistol`, `ng-l5-northern-gun-laser-rifle`, `ng-h5-holdout-ion-pistol`, `ng-57-northern-gun-heavy-duty-ion-blaster`, `ng-ip7-ion-pulse-rifle`, `ng-p7-northern-gun-particle-beam-rifle` |
| 2026-11-13 | `pal/data/northern-gun-1-robots-a` | 4 vehicle rows, the first four robots (103-116): `ng-v36-beachmaster` 11 locations and 7 weapons, `ng-ex5-behemoth-explorer` 12 and 1, `ng-ex9-behemoth-super-explorer` 20 and 3, `ng-v50-bigfoot` 11 and 4; 54 locations and 15 weapons in all, `~285`, through `scripts/vessel-sql.mjs` |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-11-12: its *BY BOOK*
table prints no `northern-gun-1` line, because no row in any table cites this
book yet. Everything in the plan remains.
