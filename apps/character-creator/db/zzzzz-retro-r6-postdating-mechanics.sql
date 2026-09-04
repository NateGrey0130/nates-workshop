-- RETRO-AUDIT R6: three classes carry a mechanic the schema gained after they
-- were imported.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r6-postdating-mechanics.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r6-postdating-mechanics.sql
--
-- R6 was filed at MEDIUM confidence and said to check each part before scoping
-- it. That check changed two of the three, and both changes are recorded here.
--
-- 1. dragon-hatchling-royal-frilled - REAL, AND WORSE THAN FILED.
--    R6 said the class could not say which psionic schedule entries are Super.
--    True, and while fixing it the schedule turned out to be WRONG as well:
--    re-read from the book (Rifts Ultimate Edition printed 162, rue cache p165,
--    the registry's +3 offset), the class grants
--      "a total of 12 psychic powers from Sensitive, Physical, and/or Healing.
--       Also select two Super Psionic Powers at level one. Select an additional
--       Super Psi-Power at levels 5, 9, 14, 18 and 22. Select an additional two
--       psychic powers from any of the three previous categories at levels 3,
--       6, 9, 12, 15, 18 and 21."
--    Production had powers_starting: 12, so EVERY ROYAL FRILLED HATCHLING WAS
--    TWO SUPER POWERS SHORT AT CREATION; the Super grants at levels 9 and 18
--    were missing entirely, level 18's ordinary pair had been collapsed to a
--    single entry, and levels 21 and 22 were absent.
--
--    powers_starting_groups splits the starting pick (S9's shape, 2026-08-26)
--    and per-entry `categories` says which grant is Super (migration
--    029-power-pick-categories.sql). Two entries may share a level: `slot` is
--    derived by POSITION in js/leveling.js, so nothing states it by hand.
--
-- 2. freelancer - REAL. The two attribute entries on the Special Freelancer's
--    chart carried only their FLAT bonuses, with the dice halves in prose.
--    bonuses.attributes takes a dice string and bonuses.pools takes a dice
--    expression - the Godling's abilities already do exactly this. Rolled once
--    at creation and stored as attribute_bonuses (migration 016).
--
-- 3. seljuk - NOT a missing mechanic. NOTE ROT ONLY, and this is the part the
--    finding told us to check. The claim is that occ_restrictions "cannot
--    express by name" the rule that a seljuk may not be a psi-stalker. As a
--    statement about the schema that is false - occ_restrictions takes a list
--    of class ids. But the rule is ALREADY ENFORCED FROM THE OTHER SIDE: both
--    psi-stalker and wild-psi-stalker carry race_restrictions only: ["none"],
--    so raceAllowedForOcc already refuses the pairing for every race. Adding an
--    occ_restrictions block here would be a second copy of a rule that already
--    works, and a second place to get it wrong. The note is corrected; no
--    mechanic is added, deliberately.

-- ---- 1. dragon-hatchling-royal-frilled: the psionic ladders, split ---------
UPDATE imported_classes
   SET markdown = replace(markdown,
'  powers_starting: 12
  categories_allowed: ["Sensitive", "Physical", "Healing"]
  powers_schedule:
    - { level: 3, count: 2 }
    - { level: 5, count: 1 }
    - { level: 6, count: 2 }
    - { level: 9, count: 2 }
    - { level: 12, count: 2 }
    - { level: 14, count: 1 }
    - { level: 15, count: 2 }
    - { level: 18, count: 1 }',
'  powers_starting: 14
  powers_starting_groups:
    - { count: 12, categories: ["Sensitive", "Physical", "Healing"] }
    - { count: 2, categories: ["Super"] }
  categories_allowed: ["Sensitive", "Physical", "Healing"]
  powers_schedule:
    - { level: 3, count: 2 }
    - { level: 5, count: 1, categories: ["Super"] }
    - { level: 6, count: 2 }
    - { level: 9, count: 2 }
    - { level: 9, count: 1, categories: ["Super"] }
    - { level: 12, count: 2 }
    - { level: 14, count: 1, categories: ["Super"] }
    - { level: 15, count: 2 }
    - { level: 18, count: 2 }
    - { level: 18, count: 1, categories: ["Super"] }
    - { level: 21, count: 2 }
    - { level: 22, count: 1, categories: ["Super"] }')
 WHERE class_id = 'dragon-hatchling-royal-frilled'
   AND instr(markdown, 'powers_starting: 12') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'The schedule below merges both ladders; which entries are Super is recorded in the extraction notes, the format having no way to say so per entry.',
       'The two ladders are kept apart: powers_starting_groups splits the level-one pick into 12 ordinary and 2 Super, and each schedule entry states its own categories. Two entries share levels 9 and 18 because both ladders grant there. Until RETRO-AUDIT R6 (2026-09-04) this note said the format had no way to say so per entry, and the class was two Super powers short at creation with the level 9 and 18 Super grants and the level 21 and 22 grants missing.')
 WHERE class_id = 'dragon-hatchling-royal-frilled'
   AND instr(markdown, 'the format having no way to say so per entry') > 0;

-- ---- 2. freelancer: the dice halves of two chart entries ------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       'bonuses: { attributes: { PS: 6 } }',
       'bonuses: { attributes: { PS: 6, PE: "1d4" }, pools: { mdc: "1d4x10" } }')
 WHERE class_id = 'freelancer'
   AND instr(markdown, 'bonuses: { attributes: { PS: 6 } }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'bonuses: { combat: { initiative: 1, roll: 2 } }',
       'bonuses: { attributes: { PP: "1d4", Spd: "4d6" }, combat: { initiative: 1, roll: 2 } }')
 WHERE class_id = 'freelancer'
   AND instr(markdown, 'bonuses: { combat: { initiative: 1, roll: 2 } }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'The two attribute entries carry only their FLAT bonuses; the dice halves (+1D4 P.E., +1D4 P.P., +4D6 Spd, 1D4x10 M.D.C.) are rolled by hand and stay in the description.',
       'The two attribute entries carry BOTH halves now: bonuses.attributes takes a dice string and bonuses.pools takes a dice expression, the shape the Godling''s abilities already use, and the roll is made once at creation and stored as attribute_bonuses. Until RETRO-AUDIT R6 (2026-09-04) only the flat bonuses were stored and the dice halves (+1D4 P.E., +1D4 P.P., +4D6 Spd, 1D4x10 M.D.C.) were rolled by hand.')
 WHERE class_id = 'freelancer'
   AND instr(markdown, 'are rolled by hand and stay in the description') > 0;

-- ---- 3. seljuk: note only, and NO mechanic is added -----------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       'a seljuk can be a psychic R.C.C. like a mind melter or burster, but NOT a' || char(10) || '    psi-stalker - a rule about which class pairs with this race, which' || char(10) || '    `occ_restrictions` cannot express by name.',
       'a seljuk can be a psychic R.C.C. like a mind melter or burster, but NOT a' || char(10) || '    psi-stalker. `occ_restrictions` COULD say that by name - it takes a list of' || char(10) || '    class ids - and this note said it could not until RETRO-AUDIT R6' || char(10) || '    (2026-09-04). No block is added here anyway, because the rule is already' || char(10) || '    enforced from the other side: psi-stalker and wild-psi-stalker both carry' || char(10) || '    race_restrictions only: ["none"], so raceAllowedForOcc refuses the pairing' || char(10) || '    for every race. A second copy would be a second place to get it wrong.')
 WHERE class_id = 'seljuk'
   AND instr(markdown, '`occ_restrictions` cannot express by name') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the royal frilled starts with 14 powers in two groups' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'dragon-hatchling-royal-frilled'
   AND instr(markdown, 'powers_starting: 14') > 0
   AND instr(markdown, 'powers_starting_groups') > 0;

SELECT 'all five Super schedule grants are stated' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'dragon-hatchling-royal-frilled'
   AND instr(markdown, 'level: 5, count: 1, categories: ["Super"]') > 0
   AND instr(markdown, 'level: 9, count: 1, categories: ["Super"]') > 0
   AND instr(markdown, 'level: 14, count: 1, categories: ["Super"]') > 0
   AND instr(markdown, 'level: 18, count: 1, categories: ["Super"]') > 0
   AND instr(markdown, 'level: 22, count: 1, categories: ["Super"]') > 0;

SELECT 'the freelancer carries both dice halves' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'freelancer'
   AND instr(markdown, 'PE: "1d4" }, pools: { mdc: "1d4x10" }') > 0
   AND instr(markdown, 'PP: "1d4", Spd: "4d6"') > 0;

-- The seljuk gains NO occ_restrictions block. This is the posture assertion:
-- the note was wrong, the mechanic was not needed, and nothing was added.
SELECT 'no occ_restrictions block was added to the seljuk' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'seljuk' AND instr(markdown, 'occ_restrictions:') > 0;

SELECT 'the psi-stalkers still gate the pairing themselves' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('psi-stalker', 'wild-psi-stalker')
   AND instr(markdown, 'race_restrictions:') > 0;

-- Matched on phrases unique to the OLD text, not on the limitation wording.
-- Each replacement QUOTES the sentence it corrects - that is what a correction
-- is for - so an assertion greping the limitation phrase matches its own
-- replacement and can never pass. That trap fired here on the first run and
-- again in zzzzz-retro-r3-warlock-notes.sql; it is the readback-cannot-assert-
-- a-quoted-phrase shape.
SELECT 'no class still denies one of these three mechanics' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('dragon-hatchling-royal-frilled', 'freelancer', 'seljuk')
   AND (instr(markdown, 'The schedule below merges both ladders') > 0
     OR instr(markdown, 'The two attribute entries carry only their FLAT bonuses') > 0
     OR instr(markdown, 'which' || char(10) || '    `occ_restrictions` cannot express by name') > 0);

-- Records this run. Every statement guards itself on the text it replaces, so
-- this script is safe to re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r6-postdating-mechanics.sql');
