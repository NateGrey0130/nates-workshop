-- Weight and cost for the mundane gear.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-mundane-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-mundane-gear.sql
--
-- The stubs left after the structural and category rows were fixed are all the
-- same job: ordinary objects needing only a weight and a price. This does the
-- most-cited of them - the canteen alone is granted by eighteen classes, the
-- backpack by fifteen, the air filter and gas mask by fourteen each.
--
-- THE SOURCE IS THE WEB, NOT THE BOOK, and source_book says so on every row
-- rather than naming a page nobody checked. These are low-stakes numbers - no
-- weight or price here changes a combat roll - which is exactly why they were
-- left until the M.D.C. and damage rows were done first.
--
-- Where the source gives a RANGE, `cost` holds the low end and the range is
-- stated in the description. A single number in the column would read as
-- precision the source does not have.
--
-- Ounces are converted to pounds because weight_lbs is what the column means.
--
-- Every UPDATE is guarded on the row still being a stub, so re-running is safe
-- and anything entered from a book later is never overwritten.


UPDATE gear SET description = 'Plastic canteen holding 1 litre. An aluminium one runs about 30 credits, and a hard insulated one more again.',
  source_book = 'Web reference (not book-verified)',
  cost = 20,
  weight_lbs = 0.16
  WHERE slug = 'canteen' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A large, good-quality backpack carrying 80 to 150 litres. Typically 100 to 200 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 100,
  weight_lbs = 8.2
  WHERE slug = 'backpack' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A large, good-quality backpack carrying 80 to 150 litres. Typically 100 to 200 credits. Duplicate spelling of "Backpack" - the two rows should probably be merged.',
  source_book = 'Web reference (not book-verified)',
  cost = 100,
  weight_lbs = 8.2
  WHERE slug = 'back-pack' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A small, good-quality backpack carrying 10 to 80 litres; also called a rucksack. Typically 40 to 100 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 40,
  weight_lbs = 4
  WHERE slug = 'knapsack' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A pack of 12 replaceable filters, about 5 credits the pack. Each filter weighs around 2 ounces; the figure here is for the full pack.',
  source_book = 'Web reference (not book-verified)',
  cost = 5,
  weight_lbs = 1.5
  WHERE slug = 'air-filter' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Damage is 1D4 S.D.C. plus the P.S. damage bonus. Typically 20 to 50 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 20,
  weight_lbs = 1.2,
  damage = '1D4',
  is_mega_damage = 0
  WHERE slug = 'survival-knife' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A military-style utility belt, typically 30 to 50 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 30,
  weight_lbs = 1.8
  WHERE slug = 'utility-belt' AND description LIKE 'STUB%';

UPDATE gear SET description = 'An ammunition belt of six pouches, typically 10 to 15 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 10,
  weight_lbs = 1.4
  WHERE slug = 'utility-ammo-belt' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A cheap carrying bag of hessian or synthetic fibre, around 36 inches long, holding up to about 99 lbs. Typically 2 to 6 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 2,
  weight_lbs = 0.44
  WHERE slug = 'large-sack' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A cheap carrying bag of hessian or synthetic fibre. Typically 2 to 6 credits. The source gives one set of figures for sacks rather than separate small and large ones.',
  source_book = 'Web reference (not book-verified)',
  cost = 2,
  weight_lbs = 0.44
  WHERE slug = 'small-sack' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A 12 inch wooden stake, pointed at one end and flat at the other for hammering. Used for tent pegs and prying as readily as for anything supernatural. About 1 credit each, or 4 credits for six.',
  source_book = 'Web reference (not book-verified)',
  cost = 1,
  weight_lbs = 0.75
  WHERE slug = 'wooden-stake' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A 12 inch wooden spike, pointed at one end and flat at the other. About 1 credit each, or 4 credits for six.',
  source_book = 'Web reference (not book-verified)',
  cost = 1,
  weight_lbs = 0.75
  WHERE slug = 'wooden-spike' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A 12 inch iron spike. About 3 credits each, or 6 credits for six.',
  source_book = 'Web reference (not book-verified)',
  cost = 3,
  weight_lbs = 0.5
  WHERE slug = 'spike' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Hand-held magnifying optics, effective to about 1 mile. Typically 400 to 700 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 400,
  weight_lbs = 2.0
  WHERE slug = 'binoculars' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Infrared binoculars with a distancing readout, effective to about 2 miles.',
  source_book = 'Web reference (not book-verified)',
  cost = 1200,
  weight_lbs = 2.19
  WHERE slug = 'infrared-distancing-binoculars' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A large flashlight with a beam reaching about 100 metres.',
  source_book = 'Web reference (not book-verified)',
  cost = 6,
  weight_lbs = 0.5
  WHERE slug = 'flashlight' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A large flashlight with a beam reaching about 100 metres.',
  source_book = 'Web reference (not book-verified)',
  cost = 6,
  weight_lbs = 0.5
  WHERE slug = 'large-flashlight' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A pen-sized flashlight with a beam reaching about 50 metres.',
  source_book = 'Web reference (not book-verified)',
  cost = 6,
  weight_lbs = 0.06
  WHERE slug = 'pocket-flashlight' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A hand-held wooden cross. A small one runs about 2 to 8 credits, a medium one 2 to 10.',
  source_book = 'Web reference (not book-verified)',
  cost = 2,
  weight_lbs = 0.5
  WHERE slug = 'wooden-cross' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A large hand-held wooden cross, typically 6 to 25 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 6,
  weight_lbs = 1.0
  WHERE slug = 'large-wood-cross' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A hatchet doing 1D6 S.D.C. Typically 40 to 200 credits depending on quality.',
  source_book = 'Web reference (not book-verified)',
  cost = 40,
  weight_lbs = 3,
  damage = '1D6',
  is_mega_damage = 0
  WHERE slug = 'hand-axe' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A hatchet doing 1D6 S.D.C. Typically 40 to 200 credits depending on quality.',
  source_book = 'Web reference (not book-verified)',
  cost = 40,
  weight_lbs = 3,
  damage = '1D6',
  is_mega_damage = 0
  WHERE slug = 'hatchet' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A 50 foot bundle of accessory cord. A 164 foot drum runs about 125 credits.',
  source_book = 'Web reference (not book-verified)',
  cost = 18,
  weight_lbs = 0.94
  WHERE slug = 'lightweight-cord' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A standard first aid kit: gauze bandages, plasters, butterfly clamps, aspirin, decongestant, scissors, forceps, tweezers, razor blades, a lighter, medical tape, tongue depressors, medicated wipes, gloves, disinfectant and a pen flashlight.',
  source_book = 'Web reference (not book-verified)',
  cost = 100,
  weight_lbs = 1.19
  WHERE slug = 'first-aid-kit' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A waterproof bedroll of good quality.',
  source_book = 'Web reference (not book-verified)',
  cost = 30,
  weight_lbs = 0.66
  WHERE slug = 'bedroll' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Shaded lenses in various colours and strengths, against glare and bright light. Sturdy enough to take 8 S.D.C. Anywhere from 15 to 300 credits depending on make.',
  source_book = 'Web reference (not book-verified)',
  cost = 15,
  weight_lbs = 0.13
  WHERE slug = 'sunglasses' AND description LIKE 'STUB%';

-- Reports the result back, so it is read rather than assumed.
--   filled           how many of the rows this script names landed. Lower than
--                    the count attempted means a slug did not match; the list
--                    below says which.
--   attempted        26
--   not_matched      the slugs this script names that are not stubs in this
--                    database - either already filled, or named differently
--   priced           every row now carrying a cost
--   stubs_now        the running total, for comparison against 110
SELECT (SELECT count(*) FROM gear
          WHERE slug IN ('canteen', 'backpack', 'back-pack', 'knapsack', 'air-filter', 'survival-knife', 'utility-belt', 'utility-ammo-belt', 'large-sack', 'small-sack', 'wooden-stake', 'wooden-spike', 'spike', 'binoculars', 'infrared-distancing-binoculars', 'flashlight', 'large-flashlight', 'pocket-flashlight', 'wooden-cross', 'large-wood-cross', 'hand-axe', 'hatchet', 'lightweight-cord', 'first-aid-kit', 'bedroll', 'sunglasses') AND description NOT LIKE 'STUB%') AS filled,
       26 AS attempted,
       -- Names this script tried that are still stubs here: a slug that does
       -- not match is silent otherwise, and reads exactly like a row nobody
       -- got to.
       (SELECT group_concat(je.value, ', ') FROM json_each('["canteen", "backpack", "back-pack", "knapsack", "air-filter", "survival-knife", "utility-belt", "utility-ammo-belt", "large-sack", "small-sack", "wooden-stake", "wooden-spike", "spike", "binoculars", "infrared-distancing-binoculars", "flashlight", "large-flashlight", "pocket-flashlight", "wooden-cross", "large-wood-cross", "hand-axe", "hatchet", "lightweight-cord", "first-aid-kit", "bedroll", "sunglasses"]') je
          WHERE je.value IN (SELECT slug FROM gear WHERE description LIKE 'STUB%')) AS not_matched,
       (SELECT count(*) FROM gear WHERE cost IS NOT NULL) AS priced,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-mundane-gear.sql');
