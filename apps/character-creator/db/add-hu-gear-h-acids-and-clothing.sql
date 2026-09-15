-- Heroes Unlimited's acids, combat and hunting clothing, hats and head
-- coverings, general purpose clothes, and the capes, robes and security guard
-- uniform that close the section. Printed 219-221. One hundred and forty-six
-- rows.
--
-- THE CLOTHING SECTION DOES NOT END WITH PAGE 220. Printed 221 opens with
-- fifteen more garments and only then starts CONVENTIONAL VEHICLES, in its
-- right-hand column. Scoping this import to "219-220" would have left those
-- fifteen behind a page boundary, to be found by whoever imported the vehicles
-- and had no reason to look above them. The vehicles on 221-227 are a separate
-- import into a separate table.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-h-acids-and-clothing.sql
--
-- ===================================================================
-- THE COLOUR LINES ARE NOT ITEMS
-- ===================================================================
--
-- The clothing lists print a bold parent entry and then its colours, one price
-- per colour, with the parent name appearing ONCE:
--
--   Heavy Camouflage Coveralls: (Jumpsuit style) Insulated lining ...
--     Tiger Stripe Camouflage                              $80.00
--     Tree Bark Camouflage                                 $85.00
--     Black or White                                       $75.00
--     Green                                                $75.00
--
-- A line-oriented parser over these pages returns `Green` and `Black or White`
-- as item names - and returns them SEVERAL TIMES, because four separate parents
-- (Heavy Camouflage Coveralls, Light Camouflage Coveralls, and the Battle Dress
-- Uniform's pants and shirts) each print the same colour words at different
-- prices. Eighteen of the rows here are colour variants - four heavy coveralls,
-- four light, five fatigue pants and five fatigue shirts - and each carries its
-- parent's name so that two $30.00 `Tiger Stripe Camouflage` rows are
-- distinguishable as the BDU pants and the BDU shirt.
--
-- ===================================================================
-- WHAT THE PARSER GOT WRONG, AND WHY EVERY ROW WAS READ OFF A RENDER
-- ===================================================================
--
--   * `Tape Recorder - 30-60 min. recording time; pocket size` wraps, so its
--     $100.00 sits alone on the next line. The parser dropped the name and
--     reported an unnamed price.
--   * `Waterproof Rubber Boots: Ankle High $20.00` is followed by a
--     continuation line reading `Hip High` and then `50.00` WITH NO DOLLAR
--     SIGN. The row was dropped entirely - the same shape as the medium
--     climbing platform on printed 217, and confirmed the same way, on a
--     235 dpi render.
--   * The acids are priced `per 1/2 gallon` and the cache reads the fraction as
--     the digit 4: `$75.00 per 4 gallon`. Written out here as `half gallon`.
--   * `Battle Dress Utility` prints three weights inside one paragraph -
--     Lightweight $65.00, Medium Weight $90.00, Arctic Weight $365.00 - and the
--     parser took the tail of the sentence as a name.
--   * `$100. Gaod availability` is the Nylon Cord entry; `Gaod` is the cache.
--
-- ===================================================================
-- TWO PAIRS THAT LOOK LIKE DUPLICATES AND ARE NOT
-- ===================================================================
--
-- `Protective Goggles or Tinted Visor` is a prose entry on printed 219 at
-- $20.00; `Protective Goggles` is a price line on the SAME PAGE at $10.00.
-- `Ponchos` closes the combat/hunting clothing at $35.00 and `Rain Poncho` sits
-- in the general purpose list at $30.00. Both pairs are printed as written,
-- both were checked on renders, and each of the four rows names its counterpart
-- rather than leaving a later reader to assume a transcription slip.
--
-- ===================================================================
-- PRICES THAT LOOK WRONG AND ARE PRINTED THAT WAY
-- ===================================================================
--
--   Wool Cap            $80.00  - between a $100.00 survival coat and a
--                                 $10.00 ski mask
--   Utility Cap         $14.50  - the only price on either page that is not a
--                                 whole dollar; the catalog already holds two
--                                 half-dollar costs, so this is not new
--   Dress Shoes/Boots   $80+    - stored as 80 with the `and up` in cost_note
--   Battle Dress Utility, Arctic Weight $365.00 - more than five times the
--                                 lightweight, and not a transposition of $65
--
-- The book also prints `3 pokcet` on the denim work apron. The row is named
-- `3 pocket`; the typo is recorded here rather than in the data.
--
-- ===================================================================
-- THE NOTE ON PRINTED 221 IS NOT AN ITEM
-- ===================================================================
--
-- The clothing list closes with a pricing rule rather than a product: double or
-- triple the price for fancy or dress articles, and multiply by ten times or
-- more for custom-made ones. It applies to the list, not to any one row, so it
-- rides in the description of every row from that page instead of becoming a
-- row of its own.
--
-- ===================================================================
-- SLUGS
-- ===================================================================
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.
-- Eleven names were already spoken for and carry the `-hu` suffix: Gas Mask,
-- Sunglasses - Light Adjusting, Work Overalls, Work Pants, Hat - Short Brim,
-- Hat - Large Brim, Cape - Short, Cape - Long, Robe - Light, Robe - Heavy and
-- Robe - Hooded.
--
-- "SPOKEN FOR" INCLUDES RETIRED SLUGS, not just the ones the gear table holds.
-- The generator behind this file reads catalog_redirects as well, because
-- batch G did not: it took `back-pack`, which was absent from gear and still
-- retired into `backpack` by merge-backpack-duplicate.sql - a file that sorts
-- LATER and therefore deleted the new row again on every clean rebuild. See
-- fix-hu-back-pack-slug.sql.

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rations', 'Rations', 'heroes-unlimited', 'gear', 470, NULL, 200, NULL, NULL, NULL, 0, 'Dry field rations. Each 15lb case includes 12 meals; a crate is stocked with 12 cases and has a total shipping weight of 200lbs.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('food-ration-packs', 'Food Ration Packs', 'heroes-unlimited', 'gear', 2000, '$2000. Limited availability', NULL, NULL, NULL, NULL, 0, 'A food pack of concentrated, vitamin enriched, freeze-dried rations, enough to easily last two weeks and stretchable to four weeks if necessary. Geared for two-man consumption.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('padded-helmet', 'Padded Helmet', 'heroes-unlimited', 'gear', 25, '$25 to $75', NULL, 10, NULL, NULL, 0, 'A padded helmet, A.R. 10.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('protective-goggles-or-tinted-visor', 'Protective Goggles or Tinted Visor', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Designed for use outdoors or for welding. Unbreakable plastic lenses. Printed 219 ALSO lists a plain `Protective Goggles` at $10.00 in the price lines a few entries later; both are here, each as the book prints it.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('face-protector-and-gas-mask', 'Face Protector and Gas Mask', 'heroes-unlimited', 'gear', 200, NULL, NULL, NULL, NULL, NULL, 0, 'The mask can attach to most standard helmets, providing added protection to the face and eyes. Tinted visor and detachable air filter are standard.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('face-protector-and-gas-mask-with-independent-oxygen', 'Face Protector and Gas Mask with Independent Oxygen', 'heroes-unlimited', 'gear', 600, NULL, NULL, NULL, NULL, NULL, 0, 'The same mask with the gas mask modification and an independent oxygen supply good for two hours.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('conventional-air-filter', 'Conventional Air Filter', 'heroes-unlimited', 'gear', 75, NULL, NULL, NULL, NULL, NULL, 0, 'Fits over the nose and mouth.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('conventional-gas-mask', 'Conventional Gas Mask', 'heroes-unlimited', 'gear', 100, NULL, NULL, NULL, NULL, NULL, 0, 'With a superior filtering system.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('gas-mask-hu', 'Gas Mask', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Filters out CS, smoke and a variety of military gases. The book notes it is NOT recommended as protection against nerve gas or radiation.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('shooting-glasses', 'Shooting Glasses', 'heroes-unlimited', 'gear', 72, NULL, NULL, NULL, NULL, NULL, 0, 'Change color and density in response to changes in light and weather. Also reduces glare and improves visibility.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jet-pack', 'Jet Pack', 'heroes-unlimited', 'gear', 80000, '$80,000.00, plus $500.00 per tank of fuel - one tank is the 40 minute flight capacity', NULL, NULL, 100, NULL, 0, 'Speed 80mph maximum, with a duration of flight of 40 minutes maximum and a maximum height of 300ft.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('space-suit', 'Space Suit', 'heroes-unlimited', 'gear', 250000, NULL, NULL, NULL, NULL, NULL, 0, 'Complete: a self-contained environmental suit, insulated, heat and cold shielded, with oxygen and life support system - the whole works.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('sunglasses-light-adjusting-hu', 'Sunglasses - Light Adjusting', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('sunglasses-aviator', 'Sunglasses - Aviator', 'heroes-unlimited', 'gear', 45, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('protective-goggles', 'Protective Goggles', 'heroes-unlimited', 'gear', 10, '$10.00 in the price lines; the `Protective Goggles or Tinted Visor` entry on the same page prints $20.00', NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('basic-phone', 'Basic Phone', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('telephone-answering-machine', 'Telephone Answering Machine', 'heroes-unlimited', 'gear', 120, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tape-recorder', 'Tape Recorder', 'heroes-unlimited', 'gear', 100, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('basic-computer', 'Basic Computer', 'heroes-unlimited', 'gear', 650, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('ibm-compatible-ms-dos', 'IBM Compatible (MS Dos)', 'heroes-unlimited', 'gear', 1800, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('ibm-computer-top-of-the-line', 'IBM Computer (top of the line)', 'heroes-unlimited', 'gear', 20000, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('monitor-black-and-white', 'Monitor - Black and White', 'heroes-unlimited', 'gear', 100, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('monitor-green-or-amber', 'Monitor - Green or Amber', 'heroes-unlimited', 'gear', 250, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('monitor-full-color', 'Monitor - Full Color', 'heroes-unlimited', 'gear', 800, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('basic-printer', 'Basic Printer', 'heroes-unlimited', 'gear', 250, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('letter-quality-printer', 'Letter Quality Printer', 'heroes-unlimited', 'gear', 650, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('laser-printer-top-quality', 'Laser Printer (top quality)', 'heroes-unlimited', 'gear', 2800, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('telephone-modem', 'Telephone Modem', 'heroes-unlimited', 'gear', 150, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('organic-acid', 'Organic Acid', 'heroes-unlimited', 'gear', 75, '$75.00 per half gallon. The cost line calls this one Organic I', NULL, NULL, NULL, '2-12 per melee for four melees', 0, 'Affects only organic substances. Acids are not common household items and must be acquired from a chemical supplier, industry or an illegal outlet. In the last case availability is extremely low - a 9% chance of getting the item - and the cost is ten times the printed price.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('organic-acid-concentrated', 'Organic Acid (concentrated)', 'heroes-unlimited', 'gear', 120, '$120.00 per half gallon. The cost line calls this one Organic II', NULL, NULL, NULL, '4-24 per melee for four melees', 0, 'The concentrated form. Acids are not common household items and must be acquired from a chemical supplier, industry or an illegal outlet. In the last case availability is extremely low - a 9% chance of getting the item - and the cost is ten times the printed price.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cleanser', 'Cleanser', 'heroes-unlimited', 'gear', 180, '$180.00 per half gallon', NULL, NULL, NULL, '2-12 to organic, 1-6 to all other substances', 0, 'An industrial cleanser. Acids are not common household items and must be acquired from a chemical supplier, industry or an illegal outlet. In the last case availability is extremely low - a 9% chance of getting the item - and the cost is ten times the printed price.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('metal-dissolver', 'Metal Dissolver', 'heroes-unlimited', 'gear', 600, '$600.00 per half gallon', NULL, NULL, NULL, '4-24 per melee for four melees, 1-8 per melee to organics and plastics', 0, 'Industrial. Acids are not common household items and must be acquired from a chemical supplier, industry or an illegal outlet. In the last case availability is extremely low - a 9% chance of getting the item - and the cost is ten times the printed price.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('nylon-cord', 'Nylon Cord', 'heroes-unlimited', 'gear', 100, 'about $100. Good availability', NULL, NULL, NULL, NULL, 0, 'A variety of heavy-duty, all-purpose nylon rope or cord. Average tension strength is 600lbs (270kg) and average length is 300ft (90m).', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('police-style-jumpsuit', 'Police Style Jumpsuit', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, NULL, 0, 'One piece, zippers down the middle; large zippered chest pockets (2), front pockets (2), rear pockets (2), pencil/pen slot (left arm), sleeves and leg cuffs zipper for adjustability, bi-swing pleated back, and padded knees.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('heavy-camouflage-coveralls-tiger-stripe-camouflage', 'Heavy Camouflage Coveralls - Tiger Stripe Camouflage', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('heavy-camouflage-coveralls-tree-bark-camouflage', 'Heavy Camouflage Coveralls - Tree Bark Camouflage', 'heroes-unlimited', 'gear', 85, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('heavy-camouflage-coveralls-black-or-white', 'Heavy Camouflage Coveralls - Black or White', 'heroes-unlimited', 'gear', 75, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('heavy-camouflage-coveralls-green', 'Heavy Camouflage Coveralls - Green', 'heroes-unlimited', 'gear', 75, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('light-camouflage-coveralls-tiger-stripe-camouflage', 'Light Camouflage Coveralls - Tiger Stripe Camouflage', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('light-camouflage-coveralls-tree-bark-camouflage', 'Light Camouflage Coveralls - Tree Bark Camouflage', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('light-camouflage-coveralls-black-or-white', 'Light Camouflage Coveralls - Black or White', 'heroes-unlimited', 'gear', 45, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('light-camouflage-coveralls-green', 'Light Camouflage Coveralls - Green', 'heroes-unlimited', 'gear', 45, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('3-d-camouflage-suit', '3-D Camouflage Suit', 'heroes-unlimited', 'gear', 150, NULL, NULL, NULL, NULL, NULL, 0, 'A multi-shade of drab green and brown, with approximately 250 individual hanging strips to blend into the foliage. Bonus: +10% on the prowl skill when in a woodland environment.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('below-30-degree-coveralls', 'Below 30 Degree Coveralls', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, NULL, 0, 'Insulated for prolonged exposure in the extreme cold, with a thick turtleneck collar that covers chin, nose and mouth. The outer fabric is an acid resistant cotton/polyester twill; zippers at the leg bottoms for easy removal; knit windproof cuffs; sleeve pockets (one each arm) and six large pockets. Comes with a zip-off hood. Suitable for up to 20 degrees below zero Fahrenheit.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('work-overalls-hu', 'Work Overalls', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Jumpsuit style.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('expendable-lab-coat-or-coveralls', 'Expendable Lab Coat or Coveralls', 'heroes-unlimited', 'gear', 6, NULL, NULL, NULL, NULL, NULL, 0, 'Made from a special non-woven fabric that is acid, grease and lint resistant. Can be worn once or a dozen times, then thrown away.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-pants-tiger-stripe-camouflage', 'Battle Dress Uniform (Fatigues) - Pants - Tiger Stripe Camouflage', 'heroes-unlimited', 'gear', 30, 'Pants: 6 pockets, adjustable waist tab, button fly, drawstring cuffs', NULL, NULL, NULL, NULL, 0, 'Printed 219, among the survival and field equipment price lines.', 'Revised Heroes Unlimited p.219');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-pants-tree-bark-camouflage', 'Battle Dress Uniform (Fatigues) - Pants - Tree Bark Camouflage', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-pants-s-w-a-t-black', 'Battle Dress Uniform (Fatigues) - Pants - S.W.A.T. Black', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-pants-olive-green', 'Battle Dress Uniform (Fatigues) - Pants - Olive Green', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-pants-white-or-khaki', 'Battle Dress Uniform (Fatigues) - Pants - White or Khaki', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-shirt-tiger-stripe-camouflage', 'Battle Dress Uniform (Fatigues) - Shirt - Tiger Stripe Camouflage', 'heroes-unlimited', 'gear', 30, 'Shirts: 4 pockets', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-shirt-tree-bark-camouflage', 'Battle Dress Uniform (Fatigues) - Shirt - Tree Bark Camouflage', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-shirt-s-w-a-t-black', 'Battle Dress Uniform (Fatigues) - Shirt - S.W.A.T. Black', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-shirt-olive-green', 'Battle Dress Uniform (Fatigues) - Shirt - Olive Green', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-uniform-fatigues-shirt-white-or-khaki', 'Battle Dress Uniform (Fatigues) - Shirt - White or Khaki', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('military-field-jacket', 'Military Field Jacket', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'Includes adjustable collar and cuffs, epaulets, 4 large outer pockets with heavy brass zippers, hidden hood, waist cord and snap closures.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('reversible-flight-jacket-light', 'Reversible Flight Jacket - Light', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Comes in navy blue, grey, green and brown.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('extreme-cold-weather-flight-jacket', 'Extreme Cold Weather Flight Jacket', 'heroes-unlimited', 'gear', 100, NULL, NULL, NULL, NULL, NULL, 0, 'Heavy and insulated. Comes in navy blue, grey, green, brown and white.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-utility-lightweight', 'Battle Dress Utility - Lightweight', 'heroes-unlimited', 'gear', 65, NULL, NULL, NULL, NULL, NULL, 0, 'Shirt and pants in a choice of arctic, desert, jungle or autumn forest camouflage. The shirt has two breast pockets, one pen pocket and one left-side interior pocket; the pants are equipped with hip, butt and thigh pockets. The lightweight is for desert and jungle.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-utility-medium-weight', 'Battle Dress Utility - Medium Weight', 'heroes-unlimited', 'gear', 90, NULL, NULL, NULL, NULL, NULL, 0, 'The same shirt and pants in the medium weight, for forest and mountain.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-dress-utility-arctic-weight', 'Battle Dress Utility - Arctic Weight', 'heroes-unlimited', 'gear', 365, NULL, NULL, NULL, NULL, NULL, 0, 'The same shirt and pants down lined for arctic weight - more than five times the price of the lightweight.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('battle-jacket', 'Battle Jacket', 'heroes-unlimited', 'gear', 225, NULL, NULL, NULL, NULL, NULL, 0, 'Comes equipped with breast, hip and interior pockets on both sides. A hidden pocket on the inside of the back is also useful. Available in camouflage, khaki, green or black.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('arctic-parka', 'Arctic Parka', 'heroes-unlimited', 'gear', 450, NULL, NULL, NULL, NULL, NULL, 0, 'High quality down lining provides protection in sub-zero conditions. Same pocket arrangement as the Battle Jacket. Available in green and white only.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('wool-sweaters', 'Wool Sweaters', 'heroes-unlimited', 'gear', 150, NULL, NULL, NULL, NULL, NULL, 0, 'Finest British quality knit with leather reinforcements at shoulders, elbows and neck. Available in cream, green or black.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('ponchos', 'Ponchos', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, NULL, 0, 'Waterproof nylon, 5ft by 5ft square. Useful for rain protection, ground cover, an emergency tent and so on. Available in camouflage. The general purpose list on the same page prints a separate `Rain Poncho` at $30.00.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('camouflage-t-shirt', 'Camouflage T-Shirt', 'heroes-unlimited', 'gear', 8, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, closing the combat/hunting clothing.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('khaki-bush-shorts', 'Khaki Bush Shorts', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, closing the combat/hunting clothing.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('police-style-riot-helmet', 'Police Style Riot Helmet', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'With a ventilated transparent face shield.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('combat-helmet', 'Combat Helmet', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Complete with liner and camouflage cover.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('safari-hat', 'Safari Hat', 'heroes-unlimited', 'gear', 125, NULL, NULL, NULL, NULL, NULL, 0, 'A wide-brimmed hat perfect for shading the eyes in tropical sunlight and classy enough for an evening out on the town. Fasteners on each side for an easy ''Aussie style'' flip. Available in choices of camouflage, cream, green or khaki.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('utility-cap', 'Utility Cap', 'heroes-unlimited', 'gear', 14.5, '$14.50 - the only price on either page that is not a whole dollar', NULL, NULL, NULL, NULL, 0, 'A classic ''marine cover.'' Available in a choice of camouflage, green or khaki.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('beret', 'Beret', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'The classic wool beret. Available in green, black or jungle camouflage.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('bandanna', 'Bandanna', 'heroes-unlimited', 'gear', 5, NULL, NULL, NULL, NULL, NULL, 0, 'In a choice of colors.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('head-net', 'Head Net', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, NULL, 0, 'Covers hair and face, leaving only a slit for the eyes.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('camouflage-face-veil', 'Camouflage Face Veil', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('navy-style-face-mask', 'Navy Style Face Mask', 'heroes-unlimited', 'gear', 8, NULL, NULL, NULL, NULL, NULL, 0, 'Water and wind proof vinyl with a soft wool lining; mouth tab with snap closure.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('dancer-s-leotards', 'Dancer''s Leotards', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('speed-suit', 'Speed Suit', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, NULL, 0, 'Jumpsuit style. Trim cut, polyester/cotton fabric with one breast pocket and two front pockets. Used by race car drivers and pit crews.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('shop-service-coat', 'Shop Service Coat', 'heroes-unlimited', 'gear', 30, 'knee length, 4 pockets', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('turtleneck-shirt', 'Turtleneck Shirt', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('thermal-parka-hooded-sweat-shirt', 'Thermal Parka, Hooded Sweat Shirt', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('sweat-shirt', 'Sweat Shirt', 'heroes-unlimited', 'gear', 16, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flannel-shirt', 'Flannel Shirt', 'heroes-unlimited', 'gear', 14, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('t-shirt', 'T-Shirt', 'heroes-unlimited', 'gear', 6, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('dress-shirt', 'Dress Shirt', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('work-pants-hu', 'Work Pants', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('denim-jeans', 'Denim Jeans', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('coveralls-work', 'Coveralls - Work', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('coveralls-insulated', 'Coveralls - Insulated', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('work-apron-denim-3-pocket', 'Work Apron - Denim, 3 pocket', 'heroes-unlimited', 'gear', 12, 'the book prints the word as `pokcet`', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('machinist-s-apron-6-pocket', 'Machinist''s Apron - 6 pocket', 'heroes-unlimited', 'gear', 18, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('lab-coat', 'Lab Coat', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('windbreaker-jacket', 'Windbreaker Jacket', 'heroes-unlimited', 'gear', 18, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('light-lined-jacket', 'Light Lined Jacket', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('winter-jacket-waist-length', 'Winter Jacket - Waist Length', 'heroes-unlimited', 'gear', 55, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('winter-jacket-hip-length', 'Winter Jacket - Hip Length', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('reversible-hunting-parka', 'Reversible Hunting Parka', 'heroes-unlimited', 'gear', 70, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('insulated-survival-vest-6-pocket', 'Insulated Survival Vest - 6 pocket', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('survival-coat-insulated-4-big-pockets-and-hood', 'Survival Coat - Insulated - 4 big pockets and hood', 'heroes-unlimited', 'gear', 100, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('wool-cap', 'Wool Cap', 'heroes-unlimited', 'gear', 80, '$80.00 as printed, between a $100.00 survival coat and a $10.00 ski mask', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('winter-ski-mask', 'Winter Ski Mask', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('arctic-trooper-hat-with-fur-earflaps', 'Arctic Trooper Hat with Fur Earflaps', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('work-gloves', 'Work Gloves', 'heroes-unlimited', 'gear', 4, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('leather-racing-gloves', 'Leather Racing Gloves', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('dress-winter-gloves', 'Dress Winter Gloves', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('heavy-winter-gloves', 'Heavy Winter Gloves', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('wool-mittens', 'Wool Mittens', 'heroes-unlimited', 'gear', 14, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('leather-chopper-mitts', 'Leather Chopper Mitts', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('lectra-mitts', 'Lectra-Mitts', 'heroes-unlimited', 'gear', 30, 'the book''s line reads `Lectra-Mitts - Warmest Hand Protection Possible`', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tennis-shoes', 'Tennis Shoes', 'heroes-unlimited', 'gear', 16, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('running-shoes', 'Running Shoes', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('work-shoes', 'Work Shoes', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('dress-shoes-boots', 'Dress Shoes/Boots', 'heroes-unlimited', 'gear', 80, '$80 and up - the book prints `$80+`', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('steel-toe-shoes', 'Steel Toe Shoes', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('steel-toe-boots', 'Steel Toe Boots', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('work-boots', 'Work Boots', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('waterproof-hunter-s-boots', 'Waterproof Hunter''s Boots', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('high-quality-hunter-woodsman-insulated-boot', 'High Quality Hunter/Woodsman, insulated boot', 'heroes-unlimited', 'gear', 140, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('waterproof-rubber-boots-ankle-high', 'Waterproof Rubber Boots - Ankle High', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('waterproof-rubber-boots-hip-high', 'Waterproof Rubber Boots - Hip High', 'heroes-unlimited', 'gear', 50, 'the book prints this one as `50.00` with NO dollar sign, on a continuation line under Ankle High', NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rain-poncho', 'Rain Poncho', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('raincoat', 'Raincoat', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rain-suit-coat-pants', 'Rain Suit - Coat & Pants', 'heroes-unlimited', 'gear', 45, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rain-hat', 'Rain Hat', 'heroes-unlimited', 'gear', 8, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('hard-hat', 'Hard Hat', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('sport-caps', 'Sport Caps', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('baseball-cap', 'Baseball Cap', 'heroes-unlimited', 'gear', 8, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('hat-short-brim-hu', 'Hat - Short Brim', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('hat-large-brim-hu', 'Hat - Large Brim', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('hat-leather-large-brim', 'Hat - Leather, large brim', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 220, the CLOTHES: GENERAL PURPOSE price list.', 'Revised Heroes Unlimited p.220');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cape-short-hu', 'Cape - Short', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cape-long-hu', 'Cape - Long', 'heroes-unlimited', 'gear', 150, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cape-long-and-hooded', 'Cape - Long and Hooded', 'heroes-unlimited', 'gear', 175, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('robe-light-hu', 'Robe - Light', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('robe-heavy-hu', 'Robe - Heavy', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('robe-hooded-hu', 'Robe - Hooded', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('bathrobe', 'Bathrobe', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-jacket', 'Security Guard Uniform - Jacket', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-shirt', 'Security Guard Uniform - Shirt', 'heroes-unlimited', 'gear', 18, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-tie', 'Security Guard Uniform - Tie', 'heroes-unlimited', 'gear', 4, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-trousers', 'Security Guard Uniform - Trousers', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-regulation-hat', 'Security Guard Uniform - Regulation Hat', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-trouser-belt', 'Security Guard Uniform - Trouser Belt', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-belt-and-holster', 'Security Guard Uniform - Belt and Holster', 'heroes-unlimited', 'gear', 60, 'the book''s line reads `Traditional belt and holster with 28 bullet loops`', NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, weight_lbs, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('security-guard-uniform-badge-and-i-d-pocket-case', 'Security Guard Uniform - Badge and I.D. Pocket Case', 'heroes-unlimited', 'gear', 18, NULL, NULL, NULL, NULL, NULL, 0, 'Printed 221, closing the clothing lists. The book''s note on this page: generally DOUBLE OR TRIPLE the price for fancy or dress articles, and multiply the price by TEN TIMES or more for custom-made articles. The security guard uniform is usually navy blue or brown.', 'Revised Heroes Unlimited p.221');

-- ASSERTIONS.

SELECT 'all one hundred and forty-six rows landed' AS assertion, count(*) AS got, 146 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.219', 'Revised Heroes Unlimited p.220',
                                  'Revised Heroes Unlimited p.221');

SELECT 'forty-seven from printed 219' AS assertion, count(*) AS got, 47 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.219';
SELECT 'eighty-four from printed 220' AS assertion, count(*) AS got, 84 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.220';
SELECT 'and fifteen from printed 221, above the vehicles' AS assertion, count(*) AS got, 15 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.221';

SELECT 'every one is Heroes Unlimited gear' AS assertion, count(*) AS got, 146 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.219', 'Revised Heroes Unlimited p.220',
                                  'Revised Heroes Unlimited p.221')
   AND system = 'heroes-unlimited' AND category = 'gear';

-- EVERY ROW CARRIES A PRICE. Both pages price everything they print, so a NULL
-- here means a row lost its figure rather than that the book withheld one.
SELECT 'every row carries its printed price' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.219', 'Revised Heroes Unlimited p.220',
                                  'Revised Heroes Unlimited p.221')
   AND cost IS NULL;

-- THE TWO THE PARSER LOST OUTRIGHT.
SELECT 'the tape recorder kept the price its wrap separated' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Tape Recorder' AND cost = 100;
SELECT 'the hip high rubber boots are a row, unsigned price and all' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Waterproof Rubber Boots - Hip High' AND cost = 50;
SELECT 'and the ankle high pair it hides under is still here' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Waterproof Rubber Boots - Ankle High' AND cost = 20;

-- THE COLOUR VARIANTS CARRY THEIR PARENT. Eighteen rows, and the four parents
-- are distinguishable rather than collapsing into repeated colour words.
SELECT 'eighteen colour variants name their parent' AS assertion, count(*) AS got, 18 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.219', 'Revised Heroes Unlimited p.220')
   AND (instr(name, 'Camouflage Coveralls - ') > 0 OR instr(name, 'Battle Dress Uniform') > 0);
SELECT 'the heavy coveralls are four rows at four prices' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE instr(name, 'Heavy Camouflage Coveralls - ') > 0 AND cost IN (80, 85, 75);
SELECT 'the fatigues are five pants and five shirts' AS assertion, count(*) AS got, 10 AS want
  FROM gear WHERE instr(name, 'Battle Dress Uniform (Fatigues)') > 0;
SELECT 'and the two tiger stripe rows at thirty dollars are told apart' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Battle Dress Uniform (Fatigues) - Pants - Tiger Stripe Camouflage',
                           'Battle Dress Uniform (Fatigues) - Shirt - Tiger Stripe Camouflage')
   AND cost = 30;

-- THE ACIDS, priced per HALF gallon rather than the cache's `4 gallon`.
SELECT 'four acids landed' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE name IN ('Organic Acid', 'Organic Acid (concentrated)', 'Cleanser', 'Metal Dissolver')
   AND source_book = 'Revised Heroes Unlimited p.219';
SELECT 'and every one of them says half gallon' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE name IN ('Organic Acid', 'Organic Acid (concentrated)', 'Cleanser', 'Metal Dissolver')
   AND source_book = 'Revised Heroes Unlimited p.219' AND instr(cost_note, 'half gallon') > 0;
SELECT 'the two organics keep the book''s I and II labels' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Organic Acid', 'Organic Acid (concentrated)')
   AND (instr(cost_note, 'Organic I') > 0 OR instr(cost_note, 'Organic II') > 0);
SELECT 'and each acid carries the damage it does' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE name IN ('Organic Acid', 'Organic Acid (concentrated)', 'Cleanser', 'Metal Dissolver')
   AND source_book = 'Revised Heroes Unlimited p.219' AND damage IS NOT NULL;

-- THE THREE BATTLE DRESS UTILITY WEIGHTS, one paragraph in the book.
SELECT 'three battle dress utility weights at three prices' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE instr(name, 'Battle Dress Utility - ') > 0 AND cost IN (65, 90, 365);

-- THE TWO PAIRS THAT ARE NOT DUPLICATES.
SELECT 'both goggles rows are here at their own prices' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Protective Goggles', 'Protective Goggles or Tinted Visor')
   AND cost IN (10, 20) AND source_book = 'Revised Heroes Unlimited p.219';
SELECT 'and both ponchos' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Ponchos', 'Rain Poncho') AND cost IN (30, 35)
   AND source_book = 'Revised Heroes Unlimited p.220';

-- THE NUMBERS THAT LAND IN THEIR OWN COLUMNS.
SELECT 'the jet pack keeps its S.D.C.' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Jet Pack' AND sdc = 100 AND cost = 80000;
SELECT 'the padded helmet keeps its A.R.' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Padded Helmet' AND ar = 10;
SELECT 'the ration crate keeps its shipping weight' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Rations' AND weight_lbs = 200 AND cost = 470;
SELECT 'the utility cap keeps its half dollar' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Utility Cap' AND cost = 14.5;

-- TEXT CHECKS, because batch C passed every count while every string in it was
-- mangled - a fold had replaced the letter s throughout.
SELECT 'the police jumpsuit description survived' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Police Style Jumpsuit' AND instr(description, 'bi-swing pleated back') > 0;
SELECT 'the safari hat kept its Aussie style flip' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Safari Hat' AND instr(description, 'Aussie style') > 0;
SELECT 'and the wool sweaters kept their s letters' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Wool Sweaters' AND instr(description, 'reinforcements at shoulders') > 0;

-- PRINTED 221, the clothing tail that sits above CONVENTIONAL VEHICLES.
SELECT 'the security guard uniform is eight rows' AS assertion, count(*) AS got, 8 AS want
  FROM gear WHERE instr(name, 'Security Guard Uniform - ') > 0;
SELECT 'including the belt and holster the cache read as `28 bullet whet`' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Security Guard Uniform - Belt and Holster' AND cost = 60
   AND instr(cost_note, '28 bullet loops') > 0;
SELECT 'three capes and three robes, each on its own slug' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.221'
   AND (instr(name, 'Cape - ') > 0 OR instr(name, 'Robe - ') > 0);
SELECT 'and every row from that page carries the fancy/custom pricing note' AS assertion, count(*) AS got, 15 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.221'
   AND instr(description, 'TEN TIMES') > 0;

-- THE SLUG THAT STARTED THE REBUILD DIVERGENCE. This file's generator reads
-- catalog_redirects as well as gear, so nothing here can land on a retired key.
SELECT 'no row in this batch sits on a retired slug' AS assertion, count(*) AS got, 0 AS want
  FROM gear g JOIN catalog_redirects r ON r.catalog = 'gear' AND r.from_key = g.slug
 WHERE g.source_book IN ('Revised Heroes Unlimited p.219', 'Revised Heroes Unlimited p.220',
                         'Revised Heroes Unlimited p.221');

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-h-acids-and-clothing.sql');
