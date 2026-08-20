-- Rename two Pilot skills to the names the book actually prints, and leave
-- forwarding pointers behind.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/rename-robot-combat-skills.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/rename-robot-combat-skills.sql
--
--   Pilot Robot Combat Basic (general)    -> Robot Combat: Basic
--   Pilot Robot Combat Elite: Glitter Boy -> Robot Combat Elite: Glitter Boy
--
-- Both came out of an import that prefixed the category onto the name. The
-- books call them Robot Combat, and Pilot: Robots & Power Armor is the separate
-- percentile skill they require - so the old names read as if the pilot skill
-- and the combat skill were one thing.
--
-- A RENAME BREAKS THE SAME REFERENCES A MERGE DOES, which is why this file is
-- three jobs rather than one:
--
--   1. the catalog row          renamed
--   2. class markdown citing it left ALONE, and a redirect recorded instead.
--      The Glitter Boy's occ_skills name both of these. Markdown is frontmatter
--      mixed with lore prose and a blind replace would hit both, so the
--      convention is to remember where the key went. crossReference() already
--      treats a key that redirects as present rather than missing.
--   3. characters holding it    repointed, the way mergeRows() repoints them,
--      so a sheet shows the new name instead of the retired one.
--
-- Guarded throughout: the rename only fires when the new name is free, the
-- redirect is INSERT OR IGNORE against UNIQUE (catalog, from_key), and the
-- character rewrite matches an exact quoted JSON key. Safe to re-run.


-- ===== 1. Rename, only if the target name is not taken =====
UPDATE skills
   SET name = 'Robot Combat: Basic'
 WHERE name = 'Pilot Robot Combat Basic (general)'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Robot Combat: Basic');

UPDATE skills
   SET name = 'Robot Combat Elite: Glitter Boy'
 WHERE name = 'Pilot Robot Combat Elite: Glitter Boy'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Robot Combat Elite: Glitter Boy');


-- ===== 2. Forwarding pointers for the retired names =====
-- reason 'rename' rather than 'merge': nothing was deleted, and the distinction
-- is the only record of which of the two happened.
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Pilot Robot Combat Basic (general)', id, 'rename'
  FROM skills WHERE name = 'Robot Combat: Basic';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Pilot Robot Combat Elite: Glitter Boy', id, 'rename'
  FROM skills WHERE name = 'Robot Combat Elite: Glitter Boy';


-- ===== 3. Characters holding the old name =====
-- Matches the QUOTED NAME, not the "name":"value" pair. The pair looked safer
-- and is not: it hard-codes one serialisation. JSON.stringify emits no space
-- after the colon, but anything that ever rewrites this column with a pretty
-- printer emits one, and the replace would silently match nothing - which is
-- exactly what a first draft of this script did against test data.
-- The surrounding quotes still make it exact: a longer skill name that merely
-- CONTAINS this one cannot match, because its closing quote falls elsewhere.
UPDATE characters
   SET skills = replace(skills,
         '"Pilot Robot Combat Basic (general)"', '"Robot Combat: Basic"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"Pilot Robot Combat Basic (general)"%';

UPDATE characters
   SET skills = replace(skills,
         '"Pilot Robot Combat Elite: Glitter Boy"', '"Robot Combat Elite: Glitter Boy"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"Pilot Robot Combat Elite: Glitter Boy"%';


-- Reports the result back, so it is read rather than assumed.
--   new_names        2 = both rows renamed
--   old_names        0 = neither old name survives as a row
--   redirects        2 = both retired names forward somewhere
--   chars_on_old     0 = no character still stores a retired name
--   glitter_cites    the class markdown STILL cites the old names, on purpose -
--                    that is what the redirects are for, not a leak
SELECT (SELECT count(*) FROM skills WHERE name IN
          ('Robot Combat: Basic','Robot Combat Elite: Glitter Boy')) AS new_names,
       (SELECT count(*) FROM skills WHERE name IN
          ('Pilot Robot Combat Basic (general)','Pilot Robot Combat Elite: Glitter Boy')) AS old_names,
       (SELECT count(*) FROM catalog_redirects WHERE catalog = 'skills' AND from_key IN
          ('Pilot Robot Combat Basic (general)','Pilot Robot Combat Elite: Glitter Boy')) AS redirects,
       (SELECT count(*) FROM characters WHERE skills LIKE '%Pilot Robot Combat%') AS chars_on_old,
       (SELECT count(*) FROM imported_classes WHERE deleted_at IS NULL
          AND markdown LIKE '%Pilot Robot Combat%') AS glitter_cites;

-- Every redirect must point at a row that exists, or it is dead weight that
-- silently stops resolving. INNER JOIN, so a broken one drops out of the count.
SELECT count(*) AS redirects_resolving
  FROM catalog_redirects r JOIN skills s ON s.id = r.to_id
 WHERE r.catalog = 'skills' AND r.from_key LIKE 'Pilot Robot Combat%';

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('rename-robot-combat-skills.sql');
