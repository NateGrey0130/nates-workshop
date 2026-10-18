-- Reprinted D-Bees races' creature rows follow D-Bees of North America
-- (BOOK-INGEST-AUDIT F143, row 38c: New West, Atlantis, Underseas and
-- South America).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~232-book-ingest-audit-f143-four-books.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~232-book-ingest-audit-f143-four-books.sql
--
-- The classes cactus-people and fennodi follow Rifts World Book 30: D-Bees
-- of North America (2007), but their creatures rows still cited Rifts World
-- Book 14: New West and carried its figures. By Nate's ruling of 2026-10-04
-- the newest printing that STATES a figure wins, so each row is UPDATED in
-- place and moves its source_book to the pages its class cites; where D-Bees
-- is silent, New West's figure stays. A complete line D-Bees restates
-- without an item drops that item (the importing session's line rule of
-- 2026-10-04). creatures has no notes column, so each New West figure that
-- changed is kept in description with its printed page.
--
-- Cactus People: D-Bees' Attacks per Melee line ("as per Hand to Hand") is
-- read as restating New West's Combat line without its two attacks for the
-- untrained, so combat loses attacks 2 and gains D-Bees' +1 roll with
-- impact. Fennodi: Nodox gives three attacks at first level where New West
-- gave two; the other combat keys are the same in both books.
--
-- Read off renders of D-Bees and New West's text layer (both at PDF offset
-- +1). Guarded on each row still citing New West, so a re-run is a no-op.
-- THIS SCRIPT CHANGES PRODUCTION. The tilde number is claimed at merge.

UPDATE creatures
   SET alignment = 'Any, but generally Principled (50%), Scrupulous (20%), Unprincipled (10%) and Anarchist (10%)',
       attributes = '{"IQ":"2D6+4","ME":"2D6+8","MA":"2D6+2","PS":"2D6+6","PP":"2D6+6","PE":"2D6+6","PB":"2D6","Spd":"2D6+2"}',
       combat = '{"roll":1}',
       bonuses_note = 'Horror Factor prints as 9+1D4 (base 9 stored; +1D4 residual not captured in horror_factor). +1 to roll with impact, +3 to save vs disease, +2 to save vs possession, impervious to the bite and charms of the vampire, and resistant to heat and cold, functioning in temperatures from 120 degrees Fahrenheit down to zero; all in addition to attribute and skill bonuses. Attacks per melee are those of the Hand to Hand skill. Hand to Hand: Basic can be changed to Expert for the cost of two R.C.C. Related Skills; no other combat choice is available. Vulnerabilities: the value of their life fluid, shyness and lack of aggression.',
       skills_note = 'Communicate via telepathy and empathy; Botany +15%, Brewing +15%, Brewing: Medicinal +10%, Lore (two of choice) +15%, Holistic Medicine +15% (Cactus People only), Identify Fruit and Plants +20%, Land Navigation +15%, Math: Basic +20%, Preserve Food +15%, Wilderness Survival +15%, two Physical skills of choice except Acrobatics and SCUBA, two W.P.s of choice (any), Hand to Hand Basic; six R.C.C. Related Skills at level 1; two Secondary Skills from the Rifts Ultimate Edition list at levels 1, 4, 8 and 12.',
       natural_abilities = 'Keen vision that sees the ultraviolet spectrum and is not bothered by glare or bright light; heals 2D6 Hit Points or S.D.C. per day of sunlight (1D4 if cloudy or in darkness); survives up to a week without food or water; minor psionics. Like a plant, a lost hand, foot, limb or even part of the body or head grows back in 1D4+3 weeks, and they feel less pain than humans, though they do feel some and fear death.',
       magic = 'None',
       psionics = 'Minor psionics: Empathy (4), See Aura (6), See Invisible (4) and a special Telepathy at no I.S.P. cost that reaches other species up to 200 feet (61 m) away and their own race up to 600 feet (183 m) +50 feet (15.2 m) per level of experience',
       size = '4-6 feet (1.2 to 1.8 m)',
       weight = '70-150 lbs (31.5 to 67.5 kg)',
       life_span = '2D6+50 years; one or two young as often as once every 18 months, grown as a bulb on the female that drops off after 7 months; physically mature by age 18',
       habitat = 'The plains of the New West, including southwestern Canada and Mexico; they live off the land or on small farms, often near pre-Rifts ruins, abandoned vehicles, caves or canyons, in shacks, tents, teepees or mobile homes',
       allies = 'Fennodi; N''reta; Lyn-Srial; Cyber-Knights; most Native Americans; Elemental Fusionists',
       enemies = 'Worm Wraiths; Brodkil; demons; slavers; evil humanoids; wary of other plant and insect people; dislike the Simvan, who harass them',
       occ_note = 'R.C.C. only; no O.C.C. is available. NPCs are level 1D6 or as the G.M. sets, and player characters start at level one, on the race''s own experience table (D-Bees printed 44). Gear: a set or two of clothing, light body armor for combat, portable tool kit, survival knife, cigarette lighter, pocket mirror, 50 feet (15.2 m) of lightweight rope, utility belt, a pack or saddlebags, a shoulder bag and containers for fresh food, a canteen or water skin, a Vibro-Blade and two weapons of choice. Little need for money, but they buy, sell and trade for tools, weapons and gear. Bionics are not applicable.',
       description = 'Small, plant-based D-bee vegetarians with mild natural psionics and nutritious, slow-spoiling life fluid that draws predatory slavers and sorcerers. New West printed 127, which this row followed until ~232, gave alignment as Any but generally good or selfish, P.B. 2D6+2, size 5 feet (1.5 m), weight 150 lbs (90 kg), a life span of 60 years and two attacks per melee round for those without combat training; it carried the +3 vs disease among the natural abilities and printed no other bonus, no vulnerabilities, no I.S.P. costs, no habitat line and no limb regrowth; its R.C.C. skills lacked Brewing, Brewing: Medicinal and Preserve Food and limited no Physical skill, its Secondary Skills came at levels 1, 4, 8, 10 and 12, and it named the Fennodi, Lyn-Srial and Cyber-Knights as allies and other humanoids and slavers as enemies.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.41-44'
 WHERE slug = 'cactus-people'
   AND source_book = 'Rifts World Book 14: New West p.127';

UPDATE creatures
   SET combat = '{"attacks":3,"initiative":1,"parry":1,"dodge":1,"pull":6,"disarm":4,"roll":2}',
       bonuses_note = 'Hand to Hand: Nodox (special), the alien art of avoidance and defense every Fennodi knows: three attacks per melee at first level, +1 at levels 2, 4, 6, 8, 10, 12 and 14; +1 on initiative, +4 to disarm, +6 to pull punch, body flip and +2 to roll with impact are flat; +1 to parry at levels 1, 3, 6, 9, 12 and 15; +1 to dodge at levels 1, 2, 4, 6, 8, 10, 12 and 14; +1 to save vs Horror Factor at levels 1, 3, 6, 9, 12 and 15. Pin or incapacitate on a roll of 17-20 (must announce intent). Generally fights only to escape or restrain; rarely kills. Vulnerabilities: they do not handle cold climates well and are sometimes too trusting of strangers.',
       skills_note = 'R.C.C. skills regardless of O.C.C.: Land Navigation +20%, Prowl +15%, Wilderness Survival +25%, W.P. Staff.',
       natural_abilities = 'Keen 280 degree peripheral vision that sees the infrared spectrum, plus 2 vs disease and toxins, immune to carcinogens and cancer, silent gliding movement, innate psionics that differ by sex.',
       psionics = 'Males: Base I.S.P. M.E. x2 +2D6 per level; Empathy (4), Empathic Transmission (6), Mind Block (4), Sixth Sense (2), Telepathy (4) and two Healing abilities of choice, plus one more Healing power at levels 2, 4, 6, 8, 10 and 12. Females: Base I.S.P. M.E. x3 +2D6 per level; Bio-Manipulation (10), Empathy (4), Mind Block (4), Sixth Sense (2), Telepathy (4) and three Physical powers of choice, plus one more Physical power at levels 2, 4, 6, 8, 10 and 12. Both have a psychic affinity with the Whisker Coyote and two unique powers: a Protective Energy Aura (16 M.D.C. +1D4 per level, engaged by reflex, regenerating 2D6 M.D.C. per melee round) and Ghost Walk (a partial phase-out of physical reality, impervious to the physical plane but open to attack from the Astral Plane; two melee actions and 20% walking speed; self only; five minutes per level; I.S.P. 10).',
       life_span = '4D6+55 years; physically mature at 16; females bear one child after an eight-month pregnancy and can bear children until age 45',
       habitat = 'Prefer warm, dry climates: the deserts and plains of the American Southwest, including Nevada, Utah, Arizona, New Mexico, Lone Star/Texas and Northern Mexico, tending livestock as nomads; they love the wilderness (light forests, grasslands, prairies, canyons and deserts) and visit towns and cities only briefly. Some travel into the Canadian Southwest, but most migrate south for the winter',
       allies = 'All cowboys; most Native Americans; Lyn-Srial; Cyber-Knights; Reid''s Rangers; Avianes; N''reta; Cactus People; they welcome all who come in peace, even Wild Psi-Stalkers',
       enemies = 'Wild Psi-Stalkers, Worm Wraiths, bandits, vampires and supernatural menaces; Simvan threaten them but come only to trade; dinosaurs and other animals',
       occ_note = 'A third are Cowboys and 20% Saddle Tramps, but any Vagabond, Rogue Scholar, Rogue Scientist, Body-Fixer, Operator, Preacher, Wilderness Scout, or Adventurer and Scholar O.C.C. is open; they never study the mystic arts, though they use magic items. NPCs are level 2D4 or as the G.M. sets, player characters start at level one, and the chosen O.C.C.''s experience table is used. Gear per O.C.C., plus a Nymbu staff, smoking pipe, tobacco pouch, small knife, belt with a wide buckle and cowboy hat. Cybernetics and bionics are not possible.',
       description = 'Tall, quiet, peaceful nomadic D-bee herders known as the Quiet Walkers, gifted with sex-specific healing psionics and a defensive phase-out ability. New West printed 128-130, which this row followed until ~232, gave two attacks per melee round at first level, no life span, W.P. Blunt/Staff, most (50%) as 3rd to 6th level (1D4+2) Cowboys or Saddle Tramps with Saloon Bum among the other O.C.C.s, three healing abilities for males, no I.S.P. costs, a habitat throughout the West but far less common in the Canadian Wilderness, allies Cowboys, Saddle Tramps, Indians, Cyber-Knights and Sky-Knights, and enemies bandits, Psi-Stalkers and supernatural menaces; it printed no vulnerabilities, and its equipment line carried a Whisker Coyote pet that D-Bees restates without.',
       source_book = 'Rifts World Book 30: D-Bees of North America p.83-85'
 WHERE slug = 'fennodi'
   AND source_book = 'Rifts World Book 14: New West p.128-130';

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the two New West rows cite D-Bees' AS assertion, count(*) AS got, 2 AS want
  FROM creatures
 WHERE (slug = 'cactus-people' AND source_book = 'Rifts World Book 30: D-Bees of North America p.41-44')
    OR (slug = 'fennodi' AND source_book = 'Rifts World Book 30: D-Bees of North America p.83-85');

SELECT 'the Cactus People figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'cactus-people'
   AND instr(attributes, '"PB":"2D6"') > 0
   AND combat = '{"roll":1}'
   AND life_span LIKE '2D6+50 years%'
   AND size = '4-6 feet (1.2 to 1.8 m)'
   AND instr(description, 'which this row followed until ~232') > 0;

SELECT 'the Fennodi figures landed' AS assertion, count(*) AS got, 1 AS want
  FROM creatures
 WHERE slug = 'fennodi'
   AND combat = '{"attacks":3,"initiative":1,"parry":1,"dodge":1,"pull":6,"disarm":4,"roll":2}'
   AND life_span LIKE '4D6+55 years%'
   AND instr(description, 'which this row followed until ~232') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~232-book-ingest-audit-f143-four-books.sql');
