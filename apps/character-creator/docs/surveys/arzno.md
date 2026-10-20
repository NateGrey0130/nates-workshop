# Rifts World Book 28: Arzno - Vampire Incursion — survey

**Status:** `importing` — gear and vehicles imported; creatures, NPCs and the two classes next. (2026-10-20)

**Rows citing this book:** gear 22, vehicles 12

Slug `arzno`. Cached 2026-10-05 from
`Rifts- World Book 28 Arzno- Vampire Incursion.pdf`, 162 PDF pages, **scan
(no text layer)**, OCR at 300 dpi, psm 3. Median 5,267 chars/page.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio in the cached page:

| cache page | folio printed on it |
|---|---|
| `p020` | 19 |
| `p050` | 49 |
| `p075` | 74 |
| `p100` | 99 |
| `p125` | 124 |
| `p140` | 139 |
| `p147` | 146 |
| `p150` | 149 |
| `p155` | 154 |
| `p161` | 160 |

One region, no `page_offset_exceptions`. **`printed_pages` is 160**, at cache
`p161`. `ocr-book.py` measured 146 and the registry outranks the manifest.
Cache `p162` is an unnumbered catalogue page. Cache `p005`-`p006` hold the
Contents, the Maps list and the Quick Find (printed 4-5).

## OCR quality

Stat-block labels survived (`Alignment:`, `R.C.C. Skills:`,
`M.D.C. by Location:`, `Cost:`, `Real Name:`). The Contents' page numbers
are misread in places, so the numbers below were checked against where each
entry's stat block sits. Two Contents lines are unreadable in the OCR (one
creature heading on printed 24-25 and one item on printed 84); the names
used below for those come from the body. The cache holds curly apostrophes
and em-dashes; strip them before any SQL.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | 4-5 | *Contents* | the order and printed page of every section; **it stops at The Black Swords (147)** |
| **p006** | 5 | *Maps* | ten maps and their pages |
| **p006-p007** | 5-6 | *Quick Find* | a second reading of the pages of places, people and item groups |

There is no experience-table page. The Thumper is pointed at the Dog Boy
ladder (28), and the Blood Priest entry carries an *Experience Table* line
inside its own block (144); read that one off a render.

**The Contents does not list what is on printed 148-160.** Those pages hold
the stat blocks of the Black Swords, found by their `Real Name:` and
`Alignment:` lines.

## Inventory

Counted by structure (stat-block markers per page, and the Contents) over
all 162 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Regional overview, the Great Trade Road, places | 7-19 | lore and maps |
| The Waste | 20-30 | **4 creature entries**: the Waste Ghost (22-24), the Waste Banshee or Screamer (25-26), the Thumper (27-29) and the Waste Monkey (29-30) |
| The Arzno territory and city | 31-63 | places, shops, government and law; no stat blocks |
| The Arzno Mercenary Corps | 64-73 | organisation and tactics; **4 NPC stat blocks** on 69-73, two of them as quick stats |
| Techno-Wizard weapons and gear | 74-84 | **9 items** |
| Techno-Wizard body armor | 85-88 | **4 armors** (Light, Incursion, Exterminator, Ironwood) |
| TW Imitator power armor | 89-98 | series rules and the P.P.E. battery (89-90); **5 suits** |
| TW aircraft | 99-103 | **3 aircraft** |
| TW ground vehicles | 104-110 | **4 vehicles** |
| Vampires, Fort Tombstone, the lair | 111-121 | places and two maps |
| Vampires in Rifts, society, the army, the incursion | 122-132 | a short restatement of vampire rules, tactics, feeding stock and mind slaves; the castes on 131-132 |
| Xavier's vampires | 133-140 | **2 named NPCs** (Xavier Stuart 133-135, Cana the Blind 136) and **2 typical blocks** (secondary 137, wild 138-139) |
| The Blood Cult | 141-147 | the Blood Priest O.C.C. (142-144), **1 named NPC** (High Father Suthue, 145) |
| The Black Swords | 147-160 | **5 NPC stat blocks**, one per `Real Name:` line (149, 152, 154, 157, 159); the text calls the group five Cyber-Knights |

### Spells: zero

`P.P.E.:` hits are pools, device activation costs, and the Blood Priest's
magic powers (143), which are class abilities with their own cost lines
rather than catalog spells.

### Psionic powers and skills: zero

No `I.S.P.` cost block and no `Base Skill:` line anywhere in the book.

## Classes

| entry | printed | tag |
|---|---|---|
| Thumper | 27-29 | optional R.C.C.; uses the Dog Boy ladder; a note says to allow it sparingly |
| Waste Monkey | 29-30 | may be offered as a player character; the entry says it suits NPCs better |
| Blood Priest O.C.C. | 142-144 | **tagged as an NPC villain, not suggested for players**; it does carry attribute requirements and a skill list |

## Catalog diff

Run against **production** (`--remote`) on 2026-10-05 with
`scripts/catalog-diff.mjs`. No row in any table cites this book.

### classes: 3 entries, 0 matched, 3 missing, 0 false gaps

### creatures: 4 new entries, 0 matched

Waste Ghost, Waste Banshee, Thumper, Waste Monkey. The held **White Monkey**
and **Banshee** are other creatures.

**The catalog's three vampire rows are Nightbane's** (The Master Vampire, The
Secondary Vampire, Wild Vampires, Nightbane RPG p.179-183). This book's
secondary and wild vampire blocks (137-139) are Rifts stat blocks, and the
book restates Rifts vampire rules without printing a full Rifts vampire
entry. No Rifts vampire creature row is held.

### gear: 23 priced entries on printed 75-90, 22 rows, 1 held

**Corrected 2026-10-20** from the extraction off renders. The first list of
14 was short: the book also prints the TW Water Rifle, TW Water Cannon, TW
Wood Rail Gun, TW Flash-Bang Bombs, TW Climbing Claws (hand-held and bionic,
priced apart), TW Reading Glasses and the TW Tactical Team Targeting System,
and Ironwood Armor is a heading over two models (Mage, TWA-1000M, and Vampire
Hunter, TWA-1000H). "TW Security Scammer" is the OCR's reading of **TW
Security Scanner**; its wand and portal share one price line and are one row.

The two near relatives, compared against production on 2026-10-20:

| the book prints | the catalog holds | decided |
|---|---|---|
| TW Vampire Chaser Steam Grenades (79): 5D6 H.P. per melee round to vampires, a 20 ft (6.1 m) diameter cloud, 60 P.P.E. to make | `tw-vampire-chaser-steam-grenade`, Book of Magic p.329: 6D6, 10 ft radius | **held row stands, no second row.** Price, range, cloud size, duration and recharge agree; only the vampire damage die and the creation stats differ |
| TW Water Pistol (76), Water Rifle (76-77), Water Cannon (77-78) | Book of Magic p.330: plastic and metal pistols, water rifles, two cannons | **rows added.** The book calls these the Vampire Kingdoms weapons restated with full stats, but it prints its own prices, recharge costs and creation stats, and the cannon differs outright (3D4x10 at 600 ft against 3D6x10 at 300 ft). The name TW Water Cannon is held, so this one is `tw-water-cannon-arzno` |

Armor rows store the main body as `mdc`, with the other locations in the
description. Prices are the A.W.M. or Arzno figure, with the other tiers in
`cost_note`. The TW P.P.E. Battery (90) has no separate price and stores
`cost` NULL. The bionic climbing claws' 55,000 is the printed "ten times" the
hand-held price.

### vehicles: 12 entries, 0 matched, 12 missing, 12 rows

Five power armors (Jackrabbit, Lonewolf, Raging Bull, Thunderbird, Guardian
Angel), three aircraft (Grinning Gunship, Kamikaze Fighter, Whirlybird
Personal Helicopter) and four ground vehicles (Sandstorm Hover Craft, Cliff
Rider Personal ATV, Rover Dune Buggy, Sand Ranger Combat Truck). The held
`TW Zone Ranger ATV` is a different vehicle.

### notable_npcs: 10 names checked, 0 matched

Prince Onra Misvina (69) and Sgt. Samantha (73) of the Mercenary Corps;
Xavier Stuart (133), Cana the Blind (136); High Father Suthue (145); of the
Black Swords, Jude Acedelma II (149), Trey Risharde (154), Sir John Leona
(157) and a Cheyenne member whose name the OCR mangles (159); and Carlos
Vanderberg, the Bisbee master vampire the Quick Find places on 13. None is
held. The Black Sword whose real name is withheld (152) and the other
Mercenary Corps blocks on 71-73 were not diffed by name.

Names are from the OCR and are taken from a render before a row is written.

## Extraction plan

Gear and vehicles ship before NPCs, because the NPC equipment lines name
this book's items (the Madhaven lesson).

1. **Gear** — 22 rows from printed 75-90, the two near relatives decided
   after comparison (see the catalog diff).
2. **Vehicles** — 12 rows from printed 91-109 (the aircraft run 99-104;
   printed 110 is art), through `scripts/vessel-sql.mjs`. Each Imitator suit leans on the series rules of
   89-90; a row restates what it takes from there.
3. **Creatures** — 4 rows from printed 22-30, through
   `scripts/bestiary-sql.mjs`.
4. **Notable NPCs** — every stat block on printed 69-73, 133-139, 145 and
   148-160, counted from renders.
5. **Classes** — the Thumper and the Waste Monkey (D19, below).

Each batch is extracted off renders by `book-extract-worker` and checked by
`book-reconcile` before its script is written.

**Decided by Nate, ruling D19 (2026-10-19)**, in the open-items plan of
that date. Not taken: a different split.

- **The Thumper and the Waste Monkey**: **classes and creature rows both.**
  Optional player races are what the creator is for.
- **The Blood Priest**: **no class.** The book tags it as an NPC villain;
  High Father Suthue (145) is its NPC row.
- **The secondary and wild vampire blocks** (137-139): **left** until a Rifts
  vampire book is imported. Xavier Stuart and Cana the Blind are named NPCs
  and are not these blocks.

**Nate's rulings of 2026-10-20 (D21, D22, D25)**, for the plan
`book-imports-2026-10-20` that ships steps 3-5.

- **D21**, standing across every book: a person named with only a level
  and no stat block never gets an NPC row. Not taken: one-line NPC rows.
- **D22**: named people only. The typical-member and Mercenary Corps
  blocks on 71-73 are left, as D20 left Adventures' gang blocks. The
  Black Sword whose name is withheld (152) gets a row under its printed
  title if its stat block is full. Not taken: rows for the typical blocks.
- **D25**: this book runs beside Dinosaur Swamp, in its own tree, and
  waits on nothing. Not taken: the books in number order.

What is deliberately left, with the reason for each:

- **The vampire rules restated on 122-132** — a summary of rules printed in
  full elsewhere; nothing here is a row.
- **Arzno's shops, compounds and districts** (46-63) — places. Shop stock
  lists that only name items held from other books are not rows.
- **The Great Trade Road, the Clarkdale Confederacy, Fort Tombstone** —
  places and lore.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-05 | `pal/data/arzno-survey` | cache built (162 pp, OCR), `arzno` registered in `books.json`, this survey written, offset +1 verified. No data. |
| 2026-10-20 | `pal/data/arzno-gear-vehicles` | ruling D19 recorded; `~244-arzno-gear.sql` (22 gear rows, printed 75-90) and `~245-arzno-vehicles.sql` (5 Imitator power armors and 7 vehicles, printed 91-109, with their locations and weapons), checked by `book-reconcile` against renders, applied `--remote` before the PR. |

### What remains

Gear and vehicles are in. Next, each in its own PR and session: creatures
and NPCs (4 creatures and 13 named NPCs through `scripts/bestiary-sql.mjs`,
equipment mapped to this PR's gear slugs), then the Thumper and Waste Monkey
classes, then `drift-check --remote` and removing the book tree.
