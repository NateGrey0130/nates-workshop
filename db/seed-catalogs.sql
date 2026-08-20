-- One-time move of the static catalogs and class files into D1, from before
-- any of this lived in the database. Originally emitted by a generator that
-- is no longer in the repo, so it IS edited by hand now - carefully, and
-- ideally not at all: production has long since moved past it and this file
-- only ever runs against a fresh environment.
--
-- Em-dashes inside the class markdown are spliced with char(8212) rather than
-- embedded. wrangler on Windows has turned literal non-ASCII into mojibake in
-- production, and this file is the FIRST thing a new environment applies, so a
-- mangled character here would be baked into every class it seeds.

-- 48 skills
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Climbing', 'Physical', 40, 5, NULL, 'seed');

-- The five fighting styles. Seeded because the classes in this same file GRANT
-- them: without a catalog row the grant resolves to nothing, and the level
-- schedules in apps/character-creator/db/add-hand-to-hand-level-bonuses.sql
-- update a row that is not there. base 0 is correct - they have no percentage.
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Hand to Hand: Basic', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Hand to Hand: Expert', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Hand to Hand: Martial Arts', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Hand to Hand: Assassin', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Hand to Hand: Commando', 'Physical', 0, 0, NULL, 'seed');

INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Swimming', 'Physical', 50, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Prowl', 'Physical', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Gymnastics', 'Physical', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Acrobatics', 'Physical', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Body Building & Weight Lifting', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Boxing', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Wrestling', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Running', 'Physical', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Sword', 'Weapon Proficiencies', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Knife', 'Weapon Proficiencies', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Blunt', 'Weapon Proficiencies', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Shield', 'Weapon Proficiencies', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Archery', 'Weapon Proficiencies', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Paired Weapons', 'Weapon Proficiencies', 0, 0, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Energy Pistol', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('W.P. Energy Rifle', 'Weapon Proficiencies', 0, 0, '["rifts"]', 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Detect Ambush', 'Espionage', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Detect Concealment', 'Espionage', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Intelligence', 'Espionage', 32, 4, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Escape Artist', 'Espionage', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Disguise', 'Espionage', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Tracking (people)', 'Espionage', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Wilderness Survival', 'Wilderness', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Land Navigation', 'Wilderness', 36, 4, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Track & Trap Animals', 'Wilderness', 20, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Identify Plants & Fruits', 'Wilderness', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Skin & Prepare Animal Hides', 'Wilderness', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Language: Other', 'Technical', 50, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Literacy', 'Technical', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Lore: Demons & Monsters', 'Technical', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Lore: Magic', 'Technical', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Art', 'Technical', 35, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Computer Operation', 'Technical', 40, 5, '["rifts"]', 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Camouflage', 'Military', 20, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Field Armorer & Munitions Expert', 'Military', 40, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Recognize Weapon Quality', 'Military', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Demolitions', 'Military', 60, 3, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Horsemanship: General', 'Horsemanship', 35, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Horsemanship: Exotic Animals', 'Horsemanship', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Radio: Basic', 'Communications', 45, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Cryptography', 'Communications', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Laser Communications', 'Communications', 30, 5, '["rifts"]', 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Basic Math', 'Science', 45, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Advanced Math', 'Science', 45, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Astronomy', 'Science', 25, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Biology', 'Science', 30, 5, NULL, 'seed');
INSERT OR IGNORE INTO skills (name, category, base, per_level, systems, source) VALUES ('Chemistry', 'Science', 30, 5, NULL, 'seed');

-- 19 spells
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Blinding Flash', 1, 1, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Globe of Daylight', 1, 2, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Lantern Light', 1, 1, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Sense Evil', 1, 2, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Sense Magic', 1, 4, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Thunderclap', 1, 4, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Befuddle', 2, 3, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Chameleon', 2, 6, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Cloud of Smoke', 2, 2, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Concealment', 2, 6, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Detect Concealment', 2, 6, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Fear', 2, 5, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Levitation', 2, 5, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Armor of Ithan', 3, 10, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Breathe Without Air', 3, 5, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Energy Bolt', 3, 5, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Fingers of the Wind', 3, 5, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Invisibility: Simple', 3, 6, 'seed');
INSERT OR IGNORE INTO spells (name, level, ppe, source) VALUES ('Paralysis: Lesser', 3, 5, 'seed');

-- 26 psionic powers
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Bio-Regenerate (self)', 'Healing', 6, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Deaden Pain', 'Healing', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Healing Touch', 'Healing', 6, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Induce Sleep', 'Healing', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Alter Aura', 'Physical', 2, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Death Trance', 'Physical', 1, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Impervious to Cold', 'Physical', 2, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Impervious to Fire', 'Physical', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Levitation (psionic)', 'Physical', 2, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Mind Block', 'Physical', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Nightvision (psionic)', 'Physical', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Resist Fatigue', 'Physical', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Summon Inner Strength', 'Physical', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Telekinesis (minor)', 'Physical', 3, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Clairvoyance', 'Sensitive', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Empathy', 'Sensitive', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Object Read', 'Sensitive', 6, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Presence Sense', 'Sensitive', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('See Aura', 'Sensitive', 6, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Sixth Sense', 'Sensitive', 2, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Telepathy', 'Sensitive', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Bio-Manipulation', 'Super', 10, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Electrokinesis', 'Super', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Hydrokinesis', 'Super', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Mind Bolt', 'Super', 4, 'seed');
INSERT OR IGNORE INTO psionic_powers (name, category, isp, source) VALUES ('Pyrokinesis', 'Super', 4, 'seed');

-- 3 class files
INSERT OR IGNORE INTO imported_classes (class_id, name, system, markdown, status, created_by) VALUES ('cyber-knight', 'Cyber-Knight', 'rifts', '---
id: cyber-knight
name: Cyber-Knight
system: rifts
source_book: rifts-core
category: occ
attribute_requirements:
  ME: 12
  MA: 12
hit_points_base: "P.E. + 1d6 per level"
sdc_base: 30
ppe_base: "1d6x10"
skills:
  occ_skills:
    - { name: "Radio: Basic", base: 40, per_level: 5 }
    - { name: "Pilot: Hovercraft", base: 45, per_level: 5 }
    - { name: "Horsemanship", base: 40, per_level: 4 }
    - { name: "Land Navigation", base: 40, per_level: 4 }
    - { name: "Paramedic", base: 40, per_level: 5 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0 }
  occ_related_skills:
    count: 6
    categories: ["Physical", "Weapon Proficiencies", "Espionage", "Wilderness", "Technical"]
  secondary_skills:
    count: 2
equipment_starting:
  - { item_id: "ns-turbo-cyclone", qty: 1 }
  - { item_id: "cyber-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 2 }
psionics:
  type: "major"
  isp_base: "1d4x10+20"
special_abilities:
  - name: "Psi-Sword"
    description: "Manifest a blade of psychic energy. 1d6 M.D. per level of experience, no I.S.P. cost."
  - name: "Cyber-Armor"
    description: "Concealed M.D.C. body armor grafted to the knight. 60 M.D.C., regenerates with rest."
level_progression:
  - level: 2
    grants: ["+1 attack per melee"]
  - level: 3
    grants: ["Psi-Sword damage +1d6 M.D."]
  - level: 5
    grants: ["+1 attack per melee", "Zen Combat: +1 to strike, parry, dodge vs machines"]
---

## Lore

Wandering champions of the Megaverse, the Cyber-Knights are an order of noble
warriors founded by Lord Coake. Part paladin, part ranger, they roam the wilds
of post-apocalyptic North America defending the weak against monsters, bandits,
and the excesses of the Coalition States alike. Each knight carries the
signature Psi-Sword ' || char(8212) || ' a weapon of pure psychic energy that cannot be taken
from them ' || char(8212) || ' and lives by a strict code of chivalry.

## GM Notes

A Cyber-Knight who grossly violates the Code of Chivalry should face in-game
consequences (loss of reputation with the order, possible visit from a senior
knight). House rule: no starting cybernetics beyond the Cyber-Armor graft.
', 'published', 'seed');
INSERT OR IGNORE INTO imported_classes (class_id, name, system, markdown, status, created_by) VALUES ('dragon-hatchling', 'Dragon Hatchling (Great Horned)', 'rifts', '---
id: dragon-hatchling
name: Dragon Hatchling (Great Horned)
system: rifts
source_book: rifts-core
category: rcc
attribute_dice:
  IQ: "3d6+6"
  ME: "3d6+2"
  MA: "3d6+4"
  PS: "4d6+12"
  PP: "3d6+4"
  PE: "3d6+6"
  PB: "4d6"
  Spd: "3d6+10"
mdc_base: "1d4x100"
ppe_base: "2d4x10+40"
skills:
  occ_skills:
    - { name: "Basic Math", base: 60, per_level: 5 }
    - { name: "Language: Dragonese", base: 96, per_level: 0 }
    - { name: "Lore: Demons and Monsters", base: 40, per_level: 5 }
  occ_related_skills:
    count: 4
    categories: ["Communications", "Science", "Technical", "Wilderness"]
  secondary_skills:
    count: 2
psionics:
  type: "major"
  isp_base: "1d6x10+30"
magic:
  type: "innate"
  spells_starting: 4
  spell_levels_allowed: [1, 2]
natural_abilities:
  - name: "Metamorphosis"
    description: "Assume the shape of any living creature for 1 hour per level of experience, twice per day."
  - name: "Fire Breath"
    description: "Breathe fire up to 100 feet, 2d6 M.D. per blast."
  - name: "Nightvision"
    description: "See in total darkness up to 200 feet."
  - name: "Bio-Regeneration"
    description: "Recover 1d4x10 M.D.C. per hour."
level_progression:
  - level: 2
    grants: ["+1 spell from levels 1-3"]
  - level: 3
    grants: ["Metamorphosis duration doubles"]
  - level: 5
    grants: ["+2 spells from levels 1-4", "+1 attack per melee"]
restrictions:
  - "Cannot take an O.C.C. until reaching adulthood (centuries from now)."
  - "Hatchlings are naive about the modern world; play accordingly."
---

## Lore

Great Horned Dragons are among the mightiest beings of the Megaverse, and even
a hatchling ' || char(8212) || ' mere decades old ' || char(8212) || ' is a creature of Mega-Damage flesh, innate
magic, and razor intellect. Hatchling player characters are newly hatched
(often orphaned by dimension-hopping circumstance), possessing terrifying raw
power but a child''s understanding of the world. They metamorphose into human
form to walk among mortals, and most are insatiably curious.

## GM Notes

The power gap between a hatchling and human classes is real ' || char(8212) || ' lean on the
naivete and the attention a young dragon attracts (Coalition, dragon hunters,
other dragons) to balance the table. Metamorphosis does not grant the copied
creature''s abilities, only its shape.
', 'published', 'seed');
INSERT OR IGNORE INTO imported_classes (class_id, name, system, markdown, status, created_by) VALUES ('long-bowman', 'Long Bowman', 'palladium-fantasy', '---
id: long-bowman
name: Long Bowman
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements:
  PP: 10
  PE: 10
hit_points_base: "P.E. + 1d6 per level"
sdc_base: 20
ppe_base: "2d6"
skills:
  occ_skills:
    - { name: "W.P. Archery", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "Wilderness Survival", base: 35, per_level: 5 }
    - { name: "Track Animals", base: 30, per_level: 5 }
    - { name: "Carpentry (fletching)", base: 35, per_level: 5 }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0 }
  occ_related_skills:
    count: 8
    categories: ["Physical", "Weapon Proficiencies", "Wilderness", "Military", "Horsemanship"]
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "long-bow", qty: 1 }
  - { item_id: "arrows-standard", qty: 24 }
  - { item_id: "short-sword", qty: 1 }
  - { item_id: "leather-armor", qty: 1 }
level_progression:
  - level: 2
    grants: ["+1 aimed shot per melee with long bow"]
  - level: 4
    grants: ["+1 to strike with long bow"]
  - level: 6
    grants: ["+1 aimed shot per melee with long bow"]
---

## Lore

Masters of the great war bow, Long Bowmen are the backbone of any serious
army in the Palladium world and prized mercenaries besides. Years of training
give them a rate of fire and accuracy no ordinary soldier can match. Most are
commoners who earned their place through skill rather than birth, and many
supplement soldiering with hunting, fletching, and woodcraft.

## GM Notes

Remember the long bow''s rate of fire stacks with Hand to Hand attacks per the
core rules ' || char(8212) || ' it adds up fast at high level. Check ammunition bookkeeping;
arrows are cheap but not infinite in the wilderness.
', 'published', 'seed');
