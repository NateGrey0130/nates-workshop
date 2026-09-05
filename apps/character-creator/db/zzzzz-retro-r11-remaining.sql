-- RETRO-AUDIT R11, the remaining six rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r11-remaining.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r11-remaining.sql
--
-- POSTURE, WHICH R11 DID NOT STATE AND WHICH IS HALF THE CHANGE:
--
--   * psi-mystic, apok, wormspeaker  - the picker offers a different set. No
--     save is refused that was accepted before.
--   * techno-wizard and the ten Warlocks - ENFORCEMENT. `minimums` is not a
--     note: relatedFloorStatus feeds validate-character.js, which pushes a
--     `related_minimum` violation, and characters.js answers HTTP 422 "This
--     character breaks its class rules". Eleven classes move from prose a
--     player may ignore to a save that is refused. That is the intended
--     reading of the printed rule, and it is a posture change worth naming.
--   * merc-soldier - prose only.
--
-- ROW 1 NEEDED AN APP CHANGE, shipped in the same PR. Giving an OCCUPATION
-- `powers_starting_groups` defeated the max-of-two composition rule: parser.js
-- takes the HIGHER of the race's and the occupation's `powers_starting`, but
-- the groups are carried by a plain spread so the occupation's win, and
-- startingGroups read only the groups. A chiang-ku-dragon (7) taking the
-- Psi-Mystic (5) silently dropped to 5. startingGroups now returns the surplus
-- as one more pick under the block's own gate. Measured before and after; no
-- class whose groups already sum to its count moves, which is all fourteen
-- carrying a starting-groups block today.
--
-- THE BOOK WAS RE-READ FOR ROW 1, because both R11 rows resolved so far moved
-- on one. Palladium Fantasy RPG, the Psi-Mystic's "Powers of the Psi-Mystic"
-- item 1 (pf cache p161, printed 159 - the entry runs 159-160 and the class
-- cites 160): "he gets to select three powers from the sensitive category and
-- two from either the physical or healing category." The split the class's own
-- note claimed is exactly right this time.
--
-- SIGNED DICE ARE A HARD PARSE ERROR, which is why rows 4 and 5 are written
-- without a sign. DICE_BONUS in js/parser.js is anchored on a digit, so
-- "+1d6" is rejected outright - loudly, not silently. "-1D4 Spd" and "P.B.
-- halved" therefore genuinely CANNOT be stored and stay in side_effects, which
-- is the half of the wormspeaker's claim that survives.
--
-- NOT TOUCHED, and each for a reason:
--   * `assassin`. Its cross-category rule IS expressible now, but the sentence
--     saying it is not sits on CLASS-AUDIT's "Checked and still true" list. A
--     control-set member is Nate's to release, not a sweep's. Recorded in the
--     RETRO-AUDIT R11 outcome note instead.
--   * `wolfen-quatoria`. It also mentions bonuses.attributes and its claim is
--     TRUE - the block ADDS to a rolled value, which is the wrong shape for a
--     fixed conversion attribute.
--   * The merc-soldier's GM Notes, which transcribe all seven packages in
--     prose beside the live skills.mos block. Cutting transcribed book text is
--     an import decision, not a note fix.

-- ---- 1. psi-mystic: three Sensitive, two Physical-or-Healing --------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       '  powers_starting: 5
  categories_allowed: ["Sensitive", "Physical", "Healing"]',
       '  powers_starting: 5
  # PF "Powers of the Psi-Mystic" item 1: "three powers from the sensitive
  # category and two from either the physical or healing category."
  # powers_starting stays the TOTAL; the groups split it. RETRO-AUDIT R11.
  powers_starting_groups:
    - { count: 3, categories: ["Sensitive"] }
    - { count: 2, categories: ["Physical", "Healing"] }
  categories_allowed: ["Sensitive", "Physical", "Healing"]')
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, 'powers_starting_groups') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'categories_allowed lists all three because the block cannot say three from one and two from the other two',
       'categories_allowed keeps all three as the union, and powers_starting_groups says the split - three Sensitive, two Physical-or-Healing. This note said the block could not until RETRO-AUDIT R11 (2026-09-04); the key landed with CLASS-AUDIT S9')
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, 'the block cannot say three from one') > 0;

-- ---- 2. techno-wizard: two of the seven from Electrical or Mechanical ------
UPDATE imported_classes
   SET markdown = replace(markdown,
       '    count: 7
    categories:
      - "Communications"',
       '    count: 7
    minimums:
      - { count: 2, categories: ["Electrical", "Mechanical"] }
    categories:
      - "Communications"')
 WHERE class_id = 'techno-wizard'
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'two of the seven must be Electrical or Mechanical - a
    composition constraint the count field cannot express; noted.',
       'two of the seven must be Electrical or Mechanical, and
    occ_related_skills.minimums says so as a union floor - the wizard counts
    it and the server refuses a save that cannot meet it. This note said the
    count field could not express it until RETRO-AUDIT R11 (2026-09-04); the
    floor is not the count, and city-rat carried the same union spelling.')
 WHERE class_id = 'techno-wizard'
   AND instr(markdown, 'the count field cannot express; noted') > 0;

-- ---- 3. the ten Warlocks: two of the eight from Wilderness or Domestic -----
UPDATE imported_classes
   SET markdown = replace(markdown,
       '    count: 8
    categories:
      - "Communications"',
       '    count: 8
    minimums:
      - { count: 2, categories: ["Wilderness", "Domestic"] }
    categories:
      - "Communications"')
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'minimums') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'TWO of the eight must be from Wilderness or Domestic - a composition constraint the count field cannot express.',
       'TWO of the eight must be from Wilderness or Domestic, and occ_related_skills.minimums says so as a union floor - the wizard counts it and the server refuses a save that cannot meet it. This note said the count field could not express it until RETRO-AUDIT R11 (2026-09-04). Inherited from the generic Warlock when R3 generated these ten.')
 WHERE class_id LIKE 'warlock-%' AND deleted_at IS NULL
   AND instr(markdown, 'the count field cannot express.') > 0;

-- ---- 4. apok: the +2D6 P.S. and +3D6 Spd the book gives --------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       '  pools: { mdc: 200 }',
       '  attributes: { PS: "2d6", Spd: "3d6" }
  pools: { mdc: 200 }')
 WHERE class_id = 'apok'
   AND instr(markdown, 'attributes: { PS: "2d6", Spd: "3d6" }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'Attribute bonuses are NOT stored. The book gives +2D6 to P.S. and +3D6 to Spd, and bonuses.attributes takes flat numbers only - storing an average would put a figure in the sheet that the book never prints.',
       'Attribute bonuses ARE stored, as dice: bonuses.attributes takes a dice expression and rolls it once at creation, so the sheet carries what this character rolled rather than an average the book never prints. This note said the block took flat numbers only, which stopped being true before it was written - RETRO-AUDIT R11, 2026-09-04, and R6 made the same correction on the freelancer.')
 WHERE class_id = 'apok'
   AND instr(markdown, 'bonuses.attributes takes flat numbers only') > 0;

-- ---- 5. wormspeaker: the +1D6 M.E. and +1D4 M.A. --------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       '  attributes: { PS: -2, PP: -2 }',
       '  attributes: { PS: -2, PP: -2, ME: "1d6", MA: "1d4" }')
 WHERE class_id = 'wormspeaker'
   AND instr(markdown, 'ME: "1d6"') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'Attribute changes: only the FLAT ones are stored, -2 P.S. and -2 P.P. The bonuses (+1D6 M.E., +1D4 M.A.) and the remaining penalties (P.B. halved, -1D4 Spd) are dice or percentages that bonuses.attributes cannot take, so they stay in side_effect',
       'Attribute changes: the flat ones and the POSITIVE dice are stored - -2 P.S., -2 P.P., +1D6 M.E. and +1D4 M.A. This note said bonuses.attributes could take none of the dice, which was false for the positive ones (RETRO-AUDIT R11, 2026-09-04). The remaining penalties (P.B. halved, -1D4 Spd) genuinely cannot be stored: DICE_BONUS in js/parser.js is anchored on a digit, so a signed expression is rejected outright, and there is no halving mechanic. Those stay in side_effect')
 WHERE class_id = 'wormspeaker'
   AND instr(markdown, 'are dice or percentages that bonuses.attributes cannot take') > 0;

-- ---- 6. merc-soldier: a note never rewritten when its own mos block landed -
UPDATE imported_classes
   SET markdown = replace(markdown,
       '  - The MOS system (pick one of seven skill packages, or roll percentile) has
    no schema shape - a package choice is neither a skill choice-group nor a
    variant. The full seven packages are transcribed in GM Notes and the
    restriction above says to apply one by hand.',
       '  - The MOS system (pick one of seven skill packages, or roll percentile) IS
    the schema shape skills.mos, and this class carries it - seven options
    under `mos: choose: 1`, which the wizard offers and compose.js folds into
    occ_skills on the pick. This note said there was no shape and that the
    restriction above says to apply one by hand; BOTH were false by the time
    anyone read them - the restriction says the opposite, and has since
    fix-merc-soldier-and-robot-pilot-mos.sql. RETRO-AUDIT R11, 2026-09-04.
    The GM Notes still transcribe all seven packages in prose beside the live
    block; that duplication is left alone deliberately, being an import
    decision rather than a note fix.')
 WHERE class_id = 'merc-soldier'
   AND instr(markdown, 'no schema shape - a package choice') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'psi-mystic splits its starting powers three and two' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, 'count: 3, categories: ["Sensitive"]') > 0
   AND instr(markdown, 'count: 2, categories: ["Physical", "Healing"]') > 0
   AND instr(markdown, 'powers_starting: 5') > 0;

SELECT 'techno-wizard and the ten Warlocks carry a union floor' AS assertion,
       count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (class_id = 'techno-wizard' OR class_id LIKE 'warlock-%')
   AND instr(markdown, 'minimums:') > 0;

SELECT 'apok and wormspeaker store their positive dice' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'apok' AND instr(markdown, 'PS: "2d6", Spd: "3d6"') > 0)
    OR (class_id = 'wormspeaker' AND instr(markdown, 'ME: "1d6", MA: "1d4"') > 0);

-- Matched on the OLD wording, which no replacement reproduces, and SCOPED to
-- the classes this script edits.
--
-- Unscoped it fails, and the reason is worth keeping: `promethean-phase-adept`
-- contains the phrase "bonuses.attributes takes flat numbers only" because its
-- own note QUOTES the apok's claim in order to refute it - "The Apok's note
-- says bonuses.attributes takes flat numbers only; that has not been true since
-- the Godling's +1D4 initiative". The repo held the refutation before R11 filed
-- the finding. That is the readback-quotes-its-own-phrase trap arriving in a
-- THIRD class's note rather than in the replacement text, and it is why this
-- assertion names its classes.
SELECT 'no class still denies one of these four capabilities' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (class_id IN ('psi-mystic', 'techno-wizard', 'apok', 'wormspeaker', 'merc-soldier')
        OR class_id LIKE 'warlock-%')
   AND (instr(markdown, 'the block cannot say three from one') > 0
     OR instr(markdown, 'the count field cannot express') > 0
     OR instr(markdown, 'bonuses.attributes takes flat numbers only') > 0
     OR instr(markdown, 'dice or percentages that bonuses.attributes cannot take') > 0
     OR instr(markdown, 'no schema shape - a package choice') > 0);

-- The assassin's sentence is UNTOUCHED. It is a control-set member on
-- CLASS-AUDIT's "Checked and still true" list, and releasing one is Nate's.
SELECT 'the assassin control-set claim is untouched' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'assassin'
   AND instr(markdown, 'cannot express a constraint spanning two categories') > 0;

-- wolfen-quatoria's bonuses.attributes claim is TRUE and is untouched.
SELECT 'wolfen-quatoria is untouched' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'wolfen-quatoria' AND instr(markdown, 'bonuses.attributes') > 0;

-- Every floor is reachable: 2 <= the class's own related-skill count.
SELECT 'no floor exceeds the count it sits in' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'minimums:') > 0
   AND instr(markdown, 'count: 2, categories:') > 0
   AND instr(markdown, 'count: 7') = 0 AND instr(markdown, 'count: 8') = 0
   AND instr(markdown, 'count: 10') = 0 AND instr(markdown, 'count: 9') = 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r11-remaining.sql');
