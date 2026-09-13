-- The Gifted One named a psionic category the catalog does not have.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-gifted-one-psionic-category-name.sql
--
-- WHY THIS FILE EXISTS. The class was applied `--remote` with
-- `categories_allowed: ["Super Psionic"]` and `categories: ["Super Psionic"]`
-- on its psionic schedules. The catalog's category is plainly `Super` -
-- SELECT DISTINCT category FROM psionic_powers gives Healing, Phase, Physical,
-- Sensitive, Super - and regression refused the merge by name:
-- "every categories_allowed entry names a category the catalog has".
--
-- WHAT IS WORTH KEEPING HERE IS WHICH CHECK CAUGHT IT. `class-check --remote`
-- passed this class clean, because it verifies the psionic POWERS a class
-- names and not the CATEGORIES. A category that resolves to nothing offers the
-- player an empty pool, with no error anywhere. Only regression's sweep over
-- every categories_allowed entry in the catalog sees it.
--
-- The book's own wording is "Super Psionic", which is why it was written that
-- way; the catalog shortens it to `Super`.
--
-- The sibling `add-gifted-one-russian-class.sql` now carries `Super`, so a
-- database built from scratch is already correct and THIS FILE IS A NO-OP
-- there. Production is the one environment that saw the wrong version.

UPDATE imported_classes
   SET markdown = replace(markdown, '"Super Psionic"]', '"Super"]'),
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, '"Super Psionic"]') > 0;

-- Read the result back. Both hold in every environment.
SELECT 'no psionic category resolves to nothing' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'gifted-one-russian' AND instr(markdown, '"Super Psionic"]') > 0;

SELECT 'and the Super category is named correctly' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'gifted-one-russian' AND instr(markdown, 'categories_allowed: ["Super"]') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-gifted-one-psionic-category-name.sql');
