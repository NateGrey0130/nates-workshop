-- The sixteen Heroes Unlimited education classes offer ZERO secondary skills,
-- because they spell the key a way nothing reads.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzz-hu-secondary-skills-key.sql
--
-- WHAT IS WRONG. Each of the sixteen writes:
--
--     occ_secondary_skills: { count: 8 }
--
-- and the key the app reads is `skills.secondary_skills`:
--
--     apps/character-creator/app.js:2695
--       const secondaryCfg = sk.secondary_skills || { count: 0 };
--     apps/character-creator/js/parser.js:2703
--       const secondary = data.skills.secondary_skills;
--
-- So `secondaryCfg.count` is 0, the wizard's secondary step offers nothing, and
-- a Heroes Unlimited character is built without the 8 to 12 secondary skills
-- printed 27 and printed 56 give it.
--
-- THE NAME IS A TRAP THE SCHEMA SET. Its sibling really is `occ_related_skills`
-- - that prefix is correct there - so `occ_secondary_skills` reads as the
-- matching spelling and is not. 252 other published classes get it right
-- (--remote, 2026-09-14); all sixteen wrong ones are from this one batch, which
-- is what a naming inconsistency costs the first time somebody writes a class
-- from memory of the line above.
--
-- NOTHING COULD REPORT IT, which is why it shipped. `class-check --remote`
-- answers `ready - 0 errors, 0 warnings` on every one: the unmodelled-key check
-- in scripts/class-check-lib.mjs compares TOP-LEVEL keys against KNOWN_KEYS and
-- never descends into `skills`, so a bad key one level down is invisible to the
-- one check built to catch exactly this. Filed as BOOK-INGEST-AUDIT F87.
--
-- THE COUNTS THEMSELVES ARE RIGHT, and were checked rather than assumed before
-- this file was written. Printed 27 was rendered at 240 dpi and all eleven
-- Educational Level rows read off it:
--
--     High School 10   Military 8    Trade School 8   One Year 8
--     Two Years 8      Three Years 8 Four Years 10    Military Specialist 8
--     Bachelor's 10    Master's 10   Doctorate 10
--
-- and they match what the sixteen classes already store. The Alien's own five
-- packages (4, 5, 5, 6, 12) come from printed 56 and are untouched here. So
-- this file renames a key and changes no number.
--
-- The token occurs EXACTLY ONCE in each of the sixteen (--remote, 2026-09-14),
-- so a replace() cannot touch prose, and none of them carries the correct
-- spelling as well - there is no duplicate key to create. Re-running is a no-op
-- once the token is gone.
--
-- EVERY GUARD BELOW USES instr(), NOT LIKE, and the first draft of this file
-- used LIKE seven times. `_` is a single-character WILDCARD in a LIKE pattern,
-- so '%occ_secondary_skills%' also matches occXsecondaryXskills - and on a key
-- whose name is nothing but underscored words, that is the entire guard. The
-- smoke suite refuses an underscored LIKE in any data script and caught all
-- seven, which is that check doing exactly the job it was written for.

UPDATE imported_classes
   SET markdown = replace(markdown, 'occ_secondary_skills:', 'secondary_skills:')
 WHERE deleted_at IS NULL
   AND instr(markdown, 'occ_secondary_skills:') > 0;

-- ASSERTIONS.

SELECT 'no class spells it occ_secondary_skills any more' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE deleted_at IS NULL AND instr(markdown, 'occ_secondary_skills') > 0;

-- 21, not 16, and the difference is the point: the FIVE Special Training
-- classes already spelled it correctly (`hu-ancient-master`, `hu-hunter`,
-- `hu-secret-operative`, `hu-stage-magician`, `hu-super-sleuth`, --remote
-- 2026-09-14). The same batch got this key right in one PR and wrong in
-- another. This total is unchanged by the UPDATE above - the sixteen already
-- matched this pattern, `occ_secondary_skills: { count:` containing it as a
-- substring - so it is asserted as a NO-CHANGE check on the other five.
SELECT 'twenty-one classes carry the inline form, as before' AS assertion, count(*) AS got, 21 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'secondary_skills: { count:') > 0;

-- The numbers must be UNCHANGED. Asserted against the printed table rather than
-- against whatever was there, so a replace() that ate a digit would be caught.
SELECT 'the ten-secondary levels still say 10' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND class_id IN ('hu-edu-high-school', 'hu-edu-four-years-college',
                    'hu-edu-bachelors', 'hu-edu-masters', 'hu-edu-doctorate')
   AND instr(markdown, 'secondary_skills: { count: 10 }') > 0;

SELECT 'the eight-secondary levels still say 8' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND class_id IN ('hu-edu-military', 'hu-edu-military-specialist',
                    'hu-edu-one-year-college', 'hu-edu-two-years-college',
                    'hu-edu-three-years-college', 'hu-edu-trade-school')
   AND instr(markdown, 'secondary_skills: { count: 8 }') > 0;

SELECT 'the Alien packages keep their own five figures' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id LIKE 'hu-alien-edu-%'
   AND instr(markdown, 'secondary_skills: { count:') > 0;

-- And no class OUTSIDE this book was touched. The UPDATE is bounded by the
-- wrong spelling, so this should be impossible; it is asserted because a
-- replace() over every published class is the shape that goes wrong quietly.
SELECT 'no class outside this book carries the pattern' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND class_id NOT LIKE 'hu-%'
   AND instr(markdown, 'secondary_skills: { count:') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzz-hu-secondary-skills-key.sql');
