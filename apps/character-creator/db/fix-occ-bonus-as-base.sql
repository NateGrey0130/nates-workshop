-- A printed O.C.C. BONUS stored as the skill's BASE, in 6 classes.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-occ-bonus-as-base.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-occ-bonus-as-base.sql
--
--   cyber-doc              10 skills   RUE p.90
--   rogue-scholar          10 skills   RUE p.94
--   wilderness-scout        9 skills   RUE p.99
--   coalition-samas-pilot   8 skills   RUE p.233
--   stone-master            6 skills   Book of Magic p.224
--   vagabond                5 skills   RUE p.97
--   chiang-ku-dragon        5 skills   Dragons & Gods p.22 (hatchling variant)
--   vagabond                1 skill    Begging unfrozen (base kept, per_level dropped)
--
-- THE BOOKS DRAW A DISTINCTION THE IMPORT LOST. An O.C.C. skill list writes a
-- fixed percentage two ways, and they mean opposite things:
--
--   "Language: Native Tongue at 96%."   the printed figure IS the percentage
--   "Chemistry (+10%)"                  ten points ON TOP of Chemistry's own
--
-- Both were stored the same way, as `base`. So the Cyber-Doc's Computer
-- Operation sat at 5% where the catalog row is 40% and the class's own note
-- said "(+5%)", and the SAMAS Pilot's Automobile at 15% where the row is 60%.
-- 48 skills across six classes read that way: not a small bonus, a crippling
-- floor, on skills the class is supposed to be BEST at.
--
-- Every one is now `bonus`, which `resolveSkill` has always summed onto the
-- catalog base - the app supported this the whole time; only the data and the
-- validator disagreed. Dropping `per_level` with it matters too: the SAMAS
-- Pilot's Automobile carried +5/level where the catalog row is +2.
--
-- VERIFIED PAGE BY PAGE, one class at a time, against the scans. Rifts Ultimate
-- Edition has no text layer, so the pages were read as images rather than
-- trusted to OCR - the OCR had merged the SAMAS Pilot's skill list with the
-- Coalition Grunt's column beside it, which would have written six wrong
-- numbers.
--
-- WHAT IS DELIBERATELY LEFT ALONE, having been checked and found correct:
--
--   * TWELVE "Language: Native Tongue" rows at 88-97%. Every one is the figure
--     its own book prints - the Vagabond really does speak at 88%, the Mystic
--     at 97% - and the catalog's generic 98% is not what those classes get.
--   * The NOBLE's Horsemanship: General at 35%/+5. The O.C.C. block prints it
--     with no bonus at all; the 35 is the Palladium Fantasy skill's own number,
--     which its note already records. A cross-system difference, not an error.
--   * The WARRIOR MONK's Begging at 20%/+3. Palladium Fantasy prints, in so
--     many words, "Base Skill: 20%+3% per level of experience."
--
-- THE CHIANG-KU HATCHLING is a different defect found by the same sweep. Its
-- adult form knows all domestic skills at 80%, which is right; the hatchling
-- variant lowered five of them to a flat 25, which is nobody's number. Dragons
-- & Gods p.22: hatchling skills "start at first level proficiency", and the
-- override's Advanced Math already reads that way, at the catalog's own 45.
-- The five domestic rows now do too.
--
-- Guarded on the exact old line, so re-running is a no-op and a row somebody has
-- since edited is left alone.

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Mathematics: Advanced", base: 10, per_level: 0, note: "(+10%)" }', '- { name: "Mathematics: Advanced", bonus: 10, note: "(+10%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Mathematics: Advanced", base: 10, per_level: 0, note: "(+10%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Mathematics: Basic", base: 30, per_level: 0, note: "(+30%)" }', '- { name: "Mathematics: Basic", bonus: 30, note: "(+30%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Mathematics: Basic", base: 30, per_level: 0, note: "(+30%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Basic Mechanics", base: 20, per_level: 0, note: "(+20%)" }', '- { name: "Basic Mechanics", bonus: 20, note: "(+20%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Basic Mechanics", base: 20, per_level: 0, note: "(+20%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Basic Electronics", base: 15, per_level: 0, note: "(+15%)" }', '- { name: "Basic Electronics", bonus: 15, note: "(+15%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Basic Electronics", base: 15, per_level: 0, note: "(+15%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Biology", base: 20, per_level: 0, note: "(+20%)" }', '- { name: "Biology", bonus: 20, note: "(+20%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Biology", base: 20, per_level: 0, note: "(+20%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Chemistry", base: 10, per_level: 0, note: "(+10%)" }', '- { name: "Chemistry", bonus: 10, note: "(+10%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Chemistry", base: 10, per_level: 0, note: "(+10%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Computer Operation", base: 5, per_level: 0, note: "(+5%)" }', '- { name: "Computer Operation", bonus: 5, note: "(+5%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Computer Operation", base: 5, per_level: 0, note: "(+5%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Find Contraband", base: 10, per_level: 0, note: "(+10%)" }', '- { name: "Find Contraband", bonus: 10, note: "(+10%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Find Contraband", base: 10, per_level: 0, note: "(+10%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "M.D. in Cybernetics", base: 10, per_level: 0, note: "(+10%)" }', '- { name: "M.D. in Cybernetics", bonus: 10, note: "(+10%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "M.D. in Cybernetics", base: 10, per_level: 0, note: "(+10%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Pathology", base: 10, per_level: 0, note: "(+10%)" }', '- { name: "Pathology", bonus: 10, note: "(+10%)" }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Pathology", base: 10, per_level: 0, note: "(+10%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Appraise Goods", base: 20, per_level: 0, note: "+20%" }', '- { name: "Appraise Goods", bonus: 20, note: "+20%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Appraise Goods", base: 20, per_level: 0, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Mathematics: Basic", base: 25, per_level: 0, note: "+25%" }', '- { name: "Mathematics: Basic", bonus: 25, note: "+25%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Mathematics: Basic", base: 25, per_level: 0, note: "+25%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Computer Operation", base: 20, per_level: 0, note: "+20%" }', '- { name: "Computer Operation", bonus: 20, note: "+20%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Computer Operation", base: 20, per_level: 0, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Computer Programming", base: 15, per_level: 0, note: "+15%" }', '- { name: "Computer Programming", bonus: 15, note: "+15%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Computer Programming", base: 15, per_level: 0, note: "+15%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Creative Writing", base: 15, per_level: 0, note: "+15%" }', '- { name: "Creative Writing", bonus: 15, note: "+15%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Creative Writing", base: 15, per_level: 0, note: "+15%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Find Contraband", base: 15, per_level: 0, note: "+15%; also +20% specifically related to books, art, film and pre-Rifts artifacts (see Special O.C.C. Abilities)." }', '- { name: "Find Contraband", bonus: 15, note: "+15%; also +20% specifically related to books, art, film and pre-Rifts artifacts (see Special O.C.C. Abilities)." }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Find Contraband", base: 15, per_level: 0, note: "+15%; also +20% specifically related to books, art, film and pre-Rifts artifacts (see Special O.C.C. Abilities)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "History: Pre-Rifts", base: 22, per_level: 0, note: "+22%" }', '- { name: "History: Pre-Rifts", bonus: 22, note: "+22%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "History: Pre-Rifts", base: 22, per_level: 0, note: "+22%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "History: Post-Apocalypse", base: 20, per_level: 0, note: "+20%" }', '- { name: "History: Post-Apocalypse", bonus: 20, note: "+20%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "History: Post-Apocalypse", base: 20, per_level: 0, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Public Speaking", base: 20, per_level: 0, note: "+20%" }', '- { name: "Public Speaking", bonus: 20, note: "+20%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Public Speaking", base: 20, per_level: 0, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Research", base: 30, per_level: 0, note: "+30%" }', '- { name: "Research", bonus: 30, note: "+30%" }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { name: "Research", base: 30, per_level: 0, note: "+30%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Cook", base: 15, per_level: 5, note: "+15%" }', '- { name: "Cook", bonus: 15, note: "+15%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Cook", base: 15, per_level: 5, note: "+15%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Climbing", base: 20, per_level: 5, note: "+20%" }', '- { name: "Climbing", bonus: 20, note: "+20%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Climbing", base: 20, per_level: 5, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Fishing", base: 15, per_level: 5, note: "+15%" }', '- { name: "Fishing", bonus: 15, note: "+15%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Fishing", base: 15, per_level: 5, note: "+15%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Horsemanship: General", base: 20, per_level: 5, note: "+20%" }', '- { name: "Horsemanship: General", bonus: 20, note: "+20%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Horsemanship: General", base: 20, per_level: 5, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Identify Plants & Fruit", base: 20, per_level: 5, note: "+20%" }', '- { name: "Identify Plants & Fruit", bonus: 20, note: "+20%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Identify Plants & Fruit", base: 20, per_level: 5, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Land Navigation", base: 20, per_level: 5, note: "+20%" }', '- { name: "Land Navigation", bonus: 20, note: "+20%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Land Navigation", base: 20, per_level: 5, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Prowl", base: 15, per_level: 5, note: "+15%" }', '- { name: "Prowl", bonus: 15, note: "+15%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Prowl", base: 15, per_level: 5, note: "+15%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Radio: Basic", base: 10, per_level: 5, note: "+10%" }', '- { name: "Radio: Basic", bonus: 10, note: "+10%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Radio: Basic", base: 10, per_level: 5, note: "+10%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Wilderness Survival", base: 20, per_level: 5, note: "+20%" }', '- { name: "Wilderness Survival", bonus: 20, note: "+20%" }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Wilderness Survival", base: 20, per_level: 5, note: "+20%" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Mathematics: Basic", base: 10, per_level: 5, note: "+10% bonus over base." }', '- { name: "Mathematics: Basic", bonus: 10, note: "+10% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Mathematics: Basic", base: 10, per_level: 5, note: "+10% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Military Etiquette", base: 15, per_level: 5, note: "+15% bonus over base." }', '- { name: "Military Etiquette", bonus: 15, note: "+15% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Military Etiquette", base: 15, per_level: 5, note: "+15% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Radio: Basic", base: 10, per_level: 5, note: "+10% bonus over base." }', '- { name: "Radio: Basic", bonus: 10, note: "+10% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Radio: Basic", base: 10, per_level: 5, note: "+10% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Automobile", base: 15, per_level: 5, note: "+15% bonus over base." }', '- { name: "Automobile", bonus: 15, note: "+15% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Automobile", base: 15, per_level: 5, note: "+15% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Hover Craft (ground)", base: 15, per_level: 5, note: "+15% bonus over base." }', '- { name: "Hover Craft (ground)", bonus: 15, note: "+15% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Hover Craft (ground)", base: 15, per_level: 5, note: "+15% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Robots & Power Armor", base: 15, per_level: 5, note: "+15% bonus over base." }', '- { name: "Robots & Power Armor", bonus: 15, note: "+15% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Robots & Power Armor", base: 15, per_level: 5, note: "+15% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Sensory Equipment", base: 15, per_level: 5, note: "+15% bonus over base." }', '- { name: "Sensory Equipment", bonus: 15, note: "+15% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Sensory Equipment", base: 15, per_level: 5, note: "+15% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Weapon Systems", base: 15, per_level: 5, note: "+15% bonus over base." }', '- { name: "Weapon Systems", bonus: 15, note: "+15% bonus over base." }')
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, '- { name: "Weapon Systems", base: 15, per_level: 5, note: "+15% bonus over base." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Mathematics: Basic", base: 40, per_level: 5 }', '- { name: "Mathematics: Basic", bonus: 40 }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Mathematics: Basic", base: 40, per_level: 5 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Mathematics: Advanced", base: 20, per_level: 5 }', '- { name: "Mathematics: Advanced", bonus: 20 }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Mathematics: Advanced", base: 20, per_level: 5 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Astronomy", base: 15, per_level: 5 }', '- { name: "Astronomy", bonus: 15 }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Astronomy", base: 15, per_level: 5 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Lore: Demons & Monsters", base: 10, per_level: 5 }', '- { name: "Lore: Demons & Monsters", bonus: 10 }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Lore: Demons & Monsters", base: 10, per_level: 5 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Land Navigation", base: 10, per_level: 5 }', '- { name: "Land Navigation", bonus: 10 }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Land Navigation", base: 10, per_level: 5 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Swimming", base: 5, per_level: 5 }', '- { name: "Swimming", bonus: 5 }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Swimming", base: 5, per_level: 5 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Barter", base: 16, per_level: 0 }', '- { name: "Barter", bonus: 16 }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "Barter", base: 16, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Cook", base: 15, per_level: 0 }', '- { name: "Cook", bonus: 15 }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "Cook", base: 15, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "I.D. Undercover Agent", base: 10, per_level: 0 }', '- { name: "I.D. Undercover Agent", bonus: 10 }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "I.D. Undercover Agent", base: 10, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Radio: Basic", base: 5, per_level: 0 }', '- { name: "Radio: Basic", bonus: 5 }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "Radio: Basic", base: 5, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Streetwise", base: 10, per_level: 0 }', '- { name: "Streetwise", bonus: 10 }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "Streetwise", base: 10, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Cook", base: 25 }', '- { name: "Cook", base: 35, per_level: 5, note: "First level proficiency - the hatchling has not learned the adult 80% yet." }')
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, '- { name: "Cook", base: 25 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Dance", base: 25 }', '- { name: "Dance", base: 30, per_level: 5, note: "First level proficiency - the hatchling has not learned the adult 80% yet." }')
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, '- { name: "Dance", base: 25 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Fishing", base: 25 }', '- { name: "Fishing", base: 40, per_level: 5, note: "First level proficiency - the hatchling has not learned the adult 80% yet." }')
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, '- { name: "Fishing", base: 25 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Play Musical Instrument", base: 25 }', '- { name: "Play Musical Instrument", base: 35, per_level: 5, note: "First level proficiency - the hatchling has not learned the adult 80% yet." }')
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, '- { name: "Play Musical Instrument", base: 25 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Sewing", base: 25 }', '- { name: "Sewing", base: 40, per_level: 5, note: "First level proficiency - the hatchling has not learned the adult 80% yet." }')
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, '- { name: "Sewing", base: 25 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Begging", base: 10, per_level: 0 }', '- { name: "Begging", base: 10, note: "Printed as Begging (10%) with no plus, where every sibling line has one - a real base, not a bonus. Advances at the catalog +3%/level." }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "Begging", base: 10, per_level: 0 }') > 0;


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS classes_carrying_a_bonus FROM imported_classes
 WHERE class_id IN ('cyber-doc', 'rogue-scholar', 'wilderness-scout',
                    'coalition-samas-pilot', 'stone-master', 'vagabond')
   AND instr(markdown, ', bonus: ') > 0;
SELECT count(*) AS cyber_doc_computer_operation_still_at_5 FROM imported_classes
 WHERE class_id = 'cyber-doc'
   AND instr(markdown, 'Computer Operation' || char(34) || ', base: 5') > 0;
SELECT count(*) AS chiang_ku_flat_25_left FROM imported_classes
 WHERE class_id = 'chiang-ku-dragon' AND instr(markdown, ', base: 25 }') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE class_id IN ('cyber-doc', 'rogue-scholar', 'wilderness-scout',
                    'coalition-samas-pilot', 'stone-master', 'vagabond',
                    'chiang-ku-dragon')
   AND instr(markdown, char(13)) > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-occ-bonus-as-base.sql');
