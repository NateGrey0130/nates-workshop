---
name: schema-change
description: Add or change a D1 table or column in this repo without leaving a fresh environment broken. Use when writing a migration, adding a table or column, or editing db/schema.sql — "add a column for X", "new table", "write migration NNN". Covers the five places one column has to land, why a new database must NOT run the migrations, and the smoke checks that fail when a step is skipped.
---

# Changing the schema

A column lives in **five** places, not one. Four of the five are easy to skip
and none of them fail at the moment you skip them.

This is not hypothetical: migrations `020` and `021` added `isp_note` and
`ppe_note` and reached only step 1. Every existing database was fine, so nothing
looked wrong for weeks — but a database built the documented way came up without
the columns, and the wizard's first call selected both. The smoke test could not
see it either, because it applies `schema.sql` to a local database that had
already been migrated by hand.

## The five places

| # | Where | What |
|---|---|---|
| 1 | `db/migrations/NNN-kebab.sql` | the `ALTER`, ending by recording itself |
| 2 | `db/schema.sql` `CREATE` | the same column, inline |
| 3 | `db/schema.sql` seeding block | a **guarded** row for the migration |
| 4 | `README.md` migration table | one row describing what it adds |
| 5 | `README.md` data model | the column, or a whole row + the table count, for a new table |

Steps 1 and 2 are not alternatives. **The migration brings an existing database
forward; the `CREATE` is what a brand-new one gets.** Both, every time.

## A whole TABLE needs four more places

The five above are what a COLUMN costs. A new table is read and written by
things a column is not, and none of these fails at the moment it is skipped
either:

| # | Where | What |
|---|---|---|
| 6 | `js/catalog-fields.js` | its fields, **if it is a catalog.** This one is worth the trouble: the editor UI, the write endpoints and the importers all build themselves from that config, so a catalog declared there arrives with all three |
| 7 | `functions/api/character-creator/catalogs.js` | one more `SELECT`, if the wizard needs it at boot |
| 8 | `_lib/character-json.js` | the right EMPTY value, if it adds a JSON column to `characters` — `[]` and `{}` are not interchangeable and `null` is neither |
| 9 | the README data-model **table count** | *"Twenty-six tables in one shared D1 database"* is parsed and compared against `schema.sql`. A new table moves it, and the smoke test fails until it does |

Step 9 is the one that catches the others: `and it matches schema.sql` fires the
moment the count is stale, which is usually the moment the table lands.

## Writing the migration

```sql
-- Why this column exists, in the voice of the rest of db/migrations/.
ALTER TABLE psionic_powers ADD COLUMN isp_note TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('020-psionic-isp-note.sql');
```

- Filenames are `NNN-kebab-description.sql`, applied in ascending order.
- **Migrations are never edited after being applied anywhere.** A mistake gets a
  new numbered file.
- Non-ASCII is fine in comments and refused in executable SQL. For a stored
  em-dash, splice it: `'a ' || char(8212) || ' b'`.

## The guarded seed line

```sql
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '020-psionic-isp-note.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('psionic_powers') WHERE name = 'isp_note');
```

**The guard tests the schema feature the migration adds.** Never insert
unconditionally: on an existing database every `CREATE` above is skipped, so an
unguarded row marks an un-migrated database as migrated — precisely the lie the
table exists to prevent, and invisible until someone trusts the record.

A rename or a drop needs **both halves** checked. `004` renamed `items` to
`gear`, so its guard requires `gear` to exist *and* `items` not to.

## A new database does not run the migrations

This looks like breakage and is not. `db/schema.sql` already contains every
column the migrations add, so **18 of the 24 fail on a fresh database** —
`duplicate column name: bio`, `no such table: items`. It records all of them as
applied instead, guarded, so a fresh database is current the moment it exists.

| | new database | existing database |
|---|---|---|
| `db/schema.sql` | yes | yes — harmless, and how you backfill the records |
| `db/migrations/*.sql` | **no** | yes — the ones it has not had, in order |

See *Standing up a new environment* in the character-creator README.

## Applying it

Before the merge that needs it — see the `ship-pr` skill.

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-thing.sql
```

Then ask the database, rather than reading the exit code:

```bash
npx wrangler d1 execute DB --remote --command "SELECT filename FROM schema_migrations ORDER BY filename;"
```

`sqlite_master` and `schema_migrations` are authoritative. `pragma_table_info`
is not — over `--remote` it has returned stale replica data mid-migration.

## What fails when you skip a step

The smoke test names the step:

| Failure | Missed |
|---|---|
| `every migrated column is also in a schema.sql CREATE` | step 2 |
| `every migration has a guarded seed line in schema.sql` | step 3 |
| `every seed line is guarded by a schema feature` | step 3, unguarded |
| `every migration has a row in the README table` | step 4 |
| `every table has a row in a data-model table` | step 5 |
| `and it matches schema.sql` (table count) | step 5, new table |

Run it before pushing:

```bash
node apps/character-creator/test/smoke.mjs
```

## Data scripts are a different thing

`apps/character-creator/db/*.sql` change **rows**, not schema, are tracked in
`data_script_runs`, and each must end by recording itself. For writing one, use
the `class-import` skill — its `reference/data-script.sql` is the template.
