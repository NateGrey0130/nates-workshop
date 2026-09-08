-- Underseas vessels from printed pages 195-210: the NGR and Triax navy -
-- power armour, a cyborg statted as a machine, four submarines and two capital
-- ships.

--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-underseas-vessels-p195-210.sql
--
-- See zzzzzz-underseas-vessels-p081-105.sql for the standing notes. Every page
-- here is past printed 130, so cache page = printed folio MINUS ONE.
--
-- THE BARRACUDA IS A CYBORG AND IT IS IN THIS TABLE ANYWAY, which is a call
-- worth stating. The rule the gear pass settled on was that an entry carrying a
-- `Model Type:` line is a vehicle - it has M.D.C. by location and numbered
-- weapon systems, which is the shape migration 048 built this table for. The
-- VX-20,000 has all three. Its `Class:` line reads "Full Conversion Cyborg -
-- Deep-Sea Heavy Assault", and that string is stored verbatim in
-- vehicle_class so nothing has to infer it. It is also the only row here with
-- TWO main bodies: the armour at 500 and the cyborg inside at 210, which the
-- book itself adds to 710. The 500 is in mdc_main_body and both keep their own
-- location rows.
--
-- NOT ONE OF THESE NINE HAS A PRICE. Every entry is NGR military and says "Not
-- available. Top Secret!" before naming an estimate - 4 million for the
-- TXD-100, 10-12 million for the Barracuda, 60 million for the X-6000, and so
-- on. An estimate is not a price. The Poseidon is the interesting one: it
-- states 4.2 billion credits TO BUILD, which is a real figure and still not a
-- market price, so it is in cost_note and the cost column stays NULL.
--
-- THE SEA MITE'S AND THE XS-30'S TORPEDOES DO HAVE PRICES - 20,000 credits for
-- a heavy, 8,000 for a light - and those are on the weapon rows, which is where
-- the book puts them.
--
-- ONE ROW IS NOT ON ANY EXPECTED LIST: the XS-24 Sea Bat, printed 201-202, sits
-- between the Sea Mite and the XS-30 with its own Model Type line. Verified in
-- the cache - the heading is on cache p200 and `Model Type: XS-24` on p201.
--
-- ONE ROW HAS NO READABLE HEADING. The XS-120's title sits in a band of
-- illustration garble at the foot of cache p203, so the printed name could not
-- be read at all. `Model Type: XS-120` on p204 is legible and unambiguous, and
-- that is what the name column holds - the book's own designation, not an
-- invented title. The prose calls it "a hydrofoil hybrid used as a patrol
-- boat/interceptor", which is in the description. Its Class line says Military
-- Attack Submersible while its own Speed line says it is not a submersible;
-- both are stored as printed.
--
-- PRINTED 194 AND 208 ARE BLANK ILLUSTRATION PAGES and nothing is lost with
-- either. 194 falls between the frogman armours finishing on 193 and the
-- TXD-100 opening on 195; 208 falls inside the Poseidon, between her M.D.C.
-- table on 207 and the "destroying the bridge" note resuming on 209.
--
-- THE POSEIDON'S WEAPON SYSTEMS SKIP NUMBER 6. They run 1, 2, 3, 4, 5, 7. Both
-- surrounding pages were searched and no "6." exists anywhere in the cache, and
-- the gap does not line up with either blank page - 208 falls before the weapon
-- list starts. So it is either the book skipping a numeral or a loss that
-- cannot be attributed, and it is recorded on system 7 rather than guessed at.
--
-- PRINTED 209 CAME OUT OF OCR WITH ITS TWO COLUMNS INTERLEAVED mid-line, the
-- tail of weapon system 4 welded to an M.D.C. note and system 3 welded to
-- system 7. The threads were separated by hand and nothing appears lost once
-- they are; recorded because the next reader of that page will meet it too.
--
-- THE BARRACUDA'S QUAD RIFLE PRINTS TWO SETS OF LASER RANGES - 3000/4000 feet
-- and 1400/6000 feet. Which is meant could not be settled from the page, so
-- BOTH are in the range field and neither is dropped.
--
-- THE SEA BAT CONTRADICTS ITSELF ON ITS RAIL GUN COUNT: the weapon heading says
-- five and the text says each side fin carries four. Both readings are on the
-- weapon row.
--
-- FOUR M.D.C. LINES ARE MISSING AN "each" their siblings carry - the TXD-100's
-- Legs and Forearm Lasers, the X-6000's Forearm Thrusters - and the XS-120's
-- Searchlight carries one on a single item. Transcribed as printed with the
-- anomaly noted, not silently normalised.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('txd-100-ultra-deep-sea-power-armor', 'TXD-100 Ultra Deep-Sea Power Armor', 'rifts', 'Sea-Air-Land Strategic Navy Assault Suit.', 'One. Exclusive to the NGR military.', NULL, 'Running 20 mph, or 30 mph with the propulsion system detached, which also gives +1 to dodge. Leaping is not possible without the thrusters, and 60 feet with them.', 'Flying 40 mph to a maximum altitude of 1,000 feet.', '60 mph (96.5 kmph; 51.6 knots).', '8 feet high, or 10 feet with the missile launcher; 5 to 10 feet wide across the wings; 6 feet long.', '1,600 lbs', 400, NULL, 'NO PRICE. "Not available. Top Secret! But would cost around 4 million credits." An estimate, not a price.', 'Triax''s all-environment power armour, taking after the SAMAS but heavier and slower in the air. It shares its detachable jet-thruster backpack with the Barracuda cyborg. Underwater it is walking artillery; in the air it is barely adequate.', 'Rifts World Book 7: Underseas p.195-196'),
('vx-20000-barracuda', 'VX-20,000 Barracuda', 'rifts', 'Full Conversion Cyborg - Deep-Sea Heavy Assault.', 'One human volunteer.', NULL, 'Running 60 mph, or 70 mph with the propulsion system detached, which also gives +1 to dodge. It cannot leap with the thrusters attached unless they are engaged - 60 feet assisted, 20 feet unassisted.', 'Flying 40 mph to a maximum altitude of 1,000 feet.', '60 mph (96.5 kmph; 51.6 knots) on the thrusters, or 5 mph (8 kmph; 4.3 knots) swimming without them.', '10 feet high, 5 feet wide, 6 feet long - 3 feet without the propulsion system.', '2 tons', 500, NULL, 'NO PRICE. "Not available. Top Secret! But would cost around 10-12 million credits."', 'A full conversion cyborg built for deep-sea reconnaissance and combat, statted as a machine because that is what it is - a cyborg body inside an armoured shell. It is the only user of the TXP Quad Rifle, and one of very few cyborgs able to do mega-damage barehanded.', 'Rifts World Book 7: Underseas p.196-199'),
('x-6000-transformable-sub', 'X-6000 Transformable Sub', 'rifts', 'Sea-Land Assault Robot.', 'One pilot. Exclusive to the NGR military.', 'Up to two.', 'Running 70 mph; leaping 20 feet, or 60 feet thruster-assisted.', 'Not possible.', '22 mph in the bipedal configuration, 30 mph as a submarine.', 'As a sub, 12 feet high, 8 to 20 feet wide across the wings, 20 feet long. Bipedal, 22 feet high, 16 feet wide, 8 feet long.', '1,600 lbs', 420, NULL, 'NO PRICE. "Not available. Top Secret! But would cost around 60 million credits."', 'An experimental machine that changes between a mini-submarine and a walking humanoid, so it can run down a target underwater and then board it.', 'Rifts World Book 7: Underseas p.199-200'),
('xs-20-sea-mite-mini-submarine', 'XS-20 Sea Mite Mini-Submarine', 'rifts', 'Military Submersible.', 'One pilot. Exclusive to the NGR military.', NULL, 'Not possible.', 'Not possible.', '25 mph surfaced, 50 mph dived.', '9 feet high, 20 feet wide fin to fin, 22 feet long.', '2 tons', 220, NULL, 'NO PRICE. "Not available. Top Secret! But would cost around 8 million credits." Its torpedoes DO have prices - see the weapon rows.', 'A one-man mini-submarine for exploration and combat, fast and manoeuvrable, carrying both heavy and light torpedoes and a bank of rail guns in its fins.', 'Rifts World Book 7: Underseas p.201'),
('xs-24-sea-bat-mini-submarine', 'XS-24 Sea Bat Mini-Submarine', 'rifts', 'Military Submersible.', 'One pilot, lying prone. Exclusive to the NGR military.', NULL, 'Not possible.', 'Not possible.', '30 mph surfaced, 35 mph dived.', '5 feet high, 10 feet wide, 17 feet long.', '1.5 tons', 260, NULL, 'NO PRICE. "Not available. Top Secret! But would cost around 7 million credits."', 'A small reconnaissance and sabotage submarine with a pair of articulated robot arms for salvage and demolition. If its observation bubble is shattered, armoured plates slide across.', 'Rifts World Book 7: Underseas p.201-202'),
('xs-30-torpedo-attack-sub', 'XS-30 Torpedo Attack Sub', 'rifts', 'Military Attack Submersible.', 'Five - a pilot, a co-pilot, a communications officer and two gunners. Exclusive to the NGR military.', 'Ten, or seven in light armour.', 'Not possible.', 'Not possible.', '25 mph surfaced, 50 mph dived. Depth 2 miles.', '12 feet high, 18 feet wide, 65 feet long.', '23 tons', 1200, NULL, 'NO PRICE. "Not available. Top Secret! But would cost around 28 million credits."', 'A patrol and escort submarine with six torpedo tubes and a laser turret above and below, meant to fight other submersibles, small ships, sea monsters and enemy power armour.', 'Rifts World Book 7: Underseas p.203-204'),
('xs-120-hydrofoil', 'XS-120', 'rifts', 'Military Attack Submersible.', 'Fourteen - a captain and pilot, a co-pilot, a communications officer, three gunners, two crewmen and six marines in TXD-100 Ultra armour. Exclusive to the NGR military.', 'Six more.', 'Not possible.', 'Not possible.', '180 mph (288 kmph; 154.8 knots) on the surface. The book says outright it is not a submersible.', '20 feet high, 40 feet wide, 100 feet long overall, of which 65 feet is the main body.', '22 tons', 1400, NULL, 'NO PRICE. "Not available; but would cost around 22 million credits."', 'A hydrofoil hybrid used as a patrol boat and interceptor - fast on the surface, and not a submarine at all despite the class line. It runs down pirates and enemy ships and escorts other NGR vessels, and it has been in service two years, unlike the secret designs around it.', 'Rifts World Book 7: Underseas p.204-205'),
('xs-400-escort-battleship', 'XS-400 Escort Battleship', 'rifts', 'Navy Battleship & Escort.', '40 officers, 200 enlisted and 244 air group personnel.', 'A large mixed complement the book itemises in full - Dragonwings, Infantry Support Platforms, TXD-100 Ultras, Predators, Terrain Hoppers, Hunters, Flankers, Glitter Boys, Super Troopers and Sea Bat mini-subs.', 'Not possible.', 'Not possible.', '60 mph (96.5 kmph; 51.6 knots) on the surface. It is not a submersible.', '80 feet high, 100 feet wide, 440 feet long, with an 80 foot VTOL flight deck.', '82,000 tons', 14000, NULL, 'NO PRICE. "Not available; but would cost around 150 million credits."', 'A compact destroyer and carrier in one, pairing heavy energy weapons with an embedded power armour and robot complement. It exists to support beach assaults and troop landings as much as to fight on the surface.', 'Rifts World Book 7: Underseas p.205-207'),
('ngr-poseidon-submersible-carrier', 'NGR Poseidon Submersible Carrier', 'rifts', 'Submersible Air-Sea-Land Carrier.', '2,200, or 5,710 with her standard troops. Five are in service and three more are being built.', '5,760 troops with room for 640 more. The book itemises a full mechanized, air and medical division - Bugs, Landcrabs, Leopard IIIs, Phantoms, Wilderness Crusaders, Super Troopers, Hunters, Dyna-Max, X-6000 Transformable Subs, Black Knights, TXD-100 Ultras, Dragonwings, Predators, Weapon Platforms, Dragonflies, Mosquitoes, Lightnings, fighter jets, medic pods and hover stations, 40 Sea Mites and 40 Sea Bats.', 'Not possible.', 'Not possible.', 'Surface 40 mph (64.3 kmph; 34.4 knots); submerged 50 mph (80 kmph; 43 knots).', '150 feet high, 320 feet wide, 1,600 feet long.', '179,000 tons fully loaded.', 20000, NULL, 'NO PRICE, but a BUILD cost the book states outright: "Top secret! Not available; but costs 4.2 billion credits to build." That is what she costs the NGR, not a market price, so the cost column stays NULL.', 'The flagship of the NGR navy and the second largest submarine in the setting after the USS Ticonderoga - an attack submarine, a mechanized division and an aircraft carrier at once, built as the spearhead of the secret Operation Sea Storm against the Gargoyle Empire.', 'Rifts World Book 7: Underseas p.207-210');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('txd-100-ultra-deep-sea-power-armor', 'Head', 90, NULL, 1),
('txd-100-ultra-deep-sea-power-armor', 'Wings (2)', 90, 'Each.', 2),
('txd-100-ultra-deep-sea-power-armor', 'Legs (2)', 160, 'Printed without an "each" where sibling lines carry one. Transcribed as printed.', 3),
('txd-100-ultra-deep-sea-power-armor', 'Arms (2)', 100, 'Each.', 4),
('txd-100-ultra-deep-sea-power-armor', 'Forearm Lasers (2)', 30, 'Printed without an "each".', 5),
('txd-100-ultra-deep-sea-power-armor', 'Sonic Rifle', 100, NULL, 6),
('txd-100-ultra-deep-sea-power-armor', 'Head Lasers (2, tiny)', 5, 'Each.', 7),
('txd-100-ultra-deep-sea-power-armor', 'Drum Ultra-Mini Torpedo Launcher (1, left shoulder)', 120, NULL, 8),
('txd-100-ultra-deep-sea-power-armor', 'Chest Lights (2)', 3, 'Each.', 9),
('txd-100-ultra-deep-sea-power-armor', 'Jet Thrusters (4, back)', 180, 'Each.', 10),
('txd-100-ultra-deep-sea-power-armor', 'Leg Thrusters (2)', 50, 'Each.', 11),
('txd-100-ultra-deep-sea-power-armor', 'Main Body', 400, NULL, 12),
('vx-20000-barracuda', 'Helmet & Sonar System', 110, NULL, 1),
('vx-20000-barracuda', 'Cyborg Head (inside the outer helmet)', 90, NULL, 2),
('vx-20000-barracuda', 'Shoulder Launchers (2)', 30, 'Each.', 3),
('vx-20000-barracuda', 'Legs (2)', 170, 'Each.', 4),
('vx-20000-barracuda', 'Arms (2)', 100, 'Each.', 5),
('vx-20000-barracuda', 'Forearm Launchers (4)', 30, 'Each.', 6),
('vx-20000-barracuda', 'TXD-02 Laser/Harpoon Rifle', 100, NULL, 7),
('vx-20000-barracuda', 'TXP Quad Rifle', 150, NULL, 8),
('vx-20000-barracuda', 'Jet Thrusters (4, back)', 180, 'Each.', 9),
('vx-20000-barracuda', 'Leg Thrusters (2)', 50, 'Each.', 10),
('vx-20000-barracuda', 'Main Body of the external Armor', 500, 'The stored main body figure.', 11),
('vx-20000-barracuda', 'Main Body of the cyborg inside', 210, 'The book notes the two together come to 710.', 12),
('x-6000-transformable-sub', 'Head/Sensor Cluster', 90, NULL, 1),
('x-6000-transformable-sub', 'Fins/Chest Plates (2)', 140, 'Each.', 2),
('x-6000-transformable-sub', 'Legs (2)', 180, 'Each.', 3),
('x-6000-transformable-sub', 'Arms (2)', 130, 'Each.', 4),
('x-6000-transformable-sub', 'Forearm Thrusters (2)', 50, 'Printed without an "each".', 5),
('x-6000-transformable-sub', 'Sub Nose Lasers (2, tiny)', 15, 'Each.', 6),
('x-6000-transformable-sub', 'Headlights (2)', 3, 'Each.', 7),
('x-6000-transformable-sub', 'Rail Guns (2)', 30, 'Each.', 8),
('x-6000-transformable-sub', 'Jet Thrusters (2, feet)', 180, 'Each.', 9),
('x-6000-transformable-sub', 'Lower Leg Thrusters (2)', 50, 'Each.', 10),
('x-6000-transformable-sub', 'Main Body', 420, NULL, 11),
('xs-20-sea-mite-mini-submarine', 'Heavy Torpedo Launch Tubes (2)', 30, 'Each.', 1),
('xs-20-sea-mite-mini-submarine', 'Light Torpedo Launch Tubes (2)', 20, 'Each.', 2),
('xs-20-sea-mite-mini-submarine', 'Rail Gun Openings (6)', 10, 'Each.', 3),
('xs-20-sea-mite-mini-submarine', 'Fins (2)', 120, 'Each.', 4),
('xs-20-sea-mite-mini-submarine', 'Tail Fins (2)', 45, 'Each.', 5),
('xs-20-sea-mite-mini-submarine', 'Main Rear Thruster', 160, NULL, 6),
('xs-20-sea-mite-mini-submarine', 'Hatches (2)', 50, 'Each.', 7),
('xs-20-sea-mite-mini-submarine', 'Infrared Spotlights (2, top)', 6, 'Each.', 8),
('xs-20-sea-mite-mini-submarine', 'Forward Lights (2, bottom)', 6, 'Each.', 9),
('xs-20-sea-mite-mini-submarine', 'Inner Pilot''s Compartment (front)', 50, NULL, 10),
('xs-20-sea-mite-mini-submarine', 'Main Body', 220, NULL, 11),
('xs-24-sea-bat-mini-submarine', 'Mini-Torpedoes (8)', 10, 'Each.', 1),
('xs-24-sea-bat-mini-submarine', 'Rail Gun Openings (8)', 10, 'Each.', 2),
('xs-24-sea-bat-mini-submarine', 'Tail Fins (2)', 50, 'Each.', 3),
('xs-24-sea-bat-mini-submarine', 'Side Fins/Wings (2)', 140, 'Each.', 4),
('xs-24-sea-bat-mini-submarine', 'Main Side Thrusters (2)', 100, 'Each.', 5),
('xs-24-sea-bat-mini-submarine', 'Robot Arms (2)', 90, 'Each.', 6),
('xs-24-sea-bat-mini-submarine', 'Hatch (1, top)', 50, NULL, 7),
('xs-24-sea-bat-mini-submarine', 'Sensor Cluster & Spotlight (2)', 45, 'Each.', 8),
('xs-24-sea-bat-mini-submarine', 'Forward Lights (2)', 6, 'Each.', 9),
('xs-24-sea-bat-mini-submarine', 'Inner Pilot''s Compartment (front, sliding plates)', 100, NULL, 10),
('xs-24-sea-bat-mini-submarine', 'Main Body', 260, NULL, 11),
('xs-30-torpedo-attack-sub', 'Torpedo Launch Tubes (6)', 50, 'Each.', 1),
('xs-30-torpedo-attack-sub', 'Top Laser Turret', 150, NULL, 2),
('xs-30-torpedo-attack-sub', 'Bottom Laser Turret', 130, NULL, 3),
('xs-30-torpedo-attack-sub', 'Rail Guns (2)', 25, 'Each.', 4),
('xs-30-torpedo-attack-sub', 'Tail Fins (2)', 90, 'Each.', 5),
('xs-30-torpedo-attack-sub', 'Main Rear Thrusters (2)', 220, 'Each.', 6),
('xs-30-torpedo-attack-sub', 'Airlock (1, front)', 120, NULL, 7),
('xs-30-torpedo-attack-sub', 'Emergency Hatch (1, rear)', 70, NULL, 8),
('xs-30-torpedo-attack-sub', 'Infrared Searchlights (4)', 6, 'Each.', 9),
('xs-30-torpedo-attack-sub', 'Forward Lights (2)', 6, 'Each.', 10),
('xs-30-torpedo-attack-sub', 'Inner Pilot''s Compartment (front)', 80, NULL, 11),
('xs-30-torpedo-attack-sub', 'Main Body', 1200, NULL, 12),
('xs-120-hydrofoil', 'Forward Lasers (2)', 120, 'Each.', 1),
('xs-120-hydrofoil', 'Rear Particle Beam Cannon', 150, NULL, 2),
('xs-120-hydrofoil', 'Mini-Missile Launcher (1)', 100, NULL, 3),
('xs-120-hydrofoil', 'Light Torpedo Tubes (2)', 35, 'Each.', 4),
('xs-120-hydrofoil', 'Searchlight (1, top)', 8, 'Printed with an "each" on a single item.', 5),
('xs-120-hydrofoil', 'Main Rear Thrusters (2)', 200, 'Each.', 6),
('xs-120-hydrofoil', 'Hydrofoil Supports (2)', 300, 'Each.', 7),
('xs-120-hydrofoil', 'Tail Fins', 50, 'Each.', 8),
('xs-120-hydrofoil', 'Pilot''s Cabin', 650, NULL, 9),
('xs-120-hydrofoil', 'Main Body', 1400, NULL, 10),
('xs-400-escort-battleship', 'Small Laser Turrets (6)', 300, 'Each.', 1),
('xs-400-escort-battleship', 'Ion Pulse Turrets (3)', 500, 'Each.', 2),
('xs-400-escort-battleship', 'Super Cannon & Turret (1)', 1200, NULL, 3),
('xs-400-escort-battleship', 'Missile Turret (1)', 950, NULL, 4),
('xs-400-escort-battleship', 'Torpedo Launch Tubes (4)', 400, 'Each.', 5),
('xs-400-escort-battleship', 'Landing Pad', 1400, NULL, 6),
('xs-400-escort-battleship', 'Anchor (2)', 700, 'Each.', 7),
('xs-400-escort-battleship', 'Sensor Clusters (4)', 250, 'Each.', 8),
('xs-400-escort-battleship', 'Rear Engines (4)', 1800, 'Each.', 9),
('xs-400-escort-battleship', 'Rudder (1)', 2200, NULL, 10),
('xs-400-escort-battleship', 'Ram Prow', 5000, NULL, 11),
('xs-400-escort-battleship', 'Bridge/Command Tower', 4500, NULL, 12),
('xs-400-escort-battleship', 'Forward Section', 9000, NULL, 13),
('xs-400-escort-battleship', 'Main Body', 14000, 'The rear two thirds of the ship, in the book''s own words.', 14),
('ngr-poseidon-submersible-carrier', 'Pop-Up Laser Turrets (8)', 300, 'Each.', 1),
('ngr-poseidon-submersible-carrier', 'Long-Range Missile Silo Hatches (8)', 350, 'Each.', 2),
('ngr-poseidon-submersible-carrier', 'Torpedo Tubes (8)', 300, 'Each.', 3),
('ngr-poseidon-submersible-carrier', 'Super Cannon & Turret (1)', 1200, NULL, 4),
('ngr-poseidon-submersible-carrier', 'Forward Hangar Doors (2)', 2500, 'Each.', 5),
('ngr-poseidon-submersible-carrier', 'Rear Hangar Doors (2)', 2500, 'Each.', 6),
('ngr-poseidon-submersible-carrier', 'Power Armor Release Hatches (8)', 450, 'Each.', 7),
('ngr-poseidon-submersible-carrier', 'Hull', 90, 'Per 40 foot (12 m) area.', 8),
('ngr-poseidon-submersible-carrier', 'Forward Fins (2)', 1500, 'Each.', 9),
('ngr-poseidon-submersible-carrier', 'Rudder (1, underwater)', 3800, NULL, 10),
('ngr-poseidon-submersible-carrier', 'Secondary Flight Deck (rear)', 5000, NULL, 11),
('ngr-poseidon-submersible-carrier', 'Bridge & Sensors', 2800, NULL, 12),
('ngr-poseidon-submersible-carrier', 'Main Body', 20000, NULL, 13);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('txd-100-ultra-deep-sea-power-armor', 1, 'Forearm Lasers', '3D6 M.D.', 1, '1200 feet (366 m)', NULL, NULL, NULL, NULL),
('txd-100-ultra-deep-sea-power-armor', 2, 'Head Lasers', '1D6 M.D. single, 2D6 M.D. double.', 1, '600 feet (183 m)', NULL, NULL, NULL, NULL),
('txd-100-ultra-deep-sea-power-armor', 3, 'Mini-Missiles/Torpedoes (10, wing-mounted)', 'Typically 1D4x10 or 1D6x10 M.D.', 1, 'About one mile (1.6 km)', NULL, '10', NULL, NULL),
('txd-100-ultra-deep-sea-power-armor', 4, 'TXT-10 Ultra-Mini Torpedo Drum Launcher', 'Concussion, 3D6 M.D. over a 30 foot (9 m) radius.', 1, 'About 1000 feet (305 m)', NULL, '56 torpedoes.', NULL, NULL),
('txd-100-ultra-deep-sea-power-armor', 5, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, 'The TXD-01 Sonic Beam Gun is standard issue; other marine weapons can be carried.'),
('txd-100-ultra-deep-sea-power-armor', 6, 'Hand to Hand Combat', 'Kick 1D6 M.D., power kick 2D6 M.D., body ram 3D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('vx-20000-barracuda', 1, 'TXP Quad Rifle', 'Tri-laser 2D6 M.D. single, 4D6 double, 6D6 triple. Rail gun 1D4 M.D. on a light burst, 3D6 M.D. depleted uranium, 6D6 M.D. heavy burst from the drum only.', 1, 'Lasers 3000 feet (914 m) underwater and 4000 feet (1220 m) in air. A SECOND pair of figures, 1400 and 6000 feet, also prints on the page; which is meant could not be settled, so both are recorded here.', NULL, '40 triple or 120 single laser blasts, recharging three every ten minutes; a 90-round rail gun clip giving 6 light bursts, or a 3,000-round drum giving 100 heavy or 200 light bursts.', NULL, 'Exclusive to the Barracuda.'),
('vx-20000-barracuda', 2, 'TXD-02 Deep-Sea Laser/Harpoon Rifle', 'Laser 3D6 M.D.; harpoon 1D6 M.D., or 5D6 M.D. explosive.', 1, 'Laser 1200 feet (366 m) underwater, 2000 feet (610 m) on land; harpoon 300 feet (91 m).', NULL, 'A 40-shot laser clip.', NULL, NULL),
('vx-20000-barracuda', 3, 'Mini-Missile/Torpedo Launchers', '1D4x10 or 1D6x10 M.D.', 1, 'About one mile (1.6 km)', NULL, '24 in total.', NULL, NULL),
('vx-20000-barracuda', 4, 'VX-270 Concealed Particle Beam Rod', '6D6+6 M.D.', 1, '300 feet (91 m) underwater, 1000 feet (305 m) on land.', NULL, '48 blasts, recharging eight an hour.', NULL, NULL),
('vx-20000-barracuda', 5, 'Concealed Vibro-Blade', '2D4 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('vx-20000-barracuda', 6, 'Wrist Weapon Systems', NULL, 0, NULL, NULL, NULL, NULL, 'One choice per arm: a chemical spray, an electrical discharge, a needle and drug dispenser, an LGL-31 grapnel, a climb cord, a garrote wire, or a laser finger.'),
('vx-20000-barracuda', 7, 'Concealed Storage Compartments (2)', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon.'),
('vx-20000-barracuda', 8, 'Hand to Hand Combat', 'Restrained punch 1D6+25 S.D.C., full punch 1D6 M.D., power punch 2D6 M.D., kick 1D6 M.D., jump kick 2D6 M.D., judo throw 1D4 M.D., body ram 2D4 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('x-6000-transformable-sub', 1, 'Nose Lasers (2)', '3D6 M.D. single, 6D6 M.D. double.', 1, '2000 feet (610 m)', NULL, NULL, NULL, NULL),
('x-6000-transformable-sub', 2, 'X-6000 Rail Guns (2)', '5D6 M.D. for a 30-round burst from one gun, 1D6x10 M.D. from both; a single round does 1D4 M.D.', 1, '1200 feet (366 m) underwater, 4000 feet (1220 m) on the surface.', NULL, '5,000 rounds, or 166 bursts.', NULL, NULL),
('x-6000-transformable-sub', 3, 'Mini-Torpedoes (6)', '1D6x10 M.D.', 1, 'About one mile (1.6 km)', NULL, '6', NULL, NULL),
('x-6000-transformable-sub', 4, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('x-6000-transformable-sub', 5, 'Hand to Hand Combat', 'Restrained punch 1D4 M.D., full punch or kick 2D4 M.D., power punch or kick 2D6+4 M.D., body ram 3D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('xs-20-sea-mite-mini-submarine', 1, 'Heavy Torpedo Launch Tubes (2)', '4D6x10 M.D., high explosive or plasma.', 1, 'Twenty miles (32 km)', NULL, '2 - it must dock to reload.', NULL, '20,000 credits a torpedo.'),
('xs-20-sea-mite-mini-submarine', 2, 'Light Torpedo Launch Tubes (2)', '2D4x10 M.D.', 1, 'Five miles (8 km)', NULL, '2 - it must dock to reload.', NULL, '8,000 credits a torpedo.'),
('xs-20-sea-mite-mini-submarine', 3, 'TXS-600 Rail Guns (6)', '5D6 M.D. from one fin, 1D6x10 M.D. from both; a single round does 1D4 M.D.', 1, '1200 feet (366 m) underwater, 4000 feet (1220 m) on the surface.', NULL, '6,000 rounds, or 200 bursts.', NULL, NULL),
('xs-20-sea-mite-mini-submarine', 4, 'Systems Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. Sonar, radar, a homing beacon and searchlights.'),
('xs-24-sea-bat-mini-submarine', 1, 'TXS-800 Rail Guns', '1D4x10 M.D. from one fin, 2D4x10 M.D. from both; a single round does 1D4 M.D.', 1, '1200 feet (366 m) underwater, 4000 feet (1220 m) on the surface.', NULL, '8,000 rounds, or 200 bursts.', NULL, 'The heading says five guns and the text says each side fin carries four. The book contradicts itself; both readings are recorded rather than one being picked.'),
('xs-24-sea-bat-mini-submarine', 2, 'Mini-Torpedoes (8)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '8', NULL, NULL),
('xs-24-sea-bat-mini-submarine', 3, 'Robot Arms (2)', 'A punch does 2D6 M.D., or damage by whatever the arm is holding.', 1, 'An eight foot (2.4 m) reach.', NULL, NULL, NULL, 'P.S. 38.'),
('xs-24-sea-bat-mini-submarine', 4, 'Systems Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The standard NGR sensor suite.'),
('xs-30-torpedo-attack-sub', 1, 'Heavy Torpedo Launch Tubes (6)', '4D6x10 M.D.', 1, 'Twenty miles (32 km)', NULL, '24 torpedoes.', NULL, '20,000 credits a torpedo.'),
('xs-30-torpedo-attack-sub', 2, 'Top Laser Turret', '1D4x10 M.D.', 1, '4000 feet (1220 m) underwater, 6000 feet (1830 m) on the surface.', NULL, NULL, NULL, NULL),
('xs-30-torpedo-attack-sub', 3, 'TXS-600 Rail Guns (2)', '5D6 M.D. from one, 1D6x10 M.D. from both; a single round does 1D4 M.D.', 1, '1200 feet (366 m) underwater, 4000 feet (1220 m) on the surface.', NULL, '15,000 rounds, or 500 bursts.', NULL, NULL),
('xs-30-torpedo-attack-sub', 4, 'Bottom Blue-Green Laser Turret', '4D6 M.D. single, 1D4x10+8 M.D. double.', 1, '4000 feet (1220 m) underwater.', NULL, NULL, NULL, NULL),
('xs-30-torpedo-attack-sub', 5, 'Systems Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The standard NGR sensor suite.'),
('xs-120-hydrofoil', 1, 'Light Torpedo Launch Tubes (2)', '2D4x10 M.D., high explosive.', 1, 'Five miles (8 km)', NULL, '12 torpedoes.', NULL, NULL),
('xs-120-hydrofoil', 2, 'Laser Turrets (2)', '1D4x10 M.D.', 1, '6000 feet (1830 m) on the surface, 4000 feet (1220 m) underwater.', NULL, NULL, NULL, NULL),
('xs-120-hydrofoil', 3, 'Rear Particle Beam Cannon', '1D6x10 M.D.', 1, '2,200 feet (670 m) on the surface, 800 feet (244 m) underwater.', NULL, NULL, NULL, NULL),
('xs-120-hydrofoil', 4, 'Mini-Missile Launcher', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '24 missiles.', NULL, NULL),
('xs-120-hydrofoil', 5, 'Systems Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The standard NGR sensor suite.'),
('xs-400-escort-battleship', 1, 'Double-Barrelled Super Laser Cannon', '2D6x10 M.D. single, 4D6x10 M.D. double.', 1, 'Three miles (4.8 km)', NULL, NULL, NULL, NULL),
('xs-400-escort-battleship', 2, 'Ion Pulse Cannons (3)', '1D4x10 M.D. single, 2D4x10 M.D. double.', 1, '6000 feet (1830 m)', NULL, NULL, NULL, NULL),
('xs-400-escort-battleship', 3, 'Double-Barrelled Laser Cannons (6)', '5D6 M.D. single, 1D6x10 M.D. double.', 1, '6000 feet (1830 m)', NULL, NULL, NULL, NULL),
('xs-400-escort-battleship', 4, 'Long-Range Missile Launcher', '4D6x10 M.D. tactical nuclear, or 1D6x100 M.D. super nuclear.', 1, 'Up to 1,800 miles (2,880 km)', NULL, NULL, NULL, NULL),
('xs-400-escort-battleship', 5, 'Torpedo Tubes (4)', 'Heavy plasma 4D6x10 M.D., or medium high explosive 3D4x10 M.D.', 1, 'Twenty miles (32 km) heavy, ten miles (16 km) medium.', NULL, '240 torpedoes.', NULL, NULL),
('xs-400-escort-battleship', 6, 'Depth Charge Launchers (2)', '2D4x10 M.D.', 1, 'Down to two miles (3.2 km).', NULL, '80 in total.', NULL, NULL),
('xs-400-escort-battleship', 7, 'Ram Prow', '2D6x10 M.D. for every 20 mph of speed.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('xs-400-escort-battleship', 8, 'Sensor Systems', NULL, 0, 'Radar and sonar both to 500 miles (800 km).', NULL, NULL, NULL, 'Not a weapon. Enhanced radar tracking 96 targets, sonar, echo-location, long-range communications, weapon targeting and life support monitoring.'),
('ngr-poseidon-submersible-carrier', 1, 'Double-Barrelled Super Laser Cannon', '2D6x10 M.D. single, 4D6x10 M.D. double.', 1, 'Three miles (4.8 km)', NULL, NULL, NULL, NULL),
('ngr-poseidon-submersible-carrier', 2, 'Pop-Up Double Barrel Laser Cannons (8)', '5D6 M.D. single, 1D6x10 M.D. double.', 1, '6000 feet (1830 m)', NULL, NULL, NULL, NULL),
('ngr-poseidon-submersible-carrier', 3, 'Long-Range Missile Launchers (8)', '4D6x10 M.D. tactical nuclear, or 1D6x100 M.D. super nuclear.', 1, '1,800 miles (2,880 km)', NULL, '216 of each.', NULL, NULL),
('ngr-poseidon-submersible-carrier', 4, 'Torpedo Tubes (8)', 'Heavy plasma 4D6x10 M.D., or medium high explosive 3D4x10 M.D.', 1, 'Twenty miles (32 km) heavy, ten miles (16 km) medium.', NULL, '480 in total.', NULL, NULL),
('ngr-poseidon-submersible-carrier', 5, 'Depth Charge Launchers (2)', '2D4x10 M.D.', 1, 'Down to two miles (3.2 km).', NULL, '160 in total.', NULL, NULL),
('ngr-poseidon-submersible-carrier', 6, 'Vehicles, Robots & Power Armor', NULL, 0, NULL, NULL, NULL, NULL, 'Numbered 7 by the book, which skips 6 entirely. Manta Ray attack ships, tanks, transports, jets, helicopters, power armour, 50 boats and 2 detachable submarines.'),
('ngr-poseidon-submersible-carrier', 7, 'Systems Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. A targeting network, a tactical combat network, long and short range sonar, a thermo-imager, telescopic optics, external audio, long and short range radar, and long and short range communications.');

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is SILENT on a collision, which is exactly how a row goes missing without
-- an error, so these COUNT.
SELECT 'these vessels' AS assertion,
       count(*) AS got, 9 AS want
  FROM vehicles WHERE slug IN ('txd-100-ultra-deep-sea-power-armor', 'vx-20000-barracuda', 'x-6000-transformable-sub', 'xs-20-sea-mite-mini-submarine', 'xs-24-sea-bat-mini-submarine', 'xs-30-torpedo-attack-sub', 'xs-120-hydrofoil', 'xs-400-escort-battleship', 'ngr-poseidon-submersible-carrier');

SELECT 'their M.D.C. locations' AS assertion,
       count(*) AS got, 106 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('txd-100-ultra-deep-sea-power-armor', 'vx-20000-barracuda', 'x-6000-transformable-sub', 'xs-20-sea-mite-mini-submarine', 'xs-24-sea-bat-mini-submarine', 'xs-30-torpedo-attack-sub', 'xs-120-hydrofoil', 'xs-400-escort-battleship', 'ngr-poseidon-submersible-carrier');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 52 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('txd-100-ultra-deep-sea-power-armor', 'vx-20000-barracuda', 'x-6000-transformable-sub', 'xs-20-sea-mite-mini-submarine', 'xs-24-sea-bat-mini-submarine', 'xs-30-torpedo-attack-sub', 'xs-120-hydrofoil', 'xs-400-escort-battleship', 'ngr-poseidon-submersible-carrier');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT count(*) AS underseas_vessels FROM vehicles WHERE source_book LIKE '%Underseas%';
SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-vessels-p195-210.sql');
