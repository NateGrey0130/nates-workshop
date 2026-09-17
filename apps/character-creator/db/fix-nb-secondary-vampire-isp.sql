-- The Secondary Vampire's I.S.P.: a house figure, 2D6x10, because the book prints none.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-nb-secondary-vampire-isp.sql
--
-- Nightbane RPG printed 181-182 calls the Secondary Vampire a major psionic and gives
-- it the vampire powers, but prints no I.S.P. line (a render of printed 182 confirms
-- it). #1138 left isp_base out, so the class had powers and no pool to spend them from.
-- Nate (2026-09-17, the Nightbane survey's follow-up decisions) chose 2D6x10 - between
-- the Wild Vampire's 1D6x10 (printed 183) and the Master's 3D6x10 (printed 180), as its
-- rank sits between them - marked as a house figure in the class's own notes.
--
-- Two guarded replaces, each keyed on the exact text it changes, so a second run is a
-- no-op: the psionics block gains isp_base, and the extraction note stops saying the
-- pool is absent.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'psionics:' || char(10) || '  type: "major"' || char(10) || '  powers:',
         'psionics:' || char(10) || '  type: "major"' || char(10) || '  isp_base: "2d6x10"' || char(10) || '  powers:')
 WHERE class_id = 'nb-secondary-vampire'
   AND instr(markdown, 'psionics:' || char(10) || '  type: "major"' || char(10) || '  powers:') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'isp_base is absent rather than borrowed from the Master.',
         'isp_base is a HOUSE FIGURE, 2D6x10, between the Wild Vampire and the Master (Nate, 2026-09-17); the book prints none.')
 WHERE class_id = 'nb-secondary-vampire'
   AND instr(markdown, 'isp_base is absent rather than borrowed from the Master.') > 0;

-- Read the result back.
SELECT 'the Secondary Vampire states isp_base 2d6x10 and calls it a house figure' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'nb-secondary-vampire'
   AND instr(markdown, '  type: "major"' || char(10) || '  isp_base: "2d6x10"' || char(10)) > 0
   AND instr(markdown, 'isp_base is a HOUSE FIGURE, 2D6x10') > 0
   AND instr(markdown, 'isp_base is absent rather than borrowed') = 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-nb-secondary-vampire-isp.sql');
