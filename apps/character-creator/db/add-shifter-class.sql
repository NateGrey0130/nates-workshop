-- The Shifter O.C.C., Rifts Ultimate Edition p.120-126.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-shifter-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('garlic-cloves', 'Garlic Cloves', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hand-held-computer', 'Hand Held Computer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('iron-javelin-rod', 'Iron Javelin Rod', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('large-wood-cross', 'Large Wood Cross', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-digital-disc-recorder', 'Pocket Digital Disc Recorder', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-laser-distancer', 'Pocket Laser Distancer', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('pocket-mirror', 'Pocket Mirror', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('salt', 'Salt', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('small-silver-cross', 'Small Silver Cross', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'shifter', 'Shifter', 'rifts', '---
id: shifter
name: Shifter
system: rifts
source_book: Rifts Ultimate Edition p.120-126
category: occ
attribute_requirements: { IQ: 12, ME: 12 }
ppe_base: "2d6x10+10, +2d6 per additional level starting at level two"
starting_money: "1d6x1000"
magic:
  type: "spell"
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
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 98%." }
    - { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }
    - { name: "Literacy: Native Language", base: 70, per_level: 5, note: "+30%" }
    - { name: "Literacy: Other", base: 50, per_level: 5, note: "One of choice (+20%)." }
    - { name: "Astronomy", base: 45, per_level: 5, note: "+20%" }
    - { name: "Basic Math", base: 60, per_level: 5, note: "Mathematics: Basic (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Lore: Dimensions", base: 35, per_level: 5, note: "Special Shifter skill: the study of dimensions - what dimensions exist, who lives there, dimensional quirks. Alien dimensions may impose -15% to -50%; places visited three or more times give +15%. Printed base 15% +5%/level, +20% O.C.C. bonus folded in." }
    - { name: "Lore ' || char(8212) || ' Faerie", base: 40, per_level: 5, note: "Lore: Faerie (+15%)." }
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts or Assassin (if Anarchist or evil alignment) for the cost of two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", except: ["Laser Communications", "Optic Systems", "Read Sensory Equipment", "Surveillance Systems", "T.V./Video"] }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics", "Boxing", "Gymnastics", "Wrestling"] }
      - { name: "Pilot", except: ["Airplane", "Jet Aircraft", "Helicopter", "Jet Fighters", "Tanks and APCs", "Robots and Power Armor", "Military: Combat Helicopter", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Jet Fighters"] }
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Communications: Any (+5%, +10% on Languages and Public Speaking). Domestic +5%. Espionage: Intelligence only (+5%). Medical: First Aid, Holistic Medicine, or Paramedic only (+5%). Rogue +2%. Science +5%. Technical +5%. Cowboy, Mechanical and Military: none."
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
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "large-wood-cross", qty: 1 }
  - { item_id: "garlic-cloves", qty: "2d4" }
  - { item_id: "wooden-stake-and-mallet", qty: 6 }
  - { item_id: "salt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "pocket-digital-disc-recorder", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "submachine-gun", qty: 1 }
  - { item_id: "energy-rifle", qty: 1 }
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
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'shifter');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'shifter';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('garlic-cloves', 'hand-held-computer', 'iron-javelin-rod', 'large-wood-cross', 'pocket-digital-disc-recorder', 'pocket-laser-distancer', 'pocket-mirror', 'salt', 'small-silver-cross');
