-- Two more Robot Combat Elite rows, for the NGR Intelligence Division and
-- Police O.C.C.s of Rifts World Book 5: Triax and the NGR.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-ngr-additional-elite-skills.sql
--
-- A SIBLING OF add-ngr-armored-division-skills.sql, not an edit to it. That
-- file has already been applied to every environment and is a one-shot; the
-- two machines below simply did not come up until the Intelligence Division
-- batch, because they are granted by the Intelligence Commando and the Police
-- rather than by the Armored Division. The reasoning for machine-specific rows
-- rather than the generic `Robot Combat Elite` is in that file's header and is
-- not repeated here.
--
-- WHY THESE TWO AND NOT MORE. The Intelligence Commando's grant on printed 172
-- is a CHOICE - power armour of choice, or the X-10A, X-60 or X-500 - and the
-- Police entry on printed 174 grants the X-60 outright plus a choice between
-- the X-10A and the X-535. The X-10A Predator and X-535 Jager rows already
-- exist from the Armored Division batch, so only the Flanker and the Forager
-- are new. The open half of the commando's grant, "power armour of choice",
-- is not enumerable and is stored as a choice over the Triax machines the
-- catalog holds a row for, with the book's wording in the class note.
--
-- The machines themselves stay out under BOOK-INGEST-AUDIT.md F3, as all Triax
-- power armour and robot vehicles do. An elite row is a training proficiency.
--
-- Guarded with INSERT OR IGNORE and keyed on name, which is UNIQUE, so this is
-- safe to re-run. It sorts at add-ngr-additional..., ahead of every
-- add-ngr-*-class.sql file - checked against the directory listing rather than
-- assumed from the prefix, per the filename-order rule in the class-import
-- skill.

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-60 Flanker', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.172-174',
        'Elite training in the X-60 Flanker, printed 51. Granted outright to the NGR Police and offered to the NGR Intelligence Commando.');

INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, note)
VALUES ('Robot Combat Elite: X-500 Forager', 'Pilot', 0, 0, 'import', 'Rifts World Book 5: Triax and the NGR p.172',
        'Elite training in the X-500 Forager, printed 54. Offered to the NGR Intelligence Commando as one of its elite choices.');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills
 WHERE name IN ('Robot Combat Elite: X-60 Flanker', 'Robot Combat Elite: X-500 Forager')
 ORDER BY name;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-ngr-additional-elite-skills.sql');
