-- The NGR Robot Soldier gets the skill programs its book gives it.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-ngr-robot-soldier-skill-programs.sql
--
-- BOOK-INGEST-AUDIT.md F23(b), taken as written. This class shipped with NO
-- skills block at all - no occ_skills, no occ_related_skills, no
-- secondary_skills - the only published O.C.C. in that state, because both of
-- the ways its book gives it skills were shapes the app did not have. One of
-- them exists now.
--
-- PRINTED 170: "Base skill: 38%; no bonuses or improvement with experience.
-- Penalty: The task takes 1D4 times longer" and "As many as three skill
-- programs/categories can be selected." A program grants EVERY skill its
-- category allows, so this is a choice of CATEGORIES, not of skills.
--
-- THIRTEEN CATEGORIES ARE OFFERED AND THE BOOK PRINTS FOURTEEN LINES. The
-- fourteenth is "Rogue: None", which is a refusal rather than an offer, so
-- Rogue is absent here rather than present and empty. The proposal that
-- preceded this script said twelve and included Rogue; it was wrong on both
-- counts, and the correction is recorded in F23(b)'s outcome note.
--
-- W.P. IS PRINTED AS "All Modern" AND THE WHOLE CATEGORY IS OFFERED. The
-- catalog does not mark a W.P. ancient or modern, and CLASS-AUDIT.md records
-- that the ancient/modern splits ride in notes - the Crazy, the Burster and
-- both Elemental Fusionists all grant the whole category and say so in prose.
-- This follows that convention rather than inventing a per-row flag, and the
-- block's note tells the player and the G.M. what the book actually allows.
-- It is the one place this grant is wider than the page.
--
-- THE PILOT LINE NEEDS BOTH FORMS AT ONCE and could not be written before
-- this finding: "All, except pilot robots & power armor and robot combat" is
-- one exact name (Robots & Power Armor) and one FAMILY (13 Robot Combat rows,
-- nine of which this very book added). Enumerating the family would rot on
-- contact, so the entry carries except AND except_prefix together.
--
-- Guarded on the result being absent as well as the anchor being present. The
-- anchor is a line the replacement KEEPS, so a guard on the anchor alone stays
-- true afterwards and a second run would insert the block twice - which is
-- exactly what happened to the F24 script before it was caught by a readback
-- that counted.

UPDATE imported_classes
   SET markdown = replace(markdown, '
bonuses:', '
skills:
  skill_programs:
    choose: 3
    base: 38
    per_level: 0
    note: "Printed 170. Choose up to three; each grants EVERY skill it lists at a flat 38% with no bonuses and no gain per level, and every task takes 1D4 times longer. Rogue is offered as None by the book and is not listed. W.P. is printed as ''All Modern'': the whole Weapon Proficiencies category is offered because the catalog does not mark a W.P. ancient or modern - the same convention the Crazy, the Burster and both Elemental Fusionists use - so a G.M. should hold the player to modern W.P.s only."
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics", "Computer Repair"] }
      - { name: "Espionage", only: ["Tracking (people)", "Intelligence", "Wilderness Survival"] }
      - { name: "Mechanical", except: ["Mechanical Engineer", "Robot Mechanics"] }
      - { name: "Medical", only: ["Paramedic", "Forensics"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling", "Prowl"] }
      - { name: "Pilot", except: ["Robots & Power Armor"], except_prefix: ["Robot Combat"] }
      - "Science"
      - { name: "Technical", except_prefix: ["Lore"] }
      - "Weapon Proficiencies"
      - "Wilderness"
bonuses:')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, '
bonuses:') > 0
   AND instr(markdown, '
skills:
  skill_programs:
    choose: 3
    base: 38
    per_level: 0
    note: "Printed 170. Choose up to three; each grants EVERY skill it lists at a flat 38% with no bonuses and no gain per level, and every task takes 1D4 times longer. Rogue is offered as None by the book and is not listed. W.P. is printed as ''All Modern'': the whole Weapon Proficiencies category is offered because the catalog does not mark a W.P. ancient or modern - the same convention the Crazy, the Burster and both Elemental Fusionists use - so a G.M. should hold the player to modern W.P.s only."
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics", "Computer Repair"] }
      - { name: "Espionage", only: ["Tracking (people)", "Intelligence", "Wilderness Survival"] }
      - { name: "Mechanical", except: ["Mechanical Engineer", "Robot Mechanics"] }
      - { name: "Medical", only: ["Paramedic", "Forensics"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling", "Prowl"] }
      - { name: "Pilot", except: ["Robots & Power Armor"], except_prefix: ["Robot Combat"] }
      - "Science"
      - { name: "Technical", except_prefix: ["Lore"] }
      - "Weapon Proficiencies"
      - "Wilderness"
bonuses:') = 0;

-- Read the result back rather than trusting the exit code.
SELECT 'the class now carries a skill_programs block' AS assertion,
       instr(markdown, 'skill_programs:') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

SELECT 'exactly one of them' AS assertion,
       (length(markdown) - length(replace(markdown, 'skill_programs:', '')))
         / length('skill_programs:') AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

SELECT 'thirteen categories are offered' AS assertion,
       (length(markdown) - length(replace(markdown, char(10) || '      - ', '')))
         / length(char(10) || '      - ') AS got, 13 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

SELECT 'and Rogue is NOT one of them, because the book prints Rogue: None' AS assertion,
       instr(markdown, '- ''Rogue''') + instr(markdown, '- "Rogue"') AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ngr-robot-soldier-skill-programs.sql');
