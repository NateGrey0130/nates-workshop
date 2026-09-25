-- Five W.P. citations that production holds correctly and a rebuild does not.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzzzzzz-reapply-wp-recitations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzzzzzz-reapply-wp-recitations.sql
--
-- NOTHING HERE IS A NEW DECISION. Both corrections were made and argued by the
-- scripts named below, and production has carried them since. Each one sorts
-- BEFORE the file that writes the value it corrects, so on a clean rebuild it
-- guards on a value that is not there yet, matches nothing, and the older value
-- lands afterwards. Production ran them by hand in the right order, which is
-- why only a repo-vs-live diff could see it (measured 2026-09-24:
-- `repo-vs-live.mjs --table skills --offenders`, and book-board --remote
-- showing rue 673 vs 670 and new-west 239 vs 238).
--
-- 1. fix-wp-source-pre-rue-citations.sql (INGESTION-AUDIT F25) re-cites four
--    pre-RUE W.P.s to 'Rifts Skill List', guarded on 'Rifts Ultimate
--    Edition'. The rows are CREATED by restore-skills-missing-from-repo.sql,
--    which sorts after it ('f' < 'r'), so on a rebuild the fix finds no rows and
--    the restore then inserts them cited to RUE.
--
-- 2. add-new-west-skills.sql re-cites W.P. Rope to 'Rifts Ultimate Edition
--    p.306', guarded on 'Rifts New West'. That value is WRITTEN by
--    backfill-blank-skills.sql, which sorts after it ('a' < 'b'), so on a
--    rebuild the guard finds the row still at 'p.302-303' and the backfill then
--    sets New West - the book that does not print it.
--
-- Guards on the WRONG value, as both originals do, so on production this is a
-- no-op and it cannot clobber a better citation. Sorts after every file in the
-- directory on the day it was written; nothing after it writes these rows'
-- source_book.

UPDATE skills SET source_book = 'Rifts Skill List'
 WHERE name IN ('W.P. Automatic Pistol', 'W.P. Revolver', 'W.P. Bolt Action Rifle',
                'W.P. Automatic and Semi-automatic Rifles')
   AND source_book = 'Rifts Ultimate Edition';

UPDATE skills SET source_book = 'Rifts Ultimate Edition p.306'
 WHERE name = 'W.P. Rope'
   AND source_book = 'Rifts New West';

-- Read the result back. This batch asserts its OWN rows and nothing else.

SELECT 'the four pre-RUE W.P.s cite the skill list' AS assertion, count(*) AS got, 4 AS want
  FROM skills
 WHERE name IN ('W.P. Automatic Pistol', 'W.P. Revolver', 'W.P. Bolt Action Rifle',
                'W.P. Automatic and Semi-automatic Rifles')
   AND source_book = 'Rifts Skill List';

SELECT 'W.P. Rope cites the RUE page that describes it' AS assertion, count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'W.P. Rope' AND source_book = 'Rifts Ultimate Edition p.306';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzzz-reapply-wp-recitations.sql');
