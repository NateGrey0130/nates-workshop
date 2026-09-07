-- Language: Gargoyle and Language: Brodkil - the two genuinely new skill rows
-- Rifts World Book 5: Triax and the NGR prints, and the last two rows the
-- survey's extraction plan asks this book for.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-gargoyle-and-brodkil-languages.sql
--
-- CITED TO PRINTED 155, the book's own New Skills section, which is where both
-- are printed. Its Language Update paragraph reads: "The following additional
-- languages are reasonably common place in Europe: Gargoyle, Brodkil, and
-- Demongogian". Three names, and only two of them are new here - the catalog
-- already holds Language: Demongogian.
--
-- THESE ARE THE ONLY TWO NEW SKILLS IN THE BOOK, and that is the survey's
-- finding rather than an assumption. Printed 155 prints seven new skills; the
-- catalog already held all seven under RUE's spellings, so they were false gaps
-- rather than imports. The Gypsy batch added a third row, Language: Gypsy, and
-- that one is NOT from this page at all - it is named only inside the Gypsy
-- O.C.C. entries and is cited to printed 179 where the book describes it.
--
-- LANGUAGE: BRODKIL IS GRANTED BY NO CLASS IN THIS BOOK, and it is imported
-- anyway. It is a real catalog row a character can take as a language of
-- choice, the book prints it in the same sentence as Gargoyle, and leaving it
-- out would close this book's skills work one row short of what the survey
-- planned. The brodkil themselves are an NPC race here; nothing in the twenty-
-- one playable classes speaks it by default.
--
-- VALUES follow the CATALOG rather than being read off this book, which prints
-- no base percentage for either - only the 98% three gargoyle R.C.C.s grant
-- Gargoyle at, which is a class-level figure and lives in the class markdown.
-- Language: Other is held at 50 +5, and so are the named languages that
-- specialise it, so both of these are 50 +5. This is the same reading
-- add-euro-language-skills.sql and add-gypsy-clan-language-skill.sql record.
--
-- CATEGORY follows the catalog majority rather than the stub generator's
-- guess, which was Communications. Every named "Language: X" row in the catalog
-- is filed under Technical - Dragonese, Gobblely, Demongogian, Mongolian, Old
-- Norse, Euro, Gypsy, the six Trades and the rest - so both of these are
-- Technical.
--
-- Guarded with INSERT OR IGNORE and keyed on name, which is UNIQUE, so this is
-- safe to re-run. FILENAME ORDER IS EXECUTION ORDER and this file has to reach
-- the database before the classes that reference Language: Gargoyle. Checked
-- against the directory rather than assumed: it sorts at add-gargoyle-a...,
-- ahead of add-gargoyle-class.sql, add-gargoyle-lord-class.sql,
-- add-gargoyle-mage-class.sql, add-gargoylite-class.sql and
-- add-gurgoyle-class.sql.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Gargoyle', 'Technical', 50, 5, 'import', 'Rifts World Book 5: Triax and the NGR p.155',
        'The tongue of the gargoyle sub-demons, reasonably common in Europe since the coming of the rifts. The Gargoyle, Gurgoyle and Gargoyle Lord R.C.C.s all speak it at 98%.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Brodkil', 'Technical', 50, 5, 'import', 'Rifts World Book 5: Triax and the NGR p.155',
        'The tongue of the brodkil, reasonably common in Europe. No playable class in Rifts World Book 5 grants it; it is a language of choice.');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level, source_book FROM skills
 WHERE name IN ('Language: Gargoyle', 'Language: Brodkil')
 ORDER BY name;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-gargoyle-and-brodkil-languages.sql');
