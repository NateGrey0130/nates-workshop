-- RETRO-AUDIT R13: the Assassin's two related-skill floors, and the release of
-- a control-set claim.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r13-assassin-minimums.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r13-assassin-minimums.sql
--
-- CLASS-AUDIT's "Checked and still true (do not fix these)" list says
-- occ_related_skills cannot span a constraint across two categories, naming the
-- assassin, the juicer-wannabe and the merc-soldier. Nate released that entry
-- for correction on 2026-09-04. Only the ASSASSIN half is fixed here, and the
-- audit of the release is the reason why - see the note in CLASS-AUDIT.md.
--
-- THE BOOK, read off the cache rather than off the class's own note. Palladium
-- Fantasy RPG printed 95 (pf cache p097, the registry's +2 offset):
--
--   "O.C.C. Related Skills: Select two espionage skills, two rogue or physical
--    skills and five other skills of choice (including additional skills from
--    espionage, rogue or physical) at level one, plus select one additional
--    skill at levels three, six, nine and twelve."
--
-- 2 + 2 + 5 = 9, which is the block's count, and the 3/6/9/12 schedule matches.
-- The parenthetical matters and the floor model handles it exactly: a floor is a
-- MINIMUM, not a cap, so the five free may also be espionage, rogue or physical.
--
-- TWO FLOORS, one single-category and one union. The union spelling is what the
-- released claim said was impossible; city-rat has carried one in production
-- since before this audit.
--
-- POSTURE: THIS ENFORCES. minimums is not a note. relatedFloorStatus feeds
-- _lib/validate-character.js, which pushes a `related_minimum` violation, and
-- characters.js answers HTTP 422 "This character breaks its class rules". The
-- Assassin moves from prose a player may ignore to a save that is refused.
-- Production holds ZERO assassin characters and zero drafts, checked on both
-- class_id and occ_class_id, so nothing live changes today.
--
-- THE REBUILD SOURCE ALSO CARRIES THE CLAIM. add-assassin-class.sql writes the
-- original sentence, so the note replacement below is what makes a rebuilt
-- database agree with production; this file sorts after it.
--
-- IT ALSO RETIRES A READBACK THAT WILL NOW PRINT THE WRONG THING.
-- zzzzz-retro-r11-remaining.sql asserts "the assassin control-set claim is
-- untouched ... want 1", which was correct when it ran and is false from here
-- on. A one-shot script is not edited, so the inverse is asserted at the foot of
-- this one, which sorts after it (r11 < r13). d1-apply PRINTS trailing SELECTs
-- rather than enforcing them, so the stale one costs a confusing line on a
-- fresh rebuild and nothing more - but it should not go unexplained.

UPDATE imported_classes
   SET markdown = replace(markdown,
'  occ_related_skills:
    count: 9
',
'  occ_related_skills:
    count: 9
    # PF printed 95: "two espionage skills, two rogue or physical skills and
    # five other skills of choice". Floors, not caps - the five free may also be
    # espionage, rogue or physical. RETRO-AUDIT R13.
    minimums:
      - { count: 2, category: "Espionage" }
      - { count: 2, categories: ["Physical", "Rogue"] }
')
 WHERE class_id = 'assassin'
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'occ_related_skills has one count and per-category limits and cannot express a constraint spanning two categories, so the count is 9 and both halves are stated in the category notes.',
       'occ_related_skills expresses both halves as minimums - a single-category floor of two Espionage and a UNION floor of two from Physical or Rogue - which the wizard counts and the server refuses a save without. The count stays 9 and the category notes stay, because a floor is a minimum rather than a cap and the five free picks may also come from those categories. This note said a constraint spanning two categories could not be expressed; that was on CLASS-AUDIT''s "Checked and still true" list until Nate released it on 2026-09-04. RETRO-AUDIT R13.')
 WHERE class_id = 'assassin'
   AND instr(markdown, 'cannot express a constraint spanning two categories') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the assassin carries both floors' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'assassin'
   AND instr(markdown, 'count: 2, category: "Espionage"') > 0
   AND instr(markdown, 'count: 2, categories: ["Physical", "Rogue"]') > 0;

-- THE INVERSE OF zzzzz-retro-r11-remaining.sql's assertion, which asserted this
-- claim was still present. It was, until this script. Stated here so a rebuild
-- that prints r11's "got 0, want 1" has the answer three files later.
SELECT 'the assassin claim is now RELEASED, inverting the r11 readback' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'assassin'
   AND instr(markdown, 'cannot express a constraint spanning two categories') > 0;

-- The floors are reachable: 2 + 2 = 4, well under the count of 9.
SELECT 'the count is unchanged at nine' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'assassin' AND instr(markdown, 'count: 9') > 0;

-- THE MERC-SOLDIER IS NOT TOUCHED, and this is the assertion that matters most.
-- Its either/or genuinely still cannot be expressed: it is "two W.P.s OR two
-- Demolition skills", an EXCLUSIVE or across Weapon Proficiencies and Military
-- (all three Demolition rows are category Military, checked --remote), and a
-- union floor would permit one of each, which the book forbids. It also lives in
-- a `mos` option rather than in occ_related_skills, where minimums does not
-- exist at all. RETRO-AUDIT R11 called it "entirely within one category", which
-- is wrong.
SELECT 'the merc-soldier claim is untouched and still true' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'merc-soldier'
   AND instr(markdown, 'a choice between two whole groups') > 0;

-- Five other classes carry an unexpressed related-skill floor and are NOT
-- touched here: knight, palladin, thief (single-category) and soldier, witch
-- (union). They are a separate finding rather than scope creep on a released
-- sentence - each would gain the same HTTP 422 enforcement.
SELECT 'the five other floor-carrying classes are untouched' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('knight', 'palladin', 'thief', 'soldier', 'witch')
   AND deleted_at IS NULL AND instr(markdown, 'minimums') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r13-assassin-minimums.sql');
