# House rules and derived values

Where a number the books do not settle comes from, and the class key that overrides it.

Part of the [character creator](../README.md) documentation.

---

## House rules and derived values

Palladium has no single answer for these, so the app invents one. Each is
overridable.

| Rule | Default | Override |
|---|---|---|
| Point-buy curve | All attributes start at 8, 40-point pool, +1 costs 1 point to 15 then 2 points to 18, cap 18, floor 3, refunds below 8 | — |
| Attribute rolls | Book rule, not a house rule — see below | `attribute_dice` |
| XP table | Shared 15-level curve: 0, 2000, 4000, 8000, 16000, 25000, 35000, 50000, 70000, 95000, 125000, 160000, 200000, 250000, 300000. **Every Palladium O.C.C. now overrides it** — see below | `xp_table: [...]` |
| Psionic starting powers | Book rule for a rolled psychic (minor 2; major 8 from one category or 6 from three). A class states its own; master 8 and Super are class-only | `psionics.powers_starting`, `psionics.categories_allowed` |
| Save vs psionic attack | 10+ for a Master Psionic, 12+ for minor and major psychics, 15+ for everyone else | override `saves.psionics_target` on the character |
| Skills gained on level-up | Start at the catalog's base percentage — a skill learned at level 6 is still new | `skills.occ_related_skills.schedule` |
| Skill percentage cap | 98% — book rule (p.22), applied at creation and on level-up | — |

### Experience is the occupation's, not the race's

Palladium Fantasy printed 336 prints **15 experience charts, 15 levels each**,
and names them by O.C.C. — *Knight & Noble*, *Thief & Merchant*. All 25
Palladium O.C.C.s in the catalog now carry their own, with nothing left over:
the two names on that page without a row here are the Monk, which is
`warrior-monk`, and the Goblin Cobbler, which is not imported.

`xp_table` stores the **lower bound** of each level's band, which is what
`levelForXp` compares against — the printed *"2,181-4,360"* for level 2 becomes
`2181`.

**The fourteen R.C.C.s get nothing, and that is correct rather than missing.** A
race has no experience table, because experience comes from what you do. That is
precisely why an occupation's table has to survive composition: `combineClasses`
carries a named list of keys forward from the occupation, and `xp_table` was not
on it, so since #210 a Knight's chart was dropped on **every Palladium
character** while the race's absence won. A race that *does* state a curve still
wins — a dragon's is the dragon's.

**This is fidelity, not a bug fix.** The house-rule default sits inside the
book's range at every level: at 15 the book spans 290,001 (Vagabond) to 370,201
(Witch) and the default is 300,000. Nobody was levelling at the wrong speed —
they were levelling at the average speed instead of their own class's. The
spread is a 28% difference between the two classes that most deserve to differ.

**The Warlock is the exception.** The catalog's `warlock` is the *Rifts* Book of
Magic printing and carries `system: rifts`, so a Palladium chart in its
frontmatter would apply a Palladium number to a Rifts row. It takes the figures
as a **delta**, in the same `## Palladium Fantasy` section that already records
its money and its armour.

Regression pins the shape over the whole catalog rather than a list of ids, so a
new Palladium O.C.C. arriving without a chart fails there rather than quietly
levelling on the house rule.

**Starting money** (p.22) is `starting_money` on the class — a formula string
like `"2d6x10"` or a flat number — rolled through the same `rollPoolFormula` the
pools use, so Review's Reroll button covers it. It lands in the character's
`bio` rather than a column, because it is a running number the player edits.
Labelled Gold in Palladium Fantasy and Credits in Rifts, from
`rules.currencyLabel()`; an unknown system gets the neutral "Money".

The book gives a character its O.C.C. equipment list **and** a sum of coin, so
nothing is deducted from the other — the gear step is unchanged and the purse is
simply recorded. Only coin goes in `starting_money`; saleable goods and
artifacts belong in `equipment_starting`.

**A choice group may carry a bonus rather than a base.** `base` states the
percentage outright; `bonus` adds to whatever each pick's own base is. A group
spanning a category needs the second — "three languages of choice at +30%"
cannot be one number, because the members start at different percentages.
Setting both is an error. A skill with no percentage (a W.P.) stays at zero,
exactly as the I.Q. bonus already works.

**Secondary skills can arrive on a schedule**, like related ones. A grant
records which kind it is, because the two are not interchangeable: related picks
are bounded by the class's categories and secondary picks are not. The call
sites keep them apart, or one unrestricted secondary grant would unrestrict the
related picks with it. A pick inside the categories spends a related slot; one
outside spends a secondary slot and is stored as a secondary skill.

**A related-skill category may be restricted.** Books state limits per
category — "Espionage: Escape Artist only", "Physical: any except Acrobatics,
Gymnastics and Wrestling", "Medical: none" — and a bare category name offered
all of it. An entry is now either a plain string, meaning any, or an object:

```yaml
categories:
  - "Wilderness"
  - { name: "Espionage", only: ["Escape Artist"] }
  - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
  - { name: "Medical", except: ["M.D. in Cybernetics"], bonus: 10 }
```

Setting both `only` and `except` is an error rather than a guess. A forbidden
skill is **never offered**, rather than offered and rejected on save; the
server-side validator enforces the same rule as a backstop, through the same
`categoryAllows()` helper, so the picker and the validator cannot disagree about
what is legal.

**A category may also carry the percentage the page prints beside it.** Class
pages state these constantly — "Technical: Any (+10%)", "Medical: Any (except
cybernetics; +10%)" — and until `bonus` existed the number had nowhere to go. An
import either dropped it or wrote a `bonus` key that parsed and did nothing,
which is the worse of the two: the class reads complete and the character comes
out ten points low with nothing to show why. The Godling R.C.C. shipped missing
all five of its own, and Pantheons of the Megaverse prints twenty-one across
four classes.

It combines with a restriction rather than replacing it, because the book states
both in one parenthetical, and `categoryLabel()` shows both for the same reason.

Three rules, all of them the books' rather than ours:

- **Related picks only, never secondary.** Every class page says the
  parenthetical percentage "applies only to O.C.C. related skill selections", in
  the same breath as the secondary skills allowance. A `bonus` on
  `secondary_skills.categories` is a parse **error**, not an ignored key — an
  author writing it has misread the page and would otherwise get no signal at
  all. The I.Q. bonus is a separate rule and still reaches both.
- **Keyed on the skill's real catalog category**, not on whichever entry
  admitted it. A cross-category `only` says you may spend a pick here on this
  skill; it does not move the skill into that category for scoring, and reading
  it that way would hand the Glitter Boy's Wilderness Survival an Espionage
  bonus that was never printed.
- **Only to a skill that has a base.** A W.P. or a hand to hand sits at zero
  because it is not percentile, the same guard a choice group's `bonus` uses.

Applied in both places a related pick gets a percentage: `app.js` at creation,
and `functions/api/character-creator/_lib/skill-picks.js` for one picked at
level-up. An out-of-category pick spent as a secondary slot does not get it.

Naming a skill the catalog does not hold yet is harmless: an `except` for a
missing skill excludes nothing, and an `only` narrows the category to what does
exist, so the restriction is already right for the day it is imported.

**But the two fail in opposite directions, and the importer now says so.**
`categoryAllows` compares literal names, so an unmatched `except` fails **open**
— the class goes on offering a skill the book forbids — while an unmatched
`only` fails closed. A not-yet-imported skill and a name the catalog simply
spells differently are indistinguishable, and the second is the common case: the
Godling R.C.C. bars robots, power armor and cybernetics, which this catalog
calls `Robots & Power Armor`, `Robot Combat: Basic` and `M.D. in Cybernetics`,
and its `except` list named none of them that way, so all three exclusions
quietly did nothing. The cross-reference now reports every restriction name that
matches no catalog row, on the review step beside the missing-reference lists.
It is a warning, not a refusal — the forward-compatible case above is still
legitimate.

**The Godling outlived two of those three fixes**, which is the part worth
keeping. Its first import corrected the cybernetics and robot-combat spellings
and left `Robots and Power Armor`; the catalog then renamed that row to
`Robots & Power Armor` and filed the old spelling as a redirect, and the
exclusion went on doing nothing for months while every catalog check passed.
`fix-godling-demigod-accuracy.sql` is what finally closed it. A rename can break
a restriction that was correct when it was written, and nothing but this
cross-reference will say so.

Redirects are deliberately **not** consulted for this check, though they are for
missing references. A merged-away name still resolves as a *reference*, but
`categoryAllows` does a literal comparison, so a redirect does not save a
restriction and reporting it as fine would misdescribe what the picker does.

**A bonus may be dice, in any group.** Some books state one as a roll rather than a
number — the Cyber-Knight adds +1D4 to five attributes, the Juicer +2D6 to P.S.
and +2D4x10 to Spd. `bonuses.attributes` accepts either, and
`bonuses.attribute_minimums` expresses a guaranteed floor ("minimum P.S. is 22;
if lower, adjust up"), applied *after* the bonus lands. That is deliberately not
`attribute_requirements`, which gates whether the class may be taken at all.

The dice belong to the class and the result belongs to the character
(`attribute_bonuses`, migration 016), because a roll cannot be re-evaluated on
every render.

**Combat and save bonuses take dice too**, and for the same reason land in a
stored column (`rolled_bonuses`, migration 019). They were flat-only on the
assumption that books always print them that way — the Godling's *"+1D4 on
initiative"* is the counter-example, and it was a hard parse error rather than
something the format could hold. Attributes keep their own column: 016 predates
this, its flat shape is read directly in several places, and rewriting stored
rows for tidiness would be a poor trade. It is rolled when the class is confirmed, so the Attributes step
can show it beside the roll it modifies, and re-rolled only by Review's Reroll
button — walking to a later step used to re-roll it silently, which changed a
number the player had already read.

**The background tables are rollable** (p.32–33). Nine percentile tables —
birth order, weight, height, age, disposition, land of origin, environment,
family background and racial bias — every one of them optional, with nothing
derived from the result.

Each field the book has a table for gets a die beside it, and one button rolls
everything still blank, so a name and age already decided survive. The Age
table's "double it for an elf, dwarf or changeling" is a checkbox rather than
something detected from the race field, which is free text.

Four of the nine had no bio field and now do; all nine store in the same `bio`
blob, so there is no migration.

**A variant may restate a skill's percentage.** `skill_overrides` names skills
the class already grants and changes only their `base` and `per_level` — a
Chiang-Ku hatchling starts its advanced math and domestic skills at first-level
proficiency where the adult has them at 96% and 80%. Naming a skill the class
does **not** grant is an error, not a way to add one, so the rule that a variant
cannot restructure the skill list still holds.

**A rolled major psionic pays for it.** The starting related-skill count is
halved, rounding down; secondary skills are untouched, as the book says. This
wizard asks for skills before powers where the book asks in the other order, so
rolling major trims any picks already made beyond the new allowance and says how
many went. A psychic O.C.C. never rolls and never pays. A class may also declare
`psionics_allowed: false` — troll and orc have no psychic potential at all —
which skips Step 3 entirely.

**Psionics can be rolled for** (p.20–21). A class granting no psychic powers
sends the character to the Random Psionics Table — 01-09 major, 10-25 minor,
26-00 none, so three quarters of characters get nothing and that is the ordinary
result. Rolling can never reach **master**, which comes only from a psychic
O.C.C.; a class that already declares psionics does not roll at all, because the
book offers the two routes as alternatives rather than as things that stack.

A minor psychic takes 2 powers from one category; a major takes 8 from one or 6
from any of the three, and picks which. I.S.P. is M.E. + 2d6 (minor) or M.E. +
4d6 (major), growing 1d6 or 1d6+1 an experience level.

The tier belongs to the **character**, not the class — `psychic_tier` and
`psychic_shape`, migration 015. `withRolledPsionics()` folds it into the
class-shaped object, so the save target, the power gating and the level-up
growth all keep reading `cls.psionics` exactly as they do for a Mind Mage.
Exactly one place applies it, because exactly one place composes a class — see
[One place composes a class](../README.md#one-place-composes-a-class). It did not start that
way, and the missed call site is the bug that caused the refactor.

**Alignment is required** and closed (p.23). Seven values in three groups —
Good (Principled, Scrupulous), Selfish (Unprincipled, Anarchist) and Evil
(Miscreant, Aberrant, Diabolic) — with deliberately **no neutral**; the book
spends a paragraph ruling it out. The list lives in `js/rules.js`.

The wizard will not save a character without one. It is *not* enforced
server-side, because a character created before the field existed has none and
rejecting its updates would make it uneditable until somebody guessed what it
used to be. The sheet offers the picker, marks a missing alignment, and saves
either way — and a value that is not one of the seven is preserved rather than
dropped, so opening such a character cannot erase what it had.

**Exceptional attribute rolls** (`js/dice.js`, p.14) are the book's, not ours. A
3d6 attribute rolling 16, 17 or 18 earns one extra 1d6; if that die is a six it
earns **one** more, and the chain stops there however the second lands. A 2d6
attribute earns its extra die on a 12. Nothing else does — 4d6, 5d6 and 6d6 are
excluded by name however high they roll, and pools the book does not mention get
nothing rather than an invented threshold.

The threshold reads the **dice**, not the total: a race written `3d6+6` is
exceptional when its dice show 16, not when the total reaches it — otherwise a
below-average roll of 10 would earn a reward reserved for the top of the range.

A class that spells out its own `3d6` now behaves identically to one that says
nothing. It used to not: stating the dice took a branch that skipped the bonus
die entirely, so the same 3d6 produced different characters depending on how the
class happened to be written. The wizard shows the working (`3d6 18 ·
exceptional +6, +4`) because an unexplained 28 off a 3d6 reads as a bug.

**Attribute-derived values** (`js/derive.js`) come from the Attribute Bonus
Chart on p.16, transcribed row by row — see
[`docs/rules-audit.md`](rules-audit.md) for the full table and
[`test/smoke.mjs`](../test/smoke.mjs) `Attribute bonus chart`, which asserts the printed values.

The rows deliberately disagree with one another, and that is the point:

| Attribute | Drives | Shape of the row |
|---|---|---|
| P.P. | strike, parry, dodge | +1 per **two** points from 16 |
| P.S. | damage bonus | +1 per point from 16 |
| P.E. | vs poison, drugs, disease, spell/ritual magic, curses, faerie magic, pain, illusionary magic | +1 per **two** points |
| P.E. | coma/death | +4% at 16, +5% at 17, then +2% a point |
| M.E. | vs psionics, possession, horror factor, mind control | +1 per **two** points |
| M.E. | vs insanity | +1 per two to 19, then +1 a point |
| M.A. | invoke trust/intimidate | 40% at 16, +5% a point, flattening after 24 |
| P.B. | charm/impress | 30% at 16, +5% a point, flattening after 26 |
| I.Q. | one-time bonus to every skill percentage | +2% at 16, +1% a point |
| Spd | running distance, Spd × 5 yards per melee | no bonus at any value |

Only P.S. and Spd match the `v - 15` this file used to apply to everything.
Parry, dodge, strike and three saves were roughly **double** the printed value,
M.A. and P.B. climbed past 100%, and the I.Q. row was missing outright.

Two house rules where the book stops: rows **continue past 30** on the step they
end on, since the chart ends there and dragons do not, and the two percentile
rows are **capped at 98%**, matching the skill ceiling. The flat rows are
bonuses added to a roll rather than percentages, so the cap does not reach them.
Possession, horror factor, pain, illusionary magic, mind control, curses, faerie
magic and disease are not on the chart at all; each borrows the row for its own
attribute. Every one of them exists because a real class or race grants a bonus
to it, and **until there is a key the bonus reaches nothing** - it parses, it
stores, and it renders nowhere. The last two arrived with the Palladium Fantasy
player races: goblins and hob-goblins are +1 to save vs faerie magic, gnomes +1
and troglodytes +2 to save vs poison and disease.

`sheet.js` declares the labels for all of them **once**, in `SAVE_FIELDS`, and
play mode's roll buttons are `SAVE_FIELDS` minus the one percentile row rather
than a second list. There were two lists, and they had drifted: the sheet printed
thirteen saves and play mode offered eight buttons, so a Juicer's +6 vs mind
control was on the sheet and unrollable at the table. A smoke check now fails if
`derive.saves()` produces a key nothing prints, if a label names a key derive
does not produce, or if the list is declared twice.

`iq_skill_bonus_pct` is exposed by `derive.bio()` and applied to every skill at
creation — see **The I.Q. bonus** below for what that means and what it skips.

Every derived value shows on the sheet as a placeholder on a dashed input;
typing overrides it and the field stops being marked derived. **Blank means "use
the table."** Attacks per melee beyond the base 2, and knockout/critical
thresholds, are deliberately *not* derived — they come from Hand to Hand tables
this app does not model, so they are plain editable fields.

Skills omitting `base` fall back to the catalog value — sourcebook class pages
state the *bonus*, with the base living in the skill table.

**The I.Q. bonus** (p.22) is a one-time addition to every skill percentage, made
at creation and never again. It reaches secondary skills too: the book's "no
skill bonuses are applicable" is about the bonus printed in parentheses on the
O.C.C. page — the same sentence limits that one to related selections — while
the I.Q. bonus is a separate paragraph about the character. Skills with no
percentage at all (W.P.s, hand to hand) stay at zero.

`pct` remains the true current percentage, because level-up increments it and
the sheet prints it; each skill also carries `iq_bonus` recording how much of it
came from I.Q., so 39% is distinguishable from a skill whose base genuinely is
39. The sheet shows it inline after the name.

**Secondary skills are no longer frozen.** The wizard used to write
`per_level: 0` on every one of them, which is right about the O.C.C. bonus and
wrong about everything else — the book says plainly that *all* skills increase
with experience. A level 10 character's hobby skills sat at their level 1
values. They now carry the catalog's real per-level step.

---
