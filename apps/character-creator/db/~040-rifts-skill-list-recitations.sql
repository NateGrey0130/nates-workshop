-- Three 'Rifts Skill List' rows get a real page: Juicer Uprising printed 65,
-- Coalition War Campaign printed 66, Palladium Fantasy printed 54.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~040-rifts-skill-list-recitations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~040-rifts-skill-list-recitations.sql
--
-- REBUILD-AUDIT F16, more of it taken on Nate's word, 2026-09-27. The number
-- ~040 was assigned by the coordinating session rather than claimed at merge,
-- because this file is applied to production before the merge and its name is
-- recorded in data_script_runs.
--
-- 'Rifts Skill List' is not a book (F16). add-rifts-skill-list-gaps.sql put all
-- three rows there, and fix-wp-source-pre-rue-citations.sql named Juicer
-- Technology and Falconry among the skills "no cached Palladium book defines".
-- Both cached books below define them now.
--
-- THE THREE READINGS, every one off a 110 dpi render of the page as well as the
-- cache, the folio read at the foot of each page (scripts/books.json offsets:
-- ju +1, cwc +1, pf +2 past its early exception):
--
--   Juicer Technology       ju cache p066, printed 65, under "Medical":
--                           "Medical: Juicer Technology", Base Skill 40%+5%.
--                           Stored: Medical 40/5.
--   Radar/Sonar Operations  cwc cache p067, printed 66: "Pilot Related:
--                           Radar/Sonar Operations (Read Sensor Equipment)",
--                           Base Skill 30%+5%. CWC's own list (printed 59)
--                           marks it "(new)". Stored: Pilot Related 30/5.
--   Falconry                pf cache p056, printed 54, under "Military":
--                           Base Skill 30%+5%. Stored: Military 30/5, systems
--                           rifts and palladium-fantasy.
--
-- NO OTHER CACHED BOOK DEFINES ANY OF THEM. Every page of all 28 caches was
-- searched for each name. RUE prints no Juicer Technology entry: its skill
-- list (printed 303, rue offset +3) carries Flight System Combat, Jump Bike
-- Combat and Lore: Juicers, not this one, whatever add-juicer-uprising-skills.sql's
-- header says. RUE printed 320 files "Radar/Sonar Operation" as a pointer to
-- Sensory Equipment, which is a redirect, not a definition. Falconry's other hits
-- (Dragons and Gods, and the rest of PF) are class skill lists and NPC lines.
--
-- Each row's stored figures are part of its guard as well as its old citation,
-- so the page is cited only while the row still says what the page says.
-- A `~` sorts after every `z` tier, so this runs after every file that wrote
-- 'Rifts Skill List' onto these rows, and re-running it is a no-op.

UPDATE skills
   SET source_book = 'Rifts World Book 10: Juicer Uprising p.65'
 WHERE name = 'Juicer Technology' AND source_book = 'Rifts Skill List'
   AND category = 'Medical' AND base = 40 AND per_level = 5;

UPDATE skills
   SET source_book = 'Rifts World Book 11: Coalition War Campaign p.66'
 WHERE name = 'Radar/Sonar Operations' AND source_book = 'Rifts Skill List'
   AND category = 'Pilot Related' AND base = 30 AND per_level = 5;

UPDATE skills
   SET source_book = 'Palladium Fantasy RPG Main Book p.54'
 WHERE name = 'Falconry' AND source_book = 'Rifts Skill List'
   AND category = 'Military' AND base = 30 AND per_level = 5;

-- Read the result back rather than trusting the exit code.
SELECT 'three rows cite their page' AS assertion, count(*) AS got, 3 AS want
  FROM skills
 WHERE (name = 'Juicer Technology' AND source_book = 'Rifts World Book 10: Juicer Uprising p.65')
    OR (name = 'Radar/Sonar Operations' AND source_book = 'Rifts World Book 11: Coalition War Campaign p.66')
    OR (name = 'Falconry' AND source_book = 'Palladium Fantasy RPG Main Book p.54');

SELECT 'and none of the three still cites the non-book' AS assertion, count(*) AS got, 0 AS want
  FROM skills
 WHERE name IN ('Juicer Technology', 'Radar/Sonar Operations', 'Falconry')
   AND source_book = 'Rifts Skill List';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~040-rifts-skill-list-recitations.sql');
