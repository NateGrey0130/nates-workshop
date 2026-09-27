-- Experience ladders for the Underseas classes, read off printed 214.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~014-underseas-xp-ladders.sql
--
-- WHAT WAS MISSING. Measured --remote 2026-09-26: all 25 live published
-- classes citing Rifts World Book 7: Underseas had no xp_table line (anchored
-- on a newline), so every one ran on DEFAULT_XP_TABLE (js/leveling.js).
--
-- READ OFF A RENDER. Printed 214 (PDF page 213, page_offset -1) was rendered
-- at 150 and 300 dpi and every column read off the image; a book-reconcile
-- agent re-rendered the page and re-read all ten columns independently and
-- found no disagreement. Each column heading names the classes it covers and
-- a class takes the column naming it. Two headings spell a class differently
-- from its entry: "Sea Inquisitioner" is sea-inquisitor and "Ocean Mage" is
-- ocean-wizard, both already recorded in those classes' notes. "Kreel-Lok
-- Warrior" is kreel-lok-nomad, the book's only Kreel-Lok class.
--
-- THE SURVEY'S TABLE WAS WRONG ABOUT ONE COLUMN: the Navy Seaman is not on
-- the Amphib / Navy Marine / Tritonian Scientist column. Printed 214 heads a
-- column "Navy Seaman, Salvage Expert, Kreel-Lok Warrior", and that is the
-- one stored for navy-seaman. docs/surveys/underseas.md is corrected in the
-- same change.
--
-- Stored as each band's LOWER bound, 0 first. Two printed lower bounds are
-- odd and still valid lower bounds, so they are stored as printed, the
-- convention ~008-rue-ju-xp-ladders.sql follows: the Pneuma Biform column's
-- level 5 (20,601, inside a level 4 band ending 20,700) and the Dragon Ray
-- column's level 5 (18,501, after a level 4 band ending 16,500). The Dragon
-- Ray column is NOT RUE's Psi-Stalker ladder, which it otherwise resembles: it
-- differs at levels 5, 11 and 13.
--
-- THE SEA TITAN. Its entry (printed 114) says "use the same tables as the
-- young and ancient dragon", which names two tables, and ~011-borrowed-xp-
-- ladders.sql left it unstored for that reason. Printed 214 also heads a
-- column "Sea Titan, Whale Singer". A column naming the class is the rule
-- this change follows, so sea-titan takes that column; its note is rewritten
-- to say so. If the dragon pointer is preferred, a later fix- replaces the line.
--
-- The Amphib's entry says to use the Amphib table or the chosen O.C.C.'s,
-- whichever is higher. The Amphib column is stored; an O.C.C.'s ladder already
-- wins a pairing, and the "higher" choice stays a restriction line.
--
-- NOT STORED: nothing. Gene-Splicer Mutants has a column and no class row
-- (docs/surveys/underseas.md).
--
-- MECHANICS. One xp_table line straight after each class's single "category:"
-- line, guarded on no xp_table LINE yet, so a second run changes nothing. The ~
-- tier sorts after every z- tier, so nothing rewrites these rows later.

-- "Horune Pirate, Naut'Yll Soldier"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'horune-pirate'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-soldier'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Amphib, Navy Marine, Tritonian Scientist"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'amphib'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'marine'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'tritonian-scientist'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Navy Seaman, Salvage Expert, Kreel-Lok Warrior"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 15001, 21501, 30501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'navy-seaman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 15001, 21501, 30501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'salvage-expert'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 15001, 21501, 30501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'kreel-lok-nomad'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Pneuma Biform: Dolphin, Pneuma Biform: Orca, Pneuma Biform: Whale"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2601, 5301, 10701, 20601, 30601, 41801, 61001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2601, 5301, 10701, 20601, 30601, 41801, 61001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-killer-whale'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2601, 5301, 10701, 20601, 30601, 41801, 61001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-whale'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Dragon Ray, Sperm Whale, Naut'Yll Devastator"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 18501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-ray'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 18501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sperm-whale'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 18501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-devastator'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Killer Whale, Rurlel Eelman"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'killer-whale'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rurlel-eelman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Sea Wolf, Sea Druid, Sea Inquisitioner"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'tritonian-sea-wolf'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sea-druid'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sea-inquisitor'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Ocean Mage, Naut'Yll Koral Shaper"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2421, 4841, 9621, 19201, 27401, 38501, 53001, 75601, 100701, 140801, 200901, 250401, 300501, 380601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ocean-wizard'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2421, 4841, 9621, 19201, 27401, 38501, 53001, 75601, 100701, 140801, 200901, 250401, 300501, 380601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-koral-shaper'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Dolphin, Humpback Whale, Gene-Splicer Mutants"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'dolphin'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'humpback-whale'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Sea Titan, Whale Singer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sea-titan'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'whale-singer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'experience table is the dragon''s.', 'entry names the dragon''s tables - two of them, young and ancient. Printed 214 also heads a column "Sea Titan, Whale Singer", and since 2026-09-26 xp_table carries that column (~014-underseas-xp-ladders.sql), the table that names this class.'), updated_at = datetime('now')
 WHERE class_id = 'sea-titan' AND instr(markdown, 'experience table is the dragon''s.') > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'horune' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('horune-pirate', 'nautyll-soldier')
   AND instr(markdown, char(10) || 'xp_table: [0, 1901, 3801, 7301, ') > 0 AND instr(markdown, ', 288001]' || char(10)) > 0;

SELECT 'amphib' AS a, count(*) AS got, 3 AS want FROM imported_classes
 WHERE class_id IN ('amphib', 'marine', 'tritonian-scientist')
   AND instr(markdown, char(10) || 'xp_table: [0, 1971, 3941, 7881, ') > 0 AND instr(markdown, ', 290881]' || char(10)) > 0;

SELECT 'seaman' AS a, count(*) AS got, 3 AS want FROM imported_classes
 WHERE class_id IN ('navy-seaman', 'salvage-expert', 'kreel-lok-nomad')
   AND instr(markdown, char(10) || 'xp_table: [0, 1926, 3851, 7451, ') > 0 AND instr(markdown, ', 300001]' || char(10)) > 0;

SELECT 'pneuma' AS a, count(*) AS got, 3 AS want FROM imported_classes
 WHERE class_id IN ('pneuma-biform-dolphin', 'pneuma-biform-killer-whale', 'pneuma-biform-whale')
   AND instr(markdown, char(10) || 'xp_table: [0, 2601, 5301, 10701, ') > 0 AND instr(markdown, ', 500001]' || char(10)) > 0;

SELECT 'dragonray' AS a, count(*) AS got, 3 AS want FROM imported_classes
 WHERE class_id IN ('dragon-ray', 'sperm-whale', 'nautyll-devastator')
   AND instr(markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, ') > 0 AND instr(markdown, ', 340501]' || char(10)) > 0;

SELECT 'killer' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('killer-whale', 'rurlel-eelman')
   AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8601, ') > 0 AND instr(markdown, ', 365001]' || char(10)) > 0;

SELECT 'seawolf' AS a, count(*) AS got, 3 AS want FROM imported_classes
 WHERE class_id IN ('tritonian-sea-wolf', 'sea-druid', 'sea-inquisitor')
   AND instr(markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, ') > 0 AND instr(markdown, ', 345001]' || char(10)) > 0;

SELECT 'ocean' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('ocean-wizard', 'nautyll-koral-shaper')
   AND instr(markdown, char(10) || 'xp_table: [0, 2421, 4841, 9621, ') > 0 AND instr(markdown, ', 380601]' || char(10)) > 0;

SELECT 'dolphin' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('dolphin', 'humpback-whale')
   AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 9001, ') > 0 AND instr(markdown, ', 425001]' || char(10)) > 0;

SELECT 'titan' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('sea-titan', 'whale-singer')
   AND instr(markdown, char(10) || 'xp_table: [0, 2501, 5001, 10001, ') > 0 AND instr(markdown, ', 440001]' || char(10)) > 0;

SELECT 'sea-titan note rewritten' AS a, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'sea-titan' AND instr(markdown, 'experience table is the dragon''s.') = 0 AND instr(markdown, '(~014-underseas-xp-ladders.sql)') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~014-underseas-xp-ladders.sql');
