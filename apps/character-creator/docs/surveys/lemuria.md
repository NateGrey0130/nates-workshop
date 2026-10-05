# Rifts World Book 32: Lemuria — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. (2026-10-05)

**Rows citing this book:** none

Slug `lemuria`. Cached 2026-10-05 from `Rifts- World Book 32 Lemuria.pdf`,
226 PDF pages, **text layer** (no OCR). `--probe` median 5,790 chars/page.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio in the cached page:

| cache page | folio printed on it |
|---|---|
| `p010` | 9 |
| `p030` | 29 |
| `p060` | 59 |
| `p088` | 87 |
| `p100` | 99 |
| `p150` | 149 |
| `p200` | 199 |
| `p224` | 223 |
| `p225` | 224 |

One region, no `page_offset_exceptions`. **`printed_pages` is 224**: the last
numbered folio is on cache `p225`, a catalogue page. `ocr-book.py` measured
223, and the registry outranks the manifest. Cache `p226` is an unnumbered
catalogue page. Cache `p001`-`p005` are cover, credits and the supporter
lists; `p006`-`p007` are the Contents (printed 5-6) and `p008` the Quick Find
(printed 7).

## Cache health

| key | cache pages | printed | where it matters |
|---|---|---|---|
| `welded_pages` | 3 | 2 | the credits; nothing to extract |
| `corrupt_pages` | 87 (1), 98 (1), 143 (1), 148 (2), 150 (1), 155 (4), 191 (1), 192 (1), 223 (11) | 86, 97, 142, 147, 149, 154, 190, 191, 222 | **86 is the Experience Tables page**: read every ladder off a render. 97 is Biomancy level five; 142 the Squid Pack; 147 and 149 the Cloud Shell and Cloud Wind; 190-191 the Panther Shark and Sea Lance. 154 and 222 are maps |
| `substituted_digits` | 30 pages | throughout | worst: cache p97 (3), p60, p171 and p214 (2 each). p97 is Biomancy levels four and five, p171 the Giant Sea Slug, p214 the Ghost Dragon. Read the token as the dice it must be; a render does not help |

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p006-p007** | 5-6 | *Contents* | the printed page of every section and entry |
| **p008** | 7 | *Quick Find* | a second reading of the page of the stat blocks and rules |
| **p087** | 86 | *Experience Tables* | the ladder each class uses; the classes share ladders in groups |
| **p087-p088** | 86-87 | the alphabetical listing of Biomancy spells | the canonical name of each Biomancy spell, with its P.P.E. cost, level, *(New)* tag and page |
| **p088-p107** | 87-106 | the *Level One* to *Level Twelve* headings | each Biomancy spell's level, and a *(New)* tag on the ones this book adds |
| **p107-p108** | 106-107 | the list of invocations open to Biomancers | which general spells the class may also take |

**The Contents cannot be paired from the text layer.** It delivers the entry
names and the page numbers as separate runs. This survey took every page
number below from where the heading sits in the body, found by font size
(section titles are set at 23 pt and up, entry titles at 15-16 pt, body text
under 10 pt), and used the Contents only for names. Read the Contents and the
Quick Find off a render before relying on either for a number.

**Biomancy levels and costs are printed twice**: in the alphabetical listing
and again in the body, under the level heading and in the entry's own lines.
The listing is the name authority. Levels and costs are reconciled between
the two, not just transcribed.

## Inventory

Counted by structure (headings by font size, and `Alignment:` stat lines)
over all 226 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Author's note, the Lemurians, people, navy, technology, castes | 8-15 | lore |
| The Mauian Order | 15-20 | lore; **1 named NPC** (Maui-Tikitiki, block on 18-20) |
| Floating Cities, the City of Mu, Garden Valley, Finding Lemuria | 21-27 | places |
| Easter Island and the Moai | 28-31 | the **Moai**, a piloted stone guardian with M.D.C. by location (30-31) |
| Agriculture and Food, Biomancer Gardens | 32-40 | **10 plant entries**; the Carnivorous Blue Fruit Tree (34) carries a creature stat block |
| Aquatic Races | 41-54 | **4 R.C.C.s** and **2 animals** (the two Lemurian lemurs, 50-51) |
| New and Notable Skills | 54-59 | **29 named skills** in four groups, then optional underwater combat rules (59) |
| Lemurian O.C.C.s of Note | 60-82 | **7 O.C.C.s** |
| New Water-Based Psionics | 82-85 | **21 powers**: 15 exclusive to the Spouter and 6 Hydro-Super-Psionics |
| Experience Tables | 86 | one page |
| Lemurian Biomancy | 86-106 | **86 spells** over twelve levels, **62 tagged new** |
| New Ocean Magic Spells | 108-109 | **8 spells** |
| Biomancy Bio-Armor | 110-130 | shared features (110), **10 Bio-Armors** and the Wave Strider body armor (129) |
| Lemurian Bio-Weapons | 131-134 | **9 entries**: six weapon families and three single weapons |
| Lemurian Ranged Weapons | 134-136 | **10 weapons** |
| Bio-Construct Symbiotes | 136-143 | **11 entries** |
| Lemurian Transportation | 144 | **2 entries** (Bubble Pack, Serpent Saddle) |
| Symbiotic Combat Vehicles | 145-153 | shared features (145) and **6 vehicles** |
| Enemies of Lemuria | 154-166 | a map (154); the Milu (**2 stat blocks**, living on 155 and vampire on 157); Davey Jones (**1 named NPC**, block on 161); other enemies and relations (162-166), lore |
| Exotic Creatures of the Sea | 167-188 | **14 creatures** |
| Sea Monsters and War Steeds | 189-207 | **9 creatures** |
| Sea Dragons | 208-220 | **5 dragons**; four carry a hatchling player-character line |
| Maps, catalogue | 221-224 | two ley line maps; advertisements |

`Alignment:` opens a stat block on 43 cached pages, and every one is
accounted for in the table above.

## Classes

### Playable R.C.C.s (4) — printed 41-54

| class | printed | note |
|---|---|---|
| Ichthylean | 41-43 | points at another class's ladder on 86 |
| Junk Crab | 43-47 | includes rules for building its armored shell (45-46) |
| Lemurian | 47-50 | the race; special abilities and stats on 48-50 |
| Meran | 52-54 | tagged as an optional player character or NPC |

### Playable O.C.C.s (7) — printed 60-82

| class | printed | group |
|---|---|---|
| Biomancer Gene-Mage | 60-65 | practitioner of magic; three schools (61), plant P.P.E. rules |
| Birdman Warrior | 66-67 | man-at-arms |
| Oceanic Guardsman | 68-69 | man-at-arms |
| Sea Sentinel | 70-72 | man-at-arms |
| Serpent Hunter | 73-76 | man-at-arms |
| Lemurian Scout | 77-79 | adventurer |
| Spouter | 80-82 | psychic; owns the fifteen exclusive Hydro-Psionics |

Printed 86 holds six ladders, read off a render on 2026-10-05: Birdman and
Junk Crab; Gene-Mage and Milu; Oceanic Guardsman and Ichthyleans; Sea
Sentinel and Lemurian Scout; Serpent Hunter; Spouter. The Lemurian and Meran
R.C.C.s are not named on it. That page is flagged corrupt, so the figures are
transcribed from a render too.

**The catalog holds a `biomancer` class already.** The Biomancer Gene-Mage is
a different class with its own entry; it gets its own id and the held class
is left alone.

### Four dragons with a hatchling player-character line

Ghost Dragon (211-214), Hydros Dragon (215-216), Octo Dragon (216-218) and
Sand Dragon (219-220) each say a hatchling may be a player character. The
Leviathan (208-210) is tagged as a non-player monster.

### Not player characters, by the book's own tags

- The living Milu (155) and Davey Jones (161) are tagged as NPC villains.
- The Leviathan (208-210) is tagged as a non-player monster.
- The Sea Dragon Turtle (182-183) is tagged as not recommended for players.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-05 with
`scripts/catalog-diff.mjs`. No row in any table cites this book.

### classes: 11 entries, 0 matched, 11 missing, 0 false gaps

None is held. The nearest names (Biomancer, Road Sentinel, Juicer Scout) are
different classes.

### spells, Biomancy: 86 entries, 22 held, 1 probable rename, 63 missing

The catalog holds 24 spells named `Biomancy: ...`. Against this book's 24
entries without a *(New)* tag:

- **22 are held** under the `Biomancy:` prefix. The diff reported two of
  them (Shrink Plant, Suspended Animation) as missing because it paired them
  with the Earth warlock spells of the same bare name; both are held.
- **Animal Phantom** (level 5) is probably the held `Biomancy: Animal Ghost`
  (level 5). Confirm against the text before treating it as a rename.
- **Heal Plants** (level 1) carries no *(New)* tag and is not held.
- The held `Biomancy: Woodland Entity` is not reprinted here.
- The held `Strengthen Plants` is printed here in the singular.

The 62 tagged new are all missing. **Remove Symbiotes** (level 11) shares its
bare name with a held level 0 row that is not a Biomancy spell; under the
`Biomancy:` prefix the two do not collide.

### spells, Ocean Magic: 8 entries, 0 matched, 8 missing

Buoyancy Blast, Capture Moisture, Current Curtain, Depth Tolerance, Draw
Water, Light up the Deep, Manipulate Thermoclines, Water Shield. The catalog
holds 42 `Ocean:` spells and none of these eight.

### psionic_powers: 21 entries, 0 matched, 21 missing, 0 false gaps

Fifteen Spouter powers (Hold Breath through Water Walk Telekinesis) and six
Hydro-Super-Psionics (Hydro-Magnet, Hydration, Water Breathing, Water
Pressure Endurance, Water Shield, Wave Attack). The held Hydrokinesis,
Telekinesis and Psychic Purification are different powers. **Water Shield is
the name of both a super-psionic here and an Ocean Magic spell here**; they
sit in different tables.

### skills: 29 entries, 19 held, 10 missing, 2 false gaps

Seventeen match by name and two by alias (Navigation; Military: Warships &
Patrol Boats). Of the twelve the diff called missing, two are held under
another name:

| the book prints | the catalog holds |
|---|---|
| Submersibles | Boat: Submersibles and Military: Submersibles |
| Underwater Navigation | Navigation: Underwater |

The ten that are new: Horsemanship: Aquatic Animals, Horsemanship: Sea
Monsters, Horsemanship: Serpent Hunter, Language: Cetacean, Language:
Ichthylean/Milu, Language: Lemurian, Language: Oceanic, Lore: Sea Creatures,
Hand to Hand: Demon Combat, Symbiotic Conduit Vehicle Combat.

### gear: 43 entries, 1 name collision, 42 missing

The one match is **Bio-Energy Bow**, held from South America (p.70). Whether
that is the same item is not settled by the name; compare the two entries at
extraction. Everything else is new: 11 armors, 9 Bio-Weapon entries, 9 other
ranged weapons, 11 symbiotes and 2 transportation items.

### vehicles: 6 entries, 0 matched, 6 missing

Sea Dart Interceptor, Cloud Shell, Cloud Wind, Wave Shadow Submarine,
Scuttler Submersible Tank, Wind Seer. The Moai (30-31) would be a seventh.

### creatures: 29 entries, 0 matched, 29 missing, 0 false gaps

Two lemurs, the living Milu, the Mahiki Milu, 14 exotic sea creatures, 9 sea
monsters and war steeds, the Leviathan, and the Carnivorous Blue Fruit Tree.
The near names (Land Ray for Line Rays, Hydra Dragon for Hydros Dragon) are
other creatures from other books.

### notable_npcs: 2 entries, 0 matched, 2 missing

Maui-Tikitiki and Davey Jones. **The Lord of the Deep is held** from
Underseas (p.43-44); printed 163 here is lore with no stat block.

## Extraction plan

Gear and vehicles ship before classes, because the class equipment lists
name this book's items (the Madhaven lesson). Spells ship before the
Biomancer Gene-Mage for the same reason.

1. **Skills** — 10 rows from printed 54-59.
2. **Spells** — 63 Biomancy rows (62 tagged new, and Heal Plants) from
   printed 87-106 and 8 Ocean Magic rows from 108-109, one batch per level
   heading. Printed 97 from a render.
3. **Psionic powers** — 21 rows from printed 82-85.
4. **Gear** — 42 rows from printed 110-144, the Bio-Energy Bow decided after
   it is compared with the held row.
5. **Vehicles** — 6 rows from printed 145-153, through
   `scripts/vessel-sql.mjs`. Printed 147 and 149 from renders.
6. **Creatures** — 29 rows, through `scripts/bestiary-sql.mjs`. Printed
   190-191 from renders.
7. **Notable NPCs** — Maui-Tikitiki and Davey Jones.
8. **Classes** — 4 R.C.C.s and 7 O.C.C.s, ladders off a render of printed 86.

Each batch is extracted by `book-extract-worker` and checked by
`book-reconcile` before its script is written.

**For Nate to decide before extraction:**

- **The four hatchling dragons** (211-220): playable R.C.C.s as well as
  creature rows, or creature rows only.
- **The Moai** (30-31): a vehicle row, or left as a place feature.
- **The ten garden plants** (34-40): only the Carnivorous Blue Fruit Tree has
  a stat block. The other nine are crops and hazards with effects in prose;
  gear rows, or left.
- **Animal Phantom**: rename the held Animal Ghost, or keep both, once the
  two texts are compared.

What is deliberately left, with the reason for each:

- **The 22 held Biomancy spells** — held; the reprint is compared at
  extraction and any difference recorded, not overwritten.
- **The 19 held skills** — held already; which book each row came from was
  not traced for this survey.
- **The Lord of the Deep** (163) — held from Underseas; no stat block here.
- **The Junk Crab shell-building rules** (45-46), **optional underwater
  combat** (59) and **plant P.P.E. rules** (62) — rules text, cited from the
  class rows rather than stored as rows.
- **Cities, Easter Island, maps, relations with other peoples** — places and
  lore.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-05 | `pal/data/lemuria-survey` | cache built (226 pp), `lemuria` registered in `books.json`, this survey written, offset +1 verified. No data. |

### What remains

Everything in the plan. Nothing from this book has been imported.
