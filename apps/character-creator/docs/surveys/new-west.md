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
| **O.C.C.s and P.C.C.** | **83-125** | **18 playable occupations** |
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

### Playable occupations (18) — printed 83-125

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
| CyberSlinger cyborg | 189-193 | 'Borg tables, core rules |

**`Psi-Slinger` is a P.C.C., and a scan keyed on `O.C.C.`/`R.C.C.` misses it
entirely.** It was found only because a marker page at printed 98-100 had a stat
block and no heading the scan would match. Any future roster scan of a Rifts
book must include `P.C.C.`

**`Special Sheriff/Lawman` (printed 103) and `Special Wired Gunslinger`
(printed 107) are NOT separate classes.** Each sits inside its base class's
pages and neither appears on the experience tables, where every other playable
class does. Treat both as variants of the class they sit under.

**The CyberSlinger is three chassis of one full-conversion cyborg** — CSLNGR
Mark I (printed 190), Mark II (191), Mark III (192-193), each with its own
`M.D.C. by Location` block and cost. This is the same shape as Free Quebec's
cyborg and its four chassis, which was **`BOOK-INGEST-AUDIT` F31 — and F31 was
taken on 2026-09-08 in PR #834.** `skills_additional` and
`related_skills_count` are in `VARIANT_OVERRIDES` with handlers in
`js/parser.js`, so a chassis can add skills and move the related-skill count.
Nothing needs filing.

F31 deliberately did **not** restructure Free Quebec's five published cyborg
classes, because a character references its class by `class_id`. That reservation
does not reach these three: they are new, nothing points at them, and they can
be variants from the first PR.

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

None of this book's 26 playable classes is in the catalog. `gambler`, `ranger`
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

**Four are real gaps: History of the West, Prospecting, W.P. Bola, W.P.
Snapshooting Specialty.**

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

`skills.W.P. Rope` is the single row already citing this book, and it has no
page range — it is the whole of `new-west 0 / 1` in the coverage ledger. The
book's W.P. list on printed 71 names Bola, Snapshooting Specialty and Whip.
**Whether this book prints a W.P. Rope at all is unresolved** and needs the
render of printed 71-72 before the row is given a page range.

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
2. **New skills** — 4 rows only. Cheap; can ride with another batch.
3. **The 18 occupations, printed 83-125** — batched by section, ~4 per PR.
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
- **Nothing on the CyberSlinger chassis** — F31 shipped the mechanism they
  need. Listed here only so a later session does not re-derive the question.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-28 | [#400](https://github.com/NateGrey0130/nates-workshop/pull/400) | cached (226 pp, text layer), registered in `books.json`, offset +1 verified |
| 2026-09-09 | — | cache re-run for `welded_pages`/`corrupt_pages`; survey written; no data shipped |
| 2026-09-09 | [#881](https://github.com/NateGrey0130/nates-workshop/pull/881) | Cloud Magic, printed 37-45: **58 spells** at level 0, prefixed by category (spells 681 -> **739**). All 58 costs reconciled against the printed 37 index, 58/58 agree. 3 `same_spell_as` links of 8 candidates. Applied `--remote` before the PR. |

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
