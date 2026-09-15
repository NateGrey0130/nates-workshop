-- Heroes Unlimited's helicopter armament systems. Printed 224 and 226.
-- Eight rows, and they close this book's equipment chapter.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-helicopter-armament.sql
--
-- ===================================================================
-- WHY THESE ARE `gear` AND NOT `vehicle_weapons`
-- ===================================================================
--
-- They look like vehicle weapons and the table would take them, but
-- `vehicle_weapons` is keyed to one `vehicle_slug` and these belong to no one
-- vehicle. The book's own framing is the reason:
--
--   "Virtually any of the following systems could be used on any helicopter.
--    The weapons were usually identical to those on armored vehicles."
--
-- Filing them under a helicopter would state the opposite of that sentence, and
-- filing eight copies under four helicopters would state it eight times. They
-- are a catalog of mountable systems, which is what `gear` is for - the same
-- place printed 207's rifle-mounted 40mm grenade launcher already sits.
--
-- EVERY ROW SAYS IT CANNOT BE CARRIED, because `gear` is what an inventory
-- draws from and nothing else in the row would stop a character pocketing a
-- six-barreled mini-gun. The book is explicit: these are large, heavy weapon
-- systems for helicopters and large armored vehicles, they can NOT be carried,
-- there is no strike bonus without the Weapon Systems skill (pilot related),
-- W.P.s do not apply, and machinegun combat rules are used.
--
-- ===================================================================
-- NO PRICES, AND THAT IS THE BOOK'S ANSWER
-- ===================================================================
--
-- Not one of the eight is priced. The book gives a reason rather than an
-- omission: availability is exclusive to the world's military, they should not
-- be made easily available even to wealthy villains, their use is strictly
-- prohibited, impossible to conceal, and constitutes deadly force on a major
-- scale - and being caught with one carries 10-30 years. A NULL `cost` with
-- that in `cost_note` is a finished row, which is the convention `gear.cost`
-- already documents.
--
-- ===================================================================
-- WHAT THE SCAN GOT WRONG
-- ===================================================================
--
-- The M-21 Coordinated System's `Attacks Per Melee:` label is the last line of
-- its entry and its value - `Five` - is stranded thirty lines further down the
-- cached text, after two whole entries. Read off a 240 dpi render of printed
-- 226, where the two sit together.
--
-- The M-21 is also the one row with TWO ranges and TWO damages, because it is a
-- combination mount: an XM-134 six-barreled 7.62mm alongside a seven-tube
-- XM-158 2.75 inch rocket launcher. Both are kept in the one row rather than
-- split, because the book prices, names and fires them as one system.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('m-5-40mm-m-75-grenade-launcher', 'M-5 40mm M-75 Grenade Launcher', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '3D4 x 10', 0, '5400ft (1650m)', 'One at a time or in volleys of 2, 4 or 6', '300 rounds', 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: four. An automatic 40mm grenade launcher with an effective radius of 20ft - see grenade damage. The book''s illustration calls it the `Thumper`, after its distinctive sound. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.224');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('xm-30-30mm-automatic-gun-xm-140', 'XM-30 30mm Automatic Gun XM-140', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '2D4 x 10', 0, '11,000ft (3355m)', '315 rounds per minute', '400 rounds', 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: four. This system employs ammunition with a dual-purpose shaped charge, enabling it to engage both `hard` targets such as armored vehicles and concrete bunkers and `soft` targets such as open trenches, trucks and wooden buildings with equal effectiveness. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.224');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('m-21-coordinated-system', 'M-21 Coordinated System', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '1D6 x 10 per rocket, or 6D6 per round from the mini-gun', 0, 'Rockets 10,000ft (3048m); mini-gun 5000ft (1524m)', 'Rockets one at a time or in volleys of 2 or 3; mini-gun in 100 round bursts', NULL, 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: five. A combination of the XM-134 six-barreled 7.62mm and a seven-tube XM-158 2.75 inch rocket launcher, which is why it has two ranges and two damages. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.226');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('xm-134-7-62mm-mini-gun', 'XM-134 7.62mm Mini-Gun', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '5D6 per round', 0, '5000ft (1524m)', 'Short bursts of 100 rounds each', '4,000 rounds', 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: four. A six-barreled 7.62mm mini-gun, usually mounted on the sides. An alternative is using it as a door gunner''s weapon. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.226');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('xm-18-7-62mm-xm-134-machinegun', 'XM-18 7.62mm XM-134 Machinegun', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '5D6 per round', 0, '2500ft (800m)', 'Short bursts of 100 rounds each', NULL, 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: five. A six-barreled 7.62mm mini-gun. An extremely high rate of fire was accomplished by using six barrels in rotation. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.226');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('xm-32-50-cal-m2', 'XM-32 .50 Cal. M2', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '7D6 per round', 0, '2500ft (800m)', '500-650 rounds per minute', NULL, 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: four. Used as a door gunner weapon or mounted on the outside. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.226');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('m-23-7-62mm-m-60d', 'M-23 7.62mm M-60D', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '5D6 per round', 0, '3000ft (1000m)', 'Short bursts of 50 rounds each', '600 rounds per gun', 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: five. A 7.62mm machinegun. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.226');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, damage,
  is_mega_damage, range, rate_of_fire, payload, description, source_book)
VALUES ('m-2-dual-machinegun-system', 'M-2 Dual Machinegun System', 'heroes-unlimited', 'weapon', NULL, 'The book prints no price: these are military-only and their possession is a crime', '5D6 per round', 0, '3750ft (1143m)', 'Short bursts of 100 rounds each', '6,000 rounds of 7.62mm ammunition supplied', 'A large, heavy weapon system to be mounted on a helicopter or a large armored vehicle. IT CAN NOT BE CARRIED. There is no bonus to strike unless the character has the Weapon Systems skill (pilot related); W.P.s do not apply, and machinegun combat rules are used. Attacks per melee: five. Twin 7.62mm machineguns. When in use, the M60 machineguns will automatically disengage when their target track leads the boresight too close to the aircraft itself. The book prints no price for any of these. Availability is exclusive to the world''s military and the book says they should not be made easily available even to wealthy villains: their use is strictly prohibited by the government, would be impossible to conceal, and constitutes deadly force on a major scale. Being caught with one is 10-30 years in prison.', 'Revised Heroes Unlimited p.226');

-- ASSERTIONS.

SELECT 'all eight armament systems landed' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226');
SELECT 'two from printed 224' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.224';
SELECT 'six from printed 226' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.226';

SELECT 'every one is a Heroes Unlimited weapon' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND system = 'heroes-unlimited' AND category = 'weapon';

-- NONE OF THEM IS MEGA-DAMAGE. Heroes Unlimited does not deal in it, and a
-- 3D4 x 10 grenade read as M.D.C. would be a hundredfold error.
SELECT 'not one of them is mega-damage' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND is_mega_damage = 1;

-- NO PRICES, WITH A REASON. The NULL is the book's answer, so every row must
-- carry the note that says why rather than looking unfinished.
SELECT 'none of them is priced' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND cost IS NULL;
SELECT 'and every one says why it has no price' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND instr(cost_note, 'military-only') > 0;

-- EVERY ROW WARNS THAT IT CANNOT BE CARRIED, which is the one thing an
-- inventory needs from these and the one thing no other column holds.
SELECT 'every row says it cannot be carried' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND instr(description, 'CAN NOT BE CARRIED') > 0;
SELECT 'and every one names the skill that gives a strike bonus' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND instr(description, 'Weapon Systems skill') > 0;

-- THE STATS LAND IN THEIR OWN COLUMNS rather than in the prose.
SELECT 'all eight carry a range and a damage' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND range IS NOT NULL AND damage IS NOT NULL AND rate_of_fire IS NOT NULL;
SELECT 'five carry the rounds the book gives them' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.224', 'Revised Heroes Unlimited p.226')
   AND payload IS NOT NULL;

-- THE M-21, whose value the cache stranded thirty lines from its label.
SELECT 'the M-21 keeps the five attacks the render settled' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'M-21 Coordinated System' AND instr(description, 'Attacks per melee: five') > 0;
SELECT 'and both of its ranges, being one mount with two weapons' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'M-21 Coordinated System'
   AND instr(range, '10,000ft') > 0 AND instr(range, '5000ft') > 0;

-- TEXT CHECKS, because a batch in this import once passed every count while
-- every string in it was mangled.
SELECT 'the XM-30 kept its shaped charge note' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'XM-30 30mm Automatic Gun XM-140'
   AND instr(description, 'dual-purpose shaped charge') > 0;
SELECT 'and the M-2 kept its boresight sentence' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'M-2 Dual Machinegun System'
   AND instr(description, 'leads the boresight too close') > 0;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-helicopter-armament.sql');
