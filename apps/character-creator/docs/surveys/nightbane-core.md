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
before it. The gap analysis is in *What the app cannot express yet*, below.

**CORRECTED 2026-09-12 (PR #996).** This paragraph ended by saying nothing in
the catalog could cite this book until `system` accepted a third value. That was
wrong: `source_book` is free text in every table that holds it, and production
has held `Lore: Nightbane` with a NULL system since long before this survey. What
was actually gated was system-TAGGING a row, creating a Nightbane campaign, and
passing a class through the parser — and the first and third of those are open as
of that PR. See D1.

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
| **126–127** | An Alphabetical List of Invocations by Level | every spell's level — **and a cost that is WRONG for sixteen spells**; the stat blocks are the authority for cost (corrected by the spell import) |
| **69** | An Alphabetical List of All Psychic Abilities | every psionic power and its category |
| **48** | Skill List by Category | every skill and its category |
| **107** | Alphabetical Nightbane Talents List | the Talent roster, split Common / Elite |

**Printed 233 is the most valuable page in the book** and it is clean in the
text layer as well as on a render. The twelve ladders:

**CORRECTED 2026-09-16 (PR #1125): a ladder here is NOT evidence an entry is
playable, and the table row above says it is.** New West and Spirit West both
settled that playability is stated on each entry's own page; this book is a
fourth where it holds, since the Nightlord and the Priest of Night have ladders
and are NPC-tagged. Printed 233 settles canonical names and experience; D3
settles who is playable.

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
| **Nightbane Talents** | 106–115 | **25** — 21 Common, 4 Elite (the last two Elite Talents finish on printed 115, past a full-page illustration on 114) |
| Magical O.C.C.s | 115–120 | four classes |
| **Magic** | 121–150 | **127 invocations, levels 1–13** |
| Denizens, Nightlords, Vampires, Guardians | 158–192 | 17 more class entries |
| Enemies and minor NPCs | 198–201 | five templates, **no ladders** |
| **Weapons and equipment** | 204–232 | **~640–690 priced items** (first surveyed as ~280; corrected by D4) |
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
  **WRONG, corrected 2026-09-16 (PR #1126):** every car and motorcycle on printed
  231 prints A.R., S.D.C., speed, range and cost; printed 232 holds three aircraft
  and five underwater vehicles, with the gadgets only at its foot. Migration 062
  gave `vehicles` an A.R. and S.D.C., and Heroes Unlimited imported these same
  vehicles as rows. See D4.

### Currency is US dollars

Every price in the book is a dollar figure, and the class `Money:` lines are
cash and possessions in dollars.

**CORRECTED 2026-09-12 (PR #996).** This said `js/rules.js` returns Gold for
`palladium-fantasy` and credits for everything else, and that neither was right
here. `currencyLabel` had a third arm from the day it was written and returned
`Money` for an unknown system; the files that really fell through to credits
were `codex.js` and `sheet.js`. All three now say **Dollars** for `nightbane`.

## Classes

**Twenty-one entries carry a ladder on printed 233.** Page ranges are the
entry's own, read off the cache.

| class | printed | ladder | note |
|---|---|---|---|
| Psychic **P.C.C.** | 68 | Ashmedai, Psychic & Sorceror | the first P.C.C. this catalog would hold |
| Nightbane R.C.C. | 87–90 | Nightbane & Guardian | four skill packages — **D2: four package O.C.C.s** |
| Sorcerer O.C.C. | 115–116 | Ashmedai, Psychic & Sorceror | |
| Mystic O.C.C. | 117–118 | Snakebird & Mystic | |
| Nightbane Sorcerer O.C.C. | 118–119 | Nightbane Sorceror & Nightbane Mystic | |
| Nightbane Mystic O.C.C. | 119–120 | Nightbane Sorceror & Nightbane Mystic | |
| Doppleganger R.C.C. | 158–160 | Dopplegangar | |
| Hound R.C.C. | 161 | Hound & Hunter | **excluded — D3** (a flat refusal) |
| Hound Master R.C.C. | 162–163 | Hound Master | **excluded — D3** (advised against) |
| Hunter R.C.C. | 164 | Hound & Hunter | |
| Ashmedai | 165–166 | Ashmedai, Psychic & Sorceror | |
| Namtar / Hollow Men | 167 | Nemtar/Hollow Men | |
| Snake Bird R.C.C. | 169 | Snakebird & Mystic | |
| Nightlord R.C.C. | 173–174 | Nightlord | **excluded — D3** (NPC villain, unfit to play) |
| Ba'al-Zebul R.C.C. | 175–176 | Nightprince & Vampire | **excluded — D3** (discouraged) |
| Priest of Night O.C.C. | 177 | Priest of Night | **excluded — D3** (tagged NPC Villain) |
| Master Vampire R.C.C. | 179–180 | Nightprince & Vampire | **excluded — D3** (not recommended) |
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

**CORRECTED 2026-09-16 (PR #1125), and this section is left standing as the
record of what the survey believed.** Three things in it are wrong:

- **The flat refusal on printed 162 is the HOUND's**, ending the Hound entry in
  the left column. The Hound Master's own note, in the right column, only advises
  against playing one — and goes on to say what a player Hound Master is like.
- **It is not twice. Six laddered entries speak against being played** — see D3.
- **The Royal Kreeghor was not this conflict.** Phase World's own survey records
  that its ladder and its page AGREED it was not playable; there was no ladder to
  overrule.

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

**CORRECTED 2026-09-16 (PR #1128): the real gaps are THREE, not five, plus one
this section never counted.**

- **`Suggestion` is not a gap** — D7 resolves it to `Hypnotic Suggestion`.
- **`Healing` has no stat block anywhere.** The Healer section (printed 83-84)
  describes `Healing Touch` and `Increased Healing` and nothing called `Healing`;
  the name exists only on printed 69's list. The claim above that it is a second
  power rested on that list alone. There is nothing to import.
- **So the psionic import is three powers**: Divination, Mediumship/Clairsentience,
  Induce Pain — each re-checked absent from production 2026-09-16, after the Heroes
  Unlimited and Powers Unlimited imports.
- **Uncounted: `Super-Hypnotic Suggestion`**, 20 I.S.P., printed in the vampire
  powers (printed 185) and exclusive to vampires. It is not on printed 69's list,
  which is why the 45 names missed it; it belongs with the vampire classes.

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

**CORRECTED 2026-09-16 (PR #1129), and this section's central finding is
withdrawn.** It compared the catalog with the book's INDEX (printed 126–127), and
**the index misprints costs**. Every stat block in the chapter was then read
(printed 127–150, three extraction slices and a reconcile pass that checked all
of it), and sixteen of the "cheaper" spells print, in their own stat blocks,
exactly the cost the catalog holds — See Aura 6, Sense Evil 2, Telekinesis 8,
Invisibility: Superior 20, Sickness 50, Metamorphosis: Mist 250, and ten more.
**Nightbane does not set its own cost table.** The comparison that should have
been run is stat block against catalog, and it gives:

| the book's 131 described spells | count | stored as |
|---|---|---|
| identical in level and cost, on a row a Nightbane character sees (`NULL` or `both`) | **92** | nothing — class spell lists name those rows |
| cost genuinely differs, the index AND the stat block agreeing | **10** | `Nightbane: <name>` beside the established row |
| identical, but the only catalog row is `rifts`-only (Wards, Summon and Control Rain) | **2** | `Nightbane: <name>` |
| no catalog row at all | **27** | a plain `nightbane` row |

**131, not 127.** The index stops at level 13; the body goes on to five level 14–15
spells (Close Rift, Id Barrier, Restoration, Dimensional Portal, Teleport:
Superior), all already here and identical. And **`Summon Entity` is an index
entry with no stat block anywhere** — nothing to store, the same shape as the
psionic `Healing`. Other index-vs-heading spellings: Night Vision / Nightvision,
Negation / Negation (of Magic), Nightlands Portal / Nightland Portal, Temporary
Insanity / Curse: Temporary Insanity, Summon Rain / Summon and Control Rain.

**What survives of the section above:** levels agree everywhere, `Swim as Fish`
is printed twice and both rows exist, and `same_spell_as` is the mechanism for the
genuine cost differences — decided per pair by `scripts/same-spell-lib.mjs`, which
approved 9 of 12. The data script's header records the three it refused and why.

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

**HALF OF THIS SHIPPED 2026-09-12 (PR #996), and three sentences above are wrong
about the rest.** Left standing as the record; what is true now:

- **`VALID_SYSTEMS` takes `nightbane`**, so a Nightbane class validates. The
  three CHECK constraints are untouched, by Nate's decision — see D1.
- **There are SIX free-text `system` columns, not three.** This paragraph missed
  `enchantments.system`, `imported_classes.system` and `character_drafts.system`.
  `enchantments` mattered: it has one of the five editor dropdowns.
- **"a third value lands in them the day it is written" was true of a data
  script and false of the editor.** `js/catalog-fields.js` filtered an unknown
  system out of `skills.systems` silently and hard-rejected it on a `select`.
- **A FOURTH gate was missed entirely** —
  `functions/api/character-creator/campaigns.js:56` allowlists two values on the
  only route that creates a campaign, which is why the wizard's picker still
  offers two and a Nightbane character cannot be built there yet.
- **Two of the five `options:` arrays deliberately still say two.**
  `gear.system` and `vehicles.system` are the CHECK-constrained columns, so
  offering a third value would put something in the editor the database refuses.
  **No longer true since 2026-09-14 (PR #1037):** migrations 059 and 060 widened
  both CHECKs, and all five dropdowns now offer every system.

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

Recorded rather than resolved on 2026-09-12, in the shape `mystic-russia` used.
**Each decision's answer, once taken, is the `DECIDED` paragraph under its own
heading** - read there, and assume nothing about a decision that has none.

**D1 — how does a third system land?** The CHECK-constraint migration and the
ten vocabulary sites, as one PR or several, and whether it ships before any
Nightbane data at all. Nothing else in the book can be imported first.

**DECIDED 2026-09-12 (PR #996), and the question as written above is wrong in
two places.** Nate had already answered it for the Heroes Unlimited batch the
same day: catalog and classes first, the `campaigns.system` CHECK left alone.
**So there is no migration** — `VALID_SYSTEMS`, the coercion allowlist, three of
the five editor dropdowns, the currency, and the documented vocabulary. Nothing
else. `BOOK-INGEST-AUDIT` F73's outcome note carries the five premises that did
not survive its own audit.

The claim that nothing else in the book could be imported first was the second
error. `source_book` is free text, so a Nightbane spell or skill row could
always have been written with `system` NULL. What was gated is system-tagging a
row, creating a Nightbane campaign, and passing a class through the parser.

**What the decision leaves standing:** the wizard's system picker still offers
two, because `S.system` feeds the campaign POST. A Nightbane class validates and
stores; it cannot yet be built in the wizard. Lifting that is `campaigns.js:56`,
the CHECK on `campaigns.system`, and `renderSystem()` — F73 stays open for it.

**SUPERSEDED 2026-09-14 (PR #1037), and the paragraph above is left as the record
of the day.** F73's deferred half shipped: `campaigns.system`, `gear.system` and
`vehicles.system` all admit `nightbane` (migrations through 060), `campaigns.js`
accepts it, and `renderSystem()` offers it. F73 is closed, in
`BOOK-INGEST-AUDIT.closed.md`. A Nightbane campaign and character can be created;
until the extraction plan ships, there is nothing to build one from.

**D2 — the four Nightbane skill packages.** `VARIANT_OVERRIDES` deliberately
excludes skills, so Basic, Resistance/Spook Squad-Trained,
Nocturne/Seeker/Lightbringer and Warlord cannot be variants of one class. Four
published classes, or one class and a new mechanism.

**DECIDED 2026-09-16 (PR #1124): one Nightbane R.C.C. plus FOUR PACKAGE O.C.C.s,
restricted to each other both ways. No code.** The question offered two answers
and the right one is a third, which neither half named; the premise pass that
settled it found both halves of the question out of date.

**Why not variants — the conclusion held, the reason did not.** A variant is no
longer barred from skills: `VARIANT_OVERRIDES` (`apps/character-creator/js/parser.js`,
read 2026-09-16) now carries `skill_overrides`, `skills_additional` and
`related_skills_count`. What it still cannot change is the related-skill
**categories**, their per-category **bonuses** and the level **schedule** — and
those are exactly where the four packages differ.

**Why not `skills.mos`, the mechanism the question did not know existed.** It is
precisely "N complete skill packages, pick one" (`RETRO-AUDIT` R2, #714; honoured
end to end since `BOOK-INGEST-AUDIT` F82), and it works on an R.C.C. — the Demon
Goblin uses it. But an option can add only fixed skills and choice groups. The
Demon Goblin fit because its packages carry no related or secondary skills; every
Nightbane package carries a related block with its own categories, bonuses and
schedule, and a choice group holds one flat bonus and no schedule.

**Why package O.C.C.s — two precedents, and the book's own structure.** Heroes
Unlimited hit the same shape with its eleven Educational Levels, tried a variant
and an ability, found neither can hold a category mix, and shipped them as
O.C.C.s restricted with `occ_restrictions` (`heroes-unlimited-core.md`, the
section explaining why they are O.C.C.s). And this book already builds that way:
the Nightbane Sorcerer and Nightbane Mystic O.C.C.s (printed 118-120) print a full
skill list on top of the R.C.C.'s natural powers. A Nightbane player therefore
picks the R.C.C. and one of six O.C.C.s — four packages, Sorcerer, Mystic.

**The packages, measured off the cache (printed 88-90).** Four, including the
Warlord package the Contents omits. Each is complete apart from secondary skills:

| package | for | related picks |
|---|---|---|
| Basic | untrained, most teenage and student Nightbane — the default | 10 |
| Resistance/Spook Squad-Trained | militant or guerrilla Factions, or ex-military | 8 |
| Nocturne/Seeker/Lightbringer | magical or scholarly Factions | 8 |
| Warlord | the Warlords, or an ex-gang member | 6 |

Printed 88 frames them as guidelines, requires one (Basic is the untrained case,
and there is no no-package option), and lets a GM allow later Faction training to
add skills. Mutual exclusion is implied, not stated.

**What the class import has to get right — each checked in the code 2026-09-16,
none of it a guess:**

- **Secondary skills live on the R.C.C.** — six, plus more at 4 and 8, stated once
  on printed 88. A pairing takes related and secondary skills from the O.C.C.
  (`combineClasses`, `parser.js:1249-1250`), so **copy them into each package
  O.C.C.**; left on the R.C.C. they are not what a paired character receives.
- **Put no `skills.mos` on the R.C.C.** `combineClasses` falls back to the race's
  `mos` when the occupation has none (`parser.js:1264`), so it would leak into the
  Sorcerer and Mystic pairings too.
- **The experience ladder.** When both halves state an `xp_table` the RACE's wins
  (`parser.js:1164-1170`). The four packages share "Nightbane & Guardian"; the
  Sorcerer and Mystic have their own. So **state the ladder on each O.C.C., not on
  the R.C.C.**, or the Sorcerer is levelled on the wrong table.
- **Restrict both ways** — `occ_restrictions` on the R.C.C. and `race_restrictions`
  on each package — so a package is never offered to a Rifts race.

**D3 — Hound Master and Master Vampire.** Ladder says playable, own page says
not. Phase World excluded the Royal Kreeghor on the same conflict.

**DECIDED 2026-09-16 (PR #1125): SIX entries are excluded, not two, and 15
laddered classes are playable.** The question named two entries; reading every
laddered entry's own page found six, and two of the question's premises false
(corrected under *The ladder and the prose disagree*, above).

| entry | printed | what its own page says | kind | settled by |
|---|---|---|---|---|
| Hound | 162 | cannot be a player character | refusal | precedent |
| Nightlord | 173 | an NPC villain, totally unfit to play | refusal | precedent |
| Priest of Night | 177 | subheading tags it NPC Villain | tag | precedent |
| Ba'al-Zebul | 176 | a GM note calls player Night Princes discouraged | advice | **Nate, 2026-09-16** |
| Hound Master | 162 | not recommended as a player character | advice | **Nate, 2026-09-16** |
| Master Vampire | 180 | not recommended as player characters | advice | **Nate, 2026-09-16** |

**The rule, and where each half comes from.** A flat refusal or an NPC tag
excludes an entry whatever its ladder says — New West and Spirit West. Advice
against playing is a call taken entry by entry, and it has gone both ways here:
Mystic Russia filtered the Rusalka, and imported the Necromancer, whose page
recommends it as an NPC villain. **For these three Nate chose exclusion**, the
Rusalka's answer.

**Where the other 15 stand, so the class import does not re-read them.** Tagged
optional or allowed on their own pages: Doppleganger (158), Snake Bird (169),
Secondary Vampire (181), Wild Vampire (182), Wampyr (188), Guardian (189). Silent:
Psychic, Nightbane R.C.C., Sorcerer, Mystic, Nightbane Sorcerer, Nightbane
Mystic, Hunter, Ashmedai, Namtar — a keyword search, not a line-by-line read, for
the last three. Printed 39 leaves any class to the GM and expects most player
characters to be Nightbane.

**For the class import:** a Rifts class with the id `mystic` already exists, so
the Nightbane Mystic O.C.C. needs a distinguished id.

**D4 — the ~280 gear entries.** Modern real-world equipment at dollar prices,
against a catalog that already holds Rifts equivalents of much of it. All of it,
weapons only, or none.

**DECIDED 2026-09-16 (PR #1126), on Nate's word: import ALL of it as
`nightbane` rows — gear AND vehicles — one row per book.** Both of the question's
premises were wrong, and correcting them is what made this a real choice rather
than a size estimate.

**The count was not ~280.** That figure counted lines containing `Cost`, and it
misses every table priced without the word — both ancient-weapon tables, the
holsters, ammunition, body armour, the optics tables, containers and the clothing
lists. Read page by page, the chapter is **~640–690 priced items**: roughly 117
ancient and oriental weapons, 51 firearms, ~30 heavy, special and energy weapons
with their clips, ~21 incendiaries, gases and explosives, ~19 miscellaneous
weapons, ~37 accessories, ~15 ammunition, 17 body armours, ~32 optics, ~84
communications and sensor items, 36 containers, ~69 miscellaneous, ~111 clothing,
26 priced vehicles plus 8 unpriced, and 8 Special Gimmicks. **Weapons and armour
alone are ~255.** A range, because variants and consumables are counted apart;
the count is the artefact the import must reproduce, not this sentence.

**The overlap is Heroes Unlimited, not Rifts, and it is nearly total.** Palladium
reprints this chapter section for section in Heroes Unlimited, and HU imported all
of it: **703 gear rows and 49 vehicles** under `heroes-unlimited` (`--remote`,
2026-09-16). Sampled against Nightbane's pages, prices and damage agree almost
everywhere. Rifts shares two items at most. **But a Nightbane campaign cannot see
any of HU's rows:** the items endpoint returns only `system IS NULL`, the
campaign's own system, or `both` (`functions/api/character-creator/items.js:19`),
and retagging them `both` would hand dollar prices to Rifts and Palladium
Fantasy characters. Sharing HU's rows with a Nightbane campaign — a code change —
was offered and declined in favour of the book's own rows.

**How the import must work — measured, not guessed:**

- **Read every value off Nightbane's page. Do not copy HU's row.** They diverge
  where it matters: the Bo Staff's table price and HU's corrected one differ; HU's
  Guisarme and all five shotguns carry no damage where the page prints it.
- **Four firearms HU skipped are here too**: Browning GP 35, FN 140 Double-Action,
  Barracuda, .38 Trident Super 4 — HU prints them, its import missed them. And the
  **eight Special Gimmicks** are in no HU gear row.
- **Slugs take `-nb`, the way HU's took `-hu`.** `gear.slug` and `vehicles.slug`
  are UNIQUE while names are not; HU kept each shared name and suffixed the slug
  (`arab-mace-hu`). Same name, slug `<name>-nb`.
- **Both cache faults are in this chapter, and the detector sees only one.**
  `corrupt_pages` lists nine cache pages inside it (205, 206, 209, 210, 216, 219,
  220, 223, 226 — cache numbering, so printed one lower); render those.
  `substituted_digits` lists NONE here, yet the cipher is present (a price reading
  `$4S0.00`), so read every figure as the number it can only be.
- **Gear before the classes that cite it.** The Sorcerer, Mystic and Namtar name
  specific equipment in their standard kit, and a class resolves gear by slug; a
  class citing a slug that does not exist yet fails the gear-citation check.

**D5 — the Morphus generator.** File as a `BOOK-INGEST-AUDIT` finding and ship
the Nightbane R.C.C. without it, per the standing rule that data ships with its
book and unasked-for code waits — or treat it as in scope, which makes it a
tier-2 decision Nate takes.

**DECIDED 2026-09-16 (PR #1133), on Nate's word: BUILD THE GENERATOR FIRST.** The
Nightbane R.C.C., its four package O.C.C.s and the Nightbane Sorcerer and Mystic wait
for it; every other class in the book does not, and ships ahead.

**Building it means building the second body too.** A Morphus result is a set of
bonuses to a form the app cannot hold - `BOOK-INGEST-AUDIT` F74, taken 2026-09-15 at
record-and-stop with the remedy undesigned. A generator that stores results nothing
applies is the "silent storage" `class-import` forbids, so F74's remedy is in scope
here as well.

**The tables, measured off the cache and renders (2026-09-16), and two things the
question did not know:**

- **19 tables, 154 entries, printed 91-106** - one page past this survey's 91-105:
  Gun Limbs, the last Biomechanical entry, heads printed 106. 36 entries route or
  combine; 118 carry effects. Every one is `Roll or select`.
- **Two tables the book routes to do not exist.** Animal Form 01-07 sends to a Bear
  Table and 08-14 to an Amphibian Table; neither is printed anywhere in the book.
- **The effects are mostly numbers a sheet can add:** Horror Factor on ~108 entries
  (base 6, cap 18, three entries SET it), S.D.C. ~75, P.S./P.P./P.E. ~46/34/34, speed
  ~31, initiative ~33, perception ~34, extra attacks ~13. Natural weapons are dice
  attacks; senses, size and ~29 restrictions are prose. No P.P.E. or save bonuses.
- **Four Elite Talents gate on the table a result came from** (Stigmata, Biomechanical,
  Animal Form), so a stored Morphus records its table, not just its effects.

**Nate's three answers (2026-09-16), which fix the product shape:**

1. **The sheet toggles between Facade and Morphus.** One sheet, a form switch;
   attributes, pools, Horror Factor, speed and bonuses redraw for the form. Not two
   blocks side by side.
2. **A route to a table the book does not print is a reroll** in random mode and is
   not offered in pick mode. Nothing is invented; the gap is recorded on the catalog
   row.
3. **Roll, pick, or mix** - the book's own three modes (printed 85, 91). Every step
   offers a roll and a picker, and the routes are followed either way.

**The build, as separate PRs, each merged before the next:** (1) a Morphus catalog -
schema, catalog config and the 154 entries as data; (2) the second body - the
Facade/Morphus delta on the class, the Morphus stored on the character, and the sheet
toggle; (3) the wizard generator; (4) the Nightbane R.C.C. and the classes that pair
with it. `variants` stays refused for the second body, for the reasons F74's closure
records.

**D6 — `W.P. Archery and Targeting`.** One book row against two catalog rows.

**DECIDED 2026-09-16 (PR #1127): the name resolves to the existing `W.P.
Archery` row. No new row.** The framing was wrong — it is not one book row
against two catalog rows, because neither catalog row, nor the two added
together, is the book's skill — and the repo had already answered this exact name.

**What the book prints (printed 58).** One proficiency covering thrown AND bow
weapons: +20 ft range per level, +1 parry at level 1, +1 strike at 2, 4, 6, 8, 11
and 14, rate of fire two at level 1 rising at 3, 5, 7, 9 and 12. **No strike bonus
at level 1.**

**What the catalog holds.** `W.P. Archery` is Rifts Ultimate Edition's — bows
only, strike AND parry at level 1. `W.P. Targeting` excludes bows. Together they
give strike +2 at level 1 where Nightbane gives none, so mapping to either, or to
both, stores the wrong numbers.

**Why resolve to `W.P. Archery` anyway — precedent, twice.** Five Spirit West
classes already grant `W.P. Archery` for the book's "W.P. Archery and Targeting"
and say so in a note (`add-spirit-warrior-class.sql`, `add-totem-warrior-class.sql`,
`add-tribal-warrior-class.sql`, `add-mystic-warrior-class.sql`,
`add-paradox-shaman-class.sql`). And `smoke.mjs` lists the pair as a REAL clash the
duplicate detector must find, so a separately named row would be flagged as a
copy of `W.P. Archery` the day it landed.

**The numbers Nightbane prints are therefore not stored, and that is a gap, not
a choice.** Migration 061's `skill_system_bases` holds a per-game `base` and
`per_level` and nothing else, and a W.P. is carried entirely by `level_bonuses`.
Filed as **`BOOK-INGEST-AUDIT` F102**, which also finds Heroes Unlimited's 14
classes granting a `W.P. Targeting` whose numbers are not the ones HU prints.

**Why it costs little today.** No Nightbane class names this W.P. — a sweep of
every class page, printed 68–192, finds the word only on the skill list, its
description and the record sheet. Classes offer weapon proficiencies generically,
so this is a picker's answer, not a class import's.

**D7 — `Suggestion`.** A Sensitive/Healer power here, `Hypnotic Suggestion`
under Super in the catalog, and this book has no Super category.

**DECIDED 2026-09-16 (PR #1128): `Suggestion` resolves to the existing
`Hypnotic Suggestion` row. No new row, no category change.**

**It is the same power, and the book says so twice over.** Both of its entries
are headed *Suggestion (Hypnosis)*, and elsewhere — the saving-throw rules, Mind
Block, and the vampire power list — the book calls it Hypnotic Suggestion by name.
The Sensitive text is Rifts' almost line for line: same range with eye contact,
same short duration, same standard save.

**But it prints TWO stat blocks, and neither cost is the catalog's.**

| entry | printed | I.S.P. | range | adds |
|---|---|---|---|---|
| Sensitive | 77 | **2** per idea | 12 ft | — |
| Healer | 84 | **4** per idea | 10 ft | a melee round of meditation first; calls itself identical to the Sensitive one |
| catalog `Hypnotic Suggestion` | — | **6** | 12 ft | filed under Super |

**Why resolve it anyway — precedent.** Heroes Unlimited met the identical case:
it prints Hypnotic Suggestion at 2 I.S.P., and its import names the catalog's
6-I.S.P. Super row in a list (`add-hu-psionics-class.sql`). Its core-psionics
script states the reasoning — a category from another book is an assignment, and
a named list replaces the category gate outright (`add-hu-core-psionics.sql`). A
second row would also split the one name two games print.

**The costs are therefore not stored, and that is a gap, not a choice** —
`psionic_powers` has one `isp` and no per-system home. It is filed as
**`BOOK-INGEST-AUDIT` F102**, together with the matching W.P. gap from D6.

**A Nightbane character can reach it.** The book calls the Psychic a master
psionic (printed 69), and the wizard gives a master all four categories including
Super (`app.js`, where Super is master-only). A class that names it in a list
bypasses the category gate regardless.

## Extraction plan

Phase 4 costs money; everything above was free. **Nothing is extracted until D1
is settled**, because a row with no system it can legally carry cannot be
written.

Once it is, in this order:

1. **SHIPPED — PR #1129: 39 rows, not the 123 planned here** (see *CORRECTED* under the spell diff). **127 spells** from printed 126–150 — two readings each, the index at
   126–127 and the `P.P.E.:` line in the description. 96 of them get
   `same_spell_as` pointing at the existing row; 27 are new; 4 are the false
   gaps above and are not written at all. Batch by the index's level headings,
   and carry the level from the index rather than the page position.
2. **SHIPPED — PR #1130: 1 skill, 2 per-system bases, 5 re-citations, 3 psionic powers.** **3–5 skills** and **3 psionic powers** (Divination, Mediumship/Clairsentience,
   Induce Pain — D7 corrected the five) — small enough for one pass.
   `Super-Hypnotic Suggestion` ships with the vampire classes, not here.
3. **SHIPPED — PR #1131: all 25 Talents.** **25 Talents** from printed 106–115 (not 114: Swarm Self's tail
   and all of Lord/Lady of the Wild are on 115). The storage question was settled by F76; D5 did not block,
   because a prerequisite naming a Morphus table is free text.
4. **IN PROGRESS - #1135: Psychic, Sorcerer, Mystic.** **The classes**, one batch per section, cited to the entry's own pages. The Nightbane R.C.C. and its pairings wait for D5's generator.
5. **SHIPPED — PR #1132: 655 gear rows and 35 vehicles**, taken before the classes. **Gear and vehicles, all of it** — D4: ~640–690 `nightbane` rows off printed
   204–232, in section batches, before any class that cites gear by slug.

What is deliberately left, with the reason for each:

- **The 19 Morphus tables** — ~~pending D5~~ **in scope by D5 (#1133)**: a catalog, the second body and a wizard generator, built before the Nightbane R.C.C.
- **The five minor NPC templates**, printed 198–201 — no ladder, and the book
  presents them as opposition.
- **Waste Coyote and The Lizard King** — no ladder, an `Experience Level:` line
  instead.
- **Printed 231–232**, the cars and the gadgets — a price and a sentence each,
  with none of the stat block that justifies a `vehicles` row. **Wrong, and moved
  into step 5 by D4**: they carry full vehicle stat blocks, and HU imported the same
  vehicles as rows.
- **Printed 202–203**, the chapter on using other Palladium books inside
  Nightbane — a conversion note, not content.

## Ledger

One line per shipped PR, appended when it merges.

| date | PR | what went in |
|---|---|---|
| 2026-09-12 | — | cache built (248 pp, text layer), offset +1 verified at four folios |
| 2026-09-13 | [#991](https://github.com/NateGrey0130/nates-workshop/pull/991) | this survey, `scripts/books.json` registered, `BOOK-INGEST-AUDIT` F73-F78 filed |
| 2026-09-13 | [#996](https://github.com/NateGrey0130/nates-workshop/pull/996) | D1 / F73, catalog half: `VALID_SYSTEMS` and the free-text catalogs take `nightbane` (Heroes Unlimited alongside) |
| 2026-09-14 | [#1037](https://github.com/NateGrey0130/nates-workshop/pull/1037) | F73's blocking half: the three CHECKs, `campaigns.js` and the wizard picker |
| 2026-09-15/16 | #1079-#1081, #1084-#1088, #1092, #1094-#1098 | app side of F74-F78 and F101: F74 recorded, F75 projected Horror Factor, F76 the `talents` catalog and its grants, F101 Talent purchases and permanent P.P.E.; F77 and F78 DECLINED. **No Nightbane rows** — these rows were added on 2026-09-16, when the ledger had not been kept |
| 2026-09-16 | [#1124](https://github.com/NateGrey0130/nates-workshop/pull/1124) | **D2 decided**: one R.C.C. plus four package O.C.C.s, no code. Survey only |
| 2026-09-16 | [#1125](https://github.com/NateGrey0130/nates-workshop/pull/1125) | **D3 decided**: six entries excluded (three by the book's refusal or tag, three on Nate's word), 15 playable. Survey only |
| 2026-09-16 | [#1126](https://github.com/NateGrey0130/nates-workshop/pull/1126) | **D4 decided**: all ~640–690 items as `nightbane` gear and vehicle rows, on Nate's word; the chapter count and the vehicles exclusion corrected. Survey and `docs/catalog.md` only |
| 2026-09-16 | [#1127](https://github.com/NateGrey0130/nates-workshop/pull/1127) | **D6 decided**: `W.P. Archery and Targeting` resolves to `W.P. Archery` (Spirit West precedent), no new row; the per-system combat-bonus gap filed as `BOOK-INGEST-AUDIT` F102. Survey and menu only |
| 2026-09-16 | [#1128](https://github.com/NateGrey0130/nates-workshop/pull/1128) | **D7 decided**: `Suggestion` resolves to `Hypnotic Suggestion` (Heroes Unlimited precedent), no new row; the psionic gaps corrected from five to three, and `Super-Hypnotic Suggestion` counted. **All seven decisions taken.** Survey only |
| 2026-09-16 | [#1129](https://github.com/NateGrey0130/nates-workshop/pull/1129) | **Step 1, spells: 39 rows** in `zzzzzzzzzzzzz-nb-spells.sql` - 27 new `nightbane` invocations and 12 `Nightbane:` retellings (9 linked by `same_spell_as`). The survey's cost finding withdrawn: the index misprints, and 92 of 131 spells are already here identical. Applied `--remote` before the merge. |
| 2026-09-16 | [#1130](https://github.com/NateGrey0130/nates-workshop/pull/1130) | **Step 2, skills and psionics.** All 130 skill descriptions compared with the catalog: 88 identical, 27 W.P./hand-to-hand, the rest spelling. Wrote **Lore: Geomancy or Lines of Power** (30/+5), two `nightbane` rows in `skill_system_bases` (Lore: Demons & Monsters 35/+5, Research 50/+5), and **re-cited five skills off `Rifts Skill List`** to printed 52 and 57, where the full descriptions carry the same percentages (`rifts-skill-list` 34 -> 29). Psionics: 42 of 54 stat blocks match on cost; wrote **Divination, Mediumship/Clairsentience, Induce Pain**. Applied `--remote` before the merge. |
| 2026-09-16 | [#1131](https://github.com/NateGrey0130/nates-workshop/pull/1131) | **Step 3, Talents: 25 rows** in `zzzzzzzzzzzzz-nb-talents.sql` - 21 Common, 4 Elite; names from printed 107's list (`Shroud`, `Nightbringer`). Activation `ppe` is the minimum, 0 on the two that vary (Storm Maker, Lord/Lady of the Wild); three clean cost pairs. The chapter runs to printed 115, not 114. A reconcile pass checked every row against the page. Applied `--remote` before the merge. |
| 2026-09-16 | [#1132](https://github.com/NateGrey0130/nates-workshop/pull/1132) | **Step 4, equipment: 655 gear rows and 35 vehicles** in eight section scripts (`zzzzzzzzzzzzz-nb-gear-a..g`, `zzzzzzzzzzzzz-nb-vehicles.sql`), shaped on HU's and diffed row by row against them. Printed 225's communications/surveillance section, never extracted, read here (29 rows). Nightbane disagrees with HU on a handful of values - Heavy Machinegun $6000, 90mm Recoilless 2D4x100, the shotguns' printed damage - and prints none of HU's camping/lock-pick list or military vehicles. Three reconcile passes over every row found two defects, fixed before the apply. `books.json`'s substituted_digits note corrected. Applied `--remote` before the merge. |
| 2026-09-16 | [#1133](https://github.com/NateGrey0130/nates-workshop/pull/1133) | **D5 decided, on Nate's word: build the Morphus generator first**, and with it F74's second body. Tables measured: 19 tables and 154 entries on printed 91-106; Bear and Amphibian are routed to but never printed. Nate's answers: a Facade/Morphus sheet toggle, a reroll for the unprinted tables, and roll/pick/mix generation. The Nightbane R.C.C. and its pairings wait; every other class ships ahead. |
| 2026-09-16 | [#1135](https://github.com/NateGrey0130/nates-workshop/pull/1135) | **Step 5 begins: the three human classes** - Psychic P.C.C. (`nb-psychic`, printed 68-69), Sorcerer (`nb-sorcerer`, 115-117), Mystic (`nb-mystic`, 117-118). Spells and psionics as named lists; ladders read off renders of printed 233, whose text layer mixes columns. `CORE_SDC_BY_CLASS` at 3D6 per printed 36 (not the men-of-arms split). 7 gear stubs. Classes 318 -> 321. Applied `--remote` before the merge. |

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
