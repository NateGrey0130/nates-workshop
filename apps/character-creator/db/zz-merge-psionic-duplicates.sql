-- Six psionic powers a rebuilt database holds twice.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-merge-psionic-duplicates.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-merge-psionic-duplicates.sql
--
-- WHAT THIS FIXES. Production holds 101 psionic powers; a database built from
-- this repo comes up with 107. The extra six are not new content - they are the
-- OLD HALF of six merges somebody performed through the catalog editor, which
-- writes straight to D1 and left no script behind:
--
--   the repo still creates      production kept
--   Bio-Manipulation            Bio-Manipulation (the evil eye)
--   Bio-Regenerate (self)       Bio-Regeneration
--   Levitation (psionic)        Levitation
--   Nightvision (psionic)       Nightvision
--   Object Read                 Object Read (Psychometry)
--   Telekinesis (minor)         Telekinesis
--
-- The six losing names all come from db/seed-catalogs.sql. Production is
-- correct and carries a `catalog_redirects` row for each; this repo carried
-- neither the deletions nor the redirects, so a rebuilt database was a
-- different database.
--
-- WHY THE PREFIX. `merge-bio-regenerate-duplicate.sql` already exists and
-- already tries to do one of these six. It has never worked in a fresh build
-- and the reason is FILENAME ORDER: it sorts under `m`, while every one of the
-- surviving rows is created by `restore-psionics-missing-from-repo.sql`, which
-- sorts under `r`. Running first, its guards correctly find no survivor to
-- merge into and it does nothing at all - silently, because doing nothing is
-- exactly what a guarded script does when its precondition is absent.
--
-- That script is left in place: it is recorded in `data_script_runs`, deleting
-- it would report as drift, and on an environment where it DID work it is
-- honest history. It simply no-ops now, and this file supersedes it.
--
-- `zz-` is this repo's convention for "must sort last", already used by
-- zz-canonicalise-class-skill-names.sql for the same reason.
--
-- SAFETY. Three of the six retired names are cited by class definitions -
-- Bio-Manipulation by combat-cyborg, Object Read by cyber-knight and
-- techno-wizard. They are deliberately NOT rewritten. That is what redirects
-- are for, and rewriting a class's markdown to match a catalog rename is how
-- you lose the book's own wording. No character holds any of the six.
--
-- Every statement resolves ids BY NAME rather than hard-coding them -
-- environments assign different ones - and guards itself, so re-running does
-- nothing and running this on production (where the merges already happened)
-- correctly finds nothing to do.

-- Any redirect already pointing at a row about to disappear moves to the
-- survivor first, so no redirect is ever left dangling.
UPDATE catalog_redirects SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Bio-Manipulation (the evil eye)')
 WHERE catalog = 'psionics' AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Bio-Manipulation')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Manipulation (the evil eye)');
UPDATE catalog_redirects SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Bio-Regeneration')
 WHERE catalog = 'psionics' AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Bio-Regenerate (self)')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regeneration');
UPDATE catalog_redirects SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Levitation')
 WHERE catalog = 'psionics' AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Levitation (psionic)')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Levitation');
UPDATE catalog_redirects SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Nightvision')
 WHERE catalog = 'psionics' AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Nightvision (psionic)')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Nightvision');
UPDATE catalog_redirects SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Object Read (Psychometry)')
 WHERE catalog = 'psionics' AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Object Read')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Object Read (Psychometry)');
UPDATE catalog_redirects SET to_id = (SELECT id FROM psionic_powers WHERE name = 'Telekinesis')
 WHERE catalog = 'psionics' AND to_id = (SELECT id FROM psionic_powers WHERE name = 'Telekinesis (minor)')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Telekinesis');

-- A forwarding address for each retired name, so the class citations above keep
-- resolving. Matches what production already holds.
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Bio-Manipulation', (SELECT id FROM psionic_powers WHERE name = 'Bio-Manipulation (the evil eye)'), 'merge'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Manipulation (the evil eye)')
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Bio-Regenerate (self)', (SELECT id FROM psionic_powers WHERE name = 'Bio-Regeneration'), 'merge'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regeneration')
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Levitation (psionic)', (SELECT id FROM psionic_powers WHERE name = 'Levitation'), 'merge'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Levitation')
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Nightvision (psionic)', (SELECT id FROM psionic_powers WHERE name = 'Nightvision'), 'merge'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Nightvision')
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Object Read', (SELECT id FROM psionic_powers WHERE name = 'Object Read (Psychometry)'), 'merge'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Object Read (Psychometry)')
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;
INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'psionics', 'Telekinesis (minor)', (SELECT id FROM psionic_powers WHERE name = 'Telekinesis'), 'merge'
 WHERE EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Telekinesis')
ON CONFLICT (catalog, from_key) DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

-- The retired rows go, but only while the survivor exists AND the row being
-- removed is still the empty one. A row that has gained its own description
-- since is a different question and must stop this.
DELETE FROM psionic_powers WHERE name = 'Bio-Manipulation'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Manipulation (the evil eye)');
DELETE FROM psionic_powers WHERE name = 'Bio-Regenerate (self)'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Bio-Regeneration');
DELETE FROM psionic_powers WHERE name = 'Levitation (psionic)'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Levitation');
DELETE FROM psionic_powers WHERE name = 'Nightvision (psionic)'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Nightvision');
DELETE FROM psionic_powers WHERE name = 'Object Read'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Object Read (Psychometry)');
DELETE FROM psionic_powers WHERE name = 'Telekinesis (minor)'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM psionic_powers WHERE name = 'Telekinesis');

-- Read the result back rather than trusting the exit code.
--   retired_left    0 = all six duplicates are gone
--   survivors       6 = every keeper is still present
--   redirects       6 = every retired name still resolves
--   dangling        0 = no redirect points at a row that no longer exists
SELECT (SELECT count(*) FROM psionic_powers WHERE name IN
          ('Bio-Manipulation', 'Bio-Regenerate (self)', 'Levitation (psionic)',
           'Nightvision (psionic)', 'Object Read', 'Telekinesis (minor)')) AS retired_left,
       (SELECT count(*) FROM psionic_powers WHERE name IN
          ('Bio-Manipulation (the evil eye)', 'Bio-Regeneration', 'Levitation',
           'Nightvision', 'Object Read (Psychometry)', 'Telekinesis')) AS survivors,
       (SELECT count(*) FROM catalog_redirects WHERE catalog = 'psionics') AS redirects,
       (SELECT count(*) FROM catalog_redirects r WHERE r.catalog = 'psionics'
          AND NOT EXISTS (SELECT 1 FROM psionic_powers p WHERE p.id = r.to_id)) AS dangling;

SELECT count(*) AS psionic_powers_total FROM psionic_powers;

INSERT INTO data_script_runs (filename) VALUES ('zz-merge-psionic-duplicates.sql');
