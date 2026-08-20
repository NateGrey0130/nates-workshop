-- Rifts Ultimate Edition, Shifter O.C.C. standard equipment.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-shifter-energy-rifle.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-shifter-energy-rifle.sql
--
-- The Shifter's equipment list carries `item_id: "energy-rifle"`. That is not an
-- item and never was: before equipment_starting supported choice groups, a class
-- whose book said "one energy rifle" had nowhere to put the choice, so the
-- importer emitted the CATEGORY as a fixed id and then created a stub catalog row
-- for it, because that is what it does for any referenced item it cannot find.
-- No book entry will ever match it, so a Shifter has been starting play holding a
-- weapon that does not exist.
--
-- This is the same fix retire-gear-placeholders.sql applied to the Juicer's
-- `energy-pistol` and `vibro-blade`, and it is separate only because that script
-- was written against the four placeholders visible at the time. `energy-rifle`
-- was in its DELETE list but had no rewrite rule, so the Juicer's two retired and
-- this one survived, still cited, which is exactly how it got noticed.
--
-- THE OPTIONS are the catalog's actual energy rifles - every gear row whose name
-- says rifle and which carries real damage, as of the Rifts Ultimate Edition
-- equipment import. The book says "of choice" without enumerating, so this is the
-- available set rather than a claim about what the page lists; widen it as more
-- books are imported. The JA-9 and JA-11 are branded for the Juicer Assassin and
-- are included on purpose - they are energy rifles the catalog holds, and cost
-- does not gate starting equipment, which is granted rather than bought.
--
-- GUARDED on all six options existing AND on the exact line being present. A
-- rewrite pointing at absent slugs would be strictly worse than the placeholder
-- it replaces, and matching the whole line rather than the id means a Shifter
-- whose markdown has since been edited is left alone rather than half-rewritten.
--
-- NOT FIXED HERE: the Shifter also cites `submachine-gun`, which is a stub too.
-- Whether that is a category ("any submachine gun") or a real S.D.C. entry the
-- equipment chapter prints needs the book, and inventing a `from:` list would be
-- the guessing this app's import rules exist to forbid. Left for a reading pass.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "energy-rifle", qty: 1 }',
      '  - { choose: 1, label: "energy rifle", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"] }'),
    updated_at = datetime('now')
WHERE class_id = 'shifter'
  AND instr(markdown, '  - { item_id: "energy-rifle", qty: 1 }') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN (
        'ja-11-juicer-assassin-s-energy-rifle',
        'ja-9-juicer-assassin-variable-laser-rifle',
        'l-20-pulse-rifle',
        'ng-l5-northern-gun-laser-rifle',
        'ng-p7-northern-gun-particle-beam-rifle',
        'wilk-s-447-laser-rifle')) = 6;

-- Retire the placeholder row, but only once no live class still cites it. The
-- same condition retire-gear-placeholders.sql uses, repeated here so this script
-- completes on its own rather than needing that one re-run afterwards.
DELETE FROM gear
WHERE slug = 'energy-rifle'
  AND NOT EXISTS (SELECT 1 FROM imported_classes c
                  WHERE c.deleted_at IS NULL
                    AND instr(c.markdown, 'item_id: ' || char(34) || 'energy-rifle' || char(34)) > 0)
  AND NOT EXISTS (SELECT 1 FROM character_items ci JOIN gear g ON g.id = ci.item_id
                  WHERE g.slug = 'energy-rifle');

-- Reports what the environment now has, so the result is read rather than
-- assumed. Over --remote the trailing SELECTs of a --file run do NOT surface -
-- D1's import endpoint returns aggregate counts only - so re-run this SELECT
-- with --command if you need to see it.
--   shifter_rewritten     1 = the choice group is in place
--   still_citing_category 0 = no live class names the placeholder any more
--   placeholder_row_left  0 = the stub is gone
--   options_available     6 = every slug the choice offers exists
SELECT (SELECT count(*) FROM imported_classes
        WHERE class_id = 'shifter' AND instr(markdown, 'label: "energy rifle"') > 0) AS shifter_rewritten,
       (SELECT count(*) FROM imported_classes
        WHERE deleted_at IS NULL
          AND instr(markdown, 'item_id: ' || char(34) || 'energy-rifle' || char(34)) > 0) AS still_citing_category,
       (SELECT count(*) FROM gear WHERE slug = 'energy-rifle') AS placeholder_row_left,
       (SELECT count(*) FROM gear WHERE slug IN (
          'ja-11-juicer-assassin-s-energy-rifle',
          'ja-9-juicer-assassin-variable-laser-rifle',
          'l-20-pulse-rifle',
          'ng-l5-northern-gun-laser-rifle',
          'ng-p7-northern-gun-particle-beam-rifle',
          'wilk-s-447-laser-rifle')) AS options_available;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-shifter-energy-rifle.sql');
