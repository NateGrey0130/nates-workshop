-- Experience ladders for the New West classes, read off printed 223-224.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~015-new-west-xp-ladders.sql
--
-- ONE CHANGE IN TWO FILES. This file stores the first seven columns (10
-- classes); ~016-new-west-xp-ladders-2.sql stores the rest (14 classes) and
-- the borrowed 'Borg ladder. The split only keeps each file's read-backs short:
-- d1-apply re-runs them as ONE command line, and Windows refuses one much over
-- 4,000 characters. This header describes both files, except the two
-- copy_of lines part 2 changes (lyn-srial-cloudweaver and -sky-knight), which
-- its own header explains.
--
-- WHAT WAS MISSING. Measured --remote 2026-09-26: all 25 live published
-- classes citing Rifts World Book 14: New West had no xp_table line (anchored
-- on a newline), so every one ran on DEFAULT_XP_TABLE (js/leveling.js).
--
-- READ OFF RENDERS. Printed 223-224 (PDF pages 224-225, page_offset 1) were rendered at
-- 150 and 250 dpi and every column read off the image. The text layer is one
-- the book-survey cipher warnings cover, and several cells on these pages are
-- set in a different face, so it was not used. A book-reconcile agent
-- re-rendered both pages and re-read all fifteen columns independently and
-- found no disagreement. A class takes the column whose heading names it:
--   Highwayman O.C.C. / Justice Ranger, 1st Cavalry  -> highwayman, justice-ranger
--   Saddle Tramp / Preacher (either)                 -> saddle-tramp, preacher
--   Cowboy / Lyn-Srial Average Citizen               -> cowboy, lyn-srial
--   Cactus People R.C.C. / Psi-Ponies (optional)     -> cactus-people, psi-pony
-- docs/surveys/new-west.md had four of these as "own" ladders; it is corrected
-- in the same change.
--
-- BORROWED (1 class). Printed 223: "CyberSlinger Cyborgs and Mining 'Borgs
-- use the 'Borg experience (E.P.) tables in the Rifts RPG." mining-borg copies
-- the 'Borg ladder combat-cyborg stores (RUE printed 295, the Combat Cyborg,
-- Headhunter & Robot Pilot column), the one kremin-cyborg copied in
-- ~011-borrowed-xp-ladders.sql (Nate, 2026-09-26: a class whose book says to
-- use another class's experience table copies that class's ladder). The
-- read-back holds the copy equal to its source row.
--
-- NOT STORED: fennodi. Printed 223: "Fennodi R.C.C. advance in experience as
-- per the O.C.C. selected." There is no ladder of its own to store, and an
-- O.C.C.'s ladder already wins a pairing.
--
-- Stored as each band's LOWER bound, 0 first. Three printed lower bounds are
-- not stored as printed:
--   Bounty Hunter & Mountain Giant level 5 (printed 16,880) and level 12
--   (printed 179,880) each repeat the previous band's upper bound and are
--   stored +1, per fix-nb-race-xp-ladders.sql.
--   Lyn-Srial Sky-Knight level 12 prints "18,301-231,400" - a dropped digit;
--   level 11 ends 181,300, so 181,301 is stored. (It is then the Euro-Juicer's
--   ladder, digit for digit.)
-- Two more are odd and still valid lower bounds, so they are stored as
-- printed: Bounty Hunter level 2 (2,111, inside a band ending 2,120) and
-- Professional Gambler level 4 (8,201, inside a band ending 8,440).
--
-- MECHANICS. One xp_table line straight after each class's single "category:"
-- line, guarded on no xp_table LINE yet, so a second run changes nothing. The ~
-- tier sorts after every z- tier, so nothing rewrites these rows later.

-- "Bounty Hunter O.C.C., Mountain Giant R.C.C."
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2111, 4221, 8441, 16881, 24881, 34881, 49881, 69881, 94881, 129881, 179881, 229881, 279881, 329881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'bounty-hunter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2111, 4221, 8441, 16881, 24881, 34881, 49881, 69881, 94881, 129881, 179881, 229881, 279881, 329881]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mountain-giant'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Bandit O.C.C."
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1861, 3601, 7001, 14401, 23401, 34401, 44401, 60401, 80401, 110401, 145401, 195401, 245401, 290401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'bandit'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Professional Gambler, Professional Thief & Smuggler"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2111, 4221, 8201, 16401, 23201, 32401, 48201, 68401, 92201, 127401, 178201, 228201, 278201, 328401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'professional-gambler'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Highwayman O.C.C., Justice Ranger, 1st Cavalry"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'highwayman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'justice-ranger'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Sheriff's Deputy"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 22801, 34301, 45801, 70301, 92801, 122301, 148001, 185801, 245301, 290801]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sheriffs-deputy'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Gunslinger, Wired-Gunslinger"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2161, 4321, 8641, 18001, 27001, 38501, 54701, 77001, 100301, 140501, 210001, 250701, 325001, 395501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gunslinger'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2161, 4321, 8641, 18001, 27001, 38501, 54701, 77001, 100301, 140501, 210001, 250701, 325001, 395501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Sherriff/Lawman"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2026, 4051, 8101, 16301, 25501, 35701, 50001, 70201, 95001, 130001, 180201, 230001, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'sheriff-lawman'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'bounty' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('bounty-hunter', 'mountain-giant')
   AND instr(markdown, char(10) || 'xp_table: [0, 2111, 4221, 8441, ') > 0 AND instr(markdown, ', 329881]' || char(10)) > 0;

SELECT 'bandit' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('bandit')
   AND instr(markdown, char(10) || 'xp_table: [0, 1861, 3601, 7001, ') > 0 AND instr(markdown, ', 290401]' || char(10)) > 0;

SELECT 'gambler' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('professional-gambler')
   AND instr(markdown, char(10) || 'xp_table: [0, 2111, 4221, 8201, ') > 0 AND instr(markdown, ', 328401]' || char(10)) > 0;

SELECT 'highway' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('highwayman', 'justice-ranger')
   AND instr(markdown, char(10) || 'xp_table: [0, 2001, 4001, 8201, ') > 0 AND instr(markdown, ', 329401]' || char(10)) > 0;

SELECT 'deputy' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('sheriffs-deputy')
   AND instr(markdown, char(10) || 'xp_table: [0, 1901, 3801, 7301, ') > 0 AND instr(markdown, ', 290801]' || char(10)) > 0;

SELECT 'gunslinger' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('gunslinger', 'wired-gunslinger')
   AND instr(markdown, char(10) || 'xp_table: [0, 2161, 4321, 8641, ') > 0 AND instr(markdown, ', 395501]' || char(10)) > 0;

SELECT 'sheriff' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('sheriff-lawman')
   AND instr(markdown, char(10) || 'xp_table: [0, 2026, 4051, 8101, ') > 0 AND instr(markdown, ', 340501]' || char(10)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~015-new-west-xp-ladders.sql');
