-- Rifts World Book 34: Northern Gun Two, the separately priced Med-Rec White Knight replacement marker (printed 119-122)
-- 1 gear row.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~308-northern-gun-2-power-armor-e-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-mru876-med-evac-marker', 'Electronic Med-EVAC Marker (White Knight)', 'rifts', 'gear', NULL, 200, '200 credits each as a replacement; twelve come with every Med-Rec White Knight power armor.', NULL, 0, 'Transmits one mile (1.6 km)', '240 hours (10 days) of transmission', NULL, NULL, NULL, NULL, 'A casualty tag for rescue work: a small red beacon marked with a white cross, about half a credit card in size and three times as thick, with a wire clip for fastening to clothing or a stretcher. Medics tag the worst hurt so teammates can home in on its ping and evacuate or treat them first, and in a pinch it marks a path to survivors or to the rescuer himself. Its tone and frequency differ from the Forester''s trail markers and sit on bands allied rescuers are likely to monitor; anyone with Paramedic or military or rescue training knows it on hearing it.', 'Rifts World Book 34: Northern Gun Two p.119 and 122', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 gear rows are in' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug IN ('ng-mru876-med-evac-marker') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~308-northern-gun-2-power-armor-e-gear.sql');
