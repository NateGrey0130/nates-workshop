-- The Merc Soldier O.C.C., Rifts Ultimate Edition p.81-83.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-merc-soldier-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('flare', 'Flare', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('mdc-body-armor', 'Mdc Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('military-fatigues-and-dress-uniform', 'Military Fatigues And Dress Uniform', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'merc-soldier', 'Merc Soldier', 'rifts', '---
id: merc-soldier
name: Merc Soldier
system: rifts
source_book: Rifts Ultimate Edition p.81-83
category: occ
starting_money: "2d6x100"
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 95%." }
    - { choose: 1, categories: ["Communications"], bonus: 10, note: "Language: Other, one of choice (+10%)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "General Athletics." }
    - { name: "Basic Math", base: 50, per_level: 5, note: "+5%" }
    - { name: "Military Etiquette", base: 45, per_level: 5, note: "+10%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Sign Language", base: 30, per_level: 5, note: "Military; +5%." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "Includes Vibro-Knives." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin if evil) for the cost of two." }
  occ_related_skills:
    count: 4
    categories:
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Rogue"
      - { name: "Science", only: ["Advanced Math", "Astronomy"] }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    note: "Military: Any (+5%). Technical: Any (+5%). Science: Advanced Math (+5%) and Astronomy only. Pilot: basic vehicle types only - the average grunt does not know how to drive a tank. Communications, Espionage, Medical and Pilot Related offer none beyond possible MOS skills. Cowboy: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "military-fatigues-and-dress-uniform", qty: 1 }
  - { item_id: "mdc-body-armor", qty: 1 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "flare", qty: 3 }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
restrictions:
  - "MOS (Military Occupational Specialty): select or roll ONE specialty package in addition to O.C.C. and Related skills - see GM Notes. MOS skills are not modeled; add them by hand on the sheet."
extraction_notes: |
  - RUE p.81-83. Alignment any; no attribute requirements (certain MOS
    categories require minimums); no racial restrictions.
  - The MOS system (pick one of seven skill packages, or roll percentile) has
    no schema shape - a package choice is neither a skill choice-group nor a
    variant. The full seven packages are transcribed in GM Notes and the
    restriction above says to apply one by hand.
  - Equipment: one weapon and 1D4+3 E-Clips for each W.P. is prose the
    quantity field cannot carry. Money is 2D6x100 credits plus 1D4x1000 in
    Black Market items.
  - Cybernetics: none to start, may acquire over time.
---

## Lore

"We''re whatever you need, whenever and wherever you need us. So, if your town needs protecting or a monster to be exterminated, we''re on the job. But it will cost ya some creds. Dangerous work, man, and I don''t see you doin'' it or we wouldn''t be having this little conversation."

On Rifts Earth, being a professional soldier can be lucrative and rewarding. Although they fight for money, many Merc Soldiers are honorable and trustworthy, and see themselves as heroes and experts ready to lend a helping hand - for the right price or fair trade. Even Merc Soldiers of a good alignment tend to play fast and loose with the law, considering themselves citizens of the world and above local law; good, Unprincipled and Aberrant ones all have a line they will not cross.

## GM Notes

**MOS packages (select one, or roll percentile):**

- **01-15% Communications Expert:** +10% to Computer Operation, Basic Electronics (+10%), Electronic Countermeasures (+15%), Optic Systems or Surveillance Systems (+14%), Radio: Basic (+20%), Cryptography (+15%) or an extra Language (+15%).
- **16-25% EOD/Demolitions Expert** (requires I.Q. 10 and P.P. 12+): Basic Electronics (+20%), Basic Mechanics (+15%), Demolitions (+15%), Demolitions Disposal (+20%), Demolitions: Underwater (+10%), Trap/Mine Detection (+10%), W.P. Heavy Energy Weapons.
- **26-50% Soldier/Grunt:** Forced March, Land Navigation (+5%), Physical: one of choice, Pilot: one of choice (+10%, excluding Power Armor, Robots or Ships), W.P.: one Ancient of choice, W.P.: one Modern of choice.
- **51-65% Point Man/Scout** (requires I.Q. 9+): Detect Ambush (+15%), Detect Concealment (+10%), Intelligence (+15%), Land Navigation (+14%), Prowl (+10%), Surveillance Systems/Tailing (+15%), Wilderness Survival (+10%).
- **66-80% Pigman/Heavy Weapons** (requires P.S. 14 and P.E. 12+): Recognize Weapon Quality (+20%), Weapon Systems (+10%), W.P. Rifles, W.P. Heavy Military Weapons, W.P. Heavy Energy Weapons (including rail guns), W.P. two of choice or two Demolition skills (+5%).
- **81-90% Transportation Specialist:** Basic Mechanics (+10%) or Combat Driving (+5%), Navigation (+10%), Pilot: Automobile or Motorcycle (+20%), Pilot: Hover Craft (ground) or Hovercycle (+15%), Pilot: Tanks & APCs (+10%), Pilot: Trucks (+10%), Pilot: one of choice (+10%, excluding robots/power armor).
- **91-00% Medic** (requires I.Q. and P.P. 11+): Brewing (+5%), Biology (+15%), Field Surgery (+15%), Medical Doctor (+5%), Pathology (+10%) or Chemistry (+10%), Sewing (+10%).

Additional weapons, heavy weapons, explosives, gear and vehicles may be made available for specific assignments; the squad usually has one basic military vehicle. Related O.C.C.s: any Rifts sourcebook with "Mercenary" or "Merc" in the title.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'merc-soldier');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'merc-soldier';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('flare', 'mdc-body-armor', 'military-fatigues-and-dress-uniform');
