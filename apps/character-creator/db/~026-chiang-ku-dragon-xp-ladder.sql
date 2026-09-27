-- The Chiang-Ku Dragon's experience ladder, which the class never stored.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~026-chiang-ku-dragon-xp-ladder.sql
--
-- Dragons and Gods printed 50, "Hatchling Dragon as an optional Player
-- Character": a hatchling uses "the dragon experience table presented in the
-- adult NPC section" - the Dragon Exp. Table, printed 17 (pdf page 18, cache
-- p018, page_offset 1), read off a render; the text layer agrees on every
-- figure. The book prints 30 levels; the fifteen lower bounds stored are
-- levels 1-15. The same list is stored on the three hatchlings added beside
-- this file and on the Rifts dragon-hatchling classes, whose table is the
-- same one.
--
-- MECHANICS. One xp_table line straight after the class's single
-- "category: rcc" line, guarded on no xp_table LINE yet, so a second run
-- changes nothing - the ~012 shape. The ~ tier sorts after every z- tier, so
-- nothing rewrites this row later.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Read the result back: the first four bounds and the last, and one line only.
SELECT 'chiang-ku ladder' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 3001, 5001, 10001, ') > 0 AND instr(markdown, ', 600001]' || char(10)) > 0;
SELECT 'one xp line' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE class_id = 'chiang-ku-dragon' AND length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > 10;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~026-chiang-ku-dragon-xp-ladder.sql');
