-- Spells and psionic powers a level-up granted and nobody has chosen yet.
--
-- `pending_skill_picks` with a different subject, and for the same reason:
-- levelling up is never blocked on choosing, so a grant that is not spent in
-- the same request has to go somewhere. Without this table a player who
-- confirmed a level-up without picking would silently lose the spells that
-- level earned, which is exactly the quiet wrongness the wizard's Advancement
-- step was built to avoid.
--
-- One row per GRANT, not per pick, so "2 spells earned at level 4" stays
-- itemised and keeps the cap that came with it.

CREATE TABLE IF NOT EXISTS pending_power_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('spell', 'psionic')),
  -- JSON array of the SPELL levels this grant may draw from; NULL means
  -- unrestricted, and it is always NULL for a psionic grant.
  --
  -- Copied from the class at grant time, exactly as pending_skill_picks copies
  -- its categories: the class can be re-imported with a different rule later,
  -- and what a character was granted at level 4 cannot change retroactively.
  spell_levels TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_pending_power_picks_character
  ON pending_power_picks (character_id, claimed_at);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('028-pending-power-picks.sql');
