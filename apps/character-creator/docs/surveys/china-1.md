# Rifts World Book 24: China 1 — survey

**Status:** `imported` — the plan is done: 24 curses, 39 creatures, 23 notable NPCs and the Naga-Spawn class. Left out on purpose: the Were-Beasts (no numbers in this book), setting lore and the optional demon tables. (2026-10-02)

**Rows citing this book:** classes 1, spells 24, notable_npcs 23, creatures 39

Slug `china-1`. Cached 2026-10-01 from
`Rifts- World Book 24 China 1 Yama Kings.pdf`, 162 PDF pages, **scan (no text
layer)**, OCR at 300 dpi, psm 3. `--probe` read 0 characters on all 20 sampled
pages.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

This is the first of two China books, and the mirror of `china-2`. **It is a
gazetteer and a bestiary: it defines no O.C.C., no skill, no spell and no
priced gear.** What it holds is the eleven Kingdoms of Hell with their rulers,
24 demonic curses, and the ghosts, goblins and demons that `china-2`'s classes
fight, bind or (the Enlightened Demon R.C.C.) play.

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio rather than trusting the vote:

| cache page | folio printed on it | read from | offset |
|---|---|---|---|
| `p004` | 3 | render | +1 |
| `p005` | 4 | render | +1 |
| `p006` | 5 | render | +1 |
| `p056` | 55 | OCR text | +1 |
| `p086` | 85 | OCR text | +1 |
| `p119` | 118 | OCR text | +1 |
| `p161` | 160 | render | +1 |

A sweep of the whole cache finds the folio `cache page - 1` as a bare line on
**128 of 162 pages** and no page carrying any other folio. One region, no
`page_offset_exceptions`. **`printed_pages` is 160**, the publisher's release
schedule at cache `p161`. The cache manifest says 159, the map keys at `p160`,
which is the last content page. Cache `p001`-`p004` are cover, dedication and
credits, `p005`-`p006` the Contents and Quick Find, `p162` the back cover.

## Cache health

A scan, so the manifest carries none of the three text-layer keys
(`welded_pages`, `corrupt_pages`, `substituted_digits`). What was measured
instead:

- Median 5,877 bytes of text per cached page. Stat-block labels survived:
  `Alignment`, `Attributes`, `M.D.C.`, `Horror Factor`, `Natural Abilities`,
  `Equivalent Level of Experience`, `R.C.C. Bonuses`, `Magic`, `Psionics`,
  `Habitat` each count cleanly per entry.
- **Six cache pages are empty or near-empty, and each is a full-page art plate
  or a map**: p007, p011, p118, p135, p149 (art; printed 6, 10, 117, 134, 148)
  and p159 (the country maps, printed 158). Checked on a contact sheet. No
  text was lost.
- **Digit damage in dice is present**: a leading `1` read as `|` or `I`
  (`|D4`, `|D6+1`, `1|D6+2`), `I.Q.` read as `1.Q.`, a `5` read as `S`
  (`1Sth level`, `Sth Kingdom`). Read each die expression as the dice it must
  be, and check the number on a render.
- Curly quotes, em-dashes, the registered-trademark sign and a replacement
  glyph for apostrophes are throughout. Strip them before any SQL.
- The maps (printed 158-159) are images. Their labels did not OCR and are not
  needed.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005** | 4 | *Contents* | the printed page of every province, ruler, artifact group, the curse chapter and the four bestiary divisions |
| **p006** | 5 | *Quick Find* | **the bestiary's master list**, grouped as Ghosts (5), Goblins (6, with two cross-references), Demons Lesser, Demons Greater and Demon Lords, each with its page; and the eleven Yama Kings by number, naming the two kingdoms that have none. A second reading of every page the Contents gives |
| **p012** | 11 | the eleven-province overview | each Kingdom of Hell by number, province and ruler |
| **p056** | 55 | *Curse Descriptions* list | the **24 demonic curses** by name |
| **p085** | 84 | the *Demons* list | Lesser Demons (11), Greater Demons (11 lines, one a cross-reference) and Demon Lords (2). A third reading of the bestiary's names |
| **p104** | 103 | the Were-Beast type list | the four types found in China: panther/leopard, snake, tiger, wolf |
| **p145-p150** | 144-149 | the optional demon tables | Demonic Characteristics and Features, Quirks and Personality Flaws, Unique Demonic Power, Demonic Rank. Percentile tables for customising an NPC demon |

The Quick Find is the more valuable of the two indexes: the Contents lists
only the first goblin or two under each bestiary heading, the Quick Find lists
every one. **The three lists agree** with each other and with the stat blocks
found by structure: every listed creature has a block, and the blocks found
outside the lists are the ones the Quick Find marks as cross-references into
a province or into the Naga entry.

**The curse list and the curse headings agree: 24 names on the list, 24
description headings** on printed 55-60.

There is **no Experience Table page**. The book defines no class, and its
creatures carry an equivalent level as a die roll instead of a ladder.

## Inventory

Counted by structure (stat-block markers and headings) over all 162 cached
pages, with the Contents and Quick Find read off renders.

| section | printed | what is there |
|---|---|---|
| Introduction, the mist, the coastline | 7-10 | lore. No stat blocks |
| The Eleven Hells | 11-53 | **eleven provinces**, each with a ruler, geography, population and places; **14 named NPCs with full stat blocks**; four Living Statues; about nine minor creatures described inside a ruler's entry; about fifteen unique artifacts, none priced |
| Terra-Cotta Warriors | 51-53 | **2 creature blocks**: the Terra-Cotta Warrior and the Tiny Terra-Cotta Warrior, both with rolled attributes |
| Demonic Curses | 54-60 | **24 curses**, each with penalties and a duration. The rules for casting one are on printed 54 |
| Ghosts | 60-73 | **5**: Ch'iang Shih (Chinese Vampire), Kuei, Preta, Shen Mo, Vapours |
| Goblins | 74-84 | **6**: Fox Spirit, Goat Goblin, Shadow Goblin (also Ghost Goblin), Mountain Goblin, One-Horned Goblin, Tall Man Goblin |
| Lesser Demons | 84-105 | **11**: Ch'uan Ti, Falcon Demon, Fox Faerie, Headless One, Long-Armed Giant, Ma T-ou, Monkey-Wolf, Ox-Head Demon, Pig Demon, Were-Beasts (four types under one entry), Yang Ching. Then *The Dead & the Damned* (105), a short entry. **Ten of the eleven print a stat block**: the Were-Beasts are prose and defer to Rifts Dark Conversions pp.99-105, and the Dead & the Damned is prose too (found at extraction, 2026-10-01) |
| Greater Demons | 106-132 | **10**: Kinnaras, Kou Ching, Mahoragas, Monkey Spirit, Naga, Red Child, Shen Wu, White Monkey, Yaksha, Ying Hsuan Shang. Inside the Naga entry: the **Naga-Spawn** (118), and inline stat lines for the Water Goblin and the Water Devil (119-120) |
| Demon Lords | 133-140 | **2**: Mo-Lo, Shih-Ju Shen; and the **Mara Asuras** (136), a greater demon printed between them |
| Using Demon NPCs | 141-149 | play advice, weaknesses common to all demons (143), and four optional percentile tables |
| Life in Rifts China | 150-157 | village statistics, industries, housing, demon settlements. Lore and tables, no catalog rows |
| Maps | 158-159 | images |
| Release schedule | 160 | advertising |

That is **35 bestiary entries with a full stat block** (2 + 5 + 6 + 10 + 10 +
2), plus the Mara Asuras, the Naga-Spawn, two inline water creatures and the
minor creatures of the province chapters. This said 36 until the lesser
demons were extracted and the Were-Beast entry turned out to print no numbers.

### The named NPCs (14), printed 12-50

| NPC | printed | role |
|---|---|---|
| Huan Shih | 12-13 | Celestial Master of Mount Song, 1st Kingdom (a hero) |
| Wu Je Nao | 14 | Abbot of the Shaolin Temple; a White Dragon (a hero) |
| Chu Chiang | 16-18 | 2nd Yama King |
| Xian Ya | 19-20 | the Immortal Raven (a hero) |
| Qin Kuai | 20-21 | the Usurper, 3rd Kingdom |
| Lady Wang | 22 | his wife; stated as differences from Qin Kuai |
| Wu Kuan | 25-27 | 4th Yama King |
| Yen Lo | 29-30 | 5th Yama King |
| Pien Cheng | 34-36 | 6th Yama King |
| Tai Shan Chun | 38-39 | Demon Regent, 7th Kingdom |
| Ping Teng | 41-43 | 8th Yama King |
| Tu Shis | 45-46 | 9th Yama King |
| Meng P'o Niang Niang | 48-49 | of the Terrace of Oblivion (a hero) |
| Huang Di | 49-51 | Emperor, 11th Kingdom; a mortal with Hit Points and S.D.C. |

The 1st and 10th Kingdoms have no Yama King (Quick Find, printed 5). The
Living Statues of Qin Kuai, Lady Wang, Feng Xiao and Feng Zhong (printed
22-23) are stated as one block and three sets of differences.

**Their classes and martial art powers are `china-2`'s.** The stat blocks name
Chi Mage, Taoist Immortal, Enlightened Scholar and Chinese Alchemist levels
and powers such as Ba Gua and Xian Tai Chi Chuan by name only.

### Minor creatures inside the province chapters

Each is described in a ruler's *Artifacts & Creatures of Note* or *Allies &
Servants* paragraph, most with a partial stat line rather than a full block:
the Ice Spider (18), Book Demons (24), Black Bees and the Never-Dying Servant
(30), Demon Boars and Jackal Wolves (40), the Crimson Moth and the White Lead
Leopards (46-47), and Huan Shih's iron servants (13). **Each needs a render
read before deciding whether it carries enough numbers to be a row.**

### Things this book has zero of, checked rather than assumed

- **Classes.** No `Attribute Requirements`, `O.C.C. Skills` or `R.C.C. Skills`
  line in 162 pages. `R.C.C. Bonuses` appears 34 times, and every one is a
  creature's combat bonus line. The two places a player character is
  mentioned are below.
- **Skills.** No skill list and no skill description.
- **Spells.** Every `P.P.E.:` line is a creature's or NPC's pool. Creatures
  list the spells they know by name, from other books' lists.
- **Psionic powers.** None defined.
- **Priced gear, weapons, armor, vehicles.** No `Cost:` line anywhere. The
  artifacts are unique possessions of named rulers; one group, the swords for
  slaying demons at the Orthodox Oneness Temple (printed 28), states a damage.

### Where the book says something may be played

Neither is a class with a skill list:

- **Were-Beasts** (printed 104): with the Game Master's approval, as a player
  character in a Celestial Court campaign. A design note on the same page says
  the same, loosely, of some goblins, spirits and demons, naming none.
- **Naga-Spawn** (printed 118): a half-Naga raised human. Stated as attribute
  bonuses, an M.D.C. formula, special abilities and vulnerabilities **on top of
  a human O.C.C.**, which supplies the skills. Allowed as a player character
  under the same condition.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-01.

**No production row cites this book** in `creatures` or `notable_npcs`, and no
`creatures.source_book` names China at all.

### creatures: 49 entries, 49 missing, 0 false gaps

`node scripts/catalog-diff.mjs --remote --table creatures --entries <49 entries>`
returns **matched 0, missing 49** (467 catalog rows). The 49 are the 36
bestiary entries, the Mara Asuras, Naga-Spawn, Dead & the Damned, Water
Goblin, Water Devil and eight minor creatures.

Every near-match hand-checked:

| book prints | nearest catalog row | verdict |
|---|---|---|
| Yaksha | `Raksasha` (Palladium Fantasy p.325) | different demon, different book. New row |
| Water Devil, Water Goblin | `Water Demon` (Mystic Russia p.36-38) | different creatures. New rows |
| Shadow / One-Horned / Tall Man Goblin | `Demon Goblin` (Wormwood p.122-124) | unrelated. New rows |
| Goat Goblin | `Psi-Goblin` (Psyscape) | unrelated. New row |
| Monkey-Wolf, Jackal Wolf | `Man-Wolf` (Mystic Russia) | unrelated. New rows |
| Naga | `Yema` (Conversion Book One) | unrelated. New row |
| Were-Beast (panther type) | `Werejaguar / Werepanther` (South America p.117-118) | a different book's creature with its own numbers. New row; **name it so the two do not read as one** |
| Mountain Goblin | `Mountain Giant` | unrelated. New row |

`creatures.category` already holds `demon`, `undead`, `spirit`, `entity`,
`construct` and `supernatural`, which cover everything here. No new category
is needed.

### notable_npcs: 14 entries, 14 missing, 0 false gaps

`node scripts/catalog-diff.mjs --remote --table notable_npcs --entries <14 entries>`
returns **matched 0, missing 14** (398 catalog rows). No near-match is closer
than distance 3, and none is the same person.

### curses

There is no table for curses. D1 below puts them in `spells`.

## Extraction plan

Phase 4 costs money; everything above was free. **Agreed by Nate on
2026-10-01**, with the decisions D1-D5 below folded in:

1. **Demonic curses** — 24 `spells` rows in a new `Demonic Curse` tradition,
   printed 54-60 (D1). First, because every later row names them. One PR.
2. **Ghosts and goblins** — 11 `creatures` rows, printed 60-84, through
   `scripts/bestiary-sql.mjs`. One PR.
3. **Lesser demons** — **10 rows**, printed 84-105. One PR. The Were-Beasts
   and the Dead & the Damned print no stat block (see the amendment to D2).
4. **Greater demons and Demon Lords** — 13 rows (10 greater, the Mara Asuras,
   2 lords), plus the Naga-Spawn, Water Goblin and Water Devil, printed
   106-140. One PR.
5. **Terra-Cotta Warriors** — 2 `creatures` rows, printed 51-53. Rides with
   step 4 or 6. The minor province creatures get no rows (D3).
6. **Named NPCs** — 14 `notable_npcs` rows, printed 12-51, plus **4 rows for
   the Living Statues** (D4). Each ruler's minor creatures go in that ruler's
   `allies` text (D3). One or two PRs.
7. **Naga-Spawn and Were-Beast as classes** (D2) — after their `creatures`
   rows. The Were-Beast is an R.C.C.; the Naga-Spawn is a template over a
   human O.C.C., so run the class through `audit-premise-auditor` before
   scoping and file a finding if the class schema cannot express it.

### Decisions (Nate, 2026-10-01)

- **D1 — curses are `spells` rows in a new tradition.** Named
  `Demonic Curse: <name>` by the tradition-namespace convention. No P.P.E.
  cost is printed per curse (casting one spends half the creature's pool,
  printed 54), so the cost column takes the catalog's no-cost form; check
  what `spell stubs` in the backlog counts before choosing level and cost, so
  24 rows do not land as stubs.
- **D2 — Naga-Spawn and Were-Beasts become classes too**, as well as
  `creatures` rows. **Amended 2026-10-01 by what the book prints: the
  Were-Beast entry (printed 103-104) is prose.** It names four types and sends
  the reader to Rifts Dark Conversions pp.99-105 for every number, so this
  book supplies neither a `creatures` row nor a class for them. The only
  were-creature in production is South America's Werejaguar / Werepanther. A
  Were-Beast class waits on Dark Conversions being cached. The Naga-Spawn
  half of D2 stands.
- **D3 — the minor province creatures stay in their ruler's text.** No rows
  for the Ice Spider, Book Demons, Black Bees, Never-Dying Servant, Demon
  Boars, Jackal Wolves, Crimson Moth, White Lead Leopards or the iron
  servants. That takes the `creatures` plan from 49 entries to **41**.
- **D4 — the four Living Statues are `notable_npcs` rows**, 18 in all.
  **23 as shipped (2026-10-02).** Extraction found five more named
  individuals with stat lines the survey had not counted: Feng Xiao and Feng
  Zhong as living people beside their statues (printed 23), and three allies
  of Tai Shan Chun, Chi Chou Lu, Ast-Oth and Zhua Zhao (printed 39-40).
- **D5 — this book's bestiary ships before `china-2`'s classes.**

Slices for `book-extract-worker`, if fanned out, follow those five page
ranges with one page of overlap at each slice edge.

What is deliberately left, with the reason for each:

- **Province gazetteer** (11-53, outside the stat blocks) — setting lore, no
  rows. `cities` is a candidate table; not proposed here.
- **Unique artifacts** — unpriced possessions of one ruler each. They go in
  that NPC's `weapons_and_equipment`, not in `gear`.
- **The optional demon tables** (144-149) — Game Master customisation tables.
- **Life in Rifts China** (150-157) and the maps — lore.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/china-1-survey` | cache built (162 pp, scan, OCR 300 dpi), offset +1 verified on renders and on 128 OCR folios, `china-1` registered in `books.json`, this survey. No rows. Written in its own worktree while five other book trees were live (`australia`, `canada`, `china-2`, `warlords-of-russia`, `xiticix-invasion`). |
| 2026-10-01 | `pal/data/china-1-curses` | Plan step 1 (D1): **24 `spells` rows**, tradition `demonic-curse`, named `Demonic Curse: <name>`, printed 55-60, in `~058-china-1-demonic-curses.sql`. Level 0 and 0 P.P.E. with the cost in `ppe_note` (half the creature's pool, printed 54). Every row checked against the chapter by `book-reconcile`: 24 of 24 clean. Spells 1,119 to 1,143. Moves `spell stubs` 19 to 43; all 24 are finished rows, the line counts level 0 with 0 P.P.E. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/china-1-ghosts-goblins` | Plan step 2: **11 `creatures` rows** and 35 `stat_attacks`, printed 61-84, in `~060-china-1-ghosts-and-goblins.sql`, written by `scripts/bestiary-sql.mjs`. First applied as `~059`; renumbered at merge when Australia's skills took that number, with the file made to re-apply over its own rows. Ghosts: Ch'iang Shih, Kuei, Preta, Shen Mo, Vapours. Goblins: Fox Spirit, Goat, Shadow, Mountain, One-Horned, Tall Man. Two `book-extract-worker` slices, then `book-reconcile` over every field with renders of printed 74-76, 80, 82 and 83: 11 of 11 clean. None playable. Each row's curses are named in `magic` as the `Demonic Curse:` rows of step 1. Applied `--remote` before the PR. |
| 2026-10-01 | `pal/data/china-1-lesser-demons` | Plan step 3: **10 `creatures` rows** and 57 `stat_attacks`, printed 84-105, in `~061-china-1-lesser-demons.sql`, written by `scripts/bestiary-sql.mjs`: Ch'uan Ti, Falcon Demon, Fox Faerie, Headless One, Long-Armed Giant, Ma T-ou, Monkey-Wolf, Ox-Head Demon, Pig Demon, Yang Ching. Two `book-extract-worker` slices with every stat line read on a render, then `book-reconcile` over every field: one page range corrected (Ox-Head, 99-100), every value clean. **No row for the Were-Beasts or the Dead & the Damned: neither prints a stat block**, confirmed by the reconcile. None playable. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/china-1-greater-demons` | Plan step 4: **16 `creatures` rows** and 77 `stat_attacks`, printed 106-141, in `~062-china-1-greater-demons.sql`, written by `scripts/bestiary-sql.mjs`. Greater demons: Kinnaras, Kou Ching, Mahoragas, Monkey Spirit, Naga, Red Child Demon, Shen Wu, White Monkey, Yaksha, Ying Hsuan Shang, Mara Asuras. Demon Lords: Mo-Lo, Shih-Ju Shen. From inside the Naga entry: the **Naga-Spawn** (`playable` 1, the only playable row from this book), the Water Goblin and the Water Devil. Three `book-extract-worker` slices, three shaping agents, then two `book-reconcile` passes over every field with renders: four page ranges corrected and one derived damage figure unsummed, every stat value clean. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/china-1-npcs` | Plan steps 5 and 6: **23 `notable_npcs` rows, 2 `creatures` rows** and 36 `stat_attacks`, printed 12-53, in `~063-china-1-npcs-and-terra-cotta.sql`, written by `scripts/bestiary-sql.mjs`. Rulers and heroes: Huan Shih, Wu Je Nao, Chu Chiang, Xian Ya, Qin Kuai, Wu Kuan, Yen Lo, Pien Cheng, Tai Shan Chun, Ping Teng, Tu Shis, Meng P'o Niang Niang, Huang Di. Qin Kuai's household: Lady Wang, Feng Xiao, Feng Zhong and the four Living Statues (D4). Tai Shan Chun's allies: Chi Chou Lu, Ast-Oth, Zhua Zhao. Creatures: Terra-Cotta Warrior, Tiny Terra-Cotta Warrior. **The minor province creatures are text on their ruler's `allies`, with every printed number (D3)**: the iron servants, Ice Spider, Book Demons, Black Bees, Never-Dying Servants, Jackal Wolves, Demon Boars, Crimson Moth, White Lead Leopards and the lesser Demon Lords of each province. The unique artifacts are in `weapons_and_equipment`. Three `book-extract-worker` slices, three shaping agents, three `book-reconcile` passes with renders of every stat block: two page ranges, three page citations and four loose phrasings corrected, every stat value clean. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/china-1-naga-spawn-class` | Plan step 7 (D2): **the Naga-Spawn R.C.C.**, printed 118, in `add-naga-spawn-class.sql`, emitted by `class-check --remote --emit-script` at 0 errors and 0 warnings. A race over a human O.C.C.: attribute dice are the human 3D6 plus the printed bonus (4d6; 5d6 for M.A. and P.S.), M.D.C. P.E. x3 plus 2D6 per level, Swimming 98%, no occupation barred. Tag `supernatural`. **This closes the plan.** The Were-Beast class of D2 is not built: the book prints no numbers for it. Applied `--remote` before the PR. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-10-02, after the NPCs were
applied:

```
  china-1             86 / 0
```

All 86 rows (24 spells, 39 creatures, 23 notable NPCs) trace to their page.
That run's `BACKLOG` block:

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            14   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           43   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

**`spell stubs` moved 19 to 43 with the curses, and the 24 are this book's.**
They are not unfinished: the book prints no level and no per-curse cost, and
each row carries the cost rule in `ppe_note`, as the 19 counted before them
do. The line counts every imported level-0 row with 0 P.P.E. No later batch
moved anything in the block.

**Nothing remains of the plan.** The Naga-Spawn class shipped last, beside its
`creatures` row. Open for a later session, none of it owed by this book: a
Were-Beast class once Rifts Dark Conversions is cached (D2), and a home for
the minor province creatures if they are ever wanted as rows (D3).

### Notes for the next batch

- **A stat block's M.A. and M.E. change order between entries.** Some print
  I.Q., M.A., M.E. and some I.Q., M.E., M.A. Key each by its label.
- **The same percentile OCR damage recurs**: `0/-25%` is 01-25%, `|D4` is 1D4,
  and a Horror Factor read as `1]` or `/5` is 11 or 15. Render the line.
- **The OCR drops the Goat Goblin from the Quick Find**, reading only the
  Ghost Goblin cross-reference beside it. The render of printed 5 lists both.
- **`bestiary-sql.mjs` refuses an 8-word run shared with the cache** in
  `natural_abilities` and `description`. Lists of illnesses and of clergy
  were the ones caught; reorder a list rather than trim it.
- **Vulnerabilities go in `natural_abilities`** after the word
  VULNERABILITIES, since `creatures` has no column for them. The alias a
  heading prints ("also known as") goes at the head of `pools_note`.
- **Printed 97 is white text on black** in its lower right, and the OCR drops
  it whole: the Monkey-Wolf's attributes, M.D.C. and Horror Factor are not in
  the cache. A 300 dpi render of that region reads cleanly without inverting.
- **A power punch is often printed as dice with no unit.** The rows call it
  M.D., after the full-strength punch beside it, and say so in the attack's
  note.
- **Two demons can print one Damage and one R.C.C. Bonuses line word for
  word** (Falcon Demon and Ma T-ou). It is the book, not a copying error.
- **The copy check catches the bio-regeneration sentence in every block.**
  Write it as "Bio-regeneration: 2D6 M.D. each melee round (double at ley
  lines or wherever negative energy gathers)" from the start.
- **Number the script late and expect to renumber.** `~059` was taken by
  another book between the push and the merge; the fix is in `~060`'s header.
- **A greater demon's M.D.C. and P.P.E. carry a per-level addition** the
  creature grammar cannot hold. `mdc` and `ppe` store the base and
  `pools_note` the addition ("+1D6x100 per level").
- **The Naga-Spawn prints attribute bonuses over a human, not formulas.** Its
  row stores the human 3D6 plus the bonus ("3D6+1D6", "3D6+2D6") and says so.
  It is `playable` 1: the book allows it as a player character in a campaign
  of Heroes of the Celestial Court.
- **The Naga and Mo-Lo print one attribute line word for word**, with no comma
  between M.A. and M.E. Both were read off renders independently.
- **The Red Child prints an Awe Factor of 15 and no Horror Factor number.** Its
  `horror_factor` holds the 15 and `pools_note` says which it is.
- **A page range is the error extraction makes most**: five of the 26 demon
  rows cited a page too many or too few, and no stat value was wrong. Place
  each heading and each Habitat line by folio.
- **The province chapters hide more named stat lines than the Quick Find
  lists.** One-paragraph blocks sit inside "Other Notable Allies" lists and
  "Quick Stats" notes; five NPCs were found only at extraction.
- **An NPC block's attribute order changes between entries** (I.Q., M.E., M.A.
  for Huan Shih, Wu Je Nao, Xian Ya and the Hubei allies; I.Q., M.A., M.E. for
  the Yama Kings). Key each by its label.
- **A family statue prints a rule, not attributes** (the person's attributes,
  +15 to P.S. and Spd), and Qin Kuai's own statue does not follow it. The three
  family statues store no `attributes` and state the rule in `bonuses_note`.
- **Pien Cheng's stored M.D.C. is 250**, the amount he adds to a possessed
  body; his god form (6,700) and spirit form (1,850) are in `bonuses_note`.
