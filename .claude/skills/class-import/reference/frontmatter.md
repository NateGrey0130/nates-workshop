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
