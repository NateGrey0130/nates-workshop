-- Phase World vessels, first half: the six robots and power armour of
-- `Robots & Powered Armor` (printed 130-142) and the five tanks and IFVs of
-- `Tanks & Infantry Fighting Vehicles` (143-150). Eleven vessels.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-pw-vessels-p130-150.sql
--
-- BOOK-INGEST-AUDIT.md F3, for the rest of this book. The survey closed on
-- 2026-08-31 leaving these vessels out because `gear` had no shape for one;
-- migration 048 built vehicles, vehicle_locations and vehicle_weapons on
-- 2026-09-03, and zzzzzzzz-pw-vessels-p128-130.sql moved the one Phase World
-- vessel that was already hiding in `gear` (the Psionic Power Armor, F41).
-- This is the data that was still waiting on those tables.
--
-- == THE COUNT, TAKEN OFF THE PAGES RATHER THAN THE SURVEY ==
--
-- The survey and F3 both said 25 vessels in 130-149 and 157-173 (6 + 5 + 14).
-- Counting `M.D.C. by Location` blocks in the cache, and checking the book's
-- own Contents (printed 5-6) against them, gives 23: 6 robots and power armour
-- (130-142), 5 tanks and IFVs (143-149) and TWELVE starships and shuttles
-- (157-173), not fourteen. The two the survey over-counted are Contents lines
-- with no stat block - `Star Ships` on printed 173 is one prose paragraph
-- about capital ships (12,000-40,000 M.D.C., no model, no weapons) - and
-- the survey's own line 395 counted "ten" in 130-149 where there are eleven.
-- Printed 134 and 136 are full-page art with no text, which is why the cache
-- is empty there; the Groundpounder's block runs 135 -> 137 across them.
--
-- == WHAT IS DELIBERATELY PROSE ==
--
-- VARIABLE FORCE FIELDS stay in `description`. Printed 156 gives military
-- and large ships six shield values - front, back, left, right, top and
-- bottom - and lets the crew shift points between them or stack the total on
-- one side, so the number is a pool redistributed in play, not a location
-- that takes damage in a fixed place. `vehicle_locations` holds what the
-- book's `M.D.C. by Location` block prints and nothing else.
--
-- `cost` is the LOW end of any range, in credits, per the convention
-- gear.cost documents; `cost_note` carries the whole Market Cost line. A
-- vessel the book says is never sold carries cost NULL, which is a finished
-- answer here.
--
-- Every figure was read from the cached OCR of a SCAN and then confirmed
-- against a 150-250 dpi render of the page, by the extraction pass and again
-- by a book-reconcile pass; the OCR repairs are listed per vessel below.
--
-- INSERT OR IGNORE throughout, and the readbacks COUNT rather than trusting
-- the exit code. Sorts after zzzzzzzz-pw-vessels-p128-130.sql, whose readback
-- asserts exactly one Phase World vessel; checked with the class-import sort
-- command rather than reasoned about.
--
-- Pure ASCII with LF endings. The book sets curly quotes and em-dashes; they
-- are stripped here.
--
-- == THIS FILE, VESSEL BY VESSEL ==
--
-- THE KARTUHM-TEREK RUNS ONTO PRINTED 150, which is why this file is named
-- p130-150 and not p130-149. Its weapon systems 4 (the tail) through 8 are
-- set on 150, above the `Starships & Space` heading; the survey's section
-- table ends the tanks at 149.
--
-- THE BATTLERAM, PHALANX AND MANIPLE print a single-value force field INSIDE
-- their `M.D.C. by Location` block (500, 700 for the front third only, and
-- 200), so it is a location row whose note says so, the shape the Psionic
-- Power Armor set. None of the three is variable.
--
-- THE BOMBARD's weapon system 5 is one numbered entry - an optional head
-- weapons pod - offering three unnumbered alternatives (missile, laser and
-- mortar pods). They are three rows sharing ordinal 5, which the table's
-- UNIQUE (vehicle_slug, ordinal, name) admits, rather than invented ordinals.
--
-- OCR repairs, each read off the render: the Ground Pounder's and the Warlord
-- Mark I's weight print as `| ton (907 kg)` in the cache, a pipe for the 1;
-- the Dark Slayer's model type caches as `I[AF-95` and is IAF-95; the
-- Kittani Robot-Fighter's M.D.C. list on 140 is welded line by line into
-- the prose column beside it and was read from the render alone.
--
-- `cost` is the price of the vessel AS STATTED: the Silverhawk, Bombard and
-- Phalanx knock-offs and rebuilds the book also prices are in cost_note.
--
-- A book error kept as printed and said so in the row: the Dark Slayer's
-- width is set `24 m (8 m)`. (The Kittani's `Wieght` label is the book's
-- typo too; only the value is stored.)

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('silverhawk-attack-exoskeleton', 'Silverhawk Attack ExoSkeleton (CAF)', 'rifts', 'power-armor',
   'One',
   NULL,
   'Running: 70 mph (112.6 km) maximum; running tires the operator at only 5% of the usual fatigue rate thanks to the exoskeleton and contragravity system (10% if the contragravity system is destroyed).',
   'Flying: up to Mach 2 (approximately 1340 mph/2144 km) in an atmosphere or Mach 12 in space. Altitude: unlimited, the contragravity system allows the suit to escape a planet''s atmosphere and fly out of orbit. Range: unlimited, limited only by pilot endurance.',
   'Underwater: maximum speed of 50 mph (80 km) to a maximum depth of 1000 feet (310 m).',
   'Height: 9 feet (2.7 m); Width: 11 feet (3.4 m) including the wings, 5 feet (1.5 m) otherwise; Length: 4 feet (1.2 m)',
   '1000 lbs (450 kg)',
   420, 3400000,
   'Cheaper knock-offs can be found in disreputable ports (and Phase World); they cost 1 to 1.5 million credits but have 30% less M.D.C. and lack the force field disrupter and the stealth system.',
   'Model Type: SH-CCW 100; Class: Space-capable assault exoskeleton. A compromise between firepower/heavy armor and speed/maneuverability, in Consortium Armed Forces service for over a century; only the best CAF pilots are assigned to Silverhawk units. Sleek streamlined design with aerodynamic wings used mainly as a weapons platform; contragravity propulsion makes the wings unnecessary for flight. Normal color is polished silver but a stealth system lets it assume the color of surrounding terrain or starry sky. Used in combined fighter/power-armor assaults on large enemy vessels, penetrating starship hulls via a special space-time distorter (Force Field Disrupter) added to its contragravity flight. Rifts Note: the contragravity system is centuries ahead of Rifts Earth tech and cannot be repaired outside Phase World or the Three Galaxies if destroyed. Physical Strength: Equal to a P.S. 50. Cargo: None. Power System: Nuclear; average energy life of 20 years.',
   'Rifts Dimension Book 2: Phase World p.130-132'),

  ('battleram-attack-robot', 'Battleram Attack Robot (CAF)', 'rifts', 'robot',
   'Two: one pilot and a co-pilot/gunner. A communications/sensor officer is optional.',
   'The robot can hold as many as twelve human passengers comfortably. Usually carries a ten-man combat squad equipped with heavy combat armor, grav packs and full combat gear, or a four-man power armor assault force in Silverhawks or Ground Pounders.',
   'Running: 40 mph (64 km) maximum.',
   'Flying: Mach 8 in outer space; Mach 1 maximum in an atmosphere. Range: effectively unlimited.',
   NULL,
   'Height: 70 feet (21.3 m) from the bottom of its feet to the top of its sensor head; Width: 40 feet (12.2 m) from shoulder to shoulder; Length: 30 feet (9.1 m)',
   '220 tons (200 metric tons) fully loaded',
   2500, 200000000,
   'The CAF never sells this vehicle; any found in the possession of others are stolen or captured.',
   'Model Type: BR-CCW2000; Class: Anti-Ship Assault Robot. A ship destroyer, the largest robot in CAF service and one of the largest in the Three Galaxies; launched from a carrier-ship, it closes on enemy vessels firing as it goes, then smashes through the hull to tear the ship apart. Can release its carried squad into enemy ships to capture or destroy them. When flying, the arms lock extended forward/upward like a flying superhero, and pilot/co-pilot use its weapons to neutralize escorts; it can only dodge attacks while flying and remains a large, easy-to-hit target, so is usually escorted by fighters or smaller robots like the Silverhawk. Physical Strength: Equal to a P.S. 70. Cargo: lockers for the crew, an armory, and an 8x8x8 foot (2.4x2.4x2.4 m) storage bay. Power System: Antimatter, average energy life 30 years. The M.D.C. of the Force Field must be depleted before any part of the robot can be targeted and attacked.',
   'Rifts Dimension Book 2: Phase World p.133-135'),

  ('ground-pounder-pa-10', '"Ground Pounder" PA-10 Infantry Power Armor (CAF)', 'rifts', 'power-armor',
   'One',
   NULL,
   'Running: 100 mph (160 km) maximum, tiring the operator at 10% of the usual fatigue rate thanks to the robot exoskeleton. Jumping: the legs can leap up to 15 feet (4.6 m) high or across.',
   'Flying: Not possible.',
   NULL,
   'Height: 9 feet (2.7 m) from head to toe; Width: 6 feet (1.8 m); Length: 4 feet (1.2 m)',
   '1 ton (907 kg)',
   450, 4000000,
   'Market cost 4 million credits.',
   'Model Type: CAF-PA-10; Class: Ground Infantry Assault Exo-Skeleton. Non-flying power armor supporting CAF ground-assault units; big and solid-looking, built to soak up punishment while dishing out as much or more in return, outfitted with missiles, mortars and lasers for both frontal assault and artillery support. Some PA-10 suits turn up on the black markets of the CCW and openly at places like Phase World; nobody knows the supplier, but black-market Ground Pounders may explain how the Free World Council rebels arm themselves against the Empire. Physical Strength: Equal to a P.S. of 45. Cargo: None. Power System: Anti-matter, average energy life 50 years.',
   'Rifts Dimension Book 2: Phase World p.135-137'),

  ('warlord-mark-i', 'Warlord Mark I Combat Suit (Transgalactic Empire)', 'rifts', 'power-armor',
   'One',
   NULL,
   'Running: 90 mph (144 km).',
   'Flying: Not possible.',
   NULL,
   'Height: 12 feet (3.7 m); Width: 6 feet (1.8 m); Length: 6 feet (1.8 m)',
   '1 ton (907 kg)',
   400, 5500000,
   'Market cost 5.5 million credits.',
   'Model Type: IPA-WI-K; Class: Assault Exoskeleton. Designed around the kreeghor race''s unique anatomy, giving the suit the same sinuous, crouched posture; brutal, blindingly fast and lethal like the kreeghor themselves. Elite kreeghor armored units use the Warlord suit exclusively; not designed to fly, since kreeghor prefer space fighters or true aircraft and leave flying armor to their humanoid underlings (see Warlord Mark II). Used in space combat as a shipboard/station defense force, but primarily as ''groundsider'' infantry where kreeghor speed and strength are most effective. Heavily armed with a gravity autocannon, particle beam gun, missile launcher and double-barreled helmet lasers; for close combat it extends two adamantine forearm blades sharpened to a molecular edge, able to slice open the toughest M.D.C. armor. Physical Strength: Equal to pilot''s P.S. +6 (supernatural); only Kreeghor can use the suit. Cargo: None. Power System: Antimatter; average energy life 50 years.',
   'Rifts Dimension Book 2: Phase World p.137-139'),

  ('warlord-mark-ii', 'Warlord Mark II Combat Suit (Transgalactic Empire)', 'rifts', 'power-armor',
   'One',
   NULL,
   'Running: 90 mph (144 km).',
   'Flying: In outer space, Mach 7; in an atmosphere, maximum flying speed is Mach 1.',
   NULL,
   'Height: 10 feet (3.1 m); Width: 6 feet (1.8 m); Length: 5 feet (1.5 m)',
   '1500 lbs (680 kg)',
   320, 4000000,
   'Market cost 4 million credits.',
   'Model Type: IPA-WI-H; Class: Assault Exoskeleton. Designed to fit most humanoid races who serve as Transgalactic Empire soldiers, including humans and wolfen. Similar basic styling and design to the Mark I, including forearm blades, but smaller and less well protected; instead of two main weapon systems it has only the gravity autocannon, but it can fly. Physical Strength: Equal to a P.S. of 40. Cargo: None. Power System: Anti-matter; average energy life 50 years.',
   'Rifts Dimension Book 2: Phase World p.139-140'),

  ('kittani-transformable-robot-fighter', 'Kittani Transformable Robot-Fighter', 'rifts', 'robot',
   'One',
   NULL,
   'Running: 60 mph (96 km) in humanoid form; running is not possible in fighter form.',
   'Flying: Mach One in humanoid form or Mach 7 (Mach 9 in space) in fighter form. Range: effectively unlimited.',
   NULL,
   'Height: 15 feet (5.6 m) standing on its legs, about half that in fighter form; Width: 7 feet (2.1 m) in humanoid form, or 30 feet (10 m) in fighter form; Length: 6 feet (1.8 m) in humanoid form, or 30 feet (10 m) in fighter form',
   '5 tons (4,500 kg)',
   450, 8000000,
   'Market cost 8 million credits.',
   'Model Type: K-TRF-M; Class: Robot-Fighter Vehicle. The Splugorth space fleets rely on this transformable robot to cover the needs of both space fighters and war robots. Its design is similar to the Kittani Land Skimmer (Rifts Atlantis, page 156), only much larger, heavily armored, and equipped with an assortment of weapon systems, plus the ability to fly in and out of an atmosphere. Typically deployed from Dragon Dreadnoughts (Rifts Atlantis) or large Kittani or Kydian spaceships. Physical Strength: Equal to a P.S. 40. Cargo: a small 3x3 foot (0.9x0.9 m) area. Power System: Nuclear; average energy life 25 years. Note: Destroying the sensor head eliminates all optical enhancement/sensory systems; the pilot must rely on human vision and senses without strike/parry/dodge bonuses from the bot. Depleting the M.D.C. of the main body shuts the armor down completely, making it useless.',
   'Rifts Dimension Book 2: Phase World p.140-142'),

  ('bombard-infantry-robot', '"Bombard" Infantry Robot (CAF)', 'rifts', 'robot',
   'Three: one pilot, one co-pilot/gunner and a gunner/communications officer. Can carry one additional passenger.',
   'One additional passenger (see crew).',
   'Running: 70 mph (122.6 maximum). Leaping: 20 feet (6.1 m) high or lengthwise from a standing still position; 30 feet (9.1 m) high or 40 feet (13.7 m) lengthwise from a running start.',
   'Not possible',
   NULL,
   'Height: 30 feet (9.1 m) with weapons pod attached, or 25 feet (7.6 m) without; Width: 12 feet (3.6 m) from shoulder to shoulder; Length: 7 feet (2.1 m)',
   '20 tons fully loaded or 18 tons without weapons pod',
   600, 50000000,
   'Cheap knock-offs made by pirate factories and sold to mercenaries/criminals: reduce price by 30 percent, but M.D.C., performance and weapon systems are reduced by 50 percent.',
   'Model Type: CAF-AR-20. Class: Ground Infantry Assault Robot with multiple weapon systems. A medium-sized headless robot used by the Consortium Armed Forces to support ground attacks in swamps, jungles and forests where tanks cannot operate efficiently; organized in platoons of three and companies of twelve, usually attached to Ground Pounder power armor or infantry. Instead of a head it carries a reconfigurable weapon pod (see Weapon Systems 5). Physical Strength: Equal to a P.S. 50. Cargo: small area for the crew personal items. Power System: Anti-Matter; average energy life of 50 years.',
   'Rifts Dimension Book 2: Phase World p.143-145'),

  ('phalanx-main-battle-tank', 'Phalanx Main Battle Tank (CAF/Wolfen)', 'rifts', 'vehicle',
   'Eight: pilot, commander, communication officer and five gunners.',
   NULL,
   'Driving on the ground: 200 mph (320 km) maximum. Contragravity system allows very tight turns, unexpected direction changes, and floating over obstacles. Not a hover tank; no vulnerable fans or thrusters underneath.',
   'Limited flying: 120 mph (192 km) to a maximum altitude of 1000 feet (305 m). Underbelly is vulnerable while flying and weapon systems are -4 to strike anything beneath the tank (no penalty against targets in front or above).',
   NULL,
   'Height: 24 feet (8 m); Width: 30 feet (9 m); Length: 40 feet',
   '250 tons',
   950, 150000000,
   '150 million credits for a fully operational and equipped Phalanx. A partially rebuilt tank (M.D.C. reduced 30 percent, force field power reduced 50 percent) costs between 90 and 120 million credits. Cheap black-market imitations (M.D.C. and force field reduced 40 to 50 percent, half lack the force field entirely, no gravity cannons, replaced by a shorter-range plasma ejector, and missing one of the other five main weapon systems) cost between 60 and 80 million credits.',
   'Model Type: MBT-35 CAF. Class: Main Battle Tank. One of the oldest vehicle designs still in service in the CAF, originally a Wolfen Empire design; a contragravity vehicle almost as fast and maneuverable as an aircraft but armored and armed to handle any land vehicle, named for the five forward-pointing weapon barrels. Has an oversized turret with two cannons, a cupola-mounted autocannon, two hull-mounted weapons, and a rear MLRS; each gunner has an individual armored battle station controlling one weapon system. Carries a heavy-duty force field projected only along the front third of the tank, giving it extra density there and near-imperviousness to frontal attacks, at the cost of vulnerable flanks screened in the field by lighter vehicles, power armor and robots. Usually carried aboard military spaceships as landing-force assets; also garrisons CCW trouble spots and has reached mercenaries, independent worlds and the black market. Cargo: minimal storage, about four feet (1.2 m) for extra clothing, weapons and personal items. Power System: Anti-matter; average energy life of 30 years.',
   'Rifts Dimension Book 2: Phase World p.145-146'),

  ('maniple-ifv-apc', 'Maniple IFV APC (CAF)', 'rifts', 'vehicle',
   'Three: Pilot, gunner and commander/gunner.',
   'Troop Capacity: up to 12 soldiers in power armor or 36 troopers in combat armor.',
   '200 mph (320 km) maximum speed. Can travel over ground and water and lift up to 20 feet (6.1 m) off the surface via air cushion; contragravity system allows floating higher, but every additional 6 feet (2 m) above 20 reduces maximum speed by 50 mph (80 km).',
   NULL,
   'Can travel over water (see speed_ground).',
   'Height: 16 feet (5.4 m); Width: 12 feet (4 m); Length: 30 feet (10 m)',
   '18 tons fully loaded',
   380, 55000000,
   'Market cost 55 million credits.',
   'Model Type: IFV-100 CAF. Class: Infantry Fighting Vehicle. An old Wolfen Empire design, named after one of its military units, adopted by the CAF to replace its light armored personnel carriers. Dual mission: medium-class tank and transport for a power armor platoon (12-man squad, or 36 infantry); four can be carried in a standard military assault shuttle for planetary assaults. A hover vehicle on an air cushion aided by a contragravity system, one of the fastest land vehicles available; while not as powerful as a main battle tank it can engage tanks or robot assault vehicles with a reasonable chance of survival, and its power armor squad can scout, harass or make surgical strikes. Also used for garrison duty protecting facilities or colonies. Cargo: in addition to troops, five 3 ft (0.9 m) by 3 ft compartments for supplies and first-aid kits. Power System: Anti-matter, average energy life of 50 years.',
   'Rifts Dimension Book 2: Phase World p.147'),

  ('dark-slayer-main-battle-tank', 'Dark Slayer Main Battle Tank (Transgalactic Empire)', 'rifts', 'vehicle',
   'Five: a commander, a pilot, a communications/sensor officer, and two gunners.',
   NULL,
   '200 mph (320 km) maximum speed over land. Can hover up to 5 feet (1.5 m) above ground and travel without penalty over swamps and mud, but is too heavy to hover above or on water.',
   NULL,
   'Too heavy to hover above or on water.',
   'Height: 21 feet (7 m); Width: printed "24 m (8 m)" - the book''s own unit slip; 8 m is about 26 feet; Length: 35 feet (7.9 m)',
   '180 tons',
   650, 37000000,
   'Market cost 37 million credits.',
   'Model Type: IAF-95 MBT. Class: Main Battle Tank (hover). A heavy hover tank using standard air-cushion systems rather than a more effective but expensive contragravity generator; main weapon is a heavy laser cannon similar to those on medium/light starships, with effective line-of-sight range even in atmosphere and, combined with advanced sensors, can engage high-flying aircraft or spacecraft entering atmosphere. Purpose is to break and scatter infantry and destroy other tanks. A veteran of the Consortium-Imperial War twenty years ago, where it proved slightly inferior to the CAF Phalanx, but is cheaper to produce, letting the Transgalactic Empire field twice as many for half the cost. Still in service, used for counter-insurgency in wilderness areas; some captured examples are rumored to be cached by freedom fighter factions, denied by the Empire. Cargo: minimal storage for personal effects. Power System: Nuclear; average energy life of 25 years.',
   'Rifts Dimension Book 2: Phase World p.147-148'),

  ('kartuhm-terek-doomsday-machine', 'Kartuhm-Terek "The Doomsday Machine" (TE)', 'rifts', 'vehicle',
   'Fourteen: one pilot, one co-pilot, two sensor officers, one communication officer, and nine gunners. Can carry up to 20 Kreeghor-sized passengers; the rest of the vehicle is dedicated to armor and redundant systems.',
   'Up to 20 Kreeghor-sized passengers (see crew).',
   'Driving on the Ground: 80 mph (128 km) maximum. Hovers about one foot off the ground; obstacles weighing less than one ton do not significantly slow it (can plow through light vehicles and houses without slowing down).',
   'Flying: Not possible; contragrav generators may increase altitude temporarily, up to 300 feet for about an hour before overloading the system, for example to traverse chasms at high speed, but no sustained flight is possible. Range: Effectively unlimited.',
   NULL,
   'Height: 80 feet (24.4 m); Width: 50 feet (15.2 m); Length: 120 feet (36.5 m)',
   '10,000 tons',
   3000, 420000000,
   '420 million credits is a production cost; no Kartuhm-Terek has ever been captured intact, and its value on the black market could reach a billion credits or more.',
   'Model Type: KT-1 (Transgalactic Empire). Class: Strategic Super-heavy Armored Vehicle. The largest military land vehicle in the Three Galaxies, named after a mythological Doomsday Machine of Kreeghor legend; as tall as a small building and several times more massive than the heaviest tanks. A contragravity system keeps it floating a few inches off the ground, with brief higher-altitude bursts; a turbine propulsion system keeps pace with lighter vehicles. Wedge-shaped front for ramming through obstacles such as trees, blockades, houses and small hills; multiple turrets give it a mini-battleship look. Firepower is comparable to a spaceship rather than a land vehicle, more than a company of main battle tanks and an artillery battery combined, and its twin laser main guns can hit targets 60,000 feet above the ground. Has multiple redundant systems: three power plants, contragravity and propulsion. Easy to hit due to its size, but hard to significantly damage; the Transgalactic Empire spearheads planetary invasions with a tank division led by a single Doomsday Machine, whose mere sight can rout enemy troops. Cargo: minimal personal storage, a small locker per crew member, plus a weapons locker with 20 rifles, 4 rocket launchers and 4 reloads each. Power System: Anti-matter; average energy life of 25 years.',
   'Rifts Dimension Book 2: Phase World p.148-150');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('silverhawk-attack-exoskeleton', 'Shoulder Plates (2)', 100, 'Each.', 1),
  ('silverhawk-attack-exoskeleton', 'Wings/Missile Launchers (2)', 100, 'Each.', 2),
  ('silverhawk-attack-exoskeleton', 'Multi-Rifle', 150, NULL, 3),
  ('silverhawk-attack-exoskeleton', 'Arms (2)', 120, 'Each.', 4),
  ('silverhawk-attack-exoskeleton', 'Legs (2)', 150, 'Each.', 5),
  ('silverhawk-attack-exoskeleton', 'Head', 100, 'Called shot only, attacker at -4 to strike; destroying it eliminates optical/sensory systems and all power armor combat bonuses, and in space the pilot suffers explosive decompression (most alien species take 1D4x10 S.D.C. and die in 1D4 minutes).', 6),
  ('silverhawk-attack-exoskeleton', 'Main Body', 420, 'Depleting shuts the armor down completely, making it useless. Destroying the wings does NOT affect flying performance.', 7),
  ('silverhawk-attack-exoskeleton', 'Contragravity System (1, in back)', 200, 'Destroying it halves the special bonuses below and prevents flying; a normal jet propulsion system or jet backpack can replace it but without the special flight bonuses, at a fraction of normal speed.', 8),
  ('battleram-attack-robot', 'Gravity Cannon (handheld)', 300, NULL, 1),
  ('battleram-attack-robot', 'HI-Laser Cannon (shoulder)', 250, NULL, 2),
  ('battleram-attack-robot', 'Pop-Up Cruise Missile Launcher', 200, NULL, 3),
  ('battleram-attack-robot', 'Long-range Missile Launchers (2, chest)', 200, 'Each.', 4),
  ('battleram-attack-robot', 'Medium-range Missile Launchers (2, legs)', 100, 'Each.', 5),
  ('battleram-attack-robot', 'Mini-Missile Launcher (Left Arm)', 100, NULL, 6),
  ('battleram-attack-robot', 'Laser Eyes (2)', 70, 'Each.', 7),
  ('battleram-attack-robot', 'Lower Arms (2)', 240, 'Each.', 8),
  ('battleram-attack-robot', 'Upper Arms (2)', 240, 'Each.', 9),
  ('battleram-attack-robot', 'Shoulders (2)', 400, 'Each.', 10),
  ('battleram-attack-robot', 'Hands (2)', 160, 'Each.', 11),
  ('battleram-attack-robot', 'Legs (2)', 600, 'Each.', 12),
  ('battleram-attack-robot', 'Feet (2)', 300, 'Each.', 13),
  ('battleram-attack-robot', 'Main Hatch (1, on the back)', 150, NULL, 14),
  ('battleram-attack-robot', 'Emergency Escape Hatches (2)', 60, 'Each.', 15),
  ('battleram-attack-robot', 'Head and Sensors', 400, 'Destroying it eliminates all optical/sensory systems; the pilot must rely on human vision and senses with no strike/parry/dodge bonuses from the bot.', 16),
  ('battleram-attack-robot', 'Main Body', 2500, 'Depleting shuts the armor down completely, making it useless.', 17),
  ('battleram-attack-robot', 'Reinforced Pilot''s Compartment (chest)', 170, NULL, 18),
  ('battleram-attack-robot', 'Force Field', 500, 'Must be depleted before any part of the robot can be targeted and attacked.', 19),
  ('ground-pounder-pa-10', 'Shoulder Missile Launchers (2)', 40, 'Each.', 1),
  ('ground-pounder-pa-10', 'Automatic Mortars (2)', 50, 'Each.', 2),
  ('ground-pounder-pa-10', 'Particle Beam Cannon (right arm)', 80, NULL, 3),
  ('ground-pounder-pa-10', 'Chest Laser', 60, NULL, 4),
  ('ground-pounder-pa-10', 'Arms (2)', 180, 'Each.', 5),
  ('ground-pounder-pa-10', 'Legs (2)', 200, 'Each.', 6),
  ('ground-pounder-pa-10', 'Head', 100, 'Called shot only, attacker at -4 to strike; destroying it eliminates optical enhancements/sensory systems and all power armor combat bonuses to strike, parry and dodge.', 7),
  ('ground-pounder-pa-10', 'Main Body', 450, 'Destroying it shuts the armor down completely, making it useless.', 8),
  ('warlord-mark-i', 'Gravity Autocannon (left arm)', 200, NULL, 1),
  ('warlord-mark-i', 'Particle Beam Gun (right arm)', 160, NULL, 2),
  ('warlord-mark-i', 'Missile Launcher (1, on back)', 100, NULL, 3),
  ('warlord-mark-i', 'Arms (2)', 180, 'Each.', 4),
  ('warlord-mark-i', 'Legs (2)', 220, 'Each.', 5),
  ('warlord-mark-i', 'Head', 120, 'Destroying the sensor head eliminates all optical enhancement/sensory systems; the pilot must rely on human vision and senses without strike/parry/dodge bonuses from the bot.', 6),
  ('warlord-mark-i', 'Main Body', 400, 'Depleting shuts the armor down completely, making it useless.', 7),
  ('warlord-mark-ii', 'Gravity Autocannon (rifle)', 190, NULL, 1),
  ('warlord-mark-ii', 'Missile Launcher (1, on back)', 100, NULL, 2),
  ('warlord-mark-ii', 'Arms (2)', 150, 'Each.', 3),
  ('warlord-mark-ii', 'Legs (2)', 200, 'Each.', 4),
  ('warlord-mark-ii', 'Head', 100, 'Destroying the sensor head eliminates all optical enhancement/sensory systems; the pilot must rely on human vision and senses without strike/parry/dodge bonuses from the bot.', 5),
  ('warlord-mark-ii', 'Main Body', 320, 'Depleting shuts the armor down completely, making it useless.', 6),
  ('kittani-transformable-robot-fighter', 'Pulse Cannons (2, on the wings or shoulders, heavily armor plated)', 150, 'Each.', 1),
  ('kittani-transformable-robot-fighter', 'Forearm Blades (2)', 75, 'Each.', 2),
  ('kittani-transformable-robot-fighter', 'Mini-Missile Launchers (2, sides or torso)', 100, 'Each.', 3),
  ('kittani-transformable-robot-fighter', 'Arms (2)', 170, 'Each.', 4),
  ('kittani-transformable-robot-fighter', 'Legs (2)', 220, 'Each.', 5),
  ('kittani-transformable-robot-fighter', 'Reinforced Pilot''s Compartment (chest)', 100, NULL, 6),
  ('kittani-transformable-robot-fighter', 'Head/Laser Turret', 180, NULL, 7),
  ('kittani-transformable-robot-fighter', 'Main Body', 450, 'Depleting shuts the armor down completely, making it useless.', 8),
  ('bombard-infantry-robot', 'Weapon Pod (one where the head should be)', 350, NULL, 1),
  ('bombard-infantry-robot', 'Plasma Cannons (two, one on each shoulder)', 150, 'Each.', 2),
  ('bombard-infantry-robot', 'Rail Gun "Accordion" (8 guns, 2 rows of 4, upper torso)', 200, NULL, 3),
  ('bombard-infantry-robot', 'Forearm Missile Launchers (two, one in each arm)', 100, 'Each.', 4),
  ('bombard-infantry-robot', 'Leg Missile Launchers (2)', 100, 'Each.', 5),
  ('bombard-infantry-robot', 'Legs (2)', 240, 'Each.', 6),
  ('bombard-infantry-robot', 'Arms (2)', 200, 'Each.', 7),
  ('bombard-infantry-robot', 'Hands (2)', 90, 'Each. Small or difficult target: called shot only, attacker is -2 to strike.', 8),
  ('bombard-infantry-robot', 'Sensor Arrays (4)', 75, 'Each. Small or difficult target: called shot only, attacker is -2 to strike. If all four destroyed, pilot and gunners lose the bots strike, parry and dodge bonuses.', 9),
  ('bombard-infantry-robot', 'Reinforced Pilots Compartment', 150, NULL, 10),
  ('bombard-infantry-robot', 'Main Body', 600, 'Depleting shuts the armor down completely, making it useless.', 11),
  ('phalanx-main-battle-tank', 'Laser Cannon (turret, left)', 200, NULL, 1),
  ('phalanx-main-battle-tank', 'Gravity Cannon (turret, right)', 200, NULL, 2),
  ('phalanx-main-battle-tank', 'Gravity Autocannon (cupola on top of turret)', 120, NULL, 3),
  ('phalanx-main-battle-tank', 'Turret', 600, 'Destroying the turret prevents the use of all its weapon systems.', 4),
  ('phalanx-main-battle-tank', 'Particle Beam Cannon (main body, right)', 200, NULL, 5),
  ('phalanx-main-battle-tank', '200 mm Flechette Gun (main body, left)', 180, NULL, 6),
  ('phalanx-main-battle-tank', 'MLRS (behind turret)', 160, NULL, 7),
  ('phalanx-main-battle-tank', 'Laser Mini-turrets (2, front sides)', 70, 'Each.', 8),
  ('phalanx-main-battle-tank', 'Main Body', 950, 'Depleting the M.D.C. of the main body destroys the vehicle.', 9),
  ('phalanx-main-battle-tank', 'Gunners Compartments (5)', 80, 'Each.', 10),
  ('phalanx-main-battle-tank', 'Pilots Compartment', 200, NULL, 11),
  ('phalanx-main-battle-tank', 'Force Field (protects front 1/3 of the vehicle only)', 700, 'A single value printed in the M.D.C. by Location list, covering the front third of the tank only; not a variable (per-facing) field.', 12),
  ('maniple-ifv-apc', 'Laser Cannon (in turret)', 100, NULL, 1),
  ('maniple-ifv-apc', 'Missile Launchers (2, turret sides)', 80, 'Each.', 2),
  ('maniple-ifv-apc', 'Main Turret', 180, 'Destroying the main turret prevents the use of all its weapon systems.', 3),
  ('maniple-ifv-apc', 'Mini-Missile Launchers (2, sides)', 50, 'Each.', 4),
  ('maniple-ifv-apc', 'RG-Gun cupola (front)', 100, NULL, 5),
  ('maniple-ifv-apc', 'Reinforced Pilots Compartment', 100, NULL, 6),
  ('maniple-ifv-apc', 'Main Body', 380, 'Depleting the M.D.C. of the main body destroys the vehicle, making it useless.', 7),
  ('maniple-ifv-apc', 'Force Field', 200, 'A single value printed in the M.D.C. by Location list; not a variable (per-facing) field.', 8),
  ('dark-slayer-main-battle-tank', 'Heavy Laser Cannon (1, in turret)', 180, NULL, 1),
  ('dark-slayer-main-battle-tank', 'Pulse Autocannon (1, in cupola over turret)', 80, NULL, 2),
  ('dark-slayer-main-battle-tank', 'Main Turret', 320, 'Destroying the main turret prevents the use of all turret weapons.', 3),
  ('dark-slayer-main-battle-tank', 'Kinetic Rocket Cage (on back)', 150, NULL, 4),
  ('dark-slayer-main-battle-tank', 'Side-mounted Medium-Range Missile Launchers (2)', 120, 'Each.', 5),
  ('dark-slayer-main-battle-tank', 'Bow-mounted Laser Guns (2)', 80, 'Each.', 6),
  ('dark-slayer-main-battle-tank', 'Fan Skirts', 300, 'Destroying the fan skirts destroys the hover system, grounding and immobilizing the vehicle. Field repairs take at least 1D6 hours with a 01-50 percent chance major repairs are needed. Hitting the fan skirts requires a called shot (no penalty).', 7),
  ('dark-slayer-main-battle-tank', 'Main Body', 650, 'Depleting the M.D.C. of the main body destroys the vehicle.', 8),
  ('dark-slayer-main-battle-tank', 'Reinforced Crew Compartment', 150, NULL, 9),
  ('kartuhm-terek-doomsday-machine', 'Laser Cannons (2)', 350, 'Each.', 1),
  ('kartuhm-terek-doomsday-machine', 'Heavy Missile Launchers (4, 2 in front, 2 in back)', 250, 'Each.', 2),
  ('kartuhm-terek-doomsday-machine', 'Gravity Cannon Turrets (2)', 200, 'Each.', 3),
  ('kartuhm-terek-doomsday-machine', 'Auto-loading Mortars (2)', 150, 'Each.', 4),
  ('kartuhm-terek-doomsday-machine', 'Medium Missile Launchers (4, on sides)', 100, 'Each.', 5),
  ('kartuhm-terek-doomsday-machine', 'Laser Batteries (4)', 100, 'Each.', 6),
  ('kartuhm-terek-doomsday-machine', 'Mini-Missile Launchers (4, one on each side)', 80, 'Each.', 7),
  ('kartuhm-terek-doomsday-machine', 'Reinforced Gunners Compartments (9)', 100, 'Each.', 8),
  ('kartuhm-terek-doomsday-machine', 'Reinforced Pilots Compartment (1)', 200, NULL, 9),
  ('kartuhm-terek-doomsday-machine', 'Entrance Hatches (3)', 150, 'Each.', 10),
  ('kartuhm-terek-doomsday-machine', 'Main Body', 3000, 'Depleting the M.D.C. of the main body completely destroys the outer hull. Due to multiple redundancy of sensor and communication systems, the vehicle stays fully operable until utterly destroyed.', 11);

-- ORDINALS ARE THE BOOK'S. Phase World numbers every Weapon Systems list.
INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('silverhawk-attack-exoskeleton', 1, 'Multi-Rifle',
   'HI-Laser: 2D4x10 M.D.; particle beam cannon: 3D6x10 M.D.; grenades: varies with grenade type. At short range, laser and particle beam cannon can fire together for a combined 4D6x10+20 M.D.', 1, 'Laser: 10,000 feet (3,050 m). Particle Beam Cannon: 2,000 feet (610 m). Grenade Launcher: 1,000 feet (305 m). All doubled in space.',
   'Equal to the total number of hand to hand attacks.',
   'Effectively unlimited for the laser and particle beam weapon; 200 grenades for the launcher.', NULL,
   'Primary: anti-armor/anti-ship; secondary: anti-personnel. Three-barreled main weapon: HI-laser cannon, particle beam generator, and grenade launcher.'),

  ('silverhawk-attack-exoskeleton', 2, 'Wing Mini-Missiles',
   'Varies with missile type; usually armor-piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.).', 1, 'About one mile (1.6 km); in space, limited by speed and distance of the target.',
   'One at a time or in volleys of 2, 4, 8 or 16.',
   '16 total, 8 on each wing.', NULL,
   'Primary: anti-ship; secondary: defense. 8 mini-missiles per wing.'),

  ('silverhawk-attack-exoskeleton', 3, 'Six-Shooters (2)',
   'A burst of three rounds does 5D6 M.D.; can only fire bursts.', 1, '800 feet (244 m), doubled in space.',
   'Equal to the total number of hand to hand attacks.',
   '240 rounds each; 80 bursts each.', NULL,
   'Primary: anti-personnel. Gravity gun mounted on each wrist, used for short range attacks or as a back-up weapon.'),

  ('silverhawk-attack-exoskeleton', 4, 'Force Field Disrupter',
   'None. Creates a momentary hole that the character can step through; no effect on solid objects or living things.', 0, '20 feet (6.1 m).',
   'One pulse per melee round; effect/hole lasts 3 seconds.',
   'Effectively unlimited.', NULL,
   'Primary: defense penetration. Pulses energy that cancels a ship''s force field, letting the Silverhawk walk through; must fly very close to the hull (force fields usually extend 10-20 feet/3-6 m from the hull).'),

  ('silverhawk-attack-exoskeleton', 5, 'Stealth Systems',
   NULL, 0, NULL,
   NULL,
   NULL, 'All attackers at -1 to strike while active.',
   'Changes color to match background and masks heat emissions, effectively invisible. Only effective while flying in a straight line or standing still; evasive maneuvers or attacks reveal its position (still hard to see and hit).'),

  ('silverhawk-attack-exoskeleton', 6, 'Hand to Hand Combat',
   'Restrained Punch 1D6 M.D.; Full Strength Punch 3D6 M.D.; Power Punch 6D6 M.D. (counts as two attacks); Kick 4D6 M.D.; Leap Kick 6D6+3 (counts as two attacks); Body Block/Ram (ground) 2D6 M.D.; Body Block/Ram (flying) 4D6 M.D.', 1, 'Melee.',
   NULL,
   NULL, '+2 to strike, +4 to parry, +4 to dodge on the ground, +6 to dodge flying, +3 to roll with impact, +2 to pull punch, +2 melee actions/attacks at level one, +1 additional attack at levels four, eight and twelve. If the gravity flying system is destroyed or disabled, halve the bonuses to parry, dodge and roll with impact.',
   'Bonuses and Damage from Silverhawk Combat Training; rather than use a weapon the pilot can engage in mega-damage hand to hand combat.'),

  ('battleram-attack-robot', 1, 'Gravity Cannon',
   'A burst is 20 rounds and does 4D6x10 M.D.; can only fire bursts.', 1, '6 miles (25 km) in space; about five miles (8 km) in an atmosphere.',
   'Equal to the total number of hand to hand attacks.',
   '10,000 rounds; 500 bursts.', NULL,
   'Primary: anti-armor/anti-ship; secondary: anti-aircraft. A 5 ton (4,500 kg) rifle-shaped GR autocannon that can be attached to back clamps when not in use.'),

  ('battleram-attack-robot', 2, 'HI-Laser Cannon',
   '3D6x10 M.D.', 1, '8 miles (12.8 km) in space, 2 miles (3.2 km) in an atmosphere.',
   'Equal to the total number of hand to hand attacks.',
   'Effectively unlimited.', NULL,
   'Primary: anti-armor & anti-ship; secondary: anti-aircraft. Mounted over the left shoulder; rotates 190 degrees up and 180 degrees left, cannot engage small targets closer than 20 yards.'),

  ('battleram-attack-robot', 3, 'Pop-Up Cruise Missile Launcher',
   '2D6x100 M.D. or 4D6x100 M.D.', 1, '10 miles (16 km).',
   'One.',
   'One missile.', NULL,
   'Primary: anti-ship; secondary: anti-building. Used point-blank (under one mile) against a large ship or space station.'),

  ('battleram-attack-robot', 4, 'Long-Range Missile Launchers (2)',
   'Varies with missile type.', 1, '500 miles (800 km).',
   'One at a time or volleys of two or four.',
   '8, four in each launcher.', NULL,
   'Primary: anti-robot/anti-aircraft; secondary: defense. In the chest, commonly used against fighters and robots.'),

  ('battleram-attack-robot', 5, 'Medium-Range Missile Launchers (2)',
   'Varies with missile type.', 1, 'About 50 miles (80 km).',
   'One at a time or volleys of two, four or eight.',
   '16, eight in each launcher.', NULL,
   'Primary: anti-fighter/anti-robot; secondary: defense. In the legs.'),

  ('battleram-attack-robot', 6, 'Mini-Missile Launcher (Left Arm)',
   'Varies with missile type.', 1, 'About one mile (1.6 km).',
   'One at a time or volleys of two, four, eight or sixteen.',
   '16 missiles.', NULL,
   'Primary: anti-personnel; secondary: defense. Can double as an anti-missile defense system.'),

  ('battleram-attack-robot', 7, 'Hand to Hand Combat',
   'Restrained Punch 4D6 M.D.; Full Strength Punch 2D6x10 M.D.; Power Punch 4D6x10 M.D. (two attacks); Crush, Pry or Tear 2D6x10 M.D.; Kick 3D4x10 M.D.; Leap Kick (only while flying) 4D6x10 M.D.; Body Flip/Throw 4D6 M.D.; Body Block/Ram (ground) 2D4x10 M.D.; Flying Ram 5D6x10 M.D.; Stomp 6D6 M.D. against targets 15 feet (4.5 m) tall or smaller.', 1, 'Melee.',
   NULL,
   NULL, '+1 to strike (in addition to weapon bonuses), +1 to parry, no dodge on the ground, +1 to dodge while flying, no roll with impact, +1 additional melee action/attack at levels 2, 6, 10 and 14. Halve combat bonuses and reduce attacks per melee by two if there is no co-pilot serving as gunner.',
   'Bonuses and Damage from Battleram Combat Training.'),

  ('ground-pounder-pa-10', 1, 'Particle Beam Cannon',
   '2D4x10 M.D. per blast.', 1, '4000 feet (1200 m).',
   'Equal to number of combined hand to hand attacks per melee round.',
   'Effectively unlimited.', NULL,
   'Primary: anti-armor; secondary: anti-personnel. Main weapon system, mounted on the right arm.'),

  ('ground-pounder-pa-10', 2, 'Missile Launchers (2)',
   'Varies with missile type.', 1, 'About one mile (1.6 km).',
   'One at a time or volleys of two or four.',
   '8 total, four per launcher.', NULL,
   'Primary: anti-aircraft/anti-personnel; secondary: defense. Each shoulder holds a mini-missile launcher with four missiles.'),

  ('ground-pounder-pa-10', 3, 'Automatic Mortars (2)',
   '4D6 M.D. to a 30 foot (9.1 m) radius.', 1, '4000 feet (1200 m); can fire above fortifications and obstacles.',
   'Equal to number of combined hand to hand attacks per melee round.',
   '60 round magazine per launcher.', NULL,
   'Primary: anti-personnel; secondary: anti-vehicle. Back-mounted; the Ground Pounder carries no reloads but can resupply from supply trucks.'),

  ('ground-pounder-pa-10', 4, 'Chest Laser',
   '4D6 M.D. per blast.', 1, '2000 feet (610 m).',
   'Equal to the total number of combined hand to hand attacks per melee round.',
   'Effectively unlimited.', NULL,
   'Primary: anti-personnel; secondary: defense. Used for close-range combat.'),

  ('ground-pounder-pa-10', 5, 'Hand to Hand Combat',
   'Normal Punch 2D4 M.D.; Power Punch 3D6 M.D. (all other abilities as Basic and Elite Power Armor Combat Training, Rifts page 45).', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'Rather than use a weapon, the pilot can engage in mega-damage hand to hand combat.'),

  ('warlord-mark-i', 1, 'Gravity Autocannon',
   '40 round burst inflicts 1D6x10+10 M.D.; can only fire bursts.', 1, '4000 feet (1200 m).',
   'Equal to number of combined hand to hand attacks.',
   '4000 round drum; 100 bursts.', NULL,
   'Primary: anti-armor; secondary: anti-personnel. Heavy rail-gun-like gravity weapon on the left arm, feeding off a back-mounted magazine.'),

  ('warlord-mark-i', 2, 'Particle Beam Gun',
   '2D4x10 M.D. per blast.', 1, '1000 feet (305 m).',
   'Equal to number of combined hand to hand attacks per melee.',
   'Effectively unlimited.', NULL,
   'Primary: anti-armor; secondary: anti-personnel. Less range but more power than the gravity autocannon; main anti-robot/anti-tank weapon.'),

  ('warlord-mark-i', 3, 'Missile Launcher',
   'Varies with missile type.', 1, 'About one mile (1.6 km).',
   'One at a time or volleys of two, four, six, eight or twelve.',
   '12 missiles.', NULL,
   'Primary: anti-aircraft; secondary: anti-personnel. Back-mounted mini-missile launcher holding 12 missiles in two superimposed rows.'),

  ('warlord-mark-i', 4, 'Head Lasers (2)',
   '3D6 M.D. per gun or double blast 6D6 M.D.; either counts as one attack/action.', 1, '2000 feet (610 m).',
   'Equal to number of combined hand to hand attacks.',
   'Effectively unlimited.', NULL,
   'Primary: anti-personnel; secondary: defense. Mounted on each side of the head, fire simultaneously as a quick-reaction weapon.'),

  ('warlord-mark-i', 5, 'Forearm Blades',
   '4D6 M.D. in addition to hand to hand damage.', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'Long slashing blades extended sideways for close combat.'),

  ('warlord-mark-i', 6, 'Hand to Hand Combat',
   'Same as Basic and Elite Power Armor Combat Training (Rifts page 45), except damage uses the supernatural strength of the wielder.', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'Rather than use a weapon, the pilot can engage in mega-damage hand to hand combat.'),

  ('warlord-mark-ii', 1, 'Gravity Autocannon',
   '40 round burst inflicts 1D6x10+10 M.D.; can only fire bursts.', 1, '4000 feet (1200 m).',
   'Equal to number of combined hand to hand attacks.',
   '4000 round drum; 100 bursts.', NULL,
   'Primary: anti-armor; secondary: anti-personnel. A rifle-shaped version of the gravity gun mounted on the Warlord Mark I.'),

  ('warlord-mark-ii', 2, 'Missile Launcher',
   'Varies with missile type.', 1, 'About one mile (1.6 km).',
   'One at a time or volleys of two, four, six, eight or twelve.',
   '12 missiles.', NULL,
   'Primary: anti-aircraft; secondary: anti-personnel. Back-mounted mini-missile launcher holding 12 missiles in two superimposed rows.'),

  ('warlord-mark-ii', 3, 'Head Lasers (2)',
   '3D6 M.D. per gun or double blast 6D6 M.D.; either counts as one attack/action.', 1, '2000 feet (610 m).',
   'Equal to number of combined hand to hand attacks.',
   'Effectively unlimited.', NULL,
   'Primary: anti-personnel; secondary: defense. Mounted on each side of the head, fire simultaneously as a quick-reaction weapon.'),

  ('warlord-mark-ii', 4, 'Forearm Blades',
   '3D6 M.D. in addition to hand to hand damage.', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'Long slashing blades extended sideways for close combat.'),

  ('warlord-mark-ii', 5, 'Hand to Hand Combat',
   'Restrained Punch 1D4 M.D.; Full Strength Punch 2D6 M.D.; Power Punch 4D6 M.D.; Kick 2D4 M.D.; Leap Kick 3D6 M.D. (all other abilities as Basic and Elite Power Armor Combat Training, Rifts page 45).', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'Rather than use a weapon, the pilot can engage in mega-damage hand to hand combat.'),

  ('kittani-transformable-robot-fighter', 1, 'Pulse Cannons (2)',
   '1D4x10 per single blast, or 2D4x10 per simultaneous double blast (counts as one melee attack).', 1, '4000 feet (1200 m).',
   'Equal to the pilot''s combined hand to hand attacks per melee.',
   'Effectively unlimited.', NULL,
   'Primary: anti-aircraft; secondary: defense. Mounted on the wings of the fighter form or the shoulders of the humanoid form.'),

  ('kittani-transformable-robot-fighter', 2, 'Mini-Missile Launchers (2)',
   'Varies with missile type.', 1, 'About one mile (1.6 km).',
   'One at a time or volleys of two, four or eight.',
   '16 missiles, eight per launcher.', NULL,
   'Primary: anti-aircraft; secondary: defense. Mounted on the sides of the fighter/robot.'),

  ('kittani-transformable-robot-fighter', 3, 'Laser Turret',
   '4D6 per single blast or 1D6x10+6 M.D. per double blast (counts as one melee attack).', 1, '4000 feet (1200 m).',
   'Equal to combined hand to hand attacks.',
   'Effectively unlimited.', NULL,
   'Primary: anti-armor; secondary: defense. The head''s twin lasers convert to a laser turret in fighter form.'),

  ('kittani-transformable-robot-fighter', 4, 'Forearm Energy Blades',
   '1D4x10 M.D. when powered up or 1D4 M.D. when used as blunt weapons.', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'The humanoid form''s arms have two energized blades.'),

  ('kittani-transformable-robot-fighter', 5, 'Hand to Hand Combat',
   'Restrained Punch 1D4 M.D.; Full Strength Punch 2D4 M.D.; Power Punch 3D6+6 M.D.; Kick 2D6 M.D.; Leap Kick 4D6 M.D. (all other abilities as Basic and Elite Power Armor Combat Training, Rifts page 45).', 1, 'Melee.',
   NULL,
   NULL, NULL,
   'Rather than use a weapon, the pilot can engage in mega-damage combat.'),

  ('bombard-infantry-robot', 1, 'Plasma Cannons (2)',
   '2D4x10 M.D. per single blast, or 4D4x10 M.D. for combined double blast (counts as two melee attacks)', 1, '4000 feet (1200 m)',
   'Equal to number of combined hand to hand attacks',
   'Effectively unlimited', NULL,
   'Primary: anti-armor. Secondary: assault. Mounted one on each shoulder; used mostly against robots and tanks.'),

  ('bombard-infantry-robot', 2, 'Rail Gun "Accordion" (8 guns, 2 rows of 4)',
   'Burst is 40 rounds per gun (320 rounds total): 1D4x10 M.D. to everything in a 30 foot (9 m) path in front; targets 12 feet (3.6 m) or larger take 2D4x10 M.D. Can only fire bursts.', 1, '1000 feet (305 m)',
   'Equal to number of combined hand to hand attacks',
   '6000 rounds per gun; 150 bursts total', '+1 to strike incoming missiles',
   'Primary: anti-personnel. Secondary: defense. Barrels bracket a 30 ft area in front of the bot; can knock down incoming missile fire.'),

  ('bombard-infantry-robot', 3, 'Forearm Missile Launchers (2)',
   'Varies with missile type', 1, 'About one mile (1.6 km)',
   'One, two or four missiles per volley',
   'Eight total; four in each arm', NULL,
   'Primary: defense, anti-personnel. Secondary: anti-aircraft.'),

  ('bombard-infantry-robot', 4, 'Leg Missile Launchers (2)',
   'Varies with missile type (usually plasma: 1D6x10 M.D.)', 1, 'About one mile (1.6 km)',
   'One at a time or in volleys of two, three, four or six missiles',
   '32 total; 16 in each leg', NULL,
   'Primary: anti-aircraft and anti-personnel. Secondary: defense.'),

  ('bombard-infantry-robot', 5, 'Optional Head Weapon Pod - Missile Pod',
   'Varies with missile type (has medium-range and mini-missiles)', 1, 'About one mile (1.6 km) for mini-missiles, about 50 miles (80 km) for medium-range missiles',
   'One at a time or in volleys of two, four, or eight',
   '10 medium-range missiles and 12 mini-missiles', NULL,
   'Primary: anti-aircraft and area bombardment. Secondary: anti-personnel and anti-armor. One of three interchangeable head pods, book item 5; only one pod mounted at a time; reloads from a supply truck in 10 minutes.'),

  ('bombard-infantry-robot', 5, 'Optional Head Weapon Pod - Laser Pod',
   '3D4x10 M.D. per laser burst', 1, 'One mile (1.6 km)',
   'Equal to number of combined hand to hand attacks per melee',
   'Effectively unlimited', NULL,
   'Primary: anti-armor and anti-aircraft. Secondary: defense. Heavy laser cannon variant of the head pod, issued for air defense or engaging enemy tanks and giant robots.'),

  ('bombard-infantry-robot', 5, 'Optional Head Weapon Pod - Mortar Pod',
   '1D4x10 M.D. (armor piercing, can be dodged) or 4D6 M.D. fragmentary (20 ft/6 m area); a burst of 10 rounds does fragmentary damage to a 200 ft (61 m) area', 1, 'Two miles (3.2 km)',
   'Single shots or bursts of 10 rounds; each counts as one melee attack',
   '200 rounds (100 fragmentary and 100 armor piercing)', NULL,
   'Primary: anti-personnel. Secondary: anti-armor. Two mortars firing side by side, smart rounds correct course within 200 ft (61 m) of landing spot.'),

  ('bombard-infantry-robot', 6, 'Hand to Hand Combat',
   'Restrained Punch 1D6 M.D.; Full Strength Punch 2D6 M.D.; Power Punch 4D6 M.D. (counts as two attacks); Vibro-blade 4D6 M.D.; Crush, Pry or Tear 1D6 M.D.; Kick 2D6 M.D.; Body Flip/Throw 1D6 M.D.; Body Block/Ram 2D4 M.D.; Stomp 2D4 M.D. against man-sized targets', 1, 'Melee',
   NULL,
   NULL, '+2 to strike, +4 to parry, +2 to dodge, +3 to roll with impact, +4 to pull punch, +2 melee actions/attacks at level one, +1 additional at levels 4, 6, 9 and 12',
   'Bonuses and Damage from Bombard Combat Training. Reduce combat bonuses by half if no co-pilot or gunner; reduce attacks per melee by two if co-pilot or gunner missing, by three if pilot is alone.'),

  ('phalanx-main-battle-tank', 1, 'Laser Cannon',
   '2D6x10 M.D. per energy pulse', 1, '2 miles (3.2 km)',
   'Equal to the number of combined hand to hand attacks of the gunner',
   'Effectively unlimited', NULL,
   'Primary: anti-armor. Secondary: anti-aircraft. Aimed independently of the adjacent gravity cannon; own gunner.'),

  ('phalanx-main-battle-tank', 2, 'Gravity Cannon',
   '4D6x10 M.D. per shot', 1, '4000 feet (1220 m)',
   'Equal to the number of combined hand to hand attacks of the gunner',
   '40 shots', NULL,
   'Primary: anti-armor. Fires solid depleted-uranium slugs with enormous penetration at short and medium range.'),

  ('phalanx-main-battle-tank', 3, 'Gravity Autocannon',
   'Burst of 40 rounds does 1D6x10+10 M.D.; can only fire bursts', 1, '4000 feet (1220 m)',
   'Equal to the number of combined hand to hand attacks of the gunner',
   '8000 rounds; 200 bursts', NULL,
   'Primary: anti-aircraft. Secondary: anti-personnel and anti-armor. Cupola-mounted, rotates 360 degrees up and sideways; operated by commander or a turret gunner.'),

  ('phalanx-main-battle-tank', 4, 'Particle Beam Cannon',
   'First setting: 1D6x10 M.D. concentrated beam. Second setting: 6D6 M.D. to a 50 ft (15.2 m) diameter area up to 600 ft (183 m) away.', 1, '2000 feet (610 m) first setting, 600 feet (183 m) second setting',
   'Equal to the number of combined hand to hand attacks of the gunner',
   'Effectively unlimited', NULL,
   'Primary: anti-armor and anti-personnel. Secondary: defense. Mounted on the front hull.'),

  ('phalanx-main-battle-tank', 5, '200 mm Flechette Gun',
   'Against large targets (10 ft/3.0 m tall/wide or higher): 3D4x10 M.D. Against human-sized targets: 1D4x10 M.D. to a 30 ft (9.1 m) diameter area.', 1, '6000 feet (1890 m)',
   'Equal to the number of combined hand to hand attacks of the gunner',
   '200 rounds', '+2 to shoot missiles aimed at the front of the tank only',
   'Primary: anti-armor and anti-personnel. Secondary: defense. Similar to the Glitter Boys Boom Gun; can traverse up to 90 degrees for limited anti-aircraft use.'),

  ('phalanx-main-battle-tank', 6, 'MLRS',
   'Varies with missile type; standard issue is half fragmentation (5D6 M.D.) and half plasma (1D6x10 M.D.)', 1, 'About one mile (1.6 km)',
   'One at a time or in volleys of 2, 4, 8 or 12 missiles',
   '48 missiles total; recycles another twelve from the missile magazine in one melee round (15 seconds) after firing the loaded twelve', NULL,
   'Primary: anti-aircraft and anti-personnel. Secondary: defense. Auto-loading, own individual gunner, engages air and ground targets.'),

  ('phalanx-main-battle-tank', 7, 'Laser Mini-Turrets (2)',
   '4D6 M.D. per single blast (cannot be fired in tandem)', 1, '2000 feet (610 m)',
   'Equal to the number of combined hand to hand attacks of the gunner',
   'Effectively unlimited', NULL,
   'Primary: anti-personnel. Secondary: defense. Side-mounted, operable by pilot, tank commander or communications officer.'),

  ('maniple-ifv-apc', 1, 'Laser Cannon',
   '2D6x10 M.D. per blast', 1, '4000 feet (1220 m)',
   'Equal to the number of hand to hand attacks per melee',
   'Effectively unlimited', NULL,
   'Primary: anti-tank. Secondary: defense. High-intensity cannon able to penetrate heavy armor.'),

  ('maniple-ifv-apc', 2, 'Missile Launchers (2)',
   'Varies with missile type; usually issued plasma missiles (2D6x10 M.D.)', 1, 'About 40 miles (64 km)',
   'One at a time or in volleys of two, four, or eight',
   '8 total; 4 per launcher', NULL,
   'Primary: anti-armor. Secondary: anti-aircraft. Mounted on each side of the main gun.'),

  ('maniple-ifv-apc', 3, 'Mini-Missile Launchers (2)',
   'Varies with missile type; usually a mix of fragmentation (5D6 M.D.) and plasma (1D6x10 M.D.)', 1, 'About one mile (1.6 km)',
   'One at a time or in volleys of two, four, eight or 16 missiles',
   '32 total; 16 per missile launcher', NULL,
   'Primary: anti-personnel, anti-aircraft. Secondary: defense. Built into the sides of the main body.'),

  ('maniple-ifv-apc', 4, 'GR Gun',
   '1D6x10 M.D. for a 10-round burst; only fires bursts', 1, '4000 feet (1220 m)',
   'Equal to the number of combined hand to hand attacks',
   '2000 rounds; 200 bursts', NULL,
   'Primary: anti-personnel. Secondary: defense. Gravity autocannon on a front mini-turret, rotates 360 degrees with a 90 degree up/down arc; usually operated by the tank commander.'),

  ('dark-slayer-main-battle-tank', 1, 'Heavy Laser Cannon',
   '3D6x10 M.D. per blast', 1, '3 miles (4.8 km)',
   'Equal to combined number of hand to hand attacks per melee',
   'Effectively unlimited', NULL,
   'Primary: anti-armor. Secondary: anti-aircraft and anti-personnel. Operated by one of the two turret gunners.'),

  ('dark-slayer-main-battle-tank', 2, 'Pulse Autocannon',
   '6D6 M.D.', 1, '2000 feet (610 m)',
   'Equal to the combined number of hand to hand attacks',
   'Effectively unlimited', NULL,
   'Primary: anti-aircraft. Secondary: defense and anti-personnel. Cupola-mounted atop the main turret, operated by the second gunner; often used against infantry, low-flying aircraft or flying power armor.'),

  ('dark-slayer-main-battle-tank', 3, 'Kinetic Rocket Cage',
   '2D6x10 M.D. per rocket; can be fired in volleys of two or four, one dodge roll determines whether all rockets hit or miss', 1, '4000 feet (1220 m)',
   'One at a time or in volleys of two or four',
   '8 rockets total', NULL,
   'Primary: anti-armor. Secondary: anti-aircraft. Holds 8 kinetic-kill rockets using contragravity generators for hypersonic, unguided flight; no warheads, solid metal relying on speed and density; do not use the special missile rules.'),

  ('dark-slayer-main-battle-tank', 4, 'Side-Mounted Medium-Range Missile Launchers (2)',
   'Varies with missile type; commonly plasma missiles (2D6x10 M.D.)', 1, 'About 40 miles (64 km)',
   'One at a time or in volleys of two, four, eight or sixteen',
   '16 total; 8 per launcher', NULL,
   'Primary: anti-armor and anti-aircraft. Secondary: defense. Used for long-range attacks.'),

  ('dark-slayer-main-battle-tank', 5, 'Bow-mounted Laser Guns (2)',
   '2D6 M.D. per single blast or 4D6 M.D. per dual blast', 1, '2000 feet (610 m)',
   'Equal to combined number of hand to hand attacks per melee',
   'Effectively unlimited', NULL,
   'Primary: anti-personnel. Secondary: defense. Light lasers used by the pilot or commander as anti-personnel or anti-missile weapons.'),

  ('kartuhm-terek-doomsday-machine', 1, 'Laser Cannons (2)',
   '1D6x100 M.D. per single blast or 2D6x100 M.D. per double blast', 1, '2,000 miles (3,200 km) in space; 60,000 feet (18,288 m) in atmosphere, roughly 11 miles',
   'Each gun can fire once per melee',
   'Effectively unlimited', NULL,
   'Primary: anti-armor and anti-aircraft. Secondary: anti-spaceship. Starship-level guns on two gimbal turrets in front; surrounded by sensor antennas tracking airborne and space targets, sensor range 5,000 miles; give one shot one kill results against most land vehicles or robots.'),

  ('kartuhm-terek-doomsday-machine', 2, 'Heavy Missile Launchers (4)',
   'Varies with missile type; commonly proton torpedoes or nuclear multi-warheads (4D6x10 M.D.); a limited number of fragmentation missiles for infantry (3D4x10 M.D.) are also carried', 1, 'About 500 miles (800 km)',
   'Each launcher fires volleys of 2, 4 or 8 missiles; all four firing at once can put 32 missiles in the air in one attack',
   '96 total; 8 per launcher plus auto-load from a 64-missile magazine', NULL,
   'Primary: anti-armor, anti-installation. Secondary: defense, anti-personnel. Long-range turrets, 2 in front and 2 in back.'),

  ('kartuhm-terek-doomsday-machine', 3, 'Gravity Cannons (2)',
   '3D6x10 M.D. per shot', 1, '6000 feet (1828 m)',
   'Equal to the number of combined hand to hand attacks per melee',
   '60 shots per gun', NULL,
   'Primary: anti-armor. Secondary: defense. Light artillery pieces heavy enough to be the main gun of a normal tank.'),

  ('kartuhm-terek-doomsday-machine', 4, 'Auto-loading Mortars (2)',
   'Fragmentary rounds do 1D4x10 M.D. to a 50 ft (15.2 m) blast diameter. Anti-armor rounds do 2D4x10 M.D. to a 10 ft (3 m) area.', 1, 'Two miles (3.2 km)',
   'Single shots or bursts of 10 rounds; each counts as one melee attack',
   '600 rounds per mortar', NULL,
   'Primary: anti-personnel. Secondary: anti-armor. Mounted on top, fires smart rounds that alter course to hit within 200 feet (61 m) of their landing spot; combination of armor piercing and fragmentary rounds; makes ambushing the vehicle suicidal.'),

  ('kartuhm-terek-doomsday-machine', 5, 'Medium Missile Launchers (4)',
   'Varies with missile type. Usually fires plasma missiles (2D6x10 M.D.)', 1, 'About 40 miles (64 km)',
   'One at a time or in volleys of two, four, or eight launchers, for a total of up to 32 missiles per melee round',
   '152 total: eight missiles per launcher plus an additional 120 in the missile magazine; recycling missiles from the magazine to the launcher takes one melee round', NULL,
   'Primary: anti-armor. Secondary: defense. Mounted on the sides; firing all missile systems temporarily obscures the tank in flash and smoke from over 60 launches.'),

  ('kartuhm-terek-doomsday-machine', 6, 'Laser Batteries (4)',
   '1D6x10 M.D. per blast', 1, '2000 feet (610 m)',
   'Equal to the number of combined hand to hand attacks per melee',
   'Effectively unlimited', NULL,
   'Primary: anti-aircraft and anti-personnel. Secondary: defense. Smaller laser turrets used for point defense or to engage enemy aircraft or infantry.'),

  ('kartuhm-terek-doomsday-machine', 7, 'Mini-Missile Launchers (4)',
   'Varies with missile type. Usually plasma (1D6x10 M.D.) missiles are used.', 1, 'About one mile (1.6 km)',
   'One at a time or in volleys of 2, 4, 8 or 12 per launcher',
   '96 total; 24 missiles per launcher', NULL,
   'Primary: defense. Secondary: anti-personnel. Located in strategic positions around the vehicle, used almost exclusively against enemy missiles or sometimes infantry.'),

  ('kartuhm-terek-doomsday-machine', 8, 'Ramming',
   '3D6x10+10 M.D. for every 20 mph (32 km) of speed; if the other vehicle is traveling from the opposite direction, add the two speeds together. Being run down by the vehicle inflicts 2D6x10 M.D.', 1, 'Melee/collision',
   NULL,
   NULL, NULL,
   'The Doomsday Machine is very close to an irresistible force when ramming any land vehicle or building. Robots, power armor and infantrymen in its path are run down unless they dodge (12 or higher).');

-- --- readback ---
-- INSERT OR IGNORE is SILENT on a collision, which is how a row goes missing
-- without an error, so these COUNT. Every want is counted off the VALUES lists
-- in THIS FILE, not read back out of a database that has just loaded it.

SELECT 'this file''s vessels' AS assertion, count(*) AS got, 11 AS want
  FROM vehicles WHERE slug IN ('silverhawk-attack-exoskeleton', 'battleram-attack-robot', 'ground-pounder-pa-10', 'warlord-mark-i', 'warlord-mark-ii', 'kittani-transformable-robot-fighter', 'bombard-infantry-robot', 'phalanx-main-battle-tank', 'maniple-ifv-apc', 'dark-slayer-main-battle-tank', 'kartuhm-terek-doomsday-machine');

SELECT 'all of them cite Phase World' AS assertion, count(*) AS got, 11 AS want
  FROM vehicles WHERE slug IN ('silverhawk-attack-exoskeleton', 'battleram-attack-robot', 'ground-pounder-pa-10', 'warlord-mark-i', 'warlord-mark-ii', 'kittani-transformable-robot-fighter', 'bombard-infantry-robot', 'phalanx-main-battle-tank', 'maniple-ifv-apc', 'dark-slayer-main-battle-tank', 'kartuhm-terek-doomsday-machine') AND source_book LIKE 'Rifts Dimension Book 2: Phase World p.%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 107 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('silverhawk-attack-exoskeleton', 'battleram-attack-robot', 'ground-pounder-pa-10', 'warlord-mark-i', 'warlord-mark-ii', 'kittani-transformable-robot-fighter', 'bombard-infantry-robot', 'phalanx-main-battle-tank', 'maniple-ifv-apc', 'dark-slayer-main-battle-tank', 'kartuhm-terek-doomsday-machine');

SELECT 'their weapon entries' AS assertion, count(*) AS got, 66 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('silverhawk-attack-exoskeleton', 'battleram-attack-robot', 'ground-pounder-pa-10', 'warlord-mark-i', 'warlord-mark-ii', 'kittani-transformable-robot-fighter', 'bombard-infantry-robot', 'phalanx-main-battle-tank', 'maniple-ifv-apc', 'dark-slayer-main-battle-tank', 'kartuhm-terek-doomsday-machine');

SELECT 'locations with no printed figure' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('silverhawk-attack-exoskeleton', 'battleram-attack-robot', 'ground-pounder-pa-10', 'warlord-mark-i', 'warlord-mark-ii', 'kittani-transformable-robot-fighter', 'bombard-infantry-robot', 'phalanx-main-battle-tank', 'maniple-ifv-apc', 'dark-slayer-main-battle-tank', 'kartuhm-terek-doomsday-machine') AND mdc IS NULL;

SELECT 'every vessel carries a main body' AS assertion, count(*) AS got, 11 AS want
  FROM vehicles WHERE slug IN ('silverhawk-attack-exoskeleton', 'battleram-attack-robot', 'ground-pounder-pa-10', 'warlord-mark-i', 'warlord-mark-ii', 'kittani-transformable-robot-fighter', 'bombard-infantry-robot', 'phalanx-main-battle-tank', 'maniple-ifv-apc', 'dark-slayer-main-battle-tank', 'kartuhm-terek-doomsday-machine') AND mdc_main_body IS NOT NULL;

-- Cumulative for the book: the Psionic Power Armor (zzzzzzzz-pw-vessels-p128-130.sql)
-- plus every Phase World vessel file that sorts at or before this one.
SELECT 'Phase World vessels in the catalog' AS assertion, count(*) AS got, 12 AS want
  FROM vehicles WHERE source_book LIKE '%Phase World%';

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Scoped to THIS book; the global version belongs to zzzzzz-vehicle-class-vocabulary.sql.
SELECT 'it carries a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE source_book LIKE '%Phase World%'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-pw-vessels-p130-150.sql');
