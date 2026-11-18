# Rifts World Book 21: Splynn Dimensional Market — survey

**Status:** `surveyed` — cached, inventoried and diffed against production; nothing imported yet. The plan is under *Extraction plan*. (2026-11-18)

**Rows citing this book:** none

Slug `splynn`. Cached 2026-11-18 from
`Rifts- World Book 21 Splynn Dimensional Market.pdf`, 194 PDF pages, **text layer** (`--probe` median 3,349 chars/page, 38.3% stop
words).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read from `scripts/books.json`**, where this survey's PR registers it.

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. One region, no exceptions.

| cache page | folio printed on it |
|---|---|
| `p008` | 7 |
| `p072` | 71 |
| `p163` | 162 |
| `p192` | 191 |

`printed_pages` is 191, the last numbered folio. Cache `p193` is an
advertisement and `p194` the back cover.

Text-layer damage, by cache page (the manifest's three keys):

- welded: none.
- glyph-corrupt: 103, one glyph. It is printed 102, the first page of the new
  magic tattoos; the glyph is punctuation in the first entry, and the two
  P.P.E. figures on the page were confirmed on a render.
- digit-substituted: 63 pages, from 22 to 188. Every stat block in the book
  sits on one. The usual tokens are a `1` set as `!` or `l` and a `0` set as
  `O`, so a dice expression is read as the one it can only be. Two shapes are
  worse than usual: a leading `1D` set as `10` (`106x10` is 1D6x10, on printed
  45, 47, 71 and 80), and `I.S.P.` welded to the figure before it (`301.S.P.`
  is 30 I.S.P., on printed 23, 125 and 144).

Pages with no text, each confirmed as full-page art on a render or thumbnail:
printed 12, 43, 46, 48, 52, 60, 69, 70, 91, 99, 110, 132, 155 and 165.
Printed 174 has only its folio in the layer and was not viewed.

Three pages interleave two blocks and are read off a render: printed 111 (the
experience table and a racial breakdown), 142 (two rifles' stat lines) and 171
(two guns' stat lines, which arrive after both descriptions with no heading).

**One figure is wrong in the ink.** Printed 109 (the Tattooed Archer's
bonuses) and 160 (the enhanced-speed result in augmentation table five) both
give a bonus to Spd as the two digits 44, on the render as well as in the
layer. Every neighbouring bonus is a single signed digit. See *Extraction
plan*.

The book spells one race two ways. The headings on 90-97 and almost all of the
running text print Staphra; the Contents and two lines (63, 90) print
Straphra. The headings win.

## The book's authority tables

| page | table | states |
|---|---|---|
| **4-5** | Contents | every section, merchant, R.C.C. and vehicle by name and page; it lists only six of the nineteen parasites and five of the eleven symbiotes, and tags two New Slave Stock entries as animals |
| **112** | parasite list | the nineteen parasites by name, alphabetical, at the head of their section |
| **128** | symbiote list | the eleven symbiotes by name, alphabetical |
| **111** | T-Archer O.C.C. experience table | fifteen levels; level 7 opens at 46,001 while level 6 closes at 46,500 (the book's own slip, confirmed on a render) |
| **190** | experience table for Full Conversion Bio-Borgs | fifteen levels, 0 to 2,200 at level one and 400,001 to 500,000 at level fifteen; the table the True Bio-Borg, the Staphra Warlord and the Monster Were-Dragon all point at |

The two organism lists are the ones to count from; the Contents is a selection.
No list of the magic tattoos is printed apart from their descriptions, so the
23 are counted off the pages. Costs and P.P.E. figures are printed once, in
each entry.

Every other R.C.C. names a ladder held from another book: Dog Boy (Kryygorth
Hunter), Dragon (Kryygorth's Lesson, the Plant-People, the Pythonan),
Psi-Stalker (Kryygorth Pegasus, the Were-Dragon), Rogue Scholar (Rulian
Translator), Headhunter (Staphra Warrior), Mystic (Staphra Mystic), and the
chosen O.C.C.'s own (Octoman).

## Inventory

Counted from four readers' passes over all 191 printed pages, by stat-block
shape, not by prose.

| section | printed pages | what is there |
|---|---|---|
| The market, its law and its trade | 7-19 | prose; population percentages (10); defect and swindle rules for merchandise (14-16) |
| Notable merchants | 19-42 | **6 full NPC blocks** (Water Merchant 21, Old West 23, Rassa 24-25, K'Rynn Katar 26-27, Dionna 28, the Re-Animator 32-33); **1 sketch that meets the row rule** (Crazy Al, 38-39); about fifteen more named proprietors with a level or less; **16 priced items with game figures** (eight timepieces 30-31, three leather armour tiers 34, and five consumables or charms on 21, 27, 28-29, 29 and 36); price lists for services and living stock |
| Palace, Bio-Wizard Center, Stables, Arena | 42-49 | prose; the slave price table (45-47); five arena champions as paragraphs with partial figures (49) |
| Life outside the market | 50-53 | prose |
| The Authorities | 54-59 | **3 full NPC blocks** (High Lord T'Lan 54-55, Powerlord Cronus 55-56, Ren the Hunter 56-58); D-Squad as an organisation, no member statted |
| The Liberated Underground | 59-71 | **4 full NPC blocks** (Max 63-65, Sergeant Beta 65-67, Skippy 67-68, White Raven 68 and 71) |
| New Slave Stock | 71-101 | **2 animals** (Demonrunner 71-73, Kryygorth Shellback 79-80) and **12 R.C.C. blocks**: Kryygorth Hunter 73-75, Kryygorth's Lesson 75-77, Kryygorth Pegasus 77-79, Octoman 80-82, Nurilian Plant-People 82-85, Pythonan 85-87 with a scholar and artist sub-block on 87, Rulian Translator 87-90, Staphra Warrior 92-93, Warlord 93-95 and Mystic 95-97, Were-Dragon 97-101 with a Monster form inside the same block |
| New Magic Tattoos | 102-107 | **23 tattoos**: 2 magic weapon (102-103), 10 power (103-104), 11 Power Arrows (105-106); two more the archer must hold are described in the rules on 104-105 with no entry of their own |
| Tattooed Archer O.C.C. | 108-111 | **1 class**, with its own experience table |
| Bio-Wizard parasites | 112-127 | **19 organisms**, each a full block with a market cost |
| Symbiotic organisms | 128-137 | **11 organisms**, same shape |
| New Bio-Wizard weapons | 137-151 | **26 items** in five groups: 6 faerie-component, 7 entity, 4 corrupted Millennium Tree, 4 Eye of Eylor, 5 others |
| Magic restraints | 151-154 | **8 items** |
| Bio-Borgs | 154-161 | insanity table (156-157); partial conversion rules (157); **1 class**, the True Bio-Borg R.C.C. (157-161), built from six orientations, a determination table and five augmentation tables (158-160) |
| Notable weapons and equipment | 162-172 | **14 items**: 3 D-Squad (162), 4 Kittani plasma (162-164), 2 Octurill (171), 3 Kizh (171-172), a helmet and a blade enchantment (172) |
| Kittani power armour | 164-170 | **2 power armours** with location blocks and weapon systems |
| Skyborne Excursions | 173-176 | **2 full NPC blocks** (Miles Sky 175-176, Andruu Realm 176); a fare list |
| Vehicles | 177-190 | **6 vehicle weapons and 5 vehicle features**, all Techno-Wizard add-ons (177); **12 vehicle headings**: 2 flying platforms, 3 Eylor devices, 2 hover pods, a patrol flyer, 2 Sky-Flyer headings covering four sizes, airships in four size classes, Splugorth flying ships in four; a flight pack (181); **1 skill** described inside the hover pod text (184, 187) |

That is **15 full NPC blocks**, **14 class blocks** (12 R.C.C.s in the slave
stock, the Tattooed Archer and the True Bio-Borg), **2 animals**, **23
tattoos**, **106 priced or statted items** (30 organisms, 26 weapons, 8
restraints, 16 market goods, 14 arms, 11 vehicle add-ons and the flight pack)
and **14 vehicle headings** that come to 22 rows when each size class is
counted.

**No spell and no general psionic power is defined.** The scan for a P.P.E.
cost line found only the tattoos, and for an I.S.P. cost line only powers
inside R.C.C. blocks: two the Pythonan alone has (86) and the Staphra
Warlord's channelled bolt (93-94).

## Classes

### R.C.C.s and O.C.C.s (14 blocks) — pages 73-101, 108-111, 157-161

| class | pages | XP table |
|---|---|---|
| Kryygorth Hunter R.C.C. | 73-75 | Dog Boy |
| Kryygorth's Lesson R.C.C. | 75-77 | Dragon |
| Kryygorth Pegasus R.C.C. | 77-79 | Psi-Stalker |
| Octoman R.C.C. | 80-82 | the chosen O.C.C.'s |
| Nurilian Plant-People R.C.C. | 82-85 | Dragon |
| Pythonan R.C.C. | 85-87 | Dragon |
| Rulian Translator R.C.C. | 87-90 | Rogue Scholar |
| Staphra Warrior R.C.C. | 92-93 | Headhunter |
| Staphra Warlord R.C.C. | 93-95 | Bio-Borg, on 190 |
| Staphra Mystic R.C.C. | 95-97 | Mystic |
| Were-Dragon R.C.C. | 97-101 | Psi-Stalker |
| Monster Were-Dragon (inside the Were-Dragon block) | 98-101 | Bio-Borg, on 190 |
| Tattooed Archer O.C.C. | 108-111 | its own, on 111 |
| True Bio-Borg R.C.C. | 157-161 | Bio-Borg, on 190 |

No id collides. Production holds no class id like `kryygorth`, `octoman`,
`nurilian`, `pythonan`, `rulian`, `staphra`, `were-dragon`, `archer` or
`bio-borg`; the nearest are `werejaguar` and `plant-shaman`, both other
classes.

Ten of the twelve slave-stock blocks carry the book's line offering them as
optional player characters. Two qualify it. The Plant-People's note advises
against them as player characters and gives them no O.C.C. (82-85).
Kryygorth's Lesson is open to players only in an emancipated form, printed as
a set of halvings and penalties on the same pages. The Staphra are offered as
spies or renegades.

The Pythonan's sub-block on 87 is an occupation of the same race (its own
skill list, equipment and money, everything else as the race). The Monster
Were-Dragon has its own M.D.C. formula, skill list, experience table,
penalties and a rolled craving table, inside the Were-Dragon's block.

The Partial Conversion Bio-Borg (157) is not a class: it is a rule that
restarts any character with four or more enhancements at level one on the
Bio-Borg ladder. Four named Bio-Borg types on 161 are deferred by the book to
a later publication and have no figures.

Two classes already held are extended by this book and not reprinted in it:
the tattoo rules on 107 say who may take tattoos, with no block.

## Catalog diff

Run against **production** (`--remote`), 2026-11-18, `origin/main` c49d7298.
Production holds 0 rows citing this book in any table. **It holds 51 of this
book's entries under other citations**, almost all from the Book of Magic,
which reprinted this book's Bio-Wizard weapons, restraints and Eylor devices
two years later.

### gear: 106 entries, 37 held, 69 new

`node scripts/catalog-diff.mjs --remote --table gear` over the names returns
20 exact matches; the hand-check of every near name against production's
4,904 rows found 17 more held under a group prefix.

| the book's group | entries | held as | verdict |
|---|---|---|---|
| faerie-component weapons (138-141) | 6 | `Faerie: Blizzard Staff`, `Faerie: Dark Lightning`, the three `Faerie: … Pistol or Rod` rows, `Faerie P.P.E. Battery`, Book of Magic p.262-264 | held; cost and M.D.C. agree with this printing |
| entity weapons (141-144) | 7 | the seven `Entity …` rows, Book of Magic p.257-258 | held; cost and M.D.C. agree |
| corrupted Millennium Tree items (144-146) | 4 | the four `Corrupt …` rows, Book of Magic p.293-294 | held; the Serpent-Slayer's price is this book's low figure |
| Eye of Eylor weapons (146-149) | 4 | `Eylor Assault Staff`, `Eylor Exploration Staff`, `Eylor Mace (Mace of Eylor)`, `Eylor Shield of Invincibility`, Book of Magic p.259-262 | held |
| other Bio-Wizard weapons (149-150) | 5 | `Demon Claw Blade`, `Dragonfire Sword`, `Venom Blade`, `Living Whip`, `Fang Dagger`, Book of Magic p.257-267 | held |
| magic restraints (151-154) | 8 | eight rows, Book of Magic p.274-276, the first as `Conventional Mega-Damage Shackles` | held |
| Kizh gauntlet, blade enchantment (172) | 2 | `Kizh TW Sensor Gauntlet`, `Mega-Blade (TW)`, Book of Magic p.314-315 | held |
| flight pack (181) | 1 | `Wing Pack (TW Jet Pack)`, a vehicles row, Book of Magic p.337-338 | held |
| parasites and symbiotes (112-137) | 30 | none | **new**. The eleven organism rows production holds are Atlantis's and are all different organisms; `Brain Feeder (Parasite)` is not the Line Feeder, and the Atlantis `Living Armor of Bone` is a Pantheons item |
| D-Squad, Kittani, Octurill, Kizh guns, helmet (162-172) | 12 | none | **new**. `Kittani Plasma Sword` (Triax) is a fifth plasma weapon, not one of these four |
| vehicle add-ons (177) | 11 | none | **new** |
| market goods (21-36) | 16 | none | **new**. Checked and different: Palladium Fantasy's snail and butterfly charms, Federation of Magic's `Firestaff`, Japan's bark shields |

Items that exist only inside an NPC's block (a rail gun, two Techno-Wizard
weapons, a bow, two Millennium Tree pieces) are not counted above; `Firestaff`
and `Scathach Magic Bow (pine)` are held from other books.

### vehicles: 22 rows by size class, 9 held, 13 new

| the book prints | production holds | verdict |
|---|---|---|
| the two flying platforms (178-180) | `tw-tech-flying-platform`, `tw-seaside-hover-platform`, Book of Magic p.337 | held; main body and price agree |
| the three Eylor devices (180-184) | `splugorth-hover-platform`, `splugorth-eylor-jet-pack`, `splugorth-eylor-hovercycle`, Book of Magic p.316-317 | held; main body and price agree |
| Splugorth flying ships, four sizes (190) | `splugorth-flying-ship-small`, `-medium`, `-large`, `-frigate`, Atlantis p.154-155 | held from the **older** book; M.D.C. floor and price agree, the rest unread |
| two Kittani power armours (164-170) | none; `k-universal-light-power-armor`, `kittani-serpent-power-armor` and two more are Atlantis's and different suits | **new** |
| two hover pods and the patrol flyer (184-188) | none | **new** |
| Sky-Flyer in four sizes (188-189) | none; `TK-Flyer "Classic"` is another craft | **new** |
| airships in four size classes (189-190) | none | **new** |

### spells: 23 tattoos, all new

Production holds 32 tattoos, all Atlantis's, as `spells` rows with tradition
`tattoo`, level 0, named `Tattoo: <heading> (<power>)`. None of the 23 matches
one. The nearest pairs are different tattoos: this book's flaming eye against
the held flaming shield, and its lightning arrows against the held lightning
bolts. The two unentered archer tattoos (the bow in flames and the four winged
arrows) are not held either. `Energy Disruption` (Rifts Ultimate Edition) is
the invocation one arrow's source tattoo names, not the arrow.

### creatures, notable NPCs, skills, psionic powers

- creatures: neither animal is held, and no slave-stock race has a creatures
  row. `Pegasus` (Conversion Book One) is the horse, not the Kryygorth.
- notable NPCs: none of the 15, nor any sketch, is held. Production's
  `splynncryth` and `styphathal` are Atlantis's and are not restated here.
- skills: `Pilot: Hover Pod` is not held. `W.P. Sharpshooting` (New West) is
  held; the archer's bow form is printed as a class ability.
- psionic powers: `Psionic Invisibility` is held (Rifts Ultimate Edition).
  The Pythonan's two powers and the Warlord's bolt are not, and are printed
  as racial abilities.

## Extraction plan

One branch per line; tattoos and organisms go before the classes that name
them, the True Bio-Borg before the two classes on its ladder, and the classes
before the NPCs levelled in them. Branch prefix `pal/data/splynn-`.

1. `tattoos-a`, `tattoos-b`: the 2 weapon and 10 power tattoos (102-104), then
   the 11 Power Arrows with the bow and winged-arrow tattoos (104-106),
   through `scripts/rows-sql.mjs`.
2. `parasites-a`, `parasites-b`, `symbiotes`: the 30 organisms (112-137) as
   gear.
3. `arms`: the 12 new D-Squad, Kittani, Octurill and Kizh items (162-172).
4. `market-goods`: the 16 priced market items (21-36).
5. `power-armor`: the Centipede and the Flying Fox (164-170), through
   `scripts/vessel-sql.mjs`.
6. `hover-pods`: the two pods and the patrol flyer (184-188), and the skill.
7. `skyborne`: the Sky-Flyer in four sizes, the four airship classes
   (188-190) and the 11 vehicle add-ons (177).
8. `flying-ships-compare`: the four held Atlantis flying ships read against
   printed 190.
9. `animals`: the Demonrunner and the Kryygorth Shellback (71-73, 79-80) as
   creatures, with the three Shellback armour tiers as gear; then
   `creatures-a` to `-c`: each slave-stock race as a creatures row as well as
   a class (the three Kryygorth and the Octoman; the Plant-People, Pythonan
   and Rulian; the three Staphra and both Were-Dragon forms), through
   `scripts/bestiary-sql.mjs`.
10. `class-<id>`: one class per branch, fourteen of them.
11. `npcs-a` to `-e`: the 15 full blocks and Crazy Al, through
    `scripts/bestiary-sql.mjs`.
12. `pal/docs/splynn-close-out`.

Rulings that govern it:

- **Each slave-stock race is a class and a creatures row. RULED (Nate,
  2026-11-18).** The class is what a player picks; the creatures row is the
  same block for the Game Master, as Lemuria and Baalgor did. Kryygorth's
  Lesson's creatures row carries the full creature and its class the
  emancipated form. Not taken: classes only (the recommendation), and
  creatures only.
- **The True Bio-Borg is imported with its creation tables in the class, and
  the gap is filed. RULED (Nate, 2026-11-18).** The six orientations, the
  determination table and the five augmentation tables go in as pick or roll
  groups where the class frontmatter expresses them; what does not fit is
  stated in the class and filed in `BOOK-INGEST-AUDIT.md`. No schema change
  and no code. Not taken: the tables as prose only, and leaving the class
  out.
- **The market goods, the vehicle add-ons and the Shellback armour are gear
  rows. RULED (Nate, 2026-11-18).** Sixteen, eleven and three rows. The slave
  price table is left out. Not taken: leaving any of the three groups as
  rules, and filing the price table as a gap.
- **The Spd figure printed as 44 is stored as +4. RULED (Nate, 2026-11-18).**
  On printed 109 and 160, with the printed digits in a note. Not taken: 44 as
  printed.
- **Newest printing wins (Nate, 2026-10-04).** The 46 gear and vehicles rows
  held from the Book of Magic (2001) are the newer printing of entries this
  book (1999) introduced, and are left as they are. The four flying ships held
  from Atlantis (1992) are the older printing, so line 8 reads them against
  this one.
- **An NPC row needs H.P. or M.D.C., a level or class, and an alignment (the
  Old Ones rule).** Fifteen blocks meet it and one sketch does (Crazy Al).
  The arena champions, the other proprietors and Powerlord Reytan do not.
- **A book-flagged class is imported with its flag (Nate, 2026-11-17, on
  Megaverse in Flames).** The Plant-People carry the book's advice against
  playing them; Kryygorth's Lesson is imported in its emancipated form.
- **The Monster Were-Dragon is a class of its own; the Pythonan scholar is a
  variant of the Pythonan.** Taken on the recommendation, 2026-11-18: the
  Monster form has its own ladder, skill list and M.D.C., and the scholar
  changes skills and equipment only. Not taken: one Were-Dragon class with
  two forms, and a second Pythonan class.
- **The bow and winged-arrow tattoos are rows.** Taken on the recommendation,
  2026-11-18: the archer must hold both, so 25 tattoo rows, the two carrying
  what 104-105 state. Not taken: leaving them as class prose.
- **Racial psionic powers stay in their class.** Taken on the recommendation,
  2026-11-18: the Pythonan's two powers and the Warlord's bolt are class
  abilities, and the archer's bow proficiency a class ability beside the held
  `W.P. Sharpshooting`. Not taken: psionic_powers and skills rows for them.
- **Each vehicle size class is a row.** Taken on the recommendation,
  2026-11-18, as the held flying ships are: four Sky-Flyers, four airships.
  Not taken: one row per heading.
- **Sergeant Beta is an NPC row.** Taken on the recommendation, 2026-11-18:
  the book prints one robot, no model block. Not taken: a vehicles row.
- **Staphra is the spelling**, off the headings; the ids are
  `staphra-warrior`, `staphra-warlord` and `staphra-mystic`.

What is deliberately left, with the reason for each:

- the 46 held Book of Magic rows: the newer printing is already in;
- the merchandise rules (14-16), the transient-merchant rules (40-42) and the
  vehicle customisation caps (177): rules for a Game Master;
- the price lists for services and living stock (24, 32, 33, 36, 175) and the
  slave price table (45-47): tables of prices by kind of being, with no item;
- D-Squad and the Liberated Underground as organisations (58-63): head-counts
  and percentages, each named in its leader's NPC row;
- the arena champions (49) and the proprietors with a level and no block;
- items that exist only inside an NPC's block: carried in that NPC's row;
- the Partial Conversion rule (157), the Bio-Borg insanity table (156-157)
  and the four deferred Bio-Borg types (161): stated in the True Bio-Borg
  class, no row of their own;
- the Gemini Demon sketch (30) and the Haardeon inside the jet pack
  (181-182): no block of their own.

## Ledger

| date | branch | what went in |
|---|---|---|
| 2026-11-18 | `pal/docs/splynn-register-survey` | cache built (194 pp, text layer), offset +1 verified by folio at four points, inventory by four readers over all 191 printed pages, production diff; `splynn` registered in `books.json` |

### What remains

From `node scripts/source-coverage.mjs --remote`, 2026-11-18: the book has no
*BY BOOK* line yet, because no row cites it. Its cache is counted among the
registered books present (194 pages). That run's `BACKLOG` block, which this
book has not moved:

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs            13   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs           56   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

Everything in *Extraction plan* remains.
