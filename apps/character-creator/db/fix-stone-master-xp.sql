-- The Stone Master (imported from the Rifts Book of Magic reprint, printed
-- 223-228) gets the experience ladder Rifts World Book 2: Atlantis prints for
-- it on printed 68. See apps/character-creator/docs/surveys/atlantis.md.
--
-- One-off data script, run once per environment.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-stone-master-xp.sql
--
-- WHY NOW. The class was imported without one. The Erta R.C.C. (Atlantis
-- printed 71) is printed as using "the same experience table as the stone
-- master", and ships in the same PR as this file with the same ladder. Read
-- off a render of printed 68 and confirmed by book-reconcile, stored as each
-- band's LOWER bound:
--   0, 2401, 4801, 9601, 19201, 28401, 38601, 52201, 72401, 98601, 140201,
--   200401, 260601, 310201, 410401
--
-- MECHANICS. One xp_table line after the class's single "category: occ" line,
-- guarded on the class having no xp_table, so a re-run does nothing. The name
-- sorts after add-stone-master-class.sql, the script that writes that line.

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2401, 4801, 9601, 19201, 28401, 38601, 52201, 72401, 98601, 140201, 200401, 260601, 310201, 410401]' || char(10)), updated_at = datetime('now') WHERE class_id = 'stone-master' AND instr(markdown, 'xp_table:') = 0 AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- Read the result back.
SELECT 'the Stone Master carries its Atlantis ladder' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'stone-master'
   AND instr(markdown, 'xp_table: [0, 2401, 4801, 9601, 19201, 28401, 38601, 52201, 72401, 98601, 140201, 200401, 260601, 310201, 410401]') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-stone-master-xp.sql');
