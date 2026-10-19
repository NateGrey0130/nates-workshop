-- The Pogtalian Dragon Slayer's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, row 38c3: South America).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~234-book-ingest-audit-f143-south-america.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~234-book-ingest-audit-f143-south-america.sql
--
-- The class pogtalian-dragon-slayer follows Rifts World Book 30: D-Bees of
-- North America (2007), printed 156-159, but its creatures row still cited
-- Rifts World Book 6: South America printed 135-136 and carried its figures.
-- By Nate's ruling of 2026-10-04 the newest printing that STATES a figure
-- wins, so the row is UPDATED in place and moves its source_book to the pages
-- its class cites; where D-Bees is silent, South America's figure stays. A
-- complete line D-Bees restates without an item drops that item (the
-- importing session's line rule of 2026-10-04). creatures has no notes
-- column, so each replaced figure is kept in description with its page.
--
-- Attributes, S.D.C., size, weight and the bite are the same in both books.
-- Horror Factor 12 stays South America's: D-Bees prints none. hp takes
-- D-Bees' 2D6 per level, mdc adds the P.E. attribute number (and 1D6 per
-- level, in pools_note), and ppe goes from NULL to 2D6x10. combat keeps
-- five attacks (Martial Arts plus the racial one) and its +3 initiative, +1
-- parry and +2 dodge, and gains +2 Perception, +2 strike and +2 pull punch.
-- By the line rule: D-Bees' Bonuses line names no supersensitive hearing, so
-- the hearing and the bonuses South America hung on it go; its Attributes
-- line makes only P.S. and P.E. Supernatural; its Alignment line drops the
-- Cibola clause; its Pilot, Pilot Related and Rogue lines drop "any if
-- trained in Cibola"; and its Habitat line replaces the one this row built
-- from South America's prose. The row takes D-Bees' alignment split, life
-- span and birth figures, R.C.C., related and secondary skill schedules,
-- vulnerabilities, allies, enemies, equipment, money, experience levels and
-- slave value. magic and psionics stay NULL: D-Bees prints None for both.
-- Its one stat_attacks row (Bite, 6D6 MD) matches D-Bees and is unchanged.
--
-- Read off renders of both books: D-Bees cache p157-p160 and South America
-- cache p136-p137 (page_offset 1 in both). Guarded on the row still citing
-- South America, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: one creatures row. The tilde number is
-- claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but leans towards Unprincipled (10%), Anarchist (40%), Aberrant (10%) and Miscreant (30%)',
       hp = 'PEx5+2D6',
       mdc = '1D4x100+PE',
       ppe = '2D6x10',
       pools_note = 'M.D.C. 1D4x100 plus the P.E. attribute number, +1D6 per level of experience; on S.D.C. worlds 1D4x100 S.D.C. and Hit Points of P.E. x5, +2D6 per level. Energy aura adds 100 M.D.C., taken first and restored in 24 hours. Special bio-regeneration restores 1D6x10 M.D.C. instantly, three times per 24 hours; otherwise lost M.D.C. recovers at 1D6 per hour. P.S. and P.E. are Supernatural.',
       combat = '{"attacks":5,"initiative":3,"perception":2,"strike":2,"parry":1,"dodge":2,"pull":2}',
       bonuses_note = 'Attacks as per Hand to Hand: Martial Arts plus the racial +1 attack per melee (five at first level). +3 to save vs magic, +3 vs psionic attacks, +5 vs Horror Factor. Damage as per Supernatural P.S. or by weapon. Vulnerabilities: giant size makes the Pogtal the target most opponents take down first, is hard to conceal, and with its gruesome looks may make people flee in terror or attack; small, light bridges, narrow streets and alleys, and human-sized dwellings and buildings may be impassable.',
       skills_note = 'Hand to Hand: Martial Arts, Hunting, Land Navigation +20%, Language: Native Tongue (Pogtalian at 94%), Language: Other: Spanish +15%, Lore: Demons and Monsters +10%, Skin and Prepare Animal Hides +20% (+10% for small animals), Swimming +10%, Track (people) +10%, Track Animals +20% (dragons and dinosaurs too), Wilderness Survival +25%; W.P. Archery or W.P. Targeting, W.P. Blunt, three Ancient and two Modern W.P.s of choice. R.C.C. Related Skills: five other skills at first level plus two at levels 3, 6, 9, 12 and 15. Two secondary skills from the Rifts Ultimate Edition Secondary Skill List (page 300) at levels 2, 4, 8 and 12, at the base skill level.',
       natural_abilities = 'Impervious to magic fire (dragon and magic M.D. fire included) and to normal fire and cold; teeth the size of short swords, a lost one regrown in two weeks; an unhinging jaw for a 4x4x4 ft (1.2 m) bite. The energy aura switches on with fear, anger, excitement or exertion and makes held S.D.C. weapons and objects strike with the M.D. of the giant''s Supernatural P.S. punch, and they stay M.D. after the aura''s M.D.C. is gone.',
       life_span = '3D6x10+150 years; physically mature by age 30; females bear one young after a 24 month pregnancy, cannot bear again for 1D6+3 years, and can bear children till 100',
       habitat = 'Native to a wilderness world dominated by dragons, and most numerous in South America, where many serve in Cibola; found anywhere in North, Central and South America, in North America most of all in Mexico, the American Southwest, the Deep South and the Magic Zone, and a few may head for the Calgary Rift and the Kingdom of Monsters',
       allies = 'None per se, though the giants may hook up with bands of adventurers, heroes or bad guys if it strikes their fancy or serves their purpose',
       enemies = 'Dragons, large dinosaurs, giant monsters, Greater Demons, Demigods, Godlings, creatures of magic, the Demon-Dragonmage and the Minions of Splugorth; other dragon and demon slayers, powerful practitioners of magic, great warriors and heroes of renown are rivals, and they challenge warriors, heroes and infamous villains and monsters to duels, to the death unless the giant is good or selfish',
       occ_note = 'R.C.C. with its own skills; no O.C.C. is available, since Pogtal are what they are. Related skill categories exclude Cowboy, Mechanical, Military, Pilot Related and Rogue, and allow Pilot: Boats and Horsemanship: Exotic Animals only. NPC experience level 1D6+2, or as the G.M. sets; a player character starts at level one on the Dragon experience table. Standard equipment: a giant-sized melee weapon for each W.P., often made from the bones of dragons and monsters, and possibly giant-sized modern guns, Vibro-Blades, magic weapons and custom armor; traditional Dragon Skin Armor gives 2D6x10+100 M.D.C., or 3D6x10+140 reinforced. Money: 2D6x1,000 credits and 3D6x1,000 worth of tradeable goods. Cybernetics and bionics: none at the start, but open to a bionic limb lost in combat. Slave market value: 2D6x100,000 credits.',
       description = 'Proud giant D-Bees evolved to hunt dragons, with a neanderthal''s head, a pig-like nose and a double row of hooked teeth on 13 to 28 ft of muscle, who seek great foes and renown rather than loot and kill good and evil alike. In South America many serve Inix of Cibola as mercenaries, rivals of the pincer warriors, and a taste for humanoid flesh earns them a monstrous name. Rifts World Book 6: South America printed 135-136, which this row followed until ~234, gave: alignment any, leaning anarchist, with most in Cibola anarchist or miscreant; Hit Points +1D6 per level; M.D.C. 1D4x100 with no P.E. or per-level addition; no P.P.E.; every attribute supernatural; a life span of 300 years with no birth or maturity figures; supersensitive hearing equal to cybernetic amplified hearing, giving the +1 parry, +2 dodge and +3 initiative, and no Perception, strike or pull punch bonus; no native tongue, Spanish, demon and monster lore or track people skill, W.P. Targeting with no archery option and two W.P.s of choice (archaic if native, any if trained in Cibola); six related skills at first level, with Pilot, Pilot Related and Rogue skills any if trained in Cibola, and no secondary skills; a habitat of Pogtalia, the Cibolan defense forces and deserters in the Amazon; and no allies, enemies, vulnerabilities, experience table or slave value.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.156-159'
 WHERE slug = 'pogtalian-dragon-slayer'
   AND source_book = 'Rifts World Book 6: South America p.135-136';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the row cites D-Bees and not South America' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'pogtalian-dragon-slayer'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.156-159';

SELECT 'the Pogtal figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'pogtalian-dragon-slayer'
   AND instr(alignment, 'Anarchist (40%)') > 0
   AND instr(alignment, 'Cibola') = 0
   AND hp = 'PEx5+2D6' AND mdc = '1D4x100+PE' AND ppe = '2D6x10'
   AND instr(pools_note, '1D6 per hour') > 0
   AND instr(pools_note, 'P.S. and P.E. are Supernatural') > 0
   AND combat = '{"attacks":5,"initiative":3,"perception":2,"strike":2,"parry":1,"dodge":2,"pull":2}'
   AND instr(bonuses_note, 'hearing') = 0
   AND instr(bonuses_note, 'Vulnerabilities') > 0
   AND instr(skills_note, 'Pogtalian at 94%') > 0
   AND instr(skills_note, 'five other skills') > 0
   AND instr(skills_note, 'page 300') > 0
   AND instr(natural_abilities, 'short swords') > 0
   AND instr(life_span, '3D6x10+150') = 1
   AND instr(habitat, 'Calgary Rift') > 0
   AND instr(habitat, 'Amazon') = 0
   AND instr(allies, 'None per se') = 1
   AND instr(enemies, 'Demon-Dragonmage') > 0
   AND instr(occ_note, 'Dragon experience table') > 0
   AND instr(occ_note, '2D6x100,000') > 0
   AND instr(occ_note, 'trained in Cibola') = 0;

SELECT 'the attributes, S.D.C., Horror Factor, size, weight and category are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'pogtalian-dragon-slayer'
   AND attributes = '{"IQ":"3D6+1","ME":"4D6","MA":"3D6","PS":"5D6+10","PP":"4D6+2","PE":"4D6+6","PB":"1D6+1","Spd":"4D6"}'
   AND sdc = '1D4x100' AND isp IS NULL AND ar IS NULL AND magic IS NULL AND psionics IS NULL
   AND horror_factor = 12 AND category = 'giant' AND playable = 1
   AND size = '3D6+10 ft' AND weight = '1D6x1000 lbs (1D6x450 kg)';

SELECT 'it keeps the figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'pogtalian-dragon-slayer'
   AND instr(description, 'which this row followed until ~234') > 0
   AND instr(description, '300 years') > 0;

SELECT 'and its bite is still there' AS assertion, count(*) AS got, 1 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'pogtalian-dragon-slayer'
   AND name = 'Bite' AND damage = '6D6 MD';

INSERT INTO data_script_runs (filename) VALUES ('~234-book-ingest-audit-f143-south-america.sql');
