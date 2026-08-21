# PR 13 — R.C.C.-first wizard

> **Built.** Decisions taken in an interview on 2026-08-20; see the
> **As built** notes below for the two places the plan was wrong.

## Problem

The wizard's step 2 is one **Class** step holding both halves of a character —
the race and the occupation — and attributes are rolled on step 3, after both
are chosen. That order is safe (see below) but it inverts how a Palladium
character is actually made: you are a dragon first, you roll to find out what
kind of dragon you are, and only then do you decide what the dragon learned.

The R.C.C. also gets no room of its own. A racial class carries attribute dice,
pool formulas, fixed skills, a psionic tier, natural bonuses and often M.D.C. —
and the player commits to all of it from a picker row.

## Decisions

**Class splits into two steps with Attributes between them.**

```
System → Race → Attributes → Occupation → Skills → Equipment → Powers → Details → Review
```

Nine steps, up from eight. Rejected: keeping one step and rolling in place on
the race screen (the roll stops reading as its own commitment, and the screen
has to hold a picker, a full R.C.C. briefing and a dice tray at once); and
folding Skills and Powers into one *Allocations* step at the same time (a
separate change that would ride along unreviewed).

**The Race step is a briefing, not a row.** Before confirming, the player sees
what the R.C.C. actually grants: the attribute dice it will roll, per attribute;
the pool formulas (H.P./S.D.C./M.D.C./P.P.E./I.S.P.) as formulas, not yet as
numbers; fixed skills at their base percentages; the psionic tier (or
`psionics_allowed: false`); natural bonuses; and whether the race *normally
requires* an occupation — the `needsOccupation()` wording that already exists.
Confirming the race is what unlocks the roll.

**A character may be an O.C.C. alone.** The Race step is skippable, and skipping
it produces a human character exactly as today. The Occupation step is likewise
optional-but-flagged. Neither becomes mandatory; the reorder changes sequence,
not requirements.

### The minimum problem, and its fix

Attribute **minimums come from both classes — the stricter of each**. Rolling
before the occupation is chosen therefore admits a state the old order made
impossible: a stat block that fails the O.C.C. the player then wants.

**Re-roll the failing attribute only.** When the chosen O.C.C. raises a minimum
the rolled block misses, the Occupation step names the attribute and the number
missed by, and offers to re-roll **that attribute alone**, using the race's dice
for that stat. Whatever it comes up as, it stands — including a second failure,
which may be re-rolled again only if the player chooses to. Rejected:

- **Re-rolling the whole block** — throws away good rolls to fix one bad one.
- **Auto-raising to the minimum**, silently or otherwise. Several books instruct
  exactly this, and it is still rejected here: the sheet would stop reflecting
  real dice, and this app's whole posture is that a number on the sheet came
  from somewhere. A house rule that raises can be added later as an explicit,
  recorded action; it must not be the default and must not be silent.
- **Offering the player a choice between re-roll and raise** — two mechanisms
  where one will do.

**It is never a refusal.** A player may decline the re-roll and proceed with an
occupation whose minimum the character misses. That is the existing doctrine for
occupations — `validate-character.js` warns, it does not block — and this
inherits it rather than inventing a stricter rule for the same class of problem.
The warning surfaces in the wizard, on save, and in the admin audit under *worth
a look*.

**A re-roll is recorded as a character event.** The events log already exists
(`characters/[id]/events`, with undo). A minimum re-roll writes one, so the
sheet's history shows the assist rather than presenting the final number as the
first thing the dice said.

## Schema

None. Every field this needs exists.

## Work

**`apps/character-creator/app.js`**

- `STEPS` becomes the nine-step list above. `Class` splits into `Race` and
  `Occupation`; the existing class-step rendering divides along the seam that is
  already there (the R.C.C. picker and the O.C.C. picker are separate widgets in
  one step today).
- The Race step gains the briefing panel. It reads a *single* class through
  `applyVariant` — not `composeClass`, which needs both halves — so a dragon's
  stage variant is reflected in the dice it shows.
- The Attributes step is unchanged except that it now runs with only the race
  known: minimums applied are the race's alone.
- The Occupation step gains the minimum check. On selecting an O.C.C. it
  composes via `js/compose.js` (never `combineClasses` directly — the smoke test
  fails the build for that), diffs the composed minimums against the rolled
  block, and renders the shortfall with a per-attribute re-roll button.
- Abilities with `occ_options` already turn the occupation picker into a
  required narrowed choice. That logic moves with the picker and is otherwise
  untouched.

**As built: `S.cls` had to split into three, not two.** The plan named `S.rcc`
(what was picked) and `S.cls` (what the character is) and missed that the race's
dice bonuses are *rolled* on confirm and *read* on the Attributes step — so
composing an occupation in afterwards re-rolled a number the player had already
seen. `S.raceCls` holds the race alone, `S.attrBonuses` and `S.occAttrBonuses`
hold the two sets of rolls separately, and `rolledAll()` is the only reader that
sees them summed. Changing occupation re-rolls its half and leaves the race's
alone. This also fixed a latent bug: `resumeDraft` composed without passing
`abilities`, so a resumed build silently lost every ability-granted bonus.

**Draft migration.** `draft.js` persists `step` as an **integer index** into
`STEPS`. Every in-flight draft saved at step ≥ 2 points at the wrong step after
the split, and the resume banner prints the wrong name (`app.js:349`). Drafts
are unfinished builds a player expects to come back to, so this cannot be left
to chance:

- Store a `steps_version` on the draft. Absent or `1` means the eight-step list.
- On load, map an old index forward. **As built:** the mapping in this plan
  was off by one. Attributes was index 2 before the split and is index 2 still
  — only the steps *after* the inserted Occupation step move. So 0→0, 1→1
  (Class→Race), 2→2 (Attributes), and 3..7 → 4..8. A draft stopped on the old
  Class step resumes on Race, which is correct — it had not committed an
  occupation yet in any way the new step can trust.

  The smoke test now pins the list, the version and the mapping together,
  including the assertion that no old index can land on Occupation.
- Newly written drafts carry `steps_version: 2` and are read literally.

Rejected: renaming steps by string instead of index (a larger change to the
draft format for a one-time problem), and discarding old drafts.

**Tests.** The existing smoke test asserts the README documents what the code
does. Add: the nine-step list, an old-index draft resuming at the right step,
and a composed minimum producing exactly the attributes that fall short.

## Depends on

Nothing. This ships alone, and [PR 14](14-start-at-level.md) assumes it has.
