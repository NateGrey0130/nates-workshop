-- Eleven more Heroes Unlimited percentages, which the first extraction lost.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-hu-skill-system-bases-2.sql
--
-- `BOOK-INGEST-AUDIT` F83, and a reading bug worth writing down. The first pass
-- bounded each skill's description by the NEXT run-in heading, and the sentence
-- it was looking for - "Base Skill: 40% + 5%" - wraps often enough that
-- `Skill:` or `Base Skill:` begins a line. Both match a run-in heading
-- perfectly. So the boundary detector matched a piece of the very thing it was
-- meant to bound, and cut each segment off IMMEDIATELY BEFORE its own
-- percentage.
--
-- Eleven skills dropped out that way and NOTHING SAID SO: a missing override
-- leaves the catalog's number standing, which is the direction that never
-- reports. It was caught by a premise audit reading three of them off the page
-- by hand and asking why they were absent.
--
-- WEAPON SYSTEMS IS THE EXPENSIVE ONE. The first pass did not merely drop it -
-- a bare-name search picked up a neighbouring skill's figure and gave it
-- 30%/+5 where printed 35 says **50% + 2%**. That number reached four live
-- classes; see zzzzzzzz-fix-hu-weapon-systems-base.sql.
--
-- All eleven were read off the page individually before this file was written.
-- Guarded on the primary key, so re-running is a no-op.

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Airplane', 'heroes-unlimited', 70, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Airplane');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Automotive Mechanics', 'heroes-unlimited', 50, 3, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Automotive Mechanics');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Basic Electronics', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Basic Electronics');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Biology', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Biology');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Mathematics: Advanced', 'heroes-unlimited', 64, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Mathematics: Advanced');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Mechanical Engineer', 'heroes-unlimited', 45, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Mechanical Engineer');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Paramedic', 'heroes-unlimited', 50, 6, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Paramedic');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Sing', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Sing');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'T.V./Video', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'T.V./Video');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Truck', 'heroes-unlimited', 60, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Truck');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Weapon Systems', 'heroes-unlimited', 50, 2, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Weapon Systems');

-- ASSERTIONS.

SELECT 'the catalog now carries all 59 overrides' AS assertion, count(*) AS got, 59 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited';

SELECT 'and every one names a real skill' AS assertion, count(*) AS got, 59 AS want
  FROM skill_system_bases b JOIN skills s ON s.name = b.skill_name
 WHERE b.system = 'heroes-unlimited';

SELECT 'none restates the catalog it overrides' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases b JOIN skills s ON s.name = b.skill_name
 WHERE b.system = 'heroes-unlimited' AND b.base = s.base AND b.per_level = s.per_level;

-- The three the premise audit read off the page by hand, spelled out.
SELECT 'Weapon Systems is 50%/+2 (printed 35)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Weapon Systems' AND base = 50 AND per_level = 2;

SELECT 'Basic Electronics is 40%/+5 (printed 30)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Basic Electronics' AND base = 40 AND per_level = 5;

SELECT 'Mechanical Engineer is 45%/+5 (printed 32)' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Mechanical Engineer' AND base = 45 AND per_level = 5;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-hu-skill-system-bases-2.sql');
