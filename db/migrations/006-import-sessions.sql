-- Resumable catalog imports.
--
-- A skill chapter is two or three pages and finishes in one sitting. A spell
-- chapter is hundreds of entries across many pages and cannot be, so extracted
-- rows are staged here instead of living in a browser tab. Close the tab, come
-- back next week, carry on.
--
-- Deliberately catalog-agnostic: psionics and gear reuse these tables as-is.
-- `payload` is the extracted row as JSON rather than columns per catalog,
-- because the shape differs per catalog and this is a staging area, not the
-- catalog itself.

CREATE TABLE IF NOT EXISTS import_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,                -- spells | psionics | gear | skills
  name TEXT NOT NULL,
  source_book TEXT,
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

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('006-import-sessions.sql');
