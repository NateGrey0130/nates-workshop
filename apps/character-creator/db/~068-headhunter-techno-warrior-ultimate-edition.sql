-- The Headhunter Techno-Warrior goes back to its Rifts Ultimate Edition
-- printing (p.74-77). Ultimate Edition wins.
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~068-headhunter-techno-warrior-ultimate-edition.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~068-headhunter-techno-warrior-ultimate-edition.sql
--
-- WHY. ~067-canada-headhunter-techno-warrior.sql moved this class to the
-- World Book 20: Canada printing (printed 110-112), reading Nate's rule "the
-- printing with the highest World Book number wins" as Canada over a core
-- book that carries no number. Nate's decision of 2026-10-02, after seeing
-- the result: Ultimate Edition wins. It is the later printing and the
-- current core book.
--
-- WHAT IT DOES. It reverses every one of ~067's eleven replacements, each
-- guarded on the text ~067 wrote, so the row reads exactly as it did before
-- ~067: +1D4 P.S. and P.E., +3 pull punch and roll, +2 Perception, Language:
-- Native at 98%, three languages at +20%, Electronic Countermeasures,
-- Commando for two picks, one related skill at level 3, 1D4+1 implants, and
-- source_book Rifts Ultimate Edition p.74-77. A re-run is a no-op.
--
-- ~067 is left in place, never edited: it was applied once. On a clean
-- rebuild it runs and this runs after it, because ~068 sorts after ~067.
-- The Canada printing's differences are recorded in ~067's header and in
-- apps/character-creator/docs/surveys/canada.md, and are not stored.

UPDATE imported_classes SET markdown = replace(markdown, 'source_book: Rifts World Book 20: Canada p.110-112', 'source_book: Rifts Ultimate Edition p.74-77')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.110-112') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  attributes: { PS: "1d4" }', '  attributes: { PS: "1d4", PE: "1d4" }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '  attributes: { PS: "1d4" }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  combat: { initiative: 1, pull_punch: 3 }', '  combat: { initiative: 1, pull_punch: 3, roll: 3, perception: 2 }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '  combat: { initiative: 1, pull_punch: 3 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '{ name: "Language: Native Tongue", base: 80, per_level: 1, note: "80% +1% per level of experience." }', '{ name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 94%." }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '{ name: "Language: Native Tongue", base: 80, per_level: 1, note: "80% +1% per level of experience." }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'bonus: 10, note: "Language: three others of choice, or one other language and two additional Lore skills (+10%).', 'bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%).')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'bonus: 10, note: "Language: three others of choice, or one other language and two additional Lore skills (+10%).') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '{ name: "Radio: Scramblers", base: 45, per_level: 5, note: "Radio: Scrambler (+10%)." }', '{ name: "Electronic Countermeasures", base: 40, per_level: 5, note: "+10%" }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '{ name: "Radio: Scramblers", base: 45, per_level: 5, note: "Radio: Scrambler (+10%)." }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'costs: { martial_arts: 1, assassin: 1, jujitsu: 2 }', 'costs: { martial_arts: 1, assassin: 1, commando: 2 }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'costs: { martial_arts: 1, assassin: 1, jujitsu: 2 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'for the cost of one O.C.C. Related Skill, or Jujitsu for the cost of two.', 'for the cost of one O.C.C. Related Skill, or Commando for the cost of two.')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'for the cost of one O.C.C. Related Skill, or Jujitsu for the cost of two.') > 0;

-- The secondary skills print the same '{ level: 3, count: 2 }' line and keep
-- it. The related schedule is the one followed by '{ level: 6, count: 1 }',
-- so the pair of lines is what is matched.
UPDATE imported_classes SET markdown = replace(markdown, '      - { level: 3, count: 2 }' || char(10) || '      - { level: 6, count: 1 }', '      - { level: 3, count: 1 }' || char(10) || '      - { level: 6, count: 1 }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '      - { level: 3, count: 2 }' || char(10) || '      - { level: 6, count: 1 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Cybernetics: 1D4 cybernetic implants of choice', 'Cybernetics: 1D4+1 cybernetic implants of choice')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'Cybernetics: 1D4 cybernetic implants of choice') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - THIS ROW IS THE WORLD BOOK 20: CANADA PRINTING (printed 110-112) since ~067-canada-headhunter-techno-warrior.sql, on the decision recorded in docs/surveys/canada.md that the printing with the highest World Book number wins. It was first published from Rifts Ultimate Edition p.74-77, and that script lists every figure that changed. The notes below were written for the Ultimate Edition printing: its +1D4 P.E., its +3 to roll and its +2 Perception are not in this printing and are no longer stored. The Lore and GM Notes body is still the wording written from Ultimate Edition. Alignment any', '  - RUE p.74-77. Alignment any')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '  - THIS ROW IS THE WORLD BOOK 20: CANADA PRINTING (printed 110-112) since ~067-canada-headhunter-techno-warrior.sql, on the decision recorded in docs/surveys/canada.md that the printing with the highest World Book number wins. It was first published from Rifts Ultimate Edition p.74-77, and that script lists every figure that changed. The notes below were written for the Ultimate Edition printing: its +1D4 P.E., its +3 to roll and its +2 Perception are not in this printing and are no longer stored. The Lore and GM Notes body is still the wording written from Ultimate Edition. Alignment any') > 0;

-- Readbacks: each must return got = want. This script asserts its OWN row.
SELECT 'the Techno-Warrior cites Ultimate Edition again' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, 'source_book: Rifts Ultimate Edition p.74-77') > 0
   AND instr(markdown, 'World Book 20') = 0;

SELECT 'its bonuses are the Ultimate Edition printing''s' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, '  attributes: { PS: "1d4", PE: "1d4" }') > 0
   AND instr(markdown, '  combat: { initiative: 1, pull_punch: 3, roll: 3, perception: 2 }') > 0;

SELECT 'its skills are the Ultimate Edition printing''s' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, '{ name: "Language: Native Tongue", base: 98, per_level: 0') > 0
   AND instr(markdown, '{ name: "Electronic Countermeasures", base: 40, per_level: 5') > 0
   AND instr(markdown, '"Radio: Scramblers"') = 0
   AND instr(markdown, 'commando: 2') > 0 AND instr(markdown, 'jujitsu: 2') = 0
   AND instr(markdown, '      - { level: 3, count: 1 }' || char(10) || '      - { level: 6, count: 1 }') > 0
   AND instr(markdown, '      - { level: 3, count: 2 }' || char(10) || '      - { level: 6, count: 2 }') > 0
   AND instr(markdown, 'Cybernetics: 1D4+1 cybernetic implants of choice') > 0
   AND instr(markdown, '  - RUE p.74-77. Alignment any') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~068-headhunter-techno-warrior-ultimate-edition.sql');
