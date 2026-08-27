-- The Demigod's Magic Powers ability carries no occ_options, on purpose.
--
-- The Godling's Magic Powers and the Demigod's are the same ability, printed
-- once and pointed at twice, and their descriptions in this catalog are word
-- for word identical. The Godling's carries
-- `occ_options: ["ley-line-walker", "shifter", "mystic", "warlock",
-- "necromancer"]`. The Demigod's carries nothing, and every sweep that
-- compares the two finds it - so the reason is written into the class rather
-- than left to be re-derived, and re-decided, by whoever notices next.
--
-- THE REASON. `occ_options` does not record which practitioner's abilities the
-- power confers. It turns the pick into the character's OCCUPATION: the class
-- step's picker becomes required and narrowed to those five ids, and the
-- choice lands in `occ_class_id`. That is affordable for the Godling, which
-- has R.C.C. skills of its own and no other use for the occupation slot. The
-- Demigod has no skills block at all - note 1 in this same list - and takes a
-- real O.C.C. that supplies every skill it will ever have, chosen from nearly
-- everything printed:
--
--   "O.C.C. & Skills: The Demigod can pick any O.C.C. that fits his human/D-bee
--    background and interests with the following exceptions: Rifts: Full
--    conversion cyborg, robot, juicer, or crazy."
--
-- Adding `occ_options` would spend that slot on the power and forbid every
-- build outside those five - the man-at-arms demigod the same entry grants,
-- among them. The book keeps the two questions separate in one line: "Magic: As
-- per O.C.C., unless Power #10 is chosen."
--
-- Pantheons of the Megaverse, printed page 17 (potm cache p018).
--
-- Note-only. No mechanical field changes, and the readback asserts the ability
-- is still there and still has no occ_options.
--
-- FILENAME. `zzz-` so a clean rebuild applies this after every other writer of
-- the Demigod's markdown - add-demigod-class.sql, fix-godling-demigod-
-- accuracy.sql and fix-source-book-pages.sql.

UPDATE imported_classes
SET markdown = replace(
      markdown,
      '     this one silently offers something different.' || char(10) || char(10) ||
      '  The extra power most demigods have is G.M.-assigned',
      '     this one silently offers something different.' || char(10) || char(10) ||
      '  8. NO occ_options on the Magic Powers ability, though the Godling''s copy' || char(10) ||
      '     of that same ability carries them. The asymmetry is deliberate.' || char(10) ||
      '     occ_options does not record which practitioner the power imitates; it' || char(10) ||
      '     turns the pick into the character''s OCCUPATION, narrowing the class' || char(10) ||
      '     step to those five ids. The Godling can spend its occupation slot that' || char(10) ||
      '     way because it has R.C.C. skills of its own and no other use for it.' || char(10) ||
      '     The Demigod cannot: it has no skills block at all (note 1), and its' || char(10) ||
      '     O.C.C. is where every skill comes from - "any O.C.C. that fits his' || char(10) ||
      '     human/D-bee background", four exclusions aside. Narrowing that slot' || char(10) ||
      '     would forbid the man-at-arms demigod the same entry grants. The book' || char(10) ||
      '     keeps the two questions apart in one line: "Magic: As per O.C.C.,' || char(10) ||
      '     unless Power #10 is chosen."' || char(10) || char(10) ||
      '  The extra power most demigods have is G.M.-assigned'),
    updated_at = datetime('now')
WHERE class_id = 'demigod'
  AND instr(markdown, '  8. NO occ_options on the Magic Powers ability') = 0;


SELECT class_id,
       instr(markdown, '  8. NO occ_options on the Magic Powers ability') > 0 AS note_written,
       instr(markdown, 'unless Power #10 is chosen.') > 0 AS book_line_quoted,
       -- The decision the note explains, asserted rather than described: the
       -- ability is still offered, and still carries no occ_options KEY. Note
       -- the trailing colon-and-bracket: the note itself says `occ_options`
       -- several times in order to explain its absence, so a bare instr on the
       -- word would read 0 whether this fired or not - a check that cannot pass.
       instr(markdown, 'name: "Magic Powers"') > 0 AS ability_present,
       instr(markdown, 'occ_options: [') = 0 AS still_no_occ_options_key,
       instr(markdown, 'The extra power most demigods have is G.M.-assigned') > 0 AS tail_intact
FROM imported_classes
WHERE class_id = 'demigod';

INSERT INTO data_script_runs (filename) VALUES ('zzz-demigod-occ-options-note.sql');
