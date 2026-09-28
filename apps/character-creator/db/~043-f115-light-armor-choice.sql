-- BOOK-INGEST-AUDIT F115: psi-tech and zenith-moon-warper get the light body
-- armour choice that fix-category-gear-rows.sql gives every other class.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~043-f115-light-armor-choice.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~043-f115-light-armor-choice.sql
--
-- fix-category-gear-rows.sql (the comment at its line 56) turns
-- `item_id: "light-mdc-body-armor"` into a choice of four real suits, because
-- the row is a category ("any light suit"), not something a character can hold.
-- Both classes were imported live on 2026-09-25, after that fix had run
-- (2026-08-20), so production kept the placeholder. F105's sync
-- (~042-f105-sync-repo-to-production.sql) then brought the repo to production,
-- as its policy requires, and filed this correction separately. THIS SCRIPT
-- CHANGES PRODUCTION: two rows, the two classes named below, and nothing else.
--
-- The book agrees. Psyscape prints a generic light suit for both: the Psi-Tech's
-- "suit of light M.D.C. body armor" with one special feature of the player's
-- choice (printed 77), and the Zenith Moon Warper's "personalized, light
-- mega-damage body armor" (printed 141).
--
-- WHY NOT THE FIX'S OWN GUARD. It requires all four options to be rows in
-- `gear`. merge-rifts-armor-duplicates.sql has since retired
-- plastic-man-body-armor and urban-warrior-body-armor into catalog_redirects,
-- so that count is 2 in both environments and a copy of the guard would be a
-- silent no-op. The option text stays as the fix wrote it: 37 live classes
-- carry those two slugs in their choice lists and they resolve through the
-- redirects. The guard below counts an option as present when it is a gear row
-- or a redirect to one. Re-inserting the retired suits is not an option;
-- regression requires them absent.
--
-- sailor and oracle-cat also cite the row, each with its own label or note,
-- and F115 leaves them alone unless Nate says otherwise.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "light-mdc-body-armor", qty: 1 }',
         '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
       updated_at = datetime('now')
 WHERE class_id IN ('psi-tech', 'zenith-moon-warper')
   AND instr(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }') > 0
   AND (SELECT count(*) FROM gear
         WHERE slug IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor'))
     + (SELECT count(*) FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
         WHERE r.catalog = 'gear'
           AND r.from_key IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor')) = 4;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'every option resolves' AS assertion,
       (SELECT count(*) FROM gear
         WHERE slug IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor'))
     + (SELECT count(*) FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
         WHERE r.catalog = 'gear'
           AND r.from_key IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor')) AS got,
       4 AS want;

SELECT 'both classes hold the choice' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('psi-tech', 'zenith-moon-warper')
   AND instr(markdown, 'label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor"') > 0
   AND instr(markdown, 'item_id: "light-mdc-body-armor"') = 0;

SELECT 'sailor and oracle-cat are untouched' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('sailor', 'oracle-cat')
   AND instr(markdown, 'item_id: "light-mdc-body-armor"') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~043-f115-light-armor-choice.sql');
