-- Hard leather, the last unpriced rung of the Palladium Fantasy armour table.
--
-- One-off data script, run once per environment. NOT a migration - it adds a
-- row, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-hard-leather-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-hard-leather-gear.sql
--
-- Prerequisite for add-merchant-class.sql and add-scholar-class.sql, both of
-- which start in it.
--
-- THE FILENAME SORTS BEFORE BOTH ON PURPOSE. A clean rebuild applies this
-- directory as one sorted glob, and 'add-hard-leather-gear' lands ahead of
-- 'add-merchant-class' and 'add-scholar-class' where the obvious
-- 'add-pf-hard-leather-gear' would have landed between them. Nothing would
-- have failed - class markdown carries item ids as text, with no foreign key
-- to trip - but the Merchant would have gone in citing a slug that did not
-- exist yet, and its own missing_gear check would have printed 1 in a rebuild
-- and 0 by hand. retire-leather-armor-placeholder.sql was renamed for the same
-- class of mistake after repo-vs-live caught it; this one is cheaper to get
-- right up front.
--
-- Printed p270, the five-column armour table read with scripts/read-columns.py:
--
--   Hard Leather (full)  150 gold  A.R. 11  30 S.D.C.  11 lbs
--
-- That completes the four leathers the table lists. Studded and soft arrived
-- with fix-pf-armor-and-cross-system-gear.sql and add-pf-rogue-gear.sql; padded
-- is the fourth and no class in this book starts in it, so it is left for
-- whoever needs it.

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, ar, weight_lbs, description, source_book)
VALUES ('hard-leather', 'Hard Leather', 'palladium-fantasy', 'armor', 150, 11, 11,
        'Full suit of hard leather. A.R. 11, 30 S.D.C. A half suit has A.R. 8 and 12 S.D.C. Hard leather, soft leather and padded armour carry no prowl or climb penalty.',
        'palladium-fantasy-core');

-- ---- read the result back rather than trusting the exit code --------------
SELECT slug, name, system, category, cost, ar, weight_lbs FROM gear
 WHERE slug IN ('soft-leather', 'hard-leather', 'studded-leather') ORDER BY cost;
-- Expect 0: the row did not arrive as a stub.
SELECT count(*) AS new_stubs FROM gear
 WHERE slug = 'hard-leather' AND description LIKE 'STUB%';

INSERT INTO data_script_runs (filename) VALUES ('add-hard-leather-gear.sql');
