-- The Ley Line Rifter drops its attribute-of-choice bonus (class audit F19,
-- 2026-08-26 - the Walker half only).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-walker-rifter-attribute-choice.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-walker-rifter-attribute-choice.sql
--
-- The book (RUE printed 117, re-read from the OCR cache): "+2 on any one
-- Physical attribute (P.S., P.P., P.E., P.B. or Spd.)". The finding named
-- both the Walker and the Rifter; a fresh --remote pull shows the WALKER
-- already carries its three-fragment choose-1 group and a correct note, so
-- only the Rifter's half remained. The shape below is the walker's own
-- (special_abilities fragments each carrying `bonuses`, behind a choose-1
-- group - ABILITY_GRANTS, the Godling precedent), and the two rifter notes
-- that called the choice inexpressible come out in the same script. The
-- Spell Strength schedules genuinely stay prose.
--
-- Filename sort: fix-walker-rifter-attribute-choice > add-ley-line-rifter,
-- fix-perception-bonuses and fix-rue-pool-attribute-terms, the writers of
-- the rifter regions this touches ('w' sorts after everything but zz-*,
-- which never touch these lines). Named per the audit sketch even though
-- only the rifter half executes.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- The choice group, inserted ahead of the restrictions block.
UPDATE imported_classes
SET markdown = replace(markdown,
      'restrictions:' || char(10) || '  - "O.C.C. bonuses beyond the modeled saves:',
      'special_abilities:' || char(10)
        || '  - name: "Physical Attribute Bonus (P.S.)"' || char(10)
        || '    description: "+2 to P.S. The book grants +2 to one Physical attribute of the player''s choice."' || char(10)
        || '    bonuses: { attributes: { PS: 2 } }' || char(10)
        || '  - name: "Physical Attribute Bonus (P.P.)"' || char(10)
        || '    description: "+2 to P.P. The book grants +2 to one Physical attribute of the player''s choice."' || char(10)
        || '    bonuses: { attributes: { PP: 2 } }' || char(10)
        || '  - name: "Physical Attribute Bonus (P.E.)"' || char(10)
        || '    description: "+2 to P.E. The book grants +2 to one Physical attribute of the player''s choice."' || char(10)
        || '    bonuses: { attributes: { PE: 2 } }' || char(10)
        || '  - name: "Physical Attribute Bonus (P.B.)"' || char(10)
        || '    description: "+2 to P.B. The book grants +2 to one Physical attribute of the player''s choice."' || char(10)
        || '    bonuses: { attributes: { PB: 2 } }' || char(10)
        || '  - name: "Physical Attribute Bonus (Spd)"' || char(10)
        || '    description: "+2 to Spd. The book grants +2 to one Physical attribute of the player''s choice."' || char(10)
        || '    bonuses: { attributes: { Spd: 2 } }' || char(10)
        || '  - { choose: 1, from: ["Physical Attribute Bonus (P.S.)", "Physical Attribute Bonus (P.P.)", "Physical Attribute Bonus (P.E.)", "Physical Attribute Bonus (P.B.)", "Physical Attribute Bonus (Spd)"] }' || char(10)
        || 'restrictions:' || char(10) || '  - "O.C.C. bonuses beyond the modeled saves:'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, 'Physical Attribute Bonus (P.S.)') = 0;

-- The restriction note stops claiming the choice is by-hand.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - "O.C.C. bonuses beyond the modeled saves: +2 on one Physical attribute of choice (P.S., P.P., P.E., P.B. or Spd), +1 to Spell Strength at levels 3, 7, 10 and 13 - chosen or applied by hand. The +2 Perception is now modeled as combat.perception."',
      '  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels 3, 7, 10 and 13 - applied by hand. The +2 Perception is modeled as combat.perception, and the +2 on one Physical attribute of choice is a special_abilities choice group (class audit F19)."'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, 'or Spd), +1 to Spell Strength at levels 3, 7, 10 and 13 - chosen or applied by hand.') > 0;

-- And the extraction note that said the schema cannot express it comes out.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - "+2 on any one Physical attribute" is a player choice the bonus schema' || char(10)
        || '    cannot express; recorded under restrictions for visibility.',
      '  - The "+2 on any one Physical attribute" choice is modeled as a' || char(10)
        || '    special_abilities choose-1 group granting the bonus, the walker''s own' || char(10)
        || '    shape (class audit F19).'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, 'is a player choice the bonus schema') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the rifter carries all five fragments and the group
--   walker_ok    1 = the walker still carries its own group (untouched)
--   old_left     0 = no by-hand or cannot-express claim left on the rifter
--   cr_free      2 = both classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'ley-line-rifter'
          AND instr(markdown, '  - { choose: 1, from: ["Physical Attribute Bonus (P.S.)"') > 0
          AND instr(markdown, 'bonuses: { attributes: { Spd: 2 } }') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'ley-line-walker'
          AND instr(markdown, '  - { choose: 1, from: ["Mental Attribute Bonus (I.Q.)"') > 0) AS walker_ok,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'ley-line-rifter'
          AND (instr(markdown, 'chosen or applied by hand') > 0
            OR instr(markdown, 'is a player choice the bonus schema') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('ley-line-rifter', 'ley-line-walker')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-walker-rifter-attribute-choice.sql');
