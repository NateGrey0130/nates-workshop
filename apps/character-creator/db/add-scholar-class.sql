-- The Scholar O.C.C., Palladium Fantasy main book, printed pp.97-98.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-scholar-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-scholar-class.sql
--
-- Read with scripts/read-columns.py. Apply add-hard-leather-gear.sql first or
-- alongside; it sorts ahead of this file so a rebuild does it for you.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE ONLY CLASS IN THE BOOK THAT STARTS WITH NO HAND TO HAND SKILL. Every
-- other O.C.C. grants one and prices an upgrade; the scholar grants none and
-- prices the entry: "Hand to hand: basic can be selected for the cost of one
-- other skill, expert for the cost of two, martial arts for the cost of three."
--
-- So occ_skills carries no fighting style at all. That is the page, not an
-- omission, and it is stated in restrictions and on the Physical category note
-- so a player reading either one finds it. What the scholar buys with that is
-- reach: twelve related skills at first level and two more at each of levels
-- three, six, nine and twelve, out of almost every category in the game - the
-- widest list in the chapter by some distance.
--
-- LITERACY IS TWO GRANTS, NOT ONE. "Literacy in Native tongue and one language
-- of choice (+20% each)" is two separate skills, and the catalog has a row for
-- each: Literacy: Native Language (40% base, so 60 here) and Literacy (30%
-- base, so 50). Read as one grant the character would come out a whole skill
-- short and literate in one language instead of two.
--
-- THE LORE OF CHOICE IS OFFERED FROM EIGHT ROWS, NOT FIFTEEN. The catalog's
-- Lore family is cross-system and includes Lore: D-Bee, Lore: Juicers, Lore:
-- Nightbane, Lore: Nightlands and Lore: Galactic/Alien, which belong to other
-- settings entirely. Offering a Palladium scholar Juicer lore would be the
-- cross-system untagging working exactly as intended and producing a nonsense
-- option, so the `from` list names the eight that fit: Astral, Demons &
-- Monsters, Dimensions, Faeries & Creatures of Magic, Magic, Psychics &
-- Psionics, Religion, Vampires.
--
-- TWO ROLLS AGAINST BUNDLED CATALOG ROWS. The book gives 2D4 sticks of charcoal
-- and 4D4 sheets of parchment; the catalog prices a dozen of each as one row.
-- One unit of each is granted rather than converting a roll into a fraction of
-- a bundle, which the qty field cannot express and which would read as
-- precision nobody has. Food rations are the opposite case - catalogued by the
-- week, and the book says 1D4 weeks - so there the quantity IS the roll.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'scholar', 'Scholar', 'palladium-fantasy', '---
id: scholar
name: Scholar
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 11 }
starting_money: "180"
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%" }
    - { name: "Literacy", base: 50, per_level: 5, note: "One further language of choice (+20%)" }
    - { choose: 1, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 20, note: "One lore of choice (+20%). The list is the Palladium-appropriate lores; the catalog also holds Rifts-only ones." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice" }
  occ_related_skills:
    count: 12
    categories:
      - { name: "Communications", note: "+10%" }
      - { name: "Domestic", note: "+10%" }
      - { name: "Espionage", only: ["Forgery"], note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Heraldry"], note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two, Martial Arts three. The class grants no fighting style of its own." }
      - "Rogue"
      - { name: "Science", note: "+10%" }
      - { name: "Technical", note: "+15%" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
  secondary_skills:
    count: 5
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: "1d4" }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "charcoal-dozen-sticks", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 2 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "parchment-dz-9x12-inch-sheets", qty: 1 }
  - { item_id: "book-paper-glued-100-sheets", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "hard-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 1, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is hard leather (A.R. 11, 30 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "Starting weapons are basic S.D.C. weapons of good quality. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The scholar starts with NO hand to hand combat skill. Basic costs one related skill, Expert two, Martial Arts three - the steepest price any class in the book pays for a fighting style, and the reason a scholar is not a fighter who reads."
extraction_notes: "The one lore of choice is offered from the eight Palladium-appropriate rows; the catalog also carries Lore: D-Bee, Juicers, Nightbane, Nightlands and Galactic/Alien, which belong to other settings. Literacy in the native tongue and in one further language are two separate grants, on the Literacy: Native Language and Literacy rows. The book counts 2D4 sticks of charcoal and 4D4 sheets of parchment where the catalog prices a dozen of each, so one unit of each is granted rather than converting a roll into a fraction of a bundle. Food rations are catalogued by the week and the book gives 1D4 weeks, so the quantity is the roll. The weapon of choice enumerates the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category."
---

# Scholar

## Lore

The scholar of the Palladium world can be a man of science or medicine, a
historian and story-teller, an archaeologist, a teacher, a writer, a
philosopher, or a jack of all trades. Some are bookworms and some prefer to
experience things for themselves, but all of them have a curious mind and a
desire to learn.

Those who take up a life of adventure are ambitious, inquisitive and anxious to
learn more about their world, its past, its people and its mysteries. If these
adventurous souls have one disadvantage, it is that they are not always prepared
for the rigours, challenges and secrets that a life of adventure provides.

## Alignment

Any.

## GM Notes

One of the book''s Optional O.C.C.s, and the widest-reaching skill list in the
chapter: twelve related skills at first level and two more at each of levels
three, six, nine and twelve, drawn from almost every category. What pays for
that breadth is combat. The scholar is the only class in the book that starts
with no hand to hand skill at all, and buying the most basic one costs a
related skill.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'scholar');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'scholar';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 6 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('hard-leather', 'charcoal-dozen-sticks', 'crow-quill-pen',
                'ink-black-6-ounces', 'parchment-dz-9x12-inch-sheets',
                'book-paper-glued-100-sheets');
-- Both literacy rows have to exist, or the class grants one where it means two.
SELECT count(*) AS literacy_rows FROM skills
 WHERE name IN ('Literacy', 'Literacy: Native Language');
-- All eight lores the choice offers.
SELECT count(*) AS lore_options FROM skills
 WHERE name IN ('Lore: Astral', 'Lore: Demons & Monsters', 'Lore: Dimensions',
                'Lore: Faeries & Creatures of Magic', 'Lore: Magic',
                'Lore: Psychics & Psionics', 'Lore: Religion', 'Lore: Vampires');

INSERT INTO data_script_runs (filename) VALUES ('add-scholar-class.sql');
