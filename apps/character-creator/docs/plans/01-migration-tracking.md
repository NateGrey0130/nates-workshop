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
4. **Seed the table from `db/schema.sql`, guarded per feature.** A database built
   from `schema.sql` already contains every column the migrations add, so it is
   current the moment it exists and should say so.

   But on an *existing* database every `CREATE` in `schema.sql` is skipped —
   which is why migrations exist at all. An unconditional insert would therefore
   mark an old, un-migrated database as migrated, exactly the lie this table
   exists to prevent. So guard each seeded row against the schema feature its
   migration adds:

   ```sql
   INSERT OR IGNORE INTO schema_migrations (filename)
   SELECT '001-character-detail.sql'
   WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'bio');
   ```

   This also backfills production and local, since `schema.sql` is safe to
   re-run. **No `003` backfill migration is needed** — an earlier draft of this
   plan called for one before the guarded-seed approach made it redundant.
5. Document the convention in the app README's Production configuration section,
   replacing the `pragma_table_info` advice with:
   ```sql
   SELECT filename, applied_at FROM schema_migrations ORDER BY filename;
   ```

## Convention to document

- Filenames are `NNN-kebab-description.sql`, applied in ascending order.
- Every migration ends with its own `INSERT OR IGNORE INTO schema_migrations`.
- Every migration also gets a **guarded** seed line in `db/schema.sql`. This is
  the step easiest to forget; the smoke test is what catches it.
- Migrations are never edited after being applied anywhere. A mistake gets a new
  numbered file.
- `db/schema.sql` remains the idempotent full-create path for new databases;
  migrations remain the ALTER path for existing ones.

## Acceptance

- `SELECT filename FROM schema_migrations ORDER BY filename` returns 001 and 002
  on both local and production after applying `schema.sql`.
- A guard on a column that does not exist inserts nothing — verify both
  directions, not just the matching one.
- `wrangler d1 execute DB --local --file db/schema.sql` on an empty database
  still produces a working schema, recorded as current.
- The smoke test fails when a migration file has no row, and when a row has no
  file.
- `node apps/character-creator/test/smoke.mjs` passes.

## As built

Landed in [#15](https://github.com/NateGrey0130/nates-workshop/pull/15). Matches
this plan apart from the dropped `003` file described above. Production verified:
both guards matched, which independently confirms production really does have
001's `bio` column and 002's `note` column.

## Out of scope

Automated application, ordering enforcement in code, down-migrations, and any
CI integration. This PR makes the state knowable, not automatic.
