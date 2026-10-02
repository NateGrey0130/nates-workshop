-- Rifts World Book 20: Canada, batch 4a: five skills its classes grant.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~066-canada-class-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~066-canada-class-skills.sql
--
-- The survey's skill inventory read only Winter Sports Skills (printed 36).
-- These five are printed inside class entries, and turned up when the
-- classes were drafted and class-check --remote reported them missing
-- (2026-10-02). None is in production under any spelling. Pages are printed
-- folios; the cache page is the folio plus one (scripts/books.json).
--
--   Fanatic Robophile          printed 117-118, special skill 1 of the
--       Headhunter Anti-Robot Specialist. The book says it is a Technical
--       skill, and that every other O.C.C. takes it at 50% +3% per level,
--       as an O.C.C. Related skill only, with no O.C.C. bonus. 50/3 is the
--       row; the Anti-Robot Specialist's own 64% is on that class.
--   Hotwire Robot Vehicles & Power Armor   printed 118-119, special skill 2
--       of the same class. Base Skill 50% +3%. The book files it under no
--       category; Electrical is this catalog's choice, where Hot Wiring is.
--       It is NOT Hot Wiring, which is the Heroes Unlimited skill.
--   Language: Techno-Can and Literacy: Techno-Can   printed 117 names the
--       language; printed 119 and 121 grant both to two Headhunter classes
--       at their own figures. The book prints no base for either. 50/5 and
--       30/5 are the figures the catalog's other Language and Literacy rows
--       carry, stored so the rows can be picked; the note says so.
--   Dog Sled                   printed 183, in the Inuit Shaman's skill list:
--       Pilot: Dog Sled, Base Skill 25% +5% per level. The sled itself is
--       the gear row dog-sled (printed 31).
--
-- A `~` sorts after every `z` tier, so this runs after
-- zzzzzzzzzzzzzzzz-tag-skill-systems.sql. Re-running it is a no-op.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Fanatic Robophile', 'Technical', 50, 3, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.117-118',
        'An obsessive knowledge of the design, function and military use of robots and power armor: recognizes the common North American makes on sight and recalls their statistics, assesses damage, wear, repair cost and value, and diagnoses faults (pinpointing one is at -10%). It does not let the character repair or sabotage anything; that needs the robot engineering skills. +5% to Robot Electronics and Robot Mechanics, and to Weapon Systems and Computer Repair on robots and power armor only. -25% on uncommon or foreign machines, -40% on the extremely rare, alien or never seen. O.C.C. Related only, never Secondary; no O.C.C. or related bonus applies, and it halves the character''s bonuses on all other mechanical and electronics skills. The Headhunter Anti-Robot Specialist has it at 64%.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Hotwire Robot Vehicles & Power Armor', 'Electrical', 50, 3, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.118-119',
        'Special skill of the Headhunter Anti-Robot Specialist. Two rolls: one to open the locking mechanism, one to start and control the machine; opening it does not disarm an alarm or surveillance system. Each attempt takes three melee actions. After three failures in a row on one machine the character is -40% on it. Locksmith adds +5%; Robot Electronics and Robot Mechanics add +2% each. The book files it under no skill category.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Language: Techno-Can', 'Technical', 50, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.117',
        'The Japanese-American technical mesh language. The book prints no base figure; 50/5 is the catalog''s figure for a language. The classes that grant it state their own.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Literacy: Techno-Can', 'Communications', 30, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.119',
        'Reading and writing Techno-Can. The book prints no base figure; 30/5 is the catalog''s figure for a literacy. The classes that grant it print a bonus on top.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Dog Sled', 'Pilot', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 20: Canada p.183',
        'Printed as Pilot: Dog Sled, inside the Inuit Shaman''s skill list. Driving a sled and its team of six to nine dogs.');

-- Readbacks: each must return got = want. This script asserts its OWN rows.
SELECT 'the two robot skills are in at 50% +3%' AS assertion, count(*) AS got, 2 AS want
  FROM skills WHERE base = 50 AND per_level = 3 AND source_book LIKE 'Rifts World Book 20: Canada p.11%'
   AND ((name = 'Fanatic Robophile' AND category = 'Technical') OR (name = 'Hotwire Robot Vehicles & Power Armor' AND category = 'Electrical'));

SELECT 'Techno-Can has a language and a literacy row' AS assertion, count(*) AS got, 2 AS want
  FROM skills WHERE source_book LIKE 'Rifts World Book 20: Canada p.11%'
   AND ((name = 'Language: Techno-Can' AND category = 'Technical' AND base = 50)
     OR (name = 'Literacy: Techno-Can' AND category = 'Communications' AND base = 30));

SELECT 'Dog Sled is a Pilot skill at 25% +5%' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Dog Sled' AND category = 'Pilot' AND base = 25 AND per_level = 5
   AND source_book = 'Rifts World Book 20: Canada p.183';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~066-canada-class-skills.sql');
