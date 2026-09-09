-- `character_vehicles`: the vessel a character owns, and the damage it carries.
--
-- Vessels have been a catalog since migration 048 and readable since the codex
-- learned the section, but nothing could OWN one. `character_items.gear_slug`
-- REFERENCES gear(slug), so a robot could not be put in an inventory even in
-- principle.
--
-- A SEPARATE TABLE RATHER THAN A COLUMN ON `character_items`, and the reasons
-- are structural rather than tidiness:
--
--   * that table's CHECK and its gear(slug) foreign key are load-bearing, and
--     widening them to mean "gear OR vessel" makes both weaker;
--   * the sheet's inventory table renders every row that endpoint returns, so a
--     robot would arrive as a line item with a quantity box;
--   * a vessel is not a thing you carry three of. `qty` and `equipped` are the
--     wrong questions and `mdc_current` is the right one, and no single table
--     answers both sets well.
--
-- `mdc_current` IS JSON KEYED BY LOCATION NAME, because the maxima are catalog
-- data and the damage is per-instance: two Glitter Boys in a party take
-- different hits to the same arm. `vehicle_locations` gives the maximum for
-- "Left Arm"; this holds {"Left Arm": 180} for THIS one. A location absent from
-- the object is undamaged, which makes a fresh vessel `{}` rather than a
-- pre-populated copy of the catalog - and means a book correcting a location's
-- M.D.C. does not have to rewrite every character who owns one.
--
-- The precedent is `characters.armor`, which already tracks mdc_current against
-- mdc_max as JSON, and `character_items.enchantments`, which is the pattern for
-- a JSON column on a joined child table. `_lib/character-json.js` owns the
-- empty value for both, and now for this one: `{}`, not `[]` and not NULL.
--
-- Soft removal via `removed_at`, exactly as `character_items` does it: a vessel
-- lost in play is history, not a mistake to erase. `journal_entry_id` ties the
-- acquisition or the loss to the session it happened in.
--
-- `nickname` exists because people name their machines and the catalog name is
-- the model. "Betsy" is a UAR-1 Enforcer.
CREATE TABLE IF NOT EXISTS character_vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  vehicle_slug TEXT REFERENCES vehicles(slug),        -- NULL = freeform, custom_name required
  custom_name TEXT,
  nickname TEXT,
  mdc_current TEXT,                                   -- JSON object keyed by vehicle_locations.location
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                    -- NULL = still owned
  CHECK (vehicle_slug IS NOT NULL OR custom_name IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_character_vehicles_character
  ON character_vehicles (character_id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('052-character-vehicles.sql');
