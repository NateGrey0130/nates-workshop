-- Heroes Unlimited's lock picking tools, field equipment, containers and
-- miscellaneous equipment. Printed 217-218. One hundred and twenty-nine rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-g-field-and-containers.sql
--
-- ===================================================================
-- WHY THIS FILE IS TRANSCRIBED AND NOT GENERATED
-- ===================================================================
--
-- These two pages are mostly two-column PRICE LISTS - one item per line with the
-- price at the end - which look ideal for a parser and are not. A parser over
-- them returned 98 rows, and its failures were not the kind that announce
-- themselves:
--
--   * `will cost about $25.00` became an item name. It is the tail of the Car
--     Openers sentence.
--   * `Lock File: Costs about $10 - $15` was split down the middle, the name
--     taking the first figure and the price the second.
--   * `camouflage, green or khaki) $400` was stranded from the Military Command
--     Post tent whose line it wraps.
--   * The MEDIUM climbing platform was dropped entirely, because the book prints
--     its price as `60.00` with NO DOLLAR SIGN - between a $40.00 and an $80.00.
--     Confirmed on a 240 dpi render: that is the page, not the cache.
--
-- So every row here was read off renders of both pages and written out by hand.
--
-- ===================================================================
-- TWO ENTRIES, ONE PRICE, AND THEY ARE NOT A DUPLICATE
-- ===================================================================
--
-- `Full Rappelling Equipment` closes the field equipment list on printed 217 at
-- $1100.00. `Climbing Kit` opens the miscellaneous equipment on printed 218, is
-- also $1100.00, and lists COMPLETELY DIFFERENT CONTENTS - 3,600ft reels of 4500
-- test rope, 48 clamps, 48 fasteners, 48 pitons, 3 hammers, 2 grappling hooks
-- and a pulley, at 190lbs with the crate. Both were read off renders of their
-- own page before either was written. Identical numbers are not evidence of a
-- duplicate, and each row says so and names the other.
--
-- ===================================================================
-- FRACTIONS THE OCR CANNOT READ
-- ===================================================================
--
-- The containers list is full of them and the cache mangles every one:
-- `Waterskin - '4 gallon`, `Jar, Glass - | pint`, `Trunk, Large Wood - S0lbs`.
-- A 240 dpi render settles them as half a gallon, one pint and 50lbs. Written
-- out in words here - `half gallon`, `1 gallon` - because a fraction glyph is
-- exactly what does not survive a round trip through this cache.
--
-- ONE PRICE LOOKS WRONG AND IS NOT. `Jar - 2 pints` at $2.00 is cheaper than
-- `Jar, Glass - 1 pint` at $4.00. They are different materials, which is what
-- makes the two prices consistent; the row says so rather than leaving a reader
-- to assume a transposition.
--
-- ===================================================================
-- WHAT FILLS `sdc`, AND WHAT FILLS `ar`
-- ===================================================================
--
-- Sixteen rows carry an S.D.C. the book prints for them: the trunks, security
-- boxes, safes, padlocks and handcuffs are all things a character breaks INTO,
-- so their S.D.C. is the number that matters at a table. Two rows carry an A.R.
-- as well - the Bullet Resistant Attache Case at A.R. 15 / S.D.C. 140 and the
-- Courier Briefcase at A.R. 11 / S.D.C. 90 - which is the first time in this
-- book's import that anything outside the body armour table has one.
--
-- ===================================================================
-- ONE HEADING, SEVERAL PRICES - STILL
-- ===================================================================
--
--   Old Stand-Bys        -> cross bar $12, drill $25, bolt cutters $80
--   Automatic Lock Pick  -> $60 to law enforcement, $120 MINIMUM on the street
--                           with a 19% chance of being attainable at all
--   Electro-Adhesive Pad -> pads and generator $40,000, shoe form $50,000
--   Rechargeable torch   -> $130 at 20,000 candle power, $160 at 35,000
--   Professional Medical Kit -> $200 as issued, and $1500 on the OPEN MARKET
--                           WITHOUT the drugs, which is the more expensive of
--                           the two and is its own row
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('mini-flashlight', 'Mini Flashlight', 'heroes-unlimited', 'gear', 9, NULL, NULL, NULL, NULL, 0, 'Overall length 4.5 by 0.75 inches, running on two AA batteries; twist the lens to turn it on. The entry begins on printed 216 and its price is on 217.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('8-inch-bowie-style-survival-blade', '8 inch Bowie-style Survival Blade', 'heroes-unlimited', 'gear', 150, NULL, NULL, NULL, NULL, 0, 'With chisel tooth saw, jewelled compass, sheath and belt clip.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('underwater-specimen-bag', 'Underwater Specimen Bag', 'heroes-unlimited', 'gear', 16, NULL, NULL, NULL, NULL, 0, 'A drawstring pouch with a shoulder belt.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('head-mounted-light', 'Head Mounted Light', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 217, with the underwater equipment.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('lock-pick', 'Lock Pick', 'heroes-unlimited', 'gear', 4, '$4 per pick, and the book says at least a dozen are needed', NULL, NULL, NULL, 0, 'A small thin steel tool ending in a slight upward curve or special tip, used to raise the pins of a lock. A good range of thickness is .025-.035, and AT LEAST A DOZEN are needed for a proper range. Generally 3.5 to 4.5 inches long. Smiths and suppliers will not usually sell these off the street and may investigate or report the inquiry, though they are available by mail order.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tension-bar', 'Tension Bar', 'heroes-unlimited', 'gear', 30, '$30 each. As contraband the price may be as much as 200% higher, and buying from a locksmith may require a bribe', NULL, NULL, NULL, 0, 'An L-shaped tool of the same clock spring steel as the pick, required alongside it to open a lock; it manipulates the position of the locking pins.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('basic-lock-pick-set', 'Basic Lock Pick Set', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, 0, 'One tension bar, a key extractor and 9 lock picking tools.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('superior-lock-pick-set', 'Superior Lock Pick Set', 'heroes-unlimited', 'gear', 90, NULL, NULL, NULL, NULL, 0, '32 high quality lock picks, a bar, tension tools and extractors.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('automatic-lock-pick-release-gun', 'Automatic Lock Pick (Release Gun)', 'heroes-unlimited', 'gear', 60, '$60 sold to law enforcement agencies. ON THE STREET it is $120 MINIMUM with only a 19% chance of being attainable at all, and may cost as much as 200% more depending on the seller', NULL, NULL, NULL, 0, 'Throws all the pins into position at once and never damages the lock. Opens tumbler, spool, regular and mushroom locks.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('car-openers', 'Car Openers', 'heroes-unlimited', 'gear', 25, 'about $25.00 for a set', NULL, NULL, NULL, 0, 'A variety of window prying tools, fairly easy to find, buy or construct.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cross-bar', 'Cross Bar', 'heroes-unlimited', 'gear', 12, NULL, NULL, NULL, NULL, 0, 'Sheer force, under the book''s Old Stand-Bys heading on printed 217.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('drill-lock-breaking', 'Drill (lock breaking)', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, 0, 'Sheer force, under the book''s Old Stand-Bys heading on printed 217.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('bolt-cutters', 'Bolt Cutters', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, 0, 'Good for shearing chains, cables and padlocks. Under the book''s Old Stand-Bys heading.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('key-blanks', 'Key Blanks', 'heroes-unlimited', 'gear', 30, '$30 per blank on average; the book notes blanks are expensive because they must be obtained the same way as the picks', NULL, NULL, NULL, 0, 'A variety of blank key types for making key impressions: insert the blank, turn it side to side, and the tumblers mark it against the carbon or boot black agent; file, reinsert and repeat. SIX INSERTIONS are required and the player rolls under their lock pick skill for each - one failure botches the whole job, and the process takes 15 to 20 minutes.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('lock-file', 'Lock File', 'heroes-unlimited', 'gear', 10, '$10-$15', NULL, NULL, NULL, 0, 'Printed 217.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('back-pack-small', 'Back Pack - Small', 'heroes-unlimited', 'gear', 120, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('back-pack-large', 'Back Pack - Large', 'heroes-unlimited', 'gear', 210, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('canteen-plastic-hu', 'Canteen: Plastic', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('canteen-aluminum-hu', 'Canteen: Aluminum', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('compass-hu', 'Compass', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('disposable-lighter', 'Disposable Lighter', 'heroes-unlimited', 'gear', 1, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-hu', 'Flashlight', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('insect-repellent', 'Insect Repellent', 'heroes-unlimited', 'gear', 4, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('knife-small-hu', 'Knife: Small', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('knife-large-hu', 'Knife: Large', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('knife-survival', 'Knife: Survival', 'heroes-unlimited', 'gear', 120, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rope-per-20ft', 'Rope - Per 20ft', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rope-ladder-per-10ft-3m', 'Rope Ladder - Per 10ft/3m', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('light-chain-per-foot', 'Light Chain - Per foot', 'heroes-unlimited', 'gear', 2, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('heavy-chain-per-foot', 'Heavy Chain - Per foot', 'heroes-unlimited', 'gear', 6, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tent-one-man-hu', 'Tent - One Man', 'heroes-unlimited', 'gear', 110, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tent-two-man-hu', 'Tent - Two Man', 'heroes-unlimited', 'gear', 180, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tent-four-man', 'Tent - Four Man', 'heroes-unlimited', 'gear', 260, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tent-military-command-post', 'Tent - Military Command Post', 'heroes-unlimited', 'gear', 400, NULL, NULL, NULL, NULL, 0, '25lbs, an 8 by 8ft floor and a 5ft ceiling, in camouflage, green or khaki.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tent-canvas-per-sq-yard-meter', 'Tent Canvas - Per sq yard/meter', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('mosquito-netting-per-sq-yard-meter', 'Mosquito Netting - Per sq yard/meter', 'heroes-unlimited', 'gear', 12, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('hammock', 'Hammock', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('sleeping-bag-hu', 'Sleeping Bag', 'heroes-unlimited', 'gear', 150, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('blanket-light-hu', 'Blanket - Light', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('blanket-heavy-hu', 'Blanket - Heavy', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('pillow', 'Pillow', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('utensil-kit', 'Utensil Kit', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, 0, 'Knife, fork and spoon set with sheath.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tackle-box', 'Tackle Box', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('bow-hunter-accessory-bag', 'Bow Hunter Accessory Bag', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('fishing-rod-and-reel', 'Fishing Rod and Reel', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('fishing-net', 'Fishing Net', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('snare-cord-per-sq-yard-meter', 'Snare Cord - Per sq yard/meter', 'heroes-unlimited', 'gear', 5, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('beaver-trap', 'Beaver Trap', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rabbit-trap', 'Rabbit Trap', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('bear-trap', 'Bear Trap', 'heroes-unlimited', 'gear', 180, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('wolf-trap', 'Wolf Trap', 'heroes-unlimited', 'gear', 160, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('fishing-line-per-50ft', 'Fishing Line - Per 50ft', 'heroes-unlimited', 'gear', 5, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('climbing-platform-small', 'Climbing Platform - Small', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, 0, 'A 16 by 19in platform with a 200lb capacity. Used by deer hunters to climb and stand in trees, getting above the line of sight and reducing the chance of being scented. Portable, 100% high carbon steel.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('climbing-platform-medium', 'Climbing Platform - Medium', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, 0, 'A 17 by 24in platform with a 250lb capacity. PRINTED 217 GIVES THIS ROW''S PRICE AS 60.00 WITH NO DOLLAR SIGN - confirmed on a 240 dpi render, so it is the book and not the OCR. It sits between $40.00 and $80.00 and is read as $60.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('climbing-platform-heavy', 'Climbing Platform - Heavy', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, 0, 'A 20 by 26in platform with a 1000lb capacity.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('grappling-hook-and-line-250ft', 'Grappling Hook and Line - 250ft', 'heroes-unlimited', 'gear', 80, NULL, NULL, NULL, NULL, 0, 'Printed 217, the FIELD EQUIPMENT price list (Hunting, Trapping, Camping).', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('full-rappelling-equipment', 'Full Rappelling Equipment', 'heroes-unlimited', 'gear', 1100, NULL, NULL, NULL, NULL, 0, 'Spikes, mallet, hooks, pulley, straps, harness, gloves, boots, black pack and so on. NOT the same entry as the Climbing Kit on printed 218, which is also $1100 and lists different contents; the two sit on facing pages and identical numbers are not evidence of a duplicate.', 'Revised Heroes Unlimited p.217');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('saddlebag-horse', 'Saddlebag (horse)', 'heroes-unlimited', 'gear', 100, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('small-pocket-purse-hu', 'Small Pocket Purse', 'heroes-unlimited', 'gear', 5, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('belt-purse', 'Belt Purse', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Attaches to a belt.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('shoulder-purse-small-hu', 'Shoulder Purse - Small', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('shoulder-purse-large-hu', 'Shoulder Purse - Large', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('small-sack-hu', 'Small Sack', 'heroes-unlimited', 'gear', 6, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('large-sack-hu', 'Large Sack', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('knapsack-hu', 'Knapsack', 'heroes-unlimited', 'gear', 25, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
-- `back-pack-hu`, NOT `back-pack`. That slug is absent from the gear table and
-- is NOT free: merge-backpack-duplicate.sql retired it into `backpack` and left
-- a catalog_redirects row behind, and that file sorts AFTER this one - so a row
-- spelled `back-pack` here is created and then DELETED again on every clean
-- rebuild. It was, until 2026-09-14: production carried the row while a clean
-- build produced 2009 gear rows against production's 2010, and the only thing
-- that said so was a count that did not name a row.
VALUES ('back-pack-hu', 'Back Pack', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cloth-handle-bag-hu', 'Cloth Handle Bag', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('tobacco-pouch-hu', 'Tobacco Pouch', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('waterskin-2-pints', 'Waterskin - 2 pints', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('waterskin-half-gallon', 'Waterskin - half gallon', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('waterskin-1-gallon', 'Waterskin - 1 gallon', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cask-wooden-4-gallons', 'Cask, Wooden - 4 gallons', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cask-wooden-10-gallons', 'Cask, Wooden - 10 gallons', 'heroes-unlimited', 'gear', 40, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('cask-wooden-25-gallons', 'Cask, Wooden - 25 gallons', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('vial-glass-2-ounce-hu', 'Vial, Glass - 2 ounce', 'heroes-unlimited', 'gear', 4, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jar-glass-1-pint-hu', 'Jar, Glass - 1 pint', 'heroes-unlimited', 'gear', 4, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jar-2-pints-hu', 'Jar - 2 pints', 'heroes-unlimited', 'gear', 2, NULL, NULL, NULL, NULL, 0, 'Printed 218 prices this BELOW the 1 pint glass jar above it. The glass jar is a different material, which is what makes the two prices consistent rather than a misreading.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jar-4-pints-hu', 'Jar - 4 pints', 'heroes-unlimited', 'gear', 4, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jar-1-gallon', 'Jar - 1 gallon', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jug-half-gallon', 'Jug - half gallon', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jug-1-gallon-hu', 'Jug - 1 gallon', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('jug-5-gallons-hu', 'Jug - 5 gallons', 'heroes-unlimited', 'gear', 60, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('small-wood-crate', 'Small Wood Crate', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('medium-wood-crate', 'Medium Wood Crate', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('large-wood-crate', 'Large Wood Crate', 'heroes-unlimited', 'gear', 50, NULL, NULL, NULL, NULL, 0, 'Printed 218, the CONTAINERS price list.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('trunk-small-wood', 'Trunk, Small Wood', 'heroes-unlimited', 'gear', 80, NULL, NULL, 30, NULL, 0, '25lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('trunk-large-wood', 'Trunk, Large Wood', 'heroes-unlimited', 'gear', 200, NULL, NULL, 70, NULL, 0, '50lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('small-metal-security-box', 'Small Metal Security Box', 'heroes-unlimited', 'gear', 40, NULL, NULL, 30, NULL, 0, '5lb.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('large-metal-security-box', 'Large Metal Security Box', 'heroes-unlimited', 'gear', 80, NULL, NULL, 90, NULL, 0, '15lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('metal-trunk-small', 'Metal Trunk, Small', 'heroes-unlimited', 'gear', 250, NULL, NULL, 100, NULL, 0, '35lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('metal-trunk-large', 'Metal Trunk, Large', 'heroes-unlimited', 'gear', 500, NULL, NULL, 200, NULL, 0, '80lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('small-safe', 'Small Safe', 'heroes-unlimited', 'gear', 900, NULL, NULL, 350, NULL, 0, '50lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('large-safe', 'Large Safe', 'heroes-unlimited', 'gear', 2000, NULL, NULL, 1000, NULL, 0, '300lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-small', 'Flashlight - Small', 'heroes-unlimited', 'gear', 5, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-medium', 'Flashlight - Medium', 'heroes-unlimited', 'gear', 10, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-large-hu', 'Flashlight - Large', 'heroes-unlimited', 'gear', 15, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-unbreakable-kel-lite-small', 'Flashlight - Unbreakable (Kel-lite), Small', 'heroes-unlimited', 'gear', 24, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-unbreakable-kel-lite-medium', 'Flashlight - Unbreakable (Kel-lite), Medium', 'heroes-unlimited', 'gear', 28, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-unbreakable-kel-lite-large', 'Flashlight - Unbreakable (Kel-lite), Large', 'heroes-unlimited', 'gear', 32, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('flashlight-unbreakable-kel-lite-very-large', 'Flashlight - Unbreakable (Kel-lite), Very Large', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('portable-halogen-spotlight', 'Portable Halogen Spotlight', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, '50,000 candle power.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('treated-torch', 'Treated Torch', 'heroes-unlimited', 'gear', 8, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('candle-stick-per-dozen', 'Candle Stick - Per Dozen', 'heroes-unlimited', 'gear', 8, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('oil-lantern-6-hours-1-pint-hu', 'Oil Lantern - 6 hours/1 pint', 'heroes-unlimited', 'gear', 20, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('oil-lantern-12-hours-2-pints', 'Oil Lantern - 12 hours/2 pints', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('oil-lamp-6-hours', 'Oil Lamp - 6 hours', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('padlock-light', 'Padlock - Light', 'heroes-unlimited', 'gear', 5, NULL, NULL, 25, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('padlock-medium', 'Padlock - Medium', 'heroes-unlimited', 'gear', 8, NULL, NULL, 50, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('padlock-heavy', 'Padlock - Heavy', 'heroes-unlimited', 'gear', 15, NULL, NULL, 75, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('padlock-burglar-proof', 'Padlock - Burglar proof', 'heroes-unlimited', 'gear', 30, NULL, NULL, 80, NULL, 0, '60% chance to be picked.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('handcuffs-regular', 'Handcuffs - Regular', 'heroes-unlimited', 'gear', 25, NULL, NULL, 60, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('handcuffs-heavy', 'Handcuffs - Heavy', 'heroes-unlimited', 'gear', 50, NULL, NULL, 120, NULL, 0, 'Printed 218, among the miscellaneous equipment price lines.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rechargeable-unbreakable-flashlight-20-000-candle-power', 'Rechargeable Unbreakable Flashlight (20,000 candle power)', 'heroes-unlimited', 'gear', 130, NULL, NULL, NULL, NULL, 0, 'Ten times brighter than most conventional types, with a quartz-halogen bulb. 12 inches (0.3m), 1.8lbs.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('rechargeable-unbreakable-flashlight-35-000-candle-power', 'Rechargeable Unbreakable Flashlight (35,000 candle power)', 'heroes-unlimited', 'gear', 160, NULL, NULL, NULL, NULL, 0, 'The brighter version of the rechargeable unbreakable flashlight, priced separately on printed 218.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('bullet-resistant-attache-case', 'Bullet Resistant Attache Case', 'heroes-unlimited', 'gear', 440, NULL, 15, 140, NULL, 0, 'Printed 218.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('courier-briefcase', 'Courier Briefcase', 'heroes-unlimited', 'gear', 225, NULL, 11, 90, NULL, 0, 'Printed 218.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('acoustic-noise-generator-hu', 'Acoustic Noise Generator', 'heroes-unlimited', 'gear', 900, NULL, NULL, NULL, NULL, 0, 'Muffles conversations and distorts bugging systems by 30%.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('camouflage-paint-kit', 'Camouflage Paint Kit', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, 0, 'Four spray cans and six stencils for camouflaging vehicles, bunkers and field equipment. One kit covers approximately 100 square feet. Jungle, forest or arctic.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('camouflage-tape', 'Camouflage Tape', 'heroes-unlimited', 'gear', 6, '$6.00 per roll', NULL, NULL, NULL, 0, 'Duct tape in rolls 26ft long and two inches wide, in jungle, forest or desert camouflage or olive drab.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('camouflage-compact', 'Camouflage Compact', 'heroes-unlimited', 'gear', 18, '$18.00 each', NULL, NULL, NULL, 0, 'A one-man kit for camouflage or night operations with face and hand paint for 6 applications, a mirror, brush and disposable cleaning pads, in a black case 4 inches across and half an inch high.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('climbing-kit', 'Climbing Kit', 'heroes-unlimited', 'gear', 1100, NULL, NULL, NULL, NULL, 0, 'A complete set for rappelling, rock scaling or climbing: 3,600ft reels of 4500 test rope at 40lbs a reel, an adjustable harness with clamps, 6 pairs of canvas climbing gloves, 48 clamps, 48 fasteners, 48 pitons, 3 hammers, 2 grappling hooks and one pulley. Weight with the shipping crate is 190lbs. NOT the same entry as Full Rappelling Equipment on printed 217, which is also $1100 and lists different contents.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('ear-protector-headphones', 'Ear Protector Headphones', 'heroes-unlimited', 'gear', 35, NULL, NULL, NULL, NULL, 0, 'The answer to the demolitions expert''s and grenadier''s dreams; the same model airport workers use to preserve hearing.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('electro-adhesive-pads-and-generator', 'Electro-Adhesive Pads and Generator', 'heroes-unlimited', 'gear', 40000, '$40,000 for the two pads and the hip or back-pack generator; not commonly available', NULL, NULL, NULL, 0, 'A hand-held device that adheres strongly to any metal surface by passing a small current through two metal electrodes. Commonly used by astronauts in shoe form, but the hand-held pads are more flexible and generally preferred. Holds up to 1000lbs and WORKS ONLY ON METAL.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('electro-adhesive-shoes', 'Electro-Adhesive Shoes', 'heroes-unlimited', 'gear', 50000, '$50,000; not commonly available', NULL, NULL, NULL, 0, 'The shoe form of the electro-adhesive pad, priced separately on printed 218. Holds up to 1000lbs and works only on metal.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('medical-bag-hu', 'Medical Bag', 'heroes-unlimited', 'gear', 275, NULL, NULL, NULL, NULL, 0, 'An 8lb complete medic''s field kit: adhesive pads, bandages, gauze, adhesive tape, splints, sterile gloves, scissors, forceps, thermometer, needle, razor blades, pins, medicine, ointment and salt tablets. Back pack and shoulder straps, in camouflage, green or khaki.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('professional-medical-kit', 'Professional Medical Kit', 'heroes-unlimited', 'gear', 200, NULL, NULL, NULL, NULL, 0, 'A comprehensive first aid kit with six doses each of antibiotics, anti-inflammatories, sedatives and painkillers, an assorted mini-instrument pack of a dozen scalpels, scissors and probes, tape, bandages, sutures and four air filters.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('professional-medical-kit-open-market-without-drugs', 'Professional Medical Kit (open market, without drugs)', 'heroes-unlimited', 'gear', 1500, NULL, NULL, NULL, NULL, 0, 'The same kit WITHOUT the drugs, which is the form printed 218 says is available on the open market - and it costs more than seven times the $200 version with them.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('machete', 'Machete', 'heroes-unlimited', 'gear', 30, NULL, NULL, NULL, '1D6', 0, 'Complete with canvas sheath.', 'Revised Heroes Unlimited p.218');
INSERT OR IGNORE INTO gear (slug, name, system, category, cost, cost_note, ar, sdc, damage, is_mega_damage, description, source_book)
VALUES ('wirecutters', 'Wirecutters', 'heroes-unlimited', 'gear', 65, NULL, NULL, NULL, NULL, 0, 'An 8 inch wirecutter with nonconducting handles to avoid the shock of electrified fences. Complete with belt sheath.', 'Revised Heroes Unlimited p.218');

-- ASSERTIONS.

SELECT 'all one hundred and twenty-nine rows landed' AS assertion, count(*) AS got, 129 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.217', 'Revised Heroes Unlimited p.218');

SELECT 'fifty-seven from printed 217' AS assertion, count(*) AS got, 57 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.217';
SELECT 'seventy-two from printed 218' AS assertion, count(*) AS got, 72 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.218';

SELECT 'every one is Heroes Unlimited gear' AS assertion, count(*) AS got, 129 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.217', 'Revised Heroes Unlimited p.218')
   AND system = 'heroes-unlimited' AND category = 'gear';

-- EVERY ROW CARRIES A PRICE. Both pages are price lists, so a NULL cost here
-- means a row lost its figure rather than that the book withheld one.
SELECT 'every row carries its printed price' AS assertion, count(*) AS got, 0 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.217', 'Revised Heroes Unlimited p.218')
   AND cost IS NULL;

-- THE FOUR THE PARSER GOT WRONG. Each is named, because each is the reason this
-- file was transcribed, and a re-extraction that repeats one would otherwise
-- look clean.
SELECT 'the car openers are an item, not a sentence fragment' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Car Openers' AND cost = 25;
SELECT 'the lock file kept its name and its low price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Lock File' AND cost = 10 AND instr(cost_note, '15') > 0;
SELECT 'the command post tent is one row at $400' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Tent - Military Command Post' AND cost = 400;
SELECT 'all three climbing platforms are here' AS assertion, count(*) AS got, 3 AS want
  FROM gear WHERE instr(name, 'Climbing Platform') > 0 AND cost IN (40, 60, 80);
SELECT 'and the medium one the book left unsigned is $60' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Climbing Platform - Medium' AND cost = 60;

-- THE TWO $1100 ENTRIES ARE TWO ROWS.
SELECT 'the rappelling kit and the climbing kit are separate' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Full Rappelling Equipment', 'Climbing Kit') AND cost = 1100;
SELECT 'and they sit on different pages' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE (name = 'Full Rappelling Equipment' AND source_book = 'Revised Heroes Unlimited p.217')
     OR (name = 'Climbing Kit' AND source_book = 'Revised Heroes Unlimited p.218');

-- THE FRACTIONS, written out in words because the glyphs do not survive.
SELECT 'the half-gallon vessels are here' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Waterskin - half gallon', 'Jug - half gallon') AND cost IN (30, 20);
SELECT 'and the glass pint jar costs more than the two-pint one' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Jar, Glass - 1 pint', 'Jar - 2 pints') AND cost IN (4, 2);

-- S.D.C. AND A.R. Sixteen rows carry an S.D.C. the book prints; two carry an
-- A.R. as well, and they are the first outside the armour table to do so.
SELECT 'sixteen rows carry an S.D.C.' AS assertion, count(*) AS got, 16 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.217', 'Revised Heroes Unlimited p.218')
   AND sdc IS NOT NULL;
SELECT 'the large safe is 1000 S.D.C. at $2000' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Large Safe' AND sdc = 1000 AND cost = 2000;
SELECT 'the two cases carry an A.R. as well' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE name IN ('Bullet Resistant Attache Case', 'Courier Briefcase')
   AND ar IN (15, 11) AND sdc IN (140, 90);

-- THE MEDICAL KIT THAT COSTS MORE WITHOUT ITS DRUGS.
SELECT 'both medical kit prices are rows' AS assertion, count(*) AS got, 2 AS want
  FROM gear WHERE instr(name, 'Professional Medical Kit') > 0 AND cost IN (200, 1500);

-- TEXT CHECKS, because a previous batch passed every count while every string in
-- it was mangled.
SELECT 'the lock pick description survived' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Lock Pick' AND instr(description, 'raise the pins') > 0;
SELECT 'and the wirecutters kept their s letters' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Wirecutters' AND instr(description, 'nonconducting handles') > 0;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-g-field-and-containers.sql');
