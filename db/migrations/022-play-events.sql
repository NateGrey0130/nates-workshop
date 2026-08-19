-- Play mode's event log (phase 3). One row per play action - damage, a pool
-- spend, a power use, ammo, a roll - appended by the events endpoint, which
-- applies the change and records it in one batch.
--
-- Events are COMMENTARY, not a ledger: the character row stays the source of
-- truth, and nothing ever replays events to derive state - replaying is how a
-- log inherits every consistency bug forever. What the log buys is undo (the
-- payload carries from/to values, so the latest event can be reversed), a
-- who-did-what trail when a G.M. and a player share a sheet, and the
-- end-of-session journal recap.
--
-- Undo marks undone_at rather than deleting - the row that says "this
-- happened and was taken back" is itself part of what happened. A 'recap'
-- kind row marks a session boundary; the next recap summarises from there.
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

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('022-play-events.sql');
