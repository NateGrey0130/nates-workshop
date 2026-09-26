# Rifts World Book 2: Atlantis — survey

**Status:** `surveyed` — cached, registered and surveyed; the extraction plan below is agreed, tattoos first. (2026-09-26)

**Rows citing this book:** none

Slug `atlantis`. Cached 2026-09-26 from `Rifts- World Book 2 Atlantis.pdf`
(handed over from `Downloads`, filed beside the others in
`C:\Users\natha\Projects\workshop\books`), 161 PDF pages, **scan (no text
layer)** — `--probe` median 0 chars/page on all twenty samples. OCR at 300
dpi, psm 3, by `ocr-book.py`. Cat. No. 804, 158 printed pages.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's session registered it.

`page_offset: 0` — the cache page IS the printed folio, so printed F is
`pF.txt` and `pymupdf d[F-1]`. Checked by render, not only by the vote: the
credits page printed 3 is `d[2]`, the Contents printed 4 is `d[3]`.
`ocr-book.py` measured +0 over the whole book and read folio 158 at cache
`p158`.

**`printed_pages` is 158.** Cache `p159`-`p161` are advertisements and the back
cover.

## Cache health

A scan, so `welded_pages`, `corrupt_pages` and `substituted_digits` are not
computed; the damage is OCR's. Seen during the survey:

| pages | fault | remedy |
|---|---|---|
| 5 | the Quick Find's dot leaders garble about a third of the entry names (`Ationtean`, `Rute Maggie`, `Stone Magte`) | the page numbers survived; read names off the Contents (printed 4) or a render |
| 68 | the experience tables are set in columns and the Ancient Dragon and Atlantean Vagabond ladders interleave | render printed 68 before transcribing any ladder |
| 98 | glyph noise only (full-page art) | nothing to read |
| 142, 150, 151 | no stat text | art pages between vehicle entries |

## The book's authority tables

| page | table | states |
|---|---|---|
| **5** | *Quick Find Table* | which classes are player characters or optional ones, with a page for each; also indexes magic, bio-wizard and rune weapons |
| **68** | *Experience Tables* | the ladders this book prints, and which ladder every other optional class borrows |
| **4** | *Contents* | a clean second index for section ranges, and the fallback where the Quick Find's OCR is garbled |
| **91** | *Tattoo Index by Power Type* | every power tattoo with its activation P.P.E. and the image it is drawn as |

**The Quick Find is the more valuable of the two indexes**: it is the only
place the book says, in one list, which beings are playable. Each class entry
also carries its own tag — *optional player character*, *not available as a
player character*, *special NPC* — and the two agree for every class checked.

**Printed 68 settles every ladder.** It prints five in full — Stone Master,
Tattooed Men, Undead Slayers, Sunaj Assassin, T-Monster Men — plus the Ancient
Dragon and Atlantean Vagabond (Nomad). It then assigns the rest: Chiang-Ku,
Zembahk, Adarok and Metztla use the RUE dragon table; Overlord, Powerlord and
Slaver use the Sunaj table; the Conservator uses RUE's Borg table; Kittani and
Blind Warrior Women use the Cyber-Knight table. Classes with no ladder are
NPC-only by the book's own statement on that page.

**Tattoo activation costs are printed twice**: once in the index on printed
91 and again in each tattoo's own entry (printed 86-93). Reconcile them.

## Inventory

Counted by structure over all 161 cached pages (stat-block markers per page,
class and NPC tags, `P.P.E. to activate` lines), not by reading prose. A `~`
count is from headings and will be exact after extraction.

| section | printed pages | what is there |
|---|---|---|
| Erin Tarn's Atlantis, Demon Sea, ley line storms | 7-12 | setting and two random-encounter tables; no rows |
| True Atlanteans | 13-17 | **True Atlantean R.C.C.** (15-16), **Atlantean Nomad O.C.C.** (17) |
| Key places, Valley of Wonder | 19-38 | setting; **4 notable NPCs** with stat blocks (Azlum Asylum inmates on 30, Styphathal the dragon on 33) |
| Splugorth and minions | 39-68 | Splynncryth (39, special NPC); the average Splugorth, High Lord, Conservator, Overlord, Powerlord, Slaver (41-49); Blind Warrior Women (50-51); **3 Kittani R.C.C.s** (52-54); **5 Metztla** (54-60); Kreelong and Kreewarr Carapace (60-62); Sunaj and the **Sunaj Assassin O.C.C.** (63-67); Atlantean Alchemist (67, special NPC); Splugorth Witch (68) |
| Splugorth slave stock | 69-82 | Adarok, Erta, Eyes of Eylor, Hawrk-duhk, Hawrk-ka, Hawrk-ohl, Shaydor Spherian, Shaydor Intel, Zembahk |
| Tattoo magic | 83-92 | **~55 tattoos**: 2 simple-weapon, 6 magic-weapon, 21 animal, ~24 power; monster tattoos are a **three-tier costing rule** (by the monster's M.D.C.), not named entries |
| Tattooed Men | 93-98 | **Tattooed Man, T-Monster Man, Maxi-Man, Undead Slayer O.C.C.s** |
| Stone magic | 99-105 | Stone Master O.C.C. (99-100), stone powers (100-102), gem powers and prices (102-104), pyramid technology (104-105) |
| Bio-wizardry | 106-119 | transmutation and reconstruction options (107-110, ~20, cybernetics-shaped), Eylor eye grafts (110-111), **~10 microbes** (111-114), **~8 parasites** (114-117), **~8 symbiotes** (117-120) |
| Bio-wizard weapons | 120-125 | **~15**: Psi-Interrogator, Psionic Rod, Staffs of Pacification, Power, Eylor and All Seeing, Holographic Imager, Eylor eyes, floating eyes, Seeker-Hunter, Slave Barge, Helm of Omnipotence, symbiotic modifications; Overlord Power Armor (123) |
| Rune magic | 126-132 | **~15 rune weapons** in three grades (lesser 127, greater 128, greatest 129-131, including the Sword of Atlantis and Sword of Life); rune statues (132-133) |
| Dimensional Market | 133-137 | slave and creature prices; rule text |
| Kittani equipment | 137-138 | **~8**: K-1, K-4, K-30, KEP-Special, K-E4 weapons, K-1000 Spider Defense, Explorer and Centaur armor |
| Kittani power armor and robots | 139-151 | **~10**: Universal, Serpent, Equestrian, Manling power armor; ABSS-2, ABS-3, ABW-4 drones; Insecton Land Rover; Creax Armored Rover; Dragon Dreadnought |
| Other odds and ends | 152-158 | Kittani wrist blasters, plasma axe, plasma sword, energy lance (**already in the catalog from Triax**, printed 213-214); arrowheads; misc. bio-wizard weapons (jolt gun, mental incapacitator, plasma blaster and rifle, helmet laser, net gun); Splugorth bio-power armor and flying ships; 4 Kittani vehicles (hover jet, two skimmers, KM-700) |

### Categories this book adds ZERO of

- **Skills: none.** Every `new skill` hit in the cache (14 pages) is the
  boilerplate *All new skills start at level one proficiency* inside a class's
  related-skills line.
- **Spells in the RUE sense: none.** Its magic is tattoos, stone powers,
  bio-wizardry and rune weapons, each a system of its own. Stone powers are
  already stored as Stone Master abilities (Book of Magic import).
- **Psionic powers: none.** Classes select from RUE's lists.

## Classes

### Playable or optional (22 new) — pages from the Quick Find and each entry

| class | kind | pages | ladder (printed 68) |
|---|---|---|---|
| True Atlantean | R.C.C. | 15-16 | depends on O.C.C.; the race is carried by class variants, as `stone-master` already does |
| Atlantean Nomad (Vagabond) | O.C.C. | 17 | Atlantean Vagabond |
| Tattooed Man (typical T-Man) | O.C.C. | 93-94 | Tattooed Men |
| T-Monster Man | O.C.C. | 95 | T-Monster Men |
| Maxi-Man | O.C.C. | 95-97 | not on 68; read its entry |
| Undead Slayer | O.C.C. | 17, 97-98 | Undead Slayers |
| Sunaj Assassin | O.C.C. | 63-67 | Sunaj Assassin; the book discourages it as a PC but gives requirements |
| Splugorth Conservator | R.C.C. | 45-47 | RUE Borg |
| Splugorth Overlord | R.C.C. | 47-48 | Sunaj |
| Splugorth Powerlord | R.C.C. | 48-49 | Sunaj |
| Blind Warrior Women | R.C.C. | 50-51 | RUE Cyber-Knight |
| Kittani Warrior | R.C.C. | 52 | RUE Cyber-Knight |
| Kittani Field Mechanic/Scientist | R.C.C. | 53 | RUE Cyber-Knight |
| Kittani Espionage | R.C.C. | 53-54 | RUE Cyber-Knight |
| Murvoma Metztla | R.C.C. | 58-60 | RUE dragon |
| Adarok Adventurer | R.C.C. | 69-71 | RUE dragon |
| Erta | R.C.C. | 71-72 | not on 68; read its entry |
| Hawrk-duhk | R.C.C. | 74 | read its entry |
| Hawrk-ka | R.C.C. | 75 | read its entry |
| Hawrk-ohl | R.C.C. | 76-77 | read its entry |
| Shaydor Intel Stilt-People | R.C.C. | 79-81 | read its entry |
| Zembahk | R.C.C. | 82-83 | RUE dragon |

**No id collides** with a live class: the diff against production found no
class id containing `kittani`, `sunaj`, `hawrk`, `erta`, `adarok`, `zembahk`,
`metztla`, `tattoo`, `conservator`, `overlord`, `powerlord` or `blind`. Two
near names are different classes and must not be matched: `maxi-killer` is
Juicer Uprising's, and `atlantean-monster-hunter` is South America's.

### Already in the catalog from another book

| class | here | in the catalog from |
|---|---|---|
| Stone Master | 99-100 | `stone-master`, Book of Magic 223-228 (a reprint) |
| Chiang-Ku dragon | 30 | `chiang-ku-dragon`, Dragons & Gods |
| Shaydor Spherian | 77-79 | `shaydor-spherian`, South America |
| Gargoyles | 68 names them | Conversion Book |

Left as they are. Stone Master's ladder on printed 68 can be compared against
the stored one as a check, not a re-import.

### NPC-only, by the book's own tags

Splynncryth (39, special NPC), the average Splugorth (41, stated not
available), Splugorth High Lord (44-45, stated not available), Slaver (49,
stated not available), Murex, Volute and Murvolva Metztla and the Kreelong and
Kreewarr Carapace (54-62, each tagged not available), the Sunaj as a race
(63), the Atlantean Alchemist (67, stated not available), Eyes of Eylor (72,
not recommended). These go to `creatures` and `notable_npcs`, not classes.

**Splugorth Witch (68)** is tagged optional, but the book prints none of its
mechanics and points to the Conversion Book's witch. The catalog's `witch`
already covers that; leave it.

### A ladder this book owes another import

South America's **Atlantean Monster Hunter** (`atlantean-monster-hunter`) is
printed as using the Undead Slayer's ladder and was imported without one,
because this book was not cached (`south-america.md` → ladders). The
Undead Slayer ladder is on printed 68. Backfill it in the same PR as the
Undead Slayer.

## Catalog diff

Run against **production** (`--remote`) on 2026-09-26.

- **Rows citing this book: zero** across `imported_classes`, `skills`,
  `spells`, `psionic_powers`, `gear`, `vehicles`, `creatures` and
  `notable_npcs`.
- **Gear already present from other books**: Kittani Laser Wrist Blasters,
  Double Blade Plasma Axe, Plasma Sword and Energy Lance (Triax printed
  213-214), Kittani Energy Trident, Energy Net and Rocket Grenades (Underseas
  173-174), Kittani Class Two Combat Shield (Africa 141). The first four are
  reprints of printed 152; leave them on Triax. A generic `Lesser Rune Weapon`
  row cites *Estimate - no published price found*. Printed 127 is the
  published source; correct that row's citation in the rune weapon PR.
- **No tattoo rows exist anywhere.** Spirit West's three tattoo *fetishes* are
  gear and a different thing.

A `catalog-diff.mjs --remote` run per table precedes each extraction batch,
per §4; with zero rows citing the book, what it will catch is the reprints
above and anything another session ships in the meantime.

## Extraction plan

Phase 4 costs money; everything above was free. Proposed, one PR each, in
this order:

1. **Tattoos (~55) as `spells`, `tradition = 'tattoo'`**, printed 86-93. That
   follows South America 2's Nazca line magic (`tradition = 'nazca'`, 25
   rows): P.P.E. to activate, duration and effect fit the spell columns.
   Names are namespaced `Tattoo: <image>`. Monster tattoos are a costing
   rule and go in the Tattooed Man classes' prose, not rows. The classes
   need the tattoos to reference, so they ship first. **Needs Nate's word on
   the table**, below (answered: yes).
2. **Atlantean and T-Man classes (6)**: True Atlantean, Atlantean Nomad,
   Tattooed Man, T-Monster Man, Maxi-Man, Undead Slayer. Also backfill
   `atlantean-monster-hunter`'s ladder.
3. **Splugorth minion classes (8)**: Conservator, Overlord, Powerlord, Blind
   Warrior Women, three Kittani, Murvoma Metztla. Plus the Sunaj Assassin.
4. **Slave-stock classes (8)**: Adarok, Erta, Hawrk-duhk, Hawrk-ka, Hawrk-ohl,
   Shaydor Intel, Zembahk.
5. **Gear: Kittani equipment and misc. weapons** (printed 137-138, 152-154).
6. **Gear: bio-wizardry** — bio-wizard weapons and devices (120-125),
   microbes, parasites and symbiotes (111-120), as `category = 'magic'`.
7. **Gear: rune weapons** (127-131), plus the `Lesser Rune Weapon` citation fix.
8. **Vehicles: Kittani power armor, robots and vehicles** (139-158) into
   `vehicles` / `vehicle_weapons` / `vehicle_locations`, every M.D.C. figure
   read off a render.
9. **Creatures and notable NPCs**: the NPC-only minions and slave stock,
   rune statues, Eylor constructs; Splynncryth, Styphathal, the Azlum
   inmates, the Alchemist.

Batches 2-4 fan out to `book-extract-worker` per class group and go through
`book-reconcile` before any data script.

What is deliberately left, with the reason for each:

- **Bio-wizard transmutation and reconstruction** (107-110): augmentation
  options costed like cybernetics but with no class that installs them. Left
  unless Nate wants them as `cybernetics` gear.
- **Stone powers and gem powers** (100-104): already on `stone-master` as
  abilities.
- **Random encounter, insanity and slave-market price tables**: rules and
  prices by band, not rows.
- **Splugorth Witch**: no mechanics here.
- **Stone Master, Chiang-Ku, Shaydor Spherian**: already in from other books.

### Decisions, answered by Nate 2026-09-26

1. **Tattoos go in `spells` with `tradition = 'tattoo'`**, following Nazca,
   not `gear` (which would lose the P.P.E. column). Yes.
2. **The Conservator, Overlord and Powerlord (a rarity as PCs) and the Sunaj
   Assassin (discouraged) are imported**, since the book tags each optional.
   Yes.
3. **Bio-wizard microbes, parasites and symbiotes become `gear` rows.** Yes.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-26 | — | cache built (161 pp, scan, OCR 300 dpi), `atlantis` registered in `books.json`, survey written |

### What remains

The whole plan above. `source-coverage.mjs --remote` has no rows to report for
this book yet; paste it here after the first data PR.
