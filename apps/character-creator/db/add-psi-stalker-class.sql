-- The Psi-Stalker (Civilized) O.C.C., Rifts Ultimate Edition p.152-155.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-psi-stalker-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('bone-knife', 'Bone Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('signal-mirror', 'Signal Mirror', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('sleeping-bag-rifts', 'Sleeping Bag Rifts', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'psi-stalker', 'Psi-Stalker (Civilized)', 'rifts', '---
id: psi-stalker
name: Psi-Stalker (Civilized)
system: rifts
source_book: Rifts Ultimate Edition p.152-155
category: occ
attribute_dice:
  IQ: "3d6"
  ME: "3d6+5"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "4d6+6"
ppe_base: "2d6"
starting_money: "6d6x100"
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
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 96%." }
    - { choose: 1, categories: ["Communications"], bonus: 20, note: "Language: Other, one of choice (+20%)." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Body Building." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Pilot: Hovercraft (+10%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: Tanks & APCs (+10%) OR Hovercycles (+15%)." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Read Sensory Equipment", base: 40, per_level: 5, note: "Sensory Equipment (+10%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Cowboy"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Tracking (people)", "Wilderness Survival"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Basic Math", "Advanced Math"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications +5%, Cowboy +5%, Domestic +5%, Electrical: Basic only (+5%), Medical: First Aid only (+5%), Military +5%, Pilot +5%, Rogue +5% except Computer Hacking, Technical +5% except all Computer skills, Wilderness +10%. Horsemanship: General and Exotic Animals only (+10% each). NOTE: even civilized Psi-Stalkers rarely care about learning to read or higher education."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
  secondary_skills:
    count: 8
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "mdc-body-armor", qty: 1 }
  - { item_id: "signal-mirror", qty: 1 }
  - { item_id: "clothing", qty: 2 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword"] }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "bone-knife", qty: 1 }
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
  - "Coalition Psi-Stalkers: standard equipment, weapons, money and cybernetics are the same as the Coalition Grunt, plus a few Dog Pack hand to hand weapons such as the Neuro-Mace, Vibro-Knife and fist spikes. All CS Psi-Stalkers are registered psychics bearing the IC bar code and implant."
extraction_notes: |
  - RUE p.152-155, the Civilized Psi-Stalker (CS soldiers, mercenaries and
    adventurers). The Wild Psi-Stalker shares every ability and differs in
    skills, attributes and equipment, so it is published as its own class -
    a variant may not restructure a skill list.
  - Save vs psionic attack is 6 or higher, better than the Master Psychic''s
    10; derive.js has one psionic save target per tier, so the 6+ is recorded
    here and in the abilities rather than as a bonus key.
  - "+1D4 to save versus magic attacks of any kind" is modeled as dice on the
    spell_magic and ritual_magic save keys.
  - +4 Perception, ambidexterity, Paired Weapons, the leap and the balance
    skill have no bonus key and sit in restrictions.
  - Money: 6D6x100 credits + 4D4x1000 in sellable Black Market items for mercs
    and independents; CS Psi-Stalkers get Coalition Grunt pay and benefits.
---

## Lore

Like the Dog Boys, the human mutants known as Psi-Stalkers have won the growing respect and friendship of the human troops they work with. Recognized as skilled Wilderness Scouts and fearless warriors, they have been elevated to the ranks of fellow soldier and equal - at least when it comes to fighting - though they are not nearly as appreciated nor loved as the Dog Boys.

Psi-Stalkers are clearly hairless, human-looking mutants who often paint or tattoo patterns on their face and body, sometimes file their teeth to points, and possess an innate supernatural ability similar to the Dog Pack''s, only "spookier." They are humans transformed by the magic and dimensional energies of the ley lines, mutated during the early decades of the Two Hundred Years Dark Age. They have survived the last few hundred years by attacking beings with high levels of P.P.E. and feeding on their life-giving energies: Psi-Stalkers are **P.P.E. vampires** who sustain themselves on magic energy rather than solid food.

A full 15% of the Coalition Army is composed of Psi-Stalkers. They generally lead Dog Packs or serve in Special Forces teams and special operations, namely those involving practitioners of magic, psychics, monsters and the supernatural. The Coalition''s prejudice against nonhumans means that although Psi-Stalkers are accepted as soldiers and enforcers, they can never achieve the same rank as true humans - which is fine by most, as they are natural hunters who don''t seek any other position in society.

## GM Notes

Psi-Stalkers can make big money as exterminators in areas plagued by supernatural beings, magic or psychics. Coalition Psi-Stalkers get the same benefits and pay as the Coalition Grunt plus hazardous duty pay; those assigned to the ISS make the same as ISS Inspectors, and CS Psi-Officers who lead a Dog Pack are paid as low ranking CS Military Specialists.

For more on Psi-Stalkers see Rifts World Book 13: Lone Star and especially World Book 23: Xiticix Invasion; for those working with the ISS police, see World Book 11: Coalition War Campaign.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'psi-stalker');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'psi-stalker';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('bone-knife', 'signal-mirror', 'sleeping-bag-rifts');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-psi-stalker-class.sql');
