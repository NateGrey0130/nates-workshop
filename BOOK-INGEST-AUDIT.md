# Book-ingestion batch — deferred code changes, 2026-08-28

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

**Taken, 2026-08-31 (PR #NNN).** `mergeMagic`, on F10's rules, sharing its union
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

**Open.**
