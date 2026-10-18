-- The Yhabbayar Bubblemaker's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 6 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~230-book-ingest-audit-f143-psy-yhabbayar.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~230-book-ingest-audit-f143-psy-yhabbayar.sql
--
-- The class yhabbayar follows Rifts World Book 30: D-Bees of North America
-- (2007), printed 217-220, but its creatures row still cited Rifts World Book
-- 12: Psyscape printed 130-135 and carried its figures. By Nate's ruling of
-- 2026-10-04 the newest printing that STATES a figure wins, so the row is
-- UPDATED in place and moves its source_book; where D-Bees is silent,
-- Psyscape's figure stays. A complete line D-Bees restates without an item
-- drops that item: its New Spells paragraph restates Psyscape's "acquiring
-- new spells" paragraph without the sentence letting Mystics use
-- Techno-Wizard devices and the occasional rare scroll, so the magic column
-- drops it. creatures has no notes column, so each Psyscape figure that
-- changed is kept in description with its page.
--
-- Body: M.D.C. (P.E. +4D6, +1D6 per level), Hit Points (P.E. +3D6, +1D6 per
-- level), S.D.C. 5D6, I.S.P. (4D4x10 + M.E., +15 per level), P.P.E. (2D4x10 +
-- P.E., +3D6 per level), size and seven of the eight attribute dice are the
-- same in both books, so pools_note does not change. P.B. becomes 2D6+2
-- (Psyscape 2D6), weight 40.5 to 54 kg (Psyscape 40.8), and the life span
-- D-Bees' 6D6x10+140 years (Psyscape 300 to 500 Earth years). Horror Factor
-- is "not applicable" in D-Bees and stays NULL. combat gains D-Bees' +1
-- Perception at level one. D-Bees adds +2 vs illusions beside Horror Factor,
-- attacks and damage lines, Performance, Public Speaking and Philosophy, a
-- native-tongue American and two other languages, a secondary skill schedule
-- from Rifts Ultimate Edition, one Physical AND one Super-Psionic power a
-- level, NPC level 1D6+4, the Amorph experience table, Lazlo among its allies,
-- an enemies line and a slave value. The habitat keeps Psyscape's figure of
-- some 10,000 in Psyscape, which D-Bees does not restate. Both books print
-- the Yhabbayar as an R.C.C., so the row's shape is the same in both (F141
-- does not arise); category stays humanoid. The row has no stat_attacks.
--
-- Read off renders of both books (both at PDF offset +1: D-Bees cache
-- p218-p221, Psyscape cache p131-p136). Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET attributes = '{"IQ":"2D6+8","ME":"2D6+8","MA":"3D6+12","PS":"2D6+8","PP":"2D6+10","PE":"2D6+8","PB":"2D6+2","Spd":"5D6"}',
       combat = '{"initiative":1,"perception":1}',
       bonuses_note = '+1 initiative at levels 1, 3, 5, 7, 9, 11 and 13, and +1 on Perception Rolls at levels 1, 3, 5, 7, 9, 11, 13 and 15 (the level-one points are stored). Saves: +2 vs Horror Factor and illusions, +5 vs possession, +1 vs poison and disease. Master psionic: needs a 10 or higher to save vs psionics. While in the open trance, +8 to save vs psionic attack and +4 vs magic. Attacks per melee as per Hand to Hand: Martial Arts; damage as per weapon, magic, psionics or bubble attack.',
       skills_note = 'Language & Literacy: Native Tongue: American (no bonus printed) and two other languages of choice (+20%); Basic and Advanced Math (+25%); Art (+15%, professional quality); Performance (+15%); Public Speaking (+15%); Philosophy (+20%); Sing or Play Musical Instrument (+15%); Lore: Demons & Monsters and one lore of choice (+10% each); Wilderness Survival, Land Navigation, Climbing and Swimming (+10% each); Boxing or Wrestling; W.P. one Ancient and one Modern Energy Weapon; Hand to Hand: Martial Arts (cannot be changed). Six related skills plus one at levels 3, 6, 9, 12 and 15; three secondary skills from the Rifts Ultimate Edition Secondary Skills List (page 300) at levels 1, 3, 6, 10 and 14.',
       magic = 'Mystic-style intuitive spells: all level one spell invocations plus Float, Fly as the Eagle, Befuddle, Breathe Without Air, Magic Pigeon, Tongues, Life Source, Restore Limb and Mystic Portal; 1D4+1 more each level from spell levels up to one above its own. Cannot be taught or buy spells.',
       psionics = 'Master psionic: all Healing and Sensitive powers plus Levitation, and one Physical and one Super-Psionic power at each level. Mind Bleeder powers are never available.',
       weight = '90 to 120 lbs (40.5 to 54 kg)',
       life_span = '6D6x10+140 years; physically mature at 17, then spends 1D4x10+20 years meditating before leaving Psyscape, and most look 50-60 whatever their age. Females bear a single baby after a 24 month pregnancy, only after finding self-awareness and up to age 300, usually 1-4 children close together and then 30-50 years before the next',
       habitat = 'Primarily the Magic Zone and Psyscape, where some 10,000 live as valued citizens and masters of philosophy, art and conceptual physics; over the last few years they have taken to exploring the rest of North America',
       allies = 'The citizens of Psyscape (their adopted people) and most champions of good; favorably disposed toward the leaders of Lazlo and New Lazlo, Cyber-Knights, Dog Boys, Psi-Stalkers, all heroes and those with good hearts and gentle souls, though each person is judged on his own merits',
       enemies = 'The forces of evil in all its forms: the Minions of Splugorth, vampires, all evil supernatural beings and evil men. They hate injustice, cruelty, slavery, genocide and tyranny',
       occ_note = 'R.C.C. with its own skill package (printed as Bubblemaker R.C.C. Skills). Available O.C.C.s: none. NPC experience level 1D6+4, or as the G.M. sets; a player character is a young Yhabbayar starting at level one and uses the Amorph experience table (D-Bees printed 25). Starts with simple clothing and traveling clothes, light M.D.C. body armor (seldom medium or heavy), one weapon for each W.P. with 1D4+1 E-Clips or ammo-clips each, a large sack, 1D4 small sacks, a backpack, a shoulder bag, a silver cross, six wooden stakes and a mallet, a canteen, binoculars, a language translator, sunglasses, a pocket mirror, an air filter, a flashlight, a cigarette lighter, pens, markers or pencils, an eraser, a sketch book, a waterskin of bubble solution, 1D6 rings for blowing bubbles, a comb and other personal items, and often a digital camera with a variety of lenses; no vehicle to start (likes to walk, and fly by magic), but may acquire a riding animal or TW vehicle. 2D4x100 credits plus 3D4x100 in tradeable goods, and gives away half of whatever money it comes into. No cybernetics or bionics; a Bio-System prosthetic only if necessary. Slave market value: 2D6x100,000 credits.',
       description = 'Short, thin, big-eared D-Bees flung to Rifts Earth by a ley line storm who settled among the people of Psyscape, where they are honored as philosophers and teachers of the Third Eye. Most look 50-65 years old yet are alert and quick, with the reflexes of someone 20 or 30. Part guru, part child and part warrior, cheerful, curious and fond of puns and harmless pranks, they are called Bubblemakers for shaping soap bubbles with the mind and sealing psionics or spells inside them. They shun cybernetics, and money means little to them. Rifts World Book 12: Psyscape printed 130-135, which this row followed until ~230, gave: P.B. 2D6; a weight of 40.8 to 54 kg; a life span of 300 to 500 Earth years; no Perception bonus and no save vs illusions; no attacks per melee or damage line; speaks and is literate in American (+25%) and speaks one other language (+20%), with no Performance, Public Speaking or Philosophy; three secondary skills from its own related list plus one at levels 3, 6, 9 and 12; one Physical or Super-Psionic power a level; that Mystics may use Techno-Wizard devices and the occasional rare scroll; NPCs at levels 4-10; a 35 mm camera, a gas mask, a survival knife and a hand axe among its equipment; no Lazlo among its allies, no enemies line and no slave value; and the Magic Zone visited as scouts sent from Psyscape to locate the Harvesters.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.217-220'
 WHERE slug = 'yhabbayar'
   AND source_book = 'Rifts World Book 12: Psyscape p.130-135';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Yhabbayar cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yhabbayar'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.217-220';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yhabbayar'
   AND instr(attributes, '"PB":"2D6+2"') > 0
   AND weight = '90 to 120 lbs (40.5 to 54 kg)'
   AND instr(life_span, '6D6x10+140') = 1
   AND instr(bonuses_note, 'Horror Factor and illusions') > 0
   AND instr(skills_note, 'Philosophy (+20%)') > 0
   AND instr(skills_note, 'levels 1, 3, 6, 10 and 14') > 0
   AND instr(psionics, 'one Physical and one Super-Psionic') > 0
   AND instr(magic, 'Techno-Wizard') = 0
   AND instr(habitat, 'some 10,000') > 0
   AND instr(allies, 'New Lazlo') > 0
   AND instr(enemies, 'Minions of Splugorth') > 0
   AND instr(occ_note, '1D6+4') > 0
   AND instr(occ_note, '2D6x100,000') > 0;

SELECT 'combat gains +1 Perception and keeps its initiative' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yhabbayar'
   AND combat = '{"initiative":1,"perception":1}';

SELECT 'the pools, size, category and Horror Factor are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yhabbayar'
   AND hp = 'PE+3D6'
   AND sdc = '5D6'
   AND mdc = 'PE+4D6'
   AND ppe = '2D4x10+PE'
   AND isp = '4D4x10+ME'
   AND horror_factor IS NULL
   AND category = 'humanoid'
   AND size = '4 to 5 ft (1.2 to 1.5 m)'
   AND instr(pools_note, 'I.S.P. +15 per level') > 0
   AND instr(natural_abilities, 'Bubble Magic') > 0;

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'yhabbayar'
   AND instr(description, 'which this row followed until ~230') > 0;

SELECT 'and it still has no stat_attacks rows' AS assertion, count(*) AS got, 0 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'yhabbayar';

INSERT INTO data_script_runs (filename) VALUES ('~230-book-ingest-audit-f143-psy-yhabbayar.sql');
