-- INGESTION-AUDIT F28: one canonical Law row, carrying RUE's number.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-ingestion-f28-law-canonical.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-ingestion-f28-law-canonical.sql
--
-- The catalog held the same skill twice:
--
--   id 311  Law             Technical  base 25  'Rifts Skill List'                  cited by 62 classes
--   id 244  Law (General)   Technical  base 35  'Rifts Ultimate Edition p.302-303'  cited by 0
--
-- RUE printed page 303 prints "Law (General; 35%+5%)" - read from the OCR cache
-- at .cache/books/rue page p306, registry page_offset 3. So 35 is the book's
-- number and 25 is not RUE's. 'Rifts Skill List' has no entry in
-- scripts/books.json, so nothing can resolve that row to a page at all; F26
-- documents it as permanently page-less.
--
-- Law SURVIVES rather than Law (General), which is the direction Nate chose and
-- is not the book's own spelling. The reason is the wizard: catalogs.js sends no
-- redirects and app.js filters a class's named skills by exact lowercased name
-- against that payload, so a rename is invisible to the picker even though the
-- server resolves it (skill-bonuses.js, catalog.js). That is RETRO-AUDIT R20's
-- finding and it applies to skills as much as to spells. Keeping the book's name
-- would have meant rewriting 62 classes' frontmatter in this script for a rename
-- nobody asked for. The number is the book's; the name is ours.
--
-- No character holds either row - characters.skills LIKE '%"Law"%' was 0 on
-- 2026-09-06 - so nothing a player owns changes.
--
-- Every statement is guarded on the value it expects, so a second run is a
-- no-op rather than a second edit.

-- 1. Law takes RUE's base and RUE's citation.
UPDATE skills
   SET base = 35,
       source_book = 'Rifts Ultimate Edition p.302-303'
 WHERE name = 'Law'
   AND base = 25
   AND source_book = 'Rifts Skill List';

-- 2. The retired name forwards to it. Written BEFORE the delete so there is
--    never a moment with a deleted row and no forwarding address.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Law (General)', id, 'merge'
  FROM skills
 WHERE name = 'Law'
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- 3. Retire the duplicate. Guarded on the base so this cannot fire against a
--    row someone has since corrected.
DELETE FROM skills
 WHERE name = 'Law (General)'
   AND base = 35;

-- --- readbacks ---

SELECT 'one Law row, carrying RUE''s number' AS assertion,
       (SELECT count(*) FROM skills WHERE name = 'Law' AND base = 35
          AND source_book = 'Rifts Ultimate Edition p.302-303') AS got,
       1 AS want;

SELECT 'the duplicate is retired' AS assertion,
       (SELECT count(*) FROM skills WHERE name = 'Law (General)') AS got,
       0 AS want;

SELECT 'the retired name forwards to the survivor' AS assertion,
       (SELECT count(*) FROM catalog_redirects r JOIN skills s ON s.id = r.to_id
         WHERE r.catalog = 'skills' AND r.from_key = 'Law (General)'
           AND s.name = 'Law') AS got,
       1 AS want;

-- Law: CCW is a different skill from a different book and must be untouched.
SELECT 'Law: CCW is not collateral' AS assertion,
       (SELECT count(*) FROM skills WHERE name = 'Law: CCW' AND base = 30) AS got,
       1 AS want;

-- Records this run. Every statement above guards itself, so the script is safe
-- to re-run, and a run that correctly did nothing is still a run that happened.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ingestion-f28-law-canonical.sql');
