-- The Morphus tables: the tenth catalog, and the first whose rows are the
-- ENTRIES of a percentile table rather than things a character picks by name.
--
-- Nightbane survey D5 (apps/character-creator/docs/surveys/nightbane-core.md),
-- DECIDED 2026-09-16 in #1133 on Nate's word: build the Morphus generator before
-- the Nightbane R.C.C., as separate PRs - this catalog, then the second body and
-- its Facade/Morphus sheet toggle, then the wizard's roll/pick generator. THIS
-- FILE IS ONLY THE TABLE. No row, no character column, nothing reads it yet; the
-- 154 entries follow as a data script.
--
-- ===================================================================
-- WHAT THE BOOK PRINTS, measured off the cache 2026-09-16 (D5)
-- ===================================================================
--
-- 19 tables and 154 entries on printed 91-106, every one "Roll or select". An
-- entry is a percentile band ("46-60% Lycanthrope"), and it does one of three
-- things: carries effects (118 of them), sends the roll on to another table,
-- or rolls the same table again two or three times. So one row per ENTRY, plus
-- one `intro` row per table for the preamble printed above its bands - which
-- is where rules like "ignore and reroll any result of 96-00" live.
--
-- TWO ROUTES GO NOWHERE. Animal Form 01-07 sends to a Bear Table and 08-14 to
-- an Amphibian Table, and neither is printed anywhere in the book. So
-- `routes[].table` is free text with no reference to `table_name`, and a route
-- naming a table with no rows is a fact the data records rather than a row this
-- schema refuses. Nate's answer (D5): a reroll in random mode, not offered in
-- pick mode.
--
-- ===================================================================
-- WHY A STORED `key`, rather than uniqueField over three columns
-- ===================================================================
--
-- A row is identified by (table_name, roll_low, name). `catalog-fields.js`
-- cannot say that: `uniqueField` is ONE column, and everything that reads it
-- reads it as one - the editor's clash check binds `values[cat.uniqueField]`,
-- a rename files `catalog_redirects.from_key` from it, and a duplicate
-- dismissal stores it. A composite would mean changing all three for one
-- catalog.
--
-- So the row carries `key` = '<table_name>: <name>', UNIQUE, and a CHECK ties
-- it to the two columns it is built from, so it cannot drift from them the
-- first time someone renames an entry in the editor. Stored and checked, not
-- trusted.
--
-- `key` IS STRICTER than the composite, and that was measured rather than
-- assumed: it forbids one table printing the same name at two bands. The
-- cache's 154 bands were read table by table on 2026-09-16 and no table
-- repeats a name. Names DO repeat ACROSS tables - "Combination of Two" is in
-- four, "Biomechanical" in three - which is why the key carries the table.
-- The composite UNIQUE is kept as well: it costs nothing the key does not
-- already imply, and its index is the (table_name, roll_low) lookup a roll
-- makes.
--
-- An intro row's `name` is the table's own printed heading ("Appearance
-- Table"), with 0/0 for its band.
--
-- ===================================================================
-- THE COLUMNS
-- ===================================================================
--
-- `kind` is free text, validated in the editor as a select with allowOther,
-- as `talents.tier` is: effect | route | combination | intro.
--
-- `bonuses` is a class-frontmatter `bonuses` block ({attributes, combat,
-- pools}), validated by the SAME js/parser.js validateBonuses the classes,
-- skills, enchantments and totems go through. D5 counted the effects as mostly
-- numbers a sheet can add - S.D.C. on ~75 entries, P.S./P.P./P.E. ~46/34/34,
-- speed, initiative, perception, extra attacks - and a second shape for them
-- would be a second thing the sheet has to learn.
--
-- HORROR FACTOR IS TWO COLUMNS, NOT A BONUS. ~108 entries ADD to it (base 6,
-- cap 18) and three SET it, and a set is not a sum; a `bonuses.saves` key would
-- also mean the save of the same name, which is the other Horror Factor
-- (BOOK-INGEST-AUDIT F75).
--
-- `horror_factor` IS TEXT, because what an entry adds is usually a ROLL: 73
-- entries add "1d4", "1d6", "1d4+1" or "1d4+2", and only a few a fixed number.
-- It holds a whole number or a dice expression, validated by the same
-- isDiceBonus (js/parser.js) a `bonuses` value goes through. A dice value is
-- rolled ONCE, when the Morphus is created, the way a class's dice attribute
-- bonuses are rolled into `characters.rolled_bonuses` - never re-rolled on a
-- render. `horror_factor_set` stays INTEGER: the book sets a fixed figure.
--
-- `routes` is JSON, [{"table": name, "count": n}], or NULL. `route_rule` is the
-- rule the book prints around it in words ("ignore and reroll 96-00").
-- `sub_choices` is JSON, a list of strings, for an entry that offers the player
-- options inside itself. Senses, size and ~29 restrictions stay prose in
-- `description` and `note`.
--
-- NO CHECK ON `table_name` or `system`. A later Nightbane book may print a
-- twentieth table, and `system` is free text on every other power catalog;
-- migration 063 gives the reason a CHECK there would re-create F73.

CREATE TABLE IF NOT EXISTS morphus_characteristics (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key TEXT NOT NULL UNIQUE,               -- '<table_name>: <name>'; see above
  table_name TEXT NOT NULL,               -- one of the 19 printed tables
  roll_low INTEGER NOT NULL,              -- 1-100, with 00 as 100; intro rows 0
  roll_high INTEGER NOT NULL,             -- 1-100; intro rows 0
  name TEXT NOT NULL,
  kind TEXT NOT NULL,                     -- effect | route | combination | intro
  routes TEXT,                            -- JSON [{"table": name, "count": n}]
  route_rule TEXT,
  bonuses TEXT,                           -- JSON, a class `bonuses` block
  horror_factor TEXT,                     -- ADDED: "2" or dice, "1d4+1"; rolled once
  horror_factor_set INTEGER,              -- SETS it instead; three entries do
  sub_choices TEXT,                       -- JSON list of strings
  description TEXT,
  note TEXT,
  source TEXT NOT NULL DEFAULT 'seed',
  source_book TEXT,
  system TEXT,                            -- NULL = unrestricted, as everywhere else
  UNIQUE (table_name, roll_low, name),
  CHECK (key = table_name || ': ' || name)
);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('068-morphus-characteristics.sql');
