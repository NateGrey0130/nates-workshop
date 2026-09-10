-- Record New West's Black Market prices on the three CS armours RUE already
-- holds, WITHOUT duplicating a row or overwriting a RUE figure.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-new-west-black-market-armour-prices.sql
--
-- == THE QUESTION THIS ANSWERS ==
--
-- New West printed 178-179 sells knock-offs of the old Coalition armour and
-- says outright they are "identical to the old CS body armor in every way,
-- except the standard colors". So PR #895 did not duplicate them - RUE already
-- holds all three - and left the price divergence for a decision instead:
--
--   ca-2-light-dead-boy-armor   RUE 35,000        New West 40,000
--   ca-1-heavy-dead-boy-armor   RUE 35,000        New West 50,000
--   dog-pack-dpm-riot-armor     RUE no cost       New West 12,000 / 18,000
--
-- ONE ROW WITH A RICHER NOTE, which is the shape F42 already chose for this
-- table when two readings of one machine disagreed. The alternatives were
-- overwriting RUE's figure - which loses a sourced number - or a second row
-- with identical stats, which is the duplicate F33 and F44 exist to find.
--
-- SO: `cost` IS NOT TOUCHED where one already exists. The New West figures go
-- in `cost_note` where a reader meets them, cited to their own page, and
-- `source_book` names both books.
--
-- THE DOG PACK IS THE EXCEPTION AND IT IS NOT AN OVERWRITE. That row carries NO
-- cost at all, so New West's 12,000 fills an empty column rather than replacing
-- a RUE reading. It is also the one row where New West has MORE than RUE: it
-- splits the suit into light and heavy with different M.D.C., where the RUE row
-- is a single suit. Both readings are recorded; the RUE M.D.C. stands, because
-- nothing here is confident enough to restate a shipped figure.

UPDATE gear
   SET cost_note = cost_note || ' NEW WEST, printed 178, prices the Black Market knock-off at 40,000 credits with fair to poor availability, especially in the West - it is popular in the Pecos Empire. Same suit, a different market.',
       source_book = source_book || '; Rifts World Book 14: New West p.178'
 WHERE slug = 'ca-2-light-dead-boy-armor'
   AND instr(cost_note, 'NEW WEST') = 0;

UPDATE gear
   SET cost_note = cost_note || ' NEW WEST, printed 178, prices the Black Market knock-off at 50,000 credits with fair to poor availability, especially in the West - it is popular in the Pecos Empire. Same suit, a different market.',
       source_book = source_book || '; Rifts World Book 14: New West p.178'
 WHERE slug = 'ca-1-heavy-dead-boy-armor'
   AND instr(cost_note, 'NEW WEST') = 0;

-- The only row here that GAINS a price rather than an annotation.
UPDATE gear
   SET cost = 12000,
       cost_note = 'Black Market 12,000 credits for the light version and 18,000 for the heavy; fair to poor availability, especially in the West. Rifts World Book 14: New West printed 178, which is the only book of the two that prices this suit at all.',
       description = description || ' NEW WEST, printed 178, SPLITS THIS SUIT INTO LIGHT AND HEAVY where this row is a single suit: main body 50 heavy or 35 light, arms 10 each plus 3 for heavy, legs 15 each plus 5 for heavy, and a weight of 10 lbs (4.5 kg) against this row''s 8. Head is none unless a helmet is bought separately, at 15-35 M.D.C. The M.D.C. figures above are RUE''s and stand; the split is recorded rather than merged, because nothing here is confident enough to restate a shipped figure.',
       source_book = source_book || '; Rifts World Book 14: New West p.178'
 WHERE slug = 'dog-pack-dpm-riot-armor'
   AND cost IS NULL;

-- Read the result back rather than trusting the exit code.
SELECT 'all three name both books' AS assertion, count(*) AS got, 3 AS want
  FROM gear
 WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor', 'dog-pack-dpm-riot-armor')
   AND instr(source_book, 'New West') > 0;

-- The two RUE prices are asserted BY VALUE, because not overwriting them is the
-- whole decision and a later well-meaning edit would be the worst way to find
-- out it had been reversed.
SELECT 'and the two RUE costs are unchanged' AS assertion, count(*) AS got, 2 AS want
  FROM gear
 WHERE (slug = 'ca-1-heavy-dead-boy-armor' AND cost = 35000)
    OR (slug = 'ca-2-light-dead-boy-armor' AND cost = 35000);

SELECT 'and the Dog Pack has gained the only new price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE slug = 'dog-pack-dpm-riot-armor' AND cost = 12000;

-- Still exactly three rows, not six. The point of the decision.
SELECT 'no duplicate row was created' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE slug LIKE 'ca-%-dead-boy-armor' OR slug = 'dog-pack-dpm-riot-armor';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-new-west-black-market-armour-prices.sql');
