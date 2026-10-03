-- Rifts World Book 25: China 2 - the Geofront's power armor, robot and
-- vehicles (printed 150-159), with their M.D.C.-by-location tables and weapon
-- systems. See apps/character-creator/docs/surveys/china-2.md, step 5.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-china-2-vehicles.sql
--
-- SCAN, page_offset +1. Every figure was read off a 200 dpi render by a
-- book-extract-worker. Cache p153 (printed 152) is a full-page art plate.
--
-- WHAT IS HERE (all new; no slug or name matched an existing vehicle):
--   power armor  PRC-STP100 Black Tiger, PRC-HY75 Red Falcon
--   robot        GD-1000 Gun Dragon
--   vehicles     the Cave Bike (a military scout motorcycle), the PC-86
--                Police Cruiser, the AB-101 Air Barge
--
-- Two readings were judgement calls and are noted on their rows: the Police
-- Cruiser's stray "-75" beside its main body is its reinforced pilot's
-- compartment (a two-column table), and its stunner and net cannon counts come
-- from the M.D.C. table, as the weapon entries print none. The Gun Dragon's
-- sensors are printed as the Black Tiger's, by reference.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book)
VALUES
  ('prc-stp100-black-tiger', 'Black Tiger "Shan Tung Pei" Power Armor (PRC-STP100)', 'rifts', 'power-armor', 'One pilot', NULL, 'running: 55 mph (88 km) maximum; tires operator at 20% of usual fatigue rate; leaping: 10 ft (3 m) high or across, +10 ft with running start; rear augmentation boosters 70 ft (21.3 m) up or across, cannot suspend in air', NULL, 'underwater: Minimal; floats; 8 mph (12.8 km); walks sea bed at 25% of walking/running speed; max ocean depth one mile (1.6 km)', 'Height 16 feet (4.9 m); Width 6 feet, 6 inches (2 m); Length 8 feet, 5 inches (2.6 m)', '2.5 tons fully loaded', 475, 25000000, '25 million credits. Exclusive to the Geofront.', 'China''s heavy nuclear-powered assault suit built around the rail-gun King Cannon, with shoulder missiles, an energy sword and a force field. Geofront-exclusive. Class: Heavy Infantry Tactical Assault Suit. Strength: Robot P.S. 40. Power: Nuclear; average energy life 20 years. Cargo: Minimal; foot compartment and storage for a rifle, handgun, survival knife, first-aid kit. Systems: language translator and depth gauge; Optical Systems (laser targeting, telescopic, passive nightvision, thermal-imaging, infrared, ultraviolet, polarization); Advanced Laser Targeting +2 to strike long-range, not hand to hand; Distress Homing Beacon (GPS useless; backup scrambled radio, 01-20% chance picked up); Self-Destruct: manual up to 5 min delay or auto at main body -25 M.D.C.; 2D4x10 M.D. in 15 ft (4.6 m) radius; Force field (stolen X-1000 Ulti-Max tech, just installed in last units). M.D.C. notes: * called shot, -4 to strike. ** depleting main body shuts down armor. M.D.C. comes off the force field first. Printed 151-153.', 'Rifts World Book 25: China 2 p.151-153'),
  ('prc-hy75-red-falcon', 'Red Falcon "Hong Ying" (PRC-HY75)', 'rifts', 'power-armor', 'One pilot', NULL, 'running: 60 mph (96 km) maximum; pilot tires at 10% of usual fatigue; leaping: 15 ft (4.6 m) high or 20 ft (6.1 m) across, +10 ft (3 m) with running start; rear jets 100 ft (30.5 m) up or 200 ft (61 m) across without flight', 'flying: hover up to 6000 ft (1829 m); max 300 mph (480 km), cruising 150 mph (240 km)', 'underwater: 4 mph (6.4 km/3.4 knots) paddling; 50 mph (80 km/43.2 knots) on jets skimming surface; max ocean depth 1000 ft (305 m)', 'Height 9 feet (2.7 m); Width wings down 4.5 feet (1.4 m); wings extended 11 feet (3.4 m); Length 5.5 feet (1.7 m)', '360 lbs (162 kg)', 275, 2500000, '2.5 million credits each. Exclusive to the Geofront.', 'Light nuclear-powered flying suit for recon and aerial assault, with a monstrous mask, shoulder wings, a heavy laser rifle and concealed mini-missiles. Class: Light aerial assault and combat suit. Strength: Robot P.S. 30. Power: Nuclear; average energy life 20 years. Cargo: None, but magnetic clamps carry four small sacks for grenades (up to 6) or three E-Clips per sack. Systems: Optical Systems (same list as Black Tiger); Advanced Laser Targeting +2 long-range; Distress Homing Beacon (30% chance picked up by enemy); Self-Destruct: same trigger; 2D4x10 M.D. to a 10 ft (3 m) area; Wings; rocket flight. M.D.C. notes: * called shot -4; destroying head eliminates optical/sensory systems and power armor bonuses. ** main body depletion shuts down. Destroying a wing makes flight impossible. Printed 153-154.', 'Rifts World Book 25: China 2 p.153-154'),
  ('gd-1000-gun-dragon', 'Gun Dragon "Chiang Long" (GD-1000)', 'rifts', 'robot', 'Five: pilot, copilot, communications/sensor officer, two gunners', 'plus a seat for one passenger or a third pilot', 'running: 30 mph (48 km); leaping: Not possible', NULL, 'underwater: None, sinks; walks on floor at one third max speed; max depth untested, suspected one mile (1.6 km), maybe twice', 'Height 24 feet (7.3 m) on all four; 44 feet (13.4 m) on hind legs; Width 32.5 feet (9.9 m); Length 77 feet (23.5 m) muzzle to tail tip', '20 tons', 1050, 50000000, '50 million credits to produce. Exclusive to the Geofront.', 'A giant nuclear dragon-shaped artillery robot built from alien tech, with five crew and a spread of ion, laser, missile and fire weapons. About 2,140 built, mostly held in reserve. Class: Heavy Mechanized Assault Robot. Strength: Robot P.S. 61. Power: Nuclear, average life 30 years. Cargo: Two lockers 4 ft (1.2 m) deep, 3 ft (.91 m) wide, 6 ft (1.8 m) tall. Systems: Those standard in all robots plus Black Tiger #1-4 (Optical Systems package, Advanced Laser Targeting, Distress Homing Beacon, Self-Destruct Mechanism). M.D.C. notes: * called shot -4. ** main body depletion shuts down. Printed 154-156.', 'Rifts World Book 25: China 2 p.154-156'),
  ('geofront-cave-bike', 'Cave Bike (military scout motorcycle)', 'rifts', 'vehicle', 'One pilot, a second person could ride in a pinch', NULL, 'ground: 180 mph (288 km) max; 90 mph (144 km) over very rough terrain at -25% piloting (-15% at 45 mph/72 km or slower); turbo boost to 250 mph (400 km) for 1D6 minutes, then one hour recharge, or four short spurts', NULL, NULL, 'Height 4.2 feet (1.3 m); Width 3 feet (.9 m); Length 5.1 feet (1.6 m)', '213 pounds (96 kg)', 85, 60000, '60,000 for electric (and gas converted) models, 2.1 million credits for nuclear', 'A lightweight cave-exploring motorcycle, now common in civilian hands; only the military version carries lasers and optional missile pods. Class: Military Scout Vehicle. Power: Electric, electric-solar combination and nuclear; majority electric. Range: Electric 100 miles (160 km); electric-solar 200 miles (320 km); nuclear unlimited (adds 2 million credits). Gasoline not used. Cargo: Optional side compartments hold equivalent of a large backpack. M.D.C. notes: Printed as Forward Lasers (2) - 10 with no ''each'', unlike rows below it. * called shot -4. ** main body shuts down. Printed 156-157.', 'Rifts World Book 25: China 2 p.156-157'),
  ('pc-86-geofront-police-cruiser', 'Police Cruiser (PC-86)', 'rifts', 'vehicle', '3: pilot, co-pilot, third officer to monitor prisoners or support', '8 police officers in addition; rear cages hold four people, six cramped', NULL, 'air: Max 400 mph (640 km), cruising about 150 mph (240 km); VTOL; hover stationary or up to 8,000 ft (2438 m)', NULL, 'Height 12 feet (3.7 m); Width 11 feet (3.4 m); Length 16 feet (4.9 m)', '3 tons', 225, 3000000, '3 to 4 million to produce. Exclusive to the Geofront.', 'A silent nuclear hover car for patrolling the Geofront cave cities, with stunners and nets and an optional missile launcher. Class: Police Patrol Vehicle. Power: Nuclear, 20 year life. Range: Effectively unlimited (nuclear); after 24 hours hover system overheats, four hour cooling. Cargo: Two cages in back: four people, six cramped; plus 8 officers; some cruisers lack cages. Systems: Silent hover flight; 50% of cruisers only have net and stunners. M.D.C. notes: The -75 printed beside Main Body 225 is read as the Reinforced Pilot''s Compartment 75 (two-column layout). ** main body shuts down. Printed 157-158.', 'Rifts World Book 25: China 2 p.157-158'),
  ('ab-101-geofront-air-barge', 'Air Barge (AB-101)', 'rifts', 'vehicle', 'Pilot, copilot and communications person required; a family of 24 live in comfort, 50-60 cramped', NULL, NULL, 'air: 70 mph (112 km) maximum, cruising 35 mph (56 km); VTOL; hover stationary or up to 3000 ft (914 m)', NULL, 'Height 65 feet (19.8 m) of which 30 (9.1 m) is the mast; Width 38 feet (11.6 m); Length 72 feet (21.9 m)', '12 tons', 200, 5000000, '5 million credits (mortgage, 4-8 family heads)', 'A generational family dwelling that floats on hover jets around the Geofront cave cities; unarmed by law. Class: Civilian vehicle. Power: Nuclear; 30 year life expectancy, most stretched to double; average barge has used 95% of fuel. Range: Effectively unlimited (nuclear); on minimal power can stay parked indefinitely, max speed then half. Cargo: Varies; up to three additional tons. M.D.C. notes: no asterisks printed. Printed 159.', 'Rifts World Book 25: China 2 p.159');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('prc-stp100-black-tiger', 'King Cannon', 225, NULL, 1),
  ('prc-stp100-black-tiger', 'Ammo Belt', 30, NULL, 2),
  ('prc-stp100-black-tiger', 'Head', 120, 'single asterisk: small or hard to hit (called shot)', 3),
  ('prc-stp100-black-tiger', 'Hands (2)', 80, 'each; single asterisk: small or hard to hit (called shot)', 4),
  ('prc-stp100-black-tiger', 'Arms (2)', 220, 'each', 5),
  ('prc-stp100-black-tiger', 'Energy Light Sword', 50, NULL, 6),
  ('prc-stp100-black-tiger', 'Shoulder Mini-Missile Launchers (2)', 210, 'each', 7),
  ('prc-stp100-black-tiger', 'Legs (2)', 275, 'each', 8),
  ('prc-stp100-black-tiger', 'Reinforced Pilot''s Compartment', 100, NULL, 9),
  ('prc-stp100-black-tiger', 'Rear Augmentation Boosters (2)', 170, 'each', 10),
  ('prc-stp100-black-tiger', 'Force Field', 100, NULL, 11),
  ('prc-stp100-black-tiger', 'Main Body', 475, 'depleting the main body shuts the machine down', 12),
  ('prc-hy75-red-falcon', 'Laser Rifle', 120, NULL, 1),
  ('prc-hy75-red-falcon', 'Gun Cable', 30, NULL, 2),
  ('prc-hy75-red-falcon', 'Arms (2)', 95, 'each', 3),
  ('prc-hy75-red-falcon', 'Legs (2)', 110, 'each', 4),
  ('prc-hy75-red-falcon', 'Energy Light Sword', 40, NULL, 5),
  ('prc-hy75-red-falcon', 'Shoulder Mini-Missile Launchers (2)', 50, 'each', 6),
  ('prc-hy75-red-falcon', 'Shoulder Wings (2)', 60, 'each', 7),
  ('prc-hy75-red-falcon', 'Main Rear Jets (2)', 70, 'each', 8),
  ('prc-hy75-red-falcon', 'Lower Maneuvering Jets (3)', 25, 'each', 9),
  ('prc-hy75-red-falcon', 'Head', 85, 'single asterisk: small or hard to hit (called shot)', 10),
  ('prc-hy75-red-falcon', 'Main Body', 275, 'depleting the main body shuts the machine down', 11),
  ('gd-1000-gun-dragon', 'Face Laser Turrets (10; 6 in place of eyes, 4 in cheeks)', 20, 'each; single asterisk: small or hard to hit (called shot)', 1),
  ('gd-1000-gun-dragon', 'Front Arms (2)', 200, 'each', 2),
  ('gd-1000-gun-dragon', 'Wrist Ion Guns (4; two per arm)', 30, 'each; single asterisk: small or hard to hit (called shot)', 3),
  ('gd-1000-gun-dragon', 'Shoulder Ion Turrets (2)', 120, 'each', 4),
  ('gd-1000-gun-dragon', 'Back Laser Turrets (2)', 120, 'each', 5),
  ('gd-1000-gun-dragon', 'Mini-Missile Launcher', 140, NULL, 6),
  ('gd-1000-gun-dragon', 'Rear Legs (2)', 250, 'each', 7),
  ('gd-1000-gun-dragon', 'Tail', 250, NULL, 8),
  ('gd-1000-gun-dragon', 'Tail Guns (4)', 75, 'each; single asterisk: small or hard to hit (called shot)', 9),
  ('gd-1000-gun-dragon', 'Head', 300, NULL, 10),
  ('gd-1000-gun-dragon', 'Main Body', 1050, 'depleting the main body shuts the machine down', 11),
  ('geofront-cave-bike', 'Forward Lasers (2)', 10, 'each; single asterisk: small or hard to hit (called shot)', 1),
  ('geofront-cave-bike', 'Forward Headlights (4)', 2, 'each; single asterisk: small or hard to hit (called shot)', 2),
  ('geofront-cave-bike', 'Tires (2)', 8, 'each; single asterisk: small or hard to hit (called shot)', 3),
  ('geofront-cave-bike', 'Windshield', 12, NULL, 4),
  ('geofront-cave-bike', 'Optional Side Storage Compartments (2)', 15, 'each', 5),
  ('geofront-cave-bike', 'Optional Side Mini-Missile Launchers (2)', 20, 'each', 6),
  ('geofront-cave-bike', 'Main Body', 85, 'depleting the main body shuts the machine down', 7),
  ('pc-86-geofront-police-cruiser', 'Hover Jet Clusters (6, two dozen directional jets)', 35, 'each; single asterisk: small or hard to hit (called shot)', 1),
  ('pc-86-geofront-police-cruiser', 'Front Lights (2)', 10, 'each; single asterisk: small or hard to hit (called shot)', 2),
  ('pc-86-geofront-police-cruiser', 'Police Light Top', 5, 'single asterisk: small or hard to hit (called shot)', 3),
  ('pc-86-geofront-police-cruiser', 'Police Lights Side (4)', 3, 'each; single asterisk: small or hard to hit (called shot)', 4),
  ('pc-86-geofront-police-cruiser', 'Stun Emitters (2)', 35, 'each', 5),
  ('pc-86-geofront-police-cruiser', 'Net Cannons (2)', 15, 'each', 6),
  ('pc-86-geofront-police-cruiser', 'Exit Hatch (in rear)', 75, NULL, 7),
  ('pc-86-geofront-police-cruiser', 'Front Ailerons (2)', 15, 'each; single asterisk: small or hard to hit (called shot)', 8),
  ('pc-86-geofront-police-cruiser', 'Side Ailerons (2)', 35, 'each', 9),
  ('pc-86-geofront-police-cruiser', 'Top Ailerons (2)', 25, 'each', 10),
  ('pc-86-geofront-police-cruiser', 'Mini-Missile Launcher', 50, NULL, 11),
  ('pc-86-geofront-police-cruiser', 'Reinforced Pilot''s Compartment', 75, NULL, 12),
  ('pc-86-geofront-police-cruiser', 'Front Windshield (2)', 50, 'each', 13),
  ('pc-86-geofront-police-cruiser', 'Top Windshields (2)', 20, 'each', 14),
  ('pc-86-geofront-police-cruiser', 'Main Body', 225, 'depleting the main body shuts the machine down', 15),
  ('ab-101-geofront-air-barge', 'Mast', 40, NULL, 1),
  ('ab-101-geofront-air-barge', 'Ornamental Head', 30, NULL, 2),
  ('ab-101-geofront-air-barge', 'Ornamental Tail', 20, NULL, 3),
  ('ab-101-geofront-air-barge', 'House', 100, NULL, 4),
  ('ab-101-geofront-air-barge', 'Hover Systems (6)', 35, 'each', 5),
  ('ab-101-geofront-air-barge', 'Main Body', 200, NULL, 6);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('prc-stp100-black-tiger', 1, 'Wang Pei "King Cannon" Multipurpose Rifle', 'rail gun (main cannon) 2D4x10 M.D. per shot; mini-gun 2D4x10 M.D.; laser 4D6 M.D.', 1, 'Main Cannon 6000 ft (1829 m); Mini-Gun 2000 ft (610 m); Laser 4000 ft (1219 m)', 'Each main cannon shot = one attack; mini-gun fires 10 round bursts only; laser single blasts only', '500 round belt rail gun; 1000 mini-gun rounds (100 bursts); laser effectively unlimited', NULL, 'Primary Assault, Anti-Demon and Monster. Secondary Defense. Weight 1300 lbs (585 kg). rail gun with flechette cartridge, mini-gun, and top-housing laser.'),
  ('prc-stp100-black-tiger', 2, 'Shoulder Mini-Missile Launchers (2)', 'Varies per missile; typically fragmentation and armor piercing', 0, 'One mile (1.6 km)', 'One at a time, or volleys of 2, 6, 8, or 10', '20 each launcher, 40 total', NULL, 'Primary Assault, Anti-Monster/Demon. Secondary Defense.'),
  ('prc-stp100-black-tiger', 3, 'Chi Yang Jen "Energy Light Sword"', '4D6 M.D.', 1, NULL, NULL, 'Remains charged indefinitely on nuclear supply', NULL, 'Primary Close Assault and Defense.'),
  ('prc-stp100-black-tiger', 4, 'Hand to Hand Combat (Power Armor Combat Elite: Black Tiger Cannon)', 'restrained punch 1D4 M.D.; full strength punch 2D6 M.D.; power punch 4D6 M.D. (counts as two attacks); kick 2D4 M.D.; running leap kick 4D6 M.D.; tear or pry with hands 1D6+2 M.D.; body block/ram 2D6 M.D.; full speed running ram 5D6 M.D. (counts as three attacks); stomp 2D4 M.D.', 1, NULL, NULL, NULL, '+2 extra attacks/actions per melee round plus pilot''s at level one, +1 attack at levels 3, 7, 11; +2 initiative, +2 strike, +2 parry, +1 dodge, +1 disarm, +2 pull punch, +3 roll with impact, punch or fall. Critical Strike same as pilot''s.', NULL),
  ('prc-hy75-red-falcon', 1, 'Heavy Laser Rifle', 'single shot 4D6 M.D.; triple pulse burst 1D6x10 M.D.', 1, '3000 ft (914 m)', 'Each blast one melee attack', 'Effectively unlimited tied to power supply; E-Clips: 12 single shots or four bursts per clip', NULL, 'Primary Assault and Anti-Monster/Demon. Secondary Defense and Sniping. Weight 20 lbs (9 kg).'),
  ('prc-hy75-red-falcon', 2, 'Shoulder Mini-Missile Launchers (2)', 'Varies per missile; typically mix of armor piercing or plasma', 0, 'One mile (1.6 km)', '1, 2, or 3 per launcher', 'Six total, three per launcher', NULL, 'Primary Assault and Anti-Monster/Demon. Secondary Defense and Anti-Aircraft.'),
  ('prc-hy75-red-falcon', 3, 'Chi Yang Jen "Energy Light Sword"', '3D6 M.D.', 1, NULL, NULL, 'Indefinite on power supply', NULL, 'Primary Close Assault and Defense.'),
  ('prc-hy75-red-falcon', 4, 'Hand to Hand Combat (Power Armor Combat Elite: Red Falcon)', 'restrained punch 6D6 S.D.C.; full strength punch 1D4 M.D.; power punch 2D4 M.D. (counts as two); kick 1D6 M.D.; power kick 2D6 M.D. (counts as two); running leap kick 3D6 M.D.; tear or pry with hands 1D4+2 M.D.; body block/ram 2D4 M.D.; full speed running ram 3D6 M.D.; flying ram 5D6 M.D. (running and flying ram count as three attacks)', 1, NULL, NULL, NULL, '+1 extra attack/action per melee round plus pilot''s at level one; +1 attack at levels 3, 6, 9, 12; +1 initiative on ground, +3 in air; +2 strike, +2 parry, +2 dodge on ground, +4 in air; +2 disarm, +2 pull punch, +3 roll with impact or fall. Critical Strike same as pilot''s.', NULL),
  ('gd-1000-gun-dragon', 1, 'Heavy Ion Shoulder Turrets (2)', 'single barrel 5D6 M.D.; double barrel 1D6x10; both turrets on same target 2D6x10 M.D. (counts as two attacks)', 1, '2000 ft (610 m)', 'each turret four times per melee round; each single or double blast one attack', 'Effectively unlimited', NULL, 'Primary Infantry Support. Secondary Anti-Fortification and Anti-Monster. 180 degree rotation, 45 degree arc; operated by a gunner.'),
  ('gd-1000-gun-dragon', 2, 'Back High-Powered Laser Turrets (2)', 'single laser beam 4D6 M.D.; double-barrel 1D4x10; both turrets together 2D4x10 M.D. (two attacks)', 1, '4000 ft (1219 m)', 'each turret four times per melee round', 'Effectively unlimited', NULL, 'Primary Attack and Anti-Personnel. Secondary Defense and Anticraft/Flyers. 360 degree rotation, 60 degree arc; text crosses printed 155-156 (range and payload on 156).'),
  ('gd-1000-gun-dragon', 3, 'Tail Guns (4)', '3D6 M.D. single; 6D6 simultaneous double; both pairs cannot train on same target', 1, '2000 ft (610 m)', 'Five attacks per melee round per pair; single or double counts as one', 'Unlimited', NULL, 'Primary Anti-Personnel and Defense.'),
  ('gd-1000-gun-dragon', 4, 'Wrist Ion Guns (4)', '3D6 M.D. per gun; double blast 6D6', 1, '1200 ft (366 m)', 'Three attacks per melee round per arm', 'Unlimited', NULL, 'Primary Anti-Monster/Demon and Defense.'),
  ('gd-1000-gun-dragon', 5, 'Face/Head Lasers (10)', '1D6 M.D. single; clusters of three 3D6 each and one 4D6; all 10 together 1D6x10 M.D. (or 6D10)', 1, '1200 ft (366 m)', 'Five attacks per melee round', 'Unlimited', NULL, 'Primary Anti-Monster/Demon and Defense.'),
  ('gd-1000-gun-dragon', 6, 'Fire Breath', '4D6 M.D. per double-barrel short burst; 01-70% chance of setting combustibles on fire', 1, '500 ft (152 m)', 'Twice per melee round', '50 blasts', NULL, 'Primary Anti-Personnel and Defense.'),
  ('gd-1000-gun-dragon', 7, 'Mini-Missile Launcher', 'Varies per missile (5D6 or 1D4x10 M.D.)', 1, 'One mile (1.6 km)', 'One at a time or volleys of 2, 4, 6, or 8; a volley is one attack and takes attacks from other weapons', '40 missiles', NULL, 'Primary Assault, Anti-Monster/Demon, Anti-Aircraft and Defense.'),
  ('gd-1000-gun-dragon', 8, 'Smoke Dispensers (12)', NULL, 0, NULL, NULL, '10 uses total per tube', NULL, 'smoke covers 120 ft (37 m) diameter; tear gas may be substituted.'),
  ('gd-1000-gun-dragon', 9, 'Hand to Hand Combat (Robot Combat Elite: Gun Dragon)', 'restrained punch 2D6 M.D.; full strength punch 1D4x10 M.D.; power punch 2D4x10+5 M.D. (two attacks); kick with rear legs 3D6 M.D.; tear or pry with hands 4D6 M.D.; tail strike 5D6 M.D.; body block/ram 5D6 M.D.; full speed running ram 1D6x10 M.D. (three attacks); stomp 4D6 M.D. (only targets smaller than 13 ft/4 m)', 1, NULL, NULL, NULL, 'Total attacks per melee round with weapons 26, divided between five people; +3 strike, +3 parry, +2 pull punch; penalty -2 dodge', NULL),
  ('geofront-cave-bike', 1, 'Forward Laser (2)', '1D6 M.D. single; 2D6 simultaneous dual', 1, '1200 ft (366 m)', 'each single or double blast counts as one of the pilot''s attacks', 'Nuclear unlimited; electric and gas use E-Clips (two); each clip 30 single or 15 dual blasts', NULL, 'Primary Anti-Personnel and Defense. military bikes only.'),
  ('geofront-cave-bike', 2, 'Optional Side Mini-Missile Launchers (2)', 'Varies (typically 5D6 or 1D4x10 M.D.), any mix incl. smoke', 1, 'roughly one mile (1.6 km)', 'one at a time or volley of two or three', 'Three per launcher', NULL, 'Primary Assault. Secondary Defense.'),
  ('pc-86-geofront-police-cruiser', 1, 'Phased Array Stunner (2)', 'Light Stun 1D6 S.D.C.; Normal Stun 3D6 S.D.C.; Heavy Stun 1D6 M.D.; Lethal omitted. Not effective vs M.D. body armor.', 1, '300 ft (91.5 m), 30 degree arc, up to 12 targets (light/normal only)', 'each shot one melee attack', 'Effectively unlimited', NULL, 'Primary Anti-crime, riot control and pacification of large crowds. stun duration: see Phased Emitter Pistol page 142; one under each cockpit; count 2 from the M.D.C. table Stun Emitters (2).'),
  ('pc-86-geofront-police-cruiser', 2, 'Net Cannons (2)', 'None; 1D6 S.D.C. mostly from being knocked down; nets 10 M.D.C.', 1, '300 ft (91.5 m)', 'each shot one melee attack', '6 nets per cannon', NULL, 'Primary Capture. grapples up to six human-size targets; count 2 from M.D.C. table.'),
  ('pc-86-geofront-police-cruiser', 3, 'Optional Mini-Missile Launcher', 'Varies per missile type', 0, 'One mile (1.6 km)', 'one at a time or volleys of 3, 5, or 10', '24: 12 smoke, 8 tear gas, four armor piercing (1D4x10 M.D.); no plasma in the city', NULL, 'Primary Assault & City Defense.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 6 China 2 vehicles are in' AS assertion, count(*) AS got, 6 AS want
  FROM vehicles WHERE slug IN ('prc-stp100-black-tiger', 'prc-hy75-red-falcon', 'gd-1000-gun-dragon', 'geofront-cave-bike', 'pc-86-geofront-police-cruiser', 'ab-101-geofront-air-barge');
SELECT 'their 62 M.D.C. locations are in' AS assertion, count(*) AS got, 62 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('prc-stp100-black-tiger', 'prc-hy75-red-falcon', 'gd-1000-gun-dragon', 'geofront-cave-bike', 'pc-86-geofront-police-cruiser', 'ab-101-geofront-air-barge');
SELECT 'their 22 weapon entries are in' AS assertion, count(*) AS got, 22 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('prc-stp100-black-tiger', 'prc-hy75-red-falcon', 'gd-1000-gun-dragon', 'geofront-cave-bike', 'pc-86-geofront-police-cruiser', 'ab-101-geofront-air-barge');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-china-2-vehicles.sql');
