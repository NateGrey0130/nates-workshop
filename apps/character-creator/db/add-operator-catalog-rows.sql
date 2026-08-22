-- Three psionic powers and one skill the Operator O.C.C. needs.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-operator-catalog-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-operator-catalog-rows.sql
--
-- CATEGORIES COME FROM WHERE THE DESCRIPTION SITS, not from the class page.
-- RUE prints its psionic chapter in category order - Healing, Physical,
-- Sensitive from printed 171, Super from 177 - so a power's category is
-- decided by which run of pages describes it:
--
--   Machine Ghost                 printed 173  -> Sensitive
--   Telemechanic Mental Operation printed 184  -> Super
--   Telemechanic Paralysis        printed 184  -> Super
--
-- That agrees with the Operator's own page, which marks the two Telemechanic
-- powers "(Super, 12)" and "(Super, 20)" and leaves Machine Ghost unmarked.
-- Two readings agreeing is the reason to trust it.
--
-- Object Read is NOT here. The Operator's page names it, but the catalog holds
-- it as "Object Read (Psychometry)" and a merge redirect already points the
-- short name at it. Adding it again would undo a merge somebody made on purpose.
--
-- Recognize Machine Quality is the Operator's exclusive skill, printed p92,
-- "Base Skill: 58% +3% per level of experience" - the same numbers the Rogue
-- Scholar's two exclusive skills carry, and like those it appears nowhere in
-- RUE's master Skill List. A class page can define a skill the index never
-- mentions; that list is not exhaustive.

INSERT INTO psionic_powers (name, category, isp, range, duration, saving_throw, source, source_book)
SELECT 'Machine Ghost', 'Sensitive', 12,
       'Self; computer by touch.', 'Three minutes per level of experience.', 'None.',
       'manual', 'Rifts Ultimate Edition p.173'
 WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Machine Ghost');

INSERT INTO psionic_powers (name, category, isp, range, saving_throw, description, source, source_book)
SELECT 'Telemechanic Mental Operation', 'Super', 12,
       '20 feet (6.1 m) +5 feet (1.5 m) per level of experience.', 'Standard.',
       'Prerequisite: the psychic must also have the Telemechanics power.',
       'manual', 'Rifts Ultimate Edition p.184'
 WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Telemechanic Mental Operation');

INSERT INTO psionic_powers (name, category, isp, range, saving_throw, description, source, source_book)
SELECT 'Telemechanic Paralysis', 'Super', 20,
       'Touch or 40 feet (12.2 m).', 'Standard.',
       'Prerequisite: the psychic must also have the Telemechanics power.',
       'manual', 'Rifts Ultimate Edition p.184'
 WHERE NOT EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Telemechanic Paralysis');

INSERT INTO skills (name, category, base, per_level, source, source_book, note)
SELECT 'Recognize Machine Quality', 'Technical', 58, 3, 'manual', 'Rifts Ultimate Edition p.92',
       'Exclusive to the Operator O.C.C.'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Recognize Machine Quality');

-- Read the result back rather than trusting the exit code.
SELECT name, category, isp FROM psionic_powers
 WHERE name IN ('Machine Ghost', 'Telemechanic Mental Operation', 'Telemechanic Paralysis')
 ORDER BY name;
SELECT name, base, per_level FROM skills WHERE name = 'Recognize Machine Quality';

INSERT INTO data_script_runs (filename) VALUES ('add-operator-catalog-rows.sql');
