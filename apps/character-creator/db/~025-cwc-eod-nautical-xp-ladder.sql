-- The experience ladder for the CS EOD Specialist and the CS Nautical
-- Specialist, which ~012-cwc-fq-xp-ladders.sql left out for a decision.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~025-cwc-eod-nautical-xp-ladder.sql
--
-- COALITION WAR CAMPAIGN printed 224 (pdf page 225, cache cwc p225,
-- page_offset 1) names both classes in TWO columns that disagree:
--   "CS EOD Specialist, CS Nautical Specialist": 0, 2,001, 4,001, 8,201,
--     16,401, 24,501, 34,601, 49,701, 69,801, 94,901, 129,001, 179,101,
--     229,201, 279,301, 329,401 - read off a 300 dpi render, and the PDF's
--     text layer agrees on all fifteen; each band's top plus one is the next
--     lower bound, so no bound needs adjusting.
--   "NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical
--     Specialist": 0, 2,051, 4,101, 8,401 ... 331,401 (ntset-psi-hound
--     stores it since ~012).
-- THE DECISION, Nate 2026-09-27: store the column that names ONLY these two,
-- and record the other column in each class's extraction_notes.
--
-- MECHANICS, as ~012: one xp_table line straight after the single
-- "category: occ" line, guarded on no xp_table line yet; the note prepended,
-- guarded on its own anchor, so a second run changes nothing. The ~ tier
-- sorts after every z- tier, so nothing rewrites these rows later.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id IN ('cs-eod-specialist', 'cs-nautical-specialist')
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'extraction_notes: "PAGE SPAN: the class heading is printed 73', 'extraction_notes: "XP: stored 2026-09-27 as xp_table, printed 224''s column headed CS EOD Specialist, CS Nautical Specialist (0, 2,001, 4,001 ... 329,401), read off a render. The same page also names this class in a second column, headed NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical Specialist (0, 2,051, 4,101 ... 331,401); Nate decided on 2026-09-27 that the column naming only the two specialists is the one stored. PAGE SPAN: the class heading is printed 73'), updated_at = datetime('now')
 WHERE class_id = 'cs-eod-specialist'
   AND instr(markdown, 'extraction_notes: "PAGE SPAN: the class heading is printed 73') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, 'extraction_notes: "Group from the book''s Military O.C.C.s section', 'extraction_notes: "XP: stored 2026-09-27 as xp_table, printed 224''s column headed CS EOD Specialist, CS Nautical Specialist (0, 2,001, 4,001 ... 329,401), read off a render. The same page also names this class in a second column, headed NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical Specialist (0, 2,051, 4,101 ... 331,401); Nate decided on 2026-09-27 that the column naming only the two specialists is the one stored. Group from the book''s Military O.C.C.s section'), updated_at = datetime('now')
 WHERE class_id = 'cs-nautical-specialist'
   AND instr(markdown, 'extraction_notes: "Group from the book''s Military O.C.C.s section') > 0;

-- Read the result back: the whole ladder, the note, one xp line each.
SELECT 'ladder' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('cs-eod-specialist', 'cs-nautical-specialist') AND instr(markdown, char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]' || char(10)) > 0;
SELECT 'note' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('cs-eod-specialist', 'cs-nautical-specialist') AND instr(markdown, 'extraction_notes: "XP: stored 2026-09-27 as xp_table') > 0;
SELECT 'one xp line' AS assertion, count(*) AS got, 0 AS want FROM imported_classes WHERE class_id IN ('cs-eod-specialist', 'cs-nautical-specialist') AND length(markdown) - length(replace(markdown, char(10) || 'xp_table:', '')) > 10;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~025-cwc-eod-nautical-xp-ladder.sql');
