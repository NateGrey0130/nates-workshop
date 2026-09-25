-- The four languages Pantheons of the Megaverse added, cited to the page that
-- names them.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-potm-language-citations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-potm-language-citations.sql
--
-- Two class imports wrote these rows with source_book set to the bare alias
-- 'pantheons-of-the-megaverse'. The alias resolves to the right book, so they
-- were attributed correctly, but nothing said where in it they came from:
-- source-coverage.mjs counted them as the book's only 4 untraceable rows. Every
-- other language row cites a title and a page.
--
-- The book gives none of the four an entry of its own. Each is named in the
-- "Skills of Note" of the class that needed it, at 98%, and that is the page
-- cited (cache page = printed + 1, per the survey):
--
--   Language: Troll/Giant, Language: Ancient Greek
--     add-greater-cyclops-class.sql - Greater Cyclops, printed 92 (cache p093):
--     "Speak Troll/Giant, Dragonese/Elf and Ancient Greek"
--   Language: Dwarven, Language: Old Norse
--     add-asgardian-dwarf-class.sql - Typical Asgardian Dwarf, printed 166
--     (cache p167): "Know the Dwarven languages, Dragonese/Elven and Old Norse"
--
-- Old Norse is named on other pages too (the Norse gods' stat blocks), but the
-- dwarf's is the class the row was created for; the high elf's INSERT OR IGNORE
-- sorts after it and never wrote the row.
--
-- Guarded on the bare alias, so a citation someone has since corrected by hand
-- is left alone, and a second run changes nothing.
UPDATE skills SET source_book = 'Rifts Conversion Book Two: Pantheons of the Megaverse p.92'
 WHERE name IN ('Language: Troll/Giant', 'Language: Ancient Greek')
   AND source_book = 'pantheons-of-the-megaverse';
UPDATE skills SET source_book = 'Rifts Conversion Book Two: Pantheons of the Megaverse p.166'
 WHERE name IN ('Language: Dwarven', 'Language: Old Norse')
   AND source_book = 'pantheons-of-the-megaverse';

SELECT 'no skill cites the bare alias' AS assertion,
       count(*) AS got,
       0 AS want
  FROM skills WHERE source_book = 'pantheons-of-the-megaverse';
SELECT 'the four languages cite a page of the book' AS assertion,
       count(*) AS got,
       4 AS want
  FROM skills
 WHERE name IN ('Language: Troll/Giant', 'Language: Ancient Greek', 'Language: Dwarven', 'Language: Old Norse')
   AND source_book IN ('Rifts Conversion Book Two: Pantheons of the Megaverse p.92',
                       'Rifts Conversion Book Two: Pantheons of the Megaverse p.166');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-potm-language-citations.sql');
