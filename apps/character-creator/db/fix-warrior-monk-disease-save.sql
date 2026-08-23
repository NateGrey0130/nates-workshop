-- The Warrior Monk's +1 to save vs disease now has a key to land on.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- a row, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-warrior-monk-disease-save.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-warrior-monk-disease-save.sql
--
-- Palladium Fantasy main book, the Warrior Monk, printed 71-74.
--
-- The class shipped saying "The +1 to save vs disease is printed and has no
-- save key in derive.js, so it stays in prose". That was true and stopped being
-- true: the `disease` key landed with the Palladium player races, because four
-- of them grant a bonus to it and a bonus written for a key derive.js does not
-- expose reaches nothing at all.
--
-- So this does two things, and the second is the smaller one. It moves the
-- number OUT of prose and into `bonuses`, where the sheet adds it up - and then
-- rewrites the sentence that explained why it could not be, because a note
-- describing a limitation that has been lifted is worse than no note.
--
-- The monk is the only published class carrying a disease bonus in prose. The
-- four races that also grant one were written after the key existed and state
-- it as a number already.
--
-- Guarded on the exact text, so re-running is a no-op and a row somebody has
-- since edited is left alone.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'saves: { possession: 4, illusionary_magic: 1, mind_control: 1 }',
         'saves: { possession: 4, illusionary_magic: 1, mind_control: 1, disease: 1 }')
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, 'saves: { possession: 4, illusionary_magic: 1, mind_control: 1 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The +1 to save vs disease is printed and has no save key in derive.js, so it stays in prose; the illusions, mind control and possession bonuses do have keys and are in `bonuses`.',
         'The +1 to save vs disease is in `bonuses` alongside the illusions, mind control and possession bonuses. It was prose until the `disease` save key landed with the Palladium player races; four of them grant one too.')
 WHERE class_id = 'warrior-monk'
   AND instr(markdown, 'has no save key in derive.js, so it stays in prose') > 0;


-- Read the result back rather than trusting the exit code. Both should be 1,
-- and the stale sentence 0.
SELECT
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'warrior-monk' AND instr(markdown, 'mind_control: 1, disease: 1') > 0) AS bonus_applied,
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'warrior-monk' AND instr(markdown, 'It was prose until the `disease` save key landed') > 0) AS note_rewritten,
  (SELECT count(*) FROM imported_classes
    WHERE class_id = 'warrior-monk' AND instr(markdown, 'has no save key in derive.js') > 0) AS stale_note_left;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-warrior-monk-disease-save.sql');
