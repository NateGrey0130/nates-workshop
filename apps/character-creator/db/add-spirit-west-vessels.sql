-- Spirit West vessels: the six robots and suits of power armor of Rifts World
-- Book 15: Spirit West, printed 189-202. Three robots (Uktena, Thunderbird,
-- Wolf) and three power armors (U.S.A. SAMAS, War Chief, Iron Bear).
-- Six vehicles, 60 M.D.C. locations, 32 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-spirit-west-vessels.sql
--
-- The book has a TEXT LAYER; offset +1, so printed N is cache p(N+1).
--
-- PAGES READ OFF A RENDER, NOT THE CACHE:
--
--   printed 190  the Uktena's location list is set under a full-width plate and
--                the text layer detaches "10 each" from the Spines line. The
--                render reads Spines 10 each, and the rest as stored.
--   printed 193  on this book's glyph-corrupt list. The Thunderbird's
--                mini-missile figures on it (1D4x10, 5D6 high explosive, one
--                mile, five per launcher, 60 total) were read off the render and
--                agree with the text layer.
--   printed 194  the LAWLO range prints "200ft (610m)" in the ink as well; 610 m
--                is 2000 feet. Stored as printed, with that noted.
--
-- THE WELDED PAGE IS NOT WHAT THE SURVEY SAID. The manifest flags printed 201,
-- and the survey filed it as the War Chief's second page. It is the Iron Bear's
-- introduction and plate: its two columns of prose interleave and it carries no
-- figure. The War Chief's stat block is entirely on printed 200.
--
-- NONE OF THE SIX IS PRICED. Each Market Cost line says the machine is not sold
-- outside the preserves, then gives the figure it WOULD fetch. Following the
-- underseas vessels, an estimate is not a price: cost is NULL and the figure is
-- in cost_note.
--
-- DICE THE TEXT LAYER SETS WRONG are read as the only dice they can be
-- (BOOK-INGEST-AUDIT F53): !D4xlO is 1D4x10, !D6xlO is 1D6x10, 2D6xlO is
-- 2D6x10, 4D6xlO is 4D6x10, 2D4xlO is 2D4x10.
--
-- TWO BOOK SLIPS, stored as printed: the Wolf's and the Iron Bear's missile
-- ranges read "1 mile (1.2 km)" where a mile is 1.6 km; and three location
-- lines print one figure for a pair with no "each" (the Uktena's forearm
-- launchers, the Wolf's shoulder cannons, the Iron Bear's gas ports).
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('uktena-combat-robot', 'Uktena Combat Robot', 'rifts', 'robot',
   'Three: the pilot (robot, head weapons and hand to hand), the co-pilot (sensors, communications, movement in melee) and the gunner (all other ranged weapons). One pilot can run it alone at half the attacks and bonuses.',
   'Two sit comfortably, three crowded, and five in an emergency - then the crew lose one attack per melee and are -2 on initiative.',
   '75 mph (120 kph) on land, excellent on rough and uneven ground and at climbing. It cannot leap, but can brace on its rear legs and tail to reach 45 feet (13.8 m) and haul itself up or across.',
   'Not possible.',
   'Swimming or crawling the bottom 25.8 knots (30 mph); surfaced with water jets 34.4 knots (40 mph); upstream against the largest rivers at a third less. Maximum depth 1500 feet (457 m).',
   'Height 35 feet (10.7 m) upright, 18 feet (5.4 m) crawling. Width 18 feet (5.4 m). Length about 62 feet (18.9 m) upright, 96 feet (29.2 m) crawling.',
   '70 tons',
   625, NULL,
   'Not sold outside the preserves. Printed 191 says one that reached the market would fetch upwards of 100 million credits - an estimate, not a price.',
   'Model Type UWS-HAR-02, Class: Amphibious Heavy Assault Robot. The first and largest Modern Native American war machine, built to hunt the giant supernatural creatures of the wilds: serpent-shaped, with two pairs of short legs, one pair of arms and a mace-like tail, nearly 100 feet long, and the largest robot produced in North America. Robot P.S. 50. Nuclear, average life 15 years. Carries three months of food and camping gear for long patrols. Robot combat: one hand to hand attack at level one plus one at levels 5 and 10, in addition to the pilot''s; +2 to strike, +3 to parry, +2 to roll, +2 to dodge underwater.',
   'Rifts World Book 15: Spirit West p.189-192'),

  ('thunderbird-assault-robot', 'Thunderbird Assailant Aerial Assault Robot', 'rifts', 'robot',
   'Two: the pilot flies and runs the missile launchers; the co-pilot runs communications, sensors, the rail gun and the energy weapons. Each gets full attacks on the weapons he operates.',
   NULL,
   'Running 60 mph (96 kph). Leaps 20 feet (6 m) high and 30 feet (9 m) across, or 50 feet (15 m) high and 100 feet (30.5 m) across with thrusters.',
   '600 mph (960 km) maximum, cruising 100 to 300 mph. Hovers, and takes off and lands vertically. Maximum altitude 30,000 feet (9,100 m).',
   'Swims about 4 mph, walks the sea bottom at 20 mph; with jet thrusters 60 mph on the surface or 40 mph underwater. Maximum depth 1000 feet (305 m).',
   'Height 26 feet (7.9 m). Width 16 feet (4.8 m) at the shoulders, 26 feet (7.9 m) wingtip to wingtip. Length 10 feet (3 m).',
   '18 tons',
   350, NULL,
   'Not sold outside the Indian Nations. Printed 192 says one would fetch upwards of 20 million credits, and another 20 million for its LAWLO system - estimates, not prices.',
   'Model Type THAR-06, Class: Heavy Aerial Assault Robot. The flying counterpart of the Wolf: a patrol and rapid-response machine, and an air-lift for troops and civilians, suited to preserves with no airstrip. Robot P.S. 48. Nuclear, average life 10 years. Depleting the stabilizer wings cuts speed 10%, piloting 25%, and halves dodge in flight.',
   'Rifts World Book 15: Spirit West p.192-194'),

  ('wolf-assault-robot', 'Wolf Assault Robot', 'rifts', 'robot',
   'Three: pilot, gunner and communications officer. One pilot can run it at two fewer attacks and -1 to all bonuses.',
   'Two can squeeze in behind the seats.',
   '160 mph (256 km) maximum, cruising 60 mph (96 kph). Leaps 40 feet (12.2 m) high and 60 feet (18.3 m) across, or 60 feet high and 120 feet across from a run of 100 mph or more.',
   'Not possible.',
   NULL,
   'Height 20 feet (6 m). Width 11 feet (3.3 m). Length 26 feet (7.8 m), not counting the tail.',
   '32 tons',
   480, NULL,
   'Not sold outside the preserves. Printed 195 says one would fetch upwards of 25 million credits - an estimate, not a price.',
   'Model Type WH-GAR-06, Class: Heavy Ground Assault Robot. The four-legged ground counterpart of the Thunderbird, for seek-and-destroy missions against giant supernatural menaces and robots, sometimes in trios with Uktena robots, and a mainstay of Modern preserve defences. Carries or pulls up to 50 tons. Robot P.S. 50. Nuclear, average life 12 years. Losing one leg halves speed and costs -2 to all bonuses; losing two cripples it to a crawl of 3D6 with no bonuses. The ears are sensor clusters and the tail is mostly for show.',
   'Rifts World Book 15: Spirit West p.194-196'),

  ('usa-samas', 'U.S.A. SAMAS', 'rifts', 'power-armor',
   'One.', 'None.',
   'Running 60 mph (96 kph) at a tenth of the usual fatigue. Leaps 15 feet (4.6 m) high or across unassisted; thruster-assisted 100 feet (30.5 m) high and 200 feet (61 m) across.',
   'Hovers up to 200 feet (61 m). Maximum 320 mph (516 kph), cruising 160 mph (256 kph), maximum altitude about 650 feet (195 m). The jets must cool after ten hours above cruising speed or twenty at it.',
   NULL,
   'Height 8 feet (2.4 m). Width 3.5 feet (1.06 m) wings down, 10 feet (3 m) extended. Length 4.5 feet (1.4 m).',
   '340 lbs without the rail gun',
   250, NULL,
   'Not sold outside select Modern Indian preserves. Printed 198 puts a fully powered suit with rail gun and full drum at 4+ million credits - an estimate, not a price.',
   'Model Type PA-04A, Class: Strategic Armor Military Assault Suit. Pre-Rifts American SAMAS built in an automated factory Modern Indians found intact at a hidden northwest military base; identical to the Coalition''s original but for minor statistics, and kept secret because of how the Coalition treats anyone else using "its" design. One in five is a heavy assault model with a mini-missile on each shoulder and leg wing tip. P.S. 30. Nuclear, average life 20 years. Destroying the head leaves the pilot on his own senses with no power armor combat bonuses; destroying a wing stops flight but not jet leaps or hovering.',
   'Rifts World Book 15: Spirit West p.196-198'),

  ('war-chief-power-armor', 'War Chief Power Armor', 'rifts', 'power-armor',
   'One.', 'None.',
   'Running 75 mph (120 km) at a tenth of the usual fatigue. Leaps 18 feet (5.4 m) high or across unassisted; thruster-assisted 120 feet (36.6 m) high and 240 feet (73 m) across.',
   'Hovers up to 200 feet (61 m). Maximum 380 mph (608 km), cruising 190 mph (304 km), maximum altitude about 1000 feet (305 m). The jets must cool after ten hours above cruising speed or twenty at it.',
   NULL,
   'Height 8.6 feet (2.6 m). Width 3.5 feet (1.06 m) wings down, 10 feet (3 m) extended. Length 4.5 feet (1.4 m).',
   '330 lbs (148.5 kg) without the rail gun',
   250, NULL,
   'Not sold on any market. Printed 200 says one would fetch 3+ million credits with its ion gun - an estimate, not a price.',
   'Model Type WC-PA-02, Class: Strategic Assault Military Armored Suit. An experimental derivative of the U.S.A. SAMAS: lighter and faster (an extra +1 to parry and dodge), thinner-armored in places, and armed as standard with the NAE-1D ion gun, which draws on the suit''s nuclear supply (an E-clip port backs up a cut power cord, which has 20 M.D.C. and needs a called shot at -4). Surplus suits are cached in bunkers for war and for stranded warriors. P.S. 28. Nuclear, average life 20 years. Destroying the head knocks the pilot out 01-70% and strips all sensors and power armor bonuses.',
   'Rifts World Book 15: Spirit West p.199-200'),

  ('iron-bear-power-armor', 'Iron Bear Power Armor', 'rifts', 'power-armor',
   'One.', 'None.',
   'Running 55 mph (88 kph). Leaps 10 feet (3 m) high or across, or 50 feet (15.2 m) with its thrusters.',
   'Not possible.',
   NULL,
   'Height 9.5 feet (2.8 m). Length 5 feet (1.5 m).',
   'One ton',
   400, NULL,
   'Not sold to any outside market. Printed 202 says one would fetch upwards of 4+ million credits - an estimate, not a price.',
   'Model Type Ursa-HPA-09, Class: Military Heavy Assault Power Armor; also called the Ursa HPA. An oversized, bear-shaped ground assault suit patterned in many ways on the Glitter Boy, built for cluttered ruins, woodland and rocky cliffs that slow larger machines. P.S. 50. Nuclear, average life 15 years. A small locker holds the pilot''s body armor and gear. Destroying the head negates every sensor bonus.',
   'Rifts World Book 15: Spirit West p.201-202');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('uktena-combat-robot', 'Propulsion Unit', 200, NULL, 1),
  ('uktena-combat-robot', 'Belly Laser Turret (1)', 100, NULL, 2),
  ('uktena-combat-robot', 'Long-Range Missile Pods (2; sides)', 175, 'Each.', 3),
  ('uktena-combat-robot', 'Forearm Mini-Missile Launchers (2; small, forearm)', 30, 'As printed, with no "each". A small target: called shot at -3.', 4),
  ('uktena-combat-robot', 'Shoulder P-Beam Cannons (2)', 150, 'Each. A small target: called shot at -3.', 5),
  ('uktena-combat-robot', 'Neck Mounted Rapid-Fire Laser (1; back of head)', 50, 'A small target: called shot at -3.', 6),
  ('uktena-combat-robot', 'Plasma Cannon (1; mouth)', 40, 'A small target: called shot at -3, and only open to attack while the mouth is open.', 7),
  ('uktena-combat-robot', 'Spines (many on neck and head)', 10, 'Each. A small target: called shot at -3. Read off a render of printed 190.', 8),
  ('uktena-combat-robot', 'Hands (2)', 50, 'Each. A small target: called shot at -3.', 9),
  ('uktena-combat-robot', 'Arms (2)', 200, 'Each.', 10),
  ('uktena-combat-robot', 'Legs (4)', 260, 'Each.', 11),
  ('uktena-combat-robot', 'Tail Section', 360, 'Depleting it halves the underwater dodge and roll bonuses.', 12),
  ('uktena-combat-robot', 'Head', 320, 'Destroying it disables only the mouth plasma cannon; the sensors run the length of the body.', 13),
  ('uktena-combat-robot', 'Main Body', 625, 'Depleting it shuts the robot down completely.', 14),
  ('uktena-combat-robot', 'Reinforced Crew Compartment', 100, NULL, 15),

  ('thunderbird-assault-robot', 'Main Jets (4; back)', 60, 'Each. A small target: called shot at -3.', 1),
  ('thunderbird-assault-robot', 'Particle Beam Cannon (1; mounted over right shoulder)', 150, 'A small target: called shot at -3.', 2),
  ('thunderbird-assault-robot', 'Rail Gun (1; center of chest)', 90, 'A small target: called shot at -3.', 3),
  ('thunderbird-assault-robot', 'Stabilizer Wings with Mini-Missile Launchers (2)', 175, 'Each. A small target: called shot at -3. Depleting them cuts speed 10%, piloting 25% and halves dodge in flight.', 4),
  ('thunderbird-assault-robot', 'Forearm Medium Range Missile Launchers (2)', 60, 'Each.', 5),
  ('thunderbird-assault-robot', 'Arms (2)', 150, 'Each.', 6),
  ('thunderbird-assault-robot', 'Legs (2)', 200, 'Each.', 7),
  ('thunderbird-assault-robot', 'Head', 175, 'A small target: called shot at -3.', 8),
  ('thunderbird-assault-robot', 'Reinforced Crew Compartment', 80, NULL, 9),
  ('thunderbird-assault-robot', 'Main Body', 350, 'Depleting it shuts the robot down completely.', 10),

  ('wolf-assault-robot', 'Particle Beam/Laser Pulse Cannons (2; shoulders)', 175, 'As printed, with no "each". A small target: called shot at -3.', 1),
  ('wolf-assault-robot', 'Tail', 50, 'Just for show. A small target: called shot at -3.', 2),
  ('wolf-assault-robot', 'Shoulder Mini-Missile Launchers (10)', 30, 'Each. A small target: called shot at -3.', 3),
  ('wolf-assault-robot', 'Eye Lasers (2)', 30, 'Each. A small target: called shot at -3.', 4),
  ('wolf-assault-robot', 'Legs (4)', 250, 'Each. A small target: called shot at -3. One gone halves speed and costs -2 to all bonuses; two cripple it.', 5),
  ('wolf-assault-robot', 'Head', 150, 'Depleting it knocks out the advanced sensors: robot bonuses fall to zero, the pilot''s are unaffected.', 6),
  ('wolf-assault-robot', 'Reinforced Crew Compartment', 100, 'In the chest.', 7),
  ('wolf-assault-robot', 'Main Body', 480, 'Depleting it shuts the robot down completely.', 8),

  ('usa-samas', 'Ammo Drum (rear)', 25, NULL, 1),
  ('usa-samas', 'Rail Gun', 50, NULL, 2),
  ('usa-samas', 'Shoulder Wings (2)', 30, 'Each. Destroying a wing makes flight impossible, though jet leaps and hovering still work.', 3),
  ('usa-samas', 'Main Rear Jets (2)', 60, 'Each.', 4),
  ('usa-samas', 'Forearm Mini-Missile Launcher (1, left)', 50, NULL, 5),
  ('usa-samas', 'Head', 70, 'A small target: called shot at -3. Destroying it strips all optics and sensors and every power armor combat bonus.', 6),
  ('usa-samas', 'Main Body', 250, 'Depleting it shuts the unit down completely.', 7),

  ('war-chief-power-armor', 'Ammo Drum (optional; rear)', 25, 'A small target: called shot at -3.', 1),
  ('war-chief-power-armor', 'Rail Gun (optional)', 50, 'A small target: called shot at -3.', 2),
  ('war-chief-power-armor', 'Ion Gun', 75, 'A small target: called shot at -3.', 3),
  ('war-chief-power-armor', 'Shoulder Missiles (4)', 10, 'Each.', 4),
  ('war-chief-power-armor', 'Shoulder Wings (2)', 25, 'Each. Destroying a wing makes flight impossible, though jet leaps and hovering still work.', 5),
  ('war-chief-power-armor', 'Main Rear Jets (2)', 50, 'Each. A small target: called shot at -3.', 6),
  ('war-chief-power-armor', 'Head', 50, 'A small target: called shot at -3. Destroying it knocks the pilot out 01-70% and strips all sensors and power armor bonuses.', 7),
  ('war-chief-power-armor', 'Main Body', 250, 'Depleting it shuts the unit down completely.', 8),

  ('iron-bear-power-armor', 'Ion Cannons (2; small shoulder units)', 45, 'Each. A small target: called shot at -3.', 1),
  ('iron-bear-power-armor', 'Rear Thrusters', 150, NULL, 2),
  ('iron-bear-power-armor', 'Forearm Missile Launchers (2; wrist launchers)', 60, 'Each. A small target: called shot at -3.', 3),
  ('iron-bear-power-armor', 'Upper Arms (2)', 110, 'Each.', 4),
  ('iron-bear-power-armor', 'Forearms (2)', 110, 'Each.', 5),
  ('iron-bear-power-armor', 'Clawed Hands (2)', 50, 'Each. A small target: called shot at -3.', 6),
  ('iron-bear-power-armor', 'Legs (2)', 200, 'Each.', 7),
  ('iron-bear-power-armor', 'Gas Ports (2)', 20, 'As printed, with no "each". A small target: called shot at -3.', 8),
  ('iron-bear-power-armor', 'Head', 115, 'A small target: called shot at -3. Destroying it negates every sensor bonus.', 9),
  ('iron-bear-power-armor', 'Muzzle/Jaws', 80, 'A small target: called shot at -3.', 10),
  ('iron-bear-power-armor', 'Sensor/Camera Eyes (2)', 8, 'Each. A small target: called shot at -3.', 11),
  ('iron-bear-power-armor', 'Main Body', 400, 'Depleting it shuts the unit down completely.', 12);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('uktena-combat-robot', 1, 'Laser Turret', '3D6 M.D. single blast, 6D6 M.D. twin blast', 1, '3,000 feet (914 m)', 'Equal to the gunner''s attacks.', 'Effectively unlimited.', NULL, 'Underbelly turret; rotates 360 degrees with a 60 degree arc of fire. Anti-vehicle and anti-armor.'),
  ('uktena-combat-robot', 2, 'Mini-Missile Launchers (2)', '1D4x10 M.D. per armor piercing missile', 1, '1 mile (1.6 km)', 'Singly or in volleys of 2, 4 or 6 per launcher.', '50 per launcher, 200 total.', NULL, 'Forearm launchers that can take torpedoes or ground-to-air missiles.'),
  ('uktena-combat-robot', 3, 'Particle Beam Cannons (2)', '1D6x10 M.D. single blast, 2D6x10 M.D. synchronized twin blast (one attack)', 1, '3,000 feet (914 m)', 'Equal to the gunner''s attacks.', 'Each fires 40 times an hour, then needs two hours to recharge.', NULL, 'The main weapons, on the shoulders.'),
  ('uktena-combat-robot', 4, 'Long-Range Missile Launchers (2)', '4D6x10 M.D. per proton torpedo', 1, '1,200 miles (1,920 km)', 'Singly or in volleys of 2 or 4 per launcher.', '4 per launcher, 8 total.', NULL, 'On the sides above the legs; rotate 360 degrees. Anti-aircraft and heavy assault.'),
  ('uktena-combat-robot', 5, 'Rapid-Fire Pulse Laser', '2D6 M.D. single blast, 6D6 M.D. three-shot pulse', 1, '2,000 feet (610 m)', 'Equal to the gunner''s attacks.', 'Effectively unlimited.', NULL, 'Behind the head, against boarders and small flying foes.'),
  ('uktena-combat-robot', 6, 'Plasma Cannon', '2D6x10 M.D.', 1, '1,200 feet (365 m)', 'Equal to the pilot''s attacks.', 'Unlimited.', NULL, 'In the mouth, which must open to fire.'),
  ('uktena-combat-robot', 7, 'Hand to Hand Combat', 'Restrained punch 1D6 M.D.; full punch 3D6; power punch 6D6 (two attacks); spined head butt 4D6; tail strike 4D6; bite 5D6; body slam 6D6 (two attacks); charging underwater ram 1D4x10 M.D.', 1, NULL, NULL, NULL, 'One hand to hand attack at level one plus one at levels 5 and 10, in addition to the pilot''s; +2 to strike, +3 to parry, +2 to roll, +2 to dodge underwater.', NULL),

  ('thunderbird-assault-robot', 1, 'Multi-Barreled Rail Gun', '2D4 M.D. per 10-round burst, 1D4x10 M.D. per 40-round burst', 1, '2,000 feet (610 m)', 'Bursts only, equal to the gunner''s attacks; a short or long burst is one attack.', '4,000 rounds, 100 full bursts.', NULL, 'Four barrels in the chest firing together.'),
  ('thunderbird-assault-robot', 2, 'Mini-Missile Launchers (12)', '1D4x10 M.D. per armor piercing missile; 5D6 M.D. per high explosive', 1, '1 mile (1.6 km)', 'Singly or in volleys of two to five per launcher.', '5 per launcher, 60 total.', NULL, 'The circular panels on the stabilizer wings. Printed 193 is glyph-corrupt; these figures were read off a render.'),
  ('thunderbird-assault-robot', 3, 'Particle Beam Cannon', '1D6x10 M.D.', 1, '2,000 feet (610 m)', 'Equal to the gunner''s attacks.', 'Effectively unlimited, but overheats past 200 shots in an hour and shuts down for two hours.', NULL, 'Over the right shoulder; swings to the left in one action.'),
  ('thunderbird-assault-robot', 4, 'Medium Range Missile Launchers (2)', '2D6x10 M.D. per plasma missile', 1, '40 miles (64 km)', 'Singly or in volleys of 2 per launcher.', '2 per launcher, 4 total.', NULL, 'One on each forearm.'),
  ('thunderbird-assault-robot', 5, 'Hand to Hand Combat', 'Restrained punch 1D6 M.D.; full punch 3D6; power punch 6D6 (two attacks); kick 4D6; leap kick 1D4x10; head butt or beak 4D6; flying ram over 100 mph 1D6x10 M.D. with a 01-90% chance to knock a same-size or smaller foe down', 1, NULL, NULL, NULL, 'Two hand to hand attacks at level one plus one at levels 6 and 12; +1 on initiative, +2 to strike (+3 with lock-on), +2 to parry, +2 to dodge on land and +4 in flight, +3 to roll, +3 to pull punch.', NULL),
  ('thunderbird-assault-robot', 6, 'LAWLO System (Laser All Weapon Lock-On)', 'The combined damage of every weapon in range', 1, '200 feet (610 m), as printed, for weapon systems 1-3', NULL, NULL, '+3 to strike on the aimed targeting shot.', 'Experimental. A called, aimed shot with the head targeting lasers locks every weapon on one target, which then fires with all remaining attacks that round; the robot can only dodge or reposition until the lock is released. The ink prints 200 ft beside 610 m, and 610 m is 2000 feet.'),

  ('wolf-assault-robot', 1, 'Rapid-Fire Lasers (2)', '3D6 M.D. single blast, 6D6 M.D. double blast', 1, '2,000 feet (610 m)', 'Equal to the pilot''s attacks.', 'Effectively unlimited.', NULL, 'In the eyes; against troops and fast or flying targets.'),
  ('wolf-assault-robot', 2, 'Shoulder Mini-Missile Launchers', '1D4x10 M.D. per armor piercing missile; 5D6 M.D. per high explosive', 1, '1 mile (1.2 km), as printed', 'Singly or in volleys of 2, 4, 6, 8 or 10.', '100 total, 50 per shoulder; 25 more in storage take 15 minutes to load.', NULL, NULL),
  ('wolf-assault-robot', 3, 'Dual Particle Beam/Laser Cannon Turrets (2)', 'Particle beam 1D6x10 M.D. single, 2D6x10 from both turrets; laser 2D6+2 M.D. single, 1D4x10 per triple pulse, 2D4x10 for a triple pulse from both', 1, 'Particle beam 2,000 feet (610 m); laser 4,000 feet (1,200 m)', 'Equal to the gunner''s attacks; a triple pulse is one attack.', 'Each particle beam fires 100 times an hour, then needs two hours to recharge; the lasers are effectively unlimited.', NULL, 'Laser and particle beam cannot fire at the same time. Each turret rotates 180 degrees.'),
  ('wolf-assault-robot', 4, 'Hand to Hand Combat', 'Restrained claw 2D6 M.D.; full vibro-claw 1D4x10; power claw 2D4x10 (two attacks); rear kick 6D6; head butt 3D6; pounce or ram over 100 mph 1D6x10 M.D. with a 01-80% chance to knock a same-size or smaller foe down; bite 1D4x10; stomp 2D6', 1, NULL, NULL, NULL, 'Two hand to hand attacks at level one plus one at levels 4, 11 and 15; +2 to strike with ranged weapons, +4 in hand to hand, +3 to parry, +3 to dodge, +4 to roll.', NULL),

  ('usa-samas', 1, 'USA-M31 Rail Gun', '1D6x10 M.D. per 40-round burst; 1D4+1 M.D. per round', 1, '4,000 feet (1,200 m)', 'Equal to the pilot''s attacks.', '2000-round drum, 50 bursts. A second drum can hang under the rear jets; reloading takes a trained crew one minute, anyone else about five.', NULL, 'The original SAMAS rail gun, heavier than the Coalition''s C-40R. Gun 110 lbs, drum 190 lbs.'),
  ('usa-samas', 2, 'USA-M17 Mini-Missile Launcher', '1D4x10 M.D. per armor piercing missile; plasma 1D6x10 M.D., common on heavy assault models', 1, '1 mile (1.6 km)', 'Singly or in pairs; heavy assault models 1, 2, 4 or all 6.', 'Two standard; six on a heavy assault model.', NULL, 'Forearm launcher opposite the rail gun, plus wing-tip missiles on the heavy assault model.'),
  ('usa-samas', 3, 'Rotary Mini-Missile Launcher (optional)', '5D6 M.D. per fragmentation or high explosive missile; any mini-missile can be used', 1, 'Usually 0.5 to 1 mile (0.8 to 1.6 km)', 'Singly or in volleys of 2, 3 or 5.', '5 per column, 25 total.', NULL, 'Replaces the ammo drum and rail gun behind the shoulders and snaps up over the right shoulder to fire; a suit carrying it uses clip-fed rail guns or energy rifles instead.'),
  ('usa-samas', 4, 'Other Rail Guns and Weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Can use any hand-held weapon, from rail guns and energy rifles to Vibro-Blades and magic items.'),
  ('usa-samas', 5, 'Hand to Hand Combat', NULL, 1, NULL, NULL, NULL, NULL, 'Mega-damage hand to hand; see Power Armor Combat Training in the Rifts RPG.'),

  ('war-chief-power-armor', 1, 'NAE-1D Ion Gun System', '6D6 M.D.', 1, '3,500 feet (1,067 m)', 'Equal to the pilot''s attacks.', 'Effectively unlimited: 100 blasts an hour, then 30 minutes to cool; up to 200, each blast past 100 carrying a cumulative 1% chance of melting the gun.', NULL, 'Standard armament, powered by the suit. Gun 70 lbs (31.5 kg).'),
  ('war-chief-power-armor', 2, 'Shoulder Mini-Missiles', '1D4x10 M.D. per armor piercing missile; plasma 1D6x10 M.D. on heavy assault missions', 1, '1 mile (1.6 km)', '1 or 2 at a time per launcher.', 'Two per shoulder, four total.', NULL, 'Usually the first weapons used, being targets themselves.'),
  ('war-chief-power-armor', 3, 'Other Rail Guns and Weapons', NULL, 0, NULL, NULL, NULL, NULL, 'Can use any other hand-held weapon, rail guns and energy rifles included.'),
  ('war-chief-power-armor', 4, 'Hand to Hand Combat', NULL, 1, NULL, NULL, NULL, NULL, 'Mega-damage hand to hand; see Power Armor Combat Training in the Rifts RPG.'),

  ('iron-bear-power-armor', 1, 'Ion Cannons (2)', '5D6 M.D. single blast, 1D6x10 M.D. twin blast', 1, '1,200 feet (365.7 m)', 'Equal to the gunner''s attacks.', 'Effectively unlimited.', NULL, 'Ball-and-socket shoulder mounts rotating 180 degrees; against vehicles and large monsters.'),
  ('iron-bear-power-armor', 2, 'Mini-Missile Launchers (2)', '1D4x10 M.D. per armor piercing missile', 1, '1 mile (1.2 km), as printed', 'Singly or in volleys of 2, 4, 6 or 8 per launcher.', '18 per launcher, 36 total.', NULL, 'Rotary wrist launchers.'),
  ('iron-bear-power-armor', 3, 'Gas/Smoke Dispensers (2)', 'None; smoke covers 60 by 60 feet, gases are S.D.C., and a nerve poison does 2D4x10 S.D.C. to humans (half on a save) and tranquilizes supernatural beings', 0, '60 foot (18.3 m) area', 'Equal to the gunner''s attacks.', 'Eight doses each.', NULL, 'Nozzles in the lower chest, for riot control and pacification.'),
  ('iron-bear-power-armor', 4, 'Vibro-Claws', 'Restrained 2D6 M.D.; full strength 5D6; paired claw attack 1D6x10; power claw 1D6x10 (two attacks)', 1, NULL, NULL, NULL, NULL, 'On each hand, for close fighting with monsters and tearing through M.D.C. materials.'),
  ('iron-bear-power-armor', 5, 'Rail Guns and Hand-Held Weapons (optional)', NULL, 0, NULL, NULL, NULL, NULL, 'Can use most power-armor-sized rail guns and energy weapons; the claws rule out rifles and pistols.'),
  ('iron-bear-power-armor', 6, 'Hand to Hand Combat', NULL, 1, NULL, NULL, NULL, NULL, 'Mega-damage hand to hand; see Power Armor Combat Training in the Rifts RPG and the claw damages above.');

-- Read the result back. INSERT OR IGNORE is SILENT on a collision, so the
-- counts are what prove nothing was lost. Every want is counted from the
-- stat blocks, not from the database.
SELECT 'the six vessels' AS assertion, count(*) AS got, 6 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 15: Spirit West%';

SELECT 'their M.D.C. locations: 15 + 10 + 8 + 7 + 8 + 12' AS assertion, count(*) AS got, 60 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('uktena-combat-robot', 'thunderbird-assault-robot', 'wolf-assault-robot', 'usa-samas', 'war-chief-power-armor', 'iron-bear-power-armor');

SELECT 'their weapon entries: 7 + 6 + 4 + 5 + 4 + 6' AS assertion, count(*) AS got, 32 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('uktena-combat-robot', 'thunderbird-assault-robot', 'wolf-assault-robot', 'usa-samas', 'war-chief-power-armor', 'iron-bear-power-armor');

SELECT 'main bodies 625 + 350 + 480 + 250 + 250 + 400' AS assertion, sum(mdc_main_body) AS got, 2355 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 15: Spirit West%';

SELECT 'none carries a price' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 15: Spirit West%' AND (cost IS NOT NULL OR cost_note IS NULL);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-spirit-west-vessels.sql');
