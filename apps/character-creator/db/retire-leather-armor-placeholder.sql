-- The Long Bowman starts in studded leather, not an unnamed "Leather Armor".
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/retire-leather-armor-placeholder.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/retire-leather-armor-placeholder.sql
--
-- THE FILENAME IS LOAD BEARING. A clean rebuild applies this directory as one
-- sorted glob, and this file has to land after two others:
--
--   fix-long-bowman.sql                     rewrites the class's WHOLE
--                                           markdown, and its replacement
--                                           still says leather-armor
--   fix-pf-armor-and-cross-system-gear.sql  creates the studded-leather row
--
-- The obvious name, fix-long-bowman-armor.sql, sorts BEFORE fix-long-bowman.sql
-- - '-' is 0x2D and '.' is 0x2E - so the swap landed and was overwritten
-- wholesale a few files later. Nothing failed while that was true: the apply
-- run was green and the local database was correct, because applying one file
-- by hand puts it last by definition. Only scripts/repo-vs-live.mjs caught it,
-- rebuilding from the repo and reporting 658 gear rows against the 657 the
-- same scripts produce in the right order. Renamed to sort after both.
--
-- Palladium Fantasy main book, printed p84: "Armor: Starts with a suit of
-- studded leather (A.R. 13, 38 S.D.C.)." The class was imported granting
-- `leather-armor`, a row the class importer created because that id matched
-- nothing - it has never had a cost, an A.R. or an S.D.C., and its description
-- is still "STUB - referenced by a class, needs stats".
--
-- WHY IT COULD NOT BE FIXED BEFORE NOW, and can be today: there was no studded
-- leather row to point at. add-pf-rogue-gear.sql and
-- fix-pf-armor-and-cross-system-gear.sql added `soft-leather` and
-- `studded-leather` off the printed armour table (p270), so the correct target
-- exists with real numbers - 200 gold, A.R. 13, 38 S.D.C., 20 lbs.
--
-- THE GENERIC ROW WAS NEVER A COHERENT ITEM, which is the deeper problem here.
-- The book prices four leathers and gives each its own A.R. and S.D.C. - soft
-- (A.R. 10 / 20), hard (A.R. 11 / 30), studded (A.R. 13 / 38) and padded
-- (A.R. 8 / 15). "Leather Armor" is none of them. It could not be filled in
-- because nothing said which one it meant; the only way to give the Long Bowman
-- an armour rating at all was to find out what its page actually says.
--
-- THREE STEPS, IN THIS ORDER, each guarded so the next only fires once the
-- previous one has landed.

-- ---- 1. the class ----------------------------------------------------------
-- Two substitutions in one UPDATE: the equipment id, and a restriction line
-- stating the armour, inserted ahead of the rate-of-fire penalty the class
-- already carries. char(10) rather than a literal newline so the statement
-- stays on one line, the same reason retire-orphan-gear-stubs.sql splices
-- char(34).
--
-- Guarded on the old id still being present, so a second run matches nothing
-- and a later hand-edit is never clobbered.
UPDATE imported_classes
   SET markdown = replace(
         replace(markdown,
                 '  - { item_id: "leather-armor", qty: 1 }',
                 '  - { item_id: "studded-leather", qty: 1 }'),
         '  - "Wearing a full suit of plate',
         '  - "Armour is studded leather (A.R. 13, 38 S.D.C.), stated outright on the page."'
           || char(10) || '  - "Wearing a full suit of plate')
 WHERE class_id = 'long-bowman'
   AND instr(markdown, 'item_id: ' || char(34) || 'leather-armor' || char(34)) > 0;

-- ---- 2. the one character already holding it -------------------------------
-- A character built from the wrong definition is holding the wrong item, and
-- leaving that alone would mean the fix only reaches Long Bowmen made from
-- tomorrow. One row in production: a level 1 Long Bowman, armour not equipped,
-- not removed.
--
-- Scoped to Long Bowman characters ON PURPOSE. Somebody who added "Leather
-- Armor" to a different character by hand chose that row, wrong as it is, and
-- this correction has nothing to say about their choice. The note records what
-- happened, because an item changing name underneath a player with no
-- explanation is worse than the wrong name.
UPDATE character_items
   SET item_id = (SELECT id FROM gear WHERE slug = 'studded-leather'),
       notes = COALESCE(notes || ' ', '')
         || 'Was Leather Armor, an unstatted import placeholder; corrected to studded leather (A.R. 13, 38 S.D.C.), which the Long Bowman page states.'
 WHERE item_id = (SELECT id FROM gear WHERE slug = 'leather-armor')
   AND EXISTS (SELECT 1 FROM characters c
                WHERE c.id = character_items.character_id
                  AND (c.class_id = 'long-bowman' OR c.occ_class_id = 'long-bowman'));

-- ---- 3. retire the orphan --------------------------------------------------
-- Same four guards as retire-orphan-gear-stubs.sql, and for the same reasons:
-- an empty stub nothing references is invisible clutter in the sheet's "add
-- item" picker, where it is indistinguishable from real kit until you add one
-- and find it has no stats.
--
--   - no class markdown names the slug, retired classes included. A retired
--     class still resolves for a character mid-play.
--   - no character_items row points at it, held or removed. A removal is soft
--     so the history survives, and that history should keep resolving.
--   - no catalog_redirects row targets it.
--   - the description still opens with the import's STUB marker, so a row
--     somebody has since filled in by hand is left alone.
--
-- A fifth guard this file adds: no campaign_items row either. The party stash
-- is a reference path the earlier script did not check, and a stashed item
-- whose row vanished is the same bug one step sideways. It is zero here, but
-- the guard costs nothing and the next caller of this pattern should have it.
--
-- No catalog_redirects row is created pointing leather-armor at studded
-- leather, and that is deliberate. A redirect means "this row moved", and this
-- row did not move - it was never studded leather, it was a placeholder for an
-- armour nobody had identified. Forwarding it would assert an identity the
-- book does not support.
DELETE FROM gear
 WHERE slug = 'leather-armor'
   AND description LIKE 'STUB%'
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.item_id = gear.id)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.item_id = gear.id)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- ---- read the result back rather than trusting the exit code ---------------
-- Expect 0: the class no longer cites the placeholder.
SELECT count(*) AS classes_citing_placeholder FROM imported_classes
 WHERE instr(markdown, 'item_id: ' || char(34) || 'leather-armor' || char(34)) > 0;
-- Expect 1: and cites the real row instead.
SELECT count(*) AS classes_citing_studded FROM imported_classes
 WHERE class_id = 'long-bowman'
   AND instr(markdown, 'item_id: ' || char(34) || 'studded-leather' || char(34)) > 0;
-- Expect 0: nothing is holding the placeholder any more.
SELECT count(*) AS inventory_rows_left FROM character_items ci
  JOIN gear g ON g.id = ci.item_id WHERE g.slug = 'leather-armor';
-- Expect 0: the row is gone.
SELECT count(*) AS placeholder_rows FROM gear WHERE slug = 'leather-armor';
-- What the corrected Long Bowman is now wearing.
SELECT c.id, c.name, g.slug, g.ar, g.cost FROM character_items ci
  JOIN characters c ON c.id = ci.character_id
  JOIN gear g ON g.id = ci.item_id
 WHERE g.slug = 'studded-leather' AND (c.class_id = 'long-bowman' OR c.occ_class_id = 'long-bowman');

INSERT INTO data_script_runs (filename) VALUES ('retire-leather-armor-placeholder.sql');
