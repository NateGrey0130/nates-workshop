-- Every literacy pick is a written language now, the way every language pick
-- became a spoken one.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-literacy-picks.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-literacy-picks.sql
--
--   rogue-scholar    pick 3, +30%   (was a whole category)
--   diabolist        pick 2, +20%   (was a list of generic rows)
--   summoner         pick 2, +20%   (was a list of generic rows)
--   wizard           pick 2, +15%   (was a list of generic rows)
--   shifter          pick 1, +20%   (was a FIXED grant of the placeholder row, base 50 = 30 + 20)
--   warlock          pick 1, +10%   (was a FIXED grant of the placeholder row, base 40 = 30 + 10)
--   stone-master     cited "Literacy: Dragonese/Elf" - no such row, no redirect
--   stone-master     frozen at base 0, per_level 0
--
-- THE SAME CHECK, RUN ON LITERACY. Six classes and the answers differ:
--
--   * The ROGUE SCHOLAR is the language defect exactly: three literacy picks
--     offered as the whole Communications category, seventeen skills, of which
--     two are literacy rows and the rest are Radio: Basic and Cryptography.
--
--   * The DIABOLIST, SUMMONER and WIZARD offered a from-list of real Literacy
--     rows, which is better and still wrong: "literate in two languages of
--     choice" was two picks from four GENERIC rows - Literacy, Literacy: Native
--     Language, Literacy: Dragonese/Elven, Literacy: Other - so a Wizard who
--     spent both ended up literate in "Other" and nothing named.
--
--   * The SHIFTER and WARLOCK granted "Literacy: Other" as a FIXED skill, and
--     both of their own notes say "of choice" in so many words. A grant of a
--     placeholder is a pick that was never offered.
--
-- LITERACY: OTHER IS THE SECOND FAMILY, and until the app change alongside this
-- file it was the only one with no rule. "Language: Other" has been taken once
-- per language, stored under the language's own name, since it was written;
-- "Literacy: Other" is the same row for reading rather than speaking and was
-- treated as one ordinary skill. The rule is now stated per FAMILY, so both
-- behave the same everywhere - the wizard's two pickers, the sheet, the pick
-- validator and the level-up resolver.
--
-- NO NUMBER CHANGES IN THE SIX. Every group keeps its own choose and bonus, and
-- the two fixed grants become a pick at the bonus their base already encoded -
-- the Shifter's 50 is the catalog's 30 plus its printed 20, the Warlock's 40 is
-- 30 plus 10. The percentages a character ends up with are identical; only the
-- NAME changes, from "Literacy: Other" to the language they chose.
--
-- THE STONE MASTER'S TWO ROWS are a different defect found by the same sweep,
-- and they were granting nothing at all:
--
--   Literacy: Dragonese/Elf   no such catalog row and no redirect, so the skill
--                             resolved to nothing. The row is Dragonese/Elven.
--   Language: American        base 0, per_level 0 - on the sheet at 0%, frozen
--                             there for fifteen levels. It has no catalog row
--                             of its own, which is exactly what the Language
--                             family's Other row is for: 50% +5/lvl.
--
-- NOT FIXED HERE, and much larger: 63 fixed skills across 16 classes sit BELOW
-- their catalog base, because the printed O.C.C. BONUS was stored as the base.
-- The Cyber-Doc's Computer Operation is 5% where the catalog row is 40% and the
-- class note says "(+5%)"; the Stone Master's whole block is the same shape.
-- Some of the 63 are deliberate and say so in their own notes - the Noble's
-- Horsemanship, the Warrior Monk's Begging - so telling them apart needs the
-- books open, one class at a time. That is its own pass.
--
-- Guarded on the exact old line, so re-running is a no-op and a row somebody has
-- since edited is left alone.

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 3, categories: ["Communications"], bonus: 30, note: "Literacy: Other, three of choice (+30%)." }', '- { choose: 3, from: ["Literacy: Other"], bonus: 30, note: "Literacy: Other, three of choice (+30%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'rogue-scholar' AND instr(markdown, '- { choose: 3, categories: ["Communications"], bonus: 30, note: "Literacy: Other, three of choice (+30%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Other"], bonus: 20, note: "Literate in two further languages of choice (+20%)" }', '- { choose: 2, from: ["Literacy: Other"], bonus: 20, note: "Literate in two further languages of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'diabolist' AND instr(markdown, '- { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Other"], bonus: 20, note: "Literate in two further languages of choice (+20%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Dragonese/Elven", "Literacy: Other"], bonus: 20, note: "Literate in two languages of choice (+20%)" }', '- { choose: 2, from: ["Literacy: Other"], bonus: 20, note: "Literate in two languages of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'summoner' AND instr(markdown, '- { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Dragonese/Elven", "Literacy: Other"], bonus: 20, note: "Literate in two languages of choice (+20%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Dragonese/Elven", "Literacy: Other"], bonus: 15, note: "Literate in two languages of choice (+15%)" }', '- { choose: 2, from: ["Literacy: Other"], bonus: 15, note: "Literate in two languages of choice (+15%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'wizard' AND instr(markdown, '- { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Dragonese/Elven", "Literacy: Other"], bonus: 15, note: "Literate in two languages of choice (+15%)" }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Literacy: Other", base: 50, per_level: 5, note: "One of choice (+20%)." }', '- { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "One of choice (+20%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'shifter' AND instr(markdown, '- { name: "Literacy: Other", base: 50, per_level: 5, note: "One of choice (+20%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Literacy: Other", base: 40, per_level: 5, note: "Literate in a Language of choice (+10%)." }', '- { choose: 1, from: ["Literacy: Other"], bonus: 10, note: "Literate in a Language of choice (+10%). Taken once per language - the picker asks which." }')
 WHERE class_id = 'warlock' AND instr(markdown, '- { name: "Literacy: Other", base: 40, per_level: 5, note: "Literate in a Language of choice (+10%)." }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Literacy: Dragonese/Elf", base: 0, per_level: 0 }', '- { name: "Literacy: Dragonese/Elven", base: 30, per_level: 5, note: "The catalog spells it Dragonese/Elven; the class cited Dragonese/Elf, which is no row and no redirect." }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Literacy: Dragonese/Elf", base: 0, per_level: 0 }') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '- { name: "Language: American", base: 0, per_level: 0 }', '- { name: "Language: American", base: 50, per_level: 5, note: "No catalog row of its own; the Language family resolves to the Language: Other row, 50% +5/lvl." }')
 WHERE class_id = 'stone-master' AND instr(markdown, '- { name: "Language: American", base: 0, per_level: 0 }') > 0;


-- Read the result back rather than trusting the exit code. Scoped to the rows
-- this script touches.
SELECT count(*) AS literacy_picks_narrowed FROM imported_classes
 WHERE class_id IN ('rogue-scholar', 'diabolist', 'summoner', 'wizard', 'shifter', 'warlock')
   AND instr(markdown, 'from: [' || char(34) || 'Literacy: Other' || char(34) || ']') > 0;
SELECT count(*) AS placeholder_still_granted_as_a_skill FROM imported_classes
 WHERE instr(markdown, 'name: ' || char(34) || 'Literacy: Other' || char(34)) > 0;
SELECT count(*) AS stone_master_rows_repaired FROM imported_classes
 WHERE class_id = 'stone-master'
   AND instr(markdown, 'Literacy: Dragonese/Elven') > 0
   AND instr(markdown, char(34) || 'Literacy: Dragonese/Elf' || char(34)) = 0
   AND instr(markdown, 'Language: American' || char(34) || ', base: 50') > 0;
SELECT count(*) AS cr_in_a_touched_class FROM imported_classes
 WHERE class_id IN ('rogue-scholar', 'diabolist', 'summoner', 'wizard', 'shifter',
                    'warlock', 'stone-master')
   AND instr(markdown, char(13)) > 0;

-- Records this run. REQUIRED: the smoke test fails a data script that has no
-- footer, or whose footer names a different file.
INSERT INTO data_script_runs (filename) VALUES ('fix-literacy-picks.sql');
