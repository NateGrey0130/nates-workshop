-- Five pick-one ability groups name their percentile band the way the wizard's
-- Roll d100 button reads it.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~074-roll-bands-on-five-pick-one-groups.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~074-roll-bands-on-five-pick-one-groups.sql
--
-- The Roll d100 button (PR #1602, 2026-10-01) reads a band out of each
-- option's NAME: abilityRollBands() in js/parser.js matches "(NN-NN)" and
-- offers the button only when the banded options cover 1 to 100. Five classes
-- hold a choose-1 group for a table their book rolls, with the band or the
-- percentage in the name in a shape that pattern does not match, so the group
-- works and the button never appears. Measured 2026-10-03 by running
-- abilityRollBands() over every published class in production: twelve groups
-- rollable, these five not.
--
--   gifted-one-russian   "The Gift: Major, 01-25"            no parentheses
--   momano-headhunter    "Psionics 01-50: None"              no parentheses
--   ramen                "Ramen Mystic (01-40%)"             a % inside them
--   agogwe               "Minor Psionic (60%)"               a share, not a band
--   crocodillian         "Psionic Type: Master Psionic (85%)" a share, not a band
--
-- The bands written here are the ones each class already states: the Agogwe
-- and Crocodillian descriptions give them (01-60, 61-97, 98-00 and 01-85,
-- 86-95, 96-00), and the other three carry them in the old names. No figure
-- is read from a book by this script.
--
-- Each name occurs exactly twice in its class, once in the group's `from`
-- list and once as the ability's own `name`, so one replace() moves both and
-- they cannot disagree. A character stores a pick by ability NAME; production
-- held no character on any of the five classes on 2026-10-03 (q.mjs --remote
-- over characters.class_id and occ_class_id), so no pick is orphaned.
--
-- Three sentences that said the app cannot roll the table are corrected in the
-- same pass, the Gypsy Gifted's among them: its options were already banded.
--
-- THIS SCRIPT CHANGES PRODUCTION: six class rows. The tilde number is claimed
-- at merge.

UPDATE imported_classes
   SET markdown = replace(replace(replace(replace(markdown,
         '"The Gift: Major, 01-25"', '"The Gift (01-25): Major"'),
         '"The Gift: Major, 26-50"', '"The Gift (26-50): Major"'),
         '"The Gift: Master, 51-75"', '"The Gift (51-75): Master"'),
         '"The Gift: Master, 76-00"', '"The Gift (76-00): Master"'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '"The Gift: Major, 01-25"') > 0;

UPDATE imported_classes
   SET markdown = replace(replace(replace(replace(replace(replace(markdown,
         '"Psionics 01-50: None"', '"Psionics (01-50): None"'),
         '"Psionics 51-70: Minor Psychic"', '"Psionics (51-70): Minor Psychic"'),
         '"Psionics 71-90: Major Psychic"', '"Psionics (71-90): Major Psychic"'),
         '"Psionics 91-95: Burster or Zapper"', '"Psionics (91-95): Burster or Zapper"'),
         '"Psionics 96-98: Nega-Psychic"', '"Psionics (96-98): Nega-Psychic"'),
         '"Psionics 99-00: Mind Melter"', '"Psionics (99-00): Mind Melter"'),
       updated_at = datetime('now')
 WHERE class_id = 'momano-headhunter'
   AND instr(markdown, '"Psionics 01-50: None"') > 0;

UPDATE imported_classes
   SET markdown = replace(replace(replace(markdown,
         '"Ramen Mystic (01-40%)"', '"Ramen Mystic (01-40)"'),
         '"Ramen Warrior (41-00%)"', '"Ramen Warrior (41-00)"'),
         'The app does not roll this; the player or G.M. rolls and picks the matching ability.',
         'The Roll d100 button picks the matching ability, or the player picks one.'),
       updated_at = datetime('now')
 WHERE class_id = 'ramen'
   AND instr(markdown, '"Ramen Mystic (01-40%)"') > 0;

UPDATE imported_classes
   SET markdown = replace(replace(replace(replace(replace(markdown,
         '"Minor Psionic (60%)"', '"Psionics (01-60): Minor Psionic"'),
         '"Major Psionic (37%)"', '"Psionics (61-97): Major Psionic"'),
         '"Master Psionic (3%)"', '"Psionics (98-00): Master Psionic"'),
         'THE PERCENTILE ROLL is not stored or enforced: the app has no roll for it.',
         'THE PERCENTILE ROLL is not stored: the Roll d100 button reads each name''s band.'),
         'Each ability''s name carries its percentage and its description the roll',
         'Each ability''s name carries its band and its description the roll'),
       updated_at = datetime('now')
 WHERE class_id = 'agogwe'
   AND instr(markdown, '"Minor Psionic (60%)"') > 0;

UPDATE imported_classes
   SET markdown = replace(replace(replace(markdown,
         '"Psionic Type: Master Psionic (85%)"', '"Psionic Type (01-85): Master Psionic"'),
         '"Psionic Type: Mind Melter (10%)"', '"Psionic Type (86-95): Mind Melter"'),
         '"Psionic Type: Mind Bleeder (5%)"', '"Psionic Type (96-00): Mind Bleeder"'),
       updated_at = datetime('now')
 WHERE class_id = 'crocodillian'
   AND instr(markdown, '"Psionic Type: Master Psionic (85%)"') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the app offers all four as a choice because it has no way to roll one.',
         'the app offers all four as a choice, with a Roll d100 button that picks by band.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, 'because it has no way to roll one.') > 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the five groups name their first band in parentheses' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'gifted-one-russian' AND instr(markdown, '"The Gift (01-25): Major"') > 0)
    OR (class_id = 'momano-headhunter' AND instr(markdown, '"Psionics (01-50): None"') > 0)
    OR (class_id = 'ramen' AND instr(markdown, '"Ramen Mystic (01-40)"') > 0)
    OR (class_id = 'agogwe' AND instr(markdown, '"Psionics (01-60): Minor Psionic"') > 0)
    OR (class_id = 'crocodillian' AND instr(markdown, '"Psionic Type (01-85): Master Psionic"') > 0);

SELECT 'no old option name is left on the five classes' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'gifted-one-russian' AND instr(markdown, 'The Gift: Ma') > 0)
    OR (class_id = 'momano-headhunter' AND instr(markdown, '"Psionics 0') + instr(markdown, '"Psionics 5') + instr(markdown, '"Psionics 7') + instr(markdown, '"Psionics 9') > 0)
    OR (class_id = 'ramen' AND instr(markdown, '(01-40%)') + instr(markdown, '(41-00%)') > 0)
    OR (class_id = 'agogwe' AND instr(markdown, 'Psionic (60%)') + instr(markdown, 'Psionic (37%)') + instr(markdown, 'Psionic (3%)') > 0)
    OR (class_id = 'crocodillian' AND instr(markdown, 'Psionic Type: M') > 0);

SELECT 'no sentence on the six classes says the app cannot roll' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('gifted-one-russian', 'momano-headhunter', 'ramen', 'agogwe', 'crocodillian', 'gypsy-gifted')
   AND instr(markdown, 'has no roll for it') + instr(markdown, 'does not roll this') + instr(markdown, 'no way to roll one') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~074-roll-bands-on-five-pick-one-groups.sql');
