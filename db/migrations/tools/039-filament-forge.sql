-- FilamentForge grows real tables. Until now it was the site's one app with
-- no server side at all: presets, history, custom filaments and the printer
-- config lived in localStorage (one browser, gone on a clear), and the
-- brand/filament catalog was fetched from openfilamentdatabase.org by every
-- page load - a third-party site as a runtime dependency. Six tables fix
-- both: ff_brands/ff_filaments hold a snapshot of the Open Filament Database
-- (refreshed by scripts/ofd-refresh.mjs, read by /api/filament-forge/catalog),
-- and the four ff_ user tables hold what localStorage held, keyed to the
-- Access email the way media_items is. Everything is prefixed ff_ because the
-- character creator's tables share this database unprefixed - the prefix IS
-- the collision boundary.

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

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('039-filament-forge.sql');
