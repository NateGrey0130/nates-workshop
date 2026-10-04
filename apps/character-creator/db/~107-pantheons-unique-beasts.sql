-- Rifts Conversion Book Two: Pantheons of the Megaverse - its bestiary and its notable NPCs.
-- 0 creatures (migration 074) and 5 notable NPCs (migration 072),
-- with their attacks in stat_attacks (migration 073).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~107-pantheons-unique-beasts.sql
--
-- Written by scripts/bestiary-sql.mjs from 1 worker file(s). Every
-- creature row passes creatureFormulaGaps, every value is printable ASCII,
-- and an 8-word shingle check of the prose fields against the book's cached text finds no copied run.

INSERT INTO notable_npcs (slug, name, real_name, title, system, race, occ, level, alignment, age, height, weight, attributes, hp, sdc, mdc, ppe, isp, ar, horror_factor, combat, bonuses_note, skills, skills_note, natural_abilities, magic, psionics, super_powers, cybernetics, weapons_and_equipment, money, disposition, allies, enemies, description, source_book) VALUES
('odins-ravens', 'Odin''s Ravens', NULL, 'Two ravens that serve Odin', 'rifts', 'Supernatural raven (mystic familiar)', NULL, NULL, 'Aberrant', NULL, NULL, NULL, '{"IQ":15,"ME":18,"MA":18,"PS":10,"PP":20,"PE":20,"PB":12,"Spd":88}', 20, 80, 75, NULL, NULL, NULL, NULL, '{"attacks":4,"initiative":2,"strike":3,"parry":3,"dodge":5}', '+6 to save vs horror factor, +6 to save vs magic, +8 to save vs psionics. Spd 88 is flying (60 mph/96 km). 80 S.D.C. and 20 hit points apply on non-M.D.C. worlds.', NULL, NULL, 'Nightvision 90 ft (27.4 m), working in total darkness; hawk-like sight out to two miles (3.2 km); half damage from fire; bio-regenerates 1D4x10 M.D.C. per hour. Odin remakes a destroyed raven, but the replacement has none of its predecessor''s memories.', NULL, NULL, NULL, NULL, NULL, NULL, 'Seldom speaks to strangers though able to. Steers travelers away from danger and shows omens of Odin''s will; those who have angered Odin may be led into ruin instead.', 'Odin', NULL, 'The pair of intelligent ravens that sit on Odin''s shoulders in Asgard and range across the Megaverse as his spies and scouts, covering what his throne cannot show him. One row for the pair: the book heads them only as Odin''s Ravens, names neither, and says the stats of both are identical, so every figure here is for each raven.', 'Rifts Conversion Book Two: Pantheons of the Megaverse p.148'),
('yamas-bull', 'Yama''s Bull', NULL, 'Yama''s mount', 'rifts', 'Demonic beast', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 600, NULL, NULL, NULL, NULL, '{"attacks":3,"strike":3,"parry":3,"dodge":3}', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Yama', NULL, 'The huge black bull-like demon beast that Yama, King of the Dead, rides. Statted in one line among his equipment; nothing else is printed for it.', 'Rifts Conversion Book Two: Pantheons of the Megaverse p.136'),
('ganesas-riding-rat', 'The Riding Rat', NULL, 'Ganesa''s mount', 'rifts', 'Magical giant rat', NULL, NULL, NULL, NULL, NULL, NULL, '{"Spd":88}', NULL, NULL, 500, NULL, NULL, NULL, NULL, '{"strike":2,"dodge":3}', 'Spd 88 is running (60 mph/96 kph).', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Ganesa', NULL, 'An elephant-sized magical rat that the elephant-headed god Ganesa rides for the joke of it. Statted as four bullet lines among his equipment; no attacks per melee is printed.', 'Rifts Conversion Book Two: Pantheons of the Megaverse p.130'),
('sarasvatis-peacock', 'Sarasvati''s Peacock', NULL, 'Sarasvati''s mount', 'rifts', 'Magical peacock', NULL, NULL, NULL, NULL, NULL, NULL, '{"Spd":147}', NULL, NULL, 300, NULL, NULL, NULL, NULL, NULL, 'No attacks, but three actions per melee round. Spd 147 is running (100 mph/160 km).', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'Sarasvati', NULL, 'The magical peacock the water goddess Sarasvati rides. Its figures sit in a parenthesis in her description line; it has no attack of its own.', 'Rifts Conversion Book Two: Pantheons of the Megaverse p.121'),
('sivas-cobras', 'Siva''s Cobras', NULL, 'Three magical snakes worn by Siva', 'rifts', 'Magical cobra', NULL, NULL, NULL, NULL, '30 feet long (9 m)', NULL, '{"Spd":88}', NULL, NULL, 300, NULL, NULL, NULL, NULL, '{"strike":3,"parry":4,"dodge":4}', '+8 to save vs magic, psionics and horror factor. Spd 88 is crawling (60 mph/96 kph). Every figure is per cobra; there are three.', NULL, NULL, 'Immune to mind control and possession. Can entangle and hold a victim for Siva; breaking loose takes a combined strength of 30 or more. Normally stay within 50 feet (15.2 m) of Siva. A cobra brought to zero M.D.C. vanishes and is gone for 1D6 days.', NULL, NULL, NULL, NULL, NULL, NULL, 'Clever; the three fight as a team with one another and with Siva, tripping or flanking whoever he is fighting.', 'Siva', NULL, 'Three magical snakes coiled about Siva''s body that uncoil to strike at his enemies. One row for the trio, since the book names none of them and gives one set of figures for each.', 'Rifts Conversion Book Two: Pantheons of the Megaverse p.127');

INSERT INTO stat_attacks (owner_kind, owner_slug, name, damage, is_mega_damage, range, note, sort) VALUES
('notable_npc', 'odins-ravens', 'Claws and beak/bite/peck', '1D4 M.D.', 1, NULL, NULL, 0),
('notable_npc', 'odins-ravens', 'Flying body slam', '2D6 S.D.C.', 0, NULL, 'not mega-damage; counts as two melee attacks', 1),
('notable_npc', 'yamas-bull', 'Kick', '4D6 M.D.', 1, NULL, NULL, 0),
('notable_npc', 'yamas-bull', 'Gore', '1D4x10 M.D.', 1, NULL, NULL, 1),
('notable_npc', 'ganesas-riding-rat', 'Bite', '4D6 M.D.', 1, NULL, NULL, 0),
('notable_npc', 'sivas-cobras', 'Bite', '3D6 M.D.', 1, NULL, 'plus weakening poison unless a save vs non-lethal poison (16 or higher): speed -25%, skills -10%, combat bonuses -1; further bites add damage only, the penalties do not stack', 0);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 5 notable NPCs are in' AS assertion, count(*) AS got, 5 AS want
  FROM notable_npcs WHERE slug IN ('odins-ravens', 'yamas-bull', 'ganesas-riding-rat', 'sarasvatis-peacock', 'sivas-cobras');
SELECT 'and the notables 6' AS assertion, count(*) AS got, 6 AS want
  FROM stat_attacks WHERE owner_kind = 'notable_npc' AND owner_slug IN ('odins-ravens', 'yamas-bull', 'ganesas-riding-rat', 'sarasvatis-peacock', 'sivas-cobras');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~107-pantheons-unique-beasts.sql');
