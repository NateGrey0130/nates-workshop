-- The Nightbane Sorcerer's Talents: one free Talent and never another, said so.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-nb-nightbane-sorcerer-talents.sql
--
-- Nightbane RPG printed 118 gives the Nightbane Sorcerer one Talent at first level
-- and no more. #1141 stored that as `talents_starting: 1` with no schedule and no
-- per-level count, which js/leveling.js read as a class that does not record its
-- per-level rule, so the sheet told the player to add Talents by hand. This adds
-- the explicit `talents_per_level: 0`, which leveling.js now reads as known and
-- empty. Guarded on the text it replaces, so a second run changes nothing.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'talents:' || char(10) || '  talents_starting: 1' || char(10) || 'extraction_notes:',
         'talents:' || char(10) || '  talents_starting: 1' || char(10) || '  talents_per_level: 0' || char(10) || 'extraction_notes:')
 WHERE class_id = 'nb-nightbane-sorcerer'
   AND instr(markdown, 'talents:' || char(10) || '  talents_starting: 1' || char(10) || 'extraction_notes:') > 0;

-- Read the result back.
SELECT 'the Nightbane Sorcerer states talents_per_level: 0 exactly once' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'nb-nightbane-sorcerer'
   AND instr(markdown, '  talents_starting: 1' || char(10) || '  talents_per_level: 0' || char(10)) > 0
   AND length(markdown) - length(replace(markdown, 'talents_per_level', '')) = length('talents_per_level');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-nb-nightbane-sorcerer-talents.sql');
