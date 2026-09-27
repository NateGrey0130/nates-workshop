-- Four W.P. rows get a real page: Nightbane RPG printed 59-60.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~037-nightbane-wp-citations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~037-nightbane-wp-citations.sql
--
-- REBUILD-AUDIT F16, taken in part on Nate's word, 2026-09-27.
--
-- THESE FOUR CITED 'Rifts Skill List', which is not a book. That label was
-- chosen on purpose by fix-wp-source-pre-rue-citations.sql (INGESTION-AUDIT
-- F25), and its reason was "No cached book DEFINES these four". That stopped
-- being true when nightbane-core was cached. This script reverses that choice
-- for these four rows, and only because its reason no longer holds.
--
-- WHAT THE PAGES SAY, read from the nightbane-core cache (scripts/books.json
-- page_offset 1, so printed 59 is p060.txt and printed 60 is p061.txt; each
-- page prints its own folio at the foot, 59 and 60):
--
--   printed 59, under "Modern Weapon Proficiencies:", a definition of each:
--     W.P. Revolver ........................ cylinder-style handguns, not automatic
--     W.P. Automatic Pistol ................ keeps firing while the trigger is held
--     W.P. Bolt-Action Rifle ............... hunting rifles, not an automatic weapon
--     W.P. Automatic and Semi-automatic Rifles .. assault rifles (M-16, AK-47)
--   printed 60, the bonuses those definitions point to:
--     aimed +3 to strike (+4 with a revolver), burst +1, and +1 to strike for
--     every three levels beyond level one.
--
-- EVERY STORED NUMBER MATCHES: aimed 3 (revolver 4) and +1 at levels 4, 7, 10
-- and 13 on all four rows, and burst 1 on the three that can fire one. The
-- bolt-action row stores no burst bonus, reasoned from printed 59's "not an
-- automatic firing weapon"; printed 60 says burst +1 "with all weapons", and
-- that row is left as it was. That agreement is the evidence the pages
-- are the source. No other cached book carries a definition of any of the four
-- (heroes-unlimited-core only lists them; RUE defines W.P. Handguns and W.P.
-- Rifles instead). Hence p.59-60: the definitions on one page, the numbers the
-- rows store on the next.
--
-- ONE STORED NOTE DISAGREED WITH THE PAGE, and it is rewritten here on Nate's
-- word. W.P. Automatic Pistol's level-1 note described a semi-automatic, one
-- trigger pull per shot. Printed 59 defines the proficiency as a weapon that
-- keeps firing while the trigger is held. No cached book carries the old
-- wording; it came in by backfill-blank-skills.sql, "from stats supplied by
-- hand". Only that one sentence changes; the rest of the note stays.
--
-- p060 is flagged in the cache manifest for substituted digits (the "+ I" for
-- +1 kind). That touches numbers on the page, not the definitions cited here,
-- and every number above was read as the value it can only be.
--
-- SORT ORDER. zzzzzzzzzzzzzzzzz-reapply-wp-recitations.sql sets these same
-- four rows to 'Rifts Skill List' on a rebuild. A `~` sorts after every `z`
-- tier, so this file runs after it and its guard finds the value it expects.
--
-- Each change is guarded on the old value still being present, so re-running
-- is a no-op and nothing overwrites a citation corrected by hand since.

UPDATE skills
   SET source_book = 'Nightbane RPG p.59-60'
 WHERE name IN ('W.P. Revolver', 'W.P. Automatic Pistol', 'W.P. Bolt Action Rifle',
                'W.P. Automatic and Semi-automatic Rifles')
   AND source_book = 'Rifts Skill List';

UPDATE skills
   SET level_bonuses = replace(level_bonuses,
       'The trigger must be pulled for each shot, but the pistol automatically ejects the cartridge and loads a new one from the magazine into the chamber.',
       'Automatic means the weapon keeps firing while the trigger is held down, until it is released or the rounds run out.')
 WHERE name = 'W.P. Automatic Pistol'
   AND instr(level_bonuses, 'The trigger must be pulled for each shot') > 0;

-- Read the result back rather than trusting the exit code.
SELECT 'all four W.P.s cite Nightbane printed 59-60' AS assertion,
       count(*) AS got, 4 AS want
  FROM skills
 WHERE source_book = 'Nightbane RPG p.59-60'
   AND name IN ('W.P. Revolver', 'W.P. Automatic Pistol', 'W.P. Bolt Action Rifle',
                'W.P. Automatic and Semi-automatic Rifles');

SELECT 'and the pistol note now matches the page' AS assertion,
       count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'W.P. Automatic Pistol'
   AND instr(level_bonuses, 'keeps firing while the trigger is held down') > 0
   AND instr(level_bonuses, 'The trigger must be pulled for each shot') = 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~037-nightbane-wp-citations.sql');
