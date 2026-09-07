-- Language: Gypsy - the catalog row the four Gypsy O.C.C.s of Rifts World
-- Book 5: Triax and the NGR need, and which the catalog does not hold.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-gypsy-clan-language-skill.sql
--
-- CITED TO TRIAX, which is the difference between this row and the two the
-- NGR Army batch added. Language: Euro and Literacy: Euro were cited to RUE
-- because Euro is a Rifts-wide language that RUE printed 304 already names,
-- and Triax was merely where the need surfaced. The gypsy tongue is not like
-- that: printed 179 is where this book describes it, and nothing earlier on
-- this machine prints it at all. It is "a secret language known only to true
-- gypsies", never spoken in front of non-gypsies and never taught to
-- strangers, and it carries a dozen symbols meaning danger, hide, safe/good,
-- moved/travelling, valuable, steal, magic, friend, enemy, monster, vampire
-- and illusion/false.
--
-- NOT one of the seven new skills printed 155 lists. That section is the
-- book's own New Skills page and the survey checked all seven against the
-- catalog; every one was already held under a RUE spelling. This row is a
-- language named only inside the O.C.C. entries, which is why the skills diff
-- did not find it.
--
-- VALUES follow the CATALOG rather than being read off this book, which
-- prints no base percentage for the language itself - only the 98% the four
-- O.C.C.s grant it at, which is a class-level figure and lives in the class
-- markdown. Language: Other is held at 50 +5, and so are the twelve named
-- languages that specialise it, so this row is 50 +5 as well. Anyone
-- correcting Language: Other later should correct this too.
--
-- CATEGORY follows the catalog majority rather than the stub generator's
-- guess, which was Communications. Every one of the thirteen named
-- "Language: X" rows in the catalog is filed under Technical - Dragonese,
-- Gobblely, Demongogian, Mongolian, Old Norse, Euro, the six Trades and the
-- rest - so Language: Gypsy is Technical. This is the same reading
-- add-euro-language-skills.sql records at greater length.
--
-- Guarded with INSERT OR IGNORE and keyed on name, which is UNIQUE, so this is
-- safe to re-run. FILENAME ORDER IS EXECUTION ORDER and this file has to
-- reach the database before the four classes that reference the row. Checked
-- against the directory rather than assumed: it sorts at
-- add-gypsy-c..., ahead of add-gypsy-gifted-class.sql, add-gypsy-seer-class.sql,
-- add-gypsy-thief-class.sql and add-gypsy-wizard-thief-class.sql, which is
-- why it is named for the gypsy CLAN language rather than
-- add-gypsy-language-skill.sql - that name would have sorted after the Gifted.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Gypsy', 'Technical', 50, 5, 'import', 'Rifts World Book 5: Triax and the NGR p.179',
        'The secret spoken language of the gypsy clans of Rifts Earth. Never spoken in front of non-gypsies, let alone taught to strangers. It carries a dozen simple symbols meaning danger, hide, safe/good, moved/travelling, valuable, steal, magic, friend, enemy, monster, vampire and illusion/false. All four Gypsy O.C.C.s grant it at 98%.');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level, source_book FROM skills
 WHERE name = 'Language: Gypsy';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-gypsy-clan-language-skill.sql');
