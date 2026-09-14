-- A skill's percentage, where one GAME prints a different one from another.
--
-- BOOK-INGEST-AUDIT.md F83. The catalog holds one `base` and one `per_level`
-- per skill, and that was true enough while every book in it was Palladium's
-- own. Heroes Unlimited is a different game: it prints its own figure for every
-- skill, and of the 55 names it shares with the catalog, 48 DISAGREE. Computer
-- Operation is 60% here and 40% there; Prowl is 46% +8%/level against 25% +5%.
--
-- WHY A TABLE RATHER THAN A NUMBER IN THE CLASS. A class CAN state an absolute
-- `base:` and the fourteen Heroes Unlimited classes already do - but only for a
-- skill it NAMES. A choice group ("select three Domestic skills") states a
-- `bonus:`, which adds to whatever the picked row holds, and there is nowhere
-- to put the book's own figure. Across the sixteen education classes that is
-- 108 of 432 entries, a quarter of everything they grant, arriving at another
-- game's percentages with nothing to say so.
--
-- The divergence is a property of (skill, system) and not of any class, which
-- is what this table's key says. One row per disagreement: ~48 for this book,
-- and Nightbane - surveyed and not yet imported - will want its own.
--
-- KEYED ON THE NAME, NOT THE ID. `skills.id` is INTEGER PRIMARY KEY
-- AUTOINCREMENT, so it is insertion order and differs per environment: a
-- database rebuilt from this repo matched production on 0 of 1025 gear ids
-- when that was last measured. `skills.name` is NOT NULL UNIQUE, so it is a
-- legal foreign-key target and it is the same value in every environment.
--
-- ON UPDATE CASCADE is the half that matters most. A catalog rename has broken
-- class restrictions here before - six classes silently offering a Pilot skill
-- their book forbids, because an unmatched `except` fails open - and an
-- override stranded by a rename would fail the same way, quietly handing back
-- the wrong game's number.
--
-- NULL MEANS "NO OPINION", per column. A book that prints the same base and a
-- different per-level gain states only the one it changes, and the reader
-- coalesces. Both null would be a row that says nothing, which the CHECK
-- refuses rather than storing.

CREATE TABLE IF NOT EXISTS skill_system_bases (
  skill_name TEXT NOT NULL
    REFERENCES skills(name) ON DELETE CASCADE ON UPDATE CASCADE,
  system TEXT NOT NULL
    CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  base INTEGER,                           -- NULL = this game does not change it
  per_level INTEGER,                      -- NULL = same
  note TEXT,                              -- why it differs, or what else the page says
  source_book TEXT,                       -- the book and page the figure came from
  CHECK (base IS NOT NULL OR per_level IS NOT NULL),
  PRIMARY KEY (skill_name, system)
);

-- Every reader loads one system's whole set at once - the wizard at boot, the
-- server per request - so `system` alone is the access path the primary key's
-- leading column cannot serve.
CREATE INDEX IF NOT EXISTS idx_skill_system_bases_system
  ON skill_system_bases(system);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('061-skill-system-bases.sql');
