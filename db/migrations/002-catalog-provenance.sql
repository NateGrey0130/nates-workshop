-- Tracks where a catalog entry came from, so the same skill imported from two
-- books can coexist and be told apart. `note` carries the oddities Palladium
-- skill entries are full of ("40%/30% climb/rappel", "counts as two skills").
--
-- RUN ONCE per environment. SQLite has no ADD COLUMN IF NOT EXISTS; a second
-- run failing with "duplicate column name" means it is already applied.
--
--   npx wrangler d1 execute nates-workshop-media --remote --file db/migrations/002-catalog-provenance.sql
--
-- Check first with:
--   SELECT name FROM pragma_table_info('skills') WHERE name IN ('source_book','note');

ALTER TABLE skills ADD COLUMN source_book TEXT;
ALTER TABLE skills ADD COLUMN note TEXT;
ALTER TABLE spells ADD COLUMN source_book TEXT;
ALTER TABLE psionic_powers ADD COLUMN source_book TEXT;
