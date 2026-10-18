-- The Zenith Moon Warper's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 7 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~231-book-ingest-audit-f143-psy-zenith.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~231-book-ingest-audit-f143-psy-zenith.sql
--
-- The class zenith-moon-warper follows Rifts World Book 30: D-Bees of North
-- America (2007), printed 221-223, but its creatures row still cited Rifts
-- World Book 12: Psyscape printed 138-140 and carried its figures. By Nate's
-- ruling of 2026-10-04 the newest printing that STATES a figure wins, so the
-- row is UPDATED in place and moves its source_book; where D-Bees is silent,
-- Psyscape's figure stays. A complete line D-Bees restates without an item
-- drops that item: its R.C.C. Skills list restates the language line as
-- "Native Tongue" with no percentage, so Psyscape's 98% goes; its magic line
-- restates the four spells without Psyscape's "(objects)" after Teleport:
-- Lesser; and its Rivals and Enemies line restates Psyscape's Enemies line
-- without Free Quebec's extermination list. creatures has no notes column,
-- so each Psyscape figure that changed is kept in description with its page.
--
-- Body: P.S. and P.E. supernatural, M.D.C. (P.E. +6D6+12, +1D6 per level),
-- Hit Points (P.E. +5D6, +1D6 per level), S.D.C. 6D6, I.S.P. (1D4x10 + M.E.
-- x3, +1D6+1 per level), P.P.E. (2D4x10 + P.E. x2, +1D6+1 per level), size,
-- weight, Horror Factor 10 and seven of the eight attribute dice are the same
-- in both books. M.A. becomes 1D6+20 (Psyscape 1D6+2). D-Bees adds a Natural
-- A.R. of 10 in S.D.C. environments, stored in ar as xiticix-grub stores its
-- own, and noted in pools_note. The alignment split, the life span (5D6+70
-- years, maturity at 13, birth figures), facial and skin-tone shapechanging,
-- Appraise Goods, the related skill levels (3, 5, 8, 10 and 12), the Rifts
-- Ultimate Edition secondary skill schedule, the spell and power costs, the
-- Lanotaur experience table, the habitat's states and Iron Heart, the allies
-- and enemies lines, the equipment and money (which the row had not carried;
-- D-Bees' equipment restates Psyscape's without its Vehicle line, so that
-- goes) and a slave value all come from D-Bees. D-Bees prints no
-- save vs psionics, so Psyscape's "12 or higher" stays in bonuses_note.
-- combat stays NULL: neither book prints an unconditional racial combat
-- bonus. Both books print the Zenith Moon Warper as an R.C.C., so the row's
-- shape is the same in both (F141 does not arise); category stays humanoid.
-- The row has no stat_attacks.
--
-- Read off renders of both books (both at PDF offset +1: D-Bees cache
-- p222-p224, Psyscape cache p139-p141). Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, although most lean toward Unprincipled (10%), Anarchist (40%), Aberrant (20%) and Miscreant (10%)',
       attributes = '{"IQ":"1D6+10","ME":"1D6+12","MA":"1D6+20","PS":"2D6+12","PP":"2D6+12","PE":"2D6+12","PB":"3D6+8","Spd":"6D6+20"}',
       ar = 10,
       pools_note = 'On Rifts Earth a mega-damage being with supernatural P.S. and P.E.: M.D.C. P.E. +6D6+12, +1D6 per level. Hit Points (P.E. +5D6, +1D6 per level), S.D.C. 6D6 plus those from skills, and a Natural A.R. of 10 apply in S.D.C. environments. I.S.P. and P.P.E. each +1D6+1 per level. When the moon is full or nearly full (about six days a month) P.S., M.D.C. and I.S.P. rise by 20%. Bio-regenerates 3D6 M.D.C. an hour.',
       skills_note = 'Appraise Goods (+15%); Native Tongue: Gobblely (no percentage printed); one other language of choice, typically American (+20%); Escape Artist and Pick Pockets (+15% each); Palming, Concealment, Cardsharp, Streetwise and Intelligence (+10% each); Seduction (+20%); Land Navigation (printed as 10%); Wilderness Survival (+5%); W.P. one Ancient, one Energy Weapon and one of choice; Hand to Hand: Expert (cannot be changed). Six related skills plus two at levels 3, 5, 8, 10 and 12; three secondary skills from the Rifts Ultimate Edition Secondary Skills List (page 300) at level 1, plus one at levels 3, 6, 8, 10 and 14.',
       natural_abilities = 'Shape changes into a fully human form at will, and can take on different facial appearances and skin tones, but is forced back to its natural canine-headed form for 1D4 hours when the moon reaches its zenith; ambidextrous and double-jointed; nightvision 1000 ft (305 m); swim 60%, climb 80%/70%; leaps 10 ft (3 m) up or forward, half again as far after a run-up; bio-regenerates 3D6 M.D.C. an hour.',
       magic = 'Innate: Swap Places (300), Teleport: Lesser (15), Escape (8) and Tongues (12), each at half the spell''s normal P.P.E. (the printed figure in parentheses).',
       psionics = 'Major psychic: Psychic Invisibility (10), Deaden Pain (4), Induce Sleep (4) and Empathy (4), plus two powers of choice from Healing, Physical or Sensitive.',
       life_span = '5D6+70 years (once believed to be 600+); fully mature by 13. Females bear one child after a 9 month pregnancy and can bear children until age 50; children are usually raised by both parents',
       habitat = 'Anywhere, but primarily the Magic Zone and the northeastern half of North America, particularly eastern Canada, Maine, Vermont, Pennsylvania and Michigan; a constant problem in the ''Burbs of Iron Heart and Free Quebec',
       allies = 'None per se: self-reliant and out for themselves, they trust only people they know very well, not even other Zenith Moon Warpers, and certainly not other shape-changers, thieves or cutthroats. They hate slavers, tyrants and those who curtail the freedom of others, which can make for strange allies and sudden changes of heart',
       enemies = 'Bullies, tyrants and beings who mistreat, enslave and torture others to prove their power; other shape-changers, thieves and assassins are rivals; they dislike soldiers, lawmen and authority figures on principle, distrust practitioners and creatures of magic, and hate Loup Garou, Witch Wolves, the Minions of Splugorth and demons',
       occ_note = 'R.C.C. with its own skills, related and secondary skills. Available O.C.C.s: none, though it may find work as a thief, con artist, pickpocket, bounty hunter, spy or assassin. NPC experience level 1D4+3, or as the G.M. sets; a player character begins at level one and uses the Lanotaur experience table (D-Bees printed 117). Starts with personalized light M.D.C. body armor, a black jump suit, camouflage clothing, personal clothing and jewelry, IR distancing binoculars, a language translator, 300 ft (91.5 m) of durable rope, climbing and rappelling gear, 1D4+1 sets of fake identification, a knapsack, a backpack, 1D4 large sacks, 1D4 small or medium sacks, a canteen and personal items, plus one weapon for each W.P. with 1D4+1 ammo clips each, a survival knife, a Vibro-Knife (1D6 M.D.) and two smoke grenades; loves magic and TW weapons but starts with none. 2D6x1000 credits plus Black Market items worth 1D6x1000 credits. Avoids cybernetics and bionics; bionic prosthetics and organs only if absolutely necessary, Bio-Systems preferred. Slave market value: 2D6x10,000 credits.',
       description = 'Sleek, attractive canine-headed humanoids often mistaken for Werewolves, Dog Boys or Witch Wolves, also called Z-Warpers, Zenith Wolves or the Midnight People. They can pass as human, with any face or skin tone, except when the moon at its zenith forces their true shape, and they grow stronger around the full moon, which has some wondering whether they are lesser supernatural beings or creatures of magic; it may be only that ley line energy rises with the full moon. Fiercely independent, selfish and seductive, they are natural con artists, smugglers, thieves, spies and assassins who move on whenever something better beckons, yet are wholly faithful to a true love or a true friend. Many people, the Coalition States included, fear and hate shape-changers and kill them on sight. They avoid cybernetics entirely. Rifts World Book 12: Psyscape printed 138-140, which this row followed until ~231, gave: M.A. 1D6+2; alignments leaning anarchist (40%) and evil (30%); a life span of 600+ Earth years, with no maturity or birth figures; no Natural A.R.; no change of face or skin tone; Gobbleley and Native Tongue spoken at 98%, and no Appraise Goods; two related skills at levels 3, 5, 8 and 11; four secondary skills from its own related list; Teleport: Lesser (objects), and no spell or power costs; a habitat naming neither Maine, Vermont, Pennsylvania and Michigan nor Iron Heart; other sneaky, like-minded individuals as allies, varying with alignment; for enemies, nothing official, but trouble with the law and a place on Free Quebec''s list of dangerous D-bees marked for extermination; no damage for the Vibro-Knife, and a vehicle line (none to start, but prefers hover cycles and horses); and no slave value or experience table.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.221-223'
 WHERE slug = 'zenith-moon-warper'
   AND source_book = 'Rifts World Book 12: Psyscape p.138-140';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Zenith Moon Warper cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'zenith-moon-warper'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.221-223';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'zenith-moon-warper'
   AND instr(attributes, '"MA":"1D6+20"') > 0
   AND ar = 10
   AND instr(alignment, 'Aberrant (20%)') > 0
   AND instr(life_span, '5D6+70') = 1
   AND instr(pools_note, 'Natural A.R. of 10') > 0
   AND instr(skills_note, 'Appraise Goods (+15%)') = 1
   AND instr(skills_note, '98%') = 0
   AND instr(skills_note, 'levels 3, 5, 8, 10 and 12') > 0
   AND instr(skills_note, 'levels 3, 6, 8, 10 and 14') > 0
   AND instr(natural_abilities, 'skin tones') > 0
   AND instr(magic, '(objects)') = 0
   AND instr(magic, 'Swap Places (300)') > 0
   AND instr(psionics, 'Psychic Invisibility (10)') > 0
   AND instr(habitat, 'Iron Heart') > 0
   AND instr(allies, 'None per se') = 1
   AND instr(enemies, 'Loup Garou') > 0
   AND instr(enemies, 'Free Quebec') = 0
   AND instr(occ_note, 'Lanotaur') > 0
   AND instr(occ_note, 'Vibro-Knife (1D6 M.D.)') > 0
   AND instr(occ_note, '2D6x1000 credits') > 0
   AND instr(occ_note, 'hover cycles') = 0
   AND instr(occ_note, '2D6x10,000') > 0;

SELECT 'the pools, size, weight, category, Horror Factor and bonuses are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'zenith-moon-warper'
   AND hp = 'PE+5D6'
   AND sdc = '6D6'
   AND mdc = 'PE+6D6+12'
   AND ppe = '2D4x10+PEx2'
   AND isp = '1D4x10+MEx3'
   AND horror_factor = 10
   AND combat IS NULL
   AND category = 'humanoid'
   AND size = '5 to 6 ft (1.5 to 1.8 m)'
   AND weight = '120 to 150 lbs (54 to 67.5 kg)'
   AND instr(bonuses_note, 'Needs a 12 or higher') > 0;

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'zenith-moon-warper'
   AND instr(description, 'which this row followed until ~231') > 0;

SELECT 'and it still has no stat_attacks rows' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'zenith-moon-warper';

INSERT INTO data_script_runs (filename) VALUES ('~231-book-ingest-audit-f143-psy-zenith.sql');
