-- The chiang-ku-dragon page stamp is one page high for the copy of Dragons
-- and Gods now on this machine (class audit F18 follow-up, 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-stamp-chiang-ku-range.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-stamp-chiang-ku-range.sql
--
-- F18 stamped chiang-ku-dragon "p.23-24" from the audit's hand-located
-- number, taken on faith while the PDF was off this machine. The PDF
-- returned (PFRPG - Dragons and Gods, 240 pages, text layer) and was cached
-- as .cache/books/dag (reader page = printed+1, folios confirmed): the
-- Chiang-Ku heading and its full Palladium stat block - including the
-- audit's verified "Hatchling: 2D4x10+20" P.P.E. and the adult's
-- "2D4x100+200 plus P.E. attribute number" - print on folio 22, its Rifts
-- Stats on folio 23, and folio 24 opens the Cockatrice. The Basilisk's
-- "P.P.E. is 2D4x10+40 during hatchling years" trap line sits at the TOP of
-- folio 22, directly above the Chiang-Ku heading - the audit's trap note
-- stands, one page lower than it said. So the class spans printed 22-23 in
-- this copy, and the stamp moves to match the cache --field-sources will
-- actually read.
--
-- Filename sort: fix-stamp-chiang-ku-range > fix-source-book-pages, which
-- writes the stamp this corrects. (NOT fix-source-book-pages-chiang-ku:
-- '-' sorts before '.', so that name would run BEFORE the file it corrects
-- - the long-bowman trap.)
--
-- Safe to run twice: the second pass finds nothing to replace.

UPDATE imported_classes
SET markdown = replace(markdown,
      'source_book: dragons-and-gods p.23-24',
      'source_book: dragons-and-gods p.22-23'),
    updated_at = datetime('now')
WHERE class_id = 'chiang-ku-dragon'
  AND instr(markdown, 'source_book: dragons-and-gods p.23-24') > 0;

-- Reads the result back, so it is read rather than assumed.
--   fixed        1 = the stamp reads p.22-23
--   old_left     0 = no p.23-24 stamp remains
--   cr_free      1 = still no CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'chiang-ku-dragon'
          AND instr(markdown, 'source_book: dragons-and-gods p.22-23') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'chiang-ku-dragon'
          AND instr(markdown, 'p.23-24') > 0) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'chiang-ku-dragon'
          AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-stamp-chiang-ku-range.sql');
