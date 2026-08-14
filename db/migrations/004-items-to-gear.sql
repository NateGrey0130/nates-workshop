-- Rename the gear catalog from `items` to `gear`.
--
-- `items` is a generic name in a database shared with MediaVault, which already
-- has `media_items`. No collision today; it is the most likely future one, and
-- PR 7 is about to add a full stat block to this table — cheaper to rename now.
--
-- UNLIKE EVERY MIGRATION BEFORE THIS ONE, THIS IS NOT ADDITIVE. The moment it
-- runs, code still querying `items` fails. Apply it immediately before merging
-- the matching deploy, not ahead of time.
--
-- SQLite rewrites `REFERENCES items(id)` in character_items automatically when
-- legacy_alter_table is off (the default in modern SQLite and in D1). Verify
-- rather than assume:
--   SELECT sql FROM sqlite_master WHERE name = 'character_items';
-- It should read REFERENCES gear(id). If it still says items, the foreign key
-- is broken and the table needs rebuilding.

ALTER TABLE items RENAME TO gear;

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('004-items-to-gear.sql');
