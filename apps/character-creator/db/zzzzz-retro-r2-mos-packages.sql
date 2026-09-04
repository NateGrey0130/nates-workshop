-- RETRO-AUDIT R2: the demon-goblin and the monk get the MOS the schema can
-- already hold.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r2-mos-packages.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r2-mos-packages.sql
--
-- Rifts Dimension Book 1: Wormwood. The demon-goblin printed 123-124, the monk
-- printed 60-61. The ww cache has a ZERO page offset, so printed N is cache
-- pNNN - read out of scripts/books.json rather than assumed, because +1 is the
-- commonest offset and assuming it here would have read the wrong pages.
--
-- WHAT WAS WRONG. Both classes carried a note IN CAPITALS saying the app cannot
-- grant skills conditionally on a choice:
--
--   demon-goblin: "THE BOOK GIVES THREE COMPLETE SKILL PACKAGES - assassin,
--   thief and spy - AND THE APP CANNOT GRANT SKILLS CONDITIONALLY ON A CHOICE."
--   monk: "THE AREA OF MASTERY GRANTS SKILLS, AND THE APP CANNOT GRANT THEM
--   CONDITIONALLY."
--
-- Both were true when written and stopped being true when skills.mos landed
-- (migration 031-character-mos.sql, 2026-08-21). This is the SAME defect
-- fix-merc-soldier-and-robot-pilot-mos.sql closed for two other classes, and
-- the third instance of the shape the claim-audit skill's table records.
--
-- BASES ARE CATALOG BASE PLUS THE PRINTED BONUS, per the class-import rules -
-- EXCEPT the languages. This book prints those as absolute percentages
-- ("Dragonese and American at 55%"), not as bonuses, so they are stored as
-- printed. Book names resolving to a different catalog spelling each carry a
-- note saying so: swim is Swimming, tracking (humans) is Tracking (people),
-- basic math is Mathematics: Basic, escape is Escape Artist.
--
-- THE DEMON-GOBLIN'S SHARED SKILLS MOVE INTO THE OPTIONS. Land Navigation,
-- Prowl, Palming, Climbing, Streetwise and the two languages sat in occ_skills
-- at their CATALOG BASE with NO bonus applied, under a note saying the bonus
-- "differs and is recorded on each" - so every demon-goblin was short every one
-- of those bonuses. Each profession's printed bonus is now applied on its own
-- option. Leaving them in occ_skills as well would DOUBLE them: applyMos()
-- appends to occ_skills rather than merging.
--
-- That move is safe because the server REFUSES to save a character who has not
-- chosen an MOS (validate-character.js, rule 'mos_unchosen'), so the class
-- cannot be held without a profession - and production holds ZERO demon-goblin
-- and monk characters today, checked before writing this.
--
-- WHAT STILL WILL NOT FIT is on each mos note rather than dropped: the open
-- weapon-proficiency picks, the spy's extra language of choice, and the
-- assassin's "+5% on all acrobatic skills", which needs the per-skill modifier
-- CLASS-AUDIT's "Checked and still true" list records as absent.

-- ---- demon-goblin: three R.C.C. skill packages ---------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       '  occ_skills:
    - { name: "Language: Demongogian", base: 94, per_level: 5, note: "94%" }
    - { name: "Language: Gobblely", base: 94, per_level: 5, note: "94%" }
    - { name: "Language: Dragonese", base: 55, per_level: 5, note: "55% for an assassin, 50% for a thief, 70% for a spy - the assassin''s figure is stored and the other two are on their own abilities." }
    - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American, at 55% for an assassin, 50% for a thief and 70% for a spy." }
    - { name: "Land Navigation", base: 36, per_level: 4, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Prowl", base: 25, per_level: 5, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Palming", base: 20, per_level: 5, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Climbing", base: 40, per_level: 5, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "Streetwise", base: 20, per_level: 4, note: "Every profession has it; the bonus differs and is recorded on each." }
    - { name: "W.P. Knife" }',
       '  occ_skills:
    - { name: "Language: Demongogian", base: 94, per_level: 5, note: "94% for all three professions." }
    - { name: "Language: Gobblely", base: 94, per_level: 5, note: "94% for all three professions." }
    - { name: "W.P. Knife", note: "All three professions have it." }
  mos:
    choose: 1
    note: "The book gives three complete R.C.C. skill packages - assassin, thief and spy - and every demon-goblin is one of them. Printed 123-124. Each option''s skills are granted in addition to the three above, which are the only ones identical across all three professions. NOT EXPRESSIBLE HERE and deliberately left in this note rather than dropped: the open weapon-proficiency picks (the book''s ''one modern W.P. of choice and one W.P. from any category'' for the assassin, ''one W.P. of choice'' for the thief, ''two W.P.s of choice'' for the spy), the spy''s one additional language of choice, and the assassin''s +5% to all acrobatic skills, which needs the per-skill modifier CLASS-AUDIT records as absent."
    options:
      - id: "assassin"
        name: "Assassin"
        skills:
            - { name: "Wilderness Survival", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
            - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
            - { name: "Palming", base: 20, per_level: 5, note: "No bonus printed." }
            - { name: "Streetwise", base: 24, per_level: 4, note: "+4%" }
            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
            - { name: "Swimming", base: 50, per_level: 5, note: "No bonus printed. The book prints swim." }
            - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. The book prints tracking (humans)." }
            - { name: "Sniper", base: 0, per_level: 0, note: "The book prints +2 to strike on an aimed shot; the catalog row carries that." }
            - { name: "W.P. Sword" }
            - { name: "W.P. Targeting", note: "The book prints throwing knife, sling, short bow." }
            - { name: "Language: Dragonese", base: 55, per_level: 5, note: "55% for an assassin - printed as an absolute, not a bonus." }
            - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American at 55% for an assassin." }
      - id: "thief"
        name: "Thief"
        skills:
            - { name: "Dance", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%. The book prints basic math." }
            - { name: "Wilderness Survival", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
            - { name: "Prowl", base: 30, per_level: 5, note: "+5%" }
            - { name: "Concealment", base: 30, per_level: 4, note: "+10%" }
            - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
            - { name: "Pick Locks", base: 40, per_level: 5, note: "+10%" }
            - { name: "Pick Pockets", base: 35, per_level: 5, note: "+10%" }
            - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
            - { name: "Streetwise", base: 26, per_level: 4, note: "+6%" }
            - { name: "Swimming", base: 55, per_level: 5, note: "+5%. The book prints swim." }
            - { name: "W.P. Sword" }
            - { name: "Language: Dragonese", base: 50, per_level: 5, note: "50% for a thief - printed as an absolute, not a bonus." }
            - { name: "Language: Native Tongue", base: 50, per_level: 0, note: "The book prints American at 50% for a thief." }
      - id: "spy"
        name: "Spy"
        skills:
            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape artist." }
            - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
            - { name: "Art", base: 40, per_level: 5, note: "+5%" }
            - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%. The book prints basic math." }
            - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
            - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
            - { name: "Concealment", base: 25, per_level: 4, note: "+5%" }
            - { name: "Palming", base: 25, per_level: 5, note: "+5%" }
            - { name: "Pick Locks", base: 35, per_level: 5, note: "+5%" }
            - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
            - { name: "Streetwise", base: 28, per_level: 4, note: "+8%" }
            - { name: "Language: Dragonese", base: 70, per_level: 5, note: "70% for a spy - printed as an absolute, not a bonus." }
            - { name: "Language: Native Tongue", base: 70, per_level: 0, note: "The book prints American at 70% for a spy." }')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'Every profession has it; the bonus differs') > 0;

-- ---- demon-goblin: the note that said this was impossible ----------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       'THE BOOK GIVES THREE COMPLETE SKILL PACKAGES - assassin, thief and spy - AND THE APP CANNOT GRANT SKILLS CONDITIONALLY ON A CHOICE. The eight skills all three share are granted outright AT THEIR CATALOG BASE, because each profession prints a different bonus on them (prowl +10/+5/+10, climbing +10/+5/+5, land navigation +10/+5/+10, streetwise +4/+6/+8) and there is no honest single number. Each profession''s full list and exact percentages are on its own ability, to be applied by hand.',
       'THE BOOK GIVES THREE COMPLETE SKILL PACKAGES - assassin, thief and spy - and the app GRANTS THEM, as skills.mos. This note said it could not until RETRO-AUDIT R2 (2026-09-04); skills.mos landed in migration 031-character-mos.sql on 2026-08-21, and the same correction was made for the Merc Soldier and the Robot Pilot in fix-merc-soldier-and-robot-pilot-mos.sql. The shared skills used to be granted outright AT THEIR CATALOG BASE, with every profession''s bonus dropped, because each profession prints a different one (prowl +10/+5/+10, climbing +10/+5/+5, land navigation +10/+5/+10, streetwise +4/+6/+8) and one column cannot hold three numbers. Each now sits on its own mos option carrying its own bonus, so no demon-goblin is short them any more. Only Demongogian, Gobblely and W.P. Knife are identical across all three and stay in occ_skills.')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'AND THE APP CANNOT GRANT SKILLS CONDITIONALLY ON A CHOICE') > 0;

-- ---- monk: the three Areas of Mastery ------------------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       '    - { name: "Hand to Hand: Martial Arts", note: "See the area of Mastery for W.P.s and the specific combat skills." }',
       '    - { name: "Hand to Hand: Martial Arts", note: "The combat techniques an Area of Mastery adds are on its own ability; the skills it grants are in the mos block below." }
  mos:
    choose: 1
    note: "Powers of Mastery, printed 60-61: ''Select only ONE of the three available areas of focus and study.'' These are the ADDITIONAL SKILLS each area grants; its combat techniques, bonuses and superhuman abilities stay on the ability of the same name, because they are not skills. NOT EXPRESSIBLE HERE and left in this note: the open weapon-proficiency picks each area grants alongside them - two for Defense, four for Offense, two for Meditation, all ''of choice from any category''. The occ_related_skills block above already excludes Acrobatics, Gymnastics and Boxing from the Physical category, so a monk cannot take one of these twice."
    options:
      - id: "defense"
        name: "The Art of Defense"
        skills:
            - { name: "Gymnastics", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Running", base: 0, per_level: 0, note: "No percentage - a physical skill with no roll." }
            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }
      - id: "offense"
        name: "The Arts of Offense"
        skills:
            - { name: "Acrobatics", base: 30, per_level: 5, note: "No bonus printed." }
            - { name: "Boxing", base: 0, per_level: 0, note: "No percentage - what it grants is bonuses." }
            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }
      - id: "meditation"
        name: "The Art of Meditation & Spirit"
        skills:
            - { name: "Art", base: 45, per_level: 5, note: "+10%" }
            - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }
            - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
            - { name: "Concealment", base: 30, per_level: 4, note: "+10%" }
            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }')
 WHERE class_id = 'monk'
   AND instr(markdown, 'See the area of Mastery for W.P.s') > 0;

-- ---- monk: the two sentences that said this was impossible ---------------
UPDATE imported_classes
   SET markdown = replace(replace(markdown,
       'THE AREA OF MASTERY GRANTS SKILLS, AND THE APP CANNOT GRANT THEM CONDITIONALLY.',
       'THE AREA OF MASTERY GRANTS SKILLS, AND THE APP GRANTS THEM, as skills.mos. This note said it could not until RETRO-AUDIT R2 (2026-09-04); skills.mos landed in migration 031-character-mos.sql on 2026-08-21.'),
       'special_abilities carries the descriptions and the flat bonuses, but the skills are recorded in prose and have to be added by hand.',
       'special_abilities carries the descriptions and the flat bonuses, which are not skills and stay there; the SKILLS each area adds are in the mos block and are granted on the pick. They used to be prose and added by hand.')
 WHERE class_id = 'monk'
   AND instr(markdown, 'AND THE APP CANNOT GRANT THEM CONDITIONALLY') > 0;


-- ---- readbacks -----------------------------------------------------------
SELECT 'both classes now carry an mos block' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('demon-goblin', 'monk')
   AND instr(markdown, '  mos:') > 0 AND deleted_at IS NULL;

SELECT 'demon-goblin offers three professions' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'id: "assassin"') > 0
   AND instr(markdown, 'id: "thief"') > 0
   AND instr(markdown, 'id: "spy"') > 0;

SELECT 'monk offers three areas of mastery' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'monk'
   AND instr(markdown, 'id: "defense"') > 0
   AND instr(markdown, 'id: "offense"') > 0
   AND instr(markdown, 'id: "meditation"') > 0;

-- Classes carrying an mos block went from three to five. Matched on the
-- INDENTED YAML key so prose mentions of the word elsewhere do not count.
SELECT 'published classes carrying an mos block' AS assertion,
       count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE instr(markdown, '  mos:') > 0 AND status = 'published' AND deleted_at IS NULL;

-- No shared skill is left in the demon-goblin's occ_skills, where applyMos()
-- would append a second copy on top of it.
SELECT 'demon-goblin shared skills no longer duplicated' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'Every profession has it; the bonus differs') > 0;


-- No capitalised impossibility claim survives in either class.
SELECT 'neither class still says the app cannot grant these' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('demon-goblin', 'monk')
   AND (instr(markdown, 'CANNOT GRANT SKILLS CONDITIONALLY') > 0
     OR instr(markdown, 'CANNOT GRANT THEM CONDITIONALLY') > 0
     OR instr(markdown, 'have to be added by hand') > 0);

-- Records this run. Both statements guard themselves on the text they replace,
-- so this script is safe to re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r2-mos-packages.sql');
