-- The Wilderness Scout's bonus block, wrong four ways against RUE printed
-- p.99 (class audit F3, 2026-08-25).
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/fix-wilderness-scout-bonuses.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/fix-wilderness-scout-bonuses.sql
--
-- The book (printed 99, "4. O.C.C. Bonuses"): "+3D6+10 to physical S.D.C.,
-- +1D4 to P.S. and P.E. attributes, +1 on initiative, +3 on Perception Rolls,
-- +2 to roll with impact, +2 to save vs poison and disease, +10% to save vs
-- Coma & Death, and +1 to save vs Horror Factor at levels 2, 4, 6, 9, 12
-- and 15."
--
-- Production, against that line:
--
--   sdc: "3d6+10"        `sdc` is not a recognised bonus group - the parser
--                        warns and IGNORES it, so the S.D.C. never reaches a
--                        sheet. It belongs in pools: { sdc: ... }.
--   toxins_poisons: 10   the book says 2; the 10 belongs to coma/death,
--                        which is separately correct.
--   (no disease)         the book's +2 covers poison AND disease, and
--                        disease is a modeled save key (derive.js, sheet.js).
--   (no perception)      the +3 to Perception Rolls was dropped entirely.
--   horror_factor: 1     flat, where the book prints an at-level schedule
--                        starting at 2 - so a first-level scout got a bonus
--                        the book does not give until level 2, and a
--                        fifteenth-level scout had +1 where the book gives +6.
--
-- The attributes line (+1D4 P.S. and P.E.) and initiative/roll are correct
-- and stay. The at_level shape is the headhunter's.
--
-- Filename sort: fix-wilderness-scout-bonuses < fix-wilderness-scout-
-- page-break, so on a clean rebuild this runs FIRST - safe, because the
-- page-break fix touches equipment and money, never the bonuses block, and
-- the guard below matches the text add-wilderness-scout-class.sql creates.
--
-- Safe to run twice: the second pass finds nothing to replace.

UPDATE imported_classes
SET markdown = replace(markdown,
      '  sdc: "3d6+10"' || char(10)
        || '  combat: { initiative: 1, roll: 2 }' || char(10)
        || '  saves: { toxins_poisons: 10, coma_death_pct: 10, horror_factor: 1 }',
      '  pools: { sdc: "3d6+10" }' || char(10)
        || '  combat: { initiative: 1, roll: 2, perception: 3 }' || char(10)
        || '  saves: { toxins_poisons: 2, disease: 2, coma_death_pct: 10 }' || char(10)
        || '  at_level:' || char(10)
        || '    - { level: 2, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 4, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 6, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 9, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 12, saves: { horror_factor: 1 } }' || char(10)
        || '    - { level: 15, saves: { horror_factor: 1 } }'),
    updated_at = datetime('now')
WHERE class_id = 'wilderness-scout'
  AND instr(markdown, '  saves: { toxins_poisons: 10, coma_death_pct: 10, horror_factor: 1 }') > 0;

-- Reads the result back, so it is read rather than assumed. Over --remote a
-- --file run returns aggregate counts only; d1-apply.mjs replays these.
--   fixed        1 = the class carries the corrected block
--   old_left     0 = no trace of the ignored sdc: line or the wrong saves
--   cr_free      1 = the spliced newlines did not smuggle in a CR
SELECT (SELECT count(*) FROM imported_classes WHERE class_id = 'wilderness-scout' AND instr(markdown, '  pools: { sdc: "3d6+10" }') > 0 AND instr(markdown, 'perception: 3') > 0 AND instr(markdown, '  saves: { toxins_poisons: 2, disease: 2, coma_death_pct: 10 }') > 0 AND instr(markdown, '    - { level: 15, saves: { horror_factor: 1 } }') > 0) AS fixed,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'wilderness-scout' AND (instr(markdown, char(10) || '  sdc: "3d6+10"') > 0 OR instr(markdown, 'toxins_poisons: 10') > 0 OR instr(markdown, 'horror_factor: 1 }' || char(10) || 'skills:') > 0)) AS old_left,
       (SELECT count(*) FROM imported_classes WHERE class_id = 'wilderness-scout' AND instr(markdown, char(13)) = 0) AS cr_free;

-- Records this run. One row per run rather than per file: every statement
-- above guards itself, so this script is safe to re-run and safe to run
-- early, and a run that correctly did nothing is still a run that happened.
-- See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('fix-wilderness-scout-bonuses.sql');
