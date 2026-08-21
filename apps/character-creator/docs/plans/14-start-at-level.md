# PR 14 — Starting above level 1

> **Built.** Decisions taken in an interview on 2026-08-20; the **As built**
> notes below record where the plan turned out to be wrong.

## Problem

Every character starts at level 1. A player joining an established party has to
be built at 1 and then levelled up five times through the XP endpoint, one
confirmation at a time, which is both tedious and wrong — the XP the character
never earned has to be invented to get there.

## The engine already exists

`buildProposal(character, cls, earnedLevel)` in `_lib/leveling.js` computes the
whole diff for a span of levels: pool growth per level, per-level skill
percentage increases, and skill grants **itemised by the level that earned
each**, with unclaimed ones banked in `pending_skill_picks`. It already handles
multi-level jumps — `skillGrantsFor(cls, 2, 7)` collects the level-3 and level-6
grants both.

So "start at level 6" is not a second system. It is *build at level 1, then run
the existing 1→6 proposal before the character is ever saved*. Everything below
follows from refusing to write a parallel implementation of levelling.

## Decisions

**As built: the level selector is on the RACE step, not the Occupation step.**
The plan put it on Occupation, reasoning that it is the first point where both
class halves are known. That step does not exist for a character whose primary
class is an O.C.C. — which is most Rifts characters, and exactly the ones a
player joining an established party would build. The Race step always renders
and comes before everything that scales, so the control lives there and the
preview of what the level adds lives on the Advancement step, which is that
step's whole job anyway.

**As built: the engine had to move into the app.** The plan said "reuse
`buildProposal`" without noticing that it lives under `functions/`, which a
browser cannot import. `js/leveling.js` is now the implementation and
`_lib/leveling.js` re-exports it, leaving every server import unchanged — the
same arrangement `js/dice.js` already had, which `_lib/leveling.js` was already
reaching across for.

**As built: one proposal per level, not one for the span.** The plan implied a
single 1→N call. That gives one lump sum and no way to itemise or re-roll a
single level, so the step runs the engine once per level gained.

**As built: the audit had to learn about `xp`.** The `xp_below_level` warning
was written, shipped and could never fire, because `admin/audit.js` passed only
`{ level }` to the validator. Caught by checking rather than by assuming — it is
the same dead-key failure the README already documents for bonuses.

**A new Advancement step, present only when the starting level is above 1**, and
placed **after Powers, before Details**:

```
… → Skills → Equipment → Powers → Advancement → Details → Review
```

By that point the level-1 character is completely built, which is precisely the
input `buildProposal` takes. Rejected: folding per-level grants into the Skills
and Powers steps (picks for level 1 and picks for level 5 would interleave on
one screen with nothing distinguishing them), and putting Advancement before
Powers (an ability chosen at level 1 can change the psionic tier, and the tier
gates which powers later levels may pick).

**Batched, with per-level expanders.** The step shows one summary by default —
total pool gain, all skill picks, all spell and psionic picks — and each level
is a collapsible section that can be opened to roll and choose individually. A
player who wants six levels resolved in one click gets that; one who wants to
roll each level's hit points separately gets that too. Rejected: forcing the
sequence level by level (six screens for a level-6 character), and a level-N
stat block with no retroactive picks (it silently skips every grant the O.C.C.
schedule earns, which is the main thing being asked for).

**The starting level is chosen freely**, 1 to whatever the class's own XP table
caps at — on the **Race step**, not the Occupation step this plan originally
named (see the As built note above). No campaign cap, no GM approval. Rejected: a campaign
starting-level setting and a GM approval gate; both add an administrative path
before there is any evidence one is wanted.

**XP is set to the level's cumulative threshold** on save, from `xpTableFor(cls)`
so a class-supplied `xp_table` wins. Without it a level-6 character has 0 XP,
the XP endpoint believes it is under-levelled, and the next award triggers a
spurious level-up proposal. Rejected: leaving XP at 0, and asking the player for
an XP figure.

**Starting gear and money are NOT scaled.** A level-6 character receives exactly
the `equipment_starting` and `starting_money` its class grants a level-1
character. This is deliberate and was decided against explicitly: the books do
not rule on it, so any multiplier would be an invented rule, and what a veteran
owns is a table conversation. **Do not quietly add a per-level allowance.**

**Unclaimed picks bank, as they already do.** The Advancement step may be
completed with slots left blank; they land in `pending_skill_picks` and the
sheet shows them unspent. Levelling is never blocked on a pick, and neither is
character creation.

## The gap this exposes

**The class format has no per-level schedule for spells or psionic powers.**
`magic.spells_starting` and `psionics.powers_starting` are level-1 counts. Only
skills carry a `schedule: [{ level, count }]`. The books do state per-level
spell gains — a Ley Line Walker learns new spells at every level — but nothing
in the extracted data says so, and **inventing a number here is exactly the
failure the import rules exist to prevent** (see *A field the prompt does not
mention is a field that never arrives* in the README).

So this PR adds the field and the honest fallback:

```yaml
magic:
  spells_starting: 6
  spell_levels_allowed: [1, 2]
  spells_per_level: 2                    # NEW — flat count gained each level
  # or, when the book varies it:
  spells_schedule: [{ level: 2, count: 2 }, { level: 3, count: 3 }]
psionics:
  powers_starting: 3
  powers_per_level: 1                    # NEW
  powers_schedule: [{ level: 4, count: 2 }]
```

Both keys optional, both read the same way `occ_related_skills.schedule` already
is, and both flow through the same "every threshold strictly above `fromLevel`
and up to `toLevel`" rule so the arithmetic is shared rather than re-derived.

**A class that states neither grants no spells or powers on level-up, and says
so.** The Advancement step prints *"This class's definition does not record what
it learns per level — add them by hand or import the field."* It does not guess,
and it does not silently show nothing. That message is the feature: it tells the
player the data is missing rather than letting them believe a Ley Line Walker
genuinely learns nothing at level 4.

The importer prompt (`_lib/extraction-prompt.js`) must name the new keys, or
they will never arrive — that is the whole lesson of `variants` shipping as
schema the prompt never mentioned.

## Schema

None on `characters`. `level` and `xp` already exist and already carry this.
`pending_skill_picks` already exists and takes the banked picks unchanged.

The class-format keys above live in `imported_classes.markdown` frontmatter,
which is schemaless by design — no migration.

## Work

**`_lib/leveling.js`** — generalise what `skillGrantsFor` does:

- `spellGrantsFor(cls, from, to)` and `psionicGrantsFor(cls, from, to)`, reading
  the new keys, returning grants itemised by level, and returning an explicit
  `unknown: true` (not an empty array) when the class states nothing. Empty and
  unknown are different answers and the UI shows them differently.
- `buildProposal` carries both onto the proposal alongside `grants`.

**`apps/character-creator/app.js`** — the Advancement step:

- Renders `buildProposal(levelOneCharacter, composedClass, startingLevel)`.
- Summary view plus per-level `<details>` expanders; each pool die rollable
  individually or all at once.
- Spell picks filter to `magic.spell_levels_allowed`; psionic picks filter to
  the character's tier, using the existing tier rules — **out-of-tier powers
  stay unselectable**, unlike skill categories which may be overridden. That
  asymmetry is deliberate and already documented; do not level it out.
- The step is skipped entirely when the starting level is 1, and the Occupation
  step's level control is the only thing that makes it appear.

**Save path** — the character is written at its starting level with XP set to
the threshold, its granted skills at catalog base percentages (a skill learned
at level 5 is new, not back-dated), and any unspent grants inserted into
`pending_skill_picks` in the same batch. One batch, because a grant recorded as
spent whose skill never landed is a pick lost forever.

**`_lib/validate-character.js`** — a character above level 1 whose XP is below
its level's threshold is a warning, not a violation. Hand-edited data and
imported characters both produce it legitimately.

## Depends on

[PR 13](13-rcc-first-wizard.md), for the step list and for the composed class
being settled before the Advancement step reads it.
