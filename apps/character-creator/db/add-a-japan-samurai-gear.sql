-- Rifts World Book 8: Japan - the true samurai's armor and silver-tipped
-- arrows (printed 46-48): 2 new rows, shipped with the classes that grant them
-- (true-samurai, ronin) so neither class needs a stub. See
-- apps/character-creator/docs/surveys/japan.md, step 5.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-a-japan-samurai-gear.sql
--
-- The book prints no price, weight or A.R. for the armor and no damage or
-- price for the arrows; those columns are NULL rather than estimated. It sorts
-- before every class script (add-a-), so a clean rebuild creates the rows first.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('samurai-armor', 'Samurai Armor', 'rifts', 'armor', NULL, NULL, 'No price printed. Made by priests, sorcerers or dragons, inherited, captured from oni or given by the gods; monks sometimes give Millennium Tree bark armor instead.', NULL, 0, NULL, NULL, NULL, NULL, NULL, 100, 'The true samurai''s magic mega-damage armor of lamellar plates, sode shoulder plates, a helmet and a mempo face mask (human, demonic or animal). Typically 100 M.D.C.; a rare suit has as much as 180. Not environmental: no protection from fumes, gas, radiation or disease. No weight or A.R. is printed.', 'Rifts World Book 8: Japan p.46-48'),
('silver-tipped-arrows', 'Silver-Tipped Arrows', 'rifts', 'weapon', NULL, NULL, 'No price printed.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'Arrows with silver tips, six of which are part of the true samurai''s standard kit (printed 48); silver harms many supernatural creatures. The book prints no damage or price for them; a conventional long bow arrow does 2D6 S.D.C. (printed 118).', 'Rifts World Book 8: Japan p.48');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'the 2 rows of add-a-japan-samurai-gear.sql are in' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('samurai-armor', 'silver-tipped-arrows') AND source_book LIKE 'Rifts World Book 8: Japan p.%';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-a-japan-samurai-gear.sql');
