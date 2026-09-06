-- Seven gear rows where a rebuilt database and production disagree.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-reconcile-gear-with-production.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-reconcile-gear-with-production.sql
--
-- Production holds 652 gear rows; a database built from this repo comes up with
-- 651, and the single-row difference hides seven disagreements going both ways.
--
-- FOUR ROWS EXIST ONLY IN PRODUCTION. Nothing in the repo creates them, so a
-- fresh environment comes up missing gear that classes have been citing:
--
--   Huntsman Armor            Rifts Book of Magic
--   Air Filter And Gas Mask   Rifts Ultimate Edition p.233-235
--   Hovercycle                Rifts Ultimate Edition p.233-235
--   Light Mdc Body Armor      Rifts Ultimate Edition p.86-87
--
-- All four are class-import stubs: the importer creates a placeholder row when
-- a class names equipment the catalog lacks, and it writes to D1 directly. The
-- class scripts in this repo were written before those imports, so they never
-- learned. This is the same failure the `restore-*.sql` scripts were written
-- for, recurring because nothing watches for it.
--
-- THREE ROWS EXIST ONLY IN THE REPO. All three are class-import stubs that
-- production has since superseded with specific rows:
--
--   Energy Rifle                       production carries the named rifles
--                                      (L-20 Pulse Rifle, Wilk's 447, ...)
--   Sunglasses Or Tinted Goggles       production carries Sunglasses AND
--                                      Tinted Goggles separately
--   Traveling Robe Or Cloak With Hood  production carries Hooded Robe and
--                                      Hooded Cloak
--
-- Nothing cites any of the three and no character holds one - both checked
-- before writing this. They are removed so a rebuild matches production, but
-- ONLY WHILE THEY ARE STILL STUBS: a row somebody has since filled in with real
-- stats is no longer the placeholder this is talking about, and the guard says
-- so rather than trusting the name.
--
-- WHY THE PREFIX. `restore-gear-missing-from-repo.sql` sorts under `r` and
-- creates one of the rows removed here. A file sorting before it would be
-- undone. `zz-` is this repo's convention for "must sort last".
--
-- The stub marker is written as `'STUB ' || char(8212) || ' ...'` rather than
-- with a literal em-dash, because scripts/d1-apply.mjs refuses non-ASCII files
-- and passing one through wrangler on Windows has produced mojibake.

-- --- the four production-only rows -------------------------------------------
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('huntsman-armor', 'Huntsman Armor', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats',
        'Rifts Book of Magic');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('air-filter-and-gas-mask', 'Air Filter And Gas Mask', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats',
        'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hovercycle', 'Hovercycle', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats',
        'Rifts Ultimate Edition p.233-235');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('light-mdc-body-armor', 'Light Mdc Body Armor', 'rifts',
        'STUB ' || char(8212) || ' created by class import, needs stats',
        'Rifts Ultimate Edition p.86-87');

-- --- the three superseded stubs ----------------------------------------------
-- Guarded on still being a stub, and on nothing referencing them. A stub that
-- has gained stats, or that some character turns out to hold, stops here.
DELETE FROM gear
 WHERE name = 'Energy Rifle'
   AND description LIKE 'STUB%'
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);
DELETE FROM gear
 WHERE name = 'Sunglasses Or Tinted Goggles'
   AND description LIKE 'STUB%'
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);
DELETE FROM gear
 WHERE name = 'Traveling Robe Or Cloak With Hood'
   AND description LIKE 'STUB%'
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- Read the result back rather than trusting the exit code.
--   restored     4 = the production-only rows now exist here too
--   superseded   0 = the three generic stubs are gone
--   orphans      0 = no inventory row points at gear that no longer exists.
--                    gear_slug IS NULL is EXCLUDED on purpose: a custom item
--                    is stored with a null gear_slug and its own custom_name,
--                    and counting those reported 11 'orphans' on a database
--                    with none.
SELECT (SELECT count(*) FROM gear WHERE name IN
          ('Huntsman Armor', 'Air Filter And Gas Mask', 'Hovercycle',
           'Light Mdc Body Armor')) AS restored,
       (SELECT count(*) FROM gear WHERE name IN
          ('Energy Rifle', 'Sunglasses Or Tinted Goggles',
           'Traveling Robe Or Cloak With Hood')) AS superseded,
       (SELECT count(*) FROM character_items ci
          WHERE ci.gear_slug IS NOT NULL
            AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.slug = ci.gear_slug)) AS orphans;

SELECT count(*) AS gear_total FROM gear;

INSERT INTO data_script_runs (filename) VALUES ('zz-reconcile-gear-with-production.sql');
