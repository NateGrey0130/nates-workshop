---
paths:
  - "db/**"
---

# Changing the D1 schema

> **What pins this file:** every absolute path it names, by
> `apps/character-creator/test/checks/instruction-paths.mjs`; its `paths:`
> globs, by `environment.mjs` (*Rules stay true*: each matches a tracked
> file). Nothing pins the repo paths its body names: it is a path-scoped rule,
> not a skill, so the skill path scan does not read it.
>
> **The prose is pinned by nothing** — read an undated claim here as true on
> the day it was written.

These bind anyone editing `db/`. They were moved unchanged out of the
`schema-change` skill (2026-11-06), which still owns which database a change
goes to, why a new database does not run the migrations, applying one, and
which smoke check names a skipped step.

Every path below is written for Palladium (`db/schema.sql`,
`db/migrations/`). Marvel and tools have a D1 of their own
(`db/schema-marvel.sql` with `db/migrations/marvel/`, `db/schema-tools.sql`
with `db/migrations/tools/`), applied with `d1-apply.mjs --db <group>`; the
same rules hold in each.

## The five places

| # | Where | What |
|---|---|---|
| 1 | `db/migrations/NNN-kebab.sql` | the `ALTER`, ending by recording itself |
| 2 | `db/schema.sql` `CREATE` | the same column, inline |
| 3 | `db/schema.sql` seeding block | a **guarded** row for the migration |
| 4 | `docs/operations.md` migration table | one row describing what it adds |
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
| 9 | the README data-model **table count** | the sentence opening the *Data model* section that says how many tables the shared database has, spelled as a word rather than a numeral. It is parsed back out of the prose and compared against `schema.sql`; a new table moves it, and the smoke test fails until it does. Find it with `node scripts/readme-section.mjs "Data model"`, and let the test tell you the current value — quoting one here is how this row was wrong for seven tables |

Step 9 is the one that catches the others: `and it matches schema.sql` fires the
moment the count is stale, which is usually the moment the table lands.

**And a new CATALOG is named by hand in the ledgers too.** Declaring it in
`js/catalog-fields.js` (step 6) builds the editor and the endpoints, and reaches
none of these, which keep their own literal lists on purpose - they disagree
about scope, so they are not derived:

| where | the list |
|---|---|
| `scripts/source-coverage.mjs` | the group list, **twice** - live side and build side - and the two must match or every run prints a phantom delta the size of a table |
| `scripts/repo-vs-live.mjs` | `TABLES` - a triple naming the table's identity column, read from `schema.sql` rather than assumed |
| `scripts/drift-check.mjs` | `CITATION_TABLES` - only if the catalog's names are the book's own headings; gear-like catalogs are deliberately left out |
| `apps/character-creator/test/regression.mjs` | the redirect map - keyed by the **CATALOGS key**, not the table name, because that is what `catalog_redirects` stores |

**You do not have to remember these.** The smoke check *"every catalog is in
every hand-written catalog list"* reads all of them as text and fails, naming the
list and the catalog, the moment one is missed. It exists because this was
remembered by hand for the ninth catalog after being forgotten for three before
it - `BOOK-INGEST-AUDIT` F28, F85 and F100. A deliberate exclusion from
`CITATION_TABLES` has to be NAMED in that check, with its reason, or it reads as
an omission.

**This row used to quote the number, and the number went stale.** It said
twenty-six while the README said thirty-three and `schema.sql` had 33 — in the
file whose job is to tell you to update that count. The README was fine the
whole time, because a check reads it back out of the prose; nothing read this.
There is now a companion check — *"and no skill quotes a table count that
disagrees with it"* — so a value quoted in any skill has to be right. The
cheaper habit is not to quote one.

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
