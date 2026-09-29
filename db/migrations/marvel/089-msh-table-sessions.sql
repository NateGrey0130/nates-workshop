-- 089: msh_table_sessions - The Table's live game sessions for a Marvel
-- campaign, one row per table its GM opened, and its roll feed once it closed.
--
-- Marvel's own copy of Palladium's table_sessions (migration 088), not a share
-- of it: each group's server code reaches only its own database (groups.json).
-- The two are read and written through the same shared handlers
-- (functions/api/_lib/table-room.js), each game supplying its own queries, so
-- the columns and their meaning are identical and are described once, in 088.
--
-- In short: while `closed_at` is NULL the campaign has a table open under
-- `code`; on close `feed` holds every roll, GM-only ones included, with its
-- visibility, and each reader gets it back filtered by the room's own rule.
CREATE TABLE IF NOT EXISTS msh_table_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES msh_campaigns(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  opened_by TEXT NOT NULL,
  opened_at TEXT NOT NULL DEFAULT (datetime('now')),
  closed_at TEXT,
  closed_reason TEXT CHECK (closed_reason IN ('gm', 'idle', 'lost')),
  feed TEXT,
  roll_count INTEGER NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_msh_table_sessions_one_open
  ON msh_table_sessions (campaign_id) WHERE closed_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_msh_table_sessions_campaign ON msh_table_sessions (campaign_id, id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('089-msh-table-sessions.sql');
