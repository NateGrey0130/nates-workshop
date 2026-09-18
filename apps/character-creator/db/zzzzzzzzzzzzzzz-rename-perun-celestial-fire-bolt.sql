-- Rename "Living Fire: Rerun's Celestial Fire Bolt" to the Perun's it is printed.
--
-- Mystic Russia printed 116 heads the spell "Perun's Celestial Fire Bolt", and
-- its own description ends "the ancient God of War, Perun"; the spell after it
-- is "Living Fire: Perun's Fire Scourge". The book's TEXT LAYER reads the
-- heading as "Rerun's" (cache p117 line 57), and zzzzzzzzzz-mr-living-fire-
-- spells.sql took the name from it. Found by the read-only OCR sweep of
-- 2026-09-18 that followed the super-ability repair (#1153); read off a
-- render of the page before this was written.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzzzz-rename-perun-celestial-fire-bolt.sql
--
-- A NAME IS A KEY. Classes, characters' `powers` JSON and `character_grants`
-- cite spells by name. On production, 2026-09-18, NONE cites this one: 0
-- imported_classes, 0 characters, 0 grants, 0 drafts. The rename still leaves
-- a `catalog_redirects` row, the shape the eight earlier spell renames use, so
-- anything that ever held the old name resolves to the new one. `to_id` is
-- looked up by name, never written as a literal: ids are insertion order and
-- differ between environments.
--
-- SORTS AFTER zzzzzzzzzzzzzz-fix-spell-psionic-ocr-text.sql, which repairs
-- this row's text and damage UNDER ITS OLD NAME. Renamed first, that script's
-- guarded UPDATEs would match nothing on a rebuild.

UPDATE spells
   SET name = 'Living Fire: Perun''s Celestial Fire Bolt'
 WHERE name = 'Living Fire: Rerun''s Celestial Fire Bolt';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'spells', 'Living Fire: Rerun''s Celestial Fire Bolt', id, 'rename'
  FROM spells WHERE name = 'Living Fire: Perun''s Celestial Fire Bolt';

-- ASSERTIONS.

SELECT 'the spell carries its printed name' AS assertion, count(*) AS got, 1 AS want
  FROM spells WHERE name = 'Living Fire: Perun''s Celestial Fire Bolt';

SELECT 'and the misread name is gone' AS assertion, count(*) AS got, 0 AS want
  FROM spells WHERE name = 'Living Fire: Rerun''s Celestial Fire Bolt';

SELECT 'the old name redirects to it' AS assertion, count(*) AS got, 1 AS want
  FROM catalog_redirects cr JOIN spells s ON s.id = cr.to_id
 WHERE cr.catalog = 'spells' AND cr.from_key = 'Living Fire: Rerun''s Celestial Fire Bolt'
   AND cr.reason = 'rename' AND s.name = 'Living Fire: Perun''s Celestial Fire Bolt';

SELECT 'its mechanics are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM spells
 WHERE name = 'Living Fire: Perun''s Celestial Fire Bolt'
   AND level = 6 AND ppe = 20 AND tradition = 'living-fire' AND system = 'rifts'
   AND instr(description, 'God of War, Perun.') > 0;

SELECT 'the Living Fire tradition still holds 39 spells' AS assertion, count(*) AS got, 39 AS want
  FROM spells WHERE tradition = 'living-fire';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzz-rename-perun-celestial-fire-bolt.sql');
