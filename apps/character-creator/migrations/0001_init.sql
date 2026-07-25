-- Character Creator — core schema (spec section 9).
-- RCC/OCC definitions live in markdown files, not here; characters reference them by class_id slug.

CREATE TABLE campaigns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  system TEXT NOT NULL CHECK (system IN ('rifts', 'palladium-fantasy')),
  gm_email TEXT NOT NULL,
  description TEXT,
  gm_notes TEXT,                        -- campaign-level notes, separate from character journals
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE characters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  player_email TEXT NOT NULL,           -- Zero Trust identity of the owner
  name TEXT NOT NULL,
  class_id TEXT NOT NULL,               -- slug of the RCC/OCC markdown file, e.g. 'cyber-knight'
  level INTEGER NOT NULL DEFAULT 1,
  xp INTEGER NOT NULL DEFAULT 0,
  attributes TEXT NOT NULL DEFAULT '{}',  -- JSON: {"IQ": 12, "ME": 14, ...}
  skills TEXT NOT NULL DEFAULT '[]',      -- JSON: [{"name", "pct", "per_level", "type": "occ|related|secondary"}]
  powers TEXT NOT NULL DEFAULT '[]',      -- JSON: spells/psionics (populated in later phases)
  hp_max INTEGER,  hp_current INTEGER,
  sdc_max INTEGER, sdc_current INTEGER,
  mdc_max INTEGER, mdc_current INTEGER,   -- M.D.C. beings (e.g. dragon hatchlings) use this instead of HP/SDC
  ppe_max INTEGER, ppe_current INTEGER,
  isp_max INTEGER, isp_current INTEGER,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_characters_campaign ON characters(campaign_id);
CREATE INDEX idx_characters_player ON characters(player_email);

CREATE TABLE journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  character_id INTEGER REFERENCES characters(id) ON DELETE CASCADE,  -- NULL = campaign-level entry
  author_email TEXT NOT NULL,
  title TEXT,
  body TEXT NOT NULL,
  session_date TEXT,                    -- in-world or real session date, freeform ISO string
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_journal_campaign ON journal_entries(campaign_id);
CREATE INDEX idx_journal_character ON journal_entries(character_id);

CREATE TABLE level_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  from_level INTEGER NOT NULL,
  to_level INTEGER NOT NULL,
  xp_at_levelup INTEGER,
  changes TEXT NOT NULL DEFAULT '{}',   -- JSON diff of what the level-up changed (old -> new)
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX idx_level_history_character ON level_history(character_id);

CREATE TABLE items (
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

CREATE TABLE character_items (
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
CREATE INDEX idx_character_items_character ON character_items(character_id);
