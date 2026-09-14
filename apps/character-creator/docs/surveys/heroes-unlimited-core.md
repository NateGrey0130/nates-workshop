# Revised Heroes Unlimited — survey

Slug `heroes-unlimited-core`. Cached 2026-09-12 from
`93229611-Heroes-Unlimited-Core-Book-Revised.pdf`, 240 PDF pages,
**a scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

Three sibling books were cached in the same session and are surveyed in
`powers-unlimited-1.md`, `powers-unlimited-2.md` and `powers-unlimited-3.md`.
**Read the edition section below before treating them as one batch.**

## This is NOT Heroes Unlimited 2nd Edition, and the supplements are

The single most load-bearing fact in this file, because every later decision
turns on it and nothing in the tooling would have caught it.

`93229611-Heroes-Unlimited-Core-Book-Revised.pdf` is the **1987 Revised first
edition**, ninth printing January 1993 (cache p002, p003). The three Powers
Unlimited books each describe themselves on their own copyright page as a
sourcebook for Heroes Unlimited **2nd Edition** — PU1 cache p004, PU2 cache
p003, PU3 cache p004.

**The structural evidence, which does not depend on reading a copyright line.**
PU2 lays its six new power categories out as `Step 3:`, `Step 5:` and
**`Step 6:`** (its printed Contents, cache p005). The Revised core defines
**five** steps and stops at Step 5 — its printed 8, and its printed Contents at
printed 4-5. A Step 6 does not exist in this book. PU2 is therefore bound to a
longer step sequence than the core on hand provides.

**What that does and does not rule out**, measured by what each supplement
contains rather than by the edition label:

| book | content | portable to Revised? |
|---|---|---|
| PU1 | new minor and major super abilities, self-contained Range/Duration/Damage blocks, printed 9-86; psionics at cache p090-p097 | **largely yes** - a super ability is self-contained; the 2nd-Edition dependency is in WHICH CATEGORY may take it, not in the ability |
| PU3 | same shape, printed 6-104, some entries marked Reprinted | **largely yes**, same argument |
| PU2 | six new POWER CATEGORIES with attribute bonuses, experience ladders and equipment budgets | **no** - see the Step 6 argument above |

**D0 is ANSWERED, 2026-09-13, after all three supplements were surveyed in
full** — `powers-unlimited-1.md`, `powers-unlimited-2.md`,
`powers-unlimited-3.md`. See *D0, answered* below.

## Page offset

Read from `scripts/books.json`, which this session wrote after measuring.

`page_offset: 0` — cache file page = printed folio + 0, so printed folio F is
`p<F>.txt` and `read-columns.py F`. No `page_offset_exceptions`.

**This is the cleanest offset measurement in the registry.** 160 of 240 cached
pages carry a folio-like line; **all 160 agree at +0 and none disagrees**, in a
single region p010-p237 with no split. The repo's own smoke check derives the
same thing independently and reports `heroes-unlimited-core +0 over printed
42-237`.

Corroborated four further ways, by section ranges landing exactly where the
printed Contents (printed 4-5) says they do:

| section | Contents says | marker scan found |
|---|---|---|
| magic spell descriptions | 96-105 | `Range:`/`Duration:`/`Savings Throw:` on 96-105 |
| psionic power descriptions | 127-135 | `I.S.P.:` on 128-134 |
| super ability descriptions | 163-192 | `Damage:`/`Duration:` on 164-191 |
| weapons and equipment | 212-221 | `Cost:` on 213-221 |

**`ocr-book.py` measured `printed_pages: 248` and it is wrong.** Cache p239 is a
comic panel whose sound effect OCR'd as a folio. The registry outranks the
manifest here for the same reason it does for `bom`. `printed_pages` is recorded
as **238**, which the printed Contents gives for the character sheets; the last
folio that actually surfaces is **237**, and cache p238-p239 carry comic art
rather than the sheets the Contents names. p240 is the back cover. The gate
passes either way, the cache holding 240.

**Zero offset is the worst case, not the easiest** — there is no offset left to
explain, so a wrong page reads as the book not saying what you expected. It cost
one wrong page read in this session before the folios were checked.

**OCR quality.** Median 4,593 chars/page. Stat-block labels survived well:
`Range:`, `Duration:`, `Savings Throw:` and `I.S.P.:` all parse. The cache
carries curly apostrophes and em-dashes (`Fool's Gold` round-trips through a
replacement character in a naive read) — **strip them before any SQL**. No page
needed a re-render for legibility; one page was rendered at 220 dpi to settle a
content question, not an OCR one (see Authority tables).

## The book's authority tables

| printed page | table | states |
|---|---|---|
| **4-5** | *Table of Contents* plus a *Quick Find Reference Table* | the section ranges, and a second index of the ten power categories |
| **12** | *Random Power Table* | the ten power categories, by percentile |
| **27** | *Educational Level* | eleven rows: education type, one-time skill bonus, number of skill programs, number of secondary skills |
| **27-28** | *Available Skill Programs* | the sixteen programs and what each grants |
| **9** | *Attribute Bonus Chart* | the 17-30 bonus ladder, six rows |
| **162** | *Random Super Ability Selection Tables* | how many major/minor abilities a character gets |
| **163**, **169** | alphabetical lists of minor and major super abilities | the canonical spelling and the roster |
| **96** | alphabetical list of wizard spells | the roster, the pick cost, and which spells are offensive |
| **128** | major and secondary psionic lists | the roster and the major/secondary split |

**Two indexes exist and the Quick Find one is a subset**, not an independent
reading — it repeats the power-category pages only. So most values here are
printed ONCE and are transcribed rather than reconciled. The exception is the
spell roster, where printed 96 and the description blocks on printed 96-103 are
two independent readings.

### The one page that contradicts the book

**Printed 8 lists the wrong five steps.** Its `CREATING A CHARACTER` block gives
Step 3 as Occupational Character Class, Step 4 as Equipment and Money and Step 5
as Alignments — the Palladium Fantasy sequence. The Contents at printed 4 and
the section headings at printed 12, 12 and 13 give Step 3 as Determining Super
Abilities, Step 4 as Determining Education and Skills and Step 5 as Rounding Out
One's Character.

**Verified by render, not by OCR** — printed 8 was rendered at 220 dpi and read,
because an OCR artifact was the likelier explanation and it is not the true one.
The page really says it. **Follow the Contents and the section headings.** An
importer that trusts printed 8 will look for an O.C.C. this game does not have.

### What the spell index's own notation means

Printed 96 prints a parenthetical after some spell names and an asterisk before
others. The footnote on that page settles both, and neither means what a Rifts
reader would assume:

- **`(2)` / `(3)` is a PICK COST**, not P.P.E. and not spell level: a more
  powerful spell counts as two or three of the character's spell selections.
- **The asterisk marks a spell as strictly offensive.**

The catalog has a field for neither. See D6.

## Inventory

Counted by structure over all 240 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| rules, creation, combat | 6-54 | five creation steps, insanity tables, hand-to-hand, car/air/space combat |
| education and skills | 27-36 | **11** educational levels, **16** skill programs, a secondary skill list, skill descriptions |
| power categories | 55-161 | **10** categories; four carry named sub-types, **13** sub-types in all |
| super abilities | 162-192 | **31** minor, **38** major |
| psionic powers | 127-135 | **19** major, **14** secondary, **33** total |
| wizard spells | 96-100 | **48** |
| illusionary spells (Magician) | 101-103 | **25** |
| circles, wards, enchanted objects | 88-91, 103-107 | protection/summoning circles, wards, enchanted weapons and objects |
| mutant animal rules | 111-123 | B.E.P. budget, animal features, animal psionics, animal descriptions |
| robot construction | 141-152 | a point-budget builder |
| super-vehicle construction | 80-87 | a second point-budget builder |
| weapons and equipment | 193-220 | ancient, oriental and modern weapons; Tissue Damage Ratings; energy, incendiary, gases; accessories, sensors, clothing |
| vehicles | 221-227 | ground, military, helicopters |
| GM material | 228-237 | Quick Roll Villain, vigilantes, the law, two adventures |

### The ten power categories, and their sub-types

| category | printed | sub-types |
|---|---|---|
| Aliens | 55-59 | — |
| Bionics | 60-68 | — |
| Experiments | 69-72 | none - the Super-Soldier at printed 71 is an OPTION inside the category, not a sub-type |
| Hardware | 73-87 | **3**: Electrical Expert, Mechanical Genius, Weapons Expert |
| Magic | 88-107 | **3**: Wizard, Magician, Mystically Bestowed |
| Mutants | 108-123 | **2**: Mutant Human, Mutant Animal |
| Physical Training | 124-126 | — |
| Psionics | 127-135 | — |
| Robotics | 136-152 | — |
| Special Training | 153-161 | **5**: Ancient Master, Hunter/Vigilante, Secret Operative, Stage Magician, Super Sleuth |

**Two categories do not roll on the Educational Level table at all** — Physical
Training and Special Training, stated at printed 27. Their skills come from the
category entry instead. That is a fact about the book, not a gap in the
extraction.

### What this book has ZERO of

Stated because each reads like a gap and is not:

- **No O.C.C. and no R.C.C.** Checked by marker scan: `O.C.C. Skills`,
  `R.C.C. Skills` and `Attribute Requirement` return **zero hits across all 240
  pages**. This game does not have the concept.
- **No M.D.C. system.** Everything is S.D.C. and Hit Points. The marker is not
  zero, and the two hits are worth stating rather than rounding away: printed 39
  carries a glossary cross-reference naming M.D.C. as a cousin to S.D.C., and
  printed 209 gives one incendiary weapon an M.D.C. equivalent beside its S.D.C.
  damage. Neither is an M.D.C. character or an M.D.C. rule.
- **No P.P.E. as a spell currency.** The `P.P.E.:` marker returns zero hits in
  the magic chapter. Spell capacity is a **spells-per-day count** (printed 92-95),
  not a point pool. See D5.

## The character model, and why it does not fit the class chassis as-is

This is the section the integration turns on.

A Rifts or Palladium Fantasy character is one class row that grants skills,
bonuses and equipment. **A Revised Heroes Unlimited character is two independent
axes plus an optional third:**

1. **Power Category** — one of ten, chosen or rolled on printed 12. Determines
   super abilities, and for four categories a **sub-type** must be chosen too.
2. **Educational Level** — one of eleven, rolled on printed 27. Determines a
   one-time scholastic bonus (+5% to +35%), a number of **skill programs**
   (2-4, or a bespoke allowance), and a number of secondary skills (8-10).

Nothing links them: any category may hold any education, except the two that do
not roll at all.

### What ALREADY fits, and it is more than expected

- **Attributes are identical** — I.Q., M.E., M.A., P.S., P.P., P.E., P.B., Spd,
  3D6 with an extra D6 at 16-18, and the printed-9 bonus chart has the same six
  rows the app models.
- **Alignments are identical** — the same seven, printed 13.
- **S.D.C., Hit Points, percentile skills, W.P.s and hand-to-hand** are the same
  Palladium chassis.
- **`skill_programs` already exists in the frontmatter contract** —
  `apps/character-creator/js/parser.js` validates
  `{choose, base, per_level, categories}`, a whole category taken at one flat
  percentage, and `characters.skills` already accepts `"type": "program"`. Built
  for the Triax NGR Robot Soldier under `BOOK-INGEST-AUDIT` F23(b). It is most
  of this book's skill engine already in place.

### What does not fit

| # | gap | evidence |
|---|---|---|
| G1 | `system` is a closed enum in **8** code sites, three of them SQLite `CHECK` constraints that cannot be widened by `ALTER`. **Already filed as `BOOK-INGEST-AUDIT` F73 by the Nightbane survey (PR #991)**, which hit the same wall one book earlier - so Heroes Unlimited is the SECOND game to need it and this is not a new finding | `db/schema.sql:179`, `:467`, `:575`; `js/parser.js:15`; `js/catalog-fields.js` x6 plus `:348`; `functions/api/character-creator/campaigns.js:56`; `app.js:710`/`:951`/`:954`; `codex.js:136`/`:334`; `catalog.js:130`; `js/rules.js:65` |
| G2 | `skill_programs` grants by CATEGORY; **3** HU programs grant NAMED SKILLS across categories | Computer, Journalist/Investigation and Medical programs, printed 27-28 |
| G3 | a program can carry a **per-skill penalty inside the bundle** - Robot Electronics at -40%, robot mechanics at -40% - and `parser.js:2444` rejects a per-category bonus deliberately | printed 27-28 |
| G4 | **3** programs have no catalog category: Computer, Journalist/Investigation, Language | catalog holds 17 categories |
| G5 | HU splits W.P. into **Ancient** and **Modern**; the catalog has one `Weapon Proficiencies` (38 rows) | printed 28 |
| G6 | **69** super abilities are a fifth power kind - permanent traits with Range/Duration/Damage, no cost and no level. Not spells, not psionics | printed 163-192 |
| G7 | **two point-budget construction systems** - robots printed 141-152, super-vehicles printed 80-87. The catalog has no builder of any kind | a harder `BOOK-INGEST-AUDIT` F3 |
| G8 | HU psionics are **Major/Secondary**; Rifts psionics are Sensitive/Physical/Healing/Super. The taxonomies do not map | printed 128 |
| G9 | spell capacity is **spells per day**, not P.P.E.; and a spell can cost 2 or 3 PICKS | printed 92-96 |
| G10 | currency is dollars; `js/rules.js:65` returns Credits for rifts and gold otherwise | printed 193-220 |

## Catalog diff

Run against **production** (`--remote`) on 2026-09-12. Note the spells table read
**889** rows, not the 850 it held earlier the same day: the 39 Fire Sorcerer
spells of the Mystic Russia Living Fire import (PR #990) went in mid-session,
applied `--remote` before that PR merged as the ordering rule requires — which
is why the count moved before the merge rather than after it. The diff was
re-run after #990 landed and every number below is unchanged.

### `spells`: 70 entries, 54 matched, 16 missing — and ~12 genuinely new

`node scripts/catalog-diff.mjs --remote --table spells --entries hu-all-spells.json`

**The headline is that this book is mostly RE-CITATION, not import.** 48 wizard
plus 25 illusionary spells are 70 distinct names, and the catalog already holds
54 of them.

**The alias bucket is UNSAFE for this book and must not be auto-accepted.** Six
of its seven entries are wrong, and they are wrong in two distinct ways:

| book prints | matcher chose | what production actually holds | verdict |
|---|---|---|---|
| `Invisibility (self)` | `Invisibility (Superior)` L7/20 | `Invisibility: Simple` L3/6 **also exists** | **wrong row of two** |
| `Levitate (self or others)` | `Air: Levitate` L2/7 | **no general `Levitate` at all** | tradition row, not the spell |
| `Mesmerism` | `Air: Mesmerism` L2/7 | **no general `Mesmerism`** | same |
| `Wall of Flame` | `Fire: Wall of Flame` L3/15 | **no general `Wall of Flame`** | same |
| `Spontaneous Combustion` | `Fire: Spontaneous Combustion` | — | same shape, unchecked |
| `Swirling Lights` | `Fire: Swirling Lights` | — | same shape, unchecked |
| `Dispel Magic Barrier` | `Dispel Magic Barriers` | plural only | **genuine** |

A tradition row is a separate, cheaper row than the general spell — `Fool's Gold`
is held both ways, general at L4 and `Earth: Fool's Gold` at L1. Matching a bare
book name onto a tradition row conflates the two.

**False gaps inside the MISSING list**, hand-checked:

| book prints | catalog holds | action |
|---|---|---|
| `Breath Without Air` | `Breathe Without Air` L3/5 | **rename, not a new row** |
| `Sword to Snakes` | `Swords to Snakes` | **rename, not a new row** |
| `Expel Devils/Demons` | `Expel Demons` L8/35 | likely rename; confirm against printed 98 |
| `Swim as the Fish` | `Swim as a Fish (lesser)` L4 and `(Superior)` L5 | confirm which, against printed 100 |

**And one near-match that is NOT a false gap:** `Shadow Walk` against
`Shadow Wall` is distance **1** and they are different spells. This is the
Push/Punch case the matcher's own warning names.

### `psionic_powers`: 33 entries, 28 matched, **5** missing

`Ectoplasmic Arm`, `Empathic Transfer`, `Hypnosis/Mesmerism`, `Mind Control`,
`Resist Cold`. Both alias matches are genuine — `Bio-Manipulation (the evil
eye)` and `Object Read (Psychometry)` are the same powers under a parenthetical.

### Skill programs against catalog categories

13 of the 16 programs map to an existing category. The three that do not are G4.
The mapping is **not** one program to one category — see G2.

## Decisions

D0-D3 are answered; D4-D8 are open. D1-D3 were answered by Nate on 2026-09-12
before the survey was written, and D0 on 2026-09-13 once all three supplements
had been surveyed in full.

| id | question | status |
|---|---|---|
| **D0** | **which edition** - Revised only, get an HU2 core, or adapt | **ANSWERED 2026-09-13** - build against the Revised core; take PU1 and PU3; EXCLUDE PU2. See *D0, answered* |
| **D1** | how deep to integrate | **ANSWERED** - a third `system` value reusing the class chassis: Power Category in the R.C.C. slot, Educational Level in the O.C.C. slot, sub-type as the variant |
| **D2** | campaigns or catalog first | **ANSWERED** - catalog and classes first; `campaigns.system` `CHECK` is left alone, so HU rows exist before an HU campaign can |
| **D3** | where super abilities live | **ANSWERED** - a new `super_abilities` table with a minor/major tier column. A schema change, so NOT this session |
| **D4** | the 6 unsafe alias matches above - rename, new row, or `same_spell_as` | **ANSWERED 2026-09-13.** Five are the SAME row under a different spelling; five more are NEW general rows the catalog holds only in tradition form. See *D4-D8, answered* |
| **D5** | spells-per-day and the 2/3 pick cost (G9) - model, or record in `extraction_notes` | **ANSWERED** - recorded, not modelled |
| **D6** | the offensive-spell asterisk - a tag, or dropped | **ANSWERED** - dropped |
| **D7** | the two construction systems (G7) - deliberately not imported, as `BOOK-INGEST-AUDIT` F3 decided for vessels | **ANSWERED** - not imported |
| **D8** | W.P. Ancient/Modern split (G5) - two categories, or one with a tag | **ANSWERED** - one category; the split is a PROGRAM's named list |

## D0, answered

**Build against the Revised core. Import Powers Unlimited One and Three.
EXCLUDE Powers Unlimited Two.** Decided 2026-09-13 after surveying all three
supplements in full.

### What the three books actually are

| book | new super abilities | new psionics | new power CATEGORIES |
|---|---|---|---|
| PU1 | **170** (125 minor, 45 major) | **21** | 0 |
| PU3 | **125** (46 minor, 79 major) | 0 | 0 |
| PU2 | **2** | 0 | **12** |

Each roster was read twice - the book's Contents and its own alphabetical list
page - and the two agree exactly for PU1 and resolve to a one-entry
explanation for PU3.

### The measurement the answer rests on

Coupling to the 2nd Edition rule book, counted per page over each cache:

| measure | PU1 | PU3 | **PU2** | Revised core |
|---|---|---|---|---|
| pages mentioning HU2 | 6% | 16% | **45%** | — |
| `page N of HU2` citations | 2 | 7 | **42** | — |
| `Step 6` references | 0 | 0 | **5** | — |
| pages using P.P.E. | 2 | 3 | **15** | **0 of 240** |
| pages using S.D.C. | 61 | 63 | 63 | 108 |

### Why PU1 and PU3 come in

1. **They are additive, not structural.** Both are rosters of super abilities.
   They add rows; they do not touch how a character is built.
2. **They are S.D.C.-based, like the Revised core.** PU3 mentions M.D.C. on
   **zero** of its 120 pages.
3. **Their few HU2 citations point at content the Revised core HAS** under
   different pagination: P.S. damage, lifting and carrying (HU2 p.294; Revised
   printed 9), animal damage (HU2 p.251; Revised printed 111-123), Underwater
   abilities (one of the Revised core's own 31 minor abilities). Nine citations
   between the two books, each a one-time translation.

### Why PU2 stays out

1. **Its 42 citations are load-bearing in a way the others' are not.** They name
   the specific super abilities its categories GRANT - Plant Control at HU2
   p.285, Energy Expulsion at p.293, Tentacles at p.294 - so a category cannot
   be transcribed until every ability it names is resolved against a roster this
   catalog is still building.
2. **Its categories are class-shaped**, and under D1 a Power Category occupies
   the R.C.C. slot. A class is the most expensive thing in this catalog to get
   wrong, and there is not yet a single Heroes Unlimited class to compare one to.
3. **It assumes P.P.E.** - 6D6 for every superbeing, on 15 of its pages. The
   Revised core uses P.P.E. on none of its 240.

### What is NOT a reason, stated because it was the first reading and it was weak

**The category roster is not the problem.** PU2's own Random Power Category
Table (printed 7) lists twenty categories, and its ten unmarked rows are
**exactly the Revised core's ten**. Mega-Hero - which the Revised core refuses
outright in a section headed for it on printed 12 - is excluded from PU2's table
by the book itself, as is the Crazy Hero, which the Revised core does carry.

**The `Step 6` mismatch is real but narrow.** PU2's Steps 5 and 6 cover
alignment, experience and equipment, all of which the Revised core carries in
its own Step 5 and its per-category equipment lines. It is a numbering mismatch
more than a missing mechanic, and it is the weakest of the three arguments
above. It was the first evidence found and it should not be the one quoted.

### What the answer costs

**PU2's twelve categories are the single largest content loss in the batch**,
and the only new character TYPES in any of the four books: Empowered, Eugenic
Heroes, four Gestalt Superhumans, Imbued Heroes, Immortals, Personal Weapon,
Super-Invention, Minor Heroes, Natural Genius, Supersoldier, Symbiotic
Superhuman, Ancient Weapons Master.

**What would reopen it:** an HU2 core book. PU2 becomes the most valuable of the
three the moment one exists, which is why its cache and registry entry stay.

### Sequencing this answer implies

**D3 gates the ABILITIES, and nothing else.** 295 of the 296 new super
abilities cannot be imported until `super_abilities` exists; the catalog has no
shape for a permanent trait with a Range and a Damage and no cost and no level.

**PU1's eight new psionic powers are NOT gated on it** and can ship as soon as
this survey merges - `psionic_powers` has been there all along. They are the
smallest complete unit in the batch and the natural first data PR.

1. D3's table.
2. The Revised core's own 69 abilities, 10 categories and 14 sub-types.
3. PU1's 170 abilities and 8 new psionics.
4. PU3's 125 abilities, de-duplicated against PU1 and against its own seven
   `(Reprinted)` markers.

## D4-D8, answered

Decided 2026-09-13, after the super-ability import closed out D0's scope.

### D4 - the unsafe alias matches

`catalog-diff`'s alias bucket was wrong on six of seven entries for this book,
so every one was resolved against production by hand. They split two ways, and
the split is the answer:

**Five are the SAME row the catalog already holds**, under a spelling
difference. No new row; the importer cites the existing one.

| the book prints | the catalog holds |
|---|---|
| `Invisibility (self)` | **`Invisibility: Simple`** L3/6 - NOT `Invisibility (Superior)` L7/20, which is what the matcher chose |
| `Dispel Magic Barrier` | `Dispel Magic Barriers` |
| `Breath Without Air` | `Breathe Without Air` L3/5 |
| `Sword to Snakes` | `Swords to Snakes` L9/50 |
| `Expel Devils/Demons` | `Expel Demons` L8/35 |

**Five more are NEW general rows**, and this is the substantive half. For each of
these the catalog holds ONLY a tradition-namespaced row - a Warlock spell, which
is a separate and cheaper row, not the general invocation:

| the book prints | all the catalog has | so |
|---|---|---|
| `Levitate (self or others)` | `Air: Levitate` L2/7 | no general `Levitate` exists |
| `Mesmerism` | `Air: Mesmerism` L2/7 | no general `Mesmerism` exists |
| `Wall of Flame` | `Fire: Wall of Flame` L3/15 | no general `Wall of Flame` exists |
| `Spontaneous Combustion` | `Fire: Spontaneous Combustion` L2/5 | none general |
| `Swirling Lights` | `Fire: Swirling Lights` L2/8 | none general |

**So the Heroes Unlimited spell import ADDS five general spells this catalog has
only ever held in Warlock form.** That is worth knowing independently of this
book: a Rifts Ley Line Walker cannot reach `Wall of Flame` today either.

`same_spell_as` is NOT the mechanism for the second group. It links two
retellings of one spell; a general invocation and its tradition counterpart are
different rows with different levels and costs, which is exactly why the
tradition namespace exists.

### D5 - spells per day, and the 2/3 pick cost

**Recorded, not modelled.** Printed 96's footnote makes a powerful spell count
as two or three of a character's spell SELECTIONS, and printed 92-95 give
capacity as spells PER DAY rather than as a P.P.E. pool - the Revised core uses
P.P.E. on none of its 240 pages.

Neither has a column, and inventing one now would be a schema change in service
of a class import that has not happened. The facts go in the class's own prose
when the Magic category is imported. Revisit if and when a Heroes Unlimited
caster is actually built.

### D6 - the offensive-spell asterisk

**Dropped.** Printed 96 marks some spells as strictly offensive. Nothing in the
catalog or the wizard reads such a tag, no class restriction depends on it, and
a column written once and read never is the shape `claim-audit` keeps finding.

### D7 - the robot and super-vehicle construction systems

**Not imported**, on the same reasoning `BOOK-INGEST-AUDIT` F3 used for Phase
World's vessels. Both are point-budget BUILDERS - robots at printed 141-152,
super-vehicles at 80-87 - and the catalog has no builder of any kind; `gear`
holds one `mdc`, one `damage`, one `range`. Importing the parts lists without
the budget rules would produce rows nothing can assemble.

### D8 - the W.P. Ancient/Modern split

**One category, as today.** The catalog holds 38 rows under a single
`Weapon Proficiencies`, and Heroes Unlimited's split is not a property of a
weapon proficiency - it is which ones a PROGRAM may draw from: printed 28 gives
a `W.P. Ancient Weapons Program` and a `W.P. Modern Weapons Program`, each
"select three".

That is a named list on the program, which `skill_programs` can already express,
and it is the same shape as a class's `spell_traditions_allowed`. Splitting the
category would change 38 existing rows to model a restriction that belongs one
level up.

## Extraction plan

Phase 4 costs money; everything above was free. **D0 is answered, so the scope is
now fixed: this core book, plus PU1 and PU3. D3 is what gates the start.**

Proposed order once green-lit:

1. **Catalog vocabulary first** — the 3 missing skill categories (G4), then the
   16 skill programs and 11 educational levels from printed 27-28. Free of the
   super-ability question entirely.
2. **~12 new spells** from printed 96-103, plus the 4 renames and the 6 alias
   decisions from D4. Two independent readings available (index and block).
3. **5 psionic powers** from printed 128-135.
4. **The 10 power categories** as class rows, with their 13 sub-types as
   variants — only after D1's slot mapping is built.
5. **69 super abilities** from printed 163-192 — only after D3's table exists.
6. **Weapons and equipment** from printed 193-220, batched by kind.

What is deliberately left, with the reason:

- **Robot and super-vehicle construction (G7)** — the catalog has no builder,
  and `gear` holds one `mdc`, one `damage`, one `range`. Same argument that kept
  Phase World's 25 vessels out, recorded as `BOOK-INGEST-AUDIT` F3.
- **The GM material, printed 228-237** — Quick Roll Villain, two adventures, the
  law. Nothing the catalog has a shape for.
- **The insanity tables, printed 24-26** — reachable later; not part of a
  character's stored state today.

## The slot mapping, as built

D1 said *"Power Category in the R.C.C. slot, Educational Level in the O.C.C.
slot, sub-type as the variant"*. Building it settled four things that sentence
did not, and each was settled by hitting a wall rather than by choosing.

**A Power Category grants super abilities through a block of its own.**
`super_abilities` shipped in PR #1033 as the third member of the family `magic`
and `psionics` form, gated on the TIER. Before it there was a table of 364 rows
no class could reach.

**A roll for a PACKAGE is an ability choice group, not a variant.** Experiments'
Table C is six whole outcomes - *"one major and three minor"* against *"four
minor"* - and `variants` cannot carry a power block: `VARIANT_OVERRIDES` lists
`bonuses` and `skill_overrides` and nothing else that grants. An entry in
`special_abilities` can, because `ABILITY_GRANTS` now includes
`super_abilities`, so the six outcomes are six named options under one
`{ choose: 1 }`. The same shape carries the Alien's appearance, environment and
power-source tables.

**The random tables that MODIFY a character are ability choice groups too.**
The Alien's thirteen appearances and eight homeworld environments, the Mutant's
sixteen unusual characteristics, the Experiment's thirteen side-effects: each is
a named option carrying `bonuses`, offered as `{ choose: 1, from: [...] }`. That
is the whole of `BOOK-INGEST-AUDIT` F78's problem - a creation-time roll table
that permanently modifies the character - solved for this book without the
feature F78 asks for, because these tables grant BONUSES and nothing else.

**An Educational Level is an O.C.C., and so is an Alien's education.** Printed
27 exempts only Special Training and Physical Training from the Educational
Level table - but the Alien's STEP FIVE prints its own five-outcome education
table, which REPLACES it. Those five are O.C.C.s beside the standard eleven, and
the Alien R.C.C. names them in `occ_restrictions: { only: [...] }`. That key
takes class ids, so it cannot be written until they exist; the Alien ships
without it and gains it in a `fix-` script afterwards.

Why they are O.C.C.s rather than anything else: an education package is a
CATEGORY MIX plus a secondary-skill count - *"two science and twelve secondary
skills"* - and nothing but a class can hold one. A variant carries
`skills_additional` and `related_skills_count` and no `skills` block at all; an
ability carries `related_skills_count` and nothing else. Both were tried.

### What the chassis still cannot say

- **A second choice group cannot be conditioned on the first.** The
  Super-Soldier's three enhancements are the Super-Soldier's, and a build that
  did not take that option can still open the group. The book's own text is the
  only rule, as it is at the table.
- **A branch that swaps one power kind for another is not expressible.** The
  Mutant's STEP FOUR offers psionics INSTEAD of two super abilities, and a class
  granting the abilities outright cannot also offer a branch that grants none.
  A psionic mutant is built as the Psionics category.
- **`campaigns.system` is still two values** (D2), so no Heroes Unlimited
  campaign can be created and none of this can be played yet. That is
  `BOOK-INGEST-AUDIT` F73, filed one book earlier by the Nightbane survey.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | — | four books cached (557 pp); `books.json` registered all four; offsets measured and verified by the suite; `BOOK-INGEST-AUDIT` F73 filed; survey written. **No data applied, no schema change.** |
| 2026-09-13 | #999 | all three Powers Unlimited books surveyed in full; **D0 answered** - build against the Revised core, take PU1 and PU3, EXCLUDE PU2. `BOOK-INGEST-AUDIT` F79 filed. |
| 2026-09-13 | #1025 | **D3 taken**: migration `057-super-abilities.sql`, the fifth kind of power. No cost column and no level column, which is the reason the table exists. |
| 2026-09-13 | #1026 | `super_abilities` declared as the eighth catalog in `js/catalog-fields.js`. |
| 2026-09-13 | #1027 | the Revised core's **69 super abilities**, printed 163-192. |
| 2026-09-13 | #1028 | Powers Unlimited One's **170 super abilities**. |
| 2026-09-13 | #1029 | Powers Unlimited Three's **125 super abilities**. Catalog total **364**. |
| 2026-09-13 | #1030 | **D4-D8 answered**; the decision record closed. |
| 2026-09-13 | #1031 | stat-block repair on 15 core abilities - a `savings_throw` key typo that left 0 of 364 rows with a saving throw, and a `range` that had swallowed 621 characters of prose. |
| 2026-09-13 | #1032 | the core's **16 new spells**, printed 96-103. Spells **919 -> 935**. |
| 2026-09-14 | #1033 | **D1's R.C.C. half built**: the `super_abilities` grant block, wired from the parser through the wizard, the create validator and the sheet. `BOOK-INGEST-AUDIT` F81 filed. Code only. |
| 2026-09-14 | this PR | the core's **4 new psionic powers**, printed 128-135, of thirty-three extracted. Psionics **125 -> 129**. Plus a folio repair on **23 super abilities**. |
| 2026-09-14 | this PR | **NINE of the ten Power Categories as R.C.C. classes** - Aliens, Bionics, Experiments, Hardware, Magic, Mutants, Physical Training, Psionics, Robotics. Classes **288 -> 297**. Plus the 5 skills Hardware needs (skills **379 -> 384**), and `class-check` taught to look inside a `from` list. Special Training is the tenth and is five separate classes; it follows. |
| 2026-09-14 | this PR | **SPECIAL TRAINING, the tenth category, as FIVE classes** - Ancient Master, Hunter/Vigilante, Secret Operative, Stage Magician, Super Sleuth. Classes **297 -> 302**, skills **384 -> 388**. **All ten Power Categories are now imported.** |

Earlier also, ahead of the ledger: Powers Unlimited One's new psionic powers
(`af196d9`), which is why the psionic count moves from 125 rather than from 116.
**That commit's subject line says EIGHT and production holds NINE** rows citing
Powers Unlimited One - counted 2026-09-14. The rows are the authority; the
subject line is not, and it cannot be corrected now.

### What remains

`node scripts/source-coverage.mjs --remote` has not been run for these slugs —
run it from here on, now that production rows cite three of the four books.

**The ten Power Categories are the outstanding work**, plus the Educational
Levels they compose with; see *The slot mapping, as built* below.
