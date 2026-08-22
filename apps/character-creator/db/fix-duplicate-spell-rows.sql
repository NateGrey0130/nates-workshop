-- Four spells the catalog held twice.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-duplicate-spell-rows.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-duplicate-spell-rows.sql
--
-- HOW THEY WERE FOUND. Not by looking. The new catalog matcher REFUSED to
-- match RUE's "Summon & Control Canine" because two catalog rows claimed the
-- alias, and that refusal to guess exposed a duplicate nobody had noticed.
-- Scanning every catalog the same way - group by name with parentheticals and
-- connectives removed, then require the identifying fields to agree - found
-- three more. All four are in `spells`; skills, gear and psionic_powers are
-- clean.
--
-- EVERY PAIR IS SETTLED AGAINST A BOOK, not against which name looks nicer:
--
--   Fear                    RUE's index (printed p197) prints the name as
--                           plainly "Fear", level 2, 5 P.P.E. The stat detail
--                           in "Fear (Horror Factor: 16)" was baked into the
--                           name by the importer. The plain row keeps the name;
--                           the RUE description moves onto it first, because
--                           the seed row's description is a placeholder
--                           ("A horror-factor style effect") and the imported
--                           one is the book's.
--
--   Summon and Control      Same spell, imported once from each book. The
--   Canines                 Book of Magic row carries NO description; the RUE
--                           row does. Keep the row that has content.
--
--   Circle of Travel        The Book of Magic master index (printed p89-92)
--   Transformation          lists each of these EXACTLY ONCE, at level 15, and
--                           the word "Ritual" does not appear anywhere on those
--                           index pages. The "(Ritual)" rows are an import
--                           artifact, not a second spell: same level, same
--                           P.P.E., no description, and a P.P.E. note that says
--                           the same thing in different words.
--
-- SAFETY, checked before writing this:
--
--   * No class definition cites any of the eight names. Verified with a
--     pattern PROBED against a name known to be cited - classes list spells as
--     an inline "Name (cost), Name (cost)" run, and a first attempt that looked
--     for YAML list items returned zero for everything, which would have read
--     as "safe" for the wrong reason.
--   * No character holds any of them in its powers JSON.
--
-- MATCHED BY NAME, NEVER BY ID. Row ids differ between the local and remote
-- databases - "Fear (Horror Factor: 16)" is #37 locally and #29 in production.
-- An id in this file would delete the wrong spell in one of them.
--
-- Guarded throughout, so re-running is a no-op.

-- Fear: move the book's description onto the correctly-named row first.
UPDATE spells
   SET description = (SELECT description FROM spells WHERE name = 'Fear (Horror Factor: 16)'),
       source_book = 'Rifts Ultimate Edition'
 WHERE name = 'Fear'
   AND EXISTS (SELECT 1 FROM spells WHERE name = 'Fear (Horror Factor: 16)'
                 AND description IS NOT NULL);

DELETE FROM spells
 WHERE name = 'Fear (Horror Factor: 16)'
   AND EXISTS (SELECT 1 FROM spells WHERE name = 'Fear');

-- Canines: drop the description-less Book of Magic copy.
DELETE FROM spells
 WHERE name = 'Summon & Control Canines'
   AND (description IS NULL OR description = '')
   AND EXISTS (SELECT 1 FROM spells
                WHERE name = 'Summon and Control Canines' AND description IS NOT NULL);

-- Circle of Travel and Transformation: the index lists one of each.
DELETE FROM spells
 WHERE name = 'Circle of Travel (Ritual)'
   AND EXISTS (SELECT 1 FROM spells WHERE name = 'Circle of Travel' AND level = 15);

DELETE FROM spells
 WHERE name = 'Transformation (Ritual)'
   AND EXISTS (SELECT 1 FROM spells WHERE name = 'Transformation' AND level = 15);

-- Read the result back rather than trusting the exit code.
SELECT name, level, ppe, source_book,
       CASE WHEN description IS NULL OR description = '' THEN 'no description'
            ELSE 'has description' END AS descr
  FROM spells
 WHERE name IN ('Fear', 'Summon and Control Canines', 'Circle of Travel', 'Transformation')
 ORDER BY name;

-- All four duplicates should now be absent.
SELECT count(*) AS duplicates_remaining FROM spells
 WHERE name IN ('Fear (Horror Factor: 16)', 'Summon & Control Canines',
                'Circle of Travel (Ritual)', 'Transformation (Ritual)');

SELECT count(*) AS spells_total FROM spells;

INSERT INTO data_script_runs (filename) VALUES ('fix-duplicate-spell-rows.sql');
