-- RETRO-AUDIT R3: the Warlock's notes, corrected. NOTE-ONLY BY DECISION.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzzzz-retro-r3-warlock-notes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzzzz-retro-r3-warlock-notes.sql
--
-- R3 AS FILED WAS LARGELY WRONG, and this script records that rather than
-- implementing it. The finding said the Warlock was missing `magic.spells_from`
-- the way the Elemental Fusionists were before CLASS-AUDIT S1. It is not the
-- same case:
--
--   * The Fusionists' orientation is fixed by the CLASS - there are two of them,
--     elemental-fusionist-fire-water and elemental-fusionist-earth-air - so a
--     class-level spells_from names exactly the right spells.
--   * The Warlock's Force is chosen PER CHARACTER, and its variants are
--     `one-force` and `two-forces`: they record HOW MANY Forces, not WHICH. The
--     app has nowhere to put "this Warlock chose Fire".
--
-- So a class-level spells_from could only be the union of all four spheres: 37
-- level-1 elemental spells where a Fire Warlock should see 9. Measured against
-- production 2026-09-04: 231 elemental spells, 37 at level 1 (Air 7, Earth 11,
-- Fire 9, Water 10), against 50 level-1 spells in the whole catalog.
--
-- The class's own extraction_notes ALREADY say this, accurately: "The ELEMENT
-- choice itself is per-character and has no schema shape ... the wizard's spell
-- picker filters by level, not by sphere", and they name the filter-box
-- workaround. That note is TRUE and is left exactly as it stands.
--
-- TWO THINGS ARE WRONG, and only these two are touched:
--   1. A restriction says the variant "records which" Force. It does not - it
--      records how many. That sentence is false today.
--   2. Nothing anywhere records that the picker lets a Warlock take
--      NON-ELEMENTAL magic, which the class's own summary forbids outright
--      ("A warlock cannot learn spell magic of any other kind"). That is a real
--      defect and it was undocumented; it is now stated where the next reader
--      will find it.
--
-- The route that would actually fix it is per-Force classes, the way the
-- Fusionists are split - an IMPORT decision rather than a transcription, and
-- Nate's. Same conclusion CLASS-AUDIT S8 reached for the Goblin Cobbler.

-- ---- 1. the variant does not record which Force -------------------------
UPDATE imported_classes
   SET markdown = replace(markdown,
       'Choose ONE or TWO Elemental Forces at creation (Air, Earth, Fire or Water) - the variant records which, and the choice is permanent.',
       'Choose ONE or TWO Elemental Forces at creation (Air, Earth, Fire or Water) - the variant records HOW MANY, not which, and the choice is permanent. There is no field for the Force itself: the variants are one-force and two-forces, so a Fire Warlock and an Air Warlock are the same class and variant here, and the element lives on the player''s own record. RETRO-AUDIT R3, 2026-09-04.')
 WHERE class_id = 'warlock'
   AND instr(markdown, 'the variant records which') > 0;

-- ---- 2. the picker permits magic the book forbids ------------------------
-- Appended to the extraction note that already explains the element problem, so
-- the two halves sit together. The existing sentence is preserved verbatim and
-- the new one follows it.
UPDATE imported_classes
   SET markdown = replace(markdown,
       'narrows it correctly - that is the intended workflow and it is stated' || char(10) || '    here rather than left to be discovered.',
       'narrows it correctly - that is the intended workflow and it is stated' || char(10) || '    here rather than left to be discovered.' || char(10) ||
       '  - WHAT THE PICKER DOES NOT STOP, recorded by RETRO-AUDIT R3 (2026-09-04):' || char(10) ||
       '    the summary says "A warlock cannot learn spell magic of any other kind",' || char(10) ||
       '    and nothing enforces it. spell_levels_allowed [1] gates by LEVEL only, so' || char(10) ||
       '    a first-level Warlock is offered all 50 level-1 spells in the catalog,' || char(10) ||
       '    including wizard magic the class may never learn. magic.spells_from could' || char(10) ||
       '    narrow that to the 37 level-1 ELEMENTAL spells, but not to the 9 a Fire' || char(10) ||
       '    Warlock should see, because no field records which Force was chosen. The' || char(10) ||
       '    route that works is per-Force classes, the way the Elemental Fusionists' || char(10) ||
       '    are split into two - an import decision, not a transcription.')
 WHERE class_id = 'warlock'
   AND instr(markdown, 'WHAT THE PICKER DOES NOT STOP') = 0
   AND instr(markdown, 'here rather than left to be discovered.') > 0;

-- ---- readbacks -----------------------------------------------------------
SELECT 'the false variant sentence is gone' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'warlock' AND instr(markdown, 'the variant records which') > 0;

SELECT 'the undocumented defect is now recorded' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'warlock' AND instr(markdown, 'WHAT THE PICKER DOES NOT STOP') > 0;

-- The accurate note about the element having no schema shape is UNTOUCHED.
-- This is the control: R3 as filed would have called it stale.
SELECT 'the true element-choice note survives' AS assertion,
       count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE class_id = 'warlock'
   AND instr(markdown, 'The ELEMENT choice itself is per-character and has no schema shape') > 0;

-- NO MECHANIC MOVED. The class still declares no spells_from KEY, deliberately.
--
-- Matched on the YAML key WITH ITS COLON, not on the bare word: the note this
-- script adds mentions `magic.spells_from` in prose, so a bare-word instr()
-- matches the assertion's own replacement text and can never pass. That is the
-- readback-quotes-its-own-phrase trap, and it fired here on the first run.
SELECT 'no spells_from key was added' AS assertion,
       count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id = 'warlock' AND instr(markdown, 'spells_from:') > 0;

-- Records this run. Both statements guard themselves, so this script is safe to
-- re-run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzz-retro-r3-warlock-notes.sql');
