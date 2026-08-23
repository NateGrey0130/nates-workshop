-- A third family: what goes into a ring, and it is not a ring.
--
-- 035 shipped `applies_to` with CHECK (applies_to IN ('weapon', 'armor')),
-- taken from the two halves printed 249-250. Printed 253 has a third, and
-- reading it settles what it is:
--
--   "The following magic effects can be PLACED IN rings, bracelets, charms,
--    and medallions. They cannot be instilled in weapons."
--   "A maximum of three different powers can be placed in any one enchanted
--    item, but most have only one or two."
--
-- That is the same shape as the armour features and the weapon properties -
-- a property with a price and a cap, instilled into an ordinary object - and
-- not thirty finished items. Importing "Ring of Chameleon" as gear would invent
-- a name the book never prints, and would have no way to say that one ring can
-- carry three of these at once.
--
-- SQLite cannot alter a CHECK, so the table is rebuilt: the documented
-- twelve-step, minus the steps this table does not need (no indexes, no
-- triggers, no views, and nothing references it by foreign key -
-- character_items stores slugs in JSON, not ids).
--
-- The copy is by NAMED columns rather than SELECT *, so a column added later
-- fails loudly here instead of silently shifting values one to the left.

PRAGMA foreign_keys = OFF;

CREATE TABLE enchantments_new (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  slug         TEXT UNIQUE,
  name         TEXT NOT NULL,
  applies_to   TEXT NOT NULL CHECK (applies_to IN ('weapon', 'armor', 'charm')),
  cost         INTEGER,
  cost_note    TEXT,
  max_per_item INTEGER,
  limits       TEXT,
  bonuses      TEXT,
  description  TEXT,
  system       TEXT,
  source_book  TEXT
);

INSERT INTO enchantments_new
  (id, slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses,
   description, system, source_book)
SELECT
   id, slug, name, applies_to, cost, cost_note, max_per_item, limits, bonuses,
   description, system, source_book
  FROM enchantments;

DROP TABLE enchantments;

ALTER TABLE enchantments_new RENAME TO enchantments;

PRAGMA foreign_keys = ON;

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('036-enchantments-charm.sql');
