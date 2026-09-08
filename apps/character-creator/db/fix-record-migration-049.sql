-- Record migration 049 in the ledger it forgot to write to.
--
-- BOOK-INGEST-AUDIT.md F37, taken in PR #826.
--
-- `drift-check --remote` reports `MIGRATION NOT APPLIED:
-- 049-spell-same-spell-as.sql` on a clean tree. The migration WAS applied:
-- `spells.same_spell_as` exists on production and 7 rows carry a link. What is
-- missing is the ledger row, because 049 is the one migration that does not end
-- by recording itself - 048 does, and so does every other one.
--
-- THIS IS A DATA SCRIPT AND NOT A MIGRATION, and the finding proposed it the
-- other way round. F37 asked for the line to be appended to 049 as well, "so a
-- rebuild from nothing records it too". Both halves of that are wrong:
--
--   1. A rebuild from nothing ALREADY records it. `db/schema.sql` carries the
--      guarded seed at its own line - INSERT OR IGNORE ... SELECT
--      '049-spell-same-spell-as.sql' WHERE EXISTS (a pragma_table_info check
--      for the column) - which is step 3 of the five the `schema-change` skill
--      lists, and 049 did not skip it. A fresh database has been correct all
--      along; only an EXISTING one is missing the row.
--   2. Editing 049 is forbidden anyway. `schema-change` -> "Migrations are
--      never edited after being applied anywhere. A mistake gets a new
--      numbered file." 049 is applied on production and on this machine.
--
-- So the gap is exactly one row in one existing database, which is what a data
-- script is for. Nothing here touches schema.
--
-- GUARDED THE SAME WAY schema.sql guards it, rather than inserted flat: the
-- ledger's whole purpose is to say what a database actually has, and a row
-- asserting a migration that did not run is the one lie it exists to prevent.
-- If the column is absent, this does nothing and drift-check goes on saying so,
-- which is the correct outcome for a database that genuinely has not migrated.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '049-spell-same-spell-as.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'same_spell_as');

-- Both halves, so a run that guarded itself out is not read as a run that
-- worked. `recorded` 0 with `column_present` 0 is a database that has not had
-- 049 and correctly refused the row.
SELECT (SELECT count(*) FROM schema_migrations
         WHERE filename = '049-spell-same-spell-as.sql') AS recorded,
       (SELECT count(*) FROM pragma_table_info('spells')
         WHERE name = 'same_spell_as') AS column_present;

INSERT INTO data_script_runs (filename) VALUES ('fix-record-migration-049.sql');
