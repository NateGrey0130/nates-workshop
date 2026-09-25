-- South America vessels: the 19 vehicles, robots, power armors and ships of
-- Rifts World Book 6: South America. 19 vehicles, 150 M.D.C. locations,
-- 61 weapon entries.
--
--   Republic of Colombia, printed 25-34: D-20, D-30 Conquistador, G-9A Jaguar,
--     G-18B Aguirre, Lancero, Zancudo
--   Kingdom of Lagarto (Kittani), printed 79-85: Raptor, Allosaurus
--     "Firedrake", Tyrannosaurus
--   Manoa, printed 92-97: Hoplite, Lictor
--   Cibola, printed 141-143: Dragon Death, FP-10 Flying Platform
--   Ships, printed 152-159: Slaver Raider, Slaver Mothership, Corsair
--     Hydrobike, Piranha, Black Galleon
--   Nightmare Island, printed 165-167: the Demon Black Ship
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-south-america-vessels.sql
--
-- The book has a TEXT LAYER; offset +1, so printed N is cache p(N+1). Extracted
-- in three slices by book-extract-worker and checked by book-reconcile.
--
-- PAGES READ OFF A RENDER, NOT THE CACHE:
--
--   printed 25   the D-20's weight sets as "ISOlbs"; the ink is 180 lbs, and
--                81.5 kg agrees.
--   printed 81   on this book's substituted-digit list: the Raptor's leap
--                kick "!D4xlO" is 1D4x10.
--   printed 159  the welded page: the Black Galleon's last three weapon
--                systems run into the next section in the text layer.
--
-- THREE BOOK SLIPS, stored as printed and noted on the row: the Lictor's laser
-- fingers "2000 feet (610 km)", the Black Galleon's speed "50 mph (80 mph)",
-- and the Galleon's rocket auto-cannon pair given one figure with no "each".
--
-- PRICES. Following the Spirit West and Underseas vessels, a figure the book
-- gives only as what a machine WOULD fetch is an estimate, not a price: the
-- Slaver Raider, the Mothership and the Black Ship have cost NULL with the
-- figure in cost_note. The three Kittani machines ARE sold, to Splugorth
-- allies, so their prices are stored. A range stores its low end.
--
-- THE BLACK SHIP HAS NO mdc_main_body. The book splits the hull into front,
-- mid-ship and rear sections, each of which sinks the ship when depleted, and
-- names no main body; those are location rows.
--
-- The Hoplite's optional abilities, the Lancero's three variants and every
-- robot's hand to hand table are in the description, not in vehicle_weapons,
-- which holds the fixed weapon systems. The RAR-C15 the D-20 carries is also a
-- gear row (add-south-america-gear.sql).
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('d-20-light-combat-exo-skeleton', 'D-20 Light Combat Exo-Skeleton', 'rifts', 'power-armor', 'One', NULL, 'Running 50 mph (80 km) maximum; tires the pilot at 20% of the normal rate. Leaps 10 feet (3 m) high or lengthwise, double from a running start.', 'Not possible', NULL, 'Height 7 feet (2.1 m), width 3 feet (0.9 m), length 3 feet (0.9 m)', '180 lbs (81.5 kg)', 150, 150000, '150,000 credits.', 'Model D-20, Armored Infantry Assault Suit (Light): the Republic of Colombia''s light exo-skeleton. P.S. equal to 24; no cargo. Battery powered: a 12-hour charge gives up to 600 miles (960 km) in a straight line, typically 100-200 miles (160-320 km) in practice; recharging takes 4 hours from any power plant, and one generator charges five suits at once. A drained suit has one attack per melee, no combat bonuses and speed 2, and takes two minutes to get out of. Hand to hand is Power Armor Combat Training (Rifts RPG); no separate table is printed. The weight is read off a render; the text layer sets it "ISOlbs".', 'Rifts World Book 6: South America p.25-27'),
  ('d-30-conquistador-power-armor', 'D-30 "Conquistador" Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running 60 mph (96 km) maximum; tires the pilot at 10% of the normal rate. Leaps 12 feet (3.65 m) high or lengthwise, double from a running start.', 'Not possible', NULL, 'Height 10 feet (3.0 m), width 6 feet (1.8 m), length 5 feet (1.5 m)', '900 lbs (408 kg)', 230, 240000, '240,000 credits.', 'Model D-30 Armor Suit, Armored Infantry Assault Suit: Colombia''s standard power armor. P.S. equal to 30; no cargo. Battery powered, a 10-hour charge from any power plant, about 600 miles (960 km) at most and 100-200 miles (160-320 km) in practice. Hand to hand is the Robot Combat section of Power Armor Combat Training (Rifts RPG); no table is printed.', 'Rifts World Book 6: South America p.27-28'),
  ('g-9a-jaguar-light-robot', 'G-9A "Jaguar" Light Robot Vehicle', 'rifts', 'robot', 'One pilot', 'Up to three', 'Running 90 mph (144 km) maximum. Leaps 20 feet (6.1 m) high or across, +10 feet (3.0 m) from a running start.', NULL, NULL, 'Height 21 feet (6.4 m), width 11 feet (3.4 m), length 7 feet 2 inches (2.2 m)', '18 tons (16,200 kg) fully loaded', 320, 25000000, '25 million credits.', 'Model G-9A, Ground Infantry Assault Robot: Colombia''s light combat robot, with clawed hands. P.S. equal to 40; about 4 feet (1.2 m) of storage. Nuclear, average energy life 20 years. Hand to hand: +1 attack per melee at levels 1, 3, 7 and 12; +1 initiative, +1 to strike, +2 to parry, dodge, pull punch and roll with impact. Restrained punch 1D4 M.D., full strength punch 2D6 M.D., claw strike 4D6 M.D., power punch 4D6 M.D. and power claw strike 6D6 M.D. (each counts as two attacks), kick 2D4 M.D., leap kick 3D6 M.D. (two attacks), stomp or body flip 1D4 M.D.', 'Rifts World Book 6: South America p.29'),
  ('g-18b-aguirre-heavy-combat-robot', 'G-18B "Aguirre" Heavy Combat Robot', 'rifts', 'robot', 'One pilot', 'Up to four', 'Running 60 mph (96 km). Leaps 15 feet (4.6 m) high or across, +10 feet (3.0 m) from a running start.', NULL, NULL, 'Height 27 feet (8.2 m), width 15 feet (4.6 m), length 10 feet (3.0 m)', '21 tons (19,407 kg) fully loaded', 380, 30000000, '30 million credits.', 'Model G-18B, Ground Infantry Assault Robot: Colombia''s heavy combat robot, carrying a 20 foot (6.1 m) vibro-sword magnetically clamped to its back. P.S. equal to 44; about 4 feet (1.2 m) of storage. Nuclear, average energy life 15 years. Hand to hand: +1 attack per melee at levels 1, 4, 8 and 12; +1 to strike (+3 with the sword), +3 to parry (+5 with the sword, and +1 to parry energy blasts), +2 to dodge and pull punch, +3 to roll with impact. Restrained punch 1D6 M.D., full strength punch 3D6 M.D., power punch 1D6x10 M.D., kick 2D6 M.D., leap kick 4D6 M.D., stomp or body flip 1D6 M.D.', 'Rifts World Book 6: South America p.31'),
  ('lancero-light-tank-apc', 'Lancero Light Tank/APC', 'rifts', 'vehicle', 'Four: pilot, co-pilot, communications engineer and gunner', 'LTT-100A: up to 10 troopers in body armor or light exo-skeletons, or 6 in Conquistador or heavy power armor, or 4 of each. LTT-100B: a smaller bay, up to 5 in body armor or 3 in power armor. LTT-100V: three human-sized passengers.', '80 mph (128 km)', NULL, '15 mph (24 km)', 'Height 12 feet (3.7 m), width 12 feet (3.7 m), length 21 feet (6.4 m)', '14 tons (12,698 kg) fully loaded', 300, 2100000, '2.1 million credits.', 'Models LTT-100A, LTT-100B and LTT-100V, Infantry Assault and Transport Vehicle: Colombia''s six-wheeled light tank and armored personnel carrier on balloon tires, usually in camouflage, green or dark grey. Type V is the anti-vampire model, trading the 120 mm cannon for a water cannon and most of its bay for the water tank. Gasoline turbine engine, range 600 miles (965 km). The troop bay carries up to 5 tons (4,500 kg) as a transport (Type V about 1 ton), plus about 4 feet (1.2 m) of storage for four rifles, a rocket launcher and 12 mini-missiles.', 'Rifts World Book 6: South America p.31-33'),
  ('zancudo-transport-attack-helicopter', 'Zancudo Transport & Attack Helicopter', 'rifts', 'vehicle', 'Two: pilot and co-pilot/gunner', 'Six in light power armor, or 10 infantry in body armor; up to 5 tons (4,500 kg) of cargo can replace the troops.', NULL, '200 mph (320 km), full VTOL; range 450 miles (720 km)', NULL, 'Height 16 feet (4.9 m), width 15 feet (4.6 m) and 55 feet (16.8 m) across the top rotor, length 70 feet (21.3 m)', '12 tons (10,800 kg) fully loaded', 250, 400000, '400,000 credits.', 'Model CH-1000, combat assault and transport helicopter, Republic of Colombia. Cargo and ambulance variants share the stats with the missiles removed. Gasoline engine. About 3 feet (0.9 m) of storage for personal effects behind the pilots'' seats.', 'Rifts World Book 6: South America p.33-34'),
  ('kittani-raptor-power-armor', 'Kittani Raptor', 'rifts', 'power-armor', 'One', NULL, 'Running 150 mph (240 km) maximum, cruising 60 mph (96 km). Leaps 40 feet (12.2 m) up or lengthwise standing; 60 feet (18.3 m) high or 120 feet (36.6 m) long running; thruster-assisted 200 feet (61 m) long or 100 feet (30.5 m) high.', 'Not possible', 'Swimming 20 mph (32 km), 40 mph (64 km) thruster-assisted', 'Height 10 feet (3.0 m), width 6 feet (1.8 m), length 24 feet (7.3 m)', '1 ton (907 kg)', 350, 30000000, '30 million credits. Sold only to Splugorth allies such as the New Dragcona government, never on the open market.', 'Model Kittani RPA, Heavy Infantry Environmental Exo-Skeleton: a velociraptor-shaped Kittani power armor of the "Carnosaurus" series built for the Kingdom of Lagarto; fully field tested and ready for mass production. P.S. equal to 35; no cargo. Nuclear, 20-year life. Favored tactic: grapple or bite, then fire the head lasers point-blank. Hand to hand: +1 attack per melee at levels 1, 4 and 9; +3 initiative, +3 to strike and parry (+4 to strike with a leap kick), +3 automatic dodge (costs no melee action), +2 to roll with impact. Restrained punch 1D4 M.D., full strength punch 2D6 M.D., power punch 4D6 M.D. (two attacks), kick 4D6 M.D., slashing claw kick 5D6 M.D., leap kick 1D4x10 M.D. (two attacks), slashing claw leap kick 1D6x10 M.D. (two attacks), tail strike 4D6 M.D., bite 4D6 M.D. The leap kick is read off a render; the text layer prints it "!D4xlO".', 'Rifts World Book 6: South America p.79-81'),
  ('kittani-allosaurus-firedrake-power-armor', 'Kittani Allosaurus "Firedrake" Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running 100 mph (160 km) maximum. Leaps 15 feet (4.6 m) unassisted; thruster-assisted up to 50 feet (15.2 m) high or 100 feet (30.5 m) long.', 'Not possible', 'Swimming 15 mph (24 km), 30 mph (48 km) assisted', 'Height 17 feet (5.2 m), width 10 feet (3.0 m) with weapon turrets, length 30 feet (9.1 m)', '3 tons (2,700 kg)', 475, 50000000, '50 million credits. Sold only to Splugorth allies such as the New Dragcona government, never on the open market.', 'Model Kittani APA, Strategic Mobile Assault Suit: an allosaurus-shaped Kittani power armor, an experimental prototype. Its mouth plasma projector earned the "Firedrake" name, and it is a favorite of dragons. P.S. equal to 48. Cargo: a small area for personal items and a weapon bin (one rifle, one pistol, canteen, rations). Nuclear, about 20 years. Hand to hand: +1 attack per melee at levels 1, 5 and 10; +2 initiative, +2 to strike and parry, +1 to dodge and roll with impact. Restrained punch 1D6 M.D., full strength punch 5D6 M.D., power punch 1D6x10 M.D. (two attacks), kick 5D6 M.D., leap kick 1D6x10 M.D. (two attacks), tail strike 5D6 M.D., bite 1D4x10 M.D., head butt 2D6 M.D., stomp 2D6 M.D. (only against targets 8 feet/2.4 m or smaller).', 'Rifts World Book 6: South America p.82-83'),
  ('kittani-tyrannosaurus-robot-vehicle', 'Kittani Tyrannosaurus', 'rifts', 'robot', 'Two: pilot and co-pilot/gunner', 'Two human-sized passengers', 'Running 80 mph (128.7 km) maximum', 'Not possible', NULL, 'Height 28 feet 9 inches (8.8 m), width 16 feet 4 inches (5.0 m) shoulder to shoulder, length 40 feet (12.2 m)', '30 tons (27,210 kg)', 600, 100000000, '100 million credits. Sold only to Splugorth allies such as the New Dragcona government, never on the open market.', 'Kittani TRV, Strategic Assault Robot Vehicle: a tyrannosaurus-shaped Kittani robot, an experimental prototype. P.S. equal to 60. Cargo: about 4 feet (1.2 m) of storage and a weapons locker (two energy rifles, two energy pistols, two canteens, two weeks'' rations). Nuclear, about 20 years. Its small arms reach only about 6 feet (1.8 m); legs, tail and maw are its real weapons. Hand to hand: +1 attack per melee at levels 1 and 7; +2 to strike and parry, +1 to dodge. Restrained punch 1D6 M.D., full strength punch, tear or rip 5D6 M.D. (point-blank only), no power punch or leap kick, kick 1D6x10 M.D., tail strike 1D4x10 M.D. (25 foot/7.6 m reach), head butt 3D6 M.D., bite 1D6x10+10 M.D., stomp 4D6 M.D. (only against 10 feet/3.0 m or smaller). Body ram after a short run: 1D6x10 M.D. and a 75% chance to knock down a truck-sized foe (95% against man-sized to 15 feet, motorcycles and small cars), who loses initiative and one attack and is thrown 2D6 yards (x10 for a human-sized victim, who loses two attacks); counts as two attacks.', 'Rifts World Book 6: South America p.83-85'),
  ('hoplite-power-armor', 'Hoplite Power Armor', 'rifts', 'power-armor', 'One, usually a human or True Atlantean, occasionally an Amazon', NULL, 'Running 60 mph (96 km) maximum; tires the operator at 20% of the usual rate. Leaps 20 feet (6 m) lengthwise and 12 feet (3.6 m) high.', 'Not available in standard models', 'Swimming 5 mph (8 km)', 'Height 9 feet (2.7 m) to the helmet crest, width 4 feet (1.2 m), length 3 feet (0.9 m)', '600 lbs (270 kg)', 300, 60000000, '60 million credits.', 'Model M-100 Hoplite, Techno-Wizard Armored Assault Suit of Manoa: a giant metal Greek warrior in Spartan hoplite armor with cuirass, greaves and crested helmet, issued with an oblong shield and an energy spear. A golem-like TW shell closes around the pilot. Supernatural P.S. 26. All standard power armor sensors and communications, plus tongues, breathe without air, impervious to normal fire, and an Armor of Ithan force field. Magical power: 96 hours of continuous use, then recharge in a stone pyramid (four hours; 24 hours'' worth per hour) or at a ley line or nexus. BOOK DISCREPANCY: printed 92 says a ley line takes three times as long (about 12 hours); the Power System line on printed 94 says eight hours. It self-repairs 75 M.D.C. per hour at a pyramid or 37 at a ley line, but not once the main body is depleted. Hand to hand: +1 attack per melee at levels 1, 5 and 10; +1 initiative, +1 to strike and parry, +2 to dodge, pull punch and roll with impact; restrained punch 5D6 S.D.C., full strength punch or kick 3D6 M.D., power punch or leap kick 6D6 M.D. (two actions). It may carry one or two conventional weapons sized for a 9 foot humanoid. Officers, heroes and elite squads may take up to two OPTIONAL abilities, replacing spear, shield or eye lasers: six throwable returning shoulder or forearm spikes per side (3D6 M.D. each), a TW magic net, TW fire gauntlets (1D4x10 S.D.C., 3D6 M.D. or 5D6 M.D.), a TW ankh mace (3D6 M.D. to the undead; Turn Dead and Banishment), a TW flaming sword or other magic weapon, magic senses, magic communication, Fly as the Eagle (two hours a day), underwater magic, jungle cloaking (Chameleon), or a super energy damper (Impervious to Energy at will; counts as two choices).', 'Rifts World Book 6: South America p.92-95'),
  ('lictor-assault-robot', 'Lictor Assault Robot', 'rifts', 'robot', 'Two: pilot and co-pilot/gunner, usually human or True Atlantean, occasionally an Amazon', NULL, 'Running 45 mph (72 km) maximum. Leaps 30 feet (9.1 m) lengthwise or 20 feet (6.1 m) high.', 'Up to 50 mph (64 km) by spell, at most two hours in 24, which may be split; then no flight for 24 hours or until 20 minutes of recharging at a pyramid', 'Swimming 10 mph (16 km)', 'Height 30 feet (9.1 m), width 15 feet (4.6 m), length 9 feet (2.7 m)', '30 tons (27,000 kg) fully loaded', 400, 80000000, '80 million credits.', 'Model L-100 Lictor, Techno-Wizard Strategic Assault Robot: the Hoplite''s larger cousin and the biggest war machine Manoa fields. Supernatural P.S. 32. All standard robot sensors and communications, plus tongues, breathe without air, impervious to normal fire, and a magical force field; a small area for the pilots'' personal items. Magical power: 72 hours of continuous use, then recharge at a pyramid (an hour per day''s worth) or ley line (two hours per day''s worth), self-repairing like the Hoplite. Hand to hand: +1 attack per melee at levels 1, 6 and 11; +1 initiative, +1 to strike, parry and dodge (+3 to dodge in flight), +1 to pull punch and roll with impact; restrained punch 5D6 S.D.C., full strength punch or kick 4D6 M.D., power punch or leap kick 1D4x10+8 M.D. It may carry one or two conventional weapons sized for 30 foot giants, and takes the same optional abilities as the Hoplite, giant-sized.', 'Rifts World Book 6: South America p.95-97'),
  ('dragon-death-power-armor', 'Dragon Death Power Armor', 'rifts', 'power-armor', 'One', NULL, 'Running 100 mph (160 km) maximum, at 20% of the normal fatigue rate. Leaps 20 feet high or 30 feet lengthwise unassisted.', 'Hover up to 200 feet; 300 mph (480 km) maximum, 150 mph (240 km) cruising, altitude about 4000 feet (1220 m). The jets need cooling after 10 hours above cruising speed or 24 at cruise; indefinite with rest stops.', NULL, 'Height 30 feet (9.1 m), width 16 feet (4.9 m), length 9 feet (2.7 m)', '20 tons (18,000 kg) fully loaded', 350, 6000000, 'Six to twelve million credits; sold in transdimensional markets everywhere.', 'Model DD-1000, Strategic Armor Military Assault Suit: Cibolan power armor designed for the 18-24 foot Pogtalian dragon slayers and usable by other giants; the pilot can do everything in it but bite. No cargo. Nuclear, about 25 years. Hand to hand, in addition to supernatural strength damage: +1 attack per melee at levels 1, 6 and 11; +1 initiative, +2 to strike and parry, +1 to dodge (+3 flying), +1 to roll with impact. Full strength punch 1D6 M.D., power punch 2D6 M.D. (two attacks), claw strike 2D6 M.D. (added to a punch), kick 2D6 M.D., leap kick 3D6 M.D., jet-assisted body slam or ram 1D6 M.D.', 'Rifts World Book 6: South America p.141-142'),
  ('cibolan-flying-platform-fp-10', 'Cibolan Flying Platform (FP-10)', 'rifts', 'vehicle', 'One', 'Comfortably one or two; up to four cramped, which puts the pilot''s skill at -15% and every attack from the platform at -3', 'Not possible; hovers as low as 3 feet (0.9 m)', '200 mph (320 km); maximum altitude 500 feet (152 m)', NULL, '1 foot (0.3 m) thick, 6 feet (1.8 m) high with railings; width 9 feet (2.7 m), length 10 feet (3.0 m)', '600 lbs (270 kg)', 85, 400000, '400,000 credits without weapons, 600,000 with.', 'Model FP-10, Light Weapon Platform/Air Vehicle: an open, railed flying platform built in Cibola. Personal items are lashed to the railing. Nuclear, about 10 years.', 'Rifts World Book 6: South America p.142-143'),
  ('splugorth-slaver-raider', 'Splugorth Slaver Raider', 'rifts', 'ship', '22: captain, two pilots, navigator, two communications and two sensor officers, three petty officers, four weapons officers and seven sailors', 'Typically a company of 64 armored troops, plus 12 Splugorth Slavers on flying barges and 60 Blind Warrior Women', '40 mph (64 km) on land', NULL, 'Hydrofoil 100 mph (160 km); hovercraft 400 mph (640 km), calm water only', 'Height 55 feet (16.8 m), width 65 feet (19.8 m), length 200 feet (61 m)', '5,000 tons (4.5 million kg)', 2500, NULL, 'Almost impossible to find. Printed 153 says one fully armed and loaded would cost 500 million credits - an estimate, not a price.', 'Model Kittani KY-HSS, Hydrofoil/Hovercraft Assault Ship: a Kittani and Kydian-built slave raider of the Splugorth. It holds up to 800 captives in 100 reinforced cells (uncomfortable past four a cell), often pacified with zombitron parasites, drugs or shackles, and up to 500 tons (450,000 kg) of loot. Nuclear, about 25 years.', 'Rifts World Book 6: South America p.152-154'),
  ('splugorth-slaver-mothership', 'Splugorth Slaver Mothership', 'rifts', 'ship', '100 officers and 1,200 ship crew, plus a defense force: 960 Kittani warriors in Manling power armor with jet packs, 240 Overlords in Overlord power armor, 240 Blind Warrior Women, 60 Splugorth Slavers, 60 Powerlords in power armor, a special operations squad of six Conservators, and 4-6 Murex or Volute Metzla, led by 2-8 High Lords', 'About 700 more troops aboard its eight embarked Slaver Raiders; up to 20,000 slaves in 1,000 reinforced cells on four deck levels', 'Not possible', NULL, '40 mph (64 km) surfaced, 20 mph (32 km) submerged', 'Height 400 feet (122 m), 100 feet (30.5 m) of it the four support pillars; width 800 feet (244 m), length 800 feet (244 m)', '300,000 tons (270 million kg)', 28000, NULL, 'Never sold. Printed 154 says it would go for 100 billion credits or more - an estimate, not a price.', 'Model Kittani KSM-100, Dreadnought Combat Ship: the Splugorth''s floating slave fortress, carrying eight Slaver Raiders and over a thousand warriors, monsters and wizards who can defend it or attack other targets. Nuclear, about 20 years.', 'Rifts World Book 6: South America p.154-156'),
  ('corsair-hydrobike', 'Corsair Hydrobike', 'rifts', 'vehicle', 'One', 'One, behind the pilot', 'Not possible', NULL, '60 mph (96 km)', 'Height 5 feet (1.5 m), width 3 feet (0.9 m), length 8 feet (2.4 m)', '600 lbs (270 kg)', 126, 20000, '20,000-30,000 credits depending on seller and availability.', 'Model CHB-5, Personal Amphibious Assault Vehicle: a fast, quiet water bike popular with pirates, river adventurers, raiders and spies. A small watertight briefcase-sized compartment. Gasoline.', 'Rifts World Book 6: South America p.156-157'),
  ('piranha-submersible-attack-boat', 'Piranha Submersible Attack Boat', 'rifts', 'ship', 'Four: pilot, co-pilot/gunner, communications and sensor officer, engineer', 'Up to 20 passengers or troops', NULL, NULL, '40 mph (64 km) surfaced or underwater; 80 mph (128 km) on its hydrofoils', 'Height 25 feet (7.6 m), width 21 feet (6.4 m), length 100 feet (30.5 m)', '60 tons (54,000 kg)', 600, 300000000, '300 million credits; very hard to find.', 'Model PTB-20AB, Submersible Attack Boat: one of the last pre-Rifts designs still in service; every surviving boat is held by pirates, smugglers or adventurers, and Colombia and the Silver River Republics both want one to copy. Up to 4 tons (3,600 kg) of cargo. Nuclear, about 20 years.', 'Rifts World Book 6: South America p.157-158'),
  ('black-galleon-gunboat', '"Black Galleon" Gunboat', 'rifts', 'ship', 'Six: pilot, captain, two gunners, a communications and sensor officer, an engineer', 'Up to 20 passengers or soldiers', NULL, NULL, '50 mph (80 mph) as printed; the parenthesis gives mph where the book everywhere else converts to km', 'Height 21 feet (6.4 m), width 10 feet (3.0 m), length 40 feet (12.2 m)', '120 tons (109,000 kg)', 900, 400000, '400,000 credits.', 'Model GB-30C, patrol boat: the ship of the line of the Republic of Colombia''s navy, 72 in active service; wealthy merchants buy modified cargo versions. About 10 tons (9,000 kg) of cargo. Diesel engine. Its last three weapon systems sit on printed 159, a page the text layer welds into the next section; they were read off a render.', 'Rifts World Book 6: South America p.158-159'),
  ('demon-black-ship', 'Demon Black Ship', 'rifts', 'ship', '16-40 demons and 40-120 skeletons or zombies; 30-80 living humans and D-bees, at least 10 of them Kittani mercenaries in Manling power armor; two 8th-10th level magicians, shifters or summoners, eight 3rd-6th level summoners and six 3rd-6th level diabolists. A typical demon crew is eight greater demons (four Baal-rogs, two Green and two White Jinn) and 24 lesser (eight Aquatics, two Succubus/Incubus, seven Gurgoyles, seven Gargoyles); six of the twelve ships also carry a 4th-6th level gargoyle lord or mage, and Kharkon''s flagship a stronger crew', NULL, NULL, NULL, 'Sail 16 mph (26 km); mystic propulsion 32 mph (51 km); 70 mph (112.6 km) along ley lines', 'Width 30 feet (9.1 m), length 180-220 feet (55-67.1 m); no height printed', '100 tons (90,000 kg)', NULL, NULL, 'Printed 166 says Kharkon would ask no less than 10 billion credits if he ever sold one, which is highly unlikely - an estimate, not a price.', 'Demon Black Ship, Magic Warship: the demonic sailing vessels of Kharkon''s fleet on Nightmare Island. Twelve came through the Rifts to Earth; eight more are being built, five finishable within 1D6 months, by knowledge found only on Kharkon''s homeworld and the Palladium World. Sail or magic: mystic propulsion costs 100 P.P.E. an hour (often fueled by sacrificed prisoners), or 20 on a ley line, where it makes 70 mph against wind and current. It regenerates 100 M.D.C. per 24 hours, 200 at a ley line or in the Bermuda Triangle. 20 tons (18,000 kg) of cargo. Beyond its guns and ram, the practitioners aboard cast spells, especially against boarders, and the demon crew board, fly or swim to attack other vessels and intercept missiles and torpedoes. The book gives no single main body: the front, mid-ship and rear sections each sink the ship when depleted.', 'Rifts World Book 6: South America p.165-167');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('d-20-light-combat-exo-skeleton', 'Arms (2)', 50, 'Each.', 1),
  ('d-20-light-combat-exo-skeleton', 'Rocket Gun (1)', 50, NULL, 2),
  ('d-20-light-combat-exo-skeleton', 'Backpack Magazine Dispenser', 100, NULL, 3),
  ('d-20-light-combat-exo-skeleton', 'Head', 60, 'Destroying it has a 01-70% chance of knocking the pilot unconscious; if conscious, the pilot loses the power armor combat bonuses and the head is exposed. Called shot only, at -3 to strike.', 4),
  ('d-20-light-combat-exo-skeleton', 'Main Body', 150, 'Depleting it shuts the armor down completely.', 5),
  ('d-20-light-combat-exo-skeleton', 'Legs (2)', 60, 'Each.', 6),
  ('d-30-conquistador-power-armor', 'Arms (2)', 80, 'Each.', 1),
  ('d-30-conquistador-power-armor', 'Legs (2)', 100, 'Each.', 2),
  ('d-30-conquistador-power-armor', 'Mini-Missile Launchers (2; forearms)', 35, 'Each.', 3),
  ('d-30-conquistador-power-armor', 'Hand-held Auto-loading Bazooka', 80, NULL, 4),
  ('d-30-conquistador-power-armor', 'Shoulder Rocket Gun', 40, NULL, 5),
  ('d-30-conquistador-power-armor', 'Backpack Ammo Dispenser', 120, NULL, 6),
  ('d-30-conquistador-power-armor', 'Head', 95, 'As the D-20: 01-70% chance of knocking the pilot unconscious, and the head is exposed. Called shot only, at -3 to strike.', 7),
  ('d-30-conquistador-power-armor', 'Main Body', 230, 'Depleting it shuts the armor down completely.', 8),
  ('g-9a-jaguar-light-robot', 'Shoulder Missile Launchers (2)', 100, 'Each.', 1),
  ('g-9a-jaguar-light-robot', 'Eye Laser Cannons (2)', 25, 'Each. Small: Called shot only, at -2 to strike.', 2),
  ('g-9a-jaguar-light-robot', '20 mm Auto-cannon in Left Arm', 120, NULL, 3),
  ('g-9a-jaguar-light-robot', 'Head', 100, NULL, 4),
  ('g-9a-jaguar-light-robot', 'Hands (2)', 60, 'Each.', 5),
  ('g-9a-jaguar-light-robot', 'Arms (2)', 150, 'Each.', 6),
  ('g-9a-jaguar-light-robot', 'Legs (2)', 220, 'Each.', 7),
  ('g-9a-jaguar-light-robot', 'Main Body', 320, 'Depleting it shuts the robot down completely.', 8),
  ('g-9a-jaguar-light-robot', 'Reinforced Pilot''s Compartment', 100, NULL, 9),
  ('g-18b-aguirre-heavy-combat-robot', 'Giant Vibro-Sword', 200, NULL, 1),
  ('g-18b-aguirre-heavy-combat-robot', 'Belly Rocket Auto-cannon', 150, NULL, 2),
  ('g-18b-aguirre-heavy-combat-robot', 'Shoulder Missile Launchers (2)', 140, 'Each.', 3),
  ('g-18b-aguirre-heavy-combat-robot', 'Forearm Lasers (2)', 90, 'Each.', 4),
  ('g-18b-aguirre-heavy-combat-robot', 'Head', 100, NULL, 5),
  ('g-18b-aguirre-heavy-combat-robot', 'Hands (2)', 50, 'Each.', 6),
  ('g-18b-aguirre-heavy-combat-robot', 'Arms (2)', 160, 'Each.', 7),
  ('g-18b-aguirre-heavy-combat-robot', 'Legs (2)', 240, 'Each.', 8),
  ('g-18b-aguirre-heavy-combat-robot', 'Main Body', 380, 'Depleting it shuts the robot down completely.', 9),
  ('g-18b-aguirre-heavy-combat-robot', 'Reinforced Pilot''s Compartment', 100, NULL, 10),
  ('lancero-light-tank-apc', 'Main Turret and Cannon', 200, NULL, 1),
  ('lancero-light-tank-apc', 'Side Mini-Missile Launchers (2)', 40, 'Each.', 2),
  ('lancero-light-tank-apc', 'Front-mounted Rocket Machinegun', 100, NULL, 3),
  ('lancero-light-tank-apc', 'Back Ramp Door', 200, NULL, 4),
  ('lancero-light-tank-apc', 'Balloon Tires (6)', 40, 'Each.', 5),
  ('lancero-light-tank-apc', 'Main Body', 300, 'Depleting it shuts the tank down completely.', 6),
  ('lancero-light-tank-apc', 'Reinforced Pilot''s Compartment', 100, NULL, 7),
  ('zancudo-transport-attack-helicopter', 'Four-Blade Top Rotor', 60, 'Destroying it crashes the helicopter in 1D4 melee rounds.', 1),
  ('zancudo-transport-attack-helicopter', 'Rear Rotor', 50, 'Destroying it costs control: piloting rolls at -40%, and it must land immediately.', 2),
  ('zancudo-transport-attack-helicopter', 'Mini-Missile Launchers (4)', 100, 'Each.', 3),
  ('zancudo-transport-attack-helicopter', 'Auto-cannon in Belly Turret', 100, NULL, 4),
  ('zancudo-transport-attack-helicopter', 'Main Body', 250, 'Depleting it destroys the helicopter, which crashes.', 5),
  ('zancudo-transport-attack-helicopter', 'Reinforced Pilots'' Compartment', 150, NULL, 6),
  ('kittani-raptor-power-armor', 'Concealed Shoulder Missile Launchers (2)', 100, 'Each.', 1),
  ('kittani-raptor-power-armor', 'Arms/Laser Mounts (2)', 80, 'Each.', 2),
  ('kittani-raptor-power-armor', 'Clawed Hands (2)', 35, 'Each.', 3),
  ('kittani-raptor-power-armor', 'Hip Thrusters', 75, 'Each.', 4),
  ('kittani-raptor-power-armor', 'Legs (2)', 160, 'Each.', 5),
  ('kittani-raptor-power-armor', 'Clawed Feet (2)', 90, 'Each.', 6),
  ('kittani-raptor-power-armor', 'Tail', 120, 'Destroying it: -1 to strike, parry and dodge, and running speed and leaping distance are reduced by a third.', 7),
  ('kittani-raptor-power-armor', 'Head', 130, 'Destroying it loses all optical and sensory systems and all power armor combat bonuses. A small target: Called shot only, at -4 to strike.', 8),
  ('kittani-raptor-power-armor', 'Main Body', 350, 'Depleting it shuts the armor down completely.', 9),
  ('kittani-allosaurus-firedrake-power-armor', 'Mini-Missile Launchers (2; side-back)', 120, 'Each.', 1),
  ('kittani-allosaurus-firedrake-power-armor', 'Tri-Barrel Super Rail Gun Arms (2)', 150, 'Each.', 2),
  ('kittani-allosaurus-firedrake-power-armor', 'Arms (2)', 100, 'Each.', 3),
  ('kittani-allosaurus-firedrake-power-armor', 'Clawed Hands (2)', 50, 'Each.', 4),
  ('kittani-allosaurus-firedrake-power-armor', 'Chest Medium-Range Missile Launcher', 160, NULL, 5),
  ('kittani-allosaurus-firedrake-power-armor', 'Legs (2)', 200, 'Each.', 6),
  ('kittani-allosaurus-firedrake-power-armor', 'Clawed Feet (2)', 110, 'Each.', 7),
  ('kittani-allosaurus-firedrake-power-armor', 'Tail', 200, 'Destroying it: -1 to strike, parry and dodge, and running and leaping are reduced by a third.', 8),
  ('kittani-allosaurus-firedrake-power-armor', 'Head', 120, 'Destroying it loses optical and sensory systems and the power armor combat bonuses. Called shot only, at -2 to strike.', 9),
  ('kittani-allosaurus-firedrake-power-armor', 'Main Body', 475, 'Depleting it shuts the armor down completely.', 10),
  ('kittani-tyrannosaurus-robot-vehicle', 'Shoulder Medium-Range Missile Launchers (2)', 300, 'Each.', 1),
  ('kittani-tyrannosaurus-robot-vehicle', 'Belly Rail Gun Turret', 120, NULL, 2),
  ('kittani-tyrannosaurus-robot-vehicle', 'Concealed Mini-Missile Launchers (2)', 100, 'Each.', 3),
  ('kittani-tyrannosaurus-robot-vehicle', 'Side Twin-Barrel Pulse Cannons (2)', 150, 'Each.', 4),
  ('kittani-tyrannosaurus-robot-vehicle', 'Arms (2; small)', 130, 'Each.', 5),
  ('kittani-tyrannosaurus-robot-vehicle', 'Clawed Two-Finger Hands (2)', 50, 'Each.', 6),
  ('kittani-tyrannosaurus-robot-vehicle', 'Legs (2)', 300, 'Each.', 7),
  ('kittani-tyrannosaurus-robot-vehicle', 'Tail', 320, 'Destroying it: -1 to strike, parry and dodge, and running and leaping are reduced by a third.', 8),
  ('kittani-tyrannosaurus-robot-vehicle', 'Head and Sensors', 240, 'Destroying it loses optical and sensory systems and all combat bonuses. Called shot only, at -1 to strike.', 9),
  ('kittani-tyrannosaurus-robot-vehicle', 'Reinforced Pilot''s Compartment', 120, NULL, 10),
  ('kittani-tyrannosaurus-robot-vehicle', 'Main Body', 600, 'Depleting it shuts the robot down completely.', 11),
  ('hoplite-power-armor', 'Shield', 100, NULL, 1),
  ('hoplite-power-armor', 'Arms (2)', 120, 'Each.', 2),
  ('hoplite-power-armor', 'Hands (2)', 50, 'Each.', 3),
  ('hoplite-power-armor', 'Legs (2)', 140, 'Each.', 4),
  ('hoplite-power-armor', 'Spear', 120, NULL, 5),
  ('hoplite-power-armor', 'Head', 80, 'Destroying it loses optical enhancement, sensors and all power armor combat bonuses. Called shot only, at -3 to strike.', 6),
  ('hoplite-power-armor', 'Main Body', 300, 'Destroying it makes the suit useless, and the shield and spear lose their energy.', 7),
  ('hoplite-power-armor', 'Armor of Ithan Force Field', 100, NULL, 8),
  ('lictor-assault-robot', 'Shoulder Plates (2)', 150, 'Each.', 1),
  ('lictor-assault-robot', 'Axe', 200, NULL, 2),
  ('lictor-assault-robot', 'Giant TK-Rifle', 250, NULL, 3),
  ('lictor-assault-robot', 'Missile Launchers (2; shoulders)', 100, 'Each.', 4),
  ('lictor-assault-robot', 'Arms (2)', 200, 'Each.', 5),
  ('lictor-assault-robot', 'Hands (2)', 90, 'Each. A small target: Called shot only, at -3 to strike.', 6),
  ('lictor-assault-robot', 'Legs (2)', 250, 'Each.', 7),
  ('lictor-assault-robot', 'Head', 250, 'Called shot only, at -3 to strike.', 8),
  ('lictor-assault-robot', 'Main Body', 400, 'Depleting it shuts the robot down completely.', 9),
  ('lictor-assault-robot', 'Magical Force Field', 150, NULL, 10),
  ('dragon-death-power-armor', 'Shoulder Missile Launchers (2)', 80, 'Each.', 1),
  ('dragon-death-power-armor', 'Arms (2)', 80, 'Each.', 2),
  ('dragon-death-power-armor', 'Legs (2)', 100, 'Each.', 3),
  ('dragon-death-power-armor', 'Plasma Cannon', 120, NULL, 4),
  ('dragon-death-power-armor', 'Jet Pack (back)', 120, NULL, 5),
  ('dragon-death-power-armor', 'Reinforced Helmet/Head', 110, 'Destroying it exposes the wearer''s head; most giants can take a sixth of their total M.D.C. to the head before dying.', 6),
  ('dragon-death-power-armor', 'Main Body', 350, 'Depleting it shuts the armor down completely.', 7),
  ('dragon-death-power-armor', 'Pogtalian Force Field', 100, 'Only a Pogtalian dragon slayer can extend its natural invisible force field around the suit.', 8),
  ('cibolan-flying-platform-fp-10', 'Hand Railing', 40, 'Without it, anyone aboard has a 60% chance to fall at over 50 mph (80 km). Called shot only, at -4 to strike.', 1),
  ('cibolan-flying-platform-fp-10', 'Missile Launcher', 30, NULL, 2),
  ('cibolan-flying-platform-fp-10', 'Plasma Cannon', 80, NULL, 3),
  ('cibolan-flying-platform-fp-10', 'Main Body', 85, 'Depleting it destroys the platform.', 4),
  ('cibolan-flying-platform-fp-10', 'Force Field', 250, 'Once depleted it is down for an hour, and everything else is exposed.', 5),
  ('splugorth-slaver-raider', 'Pulse Cannon Turrets (2)', 200, 'Each.', 1),
  ('splugorth-slaver-raider', 'Radar and Communication Towers (4)', 100, 'Each.', 2),
  ('splugorth-slaver-raider', 'Missile Launchers (2)', 120, 'Each.', 3),
  ('splugorth-slaver-raider', 'Command Bridge', 400, 'Destroying it disables the ship and its main weapons until a tower comes online in 1D4 melees (then -2 attacks per melee, communications at 80%). Losing the bridge and all four towers leaves two attacks per melee at -5 to strike, no long-range sensors or communications, and 6 mph (9.6 km) at most.', 4),
  ('splugorth-slaver-raider', 'Prison Cells (100)', 600, 'Per wall.', 5),
  ('splugorth-slaver-raider', 'Hull/Main Body', 2500, 'Depleting it sinks the ship in 4D4 minutes, and the whirlpool drags down anything within 100 yards.', 6),
  ('splugorth-slaver-mothership', 'Main Missile Batteries (6)', 1200, 'Each. Depleting one detonates its magazine for 1D4x1000 M.D. to the main body.', 1),
  ('splugorth-slaver-mothership', 'Laser Turrets (8)', 700, 'Each.', 2),
  ('splugorth-slaver-mothership', 'Concealed Mini-Missile Launchers (12)', 140, 'Each.', 3),
  ('splugorth-slaver-mothership', 'Exterior Walls & Hatches', 200, 'Per 50 square feet (4.6 square m).', 4),
  ('splugorth-slaver-mothership', 'Interior Walls & Hatches', 100, 'Per 50 square feet (4.6 square m).', 5),
  ('splugorth-slaver-mothership', 'Holding Cells (1000)', 400, 'Per wall (reinforced).', 6),
  ('splugorth-slaver-mothership', 'Support Legs (4)', 3400, 'Each.', 7),
  ('splugorth-slaver-mothership', 'Secondary Command Post & Communications', 1400, NULL, 8),
  ('splugorth-slaver-mothership', 'Main Command Post & Communications', 2800, 'Destroying it disables the ship and main weapons until the secondary post comes online in 1D4 melees; losing both cripples the main systems (no main missiles, long-range radar or communications), though gunners still fight.', 9),
  ('splugorth-slaver-mothership', 'Main Body', 28000, 'Depleting it sinks the ship in 3D6 minutes, and the whirlpool drags down anything within 200 yards.', 10),
  ('corsair-hydrobike', 'Mini-Missile Launchers (2)', 25, 'Each.', 1),
  ('corsair-hydrobike', 'Rocket Gun', 50, NULL, 2),
  ('corsair-hydrobike', 'Concealed Forward Laser (1)', 25, NULL, 3),
  ('corsair-hydrobike', 'Main Body', 126, 'Depleting it destroys the bike.', 4),
  ('piranha-submersible-attack-boat', 'Hydrofoils (3)', 50, 'Each. Destroyed, the boat loses that mode but can still surface and run at 40 mph. Called shot only, at -4.', 1),
  ('piranha-submersible-attack-boat', 'Sensor System', 100, 'Destroyed, radar and targeting bonuses are lost. Called shot only, at -3.', 2),
  ('piranha-submersible-attack-boat', 'Rail Gun Turret', 150, NULL, 3),
  ('piranha-submersible-attack-boat', 'Missile/Torpedo Launchers (2)', 100, 'Each.', 4),
  ('piranha-submersible-attack-boat', 'Main Body', 600, 'Depleting it sinks the boat in 1D4 minutes.', 5),
  ('black-galleon-gunboat', 'Command Bridge', 300, NULL, 1),
  ('black-galleon-gunboat', 'Sensor Array', 160, NULL, 2),
  ('black-galleon-gunboat', 'Rocket Auto-cannons (2)', 300, 'As printed, one figure for the pair with no "each".', 3),
  ('black-galleon-gunboat', 'Missile Turret', 150, NULL, 4),
  ('black-galleon-gunboat', 'Main Body', 900, 'Depleting it destroys the boat.', 5),
  ('demon-black-ship', 'Front Mast', 65, 'Destroying a mast or sail cuts sailing speed by 30%.', 1),
  ('demon-black-ship', 'Sails (3)', 35, 'Each. Destroying a mast or sail cuts sailing speed by 30%.', 2),
  ('demon-black-ship', 'Mid-Mast', 90, 'Destroying a mast or sail cuts sailing speed by 30%.', 3),
  ('demon-black-ship', 'Ram Prow', 600, NULL, 4),
  ('demon-black-ship', 'Rear Mast', 65, 'Destroying a mast or sail cuts sailing speed by 30%.', 5),
  ('demon-black-ship', 'Rudder', 250, NULL, 6),
  ('demon-black-ship', 'Protruding Spikes', 50, 'Each.', 7),
  ('demon-black-ship', 'Kittani Swivel Lasers (10)', 50, 'Each.', 8),
  ('demon-black-ship', 'Front Section', 1200, 'Depleting it sinks the ship in 4D6 minutes.', 9),
  ('demon-black-ship', 'Mid-Ship', 800, 'Depleting it sinks the ship in 4D6 minutes.', 10),
  ('demon-black-ship', 'Rear Section', 900, 'Depleting it sinks the ship in 4D6 minutes.', 11),
  ('demon-black-ship', 'Hull, per 20 foot (6 m) area', 250, 'Depleting a section floods it, sinking the ship in 4D6x10 minutes; repairable.', 12),
  ('demon-black-ship', 'Keel, per 10 foot area', 500, 'Each section destroyed cuts best speed by 20%, cumulative.', 13);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('d-20-light-combat-exo-skeleton', 1, 'RAR-C15 Rocket Auto-cannon Rifle', '3D6+5 M.D. single round; 1D4x10 M.D. short burst (8 rounds); 2D4x10 M.D. long burst (20 rounds). Wooden warheads: 1 M.D. to normal targets (1D4 M.D. per burst), 4D6 to vampires, 1D6x10 short burst, 2D6x10 long burst', 1, '2000 feet (610 m)', 'Standard', '200 round belt-fed drum (ten long or 25 short bursts), or a 48 round magazine', NULL, 'Anti-personnel, secondary defense. The rifle weighs 50 lbs (22.68 kg); see the gear row of the same name.'),
  ('d-30-conquistador-power-armor', 1, 'Auto-loading Bazooka', 'Armor-piercing 1D6x10+20 M.D. (3 foot/0.9 m radius); fragmentary 6D6 M.D. (20 foot/6.1 m radius); wood fragment 1 M.D. (20 foot radius), 1D6x10 to vampires', 1, '1200 feet (366 m)', 'Twice per melee (about a 6 second reload cycle)', '12 shot drum; reloading takes 1D4 minutes', NULL, 'Anti-vehicle and/or anti-personnel, secondary defense.'),
  ('d-30-conquistador-power-armor', 2, 'Arm-Mounted Mini-Missile Launchers', 'Varies with missile type', 1, 'About 1 mile (1.6 km)', 'One or two missiles', '4 total, 2 per arm', NULL, 'Anti-personnel and/or anti-aircraft, secondary defense.'),
  ('d-30-conquistador-power-armor', 3, 'Shoulder-Mounted Rocket Gun', '4D6 M.D. single round; 1D4x10+6 M.D. burst (10 rounds); 2D4x10+10 M.D. long burst (40 rounds). Wooden warheads: 2 M.D. to normal targets (2D6 burst, 3D6 long burst), 5D6 to vampires, 2D4x10 burst, 3D6x10 long burst', 1, '2000 feet (610 m)', 'Standard', '2,000 rounds in the backpack dispenser', NULL, 'Anti-personnel, secondary defense.'),
  ('g-9a-jaguar-light-robot', 1, '20 mm Auto-cannon', '2D4x10 M.D. per 40 round burst; bursts only. Wooden rounds 2D6 M.D. per burst, 2D6x10 to vampires', 1, '4000 feet (1220 m)', 'Equal to the pilot''s hand to hand attacks (usually 4-6)', '4,000 rounds in the arm, reloaded automatically in one melee round from a 12,000 round body magazine; refilling the dispensers takes special equipment and about an hour', NULL, 'Anti-vehicle, secondary defense. Left arm.'),
  ('g-9a-jaguar-light-robot', 2, 'Laser Eye Beams (2)', '6D6 M.D. per dual blast (3D6 with one eye disabled)', 1, '4000 feet (1220 m)', 'Equal to the combined hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Anti-robot and anti-aircraft, secondary defense.'),
  ('g-9a-jaguar-light-robot', 3, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'About 1 mile (1.6 km)', 'Singly or in volleys of 2, 4, 8, 16 or 32', '32 total, 16 per launcher', NULL, 'Anti-personnel and anti-aircraft, secondary defense. Shoulders.'),
  ('g-18b-aguirre-heavy-combat-robot', 1, 'Rocket Auto-cannon', '1D6x10 M.D. per 10 round burst; bursts only. Anti-vampire wooden rounds 2D4x10 to vampires', 1, '4000 feet (1220 m)', 'Equal to the pilot''s combined hand to hand attacks (usually 4-6)', '4,000 rounds (400 bursts)', NULL, 'Anti-personnel, secondary defense. Belly.'),
  ('g-18b-aguirre-heavy-combat-robot', 2, 'Medium Range Missile Launchers (2)', 'Varies with missile type', 1, '40-80 miles (64-128 km)', 'Singly or in volleys of 2, 3 or 4', '12 total, 6 per launcher', NULL, 'Anti-aircraft, secondary anti-armor. Shoulders.'),
  ('g-18b-aguirre-heavy-combat-robot', 3, 'Laser Cannons (2)', '3D6 M.D. single blast, 6D6 M.D. dual blast (one attack)', 1, '4000 feet (1220 m)', 'Equal to the hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense. Forearms.'),
  ('g-18b-aguirre-heavy-combat-robot', 4, 'Giant Vibro-Sword', '1D6x10 M.D. activated; 3D4 M.D. unpowered (blunt). A silver-plated variant does 2D4 M.D. to normal targets and 2D6x10 to vampires', 1, NULL, NULL, NULL, '+3 to strike, +5 to parry', 'A 20 foot (6.1 m) blade.'),
  ('lancero-light-tank-apc', 1, 'Main Gun', 'Types A and B, 120 mm cannon: high-explosive 2D4x10 M.D. (20 foot/6.1 m radius) or armor-piercing solid 2D6x10 M.D. (no radius). Type V, water cannon: 2D6 S.D.C. and an 88% chance of knocking a human-sized target down (48% against 800 lbs to one ton, none heavier), 2D6x10 to vampires', 1, '6000 feet (1830 m) for A and B; 500 feet (152 m) for V', 'Once per melee (A and B); six times per melee (V)', '50 120 mm rounds, or 600 water blasts', NULL, 'Anti-armor, secondary anti-personnel (A and B); anti-vampire, secondary riot control (V).'),
  ('lancero-light-tank-apc', 2, 'Coaxial Machinegun', '4D6 M.D. short burst (20 shots); 1D4x10 M.D. long burst (40 rounds); bursts only. Wooden warheads 1 M.D. (short) or 1D4 M.D. (long) to normal targets, 5D6 or 1D6x10 to vampires', 1, '2000 feet (610 m)', 'Equal to the hand to hand attacks (usually 4-6)', '8,000 rounds (2,000 long or 4,000 short bursts)', NULL, 'Anti-personnel, secondary defense.'),
  ('lancero-light-tank-apc', 3, 'Rocket Machinegun', '8D6 M.D. per 10 round burst; 2D4x10 M.D. long burst (40 rounds); bursts only. Wooden warheads 2 M.D. (2D6 long burst) to normal targets, 5D6 (2D4x10 long burst) to vampires', 1, '2000 feet (610 m)', 'Equal to the hand to hand attacks (usually 4-6)', '8,000 rounds (200 long or 800 short bursts)', NULL, 'Anti-personnel, secondary defense. Front-mounted.'),
  ('lancero-light-tank-apc', 4, 'Side Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'About 1 mile (1.6 km)', 'Singly or in volleys of 2, 5 or 10', '20 total, 10 per launcher', NULL, 'Anti-personnel and/or anti-armor, secondary defense.'),
  ('zancudo-transport-attack-helicopter', 1, '20 mm Rocket Auto-cannon', '1D6x10 M.D. per 20 round burst; bursts only', 1, '4000 feet (1220 m)', 'Equal to the gunner''s hand to hand attacks (usually 3-6)', '4,000 round drum (200 bursts)', NULL, 'Anti-vehicle, secondary anti-personnel. Belly turret.'),
  ('zancudo-transport-attack-helicopter', 2, 'Mini-Missile Launchers (4)', 'Varies with missile type', 1, 'About 1 mile (1.6 km)', 'Singly or in volleys of 2, 4, 8, 12, 16, 20 or 24', '48 total, 12 per launcher', NULL, 'Anti-vehicle and anti-personnel, secondary defense.'),
  ('kittani-raptor-power-armor', 1, 'Laser Mounts (2)', '6D6 M.D. single pulse; 1D6x10 M.D. combined burst (counts as two attacks)', 1, '4000 feet (1220 m)', 'Equal to the combined hand to hand attacks (average 6-8)', 'Effectively unlimited', NULL, 'Assault, secondary defense. Frequency adjustable to defeat laser-resistant armor like the Glitter Boy''s.'),
  ('kittani-raptor-power-armor', 2, 'Shoulder Missile Launchers (2)', 'Varies with mini-missile; standard load plasma (1D6x10 M.D.)', 1, 'About 1 mile (1.6 km)', 'Singly or in volleys of 2, 4, 6, 8 or 12', '12 total, 6 per launcher', NULL, 'Anti-robot and anti-aircraft, secondary defense. Concealed.'),
  ('kittani-raptor-power-armor', 3, 'Head Laser Beams', '2D6 M.D. single; 4D6 M.D. dual blast (one attack)', 1, '2000 feet (610 m)', 'Equal to the combined hand to hand attacks (average 6-8)', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense.'),
  ('kittani-allosaurus-firedrake-power-armor', 1, 'Medium-Range Missile Launcher', 'Varies with missile; commonly plasma (2D6x10 M.D.)', 1, 'About 40 miles (64 km)', 'One at a time or in volleys of 2 or 4', '4 total, 2 per chest housing', NULL, 'Anti-armor, secondary defense. Chest.'),
  ('kittani-allosaurus-firedrake-power-armor', 2, 'Tri-Barrel Super Rail Gun Arms (2)', '1D6x10 M.D. per 40 round burst, bursts only; both guns on one target 2D4x10 M.D. per double burst (one attack)', 1, '6000 feet (1830 m)', 'Up to six bursts per melee, each one attack', '4,000 round drum (100 bursts); a second drum feeds automatically; reloading takes about 5 minutes and P.S. 26+', '+2 to strike', 'Assault, secondary defense. The gun of the Kittani Equestrian Power Armor (Rifts Atlantis), with built-in laser targeting and radar tracking to 6000 feet.'),
  ('kittani-allosaurus-firedrake-power-armor', 3, 'Concealed Mini-Missile Launchers (2)', 'Varies with missile; standard plasma (1D6x10 M.D.)', 1, 'About 1 mile (1.6 km)', 'Singly or in volleys of 2, 4, 6, 8 or 12', '24 total, 12 per launcher', NULL, 'Anti-robot and anti-aircraft, secondary defense. Side and back.'),
  ('kittani-allosaurus-firedrake-power-armor', 4, 'Mouth Plasma Projector', '2D4x10 M.D.', 1, '300 feet (91.4 m)', 'Once per melee (one attack)', 'Effectively unlimited', NULL, 'Assault, secondary anti-personnel.'),
  ('kittani-tyrannosaurus-robot-vehicle', 1, 'Shoulder Medium-Range Missile Launchers (2)', 'Varies with missile; usually plasma (2D6x10 M.D.)', 1, 'About 40 miles (64 km)', 'Singly or in volleys of 2, 4, 8 or 16', '16 total, 8 per launcher', NULL, 'Anti-armor, secondary anti-aircraft.'),
  ('kittani-tyrannosaurus-robot-vehicle', 2, 'Concealed Mini-Missile Launchers (2)', 'Varies with missile; standard plasma (1D6x10 M.D.)', 1, 'About 1 mile (1.6 km)', 'Singly or in volleys of 2, 4, 6, 8 or 12', '48 total, 24 per launcher', NULL, 'Anti-robot and anti-aircraft, secondary defense.'),
  ('kittani-tyrannosaurus-robot-vehicle', 3, 'Twin-Barrel Pulse Cannons (2)', '5D6 M.D. single pulse; 1D6x10 M.D. dual blast from one cannon; up to 2D6x10 M.D. with all four barrels on one target (one melee action)', 1, '6000 feet (1830 m)', 'Equal to the pilot''s or gunner''s attacks (usually 3-6), at most six blasts per melee', 'Effectively unlimited', NULL, 'Assault, secondary defense. Shoulder-mounted; each rotates 360 degrees.'),
  ('kittani-tyrannosaurus-robot-vehicle', 4, 'Belly Rail Gun', '1D6x10 M.D. per 40 round burst; bursts only', 1, '4000 feet (1220 m)', 'Up to six bursts per melee, each one attack', '4,000 round drum (100 bursts); a second drum feeds automatically; reloading takes about 5 minutes and P.S. 26+', NULL, 'Anti-personnel, secondary defense.'),
  ('kittani-tyrannosaurus-robot-vehicle', 5, 'Head Laser Cannons (2; eyes)', '1D4x10 M.D. single blast; 2D4x10 M.D. dual blast (two attacks)', 1, '4000 feet (1220 m)', 'Equal to the pilot''s or gunner''s attacks (usually 3-6)', 'Effectively unlimited', NULL, 'Assault, secondary defense.'),
  ('hoplite-power-armor', 1, 'Energy Spear', 'Energy bolt 5D6 M.D.; energized strike 6D6 M.D., unenergized 3D6 M.D.', 1, 'Bolt 1000 feet (305 m); thrown 300 feet (91.5 m)', 'Each blast one melee action', 'Effectively unlimited while the suit is active', '+1 to strike and parry in hand to hand, +2 to strike thrown', 'Anti-armor, secondary anti-personnel.'),
  ('hoplite-power-armor', 2, 'Shield', 'Shock wave 2D6 M.D. with a 75% chance to knock down a man-sized or smaller target (60% at 9 feet, 35% at 10-11 feet, none larger; the victim loses one attack and initiative); shield bash 2D6+6 M.D.', 1, '300 feet (91.5 m)', 'Each shock wave one melee action', 'Effectively unlimited (recharges with the suit)', '+2 to parry, +1 to strike with the shield or shock wave', 'Anti-personnel, secondary defense.'),
  ('hoplite-power-armor', 3, 'Light Amplification System (eyes)', 'Light beam (no damage), 6D6 S.D.C. laser or 3D6 M.D. laser', 1, 'Laser 1000 feet (305 m); light beam 300 feet (91.5 m)', 'Each blast one melee action', 'Effectively unlimited', '+1 to strike', 'Anti-personnel, secondary defense. Also casts Globe of Daylight and Blinding Flash three times each per 24 hours, as a 6th level spell.'),
  ('lictor-assault-robot', 1, 'TK-Rifle', '1D6x10 M.D. per blast', 1, '4000 feet (1220 m)', 'Equal to the combined hand to hand attacks (usually 4-8), each blast one action', 'Effectively unlimited (recharges with the robot)', NULL, 'Assault, secondary defense. A giant version of the TW TK-machinegun.'),
  ('lictor-assault-robot', 2, 'Energy Axe', '1D6x10 M.D. per electrically charged strike; 1D4x10 M.D. as a lightning blast or thrown', 1, 'Thrown 300 feet (91 m), returning in 3 seconds; electrical blast 600 feet (183 m)', 'Equal to the combined hand to hand attacks', 'Effectively unlimited (recharges with the robot)', '+1 to strike, +2 to parry', 'Assault.'),
  ('lictor-assault-robot', 3, 'Eye Plasma Bolts', '5D6 M.D. one eye; 1D6x10 M.D. twin blast (one attack)', 1, '2000 feet (610 m)', 'Equal to the hand to hand attacks per melee', 'Effectively unlimited', '+2 to strike', 'Assault, secondary defense. Also casts Fuel Flame and Circle of Flame three times each per 24 hours, as a 6th level spell.'),
  ('lictor-assault-robot', 4, 'Mini-Missile Launchers (2)', 'Varies; typically armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.)', 1, 'About 1 mile (1.6 km)', 'Volleys of 2, 4 or 6', '48 total, 24 per launcher', NULL, 'Anti-armor and anti-aircraft/dragon, secondary anti-personnel. Shoulders.'),
  ('lictor-assault-robot', 5, 'Concealed Laser Fingers (2)', '2D6 M.D. single; 4D6 M.D. dual', 1, '2000 feet (610 km) as printed; 2000 feet is 610 m', 'Equal to the pilot''s combined hand to hand attacks', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense.'),
  ('dragon-death-power-armor', 1, 'Mini-Missile Launchers (2)', 'Varies with missile; usually plasma or armor piercing', 1, 'About 1 mile (1.6 km)', 'One at a time or in volleys of 2, 4 or 6', '12 total, 6 per launcher', NULL, 'Anti-aircraft and anti-armor, secondary defense. Shoulders.'),
  ('dragon-death-power-armor', 2, 'Plasma Cannon', '1D6x10 M.D. per blast; 3D4x10 M.D. long burst (two attacks)', 1, '4000 feet (1220 m)', 'Equal to the hand to hand attacks', 'Effectively unlimited; a giant E-clip holds 20 shots, a normal E-clip 4', NULL, 'Anti-armor, secondary anti-personnel.'),
  ('cibolan-flying-platform-fp-10', 1, 'Plasma Cannon', '6D6 M.D. per blast', 1, '2000 feet (610 m)', 'Equal to the pilot''s hand to hand attacks', 'Effectively unlimited', NULL, 'Assault, secondary defense.'),
  ('cibolan-flying-platform-fp-10', 2, 'Missile Launcher', 'Varies with missile; usually plasma (1D6x10 M.D.)', 1, 'About 1 mile (1.6 km)', 'One at a time or in volleys of 2, 4 or 8', '8 mini-missiles', NULL, 'Assault.'),
  ('splugorth-slaver-raider', 1, 'Pulse Cannon Turrets (2)', '1D4x10 M.D. single, 2D4x10 double, 3D4x10 all three barrels (each one attack)', 1, '6000 feet (1830 m)', 'Six per turret', 'Effectively unlimited', NULL, 'Anti-ship, anti-sea serpent and anti-aircraft, secondary defense.'),
  ('splugorth-slaver-raider', 2, 'Missile Launchers (2)', 'Varies with missile; may carry amphibious dual-purpose missiles (200 mph/320 km underwater)', 1, '500-1800 miles (800-2900 km)', 'One at a time or in volleys of 2, 4, 6, 8, 12 or 16', '128 (64 per launcher); 512 carried aboard, reloadable from the hold', NULL, 'Anti-ship, anti-submarine and anti-sea serpent, secondary defense.'),
  ('splugorth-slaver-raider', 3, 'Depth Charges (4)', '2D4x10 M.D.', 1, 'Range and depth 2000 feet (610 m); detonates at 2000 feet or a set depth between 200 and 2000 feet', NULL, '24 total, 6 per launcher', NULL, NULL),
  ('splugorth-slaver-mothership', 1, 'Main Missile Batteries (6)', 'Any long-range missile type', 1, '500-1800 miles (804-2893 km)', 'One at a time or in volleys of 4, 8 or 12 per battery - up to 72 missiles a melee from all six', '120 per battery (720), plus 8,000 in the hold; 20 minutes to reload', NULL, 'Anti-ship and anti-aircraft, secondary anti-personnel and shore bombardment.'),
  ('splugorth-slaver-mothership', 2, 'Mini-Missile Launchers (12)', 'Typically armor piercing (1D4x10 M.D.) or plasma (1D6x10 M.D.)', 1, 'About 1 mile (1.6 km)', 'Volleys of 2, 4, 6 or 8; automatic reloading', '960 total (80 per launcher), plus 2,400 in the hold; 6 minutes for a full reload', NULL, 'Anti-missile and anti-aircraft, secondary anti-personnel and defense.'),
  ('splugorth-slaver-mothership', 3, 'Laser Turrets (8)', '2D6x10 M.D. per blast', 1, '10,000 feet (3050 m)', 'Equal to the gunner''s hand to hand attacks, or two each from the command post', 'Effectively unlimited', NULL, 'Anti-aircraft/dragon and anti-missile, secondary anti-ship and defense.'),
  ('splugorth-slaver-mothership', 4, 'Medium Torpedo Launch Tubes (6)', '2D6x10 M.D. (plasma)', 1, '10 miles (16 km)', NULL, '150 total, 25 per tube', '+3 to strike within optimum range; -2 beyond 2 miles (3.2 km)', 'Anti-submarine and sea monsters, secondary defense. Torpedo speed 200 mph (321.8 km).'),
  ('splugorth-slaver-mothership', 5, 'Depth Charges (4)', '2D4x10 M.D.', 1, 'Range and depth 2000 feet (610 m); detonates at 2000 feet or a set depth between 200 and 2000 feet', NULL, 'Not printed', NULL, NULL),
  ('corsair-hydrobike', 1, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'About 1 mile (1.6 km)', 'One at a time or in volleys of 2 or 4', '8 total, 4 per launcher', NULL, 'Assault, secondary defense.'),
  ('corsair-hydrobike', 2, 'AC-15 Rocket Gun', '4D6 M.D. single round; 8D6 M.D. burst (8 rounds); 2D6x10 M.D. long burst (20 rounds)', 1, '2000 feet (610 m)', 'Standard', '100 round belt', NULL, 'Assault, secondary defense.'),
  ('corsair-hydrobike', 3, 'LC-20 Laser Gun', '3D6 M.D. per blast', 1, '900 feet (274 m)', 'Standard', '20 shots per standard long E-clip', NULL, 'Assault, secondary defense. Concealed under the rocket gun.'),
  ('piranha-submersible-attack-boat', 1, 'Rail Gun Turret', '1D6x10 M.D. per 80 round burst; bursts only', 1, '4000 feet (1220 m)', 'Equal to the gunner''s hand to hand attacks', '8,000 rounds (100 bursts); reloadable in one minute', NULL, 'Anti-ship and anti-aircraft, secondary defense.'),
  ('piranha-submersible-attack-boat', 2, 'Missile/Torpedo Launchers (2)', 'Varies with missile; amphibious missiles do the same damage as their regular equivalent at double the cost, travel 120 mph (192 km) underwater and are +2 to strike underwater targets', 1, 'Varies', 'One at a time or in volleys of 2, 4 or 8', '32 total, 16 per launcher', NULL, 'Anti-ship, secondary shore bombardment.'),
  ('black-galleon-gunboat', 1, 'Rocket Auto-cannons (2)', '2D4x10 M.D. per 20 round burst; bursts only', 1, '6000 feet (1830 m)', 'Equal to the gunner''s hand to hand attacks', '4,000 rounds (200 bursts)', NULL, 'Anti-ship, secondary defense. One fore, one aft.'),
  ('black-galleon-gunboat', 2, 'Missile Turret', 'Varies with missile type', 1, 'Varies', 'One at a time or in volleys of 2, 4, 8 or 12', '36 in the turret plus 10 reloads in the hold (360 total)', NULL, 'Anti-ship, secondary shore bombardment.'),
  ('black-galleon-gunboat', 3, 'Light Torpedo Launch Tubes (2)', '2D4x10 M.D. (high explosive)', 1, '3 miles (4.8 km)', NULL, '12 total, 6 per tube; 8,000 credits per torpedo', '-2 to strike beyond 1 mile (1.6 km)', 'Anti-submarine and sea monsters, secondary defense. Forward, above the waterline; torpedo speed 200 mph (321.8 km).'),
  ('black-galleon-gunboat', 4, 'Forward Pulse Laser Cannon', '4D6 M.D. single blast or 1D6x10 M.D. pulse (either one action)', 1, '6000 feet (1830 m)', 'Equal to the gunner''s hand to hand attacks', 'Effectively unlimited', NULL, 'Anti-missile and anti-aircraft, secondary defense. Often built into the auto-cannon turrets or as an open deck gun; 90 M.D.C.'),
  ('black-galleon-gunboat', 5, 'Depth Charge Launchers (2)', '2D4x10 M.D.', 1, 'Range and depth 2000 feet (610 m); detonates at 2000 feet or a set depth between 200 and 2000 feet', NULL, '16 total, 8 per launcher; 4,500 credits per charge, 10,000 for a launcher', NULL, 'Rear.'),
  ('demon-black-ship', 1, 'Kittani Swivel Lasers (10)', '1D4x10 M.D. per blast', 1, '3000 feet (914 m)', 'Six attacks per melee under the Robot Defense System (+2 to strike), or as fired by a gunner', '40 blasts, then a 2 hour recharge; in an emergency an E-clip gives 5 blasts, and deck loaders reload in combat', NULL, 'Anti-ship, secondary defense. Modified K-1000 Spider Defense Systems with the propulsion removed, deck-mounted: two above the prow, four per side.'),
  ('demon-black-ship', 2, 'Ram Prow', '3D6x10 M.D. plus 5 M.D. per mph of speed (3D6x10+160 at full speed against a stationary target)', 1, 'Contact', 'One attack per melee on contact', NULL, NULL, 'Anti-ship. An enchanted construct.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the 19 vessels' AS assertion, count(*) AS got, 19 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 6: South America p.%';

SELECT 'their M.D.C. locations: 6 + 8 + 9 + 10 + 7 + 6 + 9 + 10 + 11 + 8 + 10 + 8 + 5 + 6 + 10 + 4 + 5 + 5 + 13' AS assertion, count(*) AS got, 150 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('d-20-light-combat-exo-skeleton', 'd-30-conquistador-power-armor', 'g-9a-jaguar-light-robot', 'g-18b-aguirre-heavy-combat-robot', 'lancero-light-tank-apc', 'zancudo-transport-attack-helicopter', 'kittani-raptor-power-armor', 'kittani-allosaurus-firedrake-power-armor', 'kittani-tyrannosaurus-robot-vehicle', 'hoplite-power-armor', 'lictor-assault-robot', 'dragon-death-power-armor', 'cibolan-flying-platform-fp-10', 'splugorth-slaver-raider', 'splugorth-slaver-mothership', 'corsair-hydrobike', 'piranha-submersible-attack-boat', 'black-galleon-gunboat', 'demon-black-ship');

SELECT 'their weapon entries: 1 + 3 + 3 + 4 + 4 + 2 + 3 + 4 + 5 + 3 + 5 + 2 + 2 + 3 + 5 + 3 + 2 + 5 + 2' AS assertion, count(*) AS got, 61 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('d-20-light-combat-exo-skeleton', 'd-30-conquistador-power-armor', 'g-9a-jaguar-light-robot', 'g-18b-aguirre-heavy-combat-robot', 'lancero-light-tank-apc', 'zancudo-transport-attack-helicopter', 'kittani-raptor-power-armor', 'kittani-allosaurus-firedrake-power-armor', 'kittani-tyrannosaurus-robot-vehicle', 'hoplite-power-armor', 'lictor-assault-robot', 'dragon-death-power-armor', 'cibolan-flying-platform-fp-10', 'splugorth-slaver-raider', 'splugorth-slaver-mothership', 'corsair-hydrobike', 'piranha-submersible-attack-boat', 'black-galleon-gunboat', 'demon-black-ship');

SELECT 'main bodies of the 18 that print one' AS assertion, sum(mdc_main_body) AS got, 36316 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 6: South America p.%';

SELECT 'priced: 16; the three estimates carry their note' AS assertion, count(*) AS got, 16 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 6: South America p.%' AND cost IS NOT NULL;

SELECT 'and every estimate is explained' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 6: South America p.%' AND cost IS NULL AND cost_note IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-south-america-vessels.sql');
