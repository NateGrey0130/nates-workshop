-- Prices for the gear nothing publishes a price for.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/estimate-mundane-gear-prices.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/estimate-mundane-gear-prices.sql
--
-- THESE NUMBERS ARE INVENTED, and source_book says so in those words:
--
--     Estimate - no published price found
--
-- A THIRD provenance tier, below "Rifts Ultimate Edition p.261-265" and below
-- "Web reference (not book-verified)". Grep for it to find every value in this
-- catalog that no source stands behind.
--
-- Why invent anything at all. The equipment chapter (p.261-274) covers gear,
-- communications, medical, optics, sensors, vehicles, energy weapons and power
-- armour, and prices NONE of these: there is no clothing entry in the
-- alphabetical Basic Gear list, which runs straight from Cigarettes to Compass
-- to Cross/Crucifix, and no food anywhere in the chapter. The open web has no
-- Rifts clothing prices either, and what it does offer for Palladium Fantasy is
-- either a generic fantasy compilation in gold that only "references Palladium
-- as a baseline", or pages that declare themselves fan-made. A stub with no
-- price cannot be bought at a table; a marked estimate can, and can be
-- corrected the moment a real page turns up.
--
-- WHAT IS DELIBERATELY NOT ESTIMATED, and why. Nothing here changes a roll.
-- Every remaining stub that WOULD - a weapon's damage, an armour's M.D.C., the
-- Juicer's drug harness, the Techno-Wizard weapons, the grenades - is left
-- alone, because a guessed combat number is indistinguishable from a real one
-- once it is in the table, and it decides fights.
--
-- The four category rows (submachine-gun, musical-instrument, basic-provisions,
-- lesser-rune-weapon) are also untouched: they are not items and a price would
-- not make them into items.
--
-- Anchored to the book's own scale where there is one - a bedroll is 30
-- credits, a heavy blanket 20, a small backpack 40-100, a duffle bag 25-80 - so
-- these sit beside published values without looking odd.
--
-- WEIGHT IS LEFT NULL throughout. Cost at least has the book's scale to anchor
-- to; a weight would be invention with nothing behind it, and encumbrance is
-- the one thing it would quietly affect.
--
-- Every UPDATE is guarded on the row still being a stub, so a real price from a
-- book later is never overwritten by a guess.

-- -- Named in the book after all --
-- Found on a re-read of p.262: "Hammer (average, metal): 10-20 cr." This one is
-- NOT an estimate and does not carry the estimate marker.

UPDATE gear SET description = 'An average metal hammer, 10 to 20 credits, doing 1D6 S.D.C. if swung in anger.',
  source_book = 'Rifts Ultimate Edition p.261-265',
  cost = 10, weight_lbs = 1,
  damage = '1D6', is_mega_damage = 0
  WHERE slug = 'small-hammer' AND description LIKE 'STUB%';

-- -- Clothing and things worn --

UPDATE gear SET description = 'A basic set of everyday clothing.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'clothing' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Hard-wearing clothing for the road.',
  source_book = 'Estimate - no published price found', cost = 40
  WHERE slug = 'traveling-clothes' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Hand-made leather clothing.',
  source_book = 'Estimate - no published price found', cost = 60
  WHERE slug = 'buckskin-clothing' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Insulated clothing for cold country.',
  source_book = 'Estimate - no published price found', cost = 90
  WHERE slug = 'cold-weather-clothing' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Camouflage-pattern military fatigues.',
  source_book = 'Estimate - no published price found', cost = 50
  WHERE slug = 'camouflage-fatigues' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Military fatigues.',
  source_book = 'Estimate - no published price found', cost = 40
  WHERE slug = 'fatigues' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Grey military fatigues.',
  source_book = 'Estimate - no published price found', cost = 40
  WHERE slug = 'grey-fatigues' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A service uniform.',
  source_book = 'Estimate - no published price found', cost = 60
  WHERE slug = 'uniform' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A formal dress uniform.',
  source_book = 'Estimate - no published price found', cost = 120
  WHERE slug = 'dress-uniform' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Hard-wearing work overalls.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'work-overalls' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A flight jumpsuit.',
  source_book = 'Estimate - no published price found', cost = 80
  WHERE slug = 'pilot-jumpsuit' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Military combat boots.',
  source_book = 'Estimate - no published price found', cost = 50
  WHERE slug = 'combat-boots' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Boots with velcro straps rather than laces.',
  source_book = 'Estimate - no published price found', cost = 45
  WHERE slug = 'velcro-strapped-boots' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Boots with an integral sheath for a knife.',
  source_book = 'Estimate - no published price found', cost = 60
  WHERE slug = 'boots-with-knife-holster' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A plain pair of gloves.',
  source_book = 'Estimate - no published price found', cost = 15
  WHERE slug = 'gloves' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Soft deerskin gloves.',
  source_book = 'Estimate - no published price found', cost = 25
  WHERE slug = 'deerskin-gloves' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A shoulder cape.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'cape' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A plain robe.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'robe' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A robe with a hood.',
  source_book = 'Estimate - no published price found', cost = 40
  WHERE slug = 'hooded-robe' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A cloak with a hood.',
  source_book = 'Estimate - no published price found', cost = 40
  WHERE slug = 'hooded-cloak' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A robe kept for ceremony rather than travel.',
  source_book = 'Estimate - no published price found', cost = 100
  WHERE slug = 'ceremonial-robe' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A small carried purse or satchel.',
  source_book = 'Estimate - no published price found', cost = 20
  WHERE slug = 'purse-satchel' AND description LIKE 'STUB%';

-- -- Sundries and consumables --

UPDATE gear SET description = 'About a week of preserved field rations.',
  source_book = 'Estimate - no published price found', cost = 20
  WHERE slug = 'food-rations' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Salt, for preserving food as much as seasoning it.',
  source_book = 'Estimate - no published price found', cost = 5
  WHERE slug = 'salt' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A few cloves of garlic.',
  source_book = 'Estimate - no published price found', cost = 2
  WHERE slug = 'garlic-cloves' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A striking flint.',
  source_book = 'Estimate - no published price found', cost = 5
  WHERE slug = 'flint' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Charcoal, for drawing or for a fire.',
  source_book = 'Estimate - no published price found', cost = 3
  WHERE slug = 'charcoal' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A wire snare for taking small game.',
  source_book = 'Estimate - no published price found', cost = 15
  WHERE slug = 'animal-snare' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A compact kit of hand tools.',
  source_book = 'Estimate - no published price found', cost = 100
  WHERE slug = 'mini-tool-kit' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A belt or shoulder holster.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'gun-holster' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A conventional ammunition clip. NOT an E-Clip - those are a separate row at 5,000 credits.',
  source_book = 'Estimate - no published price found', cost = 20
  WHERE slug = 'ammunition-clips' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A trained riding horse.',
  source_book = 'Estimate - no published price found', cost = 1000
  WHERE slug = 'riding-horse' AND description LIKE 'STUB%';

-- -- Symbols and ceremony --

UPDATE gear SET description = 'A worn or carried symbol of a faith.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'holy-symbol' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A symbol of one of the elemental forces.',
  source_book = 'Estimate - no published price found', cost = 30
  WHERE slug = 'elemental-symbol' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A silver chalice for ceremony.',
  source_book = 'Estimate - no published price found', cost = 150
  WHERE slug = 'silver-chalice' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A single vial of consecrated water.',
  source_book = 'Estimate - no published price found', cost = 50
  WHERE slug = 'vial-of-holy-water' AND description LIKE 'STUB%';

-- Reports the result back, so it is read rather than assumed.
--   estimated        rows now carrying the estimate marker
--   book_hammer      10 = the one that turned out to be in the book
--   stubs_now        the running total, for comparison against 56
--   mechanical_left  the stubs deliberately untouched - weapons, armour and the
--                    two Juicer devices, whose numbers decide fights
--   categories_left  4 = rows that name a category, which no price would fix
SELECT (SELECT count(*) FROM gear WHERE source_book = 'Estimate - no published price found') AS estimated,
       (SELECT cost FROM gear WHERE slug = 'small-hammer') AS book_hammer,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stubs_now,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%'
          AND slug NOT IN ('submachine-gun', 'musical-instrument',
                           'basic-provisions', 'lesser-rune-weapon')) AS mechanical_left,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%'
          AND slug IN ('submachine-gun', 'musical-instrument',
                       'basic-provisions', 'lesser-rune-weapon')) AS categories_left;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('estimate-mundane-gear-prices.sql');
