-- The Merchant O.C.C., Palladium Fantasy main book, printed p96.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-merchant-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-merchant-class.sql
--
-- Read with scripts/read-columns.py. Apply add-hard-leather-gear.sql first or
-- alongside; it sorts ahead of this file so a rebuild does it for you.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE FIRST OF THE OPTIONAL O.C.C.s, and the first Palladium Fantasy class on
-- the 1D6 side of CORE_SDC_BY_CLASS. Every Palladium class so far has been a
-- man of arms rolling 3D6; the merchant, the noble and the scholar are the
-- book's own "Optional O.C.C.s" heading and fall under the other half of the
-- core rule - practitioners of magic, scholars and everyone else.
--
-- ITS THREE LAST LINES PRINT UNDER SOMEBODY ELSE'S. The Merchant's Armor,
-- Weapons and Money sit in the third column of the page, directly below the
-- Assassin's Armor, Weapons and Money, with no heading between the two sets.
-- Geometry puts them in reading order and stops there; the text is what
-- attributes them:
--
--   Assassin  studded leather, a pair of daggers and three more weapons of
--             VERY GOOD quality, "assassins are often familiar with a wide
--             range of weapons", money from "assassination and combat jobs"
--   Merchant  hard leather, a knife and two more weapons of FAIR TO GOOD
--             quality, and a starting kit of a notebook, two crow quill pens
--             and a bottle of ink
--
-- Both start with 200 gold, so the money line alone separates nothing.
--
-- FOUR BARE NOUNS AGAINST A CATALOG THAT PRICES VARIANTS. The book asks for "a
-- hat", "blanket", "a notebook" and "a small lantern"; the catalog holds three
-- hats, two blankets, three books and five lanterns. The plainest row is
-- granted in each case rather than an equipment choice, because the book is not
-- offering the character an option - it simply did not specify, and a choice
-- the wizard blocks on would invent a decision the page never asked for.
--
-- Food rations are catalogued by the week and the book gives 1D4 weeks, so the
-- quantity is the roll rather than a rounded guess.
--
-- MULTIPLE O.C.C.s ARE PROSE ONLY. This is the one class in the chapter that
-- says "Multiple O.C.C.s are possible as long as the character has the required
-- attributes", and the character model stores a single class_id - the same
-- limitation an R.C.C. taken alongside an O.C.C. runs into, already recorded
-- under known limitations. Kept in restrictions where a human reads it.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'merchant', 'Merchant', 'palladium-fantasy', '---
id: merchant
name: Merchant
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 10 }
starting_money: "200"
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Two languages of choice (+10% each)" }
    - { name: "Literacy", base: 40, per_level: 5, note: "One language of choice, usually native or elf (+10%)" }
    - { name: "Public Speaking", base: 40, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of two other skills, or to Martial Arts for the cost of three." }
  occ_related_skills:
    count: 10
    categories:
      - { name: "Communications", note: "+10%" }
      - { name: "Domestic", note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Carpentry", "Preserve Food", "Land Navigation"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: "1d4+2" }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "wine-good", qty: 1 }
  - { item_id: "food-rations", qty: "1d4" }
  - { item_id: "book-paper-glued-100-sheets", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 2 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "oil-lantern-6-hours-1-pint", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "hard-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is hard leather (A.R. 11, 30 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "Starting weapons are basic S.D.C. weapons of fair to good quality, a grade below what the men of arms carry. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "Multiple O.C.C.s are possible for this character, so long as the attribute requirements of each are met."
extraction_notes: "The Merchant''s Armor, Weapons and Money lines print in the third column of the page, directly below the Assassin''s three, with no heading between them; they are attributed by the notebook and quill-pen kit and the fair-to-good weapon grade, against the Assassin''s studded leather and wide weapon familiarity. The book says a bare hat, blanket, notebook and small lantern where the catalog prices several of each, so the plainest row is granted in every case. Food rations are catalogued by the week and the book gives 1D4 weeks, so the quantity is the roll. Two weapons of choice enumerate the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category. Multiple O.C.C.s are prose only: the character model stores one class_id, which is the same limitation an R.C.C. plus O.C.C. runs into."
---

# Merchant

## Lore

A character with a background in trade, typically a small-time businessman or
from a family involved in business. Most became adventurers to make a fortune in
the world or to find a new profitable venture; others simply gave up a
sedentary and restrictive life behind a counter for the road.

The merchant is the Palladium world''s other kind of competence: numerate,
literate, persuasive, and able to hold a room. What he does not have is
training. His hand to hand is the basic grade, his weapons are fair to good
rather than very good, and upgrading either costs him two or three of the
skills that make him a merchant in the first place.

## Alignment

Any.

## GM Notes

This is one of the book''s Optional O.C.C.s, offered for players who want a
character whose competence is not martial. It is also the only class in the
chapter that explicitly permits stacking: "Multiple O.C.C.s are possible as long
as the character has the required attributes."
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'merchant');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'merchant';
-- Every slug this class grants outright must already be a real catalog row.
SELECT 6 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('hard-leather', 'hat-short-brim', 'blanket-light',
                'book-paper-glued-100-sheets', 'crow-quill-pen', 'food-rations');
SELECT count(*) AS stub_gear FROM gear
 WHERE slug = 'hard-leather' AND description LIKE 'STUB%';

INSERT INTO data_script_runs (filename) VALUES ('add-merchant-class.sql');
