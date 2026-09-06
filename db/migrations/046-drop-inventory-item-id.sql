-- Inventory stops carrying a gear id at all.
--
-- RETRO-AUDIT R21, second half. Migration 044 added `gear_slug` beside
-- `item_id` and moved every read onto the slug, which closed the portability
-- hazard: a catalog id is INTEGER PRIMARY KEY AUTOINCREMENT, so it is insertion
-- order, and ZERO of production's 1025 gear ids matched a database rebuilt from
-- this repo. 044 was deliberately additive and said the drop was a separate
-- decision. This is that decision, taken 2026-09-06.
--
-- WHY A REBUILD RATHER THAN A DROP COLUMN. SQLite refuses `ALTER TABLE ... DROP
-- COLUMN item_id` while a CHECK constraint names the column - tested rather than
-- assumed, on a scratch database:
--
--   with    CHECK (item_id IS NOT NULL OR custom_name IS NOT NULL)
--             -> "error in table character_items after drop column:
--                 no such column: item_id"
--   without the CHECK
--             -> DROP SUCCEEDED
--
-- So the CHECK is the sole blocker. 045 has already moved it to `gear_slug`,
-- which is a rebuild in its own right, and this is the second: SQLite cannot
-- drop a column in place any more than it can alter a CHECK. The documented
-- twelve-step, on 036's precedent -
-- minus the steps these tables do not need. Unlike 036 they DO have an index
-- each, recreated below; unlike 036 they also have outgoing foreign keys, which
-- the new CREATE carries verbatim. NOTHING references either table by foreign
-- key, checked with `grep -n "REFERENCES character_items\|REFERENCES
-- campaign_items" db/schema.sql` - no hits - so no inbound key breaks.
--
-- The copy lists columns by NAME rather than SELECT *, for 036's reason: a
-- column added later fails loudly here instead of silently shifting values one
-- to the left.
--
-- SAFE TO RUN ON A DATABASE THAT ALREADY HAS `gear_slug` POPULATED, which is
-- every database 044 has reached. The backfill below repeats 044's, because
-- this migration must not depend on 044 having been run in the same session,
-- and because a row that arrived between the two would otherwise fail the new
-- CHECK. Measured against production 2026-09-06 immediately before this ran:
-- 78 rows, 78 with a slug, 0 that would fail the new CHECK, 0 orphaned ids,
-- campaign_items empty.

-- Belt and braces: anything still holding only an id gets its slug now, while
-- the id is still here to derive it from. This is the last moment that is
-- possible.
UPDATE character_items
   SET gear_slug = (SELECT slug FROM gear WHERE gear.id = character_items.item_id)
 WHERE item_id IS NOT NULL AND gear_slug IS NULL;

UPDATE campaign_items
   SET gear_slug = (SELECT slug FROM gear WHERE gear.id = campaign_items.item_id)
 WHERE item_id IS NOT NULL AND gear_slug IS NULL;

PRAGMA foreign_keys = OFF;

-- ===== character_items =====
CREATE TABLE character_items_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear(slug),               -- NULL = freeform custom item
  custom_name TEXT,                                   -- required for freeform items
  qty INTEGER NOT NULL DEFAULT 1,
  equipped INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  enchantments TEXT,                                  -- JSON array of enchantment slugs
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                    -- NULL = currently in inventory
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);

INSERT INTO character_items_new
  (id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments,
   journal_entry_id, added_at, removed_at)
SELECT
   id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments,
   journal_entry_id, added_at, removed_at
  FROM character_items;

DROP TABLE character_items;

ALTER TABLE character_items_new RENAME TO character_items;

-- The index went with the dropped table. 036 had none to recreate; these do.
CREATE INDEX IF NOT EXISTS idx_character_items_character ON character_items (character_id);

-- ===== campaign_items =====
CREATE TABLE campaign_items_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear(slug),             -- NULL = freeform custom item
  custom_name TEXT,                                 -- required for freeform items
  qty INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                  -- NULL = still in the stash
  removed_by TEXT,
  claimed_by_character_id INTEGER REFERENCES characters(id) ON DELETE SET NULL,
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);

INSERT INTO campaign_items_new
  (id, campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id,
   added_by, added_at, removed_at, removed_by, claimed_by_character_id)
SELECT
   id, campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id,
   added_by, added_at, removed_at, removed_by, claimed_by_character_id
  FROM campaign_items;

DROP TABLE campaign_items;

ALTER TABLE campaign_items_new RENAME TO campaign_items;

CREATE INDEX IF NOT EXISTS idx_campaign_items_campaign ON campaign_items (campaign_id);

PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('046-drop-inventory-item-id.sql');
