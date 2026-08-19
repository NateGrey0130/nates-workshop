-- Provenance columns for the two skills fix-long-bowman.sql created.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/backfill-skill-provenance.sql
--
-- fix-long-bowman.sql inserted 'W.P. Targeting' and 'Language: Native Tongue'
-- with the BOOK NAME in the `source` column:
--
--   INSERT OR IGNORE INTO skills (name, category, base, per_level, source)
--   VALUES ('W.P. Targeting', 'Weapon Proficiencies', 0, 0, 'palladium-fantasy-core');
--
-- `source` is a closed set - seed | import | manual - and `source_book` is where
-- a title goes. So both rows carry a value nothing recognises and a NULL where
-- their book should be, and neither is findable by the query that asks where a
-- row came from.
--
-- This changes no behaviour, which is worth stating plainly rather than
-- implying: the importer's stub test is `source === 'import'`, so these rows
-- classify as curated and default to *ignore* either way. 'manual' is simply
-- the true answer, and it keeps that protection for a reason that matters here
-- - W.P. Targeting is base 0 / per_level 0, which is CORRECT for a W.P. rather
-- than a missing value, and a row reading 'import' with those numbers would be
-- classified a stub and offered for overwrite on the next skill import.
--
-- Values are unchanged. Only the two provenance columns move.
--
-- Guarded on the wrong value still being present, so re-running is a no-op and
-- a row someone has already corrected by hand is left alone.
UPDATE skills
   SET source = 'manual',
       source_book = 'Palladium Fantasy RPG 2nd Ed.'
 WHERE source = 'palladium-fantasy-core';

-- Read the result back rather than trusting the exit code. `source` should now
-- hold only the three values it is allowed to.
SELECT source, source_book, count(*) AS n
  FROM skills
 GROUP BY source, source_book
 ORDER BY n DESC;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-skill-provenance.sql');
