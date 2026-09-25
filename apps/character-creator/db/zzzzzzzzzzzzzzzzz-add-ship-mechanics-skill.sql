-- Ship Mechanics: the skill the Sailor and Pirate O.C.C.s of Rifts World
-- Book 6: South America grant.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzzzz-add-ship-mechanics-skill.sql
--
-- The book prints no skill block for it. Printed 48 says Ship Mechanics works
-- the same as Aircraft Mechanics, applied to boats and ships, so the row copies
-- Aircraft Mechanics' category, base and per-level figure (Rifts Ultimate
-- Edition p.312: Mechanical, 25%, +5% per level) and cites the page that says
-- so. catalog-diff and a name search found no ship mechanics row or redirect
-- in production on 2026-09-25; the nearest are Submersible Vehicle Mechanics
-- and Boat Building, which are different trades.
--
-- THE NAME SORTS AFTER zzzzzzzzzzzzzzzz-tag-skill-systems.sql ON PURPOSE.
-- untag-cross-system.sql sets skills.systems NULL on every row that exists
-- when it runs, and the tag script re-tags only the names it lists, so a
-- skill inserted any earlier would be left untagged by a clean rebuild.

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source, source_book, note)
VALUES ('Ship Mechanics', 'Mechanical', 25, 5, '["rifts"]', 'import',
        'Rifts World Book 6: South America p.48',
        'Works the same as Aircraft Mechanics, applied to boats and ships.');

-- Read the result back. This script asserts its OWN row and nothing else.
SELECT 'Ship Mechanics is in, at 25% +5% per level' AS assertion, count(*) AS got, 1 AS want
  FROM skills WHERE name = 'Ship Mechanics' AND category = 'Mechanical' AND base = 25 AND per_level = 5;

-- The run record follows the file. This script was applied to production
-- under its first name, add-ship-mechanics-skill.sql, and renamed afterwards
-- (see the sort-order note above) - so that row names a file the repo does not
-- have and would read as drift forever. Removed, on the zzzz-cite-pf-rows.sql
-- precedent: only a record that says something untrue is deleted.
DELETE FROM data_script_runs WHERE filename = 'add-ship-mechanics-skill.sql';
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzzz-add-ship-mechanics-skill.sql');
