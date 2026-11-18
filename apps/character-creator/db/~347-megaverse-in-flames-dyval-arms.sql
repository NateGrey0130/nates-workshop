-- Rifts World Book 35: Megaverse in Flames, the Deevils' Hell Galleon, Hell Schooner and Hell Battle Barge (printed 131-136)
-- 3 vehicle rows, with 43 locations and 14 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~347-megaverse-in-flames-dyval-arms.sql
--
-- Written by scripts/vessel-sql.mjs from 1 worker file(s). Every value
-- is printable ASCII, every row cites its book, and a Main Body location
-- agrees with its vehicle's mdc_main_body.
-- The three Deevil warships of Dyval Weapons and Vehicles. Every M.D.C. by
-- Location block, damage, speed and P.P.E. figure was read off a render of its
-- page. Every numbered weapon system is stored, the non-weapon ones (magic,
-- troops) with no damage. The Galleon's weapon 1 is any gun the owner mounts; the
-- book's own figures for it are stored.
-- NO SINGLE MAIN BODY: each ship prints three main-body sections (front,
-- mid-ship, rear) and no Main Body figure, so mdc_main_body is NULL and the
-- sections are locations.
-- FIGURES STORED AS PRINTED, with a note in the row: the Battle Barge's Rear
-- Section is 8600 (the other two are 760 and 650, so likely 860); the Schooner
-- weighs "150-20" tons; the Galleon's 200 ft length is printed as 55 m; the
-- Barge's Soul Cannon Gunner Compartments print 200 without "each".
-- Not the same vessel, left alone: demon-black-ship (South America), which the
-- Galleon is said to match, and black-galleon-gunboat.

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
  ('hell-galleon', 'Hell Galleon', 'rifts', 'ship', 'Greater Deevils: 2 Arch Fiends, 2 Deevil Dragons, 2 Deevil Beasts, 2 Horrors, and a Serpent (or another Beast) as captain. Lesser Deevils: 2D6+12 Bonelings, 1D6+6 Deevils, 1D4+4 Naga Deevils, 1D4 Nexus Deevils, 1D4 Gorgons, 2 Fiends, plus 2D6 more Lesser Deevils or Host of any kind. Air wing: 2D6+8 Harpies and 2 Dire Harpies. Others: 1D6 Blood Warriors, 1-2 Soulmancers, 1D4+1 Necromancers, 2D6+6 Shock Dragons (Host), 1D4x10 mortal slaves or followers (usually level 1D6), and 4D6x16 skeletons, zombies or other animated dead', NULL, NULL, NULL, 'Sailing 16 mph (26 km). Mystic propulsion 32 mph (51 km), +10 mph (16 km) for 1D4 hours when a living mortal is sacrificed on its altar (one soul at a time); 70 mph (112 km) on a ley line or anywhere in the Devil''s (Bermuda) Triangle', 'Width 30 ft (9.14 m); length 200 to 300 ft (printed 55 to 91.4 m)', '300-500', NULL, 1, NULL, NULL, 'Never sold openly; the book values one at hundreds of millions of credits, perhaps billions.', 'Dyval Hell Galleon, a Magic Warship: the Deevils'' own build of the Demon Black Ship, made by the same Soulmancy rite in a different style. Only the mightiest evil Soulmancers, Shifters and Necromancers know how to raise one, and even the Splugorth neither have nor want the secret; on ley-line-rich Rifts Earth the ship becomes a Mega-Damage structure that can trade fire with modern warships. Eight sail from Ciudad de Diablo, four always roaming the world''s seas and four patrolling the Caribbean and the Atlantic, with rumours of 2-4 more on the Gulf Coast and 2-4 off Africa. They hunt mortal and Splugorth shipping and any Demon Black Ship they meet, including Kharkon the Undaunted''s independent fleet out of Nightmare Island, which both sides of the Minion War would like to capture or recruit. Main body: three sections (front 1,200, mid-ship 800, rear 900 M.D.C.) rather than one figure, so mdc_main_body is empty; losing any section sinks her in 4D6 minutes. Cargo: 120 tons besides the crew. Range: unlimited. Power: sail, or mystic propulsion at 100 P.P.E. an hour (only 20 an hour on a ley line, where she makes 70 mph even into wind or current); captives are often sacrificed to keep her moving. Self-repair: 100 M.D.C. a day, 200 when anchored on a ley line or in the Bermuda Triangle.', 'Rifts World Book 35: Megaverse in Flames p.131-133'),
  ('hell-schooner', 'Hell Schooner', 'rifts', 'ship', 'Greater Deevils: usually 2 Beasts or Horrors and one Arch Fiend, sometimes twice that. Lesser Deevils: 8 Deevils, 4 Devilkins, 4 Naga Deevils, 1 Imp, and a Fiend or Ice Wraith. Host and others: 1D6+4 Harpies, 1D4+4 Tiger Beasts, 1D4+2 Shock Troopers, 1-2 Soulmancers, 1D4+2 Blood Warriors and 2D6+12 mortal henchmen or slaves', 'Carries troops; in a pinch cargo and small, light vehicles instead', 'None; a hover craft for water and air only', '70 mph (112 km) maximum, cruising 40 mph (64 km), hovering up to 5,000 ft (1524 m); +30% along a ley line', 'Sailing 20 mph (32 km). Mystic propulsion 42 mph (67 km), +15 mph (24 km) for 1D4+2 hours when a living mortal is sacrificed on its altar (one soul at a time); 90 mph (145 km) on a ley line or in the Devil''s (Bermuda) Triangle. Cannot submerge', 'Height 18 ft (5.5 m); width 15-20 ft (4.6-6.1 m); length 120-200 ft (36.6-61 m)', '150-20 (as printed; the upper figure is likely 200)', NULL, 1, NULL, NULL, 'Never sold openly; the book values one at tens of millions of credits.', 'Dyval Hell Schooner, a Deevil hovering assault ship and troop carrier for both sea and sky: a sailing ship that lifts off the waves to fly over clouds, trees and land. Built the same way as the Hell Galleon, it looks demonic, its hull of red and black flesh on a frame of bone, with spikes and two snapping maws on the bow; the front rams and the rest carries gun platforms for strikes on water, from air to sea and from air to land. Behind the pilot stands a sacrificial altar, and channels cut in the deck run spilled blood to a Blood Pool below his dais. Deevils use it as a fairly quick, nimble raider and troop carrier at sea and over land. Main body: front 440, mid-ship 330 and rear 400 M.D.C. sections rather than one figure, so mdc_main_body is empty; losing a section sinks her in 4D6 minutes. Destroying the Blood Pool (150 M.D.C., below deck) disables her: aloft she sinks to the ground or water within 1D4+2 melee rounds, aground she cannot move, afloat she can still sail, and only 1D4 gallons of blood are left. Cargo: 80 tons besides the crew. Power: sail or magic flight; the mystic drive costs 100 P.P.E. an hour plus blood, 5 gallons (19 liters) an hour, 10 gallons (37.8 liters) at top speed, so captives are often sacrificed. Self-repair: 30 M.D.C. a day, 60 when anchored on a ley line or in the Bermuda Triangle.', 'Rifts World Book 35: Megaverse in Flames p.133-134'),
  ('hell-battle-barge', 'Hell Battle Barge', 'rifts', 'ship', 'Greater Deevils: 4 Beasts, 4 Horrors, 2 Arch Fiends, 2 Deevil Dragons. Lesser Deevils: 6 Deevils, 6 Devilkins, 6 Fiends, 2 Gorgons, 6 Harpies, 6 Imps and 1D4 Soulmancers. Others: 40 Host or mortal slaves', '60-120 troops depending on size, doubled if they are human-sized; mostly Minions of Dyval, sometimes mortal Blood Warriors, mages and dark priests. Also War Steeds and small vehicles', 'Hovers up to 40 ft (12.2 m) over land or sea; 50 mph (80 km) maximum, cruising 30 mph (48 km). Speed and height +50% on a ley line or in the Devil''s (Bermuda) Triangle', 'Limited flight: the same hover, up to 40 ft (12.2 m) high', 'Mystic propulsion 40 mph (64 km), 80 mph (128 km) on ley lines and in the Devil''s Triangle. Cannot submerge', 'Height 66 ft (20.1 m); width 55 ft (16.8 m); length 280-330 ft (85.34-100.6 m)', '500-600', NULL, 1, NULL, NULL, 'Never sold openly; the book values one at hundreds of millions of credits.', 'Dyval Hell Battle Barge, a Demonic Hover Battleship: a landing craft that crosses water and runs straight up onto shore to put troops, War Steeds, light vehicles and guns against the enemy, and a hovering mobile command post. Riding above the waves it is safe from rough seas and reefs, and it can hide inland or in an island''s trees where no sailor expects a ship. Built like the Galleon and Schooner. Five decks: engineering below the main deck holds the Blood Pool tanks (eight, each of 2,000 gallons/7,570 liters), stores, slave pens and a mystic generator turning blood into ammunition and drive power, fed by sacrifices and by slaves kept alive to be bled again and again; the main deck carries the side Blood Cannons, a Soul Cannon at bow and stern, and a central hold and troop bay unloading through side ramps; the third level is quarters and galley, with two giant searchlights and two missile launchers on its roof, run from the command deck; the fourth is the command deck with officers'' rooms, war room and a communications room holding a second Blood Pool; the open top deck has a sacrificial altar draining into it. The four giant decorative horns shield the quarters and troop bay from the rear, and each hides a large secret compartment for magic items, weapons, blood barrels or 6-10 prisoners. Main body: front 760, mid-ship 650 and rear 8,600 M.D.C. sections rather than one figure, so mdc_main_body is empty; the rear figure is printed so and is likely 860. Losing a section sinks her in 3D6 minutes. Cargo: up to 750 tons. Power: magic, 100 P.P.E. an hour plus blood, 10 gallons (38 liters) an hour or 15 gallons (56.7 liters) at top speed. Self-repair: 30 M.D.C. a day, 60 when anchored on a ley line or in the Bermuda Triangle.', 'Rifts World Book 35: Megaverse in Flames p.134-136');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('hell-galleon', 'Front Mast', 65, 'Losing a mast or sail cuts sailing speed by 30%.', 1),
  ('hell-galleon', 'Mid-Mast', 90, 'Losing a mast or sail cuts sailing speed by 30%.', 2),
  ('hell-galleon', 'Rear Mast', 65, 'Losing a mast or sail cuts sailing speed by 30%.', 3),
  ('hell-galleon', 'Sails (3)', 35, 'Each. The book''s footnote on speed is starred on the masts only.', 4),
  ('hell-galleon', 'Ram Prow', 600, NULL, 5),
  ('hell-galleon', 'Rudder', 250, NULL, 6),
  ('hell-galleon', 'Protruding Spikes', 50, 'Each.', 7),
  ('hell-galleon', 'Weapons on Swivels (10)', 50, 'Each.', 8),
  ('hell-galleon', 'Front Section', 1200, 'Main body section; depleting it sinks the ship in 4D6 minutes.', 9),
  ('hell-galleon', 'Mid-Ship', 800, 'Main body section; depleting it sinks the ship in 4D6 minutes.', 10),
  ('hell-galleon', 'Rear Section', 900, 'Main body section; depleting it sinks the ship in 4D6 minutes.', 11),
  ('hell-galleon', 'Hull (per 20 ft/6.1 m area)', 250, 'A holed area takes on water and sinks her in 4D6x10 minutes; repairable.', 12),
  ('hell-galleon', 'Keel (per 10 ft/3 m area)', 500, 'Each section destroyed cuts top speed by 20%, cumulative.', 13),
  ('hell-schooner', 'Front Mast', 35, 'Losing a mast or sail cuts sailing speed by 30%.', 1),
  ('hell-schooner', 'Mid-Mast', 45, 'Losing a mast or sail cuts sailing speed by 30%.', 2),
  ('hell-schooner', 'Rear Mast', 35, 'Losing a mast or sail cuts sailing speed by 30%.', 3),
  ('hell-schooner', 'Sails (3)', 25, 'Each.', 4),
  ('hell-schooner', 'Bow Figurehead, Large (1)', 120, NULL, 5),
  ('hell-schooner', 'Bow Figurehead, Small (1)', 90, NULL, 6),
  ('hell-schooner', 'Ram Prow (1)', 200, NULL, 7),
  ('hell-schooner', 'Rudder', 150, NULL, 8),
  ('hell-schooner', 'Protruding Spikes', 25, 'Each.', 9),
  ('hell-schooner', 'Blood Cannons (6)', 50, 'Each.', 10),
  ('hell-schooner', 'Altar', 175, NULL, 11),
  ('hell-schooner', 'Blood Pool', 150, 'Below deck. Destroying it disables the ship; see the description.', 12),
  ('hell-schooner', 'Front Section', 440, 'Main body section; depleting it sinks the ship in 4D6 minutes.', 13),
  ('hell-schooner', 'Mid-Ship', 330, 'Main body section; depleting it sinks the ship in 4D6 minutes.', 14),
  ('hell-schooner', 'Rear Section', 400, 'Main body section. Printed with the Blood Pool''s footnote mark rather than the other sections''.', 15),
  ('hell-schooner', 'Hull (per 20 ft/6.1 m area)', 80, 'Printed per 20 ft diameter. A holed area takes on water and sinks her in 4D6x10 minutes; repairable.', 16),
  ('hell-schooner', 'Keel (per 10 ft/3 m area)', 200, 'Printed per 10 ft diameter. Each section destroyed cuts top speed by 20%, cumulative.', 17),
  ('hell-battle-barge', 'Decorative Horns, Giant (4)', 200, 'Each. Each hides a secret storage compartment.', 1),
  ('hell-battle-barge', 'Searchlights, Giant (2, top)', 100, 'Each.', 2),
  ('hell-battle-barge', 'Missile Launchers (2, top)', 100, 'Each.', 3),
  ('hell-battle-barge', 'Side Boarding Ramps (4, 2 each side)', 100, 'Each.', 4),
  ('hell-battle-barge', 'Blood Cannons (16; eight per side)', 100, 'Each.', 5),
  ('hell-battle-barge', 'Heavy Soul Cannons (2)', 500, 'Each.', 6),
  ('hell-battle-barge', 'Soul Cannon Gunner Compartments (2)', 200, 'Printed without the word each.', 7),
  ('hell-battle-barge', 'Internal Blood Pool Tanks (9)', 150, 'Each. Eight in engineering and one by the communications room.', 8),
  ('hell-battle-barge', 'Altar', 175, NULL, 9),
  ('hell-battle-barge', 'Front Section', 760, 'Main body section; depleting it sinks the ship in 3D6 minutes.', 10);

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('hell-battle-barge', 'Mid-Ship', 650, 'Main body section; depleting it sinks the ship in 3D6 minutes.', 11),
  ('hell-battle-barge', 'Rear Section', 8600, 'Printed 8600, ten times the other sections; likely 860. Depleting it sinks the ship in 3D6 minutes.', 12),
  ('hell-battle-barge', 'Hull (per 20 ft/6.1 m area)', 80, 'Printed per 20 ft diameter. A holed area takes on water and sinks her in 4D6x10 minutes; repairable.', 13);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('hell-galleon', 1, 'Medium to Moderately Heavy Weapons (10)', '1D6x10 M.D. per blast', 1, '2,000 feet (610 m)', 'Four blasts each per melee round; each blast is one melee attack', '50 blasts each from its own supply; four more blasts for one gun cost 20 S.D.C. and 5 H.P., or 20 M.D.C. from a supernatural gunner', NULL, 'Assault and ranged combat, secondarily defense. Any tech or magic gun can go here (lasers, rail guns, Blood, Soul or Lightning Cannons, TW weapons); most Deevil ships carry Kreelo''s Lightning Cannons. Two sit above the prow and four along each side, each crewed by a gunner, swivelling 120 degrees side to side and 45 up or down. Blood-fed guns refill from a Blood Pool or from the gunner himself.'),
  ('hell-galleon', 2, 'Ram Prow', '3D6x10 M.D. +5 M.D. per mph of speed; 3D6x10+350 M.D. at 70 mph on a ley line against a stationary target', 1, 'Contact', 'About once every six minutes at most', NULL, NULL, 'Anti-ship. An enchanted ram that wrecks other hulls without harming her own; usually used to block or cripple a ship before boarding.'),
  ('hell-galleon', 3, 'Magic', NULL, 1, NULL, NULL, NULL, NULL, 'The crew''s spellcasters and Deevils attack other vessels and defend the ship, most of all at close range and against boarders.'),
  ('hell-galleon', 4, 'Deevil Troops', NULL, 1, NULL, NULL, NULL, NULL, 'The crew listed above; always enough to repel or launch a boarding, and some can fly or swim ahead to scout, chase ships and stop missiles or torpedoes.'),
  ('hell-schooner', 1, 'Blood Cannons (6)', '5D6 M.D. per blast', 1, '2,000 feet (610 m)', 'Each blast is one attack of its gunner', '30 shots per hopper of about 2 gallons (7.5 liters) of blood', NULL, 'Assault and anti-aircraft, secondarily defense. Three along each rail, the ship''s only mounted guns, swivelling 90 degrees side to side and 90 up or down. A slave runs blood from the Pool to refill the hoppers, and a slow one may be bled into them himself. Other guns could be fitted instead.'),
  ('hell-schooner', 2, 'Ram Prow', '1D4x10 M.D. +2 M.D. per 10 mph of speed', 1, 'Contact', 'About once every six minutes at most', NULL, NULL, 'Anti-ship. An ordinary ram below the waterline, meant to hole a hull; usually used to block or cripple a ship before boarding.'),
  ('hell-schooner', 3, 'Attacking Figureheads (2; bowsprit)', 'Large figurehead 4D6 M.D.; small figurehead 3D6 M.D.', 1, 'Contact, with a 16 ft (4.9 m) reach', 'Up to three attacks each per melee round', NULL, NULL, 'Anti-ship and anti-personnel. Two enchanted monsters on long necks where a bowsprit would be, biting at sails, hulls, crews or anything near; the necks sway 30 degrees any way and lunge an extra 6 ft (1.8 m).'),
  ('hell-schooner', 4, 'Magic', NULL, 1, NULL, NULL, NULL, NULL, 'Chameleon, only while motionless, hiding the ship to flee or lie in ambush until it moves or acts, at a gallon (3.8 liters) of blood an hour. Cloud of Fog or Mist, a thick white cloud of 60 ft (18.2 m) radius, six uses per gallon of blood. The crew''s spellcasters add their own magic.'),
  ('hell-schooner', 5, 'Deevil Troops', NULL, 1, NULL, NULL, NULL, NULL, 'The crew listed above repel boarders or leave the ship to fight on other ships, on land or in the water; a few can always fly or swim to scout or attack.'),
  ('hell-battle-barge', 1, 'Blood Cannons (16)', '5D6 M.D. per blast', 1, '2,000 feet (610 m)', 'Each blast is one attack of its gunner', '30 shots per hopper of about 2 gallons (7.5 liters) of blood', NULL, 'Assault and anti-aircraft, secondarily defense. Eight down each side like an old galleon''s broadside, each with its own gunner, turning 90 degrees side to side and 60 up or down. Slaves carry blood from the Pool to the hoppers. Other guns could be fitted instead.'),
  ('hell-battle-barge', 2, 'Double-Barreled Soul Cannons (2)', '1D6x10+10 M.D. to a 10 ft (3 m) area per single blast, or 2D6x10+20 M.D. for both barrels at one target', 1, '2 miles (3.2 km)', 'Two dual blasts or four single blasts per melee round', '50 dual or 100 single blasts from each gun''s 100 gallon (378.5 liter) blood tank; the Blood Pools can usually refill each 1D4 more times before fuel runs short', NULL, 'Anti-ship, anti-fortification and artillery; secondarily assault, anti-armor and anti-Netherbeast. The Deevil Soul Cannon, shielded by big ram horns, at bow and stern. The gunner gets a feed from the war room and orders from the command deck; each turns 180 degrees side to side and 90 up or down.'),
  ('hell-battle-barge', 3, 'Medium-Range Missile Launchers (2)', 'By missile; typically fragmentation 2D4x10 M.D. (20 ft/6.1 m radius), high explosive 2D6x10 M.D. (15 ft/4.6 m), armor piercing 2D6x10 M.D. (5 ft/1.5 m) or plasma 2D6x10 M.D. (15 ft/4.6 m)', 1, 'Typically 5 miles (8 km); 3 miles (4.8 km) for plasma and fragmentation', 'One at a time or volleys of two or four', '32, 16 per launcher, with 32 more in the cargo bay; reloading 16 takes 1D6+4 minutes', NULL, 'Anti-ship, anti-fortification and artillery; secondarily assault, anti-armor and anti-Netherbeast. Conventional launchers either side of the bridge, turning 360 degrees and 90 up or down.'),
  ('hell-battle-barge', 4, 'Magic', NULL, 1, NULL, NULL, NULL, NULL, 'As the Hell Schooner: Chameleon while motionless at a gallon (3.8 liters) of blood an hour, and Cloud of Fog or Mist of 60 ft (18.2 m) radius, six uses per gallon. The crew''s spellcasters add their own magic.'),
  ('hell-battle-barge', 5, 'Deevil Troops', NULL, 1, NULL, NULL, NULL, NULL, 'The crew and troops listed above repel boarders or go out to fight on other ships, on land or in the water; a few can always fly or swim to scout or attack.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 3 machines are in' AS assertion, count(*) AS got, 3 AS want
  FROM vehicles WHERE slug IN ('hell-galleon', 'hell-schooner', 'hell-battle-barge');
SELECT 'their 43 locations are in' AS assertion, count(*) AS got, 43 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('hell-galleon', 'hell-schooner', 'hell-battle-barge');
SELECT 'their 14 weapon entries are in' AS assertion, count(*) AS got, 14 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('hell-galleon', 'hell-schooner', 'hell-battle-barge');
SELECT 'each main body location equals mdc_main_body' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body'
  WHERE v.slug IN ('hell-galleon', 'hell-schooner', 'hell-battle-barge') AND l.mdc IS NOT NULL AND v.mdc_main_body IS NOT NULL AND l.mdc <> v.mdc_main_body;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~347-megaverse-in-flames-dyval-arms.sql');
