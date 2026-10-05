-- The stale-notes sweep, part 1 of 2: sentences in class records that say
-- the catalog lacks something it now holds.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~124-stale-notes-sweep-part-1.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~124-stale-notes-sweep-part-1.sql
--
-- Close-out package A14, last of Phase A. A note describing a limit that has
-- been lifted tells the next reader not to try, and nothing fails when it
-- goes stale. Every published class was searched for sentences saying a
-- thing "has no catalog row", "is not in the catalog" or the like: 484
-- sentences in 293 classes. Four read-only passes asked production whether
-- each named thing has a row today, with a near-match rule (a similar word
-- is not the thing): 71 sentences were false. The clear-cut ones are
-- corrected here; the ones that turn on judgement (a row from another game
-- system, a named model standing in for a generic item) are left and listed
-- in the PR.
--
-- A corrected sentence says the row exists and that the class still stores
-- what it stored. NOTHING A CLASS GRANTS CHANGES, with one exception: the
-- Jungle Elf's occupation list gains african-priest, rain-maker and
-- medicine-man, which its own note said to add once they were imported. The
-- generator parsed every class before and after and refuses any other
-- difference outside notes, descriptions and prose.
--
-- Also here: four classes' "add it by hand" notes that ~122/~123 made false.
--
-- Every replace() is guarded and a second run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: 29 class rows.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book says one medium size sack; the catalog has no medium.',
         'The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack.'),
       updated_at = datetime('now')
 WHERE class_id = 'apok'
   AND instr(markdown, 'The book says one medium size sack; the catalog has no medium.') > 0
   AND instr(markdown, 'The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Medical carries +5% on Paramedic only: add it to that skill by hand.',
         'Medical carries +5% on Paramedic only: the second Medical entry carries it.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon'
   AND instr(markdown, 'Medical carries +5% on Paramedic only: add it to that skill by hand.') > 0
   AND instr(markdown, 'Medical carries +5% on Paramedic only: the second Medical entry carries it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a category bonus applies to every pick in it, so no bonus is stored and the +5 is a note.',
         'a category bonus applies to every pick in it, so the second Medical entry, limited to Paramedic, carries the +5.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon'
   AND instr(markdown, 'a category bonus applies to every pick in it, so no bonus is stored and the +5 is a note.') > 0
   AND instr(markdown, 'a category bonus applies to every pick in it, so the second Medical entry, limited to Paramedic, carries the +5.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Medical carries +5% on Paramedic only: add it to that skill by hand.',
         'Medical carries +5% on Paramedic only: the second Medical entry carries it.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-spectral-hunter'
   AND instr(markdown, 'Medical carries +5% on Paramedic only: add it to that skill by hand.') > 0
   AND instr(markdown, 'Medical carries +5% on Paramedic only: the second Medical entry carries it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Medical +5% on paramedic only is a note, as for the race.',
         'Medical +5% on paramedic only is carried by the second Medical entry, as for the race.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-spectral-hunter'
   AND instr(markdown, 'Medical +5% on paramedic only is a note, as for the race.') > 0
   AND instr(markdown, 'Medical +5% on paramedic only is carried by the second Medical entry, as for the race.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The saddle, the camping kit and the Blood Lizard mount itself have no catalog row and are not stubbed; the mount is the Blood Lizard R.C.C.',
         'The saddle and the camping kit have no catalog row and are not stubbed. The Blood Lizard mount has a creature row now (blood-lizard, South America 2 p.137-138); the class does not grant or list it. The mount is the Blood Lizard R.C.C.'),
       updated_at = datetime('now')
 WHERE class_id = 'blood-rider'
   AND instr(markdown, 'The saddle, the camping kit and the Blood Lizard mount itself have no catalog row and are not stubbed; the mount is the ') > 0
   AND instr(markdown, 'now (blood-lizard, South America 2 p.137-138); the class does not grant or list it. The mount is the Blood Lizard R.C.C.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a first-aid kit with extra bandages and antiseptic, a bedroll, a belt, boots, a notepad and personal items have no catalog row.',
         'antiseptic, a belt, boots and personal items have no catalog row. Rows exist now for the first-aid kit, the extra bandages, the bedroll and the notepad (first-aid-kit, bandages-6-foot-1-8-m-roll, bedroll-rifts, note-pad); the class does not list them.'),
       updated_at = datetime('now')
 WHERE class_id = 'bogatyr-hero-knight'
   AND instr(markdown, 'a first-aid kit with extra bandages and antiseptic, a bedroll, a belt, boots, a notepad and personal items have no catal') > 0
   AND instr(markdown, 'roll and the notepad (first-aid-kit, bandages-6-foot-1-8-m-roll, bedroll-rifts, note-pad); the class does not list them.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the good quality riding horse and the one unearthly riding animal (probably a Horned Steed) under Vehicle have no row.',
         'the good quality riding horse and the one unearthly riding animal (probably a Horned Steed) under Vehicle have rows now (gear riding-horse; creature horned-steed, Warlords of Russia p.165-166), and the class does not grant or list either.'),
       updated_at = datetime('now')
 WHERE class_id = 'cossack'
   AND instr(markdown, 'the good quality riding horse and the one unearthly riding animal (probably a Horned Steed) under Vehicle have no row.') > 0
   AND instr(markdown, 'w (gear riding-horse; creature horned-steed, Warlords of Russia p.165-166), and the class does not grant or list either.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'bedroll, belt, boots, cloak or cape (often fur) and personal items have no row',
         'belt, boots and personal items have no row; the bedroll and the cloak or cape (often fur) are not listed, though rows exist now (bedroll-rifts, cape-or-cloak-long)'),
       updated_at = datetime('now')
 WHERE class_id = 'cossack'
   AND instr(markdown, 'bedroll, belt, boots, cloak or cape (often fur) and personal items have no row') > 0
   AND instr(markdown, ' the bedroll and the cloak or cape (often fur) are not listed, though rows exist now (bedroll-rifts, cape-or-cloak-long)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'which no catalog row covers (samurai-armor is the True Samurai''s magic armor); the choice offers the samurai-styled HA-5 and HA-7 first',
         'which has a catalog row now (cyber-samurai-armor; samurai-armor is the True Samurai''s magic armor) that the choice does not list; the choice still offers the samurai-styled HA-5 and HA-7 first'),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-samurai'
   AND instr(markdown, 'which no catalog row covers (samurai-armor is the True Samurai''s magic armor); the choice offers the samurai-styled HA-5') > 0
   AND instr(markdown, 'rue Samurai''s magic armor) that the choice does not list; the choice still offers the samurai-styled HA-5 and HA-7 first') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The headjack has no catalog row and is a stub.',
         'The headjack is the catalog row universal-headjack-and-ear-implant, and equipment_starting lists it.'),
       updated_at = datetime('now')
 WHERE class_id = 'cyberoid'
   AND instr(markdown, 'The headjack has no catalog row and is a stub.') > 0
   AND instr(markdown, 'The headjack is the catalog row universal-headjack-and-ear-implant, and equipment_starting lists it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'this catalog holds no NGR O.C.C. at all,
     so there is nothing to name for that half and the sentence is recorded in
     the note.',
         'this catalog holds eleven `ngr-` classes now
     (`ngr-infantry-soldier`, `ngr-police` and `ngr-cyborg-soldier` among
     them). The list still names none of them, and the sentence is recorded
     in the note.'),
       updated_at = datetime('now')
 WHERE class_id = 'daitya'
   AND instr(markdown, 'this catalog holds no NGR O.C.C. at all,
     so there is nothing to name for that half and the sentence is recorded in
') > 0
   AND instr(markdown, '`ngr-cyborg-soldier` among
     them). The list still names none of them, and the sentence is recorded
     in the note.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the catalog has no spear or pole-arm W.P., so both slots are of choice.',
         'the catalog holds W.P. Spear and W.P. Pole Arm as two rows now, and both slots are still of choice.'),
       updated_at = datetime('now')
 WHERE class_id = 'demon-hound-rider'
   AND instr(markdown, 'the catalog has no spear or pole-arm W.P., so both slots are of choice.') > 0
   AND instr(markdown, 'the catalog holds W.P. Spear and W.P. Pole Arm as two rows now, and both slots are still of choice.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'W.P. spear/pole-arm has no catalog row. Rather than invent one, both non-sword W.P. slots are of choice and the book''s wording is in the note.',
         'W.P. spear/pole-arm is two catalog rows now, W.P. Spear and W.P. Pole Arm, not one combined row. The class grants neither: both non-sword W.P. slots are still of choice and the book''s wording is in the note.'),
       updated_at = datetime('now')
 WHERE class_id = 'demon-hound-rider'
   AND instr(markdown, 'W.P. spear/pole-arm has no catalog row. Rather than invent one, both non-sword W.P. slots are of choice and the book''s w') > 0
   AND instr(markdown, 'ined row. The class grants neither: both non-sword W.P. slots are still of choice and the book''s wording is in the note.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '+5% on First Aid (add it by hand)',
         '+5% on First Aid (the second Medical entry carries it)'),
       updated_at = datetime('now')
 WHERE class_id = 'duelist'
   AND instr(markdown, '+5% on First Aid (add it by hand)') > 0
   AND instr(markdown, '+5% on First Aid (the second Medical entry carries it)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'with +5% on First Aid (a per-skill bonus, in the note)',
         'with +5% on First Aid (a per-skill bonus, carried by the second Medical entry)'),
       updated_at = datetime('now')
 WHERE class_id = 'duelist'
   AND instr(markdown, 'with +5% on First Aid (a per-skill bonus, in the note)') > 0
   AND instr(markdown, 'with +5% on First Aid (a per-skill bonus, carried by the second Medical entry)') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'a box of 100 large resealable plastic bags, clothing, a bedroll, belt, boots, a note pad and personal items have no catalog row.',
         'a box of 100 large resealable plastic bags, belt, boots and personal items have no catalog row. Clothing, bedroll and note pad rows exist now (clothing, bedroll-rifts, note-pad); the class does not list them.'),
       updated_at = datetime('now')
 WHERE class_id = 'ectohunter'
   AND instr(markdown, 'a box of 100 large resealable plastic bags, clothing, a bedroll, belt, boots, a note pad and personal items have no cata') > 0
   AND instr(markdown, 'og row. Clothing, bedroll and note pad rows exist now (clothing, bedroll-rifts, note-pad); the class does not list them.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Use that Lesser Demon''s statistics from Rifts China One for the Demon Form; they are not in this catalog. The book names',
         'Use that Lesser Demon''s statistics from Rifts China One for the Demon Form. The book names'),
       updated_at = datetime('now')
 WHERE class_id = 'enlightened-demon'
   AND instr(markdown, 'Use that Lesser Demon''s statistics from Rifts China One for the Demon Form; they are not in this catalog. The book names') > 0
   AND instr(markdown, 'Use that Lesser Demon''s statistics from Rifts China One for the Demon Form. The book names') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Unique Demonic Powers, 145-149), which is not in the catalog.',
         'Unique Demonic Powers, 145-149). The Lesser Demons of 84-105 are creature rows now (about 45 rows cite Rifts World Book 24: China 1, chuan-ti, ma-tou and ox-head-demon among them); the class does not grant or list them and still keeps the demon form in prose. The Unique Demonic Powers of 145-149 still have no rows.'),
       updated_at = datetime('now')
 WHERE class_id = 'enlightened-demon'
   AND instr(markdown, 'Unique Demonic Powers, 145-149), which is not in the catalog.') > 0
   AND instr(markdown, 'not grant or list them and still keeps the demon form in prose. The Unique Demonic Powers of 145-149 still have no rows.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'which are not in the catalog yet.',
         'which are vehicle rows now (usa-g10a1-point-glitter-boy, usa-g10a2-hawkeye-glitter-boy; Japan p.137-142).'),
       updated_at = datetime('now')
 WHERE class_id = 'glitter-force-trooper'
   AND instr(markdown, 'which are not in the catalog yet.') > 0
   AND instr(markdown, 'which are vehicle rows now (usa-g10a1-point-glitter-boy, usa-g10a2-hawkeye-glitter-boy; Japan p.137-142).') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'all three are described in the Issued Power Armor section, to be wired to the vehicles tables once the book''s power armor is imported.',
         'all three are described in the Issued Power Armor section, and the class does not grant any of them.'),
       updated_at = datetime('now')
 WHERE class_id = 'glitter-force-trooper'
   AND instr(markdown, 'all three are described in the Issued Power Armor section, to be wired to the vehicles tables once the book''s power armo') > 0
   AND instr(markdown, 'all three are described in the Issued Power Armor section, and the class does not grant any of them.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The full statistics will be linked here once the book''s power armor is in the catalog.',
         'The full statistics are on the printed pages given above.'),
       updated_at = datetime('now')
 WHERE class_id = 'glitter-force-trooper'
   AND instr(markdown, 'The full statistics will be linked here once the book''s power armor is in the catalog.') > 0
   AND instr(markdown, 'The full statistics are on the printed pages given above.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    prose rather than stub, T-40 "plain clothes" armour and Millennium Tree
    leaf armour, the car as a vehicle option, and the contents of the two kits -',
         '    prose rather than stub, Millennium Tree leaf armour, the car as a vehicle
    option, and the contents of the two kits -'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, '    prose rather than stub, T-40 "plain clothes" armour and Millennium Tree
    leaf armour, the car as a vehicle option') > 0
   AND instr(markdown, 'prose rather than stub, Millennium Tree leaf armour, the car as a vehicle
    option, and the contents of the two kits -') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    contents are prose, which is how the NGR Medical Officer''s kits went in.',
         '    contents are prose, which is how the NGR Medical Officer''s kits went in.
    T-40 "plain clothes" armour is left out of `equipment_starting` as well,
    but it has rows now: `t-40-urban-businessman-suit`,
    `t-40-ultra-businessman-suit`, `t-40-jump-suit`, `t-40-outdoorsman`,
    `t-40-long-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, '    contents are prose, which is how the NGR Medical Officer''s kits went in.') > 0
   AND instr(markdown, 'ng-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    as prose rather than stub, T-40 "plain clothes" armour and Millennium Tree
    leaf armour - the first a Triax armour row the gear batch has not reached,
    the second a Rifts England row this catalog does not hold - the squirt gun
    filled with water, the car as a vehicle option, and the 2D4 pieces of
    jewelry the seer wears.',
         '    as prose rather than stub, Millennium Tree leaf armour - a Rifts England
    row this catalog does not hold - the squirt gun
    filled with water, the car as a vehicle option, and the 2D4 pieces of
    jewelry the seer wears.
    T-40 "plain clothes" armour is left out of `equipment_starting` as well,
    but it has rows now: `t-40-urban-businessman-suit`,
    `t-40-ultra-businessman-suit`, `t-40-jump-suit`, `t-40-outdoorsman`,
    `t-40-long-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-seer'
   AND instr(markdown, '    as prose rather than stub, T-40 "plain clothes" armour and Millennium Tree
    leaf armour - the first a Triax armou') > 0
   AND instr(markdown, 'ng-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    than stub, T-40 "plain clothes" armour, which is a Triax armour row the
    gear batch has not reached, and the robot horse and land buggy, two of the
    four vehicle options, which have no rows - the horse and the hovercycle do
    and are the stored choice.',
         '    than stub, and the robot horse and land buggy, two of the
    four vehicle options, which have no rows - the horse and the hovercycle do
    and are the stored choice.
    T-40 "plain clothes" armour is left out of `equipment_starting` as well,
    but it has rows now: `t-40-urban-businessman-suit`,
    `t-40-ultra-businessman-suit`, `t-40-jump-suit`, `t-40-outdoorsman`,
    `t-40-long-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, '    than stub, T-40 "plain clothes" armour, which is a Triax armour row the
    gear batch has not reached, and the robo') > 0
   AND instr(markdown, 'ng-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '    as prose rather than stub, T-40 "plain clothes" armour, which is a Triax
    armour row the gear batch has not reached, and the robot horse and land
    buggy, two of the four vehicle options.',
         '    as prose rather than stub, and the robot horse and land
    buggy, two of the four vehicle options.
    T-40 "plain clothes" armour is left out of `equipment_starting` as well,
    but it has rows now: `t-40-urban-businessman-suit`,
    `t-40-ultra-businessman-suit`, `t-40-jump-suit`, `t-40-outdoorsman`,
    `t-40-long-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.'),
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-wizard-thief'
   AND instr(markdown, '    as prose rather than stub, T-40 "plain clothes" armour, which is a Triax
    armour row the gear batch has not reach') > 0
   AND instr(markdown, 'ng-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - Temporal Magic has no catalog rows, so the level 6+ alternative of two
    Temporal Magic spells is only in each entry''s note.',
         '  - Temporal Magic has 25 catalog rows now (tradition temporal, names
    prefixed Temporal: ). The class does not grant or list them, and the
    level 6+ alternative of two Temporal Magic spells is still only in each
    entry''s note.'),
       updated_at = datetime('now')
 WHERE class_id = 'high-magus'
   AND instr(markdown, '  - Temporal Magic has no catalog rows, so the level 6+ alternative of two
    Temporal Magic spells is only in each ent') > 0
   AND instr(markdown, 'rant or list them, and the
    level 6+ alternative of two Temporal Magic spells is still only in each
    entry''s note.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'CIRCLE MAGIC (printed 103-107) IS NOT IMPORTED: protection circles, circles of power and summoning circles are a separate discipline with their own drawing rules and their own costs, available to the wizard alone, and the catalog has no shape for one. Neither are golems and zombies, printed 107.',
         'CIRCLE MAGIC (printed 103-107) IS NOT GRANTED BY THIS CLASS: protection circles, circles of power and summoning circles are a separate discipline with their own drawing rules and their own costs, available to the wizard alone. The catalog holds 13 Heroes Unlimited spell rows of tradition circle now (Revised Heroes Unlimited p.104-106), beside 51 Palladium Fantasy ones; the class does not grant or list them. Golems and zombies, printed 107, are not imported.'),
       updated_at = datetime('now')
 WHERE class_id = 'hu-magic'
   AND instr(markdown, 'CIRCLE MAGIC (printed 103-107) IS NOT IMPORTED: protection circles, circles of power and summoning circles are a separat') > 0
   AND instr(markdown, 'ide 51 Palladium Fantasy ones; the class does not grant or list them. Golems and zombies, printed 107, are not imported.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'skinning knives, flint and tinder box, cooking utensils, frying pan, a box of 100 plastic sandwich bags, a box of 100 large bags, 1D4 airtight plastic containers, bedroll, belt, boots, fur cloak or long coat, note pad, 20 feet of wire and personal items have no catalog row and are in GM Notes.',
         'flint and tinder box, frying pan, a box of 100 plastic sandwich bags, a box of 100 large bags, 1D4 airtight plastic containers, belt, boots, 20 feet of wire and personal items have no catalog row and are in GM Notes. Rows exist now for the skinning knives, cooking utensils, bedroll, fur cloak or long coat and note pad (knife-skinning, utensil-kit-rifts, bedroll-rifts, cape-or-cloak-long, note-pad); the class does not list them and they are still in GM Notes.'),
       updated_at = datetime('now')
 WHERE class_id = 'huntsman-trapper'
   AND instr(markdown, 'skinning knives, flint and tinder box, cooking utensils, frying pan, a box of 100 plastic sandwich bags, a box of 100 la') > 0
   AND instr(markdown, 'il-kit-rifts, bedroll-rifts, cape-or-cloak-long, note-pad); the class does not list them and they are still in GM Notes.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'not stored as occ_restrictions (judgement) because the list''s first and most common entry, the Idie Fisherman O.C.C., is not in the catalog, and an only-list would bar the race''s own occupation.',
         'not stored as occ_restrictions (judgement). The list''s first and most common entry, the Idie Fisherman O.C.C., is in the catalog now (idie-fisherman); the race still stores no occ_restrictions for the list.'),
       updated_at = datetime('now')
 WHERE class_id = 'idie-swamp-man'
   AND instr(markdown, 'not stored as occ_restrictions (judgement) because the list''s first and most common entry, the Idie Fisherman O.C.C., is') > 0
   AND instr(markdown, 'e Idie Fisherman O.C.C., is in the catalog now (idie-fisherman); the race still stores no occ_restrictions for the list.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '"tribal-shaman", "stone-master"]',
         '"tribal-shaman", "stone-master", "african-priest", "rain-maker", "medicine-man"]'),
       updated_at = datetime('now')
 WHERE class_id = 'jungle-elf'
   AND instr(markdown, '"tribal-shaman", "stone-master"]') > 0
   AND instr(markdown, '"tribal-shaman", "stone-master", "african-priest", "rain-maker", "medicine-man"]') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'It also names the Herbalist or Druid and the Temporal Wizard (Rifts England) and the African Priest, Rain Maker and Medicine Man (Rifts Africa), which are not in the catalog yet, and allows a Wilderness Scout ''or equivalent''.',
         'It also names the African Priest, Rain Maker and Medicine Man (Rifts Africa), which are listed, and the Herbalist or Druid and the Temporal Wizard (Rifts England), which still have no class row (the catalog''s only druid is Palladium Fantasy''s), and allows a Wilderness Scout ''or equivalent''.'),
       updated_at = datetime('now')
 WHERE class_id = 'jungle-elf'
   AND instr(markdown, 'It also names the Herbalist or Druid and the Temporal Wizard (Rifts England) and the African Priest, Rain Maker and Medi') > 0
   AND instr(markdown, 'till have no class row (the catalog''s only druid is Palladium Fantasy''s), and allows a Wilderness Scout ''or equivalent''.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'NOT in the catalog on the day of drafting, so not
    listed and currently refused: Herbalist or Druid (Rifts England; the
    catalog''s druid is the Palladium Fantasy one), Temporal Wizard (Rifts
    England), African Priest, Rain Maker and Medicine Man (Rifts Africa).
    Each needs adding here when it is imported.',
         'Also listed: african-priest, rain-maker and
    medicine-man (Rifts Africa''s African Priest, Rain Maker and Medicine
    Man). Still without a class row, so not listed and currently refused:
    Herbalist or Druid (Rifts England; the catalog''s druid is the Palladium
    Fantasy one) and Temporal Wizard (Rifts England). Each needs adding
    here when it is imported.'),
       updated_at = datetime('now')
 WHERE class_id = 'jungle-elf'
   AND instr(markdown, 'NOT in the catalog on the day of drafting, so not
    listed and currently refused: Herbalist or Druid (Rifts England; t') > 0
   AND instr(markdown, 'd is the Palladium
    Fantasy one) and Temporal Wizard (Rifts England). Each needs adding
    here when it is imported.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'is a creature and the robot horse has no gear row; a character taking either records it by hand.',
         'is a creature and the robot horses are vehicle rows (four Bandito Arms models, New West p.196-200) that no gear row points at; a character taking either records it by hand.'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-shaman'
   AND instr(markdown, 'is a creature and the robot horse has no gear row; a character taking either records it by hand.') > 0
   AND instr(markdown, '(four Bandito Arms models, New West p.196-200) that no gear row points at; a character taking either records it by hand.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the robot horse has no row.',
         'robot horse rows exist now as vehicles (the four Bandito Arms models of New West p.196-200, such as rh-1002b-mustang-medium-robot-horse) with no gear row pointing at them, and the class does not list one.'),
       updated_at = datetime('now')
 WHERE class_id = 'larhold-shaman'
   AND instr(markdown, 'the robot horse has no row.') > 0
   AND instr(markdown, '96-200, such as rh-1002b-mustang-medium-robot-horse) with no gear row pointing at them, and the class does not list one.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Saddle, camping kit and the Blood Lizard mount have no catalog row and are not stubbed.',
         'Saddle and camping kit have no catalog row and are not stubbed. The Blood Lizard mount has a creature row now (blood-lizard, South America 2 p.137-138); the class does not grant or list it.'),
       updated_at = datetime('now')
 WHERE class_id = 'master-blood-rider'
   AND instr(markdown, 'Saddle, camping kit and the Blood Lizard mount have no catalog row and are not stubbed.') > 0
   AND instr(markdown, 'lood Lizard mount has a creature row now (blood-lizard, South America 2 p.137-138); the class does not grant or list it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Standard equipment names Mega-Juicer Combat Armor at 130 M.D.C., which has no gear row yet.',
         'Standard equipment names Mega-Juicer Combat Armor at 130 M.D.C.; its gear row exists (mega-juicer-combat-armor) and equipment_starting lists it.'),
       updated_at = datetime('now')
 WHERE class_id = 'mega-juicer'
   AND instr(markdown, 'Standard equipment names Mega-Juicer Combat Armor at 130 M.D.C., which has no gear row yet.') > 0
   AND instr(markdown, ' Mega-Juicer Combat Armor at 130 M.D.C.; its gear row exists (mega-juicer-combat-armor) and equipment_starting lists it.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'The book says 1D4 medium size sacks; the catalog has no medium.',
         'The book says 1D4 medium size sacks. A medium sack row exists now (sack-medium); the class still stores small sacks.'),
       updated_at = datetime('now')
 WHERE class_id = 'monk'
   AND instr(markdown, 'The book says 1D4 medium size sacks; the catalog has no medium.') > 0
   AND instr(markdown, 'The book says 1D4 medium size sacks. A medium sack row exists now (sack-medium); the class still stores small sacks.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'the catalog has no Land Rover, so jeep stands in, and the M.D.C. reduction is prose only.',
         'the catalog''s Land Rover (wr-1010-land-rover, Triax and the NGR p.138) is a vehicle row with no gear pointer, so jeep still stands in, and the M.D.C. reduction is prose only.'),
       updated_at = datetime('now')
 WHERE class_id = 'nega-psychic'
   AND instr(markdown, 'the catalog has no Land Rover, so jeep stands in, and the M.D.C. reduction is prose only.') > 0
   AND instr(markdown, 'd the NGR p.138) is a vehicle row with no gear pointer, so jeep still stands in, and the M.D.C. reduction is prose only.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - The 1D4 tear gas grenades and 1D4 plasma grenades are not stored: neither
    has a catalog row, and the plasma grenade''s damage is printed "SD6 M.D.",
    an OCR reading of 5D6 that is not worth stubbing a row on. In the body.',
         '  - The 1D4 tear gas grenades and 1D4 plasma grenades are not stored. Both
    have catalog rows now (`triax-tear-gas-grenade`, `triax-plasma-grenade`)
    that the class does not list. The plasma grenade''s damage is printed
    "SD6 M.D.", an OCR reading of 5D6. In the body.'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-power-armor-commando'
   AND instr(markdown, '  - The 1D4 tear gas grenades and 1D4 plasma grenades are not stored: neither
    has a catalog row, and the plasma gren') > 0
   AND instr(markdown, 'that the class does not list. The plasma grenade''s damage is printed
    "SD6 M.D.", an OCR reading of 5D6. In the body.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'None is given a catalog row - the first three are unresolved choices and the last two have no row to reference.',
         'None is stored with the class; the first three are unresolved choices.'),
       updated_at = datetime('now')
 WHERE class_id = 'ngr-power-armor-commando'
   AND instr(markdown, 'None is given a catalog row - the first three are unresolved choices and the last two have no row to reference.') > 0
   AND instr(markdown, 'None is stored with the class; the first three are unresolved choices.') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Jungle Elf lists the three occupations' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'jungle-elf' AND instr(markdown, '"stone-master", "african-priest", "rain-maker", "medicine-man"]') > 0;

SELECT 'part 1: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'apok' AND length(markdown) = 11599)
    OR (class_id = 'arkhon' AND length(markdown) = 12610)
    OR (class_id = 'arkhon-spectral-hunter' AND length(markdown) = 11583)
    OR (class_id = 'blood-rider' AND length(markdown) = 13754)
    OR (class_id = 'bogatyr-hero-knight' AND length(markdown) = 13945)
    OR (class_id = 'cossack' AND length(markdown) = 14693)
    OR (class_id = 'cyber-samurai' AND length(markdown) = 13804)
    OR (class_id = 'cyberoid' AND length(markdown) = 12748)
    OR (class_id = 'daitya' AND length(markdown) = 7527)
    OR (class_id = 'demon-hound-rider' AND length(markdown) = 9685)
    OR (class_id = 'duelist' AND length(markdown) = 12547)
    OR (class_id = 'ectohunter' AND length(markdown) = 18792);

SELECT 'part 2: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 12 AS want
  FROM imported_classes
 WHERE (class_id = 'enlightened-demon' AND length(markdown) = 26822)
    OR (class_id = 'glitter-force-trooper' AND length(markdown) = 14121)
    OR (class_id = 'gypsy-gifted' AND length(markdown) = 20828)
    OR (class_id = 'gypsy-seer' AND length(markdown) = 16728)
    OR (class_id = 'gypsy-thief' AND length(markdown) = 12815)
    OR (class_id = 'gypsy-wizard-thief' AND length(markdown) = 13108)
    OR (class_id = 'high-magus' AND length(markdown) = 20764)
    OR (class_id = 'hu-magic' AND length(markdown) = 25539)
    OR (class_id = 'huntsman-trapper' AND length(markdown) = 19286)
    OR (class_id = 'idie-swamp-man' AND length(markdown) = 6575)
    OR (class_id = 'jungle-elf' AND length(markdown) = 15508)
    OR (class_id = 'larhold-shaman' AND length(markdown) = 16345);

SELECT 'part 3: each class is exactly the length this script leaves it' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'master-blood-rider' AND length(markdown) = 13509)
    OR (class_id = 'mega-juicer' AND length(markdown) = 9429)
    OR (class_id = 'monk' AND length(markdown) = 17293)
    OR (class_id = 'nega-psychic' AND length(markdown) = 15320)
    OR (class_id = 'ngr-power-armor-commando' AND length(markdown) = 8647);

INSERT INTO data_script_runs (filename) VALUES ('~124-stale-notes-sweep-part-1.sql');
