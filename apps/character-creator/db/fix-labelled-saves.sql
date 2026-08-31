-- Store the saves the sixteen fixed fields do not name.
--
-- BOOK-INGEST-AUDIT.md F7, taken in PR #426. `bonuses.saves.other` is a list of
-- { label, bonus }, rendered on the sheet after the sixteen and rollable in
-- play mode, labelled in the book's own words.
--
-- Two classes gain a bonus they have been carrying in prose:
--
--   spacer        printed 38 - "+2 to any saves against explosive
--                 decompression or other space dangers". This class's ONLY
--                 mechanical grant, which is why it filed the finding. It had
--                 no `bonuses:` key at all, because there was nothing it could
--                 legally hold.
--   cosmo-knight  printed 102 - the +4 is printed for mega-damage poisons AND
--                 for bio-wizard microbes and parasites. The poison half was
--                 stored as `toxins_poisons`; the other half had no field.
--
-- WHY THE COSMO-KNIGHT'S `saves:` CHANGES SHAPE. It was an inline flow map, and
-- a nested list cannot hang off one - the frontmatter parser is line-based and
-- an inline `{...}` must close on its own line. The same two numbers are
-- restated as a block map with `other` beneath them. No value changes.
--
-- The Colonist's note is corrected too. It does not need the mechanism; it
-- cites the Spacer's decompression save as an example of one with NO FIELD AT
-- ALL, which stops being true here. That is F12's pattern, caught this time by
-- sweeping the citers before shipping rather than three PRs afterwards.
--
-- The Vacuum Wasp also cites F7 and is deliberately NOT touched: its case is
-- `dogfighting`, a COMBAT field, and F7's proposal covers `saves` only. Its
-- note stays true.
--
-- Guarded on the text it replaces, so re-running is a no-op.

-- - spacer: the class had no bonuses block at all -
UPDATE imported_classes
SET markdown = replace(markdown,
  'The any/only/none limits above still apply."
equipment_starting:',
  'The any/only/none limits above still apply."
bonuses:
  saves:
    other:
      - { label: "vs explosive decompression and other space dangers", bonus: 2, note: "Printed 38; the spacers'' experience of vacuum. This class''s only mechanical grant." }
equipment_starting:')
WHERE class_id = 'spacer'
  AND instr(markdown, 'bonuses:') = 0;

-- - cosmo-knight: inline flow map to block, so `other` can hang off it -
UPDATE imported_classes
SET markdown = replace(markdown,
  '  saves: { toxins_poisons: 4, horror_factor: 6 }',
  '  saves:
    toxins_poisons: 4
    horror_factor: 6
    other:
      - { label: "vs bio-wizard microbes and parasites", bonus: 4, note: "Printed 102 in the same breath as the mega-damage poison save, which is stored as toxins_poisons." }')
WHERE class_id = 'cosmo-knight'
  AND instr(markdown, 'saves: { toxins_poisons: 4, horror_factor: 6 }') > 0;

-- - colonist: its note cites the Spacer's save as having no field -
UPDATE imported_classes
SET markdown = replace(markdown,
  -- The stored markdown really does hold a DOUBLED apostrophe here - `Spacer''''s`
  -- - from an escaping that was applied twice at import. Ten published classes
  -- carry one; filed as F13 and not fixed here. Matched as stored, and the
  -- replacement writes a single apostrophe, so this one is repaired in passing.
  'Both are real keys that `sheet.js` renders - unlike the Spacer''''s
    decompression save, which has no field at all. See BOOK-INGEST-AUDIT.md F7.',
  'Both are real keys that `sheet.js` renders directly. The Spacer''s
    decompression save had no field at all when this class was imported and now
    has one: BOOK-INGEST-AUDIT.md F7 has since been taken, and a save the
    sixteen fixed fields do not name goes in `bonuses.saves.other` with the
    book''s own wording as its label.')
WHERE class_id = 'colonist'
  AND instr(markdown, 'which has no field at all') > 0;

-- Readback: both bonuses present, the Cosmo-Knight's two numbers intact after
-- the reshape, and the Colonist's stale contrast gone.
SELECT class_id,
       instr(markdown, 'saves:') > 0 AS has_saves,
       instr(markdown, 'other:') > 0 AS has_other,
       instr(markdown, 'toxins_poisons: 4') > 0 AS ck_poison_intact,
       instr(markdown, 'horror_factor: 6') > 0 AS ck_horror_intact,
       instr(markdown, 'which has no field at all') AS stale_contrast_gone
FROM imported_classes
WHERE class_id IN ('spacer', 'cosmo-knight', 'colonist')
ORDER BY class_id;

INSERT INTO data_script_runs (filename) VALUES ('fix-labelled-saves.sql');
