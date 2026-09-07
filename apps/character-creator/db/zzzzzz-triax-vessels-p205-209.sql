-- Triax vessels from printed pages 205-209.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-triax-vessels-p205-209.sql
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
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'G-10 Gurgoyle Power Armor / G-11 Gargoyle Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 100 mph (160 km) maximum. Note that the act of running does tire its operator, but at 10% of the usual fatigue rate, thanks to the robot exo-skeleton.', 'Leaping: Assisted by the augmenting armor the character can leap up to 50 feet (15.2 m) high or lengthwise unassisted by the thrusters. A jet thruster assisted leap propels the unit up to 200 feet (61 m) high or lengthwise. Flying: Flight is not possible. Nor are high speed, continuous leaps like the Terrain Hopper.', NULL, 'Height: 10 to 14 feet (3 to 4.3 m) from head to toe (suit worn over the body); Width: 8 to 12 feet (2.4 to 3.6 m); Length: 6 feet (1.8 m)', '1.4 tons', 250, 2000000, 'Rarely available; 2+ million credits.', 'A full environmental power armor suit for gurgoyle warriors (G-10) and giant winged gargoyles 15 feet tall or smaller (G-11, whose wings are left exposed for flight/mobility); giant-sized, with spiked shoulder plates, jet thrusters for power leaps, vibro-claws, a vibro-axe, twin ion blasters and a concealed back mini-missile launcher. Not depicted in the book because it closely resembles the larger G-20 Avenger robot.', 'Rifts World Book 5: Triax and the NGR p.205-207'),
('g-20-avenger-combat-robot', 'G-20 Avenger', 'rifts', 'robot', 'One', NULL, 'Running: 60 mph (96 km) maximum. Note that the act of running does tire its operator.', 'Leaping: The powerful robot legs can leap up to 20 feet (6 m) high or lengthwise unassisted by the thrusters. A jet thruster assisted leap propels the unit up to 100 feet (30.5 m) high and 150 feet (45.7 m) lengthwise. Flying: Flight is not possible. Nor are high speed, continuous leaps like the Terrain Hopper.', NULL, 'Height: 20 feet (6 m) from head to toe; Width: 15 feet (4.6 m); Length: 10 feet (3 m)', '30 tons', 350, 18000000, 'Rarely available; 18+ million credits.', 'A giant combat robot version of the gurgoyle power armor: larger, with stubby mechanical legs, the pilot seated in the chest, and the same basic weapon systems scaled up for greater range and damage. Exclusive to the Gargoyle Empire.', 'Rifts World Book 5: Triax and the NGR p.206-208'),
('g-30-wrecker-combat-robot', 'G-30 Wrecker', 'rifts', 'robot', 'One gurgoyle pilot, a gunner and a gargoylite supervisor.', NULL, 'Running: 50 mph (96 km) maximum. Note that the act of running does tire its operator.', 'Leaping: The powerful robot legs can leap up to 30 feet (9 m) high or 50 feet (15.2 m) lengthwise unassisted by the thrusters. Jet thruster assisted leaps: Propels the unit up to 800 feet (244 m) high or lengthwise; the thrusters can also stop or reduce impact from falls. Flying: Flight is not possible. Nor are high speed, continuous leaps like the Terrain Hopper.', NULL, 'Height: 30 feet (6 m) from head to toe; Width: 15 feet (4.6 m); Length: 10 feet (3 m)', '30 tons', 450, NULL, 'Not available.', 'The Gargoyle Empire largest and more powerful successor to the G-20 Avenger. Resembles a gargoyle with wings (for rear armor protection and slashing, not flight) and large horns; mini-missiles fire from the chest, lasers from the fingers, an ion cannon sits in the belly, and retractable energy-ball-and-chain weapons are mounted in the forearms. Specifically designed to combat the NGR Black Knight, Devastator and other giant robots. Only gurgoyles (sometimes supervised by gargoylites) pilot it; the giant winged gargoyles prefer to fight unarmored.', 'Rifts World Book 5: Triax and the NGR p.208-210');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Shoulders/Upper arm (2)', 100, 'each', 1),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Forearms (2)', 60, 'each; single-asterisk item, small/difficult target', 2),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Claws (2)', 30, 'each; single-asterisk item, small/difficult target', 3),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Legs (2)', 90, 'each', 4),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Ton Blasters (2; side of chest)', 20, 'each; single-asterisk item, small/difficult target; likely OCR misread of Ion Blasters', 5),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Back Mini-Missile Launcher (1)', 30, 'single-asterisk item, small/difficult target', 6),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Maneuvering Jets (4, small)', 15, 'each; single-asterisk item, small/difficult target', 7),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Reinforced Helmet/Head', 100, 'single-asterisk item, small/difficult target; destroying it exposes the gurgoyle head, which as a mega-damage creature can withstand at least 75 points of damage', 8),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 'Main Body', 250, 'double-asterisk; depleting the main body M.D.C. shuts the armor down completely, rendering it useless', 9),
('g-20-avenger-combat-robot', 'Shoulders/Upper arm (2)', 150, 'each', 1),
('g-20-avenger-combat-robot', 'Forearms (2)', 100, 'each; single-asterisk item, small/difficult target; printed as Rorearms, an OCR misread of Forearms', 2),
('g-20-avenger-combat-robot', 'Claws (2)', 40, 'each; single-asterisk item, small/difficult target', 3),
('g-20-avenger-combat-robot', 'Legs (2)', 120, 'each', 4),
('g-20-avenger-combat-robot', 'Back Mini-Missile Launcher (1)', 75, NULL, 5),
('g-20-avenger-combat-robot', 'Ion Blasters (2; side of chest)', 30, 'each; single-asterisk item, small/difficult target; printed as Jon Blasters, an OCR misread of Ion Blasters', 6),
('g-20-avenger-combat-robot', 'Maneuvering Jets (4, small)', 25, 'each; single-asterisk item, small/difficult target', 7),
('g-20-avenger-combat-robot', 'Sensor Head', 75, 'single-asterisk item, small/difficult target', 8),
('g-20-avenger-combat-robot', 'Pilot View Port', 55, 'single-asterisk item, small/difficult target', 9),
('g-20-avenger-combat-robot', 'Main Body', 350, 'double-asterisk; depleting the main body M.D.C. shuts the armor down completely, rendering it useless', 10),
('g-30-wrecker-combat-robot', 'Chest Mini-Missile Launchers (2)', 150, 'each', 1),
('g-30-wrecker-combat-robot', 'Ton Cannon (1; belly)', 90, 'single-asterisk item, small/difficult target; likely OCR misread of Ion Cannon', 2),
('g-30-wrecker-combat-robot', 'Energy Ball and Chain (2)', 110, 'each; single-asterisk item, small/difficult target', 3),
('g-30-wrecker-combat-robot', 'Energy Ball and Chain Line (2)', 50, 'each; single-asterisk item, small/difficult target', 4),
('g-30-wrecker-combat-robot', 'Wings (2)', 120, 'each', 5),
('g-30-wrecker-combat-robot', 'Shoulders/Upper Arms (2)', 200, 'each', 6),
('g-30-wrecker-combat-robot', 'Forearms (2)', 150, 'each; single-asterisk item, small/difficult target', 7),
('g-30-wrecker-combat-robot', 'Claws/hands (2)', 60, 'each; single-asterisk item, small/difficult target', 8),
('g-30-wrecker-combat-robot', 'Legs (2)', 220, 'each', 9),
('g-30-wrecker-combat-robot', 'Jet Thrusters (2; chest)', 120, 'each', 10),
('g-30-wrecker-combat-robot', 'Jet Thrusters (2; lower leg)', 50, 'each; single-asterisk item, small/difficult target', 11),
('g-30-wrecker-combat-robot', 'Reinforced Sensor Head', 135, 'single-asterisk item, small/difficult target', 12),
('g-30-wrecker-combat-robot', 'Main Body', 450, 'double-asterisk; depleting the main body M.D.C. shuts the armor down completely, rendering it useless', 13);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('g-10-g-11-gurgoyle-gargoyle-power-armor', 1, 'Ion Blasters (2)', '3D6 per single blast or 6D6 per simultaneous blasts from both weapons at the same target', 1, '1200 feet (365 m)', 'Equal to the number of hand to hand melee actions of the pilot plus power armor bonuses', 'Effectively unlimited', NULL, 'Twin circular turret blasters in the lower chest, rotate 90 degrees in all directions.'),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 2, 'Concealed Back Mini-Missile Launcher (1)', 'Varies with missile type', 1, 'Usually about a mile', 'One at a time or volleys of two, three or four', '4 total', NULL, 'Standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation seldom used. Primary Purpose: Anti-Aircraft/Anti-Power Armor; Secondary Purpose: Assault.'),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 3, 'Vibro-Claws', '3D6 M.D. per hand strike plus the creature normal damage for supernatural physical strength', 1, 'Hand to hand combat', NULL, NULL, NULL, 'Each hand is equipped with giant-size vibro-claws; the strength bonus is not true of the larger robot vehicles.'),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 4, 'Vibro-Axe', 'Giant Axe Blade: 4D6 M.D., secondary spikes or blades: 2D6 M.D.', 1, 'Hand to hand combat', NULL, NULL, NULL, 'Standard issue handheld weapon; can be substituted with a Kittani plasma weapon or magic weapon.'),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 5, 'Energy Rifles, Light Rail Gun and other weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Can be carried and used.'),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 6, 'Hand to Hand Combat', 'Full Strength Punch - 1D6 M.D.; Power Punch - 2D6 M.D. (counts as two melee attacks); Shoulder Butt with Spikes - 1D6 M.D.; Kick or Knee Jab with Spikes - 2D4 M.D.; Jet Assisted Leap Kick - 2D6 M.D. (counts as two melee attacks); Body Slam/Ram - 1D4 M.D.; Jet Assisted Body Slam/Ram - 1D6 M.D.', 1, 'Hand to hand combat', NULL, NULL, 'One additional melee action/attack at experience levels one, four, and ten; +1 on initiative; +1 to parry and dodge; +3 to roll with impact; +3 to pull punch', 'The gurgoyle is a supernatural creature and already inflicts mega-damage from punches/kicks; listed damage is in addition to that from supernatural strength.'),
('g-10-g-11-gurgoyle-gargoyle-power-armor', 7, 'Sensors & Systems of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Fundamentally, all the basic items as found in human power armor.'),
('g-20-avenger-combat-robot', 1, 'Ion Blasters (2)', '3D6 per single blast or 6D6 per simultaneous blasts from both weapons at the same target', 1, '2000 feet (610 m)', 'Equal to the number of hand to hand melee actions of the pilot plus power armor bonuses', 'Effectively unlimited', NULL, 'Twin circular turret blasters in the lower chest, rotate 90 degrees in all directions.'),
('g-20-avenger-combat-robot', 2, 'Concealed Back Mini-Missile Launcher (1)', 'Varies with missile type', 1, 'Usually about a mile', 'One at a time or volleys of two, three or four', '10 total', NULL, 'Holds ten mini-missiles; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation seldom used. Primary Purpose: Anti-Aircraft/Anti-Power Armor; Secondary Purpose: Assault.'),
('g-20-avenger-combat-robot', 3, 'Vibro-Claws', '3D6 M.D. per hand strike', 1, 'Hand to hand combat', NULL, NULL, NULL, 'Each hand is equipped with giant-size vibro-claws.'),
('g-20-avenger-combat-robot', 4, 'Vibro-Axe', 'Giant Axe Blade: 4D6 M.D., secondary spikes or blades: 2D6 M.D.', 1, 'Hand to hand combat', NULL, NULL, NULL, 'Standard issue handheld weapon; can be substituted with a Kittani plasma weapon or magic weapon.'),
('g-20-avenger-combat-robot', 5, 'Giant-Sized Energy Rifles, Rail Guns and other weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Can be carried and used by the bot, including NGR items.'),
('g-20-avenger-combat-robot', 6, 'Hand to Hand Combat', 'Restrained Punch or Kick - 1D6x10 S.D.C.; Normal Punch - 2D6 M.D.; Power Punch - 4D6 M.D. (counts as two melee attacks); Kick or Knee Jab with Spikes - 2D6 M.D.; Jet Assisted Leap Kick - 3D6+2 M.D. (counts as two melee attacks); Body Slam/Ram - 1D6 M.D.; Jet Assisted Body Slam/Ram - 2D6 M.D.', 1, 'Hand to hand combat', NULL, NULL, 'Two additional attacks per melee round; +1 on initiative; +1 to parry; +2 to roll with impact; +2 to pull punch', 'Inside the robot the pilot must rely on the mechanical strength and abilities of the robot, not his own.'),
('g-20-avenger-combat-robot', 7, 'Sensors & Systems of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Fundamentally, all the basic items as found in human robots, only simpler.'),
('g-30-wrecker-combat-robot', 1, 'Ion Cannon (1)', '6D6 per blast', 1, '3000 feet (915 m)', 'Equal to the number of hand to hand melee actions of the gunner', 'Effectively unlimited', NULL, 'Powerful circular turret ion blaster in the belly of the bot, rotates in a 90 degree arc.'),
('g-30-wrecker-combat-robot', 2, 'Concealed Chest Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'Usually about a mile', 'One at a time or volleys of two, three or four', '48 total; 24 in each chest launcher', NULL, 'Two chest plates flip up to reveal launchers, usually operated by the gunner. Standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10); fragmentation seldom used. Primary Purpose: Anti-Aircraft/Anti-Power Armor; Secondary Purpose: Assault.'),
('g-30-wrecker-combat-robot', 3, 'Laser Fingers (4)', '2D6 per blast or 4D6 per double simultaneous blast', 1, '1200 feet (366 m)', 'Equal to the number of hand to hand melee actions of the gunner', 'Effectively unlimited', NULL, 'Two fingers on each hand conceal medium lasers; point and shoot. No more than two finger lasers can be fired simultaneously at the same target with accuracy unless at point-blank range.'),
('g-30-wrecker-combat-robot', 4, 'Retractable Energy Ball and Chain (2)', '4D6 M.D. per strike', 1, NULL, NULL, NULL, '+2 to strike and parry', 'Ball-shaped energy spheres in the forearms on long extendable and retractable lines, like giant versions of the neural blast whip. Releases a charge that short-circuits the nervous system on a strike (ball or cable); especially effective vs supernatural beings (electrical jolt); kills unarmored humans; may stun unarmored mega-damage creatures; may cause temporary system failure in armored targets. Is an M.D.C. structure and can parry M.D. attacks from robots and power armor. Stun penalties vs mega-damage beings such as demons and dragons: same amount of mega-damage plus double damage to those vulnerable to electricity; victim loses initiative and one melee action per strike and is dazed for the rest of the melee (-2 to strike, parry, dodge). Characters in power armor or environmental body armor suffer damage and there is a 01-40% chance of targeting, radar or communications being knocked out for 1D4 minutes, but the character inside is grounded and insulated and impervious to being dazed. Robot vehicles only suffer mega-damage from the hits. Save vs Being Dazed: same as a save vs non-lethal poison, 16 or higher, rolled each time struck; a successful save means no dazing or penalties.'),
('g-30-wrecker-combat-robot', 5, 'Giant-Sized Energy weapons, electro-mace and others', NULL, 0, NULL, NULL, NULL, NULL, 'Can be carried and used by the bot, including NGR items.'),
('g-30-wrecker-combat-robot', 6, 'Hand to Hand Combat', 'Restrained Punch or Kick - 1D4 M.D.; Normal Punch - 3D6 M.D.; Power Punch - 6D6 M.D. (counts as two melee attacks); Normal Kick - 3D6 M.D.; Jet Assisted Leap Kick - 6D6 M.D. (counts as two melee attacks); Body Slam/Ram - 3D6 M.D.; Jet Assisted Body Slam/Ram - 4D6 M.D.; Body Throw - 2D4 M.D.; Head Butt - 2D6 M.D.', 1, 'Hand to hand combat', NULL, NULL, 'Two additional attacks per melee round; +1 on initiative; +1 to parry; +2 to roll with impact; +2 to pull punch', 'Inside the robot the pilot must rely on the mechanical strength and abilities of the robot, not his own.'),
('g-30-wrecker-combat-robot', 7, 'Sensors & Systems of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Printed as Fundamentally, all the sel items as found in human robots, only simpler - sel appears to be an OCR garble, likely of basic.');

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is silent on collision, so what matters is how many rows are THERE.
SELECT 'vessels from p205-209' AS assertion,
       count(*) AS got, 3 AS want
  FROM vehicles WHERE slug IN ('g-10-g-11-gurgoyle-gargoyle-power-armor', 'g-20-avenger-combat-robot', 'g-30-wrecker-combat-robot');

SELECT 'their M.D.C.-by-location rows' AS assertion,
       count(*) AS got, 32 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('g-10-g-11-gurgoyle-gargoyle-power-armor', 'g-20-avenger-combat-robot', 'g-30-wrecker-combat-robot');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 21 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('g-10-g-11-gurgoyle-gargoyle-power-armor', 'g-20-avenger-combat-robot', 'g-30-wrecker-combat-robot');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-triax-vessels-p205-209.sql');
