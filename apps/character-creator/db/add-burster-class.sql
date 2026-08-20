-- The Burster O.C.C., Rifts Ultimate Edition p.139-142.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-burster-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('sleeping-bag-rifts', 'Sleeping Bag Rifts', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'burster', 'Burster', 'rifts', '---
id: burster
name: Burster
system: rifts
source_book: Rifts Ultimate Edition p.139-142
category: occ
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "2d6"
starting_money: "4d6x100"
psionics:
  type: "master"
  isp_base: "3d4x10, +10 per additional level of experience"
  powers_starting: 3
  # The book names the exact list these three come from - the wizard narrows
  # the picker to it rather than to a category (see powers_from).
  powers_from: ["Bio-Regenerate (self)", "Deaden Pain", "Deaden Senses", "Death Trance", "Empathy", "Levitation", "Mind Block", "Resist Fatigue", "Resist Hunger", "Resist Thirst", "See Aura", "Sense Time", "Suppress Fear", "Telekinesis", "Telepathy", "Psychic Body Field", "Radiate Horror Factor"]
bonuses:
  combat: { initiative: 2, strike: 1, pull_punch: 2, roll: 2 }
  saves: { horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 98%." }
    - { choose: 1, categories: ["Communications"], bonus: 30, note: "Language: Other, one of choice (+30%)." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "Athletics (General)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Basic Math", base: 60, per_level: 5, note: "Math: Basic (+15%)." }
    - { choose: 2, categories: ["Pilot"], bonus: 10, note: "Pilot: two of choice (+10%); any except Military Vehicles." }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: two of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern: one of choice (any except Heavy Weapons)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Animal Husbandry", "Brewing"] }
      - { name: "Physical", except: ["Acrobatics", "Wrestling"] }
      - { name: "Pilot", except: ["Robots and Power Armor", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Tanks and APCs"] }
      - "Pilot Related"
      - { name: "Rogue", except: ["Seduction"] }
      - { name: "Science", only: ["Basic Math", "Advanced Math"] }
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy", "W.P. Heavy Energy Weapons", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons"] }
      - "Wilderness"
    note: "Communications: Any (+10%). Domestic: Any (+10%). Piloting: Any (+10%) except robots, power armor or military. Pilot Related: Any (+5%). Technical: Any (+10%). Cowboy, Espionage and Military: none."
    schedule:
      - { level: 4, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
natural_abilities:
  - name: "Impervious to Fire and Heat"
    description: "A psionic aura makes the Burster and what he wears completely impervious to fire and heat - Mega-Damage plasma, napalm, dragon fire breath and magic fires do nothing but minor cosmetic damage. He can hold hot coals, eat fire and stand in flames without discomfort. Also unaffected by smoke: breathes unimpaired, vision only slightly obscured (half distance, -1 strike/parry/dodge where others suffer -10 and choke). The aura halves Mega-Damage electrical attacks (S.D.C. electricity just tingles) and the character never sweats."
  - name: "Extinguish Fires"
    description: "Instantly puts out flames without chemicals or water. Range: 100 feet (30.5 m) +10 feet (3 m) per level. Radius of Effect: 200 foot (61 m) radius per level - the Burster can go for the maximum or narrowly focus on a small area. Duration: Permanent until the fire is reignited. I.S.P. Cost: 4."
  - name: "Flame Burst (Self)"
    description: "Engulfs himself in a fiery aura - nothing on his person actually burns and he moves without difficulty, but the fire ignites anything he touches. Range: Self. Duration: Two minutes per level. S.D.C. Damage: 6D6 per strike to anyone or anything he touches, accumulative, plus combustibles catch fire for an additional 6D6 per melee round. Mega-Damage: 1D6 M.D. (2D6 at a ley line, 3D6 at a nexus) with intense concentration, addable to punches, kicks or a touch, at an additional cost of 8 I.S.P.; lasts one melee round per level and each M.D. attack counts as two melee actions. I.S.P. Cost: 4."
  - name: "Flame Burst Body Protection (Special)"
    description: "The Flame Burst aura also provides 30 M.D.C. +6 per level of protection, renewing at 3D6 M.D.C. per melee round (never above the normal maximum). No extra I.S.P. cost - it comes with the Flame Burst."
  - name: "Fire Bolt"
    description: "A fiery energy bolt hurled or fired from the forehead or hands. Range: 200 feet (61 m) +20 feet (6 m) per level. Duration: Instant; counts as one melee attack. Bonus to Strike: +4, line of sight. Damage: mini-bolt 2D6 S.D.C./Hit Points, medium 4D6 S.D.C., heavy 6D6 S.D.C., or a Mega-Damage plasma bolt at 2D6 M.D. I.S.P. Cost: 2 regardless of size for an S.D.C. blast, 4 to create an M.D. blast."
  - name: "Fire Eruption"
    description: "Causes a fire to erupt in front of somebody or in an area instantly and without combustible material (never directly on a living creature). Range: 100 feet (30 m) +20 feet (6 m) per level. Base Skill: 48% +4% per level to place it exactly (a failed roll lands it 2D6 yards off target); -25% against a target he cannot see smaller than 20 feet across. S.D.C. Damage: tiny flame 1D4, a 1-2 yard fire 4D6, a towering pillar or wall 1D4x10, filling a room or 20 square foot area 2D4x10 per melee round. Mega-Damage: double the I.S.P. for larger fires - an M.D. fire wall or pillar does 2D6 M.D., a 20 foot area 4D6 M.D., 40 feet or bigger 6D6 M.D. per melee round; combustibles burn hotter and spread four times faster. Maximum Size: 20 foot area +5 feet per level. Duration: 10 minutes, or maintained for 1 I.S.P. every 10 minutes while concentrating (melee actions halved, fighting impossible). I.S.P. Cost: 10 for S.D.C. fires regardless of size, 20 for a Mega-Damage fire."
  - name: "Sense Fire"
    description: "Senses a fire as small as a burning candle after 15 seconds of concentration: approximate size, distance, direction and whether it is contained, spreading or raging, natural or man-made or magical, and how long it has burned. Can also object-read burnt objects or ashes. Recognizes Fire Elementals and fire-based supernatural creatures (but not Fire Dragons or other Bursters unless burst into flames). Range: 800 foot (244 m) radius +100 feet (30.5 m) per level. Duration: impressions last four minutes. I.S.P. Cost: 2."
  - name: "Super Fuel Flame"
    description: "Feeds a fire with psychic energy, increasing its size from twofold to as much as 10 times. Range: 100 feet (30.5 m) per level. Area Effect: 20 foot (6 m) area per level. Damage: increased proportional to the size of the fire, G.M. discretion. I.S.P. Cost: 8."
  - name: "Minor Psionic Powers"
    description: "Select THREE minor psionic powers from the class list at level one, and one additional at levels 3, 6, 9 and 12. Psychic Body Field (Super, 30 I.S.P.) and Radiate Horror Factor (Super, 8 I.S.P.) each count as TWO selections."
  - name: "I.S.P. and Recovery"
    description: "I.S.P. Base: 3D4x10 plus the M.E. attribute, +10 per additional level. Considered a Master Psychic (needs a 10 or higher to save vs psionic attack). Recovery: 2 I.S.P. per hour of activity, 12 per hour of meditation or sleep."
  - name: "The Influence of Ley Line Energy"
    description: "Duration and range of the Burster''s pyrokinetic and other psychic powers increase by 50% whenever on or near (within one mile/1.6 km) a ley line. Duration, range AND damage are DOUBLED at or near a ley line nexus point."
restrictions:
  - "Race Restrictions: most common among humans (87%), Elves (5%), Ogres (5%) and 3% others, typically human-like races. Both males and females can become Bursters."
  - "O.C.C. bonuses beyond the modeled ones: +1 on Perception Rolls, and loves hot, spicy foods - can eat them without any adverse effect."
  - "Cybernetics: starts with none; tends to avoid implants in favor of natural powers."
extraction_notes: |
  - RUE p.139-142. Alignment any, but tends to strong good (Principled,
    Scrupulous) or very evil (Miscreant, Diabolic). No attribute requirements;
    a high M.E. and at least I.Q. 8 are suggested.
  - The pyrokinetic powers are EXCLUSIVE to the O.C.C. and more powerful than
    the common Pyrokinesis super-power, so they are natural_abilities rather
    than catalog psionic rows.
  - powers_from names the book''s own list of seventeen; the wizard narrows the
    psionic picker to exactly those (see the Play/psionics notes in the
    README). The "counts as two selections" rule for the two Super powers has
    no schema shape and stays prose in the Minor Psionic Powers ability.
  - +1 Perception has no bonus key and sits in restrictions.
  - Equipment: one weapon per W.P. plus 1D4 E-Clips each, and a commercial
    vehicle (hover vehicle, souped-up motorcycle or car) - per-W.P. and dice
    quantities stay prose. Money: 4D6x100 credits + 4D4x1000 Black Market.
---

## Lore

A Burster is a Master Psychic with dramatic psychic powers that manifest in *physical* ways, most significant of which is a highly developed Pyrokinesis - the creation and manipulation of fire. These psychics can create fire out of thin air, cause things to simply burst into flames, and use fire as a weapon. This spectacular display has made the Burster one of the most feared of all psychic characters, second only to the Mind Melter. In addition to creating fire with a thought, the psychic can actually "burst" into flame - flames that provide a warm and protective covering and give the character a frightening visage and enhanced power.

Bursters are extremely passionate about ... well, everything. The more intense emotions - joy, love, hate and anger - burn the hottest within them. While some are literally "hot heads" with short tempers and explosive anger, most tend to be warm, sincere people who exhibit a fair amount of self-control; they are simply deeply committed to whatever they care about and unafraid to take a stand.

Many observers have noted that Bursters are a study of duality and extremes. Most are either Principled and Scrupulous or Miscreant and Diabolic - extreme good or extreme evil - rarely anything in between. Part of this comes from the very nature of fire, one of the four ancient mystical elements: fire nurtures, protects, helps and builds, and fire rages uncontrolled and destroys everything it touches. Paradoxically, the Burster tends to be the living embodiment of fire - a builder and destroyer, a warm and noble spirit who, if hurt or provoked, can transform into a cold-hearted destroyer with a fiery wrath.

## GM Notes

The Burster''s minor psionic list, with I.S.P. costs as printed: Bio-Regenerate (self; 6), Deaden Pain (4), Deaden Senses (4), Death Trance (1), Empathy (4), Levitation (varies), Mind Block (4), Resist Fatigue (4), Resist Hunger (2), Resist Thirst (6), See Aura (6), Sense Time (2), Suppress Fear (8), Telekinesis (varies), Telepathy (4), plus the two Super powers Psychic Body Field (30) and Radiate Horror Factor (8), each of which counts as TWO selections.

Related R.C.C.s: several other types of psychics are in Rifts World Book 12: Psyscape; see also the Fire/Water Elemental Fusionist in the magic O.C.C. section.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'burster');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'burster';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('sleeping-bag-rifts');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-burster-class.sql');
