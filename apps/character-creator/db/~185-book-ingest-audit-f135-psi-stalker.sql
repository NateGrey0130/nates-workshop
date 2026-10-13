-- The Psi-Stalker's Pilot choice is two named skills, each at its own bonus.
-- 1 class, each replaced whole: psi-stalker.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~185-book-ingest-audit-f135-psi-stalker.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
--
-- BOOK-INGEST-AUDIT F135, the data half. RUE printed 154 gives the Civilized
-- Psi-Stalker one Pilot skill: "Pilot: Tanks & APCs (+10%) or Hovercycles
-- (+15%)". The class stored it as any one Pilot skill at +10%, because a choice
-- group held one bonus for the whole group. A from option may now carry its own
-- bonus (#1793), so the group names the two skills and each takes its own:
--
--   Military: Tanks & APCs                  36% + 10 = 46% at level 1
--   Hovercycles, Skycycles & Rocket Bikes   70% + 15 = 85% at level 1
--
-- The line was re-read 2026-10-13 in the OCR cache (cache page 157, printed 154)
-- and agrees with the note the class already carried. Two things move: the group
-- line with its note, and one new extraction_notes entry. wild-psi-stalker and
-- mutant-psi-stalker are not declared copies of this class and are untouched.

-- == psi-stalker ==
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
tags: [combat, wilderness, hunter]
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
    - { choose: 1, from: [{ name: "Military: Tanks & APCs", bonus: 10 }, { name: "Hovercycles, Skycycles & Rocket Bikes", bonus: 15 }], note: "Pilot: Tanks & APCs (+10%) or Hovercycles (+15%), one of the two." }
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
  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
restrictions:
  - "Weapons: one weapon for every W.P., plus 1D6+1 E-Clips (RUE p.155)."
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
  - The Pilot choice (printed 154) is one of two named skills, each at its
    own bonus: Tanks & APCs +10% or Hovercycles +15%. Stored as a from list
    whose options carry their own bonus (BOOK-INGEST-AUDIT F135).
  - Money: 6D6x100 credits + 4D4x1000 in sellable Black Market items for mercs
    and independents; CS Psi-Stalkers get Coalition Grunt pay and benefits.
---

## Lore

Like the Dog Boys, the human mutants known as Psi-Stalkers have won the growing respect and friendship of the human troops they work with. Recognized as skilled Wilderness Scouts and fearless warriors, they have been elevated to the ranks of fellow soldier and equal - at least when it comes to fighting - though they are not nearly as appreciated nor loved as the Dog Boys.

Psi-Stalkers are clearly hairless, human-looking mutants who often paint or tattoo patterns on their face and body, sometimes file their teeth to points, and possess an innate supernatural ability similar to the Dog Pack''s, only "spookier." They are humans transformed by the magic and dimensional energies of the ley lines, mutated during the early decades of the Two Hundred Years Dark Age. They have survived the last few hundred years by attacking beings with high levels of P.P.E. and feeding on their life-giving energies: Psi-Stalkers are **P.P.E. vampires** who sustain themselves on magic energy rather than solid food.

A full 15% of the Coalition Army is composed of Psi-Stalkers. They generally lead Dog Packs or serve in Special Forces teams and special operations, namely those involving practitioners of magic, psychics, monsters and the supernatural. The Coalition''s prejudice against nonhumans means that although Psi-Stalkers are accepted as soldiers and enforcers, they can never achieve the same rank as true humans (Xiticix Invasion p.109: the best rank achievable is Command Sergeant Major, and few rise above Master Sergeant) - which is fine by most, as they are natural hunters who don''t seek any other position in society.

## GM Notes

Psi-Stalkers can make big money as exterminators in areas plagued by supernatural beings, magic or psychics. Coalition Psi-Stalkers get the same benefits and pay as the Coalition Grunt plus hazardous duty pay; those assigned to the ISS make the same as ISS Inspectors, and CS Psi-Officers who lead a Dog Pack are paid as low ranking CS Military Specialists.

For more on Psi-Stalkers see Rifts World Book 13: Lone Star and especially World Book 23: Xiticix Invasion; for those working with the ISS police, see World Book 11: Coalition War Campaign.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-stalker'
   AND instr(markdown, '{ choose: 1, categories: ["Pilot"], bonus: 10,') > 0
   AND length(markdown) = 8012;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'psi-stalker' AND instr(markdown, '{ name: "Hovercycles, Skycycles & Rocket Bikes", bonus: 15 }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'psi-stalker' AND instr(markdown, '{ choose: 1, categories: ["Pilot"], bonus: 10,') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('psi-stalker') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~185-book-ingest-audit-f135-psi-stalker.sql');
