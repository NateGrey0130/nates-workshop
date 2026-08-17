# Rules audit — Palladium Fantasy RPG 2nd Edition

Where each rule this app implements comes from, so a number can be checked
without re-reading the book.

Page numbers are the **printed** page, which is the PDF page minus one for this
scan — and note PDF pages 18 and 19 are the same printed page 17 duplicated.
The text layer of that PDF is scrambled; the pages have to be read as rendered
images, so do not point an importer at it expecting clean extraction.

Character creation is six steps, printed on p.14 (the book says "five main
steps" and then lists six).

| Step | Printed | Built? |
|---|---|---|
| 1. The Eight Attributes & bonuses | p.14–16 | yes |
| 2. Hit Points and S.D.C. | p.18 | yes, via per-class formulas |
| 3. How to Determine Psionics | p.20–21 | the roll, I.S.P. and powers; penalties not yet |
| 4. Selecting a Race and O.C.C. | p.21–22 | yes |
| 5. Equipment and Money | p.22 | yes |
| 6. Rounding Out One's Character | p.22–23, 32–33 | alignment done; background tables absent |

---

## Step 1 — the Attribute Bonus Chart (p.16)

Implemented in [`js/derive.js`](../js/derive.js), one row per line, asserted
against the printed values in smoke section `[1c17]`.

The rows do **not** share a formula, which is the entire reason this file exists
in its current shape. Values for attributes 16–30:

| Row | 16 | 18 | 20 | 24 | 30 | step |
|---|---|---|---|---|---|---|
| I.Q. → all skills (one-time) | +2% | +4% | +6% | +10% | +16% | +1 per point |
| M.E. save vs psionic attack | +1 | +2 | +3 | +5 | +8 | +1 per **two** points |
| M.E. save vs insanity | +1 | +2 | +3 | +7 | +13 | +1 per two to 19, then +1 per point |
| M.A. trust/intimidate | 40% | 50% | 60% | 80% | 97% | +5% per point, flattening after 24 |
| P.S. hand to hand damage | +1 | +3 | +5 | +9 | +15 | +1 per point |
| P.P. parry, dodge and strike | +1 | +2 | +3 | +5 | +8 | +1 per **two** points |
| P.E. save vs coma/death | +4% | +6% | +10% | +18% | +30% | +1% at 17, then +2% per point |
| P.E. save vs magic/poison | +1 | +2 | +3 | +5 | +8 | +1 per **two** points |
| P.B. charm/impress | 30% | 40% | 50% | 70% | 92% | +5% per point, flattening after 26 |
| Spd | — | — | — | — | — | no bonus at any value |

Nothing below 16 grants anything.

**House rules where the book is silent.** The chart stops at 30 and dragons do
not, so each row continues the step it ends on; and the two percentile rows are
capped at 98%, matching the skill ceiling on p.22 and its stated reasoning that
there is always a margin for error. The flat rows are bonuses added to a roll
rather than percentages, so the cap deliberately does not reach them.

Three saves the app derives are **not** on the chart — possession, horror factor
and pain. Each borrows the printed row for its own attribute. Also a house rule.

### What this replaced

Every row was previously computed as `v - 15`. That is correct for P.S. damage
and for coma/death from 18 up, and wrong everywhere else — parry, dodge, strike
and three saves came out roughly double, M.A. and P.B. climbed past 100%, and
the I.Q. row did not exist. The file described this as "the standard Palladium
attribute tables", which is why it went unexamined for so long.

## Step 1 — rolling (p.14)

- 3D6 per attribute for a typical human; a race may state different dice.
- **Exceptional roll:** on 3D6, a total of 16, 17 or 18 earns one extra 1D6.
  If *that* die is a 6, roll 1D6 once more and add it too — but never a third
  time.
- A **2D6** attribute gets its extra 1D6 on a roll of 12.
- A **4D6, 5D6 or 6D6** attribute never gets an exceptional die, however high it
  rolls.
- A racial bonus may be written into the dice, e.g. `3D6+6`.

All of the above is implemented in [`js/dice.js`](../js/dice.js) and asserted in
smoke `[1c18]`, including the chain stopping at two dice and the threshold
reading the dice rather than the total.

## Step 2 — hit points and S.D.C. (p.18)

- Base hit points equal the **P.E. attribute**, plus one 1D6 rolled once.
- Each new experience level adds another 1D6 (also p.31).
- S.D.C.: men of arms roll 3D6; practitioners of magic, scholars and everyone
  else roll 1D6. Physical skills add more, and all S.D.C. bonuses are cumulative.
- Damage depletes S.D.C. entirely before it touches hit points.

Carried per class as `hit_points_base` / `sdc_base` formulas, which is why
`"P.E. + 1d6 per level"` parses.

## Step 3 — psionics (p.20–21)

- **Random Psionics Table:** 01–09 major, 10–25 minor, 26–00 none. Available to
  a character of any O.C.C., not only psychic classes. A player may skip the
  step entirely.
- **Minor:** 2 powers from any *one* of sensitive, physical or healer.
  I.S.P. = M.E. + 2D6, and +1D6 per level.
- **Major:** 8 powers from one category *or* 6 across all three.
  I.S.P. = M.E. + 4D6, and +1D6+1 per level. Costs the character half its skill
  bonuses and half its "other" skills; secondary skills are unaffected.
- **Master:** only from a psychic O.C.C.
- Some races — troll and orc are named — can have no psychic powers at all.

Implemented in [`js/psionics.js`](../js/psionics.js), asserted in smoke `[1c22]`.
A rolled tier is stored on the *character* (`psychic_tier`, `psychic_shape`) and
folded into the class-shaped object by `withRolledPsionics()`, so the save
targets, the power gating and the level-up I.S.P. growth all keep reading one
place. Four call sites compose a class and every one of them has to remember
that step.

**Not built yet.** The major psionic's cost — *"all skill bonuses are reduced by
half ... and the number of 'other' skills are also reduced by half"* — and the
racial exclusions. Halving the related-skill count is straightforward; halving
the **bonuses** is not expressible today, because a class skill stores a single
`base` with the O.C.C. parenthetical bonus already folded in, leaving no
separable bonus to halve. Splitting it out would mean changing the class schema,
the importer prompt and every authored class. Recorded here rather than faked.

## Step 4 — skills (p.22)

- Three categories: O.C.C. skills, O.C.C. Related skills, Secondary skills.
- A skill's percentage is its catalog base, plus the O.C.C. bonus in
  parentheses, plus the I.Q. bonus — both **one-time**, not per level.
- The O.C.C. parenthetical bonus applies to O.C.C. and related skills only.
  **Secondary skills get no bonus**, but they still advance per level like
  everything else.
- Level 1 is the base; each level after adds the skill's per-level step.
- **Maximum 98%**, always — enforced at creation as well as on level-up, which
  matters now that a large I.Q. bonus can push a high base over it.

The I.Q. bonus reaches secondary skills too. "No skill bonuses are applicable"
is about the bonus printed in parentheses on the O.C.C. page — the same
sentence says it "applies only to O.C.C. related skill selections" — while the
I.Q. bonus is a separate paragraph about the character rather than the
occupation. A skill with no percentage at all (W.P.s, hand to hand) stays at
zero, since a percentage bonus has nothing to modify.
- Not all skill categories are open to every O.C.C., and **not all O.C.C.s are
  open to every race** (p.21).
- Multiple or split O.C.C.s are explicitly not allowed (p.22) — a character is
  one race and one occupation, which is exactly what `combineClasses` models.

## Step 5 — equipment and money (p.22)

Every class starts with its O.C.C. equipment list **and** a sum of coin. The two
are independent: the gear is not bought out of the purse, so nothing deducts
one from the other.

Carried on the class as `starting_money`, a formula string or a flat number,
rolled through the same parser as the pools — so the Reroll button on Review
covers it. Stored in the character's `bio`, because it is a running number the
player edits rather than anything the rules derive. Gold in Palladium Fantasy,
credits in Rifts; an unknown system gets the neutral word rather than a guess.

Only coin belongs here. Saleable goods, gems and artifacts an entry also lists
go in `equipment_starting`.

Worked example, Long Bowman O.C.C. (p.85): *"Money: The character starts with
170 in gold."* → `starting_money: 170`.

## Step 6 — alignment (p.23)

Seven alignments, and **every character must have one**. There is deliberately
no neutral.

- Good: Principled, Scrupulous
- Selfish: Unprincipled, Anarchist
- Evil: Miscreant, Aberrant, Diabolic

The list lives in [`js/rules.js`](../js/rules.js), closed, asserted in smoke
`[1c20]` — including a check that nothing named "neutral" has crept into it.

Required in the wizard, which will not save without one. **Not** enforced
server-side: a character created before the field existed has no alignment, and
rejecting its updates would make it uneditable until somebody guessed what it
used to be. The sheet offers the picker, says when one is missing, and saves
either way. A value that is not one of the seven is preserved rather than
dropped, so merely opening such a character cannot erase what it had.

## Experience (p.30–31)

- Levels run to 15; the book gives a per-class XP chart, which this app replaces
  with one shared curve (a documented house rule — see the README).
- The XP award table on p.31 is per action: 25 for performing a skill, 100 for a
  clever useful idea, 150–300 for a great menace, and so on.

## Class data accuracy

The rules above are only as good as the class definitions they run on. Audited
against their source books:

| Class | Book | State |
|---|---|---|
| Long Bowman | PF main, p.83-85 | **corrected** — `db/fix-long-bowman.sql` |
| Chiang-Ku Dragon | Dragons and Gods, p.22-23 | **corrected** — `db/fix-chiang-ku.sql` |
| Cyber-Knight | Rifts, p.63-64 | **corrected** — `db/fix-cyber-knight.sql` |
| Juicer | Rifts, p.69-71 | **corrected** — `db/fix-juicer.sql` |
| Dragon Hatchling (Great Horned) | Rifts, p.98, p.100 | **corrected** — `db/fix-dragon-hatchling.sql` |

The two audited failed in **completely different ways**, which is the useful
finding.

The **Long Bowman** was hand-written and largely invented: six of eight fields
disagreed, including the attribute requirements, the entire O.C.C. skill list,
the related-skill categories and schedule, and the S.D.C. formula. Only
Wilderness Survival and W.P. Archery survived.

The **Chiang-Ku** was model-imported and every *number* was right — both stages'
attribute dice, hit points, S.D.C., P.P.E., natural A.R., Horror Factor and the
I.S.P. formula all matched. What it got wrong was **applying** the bonuses:
seven skill bonuses sat in `note` prose with no `base`, so each fell back to the
catalog value and the bonus vanished. Climbing read 40 where the book gives 50;
faerie lore read 25 for 40. Psionics granted six powers where the book gives
seven.

So a hand-written class fails on facts, and an imported one fails on the
difference between recording a rule and encoding it. Reviewing an import for
plausible prose will not catch the second kind.

All five are now corrected, and the split held across the rest:

**Hand-written (Long Bowman, Cyber-Knight, Dragon Hatchling)** — invented.
The Cyber-Knight had six related skills where the book gives twelve, two
secondary for six, P.P.E. of 1d6x10 for 6d6, and three O.C.C. skills that are
not Cyber-Knight skills at all. The Dragon Hatchling was worst: **not one of its
eight attribute dice matched**, and it granted four spells to a creature the
book says knows none.

**Model-imported (Chiang-Ku, Juicer)** — accurate prose, inert mechanics. The
Juicer had **no pool formulas at all**, so a Juicer was created with no hit
points and no S.D.C.; and its signature bonuses (+4 initiative, two extra
attacks, +8 vs toxins) were description only. Every word about them was correct.

The Juicer also carried **mojibake**: two dashes stored as raw UTF-8 bytes
decoded as latin-1. Worth knowing that an import can corrupt text silently — and
worth not over-reacting to, since the Chiang-Ku's em-dash *looked* identical in a
terminal and was perfectly fine.

### What the schema still cannot say

Collected across the five, because these recur:

- ~~**Dice-valued attribute bonuses.**~~ **Resolved.** `bonuses.attributes` now
  takes a dice expression as well as a number, and `bonuses.attribute_minimums`
  expresses a floor like the Juicer's "minimum P.S. is 22". The dice belong to
  the class; what they rolled belongs to the character
  (`attribute_bonuses`, migration 016), because a roll cannot be re-evaluated on
  every render. The Cyber-Knight's +1D4 to five attributes and the Juicer's
  +2D6 P.S. / +2D6 P.E. / +2D4x10 Spd / +2D4 P.P. are all applied.
- **Percentage bonuses on a choice group.** "three languages at +30%" — a group
  carries one base and its members have different ones.
- ~~**Per-category skill restrictions.**~~ **Resolved.** A category in
  `occ_related_skills.categories` may now be an object stating what the book
  allows inside it — `{ name: "Espionage", only: ["Escape Artist"] }` or
  `{ name: "Physical", except: ["Acrobatics"] }`. Plain strings still mean
  "any", so nothing already authored had to change. `categoryAllows()` is
  shared by the wizard's picker and the server-side validator, because two
  copies of "may this character take this skill" is the pair that drifts.
  Applied to the Long Bowman (8 of 12 categories), Cyber-Knight (2 of 14) and
  Juicer (4 of 14).
- **A schedule on secondary skills**, which `occ_related_skills` has and
  `secondary_skills` does not.
- **Variant-specific skills.** A Chiang-Ku hatchling's advanced math should start
  at first level; variants override dice, pools and bonuses only.
- ~~**Missing derive keys**: pull punch, save vs illusionary magic, save vs mind
  control.~~ **Resolved.** All three exist now, and the bonuses the books grant
  are applied: the adult Chiang-Ku is +2 to pull punch and +3 to save vs
  illusionary magic, the hatchling +1, and the Juicer +6 vs mind control.

  Checked before widening further: Palladium 2nd Ed.'s Hand to Hand tables
  (p.49) use only strike, parry, dodge, damage, roll with punch and pull punch,
  and the book has no consolidated saving-throw table. Pull punch was the *only*
  combat key missing, and these three are the complete grounded set. Anything
  more would be invented.

**Correcting a class does not change characters already built from it** — skills
are stored per character. The existing production Long Bowman keeps the skills
it was created with, and still validates cleanly against the corrected class.

Two limits met while doing it:

- **Starting equipment could not be corrected.** The gear catalog holds four
  Palladium rows against seventy-four Rifts ones, so most of the book's list has
  nothing to reference. The Palladium equipment chapter has never been imported.
- **`secondary_skills` takes only a count.** The book grants one more at levels
  4, 7, 10 and 13, and there is no `schedule` on that block the way there is on
  `occ_related_skills`. Nor can a category's per-skill restrictions be
  expressed — "Espionage: Escape Artist only" becomes plain "Espionage".

## A guard that silently does nothing

`_` is a single-character **wildcard** in a SQL `LIKE` pattern. A guard written
`markdown NOT LIKE '%mind_control%'` therefore also matches the plain words
"mind control" -- which the Juicer's own notes contain -- so the guard excluded
the row and the update applied to nothing, reporting success.

Every data script under `db/` now guards with `instr()` instead, and a smoke
check fails the build if an underscored `LIKE` pattern reappears, including one
built by concatenation (`'%item_id: "' || slug || '"%'` has the same hazard).

The others were latent rather than live: `'%spells_starting: 4%'` and
`'%item_id: "energy-pistol"%'` happened never to meet the alternative spelling.
They are converted anyway, because these scripts are meant to be re-runnable.

## Setting decisions, not book rules

**Skills and psionic powers are available in every system.** The two lines share
a multiverse, so a campaign can hold both and a psychic is a psychic whichever
realm they walk into. Both catalogs are untagged on purpose; gear is not, since
a laser rifle in a medieval realm is an event in play rather than a creation
choice. See the README for why tagging skills from `source_book` is a trap.

## Play-time values not currently derived

From p.17 and p.19, all sheet-display candidates rather than creation rules:
carrying capacity (P.S. × 10, ×20 at P.S. 17+, ×50 for supernatural P.S. 18+),
lifting at twice carrying, death at hit points below **−P.E.**, and coma length
of one hour per P.E. point.
