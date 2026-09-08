# Rifts World Book 7: Underseas — survey

Slug `underseas`. Cached 2026-08-28 from `Rifts- World Book 7 Underseas.pdf`,
216 PDF pages, **scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7. Keep this
line.*

## Page offset

**Read it from `scripts/books.json`. Do not re-derive it.**

`page_offset: -1`, with `page_offset_exceptions: [{ printed_through: 130,
offset: 0 }]`. So:

- printed folio 1-130 → cache `p001`-`p130`, `read-columns.py N`
- printed folio 132-216 → cache `p<N-1>`, `read-columns.py N-1`

**This is the second split-offset book in the catalog after `pf`, and the first
with a negative offset.** The vote across the whole cache is 101 pages to 74,
close enough that a single number looks defensible and is wrong either way.

**The cause is a missing page: printed 131 is not in the PDF.** Cache `p130`
carries folio 130 and stops mid weapons stat block; `p131` carries folio 132 and
opens mid-sentence. No re-run fixes this — the page is not in the scan. Printed
131 falls through to the -1 rule and resolves to `p130`, which is printed 130;
that is deliberate, on the `pf` precedent of sending an ambiguous boundary page
to the fuller of the two candidates. **Anything straddling printed 130-132 has a
hole in the middle of it.** The one thing that does is the tail of the New Navy
attack-submarine stat block (pp.129-132), which is gear, not a class.

OCR quality: median 5,668 chars/page. Stat-block labels survived intact —
`Attribute Requirements`, `O.C.C. Skills`, `R.C.C. Related Skills`,
`Saving Throw:` and `P.P.E.:` all grep cleanly across the book. The recurring
damage is the apostrophe in `Naut'Yll`, which OCR renders as a replacement
character in most of its occurrences, and `I.S.P.` reading as `LS.P.` on a
handful of pages. Curly quotes and em-dashes are present throughout and must be
stripped before any SQL.

## The book's authority tables

| page | table | states |
|---|---|---|
| **214** | *Experience Tables* | **which classes are playable.** Twenty-six names across nine ladders. Twenty-five of them are importable; see the Gene-Splicer note below. |
| **57** | *Alphabetical List of Spellsongs* | the 21 Whale Singer spellsongs and each one's P.P.E. cost |
| **63** | *Alphabetical List of Ocean Spells* | the 41 ocean spells and each one's P.P.E. cost |
| **70** | *Alphabetical Spell List* (Dolphin Magic) | the 10 dolphin spells and each one's P.P.E. cost |
| **210** | *Alphabetical list of new skills* | the 22 entries the skills chapter defines — 19 skills and 3 notes |

**Page 214 is the most valuable page in the book**, and it is the reason the
class count is 25 rather than the forty-odd stat blocks a marker scan finds.
The creatures chapter (pp.20-46) is full of entries carrying `R.C.C. Skills of
Note:` — a monster stat block, not a class — and page 214 settles which of them
a player may take. Exactly two do: the **Dragon Ray** and **Gene-Splicer
Mutants**, both of which sit in that chapter and both of which page 214 gives a
ladder. Everything else in those pages is an NPC.

**And one of those two turns out not to be a class at all.** See the
Gene-Splicer section under *Classes* below - it has a ladder and no stat block,
which page 214 alone cannot tell you.

Page 214 also settles two names the chapter headings spell differently: the
**Ocean Wizard O.C.C.** (p.60) is *Ocean Mage* in the ladder, and the **Sea
Inquisitor O.C.C.** (p.48) is *Sea Inquisitioner*. Per `book-survey` §4c the
index wins, and both readings are recorded here.

**Costs are printed twice** for all 72 of the ocean/spellsong/dolphin spells —
once in the alphabetical list, once on the description's own `P.P.E.:` line — so
they are reconciled rather than transcribed. **Levels are printed once**, on the
description's `Level:` line; the alphabetical lists do not state level, which is
the reverse of the Book of Magic's index and means the level has no second
reading.

## Inventory

Counted by structure over all 216 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| Front matter, contents | 1-8 | — |
| Mysteries of the Seas | 9-19 | setting: ocean zones, ley line storms, Time Flux, Dead Pools |
| Creatures of the Deep | 20-40 | ~20 sea-monster stat blocks; 2 of them playable per p.214 |
| The Lord of the Deep | 41-49 | alien intelligence, its minions, the Cult of the Deep, 1 playable O.C.C. |
| The Whale Singers | 50-62 | 5 playable classes, the pneuma-biform society |
| Whale Singer Spellsongs | 57-60 | 21 spells |
| Ocean Magic | 63-70 | 41 spells |
| Dolphin Magic | 70-72 | 10 spells |
| Dolphins & Cetaceans | 73-92 | 4 playable R.C.C.s, dolphin power armour (pp.81-84) |
| Tritonia | 93-105 | 3 playable classes, weapons and vehicles (pp.100-105) |
| Nemo-2 & The New Navy | 106-132 | 3 playable classes, weapons/armour/vessels (pp.115-132) |
| Human Info & Equipment | 133-144 | 1 playable O.C.C., boats, wet suits, Aqua-Tech armour, subs |
| Naut'Yll | 145-162 | 4 playable R.C.C.s, Korallyte spells (pp.151-152), weapons/vessels (pp.153-162) |
| Horune Pirates | 162-172 | 1 playable R.C.C., Ship Dreamers, weapons, dream ships |
| Atlantis Undersea | 173-189 | Kittani and Splugorth power armour, war beasts, ships |
| Top Secret — NGR Military | 190-209 | Triax underwater bionics, armour, submarines |
| Underwater Skills | 210-213 | 19 new skills + 3 rules notes |
| Experience Tables | 214 | the authority above |

### Psionics: this book adds ZERO new psionic powers

Stated because "zero" reads like a gap. The `I.S.P.` stat-block scan hits 10
pages across the whole book, one occurrence each, and every one is a class's own
I.S.P. pool line rather than a power definition. The four cetacean psionics
sections (pp.80, 88, 90, 92) are **roll tables** that select a number of
abilities from the existing healing / sensitive / physical / super-psionic
categories; they define no new power. The one thing that looks like a new power,
*Psychic Family Imprint* (p.80), is a natural ability of psychic dolphins and
belongs in the class's `special_abilities`, not in `psionic_powers`.

**No psionic import from this book.**

## Classes

### Playable (25 importable of 26 named) — the ladder on p.214 is the list

| class | printed pages | XP ladder |
|---|---|---|
| Dragon Ray R.C.C. | 20-22 | Dragon Ray / Sperm Whale / Naut'Yll Devastator |
| Rurlel Eelman R.C.C. | 37-38 | Killer Whale / Rurlel Eelman |
| Sea Inquisitor O.C.C. | 48-49 | Sea Wolf / Sea Druid / Sea Inquisitioner |
| Pneuma-Biform Dolphin R.C.C. | 51-53 | Pneuma Biform: Dolphin / Orca / Whale |
| Pneuma-Biform Killer Whale R.C.C. | 53-55 | Pneuma Biform: Dolphin / Orca / Whale |
| Pneuma-Biform Whale R.C.C. | 55-56 | Pneuma Biform: Dolphin / Orca / Whale |
| Whale Singer O.C.C. | 56-57 | Sea Titan / Whale Singer |
| Ocean Wizard O.C.C. | 60-61 | Ocean Mage / Naut'Yll Koral Shaper |
| Sea Druid O.C.C. | 61-63 | Sea Wolf / Sea Druid / Sea Inquisitioner |
| Dolphin R.C.C. | 77-80 | Dolphin / Humpback Whale / Gene-Splicer Mutants |
| Killer Whale R.C.C. | 85-88 | Killer Whale / Rurlel Eelman |
| Sperm Whale R.C.C. | 88-90 | Dragon Ray / Sperm Whale / Naut'Yll Devastator |
| Humpback Whale R.C.C. | 90-92 | Dolphin / Humpback Whale / Gene-Splicer Mutants |
| Tritonian Sea Wolf O.C.C. | 96-97 | Sea Wolf / Sea Druid / Sea Inquisitioner |
| Tritonian Scientist O.C.C. | 97-98 | Navy Seaman / Amphib / Navy Marine / Tritonian Scientist |
| Amphib R.C.C. | 98-100 | Navy Seaman / Amphib / Navy Marine / Tritonian Scientist |
| Navy Seaman O.C.C. | 111-112 | Navy Seaman / Amphib / Navy Marine / Tritonian Scientist |
| Marine O.C.C. | 112-113 | Navy Seaman / Amphib / Navy Marine / Tritonian Scientist |
| Sea Titan R.C.C. | 113-115 | Sea Titan / Whale Singer |
| Salvage Expert O.C.C. | 133-134 | Salvage Expert / Kreel-Lok Warrior |
| Naut'Yll Soldier R.C.C. | 149-150 | Horune Pirate / Naut'Yll Soldier |
| Naut'Yll Devastator R.C.C. | 150-151 | Dragon Ray / Sperm Whale / Naut'Yll Devastator |
| Naut'Yll Koral Shaper R.C.C. | 151-152 | Ocean Mage / Naut'Yll Koral Shaper |
| Kreel-Lok Nomad R.C.C. | 152-153 | Salvage Expert / Kreel-Lok Warrior |
| Horune Pirate R.C.C. | 164-165 | Horune Pirate / Naut'Yll Soldier |

### Gene-Splicer Mutants has a ladder and NO class data — not imported

Page 214 gives *Gene-Splicer Mutants* an experience ladder, so the survey first
counted it among the playable classes. **Reading printed 38-40 settles it the
other way, and the reason is worth recording because the authority table cannot
see it.**

Those pages are a **random-monster generator**, not a class entry. They carry
six roll tables — Random Body Type/Appearance, Number of Heads, Type of Head,
Additional Appendages, Additional Features & Abilities, and a Genetic Defect
Table — and **no stat block of any kind**: no attribute dice, no M.D.C. formula
of its own, no O.C.C. or R.C.C. skill list, no related or secondary skills, no
standard equipment, no money line. Every value a class row needs comes out of a
percentile roll, and the body-type table alone sets M.D.C., size, attacks per
melee and combat bonuses thirteen different ways.

There is nothing for `imported_classes` to hold. **Not imported, and this is
not a deferral** — no schema change would make it importable, because the book
supplies no values to store. A G.M. rolls one up per creature.

**This is also the one case in this book where the p.214 authority is not
sufficient by itself.** The ladder says a gene-splicer mutant can be a player
character and the book means it; what it cannot say is that the mutant has no
printed class. The rule that survives: **the ladder decides what is playable,
and the entry decides what is importable.**

**The Naut'Yll racial stat block is printed 148, not a class of its own.** The
ladder names the Soldier, the Devastator and the Koral Shaper separately, and
p.148 is the shared racial preamble all three build on — depth tolerance,
dehydration vulnerability, the M.D.C. conversion. It folds into each of the
three rather than shipping as a fourth row.

### Named but not playable, by the book's own ladder (p.214)

Excluded because p.214 gives them no ladder, not because their pages are thin:

- **Ship Dreamers** (pp.165-166) — its stat block states that O.C.C. skills and
  O.C.C. related skills are both not applicable. It is a Horune caste, not a
  character class.
- **Servants of the Deep** (pp.47-48) — a progression a character of any O.C.C.
  acquires by years of service, with no attribute requirement and no skill list
  of its own.
- **Devil Shark, Psiren, Sea Doppleganger** (pp.45-46) — the Lord of the Deep's
  minions, each headed as such.
- The remaining ~17 creature entries in pp.20-46 — **Giant Octopus, Giant Squid,
  Lorica Wraith, Picasso Magic Fish, Great White Shark, Tiger Shark, Shadow
  Shark, Storm Rider, Zomba, Stidjron, Sea Maw** and others. Each carries
  `R.C.C. Skills of Note:` rather than `R.C.C. Related Skills:`, plus Market
  Value / Habitat / Enemies / Allies — the book's monster-entry shape.

## Catalog diff

Run against **production** (`--remote`), 2026-09-07. **Production holds nothing
from this book**: 0 classes, 0 skills, 0 spells, 0 gear, 0 vehicles cite it.

### spells: 74 book entries, 64 missing, **9 name collisions that are not gaps**

`node scripts/catalog-diff.mjs --remote --table spells --entries us-spells.json`
returns **matched 10, missing 64** against 607 rows.

One exact match and nine alias matches, and **all ten are real collisions rather
than false gaps** — the catalog row and the book row are different rows that
share a name:

| book (Ocean Magic) | catalog holds | catalog level / P.P.E. | book P.P.E. |
|---|---|---|---|
| Change Current | `Water: Change Current` | 2 / 8 | 15 |
| Communicate with Sea Creature | `Water: Communicate with Sea Creatures` | 4 / 12 | 10 |
| Float on Water | `Water: Float on Water` | 1 / 4 | 3 |
| Impervious to Ocean Depths | `Water: Impervious to Ocean Depths` | 3 / 12 | 75 |
| Ride the Waves | `Water: Ride the Waves` | 2 / 7 | 10 |
| Sense Direction Underwater | `Water: Sense Direction Underwater` | 1 / 4 | 4 |
| Speak Underwater | `Water: Speak Underwater` | 4 / 10 | 10 |
| Water Seal | `Water: Water Seal` | 2 / 8 | 10 |
| Whirlpool | `Water: Whirlpool` | 5 / 40 | 50 (level 9) |
| Sonic Blast *(Dolphin Magic)* | `Sonic Blast` | 7 / 25 | 15 |

**Checked rather than assumed.** `Water: Whirlpool` was read out of the catalog
and compared line by line against printed 70: same 120 foot radius, same 500
foot casting range, same ten feet per melee drag, same 20 foot centre. **It is
the same spell**, published as a Water Warlock invocation in the Book of Magic
at level 5 for 40 P.P.E. and as an ocean spell here at level 9 for 50. The other
eight are the same pattern — the nine names Underseas' ocean list shares with
the warlock water list, which the book itself points at on p.63.

So this is not a duplicate to skip and not a correction to apply. **One spell,
two traditions, two costs, and one row cannot hold both** — the sheet's use
button spends `ppe`, and an Ocean Wizard casting Whirlpool spends 50 where a
Water Warlock spends 40. Filed as a modelling gap in `BOOK-INGEST-AUDIT.md`;
the import ships the ocean rows separately under their own prefix and records
the warlock reading in `variant_note`.

**Naming this import establishes**, following the `Water:` / `Fire:` / `Air:` /
`Earth:` families the catalog already uses for a scoped tradition:

| family | prefix | rows | why |
|---|---|---|---|
| Ocean Magic | `Ocean:` | 41 | forced — 9 names collide with `Water:` |
| Whale Singer Spellsongs | `Spellsong:` | 21 | a closed list only a Whale Singer draws from; `Sound Blast` / `Sound Spike` / `Sonic Boom` are generic enough to collide later |
| Dolphin Magic | `Dolphin:` | 10 | forced — `Sonic Blast` collides with a bare Book of Magic row |
| Korallyte Shaping | *(none)* | 2 | `Shape Koral` and `Koral Blast` are unique and self-identifying; a prefix would only add noise |

The "Additional Spell Magic for Ocean Wizards" list on p.63 is **not imported**:
it is 20-odd spells the book names from the Rifts RPG by page number, and the
catalog already holds every one. It is a grant list for the Ocean Wizard, not
new data.

### skills: 19 book entries, **8 genuinely new, 6 re-provenance, 5 already covered**

`node scripts/catalog-diff.mjs --remote --table skills --entries us-skills.json`
returns **matched 7, missing 12** against 358 rows. Every one hand-checked:

**New rows (8):**

| skill | category | base | per level | printed |
|---|---|---|---|---|
| Advanced Fishing | Technical | 30 | 5 | 211 |
| Marine Biology | Science | 35 | 5 | 212 |
| Sea Holistic Medicine | Medical | 20 | 5 | 210 |
| Track & Hunt Sea Animals | Wilderness | 35 | 5 | 212 |
| Undersea Salvage | Technical | 30 | 5 | 211-212 |
| Advanced Deep Sea Diving | Pilot | — | — | 212 |
| W.P. Torpedo | Weapon Proficiencies | 0 | 0 | 212 |
| W.P. Trident | Weapon Proficiencies | 0 | 0 | 212 |

**`Pilot: Advanced Deep Sea Diving` is printed with no base percentage and no
per-level step.** Its entry describes what the skill covers and stops. This is
the book, not the OCR — the paragraph is clean and ends on a sentence about
combat models. It ships at base 0 with the omission recorded in its `note`.

*Marine Biology* and *Track & Hunt Sea Animals* are both printed as two numbers
(35%/25%), the second being a narrower application. `base` takes the general
figure and `note` carries the split, which is the convention the catalog already
uses for `Undersea & Sea Survival`.

**False gaps — the catalog holds these under another name (4):**

| book prints | catalog holds | verdict |
|---|---|---|
| W.P. Harpoon Gun | `W.P. Harpoon & Spear Gun` (RUE) | rename only; no new row |
| Underwater Demolitions | `Demolitions: Underwater` (RUE, Military 56 +4) | existing row — **but see the disagreement below** |
| Underwater Navigation | `Navigation: Underwater` (Pilot Related 30 +4) | existing row, **filed in a different category** than this book states |
| Pilot: Submersibles | `Boat: Submersibles` (Pilot 40 +4) **and** `Military: Submersibles` (RUE, Pilot 40 +4) | existing — **the catalog holds two rows for one skill** |

**Two disagreements the diff cannot settle by itself:**

1. **`Demolitions: Underwater` per-level.** Printed 210 gives 56% **+3%** per
   level; the catalog row, sourced to RUE pp.302-303, holds **+4%**. RUE is the
   later book and wins under the standard rule, so the catalog is left alone and
   the Underseas reading goes in `variant_note`.
2. **`Navigation: Underwater` category.** Printed 212 files it under
   *Wilderness*; the catalog has it under *Pilot Related*. Printed 212 also
   files a `Pilot Related: Navigation Note` that says surface and submersible
   navigation are aspects of the standard navigation skill — which is an
   argument for the catalog's placement, not against it. **Left alone.** Moving
   a category silently changes which classes can take it.

**Re-provenance (6).** Six rows currently sourced to the placeholder
`Rifts Skill List` are defined in this book, and the book is cached now:

| row | current source | real source | values agree? |
|---|---|---|---|
| Ocean Geographic Surveying | Rifts Skill List | Underseas p.211 | yes — 15 +5 |
| Submersible Vehicle Mechanics | Rifts Skill List | Underseas p.210 | yes — 25 +5 |
| Undersea Farming | Rifts Skill List | Underseas p.211 | yes — 35 +5 |
| Undersea & Sea Survival | Rifts Skill List | Underseas p.212 | yes — 25 +5 |
| Boat: Submersibles | Rifts Skill List | Underseas p.212 | yes — 40 +4 |
| Navigation: Underwater | Rifts Skill List | Underseas p.212 | yes — 30 +4 |

All six agree on every value, which is six independent confirmations that the
skills chapter was read correctly. `Rifts Skill List` drops from 40 rows to 34.

**Not new (5):** `Water Scooters`, `Water Skiing & Surfing` and
`Military: Warships & Patrol Boats` are RUE rows already; the three remaining
entries on p.210's list — *Pilot Related: Navigation Note*, *Power Armor Skill
Note* and *Swimming & Fatigue Note* — are **rules notes, not skills**, and
define nothing to import.

## Extraction plan

Phase 4 costs money; everything above was free.

1. **Skills** — 8 new rows, 6 re-provenance updates, 2 `variant_note`
   corrections. Read straight off pp.210-213, one pass.
2. **Spells** — 74 rows from pp.57-60, 63-72 and 151-152, batched by tradition
   (41 / 21 / 10 / 2). Cost reconciled between each list and its description;
   level taken from the description's own line.
3. **Classes** — 25, in batches of three to six grouped by the book's own
   chapters, so a batch shares its racial preamble and its page range.
4. **Gear, armour and vehicles** — last, because the classes' `Standard
   Equipment` lines name items that need catalog rows and the stub marker is
   easier to clear once than twice.

What is deliberately left, with the reason:

- **The creature entries in pp.20-46 that p.214 gives no ladder** — the book's
  own authority says they are not player characters.
- **The "Additional Spell Magic for Ocean Wizards" list (p.63)** — every row is
  already in the catalog; it is a grant list, not new data.
- **The three rules notes on p.210** — they change how existing skills behave
  and define nothing.
- **Setting material** — Tritonia, the New Navy, the Naut'Yll and Horune
  nations, the Lord of the Deep, Dead Pools, Time Flux, the Cult of the Deep,
  and every named NPC including Captain Nemo-2 (pp.110-111). Lore, not rows.
- **Gene-Splicer Mutants (pp.38-40) in full** — it has a p.214 ladder and no
  stat block at all. See the section under *Classes*; the six roll tables are a
  G.M. generator and there is no class row underneath them.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-28 | — | cache built (216 pp), offset -1 with a `printed_through: 130` exception verified by folio |
| 2026-09-07 | — | survey written; 26 playable classes established from the p.214 ladder |
| 2026-09-07 | [#798](https://github.com/NateGrey0130/nates-workshop/pull/798) | 8 new skills (358 -> **366**); 6 `Rifts Skill List` rows re-cited to this book (40 -> **34**); 2 losing readings recorded on the RUE rows that won. Applied `--remote` before the PR. |
| 2026-09-07 | [#799](https://github.com/NateGrey0130/nates-workshop/pull/799) | 74 spells across four traditions (607 -> **681**): 21 `Spellsong:`, 41 `Ocean:`, 10 `Dolphin:`, 2 Korallyte unprefixed. Ten collide with an existing row and are the SAME spell at another tradition's price - `variant_note` on each, gap filed as `BOOK-INGEST-AUDIT` F26. Applied `--remote` before the PR. |
| 2026-09-07 | [#800](https://github.com/NateGrey0130/nates-workshop/pull/800) | class batch 1 of 6: **Dragon Ray**, **Rurlel Eelman**, **Sea Inquisitor** (190 -> **193** live classes). Gene-Splicer Mutants dropped from the roster - a p.214 ladder with no stat block. `sea-inquisitor` needed a `CORE_SDC_BY_CLASS` entry, proved load-bearing by removing it and watching the suite fail. Applied `--remote` before the PR. |
| 2026-09-07 | [#801](https://github.com/NateGrey0130/nates-workshop/pull/801) | class batch 2 of 6: the three **Pneuma-Biforms** - Dolphin, Killer Whale, Whale (193 -> **196** live classes). Plus one skill row the skills chapter does not define: `Language: Dolphin/Whale`, from printed 75-76 (366 -> **367**). Applied `--remote` before the PR. |
| 2026-09-07 | [#802](https://github.com/NateGrey0130/nates-workshop/pull/802) | class batch 3 of 6: the three casters - **Whale Singer**, **Ocean Wizard**, **Sea Druid** (196 -> **199** live classes). Six gear stubs created by the import, for the gear pass to fill (1136 -> **1142**). Applied `--remote` before the PR. |
| 2026-09-07 | [#803](https://github.com/NateGrey0130/nates-workshop/pull/803) | class batch 4 of 6: the four cetacean R.C.C.s - **Dolphin**, **Killer Whale**, **Sperm Whale**, **Humpback Whale** (199 -> **203** live classes). All four are S.D.C. creatures, the first from this book. Plus a third spelling of the dolphin EMP spell, found in a class list ten pages from the spell chapter. Applied `--remote` before the PR. |
| 2026-09-07 | [#804](https://github.com/NateGrey0130/nates-workshop/pull/804) | class batch 5 of 6: the three Tritonians - **Sea Wolf**, **Tritonian Scientist**, **Amphib** (203 -> **206** live classes). The Amphib is F23(a)'s second and harder case: it borrows a class's skill list AND subtracts three. Applied `--remote` before the PR. |
| 2026-09-07 | [#805](https://github.com/NateGrey0130/nates-workshop/pull/805) | class batch 6 of SEVEN: **Navy Seaman**, **Marine**, **Sea Titan**, **Salvage Expert** (206 -> **210** live classes). The Navy Seaman is this book's only MOS class, with nine specialty options. Filed `BOOK-INGEST-AUDIT` **F27**: `class-check` does not validate skill names inside an MOS option, proved with the same bogus name in two positions. Applied `--remote` before the PR. |

**CORRECTION, same day.** PR #805's own title, body and commit message call it *"batch 6 of 6"* and state that **all 25 importable classes from this book are in**. **That is false and it was false when written: 20 of 25 are in, and FIVE remain** - the Naut'Yll Soldier, the Naut'Yll Devastator, the Naut'Yll Koral Shaper, the Kreel-Lok Nomad and the Horune Pirate, printed 149-165. The error was arithmetic rather than a misreading of the book: six batches of 3, 3, 3, 4, 3 and 4 come to 20, and the roster on printed 214 has 25. It was caught by counting `imported_classes` against the survey's own roster after the merge, which is the check that should have run before it.

The merged PR body cannot be edited into truth retroactively and is left as the record it is; **this ledger is the authority the next session boots from**, and it says 20 of 25. The remaining five are one batch, and the survey's *Extraction plan* still describes them.

| 2026-09-08 | [#807](https://github.com/NateGrey0130/nates-workshop/pull/807) | class batch 7 of 7: **Naut'Yll Soldier**, **Naut'Yll Devastator**, **Naut'Yll Koral Shaper**, **Kreel-Lok Nomad**, **Horune Pirate** (210 -> **215** live classes). **THE CLASS ROSTER IS COMPLETE: 25 of 25**, verified by counting `imported_classes` against the p.214 ladder rather than by adding up batches - which is the check whose absence produced the #805 miscount. Applied `--remote` before the PR. |
