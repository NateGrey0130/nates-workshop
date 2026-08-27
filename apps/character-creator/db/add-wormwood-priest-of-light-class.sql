-- The Priest of Light O.C.C., Rifts Dimension Book 1: Wormwood p.52-54.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-wormwood-priest-of-light-class.sql
--
-- THE ID IS NOT priest-of-light. That id belongs to a published Palladium
-- Fantasy class from palladium-fantasy-core p.63-67 - a completely different
-- one - so Wormwood's takes wormwood-priest-of-light. The display NAME carries
-- a (Wormwood) suffix for the same reason, on the precedent of rifts-priest,
-- which disambiguated both its id and its name.
--
-- The High Priest on p.54 is NOT imported. It is a social status reached by
-- experienced priests rather than an O.C.C., requires 9th level or higher, and
-- p.157 gives it no experience ladder. What it adds to a priest is recorded in
-- the GM notes so a G.M. can run one.
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
SELECT 'wormwood-priest-of-light', 'Priest of Light (Wormwood)', 'rifts', '---
id: wormwood-priest-of-light
name: Priest of Light (Wormwood)
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.52-54
category: occ
occ_group: clergy
xp_table: [0, 2201, 4401, 8801, 17601, 27801, 37901, 55101, 75201, 100301, 145501, 190601, 245701, 295801, 345901]
mdc_base: "20, plus 1d6 per level of experience"
ppe_base: "1d4x10+50, plus 2d6 per level of experience"
bonuses:
  saves: { horror_factor: 2, possession: 3, spell_magic: 1 }
skills:
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 35, per_level: 5, note: "35% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (98%)." }
    - { name: "Language: Demongogian", base: 70, per_level: 5, note: "+20%" }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%; the book prints Literacy: American" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; the book prints Math: Basic" }
    - { name: "First Aid", base: 55, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "W.P. Blunt" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice" }
    - { name: "Hand to Hand: Basic", note: "May be raised to Hand to Hand: Expert for one O.C.C. related skill, or to Hand to Hand: Martial Arts for two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications" }
      - { name: "Domestic", bonus: 15 }
      - { name: "Espionage" }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Rogue" }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Create a Burial Place", "Create a Fountain of Water", "Create an Opening", "Close an Opening", "Life Fuel", "Locate Places of Evil", "Impervious to Symbiotes", "Mold Structures"]
  spells_starting: 1
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites", "Summon & Use Stones & Crystals", "Summon & Use Symbiotes", "Summon Battle Saints & Orbs", "Summon Edible Grubs", "Summon Entities", "Summon Flies", "Summon Wind", "Summon and Command Parasites", "Summon and use Angel Hair", "Summon and use Spirits of Wormwood"]
  spells_schedule: [{ level: 2, count: 1 }, { level: 3, count: 2 }, { level: 4, count: 2 }, { level: 5, count: 1 }, { level: 6, count: 1 }, { level: 7, count: 1 }, { level: 8, count: 1 }, { level: 9, count: 1 }, { level: 10, count: 1 }, { level: 11, count: 1 }, { level: 12, count: 1 }, { level: 13, count: 1 }, { level: 14, count: 1 }, { level: 15, count: 1 }]
equipment_starting:
  - { item_id: "hooded-robe", qty: 2, note: "For travelling." }
  - { item_id: "ceremonial-robe", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "sleeping-bag-rifts", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "The book says one medium size sack; the catalog has no medium." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "1D4 weeks of rations." }
special_abilities:
  - name: "Meditation"
    description: "The ability to focus one''s thought in prayer is a necessity of life for the priest: WITHOUT IT HE CANNOT USE HIS MAGIC POWERS AT ALL. Meditation and prayer regain spent P.P.E. at ten points per hour, against the four points an hour of ordinary rest, and restore physical damage twice as fast as for ordinary people."
  - name: "Removing Symbiotes"
    description: "All priests of light are versed in the lore of Wormwood and the monsters that infest it - their weaknesses, strengths and habits, and how best to protect against them. The priest is also knowledgeable about symbiotes and has the power to remove them."
  - name: "Shaping the Living Planet"
    description: "Wormwood is alive, and its buildings, spires and mountains are part of its living body. Through prayer and concentration the priest changes and shapes a tiny area of that body: a doorway opens where none existed, the wall spreading apart as if pushed by giant invisible hands through soft clay; water fountains emerge from the ground like a blossoming flower and shrink back as if they had never been; portals close, stairways rise out of walls, and a hut can be made to rise from the ground. This is why a priest leads a siege or a sneak into a demon stronghold, and why one is on almost every reconnaissance team and commando strike force."
restrictions: ["Never uses symbiotic organisms", "Cannot draw P.P.E. from other beings except by blood sacrifice or when a priest offers it freely", "Cybernetics and bionics are virtually non-existent"]
side_effects: "The priest of light never uses symbiotic organisms, but can summon the battle saint and other symbiotes and can use blood stones and magic crystals. There are no ley lines on Wormwood to tap for ambient energy, though some subterranean caves are places of power and work like them."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. The p.52 social hierarchy puts the priest of light third from the top, below only the high priest and the sainted heroes. || THE ID IS NOT priest-of-light. That id is taken by a published Palladium Fantasy class from palladium-fantasy-core p.63-67, a completely different one; the name carries a (Wormwood) suffix for the same reason, on the precedent of rifts-priest. || Prayer schedule: the book says one additional ability at levels one and two, two at levels three and four, and one for each subsequent level. The level-one pick is spells_starting; everything from level two on is spells_schedule. The pick list is all 37 prayers, unrestricted - this is the only one of the four Cathedral classes with no exclusion on it. || Weapons and armor are described rather than issued: 1D4 wooden stakes and a mallet, a silver, crystal or resin cross, and two or three weapons of choice; chain mail through full plate at 40 to 100 M.D.C. with prowl penalties of 0 to -20%. || The High Priest on p.54 is NOT imported. It is a social status rather than an O.C.C., requires 9th level or higher, and p.157 does not give it an XP ladder."
---

## Lore

Long ago the priest was a scholar, teacher, healer and spiritual leader. Today
he must add warrior to that list. All are versed in the basics of combat and
self defense, and many wear armor and carry weapons - but most still consider
themselves teachers, healers and counselors rather than fighters.

His greatest mystical power is the ability to commune with and manipulate the
planet itself. Through prayer and concentration he shapes a small piece of a
living world: doorways open in mega-damage walls, exits close, fountains rise
out of the floor. It makes him the perfect urban spy and a fixture of any
reconnaissance team or commando strike force sent against the cities or the
crawling towers.

Despite the few evil and power hungry individuals in the church''s high command,
most priests of light are caring and compassionate people who help the
downtrodden and fight to keep the spark of humanity alive. Some wander from
city to city righting injustices and slaying monsters - there are priests known
as monster hunters. Others join the knights and freelancers as healers under
arms, or stay in a community to build defenses, organize the people and
establish secret networks of resistance fighters.

## GM Notes

The typical player character starts at level one or two. The average non-player
priest is 1D4+2 level.

Alignment runs roughly 5% evil, 20% selfish, 20% unprincipled, 35% scrupulous
and 20% principled - so an evil priest of light is rare but explicitly allowed,
and the corruption inside the Cathedral''s high command is a running thread of
the book. The apok and the monks are the two groups willing to say so out loud.

**The High Priest is not a character class.** It is a social status reached by
experienced priests who are recognized and elected as heads of the Cathedral,
almost always 9th level or higher, and p.157 gives it no experience ladder. A
high priest adds 1D4x10 P.P.E., +10 M.D.C., another +2 to save vs horror factor,
+2 vs supernatural and psionic possession, +1 vs magic, three more prayers of
choice, and six "other" skills at fifth level proficiency; the congress of them
rules the Cathedral, commands both knightly orders and tries to manage the apok
and the monks. Run one as an NPC with those adjustments.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'wormwood-priest-of-light');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'wormwood-priest-of-light';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-wormwood-priest-of-light-class.sql');
