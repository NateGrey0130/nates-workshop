# Rifts World Book 20: Canada — survey

**Status:** `imported` — the plan is done: skills, gear, vehicles, creatures and 23 new classes. The Techno-Warrior stays the *Ultimate Edition* class. What was left out on purpose is under *Extraction plan* and in the ledger. (2026-10-02)

**Rows citing this book:** classes 12, gear 45, vehicles 5, skills 14, creatures 34

Slug `canada`. Cached 2026-10-01 from `Rifts - World Book 20 - Canada.pdf`,
194 PDF pages, **text layer** (no OCR). `--probe` median 4,457 chars/page,
36.3% stop words, 0.0% private-use glyphs, so the words survive.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read it from `scripts/books.json`. Do not re-derive it.**

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. One region, no exceptions: verified by
folio at cache p012 (11), p050 (49), p100 (99), p150 (149), p192 (191) and
p193 (192).

`printed_pages` is **192**, not the 191 `ocr-book.py` measured. Printed 192 is
the Experience Tables page and its folio lands mid-file between the table
columns, so the detector does not see it as a folio. Cache p194 is blank.

Three manifest keys, all in **cache pages**:

- `welded_pages`: 23 (the Rifts Canada map, 118 characters) and 141 (printed
  140, the *Monsters of the North* opener and the start of the Armored Slayer).
  Read printed 140 off a render.
- `corrupt_pages`: p58 (3), p67 (1), p130 (1), p176 (2), p188 (1). p67 is the
  Perez map. **p130 (printed 129) is the last Techno-Wizard bionic weapon,
  p176 (printed 175) is Sedna's stat block, and p188 (printed 187) opens the
  Tundra Ranger equipment**: read every number on those three off a render.
- `substituted_digits`: 50 pages. The heaviest are p160 (12), p187 (11),
  p155 (8), p29 (7), p169 (7). The Experience Tables page itself carries
  `190,OOQ` for 190,000 and `290,60.1` for 290,601.

## The book's authority tables

| page | table | states |
|---|---|---|
| **192** | *Experience Tables* | eight ladders naming fourteen classes, plus a note sending three creatures to the Dragon ladder |
| **4-5** | *Contents*, map list and *Quick Find* | every section with its printed page |

**Printed 192 is the class authority, and it was read off a 130 dpi render**,
not off the cache: the text layer interleaves the ladders with the two armour
entries above them. The eight ladder headings, as rendered:

| ladder heading | classes it covers |
|---|---|
| Tundra Ranger, Headhunter Techno-Hound & Trapper-Woodsman | 3 |
| Anti-Robot Headhunter, Tundra Ranger Cavalry, Ixion Cyber-Horsemen | 3 |
| Centaur R.C.C. & True Sasquatch R.C.C. | 2 |
| Worldly Sasquatch & Tundra Ranger Scout | 2 |
| HH Techno-Warrior | 1 |
| Inuit Shaman/Angakoq | 1 |
| Momano Headhunter | 1 |
| Headhunter Assassin | 1 |

The note under the tables says D-Bees take the ladder of their O.C.C., and the
Faerie Bot, Loup Garou and Ogopogo use the Dragon ladder.

**The second authority is the Contents on printed 4-5**, and it agrees with the
ladder page on every class it lists. Its text-layer copy is unusable (the page
numbers arrive as a separate run), so it was read off a render too. Two names
differ between the book's own tables and are the same thing:

| printed in one place | printed in another | where |
|---|---|---|
| Headhunter Anti-Robot Specialist O.C.C. (heading, Contents) | Anti-Robot Headhunter (ladder) | 116 / 192 |
| Grackle Tooth (Contents, body text) | Crackle Tooth (the page heading's display font) | 133 |

Levels and costs are printed **once** for classes and gear. The seven
Sasquatch psionic powers are printed a second time in *Rifts Ultimate Edition*,
which the catalog already holds, so those reconcile rather than transcribe.

## Inventory

Counted by structure over all 194 cached pages (stat-block markers and
large-font headings from the PDF's own font sizes), not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| History, law, Erin Tarn, the civilised heart | 7-17 | lore; no stat blocks |
| Climates, and the Rifts Canada map | 18-22 | lore; one welded map page |
| Dangers of the cold, travel in snow and ice | 23-35 | environmental rules: hypothermia, frostbite, snow blindness, optional saves, avalanche, deep-snow speed modifiers, armour in the cold, riding animals, dog sleds, demon storms, flash floods |
| Winter Sports Skills | 36-37 | 2 skills, each with pro specialisations (3 skating, at least 2 skiing), and 3 pilot-skill notes |
| Eastern Canada | 37-50 | gazetteer: Free Quebec, Mechanicsville, Willisburg, Montreal, the Atlantic provinces; maps |
| Central Canada | 51-75 | gazetteer: Windsor ruins, Cartier-Fury Ranch, Lazlo region, Perez, Fowlerville, Burleston, the Hivelands, Hudson Wheigh. Named people as one-line prose (level, class, alignment), no stat blocks |
| Northern Canada, the Tundra Rangers | 76-83 | lore and the Rangers' code |
| Tundra Ranger classes | 84-90 | **4 O.C.C.s** |
| Southwestern Canada, Old Calgary, Fadetowns | 91-100 | gazetteer; one group stat line (the Calgary Highlanders, 97) |
| British Columbia | 101-102 | gazetteer |
| Centaurs and the Cyber-Horsemen of Ixion | 102-107 | **2 R.C.C.s**, their bionics, 3 weapons |
| Headhunters | 107-126 | **5 O.C.C.s**, plus Momano weapon modifications (5 bullets, 125-126) |
| Techno-Wizard Bionics | 126-129 | 8 TW bionic weapons, each with creation stats and weapon stats |
| D-Bees of Canada | 130-139 | 7 entries: Aardan Tek, Rogue Dog Packs, Grackle Tooth, Greot Hunter, Mastadonoid, Noli Bushman, Yeno |
| Monsters of the North | 140-168 | Armored Slayer; 6 bears; 4 canines; Cadborosaurus; Faerie Bots; Faerie Folk (a pointer); Fury Beetle; Giant Squid; Loup Garou; Ogopogo; Spirit Sasquatch; True Sasquatch; a typical-dinosaur template |
| The Worldly Sasquatch and Sasquatch Psionics | 166-168 | **1 O.C.C.**, 7 psionic powers |
| Demons | 169-180 | Demon Bear, D'Sonoqua, Sedna, Windigo, Wishpoosh; a Russian-demons pointer; other spirits in prose |
| The Inuit Shaman | 181-187 | **1 O.C.C.** (Angakoq), the Tornaq spirit bear, 6 amulets, 11 talismans, 3 special items |
| Tundra Ranger weapons, gear and vehicles | 187-192 | 2 armours, an energy-weapons pointer, 1 turret, 1 flight pack, 4 vehicles, homemade and Fury Beetle armour, 2 miscellaneous goods |
| Experience Tables | 192 | the class authority |

### Spells: zero, scanned rather than assumed

`P.P.E.` appears on 40 cached pages, and every hit on a `P.P.E.:` line is a creature's P.P.E. line, a
Techno-Wizard creation cost or the shaman's own reserve. **No page carries a
spell stat block** (a `Range:` / `Duration:` / `Saving Throw:` / `P.P.E.:`
group outside the psionics on 167-168). The Inuit Shaman's magic is amulets,
talismans and three made items with a creation cost, not a spell list.

### Notable NPCs: none with a stat block

The gazetteer names people on thirteen pages between printed 39 and 69
(heaviest: 55, then 41 and 63) as one line each. `Attributes:` and `Alignment:`
occur in that range only inside class and creature entries.

## Classes

### Playable, on the Experience Tables (14) — pages 84-185

| class | pages | ladder on p.192 |
|---|---|---|
| Tundra Ranger O.C.C. | 84 | Tundra Ranger (shared) |
| Tundra Ranger Scout O.C.C. | 85 | Worldly Sasquatch & Tundra Ranger Scout |
| Tundra Ranger Cavalry O.C.C. | 86-87 | Anti-Robot Headhunter (shared) |
| Trapper-Woodsman O.C.C. | 88-90 | Tundra Ranger (shared) |
| Centaur R.C.C. | 102-103 | Centaur & True Sasquatch |
| Cyber-Horsemen of Ixion R.C.C. | 103-107 | Anti-Robot Headhunter (shared) |
| Headhunter Techno-Warrior O.C.C. | 110-113 | HH Techno-Warrior |
| Headhunter Assassin O.C.C. | 113-116 | Headhunter Assassin |
| Headhunter Anti-Robot Specialist O.C.C. | 116-120 | Anti-Robot Headhunter (shared) |
| Headhunter Techno-Hound O.C.C. | 120-121 | Tundra Ranger (shared) |
| Momano Headhunter O.C.C. | 122-126 | Momano Headhunter |
| True Sasquatch R.C.C. | 162-166 | Centaur & True Sasquatch |
| Worldly Sasquatch O.C.C. | 166 | Worldly Sasquatch & Tundra Ranger Scout |
| Inuit Shaman (Angakoq) O.C.C. | 181-185 | Inuit Shaman/Angakoq |

**One name is already published.** `Headhunter Techno-Warrior` is class id 23
in production. Whether that row is this book's class or the later *Ultimate
Edition* restatement has to be read before anything is written: it is either a
correction to an existing class or nothing at all, never a second row.

The book's Momano Headhunter carries its psionics inside the class
(the heading on printed 124 pairs bonuses with psionics), which is the shape
an ability grant carries here, not a variant.

### Optional player characters the book marks as such, with no ladder of their own

The book labels each of these as an optional player character and gives it a
list of available O.C.C.s; the ladder page says a D-Bee takes its O.C.C.'s
ladder. They are **races, not classes**:

| entry | page | the book's rule, in short |
|---|---|---|
| Aardan Tek | 130-131 | optional PC; picks from a list of O.C.C.s |
| Grackle Tooth | 133-134 | military and mercenary O.C.C.s |
| Greot Hunter | 135 | a short list of combat O.C.C.s |
| Mastadonoid | 137 | shaman O.C.C.s and a few others |
| Noli Bushman | 137-138 | optional PC; Psi-Druid, Psi-Slayer and two Noli variants |
| Yeno | 139-140 | optional PC; an assassin-type equivalent |
| Armored Slayer | 140-143 | G.M.'s option; Dragon ladder; no O.C.C. |
| Faerie Bot | 149-151 | optional PC; Dragon ladder |
| Loup Garou | 155-156 | not suggested as a PC; starts at level one if allowed. **The entry names two ladders**: Dragon in its experience line, Psi-Stalker in its skills paragraph; the note on 192 says Dragon |
| Ogopogo | 157-159 | Dragon ladder per the note on 192 |

### NPC-only, by the book's own rule

The Spirit Sasquatch (160-161) is stated as not available as a player
character on printed 162. The five demons, the Tornaq, the animals and the
Fury Beetle carry no player-character line at all.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-01 with
`scripts/catalog-diff.mjs`, names only. No row in `gear`, `creatures`,
`spells`, `vehicles` or `notable_npcs` cites this book.

| table | book entries | matched | missing | after the hand-check |
|---|---|---|---|---|
| `imported_classes` | 14 on the ladder page | 1 | 13 | 13 new; 1 to read against the published row |
| `psionic_powers` | 7 | 7 | 0 | **nothing to import** |
| `skills` | 2 skills, 5 specialisations, 3 pilot notes | 2 | 8 | see below |
| `gear` | 23 probed, about 45 in the book | 1 | 22 | 1 false gap |
| `vehicles` | 4 | 0 | 4 | 4 new |
| `creatures` | 34 probed | 2 | 32 | 2 to look at, the rest new |

**Psionics: all seven are held, and all seven costs agree.** Deaden Senses 4,
Intuitive Combat 10, Psionic Invisibility 10, Psychic Omni-Sight 15, Radiate
Horror Factor 8, Sense Dimensional Anomaly 4 and Sense Time 2 on printed
167-168 are the catalog's own I.S.P. values, cited there to *Ultimate Edition*.
This is two independent readings agreeing, so it is also a probe of the cache
on those two pages.

**Skills.** `Ice Skating` and `Snow Skiing` are in the catalog, cited to
`Rifts Skill List` with no page: this book is their printed home (36), which
is the citation backfill `rifts-skill-list-is-not-a-book` asks for when a book
is cached. The three pilot entries on printed 37 are notes on skills the
catalog holds under *Ultimate Edition* names (`Hovercycles, Skycycles & Rocket
Bikes`, `Motorcycles & Snowmobiles`, `Tracked & Construction Vehicles`):
**false gaps, not new skills**. The pro specialisations (Figure, Pro Hockey
and Speed Skating; Downhill and Cross-Country Skiing, with the rest of printed
36-37 still to read) each cost an extra skill selection and add bonuses to
the base skill. Whether they are rows or prose on the base skill is a
decision, below.

**Gear false gap.** The book's communication helmet (192) is the catalog's
`Communications Helmet`. Everything else probed is absent, including all
eight TW bionic weapons, the three Ixion weapons, both Ranger armours and
Fury Beetle armour.

**Creatures to look at before adding.** `Giant Squid` is held from
*Underseas* p.24, and `Centaurs` from *Conversion Book One*; this book prints
its own of each (154, 102). `Windigo` here against the catalog's `Wendigo`
from *Spirit West* is distance 1 and **may be two different creatures**: read
both before deciding, and do not merge on the spelling. `Loup Garou` against
`Loogaroo` (*Conversion Book One*) is the same question.

## Extraction plan

**Agreed 2026-10-01**, with the four decisions below. Phase 4 has not
started. In the order the earlier books went:

1. **Skills** (36-37): cite the two held skills to this book and its page;
   add each specialisation as a row of its own (decision 3).
2. **Gear and vehicles** (107, 125-129, 185-192): about 45 gear rows and
   4 vehicles. The three corrupt pages (129, 175, 187) are read off renders.
3. **Creatures** (130-180): about 35, plus the typical-dinosaur template
   (decision 4), through `scripts/bestiary-sql.mjs`, after the two same-name
   and two near-name checks above.
4. **Classes** (84-185): 13 new, in book order, the four Tundra Ranger
   classes first because the gear they start with ships in step 2; then the
   ten optional-PC races as playable R.C.C.s (decision 1); then the
   `Headhunter Techno-Warrior` comparison (decision 2).

What is deliberately left, with the reason for each:

- **The gazetteer and its named people (7-22, 37-101)** — lore; no stat
  blocks, so nothing the catalog has a row for.
- **Cold, exposure and snow-travel rules (23-35)** — environmental rules the
  app has no mechanic for. A finding for `BOOK-INGEST-AUDIT.md` if it is
  wanted, not an import.
- **The seven Sasquatch psionics** — already held, costs agree.
- **The Faerie Folk and Russian-demons entries (152, 173)** — pointers to
  other books.
- **Tundra Ranger energy weapons (187)** — a pointer to the core book's
  early Coalition weapons, not new items.

### Decisions, settled by Nate on 2026-10-01

1. **The ten optional-PC races are playable.** Each is imported as a
   playable R.C.C. as well as a `creatures` row. The Spirit Sasquatch stays
   NPC-only, by the book's own rule.
2. **`Headhunter Techno-Warrior`: *Ultimate Edition* wins** (settled
   2026-10-02). The first answer, on 2026-10-01, was that the printing with
   the highest World Book number wins. Read literally that put this book
   (World Book 20) over a core book that carries no number, and batch 6 moved
   the class to printed 110-112. Seeing the result, Nate reversed it: the
   row is the *Rifts Ultimate Edition* p.74-77 class and this book's
   printing is not stored. How the two printings differ is in the header of
   `~067-canada-headhunter-techno-warrior.sql`.
3. **The skating and skiing specialisations are rows of their own**, not
   prose on the base skill.
4. **The typical-dinosaur template (168) is a creature row.**

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/canada-survey` | cache built (194 pp, text layer), `canada` registered in `books.json`, offset +1 verified at six folios, survey written. No D1 change. |
| 2026-10-02 | `pal/data/canada-skills` | batch 1: six Professional Status rows (three skating, three skiing) and `Ice Skating` and `Snow Skiing` re-cited from the Skill List to printed 36. `~065-canada-skills.sql`, applied `--remote` before the PR. The three pilot notes on printed 37 are held under their *Ultimate Edition* names and were left alone. |
| 2026-10-02 | `pal/data/canada-gear` | batch 2: 45 gear rows (`add-canada-gear.sql`) and 4 vehicles with 40 M.D.C. locations and 11 weapon entries (`add-canada-vehicles.sql`), both applied `--remote` before the PR. Three more false gaps found at extraction: Homemade M.D.C. Armor and both kinds of skis are held from *Warlords of Russia* (printed 173 and 187 there), which shipped after this survey's diff. This book prints 30-40 M.D.C. for light homemade armor where that one prints 30-45, and 40 M.D.C. for the communication helmet where the held *Ultimate Edition* row stores 30; the held rows were left alone. The dog sled (31) was not in the survey's gear count and is in. |
| 2026-10-02 | `pal/data/canada-bestiary` | batch 3: 34 creatures with 100 attacks (`add-canada-bestiary.sql`, written by `scripts/bestiary-sql.mjs`) and the Faerie Bot Vehicle (`add-canada-faerie-bot-vehicle.sql`), both applied `--remote` before the PR. Four extraction slices, then `book-reconcile` over the extracted rows: no number disagreed; four wording and placement findings were fixed before the apply. **The inventory missed the Faerie Bot Vehicle**: it is printed inside the Faerie Bot's own stat block (151) as its standard equipment. Ogopogo is two rows (adult and hatchling print their own figures) and the dinosaur template is three (one per size class). No rows, because none prints a stat block: Rogue Dog Packs (132), Faerie Folk (152), Russian Demons (173) and the other spirits of the north (180), five of which print only an M.D.C. total and an alignment. **The Giant Squid (154) is not a row**: its attributes, M.D.C. and Horror Factor are the *Underseas* p.24 row's exactly, so it is a reprint. It was applied `--remote` as `giant-squid-canada` and deleted again, with its five attacks, before this PR opened; the script that ships never had it. The Windigo Demon and the Loup Garou are their own rows beside *Spirit West*'s Wendigo and *Conversion Book One*'s Loogaroo: every attribute and pool compared differs. A Natural A.R. printed only for S.D.C. worlds is in `pools_note`, not `ar`. |
| 2026-10-02 | `pal/data/canada-classes-a` | batch 4: the 13 new classes on the printed 192 ladders, one `add-<id>-class.sql` each (`tundra-ranger`, `tundra-ranger-scout`, `tundra-ranger-cavalry`, `trapper-woodsman`, `centaur`, `cyber-horsemen-of-ixion`, `headhunter-assassin`, `headhunter-anti-robot-specialist`, `headhunter-techno-hound`, `momano-headhunter`, `true-sasquatch`, `worldly-sasquatch`, `inuit-shaman`), and five skills they grant that the survey's skill inventory missed because they are printed inside class entries (`~066-canada-class-skills.sql`: Fanatic Robophile, Hotwire Robot Vehicles & Power Armor, Language and Literacy: Techno-Can, Dog Sled). All applied `--remote` before the PR. Each draft read `ready` on `class-check --remote` and was then read against its pages by `book-reconcile`: no rules number disagreed; ration quantities on four Headhunter classes, two cybernetics the Momano was wrongly granted, and copied phrasing were corrected before the emit. Every class carries the ladder printed for it. The True Sasquatch's sexes are variants for skills and a pick-one ability for psionics, because a variant cannot carry psionics. Gear the classes print that has no catalog row is named in each class's `extraction_notes`, not stubbed. |
| 2026-10-02 | `pal/data/canada-races` | batch 5: the ten optional-PC races as playable R.C.C.s, per decision 1 (`aardan-tek`, `grackle-tooth`, `greot-hunter`, `mastadonoid`, `noli-bushman`, `yeno`, `armored-slayer`, `faerie-bot`, `loup-garou`, `ogopogo`), one `add-<id>-class.sql` each, applied `--remote` before the PR. Each read `ready` on `class-check --remote` and was read against its pages by `book-reconcile`; no rules number disagreed. The six D-Bees store no ladder (a D-Bee takes its O.C.C.'s); the other four store the Dragon ladder copied from `dragon-hatchling`, as the note on 192 and the Armored Slayer's own entry direct. **The Loup Garou names two ladders and prints Hit Points twice** (156): Dragon is stored, and the per-level Hit Points line; both readings are in its `extraction_notes`. Each race's *Available O.C.C.s* line is an `occ_restrictions` list where the book closes it, with this book's own classes added (the four new Headhunters for the Greot, the three Tundra Rangers for the Grackle Tooth, the Inuit Shaman for the Mastadonoid). **Names that resolve to no class and are left out, each said in the race's notes**: Military Specialist, CyberSlinger Cyborg, and for the Yeno the Assassin, Commando, Special Forces and Spy. Grunt is `merc-soldier` throughout, because `coalition-grunt` is barred to non-humans. The Noli Cowboy and Noli Scout psionic packages are prose. `aardan-tek` joins the pinned `yields_to_occupation` races in `regression.mjs`: its P.P.E. is printed as 5D6 or per magic O.C.C. |
| 2026-10-02 | `pal/data/canada-techno-warrior` | batch 6: `headhunter-techno-warrior` takes this book's printing (110-112), per decision 2. `~067-canada-headhunter-techno-warrior.sql`, applied `--remote` before the PR. Nine figures change from the *Ultimate Edition* printing and the script's header lists each: P.E. bonus gone, roll bonus gone, Perception gone, Language: Native 80% +1%, the three languages at +10%, Radio: Scramblers in place of Electronic Countermeasures, Jujitsu in place of Commando, two related skills at level 3, 1D4 implants. The class now cites this book, so it counts here and no longer under `rue`. The Lore and GM Notes body is still the wording written from *Ultimate Edition*. |
| 2026-10-02 | `pal/data/canada-techno-warrior-rue` | batch 6 reversed: `~068-headhunter-techno-warrior-ultimate-edition.sql` undoes each of `~067`'s eleven replacements, so `headhunter-techno-warrior` reads exactly as it did before and cites *Ultimate Edition* again. Applied `--remote` before the PR. The class counts under `rue` again and this book is back to 23. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **The Momano Headhunter's psionics group names its bands in parentheses** (`~074`). It was written "Psionics 01-50: None", a day after the Roll d100 button shipped reading "(01-50)". Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a2-reprints-compared` | **The Centaur and the pilot notes compared with their held rows** (`~094`). The `creatures` row `centaurs` cites Conversion Book One revised (2002), newer than this book (1999), and stands on every figure both print, although this book calls its block an update. Taken from printed 102-103, because Conversion Book One does not state them: swim 50%, W.P. Bow and Arrow, and the equipment list. The kick damage both books print (2D6 front, 4D6 rear) had been dropped and is restored. The three pilot notes of printed 37 match the held skills; `Tracked & Construction Vehicles` gains RUE's tank and APC penalty. Off renders, checked again by `book-reconcile`. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/d-bees-of-north-america-canada-updates` | **Eleven classes leave this book's count for D-Bees of North America** (`~097`): `centaur`, `cyber-horsemen-of-ixion`, `true-sasquatch`, `worldly-sasquatch`, `aardan-tek`, `grackle-tooth`, `greot-hunter`, `mastadonoid`, `noli-bushman`, `yeno`, `faerie-bot`. D-Bees (2007) reprints and updates each, and by Nate's ruling of 2026-10-04 the newest printing wins and the class moves its `source_book`. This book's figures, including the experience ladders of printed 192, are kept in each class's `extraction_notes`. **One held-row error found against this book:** `grackle-tooth`'s GM Notes said the heading reads Crackle Tooth, which is the text layer's misreading: the render of printed 133 reads Grackle. **For the Noli occupations planned from this book:** D-Bees no longer names the Noli Cowboy and Noli Scout of printed 138; it prints the psionic package on the race and lists Cowboy, Wilderness Scout and Vagabond as occupations. Neither book's Noli entry prints a language line. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a8-class-extras` | **`Language: Inuit` is a row** (`~114`), at the 50% +5% every spoken language carries, tagged `rifts` as `Language: Techno-Can` is; `tundra-ranger-scout` and `trapper-woodsman` grant it at 65% instead of asking the player to name a `Language: Other` pick. The Scout's Native American tongue stays a `Language: Other` pick, as Spirit West's tribal languages are. The Noli Cowboy and Scout packages needed nothing: `~097` made them a pick-one group keyed to the occupation when the race moved to D-Bees. Skills 1 up. Applied `--remote` before the merge. |

### What remains

Nothing from the agreed plan. `node scripts/source-coverage.mjs --remote`,
2026-10-02, after batch 5; batch 6 and its reversal leave it unchanged:

```
  canada             120 / 0
```

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            14   description still says STUB - created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           43   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

No class script in this import wrote a stub (`class-check --emit-script`
reported 0 stub statements for all 23), so none of those lines is this book's.
`other` is 0: every row citing this book carries a page the cache holds.

**Left for a later decision, none of it imported:**

- Gear the classes print that has no catalog row. Each class names its own in
  `extraction_notes`: the Rangers' pick-hatchet, survival kit, climbing
  anchors, mallet, web vest and winter cap; the Headhunters' black paint
  stick, plastic gloves and NG-S2 survival pack; the Worldly Sasquatch's comb
  and loincloth; and others.
- A Native American tongue has no row: the book names no tribe, so the
  Tundra Ranger Scout takes it as a `Language: Other` pick. (`Language: Inuit`
  is a row since `~114`.)
- The Noli's cut of O.C.C. Related and Secondary Skills to three each, for a
  Wilderness Scout or Vagabond, is applied by hand. (The psionic packages are
  enforced since `~097`: a pick-one group on `noli-bushman` keyed to the
  occupation.)
- The cold, exposure and snow-travel rules (23-35) and the gazetteer.
