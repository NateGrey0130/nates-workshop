-- Why eight classes speak at less than 98%, written down so nobody checks again.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/zz-note-native-tongue-figures.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/zz-note-native-tongue-figures.sql
--
--   body-fixer          96%   RUE p.87
--   crazy               95%   RUE p.56
--   cyber-doc           96%   RUE p.90
--   cyber-knight        96%   RUE p.66
--   glitter-boy         95%   RUE p.70
--   rogue-scientist     96%   RUE p.96
--   vagabond            88%   RUE p.97
--   wilderness-scout    94%   RUE p.99
--
-- THESE ARE NOT THE BONUS-AS-BASE BUG. That was 48 skills across six classes
-- where a printed O.C.C. BONUS had been stored as the skill's BASE, and it is
-- fixed. What is left below the catalog line is fifteen rows that really are
-- below it, because their books print them that way - and twelve of those are
-- a native tongue at 88-97%.
--
-- THE POINT OF THIS SCRIPT IS THE NOTE, NOT THE NUMBER. Every figure here is
-- already correct and not one of them changes. Four of the twelve carried a
-- note saying so; eight did not, and those eight had to be re-verified against
-- the scans one at a time during the bonus-as-base pass - which is exactly the
-- work a note exists to prevent. An unexplained number under the catalog line
-- reads as a defect, and the next audit will read it that way again.
--
-- THE PAGE NUMBERS ARE VERIFIED, not derived once and applied everywhere. Rifts
-- Ultimate Edition's OCR cache is indexed by PDF page and the printed folio runs
-- three behind, which was confirmed on six pages that print one (56, 66, 90, 96,
-- 97, 99). The two that do not - the Glitter Boy and the Body Fixer - were
-- bracketed by their neighbours instead: 69 and 71 put the Glitter Boy at 70,
-- 86 and 88 put the Body Fixer at 87. That care is the point rather than
-- pedantry: this book's companion has a DUPLICATED page, so an offset taken
-- once at one end is wrong at the other.
--
-- Two rows record a wording difference as well, because the next reader
-- grepping for "at 96%" will not find the Cyber-Knight's line and should know
-- why: it prints "Language: American and Dragonese/Elf at 96%", and the
-- Wilderness Scout's drops the "at" entirely.
--
-- Guarded on the exact old line, so re-running is a no-op and a row somebody
-- has since edited is left alone.

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }', '- { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%, the figure its own O.C.C. block prints (RUE p.87) rather than the catalog''s generic 98%." }')
 WHERE class_id = 'body-fixer' AND instr(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 95, per_level: 1 }', '- { name: "Language: Native Tongue", base: 95, per_level: 1, note: "At 95%, the figure its own O.C.C. block prints (RUE p.56) rather than the catalog''s generic 98%. The book writes it as "Native Language"." }')
 WHERE class_id = 'crazy' AND instr(markdown, '- { name: "Language: Native Tongue", base: 95, per_level: 1 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }', '- { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%, the figure its own O.C.C. block prints (RUE p.90) rather than the catalog''s generic 98%." }')
 WHERE class_id = 'cyber-doc' AND instr(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }', '- { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%, the figure its own O.C.C. block prints (RUE p.66) rather than the catalog''s generic 98%. The book prints "Language: American and Dragonese/Elf at 96%"." }')
 WHERE class_id = 'cyber-knight' AND instr(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 95, per_level: 0 }', '- { name: "Language: Native Tongue", base: 95, per_level: 0, note: "At 95%, the figure its own O.C.C. block prints (RUE p.70) rather than the catalog''s generic 98%." }')
 WHERE class_id = 'glitter-boy' AND instr(markdown, '- { name: "Language: Native Tongue", base: 95, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }', '- { name: "Language: Native Tongue", base: 96, per_level: 0, note: "At 96%, the figure its own O.C.C. block prints (RUE p.96) rather than the catalog''s generic 98%." }')
 WHERE class_id = 'rogue-scientist' AND instr(markdown, '- { name: "Language: Native Tongue", base: 96, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 88, per_level: 0 }', '- { name: "Language: Native Tongue", base: 88, per_level: 0, note: "At 88%, the figure its own O.C.C. block prints (RUE p.97) rather than the catalog''s generic 98%." }')
 WHERE class_id = 'vagabond' AND instr(markdown, '- { name: "Language: Native Tongue", base: 88, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: Native Tongue", base: 94, per_level: 1 }', '- { name: "Language: Native Tongue", base: 94, per_level: 1, note: "At 94%, the figure its own O.C.C. block prints (RUE p.99) rather than the catalog''s generic 98%. The book omits the "at", printing "Language: Native Tongue 94%"." }')
 WHERE class_id = 'wilderness-scout' AND instr(markdown, '- { name: "Language: Native Tongue", base: 94, per_level: 1 }') > 0;


-- Read the result back rather than trusting the exit code.
SELECT count(*) AS native_tongue_rows_with_a_note FROM imported_classes
 WHERE instr(markdown, 'name: ' || char(34) || 'Language: Native Tongue' || char(34)) > 0
   AND instr(markdown, 'the figure its own O.C.C. block prints') > 0;
SELECT count(*) AS classes_with_a_native_tongue_row FROM imported_classes
 WHERE status = 'published'
   AND instr(markdown, 'name: ' || char(34) || 'Language: Native Tongue' || char(34)) > 0;
SELECT count(*) AS any_percentage_changed FROM imported_classes
 WHERE class_id IN ('body-fixer', 'crazy', 'cyber-doc', 'cyber-knight', 'glitter-boy', 'rogue-scientist', 'vagabond', 'wilderness-scout')
   AND instr(markdown, 'Language: Native Tongue' || char(34) || ', base: 98') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE class_id IN ('body-fixer', 'crazy', 'cyber-doc', 'cyber-knight', 'glitter-boy', 'rogue-scientist', 'vagabond', 'wilderness-scout')
   AND instr(markdown, char(13)) > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('zz-note-native-tongue-figures.sql');
