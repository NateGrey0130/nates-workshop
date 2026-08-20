-- Retire the stub gear rows nothing references.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/retire-orphan-gear-stubs.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/retire-orphan-gear-stubs.sql
--
-- A class import creates a stub catalog row for every equipment id it cannot
-- find, so the catalog accumulates a row per name any class ever mentioned. When
-- a class is later corrected - fix-juicer-rue-edition.sql rewrote the Juicer's
-- whole equipment list, and it is not the only one - the ids it used to name are
-- orphaned. They keep sitting in the catalog with no stats and no referent, and
-- they show up in the sheet's "add item" picker, where they are indistinguishable
-- from real kit until you add one and it has nothing in it.
--
-- 33 such rows were found in production. Two shapes, and both belong here:
--
--   CATEGORIES the importer emitted as ids before choice groups existed -
--   'car', 'sword', 'staff', 'rifle', 'non-energy-weapon', 'set-of-clothing'.
--   No book entry will ever match these. Same bug as the Juicer's
--   'energy-pistol' and the Shifter's 'energy-rifle'; these differ only in that
--   no live class still cites them, so there is nothing to rewrite first.
--
--   REAL PRODUCTS whose citing class was rewritten away - 'c-10-laser-rifle',
--   'huntsman-armor', 'tw-wing-board'. Deleting an EMPTY stub of a real item
--   costs nothing: the row holds a name and a source book and no stats at all,
--   and the gear importer recreates it properly from the book if a class ever
--   needs it again. What would cost something is deleting a FILLED row, which
--   the description guard below cannot match.
--
-- EVERY DELETE IS TRIPLE-GUARDED, and each guard is a way this could go wrong:
--
--   - no class markdown names the slug, INCLUDING RETIRED CLASSES. A retired
--     class still resolves for a character mid-play - that is the whole point of
--     the soft delete - so its equipment ids are live references.
--   - no character_items row points at it, held or removed. A removal is soft so
--     the history survives, and that history should keep resolving.
--   - no catalog_redirects row targets it. A merge repointed something here, and
--     deleting the target breaks the forwarding pointer that redirect exists to
--     provide.
--   - and the description still opens with the import's STUB marker, so a row
--     somebody has since filled in by hand is left alone.
--
-- All four were verified zero for all 33 before this file was generated. The
-- guards are here because that was a snapshot: a class import between then and
-- the run can cite one of these again, and then it must not be deleted.
--
-- Safe to run twice - a second pass matches nothing.

DELETE FROM gear
WHERE slug IN (
  'ammo-clips-extra',
  'automatic-pistol',
  'automatic-pistol-or-submachinegun',
  'bio-comp-and-bio-data-implants',
  'bio-data-implants',
  'blunt-weapon',
  'c-10-laser-rifle',
  'c-12-laser-rifle',
  'car',
  'chain-weapon',
  'drug-harness-and-supply',
  'drug-supply',
  'grey-fatigues-extra-set',
  'hover-vehicle',
  'hovercycle',
  'huntsman-armor',
  'jet-pack',
  'juicer-harness',
  'juicer-lightweight-flex-plate-armor',
  'motorcycle',
  'non-energy-weapon',
  'rifle',
  'robot-horse',
  'set-of-clothing',
  'spear',
  'staff',
  'sword',
  'techno-wizard-vehicle',
  'triax-pump-weapon',
  'tw-tree-trimmer',
  'tw-wing-board',
  'urban-warrior-armor',
  'wooden-stakes-and-mallet'
)
  AND description LIKE 'STUB%'
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
  AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.item_id = gear.id)
  AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                  WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- Reports what is left, so the result is read rather than assumed. Over --remote
-- a --file run returns aggregate counts only and these do NOT surface; re-run
-- this SELECT with --command to see it.
--   orphans_left      0 = every row this file targets is gone
--   stub_rows_left        the gear importer's remaining backlog, all of it cited
--   gear_total            catalog size after the cleanup
SELECT (SELECT count(*) FROM gear WHERE slug IN (
        'ammo-clips-extra',
        'automatic-pistol',
        'automatic-pistol-or-submachinegun',
        'bio-comp-and-bio-data-implants',
        'bio-data-implants',
        'blunt-weapon',
        'c-10-laser-rifle',
        'c-12-laser-rifle',
        'car',
        'chain-weapon',
        'drug-harness-and-supply',
        'drug-supply',
        'grey-fatigues-extra-set',
        'hover-vehicle',
        'hovercycle',
        'huntsman-armor',
        'jet-pack',
        'juicer-harness',
        'juicer-lightweight-flex-plate-armor',
        'motorcycle',
        'non-energy-weapon',
        'rifle',
        'robot-horse',
        'set-of-clothing',
        'spear',
        'staff',
        'sword',
        'techno-wizard-vehicle',
        'triax-pump-weapon',
        'tw-tree-trimmer',
        'tw-wing-board',
        'urban-warrior-armor',
        'wooden-stakes-and-mallet'
        )) AS orphans_left,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stub_rows_left,
       (SELECT count(*) FROM gear) AS gear_total;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('retire-orphan-gear-stubs.sql');
