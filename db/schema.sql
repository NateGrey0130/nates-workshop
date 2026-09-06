-- ═══════════════════════════════════════════════════════════════════
-- Migration bookkeeping. Which db/migrations/*.sql files a database has
-- had applied. Everything else in this file is CREATE ... IF NOT EXISTS,
-- so re-running it is safe; the seeding block at the bottom keeps this
-- table honest on databases that predate it.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS schema_migrations (
  filename   TEXT PRIMARY KEY,
  applied_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- MediaVault library storage, scoped per Cloudflare Access user email
CREATE TABLE IF NOT EXISTS media_items (
  user_email TEXT NOT NULL,
  item_id    TEXT NOT NULL,
  type       TEXT NOT NULL DEFAULT 'audiobook',
  format     TEXT NOT NULL DEFAULT 'digital',
  title      TEXT NOT NULL,
  author     TEXT NOT NULL DEFAULT '',
  actors     TEXT NOT NULL DEFAULT '',
  producers  TEXT NOT NULL DEFAULT '',
  genre      TEXT NOT NULL DEFAULT '',
  series     TEXT NOT NULL DEFAULT '',
  location   TEXT NOT NULL DEFAULT '',
  cover      TEXT NOT NULL DEFAULT '',
  notes      TEXT NOT NULL DEFAULT '',
  -- Where this row came from, so its lookup can be run again exactly: the
  -- normalised ISBN for a book, 'tmdb:movie:1234' / 'tmdb:tv:1234' for video.
  -- Empty on every row saved before 040, which is honest rather than a gap.
  source_id  TEXT NOT NULL DEFAULT '',
  added_at   INTEGER NOT NULL,
  PRIMARY KEY (user_email, item_id)
);

CREATE INDEX IF NOT EXISTS idx_media_items_user ON media_items (user_email);

-- Who is spending the Anthropic key, on what. Site-level, like media_items:
-- it belongs to the /api/claude proxy rather than to any one app. One row per
-- call, written fail-open (a metering failure must never break the call it
-- measures). The log half of the audit's F3 - spend visibility, not a cap.
CREATE TABLE IF NOT EXISTS claude_usage (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email TEXT,                            -- Cloudflare Access identity; NULL on local dev
  endpoint TEXT NOT NULL,                -- 'proxy' | 'campaign-ask' | ...
  model TEXT,
  input_tokens INTEGER,
  output_tokens INTEGER,
  status INTEGER,                        -- upstream HTTP status; a 4xx/5xx row is a
                                         -- failed call that still cost an attempt
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_claude_usage_email ON claude_usage (email, created_at);

-- ═══════════════════════════════════════════════════════════════════
-- FilamentForge — AI slicer-settings engine. Six tables, all prefixed
-- ff_ because the character creator's tables share this database
-- unprefixed: the prefix is the collision boundary. ff_brands and
-- ff_filaments are a snapshot of the Open Filament Database, refreshed
-- by scripts/ofd-refresh.mjs and read by /api/filament-forge/catalog so
-- the app has no runtime dependency on openfilamentdatabase.org. The
-- four user tables hold what used to live in localStorage, keyed to the
-- Access email the way media_items is.
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS ff_brands (
  id         TEXT PRIMARY KEY,           -- OFD brand id
  name       TEXT NOT NULL,
  fetched_at TEXT NOT NULL               -- when the snapshot holding this row was taken
);

CREATE TABLE IF NOT EXISTS ff_filaments (
  id                    TEXT PRIMARY KEY, -- OFD filament id
  brand_id              TEXT NOT NULL,
  name                  TEXT NOT NULL,
  material              TEXT NOT NULL DEFAULT '',
  density               TEXT NOT NULL DEFAULT '',
  diameter_tolerance    TEXT NOT NULL DEFAULT '',
  min_print_temperature TEXT NOT NULL DEFAULT '',
  max_print_temperature TEXT NOT NULL DEFAULT '',
  min_bed_temperature   TEXT NOT NULL DEFAULT '',
  max_bed_temperature   TEXT NOT NULL DEFAULT '',
  max_dry_temperature   TEXT NOT NULL DEFAULT '',
  slicer_settings       TEXT NOT NULL DEFAULT '',
  fetched_at            TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_ff_filaments_brand ON ff_filaments (brand_id);

-- The printer dropdowns: one row per user, replaced on every change.
CREATE TABLE IF NOT EXISTS ff_config (
  email      TEXT PRIMARY KEY,
  printer    TEXT NOT NULL DEFAULT '',
  nozzle     TEXT NOT NULL DEFAULT '',
  ams        TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- One row per generated result, capped at 50 per user by the endpoint.
-- `settings` and `raw_json` are the parsed and unparsed halves of the same
-- Claude response, stored both because the app displays both.
CREATE TABLE IF NOT EXISTS ff_history (
  email      TEXT NOT NULL,
  entry_id   TEXT NOT NULL,
  created_at TEXT NOT NULL,
  brand      TEXT NOT NULL DEFAULT '',
  name       TEXT NOT NULL DEFAULT '',
  material   TEXT NOT NULL DEFAULT '',
  printer    TEXT NOT NULL DEFAULT '',
  nozzle     TEXT NOT NULL DEFAULT '',
  intent     TEXT NOT NULL DEFAULT '',
  settings   TEXT NOT NULL DEFAULT '{}', -- JSON
  raw_json   TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (email, entry_id)
);

-- A history entry the user named and chose to keep. Same shape plus the name,
-- and no cap - saving is deliberate where history is automatic.
CREATE TABLE IF NOT EXISTS ff_presets (
  email       TEXT NOT NULL,
  entry_id    TEXT NOT NULL,
  preset_name TEXT NOT NULL,
  saved_at    TEXT NOT NULL,
  created_at  TEXT NOT NULL,
  brand       TEXT NOT NULL DEFAULT '',
  name        TEXT NOT NULL DEFAULT '',
  material    TEXT NOT NULL DEFAULT '',
  printer     TEXT NOT NULL DEFAULT '',
  nozzle      TEXT NOT NULL DEFAULT '',
  intent      TEXT NOT NULL DEFAULT '',
  settings    TEXT NOT NULL DEFAULT '{}', -- JSON
  raw_json    TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (email, entry_id)
);

-- A filament the user typed in because OFD does not list it.
CREATE TABLE IF NOT EXISTS ff_custom_filaments (
  email          TEXT NOT NULL,
  filament_id    TEXT NOT NULL,
  brand          TEXT NOT NULL,
  name           TEXT NOT NULL,
  material       TEXT NOT NULL DEFAULT '',
  min_print_temp TEXT NOT NULL DEFAULT '',
  max_print_temp TEXT NOT NULL DEFAULT '',
  min_bed_temp   TEXT NOT NULL DEFAULT '',
  max_bed_temp   TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (email, filament_id)
);

-- ═══════════════════════════════════════════════════════════════════
-- Character Creator — Palladium Fantasy / Rifts characters & campaigns.
-- R.C.C./O.C.C. definitions live in `imported_classes` below as markdown;
-- characters reference them by class_id slug. (An earlier design kept them
-- as committed files under apps/character-creator/data — that is gone.)
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS campaigns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  system TEXT NOT NULL CHECK (system IN ('rifts', 'palladium-fantasy')),
  gm_email TEXT NOT NULL,
  description TEXT,
  gm_notes TEXT,                        -- GM-only; stripped from non-GM API responses
  open INTEGER NOT NULL DEFAULT 1,      -- 1 = anyone on the site may join by creating a
                                        -- character in it; 0 = GM and existing members
                                        -- only. Joining IS creating a character, so this
                                        -- is the door onto the campaign's notes, stash
                                        -- and ledger. Migration 037.
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS characters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  player_email TEXT NOT NULL,           -- Cloudflare Access identity of the owner
  name TEXT NOT NULL,
  class_id TEXT NOT NULL,               -- slug of the RCC/OCC markdown file, e.g. 'cyber-knight'
  class_variant TEXT,                   -- which `variants` entry, e.g. 'hatchling'; NULL = the class as written
  occ_class_id TEXT,                    -- the O.C.C. taken alongside an R.C.C.; NULL = none
  occ_class_variant TEXT,
  mos TEXT,                             -- which `skills.mos` option was taken; NULL = the class offers none

  psychic_tier TEXT,                    -- rolled on the Random Psionics Table; NULL = none, or psychic by class
  psychic_shape TEXT,                   -- which power allowance was taken ('focused' | 'broad')
  attribute_bonuses TEXT,                -- JSON: what the class's dice attribute bonuses rolled
  abilities TEXT,                        -- JSON array of chosen ability names; duplicates are meaningful
  rolled_bonuses TEXT,                   -- JSON: what a class's dice combat/save bonuses came up
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
  -- Sheet sections stored as JSON rather than ~40 scalar columns, because the
  -- shapes are sparse and this file only ever CREATEs. See db/migrations/ for
  -- the one-shot ALTERs that add these to an existing database.
  bio TEXT NOT NULL DEFAULT '{}',        -- race, alignment, age, height, sentiments, …
  combat TEXT NOT NULL DEFAULT '{}',     -- attacks, initiative, strike/parry/dodge, punches
  saves TEXT NOT NULL DEFAULT '{}',      -- save vs magic, psionics, poison, insanity, …
  armor TEXT NOT NULL DEFAULT '[]',      -- [{ name, ar, mdc_max, mdc_current, weight, cost, prowl }]
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_characters_campaign ON characters (campaign_id);
CREATE INDEX IF NOT EXISTS idx_characters_player ON characters (player_email);

CREATE TABLE IF NOT EXISTS journal_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  character_id INTEGER REFERENCES characters(id) ON DELETE CASCADE,  -- NULL = campaign-level entry
  author_email TEXT NOT NULL,
  title TEXT,
  body TEXT NOT NULL,
  session_date TEXT,                    -- in-world or real session date, freeform ISO string
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_journal_campaign ON journal_entries (campaign_id);
CREATE INDEX IF NOT EXISTS idx_journal_character ON journal_entries (character_id);

-- Full-text search over the journal. External-content FTS5, so the index holds
-- no copy of the text and journal_entries stays the single source; the triggers
-- are what keep it current, because an external-content table does not notice
-- writes on its own.
CREATE VIRTUAL TABLE IF NOT EXISTS journal_fts USING fts5(
  title, body,
  content='journal_entries', content_rowid='id',
  tokenize='porter unicode61'
);

CREATE TRIGGER IF NOT EXISTS journal_fts_ai AFTER INSERT ON journal_entries BEGIN
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;
-- 'delete' carries the OLD values because the index has no copy to look up.
CREATE TRIGGER IF NOT EXISTS journal_fts_ad AFTER DELETE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
END;
CREATE TRIGGER IF NOT EXISTS journal_fts_au AFTER UPDATE ON journal_entries BEGIN
  INSERT INTO journal_fts(journal_fts, rowid, title, body)
  VALUES ('delete', old.id, old.title, old.body);
  INSERT INTO journal_fts(rowid, title, body) VALUES (new.id, new.title, new.body);
END;

-- The party stash: character_items' shape, owned by a campaign. Soft-deleted
-- via removed_at, and tied to the journal entry explaining how it was acquired.
CREATE TABLE IF NOT EXISTS campaign_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear(slug),            -- NULL = freeform custom item, and the
                                                   -- only key; see migrations 044-046
  custom_name TEXT,                                 -- required for freeform items
  qty INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_by TEXT NOT NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                  -- NULL = still in the stash
  removed_by TEXT,
  claimed_by_character_id INTEGER REFERENCES characters(id) ON DELETE SET NULL,
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_campaign_items_campaign ON campaign_items (campaign_id);

-- Party currency as a ledger, not a number: the balance is SUM(delta), so no
-- stored total can disagree with its own history. Rows are appended, never
-- updated. `currency` is free text because the two systems use different coin.
CREATE TABLE IF NOT EXISTS campaign_currency (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  currency TEXT NOT NULL,
  delta INTEGER NOT NULL,                           -- signed; positive is income
  reason TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_campaign_currency_campaign
  ON campaign_currency (campaign_id, currency);

-- NPC dossiers, campaign-scoped. An NPC belongs to one table's game; a shared
-- dossier would leak what one group knows into another's.
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
-- One dossier per name per campaign: what makes @Kevik resolve to a person
-- rather than to three near-identical rows nobody merges.
CREATE UNIQUE INDEX IF NOT EXISTS idx_npcs_campaign_name
  ON npcs (campaign_id, name COLLATE NOCASE);

-- Which entries mention whom, and who said so: `source` distinguishes a link a
-- person typed from one the sweep inferred.
CREATE TABLE IF NOT EXISTS npc_mentions (
  npc_id INTEGER NOT NULL REFERENCES npcs(id) ON DELETE CASCADE,
  journal_entry_id INTEGER NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  source TEXT NOT NULL CHECK (source IN ('mention', 'ai')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (npc_id, journal_entry_id)
);
CREATE INDEX IF NOT EXISTS idx_npc_mentions_entry ON npc_mentions (journal_entry_id);

-- What the sweep has already read, and the names a human said are not people.
CREATE TABLE IF NOT EXISTS npc_sweeps (
  journal_entry_id INTEGER PRIMARY KEY REFERENCES journal_entries(id) ON DELETE CASCADE,
  swept_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE TABLE IF NOT EXISTS npc_proposals_dismissed (
  campaign_id INTEGER NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  dismissed_by TEXT NOT NULL,
  dismissed_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (campaign_id, name COLLATE NOCASE)
);

CREATE TABLE IF NOT EXISTS level_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  from_level INTEGER NOT NULL,
  to_level INTEGER NOT NULL,
  xp_at_levelup INTEGER,
  changes TEXT NOT NULL DEFAULT '{}',   -- JSON diff of what the level-up actually applied
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_level_history_character ON level_history (character_id);

-- Skill picks a level-up granted but the player has not spent yet. One row per
-- GRANT rather than per pick, so "2 picks from Physical or Rogue, earned at
-- level 3" stays itemised. `categories` is copied from the class at the moment
-- of the level-up — the class can change later, what you were granted cannot.
CREATE TABLE IF NOT EXISTS pending_skill_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  categories TEXT,                       -- JSON array; NULL = no category restriction
  kind TEXT,                             -- 'related' | 'secondary'; NULL means related
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT                       -- NULL = still unspent
);
CREATE INDEX IF NOT EXISTS idx_pending_picks_character
  ON pending_skill_picks (character_id, claimed_at);

-- Spells and psionic powers a level-up granted and nobody has chosen yet.
-- pending_skill_picks with a different subject, and for the same reason:
-- levelling up is never blocked on choosing, so an unspent grant has to go
-- somewhere or the spells that level earned are silently lost.
CREATE TABLE IF NOT EXISTS pending_power_picks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  granted_at_level INTEGER NOT NULL,
  count INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('spell', 'psionic')),
  -- JSON array of SPELL levels this grant may draw from; NULL is unrestricted,
  -- and always NULL for a psionic grant. Copied from the class at grant time,
  -- as pending_skill_picks copies its categories.
  spell_levels TEXT,
  -- JSON array of psionic CATEGORIES this grant may draw from; NULL is
  -- unrestricted, and always NULL for a spell grant. A grant's categories
  -- REPLACE the class's: the Mystic's level-4 power comes from Super, which a
  -- major psychic could not otherwise take.
  categories TEXT,
  -- Several grants can share a level with different restrictions: the Shifter
  -- gains two spells from its named list and one of any kind each level. `slot`
  -- is what tells them apart, and everything that keys a grant keys on level
  -- AND slot.
  slot INTEGER NOT NULL DEFAULT 0,
  from_names TEXT,                        -- JSON array; a grant drawn from a named list
  -- A restriction the catalog CANNOT enforce, shown to the player instead.
  -- Spells carry no tag, so "non-dimension related or control based" has
  -- nothing to filter on; stating it beats dropping it or guessing at it.
  note TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  claimed_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_pending_power_picks_character
  ON pending_power_picks (character_id, claimed_at);

-- Things a table hands out that no class schedule granted: a patron teaches a
-- skill, an artefact confers a power, an implant adds S.D.C. The G.M. usually
-- says so out loud mid-session, so the PLAYER types it in on their own sheet.
-- That is why this is not a G.M.-only table, and why `reason` is NOT NULL with
-- no default: the person entering a grant is usually its beneficiary, and the
-- reason is the only thing between a record and an unfalsifiable claim.
--
-- All eight kinds are in the CHECK though only 'skill' is implemented, because
-- SQLite cannot alter one -- adding a kind later would mean the table rebuild
-- 036 had to do. Removal is a hard DELETE, logged to play_events: a grant is
-- current state, and a withdrawn ruling is not a stash item that left the
-- party. See apps/character-creator/docs/plans/19-gm-grants.md. Migration 043.
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
-- Shared gear catalog for character sheets. Named `gear` rather than `items`
-- because this database is shared with MediaVault's `media_items`, and a table
-- called `items` sitting next to it was the most likely future collision.
CREATE TABLE IF NOT EXISTS gear (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,            -- matches equipment_starting item_id refs in class markdown,
                                        -- and since migration 046 the only key inventory
                                        -- holds. NOT NULL since 047: UNIQUE alone permits
                                        -- any number of NULLs, and a slugless gear row
                                        -- would join to nothing.
  name TEXT NOT NULL,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'both')),
  category TEXT,                        -- weapon | armor | vehicle | cybernetics | gear
  weight_lbs REAL,
  cost INTEGER,                         -- credits (rifts) or gold (palladium-fantasy).
                                        -- A range's LOW end, the way spells.ppe holds a
                                        -- variable cost's minimum; see cost_note.
  cost_note TEXT,                       -- a range or qualifier the integer cannot hold:
                                        -- "20-100 cr.", "double for gold". Migration 032.
  -- Stat block. TEXT where books write prose as often as figures
  -- ("2D6 M.D. single shot, 6D6 M.D. burst"); ar and mdc are numbers because
  -- the sheet's armour block uses them as such. is_mega_damage is structured
  -- because S.D.C. versus M.D.C. is the distinction that matters most in Rifts
  -- and reading it back out of a damage string is error-prone.
  damage TEXT,
  is_mega_damage INTEGER NOT NULL DEFAULT 0,
  range TEXT,
  payload TEXT,
  rate_of_fire TEXT,
  ar INTEGER,
  sdc INTEGER,                          -- Structural Damage Capacity: how much the OBJECT
                                        -- takes before it breaks. The other half of what
                                        -- Palladium armour is, and spent by the rules that
                                        -- follow the table - at half S.D.C. the A.R. drops
                                        -- two points. Never the "1D6 S.D.C." a knife DEALS,
                                        -- which is damage. Migration 034.
  mdc INTEGER,
  description TEXT,
  source_book TEXT
);

-- What an alchemist puts INTO an object, as opposed to the object. THREE
-- families, and the book draws every one of them the same way - a property
-- with a price and a cap, instilled into ordinary gear:
--
--   armor   11 features, printed 249, four to a suit
--   weapon  21 properties, printed 249-250, three to a weapon
--   charm   30 powers, printed 253, three to a ring, bracelet or medallion
--
-- "+1 A.R., 4,000 gold" is a modifier on any of the armour rows the catalog
-- already has, not a row of its own. Nor is "Chameleon, 40,000 gold" a ring:
-- the book says the effect is PLACED IN one, three powers to an item.
CREATE TABLE IF NOT EXISTS enchantments (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  slug         TEXT UNIQUE,
  name         TEXT NOT NULL,
  applies_to   TEXT NOT NULL CHECK (applies_to IN ('weapon', 'armor', 'charm')),
  cost         INTEGER,                -- gold, the LOW end; see cost_note
  cost_note    TEXT,                   -- a range, a per-unit rate, or a cap
  max_per_item INTEGER,                -- 4 for armour, 3 for weapons
  limits       TEXT,                   -- "blunt weapons only, excluding ball & chain"
  bonuses      TEXT,                   -- the same JSON shape skills.bonuses uses
  description  TEXT,
  system       TEXT,
  source_book  TEXT
);

CREATE TABLE IF NOT EXISTS character_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  gear_slug TEXT REFERENCES gear(slug),              -- NULL = freeform custom item.
                                                     -- The PORTABLE key, and since
                                                     -- migration 046 the ONLY one: a gear
                                                     -- id is insertion order and means
                                                     -- nothing in another database, where
                                                     -- a slug means the same thing
                                                     -- everywhere. RETRO-AUDIT R21.
  custom_name TEXT,                                   -- required for freeform items
  qty INTEGER NOT NULL DEFAULT 1,
  equipped INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  enchantments TEXT,                                  -- JSON array of enchantment slugs. On the
                                                      -- INSTANCE: one long sword in a party of four
                                                      -- can be the Demon Slayer, the rest ordinary.
                                                      -- Migration 035.
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,  -- ties acquisition/loss to a session
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                    -- NULL = currently in inventory
  CHECK (gear_slug IS NOT NULL OR custom_name IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_character_items_character ON character_items (character_id);

-- Classes created by the PDF import tool, and the ONLY source of class
-- definitions. A row goes live immediately, without a redeploy. (Committed
-- markdown under apps/character-creator/data/classes used to win on an id
-- collision; that design is gone — see _lib/class-store.js.)
-- A row is saved as 'draft' the moment extraction succeeds (so a closed tab
-- never loses the work) and flips to 'published' when the import is confirmed.
CREATE TABLE IF NOT EXISTS imported_classes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  class_id TEXT NOT NULL UNIQUE,        -- kebab-case slug from the frontmatter
  name TEXT,
  system TEXT,
  markdown TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  created_by TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  -- NULL = live, timestamp = retired. Characters built on a retired class keep
  -- working; only the pickers and the published list filter on it.
  deleted_at TEXT
);
CREATE INDEX IF NOT EXISTS idx_imported_classes_status ON imported_classes (status);
CREATE INDEX IF NOT EXISTS idx_imported_classes_deleted ON imported_classes (deleted_at);

-- Reference catalogs. These began as static JSON shipped with the deploy, which
-- meant a commit and a redeploy to add a single skill. They live here so the
-- import tool can create missing entries live, the same way it does for items.
-- `name` is unique: the same skill imported from a second book with different
-- numbers is stored under a distinguished name (e.g. "Climbing (Rifts UE)"),
-- decided during import review rather than silently merged or duplicated.
CREATE TABLE IF NOT EXISTS skills (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,
  base INTEGER NOT NULL DEFAULT 0,        -- 0 = non-percentile (W.P.s, hand to hand)
  -- An attribute-derived starting percentage: "PP*5" for a skill a book states
  -- as the P.P. attribute number times five. Consulted only when set, so `base`
  -- above keeps its meaning and stays the fallback; see migration 042.
  base_formula TEXT,
  per_level INTEGER NOT NULL DEFAULT 0,
  systems TEXT,                           -- JSON array; NULL means both systems
  source TEXT NOT NULL DEFAULT 'seed',    -- seed | import
  source_book TEXT,
  note TEXT,                              -- "40%/30% climb/rappel", "counts as two skills"
  bonuses TEXT,                           -- JSON, the class `bonuses:` shape; see migration 023
  -- JSON array of per-level grants, summed up to the character's level.
  -- Hand to Hand tables are level-by-level and accumulative; see migration 025.
  level_bonuses TEXT
);

CREATE TABLE IF NOT EXISTS spells (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  level INTEGER NOT NULL DEFAULT 0,
  ppe INTEGER NOT NULL DEFAULT 0,
  ppe_note TEXT,                          -- a variable cost's schedule in a few words.
                                          -- `ppe` holds the MINIMUM, which is what the
                                          -- sheet's use button spends; see migration 021.
  variant_note TEXT,                      -- what an OLDER book prints instead. The later
                                          -- book wins (RUE > Book of Magic > Palladium
                                          -- Fantasy); the losing number is kept, not
                                          -- discarded. NOT ppe_note: the wizard treats
                                          -- that column's presence as "this cost varies".
                                          -- See migration 033.
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- rifts | palladium-fantasy | both; NULL = unrestricted
  -- Stat block. TEXT rather than numbers because book values are prose as often
  -- as figures: "100 feet per level of experience", "2D6 melee rounds".
  range TEXT,
  duration TEXT,
  damage TEXT,
  saving_throw TEXT,
  area_of_effect TEXT,
  casting_time TEXT,
  description TEXT
);

CREATE TABLE IF NOT EXISTS psionic_powers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT,                          -- Healing | Physical | Sensitive | Super
  isp INTEGER NOT NULL DEFAULT 0,
  isp_note TEXT,                          -- a variable cost's schedule in a few words.
                                          -- `isp` holds the MINIMUM, which is what the
                                          -- sheet's use button spends; see migration 020.
  variant_note TEXT,                      -- what an OLDER book prints instead. The later
                                          -- book wins; the losing number is kept, not
                                          -- discarded. NOT isp_note: the wizard treats
                                          -- that column's presence as "this cost varies".
                                          -- See migration 033.
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- rifts | palladium-fantasy | both; NULL = unrestricted
  -- Field names match spells on purpose, so the sheet renders both the same way.
  range TEXT,
  duration TEXT,
  saving_throw TEXT,
  description TEXT,
  -- minor | major | master. NULL = no restriction beyond the power's category,
  -- which is today's behaviour. Books state tier at the category level far more
  -- often than per power, so most rows legitimately have none. Nothing enforces
  -- this yet — that needs real imported data behind it first.
  min_tier TEXT
);

-- ═══════════════════════════════════════════════════════════════════
-- Migration seeding. The CREATEs above already contain the columns that
-- db/migrations/*.sql add, so a database built from this file is current
-- the moment it exists and should say so.
--
-- But on an EXISTING database every CREATE above is skipped, so this file
-- alone cannot bring old tables up to date — that is what the migrations
-- are for. An unconditional insert here would therefore mark an old,
-- un-migrated database as migrated, which is precisely the lie this table
-- exists to prevent.
--
-- So each row is guarded by the schema feature its migration adds. The
-- record is derived from what the database actually looks like, never
-- assumed. Add a guarded line here whenever you add a migration.
-- ═══════════════════════════════════════════════════════════════════
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '001-character-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'bio');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '002-catalog-provenance.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('skills') WHERE name = 'note');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '003-class-soft-delete.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('imported_classes') WHERE name = 'deleted_at');

-- ═══════════════════════════════════════════════════════════════════
-- Resumable catalog imports. A spell chapter is hundreds of entries across
-- many pages, so extracted rows are staged here rather than living in a
-- browser tab. Catalog-agnostic on purpose — psionics and gear reuse them.
-- ═══════════════════════════════════════════════════════════════════
-- A rename needs both halves checked. The CREATE above makes an empty `gear`
-- on a database that still has a populated `items`, so "gear exists" alone
-- would record this migration on a database that has not actually had it.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '004-items-to-gear.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'gear')
  AND NOT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'items');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '005-spell-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'saving_throw');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '041-drop-import-staging.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'imported_classes')
  AND NOT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'import_staged');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '042-skill-base-formula.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('skills') WHERE name = 'base_formula');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '006-import-sessions.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'imported_classes')
  AND NOT EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'import_staged');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '007-psionic-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('psionic_powers') WHERE name = 'min_tier');

-- Both halves again: 008 adds columns AND drops `stats`, so a database that has
-- the new columns but still has the blob has not finished the migration.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '008-gear-detail.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('gear') WHERE name = 'ar')
  AND NOT EXISTS (SELECT 1 FROM pragma_table_info('gear') WHERE name = 'stats');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '009-pending-skill-picks.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'pending_skill_picks');

-- ═══════════════════════════════════════════════════════════════════
-- Forwarding pointers for retired catalog keys. A merge deletes one of two
-- rows and repoints the characters that held it, but class markdown cites
-- gear by slug and skills by name, and a merge never rewrites markdown. This
-- remembers where the key went so those citations still resolve.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS catalog_redirects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  catalog TEXT NOT NULL,                          -- skills | spells | psionics | gear
  from_key TEXT NOT NULL COLLATE NOCASE,          -- the retired slug or name
  to_id INTEGER NOT NULL,                         -- row in that catalog's table
  reason TEXT NOT NULL DEFAULT 'merge',           -- merge | rename
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (catalog, from_key)
);
CREATE INDEX IF NOT EXISTS idx_catalog_redirects_target ON catalog_redirects (catalog, to_id);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '010-catalog-redirects.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'catalog_redirects');

-- Guarded on the column the migration adds, on BOTH tables, because 044 alters
-- both and a database with one of them is not migrated.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '044-inventory-gear-slug.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('character_items') WHERE name = 'gear_slug')
  AND EXISTS (SELECT 1 FROM pragma_table_info('campaign_items') WHERE name = 'gear_slug');

-- 045 only MOVES the CHECK, so its guard has to read the constraint itself -
-- pragma_table_info cannot see a CHECK, and no column appears or disappears.
-- sqlite_master's stored CREATE text is the only place it shows. True after 046
-- as well, which is right: a fresh database built from this file has both.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '045-inventory-check-on-slug.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'character_items'
                AND sql LIKE '%CHECK (gear_slug IS NOT NULL%')
  AND EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'campaign_items'
                AND sql LIKE '%CHECK (gear_slug IS NOT NULL%');

-- 046 DROPS `item_id` from both tables, so its guard checks BOTH HALVES the way
-- 004's rename does: the new column present AND the old one gone. Testing only
-- for the absence would mark a database that never had the column as migrated,
-- and testing only for the presence would mark 044 as 045.
-- 047 adds a constraint rather than a column, and `notnull` is the one schema
-- feature pragma_table_info DOES expose - so unlike 045's guard this needs no
-- sqlite_master text match.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '047-gear-slug-not-null.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('gear')
               WHERE name = 'slug' AND "notnull" = 1);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '046-drop-inventory-item-id.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('character_items') WHERE name = 'gear_slug')
  AND NOT EXISTS (SELECT 1 FROM pragma_table_info('character_items') WHERE name = 'item_id')
  AND EXISTS (SELECT 1 FROM pragma_table_info('campaign_items') WHERE name = 'gear_slug')
  AND NOT EXISTS (SELECT 1 FROM pragma_table_info('campaign_items') WHERE name = 'item_id');

-- ═══════════════════════════════════════════════════════════════════
-- Play mode's event log. Commentary, not a ledger: the character row stays
-- the source of truth and nothing replays events to derive state. Buys undo
-- (payload carries from/to), a who-did-what trail, and the session recap.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS play_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  actor_email TEXT NOT NULL,
  kind TEXT NOT NULL,                   -- damage | pool | power | ammo | roll | recap
  payload TEXT NOT NULL,                -- JSON: note, and changes {from, to} for undo
  undone_at TEXT,                       -- NULL = stands
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_play_events_character ON play_events (character_id, id);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '020-psionic-isp-note.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('psionic_powers') WHERE name = 'isp_note');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '021-spell-ppe-note.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'ppe_note');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '022-play-events.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'play_events');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '023-skill-bonuses.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('skills') WHERE name = 'bonuses');

-- ═══════════════════════════════════════════════════════════════════
-- Bookkeeping for apps/character-creator/db/*.sql, which change ROWS
-- rather than schema and are therefore NOT migrations. One row per RUN
-- rather than per file: those scripts guard every statement, so one is
-- safe to run twice and safe to run early, and an applied-once flag
-- would record a deliberate no-op run as done. See migration 024.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS data_script_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  filename TEXT NOT NULL,               -- basename only, e.g. 'fix-juicer.sql'
  note TEXT,                            -- NULL = an ordinary observed run
  run_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_data_script_runs_file ON data_script_runs (filename, run_at);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '024-data-script-runs.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'data_script_runs');

-- ═══════════════════════════════════════════════════════════════════
-- An in-progress character build. Its own table rather than a `draft` status
-- on `characters`: a half-built character has no name, no campaign and
-- possibly no attributes, and putting one in `characters` would make every
-- list, the dashboard, the audit and the validator filter it out forever to
-- serve a state that lasts minutes. UNIQUE(owner_email) is what enforces one
-- draft at a time — saving is an upsert.
-- ═══════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS character_drafts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  owner_email TEXT NOT NULL UNIQUE,
  system TEXT,
  class_id TEXT,
  class_name TEXT,
  char_name TEXT,
  step INTEGER NOT NULL DEFAULT 0,
  state TEXT NOT NULL,                            -- JSON: the wizard's build state
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '011-character-drafts.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'character_drafts');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '014-character-occ.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'occ_class_id');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '015-character-psychic-tier.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'psychic_tier');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '016-character-attribute-bonuses.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'attribute_bonuses');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '017-pick-kind.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('pending_skill_picks') WHERE name = 'kind');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '018-character-abilities.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'abilities');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '019-character-rolled-bonuses.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'rolled_bonuses');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '013-character-variant.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'class_variant');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '012-catalog-system.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'system')
  AND EXISTS (SELECT 1 FROM pragma_table_info('psionic_powers') WHERE name = 'system');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '025-skill-level-bonuses.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('skills') WHERE name = 'level_bonuses');

-- Both halves: 026 adds the search index AND the two campaign-owned tables, so
-- a database with the tables but no index has not finished the migration.
INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '026-campaign-notes.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'campaign_items')
  AND EXISTS (SELECT 1 FROM sqlite_master WHERE name = 'journal_fts');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '027-npc-dossiers.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'npcs');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '028-pending-power-picks.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'pending_power_picks');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '029-power-pick-categories.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('pending_power_picks') WHERE name = 'categories');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '030-power-pick-slots.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('pending_power_picks') WHERE name = 'slot');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '031-character-mos.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('characters') WHERE name = 'mos');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '032-gear-cost-note.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('gear') WHERE name = 'cost_note');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '033-variant-note.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('spells') WHERE name = 'variant_note');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '034-gear-sdc.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('gear') WHERE name = 'sdc');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '035-enchantments.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('character_items') WHERE name = 'enchantments');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '036-enchantments-charm.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master
               WHERE type = 'table' AND name = 'enchantments' AND sql LIKE '%charm%');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '037-campaign-open.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('campaigns') WHERE name = 'open');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '038-claude-usage.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'claude_usage');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '039-filament-forge.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'ff_config');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '040-media-vault-source-id.sql'
WHERE EXISTS (SELECT 1 FROM pragma_table_info('media_items') WHERE name = 'source_id');

INSERT OR IGNORE INTO schema_migrations (filename)
SELECT '043-character-grants.sql'
WHERE EXISTS (SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'character_grants');
