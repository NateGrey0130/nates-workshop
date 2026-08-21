-- The Rogue Scientist O.C.C., Rifts Ultimate Edition p.95-96.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-rogue-scientist-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-rogue-scientist-class.sql
--
-- Extracted with the app's own class importer from the Rifts Ultimate Edition
-- PDF and validated with scripts/class-check.mjs before this file was
-- generated. Applied as a script rather than through the import UI because
-- production sits behind Cloudflare Access.
--
-- THE PDF HAS NO TEXT LAYER. All 382 pages are scanned images, so the model
-- read the pages as images rather than parsing text. That is what the importer
-- does anyway - it sends the PDF as a document attachment and never
-- pre-extracts text, because layout-preserving extraction splices neighbouring
-- columns together mid-line on a two-column sourcebook page.
--
-- SKILL BASES AND NAMES ARE POST-PROCESSED, not taken as extracted. The model
-- has the printed bonus ("+15%") but no catalog, so it returns base 0 and
-- strands the bonus in a note; the convention is that a skill's base is the
-- CATALOG base plus the printed bonus, already added. And RUE contradicts
-- itself on names - its class entries print "Basic Math" and "Lore: D-Bees"
-- where its own Skill List prints "Mathematics: Basic" and "Lore: D-Bee" - so
-- names are resolved through catalog_redirects to the canonical row. That
-- matters beyond tidiness: a restriction is matched by raw name, in the
-- browser, where redirects are not available.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'rogue-scientist', 'Rogue Scientist', 'rifts', '---
id: rogue-scientist
name: Rogue Scientist
system: rifts
source_book: Rifts Ultimate Edition p.95-96
category: occ
attribute_requirements:
  IQ: 12
starting_money: "1d6x1000"
bonuses:
  attributes: { IQ: 2 }
  combat: { }
  saves: { insanity: 2, disease: 2 }
  pools: { sdc: "1d6+6" }
skills:
  occ_skills:
    - { name: "Literacy", base: 35, per_level: 0, note: "Literacy in two Languages of choice (+35%)." }
    - { name: "Language: Native Tongue", base: 96, per_level: 0 }
    - { choose: 3, categories: ["Communications"], bonus: 20, note: "Language: Other, three of choice (+20%)." }
    - { name: "Astronomy & Navigation", base: 50, per_level: 5 }
    - { name: "Mathematics: Advanced", base: 45, per_level: 5 }
    - { name: "Mathematics: Basic", base: 45, per_level: 5, note: "Both +30%" }
    - { name: "Basic Electronics", base: 50, per_level: 5 }
    - { name: "Computer Operation", base: 60, per_level: 5 }
    - { name: "Find Contraband", base: 36, per_level: 4 }
    - { name: "Automobile", base: 70, per_level: 2 }
    - { name: "Radio: Basic", base: 55, per_level: 5 }
    - { name: "Recycle", base: 50, per_level: 5 }
    - { name: "Salvage", base: 55, per_level: 5 }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"] }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Hand to hand combat may be selected as an O.C.C. Related Skill: Basic counts as one skill selection, Expert as two, Martial Arts as three, or Assassin (if evil) as four selections." }
  occ_related_skills:
    count: 15
    categories: ["Science", "Medical", "Technical", "Communications", "Domestic", "Electrical", "Espionage", "Horsemanship", "Mechanical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Weapon Proficiencies", "Wilderness"]
    note: "Select three Science skills, two Medical skills, and two Technical skills, and eight other skills (including others from the previous categories if so desired). Communications: Any (+5%; but +15% to Cryptography, Laser Communications and Optic Systems). Cowboy: None. Domestic: Any (+5%). Electrical: Any (+10%). Espionage: Wilderness Survival only (+10%). Horsemanship: General only. Mechanical: Any (+5%). Medical: Any (+10%). Military: Trap/Mine Detection (+5%) only. Physical: Any, excluding Acrobatics, Gymnastics and Wrestling. Pilot: Any (+5%). Pilot Related: Any (+10%). Rogue: Any. Science: Any (+20%). Technical: Any (+15%). W.P.: Any, excluding Heavy Weapons of any kind. Wilderness: Any (+10%). All new skills start at level one proficiency."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
      - { level: 15, count: 2 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "e-clip", qty: 2 }
  - { choose: 1, label: "laser scalpel or vibro-knife", qty: 1, from: ["laser-scalpel", "vibro-knife"] }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1 }
  - { item_id: "blank-disc", qty: 12 }
  - { item_id: "note-pad", qty: 1 }
  - { item_id: "marker", qty: 1 }
  - { item_id: "mechanical-pencil", qty: 1 }
  - { item_id: "portable-hand-held-computer", qty: 1 }
  - { item_id: "conventional-tape-measure", qty: 1 }
  - { item_id: "digital-camera", qty: 1 }
  - { item_id: "video-disc", qty: 12 }
  - { item_id: "multi-optics-band", qty: 1 }
  - { item_id: "pen-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "hand-pick", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "ammo-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "goggles", qty: 1 }
  - { item_id: "walkie-talkie-radio", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "specimen-case", qty: 6 }
  - { item_id: "specimen-dish", qty: 12 }
  - { item_id: "test-tube", qty: 6 }
  - { item_id: "specimen-jar", qty: 4 }
  - { item_id: "microscope-slide", qty: 24 }
  - { item_id: "portable-microscope", qty: 1 }
  - { item_id: "scalpel", qty: 1 }
  - { item_id: "pin", qty: 1 }
  - { item_id: "tweezers", qty: 1 }
special_abilities:
  - name: "Analyze"
    description: "A skill-like ability that enables a character to break patterns, solve strange equations, and otherwise gain insight and analysis to a situation, event or character. Also applies to strategy, finance, or ''working all the angles.'' Adds a bonus of +10% to skills such as Anthropology, Chemistry: Analytical, Computer Hacking, Cryptography, Entomology Medicine, Jury-Rig, Sensory Equipment, Trap/Mine Detection, Zoology, and Xenology, and +1 on Perception Rolls when the scientist is focused on analyzing/figuring something out."
  - name: "Hypothesize"
    description: "A skill-like ability that enables a character to brainstorm out an answer to an impossible question. Given all of the information at hand, the character can make a quantum leap in logic to arrive at a new, and possibly radical solution to a problem that no one else has made, or is likely to understand. The catch is the odds of being able to duplicate it again. Adds a +20% bonus to Jury-Rig and Brewing. G.M. Note: Use as a sudden flash of insight or realization and a quick fix (temporary) in which the character knows what to do about some critical problem. This ability does NOT apply to finding a cure for cancer or figuring out how to use, build or improve everything, but it does reduce all penalties for extremely alien physiology or alien technology by half."
  - name: "Find the Exotic"
    description: "+20% bonus to Find Contraband related to scientific equipment, medicinal drugs, rare herbs and chemicals, exotic specimens (plant, herb, insect, animal, etc.) as ingredients and component parts, or as live subjects for study or testing. May also include rare parts and pre-Rifts science related books and artifacts. Only +10% bonus to find electrical, mechanical, scholastic, or bionic contraband. These bonuses are added to the character''s normal Find Contraband skill whenever such items are being sought. Gets science and medical equipment, medicinal drugs, and exotic specimens at a discount - 30% off as a professional courtesy from most other Scientists, doctors, medical suppliers and the Black Market, 50% discount from the Black Market, labs and clinics if he trades at least 12 hours of his time to work at one of their facilities, like a Body-Chop-Shop, underground lab or illegal clinic. Every 12 hours he puts in, he can get up to 100,000 credits worth of equipment or specimens at the discount (that''s 50,000 credits, his cost)."
  - name: "Recognize Scientific Authenticity and Quality"
    description: "An exclusive skill that enables the Rogue Scientist to tell if scientific equipment is new or used, defective, low or high quality, and if a chemical, drug, specimen or sample is genuine, a fair price and if it is exactly what he needs or not. Reduce this skill by half when dealing with unknown alien items, bionics, electronics and mechanical items. Not applicable to magic items. Base Skill: 57% +3% per level of experience."
restrictions:
  - "Feared and vilified by the Coalition States as ''mad scientists'' and dangerous rogues; propaganda paints them as disruptive threats to CS society."
extraction_notes: |
  - Attribute Requirements note "a high M.E. and P.E. are helpful but not mandatory" ' || char(8212) || ' recorded as prose only, no numeric requirement given.
  - Racial Requirements: None, at least 35% are D-Bees ' || char(8212) || ' no attribute/racial numeric requirement to record.
  - Many O.C.C. skill bonuses are printed as plain percentage additions without a distinct catalog base visible on the page; base is left at 0 with the printed bonus captured in `note`, per operator hint that bases already include the O.C.C. bonus where stated as a full percentage (e.g. Astronomy & Navigation +20%, Basic Electronics +20%).
  - "Find Contraband" discount mechanic (30%/50% off, 100,000 credit cap per 12 hours worked) does not fit the bonuses schema and is preserved in special_abilities prose.
  - Cybernetics note: "Starts with none. May or may not be opposed to having cybernetics." ' || char(8212) || ' descriptive, not a mechanical restriction, so omitted from restrictions list but mentioned here.
  - Related O.C.C.s: See the others in this section ' || char(8212) || ' no specific classes named on the page.
---

## Lore

The rogue scientist is not the stereotypical bookworm or lab rat of the 21st Century, but a tough, self-reliant explorer of a harsh and unforgiving world. They are usually versed in survival skills and proficient in a wide range of science, technical, mechanical and electrical skills. In many cases, they look more like your average Headhunter than a scientist. These men and women suffer from an insatiable lust for knowledge that drives them into the wastelands and wilderness, digging through ruins to unearth pre-Rifts artifacts and technology and trying to explain magic, the Rifts, time, dimensional travel, and rediscovering humankind''s past. They explore the ruins of toppled cities and study the habits and physiology of creatures from the Rifts.

Far from the Coalition States, they are highly regarded as men of science and learning. They are a welcome and, sometimes, desperately needed addition to most adventurer groups, mercenary companies, and wilderness towns. Yet these rugged explorers of our future Earth are frequently feared by superstitious wilderness folk and by the average people of the CS. Coalition propaganda has painted these Rogues as mad scientists who care about science and knowledge above the safety of people. Reckless fools who toy with alien technology and flirt with disaster. Rumor has it that Rogue Scientists and Rogue Scholars cavort with all manner of alien beings, monsters, and worse. They also dare to enter forbidden places and hell-spawned dimensions where no god-fearing man would set foot. All propaganda from the Coalition States that fuels the flames of fear and superstition. The illiterate are constantly bombarded by talk, radio and video telecasts about insane or rebellious rogues who threatened the sanctity of the city or who support alien life over human. Reports frequently offer an inflammatory statement like, "Only the demented mind of a Rogue Scientist (or Scholar) could have conceived of anything so diabolical." Or "Several books were found among the assailant''s possessions, obviously the source of his delusions." Or warnings like, "Remember, these self-proclaimed men of science are liars and pawns of alien forces. Report any suspicious activity to the authorities at once! The life you save may be your own!"

The Coalition intentionally paints a scary picture of the Rogue Scientist, because its leaders fear their knowledge. The Coalition knows all too well the power of pre-Rifts and alien technology, and a curious mind. They are concerned that if left unhampered, these scientists may disrupt CS society and affect the status quo. To the CS, these characters are indeed rogues who question everything they see and seek answers and truths the CS would rather not have revealed. Independent and strong in body and mind, these independent crusaders are not the sheep that typifies the average CS citizen. They are wolves among the sheep. Wolves who, by their words and actions, may show the sheep how to step out of their roles and question their masters. And that is not an acceptable contingency. Thus, they are vilified, discredited and branded dangerous enemies of the States.

An inventive and resourceful scavenger, the Rogue Scientist combines all levels of knowledge and technology to his area of expertise. Some are practically Operators with expertise in mechanics and technology, others study genetics, physiology and zoology, some are naturalists and explorers, and still others study a little bit of everything.

## GM Notes

Use Hypothesize as a sudden flash of insight or realization and a quick fix (temporary) in which the character knows what to do about some critical problem. This ability does NOT apply to finding a cure for cancer or figuring out how to use, build or improve everything, but it does reduce all penalties for extremely alien physiology or alien technology by half.

The Find the Exotic discount mechanic rewards players who roleplay professional networking with other Scientists, doctors, medical suppliers, and the Black Market ' || char(8212) || ' track hours traded for the 50% discount tier carefully, as it caps at 100,000 credits worth of goods per 12-hour block of labor.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'rogue-scientist');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'rogue-scientist';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-rogue-scientist-class.sql');
