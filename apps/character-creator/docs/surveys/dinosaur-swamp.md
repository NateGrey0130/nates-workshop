# Rifts World Book 26: Dinosaur Swamp — survey

**Status:** `surveyed` — survey and plan written; nothing imported yet. (2026-10-05)

**Rows citing this book:** none

Slug `dinosaur-swamp`. Cached 2026-10-05 from
`Rifts- World Book 26 Dinosaur Swamp.pdf`, 162 PDF pages, **scan (no text
layer)**, OCR at 300 dpi, psm 3. Median 5,646 chars/page.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio in the cached page:

| cache page | folio printed on it |
|---|---|
| `p014` | 13 |
| `p030` | 29 |
| `p050` | 49 |
| `p075` | 74 |
| `p100` | 99 |
| `p120` | 119 |
| `p140` | 139 |
| `p150` | 149 |
| `p153` | 152 |
| `p161` | 160 |

One region, no `page_offset_exceptions`. **`printed_pages` is 160**, at cache
`p161`. `ocr-book.py` measured 152 and the registry outranks the manifest.
Cache `p162` is an unnumbered catalogue page. Cache `p001`-`p004` are cover
and credits; `p005`-`p006` hold the Contents, the Quick Find and the Maps
list (printed 4-5).

## OCR quality

Stat-block labels survived: `Alignment:`, `Attribute Requirements:`,
`O.C.C. Skills:`, `M.D.C. by Location:` and `Cost:` are all found where the
Contents says an entry is. Three things did not survive and are read off a
render:

- **The Experience Tables (printed 74).** Four ladders are set side by side
  and the OCR runs them together on one line per level, with stray spaces
  inside figures. The upper levels of two ladders come out as separate runs
  below the rest.
- **The Contents page numbers.** Several are misread (a 7 as a 1, a 1 as a
  bracket), so the Contents is good for names and order, not for numbers.
- **Entry headings on the creature pages (printed 15-40)** mostly did not
  come through as their own lines; the creature names below are from the
  Contents, placed by where each `Alignment:` line sits.

The cache holds curly apostrophes and em-dashes; strip them before any SQL.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | 4-5 | *Contents* | the order and printed page of every section |
| **p006** | 5 | *Quick Find* and *Maps* | a second reading of the page of rules, armor, the special skills (ten are listed by name) and five maps |
| **p075** | 74 | *Experience Point Tables* | four ladders for eight classes, to level 15 |
| **p014-p015** | 13-14 | the New West dinosaur list | which dinosaurs already printed in New West live here, and what the book adds to them |

The Quick Find is the only place the special skills are listed together; in
the body each sits inside the class that owns it.

## Inventory

Counted by structure (stat-block markers per page, and the Contents) over
all 162 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Introduction, history, survivors, hazards, hunting | 7-12 | lore and hunting rules |
| New West dinosaurs | 13-14 | a list pointing back at New West, with additions |
| New Dinosaurs | 15-26 | **9 creatures** |
| Alien Dinosaurs and Beings | 27-36 | **7 creatures** |
| Man-Eating Plants | 37-40 | **3 creatures** |
| Diseases, Toxins and Medicines | 40-46 | 5 diseases (optional rules), 3 natural toxins, 2 natural medicines, 3 synthetic medicines; the priced ones are on 43-46 |
| New O.C.C.s | 47-59 | **5 O.C.C.s**, each with its own special skills; the Ghillie Suit (59) |
| Barbarians | 59-69 | guidelines for four barbarian versions of existing classes (61-62), **2 O.C.C.s** (Wild Knives Warrior, Eco-Wizard), **1 R.C.C.** (Mutant Barbarian), Home Spun Armor (63) |
| O.C.C.s from Rifts and the sourcebooks | 69-73 | which existing classes fit the region; lists, no stat blocks |
| Experience Tables | 74 | one page |
| Weapons of Dinosaur Swamp | 74-83 | 3 custom firearms, 5 barbarian weapons, 11 SteelTree entries (four of them price tables) |
| Magic Weapons and Items | 83-95 | **28 Eco-Wizard items** |
| Techno-Wizard Equipment | 96-99 | **10 items** |
| Necromancy Items | 99-101 | **7 entries**, by dinosaur body part |
| Vehicles | 101-105 | **8 entries**: bicycles, motorcycles, hovercycles, A.T.V.s, a buggy and two boats; four carry M.D.C. by location |
| The region | 106-135 | Florida, Georgia, the Carolinas; **2 group blocks** (Tunnel Goblins 112-113, Rat Men of Atlanta 121-122); **9 NPC stat blocks** (113, 122-132); the Fort Hawkins training program (130) |
| Dimensional Shifting | 136-142 | rules and tables for the region's dimensional weather |
| Communities | 143-160 | towns and their people; residents are named with a level in running prose, without stat blocks |

### Spells: zero

`P.P.E.:` opens a line on 26 pages and every hit is a creature or NPC pool, a
class's P.P.E. line or a device's activation cost. The Eco-Wizard works
through special abilities and made items (64-66, 83-95), not a spell list.

### Psionic powers: zero

`I.S.P.:` opens a line on one page, an NPC pool. The Mutant Barbarian's natural
psionics (68) select from existing powers.

## Classes

### Playable O.C.C.s and R.C.C. with a full entry (8)

| class | printed | ladder on p.74 |
|---|---|---|
| Swamp Stomper | 48-49 | fourth column, with the Naturalist and Wild Knives |
| Naturalist | 50-52 | fourth column |
| Pathfinder | 52-54 | third column, with the Dinosaur Hunter |
| Legacy Scout | 55-56 | first column, with the Mutant Barbarian |
| Dinosaur Hunter | 57-59 | third column |
| Wild Knives Warrior | 62-63 | fourth column; the table calls it Wild Knives Barbarian |
| Eco-Wizard | 64-66 | second column, alone |
| Mutant Barbarian R.C.C. | 66-69 | first column |

Each of the eight has an `Attribute Requirements:` line; the count comes from
that marker, and matches the Contents. The ladder groupings were read off a
render of printed 74, because the OCR sets the class names on the wrong
columns; the figures themselves are still to be transcribed from a render.

### Barbarian versions of existing classes (4) — printed 61-62

Barbarian Wilderness Scout, Barbarian Swamp Stomper, Barbarian Nurturer and
Barbarian Master Psychic are short guideline entries that modify another
class rather than restate one. They are candidates for `variants` on the
class each modifies, not for four new classes.

### Listed, not defined (printed 69-73)

Classes from the core book and other sourcebooks, grouped as men at arms,
scholars and adventurers, practitioners of magic and psychics, with notes on
how each fits the region. Nothing to import.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-05 with
`scripts/catalog-diff.mjs`. No row in any table cites this book.

### classes: 12 entries, 0 matched, 12 missing, 0 false gaps

None of the eight full classes is held. The catalog holds `Wilderness Scout`,
which the Barbarian Wilderness Scout modifies.

### creatures: 21 entries, 0 matched, 21 missing, 0 false gaps

Allosaurus, Ankylosaurus, Dilophosaurus, Pachycephalosaurus, Sarcosuchus,
Sauropod, Scampers, Spinosaurus, Stegosaurus (15-26); Azhure, Haunting Child,
Iron-Hoof, Panthera-Thrinax, Spitfire Leaper, Switchback, Trysia Faerie
(27-36); Lankton's Knot, Qink, Seep Fern (37-40); Tunnel Goblins (112-113);
Rat Men of Atlanta (121-122).

The held **Panthera-Tereon** is a different animal; this book describes the
Panthera-Thrinax as its smaller relative. The New West dinosaurs named on
13-14 were not diffed by name here; that list is compared against the held
New West rows at extraction.

### skills: 10 entries, 1 held, 9 missing

**Sign Language** is held. Missing: Cartography, Cross-Country Pacing,
Fashion Weapons & Tools, Lore: Dinosaurs, Lore: Swamp & Everglades, Land
Navigation: Regional, Stalking, Trail Blazing, Track Dinosaurs. The held
`Land Navigation` and `Tracking (people)` are different skills.

### gear: 74 entries, 2 held by name, 72 missing

**Vibro-Spear and Vibro-Axe** are held from Spirit West (p.203) and Warlords
of Russia (p.185). Compare the figures on printed 77 with the held rows at
extraction; a reprint is left.

The 72 are an **entry count, not a row count**. Four SteelTree entries
(tools, forged weapons, forged armor, clubs and staves, printed 78-81) are
tables with one line per item, and each line is a row.

### vehicles: 8 entries, 0 matched, 8 missing

Generic names (Motorcycle, Hovercycle, A.T.V.) will collide with other
books' rows unless the slug carries this book's maker or model. The A.T.V.
entry (103) names a Coalition model as its equal; check that row before
adding one.

### notable_npcs: 9 entries, 0 matched, 9 missing

| printed | who |
|---|---|
| 113 | the Tunnel Goblin leader |
| 122 | Hirgg |
| 123 | Lyxander Ekbanio |
| 124 | Sir Falcone Maviteyolucas |
| 125 | Oxrik |
| 126 | real name unknown; three aliases are printed |
| 128 | Cavor Porter |
| 131 | Pennent Larellen |
| 132 | Gran Anu |

Names are from the OCR and are taken from a render before a row is written.

## Extraction plan

Gear and skills ship before classes, because the class entries name this
book's items and special skills (the Madhaven lesson).

1. **Skills** — 9 rows, each read from the class that owns it (49-64).
2. **Gear** — the 72 entries from printed 43-46, 59, 63 and 74-101, with the
   four SteelTree tables expanded to one row per line.
3. **Vehicles** — 8 rows from printed 101-105, through
   `scripts/vessel-sql.mjs`.
4. **Creatures** — 21 rows, through `scripts/bestiary-sql.mjs`.
5. **Notable NPCs** — 9 rows.
6. **Classes** — 8 full classes, ladders off a render of printed 74.

Each batch is extracted off renders by `book-extract-worker` and checked by
`book-reconcile` before its script is written.

**For Nate to decide before extraction:**

- **The four barbarian versions** (61-62): `variants` on the classes they
  modify, which edits held classes, or left.
- **The five diseases** (41-43): optional rules with no price. Rows of some
  kind, or left.
- **The community residents** (143-160): named with a level in prose and no
  stat block. This is the standing one-line-NPC question; no rows until it is
  ruled on.
- **Dimensional Shifting** (136-142): G.M. tables; left unless asked for.

What is deliberately left, with the reason for each:

- **The classes listed on 69-73** — held or belonging to other books.
- **The New West dinosaurs** (13-14) — held from New West; anything this book
  adds to them is recorded against those rows at extraction, not as new rows.
- **Geography, ruins, forts and towns** — places and lore.
- **Hunting rules and hazards** (10-12) — rules text.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-05 | `pal/data/dinosaur-swamp-survey` | cache built (162 pp, OCR), `dinosaur-swamp` registered in `books.json`, this survey written, offset +1 verified. No data. |

### What remains

Everything in the plan. Nothing from this book has been imported.
