# Nightbane RPG (core book) — survey

**Surveyed 2026-09-12**, offline, off the cache. No extraction has been spent
yet: this file is what phases 1–3 of `book-survey` produced, and the extraction
plan at the end is the thing to agree on before phase 4 costs anything.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

**This book is not part of the 2026-08-28 batch** and is deliberately absent
from `BOOK-INGEST-QUEUE.md`, which is the roster for seven Rifts world books.
Nightbane is a **separate game**, published by the same house on the same
engine, and that single fact is what makes this import unlike the eighteen
before it: **nothing in the catalog can cite this book until `system` accepts a
third value.** The gap analysis is in *What the app cannot express yet*, below.

Slug `nightbane-core`. Cached 2026-09-12 from `Nightbane - Core.pdf`, 248 PDF
pages, **text layer** (median 3,925 chars/page — no OCR, no cost, seconds for
the whole book).

## Page offset

**Read it from `scripts/books.json`. Do not re-derive it.**

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. No `page_offset_exceptions`: the
smoke test's *every offset region the caches show is recorded* check passes
against this cache with the single value.

Verified by reading the folio off the page rather than taken from the vote:

| check | reads |
|---|---|
| cache `p005` (a rendered contents page) | `4` |
| cache `p121` last line | `120` |
| cache `p151` last line | `150` |
| cache `p241` last line | `240` |

`printed_pages: 240` is the last **numbered** folio and not where the book
stops. Content ends at **printed 233**, the Experience Tables; printed 234–240
are blank character record sheets and a trademark page. Cache `p242`–`p248` are
Palladium house ads and a catalogue the book does not number.

## Cache health

| key | value |
|---|---|
| `text_layer` | true |
| `welded_pages` | **8** — 141, 208, 216, 234, 236, 242, 244, 245 |
| `corrupt_pages` | **12 pages** — 206 (5), 219 (5), 205 (3), 209 (3), 216 (3), 35 (2), and 14, 105, 210, 220, 223, 226 at one each |
| `substituted_digits` | **45 pages** — worst are 96 (10), 101 (9), 100 (8), 98 (6), 167 (6) |

**The 45 are the ones that will cost money if they are forgotten.** This is the
third fault class in `book-survey` §0 — a digit set as a letter that looks like
it — and **a render does not fix it, because the damage is in the ink.** Read
the token as the dice expression it can only be.

Two places it lands on data an import reads:

- **printed 95–100**, the Morphus tables, where every roll range and every
  attribute bonus is a number.
- **printed 204–232**, the whole weapons and equipment chapter, where the prices
  are.

`corrupt_pages` and `substituted_digits` are separate keys on purpose and need
**opposite** remedies. Four of the twelve corrupt pages (205, 206, 209, 216) sit
inside the weapons chapter, so that chapter carries both faults at once: render
the page for the corrupt characters, and read the dice and prices contextually
because the render will not help there.

## The book's authority tables

| printed | table | states |
|---|---|---|
| **233** | Experience Tables | which entries are playable, and the canonical spelling of each — **twelve ladders naming twenty-one classes** |
| **126–127** | An Alphabetical List of Invocations by Level | every spell's level **and** its P.P.E. cost, in one place |
| **69** | An Alphabetical List of All Psychic Abilities | every psionic power and its category |
| **48** | Skill List by Category | every skill and its category |
| **107** | Alphabetical Nightbane Talents List | the Talent roster, split Common / Elite |

**Printed 233 is the most valuable page in the book** and it is clean in the
text layer as well as on a render. The twelve ladders:

| ladder as printed | covers |
|---|---|
| Nightbane & Guardian | Nightbane, Guardian |
| Nightbane Sorceror & Nightbane Mystic | Nightbane Sorcerer, Nightbane Mystic |
| Ashmedai, Psychic & Sorceror | Ashmedai, Psychic, Sorcerer |
| Snakebird & Mystic | Snake Bird, Mystic |
| Wampyr | Wampyr |
| Nightprince & Vampire | Ba'al-Zebul, and the three Vampire R.C.C.s |
| Dopplegangar | Doppleganger |
| Priest of Night | Priest of Night |
| Nightlord | Nightlord |
| Nemtar/Hollow Men | Namtar |
| Hound & Hunter | Hound, Hunter |
| Hound Master | Hound Master |

**The table and the rest of the book disagree about three names**, and in each
case the body of the book is the majority reading:

| printed 233 | the entry's own heading | where |
|---|---|---|
| Nightprince | Ba'al-Zebul | printed 175; the index at printed 6 says *Nightprinces R.C.C. 175*, so both spellings are the book's |
| Nemtar | **Namtar** — 18 occurrences on its own page | printed 167 |
| Dopplegangar, Sorceror | Doppleganger, Sorcerer | printed 158, 115 |

**The spell index is printed once, not twice.** There is no second cost table to
reconcile it against, so each spell's cost has exactly **two** independent
readings: the index at printed 126–127, and the `P.P.E.:` line in the spell's
own description at printed 127–150. Both must be read; a single reading is a
transcription rather than a reconciliation.

**A trap in the Contents.** Printed 4–5 lists **three** Nightbane skill
packages. Printed 90 carries a **fourth** — a Warlord package the Contents does
not mention. Survey from the pages, not the Contents.

## Inventory

Counted by structure over all 248 cached pages, not by reading prose.

| section | printed | what is there |
|---|---|---|
| Setting, lore, campaigns | 7–32, 151–157, 193–203 | nothing importable |
| Character creation rules | 33–47 | the same eight attributes, alignments, insanity, experience |
| **Skill list and descriptions** | 48–60 | **132 listed entries, 129 unique names, 15 categories** |
| Combat, psychic combat, Horror Factor | 60–66 | rules |
| **Psionics, and the Psychic P.C.C.** | 67–84 | **55 listings, 45 unique names**, three categories |
| **The Nightbane R.C.C.** | 85–90 | one R.C.C. and **four** skill packages |
| **The Morphus generator** | 91–105 | **19 random tables** |
| **Nightbane Talents** | 106–114 | **25** — 21 Common, 4 Elite |
| Magical O.C.C.s | 115–120 | four classes |
| **Magic** | 121–150 | **127 invocations, levels 1–13** |
| Denizens, Nightlords, Vampires, Guardians | 158–192 | 17 more class entries |
| Enemies and minor NPCs | 198–201 | five templates, **no ladders** |
| **Weapons and equipment** | 204–232 | **~280 priced entries** |
| **Experience Tables** | 233 | the playability authority |

### Things this book has zero of, checked rather than assumed

- **No M.D.C. anywhere.** This is an S.D.C. game set in the present day. Every
  class states S.D.C. and Hit Points and nothing else, so `CORE_SDC_BY_CLASS`
  in `js/compose.js` is the right home for the ones that state neither.
- **No Super-Psionics category.** Printed 69 lists exactly three — Sensitive,
  Physical, Healer — against the catalog's four.
- **No vessels worth the `vehicles` table.** Printed 231 is a **single page** of
  civilian cars and vans with a price and little else, and printed 232 is
  gadgets. There is no stat block here of the kind that filled 55 rows from
  Triax.

### Currency is US dollars

Every price in the book is a dollar figure, and the class `Money:` lines are
cash and possessions in dollars. `js/rules.js` returns Gold for
`palladium-fantasy` and credits for everything else; neither is right here.

## Classes

**Twenty-one entries carry a ladder on printed 233.** Page ranges are the
entry's own, read off the cache.

| class | printed | ladder | note |
|---|---|---|---|
| Psychic **P.C.C.** | 68 | Ashmedai, Psychic & Sorceror | the first P.C.C. this catalog would hold |
| Nightbane R.C.C. | 87–90 | Nightbane & Guardian | four skill packages |
| Sorcerer O.C.C. | 115–116 | Ashmedai, Psychic & Sorceror | |
| Mystic O.C.C. | 117–118 | Snakebird & Mystic | |
| Nightbane Sorcerer O.C.C. | 118–119 | Nightbane Sorceror & Nightbane Mystic | |
| Nightbane Mystic O.C.C. | 119–120 | Nightbane Sorceror & Nightbane Mystic | |
| Doppleganger R.C.C. | 158–160 | Dopplegangar | |
| Hound R.C.C. | 161 | Hound & Hunter | |
| Hound Master R.C.C. | 162–163 | Hound Master | **the prose contradicts the ladder — see below** |
| Hunter R.C.C. | 164 | Hound & Hunter | |
| Ashmedai | 165–166 | Ashmedai, Psychic & Sorceror | |
| Namtar / Hollow Men | 167 | Nemtar/Hollow Men | |
| Snake Bird R.C.C. | 169 | Snakebird & Mystic | |
| Nightlord R.C.C. | 173–174 | Nightlord | |
| Ba'al-Zebul R.C.C. | 175–176 | Nightprince & Vampire | |
| Priest of Night O.C.C. | 177 | Priest of Night | |
| Master Vampire R.C.C. | 179–180 | Nightprince & Vampire | **prose contradicts the ladder** |
| Secondary Vampire R.C.C. | 181 | Nightprince & Vampire | |
| Wild Vampire R.C.C. | 182 | Nightprince & Vampire | |
| Wampyr R.C.C. | 188 | Wampyr | |
| Guardian R.C.C. | 189–192 | Nightbane & Guardian | its heading on printed 189 labels it optional player characters |

### No ladder, and therefore not playable

- **Waste Coyote**, printed 168, and **The Lizard King**, printed 170. Both
  carry an `Experience Level:` line giving a GM-assigned level instead of a
  ladder — the same shape that excluded the Dominator from Phase World.
- **Five minor NPC templates**, printed 198–201: Preserver Activist, Nightbane
  Gang Member, Corrupted Police, Night Cultist, NSB Agent.

### The ladder and the prose disagree — the Royal Kreeghor shape, twice

Two entries have a ladder on printed 233 and a sentence in their own entry
saying they are not for players:

- **Hound Master**, printed 162, describes them as predators who cannot be
  player characters.
- **Master Vampire**, printed 180, says they are not recommended as player
  characters. Printed 182 says the opposite for the Wild Vampire, which the same
  ladder covers — so the conflict is inside one ladder, not just between a page
  and the table.

Phase World settled the same conflict against the ladder when the Royal
Kreeghor's heading labelled it NPC villains. **Recorded as an open decision,
not resolved here** — see D3.

## Catalog diff

Run against **production** (`--remote`) on 2026-09-12: 372 skills, 850 spells,
116 psionic powers, 1408 gear, 265 published live classes.

### skills: 132 entries, 113 matched, and only 3–5 real gaps

`node scripts/catalog-diff.mjs --remote --table skills --entries nb-skills.json`
returns **matched 113, disagree 0, missing 19**. Every one of the 19 was
hand-checked against production. **Fifteen resolve to a row the catalog already
holds under a different spelling**, two of those pending a look:

| the book prints | the catalog holds | action |
|---|---|---|
| Laser | Laser Communications | existing row |
| Surveillance Systems | Surveillance | existing row |
| S.C.U.B.A. | SCUBA | existing row |
| Boat: Motor and Hydrofoils | Boat: Motor, Race & Hydrofoil | existing row |
| Horsemanship | Horsemanship: General | existing row |
| Motorcycle | Motorcycles & Snowmobiles | existing row |
| Read Sensory Equipment | Sensory Equipment | existing row |
| Language | Language: Other | the family stand-in, per `parser.js` |
| Writing | Creative Writing | needs eyes — the nearest row, and not obviously the same skill |
| W.P. Battle Axe | W.P. Axe | existing row |
| W.P. Polearm | W.P. Pole Arm | existing row |
| W.P. Sub-Machinegun | W.P. Submachine-Gun | existing row |
| W.P. Heavy | W.P. Heavy Military Weapons | S.D.C. game, so not the M.D. row |
| Track Animals | Track & Trap Animals | existing row |
| Criminal Sciences & Forensics | Forensics | needs eyes — the book files it under Medical |

Genuinely absent, and the only rows this book would add:

- **Counter-Tracking** (Espionage)
- **Forensic Medicine** (Medical) — distinct from both Forensics and Pathology
- **Lore: Geomancy or Lines of Power** (Technical)
- **W.P. Archery and Targeting** — the book prints as ONE proficiency what the
  catalog holds as two, `W.P. Archery` and `W.P. Targeting`. A decision, not a
  rename.

Also matched by alias, and worth knowing: Tracking to `Tracking (people)`, Jet
Fighters to `Military: Jet Fighters`, Tanks and APCs to `Military: Tanks &
APCs`, Streetwise - Drugs to `Streetwise: Drugs`, Identify Plants & Fruits to
`Identify Plants & Fruit`.

### The `rifts-skill-list` phantom: nine of its rows are printed in THIS book

`source-coverage.mjs --remote` reports **34 skills** citing `Rifts Skill List`,
a compiled PDF that is not a Palladium book and has no cache. `book-survey`
§0 says to re-run the search whenever a book is cached, and this is that moment.
**Nine of the 34 are printed on Nightbane's own skill list at printed 48:**

`Lore: Nightbane`, `Lore: Nightlands`, `Lore: Vampires`, `Strategy/Tactics`,
`Toxicology`, `W.P. Revolver`, `W.P. Automatic Pistol`, `W.P. Bolt Action
Rifle`, `W.P. Automatic and Semi-automatic Rifles`.

**Being printed here does not prove the rows' numbers came from here**, and
printed 48 is a list — the base percentages are in the descriptions at printed
49–60. So this is a candidate list for a later PR that checks each row's numbers
against printed 49–60, not a re-citation to make blind. The first three are the
strong ones: they are Nightbane concepts that the Rifts books only cross-refer
to. Doing it would take `rifts-skill-list` from 34 rows to 25.

### psionic_powers: 45 unique names, 39 matched, 5 real gaps

**matched 39, disagree 0, missing 6.** One false gap: `Increase Healing` is the
catalog's `Increased Healing`. Also matched by alias: `Bio-Manipulation` to
`Bio-Manipulation (the evil eye)`, `Impervious to Poison` to `Impervious to
Poison/Toxin`.

The five real ones: **Divination**, **Mediumship/Clairsentience**, **Healing**
(the book lists this *alongside* Healing Touch, so it is a second power and not
a renaming), **Induce Pain**, and **Suggestion** — which needs a decision,
because the catalog's nearest row is `Hypnotic Suggestion` filed under **Super**
and this book has no Super category at all. It files Suggestion under both
Sensitive and Healer.

Ten names appear in two of the book's three categories (Death Trance,
Meditation, Mind Block, Speed Reading, Summon Inner Strength, Total Recall,
Impervious to Cold, Impervious to Fire, Resist Fatigue, Suggestion). That is 55
listings against 45 unique names, and it is the book's own shape rather than a
parse error.

### spells: 127 entries, 96 matched by name, 31 missing — and the costs are a different table

This is the finding that decides how the magic chapter is imported.

**matched 96, missing 31.** Comparing `level`: **2 disagreements**, and both are
artifacts — `Enchant Weapon` matched the catalog's `Enchant Weapon (Minor)` and
`Summon Storm` matched `Water: Summon Storm`, which are different spells.
**On level, this book agrees with the catalog everywhere it can.**

Comparing `ppe`: **28 disagreements**, of which those same two are artifacts.
Of the 26 real ones, **25 are cheaper in Nightbane and one is dearer**:

| | |
|---|---|
| roughly half price at low level | See Aura 6→2, See the Invisible 4→2, Sense Evil 2→1, Sense Magic 4→2, Thunderclap 4→2, Befuddle 6→3, Concealment 6→3 |
| a flat third off at level four | Astral Projection, Charismatic Aura, Cure Minor Disorders, Energy Field, Shadow Meld, Trance — all 10→7 |
| cheaper at the top | Sickness 50→35, Metamorphosis: Mist 250→200, Protection Circle: Superior 300→250 |
| **dearer** | Create Magic Scroll 100→160, Invisibility: Superior 20→25 |

So the levels are shared and the cost table is independently set. **That is
exactly what `spells.same_spell_as` was built for** (migration 049,
`BOOK-INGEST-AUDIT` F26): a second tradition's retelling of the same spell at
its own cost, stored as its own row and linked so the pair can be checked for
drift. It is not a case for correcting the existing rows, and it is not a case
for reusing them.

**Four of the 31 "missing" are false gaps**, hand-checked against production:

| the book prints | the catalog holds | agrees on |
|---|---|---|
| Fingers of Wind | Fingers of the Wind | level 3, 5 P.P.E. — exactly |
| Negate Poisons/Toxins | Negate Poison/Toxin | level 3, 5 P.P.E. — exactly |
| Swim as Fish (the level 4 listing, 6 P.P.E.) | Swim as a Fish (lesser) | level 4, 6 P.P.E. — exactly |
| Swim as Fish (the level 5 listing, 12 P.P.E.) | Swim as a Fish (Superior) | level 5, 12 P.P.E. — exactly |

**The book prints `Swim as Fish` TWICE under one name**, at two levels and two
costs, and the catalog distinguishes the pair. A diff cannot see this — both
book rows carry the same name — so it reads as one spell listed twice. It is
two spells the catalog already holds correctly.

That leaves **27 genuinely new spells**, and they are the Nightbane-specific
ones: the Nightlands rituals and portals, Sense Nightbane, Bind Nightbane,
Summon Nightlord and its avatar, Magic Armor, Night Vision, Paralysis: Superior,
Negation, Charm Weapon, Impression, Midnight Wind, the three Curses, Bonding,
Temporary Enchantment, Temporary Insanity, Summon Rain, Summon Entity.

`Summon Entity` needs eyes before it is added: the catalog has `Summon Entities`
at **level 0** and 150 P.P.E. against this book's level 12 and 250. A level-0
row with a real cost is a half-finished import that the `spell stubs` backlog
count — which keys on level 0 **and** cost 0 — cannot see.

## What the app cannot express yet

None of this blocks the survey. All of it blocks the import, and it is why this
book is not simply the nineteenth data drop.

### 1. `system` is a two-value enum

`VALID_SYSTEMS` in `apps/character-creator/js/parser.js` is `['rifts',
'palladium-fantasy']`, and three tables carry a **CHECK constraint** naming the
same two: `campaigns.system`, `gear.system`, `vehicles.system`. SQLite cannot
alter a CHECK, so those are table rebuilds and a `schema-change` job.

`skills.systems`, `spells.system` and `psionic_powers.system` are free text and
need **nothing** — a third value lands in them the day it is written.

The rest is vocabulary in about ten places: `SYSTEM_LABEL` and the system picker
in `app.js`, the filter in `catalog.js`, the label and currency in `codex.js`,
five `options:` arrays plus an `allowed` list in `js/catalog-fields.js`,
`js/class-template.js`, `js/rules.js`, and the README and `docs/catalog.md`.

### 2. There is no P.C.C.

`VALID_CATEGORIES` in `parser.js` is `['rcc', 'occ']`. The Psychic at printed 68
is a Psychic Character Class and the book means the distinction.

### 3. A Nightbane has two stat blocks, not one

Printed 87 gives the R.C.C. **twice**: Facade attributes rolled 3D6 with S.D.C.
30 and standard hit points, and Morphus with +10 to P.S., P.E. and Spd, +6 to
P.P., +2D6x10 S.D.C., and hit points on a different formula. Most Talents work
only in the Morphus. The class schema has one `attribute_dice`, one `sdc_base`
and one `hit_points_base`, and `VARIANT_OVERRIDES` cannot carry the difference
because a variant may not override skills or abilities. **This is the largest
gap in the book and it is the one the flagship class needs.**

### 4. Talents fit neither spells nor psionics

A Talent costs P.P.E. **permanently to acquire** and P.P.E. again to activate,
and gates on character level and on being in the Morphus. `spells` has one cost
column and its `level` means spell level; `psionic_powers` is I.S.P.

### 5. Horror Factor is a save here, not a stat

`js/derive.js` and `sheet.js` carry `horror_factor` as a bonus to save against
one. A Nightbane **has** a Horror Factor — base 6, raised by the Morphus tables
to a maximum of 18.

### 6. The Morphus generator has no home

Nineteen tables at printed 91–105 that roll attribute modifiers, S.D.C.,
Horror Factor and movement onto a character at creation.

## Open decisions

Recorded rather than resolved, in the shape `mystic-russia` used. None is
answered in this survey and none should be assumed by a later session.

**D1 — how does a third system land?** The CHECK-constraint migration and the
ten vocabulary sites, as one PR or several, and whether it ships before any
Nightbane data at all. Nothing else in the book can be imported first.

**D2 — the four Nightbane skill packages.** `VARIANT_OVERRIDES` deliberately
excludes skills, so Basic, Resistance/Spook Squad-Trained,
Nocturne/Seeker/Lightbringer and Warlord cannot be variants of one class. Four
published classes, or one class and a new mechanism.

**D3 — Hound Master and Master Vampire.** Ladder says playable, own page says
not. Phase World excluded the Royal Kreeghor on the same conflict.

**D4 — the ~280 gear entries.** Modern real-world equipment at dollar prices,
against a catalog that already holds Rifts equivalents of much of it. All of it,
weapons only, or none.

**D5 — the Morphus generator.** File as a `BOOK-INGEST-AUDIT` finding and ship
the Nightbane R.C.C. without it, per the standing rule that data ships with its
book and unasked-for code waits — or treat it as in scope, which makes it a
tier-2 decision Nate takes.

**D6 — `W.P. Archery and Targeting`.** One book row against two catalog rows.

**D7 — `Suggestion`.** A Sensitive/Healer power here, `Hypnotic Suggestion`
under Super in the catalog, and this book has no Super category.

## Extraction plan

Phase 4 costs money; everything above was free. **Nothing is extracted until D1
is settled**, because a row with no system it can legally carry cannot be
written.

Once it is, in this order:

1. **127 spells** from printed 126–150 — two readings each, the index at
   126–127 and the `P.P.E.:` line in the description. 96 of them get
   `same_spell_as` pointing at the existing row; 27 are new; 4 are the false
   gaps above and are not written at all. Batch by the index's level headings,
   and carry the level from the index rather than the page position.
2. **3–5 skills** and **5 psionic powers** — small enough for one pass.
3. **25 Talents** from printed 106–114, once D5 and the Talent storage question
   are settled.
4. **The classes**, one batch per section, cited to the entry's own pages.
5. **Gear**, only if D4 says so.

What is deliberately left, with the reason for each:

- **The 19 Morphus tables** — pending D5.
- **The five minor NPC templates**, printed 198–201 — no ladder, and the book
  presents them as opposition.
- **Waste Coyote and The Lizard King** — no ladder, an `Experience Level:` line
  instead.
- **Printed 231–232**, the cars and the gadgets — a price and a sentence each,
  with none of the stat block that justifies a `vehicles` row.
- **Printed 202–203**, the chapter on using other Palladium books inside
  Nightbane — a conversion note, not content.

## Ledger

One line per shipped PR, appended when it merges.

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | — | cache built (248 pp, text layer), offset +1 verified at four folios |

### What remains

Pasted from `node scripts/source-coverage.mjs --remote`, 2026-09-12. The slug
does not appear, because nothing cites it yet:

```
  free-quebec         49 / 0
  rifts-skill-list     0 / 34
  potm                14 / 4
  cb1                 10 / 0
  dag                  1 / 0
  rifts-core           0 / 1
```

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs             6   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs            2   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

Nothing on either list is this book's — nothing of this book has shipped. The
`rifts-skill-list 0 / 34` line is the one this book can move, by the nine rows
named above.

**`spell stubs 2` is NOT a line this book moves, and this section said it was.**
The two are `Impervious to Symbiotes` and `Open & Close Dimensional Rifts`,
neither of them a Nightbane spell — checked `--remote` rather than reasoned
about. `Summon Entities`, which the spell diff turns up, is level 0 with a real
150 P.P.E. and so is not on that list at all; it is a half-stub the backlog
count cannot see.
