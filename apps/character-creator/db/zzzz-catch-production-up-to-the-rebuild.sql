-- Production catches up to the rebuild: four armour choices, the SAMAS pilot's
-- air filter, and four uncategorised gear rows.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-catch-production-up-to-the-rebuild.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-catch-production-up-to-the-rebuild.sql
--
-- THIS DOES NOTHING IN A REBUILD, and that is the point. Every statement is
-- guarded on the OLD value still being present. A database built from this
-- repo already holds the new value by the time this file is reached, so the
-- guards find nothing and the script correctly does nothing. It exists solely
-- to move production onto what a rebuild has held all along. See
-- REBUILD-AUDIT.md F19.
--
-- WHAT F19 SAID, AND WHAT WAS ACTUALLY TRUE. The finding proposed re-running
-- `retire-gear-placeholders.sql` against production. That script never mentions
-- `light-mdc-body-armor`; it handles four other placeholders and only for the
-- juicer. Re-running it would have changed nothing and looked like success.
-- The script that resolves these four classes is `fix-category-gear-rows.sql`.
--
-- AND RE-RUNNING THAT ONE WOULD ALSO DO NOTHING, permanently. Its guard
-- requires four slugs to exist:
--
--     dog-pack-dpm-riot-armor, plastic-man-body-armor,
--     ca-2-light-dead-boy-armor, urban-warrior-body-armor
--
-- `merge-rifts-armor-duplicates.sql` later merged two of those into the
-- environmental-armour rows that `add-rue-equipment.sql` had created:
--
--     plastic-man-body-armor   -> plastic-man-full-environmental-body-armor
--     urban-warrior-body-armor -> urban-warrior-padded-environmental-body-armor
--
-- so the guard now counts 2 of 4 and can never pass again in any environment.
-- This is the repeat offender documented in `scripts/trace-row.mjs`: a guard
-- naming a string an EARLIER file has already renamed matches nothing, does
-- nothing, and is indistinguishable from a file that had nothing to do.
--
-- WHY THE NEW TEXT STILL CITES THE PRE-MERGE SLUGS. It is copied byte for byte
-- out of a rebuild, because convergence is the whole goal - writing the
-- post-merge slugs here would make production differ from the repo again, in a
-- new way. The merge left `catalog_redirects` rows for both old slugs, and both
-- redirects are present in production and in a rebuild, so all four options
-- resolve. Verified 2026-08-28 rather than assumed.
--
-- THE SAMAS PILOT IS A BOOK QUESTION, AND THE BOOK ANSWERS IT. F19 called it
-- "not obvious which is right". RUE printed 233 and printed 235 both read
-- "air filter and gas mask" inside a comma-separated equipment list, next to
-- "energy rifle and energy sidearm of choice" - plainly two items. RUE also
-- writes it "air filter & gas mask" and "gas mask and air filter"; the order
-- varies, which happens for two things and not for one product. Production's
-- single `air-filter-and-gas-mask` is the importer making one catalog row out
-- of a two-item phrase, the same mistake as `light-mdc-body-armor`.
--
-- The merged gear row is NOT retired here. `coalition-samas-pilot` is the only
-- class citing it, so after this it is uncited - but retiring a catalog row is
-- a separate decision from correcting a class, and F19 did not ask for it.
--
-- `wizard` is deliberately untouched: one word of prose in extraction_notes,
-- "the" against "a" fifth starting group. F19 said leave it. It is left.

-- body-fixer
UPDATE imported_classes SET
      markdown = replace(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }', '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
      updated_at = datetime('now')
  WHERE class_id = 'body-fixer'
    AND instr(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }') > 0;

-- rogue-scientist
UPDATE imported_classes SET
      markdown = replace(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }', '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
      updated_at = datetime('now')
  WHERE class_id = 'rogue-scientist'
    AND instr(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }') > 0;

-- wilderness-scout
UPDATE imported_classes SET
      markdown = replace(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }', '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
      updated_at = datetime('now')
  WHERE class_id = 'wilderness-scout'
    AND instr(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }') > 0;

-- rifts-priest
UPDATE imported_classes SET
      markdown = replace(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }', '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
      updated_at = datetime('now')
  WHERE class_id = 'rifts-priest'
    AND instr(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }') > 0;

-- coalition-samas-pilot - RUE printed 233 and 235 both read "air filter and gas mask"
-- in a comma-separated list, beside "energy rifle and energy sidearm of
-- choice". Two items, not one product.
UPDATE imported_classes SET
      markdown = replace(markdown, '  - { item_id: "air-filter-and-gas-mask", qty: 1 }', '  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }'),
      updated_at = datetime('now')
  WHERE class_id = 'coalition-samas-pilot'
    AND instr(markdown, '  - { item_id: "air-filter-and-gas-mask", qty: 1 }') > 0;

-- The four uncategorised rows F18 handed over. zzz-gear-tidy-3-categories.sql
-- ends with an unconditional catch-all; on production it ran THREE HOURS
-- BEFORE fix-body-fixer-page-break.sql inserted these, so they missed it.
UPDATE gear SET category = 'gear'
  WHERE slug IN ('hand-held-blood-pressure-machine', 'unbreakable-vial', 'medical-bag', 'poncho')
    AND category IS NULL;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-catch-production-up-to-the-rebuild.sql');
