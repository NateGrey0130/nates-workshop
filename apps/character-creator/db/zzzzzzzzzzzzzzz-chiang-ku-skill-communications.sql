-- The Chiang-Ku Dragon's three Communications skills.
--
-- Palladium Fantasy Dragons and Gods printed 23-24 (OCR cache dag p023/p024):
-- "plus select three skills each from the categories of Communications,
-- Science, Scholar/Technical, and three ancient (and three modern) Weapon
-- Proficiencies." The class stored the Science and Technical groups and both
-- W.P. groups, and no Communications group, so the dragon was three skill picks
-- short.
--
-- The group goes in ahead of Science, in the book's order. Anchored on the
-- Science group, which nothing else rewrites - so this is independent of the
-- W.P. lines that zzzzzzzzzzzzzzz-chiang-ku-modern-wps.sql rewrites and of the
-- skills.systems tagging in zzzzzzzzzzzzzzzz-tag-skill-systems.sql, which
-- touches no class.
--
-- Keyed on class_id and guarded on the text it replaces AND on the new group
-- being absent, so a re-run is a no-op. Sorts after every file that rewrites
-- this class, the last on main being zzzzzzzzzzzzzz-hand-to-hand-prices.sql.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzz-chiang-ku-skill-communications.sql

UPDATE imported_classes
   SET markdown = replace(markdown,
         '- { choose: 3, categories: ["Science"] }',
         '- { choose: 3, categories: ["Communications"] }' || char(10) || '    - { choose: 3, categories: ["Science"] }'),
       updated_at = datetime('now')
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, '    - { choose: 3, categories: ["Science"] }') > 0
   AND instr(markdown, 'categories: ["Communications"]') = 0;

-- ASSERTIONS.

SELECT 'the Communications group is present, once' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'chiang-ku-dragon'
   AND (length(markdown) - length(replace(markdown, 'categories: ["Communications"]', '')))
       = length('categories: ["Communications"]');

SELECT 'it sits directly above the Science group' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'chiang-ku-dragon'
   AND instr(markdown, '    - { choose: 3, categories: ["Communications"] }' || char(10) || '    - { choose: 3, categories: ["Science"] }') > 0;

SELECT 'the Science group is still there, once' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'chiang-ku-dragon'
   AND (length(markdown) - length(replace(markdown, 'categories: ["Science"]', '')))
       = length('categories: ["Science"]');

SELECT 'the category exists in the catalog' AS assertion, (SELECT count(*) FROM skills WHERE category = 'Communications') > 0 AS got, 1 AS want;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzz-chiang-ku-skill-communications.sql');
