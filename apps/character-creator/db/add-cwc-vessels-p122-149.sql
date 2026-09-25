-- Coalition War Campaign vessels, printed 122-149: the Skelebots and the CS
-- robot vehicles of Rifts World Book 11: Coalition War Campaign. 10 vehicles,
-- 99 M.D.C. locations, 35 weapon entries.
--
--   Coalition Skelebot (FASSAR-20 and FASSAR-30), printed 122-127
--   Hunter Skelebot (FASSAR-40), printed 129-130
--   Hellion Skelebot (FASSAR-50), printed 130-132
--   Centaur Skelebot (FASSAR-60), printed 132-133
--   IAR-2 Abolisher, printed 134-137 (printed 134 also sets out the
--     features every CS robot vehicle shares)
--   IAR-3 Skull Smasher, printed 137-140
--   IAR-4 Hellraiser, printed 140-143
--   IAR-5 Hellfire, printed 143-145
--   CR-004 Scout Spider-Skull Walker, printed 146-147
--   CR-005 Scorpion-Skull Walker, printed 148-150 (its weapon 5's rate and
--     payload, weapon 6, hand to hand and bonuses run onto printed 150, the
--     first page of the CS Combat Vehicles section, read as a margin)
--
-- Printed 122 opens with the end of the PA-08A Striker SAMAS (weapons 2-7),
-- which add-cwc-vessels-p105-121.sql already holds; nothing of it is here.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local add-cwc-vessels-p122-149.sql
--
-- The book has a TEXT LAYER; offset +1, so printed N is cache p(N+1). The text
-- layer was used only to find things. EVERY NUMBER HERE WAS READ OFF A 200 DPI
-- RENDER of printed 125-127, 129-130, 132-134, 136-138, 140-143, 145-150
-- (printed 122 and 124 hold prose only; 123, 128, 131, 135, 139 and
-- 144 are full-page art, which is why their cache pages are empty or, for
-- cache p136, corrupt glyphs). Printed 145 (cache p146) sets the IAR-5's cost
-- line and hand to hand heading in corrupt glyphs; printed 150 (cache p151)
-- is welded, and the Scorpion's last two systems and hand to hand table were
-- read off the render. The layer's digit cipher (!D6xlO = 1D6x10) is corrected
-- throughout.
--
-- ONE ROW FOR THE FASSAR-20 AND FASSAR-30. The book prints one stat block
-- that "applies to both" and lists only the FASSAR-30's different weapons at
-- the end, so this follows the NG-JK1 shape of the Juicer Uprising vessels: one
-- row, the FASSAR-30's rail gun as a weapon row of its own and its different
-- punch and blades in the description. The FASSAR-30 list restarts its
-- numbering (its hand to hand is "2."), so its unnumbered rail gun is ordinal 1
-- of that list, beside the FASSAR-20's own ordinal 1.
--
-- SKELEBOTS ARE `drone`: they have no pilot or controller, as the catalog's
-- DV-series drones; everything with a crew is `robot`.
--
-- BOOK SLIPS, stored as printed and noted on the row:
--   printed 126  "44 to strike" in the Skelebot bonuses (almost certainly +4);
--                full strength punch "1D6" with no unit (also the Hunter's 2D6)
--   printed 129-132  the Hunter's, Hellion's and Centaur's Power System line
--                gives a three-year energy life; the Range paragraph
--                (repeated from the FASSAR-20) still says about two years.
--                Three years is stored.
--   printed 130  the Hellion's location list has two hands and arms, two
--                vibro-blades and a C-200, though the text gives it four arms
--                and no built-in weapons, "not even vibro-blades"
--   printed 133  the Centaur's ion blaster "1200 feet (336 m)"
--   printed 137  IAR-3 missile launchers and eyes without "each"; its single
--                mouth cannon "75 each"; printed 138 height "28 feet (9.1 m)"
--   printed 142  IAR-4 "18 feet (9.1 m)" (the intro on printed 140 has
--                18 feet (5.5 m)) and "10 feet (3.6 m)"
--   printed 143  IAR-5 "Small Rear Trusters"; printed 145 "10 feet (3.6 m)",
--                mini-missile range "One mile (1.6 m)", the plasma ejector
--                given the rail guns' HF-36 designation and its single-barrel
--                blast "5D6" with no unit
--   printed 147  the Spider Scout's eye cameras "1200 feet/610 m"
--   printed 149  the Scorpion's "Legs (4)" though it walks on six, and its
--                cost line naming the "Spider Scout"
--
-- PRICES. Every machine prints a figure: the Skelebot a Black Market cost, the
-- IAR-2 a Black Market cost, the rest a CS cost with "not available on the
-- Black Market". Following the T-550 Glitter Boy and T-31 rows, a printed
-- price is stored even where no market sells the machine; the availability
-- text is in cost_note.
--
-- The IAR-2's older Rifts Sourcebook One version is mentioned (30% of those
-- in service) but not statted here, so it has no row. The book does not relate
-- the IAR-2 to Free Quebec's QR-2 Abolisher Prime, so neither row mentions the
-- other. Hand to hand tables and bonuses are in the description, not in
-- vehicle_weapons, which holds the fixed weapon systems.
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('fassar-20-30-skelebot', 'Coalition Skelebot (FASSAR-20 and FASSAR-30)', 'rifts', 'drone', 'None; artificial intelligence', NULL, 'Running 90 mph (144 km) maximum; running never tires it. Leaps about 6 feet (1.8 m) high or across.', 'None without a conventional CS jet pack or vehicle', 'Walks the sea bottom at about 25% of its running speed; maximum depth 1000 feet (305 m)', 'Height 7 feet (2.1 m), width 3 feet (0.9 m), length 2 feet 9 inches (0.9 m)', '390 lbs (175 kg)', 150, 3000000, 'Black Market Cost: three million credits for a new, fully powered unit with an assault rifle. Rarely available; exclusive to the CS military, and nobody has dared a knock-off.', 'Fully Automated Self-Sufficient Assault Robot: the CS''s unpiloted, skeleton-styled infantry robot, fielded by the division against Tolkeen and Quebec, usually in squads of 4-10 and often under a human in power armor. One stat block covers the old-style FASSAR-20 and the new FASSAR-30, which is styled after the Dead Boy armor, carries the C-200 rail gun as standard and swings out wing-style vibro-blades. P.S. 30; cannot wear armor. Nuclear, a deliberately short life of about two years (nearly three under light use); a homing device and an anti-tamper charge that guts it if opened without the code. Destroying the head usually shuts it down, but one in ten fights on blindly. Five attacks per melee, Hand to Hand Expert at 8th level. FASSAR-20: restrained punch 2D6+15 S.D.C., full strength punch, elbow or knee 1D6 (no unit printed), power punch 2D6 (two attacks), kick 2D4 M.D., body block 1D6 M.D., head butt 1D6 M.D., vibro-sabers 2D6 M.D. each. FASSAR-30 the same except restrained punch 3D6+15 S.D.C. and vibro-wing blades 2D6 M.D. Bonuses: +2 to strike with automatic rifle, energy pistol or energy rifle, +5 on an aimed shot, "44" to strike with blades or hand to hand as printed (read +4), +5 to parry with fists, +7 with a blade, +6 to dodge, +4 to parry and dodge from behind, +2 to roll with impact (no pull punch), critical on a natural 19-20. Impervious to poison, gas, biological agents, psionic and magic mind control, charms, bio-manipulation and S.D.C. attacks. Sensors: full optics (telescopic about 2 miles, others about 3000 feet), radar tracking 12 airborne targets at 2 miles, a 100 foot motion detector, 10 mile coded radio that can trace transmissions (60%); understands English, Spanish and Techno-can and speaks only a short list of commands. Skills: W.P. sword, blunt, automatic rifle, energy pistol, energy rifle and paired weapons; pilot automobile and hover cycle 96%, jet pack 80%, radio basic 96%, intelligence 76%, land navigation 86%, climb 96%/86%, six languages and basic math at 96%. Recognizes every CS rank, uniform and machine and 2000 enemy targets. Any energy rifle or normal weapon can be substituted. Not suitable as a player character.', 'Rifts World Book 11: Coalition War Campaign p.122-127'),
  ('fassar-40-hunter-skelebot', 'Coalition Hunter Skelebot (FASSAR-40)', 'rifts', 'drone', 'None; artificial intelligence', NULL, 'Running 90 mph (144 km) maximum; running never tires it. Leaps about 6 feet (1.8 m) high or across.', 'None without a conventional CS jet pack or vehicle', 'Walks the sea bottom at about 25% of its running speed; maximum depth 1000 feet (305 m)', 'Height 8 feet (2.4 m), width 3 feet 6 inches (1 m), length 3 feet (0.9 m)', '600 lbs (270 kg)', 210, 3800000, 'CS Cost: 3.8 million credits; not available on the Black Market.', 'Experimental heavy assault Skelebot, larger and more heavily plated than the FASSAR-20/30, sent out alone or in pairs as an automated exterminator of D-bees and monsters. A two-chamber chest compartment (the rib plates flip open) holds up to 50 message disks each or a few small items, programmed through a keypad or finger jack; as a courier it fights to destruction and self-destructs when its main body reaches zero. No standard weapon: any rail gun or rifle; the concealed forearm vibro-sabers leave the hands free. P.S. 40. Energy life printed as three years on the Power System line, though its Range paragraph repeats the two-year text. Programming as the FASSAR-20/30 plus detect ambush 60%, prowl 60%, track humanoids 50% and sniper (+2 to strike on aimed shots). Hand to Hand Expert, five attacks: restrained punch 3D6+30 S.D.C., full strength punch, elbow or knee 2D6 (no unit printed), power punch 4D6 (two attacks), kick 2D6 M.D., body block 1D6 M.D., head butt 1D6 M.D., vibro-saber 2D6 M.D.; bonuses as the FASSAR-20 plus +1 on initiative.', 'Rifts World Book 11: Coalition War Campaign p.129-130'),
  ('fassar-50-hellion-skelebot', 'Coalition Hellion Skelebot (FASSAR-50)', 'rifts', 'drone', 'None; artificial intelligence', NULL, 'Running 70 mph (112.6 km) maximum; running never tires it. Leaps 20 feet (6 m) high and 30 feet (9 m) long in a few strides, 50 feet (15.2 m) long from a short run.', 'None without a conventional CS jet pack or vehicle', 'Walks the sea bottom at about 25% of its running speed; maximum depth 1000 feet (305 m)', 'Height 12 feet (3.6 m) erect, though it crouches to look half that; width 4 feet (1.2 m), length 3 feet (0.9 m)', '800 lbs (360 kg)', 200, 4600000, 'CS Cost: 4.6 million credits; not available on the Black Market.', 'Experimental demon-styled Skelebot with four arms (two large, two smaller), horns and a prehensile tail used as a whip, for balance and to strangle; it sways and weaves constantly and has an automatic dodge like the Commando O.C.C. A few hundred are in field tests in the Quebec campaign and on western and southwestern patrols. No built-in weapons: spiked fingers slash, spines on the large arms help parry M.D. blades, and it can wield up to four weapons, or one two-handed heavy weapon such as the CTT-P40A plus two lighter ones. P.S. 30; three-year energy life. Seven attacks per melee, Hand to Hand Expert: restrained punch 2D6+15 S.D.C., full strength punch, elbow or knee 1D6 M.D., claw strike 2D4 M.D., power punch 2D6 (two attacks), tail strike 1D6 M.D., kick 2D6 M.D., body block 1D6 M.D., head butt 2D4 M.D., running leap kick 4D6 M.D. (uses all but one attack; 01-35% knockdown against giants, 01-70% against human-sized, victim loses two actions and initiative), body block/ram 1D6 M.D., full speed running ram 4D6 M.D. (three attacks). Bonuses as the FASSAR-20 plus +2 to roll with impact, +2 on initiative, +1 to strike, +2 to parry and +4 to automatic dodge. BOOK SLIP: the location list prints two hands and two arms, two vibro-blades and a C-200 rail gun, against the text''s four arms and no built-in weapons.', 'Rifts World Book 11: Coalition War Campaign p.130-132'),
  ('fassar-60-centaur-skelebot', 'Coalition Centaur Skelebot (FASSAR-60)', 'rifts', 'drone', 'None; artificial intelligence', NULL, 'Running 120 mph (192 km) maximum; running never tires it. Leaps 20 feet (6 m) high and 30 feet (9 m) long in a few strides, 60 feet (18.3 m) long with a running start.', 'None', 'None', 'Height 10 feet (3 m), width 4 feet (1.2 m), length 10 feet (3 m)', '800 lbs (360 kg)', 180, 4800000, 'CS Cost: 4.8 million credits; not available on the Black Market.', 'Experimental Skelebot with a humanoid skeleton torso on a horse-like body, back-mounted mini-missile launchers, forearm energy weapons and two sensor rods on its hind hips. A design failure: little faster than other bots, the missiles unbalance it, its hands cannot use normal guns (vibro-blades and oversized weapons only), and Emperor Prosek objects to its alien look. About a dozen were built and it will not reach phase two tests. P.S. 30; three-year energy life. Programming as the FASSAR-20/30, five attacks per melee; hand to hand as the FASSAR-20 plus a 2D6 M.D. kick. The two forearm weapons cannot fire at the same target.', 'Rifts World Book 11: Coalition War Campaign p.132-133'),
  ('iar-2-abolisher-assault-robot', 'IAR-2 Abolisher Assault Robot', 'rifts', 'robot', 'Six: pilot, co-pilot, communications officer and three gunners (two cannons each); a top hatch gunner, usually a SAMAS or armored soldier with a heavy weapon, can be added', 'Two', 'Running 70 mph (112 km) maximum; never tires. Leaping is not recommended: only from a running start, about 20 feet (6 m) long and 5-6 feet (1.8 m) high, with a 1-70% chance of falling over (all attacks lost for a melee round).', NULL, 'Walks the sea bottom at about 25% of its running speed; maximum depth 4000 feet (1200 m)', 'Height 30 feet (9.1 m), width 14 feet (4.3 m), length 14 feet (4.3 m)', '60 tons fully loaded', 590, 80000000, 'Black Market Cost: 80 million credits for a new, fully functioning unit. Rarely available.', 'Infantry Assault Robot nicknamed "Thorn Head": a headless, heavily armored 30 foot walker shaped like a giant skull on legs, built to obliterate troops, robots and tanks at long range. Six heavy auto-cannons ring the upper skull body, which rotates 360 degrees; the red eyes are infrared searchlights; the arms rotate 180 degrees at the shoulder; a top gunner''s hatch lets a SAMAS fire from its crown. It has a 20 foot blind spot at its feet and overhead, is slow and a large target, and suits defense and infantry assault better than city fighting. This version has more armor, three gunners instead of two and bigger cannon payloads than the Rifts Sourcebook One model; both serve, 70% of them improved. The intro calls it a five-man crew; the Crew line says six. P.S. 60; nuclear, 20 years; about four feet of storage. Standard CS robot vehicle features (printed 134): 30 mile radar and targeting, laser targeting (+1 initiative and strike with long-range weapons), 500 mile radio, ejector seats, self-destruct, voice-coded locks and a sealed environmental crew compartment. Hand to hand as the UAR-1 Enforcer except +4 to parry, restrained punch 1D6 M.D., full strength punch 3D6 M.D., power punch 5D6 M.D., body block 2D6 M.D., stomp 2D4 M.D., kick 1D6 M.D., no leap kick. Sensors: radar tracking 96 targets at 50 miles (80 km), thermo-imager 2000 feet (610 m), infrared and ultraviolet optics, a left-shoulder nightvision and video array, infrared searchlights 500 feet (152 m); +1 to strike with the long-range cannons.', 'Rifts World Book 11: Coalition War Campaign p.134-137'),
  ('iar-3-skull-smasher', 'IAR-3 Skull Smasher', 'rifts', 'robot', 'Five: pilot, co-pilot, communications officer and two gunners (one on the laser cannon and missiles, one on the particle beam and weapon monitoring); the pilot works the forearm guns', 'Two, comfortably', 'Running 90 mph (144.8 km) maximum; never tires. Leaps 30 feet (9 m) long or high with a short running start.', NULL, 'Walks the sea bottom at about 25% of its running speed; maximum depth one mile (1.6 km)', 'Height 28 feet (9.1 m) as printed (28 feet is about 8.5 m); width 14 feet (4.3 m), length 14 feet (4.3 m)', '80 tons fully loaded', 990, 74000000, 'CS Cost: 74 million credits for a new, fully loaded IAR-3. Not available on the Black Market; exclusive to the CS.', 'Infantry Assault Robot: the most heavily armored and perhaps most powerful robot in the CS armored division, a fast walking tank for front-line assault and heavy support. 600 are in service and 600 more due within six months. Its crews favor full-tilt rams and running leap kicks; knees and elbows are spiked and the eyes are sensor clusters flanked by spotlights. P.S. 60; nuclear, 20 years; about four feet of storage. Standard CS robot vehicle features (printed 134). Elite combat training of its own (others use Robot Basic): two attacks plus the pilot''s at level one, +1 at levels 3, 6, 10 and 14; critical strike as the pilot; +2 to roll with impact, +2 on initiative, +2 to strike, +4 to parry, +2 to dodge, +3 to pull punch. Restrained punch 1D6 M.D., full strength punch, elbow or knee 5D6 M.D., power punch 1D6x10 M.D. (two attacks), tear or pry 3D6 M.D., kick 5D6 M.D., running leap kick 2D4x10 M.D. (uses all but one attack; 01-75% knockdown, victim loses two actions and initiative), body block/ram 4D6 M.D., full speed running ram 2D4x10 M.D. (three attacks; 01-80% knockdown), stomp 3D6 M.D. against targets under 12 feet (3.6 m). Sensors as the IAR-2.', 'Rifts World Book 11: Coalition War Campaign p.137-140'),
  ('iar-4-hellraiser', 'IAR-4 Hellraiser', 'rifts', 'robot', 'Two: pilot and gunner. The gunner usually runs the plasma ejector, laser turret and missiles, the pilot the Quatro-Gun and vibro-claw; either can fire the electro-stunner', 'One passenger or a communications officer', 'Running 90 mph (144.8 km) maximum, 0-60 mph (96.5 km) in 10 seconds; never tires. Leaps 20 feet (6 m) long or high with a short running start.', NULL, 'Walks the sea bottom at about 25% of its running speed; maximum depth one mile (1.6 km)', 'Height 18 feet (9.1 m) as printed, standing erect, though it usually stands and runs crouched; width 10 feet (3.6 m) as printed; length 6 feet (1.8 m)', '35 tons fully loaded', 690, 47000000, 'CS Cost: 47 million credits for a new, fully loaded IAR-4. Not available on the Black Market; exclusive to the CS.', 'Infantry Assault Robot, the "Robot Killer": a comparatively small, fast and agile 18 foot robot built to fight other robots and tanks, a favorite of commandos and RPA pilots and argued by many to be a better Glitter Boy killer than the PA-300. It is the robot on the book''s cover; the cover''s gunner wears the CS Urban Warrior armor (50 M.D.C., 11 lbs/5 kg, -10% to prowl, -5% on other physical skills). The head is a sensor cluster tucked between the shoulders; the left hand is a vibro-claw that spins into a drill. P.S. 50; nuclear, 20 years; about four feet of storage. Standard CS robot vehicle features (printed 134). Elite combat training of its own (others use Robot Basic): two attacks plus the pilot''s at level one, +1 at levels 3, 7 and 11; critical strike as the pilot; +3 to roll with impact, +2 on initiative, +2 to strike, +2 to parry, +2 to dodge, +4 to pull punch. Restrained punch 1D6 M.D., full strength punch, elbow or knee 2D6 M.D., power punch 4D6 M.D. (two attacks), tear or pry 1D6 M.D., kick 2D6 M.D., running leap kick 1D4x10 M.D. (uses all but one attack; 01-45% knockdown against giants), body block/ram 3D6 M.D., full speed running ram 1D4x10 M.D. (three attacks), stomp 1D6 M.D. against targets under 10 feet (3 m). Sensors as the IAR-2.', 'Rifts World Book 11: Coalition War Campaign p.140-143'),
  ('iar-5-hellfire', 'IAR-5 Hellfire', 'rifts', 'robot', 'Two: pilot and gunner. The gunner usually runs the rail guns and mini-missiles, the pilot the plasma ejector and light lasers', 'One, squeezed in behind the seats', 'Running 120 mph (192 km) maximum, 0-60 mph (96.5 km) in 8 seconds; never tires. Leaps 30 feet (9 m) high or long with a short running start, 60 feet (18.3 m) jet assisted.', NULL, 'Walks the sea bottom at about 25% of its running speed, or 10 mph (16 km/8.5 knots) on its thrusters, about the same on the surface; maximum depth 4000 feet (1200 m)', 'Height 14 feet (4.2 m), width 10 feet (3.6 m) as printed, length 7 feet (2.1 m)', '25 tons, fully loaded', 480, 25000000, 'CS Cost: 25 million credits for a new, fully loaded IAR-5. Not available on the Black Market; exclusive to the CS.', 'Light Infantry Assault Robot: an experimental two-man, ostrich-like scout and hit-and-run robot with no arms; its weapon-laden upper body spins 360 degrees in a heartbeat. Pairs partner a Hellraiser, Skull Smasher or 1D4 Terror Troopers, scout ahead of Spider-Skull Walkers and armored patrols, or hunt in squads of 4-8. The access hatch between the legs has a 90 M.D.C. outer and 50 M.D.C. inner door, and the top flips open to eject. It has no head: more than 380 M.D.C. of damage to the domed main body knocks out its concealed sensors. P.S. 45; nuclear, 20 years; about three feet of storage. Standard CS robot vehicle features (printed 134). Elite combat training of its own (others use Robot Basic): one extra action plus the pilot''s at level one, +1 at levels 3, 6 and 12; critical strike as the pilot; +3 to roll with impact, +3 on initiative, +2 to strike with kicks, +2 to dodge standing and +4 running or leaping; no parry bonus and no punch. Kick 2D6 M.D., power kick 3D6 M.D. (two attacks), leap kick 3D6 M.D., running leap kick 6D6 M.D. (uses all but one attack; 01-35% knockdown against giants), body block/ram 2D6 M.D., full speed running ram 1D4x10 M.D. (three attacks), stomp 1D6 M.D. against targets under five feet (1.5 m). Sensors as the IAR-2. Its cost line and hand to hand heading were read off a render; the text layer sets them in corrupt glyphs.', 'Rifts World Book 11: Coalition War Campaign p.143-145'),
  ('cr-004-spider-scout-skull-walker', 'CR-004 Scout Spider-Skull Walker', 'rifts', 'robot', 'Two: pilot and gunner', 'Two passengers or prisoners', 'Running 100 mph (160.5 km) maximum. Leaps 10 feet (3 m) high or 20 feet (6 m) long. Climbs inclines up to 90 degrees.', NULL, 'Walks the sea bottom at about 25% of its running speed, or 10 mph (16 km/8.5 knots) on its thrusters, about the same on the surface; maximum depth one mile (1.6 km)', 'Height 12 feet (3.6 m), the skull about 6 feet (1.8 m); width 7 feet (2.1 m) at the skull, about 17 feet (5.1 m) across the legs; length about 17 feet (5.1 m) with legs extended, the skull 12 feet (3.6 m)', '12 tons fully loaded', 280, 22000000, 'CS Cost: 22 million credits for a new, fully loaded Spider Scout. Not available on the Black Market; exclusive to the CS.', 'Multi-purpose All-Terrain Assault Robot, the "Spider Scout": a six-legged, lower and faster reconnaissance and light infantry version of the CR-003 Spider-Skull Walker. Four usually escort each CR-003; they also go out alone, in pairs, squads of 4-10 or platoons, ahead of troops and armor, and clamber easily over ruins. It has no head: the skull is the main body, and its many sensors are nearly impossible to blind. It can lose one leg per side without losing balance, at -15% speed. No P.S. rating. Cargo about 4x4x4 feet (1.2 m) plus a weapons locker of six CP-40 laser rifles, two C-50 Dragonfire rifles, 24 E-clips and two smoke grenades. Nuclear, 25 years. Standard CS robot vehicle features (printed 134). Hand to hand, best against targets twice human size: leg strike (one or two legs, the pilot''s attacks) 2D4 M.D., stomp 1D6 M.D., head butt 1D6 M.D., leaping body block/ram 3D6 M.D. (01-40% knockdown; victim loses initiative and two actions). Sensors as the IAR-2 plus sonar, sound and video recording, a molecular analyzer that identifies 3000 airborne substances, multi-optic eye cameras (range printed "1200 feet/610 m") and low-light eyebrow cameras (300 feet/91.5 m). +1 on initiative, +1 to dodge, prowl/hide 44% +2% per level of the pilot.', 'Rifts World Book 11: Coalition War Campaign p.146-147'),
  ('cr-005-scorpion-skull-walker', 'CR-005 Scorpion-Skull Walker', 'rifts', 'robot', 'Two: pilot and gunner', 'One', 'Running 50 mph (80.4 km) maximum. Cannot leap.', NULL, 'Minimal: walks the sea bottom at about 25% of its running speed; maximum depth 2000 feet (610 m)', 'Height 5 feet (1.5 m), the legs rising 3 feet (0.9 m) more when running; width 6 feet (1.8 m) at the skull, about 18 feet (5.4 m) across the legs; length about 25 feet (7.6 m) with the tail flat, the skull 8 feet (2.4 m)', '14 tons fully loaded', 200, 26000000, 'CS Cost: 26 million credits for a new, fully loaded unit (the printed line says "Spider Scout", carried over from the CR-004). Not available on the Black Market; exclusive to the CS.', 'Multi-purpose All-Terrain Assault Robot, "the Scorpion": an experimental, very low-profile ambush walker derived from the CR-003, on six legs with two giant pincers and a weapon tail it must raise over its head to fire its main guns. It can crawl no higher than five feet and lie in wait; the crew recline and work through helmet displays and headjacks. 640 (one battalion) are in the field: 360 against Tolkeen, 140 on the northern and western borders, 140 in the Quebec campaign. Losing the head destroys the sensors, exposes the crew compartment, loses all robot combat bonuses and halves attacks and speed. Losing one or two legs costs 15% speed, three 50%. P.S. 45; no cargo; nuclear, 25 years. Standard CS robot vehicle features (printed 134). Hand to hand, best against targets twice human size: tail strike 2D4 M.D., pincer strike/punch 2D6 M.D., pincer scissor cut 4D6 M.D.; no power punch, kick or body block. Sensors as the IAR-2. +1 on initiative, prowl/hide 48% +2% per level of the pilot. BOOK SLIP: the location list prints "Legs (4)" although the text gives it six legs.', 'Rifts World Book 11: Coalition War Campaign p.148-150');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('fassar-20-30-skelebot', 'Hands (2)', 22, 'Each.', 1),
  ('fassar-20-30-skelebot', 'Arms (2)', 45, 'Each.', 2),
  ('fassar-20-30-skelebot', 'Vibro-Blades (2)', 25, 'Each.', 3),
  ('fassar-20-30-skelebot', 'CV-213 Laser Rifle (1)', 30, 'The FASSAR-20''s rifle; no figure is printed for the FASSAR-30''s C-200.', 4),
  ('fassar-20-30-skelebot', 'Legs (2)', 70, 'Each.', 5),
  ('fassar-20-30-skelebot', 'Head', 60, 'Destroying it removes all optics and sensors; the robot usually shuts down, but one in ten fights on blindly with no combat bonuses. Called shot only, at -2 to strike.', 6),
  ('fassar-20-30-skelebot', 'Main Body', 150, 'Depleting it destroys the bot.', 7),
  ('fassar-40-hunter-skelebot', 'Hands (2)', 32, 'Each.', 1),
  ('fassar-40-hunter-skelebot', 'Arms (2)', 65, 'Each.', 2),
  ('fassar-40-hunter-skelebot', 'Vibro-Blades (2)', 50, 'Each.', 3),
  ('fassar-40-hunter-skelebot', 'C-200 Rail Gun (1)', 50, 'Listed although the Hunter has no standard issue weapon.', 4),
  ('fassar-40-hunter-skelebot', 'Legs (2)', 100, 'Each.', 5),
  ('fassar-40-hunter-skelebot', 'Chest Compartment Plates/Hatch (2)', 40, 'Each.', 6),
  ('fassar-40-hunter-skelebot', 'Head', 90, 'As the FASSAR-20: usually shuts the robot down, one in ten fights on blindly. Called shot only, at -2 to strike.', 7),
  ('fassar-40-hunter-skelebot', 'Main Body', 210, 'Depleting it destroys the bot, which self-destructs to protect its cargo.', 8),
  ('fassar-50-hellion-skelebot', 'Hands (2)', 32, 'Each. As printed: two, though the Hellion has four arms.', 1),
  ('fassar-50-hellion-skelebot', 'Arms (2)', 65, 'Each. As printed: two, though the Hellion has four arms.', 2),
  ('fassar-50-hellion-skelebot', 'Vibro-blade (2)', 50, 'Each. As printed, though the text says it has no built-in vibro-blades.', 3),
  ('fassar-50-hellion-skelebot', 'C-200 Rail Gun (1)', 50, 'As printed; the text gives it no standard weapon.', 4),
  ('fassar-50-hellion-skelebot', 'Legs (2)', 100, 'Each.', 5),
  ('fassar-50-hellion-skelebot', 'Head', 90, 'As the FASSAR-20: usually shuts the robot down, one in ten fights on blindly. Called shot only, at -2 to strike.', 6),
  ('fassar-50-hellion-skelebot', 'Main Body', 200, 'Depleting it destroys the bot.', 7),
  ('fassar-60-centaur-skelebot', 'Hands (2)', 30, 'Each.', 1),
  ('fassar-60-centaur-skelebot', 'Arms (2)', 45, 'Each.', 2),
  ('fassar-60-centaur-skelebot', 'Forearm Weapons (2)', 25, 'Each.', 3),
  ('fassar-60-centaur-skelebot', 'Mini-Missile Cluster Launchers (2; back)', 50, 'Each.', 4),
  ('fassar-60-centaur-skelebot', 'Legs (4)', 75, 'Each.', 5),
  ('fassar-60-centaur-skelebot', 'Sensor Rods (2)', 10, 'Each.', 6),
  ('fassar-60-centaur-skelebot', 'Head', 90, 'As the FASSAR-20: usually shuts the robot down, one in ten fights on blindly. Called shot only, at -2 to strike.', 7),
  ('fassar-60-centaur-skelebot', 'Main Body', 180, 'Depleting it destroys the bot.', 8),
  ('iar-2-abolisher-assault-robot', 'Hands (2)', 100, 'Each.', 1),
  ('iar-2-abolisher-assault-robot', 'Arms (2)', 190, 'Each.', 2),
  ('iar-2-abolisher-assault-robot', 'Legs (2)', 240, 'Each.', 3),
  ('iar-2-abolisher-assault-robot', 'Main Auto-Cannons (6)', 100, 'Each.', 4),
  ('iar-2-abolisher-assault-robot', 'Belly Gun (1, turret)', 25, NULL, 5),
  ('iar-2-abolisher-assault-robot', 'Chest Spotlight Eyes (2)', 10, 'Each. Destroyed once the main body has taken 300 points of damage.', 6),
  ('iar-2-abolisher-assault-robot', 'Sensor Turret (left shoulder)', 80, 'Destroying it takes out the main radar and targeting (no bonuses to strike, parry or dodge). Called shot only, at -3 to strike.', 7),
  ('iar-2-abolisher-assault-robot', 'Gunner''s Hatch (1; top)', 100, 'Depleting it opens the robot to entry from above.', 8),
  ('iar-2-abolisher-assault-robot', 'Inner Hatch (1; top)', 50, 'Locks automatically; only the pilots can open it.', 9),
  ('iar-2-abolisher-assault-robot', 'Main Body', 590, 'Depleting it destroys the robot.', 10),
  ('iar-2-abolisher-assault-robot', 'Reinforced Pilot''s Compartment', 250, NULL, 11),
  ('iar-3-skull-smasher', 'Hands (2)', 110, 'Each.', 1),
  ('iar-3-skull-smasher', 'Arms (2)', 250, 'Each.', 2),
  ('iar-3-skull-smasher', 'Legs (2)', 350, 'Each.', 3),
  ('iar-3-skull-smasher', 'Heavy Laser Cannon (1; top right)', 140, NULL, 4),
  ('iar-3-skull-smasher', 'Medium-Range Missile Launchers (2; top left & right)', 130, 'As printed, one figure with no "each".', 5),
  ('iar-3-skull-smasher', 'Mini-Missile Launchers (3; center)', 40, 'Each. Called shot only, at -4 to strike.', 6),
  ('iar-3-skull-smasher', 'P-Beam Mouth Cannon (1)', 75, 'Printed "75 each" for a single cannon. Called shot only, at -4 to strike.', 7),
  ('iar-3-skull-smasher', 'Forearm Turrets (2)', 120, 'Each. Called shot only, at -4 to strike.', 8),
  ('iar-3-skull-smasher', 'Chest Spotlights (4)', 15, 'Each. Called shot only, at -4 to strike. Destroyed once the main body has taken 300 points of damage.', 9),
  ('iar-3-skull-smasher', 'Sensor Cluster Eyes (2)', 80, 'As printed, with no "each". Called shot only, at -4 to strike.', 10),
  ('iar-3-skull-smasher', 'Main Body', 990, 'Depleting it destroys the robot.', 11),
  ('iar-3-skull-smasher', 'Reinforced Pilot''s Compartment', 250, NULL, 12),
  ('iar-4-hellraiser', 'Hand (1; right)', 90, NULL, 1),
  ('iar-4-hellraiser', 'Vibro-Claw (1; left)', 90, NULL, 2),
  ('iar-4-hellraiser', 'Arms (2)', 210, 'Each.', 3),
  ('iar-4-hellraiser', 'Legs (2)', 250, 'Each.', 4),
  ('iar-4-hellraiser', 'Electro-Stunner (1; top right)', 40, NULL, 5),
  ('iar-4-hellraiser', 'Plasma Ejector (1; top right)', 140, NULL, 6),
  ('iar-4-hellraiser', 'Short-Range Missile Launcher (1; top left)', 120, NULL, 7),
  ('iar-4-hellraiser', 'Small Laser Turret (1; left cover)', 35, NULL, 8),
  ('iar-4-hellraiser', 'Quatro-Gun (1; hand-held)', 100, 'Its power cable has 25 M.D.C. and can only be hit by a called shot at -7.', 9),
  ('iar-4-hellraiser', 'Head/Sensor Cluster', 90, 'Destroying it removes all optical and sensory systems and every robot combat bonus. Called shot only, at -3 to strike.', 10),
  ('iar-4-hellraiser', 'Main Body', 690, 'Depleting it shuts the robot down completely.', 11),
  ('iar-4-hellraiser', 'Reinforced Pilot''s Compartment', 200, NULL, 12),
  ('iar-5-hellfire', 'Legs (2)', 250, 'Each.', 1),
  ('iar-5-hellfire', 'Rail Guns (2; sides)', 90, 'Each.', 2),
  ('iar-5-hellfire', 'Plasma Ejector (1; double barrel, center)', 50, 'Called shot only, at -4 to strike.', 3),
  ('iar-5-hellfire', 'Mini-Missile Launchers (2; sides)', 120, 'Each.', 4),
  ('iar-5-hellfire', 'Small Laser Turrets (2; undercarriage)', 25, 'Each. Called shot only, at -4 to strike.', 5),
  ('iar-5-hellfire', 'Small Rear Trusters (2; undercarriage)', 30, 'Each. Called shot only, at -4 to strike. "Trusters" as printed: the jet thrusters above the leg joints.', 6),
  ('iar-5-hellfire', 'Main Body', 480, 'Depleting it shuts the robot down. It is also the head: more than 380 M.D.C. of damage knocks out the concealed sensors, optics and radar and their bonuses.', 7),
  ('iar-5-hellfire', 'Reinforced Pilot''s Compartment', 180, NULL, 8),
  ('cr-004-spider-scout-skull-walker', 'Triple-Barreled Rail Guns (2)', 100, 'Each.', 1),
  ('cr-004-spider-scout-skull-walker', 'Laser Turret (1; undercarriage)', 80, NULL, 2),
  ('cr-004-spider-scout-skull-walker', 'Mini-Missile Launchers (2; side)', 100, 'Each.', 3),
  ('cr-004-spider-scout-skull-walker', 'Legs (6)', 100, 'Each. Losing one leg per side leaves it balanced, at -15% speed.', 4),
  ('cr-004-spider-scout-skull-walker', 'Leg Lights (6)', 5, 'Each.', 5),
  ('cr-004-spider-scout-skull-walker', 'Rear Jet Thrusters (2)', 50, 'Each.', 6),
  ('cr-004-spider-scout-skull-walker', 'Eye Searchlights (2)', 20, 'Each. Called shot only, at -4 to strike.', 7),
  ('cr-004-spider-scout-skull-walker', 'Eyebrow Cameras (4; two above each eye)', 5, 'Each. Called shot only, at -4 to strike.', 8),
  ('cr-004-spider-scout-skull-walker', 'Sensor Clusters (6; rear)', 25, 'Each. Called shot only, at -4 to strike.', 9),
  ('cr-004-spider-scout-skull-walker', 'Main Body/Skull', 280, 'Depleting it shuts the robot down completely.', 10),
  ('cr-004-spider-scout-skull-walker', 'Reinforced Crew Compartment', 150, NULL, 11),
  ('cr-005-scorpion-skull-walker', 'Gatling Rail Guns (3; tail)', 80, 'Each.', 1),
  ('cr-005-scorpion-skull-walker', 'Tail Lasers (2; tail)', 40, 'Each. Called shot only, at -5 to strike.', 2),
  ('cr-005-scorpion-skull-walker', 'Multiple Mini-Missile Launcher (1; tail)', 100, NULL, 3),
  ('cr-005-scorpion-skull-walker', 'Secondary Mini-Missile Launchers (2; tail)', 40, 'Each.', 4),
  ('cr-005-scorpion-skull-walker', 'Double-Barrelled Head Lasers (2 pair; head)', 40, 'Each. Called shot only, at -5 to strike.', 5),
  ('cr-005-scorpion-skull-walker', 'Giant Pincers (2)', 120, 'Each.', 6),
  ('cr-005-scorpion-skull-walker', 'Legs (4)', 120, 'Each. As printed "(4)", though the text gives it six legs. Losing one or two costs 15% speed, three 50%.', 7),
  ('cr-005-scorpion-skull-walker', 'Eye Searchlights (2)', 20, 'Each. Called shot only, at -5 to strike.', 8),
  ('cr-005-scorpion-skull-walker', 'Smoke Dispenser (1; grille/teeth of head)', 20, 'Called shot only, at -5 to strike.', 9),
  ('cr-005-scorpion-skull-walker', 'Eyebrow Cameras (4; two above each eye)', 5, 'Each. Called shot only, at -5 to strike.', 10),
  ('cr-005-scorpion-skull-walker', 'Sensor Cluster (1; nose)', 35, 'Called shot only, at -5 to strike.', 11),
  ('cr-005-scorpion-skull-walker', 'Tail Segments (3, including weapon segment)', 180, 'Each.', 12),
  ('cr-005-scorpion-skull-walker', 'Head (crew area)', 180, 'Destroying it removes all sensors and optics, exposes the inner crew compartment, loses all robot combat bonuses and halves attacks per melee and speed.', 13),
  ('cr-005-scorpion-skull-walker', 'Main Body/Skull', 200, 'Depleting it shuts the robot down completely.', 14),
  ('cr-005-scorpion-skull-walker', 'Reinforced Crew Compartment', 150, NULL, 15);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('fassar-20-30-skelebot', 1, 'CV-213 Robot Variable Laser Rifle (FASSAR-20)', '2D6 M.D. or 4D6 M.D. (two settings)', 1, '2000 feet (610 m)', 'Equal to the number of hand to hand attacks', 'E-clip of 20 shots, or effectively unlimited through the power pack hand link', NULL, 'Assault. The robot version of the C-212: the combat computer retunes the frequency after one melee round to defeat laser-resistant armor such as the Glitter Boy''s. 7 lbs (3.2 kg). The FASSAR-30 lacks the hand link and must use E-clips or E-canisters.'),
  ('fassar-20-30-skelebot', 2, '18 inch (0.45 m) Vibro-Blades (2; FASSAR-20)', '2D6 M.D. (vibro-saber)', 1, 'Hand to hand, about a 5.6 foot (1.7 m) reach', 'Five per melee', 'Not applicable', NULL, 'Assault, secondary defense. Swing out of each forearm; the hand behind an extended blade cannot hold anything. 2 lbs (0.9 kg).'),
  ('fassar-20-30-skelebot', 1, 'C-200 "Dead Man''s" Rail Gun (FASSAR-30)', '4D6 M.D. per 20 round burst; 1D4 M.D. single round', 1, '4000 feet (1200 m)', 'Equal to the bot''s hand to hand attacks (five)', 'Short clip 200 rounds (10 bursts), light drum 600 (30 bursts) or heavy drum 2000 (100 bursts); Skelebots usually carry a light or heavy drum', '+1 to strike (laser targeting scope)', 'Assault, secondary defense. FASSAR-30 standard weapon, unnumbered at the head of its own list. Gun 45 lbs (20.25 kg); black market 80,000 credits, poor availability.'),
  ('fassar-40-hunter-skelebot', 1, 'Concealed Forearm Vibro-Sabers (2)', '2D6 M.D.', 1, 'Hand to hand', 'Five attacks per melee', 'Not applicable', NULL, 'The book numbers no weapon systems for the Hunter; the sabers do not interfere with its hands, and the damage is from its hand to hand table. Any rail gun or rifle serves as its hand weapon.'),
  ('fassar-60-centaur-skelebot', 1, 'Mini-Missile Cluster Launchers (2)', 'Varies with missile; standard fragmentation (5D6 M.D.) or plasma (1D6x10 M.D.)', 1, 'About one mile', 'One at a time or in volleys of two, three or four', '20 total, ten per launcher', NULL, 'Anti-missile and anti-aircraft, secondary anti-personnel. Back of the upper torso.'),
  ('fassar-60-centaur-skelebot', 2, 'Double-Barrel Forearm Laser (1)', '2D6 M.D. single blast; 4D6 M.D. simultaneous double blast (one melee action)', 1, '2000 feet (610 m)', 'Each single or double blast counts as one melee attack', 'Effectively unlimited', NULL, 'Defense, secondary assault. Right forearm; cannot fire at the same target as the ion blaster.'),
  ('fassar-60-centaur-skelebot', 3, 'Triple-Barreled Ion Forearm Blaster (1)', '2D6 M.D. single, 4D6 M.D. simultaneous double or 6D6 M.D. triple blast', 1, '1200 feet (336 m) as printed; 1200 feet is about 366 m', 'Each single or multiple blast counts as one melee attack', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense. Left forearm; cannot fire at the same target as the laser.'),
  ('iar-2-abolisher-assault-robot', 1, 'C-144 Auto-Cannons (6)', '2D4x10 M.D. per single blast; 4D4x10 M.D. per double blast (two cannons on one target)', 1, '6000 feet (1828 m) effective; maximum 10,000 feet (3048 m), at -2 to strike beyond 6000 feet to about 7000 feet (2286 m) and -4 beyond that', 'Each cannon twice per melee: 2, 4, 6 or 12 shots. All 12 on one target means rotating the body (the last six -3 to strike, top gunner and belly turret idle, only six shots the next melee); without rotating, two cannons give four single or two double shots on one target', '240 total, 40 shells per cannon; a destroyed cannon''s shells divert to the others, and gunners can shift payloads between guns', NULL, 'Anti-tank, anti-armor and anti-dragon, secondary defense. 2 tons each; 90 degree arcs, leaving a 20 foot (6 m) blind spot at the feet and overhead. Pilots firing them get half the attacks.'),
  ('iar-2-abolisher-assault-robot', 2, 'CR-3T Dual Laser Turret (1, belly gun)', '4D6 M.D.', 1, '2000 feet (610 m)', 'Two per melee', 'Effectively unlimited', NULL, 'Defense, secondary assault. In the lower teeth, covering the cannons'' blind spot; rotates 180 degrees. Either pilot can fire it.'),
  ('iar-2-abolisher-assault-robot', 3, 'Top Gunner''s Hatch (1)', NULL, 0, NULL, NULL, NULL, NULL, 'A perch on the crown for a SAMAS or gunman to fire down from. Outer hatch 100 M.D.C.; the inner hatch locks automatically, 50 M.D.C.'),
  ('iar-3-skull-smasher', 1, 'Heavy Laser Cannon (1)', '1D6x10 M.D. per blast', 1, '6000 feet (1828 m)', 'Equal to the gunner''s attacks per melee (typically 3-5)', 'Effectively unlimited', NULL, 'Anti-aircraft and anti-armor, secondary defense. Above the head on an arm with a 45 degree arc.'),
  ('iar-3-skull-smasher', 2, 'Medium-Range Missile Launchers (2)', 'Varies with missile; standard heavy high explosive, plasma or multi-warhead smart bomb (+5 to strike)', 1, 'About 40 to 80 miles', 'One at a time or in volleys of two, three or four', 'Six total, three per launcher', NULL, 'Anti-aircraft, secondary anti-armor (tanks, robots, dragons).'),
  ('iar-3-skull-smasher', 3, 'Mini-Missile Launchers (3)', 'Varies with missile; standard fragmentation (5D6 M.D.) or plasma (1D6x10 M.D.)', 1, 'About one mile', 'One at a time or in volleys of two, three or four', '21 total, seven per tube', NULL, 'Anti-missile and anti-aircraft, secondary anti-personnel. Three caps above the skull face.'),
  ('iar-3-skull-smasher', 4, 'Double-Barreled Particle Beam Cannon (1)', '1D4x10 M.D. single blast; 2D4x10 M.D. simultaneous double blast (one melee action)', 1, '1400 feet (426.7 m)', 'Equal to the gunner''s attacks per melee (typically 3-5)', 'Effectively unlimited', NULL, 'Anti-aircraft and anti-armor, secondary defense. In the mouth of the Death''s Head.'),
  ('iar-3-skull-smasher', 5, 'Double-Barreled Forearm Ball Laser Turrets (2)', '4D6 M.D. single blast; 1D4x10+8 M.D. simultaneous double blast (one melee action)', 1, '4000 feet (1200 m)', 'Equal to the operator''s hand to hand attacks', 'Effectively unlimited', NULL, 'Defense, secondary assault. Rotate 180 degrees side to side and 90 up and down; both cannot fire at the same target.'),
  ('iar-4-hellraiser', 1, 'H-02 Electro-Stunner (1)', '1D6x10 S.D.C., 2D6 M.D. or 4D6 M.D. per blast (three settings); damage beyond the victim''s capacity electrocutes rather than stuns', 1, '200 feet (61 m)', 'Twice per melee', 'Effectively unlimited', NULL, 'Anti-personnel (capture), secondary anti-electronics: 01-55% chance to short out unshielded electronics, and a 01-33% chance it electrocutes the victim instead of stunning. Raised from a housing above the right shoulder.'),
  ('iar-4-hellraiser', 2, 'H-40 Plasma Ejector (1)', '1D4x10 M.D. per blast', 1, '2000 feet (610 m)', 'Equal to the gunner''s attacks per melee (typically 3-5)', 'Effectively unlimited', NULL, 'Anti-armor, secondary defense. Above and behind the right shoulder.'),
  ('iar-4-hellraiser', 3, 'Short-Range Missile Launcher (1)', 'Varies with missile type', 1, 'Two to five miles', 'One at a time or in a volley of two or three', 'Three total', NULL, 'Anti-armor, secondary anti-aircraft and missiles.'),
  ('iar-4-hellraiser', 4, 'H-L24 Double-Barreled Laser Turret (1)', '4D6 M.D. per simultaneous double blast (always fires in tandem; one melee action)', 1, '2000 feet (610 m)', 'Equal to the operator''s hand to hand attacks', 'Effectively unlimited', NULL, 'Anti-missile, secondary anti-personnel. Slides forward from the back of the left shoulder; 180 degrees side to side, 45 up and down.'),
  ('iar-4-hellraiser', 5, 'H-4 Quatro-Gun (1)', 'Short-range laser 2D6 M.D.; long-range laser 4D6 M.D.; particle beam 1D4x10 M.D.; torch/flame thrower 1D6 M.D. per short blast, 2D6 M.D. cutting or welding', 1, 'Short-range laser 1000 feet (305 m); long-range laser 3000 feet (914 m); particle beam 1400 feet (426.7 m); torch 100 feet (30.5 m)', 'Equal to the operator''s hand to hand attacks; each blast one attack, one setting at a time', 'Effectively unlimited through a power cable (25 M.D.C., called shot at -7); a severed cable takes 1D6x10 minutes to patch', NULL, 'Experimental hand-held multi-weapon and tool. Quirks: more than five minutes of continuous particle beam fire has a 01-50% chance to jam every setting for 1D4+1 melee rounds; after four straight flame blasts, range halves for five minutes.'),
  ('iar-4-hellraiser', 6, 'HV-60 Vibro-Claw (1)', '5D6 M.D. as a claw; 1D4x10+10 M.D. as a drill', 1, 'Arm''s reach, about 14 feet (4.2 m)', 'Equal to the pilot''s combined attacks (typically 3-6)', NULL, NULL, 'Anti-armor, secondary drilling tool. The double-bladed left hand spins to bore through M.D. armor, fortifications and support beams.'),
  ('iar-5-hellfire', 1, 'HF-36 Hellfire Rail Guns (2)', '1D4x10 M.D. per 40 round burst from one gun; 2D4x10 M.D. from both (the target must be wider than 11 feet/3.3 m)', 1, '4000 feet (1200 m)', 'Equal to combined hand to hand attacks (usually 4-6)', '10,000 rounds per drum: 250 bursts each, 500 total. Reloading needs special equipment or a giant robot: about 10 minutes untrained, five trained', NULL, 'Assault, secondary defense. Gatling-style, fixed forward on the sides; 300 lbs (135 kg) each.'),
  ('iar-5-hellfire', 2, 'HF-36 Double-Barrelled Plasma Ejector (1)', '5D6 per single barrel blast (no unit printed); 1D6x10 M.D. simultaneous double barrel blast', 1, '1600 feet (488 m)', 'Equal to the gunner''s attacks per melee (typically 3-6)', 'Effectively unlimited', NULL, 'Anti-armor, secondary anti-personnel. Center; 45 degree arc. The book gives it the rail guns'' HF-36 designation.'),
  ('iar-5-hellfire', 3, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'One mile (1.6 m) as printed; a mile is 1.6 km', 'One at a time or in a volley of two, four or eight', '32 total, 16 per launcher', NULL, 'Anti-armor, power armor and anti-robot, secondary anti-personnel. Shoulders.'),
  ('iar-5-hellfire', 4, 'HF-12 Single-Barrelled Laser Turrets (2)', '3D6 M.D. per shot; the two cannot fire at the same target', 1, '2000 feet (610 m)', 'Equal to the operator''s hand to hand attacks', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense. Under each missile launcher; 360 degree rotation, 45 degree arc.'),
  ('cr-004-spider-scout-skull-walker', 1, 'C-104 Spider Tri-Barrel Rail Guns (2)', '1D4x10 M.D. per 60 round burst from one gun; 2D4x10 M.D. from both', 1, '6000 feet (1828 m)', 'Equal to combined hand to hand attacks (usually 4-6)', '10,000 rounds per drum: 166 bursts each, 332 total. Reloading needs special equipment or a giant robot: about 30 minutes untrained, 15 trained', NULL, 'Assault, secondary defense; good anti-missile and anti-aircraft guns. Rear sides, 75 degree arcs.'),
  ('cr-004-spider-scout-skull-walker', 2, 'CR-2T Laser Turret (1)', '5D6 M.D. per dual blast', 1, '2000 feet (610 m)', 'Equal to combined hand to hand attacks (usually 4-6)', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense. Double-barrelled, under the chin; 360 degree rotation, 60 degree arc.'),
  ('cr-004-spider-scout-skull-walker', 3, 'Mini-Missile Launchers (2)', 'Varies with missile; standard fragmentation (5D6 M.D.) or plasma (1D6x10 M.D.)', 1, 'About one mile', 'One at a time or in volleys of two, three or four', '20 total, ten per launcher', NULL, 'Anti-missile and anti-aircraft, secondary anti-personnel. In the skull''s cheeks.'),
  ('cr-004-spider-scout-skull-walker', 4, 'Smoke Dispenser', 'Smoke cloud 60 feet (18.3 m) across, or tear gas', 0, NULL, NULL, 'Eight total; usually four smoke and four tear gas', NULL, 'Rear undercarriage; the cloud covers the area behind it.'),
  ('cr-005-scorpion-skull-walker', 1, 'Tail Rail Guns (3)', '1D4x10 M.D. per 40 round burst from one gun; 2D4x10 M.D. from two; 3D4x10 M.D. from all three (one melee action)', 1, '4000 feet (1200 m)', 'Equal to the gunner''s combined hand to hand attacks (usually 4-6)', '8,000 rounds per gun: 200 bursts each, 600 total. Reloading needs special equipment or a giant robot: about an hour untrained, 25 minutes trained', NULL, 'Anti-armor and anti-robot, secondary anti-personnel. Gatling-style in the tail tip; the weapon segment points 180 degrees any way but backwards.'),
  ('cr-005-scorpion-skull-walker', 2, 'Tail Lasers (2)', '3D6 M.D. single blast; 6D6 M.D. simultaneous double blast', 1, '2000 feet (610 m)', 'Equal to the gunner''s combined hand to hand attacks (usually 3-6)', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense. Fixed below the rail guns; aimed with the tail.'),
  ('cr-005-scorpion-skull-walker', 3, 'Tail Multiple Mini-Missile Launcher (1)', 'Varies with missile; standard fragmentation (5D6 M.D.) or plasma (1D6x10 M.D.)', 1, 'About one mile', 'One at a time or in volleys of two, three or four', '18 total', NULL, 'Anti-missile and anti-aircraft, secondary anti-armor. On top of the tail.'),
  ('cr-005-scorpion-skull-walker', 4, 'Tail Mini-Missile Launcher (2)', 'Varies with missile; standard fragmentation (5D6 M.D.) or plasma (1D6x10 M.D.)', 1, 'About one mile', 'One at a time or in volleys of two, three or four', '10 total, five per launcher', NULL, 'Anti-missile and anti-aircraft, secondary anti-armor. Back-up launchers.'),
  ('cr-005-scorpion-skull-walker', 5, 'Skull, Double-Barreled Lasers (2)', '4D6 M.D. per pair of blasts from one pair; 8D6 M.D. with both pairs simultaneously', 1, '2000 feet (610 m)', 'Equal to the pilot''s combined hand to hand attacks (usually 3-6)', 'Effectively unlimited', NULL, 'Anti-personnel, secondary defense. Front of the head; 45 degree arc, and the head turns 30 degrees either way.'),
  ('cr-005-scorpion-skull-walker', 6, 'Smoke Dispenser', 'Smoke cloud 60 feet (18.3 m) across, or tear gas', 0, NULL, NULL, 'Eight total; usually four smoke and four tear gas', NULL, 'In the mouth of the skull.');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the 10 machines of printed 122-149' AS assertion, count(*) AS got, 10 AS want
  FROM vehicles WHERE slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker')
    AND source_book LIKE 'Rifts World Book 11: Coalition War Campaign p.%';

SELECT 'their M.D.C. locations: 7 + 8 + 7 + 8 + 11 + 12 + 12 + 8 + 11 + 15' AS assertion, count(*) AS got, 99 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker');

SELECT 'their weapon entries: 3 + 1 + 0 + 3 + 3 + 5 + 6 + 4 + 4 + 6' AS assertion, count(*) AS got, 35 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker');

SELECT 'main bodies: 150 + 210 + 200 + 180 + 590 + 990 + 690 + 480 + 280 + 200' AS assertion, sum(mdc_main_body) AS got, 3970 AS want
  FROM vehicles WHERE slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker');

SELECT 'every one priced, and every price explained' AS assertion, count(*) AS got, 10 AS want
  FROM vehicles WHERE slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker')
    AND cost IS NOT NULL AND cost_note IS NOT NULL;

SELECT 'the four Skelebots are drones, the six crewed machines robots' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles WHERE slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot')
    AND vehicle_class = 'drone';

SELECT 'every main body location matches its vehicle' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles v JOIN vehicle_locations l ON l.vehicle_slug = v.slug AND l.location IN ('Main Body', 'Main Body/Skull')
  WHERE v.slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker')
    AND l.mdc <> v.mdc_main_body;

SELECT 'prices: 3 + 3.8 + 4.6 + 4.8 + 80 + 74 + 47 + 25 + 22 + 26 million' AS assertion, sum(cost) AS got, 290200000 AS want
  FROM vehicles WHERE slug IN ('fassar-20-30-skelebot', 'fassar-40-hunter-skelebot', 'fassar-50-hellion-skelebot', 'fassar-60-centaur-skelebot', 'iar-2-abolisher-assault-robot', 'iar-3-skull-smasher', 'iar-4-hellraiser', 'iar-5-hellfire', 'cr-004-spider-scout-skull-walker', 'cr-005-scorpion-skull-walker');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-cwc-vessels-p122-149.sql');
