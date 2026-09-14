-- The Alien R.C.C.'s `occ_restrictions`, which the script before this one
-- failed to write.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzz-hu-aliens-education-only.sql
--
-- WHY THERE ARE TWO SCRIPTS. `zzzzzz-hu-education-occ-restrictions.sql` does
-- this in its first statement, guarded on
-- `instr(markdown, 'occ_restrictions:') = 0`. The Alien's own LORE already
-- contained that string - its extraction note promises "this class will name
-- them in `occ_restrictions: { only: [...] }` ... it arrives in a fix- script"
-- - so the guard was satisfied by the sentence describing the work, the
-- statement matched no row, and only the eight `except` classes were written.
-- The assertion caught it on the apply.
--
-- That script's guard is now scoped to char(10) either side, so a CLEAN
-- REBUILD writes the Alien correctly from it and this file no-ops. Production
-- cannot re-run it - `data_script_runs` already holds its name - so this file
-- exists to bring production to the same place. Both are guarded, so whichever
-- runs first wins and the second does nothing.
--
-- It also corrects the promise in the Alien's own extraction note, which now
-- names a file rather than "a fix- script", and says which one.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10)
      || 'occ_restrictions:' || char(10)
      || '  only: ["hu-alien-edu-general-studies", "hu-alien-edu-military-specialist", "hu-alien-edu-science-specialist", "hu-alien-edu-combat-specialist", "hu-alien-edu-engineer"]' || char(10))
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10)) = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- The promise, now kept. Guarded on the old wording so a re-run is a no-op.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'this class will name them in `occ_restrictions: { only: [...] }`, which takes class ids and so cannot be written until they exist; it arrives in a fix- script.',
         'this class names them in `occ_restrictions`, written by zzzzzz-hu-education-occ-restrictions.sql once those five class ids existed.')
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, 'it arrives in a fix- script.') > 0;

-- ASSERTIONS.

SELECT 'the Alien is limited to its own five' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10)) > 0
   AND instr(markdown, '  only: ["hu-alien-edu-general-studies"') > 0;

SELECT 'and it names all five' AS assertion, count(*) AS got, 5 AS want
  FROM (SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, '"hu-alien-edu-general-studies"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, '"hu-alien-edu-military-specialist"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, '"hu-alien-edu-science-specialist"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, '"hu-alien-edu-combat-specialist"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, '"hu-alien-edu-engineer"') > 0);

-- It must NOT have picked up the `except` form as well. The parser refuses a
-- class stating both, and a class refusing everything is the failure this
-- would produce.
SELECT 'and states only, never except' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'hu-aliens' AND instr(markdown, '  except: ["hu-alien-edu') > 0;

-- The key landed in the FRONTMATTER, not in the body. `---` closes it, so the
-- key's offset has to be smaller than the second `---`.
SELECT 'and it is in the frontmatter, not the lore' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10))
       < instr(substr(markdown, 4), char(10) || '---' || char(10)) + 3;

-- The eight others were already right and must stay so.
SELECT 'the eight except classes are unchanged' AS assertion, count(*) AS got, 8 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-bionics', 'hu-experiments', 'hu-hardware', 'hu-magic',
                    'hu-mutants', 'hu-psionics', 'hu-robotics', 'hu-physical-training')
   AND instr(markdown, '  except: ["hu-alien-edu-general-studies"') > 0;

SELECT 'the stale promise is gone' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'hu-aliens' AND instr(markdown, 'it arrives in a fix- script.') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-hu-aliens-education-only.sql');
