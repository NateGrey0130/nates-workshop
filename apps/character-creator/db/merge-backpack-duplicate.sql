-- Merge the Backpack duplicate, and clear the redirect left by the last one.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/merge-backpack-duplicate.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/merge-backpack-duplicate.sql
--
-- 'Backpack' and 'Back Pack' are the same object under two spellings. Checked
-- before acting, because the Revolver looked like a duplicate of W.P. Handguns
-- and was not: these two match on EVERY column - same system, same 100 credit
-- cost, same 8.2 lbs, no M.D.C. or damage on either, and identical text. That
-- is what makes this a real duplicate rather than two things sharing a shape.
--
-- THE KEEPER IS 'backpack', WHICH IS THE NEWER ROW. That departs from the
-- tiebreak merge-scuba-duplicate used, and deliberately: age is only a proxy
-- for "which name do existing references use", and here the answer is not the
-- older one. Fifteen classes and two inventory rows point at 'backpack'; one
-- class and nothing else points at 'back-pack'. Deleting the row the inventory
-- rows are attached to would break them for nothing.
--
-- There is also a stale redirect to clear. A previous merge went the OTHER way
-- and left 'backpack' -> back-pack behind; the class importer then re-created
-- 'backpack' as a fresh row, because fifteen classes ask for that slug and a
-- missing slug gets stubbed. The redirect has been inert ever since - _lib/
-- catalog.js consults redirects only for keys NOT found in the table, and
-- 'backpack' is found - so it has done no harm. It cannot stay, though: its
-- target is about to be deleted, which would leave it dangling, and its
-- from_key is a live slug, which is a trap for whoever reads it next.
--
-- Every statement guards itself: names are resolved rather than hard-coded ids
-- (environments assign different ones), and re-running does nothing.

-- The one class citing the retired spelling is repointed. An exact structured
-- match on the whole entry, not a blind name replace - class markdown is
-- frontmatter plus prose, and a loose replace would hit lore text as readily.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "back-pack", qty: 1 }',
      '  - { item_id: "backpack", qty: 1 }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "back-pack"') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'backpack');

-- The redirect the previous merge left behind. Removed by from_key AND target,
-- so a redirect that legitimately points somewhere else is never touched.
DELETE FROM catalog_redirects
WHERE catalog = 'gear'
  AND from_key = 'backpack'
  AND to_id = (SELECT id FROM gear WHERE slug = 'back-pack')
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'backpack');

-- Any other redirect aimed at the row about to disappear moves onto the keeper.
UPDATE catalog_redirects
SET to_id = (SELECT id FROM gear WHERE slug = 'backpack')
WHERE catalog = 'gear'
  AND to_id = (SELECT id FROM gear WHERE slug = 'back-pack')
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'backpack');

-- Forwarding address for the retired spelling, so anything citing it still
-- resolves instead of being stubbed back into existence on the next import.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'back-pack', (SELECT id FROM gear WHERE slug = 'backpack'), 'merge'
WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'backpack')
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'back-pack')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- Inventory attached to the retired row is REPOINTED, not converted to text.
-- This is the straight repoint the catalog editor's own merge does for gear,
-- which references rows by id: unlike the category placeholders, a backpack is
-- a real object and the character really has one. A character holding both
-- keeps both lines - two of the same item is a quantity, not a duplicate.
UPDATE character_items
SET item_id = (SELECT id FROM gear WHERE slug = 'backpack')
WHERE item_id = (SELECT id FROM gear WHERE slug = 'back-pack')
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'backpack');

-- The losing row goes, once nothing points at it any more.
DELETE FROM gear
WHERE slug = 'back-pack'
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'backpack')
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE c.deleted_at IS NULL
                    AND instr(c.markdown, 'item_id: "back-pack"') > 0)
  AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.item_id = gear.id);

-- Reports the result back, so it is read rather than assumed.
--   duplicate_left       0 = the retired spelling is gone
--   keeper_intact        1 = Backpack is still there, with its stats
--   classes_citing_old   0 = nobody names the retired spelling any more
--   redirect_points_at   'backpack' = and anything that did still resolves
--   stale_redirect       0 = the inert one from the previous merge is cleared
--   dangling_redirects   0 = no gear redirect points at a row that is gone
--   inv_on_keeper        every inventory line that was on either row, now on one
SELECT (SELECT count(*) FROM gear WHERE slug = 'back-pack') AS duplicate_left,
       (SELECT count(*) FROM gear WHERE slug = 'backpack' AND cost IS NOT NULL) AS keeper_intact,
       (SELECT count(*) FROM imported_classes
          WHERE deleted_at IS NULL AND instr(markdown, 'item_id: "back-pack"') > 0) AS classes_citing_old,
       (SELECT g.slug FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
         WHERE r.catalog = 'gear' AND r.from_key = 'back-pack') AS redirect_points_at,
       (SELECT count(*) FROM catalog_redirects
         WHERE catalog = 'gear' AND from_key = 'backpack') AS stale_redirect,
       (SELECT count(*) FROM catalog_redirects r
         WHERE r.catalog = 'gear'
           AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.id = r.to_id)) AS dangling_redirects,
       (SELECT count(*) FROM character_items ci JOIN gear g ON g.id = ci.item_id
         WHERE g.slug = 'backpack') AS inv_on_keeper;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('merge-backpack-duplicate.sql');
