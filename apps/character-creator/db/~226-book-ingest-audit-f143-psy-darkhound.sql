-- The Darkhound's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Psyscape part 2 of 7).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~226-book-ingest-audit-f143-psy-darkhound.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~226-book-ingest-audit-f143-psy-darkhound.sql
--
-- The class darkhound follows Rifts World Book 30: D-Bees of North America
-- (2007), printed 54-58 (~096), but its creatures row still cited Rifts World
-- Book 12: Psyscape printed 94-98 and carried its figures. By Nate's ruling
-- of 2026-10-04 the newest printing that STATES a figure wins, so the row is
-- UPDATED in place and moves its source_book; where D-Bees is silent,
-- Psyscape's figure stays (the "about half" who wear scrap armor, the
-- permanent P.P.E. base, Hand to Hand: Expert, no nightvision). A complete
-- line D-Bees restates without an item drops that item: the secondary skill
-- limit (Physical, Technical spoken languages and lore, Wilderness), the
-- Enemies line's "no real enemies, anything warm and living is food", the
-- plain knife, and the habitat's lower Great Lakes, as the class did in
-- ~096. creatures has no notes column, so each Psyscape figure that changed
-- is kept in description with its printed page.
--
-- Body: unchanged. Both books print the same eight attribute dice, M.D.C.
-- 3D6x10 (+2D6 per level), P.P.E. 2D6, I.S.P. 1D6x10 plus M.E. and Horror
-- Factor 11, so hp, sdc, mdc, ppe, isp, horror_factor and attributes stay.
-- D-Bees marks only P.S. and P.E. as supernatural where Psyscape called all
-- physical attributes supernatural; pools_note now says P.S. and P.E.
-- combat: D-Bees prints its own attack schedule, starting with four (+1 at
-- levels 2, 5, 8, 10, 13 and 15), and adds +3 Perception and +1 dodge to
-- Psyscape's line; Psyscape's five at level one (Hand to Hand: Expert's four
-- plus a racial +1) becomes four, as the class reads it. The key stays
-- `pull`, the spelling the row already used. psionics gains Meditation.
-- Both books print the Darkhound as an R.C.C. with its own skills, so the
-- row's shape is the same in both (F141 does not arise). Its two
-- stat_attacks rows (claws 2D6 MD, bite 4D6 MD) match D-Bees and are not
-- touched.
--
-- Read off renders of both books (both at PDF offset +1: D-Bees cache
-- p055-p059, Psyscape cache p095-p099). Guarded on the row still citing
-- Psyscape, so a re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION: one
-- creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but typically Anarchist (33%), Unprincipled (23%) or Aberrant evil (24%); whatever its alignment, a bloodthirsty predator toward psychics, practitioners of magic and evil supernatural beings',
       pools_note = 'A mega-damage creature: M.D.C. 3D6x10, +2D6 per level of experience, and may also wear partial body armor for additional protection. I.S.P. +10 per additional level; regained 2 per hour of activity or 12 per hour of meditation or sleep. P.P.E. 2D6 is the permanent base. P.S. and P.E. are supernatural; its endurance takes about ten times the exertion of a Dog Boy. About half wear scrap-built partial body armor, typically 1D4x10+15 M.D.C.',
       combat = '{"attacks":4,"initiative":2,"perception":3,"strike":1,"dodge":1,"pull":3,"roll":1}',
       bonuses_note = 'Horror Factor 11 for most humanoids, 14 for supernatural creatures, psychics and practitioners of magic. Bonuses are in addition to those from attributes and skills. Four attacks per melee at level one, +1 at levels 2, 5, 8, 10, 13 and 15; +2 initiative at levels 1, 4, 8 and 14; +3 on Perception Rolls, +1 strike, +1 dodge, +3 pull punch, +1 roll with impact. Saves: +4 vs Horror Factor, +3 vs disease and poison, +2 vs possession; needs 10 or higher to save vs psionics as a master psychic. Magic resistance: even on a failed save, magic''s damage, duration and penalties are halved. Its low intelligence, powerful instincts and drive to hunt may work against it.',
       skills_note = 'Climb (+15%), Detect Ambush (+15%), Land Navigation (+20%), Prowl (+10%), Intelligence (+5%), Swim (+20%), Tailing (+20%), Wilderness Survival (+20%), W.P. Sword or Knife; speaks American at 45% +3% per level and may pick up one additional language at 35% +3% per level; cannot understand the written word. One related skill at each of levels 2, 4, 8, 12 and 15, none at level one, from Communications (Barter, Radio: Basic and Sign Language only), Domestic (any), Physical (any except Acrobatics, Kick Boxing and SCUBA), Rogue (any), Weapon Proficiencies (any) and Wilderness (any, +10%); all new skills start at first level. Two secondary skills from the Secondary Skill List of Rifts Ultimate Edition (p.300) at each of levels 1, 3, 6, 9 and 12, without bonuses other than a high I.Q. bonus. Combat equal to Hand to Hand: Expert (Psyscape printed 97; D-Bees prints no combat line, and its attack schedule is the whole count).',
       psionics = 'Master psychic: Deaden Senses, Empathy (receive only, not transmission), Meditation, Nightvision, Resist Fatigue, Sense Evil and Sense Magic, plus one additional Sensitive power of choice.',
       weight = '400 to 500 lbs (180 to 225 kg)',
       life_span = '3D6+22 years; physically mature by age six. Females bear a litter of 2D4 after a five month pregnancy, and the young fend for themselves at five',
       habitat = 'Created in the City of Brass in Kentucky and most common in the Magic Zone, but over the last 20 years spread into Ohio, Indiana, Michigan, Kentucky, Tennessee, Arkansas and Texas',
       allies = 'None officially, but it instinctively counts humans and Psi-Hounds as friends and potential allies and would love to live and work with both, though people fear it, and it likes Coalition soldiers; it seldom attacks humans or Dog Boys unless attacked first, and has joined CS troops against mages and supernatural horrors. A social animal that travels and hunts at night in packs of 4D4, occasionally in small mixed groups of Dog Boys, humans and D-Bees; for all its affinity with Dog Boys and Coalition soldiers, most keep their distance and avoid prolonged or regular contact',
       enemies = 'Hates Mystic Knights, Bio-Wizards, Minions of Splugorth, Witch Wolves, Brodkil, Black Faeries, Witchlings and demons with an almost obsessive passion, and hunts all Psi-Stalkers, psychics, practitioners of magic, evil creatures of magic and evil supernatural beings; magic practitioners and the supernatural are its favorite prey. Attacks other intelligent canines, Werewolves, Witch Wolves and animal-like D-Bees and monsters without hesitation',
       occ_note = 'R.C.C. with its own skills; Available O.C.C.s: none. An optional player character or NPC with the I.Q. of a six year old child and the predatory instincts of a wolf, more animal than human. Experience level 1D6 for NPCs, or as the G.M. sets; player characters start at first level, on the Darkhound''s own experience table printed with the entry (level 2 at 2,061, level 15 at 350,901). Can use guns and simple weapons and tools but seldom uses guns, and cannot pilot a vehicle, operate a radio or computer, or understand the written word. Standard equipment: homemade, piecemeal body armor (1D4x10+15 M.D.C.), a hooded cloak or poncho, a Vibro-Knife, a Vibro-Sword or a magical equivalent, a backpack or satchel holding 1D6+10 wooden stakes, a wooden mallet, a wooden cross, a mirror, a comb and some personal items; starts with no guns and no magic items. Starts with only 4D6x10 in tradeable goods. Slave market value 2D6x10,000 as warriors, assassins, gladiators and trackers.',
       description = 'Huge grey-furred canine hunters of the Magic Zone with long gorilla-like arms, clawed hands and glowing red eyes. The stories are true: Lord Dunscon let his supernatural associates experiment on captured Dog Boys, 15% of whom survived warped into mega-damage Darkhounds, and at least half of those alive today are transformed Dog Boys, the rest bred true; they remember nothing of it. They hunt mages, psychics and the supernatural with obsessive hatred, but shadow Coalition patrols, warn them of ambushes and have defended human children from monsters. Rifts World Book 12: Psyscape printed 94-98, which this row followed until ~226, gave: the Dog Boy origin as a rumor, with some 15-20% surviving; the heading NPC Villain and Optional Player R.C.C., the I.Q. of a five year old child and the instincts of a crazed hunter, an average NPC level of 1D4, and the Juicer experience table on the class page (its experience-tables page lists the Darkhound with the Psi-Druid and Psi-Ghost); five attacks per melee at level one, from Hand to Hand: Expert plus a racial +1 attack at levels 1, 5 and 10, with no Perception or dodge bonus and +1 to roll with impact or fall; all physical attributes supernatural; Horror Factor 14 to supernatural creatures and magic practitioners, especially the True Federation, with no psychics named; a bloodthirsty predator toward supernatural beings, not only evil ones; no Meditation among its psionics; no Detect Ambush or Tailing, no related skills, and four secondary skills once, limited to Physical (any), Technical (spoken languages and lore only) and Wilderness (any); a life span unknown, perhaps 30 to 40 years; a habitat of the wildernesses of the Magic Zone, Ohio and the lower Great Lakes; no real enemies, almost anything warm and living being food, with its hatred aimed at practitioners of magic above all, then evil supernatural beings, powerful Major and Master psychics, creatures of magic including faerie folk and dragons, and monsters of all kinds, and an affinity for Dog Boys, CS soldiers and innocent humans; no guns of any kind, the ragged remains of clothing, possibly piecemeal armor, one Vibro-Blade and a knife, with blunt weapons, staves and magic blade or blunt weapons allowed; and no money.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.54-58'
 WHERE slug = 'darkhound'
   AND source_book = 'Rifts World Book 12: Psyscape p.94-98';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Darkhound cites D-Bees and not Psyscape' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'darkhound'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.54-58';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'darkhound'
   AND combat = '{"attacks":4,"initiative":2,"perception":3,"strike":1,"dodge":1,"pull":3,"roll":1}'
   AND instr(psionics, 'Meditation') > 0
   AND life_span LIKE '3D6+22 years%'
   AND instr(skills_note, 'Detect Ambush (+15%)') > 0
   AND instr(occ_note, 'Experience level 1D6') > 0
   AND instr(habitat, 'City of Brass') > 0;

SELECT 'the body, attributes and Horror Factor are unchanged' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'darkhound'
   AND hp IS NULL
   AND sdc IS NULL
   AND mdc = '3D6x10'
   AND ppe = '2D6'
   AND isp = 'ME+1D6x10'
   AND horror_factor = 11
   AND attributes = '{"IQ":"2D4+2","ME":"2D6+8","MA":"2D4+1","PS":"3D6+10","PP":"3D6+6","PE":"2D6+10","PB":"2D4","Spd":"6D6+10"}';

SELECT 'it keeps the Psyscape figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'darkhound'
   AND instr(description, 'which this row followed until ~226') > 0;

SELECT 'and its two stat_attacks rows are untouched' AS assertion, count(*) AS got, 2 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'darkhound'
   AND ((name = 'Claws' AND damage = '2D6 MD') OR (name = 'Bite' AND damage = '4D6 MD'));

INSERT INTO data_script_runs (filename) VALUES ('~226-book-ingest-audit-f143-psy-darkhound.sql');
