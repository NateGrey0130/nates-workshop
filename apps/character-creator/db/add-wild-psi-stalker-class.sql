-- The Wild Psi-Stalker O.C.C., Rifts Ultimate Edition p.155-156.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-wild-psi-stalker-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('bone-knife', 'Bone Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('gun-holster', 'Gun Holster', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('riding-horse', 'Riding Horse', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('wooden-spear', 'Wooden Spear', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'wild-psi-stalker', 'Wild Psi-Stalker', 'rifts', '---
id: wild-psi-stalker
name: Wild Psi-Stalker
system: rifts
source_book: Rifts Ultimate Edition p.155-156
category: occ
attribute_dice:
  IQ: "3d6"
  ME: "3d6+5"
  MA: "3d6"
  PS: "3d6+2"
  PP: "3d6+2"
  PE: "4d6"
  PB: "3d6"
  Spd: "4d6+6"
ppe_base: "2d6"
starting_money: "0"
psionics:
  type: "master"
  isp_base: "1d6x10, +10 per additional level of experience"
  powers_starting: 6
  categories_allowed: ["Sensitive"]
bonuses:
  pools: { hp: "1d6+1", sdc: 10 }
  combat: { attacks: 1 }
  saves: { mind_control: 5, possession: 3, horror_factor: 6, spell_magic: "1d4", ritual_magic: "1d4" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 90%." }
    - { choose: 1, categories: ["Communications"], bonus: 25, note: "Language: Other, one of choice (+25%)." }
    - { name: "Detect Ambush", base: 35, per_level: 5, note: "+5%" }
    - { name: "Escape Artist", base: 35, per_level: 5, note: "+5%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Horsemanship: Cowboy", base: 76, per_level: 3, note: "+10%" }
    - { name: "Horsemanship: Exotic Animals", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Tracking (humanoids, NOT animals; +10%)." }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: three of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", only: ["Barter", "Language: Other", "Performance", "Sign Language", "Radio: Basic"] }
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots and Power Armor", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Tanks and APCs"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Astronomy & Navigation", "Basic Math"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Barter, Language Other, Performance, Sign Language and Radio: Basic only (+5%). Domestic +5%. Medical: First Aid and Holistic Medicine only (+5%). Physical: Any (+5% where applicable). Pilot: Any (+5%) except power armor, robots and military vehicles. Rogue +5% except Computer Hacking. Technical +5% except all Computer skills. Wilderness +10%. Cowboy, Electrical, Horsemanship (beyond the O.C.C. skills), Mechanical, Military and Pilot Related: none. NOTE: most Wild Psi-Stalkers care nothing about learning to read or higher education."
    schedule:
      - { level: 5, count: 1 }
      - { level: 10, count: 1 }
  secondary_skills:
    count: 8
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "mdc-body-armor", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "gun-holster", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-spear", qty: 1 }
  - { item_id: "bone-knife", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
natural_abilities:
  - name: "Sense Psychic and Magic Energy"
    description: "Like a bloodhound smelling a familiar scent, the Psi-Stalker detects psychic energy - fellow psionics (I.S.P.) and magic and the supernatural (both with high P.P.E.). A natural ability like a human''s sense of smell: the moment a psychic scent is within range he recognizes it and can trace it to the specific individual. Base Skill: 60% +5% per level (roll once every melee) to track energy in use; 20% +5% per level to recognize a specific scent again, +20% with a bit of hair, skin, blood or clothing worn within four hours. Ranges: a practitioner NOT using powers, 50 feet (15 m) +20 feet (6 m) per level; powers BEING USED, 600 feet (182 m) +100 feet (30.5 m) per level. Other P.P.E. sources confuse the scent (-10%, -20% if numerous). Close proximity to a ley line (2 miles) halves specific-scent tracking; a nexus point (4 miles) obliterates it entirely."
  - name: "Sense Supernatural Beings"
    description: "As above, but attuned to the distinctive scent of the supernatural (demons, Elementals, Godlings). Base Skill: 40% +5% per level, including demons, vampires and Entities. Tracking by psychic scent alone: 30% +5% per level when the being is in disguise and not using its abilities, 70% +3% per level if it is expending psionic or magic energy or is a Greater Demon, god or Alien Intelligence. Ranges: a supernatural being not using powers, 50 feet (15 m) per level; powers being expended, 1000 feet (305 m) +100 feet (30.5 m) per level. Ley lines and nexus points have the same adverse effects."
  - name: "Nourishment - the P.P.E. Vampire"
    description: "The Psi-Stalker must feed on a minimum of 50 P.P.E. or I.S.P. a week, preferably 80 to 100. To feed without killing, the predator hunts down a psychic, practitioner of magic, creature of magic or supernatural monster, physically captures the prey, cuts it (1D6 S.D.C. or 1D4 M.D.) and drains all available P.P.E. - up to 300 points in a single sitting. Against creatures of great magic he feasts on 300 points and causes another 1D4x100 to dissipate into the area for other Psi-Stalkers. Psychics temporarily lose HALF their I.S.P. and ALL their P.P.E. Once feeding begins he cannot stop until all the P.P.E. is absorbed (about five seconds). CANNOT feed on beings who are not practitioners of magic, creatures of magic, psychic or supernatural. Ley line energy can sustain him in an emergency but tastes foul (-1 on all combat bonuses for 1D6x10 minutes)."
  - name: "No Need for Normal Food or Water"
    description: "Needs no more than one pound (0.45 kg) of meat and eight ounces (0.23 liters) of water a week, and can go three weeks without either. But deprivation of P.P.E. inflicts real damage: for every week with less than 50 P.P.E. he suffers 6D6 points to BOTH Hit Points and S.D.C. until down to a minimum of two each, and combat bonuses and attacks per melee are halved. After three weeks of starvation, unless P.P.E. becomes available, he dies within 1D6 days."
  - name: "Psionic Empathy with Animals"
    description: "An automatic affinity with animals of all kinds. Domesticated animals take an immediate liking to him and do their best to please; he can ride any horse (wild or tame) or non-predatory animal at +15% and work with any domestic animals. Wild animals - excepting felines and mutant or alien predators - react to him as a fellow woodland creature and allow him to walk among them without fear, so birds do not fly and animals do not run to betray his approach. Even watchdogs do not bark. Most feline, mutant and alien predators, however, see the Psi-Stalker as a rival and will frequently select him as their first target in battle. The affinity means the character hunts and eats meat only for food, never pleasure."
  - name: "Mega-Damage Combat"
    description: "A closely guarded secret: whenever a Psi-Stalker locks horns with an M.D.C. supernatural being or creature of magic, his Hit Points turn into M.D.C., temporarily making him a minor Mega-Damage creature. This also occurs on a ley line (50% more M.D.C.) and at a nexus point (M.D.C. doubled). Note: although H.P. becomes M.D.C., he still inflicts S.D.C. damage with his bare hands."
  - name: "Psionics and I.S.P."
    description: "Master Psychic who needs only a 6 or higher to save vs psionic attack. Chooses SIX psi-powers from the Sensitive category only. I.S.P. Base: M.E. attribute plus 1D6x10, +10 per additional level. Recovery: two I.S.P. per hour of activity or 12 per hour of meditation or sleep."
restrictions:
  - "Racial Requirement: Psi-Stalkers are mutant humans only."
  - "O.C.C. bonuses beyond the modeled saves: ambidextrous and Paired Weapons; can leap six feet (1.8 m) high or 10 feet (3 m) long (+20% to length with a running start); excellent balance (80% +2% per level)."
  - "Cybernetics: starts with none; tends to avoid implants in favor of natural powers."
  - "Wild Psi-Stalkers get +5 on Perception Rolls rather than the Civilized Stalker''s +4 - the one mechanical difference between the two."
  - "Fifty percent are cannibals who eat part of their victims; the act is a manifestation of the predatory killing instinct rather than a need for flesh."
extraction_notes: |
  - RUE p.155-156. Special abilities and bonuses are the Civilized
    Psi-Stalker''s, except Perception is +5 rather than +4 - so this class
    carries the same natural_abilities block verbatim.
  - Published as its own class rather than a variant of the Civilized
    Psi-Stalker: the two differ in skills, attribute dice and equipment, and
    a variant may not restructure a skill list.
  - Money: no credits at all, 4D6x1000 in sellable Black Market items;
    starting_money is 0 because the character genuinely starts with no coin.
  - Starts with a good quality horse or other riding mount (has an affinity
    with all non-predatory animals), or a non-military vehicle or souped-up
    hovercycle - the mount is modeled, the vehicle alternatives are prose.
---

## Lore

Wild Psi-Stalkers are the nomadic tribal people of the wilderness. When civilization crashed after the Great Cataclysm, the ancestors of the Psi-Stalkers fell to barbarism; over the centuries they''ve advanced, but remain very much like Native American Indian tribes of the past, only a bit more wild and savage. Fifty percent are cannibals who eat part of their victims or tear them to shreds - a manifestation of the predatory killing instinct, since Psi-Stalkers have minimal need for flesh and blood nourishment.

With rare exceptions they never hunt or kill a fellow Psi-Stalker, but they do engage in friendly and not so friendly competitions, feuds and vendettas with rival tribes and clans. Most Wild Psi-Stalkers consider their Coalition counterparts to be weaklings and sissies, even cowards, and love to chide and insult CS Stalkers whenever they encounter them - part jealousy, because the CS Stalkers have an easier life and fun toys like environmental body armor, Vibro-Blades and guns without having to steal or barter for them.

The typical Wild Psi-Stalker is cunning, sneaky, selfish and silent; often a solitary hunter who uses his powers and fighting abilities rather than skills and machines. The clans in the Pecos Empire are among the most savage and murderous on the continent. Psi-Stalkers are least common in the American Southwest, but their numbers increase dramatically in the Northwest and throughout the Magic Zone; total numbers could be as high as 2-6 million scattered across the US and Canada.

## GM Notes

Wild Psi-Stalkers frequently join bandits and adventurer groups, especially if the group is predominantly human. They are also fascinated with Cyber-Knights and often join or assist them on their crusades, although most Wild Stalkers are too undisciplined to become one.

Encounters between Wild and Civilized Psi-Stalkers almost always result in contests of one-upmanship, threats, steely-eyed stares, brawls, firefights and even bloodshed.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'wild-psi-stalker');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'wild-psi-stalker';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('bone-knife', 'gun-holster', 'riding-horse', 'wooden-spear');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-wild-psi-stalker-class.sql');
