-- Widen `gear.system` so rows from a THIRD and FOURTH game can be tagged.
--
-- BOOK-INGEST-AUDIT F73, the half left standing. F73 was taken once already in
-- PR #996, as its own Option C - catalog and classes only, the CHECK left alone
-- because that was the recorded decision for the Nightbane batch. `parser.js`
-- has admitted `nightbane` and `heroes-unlimited` since; this is the table
-- catching up with the parser.
--
-- SQLite cannot alter a CHECK in place, so `gear` is rebuilt. The technique
-- is migration 047's, and the ORDER is what makes it legal with foreign keys
-- fully enforced the whole way through - no pragma is used, because D1 ignores
-- the ones that would help and one of them destroys data silently. See
-- `058-campaign-system-third-game.sql` for the probe that established that.
--
--   subtree rebuilt (3): gear, character_items, campaign_items
--
--   1. build a suffixed copy of every table, REFERENCES already pointing at the
--      other copies;
--   2. copy the rows, parents before children;
--   3. drop the originals, children before parents;
--   4. rename the copies back - SQLite rewrites the REFERENCES clauses to follow;
--   5. recreate the indexes and triggers, which went with their tables in 3.
--
-- NO BEHAVIOUR CHANGE FOR EITHER EXISTING SYSTEM. Nothing is dropped, no column
-- changes type, no default moves.

-- 1. the suffixed copies.

CREATE TABLE gear_w059 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,            -- what equipment_starting[].item_id references,
                                        -- and since migration 046 the only key
                                        -- inventory holds. NOT NULL since 047.
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
  source_book TEXT
, vehicle_slug TEXT);

CREATE TABLE character_items_w059 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear_w059(slug),           -- NULL = freeform custom item
  custom_name TEXT,
  qty INTEGER NOT NULL DEFAULT 1,
  equipped INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  enchantments TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);

CREATE TABLE campaign_items_w059 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear_w059(slug),         -- NULL = freeform custom item
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

-- 2. the rows, parents before children.

INSERT INTO gear_w059 (id, slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) SELECT id, slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug FROM gear;

INSERT INTO character_items_w059 (id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments, journal_entry_id, added_at, removed_at) SELECT id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments, journal_entry_id, added_at, removed_at FROM character_items;

INSERT INTO campaign_items_w059 (id, campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id, added_by, added_at, removed_at, removed_by, claimed_by_character_id) SELECT id, campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id, added_by, added_at, removed_at, removed_by, claimed_by_character_id FROM campaign_items;

-- 3. the originals, children before parents.

DROP TABLE campaign_items;
DROP TABLE character_items;
DROP TABLE gear;

-- 4. the copies take their names back.

ALTER TABLE gear_w059 RENAME TO gear;
ALTER TABLE character_items_w059 RENAME TO character_items;
ALTER TABLE campaign_items_w059 RENAME TO campaign_items;

-- 5. the 2 indexes and triggers that went with the tables in step 3.

CREATE INDEX idx_character_items_character ON character_items (character_id);
CREATE INDEX idx_campaign_items_campaign ON campaign_items (campaign_id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('059-gear-system-third-game.sql');

-- VERIFICATION.

SELECT 'gear admits four systems' AS assertion,
       CASE WHEN instr(sql, '''nightbane''') > 0 AND instr(sql, '''heroes-unlimited''') > 0
            THEN 1 ELSE 0 END AS got, 1 AS want
  FROM sqlite_master WHERE name = 'gear';

SELECT 'gear kept its rows' AS assertion, count(*) AS got, 1461 AS want FROM gear;
SELECT 'character_items kept its rows' AS assertion, count(*) AS got, 57 AS want FROM character_items;
SELECT 'campaign_items kept its rows' AS assertion, count(*) AS got, 0 AS want FROM campaign_items;

SELECT 'every index and trigger is back' AS assertion, count(*) AS got, 2 AS want
  FROM sqlite_master
 WHERE type IN ('index', 'trigger') AND sql IS NOT NULL
   AND tbl_name IN ('gear', 'character_items', 'campaign_items');

SELECT 'no suffixed table survived' AS assertion, count(*) AS got, 0 AS want
  FROM sqlite_master WHERE name LIKE '%_w059';