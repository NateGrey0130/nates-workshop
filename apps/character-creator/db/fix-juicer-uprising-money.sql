-- Two wrong starting_money figures in the Juicer-Related O.C.C.s, and one
-- missing secondary-skill schedule. Read again, from the page that carries the
-- answer rather than the page that starts the entry.
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-juicer-uprising-money.sql
--
-- HOW THESE GOT IN. Both classes have their Money line on the page AFTER the
-- one their O.C.C. block starts on, and both were shipped with a figure taken
-- from the wrong sentence. The Gambler's entry begins on printed 58 and its
-- Money line is on printed 59; the Wannabe's begins on printed 60 and its Money
-- line is on printed 61. This is the straddling-page-break hazard the
-- book-survey skill names, in its most ordinary form - not a row cut in half,
-- just a value that lives one page further on than the reading stopped.
--
--   Gambler          shipped 2d6x100   book prints 6D6x10   (printed 59)
--   Juicer Wannabe   shipped 2d6x100   book prints 5D6x100  (printed 61)
--
-- The Wannabe's 2D6x100 IS a real number in that entry - it is the credits a
-- player takes INSTEAD of the three designer drugs, printed 60 - which is
-- exactly why it read as the money line and was not questioned. It is not the
-- starting money, and it is recorded in the Enhancing Drugs ability where it
-- belongs.
--
-- The Wannabe also gains the secondary-skill schedule its entry prints and this
-- import dropped: four at level one, and TWO MORE at levels three, six, nine and
-- twelve. Every other class in the batch had its schedule transcribed; this one
-- was read from the truncated view of the page.
--
-- Neither figure is one a test could have caught. starting_money is free text
-- and nothing cross-checks it against the book, which is the whole reason a
-- wrong number here is worse than a missing one.
--
-- Pure ASCII with LF line endings, comments included, per PR #93 and #101.
-- Idempotent: every statement is guarded on the text it replaces.

-- 1. The Gambler starts with 6D6x10 credits, plus 1D4x100 in saleable black
--    market items which are goods rather than coin.
UPDATE imported_classes
   SET markdown = replace(markdown, 'starting_money: "2d6x100"', 'starting_money: "6d6x10"')
 WHERE class_id = 'gambler' AND instr(markdown, 'starting_money: "2d6x100"') > 0;

-- 2. The Juicer Wannabe starts with 5D6x100 credits, plus 2D4x1000 in drugs or
--    saleable black market items.
UPDATE imported_classes
   SET markdown = replace(markdown, 'starting_money: "2d6x100"', 'starting_money: "5d6x100"')
 WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'starting_money: "2d6x100"') > 0;

-- 3. And its secondary skills gain the schedule the page prints.
UPDATE imported_classes
   SET markdown = replace(markdown, '  secondary_skills:
    count: 4
special_abilities:
  - name: "Enhancing Drugs"', '  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
special_abilities:
  - name: "Enhancing Drugs"')
 WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'secondary_skills:' || char(10) || '    count: 4' || char(10) || '    schedule:') = 0;

-- 4. True up the extraction_notes on both, so the file does not silently
--    disagree with the class it corrected.
UPDATE imported_classes
   SET markdown = replace(markdown,
       'starting_money is 2D6x100, taken from the Standard Equipment paragraph rather than a Money Bonus line, which this class does not have.',
       'starting_money is 6D6x10 credits, printed on the page AFTER the entry begins; the 1D4x100 in saleable black market items alongside it is goods rather than coin and is not stored. This class has no Money Bonus line. An earlier version of this row shipped 2D6x100, read from the wrong page - see fix-juicer-uprising-money.sql.')
 WHERE class_id = 'gambler' AND instr(markdown, 'starting_money is 2D6x100, taken from') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
       'starting_money is the 2D6x100 credits a character takes INSTEAD of the three designer drugs, which is the only coin figure the entry prints.',
       'starting_money is 5D6x100 credits, printed on the page AFTER the entry begins; the 2D4x1000 in drugs or saleable black market items alongside it is goods rather than coin. The 2D6x100 a drug-free character takes INSTEAD of the three designer drugs is a different figure and lives in the Enhancing Drugs ability. An earlier version of this row shipped that 2D6x100 as the starting money - see fix-juicer-uprising-money.sql.')
 WHERE class_id = 'juicer-wannabe' AND instr(markdown, 'starting_money is the 2D6x100 credits') > 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'starting_money: ' || char(34) || '6d6x10' || char(34)) > 0 AS gambler_money,
       instr(markdown, 'starting_money: ' || char(34) || '5d6x100' || char(34)) > 0 AS wannabe_money,
       instr(markdown, 'schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }') > 0 AS wannabe_schedule,
       instr(markdown, 'fix-juicer-uprising-money.sql') > 0 AS notes_trued,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id IN ('gambler', 'juicer-wannabe') ORDER BY class_id;

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-juicer-uprising-money.sql');
