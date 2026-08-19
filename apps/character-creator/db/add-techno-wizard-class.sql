-- The Techno-Wizard O.C.C., Rifts Ultimate Edition p.126-129.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-techno-wizard-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hand-held-computer', 'Hand Held Computer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('large-flashlight', 'Large Flashlight', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('magnifying-glass', 'Magnifying Glass', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('mini-tool-kit', 'Mini Tool Kit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('multi-optics-band', 'Multi Optics Band', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pilot-jumpsuit', 'Pilot Jumpsuit', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-digital-disc-recorder', 'Pocket Digital Disc Recorder', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-flashlight', 'Pocket Flashlight', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-laser-distancer', 'Pocket Laser Distancer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-mirror', 'Pocket Mirror', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('small-silver-cross', 'Small Silver Cross', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('swiss-army-knife', 'Swiss Army Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('tw-converted-energy-pistol', 'Tw Converted Energy Pistol', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('tw-converted-energy-rifle', 'Tw Converted Energy Rifle', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('tw-tree-trimmer', 'Tw Tree Trimmer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('tw-wing-board', 'Tw Wing Board', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('work-overalls', 'Work Overalls', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'techno-wizard', 'Techno-Wizard', 'rifts', '---
id: techno-wizard
name: Techno-Wizard
system: rifts
source_book: Rifts Ultimate Edition p.126-129
category: occ
attribute_requirements: { IQ: 12, ME: 12 }
ppe_base: "3d4x10, +2d6 per additional level starting at level two"
starting_money: "1d6x100"
psionics:
  type: "minor"
  isp_base: "4d6"
  powers: ["Machine Ghost", "Mind Block", "Object Read (Psychometry)", "Speed Reading", "Telemechanics", "Total Recall"]
magic:
  type: "spell"
  spells: ["Armor of Ithan", "Blinding Flash", "Breathe Without Air", "Call Lightning", "Cloak of Darkness", "Deflect", "Electric Arc", "Energy Bolt", "Energy Field", "Fire Ball", "Fire Bolt", "Fuel Flame", "Fly", "Forcebonds", "Globe of Daylight", "Ignite Fire", "Impervious to Energy", "Impervious to Fire", "Magic Net", "Magic Shield", "See the Invisible", "Sense Magic", "Shadow Meld", "Superhuman Strength", "Telekinesis"]
bonuses:
  saves: { horror_factor: 2, possession: 2, mind_control: 2 }
  at_level:
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 7, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 10, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 13, saves: { spell_magic: 1, ritual_magic: 1 } }
skills:
  occ_skills:
    - { name: "Literacy: Native Language", base: 50, per_level: 5, note: "+10%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 98%." }
    - { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Computer Operation", base: 45, per_level: 5, note: "+5%" }
    - { name: "Computer Programming", base: 35, per_level: 5, note: "+5%" }
    - { name: "Computer Repair", base: 40, per_level: 5, note: "+10%" }
    - { name: "Basic Electronics", base: 45, per_level: 5, note: "+15%" }
    - { name: "Mechanical Engineer", base: 45, per_level: 5, note: "+20%" }
    - { name: "Techno-Wizardry Construction", base: 70, per_level: 2, note: "Special Techno-Wizard skill: in-depth knowledge of combining magic with machines to construct TW devices, and to analyze or duplicate another mage''s TW device. Truly alien machines and magic devices incur a -40% penalty to analyze, repair or rebuild. Base 70% +2% per level (the +10% O.C.C. bonus is folded in)." }
    - { name: "Read Sensory Equipment", base: 40, per_level: 5, note: "Sensory Equipment (+10%)." }
    - { name: "Basic Math", base: 65, per_level: 5, note: "Math: Basic (+20%)." }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 2, categories: ["Pilot"], bonus: 5, note: "Pilot: two of choice (+5%)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Knife or Sword (pick one)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Pistol or Energy Rifle (pick one)." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - "Mechanical"
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics", "Boxing", "Wrestling"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "TWO of the seven must be Electrical or Mechanical skills. Communications +5% (+10% radio and sensor based). Electrical +10%. Mechanical +10%. Pilot +5%. Pilot Related +5%. Rogue +5% to Computer Hacking only. Science +10%. Technical +10%. Cowboy and Espionage: none. Hand to Hand combat is taken HERE, not automatically: Basic costs one selection, Expert two, Martial Arts three, Assassin (if evil) four."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 5
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "work-overalls", qty: 1 }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "pilot-jumpsuit", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "multi-optics-band", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "signal-flare", qty: 6 }
  - { item_id: "mini-tool-kit", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "wooden-stake-and-mallet", qty: 6 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "swiss-army-knife", qty: 1 }
  - { item_id: "tw-converted-energy-rifle", qty: 1 }
  - { item_id: "tw-converted-energy-pistol", qty: 1 }
  - { item_id: "e-clip", qty: "1d4" }
  - { choose: 1, label: "TW vehicle", qty: 1, from: ["tw-wing-board", "tw-tree-trimmer"] }
natural_abilities:
  - name: "Spell Casting Through Devices"
    description: "The Techno-Wizard casts spells through an appropriate mechanical device as his delivery system - a pistol to fire a Fire Bolt, binoculars or goggles to See the Invisible. Using technology as the spell focus does not harm the object; only full Techno-Wizardry conversion permanently adds magic to a device. He cannot fire the device''s normal function and a spell at the same time. Spell Casting Penalty: casting through traditional words and gestures alone HALVES all spell ranges, durations, M.D.C./S.D.C. and damage."
  - name: "Learning New Spells"
    description: "Primarily interested in energy spells needed to create and power mystic devices, then physical-manipulation spells (Invisibility: Simple, Invincible Armor, Teleport: Lesser, Mystic Portal). Additional spells and rituals of any level can be learned or purchased at any time regardless of experience level. Never acquires summoning or circle magic."
  - name: "Psionics of the Techno-Wizard"
    description: "Minor psychic (needs 12+ to save vs psionics): Machine Ghost (12), Mind Block (4), Object Read (6), Speed Reading (2), Telemechanics (10) and Total Recall (2). I.S.P.: 4D6 plus M.E., +1D4+1 per level."
  - name: "Ley Line Piloting"
    description: "Intuitively pilots any TW vehicle designed to travel along ley lines, even with no piloting skill: 74% +2% per level. Other mages and psychics need the appropriate piloting skill to operate a TW vehicle at all; Wing Boards are the exception - anybody can fly one with practice (74% +2%), and only the Ley Line Walker gets a +10% bonus."
  - name: "P.P.E. and Recovery"
    description: "Permanent Base P.P.E.: 3D4x10 in addition to the P.E. attribute; +2D6 per level. Draws from ley lines, nexus points and other people whenever available. Recovery: 4 per hour of rest; meditation restores 8 per hour and counts as one hour of sleep."
restrictions:
  - "O.C.C. bonuses beyond the modeled saves: +1 to Spell Strength at levels 4, 8 and 12; +3 on Perception Rolls involving magic, machines, or their combination."
  - "Cybernetics: starts with none and avoids them except for medical reasons - they interfere with magic."
extraction_notes: |
  - RUE p.126-129, by Kevin Siembieda & Carmen Bellaire. Alignment any; only
    about 20% are D-Bees. The Techno-Wizardry Construction Rules section that
    follows the class (p.129+) is deliberately NOT part of this entry.
  - The 24 named starting spells land via magic.spells; Invisibility: Superior
    and others can be used to create devices but are not starting knowledge.
  - Techno-Wizardry Construction is a TW-only skill entered with its own
    numbers (70% +2%), the Find Contraband precedent. Lore of building TW
    devices lives in the book''s construction rules, out of scope here.
  - Hand to Hand is bought as a Related Skill (Basic 1, Expert 2, Martial
    Arts 3, Assassin 4) - the related-block note carries it.
  - Related skills: two of the seven must be Electrical or Mechanical - a
    composition constraint the count field cannot express; noted.
  - Psionics: six fixed powers; psionics.powers carries them (Total Recall
    noted - the book lists six).
  - Equipment: the TW-converted energy rifle and pistol carry one magic
    feature each; the starting TW vehicle is a Wing Board or Tree Trimmer,
    plus one magic-converted ground vehicle of choice (excluding Invisibility
    and Impervious to Energy) - the conversions are prose. Money: 1D6x100
    credits, 1D6x1000 in Black Market items, 2D4x1000 in quartz crystals and
    gems; everything has been spent on equipment.
---

## Lore

The Techno-Wizard is the most unconventional of the magic O.C.C.s: men of magic who have learned to combine magic with technology. Although the Techno-Wizard can cast spells and read scrolls, the focus of their magic is the creation of magic devices - machines empowered to do strange and magical things that seem to defy known science.

Techno-Wizards have taken the concept of a practitioner of magic being a living battery of Potential Psychic Energy to its logical conclusion: they create devices powered by the individual user''s own energy and directed by the person''s thoughts and willpower. Many devices emulate existing magic and psionic abilities, but anyone with sufficient psychic or magic energy (P.P.E. or I.S.P.) can use them - a fellow mage or psychic can use a Techno-Wizard''s machine, while ordinary people cannot operate the device at all; to a normal person it seems like worthless junk with no apparent power source. The devices are non-polluting, easy to conceal, and do not radiate magic when not empowered - most look like nothing more than a construct of machine parts, gems, wires and chewing gum.

Favorite clothing is Pre-Rifts aviator uniforms, flight jackets, jumpsuits, headgear, goggles and boots - currently considered high fashion among Techno-Wizards. Favorite vehicles tend to be souped-up motorcycles, dune buggies and hover vehicles.

## GM Notes

The Techno-Wizardry Construction Rules (RUE p.129+) govern building new TW devices - base skill, P.P.E. batteries, spell integration - and are deliberately not modeled in this class entry. When a Techno-Wizard character builds devices at the table, work from the book''s construction chapter.

Related O.C.C.s: the Ninja Techno-Wizard is in Rifts World Book 8: Japan; the Rifts Book of Magic collects TW weapons and devices from World Books 1-23 and Sourcebooks 1-4.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'techno-wizard');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'techno-wizard';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('hand-held-computer', 'large-flashlight', 'magnifying-glass', 'mini-tool-kit', 'multi-optics-band', 'pilot-jumpsuit', 'pocket-digital-disc-recorder', 'pocket-flashlight', 'pocket-laser-distancer', 'pocket-mirror', 'small-silver-cross', 'swiss-army-knife', 'tw-converted-energy-pistol', 'tw-converted-energy-rifle', 'tw-tree-trimmer', 'tw-wing-board', 'work-overalls');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-techno-wizard-class.sql');
