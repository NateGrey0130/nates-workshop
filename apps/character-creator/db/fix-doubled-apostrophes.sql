-- Undo a double-escape in ten classes' stored markdown.
--
-- BOOK-INGEST-AUDIT.md F13, taken in PR #NNN. The stored text reads
-- "the Spacer''s decompression save" - two apostrophes in the markdown AS
-- STORED, not as escaped for SQL. It renders to the reader exactly as stored,
-- so a class detail page shows a doubled apostrophe where the author wrote one.
--
-- THE CAUSE, WHICH F13 ASKS FOR BEFORE THE SWEEP. It is not the generator.
-- `class-check --emit-script` has one escaping site, `literal()`, and it doubles
-- each apostrophe exactly once, which is correct. The proof is arithmetic: all
-- 157 `add-*-class.sql` files were emitted through it and exactly TEN contain
-- '''' - and those ten are the same ten rows carrying '' in production, with
-- the counts matching one for one. A generator that double-escaped would have
-- done it to all 157.
--
-- So the DRAFTS arrived pre-escaped: someone had already doubled the
-- apostrophes for SQL in the .md before `--emit-script` doubled them again.
-- All ten are Phase World classes, which is the narrowing F13 predicted.
--
-- A BLANKET REPLACE IS SAFE HERE, AND ONLY BECAUSE IT WAS CHECKED. F13 warns
-- against starting with one, since a doubled apostrophe is legal prose if the
-- author meant it. Every one of the 36 occurrences was printed and read
-- first, and every one is a possessive - the catalog''s, the character''s, the
-- Galactic Tracer''s - or the plural possessive in "1D6x1000 credits'' worth of
-- items", which the book writes with a single apostrophe. None is intentional.
-- The statement is scoped to these ten ids rather than the whole table, so a
-- class that legitimately wants '' later is untouched.
--
--   class                      occurrences
--   colonist                    1
--   freedom-fighter             5
--   galactic-tracer             3
--   imperial-legionnaire        3
--   imperial-security-agent     2
--   machine-people              1
--   runner                      7
--   silhouette                  7
--   space-pirate                5
--   spacer                      2
--
-- The Colonist has one where its script emitted two: F7's script repaired the
-- other in passing, because it had to match that text to do its own job. That
-- mismatch is how F13 was found.
--
-- The ten `add-*-class.sql` files are NOT edited - they are one-shot scripts
-- that have already run. On a clean rebuild the glob applies them in sorted
-- order and `fix-` sorts after `add-`, so this runs last and the rebuild
-- converges on the corrected text.

UPDATE imported_classes
   SET markdown = replace(markdown, '''''', ''''),
       updated_at = datetime('now')
 WHERE class_id IN ('colonist', 'freedom-fighter', 'galactic-tracer', 'imperial-legionnaire', 'imperial-security-agent', 'machine-people', 'runner', 'silhouette', 'space-pirate', 'spacer')
   AND instr(markdown, '''''') > 0;

-- Readback: no doubled apostrophe survives in any of the ten, and the corpus as
-- a whole is clean. The second count is the one that matters - it would catch a
-- class outside the list that had drifted the same way.
SELECT (SELECT count(*) FROM imported_classes
         WHERE class_id IN ('colonist', 'freedom-fighter', 'galactic-tracer', 'imperial-legionnaire', 'imperial-security-agent', 'machine-people', 'runner', 'silhouette', 'space-pirate', 'spacer') AND instr(markdown, '''''') > 0) AS of_the_ten,
       (SELECT count(*) FROM imported_classes
         WHERE instr(markdown, '''''') > 0) AS anywhere,
       (SELECT count(*) FROM imported_classes) AS classes;

INSERT INTO data_script_runs (filename) VALUES ('fix-doubled-apostrophes.sql');
