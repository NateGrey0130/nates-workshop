# Rifts World Book 14: New West — survey

Slug `new-west`. Cached 2026-08-28 from `Rifts- World Book 14 New West.pdf`,
226 PDF pages, **text layer** (median ~3,784 chars/page — no OCR, no cost).

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

Surveyed 2026-09-09. The cache was **re-run through `ocr-book.py` first**, which
recomputed the manifest and filled in the `welded_pages` and `corrupt_pages`
keys that did not exist when this book was cached — `BOOK-INGEST-AUDIT` F30 and
F36 landed after 2026-08-28. Both keys are non-empty. See *Pages that need a
render* below; read that section before extracting anything.

## Page offset

**Read from `scripts/books.json`; not re-derived.**

`page_offset: 1` — cache file page = printed folio + 1, so printed folio F is
`p<F+1>.txt` and `read-columns.py <F+1>`. No `page_offset_exceptions`.

Verified twice in passing during this survey rather than assumed: cache `p223`
ends on folio 222, and the full-page plate at cache `p132` carries folio 131.

`printed_pages: 224`, and the registry's `note` explaining why that is not the
222 the manifest measured — printed 223-224 are the experience tables and print
no folio — **is correct as written**. Cache `p224` opens with the tail of the
Ironhorse entry (printed 223) and the experience tables begin on that same page.
Cache `p222` and `p226` are blank; `p225` is the second table page.

## Pages that need a render

`ocr-book.py` reports one welded page and three glyph-corrupt pages. Only two of
the four sit anywhere data will be read from:

| cache | printed | fault | matters? |
|---|---|---|---|
| `p131` | **130** | WELDED — both columns in one text block | **yes** — Keepers of the Desert R.C.C. |
| `p218` | **217** | GLYPHS (1) | **yes** — Techno-Wizard weapons, three priced entries |
| `p143` | 142 | GLYPHS (4) | no — full-page plate, verified by render |
| `p031` | 30 | GLYPHS (1) | no — full-page plate |

Printed 130 and printed 217 must be read off a **render**, not off the cache.
F36's rule applies to printed 217 in particular: a page with corrupt prose is
corrupt everywhere, including in the numbers that look ordinary, and every
figure on that page is a price.

**Fourteen cache pages are near-empty** (`p001 p008 p009 p031 p051 p064 p127
p132 p138 p170 p183 p186 p222 p226`). Four of them fall inside class ranges, so
they were checked rather than assumed: every one carries one or two embedded
images and no text, and the two rendered in full (`p132`, `p143`) are full-page
art plates with the folio printed at the foot. **No page of this cache has lost
text.** `book-survey` §0c.

## The book's authority tables

| printed | table | states |
|---|---|---|
| **223-224** | the experience tables | the playable roster, and which classes share a ladder or borrow one from another book |
| **37** | the Cloud Magic index | every cloud spell's name and P.P.E. cost, grouped by its seven categories |
| **4** | Contents | section ranges |
| **5-8** | Quick Find | a second, alphabetical index by page |

**The experience-table page is the authority that matters, and it is the one a
structural scan does not find.** It settles three things the class pages do not:

- **Fennodi advance on the ladder of the O.C.C. the character takes**, so the
  race carries no ladder of its own.
- **Mining 'Borgs and CyberSlinger cyborgs use the 'Borg tables in the core
  rules**, not a ladder printed here.
- **An experience ladder is not a claim of playability in this book.** Great
  Dream Snakes, Phantasms and the Worm Wraith all get one and all three are
  tagged NPC where they are defined. Playability is stated per entry, on the
  entry's own tag line, and that is the test used throughout this survey.

The Contents page is set in columns and its page numbers detach from their
labels in the text layer — the tail of cache `p005` is a bare run of 48 numbers.
Usable for section ranges after re-pairing by hand; **not** usable as a roster.

Costs in the Cloud Magic section are printed **twice** — once in the index on
printed 37 and once on each spell's own `P.P.E.:` line — so that import is a
reconciliation rather than a transcription. `book-survey` §4b.

## Inventory

Counted by structure over all 226 cached pages, not by reading prose.

| section | printed | what is there |
|---|---|---|
| front matter, setting, territories | 9-36 | narrative, places, organizations |
| **Cloud Magic** | **37-45** | index + **58 index entries** (57 distinct), 58 `P.P.E.` lines, 44 `Saving Throw` lines |
| Colorado, baronies, rodeos, medicine shows | 45-69 | setting; rodeo event resolution rules |
| **New Skills** | **70-81** | **38 `Base Skill:` definitions**, plus W.P.s, snapshooting bonuses and combat notes |
| **O.C.C.s and P.C.C.** | **83-125** | **17 playable occupations** |
| **Racial classes and creatures** | **125-170** | **30 entries**, of which **8 are playable** |
| **Gear, armour, bionics, cyborgs, vehicles** | **171-223** | **79 priced entries**; ~15 `M.D.C. by Location` blocks; 3 cyborg chassis |
| experience tables | 223-224 | the ladders |

### Categories this book defines ZERO of

- **Psionic powers.** Seven `I.S.P.` lines in the whole book and every one of
  them is inside a class or creature stat block — an attribute, not a power
  definition. There is no `I.S.P.` stat-block section anywhere. **No psionic
  import.** Classes that grant psionics draw them from existing catalog rows.
- **Spells outside Cloud Magic.** All 44 `Saving Throw:` lines fall on printed
  37-45. The `P.P.E.` lines scattered through printed 127-170 are the P.P.E.
  attribute in creature stat blocks.

## Classes

### Playable occupations (17) — printed 83-125

| class | printed | ladder (p.223-224) |
|---|---|---|
| Bandit O.C.C. | 83-85 | own |
| Highwayman O.C.C. | 85-87 | own |
| Bounty Hunter O.C.C. | 87-90 | shared with Mountain Giant |
| Gunfighter O.C.C. | 90-92 | own |
| Gunslinger O.C.C. | 92-96 | shared with Wired Gunslinger |
| Justice Ranger O.C.C. | 96-98 | shared with 1st Cavalry |
| **Psi-Slinger P.C.C.** | 98-101 | shared with Lyn-Srial Cloudweaver |
| Saddle Tramp O.C.C. | 101-102 | own |
| Sheriff/Lawman O.C.C. | 102-105 | own |
| Sheriff's Deputy O.C.C. | 105-107 | own |
| Wired Gunslinger O.C.C. | 107-110 | shared with Gunslinger |
| Cowboy O.C.C. | 110-113 | own |
| Mining 'Borg/Prospector O.C.C. | 113-115 | 'Borg tables, core rules |
| Preacher O.C.C. | 115-117 | own, and the ladder line covers two Preachers |
| Professional Gambler O.C.C. | 117-120 | shared with Professional Thief & Smuggler |
| Saloon Bum/Stoolie O.C.C. | 120-123 | shared with Saloon Girl |
| Saloon Girl/Barmaid O.C.C. | 123-125 | shared with Saloon Bum |

**`Psi-Slinger` is a P.C.C., and a scan keyed on `O.C.C.`/`R.C.C.` misses it
entirely.** It was found only because a marker page at printed 98-100 had a stat
block and no heading the scan would match. Any future roster scan of a Rifts
book must include `P.C.C.`

**`Special Sheriff/Lawman` (printed 103) and `Special Wired Gunslinger`
(printed 107) are NOT separate classes.** Each sits inside its base class's
pages and neither appears on the experience tables, where every other playable
class does. Treat both as variants of the class they sit under.

**THE CYBERSLINGER IS NOT A CLASS, and this survey said it was until 2026-09-09.**
CSLNGR Mark I (printed 190), Mark II (191) and Mark III (192-193) each carry an
`M.D.C. by Location` block, a `Model Type`, bionic attributes and a cost — and
**no class block at all.** Checked on all three pages: no `O.C.C. Skills`, no
`O.C.C. Related Skills`, no `Secondary Skills`, no `Money:`, no
`Attribute Requirements`, no `Alignment`. Printed 190 says outright that these
are different types of cyborg body and that all of them fall into the existing
'Borg O.C.C.

**So the resemblance to Free Quebec's cyborg was the wrong way round.** Free
Quebec's four chassis ARE classes — `fq-cyborg-imprimer` and its three siblings
are `imported_classes` rows, each with its own skill list. New West's three are
bodies, and under that same book's precedent a chassis body belongs in
**`vehicles`**, which is where these go: with the gear and vessel import from
printed 171-223, not with the classes. `BOOK-INGEST-AUDIT` F31 is irrelevant to
them.

**The roster is therefore 25 playable classes, not 26** — 17 occupations and 8
racial.

The text layer sets *Saddle Tramp* as `Saddle TVamp` — a ligature fault, not a
second name.

### Playable racial classes (8) — printed 125-170

The book tags each entry on its own line as an optional player character or as
NPC-only. These eight carry the player-character tag:

| class | printed | ladder |
|---|---|---|
| Cactus People R.C.C. | 127-128 | own |
| Fennodi R.C.C. | 128-130 | **none — advances on the chosen O.C.C.'s** |
| Keepers of the Desert R.C.C. | 130-133 | own — **welded page, printed 130** |
| Lyn-Srial (Average Citizen) R.C.C. | 133-134 | own |
| Lyn-Srial Sky-Knight R.C.C. | 134-135 | own |
| Lyn-Srial Cloudweaver R.C.C. | 135-136 | shared with Psi-Slinger |
| Mountain Giant R.C.C. | 136-138 | shared with Bounty Hunter |
| Psi-Ponies R.C.C. | 156-158 | own, marked optional |

**Cactus People and Mountain Giant are invisible to a stat-block scan** — their
headings carry no `R.C.C.` at all, and both were found only by scanning for the
book's playability tag. Psi-Ponies sits 20 pages inside the creature section,
well past where the racial-class chapter appears to end.

### NPC-only, by the book's own per-entry tag

Twenty-two creature entries between printed 139 and 170 are tagged NPC animal,
monster or villain: Desert Sleeper (139), Duckbilled Honker (141), Giant Canyon
Worm (143), Great Dream Snake (144), Great Plains Buffalo (146), Grigleaper
(147), Gwylack (147), Leatherwing (148), Mammoth Brontodon (150), Moss-Backed
Scuttler (151), Oborus-Slitherer (152), Ostrosaurus (153), Panthera-Tereon
(155), Phantasm (158), Rhino-Buffalo (158), Silonar (160), Tiger Claw Raptor
(162), Tree Spider (164), Tri-Tops (164), Tyrannosaurus Rex (166), Whisker
Coyote (168), Worm Wraiths (170).

These are not missing classes. Three of them carry experience ladders and the
book still tags them NPC; see the authority-table section above.

## Catalog diff

Run against **production** (`--remote`). Catalog at survey time: 225 classes,
367 skills, 681 spells, 116 psionic powers, 1249 gear, 143 vehicles.

### classes: 26 missing, 0 false gaps

None of this book's 25 playable classes was in the catalog at survey time. (This read 26 until 2026-09-09; the CyberSlinger is not a class - see the correction under *Playable occupations*.) `gambler`, `ranger`
and `murder-wraith` exist under similar names and are different classes from
other books — check for an id collision at import time, not a name collision.

### spells: 50 missing, 7 already held

`catalog-diff --remote --table spells` over the 57 distinct index entries
returns **matched 7, missing 50, disagree 0**.

The seven Cloud Magic reprints of spells the catalog already holds: Blinding
Flash, Globe of Daylight, See the Invisible, Tongues, Create Water, Calm Storms,
and **Breath of Life, which matched only through an alias** to the catalog's
`Air: Breath of Life` — naming drift, not a gap.

**Cloud Magic states no spell level.** It is a seven-category tradition, not a
leveled ladder, so every new row lands at `level 0`. That convention is already
established and is not this import inventing one: Wormwood's symbiotic magic
(27 rows) and Underseas' Spellsongs (13 rows) are level 0 for the same reason.
The Spellsong rows also carry a tradition prefix in the name, which is the open
question below.

### skills: 4 missing, 9 false gaps out of 13

`catalog-diff --remote --table skills` over 43 entries returns **matched 30,
missing 13**. Nine of the thirteen are rows the catalog already holds under
another name — hand-checked one at a time against the catalog:

| the book prints | the catalog holds | action |
|---|---|---|
| Horsemanship: Exotic | Horsemanship: Exotic Animals | none — the book's own short form |
| Lore: Indians | Lore: American Indians | none |
| Imitate Voices & Impersonation | Imitate Voices & Sounds | none |
| Armorer (Field Armorer) | Field Armorer & Munitions Expert | none |
| Find Contraband, Weapons & Cybernetics | Find Contraband | none |
| Nuclear, Biological, & Chemical Warfare | NBC Warfare | none |
| Underwater Demolitions | Demolitions: Underwater | none |
| Hovercycle | Hovercycles, Skycycles & Rocket Bikes | none |
| Safecracking | Safe-Cracking | none |

**Three are real gaps: History of the West, Prospecting, W.P. Bola.**

**This said FOUR until the import, and `W.P. Snapshooting Specialty` was the
fourth.** It is not a skill this book adds — it is `W.P. Sharpshooting`, which
the catalog already holds from Juicer Uprising p.57. The heading on printed 79
and both indexes spell it *Snapshooting*; the body of that same entry says
*Sharpshooting* throughout, and so do the classes that grant it — printed 108
writes both spellings in one line. Counted across the book: **Snapshooting 9,
Sharpshooting 48.** A name that a book spells two ways is not two skills, and
the diff cannot see that. PR #882 enriches the existing row instead.

**Almost the whole New Skills section is already in the catalog, cited to Rifts
Ultimate Edition p.302-303.** RUE reprints this book's cowboy and horsemanship
skills, and RUE is the later book, so those rows stand and are not re-imported:
Branding, Breaking/Taming Wild Horse, Herding Cattle, Horsemanship: Cowboy,
Lore: American Indians, Lore: Cattle & Animals, Roping, Trick Riding, and the
whole Horsemanship category. **The base percentages agree between the two books
where this survey spot-checked them** — Horsemanship: Cowboy 66, Cyber-Knight
70, Exotic Animals 30, all matching printed 73-74.

`Trick Riding` is stored at `base 0`. That is the catalog's convention for a
non-percentile skill, and New West prints a percentage for it on printed 71.
**Check before changing anything**: `base 0` is shared with every W.P. and every
physical skill, so this may be correct rather than a stub.

**`skills.W.P. Rope` was never this book's, and that is now settled (PR #882).**
It carried `source_book = 'Rifts New West'` with no page range — the whole of
`new-west 0 / 1` in the coverage ledger, and the reason it read 0: an
un-rangeable citation is not checkable. The book's W.P. section on printed 79
defines exactly three — Bola, Whip, Snapshooting Specialty — its skill list on
printed 71 names the same three, and **a grep of all 226 cached pages finds no
`W.P. Rope` anywhere.**

It is Rifts Ultimate Edition's: listed on printed 302 among the Cowboy skills
and 303 among the W.P.s, and **described on printed 306**. Re-cited there. Its
`level_bonuses` already matched RUE's description and were not touched.

### gear and vehicles: not diffed

79 priced entries and ~15 `M.D.C. by Location` blocks, printed 171-223. Not
diffed in this session — the class and spell batches come first, and a gear diff
wants the entry names, which is extraction work.

## Extraction plan

Phase 4 costs money; everything above was free.

1. ~~**Cloud Magic, printed 37-45**~~ — **DONE, PR #881. 58 rows, not the 50
   projected here**, and the difference is the whole of what the category prefix
   costs: a prefix on the category rather than the tradition makes the seven
   spells this book reprints from other traditions into new rows of their own,
   and makes Globe of Daylight **two** rows, because printed 37 lists it under
   both Clouds of Survival and Clouds of Creation. Printed 45 prints the
   Creation heading with a redirect to the survival entry and no stat block —
   verified on a render, not inferred. All 58 costs have two readings and all
   58 agree.
2. ~~**New skills**~~ — **DONE, PR #882. Three rows, not four**, plus two
   corrections to rows other books own: `W.P. Rope` re-cited to RUE p.306, and
   `W.P. Sharpshooting` given New West's definition and its P.P.-scaled bonuses.
3. **The 18 occupations, printed 83-125** — batched by section, ~4 per PR.
   **Batch 1 DONE (PR #883): Bandit 83, Highwayman 85, Bounty Hunter 87, Gunfighter 90.**
   **Batch 2 DONE (PR #885): Gunslinger 92, Justice Ranger 96, Psi-Slinger 98, Saddle Tramp 101.**
   **Batch 3 DONE (PR #886): Sheriff/Lawman 102, Sheriff's Deputy 105, Wired Gunslinger 107, Cowboy 110.**
   **Batch 4 DONE (PR #887): Mining 'Borg 113, Preacher 115, Professional Gambler 117, Saloon Bum 120.**
   **Batch 5 DONE (PR #888): Saloon Girl 123. ALL SEVENTEEN OCCUPATIONS ARE IN.**
   **NOTHING REMAINS in this item.** The CyberSlinger's three chassis are not
   classes and belong to item 5, the gear and vessel pass.
   Read every entry onto the following page; `Money:` sits at the end of each.
4. **The 8 racial classes, printed 125-158** — printed 130 off a render.
5. **Gear and vessels, printed 171-223** — last, and diffed first. Printed 217
   off a render.

What is deliberately left, with the reason:

- **The 22 NPC creature entries, printed 139-170** — the book tags each one
  NPC, per-entry. Importing them would contradict its own statement.
- **Setting: territories, baronies, Silvereno, the rodeo and medicine-show
  rules, organizations, named NPCs (printed 9-69)** — narrative and GM
  procedure, nothing the schema models.
- **Snapshooting bonuses and combat notes, printed 80-81** — combat modifiers
  attached to a W.P., not a catalog row of their own.

### Open questions for the class batches

**Both spell questions were settled on 2026-09-09 and are recorded here as
answers, not questions.** Nate chose the **category** as the name prefix —
`Clouds of War: Cloud Blast` — over a `Cloud Magic:` tradition prefix and over
adding a `spells.category` column.

That single choice answers both. The categories live in the name, which is where
`Air:`/`Earth:`/`Fire:`/`Water:` already put the Warlock spheres, and it is the
only option that leaves the Sky-Knight's grant rebuildable from the catalog: he
gets all of Clouds of War and Clouds of Peace, then one spell per level from any
category **except** Clouds of Creation (printed 134), and `magic.spells_from` is
an explicit list of names with no category column behind it.

The cost is two rows for Globe of Daylight, which the book lists in two
categories — see the import note below. `BOOK-INGEST-AUDIT` F21 and F35 are the
standing edges of prefixed names and are unchanged by this.
- **Nothing on the CyberSlinger chassis** — they are not classes at all. See
  the correction under *Playable occupations*; they are vessel work.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-28 | [#400](https://github.com/NateGrey0130/nates-workshop/pull/400) | cached (226 pp, text layer), registered in `books.json`, offset +1 verified |
| 2026-09-09 | — | cache re-run for `welded_pages`/`corrupt_pages`; survey written; no data shipped |
| 2026-09-09 | [#881](https://github.com/NateGrey0130/nates-workshop/pull/881) | Cloud Magic, printed 37-45: **58 spells** at level 0, prefixed by category (spells 681 -> **739**). All 58 costs reconciled against the printed 37 index, 58/58 agree. 3 `same_spell_as` links of 8 candidates. Applied `--remote` before the PR. |
| 2026-09-09 | [#882](https://github.com/NateGrey0130/nates-workshop/pull/882) | Skills: **3 new rows** (skills 367 -> **370**), plus `W.P. Rope` re-cited to RUE p.306 and `W.P. Sharpshooting` given this book's definition. Applied `--remote` before the PR. |
| 2026-09-09 | [#883](https://github.com/NateGrey0130/nates-workshop/pull/883) | Classes batch 1, printed 83-92: **Bandit, Highwayman, Bounty Hunter, Gunfighter** (classes 225 -> **229**). One new catalog row, `Language: Spanish`. Filed `BOOK-INGEST-AUDIT` F49 and F50. Applied `--remote` before the PR. |
| 2026-09-09 | [#885](https://github.com/NateGrey0130/nates-workshop/pull/885) | Classes batch 2, printed 92-102: **Gunslinger, Justice Ranger, Psi-Slinger, Saddle Tramp** (classes 229 -> **233**). No new catalog rows. Filed `BOOK-INGEST-AUDIT` F51. Applied `--remote` before the PR. |
| 2026-09-09 | [#886](https://github.com/NateGrey0130/nates-workshop/pull/886) | Classes batch 3, printed 102-113: **Sheriff/Lawman, Sheriff's Deputy, Wired Gunslinger, Cowboy** (classes 233 -> **237**). No new catalog rows, no new findings. Applied `--remote` before the PR. |
| 2026-09-09 | [#887](https://github.com/NateGrey0130/nates-workshop/pull/887) | Classes batch 4, printed 113-123: **Mining 'Borg/Prospector, Preacher, Professional Gambler, Saloon Bum/Stoolie** (classes 237 -> **241**). First use of `variants` and `skills_additional` in this book. No new catalog rows, no new findings. Applied `--remote` before the PR. |
| 2026-09-09 | [#888](https://github.com/NateGrey0130/nates-workshop/pull/888) | Classes batch 5, printed 123-125: **Saloon Girl/Barmaid** (classes 241 -> **242**). **ALL SEVENTEEN OCCUPATIONS ARE IN.** Also corrects this survey: the CyberSlinger is NOT a class. Applied `--remote` before the PR. |

### What remains

`node scripts/source-coverage.mjs --remote`, 2026-09-09, **after the Cloud Magic
import**:

```
  new-west            58 / 1
```

All 58 are the cloud spells, and all 58 are traceable. The `1` is
`skills.W.P. Rope` — a row citing this book with no page range, created before
the book was cached, and still unresolved: whether this book prints a W.P. Rope
at all is the open question in the skills diff above.

The spells table now reads `739 traceable ... of 739`.

```
  BACKLOG       rows an importer created and nobody finished
    gear stubs             6   description still says STUB — created by class import
    skill stubs            5   created by an import and never given a base %, a bonus or a note
    spell stubs            2   level 0 and 0 P.P.E.
    psionic stubs          1   0 I.S.P.
    spell text missing     0   nothing for the codex to show
    psionic text missing   0   nothing for the codex to show
```

None of these is this book's. **Re-read after the Cloud Magic import and every
line is unchanged**, which is the answer to "did we finish?" for that batch:
`spell stubs` is still 2 and `spell text missing` still 0, so none of the 58
landed as a stub. Checked directly as well — all 58 carry a non-empty
description and a non-zero P.P.E. `BOOK-INGEST-AUDIT` F22.

## What the classes needed from the app

Recorded here because it is the answer to "what has to change to take these
O.C.C.s", and because batches 2-5 will meet the same list.

**Done as part of the import, and not a code change in the sense the batch rule
means (`book-survey` §8, tier 1):**

- **`CORE_SDC_BY_CLASS` in `js/compose.js`** — four entries at `3D6`. None of
  the four prints an S.D.C. formula, and the smoke test fails a class that
  states none and is missing from the map. The Bandit and Highwayman print an
  S.D.C. **bonus** (`+2D6+10`, `+2D6+6`), which is `bonuses.pools.sdc` on top of
  this rather than a replacement for it.
- **One new catalog row, `Language: Spanish`** — Technical, 50% +5%, matching
  the twenty-odd other `Language:` rows. `class-check --emit-script` writes this
  stub as **Communications, base 0, per_level 0**, which is wrong for the family
  and would have shipped a permanent bad row; both emitted copies were corrected
  by hand before applying.
- **Pinned counts**: classes 225 → 229 and skills 370 → 371 in
  `docs/operations.md`, and the README's *"of two-hundred-and-twenty-five
  published classes"* sentence, which `regression.mjs` parses as WORDS.

**A rule the suite enforces that is easy to get wrong the first time:** a
"speak one other language of choice" line must be a choice group offering
`from: ["Language: Other"]`. Offering a **category** is refused outright —
`regression.mjs` has three separate checks on this — and granting the
placeholder as a fixed skill is the F34 defect. Two of these four classes were
written the wrong way and caught by the regression run, not by `class-check`.

**Filed, not implemented** (`BOOK-INGEST-AUDIT.md`):

- **F49** — one skill taken several times for several weapons. The Gunfighter
  gets three W.P. Sharpshooting specialties and a class may grant a skill once.
  Three more classes in this book hit it: Gunslinger (94), Psi-Slinger (99),
  Wired Gunslinger (108).
- **F50** — `equipment_starting` cannot grant a skill, and the Bounty Hunter's
  Special Equipment choice does.

**Handled by existing convention, so nothing was filed:**

- The Gunfighter's Quick-Draw Initiative scales on **P.P.**, not on level →
  prose, like `W.P. Quick Draw`.
- The Gunfighter's Horror Factor of 8 at 6th level is one he **projects**;
  `bonuses.saves.horror_factor` is the save against one → prose, like the
  demigod.
- "+1 attack when using any gun" and "+3 to disarm on a called shot" are
  conditional on holding a gun → `special_abilities`, not `bonuses.combat`.
- The Bounty Hunter's *"two piloting skills and five other skills, at least two
  from espionage or military"* is `occ_related_skills.minimums`, which **F6
  shipped** in PR #428.

**A caveat on `class-check --field-sources` worth knowing for batch 2:** where
two classes' page ranges overlap, it can lock onto the neighbour's `Money:`
line. The Highwayman's report pointed at the Bandit's figure on printed 85. All
four were confirmed against their own pages instead — and every one of the four
has its `Money:` line on the page **after** the class opens, which is exactly
the page-break miss the check exists for.

### Batch 2 added to the "what the classes needed" list

- **`CORE_SDC_BY_CLASS`**: four more at `3D6`, including the **Psi-Slinger**,
  which is `occ_group: psychic` and still takes the men-of-arms value — the same
  call `psi-stalker` and `wild-psi-stalker` already carry, and for the same
  reason. All four print an S.D.C. bonus and no formula.
- **No new catalog rows.** Every skill these four grant already existed. Two
  names needed looking up rather than guessing: the book's *"Hover Vehicles"* is
  `Hover Craft (ground)`, and its *"Track Animals"* is `Track & Trap Animals`.
- **A language choice must state a `bonus`, and `regression.mjs` enforces it.**
  The Gunslinger and Psi-Slinger both print *"American and one language of
  choice at 96%"* with no bonus printed at all. The catalog holds
  `Language: Other` at 50%, so 96% is stored as **`bonus: 46`**. An absent bonus
  is what that check exists to catch, and both classes failed it first time.

**`race_restrictions` could not take either of this batch's two racial
restrictions, for two different reasons — `BOOK-INGEST-AUDIT` F51.** The
Gunslinger bars races by **kind** (dragons, creatures of magic, master psionics,
supernatural beings, cyborgs, androids, robots), and the block matches ids. The
Psi-Slinger names two plain races, *humans and Psi-Stalkers* — and **this
catalog files `psi-stalker` and `wild-psi-stalker` as `category: occ`**, so
there is no race id to name. Both are `restrictions` prose. The second was
written the "correct" way first and refused by the regression run.

**`bonuses.attributes` takes a fixed number, so the Saddle Tramp's `+1D4 to
M.A.` is not stored as one** — it is in `extraction_notes`, to be rolled at
creation. Rounding it to an invented figure would have been worse.

### Batch 3 added to the "what the classes needed" list

- **`CORE_SDC_BY_CLASS`**: four more at `3D6`. Twelve of this book's classes
  now have an entry and none has printed an S.D.C. formula yet.
- **No new catalog rows and no new findings.** Everything these four needed was
  already expressible, already in the catalog, or already filed.

**The Wired Gunslinger is the most heavily dropped class in this book, and all
of it is recorded rather than rounded.** Four of its augmentation bonuses are
**dice**, which `bonuses.attributes` and `bonuses.combat` do not take: P.S.
`+1D4`, Speed `+2D6`, initiative `+3+1D4`, and **P.P. SET to `17+1D6`** — which
is not a bonus at all but an assignment, and nothing in the schema expresses
one. All four are in a `special_abilities` entry to be rolled at creation. The
extra attack and the automatic dodge from the same paragraph *are* fixed and are
in `bonuses`.

**Its twenty-entry insanity table (printed 108-109, rolled at levels 3, 5, 7,
10 and 13) is not stored either** — there is no insanity mechanic in this app at
all. The fact of the table and its trigger levels are in `side_effects`; the
entries are not. That is a deliberate omission rather than a gap: half-storing
it would put a list on the sheet that nothing rolls.

**The Cowboy's Quick-Draw Initiative is an OPTION, not a grant.** The book
prints it under the W.P. related-skill line and says outright it must be bought
as one of the O.C.C. Related selections and is not available as a secondary
skill. Stored as an ability describing the option — it is the Sheriff/Lawman's
P.P.-scaled bonus, so it would not be applied automatically in any case. The
Sheriff and the Deputy have the same shape for Paired Weapons, at two and three
related skills respectively.

**The Wired Gunslinger's O.C.C. Skills list is two-column, like the
Highwayman's on printed 86.** Read off a 320 dpi render of printed 109 before
transcribing. Two of this book's eighteen class skill lists are set that way so
far, and the text layer interleaves both.

### Batch 4 added to the "what the classes needed" list

**This is the batch that used `variants`, and both uses are new to this book.**

- **The Mining 'Borg's two chassis are `variants` overriding `mdc_base` only** —
  130 for the Partial Reconstruction, 200 for the Full Construction. Their fixed
  P.S., P.P. and Speed are **not** stored: an O.C.C.'s attribute block is
  minimums rather than rolls, a full conversion *replaces* attributes rather
  than setting a floor, and the Full Construction chassis prints P.S. as a
  **range**, 28-30, which is neither a fixed value nor dice. Free Quebec set the
  precedent on printed 114-116 — the chassis body, its M.D.C. by location, its
  armour and its weapons are a **`vehicles` row**, and the class carries
  `mdc_base` plus a pointer. **New West's vessel import has not run**, so there
  is nothing to point at yet and the figures are in the ability text.
- **The Preacher's two types are `variants` using `skills_additional`** — the
  first use in this book of the mechanism **F31 shipped in PR #834**. The base
  class is the Peacemaker and carries no hand to hand at all, which is what the
  book's list prints; the Fire and Brimstone variant adds Hand to Hand: Basic
  and one more W.P., and carries the extra +10 S.D.C. **A variant's `bonuses`
  REPLACE rather than merge**, so the variant restates the shared figures.
- **`CORE_SDC_BY_CLASS`**: three at `1D6`, not four and not `3D6`. The Preacher
  is clergy; the Gambler and the Saloon Bum are filed under *Adventurers of the
  New West* rather than among the gunfighters. **The Mining 'Borg needs no entry
  at all** — it states an `mdc_base`, and the rule only fires on a class with
  neither.

**A fourth and fifth dice-attribute drop**: the Preacher's `+1D4+2 to M.A.` and
the Saloon Bum's `+1D4 to P.E.`, joining the Saddle Tramp and the Wired
Gunslinger. Five classes in this book now carry an attribute bonus the schema
will not take. That is enough of a pattern to be worth a finding if it recurs in
the next book.

**The Professional Gambler's skill list is the THIRD two-column one** (after the
Highwayman on printed 86 and the Wired Gunslinger on 109), confirmed on a 320
dpi render of printed 119 before transcribing.

**Two `occ_group` calls worth knowing**: the Gambler and the Saloon Bum are
`optional`. The five legal values are clergy, men-of-arms, optional, magic and
psychic, and the book's own *Adventurers of the New West* heading has no closer
fit than `optional`.

### Batch 5, and the correction it turned up

**All seventeen occupations are in.** The Saloon Girl needed nothing new:
`occ_group: optional` like the Gambler and the Saloon Bum, `1D6` in
`CORE_SDC_BY_CLASS`, and one `occ_related_skills.minimums` floor of 2 Rogue for
her *"two rogue skills plus six other skills"* line. Her `+1D4+1 to M.A.` is the
sixth dice-attribute drop in this book.

**THE CYBERSLINGER IS NOT A CLASS, and this survey claimed it was from the day
it was written.** Reading printed 189-193 to import it is what found that out:
the three chassis carry an `M.D.C. by Location` block, a `Model Type`, bionic
attributes and a cost, and **no class block at all** — checked on all three
pages for `O.C.C. Skills`, `O.C.C. Related Skills`, `Secondary Skills`,
`Money:`, `Attribute Requirements` and `Alignment`, and none of the six appears.
Printed 190 states outright that they are cyborg *bodies* and that all of them
fall into the existing 'Borg O.C.C.

**The resemblance to Free Quebec's cyborg ran the opposite way to what this file
said.** Free Quebec's four chassis really are classes — `fq-cyborg-imprimer` and
its three siblings are `imported_classes` rows with their own skill lists. New
West's three are bodies, and Free Quebec's own precedent puts a chassis body in
**`vehicles`**. So they belong to the gear and vessel pass, printed 171-223, and
`BOOK-INGEST-AUDIT` F31 has nothing to do with them.

That moves the roster from **26 to 25**: seventeen occupations and eight racial.
The eight racial classes, printed 125-158, are the next class work.
