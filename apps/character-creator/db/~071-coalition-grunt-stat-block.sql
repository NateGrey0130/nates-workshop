-- Gives the Coalition Grunt O.C.C. (Rifts Ultimate Edition printed 231-233)
-- its stat block, and replaces lore that had copied the book's sentences.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~071-coalition-grunt-stat-block.sql
--
-- WHY. add-coalition-grunt-class.sql was made from printed 231-232 alone, the
-- lore and art pages, and said so in its extraction_notes. Later scripts
-- added its money, page range, group, race rule, tags and ladder, but no one
-- returned for the stats in the left column of printed 233. So the class
-- had no skills, related or secondary skills and no equipment, and its
-- ## Lore was the book's own text. Found 2026-10-02 by the drafter of Rifts
-- China 2's Geofront Chi Warrior ("same as the CS Grunt"), which was read off
-- the page instead. Read off a render of core-book cache p236 on 2026-10-03.
--
-- WHOLE-MARKDOWN REPLACE, because nearly every block is new. The new text
-- keeps every line the later scripts wrote (men_of_arms, occ_group,
-- race_restrictions, tags, xp_table, starting_money and its note). It sorts
-- after all of them: the ~ tier sorts after z, and the tilde number is
-- claimed at merge.
--
-- Guarded on the old note's own sentence, so a re-run, or a database that
-- already has the new text, changes nothing.

UPDATE imported_classes
SET markdown = '---
id: coalition-grunt
men_of_arms: true
occ_group: men-of-arms
race_restrictions:
  only: ["none", "mutant-psi-stalker"]
  note: "Racial Restrictions: Humans and Psi-Stalkers only, the latter being a human mutant (RUE p.230). In Rifts a human character takes no R.C.C., so \"none\" is the human case, and a Psi-Stalker is the mutant-psi-stalker race (BOOK-INGEST-AUDIT F110, taken 2026-09-27)."
name: Coalition Grunt
system: rifts
source_book: Rifts Ultimate Edition p.231-233
category: occ
tags: [combat, beginner]
xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]
starting_money: "1700 credits monthly salary"
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil or anarchist alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 92, per_level: 0, note: "American, at 92%." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0 }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%." }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%." }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed as Pilot: Hovercraft (+10%)." }
    - { name: "Military: Tanks & APCs", base: 50, per_level: 4, note: "Printed as Pilot: Tank & APCs (+14%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0 }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "+10%." }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (Ancient or Modern)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil or Anarchist alignment) at the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy & Navigation"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Carpentry", "Hunting", "Land Navigation"] }
    note: "Select seven other skills at level one, +1 at levels 2, 5, 9 and 12; all start at level one. Cowboy, Espionage and Horsemanship: none. Science: math skills and Astronomy & Navigation only."
    schedule:
      - { level: 2, count: 1 }
      - { level: 5, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 5
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "coalition-dead-boy-body-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"], note: "The book says of choice without enumerating; this is the catalog set the SAMAS Pilot uses." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-super-laser-pistol-and-grenade-launcher", "wilk-s-320-laser-pistol"], note: "The book says of choice without enumerating; this is the catalog set the SAMAS Pilot uses." }
  - { item_id: "e-clip", qty: 8, note: "Four extra E-Clips for each energy weapon." }
  - { item_id: "fragmentation-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "non-energy weapon of choice", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws", "ng-101-rail-gun"], note: "The book says of choice without enumerating; this is the catalog set the SAMAS Pilot uses." }
restrictions:
  - "Racial Restrictions: Humans and Psi-Stalkers only."
  - "Attribute Requirements: a high P.S. and P.E. are suggested but not required; the physical attributes may be no lower than seven (printed 233). Not enforced: the book does not list which attributes it counts as physical."
extraction_notes: |
  - Rifts Ultimate Edition printed 231-233 (core-book cache page_offset 3, so
    cache p234-p236). The O.C.C. stats are the left column of printed 233,
    read off a 110 dpi render on 2026-10-03. Until then this row held only
    the lore of printed 231-232: an earlier import was given those two pages
    and said so, and nobody returned for the stat block on 233.
  - Named skills store the catalog base plus the printed bonus. Pilot:
    Hovercraft is the catalog''s Hover Craft (ground); Pilot: Tank & APCs is
    Military: Tanks & APCs.
  - Equipment follows the SAMAS Pilot''s catalog choices for "of choice"
    items. The book prints four extra E-Clips for each energy weapon, stored
    as eight.
  - starting_money was added from printed 233 ("Monthly salary is 1700
    credits. Starts off with one month''s pay"), the samas-pilot salary
    convention (class audit F16; F17 extended the page range to match).
  - Cybernetics: none to start; usually restricted to medical implants and
    prosthetics. Prose, below.
  - The lore below is a paraphrase written 2026-10-03, replacing a section
    that had copied the book''s sentences.
---

## Lore

The Grunt is the Coalition Army''s ordinary infantry soldier, and in the Coalition States even the foot soldier is treated as one of the elite and a hero of the people. Grunts see themselves as patriots defending humankind against magic users, D-Bee invaders and monsters, and they fight those enemies without mercy. Most come from humble beginnings, often from the ''Burbs, and enlist hoping to move their families up the waiting list for citizenship inside a fortress city such as Chi-Town. Few arrive with much education; soldiering is what they learn, and many make a career of it.

Civilians call them Dead Boys, after the skull helmets, black armor and death''s-head insignia the Coalition chose deliberately to frighten its enemies.

## GM Notes

Money: a monthly salary of 1700 credits, starting with one month''s pay, plus room, board, clothing and access to military facilities; barracks are shared four to a dormitory, each with a private room.

Equipment available upon assignment (any weapon types, extra ammunition, hovercraft and hovercycles, tanks, jet packs, cameras, optics, rations, repairs) is issued as the commanding officer sees fit, which can be very limited for a soldier the officer dislikes.

Cybernetics: none to start, and usually restricted to medical implants and prosthetics, not augmentation.

Related O.C.C.s: many more Coalition military O.C.C.s are in Rifts World Book 11: Coalition War Campaign.
',
    updated_at = datetime('now')
WHERE class_id = 'coalition-grunt'
  AND instr(markdown, 'Only pages 231-232 were provided') > 0;

SELECT 'the Coalition Grunt carries its printed 233 stat block' AS assertion,
       count(*) AS got,
       1 AS want
  FROM imported_classes
 WHERE class_id = 'coalition-grunt' AND instr(markdown, 'read off a 110 dpi render on 2026-10-03') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~071-coalition-grunt-stat-block.sql');
