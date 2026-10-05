# Rifts Conversion Book One — survey

**Status:** `imported` — the Palladium Character Conversions section is inventoried and all four batches are in: the nine races the Palladium Fantasy catalog already holds, the seven new humanoids, the eight giants, and the three race occupations with Hand to Hand: Skudasa and the Chant of Dreaming. (2026-09-27)

**Rows citing this book:** classes 37, skills 1, spells 1, creatures 77

Slug `cb1`. Cached from
`595586607-Rifts-Conversion-Book-1-Revised-and-Updated-PAL803P.pdf`,
200 PDF pages, **text layer**.

*Facts about this book, not prose from it — see `book-survey` §7.*

**Backfilled offline on 2026-08-28; the conversions section surveyed on
2026-09-26.** The rest of the book was inventoried from its contents page
(printed 4-5), not page by page.

## Page offset

`page_offset: 1` from `scripts/books.json` — cache file page = printed folio + 1.
`printed_pages: 192`, `cached_range` `p001-p200`, all 200 cached.

**The PDF has 200 pages and the book has 192.** The tail is a Palladium
catalogue and order form the book does not number, so the last folio is 192 (file
p193) and `printed_pages` says 192 rather than 200. `dag` has the same appended
catalogue. **This said 172 until 2026-09-18**: the text layer prints the last
folios with an interior space (`1 91`, `1 92`), and the derived figure stopped
twenty pages short, in the middle of the monster section. The render of file
p193 shows 192.

**Printed 77 (file p078) is a full-page illustration** with no text, which is
why the Wolfen entry reads printed 76, then 78.

## Cache health

`cb1` is the one text-layer cache with no welded pages. It does carry the
Palladium digit cipher (`lD6`, `ID4xlO`, `1 1` for 11) — `substituted_digits`
69 on 2026-09-10 — so every dice figure below was read as the expression it can
only be.

## The book's authority tables

None that an import depends on. The conversions section states every figure
inside each entry; there is no index of races, no experience table (a race takes
its occupation's), and no equipment or money (those come from the O.C.C.).

Two reference tables in the rules chapters are cited by the race entries: the
**Bionic Strength Table** and the **Supernatural Physical Strength Table**
(Rules Clarifications, printed 8-9 per the contents page). A race whose P.S.
"is considered Bionic" or "becomes Supernatural" on Rifts Earth reads its damage
off one of them. The app has no P.S.-class key, so each class says so in prose.

## Inventory

By chapter, from the contents page (printed 4-5). Only the last three rows were
read page by page.

| printed | chapter | imports |
|---|---|---|
| 7-43 | Rules Clarifications & Reference Data — attributes beyond 30, the strength tables, combat notes, pain and damage, Mega-Damage conversions, integrating S.D.C. characters, general conversion rules | nothing: rules reference |
| 43-65 | Heroes Unlimited, Ninjas & Superspies, After the Bomb and Beyond the Supernatural conversions | nothing: conversion advice for other games' characters |
| 66-71 | Magic & Spells; **the Warlock O.C.C.** (66-71) | the Warlock — imported as ten element rows (see Classes) |
| 71-72 | **Elemental Spell Magic** — the Warlock's spell list by element (Air, Earth, Fire, Water) and level, with P.P.E. in parentheses; descriptions deferred to the Book of Magic | names only here; no diff has been run |
| 72-73 | Magic index by book — which book prints each magic discipline | nothing: a cross-reference |
| **73-109** | **Palladium Character Conversions** — 24 race entries and three R.C.C. pointers (table below) | **the subject of this survey** |
| 110-~128 | Faerie Folk | creatures, already imported (see Ledger) |
| ~130-192 | Palladium Monsters & Animals | creatures, already imported |

### Palladium Character Conversions, printed 73-109

Printed 73-74 introduce the section: the races are mortal Hit Point and S.D.C.
beings who need M.D.C. armor, except where an entry states an M.D.C.
transformation; the author's conversion is H.P. + S.D.C. less 20%, and a mortal
with a hundred or more combined points keeps the old 100 S.D.C. = 1 M.D.C.
Printed 74 also gives **the section-wide rule on learning Rifts skills**: within
a few weeks a new arrival picks up the regional language (+5%) and two Modern
W.P.s; after 2D4+4 months or one level, three skills from Communications, Pilot
(basic vehicles), Technical and W.P. Modern; then one language, literacy or skill
from those four every two levels, with others at the G.M.'s discretion. It is
not stored on any class, because it applies to a character who came from
Palladium and not to one raised on Rifts Earth.

Every entry prints alignment, attribute dice, hit points, S.D.C., natural A.R.
where it has one, M.D.C. (or "None"), Horror Factor, P.P.E., size and weight,
natural abilities, attacks per melee, damage (with a Bionic or Supernatural P.S.
note where it applies), bonuses, magic and psionics, life span, **two O.C.C.
lines — one for Palladium Fantasy, one for Rifts** — skills of note, habitat,
enemies and allies.

| printed (file) | entry | on Rifts Earth | Palladium Fantasy row | batch |
|---|---|---|---|---|
| 74-76 (p075-p077) | Bearmen of the North | S.D.C. 2D4x10, A.R. 11, Bionic P.S., H.F. 14 | — | 2 |
| 76-79 (p077-p080) | Canines: Wolfen | S.D.C. 20, A.R. 6, Bionic P.S., H.F. 12 | `wolfen` | **1** |
| 79-80 (p080-p081) | Canines: Coyle | S.D.C. 20, human P.S., H.F. 11 | `coyle` | **1** |
| 80-82 (p081-p083) | Canines: Kankoran | S.D.C. 20, A.R. 6, H.F. 12 | — | 2 |
| 82-83 (p083-p084) | Changelings | S.D.C. by O.C.C. only, H.F. 10 | `changeling` | **1** |
| 83-84 (p084-p085) | Dragonmen | 6D6+20 M.D.C., A.R. 12, Bionic P.S., fire breath | — | 2 |
| 84-86 (p085-p087) | Dwarves | S.D.C. 20 | `dwarf` | **1** |
| 86-87 (p087-p088) | Elves | S.D.C. 10 | `elf` | **1** |
| 87 (p088) | Giants — introduction | | | |
| 87-88 (p088-p089) | Algor, Frost Giant | P.E. + 4D6 M.D.C., frost breath | — | **3** |
| 88-89 (p089-p090) | Cyclops, Lightning Giant | P.E. + 3D6 M.D.C. | — | **3** |
| 90 (p091) | Jotan, Earth Giant | P.E. + 1D6x10+20 M.D.C. | — | **3** |
| 91-92 (p092-p093) | Gigantes, Mutant Giants | 1D6x10 + P.E. M.D.C.; **Gigante Mutation & Special Abilities Table** 91-92, **Gigante Insanity Table** 92 | — | **3** |
| 92-93 (p093-p094) | Minotaur, the Bull | 6D6+18 M.D.C. | — | **3** |
| 93-94 (p094-p095) | Nimro, Fire Giant | 6D6+20 M.D.C. | — | **3** |
| 94-97 (p095-p098) | Rahu-Man; printed 95 is a full-page illustration | 6D6x10 M.D.C.; minor psionics, printed 96 | — | **3** |
| 97-98 (p098-p099) | Titan, Hero Giant | 3D6x10+60 M.D.C. | — | **3** |
| 98-99 (p099-p100) | Goblin, with the **Cobbler Goblin** on printed 99 | S.D.C. 10 | `goblin` | **1** |
| 99-101 (p100-p102) | Gosai; the **Gosai Assassin R.C.C.** pointer and **Hand to Hand: Skudasa** (a 15-level table) on printed 100-101 | S.D.C. 3D6, A.R. 10, metal allergy | — | 2 (race), 4 (R.C.C., Skudasa) |
| 101-102 (p102-p103) | Orc | S.D.C. 10, no psionics | `orc` | **1** |
| 102-103 (p103-p104) | Ogre | S.D.C. 40, Bionic P.S. | `ogre` | **1** |
| 104-105 (p105-p106) | Quillback; the **Quillback Scavenger R.C.C.** pointer on printed 105 | 3D6+12 M.D.C. | — | 2 (race), 4 (R.C.C.) |
| 105-107 (p106-p108) | Quorian; the **Quorian Oneiromancer** and the **Chant of Dreaming** on printed 107 | S.D.C. 25 | — | 2 (race), 4 (R.C.C., chant) |
| 107-108 (p108-p109) | Troll | P.E. + 6D6+12 M.D.C., Supernatural P.S., no psionics | `troll` | **1** |
| 108-109 (p109-p110) | Vrill | P.E. + 2D6+2 M.D.C.; radar | — | 2 |

**24 race entries and three occupation-style R.C.C.s.** Each R.C.C. is a pointer
rather than a stat block: the Gosai Assassin is the Palladium Assassin with
Skudasa in place of Hand to Hand: Assassin and four extra skills in place of its
four W.P.s; the Quillback Scavenger is the Vagabond ("Vagabond Optional O.C.C.",
the Rifts `vagabond`) with added skills;
the Quorian Oneiromancer is a dream shaman built on the Mystic.

## Classes

**Nineteen rows cite this book after batch 1.** The Warlock is ten of them: it
was closed against this book as class-audit item **CB1** in
[#304](https://github.com/NateGrey0130/nates-workshop/pull/304), and is carried
as one row per element and element pair (`warlock-air` through
`warlock-fire-water`); the original `warlock` row is deleted. The other nine are
batch 1 below. **Batch 2 takes it to twenty-six, batch 3 to thirty-four, and
batch 4 to thirty-seven.**

### Batch 1 — the nine races the Palladium Fantasy catalog already holds

Each is a **new class with `system: rifts`**, because a variant cannot cross
systems. **The id is the Palladium id with a `rifts-` prefix** (`rifts-wolfen`,
`rifts-troll`, ...), matching the one existing twin, `rifts-priest`; no
production id ends in `-rifts`. The name is the book's (Wolfen, Troll), as
`mystic` and `nb-mystic` share theirs across systems.

None is a `copy_of` its Palladium row. Every pair differs in more than a short
`except` list could name — natural abilities, the granted skills, the O.C.C.
restrictions and usually a bonus — and several differ in the stats themselves:

| class | differs from the Palladium Fantasy row |
|---|---|
| `rifts-coyle` | S.D.C. 20 (PF 10) |
| `rifts-dwarf` | S.D.C. 20 (PF 15); no `group:magic` bar on Rifts Earth |
| `rifts-goblin` | S.D.C. 10 (PF 5) |
| `rifts-orc` | P.E. 3D6 (PF 3D6+2) |
| `rifts-ogre` | P.S. 4D6+2, P.E. 4D6, P.B. 2D6+2, Spd 3D6+2, S.D.C. 40; **psionics standard** (PF none) |
| `rifts-troll` | an M.D.C. being (P.E. + 6D6+12); S.D.C.-world H.P. +2D6/level, S.D.C. 60, P.B. 2D6 |
| `rifts-wolfen` | Horror Factor save ladder at 4, 8 and 12 |

Decisions every one of them shares:

- **`occ_restrictions` is read from the "O.C.C.s Rifts" line**, never the
  Palladium one. Wolfen, Coyle and Dwarf state none (their Rifts lines allow any
  O.C.C.). The rest name catalog ids; each list's note says what the book said
  and which ids stand for it, and an O.C.C. imported later is not covered until
  it is added — the same posture as the felinoid and lizard-man restrictions.
- **Skills of Note are granted** as `occ_skills`, languages included. Where the
  book gives them to a share of the race (two thirds of Wolfen, 70% of Dwarves,
  90% of Elves) the grant says so. Wolfen, Ogre and Faerie Speak have no language
  row, so they are `Language: Other` with the name in the note.
- **Bionic and Supernatural P.S., natural A.R. and per-skill percentage
  bonuses** (the Coyle's +5% Espionage/Wilderness, the Dwarf's +5% tech, the
  Elf's +2% Wilderness, the Goblin's +2% Rogue) are prose. The app has no key for
  the first two and no race-level per-skill modifier for the third.
- **The Cobbler Goblin is a pick-one group on `rifts-goblin` since `~121`**, the
  page's two bands (01-15 Cobbler, 16-00 ordinary). The book disagrees with
  itself on the odds: one in 20 in the text, 1-15 on percentile in the
  procedure. The Palladium `goblin` row still holds it as prose.
- Horror Factor is the top-level `horror_factor` key, which the Palladium rows
  predate.

### Batch 2 — the seven new humanoids

`rifts-bearman` (named *Bearman of the North*), `rifts-kankoran`,
`rifts-dragonman`, `rifts-gosai`, `rifts-quillback`, `rifts-quorian`,
`rifts-vrill`: seven rows, classes citing this book 19 -> 26. No Palladium
Fantasy row exists for any of them and no production id names them (checked
`--remote`, 2026-09-26), but every one is a Palladium World race that a
Palladium Fantasy import could later claim, so the ids keep batch 1's `rifts-`
prefix. Batch 1's shared decisions hold, with these additions:

- **The Dragonman, Quillback and Vrill are M.D.C. beings on Rifts Earth** and
  take `rifts-troll`'s shape: `mdc_base` as printed, the S.D.C.-world Hit Points
  and S.D.C. in a natural ability rather than pools.
- **The Bearman is not an M.D.C. being.** His 2D4x10 S.D.C. is a pool bonus;
  the 100 S.D.C. = 1 M.D.C. rule the book illustrates with him is prose.
- **Where the Rifts O.C.C. line names what it allows** (Bearman, Dragonman,
  Quillback, Quorian, Vrill) it is an `only` list, with `group:` tokens where
  the line says "any Men at Arms" or "any Psychic"; Kankoran and Gosai are
  `except` lists. Each note says which catalog ids stand for the book's names
  and which names have no row (a plain Ranger, Hunter-Woodsman, Professional
  Thief, Freelance Spy, Smuggler, villager, any Temporal Magic O.C.C.).
  Judgement calls the reconcile pass named and that stand as written: the
  Bearman's "Grunt (equivalent)" is the Coalition Grunt plus the Merc Soldier,
  the Kankoran's "likely never an Operator or Power Armor pilot" is a bar, and
  the Vrill adds the Mystic (its psionics line) and the Healing Shaman (a
  "healer type").
- **The Vrill's radar bonuses are stored**, because the radar is always on and
  the page counts its attack in the Vrill's three; what removes or halves them
  is a natural ability. Its psionics-only-as-Mystic-or-Psi-Healer rule is a
  prose restriction.
- **Dwarven literacy is prose** on the Vrill as on `rifts-dwarf`: the catalog
  has no Dwarven literacy row, and a fixed `Literacy: Other` fails regression.
- The Gosai Assassin, Hand to Hand: Skudasa, the Quillback Scavenger, the
  Quorian Oneiromancer and the Chant of Dreaming are not in these rows; they
  are batch 4.

### Batch 3 — the eight giants

`rifts-algor`, `rifts-cyclops`, `rifts-jotan`, `rifts-gigantes`,
`rifts-minotaur`, `rifts-nimro`, `rifts-rahu-man`, `rifts-titan`. No
Palladium Fantasy row exists for any of them on 2026-09-26, and none is a
`creatures` row; they take batch 1's `rifts-` prefix because a Palladium
Fantasy giant could later arrive. `rifts-cyclops` is unrelated to
`greater-cyclops`, and `rifts-titan` to `titan-juicer` and `sea-titan`.

- **All eight are M.D.C. beings on Rifts Earth**, so each states `mdc_base` and,
  as `rifts-troll` does, carries its S.D.C.-world Hit Points, S.D.C. and A.R.
  as a natural ability rather than pools.
- **The Gigante Mutation & Special Abilities Table is a `choose: 4`** over
  twenty-one `special_abilities` entries, the `keeper-of-the-desert` shape: the
  percentile band heads each entry so the roll can still be made. The flat
  numbers (+20 and +10 M.D.C., +1 attack, +2 initiative) and the two skin
  entries' M.D.C. dice are bonuses; the rest is prose. The **Insanity Table** is
  prose in `side_effects`, since it points into the Rifts RPG's own tables.
- **The Rahu-Man carries a psionics block**: minor, eight Sensitive picks, I.S.P.
  M.E. +30 +1D6 per level.
- **The Cyclops's P.P.E. is added to a magic O.C.C.'s base** on the page, and
  the app keeps a race's `ppe_base` and drops the occupation's, so that sum is
  not modelled; the class says to add the O.C.C.'s by hand.
- **Occupation lists are judgements where the page is loose.** The Gigantes'
  "basic Man at Arms ... simple ones like Raider, Bandit, Vagabond" is an `only`
  of eleven low-tech fighters and drifters; the Minotaur's "any Men of Arms ...
  or any Adventurer or Scholar except Cyber-Doc" is `group:men-of-arms` plus the
  thirty `optional` O.C.C.s other than `cyber-doc`. Each note says so.
- Breath attacks (Algor, Nimro) are prose, not `combat.attacks`, because the
  extra attack can only be a breath.

### Batch 4 — the three race occupations, Skudasa and the Chant

`rifts-gosai-assassin`, `rifts-quillback-scavenger`,
`rifts-quorian-oneiromancer`: three occupations (`category: occ`), classes
citing this book 34 -> 37, plus one skill row and one spell row.

- **Each is its race's own occupation.** `race_restrictions: { only:
  ["rifts-<race>"] }` limits it to its race, and regression's
  `RACE_OWN_TRAINING` list names all three, because no human may take one.
  `fix-cb1-race-own-occupations.sql` adds the Oneiromancer and the Scavenger
  to the Quorian's and Quillback's `only` lists, which could not pair them
  otherwise; the Gosai's list is an `except` list and already allowed the
  Assassin.
- **The Oneiromancer is `copy_of: mystic`** (the RUE Mystic), except
  `psionics`, `magic`, `natural_abilities` and `race_restrictions`: four
  granted powers plus four Sensitive, then one Healing, Sensitive or Physical
  power a level; four spells of levels 1-2, then two a level up to his own
  level; and the Chant granted by name.
- **The Scavenger is `copy_of: vagabond`** (the RUE Vagabond; the page says
  "Vagabond Optional O.C.C.", and `vagabond-peasant` is Palladium Fantasy's),
  except `skills` - Detect Ambush, Detect Concealment and Find Contraband at
  catalog base - and `race_restrictions`. The ladder is the Vagabond's, as the
  page says. The page states nothing but skills and ladder, so the Vagabond's
  O.C.C. bonuses, Eyeball a Fella and money come with the copy; the class's note
  says so.
- **The Gosai Assassin is written out in full** from the Palladium Fantasy
  `assassin`, not a `copy_of`: the pair would differ on `system`, and no
  copy in the catalog crosses systems. Skudasa replaces Hand to Hand: Assassin
  (`costs: {}` - nothing else is sold); one Espionage (never Disguise),
  Military, Rogue and "Scholar" pick replace the four W.P.s, Scholar spanning
  Technical and Science because the catalog has no such category; W.P.s and
  Horsemanship leave the related list. Equipment drops the weapons and - by
  inference from the Gosai's metal allergy, not from this page - the studded
  leather. Money is the Assassin's 200, gold in Palladium Fantasy.
- **Hand to Hand: Skudasa** is a Physical skill row in the other styles' shape,
  `systems` ["rifts"], the fifteen levels in `level_bonuses`
  (`add-cb1-skudasa-and-chant-of-dreaming.sql`, sorting before the class
  scripts; `~023-cb1-skudasa-skill-systems.sql` re-tags it after the scripts
  that clear `skills.systems` on a clean build). "ONLY the Gosai Assassin" is
  its note, as the catalog's other exclusive skills are: **nothing enforces a
  skill's exclusivity**, and a class that states no Hand to Hand price is still
  offered it by the picker.
- **The Chant of Dreaming** is a spell row at level 0 with no tradition, 20
  P.P.E., the shape Wormwood's class-specific prayers take; its success ratio
  is in the description.
- Reconciled against printed 99-101, 105 and 107 by `book-reconcile` with no
  figure in dispute. It flagged the studded leather as an inference, and the
  class now says so.

## Catalog diff

Run for batch 1 by `class-check --remote` on each draft, 2026-09-26: every skill
the nine grant resolves, and no stub rows were needed. The same for batch 2's
seven, 2026-09-26: every skill and every `occ_restrictions` id resolves, no stubs. No spell, psionic or gear
diff has been run; batch 1 needs none. Batch 3's eight, 2026-09-26: every skill,
every psionic category and every `occ_restrictions` id resolves, no stubs.
Batch 4's three, 2026-09-27: every skill, psionic, spell and gear row resolves
except Hand to Hand: Skudasa and the Chant of Dreaming, which the batch adds in
its own catalog script; the stubs `--emit-script` printed for them were removed.

## Extraction plan

Agreed 2026-09-26. One PR each, in order.

1. **The nine races the Palladium Fantasy catalog holds** — Wolfen, Coyle,
   Changeling, Dwarf, Elf, Goblin (with the Cobbler as a pick since `~121`), Orc, Ogre, Troll.
   *Shipped, this PR.*
2. **The seven new humanoids** — Bearman, Kankoran, Dragonman, Gosai, Quillback,
   Quorian, Vrill. `rifts-` ids only if Palladium Fantasy rows for them could
   later exist; check the catalog first. The Dragonman, Quillback and Vrill are
   M.D.C. beings on Rifts Earth; the Bearman is the book's example of a 100
   S.D.C. = 1 M.D.C. mortal. *Shipped, with `rifts-` ids; see Batch 2.*
3. **The eight giants** — Algor, Cyclops, Jotan, Gigantes, Minotaur, Nimro,
   Rahu-Man (with its minor psionics, printed 96) and Titan, all M.D.C. beings on
   Rifts Earth. The **Gigante Mutation & Special Abilities Table** (printed
   91-92) is a roll table, not stats; decide there whether it is prose on the
   class or a modelled roll. The Gigante Insanity Table (92) points into the Rifts
   RPG's tables. *Shipped — see Batch 3 above.*
4. **The three R.C.C. pointers and what they bring** — the Quorian Oneiromancer
   (`copy_of: mystic` if its except list stays short), the Quillback Scavenger
   (built on the Vagabond), the Gosai Assassin (built on the Palladium Assassin),
   plus **Hand to Hand: Skudasa** as a skill row usable only by the Gosai
   Assassin and the **Chant of Dreaming** as a spell or ability row. Needs
   batch 2's races first. *Shipped — see Batch 4 above.*

**Left out, with reasons:** the rules chapters and the other-game conversion
chapters (rules reference, no rows); the magic index (a cross-reference); the
Elemental Spell list's descriptions, which the book defers to the Book of Magic
(`bom` is the authority for those rows). The section-wide skill rule on printed
74 stays prose until someone asks for it to be modelled.

## Ledger

| date | PR | what went in |
|---|---|---|
| — | — | cached, 200 pages |
| — | [#304](https://github.com/NateGrey0130/nates-workshop/pull/304) | the Warlock closed against this book (class audit CB1) |
| 2026-08-27 | [#337](https://github.com/NateGrey0130/nates-workshop/pull/337) | `cb1` registered in `books.json` |
| 2026-08-28 | — | this file, backfilled offline |
| 2026-09-18 | [#1170](https://github.com/NateGrey0130/nates-workshop/pull/1170) | 77 creatures (NPC & bestiary plan, Phase 3) |
| 2026-09-26 | #1443 | conversions section surveyed; batch 1, nine Rifts race classes (`rifts-wolfen`, `rifts-coyle`, `rifts-changeling`, `rifts-dwarf`, `rifts-elf`, `rifts-goblin`, `rifts-orc`, `rifts-ogre`, `rifts-troll`); classes citing this book 10 -> 19. Applied `--remote` before the merge |
| 2026-09-26 | #1449 | batch 2, seven new Rifts race classes (`rifts-bearman`, `rifts-kankoran`, `rifts-dragonman`, `rifts-gosai`, `rifts-quillback`, `rifts-quorian`, `rifts-vrill`), reconciled against the book with no figure in dispute; no stub rows; classes citing this book 19 -> 26. Applied `--remote` before the merge |
| 2026-09-26 | #1452 | batch 3, the eight giants (`rifts-algor`, `rifts-cyclops`, `rifts-jotan`, `rifts-gigantes`, `rifts-minotaur`, `rifts-nimro`, `rifts-rahu-man`, `rifts-titan`); classes citing this book 26 -> 34. Applied `--remote` before the merge |
| 2026-09-27 | #1457 | batch 4, the three race occupations (`rifts-gosai-assassin`, `rifts-quillback-scavenger` as `copy_of: vagabond`, `rifts-quorian-oneiromancer` as `copy_of: mystic`), the skill row Hand to Hand: Skudasa and the spell row Chant of Dreaming; the Quorian and Quillback opened to their occupations; reconciled with no figure in dispute; classes citing this book 34 -> 37, skills 0 -> 1, spells 0 -> 1. Applied `--remote` before the merge |
| 2026-10-04 | `pal/data/retro-a12-small-corrections` | **The Cobbler Goblin is a pick** (`~121`): `rifts-goblin`'s one hand-applied natural ability becomes a pick-one group of printed 99's two bands. The Cobbler option adds +1 to save vs all magic and +1 vs possession; its P.P.E. (which replaces the Goblin's), its +3 vs Horror Factor (the page does not say whether it joins the Goblin's +2) and its three skill bonuses stay by hand, in the option's text. Printed 98-99 re-read off a render: nothing in the class disagreed. No row count moves. Applied `--remote` before the merge. |
| 2026-10-04 | `pal/data/retro-a13-category-bonuses` | **Related-skill category bonuses that lived only in a note now apply** (`~122`, `~123`): 1 of this book's classes (`rifts-gosai-assassin`). `categoryBonus` reads an entry's `bonus` key and nothing else, so a bonus written only in the entry's note reached no character. A plain one gains the key; a bonus for part of a category gains a second entry naming those skills (`BOOK-INGEST-AUDIT` F109's shape). Taken from each class's own stored note; no page was reopened. No row count moves. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-c2-roll-tables` | **The Rifts Gigante Insanity Table is a pick** (`~161`, close-out package C2): nine bands on printed 92, rolled once; the Hyper-Aggressive row's +1 initiative, which the page prints without a condition, is applied. Read off a render and checked by `book-reconcile`. No rows added. Applied `--remote` before the merge. |
| 2026-10-05 | `pal/data/retro-c2-roll-tables` | **The Rifts Gigante mutation table is rolled four times** (`~162`, close-out package C2; `BOOK-INGEST-AUDIT` F120): the `choose: 4` group of 21 options becomes `rolls: 4` with every option named for its band (printed 91-92), and the additional leg's +1D4x10 Spd, printed without a condition, is stored. The page says nothing about a repeated result. Checked by `book-reconcile`. No rows added. Applied `--remote` before the merge. |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-09-26, before batch 1
was applied:

```
  cb1                 87 / 0
```

**87 traceable, nothing untraceable** — ten Warlock rows and 77 creatures.
Batch 1 takes it to 96, batch 2 to 103, batch 3 to 111 and batch 4 to 116.
**Nothing remains to take** from the extraction plan. Left out on purpose: the
chapters listed under *Left out, with reasons* above.

**After the retrospective close-out, 2026-10-05** (Phase C; `node scripts/source-coverage.mjs --remote` the same day: `cb1 116 / 0`). Nothing on the retrospective's list is left for this book. The Gigante tables are rolled; the page says nothing about a repeated result.
