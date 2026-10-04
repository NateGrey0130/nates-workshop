-- Widen `pending_power_picks.kind` so a CLASS ABILITY pick can be banked.
--
-- BOOK-INGEST-AUDIT F116. Rifts Japan's Mystic Ninja takes one art of
-- invisibility at levels 1, 3, 6, 9, 12 and 15 (printed 53); the Bishamon and
-- Sohei monks and China 2's Demon Quellers pick the same way. A class states it
-- as a `special_abilities` choice group with `at_levels`, and each level above
-- creation banks a grant the sheet's banked-picks panel spends - which writes a
-- row here, whose `kind` is a four-value CHECK.
--
-- NO NEW COLUMN. The finding asked for one to hold the option list, and its
-- premise audit found it already exists: `from_names` (migration 030), written
-- and enforced for spell and psionic grants. An ability grant's list rides
-- there, its `slot` is its group's index, and every other restriction column
-- is NULL.
--
-- A KIND OF ITS OWN because of where it is spent: a spell, a psionic power and
-- a Talent land in `characters.powers`; a class ability lands in
-- `characters.abilities`, where `applyAbilities` folds it, and its dice and
-- pool bonuses are rolled into the stored character as it is spent.
--
-- THE SAME SINGLE-TABLE REBUILD AS 064 AND 066, measured again rather than
-- assumed, all `--remote` 2026-10-04:
--
--   nothing references it  - sqlite_master rows naming `pending_power_picks`:
--                            the table and idx_pending_power_picks_character
--   one outgoing key       - character_id -> characters(id) ON DELETE CASCADE
--   rows in production     - 0
--   columns                - 13, in schema.sql's order since 064
--
-- Columns are copied BY NAME, on 066's reasoning: a positional copy is the
-- shape that breaks the next time someone ALTERs this table.
--
-- 'ability' IS ADDED ALONE, on 064's reasoning: a value nothing can produce is
-- a claim about a future nobody has read a book for.

CREATE TABLE pending_power_picks_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('spell', 'psionic', 'talent', 'talent_purchase', 'ability')),
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

SELECT 'the CHECK admits a class ability' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'pending_power_picks'
   AND instr(sql, '''ability''') > 0;

SELECT 'and still admits the four kinds that existed before' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'pending_power_picks'
   AND instr(sql, '''spell''') > 0 AND instr(sql, '''psionic''') > 0
   AND instr(sql, '''talent''') > 0 AND instr(sql, '''talent_purchase''') > 0;

SELECT 'the index came back with it' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'index' AND name = 'idx_pending_power_picks_character';

SELECT 'all thirteen columns survived the rebuild' AS assertion,
       count(*) AS got, 13 AS want
  FROM pragma_table_info('pending_power_picks');

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('090-pending-power-picks-ability.sql');
