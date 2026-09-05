-- The Machine Ghost psionic power gets the description it never had.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-machine-ghost-description.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-machine-ghost-description.sql
--
-- THE ONLY PSIONIC POWER IN THE CATALOG WITH NO DESCRIPTION, and it is now the
-- last one: 115 of the 116 carry real prose and this was the single NULL,
-- checked --remote 2026-09-05. Unlike the spell catalog, there is no stub
-- problem here - no psionic power carries a category label where a description
-- belongs, so this row is the whole gap rather than the visible part of one.
--
-- THE BOOK. Rifts Ultimate Edition printed 173 (rue cache p176, registry offset
-- 3, the folio "173" verified inside the page). The entry runs across the page
-- break and BOTH halves were read: the first half is the read-only rule and the
-- data it reaches, the second describes entering the machine "as an actual
-- Machine Ghost", which is where the Astral Projection comparison comes from.
--
-- THE DESCRIPTION IS A PARAPHRASE, not the book's text, matching the ~200
-- catalog rows written that way. Book text is never committed to this repo -
-- see the OCR cache's own rule - and a description is our summary of a
-- mechanic, not a transcription of it.
--
-- ONE STAT FIELD IS ALSO CORRECTED. The row stores saving_throw "None."; the
-- book prints "Not applicable." Both mean no save is rolled, but the catalog
-- stores what the page prints, and the two are not the same statement - "None"
-- says a save exists and always fails, "Not applicable" says the question does
-- not arise. Range, duration and I.S.P. already match the page exactly and are
-- untouched.
--
-- GUARDED ON THE NULL, so a re-run after the row has a description does
-- nothing rather than overwriting a later correction.

UPDATE psionic_powers
   SET description = 'The psychic falls into a trance and projects his mind into a computer or artificial intelligence, travelling its network from the inside much as Astral Projection travels the physical world. READ ONLY - he can acquire and read information but can never input, program or delete data. He can also read anything stored electronically, including disks, tape, film and hard drives, perceiving it roughly ten times faster than playing it back. It does not work on sentient, self-aware machines.'
 WHERE name = 'Machine Ghost'
   AND (description IS NULL OR description = '');

UPDATE psionic_powers
   SET saving_throw = 'Not applicable.'
 WHERE name = 'Machine Ghost'
   AND saving_throw = 'None.';

-- ---- readbacks -----------------------------------------------------------
SELECT 'Machine Ghost has a description' AS assertion,
       count(*) AS got, 1 AS want
  FROM psionic_powers
 WHERE name = 'Machine Ghost'
   AND description IS NOT NULL AND length(description) > 150;

SELECT 'and it states the read-only limit, which is the whole point of it' AS assertion,
       count(*) AS got, 1 AS want
  FROM psionic_powers
 WHERE name = 'Machine Ghost' AND instr(description, 'READ ONLY') > 0;

SELECT 'and the saving throw is what the page prints' AS assertion,
       count(*) AS got, 1 AS want
  FROM psionic_powers
 WHERE name = 'Machine Ghost' AND saving_throw = 'Not applicable.';

-- The stat block is UNTOUCHED apart from that one field.
SELECT 'range, duration and I.S.P. are unchanged' AS assertion,
       count(*) AS got, 1 AS want
  FROM psionic_powers
 WHERE name = 'Machine Ghost'
   AND range = 'Self; computer by touch.'
   AND duration = 'Three minutes per level of experience.'
   AND isp = 12;

-- NO PSIONIC POWER IS LEFT WITHOUT A DESCRIPTION. This is the assertion the
-- file exists for, and it is a corpus-wide invariant rather than a count.
SELECT 'no psionic power is left with an empty description' AS assertion,
       count(*) AS got, 0 AS want
  FROM psionic_powers
 WHERE description IS NULL OR description = '';

INSERT INTO data_script_runs (filename) VALUES ('zzzzz-machine-ghost-description.sql');
