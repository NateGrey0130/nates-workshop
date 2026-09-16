-- Widen `pending_power_picks.kind` so a Talent PURCHASE allowance can be banked.
--
-- BOOK-INGEST-AUDIT F101 (2 of 3). Printed 106, "Acquiring Talents": "At level
-- one and upon reaching each subsequent new level of experience, the Nightbane
-- can purchase two additional Talents, but, each purchase will cost the
-- character a permanent expenditure of P.P.E.!" Nate's answer (2026-09-16) is
-- that an unused purchase BANKS, like a free pick - so it writes a row here.
--
-- A KIND OF ITS OWN, NOT A 'talent' ROW. A free Talent grant is spent by
-- choosing; a purchase is spent by choosing AND paying the Talent's
-- `acquire_ppe` out of the character's base. Sharing the kind would let one be
-- spent as the other, and both are keyed `kind:level:slot` - so at levels four,
-- seven, ten and twelve a free grant and a purchase allowance would collide on
-- the same key and be indistinguishable. PR #1093 already recorded this: "F101's
-- Talent purchases bank as a DIFFERENT grant kind from the power they yield".
--
-- THE SAME SINGLE-TABLE REBUILD AS 064, measured again rather than assumed, all
-- `--remote` 2026-09-16:
--
--   nothing references it  - count of tables whose sql names
--                            `REFERENCES pending_power_picks`: 0
--   one index              - idx_pending_power_picks_character
--   rows in production     - 0
--   columns                - 13, which 064's rebuild made agree with schema.sql
--
-- Columns are still copied BY NAME, not because production's order differs any
-- longer - 064 fixed that - but because a positional copy is the shape that
-- breaks the next time someone ALTERs this table.
--
-- 'talent_purchase' IS ADDED ALONE, on 064's reasoning: a value nothing can
-- produce is a claim about a future nobody has read a book for.

CREATE TABLE pending_power_picks_new (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('spell', 'psionic', 'talent', 'talent_purchase')),
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

SELECT 'the CHECK admits a talent purchase' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'pending_power_picks'
   AND instr(sql, '''talent_purchase''') > 0;

SELECT 'and still admits the three kinds that existed before' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'table' AND name = 'pending_power_picks'
   AND instr(sql, '''spell''') > 0 AND instr(sql, '''psionic''') > 0 AND instr(sql, '''talent''') > 0;

SELECT 'the index came back with it' AS assertion, count(*) AS got, 1 AS want
  FROM sqlite_master
 WHERE type = 'index' AND name = 'idx_pending_power_picks_character';

SELECT 'all thirteen columns survived the rebuild' AS assertion,
       count(*) AS got, 13 AS want
  FROM pragma_table_info('pending_power_picks');

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('066-pending-power-picks-talent-purchase.sql');
