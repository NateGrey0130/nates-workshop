-- The Crazy heals like a Vagabond: 1D6 Hit Points where the book gives 5D6,
-- and the +1D6 P.E. is gone (class audit F4, 2026-08-25).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-crazy-super-endurance.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-crazy-super-endurance.sql
--
-- The book (RUE printed p.55, "1. Super Endurance"): "Add 3D6x10 to S.D.C.,
-- add 5D6 to Hit Points, and +1D6 to P.E. attribute." The class's own
-- special_abilities prose already quotes that line correctly; only the
-- frontmatter disagrees with it:
--
--   pools.hp: "1d6"      the book says 5D6 - a Crazy was gaining Hit Points
--                        at a Vagabond's rate.
--   (no PE)              the +1D6 P.E. was dropped from the attributes line
--                        entirely.
--
-- Everything else in the block - PS 2d4 (min 19), PP 1d6 (min 17), Spd 4d6,
-- initiative/attacks/roll, and all five save lines - was verified correct by
-- the audit and stays.
--
-- Filename sort: fix-crazy-super-endurance > add-crazy-class, the only
-- script that writes this block, so a clean rebuild applies them in the
-- right order. The later crazy-touching scripts (fix-language-picks, the
-- zz- notes) edit language lines and occ_group, never these two lines.
--
-- Safe to run twice: the second pass finds nothing to replace.

UPDATE imported_classes
SET markdown = replace(markdown,
      '  pools: { sdc: "3d6x10", hp: "1d6" }',
      '  pools: { sdc: "3d6x10", hp: "5d6" }'),
    updated_at = datetime('now')
WHERE class_id = 'crazy'
  AND instr(markdown, '  pools: { sdc: "3d6x10", hp: "1d6" }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  attributes: { PS: "2d4", Spd: "4d6", PP: "1d6" }',
      '  attributes: { PS: "2d4", Spd: "4d6", PP: "1d6", PE: "1d6" }'),
    updated_at = datetime('now')
WHERE class_id = 'crazy'
  AND instr(markdown, '  attributes: { PS: "2d4", Spd: "4d6", PP: "1d6" }') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the class carries hp 5d6 and the PE die
--   old_left     0 = no trace of hp "1d6" or the PE-less attributes line
--   cr_free      1 = still no CR anywhere in the markdown
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'crazy' AND instr(markdown, '  pools: { sdc: "3d6x10", hp: "5d6" }') > 0 AND instr(markdown, '  attributes: { PS: "2d4", Spd: "4d6", PP: "1d6", PE: "1d6" }') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'crazy' AND (instr(markdown, 'hp: "1d6"') > 0 OR instr(markdown, 'PP: "1d6" }' || char(10) || '  attribute_minimums') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'crazy' AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-crazy-super-endurance.sql');
