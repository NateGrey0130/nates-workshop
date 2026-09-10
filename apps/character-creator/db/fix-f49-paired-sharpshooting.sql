-- Give the three classes that take W.P. Sharpshooting more than once a `with`
-- list, so the weapons reach the character sheet.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-f49-paired-sharpshooting.sql
--
-- BOOK-INGEST-AUDIT.md F49, taken in this PR. `with` names the OTHER skills a
-- repeated skill is paired with; the wizard and the sheet both render it, and
-- `skillsAtLevelOne` carries it onto the saved character as a note.
--
-- == THREE CLASSES, NOT THE FIVE THE FINDING LISTS ==
--
-- `with` requires two or more names, because pairing one skill to one weapon is
-- not a repetition. Of the five rows F49 names:
--
--   gunfighter        THREE - Revolver, Energy Pistol, Energy Rifle    -> with
--   gunslinger        TWO   - Revolver, Energy Pistol                  -> with
--   wired-gunslinger  TWO   - Revolver, Energy Pistol                  -> with
--   juicer-assassin   ONE   - Energy Rifle                             -> unchanged
--   psi-slinger       a RESTRICTION, not a repetition                  -> unchanged
--
-- The Psi-Slinger''s note is the one worth reading twice: its Sharpshooting is
-- automatic but works ONLY for projectile revolvers and pistols the character
-- is psionically linked to. That is a narrowing of one grant, not the same
-- grant taken twice, and `with` would misdescribe it.
--
-- == THE NOTES LOSE A CLAIM THAT IS NO LONGER TRUE ==
--
-- All three said some version of "a class cannot grant it three times, so the
-- weapons are recorded here". The weapons are now recorded in `with` and reach
-- the sheet, so that half is removed. What stays is the book fact - which
-- weapons, and how many.
--
-- IT REMAINS ONE ROW, NOT THREE. `validate-character.js` refuses a character
-- holding the same skill name twice with HTTP 422 `duplicate_skill`, so three
-- rows named W.P. Sharpshooting would make every Gunfighter unsaveable. The
-- `with` list annotates the single row instead. That is a deviation from F49''s
-- proposed "one row per pairing on the sheet" and the finding''s outcome note
-- says so.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '{ name: "W.P. Sharpshooting", base: 0, per_level: 0, note: "THREE specialties: Revolver, Energy Pistol and Energy Rifle. The catalog holds one Sharpshooting row and a class cannot grant it three times, so the three weapons are recorded here and in the abilities below." }',
         '{ name: "W.P. Sharpshooting", base: 0, per_level: 0, with: ["W.P. Revolver", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "THREE specialties, one per weapon, and the class grants all three weapons separately. BOOK-INGEST-AUDIT.md F49." }')
 WHERE class_id = 'gunfighter'
   AND instr(markdown, 'a class cannot grant it three times') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '{ name: "W.P. Sharpshooting", base: 0, per_level: 0, note: "TWO specialties: Revolver and Energy Pistol. The catalog holds one Sharpshooting row and a class grants a skill once, so the two weapons are recorded here and in the abilities below. BOOK-INGEST-AUDIT.md F49." }',
         '{ name: "W.P. Sharpshooting", base: 0, per_level: 0, with: ["W.P. Revolver", "W.P. Energy Pistol"], note: "TWO specialties, one per weapon, and the class grants both weapons separately. BOOK-INGEST-AUDIT.md F49." }')
 WHERE class_id IN ('gunslinger', 'wired-gunslinger')
   AND instr(markdown, 'a class grants a skill once') > 0;

-- Read the result back rather than trusting the exit code.
SELECT 'the three repeating classes carry a with list' AS assertion,
       count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('gunfighter', 'gunslinger', 'wired-gunslinger')
   AND instr(markdown, 'with: ["W.P. Revolver"') > 0;

SELECT 'and the Gunfighter names all three weapons' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'gunfighter'
   AND instr(markdown, '"W.P. Revolver", "W.P. Energy Pistol", "W.P. Energy Rifle"') > 0;

-- The two that take it ONCE are deliberately untouched, and that is asserted so
-- a later pass does not "finish the job" by giving them a with list too.
SELECT 'the two non-repeating classes have no with list' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('juicer-assassin', 'psi-slinger')
   AND instr(markdown, 'with: [') > 0;

SELECT 'and none still says the app cannot grant it twice' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE instr(markdown, 'a class cannot grant it three times') > 0
    OR instr(markdown, 'a class grants a skill once, so the two weapons') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-f49-paired-sharpshooting.sql');
