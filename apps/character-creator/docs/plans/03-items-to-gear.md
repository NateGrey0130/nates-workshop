# PR 3 — Rename `items` to `gear`

## Problem

`items` is a generic name in a database shared with MediaVault, which already
has `media_items`. No collision today; it is the most likely future one. The
schema comment already has to explain the distinction.

## Decision

**`ALTER TABLE items RENAME TO gear`, all references updated in the same PR, no
compatibility layer.**

The API route stays `/api/character-creator/items`. Renaming the endpoint too was
considered and rejected — both the wizard and the sheet call it, and the blast
radius is not worth end-to-end naming purity for an internal table concern.

Dropping the PR entirely was also on the table. It is being done because PR 7
adds a gear importer and a full stat block to this table; renaming before that
work is cheaper than after.

## Scope of the change

`items` appears 140 times across 25 files, but most are CSS class names and
unrelated MediaVault code. The actual database references are:

- `db/schema.sql` — the `items` create statement and the `character_items`
  foreign key `item_id INTEGER REFERENCES items(id)`
- `functions/api/character-creator/items.js`
- `functions/api/character-creator/characters/[id]/items.js`
- `functions/api/character-creator/characters/[id]/items/[itemId].js`
- `functions/api/character-creator/_lib/catalog.js` — stub creation and
  cross-reference lookups
- `functions/api/character-creator/characters.js` and `characters/[id].js`
- `apps/character-creator/db/seed-dev.sql`
- `apps/character-creator/test/smoke.mjs`
- The app README

**Grep for `FROM items`, `INTO items`, `JOIN items`, and `REFERENCES items` — not
bare `items`.** Bare matches are dominated by CSS and MediaVault.

`character_items` keeps its name and its `item_id` column. Renaming the join
table and its column is a much larger change for no additional benefit; only the
catalog table is being disambiguated.

## Schema

`db/migrations/005-items-to-gear.sql`:

```sql
ALTER TABLE items RENAME TO gear;
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('005-items-to-gear.sql');
```

SQLite rewrites `REFERENCES items(id)` in dependent tables automatically when
`legacy_alter_table` is off, which is the default in modern SQLite and in D1.
**Verify this after applying** — query
`SELECT sql FROM sqlite_master WHERE name='character_items'` and confirm it now
reads `REFERENCES gear(id)`. If it still says `items`, the foreign key is broken
and the table needs a rebuild instead.

Also rename the table in `db/schema.sql`, keeping the comment that distinguishes
it from MediaVault's `media_items`.

## Ordering

This migration must be applied to production **before** the deploy that merges
the PR, per the standing rule. The code and the schema change are not separable
here — the moment the new code deploys it queries `gear`.

## Acceptance

- `SELECT sql FROM sqlite_master WHERE name='character_items'` shows
  `REFERENCES gear(id)`.
- A character's inventory loads, an item can be added and removed, and a
  freeform custom item still works.
- A class import still creates gear stubs for equipment it references.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Renaming `character_items`, its `item_id` column, the API routes, or any CSS
class containing "items".
