-- BOOK-INGEST-AUDIT F139: seven classes are granted the sack, grenades, utensil kit and horse their kit names, and the Loronoid's camera is not starting kit
-- 7 classes, each replaced whole: symbiotic-warrior, apok, monk, wormwood-priest-of-light, ngr-power-armor-commando, adna-nomad, loronoid.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~198-book-ingest-audit-f139-plain-grants.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == symbiotic-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: symbiotic-warrior
name: Symbiotic Warrior
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.64-65
category: occ
tags: [combat, augmented]
occ_group: men-of-arms
xp_table: [0, 1901, 3701, 7401, 14801, 22101, 31201, 41301, 54401, 75501, 105601, 140701, 190801, 240901, 292001]
mdc_base: "30, plus 1d6 per level of experience"
ppe_base: "1d4x10, plus 1d6 per level of experience"
bonuses:
  attributes: { ME: -1, Spd: "-1d4" }
  combat: { initiative: 1, pull_punch: 1, roll: 1 }
  saves: { horror_factor: 2, possession: 1 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "98%" }
    - { name: "First Aid", base: 50, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 45, per_level: 4, note: "+5%; the book grants all riding animals in general" }
    - { name: "W.P. Targeting" }
    - { name: "W.P. Knife" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Three of choice" }
    - { name: "Hand to Hand: Expert", note: "Hand to Hand: Assassin instead, if the character is of an evil alignment." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", bonus: 5 }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Locate Home Town", "Ride Giant Parasites"]
equipment_starting:
  - { choose: 1, label: "hooded cloak or cape", qty: 1, from: ["hooded-cloak", "cape"] }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "sack-medium", qty: 1, note: "One medium size sack." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "100 feet. The book prints (15 m), which is the metric figure for FIFTY feet; its other three warrior O.C.C.s print 100 feet (30.5 m)." }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "Symbiotic Organisms"
    description: "The symbiotic warrior starts with one claw, one crawler, one star and one worm, each of his choice, and adds one more symbiote at levels 2, 4, 6, 8, 10 and 12. He may also acquire and use symbiotic stones and crystals, the spirit of Wormwood, worms of blood, worms of mending, and the potions and ointments made from magic slime."
  - name: "Horror Factor 10"
    description: "The symbiotic warrior has a horror factor of 10 and may frighten humans and monsters alike."
level_progression:
  - { level: 2, grants: ["One additional symbiotic organism"] }
  - { level: 4, grants: ["One additional symbiotic organism"] }
  - { level: 6, grants: ["One additional symbiotic organism"] }
  - { level: 8, grants: ["One additional symbiotic organism"] }
  - { level: 10, grants: ["One additional symbiotic organism"] }
  - { level: 12, grants: ["One additional symbiotic organism"] }
restrictions: ["Cannot select additional communion abilities as he grows in experience", "Not trained in the art of meditation", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Penalties: -1 M.E. and -1D4 Spd, both applied by the class''s bonuses (Wormwood printed 64)."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. This is a property of the setting, not a failed extraction. || The Standard Equipment line prints 100 feet of rope (15 m; made from angel hair). 100 feet is 30.5 m, and the other three warrior O.C.C.s in this book print 100 feet (30.5 m); the wormspeaker on p.63-64 prints 50 feet (15 m). The metric figure is the book''s own typo, and the FEET figure is transcribed. This script adds the angel-hair-rope catalog row the four warrior O.C.C.s all needed. || Pilot: the book excludes power armor, robots, tanks and spaceships. Only Pilot-category rows can be excluded from a Pilot pick, so tanks is Military: Tanks & APCs (which the catalog files under Pilot) and spaceships are the three Space craft rows. The robot combat rows and the two power armor suits are excluded on the same reading the Juicer Gladiator already uses for the same book phrase."
---

## Lore

A human or D-bee fighter who has given his body over to Wormwood''s symbiotic
organisms and fights with the powers they lend him. As a rule most of his
attributes are average or below - the symbiotes are what make him formidable,
not the man underneath. He is not a priest and not a mage, knows four prayers
and will never learn a fifth, and has never been trained to meditate.

Native humans of Wormwood have adapted to the energies of the living planet and
are mega-damage creatures in P.P.E. rich environments such as Wormwood and
Rifts Earth. In an environment that is not magic rich, the warrior''s M.D.C. is
S.D.C. instead.

Most are anarchist, unprincipled or scrupulous. The symbiotic warrior sits at
the low end of Wormwood''s social scale, and the horror of what rides on his
body is part of why.

## GM Notes

Dark Symbiotic Warriors are employed by the Forces of Darkness. The only real
difference between them and a player character is their black hearts and evil
alignment - the class is otherwise identical, which makes it a ready-made
antagonist.

The horror factor of 10 cuts both ways: it frightens humans as readily as
monsters, and the knights of the Temple and the priests of light look down on
anyone carrying symbiotes at all.
',
       updated_at = datetime('now')
 WHERE class_id = 'symbiotic-warrior'
   AND instr(markdown, 'the class still stores the small sack') > 0
   AND length(markdown) = 6898;

-- == apok ==
UPDATE imported_classes
   SET markdown = '---
id: apok
name: Apok
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.55-59
category: occ
tags: [combat, divine]
occ_group: clergy
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
mdc_base: "40, plus 1d6 per level of experience, plus the mask''s 200"
ppe_base: "1d4x10+20, plus 2d6 per level of experience"
bonuses:
  combat: { attacks: 1, initiative: 1 }
  saves: { spell_magic: 2, disease: 2 }
  attributes: { PS: "2d6", Spd: "3d6" }
  pools: { mdc: 200 }
skills:
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 50, per_level: 5, note: "+25%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 25, per_level: 5, note: "25% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (at 98%)." }
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "at 98%" }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "at 98%" }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%; the book prints Literacy: American" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Blunt" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Three of choice" }
    - { name: "Hand to Hand: Expert" }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Espionage", bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Create Shelter", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Locate Home Town", "Locate Places of Evil", "Repel Symbiotes"]
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites"]
  spells_schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
equipment_starting:
  - { item_id: "hooded-cloak", qty: 2 }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "sack-medium", qty: 1, note: "One medium size sack." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "The Demon Mask"
    description: "A living symbiotic organism created by the living planet and molded by the repentant warrior, worn as a brand rather than a badge. It sticks to the face like magic and cannot be forcibly removed - only the apok himself can take it off. Horror factor 16 to all demons and evildoers of Wormwood including the Unholy, and 10 to characters of good alignment. All the apok''s attacks inflict DOUBLE damage to supernatural beings and creatures of magic - demons, vampires, dragons, alien intelligences - whatever the weapon, so a dagger doing 1D4 does 2D4 and a laser rifle doing 4D6 M.D. does 4D6x2; even S.D.C. weapons inflict mega-damage against supernatural evil in his hands. +1 attack per melee, +1 on initiative, +200 physical M.D.C., and he heals ten times faster than normal. The mask itself is indestructible and radiates magic. It is said that when the Unholy is slain and his minions destroyed or cast off Wormwood, the mask will become powerless and the apok can finally live in peace."
  - name: "Impervious to Horror Factor"
    description: "Always saves. The apok has walked with monsters and stared into the blackness of his own soul and his own potential for evil - there is nothing more frightening."
  - name: "Impervious to Possession and Mind Control"
    description: "All forms. Having seen the depths of his own potential for evil has given the apok an iron will, great determination and an unbreakable spirit."
  - name: "Supernatural Strength and Endurance"
    description: "The strength of the apok''s resolve has given both spirit and body superhuman strength. Add +2D6 to P.S., which is considered SUPERNATURAL, and +3D6 to Spd, plus +2 to save vs poison, disease and all types of magic."
  - name: "Meditation"
    description: "Focusing his thoughts in prayer regains spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and gives the apok the ability to pilot battle saints and battle saint orbs."
  - name: "Invisible to Magic Seeing"
    description: "Constantly on, with no P.P.E. cost. This is a standing exception to the way the prayer normally works."
  - name: "Hell Fire"
    description: "Inflicts 3D4x10 damage when cast by an apok, rather than the prayer''s ordinary damage."
restrictions: ["Never uses any symbiote except the demon mask, the battle saint and the battle saint orb", "Will not draw P.P.E. from other beings and will not engage in blood sacrifice, even of the most foul villain", "May not select summoning magic as a level-up prayer", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Alignment is GOOD ONLY - 40% principled and 60% scrupulous - and the reborn character always starts at first level with all his original O.C.C. skills lost. Impervious to Symbiotes does not exclude the demon mask, the battle saint or the battle saint orb."
extraction_notes: "THE PAGE RANGE IS 55-59, NOT THE SURVEY AND CONTENTS'' 55-58. Printed 56 and 58 are FULL-PAGE ART - the OCR cache holds 16 bytes for p056 and 9 bytes for p058, and neither is text. The Apok''s text runs 55 -> 57 -> 59, and printed 59 is not optional: it carries the SECOND HALF of the O.C.C. related skill category list (Medical through Wilderness), the whole Standard Equipment line, the Weapons, Armor, Transportation, Money, Cybernetics and Symbiotes entries. Reading only 55-58 would have lost a third of the class. Printed 59 also opens the Monk, so the two share it. || Money: Not applicable, read whole on p.59 - the apok are feared, disliked and on the bottom of the social totem-pole. No starting_money is stored. || Attribute bonuses ARE stored, as dice: bonuses.attributes takes a dice expression and rolls it once at creation, so the sheet carries what this character rolled rather than an average the book never prints. This note said the block took flat numbers only, which stopped being true before it was written - RETRO-AUDIT R11, 2026-09-04, and R6 made the same correction on the freelancer. Both are recorded on the Supernatural Strength and Endurance ability; they are also dice in bonuses, which the sheet rolls, so nothing is rolled by hand. The ability text follows the same rule the Freelancer follows for its d100 chart in #355. The P.S. is SUPERNATURAL, which the sheet does not model either. || M.D.C.: 40 plus 1D6 per level from the class and a flat +200 from the mask. The 200 is a pool bonus so that it reads as coming from the mask, which is where the book puts it. || Technical: the book prints Any (+10%; +20% on any language or literacy). The +20% clause is not stored: the catalog files Literacy under Communications, and this class grants NO Communications at all, so half of that clause reaches a category the apok cannot pick from. The languages it can reach are already granted at 98% as O.C.C. skills. || The level-up prayer list excludes summoning magic per p.57, which removes all ten Summon prayers from the 37 - leaving 27."
---

## Lore

The Apok is the most notorious of the Cathedral''s legion of warriors and
protectors: men and women who started life as Champions of Light, fell prey to
greed, hate or envy, and joined the Forces of Darkness. They served the Unholy
for years. Then they saw the light, forsook evil, and dedicated their lives to
eradicating the Unholy and his dark minions from Wormwood.

They have stared into the face of evil and seen their own reflection. They
walked that path and hurt, if not killed, many people. They are truly sorry, and
they are dedicated one hundred percent to the destruction of evil - they cannot
be bribed, tempted or diverted. That same keen eye for recognizing evil is
turned on everyone, which has given them a clear view of the corruption spreading
in the heart of the Cathedral.

Despite their courage and sacrifice they are feared and viewed with great
suspicion. They were evil once, so people fear they may be lured back. The apok
understand and accept this. They do not blame the people for their fear or even
their hate - they betrayed them once and they have earned the distrust. That is
why they wear the demon mask: as a brand, so all may know they were once fallen
champions, and have risen to become the living nightmare of the Forces of
Darkness.

To become an apok, a villain must be truly sorry, one hundred percent committed,
and willing to die for it. He prays, concentrates, and steps into a life vat
cauldron. If he is sincere he emerges 2D4 minutes later reborn as a Champion of
Light - all of his old O.C.C. skills lost, a new experience table begun, his
alignment now principled or scrupulous, and the demon mask in his hand.

## GM Notes

The typical player character starts at level one or two. The average non-player
apok is 1D4+3 level, fewer than 10% are above 7th, and there are estimated to be
fewer than a thousand of them alive.

**The apok is the lowest of the low socially and the most feared thing on the
board.** p.52 puts him at the very bottom of the human hierarchy, below
criminals and traitors, feared more than the dreaded Dark Priests. Inside the
Cathedral''s own hierarchy he sits fifth, above the monks. The Unholy and his
minions hate and fear the apok above all others, because he knows their cities,
their tactics and their dark secrets from the inside.

Some, like the infamous Confessor, have defied orders and even attacked a high
priest after pointing an accusing finger at the evil and selfish among them.
Those have been branded dangerous rogues, heretics or traitors, and are said to
have become servants of evil again. For now the apok turn their attention to the
greater evil.
',
       updated_at = datetime('now')
 WHERE class_id = 'apok'
   AND instr(markdown, 'the class still stores the small sack') > 0
   AND length(markdown) = 11680;

-- == monk ==
UPDATE imported_classes
   SET markdown = '---
id: monk
name: Monk
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.59-62
category: occ
tags: [combat, divine]
occ_group: clergy
xp_table: [0, 2201, 4401, 8801, 17601, 24001, 35001, 50501, 72501, 98501, 140501, 200501, 250501, 300501, 400501]
mdc_base: "1d4x10+30, plus 1d6 per level of experience"
ppe_base: "1d6x10, plus 2d6 per level of experience"
bonuses:
  saves: { horror_factor: 3, possession: 3, spell_magic: 1 }
skills:
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 20, per_level: 5, note: "20% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Demongogian", base: 70, per_level: 5, note: "+20%" }
    - { name: "Literacy: Native Language", base: 45, per_level: 5, note: "+5%; the book prints Literacy American" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "First Aid", base: 65, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Hand to Hand: Martial Arts", note: "The combat techniques an Area of Mastery adds are on its own ability; the skills it grants are in the mos block below." }
  mos:
    choose: 1
    note: "Powers of Mastery, printed 60-61: ''Select only ONE of the three available areas of focus and study.'' These are the ADDITIONAL SKILLS each area grants; its combat techniques, bonuses and superhuman abilities stay on the ability of the same name, because they are not skills. The open weapon-proficiency picks each area grants - two for Defense, four for Offense, two for Meditation - are choice groups over the Weapon Proficiencies category, added by RETRO-AUDIT R10 (2026-09-04). This note said they were not expressible, which was false when R2 wrote it: an MOS option takes the same skill entries occ_skills does, choice groups included. The occ_related_skills block above already excludes Acrobatics, Gymnastics and Boxing from the Physical category, so a monk cannot take one of these twice."
    options:
      - id: "defense"
        name: "The Art of Defense"
        skills:
            - { name: "Gymnastics", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Running", base: 0, per_level: 0, note: "No percentage - a physical skill with no roll." }
            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }
            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two weapon proficiencies of choice from any category." }
      - id: "offense"
        name: "The Arts of Offense"
        skills:
            - { name: "Acrobatics", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Boxing", base: 0, per_level: 0, note: "No percentage - what it grants is bonuses." }
            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }
            - { choose: 4, categories: ["Weapon Proficiencies"], note: "The book: four weapon proficiencies of choice from any category." }
      - id: "meditation"
        name: "The Art of Meditation & Spirit"
        skills:
            - { name: "Art", base: 45, per_level: 5, note: "+10%" }
            - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }
            - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
            - { name: "Concealment", base: 30, per_level: 4, note: "+10%" }
            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two weapon proficiencies of choice from any category." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications" }
      - { name: "Domestic", bonus: 20 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells_starting: 4
  spells_from: ["Close an Opening", "Create an Opening", "Create a Fountain of Water", "Locate Places of Evil", "Locate Food & Resources", "Locate Home Town", "Summon Battle Saints & Orbs", "Invisible to Magic Seeing"]
equipment_starting:
  - { item_id: "hooded-robe", qty: 2, note: "For travelling." }
  - { item_id: "sandals", qty: 1, note: "Sandals or moccasins." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "sack-medium", qty: "1d4", note: "1D4 medium size sacks." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "1D4 weeks of rations." }
special_abilities:
  - name: "Meditation"
    description: "Important for the monk to use his magic powers, his special martial arts powers of mastery, and to pilot battle saints and orbs. Meditation and prayer regain spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and increase healing threefold."
  - choose: 1
    from: ["The Art of Defense", "The Art of Offense", "The Art of Meditation & Spirit"]
    note: "Each monk studies ONE area of focus. It is the single biggest decision on the sheet - it sets his combat techniques, his bonuses, his extra skills and his disposition."
  - name: "The Art of Defense"
    description: "Defensive combat techniques: paired weapons, punch, kick, entangle, multiple attackers and Judo style body flip. Bonuses: +2 to roll with impact, +4 to pull punch, and +2 on initiative ONLY when defending, against -2 on initiative for acts of aggression. Additional skills: Gymnastics, Running, Escape Artist (+10%) and two W.P.s of choice from any category. Powers: (1) AUTOMATIC DODGE - dodge instead of parry without losing a melee action. (2) BODY HARDENING - +2D4x10 M.D.C., impervious to normal fire and cold, half damage from mega-damage fire and cold; the body is like iron and he can block blades, flaming swords and energy weapons bare-handed - it hurts and does damage but does not break the skin. Punches and kicks land like a lead pipe: 2D4 M.D. punch or 2D6 M.D. kick to supernatural monsters, 3D6 or 5D6 S.D.C. to mortals. (3) FAST HANDS - block or parry every attack from multiple attackers simultaneously without using up a melee action. (4) KICK PARRY - block a punch, kick or strike with feet and legs; the parry does no damage. (5) TUMBLE STRIKE - roll or somersault toward an attacker at +3 to dodge anything aimed at him, then bowl into him for normal damage and knock him down, costing him one melee attack and initiative. Disposition: calm, soft spoken and courteous; good natured, friendly, diplomatic, avoids unnecessary violence - and will not tolerate injustice or stand idle while the innocent are hurt."
    bonuses: { combat: { roll: 2, pull_punch: 4 } }
  - name: "The Art of Offense"
    description: "Offensive combat techniques: paired weapons, kick attack, jump kick, leap kick, multiple attackers and simultaneous attack. Bonuses: +2 on initiative, +1 to strike and one additional attack per melee round. Additional skills: Acrobatics, Boxing, W.P. Targeting and FOUR W.P.s of choice from any category. Powers: (1) SPIRIT FIST - a punch, jab or open hand strike inflicting 1D4x10 M.D. to supernatural beings, demons, elementals and creatures of magic including dragons (1D4x10 S.D.C. to non-mega-damage beings); costs two melee attacks. (2) SPIRIT KICK - 1D6x10 M.D. on the same terms, costing two melee attacks, and the kicker automatically loses initiative the following round. (3) SPIRIT LEAP KICK - 3D6x10 M.D., but it must be the character''s FIRST AND ONLY attack of that melee: the leap uses up every attack he had, and after landing he can only parry or dodge. (4) VITAL STRIKE - two melee attacks, and only on a natural unmodified 17-20; a lower roll that still hits does normal damage and burns the two actions anyway. Choose: disarm (weapons fly 1D4x10 feet, victim loses initiative and one action, and the monk gains a temporary horror factor of 12 - a failed save means the opponent surrenders or flees for 1D4 minutes); knock down and stun (victim loses two attacks, initiative and his footing); critical bull''s eye strike (double damage to exactly what he aimed at); or nerve strike (a limb is paralysed for 1D4 melee rounds). Disposition: bold, confident, outspoken, undiplomatic and aggressive; enjoys a challenge and hard labor, flamboyant and courageous, and actively seeks out injustice and cruelty in order to end it."
    bonuses: { combat: { initiative: 2, strike: 1, attacks: 1 } }
  - name: "The Art of Meditation & Spirit"
    description: "Basic combat techniques: punch, kick and Judo style body flip. Bonuses: +2 to roll with impact, +1 to pull punch, +1 on initiative, and recovers 15 P.P.E. per hour of meditation. Additional skills: Art (+10%), Prowl (+10%), Escape Artist (+10%), Palming (+10%), Concealment (+10%), Climbing (+10%) and two W.P.s of choice from any category. ONLY ONE POWER OF MEDITATION CAN BE USED AT A TIME. (1) INNER PHYSICAL STRENGTH - does not fatigue, half damage from heat and cold, +6 to P.S. and Spd, +4 to save vs poison, drugs or disease, +2 vs magic and psionics; three minutes per level, three times per 24 hours. (2) SPIRIT STRENGTH - overcome the penalties of exhaustion, pain, drugs, sickness, injury, insanity, psionics and magic by sheer force of will; while it holds they are completely gone, and when it ends they all return and he may collapse. Three minutes per level, three times per 24 hours. (3) THIRD EYE - see the invisible, sense evil, sense magic, +4 to save vs horror factor, impervious to possession and mind control, and cannot be tempted to act against his alignment or alliances; five minutes per level, three times per 24 hours. (4) DEATH STRIKE - used with great reluctance and it may kill him too. He summons all his physical, spiritual and magic energy (at least 20 P.P.E.), strikes bare-handed or with a kick, and ALWAYS hits for 2D4x100 M.D. or S.D.C. A survivor is paralysed and senseless for 2D4 minutes and afterwards runs at half speed, bonuses and attacks for 1D6x10 minutes. Once per 24 hours. It completely drains him: all P.P.E. gone, no meditative powers for twelve hours, helpless on the ground for 1D4 minutes, barely able to move for ten more (one action per round, speed down 80%, no bonuses, no skills, no attacks), then half of everything for six hours. Disposition: introspective thinkers and debaters with a love for life and art, willing to discuss any philosophy - and at the end of the debate they stand by their beliefs and stand up to any bully or monster."
    bonuses: { combat: { roll: 2, pull_punch: 1, initiative: 1 } }
restrictions: ["Sworn to an oath of poverty", "Has forsaken all political aspirations", "Cannot draw P.P.E. from other beings except by blood sacrifice", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Most monks avoid symbiotes, but may acquire one or two over the years, and will use blood worms and worms of mending. Most wear little or no armor - the heavy and plate types interfere with movement, agility and speed - so chain mail and light armor at 40 M.D.C. with no prowl penalty are the only types considered."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - characters exchange goods and services for other goods and services - so no starting_money is stored. Monks are highly regarded by most communities, especially in demon infested lands. || The Monk SHARES printed 59 with the Apok: the Apok''s O.C.C. block ends in the left column and Monk O.C.C. opens the right, and the monk''s own prayer list starts at the foot of p.59 and finishes at the top of p.60. Both halves were read. || THE AREA OF MASTERY GRANTS SKILLS, AND THE APP GRANTS THEM, as skills.mos. This note said it could not until RETRO-AUDIT R2 (2026-09-04); skills.mos landed in migration 031-character-mos.sql on 2026-08-21. Each of the three areas confers its own skill list - Defense adds Gymnastics, Running, Escape Artist and two W.P.s; Offense adds Acrobatics, Boxing, W.P. Targeting and four W.P.s; Meditation adds Art, Prowl, Escape Artist, Palming, Concealment, Climbing and two W.P.s - and those depend on a choice made at creation. special_abilities carries the descriptions and the flat bonuses, which are not skills and stay there; the SKILLS each area adds are in the mos block and are granted on the pick. They used to be prose and added by hand. This is the one thing in this class the app does not model, and it is deliberate rather than missed. Note that Defense and Offense both grant skills the class''s own related list EXCLUDES (gymnastics, acrobatics, boxing), which is the book granting an exception to its own restriction. || The mastery bonuses that ARE stored are only the unconditional ones. The Art of Defense''s +2 on initiative applies ONLY when defending and carries -2 for acts of aggression, so neither number is stored; the +2 to roll and +4 to pull punch are. || The monk grants NO W.P. of its own - the book says to see the area of Mastery for W.P.s - which is why the O.C.C. skill list ends at Hand to Hand: Martial Arts."
---

## Lore

The monks are a loose knit set of religious communities that splintered away
from the laws and teachings of the Cathedral. Most believe the Cathedral is too
removed from the people and too concerned with material wealth and power, and
that its leaders are bogged down in bureaucracy and politics - a ponderous group
of plotters, too slow to decide anything and too slow to fight monsters.

Wormwood monks are very narrowly focused: destroy all monsters, help the
innocent. To stay in touch with the needs of the people they have taken an oath
of poverty and forsaken all political ambition, and they view those who have such
ambitions with distrust. They are common folk, like the people they protect. When
they are not in combat they work the fields, build, and help healers and
teachers. The typical monk is a hard working laborer as well as a master of hand
to hand combat.

The first ten years of a monk''s training are given entirely to the mastery of
himself and the martial arts; a disciple only becomes a first level monk after
those years. Monasteries are simple, bare bones communities where the young are
cloistered away from the temptations of the world to learn martial arts and
develop inner strength. Many learn to master their inner spirit in ways of
superhuman focus and control, and yet seldom find inner peace, because they are
so driven.

## GM Notes

Monks, along with the apok, recognize the evil and self-serving forces inside the
Cathedral and are not afraid to point them out. They can be extremely
self-righteous and outspoken, and many openly criticize the Cathedral and treat
its priests and Knights of the Temple with sarcasm and little respect. This has
created real animosity - even good priests and knights find a lot of monks
unnecessarily rude, crude and belligerent. A monk will, however, show great
respect and honor toward any knight, priest or fighter who has proven himself in
combat, and many treat the apok like celebrities.

Alignment runs roughly 2% evil, 13% selfish, 20% unprincipled, 40% scrupulous and
25% principled. p.52 places the monk at the top of the middle class, above the
average citizen and the freelance warrior; inside the Cathedral''s own hierarchy
he is sixth, below the apok.

**Pick the area of mastery before anything else.** It determines the monk''s
combat techniques, his skills, his bonuses and even his temperament, and the
three read as three different classes at the table: the Defense monk is an
unkillable bodyguard, the Offense monk deletes supernatural things with his bare
hands at a cost of two attacks apiece, and the Meditation monk is a philosopher
holding a once-a-day 2D4x100 M.D. death sentence he will be helpless for hours
after using.
',
       updated_at = datetime('now')
 WHERE class_id = 'monk'
   AND instr(markdown, 'the class still stores small sacks') > 0
   AND length(markdown) = 17293;

-- == wormwood-priest-of-light ==
UPDATE imported_classes
   SET markdown = '---
id: wormwood-priest-of-light
name: Priest of Light (Wormwood)
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.52-54
category: occ
tags: [healer, divine]
occ_group: clergy
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
mdc_base: "20, plus 1d6 per level of experience"
ppe_base: "1d4x10+50, plus 2d6 per level of experience"
bonuses:
  saves: { horror_factor: 2, possession: 3, spell_magic: 1 }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 35, per_level: 5, note: "35% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Demongogian", base: 70, per_level: 5, note: "+20%" }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%; the book prints Literacy: American" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints Math: Basic" }
    - { name: "First Aid", base: 55, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Blunt" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice" }
    - { name: "Hand to Hand: Basic", note: "May be raised to Hand to Hand: Expert for one O.C.C. related skill, or to Hand to Hand: Martial Arts for two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications" }
      - { name: "Domestic", bonus: 15 }
      - { name: "Espionage" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Rogue" }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Create a Burial Place", "Create a Fountain of Water", "Create an Opening", "Close an Opening", "Life Fuel", "Locate Places of Evil", "Impervious to Symbiotes", "Mold Structures"]
  spells_starting: 1
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites", "Summon & Use Stones & Crystals", "Summon & Use Symbiotes", "Summon Battle Saints & Orbs", "Summon Edible Grubs", "Summon Entities", "Summon Flies", "Summon Wind", "Summon and Command Parasites", "Summon and use Angel Hair", "Summon and use Spirits of Wormwood"]
  spells_schedule: [{ level: 2, count: 1 }, { level: 3, count: 2 }, { level: 4, count: 2 }, { level: 5, count: 1 }, { level: 6, count: 1 }, { level: 7, count: 1 }, { level: 8, count: 1 }, { level: 9, count: 1 }, { level: 10, count: 1 }, { level: 11, count: 1 }, { level: 12, count: 1 }, { level: 13, count: 1 }, { level: 14, count: 1 }, { level: 15, count: 1 }]
equipment_starting:
  - { item_id: "hooded-robe", qty: 2, note: "For travelling." }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "sack-medium", qty: 1, note: "One medium size sack." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "1D4 weeks of rations." }
special_abilities:
  - name: "Meditation"
    description: "The ability to focus one''s thought in prayer is a necessity of life for the priest: WITHOUT IT HE CANNOT USE HIS MAGIC POWERS AT ALL. Meditation and prayer regain spent P.P.E. at ten points per hour, against the four points an hour of ordinary rest, and restore physical damage twice as fast as for ordinary people."
  - name: "Removing Symbiotes"
    description: "All priests of light are versed in the lore of Wormwood and the monsters that infest it - their weaknesses, strengths and habits, and how best to protect against them. The priest is also knowledgeable about symbiotes and has the power to remove them."
  - name: "Shaping the Living Planet"
    description: "Wormwood is alive, and its buildings, spires and mountains are part of its living body. Through prayer and concentration the priest changes and shapes a tiny area of that body: a doorway opens where none existed, the wall spreading apart as if pushed by giant invisible hands through soft clay; water fountains emerge from the ground like a blossoming flower and shrink back as if they had never been; portals close, stairways rise out of walls, and a hut can be made to rise from the ground. This is why a priest leads a siege or a sneak into a demon stronghold, and why one is on almost every reconnaissance team and commando strike force."
restrictions: ["Never uses symbiotic organisms", "Cannot draw P.P.E. from other beings except by blood sacrifice or when a priest offers it freely", "Cybernetics and bionics are virtually non-existent"]
side_effects: "The priest of light never uses symbiotic organisms, but can summon the battle saint and other symbiotes and can use blood stones and magic crystals. There are no ley lines on Wormwood to tap for ambient energy, though some subterranean caves are places of power and work like them."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. The p.52 social hierarchy puts the priest of light third from the top, below only the high priest and the sainted heroes. || THE ID IS NOT priest-of-light. That id is taken by a published Palladium Fantasy class from palladium-fantasy-core p.63-67, a completely different one; the name carries a (Wormwood) suffix for the same reason, on the precedent of rifts-priest. || Prayer schedule: the book says one additional ability at levels one and two, two at levels three and four, and one for each subsequent level. The level-one pick is spells_starting; everything from level two on is spells_schedule. The pick list is all 37 prayers, unrestricted - this is the only one of the four Cathedral classes with no exclusion on it. || Weapons and armor are described rather than issued: 1D4 wooden stakes and a mallet, a silver, crystal or resin cross, and two or three weapons of choice; chain mail through full plate at 40 to 100 M.D.C. with prowl penalties of 0 to -20%. || The High Priest on p.54 is NOT imported. It is a social status rather than an O.C.C., requires 9th level or higher, and p.157 does not give it an XP ladder."
---

## Lore

Long ago the priest was a scholar, teacher, healer and spiritual leader. Today
he must add warrior to that list. All are versed in the basics of combat and
self defense, and many wear armor and carry weapons - but most still consider
themselves teachers, healers and counselors rather than fighters.

His greatest mystical power is the ability to commune with and manipulate the
planet itself. Through prayer and concentration he shapes a small piece of a
living world: doorways open in mega-damage walls, exits close, fountains rise
out of the floor. It makes him the perfect urban spy and a fixture of any
reconnaissance team or commando strike force sent against the cities or the
crawling towers.

Despite the few evil and power hungry individuals in the church''s high command,
most priests of light are caring and compassionate people who help the
downtrodden and fight to keep the spark of humanity alive. Some wander from
city to city righting injustices and slaying monsters - there are priests known
as monster hunters. Others join the knights and freelancers as healers under
arms, or stay in a community to build defenses, organize the people and
establish secret networks of resistance fighters.

## GM Notes

The typical player character starts at level one or two. The average non-player
priest is 1D4+2 level.

Alignment runs roughly 5% evil, 20% selfish, 20% unprincipled, 35% scrupulous
and 20% principled - so an evil priest of light is rare but explicitly allowed,
and the corruption inside the Cathedral''s high command is a running thread of
the book. The apok and the monks are the two groups willing to say so out loud.

**The High Priest is not a character class.** It is a social status reached by
experienced priests who are recognized and elected as heads of the Cathedral,
almost always 9th level or higher, and p.157 gives it no experience ladder. A
high priest adds 1D4x10 P.P.E., +10 M.D.C., another +2 to save vs horror factor,
+2 vs supernatural and psionic possession, +1 vs magic, three more prayers of
choice, and six "other" skills at fifth level proficiency; the congress of them
rules the Cathedral, commands both knightly orders and tries to manage the apok
and the monks. Run one as an NPC with those adjustments.
',
       updated_at = datetime('now')
 WHERE class_id = 'wormwood-priest-of-light'
   AND instr(markdown, 'the class still stores the small sack') > 0
   AND length(markdown) = 10356;

-- == ngr-power-armor-commando ==
UPDATE imported_classes
   SET markdown = '---
id: ngr-power-armor-commando
men_of_arms: true
occ_group: men-of-arms
name: NGR Power Armor Commando
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.164
category: occ
tags: [combat, pilot]
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
attribute_requirements: { IQ: 11, ME: 12, PS: 14, PP: 14 }
starting_money: "2d4x1000"
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Literacy: Euro", base: 60, per_level: 5, note: "+30%" }
    - { name: "Language: Euro", base: 80, per_level: 5, note: "+30%" }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Select one additional language (+10%)." }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Radio: Scramblers", base: 55, per_level: 5, note: "+20%" }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Jet Packs", base: 52, per_level: 4, note: "+10%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "+10%; the book prints Pilot Hover Vehicles." }
    - { name: "Robots & Power Armor", base: 66, per_level: 3, note: "+10%" }
    - { name: "Robot Combat Elite: T-31 Super Trooper", base: 0, per_level: 0 }
    - { name: "Robot Combat Elite: X-10A Predator", base: 0, per_level: 0 }
    - { name: "Robot Combat Elite: X-535 Jager", base: 0, per_level: 0, note: "The book grants Robot Combat Elite: Jager (both types)." }
    - { name: "Robot Combat Elite: X-545 Super Jager", base: 0, per_level: 0, note: "The book grants Robot Combat Elite: Jager (both types)." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Demolitions", base: 80, per_level: 3, note: "+20%" }
    - { name: "Demolitions Disposal", base: 80, per_level: 3, note: "+20%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "The book prints W.P. Heavy Energy; this is the catalog''s row for rail guns and energy cannons." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Martial Arts (or Assassin if evil) for one O.C.C. Related skill." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 15 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", bonus: 2 }
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 4, count: 2 }
      - { level: 7, count: 2 }
      - { level: 11, count: 2 }
equipment_starting:
  - { item_id: "t-31-super-trooper", qty: 1 }
  - { item_id: "t-11-enhanced-body-armor", qty: 1 }
  - { item_id: "t-100-eagle-jet-pack", qty: 1 }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "smoke-grenade", qty: "1d4" }
  - { item_id: "fragmentation-grenade", qty: "1d4" }
  - { item_id: "triax-tear-gas-grenade", qty: "1d4" }
  - { item_id: "triax-plasma-grenade", qty: "1d4" }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 4 }
  - { item_id: "dress-uniform", qty: 1 }
extraction_notes: |
  - Military is printed "See O.C.C. skills" rather than as a category, so it is
    absent from occ_related_skills. The entry''s own Demolitions, Demolitions
    Disposal and Robot Combat Elite grants are what that line points at.
  - The book grants "Robot Combat Elite: Jager (both types)" as ONE line. It is
    stored as the two rows the same entry names three paragraphs later - the
    X-535 Jager and the X-545 Super Jager - because "both types" is a grant of
    two proficiencies, not one. add-ngr-armored-division-skills.sql creates all
    four Robot Combat Elite rows this class needs and records why they are
    machine-specific.
  - THE CLASS''S DEFINING EQUIPMENT IS IN equipment_starting since 2026-09-26
    (~018-class-vessels.sql). The T-31 Super Trooper is standard issue and the
    entry is built around it - printed 164 says the commando is sent out in one
    to fight giant robots and tanks one on one. It is the `t-31-super-trooper`
    gear row, which points at the vessel of the same slug the way
    `glitter-boy-power-armor` does (BOOK-INGEST-AUDIT.md F41). The T-11 Enhanced
    body armour and T-100 Eagle jet pack issued beside it are gear rows of
    their own (printed 34-35). Until then all three were in the body, under F3.
  - Three issued items are choices the book does not resolve and are not
    stubbed: a rail gun or heavy weapon of choice, an energy rifle of choice
    (the entry suggests the TX-42, TX-30 or TX-16 pump rifle), and gun
    holsters. In the body.
  - The 1D4 tear gas grenades and 1D4 plasma grenades are stored as
    `triax-tear-gas-grenade` and `triax-plasma-grenade` (BOOK-INGEST-AUDIT.md
    F139). The plasma grenade''s damage is printed "SD6 M.D.", an OCR reading
    of 5D6.
  - Secondary skills are printed at levels ONE, four, seven and eleven. Level
    one is creation, so it is the starting count of two rather than a schedule
    entry - a level-1 schedule entry does not fire, because creation asks from
    level 1.
  - starting_money is the first-level savings the book prints, 2D4x1000. The
    2600 credit monthly salary and the 4000 to 6000 a month for 9th level and
    higher are pay rather than starting coin and are in the body.
  - The two cybernetic augmentations the character selects at creation are not
    stored: an unrestricted pick from any category, and there is no cybernetics
    picker. In the body.
  - Skill bases are catalog base plus the printed bonus, already added.
---

## Lore

A specialist in combat power armour, explosives and heavy weapons, skilled with all man-size power armour and familiar with most robot vehicles. The commando''s job is usually to get in, do the job and get out.

The power armour commando is the soldier issued the T-31 Super Trooper and sent to engage giant enemy robots, tanks and assault vehicles one on one. Typical assignments are seek and destroy, sabotage, anti-armour assault, enemy penetration and rescue, most of them behind enemy lines.

Alignment: Any.

## The machines

Standard issue includes the T-31 Super Trooper, T-11 Enhanced body armour and the T-100 Eagle jet pack, all three in the starting equipment; the T-31''s full stat block is its vessel row. The elite training in them is stored, as Robot Combat Elite rows.

Available upon assignment: any man-size power armour, including all T-series armour, the X-10A Predator, X-60 Flanker, X-535 Jager, X-545 Super Jager and X-1000 Ulti-Max.

## Rank and pay

Standard military, private to general. Salary is 2600 credits a month, rising to 4000 to 6000 for ninth level and higher. Out of the field the commando gets a private apartment on or near a base.

## Cybernetics

Select two cybernetic augmentations from any category, usually sensory - gyro-compass, universal headjack, amplified hearing. Not stored, because the choice is unrestricted and the catalog has no cybernetics picker.

## GM Notes

Issued alongside the stored equipment: a rail gun or heavy weapon of choice, an energy rifle of choice (typically the TX-42, TX-30 or TX-16 pump rifle), and gun holsters. None is stored with the class; all three are unresolved choices.

Also available on assignment: additional weapons, energy clips and vehicles, a medical kit, portable computer, portable language translator, cameras, surveillance equipment and explosives including fusion blocks, plus mid-level base access. The commando usually gets priority for power armour, heavy weapons and explosives.
',
       updated_at = datetime('now')
 WHERE class_id = 'ngr-power-armor-commando'
   AND instr(markdown, 'that the class does not list') > 0
   AND length(markdown) = 8647;

-- == adna-nomad ==
UPDATE imported_classes
   SET markdown = '---
id: adna-nomad
name: Adna Nomad
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.11-13
category: rcc
tags: []
attribute_dice:
  IQ: "3d6+5"
  ME: "3d6+5"
  MA: "3d6+7"
  PS: "3d6"
  PP: "2d6+3"
  PE: "2d6+3"
  PB: "2d6+1"
  Spd: "3d6"
mdc_base: "P.E. + 6d6, +2d4 per level"
ppe_base: "2d6"
psionics:
  type: "minor"
  isp_base: "M.E. + 2d6, +1d6 per level"
  powers: ["Resist Thirst", "Resist Fatigue", "Summon Inner Strength", "Presence Sense"]
  powers_starting: 0
occ_restrictions:
  only: ["group:optional"]
  note: "Any Adventurer O.C.C.; Rogue Scholar, Rogue Scientist, Wilderness Scout and an educated Vagabond appeal most. No Men of Arms or Magic occupations."
bonuses:
  combat: { perception: 3 }
  saves: { spell_magic: -2, disease: 2, possession: 2, other: [ { label: "vs heat and cold", bonus: 3 } ] }
equipment_starting:
  - { item_id: "l-20-pulse-rifle", qty: 1 }
  - { item_id: "e-clip", qty: "2d4+4" }
  - { choose: 1, label: "Vibro-Knife or Neural Mace", qty: 1, from: ["vibro-knife", "neural-mace"] }
  - { choose: 1, label: "survival knife or hand axe", qty: 1, from: ["survival-knife", "hand-axe"] }
  - { item_id: "backpack-large", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "utensil-kit-rifts", qty: 1, note: "A set of cookware and eating utensils." }
  - { item_id: "sack", qty: "1d4" }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "flint", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 3 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "geiger-counter", qty: 1 }
  - { choose: 1, label: "gas mask or air purifier", qty: 1, from: ["gas-mask", "air-filter"] }
  - { item_id: "infrared-binoculars-digital-distancing-readout", qty: 1 }
  - { item_id: "goggles", qty: 1 }
  - { item_id: "walkie-talkie-radio", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "pen", qty: "1d4" }
  - { item_id: "traveling-clothes", qty: 4 }
  - { item_id: "hooded-cloak", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "hammer-and-mallet", qty: 1 }
  - { item_id: "wooden-stake", qty: 4 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "walking-stick", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "shovel", qty: 1, note: "Printed as a collapsible shovel." }
  - { item_id: "work-boots-rifts", qty: 1, note: "Printed as sturdy, comfortable hiking boots." }
  - { item_id: "riding-horse", qty: 1, note: "Only with a Horsemanship skill: a living or robot horse or mule, or a light M.D.C. riding animal with Horsemanship: Exotic, plus saddlebags and gear." }
natural_abilities:
  - name: "Mega-Damage being of normal strength"
    description: "M.D.C. equal to the P.E. attribute number plus 6D6, plus 2D4 per level of experience. Despite the M.D.C. body, strength is normal: punches, kicks and other physical attacks inflict S.D.C. damage."
  - name: "Smart and adaptive"
    description: "Smart, resourceful and highly adaptive. Physical maturity at 21; a healthy female can bear one child as often as every four years, after an 18 month gestation. Most mate for life."
  - name: "Minor psychic"
    description: "Every Adna is a Minor Psychic with Resist Thirst (6), Resist Fatigue (4), Summon Inner Strength (4) and Presence Sense (4). I.S.P. is the M.E. attribute number plus 2D6, +1D6 per level of experience."
special_abilities:
  - name: "Lore: Traversing the Megaverse"
    description: "Special skill, base 50% +3% per level of experience. Familiar with other key dimension-traveling races (Temporal Raiders, True Atlanteans, the Naruni, the Minions of Splugorth, the peoples of Phase World and the Three Galaxies) and with common and commercial means of dimensional travel such as stone pyramids, ley line nexus points, Temporal Raiders, Line Walkers and Ley Line Rifters. Cannot open a Rift; must hire one or seize an opportunity."
trackable_resources: []
restrictions:
  - "Alignment: any, but tend to be Principled (25%), Scrupulous (30%), Unprincipled (20%) or Anarchist (10%)."
  - "Magic: none. The Adna avoid magic."
  - "Vulnerability: -2 to save vs magic, and no P.E. or O.C.C. bonuses to save vs magic apply."
  - "The Long Death: 98% of all Adna carry this genetic disease, which makes them sterile and eventually kills them. The healthy 2% may carry it and pass it on (50% chance)."
  - "Cybernetics and bionics: none to start; taken only for medical, life-saving reasons."
  - "Equipment replaces the O.C.C.''s standard equipment. Money is in addition to the chosen O.C.C.''s: an extra 1D6x1,000 Universal Credits and 4D6x1,000 credits of exotic tradable goods."
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 11-13 (cache p012-p014), a scan; every number read off 200 dpi renders of cache p013 (printed 12, the whole stat block) and checked against the OCR. Heading Adna - Optional Player Character or NPC. The stat block ends on printed 12; Alliances and Allies and Rivals and Enemies continue on printed 13. Entry printed 11 starts mid-page under the Aardan Tek note. || CATEGORY: a race that takes an O.C.C. No xp_table: the book prints none; the Experience Level line gives NPC levels only, and the race uses the chosen O.C.C.''s table. || NAME: the entry is titled Adna Nomads and the stat block Adna; stored as Adna Nomad. Also known as The Quiet Wanderers and End Men. || M.D.C.: Mega-Damage Capacity, P.E. attribute number plus 6D6, plus 2D4 per level, stored as mdc_base; so no men_of_arms line. Physical attacks do S.D.C. damage (ability text). || P.P.E. 2D6. Horror Factor not applicable. || PSIONICS: All Adna are Minor Psychics with Resist Thirst (6), Resist Fatigue (4), Summon Inner Strength (4) and Presence Sense (4), granted by name; I.S.P. M.E. attribute number plus 2D6, +1D6 per level. || BONUSES: +3 Perception (perception 3), +2 vs disease, +2 vs possession, +3 vs heat and cold (saves.other). The Vulnerabilities line -2 to save vs magic is stored as spell_magic -2; that P.E. and O.C.C. bonuses to save vs magic do not apply cannot be expressed and is a restriction line. || SPECIAL SKILL: Lore: Traversing the Megaverse, base 50% +3% per level; the catalog has no such skill, so it is a special ability with the printed figure. || OCCUPATIONS: Any Adventurer O.C.C., no Men of Arms or Magic; stored as only group:optional (the catalog''s Scholars and Adventurers group). || EQUIPMENT: printed to be used instead of the O.C.C.''s; the composition cannot replace an O.C.C.''s gear, so this is said in a restriction line. Stored with catalog slugs: L-20 Pulse Rifle; 1D4+2 E-Clips for each of two weapons stored as 2D4+4; Vibro-Knife or Neural-Mace; survival knife or hand axe; large travel backpack as backpack-large; bedroll or sleeping bag as sleeping-bag; 1D4 medium sacks as sack; 1D4 small sacks; flint; 60 feet of rope as three 20-foot lengths; canteen; Geiger counter; gas mask or air purifier (air-filter); electronic distancing binoculars as infrared-binoculars-digital-distancing-readout; goggles; small hand-held short-range radio as walkie-talkie-radio; language translator; handheld computer; note pad and 1D4 pens (the book says pens or mechanical pencils); four sets of travel clothes; hooded cloak (comfortable coat or hooded cloak); small silver cross; mallet as hammer-and-mallet; four wooden stakes; a suit of light M.D. body armor (35 M.D.C.) as light-mdc-body-armor, whose catalog row carries no M.D.C. figure. Granted since ~116 and ~117: walking stick (1D8 S.D.C.) as walking-stick, tinder box as tinder-box, collapsible shovel as shovel, hiking boots as work-boots-rifts. Granted under BOOK-INGEST-AUDIT F139: the set of cookware and eating utensils as utensil-kit-rifts, and the Horsemanship character''s optional mount as riding-horse; the robot horse (a vehicles row with no gear row), the mule and the M.D.C. riding animal are in GM Notes. NOT STORED, no catalog row: the energy sidearm of choice and 1D6+1 items central to the O.C.C.; in GM Notes. || MONEY: printed as in addition to the O.C.C.''s amount (1D6x1,000 credits and 4D6x1,000 in tradable goods). Not stored as starting_money, which would replace the O.C.C.''s money; a restriction line. || NOT STORED: size 8-9 feet, weight 300-500 pounds, life span 4D6+90 years (ancestors lived to 220), slave market value, allies, enemies and habitat; in GM Notes."
---

## Lore

The Adna are among the rarest D-Bees in North America: tall, slender
wanderers with salmon-pink skin, very long and supple arms that reach past
their knees, long heads, slit nostrils and big, soft gray eyes. For all
their height they move gracefully, and their gentle smiles make most people
trust them on sight. An Adna on the road usually carries a bedroll and a
heavily loaded pack, leans on a walking stick, and dresses to blend in with
the countryside.

The race is dying. A hereditary illness the Adna call the Long Death first
leaves its victims sterile and then kills them, and no medicine or magic has
touched it. Nearly all Adna have it, and even the few who do not may pass it
to their children. Most have accepted this with a calm, philosophical
cheer, though a quiet sorrow follows them. Some came to Rifts Earth for one
last adventure, some to find other healthy Adna, and a few to plead with the
Gene-Splicers for help.

They are born explorers who never lose their wanderlust, and they prefer
quiet wilderness to crowded towns, especially the forests and mountains of
the eastern seaboard. Their peaceful ways are so well known that even
barbarian raiders usually leave them alone. They love people, art, music,
books and knowledge, and dislike conquerors and slavers.

## GM Notes

Size 8-9 feet (2.4 to 2.7 m), with a reach of 6-7 feet. Weight 300 to 500
pounds (135 to 225 kg). Life span 4D6+90 years; their ancestors lived to
220.

Experience Level: 1D8+5 for NPCs; player characters start at first or
second level.

Standard equipment the catalog has no row for: one energy sidearm of
choice and 1D6+1 items central to the chosen O.C.C. A character with a
Horsemanship skill may start with a living or robot horse or mule, or a
light M.D.C. riding animal with Horsemanship: Exotic, plus saddlebags and
gear; the living horse is stored, and the rest of that choice is not.

Slave Market Value: same as psychic human slaves.

Allies: they get along with humans and most D-Bees, and especially enjoy
carefree peoples such as Kraks, Larmac, Fennodi, Bubblemakers, Grackle
Tooth, most Idie Swamp Men and some Bayou Ursines. Enemies: the Splugorth
and their minions above all, then the Naruni and Kreeghor, and anyone who
makes war or enslaves. Horune Pirates believe drinking an Adna''s blood
grants wisdom and prophetic dreams.

Habitat: anywhere a human can live, but they favor quiet wilderness. A
small community has settled in the Appalachian Mountains, and some search
eastern Europe for Gene-Splicers.
',
       updated_at = datetime('now')
 WHERE class_id = 'adna-nomad'
   AND instr(markdown, 'set of cookware and utensils, 1D6+1') > 0
   AND length(markdown) = 10638;

-- == loronoid ==
UPDATE imported_classes
   SET markdown = '---
id: loronoid
name: Loronoid
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.124-127
category: rcc
tags: [flyer, scholar]
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+2"
  MA: "3d6+6"
  PS: "2d6+3"
  PP: "3d6+3"
  PE: "3d4+2"
  PB: "3d6+4"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "3d6+10"
ppe_base: "3d4"
starting_money: "3d4x100"
psionics:
  type: "master"
  isp_base: "M.E. attribute number + 2d4x10+10, +2d6 per level of experience"
  powers: ["Clairvoyance", "Empathy", "Mind Block Auto-Defense", "Mind Wipe", "Object Read (Psychometry)", "Remote Viewing", "Sense Time", "Telepathy", "Total Recall"]
  powers_starting: 4
  categories_allowed: ["Sensitive"]
  powers_starting_groups:
    - { count: 4, categories: ["Sensitive"], note: "The book grants 1D4 additional Sensitive powers: roll 1D4 and take only that many." }
  powers_schedule:
    - { level: 3, count: 1, categories: ["Sensitive"], note: "One additional Sensitive power." }
    - { level: 4, count: 1, from: ["Empathic Transmission"], note: "Gains the Super power Empathic Transmission at 4th level." }
    - { level: 6, count: 1, categories: ["Sensitive"], note: "One additional Sensitive power." }
    - { level: 8, count: 1, from: ["Hypnotic Suggestion"], note: "Gains the Super power Hypnotic Suggestion at 8th level." }
    - { level: 9, count: 1, categories: ["Sensitive"], note: "One additional Sensitive power." }
    - { level: 12, count: 1, categories: ["Sensitive"], note: "One additional Sensitive power." }
    - { level: 12, count: 1, from: ["Psychic Omni-Sight"], note: "Gains the Super power Psychic Omni-Sight at 12th level." }
    - { level: 15, count: 1, categories: ["Sensitive"], note: "One additional Sensitive power." }
bonuses:
  combat: { perception: 2, strike: 1, parry: 2, dodge: 1, pull_punch: 2, roll: 3 }
skills:
  hand_to_hand: { costs: { expert: 2 } }
  occ_skills:
    - { name: "Detect Ambush", base: 45, per_level: 5, note: "+15%" }
    - { name: "Detect Concealment", base: 45, per_level: 5, note: "+20%" }
    - { name: "Language: Spanish", base: 98, per_level: 0, note: "Language: Native Tongue: Spanish at 98%." }
    - { choose: 4, from: ["Language: Other"], bonus: 20, note: "Language: Other: American and three of choice (+20%) - take American as one of the four. Taken once per language - the picker asks which." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Literacy: Native Tongue (Spanish) at 98%." }
    - { choose: 3, from: ["Literacy: Other"], bonus: 20, note: "Literacy: Other: American and two of choice (+20%) - take American as one of the three. Taken once per language - the picker asks which." }
    - { name: "Computer Hacking", base: 30, per_level: 5, note: "+15%, but gets bored quickly." }
    - { name: "Cryptography", base: 45, per_level: 5, note: "+20%" }
    - { name: "Forgery", base: 35, per_level: 5, note: "+15%" }
    - { name: "Gambling (Standard)", base: 40, per_level: 5, note: "+10%" }
    - { name: "Imitate Voices & Sounds", base: 58, per_level: 4, note: "+16%" }
    - { name: "Intelligence", base: 52, per_level: 4, note: "+20%" }
    - { name: "Land Navigation", base: 52, per_level: 4, note: "+16%" }
    - { name: "Navigation", base: 55, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Research", base: 50, per_level: 5, note: "+10%" }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20%" }
    - { name: "Tailing", base: 40, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "Intuitive Math Skill: automatically known at 98%." }
    - { name: "Mathematics: Advanced", base: 78, per_level: 2, note: "Intuitive Math Skill: 78% +2% per level of experience." }
    - { choose: 1, from: ["W.P. Blunt", "W.P. Knife"], note: "W.P. Blunt or Knife (pick one)." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. Energy Pistol or Energy Rifle (pick one)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of two Secondary Skills." }
  secondary_skills:
    count: 3
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
      - { level: 15, count: 2 }
equipment_starting:
  - { choose: 1, label: "melee weapon", qty: 1, from: ["vibro-knife", "neural-mace"] }
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon for each W.P." }
  - { item_id: "e-clip", qty: "1d4+1" }
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1, note: "A light or medium suit of custom made or patchwork M.D.C. armor; the patchwork kind is not environmental and has 32 to 55 M.D.C." }
  - { item_id: "walkie-talkie", qty: 1, note: "Hand radio with scrambler." }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "survival-kit", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "hammock", qty: 1, note: "Portable hammock." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "A cigarette lighter and a box of matches." }
  - { item_id: "pencil", qty: 1, note: "Mechanical pencil and 24 replacement leads." }
  - { item_id: "portable-hand-held-computer", qty: 1, note: "Handheld portable computer." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "purse-satchel", qty: 1, note: "A medium-sized or large satchel with a sturdy shoulder strap." }
  - { item_id: "marker", qty: "1d4" }
  - { item_id: "mechanical-pencil-lead-24-in-a-pack", qty: 1 }
natural_abilities:
  - name: "Wings and flight"
    description: "Flight-capable wings with fully articulated hands at their ends, like a bat. Spd 3D6 running, 4D6+28 flying (minimum flying speed 30 mph/48 km). +4 to dodge when flying (instead of +1)."
  - name: "Natural weapons"
    description: "Grasping, climbing bird-like feet; a foot claw does 1D6 S.D.C. (+P.S. damage bonus) and a bite does 1D8 S.D.C."
special_abilities:
  - name: "Suspended Animation"
    description: "At will, enters a deep trance like the Death Trance spell, appearing dead or comatose: -35% on Paramedic and -25% on Medical Doctor rolls to diagnose as alive, and casual observers assume it is dead. Slows breathing and body functions, conserving air and slowing poison. Duration: 5 minutes per level of experience."
  - name: "Intuitive Math"
    description: "Knows the first 1D4x100+47 prime numbers and Pi to 1D6x1,000 decimal places. Mathematics: Basic 98% and Mathematics: Advanced 78% +2% per level (granted as skills). Computes without paper or a calculator at only -10%."
  - name: "Pattern Recognition"
    description: "Recognizes patterns in seemingly chaotic information, words, letters, numbers and images; reads maps without error and identifies locations, buildings and vehicles from aerial photographs; good at word puzzles and poetry. Its bonus is already counted in skills such as Cryptography, Land Navigation and Sensory Equipment."
trackable_resources: []
restrictions:
  - "Alignment: any, but the majority are Unprincipled (50%) and Anarchist (35%)."
  - "Available O.C.C.s: none; a Loronoid relies on its R.C.C. skills and abilities. R.C.C. Related Skills: none."
  - "Magic: none."
  - "Cybernetics and bionics: none; any cybernetic, M.O.M., Juicer or other augmentation costs all psionic abilities."
side_effects: "Easily distracted, and oblivious to its surroundings when focused on details; treat M.E. as half for anything needing long concentration or drudgery. Prone to laziness, gluttony and drink or drug addiction. Juveniles under 12 perform at half level and gain no experience until 12."
extraction_notes: "WB30 D-Bees of North America printed 124-127 (cache p125-p128), every number read off 200 dpi renders; the entry opens below the Loak on printed 124 and ends at Rivals and Enemies on printed 127, above the Lyn-Srial heading (the brief gave 124-126; Hand to Hand, psionics, equipment and money are on 127). Heading Loronoids - Optional Player Character or NPC. A mutant from Achilles, not a D-Bee. || CATEGORY: a complete R.C.C. that takes no O.C.C. (Available O.C.C.s: None); not expressible as occ_restrictions, a restriction line says so. || XP: Use the Military Specialist experience table. No Rifts class named Military Specialist is in the catalog (only Heroes Unlimited''s hu-edu-military-specialist and China 2''s geofront-military-specialist, neither the named table), so no xp_table is stored; reported for a decision. || POOLS: Hit Points P.E. plus 1D6 per level. Base S.D.C. 3D6+10 stored as sdc_base because the R.C.C. is the whole class (the Condoroid convention, the same Achilles mutant family), so no men_of_arms line. P.P.E. 3D4. Horror Factor not applicable. Money 3D4x100 credits. || ATTRIBUTES as printed; Spd 3D6 running, 4D6+28 flying (ability text). || BONUSES: +2 Perception, +1 strike, +2 parry, +1 dodge, +2 pull punch, +3 roll stored; +4 to dodge when flying is conditional, ability text. || PSIONICS: at first level Clairvoyance, Empathy, Mind Block Auto-Defense, Mind Wipe, Object Read (Psychometry; printed Object Read), Remote Viewing, Sense Time, Telepathy and Total Recall, plus 1D4 Sensitive powers (stored as 4 with the roll-and-take-that-many note), plus one Sensitive at levels 3, 6, 9, 12 and 15; the Super powers Empathic Transmission at 4, Hypnotic Suggestion at 8 and Psychic Omni-Sight at 12 as named-list schedule entries. Master Psionic. I.S.P. M.E. + 2D4x10+10, +2D6 per level. || SKILLS: catalog base plus printed bonus. Language: Native Tongue Spanish 98% as Language: Spanish 98 and Literacy: Native Tongue Spanish as Literacy: Native Language 98 (the Condoroid''s convention). Language: Other American and three of choice (+20%): a choose-4 Language: Other at +20% whose note names American as one pick; Literacy: Other American and two of choice (+20%) likewise as a choose-3 (Literacy: Other is a placeholder row that may not be granted by name). Gambling (Standard) 30+10. Imitate Voices & Sounds 42+16. Mathematics: Basic 98% and Advanced 78% +2% per level from Intuitive Math. W.P. Blunt or Knife and W.P. Energy Pistol or Rifle as choose-1 groups. Hand to Hand: Basic changes to Expert at the cost of two Secondary Skills: stored costs expert 2 (the app counts the picks; the book spends secondary skills since the race has no related skills). R.C.C. Related Skills: none. SECONDARY: three at level one plus two at levels 3, 6, 9, 12 and 15. || EQUIPMENT: Vibro-Knife or Neural Mace; weapons-matching-w-p-skills; 1D4+1 E-Clips; light or medium custom or patchwork M.D.C. armor (patchwork 32 to 55 M.D.C., non-environmental) as personalized-light-or-medium-mdc-body-armor (judgement); hand radio with scrambler as walkie-talkie; gas mask, survival kit, canteen, food-rations (one week), hammock, lighter and matches, mechanical pencil, handheld computer, pocket mirror. Granted since ~116 and ~117: the medium or large satchel as purse-satchel, the 1D4 markers as marker, and the pencil''s 24 replacement leads as mechanical-pencil-lead-24-in-a-pack. No catalog rows, not stored and not statted: hip flask of rum, 1D6+1 cigars, medium shoulder bag, journal, bottle opener. Not starting kit, so not granted: the digital or video camera, language translator and jewelry the book says the character may also acquire (BOOK-INGEST-AUDIT F139). || NOT STORED: size 4 feet to 5 feet 5 inches, weight 60 to 90 lbs, life span 4D4+130, eggs, slave value 3D6x10,000, habitat, allies and enemies; GM Notes."
---

## Lore

In 75 P.A. the genetic engineers of the Silver River Republic of Achilles,
in South America, set out to breed a mutant intelligence analyst: clever,
patient, good with numbers, patterns and languages, and psychically
sensitive. They built it from macaw parrots and called it the Loronoid.
The birds were brilliant, but something in their brain chemistry made
them easily bored and distracted, and they hated confinement and repetitive
work. Within a year they were deserting by the hundreds, and Achilles wrote
the whole project off as a failure.

Loronoids are short, brightly feathered humanoid parrots in blue and
yellow, red and blue or green and yellow, with large curved beaks, long
tail feathers, grasping bird feet and wings that end in fully working
hands. They breed true, and feral flocks have spread across South and
Central America, the Caribbean and, lately, Mexico and the American South.
Most are either thrill-seeking adventurers or laid-back loafers who love
food, drink, talk and parties. They let people assume they are D-Bees from
another world, partly from pride and partly so nobody tells Achilles where
they are.

## GM Notes

The book heads the race an optional player character or NPC. Also called
Parrotoids, Macaw Men and Loafin'' Loros.

Size 4 feet to 5 feet 5 inches (1.2 to 1.6 m). Weight 60 to 90 pounds (27
to 40.5 kg). Life span 4D4+130 years; mature at 12. Females lay 1D4 eggs
twice a year, hatching after five months.

Slave market value 3D6x10,000 credits, high demand, as scouts, analysts,
bookkeepers, tutors and servants.

Habitat: rain forest canopies, mountains and coasts from South America to
the Deep South and Dinosaur Swamp; northern ones migrate south in winter.

Allies: anyone who knows how to have fun. Enemies: they hate their Achilles
makers, fear feline D-Bees and monsters, are wary of stronger avian races,
and fear the Splugorth, slavers and human supremacists.
',
       updated_at = datetime('now')
 WHERE class_id = 'loronoid'
   AND instr(markdown, 'bottle opener; optional camera') > 0
   AND length(markdown) = 13617;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'symbiotic-warrior' AND instr(markdown, 'item_id: "sack-medium"') > 0)
    OR (class_id = 'apok' AND instr(markdown, 'item_id: "sack-medium"') > 0)
    OR (class_id = 'monk' AND instr(markdown, 'item_id: "sack-medium"') > 0)
    OR (class_id = 'wormwood-priest-of-light' AND instr(markdown, 'item_id: "sack-medium"') > 0)
    OR (class_id = 'ngr-power-armor-commando' AND instr(markdown, 'item_id: "triax-plasma-grenade"') > 0)
    OR (class_id = 'adna-nomad' AND instr(markdown, 'item_id: "utensil-kit-rifts"') > 0)
    OR (class_id = 'loronoid' AND instr(markdown, 'may also acquire (BOOK-INGEST-AUDIT F139)') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'symbiotic-warrior' AND instr(markdown, 'the class still stores the small sack') > 0)
    OR (class_id = 'apok' AND instr(markdown, 'the class still stores the small sack') > 0)
    OR (class_id = 'monk' AND instr(markdown, 'the class still stores small sacks') > 0)
    OR (class_id = 'wormwood-priest-of-light' AND instr(markdown, 'the class still stores the small sack') > 0)
    OR (class_id = 'ngr-power-armor-commando' AND instr(markdown, 'that the class does not list') > 0)
    OR (class_id = 'adna-nomad' AND instr(markdown, 'set of cookware and utensils, 1D6+1') > 0)
    OR (class_id = 'loronoid' AND instr(markdown, 'bottle opener; optional camera') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('symbiotic-warrior', 'apok', 'monk', 'wormwood-priest-of-light', 'ngr-power-armor-commando', 'adna-nomad', 'loronoid') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~198-book-ingest-audit-f139-plain-grants.sql');
