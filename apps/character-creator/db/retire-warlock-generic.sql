-- RETRO-AUDIT R3: retire the generic `warlock`.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/retire-warlock-generic.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/retire-warlock-generic.sql
--
-- The ten add-warlock-*-class.sql files replace it, one per Elemental Force and
-- one per pair. This file sorts AFTER all of them ('r' > 'a'), so a clean
-- rebuild adds the ten and then retires the generic one, in that order.
--
-- WHY RETIRE RATHER THAN NARROW IT. The generic row is the one that offers a
-- first-level Warlock all 50 level-1 spells in the catalog, which is the defect
-- RETRO-AUDIT R3 recorded. Narrowing it to the 37 elemental spells would still
-- let a Fire Warlock take Air spells and would look complete - the objection
-- CLASS-AUDIT S7 raised against a half-modelled Dog Boy. Leaving it published
-- keeps the defect alive under a name a player would reasonably pick.
--
-- SOFT delete, not a DELETE: `deleted_at` is what migration 003 added for
-- exactly this, and composeClass still resolves a retired class so an existing
-- character is not orphaned. Production holds ZERO warlock characters, checked
-- before this ran, so nothing is orphaned either way.

UPDATE imported_classes
   SET deleted_at = datetime('now')
 WHERE class_id = 'warlock' AND deleted_at IS NULL;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the generic warlock is retired' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'warlock' AND deleted_at IS NOT NULL;

SELECT 'ten per-Force warlocks are live' AS assertion, count(*) AS got, 10 AS want
  FROM imported_classes
 WHERE class_id LIKE 'warlock-%' AND status = 'published' AND deleted_at IS NULL;

-- No character is orphaned by this, checked rather than assumed.
SELECT 'no character holds the generic warlock' AS assertion, count(*) AS got, 0 AS want
  FROM characters WHERE occ_class_id = 'warlock' OR class_id = 'warlock';

INSERT INTO data_script_runs (filename) VALUES ('retire-warlock-generic.sql');
