-- Experience ladders for the fourteen Heroes Unlimited Power Category
-- classes, which stored none and so levelled on DEFAULT_XP_TABLE.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~028-hu-xp-ladders.sql
--
-- THE SOURCE. Heroes Unlimited Revised printed 17 (pdf page 17, cache p017,
-- page_offset 0), "EXPERIENCE LEVELS": ten columns, one per power category,
-- each headed "Level of Experience" over the category's name. Printed 16 says
-- "Each random power category has a listing for levels of experience." Read
-- off a 300 dpi render; do not read them off the cache, which runs the
-- right-hand page's columns together, drops level labels and reads 4 as "a",
-- 11 as "Il" and 15 as "1S". An independent book-reconcile pass re-read every
-- column from its own render and agreed on all 150 figures.
--
-- WHICH HALF CARRIES IT. A Heroes Unlimited character is a Power Category in
-- the R.C.C. slot crossed with an Educational Level in the O.C.C. slot
-- (survey D1). combineClasses (js/parser.js) takes xp_table from the
-- occupation when it states one and otherwise keeps the race's, so the
-- ladders go on the POWER CATEGORY classes and the sixteen education classes
-- (hu-edu-* and hu-alien-edu-*) state none: the book prints no ladder for an
-- education, and one there would override the category's. Physical Training
-- and the Special Training classes take no education at all (printed 27) and
-- level on these ladders alone.
--
-- COLUMN -> CLASS.
--   Alien                -> hu-aliens
--   Bionics and Implants -> hu-bionics
--   Experiments          -> hu-experiments
--   Hardware             -> hu-hardware
--   Magic                -> hu-magic
--   Mutants              -> hu-mutants
--   Physical Training    -> hu-physical-training
--   Psionics             -> hu-psionics
--   Robotics             -> hu-robotics
--   Special Training     -> hu-ancient-master, hu-hunter, hu-secret-operative,
--                           hu-stage-magician, hu-super-sleuth (the category's
--                           five sub-types, imported as five classes)
-- The sub-types of Hardware, Magic and Mutants print no column of their own,
-- so no variant needs a ladder; xp_table is not in VARIANT_OVERRIDES and does
-- not need to be.
--
-- Each figure is the LOWER bound of each band. The Alien column prints level 5
-- as "17,200 - 25,400", its lower bound repeating level 4's top of 17,200;
-- stored as 17,201, per fix-nb-race-xp-ladders.sql and #1406, and the class's
-- extraction_notes say so. Every other bound is printed one past the top of
-- the band before it.
--
-- MECHANICS. One xp_table line straight after each class's single
-- "category: rcc" line, guarded on no xp_table LINE yet, so a second run
-- changes nothing. The ~ tier sorts after every z- tier, so nothing rewrites
-- these rows later.

-- Alien
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Bionics and Implants
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2401, 4801, 9601, 19001, 27001, 37001, 52001, 72001, 96001, 131001, 180001, 229001, 278001, 337001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-bionics'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Experiments
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-experiments'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Hardware
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2301, 4601, 9201, 18401, 26801, 36901, 51101, 71201, 96301, 136401, 186501, 236601, 286701, 336801]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-hardware'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Mutants
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-mutants'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Physical Training
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-physical-training'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Robotics
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-robotics'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Magic
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-magic'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Psionics
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2201, 4401, 8801, 17701, 25701, 35701, 50701, 70701, 95701, 135701, 185701, 225701, 275701, 325701]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-psionics'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- Special Training
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-ancient-master'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-hunter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-secret-operative'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-stage-magician'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hu-super-sleuth'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- The Alien's note records its adjusted bound.
UPDATE imported_classes
   SET markdown = replace(markdown, 'extraction_notes: "AN ALIEN DOES NOT ROLL ON THE EDUCATIONAL LEVEL TABLE.', 'extraction_notes: "XP: stored 2026-09-27 as xp_table, printed 17''s column headed Alien, read off a render. It prints level 5 as 17,200 - 25,400, the lower bound repeating level 4''s top of 17,200; stored as 17,201. AN ALIEN DOES NOT ROLL ON THE EDUCATIONAL LEVEL TABLE.'), updated_at = datetime('now')
 WHERE class_id = 'hu-aliens' AND instr(markdown, 'extraction_notes: "AN ALIEN DOES NOT ROLL ON THE EDUCATIONAL LEVEL TABLE.') > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'alien' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-aliens') AND instr(markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, ') > 0 AND instr(markdown, ', 342401]' || char(10)) > 0;
SELECT 'bionics' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-bionics') AND instr(markdown, char(10) || 'xp_table: [0, 2401, 4801, 9601, ') > 0 AND instr(markdown, ', 337001]' || char(10)) > 0;
SELECT 'experiments' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-experiments') AND instr(markdown, char(10) || 'xp_table: [0, 2001, 4001, 8201, ') > 0 AND instr(markdown, ', 329401]' || char(10)) > 0;
SELECT 'hardware' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-hardware') AND instr(markdown, char(10) || 'xp_table: [0, 2301, 4601, 9201, ') > 0 AND instr(markdown, ', 336801]' || char(10)) > 0;
SELECT 'mutants' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-mutants') AND instr(markdown, char(10) || 'xp_table: [0, 2051, 4101, 8251, ') > 0 AND instr(markdown, ', 340501]' || char(10)) > 0;
SELECT 'physical' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-physical-training') AND instr(markdown, char(10) || 'xp_table: [0, 2141, 4281, 8561, ') > 0 AND instr(markdown, ', 341601]' || char(10)) > 0;
SELECT 'robotics' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-robotics') AND instr(markdown, char(10) || 'xp_table: [0, 2241, 4481, 8961, ') > 0 AND instr(markdown, ', 335921]' || char(10)) > 0;
SELECT 'magic' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-magic') AND instr(markdown, char(10) || 'xp_table: [0, 1951, 3901, 8801, ') > 0 AND instr(markdown, ', 325601]' || char(10)) > 0;
SELECT 'psionics' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('hu-psionics') AND instr(markdown, char(10) || 'xp_table: [0, 2201, 4401, 8801, ') > 0 AND instr(markdown, ', 325701]' || char(10)) > 0;
SELECT 'special' AS assertion, count(*) AS got, 5 AS want FROM imported_classes WHERE class_id IN ('hu-ancient-master', 'hu-hunter', 'hu-secret-operative', 'hu-stage-magician', 'hu-super-sleuth') AND instr(markdown, char(10) || 'xp_table: [0, 2121, 4241, 8481, ') > 0 AND instr(markdown, ', 329961]' || char(10)) > 0;
SELECT 'alien note' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, 'stored as 17,201. AN ALIEN') > 0;
SELECT 'no hu education ladder' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE system = 'heroes-unlimited' AND instr(markdown, char(10) || 'category: occ') > 0 AND instr(markdown, char(10) || 'xp_table:') > 0;
SELECT 'one xp line' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > 10;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~028-hu-xp-ladders.sql');
