-- Tags Rifts World Book 9: South America 2's two non-language skills with
-- their game, AFTER the scripts that clear and re-tag skills.systems.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~002-south-america-2-skill-systems.sql
--
-- WHY A SEPARATE FILE. add-a-south-america-2-skills.sql inserts both rows
-- already tagged ["rifts"], which is what production keeps. On a clean build
-- that file sorts first, and fix-pf-armor-and-cross-system-gear.sql and
-- untag-cross-system.sql then set systems = NULL on EVERY skill; the re-tag in
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql names only the rows it knew about.
-- Without this file a rebuild would carry both rows untagged, production would
-- not, and regression's untagged pin would fail. Filename order is execution
-- order: this name sorts after the re-tag and after every z tier
-- (checked with the sort command in class-import), and after ~001-men-of-arms-frontmatter.sql, which does not touch skills.
--
-- Guarded on systems IS NULL, so a row someone has deliberately tagged since
-- is left alone, and in production (where the rows arrived tagged) this
-- changes nothing.

UPDATE skills SET systems = '["rifts"]'
 WHERE systems IS NULL
   AND name IN ('Art: Line Drawing', 'Riding: War Bison');

SELECT 'the two non-language skills are tagged Rifts' AS assertion,
       count(*) AS got,
       2 AS want
  FROM skills WHERE name IN ('Art: Line Drawing', 'Riding: War Bison') AND systems = '["rifts"]';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~002-south-america-2-skill-systems.sql');
