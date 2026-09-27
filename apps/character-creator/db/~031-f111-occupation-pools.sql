-- BOOK-INGEST-AUDIT F111, taken as an OPT-IN per occupation on Nate's word
-- (2026-09-27): two Arkhon-only O.C.C.s take their own printed starting money
-- over the Arkhon R.C.C.'s, and four notes stop describing the old effect.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~031-f111-occupation-pools.sql
--
-- WHAT. js/parser.js combineClasses now reads an O.C.C.'s
-- overrides_race: [ppe_base, starting_money] and lets the occupation's value
-- win the listed keys. This script sets it on:
--   arkhon-spectral-hunter  [starting_money]  2D4x1000, South America 2 printed 74
--   arkhon-esp-specialist   [starting_money]  2D6x1000, printed 76
-- against the Arkhon R.C.C.'s 1D6x1000 (printed 73). Both classes carry
-- race_restrictions only arkhon, so each changes exactly one pairing.
--
-- NOT the Larhold Shaman, though F111 names it. It has no race_restrictions
-- (printed 189: humans, ogres, wolfen and others are trained too), so the key
-- on it would move every race's P.P.E. or money in a pairing with it - 206
-- pairings over 150 races (variants counted; 165 P.P.E., 41 money), among
-- them the ADD and own-figure races Nate's decision leaves alone
-- (rifts-cyclops, rifts-elf, godling, true-inca, draconid) and a Phoenixi
-- falling from 3D4x100. Measured 2026-09-27 against the session census's
-- published-class snapshot. Left open in F111's outcome note.
--
-- NOTES. The two money notes and the Arkhon race's are rewritten past-tense.
-- The Palladium Fantasy human's note claimed a mage or clergy O.C.C.'s P.P.E.
-- wins the pairing; it never did, and it still does not, so it now says so.
--
-- MECHANICS. Each statement is a replace() guarded on its old text being
-- present - and each key insert also on no overrides_race line yet, because
-- its old text survives inside the new - so a second run changes nothing.
-- The ~ tier sorts after every z- tier; ~029 and ~030 are claimed by open PRs
-- and touch none of these rows.

-- spectral-hunter key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'starting_money: "2d4x1000"' || char(10), char(10) || 'starting_money: "2d4x1000"' || char(10) || 'overrides_race: [starting_money]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-spectral-hunter'
   AND instr(markdown, char(10) || 'starting_money: "2d4x1000"' || char(10)) > 0
   AND instr(markdown, char(10) || 'overrides_race:') = 0;

-- spectral-hunter note
UPDATE imported_classes
   SET markdown = replace(markdown, 'MONEY: 2D4x1000 Arkhon credits stored as printed; in a pairing the race''s 1D6x1000 wins by the composition rule, so this figure shows on the class detail only. class-check''s racial-discard warning names mdc_base and starting_money: mdc_base survives because the Arkhon R.C.C. states none, and starting_money is discarded as described; NOT supersedes_race, since the book does not say the character stops being an Arkhon.', 'MONEY: 2D4x1000 Arkhon credits stored as printed (printed 74). overrides_race: [starting_money] makes this figure win the pairing over the Arkhon R.C.C.''s 1D6x1000 (BOOK-INGEST-AUDIT F111, taken 2026-09-27); until then the race''s figure won and this one showed on the class detail only. class-check''s racial-discard warning names mdc_base alone, which survives because the Arkhon R.C.C. states none; NOT supersedes_race, since the book does not say the character stops being an Arkhon.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-spectral-hunter'
   AND instr(markdown, 'MONEY: 2D4x1000 Arkhon credits stored as printed; in a pairing the race''s 1D6x1000 wins by the composition rule, so this figure shows on the class detail only. class-check''s racial-discard warning names mdc_base and starting_money: mdc_base survives because the Arkhon R.C.C. states none, and starting_money is discarded as described; NOT supersedes_race, since the book does not say the character stops being an Arkhon.') > 0;

-- esp-specialist key
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'starting_money: "2d6x1000"' || char(10), char(10) || 'starting_money: "2d6x1000"' || char(10) || 'overrides_race: [starting_money]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-esp-specialist'
   AND instr(markdown, char(10) || 'starting_money: "2d6x1000"' || char(10)) > 0
   AND instr(markdown, char(10) || 'overrides_race:') = 0;

-- esp-specialist note
UPDATE imported_classes
   SET markdown = replace(markdown, 'MONEY: 2D6x1000 Arkhon credits stored as printed; in a pairing the race''s 1D6x1000 wins by the composition rule, so this figure shows on the class detail only.', 'MONEY: 2D6x1000 Arkhon credits stored as printed (printed 76). overrides_race: [starting_money] makes this figure win the pairing over the Arkhon R.C.C.''s 1D6x1000 (BOOK-INGEST-AUDIT F111, taken 2026-09-27); until then the race''s figure won and this one showed on the class detail only.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon-esp-specialist'
   AND instr(markdown, 'MONEY: 2D6x1000 Arkhon credits stored as printed; in a pairing the race''s 1D6x1000 wins by the composition rule, so this figure shows on the class detail only.') > 0;

-- arkhon note
UPDATE imported_classes
   SET markdown = replace(markdown, 'In a pairing the race''s starting_money wins over an occupation''s.', 'In a pairing the race''s starting_money wins over an occupation''s, except the Arkhon Spectral Hunter''s and ESP Specialist''s: both are Arkhon-only, both print their own money, and both carry overrides_race: [starting_money] (BOOK-INGEST-AUDIT F111, taken 2026-09-27), so they start with 2D4x1000 and 2D6x1000.'),
       updated_at = datetime('now')
 WHERE class_id = 'arkhon'
   AND instr(markdown, 'In a pairing the race''s starting_money wins over an occupation''s.') > 0;

-- human note
UPDATE imported_classes
   SET markdown = replace(markdown, 'a mage or clergy O.C.C. states its own P.P.E. and wins, because a pool the race states is replaced by nothing but its own occupation''s.', 'the mage-or-clergy exception is NOT modelled: composition keeps the race''s pool, so a human paired with an occupation that states its own P.P.E. (the wizard, summoner, diabolist and witch) composes to this 2D6. An occupation takes its own figure over a race''s only when it lists ppe_base in overrides_race, and none of these does; see BOOK-INGEST-AUDIT F111 (2026-09-27), which declined making that the general rule. Until then this note said the occupation''s figure won, which was never true.'),
       updated_at = datetime('now')
 WHERE class_id = 'human'
   AND instr(markdown, 'a mage or clergy O.C.C. states its own P.P.E. and wins, because a pool the race states is replaced by nothing but its own occupation''s.') > 0;

-- Read the result back: each new text present once, each old text gone.
SELECT 'hunter takes its money' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'arkhon-spectral-hunter' AND instr(markdown, char(10) || 'starting_money: "2d4x1000"' || char(10) || 'overrides_race: [starting_money]' || char(10)) > 0;
SELECT 'esp takes its money' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'arkhon-esp-specialist' AND instr(markdown, char(10) || 'starting_money: "2d6x1000"' || char(10) || 'overrides_race: [starting_money]' || char(10)) > 0;
SELECT 'hunter old note gone' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE class_id = 'arkhon-spectral-hunter' AND instr(markdown, 'so this figure shows on the class detail only. class-check''s') > 0;
SELECT 'esp old note gone' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE class_id = 'arkhon-esp-specialist' AND instr(markdown, 'wins by the composition rule') > 0;
SELECT 'arkhon note names F111' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'arkhon' AND instr(markdown, 'both carry overrides_race: [starting_money]') > 0;
SELECT 'human note corrected' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'human' AND instr(markdown, 'the mage-or-clergy exception is NOT modelled') > 0 AND instr(markdown, 'states its own P.P.E. and wins') = 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~031-f111-occupation-pools.sql');
