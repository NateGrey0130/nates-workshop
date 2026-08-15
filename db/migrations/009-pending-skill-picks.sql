-- Skill picks a level-up granted but the player has not spent yet.
--
-- occ_related_skills.schedule has always recorded that a class grants extra
-- picks at levels 3/6/9/12; the level-up flow read it and did nothing with it.
-- This is where an unspent grant waits.
--
-- One row per GRANT, not per pick, so "2 picks from Physical or Rogue, earned
-- at level 3" stays intact and itemised rather than dissolving into a pool.
-- categories is a JSON array copied from the class at the moment of the
-- level-up: the class definition can change afterwards, and what you were
-- granted should not change with it.

CREATE TABLE IF NOT EXISTS pending_skill_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  categories TEXT,                      -- JSON array; NULL = no category restriction
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT                       -- NULL = still unspent
);
CREATE INDEX IF NOT EXISTS idx_pending_picks_character
  ON pending_skill_picks (character_id, claimed_at);

-- Record this migration as applied. See db/schema.sql for the convention.
INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('009-pending-skill-picks.sql');
