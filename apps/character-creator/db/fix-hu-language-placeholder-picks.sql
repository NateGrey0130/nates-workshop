-- Repair the two Special Training classes that GRANTED the language
-- placeholder rows instead of offering them.
--
-- One-off data script, run once per environment. NOT a migration. It corrects
-- `add-hu-ancient-master-class.sql` and `add-hu-super-sleuth-class.sql`, which
-- are one-shot and already applied, so they are not edited - that is the
-- standard shape here.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-hu-language-placeholder-picks.sql
--
-- TWO RULES, BOTH FROM `regression.mjs`, AND BOTH RIGHT:
--
--   A class may never GRANT `Literacy: Other`. It is a PLACEHOLDER the player
--   names when the pick is made, so granting it leaves the character holding a
--   skill called, literally, "Literacy: Other" - a pick nobody offered.
--   BOOK-INGEST-AUDIT F34.
--
--   A language must never be FIXED with `base`. The row resolves off
--   `Language: Other`'s own 50% +5% per level, and a base FREEZES it flat for
--   fifteen levels. The Cyber-Doc read a printed "+20%" as `base: 20,
--   per_level: 0` and produced a language stuck at 20%, which is what that
--   check was written for.
--
-- So the book's percentage is stored as the DIFFERENCE from the row's own base:
-- 50 for a language, 30 for a literacy. The Ancient Master's 98% is +48 and +68;
-- the Super Sleuth's 96% is +46 and +66.
--
-- THE CLASSES WERE APPLIED BEFORE THE SUITE RAN ON THEM, which is how both
-- reached production: `class-check` reported them ready with no errors and no
-- warnings, because neither rule lives there - both are `regression.mjs`
-- sweeps over every published class. Running the suite before the apply is the
-- cheaper order and it is the one the skill asks for.
--
-- Each UPDATE is guarded on the text it replaces, so re-running is a no-op and
-- a row edited by hand since is left alone. Keyed on `class_id`, which is a
-- stable slug.

UPDATE imported_classes
   SET markdown = replace(markdown, '    - { name: "Language: Other", base: 98, note: "One additional language, read, write and speak, at 98%. Make one of them English and be easy on yourself." }', '    - { choose: 1, from: ["Language: Other"], bonus: 48, note: "Printed 153: read, write and speak ONE additional language at 98%, which is +48 on the row''s own 50%. Be easy on yourself and make one of them English." }')
 WHERE class_id = 'hu-ancient-master' AND instr(markdown, '    - { name: "Language: Other", base: 98, note: "One additional language, read, write and speak, at 98%. Make one of them English and be easy on yourself." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '    - { name: "Literacy: Other", base: 98, note: "The written half of that additional language." }', '    - { choose: 1, from: ["Literacy: Other"], bonus: 68, note: "Literacy: Other, the written half of that additional language - +68 on its own 30%, for the 98% printed 153 gives." }')
 WHERE class_id = 'hu-ancient-master' AND instr(markdown, '    - { name: "Literacy: Other", base: 98, note: "The written half of that additional language." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '    - { name: "Language: Other", base: 96, note: "Two additional languages, read, write and speak, at 96%. The catalog holds one `Other` row, so the second is the player''s to name." }', '    - { choose: 2, from: ["Language: Other"], bonus: 46, note: "Printed 161: read, write and speak TWO additional languages at 96%, which is +46 on the row''s own 50%." }')
 WHERE class_id = 'hu-super-sleuth' AND instr(markdown, '    - { name: "Language: Other", base: 96, note: "Two additional languages, read, write and speak, at 96%. The catalog holds one `Other` row, so the second is the player''s to name." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '    - { name: "Literacy: Other", base: 96, note: "The written half of those languages." }', '    - { choose: 2, from: ["Literacy: Other"], bonus: 66, note: "Literacy: Other twice over, the written half of those two languages - +66 on its own 30%, for the 96% printed 161 gives." }')
 WHERE class_id = 'hu-super-sleuth' AND instr(markdown, '    - { name: "Literacy: Other", base: 96, note: "The written half of those languages." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'TWO ADDITIONAL LANGUAGES ARE ONE ROW. The catalog holds `Language: Other` and `Literacy: Other` as single rows that a character names when he takes them, so a second pair cannot be granted twice without naming the specific language the book does not name. One is granted and the note says there are two.', 'THE TWO ADDITIONAL LANGUAGES ARE A PICK, NOT A GRANT. `Language: Other` and `Literacy: Other` are PLACEHOLDER rows a character names when he takes them, and granting one outright leaves him holding a skill called, literally, `Literacy: Other` - BOOK-INGEST-AUDIT F34. A fixed `Language: Other` is legitimate only where the book NAMES the tongue; this one does not. THE PERCENTAGE IS A `bonus`, NEVER A `base`: the row resolves off its own 50% +5%/level and a base would FREEZE it there for fifteen levels, so the book''s 96% is stored as +46.')
 WHERE class_id = 'hu-super-sleuth' AND instr(markdown, 'TWO ADDITIONAL LANGUAGES ARE ONE ROW. The catalog holds `Language: Other` and `Literacy: Other` as single rows that a character names when he takes them, so a second pair cannot be granted twice without naming the specific language the book does not name. One is granted and the note says there are two.') > 0;

-- ASSERTIONS.

SELECT 'neither class grants a placeholder row any more' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-ancient-master', 'hu-super-sleuth')
   AND (instr(markdown, '{ name: "Language: Other"') > 0
        OR instr(markdown, '{ name: "Literacy: Other"') > 0);

SELECT 'both now OFFER them instead' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-ancient-master', 'hu-super-sleuth')
   AND instr(markdown, 'from: ["Language: Other"]') > 0
   AND instr(markdown, 'from: ["Literacy: Other"]') > 0;

-- A bonus, never a base: the four figures, by name.
SELECT 'the Ancient Master carries +48 and +68' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-ancient-master'
   AND instr(markdown, 'bonus: 48') > 0 AND instr(markdown, 'bonus: 68') > 0;

SELECT 'the Super Sleuth carries +46 and +66' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'hu-super-sleuth'
   AND instr(markdown, 'bonus: 46') > 0 AND instr(markdown, 'bonus: 66') > 0;

SELECT 'and no base survives on either language line' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-ancient-master', 'hu-super-sleuth')
   AND (instr(markdown, '"Language: Other"], base:') > 0
        OR instr(markdown, '"Literacy: Other"], base:') > 0);

SELECT 'the Super Sleuth note no longer claims one row was granted' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'hu-super-sleuth'
   AND instr(markdown, 'One is granted and the note says there are two') > 0;

INSERT INTO data_script_runs (filename) VALUES ('fix-hu-language-placeholder-picks.sql');
