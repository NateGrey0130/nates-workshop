-- Abilities the player chose from a class's `special_abilities` choice group.
--
-- A list of names, and DUPLICATES ARE MEANINGFUL: the Godling's Shape Shifter
-- and Magic Powers can each be taken twice, and the book gives the second take
-- a different meaning rather than a doubled one. So this is a JSON array and
-- not a set.
--
--   ["Super-Tough", "Shape Shifter", "Shape Shifter"]
--
-- Chosen before attributes and pools are rolled, because an ability can add to
-- both: Super-Tough is +1D6 P.E. and +3D4x10 M.D.C.
--
-- One-shot. Run once per environment, in filename order.
ALTER TABLE characters ADD COLUMN abilities TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('018-character-abilities.sql');
