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

**Decision D0 is therefore open and is not this session's to make.** See
Decisions.

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

Recorded for a green-light pass, not settled here. D1-D3 were answered by Nate
on 2026-09-12 before the survey was written; D0 and D4-D8 are open.

| id | question | status |
|---|---|---|
| **D0** | **which edition** - Revised only, get an HU2 core, or adapt | **OPEN.** All four books are surveyed so this can be decided on content. See the edition section |
| **D1** | how deep to integrate | **ANSWERED** - a third `system` value reusing the class chassis: Power Category in the R.C.C. slot, Educational Level in the O.C.C. slot, sub-type as the variant |
| **D2** | campaigns or catalog first | **ANSWERED** - catalog and classes first; `campaigns.system` `CHECK` is left alone, so HU rows exist before an HU campaign can |
| **D3** | where super abilities live | **ANSWERED** - a new `super_abilities` table with a minor/major tier column. A schema change, so NOT this session |
| **D4** | the 6 unsafe alias matches above - rename, new row, or `same_spell_as` | OPEN. Affects ~6 rows |
| **D5** | spells-per-day and the 2/3 pick cost (G9) - model, or record in `extraction_notes` | OPEN |
| **D6** | the offensive-spell asterisk - a tag, or dropped | OPEN. Recommend dropped; nothing reads it |
| **D7** | the two construction systems (G7) - deliberately not imported, as `BOOK-INGEST-AUDIT` F3 decided for vessels | OPEN. Recommend the same answer, for the same reason |
| **D8** | W.P. Ancient/Modern split (G5) - two categories, or one with a tag | OPEN |

## Extraction plan

Phase 4 costs money; everything above was free. **Nothing is extracted until D0
is answered**, because the edition decides whether the supplements join it.

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

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | — | four books cached (557 pp); `books.json` registered all four; offsets measured and verified by the suite; `BOOK-INGEST-AUDIT` F73 filed; survey written. **No data applied, no schema change.** |

### What remains

`node scripts/source-coverage.mjs --remote` has not been run for these slugs —
no production row cites any of the four books yet, so the report would be four
zero rows. It belongs here from the first data PR onward, not before.
