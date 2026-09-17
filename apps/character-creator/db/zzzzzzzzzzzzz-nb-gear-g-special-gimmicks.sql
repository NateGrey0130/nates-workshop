-- Step 4 of the Nightbane extraction plan (apps/character-creator/docs/surveys/nightbane-core.md):
-- Special Gimmicks. Printed 232. 8 rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzzzzzzzzz-nb-gear-g-special-gimmicks.sql
--
-- D4 (#1126): every item in the equipment chapter is its own `nightbane` row, on
-- Nate's word, read off the Nightbane pages rather than shared with Heroes Unlimited's
-- rows for the near-identical chapter. HU's scripts (add-hu-gear-*.sql) are the
-- PRECEDENT for shape - names, where a combined entry splits into priced rows, which
-- column a number goes in - and each row here was diffed against its HU counterpart
-- to catch misreads. Where the two books disagree, this file holds what Nightbane
-- prints; the PR lists every disagreement and its evidence.
--
-- Slugs are the name plus `-nb`, so no Nightbane row can collide with a row of
-- another game. `cost` is dollars, a range's low end; NULL where the page prints no
-- price, with any printed wording in cost_note. Citations are printed folios
-- (cache page = folio + 1).

INSERT INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, damage, is_mega_damage, range, payload, rate_of_fire, ar, sdc, description, source_book)
VALUES
  ('tailor-made-clothing-nb', 'Tailor-Made Clothing', 'nightbane', 'gear', NULL, NULL, 'Add $50 for each hiding place/pocket and $100 to the overall cost of the clothing', NULL, 0, NULL, NULL, NULL, NULL, NULL, 'Clothing with secret pockets and seams for concealment: a seam or cuff can hold wire or a small tool, and tiny pouches and pockets are designed to be invisible on quick examination. They are small, flat pockets for small implements that might not be felt in a body search; guns or wallets are far too bulky.', 'Nightbane RPG p.232'),
  ('belt-buckle-compartment-nb', 'Belt Buckle Compartment', 'nightbane', 'gear', NULL, 35, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 'Special Gimmicks, printed 232.', 'Nightbane RPG p.232'),
  ('belt-with-a-secret-lining-nb', 'Belt with a Secret Lining', 'nightbane', 'gear', NULL, 50, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, 'Holds wire, keys and small, flat tools.', 'Nightbane RPG p.232'),
  ('flash-powder-nb', 'Flash Powder', 'nightbane', 'gear', NULL, 20, 'per ounce', NULL, 0, NULL, NULL, NULL, NULL, NULL, 'A simple chemical reaction ignites the powder in a blinding flash and a small puff of smoke. Does no damage, but everyone exposed to the flash (within 12ft) loses initiative.', 'Nightbane RPG p.232'),
  ('itching-powder-gimmick-nb', 'Itching Powder (gimmick)', 'nightbane', 'gear', NULL, 10, 'per ounce', NULL, 0, NULL, NULL, NULL, NULL, NULL, 'Makes its victim itchy and uncomfortable for 1D4 hours or until washed off. Affects only bare skin. Victims are annoyed and distracted: -4 on initiative. Special Gimmicks, printed 232.', 'Nightbane RPG p.232'),
  ('goblin-dust-nb', 'Goblin Dust', 'nightbane', 'gear', NULL, NULL, 'About two bucks for a five pound batch - not a firm price', NULL, 0, NULL, NULL, NULL, NULL, NULL, 'Often a homemade powder of fine soot, ash and dirt, packaged in small packets that are torn and thrown or blown in an opponent''s face; large paper bags can be filled and swung like a club, breaking open in the person''s face. 45% chance of getting the dust in the eyes, blinding for 1D4 melees (-6 to strike, parry and dodge).', 'Nightbane RPG p.232'),
  ('mini-smoke-bomb-nb', 'Mini-Smoke Bomb', 'nightbane', 'gear', NULL, 5, 'each', NULL, 0, NULL, NULL, NULL, NULL, NULL, 'A small golf-ball sized item, easy to conceal or palm, that emits a cloud of smoke filling a 10 foot (3m) area. Colors: grey, black, yellow, red, white and green.', 'Nightbane RPG p.232'),
  ('mini-stink-bombs-nb', 'Mini-Stink Bombs', 'nightbane', 'gear', NULL, 30, 'each', NULL, 0, NULL, NULL, NULL, NULL, NULL, 'Looks just like the smoke bomb but emits a horrible stench that fills a 10ft area and lasts 1D6 minutes, 20 times worse than commercial prank types. Save 16 or higher: on a failed save, those exposed forfeit half their attacks that melee and run out of the area; those who endure it without saving lose two melee attacks and are -1 to strike, parry and dodge. A successful save means no significant effect.', 'Nightbane RPG p.232');

-- Read the result back. This batch asserts its OWN rows and nothing else.
SELECT 'all 8 rows of this script are in, as nightbane' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE system = 'nightbane' AND source_book LIKE 'Nightbane RPG p.%'
   AND slug IN ('tailor-made-clothing-nb', 'belt-buckle-compartment-nb', 'belt-with-a-secret-lining-nb', 'flash-powder-nb', 'itching-powder-gimmick-nb', 'goblin-dust-nb', 'mini-smoke-bomb-nb', 'mini-stink-bombs-nb');

SELECT 'every one has a description' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE system = 'nightbane' AND length(description) > 0
   AND slug IN ('tailor-made-clothing-nb', 'belt-buckle-compartment-nb', 'belt-with-a-secret-lining-nb', 'flash-powder-nb', 'itching-powder-gimmick-nb', 'goblin-dust-nb', 'mini-smoke-bomb-nb', 'mini-stink-bombs-nb');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzz-nb-gear-g-special-gimmicks.sql');
