-- Africa gear and vehicles: 14 gear rows and 4 vehicles from Rifts World
-- Book 4: Africa.
--
--   The Phoenix Empire's weapons of note, printed 140-141: K-4 Laser Pulse
--     Rifle, K-30 Ion Pulse Rifle, KEP-Special Energy Pump Pistol, K-E4 Plasma
--     Ejector, K-500 Rail Gun, Kittani Class Two Combat Shield
--   The Medicine Man's magic items, printed 80-82: medicine stick, medicine
--     horn, Kifaalu taboo horn, Mayembe horns of divining, Magic Wings, and
--     three protective charms
--   The Phoenix Empire's vehicles, printed 136-140: Phoenix Power Armor,
--     Phoenix Sand Skimmer, Phoenix Sand Crawler, Robot Spy Wing
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzz-africa-gear-and-vehicles.sql
--
-- NAMED TO SORT AFTER zzzzzz-vehicle-class-vocabulary.sql, which asserts the
-- whole vehicles table holds exactly 127 rows. Four new vehicles written
-- before it would make that read-back false on a clean rebuild.
--
-- EVERY NUMBER WAS READ OFF A 150-170 DPI RENDER, not the text layer: printed
-- 140-141 set their dice as 306+6, 406, 506, 606 and 104 in the text layer (a
-- D read as 0 that no detector counts), and the vehicle stat blocks sit around
-- full-page art.
--
-- TWO WEAPONS ON PRINTED 140-141 ARE NOT HERE, because production already
-- holds them from Triax (printed 214 there) with every number equal: the
-- Kittani Plasma Sword (2D6 / 4D6 M.D., 3 lbs, 28,000) and the Kittani Plasma
-- Axe, which Triax stores as the human-size Kittani Double Blade Plasma Axe
-- (3D6 / 6D6 M.D., 10 lbs, 32,000).
--
-- PRINTED 139 SAYS THE WEAPONS OF NOTE ARE REPRINTED FROM RIFTS WORLD BOOK
-- TWO: ATLANTIS. The catalog holds no Atlantis rows, so this book is the
-- citation; each description says so.
--
-- THE MEDICINE MAN'S ITEMS ARE MADE, NOT BOUGHT. Each prints a P.P.E. cost to
-- create and no credit price, so cost is NULL with the P.P.E. in cost_note,
-- category 'magic' - the South America bio-weapon convention. Two rituals
-- printed inside his charm list ride on the item they use rather than becoming
-- spells: the area version of the protection against witches (160 P.P.E.) on
-- that charm, and Witch Lure (120 P.P.E.) on the medicine horn.
--
-- The vehicles' hand to hand tables and sensor notes are in the description,
-- not in vehicle_weapons, which holds the fixed weapon systems.
--
-- DESCRIPTIONS ARE PARAPHRASES, never the book's prose.

INSERT OR IGNORE INTO gear
  (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage,
   range, payload, rate_of_fire, ar, sdc, mdc, description, source_book)
VALUES
  ('k-4-laser-pulse-rifle', 'K-4 Laser Pulse Rifle', 'rifts', 'weapon', 4, 75000, NULL,
   '3D6+6 M.D. per single shot, or 1D6x10+6 M.D. per multiple pulse burst (three simultaneous shots)', 1,
   '3000 feet (910 m)', '30 shots, standard long E-Clip', 'Standard',
   NULL, NULL, NULL,
   'A knock-off of a Wilk''s Laser Industries rapid-fire pulse rifle: light, black plastic and ceramic construction, long range and dependable. +1 to strike on an aimed shot. One of the Phoenix Empire''s common weapons, which this book reprints from Rifts World Book Two: Atlantis.',
   'Rifts World Book 4: Africa p.140'),
  ('k-30-ion-pulse-rifle', 'K-30 Ion Pulse Rifle', 'rifts', 'weapon', 7, 45000, NULL,
   '4D6 M.D. per single shot, or 1D6x10+6 M.D. per multiple pulse burst (three simultaneous shots, at -2 to strike)', 1,
   '1000 feet (305 m)', '15 shots from a short E-Clip or 30 from a long E-Clip', 'Standard',
   NULL, NULL, NULL,
   'A light, dependable close-range ion rifle with rapid-fire bursts. Reprinted in this book from Rifts World Book Two: Atlantis.',
   'Rifts World Book 4: Africa p.140'),
  ('kep-special-energy-pump-pistol', 'KEP-Special Energy Pump Pistol', 'rifts', 'weapon', 4, 26000, NULL,
   '5D6 M.D.', 1,
   '200 feet (61 m)', '10 blasts from a short clip or 20 from a long', 'Equal to the user''s hand to hand attacks; each pump counts as a melee attack',
   NULL, NULL, NULL,
   'A short-range pump-action ion blaster that handles like a sawed-off shotgun. Reprinted in this book from Rifts World Book Two: Atlantis.',
   'Rifts World Book 4: Africa p.140'),
  ('k-e4-plasma-ejector', 'K-E4 Plasma Ejector', 'rifts', 'weapon', 12, 60000, '60,000 credits; good availability.',
   '6D6 M.D.', 1,
   '2000 feet (610 m)', '20 shots from a standard clip or 30 from a long E-Clip', 'Standard',
   NULL, NULL, NULL,
   'A heavy plasma weapon patterned on Northern Gun designs; a little heavy, with a telescopic sight that any optic system can replace. Reprinted in this book from Rifts World Book Two: Atlantis.',
   'Rifts World Book 4: Africa p.140'),
  ('k-500-rail-gun', 'K-500 Rail Gun', 'rifts', 'weapon', 80, 155000, '155,000 credits; fair availability.',
   'A 30-round burst does 6D6 M.D.; a single round does 1D4 M.D.', 1,
   '4000 feet (1200 m)', 'As a machinegun, a 390-round belt (13 full bursts); or a 90-round mini-clip (3 bursts) weighing 33 lbs (14.9 kg)', 'Standard',
   NULL, NULL, NULL,
   'A light rail gun like the Triax borg gun, for borgs and for creatures of P.S. 24 or more with a high P.E.; it can also be tripod-mounted as a machinegun. Telescopic night-vision scope and laser targeting, +1 to strike. The gun weighs 80 lbs (36.3 kg), its power pack 30 lbs (13.6 kg), one ammo belt 25 lbs (11 kg). Reprinted in this book from Rifts World Book Two: Atlantis.',
   'Rifts World Book 4: Africa p.140'),
  ('kittani-class-two-combat-shield', 'Kittani Class Two Combat Shield', 'rifts', 'armor', NULL, 30000, '30,000 credits; fair availability.',
   NULL, 0,
   NULL, NULL, NULL,
   NULL, NULL, 120,
   'A shield for blocking and parrying physical attacks and energy blasts; a successful parry means the shield takes half the damage. Parrying fast energy blasts is possible at -4. Reprinted in this book from Rifts World Book Two: Atlantis.',
   'Rifts World Book 4: Africa p.141'),
  ('medicine-stick', 'Medicine Stick', 'rifts', 'magic', NULL, NULL, 'No credit price; a medicine man makes his own for 800 P.P.E. in a 48-hour ritual.',
   '2D6 S.D.C. as a normal weapon, double against witches; 4D6 M.D. against werebeasts, evil spirits and mega-damage creatures', 1,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'The medicine man''s scepter-like club, charged with good medicine: smashing an object charged with bad medicine harmlessly destroys the curse. It makes its maker impervious to witch magic (only a witch''s), gives him +1 to parry, and is indestructible in his hands. Anyone else holding it is +2 to save vs possession and mind control, +2 vs disease and poison, +4 vs horror factor, fear and illusions, and +10% vs coma/death. If destroyed he must make another; if stolen, recover it.',
   'Rifts World Book 4: Africa p.80'),
  ('medicine-horn', 'Medicine Horn', 'rifts', 'magic', NULL, NULL, 'No credit price; a medicine man makes his own for 500 P.P.E. Only one is made unless it is lost.',
   NULL, 0,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'A decorated buffalo horn that focuses the medicine man''s rituals, meditation and spirit summoning and is used to make his other charms. Impervious to fire and heat, indestructible in its maker''s hands, and a 50 P.P.E. battery only its maker can draw on, once per 24 hours; it loses all magic when he dies. Witch Lure (printed 82, 120 P.P.E.): left in the open, the horn draws a witch''s magic snakes and other conjured servants to itself, where they can be seen and destroyed.',
   'Rifts World Book 4: Africa p.80-82'),
  ('kifaalu-taboo-horn', 'Kifaalu Taboo Horn', 'rifts', 'magic', NULL, NULL, 'No credit price; a medicine man makes it for 1200 P.P.E., as a charm or as a weapon.',
   'As a worn charm: 5D6 M.D. against evil demons, supernatural monsters and creatures of magic. Made into an axe or club instead: 1D6 S.D.C., or 1D6x10 M.D. against werebeasts and other evil spirits', 1,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'A rhino-horn taboo charm worn at the neck. Supernatural beings that attack its wearer suffer taboo-like haunting: -1 attack per melee, -1 to save vs horror factor and magic fear, -2 to all combat bonuses; vampires and animated dead cannot attack at all. If the wearer strikes first, the taboo is void. The wearer is +2 to save vs evil spirits'' magic and poison and +2 vs horror factor. Made into a weapon, it keeps none of the taboo powers or bonuses.',
   'Rifts World Book 4: Africa p.81'),
  ('mayembe-horns-of-divining', 'Mayembe Horns of Divining', 'rifts', 'magic', NULL, NULL, 'No credit price; a medicine man makes them for 350 P.P.E.',
   NULL, 0,
   'One mile per level of the medicine man', NULL, NULL,
   NULL, NULL, NULL,
   'Buffalo or buck horns used to find water, lost articles, lost children, and a missing medicine stick or horn.',
   'Rifts World Book 4: Africa p.81'),
  ('magic-wings', 'Magic Wings', 'rifts', 'magic', NULL, NULL, 'A medicine man''s charm, 100 P.P.E.; no credit price.',
   NULL, 0,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'An insect-wing charm: a pair of butterfly or moth wings is burnt in a sung and danced ceremony and ectoplasmic wings, sized to the wearer, grow from the body with the instinct to use them. Any mortal creature can receive them; creatures of magic and supernatural beings cannot. Flies up to 80 mph (128 km) or hovers; +1 to parry, +3 to dodge and +3 to S.D.C. damage from dives and airborne strikes. Lasts 15 minutes per level of the medicine man.',
   'Rifts World Book 4: Africa p.81'),
  ('charm-protection-from-disease', 'Charm: Protection from Disease', 'rifts', 'magic', NULL, NULL, 'A medicine man''s charm, 310 P.P.E.; no credit price.',
   NULL, 0,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'The wearer is +2 to save against all diseases and sicknesses, magical or natural; a disease that is caught runs half its symptoms and duration. A medicine man''s charm lasts years, until its maker deactivates it or it is destroyed.',
   'Rifts World Book 4: Africa p.81'),
  ('charm-protection-against-witch-life-drain', 'Charm: Protection against the Witch''s Life Drain', 'rifts', 'magic', NULL, NULL, 'A medicine man''s charm, 220 P.P.E.; no credit price.',
   NULL, 0,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'A seed pod, or 2D4 seeds in a tiny decorated pouch or bottle. The witch''s life-eating power normally allows no saving throw; this charm gives a save vs magic of 13 or higher.',
   'Rifts World Book 4: Africa p.81'),
  ('charm-protection-against-witches', 'Charm: Protection against Witches and Witchcraft', 'rifts', 'magic', NULL, NULL, 'A medicine man''s charm, 80 P.P.E.; the area ritual costs 160 P.P.E. thanks to the medicine horn. No credit price.',
   NULL, 0,
   NULL, NULL, NULL,
   NULL, NULL, NULL,
   'A buffalo bone or horn carving on a necklace or bracelet; the wearer is +2 to save vs a witch''s magic, curses and evil eye. The area version (printed 81-82) is a ritual chanted at each entrance of a village or building while ground horn is sprinkled, ending with the medicine horn driven into the ground at the main entrance: witches and their magic snakes cannot enter for one day per level of the medicine man, and removing the horn breaks it. Villagers usually follow him chanting to supply the P.P.E.',
   'Rifts World Book 4: Africa p.81-82');

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   speed_water, dimensions, weight_tons, mdc_main_body, cost, cost_note,
   description, source_book)
VALUES
  ('phoenix-power-armor', 'Phoenix Power Armor (Modified K-Universal)', 'rifts', 'power-armor', 'One', NULL,
   'Running 40 mph (64 km) maximum, tiring the pilot 20% less than normal. With a running start, power jumps of up to 300 feet (91.5 m) up or lengthwise; leap-running sustains 170 mph (272 km) for unlimited hours (reduce 40% in dense vegetation).',
   'With the optional jet pack: hover up to 300 feet (91.5 m) or fly at 100 mph (160 km) maximum; half an hour of constant flight overheats the jets and they shut down.',
   NULL, 'Height 8 to 15 feet (2.4 to 4.6 m), width 4.4 to 6 feet (1.34 to 1.8 m), length about 3 to 6 feet (0.9 to 1.8 m)',
   'Typically 300 lbs (135 kg) with jet pack', 200, 1400000,
   '1.4 million credits new with jet pack, 1.3 million without; good availability only in the Phoenix Empire and the city of Splynn in Atlantis.',
   'Kittani UPA model: the K-Universal, itself a mass-market version of the Kittani Manling, modified for the Phoenix Empire; the city of Rama builds 72 a month. A light environmental exo-skeleton sized for humans up to ogres, trolls and gurgoyles. P.S. 30; nuclear, 10-year life; full helmet optics. +1 to strike with long-range weapons only; +1 to parry and dodge, and +2 to dodge while power jumping. No weapon systems: the wearer carries a hand-held energy weapon.',
   'Rifts World Book 4: Africa p.136-137'),
  ('phoenix-sand-skimmer', 'Phoenix Sand Skimmer', 'rifts', 'vehicle', 'One pilot', 'Two',
   NULL, 'Hover stationary or fly up to 660 mph (1063 km), just under Mach one; ceiling 1000 feet (305 m).',
   NULL, 'Height 10 feet (3 m), width 15 feet (4.6 m), length 24 feet (7.3 m)',
   '8 tons', 250, 6500000,
   '6.5 million credits; good availability only in the Phoenix Empire and the city of Splynn in Atlantis.',
   'A hover jet ATV built from technology the Pharaoh stole and will not share, though he has sold hundreds to bandits and pirates. Thousands of mite-sized robots clean and shield it against sand. Utility arm P.S. 30; cargo a 4 by 4 foot (1.2 x 1.2 m) space; nuclear, 10-year life. Hand to hand with its arms: restrained punch 3D6 S.D.C., full punch 1D4 M.D., power punch 2D4 M.D. (two attacks), body block/ram 4D6 M.D. with a 01-85% knockdown (two attacks). Highly maneuverable: +5% piloting, one extra attack per melee, +3 initiative, +3 strike, +6 dodge. Basic jet and robot sensors.',
   'Rifts World Book 4: Africa p.137-138'),
  ('phoenix-sand-crawler', 'Phoenix Sand Crawler', 'rifts', 'vehicle', 'One pilot', 'Two',
   'Pulls itself along with its large claw appendage and directional thrusters, and can dig in and bury itself in sand or loose soil, where radar, infrared and heat detection cannot find it.',
   'Hovers two feet (0.6 m) above the ground at up to 180 mph (290 km), invisible to most radar (85%) at that height; up to 10 feet (3 m) at half speed.',
   NULL, 'Height 10 feet (3 m) on its legs, width 12 feet (3.6 m), length 15 feet (4.6 m)',
   '1.5 tons', 280, 2000000,
   'Two million credits; good availability only in the Phoenix Empire and the city of Splynn in Atlantis.',
   'The Sand Skimmer''s companion, from the same stolen technology and with the same mite-robot sand shielding. Claw P.S. 40; cargo a 4 by 4 foot (1.2 x 1.2 m) space; nuclear, 10-year life. Hand to hand: claw strike 1D6 M.D.; body block/ram 2D6 M.D. with a 01-50% knockdown (two attacks). +1 initiative, +1 strike, +3 dodge, prowl 50%. Seismic sensors monitor the surface while buried; full optics, long-range radar, dosimeter and distress signaller.',
   'Rifts World Book 4: Africa p.137-139'),
  ('robot-spy-wing', 'Robot Spy Wing', 'rifts', 'drone', 'None; remote-piloted', NULL,
   NULL, 'Hover or fly up to 140 mph (224 km), from two feet (0.6 m) to 1000 feet (305 m) up.',
   NULL, 'Height 3 feet (0.9 m) including fin, width 6 feet (1.8 m), length 4 feet (1.2 m)',
   '90 lbs (40.8 kg)', 40, 40000,
   '40,000 credits with a conventional power system, 500,000 with a nuclear battery (two-year life); good availability only in the Phoenix Empire.',
   'A flying camera: everything it sees and hears goes to a receiver up to 100 miles (160 km) away, and its remote pilot sees what it sees. No weapons.',
   'Rifts World Book 4: Africa p.139-140');

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal)
VALUES
  ('phoenix-power-armor', 'Rear Jet Pack (1, optional)', 50, 'Destroying it makes flight and power jumps impossible.', 1),
  ('phoenix-power-armor', 'Shoulders (2)', 90, 'Each.', 2),
  ('phoenix-power-armor', 'Legs (2)', 100, 'Each.', 3),
  ('phoenix-power-armor', 'Shield (1, optional)', 150, NULL, 4),
  ('phoenix-power-armor', 'Head', 80, 'Small target: hit only by a called shot, at -3. Destroying it has a 01-70% chance of knocking the pilot unconscious; if conscious, the pilot loses the power armor combat bonuses and the head is exposed.', 5),
  ('phoenix-power-armor', 'Main Body', 200, 'Depleting it shuts the armor down completely.', 6),
  ('phoenix-sand-skimmer', 'Weapon Arm (1)', 30, 'Small target: called shot only, at -3.', 1),
  ('phoenix-sand-skimmer', 'Extendable Utility Arm (1)', 20, 'Small target: called shot only, at -3.', 2),
  ('phoenix-sand-skimmer', 'Forward Air Foils (2)', 50, 'Each. Small target: called shot only, at -3.', 3),
  ('phoenix-sand-skimmer', 'Rear Wings (2)', 80, 'Each.', 4),
  ('phoenix-sand-skimmer', 'Top Sensor Head (1)', 20, 'Small target: called shot only, at -3.', 5),
  ('phoenix-sand-skimmer', 'Rotating Hover Jet Drums (2)', 100, 'Each. Small target: called shot only, at -3.', 6),
  ('phoenix-sand-skimmer', 'Directional Thrusters (8)', 10, 'Each. Small target: called shot only, at -3.', 7),
  ('phoenix-sand-skimmer', 'Pilot & Crew Compartment', 50, NULL, 8),
  ('phoenix-sand-skimmer', 'Main Body', 250, 'Depleting it destroys the vehicle.', 9),
  ('phoenix-sand-crawler', 'Extendable Utility Arm (1)', 10, 'Small target: called shot only, at -3.', 1),
  ('phoenix-sand-crawler', 'Weapon Arm (1, right side)', 50, 'Small target: called shot only, at -3.', 2),
  ('phoenix-sand-crawler', 'Secondary Weapon Appendage (1, left)', 30, 'Small target: called shot only, at -3.', 3),
  ('phoenix-sand-crawler', 'Crawling & Digging Appendage (1, large)', 80, NULL, 4),
  ('phoenix-sand-crawler', 'Forward Sensor Head (1, large)', 50, 'Small target: called shot only, at -3.', 5),
  ('phoenix-sand-crawler', 'Rotating Hover Jet Drum (1, undercarriage)', 100, 'Small target: called shot only, at -3.', 6),
  ('phoenix-sand-crawler', 'Main Thrusters (2, shoulder plates)', 100, 'Each.', 7),
  ('phoenix-sand-crawler', 'Directional Thrusters (6)', 10, 'Each. Small target: called shot only, at -3.', 8),
  ('phoenix-sand-crawler', 'Pilot & Crew Compartment', 80, NULL, 9),
  ('phoenix-sand-crawler', 'Main Body', 280, 'Depleting it destroys the vehicle.', 10),
  ('robot-spy-wing', 'Wings (2)', 10, 'Each.', 1),
  ('robot-spy-wing', 'Main Jet Thrusters (1, rear)', 10, NULL, 2),
  ('robot-spy-wing', 'Main Body', 40, 'Depleting it destroys the bot.', 3);

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, bonus, note)
VALUES
  ('phoenix-sand-skimmer', 1, 'Pulse Cannon (right arm)', '1D4x10 M.D. per multiple energy pulse, or 2D6 M.D. per single shot', 1, '4000 feet (1200 m)', 'Equal to combined hand to hand attacks (usually 4-6)', 'Effectively unlimited; draws on the vehicle''s power supply', NULL, 'Assault, secondary defense.'),
  ('phoenix-sand-skimmer', 2, 'Concealed Mini-Missile Launcher', 'Varies with missile type; standard issue armor piercing (1D4x10 M.D.) or plasma (1D6x10)', 1, 'Usually about a mile', 'One or two', 'Two', NULL, 'Mounted above the right shoulder. Anti-aircraft, secondary defense; fragmentation for anti-personnel.'),
  ('phoenix-sand-crawler', 1, 'Double-Barrel Pulse Cannon (right arm)', '1D4x10 M.D. per multi-pulse blast, or 2D4x10 M.D. per double-barrel pulse', 1, '4000 feet (1200 m)', 'Equal to combined hand to hand attacks (usually 4-6)', 'Effectively unlimited; draws on the vehicle''s power supply', NULL, 'Assault, secondary defense.'),
  ('phoenix-sand-crawler', 2, 'Dual Light Lasers & Ion Blaster (left appendage)', 'Lasers 2D6 M.D. per single blast or 4D6 M.D. per double shot (one attack); ion blaster 6D6 M.D. per blast', 1, 'Lasers 2000 feet (610 m), ion blaster 1000 feet (305 m)', 'Equal to the pilot''s hand to hand attacks', 'Effectively unlimited', NULL, 'Defense. Three forward ports that angle 90 degrees up and down.');

-- Read the result back.
SELECT 'the 14 gear rows' AS assertion, count(*) AS got, 14 AS want
  FROM gear WHERE source_book LIKE 'Rifts World Book 4: Africa p.%';

SELECT 'six Phoenix arms and armor, priced' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE source_book LIKE 'Rifts World Book 4: Africa p.14%' AND cost > 0;

SELECT 'eight Medicine Man items, priced only in P.P.E.' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book LIKE 'Rifts World Book 4: Africa p.8%'
   AND category = 'magic' AND cost IS NULL AND cost_note LIKE '%P.P.E.%';

SELECT 'the 4 vehicles' AS assertion, count(*) AS got, 4 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 4: Africa p.%';

SELECT 'their main bodies: 200 + 250 + 280 + 40' AS assertion, sum(mdc_main_body) AS got, 770 AS want
  FROM vehicles WHERE source_book LIKE 'Rifts World Book 4: Africa p.%';

SELECT 'their M.D.C. locations: 6 + 9 + 10 + 3' AS assertion, count(*) AS got, 28 AS want
  FROM vehicle_locations WHERE vehicle_slug IN ('phoenix-power-armor', 'phoenix-sand-skimmer', 'phoenix-sand-crawler', 'robot-spy-wing');

SELECT 'their weapon systems: 0 + 2 + 2 + 0' AS assertion, count(*) AS got, 4 AS want
  FROM vehicle_weapons WHERE vehicle_slug IN ('phoenix-power-armor', 'phoenix-sand-skimmer', 'phoenix-sand-crawler', 'robot-spy-wing');

SELECT 'the two Triax Kittani weapons are still the only copies' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Kittani Plasma Sword', 'Kittani Double Blade Plasma Axe', 'Kittani Plasma Axe');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-africa-gear-and-vehicles.sql');
