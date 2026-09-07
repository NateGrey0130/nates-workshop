-- Triax vessels from printed pages 039-070.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-triax-vessels-p039-070.sql
--
-- BOOK-INGEST-AUDIT.md F3. The vessels were excluded from every batch of
-- this book because `gear` holds one mdc, one damage, one range and one
-- payload, and a vessel here has M.D.C. by LOCATION and several numbered
-- weapon systems with four stats each. Migration 048 gave them three tables
-- of their own - vehicles, vehicle_locations, vehicle_weapons - and this is
-- the data that was waiting on them.
--
-- A VESSEL BELONGS TO THE SLICE ITS NAME HEADING FALLS IN. That rule is why
-- no vessel is split across two of these files and none is imported twice:
-- a reader whose stat block runs past a page boundary read on to finish it,
-- and a reader who met a block already in progress skipped it.
--
-- INSERT OR IGNORE THROUGHOUT, and the readbacks COUNT rather than trusting
-- the exit code - an IGNORE that collides is silent, which is exactly how a
-- row goes missing without an error.
--
-- mdc_main_body is the main body ONLY. The full printed block is in
-- vehicle_locations, main body included, so it can be rendered in the order
-- the book sets it; a reader wanting a total must sum the rows.
--
-- A LOCATION WHOSE M.D.C. THE BOOK PRINTS AS A FORMULA carries mdc NULL and
-- the formula in mdc_note. The EIR-50 Gurgoyle Android is the whole reason:
-- its block is printed as dice, not numbers, because the machine is built to
-- match whatever gurgoyle it is imitating.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('t-21-terrain-hopper', 'T-21 Terrain Hopper Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 40 mph (64 km) maximum; tires operator at 20% of normal fatigue rate thanks to the robot exo-skeleton.', 'Leaping: 15 feet (4.6 m) high or lengthwise unassisted; jet thruster assisted leap up to 200 feet (61 m) high. Power Jumping: up to 300 feet (91.5 m) lengthwise, height typically 20-30 feet (20-50 ft range), sustained ground speed via power leaps 170 mph (272 km). Limited Flight: hover to 200 feet (61 m); max flying speed 100 mph (160 km), cruising 60 mph (96.5 km), max altitude 200 feet (61 m).', NULL, 'Height: 7 feet (2.1 m); Width: 3 feet (0.9 m); Length: About 2.5 feet (0.63 m)', '100 lbs (45 kg) with jet pack', 170, 500000, '500,000 credits for a new, undamaged, fully powered suit complete with jet pack. Excellent availability at the NGR, fair to good availability in other European and Coalition cities; scarce everywhere else.', 'A lightweight environmental power armor built for comfort, extreme mobility, reconnaissance, rescue and exploration; it hops via jet-boosted leaps rather than running or sustained flight, and is unarmed as standard, relying on hand-held weapons.', 'Rifts World Book 5: Triax and the NGR p.39-41'),
('t-c20-terrain-hopper', 'T-C20 Terrain Hopper Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 40 mph (64 km) maximum; tires operator at 20% of normal fatigue rate.', 'Leaping: 15 feet (4.6 m) high or lengthwise unassisted; jet thruster assisted leap to 200 feet (61 m) high. Power Jumping: same as T-21, up to 300 feet (91.5 m) lengthwise, height typically 20-30 feet (20-50 ft range), ground speed via power leaps 170 mph (272 km). Limited Flight: hover to 200 feet (61 m); max flying speed 100 mph (160 km), cruising 60 mph (96.5 km), max altitude 200 feet (61 m).', NULL, 'Height: 7 feet (2.1 m); Width: 3 feet (0.9 m); Length: About 2.5 feet (0.76 m)', '150 lbs (68 kg) with jet pack, missiles and additional armor', 200, 750000, 'NGR and Black Market Cost: 750,000 credits for a new, undamaged, fully equipped suit with jet pack and weapon systems. Good availability at the NGR; poor availability in other European locations; scarce everywhere else.', 'The combat version of the Terrain Hopper, used by the military and Triax Industry investigators; nearly identical to the T-21 but with built-in weapon systems and heavier armor.', 'Rifts World Book 5: Triax and the NGR p.41-42'),
('t-31-super-trooper', 'T-31 Super Trooper Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 40 mph (64 km) maximum; 10% of the usual fatigue rate thanks to the robot exo-skeleton.', 'Leaping: 12 feet (3.6 m) high or lengthwise unassisted; jet thruster assisted leap propels the unit up to 60 feet (18.3 m) high and 100 feet (30.5 m) lengthwise. Flying is not possible; the rocket system is for leaping onto/off giant bots and vehicles and for rolling with impact.', NULL, 'Height: 7 to 8 feet (2.1 to 2.4 m) head to toe, 8 to 9 feet (2.4 to 2.7 m) with shoulder missile launchers; Width: Wings 4 feet (1.2 m); Length: 3 feet (0.9 m)', '450 lbs (202.5 kg)', 250, 1800000, 'Black Market Cost: 1.8 million credits for a new, undamaged, fully powered suit with complete weapon systems. Poor availability. Exclusive to the NGR military; never made available to the mass market.', 'A man-size anti-tank/armor assault power armor nicknamed The Can-Opener, designed for troopers to leap onto and cling to giant robots or armored vehicles and cut them apart with vibro-blade, lasers, explosives and missiles, targeting joints, sensors and weapon turrets.', 'Rifts World Book 5: Triax and the NGR p.42-45'),
('t-550-glitter-boy', 'T-550 Glitter Boy Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 60 mph (96 km) maximum; 20% of the usual fatigue rate.', 'Leaping: 10 feet (3 m) high or 15 feet lengthwise (4.6 m) from a short running start. Flight is not a capability of the T-550.', NULL, 'Height: 9 feet (2.7 m) head to toe, 10 feet (3 m) with boom gun in firing position; Width: 3 feet 9 inches (1.1 m); Length: 4 feet (1.2 m) including ammo drum and recoil suppression system, 8 feet (2.4 m) nose of gun to back in firing position', '2 tons', 650, 60000000, 'Black Market Cost: 60+ million credits for a completely equipped T-550 Glitter Boy. The black market has yet to acquire one of these suits. No availability.', 'The Triax version of the Glitter Boy: a laser-resistant strategic armor built around a Boom Gun/rail gun, produced under a technology-sharing agreement between the NGR and Free Quebec; sleeker and smaller than the North American G10 Glitter Boy, with added mini-missiles, an anti-personnel laser and a vibro-sword.', 'Rifts World Book 5: Triax and the NGR p.45-48'),
('x-10a-predator', 'X-10A Predator Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 50 mph (80 km) maximum; 10% of the usual fatigue rate.', 'Leaping: 15 feet (4.6 m) high or across unassisted; jet thruster assisted leap up to 100 feet (30.5 m) high and 200 feet (61 m) lengthwise without attaining flight. Flying: hover to 500 feet (152 m); max flying speed 290 mph (464 km), cruising 150 mph (240 km), max altitude 500 feet (152 m); flies 24 hours non-stop, cooling usable after 15 minutes.', NULL, 'Height: 9 feet (2.7 m) head to toe, 11 feet (3.35 m) with wings extended; Width: wings down 5 feet (1.5 m), wings extended 13 feet (4 m); Length: 4 feet, 6 inches (1.4 m)', '1000 lbs (450 kg)', 380, 2400000, 'Black Market Cost: the related, weaker/slower export model X-10 Predator sells in the Americas for around 1.9 million credits in perfect condition; the X-10A is NGR-military exclusive and sells on the black market for 2.4 million in perfect condition. Rare; very poor availability.', 'A one-man aerial fighter power armor developed to combat gargoyles and other winged enemies; heavier and slightly slower than the Coalition SAMAS but compensates in armor, weapon systems and physical strength. A scaled-down export version, the X-10, is sold in the Americas but not Europe.', 'Rifts World Book 5: Triax and the NGR p.49-51'),
('x-60-flanker', 'X-60 Flanker Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 50 mph (80 km) maximum; 20% of the usual fatigue rate.', 'Leaping: 10 feet (3 m) high or 15 feet across (4.6 m) from a running start. Flying: None.', NULL, 'Height: 11 feet (3.3 m); Width: 5 feet (1.5 m); Length: 4 feet (1.2 m) including the cooling pylon', '1000 lbs (450 kg)', 380, 500000, 'Black Market Cost: 500,000 credits in perfect condition and fully loaded. Very poor availability. Not offered by Triax in the mass market.', 'A hybrid exoskeleton/one-man robot used by NGR police and civil defense for riot control and urban combat, also used for military police, escort and guard duties; suits up in under 15 seconds and carries concealed non-lethal and lethal weapon systems and extendable hydraulic arms.', 'Rifts World Book 5: Triax and the NGR p.51-54'),
('x-500-forager', 'X-500 Forager Battlebot', 'rifts', 'robot', 'Two, a pilot and co-pilot. It can also accommodate two passengers.', 'Two', 'Running: 60 mph (96 km) maximum, does NOT tire out its operator; cruising speed usually 35 mph (56 km). Well suited for most terrains including underwater; not as well suited for climbing rope/cables or steep mountains; excellent for mining (digging) and construction operations.', NULL, NULL, 'Height: 29 feet, 5 inches (9 m); Width: 15 feet (4.6 m); Length: 12 feet (3.7 m)', '28 tons fully loaded, 22 tons without missiles and launchers', 350, 22000000, 'Black Market Cost: 22 million credits for a new, undamaged, full combat unit complete with missiles; fair availability. 13 million for the labor and exploration models which lack missiles/launchers (has belly gun).', 'An old-style assault robot in service for 50 years and now being phased out by the Dyna-Max and Jager series; suited to reconnaissance, defense, combat, and construction/mining operations over most land terrain.', 'Rifts World Book 5: Triax and the NGR p.54-55'),
('x-535-hunter-jager', 'X-535 Hunter', 'rifts', 'robot', 'One pilot', NULL, 'Running: 140 mph (224 km) maximum, does NOT tire out its operator; cruising speed usually around 60 mph (96 km). Superb at climbing rope/cables and sheer mountain cliffs/buildings; suitable for labor, mining and construction; well suited for most terrains including underwater.', NULL, NULL, 'Height: 12 feet (3.6 m) as a basic combat unit, 17 feet (5 m) with cannon attachments; Width: 5 feet (1.5 m); Length: 5 feet (1.5 m)', '3 tons as a basic unit, 6 to 9 tons fully loaded with cannons and launchers', 300, 12000000, 'Black Market Cost: 12 million credits for a new, undamaged basic unit with rail gun. Add 8 million for each of the heavy, long-range weapon systems.', 'Also known as the Jager, a fast and nimble one-man infantry robot in service for nine years, armed with head machineguns and hand-held rail guns as standard, with three types of interchangeable heavy shoulder-mounted cannons available via the TX-481M Universal Mount.', 'Rifts World Book 5: Triax and the NGR p.55-60'),
('x-545-super-hunter', 'X-545 Super Hunter', 'rifts', 'robot', 'One pilot', NULL, 'Running: 70 mph (112.6 km) maximum, does NOT tire out its operator; cruising speed usually around 40 mph (64 km). Reasonably good at climbing rope/cables and mountains, cannot climb sheer walls; suitable for labor, mining and construction; well suited for most terrains including underwater.', NULL, NULL, 'Height: 18 feet (5.4 m); Width: 9 feet (2.7 m); Length: 6 feet (1.8 m)', '8 tons fully loaded', 500, 16000000, 'Black Market Cost: 16 million credits for a new, undamaged basic unit with rail gun and missiles.', 'Also known as the Armored Jager, a larger, more heavily armored version of the Jager infantry robot in service for six years, designed to stand and fight advancing enemy troops while other NGR forces retreat or reposition; carries both anti-personnel and anti-armor weapon systems.', 'Rifts World Book 5: Triax and the NGR p.60-63'),
('x-622-bug', 'X-622 Bug', 'rifts', 'robot', 'Two, a pilot and co-pilot/gunner. It can also accommodate four passengers comfortably.', 'Four', 'Land Speed: 60 mph (96 km) crawling/scurrying in unobstructed environments; cruising speed usually 40 mph (64 km). Reduce speed by 20 percent through woodlands, swamps or rough terrain; reduce by 50 percent through dense forests and extremely difficult terrain.', NULL, 'Surface Water Travel: 30 mph (48 km); can push/swim with arms at about 5 mph (8 km) if rear engine destroyed, or crawl along riverbeds. Underwater Travel: safe max depth 300 feet (91.5 m), can go as deep as 600 feet (183 m); engine speed 30 mph (48 km), crawling speed max 20 mph (32 km), swimming with claws about 3 mph (4.8 km).', 'Height: 13 feet (4 m) fully erect, body section roughly 7 feet (2.1 m) belly to top; Width: 6 feet (1.8 m); Length: 17 feet (5.2 m)', '8 tons fully loaded', 400, 6000000, 'Black Market Cost: 9 million credits for a new, undamaged, full combat unit complete with missiles and weapons; 6 million without weapons. Poor availability for either.', 'An amphibious robot vehicle (nicknamed Kaefer) that can hold up to six people, designed as a light assault infantry support vehicle and APC able to scurry over rugged terrain and float/skim on the surface of water or travel underwater like a mini-submarine.', 'Rifts World Book 5: Triax and the NGR p.63-66'),
('x-821-landcrab', 'X-821 Landcrab Robot APC', 'rifts', 'robot', 'Two, a pilot and co-pilot/gunner. It can also accommodate as many as 12 passengers comfortably.', 'Up to 12', 'Land Speed: 60 mph (96 km) crawling/scurrying in unobstructed environments; cruising speed usually 40 mph (64 km). Reduce speed by 20 percent through woodlands, swamps or rough terrain; reduce by 50 percent through dense forests and extremely difficult terrain.', NULL, 'Surface Water Travel: 20 mph (32 km) like a boat; can push/swim with arms at about 5 mph (8 km) if rear engine destroyed, or crawl along riverbeds. Underwater Travel: safe max depth 300 feet (91.5 m), can go as deep as 1000 feet (305 m); engine speed 20 mph (32 km), crawling speed max 15 mph (24 km), swimming with claws about 3 mph (4.8 km).', 'Height: 18 feet (4.4 m) fully erect, body section roughly 10 feet (3 m) belly to top; Width: 10 feet (3 m); Length: 24 feet (7.3 m)', '14 tons fully loaded', 650, 10000000, 'Black Market Cost: 14 million credits for a new, undamaged, full combat unit complete with missiles and weapons; 10 million without weapons. Poor availability for either.', 'A larger, more heavily armed and armored version of the Bug, designed as a heavy assault infantry support vehicle and APC with an extra pair of arms carrying particle beam cannons and rail guns, able to travel over rugged terrain, on the surface of water and underwater.', 'Rifts World Book 5: Triax and the NGR p.66-68'),
('x-1000-ulti-max', 'X-1000 Ulti-Max Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 44 mph (70 km) maximum, does NOT tire out its operator; cruising speed a more cautious 35 mph (56 km). Well suited for most terrains including underwater, not so well suited for climbing or mountain terrain.', 'Leaping: Not possible. Flying: Not possible; the rear rocket system is provided only for stability and balance.', NULL, 'Height: 16 feet (4.9 m) head to toe, exhaust tube extends to about 20 feet (6 m); Width: 9 feet (2.7 m); Length: 7 feet, 6 inches (1.9 m)', '2.5 tons', 400, 22000000, 'Black Market Cost: 22 million credits average, but has been known to sell for twice as much from time to time, for a new, undamaged, fully powered suit complete with the VX-180 Maxi-rail gun and mini-missiles. Poor availability.', 'A heavily armored, largely automated one-man combat unit that some consider a miniaturized robot rather than true power armor; slower and less mobile than the Jager or Predator but able to absorb much more damage, making it a strong support/defense and heavy assault unit; includes a rechargeable force field.', 'Rifts World Book 5: Triax and the NGR p.68-70'),
('x-2000-dyna-max', 'X-2000 Dyna-Max', 'rifts', 'robot', 'Two: One pilot and a co-pilot/gunner. One human-size passenger can squeeze into the storage space behind the seats.', 'One (squeezed into storage space behind the seats)', 'Running: 70 mph (112.6 km) maximum; cruising speed usually around 40 mph (64 km). Well suited for most terrains including underwater; reasonably good at climbing rope/cables and mountains, cannot climb sheer walls.', 'Leaping: 20 feet (6 m) high or lengthwise from a stationary position; 30 feet (9 m) high or 40 feet (13.7 m) lengthwise from a running start. Flying: Not possible.', NULL, 'Height: 25 feet (7.6 m) overall with the Slammer launchers up, 21 feet (6.3 m) to the top of the shoulder missile launcher, or 18 feet (5.4 m) to the top of the sensor head; Width: 12 feet (3.6 m) from shoulder to shoulder; Length: 6 feet (1.8 m)', '12 tons; 14 tons fully loaded', 550, 40000000, 'Black Market Cost: 40 million credits for a new, undamaged unit with all weapon systems intact.', 'A towering, 25-foot robot dreadnought designed to fight dragons, elementals, gargoyles, gurgoyles and other giant monsters, bristling with concussion Slammer missiles, forearm lasers, vibro-swords, rail gun arms, a hand-held rail gun, mini-missiles and flamethrowers.', 'Rifts World Book 5: Triax and the NGR p.70-73');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('t-21-terrain-hopper', 'Rear Jet Pack (1)', 50, NULL, 1),
('t-21-terrain-hopper', 'Chest Headlight (1)', 2, NULL, 2),
('t-21-terrain-hopper', 'Head', 60, 'Destroying the head/helmet has a 1-70% chance of knocking the pilot unconscious; small/difficult target, called shot only, attacker -3 to strike.', 3),
('t-21-terrain-hopper', 'Main Body', 170, 'Depleting the M.D.C. of the main body will shut the armor down completely, making it useless. Destroying the jet pack makes power jumps impossible.', 4),
('t-c20-terrain-hopper', 'Rear Jet Pack (1)', 50, NULL, 1),
('t-c20-terrain-hopper', 'Rear Mini-Missile Launcher (1)', 50, NULL, 2),
('t-c20-terrain-hopper', 'Chest Headlight (1)', 2, NULL, 3),
('t-c20-terrain-hopper', 'Forearm Laser (2, one each arm)', 10, 'Printed as a single value of 10 for the pair; not stated whether per-arm or combined.', 4),
('t-c20-terrain-hopper', 'Head', 70, 'Small/difficult target, called shot only, attacker -3 to strike; same unconscious risk as T-21.', 5),
('t-c20-terrain-hopper', 'Main Body', 200, 'Depleting the M.D.C. of the main body will shut the armor down completely.', 6),
('t-31-super-trooper', 'Shoulders/Upper arm (2)', 90, 'each', 1),
('t-31-super-trooper', 'Forearms (2)', 70, 'each', 2),
('t-31-super-trooper', 'Legs (2)', 120, 'each', 3),
('t-31-super-trooper', 'Leg Mini-Missile Launchers (2, lower leg)', 30, 'each', 4),
('t-31-super-trooper', 'Fusion Launchers (2, above each shoulder)', 50, 'each', 5),
('t-31-super-trooper', 'Maneuvering Jets (8, small)', 15, 'each', 6),
('t-31-super-trooper', 'Head', 75, 'Small/difficult target (shielded by armored neck collar and fusion launchers), called shot only, attacker -4 to strike; destroying it eliminates all optics/sensory systems.', 7),
('t-31-super-trooper', 'Main Body', 250, 'Depleting the M.D.C. of the main body will shut the armor down completely. The T-31 has a self-destruct mechanism to prevent capture.', 8),
('t-550-glitter-boy', 'Head', 200, 'Small/difficult target, called shot only, attacker -3 to strike; destroying it eliminates all optics/sensory systems.', 1),
('t-550-glitter-boy', 'Hands', 75, 'each', 2),
('t-550-glitter-boy', 'Arms', 200, 'each', 3),
('t-550-glitter-boy', 'Legs', 400, 'each', 4),
('t-550-glitter-boy', 'Leg Stabilizer Units (2)', 60, 'each', 5),
('t-550-glitter-boy', 'Boom Gun (1, right shoulder)', 150, NULL, 6),
('t-550-glitter-boy', 'Rear Ammo Drum (1)', 150, NULL, 7),
('t-550-glitter-boy', 'Vibro-Sword (1)', 30, NULL, 8),
('t-550-glitter-boy', 'Chest Spotlight (1)', 3, NULL, 9),
('t-550-glitter-boy', 'Main Body', 650, 'Depleting the M.D.C. of the main body will shut the armor down completely. Laser weapons do half damage.', 10),
('x-10a-predator', 'Shoulder Wings (2)', 50, 'each', 1),
('x-10a-predator', 'Main Rear Jets (2)', 80, 'each', 2),
('x-10a-predator', 'Lower Maneuvering Jets (2)', 30, 'each', 3),
('x-10a-predator', 'Right Hand and Forearm Pulse Cannon (1)', 100, NULL, 4),
('x-10a-predator', 'Mini-Missile Launcher (1, right shoulder)', 20, NULL, 5),
('x-10a-predator', 'Chest Headlight (1)', 2, NULL, 6),
('x-10a-predator', 'Left Forearm (1)', 80, NULL, 7),
('x-10a-predator', 'Shoulders and Upper Arm (2)', 150, 'each', 8),
('x-10a-predator', 'Legs (2)', 130, 'each', 9),
('x-10a-predator', 'Head', 90, 'Small/difficult target (shielded by exhaust tube, wings and shoulder plating), called shot only, attacker -4 to strike; destroying it eliminates all optics/sensory systems.', 10),
('x-10a-predator', 'Main Body', 380, 'Depleting the M.D.C. of the main body will shut the armor down completely. Destroying a wing makes flight impossible, though jet-powered leaps and stationary hover remain possible.', 11),
('x-60-flanker', 'Shoulder (2)', 50, 'each', 1),
('x-60-flanker', 'Rear Cooling Tube (2)', 80, 'each', 2),
('x-60-flanker', 'Hydraulic Hand Extensions (2)', 35, 'each', 3),
('x-60-flanker', 'Hands (2)', 40, 'each', 4),
('x-60-flanker', 'Lower Arms with Plate (2)', 100, 'each', 5),
('x-60-flanker', 'Legs (2)', 120, 'each', 6),
('x-60-flanker', 'Feet (2)', 50, 'each', 7),
('x-60-flanker', 'Mini-Missile Launchers (2, lower leg)', 30, 'each', 8),
('x-60-flanker', 'Chest Viewing Portal (1)', 15, 'Called shot only, attacker -6 to strike; tiny target.', 9),
('x-60-flanker', 'Spotlight (1, top of head)', 3, NULL, 10),
('x-60-flanker', 'Shoulder Lights (2)', 2, 'each', 11),
('x-60-flanker', 'Leg Lights (2)', 2, 'each', 12),
('x-60-flanker', 'Sensor Head', 90, 'Called shot only, attacker -3 to strike; destroying it eliminates all optics/sensory systems.', 13),
('x-60-flanker', 'Main Body', 380, 'Depleting the M.D.C. of the main body will shut the armor down completely. Printed a second time, after the Statistical Data block and before the Weapon Systems header, rather than in the main M.D.C. by Location list; likely an OCR reading-order artifact from the two-column layout.', 14),
('x-500-forager', 'Medium Range Missile Launchers (2)', 130, 'each', 1),
('x-500-forager', 'Belly Gun Turret (1)', 100, NULL, 2),
('x-500-forager', 'Hands (2)', 60, 'each', 3),
('x-500-forager', 'Forearms (2)', 100, 'each', 4),
('x-500-forager', 'Upper arms (2)', 140, 'each', 5),
('x-500-forager', 'Legs (2)', 200, 'each', 6),
('x-500-forager', 'Spotlight (1, head area)', 10, NULL, 7),
('x-500-forager', 'Small Headlights (2, shoulder area)', 5, 'each', 8),
('x-500-forager', 'Head Sensors (1; small circle)', 70, 'Called shot only, attacker -4 to strike; destroying it eliminates all optics/sensory systems.', 9),
('x-500-forager', 'Main Body', 350, 'Depleting the M.D.C. of the main body will shut the armor down completely.', 10),
('x-500-forager', 'Reinforced Pilot''s Compartment', 100, NULL, 11),
('x-535-hunter-jager', 'Hands (2)', 50, 'each', 1),
('x-535-hunter-jager', 'Forearms (2)', 70, 'each', 2),
('x-535-hunter-jager', 'Upper arms (2)', 120, 'each', 3),
('x-535-hunter-jager', 'Legs (2)', 120, 'each', 4),
('x-535-hunter-jager', 'Feet (2)', 80, 'each', 5),
('x-535-hunter-jager', 'Headlights (2, chest)', 5, 'each', 6),
('x-535-hunter-jager', 'TX-250 Rail Gun (1 or 2)', 100, NULL, 7),
('x-535-hunter-jager', 'Pilot View Port (1)', 25, 'Called shot only, attacker -9 to strike.', 8),
('x-535-hunter-jager', 'Optional: TX-843P Particle Beam Cannon', 170, NULL, 9),
('x-535-hunter-jager', 'Optional: TX-862FC Anti-Aircraft Cannon', 210, NULL, 10),
('x-535-hunter-jager', 'Optional: TX-871MM Missile Drum', 200, NULL, 11),
('x-535-hunter-jager', 'Optional: TX-884I Ion Cannon', 290, NULL, 12),
('x-535-hunter-jager', 'Head and Sensors (1)', 75, 'Called shot only, attacker -4 to strike; same penalty applies to hands and feet; destroying it eliminates all optics/sensory systems.', 13),
('x-535-hunter-jager', 'Main Body', 300, 'Depleting the M.D.C. of the main body will shut the armor down completely.', 14),
('x-535-hunter-jager', 'Reinforced Pilot''s Compartment', 80, NULL, 15),
('x-545-super-hunter', 'Ion Cannon (2; chest)', 150, 'each', 1),
('x-545-super-hunter', 'Hands (2)', 90, 'each', 2),
('x-545-super-hunter', 'Forearms (2)', 150, 'each', 3),
('x-545-super-hunter', 'Forearm Vibro-Swords (2)', 50, 'each', 4),
('x-545-super-hunter', 'TX-250 Rail Gun (1)', 100, NULL, 5),
('x-545-super-hunter', 'Upper arms (2)', 130, 'each', 6),
('x-545-super-hunter', 'Shoulder Mini-Missile Launchers (2)', 100, 'each', 7),
('x-545-super-hunter', 'Legs (2)', 200, 'each', 8),
('x-545-super-hunter', 'Feet (2)', 150, 'each', 9),
('x-545-super-hunter', 'Leg Missile Launchers (2)', 50, 'each', 10),
('x-545-super-hunter', 'Leg Flamethrowers (2)', 20, 'each', 11),
('x-545-super-hunter', 'Leg Spotlights (2; knees)', 5, 'each', 12),
('x-545-super-hunter', 'Chest Spotlights (2)', 5, 'each', 13),
('x-545-super-hunter', 'Pilot View Port (1)', 50, 'Called shot only, attacker -9 to strike.', 14),
('x-545-super-hunter', 'Pilot View Port Shield', 50, 'Slides into place as needed.', 15),
('x-545-super-hunter', 'Head and Sensors (1)', 75, 'Called shot only, attacker -4 to strike; same penalty applies to hands and feet; destroying it eliminates all optics/sensory systems.', 16),
('x-545-super-hunter', 'Main Body', 500, 'Depleting the M.D.C. of the main body will shut the armor down completely.', 17),
('x-545-super-hunter', 'Reinforced Pilot''s Compartment', 150, NULL, 18),
('x-622-bug', 'Forward Gun Turret (1)', 100, NULL, 1),
('x-622-bug', 'Ammo-Drum (1; belly)', 100, NULL, 2),
('x-622-bug', 'Rear Laser Turret (1, top)', 150, NULL, 3),
('x-622-bug', 'Rear Laser Turret Sensor/Optics (1)', 20, NULL, 4),
('x-622-bug', 'Arms/Legs (4)', 200, 'each', 5),
('x-622-bug', 'Claws (4)', 60, 'each', 6),
('x-622-bug', 'Rear Engine Section (for travelling on water)', 100, NULL, 7),
('x-622-bug', 'Flip-Top Missile Launcher (1; top)', 90, NULL, 8),
('x-622-bug', 'Main Hatch (1; side)', 90, NULL, 9),
('x-622-bug', 'Small Escape Hatch (2; rear side)', 45, 'each', 10),
('x-622-bug', 'Infrared Searchlight (1, large)', 15, NULL, 11),
('x-622-bug', 'Conventional Spotlights (2, forward)', 10, 'each', 12),
('x-622-bug', 'Forward Gun Turret Sensor/Targeting (1)', 25, NULL, 13),
('x-622-bug', 'Forward Sensor Array (1 section)', 30, 'The two smaller circular lenses clustered around the large infrared searchlight; called shot only, attacker -2 to strike; destroying it halves all combat bonuses and blinds the vehicle to instruments only.', 14),
('x-622-bug', 'Main Body', 400, 'Depleting the M.D.C. of the main body will shut the robot down completely.', 15),
('x-622-bug', 'Reinforced Pilot''s Compartment', 100, NULL, 16),
('x-821-landcrab', 'Concealed Missile Launcher (1; top)', 100, NULL, 1),
('x-821-landcrab', 'Forward Arm Guns (2)', 200, 'each', 2),
('x-821-landcrab', 'Rear Laser Turrets (2)', 70, 'each', 3),
('x-821-landcrab', 'Rear Optics (1)', 20, NULL, 4),
('x-821-landcrab', 'Arms/Legs (4)', 300, 'each', 5),
('x-821-landcrab', 'Large Claws (2; forward limbs)', 200, 'each', 6),
('x-821-landcrab', 'Small Claws (2; rear limbs)', 100, 'each', 7),
('x-821-landcrab', 'Rear Engine Section (for travelling on water)', 100, NULL, 8),
('x-821-landcrab', 'Main Hatch (1; top)', 100, NULL, 9),
('x-821-landcrab', 'Small Escape Hatch (1; rear, side)', 45, NULL, 10),
('x-821-landcrab', 'Infrared Searchlight (1, large)', 15, NULL, 11),
('x-821-landcrab', 'Conventional Spotlights (2, forward)', 10, 'each', 12),
('x-821-landcrab', 'Forward Gun Turret Sensor/Targeting (1)', 25, NULL, 13),
('x-821-landcrab', 'Forward Sensor Array (1 section)', 40, 'The two smaller circular lenses clustered around the large infrared searchlight; called shot only, attacker -2 to strike; destroying it halves all combat bonuses and blinds the vehicle to instruments only.', 14),
('x-821-landcrab', 'Main Body', 650, 'Depleting the M.D.C. of the main body will shut the robot down completely.', 15),
('x-821-landcrab', 'Reinforced Pilot''s Compartment', 100, NULL, 16),
('x-1000-ulti-max', 'Rear Exhaust Tubes (2)', 50, 'each', 1),
('x-1000-ulti-max', 'Rear Booster Jet (1)', 50, 'Printed as ''50 each'' though only one item is listed; kept as printed.', 2),
('x-1000-ulti-max', 'VX-180 Maxi-Rail Gun (1)', 100, NULL, 3),
('x-1000-ulti-max', 'VX-180 Laser (1)', 15, NULL, 4),
('x-1000-ulti-max', 'VX-180 Targeting System (1)', 20, NULL, 5),
('x-1000-ulti-max', 'Mini-Missile Shoulder Launchers (2)', 150, 'each', 6),
('x-1000-ulti-max', 'Forearms (2)', 120, 'each', 7),
('x-1000-ulti-max', 'Upper arms (2)', 100, 'each', 8),
('x-1000-ulti-max', 'Legs (2)', 200, 'each', 9),
('x-1000-ulti-max', 'Head Spotlight (1)', 10, NULL, 10),
('x-1000-ulti-max', 'Communications Cluster (1, top, rear)', 30, NULL, 11),
('x-1000-ulti-max', 'Head Sensors (top)', 70, 'Small/difficult target (shielded by exhaust tubes and shoulder plating), called shot only, attacker -4 to strike; destroying it eliminates all optics/sensory systems (rail gun targeting system still usable).', 12),
('x-1000-ulti-max', 'Main Body', 400, 'Depleting the M.D.C. of the main body will shut the armor down completely.', 13),
('x-1000-ulti-max', 'Force field', 100, 'Rechargeable; laser cannot fire while engaged; a fully depleted field needs 24 hours to regenerate, minor damage of 25 M.D.C. or less needs 8 hours.', 14),
('x-1000-ulti-max', 'Reinforced Pilot''s Compartment', 80, NULL, 15),
('x-2000-dyna-max', 'Slammer Missile Launchers (2; shoulders)', 150, 'each', 1),
('x-2000-dyna-max', 'Shoulder Slammer Launch Tubes (4)', 50, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 2),
('x-2000-dyna-max', 'Rail Gun Arms (2, small)', 50, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 3),
('x-2000-dyna-max', 'Forearm Lasers (2)', 50, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 4),
('x-2000-dyna-max', 'Forearm Vibro-Swords (2)', 50, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 5),
('x-2000-dyna-max', 'Arms (2)', 150, 'each', 6),
('x-2000-dyna-max', 'Hands (2)', 90, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 7),
('x-2000-dyna-max', 'TX-250 or VX-180 Rail Gun (1, hand-held)', 100, NULL, 8),
('x-2000-dyna-max', 'Legs (2)', 300, 'each', 9),
('x-2000-dyna-max', 'Feet (2)', 200, 'each', 10),
('x-2000-dyna-max', 'Leg Missile Launchers (2)', 100, 'each', 11),
('x-2000-dyna-max', 'Leg Flamethrowers (2)', 20, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 12),
('x-2000-dyna-max', 'Leg Spotlights (2; below knees)', 5, 'each; single-asterisk small/difficult target, called shot only, attacker -3 to strike', 13),
('x-2000-dyna-max', 'Chest Searchlight (1)', 5, NULL, 14),
('x-2000-dyna-max', 'Head and Sensors (1)', 75, 'Single-asterisk small/difficult target, called shot only, attacker -3 to strike; destroying it eliminates all optics/sensory systems.', 15),
('x-2000-dyna-max', 'Main Body', 550, 'Depleting the M.D.C. of the main body will shut the armor down completely.', 16),
('x-2000-dyna-max', 'Reinforced Pilot''s Compartment', 150, NULL, 17);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('t-c20-terrain-hopper', 1, 'Forearm Lasers (2)', '1D6 or 3D6 M.D. per single blast (two damage settings)', 1, '2000 feet (610 m)', 'Equal to the number of combined hand to hand attacks of the person in the suit (usually 4-6)', 'Effectively unlimited', NULL, NULL),
('t-c20-terrain-hopper', 2, 'Back mounted Mini-Missile Launcher', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One at a time or volleys of two', 'Six', NULL, NULL),
('t-c20-terrain-hopper', 3, 'Hand-held weapon (Energy Rifle, Light Rail Gun, sidearm, knife, sword, hand grenades)', NULL, 0, NULL, NULL, NULL, NULL, 'Carried on belt/chest, not built in. Pilot is -3 to strike when leaping or flying.'),
('t-31-super-trooper', 1, 'F4-Dual Fusion Shoulder Launchers (2)', '2D6 x 10 M.D.; blast area is 10 feet (3 m)', 1, '300 feet (91.5 m)', 'One or two', 'A total of four; two per each launcher', NULL, 'Fusion block missiles, not conventional mini-missiles; electromagnetic/adhesive nose; time delay 3-30 sec; malfunction table: 01-65 normal, 66-85 timer faulty (detonates 2D6 sec early/late), 86-00 dud (destroyed by 8 M.D., does not detonate).'),
('t-31-super-trooper', 2, 'MAE-3 Hand Charges (Maysies)', '1D6 x 10 M.D. with 5 foot (1.5 m) blast area for the two small disks; 2D4 x 10 M.D. with 10 foot (3 m) blast area for the one large disk', 1, 'Tossed 1D4 x 10+30 yards (max 210 ft/64 m, min 120 ft/36.5 m); no bonuses to strike, natural dice rolls only', 'One per melee action', 'Three total; two small and one large', NULL, 'Plastique explosive charges, molecular adhesion; detonated by device or electrical charge only; 01-20% chance of detonation if struck by lightning/electrical discharge; characters of P.S. 20-30 can throw one 1D4x10 yards/meters at -4 to strike.'),
('t-31-super-trooper', 3, 'Leg Mini-Missile Launchers (2)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.); fragmentation seldom used', 1, 'Usually about a mile', 'One at a time or volleys of two, three or four', '14 total; seven missiles in each leg', NULL, NULL),
('t-31-super-trooper', 4, 'RVB-31 Vibro-Blade', '2D4 M.D.', 1, 'Hand to hand combat', NULL, NULL, NULL, 'Concealed in the right arm; used to cut/stab thin armor and sever cords/hoses.'),
('t-31-super-trooper', 5, 'LGL-31 Grapnel and Launcher', 'None', 0, '100 feet (30.5 m) of lightweight cord (retractable)', NULL, NULL, NULL, 'Concealed in the left arm; fires a grappling hook and line.'),
('t-31-super-trooper', 6, 'PL-31 Palm Laser Torch (2)', '3D6 per single blast or 6D6 per double blast (both hands combined); blast area is 10 feet (3 m)', 1, 'One foot (0.3 m)', 'Equal to the number of hand to hand melee actions of the pilot (plus power armor bonuses)', 'Effectively unlimited', NULL, 'Located at the base of the palm/wrist of each hand.'),
('t-31-super-trooper', 7, 'Hand-held weapons', NULL, 0, NULL, NULL, NULL, NULL, 'TX-42 variable pulse laser standard issue, TX-50 or other weapons substitutable; officers may also wear a sidearm or carry an additional vibro-blade.'),
('t-31-super-trooper', 8, 'Hand to Hand Combat', 'Normal Punch or Kick 1D6 M.D.; Power Punch 2D6 M.D. (counts as two attacks); Jet Assisted Leap Kick 2D6+2 M.D. (two attacks); Jet Assisted Body Slam/Ram 1D6+2 M.D.', 1, NULL, NULL, NULL, NULL, 'All other abilities same as Basic/Elite Power Armor Combat Training, Rifts RPG p.45.'),
('t-550-glitter-boy', 1, 'TX-550 Boom Gun/Rail Gun (1)', 'One Boom Gun flechette round holds 200 slugs that inflict 3D6 x 10 M.D.', 1, '11,000 feet (about two miles/3.2 km)', 'Equal to the number of combined hand to hand attacks of the pilot and his power armor (usually 4-6)', '100 rounds; hand-reload about 15 min, or ammo drum swap by field mechanic about 3 min', NULL, 'Fires flechette rounds at Mach 1.5, creating a sonic boom; deafens/penalizes characters within 200 ft without ear protection, shatters glass and shakes buildings/vehicles within 300 ft; leg pylons and jet thrusters stabilize recoil.'),
('t-550-glitter-boy', 2, 'TX-550 Anti-Personnel Laser (1)', '3D6 M.D. per blast', 1, '1000 feet (305 m)', 'Equal to the number of combined hand to hand attacks of the pilot and his power armor (usually 4-6)', 'Effectively unlimited', NULL, 'Located above the left shoulder; rotates 45 degrees in all directions.'),
('t-550-glitter-boy', 3, 'TX-550 Mini-Missile Launchers (4)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One at a time or volleys of two, three or four', 'A total of 12; three mini-missiles in each of the four launch compartments', NULL, NULL),
('t-550-glitter-boy', 4, 'Vibro-Sword (1; right arm)', '5D6 M.D.', 1, NULL, NULL, NULL, '+1 to strike and +1 to parry when engaged in hand to hand combat', 'Large, retractable, built into the right forearm.'),
('t-550-glitter-boy', 5, 'Hand-held weapon', NULL, 0, NULL, NULL, NULL, NULL, 'TX-500 standard issue, TX-50 or VX Maxi-Rail Gun substitutable (latter only for special missions; reduces speed/maneuverability by 25%).'),
('t-550-glitter-boy', 6, 'Hand to Hand Combat', 'Bonuses in addition to Power Armor Combat Training: +2 to strike with Boom Gun, +1 on initiative, +2 to roll with impact, -1 dodge penalty (-3 when pylons engaged)', 1, NULL, NULL, NULL, NULL, NULL),
('x-10a-predator', 1, 'X-10-453A Pulse Cannon (1, right arm)', '1D4 x 10 M.D. per multiple blast volley of four simultaneous energy pulses (counts as one melee attack/action) or a single pulse for 2D4 M.D.', 1, '4000 feet (1200 m)', 'Equal to number of combined hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Hooked directly to the armor''s nuclear power supply.'),
('x-10a-predator', 2, 'Dual Shoulder Mini-Missile Launcher', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation for anti-personnel', 1, 'Usually about a mile', 'One or two', 'Two', NULL, NULL),
('x-10a-predator', 3, 'Hand-held weapon', NULL, 0, NULL, NULL, NULL, NULL, 'Space and bulk limits addition to one weapon, fired only by the left hand; right-handed pilots are -2 to strike.'),
('x-10a-predator', 4, 'Hand to Hand Combat', '-1 dodge penalty. Normal Punch 1D6+1 M.D.; Claw Punch 2D4 M.D.; Claw Power Punch 3D6 M.D.; Claw Crush or Tear 1D6+1 M.D.', 1, NULL, NULL, NULL, NULL, NULL),
('x-60-flanker', 1, 'Extendable Hydraulic Hands/Arms', NULL, 0, NULL, NULL, NULL, NULL, 'Extends reach by six feet (1.2 m; total reach 13 feet/3.63 m); used to reach into narrow places such as storm drains, ventilator shafts, tunnels.'),
('x-60-flanker', 2, 'Riot Baton Launchers (2)', '1D4 S.D.C. plus the impact has a 50 percent chance of knocking a character off his feet (loses initiative and one melee attack/action); a called shot can knock a weapon from a hand; 01-25 percent chance of stunning for 1D4 melee rounds', 0, '400 feet (120 m)', 'Equal to combined hand to hand attacks of the pilot (usually 4-6), or a short volley of two to eight shots', '64 total; 32 in each arm', NULL, 'Each additional baton in a volley adds 10 percent to the likelihood of knockdown/stun.'),
('x-60-flanker', 3, 'Flip-Top Shoulder Canister Launchers (2)', 'Varies by grenade type: stun/flash and smoke grenades do no mega-damage; fragmentation grenades can be substituted for 2D6 M.D. with a 20 foot blast radius', 0, '25 to 150 feet (7.6 to 46 m)', 'One at a time or a volley of two or four', '16 total; eight in each shoulder', NULL, 'Concealed under the shoulder armor plates; used for riot control and anti-terrorist operations.'),
('x-60-flanker', 4, 'Dual Leg Mini-Missile Launchers (2)', 'Varies with missile type; tear gas standard issue, explosive mini-missiles or smoke missiles can be substituted', 0, 'Tear gas missiles: 4000 feet (1200 m) maximum', 'One at a time or a volley of two or four', 'Total of 16; eight in each leg', NULL, NULL),
('x-60-flanker', 5, 'Hand-held weapon', NULL, 0, NULL, NULL, NULL, NULL, 'TX-41 is standard issue for infantry units.'),
('x-60-flanker', 6, 'Hand to Hand Combat', 'Restrained Punch 4D6+15 S.D.C.; Full Strength Punch 1D6 M.D.; Power Punch is not available; Crush or Tear 1D4 M.D.; Body Flip 1D4 M.D.', 1, NULL, NULL, NULL, NULL, NULL),
('x-500-forager', 1, 'Dual Shoulder, Medium Range Missile Launchers (2)', 'Varies with missile type; standard military issue armor piercing (2D4x10 M.D.; multi-warhead whenever possible) or plasma (2D6x10); fragmentation for anti-personnel', 1, 'Usually about 40+ miles (64+ km)', 'One at a time or in volleys of two or four', '16 missiles; eight in each launcher', NULL, 'Both launchers capable of 180 degree upward rotation.'),
('x-500-forager', 2, 'Ion Belly Gun Turret', '4D6 M.D. per single blast or 1D4 x 10 per dual simultaneous blast', 1, '4000 feet (1200 m)', 'Equal to number of combined hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Turret rotates 90 degrees in all directions; the entire upper torso section can also rotate 360 degrees.'),
('x-500-forager', 3, 'Hand to Hand Combat', 'Crush, Pry or Tear 2D4 M.D.; Dig 2D6 M.D.; Stomp 2D4 M.D.', 1, NULL, NULL, NULL, NULL, 'All other abilities same as the UAR-1 Enforcer, Rifts RPG pages 44 and 45.'),
('x-535-hunter-jager', 1, 'TX-250 Maxi-Rail Gun (1 or 2)', 'A full damage burst fires 30 rounds and inflicts 6D6 M.D.; a short burst of 15 rounds does 3D6 M.D.; a single round does 1D4 M.D.', 1, '6000 feet (1828 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Short clip holds 300 rounds (10 full bursts or 20 half bursts); belt feed drum holds 3000 rounds (100 full bursts or 200 half bursts); reload about three minutes untrained, one minute trained; requires strength of 28 or higher to handle the drum', NULL, 'Own laser targeting and radar tracking system, range 6000 feet (1828 m); bonuses +1 to strike, +1 to parry and dodge.'),
('x-535-hunter-jager', 2, 'Head Guns (2)', 'A full damage burst fires 30 rounds and inflicts 6D6 S.D.C.; a short burst of 15 rounds does 3D6 S.D.C.; a single round cannot be fired', 0, '2000 feet (610 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', '2000 rounds capable of firing 66 full damage bursts or 133 half damage bursts; reload about five minutes untrained, two minutes by field mechanics; requires strength of 20 or higher', NULL, 'Used primarily against D-bee refugees and non-mega-damage foes; real bullets can be replaced with rubber ones for riot control.'),
('x-535-hunter-jager', 3, 'Forearm Mini-Missile Launchers (2)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One or two', 'Six total; three in each arm', NULL, NULL),
('x-535-hunter-jager', 4, 'TX-843P Interchangeable Particle Beam Cannon (1)', '2D4 x 10 M.D. per single blast', 1, '3000 feet (914 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Effectively unlimited', NULL, 'Reduces the X-535 Hunter''s speed and combat bonuses by 25 percent; weighs three tons with its own energy supply; can be aimed up or down 80 degrees.'),
('x-535-hunter-jager', 5, 'TX-862FC Interchangeable, Recoilless, Anti-Aircraft Flak Gun (1)', 'Single round 4D6 M.D., two rounds 1D6 x 10 M.D., or a rapid fire volley of six rounds 3D6 x 10 M.D.', 1, '10,000 feet (3048 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Total 800; 400 rounds in each giant ammo-drum; 133 rapid fire volleys of six rounds or 400 two round volleys', NULL, 'Reduces the X-535 Hunter''s speed and combat bonuses by 50 percent; weighs 4.5 tons with its own energy supply; own laser targeting/radar range 11,000 feet (3353 m), bonus +1 to strike automatic aerial or +2 fired by pilot.'),
('x-535-hunter-jager', 6, 'TX-884I Interchangeable Ion Cannon and Missile Launcher', 'Cannon: 1D6 x 10 per blast. Missiles: varies with missile type; standard military issue armor piercing (2D4 x 10 M.D.; multi-warhead) or plasma (2D6 x 10); fragmentation for anti-personnel', 1, 'Cannon: 4000 feet (1200 m); Missiles: usually about 40+ miles (64+ km)', 'Cannon equal to number of combined hand to hand attacks (usually 4-8); Missiles one at a time or in volleys of two or four', 'Cannon effectively unlimited; Missiles 12 total, six in each launcher', NULL, 'Own laser targeting/radar range 6000 feet (1828 m), bonus +1 to strike; overall weight 6 tons; both missile launchers capable of 180 degree upward rotation.'),
('x-535-hunter-jager', 7, 'TX-871MM Interchangeable Rotary Missile Drum Launchers (2)', 'Varies with missile type; standard military issue armor piercing (1D6x10 M.D.) or plasma (1D6x10 M.D.); fragmentation and others for anti-personnel; typical combat mix is 48 armor piercing, 40 plasma, 4 fragmentation and 4 smoke', 1, 'Armor Piercing: 5 miles (8 km); Plasma: 3 miles (4.8 km)', 'One at a time or in volleys of 2, 4, 8, 16, 32 or 48', '96 short-range missiles total; 48 in each launcher', NULL, 'Own laser tracking, radar, targeting, communications and standard robot sensor systems, range 6000 feet (1828 m), missile bonus +2 to strike; overall weight 6 tons.'),
('x-535-hunter-jager', 8, 'Hand to Hand Combat', 'Restrained Punch 1D6~10 S.D.C. (OCR ambiguous, possibly 1D6+10); Full Strength Punch 1D6 M.D.; Power Punch 2D6 M.D. (counts as two attacks); Crush, Pry or Tear 1D4 M.D.; Kick 1D6 M.D.; Leap Kick 2D6 M.D. (counts as two attacks); Power Leap Kick 3D6 M.D. (running start, counts as two attacks); Body Flip/Throw 1D4 M.D.', 1, NULL, NULL, NULL, NULL, 'Bonuses: +2 to strike, +4 to parry, +3 to dodge, +4 to roll with impact, +4 to pull punch, +10 percent to climb, +1 melee action/attack at levels 1, 2, 4, 7, 10 and 14.'),
('x-545-super-hunter', 1, 'TX-250 Rail Gun (1 or 2)', 'A full damage burst fires 30 rounds and inflicts 6D6 M.D.; a short burst of 15 rounds does 3D6 M.D.; a single round does 1D4 M.D.', 1, '6000 feet (1828 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Short clip holds 300 rounds (10 full bursts or 20 half bursts); belt feed drum holds 3000 rounds (100 full bursts or 200 half bursts); reload about three minutes untrained, one minute trained; requires strength of 28 or higher', NULL, 'Only one is issued to this bot; own laser targeting/radar range 6000 feet (1828 m), bonuses +1 to strike, +1 to parry and dodge.'),
('x-545-super-hunter', 2, 'Head Guns (2)', 'A full damage burst fires 30 rounds and inflicts 6D6 S.D.C.; a short burst of 15 rounds does 3D6 S.D.C.; a single round cannot be fired', 0, '2000 feet (610 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', '2000 rounds capable of firing 66 full damage bursts or 133 half damage bursts; reload about five minutes untrained, two minutes by field mechanics; requires strength of 20 or higher', NULL, NULL),
('x-545-super-hunter', 3, 'Ion Cannons (2)', '1D4 x 10 per single blast or 2D4 x 10 per simultaneous double blast', 1, '3000 feet (914 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Effectively unlimited', NULL, 'Located in the lower chest area; each angles 30 degrees in all directions.'),
('x-545-super-hunter', 4, 'Shoulder Mini-Missile Launchers (2)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One at a time or in volleys of 2, 4 or 6', '24 total; 12 in each shoulder region', NULL, NULL),
('x-545-super-hunter', 5, 'Forearm Mini-Missile Launchers (2)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One or two', 'Six total; three in each arm', NULL, NULL),
('x-545-super-hunter', 6, 'Forearm Vibro-Sword (2)', '4D6 M.D.', 1, NULL, NULL, NULL, NULL, 'Concealed, extendable and retractable; six feet long (1.8 m).'),
('x-545-super-hunter', 7, 'Lower Leg Mini-Missile Launchers (2)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One or two', '8 total; four in each leg', NULL, NULL),
('x-545-super-hunter', 8, 'Flamethrowers (2)', '1D4 M.D. per single blast or 2D4 per simultaneous double blast of napalm-like fire; 01-95 percent chance of setting combustible material on fire, 01-60 percent chance of setting living plants/trees on fire; fire does an additional 1D4 M.D. per melee round and burns for a minimum of 2D4 minutes', 1, '200 feet (61 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', '20 blasts total, 10 from each leg', NULL, '360 degree rotation turret located on the inside of each lower leg.'),
('x-545-super-hunter', 9, 'Hand to Hand Combat', 'Restrained Punch 1D6 M.D.; Full Strength Punch 2D6 M.D.; Power Punch 3D6 M.D. (counts as two attacks); Crush, Pry or Tear 1D6 M.D.; Kick 1D6 M.D.; Leap Kick not possible; Body Flip/Throw 1D4 M.D.; Body Block/Ram 2D4 M.D.', 1, NULL, NULL, NULL, NULL, 'Bonuses: +2 to strike, +3 to parry, +2 to dodge, +2 to roll with impact, +2 to pull punch, +1 melee action/attack at levels 1, 3, 6 and 10.'),
('x-622-bug', 1, 'TX-150 Man-Killer Forward Rail Gun (1)', 'Depleted uranium slugs inflict 1D6 x 10 M.D. from a standard burst of 30 rounds; this weapon can only fire bursts', 1, '4000 feet (1200 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', '3000 round drum capable of firing 100 bursts; reload about three minutes untrained, one minute by field mechanic; requires strength of 28 or higher', NULL, 'Own laser targeting and short-range radar (5 mile/8 km), range 6000 feet (1828 m), bonus +2 to strike; turret rotates 360 degrees, gun moves up/down 90 degrees; low-radiation Uranium Rounds substitutable, inflict 2D4x10 M.D. to supernatural creatures and prevent bio-regeneration until removed.'),
('x-622-bug', 2, 'Rear Laser Turret', '2D6 M.D. per single blast or 6D6 rapid-fire pulse of three nearly simultaneous blasts', 1, '4000 feet (1200 m)', 'Equal to number of combined hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Own optical, laser targeting, short range radar (5 mile/8 km) and tracking system; range 6000 feet (1828 m), bonus +2 to strike; turret rotates 360 degrees, gun moves up/down 90 degrees.'),
('x-622-bug', 3, 'Flip-Top Mini-Missile Launcher (1)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One at a time, or in a volley of two, three or four', '8 total', NULL, NULL),
('x-622-bug', 4, 'Hand to Hand Combat', 'Restrained Claw strike 1D6 M.D.; Full Strength Punch 2D6 M.D.; Power Punch 4D6 M.D. (counts as two attacks); Crush or Pry with claws 2D4 M.D.; Cut/Snap or Tear with claws 2D6 M.D.; Kick not possible; Leap Kick not possible; Body Flip/Throw 1D6 M.D.; Body Block/Ram 2D6 M.D. (counts as two attacks)', 1, NULL, NULL, NULL, NULL, 'Bonuses: +1 to strike, +2 to parry, +2 to dodge, +2 to roll with impact, +2 to pull punch, +1 melee action/attack at levels 1, 3, 7 and 11.'),
('x-821-landcrab', 1, 'Forward Weapon Arms (2) - Particle Beam Cannon', '2D4 x 10 M.D. per single blast', 1, '2000 feet (610 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Effectively unlimited', NULL, 'Independent power supply; arms swing side to side and up/down in a 180 degree arc, same as a human arm.'),
('x-821-landcrab', 1, 'Forward Weapon Arms (2) - Rail Gun', 'Depleted uranium slugs inflict 1D4 x 10 M.D. from a standard burst of 20 rounds; this weapon can only fire bursts', 1, '4000 feet (1200 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', '2000 round drum capable of firing 100 bursts; reload about three minutes untrained, one minute by field mechanic; requires strength of 28 or higher', NULL, 'Infrared targeting beams mounted on top of each barrel, range 4000 feet (1200 m), bonus +1 to strike; low-radiation Uranium Rounds substitutable, inflict 1D6x10 M.D. to supernatural creatures.'),
('x-821-landcrab', 2, 'Rear Laser Turrets (2)', '3D6 M.D. per single blast or 6D6 per dual, simultaneous blasts from both lasers aimed at the same target', 1, '4000 feet (1200 m)', 'Equal to number of combined hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Each turret fires in a 60 degree angle in all directions and can fire in unison at the same target or two different targets; secondary optical/sensory system located between the turrets.'),
('x-821-landcrab', 3, 'Concealed Mini-Missile Launcher (1)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One at a time, or in a volley of two, three or four', '16 total', NULL, 'Rear panel with the identification number conceals the launcher; plate raises to fire then snaps shut.'),
('x-821-landcrab', 4, 'Hand to Hand Combat', 'Restrained Claw strike 1D6 M.D.; Full Strength Punch 3D6 M.D.; Power Punch 5D6 M.D. (counts as two attacks); Crush or Pry with claws 2D6 M.D.; Cut/Snap or Tear with claws 3D6 M.D.; Kick not possible; Leap Kick not possible; Body Flip/Throw 1D6 M.D.; Body Block/Ram 3D6 M.D.', 1, NULL, NULL, NULL, NULL, 'Bonuses: +1 to strike, +3 to parry, +2 to dodge, +1 to roll with impact, +1 to pull punch, +1 melee action/attack at levels 1, 3, 7 and 11.'),
('x-1000-ulti-max', 1, 'VX-180 Maxi-Rail Gun (1)', 'A burst is 40 rounds and inflicts 1D6 x 10 M.D.; this weapon can only fire bursts', 1, '6000 feet (1828 m)', 'Equal to number of combined hand to hand attacks (usually 4-6)', '4000 round drum, 100 bursts; a second drum feeds immediately after the first is exhausted; reload about 5 minutes untrained, one minute trained, requires strength of 26 or higher', NULL, 'Own laser targeting/radar range 6000 feet (1828 m), bonuses +2 to strike, +1 to parry and dodge; auxiliary variable light frequency laser draws power from the armor or a 40-shot E-clip, 2D6 M.D., range 4000 feet (1200 m); man-killer depleted uranium rounds add +10 M.D. per 40-round burst, U-rounds add +10 M.D. (+20 vs supernatural beings).'),
('x-1000-ulti-max', 2, 'VX-160 Mini-Missile Launchers (2)', 'Varies with missile type; standard issue an equal number of armor piercing (1D4x10 M.D.) and plasma (1D6x10); fragmentation or riot control types for anti-personnel', 1, 'Usually about one mile (1.6 km)', 'One, or in volleys of two, four, or six', '30 total; 15 in each box', NULL, 'Letter box style launcher mounted above both shoulders, also shields the sensor head.'),
('x-1000-ulti-max', 3, 'Hand to Hand Combat', 'Restrained Punch 1D4 M.D.; Full Strength Punch 2D4 M.D.; Power Punch 3D6 M.D.; leaps and kicks are not possible', 1, NULL, NULL, NULL, NULL, NULL),
('x-2000-dyna-max', 1, 'Slammer Missile Launchers (2)', '2D4 x 10 M.D. from a direct hit; blast area 90 feet (27.4 m) diameter dealing 1D4 x 10 M.D. to those in the radius, 01-88 percent chance of knockdown, 01-65 percent chance of being stunned', 1, '6000 feet (1830 m; over a mile)', 'Typically one at a time, but can be fired in volleys of two', '8 total; 4 in each shoulder launcher', NULL, 'Concussion missiles designed to knock down and stun giant opponents or robots; a direct hit always knocks the victim down; a stunned victim is dazed, -10 to strike/parry/dodge/roll with impact/pull punch, loses initiative and half attacks per melee for 1D4 rounds, speed halved.'),
('x-2000-dyna-max', 2, 'Slammer Shoulder Missile Tubes (4)', 'Same as Slammer Missile Launchers above', 1, NULL, NULL, '4 total; one in each launch tube', NULL, 'All other stats and information are the same as the Slammer Missile Launchers.'),
('x-2000-dyna-max', 3, 'Forearm Lasers (2)', '4D6 M.D. per single blast or 1D4 x 10+6 M.D. per simultaneous double blast (counts as one melee action/attack)', 1, '6000 feet (1200 m) as printed; the foot and meter figures do not correspond to each other', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Effectively unlimited', NULL, NULL),
('x-2000-dyna-max', 4, 'Forearm Vibro-Swords (2)', '4D6 M.D.', 1, NULL, NULL, NULL, '+1 to strike and +2 to parry when engaged in hand to hand combat', 'Concealed, extendable and retractable; five feet long (1.5 m).'),
('x-2000-dyna-max', 5, 'Rail Gun Appendages (2)', 'A full damage burst fires 15 rounds and inflicts 3D6 M.D., or depleted uranium rounds inflict 4D6 M.D. per burst; single rounds or larger bursts cannot be fired', 1, '2000 feet (610 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Replaceable clip holds 300 rounds, capable of firing 20 blasts per arm; six additional magazines concealed in a groin storage compartment; reload takes about four seconds', NULL, 'Independent laser targeting, +1 to strike; tiny gun arms located at the waist.'),
('x-2000-dyna-max', 6, 'Lower Leg Mini-Missile Launchers (2)', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation and/or tear gas for anti-personnel', 1, 'Usually about a mile', 'One at a time or in volleys of 2, 3 or 4', '28 total; 14 in each leg (two rows of seven missiles stacked in each firing compartment)', NULL, NULL),
('x-2000-dyna-max', 7, 'Flamethrowers (2)', '1D4 M.D. per single blast or 2D4 per simultaneous double blast of napalm-like fire; 01-90 percent chance of igniting combustible material; fire does an additional 1D4 M.D. per melee round, burns a minimum of 2D4 minutes', 1, '200 feet (61 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'A total of 50 blasts, 25 from each leg', NULL, '360 degree rotation turret located on the inside of each lower leg.'),
('x-2000-dyna-max', 8, 'Hand to Hand Combat', 'Restrained Punch 1D6 M.D.; Full Strength Punch 2D6 M.D.; Power Punch 4D6 M.D. (counts as two attacks); Vibro-Blade 4D6 M.D.; Crush, Pry or Tear 1D6 M.D.; Kick 2D6 M.D.; Leap Kick 3D6 M.D. (counts as two attacks); Body Flip/Throw 1D6 M.D.; Body Block/Ram 2D4 M.D.; Stomp 1D6 M.D. against man-sized targets', 1, NULL, NULL, NULL, NULL, 'Bonuses: +2 to strike, +4 to parry, +3 to dodge, +4 to roll with impact, +4 to pull punch, +2 melee actions/attacks at level one, +1 additional melee action/attack at levels 4, 6, 9 and 12. Reduce combat bonuses by half and attacks per melee by two if there is no co-pilot to serve as gunner.'),
('x-2000-dyna-max', 9, 'Optional: TX-250 Rail Gun (1)', 'A full damage burst fires 30 rounds and inflicts 6D6 M.D.; a short burst of 15 rounds does 3D6 M.D.; a single round does 1D4 M.D.', 1, '6000 feet (1828 m)', 'Equal to number of combined hand to hand attacks (usually 4-8)', 'Short clip holds 300 rounds (10 full bursts or 20 half bursts); belt feed drum holds 3000 rounds (100 full bursts or 200 half bursts); reload about three minutes untrained, one minute trained; requires strength of 28 or higher', NULL, 'Own laser targeting/radar range 6000 feet (1828 m), bonuses +1 to strike, +1 to parry and dodge; other giant-size rail guns can be substituted.');

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is silent on collision, so what matters is how many rows are THERE.
SELECT 'vessels from p039-070' AS assertion,
       count(*) AS got, 13 AS want
  FROM vehicles WHERE slug IN ('t-21-terrain-hopper', 't-c20-terrain-hopper', 't-31-super-trooper', 't-550-glitter-boy', 'x-10a-predator', 'x-60-flanker', 'x-500-forager', 'x-535-hunter-jager', 'x-545-super-hunter', 'x-622-bug', 'x-821-landcrab', 'x-1000-ulti-max', 'x-2000-dyna-max');

SELECT 'their M.D.C.-by-location rows' AS assertion,
       count(*) AS got, 161 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('t-21-terrain-hopper', 't-c20-terrain-hopper', 't-31-super-trooper', 't-550-glitter-boy', 'x-10a-predator', 'x-60-flanker', 'x-500-forager', 'x-535-hunter-jager', 'x-545-super-hunter', 'x-622-bug', 'x-821-landcrab', 'x-1000-ulti-max', 'x-2000-dyna-max');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 68 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('t-21-terrain-hopper', 't-c20-terrain-hopper', 't-31-super-trooper', 't-550-glitter-boy', 'x-10a-predator', 'x-60-flanker', 'x-500-forager', 'x-535-hunter-jager', 'x-545-super-hunter', 'x-622-bug', 'x-821-landcrab', 'x-1000-ulti-max', 'x-2000-dyna-max');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-triax-vessels-p039-070.sql');
