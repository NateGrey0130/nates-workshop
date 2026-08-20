-- Merge the Bio-Regenerate duplicate.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/merge-bio-regenerate-duplicate.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/merge-bio-regenerate-duplicate.sql
--
-- 'Bio-Regenerate (self)' was the last psionic power with no description, and
-- it turned out not to need one: 'Bio-Regeneration' is the SAME POWER, already
-- complete. Same category (Healing), same cost (6 I.S.P.), same range, same
-- duration, and a description that already covers everything the empty row
-- would have been given - the 2D6 hit points or 3D6 S.D.C. per melee, the
-- absence of scarring, and both statements about concentration.
--
-- The two readings that look contradictory are not: the book says the process
-- takes one full minute of concentration during which no other psionic power
-- can be used, AND that it can be done once every other minute. Those are
-- sequential, not rival editions.
--
-- Checked against the Revolver: THAT pair looked like duplicates and was not,
-- because the numbers differed. This pair has identical numbers on every
-- column, which is what makes it a genuine duplicate rather than two powers
-- sharing a shape.
--
-- 'Bio-Regeneration (Super)' is deliberately untouched - a different power in a
-- different category at 20 I.S.P., and the one thing this merge must not
-- swallow.
--
-- This reproduces what the catalog editor's merge endpoint does, minus the
-- character rewrite - verified unnecessary: no character holds either name.
-- The keeper is the row with the stats.
--
-- Every statement guards itself: names are resolved rather than hard-coded ids
-- (environments assign different ones), and re-running does nothing.

-- Redirects pointing at the row about to disappear move onto the survivor.
UPDATE catalog_redirects
SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Bio-Regeneration')
WHERE catalog = 'psionics'
  AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Bio-Regenerate (self)')
  AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regeneration')
  AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regenerate (self)');

-- Forwarding address for the retired name. The Burster's class markdown cites
-- it and is deliberately NOT rewritten - that is what redirects are for.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Bio-Regenerate (self)',
       (SELECT id FROM psionic_powers WHERE name = 'Bio-Regeneration'), 'merge'
WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regeneration')
  AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regenerate (self)')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- The losing row goes, only while the survivor exists and only while it is
-- still the empty one. A row that has gained its own stats since is a
-- different question and should stop this.
DELETE FROM psionic_powers
WHERE name = 'Bio-Regenerate (self)'
  AND (description IS NULL OR description = '')
  AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regeneration');

-- Reports the result back, so it is read rather than assumed.
--   duplicate_left      0 = the empty row is gone
--   survivor_intact     1 = Bio-Regeneration is still there, with its text
--   super_intact        1 = the 20 I.S.P. Super power was not swallowed
--   redirect_points_at  'Bio-Regeneration' = the Burster's citation resolves
--   powers_no_desc      0 = no psionic power anywhere is left without text
SELECT (SELECT count(*) FROM psionic_powers WHERE name = 'Bio-Regenerate (self)') AS duplicate_left,
       (SELECT count(*) FROM psionic_powers
          WHERE name = 'Bio-Regeneration' AND length(description) > 100) AS survivor_intact,
       (SELECT count(*) FROM psionic_powers
          WHERE name = 'Bio-Regeneration (Super)' AND isp = 20) AS super_intact,
       (SELECT p.name FROM catalog_redirects r JOIN psionic_powers p ON p.id = r.to_id
         WHERE r.catalog = 'psionics' AND r.from_key = 'Bio-Regenerate (self)') AS redirect_points_at,
       (SELECT count(*) FROM psionic_powers
          WHERE description IS NULL OR description = '') AS powers_no_desc;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('merge-bio-regenerate-duplicate.sql');
