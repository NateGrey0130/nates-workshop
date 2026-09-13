-- Three classes stated saves as PROSE that the sheet has real fields for.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-mystic-russia-saves-the-sheet-can-draw.sql
--
-- WHY THIS FILE EXISTS. `sheet.js` draws a literal SAVE_FIELDS list of sixteen
-- saves, and the class-import skill says to use `saves.other` or a
-- special_ability for a book-stated save the sixteen do not name. Three classes
-- in this book were written on the assumption that the list was shorter than it
-- is, so saves that DO have fields were recorded as prose - where the sheet
-- shows them as a note and never adds them up.
--
-- The list actually includes `disease`, `curses` and `toxins_poisons`. It was
-- read properly only when the Gypsy Fortune Teller's "+1 to save vs illusions"
-- failed the smoke test's key check and sent me to look at it.
--
--   old-believer    +7 vs disease, +3 vs poison, and the DISEASE and CURSES
--                   halves of "+6 vs magical spoiling, sickness and curses"
--   slayer-russian  +4 vs disease
--   gypsy-fortune-teller  +1 vs illusions -> illusionary_magic
--
-- The Old Believer's "+6 vs magical SPOILING" half stays prose: nothing in the
-- sixteen covers it, and spoiling is this book's own tradition.
--
-- What is NOT changed, and deliberately: the Necromancer's "+2 to save vs
-- Necromancy spells" and the Fire Sorcerer's "+4 to save vs magic fumes" have
-- no field among the sixteen and stay as prose. That was the right call and is
-- left alone.
--
-- Each UPDATE is guarded on the text it replaces, so re-running is a no-op.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'saves: { possession: 9, horror_factor: 4 }',
         'saves: { possession: 9, horror_factor: 4, disease: 7, toxins_poisons: 3, curses: 6 }'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, 'saves: { possession: 9, horror_factor: 4 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'saves: { possession: 3, spell_magic: 1, ritual_magic: 1, mind_control: 3 }',
         'saves: { possession: 3, spell_magic: 1, ritual_magic: 1, mind_control: 3, disease: 4 }'),
       updated_at = datetime('now')
 WHERE class_id = 'slayer-russian'
   AND instr(markdown, 'mind_control: 3 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'insanity: 3, illusion: 1 }', 'insanity: 3, illusionary_magic: 1 }'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, 'illusion: 1 }') > 0;

-- Read the result back.
SELECT 'the Old Believer''s disease save is a field' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'old-believer' AND instr(markdown, 'disease: 7') > 0;

SELECT 'and its poison and curse saves too' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'old-believer'
   AND instr(markdown, 'toxins_poisons: 3') > 0 AND instr(markdown, 'curses: 6') > 0;

SELECT 'the Slayer''s disease save is a field' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'slayer-russian' AND instr(markdown, 'disease: 4') > 0;

SELECT 'the Fortune Teller''s illusion save uses the sheet''s key' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'gypsy-fortune-teller' AND instr(markdown, 'illusionary_magic: 1') > 0;

SELECT 'and the unrenderable key is gone' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'gypsy-fortune-teller' AND instr(markdown, 'illusion: 1 }') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-mystic-russia-saves-the-sheet-can-draw.sql');
