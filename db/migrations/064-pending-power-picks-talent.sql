-- Widen `pending_power_picks.kind` so a TALENT grant can be banked.
--
-- BOOK-INGEST-AUDIT F76 (4 of 4). The Nightbane's free Talents are a LEVEL
-- schedule, not a creation-time lump: printed 106, "Acquiring Talents", gives
-- one Talent free at first level and one more at levels four, seven, ten and
-- twelve. A grant at level four has to be banked until the player spends it,
-- and banking writes a `pending_power_picks` row, whose `kind` is a two-value
-- CHECK.
--
-- ===================================================================
-- WHY THIS IS A REBUILD, AND WHY IT IS A SMALL ONE
-- ===================================================================
--
-- SQLite cannot alter a CHECK in place, so the table has to be rebuilt. Unlike
-- `058`'s rebuild of `campaigns`, which dragged 16 tables behind it, this one
-- is a single table:
--
--   nothing references it  - `SELECT name FROM sqlite_master WHERE type='table'
--                             AND sql LIKE '%REFERENCES pending_power_picks%'`
--                             answers [] against production, 2026-09-16
--   one index              - idx_pending_power_picks_character
--   rows in production     - 0, counted the same day
--
-- So the ordering dance `058` needed is not needed here: there are no children
-- to rewrite and no cascade to fall through. Create, copy, drop, rename.
--
-- COLUMNS ARE COPIED BY NAME, NOT BY POSITION, and that is load-bearing.
-- Production's table is the output of `036`'s rebuild plus five later ALTERs,
-- so `categories`, `slot`, `from_names`, `note` and `spell_traditions` sit at
-- the END there while `db/schema.sql` declares them in the middle. A positional
-- `INSERT INTO ... SELECT *` would put `note` in `spell_levels`. The new table
-- below is schema.sql's shape, so after this runs production and a fresh build
-- agree about column order for the first time.
--
-- 'talent' IS ADDED ALONE, and the contrast with `058` is deliberate: that
-- migration put BOTH new systems in because the parser already admitted both.
-- Here there is exactly one new kind and nothing else is waiting. What this
-- does copy from elsewhere is `character_grants`'s lesson, whose own comment
-- reads "All eight kinds are in the CHECK though only 'skill' is implemented,
-- because SQLite cannot alter one" - that table paid this cost once and chose
-- never to pay it again. This CHECK is not being pre-widened past 'talent' on
-- the same reasoning `058` used: a value nothing can produce is a claim about a
-- future nobody has read a book for.

CREATE TABLE pending_power_picks_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('spell', 'psionic', 'talent')),
  spell_levels TEXT,
  spell_traditions TEXT,
  categories TEXT,
  slot INTEGER NOT NULL DEFAULT 0,
  from_names TEXT,
  note TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT
);

INSERT INTO pending_power_picks_new
  (id, character_id, granted_at_level, count, kind, spell_levels, spell_traditions,
   categories, slot, from_names, note, created_at, claimed_at)
SELECT
   id, character_id, granted_at_level, count, kind, spell_levels, spell_traditions,
   categories, slot, from_names, note, created_at, claimed_at
  FROM pending_power_picks;

DROP TABLE pending_power_picks;

ALTER TABLE pending_power_picks_new RENAME TO pending_power_picks;

CREATE INDEX IF NOT EXISTS idx_pending_power_picks_character
  ON pending_power_picks (character_id, claimed_at);

-- READBACKS. `d1-apply` applies the file even when one of these fails, so they
-- are a report and not a gate - read them.

SELECT 'the CHECK admits a talent grant' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'pending_power_picks'
   AND instr(sql, '''talent''') > 0;

SELECT 'and still admits both kinds that existed before' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'pending_power_picks'
   AND instr(sql, '''spell''') > 0 AND instr(sql, '''psionic''') > 0;

SELECT 'the index came back with it' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'index' AND name = 'idx_pending_power_picks_character';

-- Every column is still here, which a positional copy is exactly what would
-- break. 13 is the column count of the CREATE above.
SELECT 'all thirteen columns survived the rebuild' AS assertion,
       count(*) AS got, 13 AS want
  FROM pragma_table_info('pending_power_picks');

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('064-pending-power-picks-talent.sql');
