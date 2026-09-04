-- RETRO-AUDIT R1: five classes stop denying a key they already carry.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r1-note-rot.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r1-note-rot.sql
--
-- PROSE ONLY. No mechanic, no column, no bonus value changes. Every one of these
-- five classes ALREADY carries the key its own note says the app cannot express;
-- the data is right and only the prose is wrong, which is the shape CLASS-AUDIT
-- S4 recorded on the Godling. The readbacks at the foot assert each key is still
-- present, so "no data change" is proved rather than claimed.
--
-- THREE SENTENCES DELIBERATELY NOT TOUCHED, each verified TRUE on 2026-09-04.
-- Rewriting any of them would turn a correct claim into a false one, which is
-- the failure a note sweep cannot score itself on:
--
--   * spacer, "The saves list is a fixed sixteen and none of them is a vacuum."
--     TRUE. SAVE_FIELDS in apps/character-creator/sheet.js is exactly sixteen
--     entries and none is a vacuum. What was false is the CONCLUSION drawn from
--     it - that the bonus is therefore not on the sheet - because otherSaves()
--     renders bonuses.saves.other AFTER those sixteen.
--   * juicer-wannabe, the mid-campaign conversion to a full Juicer. TRUE, and on
--     CLASS-AUDIT's "Checked and still true" list. Untouched.
--   * crazy, the per-level I.S.P. growth. TRUE in the sense meant: parser.js
--     warns that bonuses.at_level.pools is not applied, so the growth belongs in
--     the isp_base formula, which is where the class already puts it. Only the
--     "category exclusions" half of that compound sentence was false.
--
-- The five keys, and where each is read today:
--   occ_related_skills.minimums  parser.js relatedMinimums -> wizard app.js and
--                                server _lib/validate-character.js
--   bonuses.saves.other          sheet.js otherSaves(), rendered after the sixteen
--   bonuses.combat.perception    derive.js deriveCombat, rendered by sheet.js
--   categories_allowed[].except  parser.js categoryAllows -> client and
--                                _lib/power-picks.js

-- ---- gambler -------------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       'The two-from-Rogue condition on related skills cannot be expressed in the picker and is stated in the note and the restrictions.',
       'The two-from-Rogue condition on related skills IS expressed, as an occ_related_skills.minimums floor - the wizard counts it and the server refuses a save that does not meet it. This note said it could not be expressed in the picker until RETRO-AUDIT R1 (2026-09-04); the floor was already in the data above.')
 WHERE class_id = 'gambler'
   AND instr(markdown, 'cannot be expressed in the picker and is stated') > 0;

-- ---- juicer-wannabe ------------------------------------------------------
-- Only the related-skills sentence. The mid-campaign conversion sentence in the
-- same paragraph is TRUE and is left exactly as it stands.
UPDATE imported_classes
   SET markdown = replace(markdown,
       'The two-from-Rogue and two-from-Physical condition on related skills cannot be expressed in the picker either.',
       'The two-from-Rogue and two-from-Physical condition on related skills IS expressed, as two occ_related_skills.minimums floors - the wizard counts them and the server refuses a save that does not meet them. This note said it could not be expressed in the picker until RETRO-AUDIT R1 (2026-09-04); both floors were already in the data above. The mid-campaign conversion described above is a different limitation and is still real.')
 WHERE class_id = 'juicer-wannabe'
   AND instr(markdown, 'cannot be expressed in the picker either') > 0;

-- ---- wilderness-scout ----------------------------------------------------
-- The stored note WRAPS mid-phrase - "(Perception" ends a line and "has no bonus
-- key" begins the next - which is why earlier sweeps read this sentence as
-- absent. CLASS-AUDIT S4 recorded the same trap on the Godling.
UPDATE imported_classes
   SET markdown = replace(markdown,
       '+1 on initiative and +3 on Perception Rolls (Perception' || char(10) || '    has no bonus key, left as prose); +2 to roll with impact; +2 to save vs',
       '+1 on initiative and +3 on Perception Rolls (both stored in bonuses.combat;' || char(10) || '    combat.perception is a real key - see derive.js and CLASS-AUDIT F8 - and this' || char(10) || '    note said it was not until RETRO-AUDIT R1, 2026-09-04); +2 to roll with' || char(10) || '    impact; +2 to save vs')
 WHERE class_id = 'wilderness-scout'
   AND instr(markdown, 'has no bonus key, left as prose') > 0;

-- ---- spacer, extraction_notes --------------------------------------------
-- The stronger of the two false sentences, and the one a sweep quoting only the
-- GM Notes would leave standing.
UPDATE imported_classes
   SET markdown = replace(markdown,
       '- THE ONLY BONUS THIS CLASS HAS IS NOT STORED, and `bonuses` is empty because' || char(10) || '    of it.',
       '- THE ONLY BONUS THIS CLASS HAS IS STORED, in `bonuses.saves.other`. This note' || char(10) || '    said it was not, and that `bonuses` was empty because of it, until' || char(10) || '    RETRO-AUDIT R1 (2026-09-04). The rest of this bullet is still true and is' || char(10) || '    the reason the labelled-save shape exists.')
 WHERE class_id = 'spacer'
   AND instr(markdown, 'THE ONLY BONUS THIS CLASS HAS IS NOT STORED') > 0;

-- ---- spacer, GM Notes ----------------------------------------------------
-- "The saves list is a fixed sixteen and none of them is a vacuum" is TRUE and
-- survives verbatim; only the two false clauses around it move.
UPDATE imported_classes
   SET markdown = replace(markdown,
       'space dangers**, and it is not on the sheet. The saves list is a fixed sixteen' || char(10) || 'and none of them is a vacuum. Apply it by hand; it is the whole of what this' || char(10) || 'O.C.C. gets beyond its skills.',
       'space dangers**, and it IS on the sheet. The saves list is a fixed sixteen' || char(10) || 'and none of them is a vacuum, which is exactly why it is carried as a labelled' || char(10) || 'save in `bonuses.saves.other` and rendered after those sixteen. It is the whole' || char(10) || 'of what this O.C.C. gets beyond its skills. This paragraph said to apply it by' || char(10) || 'hand until RETRO-AUDIT R1, 2026-09-04.')
 WHERE class_id = 'spacer'
   AND instr(markdown, 'Apply it by hand; it is the whole of what this') > 0;

-- ---- crazy ---------------------------------------------------------------
-- A compound sentence, half false. The record contradicted itself: the clause
-- immediately before this one already said all four exclusions are "held in
-- `except` and enforced".
UPDATE imported_classes
   SET markdown = replace(markdown,
       'The per-level ISP growth and category exclusions are prose-only, not expressible as a clean bonus.',
       'The category exclusions are NOT prose-only - all four are in categories_allowed[].except and enforced, as the clause before this one already said; this sentence contradicted it until RETRO-AUDIT R1 (2026-09-04). The per-level I.S.P. growth is prose-only in the sense meant: bonuses.at_level.pools is not applied, which parser.js warns about outright, so the growth belongs in the isp_base formula and is already there.')
 WHERE class_id = 'crazy'
   AND instr(markdown, 'The per-level ISP growth and category exclusions are prose-only') > 0;

-- ---- readbacks: no data moved --------------------------------------------
-- Each key its note denied is STILL PRESENT. This is the "prose only" posture
-- proved rather than claimed.
SELECT 'gambler still carries its minimums floor' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'gambler' AND instr(markdown, 'minimums') > 0;

SELECT 'juicer-wannabe still carries its minimums floors' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'minimums') > 0;

SELECT 'wilderness-scout still carries combat.perception' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'perception: 3') > 0;

SELECT 'spacer still carries its labelled save' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'spacer' AND instr(markdown, 'explosive decompression') > 0;

SELECT 'crazy still carries its four exclusions' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'crazy' AND instr(markdown, 'except') > 0;

-- The three sentences that are TRUE are untouched.
SELECT 'spacer keeps the true fixed-sixteen clause' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'spacer'
   AND instr(markdown, 'The saves list is a fixed sixteen') > 0;

SELECT 'juicer-wannabe keeps the true conversion sentence' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'juicer-wannabe'
   AND instr(markdown, 'nothing in the app can perform it') > 0;

-- No false claim survives in any of the five.
SELECT 'no class still denies a key it carries' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gambler', 'juicer-wannabe', 'wilderness-scout', 'spacer', 'crazy')
   AND (instr(markdown, 'cannot be expressed in the picker') > 0
     OR instr(markdown, 'has no bonus key, left as prose') > 0
     OR instr(markdown, 'THE ONLY BONUS THIS CLASS HAS IS NOT STORED') > 0
     OR instr(markdown, 'Apply it by hand; it is the whole of what this') > 0
     OR instr(markdown, 'The per-level ISP growth and category exclusions are prose-only') > 0);

-- Records this run. Every statement above guards itself on the text it replaces,
-- so this script is safe to re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r1-note-rot.sql');
