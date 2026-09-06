-- Inventory learns to name its gear by SLUG rather than by row id.
--
-- RETRO-AUDIT R21. `character_items.item_id` and `campaign_items.item_id` store
-- `gear(id)`, and a catalog id is `INTEGER PRIMARY KEY AUTOINCREMENT` - that is
-- INSERTION ORDER, and insertion order is not the same in two databases.
-- Measured 2026-09-05 against a database rebuilt from this repo: ZERO of 1025
-- gear ids matched production. So a rebuilt database would attach every
-- character's inventory to the wrong item, silently, with the foreign key
-- satisfied the whole way.
--
-- Skills, spells and psionics do not have this problem because characters
-- reference them BY NAME inside their JSON columns. Gear was the one catalog
-- referenced by id, and `gear.slug` is already UNIQUE, so the safe key was
-- always there.
--
-- ADDITIVE ON PURPOSE. `item_id` stays. Dropping it needs a full table rebuild
-- - SQLite refuses the drop while the CHECK constraint names the column, tested
-- - and both tables carry indexes and outgoing foreign keys that a rebuild
-- would have to recreate. Ten committed data scripts also join on `item_id`,
-- and `scripts/rebuild-local.mjs` replays every one of them. The portability
-- hazard closes the moment reads prefer the slug; the drop is a separate
-- decision and a separate PR.
--
-- NOT NAMED `item_slug`, which is the obvious name and is already taken:
-- `characters/[id].js` and `campaigns/[id]/items.js` both alias
-- `gear.slug AS item_slug` beside a `SELECT <table>.*`, so a stored column of
-- that name would return two columns called `item_slug` and the row object
-- would silently keep one of them - engine-dependent, and
-- `test/regression.mjs` matches on that alias.

ALTER TABLE character_items ADD COLUMN gear_slug TEXT REFERENCES gear(slug);
ALTER TABLE campaign_items  ADD COLUMN gear_slug TEXT REFERENCES gear(slug);

-- Backfill from the id that is there today. This is the ONE moment the two keys
-- are known to agree, because it happens inside the database that assigned the
-- ids - which is the whole argument for not doing it from the repo.
UPDATE character_items
   SET gear_slug = (SELECT slug FROM gear WHERE gear.id = character_items.item_id)
 WHERE item_id IS NOT NULL AND gear_slug IS NULL;

UPDATE campaign_items
   SET gear_slug = (SELECT slug FROM gear WHERE gear.id = campaign_items.item_id)
 WHERE item_id IS NOT NULL AND gear_slug IS NULL;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('044-inventory-gear-slug.sql');
