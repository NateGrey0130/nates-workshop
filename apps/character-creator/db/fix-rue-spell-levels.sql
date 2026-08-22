-- Six spell levels and one P.P.E. floor, corrected against Rifts Ultimate
-- Edition.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-rue-spell-levels.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-rue-spell-levels.sql
--
-- RUE came out after the Book of Magic and overrides it, so where the two
-- disagree these are corrections rather than curiosities.
--
-- THE AUTHORITY is the spell index on printed pp.197-198, which states every
-- spell's level and P.P.E. cost in one place. Reading it correctly took three
-- attempts, and the two that failed both looked plausible:
--
--   * Read linearly, the OCR of that page emits its headings as "Level One,
--     Level Three, Level Two, Level Four" - the columns interleave. Filing
--     entries under the heading that linearly precedes them is what made every
--     level-one spell in the Book of Magic index come out as level three.
--
--   * At --psm 6 Tesseract treats the page as one uniform block and welds the
--     columns together: "Level Two  Magic Shield (6)  Distant Voice (10)" as a
--     single line.
--
--   * Bucketing word boxes into N equal-width columns assumes even spacing.
--     That page carries two-column prose above the index and a three-column
--     index below, so no single division fits both.
--
-- What works is --psm 3, Tesseract's own layout analysis, which puts each level
-- heading and its entries in their OWN BLOCK. Group by block and the emitted
-- order of the blocks stops mattering. That parse yields 148 spells across
-- levels 1-15.
--
-- EVERY ROW BELOW WAS READ TWICE: the index on pp.197-198, and the "Level N
-- (Invocations)" section its description sits under on pp.199-225. Both agree
-- in all seven cases.
--
-- All six level rows already carry source_book 'Rifts Ultimate Edition' and all
-- six are exactly ONE LEVEL TOO HIGH - the same signature as the thirteen rows
-- the Book of Magic import got wrong, and the same cause: the book's level
-- headings sit partway down a page, so the first page of an extraction batch
-- carries the tail of the previous level and those rows get stamped with the
-- new batch's number. The index is the authority; the page position is not.
--
-- Guarded on the old value, so a row already corrected is left alone and
-- re-running is a no-op.

UPDATE spells SET level = 6 WHERE name = 'Teleport: Lesser'   AND level = 7;
UPDATE spells SET level = 6 WHERE name = 'Tongues'            AND level = 7;
UPDATE spells SET level = 6 WHERE name = 'Words of Truth'     AND level = 7;
UPDATE spells SET level = 8 WHERE name = 'Sickness'           AND level = 9;
UPDATE spells SET level = 8 WHERE name = 'Spoil'              AND level = 9;
UPDATE spells SET level = 8 WHERE name = 'Wisps of Confusion' AND level = 9;

-- "P.P.E.: Varies; two P.P.E. per five pounds (2.3 kg)." (printed p201), and
-- the index prints the cost as "2+". The stored 0 reads as FREE at the table
-- and also matches the stub heuristic. ppe holds the minimum the sheet spends
-- and ppe_note already carries the schedule - the same split the column was
-- added for.
UPDATE spells SET ppe = 2 WHERE name = 'Manipulate Objects' AND ppe = 0;

-- Nothing is added here. The index lists five spells the catalog appeared to
-- lack, and all five are the same spell under a different spelling - the diff
-- manufactured them by comparing raw names:
--
--   Swim as a Fish          = Swim as a Fish (lesser)
--   Animate/Control Dead    = Animate and Control Dead
--   Power Weapons           = Power Weapon
--   Summon & Control Canine = Summon and Control Canines
--   Control/Enslave Entity  = Control & Enslave Entity
--
-- Left as they are. Renaming them to RUE's spelling would break every class
-- definition that cites the current name, and a citation is matched in the
-- browser where catalog_redirects are not sent.

-- Read the result back rather than trusting the exit code.
SELECT name, level, ppe FROM spells
 WHERE name IN ('Teleport: Lesser', 'Tongues', 'Words of Truth', 'Sickness',
                'Spoil', 'Wisps of Confusion', 'Manipulate Objects')
 ORDER BY name;
SELECT count(*) AS spells_total FROM spells;
SELECT count(*) AS still_zero_ppe FROM spells WHERE ppe = 0 AND ppe_note IS NOT NULL;

INSERT INTO data_script_runs (filename) VALUES ('fix-rue-spell-levels.sql');
