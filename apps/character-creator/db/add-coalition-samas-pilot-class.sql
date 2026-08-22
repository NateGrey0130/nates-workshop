-- The Coalition SAMAS Pilot O.C.C., Rifts Ultimate Edition p.233-235.
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/add-coalition-samas-pilot-class.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/add-coalition-samas-pilot-class.sql
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
SELECT 'coalition-samas-pilot', 'Coalition SAMAS Pilot', 'rifts', '---
id: coalition-samas-pilot
name: Coalition SAMAS Pilot
system: rifts
source_book: Rifts Ultimate Edition p.233-235
category: occ
attribute_requirements:
  IQ: 10
  PP: 10
starting_money: "2000 credits monthly salary"
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 94, per_level: 1, note: "American." }
    - { name: "Mathematics: Basic", base: 10, per_level: 5, note: "+10% bonus over base." }
    - { name: "Military Etiquette", base: 15, per_level: 5, note: "+15% bonus over base." }
    - { name: "Radio: Basic", base: 10, per_level: 5, note: "+10% bonus over base." }
    - { name: "Automobile", base: 15, per_level: 5, note: "+15% bonus over base." }
    - { name: "Hover Craft (ground)", base: 15, per_level: 5, note: "+15% bonus over base." }
    - { name: "Robots & Power Armor", base: 15, per_level: 5, note: "+15% bonus over base." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0 }
    - { name: "Robot Combat Elite: SAMAS", base: 0, per_level: 0 }
    - { name: "Sensory Equipment", base: 15, per_level: 5, note: "+15% bonus over base." }
    - { name: "Weapon Systems", base: 15, per_level: 5, note: "+15% bonus over base." }
    - { name: "Running", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Pilot"], bonus: 15, note: "Pilot: Any, +15%." }
    - { choose: 1, categories: ["Pilot Related"], bonus: 10, note: "Pilot Related: Any, +10%." }
    - { name: "Streetwise", base: 20, per_level: 4, note: "Streetwise only." }
    - { choose: 1, categories: ["Science"], note: "Math and Astronomy & Navigation skills only." }
    - { choose: 1, categories: ["Technical"], note: "Any." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "Any." }
    - { choose: 1, categories: ["Wilderness"], note: "Land Navigation, Hunting and Wilderness Survival only." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One of choice (Ancient or Modern)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts (or Assassin, if an evil or Anarchist alignment) for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 8
    categories:
      - Communications
      - Domestic
      - Electrical
      - Military
      - Physical
      - Pilot
    note: "Select eight other skills at level one, +2 additional at levels 3, 6, 9 and 12. Communications: Any (+10%). Domestic: Any (-5% penalty). Electrical: Basic Electronics only (+5%). Military: Any (+10%). Physical: Any, except Acrobatics."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "coalition-dead-boy-body-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ja-11-juicer-assassin-s-energy-rifle", "ja-9-juicer-assassin-variable-laser-rifle", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "wilk-s-447-laser-rifle"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["c-18-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-super-laser-pistol-and-grenade-launcher", "wilk-s-320-laser-pistol"] , note: "The book says "of choice" without enumerating; this is the catalog set, widened as more books are imported." }
  - { item_id: "e-clip", qty: 4 }
  - { item_id: "fragmentation-grenade", qty: 2 }
  - { item_id: "smoke-grenade", qty: 3 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter-and-gas-mask", qty: 1 }
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
  - Class spans pages 233 (intro/subtitle) through 235 (Coalition Elite RPA
    O.C.C. Stats continued from page 234 art page). The O.C.C. Skills list is
    reconstructed by reading page 233 bottom (Alignment/Attribute
    Requirements/Racial Restrictions/O.C.C. Skills start) then continuing
    through page 234 (which is dominated by an illustration, with two columns
    of skill text below it) and concluding at the top of page 235 with
    Secondary Skills through Related O.C.C.s.
  - Standard Equipment list specifies choices ("energy rifle and energy
    sidearm of choice," "additional non-energy weapon of choice") without
    naming specific catalog options anywhere on these pages, so `from` lists
    are left empty pending a proper equipment catalog cross-reference.
  - Money: "Monthly salary is 2000 credits." Recorded verbatim as
    starting_money though it is income, not a lump starting sum; the book
    also grants one month''s pay plus free room/board/clothing/facility access,
    which is prose only (see GM Notes).
  - Cybernetics note ("None to start and usually restricted to medical
    implants and prosthetics, not augmentation") and "Related O.C.C.s" pointer
    to Rifts World Book 11: Coalition War Campaign are prose-only per schema
    and placed in GM Notes.
  - Equipment Available Upon Assignment section (vehicles, weapons, gear
    subject to CO discretion) is situational/GM-facing, not fixed starting
    gear, and is recorded in GM Notes rather than equipment_starting.
---

## Lore

The SAMAS is the Coalition''s standard-issue Robot Power Armor (RPA) used for field operations and urban defense, and it is the signature weapon and identity of the Coalition Elite RPA pilot. These men and women are the ones behind the terrifying visage of the SAMAS, Sky Cycles, Enforcer UAR-1s, and Spider-Skull Walkers ' || char(8212) || ' specially trained pilots and experts in the use of power armor and robot combat vehicles. While the SAMAS is their chief assignment and weapon, all other power armor or robot piloting duties are secondary, with the specific ''bot or power armor made available depending on the mission.

## GM Notes

Equipment Available Upon Assignment includes SAMAS power armor, Spider-Skull Walker, other robot vehicles, hovercraft, sky cycle, jet pack, tank, APC, Death''s Head Transport, and aircraft, plus any weapon types, extra ammunition, camera, disc recorder, optical enhancement, and food rations for weeks, with vehicle and equipment repair available. All weapons and equipment are given out on an as-needed basis, with the commanding officer deciding whether the item(s) are really necessary ' || char(8212) || ' an officer who dislikes the character(s) may extremely limit availability.

Money: the elite pilot starts with one month''s pay (2000 credits), plus a roof over his head, food, clothing, and other basics as part of his service, plus access to military facilities. Quarters are a nice dormitory arrangement shared by four individuals, each with a private bedroom/study complete with CD stereo system, television, digital video-disc recorder, mini-refrigerator, desk, dresser, and comfortable bed.

Cybernetics: none to start, and usually restricted to medical implants and prosthetics, not augmentation.

Related O.C.C.s: many additional human Coalition military O.C.C.s can be found in Rifts World Book 11: Coalition War Campaign.', 'published', 'data-script'
WHERE NOT EXISTS (SELECT 1 FROM imported_classes WHERE class_id = 'coalition-samas-pilot');

-- Read the result back rather than trusting the exit code.
SELECT class_id, name, status, length(markdown) AS bytes, instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'coalition-samas-pilot';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('add-coalition-samas-pilot-class.sql');
