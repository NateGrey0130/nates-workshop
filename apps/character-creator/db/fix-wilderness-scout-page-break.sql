-- The Wilderness Scout completed past the page break, RUE printed p.100
-- (scan file .cache/books/rue/txt/p103.txt).
--
-- One-off data script, run once per environment. NOT a migration - it edits
-- a row, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-wilderness-scout-page-break.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-wilderness-scout-page-break.sql
--
-- The original transcription stopped where its supplied pages did, and said
-- so twice: "the list appears cut off after 'infrared binoculars with
-- digital distancing readout, a pair'" and "Money and Cybernetics sections
-- ... appear to belong to a following page not included". The class-check
-- --field-sources sweep of 2026-08-25 surfaced the missing half in the OCR
-- cache - the equipment paragraph ends at the bottom of p102 and continues
-- on p103, followed by the Money and Cybernetics paragraphs - so this script
-- folds it in: the pair of passive nightvision goggles the note's "a pair
-- of ???" was reaching for, a telescopic gun sight, the starting vehicle,
-- and starting_money. No new catalog rows: every item resolves to an
-- existing gear slug.
--
-- Money: 3D6x100 in credits plus another 3D4x1000 in Black Market items or
-- animal pelts and furs. starting_money holds the credits - the goods are
-- not coin - and the split is recorded in the extraction notes.

-- The citation grows to the page the stat block actually ends on. The old
-- range was itself an artifact of the truncated reading, and the
-- --field-sources window is built from this line.
UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.98-99', 'source_book: Rifts Ultimate Edition p.98-100')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.98-99') > 0;

-- starting_money, ahead of the equipment block. Guarded on the key being
-- absent, so re-running is a no-op.
UPDATE imported_classes
   SET markdown = replace(markdown, 'equipment_starting:
', 'starting_money: "3d6x100"
equipment_starting:
')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'starting_money:') = 0;

-- The three items the page break cut off, exactly where the list stopped.
UPDATE imported_classes
   SET markdown = replace(markdown, '  - { item_id: "infrared-binoculars-digital-distancing-readout", qty: 1 }', '  - { item_id: "infrared-binoculars-digital-distancing-readout", qty: 1 }
  - { item_id: "passive-nightvision", qty: 1, label: "a pair of passive nightvision goggles" }
  - { item_id: "telescopic-scope", qty: 1, label: "telescopic sight for a gun" }
  - { choose: 1, label: "old or shabby looking, but reliable vehicle (missing 1D4x10% of its original M.D.C.) that matches Piloting skill", qty: 1, from: ["hovercycle", "jeep", "riding-horse"], note: "The book names no specific vehicle; this is the catalog set, widened as more books are imported." }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'passive-nightvision') = 0;

-- Both stale extraction notes stop claiming the fields are missing, because
-- leaving them would contradict the data they sit beside. The first search
-- starts after the note's em-dash so this file stays pure ASCII.
UPDATE imported_classes
   SET markdown = replace(markdown, 'remaining
    items (a pair of ??? and beyond) are not captured because the source page
    ends mid-sentence.', 'remaining
    items were read from the following page of the scan (cache file p103) and
    folded in by fix-wilderness-scout-page-break.sql: a pair of passive
    nightvision goggles, a telescopic sight for a gun, and an old or shabby
    looking, but reliable vehicle (missing 1D4x10% of its original M.D.C.)
    that matches Piloting skill.')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '(a pair of ??? and beyond)') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - Money and Cybernetics sections for this class were not visible on the
    provided pages (they appear to belong to a following page not included).', '  - Money and Cybernetics (cache file p103): starts with 3D6x100 in credits
    and another 3D4x1000 in Black Market items or animal pelts and furs -
    starting_money holds the credits, and the goods are not coin.
    Cybernetics: most avoid unnatural cybernetic augmentation except when
    needed as a prosthetic; prose, since the app has no cybernetics
    mechanic.')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, 'they appear to belong to a following page not included') > 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'p.98-100') > 0 AS citation_grown,
       instr(markdown, 'starting_money: "3d6x100"') > 0 AS money_added,
       instr(markdown, 'passive-nightvision') > 0 AS equipment_tail_added,
       instr(markdown, 'fix-wilderness-scout-page-break.sql') > 0 AS note_updated,
       instr(markdown, 'a pair of ??? and beyond') > 0 AS stale_note_left,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'wilderness-scout';

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-wilderness-scout-page-break.sql');
