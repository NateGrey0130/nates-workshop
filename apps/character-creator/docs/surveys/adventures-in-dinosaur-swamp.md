# Rifts World Book 27: Adventures in Dinosaur Swamp — survey

**Status:** `imported` — gear, the Lazlo Model Behemoth, all 19 creatures, both comparisons (New West, Horune) and the book's five full NPC stat blocks shipped; the Quick Stats and level-only people are left under D21. (2026-10-20)

**Rows citing this book:** gear 27, vehicles 1, notable_npcs 5, creatures 19

Slug `adventures-in-dinosaur-swamp`. Cached 2026-10-05 from
`Rifts- World Book 27 Adventures in Dinosaur Swamp.pdf`, 162 PDF pages,
**scan (no text layer)**, OCR at 300 dpi, psm 3. Median 5,596 chars/page.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio in the cached page:

| cache page | folio printed on it |
|---|---|
| `p027` | 26 |
| `p050` | 49 |
| `p075` | 74 |
| `p129` | 128 |
| `p130` | 129 |
| `p140` | 139 |
| `p150` | 149 |
| `p160` | 159 |
| `p161` | 160 |

One region, no `page_offset_exceptions`. **`printed_pages` is 160**, at cache
`p161`. `ocr-book.py` measured 128 and the registry outranks the manifest.
Cache `p129` (printed 128) holds its folio and no other text. Cache `p162`
is an unnumbered catalogue page. Cache `p005`-`p006` hold the Contents and
the Quick Find (printed 4-5).

## OCR quality

Stat-block labels survived (`Alignment:`, `R.C.C. Skills:`,
`M.D.C. by Location:`, `Cost:`). The OCR of the Contents misreads some page
numbers, so it is good for names and order and the numbers below were
checked against where each entry's stat block sits. The cache holds curly
apostrophes and em-dashes; strip them before any SQL.

The companion survey, `dinosaur-swamp.md`, found that OCR sets side-by-side
table columns under the wrong headings. This book's one experience table
(the Horune Pirate, printed 150) and the two tables on 13-14 are read off a
render for the same reason.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | 4-5 | *Contents* | the order and printed page of every section and entry |
| **p006-p007** | 5-6 | *Quick Find* | a second reading of the pages; it also sorts the creatures by trait (aquatic, flying, human intelligence, magic, poison, psionics) |

The Quick Find's trait index is the one place the book states which
creatures cast magic or use psionics, and it is the check on each creature's
`magic` and `psionics` fields.

## Inventory

Counted by structure (stat-block markers per page, and the Contents) over
all 162 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Running adventures, more hazards | 7-12 | G.M. advice and rules |
| Starvation, bad water, dehydration, heat, hygiene | 13-17 | rules; penalty tables on 13 and 14 |
| Climate, hurricanes | 18-21 | rules |
| Wraith Brigades | 22-25 | **1 creature or class entry**, the Wraith Soldier (24-25), with its own skills and equipment lines |
| Creatures and Dinosaurs | 26-66 | **24 creature entries** |
| Native Americans, Camp Cherokee | 67-72 | lore; **3 NPC stat blocks** (71-72) |
| The Ocmulgee Mound Complex | 72-82 | places, a map (75), time travel (77) |
| The City of Char | 83-100 | ten headed personalities (83-91), four gangs (91-94), three figures outside town (95-100); `Alignment:` opens 23 blocks across these pages |
| The Second Neenok Expedition | 101-119 | a vehicle (the Lazlo Model Behemoth, 104-106), the A'rac R.C.C. (109-111), **3 headed NPCs** and other members (107-115), adventures (116-119) |
| Independent Freeholds | 120-126 | two families; `Alignment:` opens 8 blocks (122-125) |
| 101 Adventures, Hook Line and Sinker adventures | 127-145 | adventure seeds; one stat block (133) |
| Horune Pirates | 146-155 | lore, the Horune Pirate R.C.C. (149-150), weapons and vehicles (150-155) |
| New Eco-Wizardry Constructs | 156-157 | **8 items** |
| Other Equipment | 158-160 | the NG Command and Control Shelter (158) and a Northern Gun clothing line with armor plates (159-160) |

`Alignment:` opens a line on 55 cached pages. **The NPC figures above count
markers, not people**: a typical gang member and a named leader each carry
one. The people are counted at extraction.

### Spells: zero

`P.P.E.:` hits are creature and NPC pools and the mound complex's ley line
figures (74-82). No spell description is printed.

### Psionic powers: zero

`I.S.P.:` opens a line on nine pages, all pools.

### Skills: zero

`Base Skill:` appears once, inside the Wraith Soldier entry (25).

## Classes

| entry | printed | catalog today |
|---|---|---|
| A'rac R.C.C. | 109-111 | **held**: class `arac` and the creature row, citing D-Bees of North America p.25-27, the later book |
| Horune Pirate R.C.C. | 149-150 | **held**: class `horune-pirate`, and a creature row citing Underseas p.164-165 |
| Ship Dreamer Horune | 148 | not held as a class; no class markers on that page, so it reads as lore |
| Wraith Soldier | 24-25 | not held; whether it is playable is not settled by its markers |

## Catalog diff

Run against **production** (`--remote`) on 2026-10-05 with
`scripts/catalog-diff.mjs`. No row in any table cites this book.

### creatures: 26 entries, 7 held, 19 missing, 0 false gaps

Seven are held from **New West**: Devil Unicorn (p.140-141), Duckbilled
Honker (p.141-143), Leatherwing (p.148-149), Panthera-Tereon (p.155-156),
Tiger Claw Raptor (p.162-163), Tri-Tops (p.164-166) and Tyrannosaurus Rex
(p.166-167). **All seven were compared** with the held rows (2026-10-20,
`~256`), and every one changed, because this printing states figures New
West does not: the Devil Unicorn gains +1 on Perception Rolls; the
Duckbilled Honker's speed is 3D6+35 (New West 34+3D6); the Leatherwing's
Wing Membrane is 38 (New West 130), its Main Body adds the P.E. attribute
number and its alignment is anarchist or miscreant; the Panthera-Tereon
adds P.E. to its S.D.C.-world Hit Points; the Tiger Claw Raptor gains I.Q.
dice, M.D.C. by location, P.E. in its S.D.C., wider Horror Factor bands,
85% blood-scent tracking, female attacks and damage and +2 on Perception;
the Tri-Tops gains I.Q. 1D4+4, P.B. 2D6+6 (New West 3D6), Supernatural
strength and a knockdown roll on its ram; the Tyrannosaurus Rex has no
Horror Factor (New West 18) and five attacks (New West four). All seven
take this book's habitat line, and several its enemies or allies line.
`source_book` stays New West; each description records the old figures
with both books' pages.

Missing: Wraith Soldier, Alien Rex, Carnosuchid, Devil Eel, Devilsaurus,
Frilled Swamp Runner, Giant Hunter Turtle, Giant Petal Turtle, Giant Swamp
Turtle, Gruesome Tarbid, Lepidosaur, Raptor King, Razorback Rhinoceros,
Razormouth Frog, Saurian Terror, Spiny Creeper, Titan Raptor, Tree Prowler,
and the Quee-la (133, inside an adventure seed). **All 19 have shipped**
since this diff, in the three `creatures-a/b/c` scripts (plan step 3).

The held **Razorback** and **Spiny Ravager** are different animals.

### Horune weapons and vehicles: all held

| the book prints (150-155) | the catalog holds, from Underseas |
|---|---|
| Horune Harpoon Gun, Sonic Rifle, Energy Trident | gear, p.166 |
| Horune Sea-Horse | Horune Sea-Horse Sled & Speeder, p.167 |
| Horune Dolphin Combat Drone | p.167-168 |
| Horune Land Shark Drone | p.169-170 |
| Horune Dream Ship | p.170-171 |
| Horune Strike Ships | p.172 |

The section is a reprint. **Compared (ruling D23), and `~257` records
the differences on the held rows**: all eight, with their 27 weapon and
37 location rows, read line by line against production's rows and
Underseas's page cache (printed 166-172), every differing figure read off
a render. This printing wins where it states a different figure: the
Speeder's and Dream Ship's 77.7 knots and the Strike Ships' 103.6; the
Dolphin Drone's Hip Lasers at 15 each; the Land Shark's plasma double
blast and 6 M.D. elbow blades; the Dream Ship's crew line, turret rate,
2D4x10 lasers and a dozen to 100 drones; the Strike Ships' single-blast
plasma turrets, 4D6 lasers, 2D4x10 mini-missiles and 3D6+2 drones; the
harpoon gun's makers, the sonic rifle's payload and price line, the
trident's sources and the Sea-Horse's Horune-only line. Both ships'
missile dice are counts in both printings and move from damage to
payload. Not taken: the Fireball Bite's 914 m, which its own 300 feet
contradicts. Not compared: lines the held rows never carried (the
drones' attacks and combat bonuses, the metric conversions).
`source_book` stays Underseas.

### vehicles: 1 missing

The Lazlo Model Behemoth (104-106), with M.D.C. by location and a crew line.

### gear: 8 Eco-Wizardry items, the shelter and the clothing line, none held

EW Waterskin, EW Bandages, EW Limb Cast, EW Messenger (156); EW Horror
Armor, EW Armored Shield, EW Cradle of Life, EW Spitfire Leaper Cowl (157);
the NG Command and Control Shelter (158); Northern Gun jumpsuit, jacket,
pants, boots and gloves, each in more than one protection grade (159-160).

### notable_npcs: 17 headed names checked, 0 matched

Roma Coqu, Earl and Harley Pierce, Sidibald, Doctor Erin Ventrosa, Bearcat,
Father Nicholas, Sister Elizabeth, Lamont, Paradigm Kinnear, Archibald Stump
(83-91); Jonny Maraschoc (95), Silas Skinwalker (97); Deearn Neenok (107),
Obioma Aardan-Kwu (112), Alexander Washington Lee (113); Aaarmen Cartilage
(127). None is held. The Camp Cherokee personalities (71-72), the gang
blocks (91-94), the Arclight Brigade (99), the other expedition members
(114-115) and the two freehold families (122-125) were not diffed by name;
their names are read off renders first. The Char names on 83-91 print
Quick Stats blocks (alignment, attributes, disposition, description and
experience level, the shape D21 was ruled on), which fall under ruling D21
below.

## Extraction plan

1. **Gear** — the 8 Eco-Wizardry items, the shelter and the clothing line,
   from printed 156-160. Read off renders, it is 27 rows: the 8 EW
   constructs with EW Bandages as one row per printed healing level (4), two
   shelters (NG-ICSS and NG-CCS, 158; the survey's inventory named one), the
   Overland Harness and Frame Pack and the All-In-One Utility Belt (158), the
   Hunter Suit jumpsuit in four printed grades (159), the Hunter Utilities
   jacket in four and pants in two, and the Hunter Tracks boots and Hunter
   Paws gloves (all 159; 160 is a catalogue page). No other cached book prints any of them.
2. **Vehicle** — the Lazlo Model Behemoth, through `scripts/vessel-sql.mjs`.
3. **Creatures** — 19 rows, through `scripts/bestiary-sql.mjs`, with the
   Quick Find's trait index as the check on magic and psionics. **Done:**
   ten rows in `~253-adventures-in-dinosaur-swamp-creatures-a.sql`, five in
   `~254-adventures-in-dinosaur-swamp-creatures-b.sql` and four in
   `~255-adventures-in-dinosaur-swamp-creatures-c.sql`. The New West
   comparison is done (`~256`), and so is the Horune comparison (`~257`).
4. **Notable NPCs** — every stat block on printed 71-133, counted from
   renders. This is the largest batch in the book. **Done** for printed
   83-100: the two full stat blocks there, Jonny Maraschoc and Silas
   Skinwalker, in `~258-adventures-in-dinosaur-swamp-char.sql`; the 17 Quick
   Stats people are left under D21 and the gang and Brigade blocks under D20.
   **Done** for printed 71-82 and 101-133: the three full stat blocks there,
   Deearn Neenok, Obioma Aardan-kwu and Alexander Washington Lee, in
   `~259-adventures-in-dinosaur-swamp-camps.sql`; Camp Cherokee's three Quick
   Stats blocks (71-72), the expedition's four (114-115) and the freeholds'
   eight (122-125) are left under D21, and Aaarmen Cartilage (127) prints no
   block at all.

Each batch is extracted off renders by `book-extract-worker` and checked by
`book-reconcile` before its script is written.

**Nate's ruling D20 (2026-10-19)**, plan `open-items-2026-10-19`, settled
the three questions this survey left open before extraction:

- **The Wraith Soldier** (24-25) is **a creature row only**, not a class: the
  book presents it as a monster.
- **The gang and typical-member blocks** (91-94, 99) are **left**.
  Typical-member blocks became `notable_npcs` rows only where Nate asked for
  them (the Xiticix).
- **The survival rules** (13-17) are **left**.

Not taken: a different split.

**Nate's rulings of 2026-10-20 (D21, D23, D25)**, for the plan
`book-imports-2026-10-20` that ships steps 3 and 4.

- **D21**, standing across every book: a person named with only a level
  and no stat block never gets an NPC row. It applies to the Camp
  Cherokee blocks (71-72) and the two freehold families (122-125): a
  row only where a full stat block is printed. Not taken: one-line NPC
  rows.
- **D23**: the Horune weapons and vehicles reprinted on 150-155 are
  compared against the held Underseas rows, and a difference is
  recorded on the held row. No new rows. Not taken: rows citing this
  book.
- **D25**: this book's creatures ship after Dinosaur Swamp's creature PR,
  so the New West comparisons are done once. Not taken: the books in
  number order.

What is deliberately left, with the reason for each:

- **The A'rac and the Horune Pirate** — held from later or fuller printings.
- **The seven New West creatures** — held.
- **The Horune weapons and vehicles** — held from Underseas.
- **The Ocmulgee mounds, Char, the freeholds** as places — lore.
- **The 101 adventure seeds and the Hook, Line and Sinker adventures.**

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-05 | `pal/data/adventures-in-dinosaur-swamp-survey` | cache built (162 pp, OCR), `adventures-in-dinosaur-swamp` registered in `books.json`, this survey written, offset +1 verified. No data. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-gear` | **27 gear rows** (`~243`, through `scripts/rows-sql.mjs`), printed 156-159, read off renders and checked by `book-reconcile` (it caught eight rows citing 160 for 159, corrected before the apply): 11 Eco-Wizardry rows (`magic`, the Horror Armor and Armored Shield `armor`), 4 Northern Gun field items, 12 Hunter clothing rows by grade. The Horror Armor's M.D.C. is rolled (4D6+25), so `mdc` is empty and the description says so. The Cradle of Life prints no price. Ruling D20 recorded above. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-behemoth` | **1 vehicle**, the Lazlo Model Behemoth (`~247`, through `scripts/vessel-sql.mjs`), printed 104-106, read off renders and checked by `book-reconcile` (no number disagreed; three loose paraphrases tightened): 18 M.D.C. locations and 3 numbered weapon systems. `cost` holds the 155 million credit production price without the Observation Arm; `cost_note` carries the 182 million with it. The mini-station's light laser and sensor cluster, which the book prints in prose but neither numbers nor lists by location, are in the description. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-creatures-a` | **10 creatures** (`~253`, through `scripts/bestiary-sql.mjs`), printed 23-45, with 64 attacks: the Wraith Soldier, Alien Rex, Carnosuchid, Devil Eel, Devilsaurus, Frilled Swamp Runner and the Giant Hunter, Petal and Swamp Turtles and the Gruesome Tarbid, each checked against its page and the Quick Find trait index (cache p006-p007). Thirteen runs the script's copy check refused were reworded with every figure kept. The Wraith Soldier is a creature row (ruling D20) and carries the Wraith Brigade Entity's stats; its `playable` is the optional-race display flag. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-creatures-b` | **5 creatures** (`~254`, through `scripts/bestiary-sql.mjs`), printed 47-57, with 33 attacks: the Lepidosaur, Raptor King, Razorback Rhinoceros (slugged `razorback-rhinoceros`; the held `razorback` is Australia's), Razormouth Frog and Saurian Terror, every stat block read off renders and checked against the Quick Find trait index (magic: Lepidosaur, Raptor King, Razormouth Frog; psionics: Raptor King). The Quick Find also lists the Lepidosaur as poisonous, which its entry does not bear out; the row says so. Four runs the copy check refused were reworded with every figure kept. The Raptor King is a creature row, like the Wraith Soldier, with its four M.O.S. packages in `skills_note` and `playable` as the optional-race display flag. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-creatures-c` | **4 creatures** (`~255`, through `scripts/bestiary-sql.mjs`), with 13 attacks: the Spiny Creeper (57-59), Titan Raptor (60-62; printed 61 is a full-page painting), Tree Prowler (62-64; its Magic, Psionics, I.S.P. and Habitat lines sit at the top of 64) and the Quee-la (133-134, the 28% result of an adventure-seed table), every stat block read off renders and checked against the Quick Find trait index (psionics: Spiny Creeper, Tree Prowler; neither magic). The Quick Find lists the Quee-la only as Alien/D-Bee, though her block prints six psionic powers and Empathic Language Mastery; the row says so. She is one individual with fixed attributes and no pools printed, so her pools are empty. Five runs the copy check refused were reworded with every figure kept. All 19 creatures are in. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-new-west` | **No new rows.** The seven New West creatures this book reprints (35-37, 45-49, 59-60, 64, 66) compared line by line and attack by attack with production's rows and New West's text layer; every differing figure read off a render. All seven updated in place by `~256` (newest printing that states a figure wins, ruling of 2026-10-04), `source_book` unchanged, and five attack notes added (four Tiger Claw female figures, the Tri-Tops ram). Lines the held rows never carried (Value, an Allies of None) were not compared. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-horune` | **No new rows.** The Horune weapons and vehicles this book reprints (150-155) compared with production's three gear and five vehicle rows, their 27 weapon and 37 location rows, and Underseas's page cache (166-172); every differing figure read off a render. All eight updated in place by `~257` (ruling D23 and the newest-printing ruling of 2026-10-04), `source_book` unchanged: 3 gear rows, 5 vehicles, 10 weapon rows and 1 location row, each with both pages and the old figure. Three figures that read like misprints (6 M.D. elbow blades, 2D4x10 and 4D6 laser turrets) taken under the ruling, old figures kept; the Fireball Bite's 914 m not taken. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-char` | **2 notable NPCs** (`~258`, through `scripts/bestiary-sql.mjs`), with 6 attacks: Jonny Maraschoc (95-97) and Silas Skinwalker (97-99), the two full stat blocks of the City of Char (83-100), every figure read off renders. One run the copy check refused (Silas's tracking by smell) was reworded with every figure kept. Left: the 17 Char people printed with Quick Stats blocks only (sixteen on 83-91, and Randal Arclight on 100), under ruling D21 (a row only where a full stat block is printed); the gang blocks (91-94) and the Arclight Brigade's typical member (99), under D20; and the people the book names with no block at all. Applied `--remote` before the merge. |
| 2026-10-20 | `pal/data/adventures-in-dinosaur-swamp-camps` | **3 notable NPCs** (`~259`, through `scripts/bestiary-sql.mjs`), no attacks (none of the three prints a weapon's damage): Deearn Neenok (107-109), Obioma Aardan-kwu (112-113) and Alexander Washington Lee (113-114), the Second Neenok Expedition's three full stat blocks, every figure read off renders. Three runs the copy check refused were reworded with every figure kept. Left under D21 (a row only where a full stat block is printed): Camp Cherokee's White Chief, Red Chief and Atsil (71-72) with the seven Counselors and three Revolutionaries named by level only; the expedition's Hallsley, Montgomery, Smith and Esposito (114-115); the Heinland and Carter families' eight (122-125). Aaarmen Cartilage (127) is named in an adventure seed with no block. The Wilk's EVC-600 camera stays prose in Neenok's equipment. The plan is done; Status moved to `imported`. Applied `--remote` before the merge. |

### What remains

Nothing in the plan. What was left on purpose is listed above.
