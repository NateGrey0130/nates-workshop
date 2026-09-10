-- New West robot animal options: the Special Robot Features and Weapon Options
-- sold for a robot horse or a Bandit K-9. Printed 196 and 200. Thirteen rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-new-west-gear-e-robot-animal-options.sql
--
-- == WHY THIS FILE EXISTS: A COUNT THAT ANSWERED FOR THE WRONG PAGES ==
--
-- The four gear batches (#895, #896, #897, #898) closed with a summary saying
-- 78 priced lines across printed 171-223 were "all accounted for". They were
-- not. The 78 is a count over a page range that INCLUDES the vessel pages, and
-- these thirteen entries sit on printed 196 and 200, in the middle of the robot
-- horse section - priced goods, in prose, on pages nobody had read yet. The
-- vessel batches then took the vessels and left these behind, because they are
-- gear rather than vehicles.
--
-- The summary was true of every page those batches touched and false about the
-- range it named. **A count taken over a page range answers for that whole
-- range**, and claiming it discharged means checking every page in it - not the
-- pages the work happened to cover. That is what this file closes.
--
-- == THE CHEMICAL SPRAY IS A SECOND ROW ON PURPOSE ==
--
-- `catalog-diff --remote` reported it as "matched only by an alias -> Chemical
-- Spray", which is the existing bionics row from add-new-west-gear-b-bionics.sql
-- (printed 187). They are NOT the same item: printed 196 says the robot animal
-- version is "basically the same as the cyborg unit, ONLY WITH DOUBLE THE
-- PAYLOAD", and prices it at 45,000 where the bionic one carries no price at
-- all. Two rows, distinguished by name. The alias warning is the diff working:
-- it is how a deliberate near-duplicate gets looked at instead of merged.
--
-- == THE TWO ION BLASTERS DIFFER, AT THE SAME PRICE ==
--
-- The robot HORSE's head ion blaster does 3D6 M.D. (6D6 dual) at 800 feet;
-- the robot DOG's does 2D6 M.D. (4D6 dual) at 600 feet. Both cost 32,000
-- credits each. Printed 196 and 200 respectively. Same name in the book, two
-- different weapons, so two rows.
--
-- == EXTRA ARMOR IS NOT A ROW ==
--
-- "Add 30% to all M.D.C. for the deluxe, armored model, but also add 30% to the
-- cost" is a MODIFIER on the animal, not a thing with a price of its own. It is
-- already recorded in each robot animal's `cost_note` in the vessel scripts.
--
-- Prices are for the "basic", robot-looking animal, which is what printed 196
-- states outright.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('life-like-fur-covering-robot-animal', 'Life-Like Fur Covering (robot animal)', 'rifts', 'gear', NULL, 14000, '14,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A life-like fur covering with padding and fake musculature, tail, mane and hoof coverings, making a robot horse look like a normal animal. About 40% of all robot horse purchases are made WITHOUT it. A robot horse with fur cannot take secret compartments. The Bandit K-9 typically comes with its fur covering as standard rather than as an extra.', 'Rifts World Book 14: New West p.196'),
('voice-recognition-and-response-robot-animal', 'Voice Recognition and Response (robot animal)', 'rifts', 'gear', NULL, 100000, '100,000 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Gives a robot horse or Bandit K-9 voice recognition and response - it talks. Most robot animals are programmed to act like the genuine animal without the fear response; this is what lets one answer back. The single most expensive non-weapon option in the section.', 'Rifts World Book 14: New West p.196'),
('secret-compartment-small-robot-animal', 'Secret Compartment, Small (robot animal)', 'rifts', 'gear', NULL, 1200, '1200 credits each; a lock costs an additional 200 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A secret compartment built into the upper legs or body of a robot horse or dog. A small compartment is half the size of a cigar box, or roughly the size of a videocassette box. TWO small compartments can be installed in place of one large. NOT APPLICABLE TO BOTS WITH FUR. Excellent for holding small valuables, pistols, grenades, flares, an extra canteen and so on. The Bandit K-9 can take two small compartments and no large ones.', 'Rifts World Book 14: New West p.196'),
('secret-compartment-large-robot-animal', 'Secret Compartment, Large (robot animal)', 'rifts', 'gear', NULL, 4000, '4000 credits each; a lock costs an additional 200 credits', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'A secret compartment built into the upper legs and body of a robot horse. The largest possible is approximately 12 inches (0.3 m) long and six inches (0.15 m) deep, and as many as EIGHT large compartments can be installed. NOT APPLICABLE TO BOTS WITH FUR.', 'Rifts World Book 14: New West p.196'),
('chemical-spray-robot-animal', 'Chemical Spray (robot animal)', 'rifts', 'weapon', NULL, 45000, '45,000 credits plus the cost of the chemicals', '4D6 S.D.C. for the typical acid', 0, NULL, 'Double the payload of the cyborg unit', NULL, NULL, NULL, NULL, 'Built into the mouth of a robot horse or Bandit K-9. Basically the same as the cyborg unit - typically an acid, though it can carry other chemicals such as fire-fighting foam - ONLY WITH DOUBLE THE PAYLOAD, and unlike the bionic version it carries a price. A SEPARATE ROW FROM THE BIONIC chemical-spray on purpose: catalog-diff matched the two by alias, and they differ in payload and in whether the book prices them at all.', 'Rifts World Book 14: New West p.196'),
('concealed-weapon-rod-robot-animal-shoulder', 'Concealed Weapon Rod (robot animal shoulder)', 'rifts', 'weapon', NULL, NULL, 'THE BOOK PRINTS NO PRICE OF ITS OWN for the rod; it is priced by whichever weapon is fitted into it - the light laser at 15,000 or the ion blaster at 32,000.', 'Same as the light laser or the ion blaster, depending on which is selected', 1, 'Same as the light laser or the ion blaster, depending on which is selected', NULL, NULL, NULL, NULL, NULL, 'Concealed in the robot animal''s shoulder. Damage and range are the same as the light laser or the ion blaster, depending on which is selected, so the rod is the MOUNTING rather than the gun. Weapon extras are rarely part of the basic package and always cost extra; full price applies even during sales, and all these weapons tend to be small and unobtrusive to avoid obstructing the rider or looking too obvious.', 'Rifts World Book 14: New West p.196'),
('ion-blaster-robot-horse-head', 'Ion Blaster (robot horse head)', 'rifts', 'weapon', NULL, 32000, '32,000 credits each', '3D6 M.D., or 6D6 from a dual system', 1, '800 feet (243.8 m); reduce range by 20% when built into the eyes', 'Effectively unlimited', NULL, NULL, NULL, NULL, 'A head-mounted ion blaster for a robot horse. Typically built into the eyes, which reduces range by 20%, or along the muzzle. AS MANY AS TWO can be installed, one on each side of the muzzle. NOTE: the robot DOG''s ion blaster shares this name and price and is a different weapon - 2D6 M.D. at 600 feet - so it has its own row.', 'Rifts World Book 14: New West p.196'),
('ion-blaster-robot-dog-head', 'Ion Blaster (robot dog head)', 'rifts', 'weapon', NULL, 32000, '32,000 credits each', '2D6 M.D., or 4D6 from a dual system', 1, '600 feet (183 m); reduce range by 20% when built into the eyes', 'Effectively unlimited', NULL, NULL, NULL, NULL, 'A head-mounted ion blaster for a Bandit K-9. Typically built into the eyes or along the muzzle. As many as two can be installed, one on each side of the muzzle or in the eyes. WEAKER AND SHORTER RANGED THAN THE ROBOT HORSE''S at the same price - the book gives both the same name on printed 196 and 200 and different stats.', 'Rifts World Book 14: New West p.200'),
('light-laser-robot-animal-head', 'Light Laser (robot animal head)', 'rifts', 'weapon', NULL, 15000, '15,000 credits each', '1D6 M.D., or 2D6 from a dual system', 1, '1200 feet (366 m); reduce range by 20% when built into the eyes', 'Effectively unlimited', NULL, NULL, NULL, NULL, 'A head-mounted light laser, offered for both the robot horse and the Bandit K-9 with IDENTICAL stats and price on printed 196 and 200 - unlike the ion blaster, which differs between the two. Typically built into the eyes, which reduces range by 20%, or along the muzzle. As many as two can be installed, one on each side of the muzzle or in each eye socket. The cheapest robot animal weapon option that is a gun.', 'Rifts World Book 14: New West p.196 and p.200'),
('heavy-laser-robot-horse-head', 'Heavy Laser (robot horse head)', 'rifts', 'weapon', NULL, 30000, '30,000 credits each', '2D6 M.D., or 4D6 from a dual system', 1, '2000 feet (610 m); reduce range by 20% when built into the eyes', 'Effectively unlimited', NULL, NULL, NULL, NULL, 'A head-mounted heavy laser for a robot horse. Typically built into the eyes, which reduces range by 20%, or along the muzzle. As many as two can be installed, one on each side of the muzzle. Not offered for the Bandit K-9.', 'Rifts World Book 14: New West p.196'),
('double-barrel-heavy-laser-robot-horse-shoulder', 'Double-Barrel Heavy Laser (robot horse shoulder)', 'rifts', 'weapon', NULL, 60000, '60,000 credits', '2D6 M.D. per single shot, or 4D6 per simultaneous double shot', 1, '2000 feet (610 m)', 'Effectively unlimited', NULL, NULL, NULL, NULL, 'A double-barrel unit that can be built into EACH shoulder of a robot horse. They are low profile and can be fixed forward or given an arc of fire of 30 degrees in all directions. The most expensive robot horse weapon option, tied with the mini-missile launchers.', 'Rifts World Book 14: New West p.196'),
('light-machinegun-robot-horse', 'Light Machinegun (robot horse head or shoulders)', 'rifts', 'weapon', NULL, 10000, '10,000 credits', '1D4 M.D. per burst of 50 rounds', 1, '2000 feet (610 m); reduce range by 20% when built into the eyes', '600 rounds, which is 12 bursts', 'Burst of 50 rounds', NULL, NULL, NULL, 'A light machinegun for a robot horse, mounted in the head or the shoulders. Typically built into the eyes, which reduces range by 20%, or along the muzzle; as many as two, one on each side of the muzzle, can be installed, and the feed runs up through the neck. THE CHEAPEST WEAPON OPTION IN THE SECTION, and the only one with a finite payload.', 'Rifts World Book 14: New West p.196'),
('mini-missile-launchers-robot-horse-shoulders', 'Mini-Missile Launchers (robot horse shoulders)', 'rifts', 'weapon', NULL, 60000, '60,000 credits', 'By mini-missile type', 1, 'By mini-missile type', 'Two mini-missiles in each launcher, with MANUAL reloading - which is NOT POSSIBLE WHILE MOVING', 'Each small launcher fires two mini-missiles', NULL, NULL, NULL, 'As many as TWO small, dual system launchers can be added to a robot horse, one on each side. The manual reload is the limitation that decides how they are used: four missiles, and no way to reload at a gallop.', 'Rifts World Book 14: New West p.196');

-- Read the result back rather than trusting the exit code.
SELECT 'the robot animal options' AS assertion, count(*) AS got, 13 AS want
  FROM gear WHERE source_book LIKE '%New West p.196%' OR source_book LIKE '%New West p.200%';

-- The rod is the one entry with no price of its own, and that is deliberate.
SELECT 'exactly one option carries no price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE (source_book LIKE '%New West p.196%' OR source_book LIKE '%New West p.200%')
    AND cost IS NULL;

-- Both Chemical Sprays exist and they are different rows.
SELECT 'both chemical sprays are present' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('chemical-spray', 'chemical-spray-robot-animal');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-new-west-gear-e-robot-animal-options.sql');
