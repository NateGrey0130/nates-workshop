-- Widen `vehicles.system` so rows from a THIRD and FOURTH game can be tagged.
--
-- BOOK-INGEST-AUDIT F73, the half left standing. F73 was taken once already in
-- PR #996, as its own Option C - catalog and classes only, the CHECK left alone
-- because that was the recorded decision for the Nightbane batch. `parser.js`
-- has admitted `nightbane` and `heroes-unlimited` since; this is the table
-- catching up with the parser.
--
-- SQLite cannot alter a CHECK in place, so `vehicles` is rebuilt. The technique
-- is migration 047's, and the ORDER is what makes it legal with foreign keys
-- fully enforced the whole way through - no pragma is used, because D1 ignores
-- the ones that would help and one of them destroys data silently. See
-- `058-campaign-system-third-game.sql` for the probe that established that.
--
--   subtree rebuilt (4): vehicles, vehicle_locations, vehicle_weapons, character_vehicles
--
--   1. build a suffixed copy of every table, REFERENCES already pointing at the
--      other copies;
--   2. copy the rows, parents before children;
--   3. drop the originals, children before parents;
--   4. rename the copies back - SQLite rewrites the REFERENCES clauses to follow;
--   5. recreate the indexes and triggers, which went with their tables in 3.
--
-- NO BEHAVIOUR CHANGE FOR EITHER EXISTING SYSTEM. Nothing is dropped, no column
-- changes type, no default moves.

-- 1. the suffixed copies.

CREATE TABLE vehicles_w060 (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  slug          TEXT NOT NULL UNIQUE,   -- the portable key, as gear.slug is
  name          TEXT NOT NULL,
  system        TEXT CHECK (system IN ('rifts', 'palladium-fantasy', 'nightbane', 'heroes-unlimited', 'both')),
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

CREATE TABLE vehicle_weapons_w060 (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_slug   TEXT NOT NULL REFERENCES vehicles_w060(slug) ON DELETE CASCADE,
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

CREATE TABLE vehicle_locations_w060 (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_slug TEXT NOT NULL REFERENCES vehicles_w060(slug) ON DELETE CASCADE,
  location     TEXT NOT NULL,           -- "Main Body", "Arms (2)", "Head/Helmet"
  mdc          INTEGER,                 -- NULL where a book prints a formula
  mdc_note     TEXT,                    -- the formula, or "destroying this
                                        -- disables the jets"
  ordinal      INTEGER,                 -- printed order, so a reader can render
                                        -- the block the way the book sets it
  UNIQUE (vehicle_slug, location)
);

CREATE TABLE character_vehicles_w060 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  character_id INTEGER NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
  vehicle_slug TEXT REFERENCES vehicles_w060(slug),        -- NULL = freeform, custom_name required
  custom_name TEXT,
  nickname TEXT,
  mdc_current TEXT,                                   -- JSON object keyed by vehicle_locations.location
  notes TEXT,
  journal_entry_id INTEGER REFERENCES journal_entries(id) ON DELETE SET NULL,
  added_at TEXT NOT NULL DEFAULT (datetime('now')),
  removed_at TEXT,                                    -- NULL = still owned
  CHECK (vehicle_slug IS NOT NULL OR custom_name IS NOT NULL)
);

-- 2. the rows, parents before children.

INSERT INTO vehicles_w060 (id, slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book) SELECT id, slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book FROM vehicles;

INSERT INTO vehicle_weapons_w060 (id, vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) SELECT id, vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note FROM vehicle_weapons;

INSERT INTO vehicle_locations_w060 (id, vehicle_slug, location, mdc, mdc_note, ordinal) SELECT id, vehicle_slug, location, mdc, mdc_note, ordinal FROM vehicle_locations;

INSERT INTO character_vehicles_w060 (id, character_id, vehicle_slug, custom_name, nickname, mdc_current, notes, journal_entry_id, added_at, removed_at) SELECT id, character_id, vehicle_slug, custom_name, nickname, mdc_current, notes, journal_entry_id, added_at, removed_at FROM character_vehicles;

-- 3. the originals, children before parents.

DROP TABLE character_vehicles;
DROP TABLE vehicle_locations;
DROP TABLE vehicle_weapons;
DROP TABLE vehicles;

-- 4. the copies take their names back.

ALTER TABLE vehicles_w060 RENAME TO vehicles;
ALTER TABLE vehicle_weapons_w060 RENAME TO vehicle_weapons;
ALTER TABLE vehicle_locations_w060 RENAME TO vehicle_locations;
ALTER TABLE character_vehicles_w060 RENAME TO character_vehicles;

-- 5. the 3 indexes and triggers that went with the tables in step 3.

CREATE INDEX idx_vehicle_locations_slug ON vehicle_locations(vehicle_slug);
CREATE INDEX idx_vehicle_weapons_slug ON vehicle_weapons(vehicle_slug);
CREATE INDEX idx_character_vehicles_character
  ON character_vehicles (character_id);

INSERT OR IGNORE INTO schema_migrations (filename) VALUES ('060-vehicle-system-third-game.sql');

-- VERIFICATION.

SELECT 'vehicles admits four systems' AS assertion,
       CASE WHEN instr(sql, '''nightbane''') > 0 AND instr(sql, '''heroes-unlimited''') > 0
            THEN 1 ELSE 0 END AS got, 1 AS want
  FROM sqlite_master WHERE name = 'vehicles';

SELECT 'vehicles kept its rows' AS assertion, count(*) AS got, 171 AS want FROM vehicles;
SELECT 'vehicle_weapons kept its rows' AS assertion, count(*) AS got, 759 AS want FROM vehicle_weapons;
SELECT 'vehicle_locations kept its rows' AS assertion, count(*) AS got, 1574 AS want FROM vehicle_locations;
SELECT 'character_vehicles kept its rows' AS assertion, count(*) AS got, 0 AS want FROM character_vehicles;

SELECT 'every index and trigger is back' AS assertion, count(*) AS got, 3 AS want
  FROM sqlite_master
 WHERE type IN ('index', 'trigger') AND sql IS NOT NULL
   AND tbl_name IN ('vehicles', 'vehicle_locations', 'vehicle_weapons', 'character_vehicles');

SELECT 'no suffixed table survived' AS assertion, count(*) AS got, 0 AS want
  FROM sqlite_master WHERE name LIKE '%_w060';