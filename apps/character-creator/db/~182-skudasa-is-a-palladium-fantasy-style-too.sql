-- Hand to Hand: Skudasa is the Gosai Assassin's style in Palladium Fantasy too.
--
-- The row came in with the Rifts conversion (Rifts Conversion Book One
-- p.100-101) and was tagged for Rifts alone. Palladium Fantasy RPG Book 9:
-- The Baalgor Wastelands p.45 prints the same style, level for level, for
-- its own Gosai Assassin R.C.C. (gosai-assassin), so the row serves both
-- games. The figures are not touched: the two printings agree.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~182-skudasa-is-a-palladium-fantasy-style-too.sql
--
-- Guarded on the tag it replaces, so a second run changes nothing.

UPDATE skills
   SET systems = '["rifts","palladium-fantasy"]',
       note = note || ' Also the style of the Palladium Fantasy Gosai Assassin (gosai-assassin), printed in The Baalgor Wastelands p.45.'
 WHERE name = 'Hand to Hand: Skudasa' AND systems = '["rifts"]';

-- Read the result back.
SELECT 'Skudasa is tagged for both games' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Hand to Hand: Skudasa' AND systems = '["rifts","palladium-fantasy"]';
SELECT 'and its note names the Palladium Fantasy class once' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Hand to Hand: Skudasa'
   AND length(note) - length(replace(note, '(gosai-assassin)', '')) = length('(gosai-assassin)');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~182-skudasa-is-a-palladium-fantasy-style-too.sql');
