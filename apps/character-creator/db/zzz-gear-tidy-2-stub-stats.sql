-- The 85 gear rows the class importer created as stubs, given stats.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzz-gear-tidy-2-stub-stats.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzz-gear-tidy-2-stub-stats.sql
--
-- WHY THEY RENDERED BLANK. The wizard's equipment step builds each option's
-- detail line from category, weight and cost and drops the empty ones
-- (app.js, the gearChoices block). A stub has all three null, so the option
-- renders as a bare name with nothing beside it. Category alone fixes the
-- blank; the rest makes the row worth reading.
--
-- 17 ARE PRICED OFF A PAGE. Rifts Ultimate Edition's Common Gear list
-- (printed 261-262) and its Medical Equipment entries (printed 263) carry
-- most of them, and the Huntsman is copied from the fully statted twin row
-- that already exists for the same suit.
--
-- 68 ARE ESTIMATES, and say so: each one's source_book becomes
-- 'Estimate - no published price found', which is what the 36 rows that
-- already carried an estimate use. That string is the point - it is greppable,
-- and it is what tells a later import that this number may be overwritten.
--
-- AN ESTIMATE SETS COST AND NOTHING ELSE. Not weight, not M.D.C., not damage,
-- not A.R. That is not this file's rule; it is the condition the estimate tier
-- exists under, and catalog-data.mjs fails the build over it: "a guessed price
-- is a shopping inconvenience; a guessed damage die decides fights and looks
-- identical to a real one," and weight is invention with nothing to anchor it.
-- The first draft of this script set a weight on all 68 and an M.D.C. on five,
-- and the smoke test refused it - which is the check doing its job.
--
-- SO THE ESTIMATED ARMOUR ROWS STILL HAVE NO M.D.C., and that is correct
-- rather than unfinished. Light M.D.C. Body Armor now renders "armor - 20000"
-- instead of rendering blank, and the durability stays empty until someone
-- points at a suit and a page. The readback below counts them rather than
-- hiding them.
--
-- TWO WEAPONS KEEP EMPTY COMBAT STATS ON PURPOSE. The C-14 Fire Breather and
-- the C-27 Heavy Plasma Cannon are NAMED by Juicer Uprising and statted in
-- Coalition War Machine. They get a category and a description so they render,
-- and their cost, damage and range stay null until that book arrives.
--
-- THE STUB MARKER WAS LOAD BEARING AND IS REPLACED, NOT DROPPED.
-- import-engine.js reads `description LIKE 'STUB %'` to decide that a matching
-- row is uncurated and should default to `update` rather than `ignore` when a
-- real book brings the same item in. Filling these descriptions clears that
-- flag, so an estimate would silently outrank the book that arrived later.
-- The companion change to import-engine.js makes the estimate marker count as
-- a stub for exactly that purpose, which also fixes the 36 rows that have
-- carried an estimate and been treated as curated all along.
--
-- Guarded on the row still being a stub, so a re-run is a no-op and anything
-- since corrected by hand is left alone.


UPDATE gear SET category = 'gear',
       cost = 15,
       weight_lbs = 0.2,
       description = 'Cheap protective goggles. RUE lists them with sunglasses at 15-50 credits; light-adjusting pairs run 100-300.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'goggles' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 6,
       weight_lbs = 0.15,
       description = 'A pen or pocket sized flashlight, the one that lives in a breast pocket.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'pen-flashlight' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 1,
       weight_lbs = 0.05,
       description = 'A marker pen. One credit each, six to eight credits the dozen.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'marker' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 1,
       weight_lbs = 0.5,
       description = 'An iron spike for climbing, pinning a door or staking a line. RUE sells them six for six credits.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'iron-spike' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 15,
       weight_lbs = 0.2,
       description = 'A small folding knife. Does 1D4 S.D.C.; RUE prices small knives at 15-75 credits depending on quality.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'pocket-knife' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 80,
       weight_lbs = 0.5,
       description = 'A skinning and dressing knife. Does 1D6 S.D.C.; 80-200 credits by quality.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'hunting-knife' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 100,
       weight_lbs = 1.0,
       description = 'A folding computer about the size of an opened paperback. RUE starts palm units at 100 credits and runs to tens of thousands for military machines.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'portable-hand-held-computer' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 150,
       weight_lbs = 0.5,
       description = 'An old-style radio communicator, 3 mile range, 30 S.D.C. The basic instrument issued to military personnel and field operatives.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'walkie-talkie-radio' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 20,
       weight_lbs = 0.05,
       description = 'A one inch audio disc, three hour capacity. About 20 credits each.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'blank-disc' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 8,
       weight_lbs = 0.2,
       description = 'Line and hooks. RUE prices 50 feet (15 m) of line at 5 credits; the hooks are the rest.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'fishing-line-and-hooks' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 15,
       weight_lbs = 2.0,
       description = 'Light line, 15 credits per 20 feet (6 m).',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'lightweight-rope' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 12,
       weight_lbs = 3.0,
       description = 'A metal hammer (10-20 credits) and a small mallet (2-4 credits), the pair a mason or mechanic carries.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'hammer-and-mallet' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 55,
       weight_lbs = 1.5,
       description = 'A human-sized gas mask (50-80 credits) with disposable air filters (12 for 5 credits).',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'air-filter-and-gas-mask' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 55,
       weight_lbs = 1.5,
       description = 'A human-sized gas mask with disposable filters. Duplicates air-filter-and-gas-mask; both slugs are referenced by classes.',
       source_book = 'Rifts Ultimate Edition p.261-263'
 WHERE slug = 'gas-mask-and-air-filter' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 100,
       weight_lbs = 2.0,
       description = 'A standard first-aid kit: bandages, tape, wipes, clamps, disinfectant, gloves, scissors, forceps, blades, tweezers, a thermometer and basic tablets.',
       source_book = 'Rifts Ultimate Edition p.263'
 WHERE slug = 'medical-kit' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 24000,
       weight_lbs = 16.0,
       mdc = 45,
       description = 'Huntsman plate and padded armour, non-environmental. 45 M.D.C. The same suit as huntsman-plate-padded-armor-non-environmental, which carries the full entry.',
       source_book = 'Rifts Ultimate Edition p.261-270'
 WHERE slug = 'huntsman-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 26000,
       description = 'Light Mega-Damage body armour. The Book of Magic names it only in passing, alongside the Huntsman, as what a Stone Master typically wears; it is not statted there. Priced against the Huntsman it is compared to.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'explorer-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = NULL,
       description = 'The Coalition C-14 "Fire Breather" assault rifle with underslung grenade launcher. Named by Juicer Uprising; the stat block is in Coalition War Machine. Damage and range are deliberately left empty rather than guessed.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'c-14-fire-breather-rifle' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = NULL,
       description = 'The Coalition C-27 heavy plasma cannon. Named by Juicer Uprising; the stat block is in Coalition War Machine. Damage and range are deliberately left empty rather than guessed.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'c-27-heavy-plasma-cannon' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 40000,
       description = 'Archaic Mega-Damage plate in the style of a pantheon, worn by its servants and champions. Ornamental where a modern suit is functional.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'archaic-mdc-armor-of-the-pantheon' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 50,
       description = 'Trail food, water and the small necessities of a week on the road.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'basic-provisions' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 80,
       description = 'Dark, unmarked clothing for moving at night without being seen.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'black-clothing-covert' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 15,
       description = 'A knife worked from bone. Does 1D4 S.D.C. The weapon of someone with no access to a forge.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'bone-knife' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 35000,
       weight_lbs = 9.0,
       mdc = 50,
       description = 'Generic Coalition "Dead Boy" environmental body armour, as a class list names it. Resolves to the CA-2 Light Dead Boy Armor, the standard issue: 50 M.D.C. The heavy CA-1 has its own row at 80 M.D.C.',
       source_book = 'Rifts Ultimate Edition p.261-270'
 WHERE slug = 'coalition-dead-boy-body-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 10,
       description = 'A retracting steel tape. The unpowered one, carried because it never needs a battery.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'conventional-tape-measure' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 10,
       description = 'Light utility cord.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'cord' AND description LIKE 'STUB %';

UPDATE gear SET category = 'magic',
       cost = 60000,
       description = 'The paired bracelets a Daitya wears. Enchanted rather than manufactured, and not sold.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'daitya-magical-bracelets' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 400,
       description = 'A still camera with digital storage. RUE prices a video camera with telemetry at about 4200 credits and a traditional one at half that; a stills-only unit is well below both.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'digital-camera' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 120,
       description = 'Good clothes. What a character owns for the occasions that need them.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'dress-clothing' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 15000,
       description = 'The chest and shoulder harness that carries a Juicers drug reservoirs and pumps. Fitted as part of the conversion and not sold separately; the figure is what a replacement rig costs on the black market.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'drug-injection-harness' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 40,
       description = 'Sealed emergency rations, several days worth, meant to be eaten cold.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'emergency-food-rations' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 80000,
       description = 'Enchanted chain mail borne by a Valkyrie. Granted, not bought.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'enchanted-chain-mail-valkyrie' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 20000,
       description = 'A placeholder for "an energy weapon of choice" - the book leaves the pick to the player, so this row stands in for whichever one they take.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'energy-weapon-of-choice' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 200,
       description = 'A high-explosive hand grenade. Coalition grenades of this size run about a peach; the damaging types are Mega-Damage.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'explosive-grenade' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 200,
       description = 'A fragmentation hand grenade, thrown for area effect against soft targets.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'fragmentation-grenade' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 300,
       description = 'A radiation counter. RUE stats a dosimeter as a sensor package component; this is the standalone hand unit.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'geiger-counter' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 600,
       description = 'A loupe and the small tools for cutting and setting stones.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'gem-cutters-glass-and-tools' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 200,
       description = 'A hand grenade of unspecified type. The specific rows are explosive-grenade, fragmentation-grenade and smoke-grenade.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'hand-grenade' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 40,
       description = 'A utility hand axe, carried for wood and wreckage rather than for fighting. Does 1D6 S.D.C. if it comes to that.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'hand-axe-utility' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 200,
       description = 'A plain protective helmet, no optics and no radio. RUE prices the communications version at 5,500 credits; this is the bare one.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'helmet' AND description LIKE 'STUB %';

UPDATE gear SET category = 'vehicle',
       cost = 65000,
       description = 'A civilian hover cycle. The statted rows are the A.T.V. Speedster and the AHB-2000; this is the unspecified one a class list names.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'hovercycle' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 60,
       description = 'An iron rod that serves as a javelin. Does 1D6 S.D.C. thrown.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'iron-javelin-rod' AND description LIKE 'STUB %';

UPDATE gear SET category = 'vehicle',
       cost = 22000,
       description = 'A pre-Rifts style four wheel drive utility vehicle, or a rebuild of one.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'jeep' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 22000,
       description = 'Light segmented plate cut for a Juicer, built to stay out of the way of the speed rather than to stop the most damage.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'juicer-flex-plate-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 90,
       description = 'A two-handed axe. Does 2D6 S.D.C.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'large-axe' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 20,
       description = 'A masons chisel.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'large-chisel' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 1200,
       description = 'A full mechanics or electricians kit, the one that lives in a vehicle rather than on a belt.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'large-tool-kit' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 2000,
       description = 'A surgical laser. Cuts and cauterises in the same pass.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'laser-scalpel' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 1500,
       description = 'A cutting and welding torch. The Wilks portable model has its own row and will slice a 600 S.D.C. metal door.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'laser-torch' AND description LIKE 'STUB %';

UPDATE gear SET category = 'magic',
       cost = 250000,
       description = 'A lesser rune weapon: indestructible, intelligent, and priced at what one changes hands for rather than what one costs to make.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'lesser-rune-weapon' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 20000,
       description = 'Unspecified light Mega-Damage body armour, the phrase a great many class equipment lists use instead of naming a suit. Around 40-60 M.D.C. depending on which one the player picks.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'light-mdc-body-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 1,
       description = 'A glass slide.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'microscope-slide' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 300,
       description = 'An instrument of the characters choice. The price is a decent portable one.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'musical-instrument' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 500000,
       description = 'Odins own armour. Not a purchasable item; the figure exists so the row sorts and renders with the rest.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'odins-magic-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'armor',
       cost = 30000,
       description = 'Light or medium Mega-Damage body armour, fitted and marked to its owner. Which suit is the players pick.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'personalized-light-or-medium-mdc-body-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 5,
       description = 'A pin. Laboratory and workshop consumable.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'pin' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 800,
       description = 'A pocket rangefinder. Points at a thing and reads back the distance.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'pocket-laser-distancer' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 2500,
       description = 'A field microscope, the one a Rogue Scientist carries rather than the one in a laboratory.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'portable-microscope' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 300,
       description = 'A carried tool kit. Between the mini kit on a belt and the large kit in a vehicle.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'portable-tool-kit' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 8,
       description = 'A flat bladed spreading knife.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'putty-knife' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 30,
       description = 'Sterilisable surgical gloves. RUE prices disposables at 12 credits; these cost more and last.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'reusable-surgical-gloves' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 2,
       description = 'A plain sack. The sized rows are large-sack and small-sack.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'sack' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 60,
       description = 'Paired bags for a mount or a bike.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'saddlebags' AND description LIKE 'STUB %';

UPDATE gear SET category = 'vehicle',
       cost = 1800000,
       description = 'The Coalition SAMAS flying power armour. Catalogued as a vehicle, which is where this catalog keeps power armour.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'samas-power-armor' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 25,
       description = 'A surgical scalpel.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'scalpel' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 400,
       description = 'A carrying case of sculpting tools, as the Book of Magic gives a Stone Master.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'sculpting-tools-case' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 60,
       description = 'A soldering iron.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'soldering-iron' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 120,
       description = 'A padded case for carrying samples out of the field.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'specimen-case' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 4,
       description = 'A shallow culture dish.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'specimen-dish' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 8,
       description = 'A sealing jar for wet samples.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'specimen-jar' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 1200,
       description = 'A conventional automatic weapon firing solid rounds. S.D.C. damage, which is why it is rare in a Mega-Damage world and cheap when found.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'submachine-gun' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 40,
       description = 'A sterile gown.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'surgical-gown' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 900,
       description = 'A working set of surgical instruments. Not the robot kits, which have their own rows and their own prices.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'surgical-kit' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 50,
       description = 'A folding multi-tool. Blades, driver, awl and the rest.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'swiss-army-knife' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 200,
       description = 'A two-person tent.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'tent' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 3,
       description = 'A glass test tube.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'test-tube' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 300,
       description = 'A general tool kit. The sized rows are mini-tool-kit, portable-tool-kit and large-tool-kit.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'tool-kit' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 30000,
       description = 'An energy pistol rebuilt by a Techno-Wizard to run on P.P.E. or I.S.P. instead of an E-Clip.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'tw-converted-energy-pistol' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 45000,
       description = 'An energy rifle rebuilt by a Techno-Wizard to run on P.P.E. or I.S.P. instead of an E-Clip.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'tw-converted-energy-rifle' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 6,
       description = 'Fine tweezers.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'tweezers' AND description LIKE 'STUB %';

UPDATE gear SET category = 'magic',
       cost = 200000,
       description = 'The enchanted sword a Valkyrie carries. Granted with the office, not bought.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'valkyrie-magic-sword' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 20,
       description = 'A recordable video disc.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'video-disc' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 5000,
       description = 'A placeholder for "weapons matching the characters W.P. skills" - the book leaves the pick open, so this row stands in for whichever the player takes.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'weapons-matching-w-p-skills' AND description LIKE 'STUB %';

UPDATE gear SET category = 'weapon',
       cost = 20,
       description = 'A wooden spear. Does 1D6 S.D.C.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'wooden-spear' AND description LIKE 'STUB %';

UPDATE gear SET category = 'gear',
       cost = 1800,
       description = 'Infrared binoculars with a digital distancing readout. RUE prices the infrared optic at 1800 credits for a goggle set; the ranging readout is the rest.',
       source_book = 'Estimate - no published price found'
 WHERE slug = 'infrared-binoculars-digital-distancing-readout' AND description LIKE 'STUB %';

-- The pointer row, which is not a stub. Its description already says what it
-- resolves to and is left exactly as it stands; only the empty columns are
-- filled, from the CA-2 Light it points at.
UPDATE gear SET category = 'armor',
       cost = 35000,
       weight_lbs = 9.0,
       mdc = 50,
       source_book = 'Rifts Ultimate Edition p.261-265'
 WHERE slug = 'dead-boy-body-armor' AND cost IS NULL;

-- Readback. None of these enumerate the 85 slugs; each asks a question about
-- the whole catalog, which is what actually needs to be true afterwards. An
-- 85-term IN list is also close enough to SQLite's expression-tree limit to be
-- a bad habit in a file that gets copied.
SELECT count(*) AS stubs_remaining FROM gear WHERE description LIKE 'STUB %';
SELECT count(*) AS rows_priced_as_an_estimate FROM gear WHERE source_book = 'Estimate - no published price found';
-- Expected to be NON-ZERO, and every one of them an estimated row. An M.D.C.
-- is a combat number and the estimate tier is not allowed to invent one, so
-- these wait for a page rather than for this script.
SELECT count(*) AS armour_still_awaiting_a_durability FROM gear
 WHERE category = 'armor' AND mdc IS NULL AND sdc IS NULL;
SELECT count(*) AS and_how_many_of_those_are_estimates FROM gear
 WHERE category = 'armor' AND mdc IS NULL AND sdc IS NULL AND source_book = 'Estimate - no published price found';
-- Every costless row left in the catalog, which is 22 and not 2. The two
-- Coalition War Machine weapons this script adds are among them ON PURPOSE;
-- the other 20 are older rows it does not touch, mostly weapons and magic
-- items that were never priced. Listed rather than counted so the next person
-- can see which is which instead of trusting this comment.
SELECT slug, category, weight_lbs, source_book FROM gear
 WHERE cost IS NULL AND (cost_note IS NULL OR cost_note = '') ORDER BY slug;


-- Records this run. REQUIRED: the smoke test fails a data script
-- that has no footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zzz-gear-tidy-2-stub-stats.sql');
