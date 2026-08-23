-- The Priest of Darkness O.C.C., Palladium Fantasy main book, printed pp.68-70.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-priest-of-darkness-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-priest-of-darkness-class.sql
--
-- Read with scripts/read-columns.py. Needs no new catalog rows.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- THE SECOND HALF OF THE BOOK'S PRIEST MATERIAL. Priest of Light is already
-- published from the same source; the book prints the two as separate O.C.C.s
-- with separate stat blocks, and this is the other one. Nothing about the
-- existing class changes.
--
-- MODELLED THE WAY ITS SIBLING IS. The Priest of Light records healing touch,
-- exorcism, remove curse, resurrection, turn dead, spell casting, special
-- prayers and miracles as `natural_abilities` - display prose - because not one
-- of them is a catalog spell the sheet could cost or cast. This class does the
-- same with curses, the Prayer of Strength of the Damned, Animate & Command
-- Dead, its deity-granted spell list and Summon the Minions of Darkness.
-- Matching the sibling matters more than matching the Wizard here: a reader
-- comparing the two priests should find the same shape.
--
-- THE PRAYER BONUSES STAY IN PROSE, and that is a rule rather than laziness.
-- The Prayer of Strength of the Damned gives +6 vs horror factor, +2 on ALL
-- other saving throws, +4 to damage and more - but only twice per 24 hours, for
-- three minutes per level, on a 16% roll rising 8% per level. Extraction is
-- told explicitly to leave conditional bonuses as prose; in `bonuses` they
-- would apply permanently.
--
-- NO ATTRIBUTE REQUIREMENTS AT ALL, which the page states outright: "None. The
-- priest needs only faith and dedication to his gods." So the key is absent
-- rather than empty, the same call the Noble needed.
--
-- THE WEAPON EXCLUSION NAMES ONLY THE ROWS THAT EXIST. The book excludes Siege,
-- Targeting, Large Axes, Pole Arms and the Lance. Targeting, Pole Arm and Lance
-- have catalog rows; Siege and Large Axes do not, and naming them would create
-- dead restrictions that exclude nothing - the Shifter's old bug, and the exact
-- thing test/regression.mjs pins a floor of two for. Recorded in the note
-- instead.
--
-- A GOLD CHALICE is in the kit and the catalog prices only a silver one, which
-- stands in. The one or two symbols of the priest's own god resolve to the
-- generic holy symbol row.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'priest-of-darkness', 'Priest of Darkness', 'palladium-fantasy', '---
id: priest-of-darkness
name: Priest of Darkness
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
ppe_base: "6D6 plus the P.E. attribute number, +2D4 per level of experience"
starting_money: "190"
skills:
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
      - { name: "Domestic", note: "+5%" }
      - "Espionage"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid"], note: "+10%" }
      - { name: "Military", only: ["Heraldry", "Interrogation Techniques", "Surveillance"], note: "+5%" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"] }
      - { name: "Rogue", note: "+5%" }
      - { name: "Science", note: "+5%" }
      - { name: "Technical", note: "+10%" }
      - { name: "Weapon Proficiencies", except: ["W.P. Targeting", "W.P. Lance", "W.P. Pole Arm"], note: "The book also excludes Siege and Large Axes, which have no catalog rows." }
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
extraction_notes: "This is the second half of the book''s priest material; Priest of Light is already published from the same source. Prayers, curses, animate dead and the deity-granted spell list are recorded as natural_abilities, matching how the Priest of Light records its healing touch, exorcism and miracles - display prose, because none of them is a catalog spell the sheet could cost. The weapon-proficiency exclusion names only the three rows that exist: Siege and Large Axes have no catalog row, and naming them would create dead restrictions that exclude nothing. Spell strength and the prayer bonuses live in the ability text rather than in `bonuses`, because both are conditional - the prayer runs twice a day for a limited duration."
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
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'priest-of-darkness');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'priest-of-darkness';
-- Expect 0. Every slug this class grants outright must be a real catalog row.
SELECT 5 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('soft-leather', 'ceremonial-robe', 'holy-symbol', 'silver-chalice', 'food-rations');
-- Expect 0. No dead weapon restriction: every excluded name must be a real row.
SELECT 3 - count(*) AS missing_wp FROM skills
 WHERE name IN ('W.P. Targeting', 'W.P. Lance', 'W.P. Pole Arm');
-- Expect 2. Both priests present, and the existing one untouched.
SELECT count(*) AS priests FROM imported_classes
 WHERE class_id IN ('priest-of-light', 'priest-of-darkness');

INSERT INTO data_script_runs (filename) VALUES ('add-priest-of-darkness-class.sql');
