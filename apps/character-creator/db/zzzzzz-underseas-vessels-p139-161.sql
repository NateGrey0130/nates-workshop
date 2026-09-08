-- Underseas vessels from printed pages 139-161: the Aqua-Tech suits and
-- submersibles, and the Naut'Yll war machines.

--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-underseas-vessels-p139-161.sql
--
-- See zzzzzz-underseas-vessels-p081-105.sql for the standing notes. Every page
-- in this file is past printed 130, so cache page = printed folio MINUS ONE.
--
-- A PUZZLE ON PRINTED 144, SOLVED. An earlier gear pass found an unattributed
-- priced fragment there - a Cargo line, a Power System line, "Weapon Systems:
-- None", a second sensor paragraph, and "Market Cost: Liquid fuel sled: 38,000
-- credits, nuclear; One million credits" - sitting after the UB-300's own three
-- weapon systems, which it plainly could not belong to. IT IS THE TAIL OF THE
-- BASIC UNDERWATER SLED'S OWN STAT BLOCK, and four things say so: the Sled's
-- printed block stops dead at its Weight line with exactly those fields
-- missing; the fragment's liquid-fuel-or-nuclear power system matches the
-- Sled's own Range paragraph, where the UB-300 is nuclear-only with a ten year
-- life; "Weapon Systems: None" cannot describe a sub with three armed systems;
-- and the cost line says "sled" outright. The cause is the page's two-column
-- layout - OCR read the left column, which carries the bottom half of the
-- Sled's block, before jumping to the right column where its heading begins.
-- The PAGE is not corrupt; only the reading order was.
--
-- PRINTED 142 IS BLANK IN THE CACHE and nothing is lost with it. Printed 141
-- ends "Depicted on the following page", and the Orca-100's full weapon list is
-- on 141 itself. 142 is a full-page illustration.
--
-- THE APAL-10 HAS TWO M.D.C. FIGURES PER LOCATION, standard and Korallyte, and
-- both are printed. The standard figure is in mdc_main_body and both are in
-- each location's note - one column cannot hold a material branch. The SH-7 and
-- the Deathbringer take the same idea differently: the book adds 40% to every
-- location if the machine is Korallyte, so that is a note rather than a second
-- set of numbers.
--
-- THE APAL-10 HAS NO BUILT-IN WEAPONS AT ALL, which is not an omission: it is a
-- powered shell whose wearer carries naut'yll hand weapons. Its single
-- weapon_systems row holds the hand to hand damage and the bonuses, and says
-- so. The APTW-20 is the same shape with spells in place of guns.
--
-- THREE OCR MISREADS RESOLVED FROM CONTEXT rather than transcribed as garbage,
-- each recorded where it matters: "| D6" and "|D6x10" for 1D6 and 1D6x10, and
-- "1Dox10" on the Deathbringer's mini-torpedo launcher, which the Sea Hunter's
-- identical weapon prints as 1D6x10.
--
-- ONE DUPLICATION LEFT UNRESOLVED. The Deathbringer's medium torpedo launcher
-- prints its range and payload lines twice, verbatim. Whether that is two
-- sub-entries or a printing repeat could not be settled from the cache, so the
-- figures are stored ONCE and the duplication is recorded on the weapon.
--
-- SIX OF THESE ELEVEN HAVE NO PRICE - every naut'yll machine, which the book
-- says is never sold to outsiders before estimating a black-market figure. An
-- estimate is not a price and none is stored as one.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('aqua-tech-lea-50', 'Aqua-Tech LEA-50 Deep Sea Power Armor', 'rifts', 'Sea-Air-Land Tactical Assault Exoskeleton', 'One.', NULL, 'Running 40 mph (64 kmph) maximum; leaps up to 12 feet (3.65 m).', '100 mph (160 kmph) with the jet pack.', '5 mph (8 kmph; 4.3 knots) unaided, or 40 mph surfaced and 50 mph submerged with the jet pack.', 'Height 6 to 7 feet (1.8 to 2.1 m); width 3.4 feet (1.0 m) with an 8 foot wingspan; length 3 feet (0.9 m). Physical strength equal to a P.S. of 28.', '450 lbs (202.5 kg)', 200, 2500000, '2.5 million credits.', 'The light Aqua-Tech suit, nicknamed Mermaid armour, with a swappable jet pack for air or water. Its forearm quad-lasers double as tools, and the pack carries up to six mini-missiles.', 'Rifts World Book 7: Underseas p.139'),
('aqua-tech-orca-50', 'Aqua-Tech Orca-50 Deep Sea Power Armor', 'rifts', 'Deep Sea Tactical Assault Exoskeleton', 'One.', NULL, 'Running 40 mph (64 kmph) maximum; leaps up to 15 feet (4.6 m).', '80 mph (128.7 kmph) with the jet pack.', '8 mph (12.8 kmph; 6.8 knots) unaided, or 30 mph surfaced and 40 mph submerged with the jet pack.', 'Height 7 to 8 feet (2.1 to 2.4 m); width 4 feet (1.2 m), or 6 feet with the weapons out; length 4 feet (1.2 m) with the jet pack.', '800 lbs (360 kg)', 280, 4000000, '4 million credits.', 'The medium Aqua-Tech suit, black and silver, with a rotating twin-shoulder housing that pairs an ion blaster with detachable vibro-swords. The swords hit harder the faster the suit is moving.', 'Rifts World Book 7: Underseas p.140'),
('aqua-tech-orca-100', 'Aqua-Tech Orca-100 Deep Sea Power Armor', 'rifts', 'Deep Sea Tactical Assault Exoskeleton', 'One.', NULL, 'Running 40 mph (64 kmph) maximum; leaps up to 10 feet (3 m).', 'NOT POSSIBLE - the only Aqua-Tech suit that cannot fly at all.', '8 mph unaided, or 30 mph surfaced and 40 mph submerged with the jet pack.', 'Height 13 feet (3.9 m); width 6 feet (1.8 m), or 7 feet with the weapons out; length 7 feet (2.1 m) with the jet pack and decompression system.', '1.4 tons', 480, 12000000, '12 million credits.', 'The heavy Aqua-Tech suit, with echo location, thermo-imaging and two rotating shoulder weapon clusters - one built round particle beams, the other round mini-torpedoes, each with its own targeting lasers.', 'Rifts World Book 7: Underseas p.141'),
('ub-300-mini-sub', 'UB-300 Mini-Sub', 'rifts', 'Light All-Purpose Submersible', 'One pilot.', 'Three.', 'Not possible.', 'Not possible.', 'Surface 50 mph (80.5 kmph; 43 knots); submerged 25 mph (40 kmph; 21.5 knots).', 'Height 10 feet (3.0 m), width 25 feet (7.6 m), length 30 feet (9.1 m).', '20 tons', 525, 6000000, '6 million credits.', 'A four-person submersible for exploration, rescue, salvage and light combat, popular with coastal kingdoms on patrol duty. It stays down for weeks carrying a month of supplies for four.', 'Rifts World Book 7: Underseas p.143-144'),
('basic-underwater-sled', 'Basic Underwater Sled', 'rifts', 'All-Purpose Underwater Sled', 'One.', 'No formal figure. Two or three other divers can hold on below 20 mph.', 'Not possible.', 'Not possible.', 'Surface 20 mph (54 kmph; 17.2 knots); submerged 15 mph (24 kmph; 13 knots).', 'Height 3 feet (0.9 m), width 3 feet (0.9 m), length 7 feet (2.1 m).', '250 lbs (112.5 kg), carrying or pulling another 500 lbs (225 kg).', 145, 38000, '38,000 credits for the liquid-fuel sled, or one million for the nuclear one. THE STORED FIGURE IS THE LIQUID-FUEL PRICE, the low end.', 'A one-man jet sled, prized for being quiet and manoeuvrable enough not to disturb wildlife, so it is used for exploration and marine biology as much as anything. The rider lies prone on top on handlebar controls. It has no weapons at all.', 'Rifts World Book 7: Underseas p.144'),
('apal-10-nautyll-torpedo-power-armor', 'APAL-10 Naut''Yll Torpedo Power Armor', 'rifts', 'Light combat exoskeleton', 'One.', NULL, 'Running 44 mph (70 km) maximum.', 'Not possible, though thruster-assisted leaps reach 100 feet high and 120 feet long.', 'Up to 60 knots (69 mph/111 kmph) on the thruster.', 'Height 7 to 8 feet (2.1 to 2.4 m), width 3 feet (0.9 m), length 3 feet (0.9 m).', '300 lbs (136 kg)', 180, NULL, 'NO PRICE. Never sold to outsiders; the book estimates 1 to 3 million credits on the black market or in Atlantis. An estimate, not a price.', 'A powered shell rather than a full suit - it gives a naut''yll robotic strength and half a mile more depth, and carries NO built-in weapons at all. Raiders, explorers and commandos wear it and bring their own guns.', 'Rifts World Book 7: Underseas p.156-157'),
('aptw-20-nautyll-tw-power-armor', 'APTW-20 Naut''Yll Techno-Wizard Power Armor', 'rifts', 'Medium techno-wizard combat exoskeleton', 'One.', NULL, 'Running 44 mph (70 km) maximum, without fatigue.', 'By magic only, through Fly as the Eagle. Thruster leaps reach 100 feet high and 120 feet long.', 'Up to 60 knots (69 mph/111 kmph) on the thruster, doubled under a Speed Doubler spell.', 'Height 5 to 10 feet (1.8 to 3 m) - it conforms magically to its wearer, as do its width and length.', '300 lbs (136 kg) whatever its size.', 300, NULL, 'NO PRICE. Never sold to outsiders; the book estimates 20 to 40 million credits on the black market or in Atlantis.', 'The techno-wizard APAL-10 - identical to look at, and useless unless its pilot is a practitioner of magic or a major or master psionic. It burns P.P.E. or I.S.P. for a suite of spells instead of carrying guns, and its living Korallyte shell regenerates.', 'Rifts World Book 7: Underseas p.157'),
('sea-hunter-sh-7', 'Sea Hunter Robot Vehicle SH-7', 'rifts', 'Heavy combat exoskeleton', 'One, with a cramped space for one more human or naut''yll sized occupant.', NULL, 'Running 50 mph (80 km) maximum on dry land.', 'Not possible.', 'Running 30 mph (48 km) on the bottom, or 39 knots (45 mph/72 kmph) on its thrusters.', 'Height 10 feet (3.0 m), width 10 feet (3.0 m), length 12 feet (3.65 m).', '2 tons', 300, NULL, 'NO PRICE. Not sold to outsiders; the book estimates 8 to 10 million credits from the black market, Atlantis or pirates.', 'A crab-shaped four-legged robot for sea-floor and dry-land fighting, with heavy pincer arms. It can bury itself in sand to hide from sight, sonar and sonic detection, and works in warbands of four to eight.', 'Rifts World Book 7: Underseas p.157-158'),
('deathbringer-dd-2', 'Deathbringer Combat Robot DD-2', 'rifts', 'Assault Robot', 'Two - a pilot and a gunner.', 'Two.', 'Running 50 mph (80 km) maximum on dry land.', 'Not possible.', 'Running 25 mph (40 km) on the bottom, or 30 knots (35 mph/56 kmph) on its thrusters.', 'Height 20 feet (6.1 m), width 25 feet (7.6 m), length 30 feet (9.1 m).', '20 tons fully loaded.', 500, NULL, 'NO PRICE. Not sold to outsiders; the book estimates 25 to 40 million credits from the black market, Atlantis or pirates.', 'The Sea Hunter scaled up and given a dedicated gunner - heavier armour, a triple particle wave cannon and four torpedo launchers. It anchors naut''yll defence and slave-guarding, fielded alongside Sea Hunters and infantry.', 'Rifts World Book 7: Underseas p.158-160'),
('leaper-submersible-fighter-l-52', 'Leaper Submersible Fighter L-52', 'rifts', 'Sea-Air Attack Vehicle', 'One.', NULL, 'Not possible.', 'Up to 400 mph (640 kmph).', '51 knots (60 mph/96 kmph).', 'Height 7 feet (2.1 m), width 15 feet (4.6 m) wingtip to wingtip, length 21 feet (6.3 m).', '1 ton', 150, NULL, 'NO PRICE. Not for sale; the book estimates one or two million credits on the black market.', 'A submarine that flies, named after a flying fish of the naut''yll homeworld. Slower and less agile than an Earth fighter jet but well armed, and able to strike from underwater. It does well against merchant traffic and badly against real warships.', 'Rifts World Book 7: Underseas p.160'),
('red-trident-attack-submarine', 'Red Trident Attack Submarine RT-II', 'rifts', 'Attack Submarine', '30, of whom 12 can run her at maximum efficiency.', 'A wartribe - either 160 infantry in shell body armour, or an armoured wartribe of 24 Deathbringers, 32 Sea Hunters and 24 power-armoured troops, or a power-armour wartribe of 40 standard APAL-10, 20 Korallyte APAL-10 and 20 APTW-20. Plus up to 200 slaves.', 'Not possible.', 'Not possible.', 'Surface 25 knots (29 mph/47 kmph); underwater 45 knots (52 mph/84 kmph).', 'Height 30 feet (9.1 m), width 60 feet (18.3 m), length 300 feet.', '2,000 tons', 1200, NULL, 'NO PRICE, and none is printed: the block runs from the power system straight into the weapon systems with no Market Cost or Manufacturers line anywhere.', 'The mainstay of the naut''yll navy, shaped like a giant trident with its main particle wave cannons in the two side spikes. It is built for amphibious assault - landing a wartribe on a coastline, supporting it, and carrying slaves and loot home. The Ticonderoga alone has sunk at least fifteen.', 'Rifts World Book 7: Underseas p.160-161');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('aqua-tech-lea-50', 'Head', 60, NULL, 1),
('aqua-tech-lea-50', 'Arms (2)', 70, 'Each.', 2),
('aqua-tech-lea-50', 'Legs (2)', 100, 'Each.', 3),
('aqua-tech-lea-50', 'Thruster System (back)', 140, NULL, 4),
('aqua-tech-lea-50', 'Main Body', 200, NULL, 5),
('aqua-tech-orca-50', 'Head', 75, NULL, 1),
('aqua-tech-orca-50', 'Twin Weapon Systems (2)', 35, 'Each.', 2),
('aqua-tech-orca-50', 'Arms (2)', 80, 'Each.', 3),
('aqua-tech-orca-50', 'Legs (2)', 120, 'Each.', 4),
('aqua-tech-orca-50', 'Thruster System (back)', 140, NULL, 5),
('aqua-tech-orca-50', 'Main Body', 280, NULL, 6),
('aqua-tech-orca-100', 'Head', 90, NULL, 1),
('aqua-tech-orca-100', 'Right Weapon Cluster (1)', 100, NULL, 2),
('aqua-tech-orca-100', 'Left Weapon Cluster (1)', 120, NULL, 3),
('aqua-tech-orca-100', 'Arms (2)', 170, 'Each.', 4),
('aqua-tech-orca-100', 'Legs (2)', 260, 'Each.', 5),
('aqua-tech-orca-100', 'Thruster & Air System (back)', 300, NULL, 6),
('aqua-tech-orca-100', 'Main Body', 480, NULL, 7),
('ub-300-mini-sub', 'Underbelly Laser Turret (1)', 80, NULL, 1),
('ub-300-mini-sub', 'Mini-Torpedoes (6, three per fin)', 10, 'Each.', 2),
('ub-300-mini-sub', 'Medium-Range Torpedoes (2, one per fin)', 30, 'Each.', 3),
('ub-300-mini-sub', 'Fins (2)', 150, 'Each.', 4),
('ub-300-mini-sub', 'Main Rear Thrusters (2)', 160, 'Each.', 5),
('ub-300-mini-sub', 'Sensor Cluster (1, top)', 80, NULL, 6),
('ub-300-mini-sub', 'Hatches (2)', 50, 'Each.', 7),
('ub-300-mini-sub', 'Infrared Spotlights (2, top)', 10, 'Each.', 8),
('ub-300-mini-sub', 'Forward Lights (2, bottom)', 5, 'Each.', 9),
('ub-300-mini-sub', 'Pilot''s Compartment (front)', 60, NULL, 10),
('ub-300-mini-sub', 'Inner Crew Compartment', 100, NULL, 11),
('ub-300-mini-sub', 'Main Body', 525, NULL, 12),
('basic-underwater-sled', 'Propeller Jet (1, rear)', 70, NULL, 1),
('basic-underwater-sled', 'Side Fins (2)', 60, 'Each.', 2),
('basic-underwater-sled', 'Main Body/Pilot Area', 145, NULL, 3),
('apal-10-nautyll-torpedo-power-armor', 'Jet Thruster (1, back)', 35, 'The Korallyte version has 50.', 1),
('apal-10-nautyll-torpedo-power-armor', 'Helmet', 70, 'The Korallyte version has 110.', 2),
('apal-10-nautyll-torpedo-power-armor', 'Main Body', 180, 'The Korallyte version has 300. Both figures are printed; the stored main body is the standard one.', 3),
('aptw-20-nautyll-tw-power-armor', 'Thruster (1, back)', 50, NULL, 1),
('aptw-20-nautyll-tw-power-armor', 'Helmet', 110, NULL, 2),
('aptw-20-nautyll-tw-power-armor', 'Main Body', 300, 'Always Korallyte, so there is no second figure as on the APAL-10.', 3),
('sea-hunter-sh-7', 'Arms (2)', 90, 'Each.', 1),
('sea-hunter-sh-7', 'Pincers (2)', 70, 'Each.', 2),
('sea-hunter-sh-7', 'Legs (4)', 100, 'Each.', 3),
('sea-hunter-sh-7', 'Rear Jet Thrusters (2)', 60, 'Each.', 4),
('sea-hunter-sh-7', 'Tiny Directional Jets (20)', 5, 'Each.', 5),
('sea-hunter-sh-7', 'Mini-Torpedo/Missile Launcher (1, left forearm)', 30, NULL, 6),
('sea-hunter-sh-7', 'Medium Torpedo/Missile Launchers (2, top)', 50, 'Each.', 7),
('sea-hunter-sh-7', 'Particle Wave Gun (1, top)', 100, NULL, 8),
('sea-hunter-sh-7', 'Laser (1, right forearm)', 25, NULL, 9),
('sea-hunter-sh-7', 'Main Body', 300, 'The book adds 40% to EVERY location if the machine is built of Korallyte.', 10),
('deathbringer-dd-2', 'Arms (2)', 150, 'Each.', 1),
('deathbringer-dd-2', 'Pincers (2)', 100, 'Each.', 2),
('deathbringer-dd-2', 'Legs (4)', 140, 'Each.', 3),
('deathbringer-dd-2', 'Rear Jet Thrusters (2)', 140, 'Each.', 4),
('deathbringer-dd-2', 'Tiny Directional Jets (30)', 7, 'Each.', 5),
('deathbringer-dd-2', 'Mini-Torpedo/Missile Launcher (1, left forearm)', 50, NULL, 6),
('deathbringer-dd-2', 'Medium Torpedo/Missile Launchers (2, top)', 100, 'Each.', 7),
('deathbringer-dd-2', 'Heavy Torpedo/Missile Launchers (2)', 70, 'Each.', 8),
('deathbringer-dd-2', 'Particle Wave Gun (1, top)', 200, NULL, 9),
('deathbringer-dd-2', 'Laser (1, right forearm)', 35, NULL, 10),
('deathbringer-dd-2', 'Main Body', 500, 'The book adds 40% to every location if built of Korallyte, which only 25% of them are.', 11),
('deathbringer-dd-2', 'Reinforced Pilot''s Compartment', 100, NULL, 12),
('leaper-submersible-fighter-l-52', 'Missile/Torpedo Launchers (2, nose)', 30, 'Each.', 1),
('leaper-submersible-fighter-l-52', 'Particle Wave Guns (2, top and bottom)', 50, 'Each.', 2),
('leaper-submersible-fighter-l-52', 'Wings (2)', 75, NULL, 3),
('leaper-submersible-fighter-l-52', 'Main Body', 150, NULL, 4),
('leaper-submersible-fighter-l-52', 'Reinforced Pilot''s Compartment', 50, NULL, 5),
('red-trident-attack-submarine', 'Particle Wave Cannons (2)', 300, 'Each.', 1),
('red-trident-attack-submarine', 'Heavy Torpedo/Missile Launchers (4)', 100, 'Each.', 2),
('red-trident-attack-submarine', 'Blue-Green Lasers (4)', 80, 'Each.', 3),
('red-trident-attack-submarine', 'Medium Torpedo/Missile Launchers (4)', 60, 'Each.', 4),
('red-trident-attack-submarine', 'Main Body', 1200, NULL, 5);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('aqua-tech-lea-50', 1, 'Quad-Wrist Laser', '1D6 M.D. single or 4D6 M.D. on a quad blast; the vibro-blade does 2D6 M.D.', 1, '1200 feet (366 m)', 'The pilot''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('aqua-tech-lea-50', 2, 'Mini-Missiles (6)', 'Plasma or heat, 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One, or volleys of two, four or six.', '6', NULL, NULL),
('aqua-tech-lea-50', 3, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Any underwater sidearm.'),
('aqua-tech-lea-50', 4, 'Hand to Hand Combat', 'Punch or kick 1D6 M.D.; power punch 2D6 M.D. counting as two attacks.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('aqua-tech-orca-50', 1, 'Laser Finger', '1D6 M.D. per blast.', 1, '300 feet (91 m)', 'The pilot''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('aqua-tech-orca-50', 2, 'Shoulder Weapon System', 'Ion blaster 3D6 M.D. single or 6D6 M.D. double. The twin detachable vibro-swords do 2D6 M.D. each, plus 1D6 M.D. for every 20 mph of speed when used with the suit moving.', 1, '1200 feet (366 m)', NULL, NULL, NULL, NULL),
('aqua-tech-orca-50', 3, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('aqua-tech-orca-50', 4, 'Hand to Hand Combat', 'Punch or kick 2D4 M.D.; power punch 3D6 M.D. counting as two attacks.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('aqua-tech-orca-100', 1, 'Head Laser (Blue-Green)', '2D6 M.D. per blast.', 1, '1200 feet (366 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('aqua-tech-orca-100', 2, 'Right Shoulder Weapon Cluster', 'Triple particle beam blaster 1D6x10, 2D6x10 or 3D6x10 M.D. on a single, double or triple blast, plus a top laser at 3D6 M.D.', 1, 'Particle beams 600 feet (183 m) underwater or 1200 feet (366 m) on land; the laser 3000 feet (914 m).', NULL, 'Effectively unlimited.', NULL, NULL),
('aqua-tech-orca-100', 3, 'Left Shoulder Weapon Cluster', 'Mini-torpedoes 1D6x10 M.D., plus twin lasers at 3D6 M.D. single or 6D6 M.D. simultaneous.', 1, 'Torpedoes one mile (1.6 km); lasers 3000 feet (914 m).', NULL, '6 torpedoes; the lasers are unlimited.', NULL, NULL),
('aqua-tech-orca-100', 4, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Cyborg or small-robot scale.'),
('aqua-tech-orca-100', 5, 'Hand to Hand Combat', 'Punch or kick 3D6 M.D.; power punch 6D6 M.D. counting as two attacks.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('ub-300-mini-sub', 1, 'Laser Turret (1)', '4D6 M.D. per blast.', 1, '4000 feet (1220 m)', 'The gunner''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('ub-300-mini-sub', 2, 'Medium-Range Torpedoes (2)', '3D4x10 M.D. high explosive, or 2D6x10 M.D. plasma.', 1, 'Ten miles (16 km)', 'One, or a volley of two.', '2, reloading in five minutes when docked.', NULL, NULL),
('ub-300-mini-sub', 3, 'Mini-Torpedoes (6)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', 'One, or volleys of two.', '6, reloading in five minutes when docked.', NULL, NULL),
('ub-300-mini-sub', 4, 'Systems Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. Short-range sonar, a radiation detector, a mini-computer, laser distancing, a distress beacon, medium-range radio and infrared searchlights.'),
('apal-10-nautyll-torpedo-power-armor', 1, 'None integral', 'Punch or kick 1D6 M.D.; power punch 2D6 M.D. counting as two attacks; a thruster-assisted body block or ram does 4D6 M.D. with a 1-50% chance of stunning, counting as two attacks.', 1, 'Melee.', NULL, NULL, '+1 to strike with ranged weapons; +1 to parry and dodge underwater; +1 attack per melee underwater.', 'THE SUIT HAS NO BUILT-IN WEAPONS. Its wearer is usually armed with a pulse wave rifle, harpoon rifle, energy trident and a knife, energy net or sidearm.'),
('aptw-20-nautyll-tw-power-armor', 1, 'Magic Offense', 'Fire Ball 4D6 M.D. for 10 P.P.E. or 20 I.S.P.; Sonic Blast 6D6 M.D. for 15 P.P.E. or 30 I.S.P.; Sonic Stun for 20 P.P.E. or 40 I.S.P., with no damage figure printed; Water Pulse, S.D.C. only, for 1 P.P.E. or 2 I.S.P.', 1, NULL, NULL, 'Limited by the pilot P.P.E. or I.S.P.', NULL, 'The suit has no conventional weapons - magic or hand-held only.'),
('aptw-20-nautyll-tw-power-armor', 2, 'Magic Defense and Utility', NULL, 0, NULL, NULL, NULL, NULL, 'Armor of Ithan at 60 M.D.C. or Superhuman Strength, one or the other, for 10 P.P.E. or 20 I.S.P., plus Chameleon, Fly as the Eagle, Sense Evil, Sense Magic, Speed Doubler and Tongues, each at its own cost.'),
('sea-hunter-sh-7', 1, 'Particle Wave Gun', '1D6x10+10 M.D. per blast.', 1, '4000 feet (1220 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('sea-hunter-sh-7', 2, 'Medium Torpedo/Missile Launchers (2)', '2D6x10 M.D.', 1, 'Ten miles (16 km)', 'One, or a volley of two.', '4, two per launcher.', NULL, NULL),
('sea-hunter-sh-7', 3, 'Mini-Torpedo/Missile Launcher (1)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', 'One, or volleys of two or four.', '8', NULL, NULL),
('sea-hunter-sh-7', 4, 'Concealed Laser Gun', '6D6 M.D.', 1, '4000 feet (1220 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('sea-hunter-sh-7', 5, 'Hand to Hand Combat', 'Restrained punch 1D6 M.D., full strength 3D6 M.D., full strength pincer 4D6 M.D., power punch 1D6x10 M.D. counting as two attacks, kick or stomp 1D6 M.D., body block or ram 2D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('deathbringer-dd-2', 1, 'Triple Barrelled Particle Wave Cannon Turret', '1D6x10+6 M.D. single, 2D6x10+12 M.D. double, 3D6x10+20 M.D. triple.', 1, '5000 feet (1325 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('deathbringer-dd-2', 2, 'Heavy Torpedo/Missile Launchers (2)', '4D6x10 M.D.', 1, 'Twenty miles (32 km) underwater, 500 miles (800 km) on the surface.', 'One, or a volley of two.', '16, eight per launcher.', NULL, NULL),
('deathbringer-dd-2', 3, 'Medium Torpedo/Missile Launchers (2)', '2D6x10 M.D.', 1, 'Ten miles (16 km)', 'One, or volleys of two or four.', '16, eight per launcher.', NULL, 'The page prints this system range and payload lines TWICE, verbatim. Whether that is two sub-entries or a printing repeat could not be settled from the cache, so the figures are stored once and the duplication is recorded here.'),
('deathbringer-dd-2', 4, 'Mini-Torpedo/Missile Launcher (1)', '1D6x10 M.D. The page prints it as "1Dox10", which is not a die; the Sea Hunter identical weapon reads 1D6x10.', 1, 'One mile (1.6 km)', 'One, or volleys of two or four.', '8', NULL, NULL),
('deathbringer-dd-2', 5, 'Concealed Laser Gun', '6D6 M.D.', 1, '6000 feet (1830 m)', NULL, 'Effectively unlimited.', NULL, NULL),
('deathbringer-dd-2', 6, 'Hand to Hand Combat', 'Restrained punch 2D6 M.D., full strength 6D6 M.D., pincer strike 7D6 M.D., power punch 2D6x10 M.D. counting as two attacks, kick or stomp 2D6 M.D., body block or ram 4D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('leaper-submersible-fighter-l-52', 1, 'Particle Wave Guns (2)', '1D6x10 M.D. each, or 2D6x10 M.D. on a simultaneous double blast.', 1, '4000 feet (1220 m), the same underwater or in air.', 'The pilot''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('leaper-submersible-fighter-l-52', 2, 'Torpedo/Missile Launchers (2)', '2D6x10 M.D.', 1, 'Ten miles (16 km) underwater, 40 miles (64 km) on the surface.', 'One, or a volley of two.', '8, four per launcher.', NULL, NULL),
('red-trident-attack-submarine', 1, 'Particle Wave Cannons (2)', '4D6x10 M.D. single, or 4D6x20 M.D. on a double blast.', 1, 'Two miles (3.2 km)', 'Each gun twice per melee, or two double blasts.', 'Effectively unlimited.', NULL, NULL),
('red-trident-attack-submarine', 2, 'Heavy Torpedo/Missile Launchers (4)', '4D6x10 M.D.', 1, 'Twenty miles (32 km) underwater, 500 miles (800 km) on the surface.', 'One, or volleys of two or four.', '40 in an internal magazine.', NULL, NULL),
('red-trident-attack-submarine', 3, 'Blue-Green Lasers (4)', '1D6x10 M.D. per blast.', 1, '4000 feet (1220 m)', 'The gunner''s hand to hand attacks.', 'Effectively unlimited.', NULL, NULL),
('red-trident-attack-submarine', 4, 'Medium Torpedo/Missile Launchers (4)', '2D6x10 M.D.', 1, 'Ten miles (16 km) underwater, 40 miles (64 km) on the surface.', 'One, or volleys of two or four.', '120, thirty per launcher.', NULL, NULL);

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is SILENT on a collision, which is exactly how a row goes missing without
-- an error, so these COUNT.
SELECT 'these vessels' AS assertion,
       count(*) AS got, 11 AS want
  FROM vehicles WHERE slug IN ('aqua-tech-lea-50', 'aqua-tech-orca-50', 'aqua-tech-orca-100', 'ub-300-mini-sub', 'basic-underwater-sled', 'apal-10-nautyll-torpedo-power-armor', 'aptw-20-nautyll-tw-power-armor', 'sea-hunter-sh-7', 'deathbringer-dd-2', 'leaper-submersible-fighter-l-52', 'red-trident-attack-submarine');

SELECT 'their M.D.C. locations' AS assertion,
       count(*) AS got, 71 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('aqua-tech-lea-50', 'aqua-tech-orca-50', 'aqua-tech-orca-100', 'ub-300-mini-sub', 'basic-underwater-sled', 'apal-10-nautyll-torpedo-power-armor', 'aptw-20-nautyll-tw-power-armor', 'sea-hunter-sh-7', 'deathbringer-dd-2', 'leaper-submersible-fighter-l-52', 'red-trident-attack-submarine');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 37 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('aqua-tech-lea-50', 'aqua-tech-orca-50', 'aqua-tech-orca-100', 'ub-300-mini-sub', 'basic-underwater-sled', 'apal-10-nautyll-torpedo-power-armor', 'aptw-20-nautyll-tw-power-armor', 'sea-hunter-sh-7', 'deathbringer-dd-2', 'leaper-submersible-fighter-l-52', 'red-trident-attack-submarine');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT count(*) AS underseas_vessels FROM vehicles WHERE source_book LIKE '%Underseas%';
SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-vessels-p139-161.sql');
