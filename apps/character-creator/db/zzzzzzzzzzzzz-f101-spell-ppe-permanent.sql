-- BOOK-INGEST-AUDIT F101 (3 of 3): the P.P.E. six catalog spells burn out of the
-- CASTER'S BASE, written into `spells.ppe_permanent` (migration 067).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzz-f101-spell-ppe-permanent.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzz-f101-spell-ppe-permanent.sql
--
-- ===================================================================
-- THE NUMBER ONLY - NATE'S ANSWER, 2026-09-16
-- ===================================================================
--
-- Each value is what ONE occasion burns. When the occasion arises - on success,
-- only if made permanent, each full moon, doubled for a creature of magic - stays
-- in the description, which already says it. Every number below was read from
-- the production row's own description on 2026-09-16, which carries a page
-- citation, and matches the row's `ppe_note` where that states one:
--
--   Close Rift                  "permanently draining 2 P.P.E. from the caster's
--                                base whether the attempt succeeds or fails"
--   Ley Line Resurrection       "permanently drains 2D6 P.P.E. from the caster's
--                                base ... each time it succeeds"
--   Ley Line Restoration        "permanently drains 6D6 P.P.E. from the
--                                performer's base"
--   Enchant Weapon (Minor)      "a permanent loss of 2D4 P.P.E. from the caster's
--                                own base" - only if made permanent
--   Bone: Return from the Grave "every full moon ... the mage permanently
--                                sacrifices three P.P.E. and two Hit Points"
--   Nature: Sacred Oath         "2D6 Hit Points and 2D6 P.P.E. permanently" -
--                                only when repenting a broken oath
--
-- ===================================================================
-- RETURN FROM THE GRAVE CONTRADICTS ITSELF, AND THIS DOES NOT PICK A SIDE
-- ===================================================================
--
-- Its stat line, printed Mystic Russia 105 (cache p106, offset +1), reads
-- "P.P.E. Cost: Special; a total of 60 P.P.E. and 24 hit points are permanently
-- spent." Its text says three P.P.E. and two hit points each full moon for a
-- year. Twelve moons make 36 P.P.E. and 24 hit points: the hit points agree and
-- the P.P.E. does not.
--
-- NOT the digit cipher. That cache carries a substitution, but it swaps digits
-- for LETTERS (1 as ! or l, 0 as O or Q), never one digit for another, and the
-- page rendered from the PDF reads 60 in the ink, checked 2026-09-16. So the book
-- prints both. This row stores 3 - what one moon burns, which is what a per-
-- occasion burn button needs - and leaves the stated total where it already is,
-- in `ppe_note`. Recorded under F101 for Nate rather than resolved here.
--
-- ===================================================================
-- SUMMON & USE STONES & CRYSTALS IS LEFT NULL
-- ===================================================================
--
-- Its `ppe_note` gives FOUR burns by what is summoned - a crystal ball 2D6, a
-- control crystal 1D6, special stones 1D4, a lesser stone or crystal one point -
-- and one expression cannot hold four. Choosing one would burn the wrong amount
-- for the other three, so it stays prose, which is what it was.

UPDATE spells SET ppe_permanent = '2'   WHERE name = 'Close Rift';
UPDATE spells SET ppe_permanent = '2D6' WHERE name = 'Ley Line Resurrection';
UPDATE spells SET ppe_permanent = '6D6' WHERE name = 'Ley Line Restoration';
UPDATE spells SET ppe_permanent = '2D4' WHERE name = 'Enchant Weapon (Minor)';
UPDATE spells SET ppe_permanent = '3'   WHERE name = 'Bone: Return from the Grave';
UPDATE spells SET ppe_permanent = '2D6' WHERE name = 'Nature: Sacred Oath';

-- READBACKS. `d1-apply` applies the file even when one of these fails, so they
-- are a report and not a gate - read them.

SELECT 'all six spells carry the burn their description states' AS assertion,
       count(*) AS got, 6 AS want
  FROM spells
 WHERE (name = 'Close Rift'                  AND ppe_permanent = '2')
    OR (name = 'Ley Line Resurrection'       AND ppe_permanent = '2D6')
    OR (name = 'Ley Line Restoration'        AND ppe_permanent = '6D6')
    OR (name = 'Enchant Weapon (Minor)'      AND ppe_permanent = '2D4')
    OR (name = 'Bone: Return from the Grave' AND ppe_permanent = '3')
    OR (name = 'Nature: Sacred Oath'         AND ppe_permanent = '2D6');

SELECT 'Stones & Crystals stays NULL, its four burns being prose' AS assertion,
       count(*) AS got, 1 AS want
  FROM spells
 WHERE name = 'Summon & Use Stones & Crystals' AND ppe_permanent IS NULL;

-- Nothing else was touched. Six is the number this file writes, on a database
-- where nothing wrote the column before it.
SELECT 'and no other spell burns anything' AS assertion,
       count(*) AS got, 6 AS want
  FROM spells
 WHERE ppe_permanent IS NOT NULL;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzz-f101-spell-ppe-permanent.sql');
