-- INGESTION-AUDIT F32: one Sleeping Bag row, and the class-import stub retired.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-ingestion-f32-sleeping-bag.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-ingestion-f32-sleeping-bag.sql
--
-- The gear catalog held Sleeping Bag twice, both `rifts`, both cost 110, both
-- cited to Rifts Ultimate Edition p.261-265:
--
--   sleeping-bag        cited by 3 published classes
--   sleeping-bag-rifts  cited by 10, and its own description ended
--                       "Same item as the plain Sleeping Bag row; the two
--                        should probably be merged."
--
-- It is a CLASS-IMPORT STUB that was fleshed out instead of retired.
-- add-burster-class.sql and add-psi-stalker-class.sql both create it as
-- 'STUB - created by class import, needs stats', which is exactly the shape
-- retire-orphan-gear-stubs.sql exists for; backfill-rue-equipment.sql and
-- zzz-gear-tidy-1-names.sql then gave it real stats and the real name, so it
-- stopped looking like a stub and started looking like a second product.
--
-- sleeping-bag survives because it is the canonical slug. The ten citations
-- MOVE WITH IT rather than relying on the redirect: class equipment is cited by
-- slug, and RETRO-AUDIT R20 established that the wizard's boot payload carries
-- no redirects - the server resolves them and the picker does not.
--
-- No character holds either row: character_items was 0 for both slugs on
-- 2026-09-06. The repoint below is a guard, not a repair.
--
-- This sorts after every add-*-class.sql that writes these citations, after
-- backfill-rue-equipment.sql and after zzz-gear-tidy-1-names.sql, which are the
-- later writers of the row it retires.

-- 1. The ten classes point at the surviving slug.
UPDATE imported_classes
   SET markdown = replace(markdown, '"sleeping-bag-rifts"', '"sleeping-bag"')
 WHERE markdown LIKE '%sleeping-bag-rifts%';

-- 2. Any character holding the stub moves too. Zero rows today; guarded so a
--    later environment that does have some is not left pointing at nothing.
UPDATE character_items
   SET gear_slug = 'sleeping-bag'
 WHERE gear_slug = 'sleeping-bag-rifts';

-- 3. The retired slug forwards, before the delete rather than after, so there
--    is never a moment with a dead slug and no forwarding address.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'sleeping-bag-rifts', id, 'merge'
  FROM gear
 WHERE slug = 'sleeping-bag'
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- 4. Retire the stub. Guarded on the cost so it cannot fire against a row
--    someone has since corrected into something else.
DELETE FROM gear
 WHERE slug = 'sleeping-bag-rifts'
   AND cost = 110;

-- --- readbacks ---

SELECT 'one Sleeping Bag row under rifts' AS assertion,
       (SELECT count(*) FROM gear WHERE name = 'Sleeping Bag' AND system = 'rifts') AS got,
       1 AS want;

SELECT 'the stub is retired' AS assertion,
       (SELECT count(*) FROM gear WHERE slug = 'sleeping-bag-rifts') AS got,
       0 AS want;

SELECT 'no published class still cites the stub' AS assertion,
       (SELECT count(*) FROM imported_classes
         WHERE status = 'published' AND deleted_at IS NULL
           AND markdown LIKE '%sleeping-bag-rifts%') AS got,
       0 AS want;

SELECT 'thirteen classes now cite the survivor' AS assertion,
       (SELECT count(*) FROM imported_classes
         WHERE status = 'published' AND deleted_at IS NULL
           AND markdown LIKE '%"sleeping-bag"%') AS got,
       13 AS want;

SELECT 'the retired slug forwards to the survivor' AS assertion,
       (SELECT count(*) FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
         WHERE r.catalog = 'gear' AND r.from_key = 'sleeping-bag-rifts'
           AND g.slug = 'sleeping-bag') AS got,
       1 AS want;

-- The Palladium Fantasy sleeping bag is a DIFFERENT item at a different price
-- and must be untouched - INGESTION-AUDIT F31 is the guard that stops the
-- duplicate finder confusing the two.
SELECT 'the Palladium Fantasy row is not collateral' AS assertion,
       (SELECT count(*) FROM gear WHERE slug = 'sleeping-bag-pf' AND cost = 30) AS got,
       1 AS want;

-- Records this run. Every statement above guards itself, so the script is safe
-- to re-run, and a run that correctly did nothing is still a run that happened.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ingestion-f32-sleeping-bag.sql');
