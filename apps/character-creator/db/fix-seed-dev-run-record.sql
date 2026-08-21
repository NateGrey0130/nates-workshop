-- Remove a run record that asserts something untrue.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-seed-dev-run-record.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-seed-dev-run-record.sql
--
-- `backfill-data-script-runs.sql` recorded every file in apps/character-creator/db
-- as having run before tracking existed, stamped 'pre-tracking backfill
-- (asserted, not observed)'. It swept up `seed-dev.sql` with the rest.
--
-- seed-dev.sql is LOCAL-ONLY. It carries the `-- local-only` marker, its inserts
-- are unguarded, and the README says plainly that it is "never applied to
-- production". So the row on production claims a script ran that must never run
-- there - exactly the kind of false record `data_script_runs` exists to prevent,
-- and invisible until someone trusts it.
--
-- The backfill already excludes retire-gear-placeholders.sql by hand for a
-- related reason ("asserting a plain run would read as finished"), so this is
-- the same oversight one file along.
--
-- NOTHING WAS ACTUALLY SEEDED. Checked before writing this: production holds no
-- rows from seed-dev.sql. The characters that look like test data belong to the
-- real account and were made through the app.
--
-- Only the ASSERTED row is removed. If a local database genuinely ran the dev
-- seed and recorded an observed run, that row says something true and stays.

DELETE FROM data_script_runs
 WHERE filename = 'seed-dev.sql'
   AND note = 'pre-tracking backfill (asserted, not observed)';

-- Read the result back rather than trusting the exit code. Expect 0 asserted,
-- and whatever observed rows the environment legitimately has.
SELECT count(*) AS asserted_seed_dev_rows_remaining
  FROM data_script_runs
 WHERE filename = 'seed-dev.sql'
   AND note = 'pre-tracking backfill (asserted, not observed)';
SELECT count(*) AS observed_seed_dev_rows
  FROM data_script_runs
 WHERE filename = 'seed-dev.sql'
   AND (note IS NULL OR note <> 'pre-tracking backfill (asserted, not observed)');

INSERT INTO data_script_runs (filename) VALUES ('fix-seed-dev-run-record.sql');
