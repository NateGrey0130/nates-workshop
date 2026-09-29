-- 088: table_sessions - The Table's live game sessions, one row per table a
-- G.M. opened for a campaign, and its roll feed once it closed.
--
-- The live room is a Durable Object (workers/table-room/) and never touches
-- D1. This row is the campaign's side of it: while `closed_at` is NULL the
-- campaign has a table open under `code`, and the table routes
-- (functions/api/character-creator/table/) read it to decide whether a code
-- still means anything. When the G.M. closes the table, or the campaign page
-- finds one that closed itself after twelve idle hours, the room's whole feed
-- is written to `feed` and the row closes.
--
-- `feed` is a JSON array of every roll, GM-only ones included, each with its
-- `visibility` ('all' | 'gm' | 'secret') and who rolled it. It is filtered
-- for each reader by the same rule the room used live
-- (workers/table-room/src/visibility.js), so the G.M. alone reads GM-only
-- rolls back and a player reads their own To-GM rolls and the public ones.
-- Sheet rolls are ALSO in each character's play_events, written by the sheet
-- itself; this is the table's record, not a second session log.
--
-- `closed_reason`: 'gm' (closed by the G.M.), 'idle' (closed itself), 'lost'
-- (the room was gone when the campaign came to save it, so `feed` is empty).
--
-- At most one open table per campaign: the partial unique index.
CREATE TABLE IF NOT EXISTS table_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  opened_by TEXT NOT NULL,
  opened_at TEXT NOT NULL DEFAULT (datetime('now')),
  closed_at TEXT,
  closed_reason TEXT CHECK (closed_reason IN ('gm', 'idle', 'lost')),
  feed TEXT,
  roll_count INTEGER NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX IF NOT EXISTS idx_table_sessions_one_open
  ON table_sessions (campaign_id) WHERE closed_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_table_sessions_campaign ON table_sessions (campaign_id, id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('088-table-sessions.sql');
