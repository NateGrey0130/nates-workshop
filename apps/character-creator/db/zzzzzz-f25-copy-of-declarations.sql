-- BOOK-INGEST-AUDIT.md F25: declare the eleven copy pairs, so the invariant
-- added in test/regression.mjs has something to assert.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/zzzzzz-f25-copy-of-declarations.sql
--
-- Some books define a class AS another class and state nothing of their own.
-- Triax printed 175, of the Euro-Juicer: "The same creation considerations,
-- conditions, skills, bonuses and penalties as described in the Rifts RPG are
-- applicable... create the character as usual." RUE printed 118, of the Ley
-- Line Rifter: "Ley Line Rifter Stats. Same as the Ley Line Walker." Nothing
-- here composes one class from another, so both are stored as full copies -
-- and until now nothing recorded that the two must stay identical.
--
-- ELEVEN PAIRS, NOT ONE. F25 was written as though the Euro-Juicer were the
-- only such row; its premise audit found otherwise, and the outcome note
-- carries the correction. The ten elemental Warlocks come from ONE book entry -
-- Conversion Book One printed 66-71 - and were split into ten rows by
-- RETRO-AUDIT R3; nine of them are declared copies of warlock-air, which is
-- the arbitrary but stable choice of reference among ten siblings.
--
-- THE EXCEPT LISTS ARE DERIVED, NOT TYPED. They were computed from the live
-- rows by diffing every top-level key, so they cannot disagree with the data
-- on the day this lands - and the invariant refuses a STALE except, one naming
-- a key the two rows now agree on, because that is how a divergence gets
-- re-hidden after it is fixed.
--
-- WHAT EACH PAIR STILL ASSERTS, and it is not decorative:
--   * the nine Warlocks compare everything except magic (and, for the two-Force
--     six, attribute_requirements and ppe_base) - so a skill, bonus, equipment
--     or ability correction landing on one Warlock and not the other nine is
--     caught.
--   * euro-juicer compares its pools, bonuses, equipment, abilities and money
--     against the Juicer. It excepts skills, restrictions and race_restrictions,
--     all three of which differ deliberately and are documented in the row -
--     which does mean a skills-block divergence is NOT caught for that pair.
--   * ley-line-rifter compares its attributes, pools, money, equipment and
--     grouping against the Walker. It excepts the seven blocks RUE gives the
--     Rifter in its own right.
--
-- Guarded on instr(markdown, 'copy_of:') = 0 so re-running is a no-op, and
-- keyed on class_id. Sorts after every add-*-class.sql and after the two
-- Walker/Rifter corrections in the zzzzzz- tier that this depends on.

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts World Book 5: Triax and the NGR p.175', 'source_book: Rifts World Book 5: Triax and the NGR p.175' || char(10) || 'copy_of: { class: "juicer", except: ["race_restrictions", "restrictions", "skills"] }')
 WHERE class_id = 'euro-juicer' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.116-118', 'source_book: Rifts Ultimate Edition p.116-118' || char(10) || 'copy_of: { class: "ley-line-walker", except: ["bonuses", "magic", "natural_abilities", "restrictions", "side_effects", "skills", "special_abilities"] }')
 WHERE class_id = 'ley-line-rifter' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["magic"] }')
 WHERE class_id = 'warlock-earth' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["magic"] }')
 WHERE class_id = 'warlock-fire' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["magic"] }')
 WHERE class_id = 'warlock-water' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["attribute_requirements", "magic", "ppe_base"] }')
 WHERE class_id = 'warlock-air-earth' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["attribute_requirements", "magic", "ppe_base"] }')
 WHERE class_id = 'warlock-air-fire' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["attribute_requirements", "magic", "ppe_base"] }')
 WHERE class_id = 'warlock-air-water' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["attribute_requirements", "magic", "ppe_base"] }')
 WHERE class_id = 'warlock-earth-fire' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["attribute_requirements", "magic", "ppe_base"] }')
 WHERE class_id = 'warlock-earth-water' AND instr(markdown, 'copy_of:') = 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'source_book: Rifts Conversion Book One p.66-71', 'source_book: Rifts Conversion Book One p.66-71' || char(10) || 'copy_of: { class: "warlock-air", except: ["attribute_requirements", "magic", "ppe_base"] }')
 WHERE class_id = 'warlock-fire-water' AND instr(markdown, 'copy_of:') = 0;

-- Read the result back rather than trusting the exit code.
SELECT 'eleven classes declare a copy_of' AS assertion,
       count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'copy_of:') > 0;

SELECT class_id, substr(markdown, instr(markdown, 'copy_of:'), 64) AS declared
  FROM imported_classes
 WHERE deleted_at IS NULL AND instr(markdown, 'copy_of:') > 0
 ORDER BY class_id;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('zzzzzz-f25-copy-of-declarations.sql');
