-- Three skills the RUE O.C.C. import needs that the catalog did not have.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-rue-occ-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-rue-occ-skills.sql
--
-- RUE'S MASTER SKILL LIST IS NOT EXHAUSTIVE, which is the finding here and is
-- worth recording because the skill-name reconciliation treated that list as the
-- authority. Recognize Authenticity and Professional Restoration are defined on
-- the Rogue Scholar's own page (printed p93), described as "an exclusive skill",
-- and appear NOWHERE in the Skill List on printed pp.302-303. A class page can
-- define a skill the index never mentions.
--
-- Both base at 58% +3% per level. Professional Restoration's numbers fall on the
-- FOLLOWING page - the description starts on printed 93 and "Base Skill: 58%
-- +3%" is on 94 - so reading only the page the skill starts on would have given
-- it no percentages at all. That is the same page-straddle that cost Rift
-- Teleportation its P.P.E. cost in the Book of Magic import.
--
-- Robot Combat Elite: SAMAS follows the pattern already set by Robot Combat
-- Elite: Glitter Boy - a named elite specialisation rather than the generic
-- Robot Combat Elite - because the Coalition SAMAS Pilot trains on one specific
-- suit. W.P.s and Robot Combat carry no percentages, so 0/0 here is correct
-- rather than unfilled; see the isStub note in _lib/import-engine.js.

INSERT INTO skills (name, category, base, per_level, source, source_book, note)
SELECT 'Recognize Authenticity', 'Technical', 58, 3, 'manual', 'Rifts Ultimate Edition p.93',
       'Exclusive to the Rogue Scholar O.C.C.'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Recognize Authenticity');

INSERT INTO skills (name, category, base, per_level, source, source_book, note)
SELECT 'Professional Restoration', 'Technical', 58, 3, 'manual', 'Rifts Ultimate Edition p.93-94',
       'Exclusive to the Rogue Scholar O.C.C. Grants +10% to Art, Calligraphy, Forgery and Photography.'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Professional Restoration');

INSERT INTO skills (name, category, base, per_level, source, source_book, note)
SELECT 'Robot Combat Elite: SAMAS', 'Pilot', 0, 0, 'manual', 'Rifts Ultimate Edition p.233-235',
       'Elite training in one specific power armour, like Robot Combat Elite: Glitter Boy.'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Robot Combat Elite: SAMAS');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Recognize Authenticity', 'Professional Restoration', 'Robot Combat Elite: SAMAS')
 ORDER BY name;

INSERT INTO data_script_runs (filename) VALUES ('add-rue-occ-skills.sql');
