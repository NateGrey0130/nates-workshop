-- Both inventory CHECK constraints move from `item_id` to `gear_slug`.
--
-- RETRO-AUDIT R21. FIRST OF TWO, and it exists entirely so the second one can
-- ship without a deploy window.
--
-- 046 drops `item_id`. A drop inverts the ordering rule in `ship-pr` - schema
-- goes to production BEFORE the merge - because that rule is written for
-- ADDITIVE changes: "code that expects a column merged first is code running
-- against a database that does not have it". Dropping is the mirror image. Run
-- the drop first and the DEPLOYED sheet 500s, because it still joins
-- `gear.id = character_items.item_id`. Merge first and the wizard cannot finish
-- a character, because the new code writes no `item_id` and the OLD CHECK still
-- demands one. Either way something is broken for a Pages deploy.
--
-- This migration removes the second horn. After it, a row is valid when it has
-- a `gear_slug` or a `custom_name` - and BOTH the deployed code and the code in
-- the merge satisfy that, because migration 044 already made every write derive
-- the slug inside its own statement. Nothing about `item_id` changes here: the
-- column stays, still populated, still read by the deployed join.
--
--   this  -> production BEFORE the merge, per the ordering rule
--   merge -> Pages deploys code that never mentions item_id
--   046   -> production AFTER that deploy is live
--
-- SQLite cannot ALTER a CHECK, so this is a table rebuild - the documented
-- twelve-step on 036's precedent, minus the steps these tables do not need.
-- Unlike 036 they carry an index each, recreated after the rename; nothing
-- references either table by foreign key. The copy names its columns rather
-- than SELECT *, so a column added later fails loudly here instead of silently
-- shifting values one to the left.
--
-- Every row must already have a gear_slug or a custom_name or the copy fails on
-- the new CHECK, which is the right way round: loud, before the drop, with the
-- id still there to recover from. Measured against production 2026-09-06:
-- 78 character_items rows, 78 with a slug, 0 that would fail, campaign_items
-- empty.

-- Belt and braces, repeating 044's backfill: this must not depend on 044 having
-- run in the same session, and a row that arrived between the two would
-- otherwise fail the new CHECK.
UPDATE character_items
   SET gear_slug = (SELECT slug FROM gear WHERE gear.id = character_items.item_id)
 WHERE item_id IS NOT NULL AND gear_slug IS NULL;

UPDATE campaign_items
   SET gear_slug = (SELECT slug FROM gear WHERE gear.id = campaign_items.item_id)
 WHERE item_id IS NOT NULL AND gear_slug IS NULL;

PRAGMA foreign_keys = OFF;

CREATE TABLE character_items_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES gear(id),                -- still here; 046 drops it
  gear_slug TEXT REFERENCES gear(slug),               -- the key the CHECK now names
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
  (id, character_id, item_id, gear_slug, custom_name, qty, equipped, notes,
   enchantments, journal_entry_id, added_at, removed_at)
SELECT
   id, character_id, item_id, gear_slug, custom_name, qty, equipped, notes,
   enchantments, journal_entry_id, added_at, removed_at
  FROM character_items;

DROP TABLE character_items;

ALTER TABLE character_items_new RENAME TO character_items;

CREATE INDEX IF NOT EXISTS idx_character_items_character ON character_items (character_id);

CREATE TABLE campaign_items_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES gear(id),              -- still here; 046 drops it
  gear_slug TEXT REFERENCES gear(slug),             -- the key the CHECK now names
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
  (id, campaign_id, item_id, gear_slug, custom_name, qty, notes, journal_entry_id,
   added_by, added_at, removed_at, removed_by, claimed_by_character_id)
SELECT
   id, campaign_id, item_id, gear_slug, custom_name, qty, notes, journal_entry_id,
   added_by, added_at, removed_at, removed_by, claimed_by_character_id
  FROM campaign_items;

DROP TABLE campaign_items;

ALTER TABLE campaign_items_new RENAME TO campaign_items;

CREATE INDEX IF NOT EXISTS idx_campaign_items_campaign ON campaign_items (campaign_id);

PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('045-inventory-check-on-slug.sql');
