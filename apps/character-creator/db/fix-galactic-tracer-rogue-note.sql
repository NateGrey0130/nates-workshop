-- The Galactic Tracer says two false things about its own +6% Rogue bonus.
-- The NUMBER is right; the claims about it are not.
--
-- One-off data correction, run once per environment. NOT a migration - it
-- changes rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-galactic-tracer-rogue-note.sql
--
-- WHAT IS WRONG. add-galactic-tracer-class.sql (PR #413) stores
-- `Rogue: bonus 6`, which is exactly what printed 40 prints, and then says so
-- twice over - once in the related-skills note and once in the body prose.
-- Both of those sentences overreach:
--
--   1. "which is not a percentage this book uses anywhere else". A grep of the
--      whole cache finds "Rogue: Any (+6%)" three times: printed 40 (this
--      class), printed 64 (Noro Mystic Warrior) and printed 89 (Pleasurer).
--      The other two both store 6 as well, so the catalog was already
--      contradicting the sentence when it was written. What the book really
--      does print once each are the Runner's +8% and +12%, both on printed 42,
--      and add-runner-class.sql says so correctly.
--   2. "It is on the page twice". Printed 40 carries the figure ONCE, in the
--      tracer's O.C.C. Related Skills list. Verified on a 500 dpi crop of the
--      lower left column and by grepping the cached text of printed 39 and 40
--      for any occurrence of "6%".
--
-- WHAT IT COST. Nothing mechanical: no number moves and no character changes.
-- It is a claim defect, and the reason to correct it is that the next session
-- reading the tracer would conclude that a +6% elsewhere in this book was an
-- OCR error to be normalised to +5 - which is precisely the reading the
-- Pleasurer import had to talk itself out of on printed 89.
--
-- Found while importing the Pleasurer (printed 89), whose related list carries
-- the third +6%.
--
-- Guarded on the exact text it replaces, so re-running is a no-op and a row
-- someone has already corrected by hand is left alone. The replacements
-- deliberately do NOT quote either false sentence, so the readback below can
-- assert their absence.

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Rogue is printed at +6%, which is not a percentage this book uses anywhere else and is transcribed as printed.',
         'Rogue is printed at +6% and is transcribed as printed. That figure is not unique to this class, though this note used to claim it was: the same +6% is printed for the Noro Mystic Warrior on printed 64 and for the Pleasurer on printed 89, and both of those store 6 too. The percentages this book really does use once each are the Runner''s +8% and +12%, both on printed 42.')
 WHERE class_id = 'galactic-tracer'
   AND instr(markdown, 'Rogue is printed at +6%, which is not a percentage this book uses anywhere else') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown,
         'Rogue skills are printed at **+6%** - not +5, not +10. It is on the page twice
and it is transcribed as printed.',
         'Rogue skills are printed at **+6%** - not +5, not +10 - and are transcribed as
printed. This paragraph used to add that the figure appears on printed 40 twice
and nowhere else in the book. Both halves were wrong: printed 40 carries it
once, and the same +6% is printed for the Noro Mystic Warrior on printed 64 and
for the Pleasurer on printed 89.')
 WHERE class_id = 'galactic-tracer'
   AND instr(markdown, 'It is on the page twice') > 0;

-- Read the result back rather than trusting the exit code. Expect
-- still_claims_unique = 0, still_claims_twice = 0, names_the_other_two = 1.
SELECT class_id,
       instr(markdown, 'not a percentage this book uses anywhere else') > 0 AS still_claims_unique,
       instr(markdown, 'It is on the page twice') > 0 AS still_claims_twice,
       instr(markdown, 'Noro Mystic Warrior on printed 64') > 0 AS names_the_other_two
  FROM imported_classes
 WHERE class_id = 'galactic-tracer';

-- Records this run. One row per run rather than per file: every statement above
-- guards itself, so this script is safe to re-run and safe to run early.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-galactic-tracer-rogue-note.sql');
