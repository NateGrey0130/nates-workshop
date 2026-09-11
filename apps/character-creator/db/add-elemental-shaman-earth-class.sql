-- BOOK-INGEST-AUDIT F63, taken as an import: the Elemental Shaman (Earth),
-- Rifts World Book 15: Spirit West p.65-67.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-elemental-shaman-earth-class.sql
--
-- WHY THIS CLASS EXISTS. The Elemental Shaman picks one of four elements, and
-- the element sets its three first-level spells and - for Air, Earth and Water -
-- a skill at 98% (printed 65-66). A choice of ability cannot narrow a spell
-- group or grant a skill (ABILITY_GRANTS; F24 kept skills off abilities on
-- purpose), so the one class offered all 37 elemental spells with a note and
-- kept the skill in ability text. The Warlocks settled the same problem by
-- splitting per element (RETRO-AUDIT R3); this is that, four ways, generated
-- from the live elemental-shaman row so everything but the element is
-- identical - including F61's level cap on the Shamanistic list.
--
-- A declared copy of elemental-shaman-air. The except list was DERIVED by
-- diffing the parsed classes, not typed: magic, skills, special_abilities.
-- Generated; apostrophes doubled; the markdown is pure ASCII with LF endings.

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'elemental-shaman-earth', 'Elemental Shaman (Earth)', 'rifts', '---
id: elemental-shaman-earth
name: Elemental Shaman (Earth)
system: rifts
source_book: Rifts World Book 15: Spirit West p.65-67
copy_of: { class: "elemental-shaman-air", except: ["magic", "skills", "special_abilities"] }
category: occ
occ_group: magic
starting_money: "2d6x100 in trade goods"
magic:
  type: "spell"
  spells_starting: 5
  spells_starting_groups:
    - { count: 3, from: ["Earth: Chameleon", "Earth: Create Wood", "Earth: Dowsing", "Earth: Dust Storm", "Earth: Fool''s Gold", "Earth: Identify Minerals", "Earth: Identify Plants", "Earth: Mystic Fulcrum", "Earth: Rock to Mud", "Earth: Rot Wood", "Earth: Shatter"], note: "Three first-level Earth spells, from the Warlock sphere the book points at (printed 65)." }
    - { count: 2, from: ["Dowsing", "Nose of the Wolf"], note: "The two Shamanistic spells no higher than level one." }
  spell_lists:
    S: ["Call Totem", "Call Totem Animal", "Call Totem Spirit", "Contact Spirits", "Create Arrows", "Spirit Fence", "Spirit Paint", "Spirit Quest", "Animal Companion", "Animal Speech", "Ears of the Wolf", "Metamorphosis: Totem", "Metamorphosis: Totem Animal", "Nose of the Wolf", "Shared Spirits", "Spirit''s Blessing: Animal", "Summon Game Animals", "Totem Gift", "Animate the Forest Floor", "Animate Tree", "Call Forest Guardian", "Dowsing", "Magic Stick", "Nourish Plants", "Plant Growth", "Plant Travel", "Spirit''s Blessing: Plant", "Spirit Walk", "Thornwall"]
  spells_schedule:
    - { level: 2, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 3, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 4, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 5, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 6, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 7, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 8, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 9, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 10, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 11, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 12, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 13, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 14, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
    - { level: 15, count: 2, from_list: "S", spell_levels: "up_to_character_level" }
ppe_base: "2d4x10+20 + P.E. attribute, +2d6 per level of experience"
bonuses:
  combat: { initiative: 1 }
  saves: { horror_factor: 3, spell_magic: 2, ritual_magic: 2, possession: 4 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The character''s native tribal language, at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "English (American), at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Two additional languages of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Horsemanship: Exotic Animals", base: 40, per_level: 5, note: "+10%" }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { name: "Cook", base: 45, per_level: 5, note: "+10%" }
    - { name: "Preserve Food", base: 35, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two ancient W.P.s of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be upgraded to Expert for one O.C.C. Related skill, or to Martial Arts for two." }
    - { name: "Holistic Medicine", base: 98, per_level: 0, note: "The Earth Shaman''s element skill, at 98% (printed 66)." }
  occ_related_skills:
    count: 9
    schedule: [{ level: 3, count: 2 }, { level: 7, count: 2 }, { level: 11, count: 2 }, { level: 15, count: 2 }]
    categories:
      - "Cowboy"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", note: "Sniper, if taken, is with bow and arrow or spear." }
      - { name: "Horsemanship", note: "The book''s Pilot line allows horsemanship; this catalog files it as a category of its own." }
      - { name: "Medical", only: ["Animal Husbandry", "Brewing"], bonus: 10 }
      - { name: "Military", only: ["Camouflage", "Recognize Weapon Quality", "Trap Construction", "Trap/Mine Detection"] }
      - { name: "Physical", except: ["Wrestling", "Acrobatics"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak"] }
      - { name: "Rogue", only: ["Streetwise"], bonus: 6 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", bonus: 10, note: "Art, language and lore skills only." }
      - { name: "Weapon Proficiencies", note: "Ancient weapons. A revolver or bolt-action rifle only with the G.M.''s leave, and never for a Pure One." }
      - { name: "Wilderness", bonus: 10 }
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 10, count: 2 }, { level: 14, count: 2 }]
special_abilities:
  - name: "Earth Shaman"
    description: "The element is his totem. senses any natural mineral he concentrates on within 200 feet 45% +5% per level and identifies any mineral on sight; senses seismic disturbances within 40 miles 40% +5% per level and dangers in earth or rock 32% +5% per level; land navigation 60% +4% per level. Half damage from falls of under 100 feet (a quarter if he rolls with it), and keeps his feet in quakes or knock-downs 62% +2% per level, even struck by a giant robot."
  - name: "Speak with Elementals"
    description: "Understands the secret language of True Elementals 30% +3% per level, and speaks freely with Elemental Spirits, who understand that language perfectly and can translate."
  - name: "Sense Elemental Spirits"
    description: "Instantly recognizes other Elemental Shamans and their element, Warlocks, and Elemental Spirits in any guise, host or form. Senses a True Elemental or Spirit within 120 feet without pinpointing it, and has a 01-75% chance to sense invisible spirits, elementals or creatures tied to the four elements."
  - name: "Summon Elemental Spirits"
    description: "Summons Lesser Elemental Spirits of his element - never True Elementals - one per every third level from level one, once a day, through a 2D6-minute ritual of chant, dance and song within a laid-out circle: 15% +5% per level, +10% on a ley line, +20% at a nexus. The spirit helps as it chooses, will not do what the Shaman can do himself, and cannot be commanded."
  - name: "Shaman''s Blessings"
    description: "Speaks the secret tongue by which Shamans recognize one another and talk unheard. His personal equipment is touched by the spirits and works only for him unless he gives it away before he dies. Makes and empowers five minor and two major fetishes per level, expected to give half away (printed 49-50)."
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "small-sack", qty: 3 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { choose: 1, label: "canteen or waterskin", qty: 1, from: ["canteen", "water-skin"] }
  - { item_id: "knife", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Must be of Native American descent and a Traditionalist or Pure One (printed 67)."
  - "Serves ONE of the four elements, chosen at creation; unlike a Warlock he reveres all four but cannot switch."
  - "Technical related skills are limited to art, language and lore skills."
  - "Cybernetics: none, and will never consider any, with the possible exception of bio-systems to repair grievous injury."
side_effects: "Weapons of stone - traditional arrowheads, stone-bladed spears and tomahawks, even sling stones - inflict double damage on an Elemental Shaman."
extraction_notes: "Rifts World Book 15: Spirit West printed 65-67, read from the text layer. No hit point or S.D.C. formula is printed, so compose.js supplies both (1D6 S.D.C. as a practitioner of magic). P.P.E. prints as 2D4x 10+20 and is read as 2D4x10+20; trade goods read as 2D6x100 (BOOK-INGEST-AUDIT F53). The class is split by element (BOOK-INGEST-AUDIT F63), the way the Warlocks are: this is the Earth Shaman, so the element is the class rather than a choice, and its 98% Holistic Medicine is an O.C.C. skill. Spells: three Warlock elemental spells of the chosen element - the book points at Conversion Book One and Federation of Magic for the list, and the catalog''s Book of Magic Air:, Earth:, Fire: and Water: rows are the Warlock spheres - stored as a starting group of the 11 level-one Earth rows; plus two Shamanistic spells per level no higher than the character''s own level. At level one only Dowsing and Nose of the Wolf qualify. From level two each grant''s list is capped at the character''s own level by spell_levels: up_to_character_level (BOOK-INGEST-AUDIT F61). Paradox spells are left out of that list: printed 81 reserves them to Temporal Raiders, Temporal Wizards and Paradox Shamans. The element replaces the animal totem for this class (printed 65), so BOOK-INGEST-AUDIT F56 does not apply to it. No starting fetishes are listed for this class."
---

# Elemental Shaman

**Alignments.** Any, but the spirits tend to avoid selfish people.

Like a Warlock in his bond with one element - earth, water, fire or air - but
linked to Elemental Spirits rather than True Elementals, and serving the gods
and great elemental spirits where a Warlock serves none. Where the Warlock sees
unrestrained forces, the Elemental Shaman sees a great circle of interlocking
systems, every element dependent on the others and on the animals, plants and
people within the Circle of Life.

## Lore

Elemental Spirits treat their Shamans as brothers - intelligent, friendly, and
free to help or not; an offended one may refuse even an apology. The Shaman is
held to the doctrines of all Native Americans and expected to live them as an
example to others.

## Equipment the catalog cannot hold yet

Ceremonial garments and a headdress or animal skin, a hooded cloak, moccasins,
a shovel, a hand axe, 50 feet of rope, a week of dried food, a mixing bowl, a
grinding stone and flint. Two S.D.C. weapons of choice, typically a staff or
spear and a tomahawk.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'elemental-shaman-earth');

SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'elemental-shaman-earth';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-elemental-shaman-earth-class.sql');
