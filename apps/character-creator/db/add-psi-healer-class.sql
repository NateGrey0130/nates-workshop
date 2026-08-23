-- The Psi-Healer P.C.C., Palladium Fantasy main book, printed pp.158-159.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-psi-healer-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-psi-healer-class.sql
--
-- Read with scripts/read-columns.py. One of the book's four psychic classes,
-- alongside add-psychic-sensitive-class.sql, add-psi-healer-class.sql,
-- add-psi-mystic-class.sql and add-mind-mage-class.sql.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- A P.C.C., NOT AN O.C.C. The schema's `category` takes only rcc and occ, and
-- the Rifts P.C.C.s already in the catalog - Mind Melter, Burster, Psi-Stalker
-- - are all stored as occ. This follows, and the distinction is recorded in
-- restrictions where a reader sees it, along with the book's "Multiple O.C.C.s
-- are not possible".
--
-- THE MASTER PSIONIC SAVE TARGET IS WRONG IN THE APP, and it is not this
-- batch's to fix. This class is a master psionic, and the Palladium Fantasy
-- main book (printed p48) says a master psionic saves against psionic attack on
-- a 10 or higher. Rifts Ultimate Edition agrees, printed p142. js/derive.js has
-- PSIONIC_SAVE_BASE 15 and PSIONIC_SAVE_STRONG 12, and psionicSaveTarget()
-- returns STRONG for anything major or better - so major and master collapse to
-- 12 and no character has ever been given the master's 10. Correcting it
-- touches every existing master psionic in Rifts too and changes a number on
-- sheets that already exist, so it is recorded in restrictions on all four of
-- these classes rather than changed inside a class import.
--
-- NINE NAMED POWERS AND NOTHING TO CHOOSE AT FIRST LEVEL, which is unusual -
-- every other psychic class here picks something. All nine resolve to catalog
-- rows exactly. The per-level pick from Healing or Physical has no schedule
-- field in the psionics block and is recorded in natural_abilities.
--
-- THE +12% TO SAVE VS COMA is the coma_death_pct key, which is a percentage
-- rather than a die roll - the one save in derive.js that works that way.
--
-- TWO MUNDANE ROWS RECLASSIFIED for this kit: first-aid-kit and
-- bandages-6-foot-1-8-m-roll, from rifts to both. Bandages are not technology.
-- Same trigger as the seven rows in #200, the two in #201 and the garlic in
-- #206. Not catalogued anywhere and left in restrictions instead: a pouch of
-- six surgical knives, cooking utensils, and the six inch wooden cross.

-- ---- the two catalog rows this class needs --------------------------------
UPDATE gear SET system = 'both'
 WHERE system = 'rifts' AND slug IN ('first-aid-kit', 'bandages-6-foot-1-8-m-roll');

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'psi-healer', 'Psi-Healer', 'palladium-fantasy', '---
id: psi-healer
name: Psi-Healer
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
ppe_base: "2d6"
starting_money: "300"
bonuses:
  saves: { mind_control: 4, toxins_poisons: 4, possession: 7, horror_factor: 2, coma_death_pct: 12 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d6x10, +10 per level of experience starting at level one"
  powers: ["Deaden Pain", "Exorcism", "Healing Touch", "Increased Healing", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "See Aura", "Empathy"]
  categories_allowed: ["Healing", "Physical"]
skills:
  occ_skills:
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Biology", base: 45, per_level: 5, note: "+15%" }
    - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 35, per_level: 5, note: "+10%" }
    - { name: "Preserve Food", base: 35, per_level: 5, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Math: Basic (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Domestic", note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two, Martial Arts or Assassin (if evil) three. The class grants no fighting style of its own." }
      - "Rogue"
      - { name: "Science", note: "+10%" }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - name: "Additional Psionic Abilities"
    description: "One further power from either the Healing or the Physical category at each level of experience, starting at level two."
  - name: "Standing in the World"
    description: "The most respected and honoured of the psionic P.C.C.s, even the ones who charge outrageously. Many believe them holy men endowed by the gods, which is especially true among the canine races, where a Psi-Healer may become tribal shaman, leader or advisor. Even hostile non-humans have been known to enlist a healer''s aid regardless of race, or let one pass through their territory unmolested along with his companions - they may need him later, and if he is holy they would rather not anger his god. Brigands who do not care will still rob and kill one, and some monster-race bands capture and enslave healers outright."
  - name: "Fees"
    description: "Typically 50 to 100 gold per healing touch, the same for a psychic diagnosis, and 1000 gold or more for psychic surgery. Privileges, promises, information, equipment, magic or an exchange of services are all accepted in lieu of cash. The healer sets the fee, and the most self-serving set it by the apparent wealth and desperation of whoever is asking."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 6 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "frying-pan", qty: 1 }
  - { item_id: "vial-glass-2-ounce", qty: "2d4" }
  - { item_id: "bandages-6-foot-1-8-m-roll", qty: 3 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "food-rations", qty: "1d4+1" }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "snuff-box", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements beyond having psionic powers, though a high I.Q. and M.E. are strongly recommended."
  - "The character starts with NO hand to hand skill. Basic costs one related skill, Expert two, Martial Arts or Assassin (if evil) three."
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Starting weapons are basic S.D.C. weapons of fair to good quality."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus. The app currently derives 12 for every major-or-better psychic; see extraction_notes."
  - "The kit also lists a small pouch with six surgical knives (each 1D4 damage if used as a weapon), cooking utensils, and a six inch (0.15 m) wooden cross. The catalog prices none of the three; the large silver cross stands in for the last."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s are already stored; the P.C.C. distinction is in restrictions. MASTER PSIONIC SAVE TARGET: the book says 10 or higher and derive.js returns 12 for anything major or better - an app-level gap affecting every existing master psionic in Rifts too, not something this import changes. All nine starting powers resolve to catalog rows exactly. The per-level pick from Healing or Physical is recorded as a natural ability because the psionics block has no per-level schedule. The +12% to save vs coma is the coma_death_pct save key, which is a percentage rather than a die roll. First Aid Kit and the bandage roll are reclassified from rifts to both by this batch."
---

# Psi-Healer

## Lore

The healer can come from any background, position, religion or faith. The
ability comes from a strong empathy with others plus psionic power, and it is
the most respected and honoured of the psychic classes.

Healers wander from town to village selling their services. Some settle and
establish a practice; some join adventuring parties and keep moving. Some live
as hermits or druids, dress poorly, and heal the needy for a morsel of food, a
night''s lodging, a few coins, a favour, or a smile. Others wear fine silks and
smell of money - usually anarchist or evil characters who rarely heal anyone
without profit in it, and who end up in a king''s court or running their own
clinic.

Whichever kind, being a healer is a form of safe conduct. Hostile non-humans
have been known to let one pass through their territory untouched, companions
included, on the reasoning that they may need him one day and that angering a
holy man''s god is bad business.

## Alignment

Any.

## GM Notes

The fee schedule is worth using: 50 to 100 gold a healing touch, the same for a
diagnosis, and 1000 or more for psychic surgery, with privileges, information,
equipment or magic accepted instead of coin. The healer sets the price, and the
self-serving set it by how rich and how desperate the patient looks.

The other side of the safe conduct is capture. Some tribes and bands of the
monster races will not kill a Psi-Healer - they will enslave one and keep him.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'psi-healer');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'psi-healer';
-- Expect 0. All nine automatic powers must resolve.
SELECT 9 - count(*) AS missing_powers FROM psionic_powers
 WHERE name IN ('Deaden Pain', 'Exorcism', 'Healing Touch', 'Increased Healing',
                'Psychic Diagnosis', 'Psychic Purification', 'Psychic Surgery',
                'See Aura', 'Empathy');
-- Expect 2. Both medical rows are visible to a Palladium campaign.
SELECT count(*) AS cross_system_medical FROM gear
 WHERE system = 'both' AND slug IN ('first-aid-kit', 'bandages-6-foot-1-8-m-roll');

INSERT INTO data_script_runs (filename) VALUES ('add-psi-healer-class.sql');
