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
| 3. How to Determine Psionics | p.20–21 | no — class-driven only |
| 4. Selecting a Race and O.C.C. | p.21–22 | yes |
| 5. Equipment and Money | p.22 | equipment yes, money not at all |
| 6. Rounding Out One's Character | p.22–23, 32–33 | alignment is free text; tables absent |

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

## Step 6 — alignment (p.23)

Seven alignments, and **every character must have one**. There is deliberately
no neutral.

- Good: Principled, Scrupulous
- Selfish: Unprincipled, Anarchist
- Evil: Miscreant, Aberrant, Diabolic

## Experience (p.30–31)

- Levels run to 15; the book gives a per-class XP chart, which this app replaces
  with one shared curve (a documented house rule — see the README).
- The XP award table on p.31 is per action: 25 for performing a skill, 100 for a
  clever useful idea, 150–300 for a great menace, and so on.

## Play-time values not currently derived

From p.17 and p.19, all sheet-display candidates rather than creation rules:
carrying capacity (P.S. × 10, ×20 at P.S. 17+, ×50 for supernatural P.S. 18+),
lifting at twice carrying, death at hit points below **−P.E.**, and coma length
of one hour per P.E. point.
