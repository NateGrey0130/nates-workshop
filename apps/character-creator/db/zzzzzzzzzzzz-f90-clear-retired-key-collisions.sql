-- The two live catalog rows sitting on a key a redirect has retired.
--
-- BOOK-INGEST-AUDIT.md F90. One-off data script, run once per environment.
-- NOT a migration - it changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzz-f90-clear-retired-key-collisions.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzz-f90-clear-retired-key-collisions.sql
--
-- A retired key is ABSENT FROM THE CATALOG AND STILL SPOKEN FOR. F90 was filed
-- after a Heroes Unlimited import took `back-pack`, which `gear` did not hold
-- and `merge-backpack-duplicate.sql` had retired; the row went into production
-- and was deleted again on every clean rebuild. That instance is closed. F90
-- names one other case. **There are two**, because the finding's own sweep was
-- gear-only. Both are cleared here so the new regression check can be green.
--
-- Twelve z's for the same reason the F89 file has them: both rows are the
-- residue of earlier scripts, and a corrective file that sorts merely after the
-- ones known to write them today is correct only until the next one lands.
--
-- ===================================================================
-- 1. `SCUBA` IN `skills` - A SELF-REDIRECT, AND A LIVE 409
-- ===================================================================
--
-- Two committed scripts, each working as designed, made this in filename order:
--
--   merge-scuba-duplicate.sql   retires 'SCUBA' into 'S.C.U.B.A.' and files a
--                               `merge` redirect for the old spelling
--   rename-skills-to-rue.sql    renames the SURVIVOR back to 'SCUBA' and files
--                               a `rename` redirect for 'S.C.U.B.A.'
--
-- The result is a redirect whose from_key is the name of the row it points at:
-- id 16, `SCUBA` -> skill 86, which is named `SCUBA`. It is inert for lookups,
-- because `_lib/catalog.js` consults redirects only for keys it does NOT find -
-- and it is NOT inert for writing. `functions/api/character-creator/catalogs/
-- rows.js` calls `keyClash()` on any PATCH carrying the unique field, without
-- comparing it against the row's own current value, so an admin who saves that
-- skill without renaming it is told:
--
--   "SCUBA" redirects to "SCUBA". Remove that redirect first if you mean to
--   reuse the name.   (409)
--
-- Which is exactly what this does. THE OTHER REDIRECT STAYS: `S.C.U.B.A.` ->
-- 86 is the useful one, and anything still holding the retired spelling needs
-- it. `redirectStatements`' `skipKeys` argument prevents the app creating a
-- self-redirect today; this row predates it (2026-08-18).
--
-- ===================================================================
-- 2. `dead-boy-body-armor` IN `gear` - A REDIRECT DEFEATED BY THE ROW
--    IT WAS FILED FOR
-- ===================================================================
--
-- `fix-rue-gear-review.sql` lines 126-136 file a redirect from this key to the
-- real CA-2 Light suit, and say why:
--
--   "Three real armours collapse onto one stub the Coalition Technical Officer
--    cites. CA-2 Light is standard Coalition issue, so that is what the class
--    means; the redirect keeps the class markdown resolving without editing
--    it."
--
-- Then the same file KEEPS the row and rewrites its description to a tombstone.
-- That defeats the redirect completely: a lookup finds the row, so the redirect
-- never fires, and the four classes citing this key resolve to the tombstone
-- instead of to the suit the comment says they mean. The intent is in the file;
-- only the deletion is missing.
--
-- DELETING IT IS WHAT MAKES THE REDIRECT DO ITS JOB. Checked first, the way
-- `merge-backpack-duplicate.sql` checked its own case before acting:
--
--   * 0 rows in `character_items` point at it, so no inventory breaks;
--   * 4 published classes cite it, and 0 cite `ca-2-light-dead-boy-armor`
--     directly - so they are exactly the references the redirect exists for;
--   * regression's class sweep folds redirect from_keys into the set of known
--     gear keys, so those four classes keep resolving on a rebuilt database.
--
-- Its stale description is worth recording rather than preserving: it says the
-- key resolves to `dead-boy-armor-ca-2-light`, a slug that no longer exists -
-- `merge-rifts-armor-duplicates.sql` retired it and re-pointed this redirect at
-- `ca-2-light-dead-boy-armor`. The redirect is right and the prose was stale.
--
-- THE GEAR COUNT DROPS BY ONE, 2164 -> 2163, and the pinned figure in
-- `docs/operations.md` moves with it.

-- ===== 1. The self-redirect =====
-- Named by BOTH sides, so it cannot take the useful `S.C.U.B.A.` row with it.
DELETE FROM catalog_redirects
 WHERE catalog = 'skills'
   AND from_key = 'SCUBA'
   AND to_id = (SELECT id FROM skills WHERE name = 'SCUBA');

-- ===== 2. The tombstone row =====
-- Guarded on the tombstone text, so this cannot delete a row that has since
-- become something else.
DELETE FROM gear
 WHERE slug = 'dead-boy-body-armor'
   AND instr(COALESCE(description, ''), 'Superseded by the three armours') > 0
   AND NOT EXISTS (SELECT 1 FROM character_items WHERE gear_slug = 'dead-boy-body-armor');

-- ASSERTIONS.

-- THE SHAPE ITSELF, which is what F90 is about and what the new regression
-- check now enforces on every pull request.
SELECT 'no live gear row sits on a retired gear key' AS assertion, count(*) AS got, 0 AS want
  FROM gear g JOIN catalog_redirects r ON r.catalog = 'gear' AND r.from_key = g.slug
              JOIN gear t ON t.id = r.to_id;
SELECT 'no live skill sits on a retired skill key' AS assertion, count(*) AS got, 0 AS want
  FROM skills s JOIN catalog_redirects r ON r.catalog = 'skills' AND r.from_key = s.name
                JOIN skills t ON t.id = r.to_id;
SELECT 'nor any spell' AS assertion, count(*) AS got, 0 AS want
  FROM spells p JOIN catalog_redirects r ON r.catalog = 'spells' AND r.from_key = p.name
                JOIN spells t ON t.id = r.to_id;
SELECT 'nor any psionic power' AS assertion, count(*) AS got, 0 AS want
  FROM psionic_powers q JOIN catalog_redirects r ON r.catalog = 'psionics' AND r.from_key = q.name
                        JOIN psionic_powers t ON t.id = r.to_id;

-- THE USEFUL HALF OF EACH PAIR SURVIVES. Deleting the wrong one of the two
-- SCUBA redirects would strand every reference to the retired spelling.
SELECT 'the S.C.U.B.A. redirect still resolves' AS assertion, count(*) AS got, 1 AS want
  FROM catalog_redirects r JOIN skills s ON s.id = r.to_id
 WHERE r.catalog = 'skills' AND r.from_key = 'S.C.U.B.A.' AND s.name = 'SCUBA';
SELECT 'and the skill itself is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'SCUBA';

SELECT 'the dead-boy-body-armor redirect still resolves, and now fires' AS assertion,
       count(*) AS got, 1 AS want
  FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
 WHERE r.catalog = 'gear' AND r.from_key = 'dead-boy-body-armor'
   AND g.slug = 'ca-2-light-dead-boy-armor';
SELECT 'and the tombstone row is gone' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'dead-boy-body-armor';
SELECT 'while the suit it resolves to is not' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'ca-2-light-dead-boy-armor';

-- NOTHING WAS ORPHANED. The check that would have made deleting the row wrong.
SELECT 'no inventory row was left pointing at the deleted key' AS assertion, count(*) AS got, 0 AS want
  FROM character_items WHERE gear_slug = 'dead-boy-body-armor';

-- AND NO REDIRECT WAS LEFT DANGLING, which is the one failure the table exists
-- to prevent and which deleting a row could have caused.
SELECT 'no redirect points at a row that no longer exists' AS assertion, count(*) AS got, 0 AS want
  FROM catalog_redirects r
 WHERE (r.catalog = 'gear' AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.id = r.to_id))
    OR (r.catalog = 'skills' AND NOT EXISTS (SELECT 1 FROM skills s WHERE s.id = r.to_id));

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzz-f90-clear-retired-key-collisions.sql');
