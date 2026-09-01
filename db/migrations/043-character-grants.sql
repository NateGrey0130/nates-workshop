-- Things a table hands out that no class schedule granted: a patron teaches a
-- skill, an artefact confers a power, an implant adds S.D.C., a god hands over
-- a spell. The G.M. says so out loud and, until now, there was nowhere for it
-- to go -- `gm_abilities` covered one of the eight kinds below.
--
-- The player types these in on their own sheet, because that is how they
-- arrive: verbally, mid-session. So this is deliberately NOT a G.M.-only
-- table, and integrity comes from the record rather than from a permission
-- wall. That is what `reason` is for, and why it is NOT NULL with no default:
-- the person entering a grant is usually its beneficiary, and the reason is
-- the only thing standing between a record and an unfalsifiable claim.
--
-- All eight kinds are named in the CHECK now even though only 'skill' is
-- implemented, because SQLite cannot alter a CHECK constraint -- adding a kind
-- later would mean a whole table rebuild, which is what 036 had to do.
--
-- Removal is a hard DELETE, by owner or G.M., logged to play_events. A grant
-- is current state, not a ledger; a withdrawn ruling is not like a stash item
-- that left the party, and keeping withdrawn rows in the table that decides
-- current effects is one forgotten filter away from a bonus coming back from
-- the dead.
--
-- See apps/character-creator/docs/plans/19-gm-grants.md.
CREATE TABLE IF NOT EXISTS character_grants (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  kind TEXT NOT NULL CHECK (kind IN
    ('skill', 'spell', 'psionic', 'ability', 'attribute', 'pool', 'combat', 'save')),
  name TEXT NOT NULL,                   -- catalog name, or the key: 'PS', 'sdc_max', 'attacks'
  value INTEGER,                        -- the delta, for the four numeric kinds; NULL otherwise
  detail TEXT,                          -- JSON: what was written, or a choice's terms
  reason TEXT NOT NULL,                 -- why the table gave it
  granted_by TEXT NOT NULL,             -- Access identity of whoever typed it in
  granted_at_level INTEGER,             -- what level the character was when it landed
  claimed_at TEXT,                      -- for a CHOICE: NULL until the player spends it
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_character_grants_character
  ON character_grants (character_id, kind);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('043-character-grants.sql');
