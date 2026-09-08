-- Free Quebec vessels from printed pages 124-134 - the Quebec Navy chapter.
-- Two rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-free-quebec-vessels-p124-134.sql
--
-- A VESSEL BELONGS TO THE SLICE ITS NAME HEADING FALLS IN - the rule the triax
-- and underseas vessel files state, and the reason no vessel is split across
-- two of these files or imported twice. The Leviathan cyborg's combat and
-- damage tail runs onto printed 124 and is NOT here: its heading is on printed
-- 121, so it belongs to the p105-123 file.
--
-- THE WHOLE CHAPTER WAS SWEPT, not just the two entries that were expected.
-- Printed 124-134 holds exactly two stat blocks. Printed 128 carries a
-- "Quebec Navy Resources" roster naming a dozen craft - the CSS Orca-Class
-- Attack Sub, the CSN Mark I Barracuda Patrol Boat, the IHA Sea King Guided
-- Missile Cruiser and others - and NOT ONE of them has an M.D.C. by Location
-- or any stat block. They are name-only cross-references into Rifts
-- Sourcebook 4: Coalition Navy and Rifts Underseas. Nothing to extract.
-- Printed 127-128 is Commodore Jacques LeFevre, a named NPC rather than a
-- vessel; his flagship the FQS Redeemer is named in prose and never statted.
--
-- PRINTED 131 IS BLANK - a full-page illustration, like printed 37 in the
-- class chapter. The Sea Dragon's stat block runs 130 -> 132 across it, which
-- is an ordinary internal page break and not damage.
--
-- THE NS-B20 HAS NO PRINTED COST and stores NULL, which is a finished row
-- rather than an unfinished one - see the gear.cost comment in db/schema.sql,
-- which the vehicles.cost comment points at. Confirmed absent by reading the
-- whole entry, not inferred from a failed grep.
--
-- BOTH WEIGHTS ARE PRINTED IN POUNDS, not tons, and are stored as the book
-- prints them: weight_tons is TEXT precisely so a book that does not use tons
-- can still be recorded rather than converted.
--
-- THE SEA DRAGON'S VIBRO-BLADE FINS DISAGREE WITH THEMSELVES and it is
-- recorded rather than resolved: the formal weapon line reads 1D6+2 M.D.
-- while the descriptive sentence two lines above reads "A single blade does
-- 1D6 M.D. and double blades do 2D6 M.D." - the identical phrasing the NS-B20
-- uses for its own fins. Both are in the weapon's note. A guess at which the
-- author meant would be indistinguishable from a number the book gave.
--
-- INSERT OR IGNORE THROUGHOUT, and the readbacks COUNT rather than trusting
-- the exit code - an IGNORE that collides is silent.
--
-- mdc_main_body is the main body ONLY. The full printed block is in
-- vehicle_locations, main body included, so it can be rendered in the order
-- the book sets it; a reader wanting a total must sum the rows.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('ns-b20-borg-dive-armor', 'NS-B20 Borg Dive Armor', 'rifts', 'power-armor', 'One cyborg; the armor is sized to the Borg body that wears it', NULL, 'Mobility is excellent underwater and poor on dry land: -10% to Climb and -15% to Prowl, Acrobatics and similar physical skills.', NULL, 'Built-in medium propulsion system: 20 mph (32 km or 17 knots) underwater and 30 mph (48 km or 26 knots) on the surface. Maximum depth 1200 feet (366 m).', 'Size: human equivalent, 6-9 feet (1.8 to 2.7 m)', '145 lbs (65 kg)', 290, NULL, 'NO COST IS PRINTED. The entry gives no price line at all - confirmed by reading the whole entry rather than inferred from a failed search. Issued rather than sold.', 'Dive armor issued to Free Quebec Navy cyborgs so they can work past the depth limit of a standard bionic body, extending safe depth to 1200 feet (366 m) with built-in pressure and oxygen features and a propulsion system. A partial conversion cyborg gets half the benefit.', 'Rifts World Book 22: Free Quebec p.129'),
('sea-dragon-power-armor', 'Sea Dragon Power Armor (QPA-10)', 'rifts', 'power-armor', 'One', NULL, 'Running: 60 mph (96 km) maximum; running does tire the operator, but at 10% the usual fatigue rate thanks to the robot exoskeleton. Leaping: 15 feet (4.6 m) high or across unassisted; jet assisted leap up to 200 feet (61 m) high and 300 feet (91.5 m) across without attaining flight.', 'Hover-jet propulsion: hovers stationary up to 100 feet (30.5 m) and flies short distances. Maximum flight speed 100 mph (160 km), cruising 50 mph (80 km), maximum altitude about 200 feet (61 m) over land or water - and it is wobbly, having no wings. Overheats and must cool after two hours above cruising speed, or five hours at cruising speed or less.', '55 mph (88 km or 47 knots) underwater, or 80 mph (128 km or 69 knots) skipping across the surface. Withstands pressure to 4400 feet (1341 m) deep. The book compares it directly: the CS Sea SAMAS manages 60 mph (96 km or 51.6 knots) on the surface.', 'Height: 10 feet (3 m); Width: 4 feet 6 inches (1.35 m), no wings; Length: 4 feet (1.2 m)', '600 lbs (270 kg)', 300, 2300000, 'Free Quebec cost 2.3 million credits; worth twice that on the open market.', 'A one-man underwater combat suit derived from the SAMAS chassis with the wings removed, built for the Free Quebec Navy: deep-sea assault, anti-ship and anti-submarine raids, escort, amphibious attack, and rescue and salvage work. Nearly 2,000 were built, and the book says it inspired the Coalition''s own Sea SAMAS.', 'Rifts World Book 22: Free Quebec p.130-132');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('ns-b20-borg-dive-armor', 'Head/Helmet', 70, NULL, 1),
('ns-b20-borg-dive-armor', 'Arms (2)', 65, 'each', 2),
('ns-b20-borg-dive-armor', 'Legs (2)', 110, 'each', 3),
('ns-b20-borg-dive-armor', 'Main Body', 290, NULL, 4),
('sea-dragon-power-armor', 'Arms (2)', 100, 'each', 1),
('sea-dragon-power-armor', 'Legs (2)', 150, 'each', 2),
('sea-dragon-power-armor', 'Underwater Propulsion System/Hover Pack', 90, NULL, 3),
('sea-dragon-power-armor', 'Main Jets (2)', 100, 'each. Small and difficult target: a called shot only, and the attacker is still -3 to strike.', 4),
('sea-dragon-power-armor', 'Ammo Drum (1; rear)', 50, NULL, 5),
('sea-dragon-power-armor', 'Laser Cannon (1, hand-held)', 100, NULL, 6),
('sea-dragon-power-armor', 'Ion Blaster (1; concealed in the left arm)', 25, 'Small and difficult target: a called shot only, and the attacker is still -3 to strike.', 7),
('sea-dragon-power-armor', 'Shoulder Mini-Missile Launchers (2)', 50, 'each', 8),
('sea-dragon-power-armor', 'Forearm and Lower Leg Vibro-Blades (4)', 50, 'each. Small and difficult target: a called shot only, and the attacker is still -3 to strike.', 9),
('sea-dragon-power-armor', 'Head', 100, 'Small and difficult target: a called shot only, and the attacker is still -3 to strike. Destroying it eliminates every optical and sensory system including sonar, leaving the pilot on human vision and senses alone and losing all strike, parry and dodge bonuses. Underwater it also risks drowning or decompression: most suits carry an emergency mini-air tank holding about eight minutes of air, and many pilots have a bionic lung and air supply of their own. Decompression is a risk below 300 feet (91 m).', 10),
('sea-dragon-power-armor', 'Main Body', 300, 'Depleting the main body shuts the armor down completely and sends it sinking.', 11);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire,
   payload, bonus, note)
VALUES
('ns-b20-borg-dive-armor', 1, 'Underwater Propulsion System', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. Carries the armor at 20 mph (32 km) underwater and 30 mph (48 km) on the surface, to a maximum depth of 1200 feet (366 m). Recorded here because the book numbers it among the armor''s systems.'),
('ns-b20-borg-dive-armor', 2, 'Vibro-Blade "Fins" (shoulders, forearms, knees)', 'A single blade does 1D6 M.D.; double blades do 2D6 M.D.', 1, 'Within reach', 'Equal to the wearer''s hand to hand attacks', NULL, NULL, 'Aquatic animals can detect the vibro-field up to 2 miles (3.2 km) away, which makes the blades a liability on a stealth approach.'),
('ns-b20-borg-dive-armor', 3, 'Depth gauge and gyro-system', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. A head-up display feature, numbered by the book among the armor''s systems.'),
('sea-dragon-power-armor', 1, 'QN-60 Variable Beam Laser Cannon (1, hand-held)', '5D6 M.D. per blast', 1, '2000 feet (610 m) underwater, 4000 feet (1220 m) on land', 'Equal to the combined hand to hand attacks of the pilot, usually six to eight', 'Effectively unlimited', NULL, 'Fires an ordinary laser beam on the surface and a blue-green beam underwater. A standard rail gun can be carried instead.'),
('sea-dragon-power-armor', 2, 'Ion Forearm Gun (1, left arm)', '4D6 M.D. per blast', 1, '1000 feet (305 m); half that underwater', 'Equal to the combined hand to hand attacks of the pilot, usually six to eight', 'Effectively unlimited, drawn from the armor''s own power supply', NULL, NULL),
('sea-dragon-power-armor', 3, 'CM-4 Shoulder Mini-Missile Launchers (2)', 'Varies with the missile. Standard issue is armor piercing at 1D4x10 M.D. or plasma at 1D6x10 M.D.; any mini-torpedo may be substituted.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two or four', '16 total, eight per launcher', NULL, NULL),
('sea-dragon-power-armor', 4, 'Electro-Spear', 'Blade or spearhead 1D6 M.D. stabbing or slashing; the blunt end does 2D4 S.D.C. as a club. An electrical blast into an impaled victim does 2D6 M.D. A long-range electrical bolt does 1D6 M.D. on land, or 1D6+6 M.D. underwater to the primary target plus 1 M.D. to everything within 50 feet (15.2 m) of the armor.', 1, 'Hand-held. The electrical blast reaches 20 feet (6 m) on land or 50 feet (15.2 m) underwater.', 'Equal to the combined hand to hand attacks of the pilot, usually six to eight', 'Effectively unlimited for the electrical blasts', NULL, 'The underwater splash damage is the water conducting the charge; the Sea Dragon itself is insulated against it.'),
('sea-dragon-power-armor', 5, 'Vibro-Blade "Fins" (forearms and lower legs)', 'THE BOOK PRINTS TWO DIFFERENT FIGURES. The formal weapon line reads 1D6+2 M.D.; the descriptive sentence two lines above it reads "A single blade does 1D6 M.D. and double blades do 2D6 M.D.", which is the identical phrasing the NS-B20 uses for its own fins.', 1, 'Within reach', 'Equal to the combined hand to hand attacks of the pilot, usually six to eight', NULL, NULL, 'Primary purpose: self-defense, parrying and cutting. The damage disagreement is recorded rather than resolved - a guess at which the author meant would be indistinguishable from a number the book gave.'),
('sea-dragon-power-armor', 6, 'Energy Rifles and other normal weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Substitutable as a backup or in an emergency, but space and bulk limit the pilot to one. No stats printed; use the weapon''s own.'),
('sea-dragon-power-armor', 7, 'Hand to Hand Combat', NULL, 0, NULL, NULL, NULL, '+1 on initiative, +1 to parry, +2 to dodge underwater', 'Standard Power Armor Combat Training, Rifts RPG p.45, plus the underwater bonuses above.'),
('sea-dragon-power-armor', 8, 'Sensor System Note', NULL, 0, 'Sonar reaches 15 miles (24 km) and tracks 32 targets', NULL, NULL, '+2 to strike and +1 to dodge, LONG RANGE ONLY', 'Not a weapon. Full optical package - laser targeting, telescopic, passive nightvision, thermo-imaging, infrared, ultraviolet and polarization - plus sonar and a depth and pressure gauge.');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got_vessels FROM vehicles
 WHERE source_book LIKE 'Rifts World Book 22: Free Quebec%';
SELECT count(*) AS got_locations FROM vehicle_locations
 WHERE vehicle_slug IN ('ns-b20-borg-dive-armor', 'sea-dragon-power-armor');
SELECT count(*) AS got_weapons FROM vehicle_weapons
 WHERE vehicle_slug IN ('ns-b20-borg-dive-armor', 'sea-dragon-power-armor');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-free-quebec-vessels-p124-134.sql');
