-- Experience ladders printed in Rifts World Book 5: Triax and the NGR for its
-- fifteen O.C.C.s, which stored none.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~013-triax-xp-ladders.sql
--
-- THE DECISIONS are ~012-cwc-fq-xp-ladders.sql's: a class carries the ladder
-- its own book prints for it (Nate, 2026-09-17), and a class whose book says
-- "use X's experience table" copies X's (Nate, 2026-09-26). This file is the
-- second half of that change, split off only to keep each file's read-backs
-- short enough for one Windows command line.
--
-- Triax printed 224 (pdf page 224, page_offset 0), "Experience Tables", read
-- off a 300 dpi render of each column; the book is a scan with no text layer.
-- Each figure is the LOWER bound of each band. Column heading -> class:
--   "Combat Soldier & Police/Enforcement": ngr-infantry-soldier, ngr-police.
--     Its figures equal Wormwood's goblin ladder (~010).
--   "Communications Officer, Medic/Medical Officer, Field Mechanic O.C.C.":
--     ngr-communications-officer, ngr-medical-officer, ngr-field-mechanic
--   "Cyborg Soldier": ngr-cyborg-soldier
--   "Power Armor Commando": ngr-power-armor-commando. Its figures equal CWC
--     printed 224's Psi-Net Agent and Special Forces column.
--   "Robot Combat Pilot": ngr-robot-combat-pilot
--   "Robot Soldier": ngr-robot-soldier
--   "Intelligence Officer": ngr-intelligence-officer
--   "Intelligence Commando": ngr-intelligence-commando
--   "Gypsy Thief": gypsy-thief
--   "Gypsy Wizard Thief": gypsy-wizard-thief
--   "Gypsy Seer": gypsy-seer
--   "Gypsy - The Gifted": gypsy-gifted
-- The sixteenth column, "Euro-Juicer", has been stored on euro-juicer since
-- ~010. Every lower bound on the page is the previous top plus one.
--
-- MECHANICS. One xp_table line straight after each class's single
-- "category: occ" line, guarded on no xp_table LINE yet, so a second run
-- changes nothing. No note on these classes said a ladder was not stored.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-infantry-soldier'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-police'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-communications-officer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-medical-officer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 15001, 21501, 31501, 41501, 54001, 75001, 105001, 140001, 190001, 240001, 300001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-field-mechanic'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 18601, 26601, 36601, 54601, 75601, 99601, 135601, 185601, 240601, 290601, 343601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-cyborg-soldier'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-power-armor-commando'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2251, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 300501, 400501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-combat-pilot'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-intelligence-officer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-intelligence-commando'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2701, 5401, 10801, 21601, 31601, 42801, 62001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'combatsoldier' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('ngr-infantry-soldier', 'ngr-police') AND instr(markdown, char(10) || 'xp_table: [0, 1971, 3941, 7881, ') > 0 AND instr(markdown, ', 290881]' || char(10)) > 0;
SELECT 'commsmedic' AS assertion, count(*) AS got, 3 AS want FROM imported_classes WHERE class_id IN ('ngr-communications-officer', 'ngr-medical-officer', 'ngr-field-mechanic') AND instr(markdown, char(10) || 'xp_table: [0, 1926, 3851, 7451, ') > 0 AND instr(markdown, ', 300001]' || char(10)) > 0;
SELECT 'cyborg' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ngr-cyborg-soldier') AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8601, ') > 0 AND instr(markdown, ', 343601]' || char(10)) > 0;
SELECT 'pacommando' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ngr-power-armor-commando') AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 8801, ') > 0 AND instr(markdown, ', 345901]' || char(10)) > 0;
SELECT 'robotpilot' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ngr-robot-combat-pilot') AND instr(markdown, char(10) || 'xp_table: [0, 2251, 4401, 8801, ') > 0 AND instr(markdown, ', 400501]' || char(10)) > 0;
SELECT 'robotsoldier' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ngr-robot-soldier') AND instr(markdown, char(10) || 'xp_table: [0, 2501, 5001, 10001, ') > 0 AND instr(markdown, ', 440001]' || char(10)) > 0;
SELECT 'intelofficer' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ngr-intelligence-officer') AND instr(markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, ') > 0 AND instr(markdown, ', 345001]' || char(10)) > 0;
SELECT 'intelcommando' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('ngr-intelligence-commando') AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 8601, ') > 0 AND instr(markdown, ', 365001]' || char(10)) > 0;
SELECT 'gypsythief' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('gypsy-thief') AND instr(markdown, char(10) || 'xp_table: [0, 1901, 3801, 7301, ') > 0 AND instr(markdown, ', 288001]' || char(10)) > 0;
SELECT 'wizardthief' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('gypsy-wizard-thief') AND instr(markdown, char(10) || 'xp_table: [0, 2701, 5401, 10801, ') > 0 AND instr(markdown, ', 500001]' || char(10)) > 0;
SELECT 'seer' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('gypsy-seer') AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 9001, ') > 0 AND instr(markdown, ', 425001]' || char(10)) > 0;
SELECT 'gifted' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('gypsy-gifted') AND instr(markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, ') > 0 AND instr(markdown, ', 340501]' || char(10)) > 0;
SELECT 'one xp line' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > 10;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~013-triax-xp-ladders.sql');
