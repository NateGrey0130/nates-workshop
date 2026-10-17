-- The Trimadore's and the Vanguard Brawler's creature rows follow D-Bees of
-- North America (BOOK-INGEST-AUDIT F143, Coalition War Campaign part 2 of 3;
-- part 1 was ~222, and the Quick-Flex Alien and Kremin Cyborg are part 3).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~223-book-ingest-audit-f143-cwc-trim-vanguard.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~223-book-ingest-audit-f143-cwc-trim-vanguard.sql
--
-- The classes trimadore and vanguard-brawler follow Rifts World Book 30:
-- D-Bees of North America (2007), but their creatures rows still cited Rifts
-- World Book 11: Coalition War Campaign and carried its figures. By Nate's
-- ruling of 2026-10-04 the newest printing that STATES a figure wins, so
-- each row is UPDATED in place and moves its source_book; where D-Bees is
-- silent, the Coalition War Campaign figure stays. A complete line D-Bees
-- restates without an item drops that item. creatures has no notes column,
-- so each Coalition War Campaign figure that changed is kept in description
-- with its printed page. Attribute dice, size, weight, H.P., S.D.C., M.D.C.,
-- Horror Factor and P.P.E. are the same in both books, and each row keeps
-- its shape (F141).
--
-- Read off renders of both books (both at PDF offset +1). Guarded on each
-- row still citing Coalition War Campaign, so a re-run is a no-op. Neither
-- row has stat_attacks rows. THIS SCRIPT CHANGES PRODUCTION: two creatures
-- rows. The tilde number is claimed at merge.

-- Trimadore: D-Bees printed 206-208, Coalition War Campaign 208-209. Both
-- print it as a race with its own Trimadore Mechanic R.C.C. and optional
-- O.C.C.s, so the R.C.C. skill line follows D-Bees' list. The bonuses are
-- the same in both books, so combat does not change.

UPDATE creatures
   SET alignment = 'Any, but most are Scrupulous (25%), Unprincipled (30%) or Anarchist (25%)',
       pools_note = 'Hit Points are P.E. at first level, +1D6 each level. S.D.C. is 2D6 before physical skills. I.S.P. rises 2D4 a level. M.D.C. by armor or other external means only; the home-built armor they start with has 50-100 M.D.C.',
       bonuses_note = 'On top of hand to hand (typically Basic or Expert): one extra attack per melee. Saves: possession +1, disease and poison +1, and Horror Factor +1 at each of levels 1-6, 8, 10, 12, 14. Both printings give these bonuses; in Coalition War Campaign they repeat the Vanguard Brawler bonuses word for word, a possible copy slip for a gentle race, and D-Bees reprints them unchanged. Vulnerabilities: a clearly inhuman appearance can be a liability.',
       skills_note = 'Trimadore Mechanic R.C.C., bonuses first: +30% Basic and Advanced Math; +20% each to Computer Operation, Field Armorer, Jury-Rig, Recognize Weapon Quality and Salvage; +15% each to Mechanical Engineer and Sensory Equipment; +10% each to Computer Programming, Electrical Engineer, Military Fortifications, Pilot Hover Vehicle and one Pilot skill; Native Tongue: American (an adopted language) and Literacy: American +15%; one W.P.; Hand to Hand: Basic, which becomes Expert for one Related skill or Martial Arts (Assassin if evil) for two. Related: 5, and 2 more at 3, 6, 9, 12, with Mechanical +15% and Military +10% to Demolitions and Trap skills. Secondary: 4, and 1 more at 4, 8, 12.',
       natural_abilities = 'Flawless eyesight, sharp hearing, a fine sense of touch and a near-savant gift for machines; the long arms give an extended reach of 5-6 ft (1.5-1.8 m).',
       psionics = 'Four powers: Telemechanics (10), Speed Reading (2), Object Read (6), Mind Block (4); a Major Psychic. I.S.P. is 2D4x10 + M.E., rising 2D4 a level. D-Bees prints the Speed Reading cost as 92), read here as (2).',
       life_span = '3D6+56 years; physically mature by age 18, and females can bear young until 44',
       habitat = 'Anywhere, as they enjoy travel and exploration: fewer than a quarter million in the world, half of them in America and Canada. In North America most live in the Domain of Man around modern cities, including the Burbs of Chi-Town, Iron Heart and Free Quebec, Lazlo, New Lazlo, Kingsdale, MercTown, Arzno, Ciudad Juarez and the Pecos Empire, and in the Federation of Magic and the Magic Zone',
       allies = 'None per se; they gravitate toward like-minded people and those tolerant of D-Bees, and would get along great with Faerie Bot D-Bees',
       enemies = 'None per se, though they see the CS as a threat to all D-Bees and have no love for Xiticix, supernatural monsters or evildoers',
       occ_note = 'Optional: Headhunter, Merc Soldier, City Rat, Cyber-Doc, Operator, Preacher, Rogue Scholar, Techno-Wizard, Vagabond (any) or a similar O.C.C. in place of the Trimadore Mechanic R.C.C. Experience level 2D6 for NPCs, player characters start at first level; the Trimadore Mechanic uses the Operator experience table, an O.C.C. its own. The Trimadore Mechanic starts with 2D6x1,000 credits and 2D6x1,000 credits worth of spare parts; otherwise money by O.C.C. Slave market value 5D6x1,000 credits.',
       description = 'Tall, gangly D-bees with a long neck thick at the base, a small head with green almond-shaped eyes, hands of two long fingers and a thumb, and two-toed feet, also called Fixers. Soft-spoken, kind and cheerful tinkerers who are forever taking machines apart and cobbling them back together, they make natural builders, Operators and Techno-Wizards, and even those who fight are quick to accept a surrender. Coalition War Campaign printed 208-209, which this row followed until ~223, gave the alignment as Any, most anarchist and unprincipled; M.D.C. by armor only; disguise impossible; no life span, reach, experience level or slave value; no power costs and no psychic tier; Speaks American and one language of choice +20% and Literate in an Earth language of choice +15%, Armorer +20% and no Jury-Rig, Salvage or Sensory Equipment, six Related skills with Mechanical +10% and Military +10%, and five Secondary skills; the O.C.C.s as Scholar, Cyber-Doc, Operator or Techno-Wizard; 2D4x1,000 credits or stolen valuables to start; every Trimadore literate in at least one language besides its native tongue; no allies or enemies; and fewer than 100,000 on Earth.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.206-208'
 WHERE slug = 'trimadore'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.208-209';

-- Vanguard Brawler: D-Bees printed 208-210, Coalition War Campaign 206-208.
-- D-Bees prints it as a race that takes an O.C.C., with R.C.C. skills on
-- top. The row keeps the Vanguard Brawler Thug R.C.C. it has (Nate,
-- 2026-10-16): its skill and occupation lines stay, and D-Bees' R.C.C.
-- skills and O.C.C. sentence go in description, not applied. D-Bees' Bonuses
-- line adds +1 to disarm, so disarm joins combat. Its 90% illiteracy is the
-- one figure changed inside the held skill line; the experience level and
-- slave value are appended to the held occupation line.

UPDATE creatures
   SET alignment = 'Any, but Anarchist (33%), Aberrant (20%), Miscreant (26%) and Diabolic (15%) are the norm',
       pools_note = 'A Mega-Damage creature with no Hit Points or S.D.C. M.D.C. rises 1D6 each level; body armor, force fields or magic can add more.',
       combat = '{"initiative":2,"roll":2,"pull":2,"disarm":1}',
       bonuses_note = 'On top of hand to hand (typically Expert, Martial Arts or Assassin): one extra attack per melee. Saves: possession +1, disease and poison +1, and Horror Factor +1 at each of levels 1-6, 8, 10, 12, 14. The high P.E. makes most resistant to magic, disease and poison. Horror Factor 11 for their reputation for violence. Vulnerabilities: a clearly inhuman look makes disguise difficult and makes them a target of human supremacists; the back spines mean full human armor and clothing need costly customization; their aggressive nature can work against them; and a day or two of sitting still or routine work bores them out of their minds.',
       skills_note = replace(skills_note, 'Seven in ten cannot read.', 'Nine in ten cannot read.'),
       natural_abilities = 'Tough, scaly Mega-Damage hide good for only a few blasts; P.S. equal to Robot Strength, and damage by Robot Strength or weapon; keen hearing and smell; sees infrared; a natural climber. Two rows of 3-6 hooked back spines gouge anything that jumps on its back, and their pattern tells one Brawler from another.',
       magic = 'None, and no interest in it: too much studying and not enough fighting.',
       life_span = '3D6+48 years; physically mature by age 16, and females can bear young until 40',
       habitat = 'As many as 500,000 to 800,000 in North America, most in the American Midwest and the Domain of Man, with a fair number working as bandits and criminals in the Pecos Empire; they prefer city life and gather in family clans and gangs of their own kind',
       allies = 'None per se, but they get along well with humans, Larmac, Bruutasaurs, Quick-Flex Aliens, Malvoren, Fingertooth Carpetbaggers, Kraks, Grackle Tooth, City Rats, and military and criminal types',
       enemies = 'Greot Hunters and N''mbyr Gorilla Men are rivals and the Coalition an enemy; they dislike Ganka and any plant or insect-like D-Bees, may count the authorities or rival gangs as enemies by profession, and look down on wilderness people as farmers, hicks, savages and barbarians',
       occ_note = occ_note || ' Experience level 2D4 for NPCs, player characters start at first level. Slave market value 1D6x10,000 credits as soldiers, warriors, man-hunters and gladiators.',
       description = 'Pale blue-green, scaly, spine-backed D-bees, also called Brawlers, Spiny Brawlers and VBs, who lead street gangs and hire out as bounty hunters, mercenary soldiers, athletes, bodyguards, bouncers, enforcers and hit men. Brutal with fists and threats but cool and calculating rather than hot-tempered, they are shrewd strategists who lead like crime bosses and love physical games, sports and combat. D-Bees printed 208-210 makes the Vanguard Brawler a race that takes an O.C.C., which this row does not apply, keeping its Thug R.C.C.: on top of any O.C.C. every Brawler has Climbing +20%, Boxing, Roadwise +20% and Streetwise +20%, and can upgrade to Hand to Hand: Expert, Martial Arts or Assassin for one O.C.C. Related skill. Its O.C.C.s are physical ones such as Bandit, Gunfighter, Gunslinger, City Rat, Headhunter, Highwayman, Pirate, Sailor, Saloon Bum, Bounty Hunter, Master Assassin, Safecracker, Smuggler, Professional Thief, Freelance Spy, Super-Spy, Sheriff, Saddle Tramp, Merc Soldier, Vagabond, Vagabond Fighter/Street Thug and most soldier or criminal O.C.C.s, never magic, scholarly, Glitter Boy or Robot Pilot ones, and never Juicer or Crazy; equipment, money and bionics as per O.C.C., avoiding full conversion. Coalition War Campaign printed 206-208, which this row followed until ~223, gave the alignment as Any, a third anarchist and two thirds evil; no Robot Strength; extra M.D.C. from body armor or magic; no disarm bonus; magic by O.C.C. only; disguise impossible and no other vulnerabilities; seven in ten illiterate; no life span, experience level, slave value, allies or enemies; and fewer than half a million on the continent, most in the Midwest.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.208-210'
 WHERE slug = 'vanguard-brawler'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.206-208';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'both rows cite D-Bees and not Coalition War Campaign' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE (slug = 'trimadore' AND source_book = 'Rifts World Book 30: D-Bees of North America p.206-208')
    OR (slug = 'vanguard-brawler' AND source_book = 'Rifts World Book 30: D-Bees of North America p.208-210');

SELECT 'the Trimadore D-Bees figures landed and its pools and combat did not move' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'trimadore'
   AND combat = '{"initiative":2,"roll":2,"pull":2}'
   AND hp = 'PE+1D6'
   AND sdc = '2D6'
   AND isp = '2D4x10+ME'
   AND horror_factor = 9
   AND alignment LIKE 'Any, but most are Scrupulous (25%)%'
   AND life_span LIKE '3D6+56 years%'
   AND instr(skills_note, 'Jury-Rig') > 0
   AND instr(psionics, 'a Major Psychic') > 0
   AND instr(occ_note, 'Slave market value 5D6x1,000 credits') > 0;

SELECT 'the Vanguard Brawler D-Bees figures landed and its Thug R.C.C. stayed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'vanguard-brawler'
   AND combat = '{"initiative":2,"roll":2,"pull":2,"disarm":1}'
   AND mdc = 'PEx2'
   AND hp IS NULL
   AND horror_factor = 11
   AND alignment LIKE 'Any, but Anarchist (33%)%'
   AND life_span LIKE '3D6+48 years%'
   AND instr(skills_note, 'Vanguard Brawler Thug R.C.C.') > 0
   AND instr(skills_note, 'Nine in ten cannot read.') > 0
   AND instr(skills_note, 'Seven in ten') = 0
   AND instr(occ_note, 'may replace the Thug R.C.C.') > 0
   AND instr(occ_note, 'Slave market value 1D6x10,000 credits') > 0;

SELECT 'each keeps the Coalition War Campaign figures it replaced in its description' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE slug IN ('trimadore', 'vanguard-brawler')
   AND instr(description, 'which this row followed until ~223') > 0;

SELECT 'and neither has stat_attacks rows' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature'
   AND owner_slug IN ('trimadore', 'vanguard-brawler');

INSERT INTO data_script_runs (filename) VALUES ('~223-book-ingest-audit-f143-cwc-trim-vanguard.sql');
