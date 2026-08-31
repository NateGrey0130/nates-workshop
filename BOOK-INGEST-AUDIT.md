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

**Open.**

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

**Open.**

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

**Open.**

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
