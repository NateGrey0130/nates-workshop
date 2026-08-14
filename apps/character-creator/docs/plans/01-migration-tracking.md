# PR 1 — Migration tracking

## Problem

`db/migrations/*.sql` are one-shot, manual, unordered, and leave no record of
what has been applied to which environment. Today the only way to know whether
`001-character-detail.sql` ran against production is
`SELECT name FROM pragma_table_info('characters')` and inference. A re-run fails
with "duplicate column name", which is the current — unpleasant — detection
mechanism.

Every remaining PR in this roadmap adds a migration. Fixing this first means the
other ten land on a base that can answer "what's applied here?".

## Decision

**A `schema_migrations` table plus numbered files, applied by hand.** Each
migration file ends by inserting its own row. You still run `wrangler d1 execute`
per environment and per file, but the database can be queried for what it has.

Rejected, deliberately:

- **A Node runner script** (`node db/migrate.mjs --local|--remote`). Convenient,
  but adds a script that shells out to wrangler and a new failure surface.
- **An admin migrate endpoint.** Puts schema changes behind a web request. The
  blast-radius increase was not worth removing a terminal step.
- **A recording table with no ordering convention.** Too little to be worth the
  table.

## Schema

New in `db/schema.sql` (idempotent, so it can be added there rather than as a
migration):

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
  filename    TEXT PRIMARY KEY,
  applied_at  TEXT NOT NULL DEFAULT (datetime('now'))
);
```

## Work

1. Add `schema_migrations` to `db/schema.sql`.
2. Rename existing migrations to a zero-padded, sortable convention if they are
   not already: `001-…`, `002-…`. They are; keep it.
3. Append a self-recording insert to the end of each existing migration file, so
   a fresh environment records them as it applies them:
   ```sql
   INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('001-character-detail.sql');
   ```
4. **Backfill production and local.** Both databases already have 001 and 002
   applied but no rows. Write `db/migrations/003-migration-tracking.sql` that
   creates the table (for databases that predate the `schema.sql` change) and
   inserts rows for 001 and 002 with `INSERT OR IGNORE`. This is the one
   migration that must be safe to run on a database in any prior state.
5. Document the convention in the app README's Production configuration section,
   replacing the `pragma_table_info` advice with:
   ```sql
   SELECT filename, applied_at FROM schema_migrations ORDER BY filename;
   ```
6. Update the migrations table in the README to include 003.

## Convention to document

- Filenames are `NNN-kebab-description.sql`, applied in ascending order.
- Every migration ends with its own `INSERT OR IGNORE INTO schema_migrations`.
- Migrations are never edited after being applied anywhere. A mistake gets a new
  numbered file.
- `db/schema.sql` remains the idempotent full-create path for new databases;
  migrations remain the ALTER path for existing ones.

## Acceptance

- `SELECT filename FROM schema_migrations ORDER BY filename` returns 001, 002,
  and 003 on both local and production after backfill.
- Re-running 003 against an already-migrated database succeeds and changes
  nothing.
- `wrangler d1 execute DB --local --file db/schema.sql` on an empty database
  still produces a working schema.
- `node apps/character-creator/test/smoke.mjs` passes.

## Out of scope

Automated application, ordering enforcement in code, down-migrations, and any
CI integration. This PR makes the state knowable, not automatic.
