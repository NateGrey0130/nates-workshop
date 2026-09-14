-- The ONE skill the sixteen Heroes Unlimited skill programs name and the
-- catalog lacks. Printed 27-28 for the programs, printed 30 for the skill.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-skill-program-skills.sql
--
-- ONE, out of roughly forty names across the sixteen programs. The rest all
-- resolve, and that is worth saying because the first draft of the Educational
-- Levels guessed several and got them wrong: the book prints `Laser`,
-- `Picking Locks`, `Read Sensory Equipment`, `Criminal Sciences & Forensics`,
-- `Pilot Tank`, `Navigation - Space`, `Basic Helicopter`, `Fighter Jet` and
-- `Space Shuttle` for rows the catalog calls `Laser Communications`,
-- `Locksmith`, `Sensory Equipment`, `Forensics`, `Military: Tanks & APCs`,
-- `Navigation: Stellar`, `Helicopter`, `Military: Jet Fighters` and
-- `Space: Small Spacecraft`. Each class entry carries a note saying which.
--
-- `Writing` IS NOT CREATED, and it is the interesting one. The book prints it
-- as a Technical skill and the catalog calls the row `Creative Writing`, with
-- a live `catalog_redirects` row forwarding the old name - so naming `Writing`
-- in a class would have RESOLVED and reported nothing, which is exactly how a
-- dead name survives a rename. The classes name `Creative Writing`.
--
-- THE FILENAME SORTS AFTER `add-hu-hardware-skills.sql` ON PURPOSE. A clean
-- rebuild applies this directory as one sorted glob, and FOUR of that script's
-- assertions counted every row citing this book rather than its own five - so
-- a sixth HU skill created ahead of it would have read 6 against a want of 5
-- on every rebuild, for ever. All four are bounded by name in the same commit,
-- which is the real fix; this filename is the belt to those braces. Checked
-- with the sort command from the class-import skill rather than reasoned about:
-- this lands at 139, `add-hu-hardware-skills.sql` at 131.

INSERT INTO skills (name, category, base, per_level, source, source_book, systems)
SELECT 'Radio: Satellite Relay', 'Communications', 25, 5, 'import', 'Revised Heroes Unlimited p.30', NULL
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Radio: Satellite Relay');

UPDATE skills SET note = 'An understanding of the methods and operations of satellite transmissions - locating a satellite, aligning to it, and sending or receiving through it. Granted by the Communications skill program, printed 27. Distinct from Radio: Basic, which is field radios and walkie-talkies, and from Radio: Scramblers, which is masking and unscrambling; a character may hold all three.'
 WHERE name = 'Radio: Satellite Relay' AND note IS NULL;

-- ASSERTIONS.

SELECT 'Radio: Satellite Relay exists' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Radio: Satellite Relay';

SELECT 'it is filed under Communications at the book''s 25%/+5%' AS assertion,
       count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'Radio: Satellite Relay'
   AND category = 'Communications' AND base = 25 AND per_level = 5;

SELECT 'it carries its note and cites the core' AS assertion, count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'Radio: Satellite Relay'
   AND source_book LIKE 'Revised Heroes Unlimited%' AND length(note) > 80;

-- The two other Radio rows it must NOT have been merged into. A program grants
-- all three, so a merge would silently grant two skills where the book gives
-- three.
SELECT 'the three Radio rows are distinct' AS assertion, count(*) AS got, 3 AS want
  FROM skills WHERE name IN ('Radio: Basic', 'Radio: Scramblers', 'Radio: Satellite Relay');

-- `Writing` stays a redirect rather than becoming a row, which is what lets the
-- classes name `Creative Writing` and mean the book's skill.
SELECT 'Writing was NOT created as a row' AS assertion, count(*) AS got, 0 AS want
  FROM skills WHERE name = 'Writing';

INSERT INTO data_script_runs (filename) VALUES ('add-hu-skill-program-skills.sql');
