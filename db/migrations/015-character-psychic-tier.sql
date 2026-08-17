-- A character can gain psionics by rolling on the Random Psionics Table
-- (Palladium Fantasy 2nd Ed. p.21), independently of its class. Until now the
-- tier could only come from the class, so there was nowhere to record it.
--
-- psychic_tier NULL means "not psychic, or psychic by class" — the class is
-- still consulted first, and this only answers what the class does not.
--
-- psychic_shape is which of the tier's power allowances was taken: a major
-- psionic chooses eight powers from one category or six from any of the three,
-- and the server has to know which to validate the count.
ALTER TABLE characters ADD COLUMN psychic_tier TEXT;
ALTER TABLE characters ADD COLUMN psychic_shape TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('015-character-psychic-tier.sql');
