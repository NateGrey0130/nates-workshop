-- Correct three class notes that describe an app limit which no longer exists.
--
-- BOOK-INGEST-AUDIT.md F12, taken in PR #NNN. F12 says an `extraction_notes`
-- entry does two jobs in one paragraph - what the BOOK prints, which is
-- permanent, and what the APP could do on the day of the import, which is not -
-- and that nothing sweeps the classes citing a finding when it is taken.
--
-- F12 was filed saying it "repairs nothing already shipped", because the five
-- occurrences it lists were all corrected by hand. THREE MORE APPEARED WHILE IT
-- SAT ON THE MENU, all from PRs merged the same day F12 was taken:
--
--   first-stage-promethean   F10, PR #429   "are discarded" - they now merge
--   promethean-phase-adept   F10, PR #429   "are dropped"   - they now merge
--   fallen-cosmo-knight      F11, PR #430   "equally unstorable" - the key exists
--
-- The first two are plainly false. The third is subtler and worth the longer
-- rewrite: the rule IS storable now, and this class deliberately does not carry
-- the flag, for a reason the note has to give or the omission reads as an
-- oversight.
--
-- Found by `node scripts/audit-citations.mjs --remote`, which this PR adds -
-- the finding's part 3. It listed seven passages carrying limitation language
-- beside a citation; three were stale and four describe limits that are still
-- real. That ratio is the argument for the posture: the command lists what to
-- re-read and has no opinion about whether any finding was taken.
--
-- Each statement is guarded on its own result being absent as well as its
-- anchor being present, so a re-run is a no-op.

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THIS RACE''S PSIONICS DISPLACE THE PHASE ADEPT''S WHEN THE TWO ARE PLAYED' || char(10) || '    TOGETHER. combineClasses in js/parser.js keeps whichever block is STRICTLY' || char(10) || '    higher, and "Considered a master psionic" on printed 26 puts this race at' || char(10) || '    the top of the ladder, so no O.C.C. block can ever beat it: the Phase' || char(10) || '    Adept''s six phase powers, its super-psionic pick and its whole level' || char(10) || '    schedule are discarded. Measured against the real parser rather than' || char(10) || '    reasoned about. The Promethean Time Master is untouched, because it states' || char(10) || '    no psionics of its own. Filed as BOOK-INGEST-AUDIT.md F10, which also' || char(10) || '    records the two noro O.C.C.s that have already shipped in this shape.',
       '  - THIS RACE''S PSIONICS MERGE WITH THE PHASE ADEPT''S WHEN THE TWO ARE PLAYED' || char(10) || '    TOGETHER. "Considered a master psionic" on printed 26 puts this race at the' || char(10) || '    top of the ladder, and the tier is still the stronger of the two - but the' || char(10) || '    rest of the block now folds together rather than being chosen between, so' || char(10) || '    the Phase Adept''s phase-power groups and its twenty-eight schedule entries' || char(10) || '    arrive alongside this race''s four granted powers and three starting picks.' || char(10) || '    The Promethean Time Master states no psionics of its own and is unaffected.' || char(10) || '    BOOK-INGEST-AUDIT.md F10, taken in PR #429.'),
       updated_at = datetime('now')
 WHERE class_id = 'first-stage-promethean'
   AND instr(markdown, '  - THIS RACE''S PSIONICS DISPLACE THE PHASE ADEPT''S WHEN THE TWO ARE PLAYED' || char(10) || '    TOGETHER. combineClasses in js/parser.js keeps whichever block is STRICTLY' || char(10) || '    higher, and "Considered a master psionic" on printed 26 puts this race at' || char(10) || '    the top of the ladder, so no O.C.C. block can ever beat it: the Phase' || char(10) || '    Adept''s six phase powers, its super-psionic pick and its whole level' || char(10) || '    schedule are discarded. Measured against the real parser rather than' || char(10) || '    reasoned about. The Promethean Time Master is untouched, because it states' || char(10) || '    no psionics of its own. Filed as BOOK-INGEST-AUDIT.md F10, which also' || char(10) || '    records the two noro O.C.C.s that have already shipped in this shape.') > 0
   AND instr(markdown, '  - THIS RACE''S PSIONICS MERGE WITH THE PHASE ADEPT''S WHEN THE TWO ARE PLAYED' || char(10) || '    TOGETHER. "Considered a master psionic" on printed 26 puts this race at the' || char(10) || '    top of the ladder, and the tier is still the stronger of the two - but the' || char(10) || '    rest of the block now folds together rather than being chosen between, so' || char(10) || '    the Phase Adept''s phase-power groups and its twenty-eight schedule entries' || char(10) || '    arrive alongside this race''s four granted powers and three starting picks.' || char(10) || '    The Promethean Time Master states no psionics of its own and is unaffected.' || char(10) || '    BOOK-INGEST-AUDIT.md F10, taken in PR #429.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THIS CLASS''S PSIONICS ARE DISCARDED WHEN IT IS PLAYED ON ITS OWN RACE, WHICH' || char(10) || '    IS THE ONLY WAY THE BOOK ALLOWS IT TO BE PLAYED. combineClasses in' || char(10) || '    js/parser.js keeps whichever psionics block is STRICTLY the higher tier, so' || char(10) || '    the First Stage Promethean''s block stays and all six phase powers, the' || char(10) || '    super-psionic pick and the twenty-eight schedule entries above are dropped.' || char(10) || '    Measured against the real parser, not reasoned about. THE TIER ABOVE IS NOT' || char(10) || '    WHAT CAUSES THIS and lowering it would not help: master is the top of the' || char(10) || '    ladder, the race holds it, and the comparison is strict, so this block loses' || char(10) || '    at every tier it could carry. Filed as BOOK-INGEST-AUDIT.md F10. Nothing' || char(10) || '    about this class is written down differently because of it: the block is' || char(10) || '    what the book prints, and the finding is where the gap is recorded.',
       '  - THIS CLASS''S PSIONICS SURVIVE BEING PLAYED ON ITS OWN RACE, which is the' || char(10) || '    only way the book allows it to be played. They did not: composition kept' || char(10) || '    whichever block was strictly the higher tier, and master is the top of the' || char(10) || '    ladder with the First Stage Promethean already holding it, so the six phase' || char(10) || '    powers, the super-psionic pick and the twenty-eight schedule entries were' || char(10) || '    all dropped - and lowering the tier could not have rescued them. Both' || char(10) || '    blocks now merge. Nothing about this class is written down differently' || char(10) || '    because of it: the block is what the book prints.' || char(10) || '    BOOK-INGEST-AUDIT.md F10, taken in PR #429.'),
       updated_at = datetime('now')
 WHERE class_id = 'promethean-phase-adept'
   AND instr(markdown, '  - THIS CLASS''S PSIONICS ARE DISCARDED WHEN IT IS PLAYED ON ITS OWN RACE, WHICH' || char(10) || '    IS THE ONLY WAY THE BOOK ALLOWS IT TO BE PLAYED. combineClasses in' || char(10) || '    js/parser.js keeps whichever psionics block is STRICTLY the higher tier, so' || char(10) || '    the First Stage Promethean''s block stays and all six phase powers, the' || char(10) || '    super-psionic pick and the twenty-eight schedule entries above are dropped.' || char(10) || '    Measured against the real parser, not reasoned about. THE TIER ABOVE IS NOT' || char(10) || '    WHAT CAUSES THIS and lowering it would not help: master is the top of the' || char(10) || '    ladder, the race holds it, and the comparison is strict, so this block loses' || char(10) || '    at every tier it could carry. Filed as BOOK-INGEST-AUDIT.md F10. Nothing' || char(10) || '    about this class is written down differently because of it: the block is' || char(10) || '    what the book prints, and the finding is where the gap is recorded.') > 0
   AND instr(markdown, '  - THIS CLASS''S PSIONICS SURVIVE BEING PLAYED ON ITS OWN RACE, which is the' || char(10) || '    only way the book allows it to be played. They did not: composition kept' || char(10) || '    whichever block was strictly the higher tier, and master is the top of the' || char(10) || '    ladder with the First Stage Promethean already holding it, so the six phase' || char(10) || '    powers, the super-psionic pick and the twenty-eight schedule entries were' || char(10) || '    all dropped - and lowering the tier could not have rescued them. Both' || char(10) || '    blocks now merge. Nothing about this class is written down differently' || char(10) || '    because of it: the block is what the book prints.' || char(10) || '    BOOK-INGEST-AUDIT.md F10, taken in PR #429.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '    take-the-higher rule the Cosmo-Knight states is inherited with the' || char(10) || '    attributes and is equally unstorable; see BOOK-INGEST-AUDIT.md F11, whose' || char(10) || '    measurements cover this class too.',
       '    take-the-higher rule the Cosmo-Knight states is inherited with the' || char(10) || '    attributes, and THIS CLASS DELIBERATELY DOES NOT CARRY `supersedes_race`.' || char(10) || '    The key exists (BOOK-INGEST-AUDIT.md F11, taken in PR #430) and the' || char(10) || '    Cosmo-Knight carries it, but this entry states its attributes on printed 103' || char(10) || '    as "use the cosmo-knight attributes, but reduce them as follows" - a' || char(10) || '    different rule. A fallen knight whose original race had the higher P.S.' || char(10) || '    should carry that race''s number REDUCED by the printed 22, where the flag' || char(10) || '    would hand it the race''s number untouched. It wants a rule the key cannot' || char(10) || '    express, so composition still gives this class''s pools and skills to the' || char(10) || '    race; F11''s measurements cover it and its outcome note says why.'),
       updated_at = datetime('now')
 WHERE class_id = 'fallen-cosmo-knight'
   AND instr(markdown, '    take-the-higher rule the Cosmo-Knight states is inherited with the' || char(10) || '    attributes and is equally unstorable; see BOOK-INGEST-AUDIT.md F11, whose' || char(10) || '    measurements cover this class too.') > 0
   AND instr(markdown, '    take-the-higher rule the Cosmo-Knight states is inherited with the' || char(10) || '    attributes, and THIS CLASS DELIBERATELY DOES NOT CARRY `supersedes_race`.' || char(10) || '    The key exists (BOOK-INGEST-AUDIT.md F11, taken in PR #430) and the' || char(10) || '    Cosmo-Knight carries it, but this entry states its attributes on printed 103' || char(10) || '    as "use the cosmo-knight attributes, but reduce them as follows" - a' || char(10) || '    different rule. A fallen knight whose original race had the higher P.S.' || char(10) || '    should carry that race''s number REDUCED by the printed 22, where the flag' || char(10) || '    would hand it the race''s number untouched. It wants a rule the key cannot' || char(10) || '    express, so composition still gives this class''s pools and skills to the' || char(10) || '    race; F11''s measurements cover it and its outcome note says why.') = 0;

-- Readback: none of the three still asserts the old behaviour, and each now
-- names the PR that changed it. One SELECT rather than a UNION - D1 rejects a
-- compound SELECT past five terms and rolls the whole file back.
SELECT class_id,
       instr(markdown, 'are discarded. Measured')
         + instr(markdown, 'entries above are dropped')
         + instr(markdown, 'equally unstorable') AS stale_claims,
       (instr(markdown, 'taken in PR #429') > 0)
         + (instr(markdown, 'taken in PR #430') > 0) AS names_the_pr
  FROM imported_classes
 WHERE class_id IN ('first-stage-promethean', 'promethean-phase-adept',
                    'fallen-cosmo-knight')
 ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-stale-finding-citations.sql');
