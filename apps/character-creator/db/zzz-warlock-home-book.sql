-- The warlock's source stamp names the wrong book: its page numbers were
-- always Conversion Book One's (class audit Blocked-item close-out,
-- 2026-08-26).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zzz-warlock-home-book.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zzz-warlock-home-book.sql
--
-- The stamp read "Rifts Book of Magic p.66-70" and the audit's Blocked note
-- took it on faith as the spell-list span. Both books are now on this
-- machine and cached, and neither claim survives contact:
--
--   * BOM printed 66-70 holds EARTH SPELL DESCRIPTIONS, levels 1-5 -
--     not the O.C.C. and not the warlock's spell lists.
--   * BOM's own O.C.C. index (printed 24) reads "Warlock O.C.C. (Rifts
--     Conversion Book One Revised, p. 66)", and Federation of Magic
--     (printed 7) defers the same way: "As for Warlocks, Elemental Magic
--     and Elementals, see Rifts Conversion Book (One)."
--   * CB1 Revised prints "The Warlock O.C.C." on folio 66 and everything
--     the Blocked note called unverifiable reads verbatim on printed
--     66-71 (cached as .cache/books/cb1, reader page = printed+1):
--     attribute requirements I.Q. 6/M.E. 10 and I.Q. 12/M.E. 14 (p.66-67,
--     restated p.70), P.P.E. 2D4x10+20 and +40 "in addition to the P.E.
--     attribute number" +2D6/level (p.68), the bonus line "+2 to save vs
--     Horror Factor (+6 against Elemental beings), +1 to save vs magic,
--     and +1 to save vs possession. +1 to spell strength at levels 3, 6,
--     10 and 14" (p.68), the full O.C.C. skill list with every listed
--     bonus, the related-skill program (8 skills, two from Wilderness or
--     Domestic, +2 at level 3 and +1 at 6, 9 and 12) with every category
--     caveat, four secondary skills (p.70), and "2D6x1000 in credits and
--     3D4x1000 in Black Market items" (p.71).
--
-- So the class was evidently imported FROM Conversion Book One with the
-- page numbers stamped right and the book name wrong. The stamp moves to
-- the book the figures are printed in (extended to 71, where the money
-- lands), and the two notes that repeated the wrong title are rewritten in
-- the same pass per the claim-audit rule. The elemental spell DESCRIPTIONS
-- the class casts from remain the Book of Magic's contribution (printed 57
-- onward) - that stays recorded in the extraction notes.
--
-- Filename sort: zzz-warlock-home-book > zzz-resolve-choice-group-gear,
-- record-warlock-palladium-deltas and zz-pf-experience-tables - the later
-- writers of this class's markdown, including the exact body line the
-- third replace edits. A fix- name would sort before all three.
--
-- Safe to run twice: the second pass finds nothing to replace.

-- 1. The frontmatter stamp - the one line parseSourcePages and
--    class-check --field-sources read.
UPDATE imported_classes
SET markdown = replace(markdown,
      'source_book: Rifts Book of Magic p.66-70',
      'source_book: Rifts Conversion Book One p.66-71'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, 'source_book: Rifts Book of Magic p.66-70') > 0;

-- 2. The extraction note that repeated the wrong title, rewritten to record
--    the actual chain of custody.
UPDATE imported_classes
SET markdown = replace(markdown,
      '  - Rifts Book of Magic p.66-70, adapted from the Palladium Fantasy RPG.',
      '  - Rifts Conversion Book One (Revised) printed pp.66-71, adapted from'
        || char(10) || '    the Palladium Fantasy RPG. The stamp said Book of Magic with these'
        || char(10) || '    same page numbers for years, but BOM printed 66-70 holds Earth spell'
        || char(10) || '    descriptions (levels 1-5), not the O.C.C. - BOM''s own O.C.C. index'
        || char(10) || '    (printed 24) sends the Warlock to Conversion Book One Revised p.66,'
        || char(10) || '    and Federation of Magic (printed 7) says the same. The elemental'
        || char(10) || '    spell descriptions the class casts from are BOM''s (printed 57'
        || char(10) || '    onward).'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, '  - Rifts Book of Magic p.66-70, adapted from the Palladium Fantasy RPG.') > 0;

-- 3. The Palladium Fantasy section's opening sentence made the same claim.
UPDATE imported_classes
SET markdown = replace(markdown,
      'the numbers above are the later Rifts Book of Magic printing. They agree on',
      'the numbers above are the later Rifts printing (Conversion Book One). They agree on'),
    updated_at = datetime('now')
WHERE class_id = 'warlock'
  AND instr(markdown, 'the numbers above are the later Rifts Book of Magic printing. They agree on') > 0;

-- Reads the result back, so it is read rather than assumed.
--   stamped      1 = the frontmatter cites Conversion Book One p.66-71
--   old_left     0 = neither wrong-title site remains (there were two)
--   note_fixed   1 = the extraction note records the chain of custody
--   body_fixed   1 = the Palladium Fantasy sentence no longer says BOM
--   cr_free      1 = still no CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'warlock'
          AND instr(markdown, 'source_book: Rifts Conversion Book One p.66-71') > 0) AS stamped,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'warlock'
          AND instr(markdown, 'Book of Magic p.66-70') > 0) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'warlock'
          AND instr(markdown, 'BOM printed 66-70 holds Earth spell') > 0) AS note_fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'warlock'
          AND instr(markdown, 'later Rifts printing (Conversion Book One). They agree on') > 0) AS body_fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'warlock'
          AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzz-warlock-home-book.sql');
