-- Rifts World Book 33: Northern Gun One - its bestiary and its notable NPCs.
-- 0 creatures (migration 074) and 1 notable NPCs (migration 072),
-- with their attacks in stat_attacks (migration 073).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~293-northern-gun-1-npc-reeves.sql
--
-- Written by scripts/bestiary-sql.mjs from 1 worker file(s). Every
-- creature row passes creatureFormulaGaps, every value is printable ASCII,
-- and an 8-word shingle check of the prose fields against the book's cached text finds no copied run.

INSERT INTO notable_npcs (slug, name, real_name, title, system, race, occ, level, alignment, age, height, weight, attributes, hp, sdc, mdc, ppe, isp, ar, horror_factor, combat, bonuses_note, skills, skills_note, natural_abilities, magic, psionics, super_powers, cybernetics, weapons_and_equipment, money, disposition, allies, enemies, description, source_book) VALUES
('philip-reeves', 'Field Marshal Philip Reeves', 'Philip Reeves', 'Military Councilor of Northern Gun, Commander of the IMCN', 'rifts', 'Human', '9th level Special Forces (as printed)', 9, 'Unprincipled', '54', '6 feet (1.8 m)', '205 lbs (92 kg)', '{"IQ":19,"ME":14,"MA":21,"PS":15,"PP":12,"PE":13,"PB":12,"Spd":11}', 41, 22, NULL, 9, NULL, NULL, NULL, '{"attacks":6,"initiative":2,"strike":2,"parry":3,"dodge":3,"disarm":3,"pull":5,"roll":4}', 'Hand to hand: expert, six attacks per melee. +1 on Perception Rolls. Roll with impact or fall is +4. No damage bonus, saving throw bonuses or Horror Factor printed.', '[{"name":"Computer Operation","pct":85},{"name":"Intelligence","pct":79},{"name":"Literacy: American","pct":90},{"name":"Military: Tanks & APCs","pct":68},{"name":"Robots & Power Armor","pct":80},{"name":"Radio: Basic","pct":95},{"name":"Sensory Equipment","pct":80}]', 'Skills of note only; the block prints no full list. The two piloting skills carry their catalog names (printed as Pilot: Tanks & APCs and Pilot: Robots and Power Armor). Without percentages: Robot Combat Elite: NG Blocker, Running, W.P. Energy Pistol, W.P. Energy Rifle, W.P. Paired Weapons and Hand to Hand: Expert.', NULL, 'None.', 'None.', NULL, 'Clock calendar, gyro-compass, a bionic lung and 4 bionic ribs. A laser hit he lived through cost him his own lungs and ribs.', 'Never without the NG-56 Light Ion Pistol and the NG-LP25 Laser Pulse Submachine-Gun. Body armor: usually NG-A8 Scout Armor (printed name; no catalog row). Vehicles: his field headquarters is a Mobilon rolling field base; he is often carried by a Fantail helicopter or a Skybunker hover carrier (printed names; no catalog rows); and in battle he commands from a Blocker Combat Robot that carries a communications suite.', NULL, 'Unflappable and methodical, a strategist who plans before he moves. Where other Northern Gun executives panic at a raid or a disaster, Reeves tends to be on the scene already, sorting it out with mercenary troops and the Loss Prevention Office. Takes his post seriously, and enjoys the parades and inspections that came with Task Force X.', 'The Northern Gun Trade Council, the mercenary companies of the IMCN, Task Force X and the Loss Prevention Office, which he trains and equips (from the text; the block prints no allies line).', 'Bandits and thieves who prey on Northern Gun shipments, and any IMCN company that turns rogue (from the text; the block prints no enemies line).', 'A veteran mercenary who has fought across North America for decades, both beside and against the Coalition, before moving to corporate work. He ran security for Wilk''s Laser Technologies in South Dakota from 100 to 105 P.A., then took Northern Gun''s offer to head the Ishpeming Military Contract Network: guarding the country''s borders, ports and resources, and now also Task Force X. In 106 P.A. he crushed a rogue mercenary attempt to found a state in Wisconsin with a two-week campaign of maneuver and misdirection using two merc companies. Clean cut and rarely out of uniform; a desk job has added some weight, but he is otherwise very fit.', 'Rifts World Book 33: Northern Gun One p.65');

INSERT INTO stat_attacks (owner_kind, owner_slug, name, damage, is_mega_damage, range, note, sort) VALUES
('notable_npc', 'philip-reeves', 'NG-56 Light Ion Pistol', '2D6 M.D.', 1, '400 feet (122 m)', 'Weapon of note; damage and range from its catalog row (p.198-199), the block prints none.', 0),
('notable_npc', 'philip-reeves', 'NG-LP25 Laser Pulse Submachine-Gun', '2D6+1 M.D. single shot, or 5D6 M.D. triple pulse', 1, '1,000 feet (305 m)', 'Weapon of note; damage and range from its catalog row (p.192), the block prints none.', 1);

-- Read the result back. This script asserts its OWN rows and nothing else.
SELECT 'all 1 notable NPCs are in' AS assertion, count(*) AS got, 1 AS want
  FROM notable_npcs WHERE slug IN ('philip-reeves');
SELECT 'and the notables 2' AS assertion, count(*) AS got, 2 AS want
  FROM stat_attacks WHERE owner_kind = 'notable_npc' AND owner_slug IN ('philip-reeves');

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~293-northern-gun-1-npc-reeves.sql');
