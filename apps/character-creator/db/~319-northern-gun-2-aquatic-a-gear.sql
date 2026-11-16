-- Rifts World Book 34: Northern Gun Two, AquaWalker Tires, priced on their own (printed 182-183)
-- 1 gear row.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~319-northern-gun-2-aquatic-a-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-aquawalker-tires', 'AquaWalker Tires', 'rifts', 'gear', NULL, 2000, '2,000 credits a pair for a motorcycle; 7,500 for a set of four for a light ATV or car; 10,000 for a set of four for a heavy ATV or truck. The lowest is stored.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A Northern Gun accessory, made in sizes to fit nearly any wheeled vehicle, whose special tread and paddling flaps of plain hard rubber carry an ordinary car, ATV or motorcycle across open water. Below 35 mph (56 km) on water the vehicle starts under and nothing saves it, so it can never stop out there. On roads ground speed drops 20%, and 1D4 hours of dry-land driving wears the flaps down until the tires no longer work on water at all. They are at their best on lakes, rivers, marshes, bogs and mud flats, crossing from water to mud and briefly onto hard ground.', 'Rifts World Book 34: Northern Gun Two p.182-183', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 gear rows are in' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug IN ('ng-aquawalker-tires') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~319-northern-gun-2-aquatic-a-gear.sql');
