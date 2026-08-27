-- The two classes whose STARTING psionic picks the book splits by category.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zz-starting-power-splits.sql
--
-- CLASS-AUDIT.md S9. Both were stored as one open count over every category
-- the book touches, because that was the only shape creation had - and both
-- therefore permitted loadouts their books forbid:
--
--   delphi-juicer  powers_starting: 4  over ["Physical", "Super"]
--                  where the book grants 3 Physical + 1 Super, so four Super
--                  was a legal pick.
--   mind-mage      powers_starting: 12 over all four categories
--                  where the book grants three from EACH, so twelve Super was
--                  a legal pick.
--
-- `powers_starting_groups` states the split. `powers_starting` keeps its
-- meaning as the TOTAL, and `categories_allowed` stays as the union, so
-- anything reading either still reads what it always did. See `startingGroups`
-- in js/leveling.js.
--
-- The Mind Mage's rule was re-read from the page (pf cache p163, footer 161,
-- the printed+2 offset F18 established): "he gets to select three powers from
-- each of the four psionic power categories: healing, sensitive, physical and
-- Super (12 psi-powers total)."
--
-- THE DELPHI JUICER'S PAGE COULD NOT BE RE-READ. Rifts World Book 10: Juicer
-- Uprising has no OCR cache on this machine, and the book caches are local-only
-- by design. Its 3/1 split rests on two independent records inside the class
-- itself - the "Master Psionic" special ability and the extraction note, both
-- written from the page at import - which agree with each other and with the
-- audit's own reading. Worth a page check if that book is ever cached again.
--
-- Filename sort: zz- because both classes are also touched by zz- scripts
-- (zz-pf-experience-tables, zz-race-occ-restrictions,
-- zz-wire-juicer-uprising-equipment). None of them writes a psionics block, but
-- a fix- name would sit ahead of all three for no reason.
--
-- Every statement is guarded on the old text; re-running is a no-op.


-- The Delphi Juicer: three Physical and one Super.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  powers_starting: 4' || char(10) ||
         '  categories_allowed: ["Physical", "Super"]',
         '  powers_starting: 4' || char(10) ||
         '  # Three Physical and one Super, which is what the book grants. Stored as' || char(10) ||
         '  # groups because the flat count over both categories let a Delphi take four' || char(10) ||
         '  # Super powers - legal to the app, forbidden by the book.' || char(10) ||
         '  powers_starting_groups:' || char(10) ||
         '    - { count: 3, categories: ["Physical"] }' || char(10) ||
         '    - { count: 1, categories: ["Super"] }' || char(10) ||
         '  categories_allowed: ["Physical", "Super"]'),
       updated_at = datetime('now')
 WHERE class_id = 'delphi-juicer'
   AND instr(markdown, '  powers_starting_groups:') = 0;


-- The Mind Mage: three from each of the four categories.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  powers_starting: 12' || char(10) ||
         '  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]',
         '  powers_starting: 12' || char(10) ||
         '  # Three from EACH of the four, which is the book''s own wording. The flat' || char(10) ||
         '  # count over all four let a Mind Mage take twelve Super powers.' || char(10) ||
         '  powers_starting_groups:' || char(10) ||
         '    - { count: 3, categories: ["Healing"] }' || char(10) ||
         '    - { count: 3, categories: ["Sensitive"] }' || char(10) ||
         '    - { count: 3, categories: ["Physical"] }' || char(10) ||
         '    - { count: 3, categories: ["Super"] }' || char(10) ||
         '  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]'),
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, '  powers_starting_groups:') = 0;


-- The Delphi Juicer note, which gave the old limitation as the reason.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'The book grants three Physical powers and one Super power, and the app''s powers_starting is a single count against a list of allowed categories - so it is recorded as four picks across Physical and Super, and the 3/1 split is stated in the special ability and here. The per-level pick (one from Physical, Sensitive or Super each level after the first) is prose for the same reason.',
         'The book grants three Physical powers and one Super power, and that 3/1 split is DATA now: powers_starting_groups states the two groups and powers_starting stays the total (class audit S9). Before it, the block held one count against a list of allowed categories, so a Delphi could legally take four Super powers - a loadout the book forbids, which nothing flagged. The special ability still states the split in the book''s words. The per-level pick (one from Physical, Sensitive or Super each level after the first) is still prose, but NOT because the app cannot hold it: a powers_schedule entry carries its own categories, and has since the mystic. It simply has not been written.'),
       updated_at = datetime('now')
 WHERE class_id = 'delphi-juicer'
   AND instr(markdown, 'is a single count against a list') > 0;


-- The Mind Mage ability paragraph that carried the split alone.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'The psionics block cannot say three-from-each, only twelve from all four, so the split is recorded here.',
         'The psionics block states the split directly now, as four powers_starting_groups entries (class audit S9), so this paragraph is the book''s own wording rather than the only place the rule lives.'),
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, 'cannot say three-from-each') > 0;


-- The Mind Mage extraction note, same false reason.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'powers_starting is 12 with all four categories allowed, because the block cannot express three from each; the split and the five-a-level progression are natural abilities.',
         'powers_starting is 12, the TOTAL, and powers_starting_groups states the three-from-each split the book prints (class audit S9); before it the block held one open count over all four categories, so a Mind Mage could legally take twelve Super powers. The five-a-level progression from level two - two from the lesser categories plus three from Super - is still prose, and is now the larger gap in this class: powers_schedule carries per-entry categories and several entries may share a level, so it is expressible and simply not written.'),
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, 'cannot express three from each') > 0;


-- Readback. Expected: split 2, delphi_31 1, three_groups 5, old_note_left 0,
-- totals_intact 2, has_cr 0. `three_groups` is FIVE, not four: the Mind Mage's
-- four count-3 groups plus the Delphi's one, because both classes are counted
-- together here. `totals_intact` is the one that matters most - powers_starting
-- is still the TOTAL and this script must not have moved it.
SELECT sum(instr(markdown, '  powers_starting_groups:') > 0)                  AS split,
       sum(instr(markdown, '    - { count: 3, categories: ["Physical"] }' || char(10) || '    - { count: 1, categories: ["Super"] }') > 0) AS delphi_31,
       sum((length(markdown) - length(replace(markdown, '{ count: 3, categories:', ''))) / length('{ count: 3, categories:')) AS three_groups,
       sum(instr(markdown, 'cannot express three from each') > 0)
     + sum(instr(markdown, 'cannot say three-from-each') > 0)
     + sum(instr(markdown, 'is a single count against a list') > 0)           AS old_note_left,
       sum(instr(markdown, '  powers_starting: 4') > 0)
     + sum(instr(markdown, '  powers_starting: 12') > 0)                      AS totals_intact,
       sum(instr(markdown, char(13)) > 0)                                     AS has_cr
  FROM imported_classes WHERE class_id IN ('delphi-juicer', 'mind-mage');

-- Records this run. Every statement guards itself, so this is safe to re-run.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zz-starting-power-splits.sql');
