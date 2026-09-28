-- 086: Marvel Heroes campaigns - a GM's table, the heroes played at it, and
-- what the GM keeps about it (apps/marvel-heroes/campaign, apps/marvel-heroes/gm).
--
-- Nine tables, all in DB_MARVEL, all msh_-prefixed. The Palladium suite has the
-- same shapes under unprefixed names in its own database (db/schema.sql); these
-- are Marvel's copies, not a share of those, because each group's server code
-- reaches only its own binding (groups.json).
--
-- A HERO IS LINKED, NEVER COPIED. msh_campaign_heroes holds the pair and
-- nothing else; Health and Karma stay on the hero's own row (msh_heroes.sheet),
-- so the player's sheet and the GM's roster are one number (Nate, 2026-09-28).
-- Every change the GM makes to that number is an msh_hero_events row, written
-- in the same batch, and undo is a new row that reverses one.
--
-- ONE OPEN CAMPAIGN PER HERO is a unique index, not a check in the endpoint.
-- An index cannot look at another table, so the link row carries a copy of
-- its campaign's `open`, and the trigger below keeps the copy true when a
-- campaign is closed or reopened. Reopening a campaign whose hero has since
-- joined another open one fails on the index, which is the refusal wanted.

CREATE TABLE IF NOT EXISTS msh_campaigns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  gm_email TEXT NOT NULL,
  description TEXT,
  gm_notes TEXT,
  open INTEGER NOT NULL DEFAULT 1 CHECK (open IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_campaigns_gm ON msh_campaigns (gm_email);

CREATE TABLE IF NOT EXISTS msh_campaign_heroes (
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  hero_id TEXT NOT NULL REFERENCES msh_heroes(id) ON DELETE CASCADE,
  campaign_open INTEGER NOT NULL CHECK (campaign_open IN (0, 1)),
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (campaign_id, hero_id)
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_msh_campaign_heroes_one_open
  ON msh_campaign_heroes (hero_id) WHERE campaign_open = 1;

CREATE TRIGGER IF NOT EXISTS msh_campaigns_open_au AFTER UPDATE OF open ON msh_campaigns BEGIN
  UPDATE msh_campaign_heroes SET campaign_open = new.open WHERE campaign_id = new.id;
END;

-- `field` is one of msh_heroes.sheet's play numbers. `delta` is after - before.
-- `undoes` names the event this one reverses; unique, so an event is undone once.
CREATE TABLE IF NOT EXISTS msh_hero_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  hero_id TEXT NOT NULL REFERENCES msh_heroes(id) ON DELETE CASCADE,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  actor_email TEXT NOT NULL,
  field TEXT NOT NULL CHECK (field IN ('health', 'karma', 'karma_pool', 'advancement')),
  delta INTEGER NOT NULL,
  before INTEGER,
  after INTEGER NOT NULL,
  undoes INTEGER REFERENCES msh_hero_events(id) ON DELETE CASCADE,
  at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_hero_events_campaign ON msh_hero_events (campaign_id, id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_msh_hero_events_undoes ON msh_hero_events (undoes) WHERE undoes IS NOT NULL;

CREATE TABLE IF NOT EXISTS msh_journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  hero_id TEXT REFERENCES msh_heroes(id) ON DELETE SET NULL,
  author_email TEXT NOT NULL,
  title TEXT,
  body TEXT NOT NULL,
  session_date TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_journal_campaign ON msh_journal_entries (campaign_id);

CREATE VIRTUAL TABLE IF NOT EXISTS msh_journal_fts USING fts5(
  title, body,
  content='msh_journal_entries', content_rowid='id',
  tokenize='porter unicode61'
);
CREATE TRIGGER IF NOT EXISTS msh_journal_fts_ai AFTER INSERT ON msh_journal_entries BEGIN
  INSERT INTO msh_journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;
CREATE TRIGGER IF NOT EXISTS msh_journal_fts_ad AFTER DELETE ON msh_journal_entries BEGIN
  INSERT INTO msh_journal_fts(msh_journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
END;
CREATE TRIGGER IF NOT EXISTS msh_journal_fts_au AFTER UPDATE ON msh_journal_entries BEGIN
  INSERT INTO msh_journal_fts(msh_journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
  INSERT INTO msh_journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;

-- A statted NPC: the same build / snapshot / sheet shape as msh_heroes, so
-- js/sheet.js draws one exactly as it draws a hero. Hidden from players until
-- the GM says otherwise.
CREATE TABLE IF NOT EXISTS msh_npc_sheets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  build TEXT NOT NULL,
  snapshot TEXT NOT NULL,
  sheet TEXT NOT NULL DEFAULT '{}',
  hidden INTEGER NOT NULL DEFAULT 1 CHECK (hidden IN (0, 1)),
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_npc_sheets_campaign ON msh_npc_sheets (campaign_id);

CREATE TABLE IF NOT EXISTS msh_npcs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  aliases TEXT,
  faction TEXT,
  disposition TEXT,
  status TEXT NOT NULL DEFAULT 'unknown'
    CHECK (status IN ('alive', 'dead', 'unknown', 'never-met')),
  description TEXT,
  portrait_key TEXT CHECK (portrait_key IS NULL OR portrait_key LIKE 'msh/%'),
  sheet_id INTEGER REFERENCES msh_npc_sheets(id) ON DELETE SET NULL,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_npcs_campaign ON msh_npcs (campaign_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_msh_npcs_campaign_name
  ON msh_npcs (campaign_id, name COLLATE NOCASE);

CREATE TABLE IF NOT EXISTS msh_npc_mentions (
  npc_id INTEGER NOT NULL REFERENCES msh_npcs(id) ON DELETE CASCADE,
  journal_entry_id INTEGER NOT NULL REFERENCES msh_journal_entries(id) ON DELETE CASCADE,
  source TEXT NOT NULL CHECK (source IN ('mention', 'ai')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (npc_id, journal_entry_id)
);
CREATE INDEX IF NOT EXISTS idx_msh_npc_mentions_entry ON msh_npc_mentions (journal_entry_id);

-- The GM's own pages, never revealed, and the pictures that can be. The R2
-- key is refused unless it is under msh/, so Marvel's objects cannot land in
-- the Palladium suite's part of the bucket.
CREATE TABLE IF NOT EXISTS msh_campaign_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  kind TEXT NOT NULL DEFAULT 'lore'
    CHECK (kind IN ('place', 'faction', 'lore', 'handout', 'prep')),
  title TEXT NOT NULL,
  body TEXT,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_campaign_entries_campaign
  ON msh_campaign_entries (campaign_id, kind);

CREATE TABLE IF NOT EXISTS msh_campaign_images (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  entry_id INTEGER REFERENCES msh_campaign_entries(id) ON DELETE CASCADE,
  r2_key TEXT NOT NULL CHECK (r2_key LIKE 'msh/%'),
  content_type TEXT,
  byte_size INTEGER,
  caption TEXT,
  revealed_at TEXT,
  sort INTEGER NOT NULL DEFAULT 0,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_msh_campaign_images_revealed
  ON msh_campaign_images (campaign_id, revealed_at);
CREATE INDEX IF NOT EXISTS idx_msh_campaign_images_entry
  ON msh_campaign_images (entry_id, sort);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('086-msh-campaigns.sql');
