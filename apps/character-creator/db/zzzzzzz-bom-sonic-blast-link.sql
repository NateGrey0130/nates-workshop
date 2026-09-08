-- Sonic Blast is in the Book of Magic TWICE, and both rows are right.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzz-bom-sonic-blast-link.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzz-bom-sonic-blast-link.sql
--
-- BOOK-INGEST-AUDIT.md F29, which was filed as a suspected DUPLICATE and turns
-- out not to be one. Both pages were read before anything was changed:
--
--   printed 63  under "Level Five: Air"          P.P.E.: Fifteen
--   printed 119 under "Level Seven (Invocations)" P.P.E.: Twenty-Five
--
-- The two entries are word for word identical apart from that one line - same
-- 20 foot radius, same 4D6 M.D., same Instant duration, same Standard save,
-- same deafening penalties and the same 01-40% knockdown. The Book of Magic
-- publishes one spell in two lists: as a fifth level AIR ELEMENTAL spell for
-- fifteen P.P.E., and as a seventh level general INVOCATION for twenty-five.
--
-- SO THERE IS NOTHING TO CORRECT AND NOTHING TO MERGE. `Air: Sonic Blast`
-- holds level 5 and 15 P.P.E. and `Sonic Blast` holds level 7 and 25, and both
-- agree with the page they cite. A merge would have deleted a row that is
-- correct and changed what one of two kinds of caster spends. The suspicion
-- that "one of the two pages is being read wrong" was wrong.
--
-- WHAT IT IS instead is F26's own shape - one spell, two traditions, two costs
-- - occurring INSIDE a single book rather than across two. That is what
-- `same_spell_as` is for, so the pair gets a link and the duplication becomes
-- pinned rather than merely true: `regression.mjs` now compares the two rows to
-- each other on every clean rebuild, and either one being gutted or edited away
-- from the other is reported.
--
-- DIRECTION follows migration 049's rule as closely as a within-book pair can.
-- There is no "newer import" here - both rows arrived together - so the
-- tradition-scoped row points at the general one: the Invocation list is the
-- baseline every wizard reads and the Air list is one tradition's version of it.
--
-- WHY SEVEN Z'S. `zzzzzz-underseas-same-spell-links.sql` asserts that SIX rows
-- in the whole catalog carry a link - a global count, which is the right
-- assertion for it and which this file would break by adding a seventh if it
-- ran first. Six z's puts `bom` before `underseas` alphabetically, so a clean
-- rebuild would run this one first and fail that script. Checked with the
-- sorted-glob command rather than reasoned from the prefix convention. Pure
-- ASCII, LF endings.

UPDATE spells
   SET same_spell_as = 'Sonic Blast'
 WHERE name = 'Air: Sonic Blast'
   AND same_spell_as IS NULL
   AND EXISTS (SELECT 1 FROM spells t WHERE t.name = 'Sonic Blast');

-- Read the result back rather than trusting the exit code.
SELECT 'the air version points at the invocation' AS assertion,
       count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Air: Sonic Blast' AND same_spell_as = 'Sonic Blast';

SELECT 'both rows still exist - nothing was merged away' AS assertion,
       count(*) AS got, 2 AS want
  FROM spells WHERE name IN ('Air: Sonic Blast', 'Sonic Blast');

-- The two prices are the POINT of the pair, not a defect in it.
SELECT 'and they still disagree on level and cost, as the book does' AS assertion,
       count(*) AS got, 1 AS want
  FROM spells a JOIN spells b ON b.name = a.same_spell_as
 WHERE a.name = 'Air: Sonic Blast' AND a.level <> b.level AND a.ppe <> b.ppe;

-- The dolphin spell shares the name and is a DIFFERENT spell - 1D6 M.D. per
-- level at 100 feet per level. It must never acquire a link to either.
SELECT 'the dolphin spell is still unlinked' AS assertion,
       count(*) AS got, 0 AS want
  FROM spells WHERE name = 'Dolphin: Sonic Blast' AND same_spell_as IS NOT NULL;

SELECT count(*) AS linked_rows_total FROM spells WHERE same_spell_as IS NOT NULL;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzz-bom-sonic-blast-link.sql');
