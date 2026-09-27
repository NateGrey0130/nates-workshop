# Rifts World Book 16: Federation of Magic — survey

**Status:** `importing` — PR B (25 Techno-Wizard gear rows) and PR C (12 vehicles and automatons) have shipped; the eight classes (D, E) are next. (2026-09-26)

**Rows citing this book:** gear 25, vehicles 12, notable_npcs 13

Slug `fom`. Cached from `Rifts- World Book 16 Federation of Magic.pdf`,
161 PDF pages, **text layer**. Second printing, March 1999; copyright 1997.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`:** `page_offset: 1`, so cache file page =
printed folio + 1, and printed folio F is `p<F+1>.txt` and `read-columns.py
<F+1>`. `printed_pages: 159`, cached `p001-p161`. One region, no
`page_offset_exceptions`.

Checked 2026-09-26 by reading the folio off renders: cache `p131` carries 130
and cache `p161` carries 160. The automaton extraction read the folios on cache
`p098`-`p113` and found the same +1 on every page.

**The cache holds all 161 pages.** It stopped at file `p073` — printed 72,
mid-word and mid-class — until the `F2` resume fix read the remaining 88 pages
off the source PDF. **The figure 73 appears in older audit text and is stale.**

## Cache health

| key | cache pages | where it matters |
|---|---|---|
| `welded_pages` | 3, 29, 50, 71, 90, 96, 101, 125, 159 | 71 = printed 70 (Magus introduction), 90 = printed 89 (the start of the Grey Seer), **101 = printed 100** (the Colossus: its weapon text is interleaved with its speed lines, so read the render), **125 = printed 124** (Zone Ranger add-ons, Trailblazer), **159 = printed 158** (level 13-14 spells). Cache 96 (printed 95) is welded too but reads as clean prose |
| `corrupt_pages` | 45, 105, 118, 160 (one hit each) | printed 44 (an NPC page), 104 (Colossus tail and Fire Demon; the render is legible), 117 (misc TW weapons), 159 (level 15 spells) |
| `substituted_digits` | 78 (1), 144 (3) | printed 77 (the Controller's P.P.E. line, `1D4xIO+X`), printed 143 (level 8 spell damage) |
| **not in the map, still there** | automatons, printed 95-112 | every `1D` reads `ID` (`ID6`, `ID4x10`), and a few `x` multipliers read `~` (`1D6~10+12` = 1D6x10+12). One saving throw on printed 107 reads `l l` (11) |
| **not flagged, still lost** | cache `p131` = printed 130 | **the spell index's fourth column (levels 13-15) is absent from the text layer entirely.** Read off a render for this survey |
| **not flagged, still lost** | printed 130-159 | several description **headings** are missing from the text layer: Power Weapon, Giant, Firequake, Enemy Mind, Energy Sphere, Null Sphere. The stat blocks survive, but the headings do not |
| **not flagged, nothing lost** | cache `p103`, `p106`, `p110` = printed 102, 105, 109 | each holds only a page number, because each is a **full-page illustration** (the Earth Thunder, the Fire Demon, the Infiltrator), checked on renders 2026-09-26. This row used to say cache `p104` = printed 103 was empty and the Earth Thunder's bonuses were missing: the empty page is cache `p103`, and the Earth Thunder's bonuses and Horror Factor 14 are on printed 104 (cache `p105`) |

## The book's authority tables

| printed | cache | table | states |
|---|---|---|---|
| 4-5 | p005-p006 | *Contents* and *Quick Find* | the page of every section, class, automaton and NPC |
| **130** | p131 | *New Spells Listed in Alphabetical Order* | every new spell under its level heading, with its P.P.E. in parentheses. **The authority for level.** Levels 13-15 are read off a render (above). **The book prints no Level Six heading here**: Barrage through Sheltering Force sit under Level Five's column. The description section's *Level Six* heading (printed 138) confirms they are level 6 |
| 130-159 | p131-p160 | spell descriptions | each stat block repeats the P.P.E., so costs are printed twice |
| **160** | p161 | *Experience Tables* | five ladders for the eight O.C.C.s, read off a render (below) |

### The XP ladders (printed 160), read off a render

| ladder | classes | level 15 tops out at |
|---|---|---|
| Battle Magus | Battle Magus | 389,960 |
| Conjurer, Controller Magus | Conjurer, Controller | 415,100 |
| Mystic Knight, Lord Magus | Mystic Knight, Lord Magus | 425,800 (printed `350,601425,800`, hyphen dropped in the ink) |
| Corrupt, High Magus | Corrupt, High Magus | 800,000 |
| Grey Seer | Grey Seer | 402,600 |

The ladders chain (each level's low bound is the previous high + 1) at every
level spot-checked. The text layer carries the numbers but detaches the
headings, so read the render.

## Inventory

Counted by structure over all 161 cached pages. For classes the markers were
`Attribute Requirement`, `O.C.C. Skills`, `Standard Equipment`, `Money` and
`Cybernetics`. Spells were counted from the index and checked against the
`P.P.E.:` lines. Gear was counted by `Black Market Cost:` and `Weight:`, and
vehicles by `Statistical Data`. Each hit was then checked by hand.

| section | printed | what is there |
|---|---|---|
| History, the Federation today | 8-21 | lore; the Dweomer military and brotherhoods |
| The Lords of Magic | 22-28 | the three D'zir brothers (NPCs, imported) and their special powers (23) |
| The True Federation, City of Brass | 28-46 | Alistair Dunscon and his notables (NPCs, imported) |
| Fadetowns, Grey Seers, cults, Society of Sages | 46-52 | setting |
| Magestar and the Mystic Triad | 52-57 | setting; Kara Zayne, Hugh Madding, Dan Ironforge (imported) |
| Stormspire | 57-63 | setting; K'zaa and Dragonbane (imported) |
| Playing magic characters | 64-69 | G.M. advice; a list of existing O.C.C.s suited to the Magic Zone (69), which points at other books |
| **O.C.C.s of the Federation** | **70-95** | **eight O.C.C.s** (see *Classes*); the High Magus's Automaton Creation ritual (80) and Bonding Ritual (81) |
| **Magic Automatons** | **95-112** | overview (95), common powers and spell casting (96), **seven automatons** |
| **Techno-Wizard devices and weapons** | **112-120** | P.P.E. energy cells (112), **25 priced items** |
| **Techno-Wizard vehicles** | **120-125** | **four vehicles**, plus the Zone Ranger's priced add-ons |
| Spell magic rules | 125-129 | casting terms, exclusive magic and O.C.C. limits, a guide to magic across the Rifts books |
| **New spells** | **130-159** | the index (130) and **129 descriptions**, levels 1-15 |
| Experience tables | 160 | the five ladders above |

### Things this book has zero of, checked rather than assumed

- **Skills: none defined.** The Corrupt's "new skills" (printed 87-88) are the
  usual level-gated selections from existing skills.
- **Psionic powers: none defined.** The Grey Seer's psionics (printed 89-90) are
  class abilities in the Mystic pattern, costed per ability and not
  catalogued.
- **Creatures: none.** The book says outright that automatons are not alive
  (printed 96), and every stat block outside the class, automaton, gear and
  spell chapters belongs to one of the 13 named NPCs.

## Spells

`catalog-diff.mjs --remote --table spells --compare level,ppe` was run on
2026-09-26 against the 129 index entries. Production held 1,118 spell rows.
**Result: matched 125, disagree 4, missing 0.**

**Every spell this book introduces is already in the catalog, cited to a later
compilation**: 100 to Rifts Book of Magic and 29 to Rifts Ultimate Edition, both
later printings. The later book wins, so no spell is re-cited to this book.

| result | spells | action |
|---|---|---|
| matched (125) | all but the four below; 97 cite BoM and 28 cite RUE | none |
| **name collision** | *Enchant Weapon*: the diff matched it to Nightbane RPG p.148's spell of the same name (L13, 300). FoM's is headed **Enchant Weapon (minor)** in its description (printed 159; L15, 400 or 1,000), and the catalog holds it as `Enchant Weapon (Minor)`, BoM p.152, L15, 400 | none. The two are different spells, so the collision is recorded and no row is merged |
| disagree | *Shockwave*: FoM 35 (index and stat block), catalog 45 (RUE p.216) | none. RUE is later |
| disagree | *Summon & Control Sea Serpents*: FoM 350, catalog 300 (BoM p.151, and BoM's text layer also says 300) | none. BoM is later |
| disagree | *Annihilate*: FoM 600. The catalog stores `ppe` 300 with `ppe_note` giving 600 normally and 300 for Shifters and three other classes (BoM p.150, which prints the same pair) | none from this book. Whether the BoM row should store 600 is a question about that row |

**Decision (2026-09-26, orchestrator on Nate's standing go-ahead):** the
disagreements stay as they are. They are recorded here and in no
`variant_note`.

Two more readings worth keeping:

- *Death Curse*: the index says Special, the stat block (printed 135) says 15,
  and the prose on the same page says the spell needs no P.P.E. The book
  disagrees with itself. The catalog's BoM row holds 0 with `None/Special`,
  which is right.
- Levels matched on all 129, counting Enchant Weapon (Minor). That includes the
  unheaded level-six block and the render-only levels 13-15, which checks both
  readings.

## Classes

**None of the eight is in production**, under this book or any other: on
2026-09-26 `imported_classes` held no row named magus, mystic knight, corrupt,
grey/gray seer, conjurer, controller or automaton. Madhaven's White Rose
knights are that book's own Mystic Knight variants and do not stand in for
this one.

| O.C.C. | printed | ladder | requirements | notes |
|---|---|---|---|---|
| Battle Magus | 71-73 | own | I.Q. 10, M.E. 12, P.E. 14; any alignment but Diabolic or Miscreant; mortal human or D-bee | the lowest of the four Magi |
| Controller | 74-76 | with Conjurer | I.Q. 11, M.E. 13, P.E. 11 (printed under an *Alignment Restrictions* label, a misprint) | a subset of the Battle Magus; bonds to and controls automatons |
| Lord Magus | 77-79 | with Mystic Knight | I.Q. 12, M.E. 13, P.E. 13, P.P. 13; any alignment | knows every spell of a range of levels at level one |
| High Magus | 79-82 | with Corrupt | I.Q. 12, M.E. 12, P.E. 12; any alignment but Diabolic or Miscreant | builds automatons (the creation ritual, 80) and performs the Bonding Ritual (81) |
| Conjurer | 82-86 | with Controller | I.Q. 12, M.E. 12, P.E. 10; no alignment restriction | conjuring tables (84) priced by object size and animal hit points |
| Corrupt | 86-88 | with High Magus | none; the alignment becomes Miscreant or Diabolic | the book calls it more of an R.C.C. and a villain. It is playable as the evil monster or the Repentant (Cursed) variant, which gets reduced M.D.C., two spells and half bonuses |
| Grey Seer | 89-91 | own | I.Q. 8, M.A. 10, M.E. 10 | a Mystic variant; psionics plus magic |
| Mystic Knight | 91-95 | with Lord Magus | P.E. 15 and an evil spirit; Anarchist or evil only | P.P.E. channeling, including recharging E-clips at a printed P.P.E. per clip |

**The 13 classes the `books.json` note counted were not citations.** On
2026-09-26, 25 `imported_classes` rows (23 live) **mention** Federation of Magic
in prose, and none carries it as `source_book`. The mentions are the warlocks,
the elemental shamans, the Mystic, the Dragon Juicer, the Hidden Witch, the
Domovoi, the Russian Slayer, the Darkhound and the Psi-Goblin, each pointing at
this book for spells or for a related class. The 2026-09-09 figure of 13 was a
count of such mentions, and the note is corrected in the same PR as this
survey.

## Gear

On 2026-09-26, `catalog-diff.mjs --remote --table gear` (3,121 rows) was run
against the 25 priced items. **Result: missing 25, matched 0.** Every nearest
candidate was checked and none is the same item:

- *Sonic Rifle (TW)* is Underseas p.153.
- *TW Flamethrower* is Psyscape p.156.
- *TW Storm Lance* is Madhaven.
- *Manoan TW Energy Cell* is South America.
- *CP-50 "Dragonfire"* is a CWC assault rifle.

| printed | items |
|---|---|
| 112 | P.P.E. energy cell (a priced talisman clip; a recharge price is also printed) |
| 113-114 | pistols: TW Firebolt Pistol, TW Jammer, TW Shard Pistol, TW Starfire Pistol, TW Shock Pistol |
| 114-116 | rifles and heavy: TW Nova Rifle, TW Disrupter, TW Fireburst Rifle, TW Force Cannon, TW Storm Rifle, TW Sonic Rifle, Starfire Pulse Cannon |
| 117 | Dragonfire Flamethrower, Flash Freeze Grenade, Firebomb, Shockstorm Landmine |
| 118-120 | Whip of Pain, Scepter of Command, Firestaff, Paralysis Staff, Draining Blade, Deathbringer Sword, Battle Fury Blade, Shadow Cloak |

Most weapons print a price for the weapon and a separate price for a clip.
Several magic items are priced as ranges in the millions (store the low end
plus a `cost_note`, per the gear convention). **Printed 117 is glyph-corrupt**:
read its four prices off a render.

**Shipped in PR B** (`add-fom-tw-gear.sql`). The four printed-117 prices and
the Disrupter's 2D4 were read off renders, and printed 114-116 were attributed
off renders too, because the text layer interleaves their stat lines. Guns,
grenades, the mine and the enchanted melee weapons are `weapon`. The energy cell
is `magic`, as the Manoan TW Energy Cell is. The Shadow Cloak is `gear`. The
thirteen items the book does not name "TW" carry a `tw-` slug prefix, and the
cell is `stormspire-ppe-energy-cell`. The Starfire Pulse Cannon is a gear row
and not a PR C vehicle add-on, because the book prices it as a stand-alone
weapon.

## Vehicles and automatons

On 2026-09-26, `catalog-diff.mjs --remote --table vehicles` (354 rows) was run
against the 11 names. **Result: missing 11.** No nearest candidate was closer
than distance 7, and none is related.

| printed | vehicle |
|---|---|
| 120-121 | TW Battle Skimmer (a flying barge) |
| 122 | TW Ley Streaker; a combat variant, the Battle Streaker, is priced separately in the same entry |
| 122-124 | TW Zone Ranger ATV, plus six priced add-ons (float on water, total chameleon, sky rider, shoot fire ball, call lightning, a mounted conventional weapon with an integration fee) |
| 124-125 | TW Trailblazer Assault ATV (welded page: render) |

Printed 95-96 settles what an automaton is:

- A High Magus, and sometimes a Lord Magus, builds one.
- Any Magus, or a Techno-Wizard of level 6 or higher, can **pilot** one by
  riding in an open compartment on its head or back.
- A Controller bonded by the ritual can direct it from about 200 feet away, and
  the Controller is the only class that can direct several at once.
- The book says automatons are not alive.
- No automaton has a price: each is *unavailable*, worth millions only to
  someone who could activate it.

| printed | automaton | height | main body M.D.C. | P.P.E. battery | who may pilot or control it |
|---|---|---|---|---|---|
| 97-99 | Battlelord | 18-24 ft | 1,000 | 200 | Controller level 7+, Lord Magus level 5+, High Magus level 4+ |
| 99-101 | Colossus | 60-68 ft | 2,000 | 1,200 | the most heroic High Magi and the three Lords only. **Not a Controller** |
| 101-104 | Earth Thunder | 10-12 ft | 500 | 100, regenerating 10 an hour (the spell paragraph says 120 and 20: the book disagrees with itself) | typically a Battle Magus Controller |
| 104-106 | Fire Demon | 16-20 ft | 500 | 280 | typically a Battle Magus Controller |
| 106-108 | Ice Drake | 12-15 ft to the head | 300 | 180 | typically a Controller; the only flier |
| 108-110 | Infiltrator | 6-8 ft | 220 | 120 | **not ridden**: bonded Controllers or the Lords of Magic only, by remote control out to 500 ft |
| 110-112 | Kilairgh | 60-70 ft long | 1,600 | 400 | a Controller, its creating High Magus, or a Lord of Magic |

Each automaton prints M.D.C. by location, speed, weapons, a spell list drawn
from its battery, hand-to-hand damage, Horror Factor and bonuses. The common
powers are on printed 96. Several spell lists wrap to the top of the next
page, so read each list to its end.

### Imported (PR C, 2026-09-26)

All eleven, plus the Battle Streaker, are in `vehicles` (12 rows), with 80
`vehicle_locations` and 34 `vehicle_weapons` rows. The script is
`add-fom-vehicles.sql`. Nothing was already in production under any name.

- **The automatons are `robot` rows** with `cost` NULL, and the note says
  "completely unavailable". Their numbered weapons and spell lists are weapon
  rows. Hand-to-hand damage, attacks, bonuses and Horror Factor are in the
  description. The Infiltrator's never-ridden remote control and the
  Colossus's closed door to the Controller are stated in `crew` and the
  description.
- **The Battle Streaker is its own row.** It has its own price (8 million
  against 5-6) and two weapon systems. It repeats the Ley Streaker's stat
  block, which the book says it shares.
- **The Zone Ranger's six add-ons are `vehicle_weapons` rows 1-6**, each
  with its price in the note, and the prices are also in the vehicle's
  `cost_note`. They are not `gear` rows: `gear.vehicle_slug` means "this gear
  row is a vessel", not "an option for one". The Trailblazer's item 6 points
  at them in prose.
- **Recorded as the book prints them, both ways:**
  - the Earth Thunder's battery (above);
  - the Battle Skimmer's cannons, 4-6 in its M.D.C. table and four in its
    weapon entry;
  - the Starfire Pulse Cannon's range, 2,000 feet on the Skimmer and 4,500 on
    the Trailblazer.

## Extraction plan

**Decisions recorded 2026-09-26** by the orchestrating session on Nate's
standing go-ahead. Nate may override any of them before the import PRs merge:

1. **Automatons go in as `vehicles` rows with `vehicle_class` `robot`**,
   following the precedent of New West's Glittermount. A High Magus or
   Controller owns and bonds one, and `character_vehicles` is how a character
   owns a vessel. The Infiltrator, which nobody rides, goes in the same way:
   its owner is its Controller.
2. **The Corrupt goes in as a class.** The book prints it as playable, as the
   evil monster or the Repentant, and its villain caveat goes in the class
   body.
3. **Spell disagreements are left as they are.** They are recorded under
   *Spells* above, with no `variant_note`.
4. **The automaton bond and the creation rituals are prose /
   `special_abilities` on the class**, not rows of their own.

The work in order, one PR each, applied `--remote` before the PR:

| PR | rows | tables | notes |
|---|---|---|---|
| **A** (shipped, #1441) | 0 | none | this survey, and the `books.json` note corrected |
| **B — TW gear** (shipped) | **25** | `gear` | printed 112-120. Printed 117 is read from a render, and so is the TW Disrupter's duration (printed 114: the text layer reads `204` where the ink prints 2D4). Re-diff `--remote` first |
| **C — TW vehicles and automatons** | **11** (4 vehicles, 7 automatons) plus `vehicle_locations` for each M.D.C.-by-location table | `vehicles`, `vehicle_locations` | printed 95-112 and 120-125. Welded 101 and 125 and the empty 103 are read from renders. Automaton `cost` is NULL, with the "unavailable" note. **Settled in that PR:** the Battle Streaker is its own row (12 rows in all), and the Zone Ranger's six add-ons are its `vehicle_weapons` rows, not gear. See *Imported* above |
| **D — the four Magi** | **4** | `imported_classes` | Battle Magus, Controller, Lord Magus, High Magus, printed 71-82. Every initial spell must resolve to an existing row. The Controller and High Magus carry the bond and rituals in prose. Lands after C, so an owned automaton is a real `vehicles` row |
| **E — Conjurer, Grey Seer, Mystic Knight, Corrupt** | **4** | `imported_classes` | printed 82-95; the Corrupt's Repentant variant and villain caveat go in the body |

**Spells: no PR.** All 129 are held (see *Spells*).

**Notable NPCs: no PR.** All 13 named in the Quick Find list were imported
on 2026-09-18.

Left out on purpose, with the reason:

- The Lords of Magic's special R.C.C. powers (printed 23): NPC abilities, already
  in the three D'zir rows.
- The list of O.C.C.s from other books that suit the Magic Zone (printed 69): it
  points at other books.
- The spell-casting rules and the guide to magic (125-129): rules with no row
  shape.
- The automaton stockpile counts (printed 96), the history, the cities and the
  population breakdowns: setting.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | cached (stopped at printed 72) |
| 2026-08-27 | [#338](https://github.com/NateGrey0130/nates-workshop/pull/338) | the resume fix read the remaining 88 pages — the cache now holds all 161 |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `fom` registered in `books.json` |
| 2026-08-28 | — | this file, backfilled offline |
| 2026-09-18 | — | 13 notable NPCs cite this book (Phase 2a NPC data, commit `1355500f`) |
| 2026-09-26 | [#1441](https://github.com/NateGrey0130/nates-workshop/pull/1441) | **the whole-book survey**: inventory, authority tables, the XP ladders, catalog diffs for spells, gear and vehicles, and the extraction plan. `books.json` note corrected |
| 2026-09-26 | #TBD | **PR C, vehicles and automatons**: 12 `vehicles` rows (7 automatons as `robot`, 4 TW vehicles, the Battle Streaker), 80 `vehicle_locations`, 34 `vehicle_weapons`. The Zone Ranger's add-ons are weapon rows. `add-fom-vehicles.sql`, applied `--remote` before the merge |
| 2026-09-26 | #TBD | **PR B: 25 Techno-Wizard devices and weapons** into `gear` (`add-fom-tw-gear.sql`), printed 112-120. Re-diffed `--remote` first (3,144 rows: missing 25), reconciled by `book-reconcile`, applied `--remote` before the merge |

## Where it stands

Importing. PR B (TW gear) and PR C (vehicles and automatons) have shipped.
Next is PR D, the four Magi.

### What remains

`node scripts/source-coverage.mjs --remote` on 2026-09-26 lists `fom` at
**13 traceable / 0 other**: the 13 notable NPCs. That was before PRs B and C.
What is left of the plan is the 8 classes.
