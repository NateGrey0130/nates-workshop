-- Rifts World Book 20: Canada: the Faerie Bot Vehicle, printed 151.
-- 1 vehicle, 3 M.D.C. locations, 1 weapon entry.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-canada-faerie-bot-vehicle.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-canada-faerie-bot-vehicle.sql
--
-- The survey's inventory missed it: it is printed inside the Faerie Bot's own
-- stat block as that creature's Standard Equipment (cache p152), not in the
-- equipment chapter, and add-canada-vehicles.sql does not have it. Found when
-- the Faerie Bot R.C.C. was drafted. The slug was free in production on
-- 2026-10-02.
--
-- The book prints no price and no crew line; the pilot is the Faerie Bot
-- that built it. Counts the book prints as ranges (two or three primary arms,
-- 1 or 2 secondary appendages, 2-4 tool appendages, 1 or 2 light weapons) are
-- kept as ranges in the description and the location names.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book)
VALUES
  ('faerie-bot-vehicle', 'Faerie Bot Vehicle', 'rifts', 'vehicle', 'One Faerie Bot.', 'None.', NULL,
   'Hovers stationary, lands and flies. Maximum speed 150 mph (240 km); cruising speed typically 10-30 mph (16 to 48 km). Maximum altitude unknown, at least 30,000 feet (9144 m), and it may be space capable.',
   'Maximum speed 60 mph (96 km) on the surface or underwater. Maximum depth one mile (1.6 km).',
   'A sphere the size of a basketball, never bigger.', 'With its pilot, 40-70 lbs (18 to 31.5 kg)', 120, NULL,
   'No price printed. Each Faerie Bot builds its own, and rebuilding a destroyed one takes its pilot 1D4+6 months.',
   'The flying robotic sphere a Faerie Bot lives and works in. Two or three primary arms, at least one a robot utility arm and hand (equivalent P.S. 1D6+12); one or two secondary appendages such as a tentacle or sensor antenna (equivalent P.S. 1D4+5); two to four retractable tool appendages, half with swappable heads and half single-purpose tools such as a laser cutter or plasma torch. It carries a universal language translator (93%), a 30 foot (9 m) tow line with hook and grapple rated to 500 lbs (a load of 300 lbs slows the sphere by 25%), multi-optics, a proximity alarm that sounds for anything moving within 10 feet (3 m), and a directional radio. Its power supply and its hover system are unknown and unlimited. About 40 M.D.C. of damage restores itself; anything more needs the pilot, time and parts. Its size and speed make the main body -3 to strike even on a called shot.',
   'Rifts World Book 20: Canada p.151');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('faerie-bot-vehicle', 'Main Arms (2)', 20, 'each', 1),
  ('faerie-bot-vehicle', 'Secondary Limbs and Tool Appendages (1-4)', 10, 'each', 2),
  ('faerie-bot-vehicle', 'Main Body', 120, '-3 to strike even with a called shot', 3);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('faerie-bot-vehicle', 1, 'Light Weapons (1 or 2)', '2D6 to 3D6 M.D., whatever it fires', 1, '2,000 feet (610 m)', NULL, NULL, NULL,
   'Typically a laser; may be plasma, electrical or another energy. No rate of fire or payload is printed.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the Faerie Bot Vehicle is in' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'faerie-bot-vehicle' AND mdc_main_body = 120 AND source_book = 'Rifts World Book 20: Canada p.151';
SELECT 'its 3 M.D.C. locations are in' AS assertion, count(*) AS got, 3 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'faerie-bot-vehicle';
SELECT 'its weapon entry is in' AS assertion, count(*) AS got, 1 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'faerie-bot-vehicle';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-canada-faerie-bot-vehicle.sql');
