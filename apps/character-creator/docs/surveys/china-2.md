# Rifts World Book 25: China 2 — survey

**Status:** `imported` — all seven steps shipped: skills, Chi-Gung powers, gear, vehicles and all 25 classes; what was left out on purpose is under Extraction plan. (2026-10-02)

**Rows citing this book:** classes 25, gear 94, psionic_powers 29, skills 37, vehicles 6

**MOS:** geofront-lightning-warrior 8, geofront-shadow-warrior 8, geofront-technical-officer 7, geofront-whack-job-scientist 7

Slug `china-2`. Cached 2026-10-01 from
`Rifts- World Book 25 China 2 Heroes of the Celestial Court.pdf`, 162 PDF
pages, **scan (no text layer)**, OCR at 300 dpi, psm 3. `--probe` read 0
characters on all 20 sampled pages. The page images are 150 dpi natively, so
the OCR runs on an upsample.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

This is the second of two China books. **World Book 24 (China 1, The Yama
Kings) is not registered or cached.** It holds the demons, goblins and the Yama
Kings; this book holds the heroes, the martial arts, the Geofront and their
gear. This book defines **no creature and no spell**, and refers to book one
for every demon its classes fight, bind or play.

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`.

Checked by reading the folio rather than trusting the vote:

| cache page | folio printed on it | read from | offset |
|---|---|---|---|
| `p004` | 3 | render | +1 |
| `p005` | 4 | render | +1 |
| `p014` | 13 | render | +1 |
| `p016` | 15 | OCR text | +1 |
| `p026` | 25 | OCR text | +1 |
| `p103` | 102 | OCR text | +1 |
| `p153` | 152 | OCR text | +1 |
| `p161` | 160 | render | +1 |

One region, no `page_offset_exceptions`. **`printed_pages` is 160**, the
Experience Tables. The cache manifest says 158 because the OCR lost the last
folios; the registry is right. Cache `p001`-`p004` are cover and credits,
`p005`-`p006` the Contents and Quick Find, `p162` the back cover.

## Cache health

A scan, so the manifest carries none of the three text-layer keys
(`welded_pages`, `corrupt_pages`, `substituted_digits`). What was measured
instead:

- Median 5,216 bytes of text per cached page. Stat-block labels survived
  (`Attribute Requirements`, `O.C.C. Skills`, `I.S.P. Cost`, `M.D.C. by
  Location`, `Mega-Damage`, `Payload`, `Cost` all count cleanly per page).
- **Nine cache pages are empty or near-empty, and every one is a full-page
  art plate**: p007, p043, p050, p079, p088, p116, p123, p134, p153 (printed
  6, 42, 49, 78, 87, 115, 122, 133, 152). Checked on a contact sheet. p047
  (printed 46) is mostly art with a few lines of text. No text was lost.
- **Level ordinals are damaged throughout the martial arts pages** (printed
  19-41): superscript `th`/`nd`/`rd` read as quote marks, asterisks or
  nothing, and a few level numbers dropped entirely. **Every level table on
  those pages must be read off a render**, not the cache.
- Ordinary digit damage in dice exists (an `8` read for a `6` on printed 15).
  Read each die expression as the dice it must be, and check it on the render.
- Curly quotes, em-dashes and a replacement glyph for apostrophes are
  throughout. Strip them before any SQL.

## The book's authority tables

| cache page | printed | table | settles |
|---|---|---|---|
| **p005-p006** | 4-5 | *Contents* and *Quick Find* | the printed page of every class, martial art, power group, magic item group and Geofront section. The Quick Find repeats the classes under their translated names, a second reading of those pages |
| **p011-p014** | 10-13 | *Complete List of Western Skills* | a reprint list of the core skills with base figures, asterisking those from other world books. Not this book's skills. Use it only to see which core skill a class means |
| **p014-p015** | 13-14 | *New China Skills List* and the *Ancient Chinese Weapon Proficiencies* list | the **41 skills this book adds**, by category, each with base and per-level figures. Descriptions run printed 14-19 and restate the figures: two readings of every number |
| **p020** | 19 | *List of Hand to Hand Martial Arts* | the 7 hand-to-hand styles, one Basic (Tai Chi) and six Advanced |
| **p026** | 25 | *List of Mystic Martial Art Powers* | the 11 mystic martial art powers (a twelfth line is a cross-reference from an alternate spelling of Tien-Hsueh). The back cover counts twelve; the list and the chapter hold eleven |
| **p044** | 43 | *Listing of Rifts China O.C.C.s* | the 12 Celestial Court classes in five groups |
| **p093** | 92 | *List of Exercises* | the 11 Demon Queller Mystic Body Hardening Exercises |
| **p122, p129** | 121, 128 | the two Geofront O.C.C. lists | the 13 Geofront classes: six standard military, seven elite |
| **p161** | 160 | *Experience Tables* | **10 ladders naming all 25 classes** (the Geo-Borgs share one line) |

The Experience Tables and the two class lists agree: every class the lists
name has a ladder, and no ladder names a class the book does not define.
Unlike `japan` and `new-west`, there is no NPC-only class hiding behind a
ladder here.

## Inventory

Counted by structure (stat-block markers and headings) over all 162 cached
pages, with the Contents read off a render.

| section | printed | what is there |
|---|---|---|
| Introduction, definitions, money | 7-10 | lore. No stat blocks |
| Western skill list (reprint) | 10-13 | a list, not new skills |
| New China skills | 13-19 | **41 skills**: 7 Domestic, 2 Medical, 10 Physical (Demon Wrestling, Fasting, Meditation and the 7 hand-to-hand styles), 5 Rogue, 13 Technical, 4 Ancient W.P.s |
| Hand to Hand martial arts | 19-25 | **7 styles**, each with a level 1-15 advancement table: Tai Chi, Dog Boxing, Drunken Style, Eighteen Weapons, White Jade Fan, Monkey Style, Shao-Lin. Three fans priced as weapons under White Jade Fan (printed 23); a list of Monkey Moves (24) |
| Mystic Martial Art Powers | 25-41 | **11 powers**, each a level 1-15 advancement table of named sub-abilities, I.S.P. and S.D.C. additions: Ba Gua, Bok Pai (Crane), Gui Long (Dragon Blade), Hsien Hsia, Mien-Ch'uan (Cotton Fist, with a list of specialty attacks), Pao Chih (Animus), She Shen (Snake, with a list of Arts of Invisibility), Tien-Hsueh (Touch Mastery, with a list of touch powers), Tong Lun (Praying Mantis), Xian Pu (Drunken Style), Xian Tai Chi Chuan (Chi Manipulation) |
| Celestial Court warriors | 43-51 | **3 O.C.C.s**: Jian Shih, Chun Tzu, Nei Chia Wu Shih |
| Mystic monks | 52-62 | **2 O.C.C.s**: Wai Chia Wu Shih, Chi-Gung Seng Ren; and the **29 Chi-Gung powers** (printed 56-62), each with range, duration and an I.S.P. cost |
| Diviners | 62-76 | **3 P.C.C.s**: Soothsayer, Spirit Host, Blind Mystic. The Soothsayer's tools (printed 65-66); the Spirit Host's animal spirits (69-71) |
| Demon Quellers | 77-91 | **3 O.C.C.s**: Fu Yao Da Chia (Great Demon Catching Hero), Demon & Dead Slaver, Goblin Wrangler. The Demon Hunter Sword and the Book (printed 80); Green Scarf demon hunting gear (84) |
| Body hardening, secrets, tricks | 92-95 | **11 body hardening exercises** (92-94); demon traits and tricks of the trade (94-95), which are play advice with no numbers |
| Enlightened Demon R.C.C. (optional) | 96-101 | **1 R.C.C.** A reformed Lesser Demon, whose demon type and base statistics are in book one |
| Green Scarf magic items | 101-114 | **about 44 items**: 16 binding items, 2 fans, 5 pearls, 7 scarves, 12 swords and weapons (with a bone weapon damage table, and the Sword of Demon Hunting in four types), Demon Armor in partial and full. Most carry a price |
| The Geofront | 116-121 | lore and statistical data for the nation |
| Geofront military O.C.C.s | 121-127 | **6 O.C.C.s**, each a short delta on a Coalition class: Chi Warrior, Chi Commando, Military Specialist, Scout/Ranger, Technical Officer, Whack Job Scientist. The Mystic Consultant (127) is a role, not a class |
| Elite Geofront forces | 128-141 | **7 O.C.C.s**: Demon-Eater Geo-Borg, Assault Geo-Borg, Lion Geo-Borg, Lightning Warrior, Metal Warrior, Shadow Warrior, Gun Master. The three Geo-Borgs carry M.D.C. by location and built-in weapons |
| Geofront guns | 142-147 | **7 guns** (G-91, GHT-85, GHF-AK47, GHT-88, GHT-89, GHT-93, GHT-95), **5 special ammunition types** shared by two of them, and **4 Chi Demon Weapons** |
| Geofront body armor | 148-150 | **5**: Standard Brigandine, Heavy Brigandine, Shadow Armor, Demon Skin, Demon Skin Armor |
| Power armor and robot | 150-156 | **3**: Black Tiger, Red Falcon, Gun Dragon |
| Vehicles of note | 156-159 | **3**: a military scout motorcycle, the PC-86 Police Cruiser, the AB-101 Air Barge |
| Experience Tables | 160 | 10 ladders |

### Things this book has zero of, checked rather than assumed

- **Spells.** One `P.P.E.:` line in 162 pages, and it is a rule about halving a character's
  P.P.E. in the Modifying Characters section on printed 141. No spell block anywhere.
- **Creatures and named NPCs.** No creature stat block. Every demon is in
  book one.
- **Psionic powers in the core sense.** The only `I.S.P.`-costed blocks are
  the 29 Chi-Gung powers, which belong to one class.

## Classes

### Playable (25)

| class | printed | XP ladder (p161) |
|---|---|---|
| Jian Shih O.C.C. | 43-45 | Jian Shih, Gun Master, Spirit Host |
| Chun Tzu O.C.C. | 45-48 | Wai Chia Wu Shih, Chun Tzu |
| Nei Chia Wu Shih O.C.C. | 48-51 | Enlightened Demon, Chi-Gung Seng Ren, Nei Chia Wu Shih |
| Wai Chia Wu Shih O.C.C. | 52-54 | Wai Chia Wu Shih, Chun Tzu |
| Chi-Gung Seng Ren O.C.C. | 54-62 | Enlightened Demon, Chi-Gung Seng Ren, Nei Chia Wu Shih |
| Soothsayer P.C.C. | 63-67 | Demon Catching Hero, Soothsayer, Shadow Warrior |
| Spirit Host P.C.C. | 67-72 | Jian Shih, Gun Master, Spirit Host |
| Blind Mystic P.C.C. | 72-77 | Blind Mystic, Chi Commando, Lightning Warriors |
| Fu Yao Da Chia O.C.C. | 77-83 | Demon Catching Hero, Soothsayer, Shadow Warrior |
| Demon & Dead Slaver O.C.C. | 83-86 | own |
| Goblin Wrangler O.C.C. | 86-91 | Goblin Wrangler, Metal Warrior, Whack Job Scientist |
| Enlightened Demon R.C.C. | 96-101 | Enlightened Demon, Chi-Gung Seng Ren, Nei Chia Wu Shih. The book marks it optional |
| Chi Warrior O.C.C. | 123 | own |
| Chi Commando O.C.C. | 123-124 | Blind Mystic, Chi Commando, Lightning Warriors |
| Geofront Military Specialist O.C.C. | 124 | Technical Officer, Military Specialist, Geo-Borgs |
| Geofront Scout/Ranger O.C.C. | 124-125 | own |
| Geofront Technical Officer O.C.C. | 125-126 | Technical Officer, Military Specialist, Geo-Borgs |
| Whack Job Scientist O.C.C. | 126-127 | Goblin Wrangler, Metal Warrior, Whack Job Scientist |
| Demon-Eater Geo-Borg O.C.C. | 128-130 | Technical Officer, Military Specialist, Geo-Borgs |
| Assault Geo-Borg O.C.C. | 130-131 | Technical Officer, Military Specialist, Geo-Borgs |
| Lion Geo-Borg O.C.C. | 131-132 | Technical Officer, Military Specialist, Geo-Borgs |
| Lightning Warrior O.C.C. | 132-134 | Blind Mystic, Chi Commando, Lightning Warriors |
| Metal Warrior O.C.C. | 134-135 | Goblin Wrangler, Metal Warrior, Whack Job Scientist |
| Shadow Warrior O.C.C. | 135-136 | Demon Catching Hero, Soothsayer, Shadow Warrior |
| Gun Master O.C.C. | 136-141 | Jian Shih, Gun Master, Spirit Host |

**Collisions to check at import.** `demon-queller` is Japan's class; this
book's Demon Quellers are a group of three classes with their own names, so no
id collides, but none may be named plain Demon Queller. `monk`, `ranger`,
`crazy`, `mystic` and `rifts-goblin` are taken; use the book's own names or a
`geofront-` form.

### The Geofront classes are deltas on Coalition classes

Nine of the thirteen state their skills as the same as a named Coalition
class plus additions. Production holds the base for most of them:

| this book's class | says same as | production holds |
|---|---|---|
| Chi Warrior | CS Grunt | `coalition-grunt` |
| Chi Commando, Shadow Warrior (related skills) | CS Commando | `cs-commando` |
| Scout/Ranger | CS Ranger | `cs-ranger` |
| Technical Officer | CS Technical Officer | `coalition-technical-officer` |
| Whack Job Scientist | CS RCSG Scientist | `cs-rcsg-scientist` |
| Shadow Warrior, Lightning Warrior (skills) | CS Special Forces | `cs-special-forces` |
| Lightning Warrior (related skills) | the core Crazy | `crazy` |
| Metal Warrior | CS Elite RPA SAMAS Pilot (the book says see the Rifts RPG) | `coalition-samas-pilot`, RUE's - **not** `cs-rpa-fly-boy-ace`, Coalition War Campaign's aircraft pilot. Read off RUE's page, because the production row disagrees with it (2026-10-02) |
| Demon-Eater Geo-Borg, Assault Geo-Borg | CS Heavy Cyborg, CS Light Cyborg | **`cs-cyborg-strike-trooper`'s heavy and light variants** (Coalition War Campaign p.69-70); printed 128 heads the section with that class's name. Found 2026-10-02 |
| Geofront Military Specialist | CS Military Specialist | **not in production.** Coalition War Campaign (cache `p068`) points to the core book for it, and the core book defines it (`rue` cache `p238`). It was never imported |

A class here is written out in full from its base (see `declared-copy-pairs`
in memory: a same-as class ships a full copy), so a missing base is a class
that cannot be completed until the base is found.

## Catalog diff

Run against **production** (`--remote`) on 2026-10-01.

**No production row cites this book**: 0 skills, 0 spells, 0 psionic powers,
0 creatures. Name sweeps of `imported_classes`, `gear` and `vehicles` for this
book's class, item and machine names found no overlap.

### skills: 41 entries, 37 reported missing, 1 of them a false gap

`node scripts/catalog-diff.mjs --remote --table skills --entries <41 entries> --compare base,per_level`
returns **matched 0, disagree 4, missing 37** (426 catalog rows).

Hand-checked:

| book prints | catalog holds | verdict |
|---|---|---|
| Wei Qi/Go, 30% +5% | `Go`, 30 +5 (Japan p.187) | **false gap.** The same game at the same figures. No new row; a class naming it takes `Go` |
| Fasting, 54% +4% | `Fasting`, 40 +3 (RUE) | this book's figure differs from RUE's. **Not a correction**; RUE stays, as with Japan's reprints |
| Begging, 8% +1% | `Begging`, 30 +3 (RUE) | same. RUE stays. The gap is large enough to re-read on the render before deciding |
| Calligraphy, 25% +5% | `Calligraphy`, 35 +5 (RUE) | same. RUE stays |
| Literacy: Chinese, 55% +5% | matched by alias to `Language: Chinese` (Mystic Russia) | **wrong match.** Literacy is not Language. A new row, or the catalog's general literacy skill; decide at import |
| Demon Wrestling | nearest `Wrestling` | new row; a different skill with its own moves and bonuses |
| Chinese Herbal Medicine | `Holistic Medicine` exists | new row; the book says it is equivalent but prints its own figures |
| Chinese Antiquarianism | `Antiquarian` exists | new row; a China-specific skill |
| W.P. Bamboo Staff, W.P. Chiang Zhu Spear | `W.P. Staff`, `W.P. Spear` exist | new rows; the book makes them separate proficiencies |

**Genuinely new: 37 skills**, Literacy: Chinese among them (agreed
2026-10-01). That is 41 less Go and the three RUE reprints. Seven of them are hand-to-hand styles,
stored as `skills` rows with `level_bonuses` as Japan's eight are.

### psionic_powers: 29 Chi-Gung powers, 29 missing, 0 false gaps

`node scripts/catalog-diff.mjs --remote --table psionic_powers --entries <29 entries>`
returns **matched 0, missing 29** (156 catalog rows). Nearest names are
unrelated (`Exorcism`, `Psychic Purification`); none is the same power.

The table's categories today are Healing, Physical, Sensitive, Super, Phase,
Mind Bleeder and Special. `phase-world` set the precedent of a book-specific
category for a class's own I.S.P. powers; a `Chi-Gung` category would follow
it. **Agreed 2026-10-01: they go in `Special` instead**, and no category is
added.

### gear, vehicles, classes

Not diffed row by row: nothing cites this book and the name sweeps found no
overlap. **Re-run `catalog-diff --remote` per batch before each data script**
(§4). Three other book sessions are live today.

## Extraction plan

Phase 4 costs money; everything above was free. Proposed order, gear before
the classes that carry it:

1. **Skills** — 37 new rows, Literacy: Chinese among them, printed 13-25. The
   7 hand-to-hand styles with their level tables, read off renders. One PR.
2. **Chi-Gung powers** — 29 `psionic_powers` rows, printed 56-62, in the
   existing `Special` category. One PR.
3. **Green Scarf magic items** — about 44 gear rows, printed 101-114, plus
   the three fans of printed 23 and the Soothsayer's tools of 65-66. One PR.
4. **Geofront gear** — 7 guns, ammunition, 4 Chi weapons, 5 armors, printed
   142-150. One PR.
5. **Geofront machines** — 3 power armor and robot rows and 3 vehicles,
   printed 150-159, in the `vehicles` tables. One PR.
6. **Celestial Court classes** — 12 classes, printed 43-101, the Enlightened
   Demon among them. Two PRs.
7. **Geofront classes** — 13 classes, printed 121-141, once every Coalition
   base is confirmed. One or two PRs.

What is deliberately left, with the reason for each:

- **Setting lore** (7-10, 116-121) — no rows.
- **The Western skill list** (10-13) — a reprint index.
- **Demon traits and tricks of the trade** (94-95) — play advice, no numbers.
- **The Mystic Consultant** (127) — a role any outside class fills.
- **Divination guidance for Game Masters** (62-63) — advice.

### Agreed with Nate, 2026-10-01

1. **Mystic Martial Art Powers: file the gap, import level 1.** A class
   that takes one of the 11 powers states that power's level-1 abilities.
   The later levels are not built and not written out per class. The gap is
   filed in `BOOK-INGEST-AUDIT.md` when the first class batch meets it, and
   each row or class says what was dropped (`book-survey` §8).
2. **Body hardening exercises: the same.** Level-1 picks in, the rest filed.
3. **Enlightened Demon R.C.C. goes in now**, with its demon form in prose,
   not held for China 1.
4. **Literacy: Chinese is a new skill row**, not `Language: Chinese` and not
   the general literacy skill.
5. **Chi-Gung powers go in the `Special` psionic category.** No new category.
6. **The Coalition bases are assumed to be in a book already held**, most
   likely a Coalition one. Checked the same day: the Military Specialist is
   the core book's (`rue` cache `p238`) and is not in production. The Heavy
   and Light Cyborg bases are still to be located; look in `rue` and `cwc`
   before step 7. A base that is printed but was never imported is imported
   first, as its own class.

   **Adjusted 2026-10-02 (branch `pal/data/china-2-classes`):** the Heavy and
   Light Cyborg are the heavy and light variants of `cs-cyborg-strike-trooper`
   (see *The Geofront classes are deltas*). The CS Military Specialist was
   **not** imported as its own class, contrary to the last sentence above: the
   Geofront Military Specialist is written out in full from RUE's printed
   235-236, which is all its own class needed, and importing the CS one is
   separate work. Two base rows turned out to disagree with their own pages -
   `coalition-grunt` is a stub and `coalition-samas-pilot` carries the next
   class's attribute requirements - so those Geofront classes were read off
   the RUE renders rather than copied from the rows. Both are flagged as
   separate tasks, not fixed here.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-10-01 | `pal/data/china-2-survey` | cache built (162 pp, scan, OCR 300 dpi), offset +1 verified at eight folios, `china-2` registered in `books.json`, this survey. No rows. Written in its own worktree while three other book sessions were live. |
| 2026-10-01 | `pal/docs/china-2-decisions` | the six decisions Nate settled, recorded under *Agreed with Nate*; the plan's steps 1, 2 and 6 and the status line follow them. No rows. |
| 2026-10-02 | `pal/data/china-2-skills` | step 1: 37 skills (`add-a-china-2-skills.sql`, tagged by `~069-china-2-skill-systems.sql`): 26 Domestic, Medical, Physical, Rogue and Technical skills, the four Ancient Chinese W.P.s, and the seven Hand to Hand styles with their level tables, every figure read off a render. Go, Fasting, Begging and Calligraphy are not duplicated. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/china-2-powers-gear-vehicles` | steps 2-5 in one PR: 29 Chi-Gung powers in `Special` (`add-a-china-2-chi-gung-powers.sql`); 68 Green Scarf magic items, Soothsayer tools, the Book of Ten Thousand Demons and the five fans (`add-a-china-2-magic-gear.sql`); 26 Geofront guns, rounds, Chi weapons and armors (`add-a-china-2-geofront-gear.sql`); 6 vehicles with 62 M.D.C. locations and 22 weapon entries (`add-china-2-vehicles.sql`). Five extraction workers and five reconcile passes; reconcile moved a restriction from Mystic Body to Lightning Fists, stopped the Demon Skin storing 4 M.D.C. from its 4D6+18, and corrected four descriptions. Applied `--remote` before the PR. |
| 2026-10-02 | `pal/data/china-2-classes` | steps 6-7 in one PR: all 25 classes, one `add-<id>-class.sql` each - `jian-shih`, `chun-tzu`, `nei-chia-wu-shih`, `wai-chia-wu-shih`, `chi-gung-seng-ren`, `soothsayer`, `spirit-host`, `blind-mystic`, `fu-yao-da-chia`, `demon-and-dead-slaver`, `goblin-wrangler`, `enlightened-demon` and the thirteen `geofront-*` classes. Eight drafting agents from one shared brief; every class reads `ready` against production with 0 stubs, and every XP ladder was checked against printed 160. Mystic Martial Art Powers and Body Hardening Exercises are level 1 only, from two shared blocks pasted into each class (Nate, 2026-10-01); filed as `BOOK-INGEST-AUDIT.md` F117, with the exercises' later picks under F116. A native Chinese speaker is `Language: Native Tongue` throughout; the Enlightened Demon, who learns it, has `Language: Chinese`. Applied `--remote` before the PR. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-10-01: the book has no line
in the per-book report, because no row cites it. That run's `BACKLOG` block,
recorded so a later import can tell what it moved:

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            14   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           19   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

None of these is this book's.
