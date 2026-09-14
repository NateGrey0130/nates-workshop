-- Widen `campaigns.system` so a THIRD game can have a campaign.
--
-- BOOK-INGEST-AUDIT F73, the half left standing. F73 was taken once already, in
-- PR #996, as its own Option C: catalog and classes only, with the CHECK
-- deliberately left alone because that was the recorded decision for the
-- Nightbane batch. Two games are now blocked behind it - Nightbane has been
-- surveyed since 2026-09-12 and Heroes Unlimited has fourteen classes, 364 super
-- abilities and 388 skills in production and no campaign they can be played in.
--
-- Both values go in, not just the one being worked on. `parser.js` has admitted
-- `nightbane` and `heroes-unlimited` since #996; this is the table catching up
-- with the parser, and adding one of the two would leave the same gap open.
--
-- ===================================================================
-- WHY THIS REBUILDS 16 TABLES TO CHANGE ONE CONSTRAINT
-- ===================================================================
--
-- SQLite cannot alter a CHECK in place, so `campaigns` has to be rebuilt - and
-- `campaigns` is referenced by six tables which are themselves parents of nine
-- more. Measured against production 2026-09-14:
--
--   direct children  6: characters, journal_entries, campaign_currency, npcs, npc_proposals_dismissed, campaign_items
--   transitive       15
--
-- F73's own options table called this "a table rebuild on `campaigns`", one
-- table. Its premise audit corrected that to "roughly 3 parents and 11
-- children". Both were low.
--
-- A CHEAPER ROUTE WAS TRIED FIRST AND IT DESTROYS DATA SILENTLY.
-- `PRAGMA legacy_alter_table = ON` is supposed to stop `ALTER TABLE ... RENAME`
-- from rewriting other tables' REFERENCES clauses, which would turn this into a
-- one-table operation: rename the parent aside, create the replacement under the
-- original name so every child's reference resolves to it, copy, drop the old.
-- Probed against local D1 on 2026-09-14 with a two-table parent/child pair:
--
--   D1 IGNORED THE PRAGMA. The child was rewritten to point at the renamed-aside
--   table, and `DROP TABLE` then took the child's row with it through
--   ON DELETE CASCADE. One row in, zero rows out, and the apply reported
--   "success": true.
--
-- That is the same family as the two pragmas `047` tried - `foreign_keys = OFF`
-- ignored outright, `defer_foreign_keys = ON` honoured and still failing - but
-- it is worse, because those two FAILED and this one SUCCEEDS while deleting
-- rows. A rollback does not help against an apply that works.
--
-- SO THE ORDER DOES THE WORK, exactly as `047` established for `gear`. Every
-- step below is legal with foreign keys fully enforced the whole way through:
--
--   1. build a suffixed copy of every table in the subtree, its REFERENCES
--      already pointing at the other suffixed copies;
--   2. copy the rows in, parents before children;
--   3. drop the originals, children before parents - each is unreferenced by
--      the time its turn comes, because everything that referenced it has
--      already gone;
--   4. rename the copies back, which is where SQLite rewrites the REFERENCES
--      clauses to follow;
--   5. recreate the indexes and triggers, which went with their tables in 3.
--
-- ROWS AT THE TIME OF WRITING, production 2026-09-14: 3 campaigns, 3 characters,
-- 2 journal entries, 57 character_items, 13 play_events, and eleven of the
-- sixteen tables empty. 78 rows in total, all of them snapshotted before this
-- was applied. The verification at the foot asserts every count back.
--
-- NO BEHAVIOUR CHANGE FOR EITHER EXISTING SYSTEM. Nothing is dropped, no column
-- changes type, no default moves. The database simply stops refusing two values
-- the parser has accepted since #996.

-- 1. the suffixed copies.

CREATE TABLE campaigns_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  system TEXT NOT NULL CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited')),
  gm_email TEXT NOT NULL,
  description TEXT,
  gm_notes TEXT,                        -- GM-only; stripped from non-GM API responses
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
, open INTEGER NOT NULL DEFAULT 1, rest_rates TEXT);

CREATE TABLE characters_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns_hu058(id) ON DELETE CASCADE,
  player_email TEXT NOT NULL,           -- Cloudflare Access identity of the owner
  name TEXT NOT NULL,
  class_id TEXT NOT NULL,               -- slug of the RCC/OCC markdown file, e.g. 'cyber-knight'
  level INTEGER NOT NULL DEFAULT 1,
  xp INTEGER NOT NULL DEFAULT 0,
  attributes TEXT NOT NULL DEFAULT '{}',  -- JSON: {"IQ": 12, "ME": 14, ...}
  skills TEXT NOT NULL DEFAULT '[]',      -- JSON: [{"name", "pct", "per_level", "type": "occ|related|secondary"}]
  powers TEXT NOT NULL DEFAULT '[]',      -- JSON: [{"type": "spell|psionic", "name", "cost", ...}]
  hp_max INTEGER,  hp_current INTEGER,
  sdc_max INTEGER, sdc_current INTEGER,
  mdc_max INTEGER, mdc_current INTEGER,   -- M.D.C. beings (e.g. dragon hatchlings) use this instead of HP/SDC
  ppe_max INTEGER, ppe_current INTEGER,
  isp_max INTEGER, isp_current INTEGER,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
, bio TEXT NOT NULL DEFAULT '{}', combat TEXT NOT NULL DEFAULT '{}', saves TEXT NOT NULL DEFAULT '{}', armor TEXT NOT NULL DEFAULT '[]', class_variant TEXT, occ_class_id TEXT, occ_class_variant TEXT, psychic_tier TEXT, psychic_shape TEXT, attribute_bonuses TEXT, abilities TEXT, rolled_bonuses TEXT, mos TEXT, totem TEXT);

CREATE TABLE npcs_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns_hu058(id) ON DELETE CASCADE,
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

CREATE TABLE journal_entries_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns_hu058(id) ON DELETE CASCADE,
  character_id INTEGER REFERENCES characters_hu058(id) ON DELETE CASCADE,  -- NULL = campaign-level entry
  author_email TEXT NOT NULL,
  title TEXT,
  body TEXT NOT NULL,
  session_date TEXT,                    -- in-world or real session date, freeform ISO string
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE play_events_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
  actor_email TEXT NOT NULL,
  kind TEXT NOT NULL,                   -- damage | pool | power | ammo | roll | recap
  payload TEXT NOT NULL,                -- JSON: note, and changes {from, to} for undo
  undone_at TEXT,                       -- NULL = stands
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE pending_skill_picks_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  categories TEXT,                      -- JSON array; NULL = no category restriction
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT                       -- NULL = still unspent
, kind TEXT);

CREATE TABLE pending_power_picks_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
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
, categories TEXT, slot INTEGER NOT NULL DEFAULT 0, from_names TEXT, note TEXT, spell_traditions TEXT);

CREATE TABLE npc_sweeps_hu058 (
  journal_entry_id INTEGER PRIMARY KEY REFERENCES journal_entries_hu058(id) ON DELETE CASCADE,
  swept_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE npc_proposals_dismissed_hu058 (
  campaign_id INTEGER NOT NULL REFERENCES campaigns_hu058(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  dismissed_by TEXT NOT NULL,
  dismissed_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (campaign_id, name COLLATE NOCASE)
);

CREATE TABLE npc_mentions_hu058 (
  npc_id INTEGER NOT NULL REFERENCES npcs_hu058(id) ON DELETE CASCADE,
  journal_entry_id INTEGER NOT NULL REFERENCES journal_entries_hu058(id) ON DELETE CASCADE,
  source TEXT NOT NULL CHECK (source IN ('mention', 'ai')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (npc_id, journal_entry_id)
);

CREATE TABLE level_history_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
  from_level INTEGER NOT NULL,
  to_level INTEGER NOT NULL,
  xp_at_levelup INTEGER,
  changes TEXT NOT NULL DEFAULT '{}',   -- JSON diff of what the level-up actually applied
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE character_vehicles_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
  vehicle_slug TEXT REFERENCES vehicles(slug),        -- NULL = freeform, custom_name required
  custom_name TEXT,
  nickname TEXT,
  mdc_current TEXT,                                   -- JSON object keyed by vehicle_locations.location
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries_hu058(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                    -- NULL = still owned
  CHECK (vehicle_slug IS NOT NULL OR custom_name IS NOT NULL)
);

CREATE TABLE character_items_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES "gear"(slug),           -- NULL = freeform custom item
  custom_name TEXT,
  qty INTEGER NOT NULL DEFAULT 1,
  equipped INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  enchantments TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries_hu058(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);

CREATE TABLE character_grants_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters_hu058(id) ON DELETE CASCADE,
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

CREATE TABLE campaign_items_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns_hu058(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES "gear"(slug),         -- NULL = freeform custom item
  custom_name TEXT,
  qty INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries_hu058(id) ON DELETE SET NULL,
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,
  removed_by TEXT,
  claimed_by_character_id INTEGER REFERENCES characters_hu058(id) ON DELETE SET NULL,
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);

CREATE TABLE campaign_currency_hu058 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns_hu058(id) ON DELETE CASCADE,
  currency TEXT NOT NULL,
  delta INTEGER NOT NULL,                           -- signed; positive is income
  reason TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries_hu058(id) ON DELETE SET NULL,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- 2. the rows, parents before children.

INSERT INTO campaigns_hu058 (id, name, system, gm_email, description, gm_notes, created_at, open, rest_rates) SELECT id, name, system, gm_email, description, gm_notes, created_at, open, rest_rates FROM campaigns;

INSERT INTO characters_hu058 (id, campaign_id, player_email, name, class_id, level, xp, attributes, skills, powers, hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current, ppe_max, ppe_current, isp_max, isp_current, notes, created_at, updated_at, bio, combat, saves, armor, class_variant, occ_class_id, occ_class_variant, psychic_tier, psychic_shape, attribute_bonuses, abilities, rolled_bonuses, mos, totem) SELECT id, campaign_id, player_email, name, class_id, level, xp, attributes, skills, powers, hp_max, hp_current, sdc_max, sdc_current, mdc_max, mdc_current, ppe_max, ppe_current, isp_max, isp_current, notes, created_at, updated_at, bio, combat, saves, armor, class_variant, occ_class_id, occ_class_variant, psychic_tier, psychic_shape, attribute_bonuses, abilities, rolled_bonuses, mos, totem FROM characters;

INSERT INTO npcs_hu058 (id, campaign_id, name, aliases, faction, disposition, status, description, portrait_key, created_by, created_at, updated_at) SELECT id, campaign_id, name, aliases, faction, disposition, status, description, portrait_key, created_by, created_at, updated_at FROM npcs;

INSERT INTO journal_entries_hu058 (id, campaign_id, character_id, author_email, title, body, session_date, created_at) SELECT id, campaign_id, character_id, author_email, title, body, session_date, created_at FROM journal_entries;

INSERT INTO play_events_hu058 (id, character_id, actor_email, kind, payload, undone_at, created_at) SELECT id, character_id, actor_email, kind, payload, undone_at, created_at FROM play_events;

INSERT INTO pending_skill_picks_hu058 (id, character_id, granted_at_level, count, categories, created_at, claimed_at, kind) SELECT id, character_id, granted_at_level, count, categories, created_at, claimed_at, kind FROM pending_skill_picks;

INSERT INTO pending_power_picks_hu058 (id, character_id, granted_at_level, count, kind, spell_levels, created_at, claimed_at, categories, slot, from_names, note, spell_traditions) SELECT id, character_id, granted_at_level, count, kind, spell_levels, created_at, claimed_at, categories, slot, from_names, note, spell_traditions FROM pending_power_picks;

INSERT INTO npc_sweeps_hu058 (journal_entry_id, swept_at) SELECT journal_entry_id, swept_at FROM npc_sweeps;

INSERT INTO npc_proposals_dismissed_hu058 (campaign_id, name, dismissed_by, dismissed_at) SELECT campaign_id, name, dismissed_by, dismissed_at FROM npc_proposals_dismissed;

INSERT INTO npc_mentions_hu058 (npc_id, journal_entry_id, source, created_at) SELECT npc_id, journal_entry_id, source, created_at FROM npc_mentions;

INSERT INTO level_history_hu058 (id, character_id, from_level, to_level, xp_at_levelup, changes, created_at) SELECT id, character_id, from_level, to_level, xp_at_levelup, changes, created_at FROM level_history;

INSERT INTO character_vehicles_hu058 (id, character_id, vehicle_slug, custom_name, nickname, mdc_current, notes, journal_entry_id, added_at, removed_at) SELECT id, character_id, vehicle_slug, custom_name, nickname, mdc_current, notes, journal_entry_id, added_at, removed_at FROM character_vehicles;

INSERT INTO character_items_hu058 (id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments, journal_entry_id, added_at, removed_at) SELECT id, character_id, gear_slug, custom_name, qty, equipped, notes, enchantments, journal_entry_id, added_at, removed_at FROM character_items;

INSERT INTO character_grants_hu058 (id, character_id, kind, name, value, detail, reason, granted_by, granted_at_level, claimed_at, created_at) SELECT id, character_id, kind, name, value, detail, reason, granted_by, granted_at_level, claimed_at, created_at FROM character_grants;

INSERT INTO campaign_items_hu058 (id, campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id, added_by, added_at, removed_at, removed_by, claimed_by_character_id) SELECT id, campaign_id, gear_slug, custom_name, qty, notes, journal_entry_id, added_by, added_at, removed_at, removed_by, claimed_by_character_id FROM campaign_items;

INSERT INTO campaign_currency_hu058 (id, campaign_id, currency, delta, reason, journal_entry_id, created_by, created_at) SELECT id, campaign_id, currency, delta, reason, journal_entry_id, created_by, created_at FROM campaign_currency;

-- 3. the originals, children before parents.

DROP TABLE campaign_currency;
DROP TABLE campaign_items;
DROP TABLE character_grants;
DROP TABLE character_items;
DROP TABLE character_vehicles;
DROP TABLE level_history;
DROP TABLE npc_mentions;
DROP TABLE npc_proposals_dismissed;
DROP TABLE npc_sweeps;
DROP TABLE pending_power_picks;
DROP TABLE pending_skill_picks;
DROP TABLE play_events;
DROP TABLE journal_entries;
DROP TABLE npcs;
DROP TABLE characters;
DROP TABLE campaigns;

-- 4. the copies take their names back. SQLite rewrites every REFERENCES
--    clause in the other copies as each rename lands.

ALTER TABLE campaigns_hu058 RENAME TO campaigns;
ALTER TABLE characters_hu058 RENAME TO characters;
ALTER TABLE npcs_hu058 RENAME TO npcs;
ALTER TABLE journal_entries_hu058 RENAME TO journal_entries;
ALTER TABLE play_events_hu058 RENAME TO play_events;
ALTER TABLE pending_skill_picks_hu058 RENAME TO pending_skill_picks;
ALTER TABLE pending_power_picks_hu058 RENAME TO pending_power_picks;
ALTER TABLE npc_sweeps_hu058 RENAME TO npc_sweeps;
ALTER TABLE npc_proposals_dismissed_hu058 RENAME TO npc_proposals_dismissed;
ALTER TABLE npc_mentions_hu058 RENAME TO npc_mentions;
ALTER TABLE level_history_hu058 RENAME TO level_history;
ALTER TABLE character_vehicles_hu058 RENAME TO character_vehicles;
ALTER TABLE character_items_hu058 RENAME TO character_items;
ALTER TABLE character_grants_hu058 RENAME TO character_grants;
ALTER TABLE campaign_items_hu058 RENAME TO campaign_items;
ALTER TABLE campaign_currency_hu058 RENAME TO campaign_currency;

-- 5. the 19 indexes and triggers that went with the tables in step 3.

CREATE INDEX idx_characters_campaign ON characters (campaign_id);
CREATE INDEX idx_characters_player ON characters (player_email);
CREATE INDEX idx_journal_campaign ON journal_entries (campaign_id);
CREATE INDEX idx_journal_character ON journal_entries (character_id);
CREATE INDEX idx_level_history_character ON level_history (character_id);
CREATE INDEX idx_pending_picks_character
  ON pending_skill_picks (character_id, claimed_at);
CREATE INDEX idx_play_events_character ON play_events (character_id, id);
CREATE TRIGGER journal_fts_ai AFTER INSERT ON journal_entries BEGIN
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;
CREATE TRIGGER journal_fts_ad AFTER DELETE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
END;
CREATE TRIGGER journal_fts_au AFTER UPDATE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;
CREATE INDEX idx_campaign_currency_campaign
  ON campaign_currency (campaign_id, currency);
CREATE INDEX idx_npcs_campaign ON npcs (campaign_id);
CREATE UNIQUE INDEX idx_npcs_campaign_name
  ON npcs (campaign_id, name COLLATE NOCASE);
CREATE INDEX idx_npc_mentions_entry ON npc_mentions (journal_entry_id);
CREATE INDEX idx_pending_power_picks_character
  ON pending_power_picks (character_id, claimed_at);
CREATE INDEX idx_character_grants_character
  ON character_grants (character_id, kind);
CREATE INDEX idx_character_items_character ON character_items (character_id);
CREATE INDEX idx_campaign_items_campaign ON campaign_items (campaign_id);
CREATE INDEX idx_character_vehicles_character
  ON character_vehicles (character_id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('058-campaign-system-third-game.sql');

-- VERIFICATION.

SELECT 'campaigns admits four systems' AS assertion,
       CASE WHEN instr(sql, '''nightbane''') > 0 AND instr(sql, '''heroes-unlimited''') > 0
            THEN 1 ELSE 0 END AS got, 1 AS want
  FROM sqlite_master WHERE name = 'campaigns';

SELECT 'campaigns kept its rows' AS assertion, count(*) AS got, 3 AS want FROM campaigns;
SELECT 'characters kept its rows' AS assertion, count(*) AS got, 3 AS want FROM characters;
SELECT 'npcs kept its rows' AS assertion, count(*) AS got, 0 AS want FROM npcs;
SELECT 'journal_entries kept its rows' AS assertion, count(*) AS got, 2 AS want FROM journal_entries;
SELECT 'play_events kept its rows' AS assertion, count(*) AS got, 13 AS want FROM play_events;
SELECT 'pending_skill_picks kept its rows' AS assertion, count(*) AS got, 0 AS want FROM pending_skill_picks;
SELECT 'pending_power_picks kept its rows' AS assertion, count(*) AS got, 0 AS want FROM pending_power_picks;
SELECT 'npc_sweeps kept its rows' AS assertion, count(*) AS got, 0 AS want FROM npc_sweeps;
SELECT 'npc_proposals_dismissed kept its rows' AS assertion, count(*) AS got, 0 AS want FROM npc_proposals_dismissed;
SELECT 'npc_mentions kept its rows' AS assertion, count(*) AS got, 0 AS want FROM npc_mentions;
SELECT 'level_history kept its rows' AS assertion, count(*) AS got, 0 AS want FROM level_history;
SELECT 'character_vehicles kept its rows' AS assertion, count(*) AS got, 0 AS want FROM character_vehicles;
SELECT 'character_items kept its rows' AS assertion, count(*) AS got, 57 AS want FROM character_items;
SELECT 'character_grants kept its rows' AS assertion, count(*) AS got, 0 AS want FROM character_grants;
SELECT 'campaign_items kept its rows' AS assertion, count(*) AS got, 0 AS want FROM campaign_items;
SELECT 'campaign_currency kept its rows' AS assertion, count(*) AS got, 0 AS want FROM campaign_currency;

SELECT 'every index and trigger is back' AS assertion, count(*) AS got, 19 AS want
  FROM sqlite_master
 WHERE type IN ('index', 'trigger') AND sql IS NOT NULL
   AND tbl_name IN ('campaigns', 'characters', 'journal_entries', 'campaign_currency', 'npcs', 'npc_proposals_dismissed', 'campaign_items', 'level_history', 'pending_skill_picks', 'play_events', 'pending_power_picks', 'character_grants', 'character_items', 'character_vehicles', 'npc_mentions', 'npc_sweeps');

SELECT 'no suffixed table survived' AS assertion, count(*) AS got, 0 AS want
  FROM sqlite_master WHERE name LIKE '%_hu058';