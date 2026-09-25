-- Gymnastics and Acrobatics: production takes the rebuild's note.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzzzzzzzzzzzzzz-sdc-note-order.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzzzzzzzzzzzzzz-sdc-note-order.sql
--
-- Two scripts append to each of these notes. add-rifts-skill-list-gaps.sql
-- appends 'Also +1D6 S.D.C.' joined with a SPACE, and add-rue-skills-batch.sql
-- appends 'RUE p.302 lists varies' joined with '; '. A rebuild runs them in
-- filename order and reads "Also +1D6 S.D.C.; RUE p.302 lists varies".
-- Production ran them the other way round by hand and reads "RUE p.302 lists
-- varies Also +1D6 S.D.C." - the same two facts with no separator between
-- them.
--
-- zzzz-restore-skill-notes-and-citations.sql (REBUILD-AUDIT F14) declined to
-- export production's form into the repo, because the rebuild's is the better
-- of the two. This is the other direction F14 left open: production takes the
-- rebuild's wording, and repo-vs-live stops reporting the pair.
--
-- Guarded on production's exact value, so a rebuild - which already holds the
-- target - matches nothing, and a note anyone has since edited is left alone.

UPDATE skills SET note = 'Also +1D6 S.D.C.; RUE p.302 lists varies'
 WHERE name IN ('Gymnastics', 'Acrobatics')
   AND note = 'RUE p.302 lists varies Also +1D6 S.D.C.';

-- Read the result back. This batch asserts its OWN rows and nothing else.

SELECT 'both notes read as a rebuild writes them' AS assertion, count(*) AS got, 2 AS want
  FROM skills
 WHERE name IN ('Gymnastics', 'Acrobatics')
   AND note = 'Also +1D6 S.D.C.; RUE p.302 lists varies';

INSERT INTO data_script_runs (filename) VALUES ('zzzzzzzzzzzzzzzzz-sdc-note-order.sql');
