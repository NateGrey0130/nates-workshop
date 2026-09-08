-- Underseas vessels from printed pages 081-105: the cetacean power armour
-- family and the machines of Tritonia.

--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-underseas-vessels-p081-105.sql
--
-- BOOK-INGEST-AUDIT.md F3, and the same shape the triax vessel files use.
-- `gear` holds one mdc, one damage, one range and one payload; a vessel here
-- has M.D.C. by LOCATION and several numbered weapon systems with four stats
-- each. Migration 048 gave them three tables.
--
-- NOTE THAT NOTHING IN THE APP READS THESE TABLES YET. Checked 2026-09-08:
-- no file under js/, functions/, app.js or sheet.js references vehicles,
-- vehicle_locations or vehicle_weapons, and neither does the test suite. Only
-- scripts/source-coverage.mjs does. This data is correct and reportable and it
-- is not user-visible; that is the state migration 048 left, not something
-- this import changed.
--
-- A VESSEL BELONGS TO THE SLICE ITS NAME HEADING FALLS IN, so no vessel is
-- split across two of these files and none is imported twice.
--
-- mdc_main_body is the main body ONLY. The full printed block is in
-- vehicle_locations, main body included, in the order the book sets it.
--
-- OFFSET: every page in this file is below printed 130, so cache page N IS
-- printed folio N here. The -1 rule in scripts/books.json applies only past
-- the split.
--
-- FOUR THINGS THE BOOK PRINTS THAT DO NOT ADD UP, transcribed as printed and
-- flagged on the row that carries them rather than corrected:
--   * the Sea Fin Combat Sled's length, "5 feet (61 m)"
--   * the Sea Fin and Torpedo Sleds' crew line, "Four, plus can accommodate
--     up to six passengers" - word for word the T-23 submarine's line, on two
--     vessels whose own descriptions call them one-man sleds
--   * the Man-O-War's dolphin-size width of 12 feet against a length of 8
--   * the T-23's fourth weapon system, which prints a range and then no
--     payload at all before the next heading
--
-- THE MAN-O-WAR HAS TWO MAIN BODY FIGURES, 225 for the dolphin size and 330
-- for the killer whale. The dolphin figure is stored in mdc_main_body and
-- both are in the location row's note, because one column cannot hold a size
-- branch.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('sea-snake-class-power-armor', 'Sea-Snake Class Dolphin Scout Power Armor', 'rifts', 'Dolphin Scout Power Armor', 'One dolphin or porpoise.', NULL, 'Not possible.', 'Not possible.', 'Surface 60 mph (96.5 kmph; 51.6 knots); underwater 70 mph (112.6 kmph).', 'Height 5 feet (1.5 m), width 5 feet (1.5 m), length 10 feet (3.0 m).', '350 lbs (157.5 kg)', 145, 900000, '900,000 credits nuclear, or 560,000 solar.', 'The lightest of the four suits built for cetacean pilots - a scout rather than a fighter, with one laser and an optional torpedo pack. It cannot operate on land or in the air at all, which is true of every suit in this family.', 'Rifts World Book 7: Underseas p.81'),
('man-o-war-class-power-armor', 'Man-O-War Class Combat Power Armor', 'rifts', 'Dolphin & Orca Combat Power Armor', 'One.', NULL, 'Not possible.', 'Not possible.', 'Surface 40 mph (64.3 kmph; 34.4 knots); underwater 45 mph (72 kmph; 38.7 knots).', 'Dolphin size: height 10 feet, width 12 feet, length 8 feet. Orca size: height 14 feet, width 20 feet, length 28 feet. The width and length figures are printed that way round.', 'Dolphin size 600 lbs; orca size 1.2 tons.', 225, 1000000, '1.5 million credits nuclear or 1 million solar, plus a further 1 million for the killer whale size.', 'The combat suit of the family, built in two sizes for dolphin and orca pilots. Seven forward lasers, two rail guns and four blade fins, and the orca version carries half again the main body M.D.C.', 'Rifts World Book 7: Underseas p.82-83'),
('sea-tiger-class-power-armor', 'Sea Tiger Class Orca Combat Power Armor', 'rifts', 'Orca Combat Power Armor', 'One killer whale or pneuma-biform.', NULL, 'Not possible.', 'Not possible.', 'Surface 35 mph; underwater 40 mph.', 'Height 16 feet, width 15 feet, length 40 feet.', '2.3 tons', 430, 1700000, '2.6 million credits nuclear or 1.7 million solar.', 'A heavy orca combat suit with a ram fin, three mini-torpedo tubes and a set of jaws. It is the only suit in the family whose weapon list includes the pilot own physical attacks, which the book numbers alongside the guns.', 'Rifts World Book 7: Underseas p.83-84'),
('unicorn-scout-class-power-armor', 'Unicorn Scout Class Power Armor', 'rifts', 'Orca Scout & Light Combat Power Armor', 'One killer whale, small whale or pneuma-biform.', NULL, 'Not possible.', 'Not possible.', 'Surface 32 mph; underwater 38 mph.', 'Height 16 feet, width 14 feet, length 35 feet, plus 15 feet for the lance.', '2.5 tons', 450, 1500000, '2.4 million credits nuclear or 1.5 million solar.', 'A scout and light combat suit carrying the heaviest main body of the four, and a fifteen foot lance that gives it its name. Its laser and ion blaster can be fired together for 7D6 M.D., which is more than either does alone.', 'Rifts World Book 7: Underseas p.84-85'),
('merbot-power-armor', 'Merbot Power Armor', 'rifts', 'Amphibious Armored Exo-Skeleton/Power Armor', 'One.', NULL, 'Running 40 mph (64 km) maximum.', 'Not possible.', 'Swimming up to 50 mph (80 km) underwater, dropping to 20 mph if the tail is destroyed.', 'Height 12 feet counting the tail, or 8 feet standing; width 4 feet; length 3 feet.', 'One ton', 300, 3000000, '3 million credits.', 'Tritonia humanoid power armour, with a tail for swimming and legs for walking - the only suit in this book that does both properly. Physical strength equal to a P.S. of 40. Losing the tail costs it more than half its swimming speed.', 'Rifts World Book 7: Underseas p.101-102'),
('bottom-feeder-t-23-mini-sub', '"Bottom Feeder" T-23 Mini-Sub', 'rifts', 'Light Combat Submersible', 'Four.', 'Up to six.', 'Not possible.', 'Not possible.', 'Surface 50 knots (92.5 km/58 mph); underwater 30 knots (54 km/34 mph).', 'Height 12 feet, width 22 feet, length 200 feet.', '100 tons, with 5 tons of cargo capacity.', 600, 5000000, '5 million credits.', 'Tritonia light combat submarine. The book also describes two unarmed variants: the T-23BS and T-23AS have 100 less main body M.D.C. and 10% more speed, the BS dropping the ion guns and the AS dropping both ion guns and laser pods in favour of retractable arms.', 'Rifts World Book 7: Underseas p.102-103'),
('sea-fin-combat-sled', 'Sea "Fin" Combat Sled', 'rifts', 'Light Combat Underwater Sled', 'The book prints "Four, plus can accommodate up to six passengers", which contradicts its own description of a one-man sled; see the note on the vessel.', 'Up to six, as printed.', 'Not possible.', 'Not possible.', 'Underwater 56 knots (104 km/65 mph). It cannot run on the surface, though the fin can skim near it at up to 40 knots (34 mph).', 'Height 12 feet, width 6 feet, length printed as "5 feet (61 m)" - the two figures disagree and the imperial one is the usable reading.', '500 lbs, with 1000 lbs of cargo capacity.', 180, 1000000, 'One million credits.', 'A one-man Tritonian combat sled bristling with small mounts - three mini-torpedo tubes, two laser turrets, a harpoon gun and a pair of camera turrets the book numbers among its weapon systems.', 'Rifts World Book 7: Underseas p.103-104'),
('torpedo-sled-t-06', 'Torpedo Sled', 'rifts', 'All-Purpose Underwater Sled', 'The book prints "Four, plus can accommodate up to six passengers", which contradicts its own description of a one-man sled; see the note on the vessel.', 'Up to six, as printed.', 'Not possible.', 'Not possible.', 'Underwater 43 knots (50 mph/80 km). It cannot run on the surface, though it can skim near it at up to 40 knots (34 mph).', 'Height 5 feet, width 8 feet, length 7 feet.', '350 lbs, with 1000 lbs of cargo capacity.', 145, 1000000, 'One million credits.', 'The unarmed Tritonian sled - the book states outright that it has no weapon systems, which makes it the only vessel in this batch with none. It carries a thousand pounds of cargo on a 350 pound hull.', 'Rifts World Book 7: Underseas p.104-105');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('sea-snake-class-power-armor', 'Forward Laser Gun (1)', 25, NULL, 1),
('sea-snake-class-power-armor', 'Jet Thrusters (4)', 100, 'Each.', 2),
('sea-snake-class-power-armor', 'Main Body/Pilot Area', 145, NULL, 3),
('man-o-war-class-power-armor', 'Forward Lasers (7)', 10, 'Each.', 1),
('man-o-war-class-power-armor', 'Blade Fins (4)', 40, 'Each.', 2),
('man-o-war-class-power-armor', 'Rail Guns (2)', 45, 'Each.', 3),
('man-o-war-class-power-armor', 'Lower Fin (1)', 90, NULL, 4),
('man-o-war-class-power-armor', 'Jet Thrusters (3)', 170, 'Each.', 5),
('man-o-war-class-power-armor', 'Main Body/Pilot Area', 225, 'Dolphin size 225; killer whale size 330. The stored main body figure is the dolphin size.', 6),
('sea-tiger-class-power-armor', 'Forward Lasers (2)', 35, 'Each.', 1),
('sea-tiger-class-power-armor', 'Rail Guns (2)', 50, 'Each.', 2),
('sea-tiger-class-power-armor', 'Ram Fin (1)', 150, NULL, 3),
('sea-tiger-class-power-armor', 'Side Jet Thrusters (2)', 200, 'Each.', 4),
('sea-tiger-class-power-armor', 'Rear Jet Thruster (1)', 180, NULL, 5),
('sea-tiger-class-power-armor', 'Main Body/Pilot Area', 430, NULL, 6),
('unicorn-scout-class-power-armor', 'Forward Laser (1)', 35, NULL, 1),
('unicorn-scout-class-power-armor', 'Lower Ion Cannon (1)', 50, NULL, 2),
('unicorn-scout-class-power-armor', 'Unicorn Lance (1)', 120, NULL, 3),
('unicorn-scout-class-power-armor', 'Rear Spines (5)', 35, 'Each.', 4),
('unicorn-scout-class-power-armor', 'Top Jet Thruster (1)', 200, NULL, 5),
('unicorn-scout-class-power-armor', 'Bottom Jet Thruster (1)', 180, NULL, 6),
('unicorn-scout-class-power-armor', 'Main Body/Pilot Area', 450, NULL, 7),
('merbot-power-armor', 'Head', 110, NULL, 1),
('merbot-power-armor', 'Tail', 150, NULL, 2),
('merbot-power-armor', 'Arms (2)', 100, 'Each.', 3),
('merbot-power-armor', 'Legs (2)', 120, 'Each.', 4),
('merbot-power-armor', 'Main Body', 300, NULL, 5),
('bottom-feeder-t-23-mini-sub', 'Forward Torpedo Tubes (2)', 120, 'Each.', 1),
('bottom-feeder-t-23-mini-sub', 'Laser Pods (2)', 80, 'Each.', 2),
('bottom-feeder-t-23-mini-sub', 'Ion Guns (2)', 60, 'Each.', 3),
('bottom-feeder-t-23-mini-sub', 'Mini-Torpedo Tubes (2)', 50, 'Each.', 4),
('bottom-feeder-t-23-mini-sub', 'Pilot''s Compartment', 200, NULL, 5),
('bottom-feeder-t-23-mini-sub', 'Main Body', 600, 'The T-23BS and T-23AS variants have 100 less.', 6),
('sea-fin-combat-sled', 'Forward Sensor/Camera Turrets (2)', 50, NULL, 1),
('sea-fin-combat-sled', 'Forward Mini-Torpedo Tubes (3)', 22, 'Each.', 2),
('sea-fin-combat-sled', 'Forward Lower Laser (1)', 28, NULL, 3),
('sea-fin-combat-sled', 'Rear Laser Turret (1)', 65, NULL, 4),
('sea-fin-combat-sled', 'Lower Forward Harpoon Gun (1)', 20, NULL, 5),
('sea-fin-combat-sled', 'Propeller Jets (2)', 110, 'Each.', 6),
('sea-fin-combat-sled', 'Top Fin (1)', 220, NULL, 7),
('sea-fin-combat-sled', 'Bottom Fin (1)', 180, NULL, 8),
('sea-fin-combat-sled', 'Main Body/Pilot Area', 180, NULL, 9),
('torpedo-sled-t-06', 'Propeller Jets (2)', 90, 'Each.', 1),
('torpedo-sled-t-06', 'Top Fin (1)', 100, NULL, 2),
('torpedo-sled-t-06', 'Main Body/Pilot Area', 145, NULL, 3);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('sea-snake-class-power-armor', 1, 'Forward Blue-Green Laser Turret', '2D6 M.D.', 1, '2000 feet (610 m)', 'One shot per melee action.', 'Effectively unlimited.', NULL, NULL),
('sea-snake-class-power-armor', 2, 'Mini-Torpedoes (optional)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '12', NULL, 'An optional fit rather than standard.'),
('man-o-war-class-power-armor', 1, 'Forward Blue-Green Laser Turret (7 lasers)', '1D6 M.D. single, or 2D6 to 7D6 M.D. on a volley.', 1, '1200 feet (366 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('man-o-war-class-power-armor', 2, 'Rail Guns (2)', '1D4x10 M.D. burst, 1D4 M.D. single round.', 1, '1200 feet (366 m) underwater, 3000 feet (914 m) in air.', NULL, '120 short bursts, 4800 rounds.', NULL, NULL),
('man-o-war-class-power-armor', 3, 'Blade Fins (4)', 'Raking 1D6, 2D6 or 4D6 M.D.; stab 3D6 or 1D4x10 M.D.; power strike 2D4x10 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('man-o-war-class-power-armor', 4, 'Mini-Torpedoes', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '14', NULL, NULL),
('sea-tiger-class-power-armor', 1, 'Forward Pulse Laser', '2D6, 4D6 or 6D6 M.D.', 1, '2500 feet (762 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('sea-tiger-class-power-armor', 2, 'Rail Guns (2)', '1D4x10 M.D. burst, 1D4 M.D. single round.', 1, NULL, NULL, '240 bursts.', NULL, NULL),
('sea-tiger-class-power-armor', 3, 'Ram Fin', '2D6, 4D6 or 1D6x10 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('sea-tiger-class-power-armor', 4, 'Mini-Torpedo Tubes (3)', '1D6x10 M.D.', 1, NULL, NULL, '21', NULL, NULL),
('sea-tiger-class-power-armor', 5, 'Power Armor Jaw', '2D6 M.D. bite.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('sea-tiger-class-power-armor', 6, 'Physical Combat (Special)', 'Nose jab 1D6 M.D.; head or nose strike 2D4 or 3D6 M.D.; power strike 1D6x10 M.D.', 1, 'Melee.', NULL, NULL, NULL, 'The book numbers the pilot own attacks as a weapon system.'),
('unicorn-scout-class-power-armor', 1, 'Forward Pulse Laser', '2D6 or 4D6 M.D., or 7D6 M.D. fired simultaneously with the ion gun.', 1, '2500 feet (762 m)', NULL, NULL, NULL, NULL),
('unicorn-scout-class-power-armor', 2, 'Forward Ion Blaster', '5D6 M.D., or 7D6 M.D. combined with the laser.', 1, '1200 feet (366 m) underwater, 2000 feet (610 m) in air.', NULL, NULL, NULL, NULL),
('unicorn-scout-class-power-armor', 3, 'Unicorn Lance', 'Glancing 2D6 M.D., stab 5D6 M.D., power strike 2D4x10 M.D.', 1, 'Melee.', NULL, NULL, '+1 to parry, +2 to strike.', NULL),
('merbot-power-armor', 1, 'Wrist Laser', '4D6 M.D.', 1, '2000 feet (610 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('merbot-power-armor', 2, 'Torpedo Launcher (2 tubes)', '1D6x10 M.D.', 1, NULL, NULL, '4', NULL, 'Can also fire nets, sonar sensors or decoys instead of torpedoes.'),
('merbot-power-armor', 3, 'M-90 "Beach Stormer" Multi-Weapon Assault System', 'Ion pulse 1D6x10+10 M.D.; LAWS or mini-harpoon 1D6x10 M.D.; bayonet 3D6 M.D.', 1, NULL, NULL, 'Pulse gun effectively unlimited on its cable; LAWS drum of 12 rounds.', NULL, 'The giant original of the man-portable M-80 Stormbringer on printed 100. Its use is restricted by the pilot P.S.'),
('merbot-power-armor', 4, 'Other Weapons', NULL, 0, NULL, NULL, NULL, NULL, 'The book allows any rail gun, robot or power armour weapon to be substituted, and gives no stats for the alternatives.'),
('merbot-power-armor', 5, 'Hand to Hand Combat', 'Restrained punch 1D4 M.D., full strength 2D4 M.D., power punch 3D6 M.D. counting as two attacks, tail sweep 3D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, 'The tail sweep is at -2 to strike on dry land.'),
('bottom-feeder-t-23-mini-sub', 1, 'Torpedo Tubes (2)', '3D4x10 M.D. high explosive, or 2D6x10 M.D. plasma.', 1, 'Ten miles (16 km)', NULL, '12', NULL, NULL),
('bottom-feeder-t-23-mini-sub', 2, 'Laser Pods (2)', '1D6x10 M.D.', 1, '4000 feet (1220 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('bottom-feeder-t-23-mini-sub', 3, 'Ion Guns', '1D6x10 M.D.', 1, '2000 feet (610 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('bottom-feeder-t-23-mini-sub', 4, 'Mini-Torpedo Tubes (2)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, NULL, NULL, 'NO PAYLOAD IS PRINTED for this system. The entry runs straight from its range line into the next heading; the figure is absent from the book rather than lost in the scan.'),
('sea-fin-combat-sled', 1, 'Mini-Torpedo Tubes (3)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '6, two per tube.', NULL, NULL),
('sea-fin-combat-sled', 2, 'Forward Laser Turret', '3D6 M.D.', 1, '4000 feet (1220 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('sea-fin-combat-sled', 3, 'Lower Forward Harpoon Gun', '4D6 S.D.C.', 0, '600 feet (183 m)', NULL, '48', NULL, 'The book is explicit that this is S.D.C. rather than mega-damage - the only such weapon on any vessel in this batch.'),
('sea-fin-combat-sled', 4, 'Rear Laser Turret', '3D6 M.D.', 1, '2000 feet (610 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('sea-fin-combat-sled', 5, 'Forward Sensor/Camera Turrets (2)', NULL, 0, '4000 feet (1220 m) with 10x zoom; sonar to five miles.', NULL, NULL, NULL, 'Not a weapon, but the book numbers it among the weapon systems. 360 degree rotation and twelve hours of recording.');

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is SILENT on a collision, which is exactly how a row goes missing without
-- an error, so these COUNT.
SELECT 'these vessels' AS assertion,
       count(*) AS got, 8 AS want
  FROM vehicles WHERE slug IN ('sea-snake-class-power-armor', 'man-o-war-class-power-armor', 'sea-tiger-class-power-armor', 'unicorn-scout-class-power-armor', 'merbot-power-armor', 'bottom-feeder-t-23-mini-sub', 'sea-fin-combat-sled', 'torpedo-sled-t-06');

SELECT 'their M.D.C. locations' AS assertion,
       count(*) AS got, 45 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('sea-snake-class-power-armor', 'man-o-war-class-power-armor', 'sea-tiger-class-power-armor', 'unicorn-scout-class-power-armor', 'merbot-power-armor', 'bottom-feeder-t-23-mini-sub', 'sea-fin-combat-sled', 'torpedo-sled-t-06');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 29 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('sea-snake-class-power-armor', 'man-o-war-class-power-armor', 'sea-tiger-class-power-armor', 'unicorn-scout-class-power-armor', 'merbot-power-armor', 'bottom-feeder-t-23-mini-sub', 'sea-fin-combat-sled', 'torpedo-sled-t-06');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT count(*) AS underseas_vessels FROM vehicles WHERE source_book LIKE '%Underseas%';
SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-vessels-p081-105.sql');
