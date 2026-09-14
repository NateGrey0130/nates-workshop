-- The Night Witch's lore note says the group-level form is "stored and never
-- read". Since BOOK-INGEST-AUDIT F84's parser half it is not stored at all.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzz-f84-night-witch-note.sql
--
-- WHY A WHOLE FILE FOR ONE SENTENCE. `audit-menu` -> "A class note that cites a
-- finding goes stale when the finding is taken": an extraction_notes entry does
-- two jobs in one paragraph, and only one of them is permanent. What the book
-- prints and what was stored stays true forever. What the APP could do on the
-- day of the import does not, and it rots inside a record that otherwise reads
-- as reliable. The rule is to write the DECISION and cite the finding, and let
-- the finding own the mechanism.
--
-- This note broke that rule in one clause - "they are stored and never read" is
-- the mechanism - so taking F84 falsified it. The decision half, that the four
-- names belong on the CATEGORY, is untouched and stays exactly as written.
--
-- `scripts/audit-citations.mjs --remote F84` reports this class and only this
-- class (--remote, 2026-09-14). It reads `imported_classes` alone, so the
-- menu, the survey and this file are outside what it can see; those were
-- checked by grep in the same pass.

UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'written beside categories they are stored and never read, and this offered all 87 Technical skills - BOOK-INGEST-AUDIT.md F84.',
         'written beside categories instead, they reach no reader, and this offered all 87 Technical skills. The parser REFUSES that form outright since BOOK-INGEST-AUDIT.md F84 was taken, so it can no longer be written by accident.')
 WHERE deleted_at IS NULL
   AND class_id = 'night-witch';

-- ASSERTIONS.

SELECT 'the stale mechanism clause is gone' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id = 'night-witch'
   AND instr(markdown, 'stored and never read') > 0;

SELECT 'and the class still cites the finding' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id = 'night-witch'
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F84') > 0;

-- The DECISION half must survive untouched: the four lore names sit on the
-- category entry, which is what makes the class correct rather than merely
-- documented.
SELECT 'the four names are still on the category entry' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id = 'night-witch'
   AND instr(markdown, 'categories: [{ name: "Technical", only: [') > 0;

-- And no other class was touched. The replace() is bounded by class_id, so this
-- should be impossible; asserted because a replace() over a markdown column is
-- the shape that goes wrong quietly.
SELECT 'no other class lost the phrase' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id <> 'night-witch'
   AND instr(markdown, 'REFUSES that form outright') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzz-f84-night-witch-note.sql');
