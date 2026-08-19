-- Bookkeeping for apps/character-creator/db/*.sql, the way schema_migrations
-- is bookkeeping for this directory.
--
-- Those scripts change ROWS rather than schema: class definitions rewritten
-- against the books, catalog rows a book gives that the database never had,
-- backfills for columns an import left NULL. There are 55 of them and nothing
-- has ever recorded which have been run against which environment. The only
-- way to answer "has production had the Juicer correction?" is to query the
-- rows it writes and infer - the same guessing game schema_migrations was
-- created to end for migrations.
--
-- One row per RUN, not per file, and deliberately not keyed on the filename.
-- A data script is not applied-once the way a migration is: every statement
-- guards itself, so a script is safe to run twice and safe to run EARLY.
-- retire-gear-placeholders.sql is the standing case - it does nothing at all
-- until the equipment chapter it rewrites toward has been imported, and is
-- meant to be run again afterwards. A one-shot `applied` flag would record
-- that first no-op run as done and hide the fact that the real work never
-- happened, which is worse than no record.
--
-- So: an append-only log. "Has it run here" is `EXISTS`, "did it run since the
-- import" is a comparison on run_at, and a script run three times has three
-- rows, which is the truth.
--
-- `note` is free text for a row that needs a caveat - the backfill script that
-- accompanies this migration stamps 'pre-tracking backfill' on every script
-- that had already been applied before any of this existed, because those runs
-- are asserted by a human rather than observed.
CREATE TABLE IF NOT EXISTS data_script_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  filename TEXT NOT NULL,               -- basename only, e.g. 'fix-juicer.sql'
  note TEXT,                            -- NULL = an ordinary observed run
  run_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_data_script_runs_file ON data_script_runs (filename, run_at);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('024-data-script-runs.sql');
