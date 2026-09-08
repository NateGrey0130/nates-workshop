-- Free Quebec vessels from printed pages 105-123 - three power armor and the
-- four full-conversion cyborg bodies. Seven rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-free-quebec-vessels-p105-123.sql
--
-- A VESSEL BELONGS TO THE SLICE ITS NAME HEADING FALLS IN, which is why the
-- FX-370C Leviathan is here rather than in the p124-134 file: its heading is on
-- printed 121. Its hand-to-hand Combat Bonuses and damage table run onto
-- printed 124, one page into the next slice, and are folded in below - the row
-- is complete, assembled from both readings rather than truncated at the seam.
--
-- THE FOUR FX BODIES ARE VESSELS AND ALSO CLASSES. Each entry opens with a
-- "Typical Training/Skills" list that belongs to the character rather than the
-- machine; those are NOT here. They are in the five Free Quebec cyborg classes,
-- which restate them because a `variants` block cannot add a skill -
-- BOOK-INGEST-AUDIT.md F31.
--
-- THE ARMOR NOTE ON A CYBORG MAIN BODY IS NOT PART OF THE FIGURE. Each of these
-- prints a base main body plus a schedule of bonuses for light, medium or heavy
-- cyborg armor. mdc_main_body holds the BASE; the armor schedule is in the
-- location's note, where it can be read rather than silently added.
--
-- THE SLASHER'S ARMOR NOTE IS SHAPED DIFFERENTLY FROM THE OTHER THREE and is
-- recorded as printed: a single flat +270 from its light infantry armor, rather
-- than the light/medium/heavy ladder. Its movement penalties are also printed
-- AFTER the Statistical Data rather than inside the M.D.C. note.
--
-- THE LEVIATHAN'S ASTERISKS DO NOT RESOLVE. Five weapon-mounted locations carry
-- a single asterisk and the entry's only footnote defines "*" as the head-kill
-- rule, which cannot apply to a thruster. It reads as a carry-over of the
-- power-armor convention where "*" means a small, difficult target. Recorded on
-- each location rather than guessed at.
--
-- TWO PRINTED FIGURES ARE FLAGGED RATHER THAN CORRECTED: the Leviathan's plasma
-- torch has a "Market Cost: 140,00 credits", which is missing a digit, and the
-- Slasher's cost is spelled "Five million credits" in words where every other
-- vessel in this book uses numerals.
--
-- INSERT OR IGNORE THROUGHOUT, and the readbacks COUNT rather than trusting
-- the exit code.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('qpa-201-power-trooper', 'QPA-201 Power Trooper', 'rifts', 'power-armor', 'One', NULL, 'Running: 40 mph (64 km) maximum, nought to 40 in ten seconds, at 10% of the normal fatigue rate. Leaping: about 12 feet (3.6 m) unassisted; jet assisted 60 feet high or 200 feet across; power jumping from a running start reaches 100 feet high or 300 feet lengthwise, averaging 40 feet of height, and sustains 180 mph (288 km) over ground by leap-and-run cycles - reduced 40-50% in dense terrain.', 'Limited flight only: maximum 80 mph (128 km), cruising about 40 mph (64 km), maximum altitude 200 feet. The jets overheat after an hour of continuous flight, sputter to half speed, and cut out after another 3D6 minutes.', 'Swims the surface at 60 mph (96 km) prone, torpedo-style, and walks the sea bottom at about 20 mph (32 km). Maximum ocean depth 3000 feet (1828 m).', 'Height: 14 feet (4.3 m); Width: 6 feet 6 inches (2 m); Length: 5 feet (1.5 m)', '6 tons fully loaded', 295, 6000000, 'Free Quebec cost 6 million credits; exclusive to the Free Quebec military. Not available on the black market or to the CS.', 'A heavy assault power armor combining the SAMAS and T-31 Super Trooper concepts into something slower, more heavily armed and much better armored. It underperforms as a flagship design against the Glitter Boys and excels in wilderness and urban operations - and, unexpectedly, underwater, where a naval variant swaps mini-torpedoes for its mini-missiles. Its main body does NOT use Glitter Boy materials, so it is not laser resistant.', 'Rifts World Book 22: Free Quebec p.105-107'),
('qpa-101-pale-death-samas', 'QPA-101 "Pale Death" SAMAS', 'rifts', 'power-armor', 'One', NULL, 'Running: 60 mph (96 km) maximum, nought to 60 in twelve seconds, at 10% of the normal fatigue rate. Leaping: 15 feet (4.6 m) unassisted; jet assisted 100 feet high or 200 feet across.', 'Maximum 300 mph (480 km), cruising 150 mph (240 km). The suggested maximum altitude is 500 feet but it has been flown to 6000 feet (1829 m) in the field; optimal engagement range is ground level to 1000 feet (305 m).', 'Swims 4 mph (6.4 km) and walks the sea bottom at about 25% of running speed. On jets: 50 mph (80 km) on the surface, 40 mph (64 km) underwater, or it can fly above the surface at normal speed. Maximum ocean depth 1000 feet (305 m).', 'Height: 8 feet (2.4 m); Width: 3 feet 6 inches (1.06 m) with wings down, 10 feet (3 m) with wings extended; Length: 4 feet 6 inches (1.4 m)', '340 lbs (153 kg) without the rail gun', 250, 1600000, 'Free Quebec cost 1.6 million credits. The black market sells captured, undamaged or rebuilt QPA-101s for 2.4 to 3 million - the same as a CS SAMAS - or 1.5 to 2 million without the weapon systems. Rarely available.', 'Free Quebec''s own retooled, cosmetically distinct version of the Coalition PA-06A "Death''s Head" SAMAS, manufactured and fielded here for decades and painted pale blue rather than black. Mechanically it is near-identical to the classic SAMAS apart from slight M.D.C. improvements.', 'Rifts World Book 22: Free Quebec p.107-110'),
('violator-samas-qpa-102', 'QPA-102 "Violator" SAMAS (V-SAM)', 'rifts', 'power-armor', 'One', NULL, 'Running: 70 mph (113 km) maximum. Leaping: 20 feet (6 m) unassisted; jet assisted 100 feet high or 200 feet across.', 'Maximum 360 mph (576 km), cruising 60-150 mph (96-240 km), maximum altitude 10,000 feet (3048 m).', 'Swims 4 mph (6.4 km) and walks the sea bottom at 20 mph (32 km). On jets: 60 mph (96 km) on the surface, 40 mph (64 km) underwater. Maximum ocean depth 2000 feet (610 m).', 'Height: 8 feet 6 inches (2.6 m) head to toe, plus 2 feet (0.6 m) for the top air intakes, so 10 feet 6 inches (3.2 m) overall; Width: 3 feet 7 inches (1.1 m) with wings down, 16 feet (4.9 m) with wings extended; Length: 4 feet 10 inches (1.45 m)', '680 lbs (306 kg) fully loaded', 312, 2100000, 'Free Quebec cost 2.1 million credits. Exclusive to the Quebec Military; not available on the black market or to the CS.', 'Free Quebec''s own SAMAS variant, built for air superiority, dogfighting and Glitter Boy escort. Its bladed "feather" wings are usable as melee weapons and it is shielded against sonic booms so it can work alongside the Boom Guns. After the Glitter Boy it is the nation''s most popular power armor.', 'Rifts World Book 22: Free Quebec p.111-113'),
('fx-200c-imprimer', 'FX-200C Imprimer Cyborg', 'rifts', 'borg', 'One human volunteer', NULL, 'Running: 80 mph (128 km) in heavy armor, 100 mph (160 km) in standard medium armor, or 120 mph (192 km) in light armor or none. Leaping: 15 feet (4.6 m) high or lengthwise, plus 20 feet (6.1 m) with a running start.', 'Jet pack only, with speed reduced 30% for the cyborg''s weight.', 'The book prints NO Underwater Capabilities section for this model, alone among the four FX bodies.', 'Height: 7 feet 6 inches (2.3 m); Width: 4 feet (1.2 m); Length: 3 feet (0.9 m)', '1000 lbs (450 kg)', 180, 4800000, 'Cost 4.8 million credits with all standard features and weapons.', 'A medium-assault full conversion cyborg body built for speed, agility and reconnaissance as well as full infantry work, in matte black plating accented light grey-green with two or three spikes crowning the helmet. The face plate is a stark, featureless robot mask, and underneath it the soldier usually keeps their own face or a human-looking facsimile - the book says it helps them stay in touch with their humanity.', 'Rifts World Book 22: Free Quebec p.115-116'),
('fx-320c-dervish', 'FX-320C Dervish Cyborg', 'rifts', 'borg', 'One human volunteer', NULL, 'Running: 100 mph (160 km) in medium infantry armor, or 120 mph (192 km) in light armor or none. Leaping: 15 feet (4.6 m), plus 20 feet (6.1 m) with a running start.', 'Jet pack only, at half speed for the cyborg''s weight.', 'The book prints no Underwater Capabilities section for this model.', 'Height: 8 feet (2.4 m); Width: 4 feet 6 inches (1.4 m); Length: 3 feet (0.9 m)', '1300 lbs (585 kg)', 200, 5600000, 'Cost 5.6 million credits with all standard features and weapons.', 'A covert action and assassination cyborg with FOUR ARMS, built for close combat and stealth. It rarely carries heavy forearm weapons or heavy armor, preferring light kit to keep its mobility; at least half are sent behind enemy lines alone, in pairs or in small squads to stalk, pick off and sabotage. Its priority targets are officers, communications personnel, special advisors, enemy spies and reconnaissance teams.', 'Rifts World Book 22: Free Quebec p.117-118'),
('fx-340c-slasher', 'FX-340C Slasher Cyborg', 'rifts', 'borg', 'One human volunteer', NULL, 'Running: 100 mph (160 km) in light infantry armor, or 120 mph (192 km) in light espionage armor or none. Leaping: 25 feet (7.6 m), plus 30 feet (9.1 m) with a running start.', 'Jet pack only, at half speed for the cyborg''s weight.', 'The book prints no Underwater Capabilities section for this model.', 'Height: 8 feet (2.4 m); Width: 4 feet (1.2 m); Length: 3 feet (0.9 m) for the body alone, 4 feet (1.2 m) including the launch tubes', '1000 lbs (450 kg)', 180, 5000000, 'Cost five million credits with all standard features and weapons. PRINTED IN WORDS - "Five million credits" - where every other vessel in this book uses numerals. Recorded because it is the kind of difference that looks like a transcription error later.', 'A Triax-origin "Gold Type" cyborg, reprinted from Rifts: Triax and the NGR p.103 with added text, acquired in bulk before the war and folded into Free Quebec''s forces. Its demonic face plate is for intimidation and it deliberately keeps its hands free for demolitions and assault work; it is favoured for espionage and seek-and-destroy missions.', 'Rifts World Book 22: Free Quebec p.119-121'),
('fx-370c-leviathan', 'FX-370C Leviathan Cyborg', 'rifts', 'borg', 'One human volunteer', NULL, 'Running: 70 mph (112 km) in cyborg infantry armor, or 80 mph (128 km) without. Leaping: 15 feet (4.6 m), plus 20 feet (6.1 m) with a running start.', 'Jet pack only, at half speed for the cyborg''s weight.', 'Swims unaided at 15 mph (24 km or 13 knots), or 20 mph (32 km or 17 knots) on its built-in propulsion. With the detachable Sea Dragon-style back propulsion unit: 55 mph (88 km or 47 knots) on the surface or underwater. Maximum depth 2000 feet (610 m), with risked dives to 2300 feet (701 m) and a decompression risk.', 'Height: 10 feet (3 m); Width: 5 feet (1.5 m); Length: 3 feet 5 inches (1 m), or 5 feet (1.5 m) with the propulsion system attached', '2690 lbs (1210.5 kg), plus 240 lbs (108 kg) for the detachable propulsion unit', 220, 6200000, 'Cost 6.2 million credits with all standard features and weapons.', 'A ten-foot amphibious assault cyborg fielded mainly by the Quebec Navy, which takes 70% of them, and Special Forces, which takes 25%. It is built for underwater insertion, sabotage of enemy vessels and hit-and-run naval combat, and uses a Sea Dragon-style detachable propulsion pack for high-speed underwater travel.', 'Rifts World Book 22: Free Quebec p.121-124');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('qpa-201-power-trooper', 'Hand-Held Gun (1)', 80, 'Small and difficult target: called shot only, attacker -3 to strike.', 1),
('qpa-201-power-trooper', 'Shoulder Mini-Missile Launchers (2)', 75, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 2),
('qpa-201-power-trooper', 'Folding Launcher (1, left shoulder)', 80, NULL, 3),
('qpa-201-power-trooper', 'Shoulder Mounted Laser Cannon and Launcher (1, right)', 120, NULL, 4),
('qpa-201-power-trooper', 'Forearm Weapon Package (1, left)', 75, 'Small and difficult target: called shot only, attacker -3 to strike.', 5),
('qpa-201-power-trooper', 'Chest Spotlight (1)', 4, 'Small and difficult target: called shot only, attacker -3 to strike.', 6),
('qpa-201-power-trooper', 'Lower Arms (2)', 115, 'each', 7),
('qpa-201-power-trooper', 'Hands (2)', 40, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 8),
('qpa-201-power-trooper', 'Legs (2)', 140, 'each', 9),
('qpa-201-power-trooper', 'Main Thrusters (2, back)', 100, 'each', 10),
('qpa-201-power-trooper', 'Maneuvering Jets (12; six front, six back)', 25, 'each. Small and difficult target: called shot only, attacker -3 to strike.', 11),
('qpa-201-power-trooper', 'Head', 110, 'Destroying it kills every optical and sensory system and all power armor combat bonuses. Small and difficult target: called shot only, attacker -3 to strike.', 12),
('qpa-201-power-trooper', 'Main Body', 295, 'Depleting the main body shuts the armor down completely. It does NOT use Glitter Boy materials, so it has no laser resistance.', 13),
('qpa-101-pale-death-samas', 'Shoulder Wings (2)', 50, 'each, improved over the Coalition original. Called shot only, attacker -4 to strike. Destroying a wing ends flight, though jet-assisted leaping and hovering still work.', 1),
('qpa-101-pale-death-samas', 'Main Rear Jets (2)', 60, 'each', 2),
('qpa-101-pale-death-samas', 'Lower Maneuvering Jets (2, small)', 25, 'each', 3),
('qpa-101-pale-death-samas', 'Ammo Drum (rear)', 35, 'Called shot only, attacker -4 to strike.', 4),
('qpa-101-pale-death-samas', 'Rail Gun', 50, 'Called shot only, attacker -4 to strike.', 5),
('qpa-101-pale-death-samas', 'Forearm Mini-Missile Launcher (1, left)', 50, NULL, 6),
('qpa-101-pale-death-samas', 'Hands (2)', 25, 'each. Called shot only, attacker -4 to strike.', 7),
('qpa-101-pale-death-samas', 'Arms (2)', 50, 'each', 8),
('qpa-101-pale-death-samas', 'Legs (2)', 100, 'each', 9),
('qpa-101-pale-death-samas', 'Head', 70, 'Shielded by the exhaust tubes and the weapon drum, so it is a small and difficult target: called shot only, attacker -3 to strike. Destroying it kills the optics and sensors and every combat bonus.', 10),
('qpa-101-pale-death-samas', 'Main Body', 250, 'Depleting the main body shuts the armor down completely.', 11),
('violator-samas-qpa-102', 'Shoulder Wings (2)', 115, 'each. Called shot only, attacker -4 to strike. Destroying a wing ends flight, though jet-assisted leaping and hovering still work. These are the bladed "feather" wings the V-SAM fights with.', 1),
('violator-samas-qpa-102', 'Shoulder Fins (2)', 25, 'each. Called shot only, attacker -4 to strike.', 2),
('violator-samas-qpa-102', 'Main Rear Jets (3, top)', 100, 'each', 3),
('violator-samas-qpa-102', 'Lower Maneuvering Jets (3, lower)', 60, 'each', 4),
('violator-samas-qpa-102', 'Jet Intakes (2, top and front)', 50, 'each', 5),
('violator-samas-qpa-102', 'Wing Mini-Missile Launchers (2)', 25, 'each. Called shot only, attacker -4 to strike.', 6),
('violator-samas-qpa-102', 'Laser Gun', 60, 'Called shot only, attacker -4 to strike.', 7),
('violator-samas-qpa-102', 'Hands (2)', 25, 'each. Called shot only, attacker -4 to strike.', 8),
('violator-samas-qpa-102', 'Arms (2)', 70, 'each', 9),
('violator-samas-qpa-102', 'Legs (2)', 120, 'each', 10),
('violator-samas-qpa-102', 'Head', 90, 'Shielded by the intakes and thrusters: called shot only, attacker -3 to strike. Destroying it kills the optics, sensors and combat bonuses.', 11),
('violator-samas-qpa-102', 'Main Body', 312, 'Depleting the main body shuts the armor down completely.', 12),
('fx-200c-imprimer', 'Hands (2)', 15, 'each. The footnote says hands are a difficult target at -4 on a called shot, though the list itself carries no marker on this row - a printing inconsistency shared by all four FX bodies.', 1),
('fx-200c-imprimer', 'Arms (2)', 40, 'each', 2),
('fx-200c-imprimer', 'Vibro-Blade', 30, NULL, 3),
('fx-200c-imprimer', 'TX-500 Rail Gun', 75, NULL, 4),
('fx-200c-imprimer', 'Rail Gun Ammo Drum', 75, NULL, 5),
('fx-200c-imprimer', 'Legs (2)', 70, 'each', 6),
('fx-200c-imprimer', 'Head (reinforced)', 65, 'DESTROYING THE HEAD KILLS THE CHARACTER. Small and difficult target: called shot only, attacker -3 to strike.', 7),
('fx-200c-imprimer', 'Main Body (standard)', 180, 'THE BASE FIGURE ONLY. Add 130 M.D.C. for light body armor, 230 for medium, or 360 for heavy cyborg armor, and increase the head, arms and legs by 25% for light, 50% for medium and 70% for heavy. Cyborg armor hooks directly to the bionic body. Most Imprimers wear light or medium unless in a front-line infantry assault. Armor penalties: -5% on Prowl, Climb, Swim, Acrobatics and similar physical skills for light, -10% medium, -20% heavy. Depleting the main body destroys the artificial body, but life support keeps the brain and organs alive for 36 hours - the character dies if not recovered in time, and 125 points past zero is total, unrecoverable destruction.', 8),
('fx-320c-dervish', 'Hands (2, large)', 15, 'each', 1),
('fx-320c-dervish', 'Arms (4, large)', 40, 'each. FOUR ARMS is the Dervish''s defining feature.', 2),
('fx-320c-dervish', 'Hands (2, small)', 10, 'each', 3),
('fx-320c-dervish', 'Vibro-Blades (4)', 30, 'each', 4),
('fx-320c-dervish', 'Legs (2)', 90, 'each', 5),
('fx-320c-dervish', 'Head (reinforced)', 70, 'DESTROYING THE HEAD KILLS THE CHARACTER. Small and difficult target: called shot only, attacker -3 to strike.', 6),
('fx-320c-dervish', 'Main Body (standard)', 200, 'THE BASE FIGURE ONLY. Add 130 M.D.C. for light body armor or 230 for medium; it NEVER wears the heavy 360 M.D.C. cyborg armor except as a disguise. Increase head, arms and legs by 25% for light, 50% for medium, 70% for heavy. Most Dervish prefer light armor to preserve speed, stealth and agility. Armor penalties: -5% on Prowl, Climb, Swim, Acrobatics and similar for light, -10% medium, -20% heavy. Depleting the main body destroys the artificial body; life support keeps the brain alive 36 hours, and 125 past zero is unrecoverable.', 7),
('fx-340c-slasher', 'Hands (2)', 15, 'each', 1),
('fx-340c-slasher', 'Arms (2)', 40, 'each', 2),
('fx-340c-slasher', 'Vibro-Blades (2)', 10, 'each', 3),
('fx-340c-slasher', 'Mini-Missile Launch Tubes (4, back)', 20, 'each', 4),
('fx-340c-slasher', 'TX-500 Rail Gun', 75, NULL, 5),
('fx-340c-slasher', 'Rail Gun Ammo Drum', 75, NULL, 6),
('fx-340c-slasher', 'Legs (2)', 80, 'each', 7),
('fx-340c-slasher', 'Head (reinforced)', 90, 'DESTROYING THE HEAD KILLS THE CHARACTER. Small and difficult target: called shot only, attacker -3 to strike.', 8),
('fx-340c-slasher', 'Main Body (normal)', 180, 'THE BASE FIGURE ONLY, and this one is shaped differently from the other three FX bodies: a single flat "plus an additional 270 M.D.C. from its light infantry armor (hooks directly to the bionic body)", with no light/medium/heavy ladder. Its movement penalties are printed AFTER the Statistical Data rather than inside this note: the light infantry armor is excellent protection but genuinely heavy, giving -1 to parry and dodge, -1 to roll with impact, and -20% to Prowl. Depleting the main body destroys the artificial body; life support keeps the brain alive 36 hours, and 125 past zero is unrecoverable.', 9),
('fx-370c-leviathan', 'Hands (2)', 22, 'each', 1),
('fx-370c-leviathan', 'Arms (2)', 65, 'each', 2),
('fx-370c-leviathan', 'Legs (2)', 100, 'each', 3),
('fx-370c-leviathan', 'Shoulder Mini-Missile/Torpedo Launcher (1, left)', 30, 'Carries a single asterisk whose footnote is the head-kill rule and cannot apply here; it reads as the power-armor convention for a small, difficult target. Recorded, not resolved.', 4),
('fx-370c-leviathan', 'Forearm Blaster (1, left)', 20, 'Same unresolved asterisk.', 5),
('fx-370c-leviathan', 'Vibro-Blade (1, right arm)', 30, 'Same unresolved asterisk.', 6),
('fx-370c-leviathan', 'Small Thrusters (4 back, 2 feet)', 8, 'each. Same unresolved asterisk.', 7),
('fx-370c-leviathan', 'Chest Thrusters (2)', 30, 'each. Same unresolved asterisk.', 8),
('fx-370c-leviathan', 'Head (reinforced)', 90, 'DESTROYING THE HEAD KILLS THE CHARACTER. Small and difficult target: called shot only, attacker -3 to strike.', 9),
('fx-370c-leviathan', 'Main Body (normal)', 220, 'THE BASE FIGURE ONLY. Add 220 M.D.C. for medium armor or 380 for heavy; it NEVER wears light armor. Increase head, arms and legs by 50% when wearing medium or heavy cyborg body armor. Armor penalties on land: -10% on Prowl, Climb, Acrobatics and similar skills needing agility; only -5% underwater, where buoyancy defers the weight. Depleting the main body destroys the artificial body; life support keeps the brain alive 36 hours, and 125 past zero is unrecoverable.', 10);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire,
   payload, bonus, note)
VALUES
('qpa-201-power-trooper', 1, 'QRL-201 High-Powered Laser Rifle (1)', '3D6 M.D. per single shot, or 1D4x10 M.D. per rapid burst of four shots counting as one melee action', 1, '2000 feet (610 m)', 'Equal to the total hand to hand attacks of the pilot', '60 shots, or unlimited via a cable to the robot power supply - but the cable can be cut', NULL, 'REQUIRES A ROBOT P.S. OF 28 OR BETTER: below that the firer is -3 to strike and -2 on initiative. It is too large for a cyborg or a man-sized power armor.'),
('qpa-201-power-trooper', 2, 'Shoulder Laser Cannon (1)', '6D6 M.D. per blast. No bursts.', 1, '4000 feet (1220 m)', 'Equal to the total hand to hand attacks of the pilot', 'Effectively unlimited on the cable, or 60 shots on the independent backup', NULL, 'Also mounts three smoke canisters holding six charges covering about 50 feet, and parachute flares with a payload of nine.'),
('qpa-201-power-trooper', 3, 'Left Forearm Weapon Package (1)', 'Forearm Laser Blaster 5D6 M.D. per blast, no bursts. Vibro-Sword 2D6 M.D.', 1, 'Laser 800 feet (244 m); vibro-sword reach', 'Equal to the combined hand to hand attacks of the pilot, four to seven', 'Laser effectively unlimited', NULL, 'Two sub-weapons in one housing.'),
('qpa-201-power-trooper', 4, 'Shoulder Mini-Missile System (2)', 'Armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D. as standard; fragmentation for anti-personnel work.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, three or four', '32 total, sixteen per shoulder', NULL, NULL),
('qpa-201-power-trooper', 5, 'Folding Mini-Missile Launcher (1)', 'The book says "same basic stats" as the shoulder system: armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, four or six', '18', NULL, NULL),
('qpa-201-power-trooper', 6, 'Hand to Hand Combat', NULL, 1, 'Reach', NULL, NULL, NULL, 'Not a ranged weapon. Elite Power Armor Combat Training, Rifts RPG p.45. No bonus table is printed for this suit.'),
('qpa-201-power-trooper', 7, 'Special Sensory Systems of Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The book gives no detail, saying only "same as the QR-1 Enforcer Prime".'),
('qpa-101-pale-death-samas', 1, 'C-40R SAMAS Rail Gun (1)', 'A burst of 40 rounds does 1D4x10 M.D.; a single round does 1D4 M.D.', 1, '4000 feet (1200 m)', 'Equal to the combined hand to hand attacks of the pilot, usually six to eight', '2000 round drum, fifty bursts. A second drum can be hot-swapped.', NULL, NULL),
('qpa-101-pale-death-samas', 2, 'CM-2 Rocket Launcher (1)', 'Armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D. as standard; fragmentation 5D6 M.D. to a 20 foot (6 m) radius for anti-personnel work.', 1, 'About one mile (1.6 km)', 'One or two', 'Two', NULL, NULL),
('qpa-101-pale-death-samas', 3, 'Energy Rifles', NULL, 1, NULL, NULL, NULL, NULL, 'Infantry weapons, pistols, vibro-blades and rifles are usable as substitutes or backups. No fixed stats given.'),
('qpa-101-pale-death-samas', 4, 'Hand to Hand Combat', NULL, 1, 'Reach', NULL, NULL, NULL, 'Not a ranged weapon. Basic or Elite Power Armor Combat Training, Rifts RPG p.45.'),
('qpa-101-pale-death-samas', 5, 'Sensor Systems Note', NULL, 0, NULL, NULL, NULL, '+1 to strike and +1 to dodge, on top of the usual power armor targeting and training bonuses', 'Not a weapon. Full optics: laser targeting, telescopic, passive nightvision, thermo-imaging, infrared, ultraviolet and polarization.'),
('violator-samas-qpa-102', 1, 'QR-12A SAMAS Laser Rifle (1)', '3D6 M.D. per single shot, or 1D4x10 M.D. per triple burst counting as one melee action', 1, '2800 feet (853 m)', 'Standard', 'Effectively unlimited, being tied to the nuclear supply, with a 20-shot standard or 30-shot long E-Clip as backup', NULL, 'IT COSTS SPEED TO FIRE. Single-shot mode is -1 on initiative and -10% maximum speed while active; burst mode is -2 on initiative, -1 to strike and -20% speed for the whole melee round. The penalties are not cumulative. The book adds that this weapon and the Q2-30 were designed with Triax engineers before Free Quebec seceded, which Triax and the NGR have tried to keep quiet.'),
('violator-samas-qpa-102', 2, 'CM-2B Wing Mini-Missile Launchers', 'Fragmentation 5D6 M.D. against ground troops, but more commonly armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two, four, eight or sixteen', '16 total, eight per wing', NULL, NULL),
('violator-samas-qpa-102', 3, 'Wing Blades', '1D6 M.D. for a glancing nick, or 3D6 M.D. for a full slicing attack plus 1 M.D. for every 20 mph (32 km) of speed - which is +18 at full speed', 1, 'Reach', 'Equal to the combined hand to hand attacks of the pilot', NULL, '+1 to strike at levels 2, 5, 8, 11 and 14, +2 to disarm, and +2 to parry with them', 'The bladed "feather" wings that give the V-SAM its name. They carry an intimidation effect equivalent to a Horror Factor of 12.'),
('violator-samas-qpa-102', 4, 'Vibro-Blade Short-Sword (1)', '1D6+3 M.D.', 1, 'Reach', 'Equal to the combined hand to hand attacks of the pilot', NULL, NULL, NULL),
('violator-samas-qpa-102', 5, 'Energy Rifles and Other Weapons', NULL, 1, NULL, NULL, NULL, NULL, 'Infantry sidearms, rifles and rail guns, plus a vibro-knife sheathed on the back of the lower leg. No fixed stats given.'),
('violator-samas-qpa-102', 6, 'Hand to Hand Combat', NULL, 1, 'Reach', NULL, NULL, '+2 on initiative, +1 to strike and +1 to dodge from the V-SAM''s balance, weight and sensor improvements, on top of Power Armor Combat Training and the Wing Blade bonuses', 'Not a ranged weapon. Basic or Elite Power Armor Combat Training, Rifts RPG p.45.'),
('violator-samas-qpa-102', 7, 'Sensor System Note', NULL, 0, NULL, NULL, NULL, NULL, 'Not a weapon. The same full optical suite as the Pale Death SAMAS.'),
('fx-200c-imprimer', 1, 'FX-200C Light Laser Blaster (1)', '2D6 M.D. per blast', 1, '1500 feet (457 m)', 'Equal to the total hand to hand attacks of the cyborg', 'Effectively unlimited on the internal power supply, or 20 per E-Clip', NULL, NULL),
('fx-200c-imprimer', 2, 'Concealed Vibro-Blade (1)', '2D6 M.D. per strike', 1, 'Reach', 'Equal to the total hand to hand attacks of the cyborg', NULL, 'A P.P. of 22 gives +4 to strike and parry, W.P. bonuses excluded', NULL),
('fx-200c-imprimer', 3, 'Concealed Leg Laser Rod', '3D6 M.D. per blast', 1, '2000 feet (610 m)', 'Equal to the total hand to hand attacks of the cyborg', '20 per E-Clip', NULL, NULL),
('fx-200c-imprimer', 4, 'TX-500 Borg Rail Gun (or another heavy weapon)', 'A full burst of 30 rounds does 6D6 M.D.; a half burst of 15 does 3D6 M.D.; a single round does 1D4 M.D.', 1, '4000 feet (1219 m)', 'One burst per hand to hand action', 'Heavy drum 1170 rounds, 39 bursts; light drum or belt 390 rounds, 13 bursts; mini-clip 90 rounds, three bursts', '+1 to strike from the standard optics', 'FREE QUEBEC BANS DEPLETED-URANIUM ROUNDS, which is one of the few things it and the Coalition agree on. The gun weighs 80 lbs, the power pack 50, a light drum-belt 25 and a case of six 150. Market cost 85,000 credits, good availability. The Q2-30 heavy laser, the Q5-50 or an old C-40R rail gun can be substituted, and the Q4-44 "Drummer" shotgun is a popular backup.'),
('fx-200c-imprimer', 5, 'Concealed Weapon Compartments', NULL, 1, NULL, NULL, NULL, NULL, 'Two chest compartments, typically holding a pair of vibro-knives at 1D6 M.D., or an energy pistol with 1D4 extra E-Clips and two to eight hand grenades of any type.'),
('fx-200c-imprimer', 6, 'Hand to Hand Combat', 'Restrained punch 1D6+12 S.D.C.; full strength punch 3D6+12 S.D.C.; power punch 1D4 M.D. counting as two attacks; head butt 2D4 S.D.C.; kick 4D6+12 S.D.C.; jump kick or leap attack 2D4 M.D. counting as two attacks; judo throw or flip 3D6 S.D.C.; full speed ram or body block 1D4 M.D. counting as two attacks.', 1, 'Reach', 'Equal to the cyborg''s hand to hand skill and experience, plus one more from heightened reflexes', NULL, '+2 on initiative, +1 to dodge, +2 to pull punch, +1 to roll with impact, +2 to save vs Horror Factor, plus attribute and W.P. bonuses', 'THE CYBORG''S STRENGTH IS S.D.C. BASED except on special attacks such as a power punch, which is why most of this table is S.D.C. rather than M.D.'),
('fx-200c-imprimer', 7, 'Optional hand-held weapons', NULL, 1, NULL, NULL, NULL, NULL, 'Other rail guns, energy rifles, grenades and magic weapons. Other bionic weapons - concealed weapon rods, tools and compartments - may also be integrated.'),
('fx-320c-dervish', 1, 'FX-220 Concealed Vibro-Blades (4)', '2D6 M.D. per strike', 1, 'Reach', 'Equal to the total hand to hand attacks of the cyborg', NULL, 'A P.P. of 24 gives +5 to strike and parry, W.P. bonuses excluded', 'One per arm, and it has four.'),
('fx-320c-dervish', 2, 'Concealed Leg Laser Rod (1)', '3D6 M.D. per blast', 1, '2200 feet (670.5 m)', 'Equal to the total hand to hand attacks of the cyborg', '20 per E-Clip', NULL, NULL),
('fx-320c-dervish', 3, 'Concealed Leg Ion Rod (1)', '4D6 M.D. per blast', 1, '1600 feet (488 m)', 'Equal to the total hand to hand attacks of the cyborg', '20 per E-Clip', NULL, NULL),
('fx-320c-dervish', 4, 'Chemical Spray (chest)', 'Varies with the chemical. Blinding agents, tear gas, burning vapours, sleep gas and CO2 foam are the common loads.', 0, '20 feet (6 m)', 'Equal to the total hand to hand attacks of the cyborg', '20 doses, across up to five chemical types', NULL, 'The book refers to Rifts RPG p.240 for the chemicals themselves.'),
('fx-320c-dervish', 5, 'Concealed Weapon Compartments', NULL, 0, NULL, NULL, NULL, NULL, 'Two leg compartments for tools, weapons or grenades.'),
('fx-320c-dervish', 6, 'Hand to Hand Combat', 'Restrained punch 1D6+12 S.D.C.; full strength punch 4D6+12 S.D.C.; power punch 1D6 M.D. counting as two attacks; head butt 2D4 S.D.C.; kick 4D6+12 S.D.C.; jump kick or leap attack 2D4 M.D. counting as two attacks; judo throw or flip 3D6 S.D.C.; full speed ram or body block 1D4 M.D. counting as two attacks.', 1, 'Reach', 'Equal to the cyborg''s hand to hand skill and experience, plus one from heightened reflexes and ONE MORE FROM THE EXTRA ARMS', NULL, '+3 on initiative, +4 to pull punch, +2 to parry, +4 to disarm, +4 to save vs Horror Factor, plus attribute, Boxing, Wrestling and W.P. bonuses', 'The four-armed cyborg hits harder and disarms better than any of its siblings, which is the design.'),
('fx-320c-dervish', 7, 'Optional hand-held weapons', NULL, 1, NULL, NULL, NULL, NULL, 'As the Imprimer: other rail guns, energy rifles, grenades and magic weapons, plus integrated bionic weapon rods, tools and compartments.'),
('fx-340c-slasher', 1, 'Concealed Vibro-Blades (2)', '2D6 M.D. per strike', 1, 'Reach', 'Equal to the total hand to hand attacks of the cyborg', NULL, 'A P.P. of 24 gives +5 to strike and parry, W.P. bonuses excluded', NULL),
('fx-340c-slasher', 2, 'FX-340C Mini-Missile Tube Launchers (4)', 'Armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D. as standard; fragmentation is seldom used.', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two or four', 'Four total, one per tube', NULL, NULL),
('fx-340c-slasher', 3, 'Concealed Leg Laser Rod', '3D6 M.D. per blast', 1, '3000 feet (914 m)', 'Equal to the total hand to hand attacks of the cyborg', '20 per E-Clip', NULL, 'The longest-ranged of the three FX leg rods.'),
('fx-340c-slasher', 4, 'TX-500 Borg Rail Gun (1)', 'A full burst of 30 rounds does 6D6 M.D.; a half burst of 15 does 3D6 M.D.; a single round does 1D4 M.D.', 1, '4000 feet (1219 m)', 'One burst per hand to hand action', 'Heavy drum 1170 rounds, 39 bursts; light drum 390 rounds, 13 bursts; mini-clip 90 rounds, three bursts', '+1 to strike from the standard optics', 'The same weapon and the same 85,000 credit market cost as the Imprimer''s.'),
('fx-340c-slasher', 5, 'Concealed Weapon Compartments', NULL, 1, NULL, NULL, NULL, NULL, 'Chest compartments holding a pair of vibro-knives at 1D6 M.D. plus two to eight grenades.'),
('fx-340c-slasher', 6, 'Hand to Hand Combat', 'Restrained punch 1D6+12 S.D.C.; full strength punch 3D6+12 S.D.C.; power punch 1D4 M.D. counting as two attacks; head butt 2D4 S.D.C.; kick 4D6+12 S.D.C.; jump kick or leap attack 2D4 M.D. counting as two attacks; judo throw or flip 3D6 S.D.C.; full speed ram or body block 1D4 M.D. counting as two attacks.', 1, 'Reach', 'Equal to the cyborg''s hand to hand skill and experience, plus one more from heightened reflexes', NULL, '+2 on initiative, +3 to pull punch, +1 to roll with impact, +2 to save vs Horror Factor; a P.P. of 24 adds +5 to strike, parry and dodge', NULL),
('fx-340c-slasher', 7, 'Optional hand-held weapons', NULL, 1, NULL, NULL, NULL, NULL, 'As the Imprimer.'),
('fx-370c-leviathan', 1, 'FX-99N Plasma Torch and Ejector (1)', 'Cutting settings 1D6, 3D6 or 6D6 M.D.; blast settings 1D6, 3D6 or 6D6 M.D. as desired.', 1, '10 feet (3 m) as a cutter, or 400 feet (122 m) as a ranged weapon', 'One cut or blast per melee action', '50 full-strength blasts or 100 half-strength; six 1D6 cuts count as one full blast', NULL, 'The gun weighs 8 lbs (3.6 kg) plus a 50 lb (22.7 kg) power pack. ITS MARKET COST IS PRINTED "140,00 credits", which is missing a digit and is almost certainly 140,000. Recorded as printed rather than silently corrected.'),
('fx-370c-leviathan', 2, 'Forearm Laser Blaster', '2D6 M.D.', 1, '2000 feet (610 m)', 'Equal to the total hand to hand attacks of the cyborg', '20 per E-Clip', NULL, NULL),
('fx-370c-leviathan', 3, 'Laser Finger (1)', 'Three settings: 6D6 S.D.C., 1 M.D., or 1D4 M.D. per blast', 1, '50 feet (15.2 m)', 'Equal to the total hand to hand attacks of the cyborg', 'Effectively unlimited, drawn from the internal power supply', NULL, NULL),
('fx-370c-leviathan', 4, 'Shoulder Mounted Mini-Missile or Torpedo Launcher (1)', 'Armor piercing 1D4x10 M.D. or plasma 1D6x10 M.D. as standard, or a comparable mini-torpedo', 1, 'About one mile (1.6 km)', 'One at a time, or volleys of two or three', 'Six total', NULL, 'The torpedo option is what makes this the Navy''s cyborg.'),
('fx-370c-leviathan', 5, 'Rail Gun or other heavy weapon', NULL, 1, NULL, NULL, NULL, NULL, 'Harpoon guns, laser rifles, the Q2-30, the Q5-50 or a C-40R rail gun are all usable. No fixed stats given.'),
('fx-370c-leviathan', 6, 'Hand to Hand Combat', 'Restrained punch 1D6+12 S.D.C.; full strength punch 4D6+12 S.D.C.; power punch 1D6 M.D.; head butt 2D6 S.D.C.; kick 4D6+12 S.D.C.; jump kick or leap attack 2D6 M.D.; judo throw or flip 3D6 S.D.C.; full speed ram 1D6 M.D.', 1, 'Reach', 'Equal to the cyborg''s hand to hand skill and experience', NULL, NULL, 'THIS BLOCK STRADDLES A PAGE. Its opening sentence is at the foot of printed 123 and the whole table is on printed 124, one page into the next slice - so it was assembled from two readings rather than truncated. The Leviathan hits harder than the Imprimer and the Slasher across the board.');

-- Read the result back rather than trusting the exit code.
SELECT count(*) AS got_vessels FROM vehicles
 WHERE source_book LIKE 'Rifts World Book 22: Free Quebec%';
SELECT count(*) AS got_borg_locations FROM vehicle_locations
 WHERE vehicle_slug LIKE 'fx-%';
SELECT count(*) AS got_borg_weapons FROM vehicle_weapons
 WHERE vehicle_slug LIKE 'fx-%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-free-quebec-vessels-p105-123.sql');
