-- Coalition War Campaign races' creature rows follow D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, part 2 of 3: Coalition War Campaign).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~222-book-ingest-audit-f143-cwc.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~222-book-ingest-audit-f143-cwc.sql
--
-- Each class below follows Rifts World Book 30: D-Bees of North America
-- (2007), but its creatures row still cited Rifts World Book 11: Coalition
-- War Campaign and carried its figures. By Nate's ruling of 2026-10-04 the
-- newest printing that STATES a figure wins, so each row is UPDATED in place
-- and moves its source_book; where D-Bees is silent, the Coalition War
-- Campaign figure stays. A complete line D-Bees restates without an item
-- drops that item. creatures has no notes column, so each Coalition War
-- Campaign figure that changed is kept in description with its printed page.
-- Attribute dice, H.P., S.D.C. and P.P.E. are the same in both books except
-- where named below, and each row keeps its shape (F141).
--
-- Read off the Coalition War Campaign text layer and renders of D-Bees (both
-- at PDF offset +1). Guarded on each row still citing Coalition War
-- Campaign, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION. The
-- tilde number is claimed at merge.

-- N'mbyr Gorilla Man: D-Bees printed 143-144, Coalition War Campaign 202-203.
-- D-Bees prints racial bonuses where Coalition War Campaign printed none, so
-- combat moves from NULL to those four keys. The average N'mbyr's I.S.P. is
-- the P.E. number, the Eruptor's P.E. x3; isp holds the average's.

UPDATE creatures
   SET alignment = 'Any, but lean toward Scrupulous (20%), Unprincipled (20%) and Anarchist (35%)',
       isp = 'PE',
       pools_note = 'Hit Points: P.E. plus 1D6 per level of experience. I.S.P.: the P.E. number, +10 per level from level one; an Eruptor has P.E. x3, +10 per level. M.D.C. only from body armor or other means.',
       combat = '{"damage":4,"parry":1,"pull_punch":2,"strike":1}',
       bonuses_note = '+1 to strike and parry, +2 to pull punch, +4 to damage, +1 to save vs Horror Factor, in addition to attribute and skill bonuses. Attacks per melee are those of the Hand to Hand skill. Horror Factor 10 (15 to children and women) only when enraged. Violent outburst when seriously angry, embarrassed, frightened or frustrated: +1 attack per melee, +2 on initiative, +1 to strike, +10 P.S. and the P.S. becomes the equal of a Supernatural P.S. of 1D4+21 (2D6 M.D. punch or kick, 4D6 M.D. power punch, 1 M.D. bite), +6 to save vs Horror Factor, +2 vs mind control, possession and psionic attack; -30% on skills, -2 to dodge, cannot pull punches, fears nothing, and forgets mission, friends and its own safety. Vulnerabilities: a low tolerance for alcohol and drugs, -6 to save vs drugs (though resistant to poisons and toxins), 40% struggle with addiction; short tempers bring regular trouble; an inhuman look that is hard to disguise and gets them treated as dumb animals.',
       skills_note = 'R.C.C. skills: Language: Native Tongue (N''mbyr at 95%), Wrestling, Physical Labor and Athletics (General), on top of O.C.C. skills; the O.C.C. Related and Secondary skill picks are halved. Few are literate or scholarly.',
       natural_abilities = 'Keen vision, nightvision 120 ft (36.5 m), Augmented P.S., and psionic powers.',
       magic = 'None, and not interested in magic.',
       psionics = 'The average N''mbyr has 1D4+2 physical psionic powers of choice and is a Major Psychic. 20% are Psychic Eruptors (Master Psychics, with no new powers as they rise in level): 1D4+1 physical powers plus one of Electrokinesis, Hydrokinesis, Pyrokinesis, Telekinesis (Super) or Telekinetic Force Field, at double range and duration and +1D6 M.D. damage. I.S.P. in pools_note.',
       life_span = '3D6+50 years, and females live 1D4+4 years longer; physically mature by age 16',
       habitat = 'Mainly the Midwest (above all Minnesota, Illinois, Arkansas and Missouri), the Magic Zone, Ontario Canada and the Pecos Empire; they came through a dimensional portal in the ruins of Old Chicago, and thousands perished with the fall of Tolkeen',
       allies = 'None per se. They respect those who treat them with respect and not as dumb animals, and respect strength and fighting skill, so they gravitate toward fighters, laborers and the common man',
       enemies = 'Dislike Larmac and Bayou Ursines as lazy smart-alecks, feel oppressed by the CS, and do not care for mages or creatures of magic',
       occ_note = 'Any Men of Arms or Adventurer O.C.C., with O.C.C. Related and Secondary skills halved; they lean toward military and physical O.C.C.s, never magic ones. Crazy conversion does not work on them; a Juicer gets the Juicer powers plus 1D6 random insanities, cannot detox and burns out in 1D4 years. Experience level 1D6 for NPCs, player characters start at first level, on the chosen O.C.C.''s table. Equipment and money as per O.C.C.; they are often paid a third to half of what others make. Slave market value 4D4x1,000 credits.',
       description = 'Ape-faced, long-armed, short-legged D-bees covered in orange, tan or red fur, who love hard labor, wrestling and football and make fine climbers and warriors. Most are good-natured, but any of them can fly into a rage and maul even a friend. Coalition War Campaign printed 202-203, which this row followed until ~222, gave the alignment as Any with no percentages; no life span; no racial bonuses, no Horror Factor condition and no vulnerabilities; a violent outburst of +10 P.S. equal to a Supernatural P.S. of 19 (1D6 M.D. punch or kick, 2D6 M.D. power punch) with no initiative or strike bonus; I.S.P. of M.E. x3 +10 per level for every N''mbyr, with the 20% Eruptors as major or master psychics and their damage +1D6 points; Native N''mbyr, American +20% and one language of choice +15% as its skills; the O.C.C.s as any Men of Arms, Vagabond or Wilderness Scout; 2D6x10 credits to start; no allies, enemies, experience level or slave value; and a habitat of the Midwest, above all Illinois, Arkansas, Missouri and the Magic Zone, with the Chi-Town Burbs.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.143-144'
 WHERE slug = 'nmbyr-gorilla-man'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.202-203';

-- Tirrvol Sword Fist: D-Bees printed 201-203, Coalition War Campaign 203-205.
-- D-Bees raises P.B. to 1D6+1. Its Bonuses line restates the racial bonuses
-- without Coalition War Campaign's +1 to parry, so parry leaves combat; pull
-- stays, the Natural W.P. Sword Ability's first-level +1 to pull punch.

UPDATE creatures
   SET alignment = 'Any, but most are Principled (25%), Scrupulous (35%), Unprincipled (15%), Anarchist (10%) or Aberrant (10%)',
       attributes = '{"IQ":"3D6+1","ME":"3D6+1","MA":"3D6+1","PS":"5D6+6","PP":"3D6+6","PE":"3D6+6","PB":"1D6+1","Spd":"3D6"}',
       pools_note = 'A minor Mega-Damage creature with no Hit Points or S.D.C. M.D.C.: plus 2D6 per level of experience; most also get cyber-armor. I.S.P.: plus 1D6 per level. P.S. is supernatural and does M.D.',
       combat = '{"initiative":2,"roll":1,"pull":1}',
       bonuses_note = '+1 attack per melee round, +2 on initiative, +1 to roll with impact, in addition to attribute and skill bonuses; attacks per melee otherwise come from the Hand to Hand skill. Horror Factor save gains +1 at levels 1, 2, 4, 6, 8, 10, 12 and 15. Natural W.P. Sword Ability: strike, parry and disarm with the sword fists each gain +1 at levels 1, 3, 4, 6, 8, 10, 12 and 14; pull punch/sword strike gains +1 at levels 1, 2, 3, 5, 7, 9, 12 and 15. A natural 17-20 is a double-damage critical, as is a strike from behind. A sword fist does Supernatural P.S. damage +2D6 M.D. as a blade, 1D4 M.D. more with the flat of the blade; a power punch does double damage and counts as two melee attacks; a pulled strike can do whatever damage it chooses, as little as 2D6 S.D.C. All undead, and demons and supernatural beings vulnerable to bone, take double damage from the sword fist. Firing a gun with the feet is -2 to strike. Vulnerabilities: difficulty speaking most humanoid languages, and no fingers or thumb.',
       skills_note = 'R.C.C. skills, on top of O.C.C. skills: its whistle-and-click native tongue, American +20% and one language of choice +15%; 70% are also Literate in American or a written language of choice +15%; Dance +15% and W.P. Paired Weapons. Skills needing manual dexterity or precision (Piloting, Mechanics, Medical, Demolitions and so on) are -10%.',
       natural_abilities = 'Mega-Damage hide and bone, and sword fists that inflict M.D.; keen vision and good hearing; heals twice as fast as a human and regrows sword hands and other limbs within 3D4 weeks. Blades of M.D. bone replace the fingers, with a bony hook for a thumb, yet it can still work a computer. Double-jointed legs and prehensile feet serve as hands, even to drive.',
       psionics = 'A Minor Psychic: See the Invisible, Sense Evil, Sixth Sense, and one more Sensitive power of choice. I.S.P. is twice M.E., plus 1D6 per level.',
       weight = '250-500 lbs (112.5-225 kg)',
       habitat = 'A few hundred live in the Chi-Town and Iron Heart Burbs, and others have traveled to the New West, Canada and Mexico; fewer than a thousand are believed to exist in all of North America. Their origin is unknown',
       allies = 'Cyber-Knights, Justice Rangers, Tundra Rangers, Reid''s Rangers (vampire slayers), the people of Arzno and other heroes and champions',
       enemies = 'Evil in all its guises, above all monsters, demons and evil supernatural beings; many are concerned about the Vampires of Mexico, the Kingdom of Monsters in Calgary and the Federation of Magic',
       occ_note = 'Any Men of Arms or Adventurers and Scholars O.C.C., except Juicer, Crazy, Glitter Boy and Robot Pilot; they lean toward soldier types. Experience level 2D6 for NPCs, player characters start at first level, on the chosen O.C.C.''s table. Player characters start with 3D4x1000 credits and some basic equipment. Cybernetics and bionics: avoided, except cyber-armor, a few basic implants and prosthetics.',
       description = 'Huge, barrel-chested, grey-hided D-bees with a snaking neck and ivory bone swords for hands. Most are honorable warriors and superb swordsmen who speak in short sentences and are well paid as enforcers, soldiers, bodyguards and heroes. Coalition War Campaign printed 203-205, which this row followed until ~222, gave the alignment as Any, most (60%) good and aberrant the commonest evil; P.B. 1D6; the weight in pounds only; some also using magic for M.D.C.; +1 to parry among the racial bonuses, with paired weapons as a bonus rather than a skill; sword-fist damage equal to the Supernatural P.S. with no +2D6 M.D. blade, no flat-blade damage, no double damage to the undead and no two-attack cost for a power punch; no penalty for firing a gun with the feet and no vulnerabilities; the second language at +20%, literacy with no bonus, and no Dance; the O.C.C.s as any Men of Arms, scholar or adventurer except Juicer and Crazy; no experience level; avoiding bionics except cyber-armor; a few hundred in the Chi-Town Burbs and fewer than a thousand in all the Americas; and as allies only the champions of good, some rumored to have joined the Cyber-Knights, against tyranny and evil.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.201-203'
 WHERE slug = 'tirrvol-sword-fist'
   AND source_book = 'Rifts World Book 11: Coalition War Campaign p.203-205';

-- READBACKS

INSERT INTO data_script_runs (filename) VALUES ('~222-book-ingest-audit-f143-cwc.sql');
