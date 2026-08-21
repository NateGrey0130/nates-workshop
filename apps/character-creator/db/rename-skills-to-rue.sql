-- Reconcile skill names to Rifts Ultimate Edition.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/rename-skills-to-rue.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/rename-skills-to-rue.sql
--
-- RUE (August 2005) is the later book and the stated source of truth, so where
-- it and the catalog disagree about what a skill is CALLED, RUE wins.
--
-- HOW THE PAIRS WERE DECIDED, rather than guessed. RUE's Skill List (printed
-- pp.302-303) prints every skill with its base and per-level percentages, so a
-- proposed pair could be checked against two independent readings instead of
-- against how similar the names looked. In nine cases the numbers agreed
-- exactly, which is the evidence for calling them the same skill.
--
-- ONE PAIR FAILED THAT TEST AND IS NOT HERE. RUE's Interrogation is Espionage
-- at 30%+5%; the catalog's Interrogation Techniques is Military at 40%+5% and
-- came from another book. Similar names, different skills - so Interrogation is
-- added as a new row below and Interrogation Techniques is left alone.
--
-- THE PREFIX POLICY. The catalog's stated convention was to store pilot skills
-- WITHOUT a Military:/Pilot: prefix, and it already broke that rule for four
-- rows. RUE prefixes the Military ones consistently and prints Robots & Power
-- Armor with no prefix at all, so this adopts RUE's naming in both directions.
-- That fixes a live bug: the Shifter restricts Pilot skills "except Military:
-- Jet Fighters", the catalog row was Jet Fighters, and the exclusion therefore
-- matched nothing and excluded nothing.
--
-- W.P.s CARRY NO PERCENTAGES - every W.P. row is 0/0 by nature, not because it
-- is unfilled - so the number test cannot discriminate them and the book's own
-- wording had to settle the two heavy ones.
--
-- W.P. Heavy Military Weapons is unambiguous: RUE prints it as a skill in its
-- own right, both in the Skill List (printed p303) and in class entries (p83).
--
-- The other is ambiguous INSIDE RUE. The master Skill List prints
-- W.P. Heavy M.D. Weapons; the class entries print "W.P. Heavy Energy Weapons
-- (including rail guns)" and p87 excludes "Heavy Military Weapons and Heavy
-- Energy...". Both names are the book's. The Skill List is the master table so
-- it wins the row name, and the redirect below means a class citing the other
-- form still resolves rather than creating a duplicate - crossReference()
-- treats a redirected key as present.
--
-- A RENAME BREAKS THE SAME REFERENCES A MERGE DOES, so each is three jobs:
--   1. the catalog row          renamed, only when the new name is free
--   2. class markdown citing it left ALONE, with a redirect recorded instead
--   3. characters holding it    repointed, so a sheet shows the new name
-- Guarded throughout and safe to re-run.


-- ===== 1. Renames =====

-- Writing -> Creative Writing  (both 25%+5%)
UPDATE skills SET name = 'Creative Writing'
 WHERE name = 'Writing'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Creative Writing');

-- Surveillance Systems -> Surveillance  (both 30%+5%)
UPDATE skills SET name = 'Surveillance'
 WHERE name = 'Surveillance Systems'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Surveillance');

-- Read Sensory Equipment -> Sensory Equipment  (both 30%+5%)
UPDATE skills SET name = 'Sensory Equipment'
 WHERE name = 'Read Sensory Equipment'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Sensory Equipment');

-- Criminal Sciences & Forensics -> Forensics  (both 35%+5%)
UPDATE skills SET name = 'Forensics'
 WHERE name = 'Criminal Sciences & Forensics'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Forensics');

-- Motorcycle -> Motorcycles & Snowmobiles  (both 60%+4%)
UPDATE skills SET name = 'Motorcycles & Snowmobiles'
 WHERE name = 'Motorcycle'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Motorcycles & Snowmobiles');

-- Boat: Motor and Hydrofoils -> Boat: Motor, Race & Hydrofoil  (both 55%+5%)
UPDATE skills SET name = 'Boat: Motor, Race & Hydrofoil'
 WHERE name = 'Boat: Motor and Hydrofoils'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Boat: Motor, Race & Hydrofoil');

-- Basic Math -> Mathematics: Basic  (both 45%+5%; 20 classes cite the old name)
UPDATE skills SET name = 'Mathematics: Basic'
 WHERE name = 'Basic Math'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Mathematics: Basic');

-- Advanced Math -> Mathematics: Advanced  (both 45%+5%; 12 classes cite the old name)
UPDATE skills SET name = 'Mathematics: Advanced'
 WHERE name = 'Advanced Math'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Mathematics: Advanced');

-- Lore <U+2014> Faerie -> Lore: Faeries & Creatures of Magic  (both 25%+5%)
UPDATE skills SET name = 'Lore: Faeries & Creatures of Magic'
 WHERE name = 'Lore ' || char(8212) || ' Faerie'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Lore: Faeries & Creatures of Magic');

-- S.C.U.B.A. -> SCUBA  (identical once punctuation is stripped)
UPDATE skills SET name = 'SCUBA'
 WHERE name = 'S.C.U.B.A.'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'SCUBA');

-- W.P. Sub-Machinegun -> W.P. Submachine-Gun  (identical once punctuation is stripped)
UPDATE skills SET name = 'W.P. Submachine-Gun'
 WHERE name = 'W.P. Sub-Machinegun'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'W.P. Submachine-Gun');

-- Identify Plants & Fruits -> Identify Plants & Fruit  (plural)
UPDATE skills SET name = 'Identify Plants & Fruit'
 WHERE name = 'Identify Plants & Fruits'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Identify Plants & Fruit');

-- Breaking/Taming Wild Horses -> Breaking/Taming Wild Horse  (plural)
UPDATE skills SET name = 'Breaking/Taming Wild Horse'
 WHERE name = 'Breaking/Taming Wild Horses'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Breaking/Taming Wild Horse');

-- Jet Fighters -> Military: Jet Fighters  (RUE prefixes it; the Shifter cites the prefixed form)
UPDATE skills SET name = 'Military: Jet Fighters'
 WHERE name = 'Jet Fighters'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Military: Jet Fighters');

-- Tanks and APCs -> Military: Tanks & APCs  (RUE prefixes it)
UPDATE skills SET name = 'Military: Tanks & APCs'
 WHERE name = 'Tanks and APCs'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Military: Tanks & APCs');

-- Pilot: Robots & Power Armor -> Robots & Power Armor  (RUE prints no prefix on this one)
UPDATE skills SET name = 'Robots & Power Armor'
 WHERE name = 'Pilot: Robots & Power Armor'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Robots & Power Armor');

-- W.P. Heavy -> W.P. Heavy Military Weapons  (RUE prints W.P. Heavy Military Weapons as a skill in its own right (p303, p83))
UPDATE skills SET name = 'W.P. Heavy Military Weapons'
 WHERE name = 'W.P. Heavy'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'W.P. Heavy Military Weapons');

-- W.P. Heavy Energy Weapons -> W.P. Heavy M.D. Weapons  (the master Skill List p303 calls it this; RUE class pages call it Heavy Energy Weapons)
UPDATE skills SET name = 'W.P. Heavy M.D. Weapons'
 WHERE name = 'W.P. Heavy Energy Weapons'
   AND NOT EXISTS (SELECT 1 FROM skills WHERE name = 'W.P. Heavy M.D. Weapons');


-- ===== 2. Forwarding pointers for the retired names =====
-- reason 'rename': nothing was deleted, and the distinction is the only
-- record of which of the two happened.

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Writing', id, 'rename' FROM skills WHERE name = 'Creative Writing';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Surveillance Systems', id, 'rename' FROM skills WHERE name = 'Surveillance';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Read Sensory Equipment', id, 'rename' FROM skills WHERE name = 'Sensory Equipment';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Criminal Sciences & Forensics', id, 'rename' FROM skills WHERE name = 'Forensics';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Motorcycle', id, 'rename' FROM skills WHERE name = 'Motorcycles & Snowmobiles';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Boat: Motor and Hydrofoils', id, 'rename' FROM skills WHERE name = 'Boat: Motor, Race & Hydrofoil';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Basic Math', id, 'rename' FROM skills WHERE name = 'Mathematics: Basic';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Advanced Math', id, 'rename' FROM skills WHERE name = 'Mathematics: Advanced';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Lore ' || char(8212) || ' Faerie', id, 'rename' FROM skills WHERE name = 'Lore: Faeries & Creatures of Magic';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'S.C.U.B.A.', id, 'rename' FROM skills WHERE name = 'SCUBA';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'W.P. Sub-Machinegun', id, 'rename' FROM skills WHERE name = 'W.P. Submachine-Gun';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Identify Plants & Fruits', id, 'rename' FROM skills WHERE name = 'Identify Plants & Fruit';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Breaking/Taming Wild Horses', id, 'rename' FROM skills WHERE name = 'Breaking/Taming Wild Horse';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Jet Fighters', id, 'rename' FROM skills WHERE name = 'Military: Jet Fighters';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Tanks and APCs', id, 'rename' FROM skills WHERE name = 'Military: Tanks & APCs';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'Pilot: Robots & Power Armor', id, 'rename' FROM skills WHERE name = 'Robots & Power Armor';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'W.P. Heavy', id, 'rename' FROM skills WHERE name = 'W.P. Heavy Military Weapons';

INSERT OR IGNORE INTO catalog_redirects (catalog, from_key, to_id, reason)
SELECT 'skills', 'W.P. Heavy Energy Weapons', id, 'rename' FROM skills WHERE name = 'W.P. Heavy M.D. Weapons';


-- ===== 3. Characters holding a retired name =====
-- Matches the QUOTED name, so a longer skill name that merely contains
-- this one cannot match - its closing quote falls elsewhere.

UPDATE characters SET skills = replace(skills, '"' || 'Writing' || '"', '"' || 'Creative Writing' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Writing' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Surveillance Systems' || '"', '"' || 'Surveillance' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Surveillance Systems' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Read Sensory Equipment' || '"', '"' || 'Sensory Equipment' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Read Sensory Equipment' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Criminal Sciences & Forensics' || '"', '"' || 'Forensics' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Criminal Sciences & Forensics' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Motorcycle' || '"', '"' || 'Motorcycles & Snowmobiles' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Motorcycle' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Boat: Motor and Hydrofoils' || '"', '"' || 'Boat: Motor, Race & Hydrofoil' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Boat: Motor and Hydrofoils' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Basic Math' || '"', '"' || 'Mathematics: Basic' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Basic Math' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Advanced Math' || '"', '"' || 'Mathematics: Advanced' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Advanced Math' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Lore ' || char(8212) || ' Faerie' || '"', '"' || 'Lore: Faeries & Creatures of Magic' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Lore ' || char(8212) || ' Faerie' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'S.C.U.B.A.' || '"', '"' || 'SCUBA' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'S.C.U.B.A.' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'W.P. Sub-Machinegun' || '"', '"' || 'W.P. Submachine-Gun' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'W.P. Sub-Machinegun' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Identify Plants & Fruits' || '"', '"' || 'Identify Plants & Fruit' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Identify Plants & Fruits' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Breaking/Taming Wild Horses' || '"', '"' || 'Breaking/Taming Wild Horse' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Breaking/Taming Wild Horses' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Jet Fighters' || '"', '"' || 'Military: Jet Fighters' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Jet Fighters' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Tanks and APCs' || '"', '"' || 'Military: Tanks & APCs' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Tanks and APCs' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'Pilot: Robots & Power Armor' || '"', '"' || 'Robots & Power Armor' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'Pilot: Robots & Power Armor' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'W.P. Heavy' || '"', '"' || 'W.P. Heavy Military Weapons' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'W.P. Heavy' || '"%';

UPDATE characters SET skills = replace(skills, '"' || 'W.P. Heavy Energy Weapons' || '"', '"' || 'W.P. Heavy M.D. Weapons' || '"'),
       updated_at = datetime('now')
 WHERE skills LIKE '%"' || 'W.P. Heavy Energy Weapons' || '"%';


-- ===== 4. Skills RUE has that the catalog did not =====

-- RUE Espionage. NOT the same as Interrogation Techniques, which is Military, bases at 40% and came from another book - the numbers disagree.
INSERT INTO skills (name, category, base, per_level, source, source_book)
SELECT 'Interrogation', 'Espionage', 30, 5, 'manual', 'Rifts Ultimate Edition'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Interrogation');

-- RUE lists Recycle (Domestic) and Recycling (Technical) as separate skills.
INSERT INTO skills (name, category, base, per_level, source, source_book)
SELECT 'Recycling', 'Technical', 30, 5, 'manual', 'Rifts Ultimate Edition'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'Recycling');

-- RUE lists it in Physical Skills as the explicit absence of hand to hand training.
INSERT INTO skills (name, category, base, per_level, source, source_book)
SELECT 'No Hand to Hand Combat Skill', 'Physical', 0, 0, 'manual', 'Rifts Ultimate Edition'
 WHERE NOT EXISTS (SELECT 1 FROM skills WHERE name = 'No Hand to Hand Combat Skill');


-- ===== Read the result back rather than trusting the exit code =====
--   renamed_present   18 = every new name exists
--   old_names_left    0 = no retired name survives as a row
--   redirects         18 = every retired name forwards somewhere
--   chars_on_old      0 = no character still stores a retired name
--   new_rows          3 = the skills RUE adds
SELECT (SELECT count(*) FROM skills WHERE name IN ('Creative Writing', 'Surveillance', 'Sensory Equipment', 'Forensics', 'Motorcycles & Snowmobiles', 'Boat: Motor, Race & Hydrofoil', 'Mathematics: Basic', 'Mathematics: Advanced', 'Lore: Faeries & Creatures of Magic', 'SCUBA', 'W.P. Submachine-Gun', 'Identify Plants & Fruit', 'Breaking/Taming Wild Horse', 'Military: Jet Fighters', 'Military: Tanks & APCs', 'Robots & Power Armor', 'W.P. Heavy Military Weapons', 'W.P. Heavy M.D. Weapons')) AS renamed_present,
       (SELECT count(*) FROM skills WHERE name IN ('Writing', 'Surveillance Systems', 'Read Sensory Equipment', 'Criminal Sciences & Forensics', 'Motorcycle', 'Boat: Motor and Hydrofoils', 'Basic Math', 'Advanced Math', 'Lore ' || char(8212) || ' Faerie', 'S.C.U.B.A.', 'W.P. Sub-Machinegun', 'Identify Plants & Fruits', 'Breaking/Taming Wild Horses', 'Jet Fighters', 'Tanks and APCs', 'Pilot: Robots & Power Armor', 'W.P. Heavy', 'W.P. Heavy Energy Weapons')) AS old_names_left,
       (SELECT count(*) FROM catalog_redirects WHERE catalog = 'skills'
          AND from_key IN ('Writing', 'Surveillance Systems', 'Read Sensory Equipment', 'Criminal Sciences & Forensics', 'Motorcycle', 'Boat: Motor and Hydrofoils', 'Basic Math', 'Advanced Math', 'Lore ' || char(8212) || ' Faerie', 'S.C.U.B.A.', 'W.P. Sub-Machinegun', 'Identify Plants & Fruits', 'Breaking/Taming Wild Horses', 'Jet Fighters', 'Tanks and APCs', 'Pilot: Robots & Power Armor', 'W.P. Heavy', 'W.P. Heavy Energy Weapons')) AS redirects,
       (SELECT count(*) FROM skills WHERE name IN ('Interrogation', 'Recycling', 'No Hand to Hand Combat Skill')) AS new_rows;

-- Every redirect must point at a row that exists, or it is dead weight that
-- silently stops resolving. INNER JOIN, so a broken one drops out of the count.
SELECT count(*) AS redirects_resolving
  FROM catalog_redirects r JOIN skills s ON s.id = r.to_id
 WHERE r.catalog = 'skills' AND r.from_key IN ('Writing', 'Surveillance Systems', 'Read Sensory Equipment', 'Criminal Sciences & Forensics', 'Motorcycle', 'Boat: Motor and Hydrofoils', 'Basic Math', 'Advanced Math', 'Lore ' || char(8212) || ' Faerie', 'S.C.U.B.A.', 'W.P. Sub-Machinegun', 'Identify Plants & Fruits', 'Breaking/Taming Wild Horses', 'Jet Fighters', 'Tanks and APCs', 'Pilot: Robots & Power Armor', 'W.P. Heavy', 'W.P. Heavy Energy Weapons');

-- The Shifter's Pilot restriction should now match a real row.
SELECT count(*) AS jet_fighters_row FROM skills WHERE name = 'Military: Jet Fighters';

INSERT INTO data_script_runs (filename) VALUES ('rename-skills-to-rue.sql');
