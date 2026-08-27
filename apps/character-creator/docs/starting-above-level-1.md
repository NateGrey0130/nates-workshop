# Starting above level 1

Building a character that begins at level 5 by replaying the level-up engine — and the
spell and psionic catalog work that took.

Part of the [character creator](../README.md) documentation.

---

## Starting above level 1

A player joining an established party used to have to be built at 1 and levelled
up five times through the XP endpoint, one confirmation at a time, inventing the
XP the character never earned to get there.

The wizard now asks for a **starting level** on the Race step, 1 to whatever the
class's own XP table caps at. Above 1, an **Advancement** step appears after
Powers.

**It is not a second system.** `buildProposal(character, cls, toLevel)` already
computed the whole diff for a span of levels, and by the end of the Powers step
the level-1 character is complete — which is exactly the input that function
takes. So starting at level 6 is *build at 1, then run the engine the live
level-up already uses*. That is why `js/leveling.js` moved into the app: the
browser cannot import anything under `functions/`, and
`_lib/leveling.js` now re-exports it so every server import is unchanged. Same
arrangement as `js/dice.js`, and for the same reason.

**One proposal per level, not one for the span.** The step runs the engine once
for each level gained, which is what makes a single level re-rollable — open
level 4, re-roll its dice, and every other level stays exactly as it stands.
Each level's growth is independent of the running total (the proposal reports
`from`/`to` and only the difference is kept), so every call starts from the
level-1 character.

The step opens on the summary — total pool growth, all skill picks, all spell
and psionic picks — with a collapsed section per level underneath. A player who
wants six levels resolved in one click gets that; one who wants to roll each
level's hit points separately gets that too.

### What the levels are allowed to change

| | |
|---|---|
| pool maxima | **rolled**, per level, from the class's `per level` formula |
| skills held since level 1 | advanced by `per_level × levels gained`, capped at 98% |
| skills picked with a grant | **not** advanced — a skill learned at level 5 is new, and starts at its catalog base |
| skill picks left blank | banked in `pending_skill_picks`, shown unspent on the sheet |
| XP | set to the level's own threshold, server-side |
| starting gear and money | **unchanged** |

**Gear and money do not scale, deliberately.** The books do not rule on what a
veteran owns, so any multiplier would be an invented rule and what a level-6
character has is a table conversation. Do not quietly add a per-level allowance.

**XP is not sent by the client.** The server reads `xpTableFor(cls)` and sets XP
to `thresholdFor(table, level)`, so the level and the XP beside it cannot
disagree. A level-6 character left at 0 XP reads as under-levelled to the XP
endpoint, and the very next award proposes a level-up it has already had.

**The server does not trust the pick count.** The wizard sends `picks_spent`;
the create endpoint recomputes the allowance with `skillGrantsFor(cls, 1, level)`
and banks the remainder, consuming from the earliest grant first — the same rule
a live level-up follows, now shared as `remainingGrants()` so the two cannot
drift. The character is also validated at **the level being created**, not at 1,
because the related and secondary allowances grow with level and judging a
level-6 character against a level-1 allowance refuses skills its class granted.

`validate-character.js` warns `xp_below_level` when a character above level 1
has less XP than its level needs. Hand-edited data and a G.M. levelling someone
by hand both produce it legitimately, so it is a warning and never a violation —
and the admin audit had to start selecting `xp` and passing it, because a
warning nothing hands the number to is a warning that never fires.

### Per-level spells are not in the data

`magic.spells_starting` and `psionics.powers_starting` are **level-1 counts**.
Until this change nothing in a class definition said what is learned per level —
only skills had a `schedule`. The books do state it, so the honest answer for a
class that has not been re-imported is *not recorded*, which is a different
answer from *none*:

```yaml
magic:
  spells_starting: 6
  spells_per_level: 2                                  # a flat rule
  # or, when the book varies it:
  spells_schedule: [{ level: 2, count: 2 }, { level: 3, count: 3 }]
psionics:
  powers_per_level: 1
  powers_schedule: [{ level: 4, count: 2 }]
```

`spellGrantsFor` and `psionicGrantsFor` return three distinguishable states:
`applicable: false` (the class has no magic at all), `unknown: true` (it has
magic and states no per-level rule), and a list of grants itemised by the level
that earned each. The Advancement step prints the difference — a class stating
nothing says so and offers nothing, rather than showing an empty list that reads
as *this class learns nothing at level 4*.

`startingPicksFor` draws the same three states for the **level-1** pick, which
went the other way for longer: a class with magic and no `spells_starting` got
a full picker over every spell in the catalog with every row disabled. See
[wizard-and-sheet.md](wizard-and-sheet.md), "An empty starting pick has four
different meanings".

A schedule is the **complete** statement when present and a flat `*_per_level`
is ignored alongside it. Two keys that combine is a rule nobody remembers
correctly six months later.

**How many is not the same question as which.** The Ley Line Walker learns *"2
additional spells per level of experience, equal to or lower than their current
level of experience, starting at level 2"* — a cap that tracks the character
rather than a list, and one that **disagrees with the starting selection on
purpose**: a fresh walker picks twelve spells from `spell_levels_allowed:
[1,2,3,4]`, and the two it gains at level 2 may only be spell levels 1–2.

```yaml
magic:
  spells_starting: 12
  spell_levels_allowed: [1, 2, 3, 4]              # the starting twelve
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level  # the per-level pair
```

`spells_per_level_levels` takes `up_to_character_level` or an explicit list, and
falls back to `spell_levels_allowed` when absent — so it costs nothing for a
class whose per-level picks are not capped this way.

**A schedule entry may override all of it**, because some books vary the cap per
level rather than by one rule. The Mystic (RUE p.119) is the case that forced
it: four spells at level 2 from spell levels 1–3, three at level 3 from 1–4,
then two per level from its own level downward. The first two are the
character's level **plus one** and the rest are the character's level, which no
single rule expresses.

```yaml
magic:
  spells_starting: 8
  spell_levels_allowed: [1, 2]
  spells_per_level_levels: up_to_character_level   # what entries without one use
  spells_schedule:
    - { level: 2, count: 4, spell_levels: [1, 2, 3] }
    - { level: 3, count: 3, spell_levels: [1, 2, 3, 4] }
    - { level: 4, count: 2 }
    # … every level, to the class's cap
```

An entry's own `spell_levels` wins; entries lacking one fall back to the
class-wide rule. And because a schedule is a finite list, **"and each additional
level of experience" has to be written out** — to 15, the default XP table's
cap. A class with a shorter `xp_table` simply never reaches the tail.

### Several grants can share a level, and a rule can be unenforceable

The Shifter needed both. It gains **three** spells at every level from level two,
and they do not come from the same place:

> Starting at level two, the Shifter can choose one spell from the following
> list plus one Protection or Summoning spell also in this list: *[34 named
> spells]* … and any Summoning spell that may be desired, excluding weather
> summoning. In addition, the Shifter can select one non-dimension related or
> control based spell, but they are limited to spells equal to or less than the
> Shifter's current level of experience.

So the **level alone stopped identifying a grant**. Entries sharing a level are
told apart by `slot`, and everything that keys a grant — the room accounting, the
banking, the pick payload — keys on level *and* slot.

```yaml
magic:
  spells_per_level_from: ["Banishment", "Charm", …]   # declared ONCE
  spells_per_level_levels: up_to_character_level
  spells_schedule:
    - { level: 2, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell" }
    - { level: 2, count: 1, note: "Not dimension-related or control-based" }
```

`from_list` points at a list declared once rather than repeated on every entry.
It takes two forms, because a class can have one list or several:

| | |
|---|---|
| `from_list: true` | the class's single list, `spells_per_level_from` — the Shifter |
| `from_list: "A"` | one of several, from a `spell_lists` map — the Ley Line Rifter, which learns *"one spell (pick one) from each list"* every level |

Repeating a thirty-four name list on every entry would put it in the class
definition fourteen times and make one correction fourteen edits. **A slot
bounded by a named list is not also bounded by a spell level** — the list is the
restriction. A `from_list` naming a list that does not exist restricts nothing
rather than everything, which is the safer direction to fail.

**Modelled as two grants, not three**, because the difference between the book's
first two is a restriction nothing can check.

Both classes named spells the catalog did not have, and closing that gap
turned into most of a book import - two Invocation lists, the six spell levels
RUE overrides, four duplicated rows, the psionics gap, and the import tooling
that came out of it. That is its own subject:
[Spell and psionic catalog imports](spell-and-psionic-imports.md).

### A psionic grant can name its categories, and they replace the class's

Same shape, different subject, and the Mystic needed both halves — which is why
it is the class worth designing against. Bullet 4 of the same page:

> Select three additional psychic abilities from the **Sensitive** category and
> another two from the **Healer** category. At levels four and eight the Mystic
> can select one additional ability from the **Super** category.

```yaml
psionics:
  type: major
  powers_starting: 5
  categories_allowed: ["Sensitive", "Healing"]
  powers_schedule:
    - { level: 4, count: 1, categories: ["Super"] }
    - { level: 8, count: 1, categories: ["Super"] }
```

**A grant's categories REPLACE the class's rather than narrowing them**, and
that is the whole point rather than a convenience. Every catalogued power has a
NULL `min_tier`, so the per-power tier gate never fires and **tier is enforced
by category**: Super is master-only because non-masters are not offered it. A
grant naming Super *is* the book granting a major psychic an exception, so
intersecting it with the class's own categories would throw the exception away
and leave an empty picker.

Which also means **the psionic picker is per grant**, as the spell picker
already was. It used to be one batched set, on the reasoning that no book states
which level a given power had to be learned at. The Mystic states exactly that.

`pending_power_picks.categories` carries it for a banked grant, copied at grant
time for the same reason `spell_levels` is.

**Which is why the spell picker is per grant, not one batched set.** Each level's
spells are chosen from the levels *that* level allows, the way skill picks are
already chosen from the categories their grant allows. Batching them would
quietly let the level-2 pair be filled with level-4 spells. Psionic powers stay
batched: no book states which level a given power had to be learned at.

The cap is **enforced, not advised** — an out-of-cap spell is not in the list at
all. A spell's level is a mechanical rule like a psychic tier, not a table
judgement like a skill category, and the app already draws that line.

"starting at level 2" needs no key: a per-level grant is earned for every level
above the first, which is levels 2 upward by definition.

`extraction-prompt.js` names all four keys, because
[a field the prompt does not mention is a field that never arrives](known-limitations.md#known-limitations-and-refactor-candidates) —
`variants` shipped as schema the prompt was never told about and the first class
with age stages came back with both stat blocks dropped.

### The live level-up grants them too

The sheet's level-up panel offers the spells and powers the crossed levels earn,
one select per slot, grouped by the level that granted it — because for spells
the levels a slot may draw from belong to *that* grant. Crossing two levels at
once caps each pair separately.

Unspent slots **bank into `pending_power_picks`**, the same as skill picks, for
the same reason: levelling up is never blocked on choosing, so a grant nobody
spent has to go somewhere or the spells that level earned vanish silently.

The cap is enforced **server-side**, not only in the picker. `resolvePowerPicks`
checks every pick against the grant it claims — that such a grant exists, that
it has room, that the power is not already known, that it is in the catalog, and
that a spell's level is inside that grant's cap. A rejected pick fails the whole
level-up with a sentence saying which and why, rather than being dropped.

One trap worth recording: `loadCharacter` does not join `campaigns`, so the
system filter on the catalog lookup read `character.campaign_system` and got
`undefined` — a silent no-op that would have let a Rifts caster learn a
Palladium-only spell. The system is fetched explicitly now.

---
