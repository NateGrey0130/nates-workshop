-- Five class equipment lines that a CLEAN REBUILD leaves pointing at nothing.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-repair-gear-citations.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-repair-gear-citations.sql
--
-- ON PRODUCTION THIS CHANGES NOTHING, and that is the point. Every one of these
-- corrections already ran there. What it repairs is the REBUILD: replay the
-- data scripts against an empty database in filename order and five classes
-- come out citing gear that has no row and no redirect.
--
-- HOW THEY BROKE, and it is the same shape five times: each correction is
-- guarded on the rows it wants to point AT already existing, and on a clean
-- rebuild some of those rows are created by a script that sorts LATER.
--
--   fix-shifter-energy-rifle.sql        pos 151, needs six rifles
--   restore-gear-missing-from-repo.sql  pos 168, CREATES all six
--
-- So the guard reads count(*) = 6 against a catalog holding none of them, the
-- UPDATE is skipped, and the citation survives. Then zz-reconcile deletes the
-- stub row it points at, and the class is left holding an object that does not
-- exist. Production never saw this because the fixes were applied by hand at a
-- time when the rows were already there.
--
-- WHY NOTHING CAUGHT IT. drift-check compares CLASS COUNTS - 76 live, 76
-- creatable - and repo-vs-live compares the five CATALOGS. Neither compares
-- class markdown, so a class whose equipment differs between production and a
-- rebuild is invisible to both. Regression now asserts that every gear id a
-- class cites resolves to a row or a redirect, which is what found these.
--
-- THE REPLACEMENT TEXT IS NOT INVENTED. Each line below is copied from the
-- correction that was supposed to apply, so a rebuild reaches the state
-- production is already in rather than a new one:
--
--   energy-rifle                       fix-shifter-energy-rifle.sql
--   sunglasses-or-tinted-goggles       fix-structural-gear-rows.sql
--   tinted-goggles-or-sunglasses       fix-structural-gear-rows.sql
--   traveling-robe-or-cloak-with-hood  fix-structural-gear-rows.sql
--   ns-turbo-cyclone                   fix-category-gear-rows.sql
--
-- Guarded the same way the originals were - on the target rows existing - so
-- this is a no-op if a future reordering ever makes it unnecessary. At zz-
-- position every one of the thirteen targets exists.

-- The Shifter's energy rifle, six real rifles instead of a category.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "energy-rifle", qty: 1 }',
         '  - { choose: 1, label: "energy rifle", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"] }'),
       updated_at = datetime('now')
 WHERE instr(markdown, 'item_id: "energy-rifle"') > 0
   AND (SELECT count(*) FROM gear WHERE slug IN (
         'ja-11-juicer-assassin-s-energy-rifle',
         'ja-9-juicer-assassin-variable-laser-rifle',
         'l-20-pulse-rifle',
         'ng-l5-northern-gun-laser-rifle',
         'ng-p7-northern-gun-particle-beam-rifle',
         'wilk-s-447-laser-rifle')) = 6;

-- Both spellings of the same pair, cited by twelve classes between them.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "sunglasses-or-tinted-goggles", qty: 1 }',
         '  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }'),
       updated_at = datetime('now')
 WHERE instr(markdown, 'item_id: "sunglasses-or-tinted-goggles"') > 0
   AND (SELECT count(*) FROM gear WHERE slug IN ('sunglasses', 'tinted-goggles')) = 2;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }',
         '  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }'),
       updated_at = datetime('now')
 WHERE instr(markdown, 'item_id: "tinted-goggles-or-sunglasses"') > 0
   AND (SELECT count(*) FROM gear WHERE slug IN ('sunglasses', 'tinted-goggles')) = 2;

-- The Priest of Light's robe.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "traveling-robe-or-cloak-with-hood", qty: 1 }',
         '  - { choose: 1, label: "traveling robe or hooded cloak", qty: 1, from: ["hooded-robe", "hooded-cloak"] }'),
       updated_at = datetime('now')
 WHERE instr(markdown, 'item_id: "traveling-robe-or-cloak-with-hood"') > 0
   AND (SELECT count(*) FROM gear WHERE slug IN ('hooded-robe', 'hooded-cloak')) = 2;

-- The Cyber-Knight's transportation. There is no Rifts vehicle called a "Turbo
-- Cyclone" - the book grants a choice and the importer flattened it into an
-- invented item.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "ns-turbo-cyclone", qty: 1 }',
         '  - { choose: 1, label: "transportation", qty: 1, from: ["a-t-v-speedster-hover-cycle", "the-highway-man-motorcycle", "the-wastelander-motorcycle"] }'),
       updated_at = datetime('now')
 WHERE instr(markdown, 'item_id: "ns-turbo-cyclone"') > 0
   AND (SELECT count(*) FROM gear WHERE slug IN (
         'a-t-v-speedster-hover-cycle',
         'the-highway-man-motorcycle',
         'the-wastelander-motorcycle')) = 3;


-- Read the result back rather than trusting the exit code. On production every
-- one of these is already zero, which is the proof that this repairs the
-- rebuild and does not change what is live.
SELECT count(*) AS classes_still_citing_a_missing_row FROM imported_classes
 WHERE status = 'published'
   AND (instr(markdown, 'item_id: "energy-rifle"') > 0
     OR instr(markdown, 'item_id: "sunglasses-or-tinted-goggles"') > 0
     OR instr(markdown, 'item_id: "tinted-goggles-or-sunglasses"') > 0
     OR instr(markdown, 'item_id: "traveling-robe-or-cloak-with-hood"') > 0
     OR instr(markdown, 'item_id: "ns-turbo-cyclone"') > 0);
SELECT count(*) AS classes_offering_the_choices_instead FROM imported_classes
 WHERE status = 'published'
   AND (instr(markdown, 'label: "energy rifle"') > 0
     OR instr(markdown, 'label: "sunglasses or tinted goggles"') > 0
     OR instr(markdown, 'label: "tinted goggles or sunglasses"') > 0
     OR instr(markdown, 'label: "traveling robe or hooded cloak"') > 0
     OR instr(markdown, 'label: "transportation"') > 0);
SELECT count(*) AS cr_anywhere_in_a_touched_class FROM imported_classes
 WHERE status = 'published' AND instr(markdown, char(13)) > 0
   AND instr(markdown, 'label: "energy rifle"') > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zz-repair-gear-citations.sql');
