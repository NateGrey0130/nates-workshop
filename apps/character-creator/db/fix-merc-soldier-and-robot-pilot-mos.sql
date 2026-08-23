-- The Merc Soldier and Robot Pilot get the MOS the schema can already hold.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-merc-soldier-and-robot-pilot-mos.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-merc-soldier-and-robot-pilot-mos.sql
--
-- Rifts Ultimate Edition, the Merc Soldier printed 81-83 and the Robot Pilot
-- printed 83-85.
--
-- WHAT WAS WRONG. Both classes carried a note saying an MOS is "a package
-- choice the schema cannot express" and that the skills should be added "by
-- hand on the sheet". That was true when they were written and stopped being
-- true when skills.mos landed for the Coalition Technical Officer. A note
-- describing a limitation that has been lifted is worse than no note: it tells
-- the next reader not to try.
--
-- The cost of leaving it was not documentation. A Merc Soldier is SEVEN skills
-- short of what the book gives every one of them, and a Robot Pilot EIGHT -
-- including Robot Combat: Basic and Robot Combat Elite, which are the entire
-- point of the class. The packages were transcribed in GM Notes all along, so
-- nothing here is newly read from the book; they are moved from prose the app
-- displays into skills the app grants.
--
-- BASES ARE CATALOG BASE PLUS THE PRINTED BONUS, already added, per the class
-- import rules. Six book names resolve to a different catalog spelling and each
-- one carries a note saying so: Surveillance Systems is Surveillance, W.P.
-- Heavy Energy Weapons is W.P. Heavy M.D. Weapons, Motorcycle is Motorcycles &
-- Snowmobiles, Hovercycle is Hovercycles Skycycles & Rocket Bikes, Trucks is
-- Truck, and Pilot: Robots & Power Armor is Robots and Power Armor.
--
-- TWO THINGS THE SHAPE STILL CANNOT HOLD, both stated in the option's own note
-- rather than dropped:
--   * "Two W.P.s of choice OR two Demolition skills" is a choice between two
--     whole groups. A choice group picks from one pool, so both categories are
--     open and the note carries the rule.
--   * A choice group holds ONE bonus number, so "Basic Mechanics (+10%) or
--     Combat Driving (+5%)" applies neither and the catalog base stands.
--
-- Verified through composeClass with each option in turn: the Merc Soldier goes
-- from 14 O.C.C. skills to 20 or 21 depending on the package, the Robot Pilot
-- from 15 to 23.

-- ===== Merc Soldier: 7 packages, spliced in 3 chunks =====
-- Guarded on the class having no mos block yet, so re-running is a no-op.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  secondary_skills:' || char(10) ||
         '    count: 2' || char(10) ||
         '',
         '@@MOS-MERC-SOLDIER@@' || char(10) ||
         '  secondary_skills:' || char(10) ||
         '    count: 2' || char(10) ||
         '')
 WHERE class_id = 'merc-soldier'
   AND instr(markdown, char(10) || '  mos:' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-MERC-SOLDIER@@',
         '  mos:' || char(10) ||
         '    choose: 1' || char(10) ||
         '    note: "Select ONE package, or roll percentile. Every skill under it is granted in addition to the O.C.C. and related skills. Three packages carry an attribute requirement the app does not enforce: EOD needs I.Q. 10 and P.P. 12+, Point Man needs I.Q. 9+, Pigman needs P.S. 14 and P.E. 12+, Medic needs I.Q. and P.P. 11+."' || char(10) ||
         '    options:' || char(10) ||
         '      - id: "communications"' || char(10) ||
         '        name: "Communications Expert (01-15%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { name: "Electronic Countermeasures", base: 45, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { choose: 1, from: ["Optic Systems", "Surveillance"], bonus: 14, note: "Optic Systems or Surveillance Systems (+14%). The catalog spells the second one Surveillance." }' || char(10) ||
         '          - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }' || char(10) ||
         '          - { choose: 1, from: ["Cryptography", "Language: Other"], bonus: 15, note: "Cryptography (+15%) or one extra language (+15%)." }' || char(10) ||
         '      - id: "eod"' || char(10) ||
         '        name: "EOD/Demolitions Expert (16-25%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Basic Electronics", base: 50, per_level: 5, note: "+20%" }' || char(10) ||
         '          - { name: "Basic Mechanics", base: 45, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { name: "Demolitions", base: 75, per_level: 3, note: "+15%" }' || char(10) ||
         '          - { name: "Demolitions Disposal", base: 80, per_level: 3, note: "+20%" }' || char(10) ||
         '          - { name: "Demolitions: Underwater", base: 66, per_level: 4, note: "+10%" }' || char(10) ||
         '          - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book says W.P. Heavy Energy Weapons; this is the catalog row for it." }' || char(10) ||
         '      - id: "grunt"' || char(10) ||
         '' || '@@MOS-MERC-SOLDIER@@')
 WHERE class_id = 'merc-soldier' AND instr(markdown, '@@MOS-MERC-SOLDIER@@') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-MERC-SOLDIER@@',
         '        name: "Soldier/Grunt (26-50%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Forced March", base: 0, per_level: 0 }' || char(10) ||
         '          - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }' || char(10) ||
         '          - { choose: 1, categories: ["Physical"], note: "One physical skill of choice." }' || char(10) ||
         '          - { choose: 1, categories: ["Pilot"], bonus: 10, note: "One pilot skill of choice (+10%), excluding Power Armor, Robots and Ships." }' || char(10) ||
         '          - { choose: 1, categories: ["Weapon Proficiencies"], note: "One ANCIENT W.P. of choice." }' || char(10) ||
         '          - { choose: 1, categories: ["Weapon Proficiencies"], note: "One MODERN W.P. of choice." }' || char(10) ||
         '      - id: "point-man"' || char(10) ||
         '        name: "Point Man/Scout (51-65%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Detect Ambush", base: 45, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { name: "Detect Concealment", base: 35, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { name: "Intelligence", base: 47, per_level: 4, note: "+15%" }' || char(10) ||
         '          - { name: "Land Navigation", base: 50, per_level: 4, note: "+14%" }' || char(10) ||
         '          - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { choose: 1, from: ["Surveillance", "Tailing"], bonus: 15, note: "Surveillance Systems or Tailing (+15%)." }' || char(10) ||
         '          - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }' || char(10) ||
         '      - id: "pigman"' || char(10) ||
         '        name: "Pigman/Heavy Weapons (66-80%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }' || char(10) ||
         '          - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { name: "W.P. Rifles", base: 0, per_level: 0 }' || char(10) ||
         '' || '@@MOS-MERC-SOLDIER@@')
 WHERE class_id = 'merc-soldier' AND instr(markdown, '@@MOS-MERC-SOLDIER@@') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-MERC-SOLDIER@@',
         '          - { name: "W.P. Heavy Military Weapons", base: 0, per_level: 0 }' || char(10) ||
         '          - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book says W.P. Heavy Energy Weapons, rail guns included." }' || char(10) ||
         '          - { choose: 2, categories: ["Weapon Proficiencies", "Military"], bonus: 5, note: "Two W.P.s of choice, OR two Demolition skills (+5%) - the book offers one or the other, and the app cannot express a choice between two whole groups, so both categories are open and this note carries the rule. The Demolition skills are filed under Military." }' || char(10) ||
         '      - id: "transportation"' || char(10) ||
         '        name: "Transportation Specialist (81-90%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { choose: 1, from: ["Basic Mechanics", "Combat Driving"], note: "Basic Mechanics (+10%) or Combat Driving (+5%). The two carry different bonuses and a choice group holds one number, so neither is applied and the catalog base stands." }' || char(10) ||
         '          - { name: "Navigation", base: 50, per_level: 5, note: "+10%" }' || char(10) ||
         '          - { choose: 1, from: ["Automobile", "Motorcycles & Snowmobiles"], bonus: 20, note: "Automobile or Motorcycle (+20%)." }' || char(10) ||
         '          - { choose: 1, from: ["Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes"], bonus: 15, note: "Hover Craft (ground) or Hovercycle (+15%)." }' || char(10) ||
         '          - { name: "Military: Tanks & APCs", base: 46, per_level: 4, note: "+10%" }' || char(10) ||
         '          - { name: "Truck", base: 50, per_level: 4, note: "+10%" }' || char(10) ||
         '          - { choose: 1, categories: ["Pilot"], bonus: 10, note: "One pilot skill of choice (+10%), excluding robots and power armor." }' || char(10) ||
         '      - id: "medic"' || char(10) ||
         '        name: "Medic (91-00%)"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Brewing", base: 30, per_level: 5, note: "+5%" }' || char(10) ||
         '          - { name: "Biology", base: 45, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { name: "Field Surgery", base: 31, per_level: 4, note: "+15%" }' || char(10) ||
         '          - { name: "Medical Doctor", base: 65, per_level: 5, note: "+5%" }' || char(10) ||
         '          - { choose: 1, from: ["Pathology", "Chemistry"], bonus: 10, note: "Pathology (+10%) or Chemistry (+10%)." }' || char(10) ||
         '          - { name: "Sewing", base: 50, per_level: 5, note: "+10%" }' || char(10) ||
         '' || '@@MOS-MERC-SOLDIER@@')
 WHERE class_id = 'merc-soldier' AND instr(markdown, '@@MOS-MERC-SOLDIER@@') > 0;

-- The marker goes last, leaving the block and nothing else.
UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-MERC-SOLDIER@@' || char(10), '')
 WHERE class_id = 'merc-soldier' AND instr(markdown, '@@MOS-MERC-SOLDIER@@') > 0;

-- The restriction line said the packages were not modelled. They are now.
UPDATE imported_classes
   SET markdown = replace(markdown, 'MOS (Military Occupational Specialty): select or roll ONE specialty package in addition to O.C.C. and Related skills - see GM Notes. MOS skills are not modeled; add them by hand on the sheet.', 'MOS (Military Occupational Specialty): select or roll ONE specialty package in addition to O.C.C. and Related skills. All seven are now in the skills block and the wizard offers them.')
 WHERE class_id = 'merc-soldier' AND instr(markdown, 'MOS (Military Occupational Specialty): select or roll ONE specialty package in addition to O.C.C. and Related skills - see GM Notes. MOS skills are not modeled; add them by hand on the sheet.') > 0;

-- ===== Robot Pilot: 2 packages, spliced in 2 chunks =====
-- Guarded on the class having no mos block yet, so re-running is a no-op.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  secondary_skills:' || char(10) ||
         '    count: 2' || char(10) ||
         '',
         '@@MOS-ROBOT-PILOT@@' || char(10) ||
         '  secondary_skills:' || char(10) ||
         '    count: 2' || char(10) ||
         '')
 WHERE class_id = 'robot-pilot'
   AND instr(markdown, char(10) || '  mos:' || char(10)) = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-ROBOT-PILOT@@',
         '  mos:' || char(10) ||
         '    choose: 1' || char(10) ||
         '    note: "Pick ONE specialty. Every skill under it is granted in addition to the O.C.C. skills. The power armor or giant robot the character starts with is in GM Notes and is still applied by hand - the gear catalog carries no open-market power armour rows."' || char(10) ||
         '    options:' || char(10) ||
         '      - id: "power-armor-pilot"' || char(10) ||
         '        name: "Power Armor Pilot MOS"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Mathematics: Advanced", base: 60, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { choose: 1, from: ["Basic Mechanics", "Acrobatics"], note: "Basic Mechanics (+15%) or Acrobatics. Only the first carries a bonus, and a choice group holds one number, so the catalog base stands for both." }' || char(10) ||
         '          - { name: "Navigation", base: 55, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { name: "Robots and Power Armor", base: 76, per_level: 3, note: "Pilot: Robots & Power Armor, basic (+20%)" }' || char(10) ||
         '          - { name: "Robot Combat: Basic", base: 0, per_level: 0, note: "General knowledge." }' || char(10) ||
         '          - { name: "Robot Combat Elite", base: 0, per_level: 0, note: "Select TWO power armor types to start, plus one more at levels 3, 6, 9 and 12. The catalog has one row per named machine and the app grants the generic one; record the types chosen on the sheet." }' || char(10) ||
         '          - { choose: 1, from: ["Military: Jet Fighters", "Military: Combat Helicopter"], bonus: 15, note: "Jet Fighter or Combat Helicopter (+15%)." }' || char(10) ||
         '          - { choose: 1, categories: ["Pilot"], bonus: 12, note: "One pilot skill of choice (+12%)." }' || char(10) ||
         '      - id: "robot-pilot"' || char(10) ||
         '        name: "Robot Pilot MOS"' || char(10) ||
         '        skills:' || char(10) ||
         '          - { name: "Land Navigation", base: 48, per_level: 4, note: "+12%" }' || char(10) ||
         '          - { name: "Robots and Power Armor", base: 66, per_level: 3, note: "Pilot: Robots & Power Armor, basic (+10%)" }' || char(10) ||
         '          - { name: "Robot Combat: Basic", base: 0, per_level: 0, note: "General knowledge." }' || char(10) ||
         '          - { name: "Robot Combat Elite", base: 0, per_level: 0, note: "Select TWO giant robot types to start, plus one more at levels 3, 6, 9 and 12." }' || char(10) ||
         '          - { name: "Military: Tanks & APCs", base: 36, per_level: 4 }' || char(10) ||
         '          - { name: "Tracked & Construction Vehicles", base: 60, per_level: 4, note: "+20%" }' || char(10) ||
         '' || '@@MOS-ROBOT-PILOT@@')
 WHERE class_id = 'robot-pilot' AND instr(markdown, '@@MOS-ROBOT-PILOT@@') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-ROBOT-PILOT@@',
         '          - { name: "Weapon Systems", base: 55, per_level: 5, note: "+15%" }' || char(10) ||
         '          - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book says W.P. Heavy Energy Weapons, rail guns included." }' || char(10) ||
         '' || '@@MOS-ROBOT-PILOT@@')
 WHERE class_id = 'robot-pilot' AND instr(markdown, '@@MOS-ROBOT-PILOT@@') > 0;

-- The marker goes last, leaving the block and nothing else.
UPDATE imported_classes
   SET markdown = replace(markdown, '@@MOS-ROBOT-PILOT@@' || char(10), '')
 WHERE class_id = 'robot-pilot' AND instr(markdown, '@@MOS-ROBOT-PILOT@@') > 0;

-- The restriction line said the packages were not modelled. They are now.
UPDATE imported_classes
   SET markdown = replace(markdown, 'MOS: pick ONE specialty - Power Armor Pilot or Robot Pilot - in addition to O.C.C. skills; the packages (and the power armor or robot the character starts with) are in GM Notes and applied by hand.', 'MOS: pick ONE specialty - Power Armor Pilot or Robot Pilot - in addition to O.C.C. skills. Both packages are now in the skills block and the wizard offers them; only the power armor or robot the character starts with is still applied by hand.')
 WHERE class_id = 'robot-pilot' AND instr(markdown, 'MOS: pick ONE specialty - Power Armor Pilot or Robot Pilot - in addition to O.C.C. skills; the packages (and the power armor or robot the character starts with) are in GM Notes and applied by hand.') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - The two MOS packages are a package choice the schema cannot express (see' || char(10) ||
         '    the Merc Soldier); transcribed in GM Notes.' || char(10) ||
         '',
         '  - The two MOS packages are modelled as skills.mos, which the schema gained' || char(10) ||
         '    for the Coalition Technical Officer. They were prose here until then, and' || char(10) ||
         '    the note that said the schema "cannot express" them outlived the schema it' || char(10) ||
         '    described - the packages themselves are unchanged and still printed in full' || char(10) ||
         '    under GM Notes.' || char(10) ||
         '')
 WHERE class_id = 'robot-pilot' AND instr(markdown, '  - The two MOS packages are a package choice the schema cannot express (see') > 0;


-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, char(10) || '  mos:' || char(10)) > 0 AS has_mos,
       length(markdown) AS bytes,
       instr(markdown, char(13)) > 0 AS has_cr,
       instr(markdown, 'not modeled; add them by hand') AS stale_merc_note,
       instr(markdown, 'the schema cannot express (see') AS stale_robot_note
  FROM imported_classes WHERE class_id IN ('merc-soldier', 'robot-pilot')
  ORDER BY class_id;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-merc-soldier-and-robot-pilot-mos.sql');
