-- The new skill rows Rifts World Book 9: South America 2 needs: six languages,
-- Art: Line Drawing and Riding: War Bison. The first import of that book; see
-- apps/character-creator/docs/surveys/south-america-2.md.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-a-south-america-2-skills.sql
--
-- NAMED add-a-... ON PURPOSE. Filename order is execution order, and this file
-- has to reach a fresh database before every class script of this book that
-- grants these skills (add-amaki-..., add-arkhon-..., add-inca-...,
-- add-larhold-..., add-nazca-...). add-a- sorts before every add-a<letter>
-- file in the directory today; checked with the sort command in class-import.
--
-- LANGUAGES, printed 162 (the Languages section of Other Republics): Creole,
-- Quechua, Aymara, Arkhon and Larhold are new; Spanish is already in the
-- catalog (New West). Amaki is not on that page - it is the Amaki Stone-Man's
-- racial tongue, which the R.C.C. speaks at 98% (printed 155).
--
-- VALUES follow the catalog Language family, not this book: every named
-- "Language: X" row is Technical at 50% +5%, as add-gargoyle-and-brodkil-
-- languages.sql records. The book prints a base for exactly one of these:
-- Larhold is 40% +4% for every race except the Larhold, who learn it
-- normally. The catalog holds ONE base per skill, so the row keeps the family
-- 50/5 that a Larhold character gets and the outsiders' 40/4 goes in the note.
-- The Creole literacy penalty and the Arkhon speaking penalty are prose for
-- the same reason.
--
-- ART: LINE DRAWING, printed 28. The Nazca Line Maker takes it at +30% and
-- rolls against it to draw a pattern at levels 1-3; the book says "see below"
-- and never defines it anywhere (every cache page searched for "Line Drawing"
-- and "Art: Line"). It is filed beside Art at Art's own 35% +5%, which is the
-- reading that makes the class's +30% mean something.
--
-- RIDING: WAR BISON, printed 186. Every Larhold has it; the book defines it in
-- one clause as the Horsemanship base at +10%. Horsemanship: General is 40%
-- +4% in the catalog, so this is 50% +4%, filed under Horsemanship. The name
-- is the book's own, not a Horsemanship: prefix, because that is what the
-- Larhold classes print and grant.
--
-- GAMES: the six languages stay systems NULL, with the rest of the Language:
-- family (zzzzzzzzzzzzzzzz-tag-skill-systems.sql), so the regression pin on
-- untagged skills moves 79 -> 85 on purpose. Art: Line Drawing and Riding: War
-- Bison are Rifts-only and are tagged ["rifts"] as they are inserted.
--
-- Guarded with INSERT OR IGNORE and keyed on name, which is UNIQUE, so a
-- second run changes nothing.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Quechua', 'Technical', 50, 5, 'import', 'Rifts World Book 9: South America 2 p.162',
        'The tongue of the old Inca Empire and the official language of the Empire of the Sun. Written in the common alphabet.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Aymara', 'Technical', 50, 5, 'import', 'Rifts World Book 9: South America 2 p.162',
        'The second native tongue of the Andes; the first language of a large minority of the Empire of the Sun.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Creole', 'Technical', 50, 5, 'import', 'Rifts World Book 9: South America 2 p.162',
        'Spanish, Portuguese and Amazonian tongues mixed; spoken in the northern jungles. No official writing: reading a Creole text someone else wrote is at -10%.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Arkhon', 'Technical', 50, 5, 'import', 'Rifts World Book 9: South America 2 p.162',
        'Sub-vocal grunts and clicks. Most non-Arkhons understand it at no penalty but SPEAK it at -10% (feline and canine mutants and some aliens excepted).');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Larhold', 'Technical', 50, 5, 'import', 'Rifts World Book 9: South America 2 p.162',
        'The Larhold learn it normally; every other race has a base of 40% +4% per level. Never taught to outsiders.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Amaki', 'Technical', 50, 5, 'import', 'Rifts World Book 9: South America 2 p.155',
        'The racial tongue of the Amaki of New Babylon, who speak it at 98%.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note, systems)
VALUES ('Art: Line Drawing', 'Technical', 35, 5, 'import', 'Rifts World Book 9: South America 2 p.28',
        'Named by the Nazca Line Maker (+30%), who rolls against it to draw a pattern at levels 1-3. The book never defines it; filed at Art''s own base.', '["rifts"]');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note, systems)
VALUES ('Riding: War Bison', 'Horsemanship', 50, 4, 'import', 'Rifts World Book 9: South America 2 p.186',
        'Every Larhold has it. The book defines it as the Horsemanship base at +10%: Horsemanship: General (40% +4%) plus 10.', '["rifts"]');

-- HEROES UNLIMITED'S LANGUAGE RULE, for the six new languages. Revised Heroes
-- Unlimited printed 35 gives every learned language 55% +5%, and
-- zzzzzzzzzzz-hu-skill-bases-completion.sql writes that row for every
-- 'Language: %' skill that exists WHEN IT RUNS. On a clean build this file
-- sorts first, so that sweep would cover these six; in production it ran long
-- before they existed and never will again. These rows are the sweep's own,
-- value for value, so production and a rebuild agree and the duplicate-key
-- check sees identical content.
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT name, 'heroes-unlimited', 55, 5,
       'Printed 35 gives one figure for any language other than the native tongue: 55% +5% per level.',
       'Revised Heroes Unlimited p.35'
  FROM skills
 WHERE name IN ('Language: Quechua', 'Language: Aymara', 'Language: Creole', 'Language: Arkhon',
                'Language: Larhold', 'Language: Amaki');

-- Read the result back rather than trusting the exit code.
SELECT 'the eight skills exist, citing this book' AS assertion,
       count(*) AS got,
       8 AS want
  FROM skills
 WHERE name IN ('Language: Quechua', 'Language: Aymara', 'Language: Creole', 'Language: Arkhon',
                'Language: Larhold', 'Language: Amaki', 'Art: Line Drawing', 'Riding: War Bison')
   AND source_book LIKE 'Rifts World Book 9: South America 2 p.%';

SELECT 'the six languages carry the Heroes Unlimited rule' AS assertion,
       count(*) AS got,
       6 AS want
  FROM skill_system_bases
 WHERE system = 'heroes-unlimited' AND base = 55 AND per_level = 5
   AND skill_name IN ('Language: Quechua', 'Language: Aymara', 'Language: Creole', 'Language: Arkhon',
                      'Language: Larhold', 'Language: Amaki');

SELECT 'the two non-language skills are tagged Rifts' AS assertion,
       count(*) AS got,
       2 AS want
  FROM skills WHERE name IN ('Art: Line Drawing', 'Riding: War Bison') AND systems = '["rifts"]';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-a-south-america-2-skills.sql');
