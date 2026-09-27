-- Experience ladders for the New West classes, part 2 of 2: the columns
-- from Saddle Tramp / Preacher on, and the Mining 'Borg's borrowed ladder.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~016-new-west-xp-ladders-2.sql
--
-- ~015-new-west-xp-ladders.sql carries the header for both files: the source
-- (printed 223-224, read off renders and re-read by a book-reconcile agent),
-- the column-to-class mapping, the three printed bounds adjusted (two
-- repeats stored +1, and the Sky-Knight's level 12), the 'Borg copy and why fennodi is not stored. The split exists
-- only to keep each file's read-backs under the Windows command-line limit.
--
-- TWO copy_of LINES CHANGE. lyn-srial-cloudweaver and lyn-srial-sky-knight are
-- declared copy_of lyn-srial, and regression holds a copy pair equal outside
-- its except list. Printed 224 gives the three Lyn-Srial classes three
-- different columns (Average Citizen with the Cowboy, Cloudweaver with the
-- Psi-Slinger, Sky-Knight alone), so they legitimately differ on xp_table and
-- the key joins both except lists - the change ~008-rue-ju-xp-ladders.sql
-- made for euro-juicer. The four elemental-shaman rows need no such line:
-- they share one column.
--
-- MECHANICS. As part 1: one xp_table line after the single "category:" line,
-- guarded on no xp_table LINE yet, so a second run changes nothing. Each
-- copy_of line is replaced whole, guarded on the old line, so it too is a
-- no-op on a second run.

-- "Saddle Tramp, Preacher (either)"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1826, 3451, 6901, 13801, 19201, 29201, 39201, 49201, 70301, 99501, 130501, 180501, 230501, 280501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'saddle-tramp'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1826, 3451, 6901, 13801, 19201, 29201, 39201, 49201, 70301, 99501, 130501, 180501, 230501, 280501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'preacher'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Cowboy, Lyn-Srial Average Citizen"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21301, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cowboy'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21301, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Psi-Slinger, Lyn-Srial Cloudweaver"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 9601, 18201, 28401, 38601, 54801, 75201, 100401, 132601, 185801, 240201, 295401, 365601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'psi-slinger'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2151, 4301, 9601, 18201, 28401, 38601, 54801, 75201, 100401, 132601, 185801, 240201, 295401, 365601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-cloudweaver'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Cactus People R.C.C., Psi-Ponies (optional)"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1936, 3871, 7751, 15401, 20001, 30001, 40001, 60001, 80001, 110501, 140001, 180001, 230001, 280001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cactus-people'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 1936, 3871, 7751, 15401, 20001, 30001, 40001, 60001, 80001, 110501, 140001, 180001, 230001, 280001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'psi-pony'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Lyn-Srial Sky-Knight"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96001, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "Gunfighter"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 16801, 26001, 36401, 53001, 74001, 98001, 138001, 190001, 240001, 290001, 360001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Saloon Bum & Saloon Girl"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'saloon-bum'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186501, 236501, 286501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'saloon-girl'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- "Keepers of the Desert"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10) || 'xp_table: [0, 2111, 4221, 8441, 16881, 24881, 34881, 48441, 68441, 92481, 128481, 178481, 228881, 278881, 324481]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'keeper-of-the-desert'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- "the 'Borg tables, copied from combat-cyborg (RUE printed 295)"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mining-borg'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- The copy_of lines: xp_table joins the except list.
UPDATE imported_classes
   SET markdown = replace(markdown, 'copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions"] }', 'copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions", "xp_table"] }'), updated_at = datetime('now')
 WHERE class_id IN ('lyn-srial-cloudweaver', 'lyn-srial-sky-knight') AND instr(markdown, 'copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions"] }') > 0;

-- Read the result back: first four bounds and the last, per ladder.
SELECT 'tramp' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('saddle-tramp', 'preacher')
   AND instr(markdown, char(10) || 'xp_table: [0, 1826, 3451, 6901, ') > 0 AND instr(markdown, ', 280501]' || char(10)) > 0;

SELECT 'cowboy' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('cowboy', 'lyn-srial')
   AND instr(markdown, char(10) || 'xp_table: [0, 1901, 3801, 7301, ') > 0 AND instr(markdown, ', 288001]' || char(10)) > 0;

SELECT 'psi' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('psi-slinger', 'lyn-srial-cloudweaver')
   AND instr(markdown, char(10) || 'xp_table: [0, 2151, 4301, 9601, ') > 0 AND instr(markdown, ', 365601]' || char(10)) > 0;

SELECT 'cactus' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('cactus-people', 'psi-pony')
   AND instr(markdown, char(10) || 'xp_table: [0, 1936, 3871, 7751, ') > 0 AND instr(markdown, ', 280001]' || char(10)) > 0;

SELECT 'sky' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('lyn-srial-sky-knight')
   AND instr(markdown, char(10) || 'xp_table: [0, 2141, 4281, 8561, ') > 0 AND instr(markdown, ', 341601]' || char(10)) > 0;

SELECT 'gunfighter' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('gunfighter')
   AND instr(markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, ') > 0 AND instr(markdown, ', 360001]' || char(10)) > 0;

SELECT 'saloon' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('saloon-bum', 'saloon-girl')
   AND instr(markdown, char(10) || 'xp_table: [0, 1876, 3751, 7251, ') > 0 AND instr(markdown, ', 286501]' || char(10)) > 0;

SELECT 'keeper' AS a, count(*) AS got, 1 AS want FROM imported_classes
 WHERE class_id IN ('keeper-of-the-desert')
   AND instr(markdown, char(10) || 'xp_table: [0, 2111, 4221, 8441, ') > 0 AND instr(markdown, ', 324481]' || char(10)) > 0;

SELECT 'borg copy equals combat-cyborg' AS a, count(*) AS got, 1 AS want
  FROM imported_classes c, imported_classes s
 WHERE s.class_id = 'combat-cyborg' AND c.class_id IN ('mining-borg')
   AND instr(s.markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)) > 0
   AND instr(c.markdown, char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)) > 0;

SELECT 'copy_of except xp_table' AS a, count(*) AS got, 2 AS want FROM imported_classes
 WHERE class_id IN ('lyn-srial-cloudweaver', 'lyn-srial-sky-knight') AND instr(markdown, '"restrictions", "xp_table"] }') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~016-new-west-xp-ladders-2.sql');
