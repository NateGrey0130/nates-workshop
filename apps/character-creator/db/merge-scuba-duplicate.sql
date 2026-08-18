-- Merge the SCUBA duplicate: 'SCUBA' (added by the RUE skill-list import,
-- add-rue-skills-batch.sql) duplicates the pre-existing 'S.C.U.B.A.' (RUE
-- description-page import). Same numbers on both rows (50% +5/lvl); the
-- periods defeated the import's similarity pass, and the catalog editor's
-- Find duplicates caught it in the top tier.
--
-- This reproduces exactly what the editor's merge endpoint does
-- (_lib/catalog-merge.js mergeRows), minus the character rewrite - verified
-- unnecessary in both environments: no character holds the name 'SCUBA' and
-- no class markdown mentions it. The keeper is the OLDER row, whose name any
-- existing reference would use.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/merge-scuba-duplicate.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/merge-scuba-duplicate.sql
--
-- Every statement guards itself: names are resolved, not hard-coded ids
-- (the two environments assigned different ids), and re-running or running
-- where the merge already happened does nothing.

-- Redirects pointing at the row about to disappear move onto the survivor.
UPDATE catalog_redirects
SET to_id = (SELECT id FROM skills WHERE name = 'S.C.U.B.A.')
WHERE catalog = 'skills'
  AND to_id = (SELECT id FROM skills WHERE name = 'SCUBA')
  AND EXISTS (SELECT 1 FROM skills WHERE name = 'S.C.U.B.A.')
  AND EXISTS (SELECT 1 FROM skills WHERE name = 'SCUBA');

-- Forwarding address for the retired name.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'SCUBA', (SELECT id FROM skills WHERE name = 'S.C.U.B.A.'), 'merge'
WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'S.C.U.B.A.')
  AND EXISTS (SELECT 1 FROM skills WHERE name = 'SCUBA')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- The losing row goes, only while the survivor exists.
DELETE FROM skills
WHERE name = 'SCUBA'
  AND EXISTS (SELECT 1 FROM skills WHERE name = 'S.C.U.B.A.');

-- Read the result back rather than trusting the exit code.
SELECT name FROM skills WHERE name IN ('SCUBA', 'S.C.U.B.A.');
SELECT from_key, to_id, reason FROM catalog_redirects WHERE catalog = 'skills' AND from_key = 'SCUBA';
SELECT COUNT(*) AS chars_holding_scuba FROM characters, json_each(skills) WHERE json_extract(value, '$.name') = 'SCUBA';
