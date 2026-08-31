-- The +5% on "Rogue: Prowl only" lands now, so stop saying it does not.
--
-- BOOK-INGEST-AUDIT.md F9, taken in PR #424. `categoryBonus` now scores a pick
-- against the entry that ADMITTED it when that entry carries a percentage of
-- its own, so the Vacuum Wasp and the Termite Engineer both get the +5% their
-- book prints beside Rogue.
--
-- Both classes' extraction_notes describe the old behaviour as current and
-- correct. It was, on the day it was written. It is not now, and a note
-- asserting a limit that no longer exists is durable in exactly the wrong way:
-- the next session reads it and believes it. This is the FOURTH note of this
-- shape corrected in this book (the noro mind-control save, the Apok's
-- bonuses.attributes, the Repo-Bot's fixed attribute, and now these two).
--
-- NO NUMBER MOVES IN THIS SCRIPT. The +5% is applied by the parser, not stored
-- on the row - the class markdown already says `bonus: 5` on the Rogue entry
-- and always did. What was missing was the code that read it. This script edits
-- prose only, which is why there is no readback on a percentage.
--
-- The Phaeton Juicer is the third row F9 names and needs no edit: it carries no
-- note about the behaviour, so there is nothing to correct.
--
-- Guarded on the text it replaces, so re-running is a no-op.

UPDATE imported_classes
SET markdown = replace(markdown,
  'ROGUE: PROWL ONLY IS A CROSS-CATEGORY GRANT AND ITS +5% DOES NOT LAND. The
    catalog files Prowl under Physical, and `categoryAllows` admits a
    cross-category `only` because the class also lists Physical, so the skill is
    reachable. `categoryBonus` deliberately keys on the skill''s REAL category,
    so the +5% printed beside Rogue is not applied to it. The category label
    still shows the player "Rogue (Prowl only; +5%)", which is what the book
    prints. Recorded rather than worked around: moving Prowl into the Physical
    entry would hand Swimming and Climbing a bonus the book never gave them.',
  'ROGUE: PROWL ONLY IS A CROSS-CATEGORY GRANT, AND ITS +5% LANDS. The catalog
    files Prowl under Physical, and `categoryAllows` admits a cross-category
    `only` because the class also lists Physical, so the skill is reachable. At
    import the +5% was NOT applied: `categoryBonus` keyed on the skill''s real
    category only, so the picker showed the player "Rogue (Prowl only; +5%)"
    while the sheet gave nothing. BOOK-INGEST-AUDIT.md F9 HAS SINCE BEEN TAKEN -
    a pick admitted by a cross-category `only` is now scored by the entry that
    admitted it, when that entry carries a percentage of its own. Moving Prowl
    into the Physical entry is still the wrong fix and was never done: it would
    hand Swimming and Climbing a bonus the book never gave them.')
WHERE class_id = 'vacuum-wasp'
  AND instr(markdown, 'ITS +5% DOES NOT LAND') > 0;

UPDATE imported_classes
SET markdown = replace(markdown,
  'ROGUE: PROWL ONLY IS A CROSS-CATEGORY GRANT AND ITS +5% DOES NOT LAND. The
    catalog files Prowl under Physical, and `categoryAllows` admits a
    cross-category `only` because the class also lists Physical, so the skill is
    reachable. `categoryBonus` deliberately keys on the skill''s REAL category,
    so the +5% printed beside Rogue is not applied to it. Same as the Vacuum
    Wasp in this batch.',
  'ROGUE: PROWL ONLY IS A CROSS-CATEGORY GRANT, AND ITS +5% LANDS. The catalog
    files Prowl under Physical, and `categoryAllows` admits a cross-category
    `only` because the class also lists Physical, so the skill is reachable. At
    import the +5% was NOT applied: `categoryBonus` keyed on the skill''s real
    category only. BOOK-INGEST-AUDIT.md F9 HAS SINCE BEEN TAKEN - a pick
    admitted by a cross-category `only` is now scored by the entry that admitted
    it, when that entry carries a percentage of its own. Same as the Vacuum Wasp
    in this batch.')
WHERE class_id = 'termite-engineer'
  AND instr(markdown, 'ITS +5% DOES NOT LAND') > 0;

-- Readback: the stale claim is gone from both and the corrected one is present.
SELECT class_id,
       instr(markdown, 'ITS +5% DOES NOT LAND') AS stale_claim_gone,
       instr(markdown, 'ITS +5% LANDS') > 0 AS correction_present,
       instr(markdown, 'bonus: 5') > 0 AS rogue_bonus_still_stored
FROM imported_classes
WHERE class_id IN ('vacuum-wasp', 'termite-engineer')
ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-cross-category-bonus-notes.sql');
