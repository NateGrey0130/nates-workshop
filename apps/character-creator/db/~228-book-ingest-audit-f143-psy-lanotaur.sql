-- The Lanotaur Hunter's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 4 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~228-book-ingest-audit-f143-psy-lanotaur.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~228-book-ingest-audit-f143-psy-lanotaur.sql
--
-- The class lanotaur-hunter follows Rifts World Book 30: D-Bees of North
-- America (2007), printed 115-117, but its creatures row still cited Rifts
-- World Book 12: Psyscape printed 123-126 and carried its figures. By Nate's
-- ruling of 2026-10-04 the newest printing that STATES a figure wins, so the
-- row is UPDATED in place and moves its source_book; where D-Bees is silent,
-- Psyscape's figure stays. A complete line D-Bees restates without an item
-- drops that item: the Natural Abilities line's swim, climb, prowl and track
-- by sight percentages (D-Bees grants Swimming, Climbing, Prowl and Tracking
-- as R.C.C. skills instead), the Habitat line's South America, Congo, China,
-- Germany and Gargoyle Empire, the Allies line's poor relations with its own
-- kind, and the Enemies line's defence of a claimed hunting ground.
-- creatures has no notes column, so each Psyscape figure that changed is
-- kept in description with its printed page.
--
-- Body: unchanged. Both books print M.D.C. 3D6x10 plus P.E. (+2D6 per
-- level), P.P.E. P.E. x3 (+3D6 per level), I.S.P. 1D6x10+10 plus M.E. (+2D6
-- per level), Horror Factor 12, size, and the same attribute dice but one,
-- so hp, sdc, mdc, ppe, isp, horror_factor and size stay. D-Bees prints P.B.
-- 2D6+2 where Psyscape printed 2D6, and marks only P.S. and P.E. as
-- Supernatural where Psyscape called all its attributes supernatural; the
-- metric weight becomes D-Bees' 270 to 360 kg. combat keeps its eight
-- attacks, +8 initiative, +4 strike, +5 parry, +3 disarm, +5 pull and +4
-- roll, which both books print; D-Bees prints the +7 as a bonus to automatic
-- dodge where Psyscape printed +7 to dodge plus automatic dodge, so the key
-- becomes automatic_dodge, and it adds +2 to entangle. D-Bees prints an
-- R.C.C. skill list, related and secondary skills, I.S.P. costs for the
-- starting psionics, P.P.E. costs for the spells, equipment, money,
-- experience levels and slave value, none of which Psyscape printed. Both
-- books print the Lanotaur as an R.C.C., so the row's shape is the same in
-- both (F141 does not arise); category stays alien. Its five stat_attacks
-- rows (restrained, full and power punch, claws, tail slash) match D-Bees
-- and are not touched.
--
-- Read off renders of both books (both at PDF offset +1: D-Bees cache
-- p116-p118, Psyscape cache p124-p127). Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but Anarchist (30%) and Aberrant (55%) are most common',
       attributes = '{"IQ":"2D6+8","ME":"3D6+8","MA":"1D6+1","PS":"2D6+14","PP":"1D6+20","PE":"3D6+8","PB":"2D6+2","Spd":"2D6x10+18"}',
       weight = '600 to 800 lbs (270 to 360 kg)',
       pools_note = 'A mega-damage creature: M.D.C. 3D6x10 + P.E., +2D6 per level; may also wear M.D.C. body armor. P.P.E. P.E. x3, +3D6 per level. I.S.P. 1D6x10+10 + M.E., +2D6 per level. Supernatural P.S. and P.E. Heals twice as fast as a human.',
       combat = '{"attacks":8,"initiative":8,"strike":4,"parry":5,"automatic_dodge":7,"disarm":3,"entangle":2,"pull":5,"roll":4}',
       bonuses_note = 'Attacks per melee as per Hand to Hand: Martial Arts (four attacks at level one) plus four more racial attacks, with Paired Weapons, Kick and Leap Attack from first level; Combat Awareness and Lightning Reflexes are already in these bonuses. Automatic dodge against all attacks, even from behind: the dodge uses up no melee attack but is still rolled. Saves: +6 vs Horror Factor, +2 vs lethal and non-lethal poisons; a master psychic but -2 vs psionics (needs 12). Vulnerable to its own arrogance, overconfidence, thrill seeking and obvious death wish.',
       skills_note = 'Acrobatics (+5%), Climbing (+20%), Cook (+20%), Dowsing (+20%), Hand to Hand: Martial Arts, Land Navigation (+20%), Native Tongue language and literacy (alien) at 98%, Dragonese/Elven (+20%), Prowl (+20%), Skin and Prepare Animal Hides (+15%), Swimming (+10%), Tailing (+20%), Tracking (people, +15%), Track & Trap Animals (+10%), Wilderness Survival (+20%), and W.P. Knife, Sword, Paired Weapons, Energy Pistol and one W.P. of choice. Two related skills at levels 2, 4, 7, 11 and 15, from Communications, Espionage (+5%), Horsemanship (General and Exotic Animals only), Physical, Pilot (no robot or military vehicles), Rogue (no Hacking, Safe-Cracking or Seduction), Technical and Wilderness only. Two secondary skills from the Secondary Skill List of Rifts Ultimate Edition (p.300) at levels 1, 3, 8 and 12, without bonuses other than a high I.Q. bonus.',
       natural_abilities = 'Senses psychic and magic energy like a Psi-Stalker (50 ft +20 ft per level for an idle psychic or mage; 600 ft +100 ft per level for powers in use). Combat Awareness and Lightning Reflexes let it read opponents'' intentions, except against Mind Block. Mind Over Body: can mask its heat signature (IR and thermal optics fail beyond 200 ft), control its heart rate, respiration and body chemistry to cut its scent (-20% to recognize or track by scent), fool a lie detector every time (interrogators -20%) and simulate a coma or death trance. Superhuman speed and reflexes, nightvision 100 ft, ambidextrous, heals twice as fast as humans. Takes no cybernetics or bionics, which it considers a sign of weakness.',
       magic = 'Limited, each spell passed on from parent to young: Anti-Magic Cloud (140), Astral Hole (120), Chameleon (6) or Shadow Meld (10), Close Rift (200+), Dimensional Portal (1000), Enchant Weapon (400+), Invisibility: Superior (20), Lifeblast (15), Lightblade (20), Magic Shield (6), Mystic Portal, Restore Life (275), Sanctum, Swap Places (300), Time Hole (210) and Warp Space (90); above 5th level, 1D4+2 more spells from levels 7-11.',
       psionics = 'Master psychic: Mind Block Auto-Defense (special), Presence Sense (4), Sixth Sense (2), Death Trance (1), Telepathy (4), Read Dimensional Portal (6), Deaden Senses (4) and Alter Aura (2); 1D4 Physical at 2nd, 1D4 Sensitive at 3rd, Psi-Sword and one Super at 4th, Bio-Regeneration (super) and one Super at 5th, then one Sensitive or Physical per level.',
       life_span = '4D6+80 years, physically mature at 16. Females bear one or two young after an eight month pregnancy, and can bear young until age 45',
       habitat = 'Forests of any kind, especially those with giant trees, but also mountains and cities with tall buildings; spotted in the forests of North America, Central and South America, Africa and Southeast Asia. In North America, Calgary and other parts of Canada, Tolkeen, the Magic Zone, the Detroit-Windsor region and the Deep South are excellent hunting grounds',
       allies = 'None per se: the only beings it considers its equals are its own kind. Feels a kinship for Psi-Stalkers, Darkhounds and Dog Boys and likes them, may come to respect individual people, and may join a group of adventurers who promise excitement and challenges',
       enemies = 'No declared enemies; sees Rifts Earth as a giant hunting preserve and most everyone in it as potential prey, acknowledges no people, nations or laws and never allies with Earth forces. The Splugorth dislike it but cater to it with game, arena battles and safaris; True Atlanteans, the Sunaj, Chiang-Ku dragons, Temporal Raiders and other dimensional travelers know it, and none respect it. Finds undead boring (Mexico offers little, though a kingdom of vampires appeals) and the Xiticix too mundane, and avoids slaying too many Splugorth minions, though they are targeted from time to time',
       occ_note = 'R.C.C. with its own skills, an optional player character and NPC; Available O.C.C.s: none, but makes a living as a bounty hunter, demon hunter, dragon slayer or hunter-killer. Player characters start at first level; NPC experience level 2D6, or as the G.M. sets. Uses its own Lanotaur experience table (15 levels; 2nd at 2,151). Relies on claws, tail, magic and psionics; may use simple melee weapons, magical constructs and the occasional tech-weapon, and collects magic weapons for their value but tends not to use them unless it is fair. Starts with a belt of pouches and a holster, bandoleer, backpack or satchel, canteen, language translator, handheld computer, digital camera, 1D4 pairs of handcuffs, binoculars and passive nightsight binoculars, 100 ft of nylon cord, 1D6+4 wooden stakes, a wooden cross, two Vibro-Knives (1D6 M.D.), may wear light, medium or partial M.D.C. body armor (4D6+30) and favors a helmet with a monstrous face plate (2D6+40 M.D.C.), and 1D4x10,000 credits. Slave market value: rarely offered, 2D4x100,000 credits as an assassin, warrior or gladiator.',
       description = 'Hulking flesh-and-blood D-Bees, long believed supernatural, who stalk the forests of North America and hunt fellow humanoids for sport, something like a Psi-Stalker crossed with a Juicer. They prize great warriors, psychics, mages, dangerous D-Bees, demons and dragons as prey, are thrill-seeking narcissists for whom defeat without death brings deep depression or a violent rage, never kill or torture the helpless, and sometimes spare a foe they come to respect. They study their prey before striking, and hunt alone, in groups of 2-4 Lanotaur, or with 3-8 kindred non-Lanotaur man-hunters. Cool, calm, arrogant, bold, impetuous and deadly. Rifts World Book 12: Psyscape printed 123-126, which this row followed until ~228, gave: supernatural D-bees who use no weapons but claws, tail and psionics and especially stalk psychics and practitioners of magic; anarchist or evil most common, with 55% Aberrant; P.B. 2D6 and all attributes supernatural; a weight of 272 to 363 kg; a life span of 80-120 Earth years; swim 60%, climb 80%/70%, prowl 50% +2% per level and track by sight 44% +4% per level as natural abilities, with no R.C.C. skill list; +7 to dodge plus automatic dodge, and no entangle bonus; no I.S.P. costs for its psionics and no P.P.E. costs for its spells; an NPC villain with no player note, money, equipment list or experience table; a habitat of mixed forest to rain forest, with parts of South America, the African Congo and China among its favorite hunting grounds and Germany and the Gargoyle Empire of little appeal; no allies, getting along poorly even with its own kind; and no declared enemies, taking no more than it needs and defending a claimed hunting ground against farmers, loggers and developers.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.115-117'
 WHERE slug = 'lanotaur-hunter'
   AND source_book = 'Rifts World Book 12: Psyscape p.123-126';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Lanotaur Hunter cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'lanotaur-hunter'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.115-117';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'lanotaur-hunter'
   AND instr(alignment, 'Anarchist (30%)') > 0
   AND instr(attributes, '"PB":"2D6+2"') > 0
   AND instr(weight, '270 to 360 kg') > 0
   AND instr(skills_note, 'Dowsing (+20%)') > 0
   AND instr(psionics, 'Read Dimensional Portal (6)') > 0
   AND instr(magic, 'Dimensional Portal (1000)') > 0
   AND instr(life_span, '4D6+80') = 1
   AND instr(habitat, 'Detroit-Windsor') > 0
   AND instr(occ_note, '1D4x10,000 credits') > 0
   AND instr(enemies, 'Xiticix') > 0;

SELECT 'combat takes automatic dodge and entangle, and keeps the rest' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'lanotaur-hunter'
   AND combat = '{"attacks":8,"initiative":8,"strike":4,"parry":5,"automatic_dodge":7,"disarm":3,"entangle":2,"pull":5,"roll":4}';

SELECT 'the body, Horror Factor and size are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'lanotaur-hunter'
   AND hp IS NULL
   AND sdc IS NULL
   AND mdc = 'PE+3D6x10'
   AND ppe = 'PEx3'
   AND isp = 'ME+1D6x10+10'
   AND horror_factor = 12
   AND category = 'alien'
   AND size = '8 to 9 ft (2.4 to 2.7 m) tall';

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'lanotaur-hunter'
   AND instr(description, 'which this row followed until ~228') > 0;

SELECT 'and its five stat_attacks rows are untouched' AS assertion, count(*) AS got, 5 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'lanotaur-hunter'
   AND name IN ('Restrained punch', 'Full strength punch', 'Power punch', 'Claws', 'Tail slash');

INSERT INTO data_script_runs (filename) VALUES ('~228-book-ingest-audit-f143-psy-lanotaur.sql');
