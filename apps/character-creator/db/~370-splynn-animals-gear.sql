-- Rifts World Book 21: Splynn Dimensional Market - the three Kryygorth Shellback armors (printed 80).
-- 3 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~370-splynn-animals-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('kryygorth-shellback-armor-light', 'Kryygorth Shellback Armor, Light', 'rifts', 'armor', NULL, 30000, 'About 30,000 credits as printed; -20% (24,000) for a non-environmental suit, +10% (33,000) for an environmental one', NULL, 0, NULL, NULL, NULL, NULL, NULL, 40, 'Body armor cut from the shell of the Kryygorth Shellback, the Splugorth''s armored livestock, sold in Splynn''s shops. The light suit has 40-50 M.D.C. (the low end is stored). It is cheap for M.D.C. armor because shell is plentiful in the Splugorth markets. It comes in two kinds: a non-environmental suit at 20% under the listed price, and an environmental one at 10% over it.', 'Rifts World Book 21: Splynn Dimensional Market p.80', NULL),
  ('kryygorth-shellback-armor-medium', 'Kryygorth Shellback Armor, Medium', 'rifts', 'armor', NULL, 50000, '50,000 credits as printed; -20% (40,000) for a non-environmental suit, +10% (55,000) for an environmental one', NULL, 0, NULL, NULL, NULL, NULL, NULL, 60, 'Body armor cut from the shell of the Kryygorth Shellback, the Splugorth''s armored livestock, sold in Splynn''s shops. The medium suit has 60-80 M.D.C. (the low end is stored). It is cheap for M.D.C. armor because shell is plentiful in the Splugorth markets. It comes in two kinds: a non-environmental suit at 20% under the listed price, and an environmental one at 10% over it.', 'Rifts World Book 21: Splynn Dimensional Market p.80', NULL),
  ('kryygorth-shellback-armor-heavy', 'Kryygorth Shellback Armor, Heavy', 'rifts', 'armor', NULL, 75000, '75,000 credits as printed; -20% (60,000) for a non-environmental suit, +10% (82,500) for an environmental one', NULL, 0, NULL, NULL, NULL, NULL, NULL, 90, 'Body armor cut from the shell of the Kryygorth Shellback, the Splugorth''s armored livestock, sold in Splynn''s shops. The heavy suit has 90-120 M.D.C. (the low end is stored). It is cheap for M.D.C. armor because shell is plentiful in the Splugorth markets. It comes in two kinds: a non-environmental suit at 20% under the listed price, and an environmental one at 10% over it.', 'Rifts World Book 21: Splynn Dimensional Market p.80', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 3 gear rows are in' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE slug IN ('kryygorth-shellback-armor-light', 'kryygorth-shellback-armor-medium', 'kryygorth-shellback-armor-heavy') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~370-splynn-animals-gear.sql');
