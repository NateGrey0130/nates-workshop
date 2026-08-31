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

### The three page numbers, because they are not the same number

| you want printed N | use |
|---|---|
| the cached OCR text | `.cache/books/phase-world/txt/pNNN.txt` — **N** |
| `scripts/read-columns.py` | **N** (it calls `doc[n - 1]` itself) |
| a `pymupdf` render or probe | **`doc[N - 1]`** |

```python
import pymupdf
doc = pymupdf.open(pdf)
doc[74 - 1].get_pixmap(dpi=200).save('p074.png')   # printed 74
```

**`page_offset: 0` describes the CACHE, not the PDF index**, and that is the
whole reason these differ. `ocr-book.py` numbers its output by the folio it
measured; the PDF's own index depends on how many unnumbered pages sit in front
of folio 1, which varies book to book. `book-survey` 0d illustrates a
zero-offset book as printed 16 -> `d[16]`, which is `potm`'s answer and is one
higher than this book's. The registry note carries the same inheritance: it says
`read-columns.py N+1` after potm, ww and triax, and here it is N.

**Read the folio off the render every time.** It is free, it is printed at the
bottom of the page, and it is the only check that catches this. The batch-4
session rendered `doc[74]`, got printed **75**, and only noticed because the
page was a full-page illustration where a stat block should have been.

**Two corrections to the registry note, both measured this session.**

- The note says `read-columns.py N+1`. It is **N** — see the table above.
  The distinction is moot in practice for this book, which has no text layer, so
  `read-columns.py` returns an empty page for every number you give it. It was
  still wrong, and it would have been believed on a book where it mattered.
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

**Corrected 2026-08-31 by the batch that imported the Repo-Bot: the heading is
not the authority either. The FIELDS are.** The Naruni Repo-Bot is headed
`R.C.C.` on printed 46 and its stat block prints `Attribute Requirements`,
`O.C.C. Abilities and Bonuses`, `O.C.C. Skills`, `O.C.C. Related Skills`,
`Standard Equipment`, `Money` and `Cybernetics` - and **no `Attributes:` line at
all**, where every R.C.C. in this book rolls eight. Three lists say race, every
field says occupation, and only the fields decide what the app does with it:
`category: rcc` makes `app.js` offer an occupation step whose related and
secondary allowances REPLACE the class's own, which for this class is the whole
of what it grants. Imported as `occ`. The rule above still settles a NAME; it
does not settle a category, and this is the entry that separates the two.

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

### Spells: this book defines ZERO. Psionics: fifteen, under another name

Checked by stat-block scan, not by reading. A `^P.P.E.( Cost)?:` scan hits 46
pages and an `^I.S.P.( Cost)?:` scan hits 25, and **every hit is a class or NPC
stat block's own pool line**, not a spell or power entry. There is no spell list
and no section heading for one in the Contents. That half stands: after nine
batches, no row citing this book is in `spells`.

**The psionics half of this paragraph was wrong twice over and batch 9 corrected
it.** It said the 15 **Phase Powers** on printed 32-35 were the Second Stage
Promethean's racial abilities, available to exactly one race, and belonged in
that class's `special_abilities`. Printed 32's own opening paragraph says
otherwise on both counts: it calls them a variation on psionic abilities,
activated with I.S.P., and names the phase mystic O.C.C. as the only learner
besides the prometheans themselves.

So they belong to the whole promethean race and to one non-promethean O.C.C.,
not to the NPC second stager; and three of the four playable entries in printed
25-31 select from them by count and by level - the Phase Adept takes six at
first level and one per level after, the Phase Mystic four and one per level,
and a first stage promethean may spend up to four "other" skill picks on them.
They went in as **fifteen `psionic_powers` rows in a new category, `Phase`**.
Each prints Range, Duration, I.S.P. and a description, which is the exact column
set that table holds, and `js/catalog-fields.js` carries `allowOther` on the
category select with a comment saying in as many words that a later book may add
a category the core four do not cover.

**Where a section heading says "not psionic powers", check what the entries
print.** This one was written off a Contents scan that never opened printed 32.

## Classes

**46 entries named across the two indexes. 42 carry a stat block; 34 of those
are playable and 31 are named in an experience ladder.** The ladder is the line,
and the three playable entries not named in one inherit a ladder the book states
in their own text.

**Corrected 2026-08-30, in the batch that reached this chapter.** The first pass
counted 35 playable and put the Royal Kreeghor among them, on the reasoning that
it shares the kreeghor ladder. It does not share it and it is not playable: the
heading on printed 74 reads *Royal Kreeghor R.C.C. / **NPC Villains***, the
entry closes with "Royal Kreeghor are not intended to be player-characters. They
are a sub-race of supernatural monsters used as villains and antagonists", and
p.183 names no ladder for it. Both authorities agree and the survey disagreed
with both. The Contents does not label it, which is how it got past - the label
is in the section heading itself, and this is the only entry in the book where
those two disagree.

### Playable (34) — the import target

XP ladders are shared; the column names the ladder as printed on p.183.

| class | printed | ladder (p.183) |
|---|---|---|
| First Stage Promethean | 25-27 | Noro Psychic / Promethean (First Stage) |
| Promethean Phase Adept | 27-28 | Phase Adept, Time Master & Wolfen Quatoria |
| Promethean Time Master | 28-29 | Phase Adept, Time Master & Wolfen Quatoria |
| Phase Mystic | 29 | Phase Mystic |
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
| Machine People | 77-80 | Machine People & Phantom / Vacuum Wasps |
| Silhouette | 80-82 | Silhouette, Draconid & Repo-Bots |
| Imperial Legionnaire | 82 | TVIA Agent, CAF Fleet Officer, Imperial Legionnaire |
| Imperial Security Agent | 82-83 | Freedom Fighter & Imperial Security / Galactic Tracer, Runner |
| Freedom Fighter | 83-84 | Freedom Fighter & Imperial Security / Galactic Tracer, Runner |
| Pleasurer | 88-89 | Pleasurer & Termite Engineers |
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

### Named but not playable (12)

Eight the book labels NPC or GM material - seven in its own Contents and one in
its section heading - and four that are lore, a cross-reference or a generator
and carry no stat block at all:

| entry | printed | why it is out |
|---|---|---|
| Second Stage Promethean | 31-35 | Contents labels it NPC |
| True Naruni | 48-49 | Contents labels it NPC Villain |
| Royal Kreeghor | 74-76 | its own heading labels it NPC Villains; no ladder on p.183 |
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
   - **`mind_control` IS a save key, and so are the rest of an open set.**
     Batch 2 shipped both noro O.C.C.s without the mind-control bonus their book
     prints, on an assertion that the sheet had no field for it. `js/derive.js`
     reads `mind_control` and five published classes were already using it. The
     frontmatter reference lists save keys as EXAMPLES and says outright that
     combat and saves are open sets. **Grep before concluding a key does not
     exist** - the class-import skill's rule about unmodelled keys applies in
     this direction too, and it is the direction with no error message.
     Corrected by `fix-noro-mind-control-saves.sql` in batch 3.
   - **`js/leveling.js` IS THE REFERENCE FOR SCHEDULES, not `frontmatter.md`.**
     That file lists four keys under `magic` and calls them examples, and the
     real set is much larger. `spells_per_level` with
     `spells_per_level_levels: up_to_character_level` expresses "two more spells
     per level, never above your own level" exactly - it is the Ley Line
     Walker's rule and it is named in the comment above `spellLevelsForGrant`.
     A `powers_schedule` or `spells_schedule` ENTRY carries its own `categories`
     or `spell_levels`, which OVERRIDE the class-wide gate rather than narrowing
     it, and its own `note`, which is shown to the player at the moment of the
     pick - the intended home for a restriction the catalog cannot enforce. And
     `powers_starting_groups` splits a starting allowance across categories, so
     "two from each of the four" is not `powers_starting: 8`.

     Batch 4 found all four of those by grepping, and used them to fix batch 2:
     the noro psychic could never take the Super power its book grants at second
     level, both noro schedules stopped at level 3 where the book says "third
     level and beyond", and the mystic warrior could take eight Super powers
     where the book grants two. See `fix-noro-psionic-schedules.sql`. This is
     the SECOND correction of this shape in three batches; the first was
     `mind_control`. Both were notes asserting a limit that was not there.

   - **A section heading can carry the NPC label the Contents does not.** The
     Royal Kreeghor is headed *NPC Villains* on printed 74 and the Contents
     lists it plainly, so a survey built from the Contents counted it playable.
     p.183 agrees with the heading by giving it no ladder. Where a class is
     absent from p.183, read its own heading before inheriting a ladder for it.

   - **A RENDER CAN CORRECT A NUMBER, NOT JUST DISAMBIGUATE ONE.** The Runner's
     cached text reads `EVA (45%)`. The page reads `EVA (+5%)`. A plus sign
     lost to the scan turned a five into a forty-five, and nothing downstream
     would ever have flagged a 45% skill bonus as impossible - every check in
     the tree is structural. Every percentage in this batch was read off a
     200 dpi render for that reason.

   - **A NEAR-MISS SAVE KEY IS WORSE THAN NO KEY AT ALL.** The Spacer's only
     mechanical grant is "+2 to any saves against explosive decompression or
     other space dangers", and `sheet.js` renders saves from `SAVE_FIELDS`, a
     literal list of SIXTEEN. There is no environmental save in it. The first
     draft wrote `toxins_poisons: 2` - the nearest label a GM would reach for -
     which would have handed the class a real, rendered +2 against venom the
     book never granted. `bonuses.saves` accepting an unknown key is what makes
     `mind_control` work without a schema change; the cost is that
     `space_hazards: 2` parses, validates and renders NOWHERE. Filed as F7.
     Read `SAVE_FIELDS` before mapping a save.

   - **A BOOK CAN PRINT A PERCENTAGE THAT BELONGS TO SKILLS RATHER THAN TO A
     CATEGORY.** The Spacer's list has "Science: Any (+10% ON MATH)" and
     "Technical: Any (+10% ON LANGUAGE AND COMPUTER SKILLS)"; the Machine
     People had "Rogue: Any (+10% ON COMPUTER HACKING)". `occ_related_skills`
     can only put a bonus on a whole category, so storing these would hand the
     percentage to every pick in it. They go in the note.

   - **TWO CLASSES CAN SHARE A PAGE AND TWO CATEGORY LISTS CAN SHARE A COLUMN.**
     Printed 83 carries the Imperial Security Agent's related-skill list in its
     right column and the Freedom Fighter's heading below it; the Freedom
     Fighter's own list is at the head of 84. The two lists differ in four
     places - Espionage and Rogue at +10% against +5%, Domestic at nothing
     against +5%, Pilot Related at +5% against +10% - and nothing in the OCR
     says which is which. `--field-sources` made the same point about money: it
     printed BOTH `Money: 2D6x100` (p84) and `Money: 4D6x1000` (p83) inside one
     class's window. Render the page.

   - **A per-category MINIMUM is not expressible.** Both Empire O.C.C.s require
     "at least two [of the eight related picks] from espionage and two from
     rogue". `occ_related_skills` has one open count; moving four picks into
     `occ_skills` as choice groups would enforce the floor and quietly shrink
     the free eight to four. Stated in the note and filed as F6.

   - **A conditional bonus can be almost the whole bonus line.** The Silhouette
     prints "+2 on initiative, +2 to strike, parry and dodge, +4 to roll with
     impact, but only when in the shadows. +4 to save vs horror factor." Four of
     its five bonuses evaporate in daylight, so `bonuses` holds one number and
     the rest are prose. Storing that line as written would have made the race a
     good fighter everywhere.

   - **A wrapped inline list is a parse error, not a style choice.** The
     frontmatter parser is line-based: an inline `[...]` or `{...}` must close
     on the SAME line. A twelve-name `psionics.powers` list wrapped across three
     lines made `class-check` throw a `TypeError` out of `catalog.js` - though
     it did print `UNCLOSED FLOW` above the stack, which is the line to read.
   - **A psionic class's `categories_allowed` will usually be an approximation.**
     Both noro O.C.C.s widen their allowed categories with level - three at
     first, plus Super at second, anything at third - and the key is one list
     for the whole class. Set it to the FIRST level's set, which fails closed,
     and put the schedule in `extraction_notes`. Named exclusions (mind wipe,
     psi-sword, possess others) cannot be expressed at all.
   - **Run `class-check` with `--remote`, always.** This machine's local D1 held
     **293** skills against production's **345** on 2026-08-30, so the default
     `--local` run reported seven skills as missing that production has had for
     months - `Radio: Basic`, `Climbing`, `Swimming`, both energy-weapon W.P.s
     and two more - and offered stub SQL for every one. Emitting a script from
     that report writes stubs that then SHADOW the real rows, because a stub
     `INSERT OR IGNORE` in an `add-<class>-class.sql` sorts before the file that
     creates them properly. CLAUDE.md warns that local is not a mirror of
     production because it ACCUMULATES; here it was 52 rows behind, which is the
     same rule failing in the other direction and is worse, because a missing row
     produces a confident instruction to create one.

   - **A FIXED ATTRIBUTE VALUE IS NOT A DICE STRING, AND THE APP EATS IT
     SILENTLY.** The Repo-Bot's chassis has "a P.S. of 50, P.P. 26".
     `attribute_dice` looks like the field for that and is not:
     `rollAttribute` in `js/dice.js` matches only `NdM` forms and falls back to
     `3d6` on anything else, **rewriting the notation as it goes** - measured,
     `rollAttribute("50")` returns 9 and reports `"3d6"`. A sweep of all 148
     published classes found exactly one already carrying it, the Holy Terror's
     `PS: "50"` from Wormwood, which has had a human's strength since import
     with `class-check` calling it `ready` the whole time. Filed as F8. Neither
     Repo-Bot figure is stored; both are in a natural ability. This is F7's rule
     in the other direction - an absent value that reads as absent beats a
     stored one that reads as effective.

   - **"Includes P.P. bonuses" MEANS THE APP WOULD DOUBLE-COUNT.** Even with F8
     fixed, the Repo-Bot's P.P. could not go in. Its bonus line is headed
     *Bonuses (Includes P.P. bonuses)*, so the printed +8 to strike, parry and
     dodge already contains it, and `derive.js` adds its own `pp_combat` figure
     on top of whatever `attribute_dice` supplies. Read the bonus HEADING, not
     just the numbers under it.

   - **`variants` CANNOT CARRY A MAGIC OR PSIONICS BRANCH.** Every draconid is
     born either a ley line walker or a mind melter, in full. `VARIANT_OVERRIDES`
     in `js/parser.js` is a literal list of seven keys - `attribute_dice`,
     `attribute_requirements`, the four pool bases, `starting_money`, `bonuses`
     and `skill_overrides` - and `magic` and `psionics` are not among them. A
     variant would have carried the magician's P.P.E. bonus and silently dropped
     the spell casting it exists to grant, which is the near-miss shape of F7.
     Grepped rather than assumed, and it is the counter-example to the
     `js/leveling.js` lesson above: that file is a bigger contract than
     `frontmatter.md` says, and this one is exactly as small as it looks.

   - **A CATEGORY PRINTED AS `None` IS AN EXCLUSION, NOT A ZERO BONUS.** The
     Repo-Bot's related list prints *Electrical: None, Mechanical: None,
     Medical: None, Physical: None, Science: None*. Those five are omitted from
     `categories` entirely; listing them without a bonus would offer skills the
     book bars, and the OCR renders `Espionage: None` identically to a category
     printed with no bonus. THIS IS NOT RARE AND THE FIRST DRAFT SAID IT WAS: a
     grep of the cached pages finds `<category>: None` on printed 28, 39, 42,
     43, 48, 49, 59, 64, 68, 76, 82, 89, 93 and 94 - at least a dozen entries,
     several of them already imported. What is distinctive about the Repo-Bot is
     only the COUNT: five, where no other entry bars more than four.

   - **A FULL-PAGE ILLUSTRATION CAN SPLIT ONE ENTRY.** The Repo-Bot's numbered
     abilities run 1-3 on printed 46 and resume at 4 on printed 48; printed 47
     is a full-page picture whose OCR is `KS` and `YY`. `--field-sources` prints
     that gap as "span ends near the bottom of the page" and shows the noise,
     which is the tell. Render the intervening page rather than assuming a
     numbered list is contiguous.

   - **A CHAPTER CAN INTERLEAVE PLAYABLE ENTRIES WITH NPC ONES, IN THE SAME
     COLUMN.** The Star Hives run Killer Beetles (NPC, 91-92), Vacuum Wasp
     (playable, 92-93), Termite Engineer (playable, 93-94), Worker Ants (NPC,
     94-95), Hive Queen (95-96), and printed 92 and printed 94 each carry one of
     each. The money check `--field-sources` exists for could not fire here -
     grepping printed 88-95 finds NO `Money:` and NO `Standard Equipment:` line
     at all, on any of the five - so the whole risk sat in the stat blocks and
     the category lists, and the only defence was reading each entry's own
     column off a render. The reconcile pass found no crossed numbers and DID
     find one crossed sentence: a natural-ability description that had borrowed
     the Killer Beetles' remark about attacking the spawn of OTHER hives, from
     their paragraph on printed 91. Prose bleeds before numbers do.

   - **THE BOOK'S ODD PERCENTAGES ARE REAL, AND THEY ARE NOT ONE-OFFS.** Nine
     hundred-odd percentages in this book are multiples of five; ten are not.
     `(+6%)` appears three times, always as `Rogue: Any (+6%)` - printed 40
     (Galactic Tracer), printed 64 (Noro Mystic Warrior), printed 89
     (Pleasurer) - and `(+8%)` and `(+12%)` once each, both on printed 42
     (Runner). All six rows store what is printed. The Galactic Tracer shipped
     in #413 saying its +6% was unique to it and appeared on its page twice;
     both halves were false and `fix-galactic-tracer-rogue-note.sql` corrects
     them. **Tally the whole cache before writing "the only" into a note** -
     one `grep -ohE '\(\+[0-9]+%\)' | sort | uniq -c` answers it, and it is
     free. Two of batch 7's notes and two of batch 6's failed this way.

   - **A PARENTHESISED SECOND ATTRIBUTE IS A DIFFERENT CREATURE, AND THE SKILL
     LIST DECIDES WHICH ONE YOU ARE IMPORTING.** Both hive classes print
     "I.Q. 2D6 (3D6)" or "I.Q. 3D6 (3D6+6)" and say the parenthetical is for the
     sentient ones. The R.C.C. Skills line then says outright that the normal
     ones have no skills at all. Import the skill list and you have imported the
     sentient creature, so the parenthetical I.Q. is the one that belongs beside
     it; storing the low figure with the high creature's skills describes
     neither.

   - **A CROSS-CATEGORY `only` KEEPS THE SKILL AND LOSES THE PERCENTAGE.**
     "Rogue: Prowl only (+5%)" works - `categoryAllows` admits the name because
     the class also lists Physical, which is where the catalog files Prowl - but
     `categoryBonus` keys on the skill's REAL category, so the +5% lands
     nowhere while the picker still shows the player "Rogue (Prowl only; +5%)".
     Deliberate, and its reason is good; it just cannot tell a cross-category
     line WITH a printed percentage from one without. Three rows in the whole
     catalog are affected, swept rather than guessed. Filed as F9.

   - **A PERCENTAGE STATED OUTSIDE THE SKILL LIST MAY STILL BE A SKILL.** The
     Pleasurer's shapeshifting gives "Disguise ability equal to 70% +2% per
     level", printed under Natural Abilities. The catalog has a Disguise row and
     the entry keys `base` and `per_level` say exactly that, so it is granted as
     a skill rather than described in prose. The Termite Engineer's "Chitin
     Molding 50% +2% per level" is the same sentence with the opposite answer:
     no catalog row, one race, and a new skills row would offer it to every
     class granting whatever category it was filed under. The test is whether
     the catalog already holds the row, not whether the book calls it a skill -
     the book calls both of them skills.

   - **A RACE AND AN O.C.C. THAT ARE BOTH PSYCHIC KEEP ONLY ONE BLOCK.**
     `combineClasses` merges skills, sums bonuses and concatenates abilities,
     and then CHOOSES `psionics`: whichever tier is STRICTLY higher, so a tie
     goes to the race and the occupation's granted powers, starting picks,
     categories and whole level schedule are discarded. Measured on all 361
     race/occupation pairs where both state psionics: 93 discard a block that
     had picks to lose, across 17 O.C.C.s. Two of this book's own have already
     shipped that way - `noro` + `noro-psychic` are both major, so #409's
     twelve powers and #411's corrected schedule have never composed. Filed as
     F10. **The tier is not the lever**: master is the top of the ladder, so a
     master race beats a master O.C.C. and lowering the O.C.C. cannot help.
     Check the pairing the BOOK intends before assuming a psionics block will
     be read at all.

   - **A "NOT A CATALOG CATEGORY" NOTE IS A CLAIM, AND THIS SURVEY'S WAS FALSE.**
     The Phase Powers were written off as one NPC class's racial abilities on a
     Contents scan that never opened printed 32, whose first sentence says they
     are a variation on psionic abilities, available to every promethean and to
     the phase mystic O.C.C. Three playable entries select from them by count
     and by level. They became fifteen `psionic_powers` rows in a new `Phase`
     category - `js/catalog-fields.js` carries `allowOther` on that select with
     a comment inviting exactly this. **Before writing "the app has no table for
     this", open the pages and read what the entries print**; and before adding
     a category, check the gate fails CLOSED. `psiConfig` in `app.js` defaults a
     class stating no `categories_allowed` to the core four rather than to
     anything, and the eight psionic classes that state none were checked one at
     a time - not one has a `powers_schedule` or a `powers_per_level`, so none
     has a level-up picker to leak through either.

   - **`powers_starting_groups` AND A SLOTTED `powers_schedule` EXPRESS TWO
     POOLS GROWING AT ONCE.** The Phase Adept takes six phase powers AND one
     super-psionic at first level, then one of each at every level after.
     `entryAt` indexes a schedule by (level, slot), so two entries at the same
     level with different `categories` is the supported shape, not a workaround
     - the Shifter's three slots are the comment's own example. Twenty-eight
     entries is verbose and exact; a single `powers_per_level: 2` would have
     let a player take two phase powers and no psionics.

   - **A BOOK CAN NAME A SPELL LIST THIS CATALOG DOES NOT HAVE, AND THE HONEST
     ANSWER IS TO GRANT LESS.** The Time Master learns two temporal magic spells
     plus two normal ones at first level, and one of each per level after. The
     catalog holds 607 spells and NOT ONE is temporal magic - zero rows cite
     Rifts England, and the five time-flavoured spells it does hold are ordinary
     invocations from the Book of Magic and Palladium Fantasy. A spell group
     with a note and no gate would have offered the whole catalog for a pick the
     book restricts to a list this machine does not have, which is F7's shape.
     Only the normal half is granted; the temporal half is a special ability the
     player reads at the table. `spells_per_level: 1` with
     `spells_per_level_levels: up_to_character_level` says "of the same or lower
     level as the character" exactly.

   - **A SPECIFIC NAMED LANGUAGE WITH NO CATALOG ROW GOES THROUGH
     `Language: Other`.** All four entries grant "Language and literacy:
     Promethean 98%", and Promethean is not in the book's own Languages section
     on printed 52-53, which defines the six Galactic Trade Tongues and nothing
     else. A mention is not a definition, so no row was invented; the precedent
     is the catalog's existing `{ name: "Language: Other", base: 98, note: "His
     native tongue of Br'talb" }`. This is the F4 invariant reaching a case it
     was not written for: it is not an "any language" pick, and it resolves the
     same way.

   - **THE APOK'S NOTE ABOUT `bonuses.attributes` IS STALE, AND IT WAS BELIEVED
     ONCE.** It says the key takes flat numbers only, so the Apok's +2D6 P.S.
     was dropped to prose. `validateBonusGroup` in `js/parser.js` accepts a dice
     expression in EVERY group and has since the Godling's +1D4 initiative;
     eight published classes already carry one. The Phase Adept's +1D6 to P.S.
     and +1D4 to P.P. are stored as dice. **A note in a shipped class is not a
     contract** - the same rule as `frontmatter.md` versus `js/leveling.js`,
     failing in the same direction.

   - **THE PAGE RANGES IN THIS SURVEY'S OWN TABLE ARE STILL WRONG, TWO MORE OF
     THEM.** The First Stage Promethean is printed 25-**27**, not 25-26: its
     Secondary Skills, Alliances, Weapons, Body Armor and Equipment lines are at
     the head of 27 above the Phase Adept's heading. The Phase Mystic is printed
     **29 alone**, not 29-31: it opens and closes on one page, printed 30 is a
     full-page illustration whose folio reads 30 on the render, and printed 31
     opens the NPC Second Stage Promethean. That is four corrections in two
     batches - the Pleasurer in #416 was the other two. **Re-derive every range
     from the entry's own heading and its own last line.**

   - **AN S.D.C. LINE READING "PLUS SKILL AND O.C.C. BONUSES" IS A POOL BONUS.**
     The Pleasurer's "1D6x10 + 40 S.D.C. plus skill and O.C.C. bonuses" is the
     cumulative shape, so it is `bonuses.pools.sdc` and not `sdc_base` - written
     as a base it would REPLACE the occupation's roll. The consequence is easy
     to miss: a pool bonus cannot conjure a pool into existence, so a race with
     no occupation then has no S.D.C. at all unless the class also gets a
     `CORE_SDC_BY_CLASS` entry. That entry is the one code change this book is
     allowed, and it is required rather than optional.
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
- ~~**Phase Powers (32-35).**~~ **Imported after all, in batch 9** - fifteen
  `psionic_powers` rows in a new `Phase` category. This line said they were one
  NPC class's racial abilities and belonged in `special_abilities`; printed 32
  says they are a variation on psionic abilities available to every promethean
  and to the phase mystic O.C.C., and three playable entries select from them.
  See the psionics section above.
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
| 2026-08-30 | [#407](https://github.com/NateGrey0130/nates-workshop/pull/407) | survey note: run `class-check` with `--remote`, because this machine's local D1 was 52 skills behind. No data. |
| 2026-08-30 | [#408](https://github.com/NateGrey0130/nates-workshop/pull/408) | survey: real `source-coverage` paste replacing the pre-import one - `phase-world 66 / 0`, `rifts-skill-list` 48 -> 40. No data. |
| 2026-08-30 | [#409](https://github.com/NateGrey0130/nates-workshop/pull/409) | **classes, batch 2 - the noro**: Noro R.C.C., Noro Psychic, Noro Mystic Warrior (printed 61-65). Catalog 130 -> 133 classes. The book's first R.C.C. and its first two psionics blocks here. Second occurrence added to F3. Applied `--remote` before the PR. |
| 2026-08-30 | [#410](https://github.com/NateGrey0130/nates-workshop/pull/410) | **classes, batch 3 - the rest of the CCW**: Space Wolfen, Wolfen Quatoria, Catyr, Seljuk (printed 65-70). Catalog 133 -> 137 classes. Also `fix-noro-mind-control-saves.sql`, correcting a save both noro O.C.C.s shipped without in #409. The CCW chapter is complete. Applied `--remote` before the PR. |
| 2026-08-30 | [#411](https://github.com/NateGrey0130/nates-workshop/pull/411) | **classes, batch 4 - the Transgalactic Empire races**: Kreeghor, Machine People, Silhouette (printed 73-81). Catalog 137 -> 140 classes. Also `fix-noro-psionic-schedules.sql`, correcting a psionic power schedule both noro O.C.C.s shipped wrong in #409, and the survey correction that moves the Royal Kreeghor out of the playable list. Finding F5 filed. Applied `--remote` before the PR. |
| 2026-08-30 | [#412](https://github.com/NateGrey0130/nates-workshop/pull/412) | **classes, batch 5 - the Transgalactic Empire O.C.C.s**: Imperial Legionnaire, Imperial Security Agent, Freedom Fighter (printed 82-84). Catalog 140 -> 143 classes. The Empire chapter is complete. Finding F6 filed. Applied `--remote` before the PR. |
| 2026-08-30 | [#413](https://github.com/NateGrey0130/nates-workshop/pull/413) | **classes, batch 6 - the five spacefaring trades**: Spacer, Galactic Tracer, Space Pirate, Runner, Colonist (printed 38-43). Catalog 143 -> 148 classes. Finding F7 filed. Applied `--remote` before the PR. |
| 2026-08-31 | [#414](https://github.com/NateGrey0130/nates-workshop/pull/414) | survey: the three page numbers - cache pNNN, read-columns.py N, pymupdf doc[N-1] - written out as a table, after a batch-4 render came back one page late. No data. |
| 2026-08-31 | [#415](https://github.com/NateGrey0130/nates-workshop/pull/415) | **classes, batch 7 - two races and the Naruni enforcer**: Draconid (printed 35-36), Phantom (36-38) and the Naruni Repo-Bot (46-48). Catalog 148 -> 151 classes, 1020 -> 1021 gear (a `plasma-hand-cannon` stub; the weapon appears once in the whole book and is stat-blocked nowhere). Finding F8 filed, with a sweep of all 148 published classes behind it. The Repo-Bot's category corrected away from its own heading; see the Quick Find section. Applied `--remote` before the PR. |
| 2026-08-31 | [#416](https://github.com/NateGrey0130/nates-workshop/pull/416) | **classes, batch 8 - the Pleasurer and two hive-spawn**: Pleasurer (printed 88-89), Vacuum Wasp (92-93) and Termite Engineer (93-94). Catalog 151 -> 154 classes; no new skills and no new gear, because none of the three states any. Also `fix-galactic-tracer-rogue-note.sql`, correcting two false claims #413 shipped about the book's +6%. Finding F9 filed, with a three-row sweep behind it, and the Pleasurer added to F5 as its second occurrence. One `CORE_SDC_BY_CLASS` entry in `js/compose.js`, for the Pleasurer. Applied `--remote` before the PR. |
| 2026-08-31 | [#417](https://github.com/NateGrey0130/nates-workshop/pull/417) | **classes, batch 9 - the four Prometheans**: First Stage Promethean (printed 25-27), Promethean Phase Adept (27-28), Promethean Time Master (28-29) and Phase Mystic (29). Catalog 154 -> 158 classes, 101 -> 116 psionic powers, 1021 -> 1024 gear. The book's FIRST psionic rows and its first magic-granting class. The 15 Phase Powers of printed 32-35 went in as `psionic_powers` in a new `Phase` category, correcting this survey, which had them down as one NPC class's racial abilities; three of the four playable entries select from them. Gear: two steelcloth armors read off their class pages (A.R. 12/90 M.D.C. and A.R. 19/40 M.D.C.) plus one stub, the meditation chip. Finding F10 filed, with a 361-pair sweep behind it - a race and an O.C.C. that are both psychic keep only one block, and the race wins every tie. Three `CORE_SDC_BY_CLASS` entries in `js/compose.js`, for the three O.C.C.s. Two page-range corrections and no new skills or spells. Applied `--remote` before the PR. |

### What remains

`node scripts/source-coverage.mjs --remote`, after batch 9:

```
  rue                648 / 23
  pf                 583 / 3
  bom                412 / 0
  ww                 130 / 0
  phase-world        113 / 0
  ju                  62 / 0
  rifts-skill-list     0 / 40
```

**`phase-world` is 113 traceable and 0 other.** Every row citing this book names a
page range this machine holds, across skills, gear and classes, which is what
`traceable` means and all it means. It does not say the numbers are right; the
gear script's own defence for that is the fourteen 200 dpi renders it was read
from, and each class batch has its own.

The per-table breakdown this paragraph used to spell out is deliberately gone.
It said "9 skills, 8 re-citations, 43 gear and 22 class citations" beside a
total of 84, and those four numbers add to 82. Nothing checks a hand-kept
breakdown, and this one was already wrong. Re-run `source-coverage.mjs
--remote` for the total; it is the only figure here that any tool produces.

It was 66 after the first four PRs, 73 after batch 3, 76 after batch 4, 79
after batch 5, 84 after batch 6, 88 after batch 7 and 91 after batch 8.

**"Each class adds one" was true for six batches and batch 9 broke it**, moving
the figure by 22 for four classes: the four class rows, fifteen `psionic_powers`
rows for the Phase Powers, and three gear rows. A batch adds one per class only
while it adds nothing else, and this ledger counts ROWS rather than entries.

**`rifts-skill-list` is down from 48 to 40** and will not go lower from this
book. The remaining 40 are `not-cached` and permanently so: the citation names a
one-page sheet, not a book, and there is no PDF to cache. Finding the real book
*under* a phantom source is the only thing that moves that number, and eight of
them turned out to be printed here.

The pre-import paste this section used to hold said `phase-world (absent - no
row cites this book)`. That is the line this batch replaced.
