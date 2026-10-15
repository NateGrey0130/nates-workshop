-- BOOK-INGEST-AUDIT F139: gear rows pointing at the four Bandito Arms robot horses
-- 4 gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~203-book-ingest-audit-f139-robot-horse-pointers.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, mdc, description, source_book, vehicle_slug) VALUES
  ('rh-1001a-appaloosa-light-robot-horse', 'Bandito Arms Appaloosa, Light Robot Horse', 'rifts', 'vehicle', 800, 2500000, '2.5 million credits; sometimes on sale for 10-20% less. The deluxe armored model adds 30% to all M.D.C. and 30% to the cost.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 200, 'Bandito Arms'' light robot horse, model RH-1001A. A robot horse is a start-of-play mount for the Adna Nomad (with a Horsemanship skill) and the Cyber-Samurai, neither of which names a model. Its M.D.C., speeds and abilities are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 14: New West p.196-197', 'rh-1001a-appaloosa-light-robot-horse'),
  ('rh-1002b-mustang-medium-robot-horse', 'Bandito Arms Medium Robot Horse (Mustang or Pinto)', 'rifts', 'vehicle', 1200, 5200000, '5.2 million credits; sometimes on sale for 10-20% less. The deluxe armored model adds 30% to all M.D.C. and 30% to the cost.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 250, 'Bandito Arms'' medium robot horse, model RH-1002B. A robot horse is a start-of-play mount for the Adna Nomad (with a Horsemanship skill) and the Cyber-Samurai, neither of which names a model. Its M.D.C., speeds and abilities are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 14: New West p.197-198', 'rh-1002b-mustang-medium-robot-horse'),
  ('rh-1003c-arabian-robot-horse', 'Bandito Arms Arabian Robot Horse', 'rifts', 'vehicle', 1400, 6000000, '6 million credits; sometimes on sale for 10-20% less. The deluxe armored model adds 30% to all M.D.C. and 30% to the cost.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 240, 'Bandito Arms'' Arabian robot horse, model RH-1003C. A robot horse is a start-of-play mount for the Adna Nomad (with a Horsemanship skill) and the Cyber-Samurai, neither of which names a model. Its M.D.C., speeds and abilities are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 14: New West p.198-199', 'rh-1003c-arabian-robot-horse'),
  ('rh-1004d-war-horse-heavy-robot-horse', 'Bandito Arms Heavy Robot Horse (The War Horse)', 'rifts', 'vehicle', 2000, 6100000, '6.1 million credits; sometimes on sale for 10-20% less. The deluxe armored model adds 30% to all M.D.C. and 30% to the cost.', NULL, 1, NULL, NULL, NULL, NULL, NULL, 350, 'Bandito Arms'' heavy robot horse, model RH-1004D. A robot horse is a start-of-play mount for the Adna Nomad (with a Horsemanship skill) and the Cyber-Samurai, neither of which names a model. Its M.D.C., speeds and abilities are the vessel of the same slug; this row exists so a class can list it in its starting equipment.', 'Rifts World Book 14: New West p.199-200', 'rh-1004d-war-horse-heavy-robot-horse');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 4 gear rows are in' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE slug IN ('rh-1001a-appaloosa-light-robot-horse', 'rh-1002b-mustang-medium-robot-horse', 'rh-1003c-arabian-robot-horse', 'rh-1004d-war-horse-heavy-robot-horse') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~203-book-ingest-audit-f139-robot-horse-pointers.sql');
