-- ═══════════════════════════════════════════════════════════════════
-- The tools group's database (DB_TOOLS, nates-workshop-tools): the tables of
-- FilamentForge and MediaVault. Pick 3 Cut 5, the third tool, keeps no tables.
-- groups.json says which group owns what; db/schema.sql is Palladium's
-- database and holds none of these once each app has moved.
--
-- Built the same way as db/schema.sql: everything is CREATE ... IF NOT
-- EXISTS, so re-running it is safe, and each migration in db/migrations/tools/
-- has a guarded seed line so a database built from this file records itself
-- as migrated. The migrations keep the numbers they had when these tables
-- lived in the shared database, because that is what both databases'
-- schema_migrations recorded.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS schema_migrations (
  filename   TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- ═══════════════════════════════════════════════════════════════════
-- FilamentForge — AI slicer-settings engine. Six tables, all prefixed
-- ff_, a prefix from when the character creator's unprefixed tables shared
-- their database; it still keeps them apart from MediaVault's media_. ff_brands and
-- ff_filaments are a snapshot of the Open Filament Database, refreshed
-- by scripts/ofd-refresh.mjs and read by /api/filament-forge/catalog so
-- the app has no runtime dependency on openfilamentdatabase.org. The
-- four user tables hold what used to live in localStorage, keyed to the
-- Access email the way media_items is.
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS ff_brands (
  id         TEXT PRIMARY KEY,           -- OFD brand id
  name       TEXT NOT NULL,
  fetched_at TEXT NOT NULL               -- when the snapshot holding this row was taken
);

CREATE TABLE IF NOT EXISTS ff_filaments (
  id                    TEXT PRIMARY KEY, -- OFD filament id
  brand_id              TEXT NOT NULL,
  name                  TEXT NOT NULL,
  material              TEXT NOT NULL DEFAULT '',
  density               TEXT NOT NULL DEFAULT '',
  diameter_tolerance    TEXT NOT NULL DEFAULT '',
  min_print_temperature TEXT NOT NULL DEFAULT '',
  max_print_temperature TEXT NOT NULL DEFAULT '',
  min_bed_temperature   TEXT NOT NULL DEFAULT '',
  max_bed_temperature   TEXT NOT NULL DEFAULT '',
  max_dry_temperature   TEXT NOT NULL DEFAULT '',
  slicer_settings       TEXT NOT NULL DEFAULT '',
  fetched_at            TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_ff_filaments_brand ON ff_filaments (brand_id);

-- The printer dropdowns: one row per user, replaced on every change.
CREATE TABLE IF NOT EXISTS ff_config (
  email      TEXT PRIMARY KEY,
  printer    TEXT NOT NULL DEFAULT '',
  nozzle     TEXT NOT NULL DEFAULT '',
  ams        TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- One row per generated result, capped at 50 per user by the endpoint.
-- `settings` and `raw_json` are the parsed and unparsed halves of the same
-- Claude response, stored both because the app displays both.
CREATE TABLE IF NOT EXISTS ff_history (
  email      TEXT NOT NULL,
  entry_id   TEXT NOT NULL,
  created_at TEXT NOT NULL,
  brand      TEXT NOT NULL DEFAULT '',
  name       TEXT NOT NULL DEFAULT '',
  material   TEXT NOT NULL DEFAULT '',
  printer    TEXT NOT NULL DEFAULT '',
  nozzle     TEXT NOT NULL DEFAULT '',
  intent     TEXT NOT NULL DEFAULT '',
  settings   TEXT NOT NULL DEFAULT '{}', -- JSON
  raw_json   TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (email, entry_id)
);

-- A history entry the user named and chose to keep. Same shape plus the name,
-- and no cap - saving is deliberate where history is automatic.
CREATE TABLE IF NOT EXISTS ff_presets (
  email       TEXT NOT NULL,
  entry_id    TEXT NOT NULL,
  preset_name TEXT NOT NULL,
  saved_at    TEXT NOT NULL,
  created_at  TEXT NOT NULL,
  brand       TEXT NOT NULL DEFAULT '',
  name        TEXT NOT NULL DEFAULT '',
  material    TEXT NOT NULL DEFAULT '',
  printer     TEXT NOT NULL DEFAULT '',
  nozzle      TEXT NOT NULL DEFAULT '',
  intent      TEXT NOT NULL DEFAULT '',
  settings    TEXT NOT NULL DEFAULT '{}', -- JSON
  raw_json    TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (email, entry_id)
);

-- A filament the user typed in because OFD does not list it.
CREATE TABLE IF NOT EXISTS ff_custom_filaments (
  email          TEXT NOT NULL,
  filament_id    TEXT NOT NULL,
  brand          TEXT NOT NULL,
  name           TEXT NOT NULL,
  material       TEXT NOT NULL DEFAULT '',
  min_print_temp TEXT NOT NULL DEFAULT '',
  max_print_temp TEXT NOT NULL DEFAULT '',
  min_bed_temp   TEXT NOT NULL DEFAULT '',
  max_bed_temp   TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (email, filament_id)
);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '039-filament-forge.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'ff_config');

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
  -- Where this row came from, so its lookup can be run again exactly: the
  -- normalised ISBN for a book, 'tmdb:movie:1234' / 'tmdb:tv:1234' for video.
  -- Empty on every row saved before 040, which is honest rather than a gap.
  source_id  TEXT NOT NULL DEFAULT '',
  added_at   INTEGER NOT NULL,
  PRIMARY KEY (user_email, item_id)
);

CREATE INDEX IF NOT EXISTS idx_media_items_user ON media_items (user_email);

-- This MediaVault user lets that one READ their library. The pair is the key,
-- so granting twice is idempotent and revoking is a DELETE of one known row.
-- NO token: the viewer passes Cloudflare Access to reach the site at all, so
-- the reader checks the VIEWER'S OWN Access email against viewer_email, and a
-- leaked row identifier grants nothing. NO foreign key - this site has no users
-- table, and a grant naming an address that cannot sign in is inert rather than
-- broken. NO revoked_at: revocation is a DELETE, and a row claiming a share was
-- revoked would be a second copy of what the row's absence already states.
-- See migration 051 and apps/media-vault/SHARE-AUDIT.md V1.
CREATE TABLE IF NOT EXISTS media_shares (
  owner_email  TEXT NOT NULL,             -- whose library is being shared
  viewer_email TEXT NOT NULL,             -- who may read it, Access identity
  created_at   INTEGER NOT NULL,          -- epoch ms, like media_items.added_at
  PRIMARY KEY (owner_email, viewer_email)
);
CREATE INDEX IF NOT EXISTS idx_media_shares_viewer ON media_shares (viewer_email);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '051-media-shares.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'media_shares');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '040-media-vault-source-id.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('media_items') WHERE name = 'source_id');
