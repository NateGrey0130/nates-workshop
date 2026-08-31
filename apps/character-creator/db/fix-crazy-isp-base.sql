-- Give the Crazy the I.S.P. formula its book prints.
--
-- BOOK-INGEST-AUDIT.md F17, taken in PR #NNN. The field held "6d6"; Rifts
-- Ultimate Edition printed 55 says "I.S.P. Base: 6D6 plus the M.E. attribute
-- number, +1D6 I.S.P. per level of experience, starting with level two."
--
-- Read off a 200 dpi render of the page, not the OCR - the folio reads 55,
-- which also confirms this book's +3 offset. The class's own extraction_notes
-- already quoted the full sentence, so the field was short of the book AND of
-- the record beside it.
--
-- WHERE THE 6D6 PROBABLY CAME FROM, because it explains why it looked right.
-- Two lines below the psionics entry the same page prints "P.P.E. Base: 6D6
-- P.P.E.", and the class stores `ppe_base: "6d6"` correctly. The two figures
-- are adjacent, identical at a glance, and only one of them carries the extra
-- terms. It is the only class in the catalog whose isp_base and ppe_base are
-- the identical string - checked across all 160 - so the slip did not spread.
--
-- `rollPoolFormula` is handed the character's attributes and resolves an
-- attribute named in the formula, so this string is read rather than stored and
-- ignored: 23 classes already hold one of exactly this shape. A Crazy rolled
-- 6-36 I.S.P. where the book gives it 6-36 PLUS its M.E.
--
-- THE SWEEP F17 ASKS FOR FOUND NOTHING ELSE. Fifteen classes store an isp_base
-- with no attribute term, and the other fourteen are right: the shade, the
-- entrancer, the holy terror and the morphworm were checked line by line
-- against their own pages in the Wormwood cache and all four print a bare
-- figure ("Major psionic, 3D4 x 10 I.S.P."); the six dragon hatchling variants
-- store the per-level term their pages print; the pleasurer, vacuum wasp and
-- termite engineer store theirs too; and the base Dragon Hatchling's entry
-- gives no I.S.P. figure at all, its 3D4x10 being a documented earlier
-- decision recorded in its own note. One class, not a habit.

UPDATE imported_classes
   SET markdown = replace(markdown, '  type: "minor"' || char(10) || '  isp_base: "6d6"',
       '  type: "minor"' || char(10) || '  isp_base: "6d6 plus the M.E. attribute number, +1d6 I.S.P. per level of experience, starting with level two"'),
       updated_at = datetime('now')
 WHERE class_id = 'crazy'
   AND instr(markdown, '  type: "minor"' || char(10) || '  isp_base: "6d6"') > 0
   AND instr(markdown, '  type: "minor"' || char(10) || '  isp_base: "6d6 plus the M.E. attribute number, +1d6 I.S.P. per level of experience, starting with level two"') = 0;

-- Readback: the formula now names the attribute and the per-level term, and the
-- P.P.E. base beside it is untouched at the 6D6 the book really does print.
SELECT class_id,
       instr(markdown, 'isp_base: "6d6 plus the M.E. attribute number') > 0 AS isp_full,
       instr(markdown, 'ppe_base: "6d6"') > 0 AS ppe_untouched,
       instr(markdown, 'per level of experience, starting with level two') > 0 AS per_level_kept
  FROM imported_classes
 WHERE class_id = 'crazy';

INSERT INTO data_script_runs (filename) VALUES ('fix-crazy-isp-base.sql');
