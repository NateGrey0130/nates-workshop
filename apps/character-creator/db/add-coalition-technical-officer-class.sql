-- The Coalition Technical Officer O.C.C., Rifts Ultimate Edition p.236-237.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-coalition-technical-officer-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-coalition-technical-officer-class.sql
--
-- Extracted with the app's own class importer from the Rifts Ultimate Edition
-- PDF and validated with scripts/class-check.mjs before this file was
-- generated. Applied as a script rather than through the import UI because
-- production sits behind Cloudflare Access.
--
-- THE PDF HAS NO TEXT LAYER. All 382 pages are scanned images, so the model
-- read the pages as images rather than parsing text. That is what the importer
-- does anyway - it sends the PDF as a document attachment and never
-- pre-extracts text, because layout-preserving extraction splices neighbouring
-- columns together mid-line on a two-column sourcebook page.
--
-- SKILL BASES AND NAMES ARE POST-PROCESSED, not taken as extracted. The model
-- has the printed bonus ("+15%") but no catalog, so it returns base 0 and
-- strands the bonus in a note; the convention is that a skill's base is the
-- CATALOG base plus the printed bonus, already added. And RUE contradicts
-- itself on names - its class entries print "Basic Math" and "Lore: D-Bees"
-- where its own Skill List prints "Mathematics: Basic" and "Lore: D-Bee" - so
-- names are resolved through catalog_redirects to the canonical row. That
-- matters beyond tidiness: a restriction is matched by raw name, in the
-- browser, where redirects are not available.

-- Stub rows for what the catalog lacks. The "STUB" marker is load-bearing: it
-- is how the gear importer later recognises a row as still needing stats.
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('dead-boy-body-armor', 'Dead Boy Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.236-237');


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'coalition-technical-officer', 'Coalition Technical Officer', 'rifts', '---
id: coalition-technical-officer
name: Coalition Technical Officer
system: rifts
source_book: Rifts Ultimate Edition p.236-237
category: occ
attribute_requirements: { IQ: 9 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { name: "Literacy: Native Language", base: 60, per_level: 5 }
    - { name: "Mathematics: Basic", base: 75, per_level: 5 }
    - { name: "Military Etiquette", base: 55, per_level: 5 }
    - { name: "Computer Operation", base: 55, per_level: 5 }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5 }
    - { name: "Radio: Basic", base: 55, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related skill." }
  mos:
    choose: 1
    note: "Select one area of specialty. Every skill under it is granted in addition to the O.C.C. skills."
    options:
      - id: "communications"
        name: "Communications MOS"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5 }
          - { name: "Cryptography", base: 35, per_level: 5 }
          - { name: "Electronic Countermeasures", base: 45, per_level: 5 }
          - { name: "Laser Communications", base: 45, per_level: 5 }
          - { name: "Radio: Basic", base: 70, per_level: 5 }
          - { name: "T.V./Video", base: 35, per_level: 4 }
          - { choose: 1, categories: ["Communications"], bonus: 10 }
      - id: "electrician"
        name: "Electrician MOS"
        skills:
          - { name: "Mathematics: Advanced", base: 55, per_level: 5 }
          - { name: "Basic Mechanics", base: 45, per_level: 5 }
          - { name: "Electrical Engineer", base: 45, per_level: 5 }
          - { name: "Computer Operation", base: 60, per_level: 5 }
          - { name: "Computer Programming", base: 40, per_level: 5 }
          - { name: "Computer Repair", base: 40, per_level: 5 }
          - { choose: 1, categories: ["Communications", "Electrical"], bonus: 10 }
      - id: "mechanic"
        name: "Mechanic MOS"
        skills:
          - { name: "Automotive Mechanics", base: 45, per_level: 5 }
          - { name: "Basic Electronics", base: 45, per_level: 5 }
          - { name: "Computer Operation", base: 50, per_level: 5 }
          - { name: "Locksmith", base: 35, per_level: 5 }
          - { name: "Mechanical Engineer", base: 40, per_level: 5 }
          - { name: "Vehicle Armorer", base: 40, per_level: 5 }
          - { choose: 1, categories: ["Mechanical", "Electrical"], bonus: 10 }
      - id: "robotics"
        name: "Robotics MOS"
        skills:
          - { name: "Computer Programming", base: 40, per_level: 5 }
          - { name: "Robots & Power Armor", base: 71, per_level: 3 }
          - { name: "Robot Electronics", base: 50, per_level: 5 }
          - { name: "Robot Mechanics", base: 35, per_level: 5 }
          - { name: "Vehicle Armorer", base: 35, per_level: 5 }
          - { choose: 2, categories: ["Mechanical", "Electrical"], bonus: 10 }
      - id: "technician"
        name: "Technician MOS"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5 }
          - { name: "General Repair & Maintenance", base: 50, per_level: 5 }
          - { name: "Research", base: 50, per_level: 5 }
          - { name: "Sensory Equipment", base: 45, per_level: 5 }
          - { choose: 4, categories: ["Technical", "Science"], bonus: 15 }
      - id: "medic"
        name: "Medic MOS"
        skills:
          - { name: "Biology", base: 45, per_level: 5 }
          - { name: "Field Surgery", base: 31, per_level: 4 }
          - { name: "Medical Doctor", base: 65, per_level: 5 }
          - { name: "Paramedic", base: 55, per_level: 5 }
          - { choose: 2, categories: ["Medical"], bonus: 10 }
      - id: "weapons"
        name: "Weapons MOS"
        skills:
          - { name: "Mathematics: Advanced", base: 60, per_level: 5 }
          - { name: "Demolitions", base: 70, per_level: 3 }
          - { name: "Demolitions Disposal", base: 75, per_level: 3 }
          - { choose: 4, categories: ["Weapon Proficiencies"] }
  occ_related_skills:
    count: 3
    categories: ["Communications", "Domestic", "Medical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Technical", "Weapon Proficiencies"]
    note: "Communications Any (+5%). Domestic Any. Electrical, Science and Wilderness: none unless part of his MOS. Espionage, Horsemanship and Cowboy: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 10, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
  secondary_skills:
    count: 3
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "dead-boy-body-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
extraction_notes: |
  - The MOS list was read from a COLUMN-ORDERED re-OCR of printed pp.236-237.
    Tesseract''s own page segmentation spliced the two columns together and
    produced "Medic MOS: computer, tool kit if applicable" - the left column''s
    heading running into the right column''s equipment list. Seven specialties,
    not the five visible on the first page.
  - The book says the MOS skills are granted "plus the MOS skills chosen
    previously", which is why this is skills.mos rather than variants: a variant
    REPLACES and an MOS ADDS.
  - Skill bases are catalog base + the printed bonus, already added.
---

## Lore

A specialist in one particular area who fills the slot of technical support and some special operations within the Coalition military. Starts at the rank of Corporal.

Alignment: Any. Racial Restrictions: Human.

## GM Notes

Equipment available upon assignment is whatever the mission needs, at the commanding officer''s discretion. All weapons and gear are Coalition property.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'coalition-technical-officer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'coalition-technical-officer';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-coalition-technical-officer-class.sql');
