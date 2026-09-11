-- The tradition a spell belongs to, and the traditions a banked level-up grant
-- may reach. BOOK-INGEST-AUDIT F57.
--
-- A class whose spell pick is stated only as a LEVEL RANGE was offered every
-- leveled spell in the catalog, whatever tradition it came from: a new Ley Line
-- Walker, pool levels 1-4, was offered 150 warlock, 12 Ocean and 5 Dolphin
-- spells beside its own invocations (measured --remote, 2026-09-10). Spells
-- carried nothing to filter on.
--
-- spells.tradition names the family - warlock, ocean, dolphin, spellsong,
-- cloud, shaman - and NULL is a general invocation. The rows are tagged by a
-- data script (apps/character-creator/db/zzzzzzzzz-f57-spell-traditions.sql),
-- not here, because a migration changes schema and the tagging is data.
--
-- pending_power_picks.spell_traditions freezes a level-up grant's allowance at
-- grant time, the way spell_levels freezes its cap. NULL - every row banked
-- before this migration, and every psionic row - reads as unrestricted, so a
-- grant already banked keeps the reach it was made with.
ALTER TABLE spells ADD COLUMN tradition TEXT;
ALTER TABLE pending_power_picks ADD COLUMN spell_traditions TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('055-spell-tradition.sql');
