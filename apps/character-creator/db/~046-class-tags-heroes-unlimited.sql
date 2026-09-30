-- Authored class tags for heroes-unlimited classes, one line each, from a reviewed
-- scripts/class-tags.mjs table. Derived tags (magic, psionics, mega-damage,
-- horror-factor) are computed from the class and never written.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~046-class-tags-heroes-unlimited.sql
--
-- A TILDE SCRIPT ON PURPOSE: seven fix- scripts rewrite a class's whole
-- markdown, and any that sorted after this file would erase the tags on a
-- rebuild. Guarded on the class having no tags line, so a re-run is a no-op.
-- The tilde number is claimed at merge.

UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [combat, beginner]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-physical-training' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [augmented, pilot, tech]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-robotics' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-ancient-master' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [hunter, wilderness, ranged]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-hunter' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [stealth, tech]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-secret-operative' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [stealth]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-stage-magician' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [scholar, tech]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-super-sleuth' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-bachelors' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-doctorate' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-masters' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-military' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-edu-military-specialist' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-combat-specialist' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [tech]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-engineer' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-military-specialist' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: occ' || char(10), char(10) || 'category: occ' || char(10) || 'tags: [scholar]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-alien-edu-science-specialist' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [augmented, combat]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-bionics' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [tech]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-hardware' AND instr(markdown, char(10) || 'tags:') = 0;
UPDATE imported_classes SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10), char(10) || 'category: rcc' || char(10) || 'tags: [magic]' || char(10)), updated_at = datetime('now') WHERE class_id = 'hu-magic' AND instr(markdown, char(10) || 'tags:') = 0;

SELECT 'the 19 reviewed classes carry a tags line' AS assertion, count(*) AS got, 19 AS want FROM imported_classes WHERE class_id IN ('hu-physical-training', 'hu-robotics', 'hu-ancient-master', 'hu-hunter', 'hu-secret-operative', 'hu-stage-magician', 'hu-super-sleuth', 'hu-edu-bachelors', 'hu-edu-doctorate', 'hu-edu-masters', 'hu-edu-military', 'hu-edu-military-specialist', 'hu-alien-edu-combat-specialist', 'hu-alien-edu-engineer', 'hu-alien-edu-military-specialist', 'hu-alien-edu-science-specialist', 'hu-bionics', 'hu-hardware', 'hu-magic') AND instr(markdown, char(10) || 'tags: [') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~046-class-tags-heroes-unlimited.sql');
