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

### gear and vehicles: diffed as each batch is extracted

**78 `Cost:`/`Market Price:` lines and 17 `M.D.C. by Location` blocks, printed
171-223**, counted off the cache on 2026-09-10 - close to the 79 and ~15 this
survey projected. The diff wants the entry names, which is extraction work, so
it happens per batch rather than up front, and each batch's result is recorded
in the ledger below.

**THE CACHE CANNOT BE TRUSTED FOR A GEAR NUMBER IN THIS BOOK.** The weapon
entries are set in boxed panels and the armour pages carry blocks of
illustration captions, and both break the text layer's column analysis without
looking wrong. Two proven cases:

- printed 173 - the Bandit IP-10's `Cost: 12,000 credits` is separated from its
  own stat block by an unrelated *Black Market Prices for E-Clips* sidebar, so
  cache order does not associate a cost with its weapon.
- printed 180 - four illustration captions (`NG Range Rider Riding Armor`,
  `NG Maverick Riding Armor`, `NG Buffalo Riding Armor`, `Ml Vaqueros Armor`)
  sit between the Range Rider's `Main Body - 30` and its `Market Price`.

This is the same fault already recorded three times here for class skill lists.
**Render every gear page before transcribing it.** The renders have also settled
two strings the text layer gets wrong: `Ml Vaqueros` is **MI** for Manistique
Imperium, and the Bandit 6000's price prints as `80,000-100.000`, a period where
a comma belongs.

**Batch A, printed 173-181 - 17 names checked, 15 imported, 2 already held.**
`Dead Boy Body Armor` and `Dog Pack DPM Light Riot Armor` are Black Market
knock-offs of rows RUE already has (`ca-1-heavy-dead-boy-armor`,
`ca-2-light-dead-boy-armor`, `dog-pack-dpm-riot-armor`) and neither was
duplicated - see the finding below.

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
   **ALL EIGHT DONE. PR #890: Cactus People 127, Fennodi 128, Keeper of the Desert
   130, Lyn-Srial 133. PR #892: Sky-Knight 134, Cloudweaver 135, Mountain Giant 136,
   Psi-Pony 156.**
5. **Gear and vessels, printed 171-223** - last, and diffed per batch.
   **IN PROGRESS.** Batch A (Bandito Arms weapons and the western body armour
   line, printed 173-181) is in. Remaining: bionics and cybernetics 187-189,
   Wilk's Laser Technologies 203-209, conventional revolvers 210-213,
   Techno-Wizard weapons 213-221, and the vessels. **Printed 217 is
   glyph-corrupt and carries three Techno-Wizard prices - read it off a
   render.** Every other gear page needs a render too; see the diff section
   above.

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
| 2026-09-10 | [#890](https://github.com/NateGrey0130/nates-workshop/pull/890) | Racial classes 1 of 2, printed 125-134: **Cactus People, Fennodi, Keeper of the Desert, Lyn-Srial** (classes 242 -> **246**). First class to consume the Cloud Magic spells. No new catalog rows, no new findings. Applied `--remote` before the PR. |
| 2026-09-10 | [#892](https://github.com/NateGrey0130/nates-workshop/pull/892) | Racial classes 2 of 2, printed 134-158: **Sky-Knight, Cloudweaver, Mountain Giant, Psi-Pony** (classes 246 -> **250**). **ALL 25 PLAYABLE CLASSES ARE IN.** First use of `copy_of` in this book. Applied `--remote` before the PR. |
| 2026-09-10 | [#895](https://github.com/NateGrey0130/nates-workshop/pull/895) | Gear batch A, printed 173-181: **8 Bandito Arms weapons and 7 suits of western body armour** (gear 1249 -> **1264**). Every number read off a RENDER; the cache cannot associate a cost with its entry on these pages. Two of the section's suits were NOT imported because RUE already holds them. Applied `--remote` before the PR. |
| 2026-09-10 | [#896](https://github.com/NateGrey0130/nates-workshop/pull/896) | Gear batch B, printed 187-189: **25 cybernetics rows** - 15 Mining Borg attachments and 10 other bionic items (gear 1264 -> **1289**). All 25 new; the generic names were checked a second way against the 29 existing cybernetics rows. Chemical Spray carries NO price and none was invented. Applied `--remote` before the PR. |
| 2026-09-10 | [#897](https://github.com/NateGrey0130/nates-workshop/pull/897) | Gear batch C, printed 203-213: **35 rows** - 9 Wilk's laser weapons, 7 Wilk's-Remi, 5 other Wilk's products, 8 conventional firearms, 6 CFT (gear 1289 -> **1324**). FIVE reprints of RUE rows skipped, and their five matching prices are the batch's own calibration. The 447 is a FALSE GAP at name distance 12. Grenade `sdc` refused by regression; filed rather than loosened. Applied `--remote` before the PR. |
| 2026-09-10 | [#898](https://github.com/NateGrey0130/nates-workshop/pull/898) | Gear batch D, printed 213-218: **12 Techno-Wizard weapons** (gear 1324 -> **1336**). **THE BOOK'S GEAR IS DONE.** Printed 217 is glyph-corrupt and carries three of the twelve prices; all read off a render. Applied `--remote` before the PR. |
| 2026-09-10 | [#899](https://github.com/NateGrey0130/nates-workshop/pull/899) | Vessels 1 of 2, printed 183-195: **6 vehicles, 57 M.D.C. locations, 16 weapon entries** (vehicles 143 -> **149**) - the two Bandito SAMAS, the three CyberSlinger bodies and the Tarantula ATV. The CyberSlingers land here rather than as classes. The Tarantula has TWO main bodies, so `mdc_main_body` is NULL. Applied `--remote` before the PR. |
| 2026-09-10 | [#900](https://github.com/NateGrey0130/nates-workshop/pull/900) | Vessels 2 of 2, printed 196-223: **9 vehicles, 46 M.D.C. locations, 7 weapon entries** (vehicles 149 -> **158**) - FOUR robot horses (not three), the K-9, the Bronco Scooter, the War Wagon, the Glittermount and the TW Ironhorse. Found the book-wide glyph substitution `corrupt_pages` cannot see. Applied `--remote` before the PR. |

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

### The racial classes, first four

**No `CORE_SDC_BY_CLASS` entries at all.** Every one of the four states its own
`sdc_base` or `mdc_base`, and the rule only fires on a class stating neither.

**The Lyn-Srial is the first class to consume the Cloud Magic spells**, and it
is where the category prefix earns its keep. Four spells are granted by name —
`Clouds of Travel: Cloud of Ascension`, `Clouds of Travel: Cloud Surfing`,
`Clouds of Survival: Aerial Navigation`, `Clouds of Survival: Globe of
Daylight` — and the additional picks come from Clouds of Defense, Travel and
Survival, which is a `spells_from` list of exactly those three categories'
24 rows. Under a `Cloud Magic:` prefix that list could not have been built
without reopening printed 37.

**What is still prose there**: the pick COUNT is *one per 3 points of I.Q.*, an
attribute-derived number that `spells_starting` cannot hold. The pool is exact;
only the count is in `extraction_notes`.

**The Fennodi's male and female psionic profiles are two `special_abilities`
entries behind a `choose: 1`** — because `variants` may not override `psionics`
and an ability may. `ABILITY_GRANTS` in `js/parser.js:1644` is
`['bonuses', 'psionics', 'magic']`. The two differ in I.S.P. formula (M.E. ×2
against ×3), in the fifth granted power, and in the category the per-level pick
draws from (Healing against Physical).

**The Keeper of the Desert's random mutation table is a `choose: 3` over
seventeen ability entries** — the book rolls at levels 1, 6 and 12 and lets a
G.M. allow selection instead, which is what a choice group is. The percentile
band stays at the head of each entry so a d100 still works at the table.
**The substantial drop is that eight of the seventeen grant SPELLS**, six of
them by naming a list rather than the spells — *all the fire magic spells
usually available to the Ley Line Walker* and the like. An ability CAN carry a
`magic` block, but resolving that list means deriving something the book does
not print, and doing six of the eight would look complete and be half.

**Three traps this batch hit, all caught by the tooling:**

- **A `special_abilities` entry wrapped across two lines** killed all eighteen
  of the Keeper's definitions at once — the parser read the opener as text and
  reported eighteen "offered but nothing defines it" warnings. **An inline
  `{...}` must close on the same line, however long.**
- **`Skin and Prepare Animal Hides` is `Skin & Prepare Animal Hides`** in the
  catalog, at 30% not 40%. The stub would have created a duplicate row.
- **`Read Sensory Equipment` is `Sensory Equipment`.** An unmatched name in an
  `only` list fails CLOSED, so that category would have granted nothing.

### The racial classes, last four — and the book's classes are done

**All 25 playable classes from this book are in**: seventeen occupations and
eight racial, across PRs #883, #885, #886, #887, #888, #890 and #892.
`source-coverage --remote` reads **`new-west 88 / 0`**.

**`copy_of` gets its first use in this book.** Printed 134 and 135 both define
their class as the Average Lyn-Srial for *alignment, attributes and all basic
stats*, then replace magic, skills, bonuses and equipment. Both are stored as
full copies with `copy_of: { class: "lyn-srial", except: [...] }`, because
nothing composes one class from another.

**`regression.mjs` checks the copy is real, and caught two mistakes:** the
Cloudweaver had no `natural_abilities` at all, and the Sky-Knight's had drifted
by four words from the parent's. **A copied block must be byte-identical** —
paste it, do not retype it. It also rejected `extraction_notes` in the `except`
list, which is never compared anyway.

**The Sky-Knight and the Cloudweaver are what the Cloud Magic import was for.**
The Sky-Knight gets all thirteen Clouds of War and all six Clouds of Peace, then
one per level from **any category except Clouds of Creation** — 50 of the 58
rows. The Cloudweaver gets all of Defense, Travel and Creation (22 spells), then
**two** per level from any category **except Clouds of War** — 45 rows. Both
exclusions are only expressible because the spells carry their category in the
name.

**Two more `choose: 1` psionic splits by sex** — the Psi-Pony joins the Fennodi.
Same reason: `variants` may not override `psionics` and an ability may.

**Left deliberately unmodelled, for a later pass:**

- The Sky-Knight's `+1D6 to P.S.` — `bonuses.attributes` drops a dice string
  (**F52**). The `+2D6` M.D.C. and `+1D4x10` P.P.E. from the same paragraph *are*
  in `bonuses.pools`, which does take dice (`js/dice.js:221`,
  `js/parser.js:1454`).
- The Cloudweaver's **impervious to Horror Factor and possession** — an immunity,
  not a number; `bonuses.saves` holds numbers and there is no field for an
  immunity, so it is in `restrictions`.
- The Mountain Giant's **supernatural P.S. and P.E.** — no field marks an
  attribute supernatural, so it is a natural ability.
- The book's skill called **Write** has no catalog row; `Calligraphy` is the
  nearest and is what the Cloudweaver stores, with the book's word in the note.

## What the gear batches turned up

### Batch A: three CS armours this book reprints at Black Market prices

The Black Market sells knock-offs of the old Coalition armour, and printed 178
says outright they are *"identical to the old CS body armor in every way, except
the standard colors"*. Three rows already exist from RUE, so **nothing was
duplicated** - but the New West price is not the RUE price, and the gear table
holds one `cost` per row:

| row | RUE | New West |
|---|---|---|
| `ca-2-light-dead-boy-armor` | 35,000 | 40,000 |
| `ca-1-heavy-dead-boy-armor` | 35,000 | 50,000 |
| `dog-pack-dpm-riot-armor` | no cost at all | light 12,000, heavy 18,000 |

Recording New West's figures would mean either overwriting RUE's or creating a
second row with identical stats and a different price. **Neither was done** - it
is a catalog-shape question rather than something an import should settle.

**The stats disagree too, and RUE is the fuller reading in both directions.**
New West prints ONE `M.D.C. by Location` block covering both Dead Boy suits, so
its helmet/arms/legs figures are the HEAVY suit's; RUE states the light suit's
separately at 35/15/24. Its heavy figures match RUE exactly (18 lbs, main body
80, helmet 50, arms 35, legs 50), which is a five-way independent confirmation
that the render was read correctly. The Dog Pack is the one place New West has
MORE than RUE: it splits the suit into light and heavy (main body 35 or 50, arms
10+3, legs 15+5, 10 lbs) where the RUE row is a single 8 lb suit at main body
30, arms 10, legs 20.

### Batch C: a name-diff gap that was not a gap

New West heads its 447 entry **"Wilk's 447 Traditional Laser Rifle"**. The
catalog holds **"Wilk's 447 Laser Rifle"**, from RUE p.269. That is a name
distance of **12** - `catalog-diff` reported it MISSING and offered the existing
row only as a nearest neighbour, which is exactly what it does for genuinely new
entries.

It is the same rifle: 5 lbs, 18,000 credits, 3D6 M.D., 2000 feet, and a payload
string that is word for word identical in both. **A name-diff gap is not
evidence of a missing row; the stats are.** This is the gear-table sibling of
the `W.P. Snapshooting`/`Sharpshooting` trap in the skills diff above - the same
book, the same failure, a different catalog.

**Four other reprints matched by name and confirm the reading.** The 320, the
Laser Scalpel, the Laser Wand and the Portable Laser Torch all carry the price
this book prints - 11,000, 2500, 2000 and 7000 - against rows entered from RUE
by a different session. Five independent prices agreeing is the only external
check any figure in these gear batches gets.

### Batch C: a grenade legitimately has BOTH durability and damage

`regression.mjs:1577` refuses any gear row carrying an `sdc` alongside a dice
expression in `damage`, and its comment says why: *"does 1D6 S.D.C." on a knife
is DAMAGE, and a regex over descriptions would file it as durability - a knife
that can absorb six points of punishment because it deals six.*

Printed 209 gives the Beehive and Blinder grenades an **S.D.C. of 20 and an A.R.
of 10** - the durability of the grenade itself - alongside a blast of 3D6 M.D.
**A grenade is the honest counter-example the check cannot distinguish.**

Not resolved here, and deliberately so: loosening a guard in the same change
that first trips it is how a guard stops guarding. The 20 is in each row's
`description`, the A.R. is stored normally in `ar` (the check does not read that
column), and `sdc` is `NULL`. The sibling armour check one line above is
already scoped - *"a row that CONFLATES two products can legitimately carry
both"* - so a scope is the shape a fix would probably take.

### Batch D: printed 217 is the CURABLE kind of corrupt page

`corrupt_pages` in the cache manifest lists three pages - cache p031, p143 and
**p218, which is printed 217** - and 217 is the one that mattered, because it
carries three of this batch's twelve prices: the Old Lightning Rifle's 80,000,
the Hellfire Shotgun's 65,000 and the Snare Gun's 45,000.

**The render is perfectly legible.** That makes it an ENCODING fault, where the
ink is right and the text layer is wrong, rather than the other kind, where the
page itself is damaged - Free Quebec printed 118 shows `a\` on the paper, and
no render fixes that. `book-survey` 0a draws the distinction; this is a clean
example of the half a render cures.

The other two corrupt pages carry no gear at all: cache p031 is printed 30 and
p143 is printed 142, both in the setting and creature chapters.

### The gear chapter is finished

**78 `Cost:`/`Market Price:` lines counted off the cache, all accounted for**
across #895, #896, #897 and #898:

| batch | printed | rows in | skipped, and why |
|---|---|---|---|
| A | 173-181 | 15 | 2 CS armours RUE already holds |
| B | 187-189 | 25 | none |
| C | 203-213 | 35 | 5 Wilk's reprints of RUE rows |
| D | 213-218 | 12 | none |

**87 rows in, 7 entries skipped as reprints.** Gear 1249 -> **1336**.

**A CORRECTION TO THIS TABLE, made 2026-09-10 while starting the vessels.**
It first read *"78 lines counted off the cache, ALL ACCOUNTED FOR"*, and that
was wrong. The 78 is a count across printed 171-223, which INCLUDES the vessel
pages, and those prices were still outstanding when the sentence was written -
the Sidewinder's 3.6 million on printed 184, the Wild Weasel's 4.8 million on
186, the three CyberSlinger costs on 190-193, the Tarantula's 18 million on 195,
and the robot horses, K-9, Bronco and War Wagon beyond that. What the four gear
batches finished is the **gear** chapter; the vessel prices live in
`vehicles.cost`, in a different table, and land with the vessels.

The sentence was true of every page the four batches touched and false about
the range it named. **A count taken over a page range answers for that whole
range, and claiming it is discharged means checking every page in it** - not
the pages the work happened to cover.

### The vessels: a fourth robot horse, and a corruption the detector cannot see

**THERE ARE FOUR ROBOT HORSES.** This survey said three, and so did the heading
scan that checked it - both looked for `Model Type:` lines, and the **RH-1001A
Appaloosa's heading is "Appaloosa or Pony", with no model number**, on printed
196, a page otherwise full of accessory prices. It is the LIGHT horse, the
cheapest of the four at 2.5 million. Same shape as the `P.C.C.` trap in the
class roster: **count the entries, not the headings.**

**A BOOK-WIDE GLYPH SUBSTITUTION, AND `corrupt_pages` REPORTS THREE PAGES.**
This book renders the digit **1 as `!` or `l`** and **0 as `O` or `Q`** inside
almost every `NDNx10` / `NDNx100` construction - `!D4xlO` for 1D4x10, `3D4xlOO`
for 3D4x100, `10Q` for 100.

- **It is in the INK.** Clipped printed 223 at 600 dpi to check, and the page
  itself prints `!D4xlO`. **A render does not cure it**, unlike printed 217,
  which is the other kind. This book has one clean example of each, which makes
  it the reference case for `book-survey` 0a's distinction.
- **Roughly SIXTY pages are affected** and the manifest lists three (cache
  p031, p143, p218). The detector looks for glyphs that FAIL TO MAP; these map
  to perfectly valid characters. **A substitution cipher is invisible to a
  bad-glyph detector.**
- **What gives it away is the dice grammar**, not the characters: `!D4xlO`
  cannot be read any other way than 1D4x10. Every affected figure across all six
  batches was read that way, and the sweep afterwards confirms it - no row in
  `imported_classes`, `gear` or `vehicles` contains `xlO`, `xlOO` or `!D`, and
  23 of the 27 class rows citing this book carry a correct `x100`.

**It reaches STARTING MONEY**, which is the part that would have mattered most:
almost every O.C.C. on printed 85-124 prints `Money: Starts with 3D4xlOO
credits`. Those batches read them correctly; the sweep is what proves it rather
than my memory of it.

### A hand-counted assertion was wrong three times

`INSERT OR IGNORE` is silent on a collision, so the vessel scripts count what
they wrote. The counts caught **my own arithmetic, never a lost row** - 44
against an actual 57, 15 against 16, 41 against 46 - and once caught a wrong
FILTER: a `source_book LIKE '%New West p.19%'` returned 12 vessels because the
other batch cites p.189-195. **A page-range pattern is not a batch boundary when
two batches meet inside the same hundred.** Count by slug.

The lesson is not to count more carefully. It is that **the assertion is worth
writing even when you are confident**, because being wrong about your own file
is the common case and it costs one line to find out.
