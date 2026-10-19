-- The Blind Warrior Women's and the Horune Pirate's creature rows follow
-- D-Bees of North America (BOOK-INGEST-AUDIT F143, row 38c2: Atlantis and
-- Underseas).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~233-book-ingest-audit-f143-atlantis-underseas.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~233-book-ingest-audit-f143-atlantis-underseas.sql
--
-- The classes blind-warrior-women and horune-pirate follow Rifts World Book
-- 30: D-Bees of North America (2007), printed 15-18 and 100-103, but their
-- creatures rows still cited Rifts World Book 2: Atlantis printed 50-51 and
-- Rifts World Book 7: Underseas printed 164-165 and carried their figures.
-- By Nate's ruling of 2026-10-04 the newest printing that STATES a figure
-- wins, so each row is UPDATED in place and moves its source_book to the
-- pages its class cites; where D-Bees is silent, the older book's figure
-- stays. A complete line D-Bees restates without an item drops that item
-- (the importing session's line rule of 2026-10-04). creatures has no notes
-- column, so each replaced figure is kept in description with its page.
--
-- Blind Warrior Women. Attributes, Hit Points, S.D.C., P.P.E., I.S.P.,
-- Horror Factor 12, size and weight are the same in both books. combat
-- takes D-Bees' eight attacks and its +3 Perception and +3 disarm; the other
-- keys are the same in both. By the line rule: D-Bees' R.C.C. skill list
-- names no Hand to Hand style, so Martial Arts goes (as the class did in
-- ~098); its storms line names neither smoke nor smell; and its no-penalty
-- sentence on blindness drops Atlantis' psionic and magical compensation.
-- habitat and allies stay Atlantis': D-Bees prints neither line. The
-- enemies line keeps Atlantis' hunters (D-Bees names none) and takes D-Bees'
-- 2% for Atlantis' quarter. Its three stat_attacks rows are NOT changed and
-- still carry Atlantis' karate damage (1D6, 1D8, 2D8); D-Bees' figures are
-- in bonuses_note.
--
-- Horune Pirate. Alignment, attributes, M.D.C., I.S.P., P.P.E. (Standard),
-- Horror Factor 10, size, weight and psionics are the same in both books.
-- combat gains the +1 Perception D-Bees gives at level 1 (and at 3, 5, 7,
-- 9, 11 and 13, in bonuses_note). D-Bees prints full Habitat, Alliances and
-- Allies, and Rivals and Enemies lines, so those replace the lines this row
-- had carried from Underseas printed 163; its Allies line restates
-- Underseas' without "villains", and its Magic line without Underseas'
-- "do not select any of the O.C.C. related skills". Its three stat_attacks
-- rows match D-Bees and are unchanged.
--
-- Read off renders of all three books: D-Bees cache p016-p019 and
-- p101-p104 (page_offset 1), Atlantis cache p050-p051 (page_offset 0) and
-- Underseas cache p163-p164 (page_offset -1 past printed 130). Guarded on
-- each row still citing its original book, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION: two creatures rows. The tilde number is
-- claimed at merge.

UPDATE creatures
   SET alignment = 'Any for a player character, tending to Unprincipled (30%) or Anarchist (30%); NPC villains are Anarchist or evil',
       pools_note = 'Hit points 1D4x10 plus 1D6 per level. M.D.C. only from magic or armor: the thin, rubbery suit and padded helmet give 30, the talisman''s Armor of Ithan 100; an Absurr Life Node symbiote or Chest Amalgamate awarded for loyalty makes her an M.D.C. being. I.S.P. +1D6 per level. Average level 2D6+1, or as the G.M. sets; player characters start at level one or two.',
       combat = '{"attacks":8,"initiative":2,"perception":3,"strike":1,"parry":2,"dodge":2,"disarm":3,"pull":2,"roll":4,"damage":2}',
       bonuses_note = 'Eight attacks per melee regardless of level or combat training, and the number does not improve; critical strike on a natural 18-20 (double damage); fights with paired weapons; no penalty for blindness or total darkness. Combat moves: body flip 2D4, karate kick 2D6, karate leap kick 3D8 and karate punch 2D4, all S.D.C. plus the P.S. damage bonus; a power kick does double damage but counts as two attacks. +2 vs psionic attacks, +1 vs magic, +4 vs Horror Factor, +10% vs coma/death. Vulnerabilities: storms of all kinds, rain, snow, sand, dust and ley line storms halve her radar, hearing, abilities and combat bonuses; she can never learn to read; her reputation as a Minion of Splugorth means many fear her and never trust her, and some seek her destruction.',
       skills_note = 'Boxing, climbing +10%, cook +5%, demon and monster lore +10%, general athletics, gymnastics (+5% where applicable), hunting, identify plants +5%, intelligence +5%, land navigation +5%, Language: Native Tongue (Demongogian), basic math +20%, paramedic +10%, preserve food +5%, prowl, running, skin and prepare animal hides +10%, swimming +10%, wilderness survival +10%; W.P. archery, blunt, knife, sword, energy pistol and energy rifle. R.C.C. Related Skills: two of Language: Other (+15%) and two from Espionage or Military (+10%), and no more. Three secondary skills from the Rifts Ultimate Edition Secondary Skill List (page 300) at level one, plus one at levels 3, 5, 7, 9, 12 and 15, all at the base skill level.',
       natural_abilities = 'Born blind, with no penalty for it: superb physical condition, fast reflexes and keen awareness, recovering lost Hit Points and S.D.C. three times faster than a human; heightened hearing (as cybernetic Amplified Hearing), smell (recognize odors 90%, a person, animal or plant 70%, poisons 80%, track 80%) and touch (66%), a radar sense to 1200 ft (366 m), and extraordinary physical endurance. Reproduces by ectoplasmic cloning (D-Bees refers to Atlantis for the process); the clone has half her level.',
       magic = 'Does not know magic, but may use magic weapons and devices and Splugorth parasites and symbiotes. A talisman casts Armor of Ithan (100 M.D.C., 10 minutes) three times a day; it recharges every 24 hours, or in one hour at a stone pyramid.',
       psionics = 'Sixth Sense (2), Presence Sense (4), Empathy (4), Sense Magic (3), Sense Evil (2), Object Read (6), Clairvoyance (4), Mind Block (4).',
       life_span = '4D6+60 years; sterile, reproduced by the Splugorth through cloning',
       enemies = 'A small percentage (2%) resent and resist slavery; runaways are hunted by Slavers, their sisters and Conservators, though the search is usually half-hearted and is abandoned after 48 hours, and a runaway any Splugorth minion recognizes is captured or slain',
       occ_note = 'Optional player character only where the G.M. allows: a runaway, unwelcome in Atlantis. R.C.C. with its own skills, using the Juicer experience table (D-Bees printed 17). Standard issue: a conventional dagger (1D6 S.D.C.), Vibro-Knife (1D6 M.D.), net gun, laser wrist blaster and Mental Incapacitator, of which even a runaway likely has all or at least half; Bio-Wizard devices vary with the assignment, frequently 1D4+1 each of aerobes, aquarobes, clotrobes, purirobes, stasirobes and watrobes. No money is printed.',
       description = 'Sterile, cloned, beautiful and blind warrior women, human or human-like before generations of Splugorth mind control and Bio-Wizard experimentation, who ride the slave barges to capture and herd slaves with martial arts and psionic senses; the few who break with the Splugorth flee into North America, Europe or Africa. Rifts World Book 2: Atlantis printed 50-51, which this row followed until ~233, gave: alignment any, but typically anarchist or evil; six attacks per melee, and no Perception or disarm bonus; karate kick 1D8, karate leap kick 2D8 and karate punch 1D6, with no body flip or power kick; Hand to Hand: Martial Arts at the head of the skill list, demon and monster lore +5%, gymnastics with no bonus, no native tongue and no related skills; six secondary skills from any category except medical, electrical and science; average level 4th to 10th (2D4+2); no life span; about 25% hating their captivity; no I.S.P. costs; a storms penalty that also named smoke and smell; blindness psionically and magically compensated; an unnamed vibro-blade; and no stone-pyramid recharge.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.15-18'
 WHERE slug = 'blind-warrior-women'
   AND source_book = 'Rifts World Book 2: Atlantis p.50-51';

UPDATE creatures
   SET pools_note = 'Spd 4D6+10 applies underwater and on land equally. Supernatural P.S. and P.E. M.D.C. species: no S.D.C. or hit points given; M.D.C. adds +1D6 per level of experience, and they may also wear M.D.C. body armor or use magic. P.P.E. is printed only as Standard, with no formula. I.S.P. adds +1D6+2 per level of experience on top of the base M.E.x5. A player character only where the G.M. allows: likely a loner and secretive, trusting no one but a fellow horune, of an alignment not likely better than anarchist or unprincipled, though good alignments are possible, and regarded by its own race as a dangerous rogue or a fool. 1-in-1,000 horune is instead a Ship Dreamer, a passive alien mystic shipbuilder detailed separately (Underseas printed 165, not extracted here).',
       combat = '{"initiative":2,"perception":1,"strike":1,"parry":1,"pull":2}',
       bonuses_note = 'R.C.C. Bonuses: +1 on Perception Rolls at levels 1, 3, 5, 7, 9, 11 and 13, +4 to save vs disease, +4 to save vs horror factor, in addition to the combat bonuses and attribute/skill bonuses. Underwater only (additional): +1 initiative, +1 strike, parry, and dodge, +1 to disarm, +1 to roll with impact. Vulnerabilities: none per se, though their greed, selfishness and cruelty sometimes work against them.',
       skills_note = 'R.C.C. Skills: Basic Math (+10%), Pilot: Warships and Patrol Boats (+5%), Pilot: Water Scooters (+10%), Pilot: Water Skiing and Surfing (+10%), Pilot Related: Navigation (+10%), Underwater Navigation, Salvage (+10%, on dry land and underwater), Wilderness Survival (+10%), W.P. Knife or Sword, W.P. Harpoon & Spear Gun, W.P. Torpedo, W.P. Spear/Trident, W.P. Energy Pistol, W.P. Modern: two of choice, Hand to Hand: Expert (may be changed to Martial Arts or Assassin at the cost of one O.C.C. Related Skill); plus four R.C.C. Related Skills at level one and one more at levels 3, 6, 9 and 12; two secondary skills from the Rifts Ultimate Edition Secondary Skill List (page 300) at levels 2, 4, 8 and 12. A Horune Mystic gains the Mystic O.C.C. psionic and magic powers but keeps these R.C.C. and secondary skills.',
       natural_abilities = 'Instinctual swimmers, swims 92%; holds breath up to 12 minutes; tolerates depths to 500 ft; nightvision 500 ft; sees infrared/ultraviolet light; hawk-like distance vision (2 miles) but nearsighted up close; good hearing; regenerates 1D6 M.D.C. per hour; regrows small parts (fingers, toes, eye stalks and eyes) in 1D6 weeks, limbs in 2D4 months.',
       magic = 'Only to Horune Mystics, who get the psionic and magic powers of the Mystic O.C.C. (Rifts Ultimate Edition) but use the R.C.C. skills and secondary skills given here, not those of the Mystic O.C.C.',
       life_span = '4D6+138 years; females bear one or two young after a 12 month pregnancy; physically mature by age 17',
       habitat = 'At sea: most spend their whole lives aboard ship, landing only to raid, take slaves or do business, and seldom linger ashore more than a few weeks; they may enslave coastal villages or seize small islands as outposts or dry docks without living there. Found along the coasts of almost every part of the world, most of all around Atlantis, their favorite port of call, and along the Atlantic coast from Dinosaur Swamp to Greenland, the Gulf of Mexico, the Mississippi and the St. Lawrence into the Great Lakes; Dinosaur Swamp is a place they feel safe and like to visit',
       allies = 'No official alliance with any kingdom or people, but associated with Atlantis and the Minions of Splugorth, Pharaoh Rama Set of the Phoenix Empire (Africa), the Gargoyle Empire (Germany and France) and, secretly, Mrrlyn of England; they come to the aid only of other horune, and associate and make deals with other pirates, slavers, monsters and evildoers',
       enemies = 'No rivals, being the best pirates on the seas; the New Navy, Lemurians, Naut''yll, Whale Singers and Ocean Mages top their list of enemies, and most people hate the horune, who victimize everyone',
       occ_note = 'R.C.C. with its own skills, related and secondary skills; 1-in-1,000 is a Ship Dreamer (alien mystic shipbuilder, detailed separately, not extracted here), and a Horune Mystic takes the Mystic O.C.C. powers with these R.C.C. skills. NPC experience level 2D4, or as the G.M. sets; a player character starts at first level on the Operator experience table (D-Bees printed 102). Standard equipment: a half suit of body armor (50 M.D.C.), energy pistols of choice, an energy or M.D.C. trident, a Vibro-Sword or dagger, a harpoon gun, a magic Sea-Horse Scooter, holster, utility belts, four large sacks, a backpack and personal items. Player characters start with 1D6x1000 worth of tradeable valuables; pirates spend their loot on weapons, booze and good times. Cybernetics and bionics are not applicable because of their superhuman and regenerative nature. Slave market value: 2D6x1,000, with very low demand, since horune make unreliable and treacherous slaves.',
       description = 'Five-eyed, avian-descended D-bee raiders who dominate the world''s oceans as brutal, mega-damage pirates loosely allied with the Splugorth of Atlantis, who take 65% of all their trade. Rifts World Book 7: Underseas printed 164-165, which this row followed until ~233, gave: hold breath 3D4 minutes; a life span of 160 Earth years, with no birth or maturity figures; regrowth of fingers, toes and eyes, without eye stalks; no Perception bonus and no underwater disarm; Undersea Salvage and Undersea Survival with no bonus, W.P. Harpoon Gun, W.P. Trident and Additional W.P.s: two of choice; secondary skills from its own related list without their bonuses; a mystic citing Rifts RPG page 85 and forgoing the O.C.C. related skills; 1D6x1000 worth of valuables; cybernetics not applicable because of a supernatural nature; allies including other villains; no experience table, slave value or vulnerabilities line. Underseas printed 163, from which this row took them, gave a habitat of the North and South Atlantic, Mediterranean, Black Sea, Caribbean, Gulf of Mexico, Indian Ocean and Arabian Sea, and enemies in the New Navy (Nemo-2), Tritonia''s shipping, surface dwellers and aquatic D-bees generally, with the naut''yll as rivals for the seas.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.100-103'
 WHERE slug = 'horune-pirate'
   AND source_book = 'Rifts World Book 7: Underseas p.164-165';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the two rows cite D-Bees and not Atlantis or Underseas' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE (slug = 'blind-warrior-women' AND source_book = 'Rifts World Book 30: D-Bees of North America p.15-18')
    OR (slug = 'horune-pirate' AND source_book = 'Rifts World Book 30: D-Bees of North America p.100-103');

SELECT 'the Blind Warrior Women figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'blind-warrior-women'
   AND instr(alignment, 'Unprincipled (30%)') > 0
   AND instr(pools_note, 'Average level 2D6+1') > 0
   AND instr(pools_note, '2D4+2') = 0
   AND combat = '{"attacks":8,"initiative":2,"perception":3,"strike":1,"parry":2,"dodge":2,"disarm":3,"pull":2,"roll":4,"damage":2}'
   AND instr(bonuses_note, 'Eight attacks') = 1
   AND instr(bonuses_note, 'smoke') = 0
   AND instr(bonuses_note, 'karate leap kick 3D8') > 0
   AND instr(skills_note, 'Martial Arts') = 0
   AND instr(skills_note, 'demon and monster lore +10%') > 0
   AND instr(skills_note, 'Demongogian') > 0
   AND instr(skills_note, 'levels 3, 5, 7, 9, 12 and 15') > 0
   AND instr(natural_abilities, 'three times faster') > 0
   AND instr(natural_abilities, 'compensates') = 0
   AND instr(magic, 'stone pyramid') > 0
   AND instr(psionics, 'Object Read (6)') > 0
   AND instr(life_span, '4D6+60') = 1
   AND instr(enemies, '(2%)') > 0
   AND instr(enemies, 'quarter') = 0
   AND instr(occ_note, 'Juicer') > 0
   AND instr(occ_note, 'Vibro-Knife (1D6 M.D.)') > 0;

SELECT 'the Horune Pirate figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'horune-pirate'
   AND combat = '{"initiative":2,"perception":1,"strike":1,"parry":1,"pull":2}'
   AND instr(bonuses_note, 'levels 1, 3, 5, 7, 9, 11 and 13') > 0
   AND instr(bonuses_note, '+1 to disarm') > 0
   AND instr(skills_note, 'Undersea') = 0
   AND instr(skills_note, 'W.P. Harpoon & Spear Gun') > 0
   AND instr(skills_note, 'W.P. Modern: two of choice') > 0
   AND instr(skills_note, 'page 300') > 0
   AND instr(natural_abilities, 'up to 12 minutes') > 0
   AND instr(natural_abilities, '3D4') = 0
   AND instr(natural_abilities, 'eye stalks') > 0
   AND instr(magic, 'Rifts Ultimate Edition') > 0
   AND instr(magic, 'page 85') = 0
   AND instr(life_span, '4D6+138') = 1
   AND instr(habitat, 'Greenland') > 0
   AND instr(habitat, 'Black Sea') = 0
   AND instr(allies, 'Mrrlyn') > 0
   AND instr(allies, 'villains') = 0
   AND instr(enemies, 'Lemurians') > 0
   AND instr(enemies, 'Tritonia') = 0
   AND instr(occ_note, 'Operator') > 0
   AND instr(occ_note, '2D6x1,000') > 0;

SELECT 'the attributes, pools, Horror Factor, size, weight and category are unchanged' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE (slug = 'blind-warrior-women'
        AND attributes = '{"IQ":"1D6+10","ME":"1D6+15","MA":"1D6+16","PS":"1D6+22","PP":"1D6+21","PE":"1D6+22","PB":"2D6+14","Spd":"2D6+22"}'
        AND hp = '1D4x10' AND sdc = '2D6x10' AND mdc IS NULL AND ppe = '2D6' AND isp = '3D6x10'
        AND horror_factor = 12 AND category = 'humanoid'
        AND size = '5.8 to 6.2 ft (1.7 to 1.9 m)' AND weight = '160 lbs (72 kg)'
        AND instr(habitat, 'Altara') = 1 AND allies = 'The Splugorth Slavers they serve')
    OR (slug = 'horune-pirate'
        AND attributes = '{"IQ":"2D6+4","ME":"2D6+4","MA":"2D6+4","PS":"3D6+10","PP":"3D6+6","PE":"3D6+6","PB":"2D6","Spd":"4D6+10"}'
        AND hp IS NULL AND sdc IS NULL AND mdc = 'PE+1D4x10' AND ppe IS NULL AND isp = 'MEx5'
        AND horror_factor = 10 AND category = 'alien humanoid'
        AND size = '5 to 6 feet (1.5-1.8 m)' AND weight = '200 to 300 lbs (90-135 kg)'
        AND instr(alignment, 'Anarchist (40%)') = 1 AND instr(psionics, 'hydrokinesis (super)') > 0);

SELECT 'each keeps the figures it replaced in its description' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE slug IN ('blind-warrior-women', 'horune-pirate')
   AND instr(description, 'which this row followed until ~233') > 0;

SELECT 'and their six stat_attacks rows are still there' AS assertion, count(*) AS got, 6 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug IN ('blind-warrior-women', 'horune-pirate');

INSERT INTO data_script_runs (filename) VALUES ('~233-book-ingest-audit-f143-atlantis-underseas.sql');
