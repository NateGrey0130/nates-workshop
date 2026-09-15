-- Move Heroes Unlimited's Back Pack off a RETIRED slug.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-hu-back-pack-slug.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-hu-back-pack-slug.sql
--
-- ===================================================================
-- WHAT WENT WRONG
-- ===================================================================
--
-- add-hu-gear-g-field-and-containers.sql imported the containers list on
-- printed 218 and gave its Back Pack the slug `back-pack`. The generator that
-- wrote it checks for collisions by reading the slugs PRODUCTION HOLDS, found
-- nothing at `back-pack`, and took it.
--
-- `back-pack` was not free. merge-backpack-duplicate.sql had retired it - the
-- row was deleted into `backpack` and a `catalog_redirects` row was left
-- pointing `back-pack` -> `backpack`. A retired slug is ABSENT FROM THE TABLE
-- AND STILL TAKEN, and reading the table cannot tell the two apart.
--
-- Two consequences, and the second is the one that hid:
--
--   * In production the row went in, so `back-pack` is now simultaneously a
--     live gear slug AND a redirect from_key. merge-backpack-duplicate's own
--     header calls that out as "a trap for whoever reads it next"; the
--     redirect is inert only because _lib/catalog.js consults redirects for
--     keys it does NOT find.
--   * On a CLEAN REBUILD the order runs the other way. Filename order is
--     execution order, `add-` sorts before `merge-`, so the row is inserted
--     and then deleted again by the merge. A rebuilt database held 2009 gear
--     rows against production's 2010.
--
-- Nothing reported this but a count. regression.mjs compares the clean-run gear
-- total to the pinned figure and said "README says 2010, a clean run produced
-- 2009" - which is the whole reason that check is there, and it still does not
-- name the row. The row was found by diffing the two slug lists.
--
-- ===================================================================
-- WHAT THIS DOES
-- ===================================================================
--
-- Renames the live production row to `back-pack-hu`, the suffix this import
-- already uses wherever another book holds the plain spelling. The data script
-- has been corrected to emit `back-pack-hu` directly, so on a fresh build this
-- file matches nothing and is a no-op - it exists to repair environments where
-- the wrong slug was already applied.
--
-- IT SORTS AFTER THE FILE IT CORRECTS (`add-` < `fix-`) and before `merge-`,
-- which is what makes it work on a rebuilt database as well as this one.
--
-- The bug was never the redirect. It was a new row landing on a key the
-- redirect had already spoken for.

UPDATE gear
   SET slug = 'back-pack-hu'
 WHERE slug = 'back-pack'
   AND system = 'heroes-unlimited'
   AND source_book = 'Revised Heroes Unlimited p.218';

-- ASSERTIONS.

SELECT 'the Heroes Unlimited back pack is on its own slug' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'back-pack-hu' AND system = 'heroes-unlimited' AND cost = 60;

-- THE RETIRED SLUG CARRIES NO GEAR ROW AGAIN. This is the assertion that would
-- have caught the original mistake.
SELECT 'no gear row sits on the retired back-pack slug' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE slug = 'back-pack';

-- NO ASSERTION HERE COUNTS A REDIRECT, and that is deliberate rather than an
-- omission. The obvious one to write - "the back-pack redirect still points
-- where it did" - passes in production and FAILS ON EVERY CLEAN BUILD, because
-- the redirect is created by merge-backpack-duplicate.sql, which sorts after
-- this file. An assertion about a row another data script has not written yet
-- is a check that only works in the environment it was written in, which is
-- the same mistake in a different column.
--
-- The general shape is still worth saying in prose: one other live gear slug is
-- also a redirect from_key - `dead-boy-body-armor`, in the Rifts catalog. It
-- predates this import, it does NOT vanish on a rebuild the way this one did,
-- and it is filed rather than fixed inside a Heroes Unlimited pull request.
--
-- The redirect this row collided with is LEFT ALONE. `back-pack` -> `backpack`
-- is still the right answer for anything holding the retired spelling.

INSERT INTO data_script_runs (filename) VALUES ('fix-hu-back-pack-slug.sql');
