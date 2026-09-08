-- Free Quebec vessels from printed pages 52-69 - combat vehicles and robots.
-- SIX rows, not seven. See the QR-2 note below.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-free-quebec-vessels-p052-069.sql
--
-- A VESSEL BELONGS TO THE SLICE ITS NAME HEADING FALLS IN - the rule the triax
-- and underseas vessel files state, and the reason no vessel is split across
-- two of these files or imported twice.
--
-- THE QR-2 ABOLISHER PRIME IS DELIBERATELY NOT A ROW. Printed 65-66 gives it a
-- heading, one paragraph of description, a height of about thirty feet, and
-- then this: "Note: For complete stats and additional information, see Rifts
-- World Book 11: Coalition War Campaign, pages 134-137." There is no Model
-- Type, no Class, no Crew, no M.D.C. by Location, no Speed, no Statistical
-- Data, no Cost and no Weapon Systems anywhere in this book. A row would carry
-- a name and NULLs, and F3's own reasoning applies exactly: a row that keeps
-- one field out of twenty is worse than no row, because it reads as complete.
-- The book points at another book; so does this comment.
--
-- PRINTED 58 IS WELDED - BOOK-INGEST-AUDIT.md F30. pymupdf returns one text
-- block whose lines alternate between the two columns, so the cached text for
-- that page does not read in order and read-columns.py cannot fix it. The
-- Glitter Boy Transport's M.D.C. footnotes live there and were read from the
-- page's word geometry instead. The de-welded reading: the single-asterisk
-- footnote and the last two M.D.C. rows are the LEFT column; the wing-damage
-- rule is the RIGHT.
--
-- THE COUGAR PRINTS TWO MAXIMUM ALTITUDES IN ONE PARENTHETICAL - "about 800
-- feet (244m; 1000 ft/305m)" - and both are stored, as printed, in speed_air.
-- Neither is dropped and neither is chosen.
--
-- THE RHV-60'S JET M.D.C. READS BACKWARDS and is stored as printed: the six
-- "small" directional jets carry 85 M.D.C. each and the six "main" hover jets
-- carry 40. That is what the page says.
--
-- THE QR-1 IS THE ONLY VESSEL IN THIS FILE WITH NO FREE QUEBEC PRICE. It gives
-- a Black Market cost and nothing else, where every other entry leads with
-- "Free Quebec Cost". The 28 million is the black market figure and cost_note
-- says so.
--
-- INSERT OR IGNORE THROUGHOUT, and the readbacks COUNT rather than trusting
-- the exit code - an IGNORE that collides is silent.
--
-- mdc_main_body is the main body ONLY. A location whose M.D.C. the book prints
-- as a RANGE carries mdc NULL and the range in mdc_note - the Cougar's top
-- weapon mount is the case.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('cougar-hover-jeep', 'QV-119 Cougar Hover Jeep', 'rifts', 'vehicle', 'Two: one pilot and one copilot/gunner.', 'Two comfortably, a third and fourth cramped. Two more can ride hanging on the rear gun mount or radio antenna, but fall off above 50 mph or on a sudden turn.', NULL, 'Maximum 220 mph (352 km); cruising 60-80 mph (96-128 km). Maximum altitude is printed as "about 800 feet (244m; 1000 ft/305m)" - two figures in one parenthetical, both recorded as printed.', 'Surface 110 mph (176 km). Submersible, though the crew needs environmental armor: 40 mph (64 km) underwater to a maximum depth of 200 feet (61 m).', 'Height: 6 feet (1.8 m); Width: 6 feet (1.8 m); Length: 14 feet (4.3 m)', '2 tons fully loaded', 228, 1500000, 'Free Quebec cost 1.5 million credits fully loaded. The black market sells the weapon-light Lynx for 1.1 million and a Cougar knock-off complete with weapon systems for 1.7 million. Good availability.', 'An open-top hover jeep used as a light infantry assault and reconnaissance vehicle across Free Quebec''s forces, and a favourite of the Recce Battalions working alongside Spider Skull Walkers on the Labradorian border. A lighter variant, the Lynx, strips the top gun, turret and missiles for speed.', 'Rifts World Book 22: Free Quebec p.53-55'),
('bobcat-hover-cycle', 'QV-229 Bobcat Hover Cycle', 'rifts', 'vehicle', 'One', NULL, NULL, 'Maximum 440 mph (704 km); cruising 80-150 mph (128-240 km). VTOL and hover capable with retractable gear; maximum altitude about 2500 feet (762 m).', 'Skims the surface at 210 mph (336 km). NOT submersible.', 'Height: 4 feet (1.2 m); Width: 4 feet (1.2 m) including wingspan; Length: 13 feet 4 inches (4 m)', '1400 lbs (630 kg)', 180, 1000000, 'Free Quebec cost one million credits. The black market sells cheap knock-offs with half the speed and altitude but similar weapons for 850,000 credits; a rebuilt Quebec vehicle runs 820,000 to 985,000 depending on repairs and appearance. Fair to poor availability for the knock-offs, rare for rebuilt models stolen from Free Quebec.', 'A rocket-cycle escort and reconnaissance vehicle built to work alongside flying power armor and Sky Cycles on long-range recon, strikes and infiltration; Free Quebec''s answer to the Coalition Rocket Cycle.', 'Rifts World Book 22: Free Quebec p.55-57'),
('gb6-96-glitter-boy-transport', 'GB6-96 Glitter Boy Transport "Sky Hawk"', 'rifts', 'vehicle', 'Four standard: pilot, co-pilot, communications officer and door gunner, plus one to five additional crew or medics in the cargo bay. The cockpit seats five.', 'Troops, deployable on landing or in mid-air, plus up to four Glitter Boys anchored to the external riding platforms.', NULL, 'On the main VTOL hover jets alone: 172 mph (277 km) at up to 3,000 feet (914 m). With the rear jets: 440 mph (704 km), cruising 80-150 mph (128-240 km), scouting at about 50 mph (80 km) or slower. Nought to 200 mph in four seconds - one melee action - and to maximum in about 7.5 seconds. Maximum altitude about 6000 feet (1829 m).', 'No amphibious capabilities.', 'Height: 16 feet (4.9 m); Width: 39 feet (11.9 m) with wings down, 27 feet (8.2 m) with wings up; the cargo bay is about 13 feet (4 m) door to door; Length: 56 feet (17 m)', 'About 4 tons (8073 lbs / 3632 kg empty)', 998, 2900000, 'Free Quebec cost 2.9 million credits with full armaments. Glitter Boy armor technology is built into strategic areas of the hull, particularly the flooring, but painted over to prevent the glitter. There are no knock-offs.', 'A heavily armored VTOL transport built to insert and extract Glitter Boy squads and support them in the field, with external riding platforms so a GB can fire from the aircraft. Also used for search and rescue, reconnaissance, border patrol and supply drops.', 'Rifts World Book 22: Free Quebec p.57-60'),
('rhv-60-reloader-hover-vehicle', 'RHV-60 Reloader Hover Vehicle', 'rifts', 'vehicle', 'A four-man Glitter Boy Reload Team: three Reloaders plus one more Reloader, Operator or Side Kick.', 'One to three more comfortably, six cramped, without using the cargo bay. The cargo bay is for evacuation and carries two Glitter Boys with half of each hanging over the sides, or 6-12 troops.', NULL, 'Maximum 180 mph (288 km); cruising 40-60 mph (64-96 km). VTOL and hover capable with retractable gear; maximum altitude about 600 feet (183 m), and it is designed to ride low.', 'Skims the surface at 80-100 mph (128-160 km). NOT submersible - it will sink like a rock unless hovering.', 'Height: 7 feet (2.1 m); Width: 12 feet (3.6 m); Length: 22 feet (6.7 m)', '4 tons fully loaded', 328, 2500000, 'Free Quebec cost 2.5 million credits fully loaded. Not available on the black market; when knock-offs appear they are likely to have 30% less M.D.C. and sell for 2.6 to 2.8 million.', 'The Glitter Boy Reload Team''s mobile workshop and hover truck: a crane, a hydraulics system, diagnostic gear and a cargo bay for ammo drums, munitions and replacement parts. It tows or carries up to 32 tons at reduced speed, and the team works from the open platform without dismounting.', 'Rifts World Book 22: Free Quebec p.60-61'),
('qr-1-enforcer-prime', 'QR-1 Enforcer Prime', 'rifts', 'robot', 'One or two', NULL, 'Running: 60 mph (96 km) maximum. Leaping: 15 feet (4.6 m) high or across, plus 10 feet (3 m) with a running start. A running leap kick does 1D4x10 M.D., ends most of the melee round, and has a 01-45% chance of knocking a giant opponent down - the pilot loses initiative the following round.', NULL, 'Walks the sea bottom at about 25% of running speed, to a maximum ocean depth of 2000 feet (610 m).', 'Height: 19 feet 7 inches (6 m); Width: 12 feet (3.6 m); Length: 7 feet 6 inches (2.3 m)', '18 tons fully loaded', 390, 28000000, 'THE ONLY VESSEL IN THIS BOOK WITH NO FREE QUEBEC PRICE - it gives a black market figure and nothing else, where every other entry leads with "Free Quebec Cost". Black market 28 million credits and up for a new, undamaged, fully powered Enforcer complete with rail gun and missiles; eight to ten million for a rebuilt unit or one without missiles and rail gun. Rarely available.', 'Free Quebec''s renamed UAR-1 Enforcer, the workhorse of urban assault and city defense. At least 400 are in active service and about thirty new units are built a month; the design is considered obsolete and is trusted anyway. Its main body is improved from the Coalition original''s 350 to 390.', 'Rifts World Book 22: Free Quebec p.63-65'),
('qr-3-guardian-robot', 'QR-3 Guardian Robot', 'rifts', 'robot', 'Two: a pilot, and a gunner/co-pilot who runs the mini-missiles and sensors and may take command of an arm.', 'A communications engineer and one passenger fit comfortably in the crew compartment.', 'Running: 100 mph (160 km) maximum, nought to 60 mph (96.5 km) in ten seconds, sustainable indefinitely. Leaping: 20 feet (6 m). A running leap kick does 2D6+4 M.D., ends most of the melee round, and has a 01-55% chance of knocking the target down.', NULL, 'Walks the sea bottom at about 25% of running speed. Maximum ocean depth is printed as "4000 feet (1219 km)" - the metric figure should read 1219 METRES, and the foot figure is the one to trust.', 'Height: 24 feet (7.3 m); Width: 16 feet (4.9 m); Length: 11 feet (3.4 m)', '14 tons fully loaded', 560, 31000000, 'Free Quebec cost 31 million credits for a new, fully loaded QR-3; exclusive to the Quebec Military. Not available on the black market or to the CS.', 'Free Quebec''s own experimental infantry assault robot, designed with ex-Northern Gun engineers and inspired by the Triax X-2500 Black Knight: a particle beam cannon on one arm, a vibro-sword and laser pod on the other, and heavy mini-missile armament for anti-armor and anti-aircraft work. Only 48 are in service with 24 under construction.', 'Rifts World Book 22: Free Quebec p.66-68');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('cougar-hover-jeep', 'Directional Hover Jets (6)', 30, 'each. Small and difficult target: called shot only, attacker -3 to strike. Destroying one reduces speed 10%, cumulative.', 1),
('cougar-hover-jeep', 'Rear Jets (2)', 85, 'each. Small and difficult target: called shot only, attacker -3 to strike. Destroying one reduces speed 20%.', 2),
('cougar-hover-jeep', 'Forward Laser Turret', 50, NULL, 3),
('cougar-hover-jeep', 'Forward Fixed Lasers (2, recessed)', 25, 'each', 4),
('cougar-hover-jeep', 'Mini-Missile Launchers (2)', 55, 'each', 5),
('cougar-hover-jeep', 'Radio and Sensor Package (1, rear left)', 20, NULL, 6),
('cougar-hover-jeep', 'Infrared Searchlights (2, hood)', 8, 'each', 7),
('cougar-hover-jeep', 'Headlights (4, small)', 4, 'each', 8),
('cougar-hover-jeep', 'Window Light (1)', 4, NULL, 9),
('cougar-hover-jeep', 'Tail Lights (2, rear)', 4, 'each', 10),
('cougar-hover-jeep', 'Top Mounted Weapon (1, rear)', NULL, 'Printed as a RANGE rather than a figure: 75-100 M.D.C., varying with the weapon mounted.', 11),
('cougar-hover-jeep', 'Retractable Canopy', 20, NULL, 12),
('cougar-hover-jeep', 'Windshield (1)', 15, NULL, 13),
('cougar-hover-jeep', 'Main Body', 228, 'Depleting the main body destroys the vehicle.', 14),
('bobcat-hover-cycle', 'Forward Laser Turret (1, front)', 35, 'Small and difficult target: called shot only, attacker -4 to strike.', 1),
('bobcat-hover-cycle', 'Mini-Missile Launchers (2, sides)', 45, 'each', 2),
('bobcat-hover-cycle', 'Rail Gun (1, undercarriage)', 50, 'Small and difficult target: called shot only, attacker -4 to strike.', 3),
('bobcat-hover-cycle', 'Front Windshield', 30, 'Small and difficult target: called shot only, attacker -4 to strike.', 4),
('bobcat-hover-cycle', 'Headlights (2, front)', 8, 'each. Small and difficult target: called shot only, attacker -4 to strike.', 5),
('bobcat-hover-cycle', 'Tail Fins (2)', 20, 'each. Small and difficult target: called shot only, attacker -4 to strike.', 6),
('bobcat-hover-cycle', 'Directional Jets (10)', 15, 'each. Small and difficult target: called shot only, attacker -4 to strike. Destroying three or more costs -15% to the piloting skill.', 7),
('bobcat-hover-cycle', 'Side/Rear/Main Jets (2)', 72, 'each. Destroying one halves speed and costs -30% to the piloting skill; destroying both means a crash.', 8),
('bobcat-hover-cycle', 'Main Body', 180, 'Depleting the main body destroys the vehicle.', 9),
('gb6-96-glitter-boy-transport', 'Forward Laser Turret (1, top of cockpit)', 70, 'Small and difficult target: called shot only, attacker -3 to strike.', 1),
('gb6-96-glitter-boy-transport', 'Mini-Missile Launchers (2, top of rear thrusters)', 100, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 2),
('gb6-96-glitter-boy-transport', 'Sensor Array (1, left side near the nose)', 120, 'Small and difficult target: called shot only, attacker -3 to strike.', 3),
('gb6-96-glitter-boy-transport', 'Sliding Doors (2)', 120, 'each', 4),
('gb6-96-glitter-boy-transport', 'Cockpit Doors (2)', 75, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 5),
('gb6-96-glitter-boy-transport', 'Glitter Boy Riding Platforms (2)', 125, 'each', 6),
('gb6-96-glitter-boy-transport', 'Headlights (2, underside of the nose)', 8, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 7),
('gb6-96-glitter-boy-transport', 'Wings (2, rear)', 200, 'each. Small and difficult target: called shot only, attacker -3 to strike. Destroying one wing reduces speed 10% and costs -20% to the piloting skill; destroying both caps speed at 172 mph (277 km) and costs a further -15%.', 8),
('gb6-96-glitter-boy-transport', 'Directional Jets (10)', 15, 'each. Small and difficult target: called shot only, attacker -3 to strike. Destroying six or more costs -5% to the piloting skill.', 9),
('gb6-96-glitter-boy-transport', 'VTOL Circular Jets (2, front and rear)', 200, 'each. Small and difficult target: called shot only, attacker -3 to strike. Destroying one reduces speed 15% and costs -10% to VTOL handling; destroying both reduces speed 30% and makes VTOL impossible.', 10),
('gb6-96-glitter-boy-transport', 'Side/Rear/Main Jets (2)', 290, 'each. Destroying one reduces speed 25% and costs -20% to the piloting skill; destroying both caps speed at about 150 mph and costs a further -20%.', 11),
('gb6-96-glitter-boy-transport', 'Pilot''s Cockpit/Nose area', 220, 'Destroying the nose and pilot section sends the aircraft crashing down.', 12),
('gb6-96-glitter-boy-transport', 'Inner Reinforced Cockpit Compartment', 100, NULL, 13),
('gb6-96-glitter-boy-transport', 'Main Body (cargo bay to rear)', 998, 'Depleting the main body destroys the vehicle. This row and the one above it were read from printed 58''s word geometry: that page is welded across the gutter, BOOK-INGEST-AUDIT.md F30.', 14),
('rhv-60-reloader-hover-vehicle', 'Main Hover Jets (6, undercarriage)', 40, 'each. Small and difficult target: called shot only, attacker -3 to strike. Destroying one costs 10% speed and -5% to the piloting skill, cumulative.', 1),
('rhv-60-reloader-hover-vehicle', 'Small Directional Jets (6, underbelly)', 85, 'each. AS PRINTED, and it reads backwards: the "small" directional jets carry more than twice the M.D.C. of the "main" hover jets above. Small and difficult target: called shot only, attacker -3 to strike. Destroying two or more costs 5% speed, cumulative.', 2),
('rhv-60-reloader-hover-vehicle', 'Winch (2, front and back)', 15, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 3),
('rhv-60-reloader-hover-vehicle', 'Radio Antenna (1, front)', 8, 'Small and difficult target: called shot only, attacker -3 to strike.', 4),
('rhv-60-reloader-hover-vehicle', 'Headlights (4, concealed, retractable)', 4, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 5),
('rhv-60-reloader-hover-vehicle', 'Tail Lights (4, rear)', 4, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 6),
('rhv-60-reloader-hover-vehicle', 'Dashboard (1, inside)', 80, 'Small and difficult target: called shot only, attacker -3 to strike.', 7),
('rhv-60-reloader-hover-vehicle', 'Pop-up Mini-Crane (1, left or right side)', 80, NULL, 8),
('rhv-60-reloader-hover-vehicle', 'Pop-Top Removable Cargo Bay Cover/Canopy', 25, NULL, 9),
('rhv-60-reloader-hover-vehicle', 'Doors (4)', 65, 'each', 10),
('rhv-60-reloader-hover-vehicle', 'Tailgate (1)', 80, NULL, 11),
('rhv-60-reloader-hover-vehicle', 'Windshield (1)', 25, NULL, 12),
('rhv-60-reloader-hover-vehicle', 'Main Body', 328, 'Depleting the main body destroys the vehicle.', 13),
('qr-1-enforcer-prime', 'Right Shoulder Rail Gun', 100, 'shielded', 1),
('qr-1-enforcer-prime', 'Left Shoulder Medium Range Missile Launcher', 150, NULL, 2),
('qr-1-enforcer-prime', 'Shoulder Mounted Laser Turrets (2)', 50, 'each', 3),
('qr-1-enforcer-prime', 'Shoulder Missile Launchers (2)', 60, 'each', 4),
('qr-1-enforcer-prime', 'Waist Mini-Missile Turret', 25, 'Printed as "25 each" although only one turret is named - the "each" appears to be a leftover. Recorded as printed.', 5),
('qr-1-enforcer-prime', 'Right Leg Smoke/Gas Dispenser', 25, NULL, 6),
('qr-1-enforcer-prime', 'Chest Spotlight and Video Camera', 10, 'Destroyed automatically once the main body has taken 200 or more points.', 7),
('qr-1-enforcer-prime', 'Sensor Turret (left shoulder)', 50, 'Destroying it eliminates radar and targeting. Small and difficult target: called shot only, attacker -2 to strike.', 8),
('qr-1-enforcer-prime', 'Head', 100, NULL, 9),
('qr-1-enforcer-prime', 'Arms (2)', 150, 'each', 10),
('qr-1-enforcer-prime', 'Hands (2)', 75, 'each', 11),
('qr-1-enforcer-prime', 'Legs (2)', 200, 'each', 12),
('qr-1-enforcer-prime', 'Reinforced Pilot''s Compartment', 100, NULL, 13),
('qr-1-enforcer-prime', 'Main Body', 390, 'Depleting the main body shuts the robot down. Improved from the Coalition UAR-1''s 350.', 14),
('qr-3-guardian-robot', 'Head/Sensor Cluster', 120, 'Destroying the head eliminates all optics and sensors and every robot combat bonus. A small and difficult target sitting between the shoulder launchers: called shot only, attacker -3 to strike.', 1),
('qr-3-guardian-robot', 'Hands (2)', 80, 'each', 2),
('qr-3-guardian-robot', 'Left Arm (Particle Beam Cannon)', 185, NULL, 3),
('qr-3-guardian-robot', 'Right Arm (Vibro-Blade/Laser)', 160, NULL, 4),
('qr-3-guardian-robot', 'Upper Arms (2)', 150, 'each', 5),
('qr-3-guardian-robot', 'Shoulders/Missile Pods (2)', 180, 'each', 6),
('qr-3-guardian-robot', 'Folding Missile Launchers (2, back)', 110, 'each. The weapon-systems heading calls these "(1, back)" while this table and the prose both say two - a printing inconsistency, recorded rather than resolved.', 7),
('qr-3-guardian-robot', 'Legs (2)', 220, 'each', 8),
('qr-3-guardian-robot', 'Leg Missile Pods (2)', 40, 'each', 9),
('qr-3-guardian-robot', 'Reinforced Pilot''s Compartment', 100, NULL, 10),
('qr-3-guardian-robot', 'Main Body', 560, 'Depleting the main body shuts the robot down.', 11);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire,
   payload, bonus, note)
VALUES
('cougar-hover-jeep', 1, 'Nose Laser Turret (1)', '2D6 M.D. per single pulse, or 6D6 M.D. per triple pulse (counts as two melee attacks)', 1, '2000 feet (610 m)', 'Equal to the pilot or gunner''s hand to hand attacks, usually four to six', 'Effectively unlimited', NULL, NULL),
('cougar-hover-jeep', 2, 'Forward Lasers (2, recessed)', '2D6 M.D. single, or 4D6 M.D. as a dual blast counting as one melee attack', 1, '2000 feet (610 m)', 'Equal to the pilot or gunner''s hand to hand attacks, usually four to six', 'Effectively unlimited', NULL, NULL),
('cougar-hover-jeep', 3, 'Mini-Missile Launchers (2)', 'Fragmentation 5D6 M.D., or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three, four or six', '24 total, twelve per launcher; about two minutes to reload a launcher', NULL, 'The book prints the secondary purpose as "And-Armor", which is a typesetting slip for Anti-Armor.'),
('cougar-hover-jeep', 4, 'Modular Weapon Mount (1, top)', 'Varies with the weapon fitted - a rail gun, a Q2-30, a mini-missile launcher, a Glitter Boy energy weapon or an S.D.C. machinegun. Usually 6D6 M.D. or better per blast.', 1, 'Usually 3000-4000 feet (914-1220 m)', 'Equal to the gunner''s hand to hand attacks', 'Effectively unlimited', NULL, 'This is the location the M.D.C. table prints as a range, 75-100, rather than a figure.'),
('cougar-hover-jeep', 5, 'Special Features of Note', NULL, 0, 'Radar identifies 72 and tracks 32 targets at 30 miles (48 km). Long-range radio 500 miles (800 km), short-range 10 miles (16 km). ECM covers a 100 mile (160 km) radius. Infrared searchlights reach 1000 feet (305 m).', NULL, NULL, '+1 on initiative and +1 to strike from the laser targeting system, LONG RANGE ONLY', 'Not a weapon. Combat computer, radar, laser targeting, long and short-range radio with an 80 decibel loudspeaker, ECM, voice-actuated locking on a six-digit code with a manual override taking about a minute, and infrared searchlights rotating 300 degrees through a 30 degree arc.'),
('bobcat-hover-cycle', 1, 'QL-22 Double-Barreled Laser Turret', '3D6 M.D. single, or 6D6 M.D. as a dual blast', 1, '2000 feet (610 m)', 'Equal to the combined hand to hand attacks of the pilot, usually four to six', 'Effectively unlimited', NULL, NULL),
('bobcat-hover-cycle', 2, 'Light Rail Gun (1)', 'Typically 4D6 M.D. to 1D4x10 M.D.', 1, '4000 feet (1220 m)', 'Equal to the combined hand to hand attacks of the pilot, usually four to six', '4,000 round drum, 100 to 200 bursts; about ten minutes to reload untrained, four minutes trained', NULL, NULL),
('bobcat-hover-cycle', 3, 'QR-10 Concealed Mini-Missile Launchers (2)', 'Fragmentation 5D6 M.D., or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three, four or five', '20 total, ten per launcher', NULL, NULL),
('bobcat-hover-cycle', 4, 'Sensor Systems of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. Long and short-range radio, short-range radar and targeting systems.'),
('bobcat-hover-cycle', 5, 'Combat Bonuses', NULL, 0, NULL, NULL, NULL, 'An Elite RPA SAMAS pilot or an RPA "Fly Boy" gets +2 on initiative and two additional attacks per melee round', 'Not a weapon. A pilot-skill bonus the book prints inside the weapon list.'),
('gb6-96-glitter-boy-transport', 1, 'QL-22 Double-Barreled Laser Turret', '3D6 M.D. single, or 6D6 M.D. as a dual blast', 1, '2000 feet (610 m)', 'Equal to the combined hand to hand attacks of the gunner, usually four to six', 'Effectively unlimited', NULL, NULL),
('gb6-96-glitter-boy-transport', 2, 'Concealed Mini-Missile Launchers (2)', 'Fragmentation 5D6 M.D., or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three, four or five', '48 total, 24 per launcher', NULL, NULL),
('gb6-96-glitter-boy-transport', 3, 'Optional use of one to six Gunners', NULL, 0, NULL, NULL, NULL, NULL, 'Not a conventional weapon. Up to four Glitter Boys ride the running boards and up to two more serve as door gunners. Firing Boom Guns from the platforms costs -10% to the piloting skill, which the design partly compensates for. The platforms can instead mount mini-missile launchers of twelve each or rail guns of 100 bursts, or one short or medium missile per platform plus two more per wing, which is rarely done.'),
('gb6-96-glitter-boy-transport', 4, 'Optional: Troops', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The cargo bay carries troops for deployment on landing or in mid-air.'),
('gb6-96-glitter-boy-transport', 5, 'Combat Bonuses', NULL, 0, NULL, NULL, NULL, 'An Elite RPA SAMAS pilot or Fly Boy gets +2 on initiative, +1 to strike with the built-in weapons, +2 to dodge, one additional action per melee, and halves the penalties for evasive piloting', 'Not a weapon. A pilot-skill bonus the book prints inside the weapon list.'),
('gb6-96-glitter-boy-transport', 6, 'Features of Note', NULL, 0, 'Radar identifies 72 and tracks 32 targets at 30 miles (48 km). Long-range radio 500 miles (800 km), short-range 10 miles (16 km). ECM covers a 100 mile (160 km) radius and traces transmissions and homing beacons. The searchlight reaches 1000 feet (305 m).', NULL, NULL, '+1 on initiative and +1 to strike from laser targeting, LONG RANGE ONLY', 'Not a weapon. Folding wings, sliding side doors with door-gunner harnesses, Glitter Boy running-board platforms taking four anchored GBs or one to four firing from the platform - not recommended above 300 mph - a combat computer, radar, laser targeting, radio, ECM, voice-actuated locking on a six-digit code, and a searchlight rotating 360 degrees through a 180 degree arc. The book prints "Also has also has a directional, short-range radio", which is its own duplication.'),
('rhv-60-reloader-hover-vehicle', 1, 'None', NULL, 0, NULL, NULL, NULL, NULL, 'The book prints this outright: "Weapon Systems: None. Remember, Reload Teams typically service and maintain Glitter Boys, so they are partners with these walking tanks." Recorded as a row so the absence reads as the book''s decision rather than as a gap in the extraction.'),
('qr-1-enforcer-prime', 1, 'C-50R Enforcer Rail Gun (1)', 'A burst of 80 rounds does 1D6x10 M.D.; a single round does 1D6 M.D.', 1, '4000 feet (1200 m) maximum', 'Equal to the combined hand to hand attacks of the gunner, usually six to eight', '20,000 round drum, 250 bursts; about fifteen minutes to reload untrained, five minutes trained', NULL, 'The gun weighs 700 lbs (315 kg).'),
('qr-1-enforcer-prime', 2, 'CR-6 Medium-Range Rocket Launcher', 'High explosive 2D6x10 M.D., plasma 2D6x10 M.D., or a multi-warhead smart bomb at 2D4x10 M.D.', 1, '40 to 80 miles (64-128 km)', 'One at a time, or volleys of two, three or four', 'Six', '+5 to strike with the multi-warhead smart bomb', NULL),
('qr-1-enforcer-prime', 3, 'CR-10 Short-Range Rocket Launchers (2)', 'Armor piercing, high explosive or plasma, all at 1D6x10 M.D.', 1, 'About two miles (3.2 km)', 'One at a time, or volleys of two, three or four', '10 total, five per shoulder', NULL, NULL),
('qr-1-enforcer-prime', 4, 'CR-20 Mini-Missile Turret', 'Fragmentation 5D6 M.D., or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three or four', '20', NULL, NULL),
('qr-1-enforcer-prime', 5, 'CR-2T Laser Turrets (2)', '2D6 M.D. from one, or 4D6 M.D. from both simultaneously', 1, '4000 feet (1200 m)', 'Equal to the combined hand to hand attacks of the gunner, usually six to eight', 'Effectively unlimited', NULL, NULL),
('qr-1-enforcer-prime', 6, 'Smoke Dispenser', 'None; covers an 80 foot (24 m) area. Tear gas can be released instead.', 0, '80 foot (24 m) area', NULL, 'Five total, typically three smoke and two tear gas', NULL, NULL),
('qr-1-enforcer-prime', 7, 'Hand to Hand Combat', NULL, 0, NULL, NULL, NULL, NULL, 'Not a ranged weapon. The pilot may fight in Mega-Damage hand to hand under the Robot Combat Training rules.'),
('qr-1-enforcer-prime', 8, 'Sensors and Features of Note', NULL, 0, 'Thermo-imager 2000 feet (610 m); infrared searchlights in the head 500 feet (152 m).', NULL, NULL, '+1 to strike, LONG RANGE ONLY', 'Not a weapon. Thermo-imager, infrared and ultraviolet optics, head-mounted infrared searchlights, and a nightvision and video camera system.'),
('qr-3-guardian-robot', 1, 'GP-03 Particle Beam Cannon (1, left arm)', '1D6x10+10 M.D. per blast', 1, '2000 feet (610 m) effective', 'Equal to the pilot or gunner''s hand to hand attacks, usually six to eight; each shot is one melee action', '60 shots, recharging one shot every three minutes - twenty an hour', NULL, NULL),
('qr-3-guardian-robot', 2, 'Forearm Laser Turret (1, right arm)', '4D6 M.D. per single blast', 1, '2000 feet (610 m)', 'Equal to the pilot or gunner''s hand to hand attacks, usually six to eight', 'Effectively unlimited', NULL, NULL),
('qr-3-guardian-robot', 3, 'Vibro-Blade (1, right arm)', '4D6 M.D. per strike', 1, 'About 14 feet (4.2 m) of reach', 'Equal to the gunner''s hand to hand attacks, usually six to eight', NULL, NULL, NULL),
('qr-3-guardian-robot', 4, 'Folding Missile Launchers (2, back)', 'Two interchangeable loadouts, only one fitted at a time. Medium-range: high explosive 3D6x10 M.D., plasma 4D6x10 M.D., or a smart bomb at 5D6x10 M.D. Mini-missiles: typically armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D., with four to six smoke.', 1, 'Medium-range 40 to 80 miles (64-128 km); mini-missiles about one mile (1.6 km)', 'One at a time, or volleys of two, three or four', 'Medium-range 8 total, four per launcher. Mini-missiles 48 total, 24 per launcher, though only twelve are exposed at a time.', '+5 to strike with the smart bomb', 'The weapon-systems heading calls these "(1, back)" while the M.D.C. table and the prose both say two.'),
('qr-3-guardian-robot', 5, 'Mini-Missile Shoulder Launchers', 'Fragmentation 5D6 M.D. to a 20 foot (6 m) radius, and/or armor piercing 1D4x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three, four or eight', '16 total, eight per shoulder', NULL, NULL),
('qr-3-guardian-robot', 6, 'Leg Mini-Missile Launchers (2, lower leg)', 'The book says "same basic stats as those listed above" - typically armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three or four', '20 total, ten per leg', NULL, NULL),
('qr-3-guardian-robot', 7, 'Hand to Hand Combat', 'Restrained punch 1D4 M.D.; full punch, elbow or knee 2D6 M.D.; power punch 4D6 M.D. counting as two attacks; vibro-sword 4D6 M.D.; tear or pry 1D4 M.D.; kick 2D4 M.D.; running leap kick 2D6+4 M.D.; body block or tackle 2D4 M.D.; stomp 1D4 M.D. against objects under ten feet only.', 1, 'Reach', 'Its own Elite Robot Combat Training gives an extra hand to hand attack at levels 1, 4, 8 and 13', NULL, '+3 to roll with impact, +1 on initiative, +1 to strike in hand to hand, +2 to parry, +2 to dodge, +4 to pull punch', 'Not a ranged weapon. The QR-3 has its own Elite Robot Combat Training rather than the general rules.'),
('qr-3-guardian-robot', 8, 'Sensory Systems of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The book says only "standard for robots" and gives no further detail.');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got_vessels FROM vehicles
 WHERE source_book LIKE 'Rifts World Book 22: Free Quebec%';
SELECT count(*) AS got_locations FROM vehicle_locations
 WHERE vehicle_slug IN ('cougar-hover-jeep', 'bobcat-hover-cycle',
   'gb6-96-glitter-boy-transport', 'rhv-60-reloader-hover-vehicle',
   'qr-1-enforcer-prime');
SELECT count(*) AS got_weapons FROM vehicle_weapons
 WHERE vehicle_slug IN ('cougar-hover-jeep', 'bobcat-hover-cycle',
   'gb6-96-glitter-boy-transport', 'rhv-60-reloader-hover-vehicle',
   'qr-1-enforcer-prime');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-free-quebec-vessels-p052-069.sql');
