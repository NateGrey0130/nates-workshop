-- The last of the gear the web can settle, and a correction.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-final-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-final-gear.sql
--
-- Four more mundane rows have prices. THE SOURCE IS THE WEB, NOT THE BOOK, and
-- source_book says so on each.
--
-- This is the end of what the open web can settle. What remains is recorded in
-- the README rather than left looking like work nobody got to: roughly a dozen
-- pieces of named hardware whose stats are only in books, four rows that name a
-- CATEGORY rather than an item and cannot become choices because the catalog
-- holds no options to offer, and a long tail of ordinary objects - clothing,
-- rations, mirrors, gloves, sleeping bags - that no reachable source prices.


UPDATE gear SET description = 'A survival flare, burning for about 20 minutes.',
  source_book = 'Web reference (not book-verified)',
  cost = 1,
  weight_lbs = 0.38
  WHERE slug = 'flare' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A survival flare, burning for about 20 minutes. Same item as the plain Flare row; the two should probably be merged.',
  source_book = 'Web reference (not book-verified)',
  cost = 1,
  weight_lbs = 0.38
  WHERE slug = 'signal-flare' AND description LIKE 'STUB%';

UPDATE gear SET description = 'Polarized goggles that lighten and darken with the ambient light, against glare and sudden brightness. Typically 75 to 100 credits; a high-impact version runs about 1,200.',
  source_book = 'Web reference (not book-verified)',
  cost = 75,
  weight_lbs = 0.13
  WHERE slug = 'tinted-goggles' AND description LIKE 'STUB%';

UPDATE gear SET description = 'A utility knife doing 1D4 S.D.C. plus the P.S. damage bonus. Typically 100 to 300 credits depending on quality.',
  source_book = 'Web reference (not book-verified)',
  cost = 100,
  weight_lbs = 0.22,
  damage = '1D4',
  is_mega_damage = 0
  WHERE slug = 'knife' AND description LIKE 'STUB%';

-- A CORRECTION to fix-category-gear-rows.sql. That script turned the
-- Cyber-Knight's invented "NS Turbo Cyclone" into a transportation choice and
-- justified offering only powered vehicles on the grounds that "no horses exist
-- in the catalog yet". That was wrong: `riding-horse` was there the whole time,
-- and was missed by looking only at rows whose category is 'vehicle'.
--
-- The book grants the Cyber-Knight a horse, robot horse, bionic horse, hover
-- cycle or modified motorcycle. A choice option only has to EXIST in the
-- catalog, not to carry stats - every option that script created was a stub at
-- the time it was written - so the horse belongs in the list.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { choose: 1, label: "transportation", qty: 1, from: ["a-t-v-speedster-hover-cycle", "the-highway-man-motorcycle", "the-wastelander-motorcycle"] }',
      '  - { choose: 1, label: "transportation", qty: 1, from: ["riding-horse", "a-t-v-speedster-hover-cycle", "the-highway-man-motorcycle", "the-wastelander-motorcycle"] }'),
    updated_at = datetime('now')
WHERE class_id = 'cyber-knight'
  AND instr(markdown, 'label: "transportation"') > 0
  AND instr(markdown, '"riding-horse"') = 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'riding-horse');

-- Reports the result back, so it is read rather than assumed.
--   filled            4 = the four rows this script prices
--   horse_offered     1 = the Cyber-Knight can take a horse again
--   transport_options 4 = horse, hover cycle, two motorcycles
--   stubs_now         the running total, for comparison against 82
SELECT (SELECT count(*) FROM gear
          WHERE slug IN ('flare', 'signal-flare', 'tinted-goggles', 'knife')
            AND description NOT LIKE 'STUB%%') AS filled,
       (SELECT count(*) FROM imported_classes
          WHERE class_id = 'cyber-knight' AND instr(markdown, '"riding-horse"') > 0) AS horse_offered,
       -- Counted by asking whether each expected slug is present, rather than
       -- by slicing the list out of the markdown. The first version did the
       -- latter with substring arithmetic and produced malformed JSON: a
       -- verification query has no business being harder to get right than the
       -- change it verifies.
       (SELECT (instr(markdown, '"riding-horse"') > 0)
             + (instr(markdown, '"a-t-v-speedster-hover-cycle"') > 0)
             + (instr(markdown, '"the-highway-man-motorcycle"') > 0)
             + (instr(markdown, '"the-wastelander-motorcycle"') > 0)
          FROM imported_classes WHERE class_id = 'cyber-knight') AS transport_options,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-final-gear.sql');
