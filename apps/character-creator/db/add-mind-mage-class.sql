-- The Mind Mage P.C.C., Palladium Fantasy main book, printed pp.161-162.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-mind-mage-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-mind-mage-class.sql
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
-- THE MOST POWERFUL PSYCHIC CLASS IN THE BOOK, and the progression is where
-- that shows rather than the starting block. Twelve powers at first level is a
-- lot; FIVE MORE AT EVERY LEVEL - two from the lesser categories plus three
-- from Super - is what makes it outgrow everything else.
--
-- "THREE FROM EACH OF FOUR CATEGORIES" is the same problem the Psi-Mystic has,
-- at larger scale: the psionics block holds one count against one category
-- list, so powers_starting is 12 with all four categories allowed, and the
-- three-from-each split is a natural ability.
--
-- THE THIRD LEVEL LIMITATION - Mind Wipe, Psi-Sword and Mentally Possess Others
-- cannot be selected until third level - has no shape in the block either and
-- is recorded in both restrictions and natural_abilities. Note the resolution:
-- the book's "possess others" is the catalog's Mentally Possess Others, and its
-- "alter aura (self)" is the catalog's Alter Aura.
--
-- NO SPELLS, NO CIRCLES, NO SYMBOLS, NO POWER WORDS. The Mind Mage carries no
-- `magic` block because it has no magic at all - everything comes from the
-- character.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'mind-mage', 'Mind Mage', 'palladium-fantasy', '---
id: mind-mage
name: Mind Mage
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
ppe_base: "1d6"
starting_money: "150"
bonuses:
  saves: { mind_control: 6, possession: 5, horror_factor: 3 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 3d6x10, +12 per level of experience starting at level one"
  powers: ["Mind Block", "See Aura", "Alter Aura", "Meditation"]
  powers_starting: 12
  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic (+20%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be improved to Expert for the cost of two other skills, or Martial Arts or Assassin (if evil) for three." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", note: "+5%" }
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"], note: "Intelligence +10%, Escape Artist +5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - "Science"
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
natural_abilities:
  - name: "The Twelve Starting Powers"
    description: "Three powers from EACH of the four categories - Healing, Sensitive, Physical and Super - for twelve in total, on top of the four the class grants outright. The psionics block cannot say three-from-each, only twelve from all four, so the split is recorded here."
  - name: "Third Level Limitation"
    description: "Mind Wipe, Psi-Sword and Mentally Possess Others cannot be selected until third level, whatever else the character qualifies for."
  - name: "Additional Psionic Abilities"
    description: "At each level of experience from level two, TWO further powers from any of the three lesser categories plus THREE from the Super category - five new powers a level, which is what makes this the most powerful psychic class in the book."
  - name: "Enhanced I.S.P. Recovery"
    description: "Recovers two I.S.P. per hour even while active, and twelve per hour of meditation or sleep."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "expensive cloak or cape", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 6 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "snuff-box", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements, though a high I.Q. and M.E. of 10 or higher are strongly suggested."
  - "Mind Wipe, Psi-Sword and Mentally Possess Others cannot be selected until third level."
  - "Armour is studded leather (A.R. 13, 38 S.D.C.); most prefer light or magic armour, especially magic clothing, but any type can be worn."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus. The app currently derives 12 for every major-or-better psychic; see extraction_notes."
  - "The Mind Mage casts no spells, works no circles and draws no symbols. Only a mind mage who has dedicated his life to it can use the entire range of psionics with few limitations; even other master psionics do not have the full scope."
  - "The starting dagger is silver-coated; the catalog has no silver Palladium weapon, so the ordinary Daggers and Knives row stands in. The cloak and boots are expensive ones, which the catalog does not price separately."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s - including the Rifts Mind Melter this class most resembles - are already stored; the P.C.C. distinction is in restrictions. MASTER PSIONIC SAVE TARGET: the book says 10 or higher and derive.js returns 12 for anything major or better - an app-level gap affecting every existing master psionic in Rifts too, not something this import changes. powers_starting is 12 with all four categories allowed, because the block cannot express three from each; the split and the five-a-level progression are natural abilities. Alter Aura (self) resolves to the catalog Alter Aura row, and Possess Others to Mentally Possess Others."
---

# Mind Mage

## Lore

The Mind Mage is the most powerful of the psychic classes. No spells, no
circles, no symbols, no power words - everything comes from the character. Many
people have some latent psionic ability; the Mind Mage has unlocked the
innermost secrets of the mind and mastered them, and wields power others only
dream about.

That tends to produce a personality. Most Mind Mages are self-assured, cocky and
arrogant, and even the friendliest has a strong streak of pride and
self-reliance. The selfish and evil ones consider themselves superior to
practitioners of magic and to nearly everybody else. Some are deluded enough to
challenge a dragon or a godling one to one, which - unless the opponent is sick
or inexperienced, or the mage has help waiting - is a foolish thing to do. A
Mind Mage is mortal and rarely the equal of an adult dragon.

They hold practitioners of magic in particular contempt, respectfully, while
happily using magic weapons and items.

## Alignment

Any.

## GM Notes

A Mind Mage makes enemies structurally. Many find it impossible to obey a
church''s laws or accept any man as a spiritual leader, which has made them
enemies of religious organisations; some churches treat psionics as servants of
demons and have accused Mind Mages of being witches. Ordinary people fear them
for the powers of control and manipulation.

Mechanically, watch the progression rather than the starting block. Twelve
powers at first level is a lot, but five more at every level - two from the
lesser categories and three from Super - is what makes this class outgrow
everything else in the book.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'mind-mage');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'mind-mage';
-- Expect 0. The four automatic powers must all resolve.
SELECT 4 - count(*) AS missing_powers FROM psionic_powers
 WHERE name IN ('Mind Block', 'See Aura', 'Alter Aura', 'Meditation');
-- Expect 3. The three the third-level limitation names.
SELECT count(*) AS third_level_locked FROM psionic_powers
 WHERE name IN ('Mind Wipe', 'Psi-Sword', 'Mentally Possess Others');

INSERT INTO data_script_runs (filename) VALUES ('add-mind-mage-class.sql');
