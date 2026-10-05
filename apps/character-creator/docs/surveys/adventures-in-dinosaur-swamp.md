# Rifts World Book 27: Adventures in Dinosaur Swamp — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. (2026-10-05)

**Rows citing this book:** none

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
(p.166-167). The entries here are compared with the held rows at extraction.

Missing: Wraith Soldier, Alien Rex, Carnosuchid, Devil Eel, Devilsaurus,
Frilled Swamp Runner, Giant Hunter Turtle, Giant Petal Turtle, Giant Swamp
Turtle, Gruesome Tarbid, Lepidosaur, Raptor King, Razorback Rhinoceros,
Razormouth Frog, Saurian Terror, Spiny Creeper, Titan Raptor, Tree Prowler,
and the Quee-la (133, inside an adventure seed).

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

The section is a reprint. It is compared with the held rows at extraction
and any difference recorded.

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
their names are read off renders first.

## Extraction plan

1. **Gear** — the 8 Eco-Wizardry items, the shelter and the clothing line,
   from printed 156-160.
2. **Vehicle** — the Lazlo Model Behemoth, through `scripts/vessel-sql.mjs`.
3. **Creatures** — 19 rows, through `scripts/bestiary-sql.mjs`, with the
   Quick Find's trait index as the check on magic and psionics.
4. **Notable NPCs** — every stat block on printed 71-133, counted from
   renders. This is the largest batch in the book.

Each batch is extracted off renders by `book-extract-worker` and checked by
`book-reconcile` before its script is written.

**For Nate to decide before extraction:**

- **The Wraith Soldier** (24-25): a creature row, a class, or both.
- **The gang and typical-member blocks** (91-94, 99): `notable_npcs` rows as
  the Xiticix typical soldiers were, or left.
- **The survival rules** (13-17): starvation, dehydration and heat penalties
  are rules tables; left unless asked for.

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

### What remains

Everything in the plan. Nothing from this book has been imported.
