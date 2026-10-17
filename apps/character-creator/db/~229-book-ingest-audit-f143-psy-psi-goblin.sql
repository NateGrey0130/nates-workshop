-- The Psi-Goblin's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 5 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~229-book-ingest-audit-f143-psy-psi-goblin.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~229-book-ingest-audit-f143-psy-psi-goblin.sql
--
-- The class psi-goblin follows Rifts World Book 30: D-Bees of North America
-- (2007), printed 164-166, but its creatures row still cited Rifts World Book
-- 12: Psyscape printed 128-130 and carried its figures. By Nate's ruling of
-- 2026-10-04 the newest printing that STATES a figure wins, so the row is
-- UPDATED in place and moves its source_book; where D-Bees is silent,
-- Psyscape's figure stays. A complete line D-Bees restates without an item
-- drops that item: the Magic line's "three times per 24 hours" (D-Bees gives
-- each spell a P.P.E. cost instead, as the class does), and the Psyscape
-- player note's level one or two start. creatures has no notes column, so
-- each Psyscape figure that changed is kept in description with its page.
--
-- Body: M.D.C. (P.E. +6D6+10, +1D6 per level), Horror Factor 11, size and the
-- seven attribute dice D-Bees prints are the same in both books. D-Bees
-- prints no P.B. and no Hit Point or S.D.C. figures, so P.B. 2D6, hp PE+6D6
-- and sdc 1D4x10 stay Psyscape's, as the class keeps P.B. I.S.P. becomes
-- D-Bees' 1D6x10+10 plus M.E. (Psyscape: 1D6x10 plus M.E. x2). D-Bees prints
-- P.P.E. two ways on printed 165: the stat block says 3D4x10+38 and the Magic
-- paragraph says 3D4x10 plus the P.E. attribute number. ppe stores the stat
-- block's figure, as the class's ppe_base does, and pools_note names both
-- (Psyscape: 3D4x10 plus P.E. x2). Weight becomes 40.5 to 54 kg. combat keeps
-- every figure, which both books print, and gains D-Bees' +1 Perception.
-- D-Bees adds Recognize Weapon Quality and Tailing, a later related-skill
-- schedule, I.S.P. and P.P.E. costs, equipment, money, experience levels and
-- slave value, none of which Psyscape printed. Both books print the
-- Psi-Goblin as an R.C.C., so the row's shape is the same in both (F141 does
-- not arise); category stays humanoid. Its four stat_attacks rows
-- (restrained, full and power punch, bite) match D-Bees and are not touched.
--
-- Read off renders of both books (both at PDF offset +1: D-Bees cache
-- p165-p167, Psyscape cache p129-p131). Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but most are Anarchist (35%), Miscreant (32%) or Diabolic (30%)',
       ppe = '3D4x10+38',
       isp = '1D6x10+10+ME',
       weight = '90 to 120 lbs (40.5 to 54 kg)',
       pools_note = 'On Rifts Earth a mega-damage being with Supernatural P.S. and P.E.: M.D.C. P.E. +6D6+10, +1D6 per level. On its native world and other places where magic is considerably weaker it is a Hit Point and S.D.C. being; D-Bees prints no figures for that, so the Hit Points (P.E. +6D6, +1D6 per level) and S.D.C. 1D4x10 are Psyscape''s (printed 129). I.S.P. 1D6x10+10 + M.E., +1D6 per level. D-Bees prints P.P.E. two ways on printed 165: its stat block says 3D4x10+38, which is stored, and its Magic paragraph says 3D4x10 plus the P.E. attribute number; P.P.E. does not grow with experience. Bio-regenerates 2D6 points an hour.',
       combat = '{"initiative":3,"perception":1,"strike":2,"disarm":3,"pull":4,"roll":2}',
       bonuses_note = 'Attacks per melee as per Hand to Hand: Expert (cannot be changed) plus one more attack per melee round; attacks are not otherwise printed. +1 on Perception Rolls. +2 roll covers impact or fall. Saves: +6 vs Horror Factor, +2 vs magic, +3 vs poison, radiation and pollution; impervious to disease. Needs a 12 or higher to save vs psionic attack. Their wickedness and greed can be their undoing.',
       skills_note = 'Gobblely and Faerie Speak 98%; one more language of choice, typically American (+10%); Escape Artist (+20%), Interrogation (+20%), Intelligence (+10%), Land Navigation (printed as 10%), Recognize Weapon Quality (+20%), Streetwise (+10%), Tailing (+20%), Wilderness Survival (+15%); W.P. Paired Weapons, Targeting, Knife or Sword, one Ancient, one Energy Weapon and one of choice; Hand to Hand: Expert (cannot be changed). Related skills: 1D4 Espionage, 1D4 Rogue and 1D4 Technical or Wilderness skills at level one, and one more Rogue or Espionage skill at levels 4, 8 and 12, all starting at first level proficiency. No secondary skills.',
       magic = 'Knows a handful of spells intuitively, like a Mystic: Shadow Meld (10), Armor of Ithan (10), Fool''s Gold (10), Repel Animals (7), Energy Bolt (5), Force Bonds (25) and Frostblade (15).',
       psionics = 'Major psychic: Detect Psionics (6), Death Trance (1), Ectoplasm (6+), Mind Block (4), See the Invisible (4), Sense Magic (3) and Sense Evil (2), plus two Physical powers of choice.',
       life_span = '1D6x100+400 years, physically mature at 14. Females bear a litter of 2D6 live young once every 50 years, up to age 400',
       habitat = 'Can go adventuring, but mainly the Magic Zone, with a tribe of about 60 in the ruins of Old Chicago, another 60 in southern Michigan and a hundred or so in the Pecos Empire; adapts to most environments but prefers forest, mountain and canyon country',
       allies = 'Mostly their own kind, in groups of 6-24 ruled by one strong leader or 2-4 Elders; sometimes Black Faeries, Brodkil, demons, semi-intelligent monsters, Necromancers, evil mages of 6th level or higher, Mind Bleeders and powerful evil psychics. Vindictive tyrants over any village or town of lesser beings they rule; Lord Dunscon of the Federation of Magic has more serving him than most would believe',
       enemies = 'Humans and champions of light in general, and anyone who dares oppose them; they hate the Coalition States because Lord Dunscon tells them to and because CS soldiers are pretty humans. Vindictive in the extreme: anyone who defeats, hurts or humiliates them is an enemy for life',
       occ_note = 'R.C.C. with its own skill package, an optional player character and NPC. A player character is either an outcast with delusions of being a hero or adventurer (Scrupulous, Unprincipled or Anarchist) or one of Dunscon''s spies pretending to be a good guy, likely to betray the group sooner or later. Available O.C.C.s: none, though they may work as bandits, thieves, thugs, enforcers, guards, scouts, torturers, interrogators and assassins. NPC experience level 1D6+1, or as the G.M. sets; player characters start at level one and use the SAMAS Pilot experience table. Love Vibro-Blades and heavy energy weapons and covet magic items; not sophisticated enough for power armor, robots or most combat vehicles, but adore hovercycles, motorcycles and jet packs. Starts with a large sack, satchel or backpack, waterskin, loincloth, belt, 20 ft (6.1 m) of rope, war paint and a torture kit (a small sharp knife or scalpel, 1D6+4 sharp metal or wooden needles, needle-nosed pliers, black jack, cigarette lighter, six ounces of salt and odds and ends), and 2D6x100 credits plus 2D6x100 in tradeable goods. Neither needs nor wants cybernetics or bionics. Slave market value: 2D6x1,000 credits, as killers, torturers, spies, scouts and gladiator teams.',
       description = 'Small, savage D-Bees, or creatures of magic (the debate is still out), from a magic-rich world where they prey on Faerie Folk; suspected to have been brought to Earth by Lord Alistair Dunscon, whose army of Psi-Goblins had grown to nearly 3200 by 109 P.A. Several hundred more roam the Magic Zone as mercenaries, bandits, raiders and thieves and hire out as spies, bodyguards and assassins, but are ultimately Dunscon''s spies. Hairless, bronze-skinned humanoids 4-5 ft tall with ugly faces, sharp pointed teeth, large ears and clawed fingers and toes, wearing war paint, large earrings and a loincloth or fur, they use every kind of weapon to the full. Mean, nasty, aggressive and murderous, jealous, greedy and cruel, they hate beauty and joy and are feared as torturers and interrogators. On Rifts Earth they are mega-damage beings with innate magic and psionics. Rifts World Book 12: Psyscape printed 128-130, which this row followed until ~229, gave: an army of 2000 serving Dunscon; creatures of magic like other goblins; mega-damage on Rifts Earth and Wormwood; I.S.P. 1D6x10 plus M.E. x2, +1D6 per level; P.P.E. 3D4x10 plus P.E. x2; a weight of 40.8 to 54 kg; a life span of 1000+ Earth years; each of its seven spells three times per 24 hours, with no P.P.E. costs; no I.S.P. costs for its psionics; no Perception bonus; no Recognize Weapon Quality or Tailing and no later related skills; an NPC villain whose player characters are likely Unprincipled or Anarchist and start at level one or two, with NPCs at levels 3-7, and no equipment list, money, experience table or slave value; no tribe in southern Michigan; no Brodkil among its allies; and no stated hatred of the Coalition States.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.164-166'
 WHERE slug = 'psi-goblin'
   AND source_book = 'Rifts World Book 12: Psyscape p.128-130';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Psi-Goblin cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'psi-goblin'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.164-166';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'psi-goblin'
   AND instr(alignment, 'Anarchist (35%)') > 0
   AND ppe = '3D4x10+38'
   AND isp = '1D6x10+10+ME'
   AND instr(weight, '40.5 to 54 kg') > 0
   AND instr(skills_note, 'Tailing (+20%)') > 0
   AND instr(psionics, 'Ectoplasm (6+)') > 0
   AND instr(magic, 'Force Bonds (25)') > 0
   AND instr(life_span, '1D6x100+400') = 1
   AND instr(habitat, 'southern Michigan') > 0
   AND instr(allies, 'Brodkil') > 0
   AND instr(enemies, 'Coalition States') > 0
   AND instr(occ_note, 'SAMAS Pilot') > 0;

SELECT 'combat gains +1 Perception and keeps the rest' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'psi-goblin'
   AND combat = '{"initiative":3,"perception":1,"strike":2,"disarm":3,"pull":4,"roll":2}';

SELECT 'the body, attributes, Horror Factor and size are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'psi-goblin'
   AND attributes = '{"IQ":"1D6+8","ME":"2D6+8","MA":"1D6","PS":"2D6+12","PP":"2D6+12","PE":"2D6+12","PB":"2D6","Spd":"6D6"}'
   AND hp = 'PE+6D6'
   AND sdc = '1D4x10'
   AND mdc = 'PE+6D6+10'
   AND horror_factor = 11
   AND category = 'humanoid'
   AND size = '4 to 5 ft (1.2 to 1.5 m)';

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'psi-goblin'
   AND instr(description, 'which this row followed until ~229') > 0;

SELECT 'and its four stat_attacks rows are untouched' AS assertion, count(*) AS got, 4 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'psi-goblin'
   AND name IN ('Restrained punch', 'Full strength punch', 'Power punch', 'Bite');

INSERT INTO data_script_runs (filename) VALUES ('~229-book-ingest-audit-f143-psy-psi-goblin.sql');
