-- Trap Construction leaves 'Rifts Skill List' for its page: Coalition War
-- Campaign printed 62.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~240-rebuild-audit-f16-trap-construction.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~240-rebuild-audit-f16-trap-construction.sql
--
-- REBUILD-AUDIT F16, more of it taken on Nate's word: his ruling of 2026-10-19
-- (D12) chose Coalition War Campaign printed 62 over New West printed 75, the
-- choice F16 left to him. 'Rifts Skill List' is not a book (F16), and
-- add-rifts-skill-list-gaps.sql put this row there.
--
-- THE THREE READINGS, off a 110 dpi render of each page as well as the cache,
-- the folio read at the foot of the page (cwc offset +1):
--
--   1. The page defines it. cwc cache p063, printed 62: "Military and
--      Wilderness: Trap Construction (by Nowak & Siembieda)", Base Skill 20%
--      +4% per level of experience. CWC's own skill list (cache p060, printed
--      59) marks it "(new)" under both Military and Wilderness.
--   2. The row matches the page. Stored: Military 20/4, systems ["rifts"].
--      Unchanged here.
--   3. No other cached book defines it. This is the reading that fails, and
--      the ruling settles it: New West (cache p076, printed 75) prints the
--      same entry at the same 20% +4%. Every other hit in every book cache on this
--      machine (searched 2026-10-20) is a
--      class skill line, a bonus line or a skill-list entry. Warlords of
--      Russia lists it "(new)" (cache p191-p192), which its own preamble says
--      means new for Russia, and reprints no entry.
--
-- The stored figures are part of the guard as well as the old citation, so the
-- page is cited only while the row still says what the page says. A `~` sorts
-- after every `z` tier, so this runs after every file that wrote
-- 'Rifts Skill List' onto the row, and re-running it is a no-op.

UPDATE skills
   SET source_book = 'Rifts World Book 11: Coalition War Campaign p.62'
 WHERE name = 'Trap Construction' AND source_book = 'Rifts Skill List'
   AND category = 'Military' AND base = 20 AND per_level = 4;

-- Read the result back rather than trusting the exit code.
SELECT 'Trap Construction cites CWC printed 62 at 20/4' AS assertion, count(*) AS got, 1 AS want
  FROM skills
 WHERE name = 'Trap Construction'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.62'
   AND category = 'Military' AND base = 20 AND per_level = 4;

SELECT 'and it no longer cites the non-book' AS assertion, count(*) AS got, 0 AS want
  FROM skills
 WHERE name = 'Trap Construction' AND source_book = 'Rifts Skill List';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~240-rebuild-audit-f16-trap-construction.sql');
