-- One-off data cleanup, run once per environment. NOT a migration — it changes
-- rows, not schema.
--
--   npx wrangler d1 execute DB --local  --file apps/character-creator/db/backfill-gear-system.sql
--   npx wrangler d1 execute DB --remote --file apps/character-creator/db/backfill-gear-system.sql
--
-- Safe to run twice, and self-limiting: it only ever touches rows that are still
-- NULL, and only when the source book names a system it recognises.
--
-- BACKGROUND. No catalog importer set `system` — only the class importer's stub
-- creation did, from the class being imported. So the 34 rows from the first
-- real gear import landed NULL while the stubs around them said 'rifts', and
-- /items?system=rifts (which matched only 'rifts' or 'both') hid every one of
-- them from the character sheet.
--
-- NULL now reads as unrestricted, so those rows work either way. This makes them
-- precise, which matters the moment a Palladium Fantasy equipment chapter is
-- imported and "unrestricted" stops being harmless.
--
-- Import sessions record their system from here on, so this is for the rows that
-- predate that.

UPDATE gear
SET system = 'rifts'
WHERE system IS NULL
  AND source_book IS NOT NULL
  AND lower(source_book) LIKE '%rifts%';

UPDATE gear
SET system = 'palladium-fantasy'
WHERE system IS NULL
  AND source_book IS NOT NULL
  AND (lower(source_book) LIKE '%palladium fantasy%' OR lower(source_book) LIKE '%palladium-fantasy%');

-- Report. `still_null` is not a failure: a row whose book does not name a system
-- is correctly left unrestricted rather than guessed at, and the catalog editor
-- can set it by hand.
SELECT (SELECT count(*) FROM gear WHERE system = 'rifts') AS rifts,
       (SELECT count(*) FROM gear WHERE system = 'palladium-fantasy') AS palladium_fantasy,
       (SELECT count(*) FROM gear WHERE system = 'both') AS both,
       (SELECT count(*) FROM gear WHERE system IS NULL) AS still_null,
       (SELECT group_concat(DISTINCT source_book) FROM gear WHERE system IS NULL) AS unclassified_books;
