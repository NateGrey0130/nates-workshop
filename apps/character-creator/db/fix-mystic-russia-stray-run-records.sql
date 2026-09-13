-- Remove two data_script_runs rows that record runs which changed nothing.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-mystic-russia-stray-run-records.sql
--
-- WHY THIS FILE EXISTS, stated plainly because it is my own mistake.
--
-- The Mystic Russia Gypsy Thief was first drafted with the id `gypsy-thief`.
-- That id was ALREADY TAKEN by the Gypsy Thief of Rifts World Book 5: Triax and
-- the NGR. Two things followed, and neither announced itself:
--
--   1. `--emit-script gypsy-thief` writes to `add-gypsy-thief-class.sql`, which
--      is TRIAX'S EXISTING FILE. It was overwritten in the worktree. Restored
--      with git checkout; nothing reached a commit.
--   2. Applying it `--remote` INSERTED NOTHING. The class INSERT is
--      `INSERT ... WHERE NOT EXISTS` on class_id, which makes a re-run a no-op -
--      and makes an ID COLLISION a no-op too, with no error and no warning. The
--      only symptom is that the live class count does not move.
--
-- So production now holds two run records for work that did not happen:
--
--   add-gypsy-thief-class.sql        recorded TWICE - Triax's real run, plus my
--                                    no-op. The duplicate is removed; the
--                                    original stays.
--   fix-gypsy-thief-roll-key.sql     recorded once, for a file that no longer
--                                    exists in the repo. It was a correction to
--                                    a class that was never inserted, and its
--                                    UPDATE matched nothing.
--
-- Neither row broke a test - the suite checks the SQL FILES, not this table -
-- but a ledger entry naming a script that does not exist will mislead whoever
-- reads it next, and a duplicate implies a second real application.
--
-- The class itself is re-imported as `gypsy-thief-russian` alongside this.
--
-- THIS FILE IS A NO-OP on any database that never saw those applies, including
-- a clean rebuild, because both DELETEs are guarded on what they remove.

-- The duplicate only. `id NOT IN (SELECT MIN(id) ...)` keeps the earliest row,
-- which is Triax's genuine run.
DELETE FROM data_script_runs
 WHERE filename = 'add-gypsy-thief-class.sql'
   AND id NOT IN (SELECT MIN(id) FROM data_script_runs
                   WHERE filename = 'add-gypsy-thief-class.sql');

DELETE FROM data_script_runs
 WHERE filename = 'fix-gypsy-thief-roll-key.sql';

-- Read the result back. Both hold in every environment, including one that
-- never saw the stray applies.
SELECT 'Triax''s gypsy-thief run is recorded exactly once' AS assertion, count(*) AS got, 1 AS want
  FROM data_script_runs WHERE filename = 'add-gypsy-thief-class.sql';

SELECT 'and the withdrawn fix is not recorded at all' AS assertion, count(*) AS got, 0 AS want
  FROM data_script_runs WHERE filename = 'fix-gypsy-thief-roll-key.sql';

SELECT 'the Triax class row is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'gypsy-thief' AND deleted_at IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-mystic-russia-stray-run-records.sql');
