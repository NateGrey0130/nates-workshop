-- Let the Cosmo-Knight say that it replaces the race.
--
-- BOOK-INGEST-AUDIT.md F11, taken in PR #NNN. The code half is
-- `supersedes_race` in js/parser.js; this sets it on the one class in the
-- catalog whose book says the character stops being what it was.
--
-- Phase World printed 100:
--
--   Attributes: Use these die rolls, or the attributes of the character's
--   original race, whichever are HIGHER.
--
-- and printed 102:
--
--   O.C.C. Skills: When the character is transformed, the skills of his past
--   life are lost and the character is reborn.
--
-- Both lines were read off their own pages in the OCR cache, in the block
-- belonging to this class.
--
-- Composed race-first, this class arrived wrong in almost every pairing.
-- Measured against all 57 published races: its `attribute_dice` survived 3
-- times, its `mdc_base` was discarded 36 times, its `ppe_base` 50 times, and 37
-- races carried between 1 and 17 named skills through a transformation that is
-- supposed to erase them. All four were right for exactly ONE race - and that
-- race states nothing in any of the four, so it composed correctly by having
-- nothing to compose. A kreeghor cosmo-knight came out with P.S. 3d6+10 where
-- the book prints 3d6+32, M.D.C. 2d6x10+20 against 4d6x10+60, and P.P.E. 3d6+6
-- against 1d6x100.
--
-- THE FALLEN COSMO-KNIGHT DOES NOT GET THIS FLAG, and that is deliberate rather
-- than an oversight. Its composition is broken identically - 3 of 57, 36 of 57,
-- 49 of 57, 1 of 57 - but its own entry on printed 103 states its attributes as
-- "use the cosmo-knight attributes, but reduce them as follows", which is a
-- DIFFERENT rule from "whichever are HIGHER". A fallen knight whose original
-- race had the higher P.S. should keep that race's number reduced by the
-- printed 22, and this flag would hand it the race's number untouched. Setting
-- it would trade one wrong answer for another. Recorded in the F11 outcome note
-- as needing a rule of its own.
--
-- Two extraction_notes bullets recorded the limit that has just been lifted.
-- They are rewritten to state what is true now rather than to quote what they
-- replace, so a search for the old wording finds nothing rather than finding
-- the correction.

UPDATE imported_classes
   SET markdown = replace(markdown, 'category: occ' || char(10) || 'occ_group: optional' || char(10) || 'source_book: Rifts Dimension Book 2: Phase World p.99-102',
       'category: occ' || char(10) || 'occ_group: optional' || char(10) || 'supersedes_race: true' || char(10) || 'source_book: Rifts Dimension Book 2: Phase World p.99-102'),
       updated_at = datetime('now')
 WHERE class_id = 'cosmo-knight'
   AND instr(markdown, 'category: occ' || char(10) || 'occ_group: optional' || char(10) || 'source_book: Rifts Dimension Book 2: Phase World p.99-102') > 0
   AND instr(markdown, 'category: occ' || char(10) || 'occ_group: optional' || char(10) || 'supersedes_race: true' || char(10) || 'source_book: Rifts Dimension Book 2: Phase World p.99-102') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THE ATTRIBUTE LINE IS A TAKE-THE-HIGHER RULE AND THE APP CANNOT HOLD IT.' || char(10) || '    The book says to use these die rolls OR the attributes of the character''s' || char(10) || '    original race, whichever are HIGHER. `attribute_dice` holds one expression' || char(10) || '    per attribute and `combineClasses` does not compare two of them: it gives' || char(10) || '    the RACE precedence outright wherever the race states any. Measured on all' || char(10) || '    57 published R.C.C.s - the cosmo-knight''s own dice survive on 3 of them,' || char(10) || '    and only because those three state no dice at all. A kreeghor cosmo-knight' || char(10) || '    rolls P.S. 3d6+10 where this class prints 3d6+32. The dice are stored' || char(10) || '    anyway, because a character with no race at all then gets the printed' || char(10) || '    figures and one omitting them would roll a flat 3d6 in every case. Filed as' || char(10) || '    BOOK-INGEST-AUDIT.md F11.',
       '  - THE ATTRIBUTE LINE IS A TAKE-THE-HIGHER RULE AND `supersedes_race` HOLDS' || char(10) || '    IT. The book says to use these die rolls OR the attributes of the' || char(10) || '    character''s original race, whichever are HIGHER. Composition now compares' || char(10) || '    the two per attribute and keeps the higher, by ceiling rather than by' || char(10) || '    rolling, since it runs before a die is thrown. Before the flag the RACE won' || char(10) || '    outright wherever it stated any dice: this class''s own survived on 3 of 57' || char(10) || '    published R.C.C.s, and only because those three state no dice at all. A' || char(10) || '    kreeghor cosmo-knight rolled P.S. 3d6+10 where this class prints 3d6+32.' || char(10) || '    BOOK-INGEST-AUDIT.md F11.'),
       updated_at = datetime('now')
 WHERE class_id = 'cosmo-knight'
   AND instr(markdown, '  - THE ATTRIBUTE LINE IS A TAKE-THE-HIGHER RULE AND THE APP CANNOT HOLD IT.' || char(10) || '    The book says to use these die rolls OR the attributes of the character''s' || char(10) || '    original race, whichever are HIGHER. `attribute_dice` holds one expression' || char(10) || '    per attribute and `combineClasses` does not compare two of them: it gives' || char(10) || '    the RACE precedence outright wherever the race states any. Measured on all' || char(10) || '    57 published R.C.C.s - the cosmo-knight''s own dice survive on 3 of them,' || char(10) || '    and only because those three state no dice at all. A kreeghor cosmo-knight' || char(10) || '    rolls P.S. 3d6+10 where this class prints 3d6+32. The dice are stored' || char(10) || '    anyway, because a character with no race at all then gets the printed' || char(10) || '    figures and one omitting them would roll a flat 3d6 in every case. Filed as' || char(10) || '    BOOK-INGEST-AUDIT.md F11.') > 0
   AND instr(markdown, '  - THE ATTRIBUTE LINE IS A TAKE-THE-HIGHER RULE AND `supersedes_race` HOLDS' || char(10) || '    IT. The book says to use these die rolls OR the attributes of the' || char(10) || '    character''s original race, whichever are HIGHER. Composition now compares' || char(10) || '    the two per attribute and keeps the higher, by ceiling rather than by' || char(10) || '    rolling, since it runs before a die is thrown. Before the flag the RACE won' || char(10) || '    outright wherever it stated any dice: this class''s own survived on 3 of 57' || char(10) || '    published R.C.C.s, and only because those three state no dice at all. A' || char(10) || '    kreeghor cosmo-knight rolled P.S. 3d6+10 where this class prints 3d6+32.' || char(10) || '    BOOK-INGEST-AUDIT.md F11.') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - THE SAME FINDING TAKES THE M.D.C. AND THE P.P.E. `combineClasses` gives the' || char(10) || '    race precedence on `mdc_base` and `ppe_base` too, so the transformed body' || char(10) || '    this entry describes is discarded for a race that states its own: 36 of 57' || char(10) || '    races drop the 4D6x10+60 and 50 of 57 drop the 1D6x100. And O.C.C. SKILLS' || char(10) || '    SAYS THE PAST LIFE IS LOST AND THE CHARACTER IS REBORN, which' || char(10) || '    `combineClasses` cannot express either - it UNIONS the two skill lists, so' || char(10) || '    37 of 57 races carry between 1 and 19 named skills through a transformation' || char(10) || '    the book says erases them. Exactly ONE race of 57 composes this class' || char(10) || '    correctly in all four places, and only by stating nothing in any of them.' || char(10) || '    All three are one finding, F11.',
       '  - THE SAME FLAG TAKES THE M.D.C., THE P.P.E. AND THE SKILLS. A superseding' || char(10) || '    class keeps its own `mdc_base` and `ppe_base` rather than the race''s, and' || char(10) || '    its O.C.C. skills REPLACE the race''s rather than unioning with them -' || char(10) || '    "when the character is transformed, the skills of his past life are lost' || char(10) || '    and the character is reborn" (printed 102). Before the flag, 36 of 57 races' || char(10) || '    dropped the 4D6x10+60, 50 of 57 dropped the 1D6x100, and 37 of 57 carried' || char(10) || '    between 1 and 17 named skills through a transformation the book says erases' || char(10) || '    them. Exactly ONE race of 57 composed this class correctly in all four' || char(10) || '    places, and only by stating nothing in any of them. All four are one' || char(10) || '    finding, F11.'),
       updated_at = datetime('now')
 WHERE class_id = 'cosmo-knight'
   AND instr(markdown, '  - THE SAME FINDING TAKES THE M.D.C. AND THE P.P.E. `combineClasses` gives the' || char(10) || '    race precedence on `mdc_base` and `ppe_base` too, so the transformed body' || char(10) || '    this entry describes is discarded for a race that states its own: 36 of 57' || char(10) || '    races drop the 4D6x10+60 and 50 of 57 drop the 1D6x100. And O.C.C. SKILLS' || char(10) || '    SAYS THE PAST LIFE IS LOST AND THE CHARACTER IS REBORN, which' || char(10) || '    `combineClasses` cannot express either - it UNIONS the two skill lists, so' || char(10) || '    37 of 57 races carry between 1 and 19 named skills through a transformation' || char(10) || '    the book says erases them. Exactly ONE race of 57 composes this class' || char(10) || '    correctly in all four places, and only by stating nothing in any of them.' || char(10) || '    All three are one finding, F11.') > 0
   AND instr(markdown, '  - THE SAME FLAG TAKES THE M.D.C., THE P.P.E. AND THE SKILLS. A superseding' || char(10) || '    class keeps its own `mdc_base` and `ppe_base` rather than the race''s, and' || char(10) || '    its O.C.C. skills REPLACE the race''s rather than unioning with them -' || char(10) || '    "when the character is transformed, the skills of his past life are lost' || char(10) || '    and the character is reborn" (printed 102). Before the flag, 36 of 57 races' || char(10) || '    dropped the 4D6x10+60, 50 of 57 dropped the 1D6x100, and 37 of 57 carried' || char(10) || '    between 1 and 17 named skills through a transformation the book says erases' || char(10) || '    them. Exactly ONE race of 57 composed this class correctly in all four' || char(10) || '    places, and only by stating nothing in any of them. All four are one' || char(10) || '    finding, F11.') = 0;

-- Readback: the flag is set, it is set on exactly ONE class in the whole
-- catalog, and no bullet on it still says the rule cannot be held.
SELECT class_id,
       instr(markdown, 'supersedes_race: true') > 0 AS flagged,
       instr(markdown, 'THE APP CANNOT HOLD IT')
         + instr(markdown, 'cannot express either') AS stale_claims,
       (SELECT count(*) FROM imported_classes WHERE instr(markdown, 'supersedes_race') > 0)
         AS classes_flagged_in_catalog
  FROM imported_classes
 WHERE class_id IN ('cosmo-knight', 'fallen-cosmo-knight')
 ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-cosmo-knight-supersedes-race.sql');
