-- The four psychic classes said the app gets the master save target wrong.
-- It no longer does.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-psychic-save-target-notes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-psychic-save-target-notes.sql
--
-- add-psychic-sensitive-class.sql, add-psi-healer-class.sql,
-- add-psi-mystic-class.sql and add-mind-mage-class.sql each shipped with a
-- restriction and an extraction note saying that the book gives a master
-- psionic a save target of 10 while js/derive.js hands out 12. That was true
-- when they were written and is now false: derive.js carries the full
-- three-tier table, 15 for a non-psychic, 12 for minor and major, 10 for a
-- master.
--
-- A note describing a bug that has been fixed is worse than no note. It sends
-- the next reader looking for a discrepancy that is not there.
--
-- WHY THIS IS A NEW FILE RATHER THAN AN EDIT to those four. An applied script
-- is never edited - a rebuild has to produce what production actually got, in
-- the order it got it. 'fix-' sorts after 'add-', so a clean rebuild lays down
-- the original four and then corrects them here, which is exactly the sequence
-- production went through.
--
-- Three substitutions cover all four classes: the restriction line is
-- byte-identical in every one, and the extraction note comes in two wordings.
-- Every UPDATE is guarded on the old text still being present, so this is safe
-- to run twice and cannot touch a class somebody has since rewritten.

-- ---- 1. the restriction line, identical in all four -------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         'As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus. The app currently derives 12 for every major-or-better psychic; see extraction_notes.',
         'As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus.')
 WHERE class_id IN ('psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage')
   AND instr(markdown, 'The app currently derives 12 for every major-or-better psychic') > 0;

-- ---- 2. the extraction note, wording used by three of them ------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
         'MASTER PSIONIC SAVE TARGET: the book says 10 or higher and derive.js returns 12 for anything major or better - an app-level gap affecting every existing master psionic in Rifts too, not something this import changes.',
         'MASTER PSIONIC SAVE TARGET: 10 or higher, which the app now derives correctly - the psionic save table was three tiers all along and derive.js only had two.')
 WHERE class_id IN ('psi-healer', 'psi-mystic', 'mind-mage')
   AND instr(markdown, 'an app-level gap affecting every existing master psionic in Rifts too') > 0;

-- ---- 3. the extraction note, the Psychic Sensitive's longer wording ---------
UPDATE imported_classes
   SET markdown = replace(markdown,
         'MASTER PSIONIC SAVE TARGET: the book says a master psionic saves on 10 or higher, and derive.js returns 12 for anything major or better (PSIONIC_SAVE_STRONG). That is an app-level gap affecting every existing master psionic in Rifts as well, not something this class import changes.',
         'MASTER PSIONIC SAVE TARGET: 10 or higher, which the app now derives correctly - the psionic save table was three tiers all along and derive.js only had two.')
 WHERE class_id = 'psychic-sensitive'
   AND instr(markdown, '(PSIONIC_SAVE_STRONG)') > 0;

-- ---- read the result back rather than trusting the exit code ---------------
-- Expect 0. No class still claims the app gets this wrong.
SELECT count(*) AS stale_claims FROM imported_classes
 WHERE instr(markdown, 'The app currently derives 12') > 0
    OR instr(markdown, 'an app-level gap affecting every existing master psionic') > 0
    OR instr(markdown, '(PSIONIC_SAVE_STRONG)') > 0;
-- Expect 4. All four still state the correct target from the book.
SELECT count(*) AS states_the_target FROM imported_classes
 WHERE class_id IN ('psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage')
   AND instr(markdown, 'needs a 10 or higher to save against psionic attack') > 0;
SELECT class_id, length(markdown) AS md_bytes FROM imported_classes
 WHERE class_id IN ('psychic-sensitive', 'psi-healer', 'psi-mystic', 'mind-mage')
 ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-psychic-save-target-notes.sql');
