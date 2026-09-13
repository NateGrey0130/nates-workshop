-- The Night Witch's "two other languages of choice" offered a CATEGORY.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-night-witch-language-pick.sql
--
-- WHY THIS FILE EXISTS. The class was applied `--remote` with the language pick
-- written as `{ choose: 2, categories: ["Technical"], only: ["Language: Other"] }`
-- and CI then refused the merge. `regression.mjs` holds a convention this
-- catalog enforces across every class: a LANGUAGE pick is offered as
-- `from: ["Language: Other"]`, never as a category. Two of its checks fire on
-- it - "no class offers a CATEGORY for a language pick" and "and every one of
-- them offers the repeatable language row" - because a category pick hands the
-- player the whole Technical list, and the repeatable row is the thing that
-- makes "two more languages" mean what the book means.
--
-- The sibling `add-night-witch-class.sql` now carries the corrected form, so a
-- database built from scratch is already right and THIS FILE IS A NO-OP THERE.
-- Production is the one environment that saw the wrong version. Without this
-- the two would differ silently, which is the drift this repo keeps paying for.
--
-- Guarded on the exact text it replaces, so re-running changes nothing, and it
-- sorts after `add-night-witch-class.sql` (a < f) so a rebuild applies the
-- class first and this second.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '{ choose: 2, categories: ["Technical"], only: ["Language: Other"], bonus: 20, note: "Two other languages of choice (+20%)" }',
         '{ choose: 2, from: ["Language: Other"], bonus: 20, note: "Two other languages of choice (+20%)" }'),
       updated_at = datetime('now')
 WHERE class_id = 'night-witch'
   AND instr(markdown, '{ choose: 2, categories: ["Technical"], only: ["Language: Other"]') > 0;

-- Read the result back. Both hold in every environment, including one where the
-- wrong version never existed.
SELECT 'the language pick offers the repeatable row' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'night-witch'
   AND instr(markdown, 'choose: 2, from: ["Language: Other"], bonus: 20') > 0;

SELECT 'and no longer offers a category' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'night-witch'
   AND instr(markdown, 'categories: ["Technical"], only: ["Language: Other"]') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-night-witch-language-pick.sql');
