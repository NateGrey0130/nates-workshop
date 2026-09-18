-- The Body Fixer lists Outdoorsmanship once, not twice. RUE printed p.87
-- (scan file .cache/books/rue/txt/p090.txt).
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- a class row, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-body-fixer-single-outdoorsmanship.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-body-fixer-single-outdoorsmanship.sql
--
-- add-body-fixer-class.sql carried Outdoorsmanship twice in occ_skills, the
-- second copy between W.P. Knife and Xenology with the note "duplicate listing
-- in source", and an extraction note keeping both "as this may reflect an
-- actual duplication in the source". The source does not print it twice. The
-- page, read from the cache and from a render of PDF page 90 on 2026-09-18,
-- lists Outdoorsmanship once, between Medical Doctor (+20%) and Pathology
-- (+30%), and runs straight from W.P. Knife to Xenology. So the second copy is
-- not a misread of some other skill; it is a copy, and dropping it loses
-- nothing.
--
-- It was not harmless. validate-character.js refuses a character holding one
-- skill twice (duplicate_skill, HTTP 422), and the wizard's skillsAtLevelOne()
-- maps every fixed occ skill one to one, so no Body Fixer could be saved
-- through the wizard. The NPC generator's class sweep found it on 2026-09-18.
--
-- No filename-order hazard: none of the scripts that sort after this one and
-- touch body-fixer anchors on either line it removes.

-- The duplicate row. Guarded on its own text, so re-running is a no-op.
UPDATE imported_classes
   SET markdown = replace(markdown, '    - { name: "Outdoorsmanship", base: 0, per_level: 0, note: "duplicate listing in source" }
', '')
 WHERE class_id = 'body-fixer'
   AND instr(markdown, '    - { name: "Outdoorsmanship", base: 0, per_level: 0, note: "duplicate listing in source" }') > 0;

-- The extraction note that kept it. Replaced with what the page shows.
UPDATE imported_classes
   SET markdown = replace(markdown, '  - Outdoorsmanship appears twice in the printed O.C.C. Skills list; both
    instances preserved as this may reflect an actual duplication in the
    source rather than a misread.
', '  - Outdoorsmanship is printed once, between Medical Doctor and Pathology.
    The original import carried a second copy, which made every Body Fixer
    fail duplicate_skill on save; removed by
    fix-body-fixer-single-outdoorsmanship.sql.
')
 WHERE class_id = 'body-fixer'
   AND instr(markdown, 'Outdoorsmanship appears twice in the printed') > 0;

-- Read the result back rather than trusting the exit code. d1-apply enforces
-- these assertion rows on the target and in its scratch replay.
SELECT 'body-fixer lists Outdoorsmanship once' AS assertion,
       (length(markdown) - length(replace(markdown, '{ name: "Outdoorsmanship"', ''))) / length('{ name: "Outdoorsmanship"') AS got,
       1 AS want
  FROM imported_classes WHERE class_id = 'body-fixer';
SELECT 'the stale extraction note is gone' AS assertion,
       instr(markdown, 'appears twice in the printed') AS got,
       0 AS want
  FROM imported_classes WHERE class_id = 'body-fixer';
SELECT 'the corrected note names this file' AS assertion,
       instr(markdown, 'fix-body-fixer-single-outdoorsmanship.sql') > 0 AS got,
       1 AS want
  FROM imported_classes WHERE class_id = 'body-fixer';
SELECT 'no CR in the class' AS assertion,
       instr(markdown, char(13)) AS got,
       0 AS want
  FROM imported_classes WHERE class_id = 'body-fixer';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-body-fixer-single-outdoorsmanship.sql');
