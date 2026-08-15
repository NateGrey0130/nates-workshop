-- 012 — which game system a catalog row belongs to, and which one a book is for.
--
-- Gear has always had `system` and skills `systems`, but NOTHING set them: only
-- the class importer's stub creation did, from the class being imported. So the
-- 34 items from the first real gear import landed NULL, and were invisible on
-- the character sheet until /items learned to read NULL as unrestricted.
--
-- Spells and psionic powers had no system column at all, which is a genuine
-- modelling gap rather than an oversight of the importer — Palladium Fantasy
-- and Rifts have substantially different spell lists, and a Palladium Fantasy
-- spell chapter would otherwise offer its spells to Rifts mages.
--
-- NULL keeps meaning UNRESTRICTED everywhere, which is how skills.systems has
-- always read. An operator who does not know, or a book that genuinely covers
-- both, gets the honest answer instead of a guess.
ALTER TABLE spells ADD COLUMN system TEXT;
ALTER TABLE psionic_powers ADD COLUMN system TEXT;

-- The book being imported is a property of the SESSION, not of each page: you
-- pick it once when you start the import, and every row confirmed out of that
-- session inherits it.
ALTER TABLE import_sessions ADD COLUMN system TEXT;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('012-catalog-system.sql');
