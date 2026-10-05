-- Twenty-seven D-Bees of North America classes take the equipment their pages
-- print: the racial gear ~116 adds, and held rows the import had left as prose.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~117-d-bees-classes-take-their-gear.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~117-d-bees-classes-take-their-gear.sql
--
-- Close-out package A10 (Nate's ruling of 2026-10-04). The D-Bees classes were
-- imported with sentences saying parts of their Standard Equipment had "no
-- catalog row". Each class's equipment line was read again off a render and
-- every printed item the class did not already grant was sorted:
--   held     the catalog has the item under another name: it is granted
--   new row  the book stats it, or it is the race's own item: ~116 adds the
--            row and it is granted here
--   choice   "one weapon for each W.P.", "energy sidearm of choice": the book
--            does not enumerate, so nothing is invented
--   left     unstatted personal trivia with no row (comb, loincloth, snacks)
-- 77 equipment lines across 27 classes. The rows and the held lines were
-- checked against renders by a reader that did not write them: no
-- disagreement.
--
-- NOT GRANTED, on purpose, though a row exists: the Altara's six Bio-Wizard
-- microbes ("frequently given", by assignment); the Vernulian collars (the
-- military one is the soldiers' only, three refugees in ten have the
-- commercial one); the N'reta translator (about half of those who travel);
-- the Yhabbayar camera ("many have one"); the Septumbran patchwork armor
-- (printed on the M.D.C. line, not as equipment); the Spinne force fields
-- (given to no character); the larger Nuhr rune armors and the ship cannon.
--
-- CONDITIONS THE SHEET CANNOT ENFORCE stay in the class's own words: the
-- Shale Bogle's list is a hunter's or adventurer's, the Lyvorrk's is for one
-- who takes the R.C.C., and most Feni, not all, have the armor.
--
-- ALSO: amana's gloves were 100 of a row priced per box of gloves; the book
-- prints one box of 100, so the quantity is 1.
--
-- Every sentence the new lines make false is rewritten in the same script.
-- Every replace() is guarded on the text it replaces and on the new text
-- being absent, so a second run is a no-op. MUST SORT AFTER ~116.
-- THIS SCRIPT CHANGES PRODUCTION: 29 class rows.

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
natural_abilities:
',
         '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "walking-stick", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "shovel", qty: 1, note: "Printed as a collapsible shovel." }
  - { item_id: "work-boots-rifts", qty: 1, note: "Printed as sturdy, comfortable hiking boots." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, '  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "') > 0
   AND instr(markdown, ' }
  - { item_id: "work-boots-rifts", qty: 1, note: "Printed as sturdy, comfortable hiking boots." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row: the energy sidearm of choice, walking stick (1D8 S.D.C.), set of cookware and utensils, tinder box, collapsible shovel, hiking boots, 1D6+1 items central to the O.C.C.,',
         'Granted since ~116 and ~117: walking stick (1D8 S.D.C.) as walking-stick, tinder box as tinder-box, collapsible shovel as shovel, hiking boots as work-boots-rifts. NOT STORED, no catalog row: the energy sidearm of choice, set of cookware and utensils, 1D6+1 items central to the O.C.C.,'),
       updated_at = datetime('now')
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, 'NOT STORED, no catalog row: the energy sidearm of choice, walking stick (1D8 S.D.C.), set of cookware and utensils, tind') > 0
   AND instr(markdown, 'T STORED, no catalog row: the energy sidearm of choice, set of cookware and utensils, 1D6+1 items central to the O.C.C.,') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment the catalog has no row for: one energy sidearm of
choice, a walking stick (1D8 S.D.C.), a set of cookware and eating
utensils, a tinder box, a collapsible shovel, sturdy hiking boots, and
1D6+1 items central to the chosen O.C.C. A character with a Horsemanship
',
         'Standard equipment the catalog has no row for: one energy sidearm of
choice, a set of cookware and eating utensils, and 1D6+1 items central
to the chosen O.C.C. A character with a Horsemanship
'),
       updated_at = datetime('now')
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, 'Standard equipment the catalog has no row for: one energy sidearm of
choice, a walking stick (1D8 S.D.C.), a set of cook') > 0
   AND instr(markdown, 'ce, a set of cookware and eating utensils, and 1D6+1 items central
to the chosen O.C.C. A character with a Horsemanship
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "wooden-stake", qty: "1d4+4" }
natural_abilities:
',
         '  - { item_id: "wooden-stake", qty: "1d4+4" }
  - { item_id: "akysse-vibro-spear", qty: 1 }
  - { item_id: "akysse-patchwork-hide-armor", qty: 1 }
  - { item_id: "water-skin-half-gallon", qty: 1, note: "The page prints no size." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'akysse-tribal-hunter'
   AND instr(markdown, '  - { item_id: "wooden-stake", qty: "1d4+4" }
natural_abilities:
') > 0
   AND instr(markdown, 'armor", qty: 1 }
  - { item_id: "water-skin-half-gallon", qty: 1, note: "The page prints no size." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row with these stats: the improvised Vibro-Spear (1D6, 2D4 or 2D6 M.D.; Vibro-Knives or a Vibro-Saber lashed to a pole - the catalog vibro-spear is a different weapon at 2D6+2 M.D.), the patchwork Fury Beetle or dinosaur hide armor (4D6+28 M.D.C.), medicine pouch, water skin, three loincloths, 1D4 dinosaur and animal calls;',
         'Granted since ~116 and ~117: the improvised Vibro-Spear (1D6, 2D4 or 2D6 M.D.; Vibro-Knives or a Vibro-Saber lashed to a pole) as akysse-vibro-spear - the catalog vibro-spear is a different weapon at 2D6+2 M.D. - the patchwork Fury Beetle or dinosaur hide armor (4D6+28 M.D.C., a roll held in the row''s description) as akysse-patchwork-hide-armor, and the water skin as water-skin-half-gallon (the page prints no size). NOT STORED, no catalog row: medicine pouch, three loincloths, 1D4 dinosaur and animal calls;'),
       updated_at = datetime('now')
 WHERE class_id = 'akysse-tribal-hunter'
   AND instr(markdown, 'NOT STORED, no catalog row with these stats: the improvised Vibro-Spear (1D6, 2D4 or 2D6 M.D.; Vibro-Knives or a Vibro-S') > 0
   AND instr(markdown, ' (the page prints no size). NOT STORED, no catalog row: medicine pouch, three loincloths, 1D4 dinosaur and animal calls;') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment the catalog has no row for: a Vibro-Spear made by lashing
one or two Vibro-Knives or a Vibro-Saber to a pole (1D6, 2D4 or 2D6 M.D.), a
suit of patchwork Fury Beetle or dinosaur hide armor (4D6+28 M.D.C.), a
medicine pouch, a water skin, three loincloths, and 1D4 dinosaur and animal
calls. With a Horsemanship skill the character may start with a good riding
',
         'Standard equipment the catalog has no row for: a medicine pouch, three
loincloths, and 1D4 dinosaur and animal calls. With a Horsemanship skill
the character may start with a good riding
'),
       updated_at = datetime('now')
 WHERE class_id = 'akysse-tribal-hunter'
   AND instr(markdown, 'Standard equipment the catalog has no row for: a Vibro-Spear made by lashing
one or two Vibro-Knives or a Vibro-Saber to') > 0
   AND instr(markdown, 'ree
loincloths, and 1D4 dinosaur and animal calls. With a Horsemanship skill
the character may start with a good riding
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "bio-wizard-mental-incapacitator", qty: 1 }
natural_abilities:
',
         '  - { item_id: "bio-wizard-mental-incapacitator", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Printed as a conventional dagger, 1D6 S.D.C." }
  - { item_id: "talisman-of-armor", qty: 1 }
  - { item_id: "altara-padded-armor", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'blind-warrior-women'
   AND instr(markdown, '  - { item_id: "bio-wizard-mental-incapacitator", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, '.D.C." }
  - { item_id: "talisman-of-armor", qty: 1 }
  - { item_id: "altara-padded-armor", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'give 30 M.D.C. (prose; no gear row).',
         'give 30 M.D.C. (the gear row altara-padded-armor).'),
       updated_at = datetime('now')
 WHERE class_id = 'blind-warrior-women'
   AND instr(markdown, 'give 30 M.D.C. (prose; no gear row).') > 0
   AND instr(markdown, 'give 30 M.D.C. (the gear row altara-padded-armor).') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The conventional dagger and the 30 M.D.C. suit and helmet have no Rifts gear row and stay in the body.',
         'Granted since ~116 and ~117: the conventional dagger as knife, the talisman as talisman-of-armor and the 30 M.D.C. suit and helmet as altara-padded-armor.'),
       updated_at = datetime('now')
 WHERE class_id = 'blind-warrior-women'
   AND instr(markdown, 'The conventional dagger and the 30 M.D.C. suit and helmet have no Rifts gear row and stay in the body.') > 0
   AND instr(markdown, 'onventional dagger as knife, the talisman as talisman-of-armor and the 30 M.D.C. suit and helmet as altara-padded-armor.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "food-rations", qty: "1d4+1" }
natural_abilities:
',
         '  - { item_id: "food-rations", qty: "1d4+1" }
  - { item_id: "surgical-gown", qty: 1, note: "Printed as a surgical apron." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'amana'
   AND instr(markdown, '  - { item_id: "food-rations", qty: "1d4+1" }
natural_abilities:
') > 0
   AND instr(markdown, 'ions", qty: "1d4+1" }
  - { item_id: "surgical-gown", qty: 1, note: "Printed as a surgical apron." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "disposable-surgical-gloves", qty: 100 }
',
         '  - { item_id: "disposable-surgical-gloves", qty: 1, note: "One box of 100 surgical gloves; the row is priced per box." }
'),
       updated_at = datetime('now')
 WHERE class_id = 'amana'
   AND instr(markdown, '  - { item_id: "disposable-surgical-gloves", qty: 100 }
') > 0
   AND instr(markdown, '- { item_id: "disposable-surgical-gloves", qty: 1, note: "One box of 100 surgical gloves; the row is priced per box." }
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a box of 100 surgical gloves (disposable-surgical-gloves x100)',
         'a box of 100 surgical gloves (disposable-surgical-gloves qty 1 since ~116 and ~117: the catalog row is priced per box and the book prints one box of 100)'),
       updated_at = datetime('now')
 WHERE class_id = 'amana'
   AND instr(markdown, 'a box of 100 surgical gloves (disposable-surgical-gloves x100)') > 0
   AND instr(markdown, 'posable-surgical-gloves qty 1 since ~116 and ~117: the catalog row is priced per box and the book prints one box of 100)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row: 50 surgical masks, a small bottle of disinfectant, a surgical apron; in GM Notes.',
         'The surgical apron is granted as surgical-gown. NOT STORED, no catalog row: 50 surgical masks, a small bottle of disinfectant; in GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'amana'
   AND instr(markdown, 'NOT STORED, no catalog row: 50 surgical masks, a small bottle of disinfectant, a surgical apron; in GM Notes.') > 0
   AND instr(markdown, 'is granted as surgical-gown. NOT STORED, no catalog row: 50 surgical masks, a small bottle of disinfectant; in GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment the catalog has no row for: 50 surgical masks, a small
bottle of disinfectant and a surgical apron. They also start with 1D4x10,000
',
         'Standard equipment the catalog has no row for: 50 surgical masks and a
small bottle of disinfectant. They also start with 1D4x10,000
'),
       updated_at = datetime('now')
 WHERE class_id = 'amana'
   AND instr(markdown, 'Standard equipment the catalog has no row for: 50 surgical masks, a small
bottle of disinfectant and a surgical apron. T') > 0
   AND instr(markdown, 'pment the catalog has no row for: 50 surgical masks and a
small bottle of disinfectant. They also start with 1D4x10,000
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "large-sack", qty: "1d4" }
natural_abilities:
',
         '  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "crab-warrior-giant-satchel", qty: 2 }
  - { item_id: "crab-warrior-large-water-skin", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'crab-warrior'
   AND instr(markdown, '  - { item_id: "large-sack", qty: "1d4" }
natural_abilities:
') > 0
   AND instr(markdown, '_id: "crab-warrior-giant-satchel", qty: 2 }
  - { item_id: "crab-warrior-large-water-skin", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No catalog row fits the satchels or the skin.',
         'The satchels and the skin are in the equipment list; the belts and straps are not.'),
       updated_at = datetime('now')
 WHERE class_id = 'crab-warrior'
   AND instr(markdown, 'No catalog row fits the satchels or the skin.') > 0
   AND instr(markdown, 'The satchels and the skin are in the equipment list; the belts and straps are not.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The two giant satchels and the 3-5 gallon water skin have no catalog row and are a restriction line.',
         'The two giant satchels (crab-warrior-giant-satchel x2) and the 3-5 gallon water skin (crab-warrior-large-water-skin) are granted since ~116 and ~117, and a restriction line describes them.'),
       updated_at = datetime('now')
 WHERE class_id = 'crab-warrior'
   AND instr(markdown, 'The two giant satchels and the 3-5 gallon water skin have no catalog row and are a restriction line.') > 0
   AND instr(markdown, 'allon water skin (crab-warrior-large-water-skin) are granted since ~116 and ~117, and a restriction line describes them.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
',
         '  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "darkhound-piecemeal-body-armor", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'darkhound'
   AND instr(markdown, '  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, '  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "darkhound-piecemeal-body-armor", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The armor (its M.D.C. is a roll no catalog row carries), the satchel alternative, the comb and the personal items are not stored and are named in GM Notes.',
         'The armor is granted since ~116 and ~117 as darkhound-piecemeal-body-armor, whose description holds the rolled M.D.C. (1D4x10+15). The satchel alternative, the comb and the personal items are not stored and are named in GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'darkhound'
   AND instr(markdown, 'The armor (its M.D.C. is a roll no catalog row carries), the satchel alternative, the comb and the personal items are no') > 0
   AND instr(markdown, 'd M.D.C. (1D4x10+15). The satchel alternative, the comb and the personal items are not stored and are named in GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment the class does not carry as items: homemade, piecemeal body
armor (1D4x10+15 M.D.C.), a satchel in place of the backpack, a comb and some
personal items. It starts with no guns and no magic items, and its 4D6x10 of
',
         'Standard equipment the class does not carry as items: a satchel in place of
the backpack, a comb and some personal items. Its homemade, piecemeal body
armor (1D4x10+15 M.D.C.) is in the equipment list. It starts with no guns
and no magic items, and its 4D6x10 of
'),
       updated_at = datetime('now')
 WHERE class_id = 'darkhound'
   AND instr(markdown, 'Standard equipment the class does not carry as items: homemade, piecemeal body
armor (1D4x10+15 M.D.C.), a satchel in pl') > 0
   AND instr(markdown, 'al body
armor (1D4x10+15 M.D.C.) is in the equipment list. It starts with no guns
and no magic items, and its 4D6x10 of
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { choose: 1, label: "pen or marker", qty: 1, from: ["pen", "marker"] }
natural_abilities:
',
         '  - { choose: 1, label: "pen or marker", qty: 1, from: ["pen", "marker"] }
  - { item_id: "work-boots-rifts", qty: 1, note: "Printed as comfortable boots, at tiny size." }
  - { item_id: "faerie-bot-environmental-body-armor", qty: 1 }
  - { item_id: "disposable-surgical-gloves", qty: 1, note: "Printed as a box of 50 plastic gloves; the row is priced per box." }
  - { item_id: "faerie-bot-portable-radio-and-translator", qty: 1 }
  - { item_id: "faerie-bot-protective-helmet", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'faerie-bot'
   AND instr(markdown, '  - { choose: 1, label: "pen or marker", qty: 1, from: ["pen", "marker"] }
natural_abilities:
') > 0
   AND instr(markdown, 'bot-portable-radio-and-translator", qty: 1 }
  - { item_id: "faerie-bot-protective-helmet", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Also carried, beyond the listed items: comfortable boots, a suit of environmental body armor (1D6+22 M.D.C.), a box of 50 plastic gloves, a portable radio and language translator (10 mile/16 km range), a protective helmet with built-in language translator, radio and loudspeaker, a comb and some personal items, and the Faerie Bot Vehicle.',
         'The equipment list includes comfortable boots, a suit of environmental body armor (1D6+22 M.D.C.), a box of 50 plastic gloves, a portable radio and language translator (10 mile/16 km range) and a protective helmet with built-in language translator, radio and loudspeaker. Also carried, beyond the listed items: a comb and some personal items, and the Faerie Bot Vehicle.'),
       updated_at = datetime('now')
 WHERE class_id = 'faerie-bot'
   AND instr(markdown, 'Also carried, beyond the listed items: comfortable boots, a suit of environmental body armor (1D6+22 M.D.C.), a box of 5') > 0
   AND instr(markdown, 'adio and loudspeaker. Also carried, beyond the listed items: a comb and some personal items, and the Faerie Bot Vehicle.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'comfortable boots, the environmental body armor of 1D6+22 M.D.C., the box of 50 plastic gloves, the portable radio and language translator, the protective helmet, the comb and personal items have no matching row and are a restriction line. The Faerie Bot Vehicle has no catalog row (suggested slug faerie-bot-vehicle);',
         'since ~116 and ~117 that includes comfortable boots as work-boots-rifts, the box of 50 plastic gloves as disposable-surgical-gloves qty 1 (the row is priced per box), and three tiny-sized rows of the Faerie Bot''s own: the environmental body armor of 1D6+22 M.D.C. (a roll held in the row''s description) as faerie-bot-environmental-body-armor, the portable radio and language translator as faerie-bot-portable-radio-and-translator and the protective helmet as faerie-bot-protective-helmet. The comb and personal items have no matching row and are a restriction line. The Faerie Bot Vehicle is a vehicles row, faerie-bot-vehicle, which the class does not list in equipment because no gear pointer row exists for it;'),
       updated_at = datetime('now')
 WHERE class_id = 'faerie-bot'
   AND instr(markdown, 'comfortable boots, the environmental body armor of 1D6+22 M.D.C., the box of 50 plastic gloves, the portable radio and l') > 0
   AND instr(markdown, ' vehicles row, faerie-bot-vehicle, which the class does not list in equipment because no gear pointer row exists for it;') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'described in full under the natural abilities. The gear catalog has no
row for it. Out of the sphere the creature speaks only its own squeaky
',
         'described in full under the natural abilities. It is a vehicle row,
not a gear row, so the equipment list does not carry it. Out of the
sphere the creature speaks only its own squeaky
'),
       updated_at = datetime('now')
 WHERE class_id = 'faerie-bot'
   AND instr(markdown, 'described in full under the natural abilities. The gear catalog has no
row for it. Out of the sphere the creature speaks') > 0
   AND instr(markdown, 'ow,
not a gear row, so the equipment list does not carry it. Out of the
sphere the creature speaks only its own squeaky
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
',
         '  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "feni-custom-armor", qty: 1, note: "Most Feni have one." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'feni-nomad'
   AND instr(markdown, '  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, ' "pocket-mirror", qty: 1 }
  - { item_id: "feni-custom-armor", qty: 1, note: "Most Feni have one." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'bone-and-hide armor and the grooming brush have no catalog rows and are a restriction line.',
         'bone-and-hide armor is granted since ~116 and ~117 as feni-custom-armor (the row stores the low end, 35), with the note that most, not all, have one. The grooming brush is without a catalog row and is in a restriction line.'),
       updated_at = datetime('now')
 WHERE class_id = 'feni-nomad'
   AND instr(markdown, 'bone-and-hide armor and the grooming brush have no catalog rows and are a restriction line.') > 0
   AND instr(markdown, '), with the note that most, not all, have one. The grooming brush is without a catalog row and is in a restriction line.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "backpack", qty: 1 }
natural_abilities:
',
         '  - { item_id: "backpack", qty: 1 }
  - { item_id: "marker", qty: "1d4", note: "Printed as 1D4 mechanical pencils and markers; the count is read as applying to each." }
  - { item_id: "carpetbag-large", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'fingertooth-carpetbagger'
   AND instr(markdown, '  - { item_id: "backpack", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'ls and markers; the count is read as applying to each." }
  - { item_id: "carpetbag-large", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No catalog row exists for playing cards, pocket watch, pencil refills, bottles of alcohol, hard candies or a carpetbag; they are in the equipment restriction line.',
         'No catalog row exists for playing cards, pocket watch, pencil refills, bottles of alcohol or hard candies; they are in the equipment restriction line. Granted since ~116 and ~117: the large carpetbag as carpetbag-large, and 1D4 markers as marker (the printed 1D4 is read as applying to pencils and markers each).'),
       updated_at = datetime('now')
 WHERE class_id = 'fingertooth-carpetbagger'
   AND instr(markdown, 'No catalog row exists for playing cards, pocket watch, pencil refills, bottles of alcohol, hard candies or a carpetbag; ') > 0
   AND instr(markdown, 'rpetbag as carpetbag-large, and 1D4 markers as marker (the printed 1D4 is read as applying to pencils and markers each).') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
natural_abilities:
',
         '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
  - { item_id: "wooden-throwing-knife", qty: "1d6+1" }
  - { item_id: "silver-plated-throwing-knife", qty: "1d6+2" }
  - { item_id: "water-skin", qty: 1, note: "Wine skin." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'flooper'
   AND instr(markdown, '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'ver-plated-throwing-knife", qty: "1d6+2" }
  - { item_id: "water-skin", qty: 1, note: "Wine skin." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment also includes 1D4+1 colorful costumes, a jacket, 10 juggling pins, 1D6+1 wooden throwing knives (1D4 S.D.C., double damage to vampires), 1D6+2 silver-plated throwing knives (1D6 S.D.C.), a makeup kit, a wine skin, a pocket calculator, 1D4 ammo clips/E-Clips for each W.P., and some personal items.',
         'Standard equipment also includes 1D4+1 colorful costumes, a jacket, 10 juggling pins, a makeup kit, a pocket calculator, 1D4 ammo clips/E-Clips for each W.P., and some personal items. The 1D6+1 wooden throwing knives (1D4 S.D.C., double damage to vampires), 1D6+2 silver-plated throwing knives (1D6 S.D.C.) and the wine skin are in the equipment list.'),
       updated_at = datetime('now')
 WHERE class_id = 'flooper'
   AND instr(markdown, 'Standard equipment also includes 1D4+1 colorful costumes, a jacket, 10 juggling pins, 1D6+1 wooden throwing knives (1D4 ') > 0
   AND instr(markdown, 'ouble damage to vampires), 1D6+2 silver-plated throwing knives (1D6 S.D.C.) and the wine skin are in the equipment list.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No catalog row for costumes, jacket, juggling pins, the wooden and silver-plated throwing knives (they carry their own damage; knife-throwing is not the same item), makeup kit, wine skin or pocket calculator; the E-Clips are per W.P. and left in prose. They are a restriction line.',
         'No catalog row for costumes, jacket, juggling pins, makeup kit or pocket calculator; the E-Clips are per W.P. and left in prose. They are a restriction line. Granted since ~116 and ~117: the throwing knives as wooden-throwing-knife 1d6+1 and silver-plated-throwing-knife 1d6+2 (rows that carry their own damage; knife-throwing is not the same item), and the wine skin as water-skin.'),
       updated_at = datetime('now')
 WHERE class_id = 'flooper'
   AND instr(markdown, 'No catalog row for costumes, jacket, juggling pins, the wooden and silver-plated throwing knives (they carry their own d') > 0
   AND instr(markdown, 'ng-knife 1d6+2 (rows that carry their own damage; knife-throwing is not the same item), and the wine skin as water-skin.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
natural_abilities:
',
         '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
  - { item_id: "bowl-earthenware", qty: 1, note: "A set of clay bowls; the page prints no count." }
  - { item_id: "hammock", qty: 1, note: "A woven grass mat and/or hammock." }
  - { item_id: "forest-warden-throwing-stone", qty: "2d6+6" }
  - { item_id: "purse-satchel", qty: 1, note: "A woven grass satchel, or one stolen from a traveler." }
  - { item_id: "forest-warden-walking-stick-or-club", qty: 1 }
  - { item_id: "e-clip", qty: 2, note: "Two E-Clips for each W.P. weapon." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'forest-warden'
   AND instr(markdown, '  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'tick-or-club", qty: 1 }
  - { item_id: "e-clip", qty: 2, note: "Two E-Clips for each W.P. weapon." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The clay bowls, grass mat or hammock, throwing stones (2D6 S.D.C./1D4 M.D./2D4 M.D. power throw), grass satchel and walking stick or club have no catalog rows; the stones'' and club''s damage is a special ability and the list is a restriction line.',
         'Granted since ~116 and ~117: the clay bowls as bowl-earthenware (the page prints no count), the grass mat or hammock as hammock, the 2D6+6 throwing stones as forest-warden-throwing-stone (2D6 S.D.C./1D4 M.D./2D4 M.D. power throw), the grass satchel as purse-satchel, the walking stick or club as forest-warden-walking-stick-or-club, and the two E-Clips for each W.P. weapon as e-clip; the stones'' and club''s damage is also a special ability and the list is also a restriction line.'),
       updated_at = datetime('now')
 WHERE class_id = 'forest-warden'
   AND instr(markdown, 'The clay bowls, grass mat or hammock, throwing stones (2D6 S.D.C./1D4 M.D./2D4 M.D. power throw), grass satchel and walk') > 0
   AND instr(markdown, ' W.P. weapon as e-clip; the stones'' and club''s damage is also a special ability and the list is also a restriction line.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "backpack", qty: 1 }
restrictions:
',
         '  - { item_id: "backpack", qty: 1 }
  - { item_id: "horune-half-suit-body-armor", qty: 1 }
  - { item_id: "horune-energy-trident", qty: 1, note: "Energy trident or an M.D.C. trident." }
restrictions:
'),
       updated_at = datetime('now')
 WHERE class_id = 'horune-pirate'
   AND instr(markdown, '  - { item_id: "backpack", qty: 1 }
restrictions:
') > 0
   AND instr(markdown, ', qty: 1 }
  - { item_id: "horune-energy-trident", qty: 1, note: "Energy trident or an M.D.C. trident." }
restrictions:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment besides the stored items: a standard half suit of body armour (50 M.D.C.; other armour can be purchased or stolen), energy pistols of choice, an energy trident or M.D.C. trident, a magic Sea-Horse Scooter and a handful of personal items.',
         'Standard equipment besides the stored items: energy pistols of choice, a magic Sea-Horse Scooter and a handful of personal items. The standard half suit of body armour (50 M.D.C.; other armour can be purchased or stolen) and the energy trident or M.D.C. trident are among the stored items.'),
       updated_at = datetime('now')
 WHERE class_id = 'horune-pirate'
   AND instr(markdown, 'Standard equipment besides the stored items: a standard half suit of body armour (50 M.D.C.; other armour can be purchas') > 0
   AND instr(markdown, '50 M.D.C.; other armour can be purchased or stolen) and the energy trident or M.D.C. trident are among the stored items.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The half
    suit, the energy pistols of choice, the trident pick (the catalog has no
    M.D.C. trident row), the Sea-Horse Scooter (no catalog row) and the
    personal items are in a restrictions line.',
         'The half
    suit (horune-half-suit-body-armor) and the trident (horune-energy-trident;
    its note gives the M.D.C. trident as the alternative) are granted since
    ~116 and ~117. The energy pistols of choice, the Sea-Horse Scooter and the personal
    items are in a restrictions line. The Sea-Horse Scooter is not granted:
    this book only names it and stats nothing, and the catalog''s
    horune-sea-horse-sled-and-speeder vessel row is from Underseas and is a
    different entry.'),
       updated_at = datetime('now')
 WHERE class_id = 'horune-pirate'
   AND instr(markdown, 'The half
    suit, the energy pistols of choice, the trident pick (the catalog has no
    M.D.C. trident row), the Sea-H') > 0
   AND instr(markdown, 'hing, and the catalog''s
    horune-sea-horse-sled-and-speeder vessel row is from Underseas and is a
    different entry.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
',
         '  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "purse-satchel", qty: 1, note: "A medium-sized or large satchel with a sturdy shoulder strap." }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "mechanical-pencil-lead-24-in-a-pack", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'loronoid'
   AND instr(markdown, '  - { item_id: "pocket-mirror", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, '  - { item_id: "marker", qty: "1d4" }
  - { item_id: "mechanical-pencil-lead-24-in-a-pack", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No catalog rows, not stored and not statted: hip flask of rum, 1D6+1 cigars, medium or large satchel, medium shoulder bag, journal, 1D4 markers, bottle opener;',
         'Granted since ~116 and ~117: the medium or large satchel as purse-satchel, the 1D4 markers as marker, and the pencil''s 24 replacement leads as mechanical-pencil-lead-24-in-a-pack. No catalog rows, not stored and not statted: hip flask of rum, 1D6+1 cigars, medium shoulder bag, journal, bottle opener;'),
       updated_at = datetime('now')
 WHERE class_id = 'loronoid'
   AND instr(markdown, 'No catalog rows, not stored and not statted: hip flask of rum, 1D6+1 cigars, medium or large satchel, medium shoulder ba') > 0
   AND instr(markdown, 'o catalog rows, not stored and not statted: hip flask of rum, 1D6+1 cigars, medium shoulder bag, journal, bottle opener;') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "air-filter", qty: 1 }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
',
         '  - { item_id: "air-filter", qty: 1 }
  - { item_id: "knife-small", qty: 1, note: "Whittling knife; a tool, the page lists Weapons: None." }
  - { item_id: "pocket-purse-small", qty: 1, note: "Purse; the page prints no size." }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
'),
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial'
   AND instr(markdown, '  - { item_id: "air-filter", qty: 1 }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need') > 0
   AND instr(markdown, 'ts no size." }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The personal jewelry, loincloth, whittling knife and purse of that line have no catalog row and are a restrictions line;',
         'The whittling knife and purse of that line are granted since ~116 and ~117, as knife-small (a tool; the page lists Weapons: None) and pocket-purse-small (the page prints no size). The personal jewelry and loincloth of that line have no catalog row; all four are named in a restrictions line;'),
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial'
   AND instr(markdown, 'The personal jewelry, loincloth, whittling knife and purse of that line have no catalog row and are a restrictions line;') > 0
   AND instr(markdown, 'o size). The personal jewelry and loincloth of that line have no catalog row; all four are named in a restrictions line;') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "sack", qty: "1d4+1" }
natural_abilities:
',
         '  - { item_id: "sack", qty: "1d4+1" }
  - { item_id: "sling", qty: 1, note: "With normal and silver bullets (1D6 S.D.C., double damage to vampires); grenades can also be thrown with it." }
  - { item_id: "purse-satchel", qty: 1, note: "Satchel." }
  - { item_id: "water-skin", qty: 2, note: "A waterskin, and a second kept as a blood bottle: a waterskin holding blood for drinking." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'lyvorrk'
   AND instr(markdown, '  - { item_id: "sack", qty: "1d4+1" }
natural_abilities:
') > 0
   AND instr(markdown, ' note: "A waterskin, and a second kept as a blood bottle: a waterskin holding blood for drinking." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row: sling with normal and silver bullets (1D6 S.D.C., double damage to vampires; may also throw grenades), satchel, waterskin, blood bottle, one M.D. weapon (probably a Vibro-Blade or energy pistol),',
         'Granted since ~116 and ~117, to every Lyvorrk although the book gives them to one taking the R.C.C. and not to one who takes the Body Doc or a Magic O.C.C., who has that O.C.C.''s equipment instead (the condition is the player''s to honour): the sling with normal and silver bullets (1D6 S.D.C., double damage to vampires; may also throw grenades) as sling, the satchel as purse-satchel, and the waterskin and the blood bottle as two water-skin. NOT STORED, no catalog row: one M.D. weapon (probably a Vibro-Blade or energy pistol),'),
       updated_at = datetime('now')
 WHERE class_id = 'lyvorrk'
   AND instr(markdown, 'NOT STORED, no catalog row: sling with normal and silver bullets (1D6 S.D.C., double damage to vampires; may also throw ') > 0
   AND instr(markdown, 'e blood bottle as two water-skin. NOT STORED, no catalog row: one M.D. weapon (probably a Vibro-Blade or energy pistol),') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'R.C.C. equipment the catalog has no row for: a sling with normal and silver
bullets (1D6 S.D.C., double damage to vampires) that can also throw grenades,
a satchel, a waterskin, a blood bottle (a waterskin of blood for drinking),
one M.D. weapon (probably a Vibro-Blade or energy pistol), 2D6+4 live
poisonous snakes (probably rattlers), a Gila Monster and 1D6+2 lizards. Also
1D6x100 credits in tradeable goods.',
         'R.C.C. equipment the catalog has no row for: one M.D. weapon (probably a
Vibro-Blade or energy pistol), 2D6+4 live poisonous snakes (probably
rattlers), a Gila Monster and 1D6+2 lizards. Also 1D6x100 credits in
tradeable goods.

The sling, satchel, waterskin and blood bottle (a waterskin of blood for
drinking) are the kit of a Lyvorrk taking the R.C.C.; one who takes the Body
Doc or a Magic O.C.C. has that O.C.C.''s equipment instead. The sling''s normal
and silver bullets do 1D6 S.D.C. (double damage to vampires), and it can also
throw grenades.'),
       updated_at = datetime('now')
 WHERE class_id = 'lyvorrk'
   AND instr(markdown, 'R.C.C. equipment the catalog has no row for: a sling with normal and silver
bullets (1D6 S.D.C., double damage to vampir') > 0
   AND instr(markdown, 'nstead. The sling''s normal
and silver bullets do 1D6 S.D.C. (double damage to vampires), and it can also
throw grenades.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
natural_abilities:
',
         '  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
  - { item_id: "water-skin-half-gallon", qty: 1 }
  - { item_id: "mraghiile-patchwork-armor", qty: 1, note: "M.D.C. is rolled: 2D6+17." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'mraghiile-tree-man'
   AND instr(markdown, '  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'n", qty: 1 }
  - { item_id: "mraghiile-patchwork-armor", qty: 1, note: "M.D.C. is rolled: 2D6+17." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row: waterskin and the makeshift patchwork M.D.C. armor (not environmental, 2D6+17 M.D.C.);',
         'Granted since ~116 and ~117: the waterskin as water-skin-half-gallon and the makeshift patchwork M.D.C. armor (not environmental, 2D6+17 M.D.C.) as mraghiile-patchwork-armor;'),
       updated_at = datetime('now')
 WHERE class_id = 'mraghiile-tree-man'
   AND instr(markdown, 'NOT STORED, no catalog row: waterskin and the makeshift patchwork M.D.C. armor (not environmental, 2D6+17 M.D.C.);') > 0
   AND instr(markdown, 'in-half-gallon and the makeshift patchwork M.D.C. armor (not environmental, 2D6+17 M.D.C.) as mraghiile-patchwork-armor;') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "tool-kit", qty: 1 }
natural_abilities:
',
         '  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "wilk-s-portable-laser-torch-tool", qty: 1, note: "The book says a portable laser-welding torch and names no maker." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'malvoren'
   AND instr(markdown, '  - { item_id: "tool-kit", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'aser-torch-tool", qty: 1, note: "The book says a portable laser-welding torch and names no maker." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row: a portable laser-welding torch, basic electrical tools and personal items.',
         'The portable laser-welding torch is granted since ~116 and ~117 as wilk-s-portable-laser-torch-tool (the book names no maker). NOT STORED, no catalog row: basic electrical tools and personal items.'),
       updated_at = datetime('now')
 WHERE class_id = 'malvoren'
   AND instr(markdown, 'NOT STORED, no catalog row: a portable laser-welding torch, basic electrical tools and personal items.') > 0
   AND instr(markdown, 'table-laser-torch-tool (the book names no maker). NOT STORED, no catalog row: basic electrical tools and personal items.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Starting equipment the catalog has no row for: a portable laser-welding torch,
basic electrical tools and personal items.',
         'Starting equipment the catalog has no row for: basic electrical tools and
personal items.'),
       updated_at = datetime('now')
 WHERE class_id = 'malvoren'
   AND instr(markdown, 'Starting equipment the catalog has no row for: a portable laser-welding torch,
basic electrical tools and personal items') > 0
   AND instr(markdown, 'Starting equipment the catalog has no row for: basic electrical tools and
personal items.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '
restrictions:
  - "Alignment: any, but lean toward Scrupulous (20%), Unprincipled (20%), Anarchist (20%) and Aberrant (10%)."
',
         '
equipment_starting:
  - { choose: 2, label: "two inherited Nuhr Rune Weapons", qty: 1, from: ["nuhr-rune-axe", "nuhr-rune-ball-and-chain", "nuhr-rune-morning-star", "nuhr-rune-hook-with-handle", "nuhr-rune-grappling-hook-and-rope", "nuhr-rune-knife", "nuhr-rune-short-sword", "nuhr-rune-large-sword", "tw-nuhr-firebolt-pistol", "tw-nuhr-firebolt-musket"] }
  - { choose: 1, label: "inherited armor: typically a Talisman of Armor or Studded Leather", qty: 1, from: ["nuhr-studded-leather-rune-armor", "talisman-of-armor"] }
restrictions:
  - "Alignment: any, but lean toward Scrupulous (20%), Unprincipled (20%), Anarchist (20%) and Aberrant (10%)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'nuhr-dwarf'
   AND instr(markdown, '
restrictions:
  - "Alignment: any, but lean toward Scrupulous (20%), Unprincipled (20%), Anarchist (20%) and Aberrant (') > 0
   AND instr(markdown, '-of-armor"] }
restrictions:
  - "Alignment: any, but lean toward Scrupulous (20%), Unprincipled (20%), Anarchist (20%) a') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'EQUIPMENT: NOT STORED, no catalog row: the two inherited Nuhr Rune Weapons and suit of armor, and every Nuhr Rune item, which is a special ability with its printed stats.',
         'EQUIPMENT: the inheritance is granted since ~116 and ~117 as two choice lines. Two inherited Nuhr Rune Weapons are chosen from the eight melee rows (nuhr-rune-axe, nuhr-rune-ball-and-chain, nuhr-rune-morning-star, nuhr-rune-hook-with-handle, nuhr-rune-grappling-hook-and-rope, nuhr-rune-knife, nuhr-rune-short-sword, nuhr-rune-large-sword) and the two held firearms tw-nuhr-firebolt-pistol and tw-nuhr-firebolt-musket (the Rifts Book of Magic''s rows for the Nuhr Rune Musket Pistol and Rifle, same figures). One inherited armor is chosen from nuhr-studded-leather-rune-armor or talisman-of-armor, the two the book calls typical. Three more rows exist that the class does not grant: nuhr-leather-and-chain-mail-rune-armor and nuhr-chain-mail-rune-armor, which are not the typical inherited suit, and nuhr-rune-pirate-ship-cannon, which is a ship''s gun and not a held weapon. The special ability keeps the printed stats of every Nuhr Rune item.'),
       updated_at = datetime('now')
 WHERE class_id = 'nuhr-dwarf'
   AND instr(markdown, 'EQUIPMENT: NOT STORED, no catalog row: the two inherited Nuhr Rune Weapons and suit of armor, and every Nuhr Rune item, ') > 0
   AND instr(markdown, 'annon, which is a ship''s gun and not a held weapon. The special ability keeps the printed stats of every Nuhr Rune item.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '
restrictions:
  - "Alignment: any, but mostly Principled (48%), Scrupulous (30%), Unprincipled (10%) or Aberrant (8%)."
',
         '
equipment_starting:
  - { item_id: "obsedai-stone-weapon", qty: 1, note: "A stone axe, sword or maul, the player''s pick of form." }
restrictions:
  - "Alignment: any, but mostly Principled (48%), Scrupulous (30%), Unprincipled (10%) or Aberrant (8%)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'obsedai'
   AND instr(markdown, '
restrictions:
  - "Alignment: any, but mostly Principled (48%), Scrupulous (30%), Unprincipled (10%) or Aberrant (8%)."') > 0
   AND instr(markdown, '''s pick of form." }
restrictions:
  - "Alignment: any, but mostly Principled (48%), Scrupulous (30%), Unprincipled (10%)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'EQUIPMENT: the stone weapon has no catalog row and is a special ability with its stats.',
         'EQUIPMENT: the stone weapon is granted since ~116 and ~117 as obsedai-stone-weapon (a stone axe, sword or maul, the player''s pick of form); the special ability keeps its stats.'),
       updated_at = datetime('now')
 WHERE class_id = 'obsedai'
   AND instr(markdown, 'EQUIPMENT: the stone weapon has no catalog row and is a special ability with its stats.') > 0
   AND instr(markdown, '17 as obsedai-stone-weapon (a stone axe, sword or maul, the player''s pick of form); the special ability keeps its stats.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-h5-holdout-ion-pistol"] }
natural_abilities:
',
         '  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "work-boots-rifts", qty: 1 }
  - { item_id: "note-pad", qty: 1, note: "The book says notebooks and gives no number." }
  - { item_id: "pen", qty: 1, note: "The book gives no number." }
  - { item_id: "pencil", qty: 1, note: "The book gives no number." }
  - { item_id: "duffle-bag", qty: 2 }
  - { item_id: "specimen-jar", qty: 1, note: "Assorted jars for embalmed parts; the book gives no number." }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'posluznik'
   AND instr(markdown, '  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c') > 0
   AND instr(markdown, 'em_id: "specimen-jar", qty: 1, note: "Assorted jars for embalmed parts; the book gives no number." }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT STORED, no catalog row: sturdy boots, medical scrubs, notebooks, pens and pencils, hand sanitizer, two duffel bags, jars for embalmed parts, multi-tool, books and data libraries; they are in GM Notes.',
         'Granted since ~116 and ~117: sturdy boots as work-boots-rifts, notebooks as note-pad, pens as pen, pencils as pencil, the two duffel bags as duffle-bag x2 and the jars for embalmed parts as specimen-jar (the book gives no number for the notebooks, pens, pencils or jars). NOT STORED, no catalog row: medical scrubs, hand sanitizer, multi-tool, books and data libraries; they are in GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'posluznik'
   AND instr(markdown, 'NOT STORED, no catalog row: sturdy boots, medical scrubs, notebooks, pens and pencils, hand sanitizer, two duffel bags, ') > 0
   AND instr(markdown, ' NOT STORED, no catalog row: medical scrubs, hand sanitizer, multi-tool, books and data libraries; they are in GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Also carried, with no catalog row: sturdy boots, medical scrubs,
notebooks, pens and pencils, hand sanitizer, two duffel bags, jars for
embalmed parts, a multi-tool, books on anatomy, science and local laws,
and data libraries of medical texts.',
         'Also carried, with no catalog row: medical scrubs, hand sanitizer, a
multi-tool, books on anatomy, science and local laws, and data libraries
of medical texts.'),
       updated_at = datetime('now')
 WHERE class_id = 'posluznik'
   AND instr(markdown, 'Also carried, with no catalog row: sturdy boots, medical scrubs,
notebooks, pens and pencils, hand sanitizer, two duffel') > 0
   AND instr(markdown, 'cal scrubs, hand sanitizer, a
multi-tool, books on anatomy, science and local laws, and data libraries
of medical texts.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '
restrictions:
  - "Alignment: any, though most are Anarchist (15%), Miscreant (35%), Diabolic (30%) or Aberrant (10%)."
',
         '
equipment_starting:
  - { item_id: "borrowed-ash-pouch", qty: 1 }
restrictions:
  - "Alignment: any, though most are Anarchist (15%), Miscreant (35%), Diabolic (30%) or Aberrant (10%)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'septumbran-witch-wolf'
   AND instr(markdown, '
restrictions:
  - "Alignment: any, though most are Anarchist (15%), Miscreant (35%), Diabolic (30%) or Aberrant (10%)."') > 0
   AND instr(markdown, 'sh-pouch", qty: 1 }
restrictions:
  - "Alignment: any, though most are Anarchist (15%), Miscreant (35%), Diabolic (30%) ') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'EQUIPMENT: STATTED ITEMS WITH NO CATALOG ROW: the Borrowed Ash Pouch (save bonuses) and the patchwork armor (3D6+28 M.D.C., printed on the M.D.C. line); both are special abilities with their stats, nothing in equipment_starting. Otherwise As per O.C.C.',
         'EQUIPMENT: the Borrowed Ash Pouch (save bonuses) is granted as borrowed-ash-pouch since ~116 and ~117 and is also a special ability with its stats. The patchwork armor (3D6+28 M.D.C.) is the row septumbran-patchwork-armor and is not granted, because the book prints it on the race''s M.D.C. line, not in its equipment; it is a special ability with its stats. Otherwise As per O.C.C.'),
       updated_at = datetime('now')
 WHERE class_id = 'septumbran-witch-wolf'
   AND instr(markdown, 'EQUIPMENT: STATTED ITEMS WITH NO CATALOG ROW: the Borrowed Ash Pouch (save bonuses) and the patchwork armor (3D6+28 M.D.') > 0
   AND instr(markdown, 'ints it on the race''s M.D.C. line, not in its equipment; it is a special ability with its stats. Otherwise As per O.C.C.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '
restrictions:
  - "Alignment: any, but tend to be Principled (20%), Scrupulous (25%), Unprincipled (20%) and Anarchist (30%)."
',
         '
equipment_starting:
  - { item_id: "e-clip", qty: "1d4", note: "As appropriate to the weapons chosen." }
  - { item_id: "shale-bogle-patchwork-armor", qty: 1 }
  - { item_id: "shovel", qty: 1, note: "A folding shovel." }
  - { item_id: "small-sack", qty: 1 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "blanket-light-rifts", qty: 1 }
  - { choose: 1, label: "water skin or canteen", qty: 1, from: ["waterskin-half-gallon", "canteen"] }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
restrictions:
  - "Alignment: any, but tend to be Principled (20%), Scrupulous (25%), Unprincipled (20%) and Anarchist (30%)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'shale-bogle'
   AND instr(markdown, '
restrictions:
  - "Alignment: any, but tend to be Principled (20%), Scrupulous (25%), Unprincipled (20%) and Anarchist ') > 0
   AND instr(markdown, 's", qty: 1 }
restrictions:
  - "Alignment: any, but tend to be Principled (20%), Scrupulous (25%), Unprincipled (20%) an') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Nothing is stored in equipment_starting: it applies to hunters and adventurers only, and the patchwork armor, folding shovel, blanket and water skin have no catalog rows (not stubbed); see GM Notes.',
         'Since ~116 and ~117 the list is granted in equipment_starting: the E-Clips, the patchwork armor (shale-bogle-patchwork-armor), the folding shovel (shovel), both sacks, the backpack, the blanket (blanket-light-rifts), a choice of water skin or canteen, the tinted goggles and the traveling clothes. One weapon per W.P. is not given as items. The book gives the list only to a male hunter/defender or a Bogle who goes adventuring, a condition the player honours; see GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'shale-bogle'
   AND instr(markdown, 'Nothing is stored in equipment_starting: it applies to hunters and adventurers only, and the patchwork armor, folding sh') > 0
   AND instr(markdown, 's the list only to a male hunter/defender or a Bogle who goes adventuring, a condition the player honours; see GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "sunglasses-or-goggles-cheap", qty: 1 }
natural_abilities:
',
         '  - { item_id: "sunglasses-or-goggles-cheap", qty: 1 }
  - { item_id: "gloves", qty: "1d4" }
  - { item_id: "boots", qty: 1, note: "Oversized." }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "shaper-light-partial-armor", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'shaper'
   AND instr(markdown, '  - { item_id: "sunglasses-or-goggles-cheap", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'rsized." }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "shaper-light-partial-armor", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Not stored, no catalog rows and not stubbed: one weapon and an extra ammo clip per W.P., a bag of hats, colorful scarves, 1D4 sets of gloves, oversized boots, clothing, a set of light partial armor (2D6+20 M.D.C.), 1D4 tubes of lipstick,',
         'Granted since ~116 and ~117: 1D4 sets of gloves (gloves), oversized boots (boots), clothing and the set of light partial armor (shaper-light-partial-armor, 2D6+20 M.D.C.). One weapon and an extra ammo clip per W.P. is not given as items. Not stored, no catalog rows and not stubbed: a bag of hats, colorful scarves, 1D4 tubes of lipstick,'),
       updated_at = datetime('now')
 WHERE class_id = 'shaper'
   AND instr(markdown, 'Not stored, no catalog rows and not stubbed: one weapon and an extra ammo clip per W.P., a bag of hats, colorful scarves') > 0
   AND instr(markdown, 'not given as items. Not stored, no catalog rows and not stubbed: a bag of hats, colorful scarves, 1D4 tubes of lipstick,') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "e-clip", qty: "1d6" }
natural_abilities:
',
         '  - { item_id: "e-clip", qty: "1d6" }
  - { item_id: "shemarrian-rail-gun", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'shemarrian-warrior'
   AND instr(markdown, '  - { item_id: "e-clip", qty: "1d6" }
natural_abilities:
') > 0
   AND instr(markdown, '  - { item_id: "e-clip", qty: "1d6" }
  - { item_id: "shemarrian-rail-gun", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The Shemarrian Rail Gun has no catalog row and is a special ability with its printed stats (not stubbed); personal items not stored.',
         'The Shemarrian Rail Gun is granted as shemarrian-rail-gun since ~116 and ~117 and is also a special ability with its printed stats; personal items not stored.'),
       updated_at = datetime('now')
 WHERE class_id = 'shemarrian-warrior'
   AND instr(markdown, 'The Shemarrian Rail Gun has no catalog row and is a special ability with its printed stats (not stubbed); personal items') > 0
   AND instr(markdown, 'shemarrian-rail-gun since ~116 and ~117 and is also a special ability with its printed stats; personal items not stored.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "hunting-knife", qty: 1 }
natural_abilities:
',
         '  - { item_id: "hunting-knife", qty: 1 }
  - { item_id: "knife-sheath", qty: 1 }
  - { item_id: "swamp-sludger-partial-armor", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'swamp-sludger'
   AND instr(markdown, '  - { item_id: "hunting-knife", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, ': 1 }
  - { item_id: "knife-sheath", qty: 1 }
  - { item_id: "swamp-sludger-partial-armor", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'No catalog row, not stored: loincloth, knife scabbard and partial armor (4D6+28 M.D.C.); the armor figure is in GM Notes.',
         'Granted since ~116 and ~117: the knife scabbard (knife-sheath) and the partial armor (swamp-sludger-partial-armor, 4D6+28 M.D.C.); the armor figure is also in GM Notes. No catalog row, not stored: loincloth.'),
       updated_at = datetime('now')
 WHERE class_id = 'swamp-sludger'
   AND instr(markdown, 'No catalog row, not stored: loincloth, knife scabbard and partial armor (4D6+28 M.D.C.); the armor figure is in GM Notes') > 0
   AND instr(markdown, 'wamp-sludger-partial-armor, 4D6+28 M.D.C.); the armor figure is also in GM Notes. No catalog row, not stored: loincloth.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "portable-language-translator", qty: 1 }
natural_abilities:
',
         '  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "vintex-medium-armor", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
natural_abilities:
'),
       updated_at = datetime('now')
 WHERE class_id = 'vintex-warrior'
   AND instr(markdown, '  - { item_id: "portable-language-translator", qty: 1 }
natural_abilities:
') > 0
   AND instr(markdown, 'slator", qty: 1 }
  - { item_id: "vintex-medium-armor", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
natural_abilities:
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Not stored, no catalog row or no named item: suit of medium or non-environmental armor (4D6+40 M.D.C.), one weapon for each W.P., 1D4 pieces of white chalk, a can of spray paint, notebook and personal items.',
         'Granted since ~116 and ~117: the suit of medium or non-environmental armor (vintex-medium-armor, 4D6+40 M.D.C.) and the notebook (note-pad). One weapon for each W.P. is not given as items. Not stored, no catalog row or no named item: 1D4 pieces of white chalk, a can of spray paint and personal items.'),
       updated_at = datetime('now')
 WHERE class_id = 'vintex-warrior'
   AND instr(markdown, 'Not stored, no catalog row or no named item: suit of medium or non-environmental armor (4D6+40 M.D.C.), one weapon for e') > 0
   AND instr(markdown, ' items. Not stored, no catalog row or no named item: 1D4 pieces of white chalk, a can of spray paint and personal items.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - { item_id: "sketch-pad", qty: 1 }
extraction_notes: |
',
         '  - { item_id: "sketch-pad", qty: 1 }
  - { item_id: "e-clip", qty: "1d4+1", note: "For each weapon that needs one (or ammo-clips)." }
  - { item_id: "purse-satchel", qty: 1, note: "A shoulder bag." }
  - { item_id: "yhabbayar-bubble-solution-waterskin", qty: 1 }
  - { item_id: "yhabbayar-bubble-ring", qty: "1d6" }
extraction_notes: |
'),
       updated_at = datetime('now')
 WHERE class_id = 'yhabbayar'
   AND instr(markdown, '  - { item_id: "sketch-pad", qty: 1 }
extraction_notes: |
') > 0
   AND instr(markdown, 'yhabbayar-bubble-solution-waterskin", qty: 1 }
  - { item_id: "yhabbayar-bubble-ring", qty: "1d6" }
extraction_notes: |
') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Also carries, with no catalog row and so not given as items: one weapon for each W.P. with 1D4+1 E-Clips or ammo-clips for each weapon that needs one, a shoulder bag, a waterskin of bubble solution, 1D6 rings for blowing bubbles, a comb and other personal items; many also have a digital camera with a variety of lenses.',
         'One weapon for each W.P. is not given as items. Also carries, with no catalog row and so not given as items: a comb and other personal items. Many also have a digital camera with a variety of lenses; it is not given as an item, since not every Yhabbayar has one.'),
       updated_at = datetime('now')
 WHERE class_id = 'yhabbayar'
   AND instr(markdown, 'Also carries, with no catalog row and so not given as items: one weapon for each W.P. with 1D4+1 E-Clips or ammo-clips f') > 0
   AND instr(markdown, 'Many also have a digital camera with a variety of lenses; it is not given as an item, since not every Yhabbayar has one.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Added and kept as a restrictions line because
    no catalog row fits: shoulder bag, waterskin with bubble solution, 1D6 rings for
    blowing bubbles, a comb and other personal items, one weapon for each W.P. with
    1D4+1 E-Clips/ammo-clips each.',
         'Added and granted since ~116 and ~117: the shoulder bag
    (purse-satchel), the waterskin with bubble solution, 1D6 rings for blowing bubbles
    (yhabbayar-bubble-solution-waterskin, yhabbayar-bubble-ring) and 1D4+1
    E-Clips/ammo-clips (e-clip). Kept as a restrictions line: a comb and other personal
    items, which no catalog row fits, and one weapon for each W.P., which is not given
    as items. The digital camera is not granted: the book says only that many
    have one.'),
       updated_at = datetime('now')
 WHERE class_id = 'yhabbayar'
   AND instr(markdown, 'Added and kept as a restrictions line because
    no catalog row fits: shoulder bag, waterskin with bubble solution, 1D6') > 0
   AND instr(markdown, 'ach W.P., which is not given
    as items. The digital camera is not granted: the book says only that many
    have one.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'are described but given to no character and have no catalog rows; they are in GM Notes, not stubbed.',
         'are described but given to no character, so the class grants none; since ~116 and ~117 they are the rows spinne-light-force-field, spinne-medium-force-field, spinne-heavy-force-field and spinne-super-heavy-force-field, and they are also in GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'spinne'
   AND instr(markdown, 'are described but given to no character and have no catalog rows; they are in GM Notes, not stubbed.') > 0
   AND instr(markdown, ', spinne-medium-force-field, spinne-heavy-force-field and spinne-super-heavy-force-field, and they are also in GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'It also keeps the body warm during cool periods. Not a catalog item.',
         'It also keeps the body warm during cool periods. Not a starting item: the military collar is the soldiers'' only, and not every refugee has one.'),
       updated_at = datetime('now')
 WHERE class_id = 'vernulian'
   AND instr(markdown, 'It also keeps the body warm during cool periods. Not a catalog item.') > 0
   AND instr(markdown, 'warm during cool periods. Not a starting item: the military collar is the soldiers'' only, and not every refugee has one.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Statted items with no catalog row, not stored as gear: the force field collar (160 M.D.C. military, 100 M.D.C. commercial; regenerates 10 an hour; 12 hours a day) is a special ability; the Serpent Power Armor (',
         'The force field collar (160 M.D.C. military, 100 M.D.C. commercial; regenerates 10 an hour; 12 hours a day) is a special ability and, since ~116 and ~117, the rows vernulian-force-field-collar-military and vernulian-force-field-collar-commercial; the class grants neither, because the military collar is the soldiers'' only and about 30% of refugees have the commercial one. Statted items with no catalog row, not stored as gear: the Serpent Power Armor ('),
       updated_at = datetime('now')
 WHERE class_id = 'vernulian'
   AND instr(markdown, 'Statted items with no catalog row, not stored as gear: the force field collar (160 M.D.C. military, 100 M.D.C. commercia') > 0
   AND instr(markdown, '0% of refugees have the commercial one. Statted items with no catalog row, not stored as gear: the Serpent Power Armor (') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'every new row a class lists exists in gear' AS assertion, count(*) AS got, 36 AS want
  FROM gear g
 WHERE g.source_book LIKE 'Rifts World Book 30: D-Bees of North America%'
   AND EXISTS (SELECT 1 FROM imported_classes c WHERE instr(c.markdown, '"' || g.slug || '"') > 0);

SELECT 'part 1: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'adna-nomad' AND length(markdown) = 10638)
    OR (class_id = 'akysse-tribal-hunter' AND length(markdown) = 8731)
    OR (class_id = 'blind-warrior-women' AND length(markdown) = 17513)
    OR (class_id = 'amana' AND length(markdown) = 15466)
    OR (class_id = 'crab-warrior' AND length(markdown) = 14107)
    OR (class_id = 'darkhound' AND length(markdown) = 21566)
    OR (class_id = 'faerie-bot' AND length(markdown) = 21681)
    OR (class_id = 'feni-nomad' AND length(markdown) = 11855)
    OR (class_id = 'fingertooth-carpetbagger' AND length(markdown) = 9483)
    OR (class_id = 'flooper' AND length(markdown) = 12338)
    OR (class_id = 'forest-warden' AND length(markdown) = 13096)
    OR (class_id = 'horune-pirate' AND length(markdown) = 18663);

SELECT 'part 2: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'loronoid' AND length(markdown) = 13617)
    OR (class_id = 'lyn-srial' AND length(markdown) = 14024)
    OR (class_id = 'lyvorrk' AND length(markdown) = 16552)
    OR (class_id = 'mraghiile-tree-man' AND length(markdown) = 11944)
    OR (class_id = 'malvoren' AND length(markdown) = 17412)
    OR (class_id = 'nuhr-dwarf' AND length(markdown) = 10346)
    OR (class_id = 'obsedai' AND length(markdown) = 13367)
    OR (class_id = 'posluznik' AND length(markdown) = 12490)
    OR (class_id = 'septumbran-witch-wolf' AND length(markdown) = 8995)
    OR (class_id = 'shale-bogle' AND length(markdown) = 11463)
    OR (class_id = 'shaper' AND length(markdown) = 12149)
    OR (class_id = 'shemarrian-warrior' AND length(markdown) = 16825);

SELECT 'part 3: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'swamp-sludger' AND length(markdown) = 9232)
    OR (class_id = 'vintex-warrior' AND length(markdown) = 12159)
    OR (class_id = 'yhabbayar' AND length(markdown) = 30751)
    OR (class_id = 'spinne' AND length(markdown) = 16300)
    OR (class_id = 'vernulian' AND length(markdown) = 11410);

INSERT INTO data_script_runs (filename) VALUES ('~117-d-bees-classes-take-their-gear.sql');
