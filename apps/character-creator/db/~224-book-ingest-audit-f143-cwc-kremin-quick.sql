-- The Kremin Cyborg's and the Quick-Flex Alien's creature rows follow D-Bees
-- of North America (BOOK-INGEST-AUDIT F143, Coalition War Campaign part 3 of
-- 3; parts 1 and 2 were ~222 and ~223).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~224-book-ingest-audit-f143-cwc-kremin-quick.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~224-book-ingest-audit-f143-cwc-kremin-quick.sql
--
-- The classes kremin-cyborg and quick-flex-alien follow Rifts World Book 30:
-- D-Bees of North America (2007), but their creatures rows still cited Rifts
-- World Book 11: Coalition War Campaign and carried its figures. By Nate's
-- ruling of 2026-10-04 the newest printing that STATES a figure wins, so
-- each row is UPDATED in place and moves its source_book; where D-Bees is
-- silent, the Coalition War Campaign figure stays. A complete line D-Bees
-- restates without an item drops that item. creatures has no notes column,
-- so each Coalition War Campaign figure that changed is kept in description
-- with its printed page.
--
-- Shape (Nate, 2026-10-16): D-Bees prints both as a race that takes an
-- O.C.C., with R.C.C. skills on top. Each row keeps the R.C.C. it has: its
-- skill and occupation lines stay, and D-Bees' R.C.C. skills and O.C.C.
-- sentence go in description, not applied. The experience level, slave value
-- and (Kremin) starting money are appended to the held occupation line.
--
-- Read off renders of both books (both at PDF offset +1). Guarded on each
-- row still citing Coalition War Campaign, so a re-run is a no-op.
-- stat_attacks does not change: the Kremin keeps its five rows and the
-- Quick-Flex Alien has none. THIS SCRIPT CHANGES PRODUCTION: two creatures
-- rows. The tilde number is claimed at merge.

-- Kremin Cyborg: D-Bees printed 111-114, Coalition War Campaign 209-211.
-- D-Bees prints two bionic lines, civilian and explorer/lawman/combat; the
-- row is the explorer line Coalition War Campaign printed, so its attributes
-- take D-Bees' explorer figures and the civilian line goes in description.
-- M.D.C. by location, Horror Factor and P.P.E. are the same in both books.
-- D-Bees' Bonuses line adds disarm, entangle and pull punch, so combat gets
-- those three keys; the extra attack (adults only) is in bonuses_note, as
-- the other F143 rows carry theirs. Its Habitat line refers to its Alliances
-- line, so Coalition War Campaign's head counts are dropped with that line.

UPDATE creatures
   SET alignment = 'Any, but Principled (25%), Scrupulous (35%), Unprincipled (15%) and Anarchist (15%) are common; psionic blockers in their brains stop anyone reading their thoughts, and so much bionics makes an aura hard to read',
       attributes = '{"IQ":"3D6","MA":"3D6+2","ME":"3D6+4","PS":"2D6+24","PP":"1D4+22","PE":"N/A","PB":"1D6+6","Spd":"4D6+108"}',
       size = 'Males 8 feet (2.4 m), females 7 feet (2.1 m)',
       weight = 'Males 600-800 pounds (270-360 kg), females 400-500 pounds (180-225 kg); teenagers about the same as females, children half that',
       pools_note = 'A full-conversion alien cyborg with no Hit Points or S.D.C.; M.D.C. is the Main Body. By location: Main Body 280, Head 110, each Leg 130, each Arm 95, each Foot 50, each Hand 30, Multi-Weapon Blade and Sheath 60 (printed as one item, "60 each"). Civilian males have 20% less M.D.C., civilian females 30% less, teenagers and children 50% less. P.S., P.P. and Spd are bionic: the explorer, lawman and combat line (about 20% of Kremin) is P.S. 2D6+24, P.P. 1D4+22, P.B. 1D6+6 by human standards, Spd 4D6+108 (76-90 mph, 121.6-144 km); P.E. not applicable.',
       combat = '{"disarm":2,"entangle":1,"pull":3}',
       bonuses_note = 'Hand to Hand: Expert. One extra melee action/attack per melee (adults only). Brain blockers: +2 to save vs psionic attack, +3 vs illusions and hypnosis, +6 vs possession. Horror Factor save gains +1 at each even level from 2 to 14. Vulnerabilities: clearly a cyborg, so disguise is impossible, and thanks to the CS, Kremin are believed to be hostile alien invaders on the run.',
       natural_abilities = 'Psionic dampers in the living brain work as a permanent Mind Block against reading surface thoughts, emotions or aura, sensing good or evil, or a full telepathic probe. Nano restorers mend damage, folding salvaged Earth plating, circuits and whole limbs into the alien body; they also mend the traditional vest and cowl, a soft M.D. metal like thin vinyl with 25 M.D. Energy Fist: a 4D6 M.D. punch or a short blast of 2D6, 3D6 or 4D6 M.D. as desired, range 500 feet (152 m), at most four punches or two blasts per melee round. Bionics of note: finger jack and headjack, amplified hearing, translator, full optics, molecular analyzer, voice amplifier, radio, laser finger tool, climb cord, 1D4 hidden compartments and three more of choice (any, weapons included). The natural senses are perfect 20/20 color vision, hearing twice as keen as a human''s, and human taste and smell.',
       life_span = '5D6+70 years (double that on their home world before the Minion War)',
       habitat = 'Explorers fled CS territories for the New West, Texas, Minnesota, Wisconsin and Michigan, and the refugees who survived their arrival on Rifts Earth head for the same places',
       allies = 'They go to Lazlo, New Lazlo, the Colorado Baronies and Arzno to seek help and warn of the Minion War, and find the New West, the Pecos Empire and the Deep South safer, being less likely to have heard of the alleged invasion and less inclined to believe the Coalition',
       enemies = 'The Coalition States, whose troops have had a standing order for the last decade to destroy all Kremin on sight; with evidence of a Kremin invasion most people view them with suspicion and fear, and xenophobic humans and D-Bees side with the CS and hunt them down wherever they are found',
       occ_note = occ_note || ' Experience level 2D4 for NPCs, player characters start at level one. Starts with 1D4x1000 credits worth of tradeable goods. Slave market value 2D4x10,000 credits as warriors, heavy labor, gladiators and oddities.',
       description = 'Alien cyborgs from a peaceful, Japanese/samurai-like world: bipedal humanoids with black hair, almond eyes, large pointed ears and tiger stripes on the cheeks or forehead, so heavily augmented they are more machine than flesh. Explorers cut off on Rifts Earth when their dimensional portal tore itself apart minutes after they arrived, they say they are envoys of good will, fight mostly in self-defence and simply observe. In Summer 109 P.A. some half million Kremin refugees, fleeing the Minion War on their home world, were sent through a Rift onto the edge of the Xiticix Hivelands with demons and Deevils on their heels; the CS calls it an invasion thwarted near Thunder Bay, puts the escapees into the Canadian wilderness at 20,000-30,000, and hunts small bands of 1D6x10 moving into the New West. D-Bees printed 111-114 makes the Kremin a race that takes an O.C.C., which this row does not apply, keeping its Kremin Cyborg R.C.C.: on top of any O.C.C. every Kremin has W.P. Sword, Hand to Hand Basic (Expert for explorers and lawmen), its native language at 98% and literacy in it at 96%, Math: Basic +25% and Philosophy +15%. All are partial (55%) or full (45%) conversion cyborgs and may take nearly any Adventurer or Scholar O.C.C. or basic soldier or law enforcement O.C.C., Body Fixer included; Cyber-Doc, Operator, Rogue Scholar, Rogue Scientist, Vagabond and Wilderness Scout are common, Combat Cyborg, Headhunter and military O.C.C.s rare, magic and psionics out of the question, and levels use the chosen O.C.C.''s experience table. Its civilian line is P.S. 1D6+20, P.P. 1D6+16, P.B. 1D6+8, Spd 2D6+77 (53-60 mph, 85-96 km), with a radio, clock calendar, fingerjack, gyro-compass and one bionic feature of choice, and arms and legs bionic (01-55%), all but the head (56-85%) or a full conversion (86-00%). Every Kremin starts with 1D6 sets of clothing, a utility belt, backpack, satchel, tool kit, flashlight, canteen, a Japanese-style Vibro-Sword (3D6 M.D.), the Multi-Weapon Blade, an Earth energy weapon and personal items. Coalition War Campaign printed 209-211, which this row followed until ~224, gave the alignment as unknown, most seeming anarchist or unprincipled; M.A. 3D6; P.S. 22+1D6 and Spd 132 (90 mph, 148 km); one size and weight, 8 feet and 600 pounds (270 kg); no M.D.C. reduction for civilians; no combat bonuses beyond Hand to Hand: Expert; the Horror Factor save bonus under an R.C.C. Skills heading; an Energy Fist blast of 4D6 M.D. only; various secret compartments and no bionics of choice; no vest and cowl, life span, experience level, slave value or allies; 1D4x1000 credits to start; and a habitat of Michigan, Free Quebec, Minnesota, Texas and the western wilderness, with only three dozen come through, nine destroyed by the CS, and fewer than 30 (100 at most) wandering the Americas.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.111-114'
 WHERE slug = 'kremin-cyborg'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.209-211';

-- Quick-Flex Alien: D-Bees printed 168-170, Coalition War Campaign 205-206.
-- Attributes, weight, H.P., S.D.C., Horror Factor and P.P.E. are the same in
-- both books. D-Bees' Bonuses line adds strike, parry and a +3 automatic
-- dodge, so combat gets those three keys; Perception, the extra attack and
-- the conditional strike with guns and bows are in bonuses_note. That line
-- no longer names paired weapons, which D-Bees moves to its R.C.C. skills
-- (in description). Its skill penalty replaces Coalition War Campaign's;
-- the held Rogue R.C.C.'s own exemption stays.

UPDATE creatures
   SET alignment = 'Any, but lean toward Scrupulous (20%), Unprincipled (30%) and Anarchist (30%)',
       size = '5 ft 4 in to 5 ft 10 in (1.6-1.75 m) tall',
       combat = '{"initiative":2,"strike":1,"parry":2,"automatic_dodge":3,"roll":2,"pull":2}',
       bonuses_note = 'On top of hand to hand (typically Basic or Expert): +1 attack per melee, +3 on Perception Rolls, and +1 to strike with modern weapons/guns or any bow and arrow even without the W.P. The automatic dodge is rolled as usual but uses no melee attack. Horror Factor not applicable. Vulnerabilities: thrill-seekers who enjoy a fast pace and taking risks; jumpy and hyper, they cannot sit still for more than 1D4 hours and are easily bored, and the short attention span makes complex skills and intense study hard, so there are few doctors, lawyers, scholars or scientists among them, magic is too demanding, and most are illiterate. Skill penalty: -10% on all skills (regardless of O.C.C. bonuses) except Espionage, Physical, Pilot, Rogue and W.P. skills; the skills and Related skills of the Quick-Flex Rogue R.C.C. take no penalty.',
       natural_abilities = 'Reflexes and speed about equal to a Juicer or Crazy, from a higher metabolism; ambidextrous; double-jointed, and can pop joints to slip out of confinement, ropes and the like; leaps 8 feet (2.4 m) high or across from a standstill, 4 feet (1.2 m) more with a run.',
       life_span = '4D6+60 years; physically mature by age 15, and females can bear young until 42',
       habitat = 'Common to North America, particularly the New West and the Midwest, including the Chi-Town and Iron Heart Burbs, New Lazlo, Kingsdale and the Pecos Empire, with an estimated one million more scattered across Canada, America and Northern Mexico; an estimated 10,000 perished in the Coalition-Tolkeen War',
       allies = 'Varies with occupation and alignment, but they generally get along well with humans and most D-Bees, and admire courage, physical capability, heroes and athletes',
       enemies = 'Juicers, Crazies and similar physically skilled and fast races and O.C.C.s are rivals and competitors; they dislike the Coalition States, slavers and the Minions of Splugorth, and view most practitioners of magic, creatures of magic and supernatural beings with distrust and suspicion, especially those involved with the Federation of Magic',
       occ_note = occ_note || ' Experience level 2D4+1 for NPCs, player characters start at level one. Slave market value 3D6x10,000 credits as a gunslinger, warrior, gladiator, spy or getaway driver.',
       description = 'The textbook D-bee: at a glance human, until you notice the big eyes, long face and pinhole nostrils. A racing metabolism makes it small, hyper and as quick as a Juicer, so it makes a natural gunman, gunslinger, sniper, thief, pilot or acrobat. Typically upbeat, energetic and looking for action, many with a strong sense of justice and fair play, they love adventure, fast vehicles and tattoos on the arms and chest. D-Bees printed 168-170 makes the Quick-Flex Alien a race that takes an O.C.C., which this row does not apply, keeping its Quick-Flex Rogue R.C.C.: on top of any O.C.C. every Quick-Flex has Combat Driving, Escape Artist +20%, W.P. Paired Weapons, W.P. Quick Draw and W.P. Targeting, and most have forgotten their native language and speak American +20% and one language of choice +10%. Its O.C.C.s are limited to physical ones: Bandit, Bounty Hunter, City Rat, Cyber-Knight, Gunfighter, Gunslinger, Headhunter, Highwayman, Merc Soldier, Soldier (any), Sailor, Pirate, Pecos Raider, Professional Thief, Master Spy, Super Spy, Smuggler, Saddle Tramp/Drifter, Vagabond (any), Wilderness Scout (any), and any adventurer, Lawman or soldier O.C.C. needing no dramatic bionic conversion or physiological change, so never Juicer or Crazy; Robot Pilot is acceptable but seldom liked, and they never study magic. Levels use the chosen O.C.C.''s experience table, and equipment and money are as per O.C.C., favoring pistols of all kinds, Vibro-Knives, and light or medium body armor or Naruni force fields. Coalition War Campaign printed 205-206, which this row followed until ~224, gave the alignment as Any; a height of 5 ft to 5 ft 6 in (1.5-1.65 m); no life span; no double joints; paired weapons and an automatic dodge like the Commando hand to hand as bonuses, with no Perception, strike, parry or automatic dodge figure; the -10% skill penalty only with a human O.C.C., sparing Physical and Rogue skills alone; no allies, enemies, experience level or slave value; and about a million in all, mostly in the Midwest.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.168-170'
 WHERE slug = 'quick-flex-alien'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.205-206';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'both rows cite D-Bees and not Coalition War Campaign' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE (slug = 'kremin-cyborg' AND source_book = 'Rifts World Book 30: D-Bees of North America p.111-114')
    OR (slug = 'quick-flex-alien' AND source_book = 'Rifts World Book 30: D-Bees of North America p.168-170');

SELECT 'the Kremin D-Bees figures landed and its R.C.C. and M.D.C. stayed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'kremin-cyborg'
   AND attributes = '{"IQ":"3D6","MA":"3D6+2","ME":"3D6+4","PS":"2D6+24","PP":"1D4+22","PE":"N/A","PB":"1D6+6","Spd":"4D6+108"}'
   AND combat = '{"disarm":2,"entangle":1,"pull":3}'
   AND mdc = '280'
   AND hp IS NULL
   AND horror_factor = 9
   AND ppe = '1D4'
   AND alignment LIKE 'Any, but Principled (25%)%'
   AND life_span LIKE '5D6+70 years%'
   AND instr(skills_note, 'CS Technical Officer') > 0
   AND instr(occ_note, 'Kremin Cyborg R.C.C.') > 0
   AND instr(occ_note, 'Slave market value 2D4x10,000 credits') > 0;

SELECT 'the Quick-Flex D-Bees figures landed and its Rogue R.C.C. stayed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'quick-flex-alien'
   AND combat = '{"initiative":2,"strike":1,"parry":2,"automatic_dodge":3,"roll":2,"pull":2}'
   AND attributes = '{"IQ":"3D6","MA":"3D6","ME":"3D6","PS":"3D6","PP":"3D6+6","PE":"3D6","PB":"2D6","Spd":"6D6+25"}'
   AND hp = 'PE+1D6'
   AND sdc = '3D6'
   AND ppe = '2D6'
   AND horror_factor IS NULL
   AND alignment LIKE 'Any, but lean toward Scrupulous (20%)%'
   AND life_span LIKE '4D6+60 years%'
   AND instr(skills_note, 'Quick-Flex Rogue R.C.C.') > 0
   AND instr(occ_note, 'may replace the Quick-Flex Rogue R.C.C.') > 0
   AND instr(occ_note, 'Slave market value 3D6x10,000 credits') > 0;

SELECT 'each keeps the Coalition War Campaign figures it replaced in its description' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE slug IN ('kremin-cyborg', 'quick-flex-alien')
   AND instr(description, 'which this row followed until ~224') > 0;

SELECT 'and the Kremin keeps its five stat_attacks rows, the Quick-Flex none' AS assertion, count(*) AS got, 5 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature'
   AND owner_slug IN ('kremin-cyborg', 'quick-flex-alien');

INSERT INTO data_script_runs (filename) VALUES ('~224-book-ingest-audit-f143-cwc-kremin-quick.sql');
