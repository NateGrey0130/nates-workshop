-- Dropped Perception bonuses across the audit's class list (class audit F8,
-- 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-perception-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-perception-bonuses.sql
--
-- combat.perception is a modeled bonus key - derive.js folds it, and
-- rogue-scholar (+5) and vagabond (+4) carry it in production - but these
-- classes' books print a Perception bonus that never made it in. Each line
-- re-read from the OCR cache before writing:
--
--   body-fixer      +2  RUE printed 87 ("+2 on most Perception Rolls"; the
--                       +4 medical-context half is conditional, stays prose)
--   burster         +1  printed 141   city-rat       +3  printed 88
--   dog-boy         +5  printed 146   juicer         +2  printed 79
--   mind-melter     +3  printed 151   headhunter     +2  printed 76
--   rogue-scientist +4  printed 96    ley-line-rifter +2 printed 117
--   mystic          +1 at levels 1, 3, 6, 8, 10, 12 and 14 (printed 119) -
--                       base combat.perception: 1 plus an at_level schedule;
--                       the doubling on a ley line stays prose
--
-- Cyber-knight (+3), operator (+2) and wilderness-scout (+3) got theirs in
-- F5/F7/F3. The Juicer sub-classes and the juicer's +2 disarm are F14 -
-- only the juicer's own perception lands here. Conditional bonuses
-- (elemental fusionist "in the wild", techno-wizard "involving machines",
-- headhunter's called-shot disarm) correctly stay prose.
--
-- Several classes' own notes claim the bonus has no key or is "applied by
-- hand" - false since the perception key landed - so those sentences are
-- rewritten in the same script (the claim-audit rule; CLASS-AUDIT.md S3).
-- Dog-boy's note rewrite covers the disease and disarm halves too: those
-- fixes land in fix-disease-saves.sql, which sorts BEFORE this file, so one
-- rewrite from original text to final text is correct in both apply order
-- and clean-rebuild order - and dog-boy's combat guard below expects the
-- disarm that script adds.
--
-- Filename sort: fix-perception-bonuses > every add-*-class.sql, >
-- fix-disease-saves ('d' < 'p'), and > fix-juicer-rue-edition ('j' < 'p'),
-- the last writer of the juicer's combat line and note. The later fix-*
-- (fix-pre-rue-class-audit: other classes; fix-psychic-save-target-notes:
-- save-target prose; fix-rue-*: other regions) and zz- scripts never touch
-- these lines.
--
-- Safe to run twice: every statement finds nothing to replace on a re-run.

-- Body Fixer: +2 joins the combat block; the note claiming no key exists is
-- rewritten to say what is modeled and what stays conditional prose.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { dodge: 1, disarm: 1 }',
      '  combat: { dodge: 1, disarm: 1, perception: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'body-fixer'
  AND instr(markdown, '  combat: { dodge: 1, disarm: 1 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - The "O.C.C. Bonuses" perception bonus (+2 most Perception Rolls, +4 for' || char(10)
        || '    medical/drug/poison-related Perception Rolls) is conditional and recorded' || char(10)
        || '    only in prose per the schema''s rule against unconditional Perception bonuses' || char(10)
        || '    (no Perception key exists in the bonuses schema in any case).',
      '  - The "O.C.C. Bonuses" perception line is split: the flat +2 on most' || char(10)
        || '    Perception Rolls is modeled as combat.perception (class audit F8); the +4' || char(10)
        || '    for medical/drug/poison-related Perception Rolls is conditional and stays' || char(10)
        || '    prose, per the rule that conditional bonuses are prose.'),
    updated_at = datetime('now')
WHERE class_id = 'body-fixer'
  AND instr(markdown, '(no Perception key exists in the bonuses schema in any case).') > 0;

-- Burster: +1 joins the combat block; the restriction note keeps only its
-- spicy-food half, and the false extraction note comes out.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 2, strike: 1, pull_punch: 2, roll: 2 }',
      '  combat: { initiative: 2, strike: 1, pull_punch: 2, roll: 2, perception: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'burster'
  AND instr(markdown, '  combat: { initiative: 2, strike: 1, pull_punch: 2, roll: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - "O.C.C. bonuses beyond the modeled ones: +1 on Perception Rolls, and loves hot, spicy foods - can eat them without any adverse effect."',
      '  - "Loves hot, spicy foods - can eat them without any adverse effect."'),
    updated_at = datetime('now')
WHERE class_id = 'burster'
  AND instr(markdown, 'beyond the modeled ones: +1 on Perception Rolls') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      char(10) || '  - +1 Perception has no bonus key and sits in restrictions.',
      ''),
    updated_at = datetime('now')
WHERE class_id = 'burster'
  AND instr(markdown, '  - +1 Perception has no bonus key and sits in restrictions.') > 0;

-- City Rat: the empty combat block gets its +3; the note's false halves
-- (perception "not a tracked pool/save") are rewritten. The Spd die-add
-- stays prose - expressible these days, so a decision to revisit rather
-- than a schema limit, and not part of this finding. The old text carries
-- an em-dash, spliced as char(8212) to keep this file pure ASCII.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: {}',
      '  combat: { perception: 3 }'),
    updated_at = datetime('now')
WHERE class_id = 'city-rat'
  AND instr(markdown, '  combat: {}' || char(10)) > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      'the character reaches age 22)." Spd and Perception bonuses have no clean' || char(10)
        || '    home in the bonuses schema (Spd is an attribute die-add, not covered by' || char(10)
        || '    the pools/attributes number-only convention for a roll applied post-chargen,' || char(10)
        || '    and Perception Rolls is not a tracked pool/save) ' || char(8212) || ' recorded here as prose' || char(10)
        || '    rather than forced into a field: +1D6+1 to Spd attribute, +3 on Perception' || char(10)
        || '    Rolls. The P.P.E. bonus',
      'the character reaches age 22)." The +3 Perception is modeled as' || char(10)
        || '    combat.perception (class audit F8). The +1D6+1 Spd die-add stays prose' || char(10)
        || '    for now - attribute dice bonuses are expressible these days, so it is a' || char(10)
        || '    decision to revisit rather than a schema limit. The P.P.E. bonus'),
    updated_at = datetime('now')
WHERE class_id = 'city-rat'
  AND instr(markdown, 'and Perception Rolls is not a tracked pool/save)') > 0;

-- Dog Boy: +5 joins the combat line fix-disease-saves.sql produced (with
-- the disarm); the restriction note keeps only its endurance half and the
-- false extraction note comes out.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2, disarm: 2 }',
      '  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2, disarm: 2, perception: 5 }'),
    updated_at = datetime('now')
WHERE class_id = 'dog-boy'
  AND instr(markdown, '  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 2, disarm: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - "O.C.C. bonuses beyond the modeled ones: +5 on Perception Rolls, +2 to disarm, +2 to save vs disease. Physical endurance is twice a human''s; a P.S. under 17 carries 20 times P.S. in pounds, 17 or higher carries 40 times."',
      '  - "Physical endurance is twice a human''s; a P.S. under 17 carries 20 times P.S. in pounds, 17 or higher carries 40 times."'),
    updated_at = datetime('now')
WHERE class_id = 'dog-boy'
  AND instr(markdown, 'beyond the modeled ones: +5 on Perception Rolls') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      char(10) || '  - +5 Perception, +2 disarm and +2 vs disease have no bonus key and sit in' || char(10) || '    restrictions.',
      ''),
    updated_at = datetime('now')
WHERE class_id = 'dog-boy'
  AND instr(markdown, '  - +5 Perception, +2 disarm and +2 vs disease have no bonus key') > 0;

-- Juicer: +2 joins the combat block (the juicer only - the sub-classes and
-- the +2 disarm are F14); the note is rewritten to say so.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }',
      '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2, perception: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, '  combat: { initiative: 4, attacks: 2, roll: 3, pull_punch: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - +2 Perception, +2 disarm and the auto-dodge progression have no bonus key' || char(10)
        || '    and live in the Super-Reflexes description.',
      '  - The +2 Perception is modeled as combat.perception (class audit F8). The' || char(10)
        || '    +2 disarm is not yet applied (F14 covers it with the Juicer sub-classes);' || char(10)
        || '    the auto-dodge progression stays prose in the Super-Reflexes description.'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, '  - +2 Perception, +2 disarm and the auto-dodge progression have no bonus key') > 0;

-- Mind Melter: +3 joins the combat block.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 3, strike: 1, pull_punch: 2, disarm: 2 }',
      '  combat: { initiative: 3, strike: 1, pull_punch: 2, disarm: 2, perception: 3 }'),
    updated_at = datetime('now')
WHERE class_id = 'mind-melter'
  AND instr(markdown, '  combat: { initiative: 3, strike: 1, pull_punch: 2, disarm: 2 }') > 0;

-- Headhunter: +2 joins the combat block; the restriction note keeps only
-- the conditional called-shot disarm, and the extraction note says what is
-- modeled now.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { initiative: 1, pull_punch: 3, roll: 3 }',
      '  combat: { initiative: 1, pull_punch: 3, roll: 3, perception: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, '  combat: { initiative: 1, pull_punch: 3, roll: 3 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - "+2 on Perception Rolls, and +1 to disarm on a Called Shot with any Weapon Proficiency - applied by hand."',
      '  - "+1 to disarm on a Called Shot with any Weapon Proficiency - conditional, applied by hand."'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, '  - "+2 on Perception Rolls, and +1 to disarm on a Called Shot') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    Perception and called-shot disarm have no key and sit in restrictions.',
      '    The +2 Perception is modeled as combat.perception (class audit F8); the' || char(10)
        || '    called-shot disarm is conditional and stays prose.'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, '    Perception and called-shot disarm have no key and sit in restrictions.') > 0;

-- Rogue Scientist: the empty combat block gets its +4.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  combat: { }',
      '  combat: { perception: 4 }'),
    updated_at = datetime('now')
WHERE class_id = 'rogue-scientist'
  AND instr(markdown, '  combat: { }' || char(10)) > 0;

-- Ley Line Rifter: a combat block joins the bonuses (it had none); the
-- note keeps its attribute-of-choice and Spell Strength halves.
UPDATE imported_classes
SET markdown = replace(markdown,
      'bonuses:' || char(10) || '  saves: { horror_factor: 5, possession: 3, mind_control: 2, curses: 2 }',
      'bonuses:' || char(10) || '  combat: { perception: 2 }' || char(10) || '  saves: { horror_factor: 5, possession: 3, mind_control: 2, curses: 2 }'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, 'bonuses:' || char(10) || '  saves: { horror_factor: 5, possession: 3, mind_control: 2, curses: 2 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      ', and +2 on Perception Rolls - chosen or applied by hand."',
      ' - chosen or applied by hand. The +2 Perception is now modeled as combat.perception."'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, ', and +2 on Perception Rolls - chosen or applied by hand."') > 0;

-- Mystic: base +1 at level 1 (a combat block joins the bonuses), the
-- at_level schedule carries the +1 at 3, 6, 8, 10, 12 and 14, and the note
-- keeps only the ley-line doubling as prose. classBonuses folds every
-- entry at or below the level, so entries sharing a level with the
-- existing save steps stack correctly.
UPDATE imported_classes
SET markdown = replace(markdown,
      'bonuses:' || char(10) || '  saves: { horror_factor: 4, possession: 2, spell_magic: 1, ritual_magic: 1 }',
      'bonuses:' || char(10) || '  combat: { perception: 1 }' || char(10) || '  saves: { horror_factor: 4, possession: 2, spell_magic: 1, ritual_magic: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'mystic'
  AND instr(markdown, 'bonuses:' || char(10) || '  saves: { horror_factor: 4, possession: 2, spell_magic: 1, ritual_magic: 1 }') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1, psionics: 1, mind_control: 1, possession: 1 } }' || char(10) || 'skills:',
      '    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1, psionics: 1, mind_control: 1, possession: 1 } }' || char(10)
        || '    - { level: 3, combat: { perception: 1 } }' || char(10)
        || '    - { level: 6, combat: { perception: 1 } }' || char(10)
        || '    - { level: 8, combat: { perception: 1 } }' || char(10)
        || '    - { level: 10, combat: { perception: 1 } }' || char(10)
        || '    - { level: 12, combat: { perception: 1 } }' || char(10)
        || '    - { level: 14, combat: { perception: 1 } }' || char(10)
        || 'skills:'),
    updated_at = datetime('now')
WHERE class_id = 'mystic'
  AND instr(markdown, 'possession: 1 } }' || char(10) || 'skills:') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
      '; +1 on Perception Rolls at levels 1, 3, 6, 8, 10, 12 and 14, double when on a ley line."',
      '. The +1 Perception at levels 1, 3, 6, 8, 10, 12 and 14 is modeled (base plus at_level); only the doubling when on a ley line stays prose."'),
    updated_at = datetime('now')
WHERE class_id = 'mystic'
  AND instr(markdown, '+1 on Perception Rolls at levels 1, 3, 6, 8, 10, 12 and 14, double when on a ley line."') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed       10 = each class carries its perception number
--   sched_ok     1 = mystic carries the level-14 schedule entry
--   notes_left   0 = no trace of any of the false "no bonus key" sentences
--   cr_free     10 = all ten touched classes still carry no CR
SELECT (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'burster', 'city-rat', 'dog-boy', 'juicer', 'mind-melter', 'headhunter-techno-warrior', 'rogue-scientist', 'ley-line-rifter', 'mystic')
            AND (instr(markdown, 'disarm: 1, perception: 2 }') > 0
              OR instr(markdown, 'roll: 2, perception: 1 }') > 0
              OR instr(markdown, '  combat: { perception: 3 }') > 0
              OR instr(markdown, 'disarm: 2, perception: 5 }') > 0
              OR instr(markdown, 'pull_punch: 2, perception: 2 }') > 0
              OR instr(markdown, 'disarm: 2, perception: 3 }') > 0
              OR instr(markdown, 'roll: 3, perception: 2 }') > 0
              OR instr(markdown, '  combat: { perception: 4 }') > 0
              OR instr(markdown, '  combat: { perception: 2 }' || char(10) || '  saves: { horror_factor: 5') > 0
              OR instr(markdown, '  combat: { perception: 1 }' || char(10) || '  saves: { horror_factor: 4') > 0)) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'mystic'
          AND instr(markdown, '    - { level: 14, combat: { perception: 1 } }') > 0) AS sched_ok,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'burster', 'city-rat', 'dog-boy', 'juicer', 'mind-melter', 'headhunter-techno-warrior', 'rogue-scientist', 'ley-line-rifter', 'mystic')
            AND (instr(markdown, 'no bonus key') > 0
              OR instr(markdown, 'no Perception key exists') > 0
              OR instr(markdown, 'not a tracked pool/save') > 0
              OR instr(markdown, 'have no key and sit in restrictions') > 0
              OR instr(markdown, 'and +2 on Perception Rolls - chosen or applied by hand') > 0
              OR instr(markdown, '+1 on Perception Rolls at levels 1, 3, 6, 8, 10, 12 and 14, double') > 0)) AS notes_left,
       (SELECT count(*) FROM imported_classes
          WHERE class_id IN ('body-fixer', 'burster', 'city-rat', 'dog-boy', 'juicer', 'mind-melter', 'headhunter-techno-warrior', 'rogue-scientist', 'ley-line-rifter', 'mystic')
            AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-perception-bonuses.sql');
