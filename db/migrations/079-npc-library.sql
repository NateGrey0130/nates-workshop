-- 079: npc_library - a G.M.'s own statted NPCs, belonging to no campaign.
--
-- A G.M. who rolls a good villain wants to keep them for the next table, and a
-- statted NPC was a `characters` row, which cannot exist without a campaign:
-- characters.campaign_id is NOT NULL and cascades on delete, and 37 files read
-- it. Making it nullable would put a row with no campaign in front of every one
-- of them. So the library is its own table (Nate, 2026-09-22), and an entry is a
-- SNAPSHOT: the sheet as `characters` stores it, plus the rows that hang off it
-- (open picks, grants, items, vehicles), frozen as JSON.
--
-- OWNER ONLY. An entry is read and written by `owner_email` and nobody else - not
-- another G.M., not an admin - and anyone else gets a 404, as a hidden NPC does
-- (isHiddenNpc). Pulling one into a campaign makes an INDEPENDENT copy there;
-- the entry and the copy never touch again.
--
-- `sheet` is JSON: { version, character: {...columns}, skill_picks, power_picks,
-- grants, items, vehicles }. `source` says how it arrived. Portraits live on the
-- dossier (npcs), not the sheet, so a snapshot carries none.
CREATE TABLE IF NOT EXISTS npc_library (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_email TEXT NOT NULL,
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  sheet TEXT NOT NULL,
  source TEXT NOT NULL CHECK (source IN ('notable', 'creature', 'generated', 'campaign')),
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_npc_library_owner ON npc_library (owner_email);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('079-npc-library.sql');
