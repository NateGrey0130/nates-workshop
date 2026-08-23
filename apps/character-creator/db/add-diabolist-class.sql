-- The Diabolist O.C.C., Palladium Fantasy main book, printed pp.117-120.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-diabolist-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-diabolist-class.sql
--
-- Read with scripts/read-columns.py. Apply add-arcane-catalog-rows.sql first or
-- alongside; it sorts ahead of this file so a rebuild does it for you.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE SECOND PRACTITIONER OF MAGIC WITH NO `magic` BLOCK, and for the same
-- reason as the Summoner: the diabolist casts no spells and cannot learn them.
-- The whole of the class's magic is WARDS - mystic symbols that hold, direct
-- and release magic energy, placed now and triggered later. Each symbol is
-- drawn with its own components and energised by its power word and P.P.E.: one
-- point for a simple ward symbol, five for the power symbol, twenty for the
-- permanence symbol, and nothing works until the last symbol of the phrase is
-- drawn and energised.
--
-- There is no ward catalog and no schema for one, so the mechanics are recorded
-- as special abilities and the class carries no `magic` key. The sheet shows a
-- diabolist no spell list, which is right, because the character has none. A
-- ward catalog would sit under this class rather than change it.
--
-- WARD STRENGTH IS NOT SPELL STRENGTH. It starts at 14 where a wizard's spell
-- strength starts at 12, rises at levels five, ten and fifteen, and the
-- diabolist is impervious to their own wards. Nothing in `bonuses` models a
-- ward, so it is a special ability with the numbers in it.
--
-- THREE PERCENTILE ABILITIES RESOLVE TO CATALOG ROWS AND ONE DOES NOT.
--
--   Mystic Symbology      -> Recognize Wards, Runes & Circles (15% +5%)
--   Recognize Enchantment -> Recognize Enchantment, granted at the diabolist's
--                            own 20% rather than the catalog's 10%
--   Recognize Magic       -> Recognize Magic, added by
--                            add-arcane-catalog-rows.sql at 20% +5%
--   Literacy: Runes       -> nothing. 88% +1% per level matches no catalog
--                            literacy row and is not a percentage any of them
--                            could be bent to, so it is a special ability.
--
-- LITERACY: ELVEN IS GRANTED FLAT AT 98%, which is what the page prints - not
-- the catalog base plus a bonus. Every other literacy in this batch is
-- base-plus-bonus; this one is a statement.
--
-- THE THREE LANGUAGES OF CHOICE ARE TWO CHOICE GROUPS, not one. A choice group
-- cannot ask for more options than it lists, and only two catalog rows are
-- plausible language picks here - Language: Other, which is the escape hatch
-- and may be taken repeatedly, and Language: Dragonese. Split 2 + 1 so both
-- groups validate; the picker drops Dragonese from the second group once it is
-- taken, which is correct, and leaves Language: Other, which is repeatable.
--
-- Gold dust, silver dust, sawdust, two whittling knives and grinding tools are
-- in the kit and priced nowhere in the book. Recorded in restrictions rather
-- than stubbed.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'diabolist', 'Diabolist', 'palladium-fantasy', '---
id: diabolist
name: Diabolist
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 12 }
ppe_base: "2d4x10 plus the P.E. attribute number, +2d6 per level of experience starting at level one"
starting_money: "130"
bonuses:
  saves: { horror_factor: 3 }
  at_level:
    - { level: 2, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 5, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 10, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 15, saves: { spell_magic: 1, ritual_magic: 1 } }
skills:
  occ_skills:
    - { name: "Art", base: 45, per_level: 5, note: "+10%" }
    - { name: "Cryptography", base: 45, per_level: 5, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two of the three languages of choice (+20% each)" }
    - { choose: 1, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "The third language of choice (+20%). Split into two groups because a choice group cannot ask for more options than it lists, and Language: Other is the one row that may be taken repeatedly." }
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0, note: "Literacy: Elven at 98%, flat, not the catalog base." }
    - { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Other"], bonus: 20, note: "Literate in two further languages of choice (+20%)" }
    - { choose: 1, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15, note: "One lore of choice (+15%)" }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%" }
    - { name: "Whittling & Sculpting", base: 50, per_level: 5, note: "Sculpt & Whittling (+20%)" }
    - { name: "Recognize Wards, Runes & Circles", base: 15, per_level: 5, note: "Mystic Symbology: the study of ancient and modern magic symbols, and recognising and understanding magic circles." }
    - { name: "Recognize Enchantment", base: 20, per_level: 5, note: "A diabolist O.C.C. ability, not the catalog base: charms, hypnosis, mind control, magic sickness, curses, faerie food and possession. Illusions, metamorphosis and psionics do not count." }
    - { name: "Recognize Magic", base: 20, per_level: 5, note: "+20% where magic symbols or runes are involved." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice" }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", note: "+15%" }
      - "Domestic"
      - { name: "Espionage", only: ["Forgery", "Intelligence"], note: "Forgery +10%, Intelligence +5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Heraldry", "Interrogation Techniques"], note: "Both +5%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two. Martial Arts and Assassin are not available to this O.C.C. at any price." }
      - { name: "Rogue", note: "+10% on Locate Secret Compartments and Streetwise only" }
      - { name: "Science", note: "+10%" }
      - { name: "Technical", note: "+15%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance", "W.P. Pole Arm"], note: "Any except Large Axes, Pole Arms and Lance; the catalog has no Large Axes row." }
      - { name: "Wilderness", only: ["Carpentry", "Identify Plants & Fruit", "Land Navigation", "Preserve Food"], note: "Carpentry +5%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 2 }, { level: 7, count: 2 }, { level: 10, count: 2 }, { level: 13, count: 2 }]
special_abilities:
  - { name: "Ward Magic", description: "The diabolist casts no spells. Wards are mystic symbols that hold, direct and release magic energy - time-release magic, placed now and triggered later. Each symbol is made with its own physical components, then energised by speaking its power word and spending P.P.E.; the ward does nothing until the last symbol of the phrase is drawn and energised. A simple ward symbol takes one P.P.E. point, the power symbol five, and the permanence ward symbol twenty. Wards are not in any catalog and are not modelled as spells; the character sheet has no ward list." }
  - { name: "Power Words", description: "Knows every power word currently known. Legend says others exist and have been lost." }
  - { name: "Literacy: Runes", description: "Reads, understands and writes the ancient rune alphabet at 88% +1% per level of experience from first level, which also identifies authentic rune weapons and whether one is a lesser, greater or greatest weapon. Recorded here rather than as a skill because 88% +1% matches no catalog literacy row." }
  - { name: "Identify Energized Wards", description: "Senses whether a ward or ward phrase is live and waiting or spent. Base skill 25% +5% per level; half when picking out which wards in a sequence are still potent. One try only, and a failed roll means the character is not sure." }
  - { name: "Use Magic Circles", description: "Can operate or activate a magic circle whose basic function the character has worked out, though the summoner is the one who makes them." }
  - { name: "Ward Strength", description: "The number others must save against when they trigger one of this character''s wards. Starts at 14, +1 at levels five, ten and fifteen. The diabolist is impervious to their own wards." }
  - { name: "Wards Energized Per Day", description: "One ward or ward phrase per P.E. attribute point per 24 hours at first level; two per point at third, three at ninth, four at fifteenth." }
  - { name: "Read Scrolls", description: "Diabolists cannot learn spell magic, but they can read and use magic scrolls." }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cape or cloak", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 5 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "vial-glass-2-ounce", qty: 6 }
  - { item_id: "candle-long-burning-3-hours", qty: "1d6" }
  - { item_id: "wax-bees-per-lb", qty: 1 }
  - { item_id: "wax-clear-per-lb", qty: 1 }
  - { item_id: "parchment-dz-9x12-inch-sheets", qty: 1 }
  - { item_id: "book-parchment-glued-100-sheets", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 3 }
  - { item_id: "brushes-sable-hair", qty: 8 }
  - { item_id: "bowl-earthenware", qty: 3 }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "ink-color-6-ounces", qty: 1 }
  - { item_id: "charcoal-dozen-sticks", qty: 1 }
  - { item_id: "chalk-dozen-sticks", qty: 1 }
  - { item_id: "wood-cutting-tools-fine", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "The diabolist starts with NO hand to hand skill. Basic costs one related skill and Expert two; Martial Arts and Assassin are not available to this O.C.C. at any price."
  - "Weapon proficiencies exclude Large Axes, Pole Arms and the Lance. Favourite weapons are the knife, throwing knives, small axes and hatchets, swords large and small, staves and the cross bow."
  - "The kit also lists 4D4 ounces each of gold dust, silver dust and sawdust, two whittling knives and grinding tools. None of those is priced anywhere in the book, so they are recorded here rather than stubbed into the catalog."
  - "Pay runs 50-300 gold per ward and more for high-level ones. Diabolists are hired by royalty, merchants and guild houses to protect places, vaults, secret chambers and valuables, and their command of written and spoken language, common and arcane, also gets them work as translators and scribes."
extraction_notes: "Wards are the whole of this class''s magic and there is no ward catalog, so the mechanics are recorded as special abilities rather than faked into the spell list; the class carries no magic block at all. Literacy: Elven is granted flat at 98%, which is what the page prints, not the catalog base plus a bonus. Literacy: Runes at 88% +1% per level matches no catalog literacy row and is a special ability instead. Recognize Magic is added to the catalog by this batch at the printed 20% +5%. The two medium sacks join the large ones, because the equipment chapter prices only small, large and knap."
---

# Diabolist

## Lore

The diabolist is the scribe mage: a student of symbols rather than of spells.
Wards are ancient mystic marks that hold, direct and release magic energy, and
the diabolist spends four to six years as an apprentice learning them - one new
ward symbol every month or two, one power word every three months, the simplest
first and the major symbols last - alongside cryptography, study habits, reading
and writing, and the manufacture of adhesives and components. In exchange the
apprentice cooks, cleans, prepares components, and does whatever else the
teacher imposes.

What comes out is a precise, patient, extremely literate practitioner who cannot
cast a single spell and can leave magic sitting in a doorway for a year waiting
for the wrong person to walk through it.

## Alignment

Any.

## GM Notes

Diabolists are hired to protect places, vaults, secret chambers and valuables,
and pay runs 50-300 gold per ward, more for the high-level ones. Royalty,
merchants and guild houses are the usual employers. Their command of written and
spoken language, common and arcane, also gets them steady work as translators
and scribes, which is a good way to put one in a party that has no interest in
warding anything.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'diabolist');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'diabolist';
-- Expect 0. The three percentile abilities that DO have rows.
SELECT 3 - count(*) AS missing_skills FROM skills
 WHERE name IN ('Recognize Wards, Runes & Circles', 'Recognize Enchantment', 'Recognize Magic');
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 7 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'vial-glass-2-ounce', 'wax-bees-per-lb',
                'wax-clear-per-lb', 'brushes-sable-hair', 'bowl-earthenware',
                'book-parchment-glued-100-sheets');

INSERT INTO data_script_runs (filename) VALUES ('add-diabolist-class.sql');
