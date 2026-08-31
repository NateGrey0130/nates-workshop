-- The two noro O.C.C.s were imported with a psionic power schedule that denies
-- them powers their book grants, because the import said `categories_allowed` is
-- one list for the whole class and left it there. A SCHEDULE ENTRY CARRIES ITS
-- OWN `categories`, and js/leveling.js says so in as many words.
--
-- One-off data correction, run once per environment. NOT a migration - it
-- changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-noro-psionic-schedules.sql
--
-- WHAT WENT WRONG, IN THREE PLACES.
--
-- 1. `psionicCategoriesForGrant` in js/leveling.js reads `entry.categories` off
--    a `powers_schedule` entry FIRST, and falls back to the class-wide
--    `categories_allowed` only when the entry states none. Its own comment says
--    it OVERRIDES rather than narrows, and gives the reason: a book naming Super
--    for one slot is granting an exception to the tier, and intersecting would
--    throw the exception away. Both noro extraction notes assert the opposite -
--    "categories_allowed is one list for the whole class" - and both stored a
--    bare `{ level: 2, count: 3 }`. So a noro psychic COULD NOT TAKE THE SUPER
--    POWER its book grants at second level, at any level, ever: every pick fell
--    back to Healing/Sensitive/Physical.
--
-- 2. Both schedules stop at level 3. Both books say "at third level AND BEYOND,
--    select two powers from any category", which is levels 3 through 15, not
--    level 3 alone. Twelve levels of grants were missing from each class.
--
-- 3. The noro mystic warrior is granted "two powers from EACH of the four power
--    categories" at first level. It was stored as `powers_starting: 8` over a
--    `categories_allowed` of all four - which lets a player take eight Super
--    powers where the book grants two. That is precisely CLASS-AUDIT.md S1 and
--    S9, already fixed for the Delphi Juicer and the Mind Mage in
--    zz-starting-power-splits.sql, which is where `powers_starting_groups` came
--    from and which was in the tree three days before this class was written.
--
-- THIS IS THE SAME FAILURE AS fix-noro-mind-control-saves.sql, one batch later
-- and in a different key: a claim about what the app cannot express, written
-- from memory of the frontmatter reference rather than from the code. That
-- reference lists four keys under `magic` and a handful under `bonuses.saves`,
-- and says outright that it is giving examples. Nothing failed either time - the
-- classes parse, validate and compose, and 210 regression checks pass. This one
-- was found by grepping js/leveling.js while importing an unrelated race whose
-- spell schedule turned out to be fully expressible too.
--
-- Guarded on the exact text each statement replaces, so re-running is a no-op
-- and a row someone has already corrected by hand is left alone.

-- 1. The noro psychic: two from Healing/Sensitive/Physical at second level and
-- ONE FROM SUPER beside it, then two from any category at every level from third
-- on. Mind wipe, psi-sword and mentally possess others stay barred at every
-- level, which is what the entry notes say - grantNote() shows them at the point
-- the pick is made, which is the only place a rule the catalog cannot enforce
-- can honestly live.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  powers_schedule:' || char(10) ||
         '    - { level: 2, count: 3 }' || char(10) ||
         '    - { level: 3, count: 2 }',
         '  powers_schedule:' || char(10) ||
         '    - { level: 2, count: 2, categories: ["Sensitive", "Healing", "Physical"] }' || char(10) ||
         '    - { level: 2, count: 1, categories: ["Super"], note: "One Super psionic power - but never mind wipe, psi-sword or mentally possess others." }' || char(10) ||
         '    - { level: 3, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 4, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 5, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 6, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 7, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 8, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 9, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 10, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 11, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 12, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 13, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 14, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }' || char(10) ||
         '    - { level: 15, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on." }'),
       updated_at = datetime('now')
 WHERE class_id = 'noro-psychic'
   AND instr(markdown, '    - { level: 2, count: 3 }') > 0;

-- 2. The noro mystic warrior: the eight starting picks split two per category,
-- and the same widened schedule. Its exceptions run the other way from the
-- psychic's - the book makes mind wipe, psi-sword and mentally possess others
-- AVAILABLE from third level, so the level 3+ entries say so rather than barring
-- them.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  powers_starting: 8' || char(10) ||
         '  categories_allowed: ["Sensitive", "Healing", "Physical", "Super"]' || char(10) ||
         '  powers_schedule:' || char(10) ||
         '    - { level: 2, count: 3 }' || char(10) ||
         '    - { level: 3, count: 2 }',
         '  powers_starting: 8' || char(10) ||
         '  powers_starting_groups:' || char(10) ||
         '    - { count: 2, categories: ["Sensitive"] }' || char(10) ||
         '    - { count: 2, categories: ["Healing"] }' || char(10) ||
         '    - { count: 2, categories: ["Physical"] }' || char(10) ||
         '    - { count: 2, categories: ["Super"], note: "Two Super psionic powers - but never mind wipe, psi-sword or mentally possess others, which this class may only take from third level." }' || char(10) ||
         '  categories_allowed: ["Sensitive", "Healing", "Physical", "Super"]' || char(10) ||
         '  powers_schedule:' || char(10) ||
         '    - { level: 2, count: 2, categories: ["Sensitive", "Healing", "Physical"] }' || char(10) ||
         '    - { level: 2, count: 1, categories: ["Super"], note: "One Super psionic power - but never mind wipe, psi-sword or mentally possess others." }' || char(10) ||
         '    - { level: 3, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 4, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 5, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 6, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 7, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 8, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 9, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 10, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 11, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 12, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 13, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 14, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }' || char(10) ||
         '    - { level: 15, count: 2, categories: ["Healing", "Sensitive", "Physical", "Super"], note: "Two powers from any category, from third level on, with no exceptions - mind wipe, psi-sword and mentally possess others become available here." }'),
       updated_at = datetime('now')
 WHERE class_id = 'noro-mystic-warrior'
   AND instr(markdown, '    - { level: 2, count: 3 }') > 0;

-- 3. And correct the extraction note on each, so the next reader is not told a
-- false thing about the schema. Guarded the same way.
UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - THE POWER SCHEDULE IS AN APPROXIMATION AND THE EXCEPTIONS ARE NOT ENFORCED.' || char(10) ||
         '    The book grants twelve powers outright at first level, then two picks from' || char(10) ||
         '    Healing/Sensitive/Physical; at second level two from those three categories' || char(10) ||
         '    plus ONE from Super; at third level and beyond two from ANY category. So the' || char(10) ||
         '    category set legitimately WIDENS with level, and `categories_allowed` is a' || char(10) ||
         '    single list for the whole class. It is set to the first-level three, which' || char(10) ||
         '    fails closed, and the level-2 Super pick is folded into the level-2 count.' || char(10) ||
         '    Mind wipe, psi-sword and possess others are barred at every level and' || char(10) ||
         '    nothing expresses that either.',
         '  - THE POWER SCHEDULE IS EXACT, AND THE EXCEPTIONS ARE SHOWN AT THE PICK.' || char(10) ||
         '    The book grants twelve powers outright at first level, then two picks from' || char(10) ||
         '    Healing/Sensitive/Physical; at second level two from those three categories' || char(10) ||
         '    plus ONE from Super; at third level and beyond two from ANY category. The' || char(10) ||
         '    category set widens with level, and a `powers_schedule` entry carries its' || char(10) ||
         '    own `categories`, which OVERRIDE `categories_allowed` rather than narrowing' || char(10) ||
         '    it - see psionicCategoriesForGrant in js/leveling.js. This class shipped in' || char(10) ||
         '    PR #409 with a bare level-2 count, which denied the Super pick outright and' || char(10) ||
         '    stopped the schedule at level three; corrected by' || char(10) ||
         '    fix-noro-psionic-schedules.sql. Mind wipe, psi-sword and mentally possess' || char(10) ||
         '    others are barred at every level and cannot be filtered out of the picker,' || char(10) ||
         '    so each entry states it in a note the player is shown.')
 WHERE class_id = 'noro-psychic'
   AND instr(markdown, 'THE POWER SCHEDULE IS AN APPROXIMATION') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         '  - THE PSIONIC POWER SCHEDULE IS AN APPROXIMATION. The book grants the five' || char(10) ||
         '    noro powers outright, then TWO FROM EACH of the four categories at level one' || char(10) ||
         '    - eight picks - with mind wipe, psi-sword and possess others barred until' || char(10) ||
         '    third level. At second level it is two from sensitive/healing/physical plus' || char(10) ||
         '    one from super; at third and beyond, two from any category with no' || char(10) ||
         '    exceptions at all. `categories_allowed` is one list for the whole class, so' || char(10) ||
         '    all four are allowed and the per-category floor of two, and the three barred' || char(10) ||
         '    powers, are not enforced.',
         '  - THE PSIONIC POWER SCHEDULE IS EXACT. The book grants the five noro powers' || char(10) ||
         '    outright, then TWO FROM EACH of the four categories at level one - eight' || char(10) ||
         '    picks - with mind wipe, psi-sword and possess others barred until third' || char(10) ||
         '    level. At second level it is two from sensitive/healing/physical plus one' || char(10) ||
         '    from super; at third and beyond, two from any category with no exceptions' || char(10) ||
         '    at all. All of it is stored: `powers_starting_groups` splits the eight two' || char(10) ||
         '    per category, and each `powers_schedule` entry carries its own' || char(10) ||
         '    `categories`. This class shipped in PR #409 with `powers_starting: 8` over' || char(10) ||
         '    a four-category allowance, which let a player take eight Super powers where' || char(10) ||
         '    the book grants two - the same defect as CLASS-AUDIT.md S1 and S9, three' || char(10) ||
         '    days after zz-starting-power-splits.sql fixed those. Corrected by' || char(10) ||
         '    fix-noro-psionic-schedules.sql.')
 WHERE class_id = 'noro-mystic-warrior'
   AND instr(markdown, 'THE PSIONIC POWER SCHEDULE IS AN APPROXIMATION') > 0;

-- Read the result back rather than trusting the exit code. Both rows should show
-- a level-15 grant, a reachable Super category on the schedule, and no surviving
-- claim that the schedule is an approximation. The mystic warrior alone should
-- show the starting split.
SELECT class_id,
       instr(markdown, 'level: 15, count: 2') > 0 AS schedule_runs_to_15,
       instr(markdown, 'categories: [' || char(34) || 'Super' || char(34) || ']') > 0 AS super_is_reachable,
       instr(markdown, 'powers_starting_groups') > 0 AS has_starting_split,
       instr(markdown, 'IS AN APPROXIMATION') > 0 AS still_claims_approximate
  FROM imported_classes
 WHERE class_id IN ('noro-psychic', 'noro-mystic-warrior')
 ORDER BY class_id;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-noro-psionic-schedules.sql');
