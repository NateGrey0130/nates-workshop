-- BOOK-INGEST-AUDIT F110: the Psi-Stalker and the Dog Boy become a race plus
-- an occupation, so the classes whose books open them to Psi-Stalkers (and
-- Dog Pack) can say so. Nate chose the split on 2026-09-27.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~039-f110-psi-stalker-and-dog-races.sql
--
-- Runs AFTER add-mutant-psi-stalker-class.sql and add-mutant-dog-class.sql,
-- which create the two race rows this names; both sort before this file.
--
-- WHAT.
--   psi-stalker, wild-psi-stalker  the occupation halves; attribute dice,
--       P.P.E., psionics, racial bonuses and natural abilities moved to the
--       mutant-psi-stalker R.C.C., the only race each takes. The Wild one's
--       3D6+2 P.S. and P.P. is the race's 3D6 plus a +2 occupation bonus.
--   dog-boy, ntset-psi-hound  the same, onto the mutant-dog R.C.C.; the
--       Psi-Hound keeps only the bonuses its book adds to the dog's.
--   coalition-grunt, ntset-protector, psi-slinger  humans and Psi-Stalkers.
--   psi-net-agent  humans, Psi-Stalkers and Dog Pack.
--   psycho-stalker  stays a class carrying its own package: its printed
--       numbers already include the Psi-Stalker's bonuses, and a pairing adds
--       a race's bonuses to an occupation's. Only its note changes.
--   seljuk  its note named the old block as what refuses a seljuk Psi-Stalker.
--
-- MEASURED BEFORE WRITING (2026-09-27, against production's rows): each race
-- composed with each reworked occupation through js/compose.js composeClass
-- equals what the combined class composed to - attribute dice, pools, P.P.E.,
-- money, experience table, psionics, bonuses, skills, equipment and abilities -
-- apart from the Wild Psi-Stalker's +2 arriving as a bonus. No character or
-- draft uses any of the four split classes.
--
-- MECHANICS. The four split classes are rewritten whole, guarded on the
-- natural_abilities key the old row has and the new one does not. The rest are
-- replace()s guarded on the old text present and the new text absent. A
-- second run changes nothing.

-- psi-stalker: the occupation half; the racial package is now the race's
UPDATE imported_classes
   SET markdown = '---
id: psi-stalker
men_of_arms: true
occ_group: psychic
race_restrictions:
  only: ["mutant-psi-stalker"]
  note: "Racial Requirement: Psi-Stalkers are mutant humans only (RUE p.152). The race is the mutant-psi-stalker R.C.C. (BOOK-INGEST-AUDIT F110, taken 2026-09-27), which carries the Psi-Stalker''s attributes, P.P.E., psionics, racial bonuses and natural abilities; this occupation is what the character learned."
name: Psi-Stalker (Civilized)
system: rifts
source_book: Rifts Ultimate Edition p.152-155
category: occ
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
starting_money: "6d6x100"
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 96%." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "Language: Other, one of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Body Building." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Pilot: Hovercraft (+10%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: Tanks & APCs (+10%) OR Hovercycles (+15%)." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Sensory Equipment (+10%)." }
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
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
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
  - { choose: 1, label: "M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "gladiator-body-armor", "ca-1-heavy-dead-boy-armor", "crusader-body-armor"] }
  - { item_id: "signal-mirror", qty: 1 }
  - { item_id: "clothing", qty: 2 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { choose: 1, label: "vibro-blade", qty: 1, from: ["vibro-knife", "vibro-sword"] }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "bone-knife", qty: 1 }
restrictions:
  - "Coalition Psi-Stalkers: standard equipment, weapons, money and cybernetics are the same as the Coalition Grunt, plus a few Dog Pack hand to hand weapons such as the Neuro-Mace, Vibro-Knife and fist spikes. All CS Psi-Stalkers are registered psychics bearing the IC bar code and implant."
extraction_notes: |
  - RUE p.152-155, the Civilized Psi-Stalker (CS soldiers, mercenaries and
    adventurers). The Wild Psi-Stalker shares every ability and differs in
    skills, attributes and equipment, so it is published as its own class -
    a variant may not restructure a skill list.
  - The occupation half since 2026-09-27 (BOOK-INGEST-AUDIT F110, taken 2026-09-27): the attribute
    dice, P.P.E., psionics, racial bonuses and natural abilities moved to the
    mutant-psi-stalker R.C.C., the only race this class takes. The book
    prints them as what every Psi-Stalker has (printed 153).
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
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-stalker'
   AND instr(markdown, char(10) || 'natural_abilities:') > 0;

-- wild-psi-stalker: the occupation half; the racial package is now the race's
UPDATE imported_classes
   SET markdown = '---
id: wild-psi-stalker
men_of_arms: true
occ_group: psychic
race_restrictions:
  only: ["mutant-psi-stalker"]
  note: "Racial Requirement: Psi-Stalkers are mutant humans only (RUE p.155). The race is the mutant-psi-stalker R.C.C. (BOOK-INGEST-AUDIT F110, taken 2026-09-27), which carries the Psi-Stalker''s attributes, P.P.E., psionics, racial bonuses and natural abilities; this occupation is what the character learned."
name: Wild Psi-Stalker
system: rifts
source_book: Rifts Ultimate Edition p.155-156
category: occ
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
starting_money: "0"
bonuses:
  attributes: { PS: 2, PP: 2 }
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 90%." }
    - { choose: 1, from: ["Language: Other"], bonus: 25, note: "Language: Other, one of choice (+25%). Taken once per language - the picker asks which." }
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
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Astronomy & Navigation", "Mathematics: Basic"] }
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
  - { choose: 1, label: "M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "gladiator-body-armor", "ca-1-heavy-dead-boy-armor", "crusader-body-armor"] }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "gun-holster", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-spear", qty: 1 }
  - { item_id: "bone-knife", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Wild Psi-Stalkers get +5 on Perception Rolls rather than the Civilized Stalker''s +4 - the one mechanical difference between the two."
  - "Fifty percent are cannibals who eat part of their victims; the act is a manifestation of the predatory killing instinct rather than a need for flesh."
extraction_notes: |
  - RUE p.155-156. Special abilities and bonuses are the Civilized
    Psi-Stalker''s, except Perception is +5 rather than +4.
  - The occupation half since 2026-09-27 (BOOK-INGEST-AUDIT F110, taken 2026-09-27): the racial
    package moved to the mutant-psi-stalker R.C.C., the only race this class
    takes. The book prints P.S. and P.P. at 3D6+2 where the race rolls 3D6,
    so the +2 is this occupation''s attribute bonus.
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
',
       updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker'
   AND instr(markdown, char(10) || 'natural_abilities:') > 0;

-- dog-boy: the occupation half; the racial package is now the race's
UPDATE imported_classes
   SET markdown = '---
id: dog-boy
men_of_arms: false
occ_group: psychic
race_restrictions:
  only: ["mutant-dog"]
  note: "Racial Requirements: a mutant canine genetically created by the Coalition States (RUE p.142). The race is the mutant-dog R.C.C. (BOOK-INGEST-AUDIT F110, taken 2026-09-27), which carries the dog''s attributes, pools, psionics, racial bonuses and senses; this occupation is the Dog Pack soldier''s training."
name: Dog Boy
system: rifts
source_book: Rifts Ultimate Edition p.142-149
category: occ
xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]
starting_money: "600"
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 88%." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "Language: Other, one of choice (+5%). Taken once per language - the picker asks which." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Intelligence", base: 38, per_level: 4, note: "+6%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Pilot: Hovercraft (+10%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Knife or Sword (pick one)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", only: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes", "Jet Packs", "Truck", "Boat: Motor, Race & Hydrofoil"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Any (+5%). Domestic: Any (+5%). Espionage: Any (+5%). Mechanical: Basic and Automotive only (+5%). Medical: First Aid only (+5%). Military: Any (+10%). Physical: Any except Acrobatics. Pilot: Motorcycle, Hovercycle, Jet Pack, Truck & Motorboat only (+5%). Technical: Any (+5%) except Computer Operation & Programming. Wilderness: Any (+5%). Cowboy, Pilot Related, Rogue and Science: none. NOTE: Dog Boys in CS service are never taught to read, not even officers."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "dog-pack-dpm-riot-armor", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "small-hammer", qty: 1 }
  - { item_id: "spike", qty: 4 }
  - { item_id: "animal-snare", qty: 1 }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "close-combat weapon", qty: 1, from: ["vibro-knife", "vibro-claws"] }
  - { item_id: "c-18-laser-pistol", qty: 1 }
  - { choose: 1, label: "laser assault rifle", qty: 1, from: ["c-10-laser-rifle", "c-12-laser-rifle"] }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "canteen", qty: 1 }
restrictions:
  - "Cybernetics: none to start; most mutant canines would prefer to avoid them."
extraction_notes: |
  - RUE p.142-149. The book''s Designer''s Note classifies the Dog Boy as an
    O.C.C. (an R.C.C. is a character so defined by its genetics that it
    cannot select another occupation; a Dog Boy could learn other jobs, which
    puts it on par with a D-Bee).
  - The occupation half since 2026-09-27 (BOOK-INGEST-AUDIT F110, taken 2026-09-27): the attribute
    dice, pools, psionics, racial bonuses and senses moved to the mutant-dog
    R.C.C., the only race this class takes. men_of_arms: false follows the
    class''s psychic grouping; the race''s printed S.D.C. decides the pool.
  - Money is the two months'' starting pay of a Dog Pack soldier (200-300
    credits a month); the CS provides quarters, food, clothing, medical care
    and equipment, so 600 is a representative figure rather than a roll.
  - The optional Height and Type/Breed percentile tables (and their per-breed
    bonuses) are player options that no schema field holds; they are
    summarised in GM Notes.
---

## Lore

The so-called "Dog Boy" is the Coalition States genetic engineering laboratories'' most successful creation. All Dog Boys have their origin with the CS, although an increasing number (perhaps as many as 5%) are "free born" - the natural born offspring of lab created Dog Boys who have gone AWOL from the Coalition Army.

Coalition Dog Boys have come to play an increasingly important role in CS defenses and military operations because they can literally "sniff out," sense and sometimes see users of magic and the supernatural even when invisible or disguised. One or two Dog Boys are assigned to most every squad operating outside CS held territory. The bond of friendship and camaraderie between the human troops and the mutant Dog Boys is almost akin to that of a boy and his dog, and the feeling is mutual: like real domesticated canines, Dog Boys love the company of humans and instinctively regard them as both part of their "pack" and their superiors.

Since Dog Boys are trained animals specially bred for duty as guard "animals," they are generally looked upon by the military brass as an expendable commodity - an attitude not shared by the Psi-Stalkers or police partnered with them. Most Dog Boys don''t see anything wrong with how they are treated and are happy just to be part of the human pack for however long that may be.

## GM Notes

**Optional Height table:** 01-10% four feet; 11-30% five feet; 31-50% five feet six; 51-65% five feet ten; 66-80% six feet; 81-90% six feet four; 91-00% six feet eight.

**Optional Type/Breed table (a sample):** 01-05% Irish Water Spaniel (good tracker, excellent swimmer 90%, +1 Perception, near-waterproof coat); 06-10% Wolfhound (tracks by sight not scent, -40% to track by smell, +30 S.D.C., +1D4 P.E. and P.S., +3D6 Spd, +1 Perception, +2 initiative, bite +2D6); 11-15% Irish or English Setters (good tracker, +2D6 S.D.C., +1 P.E., +1 Perception, fair swimmer 55%); 16-20% Coonhound (superior sniffer, +5% to track by smell, +3 Perception); 21-25% Golden Retriever (good tracker, hardy, +3D6 S.D.C., +1 P.S. and P.E., +2 Perception, natural swimmer 80%). Add all bonuses together with the standard ones.

A standard CS reconnaissance or patrol squad at Tolkeen or the Magic Zone consists of four human soldiers, a Dog Pack (four Dog Boys) and one Psi-Stalker, plus a squad leader. A pack of four or more Dog Boys is always led by a Civilized Psi-Stalker.

For more breeds and the full range of Coalition mutants, see Rifts World Book 13: Lone Star (pages 22-55).
',
       updated_at = datetime('now')
 WHERE class_id = 'dog-boy'
   AND instr(markdown, char(10) || 'natural_abilities:') > 0;

-- ntset-psi-hound: the occupation half; the racial package is now the race's
UPDATE imported_classes
   SET markdown = '---
id: ntset-psi-hound
men_of_arms: false
name: NTSET Psi-Hound
system: rifts
source_book: Rifts World Book 11: Coalition War Campaign p.187-188
category: occ
xp_table: [0, 2051, 4101, 8401, 16801, 25561, 35801, 50401, 70801, 95401, 130801, 180401, 230801, 280401, 331801]
occ_group: psychic
race_restrictions:
  only: ["mutant-dog"]
  note: "The entry states Race: Mutant Dog and points to the Rifts RPG for the dog''s powers (printed 187). The race is the mutant-dog R.C.C. (BOOK-INGEST-AUDIT F110, taken 2026-09-27), which carries that package; until then this class carried a copy of the dog-boy class''s."
attribute_requirements:
  IQ: 10
  ME: 12
starting_money: "3d4x10"
bonuses:
  combat: { initiative: 1 }
  saves: { psionics: 1, mind_control: 1, illusionary_magic: 1, possession: 1, spell_magic: 1, ritual_magic: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 2 } }
    - { level: 3, saves: { possession: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { horror_factor: 2 } }
    - { level: 6, saves: { possession: 1 } }
    - { level: 7, saves: { horror_factor: 2 } }
    - { level: 9, combat: { initiative: 1 } }
    - { level: 10, saves: { possession: 1, horror_factor: 2 } }
    - { level: 12, saves: { horror_factor: 2 } }
    - { level: 13, saves: { possession: 1 } }
    - { level: 15, saves: { horror_factor: 2 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American at 98%." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Math: Basic (+20%)." }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "Printed as Tracking (humanoids; +15%)." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Surveillance", base: 40, per_level: 5, note: "Printed as Surveillance Systems (+10%)." }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: Magic", base: 45, per_level: 5, note: "+20%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Martial Arts", base: 0, per_level: 0, note: "This skill cannot be changed." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 4, count: 4 }, { level: 8, count: 4 }, { level: 12, count: 4 }]
    categories:
      - { name: "Communications", only: ["Radio: Scramblers", "T.V./Video"], bonus: 10 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", only: ["Military Etiquette", "Recognize Weapon Quality"], bonus: 10 }
      - "Physical"
      - { name: "Rogue", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "The book says to select four other skills at levels one, four, eight and twelve, stored as four at each of those levels. Espionage, Mechanical, Pilot, Pilot Related and Science: none."
  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }]
equipment_starting:
  - { choose: 1, label: "old style Dead Boy armor or Dog Pack riot armor", qty: 1, from: ["ca-1-heavy-dead-boy-armor", "ca-2-light-dead-boy-armor", "dog-pack-dpm-riot-armor"] }
  - { item_id: "goggles", qty: 1 }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["c-18-laser-pistol", "c-20-laser-pistol", "cp-30-laser-pulse-pistol"] }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "neural-mace", qty: 1 }
  - { choose: 1, label: "vibro-knife or saber", qty: 1, from: ["vibro-knife", "vibro-saber"] }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "fiberglass-nightstick", qty: 1 }
  - { item_id: "stun-flash-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 2 }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "handcuffs-regular", qty: 2 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
special_abilities:
  - name: "Dog Pack Breed Abilities"
    description: "All Dog Pack members sense magic and the supernatural; some breeds carry further abilities or aptitudes, for which the book points to the Rifts RPG and Lone Star. The breed tables are summarised in the Dog Boy class."
restrictions:
  - "Racial Requirement: a mutant canine (printed 187). The dog''s own powers are the mutant-dog race''s."
  - "Only one in ten NTSET Dog Boys served before in the military or the ISS; most are hand-picked or bred for NTSET."
  - "Armor: the breeds'' head shapes rule out the standard environmental helmet, so the dog wears the Dead Boy suit with a skull cap, goggles and air filter, or Dog Pack DPM light riot armor instead."
  - "Standard gear also includes a squirt gun, which has no catalog row and is not in equipment_starting."
  - "Seldom issued a vehicle. Security clearance is low to medium, but the dog may escort a human squad leader to any level that leader is cleared for."
  - "Monthly allowance of 150 credits for personal items; housing (a two room apartment on levels 4-10), food, clothing, equipment and full medical benefits are provided."
  - "Cybernetics: none to start; may be awarded for exemplary service or to repair an injury."
level_progression:
  - { level: 4, grants: ["+4 O.C.C. Related Skills"] }
  - { level: 8, grants: ["+4 O.C.C. Related Skills"] }
  - { level: 12, grants: ["+4 O.C.C. Related Skills"] }
extraction_notes: "XP: stored 2026-09-26 as xp_table, printed 224''s column headed NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical Specialist, read off a render. It prints two lower bounds inside the band before (level 6 at 24,561 under level 5''s 16,801-25,560; level 15 at 331,401 under level 14''s top of 331,800); both are stored as the previous top plus one, 25,561 and 331,801, as vanguard-brawler stores the same column (#1406). Page span: the NTSET section opens on printed 186 (its organization and nonhuman roster run to 187); the class heading, race and attribute line are on printed 187 and the rest of the entry fills the left column and the top of the right column of printed 188, where the NTSET Protector begins. RACE: the book says Mutant Dog and defers the dog''s powers to the Rifts RPG. Since 2026-09-27 (BOOK-INGEST-AUDIT F110, taken 2026-09-27) that package is the mutant-dog R.C.C., the only race this class takes; until then this class carried a copy of the dog-boy class''s. GROUP: psychic, matching dog-boy; the NTSET section prints no Rifts O.C.C. grouping and the mutant canine is a master psychic. BONUSES: the O.C.C. bonuses are stored here and the racial ones on the race, and a pairing adds the two - initiative +1 at levels 1, 4 and 9; +1 vs magic illusion, mind control, psionic attack and magic of all kinds (stored on spell_magic and ritual_magic); +1 vs possession at 1, 3, 6, 10 and 13; +2 vs horror factor at 2, 4, 7, 10, 12 and 15. HAND TO HAND: Martial Arts, printed as unchangeable, so the price block is empty. RELATED SKILLS: printed as four skills at levels one, four, eight and twelve with no separate later count; stored literally as four at each level. Communications is printed as Scrambler, TV & Video only. MONEY: 3D4x10 credits to start, read from a render because the text layer ciphers it; a 150 credit monthly allowance. ARMOR: the book''s old style Dead Boy armor is CA-1 heavy or CA-2 light (printed 104). The flares are stored as signal flares, the flash grenades as stun/flash grenades, the nightstick as the fiberglass row and the silver cross as the small silver cross. The squirt gun and skull cap have no catalog row and are prose. Vehicles: seldom issued, and only on assignment (printed 188), so equipment_starting has nothing to hold. This cited BOOK-INGEST-AUDIT.md F3 until 2026-09-27 (~029-class-vessel-notes.sql)."
---

## Lore

NTSET, nicknamed the Nut Set, is an elite anti-supernatural police division
under the ISS that never leaves the cities it guards. Over half its operatives
are nonhuman, and four in ten are Dog Boys, called Psi-Hounds, prized above
all for sniffing out the supernatural and practitioners of magic.

The Psi-Hounds patrol the slums, sewers and lower levels, hunt down monsters
and dangerous D-bees, and work as a precision strike team alongside human
squad leaders, who often come to trust them more than their human partners.

## GM Notes

A Psi-Hound is a Dog Boy with police training: lore about magic and monsters,
tracking of people, surveillance and streetwise skills, and unchangeable
Martial Arts. The Coalition provides almost everything, so the dog''s own purse
is tiny. Crazy Cavanaugh (printed 189-190) is the notable NTSET handler whose
squad of Dog Boys shows how they are used.
',
       updated_at = datetime('now')
 WHERE class_id = 'ntset-psi-hound'
   AND instr(markdown, char(10) || 'natural_abilities:') > 0;

-- coalition-grunt: Humans and Psi-Stalkers only (RUE p.230)
UPDATE imported_classes
   SET markdown = replace(markdown, 'race_restrictions:
  only: ["none"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human mutant. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.230."
', 'race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human mutant (RUE p.230). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-grunt'
   AND instr(markdown, 'race_restrictions:
  only: ["none"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human mutant. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.230."
') > 0
   AND instr(markdown, 'race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human mutant (RUE p.230). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
') = 0;

-- ntset-protector: Race: Human or Psi-Stalker (printed 188)
UPDATE imported_classes
   SET markdown = replace(markdown, 'race_restrictions:
  only: ["none"]
  note: "The entry states Race: Human or Psi-Stalker (printed 188). In Rifts a human character takes no R.C.C., so \"none\" is the human case. The Psi-Stalker is an O.C.C. in this catalog (psi-stalker) rather than a race, so it cannot be paired with this class; a Psi-Stalker Protector is outside what the app can build."
', 'race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "The entry states Race: Human or Psi-Stalker (printed 188). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'ntset-protector'
   AND instr(markdown, 'race_restrictions:
  only: ["none"]
  note: "The entry states Race: Human or Psi-Stalker (printed 188). In Rifts a human character takes no R.C.C., so \"none\" is the human case. The Psi-Stalker is an O.C.C. in this catalog (psi-stalker) rather than a race, so it cannot be paired with this class; a Psi-Stalker Protector is outside what the app can build."
') > 0
   AND instr(markdown, 'race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "The entry states Race: Human or Psi-Stalker (printed 188). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
') = 0;

-- psi-net-agent: roster of humans, Psi-Stalkers and Dog Pack (printed 194)
UPDATE imported_classes
   SET markdown = replace(markdown, 'race_restrictions:
  only: ["none"]
  note: "The entry prints no racial line. Its unit roster (printed 194) is humans, Psi-Stalkers and Dog Pack only: non-psychic humans, human sensitives, and human Eruptors, Dominators, Mind Melters and Nullifiers. Psi-Stalkers and Dog Boys are O.C.C.s in this catalog (psi-stalker, dog-boy) rather than races, so they cannot be paired with this class. In Rifts a human character takes no R.C.C., so \"none\" is the human case."
', 'race_restrictions:
  only: ["none", "mutant-psi-stalker", "mutant-dog"]
  note: "The entry prints no racial line. Its unit roster (printed 194) is humans, Psi-Stalkers and Dog Pack only: non-psychic humans; Sensitives, of whom 20% are Psi-Stalkers, 50% Dog Pack and 30% human; and human Eruptors, Dominators, Mind Melters and Nullifiers. In Rifts a human character takes no R.C.C., so \"none\" is the human case; a Psi-Stalker is the mutant-psi-stalker race and a Dog Pack member the mutant-dog race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-net-agent'
   AND instr(markdown, 'race_restrictions:
  only: ["none"]
  note: "The entry prints no racial line. Its unit roster (printed 194) is humans, Psi-Stalkers and Dog Pack only: non-psychic humans, human sensitives, and human Eruptors, Dominators, Mind Melters and Nullifiers. Psi-Stalkers and Dog Boys are O.C.C.s in this catalog (psi-stalker, dog-boy) rather than races, so they cannot be paired with this class. In Rifts a human character takes no R.C.C., so \"none\" is the human case."
') > 0
   AND instr(markdown, 'race_restrictions:
  only: ["none", "mutant-psi-stalker", "mutant-dog"]
  note: "The entry prints no racial line. Its unit roster (printed 194) is humans, Psi-Stalkers and Dog Pack only: non-psychic humans; Sensitives, of whom 20% are Psi-Stalkers, 50% Dog Pack and 30% human; and human Eruptors, Dominators, Mind Melters and Nullifiers. In Rifts a human character takes no R.C.C., so \"none\" is the human case; a Psi-Stalker is the mutant-psi-stalker race and a Dog Pack member the mutant-dog race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
') = 0;

-- psi-slinger: Humans and Psi-Stalkers only (New West printed 100)
UPDATE imported_classes
   SET markdown = replace(markdown, '
source_book: Rifts World Book 14: New West p.98-101
category: occ
', '
source_book: Rifts World Book 14: New West p.98-101
category: occ
race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only (printed 100). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27). Until then this was a prose line citing BOOK-INGEST-AUDIT F51, because the Psi-Stalker was an O.C.C. with no race id to name."
'),
       updated_at = datetime('now')
 WHERE class_id = 'psi-slinger'
   AND instr(markdown, '
source_book: Rifts World Book 14: New West p.98-101
category: occ
') > 0
   AND instr(markdown, '
source_book: Rifts World Book 14: New West p.98-101
category: occ
race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only (printed 100). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27). Until then this was a prose line citing BOOK-INGEST-AUDIT F51, because the Psi-Stalker was an O.C.C. with no race id to name."
') = 0;

-- psi-slinger: the prose line that said this could not be stated (BOOK-INGEST-AUDIT F51)
UPDATE imported_classes
   SET markdown = replace(markdown, '  - "RACIAL RESTRICTION the schema cannot enforce: humans and Psi-Stalkers only. `race_restrictions` matches a race id, and this catalog files the Psi-Stalker as an O.C.C. rather than an R.C.C. - so there is no race id to name. See BOOK-INGEST-AUDIT.md F51."
', ''),
       updated_at = datetime('now')
 WHERE class_id = 'psi-slinger'
   AND instr(markdown, '  - "RACIAL RESTRICTION the schema cannot enforce: humans and Psi-Stalkers only. `race_restrictions` matches a race id, and this catalog files the Psi-Stalker as an O.C.C. rather than an R.C.C. - so there is no race id to name. See BOOK-INGEST-AUDIT.md F51."
') > 0;

-- psycho-stalker: stays a class carrying its own package; the note says why
UPDATE imported_classes
   SET markdown = replace(markdown, '  only: ["none"]
  note: "A Psycho-Stalker is a Juicer Psi-Stalker, and Psi-Stalkers are mutant humans only (RUE p.152). In Rifts a human character takes no R.C.C., so \"none\" is the human case - the same reading the psi-stalker and wild-psi-stalker O.C.C.s already carry. Juicer Uprising p.16-17''s widening does not reach this one: the process here is specifically the Psi-Stalker metabolism, and the book says every earlier attempt on a Psi-Stalker or mutant animal had killed the patient."
', '  only: ["none"]
  note: "A Psycho-Stalker is a Juicer Psi-Stalker, and Psi-Stalkers are mutant humans only (RUE p.152). In Rifts a human character takes no R.C.C., so \"none\" is the human case - the reading the psi-stalker and wild-psi-stalker O.C.C.s carried until the mutant-psi-stalker race existed. It is NOT paired with that race (BOOK-INGEST-AUDIT F110, taken 2026-09-27): the book counts the Psi-Stalker''s physical and saving throw bonuses into this class''s own numbers, and a pairing adds a race''s bonuses to an occupation''s, so they would count twice. Juicer Uprising p.16-17''s widening does not reach this one: the process here is specifically the Psi-Stalker metabolism, and the book says every earlier attempt on a Psi-Stalker or mutant animal had killed the patient."
'),
       updated_at = datetime('now')
 WHERE class_id = 'psycho-stalker'
   AND instr(markdown, '  only: ["none"]
  note: "A Psycho-Stalker is a Juicer Psi-Stalker, and Psi-Stalkers are mutant humans only (RUE p.152). In Rifts a human character takes no R.C.C., so \"none\" is the human case - the same reading the psi-stalker and wild-psi-stalker O.C.C.s already carry. Juicer Uprising p.16-17''s widening does not reach this one: the process here is specifically the Psi-Stalker metabolism, and the book says every earlier attempt on a Psi-Stalker or mutant animal had killed the patient."
') > 0
   AND instr(markdown, '  only: ["none"]
  note: "A Psycho-Stalker is a Juicer Psi-Stalker, and Psi-Stalkers are mutant humans only (RUE p.152). In Rifts a human character takes no R.C.C., so \"none\" is the human case - the reading the psi-stalker and wild-psi-stalker O.C.C.s carried until the mutant-psi-stalker race existed. It is NOT paired with that race (BOOK-INGEST-AUDIT F110, taken 2026-09-27): the book counts the Psi-Stalker''s physical and saving throw bonuses into this class''s own numbers, and a pairing adds a race''s bonuses to an occupation''s, so they would count twice. Juicer Uprising p.16-17''s widening does not reach this one: the process here is specifically the Psi-Stalker metabolism, and the book says every earlier attempt on a Psi-Stalker or mutant animal had killed the patient."
') = 0;

-- seljuk: note named the old block as the mechanism
UPDATE imported_classes
   SET markdown = replace(markdown, '    (2026-09-04). No block is added here anyway, because the rule is already
    enforced from the other side: psi-stalker and wild-psi-stalker both carry
    race_restrictions only: ["none"], so raceAllowedForOcc refuses the pairing
    for every race. A second copy would be a second place to get it wrong.
', '    (2026-09-04). No block is added here anyway, because the rule is already
    enforced from the other side: psi-stalker and wild-psi-stalker take only
    the mutant-psi-stalker race (since BOOK-INGEST-AUDIT F110, 2026-09-27), so
    raceAllowedForOcc refuses a seljuk. A second copy would be a second place
    to get it wrong.
'),
       updated_at = datetime('now')
 WHERE class_id = 'seljuk'
   AND instr(markdown, '    (2026-09-04). No block is added here anyway, because the rule is already
    enforced from the other side: psi-stalker and wild-psi-stalker both carry
    race_restrictions only: ["none"], so raceAllowedForOcc refuses the pairing
    for every race. A second copy would be a second place to get it wrong.
') > 0
   AND instr(markdown, '    (2026-09-04). No block is added here anyway, because the rule is already
    enforced from the other side: psi-stalker and wild-psi-stalker take only
    the mutant-psi-stalker race (since BOOK-INGEST-AUDIT F110, 2026-09-27), so
    raceAllowedForOcc refuses a seljuk. A second copy would be a second place
    to get it wrong.
') = 0;

-- Read back: every occupation names the races it takes, and no split class
-- still carries the racial package.
SELECT class_id,
       instr(markdown, 'mutant-psi-stalker') > 0 AS psi_race,
       instr(markdown, '"mutant-dog"') > 0 AS dog_race,
       instr(markdown, char(10) || 'natural_abilities:') > 0 AS carries_abilities,
       instr(markdown, char(10) || 'attribute_dice:') > 0 AS carries_dice,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes
 WHERE class_id IN ('psi-stalker', 'wild-psi-stalker', 'dog-boy', 'ntset-psi-hound', 'coalition-grunt')
 ORDER BY class_id;
SELECT class_id,
       instr(markdown, 'mutant-psi-stalker') > 0 AS psi_race,
       instr(markdown, '"mutant-dog"') > 0 AS dog_race,
       instr(markdown, 'RACIAL RESTRICTION the schema cannot enforce') > 0 AS old_prose
  FROM imported_classes
 WHERE class_id IN ('ntset-protector', 'psi-net-agent', 'psi-slinger', 'psycho-stalker', 'seljuk')
 ORDER BY class_id;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('~039-f110-psi-stalker-and-dog-races.sql');
