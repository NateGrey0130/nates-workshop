# Rifts World Book 17: Warlords of Russia — survey

**Status:** `importing` — skills, gear, bionics, the Mega-Steeds, the notable NPCs, 19 O.C.C.s and the vehicles shipped; the cyborgs next. (2026-10-01)

**Rows citing this book:** classes 19, gear 92, vehicles 18, skills 7, notable_npcs 8, creatures 5

**MOS:** soldati 5, sovietski-police-officer 7

Slug `warlords-of-russia`. Cached 2026-10-01 from
`Rifts - World Book 17 - Warlords of Russia.pdf`, 226 PDF pages, **text layer**
(no OCR). `--probe` median 3,678 chars/page, 33.8% stop words, 0.0%
private-use glyphs, so the words survive.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

This is the companion volume to `mystic-russia` (World Book 18, imported
2026-09-13). That book holds the magic, the bestiary and the Sovietski tanks;
this one holds the men-at-arms, the bionics, the Warlords' vehicles and the
skills. **The book defines no spell and no psionic power**: zero `I.S.P.:` lines
in 226 pages, and every `P.P.E.:` line is a stat inside an NPC or steed block.

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
| `p224` | 223 | +1 |
| `p225` | 224 | +1 |

One region, no split. 226 cache pages, 224 printed. Cache `p001` is the cover
(0 characters) and `p226` is blank; **there are no house ads**, and the last
page of the book proper is cache `p225` (printed 224), the Sovietski weapons.

## Cache health

| key | value |
|---|---|
| `text_layer` | true |
| `welded_pages` | **1** — cache `p141` (printed 140), inside the Demonfist Shocktrooper's stat block |
| `corrupt_pages` | **6** — `p5` (6 hits), `p7` (21), `p21` (2), `p38` (1), `p131` (1), `p164` (1) |
| `substituted_digits` | **65 pages** — worst are `p224` (6), `p124`, `p129`, `p156`, `p182` (5 each) |

What each corrupt page is, so nobody re-derives it:

- `p7` is the **Experience Tables**. Rendered at 130 dpi and read 2026-10-01:
  all 21 hits are the line art in the fourth column; the ten ladders in the
  cache agree with the render figure for figure.
- `p5` is the contents page, `p21` a map page.
- `p38` (printed 37) is Warlord Alekseyevna's stat block, `p131` (printed 130)
  the Aftermath Shocktrooper, `p164` (printed 163) the Wingrider Flying Wing.
  **Read those three off a render at extraction**, numbers included.

**The digit cipher lands on the pages an import reads most**: the Shocktrooper
weapon blocks (`p119`–`p141`), the vehicle weapon blocks (`p153`, `p156`,
`p160`) and the rail guns (`p180`–`p182`). A render does not fix it. Read the
token as the dice expression it can only be.

## The book's authority tables

| printed | table | states |
|---|---|---|
| **6** | *Experience Tables* | ten ladders naming 22 classes — the roster of what levels |
| **57** | *O.C.C. Descriptions* roster | the 17 O.C.C.s, the three cyborg O.C.C.s and the ten Shocktrooper body styles by name, plus the O.C.C.s from other books the setting uses |
| **190–191** | *Complete Alphabetical List of Skills, Old and New by Category* | every skill by category, each new one flagged as new |
| **4–5** | Contents and *Quick Find Table* | section pages; a second index, alphabetical by topic |

**The Experience Tables are the more valuable page.** The ten ladders:

| ladder | covers |
|---|---|
| 1 | Villager, Reaver Bandit |
| 2 | Explorer, Reaver Military Scout, Reaver Soldier |
| 3 | Sovietski Police, Soldati/Soldier |
| 4 | Ectohunter, Story Teller, Priest, Warlord Cyber-Doc |
| 5 | Hunter-Trapper, Mechanized Cavalry |
| 6 | Light Machine Cyborg |
| 7 | War-Knight, Bogatyr/Hero-Knight |
| 8 | Cossack, Wingrider, Heavy Machines |
| 9 | Smoke Soldier, Reaver Assassin |
| 10 | Cyborg Shocktroopers |

**Every class the book defines has a ladder** except the **Typical Soviet
Soldier** (printed 212), which the table does not name; ladder 3's
"Soldati/Soldier" is the nearest reading and needs a decision, not a guess. The
Sovietski cyborgs (printed 214–223) are not named either and presumably level
as ladders 6, 8 and 10; confirm from their own entries at import.

**Three figures on the page break the ladder's own arithmetic, and all three
are in the ink** (the render shows them as the cache does): ladder 2 level 7
opens at 30,501 after level 6 closes at 31,500; ladder 5 level 5 opens at
18,501 after level 4 closes at 16,500; ladder 10 level 2 opens at 2,601 after
level 1 closes at 2,500. Each level's low should be the previous high plus one.
An `xp_table` stores the thresholds, so this needs a recorded reading at
import.

**The contents page does not read in order.** Its two columns come out of both
the cache and `read-columns.py` as a run of titles followed by a run of page
numbers, so a title cannot be paired with its page from the text. Use the
definition pages below, which were found from each entry's own stat block.

**Costs and levels are printed once**, in the entry. Nothing here has a second
table to reconcile against except the skills, which appear in the list and
again in their descriptions (printed 191–201).

## Inventory

Counted by stat-block marker over all 226 cached pages, never by name.

| section | printed pages | what is there |
|---|---|---|
| setting, history, geography | 8–35 | prose and maps; a Forest Travel table at printed 17 |
| the seven Warlords | 36–56 | **7 NPC stat blocks** at printed 37, 40, 43, 46, 50, 53, 56, and seven sphere maps |
| O.C.C. roster and notes | 57 | the roster above |
| adventurer O.C.C.s | 58–72 | **6 classes** |
| Warlord troops and men-at-arms | 72–98 | **11 classes**; the War-Knight power armor is inside the War-Knight entry (printed 93) |
| Russian bionics | 99–106 | about **57 named systems**, ~55 `Cost:` lines |
| cyborg O.C.C.s | 107–142 | **3 classes** and **10 Shocktrooper body styles**, each with `M.D.C. by Location` and a weapon-systems block |
| price lists | 141–142 | two generic vehicle price lists, 23 `Cost:` lines |
| vehicles | 144–164 | **14 vehicles** and **the Wingrider power armor** |
| Mega-Steeds | 164–170 | **5 animals** with full creature blocks |
| bionic horses and barding | 171–172 | 2 conversions and barding, each with `M.D.C. by Location` |
| body armor | 173–176 | **7 armors**, the Bear exoskeleton and the MM-61 Explorer Exoframe |
| weapons | 177–186 | **28 named weapons**, 8 Vibro-Blades, clips, shields, the Servo-Harness Rig |
| arrowheads, bows, equipment, clothing | 186–189 | about **43 priced items** |
| new skills | 190–201 | list at 190–191, descriptions 191–201 |
| the Sovietski | 201–224 | 1 NPC (printed 207), **3 class blocks**, **5 cyborg bodies**, **3 weapons** |

**Zero spells, zero psionic powers.** Checked with the `P.P.E.` and `I.S.P.`
stat-line scans; do not re-run them.

## Classes

### Playable O.C.C.s (20) — printed 60–115

| class | definition page | ladder |
|---|---|---|
| Bogatyr / Hero-Knight | 60 | 7 |
| Ectohunter | 63 | 4 |
| Explorer | 65 | 2 |
| Huntsman-Trapper | 68 | 5 |
| Travelling Story Teller | 69 | 4 |
| Russian Villager — headed optional (printed 71) | 71 | 1 |
| Cossack | 75 | 8 |
| Reaver Soldier (Grunt/Warrior) | 78 | 2 |
| Reaver Mechanized Cavalryman | 80 | 5 |
| Reaver Assassin | 82 | 9 |
| Reaver Military Scout | 84 | 2 |
| Reaver Bandit/Raider | 86 | 1 |
| Soldati | 88 | 3 |
| Soldati Dimiye / Smoke Soldier | 89 | 9 |
| War-Knight | 92 | 7 |
| Warlord Cyber-Doc | 94 | 4 |
| Wingrider RPA Pilot | 96 | 8 |
| Light Machine cyborg | 108 | 6 |
| Heavy Machine cyborg | 112 | 8 |
| Cyborg Shocktrooper | 115 | 10 |

Five of these are headed as both an O.C.C. and an NPC villain (the Cossack and
four of the Reavers). That is a heading, not a refusal: each has a full block
and a ladder, and printed 86 carries a player-character note for the Bandit.

**Playability of the cyborgs is stated at printed 107**: a player character
may be a Light or Heavy Machine without having served a Warlord; a
Shocktrooper must have served one for years. That is a background condition,
not an exclusion.

### The ten Shocktrooper body styles — printed 117–141

Tempest (117), Butcher (119), Ripper (121), White Tiger (125), Holocaust (126),
Aftermath (129), Avenging Angel (131), Assassin Cyborg (134), Mantis (136),
Demonfist (138). All share the one Shocktrooper O.C.C. block at printed 115
and differ in body, M.D.C. and weapons.

**The catalog has a precedent for exactly this shape**: Free Quebec's
`fq-cyborg-soldier` beside `fq-cyborg-imprimer`, `-dervish`, `-slasher` and
`-leviathan`, and Japan's four `dragon-borg-*` rows. Follow whichever of those
the `free-quebec` survey records as the mechanism; do not design a third.

The Quick Find Table also names a **Black Panther** Shocktrooper under
Kolodenko (printed 41). The roster at printed 57 does not list it and no stat
block for it was found. Read printed 41 before deciding it is a mention.

### The Sovietski blocks — printed 208–223

| entry | printed | note |
|---|---|---|
| Catholic Priest | 208 | headed NPC; the entry says it is not recommended as a player character. On ladder 4 as "Priest" |
| Typical Soviet Police Officer | 211 | attribute requirements and skills; on ladder 3 |
| Typical Soviet Soldier | 212 | attribute requirements and skills; no ladder named |
| Sovietski Light Machine, Heavy Machine | 214–215 | cyborg bodies |
| Thunderhammer, Thunderstrike, Thunderstorm | 218–223 | Shocktrooper-class cyborg bodies |

### Id collisions to avoid

Checked against production's live classes 2026-10-01. `cyber-doc` exists
(Rifts core), so this book's is `warlord-cyber-doc`. `rifts-priest`,
`vagabond-peasant` and `combat-cyborg` exist and are different classes. No
class named Explorer, Cossack, Reaver, Soldati, War-Knight, Bogatyr,
Ectohunter, Trapper or Wingrider is in the catalog under any id. **Check each
id again before emitting**: a collision inserts nothing and says nothing.

## Catalog diff

Run against **production** (`--remote`), 2026-10-01. **No table holds a row
citing this book.**

### skills: 5 missing, 10 false gaps

58 entries: the 56 lines the list flags as new (three of them printed twice)
plus the Cossack's special skills. `node scripts/catalog-diff.mjs --remote
--table skills` against 421 rows returns **missing 15**, and 4 of the 43
found were found by alias.

Most of what the book calls new is reprinted from Coalition War Campaign and
New West, as its own introduction at printed 190 says, and is already here.
The 15 hand-checked:

| the book prints | the catalog holds | verdict |
|---|---|---|
| Imitate Voices/Impersonation | Imitate Voices & Sounds | false gap — compare the percentages at import |
| Field Armorer; Armorer | Field Armorer & Munitions Expert | false gap, one skill listed under two categories |
| Find Contraband, Weapons & Cybernetics | Find Contraband | false gap |
| Nuclear, Biological, & Chemical Warfare | NBC Warfare | false gap |
| Underwater Demolitions | Demolitions: Underwater | false gap |
| Hovercycle | Hovercycles, Skycycles & Rocket Bikes | false gap |
| Track Vehicles | Tracked & Construction Vehicles | false gap |
| Lore: Psychic & Psionics | Lore: Psychics & Psionics | false gap |
| Breaking/Training Wild Horses | Breaking/Taming Wild Horse | false gap |
| **Lore: History of Russia** | — | **new row** |
| **Lore: General Law** | `Law` exists; not shown to be the same | **new row unless the description matches** |
| **W.P. Net** | — | **new row** |
| **W.P. Trick Shooting** | — | **new row**; printed 200 says it cannot be a Secondary skill |
| **W.P. Siege Weapons** | — | **new row** |

`Horsemanship: Cossack`, `Trick Riding`, `Wingrider Flying Wing`,
`Language: Russian`, `Chinese` and `Mongolian` are already in the catalog,
arrived with other books. **The Asian/Westerner split at printed 198 belongs to
`Language: Chinese`**: it is the tail of that entry and sits directly above the
Mongolian heading, where it reads as Mongolian's. **22 skills in production cite `rifts-skill-list`,
which is not a book**: several of this book's skills are among them, and this
book is a real source for them. Re-run that search now the book is cached.

### classes: 20 missing, 0 false gaps

None of the twenty, none of the ten body styles and none of the Sovietski
blocks is in the catalog.

### gear: about 94 missing, 4 false gaps, 50 matched by name

148 names (57 bionics, 40 weapons, 8 armors, 43 equipment), against 3,414 rows:
**matched 50, missing 98**. The 50 are generic items the catalog already holds
(sensors, common implants, Vibro-Knife, canteens, jackets); this book's prices
may differ and that is a per-row question at import.

False gaps among the 98: Passive Nightvision Eye (`Passive Nightvision`),
Extendable Hydraulic Hand/Arm (`Extendible Hydraulic Hands/Arm`), Wire-cutters
(`Wirecutters`), Reversible Flight Jacket (`Reversible Flight Jacket - Light`).
**Not** false gaps despite a small distance: the W-41 Palm Laser Torch is a
different model from `PL-31`, the G-Clip is not the E-Clip, and Bear and Lynx
Body Armor are not Bark and Leaf Body Armor.

Every named weapon is absent: the AR rail guns and missile launchers, the
Belofsky cannons, the G-series lasers, the three Sovietski S-series. Bionics go
in `gear` under category `cybernetics` (132 rows there today).

**The name list is survey-grade, not extraction-grade.** It was read off entry
headings; the price lists at printed 141–142 and the bows are not itemised in
it. **Batch 2 proved the point**: sixteen of the names it called missing are in
the catalog under a differently ordered name (see the ledger). For the bionics
batch, build the entry list from the catalog's own naming before diffing.

### vehicles, creatures, notable NPCs: all missing

- **Vehicles: 14, plus power armor.** Novyet Arctic Hoverbike, Snow-Jetsled,
  Landcrawler-Sku, Explorer-Sku and Bear ATV; Heavy M.D.C. Snowmobile; Tek-12
  Bushbike and Tek-20 'Borgbike; Landflier; Warrior Assault Hoversled (light
  and heavy in one block); War Chariot; War Wagon/Mechanized Ram; Warthrone;
  Wingrider Flying Wing. Power armor and exoskeletons: War-Knight (printed 93),
  Wingrider (164), Bear (175), MM-61 Explorer Exoframe (176). The only catalog
  near-match, `Cavalry War Wagon`, is New West's and is a different vehicle.
- **Creatures: 5.** True Megahorse, Horned Steed, Burkov Mastodon (the contents
  page spells it Mastadon), Steppe Ostrich, Ursan Forest Steed.
- **Notable NPCs: 8.** Warlords Alekseyevna, Burgasov, Kolodenko, Orloff,
  Romanov, Seriyev and Sokolov, and General Katya Nikoforov of the Sovietski
  (printed 207, a short block).

## Extraction plan

**Agreed with Nate 2026-10-01**, with the four decisions below. Everything above
was free. Roughly 190 rows:

| # | batch | size | notes |
|---|---|---|---|
| 1 | skills | 5 new rows, 10 comparisons | first, because the classes cite them |
| 2 | weapons, armor, equipment | ~78 rows | by section; the rail-gun pages carry the digit cipher. Includes the two bionic horses and the barding (D3) |
| 3 | bionics | ~40 new rows | category `cybernetics`; the Shocktroopers and the cyborg O.C.C.s cite them |
| 4 | the 17 non-cyborg O.C.C.s and the two Sovietski classes (D1) | 19 classes | `class-import`, two or three per PR |
| 5 | Light Machine, Heavy Machine, Shocktrooper, the ten body styles, and the five Sovietski cyborg bodies (D2) | 3 classes + 15 | on the Free Quebec precedent; printed 140 from a render |
| 6 | vehicles and power armor | ~18 | same shape as the Mystic Russia vessels |
| 7 | Mega-Steeds | 5 creatures | through `bestiary-sql.mjs` |
| 8 | notable NPCs | 8 | through `bestiary-sql.mjs`; printed 37 from a render |

Gear before classes, for the reason spells went before classes in
`mystic-russia`: a class citing a row the catalog does not hold fails its check.

**Settled with Nate, 2026-10-01. Agreed, not proposed; do not re-litigate.**

- **D1 — the Sovietski classes:** import the Typical Soviet Police Officer and
  the Typical Soviet Soldier; leave the Catholic Priest, which its own entry
  discourages as a player character. The Soldier's ladder is still unnamed by
  the Experience Tables and is read at import.
- **D2 — the Sovietski cyborgs:** the five bodies go in with batch 5.
- **D3 — bionic horses and barding:** `gear` rows, not vehicles.
- **D4 — the two price lists at printed 141–142:** left out.

Deliberately left, with the reason for each:

- setting, history, geography and the Warlords' camp descriptions (printed
  8–56 outside the stat blocks) — prose, nothing the catalog models
- the O.C.C.s from other books listed at printed 57 — pointers
- the Catholic Priest — the entry's own recommendation, and D1
- the two generic vehicle price lists at printed 141–142 — D4

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/warlords-of-russia-survey` | cache built (226 pp, text layer), `warlords-of-russia` registered in `books.json`, survey written, offset +1 verified at seven folios. No data. |
| 2026-10-01 | `pal/data/warlords-of-russia-skills` | **Batch 1, skills.** `~057-warlords-of-russia-skills.sql`: five new rows (`Lore: History of Russia`, `Lore: General Law`, `W.P. Net`, `W.P. Siege Weapons`, `W.P. Trick Shooting`), production skills 421 -> 426. Two rows that cited the Rifts Skill List now cite the page that defines them: `Wingrider Flying Wing` (printed 196) and `Language: Mongolian` (printed 198); no other cache defines either. The ten false gaps were left at the catalog's spelling and figures. `Trap Construction` also cites the Skill List and is printed here, but Coalition War Campaign prints it first; left alone. Applied `--remote` before the merge. |
| 2026-10-01 | `pal/data/warlords-of-russia-gear` | **Batch 2, gear: 59 rows**, production gear 3,428 -> 3,487. `add-warlords-of-russia-weapons.sql` (35: clips, shields, the Servo-Harness Rig, six AR rail guns, four AR-M launchers, four cannons, eight rifles and pistols, three Vibro-Blades, three Sovietski weapons), `add-warlords-of-russia-armor.sql` (13: seven armors in ten rows, horse barding, the two bionic horses as `gear` rows per D3) and `add-warlords-of-russia-equipment.sql` (11). **Printed 175, 180, 183 and 184 were read off renders**: the stat blocks sit beside the art and the cache returns them under the wrong headings. Every row was checked by `book-reconcile` against the page before the apply. **The survey's gear count was wrong by 16**: the arrowheads, the Portable Field Unit, two communicators and the Communication Helmet are held from Triax, Spirit West, Japan and RUE under names the survey's heading-derived list did not use (`Arrowhead: Light Explosive`, not `Light Explosive Arrowhead`), and the equipment script's own pre-flight refused the first draft. Left out: those sixteen, the large communicator (ambiguous against RUE's medium row), the bows, and the three bare price lists at printed 187-189. The Vibro-Scythe Polearm ships with the Avenging Angel in batch 5; the MM-61 Exoframe with the vehicles. Applied `--remote` before the merge. |
| 2026-10-01 | `pal/data/warlords-of-russia-bionics` | **Batch 3, bionics: 33 rows**, category `cybernetics`, production gear 3,487 -> 3,520. `add-warlords-of-russia-bionics.sql`, printed 100-106: the two cyberlink systems, robot strength, nine optic and audio features, the Gromeko identification computer, chassis options, and thirteen weapon and tool limbs including the four Mekanikal arms. **Left out because the catalog holds them from Triax p.153-154 at the same prices** (printed 99 says the chapter reprints them): the Macro-Eyes, the eye socket, the Third Eye, the Medical Sensor Hand and its features, Bio-Comp, the Comp-Calculator, the hydraulic arm, the Laser Beam Eye, LGL-31, RVB-31 and the psionic dampers. The W-41 Palm Laser Torch is left as ambiguous against Triax's PL-31. `book-reconcile` checked all 33: no wrong figure. **It found a dropped apostrophe, and that was a generator bug, not a typo**: row text written as a doubled quote inside a Python single-quoted string is two strings joined, so the apostrophe never reached the SQL escaper. Three batch 2 rows had shipped that way (both bionic horses, the Thermal Jacket) and `fix-warlords-of-russia-gear-apostrophes.sql` corrects them, guarded. No number was affected. Applied `--remote` before the merge. |
| 2026-10-01 | `pal/data/warlords-of-russia-bestiary` | **Batches 7 and 8, out of plan order because they depend on nothing**: `add-warlords-of-russia-bestiary.sql`, generated by `scripts/bestiary-sql.mjs`. **5 creatures** (True Megahorse, Horned Steed, Burkov Mastodon, Steppe Ostrich, Ursan Forest Steed; printed 164-170) with 40 attacks, and **8 notable NPCs** (the seven Warlords, printed 37-56, and General Katya Nikoforov, printed 207) with 4. Production creatures 462 -> 467, notable NPCs 390 -> 398. `book-reconcile` checked all 13: no figure disagreed. A render settles the Megahorse's extra-skill levels as 2, 5, 7, 10 and 13 (the text layer prints the 7 as 1). Three book oddities are stored as printed and named in the script header: Kolodenko's hit points and resources are Burgasov's word for word, Orloff and Romanov print two skills twice, and Nikoforov's block has no M.D.C. number. Applied `--remote` before the merge. |
| 2026-10-01 | `pal/data/warlords-of-russia-occs` | **Batch 4, 19 O.C.C.s**, one `add-<id>-class.sql` each; production live classes 572 -> 591. Adventurers (`occ_group: optional`): `bogatyr-hero-knight`, `ectohunter`, `russian-explorer`, `huntsman-trapper`, `travelling-story-teller`, `russian-villager`. Warlord troops (`men-of-arms`): `cossack`, `reaver-soldier`, `reaver-mechanized-cavalryman`, `reaver-assassin`, `reaver-military-scout`, `reaver-bandit-raider`, `soldati`, `smoke-soldier`, `war-knight`, `warlord-cyber-doc`, `wingrider-rpa-pilot`. Sovietski (D1): `sovietski-police-officer`, `sovietski-soldier`. Every draft was validated `ready` by `class-check --remote` and checked against the page by `book-reconcile`: across the 19, **one wrong figure** (a literacy printed at a flat 90% given a per-level gain) and no missing skill. **Readings, each stated in its class's `extraction_notes`:** the Pilot exclusion ("robots, ships and aircraft") is mapped to catalog rows one way in every class; a category printing two bonuses (Technical +10%, +15% for some skills) stores the lower; the Cossack's born-and-raised attribute dice stay prose; a Horror Factor line listing levels is stored cumulatively; the Sovietski Soldier takes the ladder the Experience Tables print for "Sovietski Police & Soldati/Soldier". The Huntsman-Trapper prints no coin, only trade goods. **Regression failed twice before the apply and both were this batch**: two new classes carry an MOS block and needed the `**MOS:**` pin above; and one language pick printed with no bonus needed `bonus: 0` stated. Not rows: the War-Knight power armor, the Wingrider wing and armor (vehicles batch), and each class's starting mount or vehicle. Applied `--remote` before the merge. |
| 2026-10-01 | `pal/data/warlords-of-russia-vehicles` | **Batch 6, vehicles and power armor: 18 rows**, 152 M.D.C. locations and 47 weapon entries; production vehicles 419 -> 437. `add-warlords-of-russia-vehicles.sql`: the five Novyet vehicles, the Heavy M.D.C. Snowmobile, the Tek-12 Bushbike and Tek-20 'Borgbike, the Landflier, the Warrior Assault Hoversled (light and heavy, two rows), the War Chariot, the War Wagon/Mechanized Ram, the Warthrone, the Wingrider Flying Wing, and three suits (Wingrider Power Armor, War-Knight Power Armor, MM-61 Explorer Exoframe). **Every number was read off a 130 dpi render and checked against the render again by `book-reconcile`**: 18 rows, two page citations corrected, no figure. The heavy hoversled's cost is derived (light price plus the printed 600,000) and says so. The Explorer-Sku and the War Wagon print two main-body sections; the forward one is `mdc_main_body`. About thirty of the book's own slips on these pages (metric conversions, a missing "each", two fuel ranges) are stored as printed and named in the rows. Applied `--remote` before the merge. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-10-01: the book is counted
among the caches present and has **no line** in the BY BOOK list, because
nothing cites it. There is no per-book figure to paste yet.

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            14   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           19   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

None of those is this book's. They are the baseline: a number that moves
during this import is this import's.

**The source PDF was handed over in `Downloads` and copied to
`C:\Users\natha\Projects\workshop\books`**, where the registry points.
