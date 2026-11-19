-- Splynn Dimensional Market: the four TW Sky-Flyers and four Skyborne airship classes (p.188-190).
-- 8 vehicle rows, with 28 locations and 0 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~366-splynn-skyborne.sql
--
-- Written by scripts/vessel-sql.mjs from 1 worker file(s). Every value
-- is printable ASCII, every row cites its book, and a Main Body location
-- agrees with its vehicle's mdc_main_body.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('tw-sky-flyer-compact', 'TW Sky-Flyer Compact (Two-Man)', 'rifts', 'vehicle', 'One pilot', '1', NULL, 'Hovers in place or flies up to 120 mph (192 km), twice that on a ley line; usual cruise 30-50 mph (48-80 km); ceiling 10,000 feet (3048 m). Splynn''s limits: 20-40 mph (32-64 km) at street level, below 100 feet (30.5 m); up to 2,000 feet, 40-50 mph (64-80 km). A privately owned one can be souped up to as much as 50% over the standard speed.', NULL, 'Height 8 feet (2.4 m) on its landing gear, 6 feet with it retracted. Width 12 feet (3.7 m) across the wings. Length 13 feet (4 m).', '2 tons', 100, 1, NULL, 1000000, 'One million credits. Easy to find in Splynn, readily found elsewhere on Atlantis, hard to find anywhere else.', 'Skyborne''s two-seat recreational VTOL flyer and a favorite rental with visitors to Splynn, also bought as a personal runabout. Rounded or oval body with short stubby wings, tail fins, landing gear that retracts, headlights and underbelly landing lights, and a canopy that slides back so it can be flown open to the air. It flies on both Techno-Wizard and conventional systems; power is nuclear and magic, lasting about 6 years on average. Room for a couple of backpacks and two rifles. No weapons as sold; the Techno-Wizard vehicle add-ons of p.177 can be fitted. The Sedan, Taxi, Mini-Bus and Bus are scaled-up versions of it. Ley line racing is a popular sport.', 'Rifts World Book 21: Splynn Dimensional Market p.188'),
  ('tw-sky-flyer-sedan', 'TW Sky-Flyer Sedan/Taxi', 'rifts', 'vehicle', 'One pilot/driver', '4', NULL, 'Hovers in place or flies up to 100 mph (160 km), twice that on a ley line; ceiling 10,000 feet (3048 m). A privately owned Sedan can be souped up to as much as 50% over the standard speed.', NULL, NULL, NULL, 120, 1, NULL, 1600000, '1.6 million credits. Easy to find in Splynn, readily found elsewhere on Atlantis, hard to find anywhere else.', 'A larger Sky-Flyer, built like the Compact but carrying a pilot and four passengers; the book''s Sedan and Taxi seat the same and differ only in use. The book prints no location block of its own: its M.D.C. is the Compact''s raised by 20%, so each location here is the Compact''s figure times 1.2, rounded to the nearest whole point. Dimensions and weight are not printed. Light hover aircraft; the Techno-Wizard vehicle add-ons of p.177 can be fitted.', 'Rifts World Book 21: Splynn Dimensional Market p.188-189'),
  ('tw-sky-flyer-mini-bus', 'TW Sky-Flyer Mini-Bus/Van', 'rifts', 'vehicle', 'One pilot/driver', '10', NULL, 'Hovers in place or flies up to 100 mph (160 km), twice that on a ley line; ceiling 10,000 feet (3048 m).', NULL, NULL, NULL, 130, 1, NULL, 2000000, '2 million credits. Easy to find in Splynn, readily found elsewhere on Atlantis, hard to find anywhere else.', 'The flying mini-bus or van: a Sky-Flyer enlarged to carry a pilot and ten passengers. The book prints no location block of its own: its M.D.C. is the Compact''s raised by 30%, so each location here is the Compact''s figure times 1.3, rounded to the nearest whole point. Dimensions and weight are not printed. Light hover aircraft; the Techno-Wizard vehicle add-ons of p.177 can be fitted.', 'Rifts World Book 21: Splynn Dimensional Market p.188-189'),
  ('tw-sky-flyer-bus', 'TW Sky-Flyer Bus', 'rifts', 'vehicle', 'A pilot/co-pilot, who is also the tour guide', '40; 80 in the double-decker', NULL, 'Hovers in place or flies up to 100 mph (160 km), twice that on a ley line; ceiling 10,000 feet (3048 m).', NULL, NULL, NULL, 200, 1, NULL, 4000000, '4-6 million credits. Easy to find in Splynn, readily found elsewhere on Atlantis, hard to find anywhere else.', 'The flying bus, the largest Sky-Flyer: 40 passengers, or 80 in the double-decker version, which is much used for sightseeing tours. The book prints no location block of its own: its M.D.C. is double the Compact''s, so each location here is the Compact''s figure times 2. Dimensions and weight are not printed. Light hover aircraft; the Techno-Wizard vehicle add-ons of p.177 can be fitted.', 'Rifts World Book 21: Splynn Dimensional Market p.188-189'),
  ('skyborne-airship-small', 'Skyborne Airship (Yacht or Small)', 'rifts', 'ship', NULL, '30-60', NULL, 'Hovers in place or flies up to 150 mph (240 km), twice that on a ley line; usual cruise 30-60 mph (48-96 km); ceiling 20,000 feet (6100 m). A yacht or small speeder can be souped up to as much as 50% over the standard commercial speed.', NULL, NULL, NULL, 150, 1, NULL, 8000000, '8-20 million credits. Common.', 'The smallest class of Skyborne airship, yachts and small airships among them. Like every Skyborne airship it is a big, rounded but streamlined hull that recalls a pre-Rifts dirigible, built of solid materials and carried quietly by magic, with a gentle floating motion. The book gives each class a range of figures and no location block: M.D.C. 150-250 (the low end is stored), passengers 30-60, price 8-20 million. These big ships rarely race on ley lines.', 'Rifts World Book 21: Splynn Dimensional Market p.189'),
  ('skyborne-airship-medium', 'Skyborne Airship (Medium)', 'rifts', 'ship', NULL, '150-400', NULL, 'Hovers in place or flies up to 150 mph (240 km), twice that on a ley line; usual cruise 30-60 mph (48-96 km); ceiling 20,000 feet (6100 m). A privately owned one can be souped up to as much as 50% over the standard commercial speed.', NULL, NULL, NULL, 300, 1, NULL, 28000000, '28-50 million credits. Common.', 'The medium class of Skyborne airship: a big, rounded but streamlined hull that recalls a pre-Rifts dirigible, built of solid materials and carried quietly by magic. The book gives the class a range of figures and no location block: M.D.C. 300-500 (the low end is stored), passengers 150-400, price 28-50 million.', 'Rifts World Book 21: Splynn Dimensional Market p.189'),
  ('skyborne-airship-large', 'Skyborne Airship (Large)', 'rifts', 'ship', NULL, '600-1,000', NULL, 'Hovers in place or flies up to 150 mph (240 km), twice that on a ley line; usual cruise 30-60 mph (48-96 km); ceiling 20,000 feet (6100 m).', NULL, NULL, NULL, 500, 1, NULL, 80000000, '80-150+ million credits. Uncommon: there are dozens.', 'The large class of Skyborne airship: a massive, rounded but streamlined hull that recalls a pre-Rifts dirigible, built of solid materials and carried quietly by magic. The book gives the class a range of figures and no location block: M.D.C. 500-800 (the low end is stored), passengers 600-1,000, price 80 to more than 150 million.', 'Rifts World Book 21: Splynn Dimensional Market p.189-190'),
  ('skyborne-airship-luxury-linear', 'Skyborne Airship (Luxury Linear)', 'rifts', 'ship', NULL, '1,000-1,800', NULL, 'Hovers in place or flies up to 150 mph (240 km), twice that on a ley line; usual cruise 30-60 mph (48-96 km); ceiling 20,000 feet (6100 m).', NULL, NULL, NULL, 750, 1, NULL, 125000000, '125-190+ million credits. Rare: Skyborne''s fleet holds only eight, and no one in Splynn owns one privately.', 'The biggest Skyborne airship, headed Luxury Linear Airships in the book and called Luxury Liners in the same entry: a massive, rounded but streamlined hull that recalls a pre-Rifts dirigible, built of solid materials and carried quietly by magic. The book gives the class a range of figures and no location block: M.D.C. 750-1,000 (the low end is stored), passengers 1,000-1,800, price 125 to more than 190 million.', 'Rifts World Book 21: Splynn Dimensional Market p.189-190');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('tw-sky-flyer-compact', 'Maneuvering Thrusters (6)', 3, 'Each.', 1),
  ('tw-sky-flyer-compact', 'Main Jet Thrusters (2; rear)', 35, 'Each.', 2),
  ('tw-sky-flyer-compact', 'Pilot Cockpit', 50, 'Seats two.', 3),
  ('tw-sky-flyer-compact', 'Wings (2)', 30, 'Each.', 4),
  ('tw-sky-flyer-compact', 'Tail Fins (3)', 12, 'Each.', 5),
  ('tw-sky-flyer-compact', 'Main Body', 100, 'Destroying it destroys the vehicle.', 6),
  ('tw-sky-flyer-sedan', 'Maneuvering Thrusters (6)', 4, 'Each. Scaled: the Compact''s 3 plus 20% (3.6), rounded.', 1),
  ('tw-sky-flyer-sedan', 'Main Jet Thrusters (2; rear)', 42, 'Each. Scaled: the Compact''s 35 plus 20%.', 2),
  ('tw-sky-flyer-sedan', 'Pilot Cockpit', 60, 'Scaled: the Compact''s 50 plus 20%.', 3),
  ('tw-sky-flyer-sedan', 'Wings (2)', 36, 'Each. Scaled: the Compact''s 30 plus 20%.', 4),
  ('tw-sky-flyer-sedan', 'Tail Fins (3)', 14, 'Each. Scaled: the Compact''s 12 plus 20% (14.4), rounded.', 5),
  ('tw-sky-flyer-sedan', 'Main Body', 120, 'Scaled: the Compact''s 100 plus 20%. Destroying it destroys the vehicle.', 6),
  ('tw-sky-flyer-mini-bus', 'Maneuvering Thrusters (6)', 4, 'Each. Scaled: the Compact''s 3 plus 30% (3.9), rounded.', 1),
  ('tw-sky-flyer-mini-bus', 'Main Jet Thrusters (2; rear)', 46, 'Each. Scaled: the Compact''s 35 plus 30% (45.5), rounded.', 2),
  ('tw-sky-flyer-mini-bus', 'Pilot Cockpit', 65, 'Scaled: the Compact''s 50 plus 30%.', 3),
  ('tw-sky-flyer-mini-bus', 'Wings (2)', 39, 'Each. Scaled: the Compact''s 30 plus 30%.', 4),
  ('tw-sky-flyer-mini-bus', 'Tail Fins (3)', 16, 'Each. Scaled: the Compact''s 12 plus 30% (15.6), rounded.', 5),
  ('tw-sky-flyer-mini-bus', 'Main Body', 130, 'Scaled: the Compact''s 100 plus 30%. Destroying it destroys the vehicle.', 6),
  ('tw-sky-flyer-bus', 'Maneuvering Thrusters (6)', 6, 'Each. Scaled: double the Compact''s 3.', 1),
  ('tw-sky-flyer-bus', 'Main Jet Thrusters (2; rear)', 70, 'Each. Scaled: double the Compact''s 35.', 2),
  ('tw-sky-flyer-bus', 'Pilot Cockpit', 100, 'Scaled: double the Compact''s 50.', 3),
  ('tw-sky-flyer-bus', 'Wings (2)', 60, 'Each. Scaled: double the Compact''s 30.', 4),
  ('tw-sky-flyer-bus', 'Tail Fins (3)', 24, 'Each. Scaled: double the Compact''s 12.', 5),
  ('tw-sky-flyer-bus', 'Main Body', 200, 'Scaled: double the Compact''s 100. Destroying it destroys the vehicle.', 6),
  ('skyborne-airship-small', 'Main Body', 150, '150-250 by the ship; the low end is stored.', 1),
  ('skyborne-airship-medium', 'Main Body', 300, '300-500 by the ship; the low end is stored.', 1),
  ('skyborne-airship-large', 'Main Body', 500, '500-800 by the ship; the low end is stored.', 1),
  ('skyborne-airship-luxury-linear', 'Main Body', 750, '750-1,000 by the ship; the low end is stored.', 1);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 8 machines are in' AS assertion, count(*) AS got, 8 AS want
  FROM vehicles WHERE slug IN ('tw-sky-flyer-compact', 'tw-sky-flyer-sedan', 'tw-sky-flyer-mini-bus', 'tw-sky-flyer-bus', 'skyborne-airship-small', 'skyborne-airship-medium', 'skyborne-airship-large', 'skyborne-airship-luxury-linear');
SELECT 'their 28 locations are in' AS assertion, count(*) AS got, 28 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('tw-sky-flyer-compact', 'tw-sky-flyer-sedan', 'tw-sky-flyer-mini-bus', 'tw-sky-flyer-bus', 'skyborne-airship-small', 'skyborne-airship-medium', 'skyborne-airship-large', 'skyborne-airship-luxury-linear');
SELECT 'their 0 weapon entries are in' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('tw-sky-flyer-compact', 'tw-sky-flyer-sedan', 'tw-sky-flyer-mini-bus', 'tw-sky-flyer-bus', 'skyborne-airship-small', 'skyborne-airship-medium', 'skyborne-airship-large', 'skyborne-airship-luxury-linear');
SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('tw-sky-flyer-compact', 'tw-sky-flyer-sedan', 'tw-sky-flyer-mini-bus', 'tw-sky-flyer-bus', 'skyborne-airship-small', 'skyborne-airship-medium', 'skyborne-airship-large', 'skyborne-airship-luxury-linear') AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~366-splynn-skyborne.sql');
