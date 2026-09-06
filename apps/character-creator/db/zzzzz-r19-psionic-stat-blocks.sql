-- RETRO-AUDIT R19: four psionic powers get the stat block and the citation they
-- were imported without. Plus one spell's P.P.E., found the same way.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-r19-psionic-stat-blocks.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-r19-psionic-stat-blocks.sql
--
-- THE SAME DEFECT AS THE SPELL BACKFILL, which is why it ships beside it: all
-- four were cited to Rifts Ultimate Edition printed 141, and printed 141 is a
-- LIST page - it carries them as names with an I.S.P. cost in brackets
-- ("Deaden Senses (4)", "Psychic Body Field (Super - 30; counts as two
-- selections)"), not as entries. Whoever imported them read the list, which is
-- exactly why the stat block came out empty.
--
-- The real entries are 26 to 42 pages further on. Every one of the four printed
-- I.S.P. costs agrees with the cost the list gives, which is the cross-check
-- that says these are the right entries.
--
-- KEYED ON NAME, NOT id. Ids are assigned per environment by insertion order
-- and do not match between production and a rebuilt database; the spell
-- backfill beside this one was written keyed on id first and put the right text
-- on the wrong rows locally. Power names are unique.
--
-- WHERE THE BOOK PRINTS NOTHING, NOTHING IS WRITTEN. Sense Time and Psychic
-- Body Field have no Saving Throw line at all, so theirs stays NULL rather than
-- becoming "None" - silence and an explicit "None" are different facts.
--
-- ONE OCR TRAP, CAUGHT BY RENDERING THE PAGE. Deaden Senses' duration reads
-- "216 minutes" in the text layer. The same line says "roll for random
-- determination of duration", which no fixed number needs, so the page was
-- rendered to an image and read: it prints 2D6. The D-read-as-1 scanno is the
-- same family as the "ID6"/"IDS" ones elsewhere in these books.

UPDATE psionic_powers
   SET range = '160 feet (48.8 m); line of sight.',
       duration = '2D6 minutes; roll for random determination of duration.',
       saving_throw = '-1 to save.',
       source_book = 'Rifts Ultimate Edition p.167'
 WHERE name = 'Deaden Senses' AND (range IS NULL OR range = '');

UPDATE psionic_powers
   SET range = 'Self.',
       duration = '15 minutes per level of experience.',
       source_book = 'Rifts Ultimate Edition p.177'
 WHERE name = 'Sense Time' AND (range IS NULL OR range = '');

UPDATE psionic_powers
   SET range = 'Self.',
       duration = 'Two minutes per level of experience.',
       source_book = 'Rifts Ultimate Edition p.181'
 WHERE name = 'Psychic Body Field' AND (range IS NULL OR range = '');

UPDATE psionic_powers
   SET range = 'Self; affects all who come within 100 feet (30.5 m) of the psychic.',
       duration = '5 minutes per level of experience.',
       saving_throw = '-1 to save vs Horror Factor.',
       source_book = 'Rifts Ultimate Edition p.183'
 WHERE name = 'Radiate Horror Factor' AND (range IS NULL OR range = '');

-- ---- and one spell, found while checking the pages above --------------------
-- Realm of Chaos stores ppe 0. The Book of Magic printed 130 gives
-- "P.P.E.: Seventy", read off the page. A zero-cost 9th-level spell would be
-- free to cast, which is the kind of wrong number a player notices at the table
-- rather than in a query.
UPDATE spells
   SET ppe = 70
 WHERE name = 'Realm of Chaos' AND ppe = 0;

-- ---- readbacks -------------------------------------------------------------
SELECT 'all four psionic powers have a range' AS assertion,
       count(*) AS got, 4 AS want
  FROM psionic_powers
 WHERE name IN ('Deaden Senses', 'Sense Time', 'Psychic Body Field', 'Radiate Horror Factor')
   AND range IS NOT NULL AND range <> '';

SELECT 'and none of them still points at the list page' AS assertion,
       count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE name IN ('Deaden Senses', 'Sense Time', 'Psychic Body Field', 'Radiate Horror Factor')
   AND instr(source_book, 'p.141') > 0;

-- THE OCR TRAP, ASSERTED SO A REBUILD CANNOT QUIETLY REINTRODUCE IT.
SELECT 'Deaden Senses lasts 2D6 minutes, not 216' AS assertion,
       count(*) AS got, 1 AS want
  FROM psionic_powers
 WHERE name = 'Deaden Senses' AND instr(duration, '2D6 minutes') > 0;

-- THE TWO THE BOOK IS SILENT ABOUT STAY SILENT.
SELECT 'no saving throw was invented for the two the book omits' AS assertion,
       count(*) AS got, 2 AS want
  FROM psionic_powers
 WHERE name IN ('Sense Time', 'Psychic Body Field')
   AND (saving_throw IS NULL OR saving_throw = '');

SELECT 'no psionic power is left without a range' AS assertion,
       count(*) AS got, 0 AS want
  FROM psionic_powers WHERE range IS NULL OR range = '';

SELECT 'Realm of Chaos costs seventy P.P.E.' AS assertion,
       count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Realm of Chaos' AND ppe = 70;

-- THREE SPELLS LEGITIMATELY COST NOTHING and must not be "fixed" to match.
-- Death Curse prints "P.P.E.: None/Special." (bom printed 104, read off the
-- page), and the two Wormwood level-0 entries are abilities rather than costed
-- invocations. `want 3` is measured: before this script it was four, and Realm
-- of Chaos was the only one of the four the book gives a number for.
SELECT 'only the three that genuinely cost nothing are left at zero' AS assertion,
       count(*) AS got, 3 AS want
  FROM spells WHERE ppe = 0 OR ppe IS NULL;

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-r19-psionic-stat-blocks.sql');
