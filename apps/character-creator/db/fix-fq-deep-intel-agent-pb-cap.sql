-- Store the Deep Intel Agent's P.B. cap in the key that now exists for it.
--
-- BOOK-INGEST-AUDIT.md F32, taken in PR #824. That PR adds `attribute_maximums`;
-- this moves the one published class that needed it out of prose and into the
-- field. It is the class that filed the finding.
--
-- Free Quebec printed 32: "Attribute Requirements: I.Q. 10 and M.A. 10 or
-- higher (the higher the better), and a P.B. of 12 or lower (they want average
-- looking people)." Both halves come off ONE line, and only the first half
-- could be stored until now. `attribute_requirements` is minimums - merged with
-- Math.max, rendered "PB 12+" - so the cap written there would have demanded a
-- beauty of at least 12 from a class whose whole point is looking unremarkable.
--
-- THE RESTRICTION LINE STAYS, shortened. What comes off it is the half that is
-- now false - "Stored here rather than in attribute_requirements, which holds
-- minimums only" - not the book's own sentence, which a player and a GM should
-- still read where the class lists what it forbids. The cap being modelled does
-- not make it less true.
--
-- Three replaces rather than a full-block rewrite, because each anchors on a
-- string unique in this class's markdown and a rewrite would restate 100 lines
-- to change 3.

-- 1. The key itself, inline so it stays on one line: the frontmatter parser is
--    line-based, and a wrapped value is the failure that costs a whole class.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'attribute_requirements:' || char(10) || '  IQ: 10' || char(10) || '  MA: 10',
         'attribute_requirements:' || char(10) || '  IQ: 10' || char(10) || '  MA: 10'
           || char(10) || 'attribute_maximums: { PB: 12 }'),
       updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent';

-- 2. The restriction keeps the book's sentence and loses the storage claim.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'P.B. must be 12 or LOWER - the SQ wants average looking people. Stored here rather than in attribute_requirements, which holds minimums only; see extraction_notes.',
         'P.B. must be 12 or LOWER - the SQ wants average looking people.'),
       updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent';

-- 3. The extraction note, past-tense and naming the PR, per `audit-menu`:
--    a class note records what the book prints and what was stored, and the
--    "what the app could do that day" half is what rots when a finding is taken.
UPDATE imported_classes
   SET markdown = replace(markdown,
         'THE P.B. CAP IS NOT STORED AS A REQUIREMENT. The book prints ''a P.B. of 12 or lower (they want average looking people)'', which is a MAXIMUM, and attribute_requirements holds minimums only - it is combined with Math.max and rendered as ''PB 12+''. Writing it there would state the exact inverse of the book, silently. See BOOK-INGEST-AUDIT.md F32. It is in restrictions instead, where a player and a GM both see it.',
         'THE P.B. CAP IS STORED IN attribute_maximums. The book prints ''a P.B. of 12 or lower (they want average looking people)'', which is a MAXIMUM; attribute_requirements holds minimums only, merged with Math.max and rendered ''PB 12+'', so the cap could not go there and lived in restrictions as prose until BOOK-INGEST-AUDIT.md F32 was taken (PR #824). It is ADVISORY: the wizard shows it and the server warns, and neither refuses the character - the posture every attribute check in this app already has.'),
       updated_at = datetime('now')
 WHERE class_id = 'fq-deep-intel-agent';

-- Every replace must have bitten. A replace() that matches nothing succeeds
-- silently and leaves the row exactly as it was, which is the failure mode this
-- whole script shape has: it cannot be told from a row that was already right.
SELECT CASE
         WHEN instr(markdown, 'attribute_maximums: { PB: 12 }') = 0 THEN 'FAIL: key not added'
         WHEN instr(markdown, 'Stored here rather than') > 0 THEN 'FAIL: restriction not shortened'
         WHEN instr(markdown, 'THE P.B. CAP IS NOT STORED') > 0 THEN 'FAIL: note not rewritten'
         WHEN instr(markdown, 'THE P.B. CAP IS STORED IN attribute_maximums') = 0 THEN 'FAIL: note missing'
         ELSE 'ok'
       END AS result
  FROM imported_classes
 WHERE class_id = 'fq-deep-intel-agent';
