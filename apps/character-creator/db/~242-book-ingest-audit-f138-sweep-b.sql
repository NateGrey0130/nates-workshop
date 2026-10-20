-- Take BOOK-INGEST-AUDIT F138: seven Rifts Ultimate Edition and D-Bees classes' printed language, literacy or lore bonus as a scoped category entry
-- 7 classes, each replaced whole: faerie-bot, glitter-boy, shifter, wilderness-scout, wild-psi-stalker, body-fixer, bruutasaur.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~242-book-ingest-audit-f138-sweep-b.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Seven Rifts Ultimate Edition and D-Bees of North America classes print a
-- language, literacy or lore percentage that only their notes carried, so
-- categoryBonus paid 0 on those rows (bruutasaur paid +5 on two Literacy rows the
-- book prints at -10). Each now carries a scoped entry in the shape of ~194, ~196
-- and ~241, each figure read off a render of its cited page on 2026-10-20.
-- Language bonuses follow Nate's 2026-10-14 rulings: Language: Dolphin/Whale is
-- the one Language: row the catalog files under Communications, and Language:
-- All (magical) is left out. Nate's 2026-10-20 rulings: on shifter, body-fixer,
-- glitter-boy and faerie-bot only the language/lore/literacy bonus is stored, and
-- the +5% on wild-psi-stalker's and body-fixer's only-lines reaches every skill
-- the line lists.
-- - faerie-bot (D-Bees printed 78): Technical +10 on Lore:.
-- - glitter-boy (RUE printed 70): Technical +5 on Lore:.
-- - shifter (RUE printed 126): +10 on Language: rows, Technical and
--   Communications.
-- - wilderness-scout (RUE printed 99): +10 on Language: rows, Technical and
--   Communications; Technical +15 on Lore:.
-- - wild-psi-stalker (RUE printed 155): its Communications only-line gains +5.
-- - body-fixer (RUE printed 87): +5 on Barter, Creative Writing, Public Speaking,
--   Radio: Basic, Language:, Literacy: and Literacy, through a scoped
--   Communications and a scoped Technical entry; Communications stays Any.
-- - bruutasaur (D-Bees printed 39): Literacy: rows -10 in their own
--   Communications entry, and the subtract-15 restriction line is gone.
-- Left unstored, as the row's brief rules: faerie-bot's Research, glitter-boy's
-- Jury-Rig and Salvage, shifter's Communications +5 and Public Speaking +10,
-- wilderness-scout's Technical +5, Breed Dogs and Rope Works and its
-- Communications list, and body-fixer's only-list.

-- == faerie-bot ==
UPDATE imported_classes
   SET markdown = '---
id: faerie-bot
name: Faerie Bot
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.76-79
category: rcc
tags: [supernatural, tech]
xp_table: [0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 71801, 96901, 137001, 188001, 229201, 279301, 340401]
attribute_dice:
  IQ: "1d4+10"
  ME: "1d4+10"
  MA: "1d6+10"
  PS: "1d6+2"
  PP: "1d6+8"
  PE: "1d6+10"
  PB: "1d6+2"
  Spd: "2d6"
hit_points_base: "P.E. + 2d6, +1d6 per level"
sdc_base: "1d4x10"
ppe_base: "3d4x10, +10 per level"
psionics:
  type: "master"
  isp_base: "M.E. x10, +5 per level"
  powers: ["Empathy", "Object Read (Psychometry)", "Mind Bolt", "Telemechanics", "Telemechanic Mental Operation", "Telemechanic Paralysis"]
  powers_starting: 0
magic:
  type: "spell"
  spells: ["Globe of Daylight", "Ignite Fire", "Fuel Flame", "Fire Bolt", "Call Lightning", "Energy Bolt", "Energy Field", "Impervious to Energy", "Manipulate Objects"]
  spells_starting: 2
  spells_per_level: 2
  spell_levels_allowed: [1, 2, 3, 4]
bonuses:
  combat: { initiative: 1, strike: 1, pull_punch: 4, roll: 2 }
  saves: { possession: 2, horror_factor: 3 }
skills:
  occ_skills:
    - { name: "Anthropology", base: 35, per_level: 5, note: "+15%" }
    - { name: "Basic Electronics", base: 50, per_level: 5, note: "+20%" }
    - { name: "Basic Mechanics", base: 60, per_level: 5, note: "+30%" }
    - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Computer Repair", base: 40, per_level: 5, note: "+15%" }
    - { name: "Cybernetics: Basic", base: 35, per_level: 5, note: "+10%" }
    - { name: "Field Armorer & Munitions Expert", base: 60, per_level: 5, note: "The book prints Field Armorer (+20%)." }
    - { name: "General Repair & Maintenance", base: 65, per_level: 5, note: "+30%" }
    - { name: "Jury-Rig", base: 45, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Language and Literacy: Native Tongue at 98%; an alien language." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Language and Literacy: Native Tongue at 98%; an alien language." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: Other, one of choice (+10%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Math: Basic and Advanced (+20%)." }
    - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "Math: Basic and Advanced (+20%)." }
    - { name: "Navigation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20%" }
    - { name: "Prowl", base: 50, per_level: 0, note: "Natural ability: tiny size gives an automatic Prowl of 50%. The sphere itself prowls at 60% flying or hovering, 75% when trying to be unseen, 90% hiding motionless." }
  occ_related_skills:
    count: 2
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Mechanical", bonus: 10 }
      - "Science"
      - { name: "Technical", note: "Any; +10% to Research and any Lore skill only (printed 78). The next entry carries it on Lore; on Research it is not stored." }
      - { name: "Technical", only_prefix: ["Lore:"], bonus: 10 }
    note: "Select two at levels 1, 4, 8 and 12, from these categories only. Mechanical: any (+10%). Technical: any, with +10% to Research and any Lore skill only. All new skills start at first level experience."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 0
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 11, count: 2 }
      - { level: 14, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "work-overalls", qty: 2 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "duffle-bag", qty: 1 }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "work-gloves-rifts", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "air-filter", qty: "2d6" }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "portable-hand-held-computer", qty: 1 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "pencil", qty: "1d4" }
  - { choose: 1, label: "pen or marker", qty: 1, from: ["pen", "marker"] }
  - { item_id: "work-boots-rifts", qty: 1, note: "Printed as comfortable boots, at tiny size." }
  - { item_id: "faerie-bot-environmental-body-armor", qty: 1 }
  - { item_id: "disposable-surgical-gloves", qty: 1, note: "Printed as a box of 50 plastic gloves; the row is priced per box." }
  - { item_id: "faerie-bot-portable-radio-and-translator", qty: 1 }
  - { item_id: "faerie-bot-protective-helmet", qty: 1 }
natural_abilities:
  - name: "Senses"
    description: "Sharp vision, nightvision 300 feet (91.5 m), and a natural polarizing lens: a thin second eyelid that slides over the eye against bright light and works like polarized sunglasses."
  - name: "Natural Mechanics"
    description: "On top of the psionic machine powers, can soup up most machines to run, move or fly 10-20% faster, works out how to use and operate most machines including Techno-Wizard devices, and strips, repairs and reassembles machines three times faster than a human. Artificial intelligences and computers baffle it: -35% when working on them, and it cannot hack computers."
  - name: "Tiny size"
    description: "Stands 1D4+8 inches tall. The tiny size gives an automatic Prowl of 50%."
  - name: "Techno-Wizard powers"
    description: "An alien version of a Techno-Wizard in miniature: has all the basic Techno-Wizard O.C.C. Magic Powers and TW Construction abilities (Rifts Ultimate Edition, Techno-Wizard O.C.C.). All spells should be suitable for Techno-Wizard application and carry the same limitations as the Techno-Wizard O.C.C."
  - name: "Half-strength magic and little sleep"
    description: "Casts its spells at half the normal strength, range and duration. Needs only three hours of sleep per 24 hours."
  - name: "Faerie Bot Vehicle"
    description: "Every Faerie Bot flies a sphere the size of a basketball, which its people call an All-Environment Exploration Biosphere, or Eeb. Two or three primary arms (at least one a utility arm and hand; equivalent P.S. 1D6+12); 1 or 2 secondary appendages such as a tentacle or sensor antenna (equivalent P.S. 1D4+5); 2-4 retractable tool appendages, half with interchangeable heads and half specialized (laser cutter, plasma torch, electro-magnetic adhesive pad and the like); 1 or 2 light weapons, typically a laser, range 2,000 feet (610 m), 2D6 to 3D6 M.D.; tow line with hook and grapple, 30 feet (9 m), 500 lb (225 kg) test, and anything above 300 lb (135 kg) slows the sphere by 25%; universal language translator at 93%, speaking back by loudspeaker or radio; directional narrow and wide band radio, 100 mile (160 km) range, and the vehicle can be hailed and controlled by radio and psionics; multi-optics; proximity alarm at 10 feet (3 m); unlimited unknown power supply and unknown hover and propulsion system. Flight: hovers, lands and flies to 150 mph (240 km), cruising at 10-30 mph (16 to 48 km), maximum altitude 60,000 feet (18,288 m), and it can survive and navigate in outer space. Propulsion is completely silent: Prowl 60% when flying or hovering, 75% when trying to be unseen, 90% if hiding, concealed and motionless. Underwater: 60 mph (96 km) on or under the surface, depth one mile (1.6 km). M.D.C.: legs (2) 12 each, main arms (2-3) 20 each, secondary limbs and tool appendages (1-4) 10 each, main body 120, and it is -3 to strike even with a called shot. Self-repairs about 40 M.D.C. unaided; more needs the pilot, time and parts, and a destroyed sphere takes 1D4+6 months to rebuild. A failsafe makes it self-destruct when its designated pilot is killed: the internal systems burn out, any P.P.E. reserve is released and it crumbles to junk, wires and dust."
trackable_resources: []
restrictions:
  - "The book heads it an optional player character or NPC. Player characters should start at first or second level. Canada''s Player Note, which D-Bees of North America does not restate, leaves allowing one entirely to the G.M.''s discretion."
  - "Alignment: any, but most are Anarchist."
  - "Available O.C.C.s: none. All are effectively a Techno-Wizard/Scientist or TW Explorer/Operator through the R.C.C.: these skills only, plus the Magic Powers and TW Construction abilities of the Techno-Wizard O.C.C."
  - "R.C.C. Related Skills, Technical: the +10% applies to Research and Lore skills only. Secondary skills get no bonus other than a high I.Q. bonus."
  - "Psionics: effectively a Master Psychic, but limited to the six listed powers. Needs a 10 or higher to save vs psionic attack and mind control."
  - "Magic: the nine listed spells plus two of choice per level of experience from spell levels 1-4, all cast at half the normal strength, range and duration. All spells should be suitable for Techno-Wizard application and have the same limitations as the Techno-Wizard O.C.C."
  - "M.D.C.: only through the Faerie Bot vehicle, magic or body armor. Needs magic or M.D.C. body armor for protection against M.D. weapons, just like a human."
  - "Combat: attacks per melee round are as per the Hand to Hand Combat skill, if any; a psionic attack counts as one melee action. Damage is as per P.S., psionics, magic or weapon."
  - "Standard equipment is all at tiny size, made for the doll-sized D-Bee. The equipment list includes comfortable boots, a suit of environmental body armor (1D6+22 M.D.C.), a box of 50 plastic gloves, a portable radio and language translator (10 mile/16 km range) and a protective helmet with built-in language translator, radio and loudspeaker. Also carried, beyond the listed items: a comb and some personal items, and the Faerie Bot Vehicle."
  - "Cybernetics and Bionics: admires machines but avoids getting bionics itself."
side_effects: "Cannot resist messing with machinery, especially something it has never seen before or that is broken, including other people''s property; it needs only three hours of sleep and wanders off to explore or tinker when bored, so its curiosity gets it and its friends into trouble. Vulnerability: its tiny size leaves it open to attack even from small predatory animals such as cats and dogs, as well as birds of prey and larger animals. Fears the Minions of Splugorth, Horune Pirates, Faerie Folk, dragons and other creatures of magic, and is wary of practitioners of magic other than Techno-Wizards."
extraction_notes: "ORIGINAL: this class followed Rifts World Book 20: Canada printed 149-152 until this update; under the ruling of 2026-10-04 the newest printing that states a figure wins, so it now follows Rifts World Book 30: D-Bees of North America printed 76-79 (cache p077-p080, cache page = printed folio + 1), whose entry is headed Faerie Bot D-Bee and ends with the note Originally appeared in Rifts World Book 20: Canada. Every figure was read off page renders of both books (Canada printed 149 and 151; printed 150 is a full-page illustration). || HEADING: optional player character or NPC; imported as a playable R.C.C. on the repo owner''s decision for Canada''s optional player creatures. Canada printed 149 carried a Player Note leaving it to the G.M.''s discretion; D-Bees does not restate it and it is kept as a restriction line. || NATURE: D-Bees says the Faerie Bot is a tiny mortal humanoid D-Bee and that reports of an innate magical nature are wrong; Canada printed 149 called them creatures of magic. The natural ability named Creature of magic became Half-strength magic and little sleep; the authored tags are left as they were. || XP: D-Bees printed 78 says Use the same Experience Table the Techno-Wizard; the ladder is copied from the stored xp_table of the catalog class techno-wizard (Rifts Ultimate Edition). Canada printed 192 sent the Faerie Bot to the Dragon table, and the row held the ladder of dragon-hatchling: 0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001. || ATTRIBUTES: identical in both books. || HIT POINTS: both books print Hit Points: 2D6 +P.E. attribute number. Plus 1D6 M.D. per level of experience, starting at level one, and then S.D.C.: 1D4x10 plus those gained from Physical skills; need magic or M.D.C. body armor for protection against M.D. weapons, just like humans. D-Bees adds M.D.C.: Via Faerie Bot vehicle, magic or body armor. It is stored as an S.D.C./hit point being: hit_points_base P.E. + 2D6 with the per-level 1D6 read as hit points, and sdc_base 1D4x10; no mdc_base. || P.P.E. 3D4x10 +10 per level and I.S.P. M.E. x10 +5 per level are the same in both books. || PSIONICS: All are effectively Master Psychics, limited to six powers, granted by name with no picks; the same six in both books. The book prints Object Read; the catalog row is Object Read (Psychometry). D-Bees adds the I.S.P. costs: Empathy 4, Object Read 6, Mind Bolt varies, Telemechanics 10, Telemechanic Mental Operation 12, Telemechanic Paralysis 20. || MAGIC: nine named spells granted, plus two of choice per level of experience from spell levels 1-4, stored as spells_starting 2 and spells_per_level 2 with levels 1-4. D-Bees printed 79 lists the ninth spell as Manipulate Objects (2+); Canada printed 151 gave Telekinesis, which is no longer granted. Call Lightning and Impervious to Energy are level 6 in the catalog and granted by name. Half strength, range and duration is a restriction line. D-Bees adds that all spells should suit Techno-Wizard application with the Techno-Wizard O.C.C.''s limitations, and that the class has all the basic Techno-Wizard O.C.C. Magic Powers and TW Construction abilities; those are stored as natural ability and restriction text that points at the Techno-Wizard O.C.C., whose own pages were not re-read for this update. || BONUSES: +1 initiative, +1 strike, +4 pull punch, +2 roll, +2 vs possession, +3 vs Horror Factor, the same in both books. The master psychic save of 10 comes from the psionic tier. || SKILLS: D-Bees printed 78 restates the R.C.C. Skills line as bonuses over a longer list, stored at catalog base plus the printed bonus with the catalog''s per-level: Anthropology +15%, Basic Electronics +20%, Basic Mechanics +30%, Computer Operation +20%, Computer Repair +15%, Cybernetics: Basic +10%, Field Armorer +20% (catalog row Field Armorer & Munitions Expert), General Repair & Maintenance +30%, Jury-Rig +20%, Land Navigation +15%, Language and Literacy: Native Tongue at 98% (stored on both Language: Native Tongue and Literacy: Native Language), Language: Other one of choice +10%, Math: Basic and Advanced +20%, Navigation +20%, Radio: Basic +20%, Sensory Equipment +20%. Canada printed 151 gave basic and advanced math, basic electronics, basic mechanics, general repair/maintenance and field armorer all at a flat 95%, prowl (while in their sphere) and find contraband at 60%, and land navigation 70% +2% per level as a natural ability. Find Contraband is not in the D-Bees line and was removed. Prowl: D-Bees prints an automatic Prowl 50% from tiny size under Natural Abilities, stored as the skill at a flat 50, and gives the 60% to the vehicle (75% unseen, 90% hiding motionless). || RELATED AND SECONDARY SKILLS: new in D-Bees printed 78. Related: two at levels 1, 4, 8 and 12 from Communications, Domestic, Mechanical (+10%), Science and Technical; the Technical bonus is +10% to Research and any Lore skill only; its Lore half is a scoped Technical entry on the Lore: rows (BOOK-INGEST-AUDIT F138, 2026-10-20), and its Research half is the note and the restriction line. Secondary: two at levels 3, 5, 8, 11 and 14 and none at level one, stored as count 0 with a schedule. Canada printed neither. || O.C.C.: D-Bees prints Available O.C.C.s: All are effectively a Techno-Wizard/Scientist or TW Explorer/Operator, see R.C.C. above; the class takes no O.C.C. and that is a restriction line. Hand to Hand: attacks are As per Hand to Hand Combat skill, if any; the R.C.C. grants no Hand to Hand skill and its related categories do not include Physical. || EQUIPMENT: D-Bees printed 79 adds a personal equipment list, all at tiny size, where Canada''s Standard Equipment was the Faerie Bot Vehicle alone. Items with a catalog row are in equipment_starting (the catalog rows are the ordinary human-sized items); since ~116 and ~117 that includes comfortable boots as work-boots-rifts, the box of 50 plastic gloves as disposable-surgical-gloves qty 1 (the row is priced per box), and three tiny-sized rows of the Faerie Bot''s own: the environmental body armor of 1D6+22 M.D.C. (a roll held in the row''s description) as faerie-bot-environmental-body-armor, the portable radio and language translator as faerie-bot-portable-radio-and-translator and the protective helmet as faerie-bot-protective-helmet. The comb and personal items have no matching row and are a restriction line. The Faerie Bot Vehicle is a vehicles row, faerie-bot-vehicle, which the class does not list in equipment because no gear pointer row exists for it; its full statistics are natural ability text. || VEHICLE: D-Bees adds Legs (2) 12 M.D.C. each, main arms 2-3 where Canada printed 2, a 100 mile radio range, control by radio and psionics, the name All-Environment Exploration Biosphere or Eeb, the vehicle''s Prowl figures, and a maximum altitude of 60,000 feet with outer space survival where Canada printed Unknown, at least 30,000 feet (9144 m) and may be outer space capable. The crumbling of the sphere at its pilot''s death is now a deliberate failsafe. The attribute line gives Spd 2D6 running; the sphere''s 150 mph flight is not a class number. || NOT STORED, in GM Notes: size 1D4+8 inches (Canada 8-12 inches); weight 2-5 lb and sphere 60-70 lb (Canada 1-2 lb and 40-70 lb); average life span 4D6+50 years (Canada: Unknown. Immortal?); average NPC level 1D4+4; Horror Factor not applicable; disposition, habitat, allies and enemies. Neither book prints money."
---

## Lore

Faerie Bots came to Rifts Earth on purpose, through a Rift in the ruins
of Detroit some thirty years ago, and for a long time were seen only
around the industrial centers of southern Canada, Michigan and
Chi-Town. They are not kin to the true Faerie Folk of Earth and are not
creatures of magic at all: they are tiny mortal D-Bees about a foot
tall, with a wide shield-shaped head, big round coal-black eyes, a small
nose and a large mouth. What sets them apart is the machine. Each one
rides inside a floating sphere the size of a basketball, bristling with
little arms, tools and antennae, and so seldom steps out that scholars
once took the pilot and the sphere for a single robot. The name stuck.

They are tinkerers to the bone. Robots, power armor, cyborgs and vehicles
fascinate them, and they understand almost any machine at a glance; only
computers and artificial minds leave them stumped. Their own spheres
run on a science very like Techno-Wizardry that nobody else has
managed to study, because a sphere falls to scrap and dust the moment
its pilot dies.

Small groups of three to a dozen live together, and singles or pairs
roam for years. They are shy, curious and playful, fond of humans and
Sasquatch, and now and then one attaches itself to a band of
adventurers. It means well and tries to help. It also sleeps three hours
a night and cannot leave a machine alone, including machines that belong
to somebody else, so its friends spend a good deal of time apologizing.

## GM Notes

The book heads the Faerie Bot an optional player character or NPC; a
player character starts at first or second level. It levels on the
Techno-Wizard experience table. Also called Techno-Faeries and Bubble
Faeries; the race''s real name is Fraanids.

They came to study Rifts Earth, coming and going through the Detroit
Rift for 25 years until a shift in its harmonic frequencies shut the
door in the spring of 104 P.A. Those on Earth are trapped. Some keep
hidden base camps and go on studying; others have made contact with
Lazlo and New Lazlo, at least a hundred are exploring the Magic Zone,
and some join adventurers in the hope of finding a way home.

Hit points and M.D.: the book adds "1D6 M.D. per level" to the Hit
Points line, then says under S.D.C. that the creature needs magic or
M.D.C. armor against M.D. weapons, as a human does. The sheet treats it
as a hit point and S.D.C. being, with the 1D6 per level as hit points.
The sphere is the M.D.C. part: 120 main body.

The Faerie Bot Vehicle is the creature''s standard equipment and is
described in full under the natural abilities. It is a vehicle row,
not a gear row, so the equipment list does not carry it. Out of the
sphere the creature speaks only its own squeaky
language, which is not Earth''s Faerie tongue; the sphere''s translator
handles every language at 93%.

Spells are cast at half strength, range and duration.

Size 1D4+8 inches (23 to 30.5 cm); weight 2-5 pounds (0.9 to 2.25 kg),
the sphere 60-70 lb (27 to 31.5 kg). Average life span 4D6+50 years,
mature at 16. NPCs average level 1D4+4. Horror Factor: not applicable.

Habitat: anywhere in North America, but mainly the Domain of Man, where
technology is thickest: southern Canada, Lazlo, Michigan, the Coalition
States of Iron Heart and Chi-Town, and Free Quebec. Very rare, perhaps
as many as 500 on Earth. Allies: their own kind, Lazlo and New Lazlo;
they especially like humans, Dog Boys, Quick-Flex Aliens, Grackle
Tooth, Kraks, Fingertooth Carpetbaggers, A''rac, Adna Nomads and
Dewtani, and feel a kinship with Operators, Rogue Scholars, Rogue
Scientists, Techno-Wizards and Psi-Techs. Enemies: none as such, though
they know demons for evil and hate slavers, tyrants and oppressors.

The block prints no money.
',
       updated_at = datetime('now')
 WHERE class_id = 'faerie-bot'
   AND instr(markdown, 'which is a note and a restriction line, not a category bonus.') > 0
   AND length(markdown) = 21681;

-- == glitter-boy ==
UPDATE imported_classes
   SET markdown = '---
id: glitter-boy
men_of_arms: true
occ_group: men-of-arms
name: Glitter Boy
system: rifts
source_book: Rifts Ultimate Edition p.67-73
category: occ
tags: [combat, pilot]
xp_table: [0, 2151, 4301, 8401, 17501, 25601, 35701, 52801, 72901, 98501, 132501, 183501, 235001, 285001, 345001]
starting_money: "4d6x100"
attribute_requirements:
  PP: 10
bonuses:
  combat: { initiative: 1, strike: 1, pull_punch: 2 }
  saves: { horror_factor: 3 }
  pools: { sdc: 20 }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "At 95%, the figure its own O.C.C. block prints (RUE p.70) rather than the catalog''s generic 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, per_level: 5, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Basic Electronics", base: 40, per_level: 5, note: "+10%" }
    - { name: "Basic Mechanics", base: 45, per_level: 5, note: "+15%" }
    - { name: "General Repair & Maintenance", base: 45, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 42, per_level: 4, note: "+6%" }
    - { name: "Pilot Robot Combat Elite: Glitter Boy", base: 0, per_level: 0 }
    - { name: "Pilot Robot Combat Basic (general)", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Pilot"] }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Expert for the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin if evil alignment) for the cost of two skill selections." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Automotive Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Military", only: ["Field Armorer & Munitions Expert", "Demolitions", "Demolitions Disposal", "Military Etiquette", "Recognize Weapon Quality"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - "Pilot"
      - { name: "Pilot Related", only: ["Navigation"], bonus: 5 }
      - "Rogue"
      - "Science"
      - { name: "Technical", note: "Any; +5% to Jury-Rig, Salvage and Lore skills only (printed 70). The next entry carries it on Lore; on Jury-Rig and Salvage it is not stored." }
      - { name: "Technical", only_prefix: ["Lore:"], bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 2 }
    note: "Cowboy, Electrical and Horsemanship offer none and are omitted. Medical: pick one of the two. Category bonuses: Espionage Detect Ambush +10% and others +5%, Mechanical +5%, Military Demolitions/Disposal/Etiquette +10% and others +5%, Pilot Related +5%, Technical +5% to Jury-Rig, Salvage and Lore skills only, Wilderness +2%. Military Etiquette is a book option the catalog does not carry yet. Of those bonuses, Mechanical +5%, Pilot Related +5%, Wilderness +2% and Technical''s +5% on Lore skills (a scoped entry, BOOK-INGEST-AUDIT F138, 2026-10-20) are APPLIED as category bonuses; the rest are not stored."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "glitter-boy-power-armor", qty: 1 }
  - { choose: 1, label: "light or medium environmental body armor", qty: 1, from: ["urban-warrior-padded-environmental-body-armor", "huntsman-armor"] }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["wilk-s-447-laser-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle"] }
  - { choose: 1, label: "energy side arm of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol"] }
  - { choose: 1, label: "non-energy weapon of choice", qty: 1, from: ["submachine-gun"] }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "hand-grenade", qty: 2 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 6 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "fatigues", qty: 2 }
  - { item_id: "velcro-strapped-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
natural_abilities:
  - name: "Racial Piloting Bonuses"
    description: "Glitter Boys descended from generations of GB pilots (rather than those who recently acquired their armor) get: +1 on initiative, +1 to strike, +2 to pull punch, +3 to save vs Horror Factor, +20 S.D.C., and +1 additional melee attack/action when using a GB. These bonuses only apply to those with a long family tradition of piloting the Glitter Boy."
  - name: "Hand to Hand Combat Elite: Glitter Boy"
    description: "Available only to those who take Power Armor Combat Elite: Glitter Boy (automatic to the Glitter Boy O.C.C.). All bonuses are in addition to the pilot''s own hand to hand combat training and attribute bonuses, and do not apply to the pilot''s physical abilities when outside his power armor. +2 extra attacks/actions per melee round, in addition to those of the pilot at level one; +1 additional attack at levels 3, 7, and 11. +2 on initiative. +2 to strike when shooting the Boom Gun and other rail guns/cannons, in addition to W.P. Heavy Energy Weapons skill bonuses. +2 to strike in hand to hand combat. +2 to parry in hand to hand combat. +2 to dodge. +1 to disarm. +4 to pull punch. +3 to roll with impact. Punch Damage: 1D4 M.D. restrained, 1D6 M.D. full strength. Power Punch: 2D6 M.D., counts as two melee attacks. Kick Damage: 2D4 M.D. (Power Kick not possible). Running Leap Kick: 4D6 M.D., counts as three attacks. Tear or Pry with Hands (Special): 1D6 M.D. Body Block/Ram: 2D4 M.D. Full Speed Running Ram: 3D6 M.D., uses up three melee actions. Stomp: 1D6 M.D., effective only against objects/targets smaller than three feet tall. Pylon Impalement: 1D6 M.D., not very useful in most combat situations."
  - name: "Special Sensory Systems"
    description: "Full optical systems including laser targeting, telescopic, passive nightvision (light amplification), thermal-imaging, infrared, ultraviolet, and polarization. Advanced Laser Targeting gives the Boom Gun +2 to strike (in addition to the usual power armor laser targeting bonus). Self-Destruct Mechanism prevents the armor and its technology from falling into enemy hands. Laser Resistant Armor: all Glitter Boys are made from special alloys with a chrome-looking surface resistant to laser attacks (half damage). Other features include all standard environmental power armor features, plus built-in language translator and depth gauge."
restrictions:
  - "Glitter Boy armor can be used by any character trained to pilot power armor, but only members of the Glitter Boy O.C.C. are specifically trained in the complete understanding and operation of GB armor at the elite level."
extraction_notes: |
  - REVIEW: the three ability entries are automatic and live under
    natural_abilities - special_abilities is for powers a player chooses, and
    this class chooses none. Fixed skills fold the O.C.C. bonus into the
    catalog base (Radio: Basic 45+10=55); Basic Mechanics and General Repair &
    Maintenance have catalog rows via backfill-import-skill-gaps.sql; their
    bases here fold that catalog base plus the O.C.C. bonus. The open
    weapon choices enumerate the catalog''s rifles and pistols with the generic
    rows as the of-choice fallback, and the non-energy weapon is one, as the
    book says, not two.
  - AUDIT: The class''s racial piloting bonuses (initiative, strike, pull punch, save vs
    Horror Factor, S.D.C., extra attack) are stated to apply ONLY to those "with a long
    family tradition of piloting the Glitter Boy," not those who recently acquired
    their armor - a conditional gate the bonuses schema cannot express, so it is
    recorded in bonuses at top-level AND repeated as prose in special_abilities per the
    book''s wording; GMs should apply it only when the character background supports it.
  - The Hand to Hand Combat Elite: Glitter Boy package (extra attacks at level 1/3/7/11,
    +2 initiative, +2 strike w/ Boom Gun, +2 strike/parry/dodge in HtH, +1 disarm, +4
    pull punch, +3 roll with impact, and various punch/kick/ram/stomp damage values)
    is conditional on taking Power Armor Combat Elite: Glitter Boy, which is automatic
    to this O.C.C., and only applies while piloting the armor (does not apply to the
    pilot''s own physical abilities outside the suit) - kept as prose rather than
    unconditional bonuses since it''s armor-state-dependent.
  - Standard Equipment lists choices without enumerated named items ("energy rifle and
    energy side arm of choice," "one non-energy weapon of choice (maybe S.D.C.)," "two
    hand grenades," "two smoke grenades") - recorded as open choices/labels since no
    specific catalog items are named on this page.
  - The Glitter Boy Power Armor itself (Model USA-G10, MDC by location, weapon
    systems, speed, statistical data, etc., detailed on pages 71-73) is referenced here
    as a single equipment item; full armor/weapon stats are summarized below in GM Notes
    rather than forced into the O.C.C. schema, since this schema is for the character
    class, not the vehicle/equipment catalog.
  - Page 70 "Game Designer''s Secrets" and page 73 "Designer''s Note to Game Masters" are
    author commentary (Kevin Siembieda) about the game''s design history and GM balance
    philosophy - placed under GM Notes as prose, not mechanical data.
  - Cybernetics: "Start with none, but may purchase cybernetic augmentation later as
    desired. Typically limited to cybernetic implants and Bio-Systems for medical
    reasons." No mechanical bonus stated, recorded as restriction/prose only.
  - Money: also noted to have "another 1D4x1000 in Black Market items" beyond the
    starting credits - recorded here since starting_money captures only the coin figure.
---

## Lore

"It''s not about fame, power or money. It''s about generations of tradition and making a difference, helping people who need it. That''s our destiny."

The Glitter Boy is both a relic of the past and symbol of power, hope and courage. Of all the Mega-Damage suits of power armor available on Rifts Earth, only the Glitter Boy is *known* to have originated from before the Great Cataclysm and remains one of the most powerful, feared and respected fighting machines on the planet. Powerful, because of its heavy armor and laser resistance. Feared, because of its Boom Gun and endurance. Respected, because Glitter Boy armor was the weapon of the greatest heroes in North America throughout the Two Hundred Years Dark Age.

Legend says the armor was created by a group of powerful beings known as the Neemans - heroic supermen who fought to stem the tide of chaos and destruction during the Great Cataclysm and are reputed to have saved millions of lives. Whether they were humans, D-Bees from another world, sorcerers, or demigods remains a matter of heated debate. The true origin (revealed by later Rifts sourcebooks) is that Glitter Boy armor was the *Chromium Guardsman*, developed by NEMA (Northern Eagle Military Alliance - USA, Canada, and Mexico), the first fully field-operational power armor deployed by the pre-Rifts US military, misidentified by Dark Age legend as the "Neemans."

During the Two Hundred Years Dark Age, humanity fell into barbarism, competing with D-Bees, monsters, demons, and dragons for survival. Only the Glitter Boy, largely undamaged and unmatched by contemporary technology, allowed lone champions and small bands of heroes to stand against overwhelming supernatural threats - armor passed down from hero to chosen successor or worthy squire, becoming a symbol of noble tradition and legend.

Today the Glitter Boy''s status as unique wonder is fading: the Coalition States and other manufacturers (Northern Gun, Triax, Naruni Enterprises) have produced newer, often smaller, faster power armors, and Free Quebec - the largest producer and secret manufacturer of Glitter Boys and variants (see Rifts World Book 22) - maintains the largest legion of GBs in the world, guarding the secrets of their construction jealously as the "secret weapon" underpinning their military strength and political independence. Most Glitter Boys encountered outside Free Quebec are heroes carrying on a long family legacy with pre-Rifts relic armor, patched and repaired for centuries.

The typical Glitter Boy pilot is a career soldier with delusions of greatness - a grunt who finds combat a thrill and a hero who strives to help the innocent and downtrodden. Many wander as mercenaries or community protectors, tolerant of nonhumans, respectful of life, and open to new ideas; their long heritage of heroism keeps them grounded and committed to fighting evil, especially monsters and slavers. Some call them "champions of heroes." All are nobody''s fools, and view strangers with suspicion until trust is earned. Combat experience can also harden pilots to cold, cruel indifference over time.

## GM Notes

**Alignment:** Any, but most tend to be Principled, Scrupulous, Unprincipled, and Anarchist.

**Glitter Boy Power Armor (Model USA-G10)** - Class: Laser Resistant Infantry Personnel Assault Unit. Crew: One pilot. Height 10 ft 5 in (3.1 m); Width 4 ft 4 in (1.3 m); Length 4 ft (1.2 m); Weight 1.2 tons fully loaded. Physical Strength equal to Robot P.S. of 30.

M.D.C. by Location: Rail Gun/Boom Gun - 175; *Head - 290; *Hands (2) - 100 each; Arms (2) - 270 each; Legs (2) - 450 each; Reinforced Pilot''s Compartment - 150; **Main Body - 770. (*Called Shot required, -4 to strike; **depleting Main Body shuts the armor down completely. Laser weapons do half damage to the Glitter Boy.)

Speed: Running 60 mph (96 km) max, tires the pilot at only 10% the usual fatigue rate. Leaping 12 ft (3.6 m) high/across, +10 ft (3 m) with running start; jet thrusters can add a leap up to 80 ft (24 m) or hold the GB aloft up to 12 ft for 1D6x10 seconds (not true flight). Underwater: 15 mph (24 km/13 knots) swimming, or walk the sea bed at 25% normal speed; max depth one mile (1.6 km); firing the Boom Gun underwater requires anchoring pylons into the seabed or a hull.

Main Weapon - RG-14 Rapid Acceleration Electromagnetic Rail Gun ("Boom Gun"): fires 200 flechette rounds per blast at Mach 5, inflicting 3D6x10 M.D. per burst; creates a sonic boom that deafens everyone within 200 ft (61 m) unprotected (2D4 minutes, -8 initiative, -3 parry/dodge; shorter duration with armor). Payload 1000 rounds per auto-feed canister; reload by hand takes 15 minutes for 40 rounds, or a small extra ammo-drum of 400 rounds can be hip-mounted. Maximum effective range 11,000 ft (~2 mi/3.2 km). Black Market Cost: 25 million+ credits new/fully powered with ammo; 15-20 million for rebuilt/gunless.

Designer commentary (Kevin Siembieda) notes the Glitter Boy was the very first character concept created for Rifts, originally envisioned as the central hero of a game called *Boomers* before evolving into one ensemble character among many as the RPG''s scope expanded.

On game balance: the Glitter Boy is designed with deliberate strengths (massive M.D.C., great firepower, killer reputation/Horror Factor) and deliberate weaknesses (slow speed, limited mobility, trouble with soft/muddy ground, vulnerability to fast fliers like SAMAS, concealed hit-and-run attackers, immobilization, and magic). GMs should exploit these weaknesses to keep the class balanced rather than banning it as "too powerful" or dismissing it as "too weak" - both complaints reflect the same character used well or poorly. A team of Glitter Boys or mixed adventurers using teamwork and cleverness should be rewarded; the GM''s job is to make villains counter that teamwork credibly, not simply hand PCs victories or overwhelm them arbitrarily.',
       updated_at = datetime('now')
 WHERE class_id = 'glitter-boy'
   AND instr(markdown, 'the rest stay prose because they differ per skill and a category carries one number') > 0
   AND length(markdown) = 16579;

-- == shifter ==
UPDATE imported_classes
   SET markdown = '---
id: shifter
men_of_arms: false
occ_group: magic
name: Shifter
system: rifts
source_book: Rifts Ultimate Edition p.120-126
category: occ
tags: []
xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]
attribute_requirements: { IQ: 12, ME: 12 }
ppe_base: "2d6x10+10 plus P.E. attribute number, +2d6 per additional level starting at level two"
starting_money: "1d6x1000"
magic:
  type: "spell"
  spells_per_level_from: ["Banishment", "Charm", "Close Rift", "Commune with Spirits", "Compulsion", "Control & Enslave Entity", "D-Step", "Desiccate the Supernatural", "Dimensional Teleport", "Dispel Magic Barriers", "Distant Voice", "Domination", "Energy Disruption", "Energy Sphere", "Expel Demons", "Forcebonds", "Influence the Beast", "Ley Line Transmission", "Locate", "Magic Pigeon", "Mystic Portal", "Air: Phantom Mount", "Plane Skip", "Power Bolt", "Protection Circle: Simple", "Protection Circle: Superior", "Reality Flux", "Rift to Limbo", "Rift Teleportation", "Sheltering Force", "Tame Beast", "Teleport: Lesser", "Teleport: Superior", "Time Hole"]
  spells_per_level_levels: up_to_character_level
  spells_schedule:
    - { level: 2, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 2, count: 1, note: "Not dimension-related or control-based" }
    - { level: 3, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 3, count: 1, note: "Not dimension-related or control-based" }
    - { level: 4, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 4, count: 1, note: "Not dimension-related or control-based" }
    - { level: 5, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 5, count: 1, note: "Not dimension-related or control-based" }
    - { level: 6, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 6, count: 1, note: "Not dimension-related or control-based" }
    - { level: 7, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 7, count: 1, note: "Not dimension-related or control-based" }
    - { level: 8, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 8, count: 1, note: "Not dimension-related or control-based" }
    - { level: 9, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 9, count: 1, note: "Not dimension-related or control-based" }
    - { level: 10, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 10, count: 1, note: "Not dimension-related or control-based" }
    - { level: 11, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 11, count: 1, note: "Not dimension-related or control-based" }
    - { level: 12, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 12, count: 1, note: "Not dimension-related or control-based" }
    - { level: 13, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 13, count: 1, note: "Not dimension-related or control-based" }
    - { level: 14, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 14, count: 1, note: "Not dimension-related or control-based" }
    - { level: 15, count: 2, from_list: true, note: "One of these two must be a Protection or Summoning spell (excluding weather summoning)" }
    - { level: 15, count: 1, note: "Not dimension-related or control-based" }
  spells: ["Calling", "Call Lightning", "Compulsion", "Constrain Being", "Dimensional Portal", "Energy Bolt", "Energy Field", "Exorcism", "Repel Animals", "Re-Open Gateway", "Sense Evil", "Sense Magic", "Trance", "Shadow Meld", "Summon and Control Canines", "Summon and Control Rodents", "Sustain", "Time Slip", "Turn Dead", "Tongues"]
bonuses:
  saves: { horror_factor: 4, possession: 3, mind_control: 3 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 5, saves: { horror_factor: 1, possession: 1, mind_control: 1 } }
    - { level: 7, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 10, saves: { spell_magic: 1, ritual_magic: 1, possession: 1, mind_control: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 13, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 15, saves: { horror_factor: 1, possession: 1, mind_control: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "anarchist or evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Literacy: Native Language", base: 70, per_level: 5, note: "+30%" }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "One of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Astronomy", base: 45, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Mathematics: Basic (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: Dimensions", base: 35, per_level: 5, note: "Special Shifter skill: the study of dimensions - what dimensions exist, who lives there, dimensional quirks. Alien dimensions may impose -15% to -50%; places visited three or more times give +15%. Printed base 15% +5%/level, +20% O.C.C. bonus folded in." }
    - { name: "Lore: Faeries & Creatures of Magic", base: 40, per_level: 5, note: "Lore: Faerie (+15%)." }
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts or Assassin (if Anarchist or evil alignment) for the cost of two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", except: ["Laser Communications", "Optic Systems", "Surveillance", "T.V./Video"] }
      - { name: "Communications", only: ["Language: Dolphin/Whale"], bonus: 10, note: "The +10% on Languages (printed 126), on the Language: row the catalog files here." }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing", "Gymnastics", "Wrestling"] }
      - { name: "Pilot", except: ["Airplane", "Jet Aircraft", "Helicopter", "Military: Jet Fighters", "Military: Tanks & APCs", "Robots & Power Armor", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats"] }
      - { name: "Pilot Related", except: ["Sensory Equipment"] }
      - "Rogue"
      - "Science"
      - "Technical"
      - { name: "Technical", only_prefix: ["Language:"], bonus: 10, note: "Communications'' +10% on Languages (printed 126), on the Language: rows the catalog files here." }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Any (+5%, +10% on Languages and Public Speaking). Domestic +5%. Espionage: Intelligence only (+5%). Medical: First Aid, Holistic Medicine, or Paramedic only (+5%). Rogue +2%. Science +5%. Technical +5%. Cowboy, Mechanical and Military: none. The +10% on Languages is stored as a scoped Communications and a scoped Technical entry on the Language: rows (BOOK-INGEST-AUDIT F138, 2026-10-20); the other bonuses on this line are not stored."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "large-wood-cross", qty: 1 }
  - { item_id: "garlic-cloves", qty: "2d4" }
  - { item_id: "wooden-stake", qty: 6 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "salt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "submachine-gun", qty: 1 }
  - { choose: 1, label: "energy rifle", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"] }
  - { item_id: "iron-javelin-rod", qty: 1 }
natural_abilities:
  - name: "Dimension Sense"
    description: "After 1D6+2 minutes of concentration, reads a connecting Rift or dimensional portal: type of dimension (Infinite, Parallel, Pocket), fabric density, habitability, magic richness, artificial origin, unusual characteristics. Also senses whether a Rift will soon close, was opened deliberately, its frequency, attached anomalies, and nearby dimension-spanning monsters (that aspect at -10%). Base Skill: 35% +5% per level. Combat: can roll (one melee attack) to detect any dimension-based magic that round; can attempt to REDIRECT dimension-based magic in a magical duel of 1D20 rolls, spending the same P.P.E. - never stop it, only change it."
  - name: "Dimensional Travel"
    description: "Opens a one-way dimensional portal for himself and his familiar at a base cost of 125 P.P.E.; each additional person +25 P.P.E., paid up front. Open one minute at most, five people per melee round. Can target home dimension, a random dimension, or one visited before; levels 5-9 can target a specific country or continent, level 10+ arrives within 50 miles (80 km) of the desired destination. For greater accuracy and two-way travel: Dimensional Portal (1000 P.P.E.) or Re-Open Gateway (180 P.P.E.) at HALF the usual cost via a special ritual (1D6x10+15 minutes) known only to Shifters, holding the Rift open one minute per level and sizing it up to 10x10 feet per level."
  - name: "Communication Rift"
    description: "Opens a grapefruit-sized micro-Rift to send a message or a small animal familiar through - how a Shifter contacts an Alien Intelligence. P.P.E.: 50 on a nexus, 100 on a ley line, 200 away from ley lines. Duration: one minute per level; only the Shifter can close it. Success Ratio: 20% +5% per level for the exact location (+20% as a ritual taking 1D6x10+15 minutes longer); a complete success transcends space and time to reach a specific location on any world or dimension, with two-way conversation."
  - name: "Dimensional Teleport Home"
    description: "Always finds his way home from another dimension for 75 P.P.E. - himself, his familiar and carried gear only. One melee action to activate."
  - name: "Rifting on the Same World"
    description: "Can open a Rift anywhere on the same planet for HALF the usual dimension-jumping P.P.E. cost, provided he has visited the location or is linked to it by a Communication Rift. Can also Rift from one point on a ley line to another, or to any connecting line, without ever having been there. Ley line nexus points work as cosmic bus stops."
  - name: "Sense Rifts"
    description: "Feels the surge of a Rift within 50 miles (80 km) +20 miles (32 km) per level, and knows when a new Rift appears along a ley line he stands on regardless of distance - general direction and size. Also senses Teleports and dimensional anomalies at half range. Relates to Rifts and portals, not nexus points and ley lines."
  - name: "Familiar Link"
    description: "Links mentally and physically with one animal (not insects, intelligent mutants or supernatural creatures). The animal obeys every command, the two share senses, and the Shifter can see through its eyes (no other action while doing so). Special Endurance: BOTH gain +6 Hit Points, +1 to save vs poison and +1 vs mind control and possession. If the familiar is hurt the Shifter feels it; if killed, he permanently loses 10 Hit Points and has a 01-50% chance of lapsing into a coma for 1D6 hours. Cannot link to another familiar for at least one year."
  - name: "Summoning"
    description: "Via the Communication Rift, probes dimensions for a LESSER supernatural being and initiates a battle of wills: the summoned being must roll above the Shifter''s M.A. three out of five times on 1D20 (M.E. bonuses and mind-control save bonuses add to the creature''s roll; a natural 20 always wins). Failure makes it totally subservient except to reveal its true name or commit suicide. One lesser being can be controlled at level 1, +1 at levels 3, 5, 7, 9, 11, 13 and 15; a Greater Demon or undead counts as two. Beings that defy control may return home (01-25%), run off (26-50%), feign servitude and plot betrayal (51-75%), or attack (76-00%). Servitude can also be bargained into a simple pact signed in the creature''s own blood."
  - name: "P.P.E. and Recovery"
    description: "Permanent Base P.P.E.: 2D6x10+10 plus P.E.; +2D6 per level. Draws freely from ley lines, nexus points, his demons, blood sacrifices and willing participants. Recovery: 5 per hour of rest; meditation restores 10 per hour and counts as one hour of sleep."
  - name: "Learning New Spells"
    description: "Starting at level two, chooses one spell per level from the Shifter list (Banishment, Charm, Close Rift, Commune with Spirits, Compulsion, Control and Enslave Entity, D-Step, Dessicate the Supernatural, Dimensional Teleport, Dispel Magic Barriers, Distant Voice, Domination, Energy Disruption, Energy Sphere, Expel Demons, Forcebonds, Influence the Beast, Ley Line Transmission, Locate, Magic Pigeon, Mystic Portal, Phantom Mount, Plane Skip, Power Bolt, Protection Circle: Simple, Protection Circle: Superior, Reality Flux, Rift to Limbo, Rift Teleportation, Sheltering Force, Tame Beast, Teleport: Lesser, Teleport: Superior, Time Hole, and any Summoning spell except weather) PLUS one Protection or Summoning spell from that list, PLUS one non-dimension spell of any kind up to his current level. Can also purchase and learn spells like other mages, though they rarely do."
  - name: "Link to the Supernatural (optional)"
    description: "May link to a supernatural patron - a Demon Lord, god of darkness, Warrior God, god of magic, or Nature Spirit - trading service for bonuses (see GM Notes). Anarchist and evil Shifters take this fast path to power; alignments slip toward evil over time."
restrictions:
  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels 4, 7, 10 and 13."
  - "Cybernetics: starts with none and avoids them like the plague - they interfere with magic and make him look weak to his demonic henchmen."
  - "Shifting is considered one of the dark magicks: outlawed in some places, feared and shunned in many. The Coalition States destroy Shifters on sight."
extraction_notes: |
  - RUE p.120-126. Typically starts Unprincipled or Anarchist; any alignment.
  - The 20 named starting spells land via magic.spells (auto-known); the
    per-level learning scheme (one dimension spell + one Protection/Summoning
    + one open pick) has no schema shape and lives in Learning New Spells.
  - Lore: Dimensions is a Shifter-only skill entered with its own numbers
    (printed 15% +5%, +20% O.C.C. bonus folded to 35%) - the Find Contraband
    precedent.
  - The battle-of-wills mechanics, pact conditions and the whole Link to the
    Supernatural patron system (five patron types with distinct bonuses) are
    transcribed in GM Notes; none of it maps to schema.
  - Equipment: one weapon per W.P. plus 1D4 ammo/E-Clips each; the
    submachine-gun is loaded with silver bullets; the iron javelin rod
    (three feet, sharpened) dispels certain magic illusions and monsters.
  - Money: 1D6x1000 credits + 2D6x1000 in Black Market items.
---

## Lore

Shifters are students of magic whose emphasis is mastery over the Rifts - opening dimensional portals and summoning creatures from beyond this earthly veil. These mages have a reputation for being irrational and evil; it is undeserved, for there are as many good, kind and well intentioned Shifters as evil ones. But it is the black-hearted ones - who enslave the beings they summon and unleash them against fellow mortals - who give the entire profession its reputation, and the art itself is one of the most dangerous and corrupting of the mystic arts.

The Shifter is not so much a vessel for magic energy himself, but a conduit and stimulus that agitates, activates, controls and directs the energy around him. He can ignite a ley line nexus to surge and open a Rift without expending the energy from inside himself, and draws upon the P.P.E. of those around him - willing henchmen, summoned beings, or (for the evil) blood sacrifices. This shifting of magic energy from one source to another is what gives the sorcerer his title.

Shifters are the true masters of the Rifts: one of the few classes that embraces dimensional travel, exerting influence over dimensional beings and supernatural creatures who wander the Megaverse. No group of dimensional travelers should be without one, for they can read and control the very Rifts to take them to specific worlds, and their knowledge of dimension lore, dimensional travelers, monsters and anomalies is unsurpassed.

## GM Notes

**Limitations & Conditions of Simple Pacts of Servitude:** (A) the shorter the service the better - under a year, ideally under six months; (B) one lesser being controlled at level 1, +1 at levels 3, 5, 7, 9, 11, 13, 15; two sub-demons or imps count as one lesser being, a Greater Demon or undead as two; (C) keep demonic minions under five - two or three is better; give them titles, ranks and jobs to minimize friction; (D) the new guy goes to the bottom of the hierarchy; (E) never mix natural enemies like Demons and Deevils; (F) Black Faerie, Witchlings, Brodkil and others can be enticed by revenge, power, wealth or magic items - but can break their promise at any time; (G) never show weakness. NEVER.

**Link to the Supernatural** (optional, mostly Anarchist/evil): **Demon Lords** - +1D6x10 P.P.E., +1D4x10 S.D.C., +3 vs Horror Factor, +1 Spell Strength, +1 vs magic, daily summon of one Lesser Demon; after a year the Demon Lord can punish the Shifter at will weekly as per Agony. **Gods of Darkness** - +1D4x10 S.D.C., +1D6x10+20 P.P.E., Animate/Control Dead 3x daily, +2 vs magic and Horror Factor; by level three: +6 to P.S. or P.P., +2 all saves, one demonic minion for life; expects errands and evil. **Warrior God** - +1D6x10+30 S.D.C., +5D6+6 P.P.E., +2 all saves, 1D4+1 spells from levels 2-5, one ancient W.P., Hand to Hand: Martial Arts; expects boldness and challenge. **Gods of Magic** - +2D6 S.D.C., +1D6x10+40 P.P.E., +1 vs magic, +3 vs possession, eight spells from levels 3-13 (or a less common branch of magic); +1 Spell Strength at levels 4 and 8 if worthy. **Nature Spirits** - +4D6+6 P.P.E., 1D4+1 spells from levels 1-4, transform into one animal type (wolf, coyote, puma, deer or horse) four times daily for an hour per level with +6D6+12 S.D.C., +1 initiative, +1 strike, +2 dodge, +4 vs mind control and possession in animal form; bonus skills Dowsing, Identify Fruits & Plants, Land Navigation, Swimming and Track Animals at 75%; cannot cast spells in animal form.

Related O.C.C.s: old "revised" Shifters are in Rifts Dark Conversions and Dimension Book 7: Megaverse Builder, which also offers unusual alien familiars and in-depth dimensional-travel material.
',
       updated_at = datetime('now')
 WHERE class_id = 'shifter'
   AND instr(markdown, 'Cowboy, Mechanical and Military: none."') > 0
   AND length(markdown) = 21054;

-- == wilderness-scout ==
UPDATE imported_classes
   SET markdown = '---
id: wilderness-scout
men_of_arms: false
occ_group: optional
name: Wilderness Scout
system: rifts
source_book: Rifts Ultimate Edition p.98-100
category: occ
tags: [wilderness]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_requirements:
  IQ: 8
  PE: 12
bonuses:
  attributes: { PS: "1d4", PE: "1d4" }
  pools: { sdc: "3d6+10" }
  combat: { initiative: 1, roll: 2, perception: 3 }
  saves: { toxins_poisons: 2, disease: 2, coma_death_pct: 10 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 94, per_level: 1, note: "At 94%, the figure its own O.C.C. block prints (RUE p.99) rather than the catalog''s generic 98%. The book omits the "at", printing "Language: Native Tongue 94%"." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: Other, two of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Cook", bonus: 15, note: "+15%" }
    - { name: "Climbing", bonus: 20, note: "+20%" }
    - { name: "Fishing", bonus: 15, note: "+15%" }
    - { name: "Horsemanship: General", bonus: 20, note: "+20%" }
    - { name: "Identify Plants & Fruit", bonus: 20, note: "+20%" }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Land Navigation", bonus: 20, note: "+20%" }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes", "Horsemanship: General"], bonus: 14, note: "Pilot: Motorcycle (+14%) or Hovercycle (+10%) or Horsemanship (General); pick one." }
    - { name: "Prowl", bonus: 15, note: "+15%" }
    - { name: "Radio: Basic", bonus: 10, note: "+10%" }
    - { name: "Track & Trap Animals", base: 20, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", bonus: 20, note: "+20%" }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. Ancient and/or Modern: Three of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if evil alignment) for the cost of two." }
  occ_related_skills:
    count: 2
    categories:
      - "Physical"
      - "Wilderness"
      - "Communications"
      - { name: "Communications", only: ["Language: Dolphin/Whale"], bonus: 10, note: "Language (any; +10%), printed 99, on the Language: row the catalog files here." }
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Horsemanship"
      - "Mechanical"
      - "Medical"
      - "Military"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - { name: "Technical", only_prefix: ["Language:"], bonus: 10, note: "Communications'' Language (any; +10%), printed 99, on the Language: rows the catalog files here." }
      - { name: "Technical", only_prefix: ["Lore:"], bonus: 15, note: "Technical''s +15% on Lore (any), printed 99." }
      - "Weapon Proficiencies"
    note: "Select two Physical skills, one Wilderness skill and six other skills, +1 at levels 2, 5, 8, 11, and 14. All new skills start at level one proficiency. Communications: Barter, Language (any; +10%), Literacy (any), Performance, and Public Speaking only. Cowboy: None. Domestic: Any (+10%). Electrical: Basic Electronics only. Espionage: Any (+10%), except Forgery and Pick Locks. Horsemanship: Exotic Animals (+5%) only. Mechanical: Automotive only. Medical: First Aid (+10%) or Holistic Medicine (+20%), but the latter counts as two skill selections. Military: None. Physical: Any, except Acrobatics (+10% when applicable). Pilot: Any, except robots, power armor, military or large, noisy vehicles. Pilot Related: Any. Rogue: Gambling, Imitate Voices & Sounds, and Tailing only (+5%). Science: Math: Basic, Anthropology, Biology, and Botany only. Technical: Any (+5% to most, a +15% bonus applies only to Breed Dogs, Lore (any) and Rope Works). W.P.: Any. Wilderness: Any (+20%). The +10% on Language and the +15% on Lore are stored as scoped Communications and Technical entries (BOOK-INGEST-AUDIT F138, 2026-10-20); the other bonuses and lists on this line are not stored."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 8, count: 1 }
      - { level: 11, count: 1 }
      - { level: 14, count: 1 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
starting_money: "3d6x100"
equipment_starting:
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "e-clip", qty: 4, label: "+1D4 E-Clips for each W.P." }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { choose: 1, label: "combat knife", qty: 1, from: ["vibro-knife", "vibro-saber"] }
  - { item_id: "boots", qty: 1 }
  - { item_id: "helmet", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-ammo-belt", qty: 1 }
  - { item_id: "sack", qty: 2 }
  - { item_id: "cord", qty: 1, label: "several short pieces of cord for tying things" }
  - { item_id: "lightweight-rope", qty: 1, label: "100 feet (30 m) of lightweight rope" }
  - { item_id: "iron-spike", qty: 6 }
  - { item_id: "wooden-stake", qty: 6, label: "wooden spikes (as much for vampires as anything else)" }
  - { item_id: "wooden-cross", qty: 1, label: "8 inches/20 cm" }
  - { item_id: "hammer-and-mallet", qty: 1 }
  - { item_id: "hand-axe-utility", qty: 1, label: "utility knife, animal skinning knife" }
  - { item_id: "fishing-line-and-hooks", qty: 1, label: "pole optional" }
  - { item_id: "animal-snare", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "flare", qty: 6 }
  - { item_id: "infrared-binoculars-digital-distancing-readout", qty: 1 }
  - { item_id: "passive-nightvision", qty: 1, label: "a pair of passive nightvision goggles" }
  - { item_id: "telescopic-scope", qty: 1, label: "telescopic sight for a gun" }
  - { choose: 1, label: "old or shabby looking, but reliable vehicle (missing 1D4x10% of its original M.D.C.) that matches Piloting skill", qty: 1, from: ["hovercycle", "jeep", "riding-horse"], note: "The book names no specific vehicle; this is the catalog set, widened as more books are imported." }
extraction_notes: |
  - Skill bases in occ_skills are the printed O.C.C. bonus percentages as given
    on the page; the page states these are bonuses added to a base skill, but
    per the operator hint the printed number is used directly as "base" since
    catalog base + bonus is already combined in the source presentation given.
  - Standard Equipment list is split across page 99''s end and likely continues
    onto a following page not provided; the list appears cut off after
    "infrared binoculars with digital distancing readout, a pair" ' || char(8212) || ' remaining
    items were read from the following page of the scan (cache file p103) and
    folded in by fix-wilderness-scout-page-break.sql: a pair of passive
    nightvision goggles, a telescopic sight for a gun, and an old or shabby
    looking, but reliable vehicle (missing 1D4x10% of its original M.D.C.)
    that matches Piloting skill.
  - Money and Cybernetics (cache file p103): starts with 3D6x100 in credits
    and another 3D4x1000 in Black Market items or animal pelts and furs -
    starting_money holds the credits, and the goods are not coin.
    Cybernetics: most avoid unnatural cybernetic augmentation except when
    needed as a prosthetic; prose, since the app has no cybernetics
    mechanic.
  - Special O.C.C. Abilities (Trail Blazing, Cross-Country Pacing,
    Cartography) are percentile skill-like abilities with base/per-level
    formulas but are not skill-list skills; recorded as special_abilities
    since they do not fit the skills schema cleanly.
  - "O.C.C. Bonuses" section: +3D6+10 to physical S.D.C. was recorded under
    sdc_base-style bonus; +1D4 to P.S. and P.E. attributes recorded as
    attribute bonuses; +1 on initiative and +3 on Perception Rolls (both stored in bonuses.combat;
    combat.perception is a real key - see derive.js and CLASS-AUDIT F8 - and this
    note said it was not until RETRO-AUDIT R1, 2026-09-04); +2 to roll with
    impact; +2 to save vs
    poison and disease (mapped to toxins_poisons); +10% to save vs Coma &
    Death; +1 to save vs Horror Factor at levels 2, 4, 6, 9 and 15 (recorded
    as a flat bonus plus a note about the leveled nature).
---

## Lore

"Some folks is afeared of the woods, but to me, they''s home sweet home. It''s the city thet makes me feel a might uncomfortable."

A lot of city-folk look down on Wilderness Scouts as uneducated rabble, but in the savage wilderness, they are the lords and ladies of the forest. A Scout knows his way around the forest like the back of his hand. They consider themselves to be one of the woodland predators and are stealthy, cunning, resourceful and self-reliant.

A Wilderness Scout can be a native raised in the wilderness or a city slicker who has come to learn the ways of the wild. Regardless of their origin, the character is a walking encyclopedia about hunting, trapping, wildlife, and the land, but most are complete illiterates, unable to read or write a word. On the other hand, many are captivating storytellers who love to weave tales about the things they have seen and done. Most are also experts in Demon, Monster and Faerie Lore. The Wilderness Scout knows many of nature''s secrets and can live off the land with ease and traverse the wilderness without leaving a trace that he was there.

Generally, a Wilderness Scout is a rough and tumble fellow who enjoys tests of skill, strength, and cunning, and who enjoys life to its fullest (and purest). The years of life in the outdoors means the individual is powerfully built, conditioned to harsh climates and environments, and tough as nails. Their weathered skin makes them look ten years older than they really are. Although a Wilderness Scout may be sorely lacking in social graces, he is no stranger to technology and uses high-tech M.D.C. body armor and Mega-Damage energy weapons, and pilots a hovercraft with the same skill as his horse. Still, the typical Scout, no matter how acquainted he is with technology, will be uncomfortable in the confines of a city. His place is the wide open spaces of the wilderness. That is his home and his choice.

## GM Notes

**Trail Blazing** enables a Scout to cut and mark trails for others; a failed roll means the trail cannot be followed as intended ' || char(8212) || ' a good complication hook for lost NPC parties.

**Cross-Country Pacing** makes the Wilderness Scout an excellent overland messenger, capable of covering great distances quickly and predicting travel time accurately. A Scout never reveals his most secret and favorite routes to clients or strangers accompanying him unless it is an absolute emergency ' || char(8212) || ' use this as a roleplaying lever; these characters "come and go without anyone knowing how, when or where they''ve been."

**Cartography** lets the Scout produce highly accurate maps by hand or with tools; a failed roll produces maps with inaccuracies and details missed, with locations off by 1D10 miles ' || char(8212) || ' useful for GMs wanting to seed exploration mishaps.

Related O.C.C.s: see the Gambler, Saddle Tramp, Saloon Bum and Bar Maid in Rifts World Book 14: New West for thematically similar wilderness/rural characters.',
       updated_at = datetime('now')
 WHERE class_id = 'wilderness-scout'
   AND instr(markdown, 'Wilderness: Any (+20%)."') > 0
   AND length(markdown) = 11548;

-- == wild-psi-stalker ==
UPDATE imported_classes
   SET markdown = '---
id: wild-psi-stalker
men_of_arms: true
occ_group: psychic
race_restrictions:
  only: ["mutant-psi-stalker"]
  note: "Racial Requirement: Psi-Stalkers are mutant humans only (RUE p.155). The race is the mutant-psi-stalker R.C.C. (BOOK-INGEST-AUDIT F110, taken 2026-09-27), which carries the Psi-Stalker''s attributes, P.P.E., psionics, racial bonuses and natural abilities; this occupation is what the character learned."
name: Wild Psi-Stalker
system: rifts
source_book: Rifts Ultimate Edition p.155-156
category: occ
tags: [wilderness, hunter]
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
starting_money: "0"
bonuses:
  attributes: { PS: 2, PP: 2 }
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native Tongue (American) at 90%." }
    - { choose: 1, from: ["Language: Other"], bonus: 25, note: "Language: Other, one of choice (+25%). Taken once per language - the picker asks which." }
    - { name: "Detect Ambush", base: 35, per_level: 5, note: "+5%" }
    - { name: "Escape Artist", base: 35, per_level: 5, note: "+5%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Horsemanship: Cowboy", base: 76, per_level: 3, note: "+10%" }
    - { name: "Horsemanship: Exotic Animals", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Tracking (humanoids, NOT animals; +10%)." }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: three of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", only: ["Barter", "Language: Other", "Performance", "Sign Language", "Radio: Basic"], bonus: 5 }
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Astronomy & Navigation", "Mathematics: Basic"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Barter, Language Other, Performance, Sign Language and Radio: Basic only (+5%). Domestic +5%. Medical: First Aid and Holistic Medicine only (+5%). Physical: Any (+5% where applicable). Pilot: Any (+5%) except power armor, robots and military vehicles. Rogue +5% except Computer Hacking. Technical +5% except all Computer skills. Wilderness +10%. Cowboy, Electrical, Horsemanship (beyond the O.C.C. skills), Mechanical, Military and Pilot Related: none. NOTE: most Wild Psi-Stalkers care nothing about learning to read or higher education. The Communications +5% is stored on that entry and reaches every skill its line lists, Language: Other included (BOOK-INGEST-AUDIT F138, 2026-10-20); the other bonuses on this line are not stored."
    schedule:
      - { level: 5, count: 1 }
      - { level: 10, count: 1 }
  secondary_skills:
    count: 8
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { choose: 1, label: "M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor", "gladiator-body-armor", "ca-1-heavy-dead-boy-armor", "crusader-body-armor"] }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: 2 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "gun-holster", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-spear", qty: 1 }
  - { item_id: "bone-knife", qty: 1 }
  - { item_id: "riding-horse", qty: 1 }
  - { item_id: "weapons-matching-w-p-skills", qty: 1 }
restrictions:
  - "Weapons: one weapon for each W.P., plus 1D4+1 clips and a couple of knives and/or Vibro-Blades (RUE p.156)."
  - "Wild Psi-Stalkers get +5 on Perception Rolls rather than the Civilized Stalker''s +4 - the one mechanical difference between the two."
  - "Fifty percent are cannibals who eat part of their victims; the act is a manifestation of the predatory killing instinct rather than a need for flesh."
extraction_notes: |
  - RUE p.155-156. Special abilities and bonuses are the Civilized
    Psi-Stalker''s, except Perception is +5 rather than +4.
  - The occupation half since 2026-09-27 (BOOK-INGEST-AUDIT F110, taken 2026-09-27): the racial
    package moved to the mutant-psi-stalker R.C.C., the only race this class
    takes. The book prints P.S. and P.P. at 3D6+2 where the race rolls 3D6,
    so the +2 is this occupation''s attribute bonus.
  - Published as its own class rather than a variant of the Civilized
    Psi-Stalker: the two differ in skills, attribute dice and equipment, and
    a variant may not restructure a skill list.
  - Money: no credits at all, 4D6x1000 in sellable Black Market items;
    starting_money is 0 because the character genuinely starts with no coin.
  - Starts with a good quality horse or other riding mount (has an affinity
    with all non-predatory animals), or a non-military vehicle or souped-up
    hovercycle - the mount is modeled, the vehicle alternatives are prose.
---

## Lore

Wild Psi-Stalkers are the nomadic tribal people of the wilderness. When civilization crashed after the Great Cataclysm, the ancestors of the Psi-Stalkers fell to barbarism; over the centuries they''ve advanced, but remain very much like Native American Indian tribes of the past, only a bit more wild and savage. Fifty percent are cannibals who eat part of their victims or tear them to shreds - a manifestation of the predatory killing instinct, since Psi-Stalkers have minimal need for flesh and blood nourishment.

With rare exceptions they never hunt or kill a fellow Psi-Stalker, but they do engage in friendly and not so friendly competitions, feuds and vendettas with rival tribes and clans. Most Wild Psi-Stalkers consider their Coalition counterparts to be weaklings and sissies, even cowards, and love to chide and insult CS Stalkers whenever they encounter them - part jealousy, because the CS Stalkers have an easier life and fun toys like environmental body armor, Vibro-Blades and guns without having to steal or barter for them.

The typical Wild Psi-Stalker is cunning, sneaky, selfish and silent; often a solitary hunter who uses his powers and fighting abilities rather than skills and machines. The clans in the Pecos Empire are among the most savage and murderous on the continent. Psi-Stalkers are least common in the American Southwest, but their numbers increase dramatically in the Northwest and throughout the Magic Zone; total numbers could be as high as 2-6 million scattered across the US and Canada.

## GM Notes

Wild Psi-Stalkers frequently join bandits and adventurer groups, especially if the group is predominantly human. They are also fascinated with Cyber-Knights and often join or assist them on their crusades, although most Wild Stalkers are too undisciplined to become one.

Encounters between Wild and Civilized Psi-Stalkers almost always result in contests of one-upmanship, threats, steely-eyed stares, brawls, firefights and even bloodshed.
',
       updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker'
   AND instr(markdown, '"Sign Language", "Radio: Basic"] }') > 0
   AND length(markdown) = 8102;

-- == body-fixer ==
UPDATE imported_classes
   SET markdown = '---
id: body-fixer
men_of_arms: false
occ_group: optional
name: Body Fixer
system: rifts
source_book: Rifts Ultimate Edition p.86-88
category: occ
tags: [healer]
xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]
attribute_requirements:
  IQ: 10
bonuses:
  attributes: { MA: 1, PS: 1, PP: 1, PE: 1 }
  saves: { toxins_poisons: 2, harmful_drugs: 2, disease: 3, insanity: 3, horror_factor: 2 }
  combat: { dodge: 1, disarm: 1, perception: 2 }
  pools: { sdc: "1d6+4" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%, the figure its own O.C.C. block prints (RUE p.87) rather than the catalog''s generic 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: Other, two of choice (+20%). Taken once per language - the picker asks which." }
    - { name: "Literacy: Native Language", base: 70, per_level: 5, note: "+30%, typically American." }
    - { choose: 1, from: ["Athletics (general)", "Body Building & Weight Lifting"], base: 0, per_level: 0 }
    - { name: "Mathematics: Basic", base: 60, per_level: 5 }
    - { name: "Biology", base: 60, per_level: 5 }
    - { name: "Brewing: Medicinal", base: 45, per_level: 5 }
    - { name: "Chemistry", base: 50, per_level: 5 }
    - { name: "Lore: D-Bee", base: 50, per_level: 5 }
    - { name: "Medical Doctor", base: 80, per_level: 5 }
    - { name: "Outdoorsmanship", base: 0, per_level: 0 }
    - { name: "Pathology", base: 70, per_level: 5 }
    - { choose: 1, categories: ["Pilot"], bonus: 10 }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "+20% on medical, only +5% on all others." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "Special bonus of +1 to strike." }
    - { name: "Xenology", base: 50, per_level: 5 }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "None to start, but can be selected as an O.C.C. Related Skill: Hand to Hand: Basic counts as one skill selection, or Expert as two." }
  occ_related_skills:
    count: 8
    categories:
      - Communications
      - { name: "Communications", only: ["Barter", "Language: Dolphin/Whale", "Public Speaking", "Radio: Basic"], only_prefix: ["Literacy:"], bonus: 5, note: "The +5% on the printed list (printed 87), on the rows the catalog files here." }
      - Domestic
      - Electrical
      - Espionage
      - Horsemanship
      - Mechanical
      - Medical
      - Physical
      - Pilot
      - "Pilot Related"
      - Rogue
      - Science
      - Technical
      - { name: "Technical", only: ["Creative Writing", "Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 5, note: "Communications'' +5% (printed 87), on the Creative Writing, Language and Literacy rows the catalog files here." }
      - "Weapon Proficiencies"
      - Wilderness
    note: "Select three additional skills from the Medical category, and select 8 other skills (may include more from the Medical category) at level one, plus two additional skills at levels 3, 6, 9, and 12. All new skills start at level one proficiency. Communications: Barter, Creative Writing, Language, Literacy, Public Speaking, and Radio: Basic only (+5%). Domestic: Any (+10%). Electrical: Basic only (+5%). Espionage: Wilderness Survival only (+10%). Horsemanship: General only. Mechanical: Basic Mechanics and Automotive only. Medical: Any (+15%). Physical: Any, excluding Acrobatics, Boxing and Wrestling. Pilot: Any (+5%). Rogue: Streetwise only (+4%). Science: Any (+10%). Technical: Any (+10%). W.P.: Any, except Heavy Military Weapons and Heavy Energy Weapons. Wilderness: +5% but the bonus counts only for country/adventuring Body Fixers, not city-docs. The Communications +5% is stored, on every skill its line lists, as a scoped Communications entry and a scoped Technical entry for the rows the catalog files under Technical (BOOK-INGEST-AUDIT F138, 2026-10-20); Communications itself stays Any, and the other bonuses on this line are not stored."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 6
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
starting_money: "5d6x1000"
equipment_starting:
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "surgical-gown", qty: 2 }
  - { item_id: "disposable-surgical-gloves", qty: 12 }
  - { item_id: "reusable-surgical-gloves", qty: 1 }
  - { item_id: "surgical-kit", qty: 1 }
  - { item_id: "medical-kit", qty: 1 }
  - { item_id: "irmss-internal-robot-medical-surgeon-system", qty: 1, label: "IRMSS/Internal Robot Micro-Surgeon System" }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1, label: "RMK/Robot Medical Kit" }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "hand-held-blood-pressure-machine", qty: 1, label: "computerized" }
  - { item_id: "thermometer", qty: 1 }
  - { item_id: "unbreakable-vial", qty: 6 }
  - { item_id: "compu-drug-dispenser", qty: 1, label: "portable compu-drug dispenser" }
  - { item_id: "portable-laboratory", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "medical-bag", qty: 1, label: "medical bag or satchel" }
  - { item_id: "e-clip", qty: 2, label: "one weapon for each W.P. and two E-Clips for each" }
  - { item_id: "vibro-knife", qty: 1, label: "1D6 M.D." }
  - { item_id: "scalpel", qty: 2, label: "1D4 S.D.C. damage" }
  - { item_id: "wilk-s-laser-scalpel", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pen-flashlight", qty: 1 }
  - { choose: 1, label: "commercial vehicle (as per Pilot skill) or a horse (if he can ride)", qty: 1, from: ["hovercycle", "jeep", "riding-horse"], note: "The book names no specific vehicle; this is the catalog set, widened as more books are imported." }
  - { choose: 1, label: "hat with a brim", qty: 1, from: ["hat-short-brim", "hat-large-brim"] }
  - { choose: 1, label: "hooded cape or poncho", qty: 1, from: ["cape-long-hooded", "poncho"] }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "sunglasses", qty: 1, label: "a pair of sunglasses" }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "note-pad", qty: 1, label: "pocket note pad" }
  - { item_id: "pen", qty: 2 }
special_abilities:
  - name: "Familiarity with D-Bees"
    description: "No skill penalty when working on common/known D-Bees; only a -20% penalty when dealing with extremely alien physiology, rare or previously unknown D-Bees. The Body Fixer is -20% whenever working on bionic modifications, and -30% when working on alien cybernetics, -50% on alien bionics."
  - name: "Disease Diagnostic Specialist"
    description: "Diagnose disease with extreme clarity and accuracy. Skill Bonuses: +20% to that percentile number of the Medical Doctor skill, and +10% to Brewing and Holistic Medicine skills to whip up a cure. He is so good that he can reduce the symptoms (i.e., the penalties and duration) by half. Can also recognize possession and magical illnesses and curses."
  - name: "O.C.C. Bonuses"
    description: "+1D6+4 to S.D.C., +1 to M.A., P.S., P.P., and P.E. attributes, +1 to dodge and disarm, +2 to save vs poison and drugs, +3 to save vs disease and insanity, +2 to save vs Horror Factor, +2 on most Perception Rolls, but +4 when the Perception Roll involves making an observation about a medical condition, diagnosis/health or medical procedure, as well as when dealing with drugs/chemicals, and poison."
restrictions:
  - "No Racial Requirement; half of all Body Fixers are D-Bees themselves."
extraction_notes: |
  - Alignment is recorded as prose rather than as a key. The book says
    "Any, but tends to be Principled, Scrupulous, Unprincipled or Aberrant." - a tendency, not a
    restriction, and the app has no alignment-restriction mechanic to
    enforce one against.
  - The "O.C.C. Bonuses" perception line is split: the flat +2 on most
    Perception Rolls is modeled as combat.perception (class audit F8); the +4
    for medical/drug/poison-related Perception Rolls is conditional and stays
    prose, per the rule that conditional bonuses are prose.
  - Standard Equipment list is cut off at the bottom of page 87 ("...surgical
    kit (includes scalpels, clamps, sutures, needles, etc.), medical kit
    (first-aid kit, bandages, antiseptics,") ' || char(8212) || ' the remainder of the equipment
    list and the Money section were read from the following page of the scan
    (cache file p091) and folded in by fix-body-fixer-page-break.sql; the
    book prints no Cybernetics section for this class. Money is conditional -
    a city/Burbs doctor starts with 5D6x1000 credits, while a wandering Body
    Fixer has 1D6x1000 credits plus 3D6x1000 in Black Market saleable items -
    starting_money holds the city figure, and the goods are not coin. The
    page closes the list with "and other basic items" and "some personal
    items", which are prose, not gear.
  - Outdoorsmanship is printed once, between Medical Doctor and Pathology.
    The original import carried a second copy, which made every Body Fixer
    fail duplicate_skill on save; removed by
    fix-body-fixer-single-outdoorsmanship.sql.
  - Hand to Hand Combat note: starts with none, but may be taken as an O.C.C.
    Related Skill (Basic = 1 selection, Expert = 2 selections) ' || char(8212) || ' recorded as
    an occ_skills entry with note since it doesn''t cleanly fit the related-skill
    schema shape.
---

## Lore

Alignment: Any, but tends to be Principled, Scrupulous, Unprincipled or Aberrant.

"I''m a healer. I fix people. I don''t judge them or decide who should live and die based on their genetic makeup. That''s for God... or maybe Emperor Prosek and his goon squads. If that makes me a criminal, so be it."

Saying that a Body Fixer is just a doctor does a disservice to these brave men and women of this noble profession, and only tells part of their story. "Body Fixer" is the slang term for a medical doctor (M.D.) in North America who performs medicine on anybody ' || char(8212) || ' human and nonhuman. That distinction makes the Body Fixers criminals, rogues and dissidents in the eyes of the Coalition States. Anybody caught "harboring, aiding and abetting a criminal of the State" ' || char(8212) || ' a distinction given to all D-Bees for not having been born human ' || char(8212) || ' is punishable by death! And that includes providing them with medical aid. Better to let a D-Bee die in the gutter than give "it" comfort or aid.

Body Fixers are doctors who cannot turn their backs on the sick and injured based on their race. A choice that has branded them as "traitors to humanity" by the CS.

Conservative estimates suggest the D-Bee population among sentient (intelligent) life forms in North America is 34%. Less conservative numbers place the number at closer to 42%. Most Rogue Scholars and Scientists believe a more accurate number is probably 50-55%. Perhaps all the more reason for human supremacists like the leaders of the Coalition States to want D-Bees dead. Even in the Chi-Town ''Burbs, being caught by CS Police, soldiers and undercover agents is death for D-Bees, they make up an estimated 16% to 22% of the population! In the New West, D-Bees make up at least 60% to 80% of the population, and in the east and north into Canada that number is probably 40%-50%, possibly higher, and that does not include Psi-Stalkers, whom the CS considers to be mutant humans.

It is difficult to determine exact numbers because most D-Bees live in poverty or low-tech communities in thousands of tiny villages, towns and tribes. Gathering in a large community, especially within view of the CS, is to invite a Coalition extermination squad to come knocking. Likewise, because humans are the dominant power in North America and D-Bees second class citizens at most places that accept them, predominantly D-Bee communities are raided and attacked with impunity by other D-Bees and human mercs, raiders, bandits and adventurers. D-Bees only have rights if they have the firepower to fight back, which many do not. And because the Coalition States have been so tenacious at breaking down and wiping out large gatherings of D-Bees before they can turn into full-fledged cities or kingdoms, most D-Bees have adopted the practice of trying to integrate (and lose) themselves into an established, predominantly human community where the CS is much less likely to attack.

However one cuts the numbers, they are far too many people for a dedicated healer to ignore. Furthermore, because D-Bees are, generally, forced to live in substandard conditions, abused, and refused conventional medical treatment, they need someone like the Body Fixer more than anyone.

As a result, Body Fixers are tough adventurers who often make house calls up to 300 miles (480 km) away from their base of operation. Around half are traveling doctors who follow a regular circuit of towns, farms, homesteads and stops, or hook up with a group of adventurers, helping them and those in need encountered along the way. Consequently, most Body Fixers are rather like super-country doctors and are no strangers to traveling the wilderness. Although Body Fixers are idealistic healers, they aren''t fools. They understand better than most people the dangers of Rifts Earth, and know sometimes one must kill or be killed. Less than 12% are dedicated pacifists who refuse to use a gun or fight back to protect themselves. On the contrary, many Body Fixers will not hesitate to use a weapon and threats to protect themselves and/or their patients. Considering the prejudice leveled at their nonhuman clients, Body Fixers are by nature rather stubborn, tenacious and militant, risking their lives every day for what they believe in.

Why do it? Why especially risk the retribution of the Coalition? Because Body Fixers are compassionate people who don''t see much of a choice. Walk away and let someone they can save die, or do what they believe is right and save that life. Besides, half of all Body Fixers are D-Bees themselves devoted to helping all people. Personal profit and power mean nothing to a dedicated Body Fixer. Most of them will offer their expert services to anybody who needs them for a hot meal, a dry place to sleep, and whatever seems like a fair and reasonable trade, all things considered. This has earned them the reputation for being kind and compassionate humanitarians and champions of the downtrodden. Some are practically living folk heroes.

Of course, not all Body Fixers are the soul of compassion. Some are quacks and brigands who charge an arm and a leg (sometimes, quite literally) for their services, and gouge those in need, especially D-Bees and fugitives wanted by the authorities. Burn outs, hacks and greedy, cold-hearted Fixers seem to be the embodiment of those employed at most Black Market Body-Chop-Shops. Some are downright evil. These callous and insensitive doctors are in it for the money. Only 1 in 10 Fixers at a Chop-Shop seem to genuinely care about their patients. If the money''s right, they''ll work on anybody. No questions asked.

Perhaps because they know and cherish the pure physical body so much, many Body Fixers refuse to use cybernetics on themselves, unless it is a lifesaving organ or prosthetic. They may also try to dissuade their patients from getting augmentation of any kind. On the other hand, about a third will get a handful of cybernetic enhancements, mainly optics and sensors. However, a solid 10% will get plenty of them, although again, limited mainly to optics, sensors and things that help them to be better doctors.

## GM Notes

Body Fixers make excellent additions to adventuring parties needing dedicated medical support, but their compassion and stubbornness about treating D-Bees can drag the whole group into direct conflict with the Coalition States ' || char(8212) || ' harboring or aiding a D-Bee is a capital offense in CS territory. GMs should use this tension as a strong roleplaying hook: will the party protect their medic''s principles, or pressure them to look the other way? The wide gulf in quality between idealistic field doctors and mercenary Black Market Chop-Shop hacks (only 1 in 10 of whom truly care about patients) offers a useful spectrum of NPC Body Fixers, from folk-hero healers to morally bankrupt profiteers.',
       updated_at = datetime('now')
 WHERE class_id = 'body-fixer'
   AND instr(markdown, 'not city-docs."') > 0
   AND length(markdown) = 15740;

-- == bruutasaur ==
UPDATE imported_classes
   SET markdown = '---
id: bruutasaur
name: Bruutasaur
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.37-40
category: rcc
tags: [combat, hunter, wilderness]
attribute_dice:
  IQ: "1d6+5"
  ME: "4d6"
  MA: "2d6"
  PS: "4d6+6"
  PP: "4d6"
  PE: "3d6+10"
  PB: "2d4+4"
  Spd: "3d6+18"
mdc_base: "P.E. + 2d6x10, +10 per level"
ppe_base: "3d6"
horror_factor: 13
starting_money: "1d6x1000"
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
bonuses:
  combat: { attacks: 2, initiative: 1, strike: 2, parry: 1, dodge: 1, disarm: 1, pull_punch: 3, roll: 2 }
  saves: { horror_factor: 3, other: [ { label: "vs the charm and control of vampires", bonus: 6 } ] }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, commando: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 92, per_level: 0, note: "Adopted native tongue: Spanish at 92%." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "American (+10%)." }
    - { name: "Appraise Goods", base: 45, per_level: 5, note: "+15%." }
    - { name: "Barter", base: 42, per_level: 4, note: "+12%." }
    - { name: "Climbing", base: 70, per_level: 5, note: "+30%." }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%." }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%." }
    - { name: "Spelunking", base: 55, per_level: 5, note: "+20%." }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%." }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Track (people), +10%." }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "+20%." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%." }
    - { choose: 3, from: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Whip"], note: "W.P. Ancient: three of choice." }
    - { choose: 4, from: ["W.P. Handguns", "W.P. Rifles", "W.P. Shotgun", "W.P. Submachine-Gun", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Heavy M.D. Weapons", "W.P. Heavy Military Weapons"], note: "W.P. Modern: four of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert at the cost of one R.C.C. Related Skill, or to Martial Arts or Commando for the cost of two skills." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", only: ["Radio: Basic"], bonus: 5 }
      - { name: "Communications", only: ["Literacy: Native Language", "Literacy: Other"], bonus: -10, note: "Literacy at -10% (printed 39)." }
      - { name: "Technical", only: ["Language: Other"], bonus: 5 }
      - { name: "Cowboy", bonus: 5 }
      - "Domestic"
      - { name: "Physical", except: ["Acrobatics", "Prowl"], bonus: 5 }
      - { name: "Pilot", only: ["Automobile", "Bicycling", "Boat: Paddle Types/Canoe/Kayak", "Boat: Motor, Race & Hydrofoil", "Boat: Sail Type", "Hover Craft (ground)", "Hovercycles, Skycycles & Rocket Bikes", "Motorcycles & Snowmobiles", "Truck", "Water Scooters"], bonus: 5 }
      - { name: "Rogue", except: ["Computer Hacking", "Safe-Cracking"], bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: "1d4" }
  - { item_id: "ammo-belt", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d4+4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "large-wood-cross", qty: 1 }
  - { item_id: "e-clip", qty: "1d4+4" }
natural_abilities:
  - name: "Mega-Damage Hide"
    description: "A Mega-Damage being: 2D6x10 M.D.C. plus the P.E. attribute number to start, +10 M.D.C. per level of experience. Wears no armor by habit, but may, and custom armor is made to its size."
  - name: "Robotic Strength"
    description: "P.S. is equivalent to Robot P.S. Punches, kicks and tail strikes do damage as per Robot P.S. A restrained claw strike does 6D6 S.D.C., a full strength claw strike 4D6 M.D., a power claw strike 6D6+10 M.D. (counts as two melee attacks). A nipping bite does 2D6 S.D.C., a full strength bite 2D4 M.D."
  - name: "Hunter''s Senses"
    description: "Natural hunters, very alert, with quick reflexes. Sense of smell three times sharper than a human''s. Nightvision 500 feet (152 m). An eye filter drops over the eye as a polarizing film, and a clear covering protects the eyes from sand, grit and airborne particles."
  - name: "Runner and Leaper"
    description: "Can run for six hours before beginning to tire, and run twice as fast in short bursts lasting 1D4 minutes to catch prey. Can leap 10 feet (3 m) plus one foot (0.3 m) per P.S. point."
  - name: "Regeneration and Iron Stomach"
    description: "Heals twice as fast as normal and regenerates a lost finger, hand or tail in 2D4+8 weeks. Can eat raw meat, carrion, blood, bones and spoiled meat without ill effect."
  - name: "Impervious to Vampire Bite"
    description: "Impervious to the bite of a vampire; +6 to save vs vampire charm and control."
special_abilities:
  - name: "Pinning Leap Attack"
    description: "Impact inflicts 2D6 M.D. and counts as three attacks, with a 01-68% chance of knocking an opponent smaller than 20 feet (6.1 m) off his feet; the victim loses initiative and two melee attacks. If knocked down there is a 01-35% chance the victim is pinned and unable to attack or move; the Bruutasaur may bite the pinned prey or simply hold it down. Roll each melee round to see if the victim is still pinned. On releasing a pin, the Bruutasaur automatically has initiative and the first strike."
  - name: "Prehensile Tail"
    description: "A tail of 1D6+9 feet (3 to 4.6 m), as strong as the Robot P.S., used for balance, climbing and combat: to swat, trip and knock down opponents, curl around, grab and hold, or grab and throw a man-sized opponent, and to scale cliffs, buttes and ruins. Cannot hold, use or fire weapons. A tail strike does Robot P.S. damage, and the tail gets half the character''s usual strike bonuses even against a target behind or beside the Bruutasaur."
trackable_resources: []
restrictions:
  - "Alignment: any, but most are Anarchist (30%), Miscreant (30%) or Aberrant (20%)."
  - "Psionics: none, though a high M.E. makes them resistant to psionic attack."
  - "Magic: none. Never study magic, but appreciate magic weapons and Techno-Wizard devices."
side_effects: "Cold: in weather of 45 degrees Fahrenheit or lower a Bruutasaur loses one attack and its initiative bonus. In extreme cold, or exposed to cold for more than 36 hours, its attacks per melee, all bonuses, Spd and skills are halved, and below freezing it suffers 2D6 M.D. every 12 hours even bundled in furs. Cold attacks, magical or otherwise, do normal damage. Lacks a civilized mind: its reptilian brain is geared for hunting and fighting, and it lacks the patience and skills to behave civilized or learn complex skills. Evil reputation: its size, looks and reputation as a man-eater (a myth the CS perpetuates) leave most people terrified of it and make it a target of prejudice."
extraction_notes: "WB30 D-Bees of North America printed 37-40 (cache p038-p041), numbers read off 200 dpi renders. A reprint; the book notes it originally appeared in Rifts World Book One: Vampire Kingdoms, which is not imported, so it is imported from here. The brief listed 37-39; Money and the end of Standard Equipment are on printed 40, so source_book cites 37-40. Tag line: Bruutasaur - Optional Player Character or NPC. || CATEGORY: a full R.C.C. with its own skills, related and secondary skills; it states mdc_base, so no men_of_arms line. || XP TABLE: the entry says Use the same Experience Table as Psi-Stalkers. Stored as a copy of the psi-stalker class''s stored xp_table, read from production 2026-10-03, by the class-import reference rule (a class whose book names another class''s table copies that ladder). The shared brief for this book said no xp_table, on the premise that entries name the O.C.C.''s table; this one names a class, so the copy was taken. || ATTRIBUTES: P.S. 4D6+6 is Robotic; Spd 3D6+18, twice as fast in bursts of 1D4 minutes (ability text). || POOLS: M.D.C. 2D6x10 plus P.E. attribute number to start, plus 10 M.D.C. per level. Horror Factor 13. P.P.E. 3D6. No Hit Points or S.D.C. are printed. || SKILLS: printed base plus bonus over the catalog base: Language Other 50+10=60, Appraise Goods 30+15=45, Barter 30+12=42, Climbing 40+30=70, Land Navigation 36+20=56, Recognize Weapon Quality 25+20=45, Spelunking 35+20=55, Swimming 50+10=60, Tracking (people) 25+10=35, Track & Trap Animals 20+20=40, Wilderness Survival 30+20=50. Hunting has no percentage. Adopted Native Tongue Spanish 92% is Language: Native Tongue base 92. W.P. Ancient (3) and W.P. Modern (4) are from-lists of the catalog''s ancient and modern W.P. rows. Hand to Hand Basic; Expert costs one R.C.C. Related Skill, Martial Arts or Commando two; stored in hand_to_hand. || RELATED: five at level one plus one at levels 2, 4, 8, 10, 12 and 14. Communications is Language and Radio: Basic only at +5% and Literacy at -10%; the catalog files Language: Other under Technical, so Technical is granted with only Language: Other, and the Literacy penalty is a second Communications entry at -10 on the two Literacy rows (BOOK-INGEST-AUDIT F138, 2026-10-20). Rogue excludes Computer Hacking, Prowl and Safe-Cracking; the catalog files Prowl under Physical, so Prowl is excluded there beside Acrobatics. Pilot is basic vehicles only, including Hovercycle; the from-list of basic vehicles is a judgement. Science is Math: Basic only (catalog Mathematics: Basic). || SECONDARY: two at levels 1, 4, 8 and 12. || BONUSES: +2 attacks per melee, +1 initiative, +2 strike, +1 parry and dodge, +1 disarm, +3 pull punch, +2 roll with impact, +3 save vs Horror Factor, +6 save vs vampire charm and control (saves.other); impervious to vampire bite is ability text. || EQUIPMENT: backpack, 1D4 large sacks, ammo belt, two canteens or water skins, air filter, a week of food rations, 1D4+4 wooden stakes, a wooden mallet, a hand-held wooden cross (two feet for them, large-wood-cross), 1D4+4 E-Clips or ammo cartridges, a few personal items. The 72 silver bullets if an S.D.C. gun is one of the W.P.s are conditional and not stored; the backpack and/or large satchel is stored as backpack. Starts with no Techno-Wizard device or magic weapon. Armor examples (patchwork 5D6+55 M.D.C., medium full-body 1D4x10+80, heavy 1D6x10+140) are prose, not gear. || MONEY: 1D6x1,000 credits stored; an additional 2D4x1,000 credits of tradeable goods is not money and is not stored. || NOT STORED: size 10-12 ft, weight 850-1200 lbs, life span 2D6+40 years, NPC experience level 1D10, habitat, slave market value 2D4x10,000 credits, allies and enemies (a century-long feud with the Simvan; hunters of vampires)."
---

## Lore

Bruutasaurs are huge, cold-blooded reptilian humanoids around eleven
feet tall: tan scales with green accents, massive limbs, machete-sized
claws, a long prehensile tail, and a head that suggests a raptor or an
allosaurus by way of a horned toad. A Dark Age Shifter brought an army of
them from their Stone Age world to conquer an empire for him, and they
worshipped him as a god until he was killed. The survivors scattered
across North America, and most living today are Earth-born descendants
with no wish to go back.

They are nomads who travel in tribal packs of a few dozen to over a
hundred, working as hunters, raiders, bandits and mercenaries; females
are as aggressive as males. Their reputation as man-eaters dates from
their early days and has been untrue for at least sixty years, but the
Coalition keeps it alive. A tribe accepts anyone who pulls his weight,
human, D-Bee or sub-demon. They are a major force among the Pecos
Raiders, where a Bruutasaur named Charmo Rex leads thousands, and they
are the most active vampire hunters in northern Mexico and the
Southwest. They respect the Coalition as warriors but have feuded with
the Simvan for more than a century.
',
       updated_at = datetime('now')
 WHERE class_id = 'bruutasaur'
   AND instr(markdown, 'Literacy penalty is a restriction line because one category carries one bonus') > 0
   AND length(markdown) = 12683;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 7 classes carry their new text' AS assertion, count(*) AS got, 7 AS want
  FROM imported_classes
 WHERE (class_id = 'faerie-bot' AND instr(markdown, '- { name: "Technical", only_prefix: ["Lore:"], bonus: 10 }') > 0)
    OR (class_id = 'glitter-boy' AND instr(markdown, '- { name: "Technical", only_prefix: ["Lore:"], bonus: 5 }') > 0)
    OR (class_id = 'shifter' AND instr(markdown, '- { name: "Technical", only_prefix: ["Language:"], bonus: 10, note: ') > 0)
    OR (class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Technical", only_prefix: ["Lore:"], bonus: 15, note: ') > 0)
    OR (class_id = 'wild-psi-stalker' AND instr(markdown, '"Sign Language", "Radio: Basic"], bonus: 5 }') > 0)
    OR (class_id = 'body-fixer' AND instr(markdown, '- { name: "Technical", only: ["Creative Writing", "Literacy"], only_prefix: ["Language:", "Literacy:"], bonus: 5, note: ') > 0)
    OR (class_id = 'bruutasaur' AND instr(markdown, 'only: ["Literacy: Native Language", "Literacy: Other"], bonus: -10') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'faerie-bot' AND instr(markdown, 'which is a note and a restriction line, not a category bonus.') > 0)
    OR (class_id = 'glitter-boy' AND instr(markdown, 'the rest stay prose because they differ per skill and a category carries one number') > 0)
    OR (class_id = 'shifter' AND instr(markdown, 'Cowboy, Mechanical and Military: none."') > 0)
    OR (class_id = 'wilderness-scout' AND instr(markdown, 'Wilderness: Any (+20%)."') > 0)
    OR (class_id = 'wild-psi-stalker' AND instr(markdown, '"Sign Language", "Radio: Basic"] }') > 0)
    OR (class_id = 'body-fixer' AND instr(markdown, 'not city-docs."') > 0)
    OR (class_id = 'bruutasaur' AND instr(markdown, 'Literacy penalty is a restriction line because one category carries one bonus') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('faerie-bot', 'glitter-boy', 'shifter', 'wilderness-scout', 'wild-psi-stalker', 'body-fixer', 'bruutasaur') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~242-book-ingest-audit-f138-sweep-b.sql');
