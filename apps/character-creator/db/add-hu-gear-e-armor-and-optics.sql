-- Heroes Unlimited's firearm accessories, ammunition, body armor and optics.
-- Printed 212-213. Eighty-eight rows, and the first ARMOUR this book has had in
-- the catalog.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-hu-gear-e-armor-and-optics.sql
--
-- ===================================================================
-- BODY ARMOUR IS A REAL TABLE AND FILLS COLUMNS NOTHING ELSE HERE DOES
-- ===================================================================
--
-- Seventeen rows across three printed tables - eight ancient styles, five modern
-- LIGHT half suits and four modern HEAVY full suits - each giving Cost, A.R.,
-- S.D.C. and weight. They are the first rows in this book's import to use `ar`
-- and `sdc`, which is what `category = 'armor'` is for.
--
-- ONE PRINTED FIGURE IS ALMOST CERTAINLY A BOOK ERROR AND IS KEPT ANYWAY.
-- `Padded or Quilt` is printed at 66lbs - heavier than Plate four rows below it
-- at 58lbs, for the lightest armour on the table. It is nearly certainly 6lbs.
-- Confirmed on a 240 dpi render: the PAGE says 66, so this is not an OCR fault
-- and correcting it would be inventing a number. Stored as printed with the
-- reasoning in the description.
--
-- The ancient table's note is carried on its first row rather than repeated:
-- homemade armour is possible at half cost, with A.R. 2 and S.D.C. down 20%.
--
-- ===================================================================
-- ONE HEADING, SEVERAL PRICES - AGAIN, AND MORE OF IT
-- ===================================================================
--
-- Printed 212 prices by weapon type inside a single paragraph, and each becomes
-- its own row because a row cannot hold five prices:
--
--   Magazine Clip Pouch  -> SIX weapon types, each with a 2-clip and a 4-clip
--                           price. The 2-clip price is stored and cost_note
--                           carries both.
--   Silencer             -> five weapon types, $350 to $2000
--   Flash Suppressor     -> four weapon types, $250 to $1600
--   Metal Ammunition Box -> two calibres, $10 and $8
--
-- AMMUNITION IS PRICED PER BOX OF 100, which is in every ammunition row's
-- cost_note because the number is meaningless without it. Five of those rows are
-- SURCHARGES rather than prices - Hollow Point, Full Metal Jacketed, Teflon,
-- Exploding Shell and Dum Dum are amounts the book says to ADD to a box, and
-- each says so in its own note rather than reading as the price of a box.
--
-- Three of the surcharges carry the book's asterisk: not available at the
-- neighborhood gun shop, trackable through the black market, and the price is a
-- MINIMUM that can run two or three times higher.
--
-- ===================================================================
-- THE BOOK PRICES ONE OPTIC TWICE, AND THE DESCRIPTION WINS
-- ===================================================================
--
-- `Pocket Night Viewer` is $800 in its own description on printed 213 and
-- $1500.00 in the Night Sights table on the same page. The description wins,
-- which is the rule this batch has followed since the Bo Staff on printed
-- 194/195. Both figures are in the row's cost_note.
--
-- A SECOND DISCREPANCY IS NOT THE SAME SHAPE AND IS HANDLED DIFFERENTLY. Each
-- optics family opens with a paragraph giving a rough system-level figure -
-- infrared "about $1000", night sight "$1400", thermo-imager "about $1400" - and
-- then a table pricing specific form factors. Those are not two prices for one
-- item: the paragraph introduces the technology and the table prices the
-- goggles, binoculars, eyepiece and weapon sight separately. The TABLE rows are
-- imported as the items. The thermo-imager's paragraph figure is an order of
-- magnitude below its own table ($1400 against $18,000-$22,000) and that is
-- recorded on the first thermo-imager row rather than silently dropped.
--
-- ===================================================================
-- ONE PRICE THE COLUMN CANNOT HOLD
-- ===================================================================
--
-- `Magazine Clips` are $.89 each. `cost` is an INTEGER of dollars, so the row
-- carries a NULL cost with the figure in cost_note - the same treatment rope and
-- the ninja rope ladder got in the oriental batch, and not the usual meaning of
-- a NULL cost, which the note says.
--
-- `Web Belt (military)` at $20 is NOT the `Web Belt with Holster` at $60 from
-- printed 211; both are kept and each says so.
--
-- Guarded with INSERT OR IGNORE on a UNIQUE slug, so re-running is a no-op.

INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clip-pouch-automatic-pistol', 'Magazine Clip Pouch (Automatic Pistol)', 'heroes-unlimited', 'gear', NULL, 10, '$10 for 2 clips, $16 for 4', NULL, NULL, 0, 'A specially designed ammo pouch for 2 (slimline) or 4 (heavy-duty) clips. Choice of camouflage, green, khaki or black. The 2-clip price is stored and cost_note carries both.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clip-pouch-sub-machinegun', 'Magazine Clip Pouch (Sub-Machinegun)', 'heroes-unlimited', 'gear', NULL, 12, '$12 for 2 cells, $18 for 4', NULL, NULL, 0, 'A specially designed ammo pouch for 2 (slimline) or 4 (heavy-duty) clips. Choice of camouflage, green, khaki or black. The 2-clip price is stored and cost_note carries both.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clip-pouch-5-56mm-assault-rifle-20-round', 'Magazine Clip Pouch (5.56mm Assault Rifle, 20-round)', 'heroes-unlimited', 'gear', NULL, 14, '$14 for 2 clips, $20 for 4', NULL, NULL, 0, 'A specially designed ammo pouch for 2 (slimline) or 4 (heavy-duty) clips. Choice of camouflage, green, khaki or black. The 2-clip price is stored and cost_note carries both.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clip-pouch-5-56mm-assault-rifle-30-round', 'Magazine Clip Pouch (5.56mm Assault Rifle, 30-round)', 'heroes-unlimited', 'gear', NULL, 18, '$18 for 2 clips, $24 for 4', NULL, NULL, 0, 'A specially designed ammo pouch for 2 (slimline) or 4 (heavy-duty) clips. Choice of camouflage, green, khaki or black. The 2-clip price is stored and cost_note carries both.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clip-pouch-7-62mm-assault-rifle-20-round', 'Magazine Clip Pouch (7.62mm Assault Rifle, 20-round)', 'heroes-unlimited', 'gear', NULL, 18, '$18 for 2 clips, $22 for 4', NULL, NULL, 0, 'A specially designed ammo pouch for 2 (slimline) or 4 (heavy-duty) clips. Choice of camouflage, green, khaki or black. The 2-clip price is stored and cost_note carries both.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clip-pouch-7-62mm-assault-rifle-30-round', 'Magazine Clip Pouch (7.62mm Assault Rifle, 30-round)', 'heroes-unlimited', 'gear', NULL, 20, '$20 for 2 clips, $26 for 4', NULL, NULL, 0, 'A specially designed ammo pouch for 2 (slimline) or 4 (heavy-duty) clips. Choice of camouflage, green, khaki or black. The 2-clip price is stored and cost_note carries both.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-ammo-bag', 'Magazine Ammo Bag', 'heroes-unlimited', 'gear', NULL, 30, NULL, NULL, NULL, 0, 'Printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('assault-rifle-case', 'Assault Rifle Case', 'heroes-unlimited', 'gear', NULL, 70, NULL, NULL, NULL, 0, 'Printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('rifle-case', 'Rifle Case', 'heroes-unlimited', 'gear', NULL, 60, NULL, NULL, NULL, 0, 'Printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('sub-machinegun-case', 'Sub-Machinegun Case', 'heroes-unlimited', 'gear', NULL, 60, NULL, NULL, NULL, 0, 'Printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('shotgun-bandoleer', 'Shotgun Bandoleer', 'heroes-unlimited', 'gear', NULL, 24, '$24. THE BOOK IS AMBIGUOUS about what that figure covers - printed 212 reads ''Shotgun version will hold 56 rounds. 40mm grenade version holds 18 rounds, $24'', so the price may be the grenade version''s alone rather than both. Stored as one row with one price and the ambiguity recorded rather than resolved', NULL, NULL, 0, 'Brown leather with a heavy-duty brass belt buckle. The shotgun version holds 56 rounds and the 40mm grenade version 18.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('wrist-cartridge-bandoleer', 'Wrist Cartridge Bandoleer', 'heroes-unlimited', 'gear', NULL, 15, '$15 each', NULL, NULL, 0, 'Conceals 3 extra cartridges.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('metal-ammunition-box-50-caliber', 'Metal Ammunition Box (.50 caliber)', 'heroes-unlimited', 'gear', NULL, 10, NULL, NULL, NULL, 0, 'A waterproof ammo box for easy storage and carrying.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('metal-ammunition-box-30-caliber', 'Metal Ammunition Box (.30 caliber)', 'heroes-unlimited', 'gear', NULL, 8, NULL, NULL, NULL, 0, 'A waterproof ammo box for easy storage and carrying.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('field-gun-cleaning-kit', 'Field Gun Cleaning Kit', 'heroes-unlimited', 'gear', NULL, 35, NULL, NULL, NULL, 0, 'A complete cleaning kit in its own pouch.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('gun-repair-kit', 'Gun Repair Kit', 'heroes-unlimited', 'gear', 4, 250, NULL, NULL, NULL, 0, 'Each tool fitted into a separate loop, with room for spare bolts, screws, springs and cleaning rods, in a 12 by 8 by 2 inch case. Attaches to a harness or wears over the shoulder on the included strap.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('magazine-clips', 'Magazine Clips', 'heroes-unlimited', 'gear', NULL, NULL, '$.89 each - BELOW THE RESOLUTION of an integer cost column, so it is recorded here rather than rounded to a dollar', NULL, NULL, 0, 'Any weapon, any size, from a 7-round pistol to a 30-round rifle.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('web-belt-military', 'Web Belt (military)', 'heroes-unlimited', 'gear', NULL, 20, NULL, NULL, NULL, 0, 'A classic military belt with buckle and pouch fasteners, in camouflage, green or khaki. NOT the same item as the Web Belt with Holster on printed 211, which is $60.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('battle-harness', 'Battle Harness', 'heroes-unlimited', 'gear', NULL, 120, NULL, NULL, NULL, 0, 'Suspenders and belt combined, for distributing the weight of ammo pouches and accessories. Camouflage, black, grey, brown, cream or khaki.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('battle-pack', 'Battle Pack', 'heroes-unlimited', 'gear', NULL, 350, NULL, NULL, NULL, 0, 'A lightweight frame in heavy-duty water resistant canvas, with multiple compartments and fasteners for exterior pouches and grenades.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('multi-purpose-pouch', 'Multi-Purpose Pouch', 'heroes-unlimited', 'gear', NULL, 8, NULL, NULL, NULL, 0, 'A utility pouch for attachment to a web belt or battle harness.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('silencer-revolver', 'Silencer (Revolver)', 'heroes-unlimited', 'gear', NULL, 350, 'Not available on the commercial market', NULL, NULL, 0, 'A barrel-like attachment that muffles the report. REDUCES RANGE BY 10%.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('silencer-automatic-pistol', 'Silencer (Automatic Pistol)', 'heroes-unlimited', 'gear', NULL, 500, 'Not available on the commercial market', NULL, NULL, 0, 'A barrel-like attachment that muffles the report. REDUCES RANGE BY 10%.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('silencer-bolt-action-rifle', 'Silencer (Bolt Action Rifle)', 'heroes-unlimited', 'gear', NULL, 600, 'Not available on the commercial market', NULL, NULL, 0, 'A barrel-like attachment that muffles the report. REDUCES RANGE BY 10%.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('silencer-automatic-rifle', 'Silencer (Automatic Rifle)', 'heroes-unlimited', 'gear', NULL, 1500, 'Not available on the commercial market', NULL, NULL, 0, 'A barrel-like attachment that muffles the report. REDUCES RANGE BY 10%.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('silencer-sub-machinegun', 'Silencer (Sub-Machinegun)', 'heroes-unlimited', 'gear', NULL, 2000, 'Not available on the commercial market', NULL, NULL, 0, 'A barrel-like attachment that muffles the report. REDUCES RANGE BY 10%.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('flash-suppressor-revolver', 'Flash Suppressor (Revolver)', 'heroes-unlimited', 'gear', NULL, 250, 'Not available in the commercial market', NULL, NULL, 0, 'A barrel-shaped attachment that masks the gun''s flash, for covert night operations. REDUCES RANGE BY 15%, or 25% combined with a silencer.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('flash-suppressor-automatic-pistol', 'Flash Suppressor (Automatic Pistol)', 'heroes-unlimited', 'gear', NULL, 450, 'Not available in the commercial market', NULL, NULL, 0, 'A barrel-shaped attachment that masks the gun''s flash, for covert night operations. REDUCES RANGE BY 15%, or 25% combined with a silencer.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('flash-suppressor-bolt-action-rifle', 'Flash Suppressor (Bolt Action Rifle)', 'heroes-unlimited', 'gear', NULL, 1200, 'Not available in the commercial market', NULL, NULL, 0, 'A barrel-shaped attachment that masks the gun''s flash, for covert night operations. REDUCES RANGE BY 15%, or 25% combined with a silencer.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('flash-suppressor-sub-machinegun', 'Flash Suppressor (Sub-Machinegun)', 'heroes-unlimited', 'gear', NULL, 1600, 'Not available in the commercial market', NULL, NULL, 0, 'A barrel-shaped attachment that masks the gun''s flash, for covert night operations. REDUCES RANGE BY 15%, or 25% combined with a silencer.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-22-caliber', 'Ammunition, .22 caliber', 'heroes-unlimited', 'gear', NULL, 12, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-32-caliber', 'Ammunition, .32 caliber', 'heroes-unlimited', 'gear', NULL, 14, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-38-caliber', 'Ammunition, .38 caliber', 'heroes-unlimited', 'gear', NULL, 18, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-45-a-c-p', 'Ammunition, .45 A.C.P.', 'heroes-unlimited', 'gear', NULL, 28, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-41-magnum', 'Ammunition, .41 Magnum', 'heroes-unlimited', 'gear', NULL, 30, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-44-magnum', 'Ammunition, .44 Magnum', 'heroes-unlimited', 'gear', NULL, 32, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-357-magnum', 'Ammunition, .357 Magnum', 'heroes-unlimited', 'gear', NULL, 28, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-9mm-and-7-65mm', 'Ammunition, 9mm and 7.65mm', 'heroes-unlimited', 'gear', NULL, 30, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-5-56mm-rifle', 'Ammunition, 5.56mm (rifle)', 'heroes-unlimited', 'gear', NULL, 40, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-7-62mm-rifle', 'Ammunition, 7.62mm (rifle)', 'heroes-unlimited', 'gear', NULL, 48, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-tracer-cartridge', 'Ammunition, Tracer Cartridge', 'heroes-unlimited', 'gear', NULL, 45, 'per box of 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-hollow-point-surcharge', 'Ammunition, Hollow Point (surcharge)', 'heroes-unlimited', 'gear', NULL, 12, 'ADD $12.00 to the price of a box', NULL, NULL, 0, 'Printed 212 gives this as an ADD-ON to the price of a box, not a price of its own. The figure is the surcharge.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-full-metal-jacketed-surcharge', 'Ammunition, Full Metal Jacketed (surcharge)', 'heroes-unlimited', 'gear', NULL, 25, 'ADD $25.00 to the price of a box', NULL, NULL, 0, 'Printed 212 gives this as an ADD-ON to the price of a box, not a price of its own. The figure is the surcharge.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-teflon-armor-piercing-surcharge', 'Ammunition, Teflon armor piercing (surcharge)', 'heroes-unlimited', 'gear', NULL, 100, 'ADD $100.00; not available to the public', NULL, NULL, 0, 'Printed 212 gives this as an ADD-ON to the price of a box, not a price of its own. The figure is the surcharge. Printed 212 marks this with an asterisk: NOT available at the neighborhood gun shop, but trackable through the black market and illegal arms dealers. The added price is a MINIMUM and can cost two or three times more.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-exploding-shell-surcharge', 'Ammunition, Exploding Shell (surcharge)', 'heroes-unlimited', 'gear', NULL, 200, 'ADD $200.00; not available to the public', NULL, NULL, 0, 'Printed 212 gives this as an ADD-ON to the price of a box, not a price of its own. The figure is the surcharge. Printed 212 marks this with an asterisk: NOT available at the neighborhood gun shop, but trackable through the black market and illegal arms dealers. The added price is a MINIMUM and can cost two or three times more.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ammunition-dum-dum-surcharge', 'Ammunition, Dum Dum (surcharge)', 'heroes-unlimited', 'gear', NULL, 10, 'ADD $10.00 to $30.00; handmade, black market, any caliber', NULL, NULL, 0, 'Printed 212 gives this as an ADD-ON to the price of a box, not a price of its own. The figure is the surcharge. Printed 212 marks this with an asterisk: NOT available at the neighborhood gun shop, but trackable through the black market and illegal arms dealers. The added price is a MINIMUM and can cost two or three times more.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('40mm-grenade-cartridge', '40mm Grenade Cartridge', 'heroes-unlimited', 'gear', NULL, 700, '$700.00 per 100', NULL, NULL, 0, 'Printed 212, AMMUNITION - prices per BOX OF 100. Printed 212 marks this with an asterisk: NOT available at the neighborhood gun shop, but trackable through the black market and illegal arms dealers. The added price is a MINIMUM and can cost two or three times more.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('padded-or-quilt-armor', 'Padded or Quilt Armor', 'heroes-unlimited', 'armor', 66, 175, NULL, 8, 15, 0, 'THE PRINTED WEIGHT IS 66lbs, which is heavier than the Plate armor four rows below it at 58lbs and is almost certainly a book error for 6lbs. Confirmed on a 240 dpi render: the page really says 66. Transcribed as printed rather than corrected. Homemade armor is possible at half cost, with A.R. 2 and S.D.C. reduced by 20%.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('soft-leather-armor', 'Soft Leather Armor', 'heroes-unlimited', 'armor', 8, 300, NULL, 9, 20, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('studded-leather-armor', 'Studded Leather Armor', 'heroes-unlimited', 'armor', 20, 600, NULL, 12, 38, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('chain-mail-hu', 'Chain Mail', 'heroes-unlimited', 'armor', 40, 900, NULL, 13, 44, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('scale-mail-hu', 'Scale Mail', 'heroes-unlimited', 'armor', 45, 1500, NULL, 15, 75, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('plate-and-mail', 'Plate and Mail', 'heroes-unlimited', 'armor', 52, 2000, NULL, 15, 100, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('plate-armor-hu', 'Plate Armor', 'heroes-unlimited', 'armor', 58, 2800, NULL, 16, 150, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('plastic-plated-armor', 'Plastic Plated Armor', 'heroes-unlimited', 'armor', 28, 3000, NULL, 13, 80, 0, 'Ancient style, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('concealed-armor', 'Concealed Armor', 'heroes-unlimited', 'armor', 12, 1200, NULL, 10, 50, 0, 'A modern LIGHT half suit. Concealed styles are tough thin armor designed to be sewn into clothes or hidden under them; the other half suits are bulky or worn atop clothes. Half suits usually protect the upper body front, back, side, waist and groin.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('riot-jacket', 'Riot Jacket', 'heroes-unlimited', 'armor', 12, 900, NULL, 10, 60, 0, 'A modern LIGHT half suit, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('armor-vest', 'Armor Vest', 'heroes-unlimited', 'armor', 10, 800, NULL, 10, 50, 0, 'A modern LIGHT half suit. Printed 212 heads this row simply Vest; named in full here so it is legible out of the table.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('point-blank-vest', 'Point Blank Vest', 'heroes-unlimited', 'armor', 14, 1100, NULL, 10, 70, 0, 'A modern LIGHT half suit, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('hard-armor-vest', 'Hard Armor Vest', 'heroes-unlimited', 'armor', 15, 1400, NULL, 12, 120, 0, 'A modern LIGHT half suit, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('frag-cape-vest', 'Frag. Cape/Vest', 'heroes-unlimited', 'armor', 16, 1400, NULL, 13, 120, 0, 'A modern HEAVY full suit. Full suits are bulky, worn on top of clothes, and give the greatest protection.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('riot-armor', 'Riot Armor', 'heroes-unlimited', 'armor', 17, 1600, NULL, 14, 180, 0, 'A modern HEAVY full suit, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('hard-armor', 'Hard Armor', 'heroes-unlimited', 'armor', 20, 2200, NULL, 16, 260, 0, 'A modern HEAVY full suit, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('class-4-armor', 'Class 4 Armor', 'heroes-unlimited', 'armor', 20, 2800, NULL, 17, 280, 0, 'A modern HEAVY full suit, printed 212.', 'Revised Heroes Unlimited p.212');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('binocular-best-magnification', 'Binocular, best magnification', 'heroes-unlimited', 'gear', NULL, 1600, NULL, NULL, NULL, 0, 'Range 2000ft. Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('binocular-medium-magnification', 'Binocular, medium magnification', 'heroes-unlimited', 'gear', NULL, 1000, NULL, NULL, NULL, 0, 'Range 1600ft. Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('binocular-low-magnification', 'Binocular, low magnification', 'heroes-unlimited', 'gear', NULL, 600, NULL, NULL, NULL, 0, 'Range 1600ft. Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('weapon-sight-best-magnification', 'Weapon Sight, best magnification', 'heroes-unlimited', 'gear', NULL, 800, NULL, NULL, NULL, 0, 'Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('weapon-sight-medium-magnification', 'Weapon Sight, medium magnification', 'heroes-unlimited', 'gear', NULL, 400, NULL, NULL, NULL, 0, 'Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('weapon-sight-low-magnification', 'Weapon Sight, low magnification', 'heroes-unlimited', 'gear', NULL, 230, NULL, NULL, NULL, 0, 'Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('infrared-goggles-mercury-battery-type', 'Infrared Goggles (mercury battery type)', 'heroes-unlimited', 'gear', NULL, 550, 'fair availability', NULL, NULL, 0, 'Range 1200ft (360m). An infrared system relies on a pencil-thin beam of infrared light projected from the goggles to illuminate targets. THE BEAM LIMITS THE VIEW to about two square meters (7ft) and is clearly visible to another infrared system, giving the operator''s position away. Both drawbacks are inherent to ALL infrared systems.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('infrared-goggles-new-superior-type', 'Infrared Goggles (new superior type)', 'heroes-unlimited', 'gear', NULL, 880, 'fair availability', NULL, NULL, 0, 'Range 1200ft (360m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('infrared-binoculars', 'Infrared Binoculars', 'heroes-unlimited', 'gear', NULL, 2100, 'fair availability', NULL, NULL, 0, 'Range 1200ft (360m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('infrared-monocular-eyepiece', 'Infrared Monocular Eyepiece', 'heroes-unlimited', 'gear', NULL, 800, 'fair availability', NULL, NULL, 0, 'Range 1200ft (360m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('infrared-weapon-sight', 'Infrared Weapon Sight', 'heroes-unlimited', 'gear', NULL, 1200, 'fair availability', NULL, NULL, 0, 'Range 1200ft (360m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('infrared-distancing-binoculars-hu', 'Infrared Distancing Binoculars', 'heroes-unlimited', 'gear', NULL, 6700, 'Not commercially available', NULL, NULL, 0, 'Range 2 miles (3km). High-powered optics with infrared adjustments, cross hair indicator lines and a digital readout of estimated distance and rate of travel. Extremely popular among spies and used by the military.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('ultraviolet-optic-system', 'Ultraviolet Optic System', 'heroes-unlimited', 'gear', NULL, 500, NULL, NULL, NULL, 0, 'Range 400ft (120m). Lets the wearer see into the ultraviolet range. Usually integrated into a larger optics package rather than used alone.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('night-sight-goggles', 'Night Sight Goggles', 'heroes-unlimited', 'gear', NULL, 5200, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). A night vision system is an image intensifier - a PASSIVE system that emits no light of its own and electronically amplifies existing ambient light.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('night-sight-binoculars', 'Night Sight Binoculars', 'heroes-unlimited', 'gear', NULL, 6400, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('night-sight-monocular-eyepiece', 'Night Sight Monocular Eyepiece', 'heroes-unlimited', 'gear', NULL, 1900, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('night-sight-weapon-sight', 'Night Sight Weapon Sight', 'heroes-unlimited', 'gear', NULL, 1800, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('pocket-night-viewer-hu', 'Pocket Night Viewer', 'heroes-unlimited', 'gear', NULL, 800, 'THE BOOK PRICES THIS TWICE AND DIFFERENTLY. Its own description on printed 213 says $800; the Night Sights table on the same page lists it at $1500.00. The DESCRIPTION wins, per the rule this batch has followed since the Bo Staff', NULL, NULL, 0, 'Range 800ft (240m). A mini night sight, usually monocular, easily concealed and portable.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('night-sight-large-tripod-mount', 'Night Sight Large Tripod Mount', 'heroes-unlimited', 'gear', NULL, 14000, 'poor availability', NULL, NULL, 0, 'Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('thermo-imager-goggles', 'Thermo-Imager Goggles', 'heroes-unlimited', 'gear', NULL, 22000, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). An optical heat sensor that converts the infrared radiation of warm objects into a visible image, letting its operator see in darkness, shadow and through smoke. Battery powered and electrically cooled, with a typical running life of 16 hours. THE INTRODUCTORY PARAGRAPH SAYS ''Cost: about $1400'', an order of magnitude below every figure in its own table; the table''s itemised prices are stored and the paragraph''s figure is recorded here.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('thermo-imager-binoculars', 'Thermo-Imager Binoculars', 'heroes-unlimited', 'gear', NULL, 20000, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('thermo-imager-monocular-eyepiece', 'Thermo-Imager Monocular Eyepiece', 'heroes-unlimited', 'gear', NULL, 18000, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('thermo-imager-weapon-sight', 'Thermo-Imager Weapon Sight', 'heroes-unlimited', 'gear', NULL, 18000, 'poor availability', NULL, NULL, 0, 'Range 1600ft (480m). Printed 213.', 'Revised Heroes Unlimited p.213');
INSERT OR IGNORE INTO gear (slug, name, system, category, weight_lbs, cost, cost_note, ar, sdc, is_mega_damage, description, source_book)
VALUES ('multi-optics-helmet-m-o-h-hu', 'Multi-Optics Helmet (M.O.H.)', 'heroes-unlimited', 'gear', NULL, 38000, 'Available to high-tech organizations', NULL, NULL, 0, 'An optical enhancement system built into a protective helmet: a targeting sight to 1600ft (480m), an infrared optics system to 1600ft, a telescopic monocular lens to 2 miles (3km), and a thermo-imager to 1600ft. SPECIAL BONUS: +1 to strike when the optics and targeting sight are engaged.', 'Revised Heroes Unlimited p.213');

-- ASSERTIONS.

SELECT 'all eighty-eight rows landed' AS assertion, count(*) AS got, 88 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.212', 'Revised Heroes Unlimited p.213');

SELECT 'sixty-four from printed 212' AS assertion, count(*) AS got, 64 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.212';
SELECT 'twenty-four from printed 213' AS assertion, count(*) AS got, 24 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.213';

SELECT 'every one is Heroes Unlimited' AS assertion, count(*) AS got, 88 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.212', 'Revised Heroes Unlimited p.213')
   AND system = 'heroes-unlimited';

-- THE ARMOUR. Seventeen rows, and they are the first in this book to fill `ar`
-- and `sdc` - a row that lost either would still count above.
SELECT 'seventeen armour rows' AS assertion, count(*) AS got, 17 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.212' AND category = 'armor';
SELECT 'and every one carries an A.R., an S.D.C. and a weight' AS assertion, count(*) AS got, 17 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.212' AND category = 'armor'
   AND ar IS NOT NULL AND sdc IS NOT NULL AND weight_lbs IS NOT NULL;

-- The two ends of the armour table, spelled out, so a shifted column is caught.
SELECT 'Plate is 16/150 at $2800' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Plate Armor' AND ar = 16 AND sdc = 150 AND cost = 2800 AND weight_lbs = 58;
SELECT 'Class 4 Armor is 17/280 at $2800' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Class 4 Armor' AND ar = 17 AND sdc = 280 AND cost = 2800 AND weight_lbs = 20;

-- The book's own error, kept deliberately. If this ever reads 6 somebody
-- "corrected" the page.
SELECT 'the padded armour keeps the printed 66lbs' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Padded or Quilt Armor' AND weight_lbs = 66;

-- EXACTLY ONE row has no price, and it is the sub-dollar one.
SELECT 'exactly one row has no cost' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE source_book IN ('Revised Heroes Unlimited p.212', 'Revised Heroes Unlimited p.213')
   AND cost IS NULL;
SELECT 'and it is the magazine clips, with the figure in the note' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Magazine Clips' AND cost IS NULL AND instr(cost_note, '.89') > 0;

-- THE PRICED-BY-TYPE FAMILIES. Each must be all of its rows or none.
SELECT 'six magazine clip pouches' AS assertion, count(*) AS got, 6 AS want
  FROM gear WHERE instr(name, 'Magazine Clip Pouch') > 0;
SELECT 'five silencers' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE instr(name, 'Silencer (') > 0;
SELECT 'four flash suppressors' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE instr(name, 'Flash Suppressor (') > 0;
SELECT 'seventeen ammunition rows' AS assertion, count(*) AS got, 17 AS want
  FROM gear WHERE source_book = 'Revised Heroes Unlimited p.212'
   AND (instr(name, 'Ammunition,') > 0 OR name = '40mm Grenade Cartridge');
SELECT 'five of them are surcharges and say so' AS assertion, count(*) AS got, 5 AS want
  FROM gear WHERE instr(name, '(surcharge)') > 0 AND instr(cost_note, 'ADD') > 0;

-- THE OPTIC THE BOOK PRICES TWICE. The description's figure won.
--
-- SCOPED BY source_book, and the first draft was not - it reported 2 against a
-- want of 1. Rifts Ultimate Edition prints a Pocket Night Viewer too and prices
-- it at 800 CREDITS where this book prices it at 800 DOLLARS. The same figure in
-- two currencies is a coincidence, not a duplicate; both rows are correct and
-- the assertion was asking a wider question than it meant to.
SELECT 'the pocket night viewer took the description price' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Pocket Night Viewer' AND cost = 800
   AND source_book = 'Revised Heroes Unlimited p.213';
SELECT 'and its note records the table price it did not take' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Pocket Night Viewer' AND instr(cost_note, '1500') > 0;

-- TEXT CHECKS, because a previous batch passed every count while every string
-- in it was mangled.
SELECT 'the infrared drawback text survived' AS assertion, count(*) AS got, 1 AS want
  FROM gear WHERE name = 'Infrared Goggles (mercury battery type)'
   AND instr(description, 'giving the operator') > 0;
SELECT 'and the suppressor kept its s letters' AS assertion, count(*) AS got, 4 AS want
  FROM gear WHERE instr(name, 'Flash Suppressor') > 0
   AND instr(description, 'masks the gun') > 0;

INSERT INTO data_script_runs (filename) VALUES ('add-hu-gear-e-armor-and-optics.sql');
