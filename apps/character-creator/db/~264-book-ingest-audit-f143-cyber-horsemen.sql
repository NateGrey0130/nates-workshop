-- The cyber-horsemen-of-ixion creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, the Conversion Book One remainder, part 2 of 2).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~264-book-ingest-audit-f143-cyber-horsemen.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~264-book-ingest-audit-f143-cyber-horsemen.sql
--
-- The class cyber-horsemen-of-ixion follows Rifts World Book 30: D-Bees of
-- North America (2007) printed 51-54, but its creatures row still cited Rifts
-- Conversion Book One (revised 2002) printed 138-139 and carried its figures.
-- The row was held with F142, which closed with the year rule's second clause:
-- the newest printing wins unless the newer book says it describes an earlier
-- model. D-Bees says no such thing of the Ixion, so by Nate's ruling of
-- 2026-10-04 the newest printing that STATES a figure wins, and the row is
-- UPDATED in place and moves its source_book to the pages its class cites.
-- Where D-Bees is silent, Conversion Book One's figure stays. A complete line
-- D-Bees restates without an item drops that item. creatures has no notes
-- column, so each Conversion Book One figure that changed is kept in
-- description with its printed page.
--
-- Unchanged, the same in both books: every attribute roll (the JSON keeps the
-- unaugmented P.S. 3D6+8), S.D.C. 40, P.P.E. 3D6, Horror Factor 12, size,
-- weight and habitat.
--
-- Combat: D-Bees' complete Bonuses line restates +3 initiative, +1 parry, +1
-- disarm, +3 pull punch and +1 roll, and its dodge is "when running", so the
-- +3 dodge goes to bonuses_note as conditional, as ~263 read the Centaur. The
-- +1 attack per melee and the +1 to strike with spear and pole arm stay prose.
--
-- The six stat_attacks rows (female and male kicks, the body block) are
-- unchanged: D-Bees prints no per-attack damage, only "as per Bionic P.S.
-- +1D6 M.D. from rear kicks", which is kept in natural_abilities.
--
-- Read off renders of both books (both at PDF offset +1). Guarded on the row
-- still citing Conversion Book One, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but lean toward Principled (10%), Scrupulous (40%), Unprincipled (10%) and Anarchist (25%)',
       hp = 'PEx2+1D6',
       pools_note = 'P.S. is 3D6+8 without bionics; a bionic upper body has P.S. 2D6+20 and the bionic lower horse body P.S. 2D6+28. Hit Points are the P.E. attribute number x2, +1D6 per level of experience. S.D.C. is 40 plus those from Physical skills. Natural Spd is 7D6x2, doubled for brief 2D4-minute spurts; bionic Spd is 220 (150 mph/240 km) for males and 88 (60 mph/96 km) for females, though female warriors and scouts may have the males'' speed. M.D.C. by location, not a single roll: Bionic Hands (2) 18 each, Bionic Arms (2) 45 each, Bionic Front Legs (2) 110 each, Bionic Rear Legs (2) 160 each, Main Body (bionic horse) 250, Barding 125 additional M.D.C. to the main body, Upper Bionic Body (when applicable) 100, Upper Body Bionic Armor 90 additional, Head/Helmet 70 (double for a bionic head); hands, arms, front legs and head are small targets, -4 to strike. Bionic Barding increases overall weight by 50% and reduces running speed by 25%, and prowl is impossible in it.',
       combat = '{"initiative":3,"parry":1,"disarm":1,"pull":3,"roll":1}',
       bonuses_note = 'Attacks per melee are those of the Hand to Hand Combat skill and bonuses, +1 attack per melee. +3 on initiative, +1 to strike with spear and pole arm (in addition to W.P. bonuses), +1 to parry, +1 to disarm, +3 to dodge when running, +3 to pull punch, +1 to roll with impact and +3 to save vs Horror Factor, in addition to attribute and skill bonuses. Bionic Combat Augmentation adds +1 on initiative and +1 to strike by kick, and lets it leap 30 feet (9.1 m) high or 70 feet (21 m) across. Bionic weapons: at least one for each bionic arm, weapon rods particularly common. Vulnerabilities: stealth and disguise are pretty much impossible.',
       skills_note = 'R.C.C. skills in addition to those of a chosen O.C.C.: Dowsing +20%, Land Navigation +15%, Language: Native Tongue: Ixion 98% (95% literate in it too), Wilderness Survival +10% and W.P. Pole Arm.',
       natural_abilities = 'Great speed and endurance. Natural Prowl 50% +2% per level of experience (-30% if bionic). Without bionics it leaps 10 feet (3 m) high and 15 feet (4.6 m) across; bionic, 30 feet (9 m) high and 50 feet (15.2 m) across; either way double the length and half again the height with a running start. Otherwise on par with humans. Damage is as per bionic P.S. or weapons, +1D6 M.D. from rear kicks. Standard bionic body: hip holster(s), attachments for snap-on body armor, a medium to large concealed compartment, a built-in language translator with one or more optic and sensory implants, and a bionic lung; plus three cybernetic implants and two bionic features. Unlike other Centaurs, Ixion do not suffer and die in captivity.',
       magic = 'None, other than the acquisition of magic items and Lore skills',
       psionics = 'None',
       life_span = '6D6+140 years; physically mature by age 14; females give birth to a single foal once every two or three years up to age 70, after an 11 month pregnancy',
       allies = 'Tundra Rangers; Cyber-Knights; Justice Rangers; other Centaurs; Psi-Ponies; humans of Southwestern Canada and Northwestern America (mostly Native Americans); receptive to most people, though wary of D-Bees, especially monstrous ones',
       enemies = 'Demons, the ultimate enemy, especially the horde gathering at the Calgary Rift; Xiticix; Worm Wraiths; the Vampire Kingdoms of Mexico; dislike Psi-Stalkers, Greot Hunters, Yeno and other evil or cruel and intolerant beings; Simvan (regard them as dangerous rivals)',
       occ_note = 'Rifts: most (75%) are Combat Cyborgs or Headhunters (any), but can be any Men at Arms except Glitter Boy or Robot Pilot (none has ever become a Juicer); a few have become Cyber-Knights and Wilderness Scouts, and any Adventurer and Scholar O.C.C. is open. NPCs are level 1D10 or as the G.M. sets, player characters start at level one, and the chosen O.C.C.''s experience table is used. Standard equipment: as per O.C.C. plus one energy rod, spear or pole arm; they like Vibro-Blades, Neural Maces and magic items, and do not make guns but are not opposed to using them. Money as per O.C.C. Slave market value 4D4x10,000 credits, as warriors, gladiators, scouts, messengers and heavy labor.',
       description = 'Technologically advanced bionic centaurs from the hidden city of Ixion, wary of the Coalition, hostile to demons, and heavily cybernetically reinforced. Rifts Conversion Book One printed 138-139, which this row followed until ~264, gave alignment as Any but most lean toward selfish and good alignments, P.S. 3D6+22 for the lower bionic horse-body and P.S. equivalent of 40 bionic, Hit Points of the P.E. attribute number +1D6 per level, M.D.C. by location of Bionic Front Legs 100 each and Upper Body (body armor) 130 with no hands, arms, head or upper bionic body, Bionic Barding adding 50% to every location, a life span of 150 years with some to 220 and no maturity or birth figures, magic by O.C.C. only and psionics standard as for humans, R.C.C. skills with two languages of choice (typically American at +20%) and W.P. Pole Arm/Spear but no Dowsing, a Rifts O.C.C. line of effectively the Cyborg O.C.C. or any modern O.C.C., leaning Headhunter, Scholar and Adventurer, standard equipment adding an energy pistol, allies informally including Reid''s Rangers without other Centaurs or Psi-Ponies, and +1 to roll with punch, fall or impact with no strike bonus and no vulnerabilities.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.51-54'
 WHERE slug = 'cyber-horsemen-of-ixion'
   AND source_book = 'Rifts Conversion Book One p.138-139';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the cyber-horsemen-of-ixion row cites D-Bees' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'cyber-horsemen-of-ixion'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.51-54';

SELECT 'the Ixion figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'cyber-horsemen-of-ixion'
   AND hp = 'PEx2+1D6'
   AND sdc = '40'
   AND ppe = '3D6'
   AND horror_factor = 12
   AND instr(attributes, '"PS":"3D6+8"') > 0
   AND combat = '{"initiative":3,"parry":1,"disarm":1,"pull":3,"roll":1}'
   AND life_span LIKE '6D6+140 years%'
   AND instr(alignment, 'Scrupulous (40%)') > 0
   AND psionics = 'None'
   AND instr(pools_note, 'Bionic Front Legs (2) 110 each') > 0
   AND instr(description, 'which this row followed until ~264') > 0;

SELECT 'the Ixion attacks are unchanged' AS assertion, count(*) AS got, 6 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'cyber-horsemen-of-ixion';

INSERT INTO data_script_runs (filename) VALUES ('~264-book-ingest-audit-f143-cyber-horsemen.sql');
