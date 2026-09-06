-- Language: Euro and Literacy: Euro - the two catalog rows the New German
-- Republic O.C.C.s of Rifts World Book 5: Triax and the NGR need, and which
-- the catalog does not hold.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-euro-language-skills.sql
--
-- CITED TO RUE, NOT TO TRIAX, and that is deliberate. Triax is merely where
-- the need surfaced: all three NGR Army O.C.C.s grant "Literacy: Euro" and
-- "Language: Euro" outright, and printed 155 - the book's own New Skills
-- section - does NOT list either one, because neither is new. Euro is one of
-- the nine major languages of Rifts, named on RUE printed 304 as a blend of
-- Russian, German and Polish spoken by virtually all humans between England
-- and China. The skill values come from RUE printed 302, which prints
-- "Language: Other" and "Literacy: Other" as the general rows these specialise.
--
-- VALUES follow the CATALOG rather than RUE's printed per-level, and the
-- difference is worth stating rather than hiding. RUE printed 302 gives
-- Language: Other as 50% +3% per level; the catalog holds that row at 50 +5,
-- and has since the RUE import. A new row at +3 would sit beside twelve
-- named-language rows at +5 and read as a transcription error rather than as a
-- deliberate difference. The catalog's own convention wins here because this
-- row is a SPECIALISATION of a row already in it, not an independent reading
-- of the book. Anyone correcting Language: Other later should correct this too.
--
-- CATEGORY follows the catalog majority, which is not what a stub generator
-- guesses. class-check proposed Communications for both. Every one of the
-- twelve named "Language: X" rows in the catalog is filed under Technical -
-- Dragonese, Gobblely, Demongogian, Mongolian, Old Norse, the six Trades and
-- the rest - so Language: Euro is Technical. Literacy is the other way: the
-- general rows Literacy: Native Language and Literacy: Other are both
-- Communications, so Literacy: Euro is Communications. The catalog is
-- genuinely inconsistent between the two families and this script follows each
-- family rather than imposing one answer on both.
--
-- Guarded with INSERT OR IGNORE and keyed on name, which is UNIQUE, so this is
-- safe to re-run. It sorts at add-e..., well ahead of the add-ngr-*-class.sql
-- files that reference these rows - checked against the directory rather than
-- assumed, per the filename-order rule in the class-import skill.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Language: Euro', 'Technical', 50, 5, 'import', 'Rifts Ultimate Edition p.302-304',
        'One of the nine major languages of Rifts. RUE p.304 names it a blend of Russian, German and Polish. The native tongue of the New German Republic, whose O.C.C.s in Rifts World Book 5 grant it with a bonus.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Literacy: Euro', 'Communications', 30, 5, 'import', 'Rifts Ultimate Edition p.302-304',
        'Reading and writing Euro. Values follow the catalog Literacy: Other row this specialises.');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level, source_book FROM skills
 WHERE name IN ('Language: Euro', 'Literacy: Euro')
 ORDER BY name;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-euro-language-skills.sql');
