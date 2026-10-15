-- BOOK-INGEST-AUDIT F140: settle the unsettled sentences on four Palladium Fantasy classes
-- 4 classes, each replaced whole: druid, noble, priest-of-darkness, priest-of-light.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~207-book-ingest-audit-f140-pf.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == druid ==
UPDATE imported_classes
   SET markdown = '---
id: druid
men_of_arms: false
occ_group: clergy
xp_table: [0, 1861, 3721, 7441, 14881, 23881, 34881, 48881, 68881, 92881, 124881, 166881, 212881, 272881, 324881]
name: Druid
system: palladium-fantasy
source_book: palladium-fantasy-core p.73-78
category: occ
tags: [wilderness, divine]
attribute_requirements: { IQ: 9, PE: 12 }
ppe_base: "1D4x10 plus the P.E. attribute number, +1D6 per level of experience starting at level one"
starting_money: "100"
bonuses:
  saves: { horror_factor: 4, disease: 2 }
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
  hand_to_hand: { costs: {} }
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
      - { name: "Domestic", bonus: 10, note: "+10%" }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", bonus: 15, note: "+15%" }
      - { name: "Military", only: ["Camouflage", "Falconry"], bonus: 10, note: "Both +10%" }
      - { name: "Physical", except: ["Acrobatics", "Boxing", "Wrestling"] }
      - { name: "Science", bonus: 15, note: "+15%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Targeting", "W.P. Lance", "W.P. Pole Arm"], note: "The book also excludes Siege and Large Axes. Neither has a Palladium Fantasy row: the only Siege row, W.P. Siege Weapons, is a Rifts row this class is never offered, and no Large Axes row exists." }
      - { name: "Wilderness", bonus: 10, note: "+10%" }
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
    grants: ["Druidic Magic Powers: Negate Poison/Toxin, Healing Touch, and Control the Beasts, all as the wizard spells, plus Familiar Link - the druid may have one animal familiar"]
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
    grants: ["Master Druid", "Druidic Magic Power: Weather Control, once per day, plus the spells Spoil, Faeries'' Dance and Monster Insect as the wizard spells"]
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
  - "The starting dagger is a sharp STONE dagger doing 1D6 damage; the stone axe row stands in for it, being the only stone weapon among the catalog''s Palladium Fantasy rows."
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
',
       updated_at = datetime('now')
 WHERE class_id = 'druid'
   AND instr(markdown, 'Siege and Large Axes, which have no catalog rows.') > 0
   AND length(markdown) = 11264;

-- == noble ==
UPDATE imported_classes
   SET markdown = '---
id: noble
men_of_arms: false
occ_group: optional
xp_table: [0, 2201, 4401, 8801, 16501, 25001, 35001, 50001, 71001, 96501, 135501, 180501, 230501, 280501, 335501]
name: Noble
system: palladium-fantasy
source_book: palladium-fantasy-core p.96-97
category: occ
tags: [leader]
starting_money: "300"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Heraldry", base: 40, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 35, per_level: 5, note: "35%/20% riding/combat riding, the Palladium Fantasy numbers. The shared catalog row carries the Rifts ones (40%, +4)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 1, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "One language of choice (+20%)" }
    - { name: "Literacy", base: 45, per_level: 5, note: "One language of choice, usually native or elf (+15%)" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Play Musical Instrument", base: 50, per_level: 5, note: "+15%; pick one instrument" }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of one other skill, or to Martial Arts or Assassin (if evil) for the cost of two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5, note: "+5%" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", only: ["Falconry", "Recognize Weapon Quality"], bonus: 10, note: "+10%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - "Science"
      - { name: "Technical", bonus: 5, note: "+5%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Wilderness Survival", "Land Navigation"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { choose: 1, label: "cape or cloak", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "tent-one-man", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: 3 }
  - { item_id: "water-skin", qty: 1 }
  - { choose: 1, label: "fine wine or brandy", qty: 1, from: ["wine-good", "brandy"] }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "snuff-box", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
  - { item_id: "chain-mail", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-axe", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "knife-skinning", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is chain mail (A.R. 14, 44 S.D.C.). A noble can use every type, some preferring ornamented scale or plate and others less conspicuous leather or plate and chain, with the usual penalties."
  - "Every starting weapon is a basic S.D.C. weapon of good quality. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The riding horse is of good quality, with 30+2D6 S.D.C., 6D6 hit points, running speed 33, and a value of 1D6x1000 gold."
  - "Family background and the three family skills are rolled on the Knight tables, and those three skills are in addition to the five related skills above."
  - "1-60% chance of family and holdings in the homeland: 1D4 relatives who will house and feed the character indefinitely, and may provide a new set of clothing, studded leather armour, a sword and 2D6x10 gold."
  - "The two sets of clothing are one travelling and one fine; the catalog has a single generic clothing row."
extraction_notes: "Horsemanship: General is granted at the Palladium Fantasy printed base of 35%/20% +5% rather than the shared catalog row''s 40% +4%, which carries the Rifts numbers. The class entry is what the character reads, so the printed value wins. The book gives a bare hat where the catalog prices three, so the plainest is granted; a comb is listed and has no catalog row at all, so it is dropped rather than stubbed. The three family skills the book adds on top of the related skills are not stored on this class: the book sends the noble to the Knight''s family tables, which the Knight class here does not store either. A rolled table is a shape the format holds (band-named pick groups, BOOK-INGEST-AUDIT F116 and F120); transcribing those tables is the work left. Two weapons of choice enumerate every ordinary Palladium Fantasy weapon row, because equipment choices take item slugs rather than a category: the lance is left out by the book, and the four named artifact weapons (Black Sword of Styphon, Castlerake, the Dragon Slayer rune axe, Frostfoil) are left out because a starting weapon is a basic one. BOOK-INGEST-AUDIT F140 added the hand axe and skinning knife on 2026-10-15."
---

# Noble

## Lore

The noble is a lord or lady of noble birth, which usually means being born into
a family somewhere between relatively and incredibly wealthy. The character is
taught the rudiments of combat, weapons and horsemanship, and educated in
courtly matters and etiquette. Most nobles end up in politics, business
administration and similar occupations, but some are struck by wanderlust or a
desire for adventure, and others take to the road to make a name for themselves
or to shore up a sagging family fortune.

Some are foppish, pampered, selfish, arrogant snobs. Others are dignified,
proper and honourable, some are friendly and compassionate, and some are as
heroic and generous as the best knights in the land.

## Alignment

Any. Noble birth and education are not indicative of inner spirit, integrity or
compassion.

## GM Notes

One of the book''s Optional O.C.C.s, with no attribute minimums and no O.C.C.
bonuses at all, as the Vagabond/Peasant has none: what a noble brings to a party
is money, literacy, standing and a horse, not a trained edge in a fight.
',
       updated_at = datetime('now')
 WHERE class_id = 'noble'
   AND instr(markdown, 'nothing in the schema holds a table roll') > 0
   AND length(markdown) = 7064;

-- == priest-of-darkness ==
UPDATE imported_classes
   SET markdown = '---
id: priest-of-darkness
men_of_arms: false
occ_group: clergy
xp_table: [0, 1971, 3841, 7641, 15841, 25401, 35801, 51201, 72401, 96601, 132201, 184601, 234801, 284201, 346401]
name: Priest of Darkness
system: palladium-fantasy
source_book: palladium-fantasy-core p.70-71
category: occ
tags: [divine, evil]
ppe_base: "6D6 plus the P.E. attribute number, +2D4 per level of experience"
starting_money: "190"
skills:
  hand_to_hand: { costs: { expert: 2, assassin: 3 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { name: "Literacy", base: 50, per_level: 5, note: "One language of choice (+20%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Religion", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice, and may reflect the pantheon" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Expert for the cost of two other skills, or to Assassin for the cost of three. Martial Arts is not offered." }
  occ_related_skills:
    count: 8
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid"], bonus: 10, note: "+10%" }
      - { name: "Military", only: ["Heraldry", "Interrogation Techniques", "Surveillance"], bonus: 5, note: "+5%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"] }
      - { name: "Rogue", bonus: 5, note: "+5%" }
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Targeting", "W.P. Lance", "W.P. Pole Arm"], note: "The book also excludes Siege and Large Axes. Neither has a Palladium Fantasy row: the only Siege row, W.P. Siege Weapons, is a Rifts row this class is never offered, and no Large Axes row exists." }
      - "Wilderness"
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 5
    schedule: [{ level: 2, count: 1 }, { level: 5, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
natural_abilities:
  - name: "Curses"
    description: "The dark priest''s counterpart to the priest of light''s blessings, called down on a person, place or thing at the god''s discretion and the priest''s request."
  - name: "Special Prayers"
    description: "Pleas to the dark god for strength, insight and minor intervention. The Prayer of Strength of the Damned endows the priest with +6 to save vs horror factor, +2 on ALL other saving throws, +10% to turn dead, +1 to spell strength, +4 to damage, +1 to parry and dodge, and +8% to summon the Minions of Darkness. Twice per 24 hours; duration three minutes (12 melee rounds) per level; success 16% at first level, +8% per additional level."
  - name: "Animate & Command Dead"
    description: "As the wizard spell, with differences: success 9% per level of experience, maintained as long as the priest concentrates and does nothing else, and costing 10 P.P.E. The priest animates and commands 1D4 dead per level of experience."
  - name: "Spell Casting"
    description: "Granted by the deity rather than learned, the same way the priest of light receives it. Spell strength starts at 12 and is +1 at levels six and twelve. The dark priest''s list runs to Paralysis: Lesser, Sickness, Spoil, Tongues, or any spell from level one."
  - name: "Summon the Minions of Darkness"
    description: "Calls on the servants of the dark gods. Improved +8% while the Prayer of Strength of the Damned is running."
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { choose: 1, label: "travelling robe or hooded cloak", qty: 1, from: ["robe-hooded", "cape-long-hooded", "robe-heavy"] }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "holy-symbol", qty: 1 }
  - { item_id: "wooden-spike", qty: 4 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "silver-chalice", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "food-rations", qty: "2d4" }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 2 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Alignment is restricted to anarchist and evil. No good or unprincipled priest of darkness exists."
  - "No attribute minimums at all. The priest needs faith and dedication; a high M.E. and M.A. help and are not required."
  - "Race is open. Many of the monster races are drawn to demon lords and evil deities, and the dark gods welcome all who join the brotherhood of evil. A particular god may restrict its priests to one race or a few, but that is unusual."
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Weapons are open, though most favour staves, swords and blunt weapons; magic and holy weapons are coveted and must be acquired later."
  - "The typical dark priest gives roughly 25% of what he earns to the church."
  - "The kit calls for a GOLD chalice and one or two symbols of the priest''s own god or pantheon. The catalog prices a silver chalice and a generic holy symbol, which stand in for both."
extraction_notes: "This is the second half of the book''s priest material; Priest of Light is already published from the same source. Prayers, curses, animate dead and the deity-granted spell list are recorded as natural_abilities, matching how the Priest of Light records its healing touch, exorcism and miracles - display prose, because none of them is a catalog spell the sheet could cost. The weapon-proficiency exclusion names only the three rows that exist for this game: Siege and Large Axes have no Palladium Fantasy row (Siege''s one row is tagged Rifts and is never offered here), so naming them would exclude nothing. Spell strength and the prayer bonuses live in the ability text rather than in `bonuses`, because both are conditional - the prayer runs twice a day for a limited duration."
---

# Priest of Darkness

## Lore

The dark priest serves the demon lords and the evil deities, and gets from them
what the priest of light gets from the gods of light: prayers answered, spells
granted rather than learned, and power over the dead. Where the priest of light
heals and exorcises, the dark priest curses, animates corpses and calls up the
Minions of Darkness.

The church is a real institution with a real cut. The typical dark priest gives
roughly a quarter of everything he earns to it, and most enjoy life and all the
comforts that money, position and power can buy.

## Alignment

Only anarchist and evil. The nature of the service does not admit anything
else.

## GM Notes

Not every priest of darkness is a sadistic maniac or a murderous fiend bent on
conquest. An anarchist dark priest can travel with a party, keep his own
counsel, and be perfectly good company right up until the moment his god asks
for something.

Race is open, and the dark gods are notably less fussy about it than most of the
Palladium world: they welcome all who are members of the brotherhood of evil,
which makes a dark priest a plausible companion for the monster races.
',
       updated_at = datetime('now')
 WHERE class_id = 'priest-of-darkness'
   AND instr(markdown, 'Siege and Large Axes, which have no catalog rows.') > 0
   AND length(markdown) = 8879;

-- == priest-of-light ==
UPDATE imported_classes
   SET markdown = '---
id: priest-of-light
men_of_arms: false
occ_group: clergy
xp_table: [0, 1971, 3841, 7641, 15841, 25401, 35801, 51201, 72401, 96601, 132201, 184601, 234801, 284201, 346401]
name: Priest of Light
system: palladium-fantasy
source_book: palladium-fantasy-core p.63-67
category: occ
tags: [healer, divine]
ppe_base: "6D6 plus P.E. attribute number and 1D6 per level of experience"
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 4 } }
  occ_skills:
    - { name: "Dance", base: 50, per_level: 5, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Literacy", base: 50, per_level: 5, note: "One language of choice (+20%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Religion", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice, may reflect pantheon" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Expert for the cost of two other skills, or to Martial Arts for the cost of four other skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Heraldry", "Interrogation Techniques"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"] }
      - "Rogue"
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Siege", "W.P. Targeting", "W.P. Large Axes", "W.P. Pole Arm", "W.P. Lance"] }
      - "Wilderness"
    note: "Espionage offers none and is omitted. Category bonuses: Communications +5%, Domestic +10%, Medical +15%, Military +5%, Science +5%, Technical +15%. The except list names the book''s five barred W.P.s. W.P. Targeting, W.P. Pole Arm and W.P. Lance are Palladium Fantasy rows; W.P. Siege and W.P. Large Axes match no row (the only Siege row, W.P. Siege Weapons, is a Rifts row this class is never offered) and are named as the book prints them."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 7, count: 2 }
      - { level: 10, count: 2 }
      - { level: 13, count: 2 }
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "traveling robe or hooded cloak", qty: 1, from: ["hooded-robe", "hooded-cloak"] }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "small-sack", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "holy-symbol", qty: 2 }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "wooden-spike", qty: 4 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "vial-of-holy-water", qty: "1d6" }
  - { item_id: "silver-chalice", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { choose: 2, label: "starting weapon", qty: 1, from: ["quarterstaff", "long-staff", "mace", "morning-star", "mace-and-chain", "flail", "short-spear", "long-spear", "short-sword", "long-sword"] }
starting_money: 150
natural_abilities:
  - name: "Healing Touch"
    description: "Restores 2D4 hit points or S.D.C. (1D4 M.D.C. to supernatural beings on a mega-damage world). Can be performed once every other melee round, but cannot be used on the priest himself. May be sold for a fee (5 gold to 1D6x100 gold per touch; average 25-30 gold)."
  - name: "Exorcism"
    description: "A successful exorcism drives out/banishes any entity or demon from a possessed person, animal, dwelling or area. Exorcised creatures cannot return for at least 6 months (86% likelihood of never returning). Performed in a graveyard or tomb, it destroys animated skeletons, corpses and mummies present; ghouls and zombies are banished for 10 months; greater supernatural creatures including lesser devils and demons, vampires, ghosts, wraiths and specters are banished for 6 months. Requires 1D6 hours of prayer and meditation and the priest''s holy symbols. Success ratio: 7% per level of experience. Can be attempted as many times as desired."
  - name: "Remove Curse"
    description: "Removes magic or god-induced curses from a person or animal (new curses can still be placed later). Cannot remove curses placed on/in rune weapons, magic items, or sacred/supernatural places. Takes 1D4x10 minutes to perform. Success Ratio: 7% per level of experience. Can only be attempted ONCE per curse on the same person, though other priests may try after a failure."
  - name: "Resurrection"
    description: "Breathes life into the recently deceased. The body must have all its parts (small parts like fingers/toes may remain missing). The deceased should not have been dead more than 2-4 weeks (refrigeration adds up to 6 months to that limit); -3% penalty per month beyond four weeks. Bodies dead over one year have only a 5% total chance. Can only be attempted by priests of 5th level or higher. Ratio of Success: 10% at 5th level, +3% per additional level. Can only be attempted ONCE on the same character by the same priest; a failed roll means the character remains dead."
  - name: "Turn Dead"
    description: "Similar to exorcism but enacted in only two melee rounds (30 seconds). Affects only animated skeletons, corpses, mummies and ghouls, commanding them to leave. Vampires, ghosts, wraiths and specters may hesitate for one or two melee rounds but are not otherwise affected. Demons, deevils, gods and most other supernatural beings are unaffected. Success Ratio: 20% at first level, +5% per additional level."
  - name: "Penance and Sacrifice"
    description: "Techniques of self-denial including meditation, fasting, vows of abstinence, and vows of silence. Priests can resist thirst for two days per level of experience, and resist hunger for three days per level of experience. The priest can ignore the pain and discomfort and function at close to normal, though the physical body still suffers damage from dehydration, starvation, etc."
  - name: "Spell Casting"
    description: "Priests are endowed with spellcasting directly by their deity(s); it is not a learned or practiced skill, and most clergy know nothing of the ways of magic otherwise. Spells are invoked by chanting the god''s name and the type of spell needed. Begins at third level: automatically gains Tongues plus one additional spell selection from wizard magic levels 1-3. One additional spell (levels 1-3) is gained per subsequent level of experience. Priests cannot be taught nor purchase additional spell knowledge. Spell Strength: starts at 12, +1 at levels six and twelve."
  - name: "Special Prayers"
    description: "Pleas to the god(s) for strength, insight, and minor acts of intervention, including Blessings (of water, of a person, of a home, of food), Prayer of Strength, Prayer of Communion, and Prayer of Intervention (grants the ability to cast any one spell known by the priest''s god at +5 levels of effective power with no P.P.E. cost, temporary knowledge to create a magic scroll (6th level+), or Super Healing restoring 2D4x10 hit points/S.D.C. or 4D6 M.D.C. with two healing touches)."
  - name: "Miracles"
    description: "Direct appeals to the god(s) for incredible acts of intervention such as changing weather, parting bodies of water, or granting temporary superhuman abilities. Absolutely at the deity''s discretion and rarely granted for personal gain; success ratio equals the priest''s M.A. attribute number plus 2% per level of experience, though a deity may grant one regardless of the roll at the GM''s discretion. Does not require the priest to expend P.P.E.; if energy is unavailable the god provides it. Types include Miracle of Luck, Supernatural Strength, Purification, and the Great Miracles of Increased Power, Control Over Nature, Miraculous Healing, and Control over Magic."
level_progression:
  - level: 1
    grants: ["Healing Touch", "Exorcism", "Remove Curse", "Turn Dead", "Penance and Sacrifice", "Special Prayers"]
  - level: 3
    grants: ["Begins acquiring spells: automatic Tongues plus one additional spell selection (levels 1-3); one additional spell per subsequent level"]
  - level: 5
    grants: ["May attempt Resurrection"]
  - level: 6
    grants: ["+1 Spell Strength", "May attempt Temporary Knowledge to Create a Magic Scroll (Prayer of Intervention)"]
  - level: 8
    grants: ["Can bless two people or two items per level of experience without loss of potency"]
  - level: 12
    grants: ["+1 Spell Strength"]
restrictions:
  - "Priests are not trained as men of arms or in the use of weapons and armor with rare exception; hand to hand combat is not generally part of priestly teaching (though most travelling priests learn at least basic hand to hand)."
  - "Covering more than 50% of the body in metal armor requires the priest to spend 20% more P.P.E. to cast a spell and roll on a table for additional negative effects (reduced spell damage/effects, duration, or range by 1D4x10%, or lucked out with no problem)."
  - "Encumbrance penalties for armor: -15% to prowl and -20% to climb/scale walls or swim in full splint or plate armor; -10% to prowl, swim or climb in chain or scale mail; -5% in studded leather."
  - "The character must have an obvious and practiced allegiance to a particular god or pantheon; the deity selected should have a compatible alignment with the character."
  - "If a character disobeys, rebukes, or bad-mouths his deity(s), he will be punished, often severely (e.g., loss of experience levels, temporary or permanent restriction of abilities), at the GM''s discretion."
  - "Priests who forsake their god(s) completely are stripped of every clerical ability, skill ability and experience, and must start from scratch with a new O.C.C.; reinstatement as a priest of the same or another god is unlikely, and if granted is likely to start at level one or two."
  - "A blessing will not work if the person receiving it does not respect and acknowledge (not necessarily worship) the deity in whose name the prayer is invoked."
extraction_notes: |
  - REVIEW: the nine priestly abilities are automatic and live under
    natural_abilities - special_abilities is for powers a player chooses, and
    this class chooses none; level_progression records when each arrives.
    Fixed skills fold the O.C.C. bonus into the catalog base (Dance 30+20=50);
    Lore: Religion has a catalog row via backfill-import-skill-gaps.sql; its
    base here folds that catalog base plus the O.C.C. bonus.
  - REVIEW: the book gives 1D6 vials of holy water, and the entry says so -
    the wizard rolls a dice-valued quantity once at creation and stores the
    number, the same discipline as pools and attribute bonuses.
  - REVIEW: the priest''s spells come from the deity at level three onward
    (Tongues plus one selection from wizard levels 1-3, one more per level).
    No magic block is declared: the class starts with no spells at level one,
    and declaring one would have the wizard offer spell picks the book does
    not grant until third level. The schedule lives in Spell Casting and
    level_progression.
  - Attribute Requirements explicitly "None" per the book, so the field is omitted.
  - Hit point/S.D.C. base formulas are not given on these pages for the Priest of Light; only P.P.E. base and Spell Strength progression are stated, so hit_points_base/sdc_base are omitted rather than invented.
  - Armor and weapon starting choices: the book states armor starts as soft leather (A.R. 10, S.D.C. 20) and weapons start with "two of choice" from a favored list (staves, blunt weapons, chain weapons, spears, swords) - modeled as a choose:2 equipment entry. The soft leather is the catalog''s soft-leather armour row, granted in equipment_starting as the Druid and the Priest of Darkness grant it (BOOK-INGEST-AUDIT F140, 2026-10-15).
  - Alignment is "Any; typically reflective of the pantheon the priest worships. Priests of the Gods of Light typically start as good or selfish alignments." Not modeled as a schema field (no explicit slot for alignment), recorded here.
  - Race: "Any; although some gods/pantheons may restrict their priests to be members of a particular race or races, and some will be favorites of monsters and humans." Any race may take the class, so it states no race_restrictions; a god that narrows it is the GM''s call.
  - The percentage success ratios for many special abilities (exorcism, remove curse, resurrection, turn dead, special prayers, miracles) are level-scaling formulas embedded in prose; they are not flat numeric bonuses of the type the `bonuses` schema captures (they are percentile success chances, not combat/save bonuses), so they remain in the natural_abilities descriptions rather than under `bonuses`.
  - Secondary skills schedule: the book grants 4 secondary skills at level one, then two additional at levels 2, 5, 7, 10, and 13 - encoded as a schedule under secondary_skills, the same shape occ_related_skills uses.
  - Money: "The character starts with 150 in gold." The book adds that a typical priest gives the church at least 50% of money earned - roleplaying colour, not a mechanical bonus, recorded here only.
  - The lengthy Maryann Siembieda anecdote about disobeying a deity and being reduced from 7th to 4th level is illustrative fiction/example, not a fixed mechanical rule, and is placed under Lore/GM Notes rather than as a bonus or restriction with fixed numbers.
---

## Lore

In the Palladium world, a priest is a man or woman who has dedicated themselves to the service of a particular god or pantheon of gods. They may belong to the official Church of the Realm, a continent-spanning church like the Church of Light, or a small church, temple, monastery, cult, clan or organization with only a handful of members. The popularity of a religion is not what matters - it is the priest''s dedication to that deity, pantheon or belief.

Most player characters play a travelling priest determined to spread the word of their god(s) through word and deed: preaching, philosophical discussion, saying mass, giving sermons, settling disputes, blessing homes, baptizing children, performing weddings, tending the sick, performing healings, and generally bringing comfort and hope to the poor and downtrodden, to enslaved villages, and to those preyed upon by bandits, monsters, evil priests, witches, necromancers and other agents of darkness. In some societies priests gain great political and financial power and even become rulers; in others they are persecuted for their teachings.

Priests are not, as a rule, trained warriors or wizards - they are theologians, philosophers, healers, and liaisons between mortals and the gods, though most learn at least basic combat and a favored weapon (often staves and blunt weapons). Armor is typically light, since heavy metal armor both encumbers movement and interferes with the channelling of magic energy.

To play a priest, the character must select a god or pantheon of compatible alignment and maintain an obvious, practiced allegiance. A priest who disobeys, rebukes, or bad-mouths his deity risks severe punishment - in one storied campaign example, a priest of Light on a quest for Isis carelessly let a reclaimed relic slip away, then spoke to her goddess with arrogance ("What have you ever done for me?!"), and was instantly stripped from 7th level down to 4th, her experience frozen until the artifact was recovered. Priests who forsake their gods entirely lose all clerical ability, skill, and experience outright.

Each religion has its own laws and moral codes; the travelling priest, often removed from the rigidity of established churches, can be more flexible in interpreting them, especially in service of helping others. Only a handful of religions require celibacy; most allow priests to wed and raise families, and only about half restrict the priesthood by gender.

## GM Notes

The Priest of Light is built around a tiered escalation of divine favor: mundane Knowledge & Abilities (healing touch, exorcism, remove curse, turn dead, penance/sacrifice, spellcasting) available from level one or as noted, layered beneath Special Prayers (blessings, prayer of strength, communion, intervention) which are attempted routinely, and capped by rare, GM-adjudicated Miracles that should almost never be handed out reflexively - the book is explicit that miracles are not granted "at the drop of a hat," are refused even for worthy causes involving hundreds of lives if the deity doesn''t deem the cause important enough, and typically number one to a half-dozen across an entire campaign, or as rare as one every 2D6 years outside of deity-directed involvement.

When adjudicating a priest disobeying or offending their deity, treat it as a serious roleplaying consequence rather than a rules footnote - the example given (instant loss of three experience levels, frozen advancement, forced repentance and quest) is meant as a template for how visceral and narratively-driven such punishments should be, not a fixed penalty table.

Selling the Healing Touch is explicitly sanctioned by the book as a revenue mechanic for both PCs and church economies (5 gold to 1D6x100 gold per touch, 25-30 gold average) - useful for GMs wanting the priest to interact with local economies during downtime.

Armor encumbrance and the metal-interferes-with-magic mechanic apply identically to priests as to wizards, so GMs should apply the same 20% P.P.E. surcharge and negative-effect roll (01-20 reduce damage/effects, 21-40 reduce duration, 41-60 reduce range, 61-80 reduce both range and duration by 20%, 81-00 no additional problem) whenever a priest exceeding 50% metal armor coverage casts a spell.',
       updated_at = datetime('now')
 WHERE class_id = 'priest-of-light'
   AND instr(markdown, 'are book options the catalog does not carry yet') > 0
   AND length(markdown) = 18675;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 4 classes carry their new text' AS assertion, count(*) AS got, 4 AS want
  FROM imported_classes
 WHERE (class_id = 'druid' AND instr(markdown, 'is a Rifts row this class is never offered, and no Large Axes row exists') > 0)
    OR (class_id = 'noble' AND instr(markdown, 'BOOK-INGEST-AUDIT F140 added the hand axe and skinning knife') > 0)
    OR (class_id = 'priest-of-darkness' AND instr(markdown, 'names only the three rows that exist for this game') > 0)
    OR (class_id = 'priest-of-light' AND instr(markdown, 'are named as the book prints them') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'druid' AND instr(markdown, 'Siege and Large Axes, which have no catalog rows.') > 0)
    OR (class_id = 'noble' AND instr(markdown, 'nothing in the schema holds a table roll') > 0)
    OR (class_id = 'priest-of-darkness' AND instr(markdown, 'Siege and Large Axes, which have no catalog rows.') > 0)
    OR (class_id = 'priest-of-light' AND instr(markdown, 'are book options the catalog does not carry yet') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('druid', 'noble', 'priest-of-darkness', 'priest-of-light') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~207-book-ingest-audit-f140-pf.sql');
