-- Say "this creature has no such attribute", now that the app can hear it.
--
-- BOOK-INGEST-AUDIT.md F5, taken in PR #423. `attribute_dice` accepts the
-- literal "N/A", `rollAttribute` returns null for it, and the wizard neither
-- rolls it nor counts it as missing. The sheet already rendered a dash for a
-- null attribute and the server already treated a REQUIRED attribute that is
-- null as a violation; the only thing missing was a way to produce the null.
--
-- Two classes need it, and they are the two the finding names:
--
--   machine-people  printed 78 - "P.E. N/A". A living machine has no
--                   constitution to model.
--   pleasurer       printed 89 - "P.B. N/A". A shapeshifter wears whatever
--                   face its client wants, so beauty is not a number it has.
--
-- Both previously OMITTED the key, which was the honest choice of the two then
-- available and produced exactly the same character as writing a number:
-- app.js resolved a missing entry as `3d6`. So both sheets showed a score the
-- book denies. This is the change that stops that.
--
-- EXISTING CHARACTERS ARE NOT REWRITTEN. Attributes are rolled once and stored
-- on the character, so anyone already made keeps the number they were given;
-- this changes what NEW characters get. Nothing here touches a character row.
--
-- Each class's extraction_notes also asserted the limitation as current and
-- measured - true when written, false as of PR #423 - so both are corrected in
-- the same script. A note claiming a limit that no longer exists is the failure
-- this book has now hit three times.
--
-- Every statement is guarded on the text it replaces, so re-running is a no-op.

-- -- machine-people: the P.E. it does not have --
UPDATE imported_classes
SET markdown = replace(markdown,
  '  PS: "6d6"
  PP: "5d6"
  PB: "2d6+12"',
  '  PS: "6d6"
  PP: "5d6"
  PE: "N/A"
  PB: "2d6+12"')
WHERE class_id = 'machine-people'
  AND instr(markdown, 'PE: "N/A"') = 0;

UPDATE imported_classes
SET markdown = replace(markdown,
  'no way to say that: `attribute_dice` is a map of dice strings, and app.js
    falls back to `''3d6''` for any attribute a class does not list. So the
    character sheet will show a rolled P.E. the book says does not exist. Filed
    as BOOK-INGEST-AUDIT.md F5. Omitting the key is still the honest choice -
    writing a number would assert one.',
  'no way to say that when this class was imported: `attribute_dice` was a map
    of dice strings and app.js resolved any attribute a class did not list as
    `''3d6''`, so omitting the key and writing a number produced the same
    character and the sheet showed a rolled P.E. the book denies. FILED AS
    BOOK-INGEST-AUDIT.md F5 AND SINCE TAKEN: the key now reads "N/A", which
    `rollAttribute` answers with null rather than a roll. The sheet shows a dash,
    the wizard offers no control for it, and an occupation that requires a P.E.
    fails closed against this race - which is the right answer and the one
    nobody would get by hand.')
WHERE class_id = 'machine-people'
  AND instr(markdown, 'Omitting the key is still the honest choice') > 0;

-- -- pleasurer: the P.B. it does not have --
UPDATE imported_classes
SET markdown = replace(markdown,
  '  PP: "4d6"
  PE: "4d6"
  Spd: "4d6"',
  '  PP: "4d6"
  PE: "4d6"
  PB: "N/A"
  Spd: "4d6"')
WHERE class_id = 'pleasurer'
  AND instr(markdown, 'PB: "N/A"') = 0;

UPDATE imported_classes
SET markdown = replace(markdown,
  'attribute is simply absent from `attribute_dice`, the same treatment the
    Norse Giant already gets for a book that lists seven attributes. Writing a
    fixed value there would be worse than absent: `rollAttribute` in js/dice.js
    parses only NdM forms and falls back to 3d6 on anything else, rewriting the
    notation as it goes. See BOOK-INGEST-AUDIT.md F8.',
  'attribute was simply absent from `attribute_dice` at import, which read the
    same to the app as never having been mentioned - it resolved a missing entry
    as 3d6 and showed a beauty score to a creature whose whole trade is not
    having a fixed one. BOOK-INGEST-AUDIT.md F5 HAS SINCE BEEN TAKEN and the key
    now reads "N/A", which `rollAttribute` answers with null: the sheet shows a
    dash and the wizard offers no control for it. A FIXED NUMBER would still be
    the wrong answer here, and for a different reason than it once was - F8 made
    a bare integer storable, so writing one now would assert a beauty this
    creature does not have rather than being silently discarded.')
WHERE class_id = 'pleasurer'
  AND instr(markdown, 'the same treatment the
    Norse Giant already gets') > 0;

-- Readback: both keys present, both stale claims gone, and no other attribute
-- disturbed on either class.
SELECT class_id,
       instr(markdown, 'PE: "N/A"') > 0 AS has_pe_na,
       instr(markdown, 'PB: "N/A"') > 0 AS has_pb_na,
       instr(markdown, 'SINCE TAKEN') > 0 OR instr(markdown, 'SINCE BEEN TAKEN') > 0 AS note_corrected
FROM imported_classes
WHERE class_id IN ('machine-people', 'pleasurer')
ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-absent-attributes-na.sql');
