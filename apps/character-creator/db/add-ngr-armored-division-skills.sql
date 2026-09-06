-- The seven Robot Combat Elite rows the NGR Armored Division O.C.C.s of Rifts
-- World Book 5: Triax and the NGR need, one per Triax machine the book names.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-ngr-armored-division-skills.sql
--
-- WHY MACHINE-SPECIFIC ROWS RATHER THAN THE GENERIC ONE. The catalog already
-- holds a generic `Robot Combat Elite` AND two machine-specific rows -
-- `Robot Combat Elite: Glitter Boy` and `Robot Combat Elite: SAMAS` - so the
-- pattern is established, and it is established for exactly this case: a class
-- built around named machines. The Power Armor Commando is granted elite
-- training in three specific machines and the Robot Combat Pilot in three plus
-- one of choice. Collapsing those into one generic row would grant a commando
-- ONE elite proficiency where the book grants three, which under-grants rather
-- than simplifies.
--
-- THE MACHINES THEMSELVES ARE NOT IMPORTED AND WILL NOT BE. All seven are
-- vessels under BOOK-INGEST-AUDIT.md F3 - power armour and robot vehicles with
-- M.D.C. by location and several numbered weapon systems each - so there is no
-- `gear` row for any of them and there is not meant to be. That is not a
-- contradiction: a Robot Combat Elite row is a TRAINING PROFICIENCY, base 0
-- with no percentage, and it is meaningful whether or not the machine it names
-- can be stored. The two rows already in the catalog work the same way.
--
-- NAMES follow the CLASS ENTRIES on printed 164 and 165 rather than the
-- Contents, because the book calls two of these machines different things in
-- different places. The Contents lists "X-535 Hunter" (printed 55) and "X-545
-- Super Hunter" (printed 60); printed 164 grants "Robot Combat Elite: Jager
-- (both types)" and names them X-535 Jager and X-545 Super Jager; printed 169
-- writes "X-545 Jager Super Hunter". The class entry is what grants the skill,
-- so the class entry's spelling wins and the others are recorded here.
--
-- Base 0 and per_level 0, like every other Robot Combat and W.P. row: these
-- are proficiencies, not percentile skills. Category Pilot, matching the
-- generic row and both existing machine-specific ones.
--
-- Guarded with INSERT OR IGNORE and keyed on name, which is UNIQUE, so this is
-- safe to re-run. It sorts at add-ngr-a..., ahead of the four
-- add-ngr-*-class.sql files that reference these rows - checked against the
-- directory listing rather than assumed from the prefix, per the filename-order
-- rule in the class-import skill.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: T-31 Super Trooper', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.164',
        'Elite training in the T-31 Super Trooper power armour, printed 42. Standard issue to the NGR Power Armor Commando.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-10A Predator', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.164',
        'Elite training in the X-10A Predator power armour, printed 49.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-535 Jager', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.164',
        'Elite training in the X-535 Jager, printed 55. The Contents calls the same machine the X-535 Hunter.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-545 Super Jager', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.164',
        'Elite training in the X-545 Super Jager, printed 60. The Contents calls it the Super Hunter and printed 169 writes Jager Super Hunter.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-1000 Ulti-Max', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.165',
        'Elite training in the X-1000 Ulti-Max robot vehicle, printed 68.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-2000 Dyna-Max', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.165',
        'Elite training in the X-2000 Dyna-Max robot vehicle, printed 70. Standard issue to the NGR Robot Combat Pilot.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-2500 Black Knight', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.165',
        'Elite training in the X-2500 Black Knight robot vehicle, printed 73.');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills
 WHERE source_book LIKE 'Rifts World Book 5%' AND name LIKE 'Robot Combat Elite:%'
 ORDER BY name;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-ngr-armored-division-skills.sql');
