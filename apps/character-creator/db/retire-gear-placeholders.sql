-- One-off data cleanup, run once per environment. NOT a migration — it changes
-- rows, not schema, and it is only correct for the specific placeholder gear
-- the early class imports invented.
--
--   npx wrangler d1 execute DB --local  --file apps/character-creator/db/retire-gear-placeholders.sql
--   npx wrangler d1 execute DB --remote --file apps/character-creator/db/retire-gear-placeholders.sql
--
-- Safe to run twice: every statement is a no-op once it has been applied.
--
-- BACKGROUND. Before equipment_starting supported choice groups, a class whose
-- book said "one energy pistol of choice" had nowhere to put that, so the
-- importer emitted a fixed item_id naming the CATEGORY — `energy-pistol`,
-- `vibro-blade`, `energy-rifle`, `ancient-weapon`. The class importer then
-- created a stub catalog row for each, because that is what it does for any
-- referenced item it cannot find.
--
-- Those rows are not items. No book entry will ever match them, so they sat in
-- the catalog forever with no stats, and a character built from such a class
-- held a weapon that does not exist.

-- ── 1. Characters keep what they hold, as freeform lines ──
-- The placeholder was never a real item, so a freeform inventory line naming it
-- is the truthful representation — and it is the same shape the wizard already
-- falls back to. The CHECK constraint allows a NULL item_id exactly when
-- custom_name is set, so these two columns must move together.
UPDATE character_items
SET custom_name = (SELECT name FROM gear WHERE gear.id = character_items.item_id),
    notes = COALESCE(NULLIF(notes, ''), 'was a placeholder catalog entry; pick a real item'),
    item_id = NULL
WHERE item_id IN (SELECT id FROM gear
                  WHERE slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon'));

-- ── 2. The Juicer's two placeholders become real choices ──
-- The options are the catalog's actual weapons of each kind. The book says
-- "of choice" without enumerating, so this is the available set, not a claim
-- about what the page lists — widen it as more books are imported.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "energy-pistol", qty: 1 }',
      '  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "ng-super-laser-pistol-and-grenade-launcher"] }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer' AND markdown LIKE '%item_id: "energy-pistol"%';

UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "vibro-blade", qty: 1 }',
      '  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-saber", "vibro-sword", "vibro-claws"] }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer' AND markdown LIKE '%item_id: "vibro-blade"%';

-- Point the JA-11 citation straight at the book's entry. The redirect left by
-- the merge already resolves the old slug, so this is tidiness rather than a
-- fix — the redirect stays in place for anything else still citing it.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "ja-11-energy-rifle", qty: 1 }',
      '  - { item_id: "ja-11-juicer-assassin-s-energy-rifle", qty: 1 }'),
    updated_at = datetime('now')
WHERE class_id = 'juicer' AND markdown LIKE '%item_id: "ja-11-energy-rifle"%';

-- ── 3. Drop the placeholders ──
-- Nothing references them now: step 1 detached every inventory row and step 2
-- rewrote the only class that cited them.
DELETE FROM gear WHERE slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon');

-- ── 4. Report ──
SELECT (SELECT count(*) FROM gear
        WHERE slug IN ('energy-pistol', 'energy-rifle', 'vibro-blade', 'ancient-weapon')) AS placeholders_left,
       (SELECT count(*) FROM character_items
        WHERE item_id IS NULL AND custom_name IN ('Energy Pistol', 'Vibro Blade', 'Energy Rifle', 'Ancient Weapon')) AS freeform_lines,
       (SELECT count(*) FROM imported_classes
        WHERE class_id = 'juicer' AND markdown LIKE '%choose: 1, label: "energy pistol"%') AS juicer_converted;
