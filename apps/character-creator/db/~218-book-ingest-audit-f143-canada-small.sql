-- Five Canada races' creature rows follow D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Canada part 1 of 4).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~218-book-ingest-audit-f143-canada-small.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~218-book-ingest-audit-f143-canada-small.sql
--
-- The classes aardan-tek, grackle-tooth, greot-hunter, mastadonoid and
-- noli-bushman follow Rifts World Book 30: D-Bees of North America (2007),
-- but their creatures rows still cited Rifts World Book 20: Canada and
-- carried its figures. By Nate's ruling of 2026-10-04 the newest printing
-- that STATES a figure wins, so each row is UPDATED in place and moves its
-- source_book; where D-Bees is silent, Canada's figure stays. A complete
-- line D-Bees restates without an item drops that item. creatures has no
-- notes column, so each Canada figure that changed is kept in description
-- with its printed page. Attribute dice, pools, combat bonus keys and the
-- stat_attacks rows are the same in both books except where named below, so
-- stat_attacks is untouched and each row keeps its shape (F141).
--
-- Read off renders of both books (both at PDF offset +1). Guarded on each
-- row still citing Canada, so a re-run is a no-op. THIS SCRIPT CHANGES
-- PRODUCTION: five creatures rows. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but typically Scrupulous (20%), Unprincipled (25%) and Anarchist (20%); dark magic and dealings with the supernatural may change that',
       horror_factor = 10,
       pools_note = 'Hit Points are 5D6 plus the P.E. number, plus 1D6 per level of experience from level one. P.P.E. is 5D6 or as the magic O.C.C. gives. An S.D.C. being: M.D.C. comes only from magic or M.D.C. body armor. I.S.P. is not printed.',
       bonuses_note = '+2 on Perception Rolls (+4 when scents are involved), +2 to save vs Horror Factor. All R.C.C. bonuses are in addition to attribute and skill bonuses. Attacks per melee are those of the Hand to Hand skill, never fewer than two. Takes only half the usual strike, parry and dodge penalties when blinded or in total darkness, provided there is a scent to work from. Vulnerabilities: double the penalties from noxious fumes and stench attacks; -10% on all swimming skills; an alien look that makes them a target of D-Bee haters and slavers; and inexperience, curiosity and overconfidence that get them into trouble.',
       natural_abilities = 'Keen eyes with a 200 degree field of view, good speed and dexterity. Leaps six feet (1.8 m) up and eight feet (2.4 m) across, half again as far with a run-up. Wide, finger-like feet give excellent balance: +5% to Acrobatics and Gymnastics, and +5% to Climb and Prowl. The short trunk is prehensile, swivels any way, and smells as well as a dog: it picks out familiar odors, gases, food, animals and the route a group took, and with a reference sample or prior familiarity it singles out one person, or a drug or poison in food. Tracking by nose is rolled every 1000 feet (305 m), or every 500 on a faint trail or one under light rain or snow; a miss loses the trail for the moment, two hits in three tries recover it, two misses lose it for good, and no trail older than 24 hours can be followed.',
       magic = 'By O.C.C.; 55% of the race practice some form of magic, and 75% of those who come to Rifts Earth are magic practitioners or are seeking a new kind of magic',
       psionics = 'Same range of possibilities as a human',
       life_span = '4D6+78 years; physically mature by age 17',
       habitat = 'Anywhere in North America, thickest in Ontario, Michigan and the Ohio Valley/Magic Zone; individuals and small parties explore the continent (and to a lesser degree the world) and study magical and dimensional sites such as the Calgary Rift and the Wyoming Medicine Wheel. They avoid Atlantis for fear the Splugorth would make them a slave race. A number live and study at Lazlo, New Lazlo and the Federation of Magic, and many more visit. A few dozen joined the defense of Tolkeen and most died there, which put the race at the top of the Coalition''s list of most dangerous inhumans',
       allies = 'None formally; drawn to artists, musicians, philosophers, scholars, scientists, other mages, dragons and Faerie Folk',
       occ_note = 'Optional player character. Any O.C.C., though most become practitioners of magic (any) or Adventurers, the Body Fixer, Rogue Scientist, Rogue Scholar and Vagabond (as explorer) above all. They typically avoid invasive physical augmentation. Uses the chosen O.C.C.''s experience table; NPCs are level 2D4 or as the G.M. sets, and player characters start at level one. Gear is per O.C.C.: they love magic items and magic weapons, but a player character starts with none.',
       description = 'The Long Nose D-Bees: scholarly aliens with a stubby trunk above the mouth, from a world where magic and technology live side by side. They came to Rifts Earth on purpose, as a first venture into dimensional travel, to study it. Canada printed 130-132, which this row followed until ~218, called them the Long Nose Aliens and gave alignment as Any with no percentages, no Horror Factor, a life span of 80-100 years, "1D6 M.D." per level on the Hit Points line and no Perception bonus or foot bonuses; made every one a Minor Psychic (Mystics alone with more); said they shun Witchcraft and Necromancy and favor Temporal Magic and Techno-Wizardry, split its mages 20% Mystics, 20% Ley Line Walkers and 15% other kinds, named Operator, Scholar and Scientist as the likeliest other O.C.C.s and barred Juicers, Crazies and full conversion cyborgs; and started them with custom light (30 M.D.C.) or medium (50 M.D.C.) body armor, two modern weapons with four spare E-clips each and basic gear.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.9-11'
 WHERE slug = 'aardan-tek'
   AND source_book = 'Rifts World Book 20: Canada p.130-132';

UPDATE creatures
   SET alignment = 'Any, but lean toward Principled (20%), Scrupulous (30%), Unprincipled (10%), Anarchist (25%) or Aberrant (10%)',
       horror_factor = 12,
       bonuses_note = '+1 attack per melee round, +2 on Perception Rolls, +5 to save vs Horror Factor, +2 vs poison and toxins, +6 vs disease, +1 vs psionic attack, mind-control drugs and magical illusions. The parry bonus covers the tail. All in addition to attribute and skill bonuses. Attacks per melee are those of the Hand to Hand skill plus one for the tail (never fewer than three without combat training), plus the R.C.C.''s one. -3 to strike when the tail fires a handgun, aimed shots included. Vulnerabilities: below 35 degrees Fahrenheit skills are -5% and combat bonuses -1, and their size and warrior reputation make them prime targets.',
       life_span = '2D4x10+120 years; physically mature by age 17',
       habitat = 'Likes warm, dry country. Rare: fewer than 4,000 on Earth in 102 P.A., since grown to 6,200; half live in Lone Star and most others in the New West. An estimated 423 died fighting for Tolkeen',
       allies = 'Humans, Psi-Stalkers, Dog Boys, Larmac, Tirrvol Sword Fist, Quick-Flex Aliens, Cyber-Knights, Reid''s Rangers, and most warrior types. Many live in the Pecos Empire and ride with the Pecos Raiders or other bandit groups',
       enemies = 'None in particular beyond whoever wants a fight, and bullies who pick on folk who cannot defend themselves. Distrusts Coalition humans after clashes with CS troops and their hired guns, and feels the same about Free Quebec and the Federation of Magic; dislikes the CS even more since Tolkeen fell, for its persecution of refugees and D-Bees. Hates vampires and other demons who prey on the innocent',
       occ_note = 'Optional player character. Any Men at Arms O.C.C. except Combat Cyborg, Crazy and Juicer, leaning toward Military/Grunt/Soldier, Merc Soldier, Wilderness Scout, Vagabond, Operator, Bounty Hunter, Bandit, Cowboy, and any New West Men at Arms O.C.C. other than Psi-Slinger, Wired Gunslinger and CyberSlinger Cyborg. Bionics are usually avoided; M.O.M. and Juicer conversion do not work on them. Uses the chosen O.C.C.''s experience table; NPCs are level 2D4 or as the G.M. sets, and player characters start at level one. Gear is the O.C.C.''s plus one extra heavy weapon; with no I.S.P. and little P.P.E. they cannot power Techno-Wizard weapons. Few wear armor.',
       description = 'The Mighty Grackle Tooth or Deadly Grackle: a huge, barrel-chested Mega-Damage D-Bee with a long dragon-like head, bony fins along neck, spine, shoulders and elbows, and a snaggle-toothed grin. Most are cheerful, courteous and well liked, and nearly all love a brawl, big guns and adventure. Canada printed 133-134, which this row followed until ~218, gave alignment as "Any, but lean toward good, Anarchist or Aberrant", no Horror Factor, a life span of 200-300 years, no extra attack, Perception bonus or cold penalty; named Military/Soldier O.C.C.s, Wilderness Scout, Vagabond, Operator, Bounty Hunter, Cowboy and New West Men at Arms rather than any Men at Arms O.C.C.; counted under 4,000 on Earth, a few hundred of them drawn to Minnesota (Tolkeen) and to Ontario and Quebec by the coming wars; and did not name Larmac, Cyber-Knights or Reid''s Rangers among their allies.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.97-98'
 WHERE slug = 'grackle-tooth'
   AND source_book = 'Rifts World Book 20: Canada p.133-134';

UPDATE creatures
   SET horror_factor = 10,
       bonuses_note = '+1 attack per melee, +6 to save vs Horror Factor, +3 vs poison and toxins, +5 vs disease, +1 vs magic and possession. Horror Factor rises as high as 15 for notorious underworld Greots, mercs and bounty hunters (G.M. discretion). All in addition to attribute bonuses. Attacks per melee are those of the Hand to Hand skill plus the R.C.C.''s one.',
       natural_abilities = 'Keen eyesight, great strength and good reflexes. Swims by instinct, holds its breath one minute per P.E. point, and withstands depths to 600 feet (183 m). The tail is not prehensile. Blubber under the thick lumpy hide keeps out the cold, and even M.D. cold does half damage. Impervious to UV rays, nuclear radiation and carcinogens.',
       psionics = 'Same likelihood as humans',
       life_span = 'Males 3D6+40 years, females 4D6+43; physically mature by age 13',
       habitat = 'Once thought to have come out of the Calgary Rift in the Dark Age; the Greots say a Rift long ago in the ruins of Chi-Town. Most numerous in Manitoba, Ontario and the American Midwest, the Coalition States of Iron Heart and Chi-Town included. An estimated 6,800 died in Tolkeen',
       allies = 'Only their own kind. They respect power and ally with other powerful or warlike beings, and use subservient non-Greot henchmen, all as a means to an end; they never sell their souls or submit to anyone, and may sell others into slavery',
       enemies = 'Humans generally, the CS and Free Quebec in particular, and anyone who opposes them. Hates Xiticix, Psi-Stalkers, Simvan, Vanguard Brawlers, N''mbyr Gorilla Men and Quick-Flex Aliens; respects Grackle Tooth, Mastadonoids, Blucies, Sunaj, Loaks and Vintex as dangerous rivals; distrusts mages and creatures of magic and goes for them first. Greot slavers deal with the Horune Pirates and the Minions of Splugorth',
       occ_note = 'Optional player character, though unless the group is evil a player Greot must be one struggling to break the mold and be a hero, not a brute or a thug; a few serve with the Cyber-Knights and Reid''s Rangers or protect Lazlo. Combat O.C.C.s only: Grunt/Soldier, Military Specialist, Merc Soldier, Headhunter, Cyber-Knight, Wilderness Scout, Vagabond, Bounty Hunter, Smuggler, Bandit, Pirate, or any New West Men at Arms O.C.C. M.O.M. and Juicer conversion do not work on them. Full bionic conversion is for weaklings, but partial bionics and implants are acceptable. They do not like, understand or trust magic. Uses the chosen O.C.C.''s experience table; NPCs are level 1D8 or as the G.M. sets, and player characters start at level one. Gear and money are per O.C.C., but they covet wealth and try to amass a fortune or build a criminal empire. The Black Market recruits them heavily, and many hold power in the Iron Heart and Chi-Town ''Burbs and at Old Bones.',
       description = 'A hulking reptilian or amphibian-looking brute, a born hunter and warrior that ruled its own world and resents sharing this one. Greot are short-tempered, merciless bullies who relish a fight. Canada printed 135, which this row followed until ~218, gave no Horror Factor and a life span of 50 years (some to 70) for both sexes; printed no breath-holding, M.D. cold resistance or UV and radiation immunity, and no losses at Tolkeen; named no Merc Soldier, Cyber-Knight, Smuggler or Pirate among the O.C.C.s, and said bionics leave them weaker, so most go only as far as partial augmentation such as weapon systems; and named no Blucies, Sunaj, Loaks or Vintex among their rivals.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.98-100'
 WHERE slug = 'greot-hunter'
   AND source_book = 'Rifts World Book 20: Canada p.135';

UPDATE creatures
   SET alignment = 'Any, but tend to be Principled (25%), Scrupulous (30%), Unprincipled (20%) and Anarchist (10%)',
       attributes = '{"IQ":"1D6+6","ME":"2D6+6","MA":"2D6+3","PS":"3D6+26","PP":"2D6+6","PE":"2D6+6","PB":"1D6+1","Spd":"2D6+6"}',
       bonuses_note = '+1 to save vs magic, +5 vs Horror Factor, +3 vs poison and toxins, +5 vs disease, +4 vs mind control other than demonic possession (to which it is immune). All in addition to attribute bonuses. Attacks per melee are those of the Hand to Hand skill. Vulnerabilities: above 80 degrees Fahrenheit its Spd drops 30%, it loses one attack per melee and it tires as fast as a human (twice as fast at 90 or more); in a town or city its combat bonuses are halved and its skills are -15%.',
       skills_note = 'R.C.C. skills on top of the O.C.C.''s: Hand to Hand: Basic (may be upgraded through the O.C.C.), Land Navigation (+20%), Skin and Prepare Animal Hides (+10%), Track and Trap Animals (+20%) and Wilderness Survival (+20%).',
       magic = 'Non-mages cast See the Invisible (4), Sense Evil (2), Sense Magic (4), Armor of Ithan (10), Throwing Stones (5) and Frost Blade (15), P.P.E. costs in brackets; at levels 2, 5, 9 and 12 they add one spell of choice from spell levels 1-3',
       psionics = 'None, except among Mystics and Shamans',
       life_span = 'Males 4D6+50 years, females 6D6+65; physically mature by age 15',
       allies = 'Most count the Inuit and other traditional Native Americans as spiritual brothers; a natural affinity with Sasquatch, Dog Boys and Psi-Stalkers; liked by most Faerie Folk, who annoy them. Most civilized humans and D-Bees are viewed with suspicion',
       enemies = 'Evil supernatural beings, the Windigo most of all; Xiticix; Greot, Loup Garou and other cruel, violent races. Wary of Cyborgs, Crazies, Juicers, power armor pilots and most technology, the Cyber-Centaurs of Western Canada included. Know little of the CS, Free Quebec or the Federation of Magic beyond disliking them, and avoid the kingdom of demons and monsters building in Calgary',
       occ_note = 'Optional player character. Limited to Elemental Fusionist, Mystic, Wilderness Scout, Vagabond, Bounty Hunter, Bandit (rare), Inuit Shaman, and Animal Shaman, Healing Shaman, Tribal Warrior and Mystic Warrior (those four are in Rifts Spirit West). No M.O.M. or Juicer conversion, and bionics are avoided. Most live off the land as hunters and steer clear of modern weapons and machines, though they like Vibro-Blades and some use oversized modern weapons they come across. Uses the chosen O.C.C.''s experience table; NPCs are level 1D6+1 or as the G.M. sets, and player characters start at level one. Gear is per O.C.C.',
       description = 'The Bear Claw People of the Inuit, also called Elephant Men: shaggy tundra giants with an elephant-like head, small tusks, sword-length black claws, and a trunk that is really the mouth. Mighty hunters but neither cruel nor murderous, and still partial to raw meat. Canada printed 137, which this row followed until ~218, gave alignment as Any with no percentages, M.A. 2D6, a life span of 80-110 years, no R.C.C. skills, no heat or city vulnerabilities, no psionics even for Mystics and Shamans, and no spell costs; let one attack be by spell with two physical; printed no Allies line; and named no Elemental Fusionist among the O.C.C.s.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.134-135'
 WHERE slug = 'mastadonoid'
   AND source_book = 'Rifts World Book 20: Canada p.137';

UPDATE creatures
   SET alignment = 'Any, but lean toward Principled (30%), Scrupulous (30%) and Unprincipled (10%)',
       isp = 'MEx2',
       pools_note = 'Hit Points are 2D6 plus the P.E. number, plus 1D6 per level of experience from level one (the book prints that per-level gain as ''1D6 M.D.'' on the Hit Points line). S.D.C. is 1D4x10 plus whatever physical skills add. An S.D.C. being: M.D.C. comes only from body armor or other external protection. I.S.P. is the M.E. number x2, +1D6+1 per level of experience; a Psi-Druid or Psi-Slayer uses that O.C.C.''s I.S.P. instead.',
       skills_note = 'R.C.C. skills on top of the O.C.C.''s: Climbing (+20%), Dowsing (+15%), Prowl (+10%) and Swimming (+10%).',
       magic = 'None',
       psionics = 'All are Master Psychics, with Bio-Regeneration (self, 6), Empathy (4), Mind Block (printed as 40), Psionic Invisibility (10) and Telepathy (4), plus two Physical and two Sensitive powers of choice, one more from either category at each further level, and one Super Psionic power of choice at levels 4, 8 and 12, never Psi-Sword (that is for Noli Cyber-Knights only). A Psi-Druid or Psi-Slayer ignores this and uses that O.C.C.''s psionics, I.S.P., skills and abilities',
       life_span = '5D6+60 years, and females live 2D6 years longer; physically mature by age 17',
       habitat = 'Mostly Ontario, Free Quebec and the forests of eastern Canada; small numbers in Manitoba, Michigan, Wisconsin, Minnesota, Illinois, New York, Vermont, New Hampshire, Massachusetts and Maine, and now and then anywhere',
       allies = 'Nothing formal. Most get along with Native Americans, the Inuit, Mastadonoids, Psi-Stalkers, Simvan and rogue Dog Boys, and with humans and D-Bees tolerant of other races. Nearly 1,000 live in Lazlo and 400 at New Lazlo; a thousand died in the Coalition-Tolkeen War',
       enemies = 'The CS and the Free Quebec military, enemies number one and two, who have done them great harm; also Xiticix, Greot, Yeno, Loup Garou, vampires, Horune, the Minions of Splugorth and any slavers. Wary of other strong psychics, Mind Melters and Mind Bleeders especially, and they stay away from Psyscape',
       occ_note = 'Optional player character. Limited to Psi-Druid and Psi-Slayer (their only psychic O.C.C.s), Cowboy, Wilderness Scout (any) or Vagabond, leaning toward animals, farming and nature; for the latter two, O.C.C. Related and Secondary skill picks are cut to three each. A Noli may also be a Cyber-Knight (only two are known): Psi-Sword at level one plus six Sensitive and/or Physical powers on top of the usual Knight powers. No M.O.M. or Juicer conversion; cybernetics and bionics only for medical purposes. Uses the chosen O.C.C.''s experience table; NPCs are level 1D8 or as the G.M. sets, and player characters start at level one. Gear and money are per O.C.C., with a preference for spears and staves. Slave market value 2D4x1,000 credits as fighters, scouts and slave labor.',
       description = 'Greenbeans, Greenies or Green Scouts: green-skinned forest humanoids with a long thin neck, a big melon-shaped head and tufts of fur like dreadlocks, who live on bark, roots and other plants. Born woodsmen and strong psychics who are still happy with armor, energy weapons, hovercycles and small towns. Canada printed 137-138, which this row followed until ~218, gave alignment as Any with no percentages, a life span of 70-90 years with a few claiming more than 120, Climb +20% and Prowl +10% as the only R.C.C. skills, and no I.S.P.; gave the psionic package only to its Noli Cowboy and Noli Scout O.C.C.s and named no Vagabond; said bionics are avoided; counted a few hundred at New Lazlo and 300 joined the crusade at Tolkeen; and printed no slave value and no Inuit, Mastadonoid, Horune, Splugorth or slaver among allies and enemies.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.144-146'
 WHERE slug = 'noli-bushman'
   AND source_book = 'Rifts World Book 20: Canada p.137-138';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'all five rows cite D-Bees and none cites Canada' AS assertion, count(*) AS got, 5 AS want
  FROM creatures
 WHERE slug IN ('aardan-tek','grackle-tooth','greot-hunter','mastadonoid','noli-bushman')
   AND source_book LIKE 'Rifts World Book 30: D-Bees of North America p.%';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 5 AS want
  FROM creatures
 WHERE (slug = 'aardan-tek' AND horror_factor = 10 AND life_span LIKE '4D6+78 years%')
    OR (slug = 'grackle-tooth' AND horror_factor = 12 AND life_span LIKE '2D4x10+120 years%')
    OR (slug = 'greot-hunter' AND horror_factor = 10 AND life_span LIKE 'Males 3D6+40%')
    OR (slug = 'mastadonoid' AND instr(attributes, '"MA":"2D6+3"') > 0 AND life_span LIKE 'Males 4D6+50%')
    OR (slug = 'noli-bushman' AND isp = 'MEx2' AND life_span LIKE '5D6+60 years%');

SELECT 'each keeps the Canada figures it replaced in its description' AS assertion, count(*) AS got, 5 AS want
  FROM creatures
 WHERE slug IN ('aardan-tek','grackle-tooth','greot-hunter','mastadonoid','noli-bushman')
   AND instr(description, 'which this row followed until ~218') > 0;

SELECT 'and the seven stat_attacks rows are untouched' AS assertion, count(*) AS got, 7 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature'
   AND owner_slug IN ('aardan-tek','grackle-tooth','greot-hunter','mastadonoid','noli-bushman');

INSERT INTO data_script_runs (filename) VALUES ('~218-book-ingest-audit-f143-canada-small.sql');
