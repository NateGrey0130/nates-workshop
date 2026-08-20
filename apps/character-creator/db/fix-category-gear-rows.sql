-- The four gear rows that name a category instead of an item.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-category-gear-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-category-gear-rows.sql
--
-- light-mdc-body-armor (9 classes), mdc-body-armor (3), heavy-mdc-body-armor
-- (1) and ns-turbo-cyclone (1) are not items. A book line saying "light M.D.C.
-- body armor" means "any light suit"; the importer made a catalog row out of
-- the category, so the character holds an object that does not exist.
--
-- These could NOT be fixed the way the choice rows were, because the catalog
-- had nothing to point them at: the only filled armours in it were Cyber-Armor
-- (grown, Cyber-Knight only), the Dog Pack riot armor and the Glitter Boy. The
-- equipment chapter has never been imported. So step 1 creates the suits, and
-- only then do the categories become choices.
--
-- THE ARMOUR STATS COME FROM THE WEB, NOT THE BOOK, and source_book says so on
-- every new row rather than naming a page nobody checked.
--
-- Every rewrite is guarded on its own options existing, and every row is
-- dropped only once no live class and no inventory row still points at it - so
-- in an environment without the suits this does nothing and says so.

-- -- 1. Real body armour, so the categories have something to mean --

INSERT OR IGNORE INTO gear (slug, name, system, category, mdc, weight_lbs, cost, is_mega_damage, description, source_book)
VALUES ('plastic-man-body-armor', 'Plastic-Man Body Armor', 'rifts', 'armor', 35, 13, 18000, 1,
        'Light full body armor. M.D.C. by location: main body 35, helmet 30, arms 15 each, legs 22 each. Penalties: -5% Prowl, -10% to other physical skills.', 'Web reference (not book-verified)');

INSERT OR IGNORE INTO gear (slug, name, system, category, mdc, weight_lbs, cost, is_mega_damage, description, source_book)
VALUES ('urban-warrior-body-armor', 'Urban Warrior Body Armor', 'rifts', 'armor', 50, 11, 35000, 1,
        'Light full body armor, and the least restrictive of the common suits. M.D.C. by location: main body 50, helmet 35, arms 16 each, legs 30 each. Penalties: no Prowl penalty, -5% to other physical skills.', 'Web reference (not book-verified)');

INSERT OR IGNORE INTO gear (slug, name, system, category, mdc, weight_lbs, cost, is_mega_damage, description, source_book)
VALUES ('ca-2-light-dead-boy-armor', 'CA-2 Light Dead Boy Armor', 'rifts', 'armor', 50, 9, 40000, 1,
        'Coalition light body armor, 50 M.D.C. for the full suit. -10% Prowl. The price is the black market rate; Coalition issue is not sold openly.', 'Web reference (not book-verified)');

INSERT OR IGNORE INTO gear (slug, name, system, category, mdc, weight_lbs, cost, is_mega_damage, description, source_book)
VALUES ('gladiator-body-armor', 'Gladiator Body Armor', 'rifts', 'armor', 70, 21, 38000, 1,
        'Heavy full body armor. M.D.C. by location: main body 70, helmet 45, arms 25 each, legs 45 each. Penalties: -5% Prowl, -10% to other physical skills. Typically 38,000 to 50,000 credits on the black market.', 'Web reference (not book-verified)');

INSERT OR IGNORE INTO gear (slug, name, system, category, mdc, weight_lbs, cost, is_mega_damage, description, source_book)
VALUES ('ca-1-heavy-dead-boy-armor', 'CA-1 Heavy Dead Boy Armor', 'rifts', 'armor', 80, 18, 70000, 1,
        'Coalition heavy body armor, 80 M.D.C. for the full suit. -25% Prowl, the heaviest penalty of the common suits. The price is the black market rate.', 'Web reference (not book-verified)');

INSERT OR IGNORE INTO gear (slug, name, system, category, mdc, weight_lbs, cost, is_mega_damage, description, source_book)
VALUES ('crusader-body-armor', 'Crusader Body Armor', 'rifts', 'armor', 95, 24, 40000, 1,
        'Heavy full fibre body armor, the toughest of the common suits. M.D.C. by location: main body 95, helmet 50, arms 30 each, legs 50 each. Penalties: -10% Prowl, -15% to other physical skills. Typically 40,000 to 55,000 credits.', 'Web reference (not book-verified)');

-- -- 2. The categories become choices --
-- `label` is what the player is choosing; `from` enumerates real slugs.

-- Cited by NINE classes - the most-referenced category row in the catalog. The source that confirmed it is a category rather than an item writes it as a RANGE, "light M.D. body armor (30-40 M.D.C.)", which is not something a character can hold.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "light-mdc-body-armor", qty: 1 }',
      '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "light-mdc-body-armor"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor')) = 4;

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "heavy-mdc-body-armor", qty: 1 }',
      '  - { choose: 1, label: "heavy M.D.C. body armor", qty: 1, from: ["gladiator-body-armor", "ca-1-heavy-dead-boy-armor", "crusader-body-armor"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "heavy-mdc-body-armor"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('gladiator-body-armor', 'ca-1-heavy-dead-boy-armor', 'crusader-body-armor')) = 3;

-- No weight qualifier on this one, so every suit is on offer.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "mdc-body-armor", qty: 1 }',
      '  - { choose: 1, label: "M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "gladiator-body-armor", "ca-1-heavy-dead-boy-armor", "crusader-body-armor"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "mdc-body-armor"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor', 'gladiator-body-armor', 'ca-1-heavy-dead-boy-armor', 'crusader-body-armor')) = 7;

-- There is no Rifts vehicle called a "Turbo Cyclone". The Cyber-Knight - the only class citing it - is granted transportation as a CHOICE: horse, robot horse, bionic horse, hover cycle or modified motorcycle. The importer flattened that line into an invented item. No horses exist in the catalog yet, so the options here are the powered ones.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "ns-turbo-cyclone", qty: 1 }',
      '  - { choose: 1, label: "transportation", qty: 1, from: ["a-t-v-speedster-hover-cycle", "the-highway-man-motorcycle", "the-wastelander-motorcycle"] }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "ns-turbo-cyclone"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('a-t-v-speedster-hover-cycle', 'the-highway-man-motorcycle', 'the-wastelander-motorcycle')) = 3;

-- -- 3. Inventory rows holding a category become freeform lines --
-- The row was never a real item, so naming it as text is the truthful
-- representation. Only for rows no live class still cites.
UPDATE character_items
SET custom_name = (SELECT name FROM gear WHERE gear.id = character_items.item_id),
    notes = COALESCE(NULLIF(notes, ''), 'was a category, not an item; pick a real one'),
    item_id = NULL
WHERE item_id IN (
  SELECT g.id FROM gear g
  WHERE g.slug IN ('light-mdc-body-armor', 'heavy-mdc-body-armor', 'mdc-body-armor', 'ns-turbo-cyclone')
    AND NOT EXISTS (SELECT 1 FROM imported_classes c
                    WHERE c.deleted_at IS NULL AND instr(c.markdown, 'item_id: "' || g.slug || '"') > 0));

-- -- 4. Drop the categories nothing cites any more --
DELETE FROM gear
WHERE slug IN ('light-mdc-body-armor', 'heavy-mdc-body-armor', 'mdc-body-armor', 'ns-turbo-cyclone')
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE c.deleted_at IS NULL
                    AND instr(c.markdown, 'item_id: "' || gear.slug || '"') > 0)
  AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.item_id = gear.id);

-- Reports the result back, so it is read rather than assumed.
--   categories_left     0 = all four are gone
--   still_cited         0 = no live class names one of them
--   inventory_attached  0 = no character still holds one as a catalog item
--   suits_added         6 = the armours the choices point at
--   armour_range        the M.D.C. spread now available, lightest to heaviest
--   stubs_now           the running total, for comparison against 114
SELECT (SELECT count(*) FROM gear WHERE slug IN ('light-mdc-body-armor', 'heavy-mdc-body-armor', 'mdc-body-armor', 'ns-turbo-cyclone')) AS categories_left,
       (SELECT count(*) FROM imported_classes c, gear g
          WHERE c.deleted_at IS NULL AND g.slug IN ('light-mdc-body-armor', 'heavy-mdc-body-armor', 'mdc-body-armor', 'ns-turbo-cyclone')
            AND instr(c.markdown, 'item_id: "' || g.slug || '"') > 0) AS still_cited,
       (SELECT count(*) FROM character_items ci JOIN gear g ON g.id = ci.item_id
          WHERE g.slug IN ('light-mdc-body-armor', 'heavy-mdc-body-armor', 'mdc-body-armor', 'ns-turbo-cyclone')) AS inventory_attached,
       (SELECT count(*) FROM gear WHERE slug IN ('plastic-man-body-armor', 'urban-warrior-body-armor', 'ca-2-light-dead-boy-armor', 'gladiator-body-armor', 'ca-1-heavy-dead-boy-armor', 'crusader-body-armor')) AS suits_added,
       (SELECT min(mdc) || '-' || max(mdc) FROM gear
          WHERE category = 'armor' AND mdc IS NOT NULL) AS armour_range,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-category-gear-rows.sql');
