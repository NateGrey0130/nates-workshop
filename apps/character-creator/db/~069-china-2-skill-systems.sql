-- Tags Rifts World Book 25: China 2's 37 skills with their game, AFTER the
-- scripts that clear and re-tag skills.systems.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~069-china-2-skill-systems.sql
--
-- WHY A SEPARATE FILE - the ~023 Skudasa reason. add-a-china-2-skills.sql
-- writes the rows tagged ["rifts"], which is what production keeps. On a clean
-- build that file sorts first, fix-pf-armor-and-cross-system-gear.sql then
-- sets systems = NULL on every skill, and zzzzzzzzzzzzzzzz-tag-skill-systems.sql
-- re-tags only the rows it names. The tilde number is claimed at merge.
--
-- Guarded on systems IS NULL, so in production this changes nothing.

UPDATE skills SET systems = '["rifts"]'
 WHERE systems IS NULL
   AND source_book LIKE 'Rifts World Book 25: China 2 p.%';

SELECT 'the 37 China 2 skills are tagged Rifts' AS assertion,
       count(*) AS got,
       37 AS want
  FROM skills WHERE source_book LIKE 'Rifts World Book 25: China 2 p.%' AND systems = '["rifts"]';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~069-china-2-skill-systems.sql');
