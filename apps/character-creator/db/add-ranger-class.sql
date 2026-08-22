-- The Ranger O.C.C., Palladium Fantasy main book, printed pp.90-91.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-ranger-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-ranger-class.sql
--
-- Read with scripts/read-columns.py; the stat block runs across a column break,
-- with the related-skill list starting at the top of the next page. Apply
-- fix-pf-armor-and-cross-system-gear.sql first or alongside: this class needs
-- studded leather priced, and the hand axe, skinning knife, clothing and gloves
-- rows visible to a Palladium campaign.
--
-- Validated with scripts/class-check.mjs (ready, 0 errors, 0 warnings) before
-- this file was generated. Skill bases are the catalog base plus the printed
-- O.C.C. bonus, already added.
--
-- FOUR NAMES THAT RESOLVE TO A ROW THAT IS ALREADY THERE, rather than to a new
-- one. Each was checked against the printed numbers first; a new row would have
-- been a duplicate of the same skill or item under a second name.
--
--   Track Humanoids      -> Tracking (people). Same skill, same printed base of
--                           25% +5% (p52). The book files it under Wilderness
--                           and the catalog under Espionage; the catalog's
--                           filing is what the related-skill gates read, so the
--                           difference is recorded in the skill note.
--   Identify Plants &
--     Fruits             -> Identify Plants & Fruit. Singular in the catalog.
--   skinning/tanning
--     knives             -> Knife, Skinning. The book gives "a set"; the
--                           catalog has one row and no price for a set.
--   surgeon              -> Field Surgery, in the Medical `except` list. That
--                           is the row the exclusion lands on.
--
-- USE/RECOGNIZE POISON HAS NO CATALOG ROW. The book allows the ranger two Rogue
-- skills: Card Shark and Use/Recognize Poison (+6%). Only the first exists, so
-- the category is narrowed to Cardsharp alone and the poison half stays in the
-- note. Listing a skill that is not in the catalog would make the picker offer
-- nothing under a heading that says it should.

-- ---- the class ------------------------------------------------------------
-- INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE, so re-running is a
-- no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'ranger', 'Ranger', 'palladium-fantasy', '---
id: ranger
name: Ranger
system: palladium-fantasy
source_book: palladium-fantasy-core
category: occ
attribute_requirements: { IQ: 9, PS: 10, PE: 13 }
starting_money: "160"
bonuses:
  saves: { horror_factor: 2 }
skills:
  occ_skills:
    - { name: "Animal Husbandry", base: 45, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 15, note: "Two languages of choice (+15% each)" }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "+15%" }
    - { name: "Skin & Prepare Animal Hides", base: 45, per_level: 5, note: "+15%" }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "+20%" }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "+15%. The book calls this Track Humanoids and files it under Wilderness; the catalog row is the Espionage one, same 25% +5% base." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice. The ranger is the only O.C.C. besides the Long Bowman allowed to take the long bow, which is a separate W.P. from Archery." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert for the cost of one other skill, or to Martial Arts or Assassin (if evil) for the cost of two." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", only: ["Sign Language"] }
      - { name: "Domestic", note: "+10%" }
      - { name: "Espionage", only: ["Detect Ambush", "Intelligence"], note: "Detect Ambush +5%, Intelligence +10%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"], note: "+5%" }
      - { name: "Medical", except: ["Field Surgery"], note: "Any except surgeon" }
      - "Military"
      - { name: "Physical", except: ["Acrobatics", "Gymnastics"] }
      - { name: "Rogue", only: ["Cardsharp"], note: "Card Shark and Use/Recognize Poison (+6%) only; the catalog has no poison row." }
      - { name: "Science", note: "+5%" }
      - { name: "Technical", note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", note: "+10%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 5, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { choose: 1, label: "cape or cloak", qty: 1, from: ["cape-long", "cape-long-hooded"] }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "small-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "fishing-line-per-20-ft", qty: 1 }
  - { item_id: "fishing-hook", qty: 1 }
  - { item_id: "snare-cord-per-4-ft", qty: "1d4" }
  - { item_id: "wolf-trap-metal-teeth", qty: 2 }
  - { item_id: "knife-skinning", qty: 1 }
  - { item_id: "light-chain-per-10-ft-3m", qty: 1 }
  - { item_id: "rope", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4+1" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "oil-lantern-6-hours-1-pint", qty: 1 }
  - { item_id: "frying-pan", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "studded-leather", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "Armour is studded leather (A.R. 13, 38 S.D.C.). Rangers prefer leather for its manoeuvrability, stealth and natural or dyed colours, but wear leather and chain, chain mail, scale, splint or plate when their adventures run to battle, with the usual penalties: -15% to prowl and -20% to climb or scale walls in full splint or plate, -10% to prowl or climb in chain or scale mail, -5% in studded leather."
  - "Every starting weapon is a basic S.D.C. weapon of very good quality. Favourites are the bow and arrow, sword, throwing knives and staff. The lance is not on the list: the book limits it to the Knight and Palladin."
  - "The hand axe is mainly for chopping wood. The light chain is a six foot (1.8 m) length and the rope is 30 feet (9 m); both are catalogued in longer units."
  - "Pay for a working ranger varies from 50-100 gold for the simplest task to 300-1000 for dangerous or military assignments. Merchants, wealthy travellers and the military hire them as guides, scouts and reconnaissance or intelligence agents."
extraction_notes: "Track Humanoids resolves to the catalog Tracking (people) row rather than a new one: same skill, same 25% +5% base, filed under Espionage instead of Wilderness. Use/Recognize Poison has no catalog row, so the Rogue category is narrowed to Card Shark alone and the poison half is left in the note. Skinning and tanning knives resolve to the single Knife, Skinning row. The two weapons of choice are enumerated as the whole Palladium Fantasy weapon catalog minus the lance, because equipment choices take item slugs rather than a category."
---

# Ranger

## Lore

The ranger is a huntsman, trapper and wilderness scout, capable of hunting,
tracking and trapping animal and humanoid prey alike. He is usually familiar
with a number of terrains and well versed in the survival skills the wild
demands: identifying tracks and following them, blazing trails, concealing
trails, prowling, and handling himself in a fight. Clever, resourceful and
hardy, the ranger enjoys the freedom and purity of nature, the challenge of
survival, and living off the land. Most understand the balance of nature, hold a
high regard for life, kill only what they need and use as much of a slain animal
as they can. Few kill for pleasure.

Familiarity with the wild usually brings some knowledge of forestry, weather
patterns, animal husbandry and faerie folk, and rangers tend to be fond of
animals, though few keep companions beyond a horse or a dog. Only retired or
semi-retired rangers settle anywhere long enough to breed dogs, horses or
livestock.

How a ranger lives is up to the individual. Some prefer the wilderness and shun
civilisation; others enjoy both. Some make a living trapping, skinning animals,
selling pelts and telling tall tales. Others sell their abilities as bounty
hunters, guides, scouts and trackers to the military, nobility, merchant
caravans and travellers. Some adventure for wealth, glory and power, some simply
crave adventure, and some explore the land and study its wildlife for its own
sake. Those who turn to crime become bandits, or join outlaw bands to waylay
caravans, travellers and even squads of soldiers.

## Alignment

Any.
', 'published', 'data-script'
 WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'ranger');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, system, status, length(markdown) AS md_bytes
  FROM imported_classes WHERE class_id = 'ranger';
-- Every slug this class grants outright must already be a real catalog row.
-- Counted against an IN list rather than a UNION ALL of literals: D1 caps the
-- terms in a compound SELECT, and nine of them is already over the line.
SELECT 9 - count(*) AS missing_gear FROM gear
 WHERE slug IN ('studded-leather', 'hand-axe', 'knife-skinning', 'clothing',
                'gloves', 'wolf-trap-metal-teeth', 'snare-cord-per-4-ft',
                'oil-lantern-6-hours-1-pint', 'frying-pan');
SELECT count(*) AS stub_gear FROM gear
 WHERE slug IN ('studded-leather', 'hand-axe', 'knife-skinning')
   AND description LIKE 'STUB%';

INSERT INTO data_script_runs (filename) VALUES ('add-ranger-class.sql');
