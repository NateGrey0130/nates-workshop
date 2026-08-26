-- The Juicer's "+2 to disarm" is missing, and three Juicer Uprising
-- sub-classes copied the gap (class audit F14, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-juicer-disarm.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-juicer-disarm.sql
--
-- The book (RUE printed 79, re-read from the OCR cache): "+2 attacks per
-- melee round, +4 on initiative, +2 on Perception Rolls, +2 to disarm, +2 to
-- pull punch, +3 to roll with impact". The juicer's perception landed in F8
-- (fix-perception-bonuses.sql); this adds the disarm - and the three Juicer
-- Uprising sub-classes (gladiator, assassin, scout), whose notes say they
-- deliberately carry "the standard Juicer's numbers", get both keys so they
-- still do. The juicer note F8 wrote ("+2 disarm is not yet applied") is
-- rewritten in the same script now that it is.
--
-- Filename sort: fix-rue-juicer-disarm > fix-perception-bonuses (whose
-- output the juicer guards below expect), > fix-juicer-rue-edition (the
-- last writer of the juicer's block before F8), and > the add-juicer-*
-- scripts that write the sub-classes.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2, perception: 2 }',
      '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2, perception: 2, disarm: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2, perception: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }',
      '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2, perception: 2, disarm: 2 }'),
    updated_at = datetime('now')
WHERE class_id IN ('juicer-gladiator', 'juicer-assassin', 'juicer-scout')
  AND instr(markdown, '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - The +2 Perception is modeled as combat.perception (class audit F8). The' || char(10)
        || '    +2 disarm is not yet applied (F14 covers it with the Juicer sub-classes);' || char(10)
        || '    the auto-dodge progression stays prose in the Super-Reflexes description.',
      '  - The +2 Perception and +2 disarm are modeled in combat (class audit' || char(10)
        || '    F8/F14); the auto-dodge progression stays prose in the Super-Reflexes' || char(10)
        || '    description.'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, '    +2 disarm is not yet applied (F14 covers it with the Juicer sub-classes);') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        4 = all four classes carry disarm and perception
--   note_ok      1 = the juicer's note says both are modeled
--   old_left     0 = no pre-fix combat line or stale note text left
--   cr_free      4 = all four touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('juicer', 'juicer-gladiator', 'juicer-assassin', 'juicer-scout')
            AND instr(markdown, 'pull_punch: 2, perception: 2, disarm: 2 }') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'juicer'
          AND instr(markdown, 'The +2 Perception and +2 disarm are modeled in combat') > 0) AS note_ok,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('juicer', 'juicer-gladiator', 'juicer-assassin', 'juicer-scout')
            AND (instr(markdown, 'roll: 3, pull_punch: 2 }') > 0
              OR instr(markdown, 'perception: 2 }') > 0
              OR instr(markdown, 'not yet applied') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('juicer', 'juicer-gladiator', 'juicer-assassin', 'juicer-scout')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-juicer-disarm.sql');
