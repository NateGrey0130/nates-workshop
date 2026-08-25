-- The Body Fixer completed past the page break, RUE printed p.88 (scan file
-- .cache/books/rue/txt/p091.txt).
--
-- One-off data script, run once per environment. NOT a migration - it adds
-- and edits rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-body-fixer-page-break.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-body-fixer-page-break.sql
--
-- The original transcription stopped where its supplied pages did, and said
-- so: the extraction note reads "the remainder of the equipment list and
-- Money/Cybernetics sections are not present on the supplied pages". The
-- class-check --field-sources sweep of 2026-08-25 surfaced the missing half
-- sitting in the OCR cache - the equipment paragraph ends at the bottom of
-- p090 and continues on p091, followed by the Money paragraph - so this
-- script folds it in: eighteen standalone items after the medical kit's
-- parenthetical closes, three of-choice groups modelled the way the SAMAS
-- pilot models "of choice", and starting_money. The book prints no
-- Cybernetics section for this class; "and other basic items" and "some
-- personal items" stay prose.
--
-- Money is conditional: 5D6x1000 credits for a city/Burbs doctor, 1D6x1000
-- credits plus 3D6x1000 in Black Market saleable items for a wandering one.
-- starting_money holds the city figure - the goods are not coin - and the
-- split is recorded in the extraction notes.

-- Four items the catalog does not have yet. Stub shape from class-check, so
-- the gear importer later recognises them as unfilled; cited to p.88, the
-- page they are actually printed on.
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('hand-held-blood-pressure-machine', 'Hand Held Blood Pressure Machine', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.88');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('unbreakable-vial', 'Unbreakable Vial', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.88');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('medical-bag', 'Medical Bag', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.88');
INSERT OR IGNORE INTO gear (slug, name, system, description, source_book) VALUES ('poncho', 'Poncho', 'rifts', 'STUB ' || char(8212) || ' created by class import, needs stats', 'Rifts Ultimate Edition p.88');

-- The citation grows to the page the stat block actually ends on. The old
-- range was itself an artifact of the truncated reading, and the
-- --field-sources window is built from this line.
UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.86-87', 'source_book: Rifts Ultimate Edition p.86-88')
 WHERE class_id = 'body-fixer' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.86-87') > 0;

-- starting_money, ahead of the equipment block. Guarded on the key being
-- absent, so re-running is a no-op.
UPDATE imported_classes
   SET markdown = replace(markdown, 'equipment_starting:
', 'starting_money: "5d6x1000"
equipment_starting:
')
 WHERE class_id = 'body-fixer' AND instr(markdown, 'starting_money:') = 0;

-- The rest of the equipment list, exactly where the page break cut it.
UPDATE imported_classes
   SET markdown = replace(markdown, '  - { item_id: "medical-kit", qty: 1 }', '  - { item_id: "medical-kit", qty: 1 }
  - { item_id: "irmss-internal-robot-medical-surgeon-system", qty: 1, label: "IRMSS/Internal Robot Micro-Surgeon System" }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1, label: "RMK/Robot Medical Kit" }
  - { item_id: "hand-held-computer", qty: 1 }
  - { item_id: "hand-held-blood-pressure-machine", qty: 1, label: "computerized" }
  - { item_id: "thermometer", qty: 1 }
  - { item_id: "unbreakable-vial", qty: 6 }
  - { item_id: "compu-drug-dispenser", qty: 1, label: "portable compu-drug dispenser" }
  - { item_id: "portable-laboratory", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "medical-bag", qty: 1, label: "medical bag or satchel" }
  - { item_id: "e-clip", qty: 2, label: "one weapon for each W.P. and two E-Clips for each" }
  - { item_id: "vibro-knife", qty: 1, label: "1D6 M.D." }
  - { item_id: "scalpel", qty: 2, label: "1D4 S.D.C. damage" }
  - { item_id: "wilk-s-laser-scalpel", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pen-flashlight", qty: 1 }
  - { choose: 1, label: "commercial vehicle (as per Pilot skill) or a horse (if he can ride)", qty: 1, from: ["hovercycle", "jeep", "riding-horse"], note: "The book names no specific vehicle; this is the catalog set, widened as more books are imported." }
  - { choose: 1, label: "hat with a brim", qty: 1, from: ["hat-short-brim", "hat-large-brim"] }
  - { choose: 1, label: "hooded cape or poncho", qty: 1, from: ["cape-long-hooded", "poncho"] }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "sunglasses", qty: 1, label: "a pair of sunglasses" }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "note-pad", qty: 1, label: "pocket note pad" }
  - { item_id: "pen", qty: 2 }')
 WHERE class_id = 'body-fixer' AND instr(markdown, 'irmss-internal-robot-medical-surgeon-system') = 0;

-- The extraction note stops claiming the fields are unextractable, because
-- leaving it would contradict the data it sits beside. The search starts
-- after the note's em-dash so this file stays pure ASCII.
UPDATE imported_classes
   SET markdown = replace(markdown, 'the remainder of the equipment
    list and Money/Cybernetics sections are not present on the supplied pages
    and could not be extracted.', 'the remainder of the equipment
    list and the Money section were read from the following page of the scan
    (cache file p091) and folded in by fix-body-fixer-page-break.sql; the
    book prints no Cybernetics section for this class. Money is conditional -
    a city/Burbs doctor starts with 5D6x1000 credits, while a wandering Body
    Fixer has 1D6x1000 credits plus 3D6x1000 in Black Market saleable items -
    starting_money holds the city figure, and the goods are not coin. The
    page closes the list with "and other basic items" and "some personal
    items", which are prose, not gear.')
 WHERE class_id = 'body-fixer' AND instr(markdown, 'sections are not present on the supplied pages') > 0;

-- Read the result back rather than trusting the exit code.
SELECT class_id,
       instr(markdown, 'p.86-88') > 0 AS citation_grown,
       instr(markdown, 'starting_money: "5d6x1000"') > 0 AS money_added,
       instr(markdown, '- { item_id: "pen", qty: 2 }') > 0 AS equipment_tail_added,
       instr(markdown, 'fix-body-fixer-page-break.sql') > 0 AS note_updated,
       instr(markdown, 'not present on the supplied pages') > 0 AS stale_note_left,
       instr(markdown, char(13)) > 0 AS has_cr
  FROM imported_classes WHERE class_id = 'body-fixer';
SELECT count(*) AS stub_rows_present FROM gear
 WHERE slug IN ('hand-held-blood-pressure-machine', 'unbreakable-vial', 'medical-bag', 'poncho');

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-body-fixer-page-break.sql');
