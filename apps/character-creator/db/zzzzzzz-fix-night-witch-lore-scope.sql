-- The Night Witch's two Lore picks were offering all 87 Technical skills.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzz-fix-night-witch-lore-scope.sql
--
-- Mystic Russia printed 116 gives the Night Witch "Lore: two of choice", and
-- the class named the four it means. It wrote them on the choice GROUP:
--
--   { choose: 2, categories: ["Technical"], only: ["Lore: ..."], bonus: 10 }
--
-- `categoryAllows` reads only/except/only_prefix/except_prefix off the CATEGORY
-- ENTRY matching the skill's own category, and returns true outright for a bare
-- string entry. So the `only` was stored and never read, and the group offered
-- every Technical row. Measured against production 2026-09-14 by calling the
-- real `categoryAllows` over all 388 skills:
--
--   as written    87 skills
--   as intended    4 skills - the four lores the book names
--
-- It fails OPEN, which is why nothing ever said so: a player just sees a longer
-- list. `class-check` has no rule here and reports the class ready, because
-- every NAME is real - the names were never the problem, their scope was.
--
-- FOUND BY A SWEEP, not by a check. `BOOK-INGEST-AUDIT` F84 proposes refusing
-- the group-level form outright and says to sweep before landing the rule; this
-- is that sweep's only hit, out of 803 choice groups across 318 published
-- classes. Fixed here so the rule, when taken, lands on a clean tree.
--
-- Keyed on `class_id` and guarded on the exact text it replaces, so re-running
-- is a no-op.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '{ choose: 2, categories: ["Technical"], only: ["Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 10, note: "Lore: two of choice (+10%)" }',
         '{ choose: 2, categories: [{ name: "Technical", only: ["Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"] }], bonus: 10, note: "Lore: two of choice (+10%). Printed 116. The four names are on the CATEGORY and not on the group: written beside categories they are stored and never read, and this offered all 87 Technical skills - BOOK-INGEST-AUDIT.md F84." }')
 WHERE class_id = 'night-witch'
   AND instr(markdown, '"Technical"], only: ["Lore: Demons & Monsters"') > 0;

-- ASSERTIONS.

SELECT 'the Night Witch scopes its lore to the category' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'night-witch'
   AND instr(markdown, '{ name: "Technical", only: ["Lore: Demons & Monsters"') > 0;

SELECT 'and no longer carries the group-level form' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'night-witch'
   AND instr(markdown, '"Technical"], only: ["Lore: Demons & Monsters"') > 0;

SELECT 'all four lores survive the rewrite' AS assertion, count(*) AS got, 4 AS want
  FROM (SELECT 1 FROM imported_classes WHERE class_id = 'night-witch' AND instr(markdown, '"Lore: Demons & Monsters"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'night-witch' AND instr(markdown, '"Lore: Faeries & Creatures of Magic"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'night-witch' AND instr(markdown, '"Lore: Magic"') > 0
        UNION ALL SELECT 1 FROM imported_classes WHERE class_id = 'night-witch' AND instr(markdown, '"Lore: Religion"') > 0);

-- The +10% and the pick of two are the book's and must not have moved.
SELECT 'it still picks two at +10%' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'night-witch'
   AND instr(markdown, '{ choose: 2, categories: [{ name: "Technical"') > 0
   AND instr(markdown, 'bonus: 10, note: "Lore: two of choice (+10%)') > 0;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-fix-night-witch-lore-scope.sql');
