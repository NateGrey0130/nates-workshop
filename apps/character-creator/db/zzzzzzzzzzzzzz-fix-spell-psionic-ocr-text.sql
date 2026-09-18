-- Repair the OCR damage a sweep found in 46 spells, 1 psionic power and 2
-- super abilities.
--
-- fix-super-ability-ocr-text.sql (#1153) repaired 198 super abilities after the
-- codex showed their whole text for the first time. The same sweep, calibrated
-- on those rows (198 flagged before the fix, 6 known-legitimate after), was run
-- read-only over spells, psionic powers, skills and talents on production,
-- 2026-09-18. Talents and skills came back clean. These did not:
--
--   41 spells   Mystic Russia prints spells by level, and each level's heading
--               ("Level Two") was read onto the last spell of the level before
--   1 spell     Control & Enslave Entity stops mid-sentence at a page turn
--               ("All varieties of entities are susceptible"); the rest is the
--               top of printed 219 and is completed here from a render of it
--   2 spells    a printed page number, one on the end and one mid-sentence
--   1 spell     "1D4><10", the scan's reading of a multiplication sign
--   1 psionic   Telekinetic Push ends in the next section's heading
--   10 rows     the digit cipher every text-layer cache carries: 1D6x10 set as
--               "!D6xlO", in eight Mystic Russia spells (two of them in the
--               `damage` column) and two super abilities #1153 missed
--
-- The memory of a 2026-09-12 sweep that found the cipher in zero rows was true
-- the day it ran; Mystic Russia's spells were imported the day after.
--
-- LEFT AS PRINTED, and asserted below so a later sweep does not "fix" them:
-- `Spoiling: Curdle Milk` ends "ice cream and butter" with no stop, and so does
-- the page; `Bone: Crawling Bones` ends on its own table, "Tail (large) - 20".
--
-- NOT THE MECHANICAL READING: `Animal Abilities`' "4O0ft (12.2m)" and
-- `Growth`'s "5O0lbs per foot" decode to 400 and 500, and the page prints 40
-- and 50. 12.2 m is forty feet; the book's own next sentence makes 28 feet
-- 1,400 pounds. Read off renders of printed 175 and 184.
--
-- NOT IN SCOPE: the spell NAMED "Living Fire: Rerun's Celestial Fire Bolt",
-- which printed 116 calls Perun's. A rename moves a catalog key and gets its
-- own script and redirect. Ordinary misspellings the scan made of real words
-- are not swept for either.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzz-fix-spell-psionic-ocr-text.sql
--
-- Named to sort after every script that writes spells, psionic_powers or
-- super_abilities (zzzzzzzzzzzzz-nb-spells.sql, zzzzzzzzzzzzz-nb-psionics.sql,
-- fix-super-ability-ocr-text.sql; 2026-09-18). Each UPDATE is keyed on `name`
-- and guarded on the exact text it replaces, so re-running is a no-op; an
-- ending is matched as the column's exact suffix.

-- A. Mystic Russia prints its spells by level, and the import read each level's
--    heading ("Level Two") onto the end of the last spell of the level before.

UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Spoiling: Curdle Milk' AND substr(description, -10) = ' Level Two';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Spoiling: Spoil Eggs' AND substr(description, -12) = ' Level Three';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Spoiling: Use Poison Flawlessly' AND substr(description, -11) = ' Level Four';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Spoiling: Dry Mother''s Milk' AND substr(description, -11) = ' Level Five';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Spoiling: Spoil & Taint Food' AND substr(description, -10) = ' Level Six';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Spoiling: Track Thy Enemy' AND substr(description, -12) = ' Level Seven';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Spoiling: Spoil Memory' AND substr(description, -12) = ' Level Eight';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Spoiling: Wither Thy Enemies' AND substr(description, -10) = ' Level Ten';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Bone: Talking Bones' AND substr(description, -10) = ' Level Two';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Bone: Hide Among the Dead' AND substr(description, -12) = ' Level Three';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Bone: Recognize the Undead' AND substr(description, -11) = ' Level Four';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Bone: Summon the Dead' AND substr(description, -11) = ' Level Five';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Bone: Locking Hand' AND substr(description, -10) = ' Level Six';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Bone: Wear the Face of Another' AND substr(description, -12) = ' Level Seven';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Bone: Curse: Death Wish' AND substr(description, -12) = ' Level Eight';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Bone: Mock Funeral (curse)' AND substr(description, -11) = ' Level Nine';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Bone: Shadow of Doom (curse)' AND substr(description, -10) = ' Level Ten';
UPDATE spells SET description = substr(description, 1, length(description) - 13)
 WHERE name = 'Bone: Summon Insect Swarm' AND substr(description, -13) = ' Level Eleven';
UPDATE spells SET description = substr(description, 1, length(description) - 13)
 WHERE name = 'Bone: Transfer Life Force' AND substr(description, -13) = ' Level Twelve';
UPDATE spells SET description = substr(description, 1, length(description) - 15)
 WHERE name = 'Bone: Summon Worms of Taut' AND substr(description, -15) = ' Level Thirteen';
UPDATE spells SET description = substr(description, 1, length(description) - 15)
 WHERE name = 'Bone: Summon Magot (monster)' AND substr(description, -15) = ' Level Fourteen';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Living Fire: Smoke Smell' AND substr(description, -10) = ' Level Two';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Living Fire: Toxic Smoke Cloud' AND substr(description, -12) = ' Level Three';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Living Fire: M.D. Torchfire' AND substr(description, -11) = ' Level Four';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Living Fire: Fire Meld' AND substr(description, -11) = ' Level Five';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Living Fire: Spiral Fire Blast' AND substr(description, -10) = ' Level Six';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Living Fire: Rerun''s Celestial Fire Bolt' AND substr(description, -12) = ' Level Seven';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Living Fire: Perun''s Fire Scourge' AND substr(description, -12) = ' Level Eight';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Living Fire: The Torch & Wheel' AND substr(description, -11) = ' Level Nine';
UPDATE spells SET description = substr(description, 1, length(description) - 13)
 WHERE name = 'Living Fire: Dragonfire' AND substr(description, -13) = ' Level Twelve';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Nature: Sacred Oath' AND substr(description, -10) = ' Level Two';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Nature: Sustained by the Earth' AND substr(description, -12) = ' Level Three';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Nature: Seal a Wound with Bee''s Wax' AND substr(description, -11) = ' Level Four';
UPDATE spells SET description = substr(description, 1, length(description) - 33)
 WHERE name = 'Nature: Negate Spoiling Magic' AND substr(description, -33) = ' Level Five Glimpse of the Future';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Nature: Rope of Steel' AND substr(description, -10) = ' Level Six';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Nature: Strength of the Earth' AND substr(description, -12) = ' Level Seven';
UPDATE spells SET description = substr(description, 1, length(description) - 12)
 WHERE name = 'Nature: Living Bones of Stone' AND substr(description, -12) = ' Level Eight';
UPDATE spells SET description = substr(description, 1, length(description) - 11)
 WHERE name = 'Nature: Swords to Snakes' AND substr(description, -11) = ' Level Nine';
UPDATE spells SET description = substr(description, 1, length(description) - 10)
 WHERE name = 'Nature: Magic Egg' AND substr(description, -10) = ' Level Ten';
UPDATE spells SET description = substr(description, 1, length(description) - 13)
 WHERE name = 'Nature: Snakes to Swords' AND substr(description, -13) = ' Level Eleven';
UPDATE spells SET description = substr(description, 1, length(description) - 13)
 WHERE name = 'Nature: Protective Magic Ring' AND substr(description, -13) = ' Level Twelve';

-- B. Cut off at a page turn. The rest is the top of printed 219, read from a
--    render of the page (the OCR cache has "contro!" for "control").

UPDATE spells SET description = substr(description, 1, length(description) - 41) || 'All varieties of entities are susceptible to this enchantment. Each individual entity gets to make a saving throw vs magic. A successful save means it is not controlled by the spell caster. A failed roll means it will obey the mage to the best of its ability (some are barely intelligent). At the end of its mandatory service to the mage, the wizard can try to renew his control by invoking the Control invocation again, banish the creature (see Banishment), or just let his control slip away. The latter can be dangerous, because the evil beings may turn on the mage to extract vengeance or out of spite. On the other hand, the more intelligent types may willingly agree to work with the mage, especially an evil one, or if such service will help the diabolical being in its own schemes or to inflict pain and suffering.'
 WHERE name = 'Control & Enslave Entity' AND substr(description, -41) = 'All varieties of entities are susceptible';

-- C. Two printed page numbers, a multiplication sign read as "><", and "lOOx".

UPDATE spells SET description = substr(description, 1, length(description) - 4)
 WHERE name = 'Spontaneous Combustion' AND substr(description, -4) = ' 103';
UPDATE spells SET description = replace(description, 'must be 100 completely', 'must be completely')
 WHERE name = 'Sorcerer''s Seal' AND instr(description, 'must be 100 completely') > 0;
UPDATE spells SET description = replace(description, '1D4><10', '1D4x10')
 WHERE name = 'Nature: Snakes to Swords' AND instr(description, '1D4><10') > 0;
UPDATE spells SET description = replace(description, 'weight lOOx his', 'weight 100x his')
 WHERE name = 'Nature: Strength of the Earth' AND instr(description, 'weight lOOx his') > 0;

-- D. The next section's heading read onto the last power of this one.

UPDATE psionic_powers SET description = substr(description, 1, length(description) - 19)
 WHERE name = 'Telekinetic Push' AND substr(description, -19) = ' Sensitive Psionics';

-- E. The digit cipher: text-layer books set 1 as "!" or "l" and 0 as "O", so 1D6x10
--    arrives as "!D6xlO". Two super abilities are NOT the mechanical reading - the
--    page prints 40ft and 50lbs - and were read off the page.

UPDATE spells SET description = replace(description, '!D6xlO%', '1D6x10%')
 WHERE name = 'Spoiling: Spoil & Taint Food' AND instr(description, '!D6xlO%') > 0;
UPDATE spells SET description = replace(description, '!D4xlO S.D.C.', '1D4x10 S.D.C.')
 WHERE name = 'Bone: Kill Plants' AND instr(description, '!D4xlO S.D.C.') > 0;
UPDATE spells SET description = replace(description, '!D4xlOOO', '1D4x1000')
 WHERE name = 'Bone: Summon Magot (monster)' AND instr(description, '!D4xlOOO') > 0;
UPDATE spells SET description = replace(description, '!D6xlO S.D.C.', '1D6x10 S.D.C.')
 WHERE name = 'Living Fire: Fire Bolt' AND instr(description, '!D6xlO S.D.C.') > 0;
UPDATE spells SET damage = replace(damage, '!D6xlO M.D.', '1D6x10 M.D.')
 WHERE name = 'Living Fire: Rerun''s Celestial Fire Bolt' AND instr(damage, '!D6xlO M.D.') > 0;
UPDATE spells SET damage = replace(damage, '!D4xlO M.D.', '1D4x10 M.D.')
 WHERE name = 'Living Fire: Dragonfire' AND instr(damage, '!D4xlO M.D.') > 0;
UPDATE spells SET description = replace(description, '!D4xlO M.D.', '1D4x10 M.D.')
 WHERE name = 'Living Fire: Dragonfire' AND instr(description, '!D4xlO M.D.') > 0;
UPDATE spells SET description = replace(description, '!D4xlO S.D.C.', '1D4x10 S.D.C.')
 WHERE name = 'Nature: Snakes to Swords' AND instr(description, '!D4xlO S.D.C.') > 0;
UPDATE super_abilities SET description = replace(description, '4O0ft (12.2m)', '40ft (12.2m)')
 WHERE name = 'Animal Abilities' AND instr(description, '4O0ft (12.2m)') > 0;
UPDATE super_abilities SET description = replace(description, 'rate of 5O0lbs per foot', 'rate of 50lbs per foot')
 WHERE name = 'Growth' AND instr(description, 'rate of 5O0lbs per foot') > 0;

-- ASSERTIONS.

SELECT 'no spell ends in a Mystic Russia level heading' AS assertion, count(*) AS got, 0 AS want
  FROM spells
 WHERE description LIKE '% Level One' OR description LIKE '% Level Two' OR description LIKE '% Level Three'
    OR description LIKE '% Level Four' OR description LIKE '% Level Five' OR description LIKE '% Level Six'
    OR description LIKE '% Level Seven' OR description LIKE '% Level Eight' OR description LIKE '% Level Nine'
    OR description LIKE '% Level Ten' OR description LIKE '% Level Eleven' OR description LIKE '% Level Twelve'
    OR description LIKE '% Level Thirteen' OR description LIKE '% Level Fourteen' OR description LIKE '% Level Fifteen'
    OR instr(description, 'Level Five Glimpse of the Future') > 0;

SELECT 'Control & Enslave Entity runs to the end of printed 219' AS assertion, count(*) AS got, 1 AS want
  FROM spells
 WHERE name = 'Control & Enslave Entity'
   AND instr(description, 'susceptible to this enchantment. Each individual entity') > 0
   AND substr(description, -length('to inflict pain and suffering.')) = 'to inflict pain and suffering.';

SELECT 'the page number and the misread characters are gone' AS assertion, count(*) AS got, 0 AS want
  FROM spells
 WHERE (name = 'Spontaneous Combustion' AND substr(description, -length(' 103')) = ' 103')
    OR (name = 'Sorcerer''s Seal' AND instr(description, 'must be 100 completely') > 0)
    OR instr(description, '><') > 0
    OR instr(description, 'lOOx') > 0;

SELECT 'and what replaced them is there' AS assertion, count(*) AS got, 3 AS want
  FROM spells
 WHERE (name = 'Nature: Snakes to Swords' AND instr(description, '1D4x10+8 M.D.') > 0)
    OR (name = 'Nature: Strength of the Earth' AND instr(description, 'weight 100x his P.S.') > 0)
    OR (name = 'Sorcerer''s Seal' AND instr(description, 'must be completely sealed in wax') > 0);

SELECT 'Telekinetic Push ends where the book does' AS assertion, count(*) AS got, 1 AS want
  FROM psionic_powers
 WHERE name = 'Telekinetic Push' AND substr(description, -length('(12 feet/3.6 m).')) = '(12 feet/3.6 m).';

-- The cipher, swept the way the digit-cipher note says to: GLOB, which is
-- case-sensitive, where LIKE would also match an honest "xlo".
SELECT 'no dice are left in the digit cipher' AS assertion, count(*) AS got, 0 AS want
  FROM spells
 WHERE description GLOB '*!D[0-9]*' OR description GLOB '*[0-9]xlO*'
    OR damage GLOB '*!D[0-9]*' OR damage GLOB '*[0-9]xlO*';

SELECT 'and the two damage columns read 1Dnx10' AS assertion, count(*) AS got, 2 AS want
  FROM spells
 WHERE (name = 'Living Fire: Rerun''s Celestial Fire Bolt' AND instr(damage, 'the damage is 1D6x10 M.D.') > 0)
    OR (name = 'Living Fire: Dragonfire' AND damage = '1D4x10 M.D.');

SELECT 'the two super abilities carry the numbers the page prints' AS assertion, count(*) AS got, 2 AS want
  FROM super_abilities
 WHERE (name = 'Animal Abilities' AND instr(description, 'straight up and 40ft (12.2m) across') > 0)
    OR (name = 'Growth' AND instr(description, 'at a rate of 50lbs per foot. So 28') > 0);

SELECT 'and no super ability is left in the cipher' AS assertion, count(*) AS got, 0 AS want
  FROM super_abilities
 WHERE description GLOB '*[0-9]O[0-9]*' OR description GLOB '*!D[0-9]*' OR description GLOB '*[0-9]xlO*';

-- The two endings that look wrong and are printed that way.
SELECT 'the endings the book prints are left alone' AS assertion, count(*) AS got, 2 AS want
  FROM spells
 WHERE (name = 'Spoiling: Curdle Milk' AND substr(description, -length('ice cream and butter')) = 'ice cream and butter')
    OR (name = 'Bone: Crawling Bones' AND substr(description, -length('Tail (large) - 20')) = 'Tail (large) - 20');

SELECT 'every spell is still here, and none lost its text' AS assertion, count(*) AS got, 974 AS want
  FROM spells WHERE length(description) >= 60;

SELECT 'every psionic power is still here, and none lost its text' AS assertion, count(*) AS got, 133 AS want
  FROM psionic_powers WHERE length(description) >= 60;

SELECT 'every super ability is still here, and none lost its text' AS assertion, count(*) AS got, 364 AS want
  FROM super_abilities WHERE length(description) >= 60;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzz-fix-spell-psionic-ocr-text.sql');
