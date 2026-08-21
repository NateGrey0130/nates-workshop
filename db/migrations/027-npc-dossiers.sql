-- NPC dossiers: who the campaign has met, and every note that mentions them.
--
-- Campaign-scoped, not global. An NPC belongs to one table's game; a shared
-- dossier would leak what one group knows into another's, and the campaigns
-- here do not share a world.

CREATE TABLE IF NOT EXISTS npcs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  aliases TEXT,                          -- JSON array; matched by the sweep too
  faction TEXT,
  disposition TEXT,                      -- free text: 'hostile', 'owes us a favour'
  status TEXT NOT NULL DEFAULT 'unknown'
    CHECK (status IN ('alive', 'dead', 'unknown', 'never-met')),
  description TEXT,
  portrait_key TEXT,                     -- R2 object key; NULL = no portrait
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_npcs_campaign ON npcs (campaign_id);

-- One dossier per name per campaign. This is what makes @Kevik resolve to a
-- person rather than to three near-identical rows nobody merges. NOCASE so
-- '@kevik' and '@Kevik' are the same person.
CREATE UNIQUE INDEX IF NOT EXISTS idx_npcs_campaign_name
  ON npcs (campaign_id, name COLLATE NOCASE);

-- Which entries mention whom, and WHO SAID SO.
--
-- `source` distinguishes a link a person typed from one a model inferred. Same
-- instinct as the `override: true` flag on out-of-category skill picks: a
-- decision made by software should be visible as one, not blend into the ones a
-- human made.
CREATE TABLE IF NOT EXISTS npc_mentions (
  npc_id INTEGER NOT NULL REFERENCES npcs(id) ON DELETE CASCADE,
  journal_entry_id INTEGER NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  source TEXT NOT NULL CHECK (source IN ('mention', 'ai')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (npc_id, journal_entry_id)
);
CREATE INDEX IF NOT EXISTS idx_npc_mentions_entry ON npc_mentions (journal_entry_id);

-- Sweep bookkeeping: what the model has already looked at.
--
-- Marked only AFTER a successful response, so a failed call is retried rather
-- than silently skipped - an entry marked swept by a call that never returned
-- is an entry nobody will ever look at again.
CREATE TABLE IF NOT EXISTS npc_sweeps (
  journal_entry_id INTEGER PRIMARY KEY REFERENCES journal_entries(id) ON DELETE CASCADE,
  swept_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Names a human has already said are not people.
--
-- Without this the next sweep proposes 'the guard' again, and the one after
-- that, and the button becomes noise. Keyed on the name rather than an id
-- because a dismissed proposal never became a row.
CREATE TABLE IF NOT EXISTS npc_proposals_dismissed (
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  dismissed_by TEXT NOT NULL,
  dismissed_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (campaign_id, name COLLATE NOCASE)
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('027-npc-dossiers.sql');
