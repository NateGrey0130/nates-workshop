-- Rifts World Book 20: Canada, batch 2b: the four Tundra Ranger vehicles,
-- printed 188-191. 4 vehicles, 40 M.D.C. locations, 11 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-canada-vehicles.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-canada-vehicles.sql
--
-- ALL FOUR ARE NEW - catalog-diff --table vehicles --remote and a slug query,
-- 2026-10-02. Pages are printed folios; the cache page is the folio plus one.
--
-- mdc_main_body is the main body alone; every other location is a
-- vehicle_locations row in printed order. The SOL Flying Arsenal prints two
-- lists, the framework hovercycle's and its weapon systems', and both are
-- stored, the second marked 'weapon system' in mdc_note. Its main body is
-- the framework hovercycle's 160. The Snow Lion prints two main body lines,
-- the forward cab section (150) and the main body (300); 300 is stored and
-- both are locations.
--
-- A RANGE STORES ITS LOW END. Two of the four are not for sale and print no
-- price of their own (cost NULL); what a comparable vehicle costs is in
-- cost_note.
--
-- THE SOL'S FORWARD LASER is printed ahead of its six numbered weapon
-- systems with no number; it is ordinal 0.
--
-- THE DIGIT CIPHER lands on the SOL's rail gun (1D4x10), its missiles
-- (4D6x10, 2D4x10, 1D4x10), its main laser cannon (1D6x10) and the Snow
-- Lion's missiles (2D4x10). Each is read as the dice it can only be.
--
-- The cache prints the hovercycle's main body as 'Mam Body' and breaks the
-- Snow Lion's Capacity line across two lines; both are typesetting, and the
-- figures beside them are unaffected.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book)
VALUES
  ('legion-2-20-snowmobile', 'Legion 2/20 Snowmobile', 'rifts', 'vehicle', 'One.', 'One human-sized driver and one human-sized passenger up to 7.6 feet (2.3 m) and a total of 600 pounds (270 kg). Suits Headhunters and light cyborgs; a big full conversion cyborg halves the speed and gives -15% to the piloting skill.', 'Top speed 100 mph (160 km); cruising speed usually 30-40 mph (48-64 km). More than 60 mph (96 km) is for flat open ground. Woodlands or rugged terrain reduce maximum speed by 50-70%. Thruster assisted leaps 15 feet (4.6 m) high and 50 feet (15.2 m) across.', NULL, NULL, 'Height 2.5 feet (0.76 m); width 3 feet (0.9 m); length 6 feet (1.8 m)', '800 pounds (360 kg)', 85, 45000, 'The Tundra Rangers sometimes sell and trade it, and Northern Gun and others offer similar snowmobiles at 45,000 to 60,000 credits (higher in remote regions) with the standard alcohol or gasoline turbine engine and a 250 mile (400 km) range; excellent availability. One million credits for the nuclear powered version with a 10 year life; rare. The low end is stored.', 'A low, sleek two seat snowmobile driven by computer-controlled vector jets, braked by forward jets under the belly and in the nose. It needs a trail or path in very rugged or mountainous country. Power is a liquid fuel turbine engine (250 miles/400 km) or nuclear (effectively unlimited). A hovercycle or hover vehicle pilot skill covers it. Cargo is minimal (rifle, survival kit, backpack), plus 200 pounds (90 kg) strapped outside and another 200 pounds (90 kg) towed, which cuts speed by 20% and gives -10% to the pilot skill. No weapons are printed.', 'Rifts World Book 20: Canada p.188'),
  ('legion-50-50-arctic-hovercycle', 'Legion 50/50 Arctic Hovercycle', 'rifts', 'vehicle', 'One; a passenger can squeeze on, but may slide off during quick maneuvers.', 'One human-sized passenger and 500 pounds (225 kg). Suits Headhunters and light cyborgs; heavy full conversion cyborgs may be too large and/or heavy. More than 50 pounds (22.6 kg) over the allowance gives -10% to the piloting skill and cuts speed by 10%.', NULL, 'Hover stationary to 100 mph (160 km); cruising speed typically around 40-50 mph (64-80 km). Thruster assisted leaps 25 feet (7.6 m) high and 80 feet (24.4 m) across. Flight ceiling 50 feet (15.2 m); VTOL capable.', NULL, 'Height 4 feet (1.2 m) body; width 3.6 feet (1.1 m), tapering to a foot (0.3 m) toward the front; length 8 feet (2.4 m). Landing gear is three retractable skis, two at the rear sides and one centered under the front.', '1,200 pounds (540 kg)', 120, NULL, 'Not sold by the Tundra Rangers. The Novyet version (slightly faster and more powerful, and without the built-in weapon) sells for 90,000 to 120,000 credits with the standard internal combustion engine, or 1.1 million nuclear; a built-in weapon is 50,000-100,000 extra.', 'A pre-Rifts Canadian military hovercycle built for winter and arctic conditions: heat circulation and air-cycling keep the engine and hover jets from freezing, with heated locks and defrosting. It runs at -130 F (-90 C) and, with minimal stalling, down to -200 F (-129 C). Its muffled soft-flow hover jets disturb little snow, which is why it is slower than ordinary hovercycles. Power is internal combustion (alcohol and/or gasoline mix, 300 miles/480 km) or nuclear (unlimited). Cargo is minimal (rifle, survival kit, backpack, a couple of small items), plus 200 pounds (90 kg) strapped outside and up to 300 pounds (136 kg) towed. The Novyet Arctic Hoverbike is a modified, slightly more advanced version of this design.', 'Rifts World Book 20: Canada p.188-189'),
  ('legion-sol-flying-arsenal', 'Legion SOL Flying Arsenal', 'rifts', 'vehicle', 'One, but 2-3 passengers can squeeze on; 8-10 when fully loaded, riding on top of the missiles.', '1-4 human-sized occupants and 20 tons of weapons.', NULL, 'Hover stationary to 50 mph (80 km); cruising speed typically around 30 mph (48 km). Speed rises by 30% once all missiles are jettisoned and by another 30% if the laser cannon is jettisoned. Leaps are not possible. Flight ceiling 50 feet (15.2 m); VTOL capable.', NULL, 'Height 6 feet (1.8 m) body; width 16 feet (4.9 m) fully loaded, 12 feet (3.6 m) as the cycle alone; length 9 feet (2.7 m) for the framework hovercycle alone, 20 feet (6 m) with the top mounted laser cannon, 28 feet (8.5 m) fully loaded with the medium-range missile.', '1,200 pounds (540 kg) for the framework hovercycle, two tons with the standard laser cannon mount, 20 tons fully loaded', 160, NULL, 'Not sold by the Tundra Rangers; it would cost millions of credits fully loaded.', 'A large framework hovercycle built as a saddle over a huge medium-range missile and hooked to several detachable weapon systems, with a long-range laser cannon mounted on top: a mobile assault unit made for silence, mobility and firepower, not speed, and narrow enough for streets, mountain passes and light forest. Power is internal combustion (alcohol and/or gasoline mix, 300 miles/480 km) or nuclear (unlimited). Cargo space is good (1-2 rifles, sidearm, survival kit, backpack, half a dozen saddlebags), plus up to 1000 pounds (450 kg) strapped outside and 300 pounds (136 kg) towed. The Rangers field 50: 24 at headquarters, six at Regina and a pair at each of ten outposts. The main body figure stored is the framework hovercycle''s.', 'Rifts World Book 20: Canada p.189-190'),
  ('legion-armored-snow-lion-apc', 'Legion Armored Snow Lion A.P.C.', 'rifts', 'vehicle', '2-4.', 'Up to 18 passengers comfortably, 20 cramped, depending on the configuration of the rear and side bays: six behind the pilot and 10-12 in the side compartment. A detachable M.D.C. trailer hauls another 24 troops and 10 tons of equipment, or up to 100 tons of cargo.', 'Top 60 mph (96 km), typical cruising speed 40 mph (64 km). Deep snow and treacherous terrain may reduce speed to under 20 mph (32 km); hauling a loaded trailer reduces speed by 30%.', NULL, NULL, 'Height 12 feet (3.6 m); width 14 feet (4.3 m); length 20 feet (6 m), 40 feet (12.2 m) with the trailer', '10 tons for the main vehicle, and another 6 tons plus cargo with the trailer', 300, 600000, 'Not sold by the Tundra Rangers; a comparable vehicle would cost about 600,000 Universal Credits as the basic cargo vehicle with a liquid fuel and generator system. Add one million for nuclear power (+20 M.D.C.), 100,000 for each grenade launcher, 250,000 for the short-range missile launcher, 300,000 for the laser turret, 30,000 to fit the side cargo area as living quarters for eight, and 100,000 for a laboratory and research cabin. As many as four light weapon systems can be built in at extra cost.', 'A big, heavy tracked all-terrain personnel carrier for snow and ice, with a small pilot''s compartment (driver and 2-3 passengers) and enclosed environmental compartments behind and beside it; the side compartment has reclining seats, computer and communications stations, a storage cabinet, a water cooler and a small bathroom. It drives through blizzards, rides on deep snow, survives an avalanche, takes a plow, fords water up to seven feet (2.1 m) deep and climbs inclines up to 55 degrees (30 to 45 is optimum). It carries 20 tons and pulls another 100. Power is a liquid fuel combustion engine and generator (700 miles/1120 km) or nuclear (unlimited). Life support: sealable cab and cabins with an 8 hour oxygen supply, air recycled for about 14 days, withstands 400 Rads. Sensors: the standard large-vehicle suite, plus a digital HUD whose passive nightvision and range-finder each reach 1,500 feet (457 m). Depleting the main body destroys the engine and drive system.', 'Rifts World Book 20: Canada p.190-191');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('legion-2-20-snowmobile', 'Rear Turbojets (2)', 20, 'each', 1),
  ('legion-2-20-snowmobile', 'Small Braking/Maneuvering Jets (4)', 6, 'each; small target: called shot only, attacker -3 to strike', 2),
  ('legion-2-20-snowmobile', 'Snow Skis (2)', 25, 'each; small target: called shot only, attacker -3 to strike', 3),
  ('legion-2-20-snowmobile', 'Headlights (2)', 3, 'each; small target: called shot only, attacker -3 to strike', 4),
  ('legion-2-20-snowmobile', 'Reinforced Windshield', 10, NULL, 5),
  ('legion-2-20-snowmobile', 'Main Body', 85, 'depleting it destroys the vehicle', 6),
  ('legion-50-50-arctic-hovercycle', 'Small Hoverjets (5; undercarriage)', 18, 'each; small target: called shot only, attacker -3 to strike', 1),
  ('legion-50-50-arctic-hovercycle', 'Main Jet Thrusters (2; rear)', 30, 'each', 2),
  ('legion-50-50-arctic-hovercycle', 'Landing Skis (3)', 15, 'each; small target: called shot only, attacker -3 to strike', 3),
  ('legion-50-50-arctic-hovercycle', 'Headlight (1; large)', 8, 'small target: called shot only, attacker -3 to strike', 4),
  ('legion-50-50-arctic-hovercycle', 'Forward Laser (1)', 35, 'small target: called shot only, attacker -3 to strike', 5),
  ('legion-50-50-arctic-hovercycle', 'Reinforced Windshield', 10, NULL, 6),
  ('legion-50-50-arctic-hovercycle', 'Main Body', 120, 'depleting it destroys the vehicle', 7),
  ('legion-sol-flying-arsenal', 'Small Directional Jets (8)', 10, 'each; small target: called shot only, attacker -3 to strike', 1),
  ('legion-sol-flying-arsenal', 'Side Hover Pads (2)', 20, 'each; small target: called shot only, attacker -3 to strike', 2),
  ('legion-sol-flying-arsenal', 'Main Jet Thrusters (3; rear)', 35, 'each', 3),
  ('legion-sol-flying-arsenal', 'Spotlight (1)', 10, 'small target: called shot only, attacker -3 to strike', 4),
  ('legion-sol-flying-arsenal', 'Forward Laser (1)', 35, 'small target: called shot only, attacker -3 to strike', 5),
  ('legion-sol-flying-arsenal', 'Main Body', 160, 'the framework hovercycle; depleting it destroys the vehicle', 6),
  ('legion-sol-flying-arsenal', 'Rail Gun in Medium-Range Missile (1; nose)', 25, 'weapon system; small target: called shot only, attacker -3 to strike', 7),
  ('legion-sol-flying-arsenal', 'Massive Medium-Range Missile', 100, 'weapon system', 8),
  ('legion-sol-flying-arsenal', 'Short-Range Missiles (2; sides)', 35, 'weapon system; each', 9),
  ('legion-sol-flying-arsenal', 'Main Laser Cannon (1)', 120, 'weapon system', 10),
  ('legion-sol-flying-arsenal', 'Silver Spears (2; one forward, one rear)', 20, 'weapon system; each; small target: called shot only, attacker -3 to strike', 11),
  ('legion-sol-flying-arsenal', 'Mini-Missiles (6; 2 on each hover pad, 4 undercarriage)', 10, 'weapon system; each; small target: called shot only, attacker -3 to strike', 12),
  ('legion-armored-snow-lion-apc', 'Forward Windows (4 large; front cab)', 25, 'each', 1),
  ('legion-armored-snow-lion-apc', 'Headlights (4)', 2, 'each; small target: called shot only, attacker -3 to strike', 2),
  ('legion-armored-snow-lion-apc', 'Rear Lights (4)', 2, 'each; small target: called shot only, attacker -3 to strike', 3),
  ('legion-armored-snow-lion-apc', 'Small Spotlights (2; top of cab)', 10, 'each; small target: called shot only, attacker -3 to strike', 4),
  ('legion-armored-snow-lion-apc', 'Cab Hatches (2; one on the side, one top rear)', 60, 'each', 5),
  ('legion-armored-snow-lion-apc', 'Large Bay Doors of Side Compartment (2; front and back)', 120, 'each', 6),
  ('legion-armored-snow-lion-apc', 'Large Hatch (1; rear of small passenger compartment)', 100, 'small target: called shot only, attacker -3 to strike', 7),
  ('legion-armored-snow-lion-apc', 'Tractor Treads (2)', 90, 'each', 8),
  ('legion-armored-snow-lion-apc', 'Side Mounted Laser Turrets (2)', 100, 'each; small target: called shot only, attacker -3 to strike', 9),
  ('legion-armored-snow-lion-apc', 'Top Mounted Grenade Launchers (2)', 100, 'each; small target: called shot only, attacker -3 to strike', 10),
  ('legion-armored-snow-lion-apc', 'Short-Range Missile Launcher (1; driver''s side)', 150, NULL, 11),
  ('legion-armored-snow-lion-apc', 'Reinforced Pilot''s Compartment', 50, NULL, 12),
  ('legion-armored-snow-lion-apc', 'Main Body: Forward Cab Section', 150, 'depleting the main body destroys the engine and drive system', 13),
  ('legion-armored-snow-lion-apc', 'Side Passenger Compartment', 220, NULL, 14),
  ('legion-armored-snow-lion-apc', 'Main Body', 300, 'depleting the main body destroys the engine and drive system; +20 if nuclear powered', 15);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('legion-50-50-arctic-hovercycle', 1, 'Forward Laser', '4D6 M.D. per blast', 1, '1,600 feet (487 m)', 'Equal to the number of hand to hand attacks of the pilot (usually 4-6)', '60 shots; unlimited if tied to a nuclear power system', NULL, 'Primary purpose defense. A long-range, medium laser controlled by the driver; swivels 180 degrees side to side and 30 degrees up and down.'),
  ('legion-sol-flying-arsenal', 0, 'Forward Laser', '4D6 M.D. per blast', 1, '1,600 feet (487 m)', 'Equal to the number of hand to hand attacks of the pilot (usually 4-6)', '60 shots; unlimited if tied to a nuclear power system', NULL, 'Primary purpose defense. The hovercycle''s own laser, printed ahead of the six numbered systems; swivels 180 degrees side to side and 30 degrees up and down.'),
  ('legion-sol-flying-arsenal', 1, 'Rail Gun in the nose of the Medium-Range Missile', '1D4x10 M.D. per 30 round burst; only fires bursts', 1, '4,000 feet (1220 m)', NULL, 'Internal belt-fed ammo drum with 2,400 rounds (80 bursts)', NULL, 'Primary purpose anti-personnel. A light, cheap, disposable unit meant to be spent before the missile is launched. Fixed forward: the whole vehicle must turn to aim.'),
  ('legion-sol-flying-arsenal', 2, 'Massive Medium-Range Missile', 'Varies with missile type; the Tundra Rangers can typically make only High Explosive, 4D6x10 M.D.', 1, '40 miles (64 km)', 'One', 'One', NULL, 'Primary purpose anti-armor, bunker and monster. The framework hovercycle sits on top of the missile and clamps to its sides. On launch the missile hovers for 30 seconds while its rockets heat up, and the hovercycle detaches and moves clear.'),
  ('legion-sol-flying-arsenal', 3, 'Short-Range Missiles', 'Typically High Explosive or Armor Piercing, both 2D4x10 M.D.', 1, '3-5 miles (4.8 to 8 km) respectively', 'One', 'Two', NULL, 'Primary purpose anti-vehicle and anti-monster. One on each side of the medium-range missile, mounted on the landing strut. The Rangers cannot make other types of missile.'),
  ('legion-sol-flying-arsenal', 4, 'Mini-Missiles', 'Typically Fragmentation 5D6 M.D. or Armor Piercing 1D4x10 M.D.', 1, 'One mile (1.6 km)', 'One or two', 'Six: one on each hover pad and four on the undercarriage', NULL, 'Primary purpose assault and defense.'),
  ('legion-sol-flying-arsenal', 5, 'Main Laser Cannon', '1D6x10 M.D. per single blast', 1, '4000 feet (1200 m)', 'Three on auto-targeting (ADR), or the gunner''s hand to hand attacks (usually 4-6)', 'Laser power pack good for 80 blasts', NULL, 'Primary purpose assault. A variation on the cannon in the base bunkers; moves 30 degrees side to side and up, 45 degrees down.'),
  ('legion-sol-flying-arsenal', 6, 'Silver Spears', '1D4 M.D. fired as a projectile, or as per damage suited to creatures vulnerable to the spearhead (typically 2D6 H.P./M.D.C.)', 1, '1000 feet (305 m)', 'One', 'Two ready to fire, four total, with two stowed on the undercarriage', NULL, 'Primary purpose assault. Silver plated spears fired like a harpoon gun, one forward and one rear; they can also be used as a lance, or detached as a hand-held weapon. Interchangeable spearheads of bone and stone are carried for monsters vulnerable to those.'),
  ('legion-armored-snow-lion-apc', 1, 'Side Laser Turrets (2)', '5D6 M.D. per blast', 1, '2,000 feet (610 m)', 'Equal to the number of hand to hand attacks of the pilot (usually 4-6)', '60 shots each; unlimited if tied to a nuclear power system', NULL, 'Primary purpose defense. A long-range, medium laser controlled by the driver; rotates 360 degrees with a 90 degree side to side arc.'),
  ('legion-armored-snow-lion-apc', 2, 'Top-Mounted Grenade Launchers (2)', '4D6 M.D. per grenade', 1, '1,600 feet (487 m)', 'One or two per melee attack; equal to the number of hand to hand attacks of the gunner (usually 4-6)', '120; 60 each', NULL, 'Primary purpose defense: light assault and defense against ground troops, monsters and light vehicles.'),
  ('legion-armored-snow-lion-apc', 3, 'Short-Range Missile Launcher', 'Typically High Explosive or Armor Piercing, both 2D4x10 M.D.', 1, '3-5 miles (4.8 to 8 km) respectively', '1, 2, 4 or 6 missiles in a volley', 'Eighteen total', NULL, 'Primary purpose anti-vehicle and anti-monster, secondary assault. One launcher, on the left (driver''s) side. The Rangers cannot make other types of missile.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 4 Canada vehicles are in' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles WHERE slug IN ('legion-2-20-snowmobile', 'legion-50-50-arctic-hovercycle', 'legion-sol-flying-arsenal', 'legion-armored-snow-lion-apc') AND source_book LIKE 'Rifts World Book 20: Canada p.%';
SELECT 'their 40 M.D.C. locations are in' AS assertion, count(*) AS got, 40 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('legion-2-20-snowmobile', 'legion-50-50-arctic-hovercycle', 'legion-sol-flying-arsenal', 'legion-armored-snow-lion-apc');
SELECT 'their 11 weapon entries are in' AS assertion, count(*) AS got, 11 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('legion-2-20-snowmobile', 'legion-50-50-arctic-hovercycle', 'legion-sol-flying-arsenal', 'legion-armored-snow-lion-apc');
SELECT 'each main body agrees with its Main Body location' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location = 'Main Body' AND l.mdc = v.mdc_main_body
 WHERE v.slug IN ('legion-2-20-snowmobile', 'legion-50-50-arctic-hovercycle', 'legion-sol-flying-arsenal', 'legion-armored-snow-lion-apc');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-canada-vehicles.sql');
