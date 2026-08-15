-- 010 — forwarding pointers for retired catalog keys.
--
-- Merging two catalog rows deletes one of them. Repointing the characters that
-- held it is only half the job: class markdown cites gear by SLUG in
-- equipment_starting[].item_id, and skills, spells and psionics BY NAME. A
-- merge deliberately never rewrites that markdown — it is frontmatter mixed
-- with prose — so afterwards those citations name a key that no longer exists.
--
-- This table remembers where the key went, so the citation still resolves.
--
-- from_key is COLLATE NOCASE because every other key comparison in the app is
-- case-insensitive; a redirect that only fires on exact case would be a trap.
CREATE TABLE IF NOT EXISTS catalog_redirects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,                          -- skills | spells | psionics | gear
  from_key TEXT NOT NULL COLLATE NOCASE,          -- the retired slug or name
  to_id INTEGER NOT NULL,                         -- row in that catalog's table
  reason TEXT NOT NULL DEFAULT 'merge',           -- merge | rename
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (catalog, from_key)
);

-- Merging a row that is already a redirect target has to move those redirects
-- onto the survivor, which looks them up by target.
CREATE INDEX IF NOT EXISTS idx_catalog_redirects_target ON catalog_redirects (catalog, to_id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('010-catalog-redirects.sql');
