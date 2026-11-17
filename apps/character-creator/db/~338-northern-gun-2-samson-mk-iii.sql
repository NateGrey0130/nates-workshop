-- Rifts World Book 34: Northern Gun Two, the NG-X9 Samson Mk III (printed 140-144)
-- 1 vehicle row, with 16 locations and 6 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~338-northern-gun-2-samson-mk-iii.sql
--
-- The held ng-x9-samson-power-armor (Rifts Ultimate Edition p.271-272) is the
-- Mk I: main body 240, 850,000 credits, Robot P.S. 30, a mini-missile launcher
-- on each forearm. This book prints the later Mk III as its own suit (main
-- body 320, 1.7 million credits nuclear, Robot P.S. 33, a Forearm Tri-Laser),
-- so it is a row of its own beside the Mk I (Nate, 2026-11-17). The Mk I row
-- keeps its figures and citation and gains one sentence naming this one.
--
-- Printed misprints, recorded as printed:
--   * Statistical Data says "Robot P.S. 33 for the Mk 11 and Mk II". The
--     Hand to Hand section on the same spread says 33 is "applicable to Mk II
--     and Mk III units, the Mk I had a Robot P.S. of 30", so 33 is stored for
--     the Mk III and "Mk 11" is read as Mk I's misprint for the Mk II/Mk III.
--   * Cost says used models sell "for 850,00 to 1.2 million credits". The
--     digit-dropped 850,00 is printed so; it is read as 850,000 in the row's
--     cost note and not stored as a figure.
-- Both were read off the rendered page, not only the text layer.
--
-- Shape as scripts/vessel-sql.mjs writes it: INSERT OR IGNORE on the slug.
-- Every value is printable ASCII, and a Main Body location agrees with its
-- vehicle's mdc_main_body. The tilde number is claimed at merge.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('ng-x9-samson-mk-iii-power-armor', 'NG-X9 Samson Mk III Power Armor', 'rifts', 'power-armor', 'One.', NULL, 'Running: 150 mph (240 km) maximum, at 20% of the normal fatigue rate at full speed and 10% at 75 mph (120 km) or less. Leaping: 25 ft (7.6 m) high or across unassisted by the jet boosters, +50% with a running start; a booster-assisted leap reaches 100 ft (30.5 m) high and 200 ft (61 m) across, +50% with a running start. This is not flight.', 'None. After a leap upward it can hover for one melee round (15 seconds) before drifting back down. Its back and leg thrusters land it softly from drops of up to 400 ft (122 m), halved if the main back thruster system is destroyed. Drops of 400-800 ft (122 to 244 m): roll 1D20; 1-10 it lands hard, takes 4D6 M.D. and the pilot loses 1D4 melee actions; 11-20 it sticks the landing. Higher drops cost 2D6x10 M.D. to the armor and 6D6 S.D.C./Hit Points to the pilot, who is stunned 1D4 melee rounds.', 'Not built for water; walks the bottom at 20 mph (32 km/17 knots). Maximum depth 2,000 ft (610 m).', 'Height: 11 feet (3.4 m); Width: 5 feet (1.5 m); Length: 4 feet, 6 inches (1.4 m)', '1,000 pounds (450 kg) fully loaded', 320, 1, NULL, 950000, 'Black Market Cost: 1.7 million credits nuclear, 1.3 million Solid Oxide, 950,000 electric; the lowest is stored. Older and used models sell for "850,00" (as printed, a digit short; read as 850,000) to 1.2 million credits but seldom have more than 1D4x10+180 M.D.C. on the main body. Optional: UEL power cable in each forearm, 150,000 credits each; gun camera 6,500 credits each.', 'Northern Gun''s first and best selling power armor, an Armored Infantry Assault Suit and a hybrid of power armor and combat robot: the pilot rides in the chest with his head inside it, works the arms through shoulder controls and moves his own legs to move the suit, seeing through cameras 10 feet (3 m) up. Released in 81 P.A.; this is the heaviest of the Mk I, Mk II and Mk III, which look nearly identical and were never advertised as different. The Mk II has the same M.D.C. as the Samson Missileman. Compare the Mk I, row ng-x9-samson-power-armor (Rifts Ultimate Edition: main body 240, 850,000 credits, Robot P.S. 30, a launcher on each forearm and no Tri-Laser). Robotic P.S. 33; the book prints "Mk 11 and Mk II" in its statistics and "Mk II and Mk III" under hand to hand, and the Mk I is given as 30. Nuclear power, 15 year average life (Solid Oxide and electric models are sold). A small storage area takes supplies and personal weapons, and a footlocker-size compartment holds the pilot''s human-scale weapons. Destroying the head leaves the sealed pilot seeing through two chest cameras, or an optional gun camera, on his HUD: -3 to strike, parry, dodge and disarm and -4 on Perception Rolls, doubled with only a gun camera. Sensors: two abdomen searchlights (6 M.D.C. each; 20 degree arc; 400 ft/122 m), two helmet cameras (96 hours of video, 4,000 stills), helmet voice modulation (bullhorn, translator, 20 voices), passive nightvision to 1,600 ft (488 m) and ultraviolet vision. The UEL option, one concealed in each forearm, has been sold since summer 108 P.A. Oversized hand weapons only: man-sized weapons are awkward, -2 to strike.', 'Rifts World Book 34: Northern Gun Two p.140-144');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('ng-x9-samson-mk-iii-power-armor', 'Head', 100, 'Small target: Called Shot, -4 to strike. Destroying it ends all sensory enhancement and the main optics and the Robot Combat bonuses; the sealed pilot sees through two chest cameras, or an optional gun camera, shown on his HUD, at -3 to strike, parry, dodge and disarm and -4 on Perception Rolls, doubled with only a gun camera.', 1),
  ('ng-x9-samson-mk-iii-power-armor', 'Neck Fin Shield (right side of head)', 50, NULL, 2),
  ('ng-x9-samson-mk-iii-power-armor', 'Chest Lights (2, low profile)', 10, 'Each. Small target: Called Shot, -4 to strike.', 3),
  ('ng-x9-samson-mk-iii-power-armor', 'Main Ammo-Drum (back, large)', 75, NULL, 4),
  ('ng-x9-samson-mk-iii-power-armor', 'Second Ammo-Drum (back, small)', 40, NULL, 5),
  ('ng-x9-samson-mk-iii-power-armor', 'Rail Gun', 75, NULL, 6),
  ('ng-x9-samson-mk-iii-power-armor', 'Shoulder Plates (2)', 90, 'Each.', 7),
  ('ng-x9-samson-mk-iii-power-armor', 'Arms (2)', 90, 'Each.', 8),
  ('ng-x9-samson-mk-iii-power-armor', 'Hands (2)', 30, 'Each.', 9),
  ('ng-x9-samson-mk-iii-power-armor', 'Legs (2)', 150, 'Each.', 10),
  ('ng-x9-samson-mk-iii-power-armor', 'Leg Thrusters (2, one per leg)', 30, 'Each. Small target: Called Shot, -4 to strike.', 11),
  ('ng-x9-samson-mk-iii-power-armor', 'Rear Thruster Jets (2, back)', 50, 'Each. Losing the main back thruster system halves the safe drop height.', 12),
  ('ng-x9-samson-mk-iii-power-armor', 'Forearm Mini-Missile Launcher (1, left)', 50, NULL, 13),
  ('ng-x9-samson-mk-iii-power-armor', 'Forearm Tri-Laser (1, right)', 40, 'Small target: Called Shot, -4 to strike.', 14),
  ('ng-x9-samson-mk-iii-power-armor', 'Headlights (2, chest/upper abdomen)', 6, 'Each. Small target: Called Shot, -4 to strike.', 15),
  ('ng-x9-samson-mk-iii-power-armor', 'Main Body', 320, 'One of the most heavily armored suits of its kind. Reduced to zero, the armor shuts down completely and is useless.', 16);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('ng-x9-samson-mk-iii-power-armor', 1, 'NG-S202 Super-Samson Rail Gun', '1D6 M.D. per single round; 1D6x10 M.D. per 60-round burst', 1, '4,000 ft (1,219 m)', 'Each burst or single shot counts as one melee attack', '6,000-round drum for 100 bursts. A second drum hooks under the rocket jets and must be swapped by another Samson or a character with a strength of 26 or higher. A reload takes about 5 minutes untrained, one minute for someone trained in Samson power armor', NULL, 'Anti-armor, anti-monster and assault, secondarily anti-personnel and defense. Standard equipment with a bigger payload than the machine-gun version, wired straight into the suit''s nuclear supply, no separate power pack. Anti-monster rounds can be substituted. Locks behind the head and shoulders when not needed.'),
  ('ng-x9-samson-mk-iii-power-armor', 2, 'NG-SAM209 Forearm Mini-Missile Launcher (1, left)', 'By missile type', 1, 'One mile (1.6 km)', 'One at a time or a volley of two', 'Four: two mini-missiles in each of two barrels; eight if the right forearm laser is swapped for a launcher, a rarity', NULL, 'Anti-aircraft and anti-missile, secondarily anti-armor and defense. A double-barrel launcher in the left forearm. The Mk I had this archaic launcher on both forearms and no Tri-Laser.'),
  ('ng-x9-samson-mk-iii-power-armor', 3, 'NG-SAM309 Forearm Tri-Laser (1, right)', '2D6 M.D. single, 4D6 M.D. dual, 6D6 M.D. triple blast at one target', 1, '1,600 ft (488 m)', 'Each single or multiple blast counts as one melee attack', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Assault and anti-personnel, secondarily defense. Barrel-less: it fires from three openings in a forearm plate that looks like a small shield, and most people take it for the missile launcher. It can be swapped for the double-barrel mini-missile launcher, a single-barrel ion blaster (same range, 4D6 M.D. per blast), or an S.D.C. machine-gun the size of the launcher (range 1,200 ft/366 m; 6D6+6 S.D.C. per burst of six rounds; 360 rounds for 60 bursts; standard, silver-coated or wooden ammo from a drum on the back or behind the shoulder).'),
  ('ng-x9-samson-mk-iii-power-armor', 4, 'Knuckle Vibro-Blades', '3D4+3 M.D., Robot P.S. included', 1, 'Melee; arm''s reach, about 5 ft (1.5 m)', NULL, NULL, NULL, 'Assault and close combat, secondarily defense. Three vicious blades extend from the hand.'),
  ('ng-x9-samson-mk-iii-power-armor', 5, 'Energy Rifles and Handheld Weapons (optional)', 'By weapon.', 1, NULL, NULL, NULL, NULL, 'Not a built-in system. Any large, heavy weapon made for power armor or Combat Cyborgs, and if not too large for combat robot vehicles, fits. The suit is oversized, so man-sized weapons need modifying and are still awkwardly small (-2 to strike). Carried in hand or slung; a large side arm such as an oversized Vibro-Sword rides in a belt scabbard.'),
  ('ng-x9-samson-mk-iii-power-armor', 6, 'Hand to Hand Combat', 'Robot P.S. 33: restrained punch 1D4 M.D.; full strength punch 2D4; power punch 4D4 (two melee attacks); kick 2D8; leap kick 4D8 (two melee attacks)', 1, NULL, NULL, NULL, NULL, 'Mega-Damage combat in place of a weapon; see Basic or Elite Ground-Based Power Armor Training, Rifts Ultimate Edition pp.351-352. The Mk I had Robot P.S. 30.');

-- Names the Mk III beside the held Mk I. Guarded on the sentence being absent,
-- so a re-run is a no-op. Nothing else about the Mk I row changes.
UPDATE vehicles SET description = description || ' Rifts World Book 34: Northern Gun Two prints the later NG-X9 Samson Mk III (main body 320, Robot P.S. 33, a Forearm Tri-Laser) as its own row, ng-x9-samson-mk-iii-power-armor.'
  WHERE slug = 'ng-x9-samson-power-armor' AND instr(description, 'ng-x9-samson-mk-iii-power-armor') = 0;

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the Mk III is in' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'ng-x9-samson-mk-iii-power-armor';
SELECT 'its 16 locations are in' AS assertion, count(*) AS got, 16 AS want
  FROM vehicle_locations WHERE vehicle_slug = 'ng-x9-samson-mk-iii-power-armor';
SELECT 'its 6 weapon entries are in' AS assertion, count(*) AS got, 6 AS want
  FROM vehicle_weapons WHERE vehicle_slug = 'ng-x9-samson-mk-iii-power-armor';
SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug = 'ng-x9-samson-mk-iii-power-armor' AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;
SELECT 'the Mk I names the Mk III and keeps its figures' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE slug = 'ng-x9-samson-power-armor' AND mdc_main_body = 240 AND cost = 850000
   AND source_book = 'Rifts Ultimate Edition p.271-272' AND instr(description, 'ng-x9-samson-mk-iii-power-armor') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~338-northern-gun-2-samson-mk-iii.sql');
