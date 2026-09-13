-- Super abilities: the fifth kind of power this catalog stores, after spells,
-- psionics, skills and enchantments.
--
-- Heroes Unlimited's super abilities are not spells and not psionics, and the
-- difference is structural rather than flavour. A spell has a level and a P.P.E.
-- cost. A psionic power has a category and an I.S.P. cost. A super ability has
-- NEITHER a cost nor a level: it is a permanent trait the character simply has,
-- and what it prints instead is a stat block - Range, Duration, Damage - that
-- describes the trait in use. Storing one in `spells` would demand a level it
-- does not have; storing one in `psionic_powers` would demand an I.S.P. cost it
-- does not have and put a non-psionic trait behind an I.S.P. gate on the sheet.
--
-- Decision D3 of the Heroes Unlimited batch, recorded in
-- apps/character-creator/docs/surveys/heroes-unlimited-core.md. The Revised core
-- defines 69 of these (31 minor, 38 major), Powers Unlimited One adds 170 and
-- Powers Unlimited Three adds 125 - so roughly 364 rows are waiting on this
-- table, and not one of them could be imported before it existed.
--
-- `tier` is minor | major, which is the ONLY division these have. It is
-- deliberately NOT a CHECK: BOOK-INGEST-AUDIT F73 spent a whole finding on the
-- fact that a CHECK-constrained column cannot be widened in SQLite without
-- rebuilding the table, and `gear.system` and `vehicles.system` are still
-- narrower than the rest of the catalog because of it. `psionic_powers.category`
-- is bare TEXT for the same reason and this mirrors it.
--
-- `system` is bare TEXT for that same reason, and because NULL already means
-- unrestricted everywhere else in this catalog.
--
-- NO `bonuses` COLUMN, though many of these abilities grant one. Nothing reads
-- it yet and no importer writes it, and a column that is always NULL reads as a
-- gap in the data rather than as a feature not yet built. Adding it later is a
-- column, which is five places and cheap; removing an unused one from a live
-- table is not.

CREATE TABLE IF NOT EXISTS super_abilities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  tier TEXT,                              -- minor | major; NULL = the book does not say
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- NULL = unrestricted, as everywhere else
  -- The stat block, named to match `spells` and `psionic_powers` on purpose, so
  -- the sheet renders all three the same way. TEXT because books write
  -- "100 feet per level of experience" as often as a number.
  range TEXT,
  duration TEXT,
  damage TEXT,
  saving_throw TEXT,
  description TEXT,
  -- What an EARLIER book prints instead, when two disagree. The later book wins
  -- and the losing reading is kept rather than discarded, as in psionic_powers.
  variant_note TEXT
);

CREATE INDEX IF NOT EXISTS idx_super_abilities_tier ON super_abilities (tier);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('057-super-abilities.sql');
