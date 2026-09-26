# Rifts World Book 9: South America 2 — survey

**Status:** `importing` — skills, spells, gear, vehicles and 29 classes shipped; New Babylon and Larhold classes, then NPCs and creatures, next. The plan below was agreed by Nate on 2026-09-25. (2026-09-25)

**Rows citing this book:** classes 29, gear 60, vehicles 23, skills 8, spells 35

Slug `south-america-2`. Cached 2026-09-25 from
`Rifts- World Book 9 South America 2.pdf` (copied from a `kupdf.net` download),
193 PDF pages, **scan (no text layer)** — `--probe` median 0 chars/page on all
twenty samples. OCR at 300 dpi, psm 3, by `ocr-book.py`. Cat. No. 819,
192 printed pages. **This is a different book from `south-america`** (World
Book 6), which has its own survey and its own session.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 0` — the cache page IS the printed folio, so printed F is
`pF.txt` and `pymupdf d[F-1]`. Checked by render, not only by the vote: the
contents page printed 4 is `d[3]`, printed 30 (Rune Warrior / Nazcan Line
Magic) is `d[29]`, printed 190 (Blue Flame Spells) is `d[189]`, printed 192
(Experience Tables) is `d[191]`. `ocr-book.py` measured +0 over the whole book.

**`printed_pages` is 192.** The manifest says 184 because the last folio the OCR
could read was 184; 185-192 are text pages whose folio the OCR lost. Cache
`p193` is the back cover.

## Cache health

This is a scan, so none of `welded_pages`, `corrupt_pages` or
`substituted_digits` is computed; the damage is OCR's. What the four slice
readers found that touches a number:

| pages | fault | remedy |
|---|---|---|
| 22, 27, 110, 172, 174 | full-page art, glyph noise only | nothing to read |
| **85** | **empty** — 0 bytes in `txt` and `raw.txt` | rendered 2026-09-25: a full-page illustration of Arkhon power armor; nothing lost |
| 30, 34, 90, 97, 111, 117, 142, 166, 191 | `|` or `l` for **1** (`|D6x1000`, `| minute`) | read as the dice/number it has to be |
| 21, 54, 143, 150, 155, 187 | `[.Q.` / `1.Q.` for I.Q.; `8.D.C.` for S.D.C. | cosmetic |
| **74** | two columns merged: Spectral Hunter Related list interleaved with Secondary and Money | render printed 74 |
| **82** | BRL-3 stat lines sit before its heading | render printed 82 |
| 57 | Inti-20 triple-pulse damage split below Cost | render printed 57 |
| 66, 87, 89, 92 | art noise inside M.D.C.-by-location tables (Slinger, Ghost Wasp, Death Cyclops, Great Cyclops) | render before transcribing any M.D.C. |
| 105 | trooper helmet M.D.C. line garbled; a minimum P.P. reads `Lis` | render printed 105 |
| 134 | Blood Rider Related list has no Physical / Pilot / Pilot Related lines | render printed 134 — OCR drop or the book |
| 149 | Falconoid I.S.P. reads `2D6xX10` | render |
| **192** | Experience Tables interleaved; one misread digit | **transcribed from a 120 dpi render** — see below |

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-5** | *Contents* and *Quick Find Table* | page of every section, class, spell group, gear item and vehicle. The OCR of these pages garbles page numbers; the render is clean |
| **31** | *Common Line Drawings* list | the 19 common drawings with P.P.E. costs; **no levels anywhere** |
| **190** | *Alphabetical List of Blue Flame Spells* | ten names with P.P.E. The level is printed once, in each description heading (190-191). Two authorities for P.P.E.; see the catalog diff |
| **192** | *Experience Point Tables* | fifteen ladders covering 36 classes |

### The XP ladders (printed 192, read off the render)

| ladder | classes |
|---|---|
| True Inca | True Inca R.C.C. |
| Gaucho | Gaucho O.C.C. |
| Ancient - Inca Undead | Ancient R.C.C. (NPC-only) |
| Larhold Shaman, Pucara Mind Mage, Sun Priest | three classes |
| Destroyer 'Borg, Inca Warrior | two |
| Arkhon, Amaki Stone Man | two |
| Men-Rall "Techmaster", Nazcan Line Maker | two |
| Larhold Human Renegade, Plains 'Borg, ESP Specialist, Megaversal Trooper | four |
| Master Blood-Rider, Achilles Serpentoid | two |
| Larhold Barbarian, Neo-Human, Equinoid | three |
| Fallam, Ojahee, Pucara Red Giant | three |
| Duelist, Fallam Battlemaster, Rune Warrior | three |
| Ojahee 'Borg, Ultra-Crazy, Arkhon Spectral Hunter | three |
| Condoroid, Falconoid, Achilles Mutant Capybara | three |
| Gizmoteer, Blood Rider, Blood Lizard | three |

**Every class in the book has a ladder; none borrows one.** Three ink quirks on
the page, to carry as they are and note: the Destroyer/Inca Warrior level 10
prints `98.001` (a period); the Gizmoteer ladder's level 11 starts at 137,000,
the same figure level 10 ends on; the Ojahee 'Borg ladder's level 14 starts at
400,000, where level 13 ends.

## Inventory

Counted by structure over all 193 cached pages, by four slice readers (1-51,
50-104, 103-153, 151-193) and then collated.

| section | printed | what is there |
|---|---|---|
| Front matter | 1-8 | contents 4-5, map 7, introduction 8 |
| Empire of the Sun | 9-19 | lore; no stat blocks |
| Classes of the Empire | 20-30 | **True Inca R.C.C.** (20-23), **Inca Warrior** (23-24), **Inca Sun-Priest** (24-26), **Nazca Line Maker** (26-28), **Rune Warrior** (28-30) O.C.C.s. A one-paragraph note on Inca soldiers (20) has no block |
| Nazcan Line Magic | 30-40 | rules (30-31), **19 common drawings** (31-37), **6 secret drawings** (37-38), 6 plateau constructs (39-40) |
| Pantheon of the Sun | 40-48 | **Viracocha** (41-42), **Inti** (42-43), **Pachamama** (44-45), **Illapa** (45-46), **Manco Capac** a godling (46-47); the Heroes of the Sun (47-48) is a list, no blocks |
| Forces of Darkness | 48-56 | **Ancient R.C.C.** (48-50, NPC-only), **Yahuar Huacac** (50-52), **Pucara Red Giant R.C.C.** (53-55), **Pucara Mind Mage O.C.C.** (55-56) |
| Weapons of the Empire | 56-66 | **4 small arms** (Inti-10, Inti-20, Illapa-1, Illapa-5), **2 body armors** (Gilded, Sinchi), **4 power armors** (Nazca, Armor of the Sun, Atahualpa, Solar Combat), **Slinger** light tank |
| The Arkhons | 67-79 | lore (Overlord Enno 70, prose only); **Arkhon R.C.C.** (71-73), **Spectral Hunter** (73-74), **ESP Specialist** (75-76) O.C.C.s, **Fallam R.C.C.** (76-78), **Fallam Battlemaster O.C.C.** (77-79) |
| Arkhon weapons and machines | 79-97 | E-clip rules (79); **9 weapons** (80-83); **Arkhon Body Armor** (83-84); **Stormwind** exoskeleton, **Ghost Wasp**, **Death Cyclops** power armor, **Great Cyclops** robot (84-93); **Porcupine T-10** tank, **Evil Eye** APC, **Spikefish** fighter (93-97) |
| Megaversal Legion | 98-121 | lore, the Dakir (100, prose); **Megaversal Trooper (Human)** O.C.C. (104-106), **Ojahee R.C.C.** with a **Megaversal Trooper (Ojahee)** skill block (106-107), **Destroyer 'Borg** (107-109), **Ojahee 'Borg** (109-111), **Men-Rall "Tech Master" R.C.C.** (111-112); **6 weapons** (113-115), **Mark I / Mark II** armor (115), **Counterstrike** power armor (116-117), **Neo-Abrams**, **Neo-Bradley**, **Neo-Apache** (117-121) |
| Silver River Republics | 122-138 | lore (Cordoba, Santiago); **Gaucho** (128-129), **Plains 'Borg** (129-131), **Ultra-Crazy** (131-133), **Blood Rider** (133-135), **Master Blood Rider** (135-137) O.C.C.s; **Blood Lizard R.C.C.** (137-138, optional PC) |
| Achilles Republic | 138-151 | lore; **Serpentoid** (141-142), **Mutant Capybara** (142-144), **Equinoid "Psi-Taur"** (144-146), **Condoroid** (146-148), **Falconoid** (148-149), **Achilles Neo-Human** (149-151) R.C.C.s |
| New Babylon | 152-159 | lore; **Amaki Stone-Man R.C.C.** (154-155), **Duelist** (155-157), **Gizmoteer** (157-159) — both headed R.C.C., skills labelled O.C.C. |
| Other Republics | 159-162 | lore; **languages** (162) |
| Weapons, armor, machines | 163-183 | **10 weapons** (163-166), **7 body armors** (166-168), **Mecha-Lizard**, **Toro "Minotaur"**, **Glitter Boy Number 7** power armor, **Mastodon** and **Galapagos** robots, **Puma** tank, **Hussar** APC (168-183) |
| The Larhold Barbarians | 183-190 | **Larhold Barbarian R.C.C.** (185-186), **Larhold Human Renegade O.C.C.** (186-187), **War Bison** (187-188, animal), **Larhold Shaman O.C.C.** (188-190) |
| Blue Flame Spells | 190-191 | **10 spells** |
| Experience Tables | 192 | the table above |

### Things this book has zero of, checked rather than assumed

- **Psionic powers: none defined as catalog powers.** Every class-specific
  ability (the Duelist's psi-sword and psi-field, the Gizmoteer's Modify
  Machines, the Achilles mutants' specials, the Blood Lizard's Psychic
  Tracking, the Pucara stone powers) is written inside its class block.
  Those are class abilities, not `psionic_powers` rows.
- **Mutant-animal BIO-E: none.** The six Achilles R.C.C.s use fixed abilities;
  `BIO-E` counts zero across 141-151.
- **Spells outside the two traditions: none.** The Sun-Priest, Line Maker,
  True Inca and Larhold Shaman name existing invocations by name.

## Classes

**36 class blocks; 35 playable, one NPC-only.** Proposed ids, checked against
production 2026-09-25 — **no collision**. `mind-mage` exists, so the Pucara
one takes a prefix.

| class | printed | ladder | proposed id | note |
|---|---|---|---|---|
| True Inca R.C.C. | 20-23 | True Inca | `true-inca` | demigod: supernatural body, four patron-deity variants each with its own spell/psionic list |
| Inca Warrior | 23-24 | Destroyer / Inca Warrior | `inca-warrior` | holy weapons at level 6 |
| Inca Sun-Priest | 24-26 | Shaman / Mind Mage / Sun Priest | `inca-sun-priest` | spell ladder, four god variants |
| Nazca Line Maker | 26-28 | Men-Rall / Line Maker | `nazca-line-maker` | 8 drawings at level 1, 2 a level; six named invocations may replace drawings (28) |
| Rune Warrior | 28-30 | Duelist / Battlemaster / Rune Warrior | `rune-warrior` | six skin patterns and a Pattern Staff are class abilities, not spells |
| Ancient R.C.C. | 48-50 | Ancient | — | **NPC-only** by the book (48); a creature row |
| Pucara Red Giant R.C.C. | 53-55 | Fallam / Ojahee / Red Giant | `pucara-red-giant` | master psionic, stone powers |
| Pucara Mind Mage | 55-56 | Shaman / Mind Mage / Sun Priest | `pucara-mind-mage` | super-psionics |
| Arkhon R.C.C. | 71-73 | Arkhon / Amaki | `arkhon` | S.D.C. body; humidity penalty |
| Arkhon Spectral Hunter | 73-74 | Ojahee 'Borg / Ultra-Crazy / Spectral Hunter | `arkhon-spectral-hunter` | full conversion |
| Arkhon ESP Specialist | 75-76 | Renegade / Plains 'Borg / ESP / Trooper | `arkhon-esp-specialist` | master psionic |
| Fallam R.C.C. | 76-78 | Fallam / Ojahee / Red Giant | `fallam` | minor M.D.C. being |
| Fallam Battlemaster | 77-79 | Duelist / Battlemaster / Rune Warrior | `fallam-battlemaster` | Fallam only; battle trance is prose |
| Megaversal Trooper (Human) | 104-106 | Renegade / Plains 'Borg / ESP / Trooper | `megaversal-trooper` | partial bionics |
| Ojahee R.C.C. + Trooper block | 106-107 | Fallam / Ojahee / Red Giant | `ojahee` | the racial block and its trooper skills in one class |
| Destroyer 'Borg | 107-109 | Destroyer / Inca Warrior | `destroyer-borg` | full conversion |
| Ojahee 'Borg | 109-111 | Ojahee 'Borg / Ultra-Crazy / Spectral Hunter | `ojahee-borg` | partial bionics on an Ojahee |
| Men-Rall "Tech Master" R.C.C. | 111-112 | Men-Rall / Line Maker | `men-rall` | no attribute requirements line |
| Gaucho | 128-129 | Gaucho | `gaucho` | |
| Plains 'Borg | 129-131 | Renegade / Plains 'Borg / ESP / Trooper | `plains-borg` | full conversion, picks 3 + 3 bionics |
| Ultra-Crazy (TW Crazy) | 131-133 | Ojahee 'Borg / Ultra-Crazy / Spectral Hunter | `ultra-crazy` | M.O.M. implants, insanities; the `crazy` class already names it as not extracted |
| Blood Rider | 133-135 | Gizmoteer / Blood Rider / Blood Lizard | `blood-rider` | mount link |
| Master Blood Rider | 135-137 | Master Blood-Rider / Serpentoid | `master-blood-rider` | heading says R.C.C., block says O.C.C. |
| Blood Lizard R.C.C. | 137-138 | Gizmoteer / Blood Rider / Blood Lizard | `blood-lizard` | optional PC; natural attacks, no Hand to Hand |
| Serpentoid | 141-142 | Master Blood-Rider / Serpentoid | `serpentoid` | |
| Mutant Capybara | 142-144 | Condoroid / Falconoid / Capybara | `mutant-capybara` | |
| Equinoid "Psi-Taur" | 144-146 | Barbarian / Neo-Human / Equinoid | `equinoid` | |
| Condoroid | 146-148 | Condoroid / Falconoid / Capybara | `condoroid` | |
| Falconoid | 148-149 | Condoroid / Falconoid / Capybara | `falconoid` | |
| Achilles Neo-Human | 149-151 | Barbarian / Neo-Human / Equinoid | `neo-human` | |
| Amaki Stone-Man R.C.C. | 154-155 | Arkhon / Amaki | `amaki-stone-man` | racial skill paragraph only; no Related/Secondary lists |
| Duelist | 155-157 | Duelist / Battlemaster / Rune Warrior | `duelist` | |
| Gizmoteer | 157-159 | Gizmoteer / Blood Rider / Blood Lizard | `gizmoteer` | psionic techno-wizardry is an ability |
| Larhold Barbarian R.C.C. | 185-186 | Barbarian / Neo-Human / Equinoid | `larhold-barbarian` | |
| Larhold Human Renegade | 186-187 | Renegade / Plains 'Borg / ESP / Trooper | `larhold-renegade` | |
| Larhold Shaman | 188-190 | Shaman / Mind Mage / Sun Priest | `larhold-shaman` | 3 Blue Flame spells + 5 from levels 1-2 |

## Catalog diff

Run against **production** (`--remote`) on 2026-09-25, names from the contents
and the slice readers. **Nothing in this book is in production.** The one
`crazy` class mentions the Ultra-Crazy as not extracted; no row cites the book.

| table | book entries | matched | missing | note |
|---|---|---|---|---|
| `spells` | 35 | 1 | 34 | the match is **`Close Rift`, the common invocation — a different spell** from the line drawing of that name. The drawings need a namespace |
| `gear` | 46 | 0 | 46 | every nearest candidate is an unrelated item |
| `vehicles` | 23 | 0 | 23 | nearest `Glitter Boy Side Kick` is a different suit |
| `notable_npcs` | 9 | 0 | 9 | — |
| `creatures` | 9 | 0 | 9 | — |
| `skills` | 7 | 1 | 6 | `W.P. Bola` exists. Missing: `Language: Quechua`, `Aymara`, `Creole`, `Arkhon`, `Larhold` (p.162; Spanish exists), `Art: Line Drawing`, `Riding: War Bison` |

**Two conventions this import would establish or lean on:**

- **Namespaced traditions.** Following `Biomancy: <Name>` in the
  `south-america` plan: `Nazca: <Name>` for the 25 drawings and
  `Blue Flame: <Name>` for the ten spells. `Pattern Armor` and `Power Symbol`
  also appear as Rune Warrior skin patterns at different costs (29-30); those
  stay class abilities.
- **Level-0 spells.** No drawing prints a level (31-38); other casters use
  them at half their own level. `ww`'s 37 prayers are the level-0 precedent.

**Two authorities disagree on one Blue Flame cost:** *Flamewings* is 15 P.P.E.
in the list (190) and 25 in its stat block (191). Settle it from the render at
import time and keep the loser in `variant_note`. The list also prints
*Burning Light of the Blue Flame* and *Fists*; the headings print *Burning
Light of Blue Flame* and *Fist*.

**`Art: Line Drawing`** is named in the Line Maker's skills at +30% (28) and is
never defined; `Art` exists. **`Riding: War Bison`** is defined in one line
(186) as the horsemanship base at +10%.

## Extraction plan

Proposed, one PR each, every data script applied `--remote` before its PR,
`catalog-diff --remote` re-run immediately before each script (§8), branches
named `south-america-2-*`:

1. **Skills** — five languages, and a decision on `Art: Line Drawing` and
   `Riding: War Bison`.
2. **Spells** — 25 `Nazca:` drawings at level 0, 10 `Blue Flame:` spells at
   their printed levels.
3. **Gear** — ~41 weapons and armors plus the class magic items (Holy Axe,
   Amulet of Protection, Holy Sun Sling, Pattern Staff, Energy Jar, True Inca
   club/spear/cloth armor). Render 57 and 82 first.
4. **Vehicles** — 23 power armors, robots and vehicles. Render 66, 85, 87, 89
   and 92 first.
5. **Classes, Empire** — True Inca, Inca Warrior, Sun-Priest, Line Maker, Rune
   Warrior, Pucara Red Giant, Pucara Mind Mage (7).
6. **Classes, Arkhon and Legion** — 5 Arkhon/Fallam, 5 Legion (10).
7. **Classes, Silver River and Achilles** — 12.
8. **Classes, New Babylon and Larhold** — 6.
9. **Notable NPCs and creatures** — five gods, Yahuar Huacac, the Ancient, the
   War Bison.

What is deliberately left, with the reason for each:

- **The six plateau constructs** (39-40) — giant fixed works activated by
  groups, not spells a character casts.
- **The Dakir and Overlord Enno** — prose, no stat blocks.
- **Class abilities** (skin patterns, psi-sword, stone powers, battle trance,
  mount link) — they go in their class, not in a catalog table.
- **The E-clip compatibility rule** (79) — prose.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-25 | — | cache built from a scan (193 pp, OCR 300 dpi), offset 0 verified by render, survey written, `south-america-2` registered in `books.json` |
| 2026-09-25 | [#1381](https://github.com/NateGrey0130/nates-workshop/pull/1381) | survey and `books.json` registration. MERGED. |
| 2026-09-25 | [#1385](https://github.com/NateGrey0130/nates-workshop/pull/1385) | 8 skills: `Language:` Quechua, Aymara, Creole, Arkhon, Larhold (p.162) and Amaki (p.155); `Art: Line Drawing` (p.28, never defined in the book, filed at Art's base); `Riding: War Bison` (p.186, Horsemanship +10). The six languages also get Heroes Unlimited's 55/5 row in `skill_system_bases`, which a clean build's HU sweep would add and production's never did; `heroes-unlimited-core`'s pin moves 88 -> 94 and regression's untagged-skill pin 79 -> 85. `~002-` re-tags the two Rifts-only skills after the scripts that clear `systems`. Applied `--remote` before the PR. |
| 2026-09-25 | [#1390](https://github.com/NateGrey0130/nates-workshop/pull/1390) | 35 spells: 25 `Nazca:` line drawings at level 0 (p.31-38, tradition `nazca`, Time to Draw as casting_time) and 10 `Blue Flame:` spells at their printed levels (p.190-191, tradition `blue-flame`). Names and costs follow the p.190 list; Flamewings keeps the list's 15 with the entry's 25 in variant_note. `Nazca: Close Rift` is NOT linked to the invocation (same-spell-lib). book-reconcile 35/35. Applied `--remote` before the PR. |
| 2026-09-25 | [#1392](https://github.com/NateGrey0130/nates-workshop/pull/1392) | 60 gear rows: 32 weapons, 15 armors, 12 magic items, 1 gear (the Larhold demon-mask) - Empire (23-35, 56-58), Ancient and Pucara (50, 55), Arkhon (79-84), Legion (113-115, cost NULL: not for sale), Silver River (163-168), Larhold (186-190). book-reconcile agreed with all 54 extracted rows and found the six Ancient/Pucara items, added by hand. Applied `--remote` before the PR. |
| 2026-09-25 | [#1394](https://github.com/NateGrey0130/nates-workshop/pull/1394) | 23 vehicles (11 power armor, 9 vehicles, 3 robots) with 158 M.D.C. locations and 122 weapon-system entries: Empire (59-67), Arkhon (84-97), Legion (116-121), Silver River (168-183). Armor of the Sun has no main body (M.D.C. by the wearer's M.E.). book-reconcile checked all 23 and found the three Legion "Sensors, etc." entries the OCR had unnumbered; added. Applied `--remote` before the PR. |
| 2026-09-25 | [#1399](https://github.com/NateGrey0130/nates-workshop/pull/1399) | 7 classes: True Inca R.C.C. (20-23; the four patron gods are a choose-1 of abilities, each carrying its own magic and psionics), Inca Warrior (23-24), Inca Sun-Priest (24-26; god choice carries the elemental spell lists), Nazca Line Maker (26-28; picks from named lists, the six Secret drawings from level 6), Rune Warrior (28-30), Pucara Red Giant R.C.C. (52-55), Pucara Mind Mage (55-56, Red Giant only). Drafted and checked with class-check --remote, no stubs. Applied `--remote` before the PR. |
| 2026-09-25 | [#1402](https://github.com/NateGrey0130/nates-workshop/pull/1402) | 10 classes: Arkhon R.C.C. (71-73), Arkhon Spectral Hunter (73-74) and ESP Specialist (75-76), Fallam R.C.C. (76-78) and Fallam Battlemaster (77-79); Megaversal Trooper (104-106), Ojahee R.C.C. with its trooper skill block as one class (106-107), Destroyer 'Borg (107-109), Ojahee 'Borg (109-111, supersedes_race), Men-Rall (111-112). The four single-race O.C.C.s join regression's RACE_OWN_TRAINING. Applied `--remote` before the PR. |
| 2026-09-25 | Silver River/Achilles classes PR | 12 classes: Gaucho (128-129), Plains 'Borg (129-131), Ultra-Crazy (131-133; insanities are prose by Nate's call, the book points at the older Crazy), Blood Rider (133-135; its Related list omits Physical/Pilot as printed, render-confirmed), Master Blood Rider (135-137, an O.C.C. despite its R.C.C. heading), Blood Lizard R.C.C. (137-138, optional PC); the Achilles mutants Serpentoid, Mutant Capybara, Equinoid, Condoroid, Falconoid and Neo-Human (141-151). Applied `--remote` before the PR. |
