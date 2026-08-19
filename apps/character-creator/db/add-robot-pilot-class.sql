-- The Robot Pilot O.C.C., Rifts Ultimate Edition p.83-85.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-robot-pilot-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('combat-boots', 'Combat Boots', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('explosive-grenade', 'Explosive Grenade', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('first-aid-kit', 'First Aid Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('flare', 'Flare', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('heavy-mdc-body-armor', 'Heavy Mdc Body Armor', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-computer', 'Pocket Computer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('uniform', 'Uniform', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'robot-pilot', 'Robot Pilot', 'rifts', '---
id: robot-pilot
name: Robot Pilot
system: rifts
source_book: Rifts Ultimate Edition p.83-85
category: occ
attribute_requirements: { PS: 10, PP: 12, PE: 12 }
starting_money: "1d6x100"
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 94%." }
    - { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }
    - { name: "Basic Math", base: 65, per_level: 5, note: "+20%" }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Combat Driving", base: 0, per_level: 0, note: "Pilot: Combat Driving (+15% where applicable)." }
    - { choose: 1, categories: ["Pilot"], bonus: 15, note: "Pilot: one of choice, any (+15%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Read Sensory Equipment", base: 45, per_level: 5, note: "Sensory Equipment (+15%)." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: one of choice, and W.P. Modern: one of choice." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts at the cost of one O.C.C. Related Skill, or Commando (or Assassin if evil) for the cost of two." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Detect Concealment", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Aircraft Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", except: ["Naval History", "Naval Tactics"] }
      - "Physical"
      - { name: "Pilot", except: ["Boat: Ships"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Cardsharp", "Seduction"] }
      - { name: "Science", only: ["Basic Math", "Advanced Math", "Astronomy & Navigation"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Any (+10%). Mechanical +5%. Medical: First Aid (+5%) only. Military: Any (+10%) except Naval History and Naval Tactics. Pilot: Any (+10%) except Ships and Warships. Pilot Related: Any (+10%). Science: Math (+10%) and Astronomy & Navigation (+15%) only. Technical: Any (+5%). Wilderness: Any. Cowboy and Horsemanship: none."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "heavy-mdc-body-armor", qty: 1 }
  - { choose: 1, label: "sidearm", qty: 1, from: ["automatic-pistol", "energy-pistol"] }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword"] }
  - { item_id: "explosive-grenade", qty: 2 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "flare", qty: 4 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "pocket-computer", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "MOS: pick ONE specialty - Power Armor Pilot or Robot Pilot - in addition to O.C.C. skills; the packages (and the power armor or robot the character starts with) are in GM Notes and applied by hand."
extraction_notes: |
  - RUE p.83-85. Approximately 60% male, 40% female.
  - The two MOS packages are a package choice the schema cannot express (see
    the Merc Soldier); transcribed in GM Notes.
  - Equipment: one weapon per W.P., 1D4+2 extra E-Clips each, choice of handgun
    or energy pistol side arm - dice quantities and per-W.P. multipliers stay
    prose. Money is 1D6x100 credits + 1D6x1000 in Black Market items.
  - Cybernetics: typically starts with a Gyro Compass and a Clock Calendar
    implant.
---

## Lore

"We''re the backbone of the army - first in, last out, always there for the team. And we enjoy the ride while we''re at it."

The Robot Pilot is a heavy weapons expert who specializes in operating Power Armor or Giant Robots (pick one) and armored combat vehicles. Most have nerves of steel, remain calm under fire, and are master puppeteers controlling high-tech exoskeletons or giant robots and tanks. They see themselves as the cornerstone and muscle that supports and protects vulnerable infantry and civilians, often sacrificing their robot or armor to hold an advancing enemy at bay. In and out of their armor, Robot Pilots are highly competitive and hate to lose.

## GM Notes

**Power Armor Pilot MOS:** Advanced Math (+15%), Basic Mechanics (+15%) or Acrobatics, Navigation (+15%), Pilot: Robots & Power Armor (basic; +20%), Pilot: Robot Combat Basic (general knowledge), Pilot: Robot Combat Elite (select two power armor types to start, +1 at levels 3, 6, 9 and 12), Pilot: Jet Fighter or Combat Helicopter (+15%), Pilot: one skill of choice (+12%). **Power Armor to Start:** an NG-Samson and one other power armor of choice (any open-market North American model, air or ground). Note: CS power armor is unavailable unless the soldier deserted the Coalition military; only a Free Quebec deserter has Glitter Boy armor. Power Armor Pilots suffer -1 attack, -1 strike, -3 dodge and roll when using a Glitter Boy.

**Robot Pilot MOS:** Land Navigation (+12%), Pilot: Robots & Power Armor (basic; +10%), Pilot: Robot Combat Basic (general knowledge), Pilot: Robot Combat Elite (select two giant robot types to start, +1 at levels 3, 6, 9 and 12), Pilot: Tanks & APCs, Pilot: Construction & Tracked Vehicles (+20%), Weapon Systems (+15%), W.P. Heavy Energy Weapons (rail guns included). **Robot to Start:** any one giant robot sold on the open market common to North America.

Also has a conventional mode of transportation (commercial hovercycle, hover vehicle, car, etc.).
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'robot-pilot');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'robot-pilot';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('combat-boots', 'explosive-grenade', 'first-aid-kit', 'flare', 'heavy-mdc-body-armor', 'pocket-computer', 'uniform');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-robot-pilot-class.sql');
