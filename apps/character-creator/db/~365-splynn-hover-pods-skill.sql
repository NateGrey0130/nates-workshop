-- Splynn Dimensional Market: the skill Pilot: Hover Pod (printed 184 and 187).
-- 1 skills row.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~365-splynn-hover-pods-skill.sql
--
-- Written by scripts/rows-sql.mjs from 1 worker file(s). Every value is
-- printable ASCII and every row cites its book. Rows are keyed on their
-- portable identity, never an id; a row already held is left as it is.

INSERT OR IGNORE INTO skills (name, category, base, base_formula, per_level, systems, source, source_book, note, bonuses, level_bonuses) VALUES
  ('Pilot: Hover Pod', 'Pilot', 50, NULL, 5, '["rifts"]', 'import', 'Rifts World Book 21: Splynn Dimensional Market p.184, 187', 'Flying the Kittani Hover Pods (Speed Pod, War Pod). A pilot using Hover Craft (the book''s Pilot Hover Vehicle/Craft) in a pod instead is -15% to piloting and trick maneuver rolls; a pilot with this skill is -10% flying ordinary hover vehicles. At or below cruising speed a pod''s stunt and maneuver penalties shrink only for a pilot with this skill: halved in the Speed Pod, 20% less in the War Pod. Every Kittani has it.', NULL, NULL);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 skills rows are in' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name IN ('Pilot: Hover Pod') AND source_book IS NOT NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~365-splynn-hover-pods-skill.sql');
