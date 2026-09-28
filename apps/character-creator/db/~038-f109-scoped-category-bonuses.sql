-- BOOK-INGEST-AUDIT F109: four Coalition War Campaign classes print a
-- related-skill category bonus for PART of a category, and each is now stored
-- as that category listed twice.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~038-f109-scoped-category-bonuses.sql
--
-- WHAT. js/parser.js categoryAllows and categoryBonus rank every entry for a
-- skill's category (an only entry naming it, then an except entry not
-- excluding it, then a plain entry) instead of taking the first. So a line
-- like "Pilot: Any, +10% to water vehicles only" is the plain or except entry
-- the class already had, plus a second entry naming the skills the higher
-- figure covers:
--   cs-nautical-specialist  Pilot +10% water vehicles; Domestic +10% Fishing (printed 79)
--   cs-rpa-fly-boy-ace      Pilot +15% aircraft and modes of flying, else +10% (printed 85)
--   cs-rcsg-scientist       Technical +20% Literacy and Language, else +10% (printed 83)
--   cs-special-forces       Technical +15% Literacy and Language, else +10% (printed 87)
--
-- ORDER. Each new entry goes AFTER the entry the class already had. This file
-- is applied before the merge that ships the ranking, and the parser still
-- live then takes the first same-named entry - so, listed second, the new
-- entry changes nothing until the ranking deploys, instead of refusing every
-- other skill in the category in the meantime.
--
-- MECHANICS. Each statement is a replace() guarded on its old text being
-- present and its new text absent, so a second run changes nothing. The notes
-- that told the player to add the difference by hand are rewritten in the same
-- file.

-- cs-nautical-specialist: Domestic +10% to Fishing, the rest at +5% (printed 79)
UPDATE imported_classes
   SET markdown = replace(markdown, '      - { name: "Domestic", bonus: 5 }
', '      - { name: "Domestic", bonus: 5 }
      - { name: "Domestic", only: ["Fishing"], bonus: 10 }
'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-nautical-specialist'
   AND instr(markdown, '      - { name: "Domestic", bonus: 5 }
') > 0
   AND instr(markdown, '      - { name: "Domestic", bonus: 5 }
      - { name: "Domestic", only: ["Fishing"], bonus: 10 }
') = 0;

-- cs-nautical-specialist: Pilot +10% to water vehicles only (printed 79)
UPDATE imported_classes
   SET markdown = replace(markdown, '      - "Pilot Related"
', '      - { name: "Pilot", only: ["Military: Submersibles", "Military: Warships & Patrol Boats", "Water Scooters"], only_prefix: ["Boat:"], bonus: 10 }
      - "Pilot Related"
'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-nautical-specialist'
   AND instr(markdown, '      - "Pilot Related"
') > 0
   AND instr(markdown, '      - { name: "Pilot", only: ["Military: Submersibles", "Military: Warships & Patrol Boats", "Water Scooters"], only_prefix: ["Boat:"], bonus: 10 }
      - "Pilot Related"
') = 0;

-- cs-nautical-specialist: related-skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'Domestic is Any (+5%), and Fishing gets +10% instead - add the other 5% to Fishing by hand.', 'Domestic is Any (+5%), and Fishing gets +10% instead: a second Domestic entry names Fishing at +10% (BOOK-INGEST-AUDIT F109).'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-nautical-specialist'
   AND instr(markdown, 'Domestic is Any (+5%), and Fishing gets +10% instead - add the other 5% to Fishing by hand.') > 0
   AND instr(markdown, 'Domestic is Any (+5%), and Fishing gets +10% instead: a second Domestic entry names Fishing at +10% (BOOK-INGEST-AUDIT F109).') = 0;

-- cs-nautical-specialist: related-skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'Pilot is Any except robots, power armor, tanks, APCs and combat aircraft, with +10% to water vehicles only: the category carries no bonus, so add 10% by hand to a boat, ship, submersible or water scooter pick.', 'Pilot is Any except robots, power armor, tanks, APCs and combat aircraft, with +10% to water vehicles only: a second Pilot entry carries the +10% for the Boat: rows, Military: Submersibles, Military: Warships & Patrol Boats and Water Scooters (BOOK-INGEST-AUDIT F109). Water Skiing & Surfing and Advanced Deep Sea Diving are not vehicles and take no bonus.'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-nautical-specialist'
   AND instr(markdown, 'Pilot is Any except robots, power armor, tanks, APCs and combat aircraft, with +10% to water vehicles only: the category carries no bonus, so add 10% by hand to a boat, ship, submersible or water scooter pick.') > 0
   AND instr(markdown, 'Pilot is Any except robots, power armor, tanks, APCs and combat aircraft, with +10% to water vehicles only: a second Pilot entry carries the +10% for the Boat: rows, Military: Submersibles, Military: Warships & Patrol Boats and Water Scooters (BOOK-INGEST-AUDIT F109). Water Skiing & Surfing and Advanced Deep Sea Diving are not vehicles and take no bonus.') = 0;

-- cs-nautical-specialist: extraction note
UPDATE imported_classes
   SET markdown = replace(markdown, 'Two category bonuses the app cannot scope are recorded rather than stored: Pilot''s +10% applies to water vehicles only, and Domestic''s +5% becomes +10% for Fishing.', 'The two scoped category bonuses, Pilot''s +10% to water vehicles only and Domestic''s +10% for Fishing where the rest of Domestic is +5%, are stored since 2026-09-27 as a second entry for each category naming the skills it covers (BOOK-INGEST-AUDIT F109); before that they were written here and applied by hand.'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-nautical-specialist'
   AND instr(markdown, 'Two category bonuses the app cannot scope are recorded rather than stored: Pilot''s +10% applies to water vehicles only, and Domestic''s +5% becomes +10% for Fishing.') > 0
   AND instr(markdown, 'The two scoped category bonuses, Pilot''s +10% to water vehicles only and Domestic''s +10% for Fishing where the rest of Domestic is +5%, are stored since 2026-09-27 as a second entry for each category naming the skills it covers (BOOK-INGEST-AUDIT F109); before that they were written here and applied by hand.') = 0;

-- cs-rpa-fly-boy-ace: Pilot +15% on aircraft and modes of flying, otherwise +10% (printed 85)
UPDATE imported_classes
   SET markdown = replace(markdown, '      - { name: "Pilot", except: ["Military: Warships & Patrol Boats"], bonus: 10 }
', '      - { name: "Pilot", except: ["Military: Warships & Patrol Boats"], bonus: 10 }
      - { name: "Pilot", only: ["Airplane", "Helicopter", "Hovercycles, Skycycles & Rocket Bikes", "Jet Aircraft", "Jet Packs", "Military: Combat Helicopter", "Military: Jet Fighters", "Wingrider Flying Wing"], bonus: 15 }
'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-rpa-fly-boy-ace'
   AND instr(markdown, '      - { name: "Pilot", except: ["Military: Warships & Patrol Boats"], bonus: 10 }
') > 0
   AND instr(markdown, '      - { name: "Pilot", except: ["Military: Warships & Patrol Boats"], bonus: 10 }
      - { name: "Pilot", only: ["Airplane", "Helicopter", "Hovercycles, Skycycles & Rocket Bikes", "Jet Aircraft", "Jet Packs", "Military: Combat Helicopter", "Military: Jet Fighters", "Wingrider Flying Wing"], bonus: 15 }
') = 0;

-- cs-rpa-fly-boy-ace: related-skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'Pilot is printed +10% but +15% on all aircraft and modes of flying - take the higher figure by hand for an aircraft, flight or jet pack pick.', 'Pilot is printed +10% but +15% on all aircraft and modes of flying: a second Pilot entry carries the +15% for Airplane, Helicopter, Hovercycles, Skycycles & Rocket Bikes, Jet Aircraft, Jet Packs, Military: Combat Helicopter, Military: Jet Fighters and Wingrider Flying Wing (BOOK-INGEST-AUDIT F109). Power armor, robot combat and the Space: rows stay at +10%.'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-rpa-fly-boy-ace'
   AND instr(markdown, 'Pilot is printed +10% but +15% on all aircraft and modes of flying - take the higher figure by hand for an aircraft, flight or jet pack pick.') > 0
   AND instr(markdown, 'Pilot is printed +10% but +15% on all aircraft and modes of flying: a second Pilot entry carries the +15% for Airplane, Helicopter, Hovercycles, Skycycles & Rocket Bikes, Jet Aircraft, Jet Packs, Military: Combat Helicopter, Military: Jet Fighters and Wingrider Flying Wing (BOOK-INGEST-AUDIT F109). Power armor, robot combat and the Space: rows stay at +10%.') = 0;

-- cs-rcsg-scientist: Technical +20% to Literacy and Language (printed 83)
UPDATE imported_classes
   SET markdown = replace(markdown, '      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
', '      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 20 }
      - "Weapon Proficiencies"
'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-rcsg-scientist'
   AND instr(markdown, '      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 20 }
      - "Weapon Proficiencies"
') = 0;

-- cs-rcsg-scientist: related-skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'Technical is printed +10%, but +20% to Literacy and Language skills - pick those at the higher figure by hand.', 'Technical is printed +10%, but +20% to Literacy and Language skills: a second Technical entry carries the +20% for every Technical row whose name starts Language or Literacy (BOOK-INGEST-AUDIT F109). Seven such rows are filed under Communications (Literacy: Euro, Gypsy, Native Language, Other and Russian; Language: All (magical) and Dolphin/Whale), and they take the Communications +10%.'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-rcsg-scientist'
   AND instr(markdown, 'Technical is printed +10%, but +20% to Literacy and Language skills - pick those at the higher figure by hand.') > 0
   AND instr(markdown, 'Technical is printed +10%, but +20% to Literacy and Language skills: a second Technical entry carries the +20% for every Technical row whose name starts Language or Literacy (BOOK-INGEST-AUDIT F109). Seven such rows are filed under Communications (Literacy: Euro, Gypsy, Native Language, Other and Russian; Language: All (magical) and Dolphin/Whale), and they take the Communications +10%.') = 0;

-- cs-special-forces: Technical +15% to Literacy and Language (printed 87)
UPDATE imported_classes
   SET markdown = replace(markdown, '      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
', '      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15 }
      - "Weapon Proficiencies"
'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-special-forces'
   AND instr(markdown, '      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
') > 0
   AND instr(markdown, '      - { name: "Technical", bonus: 10 }
      - { name: "Technical", only_prefix: ["Language", "Literacy"], bonus: 15 }
      - "Weapon Proficiencies"
') = 0;

-- cs-special-forces: related-skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'Technical is printed +10%, but +15% to Literacy and Language skills - take those at the higher figure by hand.', 'Technical is printed +10%, but +15% to Literacy and Language skills: a second Technical entry carries the +15% for every Technical row whose name starts Language or Literacy (BOOK-INGEST-AUDIT F109). Seven such rows are filed under Communications (Literacy: Euro, Gypsy, Native Language, Other and Russian; Language: All (magical) and Dolphin/Whale), and they take the Communications +10%.'),
       updated_at = datetime('now')
 WHERE class_id = 'cs-special-forces'
   AND instr(markdown, 'Technical is printed +10%, but +15% to Literacy and Language skills - take those at the higher figure by hand.') > 0
   AND instr(markdown, 'Technical is printed +10%, but +15% to Literacy and Language skills: a second Technical entry carries the +15% for every Technical row whose name starts Language or Literacy (BOOK-INGEST-AUDIT F109). Seven such rows are filed under Communications (Literacy: Euro, Gypsy, Native Language, Other and Russian; Language: All (magical) and Dolphin/Whale), and they take the Communications +10%.') = 0;

-- Read back: each class carries its second entry, and no note still sends the
-- player to apply the difference by hand.
SELECT class_id,
       instr(markdown, 'only: ["Fishing"], bonus: 10') > 0 AS fishing,
       instr(markdown, 'only_prefix: ["Boat:"], bonus: 10') > 0 AS water,
       instr(markdown, '"Wingrider Flying Wing"], bonus: 15') > 0 AS aircraft,
       instr(markdown, 'only_prefix: ["Language", "Literacy"], bonus: 20') > 0 AS tech20,
       instr(markdown, 'only_prefix: ["Language", "Literacy"], bonus: 15') > 0 AS tech15,
       instr(markdown, 'by hand') AS by_hand_at
  FROM imported_classes
 WHERE class_id IN ('cs-nautical-specialist', 'cs-rpa-fly-boy-ace', 'cs-rcsg-scientist', 'cs-special-forces')
 ORDER BY class_id;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('~038-f109-scoped-category-bonuses.sql');
