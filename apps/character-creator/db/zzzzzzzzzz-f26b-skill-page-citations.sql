-- INGESTION-AUDIT F26(b): page citations for the skill rows that name a book
-- and no page. Three of the ten are citable off a cached book; the other seven
-- are not missing a page, they name a book that does not define the skill at
-- all. See F26's outcome note for that measurement.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzz-f26b-skill-page-citations.sql
--
-- Read off the OCR caches on 2026-09-12, printed folio computed from the
-- page_offset scripts/books.json records (rue +3, pf +2):
--
--   catalog row               cache page  printed  what the page holds
--   Robot Combat: Basic       rue p322    319      the description, "Robot Combat skills as follows"
--                             rue p306    303      and the skill list entry, "Robot Combat: Basic (SPECIAL)"
--   W.P. Lance                pf  p062     60      "W.P. Lance Note:" between W.P. Battle Axe and W.P. Shield
--   Language: Native Tongue   pf  p052     50      "Language: Characters with a language skill can..."
--
-- Robot Combat: Basic takes p.319, the page that DESCRIBES it, matching the
-- eight rows already citing that page. The catalog's base 0 / per_level 0
-- agrees with the book printing it as (SPECIAL) rather than a percentage.
--
-- The two Palladium Fantasy rows also get the book's CANONICAL title. They
-- carried 'palladium-fantasy-core' and 'Palladium Fantasy RPG 2nd Ed.', both
-- registered aliases of the same book (scripts/books.json), while five rows
-- already cite it as 'Palladium Fantasy RPG Main Book'. The alias resolves
-- either way; the point is that one book should read one way in the catalog.
--
-- p.50 is the Communication Skills section, where the Language skill is
-- defined. 'Sign Language' already cites that exact page, which is the check on
-- the offset: two rows read independently off the same section agree.
-- 'Native Tongue at 98%' itself is a per-class convention printed in the O.C.C.
-- skill lists (pf cache p069, p079 and p082), not a separate skill entry -
-- so the citation goes to where the skill is defined.
--
-- THE ACTION IS RE-CITATION AND NEVER A RENAME, for the reason
-- zzzzz-recite-underseas-skills.sql sets out at length: characters reference
-- skills by NAME, and an unmatched class `except` fails OPEN. Every value -
-- category, base, per_level - stays exactly where it is. Only source_book moves.
--
-- WHY THIS FILE SORTS LAST. A clean rebuild applies apps/character-creator/db/
-- *.sql as one sorted glob, so filename order IS execution order. These rows do
-- not exist until their add- files have run. Checked against the directory as
-- it stands on 2026-09-12: ten z's sorts after every existing name, including
-- zzzzzzzzz-sw-healing-powers-source.sql.
--
-- Guarded on the old citation still being present, so re-running is a no-op and
-- a row someone has already re-cited by hand is left alone.

UPDATE skills
   SET source_book = 'Rifts Ultimate Edition p.319'
 WHERE name = 'Robot Combat: Basic' AND source_book = 'Rifts Ultimate Edition';

UPDATE skills
   SET source_book = 'Palladium Fantasy RPG Main Book p.60',
       note = 'Printed as a Note under the Weapon Proficiencies: the lance is limited to the Knight and Palladin O.C.C.s and is not normally available to others. The abilities and bonuses are printed under The Way of the Lance in each of those two O.C.C. entries rather than here.'
 WHERE name = 'W.P. Lance' AND source_book = 'palladium-fantasy-core';

UPDATE skills
   SET source_book = 'Palladium Fantasy RPG Main Book p.50'
 WHERE name = 'Language: Native Tongue' AND source_book = 'Palladium Fantasy RPG 2nd Ed.';

-- Readback: the three rows, and what is left uncited.
SELECT name, category, base, per_level, source_book
  FROM skills
 WHERE name IN ('Robot Combat: Basic', 'W.P. Lance', 'Language: Native Tongue')
 ORDER BY name;
SELECT COUNT(*) AS still_book_without_page
  FROM skills
 WHERE source_book IS NOT NULL AND source_book <> ''
   AND source_book NOT LIKE '% p.%'
   AND source_book <> 'Rifts Skill List';
SELECT COUNT(*) AS still_citing_the_sheet FROM skills WHERE source_book = 'Rifts Skill List';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzz-f26b-skill-page-citations.sql');
