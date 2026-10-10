# Palladium Fantasy RPG Book 9: The Baalgor Wastelands — survey

**Status:** `importing` — creatures, notable NPCs and the warship are in; the twenty classes are next. (2026-10-10)

**Rows citing this book:** creatures 24, notable_npcs 60, vehicles 1

Slug `baalgor-wastelands`. Cached 2026-10-05 from
`515266553-Palladium-Fantasy-Book-9-The-Baalgor-Wastelands.pdf`, 218 PDF
pages, **scan (no text layer)**, OCR at 300 dpi, psm 3. Median 5,340
chars/page. Second edition; the copyright page (cache `p003`) gives a first
printing of March 1999.

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
| `p150` | 149 |
| `p200` | 199 |
| `p214` | 213 |
| `p215` | 214 |
| `p216` | 215 (read off a render) |

One region, no `page_offset_exceptions`. The OCR did not pick up a folio on
several of the pages sampled between 20 and 150; the six above agree and
the Contents page numbers land on the right entries under +1.
**`printed_pages` is 215**, the Experience Tables page, at cache `p216`.
`ocr-book.py` measured 214 and the registry outranks the manifest. Cache
`p217` and `p218` are unnumbered catalogue pages. Cache `p005`-`p006` hold
the Contents and the Quick Find table (printed 4-5).

## OCR quality

Stat-block labels survived (`Alignment:`, `Horror Factor:`, `Damage:`). The
Contents' page numbers are misread in places, and a few entry names in it
are unreadable; names below come from the body headings. The cache holds
curly apostrophes and em-dashes; strip them before any SQL.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | 4-5 | *Contents* | the order and printed page of every race, place, tribe, caravan, war camp and stronghold |
| **p006** | 5 | *Quick Find Table* | a second reading of the pages of the R.C.C.s and a few rules tables |
| **p216** | 215 | *Experience Tables* | **which races are playable and what ladder each uses** |

**Printed 215 is the page that matters most**, and it was read off a render
for this survey. It says, in its own words paraphrased here:

- Giants, Gromek, Minotaur, Eandroth, Dragonmen and Vrill use the ladder of
  whatever O.C.C. the character takes. Vrill are limited to a short list of
  O.C.C.s.
- Earthshakers, Sandwyrms and Thin Ones are NPC monsters and get no ladder.
- It prints six ladders of its own, to level 15: the Baalizad R.C.C., the
  Gosai Assassin R.C.C., the Quillback Scavenger R.C.C., the Quorian
  Oneiromancer, the Adraodan Minotaur's Crusaders of Light O.C.C. and the
  Kkairojan Minotaur's Soldier of Darkness.
- The Gosai, Quillback and Quorian may otherwise take ordinary O.C.C.s,
  with exclusions it lists.

## Inventory

Counted by structure (stat-block markers per page, and the Contents) over
all 218 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Part One: history and geography | 7-15 | lore |
| Desert adventuring | 15-25 | rules: climate, water, heat, armor, terrain, riding animals, wagons, six kinds of bad weather |
| Part Two: The People | 26-69 | **18 Contents entries** carrying **24 stat blocks**; the Giants entry (36-43) holds several kinds, four with their own heading (Cyclops 40, Jotan 41, Gigantes 42, Nimro 43) |
| Part Three: overview, colonies, pirate coves | 70-86 | places; `Alignment:` opens 15 blocks (77-86) |
| The Free City of Troker | 87-104 | a city key, a map (102), notable residents (103) |
| The Stony Desert | 105-130 | Dragonmen tribes, Eandroth caravans, Quorian wandercamps, marauder crews, Gromek war camps; **1 vehicle** (the Orcish Delight warship, a Dwarven landship, 122); encounter tables (105, 127) and a rift table (129) |
| The Sandy Desert | 131-148 | caravans, Gosai tribes, war camps, Minotaur tribes; **2 mutant Minotaur R.C.C.s** (Adraodan 142, Kkairojan 144); the ruins of Baalgor (145) |
| The Rocky Desert | 149-171 | caravans, giant strongholds, Baalizad burrows, Minotaur catacombs, Quillbacks |
| The Eastern Baalgor Mountains | 172-205 | Minotaur tribes, Gromek war camps (Raag Vire with a map, 176-181), Gurthasi Tor the city of giants (188-201) |
| Part Four: Adventures | 206-214 | adventure outlines |
| Experience Tables | 215 | one page |

`Alignment:` opens **63 lines on 52 pages**: 24 in Part Two and 39 in the
places, where they are tribe leaders, caravan masters, pirate captains and
rulers.

### Spells, psionic powers, skills, gear: zero

No spell or power description, no skill list and no price list. `P.P.E.:`
and `I.S.P.:` hits are pools. `Base Skill:` appears only inside the
Baalizad's natural abilities (28). The Quorian Oneiromancer (57) selects
from existing spells and psionics and points at another book for one chant.

## Classes

### Races with a player-character route (printed 215 is the authority)

| race | printed | route |
|---|---|---|
| Baalizad R.C.C. | 26-28 | its own ladder |
| Dragonmen | 30 | by O.C.C. |
| Eandroth R.C.C. | 32-34 | by O.C.C. |
| Giants: Cyclops, Jotan, Gigantes, Nimro and the others under the heading | 36-43 | by O.C.C. |
| Gosai | 44-45 | by O.C.C., or the **Gosai Assassin R.C.C.** (45) with its own ladder |
| Gromek | 46-47 | by O.C.C. |
| Minotaur | 48-50 | by O.C.C. |
| Quillback | 53 | by O.C.C., or the **Quillback Scavenger R.C.C.** with its own ladder |
| Quorian | 54-56 | by O.C.C., or the **Quorian Oneiromancer** (57) with its own ladder |
| Vrill | 66-67 | by O.C.C., from a short list |
| Adraodan Minotaur | 142 | the Crusaders of Light O.C.C., its own ladder |
| Kkairojan Minotaur | 144 | the Soldier of Darkness, its own ladder |

### Monsters, by the book's own tags

Cyclops Spider (29), Drayback (31), Earthshaker (35), Lazretheg (48),
Mologoth (50), Rock Buzzer (57), Sandwyrm (59) and Thin Ones (63). The
Contents tags six of them as monsters and the Sandwyrm as a dragon
sub-species; printed 215 says the Earthshaker, Sandwyrm and Thin Ones are
not player characters.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-05 with
`scripts/catalog-diff.mjs`. No row in any table cites this book.

### classes: every race here is missing as a Palladium Fantasy class

**Fourteen are held as Rifts classes**: Algor, Cyclops, Gigantes, Jotan,
Nimro, Titan, Minotaur, Dragonman, Gosai, Gosai Assassin, Quillback,
Quorian, Quorian Oneiromancer and Vrill (ids `rifts-...`, system `rifts`).
They matched by name and are **not** this book's rows: the system differs.
Which book each was imported from was not traced for this survey.

No Palladium Fantasy class row is held for any race in this book. Not held
in either system: Baalizad, Eandroth and Gromek as classes, the Quillback
Scavenger, and the two mutant Minotaur classes.

### creatures: 3 held as Rifts conversions, none as Palladium Fantasy

Eandroth, Gromek and Sandwyrm are held from Rifts Conversion Book One
(p.146-147, 153-154, 172-173), in the Rifts system. The eight monsters
listed above are not held in any system under these names.

### notable_npcs: 7 names checked, 0 matched

King Kai, Rystrom Khejas, Jijjerinn the Magnificent, Overlord Orgath
Nukessin, Wydras the Dreamer, Bimmid the Bold and Scarbone. The other
blocks in Part Three were not diffed by name; names are read off renders
first.

### vehicles: 1 missing

The Orcish Delight warship (122).

## Extraction plan

1. **Creatures** — the eight monsters, and the races as creature rows if
   the standing race-as-creature question is ruled that way; through
   `scripts/bestiary-sql.mjs`, in the `palladium-fantasy` system.
2. **Classes** — the races as Palladium Fantasy R.C.C.s, and the five
   classes with their own ladders (Gosai Assassin, Quillback Scavenger,
   Quorian Oneiromancer, Crusaders of Light, Soldier of Darkness), ladders
   off a render of printed 215.
3. **Notable NPCs** — the 39 stat blocks of Part Three, counted from
   renders.
4. **Vehicle** — the Orcish Delight, through `scripts/vessel-sql.mjs`.

Each batch is extracted off renders by `book-extract-worker` and checked by
`book-reconcile` before its script is written.

**For Nate to decide before extraction:**

- **Races that take an ordinary O.C.C.** (Dragonmen, Eandroth, Giants,
  Gromek, Minotaur, Vrill, and the Gosai, Quillback and Quorian outside
  their special classes): race rows that pair with existing Palladium
  Fantasy O.C.C.s, or left as creature rows.
- **The fourteen held Rifts classes of the same names**: add the Palladium
  Fantasy rows beside them, or treat the Rifts rows as enough.
- **The desert rules** (15-25): rules tables; left unless asked for.

What is deliberately left, with the reason for each:

- **Tribes, caravans, war camps, strongholds, coves and Troker** as places —
  lore. Their leaders are the NPC batch.
- **Encounter tables and the rift table** (105, 127, 129, 145, 167, 202) —
  G.M. material.
- **The adventures** (206-214).

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-05 | `pal/data/baalgor-wastelands-survey` | cache built (218 pp, OCR), `baalgor-wastelands` registered in `books.json`, this survey written, offset +1 verified, printed 215 read off a render. No data. |

| 2026-10-10 | `pal/data/baalgor-wastelands-bestiary` | 24 creatures and 60 notable NPCs with 216 attacks (`~180`), and the Orcish Delight warship with 9 locations and 3 weapons (`~181`). Applied `--remote` first. Status to `importing`. |

### Nate's answers, 2026-10-05

- Races go in as Palladium Fantasy classes AND as creature rows; the held
  Rifts rows of the same names stay as they are.
- The five classes with their own ladders and the two mutant Minotaur races
  are all imported.
- A notable NPC row needs printed Hit Points, a level or class, and an
  alignment. Thinner blocks are listed below, not imported.
- Desert rules, encounter tables and adventures stay out. Each PR is merged
  when green.

### What extraction found that this survey had wrong

- **The survey estimated 39 leader blocks from `Alignment:` lines; 60 pass
  the rule.** Many blocks print the alignment inside a sentence.
- **Sloderi (printed 61-63) has its own full block** and was missing from
  the monster list above. It is in.
- **Titan and Algor have no stat block in this book** (named on printed
  38 and 43 only). The giants with blocks are Cyclops, Jotan, Gigantes and
  Nimro.
- **The Quillback Scavenger is held as a Rifts class** (`rifts-quillback-scavenger`);
  the diff above says it is not held.
- Entry page ranges run one page past the Contents: Baalizad 26-29,
  Eandroth 32-35, Quillback 52-54, Vrill 66-68.
- Three creature slugs were taken by Rifts Conversion Book One rows, so
  this book's rows are `eandroth-pf`, `gromek-pf` and `sandwyrm-pf`.

### Left out of the bestiary, with the reason

- **Named people with no printed Hit Points or no alignment** (about 90
  across Part Three): the Troker residents of printed 96-104, the colony
  and cove figures of 74-76 and 85-86, and the lieutenants named in tribe
  and war-camp essays. Four print Hit Points and a level but no alignment:
  Gonsol Rorgatha, Quillon Cashcraw and Hargus Ferthik (195) and
  Highwatcher (201); so do Freelym Deryn and Seethen Jhyheryn (152).
- **Encounter-table animals** printed as one line (a desert viper on 146
  and 168, a baboon on 169) and the five-line typical Gromek of 125, which
  repeats the race row.
- **Eandroth rogues** are a life stage and sit inside the Eandroth row.

### Readings recorded in the rows

- Giants: the punch damages of printed 40 are on all four giants; the
  Gigantes and Nimro blocks do not repeat them and rest on that page's
  section rule.
- The Kkairojan Minotaur prints its attributes only as those of all
  Minotaurs; the row carries the dice of printed 50.
- The Sandwyrm row holds the young figures; the adult multipliers are in
  its notes.
- The warship's main body is printed as three sections with no total, so
  it has no main-body figure. Its ballistas (124) and run-over damage
  (123) are stored from the prose, outside the book's own two lists.
- The book's own metric conversions are wrong in two places (Mologoth
  size, Rock Buzzer weight); the rows keep the printed text.

### What remains

The twenty classes: fifteen races (four of them giants, two of them mutant
Minotaurs) and the
five classes with ladders on printed 215. Drafted and reconciled; they ship
next on `pal/data/baalgor-wastelands-classes`.
