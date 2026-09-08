-- Underseas vessels from printed pages 167-190: the horune magic ships and
-- drones, and the Kittani and Splugorth war machines of Atlantis.

--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-underseas-vessels-p167-190.sql
--
-- See zzzzzz-underseas-vessels-p081-105.sql for the standing notes. Every page
-- here is past printed 130, so cache page = printed folio MINUS ONE.
--
-- NOT ONE OF THESE THIRTEEN HAS A PRICE, and that is the section rather than a
-- gap in the reading. Horune ships are magic and "never sold"; the Kittani and
-- Splugorth machines are Atlantean and not traded. Four entries follow "not
-- available" with an ESTIMATE - at least 40 million for the War Urchin, at
-- least 100 million for the Destroyer, 30-40 million a unit for the War Fish
-- and the War Crab - and an estimate is not a price, so none is stored as one.
-- Every figure is in cost_note where it can be read and not summed.
--
-- PRINTED 187 IS A BLANK ILLUSTRATION PAGE inside the Sea Skimmer entry and
-- nothing is lost with it: weapon system 3 (Deck Laser Turrets) finishes
-- cleanly on 186 and system 4 (Heavy Torpedo Launch Tubes) opens cleanly on
-- 188. It was not previously flagged; printed 194 and 208 are the other two.
--
-- THE WAR CRAB CALLS THE SAME GUN TWO NAMES. Its M.D.C. list has a "Left Weapon
-- Turret" at 200; its weapon systems list has a "Quad-Plasma Cannon Turret (2)"
-- and no left turret. They are plainly the same mounting, and both names are
-- stored where the book puts them with a note on each pointing at the other -
-- picking a winner would erase the book's own inconsistency.
--
-- THE WAR CRAB ALSO PRINTS TWO MAIN BODIES: a Crab-Man Torso at 300 labelled a
-- main body, and a second, higher figure of 600. The 600 is the machine and is
-- what mdc_main_body holds; the torso is a decoy shell and keeps its own row.
--
-- THE SEA FIN NUMBERS A WEAPON SYSTEM "4" TWICE, running Deck Laser Turrets
-- straight into the Torpedo and Missile Launchers without reaching 5.
-- Transcribed as printed and flagged on the row.
--
-- FOUR M.D.C. LINES ARE MISSING AN "each" their siblings carry - the Dolphin
-- Drone's Hip Lasers and the Ark's Laser Cannon Turrets among them. Whether
-- that is the book's own inconsistency or an OCR drop cannot be told from the
-- cache, so each is transcribed as printed with the anomaly in its note rather
-- than silently normalised.
--
-- THE SEA-HORSE SLED AND SPEEDER ARE ONE ROW, because the book gives them one
-- stat block with paired figures throughout - one Model Type, one M.D.C., one
-- weapon list, two speeds and two sets of dimensions. Splitting them would
-- invent a second entry the page does not have.
--
-- THE HORUNE ENTRIES DO NOT NUMBER THEIR WEAPON SYSTEMS the way the rest of the
-- book does; the Sea-Horse in particular just names three attacks in prose.
-- They are stored in the order the page gives them.

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground,
   speed_air, speed_water, dimensions, weight_tons, mdc_main_body, cost,
   cost_note, description, source_book)
VALUES
('horune-sea-horse-sled-and-speeder', 'Horune Sea-Horse Sled & Speeder', 'rifts', 'Magic one-man aqua-sleds or scooters.', 'One pilot.', NULL, 'Not possible.', 'Not possible.', 'Surface - the Sled 35 mph (56 kmph; 30 knots), the Speeder 90 mph (144 kmph; 77.4 knots). Submerged - the Sled 35 mph while towing up to 6 tons, the Speeder up to 60 mph, diving to 3000 feet.', 'Sled 5 feet high, 2.6 feet wide, 7 feet long; Speeder 3 feet high, 2.6 feet wide, 10 feet long.', '200 lbs', 223, NULL, 'NO PRICE. Never sold, and it only works for horune and horune pirates.', 'A pair of magic one-rider craft grown by the horune Ship Dreamers - a stealthy towing sled and a fast scooter, both shaped as sea-horses. They regenerate damage, and vanish in light if destroyed.', 'Rifts World Book 7: Underseas p.167'),
('horune-dolphin-combat-drone', 'Horune Dolphin Combat Drone', 'rifts', 'Horune magic automaton/combat drone.', 'One dolphin host body.', NULL, 'Running 44 mph.', 'By magic only - Fly as the Eagle at 11th level spell strength.', '60 knots (69 mph) on its thrusters.', 'Standing 10 feet tall, 4 feet wide, 4 feet long.', '1000 lbs', 270, NULL, 'NO PRICE. Never sold or created for outsiders.', 'A dolphin magically fused into spiked armour by the Ship Dreamers and set to work as a shock trooper. Most lose all personality; the rare one that keeps its free will is a tragedy. It regenerates 20 M.D.C. an hour, limbs and weapons included.', 'Rifts World Book 7: Underseas p.167-168'),
('horune-land-shark-drone', 'Horune Land Shark Drone', 'rifts', 'Horune magic automaton/combat drone.', 'One shark host body.', NULL, 'Running 44 mph.', 'By magic only - Fly as the Eagle at 11th level spell strength. It can leap 20 feet.', '20 mph with its legs folded.', '18 feet high, 8 feet wide, 25 feet long.', '2 tons', 470, NULL, 'NO PRICE. Never sold or created for outsiders.', 'A tiger or great white shark welded by magic into a mechanised killing frame. Unlike the dolphin drone this one never keeps its free will. It is sent to hunt Whale Singers and cetaceans on the pirates'' orders.', 'Rifts World Book 7: Underseas p.169-170'),
('horune-dream-ship', 'Horune Dream Ship', 'rifts', 'Horune assault ship.', 'One captain, ten officers, one or two warlocks or a dragon or ocean wizard, and 1D4x100 pirates.', '1200 more crew and 5000 slaves, or 70,000 tons of cargo.', 'Not possible.', 'Not possible.', 'Surface 90 mph (144 kmph; 77.4 knots); submerged 35 mph (56 kmph; 30 knots) for up to twelve hours. Depth unlimited.', '280 feet high, 150 feet wide, 400 feet long.', '90,000 tons', 20000, NULL, 'NO PRICE. A magic vessel, never sold.', 'A whale-shaped magic warship dreamed into being by the horune Ship Dreamers - fast, heavily armed, and able to submerge. It regenerates 1D4x100 M.D.C. an hour and vanishes in light when finally destroyed.', 'Rifts World Book 7: Underseas p.170-171'),
('horune-strike-ship', 'Horune Strike Ships', 'rifts', 'Horune assault ship.', 'One captain, six officers, one or two warlocks and 100 pirates.', '100 more crew and 1000 slaves, or 30,000 tons of cargo.', 'Not possible.', 'Not possible.', 'Surface 120 mph (192 kmph; 103.2 knots); submerged 35 mph.', '95 feet high, 50 feet wide, 120 feet long.', '30,000 tons', 6500, NULL, 'NO PRICE, like every horune magic ship.', 'A third the size of the Dream Ship, in the book''s own words, and faster on the surface than anything else the horune field. A plasma cannon stands where the Dream Ship carries its Storm Cannon.', 'Rifts World Book 7: Underseas p.172'),
('war-urchin-power-armor', 'War Urchin Power Armor', 'rifts', 'Light Strategic Environmental Exo-Skeleton.', 'One - kittani, Sunaj, or a human-sized minion.', NULL, 'Running 40 mph; leaping 50 feet, or 300 feet jet-assisted.', 'Flying 100 mph, hovering to 6000 feet.', 'Swimming 10 mph, or 60 mph on the jet pack. Depth 2.4 miles.', '8 feet high, 4.4 feet wide, 3 to 4 feet long.', '200 lbs', 230, NULL, 'NO PRICE. "Not available on the open market (would cost at least 40 million credits)." Exclusive to Splugorth minions; an estimate is not a price.', 'A kittani and techno-wizard hybrid built for mobility above and below the surface, with detachable jet packs for air or sea and urchin-spine grenade tubes. Its chest and forearms are spell systems rather than guns.', 'Rifts World Book 7: Underseas p.175-176'),
('kittani-destroyer-power-armor', 'Kittani Destroyer Power Armor', 'rifts', 'Light Strategic Environmental Exoskeleton.', 'One, and kydian only.', NULL, 'Running 30 mph; leaping 30 feet, or 200 feet jet-assisted.', 'Flying 60 mph, hovering to 1000 feet.', 'Swimming 8 mph, or 60 mph on the jets. Depth 9 miles, or unlimited by magic.', '13 feet high, 8 feet wide, 6 feet long.', '2 tons', 440, NULL, 'NO PRICE. "Not available on the open market (would cost at least 100 million credits)."', 'The War Urchin built bigger and tougher for the Splugorth''s kydian Overlords and Powerlords. Its head is a sensor cluster shielding the pilot''s real head deeper inside, and it dives far further than the Urchin does.', 'Rifts World Book 7: Underseas p.176-179'),
('kittani-war-fish-power-armor', 'Kittani War Fish Power Armor', 'rifts', 'Heavy Infantry Environmental Exo-Skeleton.', 'One.', NULL, 'Running 40 mph, out of the fish section.', 'Not possible for the vehicle, though a jet pack can be fitted to the humanoid section. Leaping is not possible.', 'The humanoid section alone swims 10 mph; inside the fish section, 100 mph submerged and 140 mph on the surface.', '9 feet high, 10 feet wide, 16 feet long.', '4 tons', 375, NULL, 'NO PRICE. "Has never been sold." The book says the Coalition or Triax would pay 50 to 100 million, and the Kittani could get 30 to 40 million a unit if they sold them.', 'Two machines in one - a humanoid torso that locks into a jet-powered fish hull carrying all the heavy weapons. The pilot can leave the fish behind, which then goes into lethal automatic defence, and fight on foot.', 'Rifts World Book 7: Underseas p.179-180'),
('kittani-war-crab-robot-vehicle', 'Kittani War Crab Robot Vehicle', 'rifts', 'Strategic Robot Vehicle.', 'Two - a pilot and a gunner.', NULL, 'Running 20 mph. Leaping is not possible.', 'Not possible.', 'Walking or jetting 20 mph. Depth 3 miles.', '20 feet tall in total - an 8 foot saucer body standing 3 feet off the ground under a 9 foot crab-man torso; 16 feet wide across the shell.', '24 tons', 600, NULL, 'NO PRICE. "Has never been sold." The Coalition or Triax would pay 50 to 100 million; the Kittani could get 30 to 40 million.', 'A low crab-shaped robot whose humanoid "crab-man" torso is a decoy - the real pilot and gunner sit inside the shell beneath it. It is built for reconnaissance and sabotage and can cling magnetically to a hull.', 'Rifts World Book 7: Underseas p.181-182'),
('kittani-war-shark-submarine-mk4', 'Kittani War Shark Submarine Mk 4', 'rifts', 'Attack Submarine - full size.', '10 to 12 officers and 60 crew.', '60 marines or mechanized troops, and up to 20 more in an emergency.', 'Not possible.', 'Not possible.', 'Surface 29 mph (47 kmph; 25 knots); submerged 52 mph (84 kmph; 45 knots). Depth 3 miles.', '30 feet high, 30 feet wide, 360 feet long.', '4,100 tons', 3000, NULL, 'NO PRICE - the entry prints none at all.', 'A robot submarine shaped like a shark, able to bend into a U to turn inside its own length. Its maw is both a weapon - lined with a hundred lasers - and the hangar door its troops come out of.', 'Rifts World Book 7: Underseas p.183-184'),
('shark-mini-submarine-mk5', 'Shark Mini-Submarine Mk 5', 'rifts', 'Exploration Mini-Submarine.', 'One pilot.', 'Five.', 'Not possible.', 'Not possible.', 'Surface 29 mph (47 kmph; 25 knots); submerged 60 mph (96 kmph; 51.6 knots). Depth 2 miles.', '13 feet high, 13 feet wide, 60 feet long.', '56 tons', 850, NULL, 'NO PRICE - the entry prints none at all.', 'A six-person miniature of the War Shark, sent out to explore, with a vibro-bladed bite as its main close-in weapon.', 'Rifts World Book 7: Underseas p.184-185'),
('splugorth-sea-skimmer-ark', 'Splugorth Sea Skimmer "The Ark"', 'rifts', 'Multi-purpose sea vessel.', 'In peacetime, 10 to 12 officers (High Lords and kittani), 2 to 4 warlocks or a dragon, 2D4x10 Overlords, 1D4x10 Powerlords, 1D4x10+30 gurgoyles and Tattooed Men, and 1D4x10 gargoyles. The book also prints full slave-ship and warship crews.', '200 more personnel and 100,000 tons of cargo, or about 8,000 slaves.', 'Hovers and flies up to 50 feet off the ground.', '50 mph, doubled over ley lines and magic triangles, to a height of 50 feet.', '50 mph normally, up to 100 mph riding a storm it summons itself - 200 mph on a ley line. It cannot submerge.', '80 to 250 feet high and 100 to 360 feet wide depending where you measure, and 1,200 to 2,000 feet long.', '59,000 tons', 30000, NULL, 'NO PRICE. A Splugorth vessel; it is not sold.', 'A vast Splugorth flagship of delicate-looking bio-wizardry and technology, carrying thirty living Eyes of Eylor for eyes. It flies, rides storms, and serves as troop transport, warship or luxury cruiser as the assignment demands.', 'Rifts World Book 7: Underseas p.185-188'),
('splugorth-magic-sea-fin', 'Splugorth Magic Sea Fin', 'rifts', 'Multi-purpose sea vessel.', 'In peacetime, 10 to 20 officers, one or two warlocks or a dragon, 1D4x10 Overlords, 1D4x10+20 gurgoyles, 1D4x10 gargoyles and 1D4x10+40 slaves.', '1,000 more personnel and 100,000 tons of cargo, or about 4,000 slaves.', 'Not possible.', 'Not possible.', 'Surface 60 mph (96.5 kmph; 51.2 knots); submerged 30 mph (48 kmph; 25.8 knots). Depth 3,000 feet.', '100 feet to the top of the tallest tower, 130 feet wide, 700 to 1,000 feet long.', '57,000 tons', 15000, NULL, 'NO PRICE - the entry prints none.', 'A smaller, sleeker Splugorth ship named for its twin rear fins, used interchangeably as passenger liner, freighter and warship. It carries the Ark''s Eye-of-Eylor sensor and stealth suite at reduced scale.', 'Rifts World Book 7: Underseas p.188-190');

INSERT OR IGNORE INTO vehicle_locations
  (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
('horune-sea-horse-sled-and-speeder', 'Main Body', 223, 'The only location the book gives. There are no sub-locations; the rider is a called shot at -3 to strike.', 1),
('horune-dolphin-combat-drone', 'Thrusters (2, back)', 150, 'Each.', 1),
('horune-dolphin-combat-drone', 'Arms (2)', 100, 'Each.', 2),
('horune-dolphin-combat-drone', 'Clawed Hands (2)', 25, 'Each.', 3),
('horune-dolphin-combat-drone', 'Legs (2)', 150, 'Each.', 4),
('horune-dolphin-combat-drone', 'Tail (1)', 150, NULL, 5),
('horune-dolphin-combat-drone', 'Plasma Ejectors (3, top)', 20, 'Each.', 6),
('horune-dolphin-combat-drone', 'Hip Lasers (2)', 15, 'Printed as a flat 15 with no "each", where every sibling line carries one. Transcribed as printed.', 7),
('horune-dolphin-combat-drone', 'Sonic Rifle (1)', 100, NULL, 8),
('horune-dolphin-combat-drone', 'Main Body', 270, NULL, 9),
('horune-land-shark-drone', 'Arms (4)', 120, 'Each.', 1),
('horune-land-shark-drone', 'Clawed Hands (4)', 35, 'Each.', 2),
('horune-land-shark-drone', 'Legs (4)', 200, 'Each.', 3),
('horune-land-shark-drone', 'Tail (1)', 200, NULL, 4),
('horune-land-shark-drone', 'Mouth Plasma Ejector', 120, NULL, 5),
('horune-land-shark-drone', 'Eye Lasers (2)', 15, 'Each.', 6),
('horune-land-shark-drone', 'Wrist Blaster (1, right)', 40, NULL, 7),
('horune-land-shark-drone', 'Chest Lights (2)', 40, 'Each.', 8),
('horune-land-shark-drone', 'Main Body', 470, NULL, 9),
('horune-dream-ship', 'Storm Cannon (1, top)', 1400, NULL, 1),
('horune-dream-ship', 'Plasma Cannons (2)', 350, 'Each.', 2),
('horune-dream-ship', 'Laser Turrets (2, rear)', 150, 'Each.', 3),
('horune-dream-ship', 'Tower (1, rear)', 2000, NULL, 4),
('horune-dream-ship', 'Tail Fins (2)', 1500, 'Each.', 5),
('horune-dream-ship', 'Hatches (10, small)', 200, 'Each.', 6),
('horune-dream-ship', 'Cargo Bay Hatches (2, top)', 1000, 'Each.', 7),
('horune-dream-ship', 'Forward Cargo Hatch (1)', 4000, NULL, 8),
('horune-dream-ship', 'Main Body', 20000, NULL, 9),
('horune-strike-ship', 'Top Plasma Cannon', 800, NULL, 1),
('horune-strike-ship', 'Plasma Cannons (2)', 125, 'Each.', 2),
('horune-strike-ship', 'Laser Turrets (2)', 50, 'Each.', 3),
('horune-strike-ship', 'Tower', 650, NULL, 4),
('horune-strike-ship', 'Tail Fins (2)', 650, 'Each.', 5),
('horune-strike-ship', 'Hatches (10)', 65, 'Each.', 6),
('horune-strike-ship', 'Cargo Bay Hatches (2)', 350, 'Each.', 7),
('horune-strike-ship', 'Forward Cargo Hatch', 1200, NULL, 8),
('horune-strike-ship', 'Main Body', 6500, NULL, 9),
('war-urchin-power-armor', 'Removable Jet Pack', 80, NULL, 1),
('war-urchin-power-armor', 'Maneuvering Jets (8)', 15, 'Each.', 2),
('war-urchin-power-armor', 'Arm Fins (2)', 20, 'Each.', 3),
('war-urchin-power-armor', 'Leg Fins (2)', 15, 'Each.', 4),
('war-urchin-power-armor', 'Grenade Launchers (10)', 10, 'Each.', 5),
('war-urchin-power-armor', 'Forearm Gauntlets (2)', 100, 'Each.', 6),
('war-urchin-power-armor', 'Head', 90, NULL, 7),
('war-urchin-power-armor', 'Main Body', 230, NULL, 8),
('kittani-destroyer-power-armor', 'Backpack Water Jets', 130, NULL, 1),
('kittani-destroyer-power-armor', 'Maneuvering Jets (8)', 15, 'Each.', 2),
('kittani-destroyer-power-armor', 'Main Shoulder Gun', 200, NULL, 3),
('kittani-destroyer-power-armor', 'Grenade Launchers (14)', 30, 'Each.', 4),
('kittani-destroyer-power-armor', 'Forearm Gauntlets (2)', 180, 'Each.', 5),
('kittani-destroyer-power-armor', 'Head (sensor cluster)', 120, NULL, 6),
('kittani-destroyer-power-armor', 'Main Body', 440, NULL, 7),
('kittani-war-fish-power-armor', 'Shoulders (2)', 150, 'Each.', 1),
('kittani-war-fish-power-armor', 'Arms (2)', 110, 'Each.', 2),
('kittani-war-fish-power-armor', 'Arm Fins (2)', 50, 'Each.', 3),
('kittani-war-fish-power-armor', 'Forward Lasers (2)', 30, 'Each.', 4),
('kittani-war-fish-power-armor', 'Main Gun', 110, NULL, 5),
('kittani-war-fish-power-armor', 'Mini-Torpedo Launchers (2)', 200, 'Each.', 6),
('kittani-war-fish-power-armor', 'Lower Fins (2)', 110, 'Each.', 7),
('kittani-war-fish-power-armor', 'Jet Clusters (2)', 90, 'Each.', 8),
('kittani-war-fish-power-armor', 'Lower Jets (2)', 110, 'Each.', 9),
('kittani-war-fish-power-armor', 'Upper Jets (2)', 300, 'Each.', 10),
('kittani-war-fish-power-armor', 'Humanoid Upper Body', 200, NULL, 11),
('kittani-war-fish-power-armor', 'Head', 110, NULL, 12),
('kittani-war-fish-power-armor', 'Tail Fin & Section', 200, NULL, 13),
('kittani-war-fish-power-armor', 'Main Body', 375, NULL, 14),
('kittani-war-crab-robot-vehicle', 'Right Weapon Turret', 250, NULL, 1),
('kittani-war-crab-robot-vehicle', 'Left Weapon Turret', 200, 'Fifty per barrel. The M.D.C. list calls this the Left Weapon Turret while the weapon systems list calls the same gun the Quad-Plasma Cannon Turret.', 2),
('kittani-war-crab-robot-vehicle', 'Forward Rail Gun Mini-Turrets (2)', 60, 'Each.', 3),
('kittani-war-crab-robot-vehicle', 'Rear Laser Mini-Turrets (2)', 50, 'Each.', 4),
('kittani-war-crab-robot-vehicle', 'Sensor Cluster (2)', 25, 'Each.', 5),
('kittani-war-crab-robot-vehicle', 'Crab-Man Torso', 300, 'The book labels this a main body too; the higher 600 figure is the machine itself.', 6),
('kittani-war-crab-robot-vehicle', 'Crab-Man Head', 100, NULL, 7),
('kittani-war-crab-robot-vehicle', 'Giant Claws (2)', 200, 'Each.', 8),
('kittani-war-crab-robot-vehicle', 'Hydraulic Hands (2)', 20, 'Each.', 9),
('kittani-war-crab-robot-vehicle', 'Directional Thrusters (16)', 5, 'Each.', 10),
('kittani-war-crab-robot-vehicle', 'Concealed Thrusters (4)', 50, 'Each.', 11),
('kittani-war-crab-robot-vehicle', 'Concealed Hatches (2)', 90, 'Each.', 12),
('kittani-war-crab-robot-vehicle', 'Pilot & Gunner Compartment', 100, NULL, 13),
('kittani-war-crab-robot-vehicle', 'Main Body', 600, NULL, 14),
('kittani-war-shark-submarine-mk4', 'Laser Cannon Turret (underbelly)', 200, NULL, 1),
('kittani-war-shark-submarine-mk4', 'Torpedo Tubes (7, nose)', 100, 'Each.', 2),
('kittani-war-shark-submarine-mk4', 'Mini-Torpedo Tubes (10)', 120, 'Each.', 3),
('kittani-war-shark-submarine-mk4', 'Mini-Missile Launchers (4, top)', 50, 'Each.', 4),
('kittani-war-shark-submarine-mk4', 'Eyes, Sensors & Optics (2)', 100, 'Each.', 5),
('kittani-war-shark-submarine-mk4', 'Side Fins (2)', 500, 'Each.', 6),
('kittani-war-shark-submarine-mk4', 'Top Fin', 250, NULL, 7),
('kittani-war-shark-submarine-mk4', 'Tail Section', 950, NULL, 8),
('kittani-war-shark-submarine-mk4', 'Main Body', 3000, NULL, 9),
('shark-mini-submarine-mk5', 'Laser Pulse Cannon Turret', 70, NULL, 1),
('shark-mini-submarine-mk5', 'Mini-Torpedo Tubes (7, nose)', 40, 'Each.', 2),
('shark-mini-submarine-mk5', 'Mini-Torpedo Tubes (10)', 30, 'Each.', 3),
('shark-mini-submarine-mk5', 'Light Lasers (4, top)', 15, 'Each.', 4),
('shark-mini-submarine-mk5', 'Eyes, Sensors & Optics (2)', 40, 'Each.', 5),
('shark-mini-submarine-mk5', 'Side Fins (2)', 150, 'Each.', 6),
('shark-mini-submarine-mk5', 'Top Fin', 90, NULL, 7),
('shark-mini-submarine-mk5', 'Tail Section', 350, NULL, 8),
('shark-mini-submarine-mk5', 'Main Body', 850, NULL, 9),
('splugorth-sea-skimmer-ark', 'Laser Cannon Turrets (2)', 400, 'Printed without an "each" after the parenthetical, where sibling lines carry one.', 1),
('splugorth-sea-skimmer-ark', 'Deck Laser Turrets (2)', 150, 'Each.', 2),
('splugorth-sea-skimmer-ark', 'Ball Plasma Turrets (2)', 500, 'Each.', 3),
('splugorth-sea-skimmer-ark', 'Eyes of Eylor (30)', 220, 'Each.', 4),
('splugorth-sea-skimmer-ark', 'Support Legs (2)', 6000, 'Each.', 5),
('splugorth-sea-skimmer-ark', 'Leg Fins (2)', 1500, 'Each.', 6),
('splugorth-sea-skimmer-ark', 'Tower', 2500, NULL, 7),
('splugorth-sea-skimmer-ark', 'Canopy Horns (3)', 2000, 'Each.', 8),
('splugorth-sea-skimmer-ark', 'Hatches (20)', 200, 'Each.', 9),
('splugorth-sea-skimmer-ark', 'Cargo Bay Hatches (2)', 1000, 'Each.', 10),
('splugorth-sea-skimmer-ark', 'Canopy', 2500, NULL, 11),
('splugorth-sea-skimmer-ark', 'Force Field', 1000, 'Each, thirteen times a day.', 12),
('splugorth-sea-skimmer-ark', 'Main Body', 30000, NULL, 13),
('splugorth-magic-sea-fin', 'Forward Laser Turret', 400, NULL, 1),
('splugorth-magic-sea-fin', 'Rear Laser Turrets (2)', 300, 'Each.', 2),
('splugorth-magic-sea-fin', 'Deck Laser Turrets (6)', 150, 'Each.', 3),
('splugorth-magic-sea-fin', 'Forward Plasma Turret', 600, NULL, 4),
('splugorth-magic-sea-fin', 'Fins (2)', 1500, 'Each.', 5),
('splugorth-magic-sea-fin', 'Tower (2)', 2500, NULL, 6),
('splugorth-magic-sea-fin', 'Hatches (10)', 200, 'Each.', 7),
('splugorth-magic-sea-fin', 'Cargo Bay Hatches (2)', 1000, 'Each.', 8),
('splugorth-magic-sea-fin', 'Force Field', 500, 'Each, seven times a day.', 9),
('splugorth-magic-sea-fin', 'Main Body', 15000, NULL, 10);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range,
   rate_of_fire, payload, bonus, note)
VALUES
('horune-sea-horse-sled-and-speeder', 1, 'Fireball Bite', '6D6 M.D.', 1, '300 feet (91 m)', 'Twice per melee round.', NULL, NULL, 'Spat from the horse head. The book does not number its weapon systems; these are its named attacks.'),
('horune-sea-horse-sled-and-speeder', 2, 'Ram and Gouge', '3D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, 'With the head horns.'),
('horune-sea-horse-sled-and-speeder', 3, 'Anti-Theft Bite', '1D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, 'Self-defence only - the craft bites a thief by itself, and the rider cannot direct it.'),
('horune-dolphin-combat-drone', 1, 'Horune Sonic Rifle', '6D6 M.D.', 1, '2000 feet (610 m)', NULL, NULL, NULL, NULL),
('horune-dolphin-combat-drone', 2, 'Plasma Ejectors', '1D6x10 M.D. single, 2D6x10 double, 3D6x10 triple.', 1, '2000 feet (610 m)', NULL, NULL, NULL, NULL),
('horune-dolphin-combat-drone', 3, 'Hip Lasers', '2D6 M.D. single, 4D6 M.D. double.', 1, '2000 feet (610 m)', NULL, NULL, NULL, NULL),
('horune-dolphin-combat-drone', 4, 'Bonuses & Hand to Hand', 'Elbow spikes 3D6 M.D., slashing claw 3D6 M.D., punch or kick 3D6 M.D., power punch 6D6 M.D., shoulder or head butt 2D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('horune-land-shark-drone', 1, 'Plasma Ejector', '1D6x10 M.D. per blast.', 1, '2000 feet (610 m)', 'Six blasts per melee round.', NULL, NULL, NULL),
('horune-land-shark-drone', 2, 'Eye Lasers', '3D6 M.D. single, 6D6 M.D. double.', 1, '2000 feet (610 m) underwater, 4000 feet (1220 m) in air.', NULL, NULL, NULL, NULL),
('horune-land-shark-drone', 3, 'Forearm Blaster', '2D6 M.D. single, 4D6 double, 6D6 triple.', 1, '1000 feet (305 m) underwater, 2000 feet (610 m) in air.', NULL, NULL, NULL, NULL),
('horune-land-shark-drone', 4, 'Chest Lights', NULL, 0, '100 feet (30.5 m)', NULL, 'Three castings of each per 24 hours.', NULL, 'Not a damaging weapon. Blind, Globe of Daylight and Wisps of Confusion at 10th level spell strength.'),
('horune-land-shark-drone', 5, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('horune-land-shark-drone', 6, 'Bonuses & Hand to Hand', 'Elbow blades 6D6 M.D., claw 5D6 M.D., punch or kick 5D6 M.D., power punch 1D6x10 M.D., tail strike 5D6 M.D., bite 1D4x10 M.D., head butt 3D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('horune-dream-ship', 1, 'Storm Cannon', 'Call Lightning 1D6x10 M.D., plus twin plasma turrets at 1D6x10 M.D. each.', 1, 'Lightning one mile (1.6 km); the plasma turrets 3000 feet (914 m).', NULL, NULL, NULL, 'Also casts Summon Storm, Whirl Pool and Calm Storms at 11th level spell strength.'),
('horune-dream-ship', 2, 'Forward Plasma Turrets (2)', '1D4x100 M.D. single, 2D4x100 M.D. double.', 1, '6000 feet (1830 m) in air, 300 feet (91 m) underwater.', 'Five times per melee round.', NULL, NULL, NULL),
('horune-dream-ship', 3, 'Laser Cannon Turrets (2)', '4D6x10 M.D.', 1, 'One mile (1.6 km) in air, 3000 feet (914 m) underwater.', NULL, NULL, NULL, NULL),
('horune-dream-ship', 4, 'Heavy Torpedo Launchers (2)', '4D6x10 M.D.', 1, 'Twenty miles (32 km)', NULL, '60 torpedoes.', NULL, NULL),
('horune-dream-ship', 5, 'Missiles', '2D4x10 M.D. long and medium range; 1D4x100 M.D. mini-missiles.', 1, NULL, NULL, NULL, NULL, 'A typical loadout rather than a fixed one - the book says so.'),
('horune-dream-ship', 6, 'Power Armor & Robots', NULL, 0, NULL, NULL, 'Up to 100 of each combat drone aboard.', NULL, NULL),
('horune-dream-ship', 7, 'Ramming', '2D6x10 M.D. for every 20 mph of speed.', 1, 'Melee.', NULL, NULL, NULL, 'The ship takes 10% of the damage itself.'),
('horune-strike-ship', 1, 'Plasma Cannon', '1D4x100 M.D.', 1, NULL, 'Five times per melee round.', NULL, NULL, 'In place of the Dream Ship''s Storm Cannon.'),
('horune-strike-ship', 2, 'Forward Plasma Turrets (2)', '1D4x100 M.D. single, 2D4x100 M.D. double.', 1, '6000 feet (1830 m) in air, 300 feet (91 m) underwater.', NULL, NULL, NULL, NULL),
('horune-strike-ship', 3, 'Laser Cannon Turrets (2)', '4D6x10 M.D.', 1, NULL, NULL, NULL, NULL, NULL),
('horune-strike-ship', 4, 'Heavy Torpedo Launchers (2)', '4D6x10 M.D.', 1, 'Twenty miles (32 km)', NULL, '20 torpedoes.', NULL, NULL),
('horune-strike-ship', 5, 'Missiles', '1D4x10 M.D. long and medium range, plus about 100 mini-missiles.', 1, NULL, NULL, NULL, NULL, 'A typical loadout.'),
('horune-strike-ship', 6, 'Power Armor & Robots', NULL, 0, NULL, NULL, 'Up to 20 drones aboard.', NULL, NULL),
('horune-strike-ship', 7, 'Ramming', '1D4x10 M.D. for every 20 mph of speed.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('war-urchin-power-armor', 1, 'Chest Multi-System (magic)', NULL, 0, NULL, 'Three buttons, three spell choices each.', '120 P.P.E.', NULL, 'Spells cast at 5th level potency.'),
('war-urchin-power-armor', 2, 'Forearm Defense Gauntlets (magic)', 'The right gauntlet laser does 3D6 M.D.', 1, 'The laser 2000 feet (610 m).', NULL, '40 P.P.E. each.', NULL, 'Right: a laser and three spells. Left: a grapple hook and three spells.'),
('war-urchin-power-armor', 3, 'Kittani Rocket Grenade Launch Tubes (10)', NULL, 0, '300 feet (91 m)', NULL, NULL, NULL, 'A mixed payload of high explosive, concussion and gill-clogging rounds; the book gives no single damage figure.'),
('war-urchin-power-armor', 4, 'Fin Blades', '2D6 M.D. each.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('war-urchin-power-armor', 5, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('war-urchin-power-armor', 6, 'Hand to Hand Combat', 'Punch or kick 1D6 M.D.; power punch 2D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('kittani-destroyer-power-armor', 1, 'Chest Multi-System (magic)', NULL, 0, NULL, 'Three buttons, four spell choices each.', '200 P.P.E.', NULL, 'The War Urchin''s system with a fourth option per button.'),
('kittani-destroyer-power-armor', 2, 'Forearm Gauntlets (magic)', NULL, 0, NULL, 'Four options each.', '60 P.P.E. each.', NULL, NULL),
('kittani-destroyer-power-armor', 3, 'Kittani Rocket Grenade Launch Tubes (14)', NULL, 0, '300 feet (91 m)', NULL, NULL, NULL, 'Mixed round types; no single damage figure is printed.'),
('kittani-destroyer-power-armor', 4, 'Main Shoulder Gun', 'Heavy laser 1D6x10 M.D., or 2D6x10 M.D. double. Plasma 1D4x10 M.D. underwater, 1D6x10 M.D. on land.', 1, 'Lasers 4000 feet (1220 m); plasma 1000 to 3000 feet.', NULL, NULL, NULL, NULL),
('kittani-destroyer-power-armor', 5, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('kittani-destroyer-power-armor', 6, 'Hand to Hand Combat', 'Punch or kick 3D6 M.D.; power punch 6D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('kittani-war-fish-power-armor', 1, 'Forward Lasers (2)', '3D6 M.D. single, 6D6 M.D. double.', 1, '4000 feet (1220 m)', NULL, NULL, NULL, NULL),
('kittani-war-fish-power-armor', 2, 'Main Gun', '1D6x10 M.D.', 1, '1000 feet (305 m) underwater, 3000 feet (914 m) on land.', NULL, NULL, NULL, NULL),
('kittani-war-fish-power-armor', 3, 'Mini-Torpedo Launchers (2)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '12', NULL, NULL),
('kittani-war-fish-power-armor', 4, 'Fin Blades', '3D6 M.D. each.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('kittani-war-fish-power-armor', 5, 'Hand-Held Weapons', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('kittani-war-fish-power-armor', 6, 'Hand to Hand Combat', 'Restrained punch 1D6 M.D., full strength 3D4 M.D., power punch 4D6 M.D., vibro-blade slash 3D6 M.D., vibro-blade impale 3D6 M.D. per 30 mph, body or head butt 1D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('kittani-war-crab-robot-vehicle', 1, 'Right Weapon Turret', 'Lasers 4D6 M.D. single or 1D4x10+8 double; ion guns 3D6 M.D. single or 6D6 double.', 1, 'Lasers one mile (1.6 km) underwater and double that on land; ion guns 1000 feet (305 m).', NULL, NULL, NULL, NULL),
('kittani-war-crab-robot-vehicle', 2, 'Quad-Plasma Cannon Turret (2)', '1D6x10, 2D6x10, 3D6x10 or 4D6x10 M.D. as one to four barrels fire.', 1, '1000 feet (305 m) underwater, 3000 feet (914 m) on land.', NULL, NULL, NULL, 'The M.D.C. list names this the Left Weapon Turret.'),
('kittani-war-crab-robot-vehicle', 3, 'Rear Laser Mini-Turrets (2)', '3D6 M.D. single, 6D6 M.D. double.', 1, '4000 feet (1220 m)', NULL, NULL, NULL, NULL),
('kittani-war-crab-robot-vehicle', 4, 'Forward Rail Guns (2)', '1D4x10 M.D. per burst.', 1, '2000 feet (610 m) underwater, 4000 feet (1220 m) on land.', NULL, '1000 bursts each.', NULL, NULL),
('kittani-war-crab-robot-vehicle', 5, 'Leg Spikes', '2D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('kittani-war-crab-robot-vehicle', 6, 'Crab-Man Decoy Torso', 'Heat-beam eyes 1D6 M.D., doubled against unarmoured aquatic creatures; six shoulder spikes at 1D6 M.D. each; hydraulic hands punch 1D4 M.D.', 1, 'Eyes 50 feet (15 m); shoulder spikes 200 feet (61 m).', NULL, NULL, NULL, NULL),
('kittani-war-crab-robot-vehicle', 7, 'Hand to Hand Combat', 'Claw strike 1D6 M.D. restrained or 3D6 M.D. full, power claw 6D6 M.D., vibro-scissor claw 1D4x10 M.D. and capable of cutting a target in two, crush claw 3D6 M.D., leg jab 1D6 M.D., head butt 1D6 M.D.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('kittani-war-shark-submarine-mk4', 1, 'Laser Cannon Turret', '3D4x10 M.D.', 1, 'One mile (1.6 km)', NULL, NULL, NULL, NULL),
('kittani-war-shark-submarine-mk4', 2, 'Heavy Torpedo Launch Tubes (7)', '4D6x10 M.D.', 1, 'Twenty miles (32 km)', NULL, '48 in an internal magazine.', NULL, NULL),
('kittani-war-shark-submarine-mk4', 3, 'Mini-Torpedo Launch Tubes (10)', '1D6x10 M.D., high explosive or plasma.', 1, 'One mile (1.6 km)', NULL, '40 in total.', NULL, NULL),
('kittani-war-shark-submarine-mk4', 4, 'Mini-Missile SAM Launchers (4)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '200 in total.', NULL, NULL),
('kittani-war-shark-submarine-mk4', 5, 'Maw & Bite', 'Bite 2D6x100 M.D.; the internal battery of a hundred lasers does 4D6x100 M.D. concentrated, or 1D6x100 M.D. each divided.', 1, 'The lasers 500 feet (152 m).', NULL, NULL, NULL, NULL),
('kittani-war-shark-submarine-mk4', 6, 'Other Features', NULL, 0, NULL, NULL, NULL, NULL, 'A hangar releasing 8 Destroyer power armours, 24 War Urchins, 12 War Fish, 12 War Crabs and 2 Shark Mini-Subs, plus sonar, radar and communications.'),
('shark-mini-submarine-mk5', 1, 'Laser Pulse Cannon Turret', '1D4x10 M.D.', 1, '4000 feet (1220 m)', NULL, NULL, NULL, NULL),
('shark-mini-submarine-mk5', 2, 'Forward Mini-Torpedo Launch Tubes (7)', '1D6x10 M.D.', 1, 'One mile (1.6 km)', NULL, '48 in a magazine.', NULL, NULL),
('shark-mini-submarine-mk5', 3, 'Mini-Torpedo Launch Tubes (10)', '1D6x10 M.D., high explosive or plasma.', 1, 'One mile (1.6 km)', NULL, '10 in total.', NULL, NULL),
('shark-mini-submarine-mk5', 4, 'Bite Attack', '2D6x10 M.D.', 1, 'Close combat only.', 'Twice per melee round.', NULL, NULL, NULL),
('shark-mini-submarine-mk5', 5, 'Other Features', NULL, 0, NULL, NULL, NULL, NULL, 'Short-range communications and sensors.'),
('splugorth-sea-skimmer-ark', 1, 'Laser Cannon Turrets (2)', '1D4x100 M.D.', 1, 'Two miles (3.2 km)', NULL, NULL, NULL, NULL),
('splugorth-sea-skimmer-ark', 2, 'Forward Plasma Ball Turrets (2)', '2D4x100 M.D. single, 4D4x100 M.D. double - the double blast is for large ships only.', 1, '6000 feet (1830 m) in air, 300 feet (91 m) underwater.', NULL, NULL, NULL, NULL),
('splugorth-sea-skimmer-ark', 3, 'Deck Laser Turrets (2)', '1D4x10 M.D. single, 2D4x10 M.D. double.', 1, '6000 feet (1830 m)', NULL, NULL, NULL, NULL),
('splugorth-sea-skimmer-ark', 4, 'Heavy Torpedo Launch Tubes (4)', '4D6x10 M.D.', 1, 'Twenty miles (32 km)', NULL, '40 in a magazine.', NULL, NULL),
('splugorth-sea-skimmer-ark', 5, 'Power Armor & Robots', NULL, 0, NULL, NULL, NULL, NULL, NULL),
('splugorth-sea-skimmer-ark', 6, 'Ramming & Cutting Legs', '1D6x10 M.D. for every 20 mph of speed.', 1, 'Melee.', NULL, NULL, NULL, NULL),
('splugorth-sea-skimmer-ark', 7, 'Magic Ram Prow', 'Ram 1D6x100 M.D.; fire blast 2D4x10 M.D.; lightning bolt 2D6x10 M.D.', 1, 'Ram 200 feet (61 m); blasts 1,200 feet (366 m).', NULL, NULL, NULL, NULL),
('splugorth-sea-skimmer-ark', 8, 'Ark Spell Casting', NULL, 0, NULL, 'Up to nine spells per melee round, 260 spells in 24 hours.', '5,200 P.P.E.', NULL, 'Every spell of levels one through eight, cast at 9th level potency.'),
('splugorth-sea-skimmer-ark', 9, 'Magic Force Field', NULL, 0, NULL, NULL, 'Thirteen times a day.', NULL, '1,000 M.D.C. per field.'),
('splugorth-sea-skimmer-ark', 10, 'Eyes of Eylor (sensory)', NULL, 0, 'Sight seven miles; telepathy 1,200 feet (366 m).', NULL, NULL, NULL, '300x telescopic, 6,000 foot nightvision, and sensing aura, invisible and magic.'),
('splugorth-sea-skimmer-ark', 11, 'Magic Stealth', NULL, 0, NULL, NULL, NULL, NULL, 'Silent to the equivalent of an 80% prowl, and super chameleon below 12 mph.'),
('splugorth-magic-sea-fin', 1, 'Forward Laser Cannon Turret', '1D4x100 M.D.', 1, 'Two miles (3.2 km)', NULL, NULL, NULL, NULL),
('splugorth-magic-sea-fin', 2, 'Rear Laser Cannon Turrets (2)', NULL, 0, NULL, NULL, NULL, NULL, 'The book says only "same as number one" - the forward turret.'),
('splugorth-magic-sea-fin', 3, 'Forward Plasma Turret', '2D4x100 M.D.', 1, '6000 feet (1830 m) in air, 2000 feet (610 m) underwater.', NULL, NULL, NULL, NULL),
('splugorth-magic-sea-fin', 4, 'Deck Laser Turrets (6)', '1D4x10 M.D. single, 2D4x10 double, 3D4x10 triple.', 1, '6000 feet (1830 m)', NULL, NULL, NULL, NULL),
('splugorth-magic-sea-fin', 5, 'Heavy Torpedo Launch Tubes & Missile Launchers (12 and 12)', '4D6x10 M.D. from both.', 1, 'Torpedoes twenty miles (32 km); missiles forty miles (64 km).', NULL, '48 torpedoes and 48 missiles.', NULL, 'The book numbers this system "4" a second time, directly after the Deck Laser Turrets. Transcribed as printed.'),
('splugorth-magic-sea-fin', 6, 'Power Armor & Robots', NULL, 0, NULL, NULL, '20 to 40 troops typically.', NULL, NULL),
('splugorth-magic-sea-fin', 7, 'Magic Force Field', NULL, 0, NULL, NULL, 'Seven times a day.', NULL, '500 M.D.C. per field.'),
('splugorth-magic-sea-fin', 8, 'Eyes of Eylor (sensory)', NULL, 0, 'Sight seven miles; telepathy 1,200 feet (366 m).', NULL, NULL, NULL, 'Twenty eyes rather than the Ark''s thirty, with the same telescopic, nightvision and aura, invisible and magic senses.'),
('splugorth-magic-sea-fin', 9, 'Magic Stealth', NULL, 0, NULL, NULL, NULL, NULL, 'Silent to the equivalent of an 80% prowl, and super chameleon below 12 mph.');

-- Read the result back rather than trusting the exit code. INSERT OR IGNORE
-- is SILENT on a collision, which is exactly how a row goes missing without
-- an error, so these COUNT.
SELECT 'these vessels' AS assertion,
       count(*) AS got, 13 AS want
  FROM vehicles WHERE slug IN ('horune-sea-horse-sled-and-speeder', 'horune-dolphin-combat-drone', 'horune-land-shark-drone', 'horune-dream-ship', 'horune-strike-ship', 'war-urchin-power-armor', 'kittani-destroyer-power-armor', 'kittani-war-fish-power-armor', 'kittani-war-crab-robot-vehicle', 'kittani-war-shark-submarine-mk4', 'shark-mini-submarine-mk5', 'splugorth-sea-skimmer-ark', 'splugorth-magic-sea-fin');

SELECT 'their M.D.C. locations' AS assertion,
       count(*) AS got, 121 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('horune-sea-horse-sled-and-speeder', 'horune-dolphin-combat-drone', 'horune-land-shark-drone', 'horune-dream-ship', 'horune-strike-ship', 'war-urchin-power-armor', 'kittani-destroyer-power-armor', 'kittani-war-fish-power-armor', 'kittani-war-crab-robot-vehicle', 'kittani-war-shark-submarine-mk4', 'shark-mini-submarine-mk5', 'splugorth-sea-skimmer-ark', 'splugorth-magic-sea-fin');

SELECT 'their weapon systems' AS assertion,
       count(*) AS got, 83 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('horune-sea-horse-sled-and-speeder', 'horune-dolphin-combat-drone', 'horune-land-shark-drone', 'horune-dream-ship', 'horune-strike-ship', 'war-urchin-power-armor', 'kittani-destroyer-power-armor', 'kittani-war-fish-power-armor', 'kittani-war-crab-robot-vehicle', 'kittani-war-shark-submarine-mk4', 'shark-mini-submarine-mk5', 'splugorth-sea-skimmer-ark', 'splugorth-magic-sea-fin');

SELECT 'every location row points at a vessel that exists' AS assertion,
       count(*) AS got, 0 AS want
  FROM vehicle_locations l
  LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT count(*) AS underseas_vessels FROM vehicles WHERE source_book LIKE '%Underseas%';
SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-vessels-p167-190.sql');
