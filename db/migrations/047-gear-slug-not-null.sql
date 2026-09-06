-- `gear.slug` becomes NOT NULL.
--
-- RETRO-AUDIT R21, the last thing it left standing. `044` made the slug the
-- portable key for inventory and `046` made it the ONLY key, which put the
-- whole of inventory's meaning on a column the schema still allowed to be null.
-- `UNIQUE` does not help: SQLite permits any number of NULLs in a unique
-- column, so two slugless gear rows were always legal and either would have
-- matched nothing on the join that now renders every character's kit.
--
-- FREE TODAY, MEASURED RATHER THAN ASSUMED. Production, 2026-09-06, re-measured
-- for this migration rather than carried from R21's note:
--
--   node scripts/q.mjs --remote "SELECT count(*) AS gear_rows, sum(CASE WHEN slug IS NULL THEN 1 ELSE 0 END) AS null_slug, sum(CASE WHEN trim(COALESCE(slug,'')) = '' THEN 1 ELSE 0 END) AS null_or_empty, count(DISTINCT slug) AS distinct_slugs FROM gear"
--   -> 1025 rows, 0 null, 0 empty, 1025 distinct
--
-- NO CODE CHANGE, AND THEREFORE NO DEPLOY WINDOW - unlike `045`/`046`, which
-- needed two steps precisely because a drop breaks deployed code. Nothing reads
-- or writes gear differently after this; the database simply starts refusing
-- what the app already refuses. `catalog-fields.js` marks gear's slug
-- `required: true` and `coerceField` counts '' as blank, so the catalog editor
-- and the importers have never been able to write one. All 477 `INSERT INTO
-- gear` statements in the committed data scripts name `slug` - checked, none
-- omits it and none inserts by SELECT without a column list - so a rebuild
-- cannot trip the new constraint either.
--
-- WHAT THIS DOES NOT DO: refuse an EMPTY STRING. `NOT NULL` is what R21 asked
-- for and what this takes, and '' would still satisfy it while joining to
-- nothing - the same hazard in a different disguise. It is unreachable through
-- the API today, for the reason above, and closing it in the database would
-- need a `CHECK (slug <> '')`, which is a further decision and a further
-- rebuild. Said here rather than left for someone to discover.
--
-- ===================================================================
-- WHY THIS REBUILDS THREE TABLES TO CHANGE ONE COLUMN
-- ===================================================================
--
-- SQLite cannot add NOT NULL in place, so `gear` has to be rebuilt. `gear` is
-- the first table in this repo that anything REFERENCES: `character_items` and
-- `campaign_items` both declare `gear_slug TEXT REFERENCES gear(slug)`. That
-- makes `036`'s twelve-step precedent inapplicable, and its own header says why
-- without meaning to - it notes that "nothing references it by foreign key",
-- which is exactly the case this is not.
--
-- TWO THINGS WERE TRIED AGAINST LOCAL D1 FIRST, AND BOTH FAILED:
--
--   PRAGMA foreign_keys = OFF     IGNORED. D1 enforces the constraint anyway:
--                                 "FOREIGN KEY constraint failed". This is
--                                 `036`'s pattern, and `036` only ever worked
--                                 because it had no referencing table.
--   PRAGMA defer_foreign_keys = ON  HONOURED, and still fails. Enforcement moves
--                                 to commit - "the application left the database
--                                 in a state where constraints were violated" -
--                                 because a DROP of the parent records one
--                                 violation per orphaned child and recreating
--                                 the parent afterwards does not clear them.
--
-- Both attempts left the database untouched, which is the right failure: D1
-- rolled the Durable Object back to its last good state.
--
-- SO THE ORDER DOES THE WORK INSTEAD, and no PRAGMA is needed. Each step is
-- legal with foreign keys fully enforced the whole way through:
--
--   1. build `gear_new` with the constraint, and copy into it;
--   2. rebuild each child to reference `gear_new`, so nothing points at `gear`;
--   3. drop `gear`, which is now unreferenced;
--   4. rename `gear_new` to `gear` - and SQLite REWRITES both children's
--      REFERENCES clauses to follow the rename.
--
-- Step 4 is the part worth checking rather than trusting, so it was: a probe on
-- local D1 renamed a parent and read the child back out of `sqlite_master`,
-- which came back as REFERENCES "zz_parent_new"(slug). D1 does not run with
-- `legacy_alter_table`, so the rewrite happens. The children end up quoting the
-- table name - REFERENCES "gear"(slug) - which is cosmetic.
--
-- IDS ARE COPIED EXPLICITLY, in all three tables. `catalog_redirects.to_id`
-- points at gear ids - twenty redirects do - and a rebuild that let
-- AUTOINCREMENT reassign them would silently repoint every one at the wrong
-- row. Every copy names its columns rather than SELECT *, so a column added
-- later fails loudly here instead of shifting values one to the left.

-- ===== 1. gear, with the constraint =====
CREATE TABLE gear_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,            -- what equipment_starting[].item_id references,
                                        -- and since migration 046 the only key
                                        -- inventory holds. NOT NULL since 047.
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'both')),
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
);

INSERT INTO gear_new
  (id, slug, name, system, category, weight_lbs, cost, cost_note, damage,
   is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book)
SELECT
   id, slug, name, system, category, weight_lbs, cost, cost_note, damage,
   is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book
  FROM gear;

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
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,
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

DROP TABLE campaign_items;

ALTER TABLE campaign_items_new RENAME TO campaign_items;

CREATE INDEX IF NOT EXISTS idx_campaign_items_campaign ON campaign_items (campaign_id);

-- ===== 3. nothing references `gear` now =====
DROP TABLE gear;

-- ===== 4. and the rename carries both children with it =====
ALTER TABLE gear_new RENAME TO gear;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('047-gear-slug-not-null.sql');
