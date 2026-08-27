# Leveling, grants and tiers

What a class gains as it levels: fighting-style schedules, skill picks, staged classes,
chosen powers, and the psychic tiers that gate them.

Part of the [character creator](../README.md) documentation.

---

## A fighting style is a level schedule

`bonuses` (migration 023) applies **whole, at every level**. That is right for
Boxing — +1 attack per melee, +2 parry and dodge, +2 P.S. — and wrong for every
Hand to Hand skill in the book, which Rifts Ultimate Edition p.347 prints as a
level-by-level table and states plainly are **accumulative**: a 5th level
Expert has levels 1 through 5, not level 5 alone.

So the entire mechanical payload of the five Hand to Hand skills had nowhere
to live, and was simply absent — `base` 0, `per_level` 0, no bonuses, no note.
Picking a fighting style changed nothing about how the character fought.

`level_bonuses` is a JSON array, one entry per level that grants something:

```json
[{"level": 1, "combat": {"attacks_base": 4, "pull_punch": 2, "roll": 2}},
 {"level": 2, "combat": {"parry": 2, "dodge": 2}},
 {"level": 3, "note": "Kick attack does 1D8 points of damage."}]
```

`combat`, `saves` and `attributes` are the same groups `bonuses` uses, and
everything at or below the character's level is summed.

### Three rules this shape had to earn

- **`attacks_base` sets; everything else adds.** The books state a starting
  number outright — "starts with four attacks per melee round" — so adding it to
  the derived base of 2 would give a first level Expert six. It is also the
  one key taken as a **maximum** rather than a sum, so a character holding two
  fighting styles fights at the better one instead of adding them together.
- **What is not a number goes in `note`.** "Karate Kick (2D6 damage)", "Death
  blow on a Natural 20", and the Assassin's bonuses that apply only to guns or
  thrown weapons. A conditional bonus in `combat` would apply unconditionally,
  which is the same reason Fencing carries its bonuses as a note.
- **A level of `null` grants nothing.** That is deliberately different from
  level 1: a caller that cannot say how experienced the character is should not
  silently hand out first level bonuses.

### Where it reaches the character

`bonusesFromSkills(rows, level)` folds the schedule into the same bonuses block
everything downstream already reads, so the sheet's combat numbers pick it up
with no further help. The notes cannot be summed, so the sheet endpoint returns
them separately as `skill_level_notes` and the Combat box lists them — without
that, a 7th level Expert's numbers would be right while the four moves earned
along the way went unmentioned.

`disarm`, `entangle`, `body_flip` and `automatic_dodge` joined the combat block
for this. `combat` and `saves` are open sets on purpose, so no validator
changed — only `derive.js`, which now knows what to call them.

### A W.P. bonus applies only with that weapon

Every numeric Weapon Proficiency bonus is **conditional**. p.326:

> ...hand to hand combat bonuses to strike and parry **whenever that particular
> type of weapon is used**.

Written into `combat` the way a Hand to Hand schedule is, a character with five
W.P.s would swing their **bare fists** at +5 to strike — and it would read as a
lucky roll rather than a bug. So an entry may carry `applies_when`:

```json
{"level": 1, "applies_when": "with a sword", "combat": {"strike": 1}}
```

`bonusesFromSkills` **skips** those entries entirely. `skillConditionalBonuses`
totals them instead, one row per skill and condition, and the sheet lists them
beside the combat block rather than inside it — a player needs both numbers,
and needs to know which is which.

One skill can carry several conditions: a sword swung and a sword thrown are
different bonuses and the book lists them apart, so collapsing them would
quietly add a throwing bonus to melee. An energy weapon's aimed-shot (+3) and
burst (+1) bonuses are level-independent and stack on top of its level ladder,
so those are separate conditions too.

### The merge that was called off

`W.P. Automatic Pistol`, `W.P. Revolver` and `W.P. Automatic and
Semi-automatic Rifles` look like older-edition names for what RUE folds into
`W.P. Handguns` and `W.P. Rifles`, and were one step away from being merged
into them with `catalog_redirects`.

**They are not the same skills.** Each carries its own bonuses, and the
Revolver's aimed shot is **+4** where every other modern handgun proficiency
gives +3. Merging would have deleted that difference from every character who
had taken the skill, with nothing left to recover it from. The smoke test now
asserts the two numbers stay apart, so the merge cannot happen by accident.

The lesson generalises: a name that looks like an old spelling of another is
not evidence that the rows say the same thing. Read both entries first.

**Two W.P.s still have no bonuses**, both with a note but no schedule:
`W.P. Bolt Action Rifle` ("Hunting and sniping rifles") and `W.P. Heavy`
("Machineguns, bazookas, LAWS, and mortars"). RUE has entries whose scope
matches each closely, but after the Revolver, assuming equivalence from a
matching description is exactly the mistake to avoid twice.

---

### Still missing

The book's table for a character with **no** Hand to Hand training (one attack
at level 1, a second at 3, a third at 9) is not modelled — `derive.js`
starts everyone at 2 attacks and takes no level. Only a character with no
fighting skill at all is affected.

---

## Level-up skill picks

`skills.occ_related_skills.schedule` says a class grants extra skill picks at
certain levels — `[{ level: 3, count: 2 }, { level: 6, count: 1 }]`. Crossing
those levels now hands them over.

1. **The proposal lists them**, itemised by the level that earned each one. A
   jump from 2 to 7 collects both the level-3 and the level-6 grants; every
   threshold crossed counts, not just the highest.
2. **Choosing is optional.** Leave a slot blank and the pick is banked in
   `pending_skill_picks`. Levelling up is never blocked on picking a skill,
   which matters when it happens mid-session.
3. **The sheet shows what is unspent** until it is spent, and
   `characters/[id]/picks` applies it whenever the player comes back.

Two rules worth knowing:

- **A picked skill starts at the catalog's base percentage.** A skill learned at
  level 6 is new; it does not arrive back-dated with per-level bonuses.
- **The picker filters to the categories the grant allows**, with a toggle to
  show everything. Picking outside the allowed categories is permitted and
  **recorded as `override: true`** on the skill — so a human decision is visible
  as one, rather than looking like the rules permitted it. This differs on
  purpose from the psionic tier rules, where out-of-tier powers are simply not
  selectable: skill categories get bent at the table, psychic tiers do not.

Spending consumes the oldest grant first, and a grant only partly spent stays
pending with its count reduced — so two picks earned at level 3 can be taken one
at a time. Both paths write the skills and the claim in a single batch, because
a pick that consumed its grant without landing on the sheet would be lost.

## Classes that come in stages

Several RCCs are not one statblock but several. A Dragon is a hatchling, then
young, then adult — sharing lore, natural abilities and skills, differing in
attribute dice, M.D.C. and what the class grants. Four unrelated class files
means maintaining the shared 90% four times and watching it drift.

```yaml
mdc_base: "1d4x100"
variants:
  - id: hatchling
    name: "Dragon Hatchling (Great Horned)"
    starting_money: 100
    # Restates the percentage of a skill the class ALREADY grants. It cannot
    # add or remove one — naming an ungranted skill is an error.
    skill_overrides:
      - { name: "Mathematics: Advanced", base: 45, per_level: 5 }
  - id: adult
    name: "Adult Dragon (Great Horned)"
    attribute_dice: { PS: "4d6+30" }
    mdc_base: "1d6x1000"
    bonuses:
      attributes: { PS: 4 }
      combat: { attacks: 3 }
```

A variant may override **only** the keys in `VARIANT_OVERRIDES`: `attribute_dice`,
`attribute_requirements`, the four pool bases (`hit_points_base`, `sdc_base`,
`mdc_base`, `ppe_base`), `starting_money`, `bonuses`, and `skill_overrides`.
Skills, abilities, lore and equipment stay shared on purpose: a variant that
could override anything is not a variant, it is a second class wearing the
first one's name, and the inheritance would obscure rather than explain.
Setting anything else warns and is ignored.

Note what the last two are *not*. `starting_money` is there because a stage of a
creature may be richer than another; `skill_overrides` restates the percentage
of a skill the class **already grants** and cannot add or remove one — a much
smaller power than overriding the skills block, which stays forbidden. See
[A variant may restate a skill's percentage](house-rules.md#house-rules-and-derived-values).

**`attribute_dice` and `attribute_requirements` merge per key; everything else
replaces.** Those two are flat maps of independent per-attribute values, so a
variant naming one attribute is saying something about that attribute and
nothing about the other seven — replacing them wholesale left an adult dragon
that overrode only P.S. rolling a plain 3d6 for I.Q. A scalar like `mdc_base`
has nothing to merge, and `bonuses` is nested deeply enough that merging would
raise "which half won" on every key: a variant's bonuses *are* its bonuses, and
a variant that states none inherits the class's.

The character records `class_variant` alongside `class_id`; NULL means the class
as written, which is right for every class with no variants. It is its own
column rather than encoded into `class_id`, because every reader of `class_id`
would otherwise have to know to split it, and the ones that forgot would
silently fail to resolve the class.

**Resolution happens in one place**, `loadClass(env, url, classId, variantId)`,
so no caller has to remember that a hatchling and an adult have different pools.
The sheet gets its class already resolved from `characters/:id` — `applyVariant`
lives in `parser.js`, a module, and `sheet.js` is a classic script that cannot
import one. Doing it server-side keeps a single implementation rather than a
second copy that drifts, and removed a whole `/classes` request from the sheet.

The wizard asks which stage after the class is chosen, and will not continue
until one is picked: a Dragon is always some particular age, and defaulting to
the first stage would be choosing for you.

### Changing stage

A hatchling grows up. The **Stage** box on the sheet proposes the change and
applies nothing until it is confirmed — the same two-step a level-up uses, and
for the same reason: the rolls are the point, and a roll you did not watch
happen is a roll you cannot trust.

- **Only what the new stage actually sets is offered.** An attribute whose dice
  the stage does not change is left alone entirely, rather than being re-rolled
  because something else about the creature changed.
- **Each attribute is kept or taken individually.** Ticking *keep* holds the
  number you already had, so a dragon can grow into its body without losing the
  mind it was played with.
- **Pools roll new maxima and current moves by the same amount**, exactly as a
  level-up treats them. Growing up neither heals the damage the character was
  carrying nor leaves it on a hatchling's current with an adult's maximum — a
  creature 40 M.D.C. down stays 40 down.
- **The new stage's rules are checked before it applies.** Its
  `attribute_requirements` may differ, and a character that would not meet them
  is refused rather than arriving there quietly.
- **It is recorded in `level_history`** with `from_level` equal to `to_level`:
  the character did not gain a level, it became something else.

Owner or GM, like every other stat-changing control on the sheet.

---

## Powers the player chooses

`special_abilities` was display-only: the Godling's *"Select THREE powers from
the following"* parsed clean and was never offered. A named ability may now carry
what it grants, and the class asks for the picks.

```yaml
special_abilities:
  - name: "Super-Tough"
    description: "Add 1D6 to P.E. and 3D4x10 to M.D.C."
    bonuses: { attributes: { PE: "1d6" }, pools: { mdc: "3d4x10" } }
  - name: "Shape Shifter"
    description: "Change at will into one animal."
    repeatable: true
    on_repeat: "Can shape shift into ANY type of normal animal."
  - { choose: 3, from: ["Super-Tough", "Shape Shifter", ...] }
```

**Three grant keys, not the variant override set:** `bonuses`, `psionics`,
`magic`. That is what the Godling's eleven powers actually need, and an ability
that could restate `attribute_dice` or `starting_money` is not an ability, it is
a second class wearing one's name. A fragment's `bonuses` block is validated
through exactly the same path a class's own bonuses take, so an ability cannot
express a bonus a class could not.

M.D.C. arrives as a pool **bonus** rather than an override, which is why pool
bonuses had to exist first: Super-Tough adds to whatever the class already rolls
rather than replacing the formula.

#### A bonus here only reaches a character who took the ability

`applyAbilities` folds in the bonuses of abilities that were **chosen** — it
returns the class untouched when nothing was. So a `bonuses` block on an ability
no choice group offers is never granted automatically; it applies only if a
player picks it or a G.M. types the name in.

That makes it the wrong home for something *every* character of the class has.
The Stone Master's Marks of Heritage were written that way — +12 P.P.E. and +20
S.D.C. on a plain ability — and no Stone Master ever received either. It parsed
clean, it read as mechanical, and it did nothing. Bonuses every character gets
belong on the class's own `bonuses`, or on the **variant** when only some
characters qualify: the Marks are True Atlantean only, so that is where they
went.

The parser now warns on it, and no other shipped class trips the warning. It is
a warning rather than an error because a G.M. really can assign such an ability
by name, so the block is reachable — just never on its own.

**Chosen on the class step, not a step of its own.** An ability can add to
attributes and pools, and both are rolled on the two steps after it — choosing
later would re-roll numbers the player had already read. The step will not
advance until every pick is made, the same rule unresolved gear choices follow
and for the same reason: the book intends the character to have them. Unspent
*skill* picks are still banked instead, because those are earned over time.

**Duplicates are meaningful.** Shape Shifter and Magic Powers can each be taken
twice, and the book gives the second take a different meaning rather than a
doubled one — *"can shape shift into ANY type of normal animal"*, not twice the
animals. So `abilities` is a JSON **array**, `repeatable` gates whether a second
pick is offered, and `on_repeat` is the prose that says what the second one
bought. The bonuses do apply again, which is the only honest arithmetic reading;
the powers the books mark repeatable happen to carry no bonuses at all.

**A pick nothing defines is still recorded**, marked as granting nothing. It was
a real choice the player made, and dropping it would leave the sheet disagreeing
with what they picked. An option no definition covers is a warning, not an error
— books routinely name a power they describe only in prose.

Psionics uses the **stronger tier wins** rule composition already uses, so an
ability cannot make a Master psychic weaker.

**An ability may demand an occupation.** The Godling's Magic Powers grants
"all the abilities of a practitioner of magic - pick one: Ley Line Walker,
Shifter, Mystic or Warlock (or Necromancer if evil)". `occ_options` on the
ability definition names those practitioners as **class ids**; choosing the
ability turns the class step's occupation picker into a required choice
narrowed to that list, and the pick lands in `occ_class_id` - the existing
race+occupation composition carries everything from there, which also means
the occupation's related/secondary allowances replace the class's own (the
composition table's normal rule, stated in the picker). Ids not yet in the
catalog are listed disabled rather than hidden, so the day Shifter is
imported nothing needs editing. Dropping the ability releases the slot.
`abilityOccOptions()` in `parser.js` is the one shared reading; the
validator warns (`ability_occ`, never a violation) when a character holds
such an ability with no matching occupation. The second take of a repeatable
ability cannot compose a second occupation - one slot exists - so it stays
what `on_repeat` prose says it is, a G.M. matter.

**Only when the occupation slot is free to spend.** The Demigod's Magic
Powers is the Godling's ability word for word and deliberately carries no
`occ_options`. A godling has R.C.C. skills of its own and no other use for an
occupation, so the slot is there to be spent on the practitioner. A demigod
has no skills block at all: its O.C.C. supplies every skill it will have, and
the book lets it pick "any O.C.C. that fits his human/D-bee background" with
four exclusions. Narrowing that step to five practitioners would forbid the
man-at-arms demigod the same entry grants, which is why the asymmetry between
the two classes is the rule and not an omission - `occ_options` belongs on an
ability whose class does not otherwise need an occupation. The reason is
recorded in the Demigod's own extraction notes as well, because that is where
the next sweep comparing the two abilities will be looking.

**Each class states its own list**, even when the book prints one list and
points several classes at it. A mechanism that resolved one class's options out
of another (`from_class`, PR #80) existed briefly and was removed: its only
intended user was the Demigod, and pointing it at the Godling made one class's
powers depend on another's lifecycle — a printing convenience mistaken for a
relationship. Recoverable from git if a genuinely shared list ever appears.

`applyAbilities` runs inside [`js/compose.js`](../js/compose.js) as step 3 of 4 —
after race and occupation are one, because an ability is chosen for the
character rather than contributed by either half, and before any rolled psionic
tier, so an ability that makes you a master psychic is what a rolled tier has to
beat. What the character holds is on `abilities_taken`, as opposed to
`special_abilities`, which is what the class *offers*.

## What a class grants mechanically

`natural_abilities` and `level_progression.grants` are the book's own wording,
and display-only: the sheet lists natural abilities beside the chosen powers,
and the wizard's class detail shows them to a player still deciding. (`special_abilities` used to belong on that list too; since
[Powers the player chooses](#powers-the-player-chooses), a named ability may
carry `bonuses` of its own, validated through the same path a class's are.) So a Dragon's *"+2 to P.S."* and *"+1
attack per melee at level 5"* were prose that nothing could act on — and no
amount of typing them by hand would change that, because there was nowhere for
a number to go.

`bonuses` is that place:

```yaml
bonuses:
  attributes: { PS: 2 }
  combat: { attacks: 1, strike: 2 }
  saves: { spell_magic: 2 }
  at_level:
    - { level: 5, combat: { attacks: 1 } }
```

**Three layers, in order:** the attribute tables, then what the class grants,
then whatever a human typed — which still wins, exactly as overrides always
have. A GM ruling beats a computed number.

**A flat attribute bonus is never stored on the character.** `attributes` keeps
the numbers that were actually rolled, and the class's `+2` is added on the way
past. That keeps every number's provenance visible, at the cost of one rule:
**nothing may read a raw attribute for a derived value** — it goes through
`derive.effective(attrs, bonuses)` instead. Miss that and a bonus becomes
decorative: P.S. 24 gives a damage bonus of 9, and the class's +2 has to reach
11 or it has done nothing.

The sheet shows one number and explains it on hover — *"+2 from attributes, +1
from Juicer"* — with a dotted underline marking the values a class contributed
to. `derive.parts()` produces that split.

A bonus stated as **dice** is the one exception, and it has to be: a roll cannot
be re-evaluated on every render without changing the number under the player.
Those are rolled once when the class is confirmed and stored — attribute dice
in `attribute_bonuses`, combat and save dice in `rolled_bonuses` — see
[House rules and derived values](house-rules.md#house-rules-and-derived-values).
`derive.classBonuses(cls, level, rolled)` takes them as its third argument and
folds them in beside the flat ones, so everything downstream sees one bonus set
and does not care which kind it was.

**A pool bonus is added to a pool's own formula.** Books write pools three ways,
and only two had a shape. `mdc_base: "P.E. x 10"` states the pool outright, and
omitting a pool lets it fall through to the occupation — but the Demigod says
*"P.P.E.: As per the appropriate O.C.C., plus 4D6"*, which is fallthrough **and**
a modifier. Written as a formula it parsed to NULL and the character had no
P.P.E. at all; omitted, it lost the 4D6. Transcribing the page faithfully was
strictly worse than saying nothing.

```yaml
bonuses:
  pools: { ppe: "4d6", isp: "4d6" }   # and leave ppe_base absent
```

Four things follow from pools being rolled once rather than derived per render:

- **It is the only bonus group that takes dice as well as a number.** Combat and
  save bonuses are always printed flat; a pool bonus is usually a roll.
- **It is rolled with the base and folded into the stored `*_max`.** Nothing is
  re-evaluated later, because a dice bonus read at render time would move the
  character's maximum under them — the same reason `attribute_bonuses` is stored.
- **A bonus cannot conjure a pool the class does not have.** A null base stays
  null. That is the rule that keeps an M.D.C. race from acquiring hit points,
  applied to bonuses.
- **`at_level` does not take one**, and says so rather than ignoring it. Per-level
  growth belongs in the formula (`"P.E. x 5 plus 2D6 per level"`), which is where
  `perLevelDiceOf` already reads it from.

When two classes both grant one, the bonuses are **collected, not summed** — two
dice expressions have no arithmetic sum, so `["4d6", "2d6"]` means both are
rolled. Flat numbers still add. This is deliberately not the merge the other
bonus groups use: theirs drops any non-numeric value, which silently loses a
dice bonus coming from the **occupation** half of a composition.

`at_level` bonuses accumulate and apply the moment the level is reached, because
`classBonuses` is read at render time; nothing further is written to the
character. They appear in the level-up proposal so the change is announced
rather than simply happening.

Extraction fills this in from flat numeric statements, and is told explicitly to
leave **conditional** bonuses as prose — *"+2 to strike when flying"* would
otherwise be applied unconditionally.

### The review step

Attributes and pools sit side by side as two aligned columns; every list —
skills, equipment, spells, psionic powers — runs **down** in columns of fifteen
rather than wrapping across as one dot-separated paragraph. Spells and psionics
are separate sections, and a section with nothing in it is omitted rather than
shown empty.

A Chiang-Ku Hatchling arrives with 34 skills. As prose that was unreadable, and
it hid the thing that mattered: the same skill appearing twice.

**A choice-group never offers a skill the class already grants.** A category
group offers the whole category, which includes skills the class hands out
outright — the Chiang-Ku grants Advanced Math and Art as fixed skills and then
offers Science and Technical. Picking one listed the skill twice and the save
was refused for a duplicate, with no indication of which one. Already-held
skills are now dropped from the options rather than shown disabled: it is not a
choice you might make, it is one you already have.

---

## Psychic tiers

Minor, Major and Master differ in three ways, and only the third is new.

**Where a tier comes from:** the class (`psionics.type`), an ability the player
chose (folded into that same slot before any roll), or the character
(`psychic_tier`, rolled on the Random Psionics Table — see
[Psionics can be rolled for](house-rules.md#house-rules-and-derived-values)). `composeClass()`
folds a rolled tier into the class-shaped object, so everything below applies
the same either way.

Starting power counts are minor 2 / major 6 / master 8 when a class states the
tier, and a class may override with `psionics.powers_starting`. A *rolled* tier
uses the book's own counts instead: 2 for a minor, and 8-from-one-category or
6-from-any for a major. Super psionics are Master-only through
`psionics.categories_allowed`, which is a **category** gate.

**What this adds** is a **per-power** gate. `psionic_powers.min_tier` records the
tier a book states for an individual power, and the picker will not offer one
above the character's tier. The two gates are not the same: a book can put a
Major-only power in Physical or Sensitive, which a Minor psychic can otherwise
reach — and that is the only case where the per-power gate does anything the
category gate does not.

- **`NULL` means no restriction beyond the category**, which is the overwhelming
  majority of rows and the behaviour that existed before. Books state tier at the
  category level far more often than per power.
- **Gated powers are counted, not listed.** "2 more powers need a higher psychic
  tier than minor" — so a short list reads as a rule rather than a gap in the
  catalog.
- **There is no override.** This differs deliberately from the level-up skill
  picker, where an out-of-category pick is allowed and flagged: skill categories
  get bent at the table, psychic tiers do not.
- **A power a character already holds is never taken away.** The gate applies to
  choosing, not to having, consistent with every other rule decision here.
- A class with no `psionics` block has no tier of its own — but its character
  may still have rolled one, and then the gate applies normally. A class that
  sets `psionics_allowed: false` has no tier and never will.

`derive.meetsTier(has, needs)` is the only place the ordering is written down.
Compare through it rather than comparing tier strings.

**Elemental spells are named with their sphere.** `Air: Cloud of Steam`,
`Fire: Fire Bolt`, `Earth: Wall of Stone`. That prefix is load-bearing,
not decoration: `spells.name` is UNIQUE and the four elemental lists collide
both with the Invocation rows already in the catalog (Blinding Flash, Globe
of Daylight, Fire Bolt and Darkness are all both) **and with each other** —
Cloud of Steam is an Air 1st at 4 P.P.E., a Fire 4th at 10, and a Water 1st
at 10. A dozen more repeat across spheres at different levels and costs. The
prefix also gives the Warlock a workflow the schema cannot: the spell picker
filters by name substring, so typing `Fire:` narrows it to that Warlock's
own sphere. Water prints Calm Waters twice, so its 8th level version is
stored as `Water: Calm Waters (greater)`.

**A class may name the exact powers its picks come from.** `psionics.powers_from`
is a list of power names, and the Burster is why: its entry prints seventeen
named minor powers and says "select three". A named list is **more specific
than a category gate, so it replaces it** — exactly as a skill choice-group's
`from` list does, rather than narrowing within the categories. A name the
catalog does not carry is **reported** under the picker rather than silently
shrinking the list, the same reasoning the skill cross-reference uses. The tier
gate still applies on top, so a book that names a power above the character's
tier still says so.

**Powers a class grants outright now reach the character.** `psionics.powers`
and `magic.spells` name what the class simply knows — the Mind Melter's four
automatic powers, the Shifter's twenty spells. The wizard used to save only
what the player *picked*, so those were listed by the class and held by
nobody. They are now written into the character ahead of the picks, and a pick
that duplicates one is dropped so the list stays a set.

**Save vs psionic attack** has a target as well as a bonus, and the books give
**three** of them, not two: a non-psychic needs 15+, a minor **or** major psychic
12+, and a Master Psionic only 10+ (Palladium Fantasy printed 48; Rifts Ultimate
Edition p.65, p.142 and p.185 agree). Non-psychics are on the list because they
get attacked by psionics too and still need a number to roll against.
`deriveSaves()` originally returned only the M.E. bonus and no target at all, and
the first target it grew read `meetsTier(tier, 'major') ? 12 : 15` — one of the
three right, a minor psychic handed the non-psychic's number and a master handed
the major's. `PSIONIC_SAVE_BY_TIER` is keyed by tier rather than compared through
a threshold, because minor and major share a number and master breaks away from
both, which no single threshold expresses. It is overridable like every other
derived value.

---
