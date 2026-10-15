-- Take BOOK-INGEST-AUDIT F136 and F138: the Diabolist's and Necromancer's note-only category bonuses become bonus keys
-- 2 classes, each replaced whole: diabolist, necromancer.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~195-book-ingest-audit-f136-note-bonuses.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- The fourteen related-skill category entries BOOK-INGEST-AUDIT F136's warning
-- named as real misses: each carried its printed bonus only in its note, which
-- nothing applies. Each figure read off a render of its cited page.
-- - diabolist (Palladium Fantasy printed 120): Communications +15, Science +10,
--   Technical +15, Military (Heraldry and Interrogation) +5; Espionage split into
--   Forgery +10 and Intelligence +5; Rogue +10 on Locate Secret Compartments and
--   Streetwise only, a second scoped entry; Wilderness +5 on Carpentry only, its
--   four-skill list split in two.
-- - necromancer (Africa printed 104): Communications +5, Domestic +5, Medical
--   (First Aid) +5, Pilot +2, Pilot Related +2, Rogue +5; Technical +10 on lore,
--   literacy, language or writing as a scoped entry for Creative Writing and every
--   Language:, Literacy: and Lore: row, with a Communications entry for the
--   Literacy: rows and Language: Dolphin/Whale, by the 2026-10-14 ruling ~192
--   recorded. No class's admitted skill set changes.

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
      - { name: "Communications", bonus: 15 }
      - "Domestic"
      - { name: "Espionage", only: ["Forgery"], bonus: 10 }
      - { name: "Espionage", only: ["Intelligence"], bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Heraldry", "Interrogation Techniques"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two. Martial Arts and Assassin are not available to this O.C.C. at any price." }
      - "Rogue"
      - { name: "Rogue", only: ["Locate Secret Compartments", "Streetwise"], bonus: 10 }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance", "W.P. Pole Arm"], note: "Any except Large Axes, Pole Arms and Lance; the catalog has no Large Axes row." }
      - { name: "Wilderness", only: ["Carpentry"], bonus: 5 }
      - { name: "Wilderness", only: ["Identify Plants & Fruit", "Land Navigation", "Preserve Food"] }
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
   AND instr(markdown, '{ name: "Communications", note: "+15%" }') > 0
   AND length(markdown) = 14799;

-- == necromancer ==
UPDATE imported_classes
   SET markdown = '---
id: necromancer
name: Necromancer
system: rifts
source_book: Rifts World Book 4: Africa p.99-104
category: occ
tags: []
occ_group: magic
men_of_arms: false
xp_table: [0, 2201, 4401, 8801, 17601, 27701, 37801, 53901, 75101, 100201, 140301, 200401, 250501, 300601, 350921]
attribute_requirements: { IQ: 10, ME: 10, PE: 12 }
ppe_base: "2d4x10 plus the P.E. attribute number, and 2d6 more per additional level of experience"
starting_money: "2d6x1000"
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Euro", bonus: 20, note: "Speaks and is literate in Euro (+20%)" }
    - { name: "Literacy: Euro", bonus: 20, note: "Speaks and is literate in Euro (+20%)" }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "One additional language spoken and read, plus one more language spoken only (+20% each)" }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literacy in the first of the two additional languages (+20%)" }
    - { name: "Lore: Demons & Monsters", bonus: 20, note: "The book prints ''Lore: Monsters & Demons (+20%)''; the catalog row is Lore: Demons & Monsters." }
    - { name: "Mathematics: Basic", bonus: 20, note: "The book prints ''Basic Math (+20%)''." }
    - { name: "Wilderness Survival", bonus: 5, note: "Wilderness Survival (+5%)" }
    - { name: "Skin & Prepare Animal Hides", bonus: 5, note: "The book prints ''Skin and Prepare Animal Hides & Bones (+5%)''; the catalog row is Skin & Prepare Animal Hides." }
    - { choose: 1, from: ["Hover Craft (ground)", "Horsemanship: General"], bonus: 10, note: "Pilot Hover Craft or Horsemanship (+10%)" }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. Knife or Sword" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Weapon of choice" }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], only_prefix: ["Literacy:"], bonus: 10 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], note: "Disguise, forgery and intelligence only." }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - { name: "Pilot", bonus: 2 }
      - { name: "Pilot Related", bonus: 2 }
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - "Technical"
      - { name: "Technical", only: ["Creative Writing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 6
    schedule: []
magic:
  type: "spell"
  spells_starting: 12
  spells_starting_groups:
    - { count: 6, from_list: "necromancy", note: "Six necromancy spells, regardless of level." }
    - { count: 6, from_list: "necro_common", note: "Six common spells associated with necromancy, from the book''s Available Common Spell Magic list (levels 1-15). The book states no level cap on these picks." }
  spell_lists:
    necromancy:
      - "Necromancy: Stench of the Dead"
      - "Necromancy: Object Read the Dead"
      - "Necromancy: Recognize the Undead"
      - "Necromancy: Command Ghouls"
      - "Necromancy: Kill Plants"
      - "Necromancy: Consuming Power & Knowledge"
      - "Necromancy: Death Mask"
      - "Necromancy: Divining: Tombs & Graves"
      - "Necromancy: Maggots"
      - "Necromancy: Death Strike"
      - "Necromancy: Shadows of Death"
      - "Necromancy: Shadows of Doom"
      - "Necromancy: Strength of the Dead"
      - "Necromancy: Summon Insect Swarm"
      - "Necromancy: Summon Vampires"
      - "Necromancy: Transfer Life Force"
      - "Necromancy: Summon Worms of Taut"
      - "Necromancy: Summon Magot"
    necro_common:
      - "Death Trance"
      - "Globe of Daylight"
      - "Sense Evil"
      - "Sense Magic"
      - "Concealment"
      - "Detect Concealment"
      - "Fear"
      - "Turn Dead"
      - "Breathe Without Air"
      - "Fuel Flame"
      - "Ignite Fire"
      - "Ley Line Transmission"
      - "Magic Net"
      - "Repel Animals"
      - "Shadow Meld"
      - "Trance"
      - "Circle of Flame"
      - "Horrific Illusion"
      - "Fire Ball"
      - "Mask of Deceit"
      - "Tongues"
      - "Animate and Control Dead"
      - "Constrain Being"
      - "Life Drain"
      - "Commune with Spirits"
      - "Exorcism"
      - "Luck Curse"
      - "Minor Curse"
      - "Sickness"
      - "Spoil"
      - "Protection Circle: Simple"
      - "Banishment"
      - "Control & Enslave Entity"
      - "Create Mummy"
      - "Create Zombie"
      - "Sanctum"
      - "Restoration"
      - "Transformation"
bonuses:
  attributes: { ME: 1, PE: 1, PS: 1, Spd: 4 }
  pools: { sdc: 10 }
  saves: { horror_factor: 6, spell_magic: 1, ritual_magic: 1 }
equipment_starting:
  - { item_id: "robe", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "disposable-surgical-gloves", qty: 100 }
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "large-sack", qty: "2d4" }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-ammo-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "shovel", qty: 2 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "wilk-s-laser-scalpel", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "short-sword", qty: 1 }
  - { item_id: "wooden-stake", qty: "2d4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "hand-held-flares", qty: 12 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
  - { item_id: "e-clip", qty: "1d6" }
special_abilities:
  - name: "Union with the Dead"
    description: "By tying an animal''s claw, hoof or tentacle (skeletal, or freshly slain and severed) to his own hand, forearm or foot and speaking an incantation known only to this O.C.C., the necromancer transforms that limb into the creature''s appendage, gaining its combat bonuses and abilities. P.P.E. cost varies by type (see the options below); self only by touch, and from 5th level he can do it to others at half duration. Duration 10 minutes per level; ends early if he is killed or knocked out, or at will. Takes one full melee round (15 seconds). Works only on the living. The limb is always proportional to the mage; any combination of limbs may be transformed. The options are the fifteen abilities that follow, each with its own P.P.E. cost (printed 100-101)."
  - name: "Union: Tentacle (10 P.P.E.)"
    description: "10 P.P.E.. Covers octopus, squid and a variety of monsters. +1 to strike, +20% to climb using suction cups, +3 to damage, and can pin or entangle an opponent. (Printed 100.)"
  - name: "Union: Rodent''s Claws/Feet (10 P.P.E.)"
    description: "10 P.P.E.. Covers rats, mice, squirrels, rabbits and similar small animals. +1 to strike and parry, +2 to damage (S.D.C.), +10% to climb. The claws have an opposable thumb and fingers, so tools and weapons can be used, roughly equal to human hands. (Printed 100.)"
  - name: "Union: Cat and Other Feline Claws (20 P.P.E.)"
    description: "20 P.P.E.. +2 to strike and parry, +8 to damage (S.D.C.), +20% to climb and +10% to prowl. The claws retract but have no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Canine Claws (10 P.P.E.)"
    description: "10 P.P.E.. +1 to parry and +4 to damage (S.D.C.). No opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bear, Badger, Wolverine and Similar Large Claws (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and +1 to parry, +10 to damage (S.D.C.), and +5% to climb. Excellent for digging, but no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bird Claws/Talons (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and parry, +8 to damage (S.D.C.). The claws can grasp tools and use weapons at -1 to strike or parry; using modern or complicated devices carries a skill penalty of -20%. (Printed 101.)"
  - name: "Union: Dragon Claws (50 P.P.E.)"
    description: "50 P.P.E.. Dragon claws of any kind: +1 to strike, +1 to parry, inflict 4D6 M.D., make the necromancer impervious to fire, and give a physical M.D.C. of 12 from hatchlings and 30 from adult dragons. (Printed 101.)"
  - name: "Union: Claws of Other Creatures of Magic and Supernatural Monsters (35 P.P.E.)"
    description: "35 P.P.E.. Claws of other creatures of magic and supernatural monsters, including manticore, sphinx, za, sowki, mindolar, ghouls, gargoyles and other so-called demons and others: inflict 2D6 M.D. and give the necromancer 8 M.D.C.; no strike or parry bonuses. (Printed 101.)"
  - name: "Union: Claws of a Non-Supernatural Mega-Damage Creature (20 P.P.E.)"
    description: "20 P.P.E.. Claws of a non-supernatural mega-damage creature such as the melech, peryton and loogaroo: inflict 1D6 mega-damage points; no M.D.C. or bonuses. (Printed 101.)"
  - name: "Union: Hooves (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option. Hooves of any kind (horse, ox, cow, deer, etc.) add +20 to the speed attribute and allow a leap of 10 feet (3 m) high or lengthwise. (Printed 101.)"
  - name: "Union: Rhinoceros or Elephant Feet (20 P.P.E.)"
    description: "20 P.P.E.. Feet/legs option. +10 to the normal speed attribute, but can also run for a short period of 30 seconds (two melee rounds) at +40. A kick or stomp inflicts 4D6 S.D.C. damage. (Printed 101.)"
  - name: "Union: Kilin Hooves (25 P.P.E.)"
    description: "25 P.P.E.. Feet/legs option. +30 to the speed attribute, can leap 10 feet (3 m) high or lengthwise, and kick attacks inflict 1D6 M.D. (Printed 101.)"
  - name: "Union: Unicorn Hooves (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +40 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 2D6 M.D. (Printed 101.)"
  - name: "Union: Dragon Feet/Claws (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +20 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 4D6 M.D. (Printed 101.)"
  - name: "Union: Monkey, Ape or Humanoid Hands (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option: hands in place of feet. +20% to climb, +5% to acrobatics, and the feet are equivalent to hands and can grasp and use weapons, tools and devices. The character''s normal speed is reduced by half. (Printed 101.)"
  - name: "Augmentation and Additional Appendages"
    description: "The necromancer can temporarily strap limbs of dead creatures, people and animals to his body and animate them as his own: up to three additional pairs of arms and two additional pairs of legs, or wings, a tail and horns in any combination, to a total of six additional appendages (a tail or a single horn counts as one, a pair of wings as two, one giant limb as two normal ones). The sight adds +2 to his Horror Factor. P.P.E. cost varies (options below); self only by touch, and from 8th level he can do it to others at half duration. Duration five minutes per level; ends early if he is killed or knocked out, or at will. Takes one full melee round. The added dead limbs keep their dead appearance and cannot themselves be transformed by Union with the Dead, though his own limbs can. The options are the eleven abilities that follow, each with its own P.P.E. cost (printed 101-102)."
  - name: "Augmentation: Additional Arms or Tentacles (10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs)"
    description: "10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs. Each additional pair of arms or tentacles adds one physical attack or action per melee round and a bonus of +1 to strike and parry. Three additional pairs can be added, for a possible total of eight arms (two natural and six skeleton limbs); limbs can be human, D-bee, ape or animal, and one giant limb counts as two normal sized limbs. Limbs of a mega-damage creature carry that creature''s strength and inflict its usual mega-damage. (Printed 101.)"
  - name: "Augmentation: Horn(s) (4 P.P.E. each)"
    description: "4 P.P.E. each. Horns are a weapon for head-butting and ramming. A single horn inflicts 1D4 S.D.C. and a pair does 2D4 damage; both add six points to the character''s physical S.D.C. (Printed 102.)"
  - name: "Augmentation: Rhinoceros Horn (8 P.P.E.)"
    description: "8 P.P.E.. The horn inflicts 3D6 S.D.C. and gives keen hearing (+1 on initiative) and a keen sense of smell (55% to track by smell), plus an extra 20 S.D.C. to the wearer. (Printed 102.)"
  - name: "Augmentation: Unicorn Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D6 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), keen color vision, prowl 50%, +1 on initiative, and never tiring. (Printed 102.)"
  - name: "Augmentation: Kilin Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D4 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), healing touch (four times, restoring 1D8 HP and 2D8 S.D.C.), and sense evil as an automatic sensation. (Printed 102.)"
  - name: "Augmentation: Dragon Horn (30 P.P.E.)"
    description: "30 P.P.E.. One horn inflicts 2D4 M.D. and gives 25 M.D.C. to the character wearing it. Two or more horns do 2D6 M.D. and each additional horn adds another 10 M.D.C. points. (Printed 102.)"
  - name: "Augmentation: Dragon Tail (20 P.P.E.)"
    description: "20 P.P.E.. Provides one additional attack per melee and inflicts 2D6 M.D. per strike. (Printed 102.)"
  - name: "Augmentation: Dragon Skull (50 P.P.E.)"
    description: "50 P.P.E.. Often worn as a helmet or ceremonial headdress called the dragon helm. Gives 20 M.D.C., understanding and speech of all languages, reading and writing dragonese/elf, imperviousness to fire, resistance to cold, and whatever breath weapon (if any) the dragon had (fire, cold, acid, etc.). The mage can also cast any spell the dragon once knew, as a 5th level spell caster. (Printed 102.)"
  - name: "Augmentation: Skull of a Powerful Supernatural Monster (120 P.P.E.)"
    description: "120 P.P.E.. Skull of a god, godling, greater demon/being or demon lord (elementals, vampires, alien intelligences and energy beings do not qualify). Gives 40 M.D.C., the ability to speak that creature''s language, and all its magic powers and spell knowledge, only while the skull is activated, at half the level of ability it had alive: 10th level in life gives fifth level power, sixth gives third. (Printed 102.)"
  - name: "Augmentation: Wings of a Bird or Bat (30 P.P.E.)"
    description: "30 P.P.E.. Wings are strapped to the mage''s back and may be undersized or over-sized; when the magic engages they grow or shrink to fit the user. Flying speed is limited to 20 mph (32 km) for most songbirds and bats, game and large birds, and 35 mph (56 km) from the wings of birds of prey. Large monstrous wings (pegasus, peryton, harpy, gargoyle, gryphon, gromek, loogaroo, waternix and similar) give 45 mph (72 km). (Printed 102.)"
  - name: "Augmentation: Wings of a Dragon or Powerful Supernatural Creature (90 P.P.E.)"
    description: "90 P.P.E.. Flight at a speed of 60 mph (96 km) and a bonus of 10 M.D.C. to the flyer; the wings themselves have 2D4x10 M.D.C. (Printed 102.)"
  - name: "Animate and Control the Dead"
    description: "Like the common spell but considerably more powerful. 10 P.P.E. Range 300 ft (91.5 m) plus 20 ft (6 m) per level; duration 10 minutes per level. Controls four corpses or skeletons (humanoid, animal or monster) per level of experience; each must be in line of sight to animate, and more can be added as they are found. They can be sent out of sight on simple missions such as ''destroy'' or ''kill'' and follow the command until destroyed or the duration ends. Each has Spd 7, two attacks per melee, 1D6 S.D.C. damage from punches, kicks, claws and bites, and can use only the simplest mega-damage weapons (flaming sword, vibro-blade), never guns; giant ones have double speed and damage and one more attack. They feel no pain, fear or emotion. Only total destruction stops them, or slaying or knocking out their creator. S.D.C.: small 50, human-sized 80, giant 140. Bullets and stabbing weapons do 1/3 damage, blunt and smashing attacks full damage, fire double damage. (Printed 102.)"
  - name: "Impervious to Vampires"
    description: "Impervious to a vampire''s mind-controlling bite and cannot be turned into a vampire, though vampires can still slay him. Knows all the legends about vampires and other undead and how to combat them. (Printed 102.)"
  - name: "Horror Factor"
    description: "The necromancer is frightening. Horror Factor 6 at first level, +1 at levels 3, 5, 7, 9, 11, 13 and 15 (and +2 more while Augmentation appendages are attached). A Horror Factor the character PROJECTS is not a save the character makes, so it is recorded here; the +6 to save vs Horror Factor in bonuses is a separate thing."
  - name: "Learning New Spells"
    description: "Additional spells and rituals related to necromancy (see the necromancy and common lists) can be learned or purchased at any time, regardless of the character''s experience level. See The Pursuit of Magic, Rifts Ultimate Edition page 190."
  - name: "Common Spells Cost Double"
    description: "The necromancer can learn any spell, but any common spell NOT on the book''s Available Common Spell Magic list (printed 108) costs him twice its normal P.P.E. to cast - Armor of Ithan costs 20 rather than 10, Befuddle 6 rather than 3. The spells on that list, which are the necro_common list of this class, are cast at their normal cost. Other spell casters (a line walker, a shifter) can learn necromancy spells but pay double to cast them; techno-wizards and mystics never learn necro-magic."
  - name: "Insanity"
    description: "The necromancer often becomes deranged with the passage of time: one roll on the Necromancer Insanity Table at each of levels 4, 8, 10, 12 and 15. The table is the Insanity pick group that follows, one banked roll or pick per listed level. The book also lets a player who wants the character crazy simply pick one or two results. (Printed 104.)"
  - { choose: 1, at_levels: [4, 8, 10, 12, 15], from: ["Insanity (01-30): No Insanity", "Insanity (31-40): Obsession - Torture and Killing", "Insanity (41-45): Obsession - Hates the Light of Day", "Insanity (46-50): Obsession - Danger", "Insanity (51-55): Phobia - Gods of Light", "Insanity (56-60): Obsession - Hates Good Druids", "Insanity (61-65): Obsession - Dead Things", "Insanity (66-70): Phobia - Ancient Dragons", "Insanity (71-75): Phobia - High Level Shamans and Priests of Light", "Insanity (76-80): Phobia - Spirits of Light", "Insanity (81-85): Random Affective Disorder", "Insanity (86-90): Random Phobia", "Insanity (91-95): Random Obsession", "Insanity (96-00): Random Insanity"], note: "Necromancer Insanity Table (printed 104): roll once, or pick, at each of levels 4, 8, 10, 12 and 15. Rows 81-00 send the player to another table." }
  - name: "Insanity (01-30): No Insanity"
    description: "Roll 01-30 or choose. No insanity this time; the necromancer''s mind holds. (Printed 104.)"
  - name: "Insanity (31-40): Obsession - Torture and Killing"
    description: "Roll 31-40 or choose. Obsession: he likes to torture, hurt and kill others. (Printed 104.)"
  - name: "Insanity (41-45): Obsession - Hates the Light of Day"
    description: "Roll 41-45 or choose. Obsession: he hates the light of day and tries to avoid it. (Printed 104.)"
  - name: "Insanity (46-50): Obsession - Danger"
    description: "Roll 46-50 or choose. Obsession: he loves danger and takes needless risks. (Printed 104.)"
  - name: "Insanity (51-55): Phobia - Gods of Light"
    description: "Roll 51-55 or choose. Phobia: Gods of Light. (Printed 104.)"
  - name: "Insanity (56-60): Obsession - Hates Good Druids"
    description: "Roll 56-60 or choose. Obsession: he hates good druids, especially Millennium druids. (Printed 104.)"
  - name: "Insanity (61-65): Obsession - Dead Things"
    description: "Roll 61-65 or choose. Obsession: he loves dead things and surrounds himself with skeletons, mummies, zombies and the like. (Printed 104.)"
  - name: "Insanity (66-70): Phobia - Ancient Dragons"
    description: "Roll 66-70 or choose. Phobia: ancient dragons. (Printed 104.)"
  - name: "Insanity (71-75): Phobia - High Level Shamans and Priests of Light"
    description: "Roll 71-75 or choose. Phobia: high level shamans and priests of light. (Printed 104.)"
  - name: "Insanity (76-80): Phobia - Spirits of Light"
    description: "Roll 76-80 or choose. Phobia: spirits of light/angels. (Printed 104.)"
  - name: "Insanity (81-85): Random Affective Disorder"
    description: "Roll 81-85 or choose. The row sends the player to roll for a random affective disorder; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (86-90): Random Phobia"
    description: "Roll 86-90 or choose. The row sends the player to roll for a random phobia; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (91-95): Random Obsession"
    description: "Roll 91-95 or choose. The row sends the player to roll for a random obsession; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (96-00): Random Insanity"
    description: "Roll 96-00 or choose. The row sends the player to roll for a random insanity; that second roll is made by hand and its result is not stored here. (Printed 104.)"
restrictions:
  - "Optional O.C.C.: the book calls the necromancer a better NPC villain than player character and leaves its use as a player character to the Game Master''s discretion."
  - "Selfish or evil alignment only (unprincipled, anarchist, or any evil); a good necromancer is not possible. Most are anarchist or evil. Attribute requirements are I.Q. 10, M.E. 10 and P.E. 12 or higher."
  - "Race: any that may master death magic - humans, D-Bees, ogres and many monster races. Faerie folk, spirits of light, elementals and kilin are never necromancers, and dragons generally avoid it."
  - "Cybernetics: starts with none and avoids them because they interfere with magic. Only cybernetic bio-systems for health reasons will be considered."
  - "Vehicle is limited to NON-MILITARY transportation - a hover vehicle, a motorcycle or a riding animal."
  - "Hand to Hand is NOT free: Basic costs one O.C.C. Related Skill, Expert two, and Martial Arts or Assassin (if evil) three."
  - "The character also starts with 3D6x1000 credits'' worth of sellable black-market items, over and above the coin in starting_money. That field is coin only, so the goods are recorded here."
  - "Secondary skills are chosen from the O.C.C. Related list EXCLUDING the categories marked None - Electrical, Mechanical and Military - and take no category bonus."
  - "Starting gear the catalog has no row for: a box of 50 large zip-lock plastic bags, a large satchel or suitcase, a wooden knife, and one or two other weapons of choice. The sacrificial short sword is usually ornate and plated in a precious metal; the necromancer prefers magic weapons and devices over technological ones."
extraction_notes: "Rifts World Book 4: Africa pp.99-104, with the necromancy spell list and the Available Common Spell Magic rule on printed 108 and the ladder on printed 160. This is the original Necromancer; necromancer-russian (Mystic Russia) is a separate later class and its Bone Magic is not part of this one. XP: the Necromancer & Phoenixi column, stored as lower bounds; level 15 is printed as 350,921-425,800 although level 14 ends at 350,700, so 350,921 is stored as printed rather than 350,701 - a book anomaly. men_of_arms is false: the class sits in the book''s magic section beside the African Witch and Priest and prints no S.D.C. formula of its own, only the +10 S.D.C. bonus. STARTING SPELLS: the six necromancy picks come from a named list of the 18 Necromancy rows (the book says regardless of level, and a named list replaces the level gate). The six common picks come from a named list of the book''s Available Common Spell Magic list, the spells the book treats as associated with necromancy and casts at normal cost; no level cap is applied to that group because the book states none (necromancer-russian capped its common six at 1-5; a spell_levels key beside a named list in a starting group is not applied by startingGroups in js/leveling.js, so a cap would need a second list). The book''s list names Animate & Control Dead, Control/Enslave Entity and Protection: Simple; the catalog rows are Animate and Control Dead, Control & Enslave Entity and Protection Circle: Simple. The double P.P.E. cost of every other common spell has no key and is prose in special_abilities. Union with the Dead and Augmentation each keep one special ability for the general rule, and since ~118 every option of their tables is its own special ability named with its P.P.E. cost (fifteen unions, eleven augmentations), by the ruling of 2026-10-04 that they are class abilities and not spell rows. The 35 and 20 P.P.E. claws are paragraphs of the dragon claws entry on the page and are separate abilities here because each prints its own cost; Additional Arms or Tentacles is one ability with its three printed costs. None of their bonuses go in bonuses because each applies only while a limb is attached. The projected Horror Factor is prose; the +1 save vs magic of all kinds is carried as spell_magic and ritual_magic. Two additional languages: the book''s first additional language is spoken and literate, so the class takes two Language: Other picks and one Literacy: Other pick. Skill names needing the catalog''s spelling: Lore: Monsters & Demons is Lore: Demons & Monsters; Basic Math is Mathematics: Basic; Skin and Prepare Animal Hides & Bones is Skin & Prepare Animal Hides; Pilot Hover Craft is Hover Craft (ground). Gear judgement calls: leather gloves are gloves, the robe-or-cloak is robe, the two hand shovels are shovel, the palm size mirror is pocket-mirror, the sacrificial short sword is short-sword, the dozen flares are hand-held-flares, and a week''s food rations are one food-rations entry. The text layer prints the human-sized animated corpse S.D.C. as SO; the rendered page reads 80. 2026-10-05: the Necromancer Insanity Table (printed 104, read off the rendered page) is a pick-one group at levels 4, 8, 10, 12 and 15, the levels the page prints (four, eight, ten, twelve and fifteen), by BOOK-INGEST-AUDIT.md F116. Its fourteen rows are band-named options, 01-30 through 96-00, covering 01-00 with no gap or overlap as printed, each its own special ability. No row prints a number, so none carries bonuses. The four rows that send the player to another table (81-85 random affective disorder, 86-90 random phobia, 91-95 random obsession, 96-00 random insanity) stay as that row''s prose. The Insanity ability is kept as a pointer and holds the book''s allowance to pick one or two results outright."
---

# Necromancer

## Lore

The necromancer practises the magic of death, the dead and the monstrous. It is
an obscure art in most of the world, but by far most common in Africa and
southern Europe, spread by the influence of Egypt and its insane Pharaoh
Rama-Set, the Gods of Darkness, many death cults and the monster races and evil
supernatural beings that dominate those lands.

The heart of the necromancer''s power is the ability to animate, control and draw
power from the remains of the dead. So these mages carry bones, claws, hooves,
wings and preserved limbs in satchels, trunks and sacks, and keep the rarest -
a dragon''s claw - on their person at all times. Some travel with an entourage of
skeletons and zombies, a common sight in the Phoenix Empire, and a necromancer''s
lair is guarded by the animated dead.

Much of the magic calls for enslavement, torture, blood sacrifice and murder as
a source of P.P.E.; to the evil necromancer, death is simply a resource.

## Alignment

Selfish or evil only. An unprincipled or anarchist necromancer shows restraint:
avoids torture and wanton killing, prefers scavenging and grave-robbing to blood
sacrifice, and shuns pacts with supernatural beings and dealings with other
necromancers - which limits both P.P.E. and the spells he will use. An aberrant
one keeps his own code and kills quickly and with discretion. The rest suffer no
such scruples.

## GM Notes

The book presents the necromancer as a better NPC villain than player character
and leaves it to the Game Master whether one may be played. Roughly a quarter of
known necromancers are human; ogres and other monster races make up over half.
The five special powers - Union with the Dead, Augmentation, Animate and Control
the Dead, immunity to vampires and a Horror Factor - come in addition to the
starting spells.
',
       updated_at = datetime('now')
 WHERE class_id = 'necromancer'
   AND instr(markdown, '{ name: "Technical", note: "+10% on lore, literacy, language or writing" }') > 0
   AND length(markdown) = 29546;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'diabolist' AND instr(markdown, '{ name: "Rogue", only: ["Locate Secret Compartments", "Streetwise"], bonus: 10 }') > 0)
    OR (class_id = 'necromancer' AND instr(markdown, '{ name: "Technical", only: ["Creative Writing"], only_prefix: ["Language:", "Literacy:", "Lore:"], bonus: 10 }') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'diabolist' AND instr(markdown, '{ name: "Communications", note: "+15%" }') > 0)
    OR (class_id = 'necromancer' AND instr(markdown, '{ name: "Technical", note: "+10% on lore, literacy, language or writing" }') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('diabolist', 'necromancer') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~195-book-ingest-audit-f136-note-bonuses.sql');
