-- The Gypsy - The Gifted O.C.C. gets its related-skill count from the psionic
-- band the player picks, rather than always offering four.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/fix-gypsy-gifted-related-skill-count.sql
--
-- BOOK-INGEST-AUDIT.md F24, part (a), taken as written. Printed 185 reads
-- "O.C.C. Related Skills: None if a master psionic. Select four 'other'
-- skills from any of the available skill categories if a major psionic." The
-- class stores four, and half the percentile table rolls MASTER - so the
-- picker offered four related skills to a character the book gives none, and
-- that is the one residue of F24 that could produce an illegal character.
--
-- The parser change this depends on is in the same PR: an ability definition
-- may now carry related_skills_count, and applyAbilities folds it onto
-- occ_related_skills.count when that ability is chosen. It overrides ONE
-- NUMBER; abilities still cannot carry a skills block, which is the power
-- VARIANT_OVERRIDES refuses on purpose. That posture is F24 (a) verbatim.
--
-- THE SCHEDULED PICKS ARE DELIBERATELY LEFT ALONE. Printed 185 continues
-- "Plus select one additional skill at levels three, six, nine, and twelve."
-- That sentence sits after BOTH branches rather than inside the major-psionic
-- clause, so it is read as applying to both, and the schedule is untouched.
-- It is the one thing the printed line leaves genuinely ambiguous, which is
-- why it is written down here rather than decided silently.
--
-- Every anchor below was checked against the --remote markdown before this
-- file was written, and each UPDATE is guarded on the text it replaces, so
-- re-running is a no-op.
-- related_skills_count on 51-75
UPDATE imported_classes
   SET markdown = replace(markdown, '  - name: "The Gift (51-75): Master Psionic, mixed"
', '  - name: "The Gift (51-75): Master Psionic, mixed"
    related_skills_count: 0
')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, '  - name: "The Gift (51-75): Master Psionic, mixed"
') > 0
   AND instr(markdown, '  - name: "The Gift (51-75): Master Psionic, mixed"
    related_skills_count: 0
') = 0;

-- related_skills_count on 76-00
UPDATE imported_classes
   SET markdown = replace(markdown, '  - name: "The Gift (76-00): Master Psionic, every healing power"
', '  - name: "The Gift (76-00): Master Psionic, every healing power"
    related_skills_count: 0
')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, '  - name: "The Gift (76-00): Master Psionic, every healing power"
') > 0
   AND instr(markdown, '  - name: "The Gift (76-00): Master Psionic, every healing power"
    related_skills_count: 0
') = 0;

-- the occ_related_skills note
UPDATE imported_classes
   SET markdown = replace(markdown, 'THE COUNT OF FOUR IS THE MAJOR PSIONIC''S: a character whose gift is a MASTER psionic (a roll of 51 or higher) gets NO O.C.C. Related Skills at all. Take four only if the gift picked under Abilities is one of the two major ones. BOOK-INGEST-AUDIT.md F24.', 'THE COUNT OF FOUR IS THE MAJOR PSIONIC''S, and the app applies that by itself: each master band carries related_skills_count: 0, so picking a master gift under Abilities drops this count to zero. The four scheduled picks at levels three, six, nine and twelve are NOT dropped - printed 185 puts that sentence after both branches rather than inside the major-psionic clause. BOOK-INGEST-AUDIT.md F24.')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, 'THE COUNT OF FOUR IS THE MAJOR PSIONIC''S: a character whose gift is a MASTER psionic (a roll of 51 or higher) gets NO O.C.C. Related Skills at all. Take four only if the gift picked under Abilities is one of the two major ones. BOOK-INGEST-AUDIT.md F24.') > 0
   AND instr(markdown, 'THE COUNT OF FOUR IS THE MAJOR PSIONIC''S, and the app applies that by itself: each master band carries related_skills_count: 0, so picking a master gift under Abilities drops this count to zero. The four scheduled picks at levels three, six, nine and twelve are NOT dropped - printed 185 puts that sentence after both branches rather than inside the major-psionic clause. BOOK-INGEST-AUDIT.md F24.') = 0;

-- the instruction in both master band descriptions
UPDATE imported_classes
   SET markdown = replace(markdown, 'A MASTER PSIONIC GETS NO O.C.C. RELATED SKILLS - take none of the four the class lists.', 'A MASTER PSIONIC GETS NO O.C.C. RELATED SKILLS, and picking this gift sets the count to zero by itself.')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, 'A MASTER PSIONIC GETS NO O.C.C. RELATED SKILLS - take none of the four the class lists.') > 0
   AND instr(markdown, 'A MASTER PSIONIC GETS NO O.C.C. RELATED SKILLS, and picking this gift sets the count to zero by itself.') = 0;

-- extraction_notes (a)
UPDATE imported_classes
   SET markdown = replace(markdown, '  - WHAT IT DOES NOT MODEL, filed as BOOK-INGEST-AUDIT.md F24:
    (a) the related-skill COUNT, which is four for a major psionic and ZERO for
    a master - neither an ability nor a variant can carry a skills block, and
    half the table rolls master, so the picker offers four related skills to a
    character the book gives none;
', '  - THE RELATED-SKILL COUNT IS CARRIED BY THE ABILITY. It is four for a major
    psionic and ZERO for a master. On the day of the import neither an ability
    nor a variant could carry it, so the picker offered four related skills to
    the half of the table the book gives none; BOOK-INGEST-AUDIT.md F24 was
    filed for that, and has been taken. An ability may now set
    related_skills_count, and each of the two master bands sets it to zero.
    The four scheduled picks at levels three, six, nine and twelve are NOT
    dropped: printed 185 puts that sentence after both branches rather than
    inside the major-psionic clause.
  - WHAT IS STILL NOT MODELLED, and stays filed under BOOK-INGEST-AUDIT.md F24:
')
 WHERE class_id = 'gypsy-gifted'
   AND instr(markdown, '  - WHAT IT DOES NOT MODEL, filed as BOOK-INGEST-AUDIT.md F24:
    (a) the related-skill COUNT, which is four for a major psionic and ZERO for
    a master - neither an ability nor a variant can carry a skills block, and
    half the table rolls master, so the picker offers four related skills to a
    character the book gives none;
') > 0
   AND instr(markdown, '  - THE RELATED-SKILL COUNT IS CARRIED BY THE ABILITY. It is four for a major
    psionic and ZERO for a master. On the day of the import neither an ability
    nor a variant could carry it, so the picker offered four related skills to
    the half of the table the book gives none; BOOK-INGEST-AUDIT.md F24 was
    filed for that, and has been taken. An ability may now set
    related_skills_count, and each of the two master bands sets it to zero.
    The four scheduled picks at levels three, six, nine and twelve are NOT
    dropped: printed 185 puts that sentence after both branches rather than
    inside the major-psionic clause.
  - WHAT IS STILL NOT MODELLED, and stays filed under BOOK-INGEST-AUDIT.md F24:
') = 0;

-- Read the result back rather than trusting the exit code.
--
-- COUNTED AS AN INDENTED KEY, not as a bare string. The note this script
-- rewrites quotes "related_skills_count: 0" in its prose, so the bare string
-- appears THREE times in the finished markdown and only two of them are keys.
-- A first version of this readback counted the bare string and wanted 2; it
-- would have failed against a correct result.
SELECT 'both master bands carry a zero related-skill count' AS assertion,
       (length(markdown) - length(replace(markdown, char(10) || '    related_skills_count: 0', '')))
         / length(char(10) || '    related_skills_count: 0') AS got, 2 AS want
  FROM imported_classes WHERE class_id = 'gypsy-gifted';

SELECT 'and neither major band carries one' AS assertion,
       instr(markdown, 'two categories"' || char(10) || '    related_skills_count')
       + instr(markdown, 'all healing"' || char(10) || '    related_skills_count') AS got,
       0 AS want
  FROM imported_classes WHERE class_id = 'gypsy-gifted';

SELECT 'the stale take-none-by-hand instruction is gone' AS assertion,
       instr(markdown, 'take none of the four the class lists') AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'gypsy-gifted';

SELECT 'and the class still states four for a major psionic' AS assertion,
       instr(markdown, 'count: 4') AS got_nonzero
  FROM imported_classes WHERE class_id = 'gypsy-gifted';

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-gypsy-gifted-related-skill-count.sql');
