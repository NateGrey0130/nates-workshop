-- The Squire O.C.C., Palladium Fantasy main book, printed p98.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-squire-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-squire-class.sql
--
-- Read with scripts/read-columns.py. Needs no new catalog rows: the squire is
-- the knight's shape at lower bonuses, and every skill and item it grants
-- already exists - including Horsemanship: Knight, which the squire takes
-- WITHOUT the knight's special skills and bonuses. That distinction lives in
-- the skill note, because the catalog row is one row and both classes read it.
--
-- Apply fix-pf-armor-and-cross-system-gear.sql first or alongside: the squire
-- grants clothing, gloves and a riding horse, three rows tagged rifts-only
-- until that script reclassifies them.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- WHAT IS NOT MODELLED, AND WHY IT IS SAID OUT LOUD. The page ends its related
-- skills with "Don't forget about the three family skills" - three more skills
-- from the Knight's family background tables, on top of the five. Nothing in
-- the schema holds a table roll, and inflating the count from five to eight
-- would hide a rule behind a number. The count stays at five and the three
-- extra are stated in restrictions and extraction_notes, where a human reads
-- them.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'squire', 'Squire', 'palladium-fantasy', '---
id: squire
name: Squire
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 7, PS: 8, PP: 10 }
starting_money: "125"
bonuses:
  combat: { pull_punch: 1 }
  saves: { horror_factor: 2 }
skills:
  occ_skills:
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Heraldry", base: 40, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: Knight", base: 40, per_level: 5, note: "40%/30% riding/combat riding, but none of the knight special skills or bonuses." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Literacy", base: 45, per_level: 5, note: "One language of choice, usually native or elf (+15%)" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "W.P. Shield", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of one other skill, or to Martial Arts or Assassin (if evil) for the cost of two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", note: "+10%" }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - { name: "Science", note: "+5%" }
      - { name: "Technical", note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Wilderness Survival", "Track & Trap Animals"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 5, count: 2 }, { level: 10, count: 2 }, { level: 15, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
  - { choose: 1, label: "armour", qty: 1, from: ["chain-mail", "scale-mail"] }
  - { item_id: "small-shield", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 3, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is chain mail (A.R. 14, 44 S.D.C.) or scale mail (A.R. 15, 75 S.D.C.), player choice."
  - "Every starting weapon is a basic S.D.C. weapon of good quality. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The riding horse is of good quality, with 30+2D6 S.D.C., 6D6 hit points, running speed 33, and a value of 1D4x1000 gold."
  - "Family background and the three family skills are rolled on the Knight tables, and those three skills are in addition to the five related skills above."
  - "Squires, knights and palladins are -10% to prowl and -15% to climb or scale walls in full splint or plate, and -5% to prowl or climb in chain or scale mail. No penalty in light armour."
  - "1-65% chance of family and holdings in the homeland: 1D4 relatives who will house and feed the character indefinitely, and may provide a new set of clothing, studded leather armour, a sword and 2D6x10 gold."
extraction_notes: "The three weapons of choice are enumerated as the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category. The three family skills the book adds on top of the related skills are not modelled: the family background tables live on the Knight page and nothing in the schema holds a table roll."
---

# Squire

## Lore

The squire is typically a young nobleman attending a knight. He must know the
rudiments of combat, horsemanship and weapons, and as a nobleman he is educated
and taught courtly etiquette. Some squires go on to become knights, soldiers and
mercenaries; others become lords, administrators, merchants or scholars.
Whatever the character ends up doing, the title stays, and a squire ranks
immediately below a knight: a lesser knight, or a nobleman with knightly
training.

Like the knights they served as youngsters, squires can become champions of the
people, or travel the world looking for adventure and righting wrongs. Most
respect, honour and follow the Code of Chivalry. Their training and skills often
parallel a knight, but they get none of the knight special O.C.C. skills and
bonuses, and their own bonuses differ.

## Alignment

Any. Knighthood and noble birth are not indicative of inner spirit, integrity or
compassion, so there are good and noble squires alongside treacherous,
dishonourable and evil ones.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'squire');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'squire';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('clothing', 'gloves', 'riding-horse', 'chain-mail', 'scale-mail');
SELECT name, base, per_level FROM skills WHERE name = 'Horsemanship: Knight';

INSERT INTO data_script_runs (filename) VALUES ('add-squire-class.sql');
