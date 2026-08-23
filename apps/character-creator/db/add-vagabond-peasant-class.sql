-- The Vagabond, Peasant or Farmer O.C.C., Palladium Fantasy RPG Main Book p.99.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-vagabond-peasant-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-vagabond-peasant-class.sql
--
-- Transcribed from the PDF's own text layer, read in column order with
-- scripts/read-columns.py, and validated with scripts/class-check.mjs before
-- this file was generated. Pure ASCII, LF endings.
--
-- NOT the Rifts Vagabond, and the two were compared before this file existed.
-- The Rifts class has an O.C.C. Bonuses block and a named special ability;
-- this one has neither. Their skill lists share three names, two of which are
-- boilerplate almost every class carries, and even the native tongue disagrees
-- - 98% here against 88% there. Two classes, not one class in two editions, so
-- a second row rather than a recorded delta. That is where the Warlock landed
-- on the same test, in the other direction.
--
-- The page prints no S.D.C. formula, so the core rule on printed 18 applies:
-- the Vagabond/Peasant is filed under Optional O.C.C.s and is not a man of
-- arms, so CORE_SDC_BY_CLASS rolls it 1D6.


-- The class itself. INSERT ... WHERE NOT EXISTS rather than INSERT OR IGNORE,
-- so re-running the script is a no-op instead of a silent partial write.
INSERT INTO imported_classes (class_id, name, system, markdown, status, created_by)
SELECT 'vagabond-peasant', 'Vagabond, Peasant or Farmer', 'palladium-fantasy', '---
id: vagabond-peasant
name: Vagabond, Peasant or Farmer
system: palladium-fantasy
source_book: Palladium Fantasy RPG Main Book p.99
category: occ
starting_money: 120
skills:
  occ_skills:
    - { name: "Animal Husbandry", base: 40, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Cook", base: 40, per_level: 5, note: "+5% O.C.C. bonus" }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Two languages of choice (+10% each). Language: Other is the repeatable row - take it twice for two different languages." }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5% O.C.C. bonus" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Expert for the cost of two other skills, or Martial Arts for the cost of three." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Domestic", note: "+10%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - { name: "Rogue", note: "+2%" }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], note: "Mathematics skills only." }
      - { name: "Technical", note: "+5%" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 10, count: 2 }]
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "belt", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "large-sack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: "1d4" }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "food-rations", qty: "1d4+1" }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "hard-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 1 }
  - { item_id: "hand-axe", qty: 1 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "No Communications, Espionage or Military related skills. The page lists all three as None."
extraction_notes: |
  - THIS IS NOT THE RIFTS VAGABOND, and the two were compared before deciding. The Warlock test - do the two printings agree on everything mechanical, differing only in the world''s furniture? - fails here in both directions. The Rifts Vagabond has an O.C.C. Bonuses block (+1D4 M.A., +1 P.S., +2 P.E., +4 Perception, +2D6+10 S.D.C., +1 vs possession, +2 vs horror factor) and a named special ability, Eyeball a Fella; this class has NO bonuses section at all and no special abilities. Their O.C.C. skill lists share three names and two of those are boilerplate almost every class in either book carries - Language: Native Tongue and Hand to Hand: Basic - leaving Cook as the only substantive overlap, and even the native tongue disagrees: 98% here against the Rifts 88%. The related allowance is six against five and the categories differ; the secondary schedule is 4 then +2 at levels 2, 5 and 10 against a different shape entirely. Two classes, not one class in two editions - so a second row rather than a recorded delta.
  - "Attribute Requirements: None" is an absence and is written as one - no attribute_requirements block - rather than encoded as a note.
  - The page prints no O.C.C. Bonuses and no S.D.C. formula, so S.D.C. comes from the core rule on printed 18. The Vagabond/Peasant is filed under Optional O.C.C.s (printed 96-99) and is not a man of arms, so it rolls 1D6.
  - "Multiple O.C.C.s are possible as long as the character has the required attributes" appears on every Optional O.C.C. page. The app has no multi-O.C.C. model beyond race + occupation, so it is prose.
  - Per-category related-skill bonuses (+10% Domestic, +2% Rogue, +5% Scholar/Technical) are notes: occ_related_skills.categories takes only/except and a note, and the app has no per-category percentage field.
  - The book''s "Scholar/Technical" is the catalog''s Technical category.
  - "All new skills start at level one proficiency" and "All secondary skills start at the base skill level" are how the app already behaves.
---

## Lore

Not everybody who gets involved in adventure is a specialist in combat or some other area of training. Some are just ordinary people who get swept up in the flow of events, or who decide it is time they made a change in their life. The vagabond/peasant Occupational Character Class represents player characters who have no impressive area of expertise and no special powers - a person from an ordinary walk of life, which in this low tech, agricultural society is likely to be a farmer, laborer, peasant or vagabond.

The unskilled character is a spirited individual, full of life and dreams for a better future. Most are illiterate and lack any formal education. Consequently they tend to live by the seat of their pants and rely on their wits.

**Alignments:** Any.

**Attribute Requirements:** None. Several classes ask for nothing - the Noble, the Witch, both priests and all four psychic P.C.C.s - but this is the only one that also grants no bonuses, no abilities, no magic and no psionics. It is the least specialised entry in the book by design.

## GM Notes

The Vagabond/Peasant is the book''s answer to a player who wants to start as nobody in particular. It grants no bonuses, no abilities and no armour beyond a suit of hard leather.

It is not compensated for that. Ten related picks over fifteen levels is the lowest of any Palladium O.C.C. in the catalog - the Scholar gets twenty, the Mercenary Fighter eighteen - and ten secondary picks is mid-table, behind the Wizard, Druid, Warrior Monk and Priest of Light on fourteen. The class is meant to be played from behind, and the book is not shy about it: the character has no impressive area of expertise and no special powers.

What it does have is a wide door. Six related picks at level one from nine categories, with only Communications, Espionage and Military closed, and something new at nine of the first twelve levels - related at 3, 6, 9 and 12, secondary at 2, 5 and 10. A character with no defining trick becomes the party''s answer to whatever nobody else thought to learn.

It is also the natural second half for a race the book bars from almost everything: the troglodyte, the goblin, the hob-goblin and the orc are all held to a short list of occupations, and this is on every one of them.
', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'vagabond-peasant');


-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'vagabond-peasant';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-vagabond-peasant-class.sql');
