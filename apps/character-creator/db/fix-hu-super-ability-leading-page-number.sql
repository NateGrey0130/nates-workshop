-- Strip the printed page numbers that leaked into 23 super-ability descriptions.
--
-- A description spanning a page break picked up the FOLIO printed between its
-- two halves. `Energy Expulsion: Fire` begins "164 Attacks Per Melee", and
-- `Alter Physical Structure: Fire` reads "per each level of experi- 170 ence".
--
-- Found by QUERYING PRODUCTION, not by re-reading the generator. Every
-- assertion in `add-hu-core-super-abilities.sql` passed, because none of them
-- looked at the middle of a description - the same blind spot that hid the
-- `savings_throw` key typo and the 621-character `range` until somebody asked
-- the database a question about a COLUMN rather than about the row count.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-hu-super-ability-leading-page-number.sql
--
-- TWO TESTS DECIDE WHAT IS A FOLIO, AND THE SECOND IS WHAT MAKES THIS SAFE.
-- The token must be a THREE-DIGIT number within two of the printed page the row
-- itself cites, AND it must not be followed by a UNIT. Without the second test
-- this would have deleted `Swallowing Limbo`'s "100 lbs" - its page is 100 -
-- and rewritten the Techno-Form Hydrofoil's "100 mph" top speed, its page being
-- 102. Both were caught by printing the candidates and reading them.
--
-- Two-digit numbers are excluded outright for the same reason one step further:
-- Powers Unlimited One is printed 9-60, where "A.R. 12", "H.F. 14" and "15
-- minutes" all satisfy a page-number test and not one of them is a page number.
--
-- Each UPDATE is a SURGICAL `replace()` of the exact fragment, guarded on
-- `instr(...)`, so re-running is a no-op, the edit is readable in the diff, and
-- a row somebody has since rewritten by hand is left alone. Keyed on `name`,
-- which is UNIQUE, never on a literal id.

UPDATE super_abilities
   SET description = replace(description, 'experi- 170 ence.', 'experience.')
 WHERE name = 'Alter Physical Structure: Fire' AND instr(description, 'experi- 170 ence.') > 0;

UPDATE super_abilities
   SET description = replace(description, 'attack/action. 172 Generating', 'attack/action. Generating')
 WHERE name = 'Alter Physical Structure: Ice' AND instr(description, 'attack/action. 172 Generating') > 0;

UPDATE super_abilities
   SET description = replace(description, 'S.D.C. 173 Three', 'S.D.C. Three')
 WHERE name = 'Alter Physical Structure: Liquid' AND instr(description, 'S.D.C. 173 Three') > 0;

UPDATE super_abilities
   SET description = replace(description, 'is. 174 3.', 'is. 3.')
 WHERE name = 'Alter Physical Structure: Stone' AND instr(description, 'is. 174 3.') > 0;

UPDATE super_abilities
   SET description = replace(description, 'Teeth: 176 Antlers:', 'Teeth: Antlers:')
 WHERE name = 'Animal Metamorphosis' AND instr(description, 'Teeth: 176 Antlers:') > 0;

UPDATE super_abilities
   SET description = replace(description, 'wind. 177 6.', 'wind. 6.')
 WHERE name = 'Control Elemental Force: Air' AND instr(description, 'wind. 177 6.') > 0;

UPDATE super_abilities
   SET description = replace(description, 'super 178 ,', 'super ,')
 WHERE name = 'Control Elemental Force: Earth' AND instr(description, 'super 178 ,') > 0;

UPDATE super_abilities
   SET description = replace(description, 'wall 179 can', 'wall can')
 WHERE name = 'Control Elemental Force: Fire' AND instr(description, 'wall 179 can') > 0;

UPDATE super_abilities
   SET description = replace(description, 'etc. 180 Note:', 'etc. Note:')
 WHERE name = 'Control Elemental Force: Water' AND instr(description, 'etc. 180 Note:') > 0;

UPDATE super_abilities
   SET description = replace(description, 'save; 181 Psionics', 'save; Psionics')
 WHERE name = 'Control Others' AND instr(description, 'save; 181 Psionics') > 0;

UPDATE super_abilities
   SET description = replace(description, 'strike, 182 parry', 'strike, parry')
 WHERE name = 'Darkness Control' AND instr(description, 'strike, 182 parry') > 0;

UPDATE super_abilities
   SET description = replace(description, '164 Attacks', 'Attacks')
 WHERE name = 'Energy Expulsion: Fire' AND instr(description, '164 Attacks') > 0;

UPDATE super_abilities
   SET description = replace(description, 'S.D.C. 184 4.', 'S.D.C. 4.')
 WHERE name = 'Growth' AND instr(description, 'S.D.C. 184 4.') > 0;

UPDATE super_abilities
   SET description = replace(description, 'damage. 185 Knocks', 'damage. Knocks')
 WHERE name = 'Karmic Power' AND instr(description, 'damage. 185 Knocks') > 0;

UPDATE super_abilities
   SET description = replace(description, 'attack. 167 Bonuses:', 'attack. Bonuses:')
 WHERE name = 'Mental Stun' AND instr(description, 'attack. 167 Bonuses:') > 0;

UPDATE super_abilities
   SET description = replace(description, 'op- 188 ponents,', 'opponents,')
 WHERE name = 'Shrink' AND instr(description, 'op- 188 ponents,') > 0;

UPDATE super_abilities
   SET description = replace(description, 'half. 189 Note:', 'half. Note:')
 WHERE name = 'Sonic Power' AND instr(description, 'half. 189 Note:') > 0;

UPDATE super_abilities
   SET description = replace(description, 'km). 100 No', 'km). No')
 WHERE name = 'Superluminal Flight (FTL)' AND instr(description, 'km). 100 No') > 0;

UPDATE super_abilities
   SET description = replace(description, 'created. 101 Hit', 'created. Hit')
 WHERE name = 'Swarm-Selves' AND instr(description, 'created. 101 Hit') > 0;

UPDATE super_abilities
   SET description = replace(description, 'powers). 102 The', 'powers). The')
 WHERE name = 'Techno-Form' AND instr(description, 'powers). 102 The') > 0;

UPDATE super_abilities
   SET description = replace(description, 'Underwater: 168 Add', 'Underwater: Add')
 WHERE name = 'Underwater' AND instr(description, 'Underwater: 168 Add') > 0;

UPDATE super_abilities
   SET description = replace(description, 'Instant 191 Attacks', 'Instant Attacks')
 WHERE name = 'Vibration' AND instr(description, 'Instant 191 Attacks') > 0;

UPDATE super_abilities
   SET description = replace(description, '- 192 \', '- \')
 WHERE name = 'Weight Manipulation' AND instr(description, '- 192 \') > 0;

-- ASSERTIONS.

SELECT 'no super ability description starts with a folio' AS assertion,
       count(*) AS got, 0 AS want
  FROM super_abilities WHERE description GLOB '1[0-9][0-9] *';

SELECT 'every repaired row still has a full description' AS assertion,
       count(*) AS got, 23 AS want
  FROM super_abilities
 WHERE name IN ('Alter Physical Structure: Fire', 'Alter Physical Structure: Ice', 'Alter Physical Structure: Liquid', 'Alter Physical Structure: Stone', 'Animal Metamorphosis', 'Control Elemental Force: Air', 'Control Elemental Force: Earth', 'Control Elemental Force: Fire', 'Control Elemental Force: Water', 'Control Others', 'Darkness Control', 'Energy Expulsion: Fire', 'Growth', 'Karmic Power', 'Mental Stun', 'Shrink', 'Sonic Power', 'Superluminal Flight (FTL)', 'Swarm-Selves', 'Techno-Form', 'Underwater', 'Vibration', 'Weight Manipulation') AND length(description) > 100;

-- The word broken across printed 169-170 is CLOSED, not merely de-numbered.
SELECT 'the hyphen-split word is whole again' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Alter Physical Structure: Fire'
   AND instr(description, 'level of experience. Damage') > 0;

-- The two numbers a looser rule would have destroyed are still there. These are
-- the whole reason for the unit test, so they are asserted rather than trusted.
SELECT 'Swallowing Limbo keeps its 100 lbs' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Swallowing Limbo' AND instr(description, '100 lbs') > 0;

SELECT 'the Techno-Form Hydrofoil keeps its 100 mph' AS assertion, count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Techno-Form' AND instr(description, '100 mph') > 0;

SELECT 'and the Powers Unlimited two-digit numbers are untouched' AS assertion,
       count(*) AS got, 1 AS want
  FROM super_abilities
 WHERE name = 'Anatomical Independence'
   AND instr(description, 'H.F. 14 for moving eyeballs') > 0;

INSERT INTO data_script_runs (filename) VALUES ('fix-hu-super-ability-leading-page-number.sql');
