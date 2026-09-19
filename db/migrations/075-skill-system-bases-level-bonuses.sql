-- A W.P.'s bonus schedule where one GAME prints a different one.
--
-- BOOK-INGEST-AUDIT.md F102, option A. Migration 061 gave a skill a per-game
-- `base` and `per_level` (F83), and a weapon proficiency has neither: every
-- W.P. is `base 0 / per_level 0` and carried wholly by `level_bonuses`. So when
-- Heroes Unlimited prints its own W.P. Targeting - thrown AND bows, +1 strike at
-- 2, 4, 7, 10 and 13 (printed 36) - against the catalog's Palladium Fantasy row
-- (not bows, +1 at 1, 3, 7 and 10), the fourteen Heroes Unlimited classes that
-- grant it hand out the other game's numbers with nothing to say so. Nightbane
-- does the same to W.P. Archery (printed 58).
--
-- ONE COLUMN, ON THE TABLE F83 ALREADY CHOSE, rather than a third convention.
-- The divergence is still a property of (skill, system). The reader applies it
-- to the row exactly as it applies `base` - see applySystemBases in
-- apps/character-creator/js/skill-base.js - and it REPLACES the row's schedule
-- rather than merging into it, because a book that prints a W.P. prints the
-- whole progression.
--
-- A REBUILD, NOT AN ALTER, because the CHECK has to change: 061 refuses a row
-- with neither `base` nor `per_level`, which is exactly what a W.P. override
-- is. SQLite cannot alter a CHECK in place. Measured `--remote` 2026-09-19:
--
--   nothing references it  - tables whose sql names `REFERENCES skill_system_bases`: 0
--   one index              - idx_skill_system_bases_system (plus the primary key's own)
--   rows in production     - 89
--   columns                - skill_name, system, base, per_level, note, source_book
--
-- Columns are copied BY NAME, for the reason 066 gives.
--
-- `json_valid` on the new column, because a W.P. schedule arriving as broken
-- JSON would parse to nothing and the character would silently lose the
-- weapon's bonuses - the failure this whole finding is about, one level down.

CREATE TABLE skill_system_bases_new (
  skill_name TEXT NOT NULL
    REFERENCES skills(name) ON DELETE CASCADE ON UPDATE CASCADE,
  system TEXT NOT NULL
    CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  base INTEGER,                           -- NULL = this game does not change it
  per_level INTEGER,                      -- NULL = same
  level_bonuses TEXT                      -- NULL = same; else REPLACES skills.level_bonuses
    CHECK (level_bonuses IS NULL OR json_valid(level_bonuses)),
  note TEXT,                              -- why it differs, or what else the page says
  source_book TEXT,                       -- the book and page the figure came from
  CHECK (base IS NOT NULL OR per_level IS NOT NULL OR level_bonuses IS NOT NULL),
  PRIMARY KEY (skill_name, system)
);

INSERT INTO skill_system_bases_new (skill_name, system, base, per_level, note, source_book)
SELECT skill_name, system, base, per_level, note, source_book
  FROM skill_system_bases;

DROP TABLE skill_system_bases;

ALTER TABLE skill_system_bases_new RENAME TO skill_system_bases;

CREATE INDEX IF NOT EXISTS idx_skill_system_bases_system
  ON skill_system_bases(system);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('075-skill-system-bases-level-bonuses.sql');

-- READBACKS. A report, not a gate - read them.

SELECT 'the column is there' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'skill_system_bases' AND instr(sql, 'level_bonuses') > 0;

SELECT 'the index came back with it' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'index' AND name = 'idx_skill_system_bases_system';

SELECT 'no row carries a schedule yet' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases WHERE level_bonuses IS NOT NULL;
