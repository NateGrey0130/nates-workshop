-- Puts back one sentence of the Ghost Dragon hatchling's extraction notes that
-- a clean build rewrites.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~178-ghost-hatchling-note-keeps-the-printed-skill-names.sql
--
-- WHY. add-dragon-hatchling-ghost-class.sql records, in extraction_notes, that
-- the book prints "Advanced Math" and "Basic Math" and that they are stored as
-- the catalog's Mathematics rows. On a clean build that file sorts before the
-- scripts that rename those two quoted skill names in every class's markdown,
-- so the build rewrites the QUOTED PRINTED NAMES inside the note as well, and
-- the sentence then says a name is stored as itself. Production ran the
-- renames long before this class existed and keeps the sentence as written.
-- repo-vs-live.mjs --offenders reported exactly this one field on 2026-10-05.
-- Production wins (BOOK-INGEST-AUDIT F105), so this writes production's text.
-- The tilde number is claimed at merge.
--
-- Guarded on the rewritten text, so in production this changes nothing.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '"Mathematics: Advanced" and "Mathematics: Basic" as Mathematics:',
         '"Advanced Math" and "Basic Math" as Mathematics:')
 WHERE class_id = 'dragon-hatchling-ghost'
   AND instr(markdown, '"Mathematics: Advanced" and "Mathematics: Basic" as Mathematics:') > 0;

SELECT 'the Ghost hatchling note names the skills as the book prints them' AS assertion,
       count(*) AS got,
       1 AS want
  FROM imported_classes
 WHERE class_id = 'dragon-hatchling-ghost'
   AND instr(markdown, '"Advanced Math" and "Basic Math" as Mathematics:') > 0;

SELECT 'and the rewritten form is gone' AS assertion,
       count(*) AS got,
       0 AS want
  FROM imported_classes
 WHERE class_id = 'dragon-hatchling-ghost'
   AND instr(markdown, '"Mathematics: Advanced" and "Mathematics: Basic" as Mathematics:') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~178-ghost-hatchling-note-keeps-the-printed-skill-names.sql');
