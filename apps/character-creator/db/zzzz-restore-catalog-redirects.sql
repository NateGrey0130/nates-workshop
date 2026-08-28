-- The 22 catalog redirects that existed only in production
-- (REBUILD-AUDIT.md F8, second half, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-restore-catalog-redirects.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-restore-catalog-redirects.sql
--
-- WHY THESE WERE MISSING. `_lib/catalog-redirects.js` writes a row every time a
-- merge or a rename happens in the catalog editor, so the table drifts exactly
-- the way the catalogs themselves do - and nothing was checking it until F8
-- added it to repo-vs-live.mjs. Production held 45 redirects; a database built
-- from this repo held the 23 that data scripts create, and none of the other 22.
--
-- THE CONTINGENCY THAT GATED THIS IS NOW DISCHARGED. F8 made the export
-- conditional on F9's answer about what a rebuild is FOR. F9's answer: a rebuild
-- produces the CATALOG and the class definitions, never the user data. A
-- redirect is catalog metadata - it is what makes a saved key resolve after a
-- merge - so it is inside that scope, and a rebuilt environment that lacks
-- these is a rebuilt catalog that is missing part of itself.
--
-- to_id CANNOT BE EXPORTED. It is the ROWID of the row a redirect points at,
-- and two correct databases built in a different order disagree about it by
-- construction - which is also why repo-vs-live.mjs excludes the column from
-- comparison. Every statement below therefore resolves the target by its
-- NATURAL KEY at apply time, the same shape zz-merge-psionic-duplicates.sql
-- already uses:
--
--   SELECT 'skills', 'Horsemanship', id, 'merge' FROM skills WHERE name = ...
--
-- If the target row is absent the INSERT selects nothing and the redirect is
-- simply not created, which is the right failure: a redirect to a row that does
-- not exist is worse than no redirect.
--
-- 18 skills and 4 gear. Every one of the 22 resolved against production; none
-- pointed at a missing row.
--
-- FILENAME SORTS LATE ON PURPOSE. Targets are resolved by name, so this must
-- run after anything that renames them - rename-skills-to-rue.sql sorts under
-- `r` and zz-merge-psionic-duplicates.sql under `zz`, both before this.
--
-- INSERT OR IGNORE and guarded by construction, so it is safe to re-run and a
-- no-op on production, where all 45 already exist.

-- back-pack  ->  gear.backpack
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'back-pack', id, 'merge'
  FROM gear WHERE slug = 'backpack';

-- Irmss Portable Kit  ->  gear.portable-irmss-kit
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'Irmss Portable Kit', id, 'merge'
  FROM gear WHERE slug = 'portable-irmss-kit';

-- irmss-portable-kit  ->  gear.portable-irmss-kit
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'irmss-portable-kit', id, 'merge'
  FROM gear WHERE slug = 'portable-irmss-kit';

-- ja-11-energy-rifle  ->  gear.ja-11-juicer-assassin-s-energy-rifle
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'ja-11-energy-rifle', id, 'merge'
  FROM gear WHERE slug = 'ja-11-juicer-assassin-s-energy-rifle';

-- Boat: Motor and Hydrofoils  ->  skills.Boat: Motor, Race & Hydrofoil
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Boat: Motor and Hydrofoils', id, 'rename'
  FROM skills WHERE name = 'Boat: Motor, Race & Hydrofoil';

-- Carpentry (fletching)  ->  skills.Carpentry
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Carpentry (fletching)', id, 'merge'
  FROM skills WHERE name = 'Carpentry';

-- Criminal Sciences & Forensics  ->  skills.Forensics
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Criminal Sciences & Forensics', id, 'rename'
  FROM skills WHERE name = 'Forensics';

-- Horsemanship  ->  skills.Horsemanship: General
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Horsemanship', id, 'merge'
  FROM skills WHERE name = 'Horsemanship: General';

-- Jet Fighters  ->  skills.Military: Jet Fighters
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Jet Fighters', id, 'rename'
  FROM skills WHERE name = 'Military: Jet Fighters';

-- 'Lore ' || char(8212) || ' Faerie'  ->  skills.Lore: Faeries & Creatures of Magic
-- (the from_key holds a literal em-dash; spelled with char() here too because
--  the smoke test requires a data script to be pure ASCII in its COMMENTS as
--  well, which is stricter than d1-apply.mjs, and the stricter rule wins)
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Lore ' || char(8212) || ' Faerie', id, 'rename'
  FROM skills WHERE name = 'Lore: Faeries & Creatures of Magic';

-- Lore: Demons and Monsters  ->  skills.Lore: Demons & Monsters
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Lore: Demons and Monsters', id, 'merge'
  FROM skills WHERE name = 'Lore: Demons & Monsters';

-- Motorcycle  ->  skills.Motorcycles & Snowmobiles
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Motorcycle', id, 'rename'
  FROM skills WHERE name = 'Motorcycles & Snowmobiles';

-- Pilot: Hovercraft  ->  skills.Hover Craft (ground)
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Pilot: Hovercraft', id, 'merge'
  FROM skills WHERE name = 'Hover Craft (ground)';

-- Read Sensory Equipment  ->  skills.Sensory Equipment
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Read Sensory Equipment', id, 'rename'
  FROM skills WHERE name = 'Sensory Equipment';

-- SCUBA  ->  skills.SCUBA
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'SCUBA', id, 'merge'
  FROM skills WHERE name = 'SCUBA';

-- Surveillance Systems  ->  skills.Surveillance
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Surveillance Systems', id, 'rename'
  FROM skills WHERE name = 'Surveillance';

-- Tanks and APCs  ->  skills.Military: Tanks & APCs
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Tanks and APCs', id, 'rename'
  FROM skills WHERE name = 'Military: Tanks & APCs';

-- Track Animals  ->  skills.Track & Trap Animals
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Track Animals', id, 'merge'
  FROM skills WHERE name = 'Track & Trap Animals';

-- W.P. Heavy  ->  skills.W.P. Heavy Military Weapons
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'W.P. Heavy', id, 'rename'
  FROM skills WHERE name = 'W.P. Heavy Military Weapons';

-- W.P. Heavy Energy Weapons  ->  skills.W.P. Heavy M.D. Weapons
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'W.P. Heavy Energy Weapons', id, 'rename'
  FROM skills WHERE name = 'W.P. Heavy M.D. Weapons';

-- W.P. Sub-Machinegun  ->  skills.W.P. Submachine-Gun
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'W.P. Sub-Machinegun', id, 'rename'
  FROM skills WHERE name = 'W.P. Submachine-Gun';

-- Writing  ->  skills.Creative Writing
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Writing', id, 'rename'
  FROM skills WHERE name = 'Creative Writing';

-- Reads the result back rather than trusting the exit code.
--   catalog_redirects  45 = production's own figure. A rebuild had 23.
--   dangling_targets    0 = no redirect points at a row that is not there.
--                      Checked across both catalogs this file writes, because
--                      an INSERT that selected nothing would fail silently and
--                      look exactly like a row that was already present.
SELECT (SELECT count(*) FROM catalog_redirects) AS catalog_redirects,
       (SELECT count(*) FROM catalog_redirects r
         WHERE (r.catalog = 'skills' AND NOT EXISTS (SELECT 1 FROM skills s WHERE s.id = r.to_id))
            OR (r.catalog = 'gear' AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.id = r.to_id))) AS dangling_targets;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early, and a
-- run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-restore-catalog-redirects.sql');
