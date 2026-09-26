-- The Men-Rall "Tech Master" R.C.C. (Rifts World Book 9: South America 2
-- printed 111-112) gets an I.S.P. pool.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-men-rall-isp-base.sql
--
-- The book makes the Men-Rall a major psionic with six powers and prints no
-- I.S.P. figure. add-men-rall-class.sql stored the tier and the powers and no
-- isp_base, so the sheet showed no pool for a class whose powers all cost
-- I.S.P. The standard figure for a major psionic
-- (apps/character-creator/js/psionics.js, PSIONIC_TIER_RULES.major - the
-- figure a rolled major psychic gets) applies only to psionics rolled on the
-- table, so it never reached this class. Nate's call, 2026-09-25: store that
-- standard figure, and say it is not printed in this book.
--
-- Guarded: the insert fires only while the class has no isp_base, and the note
-- rewrite only while the old sentence is present, so a second run changes
-- nothing. Sorts after add-men-rall-class.sql (f after a).

UPDATE imported_classes
   SET markdown = replace(markdown,
         'psionics:' || char(10) || '  type: "major"' || char(10),
         'psionics:' || char(10) || '  type: "major"' || char(10) || '  isp_base: "M.E. + 4d6, +1d6+1 per level"' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'men-rall'
   AND instr(markdown, 'isp_base:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book prints no I.S.P. figure and no powers gained at later levels, so neither isp_base nor a per-level grant is stored.',
         'The book prints no I.S.P. figure and no powers gained at later levels. isp_base is the standard major-psionic figure (M.E. + 4D6, +1D6+1 per level), which this book does not print, by Nate''s call on 2026-09-25 (fix-men-rall-isp-base.sql); no per-level power grant is stored.'),
       updated_at = datetime('now')
 WHERE class_id = 'men-rall'
   AND instr(markdown, 'so neither isp_base nor a per-level grant is stored') > 0;

SELECT 'the Men-Rall carries the standard major I.S.P.' AS assertion,
       count(*) AS got,
       1 AS want
  FROM imported_classes
 WHERE class_id = 'men-rall'
   AND instr(markdown, '  isp_base: "M.E. + 4d6, +1d6+1 per level"') > 0;

SELECT 'and its note says the figure is not printed' AS assertion,
       count(*) AS got,
       1 AS want
  FROM imported_classes
 WHERE class_id = 'men-rall'
   AND instr(markdown, 'which this book does not print') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-men-rall-isp-base.sql');
