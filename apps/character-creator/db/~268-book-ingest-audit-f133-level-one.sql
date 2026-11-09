-- Fold the level-one I.S.P. increment into five classes' base roll
-- 5 classes, each replaced whole: mind-mage, psi-healer, psi-mystic, psychic-sensitive, quorian-oneiromancer.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~268-book-ingest-audit-f133-level-one.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT F133, residue: five classes write their I.S.P. as a roll plus
-- a flat amount "per level of experience starting at level one" (mind-mage +12,
-- psi-healer, psi-mystic, psychic-sensitive and quorian-oneiromancer +10). The
-- wizard rolled the base alone at level one and perLevelDiceOf reads the gain
-- from level two on, so the increment the book grants AT level one was never
-- added. The reading taken (2026-11-09, on Nate's authorisation of the same day):
-- a first-level character already holds one increment, so it is folded into the
-- level-one roll (3d6x10+12, 2d6x10+10, 2d4x10+10) and the per-level phrase stays
-- as written, so level two on is unchanged. Data only; js/leveling.js does not
-- move. A saved character is not back-filled.

-- == mind-mage ==
UPDATE imported_classes
   SET markdown = '---
id: mind-mage
men_of_arms: false
occ_group: psychic
xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]
name: Mind Mage
system: palladium-fantasy
source_book: palladium-fantasy-core p.161-163
category: occ
tags: []
ppe_base: "1d6"
starting_money: "150"
bonuses:
  saves: { mind_control: 6, possession: 5, horror_factor: 3 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 3d6x10+12, +12 per level of experience starting at level one"
  powers: ["Mind Block", "See Aura", "Alter Aura", "Meditation"]
  powers_starting: 12
  # Three from EACH of the four, which is the book''s own wording. The flat
  # count over all four let a Mind Mage take twelve Super powers.
  powers_starting_groups:
    - { count: 3, categories: ["Healing"] }
    - { count: 3, categories: ["Sensitive"] }
    - { count: 3, categories: ["Physical"] }
    - { count: 3, categories: ["Super"] }
  categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]
  powers_schedule:
    - { level: 2, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 2, count: 3, categories: ["Super"], note: "Mind Wipe, Psi-Sword and Mentally Possess Others cannot be selected until third level." }
    - { level: 3, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 3, count: 3, categories: ["Super"] }
    - { level: 4, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 4, count: 3, categories: ["Super"] }
    - { level: 5, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 5, count: 3, categories: ["Super"] }
    - { level: 6, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 6, count: 3, categories: ["Super"] }
    - { level: 7, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 7, count: 3, categories: ["Super"] }
    - { level: 8, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 8, count: 3, categories: ["Super"] }
    - { level: 9, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 9, count: 3, categories: ["Super"] }
    - { level: 10, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 10, count: 3, categories: ["Super"] }
    - { level: 11, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 11, count: 3, categories: ["Super"] }
    - { level: 12, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 12, count: 3, categories: ["Super"] }
    - { level: 13, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 13, count: 3, categories: ["Super"] }
    - { level: 14, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 14, count: 3, categories: ["Super"] }
    - { level: 15, count: 2, categories: ["Healing", "Sensitive", "Physical"] }
    - { level: 15, count: 3, categories: ["Super"] }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic (+20%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be improved to Expert for the cost of two other skills, or Martial Arts or Assassin (if evil) for three." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5, note: "+5%" }
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence"], bonus: 10, note: "Intelligence +10%." }
      - { name: "Espionage", only: ["Escape Artist"], bonus: 5, note: "Escape Artist +5%." }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - "Science"
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
natural_abilities:
  - name: "The Twelve Starting Powers"
    description: "Three powers from EACH of the four categories - Healing, Sensitive, Physical and Super - for twelve in total, on top of the four the class grants outright. The psionics block states the split directly now, as four powers_starting_groups entries (class audit S9), so this paragraph is the book''s own wording rather than the only place the rule lives."
  - name: "Third Level Limitation"
    description: "Mind Wipe, Psi-Sword and Mentally Possess Others cannot be selected until third level, whatever else the character qualifies for."
  - name: "Additional Psionic Abilities"
    description: "At each level of experience from level two, TWO further powers from any of the three lesser categories plus THREE from the Super category - five new powers a level, which is what makes this the most powerful psychic class in the book. The psionics block states this as a powers_schedule now - two entries at every level from 2 to 15 - so the Advancement step offers the picks rather than leaving them to be read here."
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
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus."
  - "The Mind Mage casts no spells, works no circles and draws no symbols. Only a mind mage who has dedicated his life to it can use the entire range of psionics with few limitations; even other master psionics do not have the full scope."
  - "The starting dagger is silver-coated; the catalog has no silver Palladium weapon, so the ordinary Daggers and Knives row stands in. The cloak and boots are expensive ones, which the catalog does not price separately."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s - including the Rifts Mind Melter this class most resembles - are already stored; the P.C.C. distinction is in restrictions. MASTER PSIONIC SAVE TARGET: 10 or higher, which the app now derives correctly - the psionic save table was three tiers all along and derive.js only had two. powers_starting is 12, the TOTAL, and powers_starting_groups states the three-from-each split the book prints (class audit S9); before it the block held one open count over all four categories, so a Mind Mage could legally take twelve Super powers. The five-a-level progression from level two - two from the lesser categories plus three from Super - is DATA now: powers_schedule holds two entries at every level from 2 to 15, the three lesser categories in the first slot and Super in the second, because a grant carries its own restriction and one open count of five would let a Mind Mage take five Super powers a level. The level-two Super entry carries the book''s third-level limitation as its grant note, which is the only place the app can state it: a schedule entry gates by category, not by power name. Alter Aura (self) resolves to the catalog Alter Aura row, and Possess Others to Mentally Possess Others. I.S.P. base: the book''s +12 per level starting at level one is read as an increment a first-level character already holds, so it is folded into the level-one roll (3d6x10+12) and level two on gains +12 as before (BOOK-INGEST-AUDIT F133, residue taken 2026-11-09)."
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
',
       updated_at = datetime('now')
 WHERE class_id = 'mind-mage'
   AND instr(markdown, 'isp_base: "the M.E. attribute number plus 3d6x10, +12 per level of experience starting at level one"') > 0
   AND length(markdown) = 11644;

-- == psi-healer ==
UPDATE imported_classes
   SET markdown = '---
id: psi-healer
men_of_arms: false
occ_group: psychic
xp_table: [0, 2061, 4121, 8241, 15101, 23101, 33101, 48201, 68301, 93401, 133501, 175601, 223701, 273801, 325901]
name: Psi-Healer
system: palladium-fantasy
source_book: palladium-fantasy-core p.158-159
category: occ
tags: [healer]
ppe_base: "2d6"
starting_money: "300"
bonuses:
  saves: { mind_control: 4, toxins_poisons: 4, disease: 4, possession: 7, horror_factor: 2, coma_death_pct: 12 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d6x10+10, +10 per level of experience starting at level one"
  powers: ["Deaden Pain", "Exorcism", "Healing Touch", "Increased Healing", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "See Aura", "Empathy"]
  categories_allowed: ["Healing", "Physical"]
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
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
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", bonus: 10, note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two, Martial Arts or Assassin (if evil) three. The class grants no fighting style of its own." }
      - "Rogue"
      - { name: "Science", bonus: 10, note: "+10%" }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
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
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus."
  - "The kit also lists a small pouch with six surgical knives (each 1D4 damage if used as a weapon), cooking utensils, and a six inch (0.15 m) wooden cross. The catalog prices none of the three; the large silver cross stands in for the last."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s are already stored; the P.C.C. distinction is in restrictions. MASTER PSIONIC SAVE TARGET: 10 or higher, which the app now derives correctly - the psionic save table was three tiers all along and derive.js only had two. All nine starting powers resolve to catalog rows exactly. The per-level pick from Healing or Physical is recorded as a natural ability because the psionics block has no per-level schedule. The +12% to save vs coma is the coma_death_pct save key, which is a percentage rather than a die roll. First Aid Kit and the bandage roll are reclassified from rifts to both by this batch. I.S.P. base: the book''s +10 per level starting at level one is read as an increment a first-level character already holds, so it is folded into the level-one roll (2d6x10+10) and level two on gains +10 as before (BOOK-INGEST-AUDIT F133, residue taken 2026-11-09)."
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
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-healer'
   AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d6x10, +10 per level of experience starting at level one"') > 0
   AND length(markdown) = 9044;

-- == psi-mystic ==
UPDATE imported_classes
   SET markdown = '---
id: psi-mystic
men_of_arms: false
occ_group: psychic
xp_table: [0, 2101, 4201, 8441, 17481, 25501, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 290201, 350401]
name: Psi-Mystic
system: palladium-fantasy
source_book: palladium-fantasy-core p.160-160
category: occ
tags: []
ppe_base: "1d6x10 plus the P.E. attribute number, +2d6 per level of experience"
starting_money: "120"
bonuses:
  saves: { mind_control: 2, possession: 4, horror_factor: 2 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d4x10+10, +10 per level of experience starting at level one"
  powers: ["Exorcism", "Sense Evil", "Sixth Sense", "Meditation", "Mind Block"]
  powers_starting: 5
  # PF "Powers of the Psi-Mystic" item 1: "three powers from the sensitive
  # category and two from either the physical or healing category."
  # powers_starting stays the TOTAL; the groups split it. RETRO-AUDIT R11.
  powers_starting_groups:
    - { count: 3, categories: ["Sensitive"] }
    - { count: 2, categories: ["Physical", "Healing"] }
  categories_allowed: ["Sensitive", "Physical", "Healing"]
magic:
  type: "intuitive"
  spells_starting: 6
  spell_levels_allowed: [1, 2]
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Dowsing", base: 25, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic (+20%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be improved to Expert for the cost of two other skills, or Martial Arts or Assassin (if evil) for three." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
natural_abilities:
  - name: "Intuitive Magic"
    description: "The Psi-Mystic does not study magic and cannot be taught it. Before setting out to explore the world the character enters a meditative trance lasting six days and comes out of it intuitively knowing six spells, whose nature typically reflects his alignment and view of life. They are permanent and cannot be changed. At each new level of experience - a new metaphysical plateau, which the character simply senses - he finds time to meditate and comes away with two more spells from any level up to his own. A Psi-Mystic can never learn a spell any other way."
  - name: "Additional Psionic Abilities"
    description: "One further power from the Sensitive or Physical categories at levels 3, 5, 7, 9, 11, 13 and 15."
  - name: "Drawing on Ambient P.P.E."
    description: "Like a wizard, the Psi-Mystic can draw on the ambient P.P.E. of ley lines and on blood sacrifices."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cloak or cape", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements, though a high I.Q. and M.A. of 10 or higher are strongly suggested."
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). Most prefer light or magic armour and CANNOT wear a full suit of plate - too psychologically confining and too reliant on technology."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus."
  - "Most Psi-Mystics disregard formal education, believing that too much of it walls off the natural psychic emanations. They avoid cities, gizmos and accumulating possessions, other than things that uplift the spirit - art, musical instruments, books."
  - "The starting dagger is silver-coated; the catalog has no silver Palladium weapon, so the ordinary Daggers and Knives row stands in. A hair comb is in the kit and has no catalog row."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s are already stored; the P.C.C. distinction is in restrictions. MASTER PSIONIC SAVE TARGET: 10 or higher, which the app now derives correctly - the psionic save table was three tiers all along and derive.js only had two. The five automatic powers resolve exactly; powers_starting is 5 for the three Sensitive plus two Physical-or-Healing the book grants at first level, and categories_allowed keeps all three as the union, and powers_starting_groups says the split - three Sensitive, two Physical-or-Healing. This note said the block could not until RETRO-AUDIT R11 (2026-09-04); the key landed with CLASS-AUDIT S9. The intuitive magic IS a real selection and gets a magic block - six spells from levels 1-2 at first level, two per level thereafter from any level up to the character''s own - with the meditation flavour and the never-learns-any-other-way rule in a natural ability beside it. I.S.P. base: the book''s +10 per level starting at level one is read as an increment a first-level character already holds, so it is folded into the level-one roll (2d4x10+10) and level two on gains +10 as before (BOOK-INGEST-AUDIT F133, residue taken 2026-11-09)."
---

# Psi-Mystic

## Lore

The Psi-Mystic senses things on a psychic, magic and metaphysical level, and
has learned to trust the feeling. They are acclaimed advisors and prophets who
can glimpse the future, and their whole method is to accept suddenly knowing
something rather than working it out.

That shapes how they live. Most disregard formal education on the grounds that
too much of it builds walls that block the natural psychic emanations and
deaden a person to the real world. The same suspicion extends to technology and
to owning things: a mystic avoids cities and gadgets and accumulates nothing
except what uplifts the spirit - art, instruments, books.

Magic comes the same way. A Psi-Mystic sits down for a six-day trance and gets
up knowing six spells. He cannot be taught one, cannot buy one, and cannot
learn one from a scroll. Every new spell arrives at a new plateau in life, by
meditating on it.

## Alignment

Any.

## GM Notes

Someone will eventually try to hand a Psi-Mystic a spell book. It does not
work, and it is not a rules technicality - the character''s entire relationship
with magic is that it arrives unbidden. The same goes for plate armour, which
the book rules out on grounds of psychology rather than encumbrance.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-mystic'
   AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"') > 0
   AND length(markdown) = 8757;

-- == psychic-sensitive ==
UPDATE imported_classes
   SET markdown = '---
id: psychic-sensitive
men_of_arms: false
occ_group: psychic
xp_table: [0, 2061, 4121, 8241, 15101, 23101, 33101, 48201, 68301, 93401, 133501, 175601, 223701, 273801, 325901]
name: Psychic Sensitive
system: palladium-fantasy
source_book: palladium-fantasy-core p.156-157
category: occ
tags: []
ppe_base: "2d6"
starting_money: "200"
bonuses:
  saves: { mind_control: 3, possession: 5, horror_factor: 2 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d4x10+10, +10 per level of experience starting at level one"
  powers: ["See Aura", "Sense Evil", "Presence Sense", "Meditation"]
  powers_starting: 6
  categories_allowed: ["Sensitive"]
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Dowsing", base: 35, per_level: 5, note: "+15%" }
    - { name: "Streetwise", base: 26, per_level: 4, note: "+6%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { choose: 2, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 10, note: "Two lores of choice (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
  occ_related_skills:
    count: 9
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence", "Escape Artist"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two, Martial Arts or Assassin (if evil) three. The class grants no fighting style of its own." }
      - "Rogue"
      - { name: "Science", note: "+10% on Mathematics skills only" }
      - { name: "Science", only_prefix: ["Mathematics"], bonus: 10, note: "+10% on Mathematics skills only." }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
natural_abilities:
  - name: "Sense Magic and Psionic Energy"
    description: "Senses magic and psionic energy being expended. When the energy is continually expended - a series of attacks or a long-duration effect - the source can be pinpointed to within 20 feet (6 m). Base skill 30% +5% per level, rolled once per melee round; -10% where other P.P.E. sources confuse the sensation. Range 200 feet (61 m) +50 feet (15.2 m) per level. Automatic and constant, no I.S.P. Proximity to a ley line within two miles (3.2 km) halves it and a nexus within four miles (6.4 km) obliterates it - but the psychic can sense ley lines and nexus points themselves up to two miles off."
  - name: "Sense Supernatural Beings"
    description: "Like a bloodhound on a familiar scent. Detects gods, godlings, greater elementals, greater demons and deevils, dragons, and practitioners of magic of 10th level or higher. Base skill 30% +5% per level, +10% face to face even if the creature is disguised; identifying the nature of the being by scent alone, and tracking by psychic scent, both work at HALF the current skill. Range 50 feet (15 m) per level for a being not using its powers, and 1000 feet (305 m) +100 feet (30.5 m) per level for magic or psionics actually being expended. Ley lines and nexus points interfere exactly as above."
  - name: "Additional Psionic Abilities"
    description: "One further Sensitive power at each level of experience from level two. Alternatively, at levels 3, 6, 9, 12 and 15 the character may take one Physical power or one Super psionic instead - and the Super list is limited to Empathic Transmission, Group Mind Block, Hypnotic Suggestion, Mind Block Auto-Defense, Mind Bolt, Mind Bond and Telemechanics."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4+1" }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements beyond having psionic powers, though a high I.Q. and M.E. are strongly recommended."
  - "The character starts with NO hand to hand skill. Basic costs one related skill, Expert two, Martial Arts or Assassin (if evil) three."
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). Starting weapons are basic S.D.C. weapons of fair to good quality."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus."
  - "The starting dagger is silver-coated and the cross is a small silver one; the catalog prices neither, so the ordinary Daggers and Knives row and the large silver cross stand in."
extraction_notes: "Stored with category: occ because the schema has only rcc and occ, which is how the Rifts P.C.C.s - Mind Melter, Burster, Psi-Stalker - are already stored. The P.C.C. distinction is recorded in restrictions instead. MASTER PSIONIC SAVE TARGET: 10 or higher, which the app now derives correctly - the psionic save table was three tiers all along and derive.js only had two. The two sensing abilities are percentile powers with no catalog row and no I.S.P. cost, so they are natural_abilities. The per-level alternative - a Super psionic from a list of seven instead of a Sensitive power, at levels 3, 6, 9, 12 and 15 - has no shape in the psionics block and is recorded in the same place. I.S.P. base: the book''s +10 per level starting at level one is read as an increment a first-level character already holds, so it is folded into the level-one roll (2d4x10+10) and level two on gains +10 as before (BOOK-INGEST-AUDIT F133, residue taken 2026-11-09)."
---

# Psychic Sensitive

## Lore

The Psychic Sensitive feels magic happening. Energy being spent - a spell woven,
a psionic attack pressed - registers the way a sound does, and with enough of it
the sensitive can point at where it is coming from. The same sense picks out
gods, godlings, greater elementals, greater demons and deevils, dragons and
high-level practitioners of magic, by something the book describes as scent.

Both abilities are automatic, constant and free. They also fail near ley lines:
within two miles the sense is halved, and within four miles of a nexus it is
gone entirely. What the sensitive can do near a ley line is feel the line
itself.

## Alignment

Any.

## GM Notes

This is the psychic who notices. A party with a Psychic Sensitive gets warning
that something supernatural is nearby, that a spell is being cast somewhere out
of sight, and roughly where. A party near a nexus gets none of it, which is a
usable piece of adventure design: the closer they get to the place where the
magic is strongest, the less their early-warning system tells them.
',
       updated_at = datetime('now')
 WHERE class_id = 'psychic-sensitive'
   AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"') > 0
   AND length(markdown) = 8865;

-- == quorian-oneiromancer ==
UPDATE imported_classes
   SET markdown = '---
id: quorian-oneiromancer
men_of_arms: false
occ_group: psychic
xp_table: [0, 2131, 4261, 8581, 17161, 24911, 34191, 49291, 67391, 93491, 131591, 182691, 225791, 272891, 333191]
name: Quorian Oneiromancer
system: palladium-fantasy
source_book: Palladium Fantasy RPG Book 9: The Baalgor Wastelands p.57
copy_of: { class: "psi-mystic", except: ["psionics", "magic", "natural_abilities", "race_restrictions", "xp_table", "overrides_race"] }
race_restrictions:
  only: ["quorian"]
  note: "A Quorian class: the book prints it inside the Quorian entry, as the dream shaman of that people."
overrides_race: [ppe_base]
category: occ
tags: [divine, leader]
ppe_base: "1d6x10 plus the P.E. attribute number, +2d6 per level of experience"
starting_money: "120"
bonuses:
  saves: { mind_control: 2, possession: 4, horror_factor: 2 }
psionics:
  type: "master"
  isp_base: "the M.E. attribute number plus 2d4x10+10, +10 per level of experience starting at level one"
  powers: ["Mind Block", "Clairvoyance", "Sixth Sense", "Meditation"]
  powers_starting: 4
  powers_starting_groups:
    - { count: 4, categories: ["Sensitive"], note: "Four from the Sensitive category ONLY." }
  categories_allowed: ["Sensitive", "Healing", "Physical"]
  powers_per_level: 1
magic:
  type: "intuitive"
  spells_starting: 4
  spell_levels_allowed: [1, 2]
  spells_per_level: 2
  spells_per_level_levels: up_to_character_level
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Dowsing", base: 25, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic (+20%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be improved to Expert for the cost of two other skills, or Martial Arts or Assassin (if evil) for three." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", note: "+10% on Lore, Language and Literacy only" }
      - { name: "Technical", only_prefix: ["Lore", "Language", "Literacy"], bonus: 10, note: "+10% on Lore, Language and Literacy only." }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
natural_abilities:
  - name: "Psionics of the Oneiromancer"
    description: "Starts with Mind Block, Clairvoyance, Sixth Sense and Meditation, plus four powers from the Sensitive category only. Each new level of experience brings one more power from the Healing, Sensitive or Physical categories."
  - name: "Intuitive Magic"
    description: "Magic comes the way a Psi-Mystic''s does, from within and never by study. The Oneiromancer begins with four spells from levels one or two, and at each later level gains two more from any level up to his own (at third level, from levels one, two or three)."
  - name: "Chant of Dreaming"
    description: "The Oneiromancer can perform the shamanistic Chant of Dreaming. For him it costs 20 P.P.E. rather than the usual 40, and his chance of success is 10% better than the chant''s normal one. The chant itself is described in Adventures on the High Seas."
  - name: "Drawing on Ambient P.P.E."
    description: "Like a Psi-Mystic, the Oneiromancer can draw on the ambient P.P.E. of ley lines and on blood sacrifices."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cloak or cape", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "A P.C.C., not an O.C.C.: a Psychic Character Class. Multiple O.C.C.s are NOT possible for this character."
  - "No attribute requirements, though a high I.Q. and M.A. of 10 or higher are strongly suggested."
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). Most prefer light or magic armour and CANNOT wear a full suit of plate - too psychologically confining and too reliant on technology."
  - "As a master psionic the character needs a 10 or higher to save against psionic attack, plus any M.E. bonus."
  - "Most Psi-Mystics disregard formal education, believing that too much of it walls off the natural psychic emanations. They avoid cities, gizmos and accumulating possessions, other than things that uplift the spirit - art, musical instruments, books."
  - "The starting dagger is silver-coated; the catalog has no silver Palladium weapon, so the ordinary Daggers and Knives row stands in. A hair comb is in the kit and has no catalog row."
extraction_notes: |
  - Baalgor Wastelands printed 57 (cache p058), headed "Quorian Oneiromancer R.C.C." inside the Quorian entry; the entry ends on the same page, above the Rock Buzzers. Printed 56 calls it a Racial Character Class a Quorian opts for. Stored as category occ limited to the quorian race by race_restrictions, because it is an occupation a Quorian takes on top of the race, whose attributes, natural abilities and other racial traits the page says are unchanged.
  - The page says the class is "similar to the Psi-Mystic O.C.C., with slightly different powers" and "otherwise ... identical to the Psi-Mystic O.C.C. in all respects, including skill selection and experience point requirements". copy_of psi-mystic (Palladium Fantasy main book p.160) records that: P.P.E., money, saves, skills, equipment and restrictions are that row''s, repeated in full. occ_group is psychic because the Psi-Mystic''s is.
  - What the page changes, and the copy''s except list: psionics (Mind Block, Clairvoyance, Sixth Sense and Meditation plus four from the Sensitive category ONLY, then one power per new level from healing, sensitive or physical), magic (four spells from levels one or two, then two per level from any level up to his own), the natural abilities describing those, and race_restrictions.
  - xp_table is the "Quorian Oneiromancer" column of printed 215: 0-2,130; 2,131-4,260; 4,261-8,580; 8,581-17,160; 17,161-24,910; 24,911-34,190; 34,191-49,290; 49,291-67,390; 67,391-93,490; 93,491-131,590; 131,591-182,690; 182,691-225,790; 225,791-272,890; 272,891-333,190; 333,191-399,690. Printed 57 says the experience requirements are the Psi-Mystic''s, and printed 215 prints this separate column, which is not the Psi-Mystic''s; the column printed under the class''s own name is the one stored.
  - Printed 57 states NONE of these four: the psionic tier (master), the I.S.P. formula, the ability to draw on ambient P.P.E., or the P.P.E. base. All four are the Psi-Mystic''s, taken by the page''s "identical ... in all respects" sentence and by nothing else on the page.
  - overrides_race names ppe_base: the class is limited to one race and is a Psi-Mystic in every respect the page does not change, so its P.P.E. is the Psi-Mystic''s figure; the Quorian page''s 3D6 is headed "Average P.P.E.".
  - Chant of Dreaming: printed 57 says the Oneiromancer can perform it "as described in Adventures on the High Seas" and prints only the two differences, 20 P.P.E. instead of the usual 40 and an additional +10% chance of success. The book is named without a page number, and neither the chant''s text nor its base success chance is printed here. Stored as prose in natural_abilities with those two figures only. The spell row named Chant of Dreaming in the catalog is the Rifts Conversion Book One p.107 printing (system rifts) and is not granted here.
  - No money or equipment line is printed on 57; both are the Psi-Mystic''s under the "identical in all respects" sentence.
  - I.S.P. base: the book''s +10 per level starting at level one is read as an increment a first-level character already holds, so it is folded into the level-one roll (2d4x10+10) and level two on gains +10 as before (BOOK-INGEST-AUDIT F133, residue taken 2026-11-09).
---

# Quorian Oneiromancer

## Lore

The Oneiromancer, or Dream Shaman, is the nearest thing the Quorians have to a priest: the spiritual and psychic heart of a village or wandercamp, and very often its leader. A people who steer their lives by dreams need someone who can read them, and the Oneiromancer does that with psychic gifts, with magic that arrives unbidden, and with a chant that calls a meaningful dream on purpose instead of waiting years for one.

It was Oneiromancers who first reached the sleeping Earthshakers under the hills of the wastelands and came to treat them as slumbering gods holding the answers the Quorians want, the road home among them. The settled villages that stand on those hills exist because of them.

Only a small share of Quorians, around one in ten or fewer, follow this path.

## GM Notes

Mechanically this is a Psi-Mystic with a different opening set of powers: a fixed four plus four Sensitive picks, a new power every level, four starting spells instead of six, and the Chant of Dreaming at half cost with a better chance. Everything else, skills and gear included, is the Psi-Mystic''s.

The readings an Oneiromancer gives are not always right, and are sometimes bent toward what the tribe needs to hear. The full text of the Chant of Dreaming is in Adventures on the High Seas, not in this book.
',
       updated_at = datetime('now')
 WHERE class_id = 'quorian-oneiromancer'
   AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"') > 0
   AND length(markdown) = 11089;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 5 classes carry their new text' AS assertion, count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id = 'mind-mage' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 3d6x10+12, +12 per level of experience starting at level one"') > 0)
    OR (class_id = 'psi-healer' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d6x10+10, +10 per level of experience starting at level one"') > 0)
    OR (class_id = 'psi-mystic' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10+10, +10 per level of experience starting at level one"') > 0)
    OR (class_id = 'psychic-sensitive' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10+10, +10 per level of experience starting at level one"') > 0)
    OR (class_id = 'quorian-oneiromancer' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10+10, +10 per level of experience starting at level one"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'mind-mage' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 3d6x10, +12 per level of experience starting at level one"') > 0)
    OR (class_id = 'psi-healer' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d6x10, +10 per level of experience starting at level one"') > 0)
    OR (class_id = 'psi-mystic' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"') > 0)
    OR (class_id = 'psychic-sensitive' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"') > 0)
    OR (class_id = 'quorian-oneiromancer' AND instr(markdown, 'isp_base: "the M.E. attribute number plus 2d4x10, +10 per level of experience starting at level one"') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('mind-mage', 'psi-healer', 'psi-mystic', 'psychic-sensitive', 'quorian-oneiromancer') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~268-book-ingest-audit-f133-level-one.sql');
