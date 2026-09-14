-- The Mechanical skill program gave Locksmith the WRONG skill's percentage.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzz-fix-hu-locksmith-base.sql
--
-- HEROES UNLIMITED PRINTS TWO LOCK SKILLS AND THEY ARE DIFFERENT SKILLS:
--
--   Picking Locks  35% +5%  printed 31, the thief's - "picking/opening key,
--                           and basic, tumbler type locks", 1D6 melees a try
--   Locksmith      25% +5%  printed 32, "the practiced study of lock designs,
--                           and ability to repair, build, modify and open"
--
-- The catalog splits them the same way - `Pick Locks` under Espionage and
-- `Locksmith` under Mechanical. The Educational Levels' Mechanical program
-- takes LOCKSMITH, and it was written with Picking Locks' 35%, so every one of
-- these ten is ten points high and carries a note crediting the wrong entry.
--
-- Found while extracting every printed percentage for `BOOK-INGEST-AUDIT` F83:
-- Locksmith turned up in the AGREE column and the DISAGREE column at once,
-- which is only possible if two book names were mapped onto one catalog row.
-- A name-to-name alias table is exactly where this kind of error hides, and
-- nothing but reading both entries on the page would have settled it.
--
-- The note is rewritten too. It said "Printed as Picking Locks", which is now
-- doubly wrong: it is printed as Locksmith, and that is the whole point.
--
-- Each UPDATE is guarded on the exact wrong text, so re-running is a no-op and
-- a class already corrected by hand is left alone.

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 45, per_level: 5, note: "Printed as Picking Locks. 35% book base +10% educational bonus." }',
       '{ name: "Locksmith", base: 35, per_level: 5, note: "Printed 32. 25% book base +10% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-military' AND instr(markdown, 'Locksmith", base: 45,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 55, per_level: 5, note: "Printed as Picking Locks. 35% book base +20% educational bonus." }',
       '{ name: "Locksmith", base: 45, per_level: 5, note: "Printed 32. 25% book base +20% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-trade-school' AND instr(markdown, 'Locksmith", base: 55,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 45, per_level: 5, note: "Printed as Picking Locks. 35% book base +10% educational bonus." }',
       '{ name: "Locksmith", base: 35, per_level: 5, note: "Printed 32. 25% book base +10% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-one-year-college' AND instr(markdown, 'Locksmith", base: 45,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 50, per_level: 5, note: "Printed as Picking Locks. 35% book base +15% educational bonus." }',
       '{ name: "Locksmith", base: 40, per_level: 5, note: "Printed 32. 25% book base +15% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-two-years-college' AND instr(markdown, 'Locksmith", base: 50,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 50, per_level: 5, note: "Printed as Picking Locks. 35% book base +15% educational bonus." }',
       '{ name: "Locksmith", base: 40, per_level: 5, note: "Printed 32. 25% book base +15% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-three-years-college' AND instr(markdown, 'Locksmith", base: 50,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 55, per_level: 5, note: "Printed as Picking Locks. 35% book base +20% educational bonus." }',
       '{ name: "Locksmith", base: 45, per_level: 5, note: "Printed 32. 25% book base +20% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-four-years-college' AND instr(markdown, 'Locksmith", base: 55,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 55, per_level: 5, note: "Printed as Picking Locks. 35% book base +20% educational bonus." }',
       '{ name: "Locksmith", base: 45, per_level: 5, note: "Printed 32. 25% book base +20% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-military-specialist' AND instr(markdown, 'Locksmith", base: 55,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 60, per_level: 5, note: "Printed as Picking Locks. 35% book base +25% educational bonus." }',
       '{ name: "Locksmith", base: 50, per_level: 5, note: "Printed 32. 25% book base +25% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-bachelors' AND instr(markdown, 'Locksmith", base: 60,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 65, per_level: 5, note: "Printed as Picking Locks. 35% book base +30% educational bonus." }',
       '{ name: "Locksmith", base: 55, per_level: 5, note: "Printed 32. 25% book base +30% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-masters' AND instr(markdown, 'Locksmith", base: 65,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
       '{ name: "Locksmith", base: 70, per_level: 5, note: "Printed as Picking Locks. 35% book base +35% educational bonus." }',
       '{ name: "Locksmith", base: 60, per_level: 5, note: "Printed 32. 25% book base +35% educational bonus. NOT Picking Locks, which is a different skill at 35% and is the catalog row Pick Locks." }')
 WHERE class_id = 'hu-edu-doctorate' AND instr(markdown, 'Locksmith", base: 70,') > 0;

-- ASSERTIONS.

SELECT 'ten Educational Levels carry the corrected Locksmith' AS assertion,
       count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id GLOB 'hu-edu-*' AND instr(markdown, 'NOT Picking Locks') > 0;

SELECT 'and none still credits Picking Locks' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id GLOB 'hu-edu-*' AND instr(markdown, 'Printed as Picking Locks') > 0;

-- Each one is exactly its own educational bonus above the book's 25%.
SELECT 'hu-edu-military: Locksmith is 25%+10%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-military'
   AND instr(markdown, 'Locksmith", base: 35, per_level: 5') > 0;

SELECT 'hu-edu-trade-school: Locksmith is 25%+20%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-trade-school'
   AND instr(markdown, 'Locksmith", base: 45, per_level: 5') > 0;

SELECT 'hu-edu-one-year-college: Locksmith is 25%+10%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-one-year-college'
   AND instr(markdown, 'Locksmith", base: 35, per_level: 5') > 0;

SELECT 'hu-edu-two-years-college: Locksmith is 25%+15%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-two-years-college'
   AND instr(markdown, 'Locksmith", base: 40, per_level: 5') > 0;

SELECT 'hu-edu-three-years-college: Locksmith is 25%+15%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-three-years-college'
   AND instr(markdown, 'Locksmith", base: 40, per_level: 5') > 0;

SELECT 'hu-edu-four-years-college: Locksmith is 25%+20%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-four-years-college'
   AND instr(markdown, 'Locksmith", base: 45, per_level: 5') > 0;

SELECT 'hu-edu-military-specialist: Locksmith is 25%+20%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-military-specialist'
   AND instr(markdown, 'Locksmith", base: 45, per_level: 5') > 0;

SELECT 'hu-edu-bachelors: Locksmith is 25%+25%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-bachelors'
   AND instr(markdown, 'Locksmith", base: 50, per_level: 5') > 0;

SELECT 'hu-edu-masters: Locksmith is 25%+30%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-masters'
   AND instr(markdown, 'Locksmith", base: 55, per_level: 5') > 0;

SELECT 'hu-edu-doctorate: Locksmith is 25%+35%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'hu-edu-doctorate'
   AND instr(markdown, 'Locksmith", base: 60, per_level: 5') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-fix-hu-locksmith-base.sql');
