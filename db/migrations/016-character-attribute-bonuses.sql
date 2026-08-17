-- A class may state an attribute bonus as dice rather than a fixed number:
-- "add 2D6 to P.S." (Juicer), "add +1D4 to M.A., M.E., P.S., P.E. and Spd"
-- (Cyber-Knight). The dice belong to the class; what they came up belongs to
-- the character, because a roll cannot be re-evaluated on every render.
--
-- JSON, shaped like `attributes`: { "PS": 7, "Spd": 40 }. NULL or absent means
-- the class grants no dice bonuses, which is true of most.
ALTER TABLE characters ADD COLUMN attribute_bonuses TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('016-character-attribute-bonuses.sql');
