-- Corrects the Coalition SAMAS Pilot O.C.C. against Rifts Ultimate Edition
-- printed 233-235, re-read off renders (core-book cache p236-p238).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~072-coalition-samas-pilot-against-its-page.sql
--
-- WHAT WAS WRONG, each confirmed on the render on 2026-10-03 (reported
-- 2026-10-02 by the drafter of Rifts China 2's Geofront Metal Warrior):
--   1. Attribute requirements. The page prints I.Q. 10 and P.P. 10.
--      fix-rue-attr-reqs-and-ranges.sql (class audit F17) replaced those with
--      I.Q. 12, M.E. 12, P.E. 10, quoting printed 235 - but those are the CS
--      Military Specialist's, whose stats open in 235's right column. The
--      original values were right, and that fix introduced the error.
--   2. The Pilot, Pilot Related, Rogue, Science, Technical, W.P. and
--      Wilderness lines were filed as O.C.C. Skill picks. They are O.C.C.
--      Related categories (printed 234-235).
--   3. The Mechanical (Aircraft, Automotive and Basic, +10%) and Medical
--      (First Aid) related lines were missing.
--   4. Secondary Skills (four, +1 at levels 4, 8, 12 and 15) were missing.
--   5. Equipment: the page prints two grenades and no smoke grenades, and
--      four E-Clips for each energy weapon (eight, not four).
-- The lore is also rewritten as a paraphrase, and the stale extraction notes
-- are replaced.
--
-- WHOLE-MARKDOWN REPLACE, keeping every other line as production holds it.
-- It sorts after fix-rue-attr-reqs-and-ranges.sql and every later writer of
-- this row (the ~ tier sorts after z; the number is claimed at merge).
--
-- Guarded on the wrong requirements, so a re-run changes nothing.

UPDATE imported_classes
SET markdown = '---
id: coalition-samas-pilot
men_of_arms: true
occ_group: men-of-arms
race_restrictions:
  only: ["none"]
  note: "Racial Restrictions: Human. In Rifts a human character takes no R.C.C., so "none" is the human case. RUE p.233."
name: Coalition SAMAS Pilot
system: rifts
source_book: Rifts Ultimate Edition p.233-235
category: occ
tags: [combat, pilot]
xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]
attribute_requirements:
  IQ: 10
  PP: 10
starting_money: "2000 credits monthly salary"
skills:
  hand_to_hand: { costs: { martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil or anarchist alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 94, per_level: 1, note: "American." }
    - { name: "Mathematics: Basic", bonus: 10, note: "+10% bonus over base." }
    - { name: "Military Etiquette", bonus: 15, note: "+15% bonus over base." }
    - { name: "Radio: Basic", bonus: 10, note: "+10% bonus over base." }
    - { name: "Automobile", bonus: 15, note: "+15% bonus over base." }
    - { name: "Hover Craft (ground)", bonus: 15, note: "+15% bonus over base." }
    - { name: "Robots & Power Armor", bonus: 15, note: "+15% bonus over base." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0 }
    - { name: "Robot Combat Elite: SAMAS", base: 0, per_level: 0 }
    - { name: "Sensory Equipment", bonus: 15, note: "+15% bonus over base." }
    - { name: "Weapon Systems", bonus: 15, note: "+15% bonus over base." }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice (Ancient or Modern)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil or Anarchist alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: -5 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Mechanical", only: ["Aircraft Mechanics", "Automotive Mechanics", "Basic Mechanics"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 15 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy & Navigation"] }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Hunting", "Wilderness Survival"] }
    note: "Select eight other skills at level one, +2 additional at levels 3, 6, 9 and 12. Cowboy, Espionage and Horsemanship: none. Domestic carries a -5% penalty. Science: math skills and Astronomy & Navigation only."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 4
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
equipment_starting:
  - { item_id: "coalition-dead-boy-body-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-super-laser-pistol-and-grenade-launcher", "wilk-s-320-laser-pistol"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { item_id: "e-clip", qty: 8, note: "Four extra E-Clips for each energy weapon." }
  - { item_id: "fragmentation-grenade", qty: 2, note: "Printed as two grenades." }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "non-energy weapon of choice", qty: 1, from: ["vibro-knife", "vibro-sword", "vibro-saber", "vibro-claws", "ng-101-rail-gun"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { choose: 1, label: "conventional military vehicle for daily use", qty: 1, from: ["hovercycle", "jeep"] }
  - { item_id: "samas-power-armor", qty: 1, note: "For field use only." }
restrictions:
  - "Racial Restrictions: Human only."
extraction_notes: |
  - Rifts Ultimate Edition printed 233-235 (core-book cache page_offset 3, so
    cache p236-p238), re-read off renders on 2026-10-03. The stats begin at
    the foot of printed 233''s right column under Coalition Elite RPA O.C.C.
    Stats, continue below the art on 234, and end in 235''s left column.
  - Corrected 2026-10-03 against those renders: attribute requirements are
    I.Q. 10 and P.P. 10 (printed 233); the I.Q. 12 / M.E. 12 / P.E. 10 an
    earlier fix (fix-rue-attr-reqs-and-ranges.sql, class audit F17) wrote here
    are the CS Military Specialist''s, printed 235. The Pilot, Pilot Related,
    Rogue, Science, Technical, W.P. and Wilderness lines are O.C.C. Related
    categories, not O.C.C. Skill picks; Mechanical (Aircraft, Automotive and
    Basic, +10%) and Medical (First Aid) were missing; Secondary Skills (four,
    +1 at levels 4, 8, 12 and 15) were missing; the equipment prints two
    grenades and no smoke grenades, and four E-Clips for each energy weapon.
  - "Of choice" equipment is the catalog set named in each choice''s note.
  - Money: "Monthly salary is 2000 credits," stored as starting_money though
    it is income; one month''s pay, room, board and facilities are prose.
  - Cybernetics, equipment available on assignment and the pointer to Rifts
    World Book 11 are prose, in GM Notes.
---

## Lore

The SAMAS Pilot is the Coalition''s elite robot and power armor pilot, the soldier inside the SAMAS flying power armor that is the army''s standard machine for field operations and urban defense. The same pilots also crew the Sky Cycles, Enforcer robots and Spider-Skull Walkers, though any machine other than the SAMAS is a secondary assignment that depends on the mission.

## GM Notes

Equipment Available Upon Assignment includes SAMAS power armor, Spider-Skull Walker, other robot vehicles, hovercraft, sky cycle, jet pack, tank, APC, Death''s Head Transport, and aircraft, plus any weapon types, extra ammunition, camera, disc recorder, optical enhancement, and food rations for weeks, with vehicle and equipment repair available. All weapons and equipment are given out on an as-needed basis, with the commanding officer deciding whether the item(s) are really necessary - an officer who dislikes the character(s) may extremely limit availability.

Money: the elite pilot starts with one month''s pay (2000 credits), plus a roof over his head, food, clothing, and other basics as part of his service, plus access to military facilities. Quarters are a nice dormitory arrangement shared by four individuals, each with a private bedroom/study complete with CD stereo system, television, digital video-disc recorder, mini-refrigerator, desk, dresser, and comfortable bed.

Cybernetics: none to start, and usually restricted to medical implants and prosthetics, not augmentation.

Related O.C.C.s: many additional human Coalition military O.C.C.s can be found in Rifts World Book 11: Coalition War Campaign.',
    updated_at = datetime('now')
WHERE class_id = 'coalition-samas-pilot'
  AND instr(markdown, '  IQ: 12' || char(10) || '  ME: 12' || char(10) || '  PE: 10') > 0;

SELECT 'the SAMAS Pilot carries its printed 233-235 values' AS assertion,
       count(*) AS got,
       1 AS want
  FROM imported_classes
 WHERE class_id = 'coalition-samas-pilot' AND instr(markdown, 're-read off renders on 2026-10-03') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~072-coalition-samas-pilot-against-its-page.sql');
