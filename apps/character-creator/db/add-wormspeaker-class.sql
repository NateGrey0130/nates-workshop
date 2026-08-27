-- The Wormspeaker O.C.C., Rifts Dimension Book 1: Wormwood p.63-64.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-wormspeaker-class.sql
--
-- THIS IS THE CLASS THAT DRAWS MOST HEAVILY ON #353. The wormspeaker starts
-- with EVERY worm symbiote in the book, and all seven are issued as real
-- item_ids rather than described: worms-of-armor, -blood, -mending, -power,
-- -seeing, -speech and -spirit. That is every worm row that PR imported.
--
-- Its Standard Equipment sits at the TOP of p.64, above the Symbiotic
-- Warrior's own heading, so both classes' equipment blocks are on one page and
-- class-check --field-sources shows both in either window. #355 read the same
-- page from the other side and took the block on p65; this one takes p64.
--
-- Two prayer names differ between the description heading and the p.83
-- authority list: p.63 prints "Summon Edible Grubs & Worms" and "Summon and
-- Use Symbiotes" where p.83 prints "Summon Edible Grubs" and "Summon & Use
-- Symbiotes". The p.83 list is the authority for membership, per the survey,
-- and the catalog holds its spellings.
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
SELECT 'wormspeaker', 'Wormspeaker', 'rifts', '---
id: wormspeaker
name: Wormspeaker
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.63-64
category: occ
occ_group: clergy
xp_table: [0, 2151, 4301, 8601, 18601, 26601, 36601, 54601, 75601, 99601, 135601, 185601, 240601, 290601, 343601]
mdc_base: "25, plus 1d6 per level of experience"
ppe_base: "2d4x10+30, plus 2d6 per level of experience"
bonuses:
  attributes: { PS: -2, PP: -2 }
  saves: { horror_factor: 3, possession: 3, spell_magic: 1 }
skills:
  occ_skills:
    - { name: "Sing", base: 55, per_level: 5, note: "+20%" }
    - { name: "Play Musical Instrument", base: 55, per_level: 5, note: "+20%" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 40, per_level: 5, note: "40% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "First Aid", base: 55, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: One of choice" }
    - { name: "Hand to Hand: Basic" }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", bonus: 15 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Create a Fountain of Water", "Destroy Life Force Cauldron", "Locate Home Town", "Locate Places of Evil", "Remove Symbiotes", "Ride Giant Parasites", "Summon & Use Symbiotes", "Summon Edible Grubs"]
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites", "Summon & Use Stones & Crystals", "Summon & Use Symbiotes", "Summon Battle Saints & Orbs", "Summon Edible Grubs", "Summon Entities", "Summon Flies", "Summon Wind", "Summon and Command Parasites", "Summon and use Angel Hair", "Summon and use Spirits of Wormwood"]
  spells_schedule: [{ level: 2, count: 1 }, { level: 3, count: 1 }, { level: 4, count: 1 }, { level: 5, count: 1 }, { level: 6, count: 1 }, { level: 7, count: 1 }, { level: 8, count: 1 }, { level: 9, count: 1 }, { level: 10, count: 1 }, { level: 11, count: 1 }, { level: 12, count: 1 }, { level: 13, count: 1 }, { level: 14, count: 1 }, { level: 15, count: 1 }]
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
  - { item_id: "worms-of-armor", qty: 1, note: "One set." }
  - { item_id: "worms-of-blood", qty: 12 }
  - { item_id: "worms-of-mending", qty: 20 }
  - { item_id: "worms-of-power", qty: 1 }
  - { item_id: "worms-of-seeing", qty: 1 }
  - { item_id: "worms-of-speech", qty: 1 }
  - { item_id: "worms-of-spirit", qty: 1 }
special_abilities:
  - name: "Meditation"
    description: "Focusing his thought in prayer regains spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and gives the wormspeaker the ability to pilot battle saints and battle saint orbs. It can also be used to double his own rate of healing."
  - name: "All of the Worm Symbiotes"
    description: "The wormspeaker starts with EVERY worm symbiote in the book: a set of worms of armor, twelve worms of blood, twenty worms of mending, and one each of the worm of power, seeing, speech and spirit. He can add one further symbiote at levels 3, 4, 5, 6 and 8 - a total of five, on top of the worms - and can also use symbiotic stones and crystals and the spirit of Wormwood."
  - name: "Horror Factor 11"
    description: "The wormspeaker frightens humans and monsters alike. The worms give him a repulsive and eerie appearance, most notably a tongue composed entirely of wiggling worms."
level_progression:
  - { level: 3, grants: ["One additional symbiotic organism"] }
  - { level: 4, grants: ["One additional symbiotic organism"] }
  - { level: 5, grants: ["One additional symbiotic organism"] }
  - { level: 6, grants: ["One additional symbiotic organism"] }
  - { level: 8, grants: ["One additional symbiotic organism"] }
restrictions: ["May never be of an evil alignment", "May never select Impervious to Symbiotes", "Cannot draw P.P.E. from other beings except by blood sacrifice or when it is offered freely by another wormspeaker or a priest", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Penalties: reduce P.B. by 50%, to no lower than 2 - this already takes every symbiotic organism into account, so do not apply their penalties again - and -2 P.S., -2 P.P. and -1D4 Spd. The P.B. halving and the Spd die are not applied automatically; work them out by hand. The bonuses run the other way too: +1D6 M.E. and +1D4 M.A., plus all the bonuses from the symbiotic worms and organisms."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. p.52 puts the wormspeaker fourth in the social hierarchy, just below the priest of light, and says some are regarded as highly as one. || Attribute changes: only the FLAT ones are stored, -2 P.S. and -2 P.P. The bonuses (+1D6 M.E., +1D4 M.A.) and the remaining penalties (P.B. halved, -1D4 Spd) are dice or percentages that bonuses.attributes cannot take, so they stay in side_effects and are rolled by hand. Storing an average would put a number in the sheet the book never prints. || THIS IS THE CLASS THAT DRAWS MOST HEAVILY ON #353. All seven worm symbiotes are issued as real item_ids rather than described, which is every worm row that PR imported. || Summon Edible Grubs: the description heading on p.63 prints Summon Edible Grubs & Worms, the p.83 authority list prints Summon Edible Grubs, and the catalog holds the list''s spelling. Same for Summon & Use Symbiotes, which p.63 prints as Summon and Use Symbiotes. The p.83 list is the authority for membership, per the survey. || The level-up list excludes Impervious to Symbiotes, which the book states outright. It does NOT exclude the life force cauldron, magic slime, life force battery or worm zombie prayers: the book says the wormspeaker WOULD NEVER CREATE those, which is disposition rather than a bar, and it says in the same breath that he might use a life force cauldron and magic slime for a good purpose. Those stay selectable and the disposition is recorded here. || Standard Equipment is at the TOP of p.64, above the Symbiotic Warrior''s own heading - the two classes'' equipment blocks sit on one page and class-check --field-sources shows both."
---

## Lore

The wormspeaker is born from the peasant class, the common man. He is not usually
affiliated with a specific church or kingdom and spreads no particular doctrine.
He rises from humble beginnings through the use of symbiotic organisms and a
closeness with the Living Planet itself. The people consider him a holy man and
an oracle who uses his knowledge and insight to help others - more a shaman or a
witch doctor than a priest. Highly regarded, protected and granted favors, few
wormspeakers ever become wealthy or hold power; the closest they come to a throne
is as advisor to a king or his court.

The class is usually referred to in the masculine because 95% are male, but women
can also become wormspeakers. They see glimpses of the future and sense the
presence of evil and magic. Their psionic powers come from a variety of
permanent, worm-like symbiotes, which give them a repulsive and eerie appearance
- most notably a tongue composed entirely of wiggling worms.

They draw their power through those symbiotes from the Living Planet, which makes
their relationship with Wormwood more genuinely symbiotic than any other
character''s. That union may be part of why a wormspeaker can never be evil. He
more than any other understands the plight and the pain of the living planet, as
well as that of the people.

## GM Notes

Alignment is any EXCEPT evil: 20% anarchist, 20% unprincipled, 20% principled and
40% scrupulous. The book ties this to the union with the planet rather than to
any vow, so it is a property of what the wormspeaker is, not a rule he could
break.

He starts with every worm symbiote in the book and adds five more organisms over
his career, so his sheet grows sideways rather than upward - most of what he can
do at tenth level is a list of things attached to his body. The P.B. penalty
already accounts for all of them; do not stack the individual symbiotes''
appearance penalties on top.

The book draws one sharp line and one soft one. The sharp line: he can never
learn Impervious to Symbiotes, which would sever him from the source of his own
power. The soft one: he would never create a life force cauldron, magic slime, a
life force battery or a worm zombie - but he might well use a life force cauldron
or magic slime for a good purpose. That is a character judgement, not a
prohibition, and it is where a wormspeaker''s morality gets interesting.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'wormspeaker');


-- Read the result back rather than trusting the exit code. d1-apply prints
-- these, and a CR in the stored markdown means the checkout mangled the file.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'wormspeaker';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-wormspeaker-class.sql');
