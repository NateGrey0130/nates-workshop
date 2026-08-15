-- 011 — an in-progress character build, saved server-side.
--
-- Building a character is eight steps and includes attribute ROLLS. A refresh,
-- a stray back-gesture or a closed tab lost all of it, and a roll cannot be
-- reproduced — you either accept different numbers or re-roll until you are
-- lying to yourself.
--
-- Its own table rather than a `draft` status on `characters`, deliberately.
-- A half-built character is not a character: it has no name yet, no campaign,
-- and attributes that may not exist. Putting one in `characters` would mean
-- every list, the dashboard, the audit and the validator all growing a filter
-- for rows they must never treat as real, forever, to serve a state that lasts
-- minutes. The wizard's state is not a character shape either — it carries
-- which roll method was used per attribute, which choice-group options are
-- ticked, and how far through the steps you are.
--
-- UNIQUE on owner_email is what enforces "one draft at a time": the save is an
-- upsert, so a newer build simply replaces the older one.
CREATE TABLE IF NOT EXISTS character_drafts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_email TEXT NOT NULL UNIQUE,
  -- Denormalised purely so "resume your Juicer, step 4" can be rendered
  -- without parsing the blob. The blob remains the source of truth.
  system TEXT,
  class_id TEXT,
  class_name TEXT,
  char_name TEXT,
  step INTEGER NOT NULL DEFAULT 0,
  state TEXT NOT NULL,                            -- JSON: the wizard's build state
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('011-character-drafts.sql');
