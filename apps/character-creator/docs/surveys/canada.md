# Rifts World Book 20: Canada — survey

**Status:** `importing` — skills, gear and vehicles shipped; creatures next. (2026-10-02)

**Rows citing this book:** gear 45, vehicles 4, skills 8

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
2. **`Headhunter Techno-Warrior`: the printing with the highest World Book
   number wins.** Production's row (id 23) cites *Rifts Ultimate Edition*
   p.74-77, which is not a World Book, so this book (World Book 20) is the
   only numbered printing and printed 110-113 wins wherever the two differ.
   It is a correction to the existing row, never a second row. The two
   ladders already agree: the row's `xp_table` is the HH Techno-Warrior
   ladder on printed 192.
3. **The skating and skiing specialisations are rows of their own**, not
   prose on the base skill.
4. **The typical-dinosaur template (168) is a creature row.**

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/canada-survey` | cache built (194 pp, text layer), `canada` registered in `books.json`, offset +1 verified at six folios, survey written. No D1 change. |
| 2026-10-02 | `pal/data/canada-skills` | batch 1: six Professional Status rows (three skating, three skiing) and `Ice Skating` and `Snow Skiing` re-cited from the Skill List to printed 36. `~065-canada-skills.sql`, applied `--remote` before the PR. The three pilot notes on printed 37 are held under their *Ultimate Edition* names and were left alone. |
| 2026-10-02 | `pal/data/canada-gear` | batch 2: 45 gear rows (`add-canada-gear.sql`) and 4 vehicles with 40 M.D.C. locations and 11 weapon entries (`add-canada-vehicles.sql`), both applied `--remote` before the PR. Three more false gaps found at extraction: Homemade M.D.C. Armor and both kinds of skis are held from *Warlords of Russia* (printed 173 and 187 there), which shipped after this survey's diff. This book prints 30-40 M.D.C. for light homemade armor where that one prints 30-45, and 40 M.D.C. for the communication helmet where the held *Ultimate Edition* row stores 30; the held rows were left alone. The dog sled (31) was not in the survey's gear count and is in. |

### What remains

Everything: nothing from this book has shipped. `source-coverage.mjs` has no
line for a book no row cites, so there is nothing to paste yet.
| 2026-10-01 | `pal/docs/canada-decisions` | the four decisions Nate settled; plan agreed. No D1 change. |
