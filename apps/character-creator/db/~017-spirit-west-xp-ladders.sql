-- Experience ladders for the Spirit West classes, read off printed 7.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~017-spirit-west-xp-ladders.sql
--
-- WHAT WAS MISSING. Measured --remote 2026-09-26: all 15 live published
-- classes citing Rifts World Book 15: Spirit West had no xp_table line
-- (anchored on a newline), so every one ran on DEFAULT_XP_TABLE
-- (js/leveling.js).
--
-- READ OFF A RENDER. Printed 7 (PDF page 8, page_offset 1) was rendered at
-- 150 and 250 dpi and every column read off the image; a book-reconcile agent
-- re-rendered the page and re-read every column independently and found no
-- disagreement. A class takes the column whose heading names it. The four
-- elemental-shaman rows (one printed class, three declared copies of
-- elemental-shaman-air) all take the "Elemental Shaman" column, so the copy
-- pairs stay equal. The columns for Man-Monsters, Great Little Ones,
-- Two-Faced Star People, Man-Eagles, Stone Giants and Black-Winged Monster Men
-- name NPCs (docs/surveys/spirit-west.md) and write nothing here.
--
-- Stored as each band's LOWER bound, 0 first. Every printed lower bound on
-- the page is the previous band's upper bound plus one; nothing is adjusted.
--
-- NOT STORED: nothing.
--
-- MECHANICS. One xp_table line straight after each class's single "category:"
-- line, guarded on no xp_table LINE yet, so a second run changes nothing. The ~
-- tier sorts after every z- tier, so nothing rewrites these rows later.

-- "Animal Shaman, Plant Shaman, Mystic Warror"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'animal-shaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'plant-shaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mystic-warrior'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Fetish Shaman, Mask Shaman, Man-Monsters (villians)"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 71801, 96901, 137001, 188101, 229201, 279301, 340401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'fetish-shaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 71801, 96901, 137001, 188101, 229201, 279301, 340401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mask-shaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Elemental Shaman"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-air'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-earth'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-fire'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-shaman-water'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Paradox Shaman"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 28501, 38501, 52001, 72001, 105001, 140001, 190001, 235001, 290001, 350001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Healing Shaman"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'healing-shaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Tribal Warrior"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'tribal-warrior'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Totem Warrior, Great Little Ones"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'totem-warrior'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Spirit Warrior, Two-Faced Star People"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'spirit-warrior'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Wendigo R.C.C."
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wendigo'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'animal' AS a, count(*) AS got, 3 AS want FROM imported_classes
 WHERE class_id IN ('animal-shaman', 'plant-shaman', 'mystic-warrior')
   AND instr(markdown, char(10) || 'xp_table: [0, 2241, 4481, 8961, ') > 0 AND instr(markdown, ', 335921]' || char(10)) > 0;

SELECT 'fetish' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('fetish-shaman', 'mask-shaman')
   AND instr(markdown, char(10) || 'xp_table: [0, 2301, 4601, 9201, ') > 0 AND instr(markdown, ', 340401]' || char(10)) > 0;

SELECT 'elemental' AS a, count(*) AS got, 4 AS want FROM imported_classes
 WHERE class_id IN ('elemental-shaman-air', 'elemental-shaman-earth', 'elemental-shaman-fire', 'elemental-shaman-water')
   AND instr(markdown, char(10) || 'xp_table: [0, 2141, 4281, 8561, ') > 0 AND instr(markdown, ', 341601]' || char(10)) > 0;

SELECT 'paradox' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('paradox-shaman')
   AND instr(markdown, char(10) || 'xp_table: [0, 2501, 5001, 10001, ') > 0 AND instr(markdown, ', 350001]' || char(10)) > 0;

SELECT 'healing' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('healing-shaman')
   AND instr(markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, ') > 0 AND instr(markdown, ', 340501]' || char(10)) > 0;

SELECT 'tribal' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('tribal-warrior')
   AND instr(markdown, char(10) || 'xp_table: [0, 1901, 3801, 7301, ') > 0 AND instr(markdown, ', 288001]' || char(10)) > 0;

SELECT 'totem' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('totem-warrior')
   AND instr(markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, ') > 0 AND instr(markdown, ', 340501]' || char(10)) > 0;

SELECT 'spirit' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('spirit-warrior')
   AND instr(markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, ') > 0 AND instr(markdown, ', 342401]' || char(10)) > 0;

SELECT 'wendigo' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('wendigo')
   AND instr(markdown, char(10) || 'xp_table: [0, 1951, 3901, 8801, ') > 0 AND instr(markdown, ', 325601]' || char(10)) > 0;

SELECT 'no xp_table line twice' AS a, count(*) AS got, 0 AS want FROM imported_classes
 WHERE length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > length(char(10) || 'xp_table:');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~017-spirit-west-xp-ladders.sql');
