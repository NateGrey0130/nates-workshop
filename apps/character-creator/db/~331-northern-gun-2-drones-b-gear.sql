-- Rifts World Book 34: Northern Gun Two, the Drone Control and Command Gauntlet (printed 244-245)
-- 1 gear row.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~331-northern-gun-2-drones-b-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-drone-control-command-gauntlet', 'Drone Control and Command Gauntlet (DCCG)', 'rifts', 'gear', 2, 5200, '5,200 credits.', NULL, 0, '5 miles (8 km) relay', NULL, NULL, NULL, NULL, 10, 'An optional wrist-worn command suite sold for NG drones such as the Fido, the Mule and the Robosistant. Five screens (a large one, two mid-sized, two small) show live feed from up to five drones at once; up to ten can be linked, and the wearer flips between them, which helps when one sends a distress signal. A keypad sends numeric and typed orders and a radio sends spoken ones. Whatever the drones'' cameras see reaches the wearer, and the gauntlet records, cuts and sends video and stills (serious editing and filmmaking need the TV/Video skill), passing the drones'' audio, video and data on to a computer, vehicle, giant robot or other receiver within 5 miles (8 km).', 'Rifts World Book 34: Northern Gun Two p.244-245', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 gear rows are in' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug IN ('ng-drone-control-command-gauntlet') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~331-northern-gun-2-drones-b-gear.sql');
