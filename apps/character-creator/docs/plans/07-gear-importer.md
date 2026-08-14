# PR 7 — Gear importer

## Problem

Every gear row in production is a name-only stub created by a class import.
Characters have equipment lists with names and nothing else — no weight, no cost,
no damage, no AR or MDC. The sheet's armour block, added alongside saving throws
and combat skills, has no catalog data to draw on.

Depends on PR 3 (the table is `gear` by now) and PR 5 (the engine).

## Decisions

**One table, full Rifts stat block, nulls where irrelevant.** Weapons, body
armour, and general equipment share the table; a field that does not apply to an
item is simply null. Rejected: a `type` column with a JSON stats blob whose shape
varies — cleaner conceptually, but every consumer would need to branch on type.
Also rejected: weight, cost, and description only.

**Stubs auto-fill, real rows prompt.** A row with nothing but a name and slug
defaults to *update*; anything curated prompts. This is the behaviour the skill
importer already has and that you have been using.

Rejected: prompting on everything, and adding a post-run coverage report of which
stubs remain hollow. The coverage report is a reasonable later addition — PR 4's
catalog table filtered to empty rows gets most of the way there.

## Schema

`db/migrations/009-gear-detail.sql`:

```sql
ALTER TABLE gear ADD COLUMN weight TEXT;
ALTER TABLE gear ADD COLUMN cost TEXT;
ALTER TABLE gear ADD COLUMN damage TEXT;
ALTER TABLE gear ADD COLUMN is_mega_damage INTEGER NOT NULL DEFAULT 0;
ALTER TABLE gear ADD COLUMN range TEXT;
ALTER TABLE gear ADD COLUMN payload TEXT;
ALTER TABLE gear ADD COLUMN rate_of_fire TEXT;
ALTER TABLE gear ADD COLUMN ar INTEGER;
ALTER TABLE gear ADD COLUMN mdc INTEGER;
ALTER TABLE gear ADD COLUMN description TEXT;
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('009-gear-detail.sql');
```

Check `db/schema.sql` first — the existing `gear` table already has some of
these. Only add what is missing.

Notes on types:

- `weight` and `cost` are `TEXT`: books write "3 lbs" and "12,000 credits", and
  cost is sometimes a range.
- `damage` is `TEXT` because it is a dice expression, often several
  ("2D6 M.D. single shot, 6D6 M.D. burst"). It is not evaluated at import.
- `is_mega_damage` is the one boolean worth having structured — SDC versus MDC is
  the single most consequential distinction in Rifts, and reading it out of a
  damage string later is error-prone.
- `ar` and `mdc` are integers because the armour block on the sheet uses them
  numerically.

## Work

- Extend the `gear` entry in `_lib/catalog-fields.js`.
- Gear prompt fragment. This is the hardest extraction of the three: an
  equipment chapter mixes weapon tables, armour tables, and prose gear
  descriptions on the same page, with wildly different shapes. The fragment
  should name the item kinds explicitly and instruct that non-applicable fields
  be omitted rather than guessed.
- **Slug generation matters here.** Class imports create stubs keyed on `slug`,
  matching `equipment_starting` item_id references in class markdown. The
  importer must match an extracted item to an existing stub by slug where it can,
  not only by name, or every filled-in item becomes a second row and the
  characters keep pointing at the empty one. This is the single highest-risk
  detail in the PR — verify it against real stub rows before confirming a batch.
- Add a **Gear** tab to `import.html`.

## Acceptance

- A gear session imports a weapon page and stages items with damage,
  `is_mega_damage`, range, payload, and rate of fire populated.
- An armour page produces items with AR and MDC populated and weapon fields null.
- An existing name-only stub is matched **by slug**, defaults to update, and
  after confirm the character already holding that item shows the new stats
  without any change to the character row.
- A curated gear row prompts rather than auto-updating.
- Non-admin is refused.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Encumbrance calculation from weight, auto-populating the sheet's armour AR/MDC
block from equipped gear, vehicle-specific stats, and the coverage report.
