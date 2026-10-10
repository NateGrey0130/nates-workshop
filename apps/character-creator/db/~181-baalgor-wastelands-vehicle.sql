-- Baalgor Wastelands: the Orcish Delight warship
-- 1 vehicle rows, with 9 locations and 3 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~181-baalgor-wastelands-vehicle.sql
--
-- Written by scripts/vessel-sql.mjs from 1 worker file(s). Every value
-- is printable ASCII, every row cites its book, and a Main Body location
-- agrees with its vehicle's mdc_main_body.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('orcish-delight-warship', 'The Orcish Delight Warship (Dwarven Juggernaut)', 'palladium-fantasy', 'landship', '4 to 8 drivers on the wheelcranks, 2 to 4 on the steercranks, and a captain', 'Up to 30 human- to Orc-sized warriors, or 15 giant-sized soldiers, or any mix', 'One quarter of the combined P.S. of the wheelcrank drivers, in mph: 20 mph (32 km) minimum with four P.S. 20 drivers, 50 mph (80 km) with eight P.S. 25 drivers, no set maximum. Accelerates 10 mph per minute. No brakes: coasts a quarter-mile per 10 mph to stop, or skids 1D6x100 yards with the front wheels turned. Turns 10 degrees per melee per steering crank (each needs P.S. 30), 40 degrees at the tightest.', NULL, NULL, '70 ft (21.2 m) long, 20 ft (6 m) wide, 25 ft (7.6 m) tall', 'Excess cargo capacity 15 tons with a minimum crew and no troops or weapons; 27 tons fully loaded. Each wheel weighs close to 1,000 lbs.', NULL, 0, NULL, NULL, 'Not for sale; one of a kind. The Western Empire has offered 300,000 gold for it in working order. Building another would cost millions.', 'An Elf-Dwarf War siege engine: a mastless ship''s hull on two ironwood axles and four indestructible metal-shod wheels, hand-cranked by its crew, with a ram on the bow, two aft gunnery towers and decks and holds like a sailing vessel. Holds 1200 P.P.E. and radiates magic; regenerates 10% of its S.D.C. every 24 hours unless the main body is wholly destroyed. Impact on ramming is cushioned by a Float in Air-like enchantment. The Damnation Crew''s captain Rogayashi found this one intact, the first seen in over 6000 years. Its main body is printed as three sections with no single total.', 'Palladium Fantasy RPG Book 9: The Baalgor Wastelands p.121-124');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('orcish-delight-warship', 'Main Body: Front Section', 800, NULL, 1),
  ('orcish-delight-warship', 'Main Body: Mid-Ship', 600, NULL, 2),
  ('orcish-delight-warship', 'Main Body: Rear Section', 700, NULL, 3),
  ('orcish-delight-warship', 'Ram-Prow', 800, NULL, 4),
  ('orcish-delight-warship', 'Fighting Towers (2)', 250, 'Each.', 5),
  ('orcish-delight-warship', 'Hull per 10 foot (3 m) area', 150, NULL, 6),
  ('orcish-delight-warship', 'Undercarriage, axles, wheel hubs', 100, 'Each.', 7),
  ('orcish-delight-warship', 'Wheels (4)', NULL, 'Completely indestructible (magic).', 8),
  ('orcish-delight-warship', 'Heavy Ballistas (2)', 125, 'Each. Printed in the armaments entry, not the location list; ballistas do not regenerate.', 9);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('orcish-delight-warship', 1, 'Ram-Prow', '1D6x25 per 10 mph of speed at impact', 0, NULL, NULL, NULL, NULL, '4D6x25 at 40 mph. Meant for large stationary targets: a living creature is +6 to dodge it, and the ram passes over anything under 10 ft tall.'),
  ('orcish-delight-warship', 2, 'Heavy Ballistas (2)', '1D6x10', 0, '1,320 ft (400 m)', NULL, NULL, NULL, 'One on each aft gunnery tower, on a crank turret with a 360 degree arc; a full melee round to turn 90 degrees. Flaming arrows add 4D6 per melee round until put out, with a 01-12% chance to ignite combustibles. Small rocks (10 lbs) do 5D6 at the same range. Roped harpoon arrows travel half range.'),
  ('orcish-delight-warship', 3, 'Run over', '1D6x10', 0, NULL, NULL, NULL, NULL, 'To an Ogre-sized or smaller humanoid, who is also stunned 1D6+1 melee rounds. Giant-sized humanoids take 6D6 and are stunned 1D4 melee rounds.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 machines are in' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug IN ('orcish-delight-warship');
SELECT 'their 9 locations are in' AS assertion, count(*) AS got, 9 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('orcish-delight-warship');
SELECT 'their 3 weapon entries are in' AS assertion, count(*) AS got, 3 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('orcish-delight-warship');
SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('orcish-delight-warship') AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~181-baalgor-wastelands-vehicle.sql');
