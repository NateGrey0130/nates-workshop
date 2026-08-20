-- Choice options that point at rows which do not exist.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-phantom-choice-options.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-phantom-choice-options.sql
--
-- `energy-pistol`, `energy-rifle` and `automatic-pistol` have NO rows in the
-- gear catalog - retire-gear-placeholders.sql dropped them once nothing cited
-- them by item_id - yet seven classes still offer them as choice OPTIONS. The
-- wizard marks such an option "not in the catalog yet" and lets it be picked
-- anyway, so nothing was blocked; the character simply ended up holding a
-- reference to nothing.
--
-- Two shapes of fix, because the classes are not all in the same state:
--
--   SUBSTITUTE  Six classes offered nothing but phantoms. Their lists are
--               replaced with the real weapons the catalog holds.
--   DROP        The Glitter Boy already names four real rifles and two real
--               pistols, with a phantom trailing each list. There is nothing to
--               substitute - the entry just comes out.
--
-- The lists name Northern Gun and Wilk's weapons because those are what this
-- catalog actually has. That is the available set, not a claim about what any
-- page enumerates - widen it as more books are imported, the same way
-- retire-gear-placeholders.sql said of the Juicer's.
--
-- Every rewrite is guarded on the real options existing, so a catalog without
-- them is left alone rather than having phantoms swapped for absentees.
--
-- FOUR ENTRIES ARE DELIBERATELY LEFT ALONE, and they are all the same problem:
--
--   glitter-boy      "non-energy weapon of choice"          rifle, automatic pistol, SMG
--   mind-melter      "non-energy rifle or other weapon"     rifle, automatic pistol, SMG
--   ley-line-rifter  "automatic pistol or submachine-gun"   automatic pistol, SMG
--   ley-line-walker  "automatic pistol or submachine-gun"   automatic pistol, SMG
--
-- These want CONVENTIONAL firearms, and the catalog holds none at all - no
-- revolver, no automatic pistol, no assault rifle, no shotgun, no sub-machine
-- gun. `submachine-gun` is itself a category stub and `rifle` is not even a
-- row. Substituting here would mean swapping phantoms for absentees, which the
-- guard exists to prevent. They resolve when a book with conventional weapons
-- is imported, and not before.


-- The side arm was a choice between two slugs that do not exist, so it offered nothing real at all.
UPDATE imported_classes
SET markdown = replace(markdown,
      '["automatic-pistol", "energy-pistol"]',
      '["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"]'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, '["automatic-pistol", "energy-pistol"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

UPDATE imported_classes
SET markdown = replace(markdown,
      '["automatic-pistol", "energy-pistol"]',
      '["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"]'),
    updated_at = datetime('now')
WHERE class_id = 'robot-pilot'
  AND instr(markdown, '["automatic-pistol", "energy-pistol"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

-- Only the automatic pistol was a phantom here; the Triax weapon is a real row and stays on the list.
UPDATE imported_classes
SET markdown = replace(markdown,
      '["automatic-pistol", "triax-pump-weapon"]',
      '["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "triax-pump-weapon"]'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, '["automatic-pistol", "triax-pump-weapon"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

UPDATE imported_classes
SET markdown = replace(markdown,
      '["energy-pistol", "energy-rifle"]',
      '["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"]'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-rifter'
  AND instr(markdown, '["energy-pistol", "energy-rifle"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

UPDATE imported_classes
SET markdown = replace(markdown,
      '["energy-pistol", "energy-rifle"]',
      '["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"]'),
    updated_at = datetime('now')
WHERE class_id = 'ley-line-walker'
  AND instr(markdown, '["energy-pistol", "energy-rifle"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

-- Labelled "energy weapon of choice", so both pistols and rifles are on offer.
UPDATE imported_classes
SET markdown = replace(markdown,
      '["energy-pistol", "energy-rifle"]',
      '["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"]'),
    updated_at = datetime('now')
WHERE class_id = 'mind-melter'
  AND instr(markdown, '["energy-pistol", "energy-rifle"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

-- A SECOND entry in the same class, offering a single phantom and nothing else. Found only by enumerating every choose entry - the first pass used instr(), which returns one match per class and hid this completely.
UPDATE imported_classes
SET markdown = replace(markdown,
      '["energy-rifle"]',
      '["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"]'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, '["energy-rifle"]') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol', 'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol', 'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 7;

-- Its rifle list already names four real weapons, with the phantom slug trailing behind them. Nothing to substitute - just remove it.
UPDATE imported_classes
SET markdown = replace(markdown, ', "energy-rifle"', ''),
    updated_at = datetime('now')
WHERE class_id = 'glitter-boy'
  AND instr(markdown, ', "energy-rifle"') > 0;

UPDATE imported_classes
SET markdown = replace(markdown, ', "energy-pistol"', ''),
    updated_at = datetime('now')
WHERE class_id = 'glitter-boy'
  AND instr(markdown, ', "energy-pistol"') > 0;

-- Reports the result back, so it is read rather than assumed.
--   phantom_rows      0 = these slugs still have no catalog rows, as intended
--   classes_citing    the classes naming ANY of the three - the four
--                     conventional-weapon entries below are expected to remain
--   energy_left       0 = no ENERGY phantom is cited any more, which is what
--                     this script set out to fix
--   conventional_left the four classes whose conventional-weapon choices have
--                     no real options to offer yet
SELECT (SELECT count(*) FROM gear
          WHERE slug IN ('energy-pistol', 'energy-rifle', 'automatic-pistol')) AS phantom_rows,
       (SELECT count(*) FROM imported_classes
          WHERE deleted_at IS NULL
            AND (instr(markdown, '"energy-pistol"') > 0
              OR instr(markdown, '"energy-rifle"') > 0
              OR instr(markdown, '"automatic-pistol"') > 0)) AS classes_citing,
       (SELECT count(*) FROM imported_classes
          WHERE deleted_at IS NULL
            AND (instr(markdown, '"energy-pistol"') > 0
              OR instr(markdown, '"energy-rifle"') > 0)) AS energy_left,
       (SELECT coalesce(group_concat(class_id, ', '), 'none') FROM imported_classes
          WHERE deleted_at IS NULL
            AND instr(markdown, '"automatic-pistol"') > 0) AS conventional_left;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-phantom-choice-options.sql');
