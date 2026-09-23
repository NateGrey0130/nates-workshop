-- 080: cities - the City Creator's saved cities, each linked to a campaign.
--
-- The City Creator (apps/city-creator) builds a whole city from a seed. A city
-- worth keeping is saved here AS GENERATED - the whole city, map and name pool
-- included, in `data` - and not as the seed and settings that made it, because
-- the tables and the layout will change and a saved city must not change with
-- them (Nate's decision, the plan's Phase 3).
--
-- NO OWNER COLUMN. A city's G.M. is its campaign's `gm_email`, always, and the
-- campaign G.M. check (requireCampaign) is the only check. A campaign cannot
-- change G.M.; that is accepted, and changing it is out of scope.
--
-- EVERYTHING IS THE G.M.'S BY DEFAULT. `show_map` = 1 lets the campaign's
-- players see the map; inside `data`, each pin carries its own `revealed` flag
-- and each entry a separate `public` text, so a secret can never leak through a
-- field the players share. The player view is built by the SERVER from those,
-- leaving every G.M.-only field out rather than sending it to be hidden.
CREATE TABLE IF NOT EXISTS cities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  data TEXT NOT NULL,
  show_map INTEGER NOT NULL DEFAULT 0,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_cities_campaign ON cities (campaign_id, show_map);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('080-cities.sql');
