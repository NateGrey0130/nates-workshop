-- The Phantom's reason for not storing a zero has evaporated. Say so.
--
-- BOOK-INGEST-AUDIT.md F8 was taken in PR #422: a bare integer in
-- `attribute_dice` is now a FIXED value, returned unchanged. The Phantom's
-- extraction_notes explain that storing "0" would have been WORSE than the
-- compromise it chose, because rollAttribute would have discarded it and rolled
-- 3d6. That was measured and true when written. It is false now - "0" stores as
-- 0 exactly.
--
-- THE DECISION STANDS; ONLY ITS REASON CHANGED, and that distinction is the
-- whole point of this script. The book prints "P.S. 0 (4D6), P.P. 0 (4D6)":
-- zero in energy form, 4D6 for the physical shell. The sheet has ONE field per
-- attribute, and the shell's number is the one a player uses whenever a
-- physical attribute means anything - so the shell's 4D6 is still what is
-- stored. No attribute value moves in this script. What changes is that the
-- note no longer offers a defunct limitation as the justification.
--
-- WHY THIS IS A SEPARATE SCRIPT FROM #422's. The Phantom was MISSED when F8
-- shipped. Two published classes cite F8 and only one was corrected, which is
-- the failure now filed as F12: a class note that records the app's current
-- limits ages badly, and finding every citer is a sweep nobody was doing.
--
-- Guarded on the text it replaces, so re-running is a no-op.

UPDATE imported_classes
SET markdown = replace(markdown,
  'Storing 0 would have
    been worse than a compromise: `rollAttribute` in js/dice.js only parses NdM
    forms and FALLS BACK TO 3d6 on anything else, silently, reporting "3d6" as
    the notation it used. Measured this session; see BOOK-INGEST-AUDIT.md F8.',
  'Storing 0 was not possible when this class was imported, and it is now:
    `rollAttribute` in js/dice.js then parsed only NdM forms and fell back to
    3d6 on anything else, silently, reporting "3d6" as the notation it used, so
    a stored 0 would have rendered as an ordinary human. BOOK-INGEST-AUDIT.md F8
    HAS SINCE BEEN TAKEN and a bare integer is a fixed value. THE SHELL''S 4D6
    IS STILL WHAT IS STORED, for the reason above rather than that one: there is
    one field per attribute and the shell''s number is the one a player uses
    whenever a physical attribute means anything at all. The energy form''s zero
    is stated in the Energy Form ability.')
WHERE class_id = 'phantom'
  AND instr(markdown, 'Storing 0 would have') > 0;

-- Readback: the stale reason is gone, the correction is present, and the stored
-- attributes are untouched - 4d6 for both, exactly as before.
SELECT class_id,
       instr(markdown, 'Storing 0 would have') AS stale_reason_gone,
       instr(markdown, 'HAS SINCE BEEN TAKEN') > 0 AS correction_present,
       instr(markdown, 'PS: ' || char(34) || '4d6' || char(34)) > 0 AS ps_unchanged,
       instr(markdown, 'PP: ' || char(34) || '4d6' || char(34)) > 0 AS pp_unchanged
FROM imported_classes
WHERE class_id = 'phantom';

INSERT INTO data_script_runs (filename) VALUES ('fix-phantom-fixed-attribute-note.sql');
