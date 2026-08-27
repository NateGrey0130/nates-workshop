-- The Apok O.C.C., Rifts Dimension Book 1: Wormwood p.55-59.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-apok-class.sql
--
-- THE PAGE RANGE IS 55-59, NOT THE 55-58 THE CONTENTS AND THE SURVEY BOTH GIVE.
-- Printed 56 and 58 are FULL-PAGE ART: the OCR cache holds SIXTEEN BYTES for
-- p056 and NINE for p058, and neither is text. The Apok's text runs
-- 55 -> 57 -> 59.
--
-- Printed 59 is not optional and not a continuation of a sentence - it carries
-- a THIRD OF THE CLASS: the second half of the O.C.C. related skill category
-- list (Medical through Wilderness), the entire Standard Equipment line, and
-- the Weapons, Armor, Transportation, Money, Cybernetics and Symbiotes
-- entries. A reading that stopped at the cited 58 would have produced a class
-- that looked complete, had half a skill list and no equipment at all, and
-- nothing downstream would ever have flagged it.
--
-- Printed 59 also opens the Monk, so the two classes share it and
-- class-check --field-sources shows both their equipment blocks in either
-- window. The apok's is the one at p59 line 26; the monk's is on p62.
--
-- Hand-transcribed from the OCR cache (the scan has no text layer) and
-- validated with scripts/class-check.mjs --remote before this file was
-- written. Skill bases are the catalog base plus the printed O.C.C. bonus,
-- already added; a parenthetical WITHOUT a plus sign is an absolute
-- percentage, which is how this book prints its languages and its Lore:
-- Wormwood, so "Language: American (98%)" is base 98 rather than a bonus.
--
-- occ_group is clergy for all four. class-check does NOT require the key and
-- does not report it as unmodelled; regression.mjs DOES require it. All four
-- commune with Wormwood and meditate, and warrior-monk is already filed as
-- clergy despite being a warrior, which is the precedent for the apok.
--
-- Money: no starting_money. Every O.C.C. in this book prints
-- "Money: Not applicable" - Wormwood barters - and that is a property of the
-- setting rather than a failed extraction.
--
-- Pure ASCII, LF endings: the whole file, comments included.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
--
-- Every apostrophe inside the markdown is doubled.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'apok', 'Apok', 'rifts', '---
id: apok
name: Apok
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.55-59
category: occ
occ_group: clergy
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
mdc_base: "40, plus 1d6 per level of experience, plus the mask''s 200"
ppe_base: "1d4x10+20, plus 2d6 per level of experience"
bonuses:
  combat: { attacks: 1, initiative: 1 }
  saves: { spell_magic: 2, disease: 2 }
  pools: { mdc: 200 }
skills:
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 50, per_level: 5, note: "+25%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 25, per_level: 5, note: "25% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (at 98%)." }
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "at 98%" }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "at 98%" }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%; the book prints Literacy: American" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Blunt" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Three of choice" }
    - { name: "Hand to Hand: Expert" }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Espionage", bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Create Shelter", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Locate Home Town", "Locate Places of Evil", "Repel Symbiotes"]
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites"]
  spells_schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
equipment_starting:
  - { item_id: "hooded-cloak", qty: 2 }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "The book says one medium size sack; the catalog has no medium." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "The Demon Mask"
    description: "A living symbiotic organism created by the living planet and molded by the repentant warrior, worn as a brand rather than a badge. It sticks to the face like magic and cannot be forcibly removed - only the apok himself can take it off. Horror factor 16 to all demons and evildoers of Wormwood including the Unholy, and 10 to characters of good alignment. All the apok''s attacks inflict DOUBLE damage to supernatural beings and creatures of magic - demons, vampires, dragons, alien intelligences - whatever the weapon, so a dagger doing 1D4 does 2D4 and a laser rifle doing 4D6 M.D. does 4D6x2; even S.D.C. weapons inflict mega-damage against supernatural evil in his hands. +1 attack per melee, +1 on initiative, +200 physical M.D.C., and he heals ten times faster than normal. The mask itself is indestructible and radiates magic. It is said that when the Unholy is slain and his minions destroyed or cast off Wormwood, the mask will become powerless and the apok can finally live in peace."
  - name: "Impervious to Horror Factor"
    description: "Always saves. The apok has walked with monsters and stared into the blackness of his own soul and his own potential for evil - there is nothing more frightening."
  - name: "Impervious to Possession and Mind Control"
    description: "All forms. Having seen the depths of his own potential for evil has given the apok an iron will, great determination and an unbreakable spirit."
  - name: "Supernatural Strength and Endurance"
    description: "The strength of the apok''s resolve has given both spirit and body superhuman strength. Add +2D6 to P.S., which is considered SUPERNATURAL, and +3D6 to Spd, plus +2 to save vs poison, disease and all types of magic."
  - name: "Meditation"
    description: "Focusing his thoughts in prayer regains spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and gives the apok the ability to pilot battle saints and battle saint orbs."
  - name: "Invisible to Magic Seeing"
    description: "Constantly on, with no P.P.E. cost. This is a standing exception to the way the prayer normally works."
  - name: "Hell Fire"
    description: "Inflicts 3D4x10 damage when cast by an apok, rather than the prayer''s ordinary damage."
restrictions: ["Never uses any symbiote except the demon mask, the battle saint and the battle saint orb", "Will not draw P.P.E. from other beings and will not engage in blood sacrifice, even of the most foul villain", "May not select summoning magic as a level-up prayer", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Alignment is GOOD ONLY - 40% principled and 60% scrupulous - and the reborn character always starts at first level with all his original O.C.C. skills lost. Impervious to Symbiotes does not exclude the demon mask, the battle saint or the battle saint orb."
extraction_notes: "THE PAGE RANGE IS 55-59, NOT THE SURVEY AND CONTENTS'' 55-58. Printed 56 and 58 are FULL-PAGE ART - the OCR cache holds 16 bytes for p056 and 9 bytes for p058, and neither is text. The Apok''s text runs 55 -> 57 -> 59, and printed 59 is not optional: it carries the SECOND HALF of the O.C.C. related skill category list (Medical through Wilderness), the whole Standard Equipment line, the Weapons, Armor, Transportation, Money, Cybernetics and Symbiotes entries. Reading only 55-58 would have lost a third of the class. Printed 59 also opens the Monk, so the two share it. || Money: Not applicable, read whole on p.59 - the apok are feared, disliked and on the bottom of the social totem-pole. No starting_money is stored. || Attribute bonuses are NOT stored. The book gives +2D6 to P.S. and +3D6 to Spd, and bonuses.attributes takes flat numbers only - storing an average would put a figure in the sheet that the book never prints. Both are recorded on the Supernatural Strength and Endurance ability and rolled by hand, which is the same rule the Freelancer follows for its d100 chart in #355. The P.S. is SUPERNATURAL, which the sheet does not model either. || M.D.C.: 40 plus 1D6 per level from the class and a flat +200 from the mask. The 200 is a pool bonus so that it reads as coming from the mask, which is where the book puts it. || Technical: the book prints Any (+10%; +20% on any language or literacy). The +20% clause is not stored: the catalog files Literacy under Communications, and this class grants NO Communications at all, so half of that clause reaches a category the apok cannot pick from. The languages it can reach are already granted at 98% as O.C.C. skills. || The level-up prayer list excludes summoning magic per p.57, which removes all ten Summon prayers from the 37 - leaving 27."
---

## Lore

The Apok is the most notorious of the Cathedral''s legion of warriors and
protectors: men and women who started life as Champions of Light, fell prey to
greed, hate or envy, and joined the Forces of Darkness. They served the Unholy
for years. Then they saw the light, forsook evil, and dedicated their lives to
eradicating the Unholy and his dark minions from Wormwood.

They have stared into the face of evil and seen their own reflection. They
walked that path and hurt, if not killed, many people. They are truly sorry, and
they are dedicated one hundred percent to the destruction of evil - they cannot
be bribed, tempted or diverted. That same keen eye for recognizing evil is
turned on everyone, which has given them a clear view of the corruption spreading
in the heart of the Cathedral.

Despite their courage and sacrifice they are feared and viewed with great
suspicion. They were evil once, so people fear they may be lured back. The apok
understand and accept this. They do not blame the people for their fear or even
their hate - they betrayed them once and they have earned the distrust. That is
why they wear the demon mask: as a brand, so all may know they were once fallen
champions, and have risen to become the living nightmare of the Forces of
Darkness.

To become an apok, a villain must be truly sorry, one hundred percent committed,
and willing to die for it. He prays, concentrates, and steps into a life vat
cauldron. If he is sincere he emerges 2D4 minutes later reborn as a Champion of
Light - all of his old O.C.C. skills lost, a new experience table begun, his
alignment now principled or scrupulous, and the demon mask in his hand.

## GM Notes

The typical player character starts at level one or two. The average non-player
apok is 1D4+3 level, fewer than 10% are above 7th, and there are estimated to be
fewer than a thousand of them alive.

**The apok is the lowest of the low socially and the most feared thing on the
board.** p.52 puts him at the very bottom of the human hierarchy, below
criminals and traitors, feared more than the dreaded Dark Priests. Inside the
Cathedral''s own hierarchy he sits fifth, above the monks. The Unholy and his
minions hate and fear the apok above all others, because he knows their cities,
their tactics and their dark secrets from the inside.

Some, like the infamous Confessor, have defied orders and even attacked a high
priest after pointing an accusing finger at the evil and selfish among them.
Those have been branded dangerous rogues, heretics or traitors, and are said to
have become servants of evil again. For now the apok turn their attention to the
greater evil.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'apok');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'apok';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-apok-class.sql');
