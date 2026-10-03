# Rifts World Book 30: D-Bees of North America — survey

**Status:** `imported` — 49 races and 3 occupations shipped; the held reprints and Aarden Tek and Pogtal (held under other names) are left on purpose. (2026-10-03)

**Rows citing this book:** classes 52

Slug `d-bees-of-north-america`. Cached 2026-10-03 from
`Rifts- World Book 30 D-Bees of North America.pdf`, 226 PDF pages, **scan (no
text layer)**, OCR at 300 dpi, psm 3. `--probe` read 0 characters on all 20
sampled pages.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

The book is a catalog of 81 D-Bee races, one entry each, printed
9-223. Every entry is a race stat block; there is no skill list, no spell or
psionic list and no priced gear chapter.

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

| cache page | folio printed on it | read from | offset |
|---|---|---|---|
| `p004` | 3 | render | +1 |
| `p005` | 4 | render | +1 |
| `p006` | 5 | render | +1 |
| `p225` | 224 | render | +1 |

`ocr-book.py` measured +1 over the whole cache and found the last folio, 224,
itself. One region. **`printed_pages` is 224**, a subscription advertisement;
cache `p226` is the back cover. `p001`-`p004` are cover and credits,
`p005`-`p006` the Contents and Quick Find.

## Cache health

A scan, so none of the three text-layer keys apply. Five cache pages are
near-empty and every one is a full-page art plate (p007, p068, p091, p097,
p132; printed 6, 67, 90, 96, 131), checked on a contact sheet; `p001` is the
cover. Stat-block labels survived the OCR (`Alignment`, `Attributes`,
`M.D.C.`, `Horror Factor`, `R.C.C. Skills`, `Weight` count cleanly per
entry). As in China 2, **every number is read off a render**: the OCR drops
level ordinals and swaps digits in dice.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005** | 4 | *Contents* | every entry's first page |
| **p005-p006** | 4-5 | *New D-Bees* | the 35 entries this book introduces; everything else in the Contents is a reprint or update of a race from another book |
| **p006** | 5 | *Quick Find* | a second index by role (warrior, explorer, magical, mutant...); it repeats every page number in the Contents |

**Each entry's tag line** (its heading) says whether it is playable. Every
tag line read in the cache says *Optional Player Character or NPC* (or *&* /
*and*); none says NPC-only. The handful whose tag line the OCR wrapped are
confirmed at extraction.

**There is no experience table.** The entries that say tell the player to
use the chosen O.C.C.'s table (printed 10, for one), which is the catalog's
rule for a race: a race that names no ladder stores none
(`class-import` reference, *xp_table*).

## Inventory

81 entries, printed 9-223, each one race. Counted from the
Contents, every entry confirmed by its stat block in the cache.

| entry | printed | status |
|---|---|---|
| Aarden Tek | 9 | reprint, held: `aardan-tek` (Canada), the book's other spelling - corrected 2026-10-03 |
| Adna Nomads | 11 | new to this book |
| Akysse Tribal Hunters | 13 | new to this book |
| Altara, Blind Warrior Women | 15 | reprint, held: `blind-warrior-women` (Atlantis) |
| Amana | 18 | new to this book |
| Amorph | 21 | reprint, held: `amorph` (Psyscape) |
| A'rac | 25 | reprint, **not held** - imported from here |
| Auto-G | 27 | reprint, **not held** - imported from here |
| Aviane | 31 | new to this book |
| Bayou Ursine | 33 | new to this book |
| Blucies | 35 | new to this book |
| Bruutasaur | 37 | reprint, **not held** - imported from here |
| Butter Trolls | 40 | new to this book |
| Cactus People | 41 | reprint, held: `cactus-people` (New West) |
| Centaur | 44 | reprint, held: `centaur` (Canada) |
| Chasseur Vert | 46 | new to this book |
| Crab Warriors | 48 | reprint, **not held** - imported from here |
| Cyber-Horsemen | 51 | reprint, held: `cyber-horsemen-of-ixion` (Canada) |
| Darkhound | 54 | reprint, held: `darkhound` (Psyscape) |
| Demon-Dragonmage | 58 | reprint, held: `demon-dragonmage` (Psyscape) |
| Deer Horn Tribesman | 61 | new to this book |
| Dewtani | 64 | new to this book |
| Dirari Ecto-Men | 66 | new to this book |
| D'norr Devilmen | 71 | reprint, **not held** - imported from here |
| Dramins | 73 | new to this book |
| Drizzit | 75 | new to this book |
| Faerie Bot D-Bee | 76 | reprint, held: `faerie-bot` (Canada) |
| Feni Nomads | 80 | new to this book |
| Fennodi | 83 | reprint, held: `fennodi` (New West) |
| Fingertooth Carpetbagger | 85 | new to this book |
| Floopers | 87 | reprint, **not held** - imported from here |
| Forest Warden | 90 | new to this book |
| Ganka | 93 | new to this book |
| Grackle Tooth | 96 | reprint, held: `grackle-tooth` (Canada) |
| Greot Hunter | 98 | reprint, held: `greot-hunter` (Canada) |
| Horune Pirates | 100 | reprint, held: `horune-pirate` (Underseas) |
| Idie Swamp Men | 103 | new to this book |
| Iktek Diggers | 106 | new to this book |
| Kraks | 109 | new to this book |
| Kremin Cyborg | 111 | reprint, held: `kremin-cyborg` (CWC) |
| Lanotaur Hunter | 115 | reprint, held: `lanotaur-hunter` (Psyscape) |
| Larmac | 118 | reprint, **not held** - imported from here |
| Loaks | 120 | new to this book |
| Loronoids | 124 | new to this book |
| Lyn-Srial | 127 | reprint, held: `lyn-srial` and two variants (New West) |
| Lyvorrk | 130 | reprint, **not held** - imported from here |
| Mastadonoid | 134 | reprint, held: `mastadonoid` (Canada) |
| M'Raghiile Tree Men | 135 | new to this book |
| Malvoren | 138 | new to this book |
| N'mbyr Gorilla Man | 143 | reprint, held: `nmbyr-gorilla-man` (CWC) |
| Noli Bushman | 144 | reprint, held: `noli-bushman` (Canada) |
| N'retas | 146 | new to this book |
| Nuhr Dwarves | 149 | reprint, **not held** - imported from here |
| Obsedai | 151 | new to this book |
| Phlebus | 154 | new to this book |
| Pogtal Giants | 156 | reprint, held: `pogtalian-dragon-slayer` (South America), the same race and stat block - corrected 2026-10-03 |
| Posluznik | 159 | new to this book |
| Power Leech | 161 | reprint, **not held** - imported from here |
| Psi-Goblins | 164 | reprint, held: `psi-goblin` (Psyscape) |
| Psi-X Aliens | 166 | reprint, held: `psi-x-alien` (Lone Star) |
| Quick-Flex Alien | 168 | reprint, held: `quick-flex-alien` (CWC) |
| Roane Pipers | 170 | new to this book |
| Sasquatch | 173 | reprint, held: `true-sasquatch`, `worldly-sasquatch` (Canada) |
| Septumbran Witch Wolves | 177 | new to this book |
| Shale Bogles | 179 | new to this book |
| Shapers | 182 | reprint, **not held** - imported from here |
| Shemarrian Warrior | 185 | reprint, **not held** - imported from here |
| Simvan Monster Riders | 188 | reprint, held: `simvan-monster-rider` (Lone Star) |
| Slurmph | 190 | new to this book |
| Spinne | 193 | new to this book |
| Squilbs | 198 | new to this book |
| Swamp-Sludger | 200 | reprint, **not held** - imported from here |
| Tirrvol Sword Fist | 201 | reprint, held: `tirrvol-sword-fist` (CWC) |
| Tokanii | 203 | reprint, held: `tokanii` (Lone Star) |
| Trimadore | 206 | reprint, held: `trimadore` (CWC) |
| Vanguard Brawler | 208 | reprint, held: `vanguard-brawler` (CWC) |
| Vernulians | 210 | reprint, **not held** - imported from here |
| Vintex Warriors | 213 | new to this book |
| Yeno | 215 | reprint, held: `yeno` (Canada) |
| Yhabbayar | 217 | reprint, held: `yhabbayar` (Psyscape) |
| Zenith Moon Warpers | 221 | reprint, held: `zenith-moon-warper` (Psyscape) |

## Catalog diff

Run against **production** (`--remote`) on 2026-10-03, by name sweep of
`imported_classes` and `creatures` for every entry (the sweep's raw matches
were hand-checked: *Amana* matched `elemental-shaman-air` on a substring,
*Shapers* matched `nautyll-koral-shaper`, *Vernulians* matched a China 2
class's text - all three false; *Power Leech* is held as a Psyscape creature
only, not as a class).

- **35 new races**: none held. All import.
- **30 reprints already held** under their original books' classes:
  not re-imported. Their original books' rows stand, as Japan's reprints of
  core material did (`japan` survey, *Already in the catalog*).
- **16 reprints not held**: their original books are not imported,
  so this book is the only source the catalog has. They import from here,
  citing this book.

### Corrected 2026-10-03: two more held, three occupations found

The name sweep missed two held reprints because they are held under other
names: Aarden Tek is `aardan-tek` (Canada; this book spells it Aardan in its
own tag line), and Pogtal Giants is `pogtalian-dragon-slayer` (South
America), the same race with the same attribute dice, M.D.C. and energy
aura. Neither is re-imported. So the unheld reprints are **14**, not 16.

Three entries also print a full **O.C.C.** of their own, which the
inventory did not count: the Idie Fishermen O.C.C. (printed 105-106), the
Iktektumik Hunter-Gatherer O.C.C. (108-109) and the Roane Musician O.C.C.
(172-173). All three import, as `idie-fisherman`,
`iktektumik-hunter-gatherer` and `roane-musician`.

**Experience tables:** the survey said no class stores one. Twenty-odd
entries do name another class's table ("use the Psi-Stalker experience
table"), and those copy the named class's stored ladder, by the class-import
rule (Nate, 2026-09-26). Only entries that point to the chosen O.C.C.'s
table, or name a class the catalog lacks, store none.

## Extraction plan

Every importable entry is a race class (`category: rcc`), one
`add-<id>-class.sql` each, drafted from renders by agents working from one
brief, as China 2's classes were.

1. **All 52 classes in one PR** - 35 new races, 14 unheld reprints and the
   3 occupations - drafted by nine agents from one shared brief. (Planned as
   three alphabetical batches; shipped as one because every draft was ready
   at once.)

Each batch checks `class-check --remote` `ready` with 0 stubs, and runs smoke
and regression, before its data is applied `--remote` and its PR opened. A
named item an entry stats (bio-armor, a racial weapon) becomes a `gear` row
in its batch's script rather than a stub.

**Defaults taken, by the precedents above, without a separate decision:**
held reprints stay as they are; unheld reprints cite this book; no class
stores an `xp_table`; a racial power the catalog has no row for is a
`special_abilities` entry; and an entry's level-gated abilities the class
format cannot state are prose citing `BOOK-INGEST-AUDIT.md` F116.

What is deliberately left:

- **The 30 held reprints** — see *Catalog diff*.
- **The introduction** (printed 7-8) — lore.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-03 | `pal/data/d-bees-of-north-america-survey` | cache built (226 pp, scan, OCR 300 dpi), offset +1 verified at four folios, `d-bees-of-north-america` registered in `books.json`, this survey. No rows. |
| 2026-10-03 | `pal/data/d-bees-of-north-america-classes` | 52 classes, one `add-<id>-class.sql` each: 35 new races, 14 unheld reprints and the Idie Fishermen, Iktektumik Hunter-Gatherer and Roane Musician O.C.C.s. Nine drafting agents from one brief; every class reads `ready` against production with 0 stubs, every number read off a render. Named experience tables copied from the named class. Applied `--remote` before the PR. |

