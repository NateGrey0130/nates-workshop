-- The Druid O.C.C., Palladium Fantasy main book, printed pp.73-78.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-druid-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-druid-class.sql
--
-- Read with scripts/read-columns.py. Needs History, which
-- add-arcane-catalog-rows.sql added for the Summoner; the druid is its second
-- user and that file sorts first either way.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE LONGEST PER-LEVEL POWER LIST IN THE BOOK, AND ALMOST NONE OF IT IS A
-- CHOICE. The druid gains named Druidic Magic Powers at levels one through
-- nine - Healing Touch (animals), Chameleon, Faerie Speak, Negate
-- Poisons/Toxins, Familiar Link, Prophecy, Extinguish Fire, Kindle Flame,
-- Metamorphosis: Animal, Summon and Control Canines, Purification, Phoenix
-- Healing, Divination, Protection Charm, Water to Wine, Witch Bottle and
-- Weather Control - most cross-referenced to a wizard spell of the same name.
--
-- They are recorded in `level_progression` in the book's own wording, because
-- there is nothing to select: the character gets them, in that order, at those
-- levels. The `magic` block covers only the part that IS a selection - two
-- wizard spells from levels 1-3 at each of levels ten through fifteen.
--
-- That split is the whole modelling decision here, and it is the opposite of
-- the Wizard's. A wizard picks almost everything; a druid picks almost nothing
-- until tenth level.
--
-- ROGUE IS OMITTED ENTIRELY. The book allows "Recognize and Use Poison only",
-- and that skill has no catalog row. A Rogue category here would render a
-- heading in the picker with nothing under it, which is worse than not listing
-- it. Communications is omitted because the book says None.
--
-- HAND TO HAND: BASIC ONLY, with no upgrade offered at any price - a
-- restriction the druid shares with no other class in this book. The Warrior
-- Monk is locked to Martial Arts the same way, in the opposite direction.
--
-- DRUIDS DISLIKE PROCESSED IRON, so the weapon lists are narrowed by hand to
-- wood and stone as the page describes - the same exception the Warrior Monk
-- needed, and for the same reason: the book is restricting the weapon, not the
-- proficiency. The starting "sharp stone dagger (1D6 damage)" resolves to the
-- stone axe row, the only chipped-stone weapon the catalog prices. A sprig of
-- mistletoe and a clove of garlic are in the kit and priced nowhere.
--
-- Recognize Enchantment is granted at the druid's printed 35% rather than the
-- catalog's 10%, the same call the Wizard needed. Lore: Faerie Folk resolves to
-- Lore: Faeries & Creatures of Magic.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'druid', 'Druid', 'palladium-fantasy', '---
id: druid
name: Druid
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 9, PE: 12 }
ppe_base: "1D4x10 plus the P.E. attribute number, +1D6 per level of experience starting at level one"
starting_money: "100"
bonuses:
  saves: { horror_factor: 4 }
  at_level:
    - { level: 2, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 10, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }
magic:
  type: "druid"
  spells_schedule:
    - { level: 10, count: 2, spell_levels: [1, 2, 3], note: "From tenth level and up, two wizard spells from levels 1-3 with each new level of experience" }
    - { level: 11, count: 2, spell_levels: [1, 2, 3] }
    - { level: 12, count: 2, spell_levels: [1, 2, 3] }
    - { level: 13, count: 2, spell_levels: [1, 2, 3] }
    - { level: 14, count: 2, spell_levels: [1, 2, 3] }
    - { level: 15, count: 2, spell_levels: [1, 2, 3] }
skills:
  occ_skills:
    - { name: "Animal Husbandry", base: 55, per_level: 5, note: "+20%" }
    - { name: "Anthropology", base: 35, per_level: 5, note: "+15%" }
    - { name: "Astronomy & Navigation", base: 45, per_level: 5, note: "+15%" }
    - { name: "Botany", base: 45, per_level: 5, note: "+20%" }
    - { name: "History", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { name: "Lore: Faeries & Creatures of Magic", base: 45, per_level: 5, note: "Lore: Faerie Folk (+20%)" }
    - { choose: 1, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 10, note: "One further lore of choice (+10%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Recognize Enchantment", base: 35, per_level: 5, note: "A druid O.C.C. ability, not the catalog base. -20% when examining humanoids." }
    - { name: "W.P. Staff", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Basic ONLY. No upgrade is offered at any price." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Domestic", note: "+10%" }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", note: "+15%" }
      - { name: "Military", only: ["Camouflage", "Falconry"], note: "Both +10%" }
      - { name: "Physical", except: ["Acrobatics", "Boxing", "Wrestling"] }
      - { name: "Science", note: "+15%" }
      - { name: "Technical", note: "+10%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Targeting", "W.P. Lance", "W.P. Pole Arm"], note: "The book also excludes Siege and Large Axes, which have no catalog rows." }
      - { name: "Wilderness", note: "+10%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 7, count: 2 }, { level: 10, count: 2 }, { level: 13, count: 2 }]
natural_abilities:
  - name: "Druid Versification"
    description: "The oral tradition. Alongside their knowledge of history, druids memorise and recite the lore, genealogies and law of their people in verse. Base skill 30% +5% per level of experience."
  - name: "Druid Astronomy"
    description: "The science of the sun, moon, planets and stars as the druidic faith reads them, which is not quite the same discipline as the scholar''s."
  - name: "Weather Identification"
    description: "Time spent studying the sky tells the druid what the weather is about to do."
  - name: "Forecast Weather Change"
    description: "The druid can accurately forecast a change in the weather, well beyond what simple observation gives."
  - name: "Spell Strength"
    description: "The number others must save against when this character casts. Starts at 12, +1 at levels three, six, nine, twelve and fifteen."
  - name: "Blood Sacrifice and Ritual Magic"
    description: "The druid is not a true practitioner of magic and carries considerably less P.P.E. than one. To make up the difference the character engages in ritual magic and the blood sacrifice of an animal, drawing on its P.P.E. A druid cannot draw P.P.E. from living people or animals otherwise, but can draw on ley lines and nexus points."
level_progression:
  - level: 1
    grants: ["Druidic Magic Powers: Healing Touch (animals), Chameleon, and Faerie Speak"]
  - level: 2
    grants: ["Druidic Magic Powers: Negate Poisons/Toxins, Healing Touch, and control the beasts, all as the wizard spells, plus Familiar Link - the druid may have one animal familiar"]
  - level: 3
    grants: ["Druidic Magic Power: Prophecy (general)"]
  - level: 4
    grants: ["Druidic Magic Powers: Extinguish Fire and Kindle Flame, and Communication at one mile (1.6 km) per level"]
  - level: 5
    grants: ["Druidic Magic Powers: Metamorphosis: Animal, Summon and Control Canines, and Purification, all as the wizard spells"]
  - level: 6
    grants: ["Druidic Magic Powers: Phoenix Healing - From Death Comes Life, and Divination"]
  - level: 7
    grants: ["Druidic Magic Powers: Protection Charm, plus Water to Wine and Witch Bottle as the wizard spells"]
  - level: 9
    grants: ["Master Druid", "Druidic Magic Power: Weather Control, once per day, plus the spells Spoil, Faerie''s Dance and Monster Insect as the wizard spells"]
  - level: 10
    grants: ["Two wizard spells from levels 1-3, and two more with each subsequent level of experience"]
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { choose: 1, label: "travelling robe with hood", qty: 1, from: ["robe-hooded", "robe-heavy", "cape-long-hooded"] }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "sandals", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { choose: 1, label: "wooden or silver cross", qty: 1, from: ["large-silver-cross", "holy-symbol"] }
  - { item_id: "wooden-spike", qty: 8 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "axe-stone", qty: 1 }
  - { choose: 1, label: "wooden staff", qty: 1, from: ["long-staff", "short-staff", "quarterstaff", "bo-staff"] }
  - { choose: 1, label: "weapon of choice", qty: 1, from: ["long-staff", "short-staff", "quarterstaff", "bo-staff", "long-spear", "short-spear", "club-stick-pipe", "war-club", "cudgel", "maul", "axe-stone", "sling", "short-bow", "long-bow", "war-hammer", "hercules-club"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.)."
  - "Hand to Hand: Basic ONLY. No upgrade is offered at any price, which the druid shares with no other class in the book."
  - "DRUIDS DISLIKE PROCESSED IRON AND METAL and avoid it except in the most extreme circumstances. Weapons are wood, stone, or a combination: staves, spears, clubs, hammers and blunt weapons, slings and bows, with knives and short swords likely to be chipped or chiselled stone. The weapon of choice list is narrowed to those. Most druids will use a holy or rune weapon made of iron despite the aversion, though a magic wood, stone or flaming weapon is preferred."
  - "The starting dagger is a sharp STONE dagger doing 1D6 damage; the stone axe row stands in for it, being the only chipped-stone weapon the catalog prices."
  - "Communications skills are not available to this class at all."
  - "Most druids spend their money on nurturing and protecting nature and prefer living off the land, with no desire for property. Some collect gems and jewellery as part of nature''s beauty; silver and gold count as natural and may be used."
  - "The kit also calls for a sprig of mistletoe and a clove of garlic, neither of which the book prices anywhere."
extraction_notes: "The druidic magic powers are a fixed per-level list, most of them cross-referenced to a wizard spell, so they are recorded in level_progression as the book''s own wording rather than as spell picks - there is nothing to choose. Only the tenth-level-and-up grant is a genuine selection, and that is the whole of the `magic` block: two wizard spells from levels 1-3 at each of levels 10 through 15. Rogue is omitted entirely: the book allows Recognize and Use Poison only, and that skill has no catalog row, so a Rogue category here would offer nothing under a heading saying it should. Lore: Faerie Folk resolves to Lore: Faeries & Creatures of Magic. History is the row added by add-arcane-catalog-rows.sql. Recognize Enchantment is granted at the druid''s printed 35% rather than the catalog''s 10%, the same call the Wizard needed."
---

# Druid

## Lore

The druid is the woodland priest: historian, astronomer, healer, weather-reader
and keeper of an oral tradition recited in verse. The faith arose as a
male-dominated belief in a male God of Nature and remains largely so, though all
species and both sexes are accepted as initiates.

A druid is not a true practitioner of magic and the book is explicit about it -
considerably less P.P.E. than a wizard, and powers granted by the faith at set
levels rather than studied out of a book. What makes up the difference is ritual
and sacrifice: a druid draws P.P.E. from a sacrificed animal, from ley lines and
from nexus points, but never from a living person.

Iron is the other thing that marks them. Druids dislike processed metal and
avoid it except at the extreme, working instead in wood and stone - staves,
spears, clubs, slings and bows, with knives and short swords chipped from stone.

## Alignment

Any, but most are good, unprincipled or aberrant.

## GM Notes

Money means little to a druid. Most spend it on nurturing and protecting nature,
prefer to live off the land, and want no house and no servants. Some collect
gems and jewellery, which count as part of nature''s beauty; silver and gold are
natural too and may be handled freely.

The per-level power list is long and mostly cross-referenced to wizard spells,
so a druid at ninth level has a wide, strange toolkit that no other class
assembles the same way - Faerie Speak and Familiar Link early, Metamorphosis:
Animal and Purification in the middle, and Weather Control once a day at the
top.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'druid');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'druid';
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'ceremonial-robe', 'sandals', 'axe-stone', 'large-silver-cross');
-- Expect 0. History arrived with the previous batch; the druid is its second user.
SELECT 2 - count(*) AS missing_skills FROM skills
 WHERE name IN ('History', 'Recognize Enchantment');

INSERT INTO data_script_runs (filename) VALUES ('add-druid-class.sql');
