-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema, and it is only correct for the specific placeholder gear
-- the early class imports invented.
--
--   npx wrangler d1 execute DB --local  --file apps/character-creator/db/retire-gear-placeholders.sql
--   npx wrangler d1 execute DB --remote --file apps/character-creator/db/retire-gear-placeholders.sql
--
-- Safe to run twice, and safe to run EARLY: every statement guards itself, so in
-- an environment that has not imported the equipment chapter yet this does
-- nothing at all. Re-run it after that import and it completes. The final
-- SELECT reports what it did and what it is still waiting for.
--
-- BACKGROUND. Before equipment_starting supported choice groups, a class whose
-- book said "one energy pistol of choice" had nowhere to put that, so the
-- importer emitted a fixed item_id naming the CATEGORY - `energy-pistol`,
-- `vibro-blade`, `energy-rifle`, `ancient-weapon`. The class importer then
-- created a stub catalog row for each, because that is what it does for any
-- referenced item it cannot find.
--
-- Those rows are not items. No book entry will ever match them, so they sat in
-- the catalog forever with no stats, and a character built from such a class
-- held a weapon that does not exist.
--
-- WHY THE GUARDS. A choice is only an improvement if its options exist. Rewriting
-- the Juicer in an environment whose catalog is still seed-only would replace two
-- bad references with nine, and the next class import would stub every one of
-- them. So each rewrite requires its own options to be present, and a placeholder
-- is only dropped once no live class still cites it.

-- -- 1. The Juicer's two placeholders become real choices --
-- The options are the catalog's actual weapons of each kind. The book says
-- "of choice" without enumerating, so this is the available set, not a claim
-- about what the page lists - widen it as more books are imported.
--
-- Guarded on all four options existing: a rewrite that pointed at absent slugs
-- would be strictly worse than the placeholder it replaced.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "energy-pistol", qty: 1 }',
      '  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "ng-super-laser-pistol-and-grenade-launcher"] }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, 'item_id: "energy-pistol"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'ng-33-northern-gun-laser-pistol', 'wilk-s-320-laser-pistol',
        'ng-57-northern-gun-heavy-duty-ion-blaster', 'ng-super-laser-pistol-and-grenade-launcher')) = 4;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "vibro-blade", qty: 1 }',
      '  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-saber", "vibro-sword", "vibro-claws"] }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, 'item_id: "vibro-blade"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'vibro-knife', 'vibro-saber', 'vibro-sword', 'vibro-claws')) = 4;

-- Point the JA-11 citation straight at the book's entry, once that entry exists.
-- The redirect left by the merge already resolves the old slug, so this is
-- tidiness rather than a fix - and without the guard it would be the opposite,
-- replacing a slug that resolves with one that does not.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "ja-11-energy-rifle", qty: 1 }',
      '  - { item_id: "ja-11-juicer-assassin-s-energy-rifle", qty: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, 'item_id: "ja-11-energy-rifle"') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'ja-11-juicer-assassin-s-energy-rifle');

-- -- 2. Characters keep what they hold, as freeform lines --
-- Only for placeholders that are actually about to be retired. The placeholder
-- was never a real item, so a freeform inventory line naming it is the truthful
-- representation - and it is the same shape the wizard already falls back to.
-- The CHECK constraint allows a NULL gear_slug exactly when custom_name is set, so
-- these two columns must move together.
UPDATE character_items
SET custom_name = (SELECT name FROM gear WHERE gear.slug = character_items.gear_slug),
    notes = COALESCE(NULLIF(notes, ''), 'was a placeholder catalog entry; pick a real item'),
    gear_slug = NULL
WHERE gear_slug IN (
  SELECT g.slug FROM gear g
  WHERE g.slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon')
    AND NOT EXISTS (SELECT 1 FROM imported_classes c
                    WHERE c.deleted_at IS NULL AND instr(c.markdown, 'item_id: "' || g.slug || '"') > 0));

-- -- 3. Drop the placeholders no class still cites --
-- In an environment where step 1 could not run, the Juicer still names two of
-- them and they correctly survive.
DELETE FROM gear
WHERE slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon')
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE c.deleted_at IS NULL AND instr(c.markdown, 'item_id: "' || gear.slug || '"') > 0);

-- -- 4. Report --
SELECT (SELECT count(*) FROM gear
        WHERE slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon')) AS placeholders_left,
       (SELECT count(*) FROM imported_classes
        WHERE deleted_at IS NULL
          AND (instr(markdown, 'item_id: "energy-pistol"') > 0 OR instr(markdown, 'item_id: "vibro-blade"') > 0)) AS classes_still_citing,
       (SELECT count(*) FROM character_items ci JOIN gear g ON g.slug = ci.gear_slug
        WHERE g.slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon')) AS inventory_rows_still_attached,
       -- 0 means the equipment chapter has not been imported here yet; re-run
       -- this script after it has.
       (SELECT count(*) FROM gear WHERE slug IN (
          'ng-33-northern-gun-laser-pistol', 'wilk-s-320-laser-pistol',
          'ng-57-northern-gun-heavy-duty-ion-blaster', 'ng-super-laser-pistol-and-grenade-launcher',
          'vibro-knife', 'vibro-saber', 'vibro-sword', 'vibro-claws')) AS options_available_of_8;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('retire-gear-placeholders.sql');
