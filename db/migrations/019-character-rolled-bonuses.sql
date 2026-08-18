-- Combat and save bonuses a class states as DICE, rolled once and stored.
--
--   { "combat": { "initiative": 3 }, "saves": { "spell_magic": 2 } }
--
-- The Godling grants "+1D4 on initiative" (Rifts, Pantheons of the Megaverse
-- p.16). Combat and save numbers are recomputed on every render, so a dice
-- bonus re-evaluated each time would move the character's initiative under
-- them. Same reasoning as `attribute_bonuses` in migration 016.
--
-- Attributes keep their own column rather than moving in here: 016 predates
-- this, its flat attribute -> number shape is read directly in several places,
-- and rewriting stored rows to gain tidiness would be a poor trade.
--
-- One-shot. Run once per environment, in filename order.
ALTER TABLE characters ADD COLUMN rolled_bonuses TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('019-character-rolled-bonuses.sql');
