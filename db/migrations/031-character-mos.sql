-- Which Military Occupational Specialty a character took.
--
-- RUE gives several classes an MOS: "select one of the following areas of
-- specialty, gain all skills under that MOS" (Coalition Technical Officer,
-- printed p236; Robot Pilot, p84). The granted skills land in `skills` like any
-- other, but WHICH specialty was chosen has to be remembered - for the sheet,
-- and so the choice can be re-derived rather than inferred from the skill list.
--
-- Parallel to class_variant and occ_class_variant: a TEXT id naming an entry in
-- the class definition, NULL when the class offers no MOS or none was picked.
--
-- Not a variant, despite the resemblance. A variant REPLACES what the class
-- says and VARIANT_OVERRIDES excludes the skills block on purpose; an MOS ADDS
-- a skill package on top of the O.C.C. skills every member already has.

ALTER TABLE characters ADD COLUMN mos TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('031-character-mos.sql');
