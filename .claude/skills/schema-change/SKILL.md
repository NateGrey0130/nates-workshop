---
name: schema-change
description: Add or change a D1 table or column in this repo without leaving a fresh environment broken. Use when writing a migration, adding a table or column, or editing db/schema.sql — "add a column for X", "new table", "write migration NNN".
---

# Changing the schema

> **Pinned:** the frontmatter and every repo path named here (`environment.mjs`),
> every absolute path (`instruction-paths.mjs`).

A column lives in **five** places, not one. Four of the five are easy to skip
and none of them fail at the moment you skip them.

This is not hypothetical: migrations `020` and `021` added `isp_note` and
`ppe_note` and reached only the first place, the migration. Every existing database was fine, so nothing
looked wrong for weeks — but a database built the documented way came up without
the columns, and the wizard's first call selected both. The smoke test could not
see it either, because it applies `schema.sql` to a local database that had
already been migrated by hand.

**First, which database.** Since 2026-09-25 each group of apps is getting a D1
of its own (`groups.json`, `CLAUDE.md` → *Three groups*). Palladium's is
`db/schema.sql` and `db/migrations/`, and every path below is written for it.
A group whose tables have moved uses `db/schema-<group>.sql` and
`db/migrations/<group>/` instead — Marvel does, as `db/schema-marvel.sql` and
`db/migrations/marvel/`, and tools does, as `db/schema-tools.sql` and
`db/migrations/tools/` — and is applied with `d1-apply.mjs --db <group>`
(`--db marvel`, `--db tools`). The same rules hold in each: the
smoke checks run once per group and name the group when it is not Palladium,
and `groups.mjs --check` fails a table created in the wrong group's file.

**The five places** a column lands, **the four more** a whole TABLE needs, the hand-written catalog ledgers, **writing the migration** and **the guarded seed line** are all in `.claude/rules/d1-schema.md`, not in this file. That file loads by itself only when a file under `db/` is read. **Read it now if it is not in context**, before you plan the change or list where it lands.

## A new database does not run the migrations

This looks like breakage and is not. `db/schema.sql` already contains every
column the migrations add, so **most of them — every ALTER — fail on a fresh
database**: `duplicate column name: bio`, `no such table: items`. It records all of them as
applied instead, guarded, so a fresh database is current the moment it exists.

| | new database | existing database |
|---|---|---|
| `db/schema.sql` | yes | yes — harmless, and how you backfill the records |
| `db/migrations/*.sql` | **no** | yes — the ones it has not had, in order |

See *Standing up a new environment* in
`apps/character-creator/docs/operations.md`.

## Applying it

Before the merge that needs it (`ship-pr` → *The ordering rule*).

```bash
node scripts/d1-apply.mjs --remote db/migrations/NNN-thing.sql
```

Then ask the database, rather than reading the exit code:

```bash
node scripts/q.mjs --remote "SELECT filename FROM schema_migrations ORDER BY filename"
```

`sqlite_master` and `schema_migrations` are authoritative. `pragma_table_info`
is not — over `--remote` it has returned stale replica data mid-migration.

## What fails when you skip a step

The smoke test names the place. The numbers are the `#` column of *The five
places* in `.claude/rules/d1-schema.md`:

| Failure | Missed |
|---|---|
| `every migrated column is also in a schema.sql CREATE` | place 2, the `db/schema.sql` `CREATE` |
| `every migration has a guarded seed line in schema.sql` | place 3, the seed row |
| `every seed line is guarded by a schema feature` | place 3, the row is there but unguarded |
| `every migration has a row in the docs/operations.md table` | place 4, the `apps/character-creator/docs/operations.md` migration table |
| `every table has a row in a data-model table` | place 5, the `README.md` data model |
| `and it matches schema.sql` (table count) | place 5, a new table's count |

Run it before pushing:

```bash
node apps/character-creator/test/smoke.mjs
```

## Data scripts are a different thing

`apps/character-creator/db/*.sql` change **rows**, not schema, are tracked in
`data_script_runs`, and each must end by recording itself. For writing one, use
the `class-import` skill — its `reference/data-script.sql` is the template.
