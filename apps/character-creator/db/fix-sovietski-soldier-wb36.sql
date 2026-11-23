-- The Sovietski Soldier, reconciled with Rifts World Book 36: Sovietski printed 101-106.
-- 1 class, each replaced whole: sovietski-soldier.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-sovietski-soldier-wb36.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- The Sovietski Soldier, reconciled with its revised block in Rifts World Book
-- 36: Sovietski printed 101-106 (the Infantry Soldier O.C.C.). The class shipped
-- from Rifts World Book 17: Warlords of Russia printed 212-214
-- (add-sovietski-soldier-class.sql, left as it is; this file sorts after it and
-- after fix-sovietski-soldier-cyborg-bodies.sql, whose restriction line it
-- rewrites to name the WB36 bodies). Ruling 2026-10-04: the newest printing that
-- states a figure wins, so WB36's block replaces WB17's wherever they differ:
-- race none, I.Q. 7 the only attribute requirement, +1 initiative, +1 save vs
-- Horror Factor at level 1 and at 3, 6, 9 and 12, Hand to Hand: Basic, the WB36
-- O.C.C. skills, fourteen M.O.S. bundles each with a Training ability in place of
-- the related skills, one secondary skill at levels 1, 3, 7, 9 and 12, the
-- cybernetics table and the WB36 kit. The Motivation/Origin table (printed 102)
-- rides in the GM notes. The XP ladder is the same in both books (printed 224).
-- The class keeps its id and its WB17 citation; the extraction notes record the
-- reconciliation item by item.

-- == sovietski-soldier ==
UPDATE imported_classes
   SET markdown = '---
id: sovietski-soldier
name: Sovietski Soldier
system: rifts
source_book: Rifts World Book 17: Warlords of Russia p.212-214
category: occ
tags: [combat]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]
attribute_requirements: { IQ: 7 }
hit_points_base: "P.E. + 1d6 per level"
bonuses:
  combat: { initiative: 1, pull_punch: 1, strike: 1, roll: 1 }
  saves: { horror_factor: 1 }
  pools: { sdc: "3d6+12" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1 } }
  occ_skills:
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "Printed Athletics (General)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Forced March", { name: "Swimming", bonus: 10 }], note: "Forced March or Swimming (+10%), pick one." }
    - { name: "Language: Russian", base: 60, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: one of choice (+15%)." }
    - { name: "Literacy: Russian", base: 50, per_level: 5, note: "Native language; +20%." }
    - { name: "Mathematics: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { choose: 1, from: ["Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes"], bonus: 10, note: "Pilot: Hovercraft (Ground) or Hovercycles, Skycycles and Rocket Bikes (+10%), pick one." }
    - { name: "Jet Packs", base: 54, per_level: 4, note: "+12%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert at the cost of one Secondary Skill. Martial Arts and Commando are not available." }
  mos:
    choose: 1
    note: "O.C.C. Related Skills: instead of the usual related skills, one M.O.S. skill bundle, and the Training ability of the same name, which carries its requirement and bonuses."
    options:
      - id: combat-animal-handler
        name: "Combat Animal Handler"
        skills:
          - { choose: 1, from: [{ name: "Breed Dogs", bonus: 15 }, { name: "Falconry", bonus: 10 }], note: "Breed Dogs (+15%) or Falconry (+10%), pick one." }
          - { name: "Horsemanship: Exotic Animals", base: 40, per_level: 5, note: "+10%; can be upgraded to Horsemanship: Cossack at the cost of one Secondary Skill." }
          - { name: "Outdoorsmanship", base: 0, per_level: 0 }
          - { name: "Track & Trap Animals", base: 35, per_level: 5, note: "+15%" }
          - { name: "Veterinary Science", base: 60, per_level: 4, note: "+10%" }
          - { name: "W.P. Net", base: 0, per_level: 0 }
          - { name: "W.P. Rope", base: 0, per_level: 0 }
      - id: combat-engineer
        name: "Combat Engineer"
        skills:
          - { name: "Demolitions", base: 70, per_level: 3, note: "+10%" }
          - { name: "Demolitions Disposal", base: 80, per_level: 3, note: "+20%" }
          - { name: "Excavation", base: 50, per_level: 5, note: "+10%" }
          - { name: "Military Fortification", base: 40, per_level: 5, note: "+10%" }
          - { choose: 1, from: ["Trap Construction", "Field Armorer & Munitions Expert"], bonus: 10, note: "Trap Construction or Field Armorer and Munitions (+10%), pick one." }
          - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "Printed Trap and Mine Detection, +10%." }
      - id: communications-specialist
        name: "Communications Specialist"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
          - { choose: 1, categories: ["Communications"], bonus: 10, note: "Communication: one skill of choice (+10%)." }
          - { name: "Electronic Countermeasures", base: 45, per_level: 5, note: "+15%" }
          - { name: "Laser Communications", base: 50, per_level: 5, note: "+20%" }
          - { choose: 1, from: ["T.V./Video", "Surveillance"], bonus: 15, note: "T.V./Video or Surveillance (+15%), pick one." }
          - { choose: 1, categories: ["Communications", { name: "Technical", only: ["Computer Operation", "Computer Programming"] }], note: "And one Communications or Computer skill of choice." }
      - id: eod-demolitions-specialist
        name: "EOD/Demolitions Specialist"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
          - { name: "Demolitions", base: 80, per_level: 3, note: "+20%" }
          - { name: "Demolitions Disposal", base: 75, per_level: 3, note: "+15%" }
          - { name: "Demolitions: Underwater", base: 70, per_level: 4, note: "+14%" }
          - { name: "Field Armorer & Munitions Expert", base: 50, per_level: 5, note: "Munitions Expert: the munitions part only of Field Armorer and Munitions Expert, +10%." }
          - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "Printed Trap and Mine Detection, +10%." }
      - id: field-medic
        name: "Field Medic"
        skills:
          - { name: "Brewing: Medicinal", base: 30, per_level: 5, note: "+5%" }
          - { name: "Cybernetic Medicine", base: 40, per_level: 5 }
          - { name: "Field Surgery", base: 30, per_level: 4, note: "+14%" }
          - { name: "Medical Doctor", base: 65, per_level: 5, note: "+5%" }
          - { name: "Pathology", base: 50, per_level: 5, note: "+10%" }
          - { choose: 1, from: ["Chemistry", "Xenology"], bonus: 5, note: "Chemistry or Xenology (+5%), pick one." }
      - id: infantryman-motorized-rifleman
        name: "Infantryman/Motorized Rifleman"
        skills:
          - { name: "First Aid", base: 50, per_level: 5, note: "+5%" }
          - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
          - { choose: 1, categories: [{ name: "Physical", except: ["Acrobatics", "Gymnastics"] }], note: "Physical: one of choice, except Acrobatics or Gymnastics." }
          - { choose: 1, categories: [{ name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Flight System Combat"] }], bonus: 10, note: "Pilot: one of choice, any except Robots and Power Armor (+10%)." }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one additional Modern W.P. of choice (any)." }
      - id: marksman
        name: "Marksman"
        skills:
          - { name: "Camouflage", base: 30, per_level: 5, note: "+10%" }
          - { name: "Detect Concealment", base: 35, per_level: 5, note: "+10%" }
          - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
          - { name: "Sniper", base: 0, per_level: 0, note: "Marksmen are usually issued an SVD Dragunov." }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one additional Modern W.P. of choice (any)." }
      - id: pig-man-heavy-weapons-specialist
        name: "Pig Man/Heavy Weapons Specialist"
        skills:
          - { name: "Recognize Weapon Quality", base: 40, per_level: 5, note: "+15%" }
          - { name: "Sensory Equipment", base: 35, per_level: 5, note: "Printed Sensory Systems, +5%." }
          - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0 }
          - { name: "W.P. Heavy Military Weapons", base: 0, per_level: 0 }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one Modern W.P. of choice (any)." }
          - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
      - id: point-man-scout
        name: "Point Man/Scout"
        skills:
          - { name: "Detect Ambush", base: 45, per_level: 5, note: "+15%" }
          - { name: "Detect Concealment", base: 40, per_level: 5, note: "+15%" }
          - { name: "Land Navigation", base: 50, per_level: 4, note: "+14%" }
          - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
          - { name: "Tailing", base: 45, per_level: 5, note: "+15%" }
      - id: propagandist-zampolit
        name: "Propagandist (Zampolit)"
        skills:
          - { name: "Cryptography", base: 35, per_level: 5, note: "+10%" }
          - { choose: 1, from: ["History: Pre-Rifts", "History: Post-Apocalypse"], bonus: 5, note: "History: Pre-Rifts or Post Apocalypse, Russia and the Soviet Union only (+5%), pick one." }
          - { name: "Law", base: 45, per_level: 5, note: "Printed Law (General), +10%." }
          - { choose: 1, from: [{ name: "Law: Loopholes", bonus: 8 }, "Kremlinology"], note: "Law - Loopholes (+8%) or Kremlinology, pick one." }
          - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
          - { choose: 1, from: [{ name: "Lore: Magic", bonus: 10 }, { name: "Public Speaking", bonus: 15 }], note: "Lore: Magic (+10%) or Public Speaking (+15%), pick one." }
      - id: sailor-naval-infantryman
        name: "Sailor/Naval Infantryman"
        skills:
          - { name: "Navigation", base: 50, per_level: 5, note: "+10%" }
          - { name: "Boat: Motor, Race & Hydrofoil", base: 70, per_level: 5, note: "+15%" }
          - { name: "Boat: Ships", base: 50, per_level: 5, note: "+5%" }
          - { name: "SCUBA", base: 65, per_level: 5, note: "+15%" }
          - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
      - id: soviet-air-corps-army-aviator
        name: "Soviet Air Corps/Army Aviator"
        skills:
          - { name: "Basic Mechanics", base: 35, per_level: 5, note: "+5%" }
          - { name: "Navigation", base: 50, per_level: 5, note: "+10%" }
          - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed Pilot: Hover Vehicles (+10%); the training includes ekranoplan transports." }
          - { name: "Jet Aircraft", base: 55, per_level: 4, note: "+15%" }
          - { name: "Military: Jet Fighters", base: 50, per_level: 4, note: "Printed Pilot: Jet Fighter, +10%." }
          - { name: "Flight System Combat", base: 50, per_level: 5, note: "Printed Russian Flight System Combat, +10%." }
      - id: strategic-rocket-force
        name: "Strategic Rocket Force (Ballistic Missiles)"
        skills:
          - { name: "Navigation", base: 50, per_level: 5, note: "+10%" }
          - { name: "NBC Warfare", base: 45, per_level: 5, note: "+10%" }
          - { name: "Military: Tanks & APCs", base: 51, per_level: 4, note: "+15%; the training includes the Red Hammer Ballistic Missile Carrier." }
          - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
          - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0 }
      - id: transportation-specialist
        name: "Transportation Specialist"
        skills:
          - { name: "Combat Driving", base: 0, per_level: 0 }
          - { choose: 1, from: ["Automobile", "Motorcycles & Snowmobiles"], bonus: 15, note: "Pilot: Automobile or Motorcycles and Snowmobiles (+15%), pick one." }
          - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed Pilot: Hover Vehicles (+10%); the training includes ekranoplan transports." }
          - { name: "Military: Tanks & APCs", base: 46, per_level: 4, note: "+10%; normally used for APCs, since tankers are a select group (see the Sovietski Tanker)." }
          - { name: "Truck", base: 50, per_level: 4, note: "+10%" }
  occ_related_skills:
    count: 0
    note: "None: the M.O.S. skill bundle takes the place of O.C.C. Related Skills."
  secondary_skills:
    count: 1
    note: "One Secondary Skill (Rifts Ultimate Edition list, printed 300) at each of levels 1, 3, 7, 9 and 12, at base percentage only."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
special_abilities:
  - name: "Training: Combat Animal Handler"
    description: "Requires M.A. 10 or higher. +2 on Perception Rolls about animals: their health, mood and whether they will attack, submit or flee (not added to the sheet). Extra implants: the Neural Aggression Modulator Control (sovietski-neural-aggression-modulator-control) and one more optic or radio/jaw implant; the GM may assign the soldier one cyborg falcon, dog or bear (sovietski-cyborg-falcon-or-hawk is the falcon)."
  - name: "Training: Combat Engineer"
    description: "Requires I.Q. 11 or higher. +2D6 S.D.C. and +1 I.Q. Extra bionics: Schematic Sensor Hand, Tool Hand, Tool Mechanic''s Arm and the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing)."
    bonuses: { attributes: { IQ: 1 }, pools: { sdc: "2d6" } }
  - name: "Training: Communications Specialist"
    description: "Requires I.Q. 10 or higher. +1D6 S.D.C., +1 on Perception Rolls (not added to the sheet), and Radio: Basic takes +30% in place of the O.C.C. Skills bonus (not raised on the sheet). Extra implant: one more communication enhancement, such as a Finger Jack, Video Eye or Radio Transmitter."
    bonuses: { pools: { sdc: "1d6" } }
  - name: "Training: EOD/Demolitions Specialist"
    description: "Requires I.Q. 10 and P.P. 12 or higher. +1D6 S.D.C., +1 M.E. and P.P., +1 roll with impact, and +2 on Perception Rolls about explosives and traps: how complex, how dangerous, how far the blast reaches and how skilled their maker was (not added to the sheet). Extra bionics: Schematic Sensor Hand, Radiation Sensor and Macro-Eye Laser."
    bonuses: { attributes: { ME: 1, PP: 1 }, combat: { roll: 1 }, pools: { sdc: "1d6" } }
  - name: "Training: Field Medic"
    description: "Requires I.Q. and P.P. 10 or higher. +1 I.Q. and +2 on Perception Rolls about how bad an injury is, the best immediate treatment and how stable the patient is (not added to the sheet). From level 4 his treatment gives a patient in a coma or dying +5% to save vs coma and death, +10% from level 8. Extra bionics: Macro-Eye Laser, Molecular Analyzer, Finger Laser Scalpel and Wrist/Palm Needle."
    bonuses: { attributes: { IQ: 1 } }
  - name: "Training: Infantryman/Motorized Rifleman"
    description: "No requirements. +2D6 S.D.C. and +1 on Perception Rolls to find protective cover (not added to the sheet). No extra bionics at first; serious injuries may be repaired with cybernetics or bionics."
    bonuses: { pools: { sdc: "2d6" } }
  - name: "Training: Marksman"
    description: "Requires P.P. 12 or higher. +1 M.E., +2 to strike on Called Shots and +2 on Perception Rolls judging distance, wind, the difficulty of a shot and finding a target (both conditional, not added to the sheet). Extra bionics: Multi-Optic Eye and Motion Detector."
    bonuses: { attributes: { ME: 1 } }
  - name: "Training: Pig Man/Heavy Weapons Specialist"
    description: "Requires P.S. 14 and P.E. 12 or higher. +2D6 S.D.C., +1 P.S., and +1 to strike with rifles, machine-guns, rail guns and similar long-range modern weapons (conditional, not added to the sheet). Extra bionics: Sound Filtration System and Shoulder Weapon Mount/Clamps."
    bonuses: { attributes: { PS: 1 }, pools: { sdc: "2d6" } }
  - name: "Training: Point Man/Scout"
    description: "Requires I.Q. 9 or higher. +2D4 S.D.C., +1 P.E., and +2 on Perception Rolls about terrain, ground suited to ambush or traps, and spotting ambushes, camouflage or traps (not added to the sheet). Extra implants: Clock Calendar, Gyro-Compass, Directional Sound Amplification Finger, Sound Amplification Ear implant, and one Multi-Optic Eye or Wide-Angle Vision."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: "2d4" } }
  - name: "Training: Propagandist (Zampolit)"
    description: "Requires I.Q. 12 and M.A. 11 or higher. +10% to Charm/Impress and +10% to Trust/Intimidate whatever the M.A. (not added to the sheet). Extra implants: one more communication enhancement, such as a Video Eye or Radio Transmitter, and two Hidden Storage Compartments."
  - name: "Training: Sailor/Naval Infantryman"
    description: "Requires P.E. 10 or higher. +1D6 S.D.C. and +5% to Swimming (not raised on the sheet). Extra implants: one lung implant of choice (usually the Oxygen Storage Cell) and a Depth Gauge."
    bonuses: { pools: { sdc: "1d6" } }
  - name: "Training: Soviet Air Corps/Army Aviator"
    description: "Requires I.Q. 10 and P.P. 12 or higher. +1 to dodge in flight and +5% to evasive maneuvers, stunts and emergency landings (conditional, not added to the sheet). Extra bionics: a bionic hand or forearm with the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing), Radar Sensor, Gyro-Compass and Speedometer."
  - name: "Training: Strategic Rocket Force"
    description: "Requires M.E. 12 or higher. +1 to strike with missiles fired from a vehicle and +1 to strike an incoming missile in flight (conditional, not added to the sheet). Extra implants: the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing), Radar Sensor and Gyro-Compass."
  - name: "Training: Transportation Specialist"
    description: "Requires P.E. and P.P. 9 or higher. +1 to dodge while driving and +5% to evasive maneuvers, stunts, rams and emergency crashes (conditional, not added to the sheet). Extra bionics: a bionic hand or forearm with the Cyberlink Vehicle Interface (cyberlink-vehicle-interfacing), Gyro-Compass and Speedometer."
  - { choose: 1, from: ["Training: Combat Animal Handler", "Training: Combat Engineer", "Training: Communications Specialist", "Training: EOD/Demolitions Specialist", "Training: Field Medic", "Training: Infantryman/Motorized Rifleman", "Training: Marksman", "Training: Pig Man/Heavy Weapons Specialist", "Training: Point Man/Scout", "Training: Propagandist (Zampolit)", "Training: Sailor/Naval Infantryman", "Training: Soviet Air Corps/Army Aviator", "Training: Strategic Rocket Force", "Training: Transportation Specialist"], note: "Pick the Training that matches the M.O.S. chosen with the skills." }
  - name: "Cybernetic and Bionic Enhancement"
    description: "Roll percentile or pick. 01-50: human, no bionics, 1D4 cybernetic implants of choice (clock calendar and the like). 51-85: partial cyborg, 55-80% of the body: one headjack and one finger jack, the Cyberlink Vehicle Interface, two sensor or communication implants of choice, reinforced endo-skeleton and body frame (20 M.D.C.), full leg conversion (Spd 45, 30 mph; leaps 10 ft high or 12 ft long from a standstill, double with a short run; 60 M.D.C. per leg, 18 per foot), one bionic arm (40 M.D.C.) and hand (12 M.D.C.) with one forearm and one hand weapon, P.S. and P.P. 18 in that arm, and a gas filtration system and oxygen storage cell. 86-00: full conversion cyborg, the military grade Proletarian Light Machine (sovietski-proletariat-light-machine, printed 128). A soldier with 55% or more conversion usually serves for life or 30-50 years."
equipment_starting:
  - { item_id: "sovietski-sa-107h-red-star-infantry-armor", qty: 1, note: "Standard Red Star body armor." }
  - { item_id: "e-clip", qty: 6, note: "Six E-Clips for each weapon; these six are the energy rifle''s." }
  - { choose: 1, label: "Vibro-Knife or Vibro-Sword", qty: 1, from: ["vibro-knife", "vibro-sword"] }
  - { item_id: "signal-flare", qty: 2 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "sovietski-fragmentation-grenade", qty: 2 }
  - { item_id: "knife-silver-plated", qty: 1, note: "Silver-plated survival knife, 2D4 S.D.C." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1, note: "The book says distancing binoculars." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "gun-holster", qty: 1, note: "Holster for the side arm." }
  - { item_id: "air-filter", qty: 1, note: "An additional air filter." }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "uniform", qty: 4, note: "Four standard uniforms." }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1, note: "Pocket-sized silver cross." }
  - { item_id: "signal-mirror", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
trackable_resources: []
restrictions:
  - "CYBORG BODIES ARE VESSEL ROWS. A soldier rolled as a full conversion cyborg is the military grade Proletarian Light Machine, sovietski-proletariat-light-machine (WB36 printed 128). The WB17 bodies, sovietski-light-machine-cyborg (printed 214) and sovietski-heavy-machine-cyborg (printed 215, which sends the reader to the Sovietski Soldier for skills and training), and the three Shocktrooper-class bodies, thunderhammer-cyborg-shocktrooper, thunderstrike-cyborg-shocktrooper and thunderstorm-artillery-cyborg, are vessel rows as well; their entries print no O.C.C. or skill list."
  - "Alignment: any."
  - "Attribute requirements: I.Q. 7 or higher; higher I.Q., P.S. or P.E. scores help but are not required. Each M.O.S. has its own requirement, in its Training; cybernetics and bionics can often overcome a physical one."
  - "Race: none, though most soldiers are humans or this book''s human-looking D-Bees."
  - "Equipment beyond the starting list: Military I.D. and ration card, one weapon per W.P. with six E-Clips each, water purification tablets and anti-radiation pills."
  - "Money: room, board, clothing, medical care and the other basics are free as part of the pay; starts as a Private on 1,100 credits a month. No starting sum is printed."
extraction_notes: "WB17 Warlords of Russia printed 212-214 (cache p213-p215, cache page = printed folio + 1), read off the text layer; RECONCILED against the revised block in Rifts World Book 36: Sovietski printed 101-106 (Infantry Soldier, Revised and Expanded; cache p101-p106, cache page = printed folio + 0), whose figures replace WB17''s wherever they differ (ruling 2026-10-04: the newest printing that states a figure wins). The class keeps its id and its WB17 citation; the WB36 block is read as superseding the WB17 stat block whole, so what WB36 drops is dropped. || HEADING: WB36 heads it Infantry Soldier and the stats Sovietski Infantry Soldier O.C.C. Stats (printed 103); occ_group men-of-arms and men_of_arms true kept. || XP: WB36''s Experience Tables (printed 224, cache p220) print one ladder for Sovietski Police Officer, Gridgitz and Infantry Soldier, identical to the WB17 ladder stored. || CHANGED FROM WB17: race none (was exclusively human); I.Q. 7 is the one requirement (P.S. 10 and P.E. 10 gone). Bonuses now +1 initiative (was +2), +1 pull punch, +1 strike, +1 roll with impact; the +1 parry and dodge are gone; the Horror Factor save is +1 at levels 1, 3, 6, 9 and 12 (was +2); +3D6+12 S.D.C. unchanged. Skills: Athletics (General), Climbing, Forced March or Swimming, Language: Russian +10% (was a native 98%), one other language +15%, Literacy: Russian +20% as the native language (was 62% +2 per level), Basic Math +5%, Military Etiquette +15%, Hovercraft (Ground) or Hovercycles (+10%), Jet Packs +12%, Radio: Basic +10% (was +15%), W.P. Energy Rifle and W.P. Knife. Gone: Running, Wilderness Survival, Tracked Vehicles, the free Pilot pick, the W.P. Knife or Sword pick, Trick Shooting and the free W.P. Hand to Hand: Basic, Expert for one Secondary Skill (was Expert, with Martial Arts or Assassin for a related skill). The three free MOS picks and the three related skills (plus 4, 7, 10, 13) are replaced by fourteen M.O.S. skill bundles, stored as skills.mos options, with their requirements and M.O.S. Bonuses as a parallel pick-one Training group. Secondary: one at levels 1, 3, 7, 9 and 12 (was two at 2, 4, 8 and 12). Equipment: Red Star armor is the WB36 SA-107H row (was the WB17 medium row); two fragmentation grenades (was 1D4), the Sovietski row; gun holster, air filter, gas mask, walkie-talkie, canteen, uniforms and bedroll added; the portable language translator is gone (now issued on assignment). || HAND TO HAND: the price is one Secondary Skill, stored as costs expert 1; Martial Arts and Commando are not offered. || M.O.S.: the bundles are the fourteen printed 103-106. The Point Man''s Land Navigation +14% and the Field Medic''s Field Surgery +14% read oddly and were checked against the render. Sensory Systems is the catalog''s Sensory Equipment; Pilot: Hover Vehicles is Hover Craft (ground); Pilot: Jet Fighter is Military: Jet Fighters; Russian Flight System Combat is Flight System Combat; Munitions Expert is Field Armorer & Munitions Expert, munitions half only, in the note; Trap and Mine Detection is Trap/Mine Detection. Skill-percentage bonuses in the M.O.S. Bonuses (Radio +30%, Swimming +5%) and conditional bonuses are prose in the Training descriptions; attribute, S.D.C. and roll bonuses are on the Training. Extra cybernetics per M.O.S. are prose; the Neural Aggression Modulator Control, the cyborg falcon and the Cyberlink Vehicle Interface are named by their rows. || BIONICS TABLE: the 01-50 / 51-85 / 86-00 table is a special ability in prose; the full conversion result is the vessel row named in restrictions. || MOTIVATION: the optional Motivation/Origins table (printed 102-103) is summarised in GM Notes, not modelled. || MONEY: a salary only, so no starting_money. || EQUIPMENT not stored as rows: the weapon per W.P., the I.D. and ration card, water purification tablets and anti-radiation pills."
---

## Lore

The infantry soldier is the lowest rung of the Sovietski Red Army. Every citizen, human or D-Bee, owes at least two years of service; six to
twelve is usual, and some, including most Wolverine People and many Gridgitz
and Cold Born, make the army a career. Basic training teaches combat, military
etiquette and survival, and then each recruit takes a military occupational
specialty, sometimes to follow a parent into the same unit, sometimes to stay
alive, sometimes wherever the officers decide.

Nearly every soldier is fitted with implants or bionics after basic training,
issued like a uniform, and many specialties demand a particular augmentation.
The army will pay for a full or partial conversion in return for at least six
more years on the front line, which suits recruits born with a defect or a
chronic illness. Soldiers carry silver and a cross alongside their energy
weapons against the monsters of Russia.

## GM Notes

M.O.S.: pick one bundle with the skills and the Training of the same name. The
Training carries the bundle''s attribute requirement, its bonuses and the extra
implants it issues.

Motivation and origins (optional): a recruit may have a reason beyond the
two-year draft. A born fighter or a recruit with special abilities (Yaganar,
Wolverine People, Cold Born, Bursters or any other psychic) serves 12-30 years,
gains +1 initiative and one extra W.P. of choice. A foreign volunteer from
Tarnow, Poznan, the NGR, China or elsewhere serves 6-12 years, speaks one
more language at 98% as a native tongue and takes -10% on Language: Russian.
A huntsman raised in the wilderness gains two Wilderness skills of choice and
-10% on Military Etiquette, serving 4-16 years. A soldier driven by justice
after losing home or family to Warlords, bandits, raiders or monsters gains +1
on Perception Rolls about the object of his revenge and about treachery, and
may struggle to trust. A legacy soldier from a military or Party family gains
+10% Military Etiquette, the Contacts skill with 2D6 military or 2D4 Party
contacts, and +10% Charm/Impress and Trust/Intimidate among soldiers (or one
of the two at a flat 50% in military company if his M.A. or P.B. is too low).
A paroled criminal gains one Rogue skill of choice (+10%) and Law: Loopholes
(+10%), serves 8-12 years and can never reach high rank. A patriot serves
12-30 years and gets +5% to all M.O.S. skills on active duty. None of these is
on the sheet.

On assignment: any vehicle the soldier is trained for, more weapons and
E-Clips, a medical kit, a tool kit, a portable computer and language
translator, cameras, surveillance gear, explosives (fusion blocks included),
and low to mid-level military clearance, all subject to the commander,
supply, location, casualties and combat conditions.

Many soldiers choose sensory or weapon implants; the Gromeko Friend or Foe
Identification Computer (gromeko-friend-or-foe-identification-computer) is the
favourite.

The save vs Horror Factor rises by +1 at levels 3, 6, 9 and 12.
',
       updated_at = datetime('now')
 WHERE class_id = 'sovietski-soldier'
   AND instr(markdown, 'race_restrictions: { only: ["none"], note: "Exclusively human." }') > 0
   AND length(markdown) = 14717;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'sovietski-soldier' AND instr(markdown, 'Training: Combat Animal Handler') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'sovietski-soldier' AND instr(markdown, 'race_restrictions: { only: ["none"], note: "Exclusively human." }') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('sovietski-soldier') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-sovietski-soldier-wb36.sql');
