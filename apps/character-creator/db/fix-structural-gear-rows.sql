-- The twelve gear rows that are not items.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-structural-gear-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-structural-gear-rows.sql
--
-- Of the 123 gear stubs, twelve are not unfilled items - they are the wrong
-- SHAPE, and no amount of book-reading fixes them:
--
--   seven are CHOICES  "Air Filter Or Gas Mask", "Pen Or Pencil"
--   five are BUNDLES   "Wooden Stake And Mallet", "Flint And Charcoal"
--
-- The class importer met a book line like "an air filter and gas mask" and made
-- one catalog row out of it, so the character holds a single object that does
-- not exist instead of two that do. Same failure the energy-pistol placeholders
-- had, and the same fix: `equipment_starting` already supports a `choose`
-- entry, and a bundle is simply two entries. See
-- [Starting gear the class leaves open] in the README.
--
-- "Tinted Goggles Or Sunglasses" and "Sunglasses Or Tinted Goggles" are the
-- SAME choice imported under two names, which is why there are twelve rows but
-- eleven distinct problems.
--
-- Every statement guards itself, on the same reasoning retire-gear-placeholders
-- was written with: a choice is only an improvement if its options exist, so a
-- rewrite that pointed at absent slugs would be strictly worse than the row it
-- replaced. In an environment missing them, this does nothing and the closing
-- SELECT says so.

-- -- 1. The simple items a split or a choice has to point at --
-- Ordinary objects, so system 'both'. These are stubs like the ~110 others and
-- still need weight and cost - but a stub of a REAL item is a different kind of
-- thing from a row standing for a choice nobody can hold.

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('tinted-goggles', 'Tinted Goggles', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('robe', 'Robe', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('cape', 'Cape', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('pen', 'Pen', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('pencil', 'Pencil', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('note-pad', 'Note Pad', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('sketch-pad', 'Sketch Pad', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('flint', 'Flint', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('charcoal', 'Charcoal', 'both', 'STUB - split out of a choice or bundle row; needs stats');

INSERT OR IGNORE INTO gear (slug, name, system, description)
VALUES ('camouflage-fatigues', 'Camouflage Fatigues', 'both', 'STUB - split out of a choice or bundle row; needs stats');

-- -- 2. Bundles become two entries --
-- One book line, two objects. The character was holding neither.

-- Cited by thirteen classes - the single most common structural row.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "air-filter-and-gas-mask", qty: 1 }',
      '  - { item_id: "air-filter", qty: 1 }'
      || char(10) || '  - { item_id: "gas-mask", qty: 1 }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "air-filter-and-gas-mask"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('air-filter', 'gas-mask')) = 2;

-- Both halves were already in the catalog. The quantity does NOT split evenly: the classes grant "qty: 6", which is six stakes and ONE mallet. Splitting 6 and 6 would have handed out five mallets nobody has.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "wooden-stake-and-mallet", qty: 6 }',
      '  - { item_id: "wooden-stake", qty: 6 }'
      || char(10) || '  - { item_id: "small-mallet", qty: 1 }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "wooden-stake-and-mallet"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('wooden-stake', 'small-mallet')) = 2;

-- Reuses the existing Fatigues row rather than adding a near-duplicate "military-fatigues" beside it.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "military-fatigues-and-dress-uniform", qty: 1 }',
      '  - { item_id: "fatigues", qty: 1 }'
      || char(10) || '  - { item_id: "dress-uniform", qty: 1 }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "military-fatigues-and-dress-uniform"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('fatigues', 'dress-uniform')) = 2;

-- Both halves are new rows.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "flint-and-charcoal", qty: 1 }',
      '  - { item_id: "flint", qty: 1 }'
      || char(10) || '  - { item_id: "charcoal", qty: 1 }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "flint-and-charcoal"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('flint', 'charcoal')) = 2;

-- The Juicer's "camouflage fatigues and armor" is the one that does not split
-- evenly: the armor half is already its own entry on the same list
-- (juicer-flex-plate-armor), so splitting would grant it twice. Only the
-- fatigues are missing, so that is all this adds.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "camouflage-fatigues-and-armor", qty: 1 }',
      '  - { item_id: "camouflage-fatigues", qty: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer'
  AND instr(markdown, 'item_id: "camouflage-fatigues-and-armor"') > 0
  AND instr(markdown, 'item_id: "juicer-flex-plate-armor"') > 0
  AND EXISTS (SELECT 1 FROM gear WHERE slug = 'camouflage-fatigues');

-- -- 3. Choices become a choose entry --
-- `label` is what the player is choosing; `from` enumerates real slugs.

-- The same two items the AND row above splits into - the Mind Melter gets one, everyone else gets both.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "air-filter-or-gas-mask", qty: 1 }',
      '  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "air-filter-or-gas-mask"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('air-filter', 'gas-mask')) = 2;

-- One of a pair: the same choice was imported under two names.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "sunglasses-or-tinted-goggles", qty: 1 }',
      '  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "sunglasses-or-tinted-goggles"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('sunglasses', 'tinted-goggles')) = 2;

-- The other half of that pair, cited by eleven classes. Both retire into the same choice, which is why the duplicate was harmless to leave until now.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }',
      '  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "tinted-goggles-or-sunglasses"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('sunglasses', 'tinted-goggles')) = 2;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "note-or-sketch-pad", qty: 1 }',
      '  - { choose: 1, label: "note or sketch pad", qty: 1, from: ["note-pad", "sketch-pad"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "note-or-sketch-pad"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('note-pad', 'sketch-pad')) = 2;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "pen-or-pencil", qty: 1 }',
      '  - { choose: 1, label: "pen or pencil", qty: 1, from: ["pen", "pencil"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "pen-or-pencil"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('pen', 'pencil')) = 2;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "robe-or-cape", qty: 1 }',
      '  - { choose: 1, label: "robe or cape", qty: 1, from: ["robe", "cape"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "robe-or-cape"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('robe', 'cape')) = 2;

-- Both options already existed; no new rows needed.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "traveling-robe-or-cloak-with-hood", qty: 1 }',
      '  - { choose: 1, label: "traveling robe or hooded cloak", qty: 1, from: ["hooded-robe", "hooded-cloak"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "traveling-robe-or-cloak-with-hood"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('hooded-robe', 'hooded-cloak')) = 2;

-- -- 4. Inventory rows holding one of them become freeform lines --
-- The row was never a real item, so naming it as text is the truthful
-- representation. Only for rows no live class still cites, so an environment
-- where step 2 or 3 could not run keeps its references intact.
UPDATE character_items
SET custom_name = (SELECT name FROM gear WHERE gear.slug = character_items.gear_slug),
    notes = COALESCE(NULLIF(notes, ''), 'was a bundle or choice row, not an item; pick the real one'),
    gear_slug = NULL
WHERE gear_slug IN (
  SELECT g.slug FROM gear g
  WHERE g.slug IN ('air-filter-and-gas-mask', 'wooden-stake-and-mallet', 'military-fatigues-and-dress-uniform', 'flint-and-charcoal', 'air-filter-or-gas-mask', 'sunglasses-or-tinted-goggles', 'tinted-goggles-or-sunglasses', 'note-or-sketch-pad', 'pen-or-pencil', 'robe-or-cape', 'traveling-robe-or-cloak-with-hood', 'camouflage-fatigues-and-armor')
    AND NOT EXISTS (SELECT 1 FROM imported_classes c
                    WHERE c.deleted_at IS NULL AND instr(c.markdown, 'item_id: "' || g.slug || '"') > 0));

-- -- 5. Drop the rows nothing cites any more --
DELETE FROM gear
WHERE slug IN ('air-filter-and-gas-mask', 'wooden-stake-and-mallet', 'military-fatigues-and-dress-uniform', 'flint-and-charcoal', 'air-filter-or-gas-mask', 'sunglasses-or-tinted-goggles', 'tinted-goggles-or-sunglasses', 'note-or-sketch-pad', 'pen-or-pencil', 'robe-or-cape', 'traveling-robe-or-cloak-with-hood', 'camouflage-fatigues-and-armor')
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE c.deleted_at IS NULL
                    AND instr(c.markdown, 'item_id: "' || gear.slug || '"') > 0)
  AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- Reports the result back, so it is read rather than assumed.
--   structural_left      0 = every bundle and choice row is gone
--   still_cited          0 = no live class names one of them
--   inventory_attached   0 = no character still holds one as a catalog item
--   new_items           10 = the simple rows the splits and choices point at
--   choices_written      7 = choose entries now in class markdown
--   stubs_now           the running total, for comparison against 123
SELECT (SELECT count(*) FROM gear WHERE slug IN ('air-filter-and-gas-mask', 'wooden-stake-and-mallet', 'military-fatigues-and-dress-uniform', 'flint-and-charcoal', 'air-filter-or-gas-mask', 'sunglasses-or-tinted-goggles', 'tinted-goggles-or-sunglasses', 'note-or-sketch-pad', 'pen-or-pencil', 'robe-or-cape', 'traveling-robe-or-cloak-with-hood', 'camouflage-fatigues-and-armor')) AS structural_left,
       (SELECT count(*) FROM imported_classes c, gear g
          WHERE c.deleted_at IS NULL AND g.slug IN ('air-filter-and-gas-mask', 'wooden-stake-and-mallet', 'military-fatigues-and-dress-uniform', 'flint-and-charcoal', 'air-filter-or-gas-mask', 'sunglasses-or-tinted-goggles', 'tinted-goggles-or-sunglasses', 'note-or-sketch-pad', 'pen-or-pencil', 'robe-or-cape', 'traveling-robe-or-cloak-with-hood', 'camouflage-fatigues-and-armor')
            AND instr(c.markdown, 'item_id: "' || g.slug || '"') > 0) AS still_cited,
       (SELECT count(*) FROM character_items ci JOIN gear g ON g.slug = ci.gear_slug
          WHERE g.slug IN ('air-filter-and-gas-mask', 'wooden-stake-and-mallet', 'military-fatigues-and-dress-uniform', 'flint-and-charcoal', 'air-filter-or-gas-mask', 'sunglasses-or-tinted-goggles', 'tinted-goggles-or-sunglasses', 'note-or-sketch-pad', 'pen-or-pencil', 'robe-or-cape', 'traveling-robe-or-cloak-with-hood', 'camouflage-fatigues-and-armor')) AS inventory_attached,
       (SELECT count(*) FROM gear WHERE slug IN ('tinted-goggles', 'robe', 'cape', 'pen', 'pencil', 'note-pad', 'sketch-pad', 'flint', 'charcoal', 'camouflage-fatigues')) AS new_items,
       (SELECT count(*) FROM imported_classes
          WHERE deleted_at IS NULL AND instr(markdown, '{ choose: 1, label:') > 0) AS classes_with_gear_choices,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-structural-gear-rows.sql');
