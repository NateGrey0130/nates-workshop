-- Correct two class notes that repeat a FALSIFIED finding, and put the
-- Sky-Knight's +1D6 P.S. where it actually works.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-f52-false-dice-claims.sql
--
-- == WHAT WAS WRONG ==
--
-- `BOOK-INGEST-AUDIT.md` F52 claimed a dice string in `bonuses.attributes`,
-- `.combat` or `.saves` "parses clean, stores, and is silently dropped". IT IS
-- NOT DROPPED. It is rolled ONCE AT CREATION and stored on the character, which
-- is the same treatment `attribute_dice` gets and for the same reason:
--
--   * `js/derive.js:274-322`  diceBonusesByGroup / diceBonuses collect them
--   * `app.js:232-250`        rollDiceBonusesOf calls evalDice on every one
--   * `app.js:3622-3623`      stored as attribute_bonuses / rolled_bonuses
--   * `js/derive.js:216-246`  classBonuses turns the stored roll back into the
--                             number the sheet renders
--   * `js/parser.js:1393`     validateBonusGroup ACCEPTS dice - its own error
--                             text reads "must be a number or a dice
--                             expression like 2d6"
--
-- F52 reached the opposite conclusion by grepping `derive.js` and `compose.js`
-- for the roller. The roller is in `app.js` and `js/dice.js`. The grep was
-- true and pointed at the wrong two files.
--
-- PRODUCTION SETTLES IT. A live Juicer carries
-- `attribute_bonuses = {"PS":9,"PE":7,"Spd":70}` - exactly that class''s
-- `2d6`, `2d6` and `2d4x10`, rolled and stored. Read `--remote` 2026-09-10.
--
-- == WHAT THIS SCRIPT DOES ==
--
-- 1. THE SKY-KNIGHT''S +1D6 TO P.S. MOVES INTO `bonuses.attributes`. It was put
--    in `special_abilities` prose ONLY because F52 said a dice bonus there
--    would do nothing. It would have worked all along, so the class has been
--    quietly short a P.S. bonus its book grants outright. The now-empty
--    `special_abilities` block is removed - the P.S. bonus was its only entry.
-- 2. Both classes'' `extraction_notes` stop asserting the false claim.
--
-- Every UPDATE is guarded on the text it replaces, so re-running is a no-op and
-- none of them can fire against a row somebody has since edited by hand.

-- 1a. The Sky-Knight gains the attributes block. Inserted BEFORE `combat:` so
--     the block stays in the order every other class writes it.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'bonuses:' || char(10) || '  combat: { attacks_base: 4,',
         'bonuses:' || char(10) || '  attributes: { PS: "1d6" }' || char(10) || '  combat: { attacks_base: 4,')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, 'bonuses:' || char(10) || '  combat: { attacks_base: 4,') > 0
   AND instr(markdown, 'attributes: { PS: "1d6" }') = 0;

-- 1b. and loses the special_abilities block that held it as prose.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'special_abilities:' || char(10) ||
         '  - name: "P.S. bonus"' || char(10) ||
         '    description: "+1D6 to P.S. It is dice rather than a fixed number, so it is not applied automatically - roll it at creation. BOOK-INGEST-AUDIT.md F52."' || char(10),
         '')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, '  - name: "P.S. bonus"') > 0;

-- 1b-ii. AND `special_abilities` leaves the `copy_of` except list, because the
--     two classes now AGREE on it - the Sky-Knight has none and neither does
--     the Lyn-Srial it copies. `regression.mjs` checks that every name in an
--     except list actually differs, and it caught this the moment 1b landed:
--     "except lists special_abilities, but the two agree on it".
UPDATE imported_classes
   SET markdown = replace(markdown,
         ', "restrictions", "special_abilities"] }',
         ', "restrictions"] }')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, ', "restrictions", "special_abilities"] }') > 0;

-- 1c. and its extraction note stops repeating the false claim.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE +1D6 TO P.S. IS NOT STORED AS A NUMBER - `bonuses.attributes` silently drops a dice string, which is BOOK-INGEST-AUDIT.md F52 - so it is an ability to be rolled at creation.',
         'THE +1D6 TO P.S. IS IN `bonuses.attributes`, where a dice string is rolled once at creation and stored on the character - the same path a Juicer''s +2D6 P.S. takes. It was first stored as `special_abilities` prose on the strength of BOOK-INGEST-AUDIT.md F52, which claimed a dice bonus there was silently dropped; F52 was FALSIFIED and closed on 2026-09-10 and this class was corrected in the same PR.')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, 'silently drops a dice string') > 0;

-- 2. The Keeper of the Desert. Its abilities genuinely are not enumerated
--    against the catalog, which is true and stays; only the reason given for
--    it was false.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'see BOOK-INGEST-AUDIT.md F52 for why a dice bonus there would be silently dropped even if written as one.',
         'a `special_abilities` entry CAN carry a `bonuses` block and its dice ARE rolled at creation, so the gap here is the ENUMERATION rather than the mechanism. BOOK-INGEST-AUDIT.md F52 claimed the opposite and was falsified and closed on 2026-09-10.')
 WHERE class_id = 'keeper-of-the-desert'
   AND instr(markdown, 'would be silently dropped even if written as one') > 0;

-- Read the result back rather than trusting the exit code.
SELECT 'sky-knight has the working bonus' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'attributes: { PS: "1d6" }') > 0;

SELECT 'and no longer holds it as prose' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'name: "P.S. bonus"') > 0;

SELECT 'neither class still asserts the false claim' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('lyn-srial-sky-knight', 'keeper-of-the-desert')
   AND (instr(markdown, 'silently drops a dice string') > 0
     OR instr(markdown, 'would be silently dropped even if written as one') > 0);

SELECT 'special_abilities has left the except list' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, '"restrictions", "special_abilities"') > 0;

SELECT 'and both still cite F52, now for the correction' AS assertion,
       count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE class_id IN ('lyn-srial-sky-knight', 'keeper-of-the-desert')
   AND instr(markdown, 'BOOK-INGEST-AUDIT.md F52') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-f52-false-dice-claims.sql');
