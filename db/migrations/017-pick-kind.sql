-- A scheduled skill grant can now be for a secondary skill as well as a related
-- one: the Long Bowman gets one more secondary at levels 4, 7, 10 and 13.
-- Without this the pick was stored with no record of which it was, and
-- resolvePicks() wrote every claimed pick as `related`.
--
-- NULL means related, which is what every pick granted before this was.
ALTER TABLE pending_skill_picks ADD COLUMN kind TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('017-pick-kind.sql');
