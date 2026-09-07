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
