-- Five classes whose extra attacks are a BONUS, restated as `attacks` now that
-- a class's `attacks_base` no longer adds to a Hand to Hand style's.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~003-class-attacks-are-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~003-class-attacks-are-bonuses.sql
--
-- WHY. `attacks_base` STATES a starting number of attacks (RUE p.347), and the
-- frontmatter reference has always said the higher of two stands. Until
-- 2026-09-25 sumBonusGroups() in js/parser.js summed it with everything else,
-- so a class's attacks_base was ADDED to its Hand to Hand style's: the Pneuma-
-- Biform Killer Whale (5, with Expert's 4) fought at nine. That PR makes it
-- take the higher. These five classes were written against the sum - their
-- books say the class ADDS to the style - and would lose attacks under the
-- fix, so they say what they mean instead:
--
--   Naut'Yll Soldier     Underseas p.148-150, "one additional attack per melee"
--   Naut'Yll Devastator  Underseas p.150, "add one additional attack per melee"
--       attacks_base: 1 -> attacks: 1. Expert's four plus one is five, the
--       number both classes showed before and after.
--
--   Lyn-Srial            New West p.133, "three attacks per melee round, plus
--   Cloudweaver          New West p.135, those gained from optional hand to hand"
--       attacks_base: 3 -> attacks: 1. Untrained, the default two plus one is
--       the book's three; with Basic, four plus one is five.
--
--   Sky Knight           New West p.135, "Four attacks per melee round, plus
--                        those gained from hand to hand combat"
--       attacks_base: 4 -> attacks: 2. With the granted Expert, six.
--
-- THE LYN-SRIAL READING IS A JUDGEMENT. "Those gained from hand to hand" is
-- read as what the style gains over an untrained character - two at level 1,
-- the app's default being two and every style but Assassin stating four - not
-- the style's whole four. The literal sum (seven, eight) is what the sheet
-- showed before; it counts the untrained two twice.
--
-- The Cibola Pincer Warrior already stores its fourth attack as `attacks: 1`
-- on top of Assassin's three; only its note, which describes the old sum as
-- current, is corrected.
--
-- Filename order is execution order: `~003` sorts after ~002 and every z tier,
-- so after each class's add- script and the hand-to-hand prices script. Each
-- UPDATE is guarded on the text it replaces, so a re-run changes nothing.

UPDATE imported_classes SET markdown = replace(markdown,
    'combat: { attacks_base: 1, initiative: 2,', 'combat: { attacks: 1, initiative: 2,'),
    updated_at = datetime('now')
 WHERE class_id = 'nautyll-soldier' AND instr(markdown, 'combat: { attacks_base: 1, initiative: 2,') > 0;
UPDATE imported_classes SET markdown = replace(markdown,
    'The extra attack per melee is `attacks_base: 1`, which composes on top of' || char(10)
    || '    the hand to hand skill rather than replacing it.',
    'The extra attack per melee is `attacks: 1`, a bonus on top of the hand to' || char(10)
    || '    hand skill''s own count. It was stored as a starting number until' || char(10)
    || '    2026-09-25, which worked only because a class''s was then added to the' || char(10)
    || '    skill''s.'),
    updated_at = datetime('now')
 WHERE class_id = 'nautyll-soldier'
   AND instr(markdown, 'The extra attack per melee is `attacks_base: 1`') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
    'combat: { attacks_base: 1, initiative: 4,', 'combat: { attacks: 1, initiative: 4,'),
    updated_at = datetime('now')
 WHERE class_id = 'nautyll-devastator' AND instr(markdown, 'combat: { attacks_base: 1, initiative: 4,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
    'combat: { attacks_base: 3, initiative: 1,', 'combat: { attacks: 1, initiative: 1,'),
    updated_at = datetime('now')
 WHERE class_id = 'lyn-srial' AND instr(markdown, 'combat: { attacks_base: 3, initiative: 1,') > 0;
UPDATE imported_classes SET markdown = replace(markdown,
    '`attacks_base: 3` is the book''s ''three attacks per melee round'' for an untrained Lyn-Srial, plus whatever optional Hand to Hand: Basic adds.',
    '`attacks: 1` is the book''s ''three attacks per melee round, plus those gained from optional hand to hand'': one over the untrained two, so an untrained Lyn-Srial fights at three and one with Hand to Hand: Basic at five.'),
    updated_at = datetime('now')
 WHERE class_id = 'lyn-srial'
   AND instr(markdown, '`attacks_base: 3` is the book''s ''three attacks per melee round''') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
    'combat: { attacks_base: 3, initiative: 2,', 'combat: { attacks: 1, initiative: 2,'),
    updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-cloudweaver' AND instr(markdown, 'combat: { attacks_base: 3, initiative: 2,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
    'combat: { attacks_base: 4, initiative: 3,', 'combat: { attacks: 2, initiative: 3,'),
    updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'combat: { attacks_base: 4, initiative: 3,') > 0;

UPDATE imported_classes SET markdown = replace(markdown,
    'Not `attacks_base: 4`, which measured 2026-09-25 as adding to the' || char(10)
    || '     skill''s three (seven attacks) rather than replacing it.',
    'Until 2026-09-25 a class `attacks_base` was ADDED to the style''s, which' || char(10)
    || '     is why this is not `attacks_base: 4`; the higher of the two stands now.'),
    updated_at = datetime('now')
 WHERE class_id = 'cibola-pincer-warrior'
   AND instr(markdown, 'Not `attacks_base: 4`, which measured') > 0;

SELECT 'none of the five states attacks_base any more' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('nautyll-soldier', 'nautyll-devastator', 'lyn-srial', 'lyn-srial-cloudweaver', 'lyn-srial-sky-knight')
   AND instr(markdown, 'combat: { attacks_base:') > 0;

SELECT 'all five state their attacks as a bonus' AS assertion,
       count(*) AS got, 5 AS want
  FROM imported_classes
 WHERE (class_id IN ('nautyll-soldier', 'nautyll-devastator', 'lyn-srial', 'lyn-srial-cloudweaver')
        AND instr(markdown, 'combat: { attacks: 1,') > 0)
    OR (class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'combat: { attacks: 2,') > 0);

SELECT 'no note still describes the old sum' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE instr(markdown, 'which measured 2026-09-25 as adding') > 0
    OR instr(markdown, 'is `attacks_base: 1`, which composes') > 0
    OR instr(markdown, 'plus whatever optional Hand to Hand: Basic adds') > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('~003-class-attacks-are-bonuses.sql');
