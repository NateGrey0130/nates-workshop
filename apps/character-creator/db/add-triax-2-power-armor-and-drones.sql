-- Rifts World Book 31: Triax 2, batch 3: power armor and drones. 11 rows
-- (printed 108-131): the T-25 Uber Super-Exoskeleton, the X-11 Predator II,
-- X-21 War Eagle, X-80 Butterfly, X-700 Fat Boy, X-710 Hell Angel and
-- X-1001 Ulti-Max II, and the DV-39 Wolf, DVO-1, EIR-60 and EIR-70 drones.
-- See apps/character-creator/docs/surveys/triax-2.md.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
-- EVERY NUMBER WAS READ OFF A RENDER and checked against a render again by
-- book-reconcile; no figure disagreed. Every slug was queried against
-- production vehicles and gear before this file was written.
--
-- CONVENTIONS (as the Warlords of Russia vessels):
--   cost is the lowest printed price; the full wording is in cost_note. "Not
--     available" is NULL with the wording kept.
--   Locations and weapons are in printed order; a small target carries
--     "called shot only" in its mdc_note. Hand to hand tables and sensor
--     notes are in the description.
--   A book slip (a bad metric conversion, a location printed twice, a
--     missile mix that does not add up) is stored as printed and named in
--     the row.
--   The EIR-60 and EIR-70 are S.D.C. machines (is_mega_damage = 0).
--   The Fat Boy's table prints Hands (2) twice (100 and 120 each); the second
--     is stored as 'Hands (2), second line'.
--   NOT HERE: the Jaeger shoulder modules (printed 125-126), unpriced and for
--     the held x-535-hunter-jager.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-triax-2-power-armor-and-drones.sql

INSERT OR IGNORE INTO vehicles (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air, speed_water, dimensions, weight_tons, mdc_main_body, is_mega_damage, ar, cost, cost_note, description, source_book) VALUES
('t-25-uber-super-exoskeleton-armor', 'T-25 "Uber" Super-Exoskeleton Armor', 'rifts', 'power-armor', 'One (the wearer)', NULL, NULL, NULL, NULL, '7 to 7.5 feet (2.1 to 2.3 m) tall; varies with the wearer', '50 pounds (22.5 kg)', 200, 1, NULL, 750000, '750,000 credits; often twice that on the Black Market, where it is rarely available.', 'A full environmental heavy exoskeleton that sits on the line between body armor and power armor, issued to NGR heavy weapons specialists, commandos, front line assault troops and units sent against Gargoyle roosts; never to work details. Its augmentation gives a Robot P.S. of 20 (2D6 S.D.C. restrained punch, 1 M.D. full punch, 1D6 M.D. power punch that costs two attacks), halves fatigue and allows 18 foot (5.5 m) leaps. Bonuses: +1 attack per melee, +1 initiative, +1 parry and dodge, +1 disarm, +3 pull punch and roll with impact. Mobility is fair to good: -12% to Prowl, Swim, Acrobatics and similar physical skills. Has all standard NGR Cyclops sensors and features, and lets an ordinary soldier carry the TX-50 Rail Gun (standard issue) and other weapons normally restricted to cyborgs and power armor; any energy pistol may be carried as a side arm, and TX-H weapons can be used.', 'Rifts World Book 31: Triax 2 p.108'),
('x-11-predator-ii-power-armor', 'X-11 Predator II Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 60 mph (96 km); leaps 20 feet (6.1 m), +15 feet (4.6 m) running, ten-fold with thruster boost', '300 mph (480 km) maximum, 150 mph (240 km) cruising; can hover; ceiling 20,000 feet (6,096 m)', '30 mph (48 km or 26 knots); walks the bottom at 25% of running speed; maximum depth one mile (1.6 km)', 'Height 11 feet (3.35 m) intakes to toes; width 5 feet (1.5 m) wings down; length 4 feet 10 inches (1.45 m); wingspan 19 feet (5.8 m)', '1,600 pounds (720 kg)', 480, 1, NULL, 4900000, 'Black Market 4.9 million credits, uncommon there; NGR Army only, not sold on the open market.', 'Triax''s flying successor to the long-serving X-10A Predator, built as a low altitude ''flying tank'' to fight Gargoyles and other airborne foes. Its wings now mount behind the shoulders, and like the Super SAMAS the whole flight pack can be jettisoned so a downed pilot stays mobile. Robot P.S. 30, nuclear power with a 20 year life. Destroying the head leaves the pilot with only his own senses; depleting the main body shuts the suit down. Hand to hand uses Flying Power Armor Training (Rifts Ultimate Edition p.352). Sensors add telescopic, passive nightvision and polarizing lenses to standard NGR power armor features. The original X-10A remains in service but is being sold abroad at two-thirds its old price.', 'Rifts World Book 31: Triax 2 p.110-112'),
('x-21-war-eagle-power-armor', 'X-21 War Eagle Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 50 mph (80 km); leaps 20 feet (6.1 m) standing, 40 feet (12.2 m) high or 55 feet (16.7 m) running, ten-fold with thruster boost', '100 mph (160 km) maximum, 50 mph (80 km) cruising; silent gliding at cruising speed or less; power dive doubles speed; ceiling 6,000 feet (1,828 m)', '20 mph (32 km or 17 knots); walks the bottom at 25% of running speed; maximum depth 800 feet (244 m)', 'Height 9 feet (2.7 m); width 4 feet (1.2 m) shoulder to shoulder; length 3 feet 4 inches (1 m); wingspan 14 feet (4.3 m)', '800 pounds (360 kg)', 280, 1, NULL, 4500000, 'Black Market 4.5 million credits, uncommon there; NGR Army only, unknown to most outsiders.', 'A light, quiet, low altitude flyer that flies prone with feathered polymer wings attached to its arms, built to glide silently onto Gargoyle roosts and enemy positions. Used for covert operations, scouting, forward observation, commando raids and demolition strikes; popular with Military Specialists and Commandos. Robot P.S. 25. Called shots on its small targets are -4. Losing most feathers of one wing halves flying speed, prevents dive attacks and gives -30% to flying; losing both wings grounds it. It has no missiles, and an energy rifle is awkward to carry (-10% Piloting). Hand to hand per Flying Power Armor Training (Rifts Ultimate Edition p.352). Sensors: telescopic optics, passive nightvision, polarization, two chest searchlights (1,200 feet/366 m, 30 degree arc) and two smaller leg searchlights.', 'Rifts World Book 31: Triax 2 p.113-115'),
('x-80-butterfly-power-armor', 'X-80 Butterfly Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 40 mph (64 km) with the missile pack, 70 mph (112 km) without; leaps 12 feet (3.6 m) with the pack, +10 feet (3 m) running, 200 feet (61 m) with jump jets', 'Not possible', 'Walks the bottom at half running speed; maximum depth one mile (1.6 km)', 'Height 14 feet (4.3 m) with missile launcher, 10 feet (3 m) armor alone; width 6 feet (1.8 m) with launcher, 4 feet (1.2 m) without; length 7 feet (2.1 m)', '3 tons with missile pack, 1.8 tons without', 400, 1, NULL, 3400000, 'Black Market 3.4 million credits, missiles extra; uncommon there; NGR Army only.', 'A heavily armored walking artillery unit, little bigger than a Predator, built to bombard Gargoyle roosts, nests and hatcheries on siege missions. Despite the name it cannot fly: the ''butterfly'' is a folding, jettisonable missile launch pack with jump jets and a back thruster that boost climbing, give 200 foot leaps and slow falls to 10% damage. Robot P.S. 32, nuclear power with a 20 year life. Hand to hand per Ground-Based Power Armor Training (Rifts Ultimate Edition p.352). Sensors add telescopic, passive nightvision and polarizing lenses to standard NGR power armor features.', 'Rifts World Book 31: Triax 2 p.115-117'),
('x-700-fat-boy-glitter-boy', 'X-700 "Fat Boy" Glitter Boy', 'rifts', 'power-armor', 'One', NULL, 'Running: 40 mph (64 km); leaps six feet (1.8 m)', 'Not possible', 'Cannot swim; walks the bottom at 15 mph (24 km or 13 knots); maximum depth 1 mile (1.6 km)', 'Height 11 feet (3.3 m); width 7 feet (2.1 m); length 6.5 feet (2 m)', '4.2 tons; another half ton fully loaded with missiles and Boom Gun payloads', 980, 1, NULL, 65000000, 'Black Market 65+ million credits, super-rare; NGR Army only, apart from Free Quebec, where it has not yet been revealed.', 'An egg-shaped, laser chromium Glitter Boy built around an exclusive dual coaxial Boom Gun, with thick legs and feet and stabilization rods to absorb the recoil of firing both barrels. Takes half damage from lasers. Robot P.S. 38; a self-destruct turns the suit to slag for 1D6x10 M.D. within 5 feet (the book prints the metric figure as 15 m). The location table prints Hands (2) twice, at 100 and at 120 each; both are kept as printed. Called shots on the low profile head are -4. Hand to Hand Combat Elite: +1 attack (and +1 at levels 4, 8 and 12), +2 initiative, +2 strike with the Boom Gun and rail guns, +1 strike and parry, no dodge bonus, +2 pull punch and roll; punch 1D4 M.D. restrained or 2D6 full, power punch 4D4 (two attacks), no kicks or stomps, tear/pry 2D6, body block 2D6, full speed ram 3D6 (three actions), pylon impalement 1D6. Boom Gun blasts deafen unprotected people within 200 feet (61 m) for 2D4 minutes (-8 initiative, -3 parry and dodge) and shake buildings within 300 feet (91.5 m), doubled when both barrels fire.', 'Rifts World Book 31: Triax 2 p.117-119'),
('x-710-hell-angel-glitter-boy', 'X-710 "Hell Angel" Glitter Boy Unit', 'rifts', 'power-armor', 'One', NULL, 'Running: 60 mph (96 km); leaps 15 feet (4.6 m), +10 feet (3 m) running, ten-fold with thruster boost', '260 mph (416 km) maximum, 100 mph (160 km) cruising', '15 mph (24 km or 13 knots); walks the bottom at 25% of running speed; maximum depth one mile (1.6 km)', 'Height 10 feet (3 m); width 5 feet 6 inches (1.7 m) at the shoulders; length 5 feet (1.5 m) with back thrusters and ammo drum; wingspan 22 feet (6.7 m)', '1.5 tons', 600, 1, NULL, 90000000, 'Black Market 90+ million credits, super-rare; NGR Army only (Free Quebec does not have it either).', 'The first flying Glitter Boy: laser resistant armor (half damage from lasers) and the TX-550 Boom Gun on an upright flying suit that borrows from the X-21 and X-10A. It must slow below 50 mph (80 km) or hover a few feet up to fire the Boom Gun while its thrusters and wings hold it steady; it has no feet pylons and cannot fire it standing on solid ground. Without stabilization each blast would knock it back 1D6x100 yards with a 01-50% chance of tumbling. P.S. 30; self-destruct does 1D6x10 M.D. within 5 feet (the book prints the metric figure as 15 m). Hand to Hand Combat Elite (Glitter Boy): +2 attacks (+1 at levels 3, 7, 11), +2 initiative, +2 strike with Boom Gun and rail guns, +2 strike, +2 parry, +3 dodge hovering, +5 dodge leaping or flying, +1 disarm, +4 pull punch, +3 roll; punch 1D4/1D6 M.D., power punch 2D6 (two attacks), kick 2D4 (no power kick), running leap kick 4D6 (three attacks), tear/pry 1D6, body block 2D4, full speed ram 3D6 (three actions), stomp 1D6 vs. objects under 3 feet. Has standard NGR power armor sensors plus telescopic optics, passive nightvision and polarization.', 'Rifts World Book 31: Triax 2 p.121-123'),
('x-1001-ulti-max-ii-power-armor', 'X-1001 Ulti-Max II Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running: 50 mph (80 km), does not tire the pilot; leaps 15 feet (4.6 m) standing, 20 feet (6.1 m) running, 40 feet (12.2 m) rocket assisted', 'Not possible', '15 mph (24 km or 13 knots); walks the bottom at 20% of running speed', 'Height 16 feet (4.9 m); width 9 feet (2.7 m); length 7 feet (2.1 m)', '4.5 tons', 450, 1, NULL, 30000000, 'Black Market 30+ million credits, super-rare; NGR Army only.', 'The ''Uma II'' replaces the original X-1000 with a more humanoid, mobile body that blends the Ulti-Max, X-10 Predator and X-2000 Dyna-Max: rocket assisted leaps, mountain climbing, kicks, more mini-missiles and a big Vibro-Blade. The pilot sits in a compartment and works pedals and controls rather than wearing it, so many treat it as a small manned robot. Robot P.S. 40. Its force field (150 M.D.C.) takes damage first, regenerates fully in six hours, and shuts down if the main body loses more than two thirds of its M.D.C. Hand to hand per Light Ground Robot Training (Rifts Ultimate Edition p.352), except kick 3D8 M.D. and leap kick 5D8 M.D. Cargo bin holds a rifle, pistol, light body armor, canteen and four weeks of rations, plus a two gallon water cooler. Its sensor note is printed as the X-710 Hell Angel''s (a book slip): standard NGR features plus telescopic optics, passive nightvision and polarization. Can use any power-armor or robot rail gun or oversized weapon.', 'Rifts World Book 31: Triax 2 p.123-125'),
('dv-39-wolf-pack-robot-drone', 'DV-39 Wolf Pack Robot Drone', 'rifts', 'drone', 'None, robot drone', NULL, 'Running: 120 mph (192 km); leaps 20 feet (6.1 m) high or 30 feet (9.1 m) long, +50% at a running start of 60 mph (96 km) or more', 'Not possible', 'Swims across the surface at 20% of running speed', 'Height 3 feet 6 inches (1 m); width 2 feet (0.6 m); length 5 feet 6 inches (1.7 m)', '350 pounds (157.5 kg)', 200, 1, NULL, 1200000, 'Black Market 1.2 million credits, rarely available; NGR Army only, not sold on the open market.', 'An A.I. robot shaped like a big mechanical wolf, programmed for scouting, tracking, navigation and melee, that speaks to its soldiers and relays video and sensor data. Works alone, in pairs or packs, and up to four can be linked to and directly controlled by an X-1471 Wolfhound robot. Robot P.S. 30, I.Q. 14, P.P. 18, P.B. 10, six attacks per melee. Sensors: advanced optics to 4,000 feet with two mile telescopic vision, 500 foot motion detector, molecular analyzer and foot vibration detectors (70%); programs cover demolitions disposal, languages, reconnaissance, tracking and wilderness skills at fixed percentages. Hand to hand: bite 2D4 M.D., power bite 4D4, head butt 1D4, paw strike 1D6, pounce 1D4 with a 01-90% knockdown; critical on a Natural 19-20. Bonuses: +4 initiative, +2 strike ranged, +4 strike melee, +6 dodge, +5 disarm, +3 pin, +4 roll, +6 pull punch. Back mount options D (video array, 500 mile/800 km link) and E (sensor array) carry no weapon.', 'Rifts World Book 31: Triax 2 p.126-128'),
('dvo-1-aerial-spy-drone', 'DVO-1 Aerial Spy Drone', 'rifts', 'drone', 'None, robot drone', NULL, 'Running: not possible; leaping: not possible', '250 mph (400 km) to an altitude of 35,000 feet (10,668 m)', NULL, 'Height 3 feet (0.9 m) to the top of the tail fin; width 5 feet (1.5 m) wingtip to wingtip; length 5 feet (1.5 m)', '200 pounds (90 kg)', 80, 1, NULL, 600000, 'Black Market 600,000 credits; NGR Army only, no other source.', 'The NGR''s first unmanned aerial observation drone, small enough for two soldiers or a pickup bed to carry, flown high over enemy ground to photograph, film and scan troops, camps and Gargoyle nests and relay it live to its base. Five actions per round; no weapon systems. Its spy cameras store 48 hours of video, several drones can build 3-D terrain maps (one per 5 square miles/13 sq. km), and it carries 1,000 mile laser communications, 200 mile radar tracking 120 targets, and a two mile laser target designator worth +5 to strike for guided missiles. It can also jam radio and radar within 10 miles (16 km) while circling (-40% to counter). Destroying both sensor arrays sends it home blind.', 'Rifts World Book 31: Triax 2 p.128-129'),
('eir-60-extermination-robot', 'EIR-60 Extermination Robot', 'rifts', 'drone', 'None, artificial intelligence', NULL, 'Running: 10 mph (16 km), never tires; climbs well but not sheer walls or ceilings; leaps six inches (15 cm)', 'Not possible', NULL, 'Body two inches (5 cm) in diameter; six inches (15 cm) wide including legs', '1.4 pounds (0.6 kg)', 10, 0, NULL, 3000, 'Not available; NGR Army only, unknown to the Black Market. Estimated value 3,000 credits each.', 'Nicknamed the ''Egg Popper'' or ''Surprise Package'': a golf ball sized, six-legged S.D.C. demolitions robot released by the hundreds or thousands 1-4 miles from a Gargoyle aviary. Its simple A.I. finds a nest, picks an egg, nestles against it and waits; when most are in place they detonate together, each charge just enough to pierce one egg. Disposable and atomized in the blast; depleting its S.D.C. destroys it with a 01-30% chance of it exploding. P.S. 6, battery good for 96 hours. Insect- and mouse-shaped variants were tried but dropped; it is now usually sent in a few dozen at a time.', 'Rifts World Book 31: Triax 2 p.129-130'),
('eir-70-robot-spy-drone', 'EIR-70 Robot Spy Drone', 'rifts', 'drone', 'None, robot with an artificial intelligence (A.I.)', NULL, 'Running: 15 mph (24 km); leaps one foot (0.3 m)', 'Not possible', 'Swims across the surface at 30% of running speed', 'Mouse body: height 2 inches (5 cm), width 2 inches (5 cm), length 4 inches (10 cm) plus 8 inch (20 cm) tail; beetles about equal, smaller insects about half', '1.6 pounds (0.7 kg)', 8, 0, NULL, 3000, 'Not available; NGR Army only, unknown to the Black Market. Estimated value 3,000 credits each.', 'Tiny disposable S.D.C. spy robots built to look and act like mice, beetles and other vermin, used to watch Gargoyles and now criminals, spies, D-Bees and even NGR workers. They store about 72 hours of film and 1,000 stills but usually stream to their handlers over a 50 mile (80 km) encrypted radio, and will destroy themselves to avoid capture. Human-equivalent P.S. 10, I.Q. 14, P.P. 18, P.B. 7, six attacks per melee, five month battery. The main body is -5 to strike even on a Called Shot; the head, legs and tail can only be hit once the ''Bot is immobilized or held. Sensors include optics to 4,000 feet with two mile zoom, a 100 foot motion detector and audio pickup to 500 feet; programs cover languages, reconnaissance, tailing and tracking at fixed percentages. No weapon systems. Main Body S.D.C. is printed as 8-12 depending on size; mdc_main_body holds the low figure.', 'Rifts World Book 31: Triax 2 p.130-131');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
  ('t-25-uber-super-exoskeleton-armor', '* Head/Helmet', 90, NULL, 1),
  ('t-25-uber-super-exoskeleton-armor', 'Arms', 80, 'each', 2),
  ('t-25-uber-super-exoskeleton-armor', 'Legs', 90, 'each', 3),
  ('t-25-uber-super-exoskeleton-armor', 'Main Body', 200, NULL, 4),
  ('x-11-predator-ii-power-armor', 'Wings (2)', 140, 'each', 1),
  ('x-11-predator-ii-power-armor', '* Head', 100, NULL, 2),
  ('x-11-predator-ii-power-armor', 'Main Rear Jets (3)', 100, 'each', 3),
  ('x-11-predator-ii-power-armor', 'Maneuvering Jets (3)', 75, NULL, 4),
  ('x-11-predator-ii-power-armor', 'Air Intakes (2, above shoulders)', 65, 'each', 5),
  ('x-11-predator-ii-power-armor', 'Hands (2)', 35, 'each', 6),
  ('x-11-predator-ii-power-armor', 'Arms (2)', 100, 'each', 7),
  ('x-11-predator-ii-power-armor', 'Legs (2)', 150, 'each', 8),
  ('x-11-predator-ii-power-armor', 'Feet (2)', 80, 'each', 9),
  ('x-11-predator-ii-power-armor', 'Chest Searchlight (1)', 5, NULL, 10),
  ('x-11-predator-ii-power-armor', '* Forearm Pulse Lasers (2)', 12, 'each', 11),
  ('x-11-predator-ii-power-armor', '* Vibro-Blades (2)', 40, 'each', 12),
  ('x-11-predator-ii-power-armor', '** Main Body', 480, NULL, 13),
  ('x-21-war-eagle-power-armor', '* Head', 90, NULL, 1),
  ('x-21-war-eagle-power-armor', 'Arms (2)', 100, 'each', 2),
  ('x-21-war-eagle-power-armor', '* Forearm Weapon Housings (2)', 50, 'each', 3),
  ('x-21-war-eagle-power-armor', 'Forearm Vibro-Swords (2)', 50, 'each', 4),
  ('x-21-war-eagle-power-armor', '* Shoulder Lasers (2)', 50, 'each', 5),
  ('x-21-war-eagle-power-armor', '* Chest Searchlights (2)', 5, 'each', 6),
  ('x-21-war-eagle-power-armor', '* Leg Searchlights (2)', 2, 'each', 7),
  ('x-21-war-eagle-power-armor', 'Legs (2)', 110, 'each', 8),
  ('x-21-war-eagle-power-armor', 'Clawed Feet (2)', 75, 'each', 9),
  ('x-21-war-eagle-power-armor', 'Wings (2)', 90, 'each', 10),
  ('x-21-war-eagle-power-armor', '** Main Body', 280, NULL, 11),
  ('x-80-butterfly-power-armor', 'Butterfly Missile Launchers (2)', 220, 'each', 1),
  ('x-80-butterfly-power-armor', '* Mini-Missile Launcher Pods (2, lower legs)', 35, 'each', 2),
  ('x-80-butterfly-power-armor', '* Head', 120, NULL, 3),
  ('x-80-butterfly-power-armor', '* Jump Jets (2, behind)', 100, 'each', 4),
  ('x-80-butterfly-power-armor', '* Back Thruster (1)', 55, NULL, 5),
  ('x-80-butterfly-power-armor', '* Small Stabilization Thrusters (10, concealed)', 6, 'each', 6),
  ('x-80-butterfly-power-armor', '* Hands (2)', 25, 'each', 7),
  ('x-80-butterfly-power-armor', 'Arms (2)', 100, 'each', 8),
  ('x-80-butterfly-power-armor', 'Legs (2)', 160, 'each', 9),
  ('x-80-butterfly-power-armor', 'Feet (2)', 100, 'each', 10),
  ('x-80-butterfly-power-armor', '* Forearm Pulse Lasers (2)', 12, 'each', 11),
  ('x-80-butterfly-power-armor', '* Vibro-Blades (2)', 40, 'each', 12),
  ('x-80-butterfly-power-armor', '** Main Body', 400, NULL, 13),
  ('x-700-fat-boy-glitter-boy', 'Boom Gun (1, right shoulder)', 220, NULL, 1),
  ('x-700-fat-boy-glitter-boy', 'Arms (2)', 300, 'each', 2),
  ('x-700-fat-boy-glitter-boy', '* Shoulder Mini-Missile Launchers (2)', 130, 'each', 3),
  ('x-700-fat-boy-glitter-boy', 'Hands (2)', 100, 'each', 4),
  ('x-700-fat-boy-glitter-boy', '* Pop-Up Forearm Ion Blaster (1, right arm)', 35, NULL, 5),
  ('x-700-fat-boy-glitter-boy', '* Pop-Up Forearm Laser (1, left arm)', 40, NULL, 6),
  ('x-700-fat-boy-glitter-boy', 'Hands (2), second line', 120, 'each; printed a second time The table prints Hands (2) twice, at 100 each and at 120 each; both are kept in printed order.', 7),
  ('x-700-fat-boy-glitter-boy', '* Head (low profile)', 260, NULL, 8),
  ('x-700-fat-boy-glitter-boy', 'Legs (2)', 520, 'each', 9),
  ('x-700-fat-boy-glitter-boy', 'Feet (2)', 280, 'each', 10),
  ('x-700-fat-boy-glitter-boy', '** Main Body', 980, NULL, 11),
  ('x-710-hell-angel-glitter-boy', '* Head', 190, NULL, 1),
  ('x-710-hell-angel-glitter-boy', '* Hands (2)', 75, 'each', 2),
  ('x-710-hell-angel-glitter-boy', 'Arms (2)', 200, NULL, 3),
  ('x-710-hell-angel-glitter-boy', '* Forearm Weapons (2, low profile)', 30, 'each', 4),
  ('x-710-hell-angel-glitter-boy', 'Shoulder Mounted Boom Gun', 100, NULL, 5),
  ('x-710-hell-angel-glitter-boy', 'Legs (2)', 320, 'each', 6),
  ('x-710-hell-angel-glitter-boy', '* Feet (2, each contains thrusters)', 100, 'each', 7),
  ('x-710-hell-angel-glitter-boy', 'Wings (2)', 200, 'each', 8),
  ('x-710-hell-angel-glitter-boy', '** Main Body', 600, NULL, 9),
  ('x-1001-ulti-max-ii-power-armor', 'Forearms (2)', 150, 'each', 1),
  ('x-1001-ulti-max-ii-power-armor', 'Upper Arms (2)', 135, 'each', 2),
  ('x-1001-ulti-max-ii-power-armor', 'Shoulders (2, mini-missile launchers)', 170, 'each', 3),
  ('x-1001-ulti-max-ii-power-armor', 'Legs (2)', 240, 'each', 4),
  ('x-1001-ulti-max-ii-power-armor', 'Rear Exhaust Tubes (3)', 50, 'each', 5),
  ('x-1001-ulti-max-ii-power-armor', '* Main Rear Booster Jet (1)', 30, NULL, 6),
  ('x-1001-ulti-max-ii-power-armor', '* Rear Directional Jets (2)', 60, 'each', 7),
  ('x-1001-ulti-max-ii-power-armor', 'Forearm Vibro-Swords (2, forearms)', 50, 'each', 8),
  ('x-1001-ulti-max-ii-power-armor', 'Mini-Missile Launchers (2, chest)', 150, 'each', 9),
  ('x-1001-ulti-max-ii-power-armor', 'Leg Mini-Missile Launchers (2, lower legs)', 60, 'each', 10),
  ('x-1001-ulti-max-ii-power-armor', '* Shoulder Spotlights (2)', 15, 'each', 11),
  ('x-1001-ulti-max-ii-power-armor', '* Head Sensors (1; top)', 100, NULL, 12),
  ('x-1001-ulti-max-ii-power-armor', 'Reinforced Pilot Compartment', 80, NULL, 13),
  ('x-1001-ulti-max-ii-power-armor', '** Main Body', 450, NULL, 14),
  ('x-1001-ulti-max-ii-power-armor', '*** Force Field', 150, NULL, 15),
  ('dv-39-wolf-pack-robot-drone', '* Head', 90, NULL, 1),
  ('dv-39-wolf-pack-robot-drone', '* Back Mounted System', 60, NULL, 2),
  ('dv-39-wolf-pack-robot-drone', 'Vibro-Claws (4)', 50, 'each', 3),
  ('dv-39-wolf-pack-robot-drone', 'Legs (4)', 95, 'each', 4),
  ('dv-39-wolf-pack-robot-drone', '** Main Body', 200, NULL, 5),
  ('dvo-1-aerial-spy-drone', '* Sensor Array', 30, NULL, 1),
  ('dvo-1-aerial-spy-drone', '* Secondary Sensor Array', 30, NULL, 2),
  ('dvo-1-aerial-spy-drone', '* Jet Engine', 30, NULL, 3),
  ('dvo-1-aerial-spy-drone', '* Stabilizer Thrusters (6)', 5, 'each', 4),
  ('dvo-1-aerial-spy-drone', '* Laser Turret', 20, NULL, 5),
  ('dvo-1-aerial-spy-drone', '** Main Body', 80, NULL, 6),
  ('eir-60-extermination-robot', 'Legs (6)', 5, 'each', 1),
  ('eir-60-extermination-robot', 'Sensor Eyes (4)', 2, 'each', 2),
  ('eir-60-extermination-robot', '*Main Body', 10, NULL, 3),
  ('eir-70-robot-spy-drone', 'Head', 8, NULL, 1),
  ('eir-70-robot-spy-drone', 'Legs (4-6)', 3, 'each', 2),
  ('eir-70-robot-spy-drone', '* Main Body', NULL, '8-12 depending on the size of the ''Bot', 3);

INSERT OR IGNORE INTO vehicle_weapons (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note) VALUES
  ('t-25-uber-super-exoskeleton-armor', 1, 'TX-50 Rail Gun', NULL, 1, NULL, NULL, NULL, NULL, 'Standard issue; see Rifts World Book Five p.146 for stats. The suit''s P.S. lets the wearer handle it.'),
  ('t-25-uber-super-exoskeleton-armor', 2, 'Energy Pistol Side Arm', NULL, 1, NULL, NULL, NULL, NULL, 'Any old or new energy pistol.'),
  ('t-25-uber-super-exoskeleton-armor', 3, 'TX-H Series', NULL, 1, NULL, NULL, NULL, NULL, 'Any TX-H series hand to hand weapon can be used.'),
  ('x-11-predator-ii-power-armor', 1, 'X-11 453E Pulse Lasers (2)', '2D6 M.D. single shot, 1D6x10 M.D. quadruple pulse blast, 2D6x10 M.D. both arms at one target', 1, '4,000 feet (1,219 m)', 'Each single shot or pulse blast at one target counts as one melee attack; at different targets each blast is a separate attack', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Forearm-mounted.'),
  ('x-11-predator-ii-power-armor', 2, 'TX-252 Rail Gun (1, handheld)', '1D6x10 M.D. per 30 round burst', 1, '4,600 feet (1,402 m)', 'Each burst counts as one melee attack', '3,000 round drum, 100 full bursts', NULL, 'Gun weighs 225 lbs (101 kg); each ammo drum another 250 lbs (112.5 kg), hung at the hip or waist under the back jets. Other power-armor-sized handheld weapons may be substituted.'),
  ('x-11-predator-ii-power-armor', 3, 'Wing Missile Launchers (Optional)', 'Varies with missile type; armor piercing mini-missiles 1D4x10 M.D. or fragmentation 5D6 M.D. to a 20 foot (6.1 m) radius favored', 1, 'Varies with missile type', 'One at a time or in volleys of 2, 4 or 6', 'Six short- or medium-range missiles or 18 mini-missiles, divided evenly between the wings', NULL, 'Three hard points per wing: three short/medium-range missiles or three mini-missile clusters of three per wing.'),
  ('x-11-predator-ii-power-armor', 4, 'Forearm Vibro-Blades (2)', '3D6 M.D.', 1, NULL, NULL, NULL, NULL, 'Concealed, extendible and retractable.'),
  ('x-11-predator-ii-power-armor', 5, 'TX-H Series', NULL, 1, NULL, NULL, NULL, NULL, 'Any TX-H series hand to hand weapon can be used.'),
  ('x-21-war-eagle-power-armor', 1, 'X-11 453E Pulse Lasers (2)', '2D6 M.D. single shot, 1D6x10 M.D. quadruple pulse blast, 2D6x10 M.D. both fired together', 1, '4,000 feet (1,219 m)', 'Each single shot, pulse or dual pulse blast at one target counts as one melee attack', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Shoulder-mounted behind sliding panels; tilts up and down through a 40 degree arc.'),
  ('x-21-war-eagle-power-armor', 2, 'Forearm Laser Blaster (2)', '3D6 M.D. single blast, 6D6 M.D. both arms at one target', 1, '3,000 feet (914 m)', 'Each single or double shot at one target counts as one melee attack; at different targets each is a separate attack', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'For aimed attacks; may not be usable in flight.'),
  ('x-21-war-eagle-power-armor', 3, 'Forearm Vibro-Blades (2)', '3D6 M.D. each', 1, NULL, NULL, NULL, NULL, NULL),
  ('x-21-war-eagle-power-armor', 4, 'Clawed Feet (2)', '5D6 M.D. per foot/kick strike', 1, NULL, NULL, NULL, NULL, 'Padded talons usable as Vibro-Claws; also aid climbing.'),
  ('x-21-war-eagle-power-armor', 5, 'Side Arms (1 or 2; Optional)', NULL, 1, NULL, NULL, NULL, NULL, 'One or two pistols strapped to the waist or legs.'),
  ('x-21-war-eagle-power-armor', 6, 'TX-H Series', NULL, 1, NULL, NULL, NULL, NULL, 'Any TX-H series hand to hand weapon can be used.'),
  ('x-80-butterfly-power-armor', 1, 'Butterfly Missile Launch Pack', 'Varies with missile type; high explosive 2D6x10 M.D. to 15 ft (4.6 m) or fragmentation 2D6x10 M.D. to 20 ft (6.1 m) radius favored', 1, 'Varies with missile type, typically 500 miles (800 km)', 'One at a time or in volleys of 2, 4, 7 or 14', '28 short-range missiles: 14 loaded, plus a reload of seven in each wing', NULL, 'Fires short-range missiles; the wings fold open and close at 45 degrees.'),
  ('x-80-butterfly-power-armor', 2, 'Mini-Missile Leg Launchers (2)', 'Varies with missile type; fragmentation 5D6 M.D. to a 20 foot (6.1 m) radius favored', 1, 'One mile (1.6 km)', 'One at a time or in volleys of 2, 4, 6 or 8', '8 total mini-missiles', NULL, NULL),
  ('x-80-butterfly-power-armor', 3, 'X-11 453E Pulse Lasers (2)', '2D6 M.D. single shot, 1D6x10 M.D. quadruple pulse blast, 2D6x10 M.D. both arms at one target', 1, '4,000 feet (1,219 m)', 'Each single shot or pulse blast at one target counts as one melee attack; at different targets each blast is a separate attack', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Forearm-mounted.'),
  ('x-80-butterfly-power-armor', 4, 'Forearm Vibro-Blades (2)', '3D6 M.D.', 1, NULL, NULL, NULL, NULL, 'Concealed, extendible and retractable.'),
  ('x-80-butterfly-power-armor', 5, 'TX-252 Rail Gun (1, handheld)', '1D6x10 M.D. per 30 round burst', 1, '4,600 feet (1,402 m)', 'Each burst counts as one melee attack', '3,000 round drum, 100 full bursts', NULL, 'Gun weighs 225 lbs (101 kg); each ammo drum another 250 lbs (112.5 kg), hung at the hip or waist under the back jets. Other power-armor-sized handheld weapons may be substituted.'),
  ('x-80-butterfly-power-armor', 6, 'TX-H Series', NULL, 1, NULL, NULL, NULL, NULL, 'Any TX-H series hand to hand weapon can be used.'),
  ('x-700-fat-boy-glitter-boy', 1, 'Dual Coaxial Boom Gun (1)', '3D6x10 M.D. single shot or 6D6x10 M.D. double shot', 1, '11,000 feet (roughly two miles/3.2 km)', 'Each single or double blast counts as one melee attack', '800 rounds (400 double shots); 200 in the gun, the rest fed from inside the body', NULL, 'Can fire independently on computer targeting at five attacks per melee (no Called Shots, main body only).'),
  ('x-700-fat-boy-glitter-boy', 2, 'Shoulder Mounted Mini-Missile Launcher (2)', 'Varies with mini-missile type; standard armor piercing 1D4x10 M.D. per missile', 1, 'Usually one mile (1.6 km)', 'One at a time or in volleys of 2, 4, 6 or 8', '40 total mini-missiles, 20 in each shoulder', NULL, NULL),
  ('x-700-fat-boy-glitter-boy', 3, 'Pop-Up Forearm Ion Blaster (1, right arm)', '4D6 M.D.', 1, '800 feet (244 m)', 'Each blast counts as one melee attack', 'Effectively unlimited; tied to the power supply', NULL, NULL),
  ('x-700-fat-boy-glitter-boy', 4, 'Pop-Up Forearm Laser (1, left arm)', '3D6 M.D.', 1, '2,000 feet (610 m)', 'Each blast counts as one melee attack', 'Effectively unlimited; tied to the power supply', NULL, NULL),
  ('x-710-hell-angel-glitter-boy', 1, 'TX-550 Boom Gun/Rail Gun (1)', '3D6x10 M.D. per flechette round (200 slugs)', 1, '11,000 feet (roughly two miles/3.2 km)', 'Each Boom Gun blast counts as one melee attack', '100 rounds; reloadable by hand one round at a time (about 15 minutes) or by drum swap (about 3 minutes)', NULL, 'Mach 4.5 rounds with sonic boom (standard, as the X-700). Gun weighs 700 lbs (315 kg), built in; 90 degree vertical arc, cannot traverse sideways. Computer tracking can fire it automatically.'),
  ('x-710-hell-angel-glitter-boy', 2, 'TX-249 Particle Beam Rifle (1)', '1D6x10+10 M.D.; critical strike (double damage) on a Natural 19 or 20', 1, '2,000 feet (610 m)', 'Each blast counts as one melee attack', '33 blasts from the oversized E-Clip, 66 from the larger power pack; unlimited tied to the armor''s power', NULL, 'Two-handed for the Hell Angel. Weighs 297 lbs (133.6 kg). Black Market cost 190,000+ credits; NGR Army exclusive.'),
  ('x-710-hell-angel-glitter-boy', 3, 'Forearm Plasma Weapon Systems (2)', '6D6 M.D. single blast, 1D6x10 M.D. both arms at one target', 1, '1,000 feet (305 m)', 'Each single or dual blast at one target counts as one melee attack; at different targets each is separate', 'Effectively unlimited; tied to the armor''s power supply', NULL, 'Low profile plasma ejectors aimed at Brodkil.'),
  ('x-710-hell-angel-glitter-boy', 4, 'TX-H Series', NULL, 1, NULL, NULL, NULL, NULL, 'Any TX-H series hand to hand weapon can be used.'),
  ('x-1001-ulti-max-ii-power-armor', 1, 'TX-222 Pulse Laser Rifle (1, Handheld)', '1D6x10 M.D. per quadruple pulse burst', 1, '3,000 feet (914 m)', 'Burst firing only; cannot be used for Called Shots; each burst counts as one melee attack', '40 bursts from the internal supply, recharging one burst per 10 minutes when held or stowed; a giant E-Clip also holds 40', NULL, 'Giant-sized; powered through a hand connector and clamps magnetically to the thigh. Weighs 135 lbs (60.7 kg). Other giant rifles may be substituted.'),
  ('x-1001-ulti-max-ii-power-armor', 2, 'Shoulder Mini-Missile Launchers (2)', 'Varies with mini-missile type; armor piercing 1D4x10 M.D. or fragmentation 5D6 M.D. typical', 1, 'One mile (1.6 km)', 'One at a time or in volleys of 2, 3 or 4', '40 mini-missiles total; 20 per shoulder launcher', NULL, NULL),
  ('x-1001-ulti-max-ii-power-armor', 3, 'Chest Mini-Missile Launchers (2)', 'Varies with mini-missile type; armor piercing 1D4x10 M.D. or fragmentation 5D6 M.D. favored', 1, 'One mile (1.6 km)', 'One at a time or in volleys of 2, 4, 6, 8 or 10', '20 mini-missiles total; 20 per chest launcher (as printed)', NULL, NULL),
  ('x-1001-ulti-max-ii-power-armor', 4, 'Leg Mini-Missile Launchers (2)', 'Varies with mini-missile type; armor piercing 1D4x10 M.D. or fragmentation 5D6 M.D. typical', 1, 'One mile (1.6 km)', 'One at a time or in volleys of 2, 4 or 6', '12 mini-missiles total, six in each leg launcher', NULL, NULL),
  ('x-1001-ulti-max-ii-power-armor', 5, 'Forearm Vibro-Blades (2)', '3D6+3 M.D.', 1, NULL, NULL, NULL, NULL, 'Retractable, in special forearm housings.'),
  ('x-1001-ulti-max-ii-power-armor', 6, 'TX-H Series', NULL, 1, NULL, NULL, NULL, NULL, 'Any TX-H series hand to hand weapon can be used.'),
  ('dv-39-wolf-pack-robot-drone', 1, 'A. Optional Back-Mounted Mini-Missile Launcher', 'Varies with missile type; armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D. typical', 1, 'One mile (1.6 km)', 'One at a time or in a volley of 2 or 4', 'Six mini-missiles total', NULL, 'Only one back-mounted option at a time.'),
  ('dv-39-wolf-pack-robot-drone', 2, 'B. Optional Back-Mounted Laser', '3D6 M.D. per single shot', 1, '4,000 feet (1,219 m)', 'Each shot counts as one melee attack', 'Effectively unlimited', NULL, 'Only one back-mounted option at a time.'),
  ('dv-39-wolf-pack-robot-drone', 3, 'C. Optional Back-Mounted Ion Cannon', '5D6 M.D. per blast', 1, '2,000 feet (610 m)', 'Each single blast counts as one melee attack', 'Effectively unlimited', NULL, 'Only one back-mounted option at a time.'),
  ('eir-60-extermination-robot', 1, 'Demolitions Package (1)', '1D4 M.D.', 1, NULL, NULL, 'One explosive charge', NULL, 'Single use; ruptures a Gargoyle egg.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 11 vessels are in and cite Triax 2' AS assertion, count(*) AS got, 11 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 31: Triax 2 p.%' AND slug IN ('t-25-uber-super-exoskeleton-armor', 'x-11-predator-ii-power-armor', 'x-21-war-eagle-power-armor', 'x-80-butterfly-power-armor', 'x-700-fat-boy-glitter-boy', 'x-710-hell-angel-glitter-boy', 'x-1001-ulti-max-ii-power-armor', 'dv-39-wolf-pack-robot-drone', 'dvo-1-aerial-spy-drone', 'eir-60-extermination-robot', 'eir-70-robot-spy-drone');
SELECT 'their 93 locations are in' AS assertion, count(*) AS got, 93 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('t-25-uber-super-exoskeleton-armor', 'x-11-predator-ii-power-armor', 'x-21-war-eagle-power-armor', 'x-80-butterfly-power-armor', 'x-700-fat-boy-glitter-boy', 'x-710-hell-angel-glitter-boy', 'x-1001-ulti-max-ii-power-armor', 'dv-39-wolf-pack-robot-drone', 'dvo-1-aerial-spy-drone', 'eir-60-extermination-robot', 'eir-70-robot-spy-drone');
SELECT 'their 38 weapon entries are in' AS assertion, count(*) AS got, 38 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('t-25-uber-super-exoskeleton-armor', 'x-11-predator-ii-power-armor', 'x-21-war-eagle-power-armor', 'x-80-butterfly-power-armor', 'x-700-fat-boy-glitter-boy', 'x-710-hell-angel-glitter-boy', 'x-1001-ulti-max-ii-power-armor', 'dv-39-wolf-pack-robot-drone', 'dvo-1-aerial-spy-drone', 'eir-60-extermination-robot', 'eir-70-robot-spy-drone');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-triax-2-power-armor-and-drones.sql');
