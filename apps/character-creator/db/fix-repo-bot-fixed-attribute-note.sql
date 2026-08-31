-- Correct the Naruni Repo-Bot's note about fixed attribute values.
--
-- BOOK-INGEST-AUDIT.md F8 was taken (PR #422): `attribute_dice` now accepts a
-- bare integer as a FIXED value, returns it unchanged, and reports its own
-- notation. The Repo-Bot's extraction_notes described that limitation as
-- current and measured -- which it was on the day it was written and is not
-- now. A note asserting a limit that no longer exists is the failure mode this
-- book has already been bitten by twice (the noro mind-control save, the Apok's
-- bonuses.attributes), and it is durable: the next session reads it and
-- believes it.
--
-- WHAT THIS DOES NOT DO. It does not add `PS: "50"` to the class. The app could
-- now hold it, but changing a published class's attributes changes the
-- characters made from it, and that is a decision rather than a consequence of
-- taking F8. The note now says the option is open and why it was not taken here.
--
-- The P.P. 26 remains unstorable for a DIFFERENT reason that F8 does not
-- touch and this fix does not change: the book heads that stat block
-- "Bonuses (Includes P.P. bonuses)", so the printed +8 to strike, parry and
-- dodge already contains it and js/derive.js would add its own on top.
--
-- Guarded on the text it replaces, so re-running is a no-op.

UPDATE imported_classes
SET markdown = replace(markdown,
  'BEEN SILENTLY WORSE THAN LEAVING THEM OUT. `attribute_dice` values go through
    `rollAttribute` in js/dice.js, which parses only NdM forms and FALLS BACK TO
    3d6 on anything else - measured this session: rollAttribute("50") returns 9
    and reports its notation as "3d6". A fixed attribute therefore stores as a
    number that reads correct in the data and renders as an ordinary human.
    One published class already carries this - the Holy Terror''s `PS: "50"`, from
    Wormwood - and it is the only one of 148. Filed as BOOK-INGEST-AUDIT.md F8
    and NOT fixed here, per the standing constraint on this book.',
  'BEEN SILENTLY WORSE THAN LEAVING THEM OUT WHEN THIS CLASS WAS IMPORTED, AND
    THAT IS NO LONGER TRUE. At import, `attribute_dice` values went through
    `rollAttribute` in js/dice.js, which read only NdM forms, fell back to 3d6
    on anything else, and rewrote the notation to match - so a fixed attribute
    stored as a number that read correct in the data and rendered as an ordinary
    human. BOOK-INGEST-AUDIT.md F8 was filed for it and has since been taken:
    a bare integer is now a fixed value, returned unchanged, reporting its own
    notation, and it is its own ceiling for the server-side attribute gate. The
    one published class already carrying one, the Holy Terror''s `PS: "50"` from
    Wormwood, was corrected by that change alone and needed no edit.
    THE P.S. 50 IS STILL NOT STORED HERE, and that is now a choice rather than a
    limit: adding it would change every character made from this class, which is
    a decision to take on its own rather than a side effect of fixing the
    mechanism. Both figures remain in the Robot Attributes ability.')
WHERE class_id = 'naruni-repo-bot'
  AND instr(markdown, 'measured this session: rollAttribute("50") returns 9') > 0;

-- Readback: the stale claim is gone and the corrected one is present.
SELECT class_id,
       instr(markdown, 'measured this session: rollAttribute("50") returns 9') AS stale_claim_gone,
       instr(markdown, 'has since been taken') > 0 AS correction_present,
       instr(markdown, 'Bonuses (Includes P.P. bonuses)') > 0 AS pp_reason_untouched
FROM imported_classes
WHERE class_id = 'naruni-repo-bot';

INSERT INTO data_script_runs (filename) VALUES ('fix-repo-bot-fixed-attribute-note.sql');
