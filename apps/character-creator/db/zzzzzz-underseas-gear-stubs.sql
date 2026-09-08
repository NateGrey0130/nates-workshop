-- The eighteen gear stubs Rifts World Book 7: Underseas left behind.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzz-underseas-gear-stubs.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzz-underseas-gear-stubs.sql
--
-- WHERE THESE CAME FROM. The class imports in PRs #800-#807 read Standard
-- Equipment lines naming ordinary kit - luggage, duct tape, a fishing pole, a
-- wet suit - and every gear name a class cites needs a catalog row, so the
-- importer created one carrying the marker
--
--     STUB - created by class import, needs stats
--
-- The gear pass in #808 was meant to clear them and did not: it extracted the
-- 87 entries the book PRICES, and not one of these eighteen is among them.
-- Checked rather than assumed - "wet suit", "scuba" and "snorkel" appear in
-- this book only inside Standard Equipment lists and in ship complements. The
-- one wet suit it prices is the LEWS-9 environmental suit, which is already its
-- own row and is NOT the same object.
--
-- So the marker is wrong on all eighteen. It says "needs stats" and no stats
-- are coming, because this book does not have them and never did.
--
-- FIVE ARE DUPLICATES OF ROWS THE CATALOG ALREADY HELD, under a different
-- wording. The importer coins a slug from the book's phrasing rather than
-- matching an existing row, so `flashlight-pen` was created beside RUE's
-- `pen-flashlight` and `hand-computer` beside `hand-held-computer`. Those five
-- are merged on the `merge-backpack-duplicate.sql` pattern: repoint the citing
-- classes, move any redirect, leave a forwarding address, then delete.
--
-- THE KEEPER IS THE STATTED ROW IN ALL FIVE, which departs from the backpack
-- merge's tiebreak and for a reason that only looks similar. There, both rows
-- were complete and identical, so "which name do references use" was the only
-- question left. Here one row of each pair has a price and a book behind it and
-- the other is an empty stub, so the answer is not in doubt - and it holds even
-- for `fishing-hooks-and-lures`, which two classes cite against the keeper's
-- one. Those two are repointed.
--
-- NO CHARACTER IS AFFECTED. `character_items` was counted for all ten slugs
-- before this was written and holds nothing on any of them, so no inventory
-- line is repointed and none is orphaned.
--
-- THIRTEEN ARE NOT DUPLICATES and get a marked estimate, on the
-- `estimate-mundane-gear-prices.sql` precedent, whose rules are followed
-- exactly:
--
--   * `source_book` reads 'Estimate - no published price found', the third
--     provenance tier. Grep it to find every value in this catalog nothing
--     stands behind.
--   * COST ONLY. Not one of these gets a damage, an M.D.C., an A.R., an S.D.C.
--     or a weight. A guessed combat number is indistinguishable from a real one
--     once it is in the table and it decides fights; a guessed weight quietly
--     moves encumbrance. Both stay NULL.
--   * Anchored to the catalog's own scale, so they sit beside published values
--     without looking odd - a pen flashlight is 6 credits, plain goggles 15,
--     tinted goggles 75, fishing line and hooks 8, a tool kit 300, a hand-held
--     computer 100.
--
-- WHY ESTIMATE AT ALL, rather than describe them and leave the cost NULL: a
-- stub with no price cannot be bought at a table, a marked estimate can, and it
-- can be corrected the moment a real page turns up. That is the argument the
-- estimate file makes and nothing here changes it.
--
-- Every statement guards itself. The merges check the keeper exists before
-- touching anything, and the estimates are guarded on the row STILL being a
-- stub, so re-running this can never overwrite a row somebody has since filled
-- in by hand. Pure ASCII, LF endings.

-- ---------- the five duplicates ----------

-- flashlight-pen -> pen-flashlight
UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'flashlight-pen' || char(34),
                                    char(34) || 'pen-flashlight' || char(34)),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL
   AND instr(markdown, char(34) || 'flashlight-pen' || char(34)) > 0
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'pen-flashlight');

UPDATE catalog_redirects
   SET to_id = (SELECT id FROM gear WHERE slug = 'pen-flashlight')
 WHERE catalog = 'gear'
   AND to_id = (SELECT id FROM gear WHERE slug = 'flashlight-pen')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'pen-flashlight');

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'flashlight-pen', (SELECT id FROM gear WHERE slug = 'pen-flashlight'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'pen-flashlight')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'flashlight-pen')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

DELETE FROM gear
 WHERE slug = 'flashlight-pen'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'pen-flashlight')
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE c.deleted_at IS NULL
                     AND instr(c.markdown, char(34) || 'flashlight-pen' || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- hand-computer -> hand-held-computer
UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'hand-computer' || char(34),
                                    char(34) || 'hand-held-computer' || char(34)),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL
   AND instr(markdown, char(34) || 'hand-computer' || char(34)) > 0
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'hand-held-computer');

UPDATE catalog_redirects
   SET to_id = (SELECT id FROM gear WHERE slug = 'hand-held-computer')
 WHERE catalog = 'gear'
   AND to_id = (SELECT id FROM gear WHERE slug = 'hand-computer')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'hand-held-computer');

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'hand-computer', (SELECT id FROM gear WHERE slug = 'hand-held-computer'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'hand-held-computer')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'hand-computer')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

DELETE FROM gear
 WHERE slug = 'hand-computer'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'hand-held-computer')
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE c.deleted_at IS NULL
                     AND instr(c.markdown, char(34) || 'hand-computer' || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- tool-kit-large -> large-tool-kit
UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'tool-kit-large' || char(34),
                                    char(34) || 'large-tool-kit' || char(34)),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL
   AND instr(markdown, char(34) || 'tool-kit-large' || char(34)) > 0
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'large-tool-kit');

UPDATE catalog_redirects
   SET to_id = (SELECT id FROM gear WHERE slug = 'large-tool-kit')
 WHERE catalog = 'gear'
   AND to_id = (SELECT id FROM gear WHERE slug = 'tool-kit-large')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'large-tool-kit');

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'tool-kit-large', (SELECT id FROM gear WHERE slug = 'large-tool-kit'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'large-tool-kit')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'tool-kit-large')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

DELETE FROM gear
 WHERE slug = 'tool-kit-large'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'large-tool-kit')
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE c.deleted_at IS NULL
                     AND instr(c.markdown, char(34) || 'tool-kit-large' || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- tool-kit-portable -> portable-tool-kit
UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'tool-kit-portable' || char(34),
                                    char(34) || 'portable-tool-kit' || char(34)),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL
   AND instr(markdown, char(34) || 'tool-kit-portable' || char(34)) > 0
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'portable-tool-kit');

UPDATE catalog_redirects
   SET to_id = (SELECT id FROM gear WHERE slug = 'portable-tool-kit')
 WHERE catalog = 'gear'
   AND to_id = (SELECT id FROM gear WHERE slug = 'tool-kit-portable')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'portable-tool-kit');

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'tool-kit-portable', (SELECT id FROM gear WHERE slug = 'portable-tool-kit'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'portable-tool-kit')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'tool-kit-portable')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

DELETE FROM gear
 WHERE slug = 'tool-kit-portable'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'portable-tool-kit')
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE c.deleted_at IS NULL
                     AND instr(c.markdown, char(34) || 'tool-kit-portable' || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- fishing-hooks-and-lures -> fishing-line-and-hooks
UPDATE imported_classes
   SET markdown = replace(markdown, char(34) || 'fishing-hooks-and-lures' || char(34),
                                    char(34) || 'fishing-line-and-hooks' || char(34)),
       updated_at = datetime('now')
 WHERE deleted_at IS NULL
   AND instr(markdown, char(34) || 'fishing-hooks-and-lures' || char(34)) > 0
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'fishing-line-and-hooks');

UPDATE catalog_redirects
   SET to_id = (SELECT id FROM gear WHERE slug = 'fishing-line-and-hooks')
 WHERE catalog = 'gear'
   AND to_id = (SELECT id FROM gear WHERE slug = 'fishing-hooks-and-lures')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'fishing-line-and-hooks');

INSERT INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'gear', 'fishing-hooks-and-lures', (SELECT id FROM gear WHERE slug = 'fishing-line-and-hooks'), 'merge'
 WHERE EXISTS (SELECT 1 FROM gear WHERE slug = 'fishing-line-and-hooks')
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'fishing-hooks-and-lures')
ON CONFLICT (catalog, from_key)
DO UPDATE SET to_id = excluded.to_id, reason = excluded.reason;

DELETE FROM gear
 WHERE slug = 'fishing-hooks-and-lures'
   AND EXISTS (SELECT 1 FROM gear WHERE slug = 'fishing-line-and-hooks')
   AND NOT EXISTS (SELECT 1 FROM imported_classes c
                   WHERE c.deleted_at IS NULL
                     AND instr(c.markdown, char(34) || 'fishing-hooks-and-lures' || char(34)) > 0)
   AND NOT EXISTS (SELECT 1 FROM character_items ci WHERE ci.gear_slug = gear.slug);

-- ---------- the thirteen the book never stats ----------

UPDATE gear
   SET name = 'Acetylene Torch',
       cost = 150,
       description = 'A fuel-gas cutting and welding torch, the pre-Rifts kind, carried by salvage crews who would rather not spend a laser torch charge on a rusted hatch.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'acetylene-torch' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Duct Tape',
       cost = 10,
       description = 'A roll of cloth-backed adhesive tape. Standard issue to every salvage and repair kit in the book, and the cheapest thing in it.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'duct-tape' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Electronic Notebook',
       cost = 60,
       description = 'A palm-sized note and sketch pad with a stylus, used for survey notes and inventories. Less capable than a hand-held computer and priced below one.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'electronic-notebook' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Fishing Net, Small',
       cost = 20,
       description = 'A hand net for taking fish one at a time, as distinct from the trawler nets the boat entries carry.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'fishing-net-small' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Fishing Pole',
       cost = 20,
       description = 'Rod and reel. The catalog already holds the line and hooks separately, at the same scale.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'fishing-pole' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Laser Communicator',
       cost = 2000,
       description = 'A tight-beam optical communicator. It needs line of sight and cannot be intercepted by anything not standing in the beam, which is why undersea and covert units carry one.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'laser-communicator' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Luggage',
       cost = 80,
       description = 'A travelling case or duffel. Named in a standard equipment list; the book gives it no size, capacity or price.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'luggage' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Scaling Knife',
       cost = 15,
       description = 'A short blade for scaling and gutting fish. A tool rather than a weapon, which is why it carries no damage figure.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'scaling-knife' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Science Kit',
       cost = 400,
       description = 'A portable field kit of sample containers, reagents and measuring instruments, carried by the book scientific trades.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'science-kit' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'S.C.U.B.A. Gear',
       cost = 1500,
       description = 'Tank, regulator, mask and fins - ordinary self-contained diving gear, NOT the environmental armour the book prices separately. Its depth and duration are not printed.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'scuba-gear' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Snorkel Gear',
       cost = 60,
       description = 'Mask, snorkel and fins for surface swimming, with no air supply of its own.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'snorkel-gear' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Soldering Goggles',
       cost = 40,
       description = 'Darkened eye protection for torch and soldering work. Priced between plain and tinted goggles, which the catalog already holds.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'soldering-goggles' AND description LIKE 'STUB%';

UPDATE gear
   SET name = 'Wet Suit',
       cost = 200,
       description = 'An ordinary insulating wet suit. NOT the LEWS-9 Light Environmental Wet Suit, which is a mega-damage environmental suit the book prices at 15,000 credits and which is already its own row.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'wet-suit' AND description LIKE 'STUB%';

-- Read the result back rather than trusting the exit code. A guarded UPDATE
-- that matched nothing is a SILENT no-op, which is exactly how this fails.
-- One statement each: D1 rejects a compound SELECT past five terms and rolls
-- the whole file back.
SELECT 'the five duplicates are gone' AS assertion,
       count(*) AS got, 0 AS want
  FROM gear WHERE slug IN ('flashlight-pen', 'hand-computer', 'tool-kit-large', 'tool-kit-portable', 'fishing-hooks-and-lures');

SELECT 'and each still resolves through a redirect' AS assertion,
       count(*) AS got, 5 AS want
  FROM catalog_redirects WHERE catalog = 'gear' AND from_key IN ('flashlight-pen', 'hand-computer', 'tool-kit-large', 'tool-kit-portable', 'fishing-hooks-and-lures');

SELECT 'their keepers are intact and still priced' AS assertion,
       count(*) AS got, 5 AS want
  FROM gear WHERE slug IN ('pen-flashlight', 'hand-held-computer', 'large-tool-kit', 'portable-tool-kit', 'fishing-line-and-hooks') AND cost IS NOT NULL;

SELECT 'no class still cites a retired slug' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (instr(markdown, char(34) || 'flashlight-pen' || char(34)) > 0
     OR instr(markdown, char(34) || 'hand-computer' || char(34)) > 0
     OR instr(markdown, char(34) || 'tool-kit-large' || char(34)) > 0
     OR instr(markdown, char(34) || 'tool-kit-portable' || char(34)) > 0
     OR instr(markdown, char(34) || 'fishing-hooks-and-lures' || char(34)) > 0);

SELECT 'no gear redirect dangles' AS assertion,
       count(*) AS got, 0 AS want
  FROM catalog_redirects r
 WHERE r.catalog = 'gear'
   AND NOT EXISTS (SELECT 1 FROM gear g WHERE g.id = r.to_id);

SELECT 'the thirteen carry a price and the estimate marker' AS assertion,
       count(*) AS got, 13 AS want
  FROM gear WHERE slug IN ('acetylene-torch', 'duct-tape', 'electronic-notebook', 'fishing-net-small', 'fishing-pole', 'laser-communicator', 'luggage', 'scaling-knife', 'science-kit', 'scuba-gear', 'snorkel-gear', 'soldering-goggles', 'wet-suit')
   AND cost IS NOT NULL AND source_book = 'Estimate - no published price found';

SELECT 'and NOT ONE of them invents a combat number or a weight' AS assertion,
       count(*) AS got, 0 AS want
  FROM gear WHERE slug IN ('acetylene-torch', 'duct-tape', 'electronic-notebook', 'fishing-net-small', 'fishing-pole', 'laser-communicator', 'luggage', 'scaling-knife', 'science-kit', 'scuba-gear', 'snorkel-gear', 'soldering-goggles', 'wet-suit')
   AND (damage IS NOT NULL OR mdc IS NOT NULL OR ar IS NOT NULL
     OR sdc IS NOT NULL OR weight_lbs IS NOT NULL);

SELECT 'this book has no gear stub left' AS assertion,
       count(*) AS got, 0 AS want
  FROM gear
 WHERE source_book LIKE '%Underseas%' AND description LIKE 'STUB%';

SELECT count(*) AS total_gear FROM gear;

INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-underseas-gear-stubs.sql');

