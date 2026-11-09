-- BOOK-INGEST-AUDIT F139 residue: the Paradox Shaman's printed kit, and the Raider O.C.C.s for the Gigantes and Orc
-- 3 classes, each replaced whole: paradox-shaman, rifts-gigantes, rifts-orc.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~273-book-ingest-audit-f139-paradox-raider.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT.md F139 residue, taken 2026-11-09 (branch pal/data/book-ingest-audit-f139-paradox-raider).
--
-- paradox-shaman: the Standard Equipment paragraph of Spirit West printed 65
-- (cache p066, read off a 150 dpi render) re-checked item by item against gear
-- --remote. Granted where a rifts or both row exists: musical-instrument,
-- hand-axe, flint, hammer-and-mallet (the book's mallet), 3D4 wooden-stake and a
-- choose-one of the three silver crosses. The bedroll, light blanket and water
-- skin were Palladium Fantasy rows; swapped for bedroll-rifts,
-- blanket-light-rifts and the two Rifts water skins under Nate's 2026-10-12
-- ruling. No Rifts row: ceremonial garments, headdress or animal skin,
-- moccasins, silver-plated tomahawk.
--
-- rifts-gigantes, rifts-orc: occ_restrictions only gains raider-australia and
-- reaver-bandit-raider, both published low-tech Man at Arms O.C.C.s
-- (--remote 2026-11-09); the sentence saying the catalog has no Raider is gone.

-- == paradox-shaman ==
UPDATE imported_classes
   SET markdown = '---
id: paradox-shaman
men_of_arms: false
name: Paradox Shaman
system: rifts
source_book: Rifts World Book 15: Spirit West p.62-65
category: occ
tags: [divine, hunter]
xp_table: [0, 2501, 5001, 10001, 20001, 28501, 38501, 52001, 72001, 105001, 140001, 190001, 235001, 290001, 350001]
occ_group: magic
starting_money: "2d6x100 in trade goods"
magic:
  type: "spell"
  spells: ["Absolute Darkness", "Little Force", "Will of the Earth", "Sphere of Negation", "Universal Balance"]
  spells_starting: 5
  spells_from: ["Anti-Magic Cloud", "Armor of Ithan", "Astral Projection", "Banishment", "Close Rift", "Commune with Spirits", "Constrain Being", "Control & Enslave Entity", "Dimensional Portal", "Dispel Magic Barriers", "Energy Bolt", "Energy Disruption", "Energy Field", "Escape", "Exorcism", "Fly", "Ley Line Transmission", "Life Drain", "Locate", "Magic Pigeon", "Mystic Portal", "Negate Magic", "Protection Circle: Simple", "Protection Circle: Superior", "Sanctum", "See Aura", "See the Invisible", "Sense Magic", "Shadow Meld", "Teleport: Lesser", "Teleport: Superior", "Time Hole", "Time Slip", "Tongues", "Trance"]
  spell_lists:
    P: ["Anti-Magic Cloud", "Armor of Ithan", "Astral Projection", "Banishment", "Close Rift", "Commune with Spirits", "Constrain Being", "Control & Enslave Entity", "Dimensional Portal", "Dispel Magic Barriers", "Energy Bolt", "Energy Disruption", "Energy Field", "Escape", "Exorcism", "Fly", "Ley Line Transmission", "Life Drain", "Locate", "Magic Pigeon", "Mystic Portal", "Negate Magic", "Protection Circle: Simple", "Protection Circle: Superior", "Sanctum", "See Aura", "See the Invisible", "Sense Magic", "Shadow Meld", "Teleport: Lesser", "Teleport: Superior", "Time Hole", "Time Slip", "Tongues", "Trance"]
  spells_schedule:
    - { level: 2, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 3, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 4, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 5, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 6, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 7, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 8, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 9, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 10, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 11, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 12, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 13, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 14, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
    - { level: 15, count: 3, from_list: "P", note: "Three from printed 64''s list, of any level. The book also allows Rifts England''s temporal magic. The catalog holds 25 temporal spells now (names prefixed Temporal: ); this pick does not list them and is still from printed 64''s list only." }
ppe_base: "2d4x10+40 + P.E. attribute, +2d6 per level of experience"
bonuses:
  combat: { initiative: 2 }
  saves: { illusionary_magic: 2, psionics: 2, harmful_drugs: 2, horror_factor: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The character''s native tribal language, at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "English (American), at 98%." }
    - { choose: 4, from: ["Language: Other"], bonus: 20, note: "Four additional languages of choice (+20%). Taken once per language - the picker asks which." }
    - { choose: 4, from: ["Literacy: Other"], bonus: 10, note: "Literate in four languages of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: American Indians", base: 55, per_level: 5, note: "+30%. The book''s Lore: Indians." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
    - { name: "Play Musical Instrument", base: 50, per_level: 5, note: "+15%. One instrument of choice." }
    - { name: "Disguise", base: 35, per_level: 5, note: "+10%" }
    - { name: "Escape Artist", base: 45, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: General", base: 40, per_level: 4 }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. The book''s Track Humanoids." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book''s W.P. Archery and Targeting." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be upgraded to Expert for one O.C.C. Related skill, or to Martial Arts for two." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 7, count: 2 }, { level: 10, count: 2 }, { level: 13, count: 2 }, { level: 15, count: 2 }]
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", note: "Sniper, if taken, is with bow and arrow or spear." }
      - { name: "Horsemanship", note: "The book''s Pilot line allows horsemanship; this catalog files it as a category of its own." }
      - { name: "Military", except: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater", "Parachuting", "NBC Warfare"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak"] }
      - { name: "Rogue", only: ["Streetwise", "Palming", "Seduction"], bonus: 6 }
      - { name: "Science", only: ["Astronomy", "Astronomy & Navigation", "Anthropology", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 15 }
      - { name: "Technical", bonus: 15, note: "Art, language and lore skills only." }
      - { name: "Weapon Proficiencies", note: "Ancient weapons. A revolver or bolt-action rifle only with the G.M.''s leave, and never for a Pure One." }
      - "Wilderness"
  secondary_skills:
    count: 1
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
totem: { from: "animal" }
special_abilities:
  - name: "Memories of Earth"
    description: "Knows the true memories of the Earth''s past; a relevant snippet surfaces on a d20 roll of 16 or higher. Seen broadly - key people and events, never passwords or bank accounts - never written down, and never used for gain, to hurt others or to fuel hatred."
  - name: "Sense Rifts"
    description: "Automatically senses the opening, closing and location of dimensional Rifts within 50 miles (80 km)."
  - name: "Sense Dimensional Disturbances"
    description: "Automatically senses Rifts opening or closing, dimensional envelopes, mystic portals, dimensional teleportation and time holes within one mile (1.6 km)."
  - name: "See Dimensional Effects"
    description: "Sees dimensional envelopes and pockets, fourth- and two-dimensional beings, astral travellers, and the invisible energy essence of alien intelligences and entities."
  - name: "Ley Line Phasing"
    description: "Identical to the Ley Line Walker''s ability of the same name."
  - name: "Impervious to Possession"
    description: "Cannot be possessed."
  - name: "Temporal Magic (not held)"
    description: "Printed 64 lets the Paradox Shaman take Rifts England''s temporal spells (England p.74-83) in place of any pick from the list. Only the listed spells are offered here."
  - name: "Fetish Gifts"
    description: "Cannot make fetishes. Instead is given them: at level one the Heritage & Self and Great Body Fetishes, at level two a legendary Spirit Bow, at five a great fetish of choice, at ten a great fetish or a second legendary spirit weapon (typically a tomahawk or large battle axe), and at fifteen the legendary Cosmic Awareness Fetish."
  - name: "Animal Totem"
    description: "Every Shaman picks one totem animal and gains its skills and bonuses, though never its Totem Warrior powers. The totems are printed 96-105. Chosen in the wizard from the shared totems catalog; see BOOK-INGEST-AUDIT.md F56."
  - name: "Shaman''s Secret Tongue"
    description: "Speaks the secret tongue by which Shamans recognize one another and talk unheard (printed 49)."
equipment_starting:
  - { item_id: "heritage-and-self-fetish", qty: 1 }
  - { item_id: "great-body-fetish", qty: 1 }
  - { item_id: "spirit-weapon-fetish", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "bedroll-rifts", qty: 1 }
  - { choose: 1, label: "canteen or waterskin", qty: 1, from: ["canteen", "water-skin-half-gallon", "water-skin-one-gallon"] }
  - { item_id: "musical-instrument", qty: 1, note: "One instrument of choice." }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { item_id: "blanket-light-rifts", qty: 1 }
  - { choose: 1, label: "hooded cloak or robe", qty: 1, from: ["hooded-cloak", "hooded-robe"] }
  - { item_id: "rope-per-20-feet-6-m", qty: 3, note: "50 feet (15 m); the row is sold per 20 feet." }
  - { item_id: "food-rations", qty: 1, note: "One week: dried meat, fruits and nuts." }
  - { item_id: "flint", qty: 1 }
  - { item_id: "hammer-and-mallet", qty: 1, note: "The book prints a mallet; the Rifts row is a hammer and small mallet pair." }
  - { item_id: "wooden-stake", qty: "3d4" }
  - { choose: 1, label: "silver cross", qty: 1, from: ["small-silver-cross", "cross-crucifix-silver-4-6-inches", "cross-crucifix-silver-8-12-inches"], note: "The book names no size." }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Must be of Native American descent and a Traditionalist or Pure One (printed 64)."
  - "Cannot make fetishes."
  - "Technical related skills are limited to art, language and lore skills."
  - "Cybernetics: none, and will never consider any, with the possible exception of bio-systems to repair grievous injury."
extraction_notes: "Rifts World Book 15: Spirit West printed 62-65, read from the text layer. No hit point or S.D.C. formula is printed, so compose.js supplies both (1D6 S.D.C. as a practitioner of magic). P.P.E. prints as 2D4xlO+40 and trade goods as 2D6xlOO, read as 2D4x10+40 and 2D6x100 (BOOK-INGEST-AUDIT F53). Spells: all five Shamanistic Paradox spells are granted outright; five more at level one and three per level after come from the printed 64 list of 35, of any level. The book also allows Rifts England''s temporal magic for any of those picks. The catalog holds 25 temporal spells now (tradition temporal, names prefixed Temporal: , Rifts Book of Magic p.244-251); the class does not grant or list them and still offers the printed 64 list only, on the Time Master precedent from phase-world batch 9. Two list names use the catalog''s spelling: Control & Enslave Entity and Dispel Magic Barriers. THE BOOK CONTRADICTS ITSELF ON THE SPIRIT BOW: printed 64''s fetish list gives it at level two, and printed 65''s standard equipment lists a Spirit Bow among the starting weapons; the stat block is followed and it is starting equipment. The +1 to save vs horror factor at levels 1, 3, 4, 5, 7, 8, 9, 11, 13 and 15 is stored as +1 base and one step at each later level. Impervious to possession has no save field and is an ability. The totem pick is the class''s totem key, chosen from the shared totems catalog (BOOK-INGEST-AUDIT.md F56)."
---

# Paradox Shaman

**Alignments.** Any, but the spirits tend to avoid selfish people.

Originally called androgyne shamans: they embody the primal forces of the
universe before creation divided them into light and dark, man and woman, earth
and sky, and many live as symbolically sexless. Considered the most powerful of
Shamans, mediums between Earth, Sky and the Middle World, they tap primal forces
that at high levels can even touch time - nearly the equal of the Temporal
Raiders of Rifts England, whose abuses they oppose.

## Lore

Every Paradox Shaman carries a legendary Spirit Bow, the sign of a duty to
protect the Native American people and every other people from dimensional
horrors. Most wander the continent closing Rifts and fighting supernatural evil,
Temporal Raiders, the Splugorth and the Naruni, and they will help any sentient
being afflicted by a dimensional anomaly, whatever its race.

## Equipment not stored

Ceremonial garments, a ceremonial headdress or animal skin, soft moccasins
and a silver-plated tomahawk: no Rifts row (BOOK-INGEST-AUDIT.md F139). Two
S.D.C. weapons of choice, which the book leaves open. Every other item the
book prints on printed 65, the Spirit Bow included, is stored.
',
       updated_at = datetime('now')
 WHERE class_id = 'paradox-shaman'
   AND instr(markdown, '{ item_id: "bedroll", qty: 1 }') > 0
   AND length(markdown) = 15842;

-- == rifts-gigantes ==
UPDATE imported_classes
   SET markdown = '---
id: rifts-gigantes
name: Gigantes
system: rifts
source_book: Rifts Conversion Book One p.91-92
category: rcc
tags: []
men_of_arms: false
occ_restrictions:
  only: ["bandit", "highwayman", "saddle-tramp", "vagabond", "merc-soldier", "freelancer", "tribal-warrior", "cowboy", "gaucho", "pirate", "gunfighter", "raider-australia", "reaver-bandit-raider"]
  note: "Any basic Man at Arms O.C.C. that does not involve high technology (no robot pilots and the like), and simple ones like Raider, Bandit, Vagabond or Saddle Tramp. The Raider is the catalog''s two regional Raider O.C.C.s, Australia''s Raider and Warlords of Russia''s Reaver Bandit/Raider. The ids are a reading of ''basic, low-tech Man at Arms'': the Bandit, Highwayman, Saddle Tramp, Vagabond, Merc Soldier, Freelancer, Tribal Warrior, Cowboy, Gaucho, Pirate, Gunfighter and the two Raiders."
attribute_dice:
  IQ: "2d6"
  ME: "1d6"
  MA: "2d6"
  PS: "4d6+8"
  PP: "3d6+6"
  PE: "4d6+6"
  PB: "2d6"
  Spd: "4d6"
mdc_base: "P.E. attribute number +1d6x10"
ppe_base: "2d4x10"
horror_factor: 13
bonuses:
  combat: { attacks_base: 3 }
  saves: { horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Language: Troll/Giant", base: 90, per_level: 0, note: "Troll/Giant at 90%." }
    - { name: "Language: Gobblely", base: 90, per_level: 0, note: "Gobblely at 90%." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One additional W.P. of choice." }
    - { name: "Swimming", base: 60, per_level: 5, note: "Instinctive swimmers, 60%." }
natural_abilities:
  - name: "Mega-Damage Creature"
    description: "On Rifts Earth a Gigante becomes a Mega-Damage creature with 1D6x10 M.D.C. plus the P.E. attribute number, plus any M.D.C. its mutations add. A.R. does not apply on Rifts Earth. In an S.D.C. setting it is a Hit Point and S.D.C. being instead: Hit Points P.E. attribute number +1D6 per level of experience, S.D.C. 1D6x10 plus possible mutation bonuses."
  - name: "Supernatural Strength and Endurance"
    description: "Supernatural P.S. and P.E.: every punch, kick or bite does Mega-Damage according to the individual Gigante''s P.S., read off the Supernatural P.S. Table; a bite usually does one quarter damage unless a mutation says otherwise. Three attacks per melee without combat training, or those from Hand to Hand and other physical skills."
  - name: "Nightvision"
    description: "40 feet (12.2 m); can see in total darkness. Good overall vision and hearing."
special_abilities:
  - { rolls: 4, from: ["Mutation (01-05): Keen Nightvision", "Mutation (06-10): See the Invisible", "Mutation (11-15): Turn Invisible", "Mutation (16-20): Fire-Proof Hide", "Mutation (21-22): Poisonous Bite", "Mutation (23-24): Second Mouth", "Mutation (25-26): Single Large Horn", "Mutation (27-32): Additional Arm and Hand", "Mutation (33-40): Scaly Skin", "Mutation (41-45): Thick, Lumpy Skin", "Mutation (46-50): Leather Wings", "Mutation (51-54): Additional Eye", "Mutation (55-59): Large, Heavy Tail", "Mutation (60-64): Large Fangs", "Mutation (65-69): Ape-like Body", "Mutation (70-75): Feather Wings", "Mutation (76-80): Claws", "Mutation (81-84): Large, Flat Teeth", "Mutation (85-90): Breathe Fire", "Mutation (91-95): Spit Acid", "Mutation (96-00): Additional Leg"], note: "Rifts Gigante Mutation & Special Abilities Table (printed 91-92): the page says to roll four times. It does not say what a repeated result means." }
  - { name: "Mutation (01-05): Keen Nightvision", description: "Roll 01-05 or choose. Nightvision 3D6x20 yards/meters." }
  - { name: "Mutation (06-10): See the Invisible", description: "Roll 06-10 or choose. See the invisible." }
  - { name: "Mutation (11-15): Turn Invisible", description: "Roll 11-15 or choose. Turn invisible at will." }
  - { name: "Mutation (16-20): Fire-Proof Hide", description: "Roll 16-20 or choose. Impervious to Mega-Damage fire, and add 20 M.D.C. to the creature.", bonuses: { pools: { mdc: 20 } } }
  - { name: "Mutation (21-22): Poisonous Bite", description: "Roll 21-22 or choose. Poisonous bite: 4D6 S.D.C. damage." }
  - { name: "Mutation (23-24): Second Mouth", description: "Roll 23-24 or choose. A second mouth: its bite does 1D6 M.D." }
  - { name: "Mutation (25-26): Single Large Horn", description: "Roll 25-26 or choose. A single large horn: add 1D6 M.D. to a ram attack." }
  - { name: "Mutation (27-32): Additional Arm and Hand", description: "Roll 27-32 or choose. An additional arm and hand: adds one melee attack.", bonuses: { combat: { attacks: 1 } } }
  - { name: "Mutation (33-40): Scaly Skin", description: "Roll 33-40 or choose. Scaly skin: 2D6x10 additional M.D.C.", bonuses: { pools: { mdc: "2d6x10" } } }
  - { name: "Mutation (41-45): Thick, Lumpy Skin", description: "Roll 41-45 or choose. Thick, lumpy skin: 1D6x10 additional M.D.C.", bonuses: { pools: { mdc: "1d6x10" } } }
  - { name: "Mutation (46-50): Leather Wings", description: "Roll 46-50 or choose. Leather wings: a 01-50% chance they can fly, at a speed of 2D6x10; otherwise they are vestigial." }
  - { name: "Mutation (51-54): Additional Eye", description: "Roll 51-54 or choose. An additional eye: +2 to initiative and Nightvision 40 feet (12.2 m).", bonuses: { combat: { initiative: 2 } } }
  - { name: "Mutation (55-59): Large, Heavy Tail", description: "Roll 55-59 or choose. A large, heavy tail: can strike with it for 3D6 M.D." }
  - { name: "Mutation (60-64): Large Fangs", description: "Roll 60-64 or choose. Large fangs: bite does 3D6 M.D." }
  - { name: "Mutation (65-69): Ape-like Body", description: "Roll 65-69 or choose. An ape-like body covered in fur: +10 M.D.C.", bonuses: { pools: { mdc: 10 } } }
  - { name: "Mutation (70-75): Feather Wings", description: "Roll 70-75 or choose. Feather wings: a 01-50% chance they can fly, at a speed of 3D6x10." }
  - { name: "Mutation (76-80): Claws", description: "Roll 76-80 or choose. Claws: +1D6 M.D. to punch and clawing attacks." }
  - { name: "Mutation (81-84): Large, Flat Teeth", description: "Roll 81-84 or choose. Large, flat teeth: bite does 2D4 M.D." }
  - { name: "Mutation (85-90): Breathe Fire", description: "Roll 85-90 or choose. Breathe fire: 20 foot (6.1 m) range, 3D6 M.D." }
  - { name: "Mutation (91-95): Spit Acid", description: "Roll 91-95 or choose. Spit acid: 20 foot (6.1 m) range, 4D6 M.D." }
  - { name: "Mutation (96-00): Additional Leg", description: "Roll 96-00 or choose. An additional leg: adds 20% to balance, by hand, and +1D4x10 to speed, which the pick applies.", bonuses: { attributes: { Spd: "1d4x10" } } }
  - { choose: 1, from: ["Insanity (01-10): Random Psychosis", "Insanity (11-20): No Insanity, but Aggressive", "Insanity (21-30): Hyper-Aggressive", "Insanity (31-40): Random Obsession", "Insanity (41-50): Random Phobia", "Insanity (51-60): Thinks It Is a Demigod", "Insanity (61-70): Psychotic Reliance", "Insanity (71-90): Random Insanity", "Insanity (91-00): Random Affective Disorder"], note: "Rifts Gigante Insanity Table (printed 92): the page says to roll once." }
  - { name: "Insanity (01-10): Random Psychosis", description: "Roll 01-10. Roll for a random psychosis on the Rifts RPG''s psychosis table; that roll is made by hand." }
  - { name: "Insanity (11-20): No Insanity, but Aggressive", description: "Roll 11-20. No insanity, but aggressive." }
  - { name: "Insanity (21-30): Hyper-Aggressive", description: "Roll 21-30. Easily provoked over the slightest thing. Tries to solve all problems with violence, and smashes things or pounds on the wall or ground when frustrated or angry and unable to act on it. +1 on initiative (applied), but reduce M.A. by 25% (a percentage of the rolled attribute, so worked by hand).", bonuses: { combat: { initiative: 1 } } }
  - { name: "Insanity (31-40): Random Obsession", description: "Roll 31-40. Make a random roll on the Obsession Table in the Rifts RPG (hates or loves something, perhaps literally to death); that roll is made by hand." }
  - { name: "Insanity (41-50): Random Phobia", description: "Roll 41-50. Make a random roll on the Phobia Table in the Rifts RPG; that roll is made by hand." }
  - { name: "Insanity (51-60): Thinks It Is a Demigod", description: "Roll 51-60. Thinks he or she is a demigod and indestructible, takes stupid risks, and demands worshipers and tribute." }
  - { name: "Insanity (61-70): Psychotic Reliance", description: "Roll 61-70. Completely convinced that it draws its power and strength from a particular object, usually a piece of junk. If the item is lost or stolen, all bonuses and P.S. damage are reduced by half; nothing is changed while the object is held." }
  - { name: "Insanity (71-90): Random Insanity", description: "Roll 71-90. Roll on the Random Insanity Table in the Rifts RPG; that roll is made by hand." }
  - { name: "Insanity (91-00): Random Affective Disorder", description: "Roll 91-00. Roll for a random affective disorder in the Rifts RPG; that roll is made by hand." }
side_effects: "Insanity plagues the Gigantes. Roll once on the Rifts Gigante Insanity Table (printed 92), which is the pick-one Insanity group under special_abilities; five of its nine rows send the player on to a table in the Rifts RPG."
extraction_notes: |
  - Rifts Conversion Book One printed 91-92 (file p092-p093). No Palladium Fantasy Gigantes row exists in the catalog on 2026-09-26; the id takes the `rifts-` prefix batch 1 set. The book uses "Gigantes" for the race and "Gigante" for one of them; the id and name are the race''s.
  - THE MUTATION TABLE IS A `rolls: 4` GROUP OF TWENTY-ONE BAND-NAMED OPTIONS (2026-10-05, BOOK-INGEST-AUDIT.md F120). Printed 91-92 (file p092-p093, folios checked on the renders) heads it "Roll four times to determine random abilities and features" and prints 21 rows: 01-05, 06-10, 11-15, 16-20, 21-22, 23-24, 25-26, 27-32, 33-40, 41-45, 46-50, 51-54, 55-59, 60-64, 65-69, 70-75, 76-80, 81-84, 85-90, 91-95, 96-00 - 01-00 with no gap or overlap, each band read off the render. Each option is named `Mutation (NN-NN): ...` so the four rolls can be made or the four results picked; before this date it was a `choose: 4` whose names carried no band. The page says nothing about a repeated result, and the group''s note says so. Four entries carry the flat numbers the book states - +20 M.D.C., +1 attack, +2 initiative, +10 M.D.C. - and the two skin entries carry their M.D.C. dice as pool bonuses, which rollPoolFormula rolls once at creation. Every other entry''s mechanics are in its text: the bite, horn, tail, claw, breath and acid damages, and the flight chances and speeds. The extra leg''s +1D4x10 speed, which the page prints without a condition, is an attribute bonus on its row since 2026-10-05.
  - THE INSANITY TABLE IS A `choose: 1` GROUP OF NINE BAND-NAMED OPTIONS (2026-10-05, BOOK-INGEST-AUDIT.md F120). Printed 92 (file p093, folio checked on the render) heads it "Roll once" and prints nine rows: 01-10 random psychosis, 11-20 no insanity but aggressive, 21-30 hyper-aggressive, 31-40 the Obsession Table, 41-50 the Phobia Table, 51-60 thinks it is a demigod, 61-70 psychotic reliance, 71-90 the Random Insanity Table, 91-00 random affective disorder - 01-00 with no gap or overlap. One option per row, one definition each; side_effects now points at the group. Five rows (01-10, 31-40, 41-50, 71-90, 91-00) send the player to the Rifts RPG''s own tables, which this catalog does not hold as rows, so each stays as its row''s prose. Hyper-Aggressive''s +1 on initiative is printed flat and is stored as a bonus; its "reduce M.A. by 25%" is a percentage of a rolled attribute and stays prose. Psychotic Reliance''s halving of all bonuses and P.S. damage applies only if the object is lost or stolen, so it is prose.
  - A MEGA-DAMAGE BEING ON RIFTS EARTH: mdc_base is the page''s "1D6x10 M.D.C. plus P.E. attribute number", mutation M.D.C. added by the chosen entries. The S.D.C.-world figures are a natural ability, as on `rifts-troll`.
  - Attacks per Melee (Rifts): "Three without any combat training, or those gained from hand to hand combat" - an OR, so `attacks_base: 3`, which a Hand to Hand style''s four replaces rather than adds to.
  - Supernatural P.S. is prose; the app has no P.S. class key. Instinctive swimming at 60% is a Swimming grant, as on `rifts-troll`.
  - Psionics: "Standard, about the same as humans", so no psionics block.
  - occ_restrictions is an `only`, and it is a JUDGEMENT: "Any basic Man at Arms O.C.C., except those involving the use of high technology like robot pilot, and simple ones like Raider, Bandit, Vagabond, or Saddle Tramp" is read as low-tech Men of Arms plus the simple wanderers it names. The ids are the low-tech fighters and drifters the catalog holds; Raider is the two regional Raider O.C.C.s, raider-australia and reaver-bandit-raider, added 2026-11-09 (BOOK-INGEST-AUDIT.md F139 residue). A matching O.C.C. imported after this is refused until it is added.
  - Height 12 to 20 feet; weight 1,000 to 2,000 pounds; life span 150 years. In the Lore.
  - The section-wide rule on printed 74 - a new arrival from the Palladium World picks up the regional language and two Modern W.P.s within weeks, then three Rifts skills from Communications, Pilot (basic vehicles), Technical and W.P. Modern after 2D4+4 months or one level, and one more language or skill every two levels - applies to a character who came from Palladium rather than one raised on Rifts Earth. It is not stored; the survey carries it.
---

# Gigantes

## Lore

The Gigantes, the Mutant Giants, are perhaps the most feared and bizarre giants of the Palladium World: mutants whose ever-shifting genes throw up a host of monstrous sub-species, no two alike. They are typically ignorant, aggressive misanthropes with a lust for bloodletting, preying on humans and Elves first but on anyone they think they can beat - other giants, dragons and demons included - and insanity plagues them. They are most numerous in the Yin-Sloth Jungles and the Northern Mountains.

They are uncommon on Rifts Earth, where the magic-rich environment makes them powerful Mega-Damage beings; they are known around the Calgary Rift, the Detroit-Windsor Rifts and parts of Europe and Asia. Their simple-mindedness, senseless savagery and small numbers keep them from becoming a serious threat.

**Alignment:** Any, but leans toward Anarchist (30%), Miscreant (30%) and Diabolic (30%).

**Appearance:** Varies dramatically, but always strange and monstrous.

**Height:** 12 to 20 feet (3.6 to 6.1 m); size varies dramatically. **Weight:** 1,000 to 2,000 pounds (450 to 900 kg).

**Average Life Span:** 150 years.

## GM Notes

Most Gigantes are wild, merciless fighters given to berserker rages and slaughter; they eat the flesh of their enemies, and villainous Gigantes attack Titans, their arch-enemies, on sight. Traditional enemies are Titans, Elves, Dwarves, humans and most non-giants; allies are Cyclops, Nimro, Trolls, Ogres, Orcs and Goblins, and on Rifts Earth they get along wonderfully with Daemonix, Brodkil, Gargoyles, Witchlings, Black Faeries, Simvan and Shifters, often joining evildoers and supernatural horrors.
',
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gigantes'
   AND instr(markdown, 'The catalog has no Raider O.C.C.') > 0
   AND length(markdown) = 14821;

-- == rifts-orc ==
UPDATE imported_classes
   SET markdown = '---
id: rifts-orc
name: Orc
system: rifts
source_book: Rifts Conversion Book One p.101-102
category: rcc
tags: []
men_of_arms: false
occ_restrictions:
  only: ["city-rat", "vagabond", "saddle-tramp", "wilderness-scout", "bandit", "highwayman", "merc-soldier", "gunfighter", "gunslinger", "headhunter-techno-warrior", "crazy", "ultra-crazy", "combat-cyborg", "mining-borg", "plains-borg", "destroyer-borg", "raider-australia", "reaver-bandit-raider"]
  note: "Limited to City Rat, Vagabond, Saddle Tramp, Wilderness Scout, Bandit, Highwayman, Raider, warrior/fighter/merc, Gunfighter, Gunslinger, Headhunter, Crazy, Cyborg (any) or laborer. The Raider is the catalog''s two regional Raider O.C.C.s, Australia''s Raider and Warlords of Russia''s Reaver Bandit/Raider. The catalog has no laborer O.C.C.; the Merc Soldier stands for the warrior/fighter/merc, and the Crazy and Cyborg lines take every Crazy and non-military ''Borg O.C.C. the catalog holds."
attribute_dice:
  IQ: "2d6"
  ME: "2d6"
  MA: "3d6"
  PS: "3d6+8"
  PP: "3d6"
  PE: "3d6"
  PB: "2d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1D6 per level"
ppe_base: "2d6"
psionics_allowed: false
bonuses:
  pools: { sdc: 10 }
  combat: { roll: 1 }
  saves: { horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Language: Gobblely", base: 98, per_level: 0, note: "Gobblely at 98%; typically illiterate." }
natural_abilities:
  - name: "Nightvision"
    description: "40 feet (12.2 m), with excellent day vision equal to a human''s and a superior sense of smell."
  - name: "Track Blood Scent"
    description: "Follow the scent of blood up to 1000 feet (305 m) away. Base Skill: 15% +5% per level of experience."
  - name: "Recognize Scent of Others"
    description: "Recognize and follow a familiar scent up to 50 feet (15 m) away. Base Skill: 10% +3% per level of experience; +13% for the scent of a mate or offspring. Roll once for every 100 feet (30.5 m) of a trail; a failed roll loses it."
  - name: "Damage"
    description: "Clawed hands 1D6 S.D.C. + P.S. bonus; kick 2D6 S.D.C. + P.S. bonus; bite 1D6 S.D.C. with no P.S. bonus. Two attacks per melee without combat training; otherwise those from Hand to Hand and Boxing."
  - name: "S.D.C. Mortal"
    description: "No natural A.R. and no M.D.C. - an Orc needs M.D.C. body armor or magic. Most prefer medium and heavy armor and love magic armor; few are smart enough for power armor. No Horror Factor."
restrictions:
  - "No psionics. The page states Psionics: None."
  - "Magic by the Witch and Priest O.C.C.s only - and neither is on the Rifts list, so a Rifts Orc has no magic O.C.C."
  - "In their lust for power Orcs embrace bionics, partial and full conversion, M.O.M. (Crazy) conversion and even Bio-Wizard augmentation or becoming a Bio-Borg. Juicer conversion succeeds only 1-33% of the time; the other 67% die or are left mindless."
extraction_notes: |
  - Rifts Conversion Book One printed 101-102 (file p102-p103). The Rifts conversion of the Palladium Fantasy Orc, which is the `orc` row. A separate class because a variant cannot cross systems.
  - The P.E. here is 3D6 where the Palladium Fantasy row rolls 3D6+2; everything else in the attribute line matches. Read from the page, not carried over.
  - S.D.C. "10 plus those gained from O.C.C. and physical skills" is a POOL BONUS.
  - "+1 to roll with impact" is the `roll` combat key.
  - Psionics: None, so psionics_allowed: false.
  - The page''s "Magic: Witch and Priest O.C.C.s only" is the Palladium side; the Rifts O.C.C. line is a closed list with no magic O.C.C. on it, and the Rifts list is what occ_restrictions encodes.
  - occ_restrictions is an `only`, because the book gives a closed list. One name on it has no catalog row, laborer, and is named in the note; Raider is the two regional Raider O.C.C.s, raider-australia and reaver-bandit-raider, added 2026-11-09 (BOOK-INGEST-AUDIT.md F139 residue); "warrior/fighter/merc" is read as the Merc Soldier; "Cyborg (any)" as every ''Borg O.C.C. not tied to a national military, and "Crazy" as the Crazy and the Ultra-Crazy. An O.C.C. of any of those kinds imported after this is refused until it is added.
  - The Juicer line is not on the list - "attempted" and "successful 1-33% of the time" describe a conversion, not an O.C.C. the book allows - so no Juicer is offered.
  - Size 5 feet to 6 feet 8 inches; weight 160 to 250 pounds; life span 50 years. In the Lore.
  - The section-wide rule on printed 74 - a new arrival from the Palladium World picks up the regional language and two Modern W.P.s within weeks, then three Rifts skills from Communications, Pilot (basic vehicles), Technical and W.P. Modern after 2D4+4 months or one level, and one more language or skill every two levels - applies to a character who came from Palladium rather than one raised on Rifts Earth. It is not stored; the survey carries it.
---

# Orc

## Lore

Orcs are the commonest of the Palladium World''s sub-human races: large, broad, heavily muscled brutes with apish heads, heavy brows, pointed ears, fanged mouths, flat snout-like noses and black manes. Like Goblins they live in loose tribes of raiders and brigands, preferring to take rather than make - though their strong backs make them fine farmers and laborers. They follow anyone with enough strength or magic to impress them, which makes them the armies of Ogre warlords, Trolls, Giants, sorcerers, dragons and worse, and their taste for carnage can turn them into a mob no master can control, until a display of magic cows them again.

On Rifts Earth Orcs are found in the ''Burbs of Chi-Town, Iron Heart and Lone Star (1-3% of the D-Bees there), make up thirty percent of the Pecos Empire''s bandits, and turn up in Ciudad Juarez, Mexico, the American West, around Calgary and in southern Canada; tens of thousands live with their Goblin allies in Eastern Europe.

**Alignment:** Any, but leans toward Anarchist (30%), Miscreant (40%) and Diabolic (25%).

**Size:** 5 feet to 6 feet 8 inches. **Weight:** 160 to 250 pounds.

**Average Life Span:** 50 years.

## GM Notes

Orcs are savage, cruel and aggressive, easily startled and bluffed, especially by magic and the supernatural. They love energy weapons, rail guns, heavy armor, Vibro-Blades and bionics, and among old-fashioned weapons large swords, axes and pole arms. Traditional enemies are humans, Elves, Dwarves, Gnomes, Changelings and anything large and beautiful; allies are the other monster races, and the Wolfen have so far had little luck recruiting them.
',
       updated_at = datetime('now')
 WHERE class_id = 'rifts-orc'
   AND instr(markdown, 'The catalog has no Raider or laborer O.C.C.') > 0
   AND length(markdown) = 6222;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 3 classes carry their new text' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'paradox-shaman' AND instr(markdown, '{ item_id: "wooden-stake", qty: "3d4" }') > 0)
    OR (class_id = 'rifts-gigantes' AND instr(markdown, '"gunfighter", "raider-australia", "reaver-bandit-raider"]') > 0)
    OR (class_id = 'rifts-orc' AND instr(markdown, '"destroyer-borg", "raider-australia", "reaver-bandit-raider"]') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'paradox-shaman' AND instr(markdown, '{ item_id: "bedroll", qty: 1 }') > 0)
    OR (class_id = 'rifts-gigantes' AND instr(markdown, 'The catalog has no Raider O.C.C.') > 0)
    OR (class_id = 'rifts-orc' AND instr(markdown, 'The catalog has no Raider or laborer O.C.C.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('paradox-shaman', 'rifts-gigantes', 'rifts-orc') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~273-book-ingest-audit-f139-paradox-raider.sql');
