-- Give gear a real stat block, and retire the `stats` JSON blob.
--
-- Spells and psionic powers use scalar columns; gear was the odd one out, and
-- the blob meant weapon damage was invisible in the schema and only editable as
-- generic key/value rows. Dropping it costs nothing: every gear row in both
-- local and production was `{}` — the column was never populated, because only
-- the class importer ever wrote to this table and it only ever wrote stubs.
--
-- TEXT for damage/range/payload/rate_of_fire because books write them as prose
-- as often as figures: "2D6 M.D. single shot, 6D6 M.D. burst", "2000 feet".
-- ar and mdc are INTEGER because the sheet's armour block uses them numerically.
--
-- is_mega_damage is the one boolean worth having structured. S.D.C. versus
-- M.D.C. is the most consequential distinction in Rifts, and reading it back out
-- of a damage string later is error-prone.

ALTER TABLE gear ADD COLUMN damage TEXT;
ALTER TABLE gear ADD COLUMN is_mega_damage INTEGER NOT NULL DEFAULT 0;
ALTER TABLE gear ADD COLUMN range TEXT;
ALTER TABLE gear ADD COLUMN payload TEXT;
ALTER TABLE gear ADD COLUMN rate_of_fire TEXT;
ALTER TABLE gear ADD COLUMN ar INTEGER;
ALTER TABLE gear ADD COLUMN mdc INTEGER;

ALTER TABLE gear DROP COLUMN stats;

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('008-gear-detail.sql');
