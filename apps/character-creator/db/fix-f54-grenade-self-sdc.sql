-- Restore the S.D.C. of the two Wilk's laser grenades.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-f54-grenade-self-sdc.sql
--
-- Rifts New West printed 209 gives the Beehive and the Blinder an S.D.C. of 20
-- and an A.R. of 10 - the durability of the grenade itself - alongside a blast
-- of 3D6 M.D. Both shipped in PR #897 with `sdc` NULL and the 20 recorded only
-- in the description, because `regression.mjs` refused any gear row holding an
-- `sdc` beside a dice expression in `damage`, and loosening a guard in the same
-- change that first trips it is how a guard stops guarding.
--
-- BOOK-INGEST-AUDIT.md F54 is taken in this PR: the check is now SCOPED rather
-- than relaxed, with these two slugs named in it, so an unlisted row still
-- fails exactly as before. The A.R. was never affected - that column is not
-- read by the check - and is untouched here.

UPDATE gear SET sdc = 20
 WHERE slug IN ('wilk-s-beehive-laser-grenade', 'wilk-s-blinder-laser-grenade')
   AND sdc IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT 'both grenades carry their casing S.D.C.' AS assertion,
       count(*) AS got, 2 AS want
  FROM gear
 WHERE slug IN ('wilk-s-beehive-laser-grenade', 'wilk-s-blinder-laser-grenade')
   AND sdc = 20;

SELECT 'and still carry the A.R. they always had' AS assertion,
       count(*) AS got, 2 AS want
  FROM gear
 WHERE slug IN ('wilk-s-beehive-laser-grenade', 'wilk-s-blinder-laser-grenade')
   AND ar = 10;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-f54-grenade-self-sdc.sql');
