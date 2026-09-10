-- New West vessels, first half: the two Bandito Arms SAMAS, the three
-- CyberSlinger cyborg bodies and the Tarantula ATV. Printed 183-195.
-- Six vehicles, 57 M.D.C. locations, 16 weapon entries.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-nw-vessels-p183-195.sql
--
-- FILENAME SORT CHECKED RATHER THAN ASSUMED, per class-import. The z-tier has
-- escalated to eight z''s, so `zzzzzzzz-nw-` lands between `zzzzzzz-ww-` and
-- `zzzzzzzz-pw-`. That is fine here: every vessel file is an independent
-- INSERT OR IGNORE for a different book and none corrects another, so position
-- within the tier decides nothing.
--
-- == THE CYBERSLINGERS ARE VESSELS, NOT CLASSES ==
--
-- The survey claimed they were classes for four class batches and #888
-- corrected it. Printed 189-193 gives each one a `Model Type`, a `Class:` line
-- reading "Full Conversion Cyborg", an `M.D.C. by Location` block and a cost in
-- millions, and NO class block on any of the three pages - no attributes, no
-- O.C.C. skills, no starting money. Printed 190 says outright that these are
-- cyborg BODIES and that the recipients "all fall into the ''Borg O.C.C.
-- category". Free Quebec''s four chassis ARE classes and these three are not;
-- the resemblance runs the opposite way to what the survey first recorded.
--
-- == THE TARANTULA HAS TWO MAIN BODIES, AND mdc_main_body IS NULL ==
--
-- Printed 194 prints `** Fore Section: Main Body - 200` AND
-- `Abdomen/Rear Section: Main Body - 300`, with the double asterisk - "depleting
-- the M.D.C. of the main body will destroy it" - covering both. There is no
-- single main body to put in the column, and picking one would silently invent
-- an answer the book does not give. Both figures are stored as
-- `vehicle_locations` rows, which is exactly what that table is for, and the
-- column is NULL. Three of the catalog''s 143 vessels already carry a NULL
-- there, so this is a shape the data supports rather than a new one.
--
-- == ONE FIGURE RECOVERED FROM ITS OWN METRIC ==
--
-- The Wild Weasel''s forearm plasma ejectors print a maximum effective range of
-- "1,00 feet (305 m)" on printed 187 - a dropped digit. 305 m IS 1000 feet, and
-- the same suit''s sibling systems are all round figures, so the range is 1000
-- and the metric is what proves it. Recorded here because the parenthetical
-- conversion is the only check a page like this offers.
--
-- == WHAT IS DELIBERATELY NOT STORED ==
--
-- Each CyberSlinger lists a page of Standard Bionic Features - amplified
-- hearing, multi-optic eyes, a combat computer, quick draw holsters - carrying
-- combat bonuses. `vehicles` has no bonus column and `vehicle_weapons.bonus` is
-- per weapon, so the features and their bonuses are in the description, whole,
-- where a reader building one of these characters will meet them. Several of
-- those features are now gear rows in their own right from
-- add-new-west-gear-b-bionics.sql (combat-computer, quick-draw-holsters); they
-- are NOT linked here, because `gear.vehicle_slug` points a gear row AT a
-- vessel and these are the reverse relationship.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('bandito-sidewinder-samas', 'Bandito "Sidewinder" SAMAS', 'rifts', 'power-armor',
   'One pilot.', 'None.',
   'Running 100 mph (160 km) maximum, partly thanks to the maneuvering jets assisting the running process. Running tires the operator at 10% of the usual fatigue rate thanks to the robot exoskeleton. Leaping 15 feet (4.6 m) high or across unassisted; a jet thruster assisted leap reaches 110 feet (36.5 m) high and 200 feet (61 m) across without attaining flight.',
   'Hovers stationary up to 300 feet (91.5 m), or flies at a maximum 250 mph (400 km) with a maximum altitude of 6000 feet (1829 m) - above that, strong winds and rough weather make flight erratic and dangerous, because the suit is small and light and was designed to hug the ground and slip under enemy radar. Maximum range is unlimited on the nuclear system, but the engines need a cool-down period after ten hours of use.',
   'Swims at roughly 4 mph (6.4 km/3.4 knots) using human paddling movements, or walks the sea bottom at about 25% of normal running speed. Using the jet thrusters it travels the surface at 50 mph (80 km/42.5 knots) or underwater at 40 mph (64 km/34 knots). Maximum ocean depth 800 feet (224 m).',
   'Height 8 feet at the head, 10 feet at the shoulders. Width 4.3 feet with wings down, 10 feet (3 m) extended. Length 4 feet 6 inches (1.4 m).',
   '490 lbs (220.5 kg) without a rail gun',
   230, 3600000,
   '3.6 million credits for a new or almost new suit with a full weapons load. NOTE: stolen and used CS SAMAS sell for around 1.6 million credits, but are rarely available.',
   'Model Type PA-09-AVT, "The Sidewinder". Class: Vectored Thrust Strategic Armor Military Assault Suit. Inside the Area 51 facility were volumes of information on an experimental US Air Force unit called the Strategic Armored Military Assault Suit, and an advanced series II version called the VT-SAMAS or Vectored Thrust SAMAS, code named Project Sidewinder. It was an attempt to upgrade the original SAMAS into a more versatile combat unit using vectored thrust propulsion, and the test vehicle for upgraded systems like the "Big Bang" grenade launcher. Only eight units had been created when the ley lines erupted - four assault units and four in "Wild Weasel" anti-electronics and SAM target designation roles. THE COALITION HAS DECLARED POSSESSION OF ONE A CRIME PUNISHABLE BY IMMEDIATE EXECUTION WITHOUT TRIAL, with nearly 100 executions in three months in and around Chi-Town alone, which makes both suits undesirable commodities in the east regardless of price. Sales in the West, Mexico and the Pecos Empire continue, though fewer than 600 have sold in total. PHYSICAL STRENGTH equal to a robot P.S. of 30. Cargo: none. Power system nuclear, average life 10 years. PENALTIES: the Sidewinder is very demanding to fly and control, and the abrupt movements and high mobility place G-forces on the pilot, so the pilot must have a P.E. of at least 16 and a P.P. of at least 15 to fly it, and should be trained in SAMAS Elite piloting. Those who are not get none of the special bonuses and are -3 to roll with punch, fall or impact. HAND TO HAND: quick reflexes and high strength give it the same damage and bonus capabilities as the standard old-style "Death''s Head" SAMAS, plus +1 on initiative, +1 to parry and +2 to dodge on top of those normally available to a SAMAS; Power Armor Combat Training Basic and Elite both apply.',
   'Rifts World Book 14: New West p.183-184'),

  ('bandito-wild-weasel-samas', 'Bandito "Wild Weasel" SAMAS', 'rifts', 'power-armor',
   'One pilot.', 'None.',
   'Running 60 mph (96 km) maximum, partly thanks to the maneuvering jets assisting the running process. Running tires the operator at 10% of the usual fatigue rate thanks to the robot exoskeleton. Leaping 15 feet (4.6 m) high or across unassisted; a jet thruster assisted leap reaches 100 feet (30.5 m) high and 200 feet (61 m) across without attaining flight.',
   'Hovers stationary up to 1000 feet (305 m), or flies at a maximum 220 mph (352 km) with a maximum altitude of 6000 feet (1829 m). Maximum range is unlimited on the nuclear system, but the engines need a cool-down period after ten hours of use. SLOWER THAN THE SIDEWINDER in every regime, and better armoured for it: the Weasel is the more likely target.',
   'Swims at roughly 4 mph (6.4 km/3.4 knots), or walks the sea bottom at about 25% of normal running speed. Using the jet thrusters it travels the surface at 50 mph (80 km/42.5 knots) or underwater at 40 mph (64 km/34 knots). Maximum ocean depth 1000 feet (305 m).',
   'Height 9 feet (2.7 m) head to toe; the top mounted air foil adds another two feet (0.6 m) for an overall 11 feet (3.3 m). Width 5.6 feet (1.7 m) with wings down, 11 feet (3.3 m) extended. Length 5 feet (1.5 m).',
   '540 lbs (243 kg) without a rail gun',
   320, 4800000,
   '4.8 million credits for a new or almost new suit with full weapon systems.',
   'Model Type PA-09-AVT. Class: Vectored Thrust Strategic Armor Military Assault Suit. The Wild Weasel version of the Sidewinder was designed as a one-man infantry electronic-countermeasure and communications unit, working alongside the standard SAMAS to provide support, battlefield intelligence, anti-missile capability and forward observation and targeting. It has the heavier armour because it is more likely to be a target, and comparatively short-range plasma ejector forearm blasters with greater damage to destroy missiles that evade its jamming defense, counting on other units to come to its defense while it gathers and transmits data. BLACK BOX ABILITIES: a radar and computer tracking system with a 100 mile (160 km) radius above the tree line or 100 feet (30.5 m) in the air, whichever is greater, identifying and tracking 144 targets simultaneously, with sonar limited to 30 miles (48 km); directional, narrow and wide band radio and laser communication; a radio scrambler and encryption system that scrambles and unscrambles incoming and outgoing messages, decodes encrypted ones, and records and stores transmissions on other channels for later; a TARGETING UPLINK that feeds data to as many as 24 Sidewinder SAMAS, aircraft or ground troops within 50 miles (80 km), giving every unit receiving it +1 on initiative and +1 to dodge; and a FULL JAMMING SUITE that garbles enemy transmissions on 01-65%. To jam an incoming missile the pilot rolls under his weapon systems or electronic countermeasures skill; success scrambles the targeting of ALL missiles directed at him or in his path, effectively -7 to strike, rolled for each missile in the volley. Alternatively he can send a direct laser signal to one or two missiles within 2000 feet (610 m), whether aimed at him or another target entirely, at -9 to hit their intended target. This works on smart bombs and mini-missiles as well as guided missiles. The jamming DISABLES a missile''s tracking, guidance and motor systems; it does NOT let the Weasel seize control and redirect it. SPECIAL BONUSES: +3 on initiative, +1 to strike and parry, +2 to dodge, +1 to roll with punch, fall or impact, and +1 to pull punch, all in addition to other bonuses and power armor combat training. PHYSICAL STRENGTH equal to a robot P.S. of 30. Cargo: none. Power system nuclear, average life 10 years. PENALTIES as the Sidewinder: P.E. 16 and P.P. 15 minimum to fly it.',
   'Rifts World Book 14: New West p.184-187'),

  ('cslngr-mark-i-kid', 'CSLNGR Mark I "The Kid"', 'rifts', 'borg',
   'The augmented character; this is a cyborg body, not a piloted vehicle.', 'None.',
   'Running Speed Factor 132, or 90 mph (148 km). Leaping 20 feet (6 m) high or lengthwise, double with a running start.',
   'Not capable of flight, but suitable for use with a jet pack.',
   NULL,
   'Size human. Height usually about 6 feet 4 inches (roughly 1.9 m).',
   '400 lbs (180 kg)',
   150, 3600000,
   '3.6 million to 3.9 million credits. Add 100,000 credits for human-looking skin covering.',
   'Model Type CSLNGR Mark I. Class: Full Conversion Cyborg. The first of the CyberSlinger series, named from the American Old West slang used as a nickname for gunslingers and outlaws, and because this body is extremely human in proportion, size and shape. A basic cyborg body with enhanced reflexes, not much bigger than a standard human and relatively easy to conceal or pass off as body armour. IT RETAINS THE ORIGINAL FACE of the person augmented, and natural looking artificial skin can make the individual seem completely human - which makes it popular with those who cherish their humanity or want to disguise their nature, and means it comes with NO built-in weapon systems, arm mounts or telltale cybernetic appliances. It is also the cheapest of the three. THE HUMAN SHAPE MEANS IT CAN WEAR CONVENTIONAL BODY ARMOUR like any normal human. BIONIC PHYSICAL ATTRIBUTES: robot P.S. 20, P.P. 22, Spd 132. Power system nuclear, average life 25 years. STANDARD BIONIC FEATURES: bionic lung; amplified hearing (+1 to parry, +2 to dodge, +3 to initiative); sound filtration system; clock calendar, computer and gyro compass; multi-optic eyes (+1 to strike); quick draw holsters in the legs, two of them (+1 on initiative); headjack; climbing cord; and a combat computer (+1 on initiative, +1 to dodge, +1 to disarm, +2 to pull punch, +2 to roll with punch, fall or impact). WEAPON SYSTEMS: none. SPECIAL BONUSES: any skill requiring high dexterity or reflexes - piloting, lock picking, palming and the like - gains +2%. THE CYBERSLINGER PACKAGE IS A FULL CONVERSION PROCESS turning an average man into a lightning quick bionic gunslinger, and like Mining Borgs the recipient can often arrange the conversion with a town or wealthy individual in trade for 10-15 years of service as lawman, protector or henchman. These are cyborg BODIES: everyone who takes one falls into the Borg O.C.C. category.',
   'Rifts World Book 14: New West p.189-191'),

  ('cslngr-mark-ii-super-slinger', 'CSLNGR Mark II "Super Slinger"', 'rifts', 'borg',
   'The augmented character; this is a cyborg body, not a piloted vehicle.', 'None.',
   'Running Speed Factor 132, or 90 mph (148 km). Leaping 20 feet (6 m) high or lengthwise, double with a running start.',
   'Not capable of flight, but suitable for use with a jet pack.',
   NULL,
   'Size large, tall human. Height usually about 6 feet 8 inches to 7 feet (roughly 2.1 m).',
   '600 lbs (270 kg)',
   190, 5600000,
   '5.6 million to 6 million credits. Add 130,000 credits for human-looking skin covering.',
   'Model Type CSLNGR Mark II. Class: Full Conversion Cyborg. Another predominantly human-sized, human-looking cyborg, except that it is designed for quick draws and HAS FOUR LIGHTNING FAST ARMS. The extra pair gives it an extra melee attack, and the combat computer lets it draw and fire four light weapons simultaneously. HOWEVER, unlike a true Gunslinger O.C.C. the cyborg CANNOT split its attacks between two different targets, and the firing of each PAIR of weapons counts as one melee attack - so four weapons drawn, one in each hand, counts as two melee attacks. Larger and slightly more armoured than the Kid, and more costly. Its close to human shape means it CAN wear body armour designed for large humans and D-bees, modified for four arms. BIONIC PHYSICAL ATTRIBUTES: P.S. 22, P.P. 24, Spd 132. Power system nuclear, average life 25 years. STANDARD BIONIC FEATURES: four bionic arms (+1 attack per melee); bionic lung; amplified hearing (+1 to parry, +2 to dodge, +3 to initiative); sound filtration system; clock calendar, computer and gyro compass; multi-optic eyes (+1 to strike); quick draw holsters in the legs, two of them (+1 on initiative); a fingerjack in one hand; a laser finger in one hand (1D6 M.D., 300 ft/91.5 m range); an Energy-Clip arm port on one arm; headjack; climbing cord; retractable Vibro-Sabres in the forearms of one pair of arms; and a combat computer (+1 on initiative, +1 to dodge, +1 to disarm, +2 to pull punch, +2 to roll with punch, fall or impact). SPECIAL BONUSES: any skill requiring high dexterity or reflexes gains +2%, plus +1 on initiative and +2 to parry.',
   'Rifts World Book 14: New West p.191-192'),

  ('cslngr-mark-iii-gringo', 'CSLNGR Mark III "Gringo"', 'rifts', 'borg',
   'The augmented character; this is a cyborg body, not a piloted vehicle.', 'None.',
   'Running Speed Factor 88, or 60 mph (96 km) - the slowest of the three. Leaping 20 feet (6 m) high or lengthwise, double with a running start.',
   'Not capable of flight, but suitable for use with a jet pack.',
   NULL,
   'Size giant humanoid. Height usually about 9 to 10 feet (2.7 to 3 m).',
   '1200 lbs (540 kg)',
   220, 6100000,
   '6.1 million to 6.4 million credits. The book offers NO human-looking skin option for this chassis, unlike the Mark I and Mark II.',
   'Model Type CSLNGR Mark III, also known as the Rock. Class: Full Conversion Cyborg. A traditional, heavy borg design - big, strong and very well armoured. It lacks some of the speed and agility of the Mark I and II and makes up for it with size and armour: where the Kid and the Super Slinger have lightning reflexes, the Gringo has brute strength and firepower. Like the other two it has the integral combat computer; UNLIKE them it also carries a chest mounted ion cannon and a six pack mini-missile launcher above each shoulder. HUMAN-SIZED BODY ARMOUR CANNOT BE WORN by the Gringo, but cyborg armour can, typically 200 M.D.C. BIONIC PHYSICAL ATTRIBUTES: P.S. 30, P.P. 24, Spd 88. Power system nuclear, average life 25 years. STANDARD BIONIC FEATURES: bionic lung and toxic filter; loudspeaker; voice modulator; amplified hearing (+1 to parry, +2 to dodge, +3 to initiative); sound filtration system; clock calendar, computer and gyro compass; multi-optic eyes (+1 to strike); quick draw holsters in the legs, two of them (+1 on initiative); a laser finger on one hand (1D6 M.D., 300 ft/91.5 m range); an Energy-Clip arm port on one arm; headjack; climbing cord; a chest mounted ion blaster; two six pack mini-missile launchers, one on each shoulder; retractable Vibro-Blades in the forearms; and a combat computer (+1 on initiative, +1 to dodge, +1 to disarm, +2 to pull punch, +2 to roll with punch, fall or impact). SPECIAL BONUSES: +1 to disarm, +1 to parry with Vibro-Blades, +3 to pull punch and +2 to roll with punch, fall or impact.',
   'Rifts World Book 14: New West p.192-193'),

  ('bandito-tarantula-atv', 'The Bandito Tarantula (a.k.a. NG Spider)', 'rifts', 'robot',
   'One pilot, and a co-pilot or gunner.', 'Three passengers comfortably.',
   'Running 100 mph (160 km) maximum. The act of running does NOT tire the operator, because the legs are completely robotic. Leaping, much like a real spider, up to 30 feet (9 m) across and 10 feet (3 m) high.',
   'Not possible.',
   'Adequately suited for underwater operations: walks the sea bottom at about 25% of normal running speed, or swims at a ponderous 5 mph (8 km or 4.2 knots). Maximum depth 500 feet (152.4 m).',
   'Height 6 feet (1.8 m) low to the ground, or 11 feet (3.3 m) fully erect. Width 15 feet (4.6 m) overall, main body 6 feet (1.8 m). Length 14 feet (4.2 m).',
   '9 tons',
   NULL, 18000000,
   '18 million credits for a new bot vehicle with full weapon systems; 14 million without weapons.',
   'Model Type R-100. Class: All-Terrain Robot Stealth Vehicle. A unique, eight-legged, all-terrain robot vehicle first manufactured by Bandito Arms from vehicle designs found at Area 51, and in the last six years knocked off by both Northern Gun and the Manistique Imperium, who call it The Spider. It is deliberately made to resemble a giant spider to frighten potential humanoid and animal antagonists - plus it looks cool, and cool always sells. THE BOOK PRINTS TWO MAIN BODIES for this vehicle - Fore Section 200 and Abdomen/Rear Section 300, both marked with the double asterisk meaning depletion destroys it - so there is no single figure for the mdc_main_body column and it is left NULL; both are stored as locations. DAMAGE NOTES: all locations marked with a single asterisk are small or difficult targets needing a called shot at -3 to strike, and the mini-missile launchers are revealed only when firing, which is the only time they can be struck. Destroying the head knocks out most sensors, optics, radar and targeting, and destroys the mandible rail guns. THE ROBOT CAN LOSE ONE LEG ON EACH SIDE without impairing speed or balance; losing two on one side, or two on one side and one on the other, reduces speed by 20%. PHYSICAL STRENGTH equal to a robot P.S. of 30. Cargo: minimal, but it carries a 50 gallon water cooler, a first-aid kit, a weapon rack for six rifles and two dozen energy clips, and storage for 5-6 duffle bags or backpacks, eight canteens and a few odds and ends. Power system nuclear, average life 15 years. SENSORS OF NOTE: all the standard sensors and options common to most robot vehicles, plus SILENT MOVEMENT equal to a Prowl of 60%, stealth coating and IR dampening gear. With its low profile and stealth system the Tarantula is not likely to register on radar or be detected by heat sensors, and its sand or prairie camouflage colouring makes it difficult to spot visually and from the air, especially when motionless with legs tucked close to the body, or when prowling slowly at 10% normal speed.',
   'Rifts World Book 14: New West p.193-195');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('bandito-sidewinder-samas', 'Shoulder Wings (2)',                        50, 'Each. Destruction of even ONE of the main wings will force the unit to crash-land.', 1),
  ('bandito-sidewinder-samas', 'Shoulder/Wing Mini-Missile Launchers (2)',  60, 'Each.', 2),
  ('bandito-sidewinder-samas', 'Main Turbines (2; rear)',                  100, 'Each. A small target: called shot at -4 to strike.', 3),
  ('bandito-sidewinder-samas', 'Lower Maneuvering Jets (4; rear)',          25, 'Each. A small target: called shot at -4. Destroying the maneuvering wings imparts -1 to dodge per wing destroyed and reduces speed by 10%.', 4),
  ('bandito-sidewinder-samas', 'Leg Maneuvering Jets (1 per leg; lower)',   12, 'Each. A small target: called shot at -4.', 5),
  ('bandito-sidewinder-samas', 'Waist Maneuvering Jets (4)',                10, 'Each. A small target: called shot at -4.', 6),
  ('bandito-sidewinder-samas', 'Head',                                     100, 'A small target: called shot at -4. Destruction will most likely kill or blind the pilot and knocks out all communications, sensors and targeting; the pilot must rely on his own vision and senses and NO power armor combat bonuses apply.', 7),
  ('bandito-sidewinder-samas', 'Hands (2)',                                 25, 'Each. A small target: called shot at -4.', 8),
  ('bandito-sidewinder-samas', 'Arms (2)',                                  60, 'Each.', 9),
  ('bandito-sidewinder-samas', 'Legs (2)',                                 100, 'Each.', 10),
  ('bandito-sidewinder-samas', 'Forearm Guns (2)',                          12, 'Each. A small target: called shot at -4.', 11),
  ('bandito-sidewinder-samas', 'Bandit 6000 Grenade Launcher (1)',          80, 'A small target: called shot at -4.', 12),
  ('bandito-sidewinder-samas', 'Main Body',                                230, 'Destruction destroys the power armor and leaves the pilot inside vulnerable, assuming he survived it. Hits by missiles will generally damage the main body rather than a small target.', 13),

  ('bandito-wild-weasel-samas', 'Shoulder Wings (2)',                       95, 'Each. Destruction of even ONE of the main wings will force the unit to crash-land.', 1),
  ('bandito-wild-weasel-samas', 'Shoulder/Wing "Black Boxes" (2)',          75, 'Each. These hold the WWECM 6 communications, scrambling, jamming, radar and targeting gear.', 2),
  ('bandito-wild-weasel-samas', 'Main Turbines (2; rear)',                 120, 'Each. A small target: called shot at -4 to strike.', 3),
  ('bandito-wild-weasel-samas', 'Lower Maneuvering Jets (4; rear)',         30, 'Each. A small target: called shot at -4. Destroying the maneuvering wings imparts -1 to dodge per wing destroyed and reduces speed by 10%.', 4),
  ('bandito-wild-weasel-samas', 'Leg Maneuvering Jets (1 per leg; lower)',  12, 'Each. A small target: called shot at -4.', 5),
  ('bandito-wild-weasel-samas', 'Waist Maneuvering Jets (4)',               15, 'Each. A small target: called shot at -4.', 6),
  ('bandito-wild-weasel-samas', 'Head',                                    110, 'A small target: called shot at -4. Destruction will most likely kill or blind the pilot and knocks out all communications, sensors and targeting; NO power armor combat bonuses apply.', 7),
  ('bandito-wild-weasel-samas', 'Hands (2)',                                30, 'Each. A small target: called shot at -4.', 8),
  ('bandito-wild-weasel-samas', 'Arms (2)',                                 90, 'Each.', 9),
  ('bandito-wild-weasel-samas', 'Legs (2)',                                150, 'Each.', 10),
  ('bandito-wild-weasel-samas', 'Forearm Guns (2)',                         18, 'Each. A small target: called shot at -4.', 11),
  ('bandito-wild-weasel-samas', 'Bandit 6000 Grenade Launcher or Rail Gun (1)', 80, 'A small target: called shot at -4.', 12),
  ('bandito-wild-weasel-samas', 'Main Body',                               320, 'Destruction destroys the power armor and leaves the pilot inside vulnerable. The heaviest armour of the two Bandito SAMAS, because the Weasel is the more likely target.', 13),

  ('cslngr-mark-i-kid', 'Head (1)',   35, 'Reinforced. The head retains the original face and brain - often the eyes, tongue, voice and other features of the human head - and is reinforced to provide the 35 M.D.C. Targeting the head or hands requires a called shot, and even then the shooter is -4 to strike.', 1),
  ('cslngr-mark-i-kid', 'Hands (2)',  15, 'Each. A called shot at -4 to strike.', 2),
  ('cslngr-mark-i-kid', 'Arms (2)',   45, 'Each.', 3),
  ('cslngr-mark-i-kid', 'Legs (2)',  100, 'Each.', 4),
  ('cslngr-mark-i-kid', 'Main Body', 150, 'Reducing the main body to zero M.D.C. means it is shattered, riddled with holes, leaking vital fluids and incapable of movement or speech. The internal life support systems will keep the borg''s brain alive for 4D6 HOURS before it fails and the brain dies.', 5),

  ('cslngr-mark-ii-super-slinger', 'Head (1)',                        45, 'Reinforced, retaining the original face and brain. A called shot at -4 to strike.', 1),
  ('cslngr-mark-ii-super-slinger', 'Hands (4)',                       15, 'Each - FOUR of them. A called shot at -4 to strike.', 2),
  ('cslngr-mark-ii-super-slinger', 'Arms (4)',                        60, 'Each - four bionic arms, which is what gives this chassis its extra melee attack.', 3),
  ('cslngr-mark-ii-super-slinger', 'Vibro-Blades (2; retractable)',   50, 'Each. Printed as Vibro-Blades in the location block and as Vibro-Sabres in the feature list and weapon systems.', 4),
  ('cslngr-mark-ii-super-slinger', 'Legs (2)',                       120, 'Each.', 5),
  ('cslngr-mark-ii-super-slinger', 'Main Body',                      190, 'Reducing the main body to zero M.D.C. shatters it. The internal life support systems keep the borg''s brain alive for 4D6 hours before it fails.', 6),

  ('cslngr-mark-iii-gringo', 'Head (1)',                                             80, 'Reinforced, retaining the original face and brain. A called shot at -4 to strike.', 1),
  ('cslngr-mark-iii-gringo', 'Hands (2)',                                            25, 'Each. A called shot at -4 to strike.', 2),
  ('cslngr-mark-iii-gringo', 'Arms (2)',                                            100, 'Each.', 3),
  ('cslngr-mark-iii-gringo', 'Vibro-Blades (2; retractable; inflict 2D6 M.D. each)',  50, 'Each. Vibro-Sabres located in the forearms.', 4),
  ('cslngr-mark-iii-gringo', 'Missile Launchers (2)',                                40, 'Each. The six pack mini-missile launchers above each shoulder.', 5),
  ('cslngr-mark-iii-gringo', 'Legs (2)',                                            160, 'Each.', 6),
  ('cslngr-mark-iii-gringo', 'Main Body',                                           220, 'Reducing the main body to zero M.D.C. shatters it. The internal life support systems keep the borg''s brain alive for 4D6 hours before it fails.', 7),

  ('bandito-tarantula-atv', 'Legs (8)',                                100, 'Each. A small target: called shot at -3 to strike. The robot can lose ONE leg on each side without impairing speed or balance; two on one side, or two on one side and one on the other, reduces speed by 20%.', 1),
  ('bandito-tarantula-atv', 'Mandible Rail Guns (2)',                   35, 'Each. A called shot at -3. Destroyed along with the head.', 2),
  ('bandito-tarantula-atv', 'Ion Turret (1)',                          100, 'A called shot at -3.', 3),
  ('bandito-tarantula-atv', 'Concealed Mini-Missile Launchers (2)',     50, 'Each. A called shot at -3, and they are REVEALED ONLY WHEN FIRING, which is the only time they can be struck.', 4),
  ('bandito-tarantula-atv', 'Escape Hatch (1; underbelly)',            100, 'A called shot at -3.', 5),
  ('bandito-tarantula-atv', 'Hatch (1; main, top)',                    100, 'A called shot at -3.', 6),
  ('bandito-tarantula-atv', 'Spines/Quills (many)',                      1, 'Each. A called shot at -3.', 7),
  ('bandito-tarantula-atv', 'Head (with sensors and optics)',          100, 'Destroying the head knocks out most sensors, optics, radar and targeting, as well as destroying the mandible rail guns.', 8),
  ('bandito-tarantula-atv', 'Headlights (4)',                            5, 'Each.', 9),
  ('bandito-tarantula-atv', 'Reinforced Pilot Compartment (Fore section)', 75, NULL, 10),
  ('bandito-tarantula-atv', 'Reinforced Crew/Passenger Area (Abdomen)',    75, NULL, 11),
  ('bandito-tarantula-atv', 'Fore Section: Main Body',                 200, 'ONE OF TWO MAIN BODIES the book prints for this vehicle. Depleting the M.D.C. of the main body will destroy it. Because there are two, the vehicles.mdc_main_body column is NULL rather than carrying an invented single figure.', 12),
  ('bandito-tarantula-atv', 'Abdomen/Rear Section: Main Body',         300, 'THE OTHER of the two main bodies. Depleting the M.D.C. of the main body will destroy it.', 13);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('bandito-sidewinder-samas', 1, 'MML 12 Mini-Missile Launchers (2)',
   'Varies with the missile used; any type of mini-missile can be used.', 1,
   'Varies with the missile used; usually about a mile (1.6 km).',
   'One at a time, or in volleys of 2 or 4.',
   '12 missiles in each "toaster", for a total of 24.',
   '+3 to strike from the armor''s targeting system, giving the missiles a total of +6 to strike.',
   'The two boxes on the shoulders, nicknamed the "Toasters" because they look like four-slice toasters turned sideways and because they "toast" an opponent. Primary purpose assault and anti-armor; secondary air defense and anti-missile. This is the Sidewinder''s punch against hardened positions and armored units.'),
  ('bandito-sidewinder-samas', 2, 'Arm Mounted Short-Range Lasers (2)',
   '2D6 M.D. per single blast or 4D6 per simultaneous dual blast from both arm weapons', 1,
   '1,200 feet (366 m)',
   'Equal to the combined number of attacks of the pilot. Each single or simultaneous double blast at the same target counts as one melee attack.',
   'Effectively unlimited.',
   '+1 to strike, from computer targeting and synchronized firing for dual simultaneous blasts at the same target.',
   'Mounted on each forearm, primarily anti-personnel. The dual blast is part of the Sidewinder''s special combat system.'),
  ('bandito-sidewinder-samas', 3, 'Hand-Held Weapons',
   'By the weapon carried.', 1, NULL, NULL, NULL, NULL,
   'Any hand-held weapon can be used, but the Bandit 6000 Grenade Launcher or the C-40R rail gun were intended to be standard issue.'),

  ('bandito-wild-weasel-samas', 1, 'WWECM 6 Black Boxes',
   'None.', 0, '100 mile (160 km) radius.', NULL, NULL, NULL,
   'Wild Weasel Electronic Counter-Measure Suite 6, in the boxes on the shoulders. Primary purpose electronic counter-measures; secondary air defense and anti-missile. Holds communications, scrambling, jamming, radar and targeting gear letting the Weasel act as a very advanced forward reconnaissance, tracking, targeting and communications relay unit, plus an anti-missile system that jams and scrambles the sensors of incoming missiles to make them miss. The full ability list is in the vehicle description.'),
  ('bandito-wild-weasel-samas', 2, 'Chaff-Flare Decoy',
   'None.', 0, NULL, 'One packet per firing.', 'Chaff-flare dispenser: 24.', NULL,
   'Fires flares with packets that release clouds of smoke and floating particles to lure missiles to them. Each chaff-flare packet fired has a 15% chance of decoying incoming enemy missiles, WITH CUMULATIVE EFFECT - 3 chaff-flares is 45%, 6 is 90%, and so on.'),
  ('bandito-wild-weasel-samas', 3, 'Arm Mounted Short-Range Plasma Ejectors (2)',
   '4D6 M.D. per single blast or 8D6 per simultaneous dual blast from both arm weapons', 1,
   '1000 feet (305 m)',
   'Equal to the combined number of attacks of the pilot. Each single or simultaneous double blast at the same target counts as one melee attack.',
   'Effectively unlimited.',
   '+1 to strike, from computer targeting and synchronized firing.',
   'Mounted on each forearm; a small laser, primarily anti-personnel, with greater damage capability than the Sidewinder''s lasers so as to destroy missiles that evade the jamming defense. THE RANGE IS RECOVERED FROM ITS OWN METRIC: printed 187 sets it as "1,00 feet (305 m)", a dropped digit, and 305 m is 1000 feet.'),
  ('bandito-wild-weasel-samas', 4, 'Hand-Held Weapons',
   'By the weapon carried.', 1, NULL, NULL, NULL, NULL,
   'Any hand-held weapon can be used, but the Bandit 6000 Grenade Launcher or the C-40R rail gun were intended to be standard issue.'),

  ('cslngr-mark-ii-super-slinger', 1, 'Vibro-Sabres (2)',
   '2D6 M.D. each', 1, 'Hand to hand.', 'As per hand to hand attacks.', NULL, NULL,
   'Retractable, in the forearms of one pair of arms. The ONLY built-in weapon system on this chassis. Printed as Vibro-Blades in the M.D.C. location block.'),

  ('cslngr-mark-iii-gringo', 1, 'Retractable Vibro-Blades (2)',
   '2D6 M.D. each', 1, 'Hand to hand.', 'As per hand to hand attacks.', NULL,
   '+1 to parry with them, from the chassis'' special bonuses.',
   'Vibro-Sabres located in the forearms. Primary purpose defense; secondary anti-personnel hand to hand combat. Each has 50 M.D.C.'),
  ('cslngr-mark-iii-gringo', 2, 'Chest Mounted Ion Blaster',
   '4D6 M.D. per blast', 1, '800 feet (244 m)',
   'Equal to the combined hand to hand attacks.', 'Effectively unlimited.',
   '+1 on initiative.',
   'A high-powered ion blaster capable of a very high damage yield, built into the chest. Primary purpose assault; secondary defense. One of two systems the Kid and the Super Slinger do not have.'),
  ('cslngr-mark-iii-gringo', 3, 'Shoulder Mounted Mini-Missile Launchers (2)',
   '1D4x10 M.D. each', 1, 'One mile (1.6 km).',
   'One at a time, or in volleys of 2, 4, 6 or 12.',
   '12 total; six in each launcher.', NULL,
   'Two six pack launching systems used for heavy support. Primary purpose assault; secondary anti-missile.'),
  ('cslngr-mark-iii-gringo', 4, 'Optional Use of Hand-Held Weapons',
   'By the weapon carried.', 1, NULL, NULL, NULL, NULL,
   'Any hand-held weapon can be used, from rail guns to laser rifles.'),

  ('bandito-tarantula-atv', 1, 'Mandible Rail Guns (2)',
   'A burst is 40 rounds and does 1D4x10 M.D. from a single barrel, or 2D4x10 M.D. from a double-barrel attack of 80 rounds. Typically fires flechette rounds.', 1,
   '4,000 feet (1220 m)',
   'Equal to the number of combined hand to hand attacks of the pilot, typically 4-6.',
   '2400 per gun, which is 60 single gun bursts each.', NULL,
   'The standard weapon of the Tarantula, aimed by turning and tilting the head: 360 degrees of turn and 180 degrees of tilt up and down, forward. Fired by the pilot (typically) or the gunner. Primary purpose assault; secondary defense. DESTROYED IF THE HEAD IS DESTROYED.'),
  ('bandito-tarantula-atv', 2, 'Bandito I88 Dual Ion Cannon (1)',
   '4D6 M.D. per single shot or 8D6 per simultaneous dual blast at the same target', 1,
   '1000 feet (305 m)',
   'Equal to the combined hand to hand attacks of the pilot or gunner.',
   'Effectively unlimited.', NULL,
   'The turret mounted gun on the back of the vehicle - a double-barreled turret capable of 360 degree rotation and 80 degree elevation or declination, used primarily against targets to the rear or sides. Typically fired by the gunner.'),
  ('bandito-tarantula-atv', 3, 'MML24 Mini-Missile System (2)',
   'As per mini-missile. The typical load is a mix of 12 plasma/napalm (1D6x10 M.D.) and 12 armor piercing (1D4x10 M.D.), but any type of mini-missile can be used.', 1,
   'About one mile (1.6 km).',
   'Volley of 2, 4 or 8 missiles.',
   '24 mini-missiles; 12 per launcher.', NULL,
   'The main anti-armor weapon. The rear abdomen houses two 12 pack launchers firing from the sides near the top; they are CONCEALED unless activated to fire, which is the only time they can be struck.'),
  ('bandito-tarantula-atv', 4, 'Hand to Hand Combat',
   'Punch or jab 2D4 M.D., swat 1D4 M.D., butt with head or body 1D6 M.D., stomp 2D6 M.D.', 1,
   'Hand to hand.', NULL, NULL, NULL,
   'The Tarantula was not designed for hand to hand combat, but it can use its front legs to punch, swat, poke and stomp opponents. Hand-held weapons are NOT applicable to this vehicle.');

-- INSERT OR IGNORE is SILENT on a collision, which is how a row goes missing
-- without an error, so these COUNT. Every want below is counted off the VALUES
-- lists in THIS FILE, not read back out of a database that has just loaded it.

SELECT 'the six vessels' AS assertion, count(*) AS got, 6 AS want
  FROM vehicles WHERE source_book LIKE '%New West%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 57 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%New West%';

SELECT 'their weapon entries' AS assertion, count(*) AS got, 16 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
  WHERE v.source_book LIKE '%New West%';

-- The Tarantula is the one with no single main body, and the two it does have
-- are asserted by VALUE, because leaving that column NULL is a decision and a
-- later well-meaning backfill would be the worst way to discover it.
SELECT 'exactly one vessel has no single main body' AS assertion, count(*) AS got, 1 AS want
  FROM vehicles WHERE source_book LIKE '%New West%' AND mdc_main_body IS NULL;

SELECT 'and it carries BOTH printed main bodies as locations' AS assertion, count(*) AS got, 2 AS want
  FROM vehicle_locations
  WHERE vehicle_slug = 'bandito-tarantula-atv' AND location LIKE '%Main Body%'
    AND mdc IN (200, 300);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-nw-vessels-p183-195.sql');
