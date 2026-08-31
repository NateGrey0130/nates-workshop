# Rifts Dimension Book 2: Phase World — survey

Slug `phase-world`. Cached 2026-08-28 from
`Rifts- Dimension Book 2 Phase World.pdf`, 209 PDF pages,
**scan (no text layer)**, OCR at 300 dpi, psm 3.

*Facts about this book, not prose from it — see `book-survey` §7.*

## Page offset is ZERO

`page_offset: 0` — printed folio N is cache `pNNN.txt`. Recorded in
`scripts/books.json`, measured by folio in the kickoff session: 166 pages agree
at +0 against 3, one unbroken region from `p010` to `p208`, no split and no
exceptions. `printed_pages` is 208; PDF page 209 is a Palladium house ad the
book does not number.

The FOURTH zero-offset book here, after `potm`, `ww` and `triax`. `book-survey`
0d's warning applies: a zero offset leaves no discrepancy to explain when a page
reads wrong.

**Two corrections to the registry note, both measured this session.**

- The note says `read-columns.py N+1`. It is **N**. `read-columns.py` calls
  `doc[n - 1]`, and printed 150 renders from `doc[149]`, so printed N is
  `read-columns.py N`. The distinction is moot in practice — this book has no
  text layer, so `read-columns.py` returns an empty page for every number you
  give it — but the number was wrong and would have been believed on a book
  where it mattered.
- The note says printed **203-208** are blank character record sheets. The real
  range is **184-208**, twenty-five pages: three generic sheets (184-186) and
  twenty-two per-class ones (187-208). The note's *rule* is right and is the
  reason this matters — the sheets name classes without defining them, so the
  inventory below comes from stat blocks. Twenty-two sheets against forty-two
  classes is a much bigger trap than six would have been.

OCR quality is ordinary for a scan: median 4,119 chars/page, stat-block labels
(`Attribute Requirement`, `O.C.C. Skills`, `Money:`, `Mega-Damage:`) survived
intact. Curly quotes and en/em-dashes are present throughout and must be
stripped before any SQL. Authority tables were read as 200 dpi renders, per
`book-survey` 0c.

## The book's three authority tables

| page | table | states |
|---|---|---|
| **183** | *Experience Tables* | which classes are PLAYABLE, and their XP ladders |
| **6** | *Quick Find*, section `O.C.C.s & R.C.C.s` | the roster and the canonical spelling of every class name |
| **4-6** | *Contents* | section boundaries, and which entries the book labels NPC |

Page 183 is the most valuable. It carries **14 ladders covering 31 classes**,
and membership in it is the book's own statement that a class is meant to be
played — it is the only place that distinguishes the Dominator (a GM race, no
ladder) from the Vacuum Wasp (optional, but laddered).

Page 6's Quick Find is the naming authority and it disagrees with the Contents
and with the record sheets in five places. Where they differ, Quick Find wins
because it is the only list that is alphabetised and therefore proof-read:

| Quick Find (p.6) | Contents (p.4-5) | record sheet (184-208) |
|---|---|---|
| `Draconid R.C.C.` | `Draconoid R.C.C.` | `Draconid R.C.C.` |
| `Noro Psychic R.C.C.` | `Noro Psychic O.C.C.` | `Noro Psychic O.C.C.` |
| `Repo-Bots R.C.C.` | `The Naruni Repo-Bot R.C.C.` | `Naruni Repo-Bot O.C.C.` |
| `Imperial Legionaire O.C.C.` | `Imperial Legionnaire O.C.C.` | `Imperial Legionnaire O.C.C.` |
| `Vaccum Wasp R.C.C.` | `Vacuum Wasps R.C.C.` | — |

The last two are Quick Find's own typos (one `n`, one `u`) and lose to the other
two lists agreeing. `Noro Psychic` and `Naruni Repo-Bot` are a real O.C.C./R.C.C.
disagreement inside one book and are settled per class from the stat block's own
heading, not from any index.

Skill percentages are printed **once**, in the skill's own description. There is
no second table to reconcile them against, so every number below was transcribed
off a 200 dpi render rather than trusted to OCR.

## Inventory

Counted by structure over all 209 cached pages, not by reading prose.

| section | printed pages | what is there |
|---|---|---|
| front matter, Contents, Quick Find | 1-6 | the two indexes |
| Introduction, Phase World setting | 7-23 | lore, no mechanics |
| Prometheans and Phase Powers | 24-35 | 4 classes, 15 phase powers |
| Other races & O.C.C.s of note | 35-43 | 7 classes |
| Naruni Enterprises | 44-49 | 2 classes |
| The Three Galaxies, Languages | 50-53 | **6 trade-tongue skills** |
| Consortium of Civilized Worlds | 53-69 | 10 classes |
| Transgalactic Empire | 70-83 | 7 classes |
| United Worlds of Warlock, Splugorth, Paradise Fed. | 84-90 | 1 class |
| The Star Hives | 91-95 | 5 classes |
| The Dominators | 96-98 | 1 class |
| The Cosmo-Knights | 99-103 | 2 classes |
| Creating More Alien Races | 104-108 | a generator, not a class |
| Monsters and Animals | 109-113 | 5 creatures, no O.C.C. stat blocks |
| Weapons and personal technology | 114-129 | ~42 gear stat blocks |
| Robots & Powered Armor | 130-142 | 6 vehicles |
| Tanks & Infantry Fighting Vehicles | 143-149 | 5 vehicles |
| Starships & Space | 150-173 | **12 new skills (150-151)**, then ship rules and 14 vessels |
| Campaign ideas and NPC crew | 173-182 | NPC stat blocks, no new classes |
| **Experience Tables** | **183** | the playable-class authority |
| Character record sheets | 184-208 | blank forms — NOT an inventory source |

### Spells and psionics: this book defines ZERO of either

Checked by stat-block scan, not by reading. A `^P.P.E.( Cost)?:` scan hits 46
pages and an `^I.S.P.( Cost)?:` scan hits 25, and **every hit is a class or NPC
stat block's own pool line**, not a spell or power entry. There is no spell list,
no psionic power list, and no section heading for either in the Contents.

The 15 **Phase Powers** on printed 32-35 are the closest thing, and they are not
psionic powers: they are the Second Stage Promethean's racial abilities, costed
in I.S.P. but available to exactly one race and listed under its R.C.C. rather
than in any catalog-shaped table. They belong in that class's
`special_abilities`, not in `psionic_powers`. Recorded here so the next session
does not re-run the scan.

## Classes

**46 entries named across the two indexes. 42 carry a stat block; 35 of those
are playable and 31 are named in an experience ladder.** The ladder is the line,
and the four playable entries not named in one inherit a ladder the book states
in their own text.

### Playable (35) — the import target

XP ladders are shared; the column names the ladder as printed on p.183.

| class | printed | ladder (p.183) |
|---|---|---|
| First Stage Promethean | 25-26 | Noro Psychic / Promethean (First Stage) |
| Promethean Phase Adept | 27-28 | Phase Adept, Time Master & Wolfen Quatoria |
| Promethean Time Master | 28-29 | Phase Adept, Time Master & Wolfen Quatoria |
| Phase Mystic | 29-31 | Phase Mystic |
| Draconid | 35-36 | Silhouette, Draconid & Repo-Bots |
| Phantom | 36-38 | Machine People & Phantom / Vacuum Wasps |
| Spacer | 38-39 | Spacer & Colonist |
| Galactic Tracer | 39-40 | Freedom Fighter & Imperial Security / Galactic Tracer, Runner |
| Space Pirate | 40-41 | Space Pirate |
| Runner | 41-42 | Freedom Fighter & Imperial Security / Galactic Tracer, Runner |
| Colonist | 42-43 | Spacer & Colonist |
| Naruni Repo-Bot | 46-48 | Silhouette, Draconid & Repo-Bots |
| CAF Trooper | 56-58 | CAF Trooper |
| CAF Fleet Officer | 58-59 | TVIA Agent, CAF Fleet Officer, Imperial Legionnaire |
| TVIA Inspector | 59-60 | TVIA Agent, CAF Fleet Officer, Imperial Legionnaire |
| CAF Scientist | 60-61 | CAF Scientist |
| Noro | 61-63 | (race — uses its O.C.C.'s ladder) |
| Noro Psychic | 63-64 | Noro Psychic / Promethean (First Stage) |
| Noro Mystic Warrior | 64-65 | Seljuk, Noro Mystic Warrior, Kreeghor, and Catyr |
| Space Wolfen | 65-66 | (race — uses its O.C.C.'s ladder) |
| Wolfen Quatoria | 66-68 | Phase Adept, Time Master & Wolfen Quatoria |
| Catyr | 68-69 | Seljuk, Noro Mystic Warrior, Kreeghor, and Catyr |
| Seljuk | 69-70 | Seljuk, Noro Mystic Warrior, Kreeghor, and Catyr |
| Kreeghor | 73-74 | Seljuk, Noro Mystic Warrior, Kreeghor, and Catyr |
| Royal Kreeghor | 74-76 | (uses the Kreeghor ladder) |
| Machine People | 77-80 | Machine People & Phantom / Vacuum Wasps |
| Silhouette | 80-82 | Silhouette, Draconid & Repo-Bots |
| Imperial Legionnaire | 82 | TVIA Agent, CAF Fleet Officer, Imperial Legionnaire |
| Imperial Security Agent | 82-83 | Freedom Fighter & Imperial Security / Galactic Tracer, Runner |
| Freedom Fighter | 83-84 | Freedom Fighter & Imperial Security / Galactic Tracer, Runner |
| Pleasurer | 88-90 | Pleasurer & Termite Engineers |
| Vacuum Wasp | 92-93 | Machine People & Phantom / Vacuum Wasps |
| Termite Engineer | 93-94 | Pleasurer & Termite Engineers |
| Cosmo-Knight | 99-102 | Cosmo-Knight |
| Fallen Cosmo-Knight | 102-104 | (uses the Cosmo-Knight ladder) |

**`xp_table` goes on the O.C.C.s only.** `frontmatter.md` is explicit that a race
carrying one wins over the occupation's and silently drops it — the bug that
cost a rebuild during the Wormwood import. Every R.C.C. here records its ladder
in `extraction_notes` instead. Nineteen Rifts O.C.C.s in the catalog already
carry an `xp_table`, so this is a followed convention, not a new one.

**Two ladders are identical and that is not a transcription error.** *TVIA Agent,
CAF Fleet Officer, Imperial Legionnaire* and *Freedom Fighter & Imperial
Security / Galactic Tracer, Runner* print the same fifteen bands
(0-2,100 through 342,401-402,600). Checked band by band; they agree at every
one. The book simply prints one ladder twice for seven classes.

**The Space Pirate ladder's last band ends 375,701, where the pattern says
375,700.** Every other band in that column ends in a round hundred and the next
band's low is its high plus one; only the fifteenth high breaks it. Transcribed
as printed — a book typo is recorded, not corrected.

### Named but not playable (11)

Seven the book labels NPC or GM material in its own Contents, and four that are
lore, a cross-reference or a generator and carry no stat block at all:

| entry | printed | why it is out |
|---|---|---|
| Second Stage Promethean | 31-35 | Contents labels it NPC |
| True Naruni | 48-49 | Contents labels it NPC Villain |
| Kreeghor Emperor | 76-77 | Contents labels it NPC Villain |
| Killer Beetles | 91-92 | Contents labels it NPC Villain |
| Worker Ants | 94-95 | Contents labels it NPC Villain |
| Hive Queen | 95-96 | Contents labels it Evil Alien Intelligence |
| Dominator | 96-98 | no ladder, no O.C.C. skills, godlike stat block |
| Promethean R.C.C. | 24-25 | the race overview; First Stage is the stat block |
| Other Rifts O.C.C.s and R.C.C.s | 43-46 | cross-references to other books, no stat blocks |
| Creating More Alien Races | 104-108 | a nine-step generator, not a class |
| Gene Splicers | 49-50 | lore, no stat block |

`book-survey` §1's rule decided every one of these: a mention is not a
definition. Each was checked for `Attribute Requirement` / `O.C.C. Skills` /
`R.C.C. Skills` / `Standard Equipment` markers and none carries the set.

## Catalog diff

Run against **production** (`--remote`). Nothing in production cited this book
before this session, so every match below is a row that came from somewhere else.

### Classes: 42 missing, 0 false gaps

`node scripts/catalog-diff.mjs --remote --table imported_classes` returns
**matched 0, missing 42** against 126 catalog rows. Every nearest-candidate was
hand-checked and none is a false gap: the closest are `Phase Mystic` ~
`Psi-Mystic` (distance 3), `Runner` ~ `Ranger` (2) and `Spacer` ~ `Juicer` (3),
all plainly different classes. `Space Wolfen` ~ `Wolfen` (6) is the one worth
stating outright: p.52 says the Three Galaxies wolfen are the same race as the
Palladium world's, so the catalog's `Wolfen` and this book's `Space Wolfen` are
the same species in different settings — but different rows, because the R.C.C.
stat block on p.65 is its own.

### Skills: 12 in the book, 4 new rows, 8 re-citations

This is the interesting half of the diff, and it runs the other way from the
usual one.

The book prints its new skills in exactly two places: **printed 52-53**
(six Galactic Trade Tongues) and **printed 150-151** (`Space Skills (New)`,
twelve entries). Both were read as 200 dpi renders.

`catalog-diff --compare category,base,per_level` reported **matched 3, missing 9**
for the p.150-151 set. Hand-checking the nine turned six of them into
**false gaps under a different name** — and every one of those six is a row
citing `Rifts Skill List`, the phantom source that `source-coverage` reports as
`0 / 48` because no cached book contains it.

**Phase World is where those rows are actually printed.** The values agree
exactly, which is the evidence:

| catalog row (cited `Rifts Skill List`) | printed as | page | values |
|---|---|---|---|
| `Space: Space Fighter` Pilot 50/3 | Pilot: Space Fighter | 150 | agree |
| `Space: Small Spacecraft` Pilot 60/3 | Pilot: Small Spacecraft | 150 | agree |
| `Space: Starship` Pilot 36/4 | Pilot: Starship | 151 | agree |
| `Space: Extra-Vehicular Activity` Physical 40/5 | EVA | 150 | agree; book files it under *Pilot* |
| `Navigation: Stellar` Pilot Related 40/5 | Navigation - Space | 151 | agree |
| `Lore: Galactic/Alien` Technical 25/5 | Lore: Galactic/Alien | 151 | agree, name included |
| `Language: Trade Five/Reptile` Technical 40/5 | Trade Five | 52 | agree |
| `Language: Trade Six` Technical 45/5 | Trade Six | 52-53 | agree |

**Expect 12 new `drift-check` citation advisories, and do not "fix" them by
renaming.** That check asks whether the row's NAME appears in the text of the
page it cites. For 12 of the 15 rows this book now sources it does not, because
the catalog name and the book's own spelling differ on purpose - `Space: Space
Fighter` against *Pilot: Space Fighter*, `Space: Extra-Vehicular Activity`
against *EVA*, `Language: Trade Five/Reptile` against *Trade Five*. The
citations are correct and the advisory is the tool doing its job: it cannot
tell a wrong page from a right page under a different name, and it says so.
Three resolve cleanly - `Lore: Galactic/Alien`, `Language: Trade Three` and
`Law: CCW` - because those are the three the book spells the way the catalog
does.

**The action is re-citation, never a rename.** Characters reference skills by
name; renaming `Space: Space Fighter` to the book's `Pilot: Space Fighter` is
duplicate-tool work that rewrites characters, the same reasoning
`BOOK-INGEST-QUEUE.md` records for `W.P. Rope`. `source_book` moves to
`Rifts Dimension Book 2: Phase World p.NNN` and the book's own spelling goes in
`note`. That takes `rifts-skill-list` from 48 untraceable rows to **40**.

Genuinely new (7):

| skill | category | base | per level | page |
|---|---|---|---|---|
| Language: Trade One | Technical | 50 | 5 | 52 |
| Language: Trade Two | Technical | 50 | 5 | 52 |
| Language: Trade Three | Technical | 50 | 5 | 52 |
| Language: Trade Four | Technical | 50 | 5 | 52 |
| Zero Gravity Movement & Combat | Physical | see below | 4 | 150 |
| Pilot: Contragravity Pak | Pilot | 42 | 4 | 150 |
| Law: CCW | Technical | 30 | 5 | 151 |

Seven rows, four of them the trade tongues the catalog has never held — it holds
Trade Five and Trade Six and none of One through Four, which is why an NPC on
p.181 listing *Trade One, Four and Five* has two skills nothing can resolve.

**Two the diff surfaced that are NOT being touched, and both are judgement calls
for the catalog editor rather than SQL:**

- `Space: Spacecraft Mechanics` (Mechanical, **20**%+5%, `Rifts Skill List`)
  against the book's `Spaceship Mechanics` (Mechanical, **22**%+5%, p.150,
  confirmed on the render). Same category, same per-level, same concept, one
  word and two points apart. Correcting 20 to 22 would be adopting the printed
  authority over an unsourced value; adding a second row would duplicate it.
  Neither is obviously right and neither is urgent. **Left alone, recorded here.**
- `Space: Antigrav Suit` (Pilot, 44%+4%, `Rifts Skill List`) against
  `Pilot: Contragravity Pak` (Pilot, 42%+4%, p.150). Different name *and*
  different number, so these are treated as **two skills, not one** — the new
  row is added and the old one is untouched.

`Zero Gravity Movement & Combat`'s base is **P.P. number x5%**, an
attribute-derived percentage. `skills.base` is `INTEGER NOT NULL`, so the schema
cannot hold it. See `BOOK-INGEST-AUDIT.md` F2.

### Gear: 43 personal-equipment rows, 0 false gaps possible

Printed 114-129: energy weapons, body armor, force fields, phase technology,
gravitonic weapons and psionic crystal technology. 42 `Weight:` lines across the
range. **43 items were imported**, and that count comes from reading the
headings rather than from the `Weight:` scan: seven entries print no weight at
all - the Imperial Legionnaire's Armor, the Phase Sword, the OP-Field, the field
med kit, the Crystal-Cell, the Augmenting Helmet and the Telepathic
Communicator - while some entries carry a second `Weight:` line for an
accessory. A stat-block label count sizes a section; it does not enumerate it. Nothing in the catalog cites this book, and the names are
manufacturer-coded (`HI-30`, `NE-200`, `PH-400`, `GR-45HP`), so a false gap is
not possible — a collision would have to be another book selling the same model
number.

Prices are written `Black Market Cost:`, and the label **wraps across a line
break** on the pages that set it in a narrow column, which is why a naive
`^Cost:` scan finds 36 of them and misses every one on printed 119-122. Anything
parsing this section has to join lines first.

The vehicles (130-149) and starships (157-173) are a separate question and are
**not** planned — see below.

## Extraction plan

Phase 4 costs money; everything above was free.

1. **Skills, printed 52-53 and 150-151.** 7 new rows plus 8 re-citations. One
   PR. Already fully transcribed off renders — no further extraction needed.
2. **Classes, in ladder-shaped batches.** Batch 1 (the four CCW O.C.C.s of
   printed 56-61) is shipped; see the ledger. Two things it established that
   the rest of the batches inherit:

   - **A class's O.C.C. skill list can name a skill the book collects nowhere.**
     "Fighter Pilot: Basic" is not in the `Space Skills (New)` section and is
     not a trade tongue; its bonuses are printed on the far side of printed 151
     under a heading that does not say "skill". A section heading that says
     *New* is not the whole of what a book adds - check each class's list
     against the catalog rather than assuming the skills batch covered it.
   - **An "any language" pick must offer `Language: Other`, never a category.**
     `regression.mjs` holds this as an invariant and it is easy to get wrong;
     see F4 for the case it does not catch.
 The p.183 ladders group classes that
   share an XP table, and classes that share a ladder sit in the same chapter, so
   the ladder is also the cheapest batching. Order by how much the app can
   express: the CAF/CCW and Transgalactic O.C.C.s first (ordinary skill-and-gear
   classes), then the alien R.C.C.s, then the Prometheans and Cosmo-Knight last
   because those carry the most that the schema cannot hold.
3. **Gear, printed 114-129**, BEFORE the classes, so class equipment lists have
   real rows to point at rather than stubs. This was written the other way round
   in the first draft and is corrected here: a class import creates a stub for
   every slug it cannot resolve, and the CAF Trooper alone names eight.

What is deliberately left, with the reason for each:

- **The 11 non-laddered entries.** Six are NPC or GM material by the book's own
  Contents labels, three are lore or cross-reference pages with no stat block,
  one is the alien-race generator. Importing an NPC villain as a playable class
  contradicts the authority table.
- **Spacecraft, robots, power armor and tanks (130-149, 157-173).** `gear` has
  `mdc`, `damage`, `range` and `payload`, and a starship stat block has crew
  complement, FTL range in light years per hour, variable force fields and a
  location-by-location M.D.C. breakdown with a dozen entries. There is no table
  for a vessel and this batch does not add one. Filed as
  `BOOK-INGEST-AUDIT.md` F3.
- **Phase Powers (32-35).** Racial abilities of one class, not a catalog
  category — they go in that class's `special_abilities`.
- **Dog-fighting and space combat rules (151-157).** Rules text, not catalog
  data. The app has no vehicle combat model.
- **The `Space:` family rename.** Eight rows keep their catalog names; only their
  citations move. Renaming is duplicate-tool work.

## Ledger

| date | PR | what went in |
|---|---|---|
| 2026-08-28 | [#400](https://github.com/NateGrey0130/nates-workshop/pull/400) | cache built (209 pp), registered in `books.json`, offset 0 verified |
| 2026-08-30 | [#401](https://github.com/NateGrey0130/nates-workshop/pull/401) | survey written; inventory, both authority tables, the full catalog diff, findings F2 and F3, two corrections to the book's `books.json` note. No data. MERGED. |
| 2026-08-30 | [#403](https://github.com/NateGrey0130/nates-workshop/pull/403) | **skills**: 7 new rows (4 Trade Tongues, Law: CCW, Space: Contragravity Pak, Space: Zero Gravity Movement & Combat) and 8 re-cited off `Rifts Skill List` onto printed 52-53 and 150-151. Catalog 336 -> 343 skills; `rifts-skill-list` 48 -> 40 untraceable. Applied `--remote` before the PR. |
| 2026-08-30 | [#404](https://github.com/NateGrey0130/nates-workshop/pull/404) | **gear**: 43 rows from printed 114-129 - 22 weapon, 15 armor, 6 gear. Catalog 975 -> 1018. Every number read off a 200 dpi render; the OCR agreed on all 43. No vessels (F3). Applied `--remote` before the PR. |
| 2026-08-30 | [#405](https://github.com/NateGrey0130/nates-workshop/pull/405) | housekeeping: a commit message that shipped as a file, removed, and `*.tmp` gitignored. No data. |
| 2026-08-30 | [#406](https://github.com/NateGrey0130/nates-workshop/pull/406) | **classes, batch 1 of the CCW O.C.C.s**: CAF Trooper, CAF Fleet Officer, TVIA Inspector, CAF Scientist (printed 56-61). Catalog 126 -> 130 classes, 343 -> 345 skills (Fighter Combat: Basic and Elite, off printed 151, which the skills batch missed), 1018 -> 1020 gear. Finding F4 filed. Applied `--remote` before the PR. |

### What remains

From `node scripts/source-coverage.mjs --remote` at the time this survey was
written — before anything from this book had shipped:

```
  rifts-skill-list     0 / 48
  phase-world        (absent — no row cites this book)
```

`rifts-skill-list`'s 48 are `not-cached`: the citation names a source that is
not a book and that no cache can ever hold. **Eight of the 48 are printed in
this book** and this batch moves them; the other 40 stay untraceable and are not
this book's problem.
