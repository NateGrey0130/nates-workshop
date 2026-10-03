-- Tags Rifts World Book 25: China 2's 29 Chi-Gung powers with their game,
-- AFTER the scripts that clear and re-tag psionic_powers.system.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~070-china-2-chi-gung-systems.sql
--
-- WHY. add-a-china-2-chi-gung-powers.sql writes the rows with system 'rifts',
-- which is what production keeps. On a clean build that file sorts first, and
-- the scripts that set every psionic power's system to NULL run after it
-- (zzzzzzzzzzzzzzz-retag-game-psionics.sql records them); that file re-tags
-- only the books it names. So the repo rebuilt these 29 with system NULL, and
-- repo-vs-live.mjs --offenders reported exactly 29 differing fields on
-- 2026-10-02, all this column on these rows. Production wins
-- (BOOK-INGEST-AUDIT F105), and this script writes production's value. The
-- tilde number is claimed at merge.
--
-- Guarded on system IS NULL, so in production this changes nothing.

UPDATE psionic_powers SET system = 'rifts'
 WHERE system IS NULL
   AND source_book LIKE 'Rifts World Book 25: China 2 p.%';

SELECT 'the 29 Chi-Gung powers are tagged Rifts' AS assertion,
       count(*) AS got,
       29 AS want
  FROM psionic_powers WHERE source_book LIKE 'Rifts World Book 25: China 2 p.%' AND system = 'rifts';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~070-china-2-chi-gung-systems.sql');
