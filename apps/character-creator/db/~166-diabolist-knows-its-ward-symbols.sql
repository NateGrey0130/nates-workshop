-- Give the Diabolist its ward symbols, and correct three figures against its page
-- 1 class, each replaced whole: diabolist.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~166-diabolist-knows-its-ward-symbols.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C3, the class half. The Diabolist gains a magic block
-- naming the 34 ward symbol rows ~165 added, in the shape the Summoner uses
-- for circles: type ward, spell_traditions_allowed [ward], nothing picked at
-- first level or per level.
--
-- All 34 are granted because no page gives a first-level count or a gain by
-- level: printed 117 says only Diabolists know the secrets of ward magic and
-- all magic symbols, 119 that the class knows all power words, and 120 that
-- the symbols are learned over the four to six year apprenticeship, before
-- play. That is a defensible reading, not a printed number, and the class's
-- notes say so.
--
-- Corrected against the page while the class was open, each read off a render
-- and checked by book-reconcile:
--   Use Magic Circles said the Diabolist can operate or activate a circle;
--     printed 119 says it can attempt to USE one already active (30% +5% per
--     level, two tries, after the recognize roll) and cannot create or
--     activate one.
--   Recognize Wards, Runes & Circles carried the Rifts catalog base of 15%
--     +5%; printed 119 item 4 prints 22% +4% per level for this class.
--   The Lore's ward lasting "a year" becomes centuries (printed 122).
-- The four ward-rule abilities gain what printed 120-125 print: phrase size,
-- deliberate activation, deactivation costs, and that a ward keeps its
-- maker's level.

-- == diabolist ==
UPDATE imported_classes
   SET markdown = '---
id: diabolist
men_of_arms: false
occ_group: magic
xp_table: [0, 2181, 4361, 8721, 17101, 26201, 36301, 51401, 74501, 98601, 137701, 184801, 233001, 284201, 336301]
name: Diabolist
system: palladium-fantasy
source_book: palladium-fantasy-core p.117-120
category: occ
tags: [scholar]
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
  hand_to_hand: { costs: { basic: 1, expert: 2 } }
  occ_skills:
    - { name: "Art", base: 45, per_level: 5, note: "+10%" }
    - { name: "Cryptography", base: 45, per_level: 5, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 3, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Three languages of choice (+20% each). Taken once per language - the picker asks which." }
    - { name: "Literacy: Dragonese/Elven", base: 98, per_level: 0, note: "Literacy: Elven at 98%, flat, not the catalog base." }
    - { choose: 2, from: ["Literacy: Other"], bonus: 20, note: "Literate in two further languages of choice (+20%). Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Lore: Astral", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15, note: "One lore of choice (+15%)" }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%" }
    - { name: "Whittling & Sculpting", base: 50, per_level: 5, note: "Sculpt & Whittling (+20%)" }
    - { name: "Recognize Wards, Runes & Circles", base: 22, per_level: 4, note: "Recognize & Understand Magic Circles at the printed 22% +4% per level, not the catalog base; +10% for protection circles. Also stands for Mystic Symbology, the study of ancient and modern magic symbols, which prints no percentage." }
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
magic:
  type: "ward"
  spell_traditions_allowed: ["ward"]
  spells_starting: 0
  spells_per_level: 0
  spells:
    - "Alarm: Magic"
    - "Alarm: Silent"
    - "Alarm: Sound"
    - "Alarm: Trigger"
    - "Major Ward: Area Affect"
    - "Major Ward: Inflict"
    - "Major Ward: Permanence"
    - "Major Ward: Power"
    - "Major Ward: Protection From"
    - "Major Ward: Protection by Infliction"
    - "Condition: Agony"
    - "Condition: Blind"
    - "Condition: Burning Pain"
    - "Condition: Charm"
    - "Condition: Cold"
    - "Condition: Confusion"
    - "Condition: Dark"
    - "Condition: Death"
    - "Condition: Despair"
    - "Condition: Energy"
    - "Condition: Evil"
    - "Condition: Fear"
    - "Condition: Fire"
    - "Condition: Good"
    - "Condition: Hate"
    - "Condition: Invisible"
    - "Condition: Knowledge"
    - "Condition: Light"
    - "Condition: Magic"
    - "Condition: Mystic Energy Drain"
    - "Condition: Sleep"
    - "Condition: Undead"
    - "Descriptive: Colors"
    - "Descriptive: Numbers"
special_abilities:
  - { name: "Ward Magic", description: "The diabolist casts no spells. Wards are mystic symbols that hold, direct and release magic energy - time-release magic, placed now and triggered later. Each symbol is made with its own physical components, then energised by speaking its power word and spending P.P.E.; the ward does nothing until the last symbol of the phrase is drawn and energised. A simple ward symbol takes one P.P.E. point, the power symbol five, and the permanence ward symbol twenty. The symbols the class knows are its magic list, and each one''s description carries its components and power words; the phrases are composed at the table. Only an alarm works as a single symbol: any other ward needs a phrase of at least two or three, a typical phrase runs 2-5 symbols, and the page prints no limit by level. A whole phrase counts as one ward. Setting off one''s own ward on purpose costs two P.P.E. and one melee action while touching it. Deactivating one''s own ward costs five P.P.E. per ward and ten for the power symbol; a permanence symbol and the wards joined to it can never be deactivated, nor can another Diabolist''s wards. A spent ward cannot be energized again." }
  - { name: "Power Words", description: "Knows every power word currently known. Legend says others exist and have been lost." }
  - { name: "Literacy: Runes", description: "Reads, understands and writes the ancient rune alphabet at 88% +1% per level of experience from first level, which also identifies authentic rune weapons and whether one is a lesser, greater or greatest weapon. Recorded here rather than as a skill because 88% +1% matches no catalog literacy row." }
  - { name: "Identify Energized Wards", description: "Senses whether a ward or ward phrase is live and waiting or spent. Base skill 25% +5% per level; half when picking out which wards in a sequence are still potent. One try only, and a failed roll means the character is not sure. The Diabolist can also read another maker''s symbols to know what kind of magic they will unleash." }
  - { name: "Use Magic Circles", description: "Can attempt to use a magic circle that is already active, once its basic function has been worked out with a successful Recognize Wards, Runes & Circles roll. Base skill 30% +5% per level of experience, +10% to use a protection circle; two tries only. The diabolist cannot create or activate a magic circle." }
  - { name: "Ward Strength", description: "The number others must save against when they trigger one of this character''s wards. Starts at 14, +1 at levels five, ten and fifteen. A successful save means no effect at all. The diabolist is impervious to their own wards, though not to another maker''s. A ward keeps the level of its maker at the time it was energized." }
  - { name: "Wards Energized Per Day", description: "One ward or ward phrase per P.E. attribute point per 24 hours at first level; two per point at third, three at ninth, four at fifteenth. The limit is on energizing: any number of symbols may be made ahead and left unenergized." }
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
extraction_notes: "Wards are the whole of this class''s magic. 2026-10-05 (BOOK-INGEST-AUDIT.md F123): the ward symbols of printed 126-133 are 34 spell rows in tradition ward at level 0, covering the 52 symbols of the plate on printed 127 (4 alarms, 22 conditions, 6 major wards, 7 colors, 13 numerals) - Colors and Numbers are one row each, as the book gives each group one entry - and the magic block grants every row by name. The four kinds in the row names are a naming convention: Alarm, Condition and Major Ward are the plate''s own groups, and Descriptive is the catalog''s label for Colors and Numbers, a word the book also uses for Evil, Good and Magic. Printed 117 says only Diabolists know the secrets of ward magic and all magic symbols, printed 119 that the class knows every power word, and printed 120 that the symbols are learned across the four to six year apprenticeship; no page prints a number known at first level or gained by level, so nothing is picked and spells_per_level is 0. Ward phrases are not rows and nothing builds them. The rules every ward shares - energizing costs, ward strength, wards per day, deliberate activation and deactivation (printed 120 and 122) - stay as special abilities, and four of those were filled out from the same pages. Use Magic Circles is restated from printed 119 item 5, and Recognize Wards, Runes & Circles now carries item 4''s printed 22% +4% per level in place of the catalog skill''s own 15% +5%. Literacy: Elven is granted flat at 98%, which is what the page prints, not the catalog base plus a bonus. Literacy: Runes at 88% +1% per level matches no catalog literacy row and is a special ability instead. Recognize Magic is added to the catalog by this batch at the printed 20% +5%. The two medium sacks join the large ones, because the equipment chapter prices only small, large and knap."
---

# Diabolist

## Lore

The diabolist is the scribe mage: a student of symbols rather than of spells.
Wards are ancient mystic marks that hold, direct and release magic energy, and
the diabolist spends four to six years as an apprentice learning them, all before
play begins - in those years one new ward symbol every month or two and one power
word every three months, the simplest first and the major symbols last - alongside cryptography, study habits, reading
and writing, and the manufacture of adhesives and components. In exchange the
apprentice cooks, cleans, prepares components, and does whatever else the
teacher imposes.

What comes out is a precise, patient, extremely literate practitioner who cannot
cast a single spell and can leave magic sitting in a doorway for centuries,
waiting for the wrong person to walk through it.

## Alignment

Any.

## GM Notes

Diabolists are hired to protect places, vaults, secret chambers and valuables,
and pay runs 50-300 gold per ward, more for the high-level ones. Royalty,
merchants and guild houses are the usual employers. Their command of written and
spoken language, common and arcane, also gets them steady work as translators
and scribes, which is a good way to put one in a party that has no interest in
warding anything.
',
       updated_at = datetime('now')
 WHERE class_id = 'diabolist'
   AND instr(markdown, 'the class carries no magic block at all') > 0
   AND length(markdown) = 11280;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'diabolist' AND instr(markdown, 'spell_traditions_allowed: ["ward"]') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'diabolist' AND instr(markdown, 'the class carries no magic block at all') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('diabolist') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~166-diabolist-knows-its-ward-symbols.sql');
