-- RETRO-AUDIT R9: the Crazy gets the +3 Perception the book gives it.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r9-crazy-perception.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r9-crazy-perception.sql
--
-- WHAT WAS WRONG. Rifts Ultimate Edition, printed 55 (rue cache p058, the
-- registry's +3 offset), M.O.M. Induced Abilities item 5:
--
--   "Enhanced Senses: +3 on Perception Rolls even when acting silly and
--    bouncing around, or seemingly bored. Very alert."
--
-- The class carried the whole of items 1-4 correctly - initiative 2, attacks 1,
-- roll 4, the PP/PE/PS/Spd dice and the P.S. 19 / P.P. 17 minimums all match the
-- page - and dropped the Perception from item 5. It was in the ability's prose
-- and in no bonus key.
--
-- IT IS UNCONDITIONAL, which is why it belongs in `bonuses` rather than in an
-- applies_when entry: the book's own clause "even when acting silly and
-- bouncing around, or seemingly bored" is there precisely to say the bonus never
-- lapses.
--
-- combat.perception is a real key - js/derive.js deriveCombat states it at 0 so
-- a class bonus has a base to add to, and sheet.js renders the row.
-- CLASS-AUDIT F8 granted it to twelve classes in fix-perception-bonuses.sql and
-- named three deliberate exclusions; the Crazy was on NEITHER list, so nothing
-- recorded whether it had been considered and skipped or simply missed. The
-- page says missed.
--
-- HOW IT WAS FOUND: not by any of RETRO-AUDIT's four detectors. It surfaced
-- while audit-premise-auditor was checking R1, because a prose-only PR is
-- exactly the PR that walks past a missing mechanic. It was filed under
-- "Not established" pending this page read.

UPDATE imported_classes
   SET markdown = replace(markdown,
       'combat: { initiative: 2, attacks: 1, roll: 4 }',
       'combat: { initiative: 2, attacks: 1, roll: 4, perception: 3 }')
 WHERE class_id = 'crazy'
   AND instr(markdown, 'combat: { initiative: 2, attacks: 1, roll: 4 }') > 0;

-- The ability's prose said the bonus was there; now it also says where it is,
-- so the next reader does not re-add it.
UPDATE imported_classes
   SET markdown = replace(markdown,
       '+3 on Perception Rolls even when acting silly and bouncing around, or seemingly bored.',
       '+3 on Perception Rolls even when acting silly and bouncing around, or seemingly bored - unconditional, and stored as bonuses.combat.perception since RETRO-AUDIT R9 (2026-09-04).')
 WHERE class_id = 'crazy'
   AND instr(markdown, 'or seemingly bored.') > 0
   AND instr(markdown, 'stored as bonuses.combat.perception') = 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the crazy carries combat.perception' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'crazy' AND instr(markdown, 'perception: 3') > 0;

-- The rest of the combat block is untouched: this adds one key and moves
-- nothing. Matched on the three values that were already right.
SELECT 'the other three combat bonuses are unchanged' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'crazy'
   AND instr(markdown, 'initiative: 2, attacks: 1, roll: 4') > 0;

-- The attribute dice and minimums the page also states are still there, so a
-- readback proves nothing else in this class moved.
SELECT 'the attribute dice and minimums are unchanged' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'crazy'
   AND instr(markdown, 'PS: "2d4", Spd: "4d6", PP: "1d6", PE: "1d6"') > 0
   AND instr(markdown, 'attribute_minimums: { PS: 19, PP: 17 }') > 0;

-- Records this run. Both statements guard themselves, so this script is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r9-crazy-perception.sql');
