-- Rifts World Book 29: Madhaven - its bestiary and its notable NPCs.
-- 0 creatures (migration 074) and 2 notable NPCs (migration 072),
-- with their attacks in stat_attacks (migration 073).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~106-madhaven-inline-npcs.sql
--
-- Written by scripts/bestiary-sql.mjs from 1 worker file(s). Every
-- creature row passes creatureFormulaGaps, every value is printable ASCII,
-- and an 8-word shingle check of the prose fields against the book's cached text finds no copied run.

INSERT INTO notable_npcs (slug, name, real_name, title, system, race, occ, level, alignment, age, height, weight, attributes, hp, sdc, mdc, ppe, isp, ar, horror_factor, combat, bonuses_note, skills, skills_note, natural_abilities, magic, psionics, super_powers, cybernetics, weapons_and_equipment, money, disposition, allies, enemies, description, source_book) VALUES
('sir-charles-krieger', 'Sir Charles Krieger', NULL, NULL, 'rifts', NULL, '12th level Mystic Knight', 12, 'Diabolic', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'A zealot blinded by ambition for the rank of High Priest. He would spend every follower he has, trusted henchmen included, and dupe other evil powers into serving his ends.', 'A band of 110 mercenaries and misanthropes (half of them only level 1-3 mercs and Vagabonds), an elite platoon of 20 Brodkil and Witchlings, and a special recovery team that includes a 6th level Earth and Air Warlock.', 'Sir Geoffrey Colt, whom he knows personally and hates; the Knights of the White Rose.', 'An evil Mystic Knight who, in 106 P.A., dreamed that Set offered him demigod power and first place among the god''s North American priests in return for an obelisk and a magic diamond guarded by the Knights of the White Rose in an East Coast forest. The vision was a fraud worked by Pharaoh Rama-Set of the Phoenix Empire, who wants Cleopatra''s Needle and the Eye of Osiris for himself. By 109 P.A. Krieger leads a warband through the eastern wilds, letting it live off banditry, and has not thought to search Madhaven. He keeps the other Mystic Knights out of it, hoping to take over their order and maybe the Federation of Magic. No attributes or pools are printed.', 'Rifts World Book 29: Madhaven p.49-50'),
('the-wind-and-the-fury', 'The Wind and the Fury', NULL, 'Self-styled Friend of Mutants and Protector of Madhaven', 'rifts', NULL, '7th level Mind Melter', 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 173, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'All Sensitive, Ectoplasm and Telekinetic powers; Bio-Manipulation; Empathic Transmission; Electrokinesis; Hydrokinesis; Mind Bolt; Super Telekinesis; Telekinetic Acceleration Attack; Telekinetic Force Field', NULL, NULL, NULL, NULL, 'Insane. She shadows newcomers for 24-48 hours, then judges them: 01-50% heroes, whom she sends against a real menace; 51-00% agents of darkness, whom she orders out of Madhaven once. Her first psionic attacks are meant to scare, but if attacked she fights to kill, and she remembers her verdict at any later meeting.', 'The Haven Mutants, who all know her; any within earshot of a fight (01-80%) come to pull her out.', NULL, 'A madwoman of the ruins known only by the name she gives herself, encounter 20-21% on the Madhaven encounter table. She stages her warnings floating in the air with rubble whirling about her. The mutants know she is mad but value her protection from monsters and outsiders, and some suspect she serves their Mighty Lady. No real name, race, alignment or attributes are printed.', 'Rifts World Book 29: Madhaven p.125');

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 2 notable NPCs are in' AS assertion, count(*) AS got, 2 AS want
  FROM notable_npcs WHERE slug IN ('sir-charles-krieger', 'the-wind-and-the-fury');
SELECT 'and the notables 0' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks WHERE owner_kind = 'notable_npc' AND owner_slug IN ('sir-charles-krieger', 'the-wind-and-the-fury');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~106-madhaven-inline-npcs.sql');
