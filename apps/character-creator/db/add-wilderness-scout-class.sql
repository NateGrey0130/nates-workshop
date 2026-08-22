-- The Wilderness Scout O.C.C., Rifts Ultimate Edition p.98-99.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-wilderness-scout-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-wilderness-scout-class.sql
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
SELECT 'wilderness-scout', 'Wilderness Scout', 'rifts', '---
id: wilderness-scout
name: Wilderness Scout
system: rifts
source_book: Rifts Ultimate Edition p.98-99
category: occ
attribute_requirements:
  IQ: 8
  PE: 12
bonuses:
  attributes: { PS: "1d4", PE: "1d4" }
  sdc: "3d6+10"
  combat: { initiative: 1, roll: 2 }
  saves: { toxins_poisons: 10, coma_death_pct: 10, horror_factor: 1 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 94, per_level: 1 }
    - { choose: 2, categories: ["Communications"], bonus: 15, note: "Language: Other, two of choice (+15%)." }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Cook", base: 15, per_level: 5, note: "+15%" }
    - { name: "Climbing", base: 20, per_level: 5, note: "+20%" }
    - { name: "Fishing", base: 15, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 20, per_level: 5, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 20, per_level: 5, note: "+20%" }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 20, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hovercycles, Skycycles & Rocket Bikes", "Horsemanship: General"], bonus: 14, note: "Pilot: Motorcycle (+14%) or Hovercycle (+10%) or Horsemanship (General); pick one." }
    - { name: "Prowl", base: 15, per_level: 5, note: "+15%" }
    - { name: "Radio: Basic", base: 10, per_level: 5, note: "+10%" }
    - { name: "Track & Trap Animals", base: 20, per_level: 5, note: "+20%" }
    - { name: "Wilderness Survival", base: 20, per_level: 5, note: "+20%" }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. Ancient and/or Modern: Three of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if evil alignment) for the cost of two." }
  occ_related_skills:
    count: 2
    categories:
      - "Physical"
      - "Wilderness"
      - "Communications"
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
      - "Weapon Proficiencies"
    note: "Select two Physical skills, one Wilderness skill and six other skills, +1 at levels 2, 5, 8, 11, and 14. All new skills start at level one proficiency. Communications: Barter, Language (any; +10%), Literacy (any), Performance, and Public Speaking only. Cowboy: None. Domestic: Any (+10%). Electrical: Basic Electronics only. Espionage: Any (+10%), except Forgery and Pick Locks. Horsemanship: Exotic Animals (+5%) only. Mechanical: Automotive only. Medical: First Aid (+10%) or Holistic Medicine (+20%), but the latter counts as two skill selections. Military: None. Physical: Any, except Acrobatics (+10% when applicable). Pilot: Any, except robots, power armor, military or large, noisy vehicles. Pilot Related: Any. Rogue: Gambling, Imitate Voices & Sounds, and Tailing only (+5%). Science: Math: Basic, Anthropology, Biology, and Botany only. Technical: Any (+5% to most, a +15% bonus applies only to Breed Dogs, Lore (any) and Rope Works). W.P.: Any. Wilderness: Any (+20%)."
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
equipment_starting:
  - { item_id: "light-mdc-body-armor", qty: 1 }
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
extraction_notes: |
  - Skill bases in occ_skills are the printed O.C.C. bonus percentages as given
    on the page; the page states these are bonuses added to a base skill, but
    per the operator hint the printed number is used directly as "base" since
    catalog base + bonus is already combined in the source presentation given.
  - Standard Equipment list is split across page 99''s end and likely continues
    onto a following page not provided; the list appears cut off after
    "infrared binoculars with digital distancing readout, a pair" ' || char(8212) || ' remaining
    items (a pair of ??? and beyond) are not captured because the source page
    ends mid-sentence.
  - Money and Cybernetics sections for this class were not visible on the
    provided pages (they appear to belong to a following page not included).
  - Special O.C.C. Abilities (Trail Blazing, Cross-Country Pacing,
    Cartography) are percentile skill-like abilities with base/per-level
    formulas but are not skill-list skills; recorded as special_abilities
    since they do not fit the skills schema cleanly.
  - "O.C.C. Bonuses" section: +3D6+10 to physical S.D.C. was recorded under
    sdc_base-style bonus; +1D4 to P.S. and P.E. attributes recorded as
    attribute bonuses; +1 on initiative and +3 on Perception Rolls (Perception
    has no bonus key, left as prose); +2 to roll with impact; +2 to save vs
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

Related O.C.C.s: see the Gambler, Saddle Tramp, Saloon Bum and Bar Maid in Rifts World Book 14: New West for thematically similar wilderness/rural characters.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'wilderness-scout');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'wilderness-scout';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-wilderness-scout-class.sql');
