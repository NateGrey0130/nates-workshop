-- BOOK-INGEST-AUDIT F138 residue: the Summoner grants Deciphering Circles and stores its circle strength rule (Palladium Fantasy printed 135-136)
-- 1 class, each replaced whole: summoner.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~272-book-ingest-audit-f138-summoner-circles.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.

-- == summoner ==
UPDATE imported_classes
   SET markdown = '---
id: summoner
men_of_arms: false
occ_group: magic
xp_table: [0, 2301, 4601, 9201, 17001, 28001, 36001, 51001, 73001, 98001, 139001, 189001, 239001, 289001, 349001]
name: Summoner
system: palladium-fantasy
source_book: palladium-fantasy-core p.135-137
category: occ
tags: [scholar]
attribute_requirements: { IQ: 10, ME: 14 }
ppe_base: "3d6x10 plus the P.E. attribute number, +2d6 per level of experience starting at level one"
starting_money: "140"
bonuses:
  saves: { possession: 3, mind_control: 3 }
  at_level:
    - { level: 2, saves: { horror_factor: 2 } }
    - { level: 4, saves: { horror_factor: 2, spell_magic: 1, ritual_magic: 1 } }
    - { level: 7, saves: { horror_factor: 2 } }
    - { level: 8, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 10, saves: { horror_factor: 2 } }
    - { level: 12, saves: { spell_magic: 1, ritual_magic: 1 } }
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2 } }
  occ_skills:
    - { name: "Gemology", base: 40, per_level: 5, note: "+15%" }
    - { name: "History", base: 45, per_level: 5, note: "+15%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 20, note: "Two languages of choice (+20% each)" }
    - { choose: 2, from: ["Literacy: Other"], bonus: 20, note: "Literate in two languages of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Lore: Astral", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires"], bonus: 15, note: "One further lore of choice (+15%)" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Preserve Food", base: 40, per_level: 5, note: "+15%" }
    - { name: "Deciphering Circles", base: 20, per_level: 4, note: "Rolled only after the found circle is drawn and its power words invoked; a failure rolls on the Incorrect Circle Invocation table (printed 136)." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice" }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", bonus: 10, note: "+10%" }
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Military", only: ["Interrogation Techniques", "Surveillance"], note: "Interrogation Techniques +5%" }
      - { name: "Military", only: ["Interrogation Techniques"], bonus: 5, note: "Interrogation Techniques +5%." }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"], note: "Hand to Hand: Basic costs one of these, Expert two. Martial Arts and Assassin are not available to this O.C.C. at any price." }
      - "Rogue"
      - { name: "Science", bonus: 10, note: "+10%" }
      - { name: "Technical", bonus: 15, note: "+15%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance"], note: "Any except Large Axes and the Lance; the catalog has no Large Axes row." }
      - { name: "Wilderness", only: ["Land Navigation", "Wilderness Survival"] }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
magic:
  type: "circle"
  spell_traditions_allowed: ["circle"]
  spells_starting: 0
  spells_per_level: 0
  spells:
    - "Circle: Protection Circle: Simple"
    - "Circle: Protection Circle: Superior"
    - "Circle: Protection from Angels"
    - "Circle: Protection from Deevils"
    - "Circle: Protection from Demons"
    - "Circle: Protection from Elemental Forces"
    - "Circle: Protection from Evil"
    - "Circle: Protection from Faerie Folk"
    - "Circle: Protection from Ghosts, Spirits & Entities"
    - "Circle: Protection from Good"
    - "Circle: Protection from Magic (simple)"
    - "Circle: Protection from Magic (superior)"
    - "Circle: Protection from True Elementals"
    - "Circle: Protection from Were-beasts"
    - "Circle: Protection from Witches"
    - "Circle: Protection from the Jinn"
    - "Circle: Protection from the Old Ones"
    - "Circle: Protection from the Undead"
    - "Circle: Summon Angels"
    - "Circle: Summon Animal"
    - "Circle: Summon Elemental Forces"
    - "Circle: Summon Faerie Folk"
    - "Circle: Summon Gargoyles & Sub-Demons"
    - "Circle: Summon Ghosts & Entities"
    - "Circle: Summon Greater Demon or Deevil"
    - "Circle: Summon Insects"
    - "Circle: Summon Lesser Demon or Deevil"
    - "Circle: Summon Pawn"
    - "Circle: Summon Serpents"
    - "Circle: Summon Spirits"
    - "Circle: Summon True Elementals"
    - "Circle: Summon the Jinn"
    - "Circle: Summon the Undead"
special_abilities:
  - { name: "Circle Magic", description: "The summoner works entirely in magic circles, not spells. Circles are drawn with specific components, in a specific sequence, and activated by power words and P.P.E. They fall into three families. Circles of Protection: Simple, Superior, and from Angels, Deevils, Demons, Elementals, Elemental Forces, Evil, Faerie Folk, Good, Ghosts and Spirits, Jinn, Magic (simple), Magic (superior), Old Ones, Undead, Witches and Were-beasts. Circles of Summoning: Angels, Animals, lesser and greater Demons and Deevils, Elementals, Elemental Forces, Faerie Folk and others. Circles of Power for the summoner''s own work. The summoner knows every protection and summoning circle from the start, and they are on the sheet. He starts with no power circles: those are bought, won or deciphered from a found circle over time, at the G.M.''s say." }
  - { name: "Summon and Control", description: "A summoning circle calls a being, and a battle of wills decides who is in charge of it. With the GM''s permission a player of anarchist or evil alignment may attempt to summon and bind one lesser demon or deevil as a slave and servant." }
  - { name: "Circle Strength", description: "The base save against the summoner''s magic circles (ritual magic) is 16. He adds +1 to his circle strength at levels seven and fourteen, so 17 from level seven and 18 from level fourteen." }
  - { name: "Magic Bonuses", description: "+1 to save vs magic at levels four, eight and twelve; +2 to save vs horror factor at levels two, four, seven and ten; +3 to save vs possession and against mind control of all kinds." }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "hooded robe or cloak", qty: 1, from: ["robe-hooded", "cape-long-hooded", "robe-heavy", "robe-light"] }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "purse-satchel", qty: 1 }
  - { item_id: "large-sack-pf", qty: 3 }
  - { item_id: "small-sack-pf", qty: 4 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "book-paper-glued-100-sheets", qty: 1 }
  - { item_id: "crow-quill-pen", qty: 3 }
  - { item_id: "ink-black-6-ounces", qty: 1 }
  - { item_id: "ink-color-6-ounces", qty: 1 }
  - { item_id: "charcoal-dozen-sticks", qty: 1 }
  - { item_id: "chalk-dozen-sticks", qty: 1 }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4" }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "large-silver-cross", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is soft leather (A.R. 10, 20 S.D.C.). Hard leather, soft leather and padded armour carry no prowl or climb penalty."
  - "The summoner starts with NO hand to hand skill. Basic costs one related skill and Expert two; Martial Arts and Assassin are not available to this O.C.C. at any price."
  - "Weapon proficiencies exclude Large Axes and the Lance. The starting dagger or short sword is silver coated; the catalog has no silver-coated Palladium row, so it is the ordinary daggers and knives row plus this note."
  - "The kit includes 1D4 cloves of garlic and two iron spikes, neither of which the book prices anywhere; the wooden stakes and mallet stand in for the spikes and hammer."
  - "Summoners are generally feared and avoided, but their services are sought by royalty, the military, merchants and the wealthy."
extraction_notes: "Circles are the whole of this class''s magic. The 51 circles are spell rows in tradition circle since ~091, and since ~113 the magic block grants the 18 protection and 15 summoning circles by name, because printed 135 says the Summoner knows all protection and summoning circles and starts with no power circles. The 18 power circles are not granted and no pick offers them: the book has them acquired in play. spells_per_level is 0 because the class learns nothing by level. The Deciphering Circles skill (20% +4% per level, printed 135) is an O.C.C. skill with its own catalog row, and the circle strength rule (printed 136) is a special ability; see BOOK-INGEST-AUDIT F138. History is added to the catalog by this batch at the printed 30% +5%. The two medium sacks join the large ones, because the equipment chapter prices only small, large and knap. Silver-coated weapons have no Palladium catalog row and no printed price, and are recorded in restrictions instead of stubbed. Garlic and iron spikes have no printed prices either; rows exist now (garlic-cloves, an estimate-priced row, and iron-spike, a Rifts row), the class does not list them, and they are still recorded in restrictions."
---

# Summoner

## Lore

The summoner works no spells. His magic is the circle: drawn with the right
components in the right sequence, activated by power words and P.P.E., and
capable of protecting a place, calling a being out of somewhere else, or holding
one where it stands. Where a wizard studies invocations and a diabolist studies
symbols, a summoner studies what answers when you call it.

That makes him the most feared of the practitioners of magic and the most
avoided. A summoner who can call a demon is a summoner who might, and the
battle of wills that follows a summoning decides which of the two is in charge
of the other.

## Alignment

Any, but often unprincipled, anarchist or evil.

## GM Notes

If the GM allows it, a player of anarchist or evil alignment may try to summon
and bind one lesser demon or deevil as a slave and servant. That is a battle of
wills, not a purchase, and it is worth playing out.

Summoner services are sought by royalty, the military, merchants and the
wealthy, usually quietly.
',
       updated_at = datetime('now')
 WHERE class_id = 'summoner'
   AND instr(markdown, 'and the circle strength rule (printed 136) are not stored.') > 0
   AND length(markdown) = 11369;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'summoner' AND instr(markdown, '{ name: "Deciphering Circles", base: 20, per_level: 4,') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'summoner' AND instr(markdown, 'and the circle strength rule (printed 136) are not stored.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('summoner') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~272-book-ingest-audit-f138-summoner-circles.sql');
