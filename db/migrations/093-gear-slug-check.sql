-- `gear.slug` refuses an empty string.
--
-- `047` made the slug NOT NULL and said, in its own header, what it left: ''
-- satisfies NOT NULL and UNIQUE, and joins to nothing, which is the hazard 047
-- closed for NULL in a different disguise. A slug is what `character_items`
-- and `campaign_items` store, so a gear row with an empty one is a row no
-- inventory can name. This is that CHECK, as its own migration (Nate,
-- 2026-10-12: its own row, not folded into the soft-delete work).
--
-- FREE TODAY, MEASURED. Production on 2026-10-15 held 4,404 gear rows and none
-- with slug = ''. The app has never written one: `catalog-fields.js` marks
-- gear's slug `required: true` and `coerceField` counts '' as blank, and the
-- class importer's stub INSERT is `INSERT OR IGNORE`, which skips a row a CHECK
-- refuses rather than failing the import.
--
-- ===================================================================
-- THE SAME THREE-TABLE REBUILD AS 047, AND FOR THE SAME REASON
-- ===================================================================
--
-- SQLite cannot add a CHECK to a table, so `gear` is rebuilt, and D1 ignores
-- `PRAGMA foreign_keys = OFF`, so the two tables that declare
-- `REFERENCES gear(slug)` are rebuilt with it. 047's header records both
-- PRAGMAs failing; the order below is its order, legal with foreign keys
-- enforced at every step:
--
--   1. build `gear_new` with the CHECK, and copy into it;
--   2. rebuild each child to reference `gear_new`, so nothing points at `gear`;
--   3. drop `gear`, which is now unreferenced;
--   4. rename `gear_new` to `gear`, and SQLite rewrites both children's
--      REFERENCES clauses to follow it.
--
-- EVERY COLUMN, INDEX AND DEFAULT IS db/schema.sql's, read on origin/main and
-- against production's sqlite_master on 2026-10-19, not copied from 047.
-- Since 047, `gear` gained `vehicle_slug` (053) and `character_items` gained
-- `ammo_current` (083), both by ALTER, so both sit at the END of production's
-- tables. They are rebuilt in schema.sql's order, which puts `ammo_current`
-- before `journal_entry_id`: every copy names its columns, so the order is the
-- only thing that moves, and a database built fresh and one migrated now have
-- the same table. No trigger and no view names any of the three; the two
-- indexes are recreated below and gear's UNIQUE index comes with its table.
-- No ON DELETE clause is added to either child, as none was there.
--
-- IDS ARE COPIED EXPLICITLY, as 047 did: `catalog_redirects.to_id` points at
-- gear ids. AND THE AUTOINCREMENT COUNTER IS CARRIED, which 047 did not do.
-- A rebuilt table's counter starts at the highest id copied into it, so a
-- table whose newest rows were deleted would hand their ids out again.
-- Production's `character_items` counter stood at 243 on 2026-10-19 with its
-- highest id 139, and `play_events` payloads name inventory rows by id - so a
-- reissued id could make an old event's undo reach a different item. Each
-- `_new` table therefore takes the old table's counter when that is higher,
-- before the old one is dropped (a DROP deletes its sqlite_sequence row).

-- ===== 1. gear, with the CHECK =====
CREATE TABLE gear_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE CHECK (slug <> ''),   -- what equipment_starting[].item_id
                                                  -- references and the only key
                                                  -- inventory holds. NOT NULL since
                                                  -- 047; not empty since 093.
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both')),
  category TEXT,
  weight_lbs REAL,
  cost INTEGER,
  cost_note TEXT,
  damage TEXT,
  is_mega_damage INTEGER NOT NULL DEFAULT 0,
  range TEXT,
  payload TEXT,
  rate_of_fire TEXT,
  ar INTEGER,
  sdc INTEGER,
  mdc INTEGER,
  description TEXT,
  source_book TEXT,
  vehicle_slug TEXT                               -- the vessel in `vehicles`, no FK (053)
);

INSERT INTO gear_new
  (id, slug, name, system, category, weight_lbs, cost, cost_note, damage,
   is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description,
   source_book, vehicle_slug)
SELECT
   id, slug, name, system, category, weight_lbs, cost, cost_note, damage,
   is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description,
   source_book, vehicle_slug
  FROM gear;

-- The counter, in two statements because sqlite_sequence has no key: the
-- INSERT covers a `_new` table that received no rows and so has no counter
-- row yet, and the UPDATE covers one whose counter the copy set lower.
INSERT INTO sqlite_sequence (name, seq)
SELECT 'gear_new', seq FROM sqlite_sequence
 WHERE name = 'gear'
   AND NOT EXISTS (SELECT 1 FROM sqlite_sequence WHERE name = 'gear_new');
UPDATE sqlite_sequence
   SET seq = (SELECT seq FROM sqlite_sequence WHERE name = 'gear')
 WHERE name = 'gear_new'
   AND seq < (SELECT seq FROM sqlite_sequence WHERE name = 'gear');

-- ===== 2. the children stop pointing at the old table =====
CREATE TABLE character_items_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear_new(slug),           -- NULL = freeform custom item
  custom_name TEXT,
  qty INTEGER NOT NULL DEFAULT 1,
  equipped INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  enchantments TEXT,
  ammo_current INTEGER,                               -- NULL = full, migration 083
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);

INSERT INTO character_items_new
  (id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments,
   ammo_current, journal_entry_id, added_at, removed_at)
SELECT
   id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments,
   ammo_current, journal_entry_id, added_at, removed_at
  FROM character_items;

INSERT INTO sqlite_sequence (name, seq)
SELECT 'character_items_new', seq FROM sqlite_sequence
 WHERE name = 'character_items'
   AND NOT EXISTS (SELECT 1 FROM sqlite_sequence WHERE name = 'character_items_new');
UPDATE sqlite_sequence
   SET seq = (SELECT seq FROM sqlite_sequence WHERE name = 'character_items')
 WHERE name = 'character_items_new'
   AND seq < (SELECT seq FROM sqlite_sequence WHERE name = 'character_items');

DROP TABLE character_items;

ALTER TABLE character_items_new RENAME TO character_items;

CREATE INDEX IF NOT EXISTS idx_character_items_character ON character_items (character_id);

CREATE TABLE campaign_items_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear_new(slug),         -- NULL = freeform custom item
  custom_name TEXT,
  qty INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,
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

INSERT INTO sqlite_sequence (name, seq)
SELECT 'campaign_items_new', seq FROM sqlite_sequence
 WHERE name = 'campaign_items'
   AND NOT EXISTS (SELECT 1 FROM sqlite_sequence WHERE name = 'campaign_items_new');
UPDATE sqlite_sequence
   SET seq = (SELECT seq FROM sqlite_sequence WHERE name = 'campaign_items')
 WHERE name = 'campaign_items_new'
   AND seq < (SELECT seq FROM sqlite_sequence WHERE name = 'campaign_items');

DROP TABLE campaign_items;

ALTER TABLE campaign_items_new RENAME TO campaign_items;

CREATE INDEX IF NOT EXISTS idx_campaign_items_campaign ON campaign_items (campaign_id);

-- ===== 3. nothing references `gear` now =====
DROP TABLE gear;

-- ===== 4. and the rename carries both children with it =====
ALTER TABLE gear_new RENAME TO gear;

-- READBACK, off sqlite_master (schema-change: pragma_table_info has answered
-- from a stale replica over --remote mid-migration).
SELECT 'gear carries the empty-slug CHECK' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'gear' AND instr(sql, 'CHECK (slug <> '''')') > 0;
SELECT 'both children reference gear, not gear_new' AS assertion, count(*) AS got, 2 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name IN ('character_items', 'campaign_items')
   AND instr(sql, 'gear_new') = 0 AND instr(sql, '"gear"(slug)') > 0;
SELECT 'no _new table is left behind' AS assertion, count(*) AS got, 0 AS want
  FROM sqlite_master
 WHERE name IN ('gear_new', 'character_items_new', 'campaign_items_new');

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('093-gear-slug-check.sql');
