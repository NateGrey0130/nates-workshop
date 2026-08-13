-- MediaVault library storage, scoped per Cloudflare Access user email
CREATE TABLE IF NOT EXISTS media_items (
  user_email TEXT NOT NULL,
  item_id    TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'audiobook',
  format     TEXT NOT NULL DEFAULT 'digital',
  title      TEXT NOT NULL,
  author     TEXT NOT NULL DEFAULT '',
  actors     TEXT NOT NULL DEFAULT '',
  producers  TEXT NOT NULL DEFAULT '',
  genre      TEXT NOT NULL DEFAULT '',
  series     TEXT NOT NULL DEFAULT '',
  location   TEXT NOT NULL DEFAULT '',
  cover      TEXT NOT NULL DEFAULT '',
  notes      TEXT NOT NULL DEFAULT '',
  added_at   INTEGER NOT NULL,
  PRIMARY KEY (user_email, item_id)
);

CREATE INDEX IF NOT EXISTS idx_media_items_user ON media_items (user_email);

-- ═══════════════════════════════════════════════════════════════════
-- Character Creator — Palladium Fantasy / Rifts characters & campaigns.
-- RCC/OCC definitions live in markdown under apps/character-creator/data,
-- not here; characters reference them by class_id slug.
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS campaigns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  system TEXT NOT NULL CHECK (system IN ('rifts', 'palladium-fantasy')),
  gm_email TEXT NOT NULL,
  description TEXT,
  gm_notes TEXT,                        -- GM-only; stripped from non-GM API responses
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS characters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  player_email TEXT NOT NULL,           -- Cloudflare Access identity of the owner
  name TEXT NOT NULL,
  class_id TEXT NOT NULL,               -- slug of the RCC/OCC markdown file, e.g. 'cyber-knight'
  level INTEGER NOT NULL DEFAULT 1,
  xp INTEGER NOT NULL DEFAULT 0,
  attributes TEXT NOT NULL DEFAULT '{}',  -- JSON: {"IQ": 12, "ME": 14, ...}
  skills TEXT NOT NULL DEFAULT '[]',      -- JSON: [{"name", "pct", "per_level", "type": "occ|related|secondary"}]
  powers TEXT NOT NULL DEFAULT '[]',      -- JSON: [{"type": "spell|psionic", "name", "cost", ...}]
  hp_max INTEGER,  hp_current INTEGER,
  sdc_max INTEGER, sdc_current INTEGER,
  mdc_max INTEGER, mdc_current INTEGER,   -- M.D.C. beings (e.g. dragon hatchlings) use this instead of HP/SDC
  ppe_max INTEGER, ppe_current INTEGER,
  isp_max INTEGER, isp_current INTEGER,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_characters_campaign ON characters (campaign_id);
CREATE INDEX IF NOT EXISTS idx_characters_player ON characters (player_email);

CREATE TABLE IF NOT EXISTS journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  character_id INTEGER REFERENCES characters(id) ON DELETE CASCADE,  -- NULL = campaign-level entry
  author_email TEXT NOT NULL,
  title TEXT,
  body TEXT NOT NULL,
  session_date TEXT,                    -- in-world or real session date, freeform ISO string
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_journal_campaign ON journal_entries (campaign_id);
CREATE INDEX IF NOT EXISTS idx_journal_character ON journal_entries (character_id);

CREATE TABLE IF NOT EXISTS level_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  from_level INTEGER NOT NULL,
  to_level INTEGER NOT NULL,
  xp_at_levelup INTEGER,
  changes TEXT NOT NULL DEFAULT '{}',   -- JSON diff of what the level-up actually applied
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_level_history_character ON level_history (character_id);

-- Shared gear catalog for character sheets (distinct from media_items above).
CREATE TABLE IF NOT EXISTS items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT UNIQUE,                     -- matches equipment_starting item_id refs in class markdown
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'both')),
  category TEXT,                        -- weapon | armor | vehicle | cybernetics | gear
  weight_lbs REAL,
  cost INTEGER,                         -- credits (rifts) or gold (palladium-fantasy)
  stats TEXT NOT NULL DEFAULT '{}',     -- JSON: damage, MDC, range, payload, etc.
  description TEXT,
  source_book TEXT
);

CREATE TABLE IF NOT EXISTS character_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES items(id),               -- NULL = freeform custom item
  custom_name TEXT,                                   -- required for freeform items
  qty INTEGER NOT NULL DEFAULT 1,
  equipped INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,  -- ties acquisition/loss to a session
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                    -- NULL = currently in inventory
  CHECK (item_id IS NOT NULL OR custom_name IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_character_items_character ON character_items (character_id);

-- Classes created by the PDF import tool. Committed markdown under
-- apps/character-creator/data/classes still works and takes precedence; this
-- table lets an imported class go live immediately without a redeploy.
-- A row is saved as 'draft' the moment extraction succeeds (so a closed tab
-- never loses the work) and flips to 'published' when the import is confirmed.
CREATE TABLE IF NOT EXISTS imported_classes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  class_id TEXT NOT NULL UNIQUE,        -- kebab-case slug from the frontmatter
  name TEXT,
  system TEXT,
  markdown TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_imported_classes_status ON imported_classes (status);

-- Reference catalogs. These began as static JSON shipped with the deploy, which
-- meant a commit and a redeploy to add a single skill. They live here so the
-- import tool can create missing entries live, the same way it does for items.
CREATE TABLE IF NOT EXISTS skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  base INTEGER NOT NULL DEFAULT 0,        -- 0 = non-percentile (W.P.s, hand to hand)
  per_level INTEGER NOT NULL DEFAULT 0,
  systems TEXT,                           -- JSON array; NULL means both systems
  source TEXT NOT NULL DEFAULT 'seed'     -- seed | import
);

CREATE TABLE IF NOT EXISTS spells (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  level INTEGER NOT NULL DEFAULT 0,
  ppe INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'seed'
);

CREATE TABLE IF NOT EXISTS psionic_powers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,                          -- Healing | Physical | Sensitive | Super
  isp INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'seed'
);
