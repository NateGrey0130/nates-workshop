-- Core hit points and S.D.C. for characters saved without them.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-core-pools.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-core-pools.sql
--
-- Hit points and S.D.C. are core rules (p.18), stated once for every character
-- rather than per class, so most class pages print neither. The app read a
-- class page's silence as "this character has none" and saved hp_max NULL.
--
-- Two Priests of Light reached production that way: no hit points, no S.D.C.,
-- and nothing on the sheet to suggest anything was missing. js/compose.js now
-- supplies both from p.18 when a class states neither, which fixes every
-- character built from here on. This fixes the ones already saved.
--
-- The rolls happen here rather than being typed in, because that is what the
-- wizard would have done at creation:
--
--   hit points   P.E. + 1D6
--   S.D.C.       3D6 for men of arms, 1D6 for everyone else (p.18)
--
-- Guarded three ways, so re-running is safe and so is running this before the
-- deploy that fixes new builds:
--
--   hp_max IS NULL      only characters actually missing the pool
--   mdc_max IS NULL     an M.D.C. being tracks M.D.C. INSTEAD and is not missing
--                       anything - filling in hit points there would be wrong
--   level = 1           "+1D6 per level" needs one die per level, which is more
--                       than a single UPDATE can express. No affected character
--                       is above level 1; the verification below re-counts, so
--                       a higher-level one shows up as still-missing rather
--                       than being silently under-rolled.

-- Hit points: P.E. plus 1D6.
UPDATE characters
SET hp_max = json_extract(attributes, '$.PE') + (abs(random() % 6) + 1)
WHERE hp_max IS NULL
  AND mdc_max IS NULL
  AND level = 1
  AND json_extract(attributes, '$.PE') IS NOT NULL;

-- S.D.C. by the book's O.C.C. grouping. The occupation decides it, not the
-- race: what makes a character a man of arms is the job. The id list matches
-- CORE_SDC_BY_CLASS in js/compose.js - a class in neither group is left alone
-- rather than defaulting to 1D6, which would quietly under-roll a man of arms.
UPDATE characters
SET sdc_max = CASE
      WHEN COALESCE(occ_class_id, class_id) IN (
        'glitter-boy', 'headhunter-techno-warrior', 'merc-soldier',
        'robot-pilot', 'psi-stalker', 'wild-psi-stalker')
      THEN (abs(random() % 6) + 1) + (abs(random() % 6) + 1) + (abs(random() % 6) + 1)
      ELSE (abs(random() % 6) + 1)
    END
WHERE sdc_max IS NULL
  AND mdc_max IS NULL
  AND COALESCE(occ_class_id, class_id) IN (
    'glitter-boy', 'headhunter-techno-warrior', 'merc-soldier',
    'robot-pilot', 'psi-stalker', 'wild-psi-stalker',
    'burster', 'elemental-fusionist-earth-air', 'elemental-fusionist-fire-water',
    'ley-line-rifter', 'ley-line-walker', 'mind-melter', 'mystic',
    'priest-of-light', 'shifter', 'techno-wizard', 'warlock');

-- A character that never had the pool has never spent it, so current starts at
-- max. Separate statements because SQLite reads the OLD value on the right-hand
-- side: setting both in one UPDATE would copy the NULL that was just replaced.
UPDATE characters SET hp_current  = hp_max  WHERE hp_current  IS NULL AND hp_max  IS NOT NULL;
UPDATE characters SET sdc_current = sdc_max WHERE sdc_current IS NULL AND sdc_max IS NOT NULL;

-- Reports the result back, so it is read rather than assumed.
--   still_missing_hp   0 = every non-M.D.C. character now has hit points
--   still_missing_sdc  0 = ditto S.D.C.
--   hp_out_of_range    0 = every rolled pool is inside what the formula allows
--   current_mismatch   0 = no character is carrying damage it never took
SELECT (SELECT count(*) FROM characters
          WHERE hp_max IS NULL AND mdc_max IS NULL) AS still_missing_hp,
       (SELECT count(*) FROM characters
          WHERE sdc_max IS NULL AND mdc_max IS NULL) AS still_missing_sdc,
       (SELECT count(*) FROM characters
          WHERE mdc_max IS NULL AND hp_max IS NOT NULL AND level = 1
            AND json_extract(attributes, '$.PE') IS NOT NULL
            AND (hp_max < json_extract(attributes, '$.PE') + 1
              OR hp_max > json_extract(attributes, '$.PE') + 6)) AS hp_out_of_range,
       (SELECT count(*) FROM characters
          WHERE (hp_current > hp_max) OR (sdc_current > sdc_max)) AS current_mismatch;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-core-pools.sql');
