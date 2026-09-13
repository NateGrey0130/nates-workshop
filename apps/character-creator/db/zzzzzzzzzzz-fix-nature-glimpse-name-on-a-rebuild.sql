-- `fix-nature-glimpse-of-the-future-name.sql` SORTS BEFORE THE FILE IT
-- CORRECTS, so it is a no-op on every clean rebuild. This runs the same
-- correction from a filename that sorts after.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzz-fix-nature-glimpse-name-on-a-rebuild.sql
--
-- THE HAZARD, which the class-import skill documents and which this is a live
-- instance of: a clean rebuild applies `apps/character-creator/db/*.sql` as one
-- SORTED GLOB, so filename order IS execution order. Sorted today:
--
--   436  fix-nature-glimpse-of-the-future-name.sql   <- the correction
--   619  zzzzzzzzzz-mr-nature-spells.sql             <- the file it corrects
--
-- The correction runs 183 files EARLY, its guarded UPDATE matches nothing, and
-- the row is then created under the wrong name. Production is correct only
-- because the two were applied BY HAND in the order they were written. This is
-- the `fix-long-bowman-armor.sql` shape exactly.
--
-- HOW IT SURFACED, and it is the same mechanism the original fix's own header
-- describes: "a class that cites a spell is a check on the spell import".
-- Nothing named this row until the Russian Ley Line Walker's `russian-magic`
-- list did, and `regression.mjs` - which builds from the repo, not from
-- production - went red with
-- `russian-ley-line-walker/russian-magic: Nature: Glimpse of the Future`.
-- The original fix's own readback assertions could not catch it: `d1-apply`
-- reports a failed assertion and applies the file anyway, and a rebuild has
-- nobody reading that output.
--
-- WHY A NEW FILE RATHER THAN A RENAME. `scripts/drift-check.mjs` reads
-- `SELECT filename FROM data_script_runs` and reports `RUN BUT NO FILE` for any
-- recorded name with no file on disk. Production recorded
-- `fix-nature-glimpse-of-the-future-name.sql` on 2026-09-12 (read --remote
-- 2026-09-13), so renaming it would leave a permanent complaint against
-- production to buy a tidier tree. One-shot scripts are not rewritten;
-- corrections sort after them.
--
-- IN PRODUCTION THIS IS A NO-OP, by construction: both statements are guarded
-- on the state they replace, and production already carries the corrected name
-- and the prepended subtitle (read --remote 2026-09-13). It changes a REBUILD,
-- which is where the divergence lives.

-- The name. Guarded, so it fires only where the wrong name still exists.
UPDATE spells
   SET name = 'Nature: Glimpse of the Future'
 WHERE name = 'Nature: A Wood & Water Divination';

-- The subtitle the original fix folded into the description. Guarded
-- separately: a rebuild needs both, production has both, and a half-applied
-- state - the name fixed by hand and the description not - would otherwise be
-- invisible. `instr` on the text it adds is the only condition that survives
-- the row having been renamed already.
UPDATE spells
   SET description = 'Also titled "A Wood & Water Divination". ' || description
 WHERE name = 'Nature: Glimpse of the Future'
   AND instr(description, 'Also titled') = 0;

-- Read the result back. These are the original fix's own assertions, which is
-- the point: they now hold on a REBUILD as well as on production.
SELECT 'the spell carries its printed name' AS assertion, count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Nature: Glimpse of the Future';

SELECT 'and the subtitle is no longer the name' AS assertion, count(*) AS got, 0 AS want
  FROM spells WHERE name = 'Nature: A Wood & Water Divination';

SELECT 'the subtitle survives in the description, exactly once' AS assertion, count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Nature: Glimpse of the Future'
   AND instr(description, 'Also titled "A Wood & Water Divination". ') = 1
   AND instr(substr(description, 42), 'Also titled') = 0;

SELECT 'its mechanics are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Nature: Glimpse of the Future' AND ppe = 15 AND level = 5;

SELECT 'the Nature tradition still holds thirty rows' AS assertion, count(*) AS got, 30 AS want
  FROM spells WHERE tradition = 'nature';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzz-fix-nature-glimpse-name-on-a-rebuild.sql');
