# Book-ingestion batch — deferred code changes, 2026-08-28

> **Status lives under each finding, not in this header.** Every finding here
> carries its own dated outcome note beneath its heading; read to the next
> `###`. **`F3`'s schema half closed 2026-09-03 in PR #616** — the keep-dropping
> option, with the standing limitation written into `docs/known-limitations.md`
> where a reader of `gear` will meet it. It was the only finding on this menu
> ever taken in halves.
>
> **This header still states no overall verdict, and that is deliberate.**
> Several findings here close with a residue rather than a full stop: `F3` names
> the trigger that would reopen it, and `F11` records a `class-check` warning it
> decided against building and still thinks worth having. A one-word status
> would flatten those into *closed* or reopen them wrongly. Read the notes.
>
> **`F12`'s outcome note still says `F3`'s schema half is open, and it is not
> wrong.** It is a measurement dated 2026-08-31 and it stays as one, per this
> repo's rule that an audit file is a record. The same goes for the four class
> notes citing `F3`: *"`gear` has no shape for a vessel"* survived the closure,
> because what closed was a decision to keep dropping vessels rather than a
> change to the schema.
>
> **The one that misreads:** `F14`'s `Taken, 2026-08-31 (PR #434)` note sits
> below an inline `**F10 excluded this on a premise that is false.**` — a bold
> lead that a block-splitting scan mistakes for the start of a new finding,
> hiding the note behind it. It has produced a false "open" once. Read to the
> next `###`, not to the next bold line.
>
> **`F18` here is not `F18` anywhere else.** Six other menus in this repo carry
> one — `CLASS-AUDIT`, `INGESTION-AUDIT`, `REBUILD-AUDIT`, `HEALTH-AUDIT`,
> `SKILL-AUDIT` and `UI-AUDIT` — so cite a finding in this file by filename, and
> expect a tree-wide grep for a bare number to return mostly other menus'
> history. `F18`'s own note records how that was found.
>
> **This header no longer enumerates, and should not again.** Corrected
> 2026-09-03: the closed range it used to carry was wrong twice over — never
> extended when `F18` landed on 2026-09-02, and sweeping up `F3`, which had not
> then been fully taken. It also carried a re-verification date more recent
> than both errors, which is the part worth noticing: a count in a header is
> re-checked by hand or not at all, and the hand is what keeps missing.

Findings menu for the seven-book ingestion batch registered in
`BOOK-INGEST-QUEUE.md`. **This file holds code changes only.** Data — classes,
skills, spells, psionics, gear, `scripts/books.json` entries, class markdown —
ships with its own book, as it always has; nothing waits here for that.

A finding lands here when a book needs a mechanic the app cannot express, or
when the ingestion loop turns up a defect in the tooling rather than in the
data. The rule for the batch is: **import what the schema supports, record what
was dropped in the row's `extraction_notes`, file the gap here, keep going.**
Do not stop to implement.

Protocol is the usual one — see the `audit-menu` skill. Numbered `F1..Fn`,
`###` headings, one PR per finding, taken only when Nate names one, dated
outcome note appended under the finding in the same PR, merged on a separate
word. A finding is **audited when it is taken**: verify its premises against
current code before scoping, and lead with the corrections.

**One menu for the whole batch, not one per book.** The same missing mechanic
will turn up in more than one of these seven; add the new book's rows to the
existing finding rather than opening a second number for it.

## Findings

### F1 — A numeric column is never checked against the page it cites

`source-coverage.mjs` answers *is the cited page one this machine holds*. It
says so itself: **traceable means checkable, not correct.** Nothing anywhere
asks the next question — *is this number printed on that page* — for any
numeric or free-text column, and the columns that most need it are exactly the
ones no test touches:

| column | checked by | what has gone wrong |
|---|---|---|
| `imported_classes` `starting_money` | nothing | two wrong figures shipped in the ju batch (PR #280) |
| `skills.note` | nothing | the ju/RUE Gambling variance recorded on the wrong skill, with the wrong number (fixed 2026-08-28) |
| `gear.cost` / `gear.mdc` | nothing | none found, but 42 ju rows were only confirmed by an ad-hoc script written for this session and then thrown away |

The ad-hoc script is the point. Verifying the ju gear took ~30 lines: parse the
`p.N-M` suffix off `source_book`, apply the book's offset, and ask whether the
stored number appears in the cached text, in bare and comma-grouped form. It
found 3 of 42 rows "missing", and all three were prices the book states in words
(*"3.6 million credits"*) — a **7% false-positive rate on a first attempt**,
which is the reason this has to be advisory rather than a gate.

**Proposal:** add a `--values` pass to `scripts/source-coverage.mjs` that, for
every row whose `source_book` carries a page range, tests each numeric column's
value for presence in the cited pages of the cache, in bare and comma-grouped
form, and reports the misses as a named list. **Posture: advisory, log-only, no
new exit code and no gate** — a miss is a row worth reading by eye, never a
failure. The false-positive rate above is why; a book that prices in words would
fail a gate on every such row. Report the miss rate alongside the misses so the
number stays visible.

Worth deciding when taken, not before: whether the same pass covers
`skills.base` / `per_level`, where a bare `30` appears on almost any page and
the check would be nearly all noise. The gear columns are the ones with the
signal.

**Taken, 2026-08-31 (PR #420). Posture held: advisory, log-only, exit code
untouched.** `--values` on `scripts/source-coverage.mjs`, gear numerics only,
with `skills.base` / `per_level` left out on this finding's own advice.

**Two premises were wrong, and the table above is where.** It says
`imported_classes.starting_money` is *checked by nothing*. It has been checked
since `class-check --field-sources`, which traces that field and
`equipment_starting` back to the cache lines they were drawn from and prints
the next page when a span ends near a page break - built for the very PR #280
failure this table cites as the thing nothing catches. What is true, and is
the finding's real content, is narrower: that check runs on ONE DRAFT at
import time and there has never been a sweep over rows that already shipped,
and the gear numerics have had no check of any kind. `starting_money` is
therefore NOT in this pass - it is a dice expression rather than a number, and
it already has a better check than this one would be.

**And the 7% false-positive rate does not survive contact with the corpus.**
It came from a 42-row sample. Over 1,154 gear values the first run missed
23.7%, and the reason matters more than the number: **160 of the 274 misses
are values printed one page either side of the window the row cites**, on
entries that straddle a page break. The NG-101 Rail Gun cites `rue p.273`, its
Black Market Cost is printed on 274, and the citation is simply a page short.
That is a fixable defect in the ROW, and it is a different thing from the 114
values that are near neither page.

So every miss is classified `late` / `early` / `absent` - an addition beyond
the written scope, declared here rather than made quietly. The window is
deliberately NOT widened to absorb the off-by-one hits, because absorbing them
would hide the short citations, which are the actionable half. A third
spelling was added for the same reason: this repo's OCR renders `18,000` as
`18.000` with 93-97 confidence, so bare and comma-grouped alone would have
reported a scanned book's prices missing in bulk.

**One bug in this pass was caught by the data and is worth recording**, because
it is the shape a value check fails in. The first boundary rule excluded a `.`
or `,` on either side of a hit outright, to stop `18000` matching inside
`118,000`. It also stopped `12` matching `(A.R. 12,` - where the comma is
punctuation and the value is right there. That single rule produced most of an
apparent miss rate on `gear.ar`, which is **0%** once a separator is only a
boundary BETWEEN DIGITS. A value check that is slightly wrong reports other
people's rows as broken, which is the expensive direction.

Twelve smoke checks drive the new lib functions off a fixture, including both
directions of that boundary rule and the words-not-numerals false positive
this cannot see past.

**What it found on the day it shipped, for whoever picks this up:** 114 gear
values near neither page and 160 short citations. Neither is repaired here -
this finding asked for a check, and repairing rows is its own work.

**Closed.**

### F2 — `skills.base` cannot hold a percentage derived from an attribute

`phase-world` printed 150 defines **Zero Gravity Movement & Combat** with a base
of *P.P. number x5%*, plus 4% per level. The per-level half fits; the base does
not. `skills.base` is `INTEGER NOT NULL DEFAULT 0` and every consumer treats it
as a fixed starting percentage, so there is nowhere to put a formula and no
runtime that would evaluate one.

This is the FIRST skill in the catalog whose base is attribute-derived, so
nothing here is a regression — the shape has simply never come up. Worth stating
because a `0` in that column already means something else: the schema comment
says *0 = non-percentile (W.P.s, hand to hand)*, and 336 rows rely on that
reading. Storing this skill at 0 makes it indistinguishable from a W.P.

**What the import did instead:** the row is imported with `base` 0 and the
formula written into `note`, and the class entries that grant it carry the same
sentence in `extraction_notes`. That is visible on the skill's own detail and
invisible everywhere a number is expected — the character sheet will show a
starting 0% for a skill the book starts at 40-50% for a typical P.P.

**Proposal, and it is deliberately the smaller of the two available.** Add a
`base_formula TEXT` column beside `base`, holding an attribute token and a
multiplier (`PP*5`), read by whatever derives a skill percentage. `base` keeps
its meaning for every existing row and stays the fallback when `base_formula`
is NULL. The alternative — making `base` a TEXT expression — touches every
consumer of a column 336 rows use and is not worth it for one row.

Two things to settle when this is taken, not before:

- **Where the evaluation lives.** `derive.js` turns class bonuses into numbers
  and already has the character's attributes; a skill's base is currently
  resolved in the catalog layer, which does not. Those are different places and
  the cheaper one may be the wrong one.
- **Whether one row justifies a column.** It is one row today. Palladium prints
  attribute-derived skills elsewhere (`Mutants in Orbit` is named on printed 151
  as the source of more space skills), so the honest answer is *probably more
  later*, not *definitely*. A second occurrence is a better trigger than this
  finding is.

**Taken, 2026-08-31 (PR #427), as proposed.** `skills.base_formula` holds an
attribute token and a multiplier - `PP*5` - consulted only when set, so `base`
keeps its meaning and stays the fallback for all 344 rows without one.

**The two questions this finding left open, settled.**

*Where the evaluation lives:* in the wizard, and it turns out there is only one
place it COULD live. The server never validates a skill percentage and
`leveling.js` advances from the STORED `pct`, so a skill's base is resolved
exactly once - at character creation, in `app.js`, where the attributes already
are. The pure half is `js/skill-base.js` so the smoke test can drive it off a
fixture; nothing server-side needed changing at all.

*Whether one row justifies a column:* on the evidence, yes, and for a reason
sharper than under-storage. Storing it at 0 was not merely lossy, it was
AMBIGUOUS - the schema comment defines `base` 0 as *non-percentile (W.P.s, hand
to hand)*, so a skill the book starts near 50% was indistinguishable from a
weapon proficiency. That is a wrong statement, not a missing one.

**One premise drifted:** the finding says *336 rows rely on that reading*. The
catalog is 345 skills now and **64** of them sit at base 0; every one of those
was checked and is a genuine non-percentile skill or is marked `Special`. This
is still the only attribute-derived base in the catalog.

**THE PICKER WAS A SECOND DISPLAY SITE AND THE TESTS COULD NOT SEE IT.** With
`resolveSkill` fixed, the class-skills row rendered correctly and the
related/secondary picker still read the raw `base`, so it showed an em dash -
telling a player that a skill they may take, and which the sheet then scores at
60%, has no percentage at all. Found in the browser, not by 1373 checks.

Verified end to end on a Cosmo-Knight, which grants this skill: at P.P. 12 the
class row reads 70% (60 derived, plus the class's printed +10%) and both picker
rows read 60%; at P.P. 18 it is 100%, at P.P. 3 it is 25%.

The grammar is one shape - `ATTR*N` - which is what was proposed and all one row
needs. A formula that does NOT parse falls back to `base` silently, which is
F8's shape, so the smoke test sweeps every `base_formula` any data script writes
and fails if one would not parse.

Five places per the `schema-change` skill: migration 042, the `CREATE`, a
guarded seed line, the `docs/operations.md` row, and the README data model. Plus
the catalogs `SELECT`, without which the column exists and never reaches the
app. Migration applied `--remote` and confirmed by asking
`schema_migrations`, then the data script.

Smoke 1364 -> 1373, regression 212 unchanged.

**Closed.**

**Reopened as a new finding, 2026-09-01. See F18.** The settled answer to *where
the evaluation lives* holds for the two DISPLAY sites this note found and misses
a third site that WRITES the number: `resolvePicks` in
`_lib/skill-picks.js` sets a spent pick's `pct` from the stored `base` alone, so
a skill gained after creation is stored at 0 and stays there. Nothing about the
column, the grammar, the fallback or the five places is affected - F18 is one
`SELECT` and one call, on a path this note did not look at.

**F18 was taken 2026-09-02 and that write path now resolves through
`skillBase()`**, so the paragraph above describes what was true between
2026-09-01 and then. This note's own measurements stand: the column, the grammar,
the fallback and the five places were never affected.

### F3 — `gear` has no shape for a vessel, and this batch has 25 of them

`phase-world` prints 6 power armor and robots (130-142), 5 tanks and IFVs
(143-149) and 14 starships and shuttles (157-173). The `gear` table holds
`damage`, `is_mega_damage`, `range`, `payload`, `rate_of_fire`, `ar`, `sdc`,
`mdc`, `weight_lbs` and `cost` — enough for a rifle, and not enough for any of
these.

What a vessel stat block here carries that has nowhere to go:

| the book prints | gear column |
|---|---|
| M.D.C. **by location** — main body, engines, turrets, sensors, a dozen entries with their own destruction rules | one `mdc` integer |
| crew complement, and passenger capacity separately | none |
| speed in three regimes: ground, atmospheric Mach, and FTL in light years per hour | none |
| a numbered list of 5-8 weapon systems, each with its own damage, rate of fire, range and payload | one of each |
| variable force fields with a per-facing allocation (156) | none |

Storing one of these as a `gear` row means picking one weapon system out of
eight and dropping the rest, which is worse than not storing it: the row would
read as complete.

**This is not new with this book** and that is the argument for numbering it
here rather than treating it as a Phase World problem. The catalog already holds
power armor and robot vehicles as `gear` rows with `category = 'vehicle'`, and
they carry the same loss silently — `mdc` on a Glitter Boy is the main body and
its arms and legs are gone. Phase World is the first book where the dropped half
is most of the entry.

**Proposal:** nothing, yet. The options are a `vehicles` table (nine places, per
`schema-change`), a JSON `systems` column on `gear`, or continuing to drop it and
saying so. All three are defensible and the decision is about what the app wants
to *do* with a starship, which nothing has asked for. **What this finding is for
is the record**: when a vessel row looks thin, this is why, and it was a choice.

Until then the batch imports **no** vessels from this book, and the survey says
so in its extraction plan.

**A second occurrence, 2026-08-30 — it now costs a player their starting kit.**
The Noro Mystic Warrior (printed 64-65) is issued *a suit of psionic power
armor* as standard equipment. That suit is printed on 128-130 as a power armor
stat block, so it is excluded here, and the class ships without the one item its
own book says it starts with. Everything else on its list is imported.

That is a different cost from the one this finding opened with. Leaving a
starship out of the catalog means a GM cannot look one up; leaving this out means
a **character sheet is wrong** the moment it is generated. It does not change the
proposal - a `gear` row that keeps one weapon out of eight would be worse - but
it moves the question from "what can the catalog hold" to "what does a class
need to be complete", and the second is a stronger reason to answer it.

Worth knowing when this is taken: the noro power armour is the *only* vessel in
this book that any class is issued. The rest are bought.

**Partly taken, 2026-08-31 (PR #431) - the character-completeness half only.
THE SCHEMA QUESTION IS STILL OPEN.** Asked and answered directly: import the one
suit now, defer the schema. No migration, no new column, no new table; one data
script.

The `Psionic Power Armor` is a `gear` row and the Noro Mystic Warrior is issued
it. Every figure was read off a **200 dpi render of printed 129 and 130**, not
from the OCR - the folio on that render reads 129, which also re-confirms this
book's zero page offset. The **Mark V** is stored: the book prints two marks,
the class's equipment line names neither, and the Mark X adds contragravity
flight, weighs twice as much and costs eight million credits rather than four.

**What the measurement changed about the question.** F3 opened as "a GM cannot
look one up". Measured against production before the change:

| | |
|---|---|
| `gear` rows with `category = 'vehicle'` | **35** |
| ...already carrying a full per-location M.D.C. breakdown in `description` prose | **23** |
| ...cramming more than one weapon system into `damage` | **4** |
| classes noting a vessel they did not import | **4** |
| ...of which are the GM's option rather than issued | **4** |
| classes ISSUED a vessel and shipping without it | **1** |

So the structure F3 says `gear` cannot hold is **already in the database**, as
prose nothing can read, in two thirds of the vehicle rows. The choice was never
"store it or drop it" - it is whether anything should be able to READ it. And
the only live defect was one character sheet: the Galactic Tracer, Space Pirate,
Runner and Naruni Repo-Bot vessels are all *"the GM can let the character
own..."*, checked one by one rather than assumed.

**This row makes exactly the compromise the other 35 make**, deliberately -
`mdc` is the MAIN BODY (210) alone, the six locations are in `description`, and
all six weapon systems are in `damage` as prose, with `range` holding the speed
and `payload` the power system, which is what those columns already mean for a
vehicle here. It is consistent with the catalog rather than a new shape, and it
is still lossy. A row that read as complete would be worse, which is F3's own
argument and is why the description says so in the row itself.

**Still not imported, and still the open question**: the 25 vessels this book
prints that no class is issued, and the four conditional spaceships. The three
options F3 lists are unchanged - a `vehicles` table (nine places), a JSON
`systems` column on `gear` (five, plus the `catalogs.js` SELECT), or continuing
to drop them. Worth recording for whoever takes it: **a JSON column nothing
reads is the silent-storage failure `class-import` warns about**, so that option
wants a reader in the same PR, and the 23 rows whose breakdown is already sitting
in prose are the backfill it would start from.

Regression 228, with the clean-run gear count moved 1024 -> 1025 - the check
that pins it is what caught the row landing.

**The schema half is now CLOSED, 2026-09-03 (PR #616), as the third option:
keep dropping, and say so where a reader will find it.** No `vehicles` table, no
JSON `systems` column, no migration, no data touched. `F3` is fully closed.

**The decision was made on the measurement this finding asked for, and the
measurement has not moved in a month.** `F3` says the choice *"is about what the
app wants to do with a starship, which nothing has asked for."* Re-checked
against production:

| | 2026-08-31 | 2026-09-03 |
|---|---|---|
| `gear` rows with `category = 'vehicle'` | 35 | **36** |
| ...carrying a per-location breakdown in `description` | 23 | **24** |
| ...cramming more than one weapon system into `damage` | 4 | **4** |
| tables or columns anywhere naming a vehicle, vessel or ship | — | **0**, across 40 tables |

The `+1` on the first two rows is the `Psionic Power Armor` this finding's own
first half imported. **Nothing has asked**, which is the whole basis for
declining the other two options — and this finding's own note supplies the
argument against the cheaper of them: *a JSON column nothing reads is the
silent-storage failure `class-import` warns about*. A nine-place table for a
feature nobody has requested is worse than that, not better.

**"Say so" was the part actually missing, and it is what shipped.** `F3` has said
since 2026-08-28 that a thin vessel row is a choice, and that sentence has lived
only inside a 2,400-line audit menu. A reader who opens `gear` and sees `mdc:
170` on a power armour has no way to reach it. The standing limitation is now in
`docs/known-limitations.md` beside the other gear entries, with the numbers, the
reason both schema options were declined, and the trigger for revisiting.

**This is the reversible option and it was chosen partly for that.** Nothing is
foreclosed: the 24 rows whose breakdown already sits in prose are the backfill a
future `vehicles` table would start from, and that is written down where the
next person will be standing. **Reopen it the moment something asks** — a sheet
that renders a vessel, a GM lookup, a class that grants one beyond the Noro.


**Reopened and taken, 2026-09-07 (PR #787) - as the FIRST option, which the
2026-09-03 closure declined.** The closure above stands exactly as written and
nothing in it is edited: it was true when it was made, it is the record of what
was decided and why, and an audit file is a record.

**What asked.** The closure named the trigger itself - *"Reopen it the moment
something asks - a sheet that renders a vessel, a GM lookup, a class that grants
one beyond the Noro."* On 2026-09-07 Nate asked for the Triax vessels to be
imported, having just closed the rest of that book. That is the ask.

**What was built: `vehicles`, `vehicle_locations` and `vehicle_weapons`,**
migration `048-vehicles.sql`, all nine places per the `schema-change` skill.
Three tables rather than one, because the two things this finding says a vessel
carries are exactly the two that cannot live in a column: **M.D.C. by location**
is one row per named part, and the **numbered weapon systems** are one row each.
Folding either back into a single column is the loss this finding refused -
*"picking one weapon system out of eight and dropping the rest... the row would
read as complete."*

**The JSON option stays declined**, on this finding's own argument: a JSON column
nothing reads is the silent-storage failure `class-import` warns about. Nothing
about reopening the first option revives the second.

**THIS IS A SCHEMA CHANGE FROM A BOOK SESSION, WHICH THE BATCH PROTOCOL FORBIDS.**
`book-survey` §8 is explicit - *"NO application code, schema, validator or
generator changes from a book. Import what the schema supports, record what was
dropped, file the gap, keep going."* That rule was put to Nate as the cost of
this option before anything was written, and he took it anyway. Recorded here
because a rule broken on someone's word and a rule broken by accident look
identical six months later, and only one of them should.

**What this does NOT do, and each is deliberate:**

- **It does not touch `gear`.** The 36 rows carrying `category = 'vehicle'` stay
  where they are, per-location breakdowns in prose and all. This finding's own
  closure calls those 24 prose rows *"the backfill a future `vehicles` table
  would start from"*, and backfilling them is its own job with its own
  decisions - chiefly what happens to the class equipment lists that reference
  those gear slugs.
- **Nothing in the app reads the three tables.** No `catalogs.js` SELECT, no
  `catalog-fields.js` entry, no sheet rendering. This is the shape; the reader
  comes when something needs to render one.
- **No data yet.** The Triax vessels are a separate PR, and the measurement that
  matters for whoever writes it is in the survey: ~53 vessels across printed
  39-140 and 205-209, roughly 107 of this book's 222 printed pages.

**The measurement this finding rested on has now moved, and that is worth
recording plainly.** The closure declined both schema options on the grounds that
*"nothing has asked"*, with a table showing zero tables or columns anywhere
naming a vehicle, vessel or ship across 40 tables. As of this PR there are three,
and the count of tables in the shared database goes 33 to 36. Anyone re-running
that measurement will get a different answer than the closure did, and the reason
is this note rather than a drift.

**The data landed, 2026-09-07 (PR #791), and it is the half PR #787 said was
still to come.** That note ends *"No data yet. The Triax vessels are a
separate PR"*; this is it. **55 vessels, 601 M.D.C.-by-location rows and 259
weapon systems**, from printed 39-140 and 205-209 - 8 power armour, 12 robots,
7 drones, 9 borgs and 19 vehicles. Applied `--remote` before the PR, and every
readback counts rather than trusting the exit code, because `INSERT OR IGNORE`
is silent on collision.

**The survey's estimate of ~53 was close and low.** 55 is what four readers
found by the rule that a vessel belongs to the slice its NAME HEADING falls
in - which is what kept the X-2000 Dyna-Max (heading p.70, weapons running to
p.73) and the VX-370 Stopper (heading p.105, weapons on p.106) whole and
unduplicated across a boundary.

**The shape held: nothing needed to change to store any of it.** No column was
added, no CHECK was relaxed, and the two places the schema deliberately left
loose are both used - `mdc` is NULL on 6 location rows whose M.D.C. the book
prints as DICE rather than a number (the EIR-50 Gurgoyle Android is built to
match whatever gurgoyle it imitates), and `vehicle_class` is free text, which
absorbed the book's own categories without argument.

**AND NOTHING READS THEM STILL.** The bullet above saying so is unchanged by
this PR: there is no `catalogs.js` SELECT, no `catalog-fields.js` entry and no
sheet rendering, so 55 correct, page-cited vessels are in production and
invisible in the app. That is the honest state, it was not smuggled in with
the data, and the reader is still its own piece of work.

**Correction, 2026-09-07: the rule this finding says it broke did not say what
the note quotes, and the rule itself has since changed.** The PR #787 note above
stands as written and is not edited; both halves of this correction are about
the sentence it attributes to another file.

**First, the quote is a splice.** It reads *"`book-survey` §8 is explicit -
\"NO application code, schema, validator or generator changes from a book\""*.
<!-- claim-ok: quoting the premise this note corrects -->
Read 2026-09-07, §8 contained none of the words *application*, *validator* or
*generator*; its rule was *"Do not stop to implement"* and *"only CODE waits"*,
which is a sequencing rule rather than a ban. The banning sentence was in
`BOOK-INGEST-QUEUE.md` and `docs/prompts/BOOK-INGEST-PROMPT.md`. So the note
cited the strictest wording to the one file that did not carry it — the shape
`audit-menu` calls *a claim about another file*, and `scripts/menu-check.mjs`
could not catch it because its patterns fire on absence claims, not on a
positive misquote.

**Second, the ban is gone as of 2026-09-07.** `book-survey` §8 now sets three
tiers, and this PR falls in the second: a change Nate asks for is in scope the
moment he asks. Under the rule as it now reads, **PR #787 broke nothing** — the
banner above it is a correct record of what the session believed and a wrong
description of what the protocol required. It is left standing because it is
what prompted the measurement that replaced the rule.

### F4 — The language-pick invariant matches on prose, and missed one of three

`regression.mjs` holds a good rule: an "any language" pick must offer the
repeatable `Language: Other` row, never a whole category. It exists because the
defect it guards was reported as seven classes and was **thirty-two** - seven
offered the too-wide Technical category and twenty-five offered Communications,
which does not contain `Language: Other` at all, so those classes could not
grant a single ordinary language.

**It finds the class by reading the note.**

```js
const ABOUT_LANGUAGES = /^Language: Other,|languages? of choice|additional [Ll]anguages/;
```

The `phase-world` CCW batch wrote three of these groups and the check caught
**two**. The CAF Fleet Officer and the CAF Scientist transcribe the book as
*two languages of choice* and *four languages of choice*, which match. The CAF
Trooper transcribes printed 57 as written - **Language: any two** - which
matches nothing, and its identical defect passed 210 checks.

It was found by reading the failure message for the other two and going back to
look, not by the check. That is the same shape as the original bug: **the
invariant is stated over every class and then narrowed by a regex over free
text.**

**Proposal:** decide the group by SHAPE rather than by prose. A group with
`categories` naming Technical or Communications and no `from` is either a
language pick or a rare deliberate category pick, and there are few enough of
the latter to name. Alternatively keep the prose match and add a second,
independent check: **any `occ_skills` choice group whose `categories` include
Technical and whose note mentions a language at all** - which is a weaker
pattern but fails in the safe direction, because the answer is "go and look" and
not "rewrite the class".

Worth settling when taken: whether the same hole exists in the LITERACY family
below it, which uses a different regex over the same free text and has the same
structural weakness. It was not tested against this book - none of these four
classes writes a literacy pick as a choice group.

Not urgent, and stated plainly: **the rule is right and its aim is off.** No
class ships wrong because of this one; the trooper was corrected by hand in the
same PR that found it.

**Taken, 2026-08-31 (PR #421) - as the ALTERNATIVE, because the primary
proposal was measured against the corpus and does not work.**

The primary was to decide the group by SHAPE: `categories` naming Technical or
Communications with no `from`, on the reasoning that the deliberate category
picks are *few enough of the latter to name*. Run over every published class it
finds **nine** groups and **not one is a language pick** - four Lore picks (the
catalog files lore under Technical), two science-or-technical picks, and three
general skill choices. Naming those nine would rebuild the id list this
invariant was written to replace, and it would go stale the same way.

So the finding's own stated alternative went in instead: a SECOND detector that
shares no regex with the first. Any `occ_skills` choice group offered through a
CATEGORY whose note mentions a language at all. Measured both widths - restricted
to Technical/Communications as proposed, and left open to any category - and both
are at **zero** hits, so the wider one is used: it cannot miss and costs nothing.

**The gap is LIVE, which this finding does not quite say.** It reports that no
class ships wrong, and that is still true. What it does not say is that the CAF
Trooper - corrected by hand and correct today - is **still invisible to the prose
detector**, because its note begins *Language: any two* and matches none of the
three alternatives. Nothing would have noticed if that group were regressed to a
category. It is covered now.

**Widening `ABOUT_LANGUAGES` would have broken a correct class**, which is the
argument for a second check rather than a bigger regex, and is worth recording
because widening is the obvious move. Adding `^Language: ` pulls in the CAF
Trooper's OTHER group - a pick of one specific Trade Tongue from three named
rows - which correctly offers no `Language: Other` and would then fail the
assertion that every language pick offers the repeatable row.

**The literacy family has the same hole and got the same check.** F4 left that
open (*worth settling when taken*); it reads the same free text with a different
regex and is equally narrowable. Also at zero.

Proved to FIRE rather than merely pass: the detector was run against the CAF
Trooper's shape as it originally shipped and against the 25-class Communications
defect - it fires on both - and against the corrected Trooper, a Lore pick and a
fixed skill, where it stays silent. A check that has never been shown to fail is
not evidence of anything.

Regression 210 -> 212.

**Closed.**

### F5 - `attribute_dice` cannot say an attribute does not exist, and the app fills one in

The Machine People R.C.C. (Phase World, printed 78) prints its attribute line as
**"I.Q. 2D6+10, M.E. 2D6+10, M.A. 2D6+10, P.S. 6D6, P.P. 5D6, P.E. N/A,
P.B. 2D6+12, Spd. 6D6"**. A machine person is a living machine with no
constitution to model, so the book does not give it a P.E. at all.

There is no way to write that. `attribute_dice` is a map of dice strings, and
`app.js` resolves a missing one as

```js
return rollAttribute(S.cls?.attribute_dice?.[attr] || '3d6');
```

so a class that states nothing and a class that states **N/A** produce the same
character: one with a rolled P.E. of about ten. The import omits the key, which
is the honest choice of the two available - writing a number would assert one -
but the sheet still shows a P.E. the book denies, and the value feeds save vs
coma/death like any other.

**This is a display and a derivation problem at once**, and the second half is
what makes it more than cosmetic. P.E. is read wherever a save vs coma/death or
an S.D.C. figure is computed. A machine person is an M.D.C. being that is
impervious to toxins, drugs and radiation, so most of those paths are moot for
*this* race - which is exactly why it will not be noticed until a book states
N/A for an attribute that is not moot.

**Proposal:** accept the literal string `"N/A"` as a value in `attribute_dice`,
meaning *this creature has no such attribute*, and have `rollAttribute` return
null for it rather than falling through to `3d6`. The sheet then shows a dash
where the number would be, the wizard's re-roll button for that attribute is
suppressed, and `attribute_requirements` on an O.C.C. naming that attribute
fails closed - a machine person cannot take a class that requires a P.E., which
is the right answer and the one nobody would get by hand.

Cheaper alternative if that is too wide: leave the roll alone and add the
absence to the parser as a warning, so at least the import is told. That fixes
nothing and is not recommended; it is here because it is one line.

**Second occurrence, 2026-08-31: the Pleasurer R.C.C., printed 89**, whose
attribute line reads "P.B. N/A". A pleasurer wears whatever face its client
wants, so beauty is not a number it has, and the import omits the key for the
same reason the Machine People's P.E. is omitted. This one is closer to the
case the paragraph above predicted than the Machine People was: P.B. is not
moot for a shapeshifting entertainer whose whole trade is appearance, and the
sheet shows it a rolled ten or so.

Two classes in this book need it now, which is still why this is filed rather
than built. It is the first attribute-shaped hole to turn up, and it is the same
shape as F2 - a column that holds one kind of value being asked to hold the
statement *there is no value*.

**Taken, 2026-08-31 (PR #423), as proposed.** `attribute_dice` accepts the
literal `N/A`, `rollAttribute` returns null for it, and both classes now say so.

**THREE OF THE FOUR OUTCOMES THIS FINDING ASKS FOR ALREADY WORKED**, and that is
the correction to lead with. It reads as four changes; it is one. `sheet.js`
already renders a dash for a null attribute (`attrs[a] == null ? '-'`), and
`validate-character.js` already raises an `attribute_missing` VIOLATION when a
required attribute is not a finite number - so the fail-closed behaviour the
finding describes as a thing to build was waiting for an input it never got.
The only missing piece was the mechanism to PRODUCE the null. Everything else
was downstream of `rollAttribute` falling back to 3d6.

**One consequence the finding does not mention, and it would have broken the
wizard.** `renderAttributes` blocks the Next button on `S.attrs[a] == null` for
any of the eight. Returning null without touching that would have made every
affected race UNCREATABLE - permanently stuck on step 3 with no control to
satisfy. So `missing` now skips an absent attribute while `unmet` still counts
it, which is precisely the split the finding wants: creatable, and still barred
from an occupation that requires the attribute. `rollAll` and `setAllMethod`
skip it too, or Point-buy would have handed a machine person the base
constitution its book denies.

**Verified in the browser, not only in the tests**, because the failure mode was
a dead wizard rather than a wrong number. Walked to the attribute step as a
Machine People on a local dev server: the P.E. row renders
`PE - Machine People has no PE` with no method select and no roll button, the
other seven roll normally, `S.attrs` carries no P.E. at all, and Next is
ENABLED. Injecting an occupation requiring `PE: 12` disables Next with
*Class minimum not met: PE 12+*.

`fix-absent-attributes-na.sql` adds the key to both classes and corrects both
`extraction_notes`, each of which asserted the limitation as current - true when
written, false as of this PR. That is the THIRD note of this shape in this book.
Existing characters are not rewritten: attributes are rolled once and stored, so
this changes what new characters get. Applied `--remote` before the PR.

The grammar is deliberately narrow - `N/A` and `n/a`, nothing else. `NA`,
`none` and `0` are all still errors under F8's check, because each of them
means something different and only one of the three is this.

Smoke 1349 -> 1353, regression 212 unchanged.

**Closed.**

### F6 - `occ_related_skills` cannot express a per-category MINIMUM

Two classes in this book - the Imperial Security Agent (printed 83) and the
Freedom Fighter (printed 84) - print the same rule:

> O.C.C. Related Skills: Select 8 other skills, **but at least two must be
> selected from espionage and two from rogue skills.**

`occ_related_skills` carries one open `count` over every category it lists. It
can say *how many* picks and *which categories are legal*, and it can narrow a
category with `only` / `except`. It cannot say **at least N of them must come
from this category.** Both classes therefore offer all eight picks freely, and a
player can build an Imperial Security Agent with no espionage and no rogue
skills at all - which is the one thing its own book forbids.

**This is the mirror of the starting-powers problem** already solved on the
psionic side. `powers_starting_groups` exists exactly because
`powers_starting: 8` over four categories let a player take eight Super powers
where the book granted two (CLASS-AUDIT.md S1 and S9). This is the same defect
in the skill column, and it is a floor rather than a ceiling - which is the
harder half, because a ceiling can be modelled by splitting the count and a
floor cannot.

**Why the obvious workaround is wrong.** Four of the eight picks could be moved
into `occ_skills` as `{ choose: 2, categories: ["Espionage"] }` and
`{ choose: 2, categories: ["Rogue"] }`. That enforces the floor and then
silently takes four picks out of the eight the book calls free - the character
ends with four related picks plus four constrained ones, which is a different
class. Both classes state the rule in a note instead and the player honours it.

**Proposal:** `occ_related_skills.minimums`, a list beside `count`:

```yaml
occ_related_skills:
  count: 8
  minimums:
    - { count: 2, category: "Espionage" }
    - { count: 2, category: "Rogue" }
```

The picks still come out of the same eight; the validator refuses a set that
does not meet each floor, and the wizard shows *"Espionage 0/2 minimum"* beside
the running total the way it already shows the count. Touches the parser, the
server-side validator and the skills step of the wizard - the three places a
pick is counted - and nothing else, because it constrains an existing list
rather than adding one.

Cheaper alternative: leave it advisory and have the wizard *warn* rather than
refuse. That is worth less than it looks, since the note already warns and
nobody reads a note at the moment of the pick.

**Not urgent.** Two classes in this book, and both ship with the rule written
where a GM will see it. Filed because it is the second time a book has stated a
per-category quota and the second column that could not hold one, and because
the psionic answer is already in the tree to copy.

**Taken, 2026-08-31 (PR #428).** Implemented as proposed - `occ_related_skills.
minimums`, a list beside `count`, validated in the parser, refused by the server
validator, shown by the wizard's skills step - and applied `--remote` before the
merge. Posture as written: the picks still come out of the same `count`, the
floors are not new picks, and nothing was moved into `occ_skills`.

**THE SCOPE WAS WRONG, AND WRONG IN THE DIRECTION THAT MADE THE FINDING LOOK
SMALLER THAN IT IS.** F6 says two classes in this book and calls it the second
occurrence. It is the **eleventh**, across three books:

| class | book, printed | picks | floor |
|---|---|---|---|
| Cyber-Knight | Rifts Ultimate 67 | 12 | 2 Physical + 3 W.P.s |
| City Rat | Rifts Ultimate 88 | 10 | 3 Physical **or** Rogue |
| Cyber-Doc | Rifts Ultimate 90 | 9 | 2 Technical |
| Operator | Rifts Ultimate 92 | 8 | 2 Mechanical |
| Rogue Scholar | Rifts Ultimate 94 | 11 | 4 Technical |
| Gambler | Juicer Uprising 59 | 10 | 2 Rogue |
| Juicer Wannabe | Juicer Uprising 61 | 8 | 2 Rogue + 2 Physical |
| Galactic Tracer | Phase World 40 | 7 | 2 Espionage |
| CAF Scientist | Phase World 60 | 12 | 4 Science |
| Imperial Security Agent | Phase World 83 | 8 | 2 Espionage + 2 Rogue |
| Freedom Fighter | Phase World 84 | 8 | 2 Espionage + 2 Rogue |

Three of those are in the very book this finding was written from, not two. All
eleven were read off their own printed page in the block belonging to that
class, rather than grepped: four of these pages carry two class blocks, and a
page-wide search returns the neighbour - the first match on Phase World printed
82 is the Imperial Legionnaire, which has no floor at all.

**One class had lost the rule entirely.** Ten recorded it in prose for a human
to honour. The **Cyber-Knight** did not - no related-skills note, no GM note, no
extraction note - so its floor existed nowhere in this repo, and no search for
the rule could have found it. It turned up only in the last sweep, which went
through every cached book page for the printed sentence and intersected that
with the catalog. Its note is written here for the first time. The lesson
generalises past this finding: **a corpus sweep for a missing rule has to run
over the SOURCE, not over the records, because a record that dropped the rule is
indistinguishable from one that never had it.**

**The proposal's entry shape could not express one of the eleven.** F6 proposes
`{ count: 2, category: "Espionage" }`. The City Rat's floor is a UNION - "at
least three must be selected from Physical or Rogue skills" - satisfied by three
Physical, three Rogue, or any mix of three. As two separate floors it would
demand six picks the book never asks for. An entry therefore holds a LIST,
`categories`, and `category:` is kept as the one-element spelling so the
proposal's own syntax works verbatim. Additive, not a substitution.

**A FLOOR IS NOT A CEILING, AND THE DIFFERENCE DECIDES WHEN IT CAN FIRE.** F6
says the validator "refuses a set that does not meet each floor". Implemented
literally that refuses every HALF-BUILT character: the existing count rule fires
on `>` the allowance, so a player with picks still to spend is legal, and a
floor not yet met is that same player. What is refused is a set that can NO
LONGER reach a floor. The shortfalls are summed against what remains rather than
tested one at a time - six of eight spent on an Imperial Security Agent holding
one espionage and no rogue leaves each floor individually reachable, and the two
together needing three picks where two remain.

**The floor is counted over every related pick, which is weaker than the book
and deliberately so.** Each of these classes says "at least two of the EIGHT"
and then grants more picks on a schedule. A stored skill row records no level -
the same reason choice groups are advisory here - so the first eight cannot be
told from the two granted at level three. The weaker reading never refuses a
character the book allows, which is the side to err on when the alternative is
refusing a save.

**Six notes claimed the app could not hold the rule, and three said it again in
their GM Notes and extraction_notes.** All nine are rewritten to state what is
true now without quoting what they replace - the F12 pattern, in the same PR
that made them false.

**A regression invariant, not a count.** `every class whose note states a
per-category floor also holds one` reads the floor phrase off the live corpus
and asserts nothing states one it does not hold. A count of eleven would pass
forever while the next book imported the twelfth as prose, which is exactly how
these sat. Two more check that no floor names a category its class does not
grant - which would refuse every character of that class - and that no class
floors more picks than it grants.

**Four more books print a floor for a class this catalog does not hold**:
Underseas printed 98, Spirit West printed 39, Free Quebec printed 40, and Triax
printed 160 - the last being the next book in the queue. Nothing to fix;
recorded so the next import knows the key exists.

### F7 - the save list is sixteen fixed fields, and a book bonus outside them vanishes

The Spacer O.C.C. (Phase World, printed 38) has exactly one bonus, and it is
this:

> The spacers' experience in dealing with the vacuum of space gives them a
> **+2 bonus to any saves against explosive decompression or other space
> dangers.**

`sheet.js` renders saves from `SAVE_FIELDS`, a literal list of sixteen:
spell magic, ritual magic, psionics, toxins/poisons, harmful drugs, insanity,
possession, horror factor, coma/death, pain, illusionary magic, mind control,
curses, faerie magic, disease, fatigue. `derive.js` computes the same sixteen
from the attribute charts. There is no environmental, vacuum or decompression
save anywhere in either.

**The parser accepts a key the sheet will never draw.** `validateBonuses()`
warns on an unrecognised *group*, not on an unrecognised key inside `saves` -
which is correct and deliberate, because that is what lets `mind_control`,
`possession`, `curses` and the rest work without a schema change. The cost is
that `saves: { space_hazards: 2 }` parses cleanly, stores cleanly, validates
cleanly, and then renders nowhere. A class would look complete and grant
nothing.

**And the obvious workaround is worse.** The first draft of this class wrote
`saves: { toxins_poisons: 2 }`, on the reasoning that it is the nearest label a
GM would reach for. That is a real, rendered +2 against venom that the book
never granted, applied every time the character is poisoned. It was caught by
reading `SAVE_FIELDS`, not by any check. **A near-miss mapping is worse than an
absent one**, and the same temptation exists for every environmental rule a book
states: radiation, pressure, heat, cold, drowning.

**Proposal:** add an `other` sub-map under `bonuses.saves`, keyed by free text:

```yaml
bonuses:
  saves:
    other:
      - { label: "vs explosive decompression and other space dangers", bonus: 2 }
```

`derive.js` would pass them through untouched (there is no attribute chart to
combine them with, which is the point - a book-stated flat bonus needs none),
and the sheet would render them as extra rows after the sixteen, labelled in
the book's own words and rollable like any other save. No new derived field, no
new chart, no guess about which existing save it resembles.

Cheaper alternative: extend `SAVE_FIELDS` with the handful of environmental
saves the Palladium line actually uses. That is a smaller change and it fails
the next time a book invents one, which is the failure mode this finding is
about.

**Not urgent, and honest as it stands** - the Spacer's bonus is in its
`extraction_notes` and its GM Notes, so a table can apply it. Filed because it
is the first class in this import whose ENTIRE mechanical grant is unstorable,
and because the near-miss it invites is the kind of error nothing downstream can
catch.

**Taken, 2026-08-31 (PR #426), as proposed.** `bonuses.saves.other` is a list of
`{ label, bonus, note }`, rendered on the sheet after the sixteen and rollable in
play mode, labelled in the book's own words.

**Every premise held.** `validateBonusGroup` key-checks only `attributes`, so an
unknown key inside `saves` still parses and renders nowhere - which is exactly
what keeps `mind_control` working without a schema change, and exactly what made
`space_hazards: 2` silent. Both halves confirmed by reading the code.

**A label is required, and that is the whole design.** An unlabelled entry is
indistinguishable from the unrendered key it replaces, so it is an ERROR rather
than a warning. So is a non-list, a missing bonus and a blank label.

**THREE THINGS THE PROPOSAL DOES NOT MENTION, EACH FOUND BY BUILDING IT.**

1. **Composition had to be taught the shape.** `mergeBonusBlock` sums a group's
   keys, and summing two LISTS is nonsense. `saves.other` is concatenated
   instead, like `at_level`: a race granting +3 vs radiation and an occupation
   granting +2 vs vacuum grant BOTH.
2. **`derive.classBonuses` folded it in as a zero.** A list reads as an unrolled
   dice bonus there, so `other: 0` appeared in the numeric saves map beside
   `horror_factor`. Harmless arithmetic and wrong furniture; it is skipped
   explicitly now.
3. **The sheet row is READ-ONLY, deliberately.** `editField` needs a storage key
   to write into and these are identified by free text, and there is nothing to
   override - no chart contributed, so the printed number IS the value. It is
   rollable in play mode, which is where a save is used.

**Verified in the browser** on a real Spacer character: the row renders after the
sixteen as *vs explosive decompression and other space dangers +2*, and play mode
rolls it - `d20 11 + 2 = 13`, logged under the book's wording.

`fix-labelled-saves.sql` stores two bonuses that were prose: the Spacer's +2
(which had no `bonuses:` key at all, because there was nothing it could legally
hold) and the Cosmo-Knight's +4 vs bio-wizard microbes and parasites, the half of
its printed +4 that had no field. The Cosmo-Knight's `saves:` changes from an
inline flow map to a block one so a list can hang off it; NO VALUE CHANGES. The
Colonist's note is corrected in the same script - it cited the Spacer's save as
an example of one with no field at all. Applied `--remote` before the PR.

**The Vacuum Wasp cites F7 and is deliberately NOT covered.** Its case is
`dogfighting`, a COMBAT field, and this proposal says `saves`. The same escape
hatch under `bonuses.combat` is the obvious follow-up and is not taken here,
because widening a taken finding's scope silently is how a menu stops meaning
anything. Its note stays true and needed no edit.

Smoke 1357 -> 1364, regression 212 unchanged.

**Closed.**

### F8 - a FIXED attribute value in `attribute_dice` is silently replaced by 3d6

The Naruni Repo-Bot (Phase World, printed 46) prints **"Robot attributes: The
robot has a P.S. of 50, P.P. 26"**. Those are not dice. They are the chassis'
figures, the same for every Repo-Bot ever built, and `attribute_dice` looks
like the field for them.

It is not, and the failure is silent. `rollAttribute` in `js/dice.js` matches
one grammar:

```js
const DICE_EXPR = /^(\d+)\s*d\s*(\d+)(?:\s*x\s*(\d+))?(?:\s*([+-])\s*(\d+))?$/i;
...
if (!m) return rollAttribute('3d6');
```

A bare integer does not match, so it falls through to the human default.
Measured this session:

```
rollAttribute("50") -> total 9,  notation "3d6"
rollAttribute("26") -> total 8,  notation "3d6"
```

**The notation is rewritten too**, which is what makes this worse than F5. The
class stores `"50"`, the wizard's re-roll button reads `(3d6)`, and nothing
anywhere reports that a value was discarded. F5 is a class that cannot say
*there is no attribute*; this is a class that says *the attribute is 50* and is
not heard.

**One published class already carries it.** A sweep of all 148 published
classes on 2026-08-31 - every `attribute_dice` value in every markdown row,
tested against `DICE_EXPR` - found exactly one that does not parse:

| class | attribute | stored | rolls |
|---|---|---|---|
| `holy-terror` | P.S. | `"50"` | 3d6, about 10 |

The Holy Terror is a Wormwood R.C.C. with 2D4x100+200 M.D.C. whose whole
character is supernatural strength, and it has had an ordinary human's P.S.
since it was imported. Nothing failed: `class-check` reports it `ready`, the
parser accepts it, the smoke test passes.

**Proposal:** accept a bare integer in `attribute_dice` as a fixed value.
`evalDiceWith` already walks one grammar for both the roll and its bounds, so
the change is one alternative in `DICE_EXPR` plus returning the number
unchanged - and the notation then reports `50` rather than lying. `class-check`
should reject anything that parses as neither, which is the half that would
have caught the Holy Terror.

Cheaper alternative: make `class-check` warn on an `attribute_dice` value that
does not match `DICE_EXPR`. That fixes no character but ends the silence, and
it is the smaller change of the two.

The Repo-Bot import does **not** write `PS: "50"`, for this reason, and puts
both figures in a natural ability instead - an absent value that reads as
absent beats a stored one that reads as effective, which is F7's rule in the
other direction. It also could not have stored the P.P. even if this were
fixed: the book heads that stat block **"Bonuses (Includes P.P. bonuses)"**, so
the printed +8 to strike, parry and dodge already contains it, and `derive.js`
would have added its own `pp_combat` bonus on top.

**Taken, 2026-08-31 (PR #422), both halves.** A bare integer in
`attribute_dice` is now a FIXED value: returned unchanged, reporting its own
notation, earning no exceptional die, and acting as its own ceiling. And
`class-check` now REJECTS an `attribute_dice` value parsing as neither grammar
- the half this finding says would have caught the Holy Terror.

**Every premise held**, which is unusual here and worth saying plainly. The
measured `rollAttribute("50") -> 9, notation "3d6"` was reproduced before the
change. The sweep still finds **exactly one** published class carrying a fixed
value, now across 160 rather than 148: `holy-terror.PS`.

**Structure differs from the sketch, behaviour does not.** F8 proposed *one
alternative in `DICE_EXPR`*. That alternation would shift every capture-group
index in three functions to express a thing with no dice, no multiplier and no
modifier, so it is a second constant and an early return in each. Widening the
shared grammar was audited rather than assumed: `evalDice` and `diceBounds` are
only ever fed `perLevelDiceOf` output, which is dice-shaped; `poolBaseWith`
already resolved bare numbers to the same value by a later branch; and no
equipment quantity is a bare numeric string. `DICE_RE`, which finds dice inside
prose, is deliberately untouched.

**A THIRD GAIN THIS FINDING DOES NOT MENTION.** `attributeCeiling("50")`
returned `null`, and the server-side `attribute_above_ceiling` check skips a
null ceiling - so the one class already carrying a fixed attribute was exempt
from the gate as well as mis-rolled. It now has a ceiling like every other
class.

**The Holy Terror is repaired by the code change alone**, with no data script:
its `PS: "50"` was always stored and is now read. New characters roll 50 where
they rolled about ten; existing ones keep the attributes stored at creation,
so nothing is rewritten under anyone.

**One data script, and it is a note rather than a number.**
`fix-repo-bot-fixed-attribute-note.sql` corrects the Repo-Bot's
`extraction_notes`, which described this limitation as current and measured -
true the day it was written, false the moment this shipped. That is the exact
failure this book has already hit twice. It deliberately does NOT add
`PS: "50"` to the Repo-Bot: the app could hold it now, but changing a published
class's attributes changes the characters made from it, and that is a decision
rather than a consequence of fixing the mechanism. The note says so. The P.P.
stays out for the unrelated double-counting reason above, which is untouched.
Applied `--remote` before the PR.

Smoke 1342 -> 1349, regression 212 unchanged. Zero of the 160 published classes
trip the new error.

**Addendum, 2026-08-31 (PR #425) - this finding shipped with a second stale note
it did not correct.** TWO published classes cite F8, not one. The Repo-Bot was
corrected above; the PHANTOM was missed. Its note explains that storing `"0"`
for the energy form's P.S. would have been worse than the compromise it chose,
because `rollAttribute` would discard it - which stopped being true the moment
this finding merged. `fix-phantom-fixed-attribute-note.sql` corrects it. The
DECISION stands and no attribute value moves: the shell's 4D6 is still stored,
for the reason that there is one field per attribute rather than the reason that
a zero could not be. Filed as F12, which is what a hand sweep for citers keeps
missing.

**Closed.**

### F9 - a cross-category `only` pick silently loses the percentage printed beside it

Two classes in the Star Hives chapter - the Vacuum Wasp (printed 93) and the
Termite Engineer (printed 94) - print the same related-skill line:

  Rogue: Prowl only (+5%)

The catalog files Prowl under **Physical**, not Rogue. `categoryAllows` in
`js/parser.js` handles that half correctly and deliberately: a cross-category
`only` is admitted as long as the class also lists the skill's real category,
which both of these do. The skill is reachable and the grant works.

The percentage does not survive the trip. `categoryBonus`, ten lines above it,
looks the bonus up by the skill's **real** category:

```js
const entry = categories.find((c) => normName(categoryName(c)) === normName(skill?.category));
```

so a Prowl taken by a vacuum wasp resolves against the class's *Physical* entry,
which carries no bonus, and the +5% the book printed beside Rogue is dropped.
The player is still shown the label `Rogue (Prowl only; +5%)`, because
`categoryLabel` reads the entry the book wrote rather than the catalog's
filing - so the wizard promises a bonus the sheet does not give.

**That keying is deliberate and its reason is sound.** The comment above
`categoryBonus` names the case it exists for: the Glitter Boy's "Espionage:
Wilderness Survival only", where handing a Wilderness skill an Espionage bonus
would invent one the book never printed. The gap is that the rule cannot tell
the two apart - a cross-category line with **no** printed percentage, where
inheriting one would be wrong, from a cross-category line **with** one, where
dropping it is wrong.

**How many rows this touches: three, swept rather than estimated.** Parsing
every published class against `SELECT name, category FROM skills` on
2026-08-31 found exactly three category entries that carry both an `only`
naming a skill the catalog files elsewhere and a non-zero `bonus`:

| class | entry | names | catalog files it under |
|---|---|---|---|
| `phaeton-juicer` | Espionage (+5%) | Wilderness Survival | Wilderness |
| `vacuum-wasp` | Rogue (+5%) | Prowl | Physical |
| `termite-engineer` | Rogue (+5%) | Prowl | Physical |

The first predates this book, so this is not a Phase World problem that arrived
with Phase World; it is one this book made visible.

**Proposal:** score a pick against the entry that ADMITTED it. When a skill is
admitted by a cross-category `only`, use that entry's bonus; otherwise keep the
present behaviour. That is the same "the more specific statement wins" rule
`categoryAllows` already applies one function away, and it leaves the Glitter
Boy alone - its Espionage entry names Wilderness Survival with no percentage,
so there is nothing to inherit.

Cheaper alternative: have `class-check`'s existing `cross-category` report say
when the entry carries a bonus, so the import at least knows the number is
being dropped. It fixes no character, and it would have turned this up in batch
6 rather than batch 8.

**Taken, 2026-08-31 (PR #424), the main proposal - with ONE GUARD THE PROPOSAL
DOES NOT STATE, and without it three classes would have lost a bonus they
already had.**

The wording is *use that entry's bonus*. Implemented literally that zeroes any
pick whose admitting entry carries NO percentage - and the sweep says that is
the common case, not the rare one. Eighteen picks across the catalog are
admitted by a cross-category `only`; only **three** name a percentage. Of the
other fifteen, three sit on a real category that pays: the Glitter Boy's
Wilderness at +2%, the Combat Cyborg's Military at +10%, the CAF Trooper's
Wilderness at +5%. So the admitting entry wins ONLY where it states a figure,
which is what the finding's own sentence about the Glitter Boy - *nothing to
inherit* - assumes without saying.

**The three-row sweep is confirmed exactly**, re-run against 160 published
classes rather than the 148 of the day: `phaeton-juicer` Wilderness Survival,
`vacuum-wasp` Prowl, `termite-engineer` Prowl. All three go 0% -> 5%. The other
fifteen are byte-identical before and after, verified by running the real
`categoryBonus` over every one.

**And the cheaper alternative was taken as well, because it costs one line now
that the behaviour has changed.** `class-check`'s `cross-category` report said
only that these work; it now says a printed percentage is applied too, so the
next import is not left to infer it from this file.

`fix-cross-category-bonus-notes.sql` corrects the Vacuum Wasp's and the Termite
Engineer's `extraction_notes`, both of which stated the +5% does not land -
true when written, false as of this PR. That is the FOURTH note of this shape
corrected in this book. The Phaeton Juicer carries no such note and needed no
edit. NO NUMBER MOVES IN THAT SCRIPT: `bonus: 5` was always stored on the Rogue
entry and the parser simply never read it, so the data script is prose only.
Applied `--remote` before the PR.

Smoke 1353 -> 1357, regression 212 unchanged.

**Closed.**

### F10 - an R.C.C. and an O.C.C. that are BOTH psychic keep only one block, and the race wins every tie

`combineClasses` in `js/parser.js` folds a race and an occupation into one
class. Every other field is merged - skills are unioned, bonuses are summed,
equipment and abilities are concatenated. `psionics` is not merged. It is
CHOSEN:

```js
// The stronger psychic wins: a dragon that is already a Major psychic does
// not become weaker by studying an O.C.C. with minor psionics.
if (rcc.psionics || occ.psionics) {
  out.psionics = tierRank(occ.psionics?.type) > tierRank(rcc.psionics?.type)
    ? occ.psionics : (rcc.psionics || occ.psionics);
}
```

The comparison is **strictly greater**, so a tie goes to the RACE, and the
occupation's entire block is discarded - its granted powers, its
`powers_starting`, its `powers_starting_groups`, its `categories_allowed`, its
whole `powers_schedule`, and its `isp_base`.

**The premise is sound and the implementation is one operator away from it.**
"A dragon that is already a Major psychic does not become weaker" is exactly
right for the TIER. It is wrong for everything else in the block: a race states
what a member of that race is born with, and an O.C.C. states what training
adds. Nothing about the noro being a major psychic means a noro psychic should
not learn the twelve powers its own page grants. The two are not competing
claims about one number; they are two different sentences, and the code treats
them as rival answers to one question.

**Measured, not reasoned about.** Parsing all 154 published classes plus this
batch's four through the real parser and calling the real `combineClasses` on
every race/occupation pair where BOTH state psionics:

| | |
|---|---|
| R.C.C.s with a psionics block | 19 |
| O.C.C.s with a psionics block | 19 |
| pairs where both state psionics | 361 |
| pairs where the O.C.C.'s block is discarded AND it had picks to lose | **93** |
| distinct O.C.C.s that lose their block to at least one race | **17** |

The worst are the ones a book would actually pair:

| O.C.C. | tier | loses its block to |
|---|---|---|
| `crazy` | minor | 17 of 19 races |
| `cyber-knight`, `mystic`, `noro-psychic`, `noro-mystic-warrior` | major | 10 of 19 races each |
| eleven more, `phase-mystic` and `promethean-phase-adept` among them | master | 3 of 19 races each |

**Two classes have already shipped broken, and their own book is what pairs
them.** `noro` + `noro-psychic` are both `major`, so composing them keeps the
race's five granted powers and throws away the O.C.C.'s twelve, its two
starting picks and all fifteen schedule entries - including the level-2 Super
power and the "any category from third level" widening that
`fix-noro-psionic-schedules.sql` was written in #411 to get right. The same is
true of `noro` + `noro-mystic-warrior`, which loses four starting groups and
eight picks. Both went in with #409 and neither has ever composed correctly.

**This batch adds a third, and the tier is not the cause.** The First Stage
Promethean is "Considered a master psionic" (printed 26) and the Promethean
Phase Adept is a first stage promethean who grants a super-psionic power, so it
is a master too. Master is the TOP of the ladder, so lowering the O.C.C.'s tier
could not rescue it: the race holds the maximum and the comparison is strict.
The Phase Adept's six phase powers, its super-psionic pick and its
twenty-eight schedule entries are dropped in the only pairing the book allows.
The Promethean Time Master is untouched because it states no psionics at all,
and the Phase Mystic is untouched because the five races its book permits -
human, draconid, wolfen, seljuk, noro - are three with no psionics block and
one major; the only three races that would displace it are the catalog's other
two masters and the promethean, and none of them may be a phase mystic.

**Proposal:** merge the block instead of choosing it. Take the higher `type`
and the higher `isp_base` - that is the sentence the comment defends - and
UNION the rest: concatenate `powers`, and take the O.C.C.'s
`powers_starting` / `powers_starting_groups` / `powers_schedule` /
`powers_per_level` / `categories_allowed` where it states them, falling back to
the race's. Training adds to birth; it does not replace it.

The awkward case is a race and an O.C.C. that both state `powers_starting`,
where adding them may over-grant. The books this catalog holds do not do that
often, and where they do the O.C.C.'s number is the one written for a character
who also has the race - so preferring the O.C.C.'s single count while unioning
the granted lists is the conservative reading. `spells` has the same shape one
line below (`out.magic = occ.magic || rcc.magic`) and the same question; it is
not part of this finding because no race/O.C.C. pair in the catalog states both.

**Cheaper alternative:** make `class-check` warn when a class's `psionics`
block would be discarded by composition with any race it can be taken with. It
fixes no character, but it would have caught the noro in batch 2 instead of
batch 9.

**Taken, 2026-08-31 (PR #429).** `mergePsionics` replaces the choice. Powers and
`categories_allowed` are unioned, the tier is the stronger of the two with
`isp_base` travelling with it, and the ladders (`powers_schedule`,
`powers_starting_groups`) take the occupation's where it states one. Code only -
no data script, no migration, no class edited.

**The numbers moved, all in the direction that makes the finding bigger.**
Re-measured against production the day it was taken:

| | filed | now |
|---|---|---|
| pairs losing a block with content | 93 | **113** |
| distinct O.C.C.s losing their block | 17 | **19** |

Nineteen of nineteen, which is to say **every occupation with a psionics block
lost it to at least one race**. The finding's list of worst cases also misses
`techno-wizard`, which ties `crazy` at 17 of 19.

**TWO OF THE PROPOSAL'S THREE RULES WOULD HAVE MADE CHARACTERS WORSE, and both
contradict the finding's own sentence - *training adds to birth; it does not
replace it*.**

- **`categories_allowed`** is listed among the fields to take from the
  occupation. Taking it there **narrows in 110 of the 204 pairs** that state it
  on both sides: a psychic dragon hatchling who becomes a Crazy would lose
  Healing, Physical and Sensitive - three categories its own race page grants
  it. Unioned instead.
- **`powers_starting`** is listed the same way, with the argument that the
  occupation's number is written for a character who also has the race. True of
  a specialisation like the noro psychic; false of an occupation a strong
  psychic race merely takes. **165 pairs state a count on both sides and in 89
  of them - the majority - the occupation's is LOWER.** A psychic dragon
  hatchling would have dropped from eight starting powers to one for studying as
  a Dog Boy. The higher of the two never weakens anyone and never exceeds what a
  book states alone, which adding them would.

**"The higher `isp_base`" is not computable where the merge happens.**
Composition runs before attributes are rolled, and 7 of the 33 I.S.P. formulas
in the catalog lead with the M.E. term - `poolFormulaBounds` returns null for
every one of those without an attribute to substitute, and reads several of the
rest as their leading dice alone. So the formula travels with the tier, and a
TIE goes to the occupation. That is the right answer in all three ties the
catalog has: 3d6x10 against the noro's 1d4x10, 4d6x10 against it, and the phase
adept's 1d4x100 against the promethean's M.E. x5.

**A SECOND SITE THE FINDING DOES NOT MENTION.** `applyAbilities` folds an
ability's psionics block with the same strictly-greater operator, and its
comment claims it is *"the same rule composing a race with an occupation uses"* -
which fixing only `combineClasses` would have made false. It is not
hypothetical: the **Godling** is a minor psychic whose *Super-Psionic Powers*
ability grants `{ type: master }` and nothing else, so choosing the ability's
block outright replaced the class's I.S.P. formula with none at all. Fixed in
the same function.

**The `magic` premise is wrong, and it is an absence claim.** F10 says `spells`
is excluded because *"no race/O.C.C. pair in the catalog states both"*. Thirteen
R.C.C.s and eighteen O.C.C.s state `magic`: **234 pairs**, every one of which
discards the race's block. Filed as **F14** rather than folded in here, because
the scope agreed to was psionics.

**Verified end to end**, not only in tests. A Noro + Noro Psychic built in the
wizard shows *"Psionic powers - 0/2 (major psychic - Healing, Sensitive,
Physical)"* where the race alone offers none of that, thirteen granted powers
where the race grants five, and an I.S.P. pool of **78 at M.E. 18** - outside
the 28-58 the race's own formula can reach, so the pool is demonstrably rolled
from the occupation's.

Smoke 1398 -> 1414. Regression 215 -> 221, the six new checks composing all 361
live pairs and asserting no power, category, count or tier comes out below what
either half states alone - an invariant, so the next psychic class imported is
covered without anyone remembering to add it.

**Also found while measuring, and filed as F15:** the **Crazy** allows
`["Psychic Sensitive", "Physical Psychic"]`, and neither is a category the
catalog has. Its three starting psionic picks have no legal pool at all.

### F11 - a class whose book says it REPLACES the race cannot say so, and `combineClasses` gives the race precedence in four places at once

The Cosmo-Knight O.C.C. (Phase World, printed 100-102) is a transformation, not
a trade. The Cosmic Forge rebuilds the body: the entry prints its own attribute
dice, its own M.D.C., its own P.P.E., and an O.C.C. Skills line whose first
sentence is that when the character is transformed the skills of his past life
are lost and the character is reborn. The attribute line is stronger still - it
says to use these die rolls OR the attributes of the character's original race,
**whichever are HIGHER**.

`combineClasses` in `js/parser.js` cannot express any of that. Its policy is
fixed and race-primary:

```js
for (const key of ['attribute_dice', 'hit_points_base', 'sdc_base', 'mdc_base', 'ppe_base',
                   'starting_money', 'xp_table']) {
  if (rcc[key] == null && occ[key] != null) out[key] = occ[key];
}
```

The occupation's value is used **only when the race states none**. There is no
comparison, so a take-the-higher rule is unrepresentable; and the skills a few
lines below are UNIONED, so a replace rule is unrepresentable too.

**Measured, not reasoned about.** All 158 published classes parsed through the
real parser, and the real `combineClasses` called on this class against every
one of the 57 published R.C.C.s, 2026-08-31:

| | |
|---|---|
| races the Cosmo-Knight's `attribute_dice` survives | **3** of 57 |
| races its `mdc_base` is discarded on | **36** of 57 |
| races its `ppe_base` is discarded on | **50** of 57 |
| races that carry named skills through the transformation | **37** of 57, between 1 and 19 skills each |
| races where all four compose correctly | **1** of 57 |

The three races the dice survive on - `chiang-ku-dragon`,
`warrior-of-valhalla`, `murder-wraith` - survive by ACCIDENT: they are the only
published races that state no `attribute_dice` at all, so nothing was compared
there either. The one race that composes correctly in all four places,
`warrior-of-valhalla`, does so by stating nothing in any of them.

A concrete pair, printed by the same run:

```
kreeghor + cosmo-knight
  attribute_dice.PS = "3d6+10"     the kreeghor's. The cosmo-knight prints 3d6+32
  mdc_base          = "2d6x10+20, plus 3d6 per level of experience"
  ppe_base          = "3d6+6"      the cosmo-knight prints 1d6x100
```

A kreeghor cosmo-knight comes out with roughly half the printed strength, a
seventh of the printed M.D.C. and a fiftieth of the printed P.P.E., on a class
whose whole character is going toe to toe with a starship.

**This is F10's mechanism on four more fields.** F10 is `combineClasses`
CHOOSING a `psionics` block where it should merge; this is `combineClasses`
choosing a race's pools and dice where the book says compare, and unioning
skills where the book says replace. Three fixed policies, one function, and the
books have now disagreed with all three. It is NOT F5 or F8, which are about
what a single `attribute_dice` cell may CONTAIN; this is about what happens to
two cells that both exist.

**The import stores the class's own figures anyway**, which is the least-wrong
of the two available answers rather than a good one: a character created with no
race at all then gets the printed values, and omitting them would produce a flat
3d6 and no pools in every case instead of in 54 of 57.

**Proposal:** let a class declare that it supersedes the race, and make
`combineClasses` honour it. One key on the O.C.C. -
`supersedes_race: true`, or a narrower `race_composition: replace | higher` if
the two rules want separating - which changes the loop above from *race wins
unless absent* to *this class's value wins*, and makes the skills merge drop the
race's `occ_skills` rather than union them. The attribute half wants the
comparison rather than the replacement, and the comparison is not free: a dice
expression has no single number to compare, so "whichever are HIGHER" has to
mean comparing the two expressions' means (or their maxima) at creation and
keeping the winner per attribute. `evalDiceWith` already walks the grammar with
each die pinned to its floor or ceiling, which is where the bound would come
from.

**Posture: opt-in, and no existing class changes behaviour.** Every class in
the catalog today wants the current policy - a dragon that studies an O.C.C. is
still a dragon - so the new key must default off and the 158 published rows must
compose exactly as they do now. This is a mechanism for the handful of entries
whose book says the character stops being what it was.

**Cheaper alternative:** make `class-check` warn when a class states an
`attribute_dice`, a pool base or an `occ_skills` list that composition would
discard for some race it can be taken with. It fixes no character and it is the
same shape as F10's cheaper alternative - but between them the two would cover
every field `combineClasses` decides, and it would have said something on the
day this class was imported rather than on the day someone rolls one.

**Taken, 2026-08-31 (PR #430).** Implemented as the finding's PRIMARY proposal:
`supersedes_race: true`, one opt-in flag on the O.C.C., read by
`combineClasses`. Pools, `starting_money` and `xp_table` become the
occupation's; `occ_skills` replace the race's rather than unioning;
`attribute_dice` are compared per attribute and the higher kept. Posture as
written - the flag defaults off, and an occupation without it composes exactly
as it did, which the regression asserts rather than assumes.

**The premises held.** Every number re-measured against production: dice survive
3 of 57, `mdc_base` discarded 36 of 57, `ppe_base` 50 of 57, all four right for
1 of 57, and the three surviving races are the three that state no dice at all.
The kreeghor example reproduces exactly. One small drift: the skills carried
through are **1 to 17** each, not 1 to 19. Both book sentences were read off
their own printed pages and are quoted correctly.

**After the flag: 57 of 57 compose correctly in all four places.** Thirty-two
races still keep at least one of their own attribute dice, which is the book's
carve-out doing its job - a dragon hatchling keeps I.Q. 5d6 and P.B. 6d6, and a
kreeghor keeps M.E. 2d6+12 over the class's 4d6+4 while losing P.S. 3d6+10 to
its 3d6+32.

**THE OBVIOUS COMPARATOR WAS WRONG, and it failed loudly enough to catch.**
F11 says the comparison could come from `evalDiceWith` walking the grammar with
each die pinned to a bound, and `attributeCeiling` is exactly that helper -
already handling an ABSENT attribute (F5) and a FIXED one (F8), so reusing it
looked like the disciplined choice. It adds the **exceptional-dice chain**,
which only a plain 2d6 or 3d6 earns: a bare `3d6` scores 18+12 against
`4d6+4`'s 28, so the WEAKER dice win. **41 of the 57 races beat this class's
printed M.E. that way.** The comparison is the MEAN of the dice bounds instead,
which is also stable where a ceiling is not - 1d20 and 3d6+2 share a ceiling of
20 and are not the same offer.

**THE FALLEN COSMO-KNIGHT DOES NOT GET THE FLAG, deliberately.** Its
composition is broken identically - 3 of 57, 36 of 57, 49 of 57, 1 of 57 - and
F11 does not name it. More than that, it needs a *different rule*: printed 103
states its attributes as "use the cosmo-knight attributes, but reduce them as
follows", so a fallen knight whose original race had the higher P.S. should
carry that race's number **reduced by the printed 22**, where this flag would
hand it the race's number untouched. Setting it would trade one wrong answer for
another. It wants a rule this key cannot express.

**One gap remains, and it is step order rather than composition.** The wizard
rolls attributes at step 3 and asks for the occupation at step 4, so a character
built straight through rolls the RACE's dice; the merged ones appear only on
going back to Attributes, where they are now labelled *"transformed dice"*
rather than *"racial dice"* - a phrase this change made false. The precedent for
closing it is `trimRelatedToAllowance`, which handles the same out-of-order
problem for a rolled major psionic and tells the player what it did. Not folded
in here because silently re-rolling attributes when an occupation is picked
would be worse than the gap.

**Verified in the wizard**, not only in tests. A Kreeghor Cosmo-Knight shows
P.S. 3d6+32 against the race's 3d6+10, M.E. 2d6+12 where the race is higher, and
a P.P.E. pool of **200** - impossible for the kreeghor's own 3d6+6, which tops
out at 24.

Smoke 1414 -> 1428. Regression 221 -> 228, the new checks composing every
flagged class against all 57 races and asserting no pool, skill or attribute
comes out below what the class prints alone - plus one that an occupation
WITHOUT the flag still loses its pools to the race, which is the posture.

**The `class-check` warning in the cheaper alternative was not built**, and it
is still worth having: it would cover the fields this flag does not, and would
have said something on the day the class was imported.

### F12 - a class note that records the app's limits ages badly, and nothing sweeps the citers

An `extraction_notes` entry does two jobs at once. One is permanent - **what the
book prints and what was stored**. The other is perishable - **what the app could
do on the day of the import**. They sit in the same paragraph, so the perishable
half rots inside a record that otherwise stays true, and nothing marks the seam.

**Five occurrences, four of them corrected by hand and one missed.**

| class | asserted | falsified by |
|---|---|---|
| both noro O.C.C.s | the sheet has no mind-control save | `fix-noro-mind-control-saves.sql` |
| `apok` | `bonuses.attributes` takes flat numbers only | the Godling's +1D4 initiative |
| `naruni-repo-bot` | a fixed attribute falls back to 3d6 | F8 (PR #422) |
| `vacuum-wasp`, `termite-engineer` | the cross-category +5% does not land | F9 (PR #424) |
| `machine-people`, `pleasurer` | there is no way to say an attribute is absent | F5 (PR #423) |
| `phantom` | storing `"0"` would be worse than a compromise | F8 - **and it was missed for three PRs** |

The Phantom is the argument. F8 corrected one of its two citers, both tests
passed, and the false claim reached production and stayed there. It was found
only by counting citations while writing this finding - not by any check, and not
by the person who had just done the same correction by hand three times.

**The exposure is knowable and small.** Sixteen of 160 published classes carry at
least one `BOOK-INGEST-AUDIT.md FN` citation, across nine findings: F2 (5), F3
(5), F7 (4), F5/F8/F9/F10/F11 (2 each), F6 (1). Six findings on this menu are
still open, so this will recur about six more times unless something changes.

**Proposal, in three parts, and the third is deliberately weak.**

1. **Convention.** A class note records the DECISION and cites the finding; the
   finding owns the mechanism. *"Not stored; see F8"* never goes stale.
   *"`rollAttribute` parses only NdM forms"* always will. Where the mechanism
   must be in the class, write it past-tense and dated - which is the doctrine
   this repo already applies to audit files (*do not rewrite a measurement*),
   extended to class prose.
2. **Protocol.** Taking a finding already requires an outcome note in the same
   PR. Add: *and correct every class note that cites it.* One line in the
   `audit-menu` skill, and it is the step that was skipped.
3. **Tooling: a cross-reference, NOT a status oracle.** A flag that lists which
   classes cite which finding, so step 2 is a command rather than a memory.
   **It must parse no outcome notes.** The `audit-menu` skill forbids a check
   that decides whether a finding was taken, because a mechanical reader of
   those notes has been wrong five times; this one answers only *who mentions
   F8* and leaves *is F8 still true* to the person taking it.

**Posture: convention and protocol first, tooling last and advisory.** Parts 1
and 2 are documentation and cost nothing. Part 3 should be a listing with no
exit code of its own - a gate here would fire on every class citing an open
finding, which is the correct and useless answer.

**Not urgent, and it repairs nothing already shipped** - the five occurrences
above are all corrected as of PR #425. What it buys is that the sixth is found
by a command rather than by someone noticing.

**Taken, 2026-08-31 (PR #432), all three parts, postures as written.** Part 1
convention and part 2 protocol are documentation; part 3 is
`scripts/audit-citations.mjs`, a listing with **no exit code and no
outcome-note parsing**.

**"IT REPAIRS NOTHING ALREADY SHIPPED" WAS TRUE WHEN FILED AND FALSE BY THE TIME
IT WAS TAKEN.** Three new stale citations appeared while this sat on the menu,
all from PRs merged the same day, all mine:

| class | cites | asserted | falsified by |
|---|---|---|---|
| `first-stage-promethean` | F10 | the Phase Adept's block "are discarded" | F10, PR #429 |
| `promethean-phase-adept` | F10 | its powers and schedule "are dropped" | F10, PR #429 |
| `fallen-cosmo-knight` | F11 | the take-the-higher rule is "equally unstorable" | F11, PR #430 |

F12 predicted this would recur "about six more times unless something changes".
It recurred three times in one day, to the person who had just written the
finding, which is a better argument for part 2 than the finding makes. All three
are corrected in `fix-stale-finding-citations.sql`, applied `--remote`.

The third is the interesting one. It is not simply false - `supersedes_race`
exists now, and the Fallen deliberately does not carry it because printed 103
states a different rule. A note saying "unstorable" makes a considered omission
read as an oversight, so it now says which and why.

**The corpus is bigger than the finding recorded**: 20 of 160 classes cite a
finding, not 16, across nine findings - F2 (6), F3 (5), F6 (4), F7 (4), F5 (2),
F8 (2), F9 (2), F10 (2), F11 (2). The counts moved because five findings were
taken between the filing and the taking.

**The tool's own comments are the trap it exists to avoid.** It explains in
prose why it does not read an outcome note, quoting the words those notes use -
so a check scanning the whole file would fail on the comment that exists to
prevent the thing it checks for. The smoke check strips comments first and
tests EXECUTABLE lines only. This is INGESTION-AUDIT F14 exactly: the finding
that describes the outcome-note format carries the format inside backticks, and
every grep reports it taken when it is open.

**The signal-to-noise is the argument for the posture.** Run against production
it flagged **seven** passages carrying limitation language beside a citation:
three stale, four describing limits that are still real - all four being F3
citers, whose "`gear` has no shape for a vessel" remains true because F3's
schema half is still open. A gate would have failed on all seven. A listing
hands over seven paragraphs to re-read, which is thirty seconds.

Smoke 1428 -> 1434. The new checks pin the POSTURE rather than the output - the
output needs a live database and belongs to whoever is taking a finding.

### F13 - ten published classes carry a doubled apostrophe in their stored markdown

Found while taking F7, by a `replace()` that would not match. The Colonist's
note reads *unlike the Spacer''s decompression save* - two apostrophes, in the
markdown as stored, not as escaped for SQL. An escaping was applied twice
somewhere between the draft and the row.

**Ten published classes are affected**, counted against production on
2026-08-31: `imperial-security-agent`, `freedom-fighter`, `spacer`,
`galactic-tracer`, `space-pirate`, `runner`, `colonist` and three more. Every
one is a Phase World class, which narrows where to look.

It is cosmetic and it is real: the text is rendered to the reader as written, so
a class detail page shows `the Spacer''s` where the author wrote one apostrophe.
Nothing computes on it and no number is affected.

**It also makes a `fix-` script's guard fail in a way that reads as a missing
row.** That is how this was found: a correction matched nothing, and the obvious
conclusion - wrong class, wrong text, already applied - is wrong in a way that
costs a while to see. The Colonist's occurrence is repaired in passing by F7's
script, because that script had to match it to do its own job.

**Proposal:** find the double-escape first, then sweep. Do NOT start with a
blanket `replace(markdown, '''''''', '''''')` - a doubled apostrophe is legal
inside a class's prose if the author meant it, and more importantly a sweep that
does not know the cause will be needed again the next time an importer runs. The
generator to check is `class-check --emit-script`, which doubles apostrophes when
it splices markdown into the INSERT; the question is whether some path doubles
them twice, and whether the affected ten came through one importer.

**Posture: diagnose, then a one-off data script; no new gate.** A check that
rejects `''` in stored markdown would be wrong - it is legal text - and this is
a defect in one code path rather than a class of authoring error.

**Nine remain.** The Colonist's was repaired as a side effect of F7 and the
other nine are untouched.

**Taken, 2026-08-31 (PR #433), posture as written - diagnosed first, then a
one-off data script, and no new gate.**

**THE CAUSE, WHICH THE FINDING ASKS FOR BEFORE THE SWEEP. It is not the
generator.** `class-check --emit-script` has exactly one escaping site for
spliced markdown - `literal()` - and it doubles each apostrophe once, which is
correct. The proof is arithmetic rather than a reading: **all 157
`add-*-class.sql` files were emitted through it and exactly TEN contain
`''''`** - the same ten rows carrying `''` in production, with the counts
matching one for one. A generator that double-escaped would have done it to all
157.

So the **drafts arrived pre-escaped**: the apostrophes had already been doubled
for SQL in the `.md` before `--emit-script` doubled them again. All ten are
Phase World classes, which is the narrowing the finding predicted.

**"Nine remain" was wrong - ten did.** The Colonist still carried one of its
two; F7's script repaired the one it happened to need to match, not both. The
sweep took 36 occurrences across the ten.

**The blanket replace F13 warns against turned out to be the right instrument,
and only because it was checked first.** Every one of the 36 was printed and
read before anything ran, and every one is a possessive - *the catalog's*, *the
character's*, *the Galactic Tracer's* - or the plural possessive in *"1D6x1000
credits' worth of items"*, which the book writes with one apostrophe. None is
intentional. The statement is scoped to the ten ids rather than the table, so a
class that legitimately wants `''` later is untouched.

**No gate, one advisory.** A check rejecting `''` in stored markdown would be
wrong, as the finding says. What is added instead is a `class-check` WARNING
when a **draft** carries doubled apostrophes - the point where a pre-escaped
`.md` can still be fixed, and where the odds are strongly one way. It moves no
exit code. Verified both ways: it fires on `add-colonist-class.sql` naming the
two passages, and is silent on `add-cosmo-knight-class.sql`.

**The ten `add-*-class.sql` files are not edited** - they are one-shot scripts
that have already run. On a clean rebuild the glob applies them in sorted order
and `fix-` sorts after `add-`, so the sweep runs last and the rebuild converges.

Production now carries **zero** doubled apostrophes across all 160 classes,
which is the readback that would also catch a class outside the ten drifting the
same way. Smoke 1434 -> 1439.

### F14 - a race and an occupation that BOTH state magic keep only one block, and the occupation wins every time

The psionics half of this was F10. `combineClasses` folds a race and an
occupation into one class, and the line immediately after the psionics merge is:

```js
// Magic is what you studied, so the O.C.C. wins when both state it.
if (occ.magic || rcc.magic) out.magic = occ.magic || rcc.magic;
```

The race's entire `magic` block is discarded - its `spells`, its
`spells_starting`, its `spell_levels_allowed`, everything.

**F10 excluded this on a premise that is false.** It says *"`spells` has the
same shape one line below and the same question; it is not part of this finding
because no race/O.C.C. pair in the catalog states both."* Measured against
production on 2026-08-31, parsing all 160 published classes:

| | |
|---|---|
| R.C.C.s stating `magic` | **13** |
| O.C.C.s stating `magic` | **18** |
| pairs stating both | **234** |

The thirteen are `godling`, `entrancer`, `holy-terror`, `morphworm`, `rumbler`,
`shade`, `silhouette`, and the six dragon hatchling variants. Every one of them
loses its innate magic to any spellcasting occupation.

Note the asymmetry with F10 before the fix: psionics at least gave the RACE the
tie. Magic gives the occupation the win **unconditionally** - there is no
comparison at all - so a Godling who studies as a Ley Line Walker loses the
magic its own godhood grants, not merely a tie-break.

**The comment is a real argument and it is only half right.** Magic IS what you
studied, for a practitioner. It is not what an entrancer or a dragon has: those
books grant spell-like power as a property of the creature, the same way the
noro is born a major psychic. That is exactly the distinction F10 turned out to
be about.

**Proposal:** the same merge F10 built. Union `spells`, take the higher
`spells_starting`, take the wider `spell_levels_allowed`, and prefer the
occupation's for anything shaped like a ladder. `mergePsionics` in
`js/parser.js` is the worked example and the shapes are close enough that the
two could plausibly share a helper - though `magic.type` has no ordered ladder
the way `psionics.type` does, so there is no "stronger" to compute and the
occupation's type should simply win.

**The question that needs answering first**, and the reason this is not a
one-line change: what does a Godling who is also a Ley Line Walker actually
have? Two spell lists that merge cleanly, or two different magics that a sheet
has to show separately? F11 is about a class REPLACING its race, and if a
Godling's magic is meant to be replaced rather than added to, this finding is
partly answered by that one. Read them together.

**Taken, 2026-08-31 (PR #434).** `mergeMagic`, on F10's rules, sharing its union
helper. Every premise held on re-measurement: 13 R.C.C.s, 18 O.C.C.s, 234 pairs,
and the line was `out.magic = occ.magic || rcc.magic` with no comparison at all.

**The Godling question answers itself, and not the way the finding frames it.**
The Godling's block is `type: none` and nothing else - a placeholder for its
*Magic Powers* ability, which grants a practitioner class outright. Six of the
thirteen races are `(type only)` like that: the Godling and five of the six
dragon hatchlings. **Seven races actually lose content**, and the entrancer is
the sharp case - it loses eleven granted spells, six of its ten starting picks,
and three of its four allowed spell levels, to any spellcasting occupation.

**THE TYPE IS A KIND, NOT A DEGREE. That is the one real difference from F10**
and the finding is right about it. `psionics.type` is minor < major < master and
there is a stronger to compute; the magic types here are `spell`, `elemental`,
`druid`, `intuitive`, `none`, and two named after their class. They say HOW a
character casts. So the occupation's wins outright where it states one - a
race's generic `spell` must not overwrite a Warlock's `elemental`.

**Two rules had to be measured rather than assumed, and both came out the way
F10's did:**

| | pairs stating both | where preferring the occupation's is WORSE |
|---|---|---|
| `spells_starting` | 108 | **35** lower - a royal frilled hatchling would drop from 6 starting spells to 1 for studying as an Elemental Fusionist |
| `spell_levels_allowed` | 28 | **19** narrower - an entrancer who becomes a Warlock loses levels 2, 3 and 4 |

So counts take the higher and levels are unioned, which is what the finding
proposed. 28 pairs grant named spells on both sides and **9 overlap**, so the
dedupe is load-bearing rather than tidy.

**F11 turned out to be the other half of the answer.** A class carrying
`supersedes_race` takes its magic outright rather than merging - the same
exception it already makes for pools and skills. Unexercised today, because the
only class carrying the flag states no magic; written now so the rule is
coherent rather than discovered later as an inconsistency.

**Eleven keys, two more than psionics** - `spell_lists` and
`spells_starting_groups` appear once each - which is why the block is spread
before the rules are applied rather than enumerated.

The union helper is now shared by both merges. They ask the same question of
different columns, and the pair written twice is the pair that drifts.

Smoke 1439 -> 1448. Regression 228 -> 233, composing all 234 live pairs and
asserting no spell, level or count comes out below what either half states
alone, and that the type is always the occupation's.

### F15 - the Crazy allows two psionic categories that do not exist, so its three starting picks have no legal pool

`crazy` states:

```yaml
psionics:
  type: minor
  isp_base: "6d6"
  powers_starting: 3
  categories_allowed: ["Psychic Sensitive", "Physical Psychic"]
```

The catalog's psionic categories are `Healing`, `Phase`, `Physical`,
`Sensitive` and `Super`. **Neither name the Crazy asks for is one of them.**
`categories_allowed` gates the picker by exact category name, so a Crazy is
offered three picks from a pool of nothing.

It is the only class in the catalog whose `categories_allowed` names anything
outside the five - checked, not assumed, by parsing all 160 published classes
and comparing every entry against `SELECT DISTINCT category FROM
psionic_powers`.

The names are the book's own section headings - Rifts prints "Physical
Psionics" and "Sensitive Psionics" as headings and the transcription kept a
longer form of them. The catalog's shorter names are what every other class
uses.

**This is the psionic twin of the restriction failure the class-import skill
documents**: six classes naming `Robots and Power Armor` after the catalog
renamed that row to `Robots & Power Armor`. An unmatched name fails silently,
and it fails OPEN for an `except` and CLOSED here - the Crazy gets nothing
rather than everything, which is at least the safer direction.

**Proposal:** a `fix-crazy-psionic-categories.sql` rewriting the two names to
`Sensitive` and `Physical`, guarded on the text it replaces. One class, one
data script, no code.

**And a check, because this will happen again.** A regression invariant that
every `categories_allowed` entry in every published class resolves to a real
`psionic_powers.category` - the same shape as the related-skill floor check
added with F6, and the thing that would have caught this at import. Note that
the F10 merge makes the consequence *wider* rather than narrower: a race
composed with the Crazy now carries the Crazy's two dead names alongside its own
real ones, so the dead entries travel.

**Taken, 2026-08-31 (PR #435), as proposed - one class, one data script, no
code, plus the invariant.** Both names now point at `Sensitive` and `Physical`
and the Crazy is offered a real pool. The claim that it is the only class
affected held on a fresh count: **77 `categories_allowed` entries across all 160
published classes, and exactly these two resolve to nothing.**

**THE TRANSCRIPTION WAS FAITHFUL, WHICH THE FINDING GETS SLIGHTLY WRONG.** F15
calls the names "a longer form" of the book's section headings. They are not a
form of anything. Rifts Ultimate Edition printed 55 states the rule in exactly
those words - *"select three psionic powers from either the Psychic Sensitive or
Physical Psychic category"* - read off the page, in the block belonging to this
class. It is the vocabulary gap `catalog-diff` warns about, the book's word
against the catalog's, not a sloppy reading. The note now carries both spellings
so the next person sees why they differ.

**THE SAME SENTENCE CARRIES AN EXCLUSION THE FINDING DOES NOT MENTION, AND
FIXING THE CATEGORIES MAKES IT LIVE.** The book continues: *"(excluding Astral
Projection, Ectoplasm, Object Read and Telekinesis)"*. That was already recorded
in the class's `extraction_notes` and it is not enforceable: `psionics` has no
exclusion, and `powers_from` is a positive list that REPLACES the category gate
rather than narrowing it, so expressing this today means enumerating the other
forty-seven and re-enumerating them whenever a Sensitive power is added.

It was moot while the class could pick nothing - a class with no legal pool
cannot pick the wrong thing - and this PR makes it real. Three picks from 51
where four should be barred is a large improvement on three picks from zero, and
it is worth saying rather than leaving the class unplayable to avoid admitting
it. Filed as **F16**.

**A second gap found on the same page and filed as F17**: the Crazy's
`isp_base` is `"6d6"` where printed 55 says *"6D6 plus the M.E. attribute
number, +1D6 I.S.P. per level of experience, starting with level two"*. Its own
extraction note quotes the full sentence, so the field is short of both the book
and its own record. A bare dice figure is legitimate for the fifteen classes
whose books state one; this is not one of them.

**The invariant is asserted over the live catalog**, not a fixed list: every
`categories_allowed` entry in every published class - including those inside a
special ability's psionics block - must name a category `/catalogs` actually
reports. Regression 233 -> 235.

### F16 - a psionic grant cannot exclude a power, and one class's book does

Rifts Ultimate Edition printed 55, the Crazy: *"Select three psionic powers from
either the Psychic Sensitive or Physical Psychic category (excluding Astral
Projection, Ectoplasm, Object Read and Telekinesis)."*

The parenthetical is unstorable. `psionics.categories_allowed` opens a category
and `psionics.powers_from` names an explicit list, and the two do not compose:

```js
// app.js psiConfig()
// A named list is MORE specific than a category gate, so it replaces it rather
// than narrowing within it, exactly as a skill choice-group's `from` list does.
from: Array.isArray(p.powers_from) && p.powers_from.length ? p.powers_from.map(String) : null,
```

So the only way to say "these two categories except these four" today is to
enumerate the **forty-seven** powers that remain - and re-enumerate them every
time a Sensitive or Physical power is added to the catalog. The catalog holds 29
Sensitive and 22 Physical as of 2026-08-31.

**The skill side has had this since the beginning.** `occ_related_skills`
categories take `only` and `except`, and the class-import skill documents both,
including that an unmatched `except` fails OPEN. The psionic side has `only`'s
equivalent and not `except`'s.

**This was moot until F15 (PR #435).** The Crazy's two categories named nothing
the catalog has, so its three picks had no legal pool at all and it could not
pick a forbidden power because it could not pick anything. Repairing the
categories made the exclusion real: the class now offers 51 powers where the
book allows 47.

**Proposal:** `psionics.categories_allowed` entries take the same shape as
`occ_related_skills.categories` - a plain string, or an object with `only` /
`except`. `categoryAllows()` in `js/parser.js` already implements exactly that
grammar for skills and is shared with the server validator, so the parse, the
picker gate and the save check would come from one function rather than three.
Touches the psionics validator, `psiConfig()` in the wizard, and the server-side
power check.

**Cheaper alternative:** enumerate the forty-seven in `powers_from` and accept
that it goes stale. It is expressible today and it is one data script, but it
trades a rule the book states for a snapshot of a catalog that grows.

**Posture: no new gate.** A class stating an exclusion nothing can enforce is
the current behaviour and it should stay legal - the note records it and a GM
reads it. What is being asked for is the ability to say it, not a check that
punishes not saying it.

**One class, one book, four powers.** Worth knowing before this is taken: the
skill-side equivalent has never had more than a handful of users either, and the
argument for it was the same.

**Taken, 2026-08-31 (PR #436), the PRIMARY proposal, posture as written - no new
gate.** `psionics.categories_allowed` entries now take the same grammar as
`occ_related_skills.categories`: a plain string, or an object with `only` /
`except`. `categoryAllows()` does the work at all three call sites, so the
parse, the two wizard pickers and the server's grant check cannot disagree about
what a category entry means.

**ONE PREMISE WAS WRONG: THERE IS NO PSIONICS VALIDATOR TO TOUCH.** The finding
lists it as one of three places. `parser.js` never validated the psionics block
at all - not the tier, not the counts, not the categories. So this validates the
one key whose grammar just widened, reusing `validateCategories()`, rather than
inventing a validator for the whole block on the way past. A `bonus` on a
psionic category is rejected: a power has an I.S.P. cost and no percentage to
raise, which is the same reasoning that makes `bonus` an error on
`secondary_skills.categories`.

**"OBJECT READ" IS NOT WHAT THE CATALOG CALLS IT**, and this is the trap the
finding sets up without naming. The row is **`Object Read (Psychometry)`**, and
an `except` naming a row that does not exist excludes NOTHING, silently - the
exact failure `class-import` records for six classes that named
`Robots and Power Armor` after that row was renamed. All four names were checked
against `psionic_powers` before the data script ran; the other three match.

So the regression invariant added with F15 is extended rather than repeated:
every `categories_allowed` entry must name a real category **and** every name
inside an `only` / `except` must be a real power. The second half is the one
that would have caught this.

**The Crazy is the one user and it ships in the same PR**, because a mechanism
nothing uses is the silent storage `class-import` warns about. Its pool goes
from 51 powers to 47 - Astral Projection and Object Read (Psychometry) off
Sensitive, Ectoplasm and Telekinesis off Physical, split by the category the
catalog files each under, since `except` is scoped to its own entry.

**The cheaper alternative was not taken and should not be.** Enumerating the
forty-seven in `powers_from` is expressible today and one data script, but it
trades a rule the book states for a snapshot of a catalog that grows - and the
catalog grew twice during this batch.

Smoke 1448 -> 1460. Regression 235 -> 236.

### F17 - the Crazy's I.S.P. formula is short of both its book and its own note

`crazy` stores:

```yaml
psionics:
  isp_base: "6d6"
```

Rifts Ultimate Edition printed 55 says *"I.S.P. Base: 6D6 plus the M.E.
attribute number, +1D6 I.S.P. per level of experience, starting with level
two."* The class's own `extraction_notes` quotes that sentence in full, so the
field is short of the book **and** of the record beside it.

`rollPoolFormula` is handed the character's attributes and resolves an attribute
named in the formula, so `"6d6 plus M.E. attribute number, +1d6 per level"` is a
storable string - 23 classes in the catalog store one of that shape. A Crazy
therefore rolls 6-36 I.S.P. where the book gives it 6-36 **plus its M.E.**, and
gains nothing per level.

**A bare dice figure is not itself wrong.** Fifteen classes store one, and for
most of them - the dragon hatchlings, the entrancer, the shade - it is what
their books print. This is a transcription that dropped two thirds of a
sentence, not a convention.

**Proposal:** a `fix-crazy-isp-base.sql` writing the printed formula, guarded on
the text it replaces. One class, one data script, no code.

**Worth doing as a sweep rather than a fix.** The interesting question is not
the Crazy: it is whether any of the other fourteen bare figures is also short of
its page. That is fourteen `--field-sources` reads against the OCR cache, which
is free, and it is the only way to know whether this is one class or a habit.
Found while taking F15, on the page F15 sent me to.

**Taken, 2026-08-31 (PR #437), as a sweep first and then a one-class fix.**
`isp_base` is now the printed formula, read off a 200 dpi render of Rifts
Ultimate Edition printed 55 - the folio confirms the book's +3 offset - and the
M.E. term resolves: a Crazy with M.E. 14 now rolls 20-50 I.S.P. where it rolled
6-36.

**THE SWEEP'S ANSWER IS ONE CLASS, NOT A HABIT**, which is the answer worth
having and the reason the finding asked for it. Fifteen classes store an
`isp_base` with no attribute term and fourteen are right:

- the **shade**, **entrancer**, **holy terror** and **morphworm** were read line
  by line against their own pages in the Wormwood cache, and all four print a
  bare figure - *"Psionic Powers: Major psionic, 3D4 x 10 I.S.P."*;
- the six **dragon hatchling variants** store the per-level term their pages
  print, on Rifts Ultimate 160-161;
- the **pleasurer**, **vacuum wasp** and **termite engineer** store theirs too;
- the base **Dragon Hatchling**'s entry gives no I.S.P. figure at all - *"Most
  dragons possess some range of psychic ability"* is the whole line - and its
  3D4x10 is a documented earlier decision recorded in its own note.

**WHERE THE 6D6 CAME FROM, which is the part worth keeping.** Two lines below
the psionics entry the same page prints **"P.P.E. Base: 6D6 P.P.E."**, and the
class stores `ppe_base: "6d6"` correctly. Two figures, adjacent, identical at a
glance, and only one of them carries the extra terms. It is the only class in
the catalog whose `isp_base` and `ppe_base` are the identical string - checked
across all 160 - so the slip did not spread, and that comparison is now a
regression invariant. It proves nothing on its own; it is one comparison, and it
is the shape this error takes.

Regression 236 -> 237.

### F18 - a skill's base percentage is resolved on the SERVER too, and that path never reads `base_formula`

F2 added `skills.base_formula` and `js/skill-base.js`, whose `skillBase(row,
attrs)` is documented as *the ONLY place the two are chosen between, so a caller
cannot read one and forget the other*. One caller does exactly that.

**`resolvePicks` in `functions/api/character-creator/_lib/skill-picks.js` does
not select the column and does not call the helper.** Its lookup is
`SELECT name, category, base, per_level FROM skills`, and it stores
`pct: base ? base + catBonus : 0`. With `base` 0 - which is what an
attribute-derived row stores, by design - a spent pick lands on the sheet at
zero.

Two endpoints route through it: `characters/[id]/picks.js` (a banked pick spent
later) and `characters/[id]/level-confirm.js` (a pick spent at the level-up
itself). **Creation is correct and everything after it is not**: `app.js`
resolves through `skillBase()` at four sites, so the same skill taken at
character creation is right and the same skill taken at level 4 is 0%.

It does not self-correct. `js/leveling.js` advances from the STORED `pct`, so a
skill banked at 0 climbs by its per-level step from 0 forever.

**Premises, measured 2026-09-01 against `--remote`:**

- **One** catalog row carries a `base_formula`: `Space: Zero Gravity Movement &
  Combat`, `PP*5`, `base` 0, `per_level` 4, Phase World p.150. Still the only
  one, as F2's own follow-up said.
- `skillBase()` has exactly five callers - four in `app.js`, one in
  `_lib/grants.js`. Nothing else in `functions/` consults it.
- **No live character holds the skill**, so nothing is wrong on the site today.
  This is latent, and filing it while that is true is the cheap moment.

**Reachable from any class, not just those allowing Physical.** The skill is
Physical, but `resolvePicks` spends an out-of-category pick as a SECONDARY
skill, and secondary picks are deliberately unrestricted. Any character with a
secondary slot can take it.

**How it survived F2.** That finding asked where the evaluation belongs and
answered *the wizard*, on the reasoning that a base is resolved once, at
creation. That is true of both places it went looking, and both were display:
the class-skills row and the picker. `resolvePicks` is a WRITE site, and it
computes the same number a third way. The finding's own note records the picker
as the site the tests could not see; this is the fourth, and the same test
suite still cannot see it, because no fixture spends a pick on the one row that
has a formula.

It came to light from `_lib/grants.js`, written for plan 19 (PR #482), which
reads through `skillBase()` because the helper's own comment said to. Having two
server paths that disagree is what made the older one visible.

**Proposal.**

- Add `base_formula` to the `SELECT` in `resolvePicks` and resolve the
  percentage through `skillBase()` rather than off `base`.
- Thread the character's attributes into `resolvePicks`. **This needs no new
  query**: both callers already load the whole character and already hand
  `character.attributes` to `validateCharacter`, so it is one more field on an
  options object that is already being built.
- **Get the category bonus right, and it is the one judgement here.** The
  `base ? base + catBonus : 0` guard exists so a W.P. has no percentage for a
  percentage bonus to modify. A formula-derived base IS a real percentage and
  should take the class's per-category bonus. So the guard has to become *did we
  end up with a percentage*, not *is the stored base non-zero* - otherwise the
  fix trades a 0% for a percentage that is missing its class bonus, which is
  harder to notice than the bug it replaces.
- **Backfill: nothing to do, and check that again when this is taken.** No
  character holds the skill today. If one does by then, its stored `pct` is
  wrong and no code path will revisit it, so it wants a data script rather than
  being left to the next level-up.

**Posture: fix the write path only.** No new gate, no exit code, no change to
`base`, the grammar or the fallback. A test that spends a pick on a
formula-carrying row is the thing that would have caught this and is worth
having; it is a fixture, not a check on anyone's build.

**Taken, 2026-09-02 (PR #590).** Posture kept: the write path only, no new gate,
no exit code, `base` and the grammar and the fallback all untouched. The test is
a fixture.

`resolvePicks` now selects `base_formula` and resolves through `skillBase()`, and
both callers thread `character.attributes` — which cost no query, exactly as this
finding predicted: each already loads the whole character and already hands the
attributes to `validateCharacter`.

**Every premise re-measured against `--remote`, and all hold.** One catalog row
carries a formula (`Space: Zero Gravity Movement & Combat`, `PP*5`, base 0,
per_level 4). `skillBase()` still has five callers, four in `app.js` and one in
`_lib/grants.js`. And the backfill check this finding asks to re-run at take-time
returns **0 characters holding the skill**, so there is still nothing to backfill
and no data script is needed.

**The judgement went the way this finding argued.** The guard is now on the
*resolved* percentage rather than on the stored `base`, so a formula-derived base
takes the class category bonus like any other percentage, and a W.P. still takes
nothing. Both are asserted.

**Proved by making it fail**, which is the only reason to trust a new fixture:
with the one line reverted, the new section reports **2 of 4 checks failing** —
the derived base and the category bonus — while the fallback and the W.P. guard
still pass, which is exactly the split the fix should produce. Restored, and the
whole suite run flagless.

Smoke 1649 → **1653 in 113 sections**; regression **237**, unchanged.

**Verified END TO END on production, 2026-09-02.** Nate spent a real banked pick
on `1212` (level 6, P.P. 15) through the live sheet, and D1 was read back rather
than the sheet trusted:

```
pct         75          = P.P. 15 x 5.  The shipped bug would have stored 0.
type        related     correct - Physical IS in the grant's categories
unspent     3 -> 2      a banked pick was genuinely consumed
claimed     0 -> 1      the level-3 grant: oldest first, as claimStatements says
grant_rows  unchanged   so this was resolvePicks, not the grants.js path
override    absent      correctly in-category
```

At level 10 that character now reads **91%** where the old code gives **16%**.

**Three earlier attempts at this verification all landed on healthy paths**, and
that is the durable lesson rather than the fix. A level-1 character exercised
*creation*, which `app.js` already resolved correctly. A GM grant exercised
`_lib/grants.js`, which already called `skillBase()` — the very path whose
disagreement exposed this finding. Both produced a **correct number from code
that was never broken**, and both read as a pass. What finally discriminated was
not the percentage at all but the **pick counters**: `unspent` and `claimed` are
the only evidence that `resolvePicks` ran, and no other path can move them.

**A verification needs a signature, not a value.** The value was satisfiable
three ways.

**And one prediction here was wrong, from a self-inflicted truncation.** `type`
was expected to be `secondary`, on the reading that the grant covered only
Communications. Its category list holds thirteen entries and the sixth is
`{"name":"Physical","except":["Acrobatics","Boxing","Wrestling"]}` — the display
that said otherwise had been cut to 60 characters *by the query that printed
it*. Same shape as the terminal-transcription trap `windows-shell` records: read
the value from the file, not from a rendering of it.

**One thing worth recording for the protocol rather than for this fix.**
`audit-menu` says to grep the tree for a finding's number when it is taken. Here
that is actively misleading: **six menus in this repo have an `F18`** —
`CLASS-AUDIT`, `INGESTION-AUDIT`, `REBUILD-AUDIT`, `HEALTH-AUDIT`, `SKILL-AUDIT`
and `UI-AUDIT` — and every hit outside this file belonged to a different one. A
bare finding number is not a unique key across menus, and a sweep that treats it
as one will read another menu's history as this one's citations.

### F19 - the citation check searches the catalog's category prefix as part of the name, and 213 of its 216 warnings are its own

`drift-check --remote` prints `NO DRIFT` and then an advisory block —
`citations:    948 row(s) checked, 216 worth a look` — each line of the form
*`spells.Air: Tornado` claims "Rifts Book of Magic" — name absent from its
text*.

**Almost none of the 216 is a bad citation.** The check flattens both the book's
text and the row's name to bare alphanumerics and asks whether the name appears.
The catalog's category prefix goes into the search string with everything else:

```js
const flat = (n) => String(n).replace(/\([^)]*\)/g, ' ')
  .toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
```

So `Air: Tornado` normalises to `air tornado`, and no book prints that. The book
prints *Tornado*, in a list headed *Air*.

**Measured against production and the real `txt` caches, 2026-09-03** — the
whole advisory block re-tested row by row against each row's own cited book:

| | rows |
|---|---|
| flagged today | **216** |
| carrying a colon prefix — `Air:` `Earth:` `Fire:` `Water:` `Language:` `Space:` `Navigation:` | 210 |
| carrying `W.P. `, which has no colon | 5 |
| carrying no prefix at all | 1 |
| **found once the prefix is dropped** | **213** |
| surviving | **3** |

The four elemental families are 193 of the 216 on their own. All 231 elemental
spells are present in the `bom` cache under their bare names; 193 are absent
with the prefix attached, and the 38 that do match prefixed match by accident —
running prose puts *Air* beside *Cloud of Slumber*.

So a check whose own comment argues that **a check that cries wolf 35 times is
worse than no check** is now crying wolf 213 times, and the rows that might be
real are invisible inside it.

**This is not `F1`, and not the `--values` pass `F1` produced.** That check asks
whether a *numeric value* is printed inside the *specific pages* a row cites,
over `gear` — which this check excludes by name, because a gear name here is
reworded prose rather than a heading the book prints. Its false positives are
prices stated in words and citations that are a page short: defects in the ROW,
and the actionable half of its output. This check asks whether a *name* appears
anywhere in the *whole book*, over `spells`, `psionic_powers` and `skills`, and
its false positives are manufactured by its own normalisation. **`F1`'s misses
point at rows to fix. These point at the check.**

**Proposal:** add a de-prefixed form to the `forms` set that `found()` already
builds. It derives singular/plural variants and an `&`-expanded reading; a
prefix strip is the same shape of variant, and seeding it before the existing
plural loop gets its plural for free.

**The strip needs two shapes, not one, and that is the part to get right.**
`W.P.` carries no colon, so a colon-anchored `^[A-Za-z .]+:\s*` never reaches
it. Measured both ways against production: colon alone resolves **209** and
leaves **7**; colon plus a `^W\.P\.\s*` strip resolves **213** and leaves **3**.
Four of the five `W.P.` rows — *Automatic Pistol*, *Bolt Action Rifle*,
*Revolver* and *Rope* — are present in their books under the bare name. Note
that `W.P. Rope` cites **New West**, not RUE: tested against the wrong book it
reads as found, which hides that it is flagged at all.

**Posture: advisory only, and the exit code must not move.** The block is
deliberately not a gate — the comment beside it says wiring it into the exit
code *"would fail every run over a name the book spells differently - which is
how a useful check gets ignored"* — and that stays true with a better matcher.
Nothing here touches `problems`, the verdict line, or the exit status.

**Do not rename any catalog row to match a book.** The prefix is the catalog's
naming convention, and rows are referenced by their exact stored name: 146 data
scripts under `apps/character-creator/db/` carry 469 occurrences of a prefixed
name. Nothing parses the prefix — no code in `js/` or `functions/` splits on it
— so the cost of renaming is not a parser, it is every script that names the
row. The check is what should learn.

**Worth deciding when taken, not before.** One of the three survivors is still
the check rather than the data. `Language: Trade Five/Reptile` cites Phase
World, which prints *Language: Trade Five* at 98% in an R.C.C. skill list; the
`/Reptile` half is the catalog's own gloss and the word *reptile* appears
nowhere in that book. `flat()` turns the slash into a space, so a de-prefixed
`trade five reptile` still misses. Whether `found()` should also try each side
of a `/` is a second variant carrying its own false-positive risk, and it is a
much smaller problem than the prefix — one row against 213.

**The other two survivors are a data question and are deliberately not part of
this.** `W.P. Automatic and Semi-automatic Rifles` (RUE) and `Summon and Control
Canines` (Book of Magic) are absent with and without a prefix. A book that
writes a name differently reads exactly like one that never had it — the
advisory's own warning — so those want their cited pages read by eye rather than
a code change, and not in the PR that changes the check.

**Adjusted 2026-09-03 — both were read, and only one of them is a data
question.**

`Summon and Control Canines` is **a third artifact of this same check**. Book of
Magic printed 131 — cached `p132.txt`, offset 1 — prints **`Summon & Control
Canines (ritual)`**, so the citation is exactly right. The flattener deletes the
book's `&`, leaving `summon control canines`, which is present; the catalog
spells the word out, giving `summon and control canines`, which is not.
`found()` already expands `&` to `and` on the NAME side, for a catalog name
carrying an ampersand — the comment beside it records that case and the 18
skills it was written for. **There is no transform in the other direction**, so a
catalog name that spells *and* can never meet a book that printed `&`. Its five
siblings — *Animals*, *Entity*, *Rain*, *Storm*, *Rodents* — each appear
somewhere in `bom` with *and* spelled out, which is the only reason this row is
alone in the advisory rather than joined by all six. **Worth folding into this
finding's proposal when it is taken:** an `and`-elided form is the same shape of
variant as the prefix strip, in the same `forms` set.

`W.P. Automatic and Semi-automatic Rifles` **is** a data question, and it is four
rows rather than one. Filed as `INGESTION-AUDIT.md` `F25`.

**`F25` also names a limit of the proposal above, which belongs here.** A
de-prefixed whole-book name search matches **prose**. Three rows beside that one
— `W.P. Automatic Pistol`, `W.P. Revolver`, `W.P. Bolt Action Rifle` — cite RUE
for proficiencies RUE does not define, and every one of them goes quiet under
this fix, because RUE writes *"Typical Payload: Revolver: Six bullets. Automatic
Pistol: 8-16 rounds"* in a weapon stat block and *"bolt-action rifle"* in a list
of gun types. **This check cannot tell "the book defines this" from "the book
uses these words."** Clearing 213 false alarms will also hide three true ones.
That argues for keeping the block advisory — which it already is, and which this
finding's posture already requires — not for leaving it noisy.

So the residual after this fix is **three lines printed**: `Language: Trade
Five/Reptile` and `Summon and Control Canines`, both artifacts of the check, and
`W.P. Automatic and Semi-automatic Rifles`, which is real. Plus **three real
citation errors that stop being printed**, which is the part a reader of a quiet
advisory block would not know to look for.

**Taken, 2026-09-03 (PR #605). Posture held: advisory only, exit code
untouched.** Nothing was added to `problems`, the verdict line is unchanged, and
both runs below exited 0 on `NO DRIFT`. No catalog row was renamed and no gate
was added.

`found()` gains a `dePrefix()` variant in the set it already builds — both
shapes, `^[A-Za-z .]+?:` and `^W\.P\.`, lazy so a name with two colons loses only
the first — plus the `and`-elided form the *Adjusted* note above asked for.
**Every form is ADDED, never substituted**, so `base` stays in the set and a row
whose full prefixed name really is printed still matches on it.

**Measured against production the same day, before and after, same catalog:**

| | |
|---|---|
| before | `948 row(s) checked, **216** worth a look` |
| after | `948 row(s) checked, **2** worth a look` |
| lines removed | **214** |
| lines in the after-run that were NOT in the before-run | **0** |
| every non-citation line of the two runs | identical |

That last pair is the property worth having rather than the count: because the
change only ever adds readings, `.some()` can only become more likely to be
true, so this **cannot lengthen the advisory**. It was checked by set
comparison, not assumed.

**One better than this finding predicted, and the reason matters.** It said
three would survive; two did. `Summon and Control Canines` went with the
`and`-elision, which is the variant the *Adjusted* note added — so the elision
earned its place on a row this finding had already diagnosed rather than on
speculation. The two left are exactly the two named above as real questions:
`W.P. Automatic and Semi-automatic Rifles` (`INGESTION-AUDIT.md` `F25`) and
`Language: Trade Five/Reptile`, the `/` gloss this finding deliberately declined.

**What auditing this turned up, and it is the most useful thing here.**
`scripts/catalog-match-lib.mjs` **already exists** and already solves two of the
three variant problems, from real Palladium-vs-catalog differences:

- `loose()` drops `and` and `or` — the same transform hand-rolled here, and its
  docstring cites *"Animate and Control Dead"* against the book's
  *"Animate/Control Dead"*.
- `variants()` carries a **slash-half rule** — *"Impervious to Poison/Toxin
  should meet Impervious to Poison"* — which is exactly the shape of `Language:
  Trade Five/Reptile`, guarded by a substantial-half length test that is a
  better answer than the one this finding declined to invent.
- its plural comment uses **`Summon & Control Canines`** as its worked example.

**It has no notion of a category prefix**, so the central fix here is genuinely
new. But `drift-check`'s `found()` is a second, hand-rolled matcher standing
beside a shared one that `catalog-diff.mjs` uses and
`test/checks/catalog-matching.mjs` pins. **That duplication was not touched**,
deliberately: adopting `variants()` swaps `flat()`'s pipeline for `normalise()`'s
— which expands `&` to `and` where `flat()` deletes it — and the comment above
records 18 skills that go missing when that expansion is applied alone. That is
a real change of behaviour, outside this finding's scope, and it wants its own
number rather than a quiet ride here.

**`found()` has no test, and none was added.** It is a closure inside the
per-book loop, so testing it means extracting it, which is the refactor the
paragraph above says to decide separately. The proof here is the before/after
pair on the same catalog on the same day, plus the set comparison — not a
fixture. Worth knowing when the consolidation above is taken: that refactor is
what would make this matcher testable at all.

### F20 - two name matchers, one of them shared and tested, and `drift-check` uses the other

`F19`'s outcome note records this and gives it no number. This is the number.

`scripts/catalog-match-lib.mjs` is a name-matching library built from real
Palladium-vs-catalog differences, used by `catalog-diff.mjs` and pinned by
`apps/character-creator/test/checks/catalog-matching.mjs`. `drift-check`'s
`found()` is a **second, hand-rolled matcher** that solves the same problem
worse, and every variant `F19` added to it already existed in the library:

| the library already has | `found()` after `F19` |
|---|---|
| `loose()` — drops `and` and `or` | a hand-rolled ` and ` elision |
| singular/plural on the last word | the same, hand-rolled |
| `stem()` — parenthetical dropped | the same, hand-rolled |
| **a slash-half rule**, guarded by a substantial-half length test | **nothing** |
| — | **the category-prefix strip**, which the library does not have |

**Measured 2026-09-03, over the 941 catalog rows whose cited book has a cache,
each against its own book:**

| matcher | rows flagged |
|---|---|
| `found()` as it stands after `F19` | **2** |
| `variants(name)` + `variants(dePrefix(name))` | **1** |
| flagged by the library and **not** by `found()` | **0** |

**Zero regressions, and one fewer false alarm.** The row the library resolves and
`found()` does not is `Language: Trade Five/Reptile` — the `/` gloss `F19`
explicitly declined to invent a rule for. The library's rule is better than the
one that was declined: it takes a slash half only when the half is at least
substantial relative to the whole, so it does not register `toxin` as an alias of
*Impervious to Poison/Toxin*, which is the failure a naive split produces.

**The objection `F19` raised against this does not survive measurement, and that
is the point of filing it.** `F19` declined the consolidation because
`variants()` runs through `normalise()`, which expands `&` to `and`, where
`flat()` deletes it — and the comment in `found()` records **18 skills** that
went missing when that expansion was applied alone. Tested directly: **27 rows
carry an `&` in their name, and all 27 are found by both matchers.** None is lost.
`loose()` is why — it strips the `and` that `normalise()` introduced, so the pair
covers the reading `flat()` gets in one step. The 18-skill failure was real
against `normalise()` *alone*; it is not an argument against `variants()`, which
is `normalise()` plus the compensating form.

**Proposal:** replace the hand-rolled set in `found()` with `variants()` from the
library, keeping the de-prefixed name as a second call —
`new Set([...variants(n), ...variants(dePrefix(n))])` is the whole of it. That
deletes the duplicate and inherits the slash rule, the length guard and the
library's tests.

**The one real decision: where the prefix strip lives.** The library has no
notion of a category prefix, and there are two places to put it:

- **In `drift-check`**, as it is now — the library is untouched, `catalog-diff`
  is unaffected, and `test/checks/catalog-matching.mjs` needs no change. Smaller,
  and leaves the prefix knowledge outside the shared thing that has tests.
- **In `variants()`** — `catalog-diff` gets it too, which is probably right,
  since a catalog row prefixed `Air:` is as hard for that tool to match as for
  this one. But it changes behaviour that a smoke section pins, so the test moves
  in the same PR and the blast radius is real.

**Prefer the first unless `catalog-diff` is measured to want it**, and measure
that before deciding rather than reasoning about it — `F19` reasoned about the
`&` case and was wrong.

**Posture: advisory only, exit code untouched, no gate**, exactly as `F19`. This
is a refactor whose visible effect is one fewer advisory line; if the count moves
by more than that in either direction, something else changed and the diff is
wrong.

**It also makes the matcher testable, which nothing else will.** `found()` is a
closure inside the per-book loop and has no test of its own; `F19` recorded that
and declined the extraction as out of scope. Consolidating removes the closure's
reason to exist, and `variants()` arrives already covered.

**One caveat on the numbers above.** They come from a harness that reproduces
`drift-check`'s text flattening and slug resolution rather than from
`drift-check` itself, and its slug mapping is a shade narrower — 941 rows against
the check's own 948, seven rows resolving through a registry alias the harness
does not implement. **The A-versus-B comparison is over the same 941 either
way**, so the 2-vs-1 and the zero-regression result stand; the absolute counts
are the harness's, not the check's. Re-run the check itself when this is taken.

**Taken, 2026-09-03 (PR #614). Posture held: advisory only, exit code untouched,
no gate.** `found()` is now `new Set([...variants(n), ...variants(dePrefix(n))])`
and nothing else; the hand-rolled `flat()` and the `and`-elision loop are gone.
The diff is +32/−31, which is the shape a consolidation should have.

**The acceptance test this finding set was met exactly.** It said the visible
effect should be *one fewer advisory line*, and that a move larger than that in
either direction means the diff is wrong. Run against production:

| | |
|---|---|
| before | `948 row(s) checked, **2** worth a look` |
| after | `948 row(s) checked, **1** worth a look` |
| exit | **0**, `NO DRIFT`, both runs |

The line that went is `Language: Trade Five/Reptile`, closed by the library's
**slash-half rule** — the case `F19` declined to invent a rule for, arriving for
free with a length guard better than the one that was declined. What remains is
`W.P. Automatic and Semi-automatic Rifles`, which is real and is
`INGESTION-AUDIT.md` `F25`. **The advisory block is now one line, and that line
is a defect.**

**The objection `F19` raised was re-tested against the real thing before
switching, not taken on the harness's word.** 27 catalog rows carry an `&` and
all 27 are found either way; `loose()` strips the `and` that `normalise()`
introduces. The 18-skill failure the old comment recorded was real against
`normalise()` **alone**, and was never an argument against `variants()`.

**The prefix strip stayed local, and this is the decision the finding asked to be
made by measurement.** It said *prefer `drift-check` unless `catalog-diff` is
measured to want it*. Measured — and `catalog-diff` **does** want it, larger than
expected. It indexes catalog rows by `variants()` and looks up book-entry names
against that index, so a prefixed row is indexed with no bare form:

| the 374 prefixed catalog rows, a book printing the BARE name | today | with a de-prefixed form in the index |
|---|---|---|
| finds the right row | **0** | **269** |
| finds nothing | 317 | 49 |

21 de-prefixed keys are claimed by more than one row — `Circle of Rain` is both
`Air:` and `Water:`, `Cloud of Steam` is Air, Fire and Water — and the library's
both-sides ambiguity rule refuses those rather than guessing, which is the rule
working.

**It was still not moved, and the reason is this finding's own posture.** A
0 → 269 change in what a second tool matches is not *"one fewer advisory line"*;
it is a different change wearing this one's clothes, and `audit-menu` is explicit
that a finding taken with the right mechanism and the wrong posture has shipped
the wrong change. It also moves a pinned smoke section. **So the measurement is
recorded here and the decision is unfiled** — it wants its own number, and
whoever takes it starts from the table above rather than from a hunch.

**Filed as `F21`, 2026-09-03 (PR #615).** The number the paragraph above asks
for.

### F21 - `catalog-diff` cannot match a prefixed catalog row from the name its book prints

`F20` left this measured and unnumbered. `drift-check` now strips the catalog's
category prefix locally; `catalog-match-lib.mjs` still has no notion of one, and
`catalog-diff.mjs` is the tool that pays for it.

`diffCatalog` indexes **catalog rows** by `variants()` and looks up **book-entry
names** against that index. A row stored as `Air: Tornado` is indexed under
`air tornado` and its variants — never `tornado` — so a book printing *Tornado*
cannot reach it. `F19` established that the bare name is what books print: 213 of
216 rows it flagged were found the moment the prefix came off.

**Measured against production, 2026-09-03**, over the 374 prefixed rows of 1,068:

| a book printing the BARE name | today | with a de-prefixed reading indexed |
|---|---|---|
| finds the right row | **0** | **269** |
| finds nothing | 317 | 49 |

**Nothing regresses, and this was checked rather than assumed.** Every row that
finds itself by its own full name today still does: **1053 before, 1053 after,
0 regressed.** `match()` consults `index.exact` first, keyed on `normalise(name)`,
and adding alias keys cannot disturb an exact hit. The risk this rules out is the
obvious one — that `Air: Darkness` claiming `darkness` would knock a row actually
named *Darkness* off its own key.

**The real cost is 53 contested names, and they are contested for a good
reason.** That many bare names are held by **both** a prefixed and an unprefixed
row, because Palladium prints both a general invocation and an elemental Warlock
version of the same spell:

| unprefixed row | prefixed row |
|---|---|
| `Cloud of Smoke` — Rifts Ultimate Edition p.198 | `Fire: Cloud of Smoke` — Book of Magic p.74 |
| `Blinding Flash` | `Fire: Blinding Flash` — Book of Magic p.74 |
| `Thunderclap` | `Air: Thunderclap` — Book of Magic p.57-66 |

These are **different spells**, not duplicates. A book printing *Blinding Flash*
genuinely could mean either, and the library's both-sides ambiguity rule refuses
to guess — which is that rule working, not a defect. The 269 above already has
these refusals subtracted.

**One guard's letter survives and its spirit does not, which is the part worth
arguing about.** `test/checks/catalog-matching.mjs` pins *"variants stay small"*
as `variants('Commune with Spirits').length <= 4`. That assertion still passes:
the name it uses carries no prefix and yields **2**. But across the catalog the
combined set reaches **6**, with **22 rows over 4** — so the check would go on
passing while the property it was written to protect quietly stopped holding.
`variants()`'s own docstring is the reason to care: *"Deliberately small. Every
entry here is a difference actually observed between a Palladium book and this
catalog — a general-purpose fuzzy expansion is how you get Telekinetic Push
matched to Telekinetic Punch."*

**Proposal:** add the de-prefixed reading to `variants()`, and **re-pin the
guard on the property rather than on one name** — assert the bound over a
prefixed name too, so the check fails when the set grows rather than when one
unprefixed example happens to. Raising `4` without doing that would remove the
only thing standing between this library and general fuzzy matching.

**Posture: no exit code moves anywhere.** `catalog-diff` is a report, and
`drift-check`'s advisory is not a gate. **The acceptance test is two numbers**:
`catalog-diff`'s matched count rises by roughly 269 on the prefixed rows, and
`drift-check`'s advisory **stays at 1** — it already strips the prefix locally,
so this must not change what it prints. If the advisory moves, the local strip
and the library's are disagreeing and the diff is wrong.

**Then delete `dePrefix` from `drift-check.mjs`**, which is the point of doing
this at all: one matcher, one place, and the local strip retired in the same PR
rather than left as a second copy of the rule.

**Decline it** if `catalog-diff` matching 269 more rows is not worth touching a
shared library that four things depend on. That is a real position — nothing is
broken today, the tool simply reports as missing a set of rows that are present,
and `F20` already took the cheap half. The cost of declining is that the two
matchers stay divergent, which is the condition `F20` was filed to end.

**Taken, 2026-09-03 (PR #617), as proposed, both halves.** The de-prefixed
reading is in `variants()`; `dePrefix` is **gone from `drift-check.mjs`**, which
was the point — one matcher in one place rather than a rule with two copies.
**No exit code moves anywhere.**

**Both acceptance numbers hit, and the second is the one that mattered.**

| | wanted | got |
|---|---|---|
| `catalog-diff`: prefixed rows found by their book's bare name | ~269 | **269** of 374 |
| `drift-check` advisory | **stays at 1** | `948 row(s) checked, **1** worth a look`, `NO DRIFT`, exit 0 |

The advisory holding still is what proves the local strip and the library's
agree. Had it moved, the two would have been computing different things and the
diff would have been wrong — which is why that number was written into the
finding before the change rather than read off after it.

**The guard was re-pinned on the property, not raised.** `variants stay small`
was `variants('Commune with Spirits').length <= 4` — an unprefixed name yielding
**2**, passing with room to spare and certain to go on passing while the property
it guards stopped holding. It is now three assertions binding the **worst case**:

- unprefixed, unchanged at `<= 4`
- **prefixed and slashed and ampersanded** — `Air: Summon & Control
  Canines/Felines` — at `<= 6`, which is the measured ceiling across the whole
  catalog. One more variant and it fails.
- **the strip is anchored**: `Bolt Action Rifle` gains neither `rifle` nor
  `action rifle`, so a name with no prefix gains nothing at all.

Two more assert the strip does what it says: `Air: Tornado` yields `tornado`, and
`W.P. Rope` yields `rope` despite carrying no colon.

**Nothing regressed**, measured against the library *before* the change:
**1053 rows found themselves by their own full name, 1053 after, 0 lost.**
`match()` consults `index.exact` first, keyed on `normalise`, where an added
alias cannot reach — so the risk this finding named, `Air: Darkness` knocking a
row called *Darkness* off its own key, does not occur.

**The 53 contested names behave exactly as this finding predicted.** With the
strip live, 59 of the 374 prefixed rows resolve to a *different* row and 46 to
nothing. Those are the general-invocation-versus-Warlock pairs — `Cloud of
Smoke` against `Fire: Cloud of Smoke` — and the both-sides ambiguity rule
refusing to guess is the correct answer to a genuinely ambiguous name, not a
loss.

**One thing worth recording about this entry specifically.** It is the only form
in `variants()` that is *not* a difference observed between a book and this
catalog — it is a difference the catalog imposes on itself. That is written into
the comment, because the docstring's warning against general fuzzy expansion is
the reason this library is trustworthy, and the next person adding a form should
have to notice that this one is the exception and why.

### F22 - a spell or psionic power with no description is a stub nothing counts, and the codex is the page it shows up on

`/api/character-creator/codex` serves every spell and psionic power together
with the text that says what it does - the second half of
`apps/character-creator/docs/plans/20-power-descriptions.md`, written for the
691 powers a character does NOT hold. `description` is the column that page
exists to render.

The backlog table in `scripts/source-coverage.mjs` reports five kinds of
unfinished row and no kind that would catch an empty one. Read at lines 258-272
on 2026-09-06: `gear stubs` keys on `description LIKE 'STUB%'`, `skill stubs` on
`source = 'import' AND base = 0 AND per_level = 0`, `spell stubs` on
`level = 0 AND ppe = 0`, `psionic stubs` on `isp = 0`, and the fifth is gear
with no price. A spell imported with a level, a P.P.E. cost and no text carries
none of those signatures. It reads as finished in every report this repo has,
and renders as an empty entry in the codex.

**The instruction layer is silent about the codex too.**
`grep -ril codex .claude/skills .claude/agents scripts` returned no match on
2026-09-06. The descriptions that ARE stored got there because the spell and
psionic data scripts happen to carry the column -
`apps/character-creator/db/add-phase-world-phase-powers.sql` inserts
`range, duration, saving_throw, description` per row and argues in its header
that this is "the exact column set this table holds" - rather than because any
rule asks for it.

**It is latent, not live.** Measured 2026-09-06,
`npx wrangler d1 execute nates-workshop-media --remote`:

| table | rows | blank description | shortest | mean |
|---|---|---|---|---|
| `spells` | 607 | **0** | 63 chars | 463 |
| `psionic_powers` | 116 | **0** | 65 chars | 655 |

Neither table holds a `STUB%` or `See %` placeholder in that column either. So
this proposes a ledger line for a number that is zero today, on the argument
`INGESTION-AUDIT` `F5` made for the backlog table itself: small numbers are
worth counting before a shelf of books turns them into a project.

**A decision already exists here, and this finding argues past it rather than
around it.** `INGESTION-AUDIT` `F5`'s outcome note NARROWED the stub signatures
after its own figure came back a 4x over-count - 21 imported skills at 0/0 were
5, the other 16 being Hand to Hand rows and deliberately-modelled non-percentile
skills whose long `note` says why nothing is stored - and settled the definition
as a row an importer created and nobody touched since. A blank description does
not reopen that argument: there is no spell whose text is correctly absent, so
the false-positive class that produced the 4x cannot form here.

**The `source = 'import'` filter is deliberately absent from the predicate**,
which departs from three of the five lines above it and matches the two gear
ones. Measured 2026-09-06: of the 23 rows
`apps/character-creator/db/backfill-spell-descriptions.sql` filled - the last
blank descriptions this catalog actually had - **17 are `source = 'seed'`** and
6 are `source = 'import'`. A detector watching importers alone would have missed
seventeen of twenty-three.

**Proposal:** two lines in the `backlog` array of `scripts/source-coverage.mjs`:

```js
['spell text missing', "SELECT count(*) AS n FROM spells "
  + "WHERE description IS NULL OR trim(description) = ''",
  'nothing for the codex to show'],
['psionic text missing', "SELECT count(*) AS n FROM psionic_powers "
  + "WHERE description IS NULL OR trim(description) = ''",
  'nothing for the codex to show'],
```

and, in the same PR, extend the *Stubs* section of
`.claude/skills/class-import/reference/catalog.md` - read 2026-09-06, it defines
a stub for gear and for skills and stops there - to say that a spell or psionic
row carrying a level, a cost and no `description` is a stub as well.

**Posture: advisory, log-not-cap.** `scripts/source-coverage.mjs` always exits 0
and must keep doing so; no test, no CI check, no exit code moves. The report
reaches a book session because `book-survey` already requires pasting
`source-coverage.mjs --remote` into every survey, not because anyone remembers
this rule.

**Prove it by making it fail.** Both lines report 0 on the day they land, and a
check that has only ever printed zero has not been shown to work. Blank one
description in a `--local` database, confirm the line reports 1, restore it, and
record that in the outcome note.

**Evidence:** the `--remote` queries and the `grep` above, all run 2026-09-06;
`scripts/source-coverage.mjs`, `catalog.md` and
`apps/character-creator/test/checks/catalog-data.mjs` read the same day. Nothing
here is inferred.

**Confidence:** high that the mechanism is right - the predicate is binary and
the table it joins already exists. **Medium on whether it earns its line, and
the next book import is what would raise it:** until a book lands a row with no
text, this is two lines reporting zero.

**Ongoing cost:** two SQL strings inside a script that already runs on every
book survey. No new file, no scheduled job, no CI minute, nothing to keep
current.

**What this finding does NOT propose, recorded rather than left as a deferral**
(`META-AUDIT` `A16`): a check on the sparse stat-block columns the codex also
renders. Measured 2026-09-06 across the 588 spells carrying
`source = 'import'`, `damage` is populated on 95, `casting_time` on 43 and
`area_of_effect` on 13 - so no column is being categorically dropped by the
importers, and what is left is per-row fidelity against the printed page, which
is `F1` on this menu. Dropped deliberately, not deferred.

**Taken, 2026-09-06 (PR #774).** Leading with the corrections, because the
premise audit disagreed with this finding in six places and two of them changed
what shipped.

**Two things this finding asked for could not be done as written.** Both were
put to Nate rather than quietly rescoped, and both answers are in the PR:

- **The `catalog.md` sentence named a column that does not exist.** It asked for
  a rule about "a spell or psionic row carrying a level, a cost and no
  `description`", and `psionic_powers` has no `level` column at all - read at
  `db/schema.sql` lines 590-611 on 2026-09-06. That sentence also defined a
  NARROWER stub than the predicate this same finding proposed two paragraphs
  below it, which tests the text alone. Answered **doc matches check**: the
  definition that shipped is the text alone, for both tables, and it says so.
- **The delivery claim was false, and it was the sentence justifying the whole
  posture.** This finding said `book-survey` already requires pasting
  `source-coverage.mjs --remote` into every survey, so the new lines would reach
  a book session without a rule anyone has to remember. What
  `book-survey/reference/SURVEY.md` asks for is the PER-BOOK coverage line; the
  BACKLOG block is five global counts and was never part of it.
  `grep -rln BACKLOG apps/character-creator/docs/surveys/` returned nothing on
  2026-09-06 - zero of ten surveys carry one. Answered by **widening the scope**
  rather than by correcting the note alone: `SURVEY.md` now asks for the BACKLOG
  block beside the coverage line, which is what makes the claim true.

**Four further corrections, none of which changed what shipped:**

- This finding's own opening list of the five signatures dropped the
  `source = 'import'` clause from three of them. Its later paragraph - three of
  five carry the filter, both gear lines do not - is the correct one, and is the
  one the change was built from.
- The `INGESTION-AUDIT` `F5` arithmetic was over-attributed here. That note
  accounts for 13 of the 16 (five Hand to Hand rows and eight non-percentile
  skills), not 16. The "4x" and the narrowed definition are quoted correctly.
- *"Nothing here is inferred"* overreached. The delivery claim above was reasoned
  to rather than run, and so is *"there is no spell whose text is correctly
  absent"* - which stays unsettled, exactly as this finding's own Confidence line
  says, until a book lands a row with no text.
- Every D1 number in this finding was re-run independently and **reproduced
  exactly**: 607/0/63/463, 116/0/65/655, 17 seed and 6 import of the 23, and
  588 imported spells with damage 95, casting_time 43, area_of_effect 13.

**What shipped**, posture unchanged - advisory, log-not-cap, and
`scripts/source-coverage.mjs` still has exactly two exit points, both
`process.exit(0)`:

- two `backlog` entries, `spell text missing` and `psionic text missing`, keyed
  on the text alone with no `source` filter;
- the *Stubs* section of `class-import`'s `catalog.md` now says a spell or
  psionic power with no `description` is a stub, and that the test is the text
  alone;
- `book-survey`'s `reference/SURVEY.md` asks a survey to paste the BACKLOG block
  alongside the per-book coverage line.

**Proved by making it fail.** Two rows carrying no description were inserted
into the local database: both new lines moved 0 to 1, no other backlog line
moved, and deleting the rows returned both to 0. Both proof rows were
`source = 'seed'`, which exercises the absent filter as well. A check that has
only ever printed zero has not been shown to work, and this one now has.

**Observed and deliberately NOT changed, recorded so it is neither lost nor left
as a nameless deferral** (`META-AUDIT` `A16`): the comment above the array this
PR edits, `scripts/source-coverage.mjs` lines 252-257, says the 0/0 skill
signature "counts 21 rows and 20 of them are correct". `INGESTION-AUDIT` `F5`'s
outcome note settled on 5 stubs of 21, which makes 16 correct. They disagree by
four, and neither figure is this finding's. Not filed as a finding; raise it if
it is worth one.

### F23 - an O.C.C. whose skills are ANOTHER O.C.C.'s, and a skill grant that picks CATEGORIES rather than skills

**Filed 2026-09-06, from the `triax` Armored Division batch (PR #777). Not
implemented, per the standing constraint.** The NGR Robot Soldier
(`ngr-robot-soldier`, `apps/character-creator/db/add-ngr-robot-soldier-class.sql`)
shipped with **no `occ_skills`, no `occ_related_skills` and no
`secondary_skills` block at all** - the only published O.C.C. in the catalog in
that state - because both of the ways its book gives it skills are shapes the
app does not have. It parses, validates and composes; it simply grants nothing.

**Two distinct gaps, filed together because one class needs both.**

**(a) Skills inherited from a DIFFERENT occupation, frozen at a level.** Rifts
World Book 5 printed 170 says the robot soldier's range of skills IS the
character's previous O.C.C. training - presumably one of the military O.C.C.s -
held at the experience level it had when the conversion happened, and that those
skills do not improve again until the character reaches that same level as a
robot soldier. A character therefore has two occupations in sequence, not one,
and the second one's ladder gates when the first one's percentages resume
rising. `combineClasses` composes a RACE with an OCCUPATION; there is no slot
for a prior occupation, and `supersedes_race` is not it - that flag is about a
race being replaced, and this is an occupation being carried forward with its
skills frozen.

**(b) A grant of CATEGORIES rather than of skills.** The same page lets the
character select up to three skill categories and makes **every** skill in each
selected category available at a flat 38%, with no bonuses, no per-level gain,
and every task taking 1D4 times longer. `occ_related_skills` picks N skills from
a list of categories; this picks N categories and grants all of their contents
at a fixed percentage. The two are not the same shape and the second cannot be
expressed as the first: writing it as a large `count` would let the player take
38% skills from a category the book did not grant, and writing it as one
category with `only` would need every skill name enumerated and re-enumerated
whenever the catalog grows - which is the objection `class-import`'s reference
already records against `powers_from`.

**What was stored instead.** Only what the book states in its own right: the
combat bonuses, the four saves, the three extra melee attacks at levels 2, 6 and
12, and `starting_money`. The inherited-skills rule, the three skill programs
and the book's fourteen categories with their exclusions are written out in the
class body, so a GM at the table has them and the app does not pretend to.

**Not urgent, and worth saying so.** One class in 177 is affected, its book
gives a GM a workable manual procedure, and the class is playable without it.
The reason to record it is that a reader meeting a skill-less O.C.C. will
reasonably assume the import was incomplete. It was not.

**A caution for whoever takes this.** Do NOT read (b) as an argument for a
`categories_allowed`-style key on skills. `psionics.categories_allowed` narrows
what a pick may come from; this grants the whole category outright at a fixed
percentage and is closer to a second, parallel skill list than to a restriction.
Check what `js/leveling.js` and `js/derive.js` do with a skill carrying no
per-level gain before assuming a flat 38% is expressible either.

#### Proposals, filed 2026-09-07. Two of them, and they are independent.

**F23 had no `Proposal` and no posture until now**, which made it the one
finding on this menu that could not be taken as written - there was nothing
written to take. Twenty-four other findings here carry one. The two halves get
one each because they share nothing but a class: **(b) is small and makes the
class playable; (a) is a question about composition that should be ANSWERED
before anything is built.**

**The lettering is not new.** `F25` already refers to *"`F23(a)`"* in its own
body when distinguishing itself from it, so "take F23(b)" names a thing this
file already talks about.

---

#### F23(b) - skill programs. THE ONE TO TAKE FIRST.

**Proposal: a `skills.skill_programs` block, plus prefix matching in the shared
category matcher.** Printed 170 gives up to THREE skill categories, every skill
in each at a flat **38%**, no bonuses, no per-level gain, tasks taking 1D4 times
longer.

```yaml
skills:
  skill_programs:
    choose: 3
    base: 38
    per_level: 0
    note: "Every skill the chosen category allows, at 38% flat. 1D4x longer."
    categories:
      - "Communications"
      - { name: "Electrical", only: ["Basic Electronics", "Computer Repair"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling", "Prowl"] }
      - { name: "Technical", except_prefix: ["Lore"] }
```

**This finding's own body understates how close this already is**, and the
three reasons are the argument for taking it:

- **The per-category exclusions are ALREADY the catalog's shape.** *"Mechanical:
  All, except mechanical engineer and robot mechanics"* and *"Medical: Paramedic
  and forensics only"* are exactly the `{ name, only }` / `{ name, except }`
  objects `occ_related_skills.categories` has always taken.
- **All twelve of the book's categories are real catalog categories.** Checked
  `--remote` 2026-09-07 against `SELECT category, count(*) FROM skills GROUP BY
  category`: Communications, Domestic, Electrical, Espionage, Mechanical,
  Medical, Military, Physical, Pilot, Rogue, Science and Technical all exist. No
  vocabulary work.
- **The expansion machinery exists.** `catalogFor()`
  (`apps/character-creator/app.js:2012`) already turns a category list into every
  matching catalog skill, through `categoryAllows` - the same matcher the server
  validator uses.

**Expanding at RENDER time rather than storing names is the point, and here it
is correct rather than merely convenient.** The book says *"all the skills under
that category are part of the skill program"*, so a category that gains a skill
SHOULD grant it. That is the opposite of the `powers_from` objection this
finding's body cites - there, enumerating froze a choice the book left open;
here, enumerating would freeze a set the book defined as open-ended.

**THE REAL WORK IS THE ONE THING THIS FINDING NEVER MENTIONED: two of the book's
exclusions are PREFIXES, and `only`/`except` match exact names.** Counted
`--remote` 2026-09-07:

| the book says | catalog rows it means |
|---|---|
| Technical: all **except lore** | **14** rows named `Lore...` |
| Pilot: all except **robot combat** | **14** rows named `Robot Combat...` |

Enumerating twenty-eight names would rot on contact: **this book alone added
eleven `Robot Combat Elite:` rows.** So the grammar needs a prefix form. That is
one change to `categoryAllows()` in `js/parser.js`, which is a single function
with three call sites already sharing it.

**There is a direct precedent, and it is on this menu.** `F16` extended this
exact `only`/`except` grammar to a SECOND block - `psionics.categories_allowed` -
and was taken 2026-08-31 in PR #436, with `categoryAllows()` doing the work at
all three call sites *"so the parse, the two wizard pickers and the server's
grant check cannot disagree about what a category entry means"*. This is the
same move a third time.

**Two names to get right, both of which would silently fail open.** "Tracking"
is stored as `Tracking (people)`, and "wilderness survival" is `Wilderness
Survival` in the **Wilderness** category - so the book's *"Espionage: tracking,
intelligence, and wilderness survival only"* is a deliberate CROSS-CATEGORY
reference, which `class-check` reports as such. An unmatched `only`/`except`
fails OPEN, so getting either wrong grants more than the book does and nothing
says so.

**Posture: a new grant block and a grammar extension to the SHARED matcher.
Expanded at render time, never enumerated. NO NEW GATE** - an unmatched entry
keeps failing open exactly as it does today, and `F16`'s posture (*"no new
gate"*) carries over unchanged. What is being asked for is the ability to say
this, not a check that punishes not saying it.

**Evidence:** printed 170 read from `.cache/books/triax/txt/p170.txt`
(`page_offset: 0`) 2026-09-07 - the 38% line, the 1D4x penalty, the
three-program cap and all twelve category rules; `app.js:2012` for `catalogFor`;
the category, `Lore`, `Robot Combat`, `Tracking (people)` and `Wilderness
Survival` counts all from `--remote` the same day; `F16`'s outcome note quoted
from this file.

**Confidence: high** that the mechanism described is what the code does - every
claim above is a line reference or a `--remote` count. **Medium on the exact
form of the prefix grammar** (`except_prefix:` above is a sketch, not a
decision), and what would raise it is one look at whether any EXISTING class
wants the same thing - if several do, the grammar should be designed for them
rather than for this class.

**Ongoing cost:** one grammar in one shared function, and one block understood
by `parser.js`, the wizard's skills step and the server validator. No migration,
no column. The recurring cost is that `categoryAllows` becomes the third thing
everyone must remember is shared - which it already is.

---

**Taken, 2026-09-07 (PR #794), posture as written - a new grant block and a
grammar extension to the shared matcher, expanded at render time, no new
gate.** The mechanism shipped as proposed. **Seven of the proposal's own
claims did not survive being checked, and this note leads with them**, because
the proposal was written this morning by the session that then implemented it -
which is the conflict `audit-premise-auditor` exists to break, and it broke it.

**1. THE BOOK PRINTS FOURTEEN CATEGORY LINES, NOT TWELVE, AND THE PROPOSAL GOT
BOTH ENDS WRONG.** It dropped `W.P. All Modern` and `Wilderness: All`, and it
LISTED `Rogue` - where printed 170 says *"Rogue: None"*, a refusal rather than
an offer. <!-- claim-ok: quoting the proposal's own list, which this note corrects -->
The shipped block offers **thirteen**: the fourteen printed lines minus Rogue.
F23's own body and the live class's `extraction_notes` both said fourteen all
along; the proposal was the only document on the subject that said twelve.

**2. "No vocabulary work" was false.** The catalog has no `W.P.` category - it
is `Weapon Proficiencies` - so the list needed a translation the proposal said
was unnecessary.

**3. AN UNMATCHED `only` FAILS CLOSED, NOT OPEN, and the proposal's stated risk
was inverted for its own two examples.** It said *"an unmatched `only`/`except`
fails OPEN, so getting either wrong grants more than the book does"*. <!-- claim-ok: quoting the false premise this note corrects -->
`js/parser.js` returns `entry.only.some(...)` - so an `only` naming nothing
admits NOTHING. `functions/api/character-creator/_lib/catalog.js` says so in as
many words. Both names the proposal singled out - `Tracking (people)` and
`Wilderness Survival` - sit in an `only` line, so a typo there grants the
player FEWER skills, silently. That is the worse direction, and it is why
`skill_programs` was added to the restriction-name collectors in this PR.

**4. `categoryAllows` has EIGHT call sites, not three.** The three came from a
smoke comment scoped to the psionics path and was generalised to the whole
function. The eighth is `sheet.js`, reached by a different import path and
named nowhere in the proposal.

**5. `Robot Combat` is 13 rows and this book added 9**, not 14 and 11. The
argument - that a prefix beats enumeration - is untouched; the numbers were
wrong.

**6. THE PROPOSAL'S OWN YAML SKETCH COULD NOT EXPRESS THE PILOT LINE.** *"All,
except pilot robots & power armor and robot combat"* is one exact name AND one
family, and the grammar refused an entry carrying two forms at once. Resolved
by judging the rule **by direction**: `except` with `except_prefix` is legal -
both remove rows, so there is one reading - while anything mixing an admitting
form with an excluding one is still refused, which is what the original rule
was actually about.

**7. `class-check` could not see the block at all.** `crossCategoryRestrictions`
and `restrictionNames` both hard-code `occ_related_skills` and
`secondary_skills`. Two files the ongoing-cost paragraph never named. Both now
walk `skill_programs`, and it earned itself immediately: the first run reported
the Espionage/`Wilderness Survival` cross-category line, which nothing would
have reported before.

**AND ONE THE AUDIT FOUND THAT THE PROPOSAL NEVER CONSIDERED, which would have
shipped the feature doing nothing.** `combineClasses` rebuilds `skills`
wholesale from the RACE's block and carries only what it names explicitly. An
occupation's `skill_programs` would have been dropped on every composition -
and the only class that has one is an O.C.C. The block would have been silently
inert for the class it was built for, with every test passing. There is now a
carry line and a smoke check that fails without it.

**A defect found while implementing, by counting rather than by reading.** The
Espionage program granted TWO skills where the book grants three. `categoryAllows`
bounds a cross-category `only` by requiring the class to ALSO list the skill's
real category - correct for a related-skill pool, which is one grant spanning
many categories, and wrong for a program, which is one category standing alone.
`Wilderness Survival` is a WILDERNESS row, so choosing the Espionage program
without also choosing Wilderness dropped it. Each program is now matched alone
and grants the names its `only` states wherever the catalog files them.

**WHAT SHIPPED.** `skills.skill_programs` - `{ choose, base, per_level, note,
categories }` - expanded at render time through `catalogFor`, never stored as a
name list, because the book says *"all the skills under that category are part
of the skill program"* and a category that gains a skill should grant it.
`only_prefix` and `except_prefix` on any category entry, scoped to the entry's
own category (two `Lore:` rows are filed under Cowboy and a global prefix would
have stripped them from a Cowboy grant). A `program` skill type rendered in its
own box on the sheet - added because the sheet renders by an explicit list of
types, so a type not named there is **saved and invisible**.

**THE ONE PLACE THIS GRANTS MORE THAN THE PAGE, stated rather than buried.**
`W.P. All Modern` ships as the whole `Weapon Proficiencies` category. The
catalog does not mark a W.P. ancient or modern; `CLASS-AUDIT.md` records that
those splits ride in notes, and the Crazy, the Burster and both Elemental
Fusionists all grant the whole category and say so in prose. This follows that
convention rather than inventing a per-row flag, and the block's `note` tells
the player. A `modern`/`ancient` flag on `skills` would fix it properly for all
five classes and is a bigger change than this finding.

**Not done, and not proposed:** no server-side violation was added. The posture
is *no new gate*, and programs are stored under their own type, so nothing
miscounts them as related or secondary picks.

**Evidence:** printed 170 re-read from `.cache/books/triax/txt/p170.txt`
2026-09-07 - all fourteen lines; every count above from `--remote` the same day;
the class read from D1 rather than from its `.sql`. Production composes at 0
errors and 0 warnings, offering thirteen categories with Rogue absent. Smoke
**1734** checks, 23 of them new; the carry check and the prefix check were both
made to FAIL first by reverting their fix.

#### F23(a) - the inherited, frozen occupation. ANSWER A QUESTION BEFORE BUILDING.

**Proposal: run one composition experiment, and propose nothing until it
answers.** This finding says there is *"no slot for a prior occupation"*, and
that `composeClass` takes a race and an occupation is true. But
`compose.js:484` records that **a character with no racial class already
carries their O.C.C. in the `rcc` slot** (`apps/character-creator/js/compose.js`
lines 475-487, read 2026-09-07) - a comment written because attaching something
to `occ` fired for a D-Bee Technical Officer and not for a human one.

So a human NGR Robot Soldier may already be expressible as **Robot Soldier in
the class slot, prior military O.C.C. in the occupation slot** - which is the
book's own model, with no new architecture. `combineClasses` giving the first
slot precedence on physiology even lands correctly here: the robot body's M.D.C.
should be the Robot Soldier's, not the infantryman's.

**The experiment:** compose `ngr-robot-soldier` against two or three NGR military
O.C.C.s and read what comes out - whose skills, whose pools, whose `xp_table`,
and whether `occ_id` and the sheet render sensibly. **If it works**, (a) costs an
`occ_options` ability to gate which occupations are legal, plus documentation -
not a third slot. **If it does not**, the third slot becomes the honest proposal
and the experiment says exactly which part fails.

**`F25` states the opposite and should be read first.** It says *"`F23` needs a
model the app lacks"* while distinguishing itself from this finding. <!-- claim-ok: quoting F25 to argue past it, per the audit-menu rule -->
That sentence is not being rewritten and may well be right; what this proposal
asks is that it be TESTED rather than inherited, because the cost difference
between the two answers is most of this finding.

**THE FREEZING IS RECOMMENDED FOR DECLINE, and separately from the rest.**
*"All skills are frozen at the level of when the soldier underwent the robot
conversion"*, resuming when the robot-soldier level catches up, needs a per-skill
frozen threshold threaded through `js/leveling.js` and `js/derive.js` for one
class, where the book gives a G.M. a one-sentence procedure and the class body
already carries it. **Ongoing cost exceeds the impact.** Recorded so it is not
re-proposed as though nobody had weighed it.

**Posture: answer a question, change nothing yet.** No schema key is being
proposed here and none should be written until the experiment reports.

**Evidence:** `composeClass`'s signature and the `rcc`-slot comment at
`apps/character-creator/js/compose.js:475-487`, read 2026-09-07; printed 170 for
the inheritance and freezing rules; `F25`'s body quoted from this file.

**Confidence: medium, and deliberately so.** The `rcc`-slot comment is a fact
and the reframing follows from it, but **nobody has composed the pairing** - and
this menu's own record is that the thing found while doing the work is usually
not the thing the finding predicted. Running it is what raises this.

**Ongoing cost: none until it answers.** That is the argument for doing it in
this order.

### F24 - a book that ROLLS one of four psychic profiles: the powers fit, the RELATED-SKILL COUNT does not

**Filed 2026-09-06, from the `triax` Gypsy batch (PR #779). Not implemented,
per the standing constraint.** Rifts World Book 5 printed 184-185 gives the
Gypsy - The Gifted O.C.C. (`gypsy-gifted`) a percentile table rolled once at
creation: **01-25 and 26-50 are MAJOR psychics, 51-75 and 76-00 are MASTERS**,
and the four bands differ in tier, in I.S.P. formula, in how many powers are
picked and from which categories, in whether there is a per-level ladder, in
five save bonuses, and in **whether the character gets any O.C.C. Related
Skills at all**.

**Most of that turned out to be expressible, and this finding is smaller than
it started.** Recorded because the first two attempts were wrong and the next
reader will make the same ones.

**`variants` is the obvious home and cannot carry it.** `VARIANT_OVERRIDES`
(`apps/character-creator/js/parser.js:57-65`) is `attribute_dice`,
`attribute_requirements`, the four pool bases, `starting_money`, `bonuses` and
`skill_overrides` - so a variant carries the five saves and **nothing about the
psionics**, and `isp_base` is not reachable either, living inside `psionics`
rather than being a pool base. `CLASS-AUDIT` `S6` already records
*"variants still cannot carry `magic`"* as verified, and `S7` records
*"`variants` cannot override `skills`"* on that file's *Checked and still true*
list. This is the psionics half of the same wall.

**What DOES work is an ability, and the class shipped that way.**
`ABILITY_GRANTS` (`js/parser.js:1443`) is `['bonuses', 'psionics', 'magic']`;
`applyAbilities` folds a chosen ability's block through `mergePsionics`
(`js/parser.js:1544`); and `mergePsionics` returns the ability's block
unchanged when the class states none (`js/parser.js:368`,
`if (!born) return trained;`). So `gypsy-gifted` carries **no class-level
`psionics` block** and each band is a named ability inside a `{ choose: 1 }`,
holding its own `type`, `isp_base`, `powers`, `powers_starting`,
`categories_allowed`, `powers_starting_groups` and `powers_schedule`.

Composed on 2026-09-06, one band at a time, through the real `parseClassMarkdown`
/ `applyAbilities` / `startingGroups`:

| band | type | powers_starting | granted by name | starting groups | schedule |
|---|---|---|---|---|---|
| 01-25 | major | 6 | 0 | 6 from Healing/Sensitive/Physical | 0 |
| 26-50 | major | 8 | 0 | 8 from Healing | 0 |
| 51-75 | master | 10 | 1 | 5/2/2/1 across Healing, Sensitive, Physical, Super | 4 |
| 76-00 | master | 4 | 17 | 4 from Super | 5 |

Each band's saves arrive with it. **That is the tier, the I.S.P. formula, the
counts, the category gates, the split and both Super ladders - correct, per
band, with no over-grant.**

**Three residues, and only the first can produce an illegal character.**

**(a) The O.C.C. Related Skills COUNT is per-band, and nothing carries it.**
The class lists four; a master psionic - **half the table** - gets **none**.
Neither mechanism reaches it: `skills` is deliberately absent from
`VARIANT_OVERRIDES` (the comment there says so in as many words) and is not one
of `ABILITY_GRANTS`' three entries. So the picker offers four related skills to
a character the book gives zero, and a player who rolled 51 or higher can build
a legal-looking character with four skills their gift does not pay for. **This
is the only one of the three that lets the app produce something the book
forbids**, and it is the reason this finding exists rather than being a note.

**(b) "One additional Super psionic power OR two lesser psi-powers" is an
either/or, and a `powers_schedule` entry is an and.** Both master bands print
it at every rung - levels 4/7/10/13 and 2/4/6/9/12. Each entry stores the Super
slot and carries the alternative in its `note`, which the picker shows.

**(c) "Any TWO psionic power categories, limited to healing, sensitive and
physical" is a choose-k-of-the-gate**, and `categories_allowed` is a flat gate.
Band 01-25 names all three and the choice of two is in the ability's own
description.

**Proposal, in three parts, and two of them recommend declining.**

**(a) Let an ability state a related-skill count, as an OVERRIDE, and do NOT
add `skills` to `ABILITY_GRANTS`.** One integer key on an ability definition -
`related_skills_count: 0` - folded in `applyAbilities` onto
`occ_related_skills.count` when the ability is chosen. **Posture: override a
number, not carry a block.** The distinction is the whole proposal: an ability
that could carry a `skills` block could rewrite what the class teaches, which
is the power `VARIANT_OVERRIDES` refuses on purpose and `skill_overrides`
exists to keep narrow. Restating one count is the same size of power as
restating one percentage.

**(b) Decline.** An either/or slot means the picker offering a choice between
"one power from category X" and "two from categories Y, Z, W" - a second shape
of grant, for one class, where the `note` already tells the player and a G.M.
already adjudicates. **Ongoing cost exceeds the impact.**

**(c) Decline.** A choose-k over the category gate is real - the Crazy's
`categories_allowed` history (`F15`, `F16`) is the neighbouring problem - but
this is one band of one class, the over-grant is a breadth the player can
simply not use, and no character is made illegal by it. Revisit only if a
second book prints the same shape.

**Evidence:** the three `js/parser.js` line references above, read 2026-09-06;
the per-band composition table, produced the same day by importing
`parseClassMarkdown`, `applyAbilities` and `startingGroups` from the live
`js/` and running each band through them; `class-check --remote` on the final
draft at 0 errors and 0 warnings. `CLASS-AUDIT` `S6`/`S7` quoted from that file.

**Confidence:** high that the mechanism described is what the code does - every
claim above is a line reference or a run, not an inference. **Medium on part
(a)'s placement**, and what would raise it is one question nobody has asked:
**does the wizard let a player choose special abilities BEFORE it asks for
related skills?** If abilities come later, an ability-borne count arrives after
the picks it is meant to constrain and the override lands too late to help -
which would make the right fix a validator refusal at save time instead, or a
re-ordering of the wizard. Whoever takes this should establish the step order
in `app.js` first and scope from that, not from this paragraph.

**Ongoing cost of (a):** one key in `parser.js`, one line in `KNOWN_KEYS`
(`scripts/class-check-lib.mjs`), one read in the wizard, and a smoke case -
the shape `class-import` already lays out for a modelled key. No migration, no
column, and nothing to keep current afterwards.

**Not urgent.** One class in 184 is affected, the class is playable, and its
`extraction_notes` and its related-skill category note both say in plain words
that four is the major psionic's number and a master takes none. The reason to
record it is that the number is offered by a picker rather than read off a
page, and a picker that offers something is usually taken at its word.

**Taken, 2026-09-07 (PR #789). Part (a) only, as written. (b) and (c) stand
declined on the grounds the proposal gives, and neither was touched.**

**The open question is answered, and it answers the easy way: abilities are
chosen THREE STEPS before skills.** `STEPS` (`apps/character-creator/app.js:32`)
is `['System', 'Race', 'Attributes', 'Occupation', 'Skills', ...]`;
`abilityPicker()` (`app.js:1337`) reads `S.rcc` and is drawn on **Race**, index
1, against **Skills** at index 4. And it BLOCKS rather than merely coming
first: `classBlocker()` (`app.js:1187`) sums what each `choose` group owes and
returns *"Choose N more powers to continue"* (`app.js:1205`) until the picks
are made. So an ability-borne count is in place before the picker it
constrains is ever drawn, and the validator-refusal alternative this finding's
confidence paragraph offered as the fallback is not needed. **Confidence on
(a)'s placement raised from medium to high.**

**What shipped is the proposal verbatim.** An ability definition may carry
`related_skills_count`, and `applyAbilities` (`js/parser.js:1561`) folds it
onto `occ_related_skills.count` when that ability is chosen. It overrides ONE
NUMBER: `skills` is still not in `ABILITY_GRANTS`, an ability still cannot
carry a skills block, and the fold cannot add a skill, change a category or
touch what the class teaches. Copy-on-write, because `composeClass` re-runs
`applyAbilities` on every recompose and writing through `out.skills` would
mutate the caller's class object. Validated as a **non-negative INTEGER**
rather than a truthy number, since zero is the entire point of it.

**Two of the proposal's predicted costs were wrong, both in the cheap
direction.** No `KNOWN_KEYS` line was needed - that list is filtered against
`Object.keys(data)` (`scripts/class-check-lib.mjs:81`), so it holds TOP-LEVEL
keys and this one is nested inside a `special_abilities` entry. And no wizard
read was needed either: every call site already reads the composed class, so
the single fold reached all of them by itself.

**IT WENT ONE STEP PAST THE PROPOSAL, deliberately - this is the part to
disagree with if any of it.** The proposal scopes to `applyAbilities`. But
`functions/api/character-creator/_lib/validate-character.js` computed
`relatedAllowance(cls, level)` from the class as STORED, so the wizard would
have offered zero while that endpoint still accepted four. This finding's
stated reason for existing is that (a) *"lets the app produce something the
book forbids"* - and fixing only the client would have left exactly that
reachable through the API. `abilities` was already a parameter of
`validateCharacter`, so the change is one call (`validate-character.js:190`),
narrowed to the allowance alone; every other check in that file still reads
`cls` untouched. It is the same client/server disagreement `RETRO-AUDIT` `R18`
was filed about, in the file whose own comment says so.

**The data.** `fix-gypsy-gifted-related-skill-count.sql` sets
`related_skills_count: 0` on both master bands and rewrites the three passages
that told the player to take none by hand. Applied `--remote` before this PR;
production composes **4 / 4 / 0 / 0** across the four bands and the class
parses at 0 errors, 0 warnings. No saved character was affected -
`gypsy-gifted` had none.

**THE SCHEDULED PICKS ARE NOT DROPPED, and this is the one thing printed 185
leaves genuinely ambiguous.** The line reads *"O.C.C. Related Skills: None if
a master psionic. Select four 'other' skills from any of the available skill
categories if a major psionic. Plus select one additional skill at levels
three, six, nine, and twelve."* That third sentence sits after BOTH branches
rather than inside the major-psionic clause, so it is read as applying to
both, and `schedule` is untouched. Recorded rather than decided silently: a
reader who takes *"None if a master psionic"* to govern the whole entry would
zero the schedule too, and would not be obviously wrong.

**One defect found in this PR's own first draft, and the readback is what
caught it.** The two inserting `UPDATE`s were guarded on
`instr(markdown, <anchor>) > 0`, where the anchor is the band's `- name:` line
- which the replacement APPENDS to rather than consumes, so the guard was
still true afterwards. Applied twice to `--local`, the readback returned four
zero-counts instead of two. The guard now also requires the RESULT to be
absent. **A guard on text that survives its own replacement is not a guard**,
and it was caught only because the readback COUNTS rather than testing for
presence.

**And the first readback was wrong the other way.** It counted the bare string
`related_skills_count: 0` and wanted 2 - but the note this script rewrites
QUOTES that string in its prose, so a correct result contains three. It counts
the indented key now. Both mistakes are one shape: a check written against
what the author meant instead of against what the file would actually hold.

### F25 - a class whose book defines it AS another class, and nothing records that the two must stay identical

**Filed 2026-09-06, from the `triax` Euro-Juicer batch (PR #780). Not
implemented, per the standing constraint.** Rifts World Book 5 printed 175
gives the Euro-Juicer O.C.C. (`euro-juicer`) no mechanics of its own. Its entry
says, in full: *"The same creation considerations, conditions, skills, bonuses
and penalties as described in the Rifts RPG are applicable to the NGR/European
Juicer - create the character as usual."* There is no attribute line, no skill
list, no bonus list, no equipment and no money on the page.

**It is a playable class by both of this book's authorities** - on the O.C.C.
roster on printed 156, and with its own experience ladder on printed 224 - so
it was imported rather than left out. **And that ladder is the Juicer's own,
reprinted**: 0-2,140 / 2,141-4,280 / 4,281-8,560 through to 341,601-401,700,
read off a 190 dpi render of printed 224 on 2026-09-06. The one number the
entry could have differed on does not.

**So `euro-juicer` is a hand copy of `juicer`, and the copy was verified rather
than assumed.** Both markdowns were parsed through `parseClassMarkdown` and
compared block by block on 2026-09-06: `hit_points_base`, `sdc_base`,
`starting_money`, `bonuses`, `special_abilities` and `equipment_starting` are
byte-identical; `occ_related_skills` matches on count, categories and schedule,
`secondary_skills` matches entirely, and `race_restrictions.only` matches. The
only intended divergences are two language entries and two added restrictions,
all of them documented in the row's `extraction_notes`. **The comparison caught
one unintended one** - an abbreviated IRMSS description - which is the argument
for running it rather than trusting the transcription.

**The gap is that nothing holds that state.** No field says these two rows are
meant to be identical, and no check compares them. A correction to `juicer` -
an edition update, a bonus fix, a renamed gear slug, a skill the catalog
renames - lands on one row and not the other, silently, and the divergence is
invisible to `class-check`, to the smoke suite and to `regression.mjs`, all of
which validate each class on its own terms. `repo-vs-live.mjs` compares the
repo against production, not one class against another.

**This is NOT `F23`, and the difference is worth stating.** `F23(a)` is the NGR
Robot Soldier inheriting a *previous* occupation's skills **frozen at the level
the character had when the conversion happened** - two occupations in sequence,
where the app has one. This class is not in sequence with anything and nothing
is frozen: it simply IS the Juicer, permanently, and the app expressed it fine.
`F23` needs a model the app lacks; this needs a **link the app lacks a place to
write down**. Implementing either does nothing for the other.

**Proposal, and the cheap half is the one to take.**

**(a) A regression invariant, not a schema key. Posture: assert, do not model.**
`test/regression.mjs` already parses every published class and asserts
invariants across the corpus. Add one: a class whose `extraction_notes` declare
it a copy of another names that class, and the two agree on the blocks the note
says are copied. The declaration needs a machine-readable form - a single line
such as `copy_of: juicer` alongside a list of the blocks that are NOT copied -
which is the whole of the schema change, and it is a string nothing else reads.
**Where it lands is the open question**, since `copy_of` on the class would be
an `UNMODELLED` key by `class-check`'s own definition (nothing downstream acts
on it) and that report exists to stop exactly this. Putting it in
`extraction_notes` in a parseable form avoids that and is uglier. Whoever takes
this should decide that first.

**(b) Decline a general inheritance mechanism.** A class that composes from
another - `extends: juicer`, with an override list - is a much larger change:
it touches composition, the wizard, the sheet, the validator and every tool
that reads a class as a self-contained document, and it would be built for
**one** row. The catalog holds twelve Juicers and eleven of them state their
own mechanics; this is the only class in 185 that states none. **Ongoing cost
exceeds the impact** until a second book prints the same shape.

**Evidence:** printed 175 quoted in full above, from the OCR cache and checked
against the page; the printed 224 ladder from a 190 dpi render, 2026-09-06; the
block-by-block parse comparison of the two markdowns, same day;
`class-check --remote` on the draft at 0 errors and 0 warnings; the twelve
Juicer rows counted from production with `q.mjs --remote` the same day.

**Confidence:** high on the facts - the book's sentence is quoted, the ladder
was read off a render, and the comparison was run rather than reasoned to.
**Medium on (a) being worth building at all**, and what would raise it is
evidence of the failure actually happening: nobody has yet corrected `juicer`
since this row landed, so the drift this finding predicts has a sample size of
zero. If the next Juicer correction reaches both rows because a human
remembered, that is an argument for declining (a) too.

**Ongoing cost of (a):** one invariant in a suite that already runs on every
PR, plus one line per copied class - and there is one such class. Near zero,
which is most of why it is the half worth taking.

**Meanwhile, the mitigation is written down where someone will meet it.** The
`euro-juicer` row's `extraction_notes` and its GM Notes both say the blocks are
a copy taken on 2026-09-06 and that a correction to `juicer` must be applied
here too, and the `juicer` row's own Lore already named the Euro-Juicer as a
related O.C.C. before this import existed.

**Taken, 2026-09-07 (PR #785).** Posture honoured: **assert, do not model.**
(a) is taken as a regression invariant plus a declaration key that nothing at
runtime reads; (b) is declined, as the finding asks.

**This finding was wrong about its own size in three ways, and every one of
them made it BIGGER.** The premise audit is led with, per the protocol.

**1. "It would be built for ONE row" — it is eleven pairs.** The ongoing-cost
line said *"one line per copied class - and there is one such class."* Wrong.
`ley-line-rifter` declares itself a copy of `ley-line-walker` in its own
`extraction_notes`, and RUE printed 118 says so outright: *"Ley Line Rifter
Stats. Same as the Ley Line Walker."* And the ten elemental Warlocks come from a
single book entry - Conversion Book One printed 66-71, split into ten rows by
`RETRO-AUDIT` `R3` - and are byte-identical outside `magic`, plus
`attribute_requirements` and `ppe_base` for the two-Force six. Eleven pairs are
now declared: euro-juicer, ley-line-rifter, and nine Warlocks against
`warlock-air`.

**2. "The drift this finding predicts has a sample size of zero" — it was three,
in one pair, all shipped.** The Confidence line rested on this, and it was the
first thing the audit falsified. Found in `ley-line-rifter` / `ley-line-walker`:

| what | fixed in |
|---|---|
| the Rifter had **none** of the seven related-skill category bonuses the Walker has, because `fix-pre-rue-class-audit.sql` applied them to the Walker and names four classes, not the Rifter | PR #783 |
| the Rifter was missing two equipment entries the book grants it - `pen or pencil`, `note or sketch pad` | PR #784 |
| the **Walker's** `small-sack` was a fixed `qty: 4` against RUE's printed *"1D4 small sacks"*, where the Rifter was right | PR #784 |

The third is the one worth carrying forward: **the copy was right and the
original was wrong.** Do not assume the direction of a fix on a copy pair before
reading the page.

**3. The proposal's own open question is answered, and not the way it guessed.**
F25 said `copy_of` *"would be an `UNMODELLED` key by `class-check`'s own
definition... and that report exists to stop exactly this."* Checked: `class-check`
reports UNMODELLED and does **not** block - `scripts/class-check.mjs` says so in
its own header, *"a decision to make, not a defect"*, and its exit code is errors
and pre-flight failures only. The suite that WOULD fail is smoke, via
`no shipped class reports an unmodelled key`
(`test/checks/class-check-tool.mjs`). **But that check reads only
`add-*-class.sql` files**, and these declarations are applied by a separate data
script, so it never sees them. So the `KNOWN_KEYS` entry added here is
**defensive rather than load-bearing today**: it stops the false alarm the next
time a class ships with `copy_of` in its own `add-` script, which is the
`psionics_allowed` / `xp_table` failure that file already records twice.

**What holds.** The load-bearing claim - that **no cross-class equality
invariant exists anywhere** - held under checking, across `regression.mjs`,
`smoke.mjs`, `class-check.mjs` and `repo-vs-live.mjs`. The block-by-block copy
claim for euro-juicer re-derived exactly. The F23 distinction holds. Two of the
four "silent" examples turn out to be **already covered** - a renamed gear slug
or skill goes red in `regression.mjs` - so what is actually invisible is
narrower and sharper than the finding said: a **value** correction. Which is
precisely what all three real divergences were.

**What was built.**

- `copy_of: { class: "<id>", except: [<top-level keys>] }` on eleven rows,
  applied by `db/zzzzzz-f25-copy-of-declarations.sql`. **The except lists are
  DERIVED from the live rows rather than typed**, so they cannot disagree with
  the data on the day they land.
- `copy_of` added to `KNOWN_KEYS` in `scripts/class-check-lib.mjs`.
- Two checks in `test/regression.mjs`: every declared pair matches outside its
  except list, and a floor asserting the sweep found the pairs at all. They run
  against a database **rebuilt from the repo**, which is the question worth
  asking.

**`except` rather than an allowlist, deliberately.** A block added to one row
later and not the other fails by DEFAULT; an allowlist would silently not cover
it. The invariant also refuses a **stale except** - one naming a key the two
rows now agree on - because that is exactly how a divergence gets re-hidden
after someone fixes it.

**The check was proved to FAIL before it was trusted.** A temporary script
injected two defects into a rebuilt database - a changed `starting_money` on
`warlock-earth`, and a stale `except` on `warlock-fire` - and the run went red
naming both:

```
FAIL every declared copy pair still matches outside its except list
  warlock-earth vs warlock-air: starting_money differs;
  warlock-fire vs warlock-air: except lists "occ_group", but the two agree on it
```

The script was deleted and the suite went green again. A check that has only
ever passed proves nothing.

**What this deliberately does NOT cover, stated so the gap is not mistaken for
coverage.** `euro-juicer` excepts `skills`, because its two language entries
differ by design - so a skills-block divergence is **not** caught for that pair,
which is the very shape the Rifter's category bonuses took. `ley-line-rifter`
excepts the seven blocks RUE gives it in its own right. Nine Warlock pairs
compare their skills in full.

**One divergence found and left alone**, because it could not be settled: the
Walker's `Language: Other` choice group carries `per_level: 5` and the Rifter's
does not. Which side is right turns on what `per_level` means on a **choice
group** as opposed to a named skill, and that was not established. It is named at
`db/zzzzzz-ley-line-walker-rifter-equipment.sql`:34-35 (grepped for
`per_level`, 2026-09-07), and `grep -c per_level` on
`db/zzzzzz-f25-copy-of-declarations.sql` returns 0 - it is in no except list,
because this pair excepts `skills` wholesale.

### F26 — one spell, two traditions, two costs, and one row

**Taken, 2026-09-08 (PR pending), as the smaller option** - `spells.same_spell_as`
plus a checker, not the `spell_traditions` join table. Both questions this
finding left "to settle when taken" are settled, and **three of its own factual
claims did not survive being checked**, which is recorded here because the
finding is the record and a measurement is not rewritten.

**Direction: the retelling points at the established row.** `Ocean: Whirlpool`
names `Water: Whirlpool`. This finding noted that *"the canonical one is the
unprefixed one"* does not hold; *"the newer import points at what was already
there"* does, it matches F25's `copy_of` direction, and it means a future book
adds its own rows and touches nothing existing.

**The description is compared by a floor, not exactly** - shared vocabulary of
at least 0.35 and a length ratio under 3. The six linked pairs score 0.53 to
0.69 and run 1.12 to 2.03 times each other, so an exact check fails on day one
and no check misses the gutting this is for. Proved by feeding it a gutted, an
emptied and a swapped description.

**FIRST CORRECTION: nine pairs became six.** This finding lists nine and says
they are the same spell, on the strength of reading ONE of them - Whirlpool -
line by line. Ten rows actually share a name across the prefixes, and reading
all ten splits them in half. **Four are different spells wearing one name** and
are deliberately not linked: `Ocean: Calm Waters` covers a mile per level for an
hour where `Water: Calm Waters` covers eighty feet for thirty minutes;
`Ride the Waves` carries two passengers at 40 mph on one side and is self-only
on the other; `Float on Water` and `Water Seal` differ on range and duration.
A mile against eighty feet is not a transcription difference. **Linking them
would have made the checker assert something false on its first run.**

**SECOND CORRECTION: Sonic Blast is not a retelling at all**, and this one would
have created a wrong link rather than a failing check. This finding says Sonic
Blast is *"a bare Book of Magic row at level 7 for 25 P.P.E. and a dolphin spell
for 15"*. The catalog holds THREE rows: `Sonic Blast` (Book of Magic p.119, 20
foot radius, 4D6 M.D.), `Air: Sonic Blast` (Book of Magic p.63, same radius,
same damage), and `Dolphin: Sonic Blast` (Underseas p.71), which does 1D6 M.D.
per level at 100 feet per level and passes a third of its damage through light
armour to the pilot. The dolphin spell is a different spell. It gets no link.
**The other two look like a genuine duplicate WITHIN the Book of Magic**, filed
separately as F29.

**THIRD CORRECTION: the title over-generalises.** *"Two costs"* is true of seven
of the nine pairs listed here and false for two of them - this finding's own
table shows `Sense Direction Underwater` at 4 P.P.E. on both sides and
`Speak Underwater` at 10 on both. The first version of the checker required a
linked pair to differ on level or cost and failed immediately on those two. **A
link asserts THE SAME SPELL; a price difference is the common case and never the
requirement.**

**What the comparison actually does**, since "matching on range, duration,
saving_throw, area_of_effect" as written here rejects every pair: it compares
the NUMBERS, ignoring parentheses and normalising number words. Both were forced
by real rows - `Ocean: Whirlpool` gives its radius as 36.5 m and `Water:` as
36.6, both converting 120 feet, and one book prints "Ten minutes" where the
other prints "10 minutes". Comparing those rejects a pair this finding itself
verified off the page.

**Nothing reads the column at runtime** - the checker reads it. Twelve smoke
checks pin the comparison against fixtures taken from the real rows; three
regression checks run it over a clean rebuild. All three were proved by linking
a divergent pair on purpose and watching two of them fail with
`range: 1 vs 80; duration: 1 vs 30; description: only 0.22 shared vocabulary`.

`spells` is keyed `name TEXT NOT NULL UNIQUE` and carries a single `level` and a
single `ppe`. That is right for a catalog where a spell belongs to one
tradition, and Rifts is not that catalog.

**The case.** Rifts World Book 7: Underseas prints an **Ocean Magic** list on
printed 63, 41 spells, learnable by the Ocean Wizard, the Sea Druid and the
Whale Singer. **Nine of those 41 are spells the catalog already holds as Water
Warlock invocations**, imported from the Book of Magic:

```
                                catalog Water:  Underseas ocean
  Change Current                  L2 /  8 PPE     ?  / 15 PPE
  Communicate with Sea Creature   L4 / 12 PPE     ?  / 10 PPE
  Float on Water                  L1 /  4 PPE     ?  /  3 PPE
  Impervious to Ocean Depths      L3 / 12 PPE     ?  / 75 PPE
  Ride the Waves                  L2 /  7 PPE     ?  / 10 PPE
  Sense Direction Underwater      L1 /  4 PPE     ?  /  4 PPE
  Speak Underwater                L4 / 10 PPE     ?  / 10 PPE
  Water Seal                      L2 /  8 PPE     ?  / 10 PPE
  Whirlpool                       L5 / 40 PPE     L9 / 50 PPE
```

**They are the same spell, and that was checked rather than assumed.**
`Water: Whirlpool` was read out of production and compared against printed 70
line by line: same 120 foot radius, same 500 foot casting range, same ten feet
per melee round drag, same 20 foot centre, same drowning percentages. The Book
of Magic publishes it as a level 5 warlock invocation costing 40 P.P.E.;
Underseas publishes it as a level 9 ocean spell costing 50.

The same pattern runs through Dolphin Magic: `Sonic Blast` is a bare Book of
Magic row at level 7 for 25 P.P.E. and a dolphin spell for 15.

**What the app cannot express.** The sheet's use button spends `spells.ppe`, and
a class's `magic.spells_from` names rows by `name`. So a single row can serve
one tradition's price or the other's, never both. There is no per-tradition
override anywhere: not on the spell, not on the class's magic block, not on the
grant.

**What the import did instead.** The 41 ocean spells ship under an `Ocean:`
prefix and the 10 dolphin spells under `Dolphin:`, following the `Water:` /
`Fire:` / `Air:` / `Earth:` families the catalog already uses for a scoped
tradition. Each colliding row carries the warlock reading in `variant_note`, so
the disagreement is on the record. **This works today and the classes are
correct** — an Ocean Wizard granted `Ocean: Whirlpool` spends 50, a Water
Warlock granted `Water: Whirlpool` spends 40.

**So why this is filed at all**, given nothing is broken: the cost is
duplication that grows per book. Nine near-identical rows now, plus one, and
Lemuria and the other undersea books are in the queue behind this one. Two rows
holding the same description drift the moment either is corrected, and nothing
would say so — `drift-check` compares a row to its cited page, and both rows
cite pages that agree with them.

**Proposal, and it is deliberately the smaller of two.** Add
`spells.same_spell_as TEXT` — a `name` reference to the row this one is a
retelling of — plus a smoke check asserting that two rows so linked keep
matching on `range`, `duration`, `saving_throw`, `area_of_effect` and
`description`, and differ only on `level`, `ppe` and `source_book`. That is the
`copy_of` mechanism F25 built for classes, applied to spells, and it turns the
duplication from a silent liability into a pinned one. It changes no runtime
behaviour and no character.

The alternative — a `spell_traditions` join table with a per-tradition level and
cost, and a single canonical spell row — is the modelling-correct answer and is
much larger: it moves how every class's `magic` block resolves a spell, touches
the wizard, the sheet and the server validator, and rewrites 231 existing
warlock rows whose prefix currently carries the tradition. Not worth it for
ten rows, and the prefix convention is doing that job adequately.

Two things to settle when this is taken, not before:

- **Which direction the link points.** The warlock rows came first and are more
  numerous; the ocean rows are the retelling. But `Sonic Blast` has no prefix at
  all, so "the canonical one is the unprefixed one" is not a rule that holds.
- **Whether the check should compare `description`.** The two are paraphrases of
  two different printings and will not be byte-identical. Comparing them exactly
  would fail on day one; not comparing them misses the drift the finding is
  about. A length-and-keyword floor may be the honest middle.

### F27 - `class-check` does not validate skill names inside an MOS option, and they fail silently

**Taken, 2026-09-08 (PR pending).** Both of the questions this finding left
"to settle when taken" are settled, and the second was settled by MEASURING
rather than by agreeing with the guess written here.

**Stub SQL does NOT fire for an MOS name**, as this finding leaned toward. A
missing name is now reported on its own `mos skills` line that says it was
deliberately not stubbed and to check the spelling first. The reasoning is the
one written below - a stub for a typo is worse than no stub, because the class
then resolves against a permanent catalog row spelled the wrong way. That is
also why `mosSkills` is its own key on `crossReference` rather than folded into
`skills`: the caller stubs `missing.skills`, so the split is what makes the
no-stubbing structural rather than a rule someone has to remember.

**`only`/`except` inside an MOS option WERE in the same blind spot**, and this
finding was right to refuse to assume it. Proved the way F27 itself was proved:
a name no skill row has, placed in an MOS option's `categories[].only`, and
`class-check` reporting `restrictions ok`. It is the worse direction of the two
- an unmatched `only` fails CLOSED, so the option would grant the player
nothing at all. `restrictionNames` now walks them, tagged `<option>/<category>`
so the report says which option.

**One premise here is stale and is left standing as the record.** This finding
describes `crossReference` as shared with the Confirm endpoint. It is not, any
more: `_lib/catalog.js` is imported only by `scripts/class-check.mjs` and the
test suite, and no endpoint under `functions/api/character-creator/` calls it.
That makes the fix narrower than the finding claims - it reaches the CLI check
and nothing else - and it does not change whether the fix is right.

**The sweep it enables found nothing**, which is the honest result and is
reported as such. All six MOS classes - Coalition Technical Officer, Merc
Soldier, Robot Pilot, Demon-Goblin, Monk, Navy Seaman - were re-checked through
the fixed code and every one reads `mos skills ok` and `restrictions ok`. No
typo was hiding in the catalog. The value is preventive: the next one is
caught, and the ongoing cost below - one manual sweep per MOS class - is gone.

`class-check` reports every skill an `occ_skills` entry names that the catalog
does not hold, and prints stub SQL for it. **It does not look inside
`skills.mos.options[].skills` at all.** A misspelled skill name there passes as
`skills ok`.

**Proved by making the check fail first**, with the SAME bogus name in two
positions on one draft (`navy-seaman.md`, 2026-09-07, `--remote`):

```
A  "Zzz Not A Real Skill" inside an MOS option's choice group
     skills         ok
     class-check: ready - 0 errors, 0 warnings

B  "Zzz Not A Real Skill" as a plain occ_skills entry
     skills         1 row missing
         Zzz Not A Real Skill
     INSERT OR IGNORE INTO skills (name, category, base, per_level, ...)
```

Same name, same file, same command. Only B is seen.

**Why it matters more than a typo usually would.** An MOS option's skills are
appended to `occ_skills` at compose time, so a name that matches nothing there
behaves exactly like an unmatched name anywhere else - the pick is offered and
resolves to nothing. But the MOS is also where the names are *least* likely to
be right: an MOS option is a second, nested skill list, often transcribed from a
different part of a book, and this catalog renames freely enough that
`Surveillance Systems`, `Tracking`, `Jet Pack`, `Jet Fighter` and
`Chemistry: Analytical` are all WRONG as printed and had to be resolved by hand
against production.

**How exposed the catalog is today**, counted 2026-09-07 rather than estimated:
`navy-seaman` alone carries **46 skill names across nine MOS options**, none of
which `class-check` looked at. `coalition-technical-officer` and the
merc-soldier / robot-pilot MOS fix carry more.

**What caught it here was a manual sweep**, which is not a mechanism: every one
of those 46 names was pulled out with a regex and checked against a dump of
`SELECT name FROM skills`. 45 resolved; the one that did not
(`Chemistry - Analytical`) turned out to be the shell pipe mangling an em-dash
rather than a real mismatch, confirmed by comparing code points. That is the
right answer arrived at by hand, twice, and nothing repeats it on the next MOS
class.

**Proposal: walk the MOS options in the same pass that walks `occ_skills`.**
`class-check-lib.mjs` already collects skill names from a parsed class; the MOS
options are on the same parsed object, at `skills.mos.options[].skills`, in the
same shape - `parser.js` validates both through `validateSkillEntries`, which is
the evidence they can be collected the same way. The fix is to include them in
the collection, not to write a second collector.

Two things to settle when this is taken, not before:

- **Whether the stub SQL should fire for an MOS name.** A missing `occ_skills`
  row gets an `INSERT OR IGNORE` stub. That is right for a skill the book
  defines and the catalog lacks; it is wrong for a typo, and an MOS name is more
  likely to be the second. Reporting without stubbing may be the better default
  here.
- **Whether `only`/`except`/`only_prefix` inside an MOS option are checked too.**
  This finding measured `from` lists and named entries. The restriction keys are
  the same shape and are probably in the same blind spot, but that was not
  tested and should not be assumed.

**Ongoing cost of not taking it: one manual sweep per MOS class**, and a silent
wrong grant whenever somebody forgets.

### F28 - the coverage ledger checks five catalogs and there are six, so no vessel's citation is verified

**Taken, 2026-09-08 (PR pending) - filed and taken in one change**, on the
`SHIP-PR-AUDIT` precedent, because the fix is one line and holding it as a
proposal would have cost more to write than to make.

**The case.** `scripts/source-coverage.mjs` is the ledger that answers "can this
row be traced back to the page it cites". It builds a coverage row for
`imported_classes` and then for four catalogs by name:

```js
...['gear', 'skills', 'spells', 'psionic_powers'].map((t) => ({
```

`vehicles` is not in that list, and was never in it. So **105 vessels - 55 from
Triax and 50 from Underseas - carry a `source_book` that nothing verifies**,
while every other catalog table gets a bucket count, a per-book roll-up and an
offender list.

**Why it was easy to miss, which is the part worth keeping.** `vehicles` DOES
appear in this file - once, near the bottom, in the `priceless` block that
counts rows with no cost. So a grep for `vehicle` in the coverage script returns
a hit and the table looks covered. It is present in the report and absent from
the part of the report that checks anything.

**How long it stood.** Since migration 048 created the table. The Triax import
put 55 rows in it and closed; the Underseas import put 50 more in and closed;
neither noticed, and both PR bodies stated - correctly - that
`source-coverage.mjs` was the only consumer of these tables, which read as
coverage and was not.

**What it does NOT mean.** No citation is known to be wrong. Every one of the
105 was written by a generator that stamped the book title and the printed page
range from the same dict the row came from, and all 105 have a non-NULL
`source_book`. The defect is that nothing checks them - and per this report's
own standing warning, traceable means CHECKABLE and never correct.

**The fix.** Add `'vehicles'` to the list. The table already has the `name` and
`source_book` columns the other four are read through, so it needs no special
handling and no schema change; that it needed none is why the omission is a
one-word fix rather than a feature.

**What it changes in the report:** two new rows, `vehicles` in the COVERAGE
table and vessel counts folded into BY BOOK for `triax` and `underseas`. It
gates nothing - the report is advisory by design and says so.

### F29 - `Air: Sonic Blast` and `Sonic Blast` look like one spell twice, inside the Book of Magic

**Resolved 2026-09-08 (PR pending), and it is NOT a defect.** Filed hours
earlier in this same menu as a suspected duplicate, on the strength of two rows
sharing a range and a damage figure. Both pages were then read, and the
suspicion below - *"one of the two pages is being read wrong"* - is wrong:

```
  printed 63   under "Level Five: Air"           P.P.E.: Fifteen
  printed 119  under "Level Seven (Invocations)"  P.P.E.: Twenty-Five
```

**The two entries are word for word identical apart from that one line** -
same 20 foot radius, same 4D6 M.D., same Instant duration, same Standard save,
same deafening penalties, same 01-40% knockdown. The Book of Magic publishes
one spell in two of its lists, at two levels and two prices, and **both stored
rows agree with the page they cite**: `Air: Sonic Blast` holds level 5 and 15
P.P.E., `Sonic Blast` holds level 7 and 25.

**So the merge this finding implies would have been a mistake** - it would have
deleted a correct row and changed what one of two kinds of caster spends. What
this actually is, is **F26's own shape occurring inside a single book** rather
than across two, which is why the answer is F26's mechanism: the pair is linked
with `same_spell_as`, so `regression.mjs` compares the two rows to each other on
every clean rebuild and reports either being gutted or edited away from the
other. Direction follows migration 049 as closely as a within-book pair can -
there is no newer import, both rows arrived together, so the tradition-scoped
row points at the general Invocation list.

**`Dolphin: Sonic Blast` is a third row and stays unlinked**, being a genuinely
different spell that shares the name - 1D6 M.D. per level at 100 feet per level,
passing a third of its damage through light armour. The script asserts that it
has no link, so a later sweep matching on name cannot quietly acquire one.

**Worth keeping from this one:** the finding was filed from a column comparison
and resolved by reading the pages, and those gave opposite answers. Two rows
agreeing on range and damage looked like duplication; the section headings four
lines above each entry are what say it is not.

**Filed 2026-09-08**, found while taking F26 and deliberately not fixed there.

`Sonic Blast` (Rifts Book of Magic p.119) and `Air: Sonic Blast` (Rifts Book of
Magic p.63) carry the same range - a 20 foot radius - and the same damage, 4D6
M.D. They differ on level and cost: p.119 is level 7 for 25 P.P.E., p.63 is
level 5 for 15.

**This is NOT the F26 shape and must not be closed with an F26 link.** F26 is
about one spell two BOOKS publish at two prices, where both rows are correct and
each serves its own tradition. This is one book against itself, and one of the
two pages is being read wrong, or the book prints the spell twice on purpose for
two traditions and the unprefixed row is the one that should carry a prefix.
Which of those it is decides whether the answer is a correction, a merge with a
redirect, or a rename - and it cannot be decided without reading printed 63 and
printed 119.

**Why it was left alone in the F26 PR:** it is another book's rows, and every
outcome changes what a Book of Magic caster spends. `Dolphin: Sonic Blast` is
unaffected either way - it is a third, genuinely different spell.

### F30 - a cached page can be WELDED across the gutter, and nothing detects it

**Filed 2026-09-08**, during the `free-quebec` survey.

`scripts/read-columns.py` reads a text-layer page by bucketing `pymupdf`
BLOCKS into columns and walking each column top to bottom. That is the right
algorithm and it works on 192 of this book's 194 pages. It cannot help on the
other two, because on those `pymupdf` returned **one block whose own lines
alternate between the left and right columns** - the damage is inside the unit
the reader is sorting, so no bucketing fixes it.

The cache gives no sign. `p043.txt` and `p059.txt` are normal-length files of
ordinary sentences; the only tell is that consecutive lines do not follow one
another, which a reader notices only if the content happens to be discontinuous
enough to jar.

**What it costs, on this book:**

| cache page | printed | welded content |
|---|---|---|
| `p043` | 42 | the Reloader O.C.C.'s `Money:` line - **a `starting_money` field, which no test checks** |
| `p059` | 58 | the Glitter Boy Transport's M.D.C.-by-location footnote markers |

The first is the Juicer Uprising failure shape exactly: PR #280 fixed two
`starting_money` figures that shipped wrong because a reading stopped at a page
break, and `book-survey` §3 still leads with it. A weld is the same class of
error arriving by a different route, and `class-check --field-sources` does not
catch it either - it prints the cache lines a field was drawn from, and here the
cache line itself is wrong.

**Affected rows:** none yet on this book, because the survey found it first and
both pages were de-welded by hand before extraction. That is luck rather than
process - the detection was a session noticing that a paragraph did not follow
itself.

**How to detect it, and it is cheap.** A block is welded when the x-positions of
its own lines straddle the gutter. Measured over all 194 pages of this book in
under a second:

```python
d = page.get_text('dict', clip=block_rect)
lefts = [line['bbox'][0] for blk in d['blocks'] for line in blk['lines'] if line['spans']]
welded = (max(lefts) - min(lefts)) > page.rect.width * 0.30
```

**Proposed change:** `scripts/ocr-book.py` runs that test per page while it is
already walking every page, and records the welded page numbers in the cache
manifest - a `welded_pages: []` key beside `text_layer` and `page_offset`. Then
`class-check --field-sources` and `drift-check`'s citation check both have a
cheap thing to warn on: **this field was drawn from a page whose text does not
read in order.** A key that is an empty list on a clean book is the point; it is
the books where it is NOT empty that need the warning.

This is worth doing for the FIVE books still to be surveyed in this batch, not
just for this one. `new-west`, `spirit-west` and `mystic-russia` are text-layer
books cached by the same script and have never been checked for it, and the
other text-layer caches in the registry have not either.

**What this finding is NOT.** A page that breaks mid-word across the gutter is
normal typesetting, not a weld - printed 45 of this book reads `...weapon tech-`
at the foot of one column and `nology. Well,...` at the head of the next, and it
is correct. That page was misfiled as damaged once during this survey before the
geometry was checked, and a detector keyed on prose discontinuity rather than on
geometry would flag it and every page like it. **The test above is geometric on
purpose.**

**Taken, 2026-09-08 (PR #830).** Detect and warn, as proposed. Nothing repairs
anything, no exit code moves, no cached page is rewritten.

**THE SNIPPET IN THIS FINDING FLAGS THE PAGE THIS FINDING SAYS MUST NEVER BE
FLAGGED.** The paragraph directly above defends the geometry against a
prose-based detector and names printed 45 as the case proving it. Printed 45 is
cache `p046`, and it is among the **82 of 194** pages the snippet returns. The
defence was sound; the code beneath it was not.

Three filters separate 82 from 2, and the finding had one:

| test | flagged |
|---|---|
| the snippet as written - `get_text('dict', clip=block_rect)`, collecting lines from every block inside the clip | **82**, printed 45 among them |
| a block's OWN lines only | 15 |
| plus the block being at least 0.75 of the page wide - `read-columns.py`'s own `wide` test | **2 - p043 and p059**, the known welds |

**"Measured over all 194 pages in under a second" was false of both snippets.**
Timed here: as written **115.4s**, the dict-based fix **19.0s**, against **0.4s**
for the entire text-layer extraction it was to ride along with. What shipped
uses `get_text('words')`, grouping word `x0` by `(block, line)`, and returns the
same two pages in **0.57s** - the cost the finding claimed and neither snippet
had.

**Two wiring corrections, either of which would have shipped a key that lies.**
`ocr-book.py`'s page loop **skips anything already cached**, so a test placed
*"per page while it is already walking every page"* computes nothing on a
complete cache - and every cache here is complete, so the one book known to have
two welds would have recorded `welded_pages: []`. It is computed in
`write_manifest` instead, from the PDF, on every run, exactly as the four keys
beside it are recomputed from disk. And it walks the whole document rather than
the `pages` argument, so `--page 43 --force` cannot leave a manifest claiming
page 43 is the only weld in the book.

**`drift-check` cannot carry the warning and does not get it.** The proposal
names it beside `class-check --field-sources`. Read 2026-09-08:
`scripts/drift-check.mjs:181` is
`const CITATION_TABLES = ['spells', 'psionic_powers', 'skills'];` -
`imported_classes` is not among them, so **the row this finding exists for,
`starting_money` on `fq-gb-reloader`, is invisible to it** - and the
`citationRows` built at `:182-188` carry no page, only a table and a name.
`class-check --field-sources` was a clean fit and has the warning.

**Smaller things.** `p043` holds **four** welded blocks, not one; `p059` has the
single one. The two files are **not** *"normal-length"* - 30 and 10 lines against
a 96.5 median - though 35 of 194 pages are under 30 lines, so shortness is not
itself a tell. And *"the FIVE books still to be surveyed"* is **three**;
`BOOK-INGEST-QUEUE.md` says three and is right.

**The cross-book scan this finding asks for, run for the first time.** Every
text-layer cache whose PDF is still on this machine:

```
bom           4    cb1          10    dag           6    fom           9
free-quebec   2    ju            3    mystic-russia 0    new-west      1
pf            6    potm          1    spirit-west   1
```

**42 welded pages across ten of eleven books.** `cb1` is the only clean one, and
`pf` - the most-cited book in the database - carries six.

**And what it cost, which the finding could not know.** Every welded printed page
cross-referenced against live `source_book` citations, `--remote`: **29 live rows
were drawn from a page whose text layer welds** - 17 `ju` gear rows, the
`delphi-juicer` and `coalition-juicer` classes, three `pf` classes and one `pf`
spell. **That is a population to check, not 29 errors:** a weld anywhere on a
page flags every field drawn from it. The two highest-risk were read by hand and
are correct - the Delphi Juicer's `Money:` line really is on welded `p042`, and
the stored `5d6x100` is what the page says.

**One caveat, recorded where the key is written**, because it is the way this
could mislead: `welded_pages` describes the **PDF's block geometry**, not the
cache's state. A cache built by some other route - six of the first eight were -
gets a clean list while being wholly welded. It answers *"would reading this book
weld"*, not *"is this cache welded"*.

### F31 - four chassis of one O.C.C. cannot be `variants`, because a variant may not add a skill

**Filed 2026-09-08**, during the `free-quebec` survey.

Free Quebec prints one cyborg O.C.C. (printed 114-115) with eleven basic skills
and six related picks, and then four full-conversion chassis - FX-200C Imprimer,
FX-320C Dervish, FX-340C Slasher, FX-370C Leviathan - each of which states its
delta from that base in the book's own words:

> *"In addition to the Basic O.C.C. Skills, the Imprimer gets these additional
> skills, but other O.C.C. skills are reduced to three (not six)."*

That is two operations: **add skills**, and **change the related-skill count**.
`variants` can express neither.

`VARIANT_OVERRIDES` admits `attribute_dice`, `attribute_requirements`, the four
pool bases, `starting_money`, `bonuses` and `skill_overrides`, and
`docs/leveling.md` is explicit that the last of those *"restates the percentage
of a skill the class ALREADY grants. It cannot add or remove one - naming an
ungranted skill is an error."* The related-skill count is not on the list at all.

**The reasoning behind that restriction is sound and this finding does not argue
with it.** `docs/leveling.md`: *"a variant that could override anything is not a
variant, it is a second class wearing the first one's name."* The staged-dragon
case it was built for genuinely does share its skills.

**But the shape a book actually uses more often is the one here** - a common
training course plus a chassis-specific supplement - and the current answer to it
is five classes each restating the same eleven skills, which is precisely the
drift `variants` was introduced to stop. `docs/leveling.md` on the dragons:
*"Four unrelated class files means maintaining the shared 90% four times and
watching it drift."* Five is worse than four.

**Affected rows:** the five classes this book ships in batch 5 -
`fq-cyborg-soldier` and the four chassis. Each will carry an `extraction_notes`
line recording that its basic skills are a restatement of the base O.C.C.'s and
must be changed together.

**Proposed change**, and it is deliberately the smaller of the two available:
add **`skills_additional`** to `VARIANT_OVERRIDES` - a block in the same shape as
the class `skills` block, **unioned onto** the parent's rather than replacing it -
plus `related_skill_count`, a scalar. Union rather than replace is what keeps the
restriction's reasoning intact: a variant still cannot take a skill away, cannot
contradict the parent, and cannot become a second class, because the parent's
whole list survives in every variant by construction.

That is `js/parser.js` (validate, and add both to `VARIANT_OVERRIDES`),
`scripts/class-check-lib.mjs` (`KNOWN_KEYS`), `js/compose.js` (fold the union
before an R.C.C./O.C.C. merge sees it), `app.js` and `sheet.js` - **both**, they
are separate paths - and a `test/smoke.mjs` case. No migration and no column:
`class_variant` already exists on `characters` and this changes nothing about
how a variant is stored.

**Do NOT reach for `abilities` as the workaround.** An ability grant can carry
psionics and magic where a variant cannot, which makes it the obvious near-miss
here - but a skill granted through an ability is not a skill the picker offers,
does not take a per-level percentage, and does not compose. It would ship five
classes that look right and cannot be levelled.

**Taken, 2026-09-08 (PR #834).** The mechanism only, on Nate's decision. **The
five cyborg classes are NOT restructured** - a character references its class by
`class_id`, and collapsing the four chassis into variants would retire four ids
that characters point at. `skills_additional` and `related_skills_count` exist;
using them on published data is a separate decision that was not taken.

**THIS FINDING MAKES THE MIRROR IMAGE OF THE MISTAKE `F32` MADE, and `parser.js`
already carried the warning.** F31's edit list says *"`js/parser.js` (validate,
and add both to `VARIANT_OVERRIDES`)"*. `applyVariant` only **assigns**, so both
keys would have landed as inert top-level fields: `related_skills_count` where
nothing reads it - the count lives at `skills.occ_related_skills.count` - and
`skills_additional` beside the skills block rather than unioned into it. **It
validates clean, stores clean and does nothing.** Both are handled explicitly
below the loop, the way `skill_overrides` is, each ending in a `delete`.
Reproduced deliberately: with only the list entries and no handlers, three of
the new checks go red.

**This finding's own file list omits `docs/leveling.md`, and the suite requires
it.** Read 2026-09-08:
`apps/character-creator/test/checks/documented-counts.mjs:66-69` filters
`VARIANT_OVERRIDES` for any key the file does not mention in backticks and fails
on the remainder, so the run goes red until the doc names both.

**THE KEY IS `related_skills_count`, NOT F31's `related_skill_count`.** The
finding proposes a name one character from one that already exists and means the
same thing - the ability grant `F24` shipped. Two spellings would be a trap that
points the wrong way: a variant naming the ability's spelling gets the
ignored-key warning, while an ability naming the variant's gets **nothing at
all**, because abilities have no unknown-key sweep. One name for one mechanic
removes the question, and this is the one place the implementation departs from
the finding's text.

**The union is `combineClasses`' policy, reused rather than reinvented** - named
entries dedupe by lowercased name with the higher `base` winning, choice groups
never collapse. The repo already unions a skills block twice and F31 mentions
neither: `applyMos` in `js/compose.js` is the naive concat and is deliberately
not exported, its own comment arguing that *an MOS is not a variant*;
`combineClasses` is the considered one, and it is tested.

**Two files F31 names need no edit.** `sheet.js` references neither
`applyVariant` nor a skills block - its comment says the class *"comes with the
character now, already resolved to this character's variant"* - and `compose.js`
already runs `applyVariant` before `combineClasses`, so a union inside
`applyVariant` is upstream of it. `class-check-lib.mjs`'s `KNOWN_KEYS` is a set
of **top-level** keys, so adding variant sub-keys to it would do nothing either.
**`app.js` does need one**, and the premise audit that cleared the other two
never checked it: the Occupation step's *"Related skills: N"* preview reads the
raw class, so a chassis that reduces six to three showed six beside a dropdown
that had just selected three.

**"Eleven basic skills" is twelve.** All five classes' own notes say twelve, the
memory store says twelve, and printed 115 lists eleven lines plus
`* Hand to Hand: Expert`. The finding is the outlier; nothing here changes the
number, and the drift claim it supports holds at twelve - all four chassis carry
every one of the base's twelve entries.

**The `abilities` warning reaches the right conclusion by a wrong mechanism.**
It says a skill granted through an ability *"is not a skill the picker offers,
does not take a per-level percentage, and does not compose"*. `ABILITY_GRANTS`
is `['bonuses', 'psionics', 'magic']` - **an ability cannot grant a skill at
all**, and the ability validator has no unknown-key sweep, so a `skills:` block
on one produces no error and no warning. The failure is not *"look right and
cannot be levelled"*, it is *grant nothing, say nothing*. The advice stands and
its stated reason understates it.

**Step 5, the citation sweep.** All five classes carried the same sentence
enumerating the nine keys a variant could override and concluding neither
operation was expressible. That enumeration was **already stale before this** -
`attribute_maximums` landed earlier the same day - which is `audit-menu`'s
argument for citing a finding rather than restating a mechanism. Corrected on
all five, past-tense, recording that the mechanism now exists and that the
classes are deliberately not restructured. `fq-cyborg-soldier` needed its own
statement: it carries the same sentence with a different tail, and the script's
own readback caught it at 4 of 5.

### F32 - `attribute_requirements` holds MINIMUMS only, and a book's MAXIMUM inverts silently

**Filed 2026-09-08**, during the `free-quebec` import.

The le Surete du Quebec Deep Intel Agent (printed 32) requires *"I.Q. 10 and
M.A. 10 or higher... **and a P.B. of 12 or lower** (they want average looking
people)"*. That last clause is a **ceiling**, and nothing in the frontmatter can
say so.

`attribute_requirements` is minimums throughout, and every reader assumes it:

| where | what it does with the number |
|---|---|
| `js/parser.js:790-795` | combines a race's and an occupation's with `Math.max` - *"Both sets of minimums apply, so the stricter wins"* |
| `app.js:1109` | renders it to the player as `` `${k} ${v}+` `` - literally "PB 12+" |
| `app.js:1822-1880` | gates whether the class may be taken at all |

So writing `PB: 12` there would state **the exact inverse of the book** - it
would demand a beauty of at least 12 from a class whose whole point is looking
unremarkable - and it would do it silently, rendering as a plain requirement
with nothing to distinguish it from the two real ones beside it. This is the
`sdc_base`-versus-`pools.sdc` shape: the wrong key parses, validates and is
confidently wrong.

**Affected rows:** one today, `fq-deep-intel-agent`, which carries the cap in
`restrictions` and an `extraction_notes` line pointing here. **The shape is not
rare in Palladium** - a class capping an attribute rather than requiring it - so
the count should be expected to grow rather than stay at one.

**Proposed change:** `attribute_maximums`, beside `attribute_requirements` and
in the same flat-map shape, combined with `Math.min` where the minimums use
`Math.max`, rendered as `PB 12 or less`, and checked at creation by the same
code path. That is `js/parser.js` (validate, merge, and `VARIANT_MERGED`
alongside its twin), `scripts/class-check-lib.mjs` (`KNOWN_KEYS`),
`functions/api/.../validate-character.js` (a character CAN violate it, so it is
enforced server-side like its twin), `app.js` (the wizard's requirement line and
the roll gate), and a `test/smoke.mjs` case.

**A cheaper option exists and is worse.** `restrictions` already holds the
sentence and is displayed, which is why the class ships. But `restrictions` is
prose nothing enforces: the wizard will happily roll a P.B. of 18 and let the
character be built, and the note reads as flavour beside sixteen restrictions
that are also flavour. A requirement the app checks in one direction and ignores
in the other is the kind of half-modelled rule that is worse than an absent one,
because the enforced half makes the ignored half look enforced too.

**Taken, 2026-09-08 (PR #824).** `attribute_maximums` exists, and the class that
filed this finding stores its cap in it.

**THE POSTURE IS NOT THE ONE THIS FINDING ASKED FOR, and that is a decision
rather than a miss.** The proposal wanted the cap *"enforced server-side like
its twin"* - a blocking violation. **Nate fixed it as a WARNING when the finding
was taken.** `apps/character-creator/AUDIT.md` `F2`'s follow-up had already
decided this exact surface on 2026-08-24: pool maxima became a hard cap for any
creator who is not the campaign's GM, and **attribute checks deliberately stayed
warnings for everyone**, because *"Manual entry exists precisely for numbers a
table decided"* (`docs/wizard-and-sheet.md:481-495`). Enforcing a class cap
would have made this app the only place an attribute number is refused.

**So this finding's own argument against the cheap option is only half met, and
the note should say so.** *"A requirement the app checks in one direction and
ignores in the other"* is still, strictly, what ships: the minimum blocks and
the maximum does not.
<!-- claim-ok: quoting this finding's own text, four paragraphs above -->
What the key buys over the `restrictions` prose it replaces is real and is not
enforcement - the number renders as a cap instead of inverting to `PB 12+`, it
merges with `Math.min` across race, occupation and variant, it reaches
`admin/audit` as a structured `attribute_above_class_maximum`, and the next
importer is no longer told to write it into the block that means the opposite.
A later decision to enforce it now has something to enforce.

**Four premises did not survive, and each changed the work.**

**1. The wizard gate is not where this finding says.** It cites
`app.js:1822-1880` as the code that *"gates whether the class may be taken at
all"*. That range holds the shortfall panel, which explicitly lets the player
continue. The gate is `canNext` at **`app.js:1947`**, outside the cited range,
and the `N+` shape is rendered in **three** places - `:1109`, `:1914` and
`:1958` - not one. **This also corrects the earlier premise-audit section at the
end of this file**, which concluded there was no client gate at all.

**2. `VARIANT_MERGED` alone would have been a no-op.** The proposal names only
that list. `applyVariant` iterates **`VARIANT_OVERRIDES`** and consults
`VARIANT_MERGED` only to choose spread-versus-replace, so a key in the second
and not the first is never read. Adding it to both then turns the suite red
until `docs/leveling.md` names it, because `test/checks/documented-counts.mjs`
pins the override list against that file. Neither `VARIANT_OVERRIDES` nor
`docs/leveling.md` appears in the proposal's file list.

**3. There is no twin to validate alongside.** *"validate, merge, and
`VARIANT_MERGED` alongside its twin"* assumes `attribute_requirements` has a
shape validator. **It has none** - `parser.js` never checks that it is a map of
attributes to numbers, and neither does `class-check-lib.mjs`, which is a
key-NAME allowlist. So the validator written here is new work with no pattern to
copy, and the gap it leaves untouched is worth knowing about: a garbage
`attribute_requirements` still parses.

**4. `combineClasses` drops the occupation's half for free.** It opens
`out = { ...rcc }`, so a RACE's new key survives by spread and an OCCUPATION's
is silently lost unless an explicit merge is written. A half-implementation here
fails in exactly one direction, which is the shape a merged key hides best. It
is pinned by a test naming that asymmetry.

**And a fifth thing, which is a decision rather than an error.** The name
collides with **`bonuses.attribute_minimums`**, which already exists and is a
different mechanic - a floor applied AFTER the dice bonus lands, not a gate.
`parser.js` already carried a comment distinguishing that key from
`attribute_requirements`; both sites now carry one. The name shipped as the
finding wrote it, deliberately and with this recorded, exactly as `F31`'s
`related_skill_count` collision was flagged rather than discovered afterwards.

**One number could not be settled.** *"the note reads as flavour beside sixteen
restrictions that are also flavour"* - the class stores **three**, and no class
in this book has sixteen. It changes nothing in the argument and it had no
source.
<!-- claim-ok: quoting the premise this note corrects -->

**Both new checks were proven by injection before being trusted**, per the rule
that a check which has only ever passed proves nothing. Flipping `Math.min` to
`Math.max` fails *"both sets of maximums apply, the LOWER winning"*; pushing the
finding into `violations` fails *"warns and never blocks"*. Reverted after each.

**The UI was looked at, and looking is what caught the last bug.** On
localhost:8795 at 768x1024 and 1280x900, scrolled to top, the whole step above
the fold: the class detail reads *"Requirements: IQ 10+, MA 10+, PB 12 or
less"*, the P.B. row shows `12 or less`, and with P.B. 18 against a cap of 12
the **`Skills` button stays enabled** - the posture, confirmed in the app rather
than only in a test. The note measures 48px inside a 542px cell,
`table-layout: auto`, no horizontal scroll. **The first version rendered the
right class and the wrong colour**: a bare `.caution` ties `.attr-note` on
specificity and loses on source order, so the amber never applied. No test would
have caught it; the computed style did.

**That turned up a defect this PR does NOT fix**, filed as `UI-AUDIT` `F33`:
`.attr-note.err` has the same problem, so **an unmet class minimum has been
rendering muted grey rather than red** for as long as it has existed. Until that
is taken, this PR's advisory cap is the only coloured note in that column, which
reads louder than the blocking requirement above it.

**A second deferral, filed as `F37` on this menu:** `drift-check --remote`
reports `MIGRATION NOT APPLIED: 049-spell-same-spell-as.sql` on a clean tree.
The migration was applied - the column exists and holds 7 rows - and only its
`schema_migrations` line is missing. It arrived with `F26`'s PR (#815). This
PR's own data script shipped with the same omission on the data-script side and
was corrected before merge.

**Step 5, the citation sweep.** `audit-citations.mjs --remote F32` lists two
classes. `fq-deep-intel-agent` is rewritten by this PR's data script - the cap
moves out of `restrictions` prose and into the key, the restriction keeps the
book's sentence and loses the storage claim, and the note goes past-tense.
**`fq-glitter-girl-pilot` is deliberately NOT rewritten**: it cites this finding
for *"the neighbouring problem of a requirement the block cannot state"*, and
its own problem is **"Must be female"**, which `attribute_maximums` does not
solve and which `docs/surveys/free-quebec.md` records as unfiled on purpose.
Marking it resolved would be a false claim about a requirement that still has
nowhere to go.

### F33 - the gear catalog holds the same item twice under two slugs, and no single detector finds them

**Filed 2026-09-08**, found while resolving `equipment_starting` slugs for
`fq-deep-intel-agent`. **Not this book's rows** - every pair below is Rifts
Ultimate Edition or Palladium Fantasy, and this book contributed none of them.

Four pairs verified by reading the rows, `--remote`:

| slug | slug | shared |
|---|---|---|
| `huntsman-armor` | `huntsman-plate-padded-armor-non-environmental` | M.D.C. 45, cost 24,000, RUE p.261-270 |
| `language-translator-portable` | `portable-language-translator` | cost 9,600 |
| `large-flashlight` | `flashlight-large` | cost 12 |
| `bio-comp-monitor` | `bio-comp-system` | cost 2,500 - and the second's own description opens *"A Bio-Comp Monitor: a portable computer and sensor system..."* |

**Two pairs that match on the numbers and are NOT duplicates**, checked the same
way and recorded here so a later sweep does not merge them:

- `computer-portable` and `hand-held-computer`, both 100 credits. **THE REASON
  ORIGINALLY GIVEN HERE WAS FABRICATED.** This paragraph said the first is
  *"about the size of an open laptop"*; **no gear row in this catalog contains
  the word "laptop"** (`SELECT slug FROM gear WHERE description LIKE '%laptop%'`
  returns nothing). Both rows in fact say paperback - `computer-portable` reads
  *"about the size of an opened paperback book"* and `hand-held-computer`
  *"about the size of a paperback"* - and both quote the same 100-credits-to-
  tens-of-thousands range. **So this pair is NOT established as distinct**, and
  the paragraph that existed to stop a later sweep merging them was pointing the
  wrong way. It is not established as duplicate either; it is unresolved, and
  `catalog_redirects` already carries a `merge` from `hand-computer` to
  `hand-held-computer` - read `--remote` on 2026-09-08 with
  `SELECT r.from_key, r.reason, g.slug FROM catalog_redirects r JOIN gear g
  ON g.id = r.to_id WHERE r.catalog = 'gear' AND r.from_key LIKE '%comput%'`.
- `dead-boy-body-armor`, `coalition-dead-boy-body-armor` and the **two** CA-N
  rows - `ca-1-heavy-dead-boy-armor` at 80 M.D.C. and `ca-2-light-dead-boy-armor`
  at 50 - all 35,000. **This said THREE CA-N rows**, a number taken from
  `dead-boy-body-armor`'s own description string rather than from the catalog. `dead-boy-body-armor`'s description says outright it is
  *"Superseded by the three armours RUE prints separately"* and it resolves
  through a redirect. That is a managed legacy row, not an accident.

**The reason this finding does NOT come with a merge script**, and it is the
whole point of filing it rather than fixing it. Three detectors were written and
run this session and every one was wrong:

1. Grouping on `source_book` + `cost` + numbers returned 26 groups, almost all
   of them cheap goods that legitimately share a price - twenty-two faerie foods
   at one price is not twenty-two duplicates.
2. Adding a normalised name and keeping `source_book` in the key found **four
   groups, all false positives** (Large Sack vs Small Sack, Jacket (Heavy) vs
   Jacket (Leather)) and **missed both known pairs** - because the two
   translator rows cite the *same book with different page spans*, so the key
   split them.
3. Dropping `source_book` from the key found the flashlights and two plausible
   new pairs, still produced a false positive, and **still missed the huntsman
   and translator pairs** - the huntsman names differ too much, and stripping
   the parenthetical from `Language Translator (Portable)` deletes exactly the
   word that makes it match `Portable Language Translator`.

So a normaliser that finds all four would have to be loose enough to have made
the false positives worse, and **a merge run off any of these deletes a correct
row.** `F29` is the standing case: two Book of Magic spells sharing a range and
a damage figure looked like one spell twice, and merging them would have deleted
a correct row and changed what one of two kinds of caster spends.

**Proposed change:** not a merge script. A **reporting** check - a
`--duplicates` mode on `scripts/source-coverage.mjs`, or a new sweep - that
prints candidate pairs with the numbers they share, for a human to confirm one
at a time, and a `catalog_redirects` row per pair actually confirmed. The
redirect table already exists and is how `dead-boy-body-armor` is handled
correctly, so the mechanism is not the missing part; the confirmation is.

**Blast radius if it is ever merged:** every published class naming the losing
slug in `equipment_starting`. `node scripts/audit-citations.mjs --remote` and a
grep of the class markdown for the slug are what size it, and that sizing is
step one of taking this, not step two.

**Taken, 2026-09-08 (PR #825).** Posture as proposed - **reporting, plus a
place to put the answer. Nothing merges automatically, no catalog row changes,
and no dismissal ships as data.**

**THE HEADING IS WRONG, and it changed what got built.** *"no single detector
finds them"* is true of the three detectors written for this finding and false
of the one that ships. `findDuplicates` has been live throughout; its O(n^2)
walk was replaced with a token index by `INGESTION-AUDIT` `F29` on
**2026-09-06, two days before this finding was filed**, and that note records
reading gear's output the same day.
<!-- claim-ok: quoting this finding's own heading, above -->

Run against production gear on 2026-09-08 - the shipped module, a shim for
`env.DB`, no reimplementation:

| pair | shipped detector |
|---|---|
| `huntsman-armor` ~ `huntsman-plate-padded-armor-non-environmental` | **found**, `contains`, score 0.75 |
| `language-translator-portable` ~ `portable-language-translator` | **found**, `contains`, score 0.75 |
| `large-flashlight` ~ `flashlight-large` | **found**, `likely`, score 0.95 |
| `bio-comp-monitor` ~ `bio-comp-system` | **missed** - 0.667 against a 0.7 threshold |

So *"the huntsman names differ too much"* was true of this finding's own
normaliser and not of `normaliseName`, which scores that pair 0.75.
<!-- claim-ok: quoting this finding's own text, above -->
The miss is two of three tokens matching, and dropping the threshold to catch it
would swell a tier that is already **589 of 591** suggestions.

**And the proposal's closing sentence is backwards.** It says *"the mechanism is
not the missing part; the confirmation is."*
<!-- claim-ok: quoting this finding's own text, above -->
Confirmation is exactly what existed - a panel listing pairs, a human deciding
one at a time, and `mergeRows` writing the redirect inside the same batch that
repoints and deletes. What did not exist was anywhere to put a **no**, so every
reader re-judged the same pairs from nothing, including the 45 that `F29` read
and judged on 2026-09-06 and which sit in today's list indistinguishable from
pairs nobody has opened.

**`catalog_pair_dismissals` is that place**, shaped after
`npc_proposals_dismissed`. It records only the no: a confirmed duplicate is
executed rather than remembered, because the merge deletes the losing row and
the pair cannot be suggested again.

**A hazard this finding would have shipped.** It asks for *"a
`catalog_redirects` row per pair actually confirmed"* and says nothing about the
losing row.
<!-- claim-ok: quoting this finding's own text, above -->
Every server read path for inventory joins
`LEFT JOIN gear g ON g.slug = ci.gear_slug OR g.id = cr.to_id`, so a redirect
written while both rows still exist matches **both arms and returns the item
twice** - and `characters/[id]/items/[itemId].js` takes `LIMIT 1`, so it picks
between two categories arbitrarily. Verified `--remote` on 2026-09-08 against
`dead-boy-body-armor`, the one key in the catalog that has both a live gear row
and a redirect, which returns 2 rows today and is harmless only because no
inventory row carries that slug. **Hand-writing the redirect is the unsafe
version of what `mergeRows` already does correctly**, and nothing here does it.

**Two more premises did not hold.** *"and it resolves through a redirect"*, of
`dead-boy-body-armor`: the wizard's `findItem` checks the live slug **first**,
so that redirect is shadowed and the row resolves to itself. And the blast-radius
instruction names a script that cannot answer it - `audit-citations.mjs` matches
finding numbers in `extraction_notes`, takes no slug, and returns *"0 of 226
published classes"* for `F33`. Only the markdown grep in that sentence sizes
anything.

**The sizing the finding calls step one, done.** Citer counts re-derived
`--remote` two ways - `instr` over 225 live published classes, and an
`equipment_starting`-only pass using `String.includes` rather than a `\b` regex,
per this menu's own warning about the Bash tool eating the backslash. Both agree
with the earlier table on all eight rows: `huntsman-armor` **4** against **0**,
`portable-language-translator` **10** against **1**, `large-flashlight` **5**
against **1**, `bio-comp-system` **8** against **1**. Every citation is inside
`equipment_starting`; none is prose. One thing the table did not show:
**`salvage-expert` is the single citer of two different losers**, so two of the
four merges would touch one class.

**The "cheapest possible merge" is not available as described, and this is the
sharpest correction of the four.** The premise-audit section calls
`huntsman-plate-padded-armor-non-environmental` a zero-citer row and therefore
the cheap one to retire. `test/regression.mjs` **pins that slug as a row that
must still exist**, in a check whose comment reads *"the five that only look
like duplicates are still there"* - so retiring it turns a rebuilt database red.
And the direction is backwards anyway: the 4-citer survivor `huntsman-armor` is
a STUB whose own description says the other *"carries the full entry"*. Which
row loses is a decision, not a default, and none of the four is merged here.

**Proved by injection**: disabling the dismissal filter fails four of the six
new checks. The other two - a pure-function test of the pair identity, and one
asserting a dismissal naming a deleted row is inert - correctly do not move.

**Verified in the app**, on a local server confirmed to be serving this branch:
64 pairs on the skills catalog each gained the button, the first being
`Gambling (Standard)` against `Gambling (Dirty Tricks)` - the false positive
`INGESTION-AUDIT` `F27` already demoted, still being suggested. Measured at
1280x900 and 768x1024: zero overflow against the pair's own row, no horizontal
page scroll, and row heights **identical with the button hidden**, so the
wrapping is the panel's own and not something this added. The dismiss/restore
round trip ran against LOCAL only - 591 to 590 and back, the `likely` tier
emptying and refilling - and left no rows behind.

**Not done, and deliberately:** the `bio-comp` pair still falls under the
threshold. Catching it means either lowering `THRESHOLD` for every catalog or
adding a second signal, and `same-spell-lib.mjs`'s `descriptionOverlap` is the
obvious candidate - it is catalog-agnostic already, and near-identical prose is
exactly what separates that pair from `computer-portable`/`hand-held-computer`.
That is a change to what gets SUGGESTED rather than to what happens after, so it
is **filed as `F38` on this menu** rather than smuggled in here.

### F34 - the literacy placeholder is guarded and the LANGUAGE placeholder is not, so the same mistake fails on one and ships on the other

**Filed 2026-09-08**, caught by `regression.mjs` while importing this book's
first three classes - which is the good half of this finding.

`Language: Other` and `Literacy: Other` are **placeholder rows**. They exist to
be picked from, not to be held: a class grants them through a choice group so
the player names the actual language, and `regression.mjs` says so in its own
comment - *"A grant of the placeholder is a pick that was never offered: the
character ends up holding a skill named, literally, 'Literacy: Other'."*

The literacy family has four checks around it (lines 1082-1112): the picks
exist, none offers a CATEGORY, every pick offers the repeatable row, and
**`no class GRANTS the placeholder row as a fixed skill`**. That last one caught
all three Free Quebec classes on the first run, before anything shipped.

**The language family, about ninety lines above, has more checks than the
literacy family - and not the fourth one.** It has the two second-detector
checks, a bonus check and a frozen-percentage check; what it does not have is a
fixed-placeholder collector. `languageFixed` does not exist; only `literacyFixed`
does. So the identical mistake is fatal on one family and invisible on the other.
**This said "twenty lines above" and "the first three", and both were wrong** -
the point survives them.

**Measured `--remote`, 2026-09-08. Fifteen published classes name
`Language: Other` as a fixed skill today:**

```
godling, freelancer, knight-of-the-order-of-the-hospital,
knight-of-the-order-of-the-temple, demon-hound-rider, sky-rider,
first-stage-promethean, promethean-phase-adept, promethean-time-master,
phase-mystic, ngr-medical-officer, ngr-field-mechanic,
ngr-power-armor-commando, ngr-robot-combat-pilot, ngr-police
```

**Nine of the fifteen are the defect. Six are a different, legitimate shape,
and this paragraph originally claimed all fifteen were defective.**
`ngr-police` is the clear case: `{ name: "Language: Other", base: 60,
per_level: 5, note: "Select one additional language (+10%)." }` - the note says
*select* and the entry offers no selection.

**But `demon-hound-rider`, `sky-rider` and the four Promethean/phase classes
carry a FIXED NATIVE TONGUE at 98%** - *"His native tongue of Br'talb, at 98%"*,
*"Language: Promethean at 98%. The catalog has no Promethean row and this batch
does not invent one... The repeatable Language: Other row carries it."* That is
the same shape this finding explicitly blesses for `glitter-boy`, differing only
in that no catalog row exists for the tongue, which each note states as its
reason. **Converting those six would be a REGRESSION**, and not merely a
judgement call: a `from: ["Language: Other"]` group resolves off the Other row's
50% +5%/level, and `regression.mjs` already forbids a language group carrying
`base` or `per_level: 0`. The 98% cannot survive the rewrite.

Zero classes name `Literacy: Other` as a fixed skill, which is what the guarded
family looks like.

**Affected rows:** those fifteen. None is this book's - the three Free Quebec
classes were corrected before they were committed, and ship as choice groups in
both families.

**Proposed change**, two halves and the second is the one that lasts:

1. **The check.** A `languageFixed` collector beside `literacyFixed`, and
   `check('no class GRANTS the language placeholder as a fixed skill', ...)`.
   It goes red at fifteen the moment it is added, so it lands **with** the data
   fix rather than before it.
2. **The data.** Fifteen `fix-*.sql` rewrites turning each fixed row into
   `{ choose: N, from: ["Language: Other"], bonus: B, ... }`, where N and B come
   from each class's own note. **Read each note rather than assuming N is 1** -
   and note that the exception this line originally named was INVERTED: the four
   Promethean and phase classes grant exactly ONE, fixed, at 98%, and are among
   the six that should not be converted at all. **`godling` is the only class
   with two entries**, and it is the worst instance in the set: its second is
   `{ name: "Language: Other", choose: 2, bonus: 15 }`, and because
   `isChoiceGroup` in `js/parser.js` requires `!entry.name`, **that `choose: 2`
   is silently ignored today**. A `languageFixed` collector keyed on
   `e.name === 'Language: Other'` will therefore report `godling` twice - sixteen
   entries across fifteen class ids.

**Why the two halves must not be separated:** a check added alone turns the
suite red for fifteen classes nobody is currently touching, and the standing
temptation is then to weaken it to a warning. `class-import` already records
what that costs - six classes named `Robots and Power Armor` after a catalog
rename to `Robots & Power Armor`, every one silently offering the Pilot skill
its book forbids, because an unmatched `except` fails OPEN.

**What this finding is NOT.** It is not an argument that a class may never fix a
language at a flat percentage. `Language: Native Tongue` is a real row, and
`glitter-boy` fixes it at 95% with a note because its own O.C.C. block prints
that figure rather than the catalog's 98%. That is fine and is untouched here.
The defect is specific to the two rows whose names end in `: Other`.

**Taken, 2026-09-08 (PR #832).** Both halves in one PR, as the finding insists -
a **hard failing check**, not a warning, shipping with the data it goes red on.

**THE CHECK THIS FINDING SPECIFIES CAN NEVER PASS, and nothing in it says so.**
The proposal asks for `check('no class GRANTS the language placeholder as a
fixed skill', languageFixed.length === 0)` and says it *"goes red at fifteen the
moment it is added"*. The prose above it was corrected from fifteen to nine; the
**Proposal was not**, and it is the half an implementer builds from. If six of
the fifteen are legitimate, an `=== 0` check goes red at **six, forever**, and
the standing temptation the finding itself names - weaken it to a warning -
arrives on day one.

**So the check is a SHAPE RULE, on Nate's decision, and not a list of names.** A
fixed `Language: Other` is legitimate when the book NAMES the tongue: `base`
set, `per_level: 0`, because the character simply speaks it. A missing selection
looks like the catalog row it was copied from - `per_level: 5`, climbing, with a
note saying *select one* or *of choice*. All nine defects had the second shape
and all six named tongues the first, so no allowlist is needed and a seventh
book naming a tongue passes without anyone editing a test. A second check
asserts the named tongues **survive**, because a rule that only forbids can be
satisfied by deleting what it was protecting.

**And this finding's reason for protecting those six is FALSE.** It says
*"a `from: ["Language: Other"]` group resolves off the Other row's 50%
+5%/level... The 98% cannot survive the rewrite."*
<!-- claim-ok: quoting the premise this note corrects -->
A choice group **inherits** `base`/`per_level` - `app.js:3332-3336` says so in
its own comment, and `parser.js` says *"`base` fixes the percentage"* - and the
identical shape already ships in this book: three Prometheans carry
`{ choose: 2, from: ["Literacy: Other"], base: 98 }`. The frozen-percentage
check cannot see any of the six either; its `ABOUT_LANGUAGES` regex requires
*"languages"* plural or a leading `Language: Other,`, and none of their notes
match. **The six-vs-nine split is a real semantic judgement - a named tongue is
not a selection - and it is exactly the judgement call this finding says it is
not.**

**`godling` sits on both sides and stays fixed.** Its first entry is
`base: 98, per_level: 0, note: "One language of choice, at 98%."` - the
legitimate SHAPE with the defect's WORDING, the only entry of the sixteen where
the two signals disagree. Left alone on Nate's decision, and the arithmetic
agrees: 98% flat cannot be reproduced by a bonus on a 50% +5%/level row, so
converting it would change what the class grants. Its **second** entry is
converted, and it was worse than the finding says: `{ name: "Language: Other",
choose: 2, bonus: 15 }` is not merely *"silently ignored"* - `isChoiceGroup`
requires `!entry.name`, so it fell to the fixed path and **was granted**, giving
the Godling a 65% skill literally called "Language: Other" and no second
language.

**The nine, converted losslessly.** `Language: Other` is 50% +5%/level and
`bonus` adds to each pick's own base, so every conversion is `base - 50 = B`
with `per_level` already matching: `freelancer` 65->+15, both Knights 70->+20
and 65->+15, `ngr-medical-officer` and `ngr-robot-combat-pilot` 70->+20,
`ngr-field-mechanic`, `ngr-police` and `ngr-power-armor-commando` 60->+10, and
`godling`'s second entry keeping its own `choose: 2, bonus: 15`.

**Proved by making it fail.** With the data script held back,
`regression.mjs` goes **red naming all nine**; with it in place the suite is
green and *"the named tongues survive"* stays green throughout, so the six were
never in scope. Measured against **production** afterwards, through the shipped
parser: 225 live published classes, **zero** wrong fixed placeholders, **7**
named tongues kept fixed, 135 classes offering a language pick.

**One mistake worth recording, caught by the suite rather than by me.** The data
script first used box-drawing characters in its comment separators. `d1-apply`
accepted it and I reasoned from `schema.sql`, which uses them - but the smoke
suite is **stricter for data scripts and covers comments**, because *"wrangler
on Windows has turned them into mojibake in production"*. It went red, the
characters are now ASCII, and production was checked afterwards: the only
non-ASCII in any of the nine classes is two pre-existing em dashes on
`ngr-medical-officer`, spliced the documented way with `char(8212)`.

### F35 - `class-import` tells you to strip a prefix the catalog requires, and the advice produces the exact bug it warns about

**Filed 2026-09-08**, hit while importing this book's cyborg O.C.C.

`.claude/skills/class-import/SKILL.md`, under *Rules that are easy to get
wrong*, states:

> **Pilot skills store without a `Pilot:` or `Military:` prefix.** The catalog
> row is `Jet Fighters`, not `Military: Jet Fighters`. Naming the prefixed form
> cost three classes a restriction that silently did nothing.

**Measured `--remote`, 2026-09-08: the catalog holds the PREFIXED form and
nothing else.**

```
SELECT name, category FROM skills
 WHERE name IN ('Jet Fighters', 'Military: Jet Fighters', ...)

  Military: Jet Fighters        Pilot
  Military: Combat Helicopter   Pilot
  Military: Tanks & APCs        Pilot
```

There is **no** `Jet Fighters` row. There is no `Combat Helicopter` row and no
`Tanks & APCs` row either. **Twenty-nine** rows in the `Pilot` category carry a
prefix - the whole `Boat:`, `Military:`, `Space:`, `Fighter Combat:` and
`Robot Combat Elite:` families.

**So the rule is not merely stale, it is inverted**, and it fails in the
direction it was written to prevent. Following it here produced exactly one dead
`except` on the first try, reported by `class-check`:

```
  restrictions   1 name matches no skill row
      Pilot except: "Jet Fighters"
      These do nothing as written. An unmatched `except` excludes
      NOTHING, so the class offers skills the book forbids.
```

**Nothing shipped wrong from it.** `class-check` caught it before the class was
emitted, and the four Free Quebec classes already merged in #820 that name a
prefixed Pilot row - `Military: Tanks & APCs` on **two** of them,
`fq-descended-glitter-boy-pilot` and `fq-side-kick-rpa` - took the name from the
catalog rather than from the skill, so they are correct. **That is luck
about which source was consulted, not a process.**

**A published class DOES carry the unprefixed form.** `glitter-boy` grants
`Pilot Robot Combat Elite: Glitter Boy` and `Pilot Robot Combat Basic
(general)`, neither of which is a catalog name; they resolve because redirects
are consulted for GRANTED skills. That asymmetry is the trap and `class-import`
already documents it - **six lines BEFORE the rule, in a different section**,
not after it as this sentence originally said: *"a GRANTED skill naming an old
name still resolves... only restrictions skip them."* So the prefix question is
harmless in a grant and fatal in an `only` or `except`, which is precisely where
the wrong rule sends you.

**Proposed change**, and it is small:

1. **Correct the rule** to what is true - the catalog's Pilot rows DO carry
   `Military:`, `Boat:`, `Space:` and `Robot Combat Elite:` prefixes, and the
   name to use is whatever `SELECT name FROM skills` returns.
2. **Do not replace one memorised name with another.** The sentence was
   presumably right when written; what made it dangerous is that it names a
   specific row. Replace it with the instruction to look the row up, which is
   what `class-check --remote` already does for you.
3. **Check the three classes the original sentence says it cost.** If a rename
   went the other way since, they may now be wrong in the opposite direction -
   `class-import`'s own sweep, a parse of every class's `only`/`except` names
   against `SELECT name FROM skills`, is the command, and its stated floor of
   TWO unmatched names should be re-measured at the same time.

**Why this is worse than an ordinary stale doc.** It is a *rule* rather than a
count, it appears in a bulleted list of traps where a reader has every reason to
trust it, and its failure is silent at every layer except the one check that
happens to be run. `unmatched except fails OPEN` - the class offers a skill its
book forbids and nothing says so.

**Taken, 2026-09-08 (PR #823).** Documentation only, on one skill file,
which is the posture the proposal states - *"Correct the rule"*, *"Replace it
with the instruction to look the row up"*. No new check, no gate, no exit code
moved. Premises re-checked by `audit-premise-auditor` a second time before any
edit: **20 checked, 4 wrong, 1 unsettled by it and then settled from git.**

**1. Step 1 would have inverted the rule a second time, and was not
implemented as written.** It asks for the sentence *"the catalog's Pilot rows DO
carry `Military:`, `Boat:`, `Space:` and `Robot Combat Elite:` prefixes"*.
<!-- claim-ok: quoting the premise this note corrects -->
Measured `--remote` 2026-09-08 - `SELECT count(*), sum(CASE WHEN instr(name,':')
> 0 ...) FROM skills WHERE category='Pilot'` - the category holds **51 rows, 29
prefixed and 22 bare**: `Helicopter`, `Jet Aircraft`, `Airplane`, `Robots &
Power Armor` and `Combat Driving` carry no prefix at all. The finding's **29 is
exact**; the generalisation drawn from it is not. The catalog is MIXED, so that
replacement sentence would have been as false as the one it replaces, in the
other direction, and would have cost the next importer the same dead `except`.
**Shipped as step 2 alone** - the bullet now names no row and asserts no
convention, only *look it up*.

**2. A redirect for the unprefixed form exists live, and the finding never
mentions one.** `SELECT from_key, to_id FROM catalog_redirects WHERE
catalog='skills'`, `--remote` 2026-09-08: `Jet Fighters` forwards to `Military:
Jet Fighters`, and so do `Tanks and APCs` and `Robots and Power Armor`. So *"There
is no `Jet Fighters` row"* <!-- claim-ok: quoting the premise this note corrects -->
is true of `skills` and incomplete on its own - a GRANT naming the old string
still resolves and `class-check` will not report it. That is the asymmetry F35
identifies correctly further down, and it is now a bullet of its own rather than
a clause six lines away in another section.

**3. The history is settled, and both premise passes had recorded it as
unverifiable.** It is not in the tree; it is in `git log`. **PR #124**
(`6c73a29`, 2026-08-19) repaired `burster`, `wild-psi-stalker` and `warlock`
from `Military: Jet Fighters` to `Jet Fighters` - **those are the three
classes** - and **PR #133** (`2bbd509`, the same day) wrote the rule into
`class-import` off the back of it. **PR #180** (`ccb44a2`, 2026-08-21) then
renamed the row to `Military: Jet Fighters` and rewrote every class naming the
old form in the same script. So the rule was **true when written and inverted
two days later by the exact rename hazard the paragraph above it describes** -
the rename fixed the data and left the instruction. That is a better account
than *stale*, and it is now in the skill.

**4. "Six lines BEFORE the rule" is 11 to 14**, across a `##` heading -
`SKILL.md:162-165` against the bullet at `:176-178`. The finding had already
corrected this sentence once and was still wrong on the number.

**Step 3 is done, and it found nothing wrong.** The three classes, `--remote`
2026-09-08: all three carry `"Military: Jet Fighters"` inside the Pilot
`except`, **zero** occurrences of the bare form, and no other stale name; all
**seven** names in that list resolve to real `Pilot` rows, so the exclusions
bite. They are correct because PR #180's rename rewrote them, not by luck.
(`warlock` carries `deleted_at 2026-09-04` and `status published` - the retired
one, not drift.) The floor: a sweep of every live published class's
`only`/`except` against `SELECT name FROM skills` returns **1,499 restriction
names across 225 classes, 2 unmatched**, both the Priest of Light's documented
placeholders. **The stated floor of TWO holds exactly and no dead exclusion
exists live.** Re-measured in the skill with its date.

**And the sweep advice moved into the skill, because writing that sweep has a
trap this session fell into.** F35 calls the sweep *"the command"*; there is no
command. It ships as a suite check - `apps/character-creator/test/regression.mjs:863`
runs it over every class and pins the floor by NAME - but against the scratch D1
it builds from the repo, never `--remote`. Writing the `--remote` version by
hand, the first version of it reported **0 unmatched across all 225 classes**
and was measuring nothing: `parseClassMarkdown` returns `{ ok, data, errors,
warnings }`, and `restrictionNames()` handed the wrapper returns `[]` every
time. **The injected-failure check passed while the sweep was blind** - the
bogus name had been pushed onto the collected array, downstream of the part that
was broken, so it proved the comparison and never touched the collection. Both
the `.data` trap and the location of the real sweep are now in `class-import`.

**Nothing else needed correcting.** `audit-citations.mjs --remote F35` lists
five classes - the `fq-cyborg` dervish, imprimer, leviathan, slasher and soldier
- and each scopes its claim to the combat-aircraft rows specifically (*"the
combat-aircraft half uses the catalog's PREFIXED row names, which is how it
actually holds them"*), which is still true after this change. **No class note
edited.** By hand, F35 is also cited in `BOOK-INGEST-QUEUE.md`,
`docs/surveys/free-quebec.md`, the five `db/add-fq-cyborg-*-class.sql` scripts
and one memory file; none of them states a status this closes.

### F36 - a text-layer page can be corrupt at the GLYPH level, and the damage is not where the tell is

**Filed 2026-09-08**, during the `free-quebec` vessel extraction. **This is not
F30.** F30 is about reading ORDER - a block holding both columns, fixable by
geometry. This is about the CHARACTERS themselves being wrong, and no reader
fixes it because the text layer's own font mapping is broken.

Printed 95 of this book, cache `p096.txt`, extracts prose like this:

```
vsv&sis. \Vs. %\%vausttft tres>«safc>\a XVsaX o£ •& <3>p\d«s ^wtok CNSsferetetad
Aerwatet is Vncrea&«& V? 5$%, b^ ft& TK&%« o? \Yft pVaswA, \«s\
```

That is unmistakable, and a reader stops. **The problem is what is NOT
unmistakable on the same page.** Rendered at 200 dpi, the M.D.C. block reads:

```
  QST-333 Shaker Cannon (1) - 175
  * Vibro-Blade (1, right forearm) - 50
```

The cache gives those two lines as **`- 115`** and **`- 5Q`**. The Vibro-Blade
announces itself: `5Q` is not a number. **The Shaker Cannon does not.** `115` is
a perfectly plausible M.D.C. figure sitting in a clean-looking column of other
plausible figures, and it is wrong by sixty points.

**So the tell and the damage are not co-located.** The scrambled prose is in the
middle of the page; the corrupted digit is in a table that looks fine. A reader
who notices the garbage, reads around it, and trusts the rest of the page ships
a wrong number - and an extraction pass run over this page did exactly that,
reporting 115 in good faith.

**How it was caught, and it was not by a check:** the corrupted prose was
flagged, the page was rendered to resolve the two unreadable sentences, and the
render happened to show the M.D.C. block at the same time. **That is luck.**

**Affected rows:** the Tarantula Glitter Boy, which now ships 175 from the
render.

**How widespread it is, measured rather than asserted - and the first
measurement was wrong.** This paragraph originally read *"no other page of this
book shows the pattern - checked by scanning the whole cache"*, and **that scan
had not been run when the sentence was written.** Run afterwards, it ranked
printed 95 only **eighth**, behind printed 164-167 - which turned out to be
percentile tables (`36%-40%:`), because the signature included `%`. It also
included `&`, which matches `Demons & Monsters`. Four false positives out of
four, from a detector written in the same breath as a finding about not trusting
detectors. **F33's lesson, repeated by the session that wrote F33.**

Re-run with a signature that cannot match a percentage - `\`, the guillemets and
`£`, none of which occur in this book's clean text - printed 95 is the clear
outlier at seven occurrences and a 0.0020 ratio. Four other pages carry a single
stray character each (printed 4, 70, 140, 166) and one is not the same thing as
seven. **No other book's cache has been scanned at all.**

**Proposed change**, and the cheap half is worth doing on its own:

1. **A detector, and the character set is the whole design.** Corruption of
   this kind leaves characters the clean text never uses: `\`, `«`, `»`, `£`.
   **`%` and `&` must NOT be in it** - they match percentile tables and ordinary
   names, and including them is what produced the four false positives above. A
   per-page count recorded in the cache manifest the way `welded_pages` is
   proposed in F30 flags the page for a human. It does NOT try to repair
   anything, and it should report a COUNT rather than a threshold, because the
   difference between the one real page and the four innocent ones here was
   seven occurrences against one.
2. **The rule that matters more than the detector:** *a page with corrupt prose
   is corrupt everywhere, including in the parts that look fine.* Render it and
   read the numbers off the render. That belongs in `book-survey` §0 beside the
   existing text-layer-damage paragraph, which currently describes only the
   benign kind - missing spaces, a kept hyphen, a welded heading - and says
   *"none of it is fixed by a better reader... it is fixed by knowing what the
   value should look like."* **That advice fails here**, because 115 looks
   exactly like what the value should look like.

**Do not propose re-caching the page as the fix.** The corruption is in the
PDF's own embedded font mapping, not in the extraction: `read-columns.py` and a
raw `page.get_text()` return the same garbage, and re-running `ocr-book.py`
would too. The ink is fine and the encoding is not; rendering is the only route
to it.

**Taken, 2026-09-08 (PR #833).** Both halves - the detector and the rule. It
reports a **count** and repairs nothing, exactly as proposed.

**THE CORRECTED DETECTOR WAS ITSELF MEASURED WITH A BROKEN ONE, and this
finding is about not trusting detectors.** It specifies `\`, the guillemets and
`£`, then reports *"seven occurrences"* on printed 95 and four other pages
carrying one stray character each. Run with the signature as specified, printed
95 carries **17** - backslash 10, guillemet 5, `£` 2. **5 + 2 = 7 is the
finding's number, and its page list is exactly what you get with the backslash
absent.** The measurement was made without the character the signature names
first, which is this menu's own `\\`-collapse trap at work in the paragraph
correcting a previous detector.

**Six pages, not five.** Full output, the shipped function, 2026-09-08:

```
p096 (printed 95)  17     p119 (printed 118)  4     p005 (printed 4)  3
p167 (printed 166)  2     p071 (printed 70)   1     p141 (printed 140) 1
```

**And printed 118 is a second corrupt page this finding does not mention, on a
page a shipped class was extracted from** - `p119`, the FX-320C Dervish:
`b\omc and cybernetics common to a\\ Cyborg Soldiers, tine fo\-`.

**It is also a DIFFERENT disease, which changes what the rule can promise.**
*"The ink is fine and the encoding is not; rendering is the only route to it"*
<!-- claim-ok: quoting the premise this note corrects -->
is true of printed 95 and **false of printed 118**: rendered at 600 dpi that page
shows `a\\` as two literal backslashes - the ink itself is wrong there. Both
pages flag; only one is cured by a render. The `book-survey` rule says so.

**The cross-book scan, which the finding correctly says nobody had run.** All
sixteen caches:

| kind | flagged pages | shape |
|---|---|---|
| eleven **text-layer** caches | 0-9 each, `cb1` clean | real damage, at counts of 1 to 30 |
| five **OCR** caches | **24-39 each** | dot leaders read as guillemets, line art as backslash, clustered on contents pages |

**So the key is scoped to `text_layer: true`, which the finding does not say and
the numbers require.** *"Characters the clean text never uses"* is a property of
a text layer, not of a cache format.

Real damage found outside this book: **`bom` printed 84 at 30 hits** - a wholly
scrambled page a human found by hand on 2026-09-05 and recorded in the memory
store, which this detector rediscovers on its own - plus `bom` printed 116 and
310 turning `1` into `\` inside spell durations and damage dice, and `ju`
printed 55. **The premise audit checked the live rows those could have damaged,
`--remote`, and found none wrong**: the spells hold `10 minutes per level` and
`+10 to save`, and the Book of Magic p.84 water spells match a render exactly.
Every one was resolved correctly at import.

**A boundary of the detector, found while testing it and worth knowing.** The
signature is non-ASCII by construction, so **ASCII-to-ASCII glyph damage is
invisible to it.** The page beside the Dervish's corrupt one reads `!D6xlOOO`
for `1D6x1000` - `1` as `!`, `1` as `l`, `0` as `O` - and does not flag. The
stored value is right because a human read it right, not because anything
caught it. A signature wide enough to catch that would match ordinary prose,
which is the trade this finding already makes about `%` and `&`.

**Smaller corrections.** The 175 lives in `vehicle_locations`, not `vehicles` or
`gear`. The *"ranked printed 95 only eighth"* claim could not be reproduced -
with `%` and `&` added, 124 of 194 pages flag and printed 95 ranks 4th, 6th or
9th by method - though the substance holds, since printed 164-166 are percentile
tables and do outrank it. And `book-survey` §0 was **not** silent on mis-set
characters: it already named *"a mis-set digit"* with a remedy. What fails is
the remedy, not the category, so the new rule attaches to that clause rather
than claiming a gap.

**One thing this note cannot fix.** The section below is headed *"Premise audit
of F30-F36"* and its body audits F30 through F35 - **F36 is in the heading and
nowhere in the body**, confirmed 2026-09-08 by walking every line from that
heading to the next `###`. Its opening sentence says *"All six of F30-F35"*, so
the body knows its own scope and only the heading overreaches. It is left
standing as the dated record it is; this paragraph is the correction.

**`docs/surveys/free-quebec.md:669` gets this RIGHT and should not be
"corrected"** - *"Seven findings came out of it, F30 through F36, and all six of
F30-F35 went..."* is accurate on both counts. The memory store's
`free-quebec-import.md:41` is the one that inherits the wrong scope, saying
seven claims failed *"across F30-F36"*; no grep of this repo reaches it, which
is why it is named here.

### Premise audit of F30-F36, 2026-09-08 - read this before taking any of them

**All six of F30-F35 went through `audit-premise-auditor` BEFORE any was
implemented**, which is what `book-survey` §8 asks for when the session that
wrote a proposal is the session about to build it. **Seven claims did not
survive**, and the corrections are already made in place above rather than only
recorded here - a wrong sentence should not stand in the file at all. This
section holds what the corrections do not: the scope changes, and the two
proposals that are now different work than they said.

The auditor checked **41 premises and could not settle 2**: F33's claim that
three detectors were written and run this session, whose code is in no commit,
and F35's claim about "the three classes the original sentence says it cost",
which is a historical statement inside `class-import` and unverifiable from the
current tree. Both stand as unverified rather than as facts.

**F30 - the premises hold and the code block does not.** The algorithm claim is
right, both pages are right - re-derived without using the finding's own page
numbers - and the de-welded `Money:` line checks out. But the detector snippet
as written flags **82 of 194 pages**, because it collects lines from every block
inside the clip rather than the block's own. Restricted to a block's own lines
it flags 14; restricted further to blocks **at least 0.75 of the page width**,
which is `read-columns.py`'s own `wide` test, it flags exactly **2 - p043 and
p059**. **The wide filter is not optional**, and without it the finding's own
"an empty list on a clean book is the point" is false on the first book it runs
against. Two smaller corrections: the cache files are **still welded today** -
the de-welding happened in the reading, not in the cache - and they are not
"normal-length files", being 30 and 10 lines against a 96-line median.

**F31 - half of what it asks for already exists, built by this same menu.**
`related_skills_count` is implemented on an **ability grant** in
`js/parser.js`, with a comment naming `BOOK-INGEST-AUDIT.md F24`, and F24's
outcome note records the server change and production composing it. So "change
the related-skill count" is already expressible; what is not expressible is
doing it *in a variant*. **The proposal's `related_skill_count` is one character
from the existing `related_skills_count` and means the same thing** - that
collision is a decision to take deliberately, not to discover afterwards.
Verified by hand rather than taken from the audit report:
`grep -n related_skills_count apps/character-creator/js/parser.js` returns
lines 1619, 1624, 2309, 2310 and 2311 - the ability grant that applies it and
the validator that type-checks it, read 2026-09-08.

Two files the proposal names need no edit at all. **`sheet.js` has nothing to
touch**: its own comment says the class "comes with the character now, already
resolved to this character's variant", and it references neither `applyVariant`
nor the skills blocks. **`compose.js` needs no edit either**, because it already
runs `applyVariant` before `combineClasses`, so a union performed inside
`applyVariant` is upstream of it. And `class-check-lib.mjs`'s `KNOWN_KEYS` is a
set of **top-level class keys**; variant sub-keys are validated in `parser.js`
and adding them there does nothing. Everything else in F31 verifies, including
both `docs/leveling.md` quotes and the book quote.

**F32 - the premises hold.** Only line numbers drift, and one distinction is
worth carrying into the work: the `app.js` code the finding cites is the
**warning** panel, which lets a player carry on; the actual gate is
`validate-character.js`, which the proposal already names. No ceiling mechanism
exists anywhere - `attribute_maximums` and `maximums` return nothing across
`apps/`, `scripts/`, `.claude/` and `db/`.

**F34's data half shrinks from fifteen to nine, and six become a decision.** See
the corrected text above. The check half is unaffected and still goes red the
moment it is added, so the two halves must still ship together.

**F33 gained its sizing for free**, which the finding called step one of taking
it. Published classes citing each slug, `--remote`:

| slug | citers | | slug | citers |
|---|---|---|---|---|
| `huntsman-armor` | 4 | | `huntsman-plate-padded-armor-non-environmental` | **0** |
| `portable-language-translator` | 10 | | `language-translator-portable` | 1 |
| `large-flashlight` | 5 | | `flashlight-large` | 1 |
| `bio-comp-system` | 8 | | `bio-comp-monitor` | 1 |

Three of the four pairs have an obvious loser, and one - the huntsman pair - has
a zero-citer row, which is the cheapest possible merge. **A warning for whoever
runs that sweep**: `new RegExp('\\b' + slug + '\\b')` written through the Bash
tool collapses its double backslash and reports 0 citers for everything. Use
`String.includes`.

**What cites these findings**, because `scripts/audit-citations.mjs` sees class
`extraction_notes` **only** and will under-report: F30 is cited by
`fq-gb-reloader`, F32 by `fq-deep-intel-agent` and `fq-glitter-girl-pilot`. By
hand, the rest are cited in `docs/surveys/free-quebec.md`, in
`BOOK-INGEST-QUEUE.md`, and in six data scripts under
`apps/character-creator/db/`. **`BOOK-INGEST-QUEUE.md` also carries a per-finding
STATE outside this menu** - it says F30 and F31 are pre-authorized for
implementation - which is the shape `audit-menu` warns about, a finding's status
living somewhere the finding does not.

**And a note on citing these by bare number**: a tree-wide grep for F30 through
F35 returns mostly `UI-AUDIT` F30 and `INGESTION-AUDIT` F32, F33 and F34. This
menu's own header already says to cite by filename, at line 31; here is the
case for it. <!-- claim-ok: this file's own header, not another file -->

## Filed while taking F32, 2026-09-08

### F37 - migration 049 never records itself, so `drift-check --remote` reports a false drift forever

**Not taken here.** Found by running `drift-check --remote` while taking `F32`,
and filed rather than folded in, because that PR takes one finding.

`node scripts/drift-check.mjs --remote`, 2026-09-08, reports:

```
DRIFT FOUND (--remote): 1
  MIGRATION NOT APPLIED: 049-spell-same-spell-as.sql
```

**The migration WAS applied. Only the ledger row is missing.** Measured
`--remote` the same day:

| asked | answer |
|---|---|
| `SELECT count(*) FROM pragma_table_info('spells') WHERE name = 'same_spell_as'` | **1** - the column exists |
| `SELECT count(*) FROM spells WHERE same_spell_as IS NOT NULL` | **7** - and it is populated |
| `SELECT filename FROM schema_migrations ORDER BY filename DESC LIMIT 1` | `048-vehicles.sql` |

The cause is one absent line. `db/migrations/048-vehicles.sql` ends with
`INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('048-vehicles.sql');`
and **`049-spell-same-spell-as.sql` ends with its `CREATE INDEX`** - nothing
writes the ledger. `scripts/d1-apply.mjs` does not write it either; it is the
script's own job, by a convention every other migration follows.

**Why it matters more than a cosmetic row.** `drift-check --remote` is the
command `ship-pr` leans on to say whether production matches the repo, and it
now reports drift on a clean tree. **A check that always finds something is one
you stop reading** - which is `class-import`'s own argument, made there about
dead restriction names. The next person to run it has to re-derive that this
one row is a lie before they can trust the other rows.

**This is the same class of miss as one made in `F32`'s own PR**, caught by the
same command: that PR's data script shipped without its
`INSERT INTO data_script_runs` line and reported `DATA SCRIPT NOT RUN` until it
was added. **498 of the 499 scripts in `apps/character-creator/db/` carry the
ledger line**, so the convention is near-universal and entirely unenforced.

**Proposed change:** one statement, applied `--remote` and `--local` -
`INSERT OR IGNORE INTO schema_migrations (filename) VALUES
('049-spell-same-spell-as.sql');` - and the same line appended to the migration
so a rebuild from nothing records it too. **Posture: data only, no new check.**

**A check is the obvious second half and is deliberately NOT proposed here.**
<!-- claim-ok: describes a hypothetical check's rule, not what any file says -->
A pre-flight in `d1-apply.mjs` refusing a migration whose text does not name
itself in `schema_migrations` would catch the next one, and it is a real
proposal - but it is a gate on the script that writes production, it would fire
on every existing file that predates it, and `F32`'s PR shows the same gap
exists on the data-script side, so the sensible version covers both. That is a
different, larger finding and should be argued on its own rather than smuggled
in beside a one-line data fix.

**Evidence:** `drift-check.mjs --remote`, the three `q.mjs --remote` queries
above, and `tail` of both migration files - all 2026-09-08. **Confidence: high**;
the only thing not verified is *why* the line is absent, which the PR that added
the migration (#815, `F26`) would have to say.

**Ongoing cost:** none for the fix itself. The underlying convention stays
unenforced, which is what the paragraph above declines to solve here.

**Taken, 2026-09-08 (PR #826).** `drift-check --remote` now reports **NO
DRIFT**, for the first time in this session.

**HALF THIS FINDING'S PROPOSAL WAS WRONG, and that half was forbidden.** It
asked for the ledger line to be appended to `049` as well, *"so a rebuild from
nothing records it too"*.
<!-- claim-ok: quoting the premise this note corrects -->

- **A rebuild from nothing already recorded it.** `db/schema.sql:1077-1079`
  carries the guarded seed - `INSERT OR IGNORE ... SELECT
  '049-spell-same-spell-as.sql' WHERE EXISTS (a `pragma_table_info` check for
  `same_spell_as`)`. That is step 3 of the five the `schema-change` skill lists,
  and `049` did **not** skip it. A fresh database has been correct the whole
  time, which is also why `regression.mjs` - which builds one from nothing -
  never saw this.
- **Editing `049` is refused anyway.** `schema-change` -> *"Migrations are never
  edited after being applied anywhere. A mistake gets a new numbered file."*
  `049` is applied on production and on this machine.

So the finding described the gap as wider than it is. **It is exactly one row in
one existing database**, which is a data script's job, and
`apps/character-creator/db/fix-record-migration-049.sql` is what shipped -
guarded by the same column check `schema.sql` uses, so a database that genuinely
has not migrated still refuses the row and still reports drift, which is the
correct answer for it.

**What held:** the column exists on production and 7 rows carry a link, so the
migration really did run; `048-vehicles.sql` really does end by recording itself
and `049` really does end at its `CREATE INDEX`; and the consequence stands -
`drift-check` is the command `ship-pr` leans on, and it was reporting drift on a
clean tree.

**The check this finding declined to propose is still not proposed**, and the
reasoning is unchanged: a pre-flight in `d1-apply.mjs` refusing a migration whose
text does not name itself would fire on every file that predates it, and the
same gap exists on the data-script side - `F33`'s own script shipped without its
`data_script_runs` line and was corrected before merge. That is a bigger finding
than this one and should be argued on its own.

### F38 - one real duplicate scores 0.667 against a 0.7 threshold, and the names cannot settle it

**Not taken.** Filed while taking `F33`, whose mechanism it does not need and
whose posture it would change: `F33` added a place to record the answer, and
this is about what gets ASKED.

`bio-comp-monitor` and `bio-comp-system` are the same item. `bio-comp-system`'s
own description opens *"A Bio-Comp Monitor: a portable computer and sensor
system clipped to the ears or fingers..."*, both cost 2,500, both are `rifts`,
and both cite Rifts Ultimate Edition. **`findDuplicates` does not suggest the
pair and cannot**, measured 2026-09-08:

```
similarity('Bio-Comp Monitor', 'Bio-Comp System') = 0.667     THRESHOLD = 0.7
```

Two of three tokens match. It is the one pair of the four in `F33` the shipped
detector misses, and it misses by 0.033.

**Lowering `THRESHOLD` is the wrong fix and the numbers say so.** Gear already
returns **591** suggestions of which **589** are the loosest tier; that ratio is
what `F33` is about, and a lower threshold makes it worse on every catalog at
once to catch one pair.

**Proposal:** a SECOND signal, so a pair can clear on evidence the names do not
carry. `descriptionOverlap(a, b)` in `scripts/same-spell-lib.mjs` already
computes shared 4-plus-letter vocabulary as a fraction of the shorter
description, and is **not spell-specific** - it reads two strings. A pair below
the name threshold but with a high description overlap becomes a suggestion in
the loosest tier, never a confident one. **Posture: it may only ADD
suggestions, never promote a tier and never merge.**

**What would make this fail, stated first:** the same signal on
`computer-portable` / `hand-held-computer` - the pair `F33` records as
*unresolved* - would likely also fire, since both describe a paperback-sized
computer at 100 credits. **That is arguably correct** and is the test case
either way: if the new signal cannot separate those two, it is a noise generator
and this finding should be declined rather than tuned.

**Evidence:** `similarity()` run directly on the two names, and the four pairs
run through the shipped `findDuplicates` against `--remote` gear, both
2026-09-08, recorded in `F33`'s outcome note. **Confidence: high** that the pair
is real and missed; **low** that description overlap separates it cleanly from
the computer pair, and that is the thing to measure before writing anything.

**Ongoing cost:** one more signal to reason about when a suggestion looks wrong,
against a detector that is already three demotion rules deep.

**CLOSED WITHOUT BEING TAKEN, 2026-09-08 (PR #829). The measurement this
finding asked for was run, and it failed the test this finding set.**

The proposal named its own kill condition: *"if the new signal cannot separate
those two, it is a noise generator and this finding should be declined rather
than tuned."*
<!-- claim-ok: quoting this finding's own proposal, above -->
Measured `--remote` on 2026-09-08, `descriptionOverlap` from
`scripts/same-spell-lib.mjs` against the shipped `similarity`:

| pair | what it is | name | description overlap |
|---|---|---|---|
| `bio-comp-monitor` / `bio-comp-system` | the target - a real duplicate | 0.667 | **0.741** |
| `computer-portable` / `hand-held-computer` | the trap - `F33` records it unresolved | 0.333 | **0.750** |
| `large-sack` / `small-sack` | obviously distinct | 0.500 | 0.583 |
| `large-flashlight` / `flashlight-large` | a **real** duplicate | 0.950 | **0.000** |

**It ranks the trap ABOVE the target.** 0.750 against 0.741. There is no
threshold that admits the pair this finding exists for and excludes the pair it
named as the test, because the trap scores higher. That alone closes it.

**Two things the measurement added that the finding did not anticipate.**

**The signal is weakest exactly where it is needed.** `large-flashlight` and
`flashlight-large` are a real duplicate and score **0.000**, because
`flashlight-large`'s whole description is `20 cr.` A row thin enough to be an
accidental second copy is usually thin enough to have no prose, so a
description-based signal is least informative on precisely the rows most likely
to be duplicates.

**And the rate is fatal on its own.** Pairs below the name threshold that a
description rule would ADD to the panel, over the 591 already there:

```
overlap >= 0.50  ->  15,446 new suggestions
overlap >= 0.60  ->   6,900
overlap >= 0.70  ->   5,809
overlap >= 0.80  ->   5,321
```

Even at 0.80 that is **nine times** the current list, to reach one pair. `F33`
was taken because 591 suggestions is already more than anyone reads.

**What stands instead.** `bio-comp-monitor` and `bio-comp-system` are still the
same item, and nothing here disputes that - `bio-comp-system`'s description
opens *"A Bio-Comp Monitor: a portable computer and sensor system..."*, both
cost 2,500, both are `rifts`, both cite Rifts Ultimate Edition. **It is a merge
a human can make in the panel today**, by slug, without any detector suggesting
it: the pair is named here and in `F33`, which is what a finding is for. The
direction is not in doubt either - **8** published live classes cite
`bio-comp-system` against **1** citing `bio-comp-monitor`, measured `--remote`
2026-09-08 with `sum(instr(markdown, '<slug>') > 0)` over
`imported_classes WHERE status = 'published' AND deleted_at IS NULL`, which
agrees with `F33`'s own table.
<!-- claim-ok: the count is measured in this paragraph, not read from a file -->

*(This paragraph said NINE until the menu check flagged the line. It was eight
in `F33`'s table an hour earlier and eight when re-measured; the wrong figure
was typed here, not measured. The check fired on unrelated phrasing and caught
it anyway, which is the argument for the check rather than against it.)*

**Not to be re-proposed as a threshold change.** Lowering `THRESHOLD` to 0.66
to catch this one pair was considered and is worse than the above: it moves
every catalog at once, and `similarity` is what three separate demotion rules
(`INGESTION-AUDIT` `F27`, `F30`, `F31`) are already tuned around.

## Filed while reviewing the OCR pipeline, 2026-09-08

### F39 - §0b's DPI paragraph and §0c's framing together read as "a render only helps a text layer", and the case that disproves it is a SCAN

`book-survey` §0b says **"Do not reach for a higher DPI when the text is
wrong."** <!-- claim-ok: quoting SKILL.md:167, opened and read 2026-09-08 -->
That sentence is right, and so is everything under it: 300 -> 600 dpi took the
price-unit misreads from 7 to 5, `--oem 1` changed nothing, and only 1.3% of
words score under 70 with none of the known misreads among them. Its conclusion
is that the leverage is not in the scan but in knowing what a field is allowed
to look like, and §0 states the same thing about a text layer eight lines into
its damage paragraph - **"None of it is fixed by a better reader."**
<!-- claim-ok: quoting SKILL.md:91, opened and read 2026-09-08 -->

§0c does prescribe rendering a page and looking at it. But its heading is **"A
text layer does not give you TABLES. Render the page and look"**, and all three
rows of the table under it are text-layer cases - the Attribute Bonus Chart at
PF 16, Types of Armor at PF 270, and the SAMAS Pilot's skills at RUE 233.
<!-- claim-ok: SKILL.md:183 and the table at SKILL.md:190, both read 2026-09-08 -->

**So a session working a SCAN meets a DPI paragraph telling it not to touch the
pixels, and a render section addressed to the other kind of cache.** Neither
sentence is false. Together they read as *a render is what you do about a text
layer*, and that is the reading this finding is about.

**The case, and it is a scan.** `triax` is OCR (`text_layer: false`, `dpi: 300`
in its manifest) and its cached p110 holds items 6-9 of the VX-635 Prowler's
bionic features cleanly, then `0. Gyro-compass` for item 10, then a block of
glyph noise, then `Multi-optic eyes` and `Radar detector` loose and unnumbered.
**Three of the fifteen are in the cache nowhere**: Molecular analyzer (11),
Modulating voice synthesizer (12), and Psionic electro-magnetic dampers (14).

A 160 dpi render of the same page - PDF index 109, `triax` `page_offset` 0 -
reads all ten of items 6 through 15 without difficulty. The page is a full-page
line-art plate with the list set beside it, and `--psm 3`'s layout analysis
loses to the hatching. **That is not a resolution problem and not a wordlist
problem**, which is exactly why §0b's measurement does not reach it: raising the
DPI would not have helped, and a render did.

**Nothing was lost from the catalog.** All three items are live from printed 153
in `apps/character-creator/db/add-triax-gear-e-cybernetics.sql`, which prices
the first two and records that the book prints no price for the third. What it
cost was the reconstruction: `apps/character-creator/docs/surveys/triax.md:446`
says the items were rebuilt *"from readable fragments plus the continuation on
p111 where possible"*, and a render would have answered the page outright.
<!-- claim-ok: quoting triax.md:446, opened and read 2026-09-08 -->
*(That note says items 6-14. The cache has 6-9 clean and the damage running
10-15, so the note's range is wrong at both ends. Left as it stands - it is a
dated record, and this paragraph is the correction.)*

**Bulk OCR quality is NOT the argument here, and the measurement says so.**
Scored on 2026-09-08 by a throwaway script - per page, the fraction of
whitespace-separated tokens matching `[A-Za-z][A-Za-z'-.,;:!?()]*` or a numeric
form - over every cached page of five OCR books and five text-layer books:

| cache kind | books | pages | median word-like | pages under 0.60 |
|---|---|---|---|---|
| OCR | `rue`, `ww`, `triax`, `underseas`, `phase-world` | 1163 | 0.925 - 0.953 | 7 |
| text layer | `pf`, `bom`, `free-quebec`, `new-west`, `potm` | 1246 | 0.947 - 0.965 | 25 |

**Read that table narrowly.** It says Tesseract's bulk output on these five
books is in the same band as a publisher's own text layer, so the engine is not
the problem. It does **not** say text layers are worse: most of the text-layer
outliers cluster at `p005`-`p010`, which is front matter, and the two counts are
not measuring comparable things.

**And the proxy missed the page this finding is about.** `triax` p110 does not
appear in those 7, because the page is mostly illustration - few tokens, and the
half that survived is clean. A token-ratio detector would not have flagged the
one page that motivated the measurement.

**Proposal - documentation only, no check, no script, no code.** Two paragraphs
in `book-survey`:

1. **In §0b, after the DPI paragraph**, one sentence bounding what that
   measurement covers: it is about Tesseract's own parameters, and it does not
   say that a page whose layout analysis failed cannot be read - a render can,
   and `triax` p110 is the case.
2. **In §0c**, widen the framing from *a text layer does not give you tables* to
   *a cache of either kind can lose a page, and a render is the route to it* -
   keeping every existing text-layer row, and adding the scan case beside them.

Nothing is deleted and no existing sentence is contradicted. **The posture is
prose only**: it adds no manifest key, no detector and no exit code.

**Both neighbours have SHIPPED, and what they shipped covers text layers only.**
That is the durable statement, and it is why this finding is sharper now than
when it was drafted. `F36`'s glyph detector and its §0 render rule, and `F30`'s
`welded_pages`, both landed on 2026-09-08. Neither reaches a scan:

```
scripts/ocr-book.py:412   if doc is not None and base.get('text_layer'):
scripts/ocr-book.py:413       base['welded_pages'] = welded_pages(doc)
scripts/ocr-book.py:419   if base.get('text_layer'):
scripts/ocr-book.py:420       base['corrupt_pages'] = corrupt_pages(txt_dir, nums)
```

Read at `5feeadf`, 2026-09-08. **Both keys are gated on `text_layer`**, so no
OCR cache gets either signal - the five here are 1163 pages with no page-level
quality flag of any kind. The prose landed the same way: the §0 block added
above the DPI paragraph says *"Across the eleven text-layer caches here"* and
draws every example from `pf`, `bom` and Free Quebec.
<!-- claim-ok: quoting SKILL.md:105, read at 5feeadf on 2026-09-08 -->

**And extending the glyph detector to scans is already settled, on a
measurement, against.** `scripts/ocr-book.py:414-416` says so in the code:
*"Text-layer caches only: on an OCR cache the same characters are dot leaders
and line art, and the signature fires on 11-17% of pages."*
<!-- claim-ok: quoting the comment at ocr-book.py:414-416, read at 5feeadf on 2026-09-08 -->
**Do not re-propose it**, and read that as support rather than as an obstacle:
the detector route to the scan side is closed by evidence, which is precisely
why the remedy proposed here is prose. A reader who cannot be handed a flag has
to be told where to look.

**So this finding neither duplicates nor competes with either neighbour.** It
proposes no detector, no manifest key and no second mechanism - only the two
prose paragraphs above - and it is now the only thing on this menu addressing
the scan side of a question the text-layer side has answered twice.

*(This paragraph replaced one calling `F36` open and `F30` unbuilt. Both were
true when written at 14:14 and false by 19:04, and `audit-menu` forbids the
shape outright: a sentence carrying another finding's state rots wherever it is
written. What stands above states what the CODE does, which does not rot the
same way. The finding had not merged, so this is a draft corrected before
landing rather than a record rewritten - the rule against editing a measurement
governs what is already in the file.)*

**Evidence.** SKILL.md lines 91, 105, 167, 183 and 190, `scripts/ocr-book.py`
lines 412-420, and `triax.md:446` - all opened and read at `5feeadf` on
2026-09-08. **The four SKILL.md numbers are the second set**: the draft cited
79, 124, 140 and 147, correct at `f802eca` and moved when `F30` and `F36`
landed in between. `triax` p110 rendered at 160 dpi with
`pymupdf.get_pixmap` and read, 2026-09-08. Cache kinds from each
`.cache/books/<slug>/manifest.json`. The word-like table from the throwaway
script described above, which is **in no commit** - the method is stated in one
line so it can be re-derived rather than trusted.

**Confidence - high on the prose claims and on the page, medium on how often
this recurs.** The four skill lines and the p110 render are direct reads. What
is not measured is how many other pages across the five OCR caches are lost the
same way; the token proxy demonstrably cannot find them, and nothing else has
looked. **What would raise it:** a pass over the illustration-heavy pages of the
other four OCR caches, which needs a way of finding them that is not the proxy
above.

**Ongoing cost - two paragraphs to keep true, and one trap.** No check, no
script, no CI minute. The trap is that §0b's DPI paragraph is a *measurement*:
if it is ever re-run and moves, the sentence this finding adds beside it must be
re-read rather than left standing.

**The decline path is real.** §0c already tells you to render a page, and the
`triax` reconstruction worked - the data is correct in production today. If the
view is that a reader who needs the render will find §0c whatever its heading
says, this finding is two paragraphs of maintenance for a framing problem that
has cost one reconstruction. **It is filed as prose precisely because that is
cheap enough to decline.**

**Taken, 2026-09-08 (PR #836). Posture held: documentation only** - two prose
paragraphs plus a corrected table label in `book-survey`, no manifest key, no
detector, no script, no check, no exit code, and nothing deleted.

**FOUR of this finding's premises did not survive the premise audit, and one
changed the work.** `audit-premise-auditor` checked twelve; the corrections lead
here because an implementer must not repeat them.

1. **The catalog paragraph above is wrong.** It says all three missing items are
   live from printed 153. Only the Psionic Electro-Magnetic Dampers is a row.
   *Modulating voice synthesizer* is in `apps/character-creator/db/` nowhere
   under any name, and *Molecular analyzer* survives only as a phrase inside
   `epidermic-analyzer`'s description - a different catalog entry, the sensor-hand
   feature of printed 153. The error was conflating the Prowler's **bionic
   feature list of printed 110-111** with the **purchasable cybernetics
   catalogue of printed 153-154**. The Prowler's feature list is stored nowhere,
   which is a smaller and truer statement than the one above.
2. **`§0c`'s table already held a scan case, so the finding's central framing
   claim was half wrong.** `Coalition SAMAS Pilot's skills (RUE 233)` is Rifts
   Ultimate Edition, `text_layer: false` - and §0b uses `--slug rue` as its
   worked SCAN example. The row was filed under a column header reading *"what
   the text layer gave"*. **The section was not missing a scan case; it was
   mislabelling the one it had.**
3. **The word-likeness counts are not re-derivable** from the method the finding
   states, which was the one thing that method was for. Real cached-page totals
   are **1193** OCR and **1329** text-layer, not 1163 and 1246; no token
   threshold reproduces the published pair, so an exclusion rule was applied and
   not written down. The medians and the under-0.60 counts move too. **The
   conclusion is unaffected** - bulk OCR quality is not the problem - but the
   numbers are not evidence anyone can reproduce and were kept out of the skill.
4. **"In the cache nowhere" was an overclaim.** Items 11, 12 and 14 are absent
   from **p110**, which is all the argument needs. They appear on `p086`,
   `p098`, `p100` and `p102`, where Triax reprints the same list for its other
   cyborgs - so a grep would also have recovered them here, and the skill now
   says so rather than overselling the render.

**The scope of item 2 changed because of correction 2, and Nate approved the
change before it was written.** As filed, item 2 said to keep every existing
text-layer row and add the scan case beside them; done literally that preserves
a wrong label and adds a redundant row. What shipped instead: the table gains a
**`cache kind`** column, its header becomes *"what the cache gave"*, `RUE 233`
is marked **scan**, and a paragraph under the table says the column used to read
otherwise and why that made the section read as a text-layer remedy. **No fourth
row was added.** `triax` p110 is described in prose in both sections, because it
is not an authority table and does not belong in a table of them.

**The `§0c` heading changed, and one citation elsewhere now names wording that
is gone.** `apps/character-creator/INGESTION-AUDIT.md:1764` - `F15`'s
disposition - identifies this section as *"§0c 'a text layer does not give you
TABLES'"* while classifying it among the parts of the skill that are judgement
and should stay prose. That disposition is the reason this finding shipped as
prose at all, and it is **not edited**: an audit file is a record. Read it as
naming the section, not the sentence.

**What this costs, against a length already noticed.** `book-survey` goes 793 ->
823 lines. `INGESTION-AUDIT` `F15`'s adjustment records that the file grew
rather than shrank when §0/§0b/§0d were rewritten, and ends *"If it needs to be
shorter, that is now its own decision about which failure histories have earned
their place."* This adds thirty lines to that decision without settling it.
<!-- claim-ok: quoting INGESTION-AUDIT.md:1842-1843, opened and read 2026-09-08 -->

**Two things the finding got right and one it left open.** The p110 case
reproduces exactly - the auditor rendered PDF index 109 itself and read items
6-15, three of which the cache does not have. The `ocr-book.py` gating claim is
byte-exact, and the audit strengthened it: `welded_pages` and `corrupt_pages`
have **no other write path**, so no OCR cache can receive either signal, and
`class-check.mjs` treats an absent key as *not known* rather than *clean*. Still
unmeasured, as the Confidence line said: how many other illustration-heavy pages
across the five OCR caches are lost the same way.

**Cite this one as `BOOK-INGEST-AUDIT` F39.** A bare `F39` grep returns mostly
`SKILL-AUDIT.md`'s own unrelated F39 and a `META-AUDIT` line discussing the
`F30`-`F39` range. Nothing outside this file cites this finding.

### F40 - a Triax cybernetics row cites printed 153 and the book prints it on 154

**Found while taking `F39`, and deferred rather than folded into it** - a data
correction has nothing to do with that finding's prose, and this menu's rule is
to file the gap and keep going.

`apps/character-creator/db/add-triax-gear-e-cybernetics.sql:56` gives
`psionic-electro-magnetic-dampers` the source `Rifts World Book 5: Triax and the
NGR p.153`. The book prints it on **154**: the folio is at
`.cache/books/triax/txt/p154.txt:76` and the entry at `:78`, *"Psionic
Electro-Magnetic Dampers: Brain implants that dis-"*, with the bonuses running
to `:81`. `triax` `page_offset` is **0**, so cache `p154` is printed 154.
Twenty-one rows in that file cite `p.153` and four cite `p.154`; this one is in
the wrong bucket.

**Proposal:** correct the one `source` string to `p.154`, apply `--remote`
before merging per the ordering rule, and check the other twenty rows citing
`p.153` against the folio at the same time rather than assuming this is the only
one. **Posture: a data fix, no schema change and no new check** - the citation
ledger cannot see this. `scripts/source-coverage-lib.mjs:20` defines its clean
bucket as *"traceable  the window is in the cache. Nothing to do"*, so a page
number that is wrong but EXISTS reads as traceable - printed 153 is in the
`triax` cache. That is why this had to be found by reading.
<!-- claim-ok: quoting source-coverage-lib.mjs:20, opened and read 2026-09-08 -->

**Evidence.** `add-triax-gear-e-cybernetics.sql:56` and the two cache pages,
opened and read 2026-09-08. Confirmed independently after
`audit-premise-auditor` reported it, by locating the folio rather than by
re-running its command.

**Confidence: high** on this row - the folio and the entry are on the same
cached page. **Low on the scope**, deliberately: the other twenty `p.153` rows
were not checked, which is why the proposal asks for that rather than asserting
they are fine. **What would raise it:** reading the folios for those twenty.

**Ongoing cost: none.** One string, and the sweep it proposes is finite.

**Taken, 2026-09-08 (PR #837). Posture held: a data fix, no schema change and
no new check** - one data script of a single `UPDATE`, plus two comment
corrections in the file that made the error.

**THREE corrections, and the first is to this finding's own reasoning.**

1. **The ledger CAN see a wrong citation, and it was already reporting one of
   these two rows.** This finding said `source-coverage-lib.mjs:20`'s
   `traceable` bucket is why the error had to be found by reading. That quote is
   exact and `bucketFor` does only resolve slug -> offset -> window. **But the
   same file's `summariseValues` (`:210-241`) tests each gear numeric against
   the cited window and classifies a miss as `late`/`early`/`absent`**, it is
   wired to `node scripts/source-coverage.mjs --values`, and it is **`F1`'s own
   product on this menu**. Run before the fix, it printed:

   ```
   LATE  Extendible Hydraulic Hands/Arm = 150000 - cites triax p153-p153, printed one page later
   ```

   **The true statement is narrower:** the dampers row is invisible to it
   because its `cost` is NULL, so `valueSpellings` returns nothing and the row
   is never tested. A wrong citation on a row carrying a number is already
   caught. **This is the shape `audit-menu` warns about** - a finding arguing
   from a capability gap that does not exist, and the check was on this menu.
2. **Two rows were wrong, not one.**
   `add-triax-gear-e-cybernetics.sql:55`, the **Extendible Hydraulic Hands/Arm**,
   is also printed on 154 - `.cache/books/triax/txt/p154.txt:10-18`, closing
   *"Typical Arm P.S.: 10 to 20, Cost: 150,000 credits."* It is the first entry
   under that page's *Bionic Weapons & Combat Features* header, which is how it
   was missed.
3. **The file's own header was false in the same way and is corrected here.** It
   read that the four rows filed as `weapon` are *"the four on printed 154 that
   do damage"*, which quietly asserts that only four entries are on 154.
   **Six of the twenty-five are.** The file now says the four that do damage are
   all on 154 without claiming they are all of it, and carries a pointer saying
   two of its `p.153` strings are corrected later and by which script. **Its
   rows are left exactly as they shipped** - the correction is a later script,
   not a rewrite of what ran.

**The sweep the proposal asked for was done in full, and it settles the scope
the finding marked low.** All twenty-five rows checked against the folio printed
on the cached page, plus an independent name-token pass: **23 correct, 2 wrong,
0 unsettled.** The nineteen other `p.153` rows are on 153 and all four existing
`p.154` rows are right. The same pass over all fifteen `apps/character-creator/db/*triax*.sql`
flagged **no other file**.

**Why this is not `INGESTION-AUDIT` `F20`, which is the reason to be careful
here.** That finding also accused production rows of citing the wrong page; its
headline was **false**, and taking it found the four rows were correct and that
its fix *"would have destroyed a verified citation"*. The difference is the
evidence. `F20` had a page number that looked wrong. These two have a folio
reading **154** on the page carrying the entry, and a **stored value that
matches the printed one** - the hydraulic arm's `150000` against *"Cost:
150,000 credits"*, and the dampers' `+1/+2/+1` in the order the page prints
them. That is the standard `zzzzzz-triax-skill-citations.sql` set when it
repaired four skill rows, and it is met here.
<!-- claim-ok: quoting INGESTION-AUDIT.md:182-185, opened and read 2026-09-08 -->

**The entry directly below the dampers on that page is the RVB-31 Concealed
Vibro-Blade, which already cited p.154.** Two adjacent entries, one filed on
each page, which is the clearest statement of what went wrong: this file
assigned pages by **category** rather than by page.

**Measured, before and after, `--remote`.** `source-coverage.mjs --values` went
from **241 offenders (85 absent, 156 off by a page)** to **240 (85 absent, 155
off by a page)** - exactly the one row it could see. The dampers does not move
that number and never did, which is correction 1 restated as an observation.
Production reads `p.154` for both rows.

**What is NOT filed, deliberately.** Those remaining **155 gear rows off by a
page and 85 whose value is absent** are not a deferral hiding in this note: the
ledger reports them by design, `F1` owns that surface, and a finding would add
nothing a `--values` run does not already print. Naming them here rather than
filing them is the complete answer.

**Cite this one as `BOOK-INGEST-AUDIT` F40.** `SKILL-AUDIT` carries its own
unrelated `F40`, and a tree grep for the bare number returns mostly that one.
`node scripts/audit-citations.mjs --remote F40` reports **0 of 226 published
classes** cite it - and that script sees `extraction_notes` only, so the memory
store and the other menus were grepped by hand as well. Nothing cites it.

### F41 - the 24 gear rows that are really vessels span FIVE books, so the backfill is a book job and not a data script

**This is `F3`'s deferral, finally given a number.** That finding's 2026-09-07
note (line 430 of this file) says the 24 prose rows are *"the backfill a future
`vehicles` table would start from"* and that *"backfilling them is its own job
with its own decisions, chiefly what happens to the class equipment lists that
reference those gear slugs."* It named work and filed nothing, which is the shape
`audit-menu` now calls out. The decisions are settled below; the work is not
started.

**Filed while building the gear-and-vessels sequence** (PRs #848-#854), which put
readers on both catalogs and made the split visible: the codex now shows some
vessels in its Gear tab and some in its Vessels tab, and
`docs/plans/21-gear-and-vessels.md` says so under *What is NOT verified* rather
than hiding it.

**The measurement that re-scoped this.** All figures `--remote`, 2026-09-09:

| | |
|---|---|
| `gear` rows with `category = 'vehicle'` | **69** |
| of those, carrying `Main Body` in the description | **24** |
| the rest - stubs, mounts, worn kit | **45** |
| the 24 with a mechanically parseable `M.D.C. by location:` list | **7** |
| the 24 with M.D.C. buried in narrative prose | **17** |
| **distinct source books across the 24** | **5** |
| of the 24, carrying `Web reference (not book-verified)` | **1** |

```
node scripts/q.mjs --remote "SELECT source_book, count(*) AS n FROM gear WHERE category = 'vehicle' AND description LIKE '%Main Body%' GROUP BY source_book ORDER BY n DESC"
```

Wormwood 9, Juicer Uprising 7, Rifts Ultimate Edition 6, Phase World 1, and one
row with no book behind it at all.

**Why that changes the shape of the work.** The estimate this started from was
"a data script over 24 rows". It is not one, for two reasons and the second is
the serious one:

- **The prose is not uniform.** `glitter-boy-power-armor` reads *"M.D.C. by
  location: main body 770, head 290, arms 270 each, legs 450 each, hands 100
  each, rail gun 175, reinforced pilot compartment 150"* - transcribable.
  `battle-saint`, `battler-parasite` and `beetle-parasite` bury their numbers in
  narrative. Only 7 of 24 are mechanical.
- **The source would be a paraphrase, not a book.** Those descriptions were
  written by earlier import sessions reading the books. Deriving structured
  combat numbers from them is the thing this repo's ingestion discipline exists
  to prevent, and `book-survey` §8's batch protocol is one session per book.
  Twenty-four rows across five books is **five book sessions**.

**Proposal:** take this as **five book sessions, one per book**, not as one data
script - Wormwood, Juicer Uprising, Rifts Ultimate Edition, Phase World, and a
sixth decision for the web-sourced row. Each session re-reads its own book for
the vessels among these 24, writes `vehicles` + `vehicle_locations` +
`vehicle_weapons` rows the way the Triax and Free Quebec vessel imports already
do, and points the surviving gear row at the new vessel. **Posture: no schema
change from a book session** - see the decided half below, which is the one
schema change and belongs in its own PR ahead of them.

**The 45 are NOT part of this and should not be re-proposed.** They are not thin
vessels, they are **not vessels**: `riding-horse` is *"A trained riding horse."*,
`hovercycle` is *"the unspecified one a class list names"*, and
`wilk-s-jet-pack` and `tw-wing-board` are worn kit. A stub in `gear` reads as a
stub; a stub in `vehicles` reads as a vessel somebody failed to finish. Several
also carry `Estimate - no published price found`, and the README's estimate rule
(under *A third tier, for what nothing publishes*) forbids an estimated row
carrying M.D.C., damage or an A.R. at all - `samas-power-armor` is one of those,
so it could not be given a stat block even if somebody wanted to.

### The citation decision, which Nate settled on 2026-09-09

**Decided, so no book session re-litigates it: the gear row SURVIVES as the
citation target and points at the vessel.** Recorded here so it is not
re-proposed.

The problem it answers: `catalog_redirects` cannot express a cross-catalog move.
`db/schema.sql` comments its `to_id` column as *"row in that catalog's table"*,
and five query sites resolve a gear slug through it - `items.js`,
`characters/[id].js`, `characters/[id]/items/[itemId].js`,
`campaigns/[id]/items.js` and `campaigns/[id]/ask.js` - every one hard-coding
`catalog = 'gear'`:

```
grep -rn "catalog_redirects" functions/api/character-creator/ --include=*.js
```

So a row that simply LEFT `gear` would leave its class equipment citations
resolving to nothing, silently, in the wizard. Of the 13 slugs cited by class
markdown, 5 are among the 24 movers and carry 14 references; the heavy citations
- `hovercycle` at 21 classes, `riding-horse` at 12 - are all on rows that are
not moving.

The alternative, teaching the class format a vessel reference, was weighed and
declined: it touches the format and the wizard's resolution to buy honesty about
a row that the pointer already records.

**That needs one column - `gear.vehicle_slug`, a nullable pointer - and it is a
schema change, so it is NOT part of any book session.** It should land in its own
PR **before** the first of them, or the sessions have nothing to point at.

**Do not build that column before there is a vessel to point at**, either. A
pointer nothing uses is the silent-storage failure `F3`'s own closure declined
when it rejected the JSON option. The order that works is: the column and its
rendering in one PR, immediately followed by the first book session.

**Evidence:** the counts above are `scripts/q.mjs --remote`, run 2026-09-09, and
the command for the book split is quoted in full. The five-query-site claim is
the grep quoted directly above it, run the same day. The `to_id` wording is
quoted from `db/schema.sql`, which was read rather than recalled.
`docs/plans/21-gear-and-vessels.md` was written in PR #854 the same day and
carries the same figures.

**Confidence: high on the numbers, medium on the estimate of five sessions.**
The row counts, the book split and the query sites were all measured. What is not
measured is how much of each book still needs reading: Juicer Uprising, Phase
World and Rifts Ultimate Edition all have OCR caches present (`drift-check
--local`, 2026-09-09, reports 16 of 18 registered books cached), so a session
may find the pages quickly. **What would raise it:** open one book - Juicer
Uprising has the largest single share at 7 - and see how many of its rows have a
printed location block the cache can be read from.

**Ongoing cost: none once done, and that is the argument for doing it.** This is
a one-time correction that ends with 24 fewer rows in the wrong table and the
codex no longer splitting vessels across two tabs. The pointer column is one
nullable column with one reader. **The cost of NOT doing it is also small and
should be stated honestly**: the split is cosmetic, the data is present and
correct where it sits, and every one of those 24 rows renders its full prose in
the codex's Gear tab today. This finding is not urgent and says so.

**Taken for JUICER UPRISING, 2026-09-09 — one of the five book sessions this
finding proposes, not the whole of it.** Four books remain: Wormwood 9 rows,
Rifts Ultimate Edition 6, Phase World 1, and the one row with no book behind it.
Read under this heading rather than anywhere else for where it stands.

**The posture held.** The gear rows stayed, all seven of them, keeping their
slug, price, category and prose; each gained a `vehicle_slug` pointer. No schema
change came out of the book session — `gear.vehicle_slug` is migration 053 and
landed in its own PR ahead of it, which is what this finding asked for and what
`book-survey` section 8 requires of a book session.

**The premise audit did not happen the way `audit-menu` prescribes, and saying
so is the point.** The `audit-premise-auditor` subagent was launched first and
**stalled** — ten minutes in it had loaded its protocol and done nothing else —
so it was stopped and the premises were checked by the same session that then
implemented them. That is precisely the conflict the subagent exists to break,
and it was not broken. The corrections below are therefore worth less than they
would be from a cold reader.

**Two premises did not survive, both in the direction of less work:**

<!-- claim-ok: quoting the premises this note corrects -->

- This finding says **"only 7 of the 24 have a mechanically parseable `M.D.C. by
  location:` list"**. That was measured against the PARAPHRASE in the gear
  descriptions, repo-wide, and it understates this book badly: read from the
  book itself with `scripts/read-columns.py "<pdf>" 78 89` on 2026-09-09, **all
  seven** Juicer Uprising vessels carry a printed `M.D.C. by Location:` block.
  Nothing here had to be inferred. The figure may still hold for the other four
  books; it was not re-measured for them.
- This finding says the citation problem covers **"5 [of the 24] ... carrying 14
  references"**. For this book it is **one row**: `road-boss-motorcycle`, cited
  by two published classes. The other six are cited by nothing
  (`node scripts/q.mjs --remote`, joining `imported_classes.markdown`,
  2026-09-09). The decision to keep the gear row was still the right one — that
  one row would have broken silently — but the risk here was narrower than this
  finding implies.

**Premises that held:** 7 gear rows carrying `category = 'vehicle'` and this
book's `source_book`; `page_offset: 1`, confirmed the free way `book-survey`
section 0d prescribes, by reading the folio printed on the page — cache p84
carries printed 83; and **zero** Juicer Uprising vessels already in `vehicles`,
so this was a clean import rather than a merge.

**What shipped** (`zzzzzzz-ju-vessels-p077-088.sql`): 7 vessels, 43 M.D.C.
locations, 21 weapon systems, and 7 gear rows pointed at them. Seven z's because
`zzzzzz-vehicle-class-vocabulary.sql` asserts a vessel count of 127 and would be
falsified by these rows landing before it.

**The strongest evidence in the import is a coincidence nobody arranged.** Every
price was read off the book before the catalog was consulted, and all seven match
the `gear.cost` an earlier session stored — including `road-boss-motorcycle` at
**90,000**, which is the stripped price rather than the 200,000 armed one, so
that session applied the same low-end-of-a-range convention `gear.cost`
documents. Seven independent confirmations that the transcription is right,
which is what `book-survey` section 0c means by using the rows you already have
as a check on the reading.

**`ju`'s OCR cache was not used, and that is now recorded where a reader will
find it.** `book-survey` section 0b names it by slug as one of the caches built
by throwaway code, and reading it confirms the description: raw
`page.get_text()`, columns welded across the gutter, prose from both columns
interleaved line by line. Its manifest carries no `welded_pages` or
`corrupt_pages` key, which is the tell. `read-columns.py` reads the same pages
cleanly off the PDF. **The cache was left as it is** — rebuilding it is not this
finding's business and would have been a change made from a book session.

**One disagreement found in passing and not acted on:** the `ju` cache manifest
records `printed_pages: 160` where `scripts/books.json` records **159**. Neither
was used for anything here — the offset came from the folio — and it is filed
nowhere yet.

**The NG-JK1 is one row, not two.** The book prints one entry describing two
models with the heavier JK1B's figures in parentheses throughout. Nate settled
the shape on 2026-09-09: one vessel for the JK1A, the B figures in each
location's `mdc_note` and its price in `cost_note`. A second row would have
duplicated nine locations and five weapon systems to change nine numbers.

**Taken for WORMWOOD, 2026-09-09 — the second of the five book sessions, and it
shipped TWO vessels where this finding counts nine.** Three books remain: Rifts
Ultimate Edition 6 rows, Phase World 1, and the one row with no book behind it.

**The scope changed, and the book changed it.** This finding's Wormwood share
was measured with `category = 'vehicle' AND description LIKE '%Main Body%'`, and
that filter is wrong in BOTH directions here:

<!-- claim-ok: quoting the premises this note corrects -->

- **It includes eight rows that are living monsters.** The shock parasites —
  `battler-parasite`, `tick-parasite`, `beetle-parasite`,
  `monster-worm-parasite`, `tangle-worm-parasite`, `krikton-flailer`,
  `krikton-leaper`, `krikton-battle-wagon` — each print their own `Class:` line
  in the book, and all eight read `Class: Wormwood organism: <name> Parasite.`
  The two machines read `Class: Magic symbiotic war machine.` That is the same
  field `vehicles.vehicle_class` exists to hold, and the book fills it in
  differently for the two groups. Measured by grepping `^Class:` across cached
  printed 101-108 on 2026-09-09: eight hits, eight organisms, no exception.
- **It excludes `battle-saint-orb`, which IS one of these machines.** Its gear
  description says "M.D.C. is the pilot's own hit points or M.D.C. times 10"
  where the battle saint's says "main body", so the `LIKE` missed it. The book
  prints `M.D.C. by Location: Main Body` for the orb on printed 94, under the
  same `Class:` line as the saint. **So one of the two rows shipped here is not
  among this finding's 24**, and the count of movers is 23 + 1 rather than 24.

**This finding says `battle-saint`, `battler-parasite` and `beetle-parasite`
"bury their numbers in narrative".** Two of those three are counterexamples: both
parasites carry a full comma-separated per-location list in the gear description,
differing from the seven this finding counted only in the header phrase —
`M.D.C.:` rather than `M.D.C. by location:`. Across all 24 rows that shape holds
for **8 more**, and every one of the 8 is Wormwood, so `"17 with M.D.C. buried in
narrative prose"` is overstated by eight. **`battle-saint` is the real
exception, and for a reason this finding does not anticipate** — see the M.D.C.
paragraph below. (`node scripts/q.mjs --remote`, 2026-09-09.)

**The premise audit happened the way `audit-menu` prescribes this time**, which
the Juicer Uprising note above records it did not. `audit-premise-auditor` ran to
completion before any file was written, checked seven claims plus the posture,
and found three disagreements — the paraphrase-side count above, the closed
`vehicle_class` vocabulary, and that `scripts/read-columns.py` cannot read this
book. It reached the parasite problem from the gear rows alone and correctly
refused to open the PDF. **The decisive evidence is the book's own `Class:`
field, which only the implementing session could see**, so the two passes found
the same boundary from opposite sides — which is the point of running both.

**The eight parasites stay in `gear`, and that was already Nate's call.** The
`ww` survey's ledger records it under 2026-08-27: *"The 8 parasites ARE gear —
overriding this survey's first recommendation ... on the grounds that Ride Giant
Parasites and Summon and Command Parasites make them player-reachable."* Moving
them would reverse a settled decision, which is the failure `audit-menu`'s
subject grep exists to catch. The mechanical reason is stronger than the
taxonomic one: `vehicles` has nowhere to put a Horror Factor, an I.Q., attacks
per melee, save-vs-magic bonuses, prowl and climb percentages, or
bio-regeneration, and every parasite entry carries most of those. Importing one
would DROP them, which is worse than the cosmetic split this finding set out to
fix.

**The posture held.** Both gear rows kept their slug, prose and NULL price and
gained a pointer; no schema change came out of this session. It cost nothing
here, unlike the Juicer Uprising import: **no Wormwood gear slug is cited by any
class markdown at any status**, so nothing would have broken either way. The 45
were not touched or re-proposed.

**NO M.D.C. FIGURE EXISTS FOR EITHER VESSEL, and that is the book's answer
rather than a failed extraction.** A battle saint's main body is "equal to the
pilot's hit points/M.D.C. x 20" and every other location is a percentage of it;
the orb is x 10. So `mdc_main_body` is NULL on both rows and all six
`vehicle_locations.mdc` are NULL with the formula in `mdc_note`. **Nothing had
to be widened**: `vehicle_locations.mdc` comments itself *"NULL where a book
prints a formula"*, so migration 048 anticipated this three weeks before anyone
needed it. A reader who wants a number gets the book's own worked examples from
the notes — a pilot with 32 hit points instills 640 in a saint and 320 in an orb.

**What shipped** (`zzzzzzz-ww-vessels-p093-095.sql`): 2 vessels, 6 M.D.C.
locations, 4 weapon entries, 2 gear pointers. Seven z's to sort after
`zzzzzzz-ju-vessels-p077-088.sql`, whose readback asserts a global pointer count
of 7 and would be falsified by these two landing first.

**Every figure was read from the book and then confirmed against a RENDER.**
`ww` is a scan, so `scripts/read-columns.py` is unavailable — it needs a text
layer. The cached OCR of printed 93-95 was read first, then all three pages were
rendered at 200 dpi and read again; **they agree character for character on
every number in both entries**, which is a better result than this book's cache
had any right to give, since its manifest carries no `welded_pages` or
`corrupt_pages` key. The offset was confirmed the free way `book-survey`
section 0d prescribes and got three confirmations rather than one: the renders of
93, 94 and 95 each carry that folio at the foot of the page, so `page_offset: 0`
as `scripts/books.json` records. **The `ju` manifest disagreement does not recur
here** — `.cache/books/ww/manifest.json` and `scripts/books.json` agree on both
`page_offset: 0` and `printed_pages: 159`.

**There was no price cross-check to be had.** The Juicer Uprising import's
strongest evidence was seven printed prices matching seven stored ones. Wormwood
prices nothing — it runs on barter, and the Priest of Light O.C.C. prints
*"Money: Not applicable"* — so `cost` is NULL on every row on both sides and
there is nothing to agree. The confirmation here is the render instead.

**A spell list went into `vehicle_weapons`, and it is the one judgement call
worth flagging.** Neither machine has a weapon system; each has a melee list and
a `Magic Powers of Note:` list it casts a fixed number of times a day. Both are
`vehicle_weapons` rows with a `note` saying what they are — the convention the
Free Quebec import set for `Hand to Hand Combat` and `Combat Bonuses`. The spell
list is the only ranged offense either vessel has, and the alternative was
leaving it in description prose, which is the shape this finding exists to get
structured numbers out of. **The ordinals are this file's, not the book's**,
which is a departure from every other vessel script here and is said so in the
file.

**One correction filed in passing, in the same PR:** `docs/surveys/ww.md` cited
the Priest of Light's `Money:` line as printed 52. It is printed **54** — cached
`p054.txt` line 70, read 2026-09-09. The gear rows had it right all along.


**Taken for RIFTS ULTIMATE EDITION, 2026-09-09 — the third of the five book
sessions. It shipped FIVE vessels where this finding counts six, and it filed
three findings on the way.** Two books remain: Phase World 1 row, and the one row
with no book behind it.

**The count was wrong again, in both directions again.** This finding's RUE share
comes from `category = 'vehicle' AND description LIKE '%Main Body%'`, which
returns six. The book's `Common Vehicles` section on printed 266-267 is **five
machines and a jet pack**, and the filter:

<!-- claim-ok: quoting the premises this note corrects -->

- **includes `wilk-s-atv-transport-vehicle`, which is not a machine.** It is the
  Mountaineer ATV's stat block under a name assembled across a page break. `F43`.
- **includes `northern-gun-sky-king`, which this book does not print.** It is in
  the ORIGINAL core book, at the row's own stored 130. `F43`.
- **misses seven rows**, four of them the same five machines stored under a
  second slug: `speedster-hovercycle`, `big-boss-atv`, `mountaineer-atv`,
  `a-t-v-speedster-hover-cycle`. The `LIKE` selected the prose-rich copy of each
  machine rather than the book-correct one — the same asymmetry the Wormwood
  note records.

**The measurement to carry forward: `LIKE '%Main Body%'` has now been wrong for
all three books it has been tested against.** It counted 7 for Juicer Uprising
and understated the mechanical share; 9 for Wormwood where 2 were vessels; 6 here
where 5 are. It is a prose-shape filter, not a vessel test.

**Three findings came out of reading the book, and none of them was fixed here.**
`F41` is about moving vessels; rewriting catalog values from a book session is
not something this finding asked for:

- **`F42`** — six rows carry FIRST-EDITION M.D.C. under a RUE citation, and ten
  published class references point at them. Every divergence lands exactly on
  the older printing.
- **`F43`** — the two rows above, citing RUE for machines it does not carry.
- **`F44`** — `findDuplicates` scores two of the three duplicate pairs at 0.500
  and 0.333 against a 0.7 threshold, because `normaliseName` splits `A.T.V.`
  into three tokens.

**Filing three findings inside a take is this finding's own precedent** — `F41`
was itself filed while building the gear-and-vessels sequence, in the PRs that
shipped it. They ride in this PR rather than a separate one because a stacked PR
dies here when its base is deleted.

**THE PRICE CROSS-CHECK PASSED AND WAS WRONG, which is the most useful thing this
session learned.** The Juicer Uprising note above calls seven matching prices
*"the strongest evidence in this file"*, and `book-survey` section 0c prescribes
exactly that check. Here all six prices matched RUE and **six of six rows were
still wrong**, because RUE's errata moved the M.D.C. and left the prices alone.
A price agreeing across two editions says nothing about a combat number. `F42`
carries the table.

**The posture held.** All eight pointed gear rows kept their slug, prose and
values — including the four wrong ones, deliberately, so `F42` stays visible
rather than being quietly resolved by a session that had no mandate to. No
schema change came out of this session.

**Every gear row naming a machine points at that machine's vessel — eight rows,
five vessels.** A departure from the two earlier imports, where each vessel had
exactly one gear row, and it is what makes the duplication legible rather than
hidden. `wilk-s-atv-transport-vehicle` gets no pointer even though its figures
are the Mountaineer's, because its NAME is what `F43` disputes.

**What shipped** (`zzzzzzzz-rue-vessels-p266-267.sql`): 5 vessels, 11 M.D.C.
locations, 7 weapon entries, 8 gear pointers. Eight z's to sort after
`zzzzzzz-ju-vessels-p077-088.sql`, whose readback asserts a **global** pointer
count and would be falsified by these landing first.

**Read twice, because this one is a scan.** `rue` is `text_layer: false`, so
`scripts/read-columns.py` is unavailable exactly as it was for Wormwood. Every
figure was read from the cached OCR of printed 266-267 and confirmed against a
200 dpi render of both pages, with 500-600 dpi crops for the three numbers `F42`
turns on. The offset was confirmed the free way `book-survey` section 0d
prescribes — both renders carry their folio — so `page_offset: 3` as the
registry records, and the cache manifest agrees with it on `printed_pages` too.

**One printed value is missing from the book and is stored as missing.** The
Highway-Man's line reads `M.D.C. by Location: Main Body: 75, Tires (2)` and
stops; the motorcycle illustration overlaps where the number belongs, a 600 dpi
crop shows no digit under the art, and the OCR renders the same truncation. Its
`mdc` is NULL with the reason in `mdc_note`. Every other vehicle in the section
prints its tire figure.

**One readback was wrong on first apply** — `their weapon entries` asserted 8
against a file containing 7. Re-derived by counting the `VALUES` rows in the
file, which is the distinction the Juicer Uprising session got wrong three times.

**The premise audit ran to completion and found the edition mismatch from the
gear rows alone**, before the book was opened for it — it noticed that every
non-M.D.C. field matched RUE and inferred a different printing. Confirming that
against the original core book, and finding the Sky King's stat block there, was
this session's work. The two passes met in the middle, which is the shape the
Wormwood note describes.

**Taken for PHASE WORLD, 2026-09-09 — the fourth of the five book sessions, and
the first where this finding's count was RIGHT.** One row remains: the
web-sourced `glitter-boy-power-armor`, which is a decision rather than a book
session.

**One row, one vessel, and no correction to make.** `psionic-power-armor` is the
only `category = 'vehicle'` gear row citing this book — checked without the
`LIKE '%Main Body%'` filter as well, since that filter missed rows in two of the
three books before this one, and the wider query returns the same single row
(`--remote`, 2026-09-09). Saying so plainly matters: three consecutive
corrections would otherwise leave the next reader assuming a fourth.

**It is a machine by the test the Wormwood session established.** The book's own
`Class:` line reads `Psionic Assault Exoskeleton`, and the entry carries a crew,
a power system, a market cost and six numbered weapon systems. Nothing in it has
a Horror Factor or an I.Q., so nothing `vehicles` cannot hold would be dropped.

**THE STORED FIGURES WERE RIGHT ON THE FIRST READING — the first time in this
sequence.** The gear row holds `mdc = 210` and `cost = 4000000`; the book prints
`** Main Body - 210` and `Market Cost: Mark V: Four million credits. Mark X:
Eight million credits.` Both were read off the book before the catalog was
consulted, and the 4,000,000 is the low end of the two-model range, which is the
convention `gear.cost` documents.

**And this is not the evidence `F42` discredited.** That finding showed six RUE
rows whose PRICES matched RUE exactly while every M.D.C. came from an earlier
printing, because the errata moved combat numbers and left prices alone. Here
the M.D.C. matches as well, which is the check that actually bears weight, and
Phase World has had no second edition for a figure to drift between.

**Two models, one row**, on the shape Nate settled for the NG-JK1 in the Juicer
Uprising session. `Model Type: NF Model V or X (identical except for the
contragravity flight system)`, and the book prints ONE M.D.C. table for both:
the models differ in flight, weight, power system and price only. So the X's
figures ride in `speed_air`, `weight_tons` and `cost_note`. It applies more
cleanly here than it did there — the JK1B changed nine location values and still
got one row, where the Model X changes none.

**The ordinals are the book's, for the first time in this sequence.** Phase World
prints `Weapon Systems` numbered 1 through 6, so they are transcribed rather than
invented — unlike the Wormwood and RUE scripts, which had to number their own
because those books print prose. Entries 5 and 6 are not guns and say so in their
`note`, on the Free Quebec convention.

**THE CACHE WELDS PRINTED 129, AND THE RENDER IS WHY THAT DID NOT MATTER.** On
that page `Speed:` and `Running: 100 mph` from the left column interleave line by
line with `Flying:`, `Range:` and `Statistical Data:` from the right:

<!-- claim-ok: quoting the cache's own welded output -->

```
Speed: Statistical Data:
Running: 100 mph (160 km) maximum; the act of running Height: 9 feet (2.7 m)
```

That is the corrupting read `book-survey` section 0b names, in the same page that
carries the M.D.C. block. The figures happened to be separable by eye and would
not be in general. A 200 dpi render of all three pages separates the columns and
confirms every value. **The `phase-world` manifest carries no `welded_pages`
key**, so nothing warned about this — the same tell the `ju` and `ww` caches
gave, and the reason a render is not optional on a book cached before that
detector existed.

The offset was confirmed the free way section 0d prescribes and got three
confirmations: the renders of printed 128, 129 and 130 each carry that folio, so
`page_offset: 0` as `scripts/books.json` records. Zero is the awkward case
section 0d names, because there is no offset left to explain a wrong page with.

**The page citation was checked rather than copied.** The gear row cites
`p.128-130`, and it is right: the heading `Psionic Power Armor` sits at the foot
of printed 128 and the stat block ends on 130. Both earlier sessions found a
citation off by one or wider than the entry, so this one was verified.

**A weapon the prose names and the stat block omits.** Printed 129 says *the most
fearsome weapon of the armor is a two-handed energy blade, an artificial version
of a psi-sword*, and the numbered `Weapon Systems` list never mentions it, gives
it no damage and never returns to it. It is recorded in the vessel's description
as prose rather than as a seventh `vehicle_weapons` row, because numbering a
system the book does not number would put a weapon in the list that no reader can
find in the book.

**What shipped** (`zzzzzzzz-pw-vessels-p128-130.sql`): 1 vessel, 6 M.D.C.
locations, 6 weapon systems, 1 gear pointer. All ten readbacks passed on the
first apply. Eight z's, sorting after the Juicer Uprising and Wormwood files and
BEFORE the RUE one — the `ju` script asserts a **global** pointer count so every
later book must sort after it, while the `rue` script's readbacks are all
book-scoped, so `pw` sorting ahead of it alphabetically breaks nothing and a
ninth `z` would have bought a new tier row in `docs/operations.md` for nothing.

**The posture held.** The gear row kept its slug, prose and both values and
gained only a pointer. No schema change. `noro-mystic-warrior` is the one
published class citing it, which is fitting — the noro built the armour.

**What this session did NOT do, and it is a large thing.** This book stats
**eleven more vessels** in `Robots & Powered Armor` (printed 130-142) and
`Tanks & Infantry Fighting Vehicles` (143-149), plus every starship of 157-173.
`docs/surveys/phase-world.md` inventories all of them. **None is in scope**:
`F41` covers the gear rows that were already vessels in disguise, and importing
this book's vessel sections whole is a different job that nobody has asked for.
The survey's claim that *"There is no table for a vessel"* was true when written
on 2026-08-31 and is corrected in place, in this PR, with the date — migration
048 built one on 2026-09-03.

**THE PREMISE AUDIT RAN CONCURRENTLY WITH THE IMPLEMENTATION, NOT AHEAD OF IT,
and that is the same failure the Juicer Uprising note above records.** The
`audit-premise-auditor` subagent was launched first and then not waited for: the
book was read, the script written, applied to `--local` and committed while it
was still running. It can date the overlap itself — two of its own greps returned
different answers on a re-run, because this session edited the files between
them.

**So its findings are a post-hoc check of shipped work rather than an input to
scoping.** Everything it measured independently held — the single row, the
machine test, no duplicate, one citing class, a clean import, the registry and
the manifest agreeing — but the conflict the subagent exists to break was not
broken, for the second time in four sessions. **Launching it is not the same as
using it**, and the Juicer Uprising note's lesson was about a subagent that
stalled, where this one worked perfectly and was simply overtaken.

**It caught three defects anyway, two of them written by this session:**

- The survey ledger row said **`Applied --remote before the PR`** before the
  apply had happened, copying a form of words the other ledger rows had earned.
  Production still read 141 vessels when it checked. Reworded to say what is
  true: the apply is the merge gate, and the row was written first.
- `scripts/books.json` ended this book's note with *"Nothing in production cites
  this book yet"*, false since 2026-08-30 — measured `--remote` on 2026-09-09 it
  is **50 gear rows and 35 published classes**. It sits three lines from the
  `page_offset: 0` a book session relies on. Corrected, and **four other book
  notes in that file carry the same sentence**, at least one of them also stale.
  That sweep is NOT done here and is worth its own finding.
- `docs/operations.md`'s eighth-z row, written by the RUE session two PRs ago,
  overstated the ordering rule and got `rue` wrong. The only global readback
  among the vessel scripts is the Juicer Uprising one, so the whole constraint is
  *sort after `ju`*; the row claimed the book sessions are ordered by z-count
  from here on, which would cost a later reader a ninth `z` to buy nothing.
  Corrected in this PR.


**Taken for THE WEB-SOURCED ROW, 2026-09-09 — the last item, and F41 IS NOW
COMPLETE.** Five sessions, PRs #856-#857, #858, #859, #860 and this one.

**This was not the decision this finding expected, because its premise was
false.** F41 sets the row aside as *"a sixth decision for the web-sourced row"* —
a judgement about whether to trust an unverifiable figure — and all four earlier
notes repeat *"the one row with no book behind it"*.

<!-- claim-ok: quoting the premise this note corrects -->

**Three books on this machine stat the Glitter Boy, and one of them is a book
this very sequence had already opened.** Rifts Ultimate Edition printed 71-72
carries the entry under the row's own model designation, `USA-G10`, and prints
every one of the seven M.D.C. figures the row stored:

| the gear row, from the web | RUE printed 71 |
|---|---|
| main body 770, head 290, arms 270 each, legs 450 each, hands 100 each, rail gun 175, reinforced pilot compartment 150 | identical, all seven |
| "10 feet 5 inches, 1.2 tons loaded" | Height 10 ft 5 in (3.1 m); Weight 1.2 tons fully loaded |
| "60 mph; leaps 12 feet, or 22 with a running start" | Running 60 mph (96 km); leap 12 ft (3.6 m), plus 10 ft (3 m) running |
| "Laser weapons do HALF damage to it" | *"Laser weapons do half damage to the Glitter Boy!"* |

The original core book and Free Quebec printed 82 carry it too. **The RUE
session read only `Common Vehicles` on printed 266-267; this stat block sits 195
pages earlier in the O.C.C. chapter and was never in that session's filter.**

**ONE FIGURE WAS WRONG, and it is the kind the marker exists to catch.** The row
said `nuclear power (20 year charge)`; RUE printed 72 and the original core book
both print **25 years**, and Free Quebec prints 20 — so it was a blended reading
across editions. Corrected here.

**Correcting a gear value here is not what `F42` declined, and the difference is
the point.** `F42` left six RUE rows alone because *which edition the catalog
states* is a real decision with two coherent answers. This row stated no edition
and claimed no book at all; leaving a figure that contradicts the book it is now
cited to would have MANUFACTURED an `F42`. The repo already had the pattern —
`backfill-rue-equipment.sql` re-cites eleven web-sourced rows to RUE pages and
corrects what the book contradicts, each `UPDATE` guarded on the marker.

**A Glitter Boy was already in `vehicles`, and Nate chose not to point at it.**
The Free Quebec sequence imported `classic-glitter-boy-qgb-100` carrying all
seven figures **plus an eighth** — the Rimouski Left Forearm Weapon Package at
110, which the USA-G10 does not have, alongside a different Boom Gun model, a
20-year power system and Quebec's own price. Settled 2026-09-09: **import RUE's
USA-G10 as its own vessel** rather than send a RUE-cited row to Quebec's
production model. They are two machines, the books print them as separate
entries, and the catalog already holds five other Quebec variants beside the
classic. **The price was filled in on the same call** — RUE's 25 million for a
new complete machine, the 15-20 million band being a rebuilt or gunless suit
rather than the low end of one range.

**What shipped** (`zzzzzzzz-web-glitter-boy-p071-072.sql`): 1 vessel, 7 M.D.C.
locations, 3 weapon systems with the book's own ordinals, and one gear row
re-cited, priced, corrected and pointed.

**THE FILENAME IS THE ORDERING TRAP, HIT FOR REAL.** This file re-cites a ninth
gear row into `source_book LIKE '%Ultimate%'` and points it — and
`zzzzzzzz-rue-vessels-p266-267.sql` asserts that count is **8**. Named `gb-` it
would have sorted before that script and falsified its readback on a clean
rebuild; `web-` sorts after it at the same tier. Caught by reading the earlier
script's readbacks before choosing a name, which is the only thing that catches
it.

**One readback was wrong on first apply, and the error is worth recording.** It
asserted that no web-sourced row carries a combat number, on the strength of a
report rather than a measurement. **Four do** — `c-18-laser-pistol` (2D4),
`cyber-armor` (mdc 50, ar 16), `hand-axe` and `hatchet` (1D6 each). The true
claim is narrower: the Glitter Boy was the only web-sourced row with a
per-location M.D.C. stat block. The assertion now says four.

**And that turns up something this finding does not cover.** The README's
estimate tier forbids an ESTIMATED row from carrying M.D.C., damage or an A.R.
at all; the web marker carries no equivalent rule, and those four rows hold
combat numbers no book has been shown to back. Named here rather than filed.

**The README's own worked example is this row**, and it has been updated: it
argued the marker exists *"so a book correction knows what it is overwriting"*,
and on 2026-09-09 that is exactly what happened. Its count also said *Forty*,
measured 28, and is 27 now.

---

## F41 is closed, 2026-09-09

Twenty-four rows, five sessions, **fifteen vessels** imported and **nineteen gear
pointers** set. What the five sessions actually established, none of which this
finding predicted:

- **`LIKE '%Main Body%'` is a prose-shape filter, not a vessel test.** It was
  wrong for four of the five books — understating Juicer Uprising, counting 9
  Wormwood rows where 2 were vessels, 6 RUE rows where 5 are, and calling this
  row unverifiable. Only Phase World's count held.
- **The book's own `Class:` line settles what a thing is** — `Wormwood organism`
  against `Magic symbiotic war machine`, `Psionic Assault Exoskeleton`, `Laser
  Resistant Infantry Personnel Assault Unit`.
- **A matching price is not evidence the combat numbers are right.** `F42` is
  the case: six RUE rows whose prices matched exactly and whose every M.D.C.
  came from an earlier printing.
- **Three findings came out of the work** — `F42`, `F43`, `F44` — none of which
  this finding anticipated, all from reading books it assumed had been read.
### F42 - high - six Rifts Ultimate Edition gear rows carry FIRST-EDITION figures under a RUE citation, and ten published class references point at them

**Found while taking `F41` for Rifts Ultimate Edition, 2026-09-09**, by reading
the book the rows cite. Filed rather than fixed, because `F41` is about moving
vessels and a book session that quietly rewrote catalog values would be doing
something nobody agreed to.

RUE's `Common Vehicles` section is five vehicles and a jet pack on printed
266-267. Six catalog rows citing this book disagree with it on `mdc`, and every
one of the six matches the **original Rifts core book** instead - which
`scripts/books.json` already describes as the edition RUE revises: *"This is the
ORIGINAL Rifts core book; Rifts Ultimate Edition is its errata'd revision - the
same book, a later edition."*

| machine | original core book | RUE, printed 266-267 | the row carrying the old figure | classes citing it |
|---|---|---|---|---|
| Speedster Hovercycle | 75 | **85** | `a-t-v-speedster-hover-cycle` = 75 | **2** |
| Wastelander Motorcycle | 45 | **60** | `the-wastelander-motorcycle` = 45 | **4** |
| Big Boss ATV | 65 | **100** | `the-big-boss-a-t-v` = 65 | 0 |
| Mountaineer ATV | 140 | **210** | `the-mountaineer-a-t-v` = 140 | 0 |
| Wilk's Jet Pack | 20 | **30** | `wilk-s-jet-pack` = 20 | **1** |
| Highway-Man Motorcycle | 75 | 75 | `the-highway-man-motorcycle` = 75 | 4 |

The Highway-Man row is in the table because it is the control: its main body did
not change between editions, and its row is right in both. **Ten published class
references point at rows whose figure RUE errata'd** - `cyber-knight`,
`mind-melter`, `combat-cyborg` and `juicer-wannabe` cite the Wastelander;
`cyber-knight` and `mind-melter` also cite the Speedster duplicate.

**Every other field in these rows matches RUE exactly** - speed, range, length,
weight, and both prices. That is what makes this an edition mismatch rather than
a transcription error: RUE's errata moved the M.D.C. and the tire counts and
left the prices alone.

**AND THAT IS WHY THE OBVIOUS CHECK PASSED.** `book-survey` section 0c says to use
the rows you already have as a check on the reading, and the Juicer Uprising
import above calls seven matching prices *"the strongest evidence in this
file"*. Here **all six prices matched and every one of the six rows was still
wrong**, because price is exactly the field the errata did not touch. A price
agreeing across two editions is not evidence that a combat number did.

**Proposal:** decide which edition the catalog states for these six rows, then
make the citation and the value agree. Two coherent answers, and this finding
does not pick one:

- **RUE wins** - update the six `mdc` values to 85 / 60 / 100 / 210 / 30, keep
  the `Rifts Ultimate Edition` citations, and the ten class references silently
  become correct. Simplest, and matches what the rest of the catalog cites.
- **The original edition wins for these rows** - keep the values and re-cite
  them to the original core book. Honest about provenance, but `books.json`
  records that book as *"Cited by NOTHING since 2026-08-28"* and deliberately
  not cached, so this would reopen a spelling the repo retired.

**Posture: a decision, then a data script. Not an automatic overwrite**, and not
something a book session should have done on its own. The vessel rows shipped by
`F41`'s RUE session already carry RUE's figures and cite printed 266-267, so
until this is settled the codex shows both numbers - a Wastelander gear row
reading 45 beside a Wastelander vessel reading 60. That visibility is
deliberate.

**Evidence:** RUE figures read from the cached OCR of printed 266-267 and
confirmed against a 200 dpi render of both pages, with 500-600 dpi crops for the
Wastelander and Mountaineer, 2026-09-09. Original-edition figures read the same
day from `Rifts Main-206-230.pdf` pages 21-23 as a throwaway probe - that book is
registered `page_offset: null` and its `books.json` note says not to cache it, so
nothing was cached. Citation counts from `imported_classes.markdown`, `--remote`.

**Confidence: high** on every number and on the edition diagnosis - five of five
divergences land exactly on the older printing, which is not a coincidence
available to a transcription error. **Medium on the remedy**, because which
edition the catalog should state is Nate's call and not a measurement. **What
would raise it:** checking whether other RUE-cited gear outside the vehicle
section shows the same pattern; this finding measured only the vehicles.

**Ongoing cost: none once decided.** One data script over six rows, and no new
check to maintain. **The cost of NOT doing it** is that four published classes
hand a player a motorcycle with 25% less M.D.C. than the cited book gives it,
which is the kind of error nothing in this repo would ever surface on its own.

**Taken, 2026-09-09 (PR #864). Nate chose RUE**, so the values move and the
citations stay. Ten published class references become correct without a single
class being touched, which is the argument for this direction over re-citing to
the older book.

**Five rows moved; the sixth is the control and is asserted unchanged:**

| row | was | now |
|---|---|---|
| `a-t-v-speedster-hover-cycle` | 75 | **85** |
| `the-wastelander-motorcycle` | 45 | **60** |
| `the-big-boss-a-t-v` | 65 | **100** |
| `the-mountaineer-a-t-v` | 140 | **210** |
| `wilk-s-jet-pack` | 20 | **30** |
| `the-highway-man-motorcycle` | 75 | 75 — unchanged in **both** editions |

**THE SCOPE IS WIDER THAN THIS FINDING'S PROPOSAL, and saying so is the point.**
The proposal says *"update the six `mdc` values"*. Three of the rows also carry
the figure **in prose**, as a `M.D.C. by Location:` list, and moving the column
without the prose would leave each row contradicting itself — a worse state than
the one this finding was filed about. So the prose moved too, and with it the
**tire counts**, because the errata changed those as well:

<!-- claim-ok: quoting the premise this note widens -->

- `the-wastelander-motorcycle` — `Tires (2) 1 each` to `2 each`
- `the-mountaineer-a-t-v` — `Super Tires (3)` to `Super Tires (4)`
- `the-big-boss-a-t-v` — tires already matched RUE

`a-t-v-speedster-hover-cycle` and `wilk-s-jet-pack` carry no M.D.C. prose at all;
the column is the only place their figure lives.

**Two dash characters, and the file is pure ASCII.** `the-big-boss-a-t-v` writes
`Main Body - 65` with an ASCII hyphen; the other two write an EM DASH, codepoint
**8212**, measured with `unicode()` against production rather than guessed. The
script builds it with `char(8212)`: a literal would fail `d1-apply`'s pre-flight,
and getting it wrong would have matched nothing silently and left the prose stale
while the column moved. Four readbacks check the prose specifically, for exactly
that reason.

**The duplicate pairs now agree and are deliberately NOT merged.**
`speedster-hovercycle` and `a-t-v-speedster-hover-cycle` both read 85,
`big-boss-atv` and `the-big-boss-a-t-v` both read 100, `mountaineer-atv` and
`the-mountaineer-a-t-v` both read 210. Value-identical is what makes them cleanly
mergeable — but merging live rows that classes cite is duplicate-review work and
needs Nate. `F44` made two of the three visible to `findDuplicates` for the first
time, and `F43` already retired the fourth.

**Every figure was read from a render, and two were confirmed twice.** The RUE
values came off 200 dpi renders of printed 266-267 and 71-72 during the `F41`
sessions; the first-edition values off `Rifts Main.pdf` as throwaway probes. The
`F43` session then re-confirmed two of them independently from a render of
core-book printed 228 — `Wilk's Jet Pack ... Main Body - 20` and the
Mountaineer's `Black Market Cost: 64,000` — from a different page than the one
this finding measured.

**Nine z's**, because `zzzzzzzz-rue-vessels-p266-267.sql` asserts *"the
first-edition figures are still in gear, unaltered"* for four of these five rows.
See the ninth-tier row in `docs/operations.md`.

### F43 - two gear rows cite Rifts Ultimate Edition for machines it does not print

**Found the same way, 2026-09-09**, and separate from `F42` because the remedy is
different: these rows are not carrying the wrong *value*, they are carrying the
wrong *book*.

**`northern-gun-sky-king` is in the ORIGINAL core book, and RUE dropped it.**
`Rifts Main-206-230.pdf` page 23 prints its stat block - `Main Body - 130`, and
*"Depleting the M.D.C. of the main body will destroy the Sky King"* - which is
the row's stored `mdc` exactly. In RUE the only occurrence across all 382 cached
pages is a passing aside inside a skill description on cache `p321` line 121,
*"bike, skycycle (like the Sky King) or jet propelled one- or two-man"*. So the
row is real, correctly transcribed, and cited to the one edition that does not
contain it.

**Half of this was already known and the other half was not.** The 2026-08-28
re-provenance pass held this row back as one of eleven RUE rows under names the
book does not print - `apps/character-creator/db/zzzz-cite-rue-rows.sql` and
`apps/character-creator/docs/surveys/rue.md` both record the eleven, and
`SELECT count(*) FROM gear WHERE source_book = 'Rifts Ultimate Edition'` returns
exactly 11 today. That pass correctly declined to cite it by page. **What it did
not do is take the citation away**, so the row still asserts a book that does not
carry it. `catalog-reprovenance-passes` in the memory store makes the general
version of this point: the ledger sees an absent citation, never a wrong one.

**`wilk-s-atv-transport-vehicle` is not a machine at all.** It is the Mountaineer
ATV's stat block under a name assembled across a page break. The Mountaineer's
heading sits at the foot of printed 266 and its stat block continues at the top
of 267, opening `Vehicle Type: Three wheeled armored ATV transport vehicle.`;
the next heading below that is `Wilk's Jet Pack`. The row's `mdc` 210 and `cost`
76,000 are the Mountaineer's figures digit for digit. Grepping all sixteen
cached books for `ATV Transport` returns one file - `rue` cache `p270` - and
that hit is the Mountaineer's own `Vehicle Type:` line. There is no such entry
in any book here.

This is the same page-break failure recorded for Juicer Uprising, which put two
wrong `starting_money` figures into live data: **a value read above a break and a
name read below it.**

**Proposal:** re-cite `northern-gun-sky-king` to the original core book, or
retire it - it is cited by **0** classes at any status, so either is cheap.
Retire `wilk-s-atv-transport-vehicle` through `catalog_redirects` to
`mountaineer-atv`, which is the row that names what the book prints; it too is
cited by **0** classes. **Posture: a merge and a re-citation, no schema change,
and no new check.** Both rows keep their history in `catalog_redirects` rather
than being deleted.

**Evidence:** the greps and page reads above, all 2026-09-09. Citation counts
from `imported_classes.markdown`, `--remote`, at any status. The eleven-row count
is the `--remote` query quoted above.

**Confidence: high** on both diagnoses - the Sky King's stat block was read off
the original book and the `ATV Transport` grep covers every cached book on this
machine. **What would raise it:** nothing for the Sky King. For the transport
vehicle, confirming no OTHER Palladium book prints a Wilk's ATV - only the
sixteen cached here were searched, and the registry lists eighteen.

**Ongoing cost: none.** Two rows, one redirect and one citation change.

**Taken, 2026-09-09 (PR #863).** Posture held: a merge and a re-citation, no
schema change, no new check. Nate settled the Sky King's half on the same day —
re-cite rather than retire.

**`northern-gun-sky-king` is re-cited to `Rifts RPG (original core book) p.228`**
and its figures are untouched. The core book prints `Model Type: NG-A70`,
`*Main Body - 130` and `Black Market Cost: 1.5 million credits, and up`; the row
stored 130 and 1,500,000. That registry entry says the book is kept *"so the
spelling stays known vocabulary if it reappears"* — this is the reappearance it
was kept for, and nothing cached the book to do it.

**THE PAGE THIS FINDING WAS FILED WITH WAS WRONG BY TEN.** The premise audit
reported the stat block at pymupdf index **218**; searching the whole PDF puts it
at **228**, and a 200 dpi render carries the folio 228 at the foot of the page.
**The number that mattered — 130 — was right in both readings**, which is exactly
how a wrong page citation survives a review: the claim it supports is true.

**`wilk-s-atv-transport-vehicle` is retired into `mountaineer-atv`** through
`catalog_redirects`, on the `zzzzzz-ingestion-f28-law-canonical.sql` pattern —
redirect first so the slug keeps resolving, then a guarded DELETE. Nothing owned
it: no `character_items` row, no class citation at any status, no existing
redirect.

**Its figures were carried across before it went, and that is the difference
between a merge and a delete.** `mountaineer-atv` was a stub with `mdc` and
`cost` both NULL; it now holds the 210 and the 76,000 the retired row had been
carrying for the same machine. The catalog loses a fabricated name and keeps
every number.

**One page confirmed three separate claims.** The render of core-book 228 also
shows `Wilk's Jet Pack ... Main Body — 20` against RUE's 30, and the Mountaineer's
`Black Market Cost: 64,000` — both `F42` cases, corroborated from a different
book than the one that finding measured.

**A ninth z-tier was created, and the reason is new.** Every earlier tier existed
because of rebuild order. This one exists because
`zzzzzzzz-rue-vessels-p266-267.sql` **asserts the state of the rows these two
findings change** — that four rows still carry first-edition figures, and that
both disputed rows still exist. Deleting one makes that readback fail on a clean
rebuild. `docs/operations.md` now carries the tier and states the general form:
**a script that changes what an older script asserts needs a later tier, even
when nothing about a rebuild requires it.**

The clean-run `gear` count moves 1253 to 1252.

### F44 - `findDuplicates` cannot see an acronym written two ways, so two of three real duplicate pairs are invisible

**Found while taking `F41` for Rifts Ultimate Edition, 2026-09-09.** `F42` and
`F43` together describe five RUE machines stored under nine gear slugs. Three of
those are duplicate pairs, and the detector reports one of them.

Scored by importing the live module and calling it directly -
`node --input-type=module` against
`functions/api/character-creator/_lib/catalog-merge.js`, 2026-09-09, with
`THRESHOLD = 0.7` at line 168:

| pair | `normaliseName` output | score | reported? |
|---|---|---|---|
| Speedster Hovercycle / A.T.V. Speedster Hover Cycle | `speedster hovercycle` vs `a t v speedster hover cycle` | **0.750** | yes |
| Big Boss ATV / The Big Boss A.T.V. | `big boss atv` vs `the big boss a t v` | **0.500** | no |
| Mountaineer ATV / The Mountaineer A.T.V. | `mountaineer atv` vs `the mountaineer a t v` | **0.333** | no |
| Mountaineer ATV / Wilk's ATV Transport Vehicle | `mountaineer atv` vs `wilk s atv transport vehicle` | **0.200** | no |

**The cause is one line of normalisation.** `A.T.V.` becomes the three tokens
`a t v`, which can never match the single token `atv`, so the acronym that makes
the two names obviously the same machine is the exact thing that stops them
scoring. The pair that IS reported passes on the words around the acronym rather
than on the acronym, and it is reported in the weakest tier.

**This is not `F33` and not `INGESTION-AUDIT` `F29`, and both were checked before
filing.** `F33` proposed building a gear duplicate detector and its outcome note
records that one already existed and found three of its four pairs; `F29`
rewrote that detector for the gear catalog. Neither touches acronym tokenisation,
and neither mentions any of these six slugs - grepping both menus for
`speedster|mountaineer|big-boss|wastelander|highway-man|sky-king` returns no
hits, 2026-09-09. This finding is about a specific normalisation gap those two
left in place.

**Proposal:** in `normaliseName`, collapse a run of single letters separated by
periods into one token - `A.T.V.` to `atv`, `M.D.C.` to `mdc` - before
tokenising. **Posture: change the normaliser only. Do NOT move `THRESHOLD`**,
which would raise the false-positive rate across every catalog to fix a
tokenisation bug; and duplicate review stays a report a person reads, not a gate.

**Evidence:** the table above, produced by executing the shipped module rather
than by reasoning about it - which is what `audit-menu` says settles a claim
about a capability. The three pairs are live in production, 2026-09-09;
`catalog_redirects` and `catalog_pair_dismissals` hold no row for any of them.

**Confidence: high** on the mechanism and the scores, both executed. **Medium on
the impact beyond these rows** - no census was run of how many other catalog
names contain a dotted acronym. **What would raise it:** counting rows matching
`%.%.%` in `gear.name` and `skills.name` and re-scoring their neighbours.

**Ongoing cost: near zero.** One function, already unit-testable, and the change
can only make the detector see MORE pairs - which a person then reads. It cannot
merge anything on its own.

**Taken, 2026-09-09 (PR #862).** Posture held: `normaliseName` only.
`THRESHOLD` was not moved, no exit code moved, and duplicate review is still a
report a person reads rather than a gate.

**The fix is one line**, placed after the bracket and ampersand handling and
before the separator strip:

```js
.replace(/\b(?:[a-z]\.){2,}/g, (m) => m.replace(/\./g, ''))  // A.T.V. -> atv
```

**TWO OR MORE letters**, so a trailing initial or an ordinary abbreviation is
untouched — `St. John` normalises the same as it always did.

**The two target pairs, re-measured after the change:**

| pair | before | after |
|---|---|---|
| Big Boss ATV / The Big Boss A.T.V. | 0.500 | **0.950** |
| Mountaineer ATV / The Mountaineer A.T.V. | 0.333 | **0.950** |
| Mountaineer ATV / Wilk's ATV Transport Vehicle | 0.200 | 0.200 — correctly still apart |

**THE SWEEP THIS FINDING ASKED FOR WAS RUN, and it is the reason to trust the
change.** *"What would raise it: counting rows matching `%.%.%` and re-scoring
their neighbours."* Done across all four catalogs on 2026-09-09 by importing the
OLD module — checked out from git — beside the new one, so "before" is the
shipped code rather than a re-implementation of it:

| catalog | rows | names that normalise differently | pairs newly at or above 0.7 |
|---|---|---|---|
| gear | 1253 | 10 | **2** — both the intended targets |
| skills | 367 | 39 | **1** |
| spells | 681 | 0 | 0 |
| psionic_powers | 116 | 5 | 0 |

**Three new pairs in the whole catalog, and not one of them is false.** 54 names
normalise differently — every `W.P.`, `M.D.C.`, `I.S.P.` and `P.P.E.` in the
catalog — and the change is nearly inert outside the pairs it was written for.

**The third pair is a real find and is NOT merged here.**
`W.P. Heavy M.D. Weapons` / `W.P. Heavy Military Weapons` went 0.667 to 0.750.
Both are `Weapon Proficiencies`; the second cites `Rifts Ultimate Edition p.329`
and the first carries the bare `Rifts Ultimate Edition` that marks it as one of
the eleven rows the 2026-08-28 re-provenance pass held back, and
`docs/surveys/rue.md` lists `W.P. Heavy M.D. Weapons` among the skills RUE prints
no entry for. That is duplicate-review work with a live skill on each side, not
this finding's, and merging it would need Nate. **Recording it because the fix
surfaced it within a minute of shipping**, which is the argument for the fix.

**Three checks added to `smoke.mjs`, and two of them were proved by failing.**
Reverting `catalog-merge.js` makes *a dotted acronym collapses to one token* and
*a real duplicate pair clears the threshold because of it* fail, and restoring it
makes them pass — run both ways on 2026-09-09, per this repo's rule that a check
which has only ever passed proves nothing. **The third check passes either way**
and is said so here: it guards against over-collapsing rather than testing the
fix, and no injection makes it fail.

**Found in passing and NOT changed:** `catalog-merge.js` contains a literal NUL
byte at line 99, inside `pairKey`, as the delimiter between the two halves of a
key. It is deliberate and correct — a NUL cannot occur in a name — but it is
written as a raw byte rather than the `\0` escape, which makes the whole file
read as *binary* to `grep` and would be silently lost by any tool that
round-trips the file through an encoding that cannot carry it. Changing it to
`\0` would be byte-for-byte equivalent in behaviour. Named rather than done,
because it is not this finding.

### F45 - six book notes in the registry made a standing claim about live data, and four of the six were false

**Found while taking `F41` for Phase World, 2026-09-09**, by a premise audit that
noticed one such sentence three lines from the `page_offset` that session
depended on. Filed and taken the same day.

`scripts/books.json` is the registry three mechanisms read as a contract. Six of
its `note` fields ended with the sentence:

<!-- claim-ok: quoting the sentence this finding is about -->

> Nothing in production cites this book yet.

**It is a claim about the live database, written into a static file, in the
timeless present tense.** It stops being true the moment its book is imported,
and nothing updates it. Measured `--remote` on 2026-09-09:

| book | what the note claimed | what production held |
|---|---|---|
| `underseas` | nothing cites it | **87 gear, 74 spells, 50 vessels, 15 skills, 30 classes** |
| `free-quebec` | nothing cites it | **17 gear, 22 vessels, 13 classes** |
| `fom` | nothing cites it | **13 classes** |
| `rifts-core` | *"Cited by NOTHING since 2026-08-28"* | **1 gear row** — falsified by `F43` the same day |
| `spirit-west` | nothing cites it | nothing. **True.** |
| `mystic-russia` | nothing cites it | nothing. **True.** |

**Four of six false, and one of the four was falsified by this session's own
work.** `F43` re-cited `northern-gun-sky-king` to the original core book that
morning, which made `rifts-core`'s note wrong within the hour — and the note's
very next sentence explains that the book is kept *"so the spelling stays known
vocabulary if it reappears"*. It reappeared, and the sentence before it still
said it had not.

**THE COUNT IN THIS FINDING'S FIRST TELLING WAS ALSO WRONG.** The `F41` Phase
World note says *"four other book notes in that file carry the same sentence, at
least one of them also stale"*. It is **six** notes, and **four** are stale. That
figure came from a grep windowed on a substring position, which found three of
the six; the honest way is to parse the JSON and read every `note`, which is what
the check below does.

**Taken, 2026-09-09 (PR #865). Posture: correct the notes, and make the shape
impossible rather than the instances correct.**

- The four false notes now state a **dated measurement** — *"As of 2026-09-09
  production held 87 gear rows..."* — which cannot rot, because it says when it
  was true.
- The two TRUE notes were rewritten the same way rather than left alone. *"No
  production row cited this book as of 2026-09-09"* is the same fact with a date
  on it, and it will not become a lie the day someone imports the book.
- `rifts-core` now records the Sky King and keeps its history.
- **A check in `book-registry.mjs` refuses the sentence shape**: any `note`
  matching `cites this book yet` or `Cited by NOTHING` fails, naming the slugs.
  Proved by injecting the old sentence into `spirit-west` and watching it fail
  by name, then restoring - per this repo's rule that a check which has only ever
  passed proves nothing.

**One quotation had to be paraphrased to make the rule mechanical.** The
`phase-world` note, corrected earlier the same day, QUOTED the banned sentence
while explaining that it used to say it - the same collision `menu-check.mjs`
handles with a `claim-ok` marker. Rather than build an exemption for one case,
the quotation was reworded. **A rule with no exceptions is cheaper than a rule
with one.**

**Confidence: high.** Every count is a `--remote` query on 2026-09-09 and the
check was proved by failing. **Ongoing cost: one check that runs offline in the
existing suite, and a convention that a registry note carries a date.** The
alternative - policing the claims by hand - is what produced four false ones.

### F46 - the web marker has no rule against combat numbers, and four rows held them

**Found while closing `F41`, 2026-09-09**, by a readback that asserted no
web-marked row carries a combat number and was **wrong**. Four did. Filed and
taken the same day, on Nate's call to search the books rather than only file.

The README's estimate tier forbids a row marked `Estimate - no published price
found` from carrying M.D.C., damage or an A.R. at all. `Web reference (not
book-verified)` carries **no equivalent rule**, and these four held combat
numbers under it: `c-18-laser-pistol` (2D4), `cyber-armor` (mdc 50, A.R. 16),
`hatchet` and `hand-axe` (1D6 each).

**SEARCHING CLOSED THREE OF THE FOUR, which is the argument for searching rather
than stripping.** All three are in Rifts Ultimate Edition, read from the cached
OCR and then confirmed against a render, because `rue` is a scan:

| row | printed | what the book gives | kind of evidence |
|---|---|---|---|
| `c-18-laser-pistol` | **257** | `Mega-Damage: 2D4 M.D.` | full stat block |
| `cyber-armor` | **65** | `Armor Rating: 16`, `Chest Plate (main body) - 50 M.D.C.` | full stat block |
| `hatchet` | **56** | `hatchet for cutting wood (1D6 S.D.C. damage)` | **not** a stat block |

**The C-18 matched on every field, not just the one this finding is about** —
weight 4 lbs, range 800 feet (244 m), payload 10 shots, 12,000 credits, all
already stored. A complete and accurate transcription of a page nobody credited,
the same shape as the Glitter Boy in `F41`'s last session.

**The hatchet is the weak citation and is labelled as one.** Its figure is a
parenthetical inside the Crazy O.C.C.'s `Standard Equipment` line, not a weapon
entry. Printed, on a page, render-confirmed — but weaker than the other two, and
recorded as such rather than flattened into them.

**`hand-axe` keeps the marker, and it is a duplicate nobody has merged.** Every
hit across all sixteen caches, under both spellings, is a class equipment list
naming *"a small hand axe"* with no damage figure. **And on the evidence it is
the same item as `hatchet`**: identical damage (1D6), weight (3), cost (40) and
category. `F44`'s acronym fix cannot see this pair — the names share no token at
all — so `findDuplicates` will not report it either. Not merged: that is
duplicate-review work with two live rows and needs Nate.

**So the end state is ONE web-marked row carrying a combat number, not zero**,
and it is the one that genuinely has no book behind it. The README count moves
27 to 24.

**Posture: re-cite what the books support, mark what they do not, merge nothing.**
No new rule was added forbidding combat numbers under the web marker — `hand-axe`
shows why one would be wrong: the row is honest, and the marker is doing exactly
the job the README describes. **Confidence: high** on the three citations, all
render-confirmed; **high** on the absence for `hand-axe`, which is a search of
every cache on this machine and therefore bounded by which books are here.


**Taken, 2026-09-09 (PR #866).** Posture held: re-cite what the books support,
mark what they do not, merge nothing, and add no new rule - `hand-axe` was left
marked precisely because a rule banning combat numbers under the web marker
would have been wrong about an honest row.

**Then `F47` closed the last of it.** RUE prints the hand axe on printed 99 too,
so that row was cited rather than left marked, and **no web-marked row carries a
combat number any more.** The count this finding opened at four is now zero, and
every one of the four was closed by searching the books rather than by stripping
a value or adding a prohibition.

### F47 - three of the five duplicate pairs were duplicates; the other two were the book naming two things

**Taken on Nate's word, 2026-09-09 (PR #867).** Five candidate pairs came out of
`F42`, `F43`, `F44` and `F46`. Reading the book split them three to two, and the
two that failed the test are the more useful half.

**THREE REAL MERGES**, each retiring the `the-...` variant an earlier session
built from the first edition, keeping the short slug whose name is what RUE
prints and which already carried the page citation and the vessel pointer:

| retired | survives | classes citing the retired row |
|---|---|---|
| `a-t-v-speedster-hover-cycle` | `speedster-hovercycle` | 2 |
| `the-big-boss-a-t-v` | `big-boss-atv` | 0 |
| `the-mountaineer-a-t-v` | `mountaineer-atv` | 0 |

**The retiring rows carried weight the survivors lacked**, and it moved first -
700 lbs, 2000 (one ton) and 12000 (six tons), all matching RUE, against three
NULLs. A merge that dropped them would have lost data to tidy a name.

**AND ONE STILL HELD A FIRST-EDITION PRICE, WHICH CORRECTS `F42`.**
`the-mountaineer-a-t-v` carried `cost = 64000`; RUE prints 76,000. `F42` moved
the M.D.C. and the tire counts on these rows and left the price, because its
premise was that *"every other figure ... (speed, range, length, weight, both
prices) matches RUE exactly"*.

<!-- claim-ok: quoting the premise this note corrects -->

That was true of the other rows and **false of this one** - the first edition
prices the Mountaineer at 64,000, as the render of core-book printed 228 shows.
The merge retires the wrong figure rather than correcting it, same outcome by a
different route, and it is recorded because the premise stays wrong in `F42`'s
own text.

**TWO PAIRS THAT ARE NOT PAIRS.** Both were flagged on matching numbers, and the
book names each of them separately:

- **`hand-axe` and `hatchet`** have identical damage (1D6), weight (3) and cost
  (40) - and RUE prints both, on different pages: printed **99** gives *"survival
  knife and hand axe (both do 1D6 S.D.C. damage)"*, printed **56** gives
  *"hatchet for cutting wood (1D6 S.D.C. damage)"*. Two simple chopping tools
  with the same numbers are not one item. Merging would have changed what
  **eleven** published classes hand a player.
- **`W.P. Heavy M.D. Weapons` and `W.P. Heavy Military Weapons`** are printed on
  the SAME page, printed **329**: `Heavy Military` covers grenade launchers,
  mortars, machine-guns and light M.D. turrets; `Heavy Mega-Damage` covers plasma
  ejectors, M.D. rail guns, rocket launchers and robot cannons. Different skills
  for different weapons. Merging would have changed **twenty-seven** class
  references.

**`F44`'s detector surfaced the W.P. pair the day it shipped, and it is a FALSE
POSITIVE - which is the detector working.** Duplicate review is a report a person
reads, not a gate; the report was right to raise it and a person was right to
decline it. That is the posture `F44` shipped with, tested by its first real case.

**Both non-pairs were CITED instead of merged.** `hand-axe` to printed 99 and
`W.P. Heavy M.D. Weapons` to printed 329 - the latter was one of the eleven rows
the 2026-08-28 re-provenance pass held back under a bare book title.

**And that closes what `F46` left open.** Citing the hand axe takes the count of
web-marked rows carrying a combat number from one to **zero**. The rule the
estimate tier states explicitly now holds for the web marker too - reached by
searching the books rather than by adding a rule.

**Two readbacks were wrong on the first `--local` apply**, and both are worth
recording:

- *"five RUE gear rows still point at a vessel"* - it is **six**. Nine
  Ultimate-cited rows carried a pointer, not eight: the RUE vessel session set
  eight and the Glitter Boy added a ninth when PR #861 re-cited it into this book.
  A derived count, derived wrong.
- *"the owned hand axe is untouched"* asserted a `character_items` row that
  **production has and a fresh local database does not**. It was true and still
  failed. Replaced with the invariant that actually matters - no inventory row
  points at a deleted gear row - which holds in every environment.

Clean-run `gear` count 1252 to 1249; the web-marker count 24 to 23.

### F48 - a literal NUL byte in `catalog-merge.js` made the whole file unreviewable

**Found while taking `F44`, 2026-09-09, and named in that note rather than
changed.** Taken the same day (PR #869) on Nate's word.

`pairKey` joins the two halves of a duplicate-pair key with a NUL, which is the
right separator: a NUL cannot occur in a catalog name, so no name can be mistaken
for a pair. **It was written as a raw `0x00` byte in the source rather than the
`\u0000` escape**, and one invisible byte changed how every tool sees the file:

- `grep` skipped it entirely, reporting only *"binary file matches"*. Every
  search of this repo's `_lib` for a function name silently missed this file.
- **`git diff` rendered every change as `Bin 24839 -> 25820 bytes`.** `F44`'s
  normaliser change - a one-line fix to how duplicate detection tokenises names -
  shipped in PR #862 **with a diff no reviewer could read.** That is the cost,
  and it had already been paid once before anyone noticed.

**The fix is `\u0000`, and it is byte-for-byte identical at runtime.** Proved
rather than asserted: `pairKey('Big Boss ATV', 'The Big Boss A.T.V.')` was
captured before and after and the codepoint sequences match exactly, NUL
included, and `pairKey(a,b) === pairKey(b,a)` still holds.

**Nothing persisted depended on it.** `catalog_pair_dismissals` is the only table
holding a pair key and it has **0 rows** (`--remote`, 2026-09-09) - and the
runtime string is unchanged in any case, so a stored key would still have
matched.

**THIS PR'S OWN DIFF IS STILL BINARY, and that is the clearest demonstration of
the problem.** Git decides text-or-binary by looking at both sides: the OLD blob
contains the NUL, so the comparison is binary no matter what the new side looks
like. Every diff *after* this one is text. `.gitattributes` was checked and
applies no attribute to this file - nothing was forcing the behaviour but the
byte itself.

**A repo-wide scan found no other source file carrying a NUL** - every `.js`,
`.mjs`, `.json`, `.md`, `.sql`, `.html`, `.css`, `.py`, `.yml` and `.txt` outside
`.git`, `node_modules`, `.wrangler` and `.cache`. This was the only one.


**AND THE BUG REPRODUCED ITSELF TWICE WHILE BEING FIXED, which is the most
useful thing in this note.** Writing the paragraphs above put **two real NUL
bytes into this file**: the note was added with an inline heredoc, the Bash
tool collapsed the doubled backslash before Python ever saw it, and Python
read `\u0000` as an escape rather than as six characters of text. A third
NUL went into the pull request body the same way and the tool refused the
command outright, which is the only reason any of it was noticed.

The machine's own notes already say this: *the Bash tool eats a doubled
backslash - write scripts with the Write tool instead*. Both repairs were made
that way, building the escape byte by byte so no layer in between could
collapse it, and both files were checked for NUL bytes before the commit.

**So the class of bug this finding is about is not rare and not historical.**
It arrived three times in twenty minutes, in a markdown file, a pull request
body and a source file, from one shell behaviour - and only the instance that
happened to hit a validation check announced itself. The other two were
invisible and would have committed.

**Posture: change the literal to an escape, change nothing else.** No behaviour
change, no new check. A check would have to detect NUL bytes in source, which is
one grep nobody will remember to run against a problem that now has no instances.
**Confidence: high**, both halves executed. **Ongoing cost: none.**

### F49 - one skill taken THREE TIMES for three different weapons, and a class may grant it once

**Filed 2026-09-09**, during the `new-west` class import, batch 1.

New West's Gunfighter (printed 91) grants **three** W.P. Sharpshooting
specialties, and names the weapon each one sharpens: Revolver, Energy Pistol,
Energy Rifle. The book is explicit that this is how the skill works - printed
79-81 says Sharpshooting is bought once per weapon type, at a cost of two
O.C.C. Related picks each time, and that a character with
Sharpshooting: Revolver gets none of the bonuses when firing an energy pistol.

The catalog holds **one** row, `W.P. Sharpshooting`, and a class's
`occ_skills` is a list of skills granted once each. There is nowhere to put
"this skill, three times, for these three weapons". Granting it three times
would be three identical entries the sheet renders once; three catalog rows
named `W.P. Sharpshooting: Revolver` and so on would fragment a skill the books
treat as one, and would not compose with the Juicer Assassin, who takes the
same skill paired with W.P. Energy Rifle.

**Stored as:** one grant of `W.P. Sharpshooting`, with the three weapons in its
`note` and again in a `special_abilities` entry. Nothing is lost to a reader;
nothing is a number.

**Affected rows.** `gunfighter` today, and **three more classes in this book
will hit it before the import closes** - a grep of all 226 cached pages for
"Sharpshooting", run 2026-09-09 rather than assumed:

| class | printed | specialties |
|---|---|---|
| Gunfighter | 91 | 3 - Revolver, Energy Pistol, Energy Rifle |
| Gunslinger | 94 | 2 - Revolver and Energy Pistol |
| Psi-Slinger | 99 | revolvers and pistols |
| Wired Gunslinger | 108 | stated weapon by weapon |

**This paragraph first said "the Gunslinger, the Sheriff/Lawman and the
Psi-Slinger" at "printed 100 and printed 108", and three of those five facts
were wrong** - the Sheriff/Lawman gets no Sharpshooting at all, the Psi-Slinger's
grant is on printed 99, and the Wired Gunslinger was missing. The grep is above
because the guess was not worth keeping. Outside this book, `W.P. Sharpshooting`
carries the pairing rule in its own catalog note, from Juicer Uprising p.57 and
New West printed 79-81.

**Proposed change, NOT implemented.** The smallest shape that fits is a
`with:` list on an `occ_skills` entry - `{ name: "W.P. Sharpshooting",
with: ["W.P. Revolver", "W.P. Energy Pistol", "W.P. Energy Rifle"] }` - read by
`derive.js` into one row per pairing on the sheet. It is a display and
composition change rather than a new catalog concept, which is the argument for
it over three rows. **Check before scoping:** whether any published class
already grants `W.P. Sharpshooting` alongside a named W.P. in prose, and what
the sheet does with a skill granted twice today.

**Taken, 2026-09-10 (PR #909). Posture held: a display and composition change,
no new catalog concept.** `with` annotates an `occ_skills` entry, the wizard and
the sheet render it, and no catalog row, gear row or validator gate was added.

**ONE DEVIATION FROM THE PROPOSAL, AND IT IS FORCED.** The proposal asks for
*"one row per pairing on the sheet"*. That cannot ship: three rows named
`W.P. Sharpshooting` are refused with **HTTP 422 `duplicate_skill`** by
`functions/api/character-creator/_lib/validate-character.js:276-285`, which
keys on `norm(s.name)`. **Every Gunfighter would be unsaveable.** So the pairing
annotates ONE row instead - `W.P. Sharpshooting x3` with a sub-line reading
*"Taken once for each of: W.P. Revolver, W.P. Energy Pistol and W.P. Energy
Rifle."* The finding's goal is met; its stated shape is not.

**Four premises corrected, and three of them make the finding STRONGER:**

1. **"Granting it three times would be three identical entries the sheet renders
   once" is wrong, in the direction that matters.** Nothing collapses them for a
   single class - the by-name collapse at `js/parser.js:918-930` runs only when
   an R.C.C. and an O.C.C. are combined. The naive workaround does not render
   once; it makes the character unsaveable.
2. **"Nothing is lost to a reader" is FALSE for the character sheet.** The
   `occ_skills` `note` renders only in the wizard (`app.js:2220`) and was never
   carried onto the saved character - `skillsAtLevelOne` emitted
   `{name, category, pct, per_level, type}` and nothing else. **On a finished
   Gunfighter sheet the three weapons appeared NOWHERE.** That is the real bug
   this finding was describing, and it is what the fix repairs.
3. **The proposal names the wrong file.** It says the list would be *"read by
   `derive.js`"*; `derive.js` contains no `occ_skills` and builds no skill rows,
   and says so itself at `js/derive.js:183-185`. The surfaces are
   `app.js:2219-2225` (wizard), `app.js:3318-3350` (`skillsAtLevelOne`) and
   `sheet.js`.
4. **"There is nowhere to put 'this skill, three times'" is too strong.** The
   COUNT was already expressible - `{ name, choose: 3 }` is a fixed entry and
   the wizard already rendered `x3`. The PAIRING was the gap.

**FIVE AFFECTED ROWS BECOME THREE.** `with` requires two or more names, because
pairing one skill to one weapon is not a repetition:

| class | specialties | `with` |
|---|---|---|
| `gunfighter` | Revolver, Energy Pistol, Energy Rifle | yes |
| `gunslinger` | Revolver, Energy Pistol | yes |
| `wired-gunslinger` | Revolver, Energy Pistol | yes |
| `juicer-assassin` | Energy Rifle only | **no** |
| `psi-slinger` | a RESTRICTION, not a repetition | **no** |

The Psi-Slinger is the one to read twice: its Sharpshooting is automatic but
works ONLY for projectile revolvers and pistols it is psionically linked to.
That narrows one grant; `with` would misdescribe it. Both exclusions are
asserted in the data script so a later pass does not "finish the job".

**The `with` list REFERENCES grants the class already has** - all three classes
grant the paired W.P.s as separate `occ_skills` entries - so it adds no rows and
cannot trip `duplicate_skill`. **A regression check enforces that**: a `with`
naming a skill the class does not grant fails the suite, and a second check
asserts the sweep found some lists to look at. Proved by running the predicate
against a synthetic pairing of `W.P. Bazooka`, which it caught.

**The validator was proved to reject bad input rather than assumed to.** A
one-name list, a non-array, a list with a repeat and an empty list are all
refused with named errors; a valid two-name list is accepted.

**Verified in the running app, not only in tests.** Walked a real Gunfighter to
the skills step on a local server confirmed to be serving this branch, and the
DOM carries `W.P. Sharpshooting x3` followed by the pairing line, 353px down a
720px viewport - in view, not below the fold. **The browser pane could not
screenshot it**: it blanks after a programmatic scroll, which is a recorded
defect of that tool rather than of the page. The markup is byte-identical to the
`note` sub-line rendered directly beneath it, which already ships, so the two
cannot render differently.

**Deliberately NOT done, and named rather than left implied:** the entry's own
`note` is still not carried onto the saved character in general - only a
`with`-derived one is. Carrying every skill note to the sheet is a larger change
than this finding asks for and would alter every class at once. **Filed nowhere,
dropped on purpose**, because nobody has asked for it and the F49 case is now
covered.

### F50 - `equipment_starting` cannot grant a SKILL, and one book's gear choice does

**Filed 2026-09-09**, during the `new-west` class import, batch 1.

New West's Bounty Hunter (printed 89-90) ends with **Special Equipment: Pick
one**, and offers four packages. The second reads: a suit of light to medium
power armour, and *"Automatically gets the basic pilot robots and Power Armor
skill."*

`equipment_starting` takes gear slugs and quantities. It has no way to say that
choosing an option also grants a skill, and `occ_skills` has no way to say that
a skill is granted only if a particular equipment option was taken. The two
blocks do not see each other.

**Two of the four options have no catalog shape either** - a Techno-Wizard or
magic armour plus a magic weapon, or a bio-wizard parasite with 1D4 microbes -
so this is not a case where three of four could be modelled and one noted.

**Stored as:** the whole four-way choice is in `extraction_notes` on
`bounty-hunter`, and nothing from it is in `equipment_starting`. That is
deliberate: half-modelling it would put armour on the sheet and silently drop
the skill that comes with it, which reads as complete and is not.

**Affected rows.** `bounty-hunter` today. A grant of gear-and-a-skill together
is a common Palladium shape and this is unlikely to be the only one; **the count
here is one because one book has been read for it, not because a sweep found
one.** No sweep has been run.

**Proposed change, NOT implemented.** Either a `grants_skill` key on an
`equipment_starting` choice option, or the inverse - an `occ_skills` entry
conditional on an equipment pick. The first is smaller and keeps the condition
where the choice is made. **Check before scoping:** whether `equipment_starting`
choice options are resolved at creation or re-derived per render, because the
reference says a choice's `qty` is re-derived and a granted skill must not be.

**HELD, 2026-09-10 (PR #910). The premises are corrected and the capability is
NOT built, because neither class that wants it could use it.** Posture:
documentation only. No key added, no schema, no data change.

**THE CHECK-BEFORE-SCOPING QUESTION IS ANSWERED, AND THE ANSWER IS THE ONE THAT
CONSTRAINS A TAKER.** `equipment_starting` choice options ARE re-derived on
every render: `initEquipment` (`app.js:2545-2573`) rebuilds `S.gearChoices` each
time and is deliberately NOT guarded by `equipInit`, with the comment *"A
restored draft brings back which options were TICKED but not what the options
were."* **Only the tick is persisted.** So a granted skill must be resolved FROM
the persisted tick and never re-derived beside the options. The finding was
right to ask. (It attributes the `qty` claim to `docs/wizard-and-sheet.md`; the
sentence actually lives at `js/parser.js:2386-2392`. The claim is true, the
citation is not.)

**The ORDERING works, which the finding does not raise and a taker would
worry about.** Equipment is step 6 and skills are step 5, so an
equipment-granted skill arrives after the skills step - but `skillsAtLevelOne()`
is called from `characterAtLevelOne()` (`app.js:1798-1805`), which builds the
SAVE payload. By then the tick exists.

**WHY IT IS HELD: BOTH CLASSES THAT WANT IT STAY UNMODELLABLE ANYWAY.** The
skill is one of several things their choice needs, and it is not the only
missing one:

| Bounty Hunter / Justice Ranger option | what it needs | available? |
|---|---|---|
| armour or TW weapon **plus 2D6x1000 credits** | a sum of money in `equipment_starting` | **no** |
| light or medium power armour, **granting Pilot Robots and Power Armor** | the skill grant | **no - this finding** |
| TW or magic armour and a magic weapon, or a bio-wizard parasite | catalog rows that do not exist | **no** |
| a souped-up vehicle, or a robot horse | a gear row pointing at a vessel | **yes, see below** |

So `grants_skill` would ship as a key **no live class could use**, because
adding it still leaves three of the four options unexpressible and both classes
recorded the whole choice in `extraction_notes` rather than half-modelling it.
That is the trade `F55` was filed to name, and it applies here for the same
reason.

**A CLAIM I NEARLY MADE AND CHECKED FIRST: `equipment_starting` CAN reference a
vehicle.** It resolves slugs against the gear catalog through `findItem`
(`app.js:2533-2539`), which reads only `S.items` - so the obvious conclusion is
that power armour and robot horses are out of reach. **They are not.**
`gear.vehicle_slug` exists from migration 053 and **16 live gear rows point at a
vessel**, `glitter-boy-power-armor` among them (`--remote`, 2026-09-10). F41
built that bridge. An absence claim about a capability is the shape most likely
to be wrong, and this one was.

**Two more corrections to the finding's own text:**

- **"Affected rows: `bounty-hunter` today" points at the wrong row.**
  `node scripts/audit-citations.mjs --remote F50` returns **`justice-ranger`**
  only - and `bounty-hunter`, the class this finding is *about*, does not cite
  F50 at all. A taker following the script finds the second class and not the
  first.
- **"Two of the four options have no catalog shape either" miscounts the
  options.** Those two are the two BRANCHES of option 3 (printed 91: *"Magic
  Armor: One Techno-Wizard or other type of magic armor and one magic weapon...
  Or one major bio-wizard parasite, plus 1D4 microbes"*). The `bounty-hunter`
  row itself says it correctly - *"Only the third and fourth have no catalog
  shape at all"*.

**One thing a taker needs that the finding does not say:** neither validator
rejects unknown keys, so a `grants_skill` written today **parses clean, stores,
and is silently ignored** - the exact shape `F52` was filed about and the reason
this must not be half-shipped. The obvious alternative route is closed on
purpose: `ABILITY_GRANTS = ['bonuses', 'psionics', 'magic']`
(`js/parser.js:1644`), and `js/parser.js:1751-1757` records that an ability
carrying a skills block was rejected as *"the same power by another name"*.

**What would change this.** A way to express the other three options - money in
starting equipment, and catalog rows for the TW and magic items - or a decision
that a PARTIAL model is better than none, which both classes' notes currently
reject. Either makes `grants_skill` worth the key it costs. **Reopen on either.**

### F51 - `race_restrictions` matches a race by ID, and a book bars races by KIND

**Filed 2026-09-09**, during the `new-west` class import, batch 2.

New West's Gunslinger (printed 95) carries a Racial Restrictions line barring
dragons and other creatures of magic, master psionics, supernatural beings such
as demons, partial and full conversion cyborgs, androids and robots - and adds
that many optional D-bee R.C.C.s will preclude the class as well.

`raceAllowedForOcc` in `apps/character-creator/js/parser.js` matches
`race_restrictions.only` / `.except` against `race.id`, with the reserved entry
`none` meaning no R.C.C. at all, which is the human case. Read 2026-09-09 at
`js/parser.js:2097-2115`. So the block expresses *these races* and cannot
express *races of this kind*.

**Writing it out as ids is possible and is the wrong answer.** There are **79
live published R.C.C.s** as of 2026-09-09 (`--remote`, `deleted_at IS NULL`,
`category: rcc`), the categories the book names cut across most of them, and the
list would silently go stale every time a race is imported - which this batch of
books is doing continuously. An `except` that misses a newly added dragon fails
**OPEN**, which is the direction `class-import` records as the expensive one.

**Stored as:** a `restrictions` prose line on `gunslinger`, naming the
categories the book names and citing this finding.

**Affected rows: `gunslinger` AND `psi-slinger`, for two different reasons, and
the second one is the more interesting.**

The Psi-Slinger (printed 100) restricts to *"Humans and Psi-Stalkers only"* -
two named races, which looks like exactly what `race_restrictions.only` is for.
It was written that way, as `only: ["none", "psi-stalker"]`, and
**`regression.mjs` refused it**: *"and names only real races, or the reserved
`none` - psi-slinger -> psi-stalker"*. Read `--remote` 2026-09-09, this catalog
holds `psi-stalker` (*Psi-Stalker (Civilized)*) and `wild-psi-stalker` as
**`category: occ`**, not as R.C.C.s. So there is no race id to name, and a
restriction that is two plain names in the book is still not expressible.

**That is a second, narrower gap wearing the same coat**: not "the schema cannot
say KIND", but "the thing the book calls a race, this catalog calls an
occupation." Both are stored as `restrictions` prose. **This paragraph first
claimed the Psi-Slinger was the contrast case and needed nothing** - written
without checking what `psi-stalker` actually is. The regression run is what
corrected it.

No sweep of other books has been run, so the count is two because two classes
have been read for it.

**Proposed change, NOT implemented.** A `kinds` list beside `only`/`except`,
matched against something a race already declares, would be the shape - but
**nothing on a race declares its kind today**, and that is the real work. Check
before scoping: whether `supernatural`, `creature of magic` and `master psionic`
are derivable from fields races already carry (`psionics.type`, an
`attributes are supernatural` restriction line, `mdc_base`), or whether this
needs a new field on 79 rows. If it is the latter, the honest answer may be that
prose is correct and this finding should close undone.

**CLOSED UNDONE, 2026-09-10 (PR #907), which is the outcome this proposal
authorised in its own last sentence.** Posture was
investigate-then-possibly-decline; it declines. No code, no schema, no new
field, no data change.

**The check-before-scoping question was RUN rather than reasoned about.**
Parsed every live published class `--remote` on 2026-09-10 with the real
`parseClassMarkdown` and asked what each R.C.C. actually declares:

| signal | how it is carried | R.C.C.s |
|---|---|---|
| master psionic | a real FIELD - `psionics.type` | **4** |
| supernatural | prose only | 34 by regex |
| creature of magic | prose only | 24 by regex |
| nothing at all | - | **39 of 86** |

**The derivation FAILS, and it fails in the direction that would ship a bug.**
The 24 "creatures of magic" include **`human`, `elf`, `dwarf`, `goblin` and
`hob-goblin`**. The regex is matching *restriction* lines - a class that BARS
creatures of magic says the phrase too - not a declaration that the race is one.
So a `kinds` list derived from prose would bar Humans from the Gunslinger for
being creatures of magic. **Only one of the three kinds is derivable from a
field, and it is the rarest of the three.**

**Which leaves the option the proposal itself called the honest one:** a new
field on **86** rows, 39 of which carry no signal at all and would have to be
decided by hand against their books. That is a book-by-book research job across
every race in the catalog, to serve **three** class restrictions.

**Two numbers in this finding have moved, both upward:**

- *"79 live published R.C.C.s as of 2026-09-09"* is **86** as of 2026-09-10.
  Seven landed in one day - which is this finding's own argument against writing
  the list out as ids, strengthened.
- *"the count is two"* is **three**. `node scripts/audit-citations.mjs --remote
  F51` returns `gunslinger, psi-slinger, wired-gunslinger`; the third was
  created on 2026-09-10, after this was filed. The finding said outright that
  two was a floor because two classes had been read for it, and it was right to.

**What stays true, and is why this is closed rather than deleted.** Every
premise holds, re-verified rather than taken on the page's word:
`raceAllowedForOcc` matches `race?.id` with `none` reserved for humans
(`js/parser.js:2097-2115`); `psi-stalker` and `wild-psi-stalker` are
`category: occ` in the live catalog, so naming them in `race_restrictions` is
refused by `regression.mjs:2264-2272`; and **nothing on a race declares its
kind** - a grep of `js/parser.js` for `supernatural`, `creature_of_magic` and
`race_kind` on 2026-09-10 returns nothing, so the key is absent from the
frontmatter contract entirely.

**Reopen this if a race ever gains a kind field for another reason.** The three
restrictions become cheap to express the moment one exists; what is expensive is
creating it for them alone.

### F52 - high - a DICE STRING in `bonuses` parses clean, stores, and is silently dropped, and 34 published classes carry one

**Filed 2026-09-09**, while writing up the `new-west` class import. It was going
to be a small note about that book dropping six attribute bonuses. It is not
that.

**`js/derive.js` `addBonus` skips anything that is not a finite number**, read
2026-09-09 at `apps/character-creator/js/derive.js:344-352`:

    for (const [k, v] of Object.entries(block)) {
      if (typeof v !== 'number' || !Number.isFinite(v)) continue;

**`validateBonuses` only rejects a dice string when `opts.flatOnly` is set**
(`js/parser.js:1537-1545`), and `flatOnly` is the SKILL path. A class may carry
one freely.

**Reproduced rather than reasoned about.** A throwaway class with
`bonuses: { attributes: { MA: "1d4" }, combat: { initiative: "1d4", strike: 2 } }`
through the real `parseClassMarkdown` and then the real `addBonus`:

    parse ok      : true
    errors        : []
    warnings      : []
    stored bonuses: {"attributes":{"MA":"1d4"},"combat":{"initiative":"1d4","strike":2}}
    combat after addBonus : {"strike":2}
    attrs  after addBonus : {}

`strike: 2` survives. Both dice strings vanish. Nothing anywhere rolls them:
a grep of `js/derive.js` and `js/compose.js` for `rollDice`, `rollAttribute` and
`parseDice` on 2026-09-09 returns nothing in either file.

**THE EXPOSURE IS 103 ENTRIES ACROSS 34 OF 242 LIVE PUBLISHED CLASSES**, swept
`--remote` on 2026-09-09 by parsing every one with `parseClassMarkdown` and
walking `bonuses`, `bonuses.at_level`, `variants[].bonuses` and
`special_abilities[].bonuses`. By block: **98 in `bonuses.attributes`, 4 in
`bonuses.saves`, 1 in `bonuses.combat`.** `bonuses.pools` is excluded from the
sweep on purpose - pools legitimately take a dice expression and are rolled once
into a maximum.

The worst affected are not obscure:

| class | entries | includes |
|---|---|---|
| `cyber-knight` | 6 | `1d4` on M.A., M.E., P.S., P.P., P.E. and Spd - every attribute it raises |
| `psycho-stalker` | 5 | |
| `godling` | 5 | `combat.initiative: "1d4"`, plus four inside `special_abilities` |
| `crazy` | 4 | |
| eight juicer variants | 3-4 each | `juicer` carries `PS: "2d6"`, `PE: "2d6"`, `Spd: "2d4x10"` |
| `ley-line-walker`, `dog-boy`, `freelancer` | 3 each | |

**A Juicer's +2D6 P.S. is the defining feature of the class and it does nothing
on the sheet.** Neither does a Cyber-Knight's entire attribute block.

**F12'S TABLE HAS THIS BACKWARDS, and correcting it is part of this finding.**
Read at `BOOK-INGEST-AUDIT.md:1489`, F12 lists:

| class | asserted | falsified by |
|---|---|---|
| `apok` | `bonuses.attributes` takes flat numbers only | the Godling's +1D4 initiative |

The apok's note is **TRUE**. The Godling's `+1D4 initiative` does not falsify it:
that entry is itself one of the 103 and is inert. F12 read a class carrying a
dice string as evidence that dice strings work. It is the exact shape F12 is
about - a perishable claim about the app inside a permanent record - arrived at
from the other side.

**What the `new-west` import did, and why it needs no correction.** Six of its
classes print a dice attribute bonus - `saddle-tramp` +1D4 M.A., `preacher`
+1D4+2 M.A., `saloon-bum` +1D4 P.E., `saloon-girl` +1D4+1 M.A., and
`wired-gunslinger` P.S. +1D4, Speed +2D6 and initiative +3+1D4 - and all six put
it in prose to be rolled at creation rather than into `bonuses`. That was the
right call for the wrong reason: it was made from the reference's wording rather
than from this measurement, and it is why none of those six is in the 103.

**Proposed change, NOT implemented.** Two halves, and the second is the one that
matters:

1. **Make it loud.** `validateBonuses` should warn on a dice string outside
   `pools` for a CLASS as it already errors for a skill, and `class-check`
   should report it. That stops the 104th.
2. **Decide what the 103 should be.** Rolling them properly means a bonus that
   is rolled once and stored, which is what `pools` already does and what
   `attribute_dice` does for a race - so the mechanism exists twice and neither
   is wired to `bonuses.attributes`. The alternative is converting all 103 to
   prose, which is honest, loses the numbers from the sheet, and is a large data
   change across 34 classes including the headline ones.

**Check before scoping:** whether the wizard rolls `bonuses.attributes` at
CREATION somewhere other than `derive.js` - the sweep proves the sheet drops
them, not that nothing anywhere reads them - and whether any of the 103 is a
deliberate placeholder rather than a mistake. **Both halves of that are
unmeasured**, and the second is why this finding proposes a warning rather than
a migration.

**CLOSED AS FALSIFIED, 2026-09-10 (PR #905). NOT IMPLEMENTED, and that is a
deliberate departure from "take as written" - see the last paragraph.**

**This finding's own `Check before scoping` question is the one that kills it.**
It asks *whether the wizard rolls `bonuses.attributes` at CREATION somewhere
other than `derive.js`*. **It does. `app.js:232-250`.**

**A DICE STRING IN `bonuses` IS NOT DROPPED. It is rolled ONCE AT CREATION and
stored on the character**, which is exactly what `attribute_dice` does for a
race and for the same stated reason:

| where | what it does |
|---|---|
| `js/derive.js:274-322` | `diceBonusesByGroup` / `diceBonuses` collect every dice entry in `attributes`, `combat` and `saves` |
| `app.js:232-250` | `rollDiceBonusesOf` calls `evalDice` on each one |
| `app.js:3622-3623` | stores them as `attribute_bonuses` and `rolled_bonuses` |
| `js/derive.js:216-246` | `classBonuses` turns the stored roll back into the number the sheet renders |
| `sheet.js:1489-1501` | passes them in, with the comment *"Without them a Juicer's +2D6 P.S. would silently contribute nothing here"* |

**`validateBonusGroup` ACCEPTS dice on purpose** - `js/parser.js:1393`, and its
own error text reads *"must be a number or a dice expression like 2d6"*. So does
the smoke suite, which uses **the Cyber-Knight's five `1d4` attribute bonuses**
as its worked example that dice roll through composition
(`test/smoke.mjs:3830-3868`). That path shipped 2026-08-17 and 2026-08-20 -
three weeks before this finding was filed.

**PRODUCTION SETTLES IT.** `--remote`, 2026-09-10: a live Juicer carries
`attribute_bonuses = {"PS":9,"PE":7,"Spd":70}`, which is that class's `2d6`,
`2d6` and `2d4x10`, rolled and stored.

**How the finding got it wrong, precisely, because the shape recurs.** Its
evidence line says *"a grep of `js/derive.js` and `js/compose.js` for `rollDice`,
`rollAttribute` and `parseDice` on 2026-09-09 returns nothing in either file."*
**That grep is TRUE.** The roller is in `app.js` and `js/dice.js`, and the
function is called `evalDice`. A true grep over the wrong two files, for a name
the code does not use, read as an absence. It also reproduced the bug by calling
`addBonus` on the raw frontmatter - which nothing in the app ever does, because
`classBonuses` resolves dice to the stored roll first and hands `addBonus` an
all-numeric block.

**The counts reproduce exactly and are not the problem.** Re-swept `--remote`
2026-09-10 with the real `parseClassMarkdown`: 103 dice entries across 34
classes, `{attributes: 98, combat: 1, saves: 4}`. All 17 distinct expressions
evaluate under `evalDice`. The denominator moved - **34 of 250 live published
classes, not 242.** Every one of the 103 works.

**WHY IT WAS NOT IMPLEMENTED ANYWAY.** Half 1 asks for a warning on every dice
string outside `pools` for a class. That would fire on **103 correct, working
entries** and contradict a design `js/parser.js:1526-1531` states outright:
*"A class rolls its dice bonuses once at creation and stores the result on the
character; a skill can be taken at any level, so there is no equivalent
moment."* Half 2 asks what the 103 *should* be; they are already right, so it
has no subject. Taking this as written would ship a defect. **The protocol's
options are implement-anyway or stop-and-ask, and this note takes neither -
Nate should know that.**

**ITS PROPOSED CORRECTION TO `F12` MUST NOT BE MADE.** This finding says
*"`F12`'S TABLE HAS THIS BACKWARDS"* and asks that the `apok` row be reversed to
call that class's note TRUE. `F12`'s table lists **false claims and what
falsified them**; the `apok` note asserted *"`bonuses.attributes` takes flat
numbers only"* and the Godling's `+1D4 initiative` does falsify it, because
`combat.initiative: "1d4"` is rolled and stored like the rest. **`F12` is right
and was left untouched.**

**Two class notes repeated the false claim in live data and are corrected** in
`fix-f52-false-dice-claims.sql`, applied `--remote` in the same PR:

- **`lyn-srial-sky-knight` had been made WORSE by this finding.** Its `+1D6 to
  P.S.` was put in `special_abilities` prose *because* F52 said a dice bonus
  would do nothing, so the class shipped short a P.S. bonus its book grants
  outright. The bonus now sits in `bonuses.attributes` where it rolls.
  Verified: the corrected markdown parses with no errors and stores
  `{"PS":"1d6"}`. `special_abilities` also left its `copy_of` except list,
  because the two classes now agree on it - `regression.mjs` caught that within
  one run of the first edit.
- **`keeper-of-the-desert`** cited F52 for *"why a dice bonus there would be
  silently dropped even if written as one"*. The class's abilities genuinely are
  not enumerated against the catalog, which is true and stays; only the reason
  was false.

`apps/character-creator/docs/surveys/new-west.md` and the memory store carried it
too and are corrected in the same PR.

**What survives, and it is small.** Of the 103, **15 sit inside
`special_abilities[].bonuses`**, and 6 of those are on classes filed
`category: occ` - `ley-line-walker` and `freelancer`. `abilityPicker`
(`app.js:1345-1348`) reads `S.rcc` only, so for a D-bee taking a racial class
*plus* one of those O.C.C.s the ability is never offered. **That is an
ability-PICKING limitation, not a dropped dice string, and it is 6 entries
rather than 103.** Not filed as a finding here: it belongs to the wizard's
ability step, and nobody has reported it.

### F53 - high - `corrupt_pages` detects glyphs that FAIL to map, and the commoner fault maps to a VALID character

**Found while importing `new-west` gear and vessels, 2026-09-10.** This is not
`F36`, and the difference is the whole finding. `F36` is about a page whose text
comes out as visible nonsense - `vsv&sis. \Vs. %\%vausttft` - which announces
itself. This is about a page whose text comes out **readable and wrong**.

New West renders the digit **1 as `!` or `l`** and **0 as `O` or `Q`** inside
almost every `NDNx10` / `NDNx100` construction: `!D4xlO` where the book means
1D4x10, `3D4xlOO` for 3D4x100, `10Q` for 100. Nothing about those strings is
unmappable, so the detector `F36` produced does not count them.

**Evidence, all 2026-09-10:**

- A regex sweep over `.cache/books/new-west/txt/*.txt` for a dice-shaped token
  containing `!`, `l`, `O` or `Q` returns **roughly sixty pages**. The manifest's
  `corrupt_pages` for the same cache holds **three** entries - cache `p031`,
  `p143` and `p218` - none of which is a page the sweep is reporting for this
  reason.
- The fault is in the **ink, not the text layer**. Clipped printed 223 (cache
  `p224`) at 600 dpi with `pymupdf` `get_pixmap(dpi=600, clip=...)` and read it:
  the page itself prints `!D4xlO million credits` and `10Q P.P.E.`, two words
  after a correctly-set `4D6`. **So a render does not cure this**, which is the
  opposite of New West printed 217, where the ink is right and the text layer is
  wrong. This book carries one clean example of each, which makes it the
  reference case for both halves of `book-survey` 0a.
- It reaches **starting money**: almost every O.C.C. on printed 85-124 prints
  `Money: Starts with 3D4xlOO credits`.

**Nothing leaked into live data, and that is measured rather than assumed.**
`node scripts/q.mjs --remote` over `imported_classes`, `gear` and `vehicles` on
2026-09-10 returns zero rows containing `xlO`, `xlOO` or `!D`, and 23 of the 27
class rows whose markdown mentions this book carry a correct `x100`. Every
affected figure was read as a dice expression by a human reading a render, which
is the control that happened to be in place and is not a control anything
enforces.

**Proposal:** teach `scripts/ocr-book.py` to report this class of damage
alongside the glyph one, as a **separate manifest key** rather than folding it
into `corrupt_pages` - the two need different remedies and merging them would
tell a reader to render a page a render cannot fix. Detect it by GRAMMAR rather
than by character: a token matching `[0-9!lOQ]*[Dd][0-9!lOQ]{1,2}([xX][0-9!lOQ]+)?`
that contains at least one of `!lOQ`. Report a per-page count, as
`corrupt_pages` already does.

**Posture: warn, do not block. Report only - no exit code, no refusal to
cache.** `ocr-book.py` must still produce the cache; this key is advisory, the
same posture `corrupt_pages` and `welded_pages` already have. It should also
surface in `class-check --field-sources` for a class whose window lands on such
a page, which is where `corrupt_pages` already prints its advisory.

**Evidence for the proposal itself: the regex above was RUN**, on this cache, on
2026-09-10, and its output is what the sixty-page figure comes from. **It has
not been run against the other fifteen caches**, which is the confidence gap
below.

**Beware one false positive, found the first time it ran:** the English word
`Old` matches a looser version of the pattern and produced twenty spurious pages.
The word-boundary guard `(?<![A-Za-z])...(?![A-Za-z])` is what removes it.

**Confidence: high that the fault exists and is under-reported 20x in this book;
MEDIUM that it generalises.** What would raise it: running the sweep against the
other fifteen caches under `.cache/books/`. `spirit-west` and `mystic-russia`
are the two untouched text-layer books in this batch and are the obvious first
check.

**Ongoing cost:** one regex and one manifest key in a script that already
computes two similar keys, plus a line in `class-check --field-sources`. No new
file, no new command to remember, no CI minute. The recurring cost is that a
second advisory key is a second thing a reader must know to look at.

**Subject grep, 2026-09-10:** `corrupt_pages`, `glyph`, `substitut` across every
menu the `find` glob returns plus `SETUP-v2-CHANGES.md`, and across
`~/.claude/.../memory/`. The only menu hits are in this file - `F30` (welded
pages, a reading-ORDER fault), `F36` (glyph corruption, the visible kind) and
`F39` (a render fixes a failed layout analysis). None of the three covers a
substitution that maps to a valid character; `F36` is the one this extends and it
is named above.

**Taken, 2026-09-10 (PR #904).** Posture held: **warn, do not block.**
`substituted_digits` is a separate manifest key, advisory, no exit code, and
`ocr-book.py` still writes the cache. It reports as `DIGITS` beside the existing
`WELDED` and `GLYPHS` lines.

**THE FINDING UNDERSTATED ITSELF TWICE, and both corrections make it bigger.**

**One: this book is 75 pages, not the "roughly sixty" filed above.** The sweep
quoted in the finding was written with a `\b` word boundary, which cannot match
before a leading `!` - so every `!D4xlO` token was invisible to the measurement
that produced the number. The shipped detector uses a `(?<![A-Za-z])` lookbehind
and finds them. Against `corrupt_pages`' 3, the ratio is 25x rather than 20x.

**Two, and this is the real correction: IT IS NOT A NEW WEST FAULT.** The
finding says nothing about other books because none was checked. Run on two more
text-layer caches the same day:

| cache | `corrupt_pages` | `substituted_digits` |
|---|---|---|
| `new-west` | 3 | **75** |
| `cb1` | 0 | **69** |
| `bom` | 9 | **116** |

`cb1` is the cache the survey notes call the clean one - it is the only book here
with zero welded pages - and it prints `lD6` for 1D6, `lD4xl00` for 1D4x100 and
`lD20` for 1D20. Every hit inspected was a true positive. **So the confidence gap
this finding named as MEDIUM is closed in the direction that widens it**: this is
a property of Palladium's typesetting, not of one book, and the two untouched
text-layer caches in this batch (`spirit-west`, `mystic-russia`) should be
assumed to carry it.

**Proved silent before being trusted.** A synthetic page holding `Old`, `Gold`,
`bold`, `cold`, `hold`, `sold`, `told`, `world`, clean `1D6`, `2D4x10`,
`2D6x100`, `1D20`, `100`, `110`, `1200`, `24,000`, `RH-1001A` and `K-9R-1100`
scores **0**; a page holding `lD6`, `2D4xlO`, `lD4xl00`, `!D6xlOO` and `10Q`
scores **5**. The `Old` case is the one that matters - a looser pattern matched
it and reported twenty spurious pages on the first attempt, and the word
boundaries are what remove it.

**`book-survey` 0a gained a third category in the same PR**, with the table
above and the instruction that a render does not fix this one.

### F54 - low - a gear row may not carry both an S.D.C. and a damage die, and a grenade legitimately does

**Found while importing `new-west` gear, 2026-09-10, when it failed the run.**

`apps/character-creator/test/regression.mjs:1577` refuses any `gear` row that
has a non-null `sdc` alongside a dice expression in `damage`:

```js
const damageAsSdc = rows.filter((r) => r.sdc != null && /\dD\d/.test(r.damage || ''));
check('and no weapon was given its own damage as durability', damageAsSdc.length === 0, ...);
```

**The check guards a real trap and should not be removed.** Its own comment says
so: *"does 1D6 S.D.C." on a knife is DAMAGE, and a regex over descriptions would
file it as durability - a knife that can absorb six points of punishment because
it deals six.*

**But a grenade has both.** New West printed 209 gives the Wilk's Beehive and
Blinder an **S.D.C. of 20 and an A.R. of 10** - the durability of the grenade
casing - alongside a blast of 3D6 M.D. The check cannot tell that from the knife
it exists to catch.

**Shipped in PR #897 with `sdc` NULL and the 20 in the `description`**, because
loosening a guard in the same change that first trips it is how a guard stops
guarding. The `ar` is stored normally; the check does not read that column.

**Proposal:** scope the check the way its own sibling one line above is already
scoped. `regression.mjs:1569` restricts the both-scales check to `category =
'armor'` with the comment *"A row that CONFLATES two products can legitimately
carry both - polarized goggles are 15 S.D.C. ordinary and 1 M.D.C. high-impact -
which is why this is scoped to armour."* The same reasoning applies here: an
explicit, named allowance for rows whose S.D.C. is the object's own toughness.
Then restore `sdc = 20` on `wilk-s-beehive-laser-grenade` and
`wilk-s-blinder-laser-grenade` in a `fix-` script.

**Posture: keep the check and narrow it. No new gate, no exit-code change,
nothing relaxed for rows outside the named allowance.** A blanket removal is
explicitly not what this proposes.

**Evidence: RUN.** The check fired on this data on 2026-09-10; the quoted source
is `regression.mjs` at the lines given, read the same day. The two grenade rows
are live and carry `sdc` NULL today.

**Confidence: high.** The failure is reproducible by restoring either `sdc`
value and re-running `node apps/character-creator/test/regression.mjs`. What is
NOT measured: whether any other live gear row would want the same allowance - a
sweep of `gear` for rows whose description states a self-S.D.C. would settle it
and has not been done.

**Ongoing cost:** near zero. One predicate on one check, plus whatever names the
allowance - a category, a column, or a slug list, and a slug list is the shape
this menu has previously disliked.

**Subject grep, 2026-09-10:** no other menu mentions this check or the
`gear.sdc`/`damage` pair; `durability` returns nothing in any menu, and the only
`sdc` discussions in this file are `F42`'s edition figures and `F41`'s vessel
split, neither of which touches the both-columns question.

**Taken, 2026-09-10 (PR #906). Posture held: the check is SCOPED, not relaxed.**
An unlisted row still fails exactly as before, no exit code moved, and nothing
outside the named allowance changed.

**Listed by SLUG rather than by category, and the reason is in the trap.**
`weapon` is where the knife lives too, so a category exemption would open the
hole this check exists to close. The Palladium armour map twenty lines above is
an explicit slug list for the same reason, which makes this the house style of
the section rather than a new shape.

**THE FINDING SAID TWO GRENADES AND THE ANSWER IS ONE.** Only the **Beehive**
does dice damage. The Blinder's `damage` reads *"None; it blinds rather than
injures"*, so it never tripped the check at all and is deliberately NOT in the
allowance - which also means its `sdc` was nulled in PR #897 for no reason.
Both rows get their 20 back; only one is exempt.

**That was found by a check written in the same PR, on its first run.** The
allowance is verified in both directions: every slug in it must exist AND must
actually carry both columns, so a stale name silently widening the exemption
fails the suite. It fired immediately on `wilk-s-blinder-laser-grenade`. **A
list of exceptions needs a check that the exceptions are still needed**, and
this one earned its place before it was committed.

**Proved the scope did not open the hole.** Run against synthetic rows: a
`survival-knife` with `sdc: 6` and `damage: "1D6 S.D.C."` is still flagged; the
Beehive is exempt; the Blinder matches no dice pattern either way. The check is
314 checks now rather than 313 - the extra one is the narrowness guard.

`fix-f54-grenade-self-sdc.sql` restores `sdc = 20` on both rows, guarded on
`sdc IS NULL`. The `ar` was never affected: the check does not read that
column.

### F55 - low - `gear` has nowhere to record a CREATION cost, and RECOMMENDS BEING DECLINED for now

**Found while importing `new-west` Techno-Wizard weapons, PR #898, 2026-09-10.**

All twelve TW weapons state four things a Techno-Wizard character needs and the
`gear` table has no column for any of them: an **initial P.P.E. cost** (40 to
195), the **spells needed** with their own P.P.E. costs, a **physical
requirement** including a gem of stated value (300 to 10,000 credits), and the
**hours of work** (3D4 hours to 120). The Ironhorse's is 9,540 P.P.E. and 3700
to 4000 hours.

**Evidence:** `gear`'s schema read `--remote` on 2026-09-10 via
`node scripts/q.mjs --remote "SELECT sql FROM sqlite_master WHERE name='gear'"`
- eighteen columns: `id, slug, name, system, category, weight_lbs, cost,
cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc,
description, source_book, vehicle_slug`. None of the four fits any of them.
All twelve rows put the whole block in `description` instead, prefixed
`CREATION:`.

**Proposal, and it recommends declining itself for now.** The mechanical answer
is four columns or a `gear_creation` child table. The honest answer is that
**nothing in the app reads any of it**, and neither does anything read the
`vehicles` tables that have carried richer structure since migration 048. Adding
columns means a migration, a backfill across every book that prints TW or
alchemical creation stats, and a permanent obligation on every future gear
import to fill them - for data with no consumer.

So: **file it, store the prose, and hold.** What would change the recommendation
is a consumer - a Techno-Wizard creation view, or a search that wants "items I
can build with 60 P.P.E." If one is ever built, this is the finding to take
first, and the twelve rows are already consistent enough to parse.

**Posture: documentation of the gap only. No schema change, no migration, no
new gate.** This finding exists so the next importer knows the prose is a
decision rather than laziness, and so the gap is reachable by number.

**Confidence: high on the absence** - the schema is quoted above from the live
database. **The judgement that it should be held is a judgement, not a
measurement**, and what would raise it is somebody wanting the data.

**Ongoing cost of taking it:** four columns, one migration, a backfill across at
least Triax, Free Quebec and New West, and a field every future gear import must
consider. **Ongoing cost of declining it:** the prose stays unparseable, and a
future consumer pays to extract it.

**Subject grep, 2026-09-10:** `creation`, `P.P.E. cost` and `gear` schema
questions across every menu plus the memory store. `F41`'s Wormwood outcome note
is the nearest precedent and it points the other way - it declined to widen
`vehicles` for parasite entries carrying Horror Factor, I.Q. and attacks per
melee, on the grounds that importing one *"would DROP them, which is worse than
the cosmetic split this finding set out to fix."* That decision is named here
rather than re-litigated, per the rule about re-proposing settled questions.

**HELD, 2026-09-10 (PR #910), which is what this finding recommended for
itself.** Posture: documentation only. No columns, no migration, no data change.

**Nothing has changed the argument.** The twelve Techno-Wizard rows still carry
their creation stats as prose, nothing in the app reads them, and no consumer
has appeared. The schema was re-read `--remote` on 2026-09-10 while closing
`F50` and `gear` is unchanged at eighteen columns.

**It is now one of a PAIR and they should be decided together.** `F50` was held
the same day for the same reason: a small, correct frontmatter key with no live
class able to use it. If the answer to one is *"build it anyway, the cost is
low"*, it is probably the answer to both.

