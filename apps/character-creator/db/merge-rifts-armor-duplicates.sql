-- Seven Rifts armour rows that were the same suit twice.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/merge-rifts-armor-duplicates.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/merge-rifts-armor-duplicates.sql
--
--   crusader-body-armor                            -> crusader-full-environmental-body-armor
--     mdc 95, 40000 cr                                mdc 95, 55000 cr
--   gladiator-body-armor                           -> gladiator-full-environmental-body-armor
--     mdc 70, 38000 cr                                mdc 70, 38000 cr
--   plastic-man-body-armor                         -> plastic-man-full-environmental-body-armor
--     mdc 35, 18000 cr                                mdc 35, 18000 cr
--   urban-warrior-body-armor                       -> urban-warrior-padded-environmental-body-armor
--     mdc 50, 35000 cr                                mdc 50, 35000 cr
--   dead-boy-armor-ca-1-heavy                      -> ca-1-heavy-dead-boy-armor
--     mdc -, no cr                                    mdc 80, 35000 cr
--   dead-boy-armor-ca-2-light                      -> ca-2-light-dead-boy-armor
--     mdc -, no cr                                    mdc 50, 35000 cr
--   dead-boy-armor-black-market                    -> ca-2-light-dead-boy-armor
--     mdc -, 45000 cr                                 mdc 50, 35000 cr
--
-- THE PATTERN IS THE SAME EVERY TIME, which is what makes these real duplicates
-- rather than four suits that happen to share a shape. Each pair is one row
-- imported from Rifts Ultimate Edition p.261-270 and one older row whose
-- source_book reads "Web reference (not book-verified)", and on the four
-- full-suit pairs the M.D.C. and the weight agree exactly: 95/24, 70/21, 35/13,
-- 50/11. The book-verified row is the keeper in every case.
--
-- THE CRUSADER PAIR DISAGREES ON PRICE, 55,000 against 40,000, and that is the
-- one thing here that is not a tidy-up: one of those numbers was wrong and the
-- catalog offered both. The book-verified row keeps its 55,000.
--
-- THE THREE DEAD BOY ROWS ARE A DIFFERENT SHAPE. Two are one-line stubs -
-- "Coalition heavy body armour, old style." - with no M.D.C. and no cost,
-- standing beside full rows that have both. The third is not a suit at all:
-- "Dead Boy" Body Armor (Black Market) has no M.D.C., and its description says
-- outright that it is a price. Printed 261 puts that price under "Features
-- Common to All Dead Boy Armor" - "Black Market Price: 35,000 to 45,000 with a
-- custom paint job" - so it belongs to both suits, and it is written onto both
-- as a cost_note rather than left standing as an item somebody could wear.
--
-- The same page cross-checks the two keepers: CA-1 Heavy at 18 pounds and 80
-- main-body M.D.C., CA-2 Light at 9 pounds and 50. Both match what the catalog
-- already held.
--
-- ONE REDIRECT ALREADY POINTED AT A ROW BEING RETIRED. 'dead-boy-body-armor'
-- resolved to the CA-2 STUB, so it is re-pointed at the real row first -
-- otherwise a retired key would resolve to a row that no longer exists, which
-- is the one failure catalog_redirects exists to prevent.
--
-- NOT MERGED, having been checked and found distinct:
--
--   bushman-full-composite-environmental-body-armor / bushman-trooper
--       60 M.D.C. against 90. The book describes the Trooper as a separate,
--       bulkier model, not another printing of the same suit.
--   huntsman-plate-padded-armor-non-environmental /
--   juicer-assassin-plate-armor-non-environmental
--       both 45 M.D.C., and everything else differs - 24,000 against 28,000,
--       16 lbs against 14. Two armours that share a rating.
--   cyber-armor
--       held by two characters and granted by the Cyber-Knight. Not a
--       duplicate of anything.
--
-- Guarded four ways on every delete: nothing may hold it, no campaign may list
-- it, no class may cite it, and no redirect may point at it.

-- Re-point anything aimed at a row about to be retired.
UPDATE catalog_redirects
   SET to_id = (SELECT id FROM gear WHERE slug = 'ca-2-light-dead-boy-armor')
 WHERE catalog = 'gear'
   AND to_id = (SELECT id FROM gear WHERE slug = 'dead-boy-armor-ca-2-light')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-2-light-dead-boy-armor');

-- The black market price belongs to both suits, not to a row of its own.
UPDATE gear
   SET cost_note = 'Black market 35,000-45,000 credits, the upper end with a custom paint job'
 WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
   AND cost_note IS NULL;

-- crusader-body-armor
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'crusader-body-armor', (SELECT id FROM gear WHERE slug = 'crusader-full-environmental-body-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'crusader-full-environmental-body-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'crusader-body-armor');

DELETE FROM gear
 WHERE slug = 'crusader-body-armor'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'crusader-full-environmental-body-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- gladiator-body-armor
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'gladiator-body-armor', (SELECT id FROM gear WHERE slug = 'gladiator-full-environmental-body-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'gladiator-full-environmental-body-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'gladiator-body-armor');

DELETE FROM gear
 WHERE slug = 'gladiator-body-armor'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'gladiator-full-environmental-body-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- plastic-man-body-armor
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'plastic-man-body-armor', (SELECT id FROM gear WHERE slug = 'plastic-man-full-environmental-body-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'plastic-man-full-environmental-body-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'plastic-man-body-armor');

DELETE FROM gear
 WHERE slug = 'plastic-man-body-armor'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'plastic-man-full-environmental-body-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- urban-warrior-body-armor
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'urban-warrior-body-armor', (SELECT id FROM gear WHERE slug = 'urban-warrior-padded-environmental-body-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'urban-warrior-padded-environmental-body-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'urban-warrior-body-armor');

DELETE FROM gear
 WHERE slug = 'urban-warrior-body-armor'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'urban-warrior-padded-environmental-body-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- dead-boy-armor-ca-1-heavy
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'dead-boy-armor-ca-1-heavy', (SELECT id FROM gear WHERE slug = 'ca-1-heavy-dead-boy-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-1-heavy-dead-boy-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'dead-boy-armor-ca-1-heavy');

DELETE FROM gear
 WHERE slug = 'dead-boy-armor-ca-1-heavy'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-1-heavy-dead-boy-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- dead-boy-armor-ca-2-light
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'dead-boy-armor-ca-2-light', (SELECT id FROM gear WHERE slug = 'ca-2-light-dead-boy-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-2-light-dead-boy-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'dead-boy-armor-ca-2-light');

DELETE FROM gear
 WHERE slug = 'dead-boy-armor-ca-2-light'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-2-light-dead-boy-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);

-- dead-boy-armor-black-market
INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'dead-boy-armor-black-market', (SELECT id FROM gear WHERE slug = 'ca-2-light-dead-boy-armor'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-2-light-dead-boy-armor')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'dead-boy-armor-black-market');

DELETE FROM gear
 WHERE slug = 'dead-boy-armor-black-market'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'ca-2-light-dead-boy-armor')
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM campaign_items gi WHERE gi.gear_slug = gear.slug)
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE instr(c.markdown, 'item_id: ' || char(34) || gear.slug || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM catalog_redirects r
                   WHERE r.catalog = 'gear' AND r.to_id = gear.id);


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS retired_rows_left FROM gear WHERE slug IN ('crusader-body-armor', 'gladiator-body-armor', 'plastic-man-body-armor', 'urban-warrior-body-armor', 'dead-boy-armor-ca-1-heavy', 'dead-boy-armor-ca-2-light', 'dead-boy-armor-black-market');
SELECT count(*) AS keepers_present FROM gear WHERE slug IN ('crusader-full-environmental-body-armor', 'gladiator-full-environmental-body-armor', 'plastic-man-full-environmental-body-armor', 'urban-warrior-padded-environmental-body-armor', 'ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor');
SELECT count(*) AS redirects_for_the_retired FROM catalog_redirects
 WHERE catalog = 'gear' AND from_key IN ('crusader-body-armor', 'gladiator-body-armor', 'plastic-man-body-armor', 'urban-warrior-body-armor', 'dead-boy-armor-ca-1-heavy', 'dead-boy-armor-ca-2-light', 'dead-boy-armor-black-market');
SELECT count(*) AS redirects_pointing_at_nothing FROM catalog_redirects r
 WHERE r.catalog = 'gear' AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.id = r.to_id);
SELECT count(*) AS dead_boy_suits_with_the_black_market_price FROM gear
 WHERE slug IN ('ca-1-heavy-dead-boy-armor', 'ca-2-light-dead-boy-armor')
   AND cost_note LIKE 'Black market%';
SELECT count(*) AS rifts_armour_rows FROM gear WHERE system = 'rifts' AND category = 'armor';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('merge-rifts-armor-duplicates.sql');
