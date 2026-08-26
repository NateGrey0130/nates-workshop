-- The Operator has no bonus block at all (class audit F7, 2026-08-25).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-operator-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-operator-bonuses.sql
--
-- The book (RUE printed 92, "O.C.C. Bonuses", re-read from the OCR cache):
-- "+1 to I.Q., +2 to P.S. and +1 to P.P. attributes, +2 on Perception Rolls,
-- +2 to save vs fatigue and disease, and +2D6+6 to S.D.C." Production
-- carries no bonuses: key of any kind, so an Operator got none of it.
--
-- The +2 vs fatigue is why this PR also adds a `fatigue` save key to
-- derive.js and sheet.js - the key did not exist, and a bonus written to a
-- key nothing reads is a number that reaches nothing (the same reason
-- illusionary_magic, curses, disease and faerie_magic joined the map).
--
-- Filename sort: fix-operator-bonuses > add-operator-class, the only script
-- that writes this region; fix-language-picks (language lines) and
-- zz-rifts-occ-groups (occ_group) touch other regions.
--
-- Safe to run twice: the second pass finds nothing to replace.

UPDATE imported_classes
SET markdown = replace(markdown,
      'starting_money: "4d4x1000"' || char(10) || 'skills:',
      'starting_money: "4d4x1000"' || char(10)
        || 'bonuses:' || char(10)
        || '  attributes: { IQ: 1, PS: 2, PP: 1 }' || char(10)
        || '  combat: { perception: 2 }' || char(10)
        || '  saves: { fatigue: 2, disease: 2 }' || char(10)
        || '  pools: { sdc: "2d6+6" }' || char(10)
        || 'skills:'),
    updated_at = datetime('now')
WHERE class_id = 'operator'
  AND instr(markdown, 'starting_money: "4d4x1000"' || char(10) || 'skills:') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the class carries the whole bonus block
--   old_left     0 = starting_money no longer abuts skills:
--   cr_free      1 = the spliced newlines did not smuggle in a CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'operator'
          AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { IQ: 1, PS: 2, PP: 1 }') > 0
          AND instr(markdown, '  combat: { perception: 2 }') > 0
          AND instr(markdown, '  saves: { fatigue: 2, disease: 2 }') > 0
          AND instr(markdown, '  pools: { sdc: "2d6+6" }' || char(10) || 'skills:') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'operator'
          AND instr(markdown, 'starting_money: "4d4x1000"' || char(10) || 'skills:') > 0) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'operator' AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-operator-bonuses.sql');
