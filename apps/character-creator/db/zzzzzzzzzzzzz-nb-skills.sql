-- The skills half of step 2 of the Nightbane extraction plan
-- (apps/character-creator/docs/surveys/nightbane-core.md). Printed 48-59.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzz-nb-skills.sql
--
-- THE BOOK DESCRIBES 130 SKILLS AND THIS FILE ADDS ONE. Every description was
-- read (one extraction pass over printed 48-60) and compared, base and per-level
-- percentage, against the live catalog. 88 match exactly; 27 are weapon
-- proficiencies and hand to hand, which print bonus schedules rather than
-- percentages; the rest were spelling (T.V./Video, S.C.U.B.A., W.P. Polearm)
-- or a heading the catalog already holds under its own name (Criminal Sciences
-- & Forensics is `Forensics`, 35%/+5% on both). Counter-Tracking and Forensic
-- Medicine are on printed 48's list and have no description of their own - each
-- is a sentence inside another skill's entry - so there is nothing to store.
--
-- 1. ONE NEW SKILL: Lore: Geomancy or Lines of Power, 30% +5%, printed 57. Named
--    in the catalog's `Lore: X` form (the book prints `Lore - X`). `systems` is
--    left NULL, the way Heroes Unlimited left its new skills: a lore skill is not
--    one game's.
--
-- 2. TWO SKILLS THIS GAME PRINTS AT ITS OWN PERCENTAGE, as `nightbane` rows in
--    skill_system_bases - the mechanism BOOK-INGEST-AUDIT F83 built for exactly
--    this, and Heroes Unlimited's 87 rows used first. Both read off printed 57:
--      Lore: Demons & Monsters  35% +5%  (catalog 25% +5%)
--      Research                 50% +5%  (catalog 40% +5%)
--    The book also halves the Demons & Monsters skill when the subject is a
--    Nightbane; that rule is not a number and goes in the row's note.
--
-- 3. FIVE RE-CITATIONS. These rows cited `Rifts Skill List`, a compiled index
--    that is not a Palladium book and cannot be checked against a page. This book
--    prints each one's full description with the SAME base and per-level figure
--    the row already holds, so the citation moves to the page. The update is
--    guarded on the old citation, so it touches nothing a later fix has moved:
--      Toxicology        40% +5%  printed 52
--      Strategy/Tactics  30% +5%  printed 52
--      Lore: Nightbane   30% +5%  printed 57
--      Lore: Nightlands  25% +5%  printed 57
--      Lore: Vampires    30% +5%  printed 57
--    Four more rows citing that list are printed in this book too - the modern
--    W.P.s (Revolver, Automatic Pistol, Bolt Action Rifle, Automatic and
--    Semi-automatic Rifles) - but a W.P. prints no percentage to agree on, and
--    this book prints their bonuses only as a generic schedule (printed 60). A
--    name on a list is not evidence the row came from here, so they are not moved.

INSERT INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Lore: Geomancy or Lines of Power', 'Technical', 30, 5, NULL, 'import', 'Nightbane RPG p.57', NULL);

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Lore: Demons & Monsters', 'nightbane', 35, 5,
       'Nightbane halves the effective skill level when the subject is a Nightbane (printed 57).',
       'Nightbane RPG p.57'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Lore: Demons & Monsters');

INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, note, source_book)
SELECT 'Research', 'nightbane', 50, 5, NULL, 'Nightbane RPG p.57'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Research');

UPDATE skills SET source_book = 'Nightbane RPG p.52'
 WHERE name = 'Toxicology' AND source_book = 'Rifts Skill List';

UPDATE skills SET source_book = 'Nightbane RPG p.52'
 WHERE name = 'Strategy/Tactics' AND source_book = 'Rifts Skill List';

UPDATE skills SET source_book = 'Nightbane RPG p.57'
 WHERE name = 'Lore: Nightbane' AND source_book = 'Rifts Skill List';

UPDATE skills SET source_book = 'Nightbane RPG p.57'
 WHERE name = 'Lore: Nightlands' AND source_book = 'Rifts Skill List';

UPDATE skills SET source_book = 'Nightbane RPG p.57'
 WHERE name = 'Lore: Vampires' AND source_book = 'Rifts Skill List';

-- Read the result back. This batch asserts its OWN rows and nothing else.
SELECT 'the new lore skill is in, at 30/+5' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Lore: Geomancy or Lines of Power' AND base = 30 AND per_level = 5
   AND category = 'Technical' AND source_book = 'Nightbane RPG p.57';

SELECT 'two nightbane per-system bases' AS assertion, count(*) AS got, 2 AS want
  FROM skill_system_bases WHERE system = 'nightbane'
   AND ((skill_name = 'Lore: Demons & Monsters' AND base = 35 AND per_level = 5)
     OR (skill_name = 'Research' AND base = 50 AND per_level = 5));

SELECT 'five skills re-cited to the page' AS assertion, count(*) AS got, 5 AS want
  FROM skills WHERE source_book IN ('Nightbane RPG p.52', 'Nightbane RPG p.57')
   AND name IN ('Toxicology', 'Strategy/Tactics', 'Lore: Nightbane', 'Lore: Nightlands', 'Lore: Vampires');

SELECT 'and none of the five still cites the compiled list' AS assertion, count(*) AS got, 0 AS want
  FROM skills WHERE source_book = 'Rifts Skill List'
   AND name IN ('Toxicology', 'Strategy/Tactics', 'Lore: Nightbane', 'Lore: Nightlands', 'Lore: Vampires');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzz-nb-skills.sql');
