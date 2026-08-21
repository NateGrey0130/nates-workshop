-- Several power grants can share a level, each with its own restriction.
--
-- `pending_power_picks` assumed one grant per level per kind, which held until
-- the Shifter. Rifts Ultimate Edition, Shifter O.C.C.: starting at level two it
-- gains THREE spells each level, and each comes from a different place —
--
--   slot 0   one spell from the O.C.C.'s named list
--   slot 1   one Protection or Summoning spell, also from that list
--   slot 2   one spell of any kind, capped at the character's own level
--
-- Those are three grants, not one grant of three, because a grant carries its
-- own restriction. `slot` is what tells them apart, and everything that keys a
-- grant now keys on level AND slot.
--
-- `from_names` and `note` travel with a banked grant for the same reason
-- `spell_levels` and `categories` already do: the class can be re-imported, and
-- what a character was granted at level 4 cannot change retroactively.
--
-- `note` holds a restriction the catalog CANNOT enforce. Spells carry no
-- category or tag, so "non-dimension related or control based" has nothing to
-- filter on; the rule is shown to the player at the point of choosing instead of
-- being silently dropped or silently enforced wrongly.

ALTER TABLE pending_power_picks ADD COLUMN slot INTEGER NOT NULL DEFAULT 0;
ALTER TABLE pending_power_picks ADD COLUMN from_names TEXT;
ALTER TABLE pending_power_picks ADD COLUMN note TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('030-power-pick-slots.sql');
