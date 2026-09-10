-- The table's own rest rates, set by the GM on the campaign dashboard
-- (UI-AUDIT F52): JSON {pool: per-hour recovery}, or NULL for none.
--
-- They lived only in one device's localStorage, so a player on a new phone
-- started blank. NULL is the normal state, and no default number ships: the
-- books' recovery pages are not in the rules audit, and a rate the app invented
-- would be silently trusted. The sheet prefers these and falls back to the
-- device's own.
ALTER TABLE campaigns ADD COLUMN rest_rates TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('054-campaign-rest-rates.sql');
