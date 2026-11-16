# Rifts World Book 34: Northern Gun Two — survey

**Status:** `surveyed` — cached, inventoried and diffed against production; nothing imported yet. The proposal is under *Extraction plan*. (2026-11-16)

**Rows citing this book:** none yet

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
| Robo-Gladiator | 20-22 | **none printed** |

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

**Proposed 2026-11-16, not yet approved.** One branch per line; gear and
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

Rulings the plan needs from Nate before it runs:

- **The Robo-Gladiator's experience ladder.** The book prints none. The
  class cannot ship without one, and choosing one is a judgement about the
  game, not a reading of the page.
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

### What remains

Everything: nothing is imported. `node scripts/source-coverage.mjs --remote`
has no line for this book until its first row ships; paste its line here in
the PR that ships one.
