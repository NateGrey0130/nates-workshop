-- 084: city_themes - a G.M.'s saved City Creator themes, for reuse.
--
-- A theme ("Old West boomtown") costs five AI calls to write, and a good one
-- is worth using again for the next town (Nate, 2026-09-24: a saved theme
-- library rather than one theme per city). `pack` is the whole theme as the
-- engine checks it (validateThemePack in apps/city-creator/js/city-engine.js),
-- its name pool included; the server checks it again on every write.
--
-- OWNER ONLY. Read and written by `owner_email` and nobody else, and anyone
-- else gets a 404, as the NPC library does. A city made from a saved theme
-- keeps its OWN copy of the pack, so editing or deleting a saved theme never
-- changes a city already kept.
--
-- A pack belongs to one game: its shop kinds sell by that game's stock rules
-- and its roles roll as that game's classes. `adapted_from` is the theme this
-- one was adapted from for another game, kept only as a pointer.
CREATE TABLE IF NOT EXISTS city_themes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_email TEXT NOT NULL,
  name TEXT NOT NULL,
  system TEXT NOT NULL CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  prompt TEXT NOT NULL,
  pack TEXT NOT NULL,
  adapted_from INTEGER REFERENCES city_themes(id) ON DELETE SET NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_city_themes_owner ON city_themes (owner_email, system);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('084-city-themes.sql');
