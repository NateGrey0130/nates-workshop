-- Heroes Unlimited's OWN skill percentages, for the 48 skills where they
-- disagree with the catalog's. `BOOK-INGEST-AUDIT` F83, migration 061.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzz-hu-skill-system-bases.sql
--
-- IT IS A DIFFERENT GAME. Printed 30-36 give every skill its own base, and of
-- the 55 names this book shares with the catalog, 48 disagree - Computer
-- Operation 60% against 40%, Prowl 46%/+8 against 25%/+5. Seven agree and get
-- no row: Astrophysics, Escape Artist, Forensics, Locksmith,
-- Motorcycles & Snowmobiles, Radio: Satellite Relay and Sewing.
--
-- WHY THESE ROWS AND NOT NUMBERS IN THE CLASSES. A class can state an absolute
-- for a skill it NAMES, and the thirty Heroes Unlimited classes do. It cannot
-- state one for a skill the PLAYER picks: a choice group's `bonus:` adds to
-- whatever the picked row already holds. Across the sixteen education classes
-- that is 108 of 432 entries.
--
-- READ OFF THE RUN-IN HEADING, never off a bare name. An earlier pass searched
-- for each name anywhere in the chapter and took the next "Base Skill:" after
-- it, which matched the word "Photography" inside the SURVEILLANCE SYSTEMS
-- description and reported Surveillance's 40% as Photography's. Three of
-- twenty-eight were wrong that way before the anchor was fixed.
--
-- AND THE BOOK PRINTS TWO LOCK SKILLS. `Picking Locks` (35%, the thief's) and
-- `Locksmith` (25%, "the practiced study of lock designs") are different
-- skills, and the catalog splits them the same way - `Pick Locks` under
-- Espionage and `Locksmith` under Mechanical. Mapping one onto the other both
-- invented a Locksmith override and hid the fact that Locksmith AGREES. It also
-- put the wrong number into ten live classes; see
-- zzzzzzz-fix-hu-locksmith-base.sql.
--
-- Guarded with INSERT OR IGNORE against the (skill_name, system) primary key,
-- so re-running is a no-op and a value corrected by hand survives.


INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Aircraft Mechanics', 'heroes-unlimited', 45, 3, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Aircraft Mechanics');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Art', 'heroes-unlimited', 40, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Art');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Automobile', 'heroes-unlimited', 80, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Automobile');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Helicopter', 'heroes-unlimited', 60, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Helicopter');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Boat: Motor, Race & Hydrofoil', 'heroes-unlimited', 60, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Boat: Motor, Race & Hydrofoil');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Boat: Sail Type', 'heroes-unlimited', 60, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Boat: Sail Type');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Botany', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Botany');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Chemistry', 'heroes-unlimited', 50, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Chemistry');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Climbing', 'heroes-unlimited', 50, 8, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Climbing');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Military: Combat Helicopter', 'heroes-unlimited', 52, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Military: Combat Helicopter');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Computer Operation', 'heroes-unlimited', 60, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Computer Operation');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Computer Programming', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Computer Programming');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Computer Repair', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Computer Repair');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Cook', 'heroes-unlimited', 50, 6, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Cook');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Cryptography', 'heroes-unlimited', 30, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Cryptography');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Dance', 'heroes-unlimited', 40, 6, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Dance');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Detect Ambush', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Detect Ambush');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Detect Concealment', 'heroes-unlimited', 30, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Detect Concealment');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Disguise', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Disguise');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Electrical Engineer', 'heroes-unlimited', 45, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Electrical Engineer');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Military: Jet Fighters', 'heroes-unlimited', 50, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Military: Jet Fighters');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'First Aid', 'heroes-unlimited', 50, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'First Aid');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Fishing', 'heroes-unlimited', 60, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Fishing');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Forgery', 'heroes-unlimited', 30, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Forgery');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Intelligence', 'heroes-unlimited', 42, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Intelligence');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Interrogation', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Interrogation');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Jet Aircraft', 'heroes-unlimited', 60, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Jet Aircraft');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Laser Communications', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Laser Communications');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Mathematics: Basic', 'heroes-unlimited', 80, 2, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Mathematics: Basic');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Navigation', 'heroes-unlimited', 60, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Navigation');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Navigation: Stellar', 'heroes-unlimited', 60, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Navigation: Stellar');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Optic Systems', 'heroes-unlimited', 50, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Optic Systems');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Palming', 'heroes-unlimited', 25, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Palming');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Photography', 'heroes-unlimited', 50, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Photography');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Pick Pockets', 'heroes-unlimited', 30, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Pick Pockets');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Pick Locks', 'heroes-unlimited', 35, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Pick Locks');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Military: Tanks & APCs', 'heroes-unlimited', 50, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Military: Tanks & APCs');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Prowl', 'heroes-unlimited', 46, 8, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Prowl');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Radio: Basic', 'heroes-unlimited', 50, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Radio: Basic');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Radio: Scramblers', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Radio: Scramblers');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Sensory Equipment', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Sensory Equipment');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Robot Mechanics', 'heroes-unlimited', 30, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Robot Mechanics');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Space: Small Spacecraft', 'heroes-unlimited', 50, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Space: Small Spacecraft');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Surveillance', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Surveillance');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Swimming', 'heroes-unlimited', 50, 8, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Swimming');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Tracking (people)', 'heroes-unlimited', 30, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Tracking (people)');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Wilderness Survival', 'heroes-unlimited', 40, 5, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Wilderness Survival');
INSERT OR IGNORE INTO skill_system_bases (skill_name, system, base, per_level, source_book)
SELECT 'Creative Writing', 'heroes-unlimited', 34, 4, 'Revised Heroes Unlimited p.30-36'
 WHERE EXISTS (SELECT 1 FROM skills WHERE name = 'Creative Writing');

-- ASSERTIONS.

SELECT 'every override row landed' AS assertion, count(*) AS got, 48 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited';

-- A row whose skill vanished would be silently absent above rather than
-- wrong, so the count is checked against the CATALOG as well.
SELECT 'and every one names a real skill' AS assertion, count(*) AS got, 48 AS want
  FROM skill_system_bases b JOIN skills s ON s.name = b.skill_name
 WHERE b.system = 'heroes-unlimited';

SELECT 'none agrees with the catalog it overrides' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases b JOIN skills s ON s.name = b.skill_name
 WHERE b.system = 'heroes-unlimited' AND b.base = s.base AND b.per_level = s.per_level;

-- The seven that AGREE must NOT have a row. A row that merely restates the
-- catalog is noise that looks like a decision.
SELECT 'the seven that agree have no row' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases
 WHERE system = 'heroes-unlimited'
   AND skill_name IN ('Astrophysics', 'Escape Artist', 'Forensics', 'Locksmith',
                      'Motorcycles & Snowmobiles', 'Radio: Satellite Relay', 'Sewing');

-- Two the book is emphatic about, spelled out so a silent re-extraction
-- cannot quietly change them.
SELECT 'Computer Operation is 60%/+5 here' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Computer Operation' AND base = 60 AND per_level = 5;

SELECT 'Prowl is 46%/+8 here' AS assertion, count(*) AS got, 1 AS want
  FROM skill_system_bases WHERE system = 'heroes-unlimited'
   AND skill_name = 'Prowl' AND base = 46 AND per_level = 8;

SELECT 'and no other system has a row yet' AS assertion, count(*) AS got, 0 AS want
  FROM skill_system_bases WHERE system <> 'heroes-unlimited';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzz-hu-skill-system-bases.sql');
