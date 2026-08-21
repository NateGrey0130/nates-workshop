-- A banked PSIONIC grant can carry a category restriction of its own.
--
-- `pending_power_picks` stored `spell_levels` and nothing for psionics, because
-- when it was written no class stated a per-level psionic rule. The Mystic
-- does, and it is not the same restriction its starting powers use:
--
--   "Select three additional psychic abilities from the Sensitive category and
--    another two from the Healer category. At levels four and eight the Mystic
--    can select one additional ability from the Super category."
--                                        - Rifts Ultimate Edition p.119
--
-- Starting powers come from Sensitive and Healing; the ones gained at levels 4
-- and 8 come from SUPER, which a major psychic could not otherwise take. The
-- grant naming the category is the book granting the exception, so the
-- restriction belongs to the grant rather than to the class.
--
-- Copied at grant time for the same reason `spell_levels` is: a class can be
-- re-imported with a different rule later, and what a character was granted at
-- level 4 cannot change retroactively.

ALTER TABLE pending_power_picks ADD COLUMN categories TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('029-power-pick-categories.sql');
