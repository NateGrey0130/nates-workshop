-- Rifts World Book 2: Atlantis - its 20 power armors, drones, robots,
-- vehicles and flying ships, with 133 M.D.C. locations and 38 weapon-system entries.
--
--   Kittani, printed 138-158: K-Universal, Serpent, Equestrian and Manling
--     power armor; ABSS-2, ABS-3 and ABW-4 drones; Insecton and Creax rovers;
--     the Dragon Dreadnought; the K-ATV Hover Jet, two land skimmers, the land
--     and water skimmer and the KM-700 uni-motorcycle
--   Splugorth, printed 154-155: the flying ships, one row per printed size
--   Bio-wizardry, printed 124-125: the Eylor Slave Barge
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-atlantis-vehicles.sql
--
-- ALL 20 ARE NEW. The catalog's Kittani and Splugorth vehicles come from
-- Underseas, South America and Africa; none of these names or slugs exists.
--
-- READ FROM A SCAN, every M.D.C. table and weapon block off a render by
-- book-extract-worker. Printed 150-151 are full-page art; the Dragon
-- Dreadnought's weapon list runs from 149 to 152, so its citation names both.
-- Printed 157 interleaves two skimmers in the OCR; both were read off the
-- render, which also shows the K-GTV model as K-HV (the OCR says K-HV LW).
--
-- BOOK SLIPS, stored as printed: the Creax carries the Insecton's model code;
-- the KM-700's stat block is headed "The K-GTV Motorcycle"; the Slave Barge's
-- price is printed "50 million (?)" (cost NULL, cost_note says so).
--
-- PRICES: the Kittani armor is never sold; cost is the low end of what the
-- Kittani could get and cost_note gives the rest. The Dreadnought's
-- 200-billion figure is hypothetical, so cost is NULL.
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book)
VALUES
  ('k-universal-light-power-armor', 'K-Universal Light Power Armor (Kittani UPA)', 'rifts', 'power-armor', 1, NULL, 'Running 40 mph (64 km) maximum, or leap-running at 170 mph (272 km); leaping about 50 ft (15 m) high in a power jump, power jumps up to 300 ft (91.5 m) up or across', 'Hover to 300 ft altitude; maximum 100 mph (160 km); no more than 30 minutes of continuous flight before the jets overheat', NULL, 'Height 8 ft (2.4 m); Width 4.4 ft (1.34 m); Length about 3 ft (0.9 m)', '200 lbs (90 kg) with jet pack', 220, 1600000, 'Complete with jet pack.', 'A light Kittani environmental exo-skeleton with a rear jet pack, P.S. 30, nuclear powered (about 10 years). It has no built-in weapons; the wearer carries a hand weapon. Full optics (laser targeting, telescopic, passive nightvision, thermo-imaging, infrared, ultraviolet, polarization). Bonuses: +1 to strike (long range only), +1 to parry and dodge, +2 to dodge while power-jumping.', 'Rifts World Book 2: Atlantis p.138-140'),
  ('kittani-serpent-power-armor', 'Kittani Serpent Power Armor (SPA)', 'rifts', 'power-armor', 1, NULL, 'Running, slithering or swimming 40 mph (64 km) maximum; cannot leap, but lunges about 40 ft long or 30 ft high', 'Not possible', '40 mph (64 km)', 'Height 9 to 12 ft (2.7 to 3.6 m); Length 30 ft (9 m); Width 6 ft (1.8 m)', '1 ton', 375, 20000000, 'Never sold. The Kittani could get 20 to 30 million credits a unit; the Coalition or Triax would pay 50 to 100 million.', 'Heavy Kittani infantry armor with a humanoid upper body on a 30-foot serpent tail, P.S. 46, nuclear powered (20 years). Hand to hand: +2 attacks per melee, +2 initiative, +2 to strike and parry, +3 automatic dodge, +2 normal dodge, +2 to roll with impact. May substitute one hand-held weapon. Full optics; +2 to strike at long range.', 'Rifts World Book 2: Atlantis p.139-141'),
  ('kittani-equestrian-power-armor', 'Kittani Equestrian Power Armor (EPA)', 'rifts', 'power-armor', 1, NULL, 'Running 144 mph (230 km) maximum, cruising 60 mph (96 km); leaping 40 ft (12.2 m) from a standstill, 60 ft high or 120 ft long running, 200 ft (61 m) long thrust-assisted', 'Not possible (thrusters for stability, space and underwater only)', NULL, 'Height 12 ft (3.6 m) at the shoulder, about 17 ft (5.2 m) to the top of the pilot; Width 9 ft (2.7 m) with turrets; Length 19 ft (5.9 m)', '3 tons', 375, 30000000, 'Never sold. The Kittani could get 30 to 50 million credits; the Coalition or Triax would pay 60 to 100 million.', 'A Kittani centaur: a humanoid armored pilot (as the Manling) on a robot horse body, P.S. 60, nuclear powered (about 20 years), with a small cargo area and weapon bin. Hand to hand: +1 attack per melee, +2 to strike with kicks, +1 parry, +2 dodge. Full optics, motion and heat detection, radar; +2 to strike at long range.', 'Rifts World Book 2: Atlantis p.141-143'),
  ('kittani-manling-power-armor', 'Kittani Manling Power Armor (MPA)', 'rifts', 'power-armor', 1, NULL, 'Running 40 mph (64 km) maximum; leaping up to 20 ft (6 m)', 'Only with an optional jet pack, as the K-Universal', NULL, 'Height 7 to 8 ft (2.1 to 2.4 m)', '450 lbs', 375, 10000000, 'Never sold. The Kittani could get 10 to 15 million credits; the Coalition or Triax would pay 40 million.', 'The Kittani humanoid heavy infantry armor, P.S. 46, nuclear powered (20 years). Weapons and sensors as the Serpent, without the tail. Hand to hand: restrained 1D6, full strength or shield strike 3D4, power punch 4D6 (two attacks), kick 1D6, leap kick 2D4, body or head butt 1D4 (all M.D.); +1 initiative, +1 parry and dodge, +1 roll with impact.', 'Rifts World Book 2: Atlantis p.143-144'),
  ('kittani-abss-2-security-drone', 'Kittani ABSS-2 Simple Security Drone', 'rifts', 'drone', 0, NULL, 'Running up to 50 mph (80 km)', NULL, NULL, '5 ft (1.5 m) tall and wide, 9 ft (2.7 m) long', '800 lbs (363 kg)', 150, 6000000, 'Fair availability.', 'An unarmed, nuclear-powered Kittani security drone: kick 2D6 S.D.C., two retractable 5 ft (1.5 m) tentacles (P.S. 14) for 1D6 S.D.C. +3 to dodge, 5 melee actions; prowl, climb and track by sound or scent 60%, land navigation, intelligence and detect ambush 89%, detect concealment 60%; recognizes 100,000 targets. Acoustic amplification, radio scanner and descrambler, 24-hour video and 96-hour audio recorder, molecular analyzer, motion, heat and radiation sensors, radar (48 targets, 1 mile) and full optics.', 'Rifts World Book 2: Atlantis p.144'),
  ('kittani-abs-3-security-drone', 'Kittani ABS-3 Basic Security Drone', 'rifts', 'drone', 0, NULL, NULL, 'Hover stationary or up to 60 mph (96 km); maximum hover height 1000 ft (305 m)', NULL, '5 ft (1.5 m) tall and wide, 9 ft (2.7 m) long', '800 lbs (363 kg)', 190, 6000000, 'Fair availability; tear gas grenades 120 credits each, mini-missiles 20,000 credits each.', 'An armed, hovering Kittani security drone. +3 to strike and parry, +4 dodge, 6 attacks per melee; detect ambush and land navigation 89%, intelligence 89%, detect concealment 68%, prowl 50%; recognizes 1000 targets. Full optics, motion, heat and radiation sensors, radar detector and radar (48 targets, 1 mile), enhanced hearing, radio scrambler.', 'Rifts World Book 2: Atlantis p.144-145'),
  ('kittani-abw-4-work-drone', 'Kittani ABW-4 Basic Work Drone', 'rifts', 'drone', 0, NULL, NULL, 'Hover stationary or up to 100 mph (160 km); maximum hover height 1000 ft (305 m)', NULL, '6.6 ft (1.9 m) tall, 3.5 ft (1 m) wide', '1400 lbs (630 kg)', 200, 3000000, 'Fair availability.', 'A hovering, nuclear-powered Kittani work drone with two arms. No weapons, but it can use tools and hand-held weapons; punch 1D6 M.D. +1 to strike, parry and dodge, 4 attacks per melee. Full optics, motion, heat and radiation sensors, enhanced hearing, full radio.', 'Rifts World Book 2: Atlantis p.145'),
  ('kittani-insecton-land-rover', 'Kittani Insecton Land Rover (ATV-RV)', 'rifts', 'robot', 3, 14, 'Running 100 mph (160 km) maximum; cannot leap', 'Not possible (may carry an air vehicle on its back)', NULL, 'Height 25 ft (7.6 m), 33 ft with the cooling fin raised; Width 9 ft (2.7 m) with turrets; Length 65 ft (19.8 m)', '67 tons', 600, 120000000, 'Rarely sold; 120 million credits without weapons.', 'A six-legged Kittani insect robot vehicle for exploration and specimen collection, P.S. 60, nuclear powered (about 10 years), crew of three (pilot, co-pilot, communications and gunner) with room for 14 passengers and a cargo bay. Six attacks per melee for the pilot alone, six more with a gunner. Hand to hand: +1 attack, +1 to strike and parry, +1 roll with impact, -2 dodge. Full optics, motion and heat sensors, radar; +1 to strike at long range. The upper main body has 600 M.D.C., the lower 500.', 'Rifts World Book 2: Atlantis p.145-148'),
  ('kittani-creax-armored-rover', 'Kittani Creax Armored Rover (ATV-RV)', 'rifts', 'robot', 3, NULL, 'Running 40 mph (64 km) maximum; cannot leap', 'Hover stationary or up to 60 mph (96 km); maximum hover height 300 ft (91.5 m)', NULL, 'Height 16 ft (4.8 m), 24 ft with the rear plates raised for flight; Width 9 ft (2.7 m) with turrets; Length 11 ft (3.3 m)', '32 tons', 500, 20000000, 'Rarely sold.', 'A four-legged Kittani crab-like robot rover that can hover, P.S. 40, nuclear powered (about 10 years), crew of three (pilot, communications, field scientist). Its robot claw detaches as an independent drone (P.S. 20, P.P. 15, Spd 22, basic sensors, 3 melee actions, +2 to strike, parry and dodge). Hand to hand: +1 attack, +1 strike and parry, +2 roll with impact, -2 dodge. Full optics, motion and heat sensors, radar; +1 to strike at long range. The book gives it the same model code as the Insecton.', 'Rifts World Book 2: Atlantis p.147-149'),
  ('kittani-dragon-dreadnought', 'Kittani Dragon Dreadnought (ATV Super Fighter)', 'rifts', 'robot', 7, 40, 'Running 50 mph (80 km) maximum; cannot leap', 'Hover up to Mach 3 (about 2010 mph/3216 km), maximum Mach 5.5 (about 3700 mph/5900 km); can break Earth''s gravity and fly in space', 'Underwater to 4 miles (6.4 km) deep', 'Height 50 ft (15.2 m), 70 ft upright on its rear legs; Width 77 ft (23.5 m) wingtip to wingtip; Length 120 ft (36.6 m) plus a 120 ft tail', '300 tons', 2100, NULL, 'Never sold, top secret; the book puts it at 200 billion credits if one were ever sold fully armed.', 'A four-headed Kittani dragon robot fighter, P.S. 60, nuclear powered (about 15 years), crew of seven (pilot, co-pilot, communications, forward head gunner, wing gunner and two secondary gunners), usually carrying a platoon of 32 armored troops (Serpent or Equestrian armor) and up to 8 more passengers, with a 12 x 12 ft cargo hold. Full long-range optics and radar; +4 to strike at long range. Printed 150-151 are full-page art; the weapon list continues on 152.', 'Rifts World Book 2: Atlantis p.149, 152'),
  ('splugorth-flying-ship-small', 'Splugorth Flying Ship (Small)', 'rifts', 'ship', 2, NULL, NULL, 'Flying 35 mph (56 km); any direction, half speed against or without the wind; hovers; maximum altitude 10,000 ft (3048 m)', 'Seaworthy at about a quarter of its flying speed', NULL, NULL, 250, 12000000, 'Base price; features, weapons and decoration can add millions.', 'A small Splugorth magic sailing ship, crewed by two who can sail it plus as many passengers as fit, powered by an eye of Eylor (large ships carry two to four). Standard spells: invisibility (superior), globe of silence, globe of daylight, impervious to energy, dispel magic barriers, water to wine, wind rush, summon fog and calm storms; an elite minion''s ship may add six more. Weapon systems are optional additions. The book gives the four sizes as one table.', 'Rifts World Book 2: Atlantis p.154-155'),
  ('splugorth-flying-ship-medium', 'Splugorth Flying Ship (Medium)', 'rifts', 'ship', 2, NULL, NULL, 'Flying 50 mph (80 km); any direction, half speed against or without the wind; hovers; maximum altitude 10,000 ft (3048 m)', 'Seaworthy at about a quarter of its flying speed', NULL, NULL, 400, 25000000, 'Base price; features, weapons and decoration can add millions.', 'A medium Splugorth magic sailing ship, crewed by two who can sail it plus as many passengers as fit, powered by an eye of Eylor (large ships carry two to four). Standard spells: invisibility (superior), globe of silence, globe of daylight, impervious to energy, dispel magic barriers, water to wine, wind rush, summon fog and calm storms; an elite minion''s ship may add six more. Weapon systems are optional additions. The book gives the four sizes as one table.', 'Rifts World Book 2: Atlantis p.154-155'),
  ('splugorth-flying-ship-large', 'Splugorth Flying Ship (Large)', 'rifts', 'ship', 2, NULL, NULL, 'Flying 60 mph (96 km); any direction, half speed against or without the wind; hovers; maximum altitude 10,000 ft (3048 m)', 'Seaworthy at about a quarter of its flying speed', NULL, NULL, 650, 50000000, 'Base price; features, weapons and decoration can add millions.', 'A large Splugorth magic sailing ship, crewed by two who can sail it plus as many passengers as fit, powered by an eye of Eylor (large ships carry two to four). Standard spells: invisibility (superior), globe of silence, globe of daylight, impervious to energy, dispel magic barriers, water to wine, wind rush, summon fog and calm storms; an elite minion''s ship may add six more. Weapon systems are optional additions. The book gives the four sizes as one table.', 'Rifts World Book 2: Atlantis p.154-155'),
  ('splugorth-flying-ship-frigate', 'Splugorth Flying Ship (Frigate)', 'rifts', 'ship', 2, NULL, NULL, 'Flying 75 mph (120 km); any direction, half speed against or without the wind; hovers; maximum altitude 10,000 ft (3048 m)', 'Seaworthy at about a quarter of its flying speed', NULL, NULL, 1000, 100000000, 'Base price; features, weapons and decoration can add millions.', 'A frigate Splugorth magic sailing ship, crewed by two who can sail it plus as many passengers as fit, powered by an eye of Eylor (large ships carry two to four). Standard spells: invisibility (superior), globe of silence, globe of daylight, impervious to energy, dispel magic barriers, water to wine, wind rush, summon fog and calm storms; an elite minion''s ship may add six more. Weapon systems are optional additions. The book gives the four sizes as one table.', 'Rifts World Book 2: Atlantis p.154-155'),
  ('k-atv-hover-jet', 'Kittani K-ATV Hover Jet (K-ATV-RV)', 'rifts', 'robot', 2, 4, 'Running 60 mph (96 km) maximum; leaping 10 ft (3 m), or hovers', 'Hover or up to 650 mph (1040 km), just under Mach 1; ceiling 25,000 ft (7620 m)', NULL, 'Height 16 ft (4.8 m) on its legs, about half that as a jet; Width 22 ft (6.7 m) wings open, 14 ft (4.2 m) folded; Length 17 ft (5.2 m)', '10 tons', 225, 2400000, 'Good availability in Splynn and the Kittani cities; scarce in Europe; unheard of elsewhere.', 'A Kittani robot vehicle that transforms between a walking robot and a hover jet, P.S. 30, nuclear powered (about 10 years), pilot and co-pilot with four passengers. It can carry a borg or robot rail gun or other hand-held weapon, and up to four mini-missiles per wing. Hand to hand: +1 attack, +1 initiative, +1 strike and parry, +3 dodge.', 'Rifts World Book 2: Atlantis p.155-156'),
  ('k-gtrv-hover-land-skimmer', 'Kittani K-GTRV Hover Land Skimmer', 'rifts', 'robot', 1, 1, 'Running 40 mph (64 km) maximum; leaping 10 ft (3 m), or hovers; a high-speed ramp jump carries 200 ft (61 m) long and 40 ft (12 m) high', 'Hover or up to 570 mph (912 km); hover height 2 to 100 ft', NULL, 'Height 16 ft (4.8 m) on its legs, about half as a vehicle; Width 6 ft (1.8 m); Length 17 ft (5.2 m)', '7 tons', 200, 2100000, 'Good availability in Splynn and the Kittani cities; scarce in Europe; unheard of elsewhere.', 'A Kittani sports robot that transforms into a fast hover vehicle, P.S. 22, nuclear powered (about 6 years), pilot and one passenger. It can carry a borg or robot rail gun or hand-held weapon and up to four mini-missiles per wing. Hand to hand: +1 attack, +2 dodge.', 'Rifts World Book 2: Atlantis p.156-157'),
  ('k-gtv-fan-jet-land-skimmer', 'Kittani K-GTV Fan-Jet Land Skimmer (K-HV)', 'rifts', 'vehicle', 1, 3, 'Hover stationary or up to 300 mph (480 km); hover height 2 to 500 ft (152 m)', NULL, NULL, 'Height 6 ft (1.8 m); Width 6 ft (1.8 m); Length 16 ft (4.8 m)', '3 tons', 100, 1100000, 'Good availability in Splynn and the Kittani cities; scarce elsewhere.', 'An unarmed Kittani fan-jet hover vehicle for a pilot and three passengers, nuclear powered (about 6 years), with a small 3 x 3 ft cargo area. The model is K-HV on the render; the OCR read K-HV LW.', 'Rifts World Book 2: Atlantis p.157'),
  ('k-atv-hover-land-and-water-skimmer', 'Kittani K-ATV Hover Land & Water Skimmer (K-HVH)', 'rifts', 'vehicle', 1, 3, 'Hover stationary or up to 260 mph (416 km) over land or water; hover height 2 to 400 ft (122 m)', NULL, 'Up to 260 mph (416 km) skimming the surface', 'Height 6 ft (1.8 m) on its legs; Width 6 ft (1.8 m); Length 16 ft (4.8 m)', '3 tons', 120, 1400000, 'Good availability in Splynn and the Kittani cities; scarce elsewhere.', 'An unarmed Kittani fan-jet hydrofoil skimmer for a pilot and three passengers, with a watertight crew compartment, nuclear powered (about 6 years). Read off renders of printed 157-158; the OCR interleaved it with the K-GTV.', 'Rifts World Book 2: Atlantis p.157-158'),
  ('km-700-uni-motorcycle', 'Kittani KM-700 Uni-Motorcycle', 'rifts', 'vehicle', 1, 1, '220 mph (352 km); cannot fly', NULL, NULL, 'Height 5 ft (1.5 m); Width 2.7 ft (0.82 m); Length 8 ft (2.4 m)', '800 lbs (360 kg)', 100, 1000000, 'Good availability in Splynn and the Kittani cities; scarce elsewhere.', 'A single-wheeled Kittani jet motorcycle for a rider and one passenger, nuclear powered (about 6 years), with a briefcase-sized cargo space. Its stat block is headed "The K-GTV Motorcycle" in the book.', 'Rifts World Book 2: Atlantis p.158'),
  ('eylor-slave-barge', 'Eylor Slave Barge (Slaver''s Barge)', 'rifts', 'vehicle', 1, NULL, NULL, 'Flies or floats at 53 mph (85 km), Spd 77, to 500 ft; silent (prowl-equivalent 64%); works underwater and in space', NULL, NULL, NULL, 500, NULL, 'The book prints "50 million (?)" and says it has never been available.', 'A symbiotic bio-wizard barge permanently bonded to its Splugorth Slaver pilot; alignment as the pilot, Horror Factor 14. An Armor of Ithan force field engages automatically; it has the optics and senses of the Eyes of Eylor, gives the pilot mind block and telepathy, and casts blinding flash, globe of daylight and chameleon (barge and occupants) twice a day each from 1250 P.P.E. Its transmutation slime chamber heals 1D6x10 hit points per 10 minutes of submersion. Four plate shields shelter four blind warrior women. The barge and its eyes die if the Slaver is slain.', 'Rifts World Book 2: Atlantis p.124-125');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('k-universal-light-power-armor', 'Rear Jet Pack (1)', 50, NULL, 1),
  ('k-universal-light-power-armor', 'Chest Headlight (1)', 2, NULL, 2),
  ('k-universal-light-power-armor', 'Head', 80, 'a called shot', 3),
  ('k-universal-light-power-armor', 'Main Body', 220, 'destroying it destroys the armor', 4),
  ('kittani-serpent-power-armor', 'Shoulders (2)', 150, 'each', 1),
  ('kittani-serpent-power-armor', 'Arms (2)', 110, 'each', 2),
  ('kittani-serpent-power-armor', 'Plasma Axe (1)', 100, NULL, 3),
  ('kittani-serpent-power-armor', 'Shield / Mini-Missile Launcher (1)', 200, NULL, 4),
  ('kittani-serpent-power-armor', 'Snake Tail & Blade (last 10 ft)', 100, NULL, 5),
  ('kittani-serpent-power-armor', 'Snake Upper Body (20 ft)', 200, NULL, 6),
  ('kittani-serpent-power-armor', 'Head', 120, 'a called shot', 7),
  ('kittani-serpent-power-armor', 'Main Body', 375, 'destroying it destroys the armor', 8),
  ('kittani-equestrian-power-armor', 'Mini-Missile Shoulder Launchers (2)', 150, 'each', 1),
  ('kittani-equestrian-power-armor', 'Class Two Rocket Shield (1)', 150, NULL, 2),
  ('kittani-equestrian-power-armor', 'Forearms (2)', 100, 'each', 3),
  ('kittani-equestrian-power-armor', 'Horse Forelegs (2)', 200, 'each', 4),
  ('kittani-equestrian-power-armor', 'Horse Rear Legs (2)', 300, 'each', 5),
  ('kittani-equestrian-power-armor', 'Horse Hip Thrusters (2)', 75, 'each', 6),
  ('kittani-equestrian-power-armor', 'Horse Maneuvering Jets (8, tiny)', 10, 'each', 7),
  ('kittani-equestrian-power-armor', 'Weapon Turrets (2)', 150, 'each', 8),
  ('kittani-equestrian-power-armor', 'Energy Lance (1)', 90, NULL, 9),
  ('kittani-equestrian-power-armor', 'Forward Sensor Cluster (1)', 90, 'a called shot', 10),
  ('kittani-equestrian-power-armor', 'Main Body of Pilot', 375, NULL, 11),
  ('kittani-equestrian-power-armor', 'Main Body of Horse', 450, NULL, 12),
  ('kittani-manling-power-armor', 'Shoulders (2)', 150, 'each', 1),
  ('kittani-manling-power-armor', 'Arms (2)', 110, 'each', 2),
  ('kittani-manling-power-armor', 'Legs (2)', 110, 'each', 3),
  ('kittani-manling-power-armor', 'Plasma Axe (1)', 100, NULL, 4),
  ('kittani-manling-power-armor', 'Shield / Mini-Missile Launcher (1)', 200, NULL, 5),
  ('kittani-manling-power-armor', 'Head', 120, 'a called shot', 6),
  ('kittani-manling-power-armor', 'Main Body', 375, 'destroying it destroys the armor', 7),
  ('kittani-abss-2-security-drone', 'Communication Antenna / Tail', 50, NULL, 1),
  ('kittani-abss-2-security-drone', 'Forward Molecular Analyzer & Scent Fins (2)', 50, 'each', 2),
  ('kittani-abss-2-security-drone', 'Top Acoustic Fin', 75, NULL, 3),
  ('kittani-abss-2-security-drone', 'Legs (2)', 90, 'each', 4),
  ('kittani-abss-2-security-drone', 'Main Body', 150, NULL, 5),
  ('kittani-abs-3-security-drone', 'Light Bulb', 6, NULL, 1),
  ('kittani-abs-3-security-drone', 'Tear Gas Dispenser', 30, NULL, 2),
  ('kittani-abs-3-security-drone', 'Communication Lobe', 50, NULL, 3),
  ('kittani-abs-3-security-drone', 'Forward Weapon Lobe', 100, NULL, 4),
  ('kittani-abs-3-security-drone', 'Forward Spotlights (2)', 2, 'each', 5),
  ('kittani-abs-3-security-drone', 'Lower Hover Jets', 90, NULL, 6),
  ('kittani-abs-3-security-drone', 'Main Body', 190, NULL, 7),
  ('kittani-abw-4-work-drone', 'Communication Antenna', 35, NULL, 1),
  ('kittani-abw-4-work-drone', 'Chest Spotlight', 2, NULL, 2),
  ('kittani-abw-4-work-drone', 'Arms (2)', 50, 'each', 3),
  ('kittani-abw-4-work-drone', 'Lower Hover Jets', 110, NULL, 4),
  ('kittani-abw-4-work-drone', 'Main Body', 200, NULL, 5),
  ('kittani-insecton-land-rover', 'Mini-Missile Pod (1, top)', 150, NULL, 1),
  ('kittani-insecton-land-rover', 'Small Forward Lasers (8 barrels)', 10, 'each', 2),
  ('kittani-insecton-land-rover', 'Rear Laser Turret (1)', 100, NULL, 3),
  ('kittani-insecton-land-rover', 'Rear Particle Beams (2)', 50, 'each', 4),
  ('kittani-insecton-land-rover', 'Forward Mandibles (1)', 75, NULL, 5),
  ('kittani-insecton-land-rover', 'Nose Horn', 75, NULL, 6),
  ('kittani-insecton-land-rover', 'Lights (6, tiny)', 2, 'each', 7),
  ('kittani-insecton-land-rover', 'Lower Spotlights (2)', 10, 'each', 8),
  ('kittani-insecton-land-rover', 'Legs (6)', 200, 'each', 9),
  ('kittani-insecton-land-rover', 'Leg-like Top Appendages (6)', 100, 'each', 10),
  ('kittani-insecton-land-rover', 'Rear Thrusters (3)', 50, 'each', 11),
  ('kittani-insecton-land-rover', 'Cooling Fin (1)', 150, NULL, 12),
  ('kittani-insecton-land-rover', 'Side Hatches (14)', 70, 'each', 13),
  ('kittani-insecton-land-rover', 'Forward Hatch (1)', 100, NULL, 14),
  ('kittani-insecton-land-rover', 'Pilot & Crew Compartment', 120, NULL, 15),
  ('kittani-insecton-land-rover', 'Forward Sensor Clusters (2)', 90, 'each; a called shot', 16),
  ('kittani-insecton-land-rover', 'Upper Main Body', 600, NULL, 17),
  ('kittani-insecton-land-rover', 'Lower Main Body', 500, NULL, 18),
  ('kittani-creax-armored-rover', 'Head Laser Turret (1, tiny)', 10, NULL, 1),
  ('kittani-creax-armored-rover', 'Forward Auto-Guns (2)', 100, 'each', 2),
  ('kittani-creax-armored-rover', 'Crab Claw (1)', 125, NULL, 3),
  ('kittani-creax-armored-rover', 'Crab Claw Arms (2)', 25, 'each', 4),
  ('kittani-creax-armored-rover', 'Right Arm', 100, NULL, 5),
  ('kittani-creax-armored-rover', 'Shoulders (2)', 150, 'each', 6),
  ('kittani-creax-armored-rover', 'Lights (6, tiny)', 2, 'each', 7),
  ('kittani-creax-armored-rover', 'Lower Spotlights (2)', 10, 'each', 8),
  ('kittani-creax-armored-rover', 'Legs (4)', 200, 'each', 9),
  ('kittani-creax-armored-rover', 'Rear Thrusters (4, under the fin)', 50, 'each', 10),
  ('kittani-creax-armored-rover', 'Directional Thrusters (4, in the fin)', 50, 'each', 11),
  ('kittani-creax-armored-rover', 'Armored Fin (1, rear)', 350, NULL, 12),
  ('kittani-creax-armored-rover', 'Hatches (2, underbelly)', 90, 'each', 13),
  ('kittani-creax-armored-rover', 'Pilot & Crew Compartment', 110, NULL, 14),
  ('kittani-creax-armored-rover', 'Sensor Cluster (head)', 80, 'a called shot', 15),
  ('kittani-creax-armored-rover', 'Main Body', 500, NULL, 16),
  ('kittani-dragon-dreadnought', 'Dragon Heads (4)', 250, 'each', 1),
  ('kittani-dragon-dreadnought', 'Arms (2)', 200, 'each', 2),
  ('kittani-dragon-dreadnought', 'Legs (2)', 400, 'each', 3),
  ('kittani-dragon-dreadnought', 'Wings (6)', 300, 'each', 4),
  ('kittani-dragon-dreadnought', 'Wing Laser Turrets (4)', 150, 'each', 5),
  ('kittani-dragon-dreadnought', 'Wing P-Beam Guns (6)', 50, 'each', 6),
  ('kittani-dragon-dreadnought', 'Tail Laser (1)', 100, NULL, 7),
  ('kittani-dragon-dreadnought', 'Tail (1)', 150, NULL, 8),
  ('kittani-dragon-dreadnought', 'Missile Launch Tube (1, top)', 300, NULL, 9),
  ('kittani-dragon-dreadnought', 'Missile Bomb Bay Doors (1, underneath)', 400, NULL, 10),
  ('kittani-dragon-dreadnought', 'Spotlights (4)', 20, 'each', 11),
  ('kittani-dragon-dreadnought', 'Directional Thrusters (20)', 20, 'each', 12),
  ('kittani-dragon-dreadnought', 'Hatches (6)', 100, 'each', 13),
  ('kittani-dragon-dreadnought', 'Pilot & Crew Compartment', 200, NULL, 14),
  ('kittani-dragon-dreadnought', 'Forward Sensor Cluster', 100, 'a called shot', 15),
  ('kittani-dragon-dreadnought', 'Main Body', 2100, NULL, 16),
  ('splugorth-flying-ship-small', 'Main Body', 250, NULL, 1),
  ('splugorth-flying-ship-medium', 'Main Body', 400, NULL, 1),
  ('splugorth-flying-ship-large', 'Main Body', 650, NULL, 1),
  ('splugorth-flying-ship-frigate', 'Main Body', 1000, NULL, 1),
  ('k-atv-hover-jet', 'Arm Lasers (2, tiny)', 10, 'each; a called shot', 1),
  ('k-atv-hover-jet', 'Arms (2)', 80, 'each', 2),
  ('k-atv-hover-jet', 'Legs (2)', 150, 'each', 3),
  ('k-atv-hover-jet', 'Wings (2)', 100, 'each', 4),
  ('k-atv-hover-jet', 'Hover Wing Jets (2)', 50, 'each; a called shot', 5),
  ('k-atv-hover-jet', 'Tail Fins (2)', 50, 'each', 6),
  ('k-atv-hover-jet', 'Main Thrusters (2)', 150, 'each', 7),
  ('k-atv-hover-jet', 'Directional Thrusters (4)', 10, 'each; a called shot', 8),
  ('k-atv-hover-jet', 'Pilot & Crew Compartment', 100, NULL, 9),
  ('k-atv-hover-jet', 'Main Body', 225, NULL, 10),
  ('k-gtrv-hover-land-skimmer', 'Laser Gun Mount (1, small)', 10, 'a called shot', 1),
  ('k-gtrv-hover-land-skimmer', 'Arms (2)', 50, 'each', 2),
  ('k-gtrv-hover-land-skimmer', 'Legs (2)', 110, 'each', 3),
  ('k-gtrv-hover-land-skimmer', 'Main Jet Thrusters (2)', 100, 'each', 4),
  ('k-gtrv-hover-land-skimmer', 'Directional Thrusters (4)', 10, 'each; a called shot', 5),
  ('k-gtrv-hover-land-skimmer', 'Pilot & Crew Compartment', 50, NULL, 6),
  ('k-gtrv-hover-land-skimmer', 'Main Body', 200, NULL, 7),
  ('k-gtv-fan-jet-land-skimmer', 'Main Jet Thrusters (2)', 70, 'each', 1),
  ('k-gtv-fan-jet-land-skimmer', 'Pilot & Crew Compartment', 50, NULL, 2),
  ('k-gtv-fan-jet-land-skimmer', 'Main Body', 100, NULL, 3),
  ('k-atv-hover-land-and-water-skimmer', 'Main Jet Thrusters (2)', 75, 'each', 1),
  ('k-atv-hover-land-and-water-skimmer', 'Pilot & Crew Compartment', 50, 'water tight', 2),
  ('k-atv-hover-land-and-water-skimmer', 'Main Body', 120, NULL, 3),
  ('km-700-uni-motorcycle', 'Wheel (1)', 35, NULL, 1),
  ('km-700-uni-motorcycle', 'Main Jet Thruster (1)', 75, NULL, 2),
  ('km-700-uni-motorcycle', 'Laser Cannon (1)', 30, NULL, 3),
  ('km-700-uni-motorcycle', 'Main Body', 100, NULL, 4),
  ('eylor-slave-barge', 'Slave Barge Main Body', 500, NULL, 1),
  ('eylor-slave-barge', 'Transmutation Slime Containment Chamber', 250, NULL, 2),
  ('eylor-slave-barge', 'Barge Shields (4)', 100, 'each', 3),
  ('eylor-slave-barge', 'Barge Eyes (5)', 50, 'each', 4);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('kittani-serpent-power-armor', 1, 'Double-Bladed Plasma Axe', 'Energized strike 1D4x10 M.D.; energy blast 1D4x10 M.D. (twice per melee); blunt 1D4 M.D.', 1, '200 feet (61 m) for the blast', 'Equal to the combined hand to hand attacks (average 6 to 8); the plasma blast at most twice per melee', 'Draws on the armor (effectively unlimited), or an E-clip for an hour at half damage, six blasts at most', NULL, 'Weighs 20 lbs.'),
  ('kittani-serpent-power-armor', 2, 'Class One Combat Shield & Mini-Missile Launcher', 'Mini-missile: by type', 1, 'About 1 mile', 'One at a time', '4 mini-missiles', NULL, 'Parries at half damage.'),
  ('kittani-serpent-power-armor', 3, 'Tail & Vibro-Blade', 'Vibro-blade 3D6 M.D.; power strike 6D6 M.D. (two attacks); tail swat 2D6 M.D.', 1, 'Hand to hand', NULL, NULL, NULL, NULL),
  ('kittani-serpent-power-armor', 4, 'Hand to Hand Combat', 'Restrained 1D6 M.D.; full strength 3D4 M.D.; power punch 4D6 M.D. (two attacks); body/head butt 1D6 M.D.', 1, 'Hand to hand', NULL, NULL, '+2 attacks, +2 initiative, +2 strike and parry, +3 auto-dodge, +2 dodge, +2 roll with impact', NULL),
  ('kittani-equestrian-power-armor', 1, 'Tri-Barrel Super Rail Gun (right arm)', '1D6x10 M.D. per 40-round burst (bursts only)', 1, '6000 feet (1828 m)', 'Up to six bursts per melee', '4000-round drum (100 bursts); a second drum feeds automatically; about 5 minutes to reload', '+2 to strike (laser targeting and radar)', 'Gun 1000 lbs (450 kg) plus a 100 lb drum; needs P.S. 26+. Back-up variable-frequency laser: 2D6 M.D., 4000 ft (1200 m), 40 shots.'),
  ('kittani-equestrian-power-armor', 2, 'KL Twin-Barrel Pulse Cannon (left arm)', '1D6x10 M.D. dual blast or 5D6 M.D. single pulse', 1, '4000 feet (1200 m)', 'Equal to the pilot''s hand to hand attacks (4-6)', 'Unlimited', '+2 to strike', 'Secondary double-barrel laser turret: 2D6 M.D., 2000 ft (610 m), unlimited.'),
  ('kittani-equestrian-power-armor', 3, 'Dual Shoulder Mini-Missile Launchers', 'Armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D.; fragmentation for anti-personnel', 1, 'About 1 mile', 'One to three at a time', '6 (3 per shoulder)', NULL, NULL),
  ('kittani-equestrian-power-armor', 4, 'Class Two Rocket Shield', '3D4x10 M.D., 30 ft blast radius', 1, '2 miles (3.2 km)', 'One', '1', '+4 to strike', 'The shield is itself a guided multi-warhead missile.'),
  ('kittani-equestrian-power-armor', 5, 'Energy Lance', '3D6 M.D., or 6D6 M.D. focused at half range; 2D4 M.D. stabbing or blunt', 1, '6000 feet (1828 m); 3000 feet (915 m) focused', 'Equal to the pilot''s hand to hand attacks (4-6)', '40 shots; recharges in 4 hours', '+2 to strike on called shots', NULL),
  ('kittani-equestrian-power-armor', 6, 'Hand to Hand Combat', 'Rocket shield strike 3D4; foreleg kick 4D6 (stomp half); rear leg kick 2D4x10 (two attacks); rear stomp 5D6; power punch 3D6; body butt 2D6; leap kick or flying body block 2D4x10 with 1-75% knockdown (two attacks); all M.D.', 1, 'Hand to hand', NULL, NULL, '+1 attack, +2 strike on kicks, +1 parry, +2 dodge', NULL),
  ('kittani-manling-power-armor', 1, 'Double-Bladed Plasma Axe', 'Energized strike 1D4x10 M.D.; energy blast 1D4x10 M.D. (twice per melee); blunt 1D4 M.D.', 1, '200 feet (61 m) for the blast', 'Equal to the combined hand to hand attacks (average 6 to 8); the plasma blast at most twice per melee', 'Draws on the armor, or an E-clip for an hour at half damage', NULL, 'As the Serpent.'),
  ('kittani-manling-power-armor', 2, 'Class One Combat Shield & Mini-Missile Launcher', 'Mini-missile: by type', 1, 'About 1 mile', 'One at a time', '4 mini-missiles', NULL, 'As the Serpent.'),
  ('kittani-abs-3-security-drone', 1, 'Light Lasers (small and large)', 'Small 2D6 M.D., large 3D6 M.D., or 5D6 M.D. simultaneous double blast', 1, '2000 feet (610 m)', NULL, '100 blasts, recharged hourly; an emergency E-clip gives 20', NULL, NULL),
  ('kittani-abs-3-security-drone', 2, 'Siren', 'None: -2 initiative and -1 to strike, parry and dodge within 200 ft', 0, 'Heard for half a mile (0.8 km)', NULL, NULL, NULL, NULL),
  ('kittani-abs-3-security-drone', 3, 'Tear Gas Grenades', 'None: -10 to strike, parry and dodge and one attack lost for 1D6+1 rounds', 0, '50 feet (15 m)', NULL, '20', NULL, NULL),
  ('kittani-abs-3-security-drone', 4, 'Mini-Missiles', 'By type', 1, 'Varies with missile type', NULL, '6', NULL, NULL),
  ('kittani-insecton-land-rover', 1, 'Single Barrel Light Lasers (2, head)', '2D6 M.D. single or 4D6 M.D. double blast', 1, '2000 feet (610 m)', 'Up to six double blasts per melee', 'Unlimited', NULL, NULL),
  ('kittani-insecton-land-rover', 2, 'Tri-Barrel Light Lasers (2 pods)', '2D6 M.D. single or 6D6 M.D. triple blast', 1, '2000 feet (610 m)', 'Up to six triple blasts per melee', 'Unlimited', NULL, NULL),
  ('kittani-insecton-land-rover', 3, 'Mini-Missile Launcher Pod', 'Armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D.; fragmentation for anti-personnel', 1, 'About 1 mile', 'One to four at a time', '32', NULL, NULL),
  ('kittani-insecton-land-rover', 4, 'Rear Twin-Barrel Pulse Cannon', '6D6 M.D. dual blast', 1, '4000 feet (1200 m)', 'Equal to the pilot''s hand to hand attacks (4-6)', 'Unlimited', '+1 to strike', 'Weighs 2 tons.'),
  ('kittani-insecton-land-rover', 5, 'Rear Particle Beam Turret (2)', '1D4x10 M.D. per blast', 1, '2000 feet (610 m)', 'Up to six double blasts per melee', 'Unlimited', NULL, NULL),
  ('kittani-insecton-land-rover', 6, 'Hand to Hand Combat', 'Bite 4D6; leg kick 3D6; stomp 5D6; horn butt or ram 5D6; body block or ram 1D4x10 with 1-75% knockdown (two attacks); all M.D.', 1, 'Hand to hand', NULL, NULL, '+1 attack, +1 strike and parry, +1 roll with impact, -2 dodge', NULL),
  ('kittani-creax-armored-rover', 1, 'Double-Barrel Light Laser (chin)', '2D6 M.D. single or 4D6 M.D. double blast', 1, '2000 feet (610 m)', 'Equal to the pilot''s hand to hand attacks', 'Unlimited', NULL, NULL),
  ('kittani-creax-armored-rover', 2, 'Fixed Forward Auto-Gun Pods (2)', '3D6 M.D. single burst or 6D6 M.D. dual burst', 1, '2000 feet (610 m)', 'Equal to the pilot''s hand to hand attacks', '100 bursts', NULL, NULL),
  ('kittani-creax-armored-rover', 3, 'Hand to Hand Combat', 'Restrained punch 4D6 S.D.C.; full punch 2D6 M.D.; crab claw 4D6 M.D., power punch 1D4x10+8 M.D.; claw-arm punch 1D4 M.D.; kick 2D6 M.D.; stomp 2D6 M.D.; body block or ram 3D6 M.D. with 1-50% knockdown (two attacks)', 1, 'Hand to hand', NULL, NULL, '+1 attack, +1 strike and parry, +2 roll with impact, -2 dodge', NULL),
  ('kittani-dragon-dreadnought', 1, 'Four Dragon Heads', 'Head butt 2D6 M.D.; bite 1D4x10 M.D.; plasma blast 1D4x10 M.D.; laser blast 2D4x10 M.D. (one head fires a laser instead of plasma)', 1, 'Plasma 4000 feet (1200 m); laser 2 miles (3.2 km)', 'Each head twice per melee, 8 attacks in all', 'Unlimited', '+4 to strike, parry and dodge, +2 initiative', NULL),
  ('kittani-dragon-dreadnought', 2, 'KLT Twin-Barrel Pulse Cannon Wing Turrets (4)', '5D6 M.D. single pulse or 1D6x10 M.D. dual blast per turret; 4D6x10 M.D. from all four at once', 1, '6000 feet (1828 m)', 'Six', 'Effectively unlimited', '+3 to strike (its own laser targeting and radar, 6000 ft)', 'The entry breaks from printed 149 to 152.'),
  ('kittani-dragon-dreadnought', 3, 'Wing Particle Beam Guns (8)', '1D4x10 M.D. per blast', 1, '2000 feet (610 m)', 'Up to six double blasts per melee', 'Unlimited', NULL, NULL),
  ('kittani-dragon-dreadnought', 4, 'Tail Laser', '1D6x10 M.D. laser, or 5D6 M.D. physical hit', 1, '6000 feet (1828 m)', 'Six attacks per melee', 'Unlimited', NULL, NULL),
  ('kittani-dragon-dreadnought', 5, 'Missiles', 'Typically 4D6x10 M.D. (proton or multi-warhead)', 1, 'Medium and long range: dozens to 1000+ miles', NULL, '8 medium-range in the top tube, 16 long-range in the bomb bay', NULL, NULL),
  ('kittani-dragon-dreadnought', 6, 'Hand to Hand Combat', 'Punch 3D4; power punch 4D6; rear kick 1D4x10; rear stomp 1D6x10; tail strike 5D6; head butt 2D6; head bite 1D4x10; flying body block 3D4x10 with 1-85% knockdown (two attacks); all M.D.', 1, 'Hand to hand', NULL, NULL, '+1 attack, +2 strike on kicks, +1 parry, +2 dodge', NULL),
  ('k-atv-hover-jet', 1, 'Light Lasers (2, forearms)', '2D6 M.D. per blast', 1, '2000 feet (610 m)', 'Equal to the pilot''s hand to hand attacks', 'Unlimited', NULL, NULL),
  ('k-atv-hover-jet', 2, 'Optional Mounts', 'Borg or robot rail gun or other hand-held weapon; mini-missiles by type', 1, NULL, NULL, 'Up to 4 mini-missiles per wing', NULL, NULL),
  ('k-atv-hover-jet', 3, 'Hand to Hand Combat', 'Restrained punch 3D6 S.D.C.; full punch 1D6 M.D.; power punch 3D4 M.D. (two attacks); kick 2D6 M.D.; leap kick 4D6 M.D. (two attacks); body block or ram 4D6 M.D. with 1-50% knockdown (two attacks)', 1, 'Hand to hand', NULL, NULL, '+1 attack, +1 initiative, +1 strike and parry, +3 dodge', NULL),
  ('k-gtrv-hover-land-skimmer', 1, 'Light Laser Gun Mount', '2D6 M.D. per blast', 1, '2000 feet (610 m)', 'Equal to the pilot''s hand to hand attacks', '50 shots from a separate power canister', NULL, NULL),
  ('k-gtrv-hover-land-skimmer', 2, 'Hand to Hand Combat', 'Restrained punch 2D6 S.D.C.; full punch 1D4 M.D.; power punch 2D4 M.D. (two attacks); kick 1D6 M.D.; leap kick 2D6 M.D. (two attacks); body block or ram 3D6 M.D. with 1-50% knockdown (two attacks)', 1, 'Hand to hand', NULL, NULL, '+1 attack, +2 dodge', NULL),
  ('km-700-uni-motorcycle', 1, 'Laser Cannon', '3D6 M.D. per shot', 1, '1600 feet (488 m)', 'Equal to the pilot''s melee actions', 'Effectively unlimited', NULL, NULL),
  ('eylor-slave-barge', 1, 'Barge Blasters (2)', '4D6 S.D.C. per blast (6D6 S.D.C. on a ley line)', 0, '2000 feet (610 m)', 'Up to four blasts per melee', 'Effectively unlimited', NULL, 'Lower front and rear.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 20 Atlantis vehicles are in' AS assertion, count(*) AS got, 20 AS want
  FROM vehicles WHERE slug IN ('k-universal-light-power-armor', 'kittani-serpent-power-armor', 'kittani-equestrian-power-armor', 'kittani-manling-power-armor', 'kittani-abss-2-security-drone', 'kittani-abs-3-security-drone', 'kittani-abw-4-work-drone', 'kittani-insecton-land-rover', 'kittani-creax-armored-rover', 'kittani-dragon-dreadnought', 'splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate', 'k-atv-hover-jet', 'k-gtrv-hover-land-skimmer', 'k-gtv-fan-jet-land-skimmer', 'k-atv-hover-land-and-water-skimmer', 'km-700-uni-motorcycle', 'eylor-slave-barge') AND source_book LIKE 'Rifts World Book 2: Atlantis p.%';
SELECT 'their 133 M.D.C. locations are in' AS assertion, count(*) AS got, 133 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('k-universal-light-power-armor', 'kittani-serpent-power-armor', 'kittani-equestrian-power-armor', 'kittani-manling-power-armor', 'kittani-abss-2-security-drone', 'kittani-abs-3-security-drone', 'kittani-abw-4-work-drone', 'kittani-insecton-land-rover', 'kittani-creax-armored-rover', 'kittani-dragon-dreadnought', 'splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate', 'k-atv-hover-jet', 'k-gtrv-hover-land-skimmer', 'k-gtv-fan-jet-land-skimmer', 'k-atv-hover-land-and-water-skimmer', 'km-700-uni-motorcycle', 'eylor-slave-barge');
SELECT 'their 38 weapon entries are in' AS assertion, count(*) AS got, 38 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('k-universal-light-power-armor', 'kittani-serpent-power-armor', 'kittani-equestrian-power-armor', 'kittani-manling-power-armor', 'kittani-abss-2-security-drone', 'kittani-abs-3-security-drone', 'kittani-abw-4-work-drone', 'kittani-insecton-land-rover', 'kittani-creax-armored-rover', 'kittani-dragon-dreadnought', 'splugorth-flying-ship-small', 'splugorth-flying-ship-medium', 'splugorth-flying-ship-large', 'splugorth-flying-ship-frigate', 'k-atv-hover-jet', 'k-gtrv-hover-land-skimmer', 'k-gtv-fan-jet-land-skimmer', 'k-atv-hover-land-and-water-skimmer', 'km-700-uni-motorcycle', 'eylor-slave-barge');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-atlantis-vehicles.sql');
