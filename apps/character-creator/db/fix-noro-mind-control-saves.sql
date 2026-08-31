-- The two noro O.C.C.s were shipped without the mind-control save the book
-- gives them, because the import said the sheet had no field for it. It does.
--
-- One-off data correction, run once per environment. NOT a migration - it
-- changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-noro-mind-control-saves.sql
--
-- WHAT WENT WRONG. add-noro-psychic-class.sql and
-- add-noro-mystic-warrior-class.sql (PR #409) both carry an extraction note
-- saying "the sheet has a psionics save and a horror factor save and nothing
-- for mind control", and both therefore stored only the bonuses that fit and
-- left the mind-control figure as prose. That claim is FALSE.
--
-- `mind_control` is a real save key. `js/derive.js` reads it, and five
-- published classes were already using it when this was written - the juicer at
-- +6, the mind melter, the mystic, and both ley line classes at +2. The claim
-- was asserted from memory of the frontmatter reference, which lists
-- `spell_magic`, `psionics` and `horror_factor` as EXAMPLES and says outright
-- that combat and saves are OPEN SETS.
--
-- This is exactly the failure the class-import skill warns about under
-- "unmodelled keys": CHECK THE REPORT BEFORE ACTING ON IT, and grep for the key
-- across js/ and functions/ before believing it is missing. The same rule
-- applies to concluding a key does not exist, which is the direction it failed
-- in here. One grep would have caught it.
--
-- WHAT IT COST. A Noro Psychic was short +3 to save vs any type of mind
-- control, and a Noro Mystic Warrior short +2 to save vs all forms of it. Both
-- are printed in the books' own bonus lists. Nothing failed - the classes
-- parse, validate and compose - which is why it needed reading rather than
-- testing to find.
--
-- The other half of each note is still correct and is left alone: neither class
-- states an S.D.C. or hit point formula, and the psionics and horror-factor
-- figures were stored correctly.
--
-- Guarded on the exact text it replaces, so re-running is a no-op and a row
-- someone has already corrected by hand is left alone.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'saves: { psionics: 2, horror_factor: 3 }',
         'saves: { psionics: 2, horror_factor: 3, mind_control: 3 }')
 WHERE class_id = 'noro-psychic'
   AND instr(markdown, 'saves: { psionics: 2, horror_factor: 3 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'saves: { horror_factor: 4 }',
         'saves: { horror_factor: 4, mind_control: 2 }')
 WHERE class_id = 'noro-mystic-warrior'
   AND instr(markdown, 'saves: { horror_factor: 4 }') > 0;

-- And correct the extraction note on each, so the next reader is not told a
-- false thing about the schema. Guarded the same way.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE +3 SAVE VS MIND CONTROL IS NOT STORED. The book''s bonus line is "+2 to',
         'ALL THREE SAVE BONUSES ARE STORED. The book''s bonus line is "+2 to')
 WHERE class_id = 'noro-psychic'
   AND instr(markdown, 'THE +3 SAVE VS MIND CONTROL IS NOT STORED.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'horror factor". The sheet has a psionics save and a horror factor save and
    no mind-control save, so the psionics and horror factor figures are in
    `bonuses` and the mind-control one is here. It is a real +3 the character
    should get and the app cannot show it.',
         'horror factor", and `bonuses.saves` holds all three - `mind_control` is a
    real key that js/derive.js reads. This class shipped without it in PR #409
    on an assertion that the sheet had no such field, corrected by
    fix-noro-mind-control-saves.sql.')
 WHERE class_id = 'noro-psychic'
   AND instr(markdown, 'no mind-control save, so the psionics and horror factor figures are in') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE +2 SAVE VS ALL FORMS OF MIND CONTROL IS NOT STORED, for the same reason
    it is not stored on the noro psychic: the sheet has no mind-control save. The
    +1 initiative and +4 vs horror factor are in `bonuses`.',
         'ALL THREE BONUSES ARE STORED: +1 initiative, +4 vs horror factor and +2 vs
    all forms of mind control. This class shipped without the last of them in
    PR #409 on an assertion that the sheet had no mind-control field - it does,
    and js/derive.js reads it. Corrected by fix-noro-mind-control-saves.sql.')
 WHERE class_id = 'noro-mystic-warrior'
   AND instr(markdown, 'THE +2 SAVE VS ALL FORMS OF MIND CONTROL IS NOT STORED') > 0;

-- Read the result back rather than trusting the exit code. Both should now be 1.
SELECT class_id,
       instr(markdown, 'mind_control') > 0 AS has_mind_control_save,
       instr(markdown, 'IS NOT STORED') > 0 AS still_claims_it_cannot
  FROM imported_classes
 WHERE class_id IN ('noro-psychic', 'noro-mystic-warrior')
 ORDER BY class_id;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-noro-mind-control-saves.sql');
