-- RETRO-AUDIT R14: five Palladium Fantasy classes stop stating a related-skill
-- floor in prose and start holding one.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r14-related-floors.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r14-related-floors.sql
--
-- WHAT WAS WRONG. Each of these five prints a floor on its O.C.C. Related
-- Skills line and each carried it only as a sentence inside a CATEGORY note,
-- which the wizard displays and nothing counts. A player could spend every
-- related pick elsewhere and the save would be accepted.
--
-- THE BOOK, read off the cache rather than off each class's own note.
-- Palladium Fantasy RPG, pf cache, registry offset 2:
--
--   knight    printed 87 (p089): "Select two other skills from the Communication
--             skill category and six other skills at level one"        2 + 6 = 8
--   palladin  printed 89 (p091): "... and five other skills at level one"
--                                                                     2 + 5 = 7
--   thief     printed 94 (p096): "Select two espionage skills (+10% on these two
--             only) and six other skills of choice at level one"       2 + 6 = 8
--   soldier   printed 83 (p085): "Select two additional skills from the category
--             of Military or Espionage, and seven other skills of choice"
--                                                                     2 + 7 = 9
--   witch     printed 116 (p118): "Select 10 other skills, but two must be from
--             wilderness or domestic"                        10 total, floor 2
--
-- Every arithmetic matches the count already stored, so no count moves here.
--
-- POSTURE: THIS ENFORCES, and that is the whole of what was agreed. minimums is
-- not a note. relatedFloorStatus (js/parser.js) feeds
-- functions/api/character-creator/_lib/validate-character.js, which pushes a
-- `related_minimum` violation when a floor is UNREACHABLE, and characters.js
-- answers HTTP 422 "This character breaks its class rules". Three further
-- endpoints do the same on an EXISTING character - picks.js, level-confirm.js
-- and variant.js - so this reaches more than the create path.
--
-- NOTHING LIVE BREAKS. Production holds ZERO characters and ZERO drafts on all
-- five, checked on both class_id and occ_class_id, --remote, 2026-09-05. A
-- floor is also not a ceiling and never fires on a fresh build: unreachable is
-- owed > remaining, and at creation remaining is the full count.
--
-- TWO OF THE FIVE ARE UNIONS, AND EACH STATED ITSELF TWICE. The soldier prints
-- "Military or Espionage" and the witch "wilderness or domestic"; each class
-- carried that sentence in BOTH of the named category notes, which reads like
-- two floors of two and is one floor of two across a pair. One `categories:`
-- entry says it once, and the rewritten notes say so in words.
--
-- SEVEN NOTES, NOT FIVE, for that reason. R14's proposal says "rewrite each
-- category note" and the count follows from the classes, not from the proposal.
--
-- THE UNION SPELLING IS NOT NEW. `categories:` and the one-element `category:`
-- sugar landed together in PR #428 (BOOK-INGEST-AUDIT F6) and city-rat has held
-- a union in production since. RETRO-AUDIT R13 released a DOCUMENTATION claim,
-- not a capability; R14's own text calls these "the shape R13 just released",
-- which overstates it.
--
-- add-soldier-class.sql CARRIES THE CLAIM AND IS NOT EDITED. Lines 18-23 there
-- say occ_related_skills has "no way to say two of the nine from this pair".
-- That was true when it was written and is false from here on. It is a `--`
-- comment rather than data, so no rebuilt database repeats it and there is
-- nothing to replace in D1; a one-shot script is not edited, so THIS FILE is
-- the correction of record and it sorts after that one. The knight, palladin,
-- thief and witch scripts carry no such comment - checked.
--
-- IT ALSO RETIRES A READBACK THAT WILL NOW PRINT THE WRONG THING.
-- zzzzz-retro-r13-assassin-minimums.sql asserts "the five other floor-carrying
-- classes are untouched ... want 0", correct when it ran and false from here.
-- The inverse is asserted at the foot of this file, which sorts after it
-- (r13 < r14). d1-apply PRINTS trailing SELECTs rather than enforcing them, so
-- the stale one costs a confusing line on a fresh rebuild and nothing more.

-- ---- knight: 2 of 8 from Communications -----------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 8
    categories:',
'  occ_related_skills:
    count: 8
    # PF printed 87: "Select two other skills from the Communication skill
    # category and six other skills at level one". RETRO-AUDIT R14.
    minimums:
      - { count: 2, category: "Communications" }
    categories:')
 WHERE class_id = 'knight' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '      - { name: "Communications", note: "+10%; two of the eight must come from here" }',
       '      - { name: "Communications", note: "+10%; two of the eight must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other six may also be Communications." }')
 WHERE class_id = 'knight' AND deleted_at IS NULL;

-- ---- palladin: 2 of 7 from Communications ---------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 7
    categories:',
'  occ_related_skills:
    count: 7
    # PF printed 89: "Select two other skills from the Communication skill
    # category and five other skills at level one". RETRO-AUDIT R14.
    minimums:
      - { count: 2, category: "Communications" }
    categories:')
 WHERE class_id = 'palladin' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '      - { name: "Communications", note: "+10%; two of the seven must come from here" }',
       '      - { name: "Communications", note: "+10%; two of the seven must come from here. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other five may also be Communications." }')
 WHERE class_id = 'palladin' AND deleted_at IS NULL;

-- ---- thief: 2 of 8 from Espionage ------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 8
    categories:',
'  occ_related_skills:
    count: 8
    # PF printed 94: "Select two espionage skills (+10% on these two only) and
    # six other skills of choice at level one". RETRO-AUDIT R14.
    minimums:
      - { count: 2, category: "Espionage" }
    categories:')
 WHERE class_id = 'thief' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'note: "Any except Sniper and Track Humanoids. Two of the eight must come from here, and those two get +10%." }',
       'note: "Any except Sniper and Track Humanoids. Two of the eight must come from here, and those two get +10%. Carried as occ_related_skills.minimums since RETRO-AUDIT R14, so the wizard counts it and the server refuses a save that cannot reach it. A floor is a minimum and not a cap: the other six may also be Espionage, and the book gives the bonus to two of them only." }')
 WHERE class_id = 'thief' AND deleted_at IS NULL;

-- ---- soldier: 2 of 9 from Military OR Espionage, ONE union floor -----------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 9
    categories:',
'  occ_related_skills:
    count: 9
    # PF printed 83: "Select two additional skills from the category of Military
    # or Espionage, and seven other skills of choice". ONE floor across the
    # pair, satisfied by any two of them. RETRO-AUDIT R14.
    minimums:
      - { count: 2, categories: ["Military", "Espionage"] }
    categories:')
 WHERE class_id = 'soldier' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '      - { name: "Espionage", note: "+5%; two of the nine must come from Military or Espionage" }',
       '      - { name: "Espionage", note: "+5%; two of the nine must come from Military or Espionage. ONE union floor across the pair - not two of these and two more under Military - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }')
 WHERE class_id = 'soldier' AND deleted_at IS NULL;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '      - { name: "Military", note: "+10%; two of the nine must come from Military or Espionage" }',
       '      - { name: "Military", note: "+10%; two of the nine must come from Military or Espionage. ONE union floor across the pair - not two of these and two more under Espionage - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }')
 WHERE class_id = 'soldier' AND deleted_at IS NULL;

-- ---- witch: 2 of 10 from Wilderness OR Domestic, ONE union floor -----------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 10
    categories:',
'  occ_related_skills:
    count: 10
    # PF printed 116: "Select 10 other skills, but two must be from wilderness
    # or domestic". ONE floor across the pair, satisfied by any two of them,
    # and the ten INCLUDES the two. RETRO-AUDIT R14.
    minimums:
      - { count: 2, categories: ["Wilderness", "Domestic"] }
    categories:')
 WHERE class_id = 'witch' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '      - { name: "Domestic", note: "+10%; two of the ten must come from Wilderness or Domestic" }',
       '      - { name: "Domestic", note: "+10%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Wilderness - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }')
 WHERE class_id = 'witch' AND deleted_at IS NULL;

UPDATE imported_classes
   SET markdown = replace(markdown,
       '      - { name: "Wilderness", note: "+5%; two of the ten must come from Wilderness or Domestic" }',
       '      - { name: "Wilderness", note: "+5%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Domestic - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }')
 WHERE class_id = 'witch' AND deleted_at IS NULL;

-- ---- readbacks -------------------------------------------------------------
SELECT 'all five now hold a floor' AS assertion,
       count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE class_id IN ('knight', 'palladin', 'thief', 'soldier', 'witch')
   AND deleted_at IS NULL AND instr(markdown, 'minimums:') > 0;

SELECT 'the three single-category floors name their category' AS assertion,
       count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE class_id IN ('knight', 'palladin', 'thief')
   AND deleted_at IS NULL
   AND (instr(markdown, 'count: 2, category: "Communications"') > 0
     OR instr(markdown, 'count: 2, category: "Espionage"') > 0);

SELECT 'the soldier holds ONE union floor, not two singles' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'soldier' AND deleted_at IS NULL
   AND instr(markdown, 'count: 2, categories: ["Military", "Espionage"]') > 0;

SELECT 'the witch holds ONE union floor, not two singles' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'witch' AND deleted_at IS NULL
   AND instr(markdown, 'count: 2, categories: ["Wilderness", "Domestic"]') > 0;

-- Every count is UNCHANGED. The floor is spent out of the count, not added to
-- it, and a moved count would be the one way this script could change what a
-- player is granted.
SELECT 'no related-skill count moved' AS assertion,
       count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND ((class_id = 'knight'   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8')  > 0)
     OR (class_id = 'palladin' AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 7')  > 0)
     OR (class_id = 'thief'    AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 8')  > 0)
     OR (class_id = 'soldier'  AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 9')  > 0)
     OR (class_id = 'witch'    AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 10') > 0));

-- All seven notes were rewritten. Asserted on a phrase unique to the NEW text,
-- because a note that quotes the wording it replaces defeats a grep for the old
-- one - the trap RETRO-AUDIT R3, R6 and R13 each hit.
-- Written as summed scalar subqueries rather than seven UNIONed SELECTs,
-- because D1 refuses a compound SELECT past five terms.
SELECT 'all seven category notes were rewritten' AS assertion,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'knight'   AND instr(markdown, 'the other six may also be Communications') > 0)
     + (SELECT count(*) FROM imported_classes WHERE class_id = 'palladin' AND instr(markdown, 'the other five may also be Communications') > 0)
     + (SELECT count(*) FROM imported_classes WHERE class_id = 'thief'    AND instr(markdown, 'the other six may also be Espionage') > 0)
     + (SELECT count(*) FROM imported_classes WHERE class_id = 'soldier'  AND instr(markdown, 'not two of these and two more under Military') > 0)
     + (SELECT count(*) FROM imported_classes WHERE class_id = 'soldier'  AND instr(markdown, 'not two of these and two more under Espionage') > 0)
     + (SELECT count(*) FROM imported_classes WHERE class_id = 'witch'    AND instr(markdown, 'not two of these and two more under Wilderness') > 0)
     + (SELECT count(*) FROM imported_classes WHERE class_id = 'witch'    AND instr(markdown, 'not two of these and two more under Domestic') > 0)
       AS got, 7 AS want;

-- THE INVERSE OF zzzzz-retro-r13-assassin-minimums.sql's last assertion, which
-- asserted these five were untouched. They were, until this script.
SELECT 'the five are no longer untouched, inverting the r13 readback' AS assertion,
       count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE class_id IN ('knight', 'palladin', 'thief', 'soldier', 'witch')
   AND deleted_at IS NULL AND instr(markdown, 'minimums') > 0;

-- THE TWO LEY LINE CLASSES ARE NOT TOUCHED, and this is the assertion that
-- matters most. ley-line-walker and ley-line-rifter print the same shape - "two
-- of the seven must be from Science and one from Technical", Rifts Ultimate
-- Edition printed 116 - and R14 does not list them, because its own detection
-- query matched only "must come from" and they say "must be from". Filed as
-- RETRO-AUDIT R15 rather than folded in: draft 285 has all seven related picks
-- spent with zero Science, so unlike these five it would break something live.
SELECT 'the two ley line classes are untouched' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
   AND deleted_at IS NULL AND instr(markdown, 'minimums') > 0;

-- Records this run. Every statement guards itself, so this script is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r14-related-floors.sql');
