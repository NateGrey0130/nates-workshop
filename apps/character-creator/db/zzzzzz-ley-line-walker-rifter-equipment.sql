-- Two divergences between the Ley Line Walker and the Ley Line Rifter, one in
-- each direction, both settled against the printed page.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-ley-line-walker-rifter-equipment.sql
--
-- RUE printed 116 is the Ley Line Walker's Standard Equipment, and the Ley Line
-- Rifter inherits it: the Rifter's entry on printed 117-118 has NO Standard
-- Equipment line, no O.C.C. Skills line, no Related Skills line and no Money
-- line of its own - checked by grepping cache p120 and p121 for all four - and
-- printed 118 says "Ley Line Rifter Stats. Same as the Ley Line Walker."
--
-- The printed list reads, in part:
--   "...knapsack, backpack, 1D4 small sacks, one large sack, six wooden stakes
--    and mallet (for vampires and other practical applications), canteen,
--    binoculars, tinted goggles or sunglasses, air filter and gas mask,
--    flashlight, 100 feet (30.5 m) of lightweight cord and grappling hook, pen
--    or pencils and note or sketch pad."
--
-- (1) THE RIFTER IS SHORT TWO ENTRIES the book grants it - the pen-or-pencil
-- and note-or-sketch-pad choices. 23 entries against the Walker's 25. They are
-- inserted after the grappling hook, which is where the Walker carries them and
-- where the printed sentence puts them, and the two lines are copied from the
-- Walker's own markdown rather than retyped.
--
-- (2) THE WALKER'S SMALL SACKS ARE WRONG AND THE RIFTER'S ARE RIGHT. The book
-- says "1D4 small sacks". The Walker carries qty 4, a fixed number; the Rifter
-- carries "1d4". This is the one correction here that runs the opposite way
-- from every other Walker/Rifter divergence found so far, and it is worth
-- stating plainly: the copy was right and the original was wrong.
--
-- NOT FIXED HERE, and recorded rather than guessed at: the Walker's
-- "Language: Other" choice group carries per_level: 5 and the Rifter's does
-- not. Which side is right depends on what per_level means on a CHOICE group
-- as opposed to a named skill, and that was not established. Left alone.
--
-- Found while auditing BOOK-INGEST-AUDIT.md F25 before taking it, in the same
-- pass that found the Rifter's missing category bonuses (PR #783). F25 says the
-- drift it predicts has a sample size of zero; this is the second and third
-- instance in one pair.
--
-- SORTS AFTER EVERY WRITER OF THIS REGION, checked against the directory:
-- zzz-resolve-choice-group-gear.sql and
-- zzzz-resolve-energy-placeholder-choices.sql both rewrite equipment entries on
-- these classes, and both are in earlier z- tiers.
--
-- Guarded on the text it replaces and keyed on class_id.

UPDATE imported_classes
   SET markdown = replace(markdown, '  - { item_id: "grappling-hook", qty: 1 }', '  - { item_id: "grappling-hook", qty: 1 }' || char(10) || '  - { choose: 1, label: "pen or pencil", qty: 1, from: ["pen", "pencil"] }' || char(10) || '  - { choose: 1, label: "note or sketch pad", qty: 1, from: ["note-pad", "sketch-pad"] }')
 WHERE class_id = 'ley-line-rifter'
   AND instr(markdown, '  - { choose: 1, label: "pen or pencil", qty: 1, from: ["pen", "pencil"] }') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - { item_id: "small-sack", qty: 4 }', '  - { item_id: "small-sack", qty: "1d4" }')
 WHERE class_id = 'ley-line-walker'
   AND instr(markdown, '  - { item_id: "small-sack", qty: 4 }') > 0;

-- Read the result back rather than trusting the exit code.
SELECT 'the rifter carries the pen choice' AS assertion,
       instr(markdown, 'label: "pen or pencil"') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ley-line-rifter';

SELECT 'the rifter carries the note pad choice' AS assertion,
       instr(markdown, 'label: "note or sketch pad"') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ley-line-rifter';

SELECT 'the rifter did not gain a duplicate grappling hook' AS assertion,
       (length(markdown) - length(replace(markdown, 'item_id: "grappling-hook"', ''))) AS got,
       length('item_id: "grappling-hook"') AS want
  FROM imported_classes WHERE class_id = 'ley-line-rifter';

SELECT 'the walker small sacks are now a dice value' AS assertion,
       instr(markdown, '  - { item_id: "small-sack", qty: "1d4" }') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ley-line-walker';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ley-line-walker-rifter-equipment.sql');
