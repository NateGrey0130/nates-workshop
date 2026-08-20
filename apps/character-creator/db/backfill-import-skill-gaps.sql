-- Skill catalog gaps left by the class imports.
--
-- One-off data script, run once per environment. NOT a migration - it fills
-- and adds rows, no schema.
--
--   npx wrangler d1 execute DB --local --file apps/character-creator/db/backfill-import-skill-gaps.sql
--
-- Three stub rows created by class imports get real bases, and five skills
-- that exist only as names in classes' only/except lists become rows so those
-- pickers can actually offer them.
--
-- NOT PAGE-SOURCED. The imported page ranges never included the skills
-- chapters, so these numbers are transcribed from memory and every row says
-- so in its note column - verify against the book, like the hand-transcribed
-- classes. Categories follow where the citing class files the skill (the
-- Priest of Light's related list offers Heraldry under Military), because
-- making those only-lists functional is the point of the rows.
--
-- The stub updates guard on base = 0 so a hand-corrected value is never
-- overwritten; the new rows guard with INSERT OR IGNORE for the same reason.


-- Lore: Religion (cited by priest-of-light)
UPDATE skills SET base = 30, per_level = 5, note = 'base transcribed from memory - verify against the book'
 WHERE name = 'Lore: Religion' AND base = 0 AND source = 'import';

-- Basic Mechanics (cited by glitter-boy)
UPDATE skills SET base = 30, per_level = 5, note = 'base transcribed from memory - verify against the book'
 WHERE name = 'Basic Mechanics' AND base = 0 AND source = 'import';

-- General Repair & Maintenance (cited by glitter-boy)
UPDATE skills SET base = 35, per_level = 5, note = 'base transcribed from memory - verify against the book'
 WHERE name = 'General Repair & Maintenance' AND base = 0 AND source = 'import';

-- Heraldry (cited by the priest-of-light related list)
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, note)
VALUES ('Heraldry', 'Military', 25, 5, 'import', 'base transcribed from memory - verify against the book');

-- Interrogation Techniques (cited by the priest-of-light related list)
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, note)
VALUES ('Interrogation Techniques', 'Military', 40, 5, 'import', 'base transcribed from memory - verify against the book');

-- Military Etiquette (cited by the glitter-boy related list)
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, note)
VALUES ('Military Etiquette', 'Military', 35, 5, 'import', 'base transcribed from memory - verify against the book');

-- Animal Husbandry (cited by the mind-melter related list)
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, note)
VALUES ('Animal Husbandry', 'Medical', 35, 5, 'import', 'base transcribed from memory - verify against the book');

-- Brewing (cited by the mind-melter related list)
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, note)
VALUES ('Brewing', 'Medical', 25, 5, 'import', 'base transcribed from memory - verify against the book');

-- Read the result back rather than trusting the exit code.
SELECT name, category, base, per_level FROM skills WHERE name IN ('Lore: Religion', 'Basic Mechanics', 'General Repair & Maintenance', 'Heraldry', 'Interrogation Techniques', 'Military Etiquette', 'Animal Husbandry', 'Brewing') ORDER BY name;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-import-skill-gaps.sql');
