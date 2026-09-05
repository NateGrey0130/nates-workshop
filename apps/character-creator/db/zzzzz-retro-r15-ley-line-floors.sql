-- RETRO-AUDIT R15: the Ley Line Walker and the Ley Line Rifter stop stating
-- their related-skill floors in prose and start holding them.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r15-ley-line-floors.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r15-ley-line-floors.sql
--
-- THE BOOK. Rifts Ultimate Edition printed 116 (rue cache p119, registry offset
-- 3, the folio verified inside the page): "Select seven other skills, but two
-- must be selected from the science category and one from technical." The
-- Rifter is printed 117: "Ley Line Rifter Stats. Same as the Ley Line Walker."
--
-- TWO INDEPENDENT SINGLE-CATEGORY FLOORS, not a union and not one floor of
-- three. 2 + 1 = 3 against a count of 7, so four picks stay free, and both
-- Science and Technical are granted categories on both classes - which
-- validateRelatedMinimums would refuse outright otherwise.
--
-- WHY THIS WAS NOT PART OF R14. R14 fixed five classes with the same shape and
-- its detection query missed these two, because they print "must BE from" where
-- it matched "must COME from". That is the only reason; the query is an instr()
-- over the whole record and reads no note, so where the sentence sits could not
-- have hidden them.
--
-- POSTURE: THIS ENFORCES. relatedFloorStatus (js/parser.js) feeds
-- functions/api/character-creator/_lib/validate-character.js, which pushes a
-- `related_minimum` violation when a floor is UNREACHABLE, and characters.js
-- answers HTTP 422. picks.js, level-confirm.js and variant.js answer it on an
-- EXISTING character too.
--
-- WHAT IS LIVE, AND R15's OWN PREMISE WAS WRONG ABOUT IT. R15 said draft 285 -
-- lillcreeper's Ley Line Walker, all seven related picks spent - would be
-- "owed 2, remaining 0" and refused. Owed 2 is right. Remaining 0 is NOT.
--
--   The draft is at LEVEL 3, and the allowance grows with the schedule:
--   relatedAllowance(cls, 3) = count 7 + the { level: 3, count: 2 } grant = 9.
--   So owed 2, remaining 2, and unreachable is `owed > remaining` - false.
--   The save is ACCEPTED. Verified by running the real relatedAllowance and
--   relatedFloorStatus against the live class and the live draft.
--
--   Better still, one floor is already met. Of its seven picks, Language:
--   Dragonese and Lore: Magic are both category Technical, so Technical is 2 of
--   1 with one to spare; only Science is short. The two banked level-3 picks
--   cover it, and the player loses nothing.
--
-- SO THE REAL LIVE EFFECT IS A WRONG WARNING, NOT A REFUSED SAVE, and that is
-- an app defect this script does not fix. app.js passes
-- occ_related_skills.count as the allowance instead of relatedAllowance(cls,
-- level), so the wizard will tell that player "the picks left cannot reach it,
-- or the save will be refused" while the server would accept it. It is wrong
-- today for every one of the 28 classes that already hold a floor above level
-- one; R15 did not create it and does not carry it. Filed as R18.
--
-- Character 9917 holds occ_class_id ley-line-rifter at level 1 with no
-- related-typed skills: owed 3, remaining 7, reachable. Nothing else is live.
--
-- THE NOTE THIS REWRITES IS NOT OWNED BY add-ley-line-walker-class.sql any
-- more. That script's line 96 writes an older sentence; the live text was last
-- written by fix-pre-rue-class-audit.sql:387. Both replacements below are
-- matched against the LIVE text, and this file sorts after both.
--
-- NEITHER add- SCRIPT CARRIES A LIMITATION CLAIM about the floor, checked - so
-- unlike R14's soldier there is no stale assertion to correct.

-- ---- ley-line-walker -------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 7
    categories:',
'  occ_related_skills:
    count: 7
    # RUE printed 116: "Select seven other skills, but two must be selected from
    # the science category and one from technical." Two independent floors, not
    # a union: 2 + 1 = 3 of the 7. RETRO-AUDIT R15.
    minimums:
      - { count: 2, category: "Science" }
      - { count: 1, category: "Technical" }
    categories:')
 WHERE class_id = 'ley-line-walker' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'note: "Two of the seven must be from Science and one from Technical. Electrical, Mechanical and Military offer none and are omitted.',
       'note: "Two of the seven must be from Science and one from Technical. Both are carried as occ_related_skills.minimums since RETRO-AUDIT R15, so the wizard counts each floor and the server refuses a save that cannot reach them. They are two separate floors rather than one of three, and a floor is a minimum and not a cap - the remaining four picks may also be Science or Technical. The allowance grows with the schedule, so a character at level three is counted against nine picks rather than seven. Electrical, Mechanical and Military offer none and are omitted.')
 WHERE class_id = 'ley-line-walker' AND deleted_at IS NULL;

-- ---- ley-line-rifter -------------------------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 7
    categories:',
'  occ_related_skills:
    count: 7
    # RUE printed 117: "Ley Line Rifter Stats. Same as the Ley Line Walker",
    # whose printed 116 gives two Science and one Technical of the seven. Two
    # independent floors, not a union. RETRO-AUDIT R15.
    minimums:
      - { count: 2, category: "Science" }
      - { count: 1, category: "Technical" }
    categories:')
 WHERE class_id = 'ley-line-rifter' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'note: "Stats are the Ley Line Walker''s: two of the seven must be from Science and one from Technical. Paramedic counts as two skills.',
       'note: "Stats are the Ley Line Walker''s: two of the seven must be from Science and one from Technical. Both are carried as occ_related_skills.minimums since RETRO-AUDIT R15 and enforced on save, the same as on the Walker. They are two separate floors rather than one of three, and a floor is a minimum and not a cap - the remaining four picks may also be Science or Technical. Paramedic counts as two skills.')
 WHERE class_id = 'ley-line-rifter' AND deleted_at IS NULL;

-- ---- readbacks -------------------------------------------------------------
SELECT 'both classes hold two floors' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
   AND deleted_at IS NULL
   AND instr(markdown, 'count: 2, category: "Science"') > 0
   AND instr(markdown, 'count: 1, category: "Technical"') > 0;

-- TWO floors, not one of three. Asserted by the absence of a union spelling,
-- because a `categories: ["Science", "Technical"]` entry would satisfy the
-- readback above on a careless edit and mean something the book does not say.
SELECT 'neither floor was written as a union' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
   AND deleted_at IS NULL
   AND instr(markdown, 'categories: ["Science", "Technical"]') > 0;

SELECT 'both counts are unchanged at seven' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
   AND deleted_at IS NULL
   AND instr(markdown, 'occ_related_skills:' || char(10) || '    count: 7') > 0;

-- Both notes were rewritten. Asserted on a phrase unique to the NEW text: a
-- readback that greps the phrase it replaces matches its own replacement, which
-- is the trap R3, R6, R13 and R14 each hit.
SELECT 'both notes now name the mechanism' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
   AND deleted_at IS NULL
   AND instr(markdown, 'two separate floors rather than one of three') > 0;

-- THE INVERSE OF zzzzz-retro-r14-related-floors.sql's last assertion, which
-- asserted these two were untouched and which this script makes false. That
-- file also calls itself "safe to re-run"; it still is, but its readback now
-- prints got 2, want 0 on a rebuild. A one-shot script is not edited, so the
-- correction is stated here, three files later.
SELECT 'the two ley line classes are no longer untouched' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('ley-line-walker', 'ley-line-rifter')
   AND deleted_at IS NULL AND instr(markdown, 'minimums') > 0;

-- NOTHING ELSE GAINED A FLOOR. After this, 30 published classes hold one.
SELECT 'no other class was touched' AS assertion,
       count(*) AS got, 30 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'minimums:') > 0
   AND instr(markdown, 'attribute_minimums:') = 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r15-ley-line-floors.sql');
