-- Give a spell enough of a stat block to cast from.
--
-- The catalog held name, level and PPE only, which is not enough to play with —
-- you still needed the book open. These are TEXT rather than numbers on purpose:
-- book values are prose as often as figures ("100 feet per level of experience",
-- "2D6 melee rounds", "2D6 M.D. per level").

ALTER TABLE spells ADD COLUMN range TEXT;
ALTER TABLE spells ADD COLUMN duration TEXT;
ALTER TABLE spells ADD COLUMN damage TEXT;
ALTER TABLE spells ADD COLUMN saving_throw TEXT;
ALTER TABLE spells ADD COLUMN area_of_effect TEXT;
ALTER TABLE spells ADD COLUMN casting_time TEXT;
ALTER TABLE spells ADD COLUMN description TEXT;

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('005-spell-detail.sql');
