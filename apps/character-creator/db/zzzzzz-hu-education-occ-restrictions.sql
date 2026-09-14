-- Which education each Heroes Unlimited Power Category may take.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-hu-education-occ-restrictions.sql
--
-- `occ_restrictions` takes CLASS IDS, so it could not be written until the
-- sixteen education classes existed. The Aliens survey said this would arrive
-- in a correction afterwards, and this is it.
--
-- THE RULE, printed 27 and printed 56. Every Power Category rolls on the
-- Educational Level table on printed 27 except Special Training and Physical
-- Training, which print their own skill packages instead. The ALIEN rolls
-- there too and then printed 56 gives it a five-outcome table of its own that
-- REPLACES it - so the Alien takes one of five, and nobody else may.
--
-- TWO DIRECTIONS, because `occ_restrictions` states `only` OR `except` and
-- never both:
--
--   hu-aliens                       only:   its own five
--   the eight other rolling ones    except: those same five
--
-- The `except` half is purely subtractive - it removes five options from a
-- list of twenty-one and leaves the eleven Educational Levels alone.
--
-- WHAT THIS DELIBERATELY DOES NOT DO. Special Training's five classes and
-- Physical Training take NO education at all, and the only way to say that is
-- `only: ["none"]` - a list matching no class id, which refuses every
-- occupation rather than removing some. That is a different kind of change:
-- it decides whether a class can be paired at all, and the wizard's O.C.C.
-- step has never been shown a race that admits nothing. Left out on purpose
-- rather than guessed at, and recorded in the survey's ledger.
--
-- FILENAME: `zzzzzz-` because a clean rebuild applies this directory as one
-- sorted glob and this must run AFTER every `add-hu-*-class.sql` it edits.
-- Checked with the sort command from the class-import skill rather than
-- assumed - the z-tier has escalated before and a `zz-` file now sorts ahead
-- of three dozen others.
--
-- THE GUARD IS SCOPED TO THE FRONTMATTER, and the first version was not. It
-- read `instr(markdown, 'occ_restrictions:') = 0`, which the ALIEN's own LORE
-- already contains: its extraction note promises that "this class will name
-- them in `occ_restrictions: { only: [...] }` ... it arrives in a fix- script".
-- So the guard was satisfied by the sentence describing the script, and the
-- Alien's half silently did nothing while the other eight fired. Anchoring on
-- char(10) either side matches the KEY on its own line and not the prose.
--
-- Same shape as the readback trap already on record: a guard that greps for a
-- phrase is defeated by the document that explains the phrase.
--
-- Guarded on the text it inserts, so re-running is a no-op, and keyed on
-- `class_id`, which is a stable slug rather than an insertion-order integer.

-- The Alien: its own five, and nothing else.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10)
      || 'occ_restrictions:' || char(10)
      || '  only: ["hu-alien-edu-general-studies", "hu-alien-edu-military-specialist", "hu-alien-edu-science-specialist", "hu-alien-edu-combat-specialist", "hu-alien-edu-engineer"]' || char(10))
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10)) = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- The eight other Power Categories that roll on printed 27: everything except
-- the Alien's five.
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: rcc' || char(10),
         char(10) || 'category: rcc' || char(10)
      || 'occ_restrictions:' || char(10)
      || '  except: ["hu-alien-edu-general-studies", "hu-alien-edu-military-specialist", "hu-alien-edu-science-specialist", "hu-alien-edu-combat-specialist", "hu-alien-edu-engineer"]' || char(10))
 WHERE class_id IN ('hu-bionics', 'hu-experiments', 'hu-hardware', 'hu-magic',
                    'hu-mutants', 'hu-psionics', 'hu-robotics', 'hu-physical-training')
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10)) = 0
   AND instr(markdown, char(10) || 'category: rcc' || char(10)) > 0;

-- ASSERTIONS.

SELECT 'the Alien is limited to its own five' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10)) > 0
   AND instr(markdown, '  only: ["hu-alien-edu-general-studies"') > 0;

SELECT 'and it names all five' AS assertion, count(*) AS got, 5 AS want
  FROM (SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, 'hu-alien-edu-general-studies') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, 'hu-alien-edu-military-specialist') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, 'hu-alien-edu-science-specialist') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, 'hu-alien-edu-combat-specialist') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'hu-aliens' AND instr(markdown, 'hu-alien-edu-engineer') > 0);

SELECT 'eight other Power Categories exclude the Alien five' AS assertion,
       count(*) AS got, 8 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-bionics', 'hu-experiments', 'hu-hardware', 'hu-magic',
                    'hu-mutants', 'hu-psionics', 'hu-robotics', 'hu-physical-training')
   AND instr(markdown, '  except: ["hu-alien-edu-general-studies"') > 0;

-- Nobody got BOTH forms, which the parser refuses and which a second run of a
-- badly guarded replace would produce.
SELECT 'no class states both only and except' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE instr(markdown, '  only: ["hu-alien-edu') > 0
   AND instr(markdown, '  except: ["hu-alien-edu') > 0;

-- The five Special Training classes are untouched, which is the decision in
-- the header rather than an omission.
SELECT 'Special Training is deliberately unrestricted' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-ancient-master', 'hu-hunter', 'hu-secret-operative',
                    'hu-stage-magician', 'hu-super-sleuth')
   AND instr(markdown, char(10) || 'occ_restrictions:' || char(10)) > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-hu-education-occ-restrictions.sql');
