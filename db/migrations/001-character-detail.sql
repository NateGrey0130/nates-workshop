-- Adds the bio / combat / saving-throw / armor sections to an existing
-- characters table. db/schema.sql already carries these for a fresh database.
--
-- RUN ONCE per environment. SQLite has no ADD COLUMN IF NOT EXISTS, so a second
-- run fails with "duplicate column name" — that error means it is already
-- applied and nothing is wrong.
--
--   npx wrangler d1 execute nates-workshop-media --remote --file db/migrations/001-character-detail.sql
--
-- Check first with:
--   SELECT name FROM pragma_table_info('characters') WHERE name IN ('bio','combat','saves','armor');

ALTER TABLE characters ADD COLUMN bio TEXT NOT NULL DEFAULT '{}';
ALTER TABLE characters ADD COLUMN combat TEXT NOT NULL DEFAULT '{}';
ALTER TABLE characters ADD COLUMN saves TEXT NOT NULL DEFAULT '{}';
ALTER TABLE characters ADD COLUMN armor TEXT NOT NULL DEFAULT '[]';

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('001-character-detail.sql');
