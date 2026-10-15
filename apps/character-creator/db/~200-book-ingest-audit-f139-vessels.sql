-- BOOK-INGEST-AUDIT F139: the Vernulian Serpent Power Armor (D-Bees of North America printed 212)
-- 1 vehicle rows, with 5 locations and 0 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~200-book-ingest-audit-f139-vessels.sql
--
-- Written by scripts/vessel-sql.mjs from 1 worker file(s). Every value
-- is printable ASCII, every row cites its book, and a Main Body location
-- agrees with its vehicle's mdc_main_body.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('vernulian-serpent-power-armor', 'Vernulian Serpent Power Armor', 'rifts', 'power-armor', NULL, NULL, NULL, '400 mph (640 km) maximum. Low altitude flying only, on its hover jets: maximum height 300 feet (91 m).', NULL, NULL, NULL, 300, 1, NULL, NULL, 'No price printed. Military use only: the Vernulian military''s armor, not sold.', 'The Vernulian military''s power armor, built for the four-armed serpent body: an impressive and frightening sight, a giant serpent in robot-looking armor. It flies low on six underside hover jets and two main hover jets on its back. The book prints no crew line, weapon systems, weight, dimensions or ground speed; its M.D.C. by location and its flight are all it states. Printed 212, under the Vernulian R.C.C.''s Body Armor.', 'Rifts World Book 30: D-Bees of North America p.212');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('vernulian-serpent-power-armor', 'Head', 100, NULL, 1),
  ('vernulian-serpent-power-armor', 'Tentacles (4)', 100, 'each', 2),
  ('vernulian-serpent-power-armor', 'Main Body', 300, NULL, 3),
  ('vernulian-serpent-power-armor', 'Hover Jets (6, underside)', 25, 'each', 4),
  ('vernulian-serpent-power-armor', 'Main Hover Jets (2, on back)', 75, 'each', 5);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 machines are in' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug IN ('vernulian-serpent-power-armor');
SELECT 'their 5 locations are in' AS assertion, count(*) AS got, 5 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('vernulian-serpent-power-armor');
SELECT 'their 0 weapon entries are in' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('vernulian-serpent-power-armor');
SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('vernulian-serpent-power-armor') AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~200-book-ingest-audit-f139-vessels.sql');
