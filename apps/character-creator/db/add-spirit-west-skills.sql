-- W.P. Tomahawk - the one skill Rifts World Book 15: Spirit West grants that
-- the catalog lacks, found while importing the Tribal Warrior (printed 39).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-spirit-west-skills.sql
--
-- The survey recorded ZERO new skills for this book, and that was right about
-- what it measured: there is no new-skills section and no Base Skill line.
-- This row is the Triax lesson repeating - a class can grant a skill the book
-- never calls new. The Tribal Warrior's O.C.C. Skills list W.P. Tomahawk as a
-- weapon proficiency of its own and rate it the same as W.P. Knife.
--
-- WHY NOT W.P. AXE. The catalog's W.P. Axe (Rifts Ultimate Edition p.302-303)
-- says in its own level-1 note that axes are not designed for throwing, and
-- its throwing bonus starts at level 5. The book's tomahawk is a THROWING axe
-- whose quick-draw and paired-weapon rules (printed 38) are built on throwing.
-- Mapping it to W.P. Axe would give the Tribal Warrior the wrong table.
--
-- WHY NOT W.P. KNIFE. The book grants both, side by side, on the same list; a
-- class may grant a skill once, so folding the tomahawk into W.P. Knife would
-- silently cost the class one of its two.
--
-- So it is a row of its own carrying W.P. Knife's level bonuses - read from
-- production on 2026-09-10 - worded for a tomahawk. The 2D6 S.D.C. figure is
-- the book's own, from the Tribal Warrior's equipment line on printed 39.

INSERT INTO skills
  (name, category, base, per_level, systems, source, source_book, note, bonuses, level_bonuses)
VALUES
  ('W.P. Tomahawk', 'Weapon Proficiencies', 0, 0, NULL, 'import',
   'Rifts World Book 15: Spirit West p.39',
   'Tomahawks and small throwing axes. The book grants it as a weapon proficiency of its own and rates it the same as W.P. Knife, so its bonuses are W.P. Knife''s (Rifts Ultimate Edition p.327). Not W.P. Axe, which is not designed for throwing.',
   NULL,
   '[{"level":1,"applies_when":"throwing a tomahawk","combat":{"strike":1}},{"level":1,"applies_when":"with a tomahawk","combat":{"parry":1}},{"level":1,"note":"Tomahawks and small throwing axes; a tomahawk does 2D6 S.D.C."},{"level":2,"applies_when":"with a tomahawk","combat":{"strike":1}},{"level":3,"applies_when":"throwing a tomahawk","combat":{"strike":1}},{"level":3,"applies_when":"with a tomahawk","combat":{"parry":1}},{"level":4,"applies_when":"with a tomahawk","combat":{"strike":1}},{"level":6,"applies_when":"throwing a tomahawk","combat":{"strike":1}},{"level":6,"applies_when":"with a tomahawk","combat":{"parry":1}},{"level":7,"applies_when":"with a tomahawk","combat":{"strike":1}},{"level":8,"applies_when":"throwing a tomahawk","combat":{"strike":1}},{"level":9,"applies_when":"with a tomahawk","combat":{"parry":1}},{"level":10,"applies_when":"throwing a tomahawk","combat":{"strike":1}},{"level":10,"applies_when":"with a tomahawk","combat":{"strike":1}},{"level":12,"applies_when":"with a tomahawk","combat":{"parry":1}},{"level":13,"applies_when":"throwing a tomahawk","combat":{"strike":1}},{"level":13,"applies_when":"with a tomahawk","combat":{"strike":1}}]');

-- Read the result back rather than trusting the exit code.
SELECT 'W.P. Tomahawk is present' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'W.P. Tomahawk' AND category = 'Weapon Proficiencies';

-- Seventeen level-bonus entries, the same count W.P. Knife carries.
SELECT 'it carries all seventeen of W.P. Knife''s entries' AS assertion,
       json_array_length(level_bonuses) AS got, 17 AS want
  FROM skills WHERE name = 'W.P. Tomahawk';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-spirit-west-skills.sql');
