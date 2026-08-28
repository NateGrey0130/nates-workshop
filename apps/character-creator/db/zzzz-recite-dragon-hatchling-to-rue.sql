-- The one class still citing the pre-RUE core book
-- (REBUILD-AUDIT.md F17, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-recite-dragon-hatchling-to-rue.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-recite-dragon-hatchling-to-rue.sql
--
-- THIS CHANGES PRODUCTION, which carries the same stale citation. It is a
-- repair to a CITATION, not to a rule: no attribute, bonus, skill or item
-- moves, only the line saying where the class was transcribed from.
--
-- WHAT WAS WRONG. `rifts-core` is the ORIGINAL Rifts core book and Rifts
-- Ultimate Edition is its errata'd revision - the same book, a later edition,
-- not a different one. Seven classes come out of the Dragon Hatchling section
-- and six of them were re-done from RUE:
--
--   dragon-hatchling-cats-eye        Rifts Ultimate Edition p.159-160
--   dragon-hatchling-flame-wind      Rifts Ultimate Edition p.160-161
--   dragon-hatchling-forest-runner   Rifts Ultimate Edition p.161-162
--   dragon-hatchling-royal-frilled   Rifts Ultimate Edition p.161-162
--   dragon-hatchling-snow-lizard     Rifts Ultimate Edition p.162-163
--   dragon-hatchling-whip-tailed     Rifts Ultimate Edition p.163
--
-- The parent was left behind on `Rifts RPG (original core book) p.98-101` -
-- the same pre-RUE residue fix-pre-rue-class-audit.sql and
-- fix-class-skill-names-to-rue.sql exist to clear. It is the ONLY row in the
-- database that cites that book, so this takes `rifts-core` to zero citers.
--
-- THREE READINGS, the method zzzz-cite-rue-rows.sql sets out, and no fewer:
--
--   1. THE TABLE OF CONTENTS. Four separate entries, on printed 5, 6 and 7,
--      all give the same page:
--        "Dragon Hatchling ... 156"
--        "Dragon Hatchlings: ... 156"
--        "The Dragon Hatchling has psionics & magic: ... 156"
--        "Dragon Hatchling R.C.C. ... 156"
--
--   2. THE BODY HEADING AGREES. Printed 156 (cache p159) opens with the
--      heading "Dragon Hatchling".
--
--   3. THE ENTRY'S OWN EXTENT. The R.C.C. material runs on through printed
--      157 and 158 - "Alignments", "R.C.C. (Racial Character Class)", "Magic
--      Knowledge" - and its tail, "Hatchling's Size", sits at the top of
--      printed 159, where "Cat's-Eye Dragon Hatchling" then begins. So the
--      generic section is printed 156-159 and SHARES 159 with the first
--      variant, which is why that variant cites 159-160.
--
-- p.156-159 is therefore four pages, exactly as the p.98-101 it replaces was.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after every fix-* and zz-* that
-- rewrites this class's markdown, in particular fix-rifts-core-dragon-hatchling.sql
-- and fix-dragon-hatchling.sql, both of which sort under `f`.
--
-- Guarded on the old string, so it is safe to re-run and a no-op anywhere the
-- citation has already been corrected.

UPDATE imported_classes
SET markdown = replace(markdown,
      'source_book: Rifts RPG (original core book) p.98-101',
      'source_book: Rifts Ultimate Edition p.156-159'),
    updated_at = datetime('now')
WHERE class_id = 'dragon-hatchling'
  AND instr(markdown, 'source_book: Rifts RPG (original core book) p.98-101') > 0;

-- Reads the result back rather than trusting the exit code.
--   classes_citing_rifts_core  0 = nothing cites the original core book any
--                              more, in any environment. It was 1.
--   hatchlings_citing_rue      7 = the parent and its six variants now agree
--                              about which edition they came from.
SELECT (SELECT count(*) FROM imported_classes
         WHERE deleted_at IS NULL
           AND instr(markdown, 'Rifts RPG (original core book)') > 0) AS classes_citing_rifts_core,
       (SELECT count(*) FROM imported_classes
         WHERE deleted_at IS NULL
           AND class_id LIKE 'dragon-hatchling%'
           AND instr(markdown, 'source_book: Rifts Ultimate Edition') > 0) AS hatchlings_citing_rue;

-- Records this run. One row per run rather than per file: the statement above
-- guards itself, so this script is safe to re-run and safe to run early, and a
-- run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-recite-dragon-hatchling-to-rue.sql');
