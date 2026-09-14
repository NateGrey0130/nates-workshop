-- The Pilot Advanced program gave Weapon Systems a percentage off the wrong
-- entry, and the wrong per-level gain with it.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-fix-hu-weapon-systems-base.sql
--
-- Printed 35: "Base Skill: 50% + 2% per level of experience." The four classes
-- below were written with **30% + 5%**, which is neither this book's figure nor
-- the catalog's (40% + 5%) - a bare-name search took a neighbouring skill's
-- number, and the sentence it should have read wraps as "Base" / "Skill: 50% +
-- 2%" across two lines, so the reader that replaced it dropped the skill
-- entirely instead. `BOOK-INGEST-AUDIT` F83, and the reading bug is recorded in
-- zzzzzzzz-hu-skill-system-bases-2.sql.
--
-- THE PER-LEVEL GAIN MOVES TOO, and it is the half that would have outlived a
-- base-only fix: 2% a level against 5% is 30 points of divergence by level ten,
-- and nothing re-resolves a stored skill after it is written.
--
-- Each UPDATE is guarded on the exact wrong text, so re-running is a no-op.
--
-- NOT FIXED HERE: `hu-hardware` states Weapon Systems at 60, which is the
-- CATALOG's 30 plus its own printed +30%. That class says in its own extraction
-- notes that its convention is catalog-base-plus-bonus, and so do the other
-- thirteen Power Category classes. Correcting all fourteen to this book's own
-- figures is a backfill of its own and is recorded as outstanding rather than
-- half-done here.

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Weapon Systems", base: 40, per_level: 5 }',
       '{ name: "Weapon Systems", base: 60, per_level: 2, note: "Printed 35: 50% + 2% per level, +10% educational bonus. The per-level gain is 2%, not the catalog''s 5%." }')
 WHERE class_id = 'hu-edu-military' AND instr(markdown, 'Weapon Systems", base: 40, per_level: 5 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Weapon Systems", base: 50, per_level: 5 }',
       '{ name: "Weapon Systems", base: 70, per_level: 2, note: "Printed 35: 50% + 2% per level, +20% educational bonus. The per-level gain is 2%, not the catalog''s 5%." }')
 WHERE class_id = 'hu-edu-trade-school' AND instr(markdown, 'Weapon Systems", base: 50, per_level: 5 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Weapon Systems", base: 50, per_level: 5 }',
       '{ name: "Weapon Systems", base: 70, per_level: 2, note: "Printed 35: 50% + 2% per level, +20% educational bonus. The per-level gain is 2%, not the catalog''s 5%." }')
 WHERE class_id = 'hu-edu-military-specialist' AND instr(markdown, 'Weapon Systems", base: 50, per_level: 5 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Weapon Systems", base: 65, per_level: 5 }',
       '{ name: "Weapon Systems", base: 85, per_level: 2, note: "Printed 35: 50% + 2% per level, +35% educational bonus. The per-level gain is 2%, not the catalog''s 5%." }')
 WHERE class_id = 'hu-edu-doctorate' AND instr(markdown, 'Weapon Systems", base: 65, per_level: 5 }') > 0;

-- ASSERTIONS.

SELECT 'four Educational Levels carry the corrected Weapon Systems' AS assertion,
       count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id GLOB 'hu-edu-*' AND instr(markdown, 'The per-level gain is 2%, not') > 0;

SELECT 'and none still gains 5% a level' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id GLOB 'hu-edu-*' AND instr(markdown, 'Weapon Systems", base: ') > 0
   AND instr(markdown, 'Weapon Systems", base: ') > 0
   AND instr(substr(markdown, instr(markdown, 'Weapon Systems", base: '), 46), 'per_level: 5') > 0;

SELECT 'hu-edu-military: Weapon Systems is 50%+10% at +2/level' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-military'
   AND instr(markdown, 'Weapon Systems", base: 60, per_level: 2') > 0;

SELECT 'hu-edu-trade-school: Weapon Systems is 50%+20% at +2/level' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-trade-school'
   AND instr(markdown, 'Weapon Systems", base: 70, per_level: 2') > 0;

SELECT 'hu-edu-military-specialist: Weapon Systems is 50%+20% at +2/level' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-military-specialist'
   AND instr(markdown, 'Weapon Systems", base: 70, per_level: 2') > 0;

SELECT 'hu-edu-doctorate: Weapon Systems is 50%+35% at +2/level' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-doctorate'
   AND instr(markdown, 'Weapon Systems", base: 85, per_level: 2') > 0;

-- The override row this agrees with, so the two cannot drift apart.
SELECT 'and the override table agrees' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Weapon Systems' AND base = 50 AND per_level = 2;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-fix-hu-weapon-systems-base.sql');
