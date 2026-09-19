-- creatures: the species the books stat - a Feathered Death, a Grimbor, a
-- Kraken Worm - one row each, as a catalog a G.M. rolls into a campaign.
--
-- Phase 3 of the NPC / bestiary work, decided with Nate on 2026-09-17: two
-- tables, `creatures` beside `notable_npcs` (migration 072), not one. A named
-- individual prints FIXED numbers for one person; a species prints DICE for a
-- kind of creature - "I.Q. 2D6, P.S. 4D6", "Hit Points: P.E. +20", "S.D.C.:
-- P.E. x10". So this row stores formulas, and placing one ROLLS them.
--
-- Filed here by the same mechanical rule 072 states from the other side: a
-- stat block WITHOUT a Real / True / Greek Name line or a numeric experience
-- level is a creature.
--
-- A G.M. places creatures in a campaign through campaigns/:id/npcs/from-creature,
-- which rolls this row into one or more `characters` rows with kind = 'npc'
-- (migration 070) and class_id `creature:<slug>`. One-way, as 072's copies are.
--
-- FORMULAS, in one grammar (js/creature-roll.js), so a formula is either
-- rollable or refused - never guessed. The grammar is a sum of terms: dice
-- (2D6, 1D4x10), a whole number, or an attribute (PE, P.E. x 10). `attributes`
-- is JSON of the eight sheet keys to such formulas, or "N/A" for an attribute
-- the species does not have (dice.js's rule, BOOK-INGEST-AUDIT.md F5); a key
-- the book does not print is absent. hp / sdc / mdc / ppe / isp are formulas
-- too, and may name an attribute, which is rolled first. `pools_note` keeps any
-- printed wording a formula simplified ("equivalent to 1 or 2 M.D.C.").
-- The book's fixed numbers stay integers: `ar`, `horror_factor`, and `combat`
-- (JSON of the sheet's combat keys, as 072 has them).
--
-- `playable` is 1 when the book offers the species as an optional player race
-- ("Optional NPC Monster or Player Character"). It is a catalog fact, not a
-- class: a playable species is not in imported_classes until someone imports
-- it as an R.C.C. through the class pipeline.
--
-- PROSE as 072 has it: natural abilities, magic and psionics as the book lists
-- them; `skills_note` for its R.C.C. skills; `description` a SHORT factual
-- paraphrase citing the printed page - never the book's own sentences.
-- Attacks are `stat_attacks` rows with owner_kind = 'creature' (migration 073).
--
-- system: the same five values gear, vehicles and 072 admit (migrations 058-060).
CREATE TABLE IF NOT EXISTS creatures (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  slug TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category TEXT,
  system TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both')),
  playable INTEGER NOT NULL DEFAULT 0,
  alignment TEXT,
  attributes TEXT,
  hp TEXT,
  sdc TEXT,
  mdc TEXT,
  ppe TEXT,
  isp TEXT,
  pools_note TEXT,
  ar INTEGER,
  horror_factor INTEGER,
  combat TEXT,
  bonuses_note TEXT,
  skills_note TEXT,
  natural_abilities TEXT,
  magic TEXT,
  psionics TEXT,
  size TEXT,
  weight TEXT,
  life_span TEXT,
  habitat TEXT,
  allies TEXT,
  enemies TEXT,
  occ_note TEXT,
  description TEXT,
  source_book TEXT
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('074-creatures.sql');
