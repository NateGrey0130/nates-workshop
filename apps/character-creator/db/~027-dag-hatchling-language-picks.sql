-- The Kukulcan, Lo-Dox and Night Stalker hatchlings' language and literacy
-- picks: from a flat base to a bonus over the Other rows.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~027-dag-hatchling-language-picks.sql
--
-- Dragons and Gods (#1460) stored each class's "literate in N other languages
-- ... plus speaks M additional" as choose-groups over Literacy: Other and
-- Language: Other with base: 96 (Kukulcan, Lo-Dox) or base: 98 (Night
-- Stalker). A language pick resolves off the Other row's own 50% +5%/level
-- (30% for literacy), and a base freezes it; regression's language-pick rule
-- ("none is frozen at a flat percentage") exists for exactly that shape, and
-- these three escaped it only because their notes say "additional ones"
-- rather than "languages". The fire-dragon, great-horned-dragon and ice-dragon
-- classes added beside this file, and the Serpent of the Wind, Thunder
-- Lizard and Ultucan (#1461), already state the bonus form.
--
-- The printed percentage becomes a bonus: Language: Other 50 +46 = 96 or
-- +48 = 98; Literacy: Other 30 +66 = 96 or +68 = 98. Checked --remote on
-- 2026-09-27: all three classes carry the flat base on both picks, and the
-- other three hatchlings of the book carry none.
--
-- MECHANICS. Each UPDATE replaces the one key on the one line, guarded on the
-- old text still being there, so a second run changes nothing. Keyed on
-- class_id. The ~ tier sorts after every add- script, so the add- files that
-- wrote the old text run first on a rebuild.

UPDATE imported_classes SET markdown = replace(markdown, 'from: ["Literacy: Other"], base: 96,', 'from: ["Literacy: Other"], bonus: 66,'), updated_at = datetime('now')
 WHERE class_id IN ('kukulcan-dragon', 'lo-dox-dragon') AND instr(markdown, 'from: ["Literacy: Other"], base: 96,') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'from: ["Language: Other"], base: 96,', 'from: ["Language: Other"], bonus: 46,'), updated_at = datetime('now')
 WHERE class_id IN ('kukulcan-dragon', 'lo-dox-dragon') AND instr(markdown, 'from: ["Language: Other"], base: 96,') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'from: ["Literacy: Other"], base: 98,', 'from: ["Literacy: Other"], bonus: 68,'), updated_at = datetime('now')
 WHERE class_id = 'night-stalker-dragon' AND instr(markdown, 'from: ["Literacy: Other"], base: 98,') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'from: ["Language: Other"], base: 98,', 'from: ["Language: Other"], bonus: 48,'), updated_at = datetime('now')
 WHERE class_id = 'night-stalker-dragon' AND instr(markdown, 'from: ["Language: Other"], base: 98,') > 0;

-- Read the result back: every pick moved, no flat base left.
SELECT 'bonus 96 picks' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('kukulcan-dragon', 'lo-dox-dragon') AND instr(markdown, 'Other"], bonus: 66,') > 0 AND instr(markdown, 'Other"], bonus: 46,') > 0;
SELECT 'bonus 98 picks' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id = 'night-stalker-dragon' AND instr(markdown, 'Other"], bonus: 68,') > 0 AND instr(markdown, 'Other"], bonus: 48,') > 0;
SELECT 'no flat base' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE class_id IN ('kukulcan-dragon', 'lo-dox-dragon', 'night-stalker-dragon') AND (instr(markdown, 'Other"], base: 96,') > 0 OR instr(markdown, 'Other"], base: 98,') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~027-dag-hatchling-language-picks.sql');
