-- The sixteen psionic powers that escaped untag-cross-system.sql
-- (REBUILD-AUDIT.md F15, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-untag-escaped-psionics.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-untag-escaped-psionics.sql
--
-- THE FIRST SCRIPT IN THIS AUDIT THAT CHANGES PRODUCTION. Every other
-- correction has been repo-side, applied to --remote as a no-op so drift-check
-- stays quiet. This one moves sixteen live rows, deliberately, because
-- production is the side that is wrong.
--
-- WHAT HAPPENED, and it is the ordering bug again, pointing the other way.
-- untag-cross-system.sql sets `system = NULL` on every psionic power and says
-- why at length: "This is a DELIBERATE setting decision, not an oversight. NULL
-- means every system ... Do not fix it by tagging these rows from their
-- source_book; that was considered and rejected." Untagging the Rifts psionics
-- chapter is what makes a major psychic's "eight powers from one category"
-- possible in a Palladium Fantasy campaign at all - the largest
-- Palladium-visible category held six.
--
-- add-rue-psionics-gap.sql inserts sixteen rows with `system = 'rifts'`. In a
-- REBUILD it sorts under `a`, untag-cross-system sorts under `u`, the untag
-- runs afterwards and catches them: a fresh build has zero tagged rows. On
-- PRODUCTION the two were applied by hand three days apart, in the other order:
--
--   untag-cross-system.sql       first run 2026-08-19 22:37:07
--   add-rue-psionics-gap.sql     first run 2026-08-22 04:38:12
--
-- So the sixteen it added were never untagged, and have been rifts-only ever
-- since. Verified 2026-08-28: production holds exactly sixteen tagged rows, all
-- sixteen named in that script, and every one tagged 'rifts'. A rebuild holds
-- none.
--
-- THE EFFECT IS LIVE, not cosmetic. A Palladium Fantasy psychic cannot
-- currently pick Telekinetic Lift, Telekinetic Push, Psionic Invisibility,
-- Remote Viewing, Mask P.P.E. or the other eleven.
--
-- THE IMPORTER IS NOT THE CAUSE and needs no change - F15 asked. The catalog
-- INSERT in functions/api/character-creator/_lib/catalog.js writes
-- (name, category, isp, source, source_book) and never `system`, and the column
-- has no DEFAULT, so an imported row is NULL and therefore unrestricted. No
-- endpoint UPDATEs the column at all. The only way a row acquires a tag is a
-- data script, which is what this tier exists to sort after.
--
-- Unconditional and idempotent, exactly as untag-cross-system.sql wrote it. It
-- is a no-op on any database where the ordering came out right, which includes
-- every rebuild.

UPDATE psionic_powers
   SET system = NULL
 WHERE system IS NOT NULL;

-- Reads the result back rather than trusting the exit code.
--   powers_tagged_to_one_system  0 = untag-cross-system.sql's decision holds
--                                again, everywhere. This read 16 on production
--                                before this script and 0 on a rebuild.
--   psionic_powers             101 = nothing was added or removed; this script
--                                only clears a column.
SELECT (SELECT count(*) FROM psionic_powers WHERE system IS NOT NULL) AS powers_tagged_to_one_system,
       (SELECT count(*) FROM psionic_powers) AS psionic_powers;

-- Records this run. One row per run rather than per file: the statement above
-- guards itself, so this script is safe to re-run and safe to run early, and a
-- run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-untag-escaped-psionics.sql');
