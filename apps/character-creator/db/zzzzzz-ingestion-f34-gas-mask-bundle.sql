-- INGESTION-AUDIT F34: the gas-mask bundle, finished in the word order the
-- original pass missed.
--
-- One-off data cleanup, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-ingestion-f34-gas-mask-bundle.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-ingestion-f34-gas-mask-bundle.sql
--
-- RE-SCOPED from what F34 proposed, and the reason is already in this directory.
-- F34 read the two rows as duplicates and proposed merging them. They are not
-- two products: they are ONE BUNDLE under two slugs, and
-- fix-structural-gear-rows.sql section 2 - 'Bundles become two entries. One book
-- line, two objects. The character was holding neither.' - already decided that
-- such a row should be split and dropped. It split 'air-filter-and-gas-mask'
-- into air-filter + gas-mask across thirteen classes and dropped the row in its
-- section 5.
--
-- It missed 'gas-mask-and-air-filter', the same bundle with the words reversed,
-- cited by one class. That is the whole of F34.
--
--   air-filter-and-gas-mask  cited by 0 published classes. Dropped once by
--                            fix-structural-gear-rows.sql, then re-inserted by
--                            zz-reconcile-gear-with-production.sql purely to
--                            match production, where it had survived.
--   gas-mask-and-air-filter  cited by 1 - `crazy` - and never reached by that
--                            pass at all.
--
-- So this finishes the earlier decision rather than inventing a new one. No
-- redirect is written, because the precedent writes none: a bundle has no single
-- successor to forward to, and fix-structural-gear-rows.sql set gear_slug to
-- NULL with a note instead.
--
-- The grant does not change in substance. `crazy` gets an air filter and a gas
-- mask, which is what the book line says and what the other thirteen classes
-- already receive; 5 + 50 credits against the bundle's 55.
--
-- No character holds either slug: character_items was 0 for both on 2026-09-06.
--
-- This sorts after add-rue-occ-gear-stubs.sql, which creates both rows, after
-- fix-structural-gear-rows.sql and zz-reconcile-gear-with-production.sql, and
-- after the zzz-gear-tidy files that rename them.

-- 1. The bundle becomes two entries, in the shape fix-structural-gear-rows.sql
--    used and with its guard: do nothing unless both halves exist.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - { item_id: "gas-mask-and-air-filter", qty: 1 }',
      '  - { item_id: "air-filter", qty: 1 }'
      || char(10) || '  - { item_id: "gas-mask", qty: 1 }'),
    updated_at = datetime('now')
WHERE instr(markdown, 'item_id: "gas-mask-and-air-filter"') > 0
  AND (SELECT count(*) FROM gear WHERE slug IN ('air-filter', 'gas-mask')) = 2;

-- 2. Any character holding a bundle slug loses the reference and gains a note,
--    which is what the earlier pass did rather than guessing a half. Zero rows
--    today; guarded for an environment that has some.
UPDATE character_items
   SET notes = COALESCE(NULLIF(notes, ''), 'was a bundle row, not an item; pick the real one'),
       gear_slug = NULL
 WHERE gear_slug IN ('gas-mask-and-air-filter', 'air-filter-and-gas-mask');

-- 3. Drop both bundle rows, once nothing cites them. Same guard as section 5 of
--    the earlier pass, so a class this script did not reach keeps its row.
DELETE FROM gear
 WHERE slug IN ('gas-mask-and-air-filter', 'air-filter-and-gas-mask')
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE c.deleted_at IS NULL
                     AND instr(c.markdown, 'item_id: "' || gear.slug || '"') > 0);

-- --- readbacks ---

SELECT 'both bundle rows are gone' AS assertion,
       (SELECT count(*) FROM gear
         WHERE slug IN ('gas-mask-and-air-filter', 'air-filter-and-gas-mask')) AS got,
       0 AS want;

SELECT 'no published class cites either bundle slug' AS assertion,
       (SELECT count(*) FROM imported_classes
         WHERE status = 'published' AND deleted_at IS NULL
           AND (instr(markdown, 'gas-mask-and-air-filter') > 0
             OR instr(markdown, 'air-filter-and-gas-mask') > 0)) AS got,
       0 AS want;

SELECT 'crazy now grants both halves' AS assertion,
       (SELECT count(*) FROM imported_classes
         WHERE class_id = 'crazy' AND status = 'published'
           AND instr(markdown, 'item_id: "air-filter"') > 0
           AND instr(markdown, 'item_id: "gas-mask"') > 0) AS got,
       1 AS want;

-- The two halves are the point of the split and must both survive.
SELECT 'both halves exist to be granted' AS assertion,
       (SELECT count(*) FROM gear WHERE slug IN ('air-filter', 'gas-mask')) AS got,
       2 AS want;

SELECT 'no character is left pointing at a bundle' AS assertion,
       (SELECT count(*) FROM character_items
         WHERE gear_slug IN ('gas-mask-and-air-filter', 'air-filter-and-gas-mask')) AS got,
       0 AS want;

-- Records this run. Every statement above guards itself, so the script is safe
-- to re-run, and a run that correctly did nothing is still a run that happened.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ingestion-f34-gas-mask-bundle.sql');
