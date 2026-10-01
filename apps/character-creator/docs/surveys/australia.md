# Rifts World Book 19: Australia — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. (2026-10-01)

**Rows citing this book:** none

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

Genuinely new, about **16**: Lore: Aborigines, Lore: Cities, Lore: Dreamtime
Culture, Corroboree, Play Aboriginal Musical Instrument, Rock Painting &
Engraving, Road Train, Blend, Use Songlines, W.P. Boomerang, four languages
(Australian English, Mokoloi, Kwarla, Aboriginal), plus the three variants
above. Language `systems` stays NULL, as for every other language row.

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
3. **Homespun armor: gear rows.** The 21 price-list rows (printed 206-207) are
   imported as gear, with the printed range in `cost_note` and the range of
   A.R., S.D.C. or M.D.C. in the description where a column holds one number.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/australia-survey` | cache built (226 pp, text layer), `australia` registered in `books.json` (offset +1 verified at seven folios, 224 printed), survey written. No data. |

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

Everything in the extraction plan remains.
