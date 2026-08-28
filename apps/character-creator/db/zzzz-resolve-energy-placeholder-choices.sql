-- The six choice groups left citing placeholder gear that no longer exists
-- (REBUILD-AUDIT.md F11, 2026-08-28).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzz-resolve-energy-placeholder-choices.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzz-resolve-energy-placeholder-choices.sql
--
-- WHAT HAPPENED, AND IT IS THE SECOND TIME. retire-gear-placeholders.sql
-- deletes the four category placeholder rows - energy-pistol, energy-rifle,
-- vibro-blade, ancient-weapon - guarded on
-- `NOT EXISTS (... instr(markdown, 'item_id: "' || slug || '"'))`. That guard
-- matches only FIXED equipment entries. Choice groups cite slugs inside
-- `from: ["..."]` lists, the guard never sees them, so the rows are deleted
-- while five published classes are still citing them that way. A wizard pick
-- of one of those options resolves to nothing.
--
-- This is EXACTLY the bug class audit F2 found in retire-orphan-gear-stubs.sql
-- - same guard shape, same blind spot. zzz-resolve-choice-group-gear.sql fixed
-- it for that script's 19 slugs and nobody checked whether the other
-- retire-* script had it too. It did.
--
-- Production does not need this: its copies of these six lines already
-- enumerate real slugs, rewritten through the catalog editor, which writes
-- straight to D1 and leaves nothing in git. That is why no check could see
-- this - every comparison the repo had ran against production, where the
-- problem does not exist. A database built from the repo cites 10 dead slugs
-- across these five classes; production cites 0. Measured 2026-08-28 with the
-- smoke test's own referencedGear() sweep against a fresh build.
--
-- THE LISTS BELOW ARE PRODUCTION'S, exported row for row rather than composed
-- here. This script's whole job is to make a rebuild agree with production,
-- so inventing a better list would defeat it. Every target slug was confirmed
-- present in a fresh build before this was written.
--
-- FILENAME SORTS LAST ON PURPOSE. It must run after retire-gear-placeholders.sql
-- (which deletes the rows), after zzz-resolve-choice-group-gear.sql (which
-- restores triax-pump-weapon, cited in the warlock list below), and after the
-- zzzz-cite-* files, which rewrite source_book on rows this depends on
-- existing. `zzzz-r` sorts after `zzzz-c`.
--
-- Every statement guards itself twice - on the placeholder text being present
-- AND on every replacement slug existing - so this is safe to re-run and safe
-- to run early: in an environment missing the option rows it waits rather
-- than swapping a dead slug for an absent one.

-- -- 1. Headhunter Techno-Warrior: energy rifle, then side arm --

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["energy-rifle"] }',
      'from: ["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"] }'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, 'from: ["energy-rifle"] }') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle', 'l-20-pulse-rifle')) = 3;

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["automatic-pistol", "energy-pistol"] }',
      'from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }'),
    updated_at = datetime('now')
WHERE class_id = 'headhunter-techno-warrior'
  AND instr(markdown, 'from: ["automatic-pistol", "energy-pistol"] }') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol',
        'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol')) = 4;

-- -- 2. Robot Pilot: the same side arm list, same replacement --

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["automatic-pistol", "energy-pistol"] }',
      'from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }'),
    updated_at = datetime('now')
WHERE class_id = 'robot-pilot'
  AND instr(markdown, 'from: ["automatic-pistol", "energy-pistol"] }') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol',
        'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol')) = 4;

-- -- 3. Warlock: keeps the Triax pump weapon, which exists again --
-- zzz-resolve-choice-group-gear.sql restored it as a stub; the guard below
-- requires it, so this waits if that script has not run.

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["automatic-pistol", "triax-pump-weapon"] }',
      'from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "triax-pump-weapon"] }'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, 'from: ["automatic-pistol", "triax-pump-weapon"] }') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol',
        'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol',
        'triax-pump-weapon')) = 5;

-- -- 4. Mind Melter and Ley Line Rifter: pistol OR rifle, so both families --

UPDATE imported_classes
SET markdown = replace(markdown,
      'from: ["energy-pistol", "energy-rifle"] }',
      'from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol", "wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle"] }'),
    updated_at = datetime('now')
WHERE class_id IN ('mind-melter', 'ley-line-rifter')
  AND instr(markdown, 'from: ["energy-pistol", "energy-rifle"] }') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'wilk-s-320-laser-pistol', 'ng-33-northern-gun-laser-pistol',
        'ng-57-northern-gun-heavy-duty-ion-blaster', 'c-18-laser-pistol',
        'wilk-s-447-laser-rifle', 'ng-l5-northern-gun-laser-rifle',
        'l-20-pulse-rifle')) = 7;

-- Reads the result back rather than trusting the exit code.
--   dead_citations_left  0 = no published class cites a deleted placeholder
--                        inside a choice list any more
--   classes_rewired      5 = of the five classes this script targets, how many
--                        now carry the new list. SCOPED TO THOSE FIVE on
--                        purpose: an unscoped count of the slug reads 7 on a
--                        database where other classes already cite it, which
--                        is what the first version of this query did.
-- `automatic-pistol` and the two energy slugs are searched WITH their quotes,
-- so a slug that merely contains one of these names as a substring - there is
-- no such row today - could not read as a dead citation.
SELECT (SELECT count(*) FROM imported_classes
         WHERE status = 'published' AND deleted_at IS NULL
           AND (instr(markdown, '"energy-pistol"') > 0
             OR instr(markdown, '"energy-rifle"') > 0
             OR instr(markdown, '"automatic-pistol"') > 0)) AS dead_citations_left,
       (SELECT count(*) FROM imported_classes
         WHERE status = 'published' AND deleted_at IS NULL
           AND class_id IN ('headhunter-techno-warrior', 'robot-pilot', 'warlock',
                            'mind-melter', 'ley-line-rifter')
           AND instr(markdown, '"c-18-laser-pistol"') > 0) AS classes_rewired;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzz-resolve-energy-placeholder-choices.sql');
