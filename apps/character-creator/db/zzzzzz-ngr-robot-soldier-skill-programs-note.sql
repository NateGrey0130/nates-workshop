-- The Robot Soldier's note said its skill programs are NOT STORED. They are.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-ngr-robot-soldier-skill-programs-note.sql
--
-- BOOK-INGEST-AUDIT.md F23(b) was taken in the same PR that applies this, and
-- an extraction_notes entry does two jobs at once: what the BOOK prints, which
-- is permanent, and what the APP could do on the day of the import, which
-- rots. This is the second half rotting exactly as the class-import skill says
-- it does, and the audit-menu rule is that it is corrected in the same PR as
-- the finding rather than left behind it.
--
-- What the paragraph got RIGHT is kept word for word: the 38%, the absence of
-- bonuses and per-level gain, the 1D4x penalty, and the reason this is not
-- occ_related_skills with a large count. Only the claim that none of it is
-- stored is replaced, plus two facts the block now makes true - that thirteen
-- categories are offered where the book prints fourteen lines, and that W.P.
-- "All Modern" ships as the whole category.
--
-- Sorts immediately after the script that adds the block, and is guarded on
-- the result being absent as well as the old text being present.

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THE THREE SKILL PROGRAMS ARE ALSO NOT STORED, and they are a different shape
    from anything the app has. Printed 170 lets the character select up to three
    skill CATEGORIES, and every skill in a selected category is then available
    at a flat 38% with no bonuses and no improvement with experience, at 1D4
    times the normal time. occ_related_skills picks N SKILLS from listed
    categories; this picks N CATEGORIES and grants all of them. The category
    list and its exclusions are in the body so a GM has them. Filed as part of
    the same finding.
', '  - THE THREE SKILL PROGRAMS ARE STORED, and the app grew a shape for them.
    Printed 170 lets the character select up to three skill CATEGORIES, and
    every skill in a selected category is then available at a flat 38% with no
    bonuses and no improvement with experience, at 1D4 times the normal time.
    occ_related_skills picks N SKILLS from listed categories; this picks N
    CATEGORIES and grants all of them, which is why it is its own block rather
    than a large count. See BOOK-INGEST-AUDIT.md F23(b).
  - THIRTEEN CATEGORIES ARE OFFERED WHERE THE BOOK PRINTS FOURTEEN LINES. The
    fourteenth is Rogue: None - a refusal, not an offer - so Rogue is absent
    rather than present and empty.
  - W.P. IS PRINTED AS "All Modern" AND THE WHOLE CATEGORY IS OFFERED, which is
    the one place this grant is wider than the page. The catalog does not mark
    a W.P. ancient or modern, and CLASS-AUDIT.md records that those splits ride
    in notes; the Crazy, the Burster and both Elemental Fusionists all grant
    the whole category and say so in prose. The block note tells the player.
')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, '  - THE THREE SKILL PROGRAMS ARE ALSO NOT STORED, and they are a different shape
    from anything the app has. Printed 170 lets the character select up to three
    skill CATEGORIES, and every skill in a selected category is then available
    at a flat 38% with no bonuses and no improvement with experience, at 1D4
    times the normal time. occ_related_skills picks N SKILLS from listed
    categories; this picks N CATEGORIES and grants all of them. The category
    list and its exclusions are in the body so a GM has them. Filed as part of
    the same finding.
') > 0
   AND instr(markdown, '  - THE THREE SKILL PROGRAMS ARE STORED, and the app grew a shape for them.
    Printed 170 lets the character select up to three skill CATEGORIES, and
    every skill in a selected category is then available at a flat 38% with no
    bonuses and no improvement with experience, at 1D4 times the normal time.
    occ_related_skills picks N SKILLS from listed categories; this picks N
    CATEGORIES and grants all of them, which is why it is its own block rather
    than a large count. See BOOK-INGEST-AUDIT.md F23(b).
  - THIRTEEN CATEGORIES ARE OFFERED WHERE THE BOOK PRINTS FOURTEEN LINES. The
    fourteenth is Rogue: None - a refusal, not an offer - so Rogue is absent
    rather than present and empty.
  - W.P. IS PRINTED AS "All Modern" AND THE WHOLE CATEGORY IS OFFERED, which is
    the one place this grant is wider than the page. The catalog does not mark
    a W.P. ancient or modern, and CLASS-AUDIT.md records that those splits ride
    in notes; the Crazy, the Burster and both Elemental Fusionists all grant
    the whole category and say so in prose. The block note tells the player.
') = 0;

-- Read the result back rather than trusting the exit code.
SELECT 'the stale not-stored claim is gone' AS assertion,
       instr(markdown, 'SKILL PROGRAMS ARE ALSO NOT STORED') AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

SELECT 'and the note now cites F23(b)' AS assertion,
       instr(markdown, 'BOOK-INGEST-AUDIT.md F23(b)') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

SELECT 'the half about the INHERITED occupation still stands, and still cites F23' AS assertion,
       instr(markdown, 'BOOK-INGEST-AUDIT.md F23.') > 0 AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'ngr-robot-soldier';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-ngr-robot-soldier-skill-programs-note.sql');
