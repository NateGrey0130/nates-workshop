-- Twelve psionic powers claim a citation the book does not support.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-unverified-psionic-provenance.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-unverified-psionic-provenance.sql
--
-- All 94 psionic powers carried source_book 'Rifts Ultimate Edition'. Twelve of
-- them do not appear in that book AT ALL - not on the Psionic checklist on
-- printed p164, and not anywhere in the text of any of its 382 pages.
--
-- They came from `add-rue-psionics-batch.sql`, an earlier extraction whose own
-- header describes "four page-range passes plus three seam sweeps". The
-- psionics chapter OCR'd completely - printed pp.165-184 each carry 3.7 to 7.5
-- KB of text - so this is not a gap in the reading. The citation is wrong.
--
-- THE TEST, and why it is the one used. Three were tried:
--
--   * Whole name only              -> 13 absent, but "Commune with Spirit" is
--                                     printed "Commune with Spirits" and is
--                                     really there.
--   * Any distinctive word present ->  7 absent, far too generous: "Catatonic
--                                     Strike" matched on "strike", and
--                                     "catatonic" appears on an insanity table
--                                     200 pages from the psionics chapter.
--   * Whole name, parenthetical
--     dropped, singular/plural
--     tolerant                     -> 12 absent. Used.
--
-- The parenthetical has to be dropped or "Object Read (Psychometry)" reads as
-- absent when RUE lists it as plain "Object Read".
--
-- WHAT THIS DOES NOT DO. It does not delete them. Several are real Palladium
-- powers from World Book 12: Psyscape - which RUE's own checklist page points
-- at - so the content is worth keeping; it is only the citation that is false.
-- Nor does it retag them TO Psyscape, because that book is not in hand and a
-- guess is what created this problem. NULL is the honest value: no verified
-- source. `source` stays 'import'.
--
-- Guarded on the current value, so a row someone has since cited properly is
-- left alone and re-running is a no-op.

UPDATE psionic_powers SET source_book = NULL
 WHERE source_book = 'Rifts Ultimate Edition'
   AND name IN (
  'Attack Disease',
  'Transfer I.S.P.',
  'Teleport Object',
  'Commune with Animals',
  'Dispel Spirits',
  'Advanced Trance State',
  'Catatonic Strike',
  'Cure Insanity',
  'Induce Nightmare',
  'Insert Memory',
  'Invisible Haze',
  'Mental Illusion');

-- Read the result back rather than trusting the exit code.
SELECT COALESCE(source_book, '(no verified source)') AS source_book,
       count(*) AS powers
  FROM psionic_powers
 GROUP BY source_book
 ORDER BY powers DESC;

-- Every row still present; only the citation changed.
SELECT count(*) AS total_powers FROM psionic_powers;

INSERT INTO data_script_runs (filename) VALUES ('fix-unverified-psionic-provenance.sql');
