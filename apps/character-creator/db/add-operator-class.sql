-- The Operator O.C.C., Rifts Ultimate Edition p.91-92.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-operator-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-operator-class.sql
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


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'operator', 'Operator', 'rifts', '---
id: operator
name: Operator
system: rifts
source_book: Rifts Ultimate Edition p.91-92
category: occ
attribute_requirements: { IQ: 9 }
starting_money: "4d4x1000"
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5 }
    - { name: "Computer Operation", base: 40, per_level: 5 }
    - { name: "Computer Repair", base: 25, per_level: 5 }
    - { name: "Electrical Engineer", base: 50, per_level: 5 }
    - { name: "Find Contraband", base: 41, per_level: 4 }
    - { name: "Jury-Rig", base: 45, per_level: 5 }
    - { name: "Mechanical Engineer", base: 45, per_level: 5 }
    - { choose: 3, categories: ["Pilot"], bonus: 15, note: "Three Pilot skills of choice (+15%)." }
    - { name: "Radio: Basic", base: 60, per_level: 5 }
    - { name: "Sensory Equipment", base: 50, per_level: 5 }
    - { name: "Weapons Engineer", base: 40, per_level: 5 }
    - { name: "Recognize Machine Quality", base: 58, per_level: 3 }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern: one of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related skill, or Martial Arts (or Assassin if evil) for two." }
  occ_related_skills:
    count: 8
    categories: ["Communications", "Domestic", "Electrical", "Mechanical", "Medical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Technical", "Weapon Proficiencies", "Wilderness"]
    note: "At least two must be Mechanical. Communications Any (+15%). Domestic Any. Electrical Any (+10%). Cowboy, Espionage and Horsemanship: none."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 4
special_abilities:
  - name: "Jury-Rig Repairs"
    description: "Slaps together solid temporary repairs in half the time, that last twice as long. See the Jury-Rig skill."
  - name: "Find Parts and Components"
    description: "+20% to Find Contraband when the items are vehicular weapons, M.D. power supplies, M.D.C. materials, communications systems, electronics, generators, fuel, mechanical parts and components. Buys at a 30% discount from other Operators and the Black Market, 50% from junkyards and salvage companies, 65% if he trades at least 12 hours of labour."
  - name: "Repair and Soup-Up Machines & Vehicles"
    description: "Repairs most machines and vehicles at 25% of original list price. Restores M.D.C. on the main body and key sections at 1200 credits per M.D.C. point, never above the original amount."
  - name: "Not a Psi-Operator"
    description: "The ordinary case: four Operators in five have no psychic ability at all. Grants nothing, and is here so that being non-psychic is something the character states rather than something left blank."
  - name: "Psi-Operator"
    description: "Optional. Roughly 15% to 20% of Operators have developed psychic power focused on mechanics. A Psi-Operator is a MAJOR psychic and picks three abilities from the Operator''s list, plus one more at levels 4, 8 and 12. The book also halves the character''s O.C.C. Related Skills, which this app does not enforce."
    psionics:
      type: "major"
      isp_base: "2d4x10"
      powers: ["Electrokinesis", "Machine Ghost", "Object Read (Psychometry)", "Resist Fatigue", "Sense Magic", "Sense Time", "Speed Reading", "Total Recall", "Telemechanics", "Telemechanic Mental Operation", "Telemechanic Paralysis"]
      powers_starting: 3
      powers_schedule:
        - { level: 4, count: 1 }
        - { level: 8, count: 1 }
        - { level: 12, count: 1 }
  - { choose: 1, from: ["Not a Psi-Operator", "Psi-Operator"] }
equipment_starting:
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "large-tool-kit", qty: 1 }
  - { item_id: "soldering-iron", qty: 1 }
  - { item_id: "laser-torch", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "rope", qty: 5, note: "200 feet (60 m) of super lightweight rope; the catalog sells rope per 40 ft." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { choose: 1, label: "light or medium M.D.C. body armour", qty: 1, from: ["huntsman-armor", "explorer-armor"] }
extraction_notes: |
  - THE PSIONICS ARE OPTIONAL and therefore ride an ability rather than the
    class. The book says roughly 15% to 20% of Operators are psychic, so a
    class-level psionics block would make every Operator one. ABILITY_GRANTS
    allows an ability to carry psionics, and the choice of one from two - "Not a
    Psi-Operator" or "Psi-Operator" - makes being ordinary an explicit statement
    rather than a blank.
  - THE RELATED-SKILL HALVING IS NOT ENFORCED. The book halves a Psi-Operator''s
    O.C.C. Related Skills. withRolledPsionics halves them only for a ROLLED
    tier and deliberately skips a class that declares its own psionics;
    extending it to declared-major classes would wrongly halve the Mystic,
    whose printed count already accounts for it. Recorded here and in the
    ability''s own description instead.
  - Object Read is stored as "Object Read (Psychometry)", the name the catalog
    merged it to. The Operator''s page prints the short form, which resolves
    through the existing merge redirect.
  - Recognize Machine Quality is the Operator''s exclusive skill and appears
    nowhere in RUE''s master Skill List, the same as the Rogue Scholar''s two.
  - Money is the city Operator''s 4D4x1000 credits; the wandering Operator''s
    figure is different and is a GM call.
---

## Lore

Operators are mechanics, engineers and tinkerers who keep the machines of Rifts Earth running. They are as knowledgeable about modern high-tech engineering as any Coalition engineer, and their love of mechanics keeps them looking and learning. A loose fraternity across the Americas, similar to the Freemasons of old, with no leader, gathering place or doctrine - only a shared love of machines and forgotten science, and a habit of secrecy. An Operator tends to disguise the extent of his knowledge with false modesty and cryptic talk about the Time Before the Rifts.

Alignment: Any. Racial Requirements: none; at least 35% are D-Bees.

## GM Notes

None of the Operator''s special abilities apply to bionics or cybernetics, and there is a -20% skill penalty when working on robots and power armour unless the character also has Robot Mechanics and Robot Electronics.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'operator');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'operator';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-operator-class.sql');
