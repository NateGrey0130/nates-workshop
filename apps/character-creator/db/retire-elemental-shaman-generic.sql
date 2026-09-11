-- BOOK-INGEST-AUDIT F63: retire the one-class `elemental-shaman`.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/retire-elemental-shaman-generic.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/retire-elemental-shaman-generic.sql
--
-- The four add-elemental-shaman-<element>-class.sql files replace it, one per
-- element. This file sorts AFTER all of them ('r' > 'a'), so a clean rebuild
-- adds the four and then retires the one, in that order - the shape
-- retire-warlock-generic.sql set for RETRO-AUDIT R3.
--
-- WHY RETIRE RATHER THAN NARROW IT. The one class offers a first-level Elemental
-- Shaman all 37 elemental spells for three picks, and keeps the element's 98%
-- skill in ability text where no skill list sees it. Leaving it published keeps
-- that under a name a player would reasonably pick.
--
-- SOFT delete, not a DELETE: composeClass still resolves a retired class, so an
-- existing character is not orphaned. Production held ZERO elemental-shaman
-- characters on 2026-09-11, checked before this ran, and the readback below
-- asks again. add-elemental-shaman-class.sql and its CORE_SDC_BY_CLASS entry
-- stay, as the generic Warlock's did.

UPDATE imported_classes
   SET deleted_at = datetime('now')
 WHERE class_id = 'elemental-shaman' AND deleted_at IS NULL;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the one-class elemental shaman is retired' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'elemental-shaman' AND deleted_at IS NOT NULL;

SELECT 'four per-element elemental shamans are live' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE class_id IN ('elemental-shaman-air', 'elemental-shaman-earth', 'elemental-shaman-fire', 'elemental-shaman-water')
   AND status = 'published' AND deleted_at IS NULL;

-- No character is orphaned by this, checked rather than assumed.
SELECT 'no character holds the one-class elemental shaman' AS assertion, count(*) AS got, 0 AS want
  FROM characters WHERE occ_class_id = 'elemental-shaman' OR class_id = 'elemental-shaman';

INSERT INTO data_script_runs (filename) VALUES ('retire-elemental-shaman-generic.sql');
