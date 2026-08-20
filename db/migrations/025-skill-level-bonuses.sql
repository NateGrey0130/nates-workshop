-- What a Hand to Hand skill grants at each level of experience.

-- The `bonuses` column added by migration 023 is FLAT: it applies whole, at
-- every level, which is right for Boxing (+1 attack, +2 parry and dodge) and
-- wrong for every Hand to Hand skill in the book. Rifts Ultimate Edition p.347
-- is explicit that these are level-by-level tables and that "ALL bonuses are
-- accumulative" - a 5th level Expert has levels 1 through 5, not level 5.
--
-- So the whole mechanical payload of the 29 W.P.s and 5 Hand to Hand skills had
-- nowhere to live and was simply absent: base 0, per_level 0, no bonuses, no
-- note. A character's fighting skill contributed nothing at all.
--
-- This column carries a JSON array, one entry per level that grants something:
--
--   [{"level":1,"combat":{"attacks_base":4,"pull_punch":2,"roll":2}},
--    {"level":2,"combat":{"parry":2,"dodge":2}},
--    {"level":3,"note":"Kick attack does 1D8 damage."}]
--
-- `combat`, `saves` and `attributes` hold the same groups `bonuses` does, and
-- everything at or below the character's level is summed. `note` carries what
-- is not a number - "Karate Kick (2D6 damage)", "Death blow on a Natural 20" -
-- because dropping it would discard most of what the tables actually say.
--
-- `attacks_base` is the one key that SETS rather than adds. The books state a
-- starting number outright ("starts with four attacks per melee round"), and
-- adding four to the derived base would give a first level Expert six.
--
-- Kept separate from `bonuses` rather than folded into it: `bonuses` means "in
-- effect, always", and derive.js applies it unconditionally. A level schedule
-- living in that column would either be applied at every level or silently
-- ignored, and both are worse than a column that says what it is.
ALTER TABLE skills ADD COLUMN level_bonuses TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('025-skill-level-bonuses.sql');
