-- BOOK-INGEST-AUDIT F138 residue: the Summoner's Deciphering Circles skill gets a catalog row (Palladium Fantasy printed 135)
-- 1 skills row.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~271-book-ingest-audit-f138-summoner-skill.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO skills (name, category, base, base_formula, per_level, systems, source, source_book, note, bonuses, level_bonuses) VALUES
  ('Deciphering Circles', 'Technical', 20, NULL, 4, '["palladium-fantasy"]', 'import', 'Palladium Fantasy RPG Main Book p.135', 'The Summoner''s O.C.C. skill for working out a found magic circle; rolled only after the circle is drawn and invoked, with a failure rolled on the Incorrect Circle Invocation table (p.136).', NULL, NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 skills rows are in' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name IN ('Deciphering Circles') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~271-book-ingest-audit-f138-summoner-skill.sql');
