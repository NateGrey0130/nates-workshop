-- Tags Rifts Conversion Book One's Hand to Hand: Skudasa with its game, AFTER
-- the scripts that clear and re-tag skills.systems.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~023-cb1-skudasa-skill-systems.sql
--
-- WHY A SEPARATE FILE - the ~002 South America 2 reason. The row arrives
-- tagged ["rifts"] from add-cb1-skudasa-and-chant-of-dreaming.sql, which is
-- what production keeps. On a clean build that file sorts first, and
-- fix-pf-armor-and-cross-system-gear.sql and untag-cross-system.sql then set
-- systems = NULL on EVERY skill; the re-tag in
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql names only the rows it knew about.
-- Without this file a rebuild carries the row untagged and regression's
-- untagged pin fails. ~023 is the next free tilde number (the sort command in
-- class-import, 2026-09-27): after the re-tag, every z tier and ~001-~022.
--
-- Guarded on systems IS NULL, so in production (where the row arrived tagged)
-- this changes nothing.

UPDATE skills SET systems = '["rifts"]'
 WHERE systems IS NULL
   AND name = 'Hand to Hand: Skudasa';

SELECT 'skudasa is tagged Rifts' AS assertion,
       count(*) AS got,
       1 AS want
  FROM skills WHERE name = 'Hand to Hand: Skudasa' AND systems = '["rifts"]';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~023-cb1-skudasa-skill-systems.sql');
