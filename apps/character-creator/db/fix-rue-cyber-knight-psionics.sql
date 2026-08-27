-- The Cyber-Knight's psionics, corrected against Rifts Ultimate Edition
-- printed p.64 (rue cache p067; the rue cache runs printed+3).
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-rue-cyber-knight-psionics.sql
--
-- CLASS-AUDIT.md S2, and it corrects a choice F5 made in
-- fix-rue-cyber-knight-bonuses.sql. F5 set powers_starting: 9, reading the
-- book's "three powers known to all Cyber-Knights" as three of the picks and
-- adding the Major band's six. THAT CANNOT WORK. The three are Create
-- Psi-Sword, Create Psi-Shield and Meditation, and the catalog files the first
-- two under Super - a category a major psychic cannot reach. So the nine picks
-- were nine Healing/Sensitive/Physical powers, three more than the book grants,
-- and the three universal ones were unreachable. They are granted by name now
-- and the pick count is the book's six.
--
-- The page, read from the cache:
--
--   "Cyber-Knight Psionics Common to All: Create Psi-Sword (no I.S.P. cost);
--   Create Psi-Shield (15 I.S.P., which is half the normal I.S.P. cost);
--   Meditation."
--
--   "Inner Spirit: Somewhere around 70% of all Cyber-Knights possess limited
--   psychic powers." Then 01-40 Minor, 41-60 Major, 61-70 Master, 71-00
--   Non-Psychic - four bands, each with its own I.S.P. base, its own count of
--   additional powers and its own save target.
--
--   "41-60% Major Psychic: I.S.P. Base: 6D6 + M.E. attribute number +1D6
--   I.S.P. per level of experience ... Select a total of six additional
--   psychic powers from any of the three psionic categories: Healing,
--   Sensitive, and Physical. These are in addition to those three powers
--   known to all Cyber-Knights."
--
-- WHAT THIS SCRIPT DOES NOT DO, and why S2 is only half taken: the d100 table
-- stays unmodelled. The audit read `psionics_allowed` rolled tiers as evidence
-- that a class can state one. They are not: `PSIONIC_TABLE` and
-- `PSIONIC_TIER_RULES` in js/psionics.js are ONE GLOBAL TABLE, hardcoded from
-- Palladium Fantasy 2nd Ed. p.20-21 (01-09 major, 10-25 minor, 26-00 none),
-- and `rollsForPsionics()` returns false for any class that declares a
-- `psionics` block at all. There is no per-class rolled-table shape, and this
-- table needs four bands carrying four I.S.P. bases, four power counts, two
-- save targets and - in the Master band - a Super-psionic schedule and a
-- Psi-Sword damage schedule. That is an app change, and a bigger one than the
-- finding supposed.
--
-- The finding's SECOND half is right and is recorded: `powers_from` exists
-- (the burster uses it), so a named list is expressible. It does not apply
-- here, because the twelve-name list belongs to the MINOR band and this class
-- is stored as Major, which draws from the three categories.
--
-- Filename sort: > fix-rue-cyber-knight-bonuses.sql, whose output every guard
-- below matches, and > fix-pre-rue-class-audit.sql, the last writer of this
-- class's whole markdown. zz-merge-psionic-duplicates.sql sorts later and
-- names this class, but deliberately does not rewrite class markdown.
--
-- Every statement is guarded on the old text; re-running is a no-op.

-- 1. The psionics block: the three universal powers granted by name, the
--    book's six picks, and the three categories stated rather than left open.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         'psionics:' || char(10) ||
         '  type: "major"' || char(10) ||
         '  isp_base: "6d6 plus M.E. attribute number, +1d6 per level"' || char(10) ||
         '  powers_starting: 9',
         'psionics:' || char(10) ||
         '  type: "major"' || char(10) ||
         '  isp_base: "6d6 plus M.E. attribute number, +1d6 per level"' || char(10) ||
         '  # Known to ALL cyber-knights whatever the tier roll says, so granted' || char(10) ||
         '  # rather than picked - two of the three are Super-category and a major' || char(10) ||
         '  # psychic could never have chosen them.' || char(10) ||
         '  powers: ["Psi-Sword", "Psi-Shield", "Meditation"]' || char(10) ||
         '  powers_starting: 6' || char(10) ||
         '  categories_allowed: ["Healing", "Sensitive", "Physical"]'),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, '  powers_starting: 9') > 0;

-- 2. The Psionics ability, which stated the wrong percentage, the wrong roll
--    band and the wrong list. It now carries the whole table as prose, which
--    is where the table has to live until the app can hold one.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '    description: "Eighty percent of cyber-knights are psychic (roll 01-80). A psychic cyber-knight is a major psionic, saves against psionic attack at 12 or higher, and picks three permanent powers from a fixed list: empathy, mind block, object read, see the invisible, sense evil, sense magic, sixth sense, speed reading, summon inner strength."',
         '    description: "Create Psi-Sword, Create Psi-Shield and Meditation are known to ALL cyber-knights and are granted outright; the knight''s Psi-Shield costs 15 I.S.P., half the catalog figure. Beyond those three, about SEVENTY percent of cyber-knights are psychic. The player or G.M. may decide, or roll percentile (RUE p.64). 01-40 Minor: I.S.P. 3D6 plus M.E. attribute number, +1D6 per level, saves vs psionic attack at 12, and three additional powers from a named list of twelve - Alter Aura, Empathy, Mind Block, Object Read, Resist Fatigue, See the Invisible, Sense Evil, Sense Magic, Sixth Sense, Speed Reading, Summon Inner Strength, Total Recall. 41-60 Major: I.S.P. 6D6 plus M.E., +1D6 per level, saves at 12, and six additional powers from Healing, Sensitive and Physical. 61-70 Master: I.S.P. 6D6+10 plus M.E., +2D4 per level, saves at 10, eight additional powers from those same three categories, ONE Super-psionic power at levels 2, 6 and 10, and an extra +1D6 M.D. on the Psi-Sword at levels 2, 5, 9 and 13. 71-00 Non-psychic: I.S.P. equal to the M.E. attribute number, +1D4 per level, no additional powers, +2 to Perception Rolls, and saves as a minor psychic. THIS CLASS IS STORED AS THE MAJOR BAND, which is the one the app models; the other three are played by hand."'),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, 'Eighty percent of cyber-knights are psychic') > 0;

-- 3. The note claiming the schema cannot state a per-character roll.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - The 80% chance of having psionics at all is a per-character roll the class schema cannot state; the class is written as psychic, which is the common case.',
         '  - The d100 tier table on RUE p.64 - 01-40 minor, 41-60 major, 61-70 master, 71-00 non-psychic - is still NOT modelled, and the class is written as the major band, which is the common psychic case. An earlier version of this note said the schema simply cannot state a per-character roll; that is half right, and CLASS-AUDIT.md S2 asked for the precise version. A rolled tier DOES exist, but it is one GLOBAL table hardcoded in js/psionics.js from Palladium Fantasy 2nd Ed. p.20-21, and rollsForPsionics() fires only for a class declaring no psionics block at all. There is no per-class table shape, and this table needs four bands carrying four I.S.P. bases, four power counts, two save targets, and the master band''s Super-psionic and Psi-Sword schedules. The percentage was wrong too: the book says about seventy percent, not eighty.'),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, 'The 80% chance of having psionics at all') > 0;

-- 4. The note claiming psionics gates only by category.
UPDATE imported_classes
   SET markdown = replace(
         markdown,
         '  - Stored as the Major Psychic result of the RUE p.64 roll: the three universal powers plus six additional picks, powers_starting: 9. The universal three come from a named list, but `psionics` gates by category rather than by name, so any Sensitive/Physical/Healing power is offered; the d100 tier table itself is still not modelled (CLASS-AUDIT.md S2).',
         '  - Stored as the Major Psychic result of the RUE p.64 roll: six additional powers from Healing, Sensitive and Physical (powers_starting: 6), with Create Psi-Sword, Create Psi-Shield and Meditation granted by name because the book gives those three to every cyber-knight whatever the roll. An earlier version stored powers_starting: 9, counting the universal three as three of the picks - which could never work, since the catalog files Psi-Sword and Psi-Shield under Super and a major psychic''s picks cannot reach Super. That earlier note also said `psionics` gates by category rather than by name; that is false, `powers_from` exists and the burster uses it. It does not apply here: the twelve-name list belongs to the MINOR band, and this class is the Major one, which draws from the three categories.'),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   -- Guarded on a phrase the REPLACEMENT does not contain. The obvious guard,
   -- 'gates by category rather than by name', appears in the new text too - it
   -- quotes the claim it is correcting - so it would stay true forever and this
   -- statement would fire on every re-run, replacing nothing and touching
   -- updated_at. Caught by the local readback, which could never reach zero.
   AND instr(markdown, 'The universal three come from a named list') > 0;

-- Readback. Expected: granted 1, picks_six 1, cats 1, old_nine_gone 1,
-- notes_left 0, has_cr 0.
SELECT (instr(markdown, 'powers: ["Psi-Sword", "Psi-Shield", "Meditation"]') > 0) AS granted,
       (instr(markdown, char(10) || '  powers_starting: 6' || char(10)) > 0)      AS picks_six,
       (instr(markdown, 'categories_allowed: ["Healing", "Sensitive", "Physical"]') > 0) AS cats,
       (instr(markdown, char(10) || '  powers_starting: 9') = 0)                  AS old_nine_gone,
       (instr(markdown, 'Eighty percent of cyber-knights') > 0)
     + (instr(markdown, 'The 80% chance of having psionics') > 0)
     + (instr(markdown, 'The universal three come from a named list') > 0)       AS notes_left,
       (instr(markdown, char(13)) > 0)                                           AS has_cr
  FROM imported_classes WHERE class_id = 'cyber-knight';

-- Records this run. Every statement guards itself, so this is safe to re-run.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-rue-cyber-knight-psionics.sql');
