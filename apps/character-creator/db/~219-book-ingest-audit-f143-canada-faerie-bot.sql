-- The Faerie Bot's creature row follows D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, Canada part 2 of 4).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~219-book-ingest-audit-f143-canada-faerie-bot.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~219-book-ingest-audit-f143-canada-faerie-bot.sql
--
-- The class faerie-bot follows Rifts World Book 30: D-Bees of North America
-- (2007), printed 76-79, but its creatures row still cited Rifts World Book
-- 20: Canada printed 149-151 and carried its figures. By Nate's ruling of
-- 2026-10-04 the newest printing that STATES a figure wins, so the row is
-- UPDATED in place and moves its source_book; where D-Bees is silent,
-- Canada's figure stays (the G.M.-discretion player note, groups of 3-12).
-- A complete line D-Bees restates without an item drops that item: the
-- R.C.C. skills line, the Natural Abilities line (its land navigation 70%),
-- the Allies and Enemies lines. creatures has no notes column, so each
-- Canada figure that changed is kept in description with its printed page.
-- Attribute dice, H.P., S.D.C., P.P.E., I.S.P., the combat bonus keys and
-- the sphere's laser are the same in both books, so stat_attacks is
-- untouched and the row keeps its shape (F141).
--
-- Read off renders of both books (both at PDF offset +1). Guarded on the
-- row still citing Canada, so a re-run is a no-op. THIS SCRIPT CHANGES
-- PRODUCTION: one creatures row. The tilde number is claimed at merge.

UPDATE creatures
   SET pools_note = 'P.P.E. is 3D4x10 plus 10 per level; I.S.P. is M.E. x10 plus 5 per level. Hit Points are 2D6 plus the P.E. number, and the same line adds 1D6 M.D. per level from level one (printed that way, M.D. on a Hit Point line). S.D.C. is 1D4x10 plus any from physical skills; the creature itself is not M.D.C., and its M.D.C. comes only from its vehicle, magic or body armor. Spd 2D6 is running; the sphere flies at up to 150 mph (240 km), cruising at 10-30 mph (16 to 48 km), to a maximum altitude of 60,000 feet (18,288 m), and could survive and navigate outer space; it does 60 mph (96 km) on or under water down to one mile (1.6 km). Its propulsion is silent: Prowl 60% flying or hovering, 75% trying to be unseen, 90% hidden and motionless. Sphere M.D.C.: legs (2) 12 each, main arms (2-3) 20 each, secondary limbs and tool arms (1-4) 10 each, main body 120 and -3 to strike even on a called shot; it repairs about 40 M.D.C. by itself. Sphere arms have P.S. 1D6+12, secondary limbs 1D4+5. Average NPC level 1D4+4.',
       bonuses_note = '+2 to save vs possession, +3 to save vs Horror Factor; saves vs psionics and mind control on 10 or better as a Master Psychic. All in addition to attribute and skill bonuses. Attacks per melee come from Hand to Hand training, if any, and a psionic attack uses one action. Vulnerabilities: their tiny size leaves them open to attack even from cats, dogs and birds of prey, let alone larger animals.',
       skills_note = 'R.C.C. skills, these only, with the magical and creation abilities of the Techno-Wizard O.C.C.: Anthropology (+15%), Basic Electronics (+20%), Basic Mechanics (+30%), Computer Operation (+20%), Computer Repair (+15%), Cybernetics: Basic (+10%), Field Armorer (+20%), General Repair and Maintenance (+30%), Jury-Rig (+20%), Land Navigation (+15%), Language and Literacy: Native Tongue (98%, alien), Language: Other one of choice (+10%), Math: Basic and Advanced (+20%), Navigation (+20%), Radio: Basic (+20%) and Sensory Equipment (+20%). Two related skills at levels 1, 4, 8 and 12 from Communications any, Domestic any, Mechanical any (+10%), Science any and Technical any (+10% to Research and Lore skills only). Two secondary skills at levels 3, 5, 8, 11 and 14 from the Rifts Ultimate Edition list (p.300). -35% on artificial intelligences and computers, and cannot hack.',
       natural_abilities = 'Sharp eyes, nightvision 300 feet (91.5 m), and a second eyelid that works as a polarizing filter against glare. A born mechanic: works out how nearly any machine runs, Techno-Wizard devices included, tunes one to go 10-20% faster, and strips, repairs and rebuilds at three times human speed. Builds and runs its flying sphere by its own variant of Techno-Wizardry; when the pilot dies, a failsafe burns the sphere out, releases any P.P.E. reserve and leaves a pile of junk, wires and dust. Understands all Earth languages through its own TW translator, which gives its voice an artificial radio sound; outside the sphere it speaks its own tongue in a small, squeaky voice. Its tiny size gives an automatic Prowl of 50%. Sleeps only about three hours in 24.',
       magic = 'Spells at half normal strength, range and duration: Globe of Daylight (2), Ignite Fire (6), Fuel Flame (5), Fire Bolt (7), Call Lightning (15), Energy Bolt (5), Energy Field (10), Impervious to Energy (20) and Manipulate Objects (2+), plus two of choice per level from spell levels 1-4, all suited to Techno-Wizard use and under the Techno-Wizard O.C.C.''s limits. Has all the basic Techno-Wizard O.C.C. magic powers and TW construction abilities',
       psionics = 'Effectively a Master Psychic, limited to Empathy (4), Object Read (6), Mind Bolt (varies), Telemechanics (10), Telemechanic Mental Operation (12) and Telemechanic Paralysis (20)',
       size = '1D4+8 inches (23 to 30.5 cm) tall; the sphere is about the size of a basketball',
       weight = '2-5 pounds (0.9 to 2.25 kg); the sphere 60-70 pounds (27 to 31.5 kg)',
       life_span = '4D6+50 years; physically mature by age 16',
       habitat = 'Anywhere in North America, mainly the Domain of Man where technology-based cultures abound: southern Canada, Lazlo, Michigan and the Coalition States of Iron Heart, Chi-Town and ex-State Free Quebec. Very rare, perhaps as many as 500 on Earth; groups of 3-12. A dozen have made contact with the leader of Lazlo and half a dozen with New Lazlo, and at least a hundred are exploring the Magic Zone',
       allies = 'Its own kind, Lazlo and New Lazlo. Especially likes humans, Dog Boys, Quick-Flex Aliens, Grackle Tooth, Kraks, Fingertooth Carpetbaggers, A''rac, Adna Nomads and Dewtani, and anyone with a curious mind and a good heart; a natural kinship with Operators, Rogue Scholars, Rogue Scientists, Techno-Wizards, Grackle Tooth and Psi-Techs',
       enemies = 'None as such. Finds most intelligent beings fascinating, tech-advanced ones above all, but knows demons are evil and dangerous, and hates slavers, tyrants and oppressors of any race. Fears the Minions of Splugorth, the Horune Pirates and, ironically, Faerie Folk, dragons and other creatures of magic; wary of mages other than Techno-Wizards',
       occ_note = 'Optional player character or NPC, at the G.M.''s discretion, played as innocent and inquisitive and not quite understanding humans. All are effectively a Techno-Wizard scientist or TW explorer/operator through the R.C.C. above, and use the Techno-Wizard experience table; NPCs are level 1D4+4 or as the G.M. sets, and player characters start at first or second level. They admire machines but avoid bionics for themselves. Gear, all at tiny size: clothes and two pairs of deep-pocketed overalls, boots, environmental body armor (1D6+22 M.D.C.), sleeping bag, backpack, duffle bag, portable tool kit, 50 plastic gloves and a pair of work gloves, gas mask with 2D6 air filters, tinted goggles, a portable radio and translator (10 miles/16 km), a helmet with translator, radio and loudspeaker, a hand-held computer, note pad, 1D4 pencils, a pen or marker, a comb and personal items. Their vehicle, the All-Environment Exploration Biosphere or "Eeb": 2-3 main arms, 1-2 secondary limbs, 2-4 tool arms, 1-2 light weapons, a 30 foot (9 m) tow line (500 lbs test, slower by 25% past 300 lbs), a translator at 93% through loudspeaker or radio, multi-optics, a proximity alarm at 10 feet (3 m) and a radio of 100 miles (160 km) range through which, or by psionics, it can be hailed and controlled. A destroyed sphere takes 1D4+6 months to rebuild.',
       description = 'A doll-sized humanoid, about a foot tall, with a big shield-shaped head, coal-black eyes, wavy black hair and metallic silver skin, that goes everywhere in a basketball-sized flying machine bristling with arms and tools. Their own name is Fraanids. Mortal explorers and scientists, not faeries: they came on purpose through a Rift in the ruins of Detroit some 30 years ago, came and went for 25 years, and have been trapped on Earth since the Rift shifted in the spring of 104 P.A. Their habit of taking machines apart is study, not pranks. Canada printed 149-151, which this row followed until ~219, called them creatures of magic, perhaps an otherworldly kind of faerie; gave a size of 8-12 inches, a weight of 1-2 pounds with a 40-70 pound sphere, and an unknown, perhaps immortal, life span; gave as R.C.C. skills math, basic electronics, basic mechanics, general repair and field armorer at 95%, prowl (in the sphere) and find contraband at 60%, and land navigation 70% +2% per level; listed Telekinesis where D-Bees has Manipulate Objects, with no spell or psionic costs; gave M.D.C. for two main arms and no legs on the sphere, a maximum altitude of at least 30,000 feet, and a radio with no stated range; named no O.C.C., experience table or personal gear; printed no vulnerability; said they like humans and Sasquatch and will not stay with people who are cruel, abusive or angry all the time; and did not name Lazlo, Iron Heart, Chi-Town or Free Quebec in the habitat, or the Minions of Splugorth and Horune among their fears.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.76-79'
 WHERE slug = 'faerie-bot'
   AND source_book = 'Rifts World Book 20: Canada p.149-151';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the Faerie Bot cites D-Bees and not Canada' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'faerie-bot'
   AND source_book = 'Rifts World Book 30: D-Bees of North America p.76-79';

SELECT 'the D-Bees figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'faerie-bot'
   AND life_span LIKE '4D6+50 years%'
   AND size LIKE '1D4+8 inches%'
   AND instr(magic, 'Manipulate Objects (2+)') > 0
   AND instr(pools_note, 'legs (2) 12 each') > 0;

SELECT 'it keeps the Canada figures it replaced in its description' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'faerie-bot'
   AND instr(description, 'which this row followed until ~219') > 0;

SELECT 'and its one stat_attacks row is untouched' AS assertion, count(*) AS got, 1 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature' AND owner_slug = 'faerie-bot';

INSERT INTO data_script_runs (filename) VALUES ('~219-book-ingest-audit-f143-canada-faerie-bot.sql');
