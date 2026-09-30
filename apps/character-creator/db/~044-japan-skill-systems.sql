-- Tags Rifts World Book 8: Japan's 19 skills with their game, AFTER the scripts that clear
-- and re-tag skills.systems.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~044-japan-skill-systems.sql
--
-- WHY A SEPARATE FILE - the ~023 Skudasa reason. add-a-japan-skills.sql writes
-- the rows tagged ["rifts"], which is what production keeps. On a clean build
-- that file sorts first, fix-pf-armor-and-cross-system-gear.sql then sets
-- systems = NULL on every skill, and zzzzzzzzzzzzzzzz-tag-skill-systems.sql
-- re-tags only the rows it names. The tilde number is claimed at merge.
--
-- Guarded on systems IS NULL, so in production this changes nothing.

UPDATE skills SET systems = '["rifts"]'
 WHERE systems IS NULL
   AND source_book LIKE 'Rifts World Book 8: Japan p.%';

SELECT 'the 19 Japan skills are tagged Rifts' AS assertion,
       count(*) AS got,
       19 AS want
  FROM skills WHERE source_book LIKE 'Rifts World Book 8: Japan p.%' AND systems = '["rifts"]';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~044-japan-skill-systems.sql');
