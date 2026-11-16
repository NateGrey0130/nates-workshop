-- Rifts World Book 34: Northern Gun Two, the separately priced Sea Demon silver platings and Silent Shadow thigh UEL (printed 148 and 151)
-- 3 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~314-northern-gun-2-power-armor-h-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-nx14-sea-demon-bayonet-silver-plating', 'Silver Plating (Sea Demon Cannon Vibro-Bayonet upgrade)', 'rifts', 'gear', NULL, 6000, '6,000 credits, for the Vibro-Bayonet of the Sea Demon power armor''s CDNX114 cannon.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An optional silver plating for the Vibro-Bayonet that extends between the two barrels of the Sea Demon power armor''s big torpedo-and-harpoon cannon, for fighting supernatural enemies.', 'Rifts World Book 34: Northern Gun Two p.148', NULL),
  ('ng-nx14-sea-demon-blade-silver-plating', 'Silver Plating (Sea Demon Vibro-Blade upgrade)', 'rifts', 'gear', NULL, 2000, '2,000 credits, for the Sea Demon power armor''s left forearm Vibro-Blade.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An optional silver plating for the short retractable CD-314 Vibro-Blade in the left forearm of the Sea Demon power armor, for fighting supernatural enemies.', 'Rifts World Book 34: Northern Gun Two p.148', NULL),
  ('ng-uelx49-thigh-uel', 'Extra Thigh UEL (Silent Shadow upgrade)', 'rifts', 'gear', NULL, 160000, '160,000 credits on top of the Silent Shadow power armor''s price.', NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'An extra or emergency Universal Energy Link built into one thigh of the Silent Shadow power armor, beside the standard pair in its forearms: an E-Clip connector on a thin cable that powers a handheld energy weapon of up to 1D6x10 M.D. an attack.', 'Rifts World Book 34: Northern Gun Two p.151', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 3 gear rows are in' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE slug IN ('ng-nx14-sea-demon-bayonet-silver-plating', 'ng-nx14-sea-demon-blade-silver-plating', 'ng-uelx49-thigh-uel') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~314-northern-gun-2-power-armor-h-gear.sql');
