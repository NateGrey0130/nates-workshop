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

-- Marvel Heroes: the prose of the sourcebooks' character entries (MA1 first),
-- one row per power, section or member of an entry. Like msh_power_text its
-- rows are never in this repository - see migration 087 - so a database built
-- from here has it empty, and the codex shows the committed facts without it.
CREATE TABLE IF NOT EXISTS msh_book_text (
  key TEXT PRIMARY KEY,                  -- '<book>:<entry>:<part>[:<n>]'
  book TEXT NOT NULL,                    -- scripts/msh/books.json slug
  entry TEXT NOT NULL,                   -- the entry's slug in the committed data
  part TEXT NOT NULL,                    -- power, talents, contacts, running, background, notes, member, prose
  name TEXT,                             -- a power's or member's printed name
  page INTEGER,                          -- the printed page the piece starts on
  body TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_msh_book_text_entry ON msh_book_text (book, entry);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '087-msh-book-text.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'msh_book_text')
  AND EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'index' AND name = 'idx_msh_book_text_entry');

-- Marvel Heroes campaigns (migration 086): a GM's table, the heroes linked to
-- it, the GM's changes to their Health and Karma, the journal and its search,
-- the People and their statted sheets, and the GM's pages and pictures. The
-- migration's header says why a hero is linked rather than copied, and why the
-- link row carries a copy of its campaign's `open`.
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

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '086-msh-campaigns.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'msh_campaign_images')
  AND EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'index' AND name = 'idx_msh_campaign_heroes_one_open');
