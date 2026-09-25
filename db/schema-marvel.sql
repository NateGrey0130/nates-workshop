-- ═══════════════════════════════════════════════════════════════════
-- The Marvel group's database (DB_MARVEL, nates-workshop-marvel): the
-- Marvel Heroes app's tables, and nothing else. groups.json says which group
-- owns what; db/schema.sql is Palladium's database and holds none of these.
--
-- Built the same way as db/schema.sql: everything is CREATE ... IF NOT
-- EXISTS, so re-running it is safe, and each migration in db/migrations/marvel/
-- has a guarded seed line so a database built from this file records itself
-- as migrated. The two migrations keep the numbers they had when these tables
-- lived in the shared database (081, 082), because that is what both
-- databases' schema_migrations recorded.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS schema_migrations (
  filename   TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Marvel Heroes (apps/marvel-heroes): the full text of the Ultimate Powers
-- Book's power listings. Its rows are never in this repository - see migration
-- 081 - so a database built from here has it empty, which the app allows for.
CREATE TABLE IF NOT EXISTS msh_power_text (
  code TEXT PRIMARY KEY,                 -- the roll tables' code (D1, MCo3), or a class code for its introduction
  name TEXT NOT NULL,
  page INTEGER,                          -- the page printed on the book's page
  body TEXT NOT NULL
);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '081-msh-power-text.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'msh_power_text');

-- Marvel Heroes: the heroes people save, one row per hero, scoped to the
-- Access email that saved it (migration 082).
CREATE TABLE IF NOT EXISTS msh_heroes (
  id TEXT PRIMARY KEY,
  owner_email TEXT NOT NULL,
  name TEXT NOT NULL,
  build TEXT NOT NULL,                   -- JSON: the generator's seeds and picks
  snapshot TEXT NOT NULL,                -- JSON: what that built, resolved at save time
  sheet TEXT NOT NULL DEFAULT '{}',      -- JSON: what the player wrote on the sheet
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_heroes_owner ON msh_heroes (owner_email, updated_at);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '082-msh-heroes.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'msh_heroes');
