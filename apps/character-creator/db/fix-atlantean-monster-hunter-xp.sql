-- The Atlantean Monster Hunter (Rifts World Book 6: South America printed
-- 99-101) gets the Undead Slayer's experience ladder, which its book names
-- ("same as the Undead Slayer", WB6 printed 168) and which Rifts World Book 2:
-- Atlantis prints on printed 68. See apps/character-creator/docs/surveys/atlantis.md.
--
-- One-off data script, run once per environment.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-atlantean-monster-hunter-xp.sql
--
-- WHY NOW. The class was imported without one because Atlantis was not cached
-- (south-america.md, ladders). The Undead Slayer ships in the same PR as this
-- file, with the same ladder, read off a render of Atlantis printed 68 and
-- stored as each band's LOWER bound:
--   0, 2501, 5501, 10501, 21501, 32001, 47001, 65001, 87001, 115001, 170001,
--   220001, 300001, 400001, 500001
--
-- MECHANICS. One xp_table line after the class's single "category: occ" line,
-- guarded on the class having no xp_table, and the extraction note that asked
-- for this is rewritten to say it was done. A re-run does nothing. The name
-- sorts after add-atlantean-monster-hunter-class.sql, the only script that
-- writes those two lines.

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2501, 5501, 10501, 21501, 32001, 47001, 65001, 87001, 115001, 170001, 220001, 300001, 400001, 500001]' || char(10)), updated_at = datetime('now') WHERE class_id = 'atlantean-monster-hunter' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'No Undead Slayer or other Tattooed Man class exists in the catalog, so xp_table is omitted; supply the Undead Slayer''s ladder (Rifts Atlantis) when that class is imported.', 'The class was imported without one; fix-atlantean-monster-hunter-xp.sql then gave it the Undead Slayer''s ladder from Rifts World Book 2: Atlantis printed 68, which undead-slayer stores too.'), updated_at = datetime('now') WHERE class_id = 'atlantean-monster-hunter' AND instr(markdown, 'supply the Undead Slayer''s ladder (Rifts Atlantis) when that class is imported.') > 0;

-- Read the result back.
SELECT 'the Monster Hunter carries the Undead Slayer ladder' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'atlantean-monster-hunter'
   AND instr(markdown, 'xp_table: [0, 2501, 5501, 10501, 21501, 32001, 47001, 65001, 87001, 115001, 170001, 220001, 300001, 400001, 500001]') > 0;
SELECT 'and its note no longer asks for it' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'atlantean-monster-hunter'
   AND instr(markdown, 'when that class is imported.') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-atlantean-monster-hunter-xp.sql');
