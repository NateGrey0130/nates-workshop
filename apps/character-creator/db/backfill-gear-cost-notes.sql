-- The price ranges RUE prints, into the column that can hold them.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-gear-cost-notes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-gear-cost-notes.sql
--
-- Migration 032 added gear.cost_note because a price is often a range and the
-- integer could only hold one end of it. This fills it for the rows that made
-- the case: the common gear on printed pp.261-263, read in column order.
--
-- GUARDED ON THE COST BEING THE LOW END. A row whose stored cost is not the
-- bottom of the book's range is not a row this script understands, so it is
-- left alone rather than annotated with a range it may not match.
--
-- 8 rows.

UPDATE gear SET cost_note = '60-100 cr.'
 WHERE slug = 'bicycle-basic' AND cost = 60 AND cost_note IS NULL;
UPDATE gear SET cost_note = '2-6 cr.'
 WHERE slug = 'cigarettes-16-in-a-pack' AND cost = 2 AND cost_note IS NULL;
UPDATE gear SET cost_note = '25-80 cr.'
 WHERE slug = 'duffle-bag' AND cost = 25 AND cost_note IS NULL;
UPDATE gear SET cost_note = '80-200 cr.'
 WHERE slug = 'knife-skinning' AND cost = 80 AND cost_note IS NULL;
UPDATE gear SET cost_note = '15-75 cr.'
 WHERE slug = 'knife-small' AND cost = 15 AND cost_note IS NULL;
UPDATE gear SET cost_note = '200-600 cr.'
 WHERE slug = 'knife-throwing' AND cost = 200 AND cost_note IS NULL;
UPDATE gear SET cost_note = '2-5 cr.'
 WHERE slug = 'pocket-or-signal-mirror' AND cost = 2 AND cost_note IS NULL;
UPDATE gear SET cost_note = '110-160 cr.'
 WHERE slug = 'sleeping-bag' AND cost = 110 AND cost_note IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS with_cost_note FROM gear WHERE cost_note IS NOT NULL;

INSERT INTO data_script_runs (filename) VALUES ('backfill-gear-cost-notes.sql');
