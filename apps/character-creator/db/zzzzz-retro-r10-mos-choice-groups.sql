-- RETRO-AUDIT R10: the weapon-proficiency picks R2 said were not expressible.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r10-mos-choice-groups.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r10-mos-choice-groups.sql
--
-- WHAT WAS WRONG, AND IT WAS WRONG IN THIS MENU'S OWN WORK. RETRO-AUDIT R2
-- (PR #714, applied 2026-09-04) gave the demon-goblin and the monk their MOS
-- packages and wrote on both mos blocks: "NOT EXPRESSIBLE HERE ... the open
-- weapon-proficiency picks". That is false, and it was false when it was
-- written.
--
-- An MOS option's `skills` list is validated by validateSkillEntries, whose own
-- header says: "occ_skills uses it and so does every MOS option, because a book
-- that says 'gain all skills under that MOS' is describing the same list in a
-- smaller box." isChoiceGroup admits `categories`, and js/parser.js documents
-- that form as "when the book says 'any N skills from <category>'". "Weapon
-- Proficiencies" is a real catalog category with 34 rows, and eleven-plus
-- published classes already use that literal group in occ_skills.
--
-- SO THE CLASSES WERE SHORT. A monk who took the Arts of Offense was FOUR
-- weapon proficiencies short of what the book grants him; Defense and Meditation
-- two each; the demon-goblin's assassin two, its thief one, its spy two plus a
-- language. R2 granted the named skills and left the counted picks in a note
-- saying they could not be granted.
--
-- Found by the claim re-sweep on 2026-09-04, which re-read R2's own note as a
-- claim and disagreed with it. The first sweep never saw it: R2's note did not
-- exist yet.
--
-- WHAT STILL WILL NOT FIT, and it is smaller than R2 claimed:
--   * The assassin's "+5% on all acrobatic skills". Still true, and checked
--     rather than assumed: the assassin package grants no acrobatic skill at
--     all, so this is a modifier on skills obtained elsewhere - the race-level
--     per-skill modifier CLASS-AUDIT's "Checked and still true" list records as
--     absent.
--   * "One MODERN W.P. of choice" (the assassin) and "including modern weapons"
--     (the thief). The catalog does not divide Weapon Proficiencies into ancient
--     and modern, so the group is broader than the book by that much. Stated on
--     the option rather than used as a reason to grant nothing, which is the
--     mistake this script exists to undo.

-- ---- monk: two, four and two W.P.s of choice -----------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
'            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }
      - id: "offense"',
'            - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. The book prints escape." }
            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two weapon proficiencies of choice from any category." }
      - id: "offense"')
 WHERE class_id = 'monk'
   AND instr(markdown, 'choose: 2, categories: ["Weapon Proficiencies"]') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
'            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }',
'            - { name: "W.P. Targeting", note: "The book prints W.P. targeting (all)." }
            - { choose: 4, categories: ["Weapon Proficiencies"], note: "The book: four weapon proficiencies of choice from any category." }')
 WHERE class_id = 'monk'
   AND instr(markdown, 'choose: 4, categories: ["Weapon Proficiencies"]') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
'            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }',
'            - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two weapon proficiencies of choice from any category." }')
 WHERE class_id = 'monk'
   AND instr(markdown, 'name: "Climbing", base: 50, per_level: 5, note: "+10%" }' || char(10) || '            - { choose: 2') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'NOT EXPRESSIBLE HERE and left in this note: the open weapon-proficiency picks each area grants alongside them - two for Defense, four for Offense, two for Meditation, all ''of choice from any category''.',
       'The open weapon-proficiency picks each area grants - two for Defense, four for Offense, two for Meditation - are choice groups over the Weapon Proficiencies category, added by RETRO-AUDIT R10 (2026-09-04). This note said they were not expressible, which was false when R2 wrote it: an MOS option takes the same skill entries occ_skills does, choice groups included.')
 WHERE class_id = 'monk'
   AND instr(markdown, 'NOT EXPRESSIBLE HERE and left in this note') > 0;

-- ---- demon-goblin: the assassin's two, thief's one, spy's two + language ---
UPDATE imported_classes
   SET markdown = replace(markdown,
'            - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American at 55% for an assassin." }',
'            - { name: "Language: Native Tongue", base: 55, per_level: 0, note: "The book prints American at 55% for an assassin." }
            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: one MODERN W.P. of choice and one W.P. from any category. The catalog does not divide W.P.s into ancient and modern, so this group is broader than the book by that much." }')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'one MODERN W.P. of choice and one W.P. from any category') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
'            - { name: "Language: Native Tongue", base: 50, per_level: 0, note: "The book prints American at 50% for a thief." }',
'            - { name: "Language: Native Tongue", base: 50, per_level: 0, note: "The book prints American at 50% for a thief." }
            - { choose: 1, categories: ["Weapon Proficiencies"], note: "The book: one W.P. of choice, including modern weapons. The catalog does not divide W.P.s into ancient and modern." }')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'one W.P. of choice, including modern weapons') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
'            - { name: "Language: Native Tongue", base: 70, per_level: 0, note: "The book prints American at 70% for a spy." }',
'            - { name: "Language: Native Tongue", base: 70, per_level: 0, note: "The book prints American at 70% for a spy." }
            - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: two W.P.s of choice, any category." }
            - { choose: 1, from: ["Language: Other"], note: "The book: one additional language of choice. Language: Other is the repeatable catalog row for a language the books never print." }')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'two W.P.s of choice, any category') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'NOT EXPRESSIBLE HERE and deliberately left in this note rather than dropped: the open weapon-proficiency picks (the book''s ''one modern W.P. of choice and one W.P. from any category'' for the assassin, ''one W.P. of choice'' for the thief, ''two W.P.s of choice'' for the spy), the spy''s one additional language of choice, and the assassin''s +5% to all acrobatic skills, which needs the per-skill modifier CLASS-AUDIT records as absent.',
       'The open weapon-proficiency picks and the spy''s extra language are choice groups on each option, added by RETRO-AUDIT R10 (2026-09-04). This note said they were not expressible, which was false when R2 wrote it. STILL not expressible, and checked rather than assumed: the assassin''s +5% to all acrobatic skills, because the package grants no acrobatic skill at all, so it modifies skills obtained elsewhere - the per-skill modifier CLASS-AUDIT records as absent. The catalog also does not divide W.P.s into ancient and modern, so the assassin''s and thief''s groups are broader than the book by that much.')
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'NOT EXPRESSIBLE HERE and deliberately left in this note') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the monk grants 2 + 4 + 2 W.P. picks' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'monk'
   AND instr(markdown, 'choose: 4, categories: ["Weapon Proficiencies"]') > 0
   AND length(markdown) - length(replace(markdown, 'choose: 2, categories: ["Weapon Proficiencies"]', '')) =
       2 * length('choose: 2, categories: ["Weapon Proficiencies"]');

SELECT 'the demon-goblin grants its W.P. picks and the spy language' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'demon-goblin'
   AND instr(markdown, 'choose: 1, categories: ["Weapon Proficiencies"]') > 0
   AND instr(markdown, 'choose: 1, from: ["Language: Other"]') > 0;

-- Matched on the OLD phrasing, which the replacement does not reproduce: both
-- new notes say "not expressible" only of the acrobatic modifier, never of the
-- W.P. picks. The readback-quotes-its-own-phrase trap, avoided on purpose.
SELECT 'neither class still calls the W.P. picks inexpressible' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('monk', 'demon-goblin')
   AND (instr(markdown, 'NOT EXPRESSIBLE HERE and left in this note') > 0
     OR instr(markdown, 'NOT EXPRESSIBLE HERE and deliberately left in this note') > 0);

-- R2's own grants are untouched: this ADDS choice groups and moves nothing.
SELECT 'R2 skills are still present' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'monk' AND instr(markdown, 'name: "Gymnastics", base: 30') > 0)
    OR (class_id = 'demon-goblin' AND instr(markdown, 'name: "Tracking (people)", base: 35') > 0);

-- Records this run. Every statement guards itself, so this script is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r10-mos-choice-groups.sql');
