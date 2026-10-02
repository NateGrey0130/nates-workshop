-- Rifts World Book 20: Canada, batch 6: the Headhunter Techno-Warrior takes
-- this book's printing (printed 110-112).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~067-canada-headhunter-techno-warrior.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~067-canada-headhunter-techno-warrior.sql
--
-- WHY. The class was published from Rifts Ultimate Edition p.74-77. This book
-- prints the same O.C.C. on 110-112, and the two printings differ. Nate's
-- decision of 2026-10-01 (apps/character-creator/docs/surveys/canada.md,
-- decision 2): the printing with the highest World Book number wins.
-- Ultimate Edition is not a World Book, so World Book 20 is the only numbered
-- printing, and its text wins wherever the two differ. It is a correction to
-- the existing row, class_id headhunter-techno-warrior, never a second row.
--
-- WHAT CHANGES, each read off cache p112-p113 (printed 111-112) on 2026-10-02:
--
--   field                         was (Ultimate Edition)     is (Canada)
--   attribute bonus               +1D4 P.S. and P.E.         +1D4 P.S.
--   pull punch / roll             +3 to both                 +3 pull punch
--   perception                    +2                         not printed
--   Language: Native              98%                        80% +1% per level
--   three other languages         +20%                       +10%
--   a +10% technical skill        Electronic Countermeasures Radio: Scrambler
--   Hand to Hand for two picks    Commando                   Jujitsu
--   O.C.C. Related at level 3     one                        two
--   cybernetic implants           1D4+1                      1D4
--   source_book                   Rifts Ultimate Edition     Rifts World Book 20:
--                                 p.74-77                    Canada p.110-112
--
-- WHAT DOES NOT: the ladder (printed 192 prints the same one), the +3D6
-- S.D.C., the initiative and Horror Factor levels, the +10% vs coma, the
-- attribute requirements, Find Contraband at 53% +3%, every other skill and
-- its bonus, the related categories, the secondary skills, the equipment and
-- the money. The Lore and GM Notes body is left as written; the notes line
-- this script adds says so.
--
-- Each statement is guarded on the text it replaces, so a re-run is a no-op,
-- and a row some other script has already moved is left alone and caught by
-- the readbacks. A `~` sorts after every file that shaped this class
-- (add-headhunter-techno-warrior-class.sql, fix-language-picks.sql,
-- fix-perception-bonuses.sql, zzzzzzzzzzzzzz-hand-to-hand-prices.sql,
-- ~008-rue-ju-xp-ladders.sql, ~048-class-tags-rifts-1.sql).

UPDATE imported_classes SET markdown = replace(markdown, 'source_book: Rifts Ultimate Edition p.74-77', 'source_book: Rifts World Book 20: Canada p.110-112')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'source_book: Rifts Ultimate Edition p.74-77') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  attributes: { PS: "1d4", PE: "1d4" }', '  attributes: { PS: "1d4" }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '  attributes: { PS: "1d4", PE: "1d4" }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  combat: { initiative: 1, pull_punch: 3, roll: 3, perception: 2 }', '  combat: { initiative: 1, pull_punch: 3 }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '  combat: { initiative: 1, pull_punch: 3, roll: 3, perception: 2 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '{ name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 94%." }', '{ name: "Language: Native Tongue", base: 80, per_level: 1, note: "80% +1% per level of experience." }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '{ name: "Language: Native Tongue", base: 98, per_level: 0, note: "At 94%." }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%).', 'bonus: 10, note: "Language: three others of choice, or one other language and two additional Lore skills (+10%).')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'bonus: 20, note: "Language: Other, three of choice (+20%) - or one other language and two Lore skills (+10%).') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '{ name: "Electronic Countermeasures", base: 40, per_level: 5, note: "+10%" }', '{ name: "Radio: Scramblers", base: 45, per_level: 5, note: "Radio: Scrambler (+10%)." }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '{ name: "Electronic Countermeasures", base: 40, per_level: 5, note: "+10%" }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'costs: { martial_arts: 1, assassin: 1, commando: 2 }', 'costs: { martial_arts: 1, assassin: 1, jujitsu: 2 }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'costs: { martial_arts: 1, assassin: 1, commando: 2 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'for the cost of one O.C.C. Related Skill, or Commando for the cost of two.', 'for the cost of one O.C.C. Related Skill, or Jujitsu for the cost of two.')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'for the cost of one O.C.C. Related Skill, or Commando for the cost of two.') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '      - { level: 3, count: 1 }', '      - { level: 3, count: 2 }')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '      - { level: 3, count: 1 }') > 0;

UPDATE imported_classes SET markdown = replace(markdown, 'Cybernetics: 1D4+1 cybernetic implants of choice', 'Cybernetics: 1D4 cybernetic implants of choice')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, 'Cybernetics: 1D4+1 cybernetic implants of choice') > 0;

UPDATE imported_classes SET markdown = replace(markdown, '  - RUE p.74-77. Alignment any', '  - THIS ROW IS THE WORLD BOOK 20: CANADA PRINTING (printed 110-112) since ~067-canada-headhunter-techno-warrior.sql, on the decision recorded in docs/surveys/canada.md that the printing with the highest World Book number wins. It was first published from Rifts Ultimate Edition p.74-77, and that script lists every figure that changed. The notes below were written for the Ultimate Edition printing: its +1D4 P.E., its +3 to roll and its +2 Perception are not in this printing and are no longer stored. The Lore and GM Notes body is still the wording written from Ultimate Edition. Alignment any')
 WHERE class_id = 'headhunter-techno-warrior' AND instr(markdown, '  - RUE p.74-77. Alignment any') > 0;

-- Readbacks: each must return got = want. This script asserts its OWN row.
SELECT 'the Techno-Warrior cites World Book 20' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, 'source_book: Rifts World Book 20: Canada p.110-112') > 0
   AND instr(markdown, 'Rifts Ultimate Edition p.74-77') > 0;

SELECT 'its bonuses are the Canada printing''s' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, '  attributes: { PS: "1d4" }') > 0
   AND instr(markdown, '  combat: { initiative: 1, pull_punch: 3 }') > 0
   AND instr(markdown, 'perception: 2') = 0;

SELECT 'its skills are the Canada printing''s' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, '{ name: "Language: Native Tongue", base: 80, per_level: 1') > 0
   AND instr(markdown, '{ name: "Radio: Scramblers", base: 45, per_level: 5') > 0
   AND instr(markdown, '"Electronic Countermeasures"') = 0
   AND instr(markdown, 'jujitsu: 2') > 0 AND instr(markdown, 'commando: 2') = 0
   AND instr(markdown, '      - { level: 3, count: 2 }') > 0 AND instr(markdown, '      - { level: 3, count: 1 }') = 0
   AND instr(markdown, 'Cybernetics: 1D4 cybernetic implants of choice') > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~067-canada-headhunter-techno-warrior.sql');
