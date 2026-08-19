-- The Elemental Fusionist (Fire/Water) O.C.C., Rifts Ultimate Edition p.100-104.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/add-elemental-fusionist-fire-water-class.sql
--
-- Hand-transcribed from 300dpi page renders (the scan has no text layer) and
-- validated through parseClassMarkdown before this file was generated; skill
-- bases are computed as catalog base + the printed O.C.C. bonus. Missing
-- equipment references get the standard stub rows. Non-ASCII characters are
-- spliced in with char() - see PR #101's pre-flight.


INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('backpack', 'Backpack', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('buckskin-clothing', 'Buckskin Clothing', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('cold-weather-clothing', 'Cold Weather Clothing', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('deerskin-gloves', 'Deerskin Gloves', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('hunting-knife', 'Hunting Knife', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('large-axe', 'Large Axe', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('wooden-cross', 'Wooden Cross', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book)
VALUES ('wooden-stake', 'Wooden Stake', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition');

INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'elemental-fusionist-fire-water', 'Elemental Fusionist (Fire/Water)', 'rifts', '---
id: elemental-fusionist-fire-water
name: Elemental Fusionist (Fire/Water)
system: rifts
source_book: Rifts Ultimate Edition p.100-104
category: occ
ppe_base: "2d4x10+20, +1d4+4 per additional level starting at level two"
starting_money: "2d4x100"
bonuses:
  attributes: { PS: "1d6", PE: "1d4", PB: 2, Spd: "1d6" }
  saves: { toxins_poisons: 2, coma_death_pct: 10 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 88%." }
    - { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 40, per_level: 4 }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%" }
    - { name: "Lore ' || char(8212) || ' Faerie", base: 35, per_level: 5, note: "Lore: Faerie Folk (+10%)." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Outdoorsmanship", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Physical"], bonus: 5, note: "Physical: two of choice (+5% where applicable)." }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "Track Animals (+20%)." }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Tracking humanoids (+10%)." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Swimming", base: 55, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Axe", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: one of choice, and W.P. Modern: one non-Energy W.P. of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill selection." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", only: ["Barter", "Writing"] }
      - { name: "Cowboy", only: ["Roping"] }
      - "Domestic"
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment"] }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Military", only: ["Camouflage", "Trap/Mine Detection"] }
      - { name: "Physical", only: ["Athletics (general)", "Aerobic Athletics", "Acrobatics", "Body Building & Weight Lifting", "Juggling", "Physical Labor", "Prowl", "Running", "Wrestling"] }
      - { name: "Rogue", only: ["Concealment"] }
      - { name: "Science", only: ["Basic Math", "Advanced Math", "Biology", "Botany"] }
      - { name: "Technical", only: ["Art", "Breed Dogs", "Calligraphy", "Excavation", "Firefighting", "Gemology", "General Repair & Maintenance", "Lore: Cattle & Animals", "Masonry", "Mythology", "Philosophy", "Rope Works", "Whittling & Sculpting"] }
      - "Wilderness"
    note: "Communications also allows Language: Other. Holistic Medicine counts as two skill selections. Piloting: Paddle/Kayaking only (+5%); Pilot Related: none; Electrical: none. W.P.: any Ancient or any non-Energy Modern only. Wilderness: Any (+10%). Sundry category bonuses: Espionage/Horsemanship/Mechanical +5%, Science +5%, Gemology +5%, General Repair +10%, Prospecting +5%."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "buckskin-clothing", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1 }
  - { item_id: "deerskin-gloves", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "food-rations", qty: 3 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6+1" }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "hunting-knife", qty: 1 }
  - { item_id: "large-axe", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "small-mallet", qty: 1 }
restrictions:
  - "Race restriction: human only - the phenomenon is native to Rifts Earth and affects only humans."
  - "Cybernetics: will NEVER get cybernetics, even to replace a limb. A Bio-System implant instantly destroys all elemental abilities."
  - "City P.P.E. penalties: all fusion powers cost triple P.P.E. in a city or inside a building. Perception: +3 in the wild; -2 in villages and small towns, -4 in large towns, -6 in cities."
special_abilities:
  - name: "Flame Drench or Flame Coat"
    description: "Dowses himself with water (or his own sweat) and sets it ablaze as a protective energy field: 25 M.D.C. per level. Attackers striking the flame-engulfed character take 1D4 M.D. Punches and kicks inflict 1D6 M.D. or 5D6 S.D.C. (damage regulated at will). Range: self. Duration: 5 minutes per level. P.P.E.: 8."
  - name: "Fire Flood"
    description: "Makes fire travel like rolling water across a surface, or unleashes a flood of real water set aflame. Range: 15 feet (4.6 m) per level; the water must be moving. Damage: catches combustibles, 4D6 M.D. per melee round. Duration: two melee rounds per level. Save: dodge or dive under the surface fire. P.P.E.: 8."
  - name: "Firestorm"
    description: "One bolt of fire per level of experience rains down from the sky at a target in line of vision. Range: 300 feet (91.5 m). Damage: 1D6 M.D. per level. Duration: instant. Save: none, not even a dodge. P.P.E.: 6."
  - name: "Fire & Water Lungs"
    description: "Breathes fire and smoke as if air, and water like a fish; sees clearly through smoke and murky water. Duration: 5 minutes per level. P.P.E.: 1."
  - name: "Fire Water"
    description: "Turns water or alcohol into a magical warming elixir - four ounces keeps a person warm and safe from exposure for one hour per level. P.P.E.: 2 per quarter gallon."
  - name: "Fire/Water Protective Field"
    description: "An instinctive, barely perceptible energy field: 10 M.D.C. per level, clicks on at the first instance of danger, keeps the character dry. Range: self. Duration: 10 minutes per level. P.P.E.: 3."
  - name: "Hot Ice"
    description: "Turns ice into the equivalent of hot coal - 10 lbs per level. A one-pound lump inflicts 2D6 S.D.C. thrown or touched; stays hot 10 minutes per level, then returns to normal. P.P.E.: 2."
  - name: "Liquid Fire"
    description: "Sets the surface of ordinary water on fire in a line, wall or circle. Range: line of sight up to 5 feet per level or touch; up to a 20 foot diameter per level. Damage: 1D6 M.D. to anybody running through. Duration: one melee round per level. Only the water burns. P.P.E.: 4."
  - name: "Spit Fire"
    description: "Spits small gobs of fire. Range: 3 feet per level. Damage: 1D4 M.D. or 2D4 S.D.C. (regulated at will); each spit counts as one melee attack. Save: parry with a shield, or dodge. P.P.E.: 1."
  - name: "Steam Bath"
    description: "A soothing cloud of warm steam that cleans everything passing through it. Six foot diameter; one melee round per level. Save: standard vs magic. P.P.E.: 1."
  - name: "Steam Blast"
    description: "A blast of steam from the hands. Range: 6 feet per level. Damage: 2D6 S.D.C./Hit Points; each blast is one attack. Save: dodge at -2. P.P.E.: 1."
  - name: "Steam Bolt"
    description: "A thrown blast of superheated steam. Range: 20 feet per level. Damage: 3D6 M.D. (half to M.D.C. armor, double to creatures vulnerable to water). Each blast counts as one attack. Save: dodge at -3. P.P.E.: 3 per blast."
  - name: "Superheat Water"
    description: "Sets contained water to boil in five seconds with a glance or touch (counts as two melee attacks). Up to 12 gallons per level. Range: six feet. P.P.E.: 1."
  - { choose: 5, from: ["Flame Drench or Flame Coat", "Fire Flood", "Firestorm", "Fire & Water Lungs", "Fire Water", "Fire/Water Protective Field", "Hot Ice", "Liquid Fire", "Spit Fire", "Steam Bath", "Steam Blast", "Steam Bolt", "Superheat Water"] }
natural_abilities:
  - name: "Elemental Resistance"
    description: "Starts with 25% resistance to any damage in the character''s own two elements; 50% at level 4, 75% at level 8, full immunity at level 12. Reduce damage and penalties accordingly."
  - name: "Speak Elemental"
    description: "Can converse with any Elemental of either of the two forces held within, as equals - the Elemental may be convinced but never commanded, and cannot be summoned. Understanding: 60% +2% per level."
  - name: "Sense Elementals"
    description: "Detects Elementals of the character''s own power class within a 100 foot (30.5 m) radius."
  - name: "Increased Healing"
    description: "Heals at twice the normal rate in remote wilderness, triple in the mountains."
  - name: "Elemental Spell Magic"
    description: "Intuitively knows a handful of Elemental Magic spells from the character''s own orientation list - select one at first level and one per subsequent level. The lists (with P.P.E. costs) are in GM Notes; Elemental spells are not yet in the spell catalog, so record picks by hand."
  - name: "P.P.E."
    description: "Permanent Base P.P.E.: 2D4x10+20 added to the character''s P.E. attribute, plus 1D4+4 per additional level starting at level two. Cannot draw P.P.E. from ley lines or other beings, but can draw up to 30 P.P.E. per melee round from a willing Elemental of his orientation. Recovery: 5 per hour of rest, 10 per hour of meditation."
extraction_notes: |
  - RUE p.100-104. M.E. 12, P.E. 12, plus I.Q. and P.S. 10 recommended but NOT
    required - so no attribute_requirements are set; the recommendation is
    prose.
  - The two elemental orientations (Fire/Water and Earth/Air) have different
    initial powers and different power lists, which variants cannot express
    (a variant may not change abilities) - so each orientation is its own
    published class sharing everything else.
  - Fusion powers picked beyond level one (+2 at levels 3, 6, 9 and 12) have
    no schema shape - ability choice groups are creation-time; later picks are
    G.M.-assigned powers on the sheet.
  - Elemental Magic spells are not in the spell catalog; the class''s spell
    lists live in GM Notes and picks are recorded by hand.
  - Money: 2D4x100 credits plus 1D6x100 in sellable pelts and minerals.
---

## Lore

As the power of the ley lines arced across Rifts Earth, the magical energies awakened the forces of nature that had lain dormant for centuries. Those closest to the wilds have started to exhibit abilities that come from their close association with these forces. Unlike the Warlock, who harnesses the elemental forces and calls upon Elemental beings, and the Druid, who worships nature, Elemental Fusionists channel the latent elemental energy of the world through their veins on a primordial and instinctive level - the energy is part of them rather than an outside force to command.

Elemental Fusionists always combine two conflicting forces of nature - Fire and Water, or Earth and Air - and the conflict gives them personalities that often seem schizophrenic, bouncing between the two elemental aspects. Without exception they are born far away from civilization: hardy, lumberjack or woodsmen types with a wide variety of outdoorsman skills who shy away from Piloting, Mechanical and Electrical skills, and are only ever born human.

They feel restricted by most body armor - powers are less effective when wearing anything greater than a light suit - and are uncomfortable in cities, where all their powers cost triple P.P.E.

## GM Notes

**Elemental Fusionist Spell Lists** (select one at level one and one per level; P.P.E. in parentheses):

- **Earth/Air:** Breathe Without Air (3), Chameleon (5), Change Wind Direction (6), Create Light (2), Create Mild Wind (4), Dig (8), Distant Voice (5), Electric Arc (4), Dust Storm (5), Identify Minerals (3), Identify Plants (3), Mend Stone (15), Sand Storm (15), Stop Wind (5), Thunder Clap (2), Throwing Stones (4), Travel Through Walls (20), Walk the Wind (10).
- **Fire/Water:** Blinding Flash (1), Breathe Underwater (6), Cloud of Ash (5), Cloud of Steam (10), Dowsing (2), Float on Water (4), Fog of Fear (7), Frostblade (7), Extinguish Fire (8), Fiery Touch (5), Fire Bolt (4), Globe of Daylight (2), Impervious to Fire (5), Nightvision (4), Resist Cold (5), Sense Direction Underwater (4), Spontaneous Combustion (5), Walk the Waves (5).

Powers picked at levels 3, 6, 9 and 12 (+2 each): assign through the sheet''s G.M. power control.


**Fire/Water orientation.** Initial powers: resistant to fire and water attacks, +20% to Swimming (swim without fatigue one hour per level), and pick five powers at level one.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'elemental-fusionist-fire-water');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr FROM imported_classes WHERE class_id = 'elemental-fusionist-fire-water';
SELECT count(*) AS stub_gear FROM gear WHERE slug IN ('backpack', 'buckskin-clothing', 'cold-weather-clothing', 'deerskin-gloves', 'hunting-knife', 'large-axe', 'wooden-cross', 'wooden-stake');

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('add-elemental-fusionist-fire-water-class.sql');
