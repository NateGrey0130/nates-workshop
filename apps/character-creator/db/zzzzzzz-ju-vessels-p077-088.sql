-- Juicer Uprising vessels, printed 77-88: the seven machines the book stats,
-- moved from prose in `gear` into the three tables built for them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzz-ju-vessels-p077-088.sql
--
-- BOOK-INGEST-AUDIT.md F41, taken for Juicer Uprising - the first of the five
-- book sessions that finding proposes. Migration 053 added `gear.vehicle_slug`
-- in its own PR ahead of this one, per F41.
--
-- THE GEAR ROWS STAY. All seven keep their slug, their price and their prose,
-- and each gains a pointer at its new vessel. They are the citation target:
-- class markdown cites gear by slug in `equipment_starting[].item_id`, and
-- `catalog_redirects` cannot forward a key out of its own catalog. On production
-- 2026-09-09 exactly one of the seven is cited - `road-boss-motorcycle`, by two
-- classes - and moving it would have broken both, silently, in the wizard.
--
-- THE VESSEL SLUG IS THE GEAR SLUG. Deliberately: the two rows are the same
-- machine, and giving the vessel a second, guessable-by-nobody name would put a
-- mapping between them that only this file knows. `gear.vehicle_slug` still
-- carries information a reader cannot derive - that this row HAS a vessel record
-- at all - and the tables are separate, so nothing collides.
--
-- READ FROM THE BOOK, NOT FROM THE GEAR ROWS. The descriptions already in
-- `gear` are a paraphrase written by an earlier import session; F41's whole
-- argument is that deriving structured combat numbers from a paraphrase is what
-- this repo's ingestion discipline exists to prevent. Every figure below was
-- read off the PDF with `scripts/read-columns.py 78 89`, printed 77-88.
--
-- `ju`'s OCR CACHE WAS NOT USED, and that is not an oversight. `book-survey`
-- section 0b names it by slug as one of the seven caches built by throwaway code -
-- raw `page.get_text()`, columns welded across the gutter - and reading it shows
-- prose from both columns interleaved line by line. Its manifest has no
-- `welded_pages` or `corrupt_pages` key, which is the tell. `read-columns.py`
-- reads the same pages cleanly off the PDF, and the offset was confirmed the
-- free way `book-survey` section 0d prescribes: cache p84 carries printed folio 83, so
-- `page_offset: 1` as `scripts/books.json` records.
--
-- SEVEN INDEPENDENT CONFIRMATIONS THAT THE READING IS RIGHT. Every price below
-- was read from the book before the catalog was consulted, and all seven match
-- the `gear.cost` an earlier session stored - including `road-boss-motorcycle`
-- at 90,000, which is the STRIPPED price rather than the 200,000 armed one, so
-- that session applied the same low-end-of-a-range convention `gear.cost`
-- documents. That is `book-survey` section 0c's "use the rows you already have as a
-- check on the reading", and it is the strongest evidence in this file.
--
-- TEXT-LAYER ARTIFACTS CORRECTED, and worth naming because they put wrong dice
-- into a numeric column if they are not: the layer renders `1D6x10` as
-- `!D6xlO` and `1D4x10` as `!D4xlO` - a `1` mis-set as `!` and a zero as a
-- lower-case O. `lbs.` arrives as `Ibs.`. Every corrected value is a dice
-- expression whose shape the book states elsewhere in the same block.
--
-- THE NG-JK1 IS ONE ENTRY DESCRIBING TWO MODELS, and Nate settled the shape on
-- 2026-09-09: ONE vessel row for the JK1A, with the heavier JK1B's figures in
-- each location's `mdc_note` and its price in `cost_note`. The book prints the
-- B values in parentheses throughout - `Arms (2) - 90 each (120 each)` - so a
-- second row would duplicate nine locations and four weapon systems to change
-- nine numbers.
--
-- FILENAME: SEVEN z's, and it has to be. `zzzzzz-vehicle-class-vocabulary.sql`
-- asserts `the row count did not move = 127` and `vessels now classed as a
-- ship = 19`; these seven rows land after it or they falsify both on every
-- rebuild. Six z's sorts `ju-` BEFORE `vehicle-`, so the seventh is what puts
-- this last. The tier already exists - `docs/operations.md` documents it and
-- `zzzzzzz-bom-sonic-blast-link.sql` is in it - so nothing new is invented.
-- Checked by sorting the real directory, not by reasoning about the prefix.

-- --- the vessels ---

INSERT OR IGNORE INTO vehicles
  (slug, name, system, vehicle_class, crew, passengers, speed_ground, speed_air,
   dimensions, weight_tons, mdc_main_body, cost, cost_note, description, source_book)
VALUES
('ng-jk1-juicer-killer-power-armor', 'NG-JK1A/B "Juicer Killer" Power Armor', 'rifts', 'power-armor',
 'One', NULL,
 'Running: 90 mph (144.8 kmph) maximum. Running tires the operator at 10% of the usual fatigue rate.',
 'JK1A: none. Only the JK1B has upper-back thrusters (70 M.D.C.), giving flight in bursts of five minutes at up to 100 mph (160 kmph), maximum altitude 300 feet (91.5 m). Both models leap 25 feet (7.6 m) high or 30 feet (9.1 m) across unassisted, or 100 feet (30.5 m) in any direction jet-assisted.',
 'Height 7 feet (2.4 m), width 4.5 feet (1.37 m), length 4 feet (1.2 m)',
 '250 lbs. (112.5 kg)', 170, 3600000,
 'JK1A 3.6 million credits new and undamaged; the JK1B model 4.4 million. Drop the price by 2 million credits if the targeting computer is not included.',
 'Northern Gun''s anti-Juicer light assault exoskeleton, built around a targeting computer that fights the suit''s four guns by itself. Two models: the JK1B is 10% larger with more armour and limited flight. Physical strength equal to a P.S. of 30; nuclear, average energy life 15 years; no cargo space. In direct competition with the Defender Power Armor, a stolen Northern Gun design now produced by the Black Market.',
 'Rifts World Book 10: Juicer Uprising p.77-79'),

('bm-japeii-defender-exoskeleton', 'BM-JAPEII "Defender" Exoskeleton', 'rifts', 'power-armor',
 'One', NULL,
 'Running: 120 mph (192 kmph) maximum. Running tires the operator at 10% of the usual rate.',
 'Not flight. Jet-assisted leaps reach 120 feet (36.5 m) high and 200 feet (61.0 m) across; the thrusters hold a hover for up to 2D4x10 seconds before overheating. Unassisted leaps reach 30 feet (9.1 m).',
 'Height 8 feet (2.7 m), width 2 feet 8 inches (0.8 m), length 4 feet (1.2 m)',
 '800 lbs. (360 kg) without ammunition or rifle; 1400 lbs. (630 kg) loaded', 210, 1100000,
 'Black market: 1.1 million credits for a new, fully powered suit.',
 'The Black Market''s urban assault and capture exoskeleton, built on a stolen Northern Gun design and armed to take Juicers alive. Physical strength equal to a P.S. of 30; nuclear, average life up to 10 years.',
 'Rifts World Book 10: Juicer Uprising p.80-81'),

('tarantula-jump-bike', 'Tarantula Jump Bike', 'rifts', 'vehicle',
 'One', NULL,
 'Top speed 200 mph (320 kmph), or 150 mph (240 kmph) on the electrical battery. Cruising speed 100 mph (160 kmph). Acceleration 0-60 in 3.1 seconds rocket assisted; braking 60-0 in 75 feet (23 m). Range 500 miles (800 km), or 12 hours continuous on battery.',
 'Not flight. The jump jets throw the bike nine feet (2.7 m) for every mile per hour travelled - a bike at 100 mph can jump as much as 900 feet (270 m) - five times before the jump tanks need refuelling.',
 'Height 4 feet 1 inch (1.2 m), width 3 feet 10 inches (1.18 m), length 8 feet 7 inches (2.6 m)',
 '1545 lbs. (695.25 kg)', 100, 80000, NULL,
 'A high-performance jump bike whose interface goggles cable to the machine and give the rider a Juicer optics helmet''s benefits plus a head-up readout of jump fuel and E-Clip status. Flex-fuel internal combustion with electric backup. Augmented humans get +15% to piloting and to the execution of jumps, tricks and special manoeuvres.',
 'Rifts World Book 10: Juicer Uprising p.81-82'),

('road-boss-motorcycle', 'Road Boss', 'rifts', 'vehicle',
 'One', NULL,
 'Top speed 185 mph (296 kmph). Acceleration 0-60 in 4.4 seconds rocket assisted; braking 60-0 in 90 feet (27.4 m). Range 725 miles (1160 km).',
 NULL,
 'Height 3 feet 10 inches (1.2 m), width 4 feet 4 inches (1.3 m), length 16 feet (4.9 m)',
 '1850 lbs. (832.5 kg)', 200, 90000,
 '200,000 credits with full weapon systems; 90,000 stripped of all weapon systems. Originally Wellington Industries, but Northern Gun and Golden Age Weaponsmiths offer comparable vehicles at comparable prices.',
 'A heavy touring motorcycle built to cruise, full-featured with anti-lock brakes, traction control, active suspension and high-density solid rubber tires, and a custom set of interface goggles or sunglasses giving the Tarantula''s benefits without the head protection. Flex-fuel internal combustion. Augmented humans get +10% to piloting and to the execution of jumps, tricks and special manoeuvres.',
 'Rifts World Book 10: Juicer Uprising p.82-84'),

('rolling-thunder-apv', '"Rolling Thunder" All-Purpose Vehicle', 'rifts', 'vehicle',
 'One pilot', 'Three passengers comfortably',
 'Top speed 166 mph (265 kmph), or 142 mph (227 kmph) on the battery system. Acceleration 0-60 in 5.7 seconds, 6.5 with the battery system; braking 60-0 in 100 feet (30.5 m). Maximum range 525 miles (840 km), or 18 hours continuous on the battery system.',
 NULL,
 'Height 5 feet 6 inches (1.65 m), width 6 feet 8 inches (2.0 m), length 20 feet (6.1 m)',
 '2875 lbs. (1295 kg)', 155, 275000,
 'Black market: 275,000 credits; manufactured by Wellington Industries.',
 'An all-purpose four-wheeled vehicle carrying a rail gun, twin particle beams and a voice-activated mine layer that can seal a road behind it against reinforcements and invaders until the mines are cleared. Flex-fuel internal combustion with electric back-up. A favourite of Juicer mercenaries.',
 'Rifts World Book 10: Juicer Uprising p.84-85'),

('ahb-2000-assault-hover-bike', 'AHB-2000 Assault Hover Bike (W.I.)', 'rifts', 'vehicle',
 'One', NULL,
 'Driving on the ground: not possible.',
 'The hover propulsion system holds a stationary hover up to 1,000 feet (305 m) or flies at a maximum 300 mph (480 kmph); cruising speed is reckoned between 100 and 200 mph (160 to 320 kmph), maximum altitude about 5,000 feet (1524 m). The hover jets need cooling after 12 hours above cruising speed and 24 hours at cruising; with short rests at cruising speed the vehicle can fly almost indefinitely.',
 'Height 4 feet (1.2 m), width 6 feet (1.8 m) counting the weapon pods, length 9 feet (2.7 m)',
 '800 lbs. (360 kg) fully loaded', 190, 900000,
 '900,000 credits for a new, undamaged, fully equipped AHB-2000.',
 'Wellington Industries'' answer to Northern Gun''s Sky King - a small hovercraft, slower than its rival but heavily armed. Nuclear, average energy life 10 years. Cargo is a small pilot''s compartment large enough for a hand weapon and a few possessions. Reducing the main body to zero destroys the aircraft; destroying one thruster costs 33% of its speed and inflicts a -10% piloting penalty.',
 'Rifts World Book 10: Juicer Uprising p.85-86'),

('ips-1-icarus-flight-system', 'IPS-1 Icarus Flight System', 'rifts', 'vehicle',
 'One', NULL,
 'Driving on the ground: not possible.',
 'Up to Mach One (670 mph/1078 kmph); only a Juicer, borg or supernatural creature can survive the G-forces and stress. Cruising speed is usually 300-400 mph (480-640 kmph); VTOL capable. Maximum altitude 20,000 feet (6096 m). The jets need cooling after 10 hours continuous at cruising speed, or six at maximum.',
 'Height 5 feet (1.5 m), wingspan 12 feet (3.6 m), length 4 feet (1.2 m)',
 '1000 lbs. (450 kg); only a Juicer or super-strong being can stand up under the weight', 120, 3200000,
 '3.2 million credits. Fair to poor availability; the Coalition States has outlawed this jet pack.',
 'A winged combat flight system worn rather than ridden, which made its name destroying dozens of Coalition Jet Cycles and holding its own against jet fighters. The pilot flies in the open and can be targeted by a called shot; the pilot''s own M.D.C. body armour protects as normal, and killing the pilot crashes the Icarus. Nuclear, average energy life five years; no cargo. The new skill Flight Pack Combat is needed to pilot it.',
 'Rifts World Book 10: Juicer Uprising p.86-88');

-- --- M.D.C. by location, in the book's printed order ---
-- `ordinal` preserves that order so a renderer can set the block the way the
-- book does. The NG-JK1's `mdc_note` carries the JK1B figure the book prints in
-- parentheses; every other vessel prints one number per location.

INSERT OR IGNORE INTO vehicle_locations (vehicle_slug, location, mdc, mdc_note, ordinal) VALUES
('ng-jk1-juicer-killer-power-armor', 'Chest Plates/Grenade Launchers (4)', 90, 'each; JK1B 120 each', 1),
('ng-jk1-juicer-killer-power-armor', 'Laser Guns (2, one on each side)', 25, 'each; JK1B 30 each', 2),
('ng-jk1-juicer-killer-power-armor', 'Particle Beam Guns (2, one on each side)', 30, 'each; JK1B 40 each', 3),
('ng-jk1-juicer-killer-power-armor', 'Head', 60, 'JK1B 75. Destroying it eliminates all optical enhancement and pilot sensory systems and every power armour combat bonus, and cuts the computer to six attacks; a called shot at -4 to strike.', 4),
('ng-jk1-juicer-killer-power-armor', 'Arms (2)', 90, 'each; JK1B 120 each', 5),
('ng-jk1-juicer-killer-power-armor', 'Forearm Mini-Rail Guns (2)', 40, 'each; JK1B 60 each', 6),
('ng-jk1-juicer-killer-power-armor', 'Legs (2)', 100, 'each; JK1B 130 each', 7),
('ng-jk1-juicer-killer-power-armor', 'Computer & Sensor Cluster (1, above head)', 80, 'JK1B 90. Destroying it nullifies every anti-Juicer advantage and reduces the computer to zero attacks; a called shot at -4 to strike.', 8),
('ng-jk1-juicer-killer-power-armor', 'Main Body', 170, 'JK1B 210. Depleting it shuts the armour down completely.', 9),

('bm-japeii-defender-exoskeleton', 'Arms (2)', 65, 'each', 1),
('bm-japeii-defender-exoskeleton', 'Neural Disrupter Rifle', 50, NULL, 2),
('bm-japeii-defender-exoskeleton', 'Forearm Mounted Variable Laser', 35, 'each', 3),
('bm-japeii-defender-exoskeleton', 'Shoulder Plates/Grenade Launchers (2)', 65, 'each', 4),
('bm-japeii-defender-exoskeleton', 'Capture Assault System', 20, NULL, 5),
('bm-japeii-defender-exoskeleton', 'Legs (2)', 120, 'each', 6),
('bm-japeii-defender-exoskeleton', 'Head', 100, NULL, 7),
('bm-japeii-defender-exoskeleton', 'Main Body', 210, 'Depleting it shuts the armour down, rendering it useless and leaving the pilot vulnerable.', 8),

('tarantula-jump-bike', 'Main Body', 100, NULL, 1),
('tarantula-jump-bike', 'Wheels (2)', 12, 'each; a difficult target, -3 on a called shot', 2),
('tarantula-jump-bike', 'Pulse Lasers (2)', 15, 'each; a difficult target, -3 on a called shot', 3),
('tarantula-jump-bike', 'Thrusters (2)', 25, 'bottom 25, rear 25; a difficult target, -3 on a called shot', 4),

('road-boss-motorcycle', 'Main Body', 200, NULL, 1),
('road-boss-motorcycle', 'Wheels (2)', 30, 'each; a difficult target, -3 on a called shot', 2),
('road-boss-motorcycle', '"Catapult" cannon', 75, NULL, 3),
('road-boss-motorcycle', 'Mini-missile launchers (2)', 20, 'each; a difficult target, -3 on a called shot', 4),
('road-boss-motorcycle', 'Lasers', 5, 'each; a difficult target, -3 on a called shot', 5),

('rolling-thunder-apv', 'Main Body', 155, NULL, 1),
('rolling-thunder-apv', 'Wheels (4)', 35, 'each; a difficult target, -2 on a called shot', 2),
('rolling-thunder-apv', 'Rail Gun', 50, NULL, 3),
('rolling-thunder-apv', 'Particle Beam Guns (2)', 20, 'each; a difficult target, -2 on a called shot', 4),

('ahb-2000-assault-hover-bike', 'Side-Mounted Laser Pods (2)', 65, 'each', 1),
('ahb-2000-assault-hover-bike', 'Side-Mounted Missile Launchers (2)', 35, 'each; a difficult target, -2 on a called shot', 2),
('ahb-2000-assault-hover-bike', 'Forward P-Beam Guns (2)', 15, 'each; a difficult target, -2 on a called shot', 3),
('ahb-2000-assault-hover-bike', 'Pilot''s Windshield (1)', 25, 'a difficult target, -2 on a called shot', 4),
('ahb-2000-assault-hover-bike', 'Rear Thrusters (3)', 60, 'each. Destroying one reduces speed by 33% and inflicts a -10% piloting penalty.', 5),
('ahb-2000-assault-hover-bike', 'Main Body', 190, 'Reducing it to zero destroys the aircraft.', 6),

('ips-1-icarus-flight-system', 'Wings (2)', 120, 'each. Destroying one costs 33% of speed, halves the dodge bonus and inflicts -30% to piloting; the missile launcher on that wing is lost too.', 1),
('ips-1-icarus-flight-system', 'Wing Thrusters (6; three per wing)', 35, 'each', 2),
('ips-1-icarus-flight-system', 'Main Thrusters (3; rear, main body)', 45, 'each', 3),
('ips-1-icarus-flight-system', 'Mini-Missile Launchers/Jet Systems (2)', 90, 'each', 4),
('ips-1-icarus-flight-system', 'Forward Lasers (2)', 20, 'each', 5),
('ips-1-icarus-flight-system', 'Main Body', 120, 'Depleting it crashes the aircraft.', 6),
('ips-1-icarus-flight-system', 'Pilot', NULL, 'As per body armour. The pilot flies in the open and can be targeted by a called shot; killing the pilot crashes the Icarus.', 7);

-- --- weapon systems, under the book's own numbering ---
-- `ordinal` is what the book prints, so a reader comparing against their copy
-- finds the same number. Systems the book numbers but does not stat - the
-- pilot's own carried weapon, hand to hand - are left out rather than given
-- invented rows; where a numbered system is a capability rather than a gun it
-- carries a `note` and no damage.

INSERT OR IGNORE INTO vehicle_weapons
  (vehicle_slug, ordinal, name, damage, is_mega_damage, range, rate_of_fire, payload, note) VALUES
('ng-jk1-juicer-killer-power-armor', 1, 'Laser Guns (2)', '3D6 M.D. per blast, or 6D6 M.D. per double blast', 1, '4000 feet (1220 m)', 'Equal to the number of hand to hand attacks of the pilot or the computer', 'Effectively unlimited', NULL),
('ng-jk1-juicer-killer-power-armor', 2, 'Particle Beam Guns (2)', '5D6 M.D. per blast, or 1D6x10 M.D. per double blast', 1, '1600 feet (488 m)', 'Equal to the number of hand to hand attacks of the pilot or the computer', 'Effectively unlimited', NULL),
('ng-jk1-juicer-killer-power-armor', 3, 'Grenade Launchers (4)', 'Varies with grenade type', 1, '1200 feet (365 m)', 'One at a time, or volleys of two or four grenades', '80 grenades total; 20 per launcher', NULL),
('ng-jk1-juicer-killer-power-armor', 4, 'Forearm Mini-Rail Guns (2)', '2D6 M.D. per short burst (one arm) or 4D6 M.D. (both)', 1, '2000 feet (610 m)', 'Short bursts only', '40 short bursts per forearm', NULL),
('ng-jk1-juicer-killer-power-armor', 5, 'Response Computer System (RCS)', NULL, 0, NULL, NULL, NULL, 'The targeting computer that makes this suit an anti-Juicer weapon: it fights the four guns itself at eight attacks per melee. Destroying it drops that to zero and nullifies every anti-Juicer advantage, leaving the pilot to work all four guns himself, each use counting as one of his own attacks.'),

('bm-japeii-defender-exoskeleton', 1, 'Neural Disrupter Rifle', 'Setting one: 2D6 S.D.C. Setting two: 2D6x10 S.D.C., roughly one M.D. point', 0, '1200 feet (365 m)', 'Up to four blasts per melee', 'Effectively unlimited; tied into the power armour''s nuclear supply', 'Non-lethal by design and the reason this suit exists. Both settings force a save vs non-lethal poison at 16 or higher; a failure leaves the target barely able to act. Setting two is geared for augmented humans and will kill a normal one.'),
('bm-japeii-defender-exoskeleton', 2, 'Shoulder Mounted Grenade Launchers (2)', 'Any type; standard issue is tear gas, concussion (1D4 M.D. to a 20 foot/6.1 m area) and fragmentation (2D6 M.D. to a 30 foot/9.1 m area)', 1, '1200 feet (365 m)', 'One at a time, or in volleys of two, four or six', '24 total; 12 per launcher, typically eight of each type', NULL),
('bm-japeii-defender-exoskeleton', 3, 'Forearm Mounted Variable Frequency Laser', '3D6 M.D. or 6D6 M.D.', 1, NULL, 'Standard', 'Effectively unlimited; tied into the power armour''s nuclear supply', NULL),
('bm-japeii-defender-exoskeleton', 4, 'Capture Assault System', '5D6 S.D.C.', 0, NULL, 'Twice per melee', '10 shots', 'The capture half of an assault-and-capture suit.'),

('tarantula-jump-bike', 1, 'Pulse Lasers', '1D4x10 M.D. per simultaneous three shot burst', 1, '1600 feet (488 m)', 'Three shot bursts only', '30 triple-shot bursts (short E-Clip only)', 'Mounted in the forward cowling.'),

('road-boss-motorcycle', 1, 'W.I. "Catapult" Assault Cannon', '1D6x10 M.D. (armor-piercing explosive)', 1, '4000 feet (1220 m)', 'Once per melee round; the magazine takes time to cycle', '20 shells', NULL),
('road-boss-motorcycle', 2, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'One mile (1.6 km)', 'One at a time, or volleys of two, three or four', '16 total; eight per launcher', NULL),
('road-boss-motorcycle', 3, 'Variable Lasers (3)', '1D6+6 M.D. for the centre laser only; 4D6 M.D. for all three firing simultaneously', 1, '4000 feet (1220 m)', 'Standard', '30 single blasts, or 10 triple-blasts per long clip', 'A triple brace of light, variable-frequency lasers on the front cowling.'),

('rolling-thunder-apv', 1, 'NG-202 Rail Gun', 'A 40-round burst inflicts 1D4x10 M.D.', 1, '4000 feet (1220 m)', 'Standard', 'A 300 round belt as a machinegun', 'Cannot be operated by the driver.'),
('rolling-thunder-apv', 2, 'Twin Particle Beams', '5D6 M.D. per single blast, or 1D6x10 M.D. per double', 1, '1200 feet (365 m)', 'Standard', '50 single shots or 25 double', 'Forward weapons, connected to the driver''s controls.'),
('rolling-thunder-apv', 3, 'Mobile Mine Deployment System', 'Varies by mine type; carries all three', 1, 'The radio transmitter reaches roughly 3000 feet', 'One per melee round (15 seconds)', '12 total; four of each type', 'Voice-activated. Mines cost 400 credits light, 600 medium and 1000 heavy.'),

('ahb-2000-assault-hover-bike', 1, 'Particle Beam Guns (2)', 'A single blast from one gun inflicts 5D6 M.D.', 1, '1600 feet (488 m)', 'Equal to the number of hand to hand attacks of the pilot', 'Effectively unlimited', 'Over-and-under energy cannons.'),
('ahb-2000-assault-hover-bike', 2, 'Laser Pods (2)', 'Each beam does 1D6 M.D.', 1, '6000 feet (1830 m)', 'Equal to the number of hand to hand attacks of the pilot', 'Effectively unlimited', 'Side-mounted pods of five lasers each, which can be refocused.'),
('ahb-2000-assault-hover-bike', 3, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'About one mile (1.6 km)', 'One at a time, or in volleys of two, three or six', 'Six total; three per launcher', NULL),

('ips-1-icarus-flight-system', 1, 'High-Powered Laser Guns (2)', '5D6 M.D. per single blast, or 1D6x10 M.D. per double', 1, '4000 feet (1220 m)', 'Equal to the number of hand to hand attacks of the pilot', 'Effectively unlimited', NULL),
('ips-1-icarus-flight-system', 2, 'Mini-Missile Launchers (2)', 'Varies with missile type', 1, 'About one mile (1.6 km)', 'One at a time, or in volleys of 2, 4, 6 or 12', '12 total; six per wing launcher', 'The tip of each wing holds six.');

-- --- point the gear rows at their vessels ---
-- The rows STAY. This adds a pointer and changes nothing else - not the name,
-- not the price, not the category, not the description.
UPDATE gear SET vehicle_slug = slug
 WHERE category = 'vehicle'
   AND source_book LIKE '%Juicer Uprising%'
   AND slug IN ('ng-jk1-juicer-killer-power-armor', 'bm-japeii-defender-exoskeleton',
                'tarantula-jump-bike', 'road-boss-motorcycle', 'rolling-thunder-apv',
                'ahb-2000-assault-hover-bike', 'ips-1-icarus-flight-system');

-- --- readback ---
-- INSERT OR IGNORE is SILENT on a collision, which is exactly how a row goes
-- missing without an error, so these COUNT.

SELECT 'the seven vessels' AS assertion, count(*) AS got, 7 AS want
  FROM vehicles WHERE source_book LIKE '%Juicer Uprising%';

SELECT 'their M.D.C. locations' AS assertion, count(*) AS got, 43 AS want
  FROM vehicle_locations l JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.source_book LIKE '%Juicer Uprising%';

SELECT 'their weapon systems' AS assertion, count(*) AS got, 21 AS want
  FROM vehicle_weapons w JOIN vehicles v ON v.slug = w.vehicle_slug
  WHERE v.source_book LIKE '%Juicer Uprising%';

SELECT 'every location points at a vessel that exists' AS assertion, count(*) AS got, 0 AS want
  FROM vehicle_locations l LEFT JOIN vehicles v ON v.slug = l.vehicle_slug
  WHERE v.slug IS NULL;

SELECT 'the seven gear rows now point at a vessel' AS assertion, count(*) AS got, 7 AS want
  FROM gear WHERE vehicle_slug IS NOT NULL;

-- Every pointer resolves. A dangling one is allowed by the schema on purpose -
-- the other four books are not imported yet - but none of THESE may dangle.
SELECT 'and every one of those pointers resolves' AS assertion, count(*) AS got, 0 AS want
  FROM gear g LEFT JOIN vehicles v ON v.slug = g.vehicle_slug
  WHERE g.vehicle_slug IS NOT NULL AND v.slug IS NULL;

-- The gear rows are untouched apart from the pointer. `road-boss-motorcycle` is
-- the one of the seven any class cites, so it is the one worth naming.
SELECT 'the cited gear row is still in the gear catalog' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'road-boss-motorcycle' AND category = 'vehicle' AND cost = 90000;

-- Scoped to THIS book's seven. The global version of this belongs to
-- zzzzzz-vehicle-class-vocabulary.sql, which owns the other 127 and asserts it
-- there; asserting it again here fails on any environment that has not had that
-- script applied, which says nothing about these rows.
SELECT 'these seven carry a documented class' AS assertion, count(*) AS got, 0 AS want
  FROM vehicles
  WHERE source_book LIKE '%Juicer Uprising%'
    AND vehicle_class NOT IN ('power-armor', 'robot', 'drone', 'borg', 'vehicle', 'ship', 'other');

SELECT count(*) AS total_vessels FROM vehicles;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-ju-vessels-p077-088.sql');
