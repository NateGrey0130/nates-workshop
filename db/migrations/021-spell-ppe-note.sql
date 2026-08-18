-- A cost schedule for spells whose P.P.E. is not one number - the same shape
-- migration 020 gave psionic powers, for the same reason: the cost column is
-- live (the sheet's use button deducts it from the character's current
-- P.P.E.), so a flat number spends the wrong amount and a zero reads as free
-- while matching the import stub heuristic.
--
-- Manipulate Objects is the standing case: its entry prices the cost by a
-- schedule with no single figure, and it landed from the RUE chapter import
-- with ppe 0.
--
-- The convention: `ppe` holds the MINIMUM cost, and a non-null `ppe_note`
-- carries the schedule in a few words. The use button keeps deducting the
-- minimum - the G.M. adjusts the pool by hand for bigger spends, exactly as
-- at a real table.
ALTER TABLE spells ADD COLUMN ppe_note TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('021-spell-ppe-note.sql');
