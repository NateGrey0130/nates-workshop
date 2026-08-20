-- The Ley Line Rifter O.C.C., Rifts Ultimate Edition p.116-118.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-ley-line-rifter-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('backpack', 'Backpack', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'ley-line-rifter', 'Ley Line Rifter', 'rifts', '---
id: ley-line-rifter
name: Ley Line Rifter
system: rifts
source_book: Rifts Ultimate Edition p.116-118
category: occ
attribute_requirements: { IQ: 10, PE: 12 }
ppe_base: "3d6x10+20, +3d6 per additional level starting at level two"
starting_money: "1d4x1000"
magic:
  type: "spell"
  spells_starting: 6
  spell_levels_allowed: [1, 2]
bonuses:
  saves: { horror_factor: 5, possession: 3, mind_control: 2, curses: 2 }
  at_level:
    - { level: 3, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 6, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 9, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 11, saves: { spell_magic: 1, ritual_magic: 1 } }
    - { level: 14, saves: { spell_magic: 1, ritual_magic: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 98% per the Ley Line Walker." }
    - { choose: 2, categories: ["Communications"], bonus: 20, note: "Language: Other, two of choice (+20%)." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Basic Math", base: 55, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 40, per_level: 4, note: "+4%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Pilot"], bonus: 5, note: "Pilot: one of choice (+5%)." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { choose: 4, categories: ["Technical"], bonus: 10, note: "Lore: four of choice (+10%); the catalog files lore skills under Technical." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if an evil alignment) at the cost of two." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", only: ["Radio: Basic"] }
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Gymnastics", "Wrestling"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Stats are the Ley Line Walker''s: two of the seven must be from Science and one from Technical. Paramedic counts as two skills. Category bonuses: Domestic +10%, Espionage +5%, Medical +5%, Pilot +2%, Pilot Related +2%, Science +10%, Technical +5%."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    note: "Plus one additional Secondary Skill at levels 4, 8 and 12."
equipment_starting:
  - { item_id: "robe-or-cape", qty: 1 }
  - { item_id: "clothing", qty: 1 }
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "light-mdc-body-armor", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "wooden-stake-and-mallet", qty: 6 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "tinted-goggles-or-sunglasses", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { choose: 1, label: "automatic pistol or submachine-gun", qty: 1, from: ["automatic-pistol", "submachine-gun"] }
  - { choose: 1, label: "energy pistol or rifle", qty: 1, from: ["energy-pistol", "energy-rifle"] }
  - { item_id: "ammunition-clips", qty: 3 }
natural_abilities:
  - name: "Ley Line Walker Abilities (1-8)"
    description: "The Ley Line Rifter has the Ley Line Walker''s first eight ley line powers: Sense Ley Line, Sense Ley Line Nexus, Sense a Rift, Sense Magic in Use, See Magic Energy, Read Ley Lines, Ley Line Transmission, Ley Line Phasing, Ley Line Walking/Drifting, Ley Line Rejuvenation and the Observation Ball - see the Ley Line Walker O.C.C."
  - name: "Teleportational Hitchhiking"
    description: "INSTEAD OF the Ley Line Force Field: the Rifter can hitch a ride on any form of teleportation - a spell such as Mystic Portal, Dimensional Portal, Swap Places or Teleport, or a dragon''s or demon''s natural teleport - arriving wherever the teleporter reappears. The teleport must begin within range and line of sight of the Rifter. Range: 100 feet (30.5 m) +20 feet (6.1 m) per level of experience. P.P.E. Cost: 20."
  - name: "Rift and Ley Line Specialist Spell Lists"
    description: "Casts spells from List A (Rift & Ley Line Magic: Dimensional Portal, Ley Line Fade, Ley Line Ghost, Ley Line Phantom, Ley Line Restoration, Ley Line Resurrection, Ley Line Shutdown, Ley Line Storm Defense, Ley Line Tendril Bolts, Ley Line Time Capsule, Ley Line Time Flux, Ley Line Transmission, Rift to Limbo, Rift Teleportation, Rift Triangular Defense System, Summon Ley Line Storm, Swallowing Rift) and List B (Astral Projection, Calling, Call Lightning, Chameleon, Close Rift, Concealment, Detect Concealment, Dispel Magic Barriers, Energy Disruption, Escape, Locate, Mystic Portal, Negate Magic, Plane Skip, Reality Flux, Second Sight, Shadow Meld, Teleport: Lesser, Teleport: Superior, Time Hole, Time Slip) at HALF the usual P.P.E. cost. At level one, select four spells from List A and two from List B in addition to the six standard picks."
  - name: "Learning New Spells (Ley Line Communion)"
    description: "On reaching a new level of experience the Rifter can commune with a ley line in a 48-hour meditative trance; at the end he knows one spell (his pick) from EACH of List A and List B."
  - name: "P.P.E. Recovery"
    description: "Spent P.P.E. recovers at seven points per hour of sleep or rest; meditation restores 15 per hour. Supplemental P.P.E. as the Ley Line Walker: +20 per melee round on a ley line, +40 at a nexus."
side_effects: "Insanity for Rifters: gains a Phobia or Obsession (player''s choice) at levels 4, 8 and 12."
restrictions:
  - "O.C.C. bonuses beyond the modeled saves: +2 on one Physical attribute of choice (P.S., P.P., P.E., P.B. or Spd), +1 to Spell Strength at levels 3, 7, 10 and 13, and +2 on Perception Rolls - chosen or applied by hand."
extraction_notes: |
  - RUE p.116-118. A subset of the Ley Line Walker: stats, skills, equipment and
    money are stated as "Same as the Ley Line Walker" and are copied from that
    class''s entry.
  - Initial spells are 3 from spell level one + 3 from level two (modeled:
    spells_starting 6, levels 1-2) PLUS four picks from List A and two from
    List B - the named lists are recorded in natural_abilities because the
    picker cannot restrict to a named list, and several List A spells are not
    yet in the spell catalog.
  - The half-P.P.E. casting for Lists A and B is prose; the sheet''s use button
    deducts full listed cost, adjust by hand.
  - "+2 on any one Physical attribute" is a player choice the bonus schema
    cannot express; recorded under restrictions for visibility.
---

## Lore

Rifters believe Rift and Ley Line Magic is of significant and overriding value and should be studied and mastered above all others. They consider themselves the elite, with unique and superior insight about ley lines and Rifting. Although they focus on learning a range of spells, they are the undisputed masters of Rift and Ley Line Magic.

The focus on the dimensional aspect of ley lines gives the Rifter the insight to realize that the magic knowledge that comes from communing with a ley line at a new mystic plateau comes from beyond the Rift - the mind or memory of some long-deceased mage, creature of magic, Demon Lord, Dark God or Alien Intelligence whose memories have been psychically imprinted onto the line. Rifters worry that some powerful creature may have access to their minds while entranced; there are numerous reports of dark beings reaching out to communicate during ley line communion, and both Rifters and Line Walkers report odd dreams, nightmares and visions while entranced.

## GM Notes

The Rifter''s spell lists A and B are priced at half P.P.E. in the book (reduced costs printed in parentheses there). When those spells land in the catalog, remember the half-cost applies only to this class.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'ley-line-rifter');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'ley-line-rifter';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('backpack');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-ley-line-rifter-class.sql');
