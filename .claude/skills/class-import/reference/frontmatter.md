# Class frontmatter reference

The blocks worth explaining, with what reads each one. **This is not a complete
key list and must not be read as one** — the contract is `js/parser.js`,
`js/derive.js` and, for anything about levels, spells or psionic powers,
`js/leveling.js`. A key absent from this file may be fully modelled.

That distinction has cost mechanics twice. Both Phase World noro O.C.C.s shipped
without the mind-control save their book prints; two batches later the same
classes turned out to carry a psionic schedule that denied the psychic its Super
power at every level, stopped at level 3 where the book says *"third level and
beyond"*, and let the mystic warrior take eight Super powers where the book
grants two (`fix-noro-mind-control-saves.sql` #410,
`fix-noro-psionic-schedules.sql` #411). Each was preceded by an
`extraction_notes` line asserting the app could not express it. Nothing failed:
they parsed, validated, composed and passed 210 regression checks.

So `class-import`'s unmodelled-keys rule applies in **both** directions: grep
`js/` and `functions/` before writing either *"the app cannot express this"* or
*"this key does nothing"*. Believing a key is unmodelled costs a working field;
believing a key does not exist costs a mechanic, silently.

A key nothing downstream reads parses and is then ignored — `class-check`
reports it as `UNMODELLED`, from a hand-maintained list that has itself been
wrong twice.

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
  two from rogue skills" is a floor, and classes across several books print
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

### The two blocks are symmetric, and the ladder keys are not above

The nine keys above are the ones a simple class needs. **A class that gains
spells or powers as it levels needs more**, and `js/leveling.js` is where they
are read. `STARTING_SPEC` there pairs the two blocks name for name:

| psionics | magic | what it is |
|---|---|---|
| `powers_starting` | `spells_starting` | the TOTAL picked at creation |
| `powers_starting_groups` | `spells_starting_groups` | that total split across restrictions |
| `powers_from` | `spells_from` | a named list that REPLACES the gate |
| `categories_allowed` | `spell_levels_allowed` | the class-wide gate |
| `powers` | `spells` | granted outright, by name |
| `powers_per_level` | `spells_per_level` | a flat number gained each level |
| `powers_schedule` | `spells_schedule` | per-level grants, when a flat number will not do |

Magic has two more that psionics has no equivalent for: **`spell_lists`**, a map
of named lists a schedule entry draws from, and **`spells_per_level_levels`,**
the cap on which spell levels a per-level grant may pick from —
`up_to_character_level` is the Ley Line Walker's *"two more per level, never
above your own level"*. **`spells_per_level_from`** is the single list form of
`spell_lists`.

That is nine psionics keys and eleven magic keys in the live catalog as of
2026-09-02; `mergePsionics` and `mergeMagic` in `parser.js` both say so in
their own comments, and both spread unknown keys through rather than
enumerating, so the count moves without anything failing.

**A schedule entry carries its own restriction, and it OVERRIDES rather than
narrows:**

```yaml
magic:
  spells_schedule:
    - { level: 2, count: 4, spell_levels: [1, 2, 3] }
    - { level: 3, count: 2, from_list: "A", note: "Any Summoning spell." }
```

- entries are matched by `level` **and slot** — several may share a level, and
  each carries its own cap;
- `spell_levels` / `categories` on an entry replace the class-wide gate, because
  a book naming Super for one slot is granting an exception rather than
  narrowing;
- `from` (inline list) or `from_list` (`true` for `spells_per_level_from`, or a
  string naming an entry in `spell_lists`) is the tightest restriction there is
  and replaces the level cap outright;
- `note` is shown to the player at the pick. It is the home for a rule the
  catalog **cannot** enforce — spells carry no category, only a name, level and
  cost, so *"non-dimension related or control based"* has nothing to filter on.
  State it and let the player honour it rather than dropping it or guessing.

Creation is not a level-up: `perLevelGrants` skips every entry at or below the
level asked from, and creation asks from level 1, so a **level-1 schedule entry
does not fire.** A starting pick's restriction goes in `*_starting_groups`.

`psionics.categories_allowed` takes the **same grammar as a skill category**
(BOOK-INGEST-AUDIT.md F16): a plain string, or an object narrowing itself with
`only` / `except`.

```yaml
psionics:
  categories_allowed:
    - { name: "Sensitive", except: ["Object Read (Psychometry)"] }
    - "Physical"
```

Use it when a book allows a category *"excluding..."*. `powers_from` is the
other tool and it is not the same one: a named list REPLACES the category gate
rather than narrowing it, so it means enumerating everything that remains and
re-enumerating whenever the catalog grows.

**The names inside `only` / `except` must match catalog rows exactly**, and an
unmatched one narrows NOTHING, silently. The Crazy's book says *Object Read*;
the row is `Object Read (Psychometry)`. A regression invariant checks every one.

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

`magic` merges the same way (F14), with one difference: `psionics.type` is a
ladder and `magic.type` is not - `spell`, `elemental`, `druid` and `intuitive`
are KINDS, so the occupation's wins outright where it states one. `spells` and
`spell_levels_allowed` are unioned; `spells_starting` takes the higher.

This matters when transcribing a RACE that its own book pairs with an O.C.C.:
write what the race page grants and nothing more, because the occupation's page
is imported separately and the two now add up.

## Bonuses — the numbers the sheet adds up

Applied **unconditionally**. A conditional bonus belongs in prose.

```yaml
bonuses:
  attributes: { PS: 2 }           # IQ ME MA PS PP PE PB Spd
  combat: { attacks: 1, strike: 2, parry: 1, dodge: 1, initiative: 1 }
  saves: { spell_magic: 2, psionics: 1, horror_factor: 4 }
  pools: { mdc: 20 }              # hp sdc mdc ppe isp
  attribute_minimums: { PS: 16 }  # a floor, not a bonus
  at_level:
    - { level: 5, combat: { attacks: 1 } }
```

An unrecognised **group** is a warning, not an error, so a typo there does
nothing loudly. `at_level` entries start at level 2 — level 1 belongs in
`bonuses` itself. `pools` inside `at_level` is **not** applied.

### `combat` and `saves` accept any key. The SHEET does not

This is the trap, and it is the opposite way round from what the openness
suggests. `validateBonuses` checks the group names and not the keys inside them,
and `addBonus` in `derive.js` adds any finite number under any key — so a
misspelled or invented key **parses, validates, composes and renders nowhere.**

The sheet draws two literal lists: `SAVE_FIELDS`, sixteen rows, and
`COMBAT_FIELDS`, nineteen. A key outside them is stored and invisible. The
vacuum-wasp's own notes put it exactly right — *"`combat: { dogfighting: 2 }`
would parse, validate and render NOWHERE"* — and `sheet.js` records that the two
copies have already drifted once, when three keys were added to `derive.js` and
only one list was updated.

**Read the lists in `sheet.js` before inventing a key.** They are longer than
the examples above: sixteen saves including `ritual_magic`, `mind_control`,
`possession`, `illusionary_magic`, `toxins_poisons`, `harmful_drugs`,
`coma_death_pct` (a percentage, not a d20 bonus, and the `_pct` suffix is what
makes it one), `disease`, `curses`, `faerie_magic`, `insanity`, `pain` and
`fatigue`; and nineteen combat rows including `perception`, `pull_punch`,
`roll`, `disarm`, `entangle`, `body_flip`, `automatic_dodge`, `damage_bonus`
and `run_yards_per_melee`.

**For a save the sixteen do not name, use `saves.other`** —
`BOOK-INGEST-AUDIT.md` F7, filed for the Spacer's *"+2 to any saves against
explosive decompression"*. It is a list of `{ label, bonus }` shown read-only
after the sixteen, because these have no attribute chart and nothing to
override:

```yaml
  saves:
    horror_factor: 2
    other: [ { label: "vs explosive decompression", bonus: 2 } ]
```

There is no `combat.other`. A combat bonus the nineteen do not name goes in a
`special_abilities` entry, which is what the vacuum-wasp did with its
dogfighting line.

**`attacks_base` is the one combat key that is not a bonus.** It STATES a
starting number of attacks rather than adding to one, is taken as the higher
when a race and an occupation both give it, and is stripped before the combat
map reaches the sheet — so it is correctly absent from `COMBAT_FIELDS`.

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

## Trackable resources — what a player spends during play

```yaml
trackable_resources:              # optional; omit entirely if the class has none
  - key: uppers                   # stable slug, unique within the class
    label: "Juicer Uppers"        # what the sheet calls it
    max: 3                        # a fixed number, OR
    max_formula: "PE"             # an attribute expression, same grammar as pools
    reset_on: day                 # day | session | never — when it comes back
    note: "+1 attack, +2 initiative, 4 minutes"   # display only
```

A countable thing the class hands out that is not a pool, not a skill and not a
power — doses, charges, uses per day. The sheet draws one box per class that
declares any, and nothing at all for a class that does not.

**Omitted and empty are different.** No key means nobody has looked at this
class yet. `trackable_resources: []` means someone read the book and it has
none. Both render nothing; only the second one says so.

**Every value comes from the book, like every other number here.** This key is
tempting to fill from memory because the mechanics are famous — Juicer uppers
are the stock example and appear in NO imported Juicer's text. Twelve Juicer
classes are imported and `uppers` is in none of them. If the book does not say
it, it does not go here; `extraction_notes` is where an unresolved one goes.

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
