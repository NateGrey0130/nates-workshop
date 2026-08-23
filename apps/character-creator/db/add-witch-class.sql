-- The Witch O.C.C., Palladium Fantasy main book, printed pp.112-116.
--
-- One-off data script, run once per environment. NOT a migration - it adds and
-- changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-witch-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-witch-class.sql
--
-- Read with scripts/read-columns.py.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THREE GIFTS, MODELLED AS VARIANTS AS FAR AS VARIANTS REACH. A witch signs a
-- pact and is granted the Gift of Power, the Gift of Magic, or the Gift of
-- Union. They are genuinely different characters - different P.P.E., different
-- bonuses, different everything - so they are `variants`, which is what the
-- shape is for.
--
-- VARIANT_OVERRIDES carries ppe_base and bonuses, and those go on the variants.
-- It does NOT carry `magic`, and that is the interesting limitation here. The
-- Gift of Magic grants a full spell allotment - six from level one, four from
-- level two, two from level three, one from level four, then one per level with
-- the available range widening by one each time. That is the Wizard's shape and
-- it would fit a `magic` block exactly.
--
-- It is recorded as prose instead, because putting the block on the BASE class
-- is the only place it could go, and it would then hand thirteen spells to:
--
--   Gift of Power   which grants no spells at all - four abilities from eleven
--   Gift of Union   whose magic belongs to the creature sharing the body, at a
--                   third of its level, and which the book says explicitly the
--                   witch does not control
--
-- Over-granting two variants to model one is the worse trade. The gap is
-- `magic` not being in VARIANT_OVERRIDES; widening that list touches every
-- variant in the catalog, dragons included, and is not a change to slip into a
-- class import.
--
-- SURVEILLANCE IS DROPPED FROM THE MILITARY ONLY-LIST, and this class is why
-- the check exists. The book allows "Interrogation and Surveillance only".
-- Surveillance is a Communications skill in the catalog, and the Witch is one
-- of the few classes that grants NO Communications at all - so unlike the
-- Priest of Darkness and the Summoner, where the class lists Communications too
-- and the name is admitted, here it would have been reachable from nowhere.
-- class-check reported it as unreachable rather than merely cross-category.
-- Dropped, with the reason in the category note and extraction_notes.
--
-- ONE MUNDANE ROW RECLASSIFIED. `garlic-cloves` was tagged rifts-only. Garlic
-- is not technology, and the witch's kit calls for 1D4 cloves; same trigger as
-- the seven rows fix-pf-armor-and-cross-system-gear.sql moved, and the two
-- add-pf-rogue-gear.sql moved.
--
-- The kit also lists 1D4 black candles and 1D4 sticks of incense. The catalog
-- prices neither; the ordinary candle rows cover the first and the incense is
-- dropped rather than stubbed. The small SILVER dagger and the normal knife
-- both resolve to Daggers and Knives, the catalog having no silver Palladium
-- weapon.

-- ---- the one catalog row this class needs ---------------------------------
UPDATE gear SET system = 'both' WHERE slug = 'garlic-cloves' AND system = 'rifts';

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'witch', 'Witch', 'palladium-fantasy', '---
id: witch
name: Witch
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
starting_money: "100"
variants:
  - id: gift-of-power
    name: "Witch (Gift of Power)"
    ppe_base: "2d4x10+20, but only if the P.P.E. ability is one of the four selected; otherwise none"
  - id: gift-of-magic
    name: "Witch (Gift of Magic)"
    ppe_base: "1d6x10+10, plus 100 more available from the familiar while it is within 300 feet (91.5 m)"
    bonuses:
      saves: { spell_magic: 1, ritual_magic: 1, horror_factor: 1 }
  - id: gift-of-union
    name: "Witch (Gift of Union)"
    ppe_base: "100, combined with any the character already has and shared with the co-possessing essence"
    bonuses:
      attributes: { PS: 6, PE: 6 }
      combat: { initiative: 2, attacks: 1 }
      saves: { horror_factor: 4, illusionary_magic: 4 }
      pools: { isp: "3d4x10", sdc: "3d4x10" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Speaks two additional languages (+10%)" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: Demon & Monster (+20%)" }
    - { name: "Lore: Faeries & Creatures of Magic", base: 35, per_level: 5, note: "Lore: Faerie Folk (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two weapons of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two other skills, or Martial Arts for the cost of three." }
  occ_related_skills:
    count: 10
    categories:
      - { name: "Domestic", note: "+10%; two of the ten must come from Wilderness or Domestic" }
      - { name: "Espionage", note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", note: "+5%" }
      - { name: "Military", only: ["Interrogation Techniques"], note: "The book says Interrogation and Surveillance only. Surveillance is a Communications skill in the catalog and this class grants no Communications at all, so naming it here would offer nothing - see extraction_notes." }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"] }
      - { name: "Rogue", note: "+6%" }
      - "Science"
      - { name: "Technical", note: "+10% on lore and language skills only" }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance"], note: "Any except the Lance and the Long Bow; the catalog has no separate long bow proficiency, only W.P. Archery." }
      - { name: "Wilderness", note: "+5%; two of the ten must come from Wilderness or Domestic" }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 13, count: 2 }]
special_abilities:
  - name: "The Pact"
    description: "Everything the witch has comes from a signed pact with a demon lord, an occasional dark god, or an alien intelligence including the Old Ones and the Splugorth. The signing must be of the character''s own free will. Most such beings are surprisingly straightforward about the conditions, powers and price, and do not cheat - a mortal who tries to cheat THEM is likely to be possessed, or tortured and killed. A witch who forsakes the master loses every witch power and the familiar, and becomes the target of a vengeful demonic lord."
  - name: "Minor Pact: 40 Years of Loyal Servitude"
    description: "The most common minor pact. Complete loyalty and allegiance for forty years, obedience, no other master, no interference with fellow minions, and furthering the master''s goals wherever possible. If the master asks the witch to betray the party or kill a friend, the witch does it without question. A witch has one true friend, and it is the demonic master."
  - name: "Lesser Familiar"
    description: "Granted at second level once the witch has proven himself, identical to the wizard''s Familiar Link spell. A greater familiar may follow after years of loyal service, or as the result of a major pact."
  - name: "Gift of Power: select four"
    description: "The Gift of Power grants FOUR abilities chosen from eleven, and they never improve - skills rise with experience, the gifts do not. The eleven: add 1D6x10+40 I.S.P.; add 2D4x10+20 P.P.E.; impervious to poisons, toxins, drugs, gases and disease; Super Tough, adding 200 physical S.D.C. and healing twice as fast; +2 to save vs all magic and possession; see the invisible and sense magic, automatic; increased mental endurance, +3 vs horror factor, +1 vs psionic attack and all mind control, plus the psionic power of Sixth Sense; flight at will and without limit at Spd 1D6x10+44; supernatural strength and endurance, +10 P.S., rarely fatigues, double damage to mortals and normal damage to demons and creatures of magic otherwise vulnerable only to magic; increased physical prowess, +10 P.P. with the appropriate bonuses and +2 initiative; bio-regeneration restoring 1D4x10 S.D.C. and 4D6 hit points per hour. A demon familiar may be added later at fourth level or higher if the monster feels generous."
  - name: "Gift of Magic: the spell allotment"
    description: "The Gift of Magic bestows magic outright: 1D6x10+10 P.P.E., a demon familiar, and another 100 P.P.E. the familiar gives freely while within 300 feet (91.5 m) and while the witch is doing what it and its master want. SPELLS: six from level one, four from level two, two from level three and one from level four, chosen once and never changed. One new spell at each level of experience, and the available range widens by one level each time - a second level witch may select from levels 1-5, a third level witch from 1-6, and so on. Bonuses: +1 to save vs magic, +1 to save vs horror factor, and +1 spell strength at levels three, seven and thirteen."
  - name: "Gift of Union: the creature shares the body"
    description: "The supposed ultimate reward. The creature shares the witch''s body while allowing the human essence to share control. The character''s alignment immediately becomes the master''s, and a voice in the head implants suggestions, urges violence and entices cruelty. The witch gains all the magic the master knows but at ONE THIRD the creature''s range of knowledge and spell strength, and it is the supernatural essence that controls its use - not the witch. The essence keeps its psionic powers at half strength. Plus 3D4x10 I.S.P., 3D4x10 S.D.C., 100 P.P.E. shared both ways, one extra hand to hand attack, +6 to P.S. and P.E., impervious to further possession and mind control, +4 to save vs horror factor, +4 vs illusionary magic and +2 on initiative. The creature can cancel any or all of it if the witch disappoints."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: "1d4" }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "flint-steel", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4" }
  - { item_id: "candle-fast-burning-45-minutes", qty: "1d4" }
  - { item_id: "holy-symbol", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "garlic-cloves", qty: "1d4" }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 2 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "EVIL ONLY - miscreant, aberrant or diabolic. The book instructs Game Masters to be unbending about it. A witch is not somebody bending a demon to good ends or even to selfish ones; a witch has joined a demonic monster as one of its faithful servants."
  - "No attribute requirements at all. The only requirement is to serve the dark master faithfully, to the letter of the pact, so anyone can become a witch regardless of physical or mental deficiency - and it is often the bitter or mocked individual who does."
  - "A witch must be allied to and serve a monstrous supernatural being. One who forsakes the master loses ALL witch powers and the familiar, and becomes the target of a vengeful demonic lord."
  - "Race: common among Orcs, Ogres, Trolls, Coyles and Humans. Elves, Dwarves, Bearmen, Wolfen, Kankorans, Titans and most giants almost never consider witchcraft - a dwarf who does is regarded as a traitor to the race. Faerie folk, dragons and other creatures of magic CANNOT become a witch."
  - "Armour is soft leather (A.R. 10, 20 S.D.C.), with the same restrictions as the wizard and warlock."
  - "The starting knives are a small SILVER dagger doing 1D4 and a normal knife doing 1D6; the catalog has one Daggers and Knives row and no silver-coated Palladium weapon, so it stands in for both. Favourite weapons are throwing knives, swords, axes, staves and cross bows."
  - "The kit also lists 1D4 black candles and 1D4 sticks of incense. The catalog prices neither; the ordinary long and fast burning candles cover the first and the incense is dropped."
  - "Witches living near a community are feared and respected, and often paid tribute in livestock, food, alcohol and treasure. Among Orcs, Ogres, Trolls and Goblins they are often shamans or leaders. Humans, elves and dwarves avoid them, and the military rarely hires them."
extraction_notes: "Surveillance is dropped from the Military only-list. The book allows Interrogation and Surveillance; the catalog files Surveillance under Communications, and this class is one of the few that grants NO Communications at all, so the name would have been admitted nowhere - a dead restriction of exactly the kind the regression audit pins a floor for. The three gifts are real variants and are modelled as variants for what VARIANT_OVERRIDES can carry - ppe_base and bonuses. It cannot carry `magic`, so the Gift of Magic''s spell allotment (six level one, four level two, two level three, one level four, then one per level with a widening range) is recorded as prose in special_abilities rather than as a magic block. Putting that block on the base class would hand the same thirteen spells to a Gift of Power witch, who gets none, and to a Gift of Union witch, whose magic belongs to the creature sharing the body and is explicitly not the character''s to select. The Gift of Power''s four-from-eleven is the one part that would fit special_abilities'' own choose group; it is written out as a single ability instead because several of the eleven grant things - +10 P.S., 200 S.D.C., a psionic power, unlimited flight - that would need bonuses the shape cannot express together. The long bow exclusion is dropped because the catalog has no separate long bow proficiency, only W.P. Archery, which the book does allow."
---

# Witch

## Lore

A witch is a man or woman who draws power from, and confers with, an evil
supernatural force. They are feared and powerful practitioners of magic,
renowned for dark secrets, illicit unions and associations with supernatural
monsters, and they are generally foul, vengeful beings with little regard for
anyone else.

Everything a witch has is borrowed. The pact grants one of three gifts - power,
magic, or union - and the creature that granted it can switch any of them off
the moment the witch stops being useful. It is the witch who is a slave to the
power and the creature who holds it.

Witchcraft is common among Orcs, Ogres, Trolls, Coyles and Humans. Elves,
Dwarves, Bearmen, Wolfen, Kankorans, Titans and most giants almost never
consider it; a dwarf who does is treated by his own people as a traitor and a
corrupt monster to be destroyed. Faerie folk, dragons and other creatures of
magic cannot become witches at all.

## Alignment

Evil only: miscreant, aberrant or diabolic. The book is explicit that Game
Masters should be unbending here.

## GM Notes

The book suggests this O.C.C. as a non-player villain, and the reason is
structural rather than squeamish: a witch has one true friend, the demonic
master, and if that master asks the witch to betray the party or kill a friend,
the witch does it without question. A player character witch is a party member
with a standing instruction to turn on them.

The design note at the head of this section is worth passing on: Palladium
states that its treatment of witchcraft is entirely fictional and inspired by
horror films rather than by history or myth, that historical pagan practice was
largely druid-like earth magic concerned with healing, harvest and prophecy,
and that nobody at Palladium Books encourages or condones the occult.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'witch');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'witch';
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'flint-steel', 'garlic-cloves',
                'candle-long-burning-3-hours', 'candle-fast-burning-45-minutes');
-- Expect 1. Garlic is visible to a Palladium campaign.
SELECT count(*) AS garlic_cross_system FROM gear
 WHERE slug = 'garlic-cloves' AND system = 'both';
-- Expect 3. All three gifts survived as variants.
SELECT (length(markdown) - length(replace(markdown, 'ppe_base:', ''))) /
       length('ppe_base:') AS variant_ppe_lines
  FROM imported_classes WHERE class_id = 'witch';

INSERT INTO data_script_runs (filename) VALUES ('add-witch-class.sql');
