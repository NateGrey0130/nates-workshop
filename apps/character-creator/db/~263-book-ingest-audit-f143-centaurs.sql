-- The centaurs creature row follows D-Bees of North America (BOOK-INGEST-AUDIT
-- F143, the Conversion Book One remainder, part 1 of 2).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~263-book-ingest-audit-f143-centaurs.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~263-book-ingest-audit-f143-centaurs.sql
--
-- The class centaur follows Rifts World Book 30: D-Bees of North America
-- (2007) printed 44-45, but its creatures row still cited Rifts Conversion
-- Book One (revised 2002) printed 136-138 and carried its figures. The row was
-- held with F142, which closed with the year rule's second clause: the newest
-- printing wins unless the newer book says it describes an earlier model.
-- D-Bees says no such thing of the Centaur, so by Nate's ruling of 2026-10-04
-- the newest printing that STATES a figure wins, and the row is UPDATED in
-- place and moves its source_book to the pages its class cites. Where D-Bees
-- is silent, Conversion Book One's figure stays: Horror Factor, P.P.E., Hit
-- Points, weight, magic, psionics and the Palladium Fantasy O.C.C. line. A
-- complete line D-Bees restates without an item drops that item. creatures
-- has no notes column, so each Conversion Book One figure that changed is kept
-- in description with its printed page.
--
-- Combat: D-Bees' Attacks per Melee line ("as per Hand to Hand Combat skill")
-- restates Conversion Book One's three attacks without them, as ~232 read the
-- Cactus People. Its complete Bonuses line names no parry and only a dodge
-- when running, which is conditional and so prose (bonuses_note), so combat
-- drops +2 parry and +3 dodge and takes +2 initiative, +1 Perception, +1
-- strike, +4 damage, +2 pull punch and +2 roll with impact.
--
-- Canada (1999) printed 102-103 had supplied the swim percentage, the bow
-- proficiency and the equipment; D-Bees restates all three, so nothing on the
-- row now comes from Canada.
--
-- The two stat_attacks rows (front kick 2D6 S.D.C., rear kick 4D6 S.D.C.)
-- match D-Bees' damage and are unchanged; D-Bees adds the P.S. damage bonus
-- and a Power Kick, both kept in natural_abilities.
--
-- Read off renders of both books (both at PDF offset +1). Guarded on the row
-- still citing Conversion Book One, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but Principled (25%), Scrupulous (30%), Unprincipled (15%) and Anarchist (15%) are most typical',
       attributes = '{"IQ":"3D6","ME":"2D6","MA":"2D6","PS":"3D6+6","PP":"3D6+6","PE":"3D6+12","PB":"3D6","Spd":"6D6x2"}',
       sdc = '50',
       pools_note = 'Hit Points gain an additional 1D6 per level of experience. S.D.C. is 50 plus those from Physical skills. Has no innate M.D.C.; only via M.D.C. body armor or barding, typically captured from humanoids or made from the skins, bones and plating of M.D.C. creatures like Fury Beetles and dinosaurs.',
       combat = '{"initiative":2,"perception":1,"strike":1,"damage":4,"pull":2,"roll":2}',
       bonuses_note = 'Attacks per melee are those of the Hand to Hand Combat skill and bonuses; a Centaur who is a Man-at-Arms O.C.C. gets +1 attack per melee. +2 on initiative, +1 to Perception Rolls, +1 to strike, +2 to dodge when running, +4 to damage, +2 to pull punch, +2 to roll with impact, +2 to save vs disease and +2 to save vs Horror Factor, in addition to attribute and skill bonuses. No penalties for shooting guns or bow and arrow while running. Vulnerabilities: free spirits that cannot live in captivity; even a few weeks in chains or a cage may kill one or drive it to desperate attempts to escape, and their part-animal appearance leads many to treat them as animals rather than people.',
       skills_note = 'R.C.C. skills regardless of O.C.C., based on instinct and racial memory: Hunting, Land Navigation +20%, Wilderness Survival +15%, W.P. Bow and Arrow, Dragonese/Elven 98% (50% are literate in it too), Faerie Speak +10% and one language of choice (typically American at +15%); all increase with experience.',
       natural_abilities = 'Great speed and endurance: travels at half its maximum Spd or does heavy labor for four hours before resting 3D6+20 minutes; 25-30 mph (40 to 48 km) is the average speed and 50 mph (80 km) the fastest, doubled for brief spurts of 2D4 minutes. Natural Prowl 60% +1% per level, track by sight 77% +1% per level, swim 50%; leaps 10 feet (3 m) high and 15 feet (4.6 m) across, double the length and half again the height with a running start. A kick with the front legs does 2D6 S.D.C. and a kick from the rear legs 4D6 S.D.C., each +P.S. damage bonus; a Power Kick with the rear legs does 1D4x10 S.D.C. +P.S. damage bonus but counts as two melee attacks; or damage by weapon, with Horsemanship: Knight giving the damage bonus for a weapon in a charge.',
       size = '6-7 feet (1.8-2.1 m) at the horse shoulders, about 10 feet (3 m) head to hoof',
       life_span = '4D6+66 years; physically mature by age 12; females give birth to a single foal once every two or three years up to age 42, after a 12 month pregnancy',
       habitat = 'The plains and light forests of Southwestern Canada and the American Northwest; they avoid the North in the cold and snowy months but love the tundra in summer, and a nomadic, curious Centaur may travel anywhere on the continent and sometimes beyond',
       allies = 'Faerie Folk; Simvan; Cyber-Horsemen; traditional Native Americans; Sasquatch; Cyber-Knights; Justice Rangers; Tundra Rangers',
       enemies = 'Dislike Psi-Stalkers and Bruutasaurs; generally fear and distrust humans and all two-legged people; hate Worm Wraiths, demons and monsters',
       occ_note = 'Palladium Fantasy: any O.C.C. but rarely magic, leaning Long Bowman, Druid, Ranger/Wilderness Scout, Mercenary/Headhunter, Scholar/Rogue Scholar, Vagabond/Peasant. Rifts: most typically Wilderness Scout, Trapper-Woodsman, Highwayman, Bounty Hunter, Cowboy, Justice Ranger, Tundra Ranger or Saddle Tramp, or the equivalent of an Indian Tribal Warrior, Spirit Warrior, Mystic Warrior or Shaman; any Men at Arms (except Glitter Boy, Robot Pilot and similar) or Adventurer O.C.C. is open, and a rare mage is typically a Mystic, Druid or Elemental Fusionist. In all cases the O.C.C. Related and Secondary Skill selections are halved. NPCs are level 1D8 or as the G.M. sets, player characters start at level one, and the chosen O.C.C.''s experience table is used. Standard equipment: as per O.C.C. plus one bow and arrows, a Vibro-Blade (often built into a spear), hunting knife, two water skins or canteens, saddlebag, backpack, bandoleer, utility belt, headband, one large sack and two small, and/or as per O.C.C.; few wear full barding, most partial M.D.C. armor. Money as per O.C.C. Most try to avoid cybernetics and bionics. Slave market value 2D4x10,000 credits; valued as warriors, scouts, cargo transporters and, by some monstrous beings, as pets or riding animals.',
       description = 'A nomadic, half-human half-horse plains people, skilled hunters and archers, wary of two-legged people but loyal once befriended. Rifts Conversion Book One printed 136-138, which this row followed until ~263, gave alignment as Any but mostly Principled or other good, P.S. 4D6, P.P. 4D6, P.E. 5D6, Spd 4D6x2, S.D.C. 25 plus O.C.C. and physical skills, a life span of 90 years with no maturity or birth figures, size 7 to 8 feet (2.1 to 2.4 m) at the shoulders and about 11 feet (3.3 m) head to hoof, a leap of 5 feet high or 9 feet across increased by 50% at a run, three attacks per melee round, and +1 on initiative, +2 to parry, +3 to dodge and +4 to damage with no other bonus and no vulnerabilities; its R.C.C. skills were Faerie Speak +20%, Prowl 60%, Track (animals and humanoids) 77%, Wilderness Survival 88% and Land Navigation 82%, the straight percentages not improving with experience, with no Hunting and no language of choice; its Rifts O.C.C. line was any except Coalition Military, robot and power armor pilots, Crazies, Juicer or Shifter, leaning to scholars and adventurers; its habitat was the western plains of Canada and the U.S., once Mexico before the Vampire Kingdoms drove them out; its allies added Fennodi, Psi-Ponies and the people of the Colorado Baronies, and its enemies were humans and humanoids who hunt or enslave them, Xiticix, Worm Wraiths, Slavers (mostly Splugorth), predatory plains dinosaurs, Leatherwing, Tree Spiders and the monsters of the Calgary Rift. Canada (1999) printed 102-103 had supplied the swim percentage, W.P. Bow and Arrow and the equipment, which D-Bees restates.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.44-45'
 WHERE slug = 'centaurs'
   AND source_book = 'Rifts Conversion Book One p.136-138';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the centaurs row cites D-Bees' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'centaurs'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.44-45';

SELECT 'the Centaur figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'centaurs'
   AND instr(attributes, '"PE":"3D6+12"') > 0
   AND instr(attributes, '"Spd":"6D6x2"') > 0
   AND sdc = '50'
   AND hp = 'PE+1D6'
   AND ppe = '4D6'
   AND horror_factor = 10
   AND combat = '{"initiative":2,"perception":1,"strike":1,"damage":4,"pull":2,"roll":2}'
   AND life_span LIKE '4D6+66 years%'
   AND instr(alignment, 'Principled (25%)') > 0
   AND allies LIKE 'Faerie Folk; Simvan;%'
   AND instr(description, 'which this row followed until ~263') > 0;

SELECT 'the Centaur kicks are unchanged' AS assertion, count(*) AS got, 2 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'centaurs'
   AND ((name = 'Front Kick' AND damage = '2D6 S.D.C.') OR (name = 'Rear Kick' AND damage = '4D6 S.D.C.'));

INSERT INTO data_script_runs (filename) VALUES ('~263-book-ingest-audit-f143-centaurs.sql');
