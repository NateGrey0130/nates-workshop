-- The 27 held gear rows, and the price-range convention they exposed.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- and adds rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-gear-review.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-gear-review.sql
--
-- RUE PRICES MUCH OF ITS COMMON GEAR AS A RANGE. "Belt, Utility (military
-- style): 3-5 cr." The extraction stored one number and did not record that it
-- had chosen; it took the HIGH end 8 times out of 8, while every pre-existing
-- catalog row sits at the LOW end - utility-belt 3 of 3-5, small-mallet 2 of
-- 2-4, survival-knife 120 of 120-300.
--
-- So the low end is the house convention, add-rue-equipment.sql broke it, and
-- section 1 puts those rows back with the full range kept in the description.
--
-- IT ALSO REVERSED THREE OF MY OWN RECOMMENDATIONS. I proposed repricing
-- utility-belt 3->5, survival-knife 120->300 and small-mallet 2->4 because RUE
-- is the later book. It is - and it prints those very numbers as the BOTTOM of
-- a range the catalog already stored. There was nothing to update: the
-- disagreement was an artifact of reading one end of a range as a price.
--
-- Two rows the review caught before they did damage:
--   Canteen: 2 M.D.C. at 2200 is NOT the plastic canteen at 20. `canteen` is
--   cited by 24 classes, and repricing it would have made every character's
--   canteen a mega-damage container.
--   Spikes (6, iron) at 6 cr. is SIX spikes; the catalog's `spike` at 3 is one.
--   A unit mismatch, not a price disagreement.
--
-- The Dead Boy stub resolves to CA-2 Light, the standard Coalition issue, which
-- is what the Technical Officer's equipment list means.


-- ===== 1. Price ranges put back to the low end =====

UPDATE gear SET cost = 60,
       description = coalesce(nullif(description, ''), '') || ' Book price 60-100 cr.'
 WHERE slug = 'bicycle-basic' AND cost = 100;

UPDATE gear SET cost = 2,
       description = coalesce(nullif(description, ''), '') || ' Book price 2-6 cr.'
 WHERE slug = 'cigarettes-16-in-a-pack' AND cost = 6;

UPDATE gear SET cost = 80,
       description = coalesce(nullif(description, ''), '') || ' Book price 80-150 cr.'
 WHERE slug = 'cross-crucifix-silver-4-6-inches' AND cost = 150;

UPDATE gear SET cost = 25,
       description = coalesce(nullif(description, ''), '') || ' Book price 25-80 cr.'
 WHERE slug = 'duffle-bag' AND cost = 80;

UPDATE gear SET cost = 80,
       description = coalesce(nullif(description, ''), '') || ' Book price 80-200 cr.'
 WHERE slug = 'knife-skinning' AND cost = 200;

UPDATE gear SET cost = 200,
       description = coalesce(nullif(description, ''), '') || ' Book price 200-600 cr.'
 WHERE slug = 'knife-throwing' AND cost = 600;

UPDATE gear SET cost = 2,
       description = coalesce(nullif(description, ''), '') || ' Book price 2-5 cr.'
 WHERE slug = 'pocket-or-signal-mirror' AND cost = 5;

UPDATE gear SET cost = 8,
       description = coalesce(nullif(description, ''), '') || ' Book price 8-12 cr.'
 WHERE slug = 'sketch-book-100-sheets-hardcover' AND cost = 12;


-- ===== 2. Stubs the equipment chapter can fill =====
-- Guarded on the STUB marker: a row somebody has since filled in by hand
-- must not be overwritten by a book price.

UPDATE gear SET cost = 10, description = '10-15 cr. Belt with six pouches, military style.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'ammo-belt' AND description LIKE 'STUB%';

UPDATE gear SET cost = 12, description = '12 cr. per box.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'disposable-surgical-gloves' AND description LIKE 'STUB%';

UPDATE gear SET cost = 5, description = '5 cr.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'mechanical-pencil' AND description LIKE 'STUB%';

UPDATE gear SET cost = 2400, description = '2400 cr. Pocket digital disc audio player and recorder.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'pdd-pocket-audio-digital-disc-recorder-player' AND description LIKE 'STUB%';


-- ===== 3. Items the book distinguishes and a class list flattened =====
-- New rows BESIDE the existing one rather than replacing it: the catalog's
-- `knife` and `backpack` are what every class citing them still means.

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('backpack-large', 'Backpack, large, high quality', 'gear', 200, '200 cr.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('flashlight-large', 'Flashlight, large', 'gear', 20, '20 cr.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('gas-mask-human-size', 'Gas Mask (human-size)', 'gear', 80, '80 cr.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('gas-mask-oversized', 'Gas Mask (larger than human)', 'gear', 120, '120 cr.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('sunglasses-light-adjusting', 'Sunglasses (fancy or light adjusting)', 'gear', 300, '300 cr.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('knife-large', 'Knife, Large', 'weapon', 20, '20-100 cr. Does 1D6 S.D.C.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('knife-small', 'Knife, Small', 'weapon', 15, '15-75 cr. Does 1D4 S.D.C.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('dead-boy-armor-ca-1-heavy', '"Dead Boy" Body Armor CA-1 (Heavy)', 'armor', NULL, 'Coalition heavy body armour, old style.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('dead-boy-armor-ca-2-light', '"Dead Boy" Body Armor CA-2 (Light)', 'armor', NULL, 'Coalition light body armour, old style. Standard CS issue.', 'rifts', 'Rifts Ultimate Edition p.261-270');

INSERT OR IGNORE INTO gear (slug, name, category, cost, description, system, source_book)
VALUES ('dead-boy-armor-black-market', '"Dead Boy" Body Armor (Black Market)', 'armor', 45000, 'Black market price for Coalition Dead Boy armour.', 'rifts', 'Rifts Ultimate Edition p.261-270');


-- ===== 4. The Dead Boy stub resolves to CA-2 Light =====
-- Three real armours collapse onto one stub the Coalition Technical Officer
-- cites. CA-2 Light is standard Coalition issue, so that is what the class
-- means; the redirect keeps the class markdown resolving without editing it.
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'dead-boy-body-armor', id, 'merge' FROM gear WHERE slug = 'dead-boy-armor-ca-2-light';

UPDATE gear
   SET description = 'Superseded by the three armours RUE prints separately; resolves to '
                     || 'dead-boy-armor-ca-2-light, the standard Coalition issue.'
 WHERE slug = 'dead-boy-body-armor' AND description LIKE 'STUB%';


-- ===== Read the result back rather than trusting the exit code =====
SELECT count(*) AS still_high_end FROM gear
 WHERE slug IN ('bicycle-basic', 'cigarettes-16-in-a-pack', 'cross-crucifix-silver-4-6-inches', 'duffle-bag', 'knife-skinning', 'knife-throwing', 'pocket-or-signal-mirror', 'sketch-book-100-sheets-hardcover')
   AND cost NOT IN (60, 2, 80, 25, 80, 200, 2, 8);
SELECT count(*) AS stubs_filled FROM gear
 WHERE slug IN ('ammo-belt', 'disposable-surgical-gloves', 'mechanical-pencil', 'pdd-pocket-audio-digital-disc-recorder-player') AND description NOT LIKE 'STUB%';
SELECT count(*) AS variants_present FROM gear
 WHERE slug IN ('backpack-large', 'flashlight-large', 'gas-mask-human-size', 'gas-mask-oversized', 'sunglasses-light-adjusting', 'knife-large', 'knife-small', 'dead-boy-armor-ca-1-heavy', 'dead-boy-armor-ca-2-light', 'dead-boy-armor-black-market');
SELECT count(*) AS dead_boy_redirect FROM catalog_redirects
 WHERE catalog = 'gear' AND from_key = 'dead-boy-body-armor';

INSERT INTO data_script_runs (filename) VALUES ('fix-rue-gear-review.sql');
