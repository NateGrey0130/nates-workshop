-- The Knight (PF) has no bonus block at all (class audit F15, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-knight-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-knight-bonuses.sql
--
-- The book (PF, cache p087, re-read before writing): "3. Other O.C.C.
-- Bonuses: +1 on initiative, +2 to pull punch, and +1 to save vs horror
-- factor at levels 1, 3, 6, 8, 10 and 12." Production carried no bonuses:
-- key of any kind - the Palladin, printed beside it with the same shape,
-- has its full block including the HF schedule; the Knight was just
-- skipped. The level-1 horror factor point sits in the base saves block,
-- the rest on the at_level schedule.
--
-- Filename sort: fix-knight-bonuses > add-knight-class.sql, the only writer
-- of this region (fix-language-picks touches language lines only).
--
-- Safe to run twice: the second pass finds nothing to replace.

UPDATE imported_classes
SET markdown = replace(markdown,
      'starting_money: "110"' || char(10) || 'skills:',
      'starting_money: "110"' || char(10)
        || 'bonuses:' || char(10)
        || '  combat: { initiative: 1, pull_punch: 2 }' || char(10)
        || '  saves: { horror_factor: 1 }' || char(10)
        || '  at_level:' || char(10)
        || '    - { level: 3, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 6, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 8, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 10, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 12, saves: { horror_factor: 1 } }' || char(10)
        || 'skills:'),
    updated_at = datetime('now')
WHERE class_id = 'knight'
  AND instr(markdown, 'starting_money: "110"' || char(10) || 'skills:') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the class carries the whole bonus block
--   old_left     0 = starting_money no longer abuts skills:
--   cr_free      1 = the spliced newlines did not smuggle in a CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'knight'
          AND instr(markdown, 'bonuses:' || char(10) || '  combat: { initiative: 1, pull_punch: 2 }') > 0
          AND instr(markdown, '  saves: { horror_factor: 1 }') > 0
          AND instr(markdown, '    - { level: 12, saves: { horror_factor: 1 } }' || char(10) || 'skills:') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'knight'
          AND instr(markdown, 'starting_money: "110"' || char(10) || 'skills:') > 0) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'knight'
          AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-knight-bonuses.sql');
