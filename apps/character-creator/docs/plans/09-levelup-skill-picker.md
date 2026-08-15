# PR 9 — Level-up skill picker

> **Delivered** in [#25](https://github.com/NateGrey0130/nates-workshop/pull/25). This file is the record of why, not a to-do.

The biggest gap between what the data says and what the app does.

## Problem

`occ_related_skills.schedule` records that a class grants extra skill picks at
levels 3, 6, 9, and 12. `functions/api/character-creator/_lib/leveling.js` reads
it and pushes it onto `proposal.grants` as **text**, then does nothing with it.
The level-up flow computes pool growth and per-level percentage increases and
leaves the actual picks to the player's memory.

## Decisions

**Inline in the proposal, bankable if skipped.** The proposal grows a picker
step. Confirm picks there, or skip — unclaimed picks sit as pending on the
character with a badge on the sheet until claimed. Levelling up is never blocked.
Rejected: requiring picks before the level-up commits, and deferring picks
entirely to a separate area on the sheet.

**Filter to legal choices, allow override.** The picker defaults to the
categories the class's schedule permits, with a toggle to show everything and
pick anyway — flagged on the character when you do. Rejected: hard restriction
with no override, and showing everything with advisories only.

**A skill picked at level 6 starts at its catalog base percentage** and advances
per level from there. Standard Palladium reading: a newly learned skill is new
regardless of character level. Rejected: bringing it up as though the character
had always had it.

**Every crossed threshold accumulates, itemised by level.** Jumping from level 2
to level 7 crosses both the level-3 and level-6 grants and yields both sets of
picks, each labelled with the level that granted it. Rejected: one flat
undifferentiated pool, and granting only the highest threshold.

## Schema

Pending picks need to persist. `db/migrations/009-pending-skill-picks.sql`:

```sql
CREATE TABLE pending_skill_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  categories TEXT,              -- JSON array; NULL = unrestricted
  claimed_at TEXT
);
CREATE INDEX idx_pending_picks_character ON pending_skill_picks (character_id);
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('009-pending-skill-picks.sql');
```

One row per grant, not per pick, so "2 picks from Physical or Rogue, earned at
level 3" stays intact and itemised. Mirror into `db/schema.sql`.

A skill added this way is written into the character's existing `skills` JSON
column alongside every other skill, with enough marking to show provenance —
the level it was gained at, and an override flag if it was picked outside the
allowed categories.

## Work

**`_lib/leveling.js`** — `grants` stops being decorative:

- For a `fromLevel` → `toLevel` span, collect every schedule threshold strictly
  greater than `fromLevel` and less than or equal to `toLevel`.
- Emit each as a structured grant: level, count, allowed categories.
- The proposal returns these as claimable grants, not as text.

**Level-up commit** — creates a `pending_skill_picks` row per grant. If the
client sends picks with the commit, they are applied and the rows are marked
claimed in the same batch. Do these as one `batch()` so a partial level-up is
impossible.

**Picker UI** — a step in the level-up flow and, for banked picks, an entry point
from the sheet:

- Grants listed by the level that earned them, each showing picks remaining.
- Skill list filtered to allowed categories, with a "show all skills" toggle.
  Picking outside the filter marks the skill as an override and shows an
  advisory — it does not block.
- Skills the character already has are excluded from selection.
- New picks land at catalog `base`, displayed before confirming so there is no
  surprise.
- The sheet shows a badge when unclaimed picks exist, linking to the picker.

Note the existing wizard pattern: a delegated `change` listener on `#app`
dispatching on `data-act`, added because inline handlers broke on skill names
containing apostrophes. Follow it — skill names here come from the same catalog.

## Interactions with other PRs

- **PR 4** may have introduced hand-created skills; the picker reads the live
  catalog, so they appear automatically.
- **PR 10** builds directly on this — server-side enforcement of skill counts
  needs to understand pending and claimed picks, or it will read a legitimately
  levelled character as illegal. Land 9 before 10.

## Acceptance

- A class with picks at levels 3 and 6 offers picks at both when a character goes
  from level 2 to level 7, itemised by level.
- Skipping the picker banks the picks; the sheet shows a badge; the picks can be
  claimed later.
- A picked skill appears on the sheet at its catalog base percentage and advances
  correctly on the next level-up.
- Toggling "show all" and picking outside the allowed categories works and is
  flagged.
- A character cannot pick the same skill twice, or claim more picks than granted.
- Level-up with picks applied is atomic — no state where the level rose but the
  picks vanished.
- `node apps/character-creator/test/smoke.mjs` passes, extended to cover
  multi-level grant accumulation.

## Out of scope

Skill picks from sources other than the O.C.C. schedule, un-picking a skill after
confirming, and any secondary-skill progression rules beyond what
`occ_related_skills` describes.
