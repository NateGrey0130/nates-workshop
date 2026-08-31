# Class frontmatter reference

Every top-level key the app reads. Anything else parses and is then ignored by
everything — `class-check` reports it as `UNMODELLED`.

The parser is a small hand-written YAML subset, not a full YAML implementation.
Inline maps and lists (`{ a: 1 }`, `[1, 2]`) work; anchors, multi-line scalars
(`|`, `>`) and tags do not.

## Required

```yaml
id: mystic                        # kebab-case slug, unique, never changes
name: Mystic
system: rifts                     # rifts | palladium-fantasy
source_book: Rifts Ultimate Edition p.118-120
category: occ                     # occ | rcc
```

## Attributes and pools

An O.C.C. has attribute **minimums**; an R.C.C. **rolls** its attributes.

```yaml
attribute_requirements: { IQ: 9, ME: 9, MA: 9 }   # occ — enforced at creation
attribute_dice:                                    # rcc — rolled at creation
  IQ: "3d6"
  PS: "4d6+30"
```

Pools take a number or a dice expression, and a dice expression is rolled once
and stored — it cannot be re-rolled per render.

```yaml
hit_points_base: "P.E. + 1d6 per level"   # occ
sdc_base: 20
mdc_base: "1d4x100"                        # M.D.C. beings use this instead
ppe_base: "1d6x10+20, +2d6 per additional level starting at level two"
starting_money: "2d4x1000"                 # coin only, never gear
```

## Grouping and levelling — the two keys nothing warns you about

Both are optional to the parser and **required by `regression.mjs`**. A class
missing either one parses clean, passes `class-check`, passes the smoke suite,
and fails the regression run — so read this section rather than discovering it.

```yaml
occ_group: men-of-arms            # occ ONLY — one of five, listed below
xp_table: [0, 2100, 4200, ... ]   # palladium-fantasy occ ONLY — 15 entries
```

### `occ_group` — every O.C.C., not just the Palladium ones

It is the token a race's `occ_restrictions` matches with `group:<name>`, which
is what makes it load-bearing rather than decorative. The check is
`every O.C.C. carries the group its book section gives it`, asserted as an
invariant rather than a count, deliberately: it used to compare against a
hardcoded 25 and passed happily for months while all 34 Rifts O.C.C.s carried
no group at all — so a `group:` token matched nothing on the Rifts side, and a race written with one
would have failed CLOSED as an `only` or, far worse, OPEN as an `except`.

Two more rules the same block enforces: the value must be one of the five above,
and **a group belongs on an O.C.C. and a restriction on a race, never the other
way round.**

### `xp_table` — every Palladium Fantasy O.C.C., and NO race ever

The check is `every Palladium O.C.C. has its own experience table`, and it
applies when `system: palladium-fantasy` and `category: occ`. Fifteen integers,
the **lower bound** of each band, starting at 0 and strictly rising — that is
what `levelForXp` compares against. A Rifts O.C.C. does not need one.

**A race must never carry one.** Experience comes from what you do, and
Palladium names its charts by occupation — "Knight & Noble", "Thief &
Merchant". Composition is race-primary since #210 and falls an absent key
through to the occupation, so a race that carries its own table **wins over the
occupation's and silently drops it**, levelling the character on the house-rule
default. That is the invariant `and no R.C.C. carries one` exists to hold, and
it is what cost a rebuild during the Wormwood import.

Where a book prints an experience ladder for a *race*, record it in
`extraction_notes` — not in `xp_table`.

Two more the same block enforces: the pairs a book prints together must stay
together (`knight`/`noble`, `thief`/`merchant`, `mind-mage`/`wizard`,
`priest-of-light`/`priest-of-darkness` — two classes drifting apart means a
transcription went wrong), and the **Warlock is the standing exception**: its
row is the Rifts printing, so its Palladium figures go in its delta section and
its `xp_table` stays undefined.

### What each tool actually catches

Verified by running them, because the failure message is not the rule:

| you write | `class-check` | `regression.mjs` |
|---|---|---|
| `occ_group: warriors` | **ERROR**, and names all five legal values | — |
| an O.C.C. with no `occ_group` | `PARSE ok` — **silent** | fails |
| an R.C.C. carrying `xp_table` | `PARSE ok` — **silent** | fails |

So the *value* is checked at parse time and the *presence* is not. The two that
cost time during Wormwood are both in the silent row, and neither the smoke
suite nor `class-check` will tell you. **Run `regression.mjs` on any PR that
adds a class.**

## Skills

```yaml
skills:
  occ_skills:                     # everyone of this class gets these
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "+15%" }
    - { choose: 3, categories: ["Communications"], bonus: 15, note: "..." }
    - { choose: 2, from: ["Pilot: Hovercycle", "Pilot: Truck"], base: 45, per_level: 5 }
  occ_related_skills:             # picked at creation from these categories
    count: 6
    categories:
      - "Physical"
      - { name: "Medical", except: ["M.D. in Cybernetics"], bonus: 10 }
      - { name: "Espionage", only: ["Escape Artist"] }
      - { name: "Technical", bonus: 10 }   # "Technical: Any (+10%)"
    schedule: [{ level: 3, count: 1 }]     # extra picks at later levels
    minimums:                              # a FLOOR per category, out of `count`
      - { count: 2, category: "Espionage" }
      - { count: 3, categories: ["Physical", "Rogue"] }   # a union: three across the two
  secondary_skills:
    count: 4                      # any category, base % only, no per-level gain
    schedule: [{ level: 4, count: 1 }]
```

- `base` is the catalog base **plus** the class's printed bonus, already added.
- `base` and `bonus` are mutually exclusive on a choice-group. `bonus` adds to
  each pick's own base — use it when the group spans a category.
- `note` is free text, shown to the player, never enforced.
- `only` / `except` names must match catalog rows **exactly**. An unmatched
  name does nothing, silently. `class-check` reports these.
- An `only` entry matches **by name whatever category the catalog files the
  skill under**, provided the class also lists that real category — "Espionage:
  Wilderness Survival only" is an ordinary book line about a Wilderness skill.
  Without that second half it is `unreachable`: granted, but nobody can take it.
- An `except` naming a skill from another category excludes **nothing**. There
  was nothing offered in that category to exclude.
- **A category `bonus` is the percentage printed beside it** — "Technical: Any
  (+10%)". Transcribe it; do not fold it into anything else. It applies to
  RELATED picks only, which is the books' rule and not a simplification, so the
  same key on `secondary_skills.categories` is a parse error. It combines with
  `only`/`except`, and a skill with no percentage of its own (a W.P., a hand to
  hand) stays at zero. Books print these constantly and every class imported
  before the key existed dropped them: the Godling lost five.
- **`minimums` is the only FLOOR in this block; everything else is a ceiling.**
  "Select 8 other skills, but at least two must be selected from espionage and
  two from rogue skills" is a floor, and eight classes across four books print
  one. The picks come out of the same `count` - two floors of two over eight
  leave four free - so the sum of the floors may not exceed it, and every
  category named must be one the class grants. An entry holds a LIST because the
  City Rat's floor is a union, "at least three from Physical or Rogue", which as
  two separate floors would demand six picks the book never asks for; `category:`
  is the one-element spelling. The picker shows a running total per floor and the
  server refuses a build that can no longer reach one - but only when it can NO
  LONGER reach it, since a floor merely unmet is a player with picks left.
- See `catalog.md` for the naming rules these names have to match.
- **Related and secondary skills come from the O.C.C.** An R.C.C. with neither
  is correct.

## Equipment

```yaml
equipment_starting:
  - { item_id: "back-pack", qty: 1 }        # slug from the gear catalog
  - { item_id: "wooden-arrows", qty: "2d6" } # fixed entries may roll
  - { choose: 1, label: "energy pistol", qty: 1,
      from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
```

Every slug — including every option inside a `from` — needs a gear row. A
choice's `qty` must be a plain number: it is re-derived each render, so a dice
value there would re-roll on every repaint.

## Powers

```yaml
psionics:
  type: "major"                   # minor | major | master
  isp_base: "1d4x10+10"
  powers: ["Clairvoyance", "Sixth Sense"]    # granted by name
  powers_starting: 5              # how many the player picks
  categories_allowed: ["Sensitive", "Healing"]

magic:
  type: "spell"
  spells_starting: 8
  spell_levels_allowed: [1, 2]
  spells: ["Globe of Daylight"]   # granted by name
```

Named powers and spells need catalog rows; `class-check` lists the missing ones.

**`supersedes_race: true` says the character stops being what it was**
(BOOK-INGEST-AUDIT.md F11). Composition is race-primary by default - a dragon
that studies an O.C.C. is still a dragon - and this flag inverts it for the
handful of entries whose book describes a transformation. The Cosmo-Knight is
the only class in the catalog that carries it:

- pools (`hit_points_base`, `sdc_base`, `mdc_base`, `ppe_base`),
  `starting_money` and `xp_table` become the OCCUPATION's;
- `occ_skills` REPLACE the race's rather than unioning - *"the skills of his
  past life are lost and the character is reborn"*;
- `attribute_dice` are compared PER ATTRIBUTE and the higher kept, because that
  is the one thing the Cosmo-Knight's page carves out: *"use these die rolls, or
  the attributes of the character's original race, whichever are HIGHER"*.

**Do not reach for it because a class prints its own dice.** Almost every O.C.C.
does, and the race is meant to win. The test is whether the book says the
character ceases to be its race.

**A race and an occupation that BOTH state psionics are MERGED, not chosen
between** (BOOK-INGEST-AUDIT.md F10). A race says what a member of that race is
born with and an occupation says what training adds, so `powers` and
`categories_allowed` are unioned, `powers_starting` and `powers_per_level` take
the higher of the two, and `powers_schedule` / `powers_starting_groups` take the
occupation's when it states one - running both ladders would fire both sets of
grants at every threshold. The tier is the stronger of the two and `isp_base`
travels with it, a tie going to the occupation.

This matters when transcribing a RACE that its own book pairs with an O.C.C.:
write what the race page grants and nothing more, because the occupation's page
is imported separately and the two now add up. `magic` is still CHOSEN - the
occupation wins outright when both state it - which is a different question and
is filed separately.

## Bonuses — the numbers the sheet adds up

Applied **unconditionally**. A conditional bonus belongs in prose.

```yaml
bonuses:
  attributes: { PS: 2 }           # IQ ME MA PS PP PE PB Spd
  combat: { attacks: 1, strike: 2, parry: 1, dodge: 1, initiative: 1 }
  saves: { spell_magic: 2, psionics: 1, horror_factor: 4 }
  pools: { mdc: 20 }              # hp sdc mdc ppe isp
  at_level:
    - { level: 5, combat: { attacks: 1 } }
```

An unrecognised group is a warning, not an error, so a typo here does nothing
loudly. `at_level` entries start at level 2 — level 1 belongs in `bonuses`
itself. `pools` inside `at_level` is **not** applied.

## Abilities

```yaml
special_abilities:
  - name: "Shape Shifter"
    description: "..."
    repeatable: true              # may be taken more than once
    on_repeat: "..."              # what a second take gives
    bonuses: { attributes: { PS: 2 } }   # validated exactly like class bonuses
  - { choose: 2, from: ["Shape Shifter", "Super-Tough"] }   # a choice group

natural_abilities:                # rcc — display only
  - { name: "Nightvision", description: "90 feet" }
```

An option named in a `choose` but never defined is a warning: it can be picked
and grants nothing.

## Prose and display

```yaml
level_progression:                # display-only wording; numbers go in bonuses
  - { level: 2, grants: ["+1 attack per melee"] }
restrictions: ["No cybernetics"]  # things the class may not do
side_effects: "..."               # drawback mechanics, display only
extraction_notes: "..."           # anything unresolved, for a human to chase
```

## Variants — one creature, several stages

```yaml
variants:
  - id: hatchling
    name: "Chiang-Ku Hatchling"
  - id: adult
    name: "Adult Chiang-Ku"
    attribute_dice: { PS: "4d6+30" }
    mdc_base: "1d6x1000"
    bonuses: { combat: { attacks: 3 } }
```

A variant may override only `attribute_dice`, `attribute_requirements`, the pool
bases and `bonuses`. Skills, abilities and lore stay shared — an override naming
anything else is reported and ignored.

## What a skill itself grants

Not frontmatter — it lives on the catalog row, in `skills.bonuses`, in this
same `bonuses:` shape. Boxing is "+1 attack per melee, +2 parry & dodge, +1
roll, +2 P.S." and the class file says nothing about it.

So **do not fold a skill's bonus into the class's `bonuses:` block.** The app
adds both, and writing it in the class as well double-counts it. See
`catalog.md`.

## Body

```markdown
## Lore

Shown to the player when they pick the class.

## GM Notes

Hidden from players.
```

`## Lore` missing is a warning. Any other `##` heading is kept in
`data.sections` and shown on the class detail.
