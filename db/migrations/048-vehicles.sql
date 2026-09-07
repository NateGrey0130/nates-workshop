-- Vessels: power armour, robots, drones, borg models, combat vehicles and
-- ships, which the `gear` table has never been able to hold.
--
-- BOOK-INGEST-AUDIT.md F3 named this in full on 2026-08-28 and CLOSED it on
-- 2026-09-03 (PR #616) as the third of three options: keep dropping vessels,
-- and say so in docs/known-limitations.md. That closure was explicit that the
-- other two options - this table, and a JSON `systems` column on `gear` - were
-- declined because "nothing has asked", and equally explicit about the trigger
-- for revisiting: "Reopen it the moment something asks."
--
-- Something asked, on 2026-09-07. This is F3's FIRST option, built as it was
-- described. F3 carries a dated reopening note recording that; the 2026-09-03
-- closure stands as the record it is, because an audit file is a record and a
-- measurement is not rewritten.
--
-- WHY THREE TABLES AND NOT ONE. A vessel stat block is not a row. It carries
-- M.D.C. BY LOCATION - main body, arms, legs, turrets, sensors, each with its
-- own number and its own destruction rule - and a NUMBERED LIST of weapon
-- systems, each with its own damage, rate of fire, range and payload. Folding
-- either into one column is what F3 refused: "storing one of these as a gear
-- row means picking one weapon system out of eight and dropping the rest, which
-- is worse than not storing it: the row would read as complete." A JSON column
-- was the cheaper alternative and F3 declined it too, on the grounds that a
-- JSON column nothing reads is the silent-storage failure class-import warns
-- about. So the locations and the weapon systems each get real rows.
--
-- WHAT THIS DOES NOT DO. It does not touch `gear`. The 36 existing rows with
-- category = 'vehicle' stay exactly where they are, per-location breakdowns and
-- all, and nothing here migrates them - F3's closure calls those 24 prose rows
-- "the backfill a future vehicles table would start from", and backfilling them
-- is a separate job with its own decisions. Nothing in the app reads these
-- tables yet either. This is the shape; the data and the reader come after.

CREATE TABLE IF NOT EXISTS vehicles (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  slug          TEXT NOT NULL UNIQUE,   -- the portable key, as gear.slug is
  name          TEXT NOT NULL,
  system        TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'both')),
  vehicle_class TEXT,                   -- power-armor | robot | drone | borg |
                                        -- vehicle | ship | other. Free text on
                                        -- purpose: books invent categories and
                                        -- a CHECK here would reject a book
                                        -- rather than record it.
  crew          TEXT,                   -- "one" / "two plus four passengers" -
                                        -- prose as often as a number
  passengers    TEXT,
  speed_ground  TEXT,                   -- three regimes, each printed its own
  speed_air     TEXT,                   -- way; TEXT because a book writes
  speed_water   TEXT,                   -- "Mach 1.2" and "80 mph" and "1 light
                                        -- year per hour" in the same block
  dimensions    TEXT,                   -- height, width, length as printed
  weight_tons   TEXT,
  mdc_main_body INTEGER,                -- the main body only. Everything else
                                        -- is a vehicle_locations row, and a
                                        -- reader that wants the total must sum
                                        -- them rather than trust this column.
  cost          INTEGER,                -- credits; a range's LOW end, as
                                        -- gear.cost is. See cost_note.
  cost_note     TEXT,
  description   TEXT,
  source_book   TEXT
);

-- M.D.C. by location. One row per named part, which is the whole reason this
-- table exists: a vessel with a dozen destructible parts is a dozen rows here
-- and a single unusable integer in `gear`.
CREATE TABLE IF NOT EXISTS vehicle_locations (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_slug TEXT NOT NULL REFERENCES vehicles(slug) ON DELETE CASCADE,
  location     TEXT NOT NULL,           -- "Main Body", "Arms (2)", "Head/Helmet"
  mdc          INTEGER,                 -- NULL where a book prints a formula
  mdc_note     TEXT,                    -- the formula, or "destroying this
                                        -- disables the jets"
  ordinal      INTEGER,                 -- printed order, so a reader can render
                                        -- the block the way the book sets it
  UNIQUE (vehicle_slug, location)
);

-- The numbered weapon systems. A vessel carries five to eight of these and
-- `gear` has one of each column, which is the other half of what F3 named.
CREATE TABLE IF NOT EXISTS vehicle_weapons (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_slug   TEXT NOT NULL REFERENCES vehicles(slug) ON DELETE CASCADE,
  ordinal        INTEGER,               -- the book's own numbering
  name           TEXT NOT NULL,
  damage         TEXT,                  -- prose as often as dice, as gear.damage is
  is_mega_damage INTEGER NOT NULL DEFAULT 0,
  range          TEXT,
  rate_of_fire   TEXT,
  payload        TEXT,
  bonus          TEXT,                  -- "+2 to strike", where one is printed
  note           TEXT,
  UNIQUE (vehicle_slug, ordinal, name)
);

CREATE INDEX IF NOT EXISTS idx_vehicle_locations_slug ON vehicle_locations(vehicle_slug);
CREATE INDEX IF NOT EXISTS idx_vehicle_weapons_slug ON vehicle_weapons(vehicle_slug);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('048-vehicles.sql');
