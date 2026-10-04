-- Nine classes' rolled attribute and S.D.C. bonuses move out of prose and into
-- `bonuses`, where the sheet rolls them.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~075-dice-attribute-bonuses-nine-classes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~075-dice-attribute-bonuses-nine-classes.sql
--
-- `bonuses.attributes` and `bonuses.pools` have taken a dice string since
-- derive.js learned diceBonuses, and ~009-new-west-dice-and-horror-factor.sql
-- backfilled New West's classes on 2026-09-26. These nine were imported before
-- that, each with a special ability saying "a bonuses line takes a number, so
-- they are here", and were never revisited. Found by the retrospective sweep
-- of 2026-10-03.
--
-- NO FIGURE HERE IS READ FROM A BOOK. Every dice expression is the one the
-- class's own ability already states; this script moves it, and rewords the
-- sentence that said it could not be stored.
--
--   gypsy-beguiler          M.A. +1D4, P.B. +1D6+3
--   gypsy-enforcer          P.S. +1D6, Spd +1D6, S.D.C. +3D6 (a pool bonus)
--   gypsy-fortune-teller    M.A. +1D6, P.B. +1D4
--   gypsy-thief-russian     M.A. +1D4, Spd +1D6
--   old-believer            M.A. +1D6, P.E. +1D4
--   russian-mystic-kuznya   M.E. +1D4, M.A. +1D4
--   hidden-witch            P.B. +1D4
--   fq-deep-intel-agent     M.A. +1D4
--   gateway-knight          Spd +1D4+3
--
-- None of the nine has a `variants` block, so no second bonuses block restates
-- the first. Every UPDATE is guarded on the exact text it replaces: a re-run is
-- a no-op, and a row edited since cannot be hit. Production held no character
-- on any of them on 2026-10-03 except as checked in the PR body.
--
-- THIS SCRIPT CHANGES PRODUCTION: nine class rows. The tilde number is claimed
-- at merge.

-- == gypsy-beguiler ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  saves: { possession: 3, insanity: 3, horror_factor: 3, spell_magic: 1, ritual_magic: 1 }',
         'bonuses:' || char(10) || '  attributes: { MA: "1d4", PB: "1d6+3" }' || char(10) || '  saves: { possession: 3, insanity: 3, horror_factor: 3, spell_magic: 1, ritual_magic: 1 }'),
         '+1D4 to the M.A. attribute and +1D6+3 to P.B. Both are rolled and a bonuses line takes a number, so they are here.',
         '+1D4 to the M.A. attribute and +1D6+3 to P.B. Both are rolled by the sheet, from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-beguiler'
   AND instr(markdown, 'bonuses:' || char(10) || '  saves: { possession: 3, insanity: 3, horror_factor: 3, spell_magic: 1, ritual_magic: 1 }') > 0;

-- == gypsy-enforcer ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  attributes: { PP: 1, PE: 2 }' || char(10) || '  combat: { initiative: 3, pull_punch: 4 }',
         'bonuses:' || char(10) || '  attributes: { PP: 1, PE: 2, PS: "1d6", Spd: "1d6" }' || char(10) || '  pools: { sdc: "3d6" }' || char(10) || '  combat: { initiative: 3, pull_punch: 4 }'),
         'All three are rolled and a bonuses line takes a number, so they are here.',
         'All three are rolled by the sheet, from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { PP: 1, PE: 2 }' || char(10) || '  combat: { initiative: 3, pull_punch: 4 }') > 0;

-- == gypsy-fortune-teller ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  combat: { initiative: 1 }' || char(10) || '  saves: { possession: 3, horror_factor: 2,',
         'bonuses:' || char(10) || '  attributes: { MA: "1d6", PB: "1d4" }' || char(10) || '  combat: { initiative: 1 }' || char(10) || '  saves: { possession: 3, horror_factor: 2,'),
         '+1D6 to the M.A. attribute and +1D4 to P.B. Both are rolled and a bonuses line takes a number, so they are here.',
         '+1D6 to the M.A. attribute and +1D4 to P.B. Both are rolled by the sheet, from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-fortune-teller'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { initiative: 1 }' || char(10) || '  saves: { possession: 3, horror_factor: 2,') > 0;

-- == gypsy-thief-russian ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  attributes: { PP: 1 }' || char(10) || '  combat: { initiative: 2, dodge: 1, roll: 1, pull_punch: 3 }',
         'bonuses:' || char(10) || '  attributes: { PP: 1, MA: "1d4", Spd: "1d6" }' || char(10) || '  combat: { initiative: 2, dodge: 1, roll: 1, pull_punch: 3 }'),
         'Both are rolled and a bonuses line takes a number, so they are here.',
         'Both are rolled by the sheet, from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { PP: 1 }' || char(10) || '  combat: { initiative: 2, dodge: 1, roll: 1, pull_punch: 3 }') > 0;

-- == old-believer ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  saves: { possession: 9, horror_factor: 4, disease: 7, toxins_poisons: 3, curses: 6 }',
         'bonuses:' || char(10) || '  attributes: { MA: "1d6", PE: "1d4" }' || char(10) || '  saves: { possession: 9, horror_factor: 4, disease: 7, toxins_poisons: 3, curses: 6 }'),
         'Both are rolled and a bonuses line takes a number, so they are here.',
         'Both are rolled by the sheet, from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'old-believer'
   AND instr(markdown, 'bonuses:' || char(10) || '  saves: { possession: 9, horror_factor: 4, disease: 7, toxins_poisons: 3, curses: 6 }') > 0;

-- == russian-mystic-kuznya ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  attributes: { PE: 2 }' || char(10) || '  combat: { initiative: 1, strike: 1, parry: 1, disarm: 1, pull_punch: 6 }',
         'bonuses:' || char(10) || '  attributes: { PE: 2, ME: "1d4", MA: "1d4" }' || char(10) || '  combat: { initiative: 1, strike: 1, parry: 1, disarm: 1, pull_punch: 6 }'),
         'Both are rolled and a bonuses line takes a number, so they are here.',
         'Both are rolled by the sheet, from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { PE: 2 }' || char(10) || '  combat: { initiative: 1, strike: 1, parry: 1, disarm: 1, pull_punch: 6 }') > 0;

-- == hidden-witch ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  combat: { attacks: 1, initiative: 1 }' || char(10) || '  saves: { horror_factor: 4, possession: 4, spell_magic: 1, ritual_magic: 1 }',
         'bonuses:' || char(10) || '  attributes: { PB: "1d4" }' || char(10) || '  combat: { attacks: 1, initiative: 1 }' || char(10) || '  saves: { horror_factor: 4, possession: 4, spell_magic: 1, ritual_magic: 1 }'),
         '+1D4 to the P.B. attribute. A rolled bonus, so it is recorded here rather than as a fixed number in bonuses.',
         '+1D4 to the P.B. attribute, rolled by the sheet from bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'hidden-witch'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { attacks: 1, initiative: 1 }' || char(10) || '  saves: { horror_factor: 4, possession: 4, spell_magic: 1, ritual_magic: 1 }') > 0;

-- == fq-deep-intel-agent ==
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
         'bonuses:' || char(10) || '  attributes: { PP: 1 }' || char(10) || '  combat: { roll: 1, disarm: 2, pull_punch: 4 }',
         'bonuses:' || char(10) || '  attributes: { PP: 1, MA: "1d4" }' || char(10) || '  combat: { roll: 1, disarm: 2, pull_punch: 4 }'),
         '**The +1D4 to M.A. is rolled at creation and is not applied by the sheet.** The' || char(10)
           || 'book''s O.C.C. bonus line reads "+1D4 to M.A. and +1 to P.P. attribute". The +1' || char(10)
           || 'to P.P. is stored in `bonuses.attributes` and applies; the +1D4 cannot be, since' || char(10)
           || 'that block takes a fixed number rather than a dice expression. Roll it and add' || char(10)
           || 'it by hand at creation.',
         '**The +1D4 to M.A. is rolled by the sheet.** The' || char(10)
           || 'book''s O.C.C. bonus line reads "+1D4 to M.A. and +1 to P.P. attribute", and' || char(10)
           || 'both are stored in `bonuses.attributes`.'),
       updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent'
   AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { PP: 1 }' || char(10) || '  combat: { roll: 1, disarm: 2, pull_punch: 4 }') > 0;

-- == gateway-knight ==
UPDATE imported_classes
   SET markdown = replace(replace(replace(markdown,
         'bonuses:' || char(10) || '  attributes: { PS: 1, ME: 1, MA: 1, PP: 1 }',
         'bonuses:' || char(10) || '  attributes: { PS: 1, ME: 1, MA: 1, PP: 1, Spd: "1d4+3" }'),
         '+1D4+3 to Spd, on top of the fixed bonuses. A rolled bonus, so it lives here rather than in bonuses.',
         '+1D4+3 to Spd, on top of the fixed bonuses, rolled by the sheet from bonuses.'),
         'The Spd bonus is rolled and is prose.',
         'The Spd bonus is rolled, and is stored in bonuses.'),
       updated_at = datetime('now')
 WHERE class_id = 'gateway-knight'
   AND instr(markdown, 'bonuses:' || char(10) || '  attributes: { PS: 1, ME: 1, MA: 1, PP: 1 }') > 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the nine classes carry their dice in bonuses' AS assertion, count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE (class_id = 'gypsy-beguiler' AND instr(markdown, '  attributes: { MA: "1d4", PB: "1d6+3" }') > 0)
    OR (class_id = 'gypsy-enforcer' AND instr(markdown, '  attributes: { PP: 1, PE: 2, PS: "1d6", Spd: "1d6" }' || char(10) || '  pools: { sdc: "3d6" }') > 0)
    OR (class_id = 'gypsy-fortune-teller' AND instr(markdown, '  attributes: { MA: "1d6", PB: "1d4" }') > 0)
    OR (class_id = 'gypsy-thief-russian' AND instr(markdown, '  attributes: { PP: 1, MA: "1d4", Spd: "1d6" }') > 0)
    OR (class_id = 'old-believer' AND instr(markdown, '  attributes: { MA: "1d6", PE: "1d4" }') > 0)
    OR (class_id = 'russian-mystic-kuznya' AND instr(markdown, '  attributes: { PE: 2, ME: "1d4", MA: "1d4" }') > 0)
    OR (class_id = 'hidden-witch' AND instr(markdown, '  attributes: { PB: "1d4" }') > 0)
    OR (class_id = 'fq-deep-intel-agent' AND instr(markdown, '  attributes: { PP: 1, MA: "1d4" }') > 0)
    OR (class_id = 'gateway-knight' AND instr(markdown, 'PP: 1, Spd: "1d4+3" }') > 0);

SELECT 'none of the nine still says a bonuses line cannot hold dice' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gypsy-beguiler', 'gypsy-enforcer', 'gypsy-fortune-teller', 'gypsy-thief-russian', 'old-believer', 'russian-mystic-kuznya', 'hidden-witch', 'fq-deep-intel-agent', 'gateway-knight')
   AND instr(markdown, 'a bonuses line takes a number') + instr(markdown, 'rather than as a fixed number in bonuses') + instr(markdown, 'is not applied by the sheet.**') + instr(markdown, 'rather than in bonuses.') + instr(markdown, 'is rolled and is prose') > 0;

SELECT 'each of the nine still has exactly one bonuses block' AS assertion, count(*) AS got, 9 AS want
  FROM imported_classes
 WHERE class_id IN ('gypsy-beguiler', 'gypsy-enforcer', 'gypsy-fortune-teller', 'gypsy-thief-russian', 'old-believer', 'russian-mystic-kuznya', 'hidden-witch', 'fq-deep-intel-agent', 'gateway-knight')
   AND instr(markdown, char(10) || 'bonuses:' || char(10)) > 0
   AND instr(substr(markdown, instr(markdown, char(10) || 'bonuses:' || char(10)) + 9), char(10) || 'bonuses:' || char(10)) = 0;

INSERT INTO data_script_runs (filename) VALUES ('~075-dice-attribute-bonuses-nine-classes.sql');
