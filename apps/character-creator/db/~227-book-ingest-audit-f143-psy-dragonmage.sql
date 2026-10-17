-- The Demon-Dragonmage's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 3 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~227-book-ingest-audit-f143-psy-dragonmage.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~227-book-ingest-audit-f143-psy-dragonmage.sql
--
-- The class demon-dragonmage follows Rifts World Book 30: D-Bees of North
-- America (2007), printed 58-60 with its last lines on 61 (~096), but its
-- creatures row still cited Rifts World Book 12: Psyscape printed 120-123
-- and carried its figures. By Nate's ruling of 2026-10-04 the newest
-- printing that STATES a figure wins, so the row is UPDATED in place and
-- moves its source_book; where D-Bees is silent, Psyscape's figure stays.
-- The row cites printed 58-61 because its habitat, allies and enemies are
-- read off 61. A complete line D-Bees restates without an item drops that
-- item: the Hand to Hand line's "or upgraded", the secondary skills' tie to
-- the related list, the Allies line's other supernatural beings, psychics
-- and practitioners of magic, and the lore's Goblins among the worshippers
-- and adults conquering entire worlds. creatures has no notes column, so
-- each Psyscape figure that changed is kept in description with its printed
-- page.
--
-- Body: unchanged. Both books print the same eight attribute dice, M.D.C.
-- P.E. x10 (+3D6 per level), P.P.E. 1D4x100 plus P.E., I.S.P. 2D4x10 plus
-- M.E., Horror Factor 10 (15 mature), size and weight, so hp, sdc, mdc,
-- ppe, isp, horror_factor, attributes, size and weight stay. D-Bees marks the
-- Young's P.S. as Robotic and the adult's as Supernatural; pools_note says
-- so. combat stays NULL: D-Bees gives attacks per melee as per the Hand to
-- Hand skill and every numeric bonus at a level, so they stay in
-- bonuses_note, which gains 12th level's +2 Perception and 20th level's +2
-- attacks. psionics is the same in both books and does not change. D-Bees'
-- ability ladder runs to 30th level where Psyscape stopped at 10th; the new
-- steps go in natural_abilities. Both books print the Demon-Dragonmage as an
-- R.C.C. with its own skills, so the row's shape is the same in both (F141
-- does not arise). Its two stat_attacks rows (fire breath and fire ball,
-- 300 ft, 6D6 MD, mature only) match D-Bees and are not touched.
--
-- Read off renders of both books (both at PDF offset +1: D-Bees cache
-- p059-p062, Psyscape cache p121-p124). Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Young: any, but usually Unprincipled (20%), Anarchist (40%) or any evil (20%). Adults are Miscreant (30%), Diabolic (34%) or Aberrant (15%), with only a small percentage Anarchist (15%) or good (6%)',
       pools_note = 'Attributes and pools are the Young-Dragonmage''s, whose P.S. is Robotic. A mega-damage creature: M.D.C. P.E. x10, +3D6 per level. P.P.E. +3D6 per level. I.S.P. +10 per level. ADULT: after slaying a dragon and joining its head to its chest, the mature Demon-Dragonmage gains +1,200 M.D.C., doubles its P.P.E., raises I.Q., M.E., M.A., P.P. and P.E. by 30%, its P.S. becomes Supernatural, doubles P.S. and Spd, gains wings and flight, and its Horror Factor becomes 15.',
       bonuses_note = 'Level abilities: +2 roll with impact at 2nd; +1 attack, +1 initiative, +2 pull punch and +3 save vs Horror Factor at 5th; +6 save vs possession at 8th; +2 on Perception Rolls at 12th; +2 attacks per melee at 20th. Attacks per melee as per its Hand to Hand skill; damage as per Robot or Supernatural P.S., or by magic or weapon. Magical cold and ice and holy weapons do double damage; magic, psionics and energy weapons do full damage.',
       skills_note = 'Demongogian and Dragonese at 98% plus two languages (+15%), one literacy (+15%), Basic Math (+20%), Seduction (+13%), Dance (+20%), Sing (+10%), Climb (+10%), Land Navigation (+10%), Lore: Demons & Monsters (+20%), one lore (+10%), two Pilot or Horsemanship skills, one ancient and one modern W.P., Hand to Hand: Expert (Assassin if Anarchist or evil), which cannot be changed once selected. Five related skills plus one at levels 4, 8 and 12 and two at levels 14, 16, 18, 20, 24, 26, 28 and 30: most categories open, Communications, Espionage, Military, Pilot and Science +5%, Rogue and Technical +10%; no Cowboy, Electrical, Mechanical, Medical or Wilderness. Two secondary skills from the Secondary Skill List of Rifts Ultimate Edition (p.300) at levels 1, 3, 5, 8, 11, 15, 18, 21, 25 and 30, without bonuses other than a high I.Q. bonus.',
       natural_abilities = 'Perfect vision, senses on par with a human''s. Impervious to ordinary heat and fire, M.D. plasma included; magic fire does half (adults are immune even to magic fire). Gains powers by level: nightvision 1000 ft, see the invisible, fast healing and immunity to disease (1st); leap 10 ft (2nd); invisibility at will (3rd); bio-regenerates 1D6 M.D.C. per melee (4th); speaks all languages (6th); senses ley lines (7th); teleports self and 300 lbs up to five miles (9th); becomes a Greater Demon with Dimensional Teleport 30% +2% per level (10th); +2D6x10 M.D.C. and flying speed +50% (15th); double the range of its fire attacks (18th); bio-regenerates 1D6x10 M.D.C. per melee (25th); regenerates its entire body within 48 hours, provided the dragon''s head is not destroyed and at least 20% of the body remains intact (30th). Adults breathe fire and spit fire balls. Cannot take implants or bionics.',
       magic = 'Casts like a Ley Line Walker without that O.C.C.''s other abilities: starts with Blinding Flash, Ignite Fire, Fuel Flame, Fire Bolt and Fire Ball plus 3D4+8 spells from levels 1-6, learns more as a Ley Line Walker does, via a tutor, and from 10th level may make its selections from Temporal Magic instead.',
       life_span = 'Seemingly immortal unless slain, but a Young-Dragonmage that has not reached maturity by 2100 years of age dies; youth typically lasts 1000 to 2000 years, and a juvenile is a fully formed adult by age 20. None breed until both male and female are adult Demon-Dragonmages; the female then bears 1D4 young after a 9 year pregnancy, as often as once every 100 years until age 5000, though few give birth more than two or three times',
       habitat = 'Anywhere in the Megaverse; the young wander as adventurers or bandits and adults build kingdoms or try for world domination. On Rifts Earth most common in places of magic and regions where they may find and slay dragons; North America is a favorite, at least a hundred operate from the Magic Zone, and several dozen fought for Tolkeen, as much for its magic artifacts as anything',
       allies = 'Any evil or selfish beings willing to accept it as lord and master and serve without question, including Brodkil and other sub-demons, lesser demons and all manner of monsters and evildoers; adults seek lesser beings to worship them as gods, humans and D-Bees among them, though misanthropes and violent monster races such as Psi-Goblins, orcs, ogres and sub-demons like Brodkil and Gargoyles are drawn to them more',
       enemies = 'Dragons above all others, even hatchlings, and many kill them on sight; also Darkhounds, Pogtal Dragon Slayers, Psi-Hounds, Temporal Raiders, True Atlanteans (especially Undead Slayers and the Sunaj), Lyn-Srial, Cyber-Knights and most heroes and champions of light. The Splugorth and their minions are not fond of them either, and creatures of light, angels and spirits are wary of them and of anyone with them',
       occ_note = 'R.C.C. with its own skills; Available O.C.C.s: none, a Dragonmage by nature. Best reserved as an NPC or villain: only the Young-Dragonmage is available as a player character, if the G.M. allows it, starting at first or second level. Starts with basic adventuring gear, may or may not wear body armor, one weapon for each W.P. and no magic items, and 1D6x1000 credits and an equal amount in tradeable valuables. Experience level: young 1D4+4 for NPCs; a mature Demon-Dragonmage NPC villain 2D6+15, or as the G.M. sets up to 30th level. Uses the dragon experience table. Slave market value: young 2D6x10,000 credits, adult 4D6 million.',
       description = 'May be demons from some other dimension, who start life as mortal mega-damage beings: the young look like ordinary D-Bees but for white-skinned, hairless bodies, a thick bony skull and a pair of tiny spines on the sides of the chin, and wander the Megaverse for centuries gathering magic and psionic power. To mature, one must slay an experienced dragon and magically join its head to its own chest, becoming a Demon-Dragonmage with massive dragon-like wings, ashen white, creamy red or warm gray skin and flame from its eye sockets and mouth, which makes dragons their mortal enemies; with age most turn toward evil. Rifts World Book 12: Psyscape printed 120-123, which this row followed until ~227, gave: probably a demon, with large white or pale-gray wings and flaming eyes and tongue; Young usually Anarchist (40%) or evil (40%), and adults predominantly evil, with 15% Anarchist, about 15% Aberrant and only 6% good; a player character a difficult option, not advised, at G.M. discretion; a mature NPC level of 15-25, sometimes higher; P.S. with no strength class; a life span of immortal unless slain; +2 to roll with impact or fall at 2nd level and a teleport of 300 lbs (122 kg); no ability past 10th level, no Perception bonus and no holy-weapon vulnerability; Hand to Hand that cannot be changed or upgraded; related skills with the first three category names scrambled on the page and one more at levels 4, 8 and 12 only; secondary skills from the related list, limited as it is, at levels 1, 3, 5, 8, 11 and 15; more magic learned as the Line Walker does, with Temporal Magic something it can also learn from 10th level; allies among other supernatural beings, psychics and practitioners of magic, Goblins among the worshippers and adults conquering entire worlds; enemies of dragons, Temporal Raiders, True Atlanteans and the Splugorth, with no Darkhounds named; two weapons for its W.P.s and 1D6x1000 credits only.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.58-61'
 WHERE slug = 'demon-dragonmage'
   AND source_book = 'Rifts World Book 12: Psyscape p.120-123';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Demon-Dragonmage cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'demon-dragonmage'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.58-61';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'demon-dragonmage'
   AND instr(alignment, 'Unprincipled (20%)') > 0
   AND instr(bonuses_note, '+2 on Perception Rolls at 12th') > 0
   AND instr(natural_abilities, '(30th)') > 0
   AND instr(life_span, '2100 years') > 0
   AND instr(occ_note, '2D6+15') > 0
   AND instr(enemies, 'Pogtal Dragon Slayers') > 0
   AND instr(habitat, 'Tolkeen') > 0;

SELECT 'the body, attributes, psionics and Horror Factor are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'demon-dragonmage'
   AND hp IS NULL
   AND sdc IS NULL
   AND combat IS NULL
   AND mdc = 'PEx10'
   AND ppe = 'PE+1D4x100'
   AND isp = 'ME+2D4x10'
   AND horror_factor = 10
   AND instr(psionics, 'Master psychic: Pyrokinesis') = 1
   AND attributes = '{"IQ":"2D6+8","ME":"2D6+10","MA":"2D6+12","PS":"2D6+16","PP":"2D6+10","PE":"2D6+10","PB":"2D6+3","Spd":"2D6+16"}';

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'demon-dragonmage'
   AND instr(description, 'which this row followed until ~227') > 0;

SELECT 'and its two stat_attacks rows are untouched' AS assertion, count(*) AS got, 2 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'demon-dragonmage'
   AND damage = '6D6 MD' AND name IN ('Fire breath', 'Fire ball');

INSERT INTO data_script_runs (filename) VALUES ('~227-book-ingest-audit-f143-psy-dragonmage.sql');
