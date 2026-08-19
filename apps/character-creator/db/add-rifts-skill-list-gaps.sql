-- Skills the Rifts Skill List sheet carries that the catalog lacked, and the
-- bonuses the Physical entries have always printed.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-rifts-skill-list-gaps.sql
--
-- Source: a one-page Rifts skill list, six columns, each category in its own
-- box; the first percentage is the base and the second the per-level step.
-- Parsed from PyMuPDF page coordinates, NOT from pdftotext: this sheet's six
-- columns do not share baselines, so the rendered character grid merges and
-- splits rows and reports COMPUTER REPAIR at 30+5% where the page says 25.
-- The parse was validated against the catalog itself - 120 of the 132 entries
-- that overlap agree exactly.
--
-- WHAT IS NOT HERE, deliberately:
--   - The 12 entries where the sheet and the catalog disagree on numbers. The
--     catalog's figures stand; a disagreement is not a gap.
--   - RUE renames of rows the catalog already holds under an older spelling.
--     add-rue-skills-batch.sql settled that: characters cite skills by name, so
--     a second row manufactures a duplicate. Safe-Cracking, Basic/Advanced
--     Math, Tanks and APCs and the rest are untouched.
--   - Anything ambiguous between the two. History (NW) against the catalog's
--     History: Post-Apocalypse, Advanced Fishing against Fishing, and Track &
--     Hunt Sea Animals against Hunting are all judgement calls about the books,
--     not the data, and are left alone rather than guessed.
--
-- NAMING. Sub-skills printed as bullets under a parent take the parent's name
-- as a prefix, matching the catalog's existing Lore: Magic / Language: Other /
-- Horsemanship: General. Two normalisations worth stating: the Phase World
-- trade languages print as "Space: Trade Five/Reptile" under LANGUAGE and are
-- stored as "Language: Trade Five/Reptile" rather than carrying both prefixes,
-- and the sheet's "BOTONY" is stored as Botany.


-- ===== 1. Skills the catalog did not have =====
-- Falconry is filed under MILITARY, not the TECHNICAL the sheet gives it. The
-- Long Bowman O.C.C. excludes it from Military alongside Camouflage and
-- Interrogation Techniques, and that exclusion has to be able to match.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book) VALUES
  ('Falconry',                          'Military',      30, 5, 'import', 'Rifts Skill List'),
  ('Strategy/Tactics',                  'Military',      30, 5, 'import', 'Rifts Skill List'),
  ('Trap Construction',                 'Military',      20, 4, 'import', 'Rifts Skill List'),
  ('Space: Defense Systems',            'Military',      30, 5, 'import', 'Rifts Skill List'),

  ('Locate Secret Compartments',        'Rogue',         20, 5, 'import', 'Rifts Skill List'),
  ('Streetwise: Drugs',                 'Rogue',         25, 5, 'import', 'Rifts Skill List'),

  ('Antiquarian',                       'Science',       40, 5, 'import', 'Rifts Skill List'),
  ('Botany',                            'Science',       25, 5, 'import', 'Rifts Skill List'),
  ('Geology',                           'Science',       25, 5, 'import', 'Rifts Skill List'),
  ('Ocean Geographic Surveying',        'Science',       15, 5, 'import', 'Rifts Skill List'),
  ('Physics',                           'Science',       30, 5, 'import', 'Rifts Skill List'),
  ('Undersea Farming',                  'Science',       35, 5, 'import', 'Rifts Skill List'),

  ('Doctor of Veterinary Medicine',     'Medical',       60, 5, 'import', 'Rifts Skill List'),
  ('Juicer Technology',                 'Medical',       40, 5, 'import', 'Rifts Skill List'),
  ('Toxicology',                        'Medical',       40, 5, 'import', 'Rifts Skill List'),

  ('Space: Satellite Systems',          'Mechanical',    30, 5, 'import', 'Rifts Skill List'),
  ('Space: Spacecraft Mechanics',       'Mechanical',    20, 5, 'import', 'Rifts Skill List'),
  ('Submersible Vehicle Mechanics',     'Mechanical',    25, 5, 'import', 'Rifts Skill List'),

  ('Boat: Submersibles',                'Pilot',         40, 4, 'import', 'Rifts Skill List'),
  ('Air Assault Armor',                 'Pilot',         40, 5, 'import', 'Rifts Skill List'),
  ('Combat Pod',                        'Pilot',         40, 4, 'import', 'Rifts Skill List'),
  ('Wingrider Flying Wing',             'Pilot',         15, 5, 'import', 'Rifts Skill List'),
  ('Space: Antigrav Suit',              'Pilot',         44, 4, 'import', 'Rifts Skill List'),
  ('Space: Small Spacecraft',           'Pilot',         60, 3, 'import', 'Rifts Skill List'),
  ('Space: Space Fighter',              'Pilot',         50, 3, 'import', 'Rifts Skill List'),
  ('Space: Starship',                   'Pilot',         36, 4, 'import', 'Rifts Skill List'),

  ('Radar/Sonar Operations',            'Pilot Related', 30, 5, 'import', 'Rifts Skill List'),
  ('Navigation: Stellar',               'Pilot Related', 40, 5, 'import', 'Rifts Skill List'),
  ('Navigation: Terrestrial',           'Pilot Related', 40, 5, 'import', 'Rifts Skill List'),
  ('Navigation: Underwater',            'Pilot Related', 30, 4, 'import', 'Rifts Skill List'),

  ('Undersea & Sea Survival',           'Wilderness',    25, 5, 'import', 'Rifts Skill List'),

  ('Space: Extra-Vehicular Activity',   'Physical',      40, 5, 'import', 'Rifts Skill List'),
  ('Space: Oxygen Conservation',        'Physical',      30, 5, 'import', 'Rifts Skill List'),

  ('Space: Radio: Deep Space',          'Communications',45, 5, 'import', 'Rifts Skill List'),

  ('Cyberjacking',                      'Technical',     50, 3, 'import', 'Rifts Skill List'),
  ('Law',                               'Technical',     25, 5, 'import', 'Rifts Skill List'),
  ('Language Dialects',                 'Technical',     50, 5, 'import', 'Rifts Skill List'),
  ('Language: Mongolian',               'Technical',     40, 5, 'import', 'Rifts Skill List'),
  ('Language: Trade Five/Reptile',      'Technical',     40, 5, 'import', 'Rifts Skill List'),
  ('Language: Trade Six',               'Technical',     45, 5, 'import', 'Rifts Skill List'),

  -- Lore rows follow the catalog's existing Lore: Magic / Lore: D-Bee, which
  -- are filed under Technical rather than a Lore category of their own.
  ('Lore: Astral',                      'Technical',     26, 4, 'import', 'Rifts Skill List'),
  ('Lore: Nightbane',                   'Technical',     30, 5, 'import', 'Rifts Skill List'),
  ('Lore: Nightlands',                  'Technical',     25, 5, 'import', 'Rifts Skill List'),
  ('Lore: Vampires',                    'Technical',     30, 5, 'import', 'Rifts Skill List'),
  ('Lore: Galactic/Alien',              'Technical',     25, 5, 'import', 'Rifts Skill List'),

  -- Printed under Lore: Magic but with their own percentages, so they are rows
  -- rather than prose. Left unprefixed, as the sheet prints them.
  ('Recognize Enchantment',             'Technical',     10, 5, 'import', 'Rifts Skill List'),
  ('Recognize Wards, Runes & Circles',  'Technical',     15, 5, 'import', 'Rifts Skill List');

-- Ice Skating and Snow Skiing carry bonuses, so they are inserted with them
-- rather than in the block above.
INSERT OR IGNORE INTO skills (name, category, base, per_level, source, source_book, bonuses, note) VALUES
  ('Ice Skating', 'Physical', 35, 5, 'import', 'Rifts Skill List',
   '{"attributes":{"PE":1}}',
   'Also 1D4 Spd, +1D6 S.D.C., and +1 to dodge ON ICE. The dice and the pool are not stored as bonuses (see migration 023) and the dodge is conditional, so it stays here. Pro Status counts as two skills: Figure Skating +20%, Pro Hockey +15%, Speed Skating +10%, each with its own bonuses.'),
  ('Snow Skiing', 'Physical', 40, 5, 'import', 'Rifts Skill List',
   NULL,
   'Pro Status counts as two skills, one of: Downhill Speed/Slalom (+1 P.P. & P.E., 70mph downhill), Cross Country (+1 P.S., +2 P.E., +1D4 Spd, +1D6 S.D.C., Spd +20%), Snow Boarding/Jump Skiing (+1 P.P., +1D6 S.D.C.).');


-- ===== 2. The bonuses Physical skills have always printed =====
-- These rows already existed with base 0 and per_level 0, which is correct -
-- they are not percentile - but they were granting nothing at all. Only the
-- FLAT parts go in `bonuses`; dice and S.D.C. are refused for a skill and are
-- recorded in `note` instead (migration 023 explains why).
--
-- Guarded on bonuses IS NULL so this never overwrites a hand-edited row.
UPDATE skills SET bonuses = '{"attributes":{"PS":2},"combat":{"attacks":1,"parry":2,"dodge":2,"roll":1}}',
       note = COALESCE(note || ' ', '') || 'Also +3D6 S.D.C.'
 WHERE name = 'Boxing' AND bonuses IS NULL;

UPDATE skills SET bonuses = '{"attributes":{"PS":2,"PE":1},"combat":{"roll":1}}',
       note = COALESCE(note || ' ', '') || 'Also 4D6 S.D.C.'
 WHERE name = 'Wrestling' AND bonuses IS NULL;

UPDATE skills SET bonuses = '{"attributes":{"PS":2}}',
       note = COALESCE(note || ' ', '') || 'Also +10 S.D.C.'
 WHERE name = 'Body Building & Weight Lifting' AND bonuses IS NULL;

UPDATE skills SET bonuses = '{"attributes":{"PE":1}}',
       note = COALESCE(note || ' ', '') || 'Also +4D4 Spd and +1D6 S.D.C.'
 WHERE name = 'Running' AND bonuses IS NULL;

UPDATE skills SET bonuses = '{"attributes":{"PS":1,"PP":1,"PE":1},"combat":{"roll":2}}',
       note = COALESCE(note || ' ', '') || 'Also +1D6 S.D.C.'
 WHERE name = 'Acrobatics' AND bonuses IS NULL;

UPDATE skills SET bonuses = '{"attributes":{"PS":2,"PE":2,"PP":1},"combat":{"roll":2}}',
       note = COALESCE(note || ' ', '') || 'Also +1D6 S.D.C.'
 WHERE name = 'Gymnastics' AND bonuses IS NULL;

-- Athletics (general) is deliberately NOT populated. The sheet gives "+2 roll,
-- parry & dodge, +1 P.S., +1D6 P.P., +1D8 S.D.C."; the catalog's existing note
-- says "+1 parry/dodge, +1 roll with punch/fall, +1 P.S., +1D6 Spd, +1D8
-- S.D.C." They disagree on the size of the combat bonus AND on which attribute
-- rolls, and picking one silently would be changing existing information rather
-- than filling a gap. Left for a human with the book open.


-- Read the result back rather than trusting the exit code.
SELECT 'new skills added' AS check_name, count(*) AS n
  FROM skills WHERE source_book = 'Rifts Skill List';

SELECT 'physical rows now granting bonuses (expect 7)' AS check_name, count(*) AS n
  FROM skills WHERE category = 'Physical' AND bonuses IS NOT NULL;

SELECT name, category, base, per_level, bonuses
  FROM skills WHERE bonuses IS NOT NULL ORDER BY name;

SELECT 'Falconry filed under Military' AS check_name, category AS n
  FROM skills WHERE name = 'Falconry';
