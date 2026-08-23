-- Enchantments: the thing an alchemist puts INTO a sword, not a sword.
--
-- Palladium Fantasy printed 249-250 sells three finished suits of magic armour
-- and then thirty-two PROPERTIES that go into ordinary gear - eleven for
-- armour, twenty-one for weapons - cumulatively, up to four per suit and three
-- per weapon, with the cost adding up as you go.
--
-- "Cloak of Armor, 20,000 gold" is a gear row. "+1 A.R., 4,000 gold" is not: it
-- is a modifier that can sit on any of the armour rows the catalog already has,
-- and modelling it as a row would mean inventing a separate catalog entry for
-- every combination of every feature with every suit.
--
-- TWO TABLES' WORTH OF DECISION, and the second half is the point:
--
--   enchantments               what an alchemist can do, once each, as a catalog
--   character_items.enchantments  which ones THIS sword has
--
-- The JSON array is on the INSTANCE. One long sword in a party of four can be
-- the Demon Slayer while the other three stay ordinary, which is the whole
-- reason this cannot be a flag on `gear`.
--
-- `bonuses` REUSES the block `skills.bonuses` already stores and
-- `validateBonuses()` already checks. That is not a convenience, it is why this
-- is affordable: "Invisible Weapon: +3 initiative, +2 strike and parry" is
-- {"combat":{"initiative":3,"strike":2,"parry":2}} and derive.js needs no new
-- cases, exactly as it needed none when skills learned to grant bonuses. The
-- group accepts a dice expression too, so the Thunder Hammer's extra 2D6 is
-- {"combat":{"damage":"2d6"}} rather than a number it is not.
--
-- `cost` holds the low end and `cost_note` the formula, the same division
-- gear.cost/cost_note and spells.ppe/ppe_note already use - and these prices
-- need it more than most: "2,000 gold per 20 S.D.C., up to a 200 maximum for
-- heavy armour and 100 for leather and chain" is an arithmetic rule, not a
-- number.
--
-- `limits` is separate from `description` because it is the part a picker has
-- to act on: the Thunder Hammer is blunt weapons only excluding ball & chain,
-- Eternally Sharp Blade is blades, Returns to Wielder is throwables, and
-- Invisibility on Armor is any armour but padded.
--
-- `max_per_item` is the book's cap for that half - 4 armour, 3 weapon - carried
-- on the row so a picker enforces it from the data rather than from a constant
-- somebody has to remember to keep in step.
--
-- NOT IMPORTED, and named here so that "we skipped them" reads as a decision:
-- rune and holy weapons are GENERATED from a tier and a table of powers rather
-- than listed, so importing them would invent about forty items the book does
-- not print; curses are effects applied to a person or object, with no price
-- and no weight, and are closer to a spell than to a sword.

CREATE TABLE IF NOT EXISTS enchantments (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  slug         TEXT UNIQUE,
  name         TEXT NOT NULL,
  applies_to   TEXT NOT NULL CHECK (applies_to IN ('weapon', 'armor')),
  cost         INTEGER,                -- gold, the LOW end; see cost_note
  cost_note    TEXT,                   -- a range, a per-unit rate, or a cap
  max_per_item INTEGER,                -- 4 for armour, 3 for weapons
  limits       TEXT,                   -- "blunt weapons only, excluding ball & chain"
  bonuses      TEXT,                   -- the same JSON shape skills.bonuses uses
  description  TEXT,
  system       TEXT,
  source_book  TEXT
);

ALTER TABLE character_items ADD COLUMN enchantments TEXT;   -- JSON array of slugs

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('035-enchantments.sql');
