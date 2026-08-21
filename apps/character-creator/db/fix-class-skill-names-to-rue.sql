-- Point class definitions at the RUE skill names.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-class-skill-names-to-rue.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-class-skill-names-to-rue.sql
--
-- Runs AFTER rename-skills-to-rue.sql and finishes the job it starts.
--
-- WHY A REDIRECT WAS NOT ENOUGH. The rename convention says to leave class
-- markdown alone and record a redirect, because crossReference() treats a
-- redirected key as present. That is true of a skill a class GRANTS. It is NOT
-- true of a RESTRICTION: js/parser.js matches `only` and `except` entries
-- against the skill name as a raw normalised string, and nothing in that path
-- consults catalog_redirects.
--
-- So renaming the rows alone left 69 citations across 22 classes naming skills
-- no row carries, and a restriction matching nothing fails in whichever
-- direction is worse for the entry:
--
--   except: ["X"]  ->  excludes nothing, so the class grants MORE than the book
--   only:   ["X"]  ->  narrows to nothing, so the class grants nothing at all
--
-- The Shifter is the visible case: it restricts Pilot skills "except Jet
-- Fighters", and the rename stopped that exclusion excluding anything.
--
-- MATCHES THE QUOTED NAME, not the bare one. Class markdown is frontmatter
-- mixed with lore prose and a bare replace would rewrite both. The surrounding
-- quotes make it exact: a longer skill name that merely CONTAINS this one
-- cannot match, because its closing quote falls elsewhere. Same argument the
-- character repoint in rename-skills-to-rue.sql uses.
--
-- Guarded per class on the text being present, so re-running is a no-op.


-- Writing -> Creative Writing
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Writing' || '"', '"' || 'Creative Writing' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Writing' || '"') > 0;

-- Surveillance Systems -> Surveillance
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Surveillance Systems' || '"', '"' || 'Surveillance' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Surveillance Systems' || '"') > 0;

-- Read Sensory Equipment -> Sensory Equipment
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Read Sensory Equipment' || '"', '"' || 'Sensory Equipment' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Read Sensory Equipment' || '"') > 0;

-- Criminal Sciences & Forensics -> Forensics
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Criminal Sciences & Forensics' || '"', '"' || 'Forensics' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Criminal Sciences & Forensics' || '"') > 0;

-- Motorcycle -> Motorcycles & Snowmobiles
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Motorcycle' || '"', '"' || 'Motorcycles & Snowmobiles' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Motorcycle' || '"') > 0;

-- Boat: Motor and Hydrofoils -> Boat: Motor, Race & Hydrofoil
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Boat: Motor and Hydrofoils' || '"', '"' || 'Boat: Motor, Race & Hydrofoil' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Boat: Motor and Hydrofoils' || '"') > 0;

-- Basic Math -> Mathematics: Basic
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Basic Math' || '"', '"' || 'Mathematics: Basic' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Basic Math' || '"') > 0;

-- Advanced Math -> Mathematics: Advanced
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Advanced Math' || '"', '"' || 'Mathematics: Advanced' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Advanced Math' || '"') > 0;

-- Lore <U+2014> Faerie -> Lore: Faeries & Creatures of Magic
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Lore ' || char(8212) || ' Faerie' || '"', '"' || 'Lore: Faeries & Creatures of Magic' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Lore ' || char(8212) || ' Faerie' || '"') > 0;

-- S.C.U.B.A. -> SCUBA
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'S.C.U.B.A.' || '"', '"' || 'SCUBA' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'S.C.U.B.A.' || '"') > 0;

-- W.P. Sub-Machinegun -> W.P. Submachine-Gun
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'W.P. Sub-Machinegun' || '"', '"' || 'W.P. Submachine-Gun' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'W.P. Sub-Machinegun' || '"') > 0;

-- Identify Plants & Fruits -> Identify Plants & Fruit
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Identify Plants & Fruits' || '"', '"' || 'Identify Plants & Fruit' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Identify Plants & Fruits' || '"') > 0;

-- Breaking/Taming Wild Horses -> Breaking/Taming Wild Horse
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Breaking/Taming Wild Horses' || '"', '"' || 'Breaking/Taming Wild Horse' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Breaking/Taming Wild Horses' || '"') > 0;

-- Jet Fighters -> Military: Jet Fighters
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Jet Fighters' || '"', '"' || 'Military: Jet Fighters' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Jet Fighters' || '"') > 0;

-- Tanks and APCs -> Military: Tanks & APCs
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Tanks and APCs' || '"', '"' || 'Military: Tanks & APCs' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Tanks and APCs' || '"') > 0;

-- Pilot: Robots & Power Armor -> Robots & Power Armor
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'Pilot: Robots & Power Armor' || '"', '"' || 'Robots & Power Armor' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'Pilot: Robots & Power Armor' || '"') > 0;

-- W.P. Heavy -> W.P. Heavy Military Weapons
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'W.P. Heavy' || '"', '"' || 'W.P. Heavy Military Weapons' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'W.P. Heavy' || '"') > 0;

-- W.P. Heavy Energy Weapons -> W.P. Heavy M.D. Weapons
UPDATE imported_classes
   SET markdown = replace(markdown, '"' || 'W.P. Heavy Energy Weapons' || '"', '"' || 'W.P. Heavy M.D. Weapons' || '"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"' || 'W.P. Heavy Energy Weapons' || '"') > 0;


-- Read the result back rather than trusting the exit code.
--   classes_on_old   0 = no class definition names a retired skill in quotes
SELECT count(*) AS classes_on_old
  FROM imported_classes
 WHERE deleted_at IS NULL
   AND (instr(markdown, '"' || 'Writing' || '"') > 0
     OR instr(markdown, '"' || 'Surveillance Systems' || '"') > 0
     OR instr(markdown, '"' || 'Read Sensory Equipment' || '"') > 0
     OR instr(markdown, '"' || 'Criminal Sciences & Forensics' || '"') > 0
     OR instr(markdown, '"' || 'Motorcycle' || '"') > 0
     OR instr(markdown, '"' || 'Boat: Motor and Hydrofoils' || '"') > 0
     OR instr(markdown, '"' || 'Basic Math' || '"') > 0
     OR instr(markdown, '"' || 'Advanced Math' || '"') > 0
     OR instr(markdown, '"' || 'Lore ' || char(8212) || ' Faerie' || '"') > 0
     OR instr(markdown, '"' || 'S.C.U.B.A.' || '"') > 0
     OR instr(markdown, '"' || 'W.P. Sub-Machinegun' || '"') > 0
     OR instr(markdown, '"' || 'Identify Plants & Fruits' || '"') > 0
     OR instr(markdown, '"' || 'Breaking/Taming Wild Horses' || '"') > 0
     OR instr(markdown, '"' || 'Jet Fighters' || '"') > 0
     OR instr(markdown, '"' || 'Tanks and APCs' || '"') > 0
     OR instr(markdown, '"' || 'Pilot: Robots & Power Armor' || '"') > 0
     OR instr(markdown, '"' || 'W.P. Heavy' || '"') > 0
     OR instr(markdown, '"' || 'W.P. Heavy Energy Weapons' || '"') > 0);

-- The Shifter's Pilot restriction, which is what made this necessary.
SELECT count(*) AS shifter_cites_new
  FROM imported_classes
 WHERE class_id = 'shifter' AND instr(markdown, '"Military: Jet Fighters"') > 0;

INSERT INTO data_script_runs (filename) VALUES ('fix-class-skill-names-to-rue.sql');
