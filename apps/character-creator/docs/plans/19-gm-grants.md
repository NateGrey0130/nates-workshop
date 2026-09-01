# Plan 19 — G.M. grants

Written 2026-09-01, before any of it was built. A specification, in the shape of
plans 13–16, not a record of something that shipped.

Part of the [character creator](../../README.md) documentation.

---

## The problem

A character acquires things no class schedule granted. A patron teaches a skill,
an artefact confers a psionic power, a god hands out a spell, a cyber-implant
adds S.D.C., a session of hard training buys a point of P.S. The G.M. says so at
the table, out loud, and there is nowhere for it to go.

Today the app has exactly one route for this — `gm_abilities`, which puts a
named power into `characters.abilities` — and it covers one of the eight things
a table actually hands out.

## What was decided before the plan was written

1. **Scope is everything**: skills, spells, psionic powers, abilities, the
   attributes, the pool maxima, and the combat and save bonuses.
2. **Both shapes**: a named grant ("you gain Boxing") and a choice ("pick one
   Physical skill").
3. **Permanent until removed.** No expiry, no suspend, no durations.
4. **The player enters it on their own sheet.** The G.M. usually says it
   verbally; the player types it in.

Three more were settled while this plan was in review; they are recorded at
the end, under [Settled in review](#settled-in-review).

Decision 4 is the one that shapes everything else. This cannot be a G.M.-only
feature, so **integrity comes from the record rather than from a permission
wall**: every grant stores who added it, when, and why, and is labelled as a
grant everywhere it appears. A grant that renders indistinguishably from a class
skill is a failure of this feature even if every number is right.

`requireCharacter` — owner **or** campaign G.M. — is therefore the correct
guard, and it is already what `gm_abilities` uses.

## The doctrine already exists, and it is not mine

The single most useful thing found while planning this: the validator has
already settled what a grant *is*, and it settled it the same way this plan
would have.

`_lib/validate-character.js`, in the chosen-abilities block:

> A `{ name, gm: true }` entry is a ruling, not a pick […] so it is exempt from
> the count and never checked against the offered list, the same reasoning that
> makes an `override: true` skill legal by definition.

And in the same breath it declines to extend the exemption to everything:
repeats count G.M. and player copies together, because "holding a power twice is
holding it twice, whoever granted the second."

**A grant is a ruling. A ruling is exempt from limits on what a player may
CHOOSE, and subject to everything mechanically true regardless of who decided
it.** Every decision below is that sentence applied to one more kind, and where
this plan looks inconsistent, that rule is what it is being consistent with.

## The shape

One table, `character_grants`, one row per grant, eight kinds.

```sql
CREATE TABLE IF NOT EXISTS character_grants (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN
    ('skill', 'spell', 'psionic', 'ability', 'attribute', 'pool', 'combat', 'save')),
  name TEXT NOT NULL,          -- catalog name, or the key: 'PS', 'sdc_max', 'attacks'
  value INTEGER,               -- the delta, for the four numeric kinds; NULL otherwise
  detail TEXT,                 -- JSON: the catalog snapshot, or a choice's terms
  reason TEXT NOT NULL,        -- why the table gave it. REQUIRED, see below
  granted_by TEXT NOT NULL,    -- Access identity of whoever typed it in
  granted_at_level INTEGER,    -- what level the character was when it landed
  claimed_at TEXT,             -- for a CHOICE: NULL until the player spends it
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

**`reason` is NOT NULL with no default.** Under decision 4 the person typing the
grant is usually its beneficiary, so the reason is the only thing standing
between a record and an unfalsifiable claim. A grant nobody can explain is one
the G.M. can see and question at a glance. This is the load-bearing column of
the whole design and it should be the last one anyone makes optional.

**Removal is a hard `DELETE`, by owner or G.M., and it is logged.** A grant is
current state, not a ledger. History belongs to `play_events`, which already
exists for exactly this and describes itself as commentary rather than a ledger
— see the constraint on it below.

The guard is `requireCharacter`, the same one that let the grant be added. Making
removal G.M.-only was considered and rejected: adding is already open under
decision 4, so a G.M.-only retraction would protect the record from everyone
except the person most likely to want it gone, while turning every typo into a
message to the G.M. The trail is what carries the weight instead — **a removal
writes a `play_event` exactly as an add does**, so a grant that appeared and
vanished between sessions is still legible after the row is gone.

`campaign_items`' soft delete was the obvious model and is rejected: an item
that left the party is an object that still exists somewhere, whereas a removed
grant is a ruling that was withdrawn. Keeping withdrawn rulings in the table
that decides current effects means every read has to filter, and the first read
that forgets to is a bonus that came back from the dead.

### The choice half lives here too, and not in `pending_skill_picks`

A choice is a row with `claimed_at` NULL and its terms in `detail` — a count and
an optional category restriction. Spending it POSTs against **that grant's id**
and resolves into a named grant of the same kind.

Adding a `source` column to `pending_skill_picks` / `pending_power_picks` was
the obvious alternative and is **rejected**. Those tables feed
`characters/[id]/picks.js`, which spends grants oldest-first *across* grants and
then re-validates the merged skill list against the class's related and
secondary allowances. A G.M.-granted choice entering that pool would either trip
the allowance ceiling or force the allowance arithmetic to learn a third source
— and that arithmetic is the code most likely to break something that currently
works. Keying a spend to one grant id costs a second small endpoint and touches
none of it.

The cost is real and accepted: the sheet grows a second "you have something
unspent" badge rather than folding into the existing one. Both should be visible
in the same place on the sheet even though they are different mechanisms.

## The five problems, settled

### 1. `gm_abilities` folds in, and the migration is a no-op

The existing branch in `characters/[id].js` and the three functions driving it
in `sheet.js` are replaced by `kind: 'ability'` rows.

**Production holds zero `{name, gm:true}` entries** — one character, no
abilities at all, asked of `--remote` on 2026-09-01. So there is no data to
migrate, only code to remove. Re-ask before doing it rather than trusting this
line; it is a measurement with a date, not a property of the system.

The catch is that the validator's ability check reads `abilities` off the
character row, so moving the storage without moving what the validator sees
would silently drop the exemption quoted above and make every granted power a
`ability_count` violation.

**Compose in `loadCharacter()`.** `_lib/character-json.js` is the one function
that loads a character and decodes its JSON columns; folding `ability` grants
into the `abilities` array there means every caller — the four validator call
sites included — gets the composite without knowing about it. The JSON column
keeps player picks only.

This is the same move `effective()` makes for attributes, and it should be
described that way in the code: **one funnel, so nothing reads a raw column for
a derived value.** The slice that does this must prove all four validator call
sites go through the funnel, or say plainly which does not and why.

### 2. Attributes ride the bonus layer; pools do not, and the clamp is why

`js/derive.js` deliberately keeps class bonuses **out** of the stored attribute
so that a character's P.S. stays the number that was rolled, and everything
derived reads through `effective(attrs, bonuses)`. A granted +2 P.S. is a fourth
contributor to that block. **Never mutate `characters.attributes`** — that
column is a record of a roll, and writing a grant into it destroys the
provenance the file was built to preserve.

Combat and save grants ride the same layer, into the `combat` and `saves` groups
`classBonuses` already produces. This means the `combat` and `saves` JSON
sections stay what they are today — what a human typed — and a grant never
becomes indistinguishable from a manual edit.

**Fold inside `classBonuses(cls, level, rolled, granted)`, as a fourth
argument.** `sheet.js` builds a bonuses block in three places (around lines 702,
999 and 1008 as of this writing) and merging at each of them is three chances to
drift. An explicit argument also keeps the one call that must NOT see grants
honest: the block at ~1008 is built from `class_bonuses` precisely so the sheet
can say where a bonus came from, and it passes nothing.

**Pools are the exception, and the reason is mechanical.**
`characters/[id].js`'s PATCH clamps every `*_current` against the stored
`*_max`. So a granted +20 S.D.C. that is derived on read rather than written to
the column leaves the player unable to fill it — the clamp reads the un-granted
number and silently caps them. A pool grant therefore writes the column and its
row in one batch, and the row is provenance for a number that lives elsewhere.

Two consequences to implement, not to discover:

- **Removing a pool grant must clamp `*_current` too.** The PATCH clamps on
  write, not on read, so lowering a max on its own leaves a character sitting
  above it.
- The stored delta is what removal reverses. If the max is changed by another
  route in between, the arithmetic no longer reconciles. Accepted — the
  alternative is making pools derived, which the clamp forbids.

### 3. Skills need no validator change at all

The validator counts `type === 'related'` and `type === 'secondary'` against the
class allowances, and applies category restrictions to related skills only.
`occ` is counted by neither.

A granted skill is stored in `characters.skills` with **`type: 'gm'`**, and
every one of those checks therefore ignores it without a line being written.
This is the slice that turned out smaller than expected. Verify it rather than
believing this paragraph — it rests on there being no other reader that keys on
the three type strings.

Level-up needs nothing either: `js/leveling.js` advances every skill carrying a
`pct` and a `per_level` regardless of type, so a granted skill improves on
level-up on its own. **This is wanted**, and is recorded here so it reads as a
decision rather than as an accident somebody later "fixes".

### 4. Spells and psionics DO need an exemption, and it is one line

Unlike skills, the creation-time powers block filters on
`p.type === 'spell' || p.type === 'psionic'` and then exempts only the names the
class grants outright. A granted spell would be counted as *chosen* and trip
`power_count`, and could trip `power_level_cap`, `power_category` or
`power_not_on_list` as well.

That check runs only when the caller supplies `powers` — the create endpoint and
`admin/audit.js`. So the failure is not at grant time: **the character saves
fine and then appears in the admin audit as broken**, which is the worst
available shape for a bug.

A granted power carries a flag and joins the `auto` exemption immediately beside
it, whose comment already gives the reason in the right words: granted, not
chosen.

**`duplicate_power` is deliberately NOT exempted.** A power is learned once
whoever granted it, exactly as repeats are counted across player and G.M.
abilities today. Granting a power the character already holds should be refused
at grant time, with a message that says so.

### 5. A fourth skill type is invisible until both render sites know it

`sheet.js` hardcodes `['occ', 'related', 'secondary']` twice — once for the play
lens and once for the sheet lens. A skill stored as `type: 'gm'` is written,
saved, advanced and **never drawn**. There is also a level-up diff row that
prints `s.type` raw, which would show a bare `(gm)`.

Both sites gain a fourth group. The label should say what these are — *Granted*
— rather than naming the mechanism.

**Nothing here is finished until it has been driven in a browser and
screenshotted, and until a print render has been read back.** The sheet's
printed form is a real output of this app and a fourth column has somewhere to
go wrong in it.

## Grants are `play_events`, and they must carry no `changes`

`play_events` is the who-did-what trail and already describes itself as
commentary rather than a ledger. Adding and removing a grant belongs there.

One constraint, from reading `events/undo`: it reverses the latest not-undone
event **that carries changes**, by writing the stored from/to values back
through the character. It knows nothing about `character_grants`. So a grant
event must be a pure record, like a roll — carrying a note and no `changes` —
or "undo" will half-reverse a grant, restoring a number while leaving the row
that justifies it in place.

## Where the table lands

A column costs five places and a table costs nine — see the `schema-change`
skill. For this table:

| # | Where | What |
|---|---|---|
| 1 | `db/migrations/043-character-grants.sql` | the `CREATE`, ending by recording itself |
| 2 | `db/schema.sql` | the same `CREATE`, inline |
| 3 | `db/schema.sql` seeding block | a row for 043, **guarded** on the table existing |
| 4 | `docs/operations.md` | one row in the migration table |
| 5 | `README.md` data model | a row in the character-data table |
| 9 | `README.md` table count | *Thirty-two* becomes thirty-three, and the smoke test fails until it does |

Steps 6, 7 and 8 do not apply: this is not a catalog, the wizard does not need
it at boot, and it adds no JSON column to `characters`.

Two more places that are not on that list and are easy to miss:

- **The DELETE handler's comment** in `characters/[id].js` lists everything that
  goes with a deleted character. A cascade nobody documented is a cascade
  somebody will be surprised by.
- **The README's API-surface table** needs a row per new route.

## Slices

One PR each. Merge on a separate word.

| # | Slice | Provable by |
|---|---|---|
| 0 | This plan | — |
| 1 | **Skills, end to end**: migration 043, the table, add and remove, the sheet control, both render sites, print | `regression.mjs`, browser, print render |
| 2 | Spells, psionics and abilities along the same path — plus the powers exemption and retiring `gm_abilities` | browser |
| 3 | The stat half: attributes, combat and saves through `classBonuses`; pools through the column and the clamp; the minimums warning | browser |
| 4 | The choice half: an unspent grant, and spending it | browser |
| 5 | Docs — `known-limitations.md`, `wizard-and-sheet.md`, plans README | `smoke.mjs` |

Slice 1 applies its migration to production **before** the merge that needs it,
per the ordering rule.

**Slice 1 is one kind carried all the way through rather than the whole schema
with no interface**, which is what an earlier draft of this table proposed and
what this repo usually does. The reason for the change is in problem 5: the way
this feature fails is silently, by storing a row correctly and never drawing it,
and a schema-first slice defers every render and print question to last. One
kind end to end proves the whole path — table, endpoint, control, both lenses,
the printed sheet — and every later slice then adds kinds to a path already
known to work.

Skills are the right kind to be first: they are the only one of the eight that
needs **no** validator change, so slice 1 carries the render risk without also
carrying the rules risk.

`house-rules.md` is deliberately off the docs list. It was on it in the first
draft on the assumption that it constrained what a G.M. may do; it mentions the
G.M. nowhere at all.

## What this deliberately does not do

- **No G.M. review view.** Decision 4 puts the entry point on the player's own
  sheet, and nothing was asked for that lets a G.M. see what the table has
  written down across a party. This is the most likely follow-up and the pieces
  are already there — `campaignAccess` knows who the G.M. is, and the campaign
  page has four tabs to be a fifth beside. Left out on purpose rather than
  overlooked.
- **No expiry and no suspend**, per decision 3.
- **No enforcement.** A grant that breaks a class rule is stored anyway; the app
  says so and moves on. Log and label, do not block.
- **No new permission tier.** Owner-or-G.M., as everywhere else.

## Settled in review

Three questions the first draft left open, answered 2026-09-01. Two of them
went against what this plan recommended, and the reasoning is recorded here
rather than quietly rewritten above.

### A granted attribute WARNS at a class minimum. It does not satisfy it

The validator checks `attribute_requirements` against the stored `attributes`,
not against `effective()`. So a character granted the two points of I.Q. that
would qualify them for their own class still fails the minimum.

Neither available answer was right. Reading the rolled value only is the status
quo and makes a real table ruling — *train up and you can take it* —
unrepresentable. Reading the effective value lets someone save an illegal
character and then grant their way legal, which stops the validator being a
boundary on the one thing it was written to bound.

**So the gap is reported rather than judged.** Where the stored value is below
the minimum and a grant closes the gap, `attribute_minimum` becomes a WARNING
naming the grant it rests on, instead of a violation. Where nothing closes it,
the violation stands exactly as today. The character saves either way, the audit
says what the qualification rests on, and no rule is decided by the app.

This is the same posture as `xp_below_level` and the choice-group checks, which
is the argument for it: it is a third state, but not a new IDEA, and it is the
one this file already reaches for when a number is legitimate and surprising.

Two implementation constraints, neither optional:

- **The granted total is a new optional argument to `validateCharacter`.** With
  it absent the function must behave exactly as it does today, because three of
  its four call sites will not have grants in hand on the day this lands.
- **Class bonuses are NOT folded in here.** A class's own +2 P.S. has never
  counted toward its own minimum, and quietly changing that would flip existing
  violations to warnings across characters nobody touched. Only grants soften a
  minimum, and only to a warning.

### Removal is owner-or-G.M., and logged

Recorded under [the shape](#the-shape), with the rejected alternative.

### Slice 1 is one kind end to end, not the whole schema

Recorded under [slices](#slices). This reverses what the first draft proposed.
