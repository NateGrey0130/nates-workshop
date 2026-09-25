# Rifts World Book 6: South America — survey

**Status:** `importing` — gear, Biomancy spells, vehicles, all 8 O.C.C.s and 16 R.C.C.s shipped; creatures and notable NPCs next. (2026-09-25)

**Rows citing this book:** classes 24, gear 36, vehicles 19, skills 1, spells 24

Slug `south-america`. Cached 2026-09-24 from
`Rifts- World Book 6 South-America.pdf`, 170 PDF pages, **text layer** (no
OCR). `--probe` median 4,239 chars/page, 36.9% stop words, so this is a real
text layer and not the glyph-dropped kind (`BOOK-INGEST-AUDIT` F73). Third
printing, 1998; copyright 1994.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio on five pages rather than trusting the vote:

| cache page | folio printed on it | offset |
|---|---|---|
| `p020` | 19 | +1 |
| `p060` | 59 | +1 |
| `p100` | 99 | +1 |
| `p140` | 139 | +1 |
| `p169` | 168 | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 168**;
`ocr-book.py` wrote 167 into the manifest. Cache `p169` holds the Experience
Tables (printed 168) **and** the page-169 "same as" ladder notes, because the
text layer did not break between them. Cache `p170` is the blank back cover.

## Cache health

| key | pages | where it matters |
|---|---|---|
| `welded_pages` | 160 | **printed 159**: the Black Galleon's weapon list runs into a heading "The Black Ship" and items 3-4. Render it; the fragment may be Galleon items |
| `corrupt_pages` | 31, 47, 87, 105, 116 | p087 = the Manoa map labels, p105 = a near-empty art page (printed 104), the rest one hit each. p116 = printed 115, the Oracle Cat / Sekhmet page; read its numbers off a render |
| `substituted_digits` | 46, 82, 110 | printed 45 (Kryang's pirates), 81 (Raptor, `!D4xlO`), 109 (Flying Tiger). Read the ink as the dice it has to be |
| **not flagged, still out of order** | printed 22-23, 139 | the Colombian RC-15 / Dragon-1 / RP-C20 stat blocks and the NE-10 rifle's block sit away from their headings. **Render those pages** before transcribing any number |
| blank / art-only | printed 26, 28, 30, 35, 76, 96, 104, 108, 137, 140, 151, 164 | no text on the page (cache files of 1-9 bytes). Printed 104 is the p105 `corrupt_pages` hit, and 164 sits between Archill's intro (163) and his stats (165) |

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-6** (cache p005-p007) | *Contents* and *Quick Find Table* | page of every section, class, gear item, vehicle and NPC. The Quick Find lists 25 O.C.C./R.C.C. lines, one of which (*Other O.C.C.s*, printed 48) is a prose cross-reference, not a class |
| **48** | *Other O.C.C.s* | which outside books' O.C.C.s suit the setting. No stats |
| **64-68** | *Biomancer Spell Descriptions* | the Biomancy spell list, by level heading (1-10) |
| **68** | *Available Common Spell Magic* | the ordinary invocations a Biomancer may learn, levels 1-14, by name |
| **168-169** | *Experience Tables* | eight printed ladders, plus five "same as" notes naming another class's ladder |

### The XP ladders (printed 168-169)

| ladder | classes |
|---|---|
| Anti-Monster and Amazon | Anti-Monster O.C.C., Amazon R.C.C. |
| Sailor & Felinoid Mutant | Sailor O.C.C., Felinoid (Jaguar Mutant) R.C.C. |
| Pirate & Lizard Man (the cache reads "Lizard Map") | Pirate O.C.C., Lizard Men R.C.C. |
| Voodoo Priest, Jungle Elf & Totem Warrior | three classes |
| Biomancer | Biomancer O.C.C. |
| Ewaipanomas | Ewaipanomas R.C.C. |
| Flame Panther, Flying Tiger & Oracle Cat | three Felinoid R.C.C.s |
| Hunter Cat & Sekhmet | two Felinoid R.C.C.s |
| Cibola Pincer Warriors & Cibola Gatherers | two Cibolan R.C.C.s |
| *same as Undead Slayer* | Atlantean Monster Hunter O.C.C. |
| *same as the dragon R.C.C.* | Pogtalian Dragon Slayer R.C.C. |
| *same as the Psi-Stalker* | Werejaguar and Werepanther R.C.C. |
| *same as the Vagabond* | Grimbor R.C.C. |
| *same as the Mystic* | Tribal Shaman O.C.C. |

**No ladder for the Shaydor Spherian** (printed 103), which is tagged
optional PC. It is a master psionic, so the plan below borrows the Mind
Melter's and says so in `extraction_notes`. `mind-melter`, `mystic`,
`psi-stalker` and `vagabond` all exist in production. **`undead-slayer` does
not** — read its ladder from Rifts Africa, or store the Monster Hunter's ladder
as a note, at import time.

## Inventory

Counted by structure over all 170 cached pages, by four slice agents and then
hand-checked where they disagreed.

| section | printed | what is there |
|---|---|---|
| Cudbury's travelogue, geography | 7-15 | lore |
| Republic of Colombia | 16-34 | **7 weapons** (22-24), **6 vehicles** (25-34: D-20 exo-skeleton, D-30 Conquistador, G-9A Jaguar, G-18B Aguirre, Lancero tank/APC, Zancudo helicopter), then the **Anti-Monster O.C.C.** (34-37) |
| Vampire Kingdom of Haktla | 37-42 | **Enumu** (39) and **Hak-Talon** (40) with stat blocks; **Giant Vampire Bats**, a creature (41-42) |
| Pirate Kingdoms | 43-48 | **King Kryang** (44-45), a *typical Kryang pirate* template (45); **Sailor** and **Pirate** O.C.C.s (46-48) |
| Kingdom of Bahia | 49-54 | **Voodoo Priest O.C.C.** (51-53); **Loas**, Ghostly and Divine (53-54), stated NPC-only |
| Maga Island | 54-70 | **Jungle Elf R.C.C.** (57-59), Trees of Wisdom and Memory Trees (58-61, NPC beings), **Biomancer O.C.C.** (61-64), **24 Biomancy spells** (64-68), **8 bio-weapons and bio-armors** (69-70) |
| Kingdom of Lagarto | 71-85 | **Melastirth** (75-77), **Stleet** (77-78), **Lizard Men R.C.C.** (79, optional PC), **3 Kittani vehicles** (79-85: Raptor, Allosaurus Firedrake, Tyrannosaurus) |
| El Dorado: Manoa | 86-104 | **4 weapons + 3 enchanted armors** (91-92), **Hoplite** power armor (92-95), **Lictor** robot (95-97), **Amazon R.C.C.** (97-99), **Atlantean Monster Hunter O.C.C.** (99-101) with the True Atlantean block (100) and **Monster-Shaping Tattoos** (101-103), **Ewaipanomas R.C.C.** (102-103), **Shaydor Spherian R.C.C.** (103) |
| Omagua and the Felinoids | 105-122 | *Mutant Cat R.C.C.* (107, a pointer to other books, **not a class**), **Felinoid Jaguar Mutant** (107-109), **Flying Tiger** (109-111), **Flame Panther** (111-113), **Hunter Cat** (113-115), **Oracle Cat** with a Divine Oracle note (115-116), **Sekhmet** (116-117), **Werejaguar / Werepanther** (117-118, one stat block); **Bast** (119-120) with the Cat's Gauntlet, **Yaguar-Ogui** (120-121), **Simba** (121-123) with his War Club |
| Cibola | 123-144 | **Inix** (127-128), **Soul Worms** (127-128, NPC-only R.C.C.), **Malkhom** (129), **Iridna** (130), **Rendell** (131), **Kastor** (132-134); **Gatherer** (134), **Pogtalian Dragon Slayer** (135-136), **Pincer Warrior** (136), **Grimbor Ape-Men** (138) R.C.C.s; **NE-4P / NE-10 / NE-200** plasma weapons (139); **Dragon Death** power armor and **FP-10 Flying Platform** (141-142); **5 drugs and potions** (143-144) |
| The Rain Forest | 145-152 | **Tribal Shaman** (145-146) and **Totem Warrior** (146-147) O.C.C.s; **Ellal** (148-149), **Trelque-huecuve** (149-150), **Huecu** (150) creatures; **Aunyain** (152), an R.C.C.-shaped monster race with no player note and no ladder |
| Ships | 152-159 | **Splugorth Slaver Raider** (152-154), **Slaver Mothership** (154-156), **Corsair Hydrobike** (156-157), **Piranha** attack boat (157-158), **Black Galleon** gunboat (158-159) |
| Nightmare Island | 159-167 | **Kharkon** (160-161), **Dalgon** (162), **Archill** (163-165) with stat blocks; **the Black Ships**, demonic vessels (165-167) |
| Experience Tables | 168-169 | the table above |

### Things this book has zero of, checked rather than assumed

- **Psionic powers: none defined.** Every `I.S.P.` hit is a class or NPC
  naming existing powers. Lightning Nectar (printed 144) grants one of five
  named super powers, all in the catalog's vocabulary.
- **Skills: none defined.** Ship Mechanics is told to work like Aircraft
  Mechanics (printed 48); no new skill block exists.
- **Spells outside Biomancy: none defined.** The Voodoo Priest, Tribal Shaman,
  Werejaguar, Aunyain and the gods name existing invocations.

## Classes

### Playable O.C.C.s (8)

| class | printed | ladder | proposed id | note |
|---|---|---|---|---|
| Anti-Monster | 34-37 | Anti-Monster & Amazon | `anti-monster` | a mystic full conversion: supernatural M.D.C. body, P.P.E. and I.S.P. burned to 1D4, six fixed spells used a set number of times a day, a rejection crisis roll. Body and powers are data; the rejection roll and the per-day spell counts are prose |
| Sailor | 46-47 | Sailor & Felinoid Mutant | `sailor` | plain men of arms |
| Pirate | 47-48 | Pirate & Lizard Man | `pirate` | Hand to Hand swap by alignment is a choice plus prose |
| Voodoo Priest | 51-53 | Voodoo / Jungle Elf / Totem | `voodoo-priest` | its own spell ladder; loa commune and control are abilities, not spells |
| Biomancer | 61-64 | Biomancer | `biomancer` | Biomancy tradition plus the named common spells (printed 68). Create Bio-Weapons is an ability |
| Atlantean Monster Hunter | 99-101 | same as Undead Slayer | `atlantean-monster-hunter` | a Tattooed Man. Monster-Shaping Tattoos are a SYSTEM (cost scales by the target's M.D.C. tier), not a list of named tattoos, and its other tattoos are picked by category from Rifts Atlantis. Race limited to True Atlantean, human, ogre, Chiang-Ku |
| Tribal Shaman | 145-146 | same as Mystic | `tribal-shaman` | spell ladder and two percentile rituals |
| Totem Warrior | 146-147 | Voodoo / Jungle Elf / Totem | `totem-warrior-south-american` | **`totem-warrior` is taken** by Spirit West's (printed 42-44 there). This one channels one of seven Amazon totems into its own body; the suffix follows the `-russian` precedent |

### Playable R.C.C.s (15)

| class | printed | ladder | proposed id | note |
|---|---|---|---|---|
| Jungle Elf | 57-59 | Voodoo / Jungle Elf / Totem | `jungle-elf` | takes an O.C.C. from a weighted list; innate Biomancy and major psionics |
| Lizard Men | 79 | Pirate & Lizard Man | `lizard-man-lagarto` | takes any O.C.C. but Borg or Coalition military. Distinct from Conversion Book One's creature row *Palladium Lizard Men* |
| Amazon | 97-99 | Anti-Monster & Amazon | `amazon` | chooses magic OR psionics; M.D.C. on Rifts Earth |
| Ewaipanomas | 102-103 | Ewaipanomas | `ewaipanomas` | optional PC; takes an O.C.C. (70% Earth Warlock, 20% Stone Master) |
| Shaydor Spherian | 103 | **none printed**; Mind Melter's borrowed | `shaydor-spherian` | four orientations (Healer, Sensitive, Explorer, Warrior), each with its own I.S.P. formula. Expect four variants |
| Felinoid (Jaguar Mutant) | 107-109 | Sailor & Felinoid Mutant | `felinoid` | optional PC; O.C.C. percentage table |
| Flying Tiger | 109-111 | Flame Panther / Flying Tiger / Oracle | `flying-tiger` | |
| Flame Panther | 111-113 | Flame Panther / Flying Tiger / Oracle | `flame-panther` | |
| Hunter Cat | 113-115 | Hunter Cat & Sekhmet | `hunter-cat` | Killing Frenzy is prose |
| Oracle Cat | 115-116 | Flame Panther / Flying Tiger / Oracle | `oracle-cat` | the Divine Oracle is a note (double XP), not a separate block |
| Sekhmet | 116-117 | Hunter Cat & Sekhmet | `sekhmet` | |
| Werejaguar / Werepanther | 117-118 | same as Psi-Stalker | `werejaguar` | **one stat block for both**; a `werepanther` variant carries only the name |
| Gatherer | 134 | Pincer Warriors & Gatherers | `cibola-gatherer` | "not recommended" for players but G.M.-allowed, and it has a ladder |
| Pogtalian Dragon Slayer | 135-136 | same as the dragon R.C.C. | `pogtalian-dragon-slayer` | Energy Aura is prose plus a pool |
| Pincer Warrior | 136 | Pincer Warriors & Gatherers | `cibola-pincer-warrior` | as the Gatherer; M.D.C. grows per level |
| Grimbor Ape-Man | 138 | same as Vagabond | `grimbor` | |

That is sixteen rows: fifteen R.C.C.s plus the Werepanther as a variant.

### Not a class

- **Mutant Cat R.C.C.** (printed 107): a pointer to Heroes Unlimited, TMNT and
  Vampire Kingdoms. No stats.
- **Soul Worms** (printed 127-128): an R.C.C. stat block stated NPC-only. It
  becomes a **creature**.
- **Aunyain** (printed 152): R.C.C.-shaped, no player note, no ladder. A
  **creature**.
- **True Atlantean** (printed 100): a racial block feeding the Monster Hunter.
  Recorded on that class.
- **Loas, Trees of Wisdom, Memory Trees**: NPC beings. Loas become creatures;
  the trees are left as setting.

## Gear

| group | printed | rows | note |
|---|---|---|---|
| Colombian weapons | 22-24 | 7 | RC-10, RC-15, Dragon-1, RP-C20, RR-C40, RAR-C15, RA-C15. **Render 22-23** |
| Bio-weapons and armor | 69-70 | 10 | priced in P.P.E. to create, not credits. `magic` category |
| Manoan weapons and armor | 91-92 | 8 | TW energy cell, 3 enchanted armors, Flamer, SK Stun Gun, Fireball Rifle, Stun Pistol |
| Cibolan weapons | 139 | 0 | NE-4P, NE-10, NE-200 are **already catalogued** from Phase World p.117-118 with identical stats (Phase World calls the pistol NE-4). Not re-imported |
| Drugs and potions | 143-144 | 5 | Dream, the Energizer, the Transformer, Enhancer, Lightning Nectar |
| Named artifacts | 120, 122-123 | 2 | the Cat's Gauntlet and Simba's War Club. They ride with their gods' NPC rows, not the gear catalog |

**30 gear rows shipped** (`add-south-america-gear.sql`): the bio-weapons
counted as ten, because *Enchanted Spears, Swords & Clubs* prints three
damage lines and became three rows. Everything else NPCs carry is unnamed or
already catalogued (Kittani Explorer Armor, rune swords by grade, the Naruni
guns).

## Vehicles (the `vehicles` table)

| group | printed | rows |
|---|---|---|
| Colombian | 25-34 | 6 |
| Kittani (Lagarto) | 79-85 | 3 |
| Manoan | 92-97 | 2 (Hoplite, Lictor) |
| Cibolan | 141-142 | 2 (Dragon Death, FP-10) |
| Ships | 152-159 | 5 (Slaver Raider, Slaver Mothership, Corsair Hydrobike, Piranha, Black Galleon) |
| Demonic | 165-167 | 1 (the Black Ships) |

**19 vessels.** Kittani and Splugorth rows already in production are Underseas
and Triax vessels; none of these nineteen names collide.

**Shipped** (`add-south-america-vessels.sql`): 19 vehicles, 150 M.D.C.
locations, 61 weapon entries. Printed 25 (the D-20's weight, `ISOlbs` = 180),
81 (the Raptor's `!D4xlO` = 1D4x10) and 159 (welded) were read off renders.
The Slaver Raider, Mothership and Black Ship print only what they *would*
fetch, so their cost is NULL with the figure in `cost_note`; the Black Ship
names no main body. Book slips are stored as printed and noted: the Lictor's
laser range "(610 km)", the Black Galleon's "50 mph (80 mph)", and the
Hoplite's ley-line recharge (three times four hours on printed 92, eight hours
on printed 94).

## Creatures and notable NPCs

**Creatures (about 9):** Giant Vampire Bat (41-42), Ghostly Loa and Divine Loa
(53-54), Soul Worm (127-128), Ellal (148-149), Trelque-huecuve (149-150), Huecu
(150), Aunyain (152), and the playable R.C.C.s' NPC views where past imports
added one.

**Notable NPCs (18):** Enumu, Hak-Talon, King Kryang, Melastirth, Stleet, Bast,
Yaguar-Ogui, Simba, Inix, Malkhom, Iridna, Rendell, Kastor, Kharkon, Dalgon,
Archill — sixteen named, plus the typical Kryang pirate (45) if the template
convention allows it. Named with no stat block, and left out: General de la
Plaza, General Collazo, Doctor Prometheus, Navaja, Amalia Collazo, Lord
Temarkhos.

## Catalog diff

Run against **production** on 2026-09-24:

| table | result |
|---|---|
| `imported_classes` | **0 of 23** by id or name. `totem-warrior` is Spirit West's; the Crazy and the Gargoyle *mention* South America and are not from it |
| `spells` | **0** citing the book; none of the 24 Biomancy names exist |
| `gear`, `vehicles`, `creatures`, `notable_npcs`, `skills`, `psionic_powers` | **0** rows citing the book. Kittani and Splugorth names present are Triax and Underseas items |
| `creatures` near-names | *Palladium Lizard Men* and *Lizard Mage* (Conversion Book One). Not this book's Lizard Men |

**Spell naming, decided at survey:** Biomancy is a tradition, so its spells
go in as `Biomancy: <Name>` with `tradition` `biomancy`, following the
`Nature:` / `warlock` convention (`spell-tradition-namespaces`). The
Biomancer's class grants the tradition plus the named common spells.

**Shipped as decided** (`add-south-america-biomancy-spells.sql`): 24 rows,
level and cost from the index on printed 64. The text layer sets the *Tree
Teleport* heading at the foot of *Strengthen Plants* (printed 67); the parser
puts it back. **One retelling is linked**: *Suspended Animation* ->
`Earth: Suspended Animation`. *Shrink Plant* agrees with `Earth: Shrink Plant`
on every number but fails `same-spell-lib`'s vocabulary floor (0.33 against
0.35) because that row's description is a paraphrase, so it is not linked.

Run `scripts/catalog-diff.mjs --remote` on each extracted set before writing
SQL. The name checks above are not a matcher.

## Extraction plan

Everything above cost nothing. The work in order, one PR each, applied
`--remote` before the PR, gear before classes so class drafts find real rows
(the Madhaven lesson):

1. **Registry and survey**: this file, the `books.json` entry and the queue row.
2. **Gear**: ~31 rows, every number from a render.
3. **Biomancy spells**: 24 rows, before the Biomancer and Jungle Elf need them.
4. **Vehicles**: 19 rows.
5. **O.C.C.s**: the eight above.
6. **R.C.C.s, part one**: Jungle Elf, Lizard Men, Amazon, Ewaipanomas,
   Shaydor Spherian, Gatherer, Pogtalian, Pincer Warrior, Grimbor.
7. **R.C.C.s, part two**: the seven Felinoids.
8. **Creatures and notable NPCs**, through the Phase 3 pipeline.

What is deliberately left, with the reason:

- The Mutant Cat pointer, the trees and the travelogue: no stats.
- Monster-Shaping Tattoos as catalog rows: a costing rule, not named items. It
  stays prose on the Monster Hunter.
- NPCs named without a stat block.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-24 | — | cache built (170 pp, text layer), offset +1 verified at five folios, `south-america` registered in `books.json`, survey written |
| 2026-09-25 | #1375 | gear: 30 rows (7 Colombian C-series weapons, 10 bio-weapons and bio-armors, 8 Manoan TW items and enchanted armors, 5 Cibolan drugs); the 3 Naruni NE weapons were already catalogued. Applied `--remote` first |
| 2026-09-25 | #1378 | Biomancy spells: 24 rows, `Biomancy: ` prefix, tradition `biomancy`, level and cost from the index on printed 64; Suspended Animation linked to `Earth: Suspended Animation`. Applied `--remote` first |
| 2026-09-25 | #1380 | vehicles: 19 (6 Colombian, 3 Kittani of Lagarto, 2 Manoan, 2 Cibolan, 5 ships, the Demon Black Ship), 150 locations, 61 weapons. Applied `--remote` first |
| 2026-09-25 | #1384 | the eight O.C.C.s (Anti-Monster, Sailor, Pirate, Voodoo Priest, Biomancer, Atlantean Monster Hunter, Tribal Shaman, Totem Warrior (South American)) and the Ship Mechanics skill they share. The Monster Hunter's ladder ("same as Undead Slayer") and the Tribal Shaman's ("same as the Mystic") have no catalog source: no `undead-slayer` class exists and `mystic` stores no `xp_table`, so both are left out and noted. Applied `--remote` first |
| 2026-09-25 | #1389 | R.C.C.s part one: Jungle Elf, Lizard Man of Lagarto, Amazon, Ewaipanomas, Shaydor Spherian, Gatherer (Cibola), Pogtalian Dragon Slayer, Pincer Warrior (Cibola), Grimbor Ape-Man; plus four gear rows their equipment names (Grimbor armor, yumbuto club, NE-10 magazine, dragon-skin armor). No ladder for the Shaydor (none printed), Pogtalian ("same as the dragon"), Grimbor ("same as the Vagabond"): the catalog's dragon and vagabond classes store none. Also removes the stale `add-ship-mechanics-skill.sql` run record. Applied `--remote` first |
| 2026-09-25 | #1395 | R.C.C.s part two, the seven Felinoids of Omagua: Felinoid (Jaguar Mutant), Flying Tiger, Flame Panther, Hunter Cat, Oracle Cat, Sekhmet, Werejaguar/Werepanther (one stat block, two name-only variants); plus the Flying Tiger's and Hunter Cat's armors as gear. No ladder for the Werejaguar ("same as the Psi-Stalker", which stores none). Salable-goods money is not stored as coin; Ancient Egyptian is a fixed Language: Other. Applied `--remote` first |
