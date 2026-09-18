-- notable_npcs: the named people the books stat - a mayor, a cult leader, a
-- Lord Magus, a super-villain - one row each, as a catalog a G.M. copies into
-- a campaign.
--
-- Phase 2 of the NPC / bestiary work, decided with Nate on 2026-09-17. A named
-- individual in a book is not a species (that is `creatures`, Phase 3) and not
-- a class: the book prints FIXED numbers for one person - an I.Q. of 14, 45 hit
-- points, Pilot Hovercraft at 88% - rather than dice for a kind of person. So
-- this row stores what was printed, structured where a sheet can use it and
-- prose where the book writes prose.
--
-- Filed here rather than in `creatures` by a MECHANICAL rule, so two readers
-- file the same block the same way: a stat block carrying a Real Name / True
-- Name / Greek Name line, or a numeric experience level, is a notable NPC.
--
-- A G.M. places one in a campaign through campaigns/:id/npcs/from-notable,
-- which copies this row into a `characters` row with kind = 'npc' (migration
-- 070). One-way: the catalog row is the book, the character is that table's
-- copy, and a fight or a level-up changes only the copy.
--
-- STRUCTURED, because a sheet reads them: `attributes` (JSON, the eight keys
-- the sheet uses), the pools, `combat` (JSON, the sheet's own combat keys -
-- attacks, strike, parry, dodge, ...), and `skills` (JSON list of
-- { name, pct }). Attacks are `stat_attacks` rows (migration 073), shared with
-- the creatures to come.
-- PROSE, by decision: magic, psionics, super powers and cybernetics as the
-- book lists them, not linked to the catalogs. Linking is a later choice.
-- `description` is a SHORT factual paraphrase citing the printed page, like
-- every other catalog here - never the book's own sentences.
--
-- system: the same five values gear and vehicles admit (migrations 058-060).
CREATE TABLE IF NOT EXISTS notable_npcs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  real_name TEXT,
  title TEXT,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both')),
  race TEXT,
  occ TEXT,
  level INTEGER,
  alignment TEXT,
  age TEXT,
  height TEXT,
  weight TEXT,
  attributes TEXT,
  hp INTEGER,
  sdc INTEGER,
  mdc INTEGER,
  ppe INTEGER,
  isp INTEGER,
  ar INTEGER,
  horror_factor INTEGER,
  combat TEXT,
  bonuses_note TEXT,
  skills TEXT,
  skills_note TEXT,
  natural_abilities TEXT,
  magic TEXT,
  psionics TEXT,
  super_powers TEXT,
  cybernetics TEXT,
  weapons_and_equipment TEXT,
  money TEXT,
  disposition TEXT,
  allies TEXT,
  enemies TEXT,
  description TEXT,
  source_book TEXT
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('072-notable-npcs.sql');
