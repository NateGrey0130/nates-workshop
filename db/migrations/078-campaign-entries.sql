-- The GM's own pages, and the pictures they show the table.
--
-- P4a of the app split (2026-09-19). `campaigns.gm_notes` is ONE text blob per
-- campaign, stripped from every non-GM response - fine for a line about the
-- table, useless for a setting: a city, a faction, next session's prep and a
-- handout all lived in the same paragraph or in nothing at all.
--
-- TWO TABLES, AND THE SPLIT BETWEEN THEM IS THE WHOLE RULE. An ENTRY is the
-- GM's and is never revealed: its title and body stay behind the GM check for
-- as long as it exists. An IMAGE can be revealed, one at a time, and its
-- CAPTION is the only text a player ever reads from here. That is Nate's call
-- (2026-09-19) and it is why reveal is a column on the image rather than on the
-- entry: a map of the city is shown while the notes behind it are not.
--
-- `revealed_at` IS A TIMESTAMP, NOT A FLAG, because "what have I shown them,
-- and when" is a question a GM asks mid-session and a boolean cannot answer.
-- NULL means never shown.
--
-- `entry_id` IS NULLABLE so a picture can exist with no page behind it - the
-- handout someone drops in ten minutes before a session. ON DELETE CASCADE, so
-- deleting a page takes its pictures' ROWS; the R2 OBJECTS are deleted by the
-- endpoint in the same request, because a database cascade cannot reach a
-- bucket and an orphan there is invisible and billed monthly. That is the
-- lesson npcs/[npcId].js already learned for portraits.

CREATE TABLE IF NOT EXISTS campaign_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  -- What kind of page this is. A closed set, because it is what the list
  -- groups by; 'prep' is next session's plan and 'handout' is a picture with
  -- nothing much to say about it.
  kind TEXT NOT NULL DEFAULT 'lore'
    CHECK (kind IN ('place', 'faction', 'lore', 'handout', 'prep')),
  title TEXT NOT NULL,
  body TEXT,                             -- GM-only, always. Never revealed.
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_campaign_entries_campaign
  ON campaign_entries (campaign_id, kind);

CREATE TABLE IF NOT EXISTS campaign_images (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  entry_id INTEGER REFERENCES campaign_entries(id) ON DELETE CASCADE,  -- NULL = loose handout
  r2_key TEXT NOT NULL,                  -- the object in MEDIA; see npcs.portrait_key
  content_type TEXT,
  byte_size INTEGER,
  caption TEXT,                          -- the ONE thing a player reads from here
  revealed_at TEXT,                      -- NULL = the GM's alone; a timestamp = shown
  sort INTEGER NOT NULL DEFAULT 0,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- The player-facing read is "this campaign's revealed images, newest first",
-- and the GM's is "this entry's, in order". One index each.
CREATE INDEX IF NOT EXISTS idx_campaign_images_revealed
  ON campaign_images (campaign_id, revealed_at);
CREATE INDEX IF NOT EXISTS idx_campaign_images_entry
  ON campaign_images (entry_id, sort);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('078-campaign-entries.sql');

-- READBACKS. A report, not a gate - read them.

SELECT 'both tables exist' AS assertion, count(*) AS got, 2 AS want
  FROM sqlite_master WHERE type = 'table'
   AND name IN ('campaign_entries', 'campaign_images');

SELECT 'an entry is never revealable' AS assertion, count(*) AS got, 0 AS want
  FROM pragma_table_info('campaign_entries') WHERE name = 'revealed_at';

SELECT 'an image is' AS assertion, count(*) AS got, 1 AS want
  FROM pragma_table_info('campaign_images') WHERE name = 'revealed_at';

SELECT 'and a picture can stand on its own' AS assertion, count(*) AS got, 0 AS want
  FROM pragma_table_info('campaign_images') WHERE name = 'entry_id' AND "notnull" = 1;
