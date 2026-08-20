-- The last five most-cited stubs: two filled, three that cannot be.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/backfill-gas-mask-and-mallet.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/backfill-gas-mask-and-mallet.sql
--
-- gas-mask (14 classes), clothing (9), small-mallet (8), traveling-clothes (7)
-- and food-rations (5) were the most-cited stubs left. Only two of them have
-- numbers anywhere findable.
--
-- NOT FILLED, and this is the finding rather than a gap nobody got to:
--
--   clothing, traveling-clothes, food-rations
--       No Rifts pricing for ordinary clothes or food exists on the open web,
--       and the search turned up the reason: food and drink pricing is absent
--       from most Rifts books outright. Classes grant "a week's food rations"
--       as a line of text; no book seems to say what a week costs. Inventing a
--       number would be inventing a rule, not transcribing one.
--
-- THE SOURCE IS THE WEB, NOT THE BOOK, and source_book says so on both rows.

-- Human-sized gas mask. A version for something larger than human runs
-- roughly 80 to 120 credits.
UPDATE gear
SET description = 'A human-sized gas mask. Typically 50 to 80 credits; a version sized for something larger than a human runs roughly 80 to 120. Usually paired with an air filter, which is the consumable half.',
    source_book = 'Web reference (not book-verified)',
    cost = 50
  WHERE slug = 'gas-mask' AND description LIKE 'STUB%';

-- A "small mallet" as such is not priced anywhere findable. What IS priced is a
-- metal claw hammer, which is the same object for the purpose every class that
-- grants one has in mind: driving the six wooden stakes granted beside it. The
-- description says plainly that this is a stand-in, because a reader who
-- assumes it was transcribed from a mallet entry would be wrong.
UPDATE gear
SET description = 'Roughly 10 to 20 credits, about 1 lb, doing 1D6 S.D.C. if swung in anger. NOTE: these figures are for a metal claw hammer, which is the nearest thing with a published price - no mallet entry was found. Same job either way: the classes granting one also grant six wooden stakes.',
    source_book = 'Web reference (not book-verified)',
    cost = 10, weight_lbs = 1, damage = '1D6', is_mega_damage = 0
  WHERE slug = 'small-mallet' AND description LIKE 'STUB%';

-- A disagreement found while looking for the gas mask, recorded on the row it
-- affects rather than left for someone to trip over. Guarded on the row still
-- carrying what this project wrote, so a book correction is never overwritten.
UPDATE gear
SET description = 'A pack of 12 replaceable filters, about 5 credits the pack. Each filter weighs around 2 ounces; the figure here is for the full pack. NOTE: a second source prices 12 disposable filters at 35 credits rather than 5, so treat the cost as uncertain until a book settles it.'
  WHERE slug = 'air-filter'
    AND source_book = 'Web reference (not book-verified)'
    AND description NOT LIKE '%second source%';

-- Reports the result back, so it is read rather than assumed.
--   gas_mask_cost      50 = filled
--   mallet_cost        10 = filled
--   filter_caveat       1 = the air filter row now carries the disagreement
--   unpriced_top       the most-cited stubs still without a cost, worst first
--   stubs_now          the running total, for comparison against 84
SELECT (SELECT cost FROM gear WHERE slug = 'gas-mask') AS gas_mask_cost,
       (SELECT cost FROM gear WHERE slug = 'small-mallet') AS mallet_cost,
       (SELECT count(*) FROM gear
          WHERE slug = 'air-filter' AND description LIKE '%second source%') AS filter_caveat,
       (SELECT group_concat(slug, ', ') FROM (
          SELECT g.slug FROM gear g
           WHERE g.description LIKE 'STUB%'
           ORDER BY (SELECT count(*) FROM imported_classes c
                      WHERE c.deleted_at IS NULL
                        AND instr(c.markdown, 'item_id: "' || g.slug || '"') > 0) DESC
           LIMIT 5)) AS unpriced_top,
       (SELECT count(*) FROM gear WHERE description LIKE 'STUB%') AS stubs_now;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('backfill-gas-mask-and-mallet.sql');
