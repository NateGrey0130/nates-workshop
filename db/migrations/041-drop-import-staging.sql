-- Drop the in-app importer's two staging tables.
--
-- `import_sessions` and `import_staged` were added by 006 to hold a resumable
-- catalog import: a session per book chapter, one staged row per extracted
-- catalog row, held until an operator confirmed them. The importer that wrote
-- them was retired in the PR before this one, and the reason it was retired is
-- the reason this is safe: IT NEVER RAN. Both tables held zero rows in
-- production on the day they were dropped, and `claude_usage` held no import
-- call to have produced any.
--
-- 006 itself is NOT deleted and must not be. It has run in every environment,
-- and drift-check compares migration FILES against `schema_migrations` - a
-- recorded migration with no file is drift in the other direction. Its seed
-- line in schema.sql moves to the both-halves form instead, the same shape 004
-- uses for the items -> gear rename: the app's tables exist AND these two do
-- not.
--
-- The index on each goes with its table; SQLite drops those automatically.

DROP TABLE IF EXISTS import_staged;
DROP TABLE IF EXISTS import_sessions;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('041-drop-import-staging.sql');
