-- Clear six `same_spell_as` links that should never have been written.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzz-mr-living-fire-unlink-samename.sql
--
-- WHY THIS FILE EXISTS, stated plainly. The Living Fire batch was first written
-- with 14 candidate links chosen BY NAME, applied `--remote`, and only then
-- refused by CI: `regression.mjs` runs `scripts/same-spell-lib.mjs` over every
-- link on a clean rebuild, and that library - which this repo already shipped
-- for exactly this judgement, BOOK-INGEST-AUDIT F26 - rejects six of them.
-- The sibling script now inserts only the seven that survive, so a database
-- built from scratch is already correct and this file is a NO-OP there.
-- Production is the one environment that saw the wrong six, and this brings it
-- back into agreement with a clean rebuild rather than leaving the two to
-- differ silently.
--
-- The six are not retellings. They share a NAME with an established row and
-- disagree with it on mechanics, which is the same split the library's own
-- header records among the Ocean/Water pairs:
--
--   Cloud of Smoke       duration 1 vs 4
--   Extinguish Fire      range 20,80 vs 10,20,80
--   Impervious to Fire   protects SELF OR ONE OTHER at 60 feet; the
--                        established row protects self only
--   Fire Ball            90 feet PLUS 20 per level for Fire Sorcerers; the
--                        established row is a flat 90
--   Ballistic Fire       range 10,1000 vs 0,1,10, and no saving throw
--   Fire Gout            no saving throw here, 3 on the established row
--
-- Guarded by the tradition and by the names, so it can only touch rows this
-- book's Living Fire batch created, and re-running it changes nothing.

UPDATE spells
   SET same_spell_as = NULL
 WHERE tradition = 'living-fire'
   AND same_spell_as IS NOT NULL
   AND name IN ('Living Fire: Cloud of Smoke',
                'Living Fire: Extinguish Fire',
                'Living Fire: Impervious to Fire',
                'Living Fire: Fire Ball',
                'Living Fire: Ballistic Fire',
                'Living Fire: Fire Gout');

-- Read the result back. Both numbers are what a clean rebuild produces, so
-- these assertions hold in every environment rather than only in the one that
-- needed repairing.
SELECT 'the six same-named rows carry no link' AS assertion, count(*) AS got, 0 AS want
  FROM spells
 WHERE tradition = 'living-fire'
   AND same_spell_as IS NOT NULL
   AND name IN ('Living Fire: Cloud of Smoke',
                'Living Fire: Extinguish Fire',
                'Living Fire: Impervious to Fire',
                'Living Fire: Fire Ball',
                'Living Fire: Ballistic Fire',
                'Living Fire: Fire Gout');

SELECT 'and the seven real retellings are still linked' AS assertion, count(*) AS got, 7 AS want
  FROM spells WHERE tradition = 'living-fire' AND same_spell_as IS NOT NULL;

SELECT 'no Living Fire row was lost' AS assertion, count(*) AS got, 39 AS want
  FROM spells WHERE tradition = 'living-fire';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzz-mr-living-fire-unlink-samename.sql');
