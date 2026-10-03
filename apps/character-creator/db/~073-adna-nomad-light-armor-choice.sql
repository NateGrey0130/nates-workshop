-- The Adna Nomad gets the light body armour choice that
-- fix-category-gear-rows.sql gives every other class - the BOOK-INGEST-AUDIT
-- F115 correction, for a class imported after it.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~073-adna-nomad-light-armor-choice.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~073-adna-nomad-light-armor-choice.sql
--
-- add-adna-nomad-class.sql (Rifts World Book 30: D-Bees of North America,
-- shipped 2026-10-03) names `item_id: "light-mdc-body-armor"`, the category row
-- fix-category-gear-rows.sql turns into a choice of real suits. On a clean
-- build that fix sorts after the add script and makes the change, so the repo
-- rebuilds the choice; production ran the fix on 2026-08-20, before the class
-- existed, and kept the placeholder. repo-vs-live.mjs --offenders reported
-- exactly this one field on 2026-10-03, after PR #1651 merged.
--
-- The book agrees with the choice: printed 12 gives the Adna a generic suit
-- of light M.D.C. body armour (35 M.D.C.), not a named one.
--
-- The statement and its guard are ~043-f115-light-armor-choice.sql's, for
-- this one class: an option counts as present when it is a gear row or a
-- redirect to one, because two of the four suits are retired into
-- catalog_redirects. THIS SCRIPT CHANGES PRODUCTION: one row, and on a clean
-- build it finds nothing to replace. The tilde number is claimed at merge.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "light-mdc-body-armor", qty: 1 }',
         '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }'),
       updated_at = datetime('now')
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, '  - { item_id: "light-mdc-body-armor", qty: 1 }') > 0
   AND (SELECT count(*) FROM gear
         WHERE slug IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor'))
     + (SELECT count(*) FROM catalog_redirects r JOIN gear g ON g.id = r.to_id
         WHERE r.catalog = 'gear'
           AND r.from_key IN ('dog-pack-dpm-riot-armor', 'plastic-man-body-armor', 'ca-2-light-dead-boy-armor', 'urban-warrior-body-armor')) = 4;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Adna Nomad holds the light armour choice' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, 'label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor"') > 0
   AND instr(markdown, 'item_id: "light-mdc-body-armor"') = 0;

INSERT INTO data_script_runs (filename) VALUES ('~073-adna-nomad-light-armor-choice.sql');
