-- Repair the quote marks OCR damaged in nine super-ability descriptions.
--
-- A sweep of every TEXT column on production, 2026-09-29, counted values with
-- an odd number of double quotes or a doubled apostrophe. The only real ones
-- in this database are these nine super abilities, from the three books the
-- catalog was imported from (the Stone Master's odd count is an inch mark,
-- 6'6", and is right). fix-super-ability-ocr-text.sql, the earlier sweep of
-- these rows, did not look at quote marks.
--
--   4 rows   a closing double quote read as a single mark ("reef')
--   2 rows   an apostrophe stored twice (creature''s)
--   3 rows   read off a render of the printed page:
--            Alter Physical Structure: Electricity (Revised HU, entry p.169):
--              the ': "' after +3 to strike is two specks of the picture
--              behind the column; nothing is printed there
--            Absorb Bio-Mass (PU1, entry p.52): ("How did... opens with a
--              double quote the scan read as a single one
--            Bulletproof (PU3, entry p.52): "bulletproof" closes, the mark
--              tucked into the f, and the scan dropped it
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-super-ability-quote-marks.sql
--
-- Each UPDATE is keyed on `name` (UNIQUE) and guarded on the fragment it
-- replaces, which occurs once in its row, so re-running is a no-op and a row
-- somebody has since rewritten by hand is left alone. It sorts after
-- fix-super-ability-ocr-text.sql and every add-*-super-abilities.sql, whose
-- text it corrects.

UPDATE super_abilities SET description = replace(description, 'strike. : " The', 'strike. The')
 WHERE name = 'Alter Physical Structure: Electricity' AND instr(description, 'strike. : " The') > 0;
UPDATE super_abilities SET description = replace(description, '"powerhouse'' first', '"powerhouse" first')
 WHERE name = 'Physical Perfection' AND instr(description, '"powerhouse'' first') > 0;
UPDATE super_abilities SET description = replace(description, '(''How did', '("How did')
 WHERE name = 'Absorb Bio-Mass' AND instr(description, '(''How did') > 0;
UPDATE super_abilities SET description = replace(description, 'twister'' if', 'twister" if')
 WHERE name = 'Spiral/Vortex' AND instr(description, 'twister'' if') > 0;
UPDATE super_abilities SET description = replace(description, 'twister'' if', 'twister" if')
 WHERE name = 'Alter Physical Structure: Air' AND instr(description, 'twister'' if') > 0;
UPDATE super_abilities SET description = replace(description, '"reef'' sea', '"reef" sea')
 WHERE name = 'Alter Physical Structure: Coral' AND instr(description, '"reef'' sea') > 0;
UPDATE super_abilities SET description = replace(description, '"bulletproof and', '"bulletproof" and')
 WHERE name = 'Bulletproof' AND instr(description, '"bulletproof and') > 0;
UPDATE super_abilities SET description = replace(description, 'creature''''s', 'creature''s')
 WHERE name = 'Aerodynamics' AND instr(description, 'creature''''s') > 0;
UPDATE super_abilities SET description = replace(description, 'insect''''s', 'insect''s')
 WHERE name = 'Prodigious Multiple Arms' AND instr(description, 'insect''''s') > 0;

SELECT 'no super ability has an unpaired double quote' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities WHERE (length(description) - length(replace(description, '"', ''))) % 2 = 1;

SELECT 'and none stores an apostrophe twice' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities WHERE instr(description, '''''') > 0;

SELECT 'the nine are still here, and none lost its text' AS assertion, count(*) AS got, 9 AS want
  FROM super_abilities WHERE length(description) >= 60 AND name IN ('Alter Physical Structure: Electricity',
    'Physical Perfection', 'Absorb Bio-Mass', 'Spiral/Vortex', 'Alter Physical Structure: Air',
    'Alter Physical Structure: Coral', 'Bulletproof', 'Aerodynamics', 'Prodigious Multiple Arms');

INSERT INTO data_script_runs (filename) VALUES ('fix-super-ability-quote-marks.sql');
