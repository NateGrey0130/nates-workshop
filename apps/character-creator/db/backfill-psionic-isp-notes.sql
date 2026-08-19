-- Cost schedules for the seven psionic powers whose I.S.P. is not one flat
-- number, using the isp_note column migration 020 added.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema. Requires 020-psionic-isp-note.sql first.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/backfill-psionic-isp-notes.sql
--
-- The convention: `isp` holds the MINIMUM cost (the sheet's use button
-- deducts it) and `isp_note` says the schedule in a few words; the full
-- wording stays in the description. Minimums come from the cost figures
-- already stored in each row's own description.
--
-- Every update guards on the state it expects (isp_note still NULL, and the
-- old isp value), so a hand-corrected row is never overwritten and re-running
-- is harmless.

-- The three multi-ability powers: each sub-ability has its own cost, and the
-- stored 0 read as free while matching the import stub heuristic.
UPDATE psionic_powers SET isp = 2, isp_note = '2-4 by ability'
 WHERE name = 'Electrokinesis' AND isp = 0 AND isp_note IS NULL;
UPDATE psionic_powers SET isp = 2, isp_note = '2-5 by ability'
 WHERE name = 'Hydrokinesis' AND isp = 0 AND isp_note IS NULL;
UPDATE psionic_powers SET isp = 2, isp_note = '2-25 by ability'
 WHERE name = 'Pyrokinesis' AND isp = 0 AND isp_note IS NULL;

-- The three variable-cost powers the RUE chapter import flagged. Their
-- stored minimums were already right; the note carries the rest.
UPDATE psionic_powers SET isp_note = 'special - see description'
 WHERE name = 'Mind Block Auto-Defense' AND isp = 14 AND isp_note IS NULL;
UPDATE psionic_powers SET isp_note = '6-40 by damage'
 WHERE name = 'Mind Bolt' AND isp = 6 AND isp_note IS NULL;
UPDATE psionic_powers SET isp_note = '10; 50 for permanent'
 WHERE name = 'Mind Wipe' AND isp = 10 AND isp_note IS NULL;

-- Meditation genuinely costs nothing - the note says the zero is deliberate,
-- which also stops it matching the stub heuristic (source import + isp 0).
UPDATE psionic_powers SET isp_note = 'costs nothing'
 WHERE name = 'Meditation' AND isp = 0 AND isp_note IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT name, isp, isp_note FROM psionic_powers WHERE isp_note IS NOT NULL ORDER BY name;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-psionic-isp-notes.sql');
