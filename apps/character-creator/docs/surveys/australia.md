# Rifts World Book 19: Australia — survey

**Status:** `imported` — skills, gear, vehicles, bestiary, notable NPCs and all 29 classes. What was left out on purpose is under *Extraction plan*; what the PDF is missing is under *Cache health*. (2026-10-02)

**Rows citing this book:** classes 29, gear 76, vehicles 9, skills 14, notable_npcs 4, creatures 18

**MOS:** police-trg 2

Slug `australia`. Cached 2026-10-01 from
`Rifts - World Book 19 - Australia.pdf`, 226 PDF pages, **text layer**
(no OCR). `--probe` median 4,580 chars/page, 35.5% stop words, 0.0%
private-use glyphs, so the words survive.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

The book is the Outback, the two Tech-Cities (Melbourne and Perth), their
classes, a bestiary and the Cities' hardware. **It defines no spell and no
psionic power**: every `P.P.E.:` and `I.S.P.:` line in 226 pages is a stat
inside a class, creature or NPC block. The Aboriginal classes and Dreamtime
magic are deferred by the book itself to a later volume (printed 87).

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on seven pages rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p012` | 11 | +1 |
| `p050` | 49 | +1 |
| `p100` | 99 | +1 |
| `p150` | 149 | +1 |
| `p200` | 199 | +1 |
| `p222` | 221 | +1 |
| `p223` | 222 | +1 |

One region, no split. 226 cache pages, **224 printed**. `ocr-book.py` measured
222, because the last two pages of the book carry no folio: the Experience
Tables start at the foot of cache `p224` (printed 223) and fill cache `p225`
(printed 224), which is where the Contents puts them. Cache `p001` is the cover
and `p226` is blank; there are no house ads.

## Cache health

**Printed page 146 is missing from the source PDF.** Cache `p146` and `p147`
are the same page, both printing folio 145; `p148` prints 147, so the offset
holds on both sides and nothing else is displaced. The lost page holds the
first part of the Mokoloi Prey-Stalker power armor's weapon list and its
speed, size, weight and price. Found 2026-10-02 at extraction; the seven-folio
offset check did not land on it. Another copy of the book would fill it in.

| key | value |
|---|---|
| `text_layer` | true |
| `welded_pages` | **1** — cache `p012` (printed 11), overview prose, nothing an import reads |
| `corrupt_pages` | **3** — `p5` (3 hits), `p29` (4), `p44` (1) |
| `substituted_digits` | **64 pages** — worst are `p49` (9), `p110` (6), `p164` (5) |

- `p5` is the Contents. Its page numbers for printed 59–126 arrive as one
  detached column, so **pair a Contents name with its page by reading the class
  page, not by position in the cache**.
- `p29` (printed 28) is geography prose. `p44` (printed 43) is inside the
  community-creation tables, which are not imported.
- **The digit cipher lands on what an import reads**: the community tables
  (`p39`–`p51`), class S.D.C. bonuses (`p78`, `p124`), the bestiary
  (`p164`–`p194`) and the weapon blocks (`p196`–`p222`). A render does not fix
  it. Read the token as the dice expression it can only be.
- The cache also garbles characters in a few headings (two weapon names on
  `p203`–`p204` and two armor rows on `p207`). Take names from a render at
  extraction.

## The book's authority tables

| printed | table | states |
|---|---|---|
| **151–152** | the complete skill list by category | every skill available in Australia, with the book's own *new* mark on the ones it adds. **The most valuable page pair in the book**: it is the only place that says which category a new skill belongs to |
| **56** | the Outback O.C.C. list | the twelve Outback classes and their printed names |
| **105** | the City O.C.C. list | the City, City Military and mutant classes, and which are optional |
| **86–87** | acceptable outside O.C.C.s | which classes from other books fit Australia; names only, mechanics elsewhere |
| **223–224** | Experience Tables | twelve ladders; which class climbs which |
| **4–5** | Contents, Maps, Quick Find | section pages. Clean for names, **not** for the 59–126 page column (see above) |

The skill list and the skill descriptions (printed 153–161) are two readings
of each new skill's name, and they disagree in small ways (singular or plural,
`&` or `/`). The list wins for the name and the category; the description is
the only source for base percentages.

Costs are printed **once**, inside each entry. They are transcribed, not
reconciled. Prices are in Australian dollars, which printed 195 states are
equal to credits.

## Inventory

Counted by structure over all 226 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| overview, geography, landmarks | 9–30 | prose and maps; nothing to import |
| the Outback and its people | 31–35 | prose |
| creating Outback communities | 36–49 | a point-buy community generator, three steps; GM tool, no catalog table |
| notable Outback communities | 50–55 | six communities; **2 NPC stat blocks** (printed 52, 55) |
| Outback O.C.C.s | 56–87 | **12 classes**, then the list of acceptable outside classes |
| City blueprints | 89–104 | Melbourne and Perth; **1 NPC stat block** (Melbourne's central computer, printed 92); city defense turrets and laser net (printed 98–99) |
| City and City Military O.C.C.s | 105–126 | **10 classes** |
| mutants (Phreakers) | 126–132 | deformity and mutant-power tables (41 percentile rows), **2 R.C.C.s** |
| optional player races | 132–150 | **5 R.C.C.s**; Mokoloi gear (3 weapons, 1 armor, 2 power armors) on 142–148 |
| skills | 151–161 | the master list, then descriptions; **34 base-skill lines** |
| monsters and animals | 162–173 | **6 creatures** |
| demons and spirits | 173–187 | **7 creatures** (the classic vampire entry on 180 has no stat block) |
| gods of the Dreamtime | 188–193 | **3 entities**, one with an avatar block |
| Outback equipment and weapons | 194–198 | 4 kit items, a weapon-modification price list (10 options), an ammunition damage table, 1 flame thrower, 5 boomerangs, spears, 3 air crossbows |
| Tech-City weapons | 198–205 | **20 weapons** (4 S.D.C., 16 M.D.) |
| armor | 206–209 | homespun price rules, **12 S.D.C. and 9 M.D.C. homespun rows** as a price list, then **8 City armors** |
| power armor | 210–214 | **2 suits** |
| vehicles | 214–223 | **6 vehicles** |
| Experience Tables | 223–224 | 12 ladders |

### Spells and psionics: zero, and that is the book

Zero spell or power stat blocks. The Sham-Man and Songjuicer cast spells from
other books' lists; the Kwarla Mystic takes psionics and a short list of
existing spells. Checked with the `P.P.E.:` / `I.S.P.:` / `Duration:` /
`Level:` scan: 2 `Duration:` hits, both inside Mokoloi gear.

## Classes

### Outback O.C.C.s (12) — printed 56–85

| class | printed | note |
|---|---|---|
| Bushman | 56–58 | |
| Bushranger | 59–60 | criminal |
| Guide (Wilderness Scout) | 61–62 | an Aboriginal variant heading on 62 |
| Jackaroo | 63–64 | |
| Merchant Trader | 65–66 | |
| City Trader | 67–69 | player class and NPC villain |
| Outbacker Runabout | 70–71 | |
| Raider (City Raider) | 72–73 | |
| Roadganger | 74–76 | player class and villain |
| Road Sentinel | 77–78 | |
| Sham-Man (False Sorcerer) | 79–81 | magic; nine numbered powers |
| Songjuicer | 81–85 | magic; nine numbered powers, a harvesting skill, minor psionics |

### City and City Military O.C.C.s (10) — printed 105–125

| class | printed | note |
|---|---|---|
| Administrator | 105–106 | headed as an NPC and villain; **see the open question below** |
| Cyber-Specter | 107–109 | computer-hacking abilities |
| City Police | 110–111 | |
| Police: TRG | 112–114 | |
| Sportsman | 115–118 | athletic specialisations |
| Technologist | 119–120 | |
| Aerojock | 121–122 | |
| Infantry Grunt | 122–123 | |
| Special Operations Soldier | 124 | |
| Navy Sailor | 125 | |

### R.C.C.s (7) — printed 128–150

| class | printed | note |
|---|---|---|
| Outback Mutie | 131 | rolls on the deformity and mutant-power tables (128–130) |
| Phreaker Military Grunt | 131–132 | same tables |
| Kwarla | 132–134 | optional player race |
| Kwarla Demon Hunter | 134–135 | NPC or optional player class |
| Kwarla Mystic | 135–137 | psionics, a spell list from other books, divination |
| Mokoloi | 137–142 | NPC villain and optional player race |
| Shadow People | 148–150 | NPC or optional player race |

**29 class blocks in all.** The Experience Tables name twelve ladders and
cover every one of them; the pairing is read at extraction, per class.

### Id collisions to avoid

Production holds `merchant`, `sailor`, `navy-seaman`, `coalition-grunt`,
`ngr-police`, `police-officer-japan` and `hu-mutants`. None is the same class.
Use ids that carry the setting where the plain word is taken or ambiguous:
`merchant-trader-australia`, `navy-sailor-australia`,
`infantry-grunt-australia`, `city-police-australia`, `guide-australia`,
`raider-australia`.

### Named but not defined here

- The acceptable outside O.C.C.s on printed 86–87: names only.
- Aboriginal O.C.C.s: printed 87 defers them to a later book. Not in this one.
- The classic vampire on printed 180: a short entry with no stat block.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-01. No row in `skills`,
`gear`, `creatures` or `imported_classes` cites this book.

### skills: 20 missing by name, of which 2 are false gaps; 34 already held

`node scripts/catalog-diff.mjs --remote --table skills --entries <54 names>`
returns **matched 34, missing 20** over 426 rows. Three of the 34 matched only
by alias (a singular/plural, an `&` for a `/`, and Law for Law (general)).

Most of the book's *new* marks are skills New West and later books already
brought in: the whole Cowboy category, Vehicle Armorer, Animal Husbandry,
Brewing, Gemology, Spelunking, Roadwise, Dowsing and the W.P.s for whip, net,
spear and grappling hook all match.

| the book prints | catalog holds | verdict |
|---|---|---|
| Kayaking | Boat: Paddle Types/Canoe/Kayak | **false gap**, unless the description's base differs; check at extraction |
| W.P. Flamethrower | W.P. Military Flamethrowers | **false gap** |
| Weapons Armorer | Field Armorer & Munitions Expert | read both descriptions before deciding |
| Find Contraband, Parts & Relics | Find Contraband | an Australian variant with its own description; new row |
| Outback Combat Driving | Combat Driving | new row |
| Outback Survival | Wilderness Survival | new row |

**Read against the descriptions at extraction (2026-10-01), the count is 14
new rows, not 16.** Three more of the 20 turned out to be rows the catalog
holds at the figure this book prints: Weapons Armorer is Field Armorer &
Munitions Expert (40/5), Find Contraband, Parts & Relics is Find Contraband
(26/4), and Outback Combat Driving is Combat Driving (no percentage). Kayaking
is Boat: Paddle Types/Canoe/Kayak (50/5). The Kwarla and Aboriginal languages
share one line in the list and one percentage, so they are one row.

The 14: Corroboree, Rock Painting & Engraving, Play Aboriginal Musical
Instrument, Road Train, Language: Aboriginal, Language: Australian English,
Language: Mokoloi, Lore: Aborigines, Lore: Cities, Lore: Dreamtime Culture,
Blend, Outback Survival, Use Songlines, W.P. Boomerang. Language `systems`
stays NULL, as for every other language row. **A class that prints one of the
five held names cites the catalog's spelling.**

### classes: 29 missing, 0 false gaps

Nothing within editing distance is the same class.

### creatures: 16 missing, 0 false gaps

### gear: 53 named entries missing, 0 matched

The catalog's `Boomerang`, `Short Spear` and `Long Spear` rows are other
books' (Heroes Unlimited, Nightbane, Palladium Fantasy) and stay as they are;
the five boomerang types here are new rows with their own damage.

### vehicles: 10 missing (2 Mokoloi power armors, 2 City power armors, 6 vehicles)

### notable NPCs: 3 stat blocks, plus the Rainbow Serpent's avatar; none held

## Extraction plan

Phase 4 costs money; everything above was free. In order, one PR each:

1. **Skills** (about 16 rows) from printed 151–161. Category from the list on
   151–152, base from the description. Goes first because classes cite them.
2. **Gear** (about 60 rows) from printed 142–145 and 194–209: kit, boomerangs,
   crossbows, 20 City weapons, 3 Mokoloi weapons, 9 named armors, and the
   homespun armors as rows where the catalog can hold a range.
3. **Vehicles and power armor** (10) from printed 145–148 and 210–223.
4. **Creatures** (16) from printed 162–193, through `bestiary-sql.mjs`.
5. **Outback O.C.C.s** (12), printed 56–85.
6. **City O.C.C.s** (10), printed 105–125.
7. **R.C.C.s** (7), printed 128–150.
8. **Notable NPCs** (3–4), printed 52, 55, 92, 190.

Each batch re-runs the `--remote` diff first, and `book-reconcile` checks it
before a data script is written.

What is deliberately left, with the reason for each:

- **The community generator** (printed 36–49) — a GM tool; no table holds it.
- **City law, penalties, social levels and I.D. cards** (printed 95–101) —
  setting rules, no catalog table.
- **City defense turrets and the laser net** (printed 98–99) — fixed
  emplacements, not carried gear or vehicles.
- **The weapon-modification price list and ammunition damage table**
  (printed 196) — rules applied to other books' guns, not items.
- **Weapon deterioration** (printed 197) — optional rule.
- **Horse statistics inside the Horsemanship text** (printed 156–157) —
  the book says its Cowboy skills are reprinted from New West; they belong to
  that book.
- **Maps, glossary, adventure ideas, sports descriptions** — prose.

### Decisions, confirmed by Nate 2026-10-01

1. **NPC-flagged classes: import all 29 as playable.** Administrator is not
   left out. City Trader, Roadganger, Mokoloi, Kwarla Demon Hunter and Shadow
   People go in as player classes too, tagged `evil` where the book calls the
   class a villain.
2. **Mutant tables: the class schema is expanded to hold them.** Outback Mutie
   and Phreaker Military Grunt roll on the deformity and mutant-power tables
   (41 rows, printed 128-130). Nate asked for the schema to carry a percentile
   table rather than for the tables to go in class prose, so this is tier 2
   under `book-survey` section 8: in scope because he asked. It is its own PR,
   scoped through `audit-premise-auditor` first, and it lands before batch 7
   (the R.C.C.s). The other batches do not wait for it.
   **Outcome, 2026-10-02: no schema change was needed.** A pick-one
   `special_abilities` group whose option names carry the band already holds a
   percentile table (the Dog Boy's breeds), with the d100 roll from PR #1602.
   Both mutant classes carry all three tables that way.
3. **Homespun armor: gear rows.** The 21 price-list rows (printed 206-207) are
   imported as gear, with the printed range in `cost_note` and the range of
   A.R., S.D.C. or M.D.C. in the description where a column holds one number.

## Class readings the book leaves open

Each is stored as the book prints it and flagged in the class's own notes.
Change one with a `fix-` script if Nate reads it differently.

| class | printed | what the book prints | stored |
|---|---|---|---|
| Guide | 62 | a skill line reading only "Use (+10%)" | Use Songlines 40% |
| Guide | 62 | "Play Musical Instrument: (+5%)" with the instrument blank | the general skill, 40% |
| Guide | 62 | Aboriginal racial bonuses deferred to a later book | none; a prose restriction |
| Jackaroo | 64 | Lore: Demons and Monsters "(+2%)" | 27%, as printed |
| City Trader | 69 | the Outsider background repeats two O.C.C. skills at a second bonus | the bonuses stack |
| City Trader | 67 | headed a non-player villain and optional player class | playable, tagged `evil` |
| Roadganger, Road Sentinel | 76, 79 | "Pilot: Motorcycle or (+20%)" with the second option blank | motorcycles alone |
| Road Sentinel | 79 | a stray "(+20%)" under Outback Combat Driving | no bonus |
| Songjuicer | 84 | "+4 to save vs possession" at level 4, "+6" at level 7 | a further +6 |
| Songjuicer | 82-85 | S.D.C. at level 1, Mega-Damage from level 2 on a rolled ladder | prose; no `mdc_base` |
| Bushman | 57 | the Classic type's own psionic schedule | prose; the common block is stored |
| Cyber-Specter | 108-109 | Computer Hacking 15% +25% in the ability, "(+30%)" in the skill list | 40% |
| Sportsman | 115 | Coastline/Rim prints a P.E. bonus twice (+1D4 and +2) | both, 1D4+2 |
| Sportsman | 117 | Surfer & Swimmer prints a P.P. bonus twice (+2 and +1) | both, +3 |
| Technologist | 120 | two full blocks, City and Outback | one class, two variants; the Outback related list is prose |
| Special Operations Soldier | 124 | Espionage +15% in the opening sentence, +10% in the list | +10% |
| Infantry Grunt | 123 | "Pilot: Tank and APC (+14%)" | as printed |
| Infantry Grunt, Police: TRG | 123, 114 | "W.P. Heavy Weapons" | the catalog's W.P. Heavy Military Weapons |
| Navy Sailor | 126 | pay for "technicians" without naming them | Communications Technician, Sensors Operator and Mechanic |
| Administrator | 105 | headed an NPC and villain | playable, tagged `evil` (Nate, 2026-10-01) |
| Outback Mutie, Phreaker Military Grunt | 128-131 | three tables headed pick one or roll; no number of rolls stated | one pick per table |
| Outback Mutie, Phreaker Military Grunt | 128-129 | four deformity bands turn Hit Points into M.D.C.; the Tanker power is 4D4x10 + P.E. M.D.C. | the option's text only |
| Outback Mutie, Phreaker Military Grunt | 130 | psychic results print no I.S.P. figure | none for the four master results; the standard major formula for Ecto-Freak and Psi-Healer |
| Outback Mutie, Phreaker Military Grunt | 130 | the natural spell caster learns "one additional spell per level equal to his level" | one spell per level |
| Outback Mutie, Phreaker Military Grunt | 129 | the Echidna band's A.R. 14 and quills follow the quilled half's sentence | the whole band's text |
| Kwarla | 135 | males 1D4 Physical powers, females 1D4+1 Sensitive or Healing | 5 picks from all three categories; a restriction line states the rule |
| Kwarla Demon Hunter, Kwarla Mystic | 132-137 | one stat block for the race, two trained castes | one race and two occupations limited to it |
| Kwarla Mystic | 136 | P.P.E. 4D6+22 in the attribute lines, 1D6x10 + P.E. and 2D6 per level in power 5 | power 5, overriding the race |
| Kwarla Mystic | 136 | "R.C.C. & Mystic Bonuses" on saves | read as totals; the difference from the race is stored |
| Kwarla Demon Hunter | 135 | the rogue's skill bonuses are "half" | halves rounded down |
| Mokoloi | 137 | headed an NPC villain and optional player race | playable, tagged `evil` |
| Shadow People | 150 | three skills "from Espionage (+10%) or Physical (any)" | +10 on the whole choice |

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/australia-survey` | cache built (226 pp, text layer), `australia` registered in `books.json` (offset +1 verified at seven folios, 224 printed), survey written. No data. |
| 2026-10-01 | `pal/data/australia-skills` | batch 1: 14 skills (`~059-australia-skills.sql`), production 426 to 440 skills. Five of the book's names are catalog rows under the catalog's spelling and are not touched. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/australia-gear` | batch 2: 73 gear rows (`add-australia-gear.sql`): 4 kit, 3 flame throwers, 8 boomerangs/spear/woomera, 3 air crossbows, 20 Tech-City weapons, 5 Mokoloi TW items (a fourth weapon, the Warrior's Blade, was not in the survey's count), 9 Tech-City armors with the riot shield, 21 homespun armors. Six readings came off renders. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/australia-vehicles` | batch 3: 9 vehicles (`add-australia-vehicles.sql`) with 80 location rows and 35 weapon rows: 3 power armors (the two Prey-Stalker headings are one suit, so not the survey's 4) and the 6 Notable Vehicles. The Prey-Stalker row is incomplete because printed 146 is missing from the PDF, and says so. Reconcile found three missing main-body location rows and one wrong remark; both fixed before the apply. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/australia-bestiary` | batches 4 and 8: 14 creatures and 4 notable NPCs with 68 attacks (`add-australia-bestiary.sql`, from `bestiary-sql.mjs`). Not the survey's 16 and 3-4: Bunyil, the Rainbow Serpent and Tikilik have no stat block (printed 188-192 say so), nor does Perth's computer; the book prints the Rainbow Serpent's Avatar (a notable NPC) and Tikilik's Demon Frog minion (a creature) instead. Reconcile checked all 18 rows and 68 attacks: no disagreement. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/australia-outback-classes` | batch 5: the 12 Outback O.C.C.s, one `add-<id>-class.sql` each (`bushman`, `bushranger`, `guide-australia`, `jackaroo`, `merchant-trader-australia`, `city-trader`, `outbacker-runabout`, `raider-australia`, `roadganger`, `road-sentinel`, `sham-man`, `songjuicer`). No stub rows. `book-reconcile` checked every skill, figure and experience ladder: one missed bonus (Merchant Trader, Espionage +5%), fixed. Readings the book leaves open are listed below. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/australia-city-classes` | batch 6: the 10 City and City Military O.C.C.s, one `add-<id>-class.sql` each (`administrator-australia`, `cyber-specter`, `city-police-australia`, `police-trg`, `sportsman`, `technologist`, `aerojock`, `infantry-grunt-australia`, `special-operations-soldier-australia`, `navy-sailor-australia`). No stub rows. `book-reconcile` checked every skill, figure, the Sportsman's 19 specialties, the Navy Sailor's 7 MOS packages and each experience ladder: no wrong figure; two consistency fixes (the Sportsman's English line, the Infantry Grunt's heavy-weapons proficiency). Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/australia-rccs` | batch 7, the last: the 7 R.C.C.s, one `add-<id>-class.sql` each (`outback-mutie`, `phreaker-military-grunt`, `kwarla`, `kwarla-demon-hunter`, `kwarla-mystic`, `mokoloi`, `shadow-people`). No stub rows. Both mutant classes carry the three percentile tables (17, 11 and 13 bands; 48 options) as pick-one ability groups, the Dog Boy's existing shape, so Decision 2 needed no schema change. `kwarla-mystic` joins the pinned `overrides_race` list in `regression.mjs` for its own P.P.E. `book-reconcile` read all 41 bands off renders: no wrong figure. Applied `--remote` before the PR. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **The automated sentry gun and the two Tech-City defense turrets as gear rows** (`~088`), left out as fixed emplacements. The book prints one M.D.C. block for both turret sizes without saying which figure is which, so neither stores an `mdc`. Read off renders and checked again by `book-reconcile`; applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a2-reprints-compared` | **The 34 skills this book prints that were already held, compared at last** (`~094`). No figure of this book's goes in: where the two differ (Horsemanship: Exotic Animals, Law, Roadwise, W.P. Spear, the flamethrower W.P., Horsemanship: Cowboy, Roping) the held rows match Rifts Ultimate Edition, which is newer (2005 against 1999). **What the comparison found instead is what held rows had dropped from RUE**, visible because this book prints it too: Horsemanship: General's second percentage and mounted bonuses, Vehicle Armorer's Basic Mechanics grant, Spelunking's Climbing bonus, Whittling's bonus for taking it twice, Breaking/Taming's penalties, Brewing's second percentage. Those rows now carry them in `note`, cited to RUE. Read off renders of printed 151-162 and of RUE; the notes were checked against RUE's pages by `book-reconcile` (this book's pages were read once, by the comparison only). 32 distinct held names were compared, not 34: the survey's count includes names the list on printed 153 prints twice. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a4-race-creatures` | **Four playable races as creatures** (`~101`), `playable = 1`, by Nate's ruling of 2026-10-04: `kwarla`, `mokoloi`, `outback-mutie`, `shadow-people`, with 20 attacks. Built from renders and checked again by `book-reconcile`: no wrong figure. **Not five:** the Phreaker Military Grunt is an occupation of the same mutant race as the Outback Mutie (the book prints two Mutant R.C.C.s for one race), so it gets no row of its own. **The mutant row has no attribute dice and no pools**, because the Mutants section of printed 126-131 prints none; the class's 3D6 is the human standard, not a page figure. The Shadow People's P.P.E. formula holds P.E. x5 alone: the page prints the 5D6 as per level and does not say it is rolled to start. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-c5-own-psionics-tables` | **The two mutant classes' power table is taken as the whole answer** (`~163`, close-out package C5; `BOOK-INGEST-AUDIT` F118): `outback-mutie` and `phreaker-military-grunt` state `psionics_allowed: false`. **This is a reading, not a printed rule**, and each class's notes say so: printed 128-132 print no Psionics line for a mutant and never mention the standard roll, where the same book prints one when it means it (the Mokoloi, printed 141); printed 128 gives mutants psionic or magical enhancement and the Special Mutant Powers table of printed 130 is the only mechanism for either. All eleven bands checked against a render of printed 130: no disagreement. No rows added. Applied `--remote` before the merge. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-10-01: `australia` has no
line, because no row cites the book yet. The `BACKLOG` block on that run, as
the baseline this book's import must not move:

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            14   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           19   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

Nothing in the extraction plan remains. The mutant tables needed no schema change: a pick-one ability group already carries a percentile table, with the d100 roll from PR #1602.

Still open: printed page 146 (see *Cache health*), and the readings in *Class readings the book leaves open*.

**After the retrospective close-out, 2026-10-05** (Phase C; `node scripts/source-coverage.mjs --remote` the same day: `australia 150 / 0`). Left: `psionics_allowed: false` on the two mutant classes is a reading of pages that print no Psionics line; the serpent result's Spd of 1D6+6 is prose though an option may now set attribute dice.
