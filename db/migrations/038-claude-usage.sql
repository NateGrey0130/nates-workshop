-- Who is spending the Anthropic key, on what. The /api/claude proxy is open
-- to every authenticated friend by design - FilamentForge and MediaVault call
-- it from the browser - and until now nothing recorded a single call: the
-- audit's F3. This is the log half of that proposal (spend visibility, not a
-- cap): one row per call, written fail-open so metering can never break the
-- call it measures. A site-level table, like media_items - it belongs to the
-- proxy, not to any one app.
CREATE TABLE IF NOT EXISTS claude_usage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT,                            -- Cloudflare Access identity; NULL on local dev
  endpoint TEXT NOT NULL,                -- 'proxy' | 'campaign-ask' | ...
  model TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  status INTEGER,                        -- upstream HTTP status; a 4xx/5xx row is a
                                         -- failed call that still cost an attempt
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_claude_usage_email ON claude_usage (email, created_at);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('038-claude-usage.sql');
