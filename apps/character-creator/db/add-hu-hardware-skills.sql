-- The 5 skills the Hardware power category grants and the catalog lacks.
-- Printed 73-78.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-hardware-skills.sql
--
-- These are PERCENTAGE SKILLS, not class abilities, which is why they are rows:
-- each one has a number that a player rolls against and that the sheet has a
-- column for. `Recognize Weapon Quality` and `Field Armorer & Munitions Expert`
-- were already here on the same reasoning.
--
-- FOUR OF THE FIVE PRINT NO PER-LEVEL GAIN, so they carry `per_level` 0 and
-- never advance. That is what the book states rather than a value left blank:
-- Hot Wiring, Building Super Vehicles and Make and Modify Weapons each print a
-- flat percentage and then a long table of situational PENALTIES instead, and
-- those tables are in the notes. Only the two `Recognize` skills print
-- "+5% per each additional level of experience".
--
-- `Recognize Vehicle Quality` HAS TWO NUMBERS - 50% from personal examination
-- and 25% by observation from a distance - and a skill row holds one. The
-- examination figure is stored, matching `Recognize Weapon Quality`, which
-- prints the same pair and whose catalog row is 25. The two rows therefore
-- disagree about which half to store; the description says so on both counts.
--
-- THE 50% WAS RECOVERED FROM THE INK. The OCR dropped "50%+5%" from printed 75
-- entirely - the cached text reads "Recognize quality from personal
-- examination:" followed straight by "per each additional level of experience",
-- and the geometry TSV agrees, so it is not a column-order artefact. Rendering
-- the page at 300 dpi shows the figure plainly, set off by a wide gap that is
-- the likeliest reason it was lost. Same class of fault as the missing `Blind`
-- heading in the spell import.
--
-- `Building Super Vehicles` IS PRINTED TWICE AND THE TWO DISAGREE: the heading
-- on printed 75 says 94% and the asterisked note four lines below says "his
-- base building super vehicles skill drops from 92% to 64%". The HEADING is
-- stored, because it is the line that states the skill; the note is stating a
-- penalty and misquotes its own base.
--
-- The prose goes in `note`. The skills table has no `description` column - it
-- carries `name`, `category`, `base`, `per_level`, `systems`, `source`,
-- `source_book`, `note`, `bonuses`, `level_bonuses` and `base_formula` - which
-- the first draft of this script got wrong and the apply refused outright.
--
-- Guarded on `NOT EXISTS` so re-running is a no-op, and the note is written
-- only where there is none, so a hand edit survives.

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Hot Wiring', 'Electrical', 92, 0, 'import', 'Revised Heroes Unlimited p.73', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Hot Wiring');

UPDATE skills SET note = 'Bypassing an electrical system to make it run without its key or its code. Cars, alarms, telephone lines, electrical locks, key pads, doors and elevators. The book prints a long table of cumulative penalties rather than a per-level gain: -5% for a car built after 1980, -10% for a foreign one, -10% for an electric lock or entry key pad, -5% to -30% by the sophistication of an alarm system, -10% to -35% by that of an electrical lock, -15% to tap a telephone line, and -55% to work on super-sophisticated circuitry such as a robot''s or an alien''s. Each entry carries its own time, from 1D4 melees to 6D4 minutes.'
 WHERE name = 'Hot Wiring' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Recognize Quality and Complexity of Electrical Systems', 'Technical', 50, 5, 'import', 'Revised Heroes Unlimited p.74', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Recognize Quality and Complexity of Electrical Systems');

UPDATE skills SET note = 'Accurately estimating the level of complexity, the specific difficulties and the time a job will take - a repair, a bypass. A failed roll means the character has greatly underestimated the work.'
 WHERE name = 'Recognize Quality and Complexity of Electrical Systems' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Building Super Vehicles', 'Mechanical', 94, 0, 'import', 'Revised Heroes Unlimited p.75', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Building Super Vehicles');

UPDATE skills SET note = 'Building, repairing, custom modifying and designing all types of vehicles. Without the automotive mechanic skill the base for a ground vehicle drops to 64%, and without aircraft mechanics the base for an air vehicle does the same. A table of cumulative penalties applies to the work itself: -10% for armour or turrets, -5% for wiring, weapons or performance, -10% for a high-tech gimmick, -15% for V.T.O.L., -25% for hovercraft, -20% underwater, -50% for space, -40% for robotics, -10% or -20% for an original design, -20% for a rush job, and -10% for every twenty hours worked without six hours of sleep.'
 WHERE name = 'Building Super Vehicles' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Recognize Vehicle Quality', 'Technical', 50, 5, 'import', 'Revised Heroes Unlimited p.75', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Recognize Vehicle Quality');

UPDATE skills SET note = 'An expert eye for a vehicle''s capabilities - S.D.C., speed, manoeuvrability, weapons. 50% by personal examination, and only 25% by observation from a distance; both gain +5% per additional level of experience. The base stored here is the examination figure.'
 WHERE name = 'Recognize Vehicle Quality' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Make and Modify Weapons', 'Military', 92, 0, 'import', 'Revised Heroes Unlimited p.76', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Make and Modify Weapons');

UPDATE skills SET note = 'Making, repairing and custom modifying any weapon the character holds a W.P. for, and no others. An ancient W.P. means sharpening, cleaning, treating and balancing a blade for throwing or parrying, and forging one from scratch. A modern W.P. means cleaning, unjamming, conditioning and maintaining the weapon, lengthening or shortening the barrel, fitting a hair trigger, and adapting it to a slug two grades larger or smaller, within the largest and smallest calibres that weapon type has.'
 WHERE name = 'Make and Modify Weapons' AND note IS NULL;

-- ASSERTIONS.

SELECT 'five Hardware skills exist' AS assertion, count(*) AS got, 5 AS want
  FROM skills
 WHERE name IN ('Hot Wiring', 'Recognize Quality and Complexity of Electrical Systems',
                'Building Super Vehicles', 'Recognize Vehicle Quality',
                'Make and Modify Weapons');

-- BOUNDED BY NAME. This counted every row citing this book, which was the
-- same number only while these five were the only ones. A rebuild applies
-- the directory in sorted order, so one more HU skill script sorting ahead
-- of this one makes an unbounded count read high on every rebuild.
SELECT 'every one cites the Revised core' AS assertion, count(*) AS got, 5 AS want
  FROM skills WHERE source_book LIKE 'Revised Heroes Unlimited%'
   AND name IN ('Hot Wiring', 'Recognize Quality and Complexity of Electrical Systems',
                'Building Super Vehicles', 'Recognize Vehicle Quality',
                'Make and Modify Weapons');

SELECT 'every one carries its note' AS assertion, count(*) AS got, 5 AS want
  FROM skills
 WHERE source_book LIKE 'Revised Heroes Unlimited%' AND length(note) > 80
   AND name IN ('Hot Wiring', 'Recognize Quality and Complexity of Electrical Systems',
                'Building Super Vehicles', 'Recognize Vehicle Quality',
                'Make and Modify Weapons');

-- The two that advance, and the three that do not. Stated rather than trusted,
-- because a per_level of 0 and a per_level nobody set look identical.
SELECT 'two advance at +5% per level' AS assertion, count(*) AS got, 2 AS want
  FROM skills WHERE source_book LIKE 'Revised Heroes Unlimited%' AND per_level = 5
   AND name IN ('Hot Wiring', 'Recognize Quality and Complexity of Electrical Systems',
                'Building Super Vehicles', 'Recognize Vehicle Quality',
                'Make and Modify Weapons');

SELECT 'and three print no per-level gain at all' AS assertion, count(*) AS got, 3 AS want
  FROM skills WHERE source_book LIKE 'Revised Heroes Unlimited%' AND per_level = 0
   AND name IN ('Hot Wiring', 'Recognize Quality and Complexity of Electrical Systems',
                'Building Super Vehicles', 'Recognize Vehicle Quality',
                'Make and Modify Weapons');

SELECT 'Building Super Vehicles stores the HEADING figure' AS assertion,
       count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Building Super Vehicles' AND base = 94;

SELECT 'Recognize Vehicle Quality stores the EXAMINATION figure' AS assertion,
       count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Recognize Vehicle Quality' AND base = 50;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-hardware-skills.sql');
