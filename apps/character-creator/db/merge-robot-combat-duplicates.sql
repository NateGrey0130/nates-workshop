-- Collapse two pairs of duplicate Pilot skills that the rename exposed.
--
-- One-off data cleanup, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/merge-robot-combat-duplicates.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/merge-robot-combat-duplicates.sql
--
-- WHAT HAPPENED. rename-robot-combat-skills.sql assumed each old name had no
-- counterpart. Production disagreed: the skill importer had already created
-- rows under the book spellings, so the catalog held both. The rename is
-- guarded on the target name being free, so one half fired and the other did
-- not, and backfill-rue-physical-pilot-skills.sql added a row that duplicated
-- one already present under a different spelling.
--
-- The guards did their job - nothing was overwritten and nothing was lost - but
-- the result is four rows describing two skills:
--
--   Robot Combat: Basic                  <- survives, had no note
--   Pilot Robot Combat Basic (general)   <- carries the note, is now also a
--                                           redirect key, so it shadows its own
--                                           forwarding pointer
--
--   Robots and Power Armor               <- import spelling, cited by 6 classes
--   Pilot: Robots & Power Armor          <- book spelling, cited by 1 class
--
-- RESOLUTION. One row per skill, under the name the book prints, with a
-- redirect from every retired spelling so all seven class citations keep
-- resolving. Exactly what mergeRows() would do; written out here because the
-- merge tool is an admin UI and this needs to be reproducible per environment.
--
-- Everything is selected BY NAME rather than by id: ids differ between
-- environments, and a hard-coded one would delete whatever happens to sit there.
--
-- NOT TOUCHED: 'Robot Combat Elite' is a separate generic skill, not a
-- misspelling of the Glitter Boy entry, and keeps its own row.


-- ===== 1. Robot Combat: Basic - keep the survivor, move the note onto it =====
-- The losing row is the one carrying the description, so the note moves before
-- the row goes. Guarded on the survivor having none, so a later hand edit wins.
UPDATE skills
   SET note = (SELECT note FROM skills WHERE name = 'Pilot Robot Combat Basic (general)')
 WHERE name = 'Robot Combat: Basic'
   AND note IS NULL
   AND EXISTS (SELECT 1 FROM skills WHERE name = 'Pilot Robot Combat Basic (general)' AND note IS NOT NULL);

-- Any character holding the retired spelling moves first, so nothing is left
-- pointing at a row that is about to disappear.
UPDATE characters
   SET skills = replace(skills, '"Pilot Robot Combat Basic (general)"', '"Robot Combat: Basic"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"Pilot Robot Combat Basic (general)"%';

-- Only once the survivor exists AND the forwarding pointer is in place.
DELETE FROM skills
 WHERE name = 'Pilot Robot Combat Basic (general)'
   AND EXISTS (SELECT 1 FROM skills WHERE name = 'Robot Combat: Basic')
   AND EXISTS (SELECT 1 FROM catalog_redirects
                WHERE catalog = 'skills'
                  AND from_key = 'Pilot Robot Combat Basic (general)'
                  AND to_id = (SELECT id FROM skills WHERE name = 'Robot Combat: Basic'));


-- ===== 2. Pilot: Robots & Power Armor - the book spelling wins =====
-- The import spelling is cited by more classes, which is not a reason to keep
-- it: a redirect makes citation count irrelevant, and the book name is the one
-- a reader can look up.
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Robots and Power Armor', id, 'merge'
  FROM skills WHERE name = 'Pilot: Robots & Power Armor';

UPDATE characters
   SET skills = replace(skills, '"Robots and Power Armor"', '"Pilot: Robots & Power Armor"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"Robots and Power Armor"%';

-- The survivor keeps whichever note exists; the import row had none, but this
-- is guarded rather than assumed.
UPDATE skills
   SET note = COALESCE(note, (SELECT note FROM skills WHERE name = 'Robots and Power Armor'))
 WHERE name = 'Pilot: Robots & Power Armor'
   AND note IS NULL;

DELETE FROM skills
 WHERE name = 'Robots and Power Armor'
   AND EXISTS (SELECT 1 FROM skills WHERE name = 'Pilot: Robots & Power Armor')
   AND EXISTS (SELECT 1 FROM catalog_redirects
                WHERE catalog = 'skills'
                  AND from_key = 'Robots and Power Armor'
                  AND to_id = (SELECT id FROM skills WHERE name = 'Pilot: Robots & Power Armor'));


-- Reports the result back, so it is read rather than assumed.
--   basic_rows / pilot_rows   1 each = one row per skill
--   retired_rows              0 = no retired spelling survives as a row,
--                                 which would shadow its own redirect
--   basic_has_note            1 = the description survived the merge
--   redirects_resolving       3 = every retired spelling forwards to a real row
SELECT (SELECT count(*) FROM skills WHERE name = 'Robot Combat: Basic') AS basic_rows,
       (SELECT count(*) FROM skills WHERE name = 'Pilot: Robots & Power Armor') AS pilot_rows,
       (SELECT count(*) FROM skills WHERE name IN
          ('Pilot Robot Combat Basic (general)', 'Robots and Power Armor')) AS retired_rows,
       (SELECT note IS NOT NULL FROM skills WHERE name = 'Robot Combat: Basic') AS basic_has_note,
       (SELECT count(*) FROM skills WHERE name = 'Robot Combat Elite') AS elite_generic_kept;

SELECT count(*) AS redirects_resolving
  FROM catalog_redirects r JOIN skills s ON s.id = r.to_id
 WHERE r.catalog = 'skills'
   AND r.from_key IN ('Pilot Robot Combat Basic (general)',
                      'Pilot Robot Combat Elite: Glitter Boy',
                      'Robots and Power Armor');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('merge-robot-combat-duplicates.sql');
