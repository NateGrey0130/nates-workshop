-- The Wizard O.C.C., Palladium Fantasy main book, printed pp.106-107.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-wizard-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-wizard-class.sql
--
-- Read with scripts/read-columns.py. Apply add-arcane-catalog-rows.sql first or
-- alongside; it sorts ahead of this file so a rebuild does it for you.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE FIRST PALLADIUM FANTASY SPELL CASTER. Twelve Palladium classes are in and
-- not one has carried a `magic` block; this one does, and the shape of it is
-- where the interesting decisions are.
--
-- THE SIX COMMON KNOWLEDGE SPELLS ARE FIVE SPELLS AND A RITUAL. The page lists
-- "decipher magic, sense magic, cloud of slumber, globe of daylight, and
-- tongues, plus enchanted cauldron" and calls all six spells. The cauldron is
-- not one: no P.P.E. cost, no spell level, and a once-per-wizard brew that
-- grants a random handful of spell knowledge. Putting it in the spell list
-- would have created a catalog row nothing could cost or cast, so it is a
-- special ability and the magic block names five.
--
-- CLOUD OF SLUMBER IS AN AIR WARLOCK SPELL. That reads like a transcription
-- error and is not. The only Cloud of Slumber this book prints is the
-- first-level Air elemental spell at 4 P.P.E. (p218); the level-one invocation
-- list at p187 has no such entry. So the wizard's grant resolves to
-- "Air: Cloud of Slumber", already in the catalog under the element-qualified
-- name add-elemental-spells.sql gave it.
--
-- Decipher Magic was the one of the five the catalog lacked;
-- add-arcane-catalog-rows.sql adds it at the printed level 1, 4 P.P.E.
--
-- THE FOUR EXTRA PICKS ARE BANDED BY SPELL LEVEL, WHICH spells_starting CANNOT
-- SAY. The book gives "two spells of choice each level one and two, and one
-- from level three and four" - four picks from four different bands, not four
-- from one pool. spells_starting is a single count against a single
-- spell_levels_allowed and cannot express it. Modelled as four spells_schedule
-- entries all at character level 1, each carrying its own spell_levels. Then
-- spells_per_level: 1 with up_to_character_level covers "at each new level of
-- experience, one new spell from any level up to your own".
--
-- NO HAND TO HAND, AND NOT FOR THE SCHOLAR'S REASON. Like the Scholar the
-- wizard starts with none and buys it out of related skills. Unlike the
-- Scholar, Martial Arts and Assassin are forbidden at ANY price. That is a
-- restriction rather than a cost, so it is stated in restrictions and on the
-- Physical category note instead of being left for a reader to infer from an
-- option that is quietly absent.
--
-- Large Axes has no catalog row, so the weapon-proficiency exclusion names only
-- Lance and Pole Arm, and says so.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'wizard', 'Wizard', 'palladium-fantasy', '---
id: wizard
name: Wizard
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 10 }
ppe_base: "3d4x10+20 plus the P.E. attribute number, +3d6 per level of experience starting at level one"
starting_money: "140"
bonuses:
  saves: { horror_factor: 4 }
  at_level:
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 9, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 15, saves: { spell_magic: 1, ritual_magic: 1 } }
magic:
  type: "spell"
  spells: ["Decipher Magic", "Sense Magic", "Air: Cloud of Slumber", "Globe of Daylight", "Tongues"]
  spells_schedule:
    - { level: 1, count: 2, spell_levels: [1], note: "Two spells of choice from level one" }
    - { level: 1, count: 2, spell_levels: [2], note: "Two spells of choice from level two" }
    - { level: 1, count: 1, spell_levels: [3], note: "One spell of choice from level three" }
    - { level: 1, count: 1, spell_levels: [4], note: "One spell of choice from level four" }
  spells_per_level: 1
  spells_per_level_levels: up_to_character_level
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Dragonese/Elven", "Literacy: Other"], bonus: 15, note: "Literate in two languages of choice (+15%)" }
    - { name: "Lore: Magic", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15, note: "One further lore of choice (+15%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Recognize Enchantment", base: 35, per_level: 5, note: "A wizard O.C.C. ability, not the catalog base: charms, hypnosis, mind control, magic sickness, curses, faerie food and possession. Illusions, metamorphosis and psionics do not count." }
    - { name: "Recognize Magic", base: 20, per_level: 5, note: "Recognises that an item is magical by shape, inscription, symbol or intuition; not what it does or how to use it." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice" }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", note: "+5%" }
      - { name: "Domestic", note: "+5%" }
      - { name: "Espionage", only: ["Forgery", "Escape Artist", "Intelligence"], note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two. Martial Arts and Assassin are not available to this O.C.C. at any price." }
      - "Rogue"
      - { name: "Science", note: "+10%" }
      - { name: "Technical", note: "+10%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance", "W.P. Pole Arm"], note: "Any except Large Axes, Pole Arms and Lance; the catalog has no Large Axes row." }
      - { name: "Wilderness", only: ["Dowsing", "Identify Plants & Fruit", "Preserve Food", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 7, count: 2 }, { level: 10, count: 2 }, { level: 13, count: 2 }]
special_abilities:
  - { name: "Enchanted Cauldron", description: "The sixth of the six common knowledge spells, and not a spell at all: a ritual the apprentice is given at the end of training. Brewed and drunk, the cauldron grants a one-time gift of spell knowledge. Roll to see how many new spells are gained, then 1D6 per spell for its level, and pick a spell of that level; only levels one through six can be learned this way. It works once per wizard, and over 70% never use it. It has no P.P.E. cost and no spell level, so it is recorded here rather than in the spell list." }
  - { name: "See and Use Ley Lines", description: "Sees the lines of magic energy crossing the earth, and the nexus points where two or more meet, as places of power where P.P.E. can be drawn and spells are strengthened. Also sees mystic energy radiating from ancient dragons, demon and deevil lords, godlings and gods, and from the greatest magic items. The Palladium World''s ley lines are weaker than those of Rifts Earth and are invisible to anyone who is not a practitioner of magic or a creature of magic." }
  - { name: "Ley Line Drifting", description: "Walks or floats along the length of a ley line at a maximum Spd of 10, drawing on the ambient energy rather than personal P.P.E. Relaxing, and causes no exertion or fatigue. The wizard cannot carry anyone else along." }
  - { name: "Ley Line Rejuvenation", description: "Standing on a ley line or nexus and concentrating doubles the natural rate of healing. Once every 24 hours the wizard can instead take about ten minutes to restore 2D6 hit points and 2D6 S.D.C. outright, spending no personal P.P.E." }
  - { name: "Spell Strength", description: "The number others must save against when this character casts. Starts at 12, +1 at levels two, four, eight, twelve and fifteen." }
  - { name: "Learning New Spells", description: "Spells and ritual magic of any level can be learned or bought at any time regardless of the wizard''s own level, given an instructor and the price, which is not always cash." }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "robe or hooded cloak", qty: 1, from: ["robe-hooded", "cape-long-hooded", "robe-heavy", "robe-light"] }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "parchment-dz-9x12-inch-sheets", qty: 1 }
  - { item_id: "book-paper-glued-100-sheets", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 3 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "ink-color-6-ounces", qty: 1 }
  - { item_id: "charcoal-dozen-sticks", qty: 1 }
  - { item_id: "chalk-dozen-sticks", qty: 1 }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 1, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "The wizard starts with NO hand to hand skill. Basic costs one related skill and Expert two; Martial Arts and Assassin are not available to this O.C.C. at any price."
  - "Weapon proficiencies exclude Large Axes, Pole Arms and the Lance. Favourite weapons are the knife, short sword, staff, blunt weapons, sling and cross bow."
  - "A wooden cross is part of the starting kit; the catalog prices no plain wooden one, only the large silver cross."
  - "Pay for hired work runs 50-150 gold for the simplest task to 3000-12,000 for dangerous assignments, roughly a long bowman''s salary below 5th level and an officer''s at 5th and above. Armies like to use wizards and warlocks as artillery, though most wizards find military life too restrictive and many men of arms do not trust them."
extraction_notes: "The six common knowledge spells are five spell rows plus the Enchanted Cauldron, which is a ritual with no P.P.E. cost or spell level and is recorded as a special ability instead. Cloud of Slumber resolves to Air: Cloud of Slumber - the only Cloud of Slumber the book prints is the first-level Air warlock spell at 4 P.P.E., which is what the wizard is being given. Decipher Magic is added to the catalog by this batch. The four extra picks - two from level one, two from two, one from three, one from four - are modelled as four level-1 schedule entries rather than spells_starting, because spells_starting cannot band picks by spell level. Large Axes has no catalog row, so the weapon-proficiency exclusion names only Lance and Pole Arm."
---

# Wizard

## Lore

The wizard is the Palladium world''s student of spell magic: a scholar who has
spent two to five years as somebody''s apprentice, cooking and cleaning and
copying, and come out the other side with a basic education, literacy in two
languages, and six spells.

Wizards see what other people cannot. Ley lines cross the earth carrying mystic
energy, meeting at nexus points, and only practitioners of magic and creatures
of magic can see the gentle flow of them. A wizard can draw on that energy, walk
along it, and heal on it. He can also see it radiating from ancient dragons,
demon and deevil lords, godlings and gods, and from the greatest of magic items.

## Alignment

Any.

## GM Notes

Practitioners of magic are sought after by royalty, merchants, wealthy travellers
and the military, as mercenaries, freelance agents and infiltrators. Military
operations like to use wizards and warlocks as artillery, striking at range with
fire ball, call lightning, wind rush and fog. Most wizards find military life too
restrictive and mundane, and many men of arms are uncomfortable around sorcerers
until the mage has proven himself in several battles.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'wizard');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'wizard';
-- Expect 5. All five named spells must resolve, or the character starts short.
SELECT count(*) AS common_knowledge_spells FROM spells
 WHERE name IN ('Decipher Magic', 'Sense Magic', 'Air: Cloud of Slumber',
                'Globe of Daylight', 'Tongues');
-- Expect 0. Both O.C.C. percentile abilities need their catalog rows.
SELECT 2 - count(*) AS missing_skills FROM skills
 WHERE name IN ('Recognize Enchantment', 'Recognize Magic');
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'boots-soft-leather', 'chalk-dozen-sticks',
                'candle-long-burning-3-hours', 'ink-color-6-ounces');

INSERT INTO data_script_runs (filename) VALUES ('add-wizard-class.sql');
