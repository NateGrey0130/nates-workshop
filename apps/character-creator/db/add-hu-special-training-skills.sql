-- The 4 skills the Special Training power category grants and the catalog lacks.
-- Printed 153-161.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-special-training-skills.sql
--
-- Each prints a flat percentage and no per-level gain, so `per_level` is 0 and
-- they never advance - the same shape as three of the five Hardware skills, and
-- what the book states rather than a blank.
--
-- FOUR AND NOT SEVEN. Three more of the category's "special skills" resolve to
-- rows the catalog already has under other names, and each was checked by
-- reading both:
--
--   the book prints             the catalog holds
--   Recognize and Identify      Identify Plants & Fruit   the same skill, and the
--   Plants (86%)                (25%)                     book's own -6% for processed
--                                                         poisons and -10% for processed
--                                                         herbs are qualifications of it
--   Trap/Snare Animals (80%)    Track & Trap Animals      pit traps, snares, trip wires,
--                               (20%)                     nets, steel and drop-fall traps
--   Computer Hacking (96%)      Computer Hacking (15%)    the same row, and the sleuth is
--                                                         simply better at it than the
--                                                         Hardware Electrical character
--
-- Where the percentages differ the CLASS carries the book's figure as its
-- `base`, which is what the frontmatter rule asks for; the catalog row keeps
-- the number its own book printed.
--
-- SLEIGHT OF HAND IS NOT ONE OF THESE and is not a skill row at all. Printed
-- 159 gives it no percentage - what it grants is bonuses to four OTHER skills
-- (+5% palming, +5% pick pockets, +10% escape artist, +6% concealment) and a
-- table of penalties for picking a lock or escaping bonds. A row with no base
-- that raises other rows is an ability, and the Stage Magician carries it as
-- one.
--
-- Guarded on `NOT EXISTS` so re-running is a no-op, and the note is written
-- only where there is none.

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Feign Death', 'Physical', 96, 0, 'import', 'Revised Heroes Unlimited p.154', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Feign Death');

UPDATE skills SET note = 'Bio-feedback and meditation that drop the body into a death-like trance. The metabolic rate slows so far that body temperature falls, the pulse becomes indistinguishable and breathing seems to stop; without hospital facilities even a medical doctor is likely to believe the character dead. Six melees of meditative preparation, and it can be held for days without harm. In that suspended state drugs, toxins and chemical damage stop immediately - and take effect the instant the trance is broken.'
 WHERE name = 'Feign Death' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'The Cleansing Spirit', 'Physical', 89, 0, 'import', 'Revised Heroes Unlimited p.154', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'The Cleansing Spirit');

UPDATE skills SET note = 'Willing the body to destroy disease, drugs or chemicals and to heal - bio-feedback taken far enough to boost recuperative power a hundredfold. It needs a deep, uninterrupted trance in which the character can neither converse nor fight nor do anything else, which leaves him open to attack.'
 WHERE name = 'The Cleansing Spirit' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Disguise Scent', 'Wilderness', 82, 0, 'import', 'Revised Heroes Unlimited p.156', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Disguise Scent');

UPDATE skills SET note = 'Making one''s own scent smell like something else - a deer hunter smelling like a deer. Reducing the scent to nothing instead is far harder, at -40%; one technique is height, letting the wind sweep the scent up and away out of the animal''s range. A failed roll means the scent is neither concealed nor disguised.'
 WHERE name = 'Disguise Scent' AND note IS NULL;

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Modify Weapon Cartridges', 'Military', 90, 0, 'import', 'Revised Heroes Unlimited p.156', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Modify Weapon Cartridges');

UPDATE skills SET note = 'Modifying weapon ammunition: dum dums, hollow points, full metal jacketed and other special cartridges. A failed roll is a dud.'
 WHERE name = 'Modify Weapon Cartridges' AND note IS NULL;

-- ASSERTIONS.

SELECT 'four Special Training skills exist' AS assertion, count(*) AS got, 4 AS want
  FROM skills
 WHERE name IN ('Feign Death', 'The Cleansing Spirit', 'Disguise Scent',
                'Modify Weapon Cartridges');

SELECT 'every one carries its note and cites the core' AS assertion,
       count(*) AS got, 4 AS want
  FROM skills
 WHERE name IN ('Feign Death', 'The Cleansing Spirit', 'Disguise Scent',
                'Modify Weapon Cartridges')
   AND source_book LIKE 'Revised Heroes Unlimited%' AND length(note) > 80;

SELECT 'none of the four advances with experience' AS assertion, count(*) AS got, 4 AS want
  FROM skills
 WHERE name IN ('Feign Death', 'The Cleansing Spirit', 'Disguise Scent',
                'Modify Weapon Cartridges')
   AND per_level = 0;

-- The three that were NOT created, because the catalog already holds them.
SELECT 'the three same-skill cases were not duplicated' AS assertion,
       count(*) AS got, 0 AS want
  FROM skills
 WHERE name IN ('Recognize and Identify Plants', 'Trap/Snare Animals');

SELECT 'and the rows they resolve to are untouched' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE name IN ('Identify Plants & Fruit', 'Track & Trap Animals', 'Computer Hacking');

INSERT INTO data_script_runs (filename) VALUES ('add-hu-special-training-skills.sql');
