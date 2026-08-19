-- ═══════════════════════════════════════════════════════════════════
-- Migration bookkeeping. Which db/migrations/*.sql files a database has
-- had applied. Everything else in this file is CREATE ... IF NOT EXISTS,
-- so re-running it is safe; the seeding block at the bottom keeps this
-- table honest on databases that predate it.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS schema_migrations (
  filename   TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL DEFAULT (datetime('now'))
);

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
  class_variant TEXT,                   -- which `variants` entry, e.g. 'hatchling'; NULL = the class as written
  occ_class_id TEXT,                    -- the O.C.C. taken alongside an R.C.C.; NULL = none
  occ_class_variant TEXT,
  psychic_tier TEXT,                    -- rolled on the Random Psionics Table; NULL = none, or psychic by class
  psychic_shape TEXT,                   -- which power allowance was taken ('focused' | 'broad')
  attribute_bonuses TEXT,
  abilities TEXT,                        -- JSON array of chosen ability names; duplicates are meaningful
  rolled_bonuses TEXT,                   -- what a class's DICE combat/save bonuses came up               -- JSON: what the class's dice attribute bonuses rolled
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
  -- Sheet sections stored as JSON rather than ~40 scalar columns, because the
  -- shapes are sparse and this file only ever CREATEs. See db/migrations/ for
  -- the one-shot ALTERs that add these to an existing database.
  bio TEXT NOT NULL DEFAULT '{}',        -- race, alignment, age, height, sentiments, …
  combat TEXT NOT NULL DEFAULT '{}',     -- attacks, initiative, strike/parry/dodge, punches
  saves TEXT NOT NULL DEFAULT '{}',      -- save vs magic, psionics, poison, insanity, …
  armor TEXT NOT NULL DEFAULT '[]',      -- [{ name, ar, mdc_max, mdc_current, weight, cost, prowl }]
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

-- Skill picks a level-up granted but the player has not spent yet. One row per
-- GRANT rather than per pick, so "2 picks from Physical or Rogue, earned at
-- level 3" stays itemised. `categories` is copied from the class at the moment
-- of the level-up — the class can change later, what you were granted cannot.
CREATE TABLE IF NOT EXISTS pending_skill_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  categories TEXT,
  kind TEXT,                             -- 'related' | 'secondary'; NULL means related                      -- JSON array; NULL = no category restriction
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT                       -- NULL = still unspent
);
CREATE INDEX IF NOT EXISTS idx_pending_picks_character
  ON pending_skill_picks (character_id, claimed_at);

-- Shared gear catalog for character sheets. Named `gear` rather than `items`
-- because this database is shared with MediaVault's `media_items`, and a table
-- called `items` sitting next to it was the most likely future collision.
CREATE TABLE IF NOT EXISTS gear (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT UNIQUE,                     -- matches equipment_starting item_id refs in class markdown
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'both')),
  category TEXT,                        -- weapon | armor | vehicle | cybernetics | gear
  weight_lbs REAL,
  cost INTEGER,                         -- credits (rifts) or gold (palladium-fantasy)
  -- Stat block. TEXT where books write prose as often as figures
  -- ("2D6 M.D. single shot, 6D6 M.D. burst"); ar and mdc are numbers because
  -- the sheet's armour block uses them as such. is_mega_damage is structured
  -- because S.D.C. versus M.D.C. is the distinction that matters most in Rifts
  -- and reading it back out of a damage string is error-prone.
  damage TEXT,
  is_mega_damage INTEGER NOT NULL DEFAULT 0,
  range TEXT,
  payload TEXT,
  rate_of_fire TEXT,
  ar INTEGER,
  mdc INTEGER,
  description TEXT,
  source_book TEXT
);

CREATE TABLE IF NOT EXISTS character_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  item_id INTEGER REFERENCES gear(id),                -- NULL = freeform custom item
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
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  -- NULL = live, timestamp = retired. Characters built on a retired class keep
  -- working; only the pickers and the published list filter on it.
  deleted_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_imported_classes_status ON imported_classes (status);
CREATE INDEX IF NOT EXISTS idx_imported_classes_deleted ON imported_classes (deleted_at);

-- Reference catalogs. These began as static JSON shipped with the deploy, which
-- meant a commit and a redeploy to add a single skill. They live here so the
-- import tool can create missing entries live, the same way it does for items.
-- `name` is unique: the same skill imported from a second book with different
-- numbers is stored under a distinguished name (e.g. "Climbing (Rifts UE)"),
-- decided during import review rather than silently merged or duplicated.
CREATE TABLE IF NOT EXISTS skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  base INTEGER NOT NULL DEFAULT 0,        -- 0 = non-percentile (W.P.s, hand to hand)
  per_level INTEGER NOT NULL DEFAULT 0,
  systems TEXT,                           -- JSON array; NULL means both systems
  source TEXT NOT NULL DEFAULT 'seed',    -- seed | import
  source_book TEXT,
  note TEXT                               -- "40%/30% climb/rappel", "counts as two skills"
);

CREATE TABLE IF NOT EXISTS spells (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  level INTEGER NOT NULL DEFAULT 0,
  ppe INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- rifts | palladium-fantasy | both; NULL = unrestricted
  -- Stat block. TEXT rather than numbers because book values are prose as often
  -- as figures: "100 feet per level of experience", "2D6 melee rounds".
  range TEXT,
  duration TEXT,
  damage TEXT,
  saving_throw TEXT,
  area_of_effect TEXT,
  casting_time TEXT,
  description TEXT
);

CREATE TABLE IF NOT EXISTS psionic_powers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,                          -- Healing | Physical | Sensitive | Super
  isp INTEGER NOT NULL DEFAULT 0,
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- rifts | palladium-fantasy | both; NULL = unrestricted
  -- Field names match spells on purpose, so the sheet renders both the same way.
  range TEXT,
  duration TEXT,
  saving_throw TEXT,
  description TEXT,
  -- minor | major | master. NULL = no restriction beyond the power's category,
  -- which is today's behaviour. Books state tier at the category level far more
  -- often than per power, so most rows legitimately have none. Nothing enforces
  -- this yet — that needs real imported data behind it first.
  min_tier TEXT
);

-- ═══════════════════════════════════════════════════════════════════
-- Migration seeding. The CREATEs above already contain the columns that
-- db/migrations/*.sql add, so a database built from this file is current
-- the moment it exists and should say so.
--
-- But on an EXISTING database every CREATE above is skipped, so this file
-- alone cannot bring old tables up to date — that is what the migrations
-- are for. An unconditional insert here would therefore mark an old,
-- un-migrated database as migrated, which is precisely the lie this table
-- exists to prevent.
--
-- So each row is guarded by the schema feature its migration adds. The
-- record is derived from what the database actually looks like, never
-- assumed. Add a guarded line here whenever you add a migration.
-- ═══════════════════════════════════════════════════════════════════
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '001-character-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'bio');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '002-catalog-provenance.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('skills') WHERE name = 'note');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '003-class-soft-delete.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('imported_classes') WHERE name = 'deleted_at');

-- ═══════════════════════════════════════════════════════════════════
-- Resumable catalog imports. A spell chapter is hundreds of entries across
-- many pages, so extracted rows are staged here rather than living in a
-- browser tab. Catalog-agnostic on purpose — psionics and gear reuse them.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS import_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,                -- spells | psionics | gear | skills
  name TEXT NOT NULL,
  source_book TEXT,
  system TEXT,                          -- the book's game system; stamped on every row it imports
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  closed_at TEXT                        -- NULL = still open
);
CREATE INDEX IF NOT EXISTS idx_import_sessions_open ON import_sessions (catalog, closed_at);

CREATE TABLE IF NOT EXISTS import_staged (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id INTEGER NOT NULL REFERENCES import_sessions(id) ON DELETE CASCADE,
  page_range TEXT,
  payload TEXT NOT NULL,                -- JSON: the extracted row
  match_name TEXT,                      -- catalog row this duplicates, if any
  is_stub INTEGER NOT NULL DEFAULT 0,
  differs INTEGER NOT NULL DEFAULT 0,
  action TEXT NOT NULL DEFAULT 'insert',-- insert | update | ignore
  resolved_name TEXT,                   -- distinguishing name for "keep both"
  confirmed_at TEXT,                    -- NULL = not yet applied
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_import_staged_session ON import_staged (session_id, confirmed_at);

-- A rename needs both halves checked. The CREATE above makes an empty `gear`
-- on a database that still has a populated `items`, so "gear exists" alone
-- would record this migration on a database that has not actually had it.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '004-items-to-gear.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'gear')
  AND NOT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'items');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '005-spell-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'saving_throw');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '006-import-sessions.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'import_staged');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '007-psionic-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('psionic_powers') WHERE name = 'min_tier');

-- Both halves again: 008 adds columns AND drops `stats`, so a database that has
-- the new columns but still has the blob has not finished the migration.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '008-gear-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('gear') WHERE name = 'ar')
  AND NOT EXISTS (SELECT 1 FROM pragma_table_info('gear') WHERE name = 'stats');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '009-pending-skill-picks.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'pending_skill_picks');

-- ═══════════════════════════════════════════════════════════════════
-- Forwarding pointers for retired catalog keys. A merge deletes one of two
-- rows and repoints the characters that held it, but class markdown cites
-- gear by slug and skills by name, and a merge never rewrites markdown. This
-- remembers where the key went so those citations still resolve.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS catalog_redirects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,                          -- skills | spells | psionics | gear
  from_key TEXT NOT NULL COLLATE NOCASE,          -- the retired slug or name
  to_id INTEGER NOT NULL,                         -- row in that catalog's table
  reason TEXT NOT NULL DEFAULT 'merge',           -- merge | rename
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (catalog, from_key)
);
CREATE INDEX IF NOT EXISTS idx_catalog_redirects_target ON catalog_redirects (catalog, to_id);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '010-catalog-redirects.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'catalog_redirects');

-- ═══════════════════════════════════════════════════════════════════
-- Play mode's event log. Commentary, not a ledger: the character row stays
-- the source of truth and nothing replays events to derive state. Buys undo
-- (payload carries from/to), a who-did-what trail, and the session recap.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS play_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  actor_email TEXT NOT NULL,
  kind TEXT NOT NULL,                   -- damage | pool | power | ammo | roll | recap
  payload TEXT NOT NULL,                -- JSON: note, and changes {from, to} for undo
  undone_at TEXT,                       -- NULL = stands
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_play_events_character ON play_events (character_id, id);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '022-play-events.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'play_events');

-- ═══════════════════════════════════════════════════════════════════
-- An in-progress character build. Its own table rather than a `draft` status
-- on `characters`: a half-built character has no name, no campaign and
-- possibly no attributes, and putting one in `characters` would make every
-- list, the dashboard, the audit and the validator filter it out forever to
-- serve a state that lasts minutes. UNIQUE(owner_email) is what enforces one
-- draft at a time — saving is an upsert.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS character_drafts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_email TEXT NOT NULL UNIQUE,
  system TEXT,
  class_id TEXT,
  class_name TEXT,
  char_name TEXT,
  step INTEGER NOT NULL DEFAULT 0,
  state TEXT NOT NULL,                            -- JSON: the wizard's build state
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '011-character-drafts.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'character_drafts');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '014-character-occ.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'occ_class_id');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '015-character-psychic-tier.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'psychic_tier');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '016-character-attribute-bonuses.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'attribute_bonuses');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '017-pick-kind.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('pending_skill_picks') WHERE name = 'kind');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '018-character-abilities.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'abilities');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '019-character-rolled-bonuses.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'rolled_bonuses');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '013-character-variant.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'class_variant');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '012-catalog-system.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'system')
  AND EXISTS (SELECT 1 FROM pragma_table_info('import_sessions') WHERE name = 'system');
