-- INGESTION-AUDIT F33: one Gas Mask row, carrying the retired row's provenance.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-ingestion-f33-gas-mask.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-ingestion-f33-gas-mask.sql
--
-- The catalog held the same mask twice, both `rifts`, both cost 50:
--
--   gas-mask             cited by 21 classes, held by 3 characters,
--                        source_book 'Web reference (not book-verified)', no cost_note
--   gas-mask-human-size  cited by NOTHING, held by nobody,
--                        source_book 'Rifts Ultimate Edition p.261-270',
--                        cost_note '50-80 cr. (half that used)'
--
-- The plain row's own description says it IS the human-sized mask. The genuine
-- variant is a third row, gas-mask-oversized at 80, which this does not touch.
--
-- gas-mask SURVIVES because it carries every citation and every holding, so
-- nothing moves. But the row being retired carries the BETTER metadata, so this
-- takes it with it rather than throwing it away: the RUE citation replaces a
-- source_book that scripts/books.json lists under `not_books` and therefore
-- resolves to no page, and the cost range arrives as a real cost_note.
--
-- That citation is INHERITED, not freshly read. fix-rue-gear-review.sql wrote it
-- for a batch of RUE gear rows and zzzz-restore-gear-values.sql then corrected
-- their costs from the top of each printed range to the bottom - which is why
-- both rows read 50 today and why the note says 'half that used'. Nobody opened
-- the page for this script.
--
-- This sorts after fix-rue-gear-review.sql, which creates the retired row, and
-- after zzzz-restore-gear-values.sql, which sets the values being moved.

-- 1. The survivor takes the retired row's provenance, guarded on the web
--    reference so it cannot overwrite a citation someone has since corrected.
UPDATE gear
   SET source_book = (SELECT source_book FROM gear WHERE slug = 'gas-mask-human-size'),
       cost_note   = (SELECT cost_note   FROM gear WHERE slug = 'gas-mask-human-size')
 WHERE slug = 'gas-mask'
   AND source_book = 'Web reference (not book-verified)'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'gas-mask-human-size');

-- 2. Any holding moves. Zero rows today; guarded so a later environment that
--    does have some is not left pointing at nothing.
UPDATE character_items
   SET gear_slug = 'gas-mask'
 WHERE gear_slug = 'gas-mask-human-size';

-- 3. The retired slug forwards, before the delete rather than after.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'gas-mask-human-size', id, 'merge'
  FROM gear
 WHERE slug = 'gas-mask'
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- 4. Retire the duplicate. Guarded on the cost so it cannot fire against a row
--    someone has since corrected into something else.
DELETE FROM gear
 WHERE slug = 'gas-mask-human-size'
   AND cost = 50;

-- --- readbacks ---

SELECT 'one human-sized gas mask row' AS assertion,
       (SELECT count(*) FROM gear WHERE slug IN ('gas-mask', 'gas-mask-human-size')) AS got,
       1 AS want;

SELECT 'it carries the book rather than the web reference' AS assertion,
       (SELECT count(*) FROM gear
         WHERE slug = 'gas-mask'
           AND source_book = 'Rifts Ultimate Edition p.261-270'
           AND cost_note = '50-80 cr. (half that used)') AS got,
       1 AS want;

SELECT 'no gear row still cites a non-book for this mask' AS assertion,
       (SELECT count(*) FROM gear
         WHERE slug = 'gas-mask' AND source_book = 'Web reference (not book-verified)') AS got,
       0 AS want;

SELECT 'the retired slug forwards to the survivor' AS assertion,
       (SELECT count(*) FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
         WHERE r.catalog = 'gear' AND r.from_key = 'gas-mask-human-size'
           AND g.slug = 'gas-mask') AS got,
       1 AS want;

-- The oversized mask is a DIFFERENT item at a different price and must survive
-- untouched - it is the variant this pair is NOT.
SELECT 'the oversized mask is not collateral' AS assertion,
       (SELECT count(*) FROM gear WHERE slug = 'gas-mask-oversized' AND cost = 80) AS got,
       1 AS want;

-- Records this run. Every statement above guards itself, so the script is safe
-- to re-run, and a run that correctly did nothing is still a run that happened.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ingestion-f33-gas-mask.sql');
