-- Rifts World Book 34: Northern Gun Two, the Beach-Stormer's two separately priced weapons (printed 66-67)
-- 2 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~300-northern-gun-2-power-armor-a-gear.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('ng-p67-particle-beam-short-gun', 'NG-P67 Particle Beam Short-Gun', 'rifts', 'weapon', 16, 25600, 'Sold separately from the Beach-Stormer power armor, which comes with one.', '6D6 M.D. per shot', 1, '1,000 feet (305 m) in air; 700 feet (213 m) underwater', '10 shots per standard E-Clip; on a Beach-Stormer it can draw from the suit''s battery, each 30 shots costing one hour of operating time', 'Each blast counts as one melee attack', NULL, NULL, NULL, 'An underwater variant of the NG-P7 particle beam rifle, made for the Beach-Stormer power armor. Shorter than the rifle but still big and heavy: -2 to strike for anyone with a human P.S. under 26 and no Robotic or Supernatural Strength. An ordinary particle beam weapon fired underwater has half its range and damage.', 'Rifts World Book 34: Northern Gun Two p.66', NULL),
  ('ng-m100-multi-weapon-underwater-rifle', 'NG-M100 Multi-Weapon Underwater Rifle', 'rifts', 'weapon', 20, 34000, 'Includes the rifle and one grenade or micro-torpedo magazine. Extra magazines, explosives included, 5,000 credits each.', 'Ion blaster 4D6 M.D.; grenades 4D6 M.D. each; micro-torpedoes 5D6 M.D. each; grenades and torpedoes are armor piercing with a 3 foot (0.9 m) blast radius', 1, 'Ion blaster 800 feet (244 m); grenades or micro-torpedoes 1,400 feet (427 m)', 'Ion blaster 10 shots per standard E-Clip; 20 grenades or micro-torpedoes per magazine', 'Each blast counts as one melee attack', NULL, NULL, NULL, 'The Beach-Stormer power armor''s standard rifle: a short ion blaster that works in or out of water, mounted over a semi-automatic launcher derived from Wellington''s WI-23. Swapping its top-fed box magazine switches it between grenades and micro-torpedoes; rounds leave on compressed air and the torpedo motor lights about 5 feet (1.5 m) out. A loaded magazine is 12 lbs (5.4 kg).', 'Rifts World Book 34: Northern Gun Two p.66-67', NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 2 gear rows are in' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE slug IN ('ng-p67-particle-beam-short-gun', 'ng-m100-multi-weapon-underwater-rifle') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~300-northern-gun-2-power-armor-a-gear.sql');
