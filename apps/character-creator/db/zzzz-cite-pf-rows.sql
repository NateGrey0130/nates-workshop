-- The Palladium Fantasy main book's untraceable rows, cited by page.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzz-cite-pf-rows.sql
--
-- THE `zzzz-` PREFIX IS LOAD-BEARING. This was written as `fix-pf-citations.sql`,
-- which sorts under `f` - in the MIDDLE of the data scripts. Applied to
-- production by hand it ran last and was right; applied in filename order it
-- ran before `restore-gear-missing-from-repo.sql`, which CREATES many of
-- the rows it cites, and its guarded UPDATEs matched nothing. A database
-- rebuilt from schema.sql plus every data script in order lost 148 citations
-- across the three files this was one of. Measured, not reasoned:
-- production 26 rows still bare, fresh build 172.
--
-- This is the third time this repo has escalated a prefix for the same
-- reason. `zz-` sorts after `fix-*`, `zzz-` after `zz-`, and these citation
-- files have to sort after `zzz-gear-tidy-*` too, which rewrites the
-- `source_book` of gear rows. See operations.md, Data scripts.
--
-- 42 rows carried this book's name with no page range, under THREE different
-- spellings of it - 'Palladium Fantasy RPG Main Book', 'palladium-fantasy-core'
-- and 'Palladium Fantasy RPG 2nd Ed.'. All three are registered aliases in
-- scripts/books.json, so all three resolve; two of them are a SLUG and an
-- edition name sitting in a title column. Every row this touches is rewritten
-- to the canonical title, so the fix normalises the vocabulary as well as
-- adding the page (INGESTION-AUDIT F1).
--
-- SPELLS came from this book's own two authority tables, parsed by
-- scripts/parse-pf-spell-index.mjs, the PF-shaped worked example already in
-- the repo: an alphabetical list BY LEVEL at printed 187 and one BY PAGE at
-- printed 188. The parser reconciles them - it reports that the two tables
-- disagree on exactly two costs and that one spell is in the level table only.
-- Each of the 28 was then read on the page the by-page table named, and all 28
-- carry their heading there.
--
-- pf IS THE BOOK WHOSE OFFSET IS NOT CONSTANT: +1 for printed 1-16, +2 for
-- 18-336. Every page in this file was resolved through offsetForPrintedPage,
-- not by adding page_offset, which is the failure F4 was taken to prevent.
-- (Nothing here is below printed 50, so the exception did not bite - but the
-- verification would have been wrong for any row that was.)
--
-- SKILLS are paragraph entries in this book - `History: This is a basic
-- historical knowledge...` - and were each read on the page. GEAR is the
-- `Types of Armor` table at printed 270.
--
-- HELD BACK: 3 rows this book does not print. `W.P. Lance` appears only as a
-- mention at printed 85 ("the equivalent of W.P. Lance"), never as an entry;
-- `Language: Native Tongue` is nowhere in the book; and `Small Shield` is not
-- in the armor table - pf has the SKILL `W.P. Shield`, not the item.
--
-- Every statement guards on the row's exact current source_book value, so this
-- is a no-op on a row that has already been given a page.


-- spells (28)
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.206'
  WHERE name = 'Age' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.197'
  WHERE name = 'Animate Object' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.200'
  WHERE name = 'Circle of Concealment' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.198'
  WHERE name = 'Control the Beasts' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.198'
  WHERE name = 'Create Bread & Milk' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.189'
  WHERE name = 'Decipher Magic' AND source_book = 'palladium-fantasy-core';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.199'
  WHERE name = 'Detect Poison' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.209'
  WHERE name = 'Dimensional Pocket' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.192'
  WHERE name = 'Faerie Speak' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.206'
  WHERE name = 'Faeries'' Dance' AND source_book = 'Palladium Fantasy RPG Main Book';
-- the book prints `The Finger of Lictalon`, with the article
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.211'
  WHERE name = 'Finger of Lictalon' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.199'
  WHERE name = 'Fire Fist' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.201'
  WHERE name = 'Immobilize' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.189'
  WHERE name = 'Increase Weight' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.204'
  WHERE name = 'Love Charm' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.197'
  WHERE name = 'Mend Cloth' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.218'
  WHERE name = 'Metamorphosis: Dragon' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.207'
  WHERE name = 'Monster Insect' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.210'
  WHERE name = 'Phantom Horse' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.205'
  WHERE name = 'Sense Dimensional Anomaly' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.193'
  WHERE name = 'Sense Traps' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.197'
  WHERE name = 'Size of the Behemoth' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.206'
  WHERE name = 'Time Capsule' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.190'
  WHERE name = 'Ventriloquism' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.191'
  WHERE name = 'Weightlessness' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.203'
  WHERE name = 'Wink-Out' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.203'
  WHERE name = 'Witch Bottle' AND source_book = 'Palladium Fantasy RPG Main Book';
UPDATE spells SET source_book = 'Palladium Fantasy RPG Main Book p.203'
  WHERE name = 'X-Ray Vision' AND source_book = 'Palladium Fantasy RPG Main Book';


-- skills (6)
UPDATE skills SET source_book = 'Palladium Fantasy RPG Main Book p.58'
  WHERE name = 'History' AND source_book = 'palladium-fantasy-core';
UPDATE skills SET source_book = 'Palladium Fantasy RPG Main Book p.53'
  WHERE name = 'Horsemanship: Knight' AND source_book = 'palladium-fantasy-core';
UPDATE skills SET source_book = 'Palladium Fantasy RPG Main Book p.53'
  WHERE name = 'Horsemanship: Palladin' AND source_book = 'palladium-fantasy-core';
-- the book prints `Recognize magic`, lower-case m
UPDATE skills SET source_book = 'Palladium Fantasy RPG Main Book p.107'
  WHERE name = 'Recognize Magic' AND source_book = 'palladium-fantasy-core';
UPDATE skills SET source_book = 'Palladium Fantasy RPG Main Book p.50'
  WHERE name = 'Sign Language' AND source_book = 'Palladium Fantasy RPG 2nd Ed.';
UPDATE skills SET source_book = 'Palladium Fantasy RPG Main Book p.84'
  WHERE name = 'W.P. Targeting' AND source_book = 'Palladium Fantasy RPG 2nd Ed.';


-- gear (5)
UPDATE gear SET source_book = 'Palladium Fantasy RPG Main Book p.270'
  WHERE name = 'Chain Mail' AND source_book = 'palladium-fantasy-core';
UPDATE gear SET source_book = 'Palladium Fantasy RPG Main Book p.270'
  WHERE name = 'Hard Leather' AND source_book = 'palladium-fantasy-core';
-- the table prints `Scale (full)`
UPDATE gear SET source_book = 'Palladium Fantasy RPG Main Book p.270'
  WHERE name = 'Scale Mail' AND source_book = 'palladium-fantasy-core';
UPDATE gear SET source_book = 'Palladium Fantasy RPG Main Book p.270'
  WHERE name = 'Soft Leather' AND source_book = 'palladium-fantasy-core';
UPDATE gear SET source_book = 'Palladium Fantasy RPG Main Book p.270'
  WHERE name = 'Studded Leather' AND source_book = 'palladium-fantasy-core';


-- Read the result back rather than trusting the exit code. Three rows are held
-- back deliberately, so these must read 0 / 2 / 1 and nothing else.
SELECT 'spells' AS t, count(*) AS still_bare FROM spells
  WHERE source_book IN ('Palladium Fantasy RPG Main Book', 'palladium-fantasy-core', 'Palladium Fantasy RPG 2nd Ed.')
UNION ALL SELECT 'skills', count(*) FROM skills
  WHERE source_book IN ('Palladium Fantasy RPG Main Book', 'palladium-fantasy-core', 'Palladium Fantasy RPG 2nd Ed.')
UNION ALL SELECT 'gear', count(*) FROM gear
  WHERE source_book IN ('Palladium Fantasy RPG Main Book', 'palladium-fantasy-core', 'Palladium Fantasy RPG 2nd Ed.');

-- Records this run. REQUIRED: the smoke test fails a data script with no footer.
-- The run record follows the file. This script was applied to production
-- under its OLD name before the rename, and that name never existed in
-- `main` - so the row asserts a file the repo does not have and would read
-- as drift forever. Removing it is the `fix-seed-dev-run-record.sql`
-- precedent: only a record that says something untrue is deleted, and this
-- one names a file nobody can read.
DELETE FROM data_script_runs WHERE filename = 'fix-pf-citations.sql';
INSERT INTO data_script_runs (filename) VALUES ('zzzz-cite-pf-rows.sql');
