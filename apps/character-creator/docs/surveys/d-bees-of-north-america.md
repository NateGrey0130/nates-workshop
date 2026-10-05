# Rifts World Book 30: D-Bees of North America — survey

**Status:** `imported` — 49 races and 3 occupations shipped, and the 34 classes this book reprints from older books now follow it (Ledger, 2026-10-04); the Lyn-Srial Cloudweaver, which it does not reprint, stays on New West. (2026-10-04)

**Rows citing this book:** classes 86, gear 46, creatures 52

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

### The held reprints compared with their held rows, 2026-10-03

The diff above matched the held reprints **by name only**. On 2026-10-03
every one was read against its production class, field by field, by three
`book-reconcile` passes that render a page before reporting a figure from it.
**The inventory marks 32 entries "reprint, held"**; the two "30"s in this
file are the count before the Aarden Tek and Pogtal correction.

**None of the 32 is identical to its held row.** The book's own Contents
calls each one "a reprint or update", and they are updates. Nothing below
was changed in the catalog when this table was written: which book a held
class follows was a decision per class, as it was for Canada's
Techno-Warrior. **Nate ruled on 2026-10-04** that the newest printing which
states a figure wins and that a class this book updates moves its
`source_book` here, with the original named in its notes. The Ledger records
each batch as it ships; a class it names no longer matches its row below.

Four kinds of difference recur, and most entries show all four:

- **A dice life span** where the held row has a range in prose (most
  entries; left out of the table below).
- **Perception, disarm, pull-punch or entangle bonuses** the held row lacks,
  and attacks per melee stated differently.
- **A different R.C.C. skill list**: this book prints bonuses where several
  held rows store absolute percentages, and adds or drops skills.
- **A different rule for occupations and experience**: this book lets a race
  take a wider or narrower list of O.C.C.s, and often says to use the chosen
  O.C.C.'s experience table where the held row stores a ladder of its own.

The figures that differ, by entry. "Printed" is this book's folio. A figure
marked (OCR) was not read off a render.

| entry, printed | held class | what this book prints differently |
|---|---|---|
| Aarden Tek, 9-10 | `aardan-tek` | Horror Factor 10; psionics as a human's, where the held row makes every one a Minor Psychic; any O.C.C.; equipment as per O.C.C.; +5% to four physical skills, +2 Perception |
| Altara, 15-17 | `blind-warrior-women` | eight attacks per melee, fixed (held: six); kick 2D6, leap kick 3D8, punch 2D4, body flip 2D4 (held: 1D8, 2D8, 1D6, none); +3 Perception, +3 disarm; Demon and Monster Lore +10% (held +5%); N.P.C. level 2D6+1 (held 2D4+2) |
| Amorph, 21-25 | `amorph` | Hit Points 2D6x10 + P.E., +1D6 per level (held 3D6x10 + P.E., +2D6); S.D.C. 1D6x10+8 (held 0); regeneration 2D6 per round in the physical realm (held 1D6); four attacks, +1 at 5, 9, 13; no Hand to Hand; no Pilot Related; four added skills |
| Cactus People, 41-43 | `cactus-people` | P.B. 2D6 (held 2D6+2); life fluid priced per half gallon; secondary skills at 1, 4, 8, 12 (held adds level 10); three brewing and food skills; +1 roll, +2 vs possession |
| Centaur, 44-45 | `centaur` | +1 attack only for a Man at Arms; +1 Perception; a rear power kick, 1D4x10 S.D.C.; no Glitter Boy or Robot Pilot; the chosen O.C.C.'s experience table (held: its own ladder) |
| Cyber-Horsemen, 51-54 | `cyber-horsemen-of-ixion` | Hit Points P.E. x2 (held P.E.); horse-body P.S. 2D6+28 (held 3D6+22); front legs 110 M.D.C. (held 100), and hands, arms, head and barding figures the held row lacks; no psionics; W.P. Pole Arm only; the chosen O.C.C.'s experience table |
| Darkhound, 54-57 | `darkhound` | four attacks, +1 at 2, 5, 8, 10, 13, 15 (held: +1 at 5 and 10); +3 Perception, +1 dodge; related and secondary skill schedules the held row lacks; money 4D6x10 in goods; "can use guns" where the held row says never |
| Demon-Dragonmage, 58-60 | `demon-dragonmage` | skill and ability ladders that run past level 15, to 30 (held stops at 12, 15 and 10); teleport 300 lbs; Communications +5% and Domestic none (held the reverse); money plus an equal amount in valuables |
| Faerie Bot, 76-79 | `faerie-bot` | size 1D4+8 inches, sphere 60-70 lbs; skills printed as bonuses over a longer list (held: flat 95% on five); related and secondary skills; the Techno-Wizard experience table (held: the Dragon ladder); sphere altitude 60,000 ft (held 30,000) |
| Fennodi, 83-85 | `fennodi` | three attacks at level 1, +1 every even level (held base 2); male starts with two Healing powers (held 3); W.P. Staff (held W.P. Blunt) |
| Grackle Tooth, 97-98 | `grackle-tooth` | Horror Factor 12 (OCR); +2 Perception; an O.C.C. rule by exclusion (held: a closed list of 17); cold penalties with figures. The entry's text starts on printed 97; printed 96 is an illustration |
| Greot Hunter, 98-100 | `greot-hunter` | Horror Factor 10; Cyber-Knight, Smuggler and Pirate added to its O.C.C.s (OCR); hold breath one minute per P.E. point |
| Horune Pirates, 100-103 | `horune-pirate` | M.D.C. 1D4x10 + P.E. (held has no P.E.); hold breath 12 minutes (held 3D4); Salvage and Wilderness Survival at +10%; +1 Perception at odd levels; a full equipment list (OCR) where the held row has none |
| Kremin Cyborg, 111-114 | `kremin-cyborg` | **a different class shape**: a partial or full cyborg that takes an O.C.C. and its experience table, with a civilian and a warrior stat line (held: its own R.C.C. with no O.C.C., warrior figures only); M.A. 3D6+2; warrior P.S. 2D6+24 and Spd 4D6+108 (OCR; held 1D6+22 and 132); energy fist 2D6, 3D6 or 4D6 |
| Lanotaur Hunter, 115-117 | `lanotaur-hunter` | P.B. 2D6+2 (held 2D6); **a full R.C.C. skill list of nineteen entries** where the held row says none is printed; related and secondary skills; +2 entangle; money 1D4x10,000 (OCR) |
| Lyn-Srial, 127-130 | `lyn-srial` | +3 attacks per melee (held 1); +1 Perception, +2 dodge in flight; Hand to Hand: Basic, fixed; W.P. Handguns added; a secondary pick at level 1 |
| Lyn-Srial Sky-Knight, 129-130 | `lyn-srial-sky-knight` | +4 attacks (held 2); M.D.C. bonus 2D6+6 (held 2D6); +4 Perception; five more known spells; the average Lyn-Srial's skills at different bonuses |
| Lyn-Srial Cloudweaver | `lyn-srial-cloudweaver` | **not printed here.** Printed 130 points to New West, so there is nothing to compare |
| Mastadonoid, 134-135 | `mastadonoid` | M.A. 2D6+3 (held 2D6); five R.C.C. skills where the held row has no skills block (OCR); heat and city penalties with figures (OCR) |
| N'mbyr Gorilla Man, 143-144 | `nmbyr-gorilla-man` | outburst P.S. 1D4+21, punch 2D6 and power punch 4D6 M.D. (held 19, 1D6, 2D6); Major Psychic, 1D4+2 Physical powers (held minor, six powers); **a Juicer is permitted**, where the held row says the book refuses it; +1 strike and parry, +4 damage |
| Noli Bushman, 144-146 | `noli-bushman` | I.S.P. M.E. x2 +1D6+1 per level (OCR), where the held row says the book prints none; Dowsing and Swimming added; Vagabond among its O.C.C.s |
| Pogtal Giants, 156-158 | `pogtalian-dragon-slayer` | P.P.E. 2D6x10; +2 Perception, +2 strike, +2 pull punch; secondary skills at 2, 4, 8, 12 where the held row says none; five related skills (held six) over a narrower list; **no Horror Factor is printed** (held 12). All OCR |
| Psi-Goblins, 164-165 | `psi-goblin` | I.S.P. 1D6x10+10 + M.E. (held 1D6x10 + M.E. x2); P.P.E. printed two ways, neither the held figure; spells cast for P.P.E., with no three-a-day limit; no P.B. in the attribute line |
| Psi-X Aliens, 166-168 | `psi-x-alien` | the same structure as the held row - a fixed list of four powers, then a percentile table - **but the table's rows list more powers** (Kineticist five more, Manipulator eight more, Intuitive four more, others two or three); alignment split 17/17 for Aberrant and Anarchist; money 3D6x100 |
| Quick-Flex Alien, 168-170 | `quick-flex-alien` | five R.C.C. skills where the held row has the Rogue list; +3 Perception, +1 strike, +2 parry, +3 automatic dodge; no Juicer or Crazy; the chosen O.C.C.'s experience table, equipment and money |
| Sasquatch, 173-175 | `true-sasquatch` | four attacks for a male, three for a female (held base 2); +2 Perception; "low-end Master Psychic" with an I.S.P. formula (held: none stored); the Merc Soldier experience table; skills printed as bonuses. This book prints the save vs disease as both +5 and +2 |
| Worldly Sasquatch, 176-177 | `worldly-sasquatch` | 1D4+1 extra skills (held 1D4+2); three category bonuses the held row lacks; second language +10% |
| Simvan Monster Riders, 188-190 | `simvan-monster-rider` | eight combat bonuses where the held row stores none; male and female skill lists that differ from the held ones; five related skills with bonuses, and secondary skills; money 1D4x100 plus trade goods (held: none); the Psi-Stalker experience table |
| Tirrvol Sword Fist, 201-203 | `tirrvol-sword-fist` | P.B. 1D6+1 (held 1D6); the sword fist adds 2D6 M.D. to P.S. damage; no Glitter Boy or Robot Pilot |
| Tokanii, 203-206 | `tokanii` | bite 2D4 M.D. (held 1D6); claws 2D6+2 M.D.; five combat bonuses; Barter and Recognize Weapon Quality; money 1D6x100 plus trade goods (held: none) |
| Trimadore, 206-208 | `trimadore` | **Major Psychic** (held minor); money 2D6x1,000 plus parts (held 2D4x1,000); five related skills, Mechanical +15% (held six, +10%); nine O.C.C.s named (held four) |
| Vanguard Brawler, 208-210 | `vanguard-brawler` | 90% illiterate (held 70%); four R.C.C. skills where the held row has the Thug list; physical O.C.C.s only; the chosen O.C.C.'s experience table |
| Yeno, 215-217 | `yeno` | Horror Factor 11; Hit Points and S.D.C. printed, with M.D.C. only from armour or the force field (held: an M.D.C. body); force field 2D4x10 + P.E., +3D6 per level (held 30, +10); "nearly any" O.C.C. (held four) |
| Yhabbayar, 217-220 | `yhabbayar` | P.B. 2D6+2 (held 2D6); one Physical and one Super power per level (held one pick from either); +1 Perception at odd levels; three added skills |
| Zenith Moon Warpers, 221-223 | `zenith-moon-warper` | **M.A. 1D6+20** (held 1D6+2); Appraise Goods +15%; related skills at 3, 5, 8, 10, 12 (held ends at 11) |

**What this comparison does not say.** It compared this book with the held
row, not with the book the held row cites. So a difference is one of two
things - this book revising the earlier one, or the held row having dropped
something its own book prints - and this table cannot tell them apart. The
Lanotaur skill list, the Noli I.S.P. line and the Simvan and Tokanii combat
bonuses are the likeliest to be the second kind, because the held row says
the book prints nothing. The experience tables this book names were not
checked against the held ladders.

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
| 2026-10-03 | `pal/data/d-bees-of-north-america-adna-armor` | `~073-adna-nomad-light-armor-choice.sql`: the Adna Nomad's generic light armour becomes the four-suit choice every other class has (the F115 correction). `repo-vs-live --offenders` found production holding the placeholder while the repo rebuilt the choice, the one differing field after #1651. Changes production, one row; a no-op on a clean build. No new rows. |
| 2026-10-03 | `pal/docs/retro-open-questions` | **The 32 held reprints compared with their held rows** (*The held reprints compared*), by three `book-reconcile` passes reading renders. No rows, and nothing changed in the catalog. None of the 32 is identical; the Lyn-Srial Cloudweaver is not printed in this book at all. |
| 2026-10-03 | `pal/data/retro-holdable-gaps` | **The Larmac's rare-psionics table becomes a banded pick-one group** (`~090`). Read off renders and checked again by `book-reconcile`; applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/d-bees-of-north-america-cwc-updates` | **The held reprints follow this book, batch 1 of 4: the six held from Coalition War Campaign** (`~095`): `nmbyr-gorilla-man` (printed 143-144), `tirrvol-sword-fist` (201-203), `quick-flex-alien` (168-170), `vanguard-brawler` (208-210), `trimadore` (206-208), `kremin-cyborg` (111-114). Each was read against BOTH books off renders, one agent per class, so a difference is known to be this book's revision and not a drop: about 110 changes, 100 of them revisions. `book-reconcile` checked every figure against renders again and found **no disagreement**. Each cites this book now and keeps Coalition War Campaign's figures in `extraction_notes`. Where this book restates a complete line (bonuses, R.C.C. skills, equipment, money) without an item, the item is gone and noted; where it is silent about a whole block, the block is kept. **Three keep the shape they had**: this book prints the Quick-Flex Alien, the Vanguard Brawler and the Kremin as races that take an O.C.C. with the O.C.C.'s table, equipment and money, and the catalog holds each as an R.C.C. with its own program and ladder; that conversion is left for Nate. Production held no saved character on any of the six. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/d-bees-of-north-america-psyscape-updates` | **The held reprints follow this book, batch 2 of 4: the seven held from Psyscape** (`~096`): `darkhound` (printed 54-58), `amorph` (21-25), `demon-dragonmage` (58-61), `lanotaur-hunter` (115-117), `psi-goblin` (164-166), `yhabbayar` (217-220), `zenith-moon-warper` (221-223). Read against both books off renders, one agent per class, about 145 changes of which all but ten are this book's revisions; `book-reconcile` found **no wrong figure**. None changes shape, and no experience ladder moves: this book prints the same ladder or points to a table that is the Psyscape column figure for figure. The Lanotaur's nineteen-entry skill list is a revision, not a drop: Psyscape prints none. **Readings the page does not settle, stated in each class's notes:** the Amorph's save vs Horror Factor printed as a range (+1 to +6); the Psi-Goblin's P.P.E. printed two ways on one page, and no P.B. die (Psyscape's kept); the Yhabbayar's three secondary skills at each of five levels; the Darkhound's two blades. Production held no saved character on any of the seven. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/d-bees-of-north-america-canada-updates` | **The held reprints follow this book, batch 3 of 4: the eleven held from Canada** (`~097`): `centaur` (printed 44-45), `cyber-horsemen-of-ixion` (51-54), `true-sasquatch` (173-176), `worldly-sasquatch` (176-177), `aardan-tek` (9-11), `grackle-tooth` (97-98), `greot-hunter` (98-100), `mastadonoid` (134-135), `noli-bushman` (144-146), `yeno` (215-217), `faerie-bot` (76-79). Read against both books off renders, one agent per class, about 180 changes, nearly all this book's revisions; `book-reconcile` found **no wrong figure**. None changes shape. **Experience:** the Centaur and the Cyber-Horsemen lose Canada's own ladders, because this book sends each to the chosen O.C.C.'s table; the two Sasquatch classes take the Merc Soldier's ladder and the Faerie Bot the Techno-Wizard's, each copied from the catalog's own class as this book directs. **The largest single revision:** the Yeno is given Hit Points and S.D.C., and Canada's M.D.C. figure becomes its force field's. **The name is Aardan Tek** in this book's heading and text, as in Canada's; "Aarden" appears once, in Canada printed 132. **Readings the page does not settle, stated in each class's notes:** the Centaur's +4 damage (unconditional as this book punctuates it); the True Sasquatch's Land Navigation printed as a bare 24% and 26%, and its save vs disease and pull punch each printed twice; the Grackle Tooth's "+1 attack" on the bonus line. Production held no saved character on any of the eleven. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/d-bees-of-north-america-last-updates` | **The held reprints follow this book, batch 4 of 4: ten classes from five books** (`~098`): `horune-pirate` (printed 100-103, from Underseas), `cactus-people` (41-44), `fennodi` (83-85), `lyn-srial` (127-129) and `lyn-srial-sky-knight` (129-130) from New West, `pogtalian-dragon-slayer` (156-159, South America), `blind-warrior-women` (15-18, Atlantis; headed Altara here), `tokanii` (203-206), `simvan-monster-rider` (188-190) and `psi-x-alien` (166-168) from Lone Star. Read against both books off renders, one agent per class, about 230 changes, nearly all this book's revisions; `book-reconcile` found **no wrong figure**. None changes shape. **That makes all 34** (6 from Coalition War Campaign, 7 from Psyscape, 11 from Canada, 10 here): the 32 entries the inventory marked "reprint, held" plus Aardan Tek and Pogtal, every one except the Lyn-Srial Cloudweaver, which printed 130 sends back to New West. The Cloudweaver and the Sky-Knight are declared copies of `lyn-srial`, so both now carry the race's two new blocks (the +2 dodge in flight both books print, and this book's Vulnerabilities line). **The Psi-X table's rows take this book's names** (Kineticist, Psychic Sensitive, Psychic Energy Conduit, Psychic Intuitive, Psychic Spiritualist, Psychic Manipulator) with their bands unchanged and 24 powers added across seven rows. **No Horror Factor for the Pogtal**: South America printed 12, and no page of this entry prints one. **Readings the page does not settle, stated in each class's notes:** the Simvan female's Cook, Dance and Sing bonuses; the Fennodi's body flip; the Blind Warrior Women's Hand to Hand style. Production held no saved character on any of these classes. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a4-race-creatures` | **52 playable races as creatures** (`~102`, `~103`), `playable = 1`, by Nate's ruling of 2026-10-04. `~102` adds 51 rows with 75 attacks: this book's own 48 races that had none (every R.C.C. from `adna-nomad` to `vintex-warrior` except `power-leech`) and `tokanii`, `simvan-monster-rider` and `psi-x-alien`, built from this book's pages as the newer printing. `~103` UPDATES the one race that already had a row: `power-leech`, held from Psyscape printed 126-128 as a monster, now carries printed 161-164's figures and is playable, with Psyscape's kept in its description. Built from renders by eight extraction agents and checked against renders again by `book-reconcile` in five passes: **no wrong figure in 52 rows**, and five attack notes reworded where a row claimed more than the page prints. **The book contradicts itself in four places, each recorded in its row:** Auto-G I.S.P. (M.E.+2D6 in the stat block, +4D6 in the psionics paragraph), Loak P.P.E. reserve (150 per level on printed 122, 120 on 124), Tokanii bone share of M.D.C. (90% and 80% on printed 205), Lyvorrk I.S.P. gain (printed per melee round). **One row per race:** the Spinne rolls its Starke bloodline and the Drizzit its male, with the other in the notes. **Not done here:** the creature rows that already existed for this book's 34 reprinted races (from Psyscape, Canada, Coalition War Campaign and the rest) still carry their original book's figures; the reprint batches moved the classes only. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/d-bees-of-north-america-racial-gear` | **The racial gear, and the classes take it** (`~116`, `~117`), by Nate's ruling of 2026-10-04. Every class whose notes said part of its Standard Equipment had no catalog row had its equipment line read again off a render, and each printed item it did not grant was sorted: held under another name (granted), statted by the book or the race's own (a new row, granted), a choice the book does not enumerate (nothing invented), or unstatted trivia (left). **46 new `gear` rows** (`~116`, by `scripts/rows-sql.mjs`): the Akysse Vibro-Spear, the Shemarrian Rail Gun, the Obsedai stone weapon, eight Nuhr rune weapons with three rune armors and the ship cannon, the Borrowed Ash Pouch, two Vernulian force field collars, four Spinne force fields, twelve racial and patchwork armors, and smaller racial kit. A rolled M.D.C. is null with the dice in the description; no row prints a price. **77 equipment lines across 27 classes** (`~117`), with every sentence they make false rewritten. Not granted though a row exists: the Altara microbes, both Vernulian collars, the N'reta translator, the Yhabbayar camera, the Septumbran armor, the Spinne fields, two Nuhr armors and the cannon; the script's header says why for each. `amana`'s gloves go from 100 boxes to one box of 100. Rows and held lines were checked against renders by `book-reconcile`: no disagreement. Still without a row: the Vernulian Serpent Power Armor (a vehicle), and the unstatted trivia each class names. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a13-category-bonuses` | **Related-skill category bonuses that lived only in a note now apply** (`~122`, `~123`): 2 of this book's classes (`idie-fisherman`, `iktektumik-hunter-gatherer`). `categoryBonus` reads an entry's `bonus` key and nothing else, so a bonus written only in the entry's note reached no character. A plain one gains the key; a bonus for part of a category gains a second entry naming those skills (`BOOK-INGEST-AUDIT` F109's shape). Taken from each class's own stored note; no page was reopened. No row count moves. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-a14-stale-notes` | **Stale "no catalog row" sentences corrected** (`~124`, `~125`), the last sweep of the close-out: 3 classes of this book (`idie-swamp-man`, `roane-piper`, `vintex-warrior`) said the catalog lacked an item, skill, spell, class or vehicle that it now holds. Each sentence was checked against production and now names the row; nothing a class grants changes. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-c2-roll-tables` | **The Lyvorrk's and the Dewtani's insanity tables are rolled at their levels** (`~161`, close-out package C2; `BOOK-INGEST-AUDIT` F116). Lyvorrk, printed 132: ten bands at levels 2, 4, 6, 8, 10, 12 and 14, replacing the level-progression line that cited F116. Dewtani, printed 66: four tables of the book's own, Phobia (21 rows, levels 3 and 7), Obsession (20, levels 5 and 11), Psychosis (9, level 9) and Affective Disorder (5, level 13), replacing six level-progression lines; the level 15 roll on the Rifts Ultimate Edition table stays a line. Old row counts in the Dewtani's notes (20, 19, 8) corrected to the page's. Read off renders and checked row by row by `book-reconcile`. No rows added. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-c5-own-psionics-tables` | **The Larmac's own psionics table replaces the standard roll** (`~163`, close-out package C5; `BOOK-INGEST-AUDIT` F118): printed 120 says to roll on its table to determine whether a character has psionics, with a No Psionics band at 16-00, so the class states `psionics_allowed: false`. Read off a render; no band disagreed. No rows added. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-closeout-claim-sweep` | **The close-out's claim sweep** (`~170`, `~171`): 11 classes of this book corrected (`amana`, `arac`, `chasseur-vert`, `forest-warden`, `lyvorrk`, `malvoren`, `mraghiile-tree-man`, `obsedai`, `psi-x-alien`, `squilb`, `vernulian`). `claim-capability-verifier` judged 988 limitation claims across the 218 classes the close-out touched; these are sentences that were false while the class's data was right, or that cited a finding for a gap it did not cover. Seven of these cited `BOOK-INGEST-AUDIT` F116 for level-gated things that finding never covered; four said their experience table was "not stored" when it is. No figure read from a book moves. No rows added. Applied `--remote` before the merge. |

### What remains

**After the retrospective close-out, 2026-10-05** (Phase C; `node scripts/source-coverage.mjs --remote` the same day: `d-bees-of-north-america 184 / 0`). Left: seven classes (`amana`, `arac`, `chasseur-vert`, `forest-warden`, `mraghiile-tree-man`, `squilb`, `vernulian`) hold something that grows or is picked by level in a way nothing models - a radius, S.D.C. per level, uses per day, a language per level, a skill pick limited to a category, levels past fifteen; their notes no longer cite F116 for it. `malvoren` says "Electrical Generation" has no catalog row where the catalog holds `Electricity Generation` (a page check away from a pick). The three Lyn-Srial classes say there is no field for the Horror or Awe Factor they project; there is one for Horror Factor, and whether an Awe Factor belongs in it is a ruling. `trimadore`'s +10% on Demolitions and Trap skills is a note where a scoped category entry could hold it.
