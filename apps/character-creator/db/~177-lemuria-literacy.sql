-- Rifts World Book 32: Lemuria - Literacy: Lemurian, which its classes grant by name
-- 1 skills row.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~177-lemuria-literacy.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO skills (name, category, base, base_formula, per_level, systems, source, source_book, note, bonuses, level_bonuses) VALUES
  ('Literacy: Lemurian', 'Communications', 30, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 32: Lemuria p.50', 'Reading and writing Lemurian. The book prints no base figure for learning it; 30/5 is the catalog''s figure for a literacy. Every Lemurian has it at 85% +1% per level (p.50), and the classes that grant it print their own figure.', NULL, NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 skills rows are in' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name IN ('Literacy: Lemurian') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~177-lemuria-literacy.sql');
