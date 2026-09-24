-- 082: msh_heroes - the heroes people save in Marvel Heroes (apps/marvel-heroes).
--
-- One row per saved hero, owned by the Access email that saved it; every read
-- and write is scoped to that owner, as MediaVault's media_items is. Nothing is
-- shared between people.
--
-- `build` is the generator's own state (seeds and picks), so a hero reopens in
-- the generator exactly as it was made. `snapshot` is what that state built,
-- resolved to names and numbers at save time: the sheet draws from it, so a
-- later correction to the app's tables cannot quietly change a saved hero.
-- `sheet` holds what the player writes on the sheet (identity, base, notes).
-- All three are JSON text. The msh_ prefix is the collision boundary: this is
-- another app's table.
CREATE TABLE IF NOT EXISTS msh_heroes (
  id TEXT PRIMARY KEY,
  owner_email TEXT NOT NULL,
  name TEXT NOT NULL,
  build TEXT NOT NULL,
  snapshot TEXT NOT NULL,
  sheet TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_heroes_owner ON msh_heroes (owner_email, updated_at);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('082-msh-heroes.sql');
