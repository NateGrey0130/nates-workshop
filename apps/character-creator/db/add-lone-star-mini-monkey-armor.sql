-- Rifts World Book 13: Lone Star - the two suits of armor made for Mini Monkey
-- Spies (printed 83). The Mini Monkey Spy class starts with the light one.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-lone-star-mini-monkey-armor.sql
--
-- BOTH ARE NEW. The book prints an M.D.C. figure for each, no weight and no
-- price, and a penalty for the environmental suit only. Read off a 170 dpi
-- render by book-reconcile.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book) VALUES
('mini-monkey-light-armor', 'Mini Monkey Light Armor', 'rifts', 'armor', NULL, NULL, 'No price printed; custom made at Lone Star for its Mini Monkey Spies.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 11, 'Light armor custom made for a Mini Monkey Spy in the style of the Dog Boy riot control suit: 11 M.D.C. The Minis prefer it because it does not restrict or confine them; no penalty is printed for it.', 'Rifts World Book 13: Lone Star p.83'),
('mini-monkey-environmental-armor', 'Mini Monkey Environmental Armor', 'rifts', 'armor', NULL, NULL, 'No price printed; custom made at Lone Star for its Mini Monkey Spies.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 20, 'Full environmental armor custom made for a Mini Monkey Spy: 20 M.D.C. It reduces the wearer''s speed, leaping distance, Prowl, Climbing and Acrobatics by 20%.', 'Rifts World Book 13: Lone Star p.83');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'both Mini Monkey armors are in and cite Lone Star' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('mini-monkey-light-armor', 'mini-monkey-environmental-armor')
   AND source_book = 'Rifts World Book 13: Lone Star p.83';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-lone-star-mini-monkey-armor.sql');
