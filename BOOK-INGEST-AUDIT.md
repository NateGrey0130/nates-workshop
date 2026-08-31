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

**Open.**

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

**Open.**

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

**Open.**

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

**Open.**

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

**Open.**

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

**Open.**

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

**Open.**

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

**Open.**
