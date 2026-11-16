-- Rifts World Book 34: Northern Gun Two, the separately priced Protege sword plating and Sabre thigh UEL (printed 135 and 140)
-- 2 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~312-northern-gun-2-power-armor-g-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-x209-protege-silver-plating', 'Silver Plating (Protege Vibro-Sword upgrade)', 'rifts', 'gear', NULL, 8000, '8,000 credits, for the Protege power armor''s forearm Vibro-Sword.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An optional silver plating for the broad Vibro-Sword built into the left forearm of the Protege (Sammy Jr.) power armor, for fighting supernatural enemies.', 'Rifts World Book 34: Northern Gun Two p.135', NULL),
  ('ng-uelx42-thigh-uel', 'Extra Thigh UEL (Sabre upgrade)', 'rifts', 'gear', NULL, 160000, '160,000 credits on top of the Sabre power armor''s price.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An extra or emergency Universal Energy Link built into one thigh of the Sabre power armor, beside the standard pair in its forearms: an E-Clip connector on a thin cable that powers a handheld energy weapon of up to 1D6x10 M.D. a blast, its breaker shutting off anything stronger.', 'Rifts World Book 34: Northern Gun Two p.140', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 2 gear rows are in' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('ng-x209-protege-silver-plating', 'ng-uelx42-thigh-uel') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~312-northern-gun-2-power-armor-g-gear.sql');
