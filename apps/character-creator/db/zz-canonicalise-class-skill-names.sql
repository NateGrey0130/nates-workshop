-- Canonicalise class skill names to RUE, LAST.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-canonicalise-class-skill-names.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-canonicalise-class-skill-names.sql
--
-- WHY A SECOND COPY OF fix-class-skill-names-to-rue.sql EXISTS.
--
-- Data scripts are applied in FILENAME order, which is not the order they were
-- actually run. fix-class-skill-names-to-rue.sql was applied to production by
-- hand, last, so it won. In a database built from the repo it sorts under f,
-- and THREE scripts that sort after it write the pre-RUE names back:
--
--   fix-dead-skill-restrictions.sql   an earlier attempt at this same problem
--   fix-dragon-hatchling.sql
--   fix-juicer-rue-edition.sql
--
-- So production was correct and a fresh build was not - the regression audit of
-- only/except restrictions is what caught it, naming five skills a fresh build
-- did not have.
--
-- Editing those three would break the rule that an applied script is never
-- edited. Sorting after all of them is the alternative, and zz- is the only
-- prefix that guarantees it: the last data script today is untag-cross-system.
--
-- Identical to fix-class-skill-names-to-rue.sql and idempotent, so on
-- production it finds nothing to do.

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



-- Found by the new restriction audit rather than by the RUE diff: the Mystic
-- excludes "Warships", the catalog row is "Military: Warships & Patrol Boats",
-- and that exclusion has been excluding nothing for as long as both existed.
UPDATE imported_classes
   SET markdown = replace(markdown, '"Warships"', '"Military: Warships & Patrol Boats"'),
       updated_at = datetime('now')
 WHERE instr(markdown, '"Warships"') > 0;

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

INSERT INTO data_script_runs (filename) VALUES ('zz-canonicalise-class-skill-names.sql');
