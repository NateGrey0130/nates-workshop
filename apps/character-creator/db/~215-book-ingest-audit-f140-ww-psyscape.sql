-- Settle BOOK-INGEST-AUDIT F140's Wormwood and Psyscape sentences
-- 2 classes, each replaced whole: apok, psi-druid.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~215-book-ingest-audit-f140-ww-psyscape.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F140, row 37d4b: Wormwood's apok and Psyscape's psi-druid.
-- Every candidate was tested against a render of the page it cites (Wormwood
-- printed 57 and 59, Psyscape printed 61 and 62), Psyscape's text layer for
-- printed 157, and production's catalog (2026-10-16).
-- Apok, false and corrected:
-- 1. Its Technical note said the +20% on languages and literacy could not be
--    stored because Literacy is a Communications skill and every reachable
--    language was already granted. 38 Language: rows and 4 Literacy rows are
--    filed under Technical. The +20% is now a second Technical entry with
--    only_prefix Language: and Literacy, ranked ahead of the +10% entry.
-- 2. Printed 59's weapons were not granted: the silver cross (a choice of three
--    Rifts rows), 1D6 wooden stakes, the mallet, two silver plated daggers and
--    1D4+1 knives now are, by Nate's ruling of 2026-10-16. The sword has no
--    Rifts row.
-- 3. Printed 57's +2 to save vs poison was not stored; it is toxins_poisons: 2.
-- Psi-druid, false and corrected:
-- 1. "About thirty herb rows": production held 67, all tagged rifts. Still not
--    granted: the page names no herb.
-- 2. Ski rows existed and were not offered; printed 62's "snowshoes or skis" is
--    now a choice of the two Rifts ski rows.
-- 3. "No schema field" for alignment, attributes and race: race_restrictions and
--    attribute_minimums exist; the page sets neither.

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
  saves: { spell_magic: 2, disease: 2, toxins_poisons: 2 }
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
      - { name: "Technical", only_prefix: ["Language:", "Literacy"], bonus: 20 }
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
  - { choose: 1, label: "silver, crystal or resin cross", qty: 1, from: ["small-silver-cross", "cross-crucifix-silver-4-6-inches", "cross-crucifix-silver-8-12-inches"] }
  - { item_id: "wooden-stake", qty: "1d6" }
  - { item_id: "hammer-and-mallet", qty: 1, note: "The mallet for the stakes." }
  - { item_id: "knife-silver-plated", qty: 2, note: "Two silver plated daggers." }
  - { item_id: "knife", qty: "1d4+1" }
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
extraction_notes: "THE PAGE RANGE IS 55-59, NOT THE SURVEY AND CONTENTS'' 55-58. Printed 56 and 58 are FULL-PAGE ART - the OCR cache holds 16 bytes for p056 and 9 bytes for p058, and neither is text. The Apok''s text runs 55 -> 57 -> 59, and printed 59 is not optional: it carries the SECOND HALF of the O.C.C. related skill category list (Medical through Wilderness), the whole Standard Equipment line, the Weapons, Armor, Transportation, Money, Cybernetics and Symbiotes entries. Reading only 55-58 would have lost a third of the class. Printed 59 also opens the Monk, so the two share it. || Money: Not applicable, read whole on p.59 - the apok are feared, disliked and on the bottom of the social totem-pole. No starting_money is stored. || Attribute bonuses ARE stored, as dice: bonuses.attributes takes a dice expression and rolls it once at creation, so the sheet carries what this character rolled rather than an average the book never prints. This note said the block took flat numbers only, which stopped being true before it was written - RETRO-AUDIT R11, 2026-09-04, and R6 made the same correction on the freelancer. Both are recorded on the Supernatural Strength and Endurance ability; they are also dice in bonuses, which the sheet rolls, so nothing is rolled by hand. The ability text follows the same rule the Freelancer follows for its d100 chart in #355. The P.S. is SUPERNATURAL, which the sheet does not model either. || M.D.C.: 40 plus 1D6 per level from the class and a flat +200 from the mask. The 200 is a pool bonus so that it reads as coming from the mask, which is where the book puts it. || Technical: the book prints Any (+10%; +20% on any language or literacy). The +20% is a second Technical entry, only_prefix Language: and Literacy, which the picker ranks ahead of the plain +10% entry (BOOK-INGEST-AUDIT.md F140, 2026-10-16). It reaches every Language: and Literacy row filed under Technical; the Literacy rows filed under Communications stay out of reach, because printed 57 gives this class Communication: None. || Weapons (printed 59): the silver cross (a choice of the three Rifts silver cross rows; crystal and resin have none), 1D6 wooden stakes and the mallet, two silver plated daggers (Knife, Silver Plated) and 1D4+1 knives are granted. The sword is not: the catalog''s plain swords are Palladium Fantasy, Heroes Unlimited and Nightbane rows. The two weapons of choice and the magic weapon of choice are left to the player. The 1D4 small pouches have no Rifts row and are not granted. || The level-up prayer list excludes summoning magic per p.57, which removes all ten Summon prayers from the 37 - leaving 27."
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
   AND instr(markdown, 'the catalog files Literacy under Communications') > 0
   AND length(markdown) = 11584;

-- == psi-druid ==
UPDATE imported_classes
   SET markdown = '---
id: psi-druid
name: Psi-Druid
system: rifts
category: occ
tags: [healer, wilderness]
occ_group: psychic
men_of_arms: false
source_book: Rifts World Book 12: Psyscape p.59-62
xp_table: [0, 2061, 4161, 8521, 16901, 25601, 35901, 50501, 70901, 95501, 130901, 190501, 240901, 290501, 350901]
bonuses:
  combat: { roll: 2 }
  saves:
    harmful_drugs: 2
    toxins_poisons: 2
    disease: 2
    horror_factor: 3
    other: [ { label: "vs magic potions", bonus: 2 }, { label: "vs magic illnesses", bonus: 2 } ]
psionics:
  type: "master"
  isp_base: "1d6x10+15 + M.E. attribute number, +2D4+2 I.S.P. for each additional level of experience"
  powers:
    - "Psychic Diagnosis"
    - "Healing Touch"
    - "Psychic Surgery"
    - "Clairvoyance"
    - "Empathy"
    - "Mind Block"
    - "Psychic Omni-Sight"
  powers_starting: 4
  powers_starting_groups:
    - { count: 2, categories: ["Healing"], note: "Two of choice from Healing." }
    - { count: 2, categories: ["Sensitive"], note: "Two of choice from Sensitive." }
  categories_allowed: ["Healing", "Sensitive"]
  powers_schedule:
    - { level: 2, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 3, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 3, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 4, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 5, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 5, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 6, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 7, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 7, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 8, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 9, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 9, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 10, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 11, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 12, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 13, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 13, count: 1, categories: ["Super"], note: "One Super-Psionic power at levels 3, 5, 7, 9 and 13." }
    - { level: 14, count: 2, categories: ["Healing", "Sensitive"] }
    - { level: 15, count: 2, categories: ["Healing", "Sensitive"] }
special_abilities:
  - name: "1. Weather Sense"
    description: "Opening himself to nature, the Psi-Druid senses temperature and barometric changes, humidity, frost, wind speed and direction, fog, and the likelihood of rain and dangerous storms (tornados, hurricanes, ley line storms, flash floods, snow storms), and predicts to within 10 minutes when they will arrive and roughly how severe they will be. He can also tell when weather is unnatural (magically induced). Predictions reach no more than 24 hours ahead, except an exceptionally powerful storm front, which he may sense 6D6+24 hours in advance. Base Skill: 70% +2% per level of experience. I.S.P. Cost: 3, plus 1D4 minutes of meditation."
  - name: "2. Dowsing"
    description: "A natural psychic divining rod. Fresh water within range is sensed instantly and automatically (no roll, no I.S.P.); pinpointing its exact location takes two consecutive successful skill rolls, and a successful roll also tells whether plants and ground are dry and roughly how long since the last rain. Base Skill: 60% +3% per level of experience. Range: 1000 feet (305 m) +200 feet (61 m) per level, doubled near ley lines and nexus points. Divining for other things: ley lines at half the dowsing skill; magnetic and/or dimensional disturbances, mineral deposits and powerful supernatural presences (one powerful being such as a godling or alien intelligence, or a gathering of many lesser ones) at a base skill of 18% +1% per level of experience."
  - name: "3. See Plant & Animal Auras"
    description: "Sees the aura of a plant or animal only (not humans, D-bees or objects, unless the character also has See Aura). The aura reveals: Earth-native or extraterrestrial (not which dimension); predator or not; healthy or sickly, young or old; growth/life cycle and whether an animal is pregnant; whether it is edible or poisonous to humans; intelligence band (plant, low animal I.Q. 1-4, high animal I.Q. 4-8, human-like 8-10); general experience level for D-bee plants and animals such as the Emirin and Kisent (low 1-3, medium 4-7, high 8+); the presence of magic (including magical or healing properties of plants, and magic-casting ability, without specifics); psychic abilities; high or low base P.P.E.; a possessing entity. Range: 60 feet (18.3 m) +10 feet (3 m) per level, and the subject must be visible. Duration: two melee rounds. I.S.P. Cost: 1. Saving Throw: none for plants or lower animals, standard for most animals; a mind block hides psychic abilities, P.P.E. level and supernatural possession."
  - name: "4. Heal Plant & Animal Life"
    description: "A healing touch for plants and animals only - never humans, D-bees or supernatural creatures. On a sentient creature such as the Emirin, or an animal wolf/mountain lion-sized or larger, it restores 2D6 hit points or S.D.C. and closes open wounds. On most small animals and plants it restores 20% of hit points and S.D.C. and cures cuts, bruises, pulled muscles, damaged feathers, skin conditions, blighted leaves, damaged bark and dried or damaged roots. Range: touch. Duration: instant, lasting effects. I.S.P. Cost varies by size: 2 small flower, plant or mouse-size animal; 5 shrub/bush or squirrel-size; 10 sapling, cat- to dog-sized animal or sentient plant; 20 young adult tree or deer- to bear-sized animal; 40 old tree (100+ years) or hippo-sized animal; 70 ancient tree (500+ years) or elephant-sized animal."
  - name: "5. Empathic Animal Friendship"
    description: "An automatic affinity with animals, similar to the Psi-Stalker''s. Domestic animals take to the character at once and try to please him. He can ride any horse or exotic mount, wild or tame (wild ones only bareback - they refuse saddle, leash or rope), at +10% to Horsemanship: Exotic, and gets +10% to applicable skills for working with domesticated animals. Wild animals, even predators and mutant or alien ones, treat him as a fellow woodland creature: they do not flee, birds do not take flight, and watchdogs and CS mutant animals do not raise an alarm, so animals give no warning of his approach. The Psi-Druid never uses this affinity to hunt, and hunts only out of necessity."
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { choose: 2, from: ["Language: Other"], bonus: 15, per_level: 5, note: "Languages: two of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math +10%" }
    - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
    - { name: "Brewing", base: 35, per_level: 5, note: "+10% (the book points to Rifts New West)" }
    - { name: "Biology", base: 50, per_level: 5, note: "+20%" }
    - { name: "Botany", base: 40, per_level: 5, note: "+15%" }
    - { name: "Sewing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 40, per_level: 4 }
    - { name: "Horsemanship: Exotic Animals", base: 40, per_level: 5, note: "+10% (the book points to Rifts New West)" }
    - { name: "Lore: Cattle & Animals", base: 40, per_level: 5, note: "Lore: Cattle/Animals +10% (the book points to Rifts New West)" }
    - { name: "Identify Plants & Fruit", base: 50, per_level: 5, note: "+25%" }
    - { name: "Preserve Food", base: 45, per_level: 5, note: "+20%" }
    - { name: "Cook", base: 55, per_level: 5, note: "+20%; professional quality" }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 50, per_level: 4, note: "+14%" }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. choice of Energy Pistol or Energy Rifle." }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P. Archery or one ancient W.P. of choice. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Hand to Hand: Basic can be changed to Expert at a cost of one R.C.C. Related skill selection, or Martial Arts at a cost of two." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Cowboy"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Tracking (people)"] }
      - { name: "Horsemanship", bonus: 10 }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", bonus: 5 }
      - { name: "Military", only: ["Camouflage", "Trap/Mine Detection"] }
      - { name: "Physical", except: ["Acrobatics", "Wrestling"] }
      - { name: "Pilot", except: ["Military: Jet Fighters", "Military: Tanks & APCs", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats"] }
      - "Pilot Related"
      - { name: "Rogue", only: ["Concealment"], bonus: 5 }
      - { name: "Rogue", only: ["Palming", "Ventriloquism"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "Electrical: None. Rogue: Concealment (+5%), Palming and Ventriloquism only - the +5% is on Concealment alone, so Rogue is two entries. Pilot: any except military-type combat vehicles. Horsemanship is granted with the Wilderness bonus because the catalog files riding under its own category; the book has no Horsemanship line."
    schedule:
      - { level: 4, count: 2 }
      - { level: 7, count: 2 }
      - { level: 10, count: 2 }
      - { level: 13, count: 2 }
  secondary_skills:
    count: 5
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
    note: "From the R.C.C. Related list, limited the same way (any, only, none), without the bonuses."
equipment_starting:
  - { choose: 1, label: "light, usually non-environmental M.D.C. body armor", qty: 1, from: ["plastic-man-body-armor", "urban-warrior-body-armor", "huntsman-armor", "dog-pack-dpm-riot-armor"] }
  - { choose: 1, label: "extra wilderness-type clothing (buckskin, camouflage, etc.)", qty: 1, from: ["buckskin-clothing", "camouflage-fatigues"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-large-brim", qty: 1 }
  - { item_id: "hooded-cloak", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { choose: 1, label: "snowshoes or skis", qty: 1, from: ["skis-cross-country", "skis-downhill"] }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "cord", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 5 }
  - { item_id: "wooden-spike", qty: 6 }
  - { item_id: "hatchet", qty: 1 }
  - { item_id: "knife-small", qty: 1 }
  - { item_id: "knife-skinning", qty: 1 }
  - { item_id: "fishing-line-and-hooks", qty: 1 }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1 }
  - { item_id: "flint-steel", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { choose: 1, label: "sling or bow & arrows", qty: 1, from: ["sling", "short-bow", "long-bow"] }
  - { item_id: "wilk-s-winchester-40-82-rifle", qty: 1 }
  - { choose: 2, label: "ancient weapons of choice", qty: 1, from: ["short-sword", "long-sword", "broadsword", "short-spear", "long-spear", "hand-axe", "mace", "war-hammer", "flail", "morning-star", "quarterstaff"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "l-20-pulse-rifle", "wr-15-wilderness-laser-rifle"] }
  - { item_id: "e-clip", qty: 4 }
starting_money: "6d6x100"
restrictions: ["No cybernetics"]
extraction_notes: |
  - Pages: heading and lore printed 59, Special R.C.C. Abilities printed 60-62, stat block printed 62 (cache p060-p063). Text checked against renders of printed 60-62; the cache matched.
  - XP: the Psi-Druid/Psi-Ghost/Darkhound ladder on printed 157, lower bounds as given in the batch brief.
  - GROUPING: men_of_arms false - the stat block is headed "The Psi-Druid Psychic R.C.C.", a psychic, not a man of arms. The book states no hit point, S.D.C. or P.P.E. formula, so none is stored.
  - ABILITY NUMBERING: the book numbers its Special R.C.C. Abilities 1-9; #1-5 are stored as special_abilities with the number kept in the name because the book refers to them by number. #6 (psionic powers) is the psionics block, #7 (I.S.P.) is isp_base, #8 (master psychic save 10+) is in GM Notes, #9 (R.C.C. bonuses) is bonuses.
  - BASE SKILLS: Weather Sense 70% +2%/level, Dowsing 60% +3%/level, divining for other resources 18% +1%/level, ley lines at half the dowsing skill (printed 61). They are stored in the ability descriptions; the schema has no percentage field for a class ability.
  - JUDGEMENT (printed 62): "A total of two additional abilities can be selected at subsequent levels of experience" is read as two more Healing or Sensitive powers at EACH level from 2 to 15, not two across the whole career. The alternative reading would give a Master Psychic two powers over fourteen levels. REVIEW if Nate reads it the other way.
  - PSIONICS: the seven named powers are granted outright. Mind Block is a Physical power and Psychic Omni-Sight a Super one; both are granted by name, which the category gate does not restrict. powers_starting counts only the four chosen (two Healing, two Sensitive). Super at 3, 5, 7, 9 and 13 is a second schedule entry at those levels.
  - BONUSES: +2 vs drugs, poisons and disease stored as harmful_drugs, toxins_poisons and disease. +2 vs magic potions and +2 vs magic illnesses are saves.other. +3 vs Horror Factor and +2 roll with impact stored unconditionally.
  - SKILLS: bases are catalog base plus the printed bonus. Basic Math is Mathematics: Basic 45+10. Horsemanship: Exotic is Horsemanship: Exotic Animals 30+10; ability #5 also names +10% to exotic horsemanship - read as the same bonus the skill list prints, and NOT added twice (REVIEW). Lore: Cattle/Animals is Lore: Cattle & Animals 30+10. Identify Plants & Fruits is Identify Plants & Fruit 25+25. Skin and Prepare Animal Hides is Skin & Prepare Animal Hides. Land Navigation 36+14 (the book prints +14%). Brewing is the plain Brewing row (Medical), not Brewing: Medicinal. No native language or literacy is printed and none was added.
  - RELATED: four, plus two at levels 4, 7, 10 and 13. Espionage Tracking is Tracking (people). Rogue Ventriloquism is a Technical row in the catalog; it resolves cross-category because the class grants Technical. The +5% on Concealment alone is a Rogue entry of its own naming Concealment only (BOOK-INGEST-AUDIT.md F138, 2026-10-14). Pilot "any, except Military type combat vehicles" excludes the five Military:-prefixed Pilot rows; robot and power armor rows were left open because the book names only military vehicles. Horsemanship granted as a category (with the +10% Wilderness bonus) since the catalog files riding skills under their own category. Electrical none.
  - SECONDARY: five, plus one at levels 4, 8 and 12.
  - EQUIPMENT: not stored or approximated - snowshoes (no row; the two Rifts ski rows are offered as the choice, BOOK-INGEST-AUDIT.md F140, 2026-10-16), sewing kit with needles and thread (only row is the magic Needle of Sewing, not used), 2D4 magic herbs (see Rifts England; production held 67 herb- gear rows, all tagged rifts, on 2026-10-16, and the page names no herb, so none is granted), the arrows that come with a bow (the choice holds the bow only), and "a couple pouches or sacks" as two small sacks. "Several tie cords" is one cord. 100 feet of rope is five 20-foot lengths. Waterproof matches is the lighter-or-matches row; flint and tinder are flint/steel plus a tinder box. The utility knife is Knife, Small. The conventional hunting rifle is Wilk''s Winchester 40-82. "Hat and/or hooded cloak" gives both. The book adds that Psi-Druids are not tech-savvy but may use Techno-Wizard devices and magic items.
  - VEHICLE: none to start.
  - MONEY: 6D6x100 credits stored. The 1D4x1000 credits in Black Market or trade items is goods, not coin, and is not stored.
  - CYBERNETICS: none; they interfere with psionics and are seen as unnatural. Stored as a restriction line.
  - Alignment any; attributes none required (high M.E. and P.E. suggested); race: humans 82%, Elves 8%, Ogres 3%, others 7%, either sex. There is no alignment field; the page sets no attribute minimum and no race restriction (the race line is a frequency), so neither attribute_minimums nor race_restrictions is set. Recorded here.
---

## Lore

Psi-Druids are Master Psychics whose bond with nature is psionic rather than magical, filling the role that mystic druids play elsewhere. They use empathy, aura sight, psychic diagnosis and a handful of unique nature powers to tend animals, crops and people. Most are peaceful healers, veterinarians, farmers and wilderness hermits who prefer animals to crowds. Rural communities prize them as healers and advisors and often court them with housing, pay and a seat on the town council. Many wander a regular circuit as traveling healers, and player characters are usually of that restless, road-loving kind.

## GM Notes

As a Master Psychic, the Psi-Druid needs a 10 or higher to save vs psionic attacks.

Level 2 onward: two more powers from Healing or Sensitive at each level, plus one Super-Psionic power at levels 3, 5, 7, 9 and 13.

Weather Sense needs 1D4 minutes of meditation before the roll. Dowsing''s range doubles near ley lines and nexus points. Empathic Animal Friendship''s +10% to skills for working with domesticated animals is situational and is not applied to any skill.

About a third of Psi-Druids are vegetarians, and all are distressed by an animal in trouble and will usually try to help it.
',
       updated_at = datetime('now')
 WHERE class_id = 'psi-druid'
   AND instr(markdown, 'about thirty herb rows exist now') > 0
   AND length(markdown) = 18612;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'apok' AND instr(markdown, 'The +20% is a second Technical entry') > 0)
    OR (class_id = 'psi-druid' AND instr(markdown, 'production held 67 herb- gear rows') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'apok' AND instr(markdown, 'the catalog files Literacy under Communications') > 0)
    OR (class_id = 'psi-druid' AND instr(markdown, 'about thirty herb rows exist now') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('apok', 'psi-druid') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~215-book-ingest-audit-f140-ww-psyscape.sql');
