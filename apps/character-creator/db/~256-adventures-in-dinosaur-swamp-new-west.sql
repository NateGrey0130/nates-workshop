-- The seven New West creatures that Adventures in Dinosaur Swamp reprints
-- take that book's figures where it states a different one (plan
-- book-imports-2026-10-20, row 5d).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~256-adventures-in-dinosaur-swamp-new-west.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~256-adventures-in-dinosaur-swamp-new-west.sql
--
-- Rifts World Book 27: Adventures in Dinosaur Swamp (2005) reprints the
-- Devil Unicorn, Duckbilled Honker, Leatherwing, Panthera-Tereon, Tiger Claw
-- Raptor, Tri-Tops and Tyrannosaurus Rex with full stat blocks. Each was
-- compared line by line, and its stat_attacks row by row, with the held row
-- as production carried it on 2026-10-20, and with New West's own text
-- layer, so a difference between the printings is told apart from a line
-- the held row never carried. By Nate's ruling of 2026-10-04 the newest
-- printing that STATES a figure wins, and where it is silent the held
-- figure stays; a complete line Dinosaur Swamp restates without an item
-- drops that item (the line rule ~232 applied). All seven rows change.
-- source_book stays New West: the rows are New West's, and Dinosaur Swamp's
-- pages are cited in each description beside the old figures, because
-- creatures has no notes column.
--
-- Lines the held rows do not carry at all (Value, an Allies line printed as
-- None, the called-shot asterisks) are not compared. Every figure that
-- differs was read off a render of Dinosaur Swamp at PDF offset +1.
--
-- Guarded on each row's description not yet citing Dinosaur Swamp, so a
-- re-run is a no-op. THIS SCRIPT CHANGES PRODUCTION. The tilde number is
-- claimed at merge.

UPDATE creatures
   SET combat = '{"attacks":5,"perception":1,"initiative":3,"strike":3,"parry":1,"dodge":3,"pull":6,"roll":4}',
       habitat = 'Forests and mountain areas with lakes and waterways near people it can torment, though it can turn up anywhere; only a few hundred to a thousand are believed to live on the American continents, most commonly reported in the Canadian Southwest, American Northwest, Wyoming, Colorado, Wisconsin, Michigan and the Magic Zone, and in Dinosaur Swamp in the forests of Georgia and the Appalachian Mountains',
       description = description || ' Adventures in Dinosaur Swamp printed 35-36 reprints it, and by ~256 its figures win: +1 on Perception Rolls and a habitat that reaches Dinosaur Swamp. New West printed 140-141, which this row cites, gave no Perception bonus and named no range east of Michigan and the Magic Zone. Every other line the row holds is the same in both printings.'
 WHERE slug = 'devil-unicorn'
   AND source_book = 'Rifts World Book 14: New West p.140-141'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE creatures
   SET attributes = '{"ME":"1D6","MA":"2D6","PS":"20+1D6","PP":"14+1D6","PE":"18+1D6","PB":"2D6+3","Spd":"3D6+35 min 38"}',
       habitat = 'Woodlands and scrub plains; in Dinosaur Swamp mainly Georgia, the Carolinas and the mountain valleys and lowlands of the Appalachians, but most common out West, where millions live between the Rocky Mountains and the Mississippi River, especially Oregon, eastern Wyoming, Nebraska, Missouri, Kansas, Oklahoma, Arkansas and parts of Texas/Lone Star',
       description = description || ' Adventures in Dinosaur Swamp printed 36-37 reprints it, and by ~256 its figures win: speed 3D6+35 and a habitat that adds Dinosaur Swamp and puts millions out West. New West printed 141-143, which this row cites, gave speed 34+3D6 (both state a minimum of 38) and a habitat of over a million in the Central states, with fewer in the East. Every other line the row holds is the same in both printings.'
 WHERE slug = 'duckbilled-honker'
   AND source_book = 'Rifts World Book 14: New West p.141-143'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE creatures
   SET alignment = 'Animal predator, considered anarchist or miscreant',
       mdc = '1D4x100+PE',
       pools_note = 'Ground/climbing Spd is 3D6+6; flying Spd is 50+3D6 with a minimum of 55 (37.5 mph/60 km). Supernatural P.S. and P.E. Locational M.D.C.: Head/Beak 100, Wing Arms (2) 120 each, Hind Legs (2) 130 each, Wing Membrane (2) 38 each; Main Body 1D4x100 plus the P.E. attribute number. On S.D.C. worlds the main body is 5D6x10 H.P. and 4D6x10 S.D.C., A.R. 12.',
       enemies = 'Humans; D-bees; pack dinosaurs',
       habitat = 'Mountains and forests, hunting many miles out to sea; at least two million in the New West, roosting along the Rocky Mountains, and fewer in the East, roosting in the peaks of the Appalachians and the Great Stone Mountains of Atlantis, some flying between the coasts of North America and Atlantis; flocks of hundreds or thousands, though each hunts alone',
       description = description || ' Adventures in Dinosaur Swamp printed 45-47 reprints it, and by ~256 its figures win: Wing Membrane 38 M.D.C. each, a Main Body of 1D4x100 plus the P.E. attribute number, alignment anarchist or miscreant, humans, D-Bees and pack dinosaurs as its enemies, and a habitat reaching the Appalachians and Atlantis. New West printed 148-149, which this row cites, gave Wing Membrane 130 each, a Main Body of 1D4x100, alignment anarchist or evil, Grigleapers and the Panthera-Tereon among its enemies too, and a habitat of the cliffs, buttes and summits of Arizona, Utah, Nevada, New Mexico and the Rockies in flocks of up to 50,000. Every other line the row holds is the same in both printings.'
 WHERE slug = 'leatherwing'
   AND source_book = 'Rifts World Book 14: New West p.148-149'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE creatures
   SET pools_note = 'Supernatural P.S. and P.E.; minimum speed of 23 (15 mph/24 km). On S.D.C. worlds, Main Body is 2D4x10 H.P. plus the P.E. attribute number and 1D4x10 S.D.C., A.R. 11.',
       enemies = 'Large predators; humanoids; loathes Grigleapers and dislikes Tree Prowlers',
       habitat = 'Mountains and the ruins of skyscrapers and tall buildings throughout the Eastern seaboard, the Appalachian Mountains and the New West',
       description = description || ' Adventures in Dinosaur Swamp printed 48-49 reprints it, naming it also the Everglades Lion and Demon Mountain Lion, and by ~256 its figures win: the P.E. attribute number added to its Hit Points on S.D.C. worlds, the Tree Prowler among its enemies, and a habitat of the Eastern seaboard, the Appalachians and the New West. New West printed 155-156, which this row cites, gave 2D4x10 Hit Points, no Tree Prowler, and a habitat of the Rockies and western ruins, especially Colorado, Idaho, Wyoming, Montana, Oregon, Washington and Alberta, plus the canyons and mountains of Arizona and Utah. Every other line the row holds is the same in both printings.'
 WHERE slug = 'panthera-tereon'
   AND source_book = 'Rifts World Book 14: New West p.155-156'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE creatures
   SET attributes = '{"IQ":"1D6+7","ME":"10+1D6","MA":"2D6","PS":"19+1D6","PP":"19+1D6","PE":"19+1D6","PB":"2D6+4","Spd":"44+2D6"}',
       pools_note = 'Mega-Damage by location: Head 70; Forearms (2) 3D6+12 each; Hind Legs (2) 4D6+40 each; Tail 3D6+20; Main Body 6D6+34. On S.D.C. worlds: 4D6+20 Hit Points, 3D6 plus the P.E. attribute number S.D.C., A.R. 9. Females are 20% larger and have 20 more M.D.C. than males. Average speed 50 (35 mph/56 km). Horror Factor 9 for one, 12 for a pack of 4-8, 14 for 9-13, 16 for 14 or more.',
       combat = '{"attacks":4,"perception":2,"initiative":4,"strike":2,"parry":2,"dodge":3}',
       bonuses_note = '+6 to save vs horror factor, fearless in large packs. Four attacks per melee for males, five for females.',
       natural_abilities = 'Runs tirelessly for 8 hours; leaps 15 ft high and 20 ft long; survives two weeks without food or water; smells blood a mile (1.6 km) off and tracks a blood scent 85%; tracks animals and humanoids by scent and vision 65%, prowls 86%, detects ambush 76%, climbs 75%/25%; spits blinding poison up to 20 feet.; vulnerable: cannot swim, and tends to underestimate humanoid foes',
       enemies = 'Other predators and humanoids; preys on herbivores, livestock and any animal or humanoid that looks vulnerable',
       habitat = 'Highly adaptable, from the deserts, prairies and forests of the West to the swamps, forests and ruins of the East; dislikes cold climates and mountains. Found throughout the South, including Kansas, Arkansas, Mississippi and Alabama; in the East most numerous in Louisiana and Florida and seldom north of Georgia, with a few isolated bands on the North Carolina coast and small summer bands of 1D4+2 reaching Pennsylvania, southern Michigan and the Magic Zone',
       description = description || ' Adventures in Dinosaur Swamp printed 59-60 reprints it with fuller figures, which ~256 takes: I.Q. 1D6+7, M.D.C. by location (Head 70, Forearms 3D6+12, Hind Legs 4D6+40, Tail 3D6+20), 3D6 plus P.E. S.D.C. on S.D.C. worlds, Horror Factor 14 for a pack of 9-13 and 16 for 14 or more, blood-scent tracking 85%, five attacks and harder-hitting bite, feet, tail and fore-claws for females, +2 on Perception Rolls, prey named among its enemies, and a habitat centred on the South and Southeast. New West printed 162-163, which this row cites, gave no I.Q. dice, a Main Body only, 3D6+12 S.D.C., Horror Factor 14 for any pack of 10 or more, blood-scent tracking 65%, four attacks for both sexes, no Perception bonus, and a habitat most common in Arizona, New Mexico, Lone Star, Oklahoma, Colorado, Kansas, Nebraska and the southeastern territories. Every other line the row holds is the same in both printings.'
 WHERE slug = 'tiger-claw-raptor'
   AND source_book = 'Rifts World Book 14: New West p.162-163'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE creatures
   SET attributes = '{"IQ":"1D4+4","ME":"1D6+6","MA":"2D6+6","PS":"28+2D6","PP":"14+1D6","PE":"18+1D6","PB":"2D6+6","Spd":"34+3D6 min 38"}',
       pools_note = 'On S.D.C. worlds: 100+3D6x10 Hit Points, 4D6x10 S.D.C., A.R. 13. Mega-Damage by location: Head 200; Horns (3) 60 each; Front Legs (2) 110 each; Hind Legs (2) 160 each; Underbelly 120. Minimum speed 38 (26 mph/41.6 km), most have speed 40-44 (about 30 mph/48 km). Supernatural P.S. and P.E.',
       allies = 'None as such; gathers with its own kind in grazing herds',
       habitat = 'Woodlands and scrub plains; fewer than 20,000 in the Dinosaur Swamp region, mostly in the wooded parts of Georgia and North Carolina, and easily 1-2 million out West',
       description = description || ' Adventures in Dinosaur Swamp printed 64 reprints it, and by ~256 its figures win: I.Q. 1D4+4, P.B. 2D6+6, Supernatural P.S. and P.E., a running ram with a 01-70% chance (01-40% against larger foes) of knocking down an opponent up to 20 feet tall, costing it two attacks and initiative, its own herds as its only allies, and a habitat of fewer than 20,000 in Dinosaur Swamp and 1-2 million out West. New West printed 164-166, which this row cites, gave no I.Q. dice, P.B. 3D6, no Supernatural strength, a ram that throws foes up to Ostrosaurus size 4D4 yards with no knockdown roll, allies none, and a habitat of over a million between the Rockies and the Mississippi, particularly Washington, Oregon, Montana, Idaho, Wyoming, Colorado, the Dakotas, Minnesota, Nebraska, Kansas and parts of Canada. Every other line the row holds is the same in both printings.'
 WHERE slug = 'tri-tops'
   AND source_book = 'Rifts World Book 14: New West p.164-166'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

UPDATE creatures
   SET horror_factor = NULL,
       combat = '{"attacks":5,"initiative":3,"strike":2,"roll":2}',
       habitat = 'Throughout the Dinosaur Swamp region, preferring forests and mountain lowlands; also the New West and southwestern Canada, most numerous out West in Montana, Idaho and Wyoming',
       description = description || ' Adventures in Dinosaur Swamp printed 66 reprints it, and by ~256 its figures win: Horror Factor none, five attacks per melee, and a habitat across Dinosaur Swamp as well as the West. New West printed 166-167, which this row cites, gave Horror Factor 18, four attacks, and a habitat in the New West and southwestern Canada only. Every other line the row holds is the same in both printings.'
 WHERE slug = 'tyrannosaurus-rex'
   AND source_book = 'Rifts World Book 14: New West p.166-167'
   AND instr(description, 'Adventures in Dinosaur Swamp printed') = 0;

-- The attacks Dinosaur Swamp prints differently. A note is only ever added
-- to, never replaced, so the guard is the note not yet citing the book.

UPDATE stat_attacks
   SET note = 'females +4 M.D. (Adventures in Dinosaur Swamp printed 60; New West printed 163 gave no female bonus)'
 WHERE owner_kind = 'creature' AND owner_slug = 'tiger-claw-raptor' AND name = 'Bite'
   AND note IS NULL;

UPDATE stat_attacks
   SET note = 'females +1D6 M.D. (Adventures in Dinosaur Swamp printed 60; New West printed 163 gave no female bonus)'
 WHERE owner_kind = 'creature' AND owner_slug = 'tiger-claw-raptor' AND name = 'Clawed Feet'
   AND note IS NULL;

UPDATE stat_attacks
   SET note = 'females do 1D4 M.D. instead (Adventures in Dinosaur Swamp printed 60; New West printed 163 gave no female figure)'
 WHERE owner_kind = 'creature' AND owner_slug = 'tiger-claw-raptor' AND name = 'Tail Slash'
   AND note IS NULL;

UPDATE stat_attacks
   SET note = 'females do 1D6 M.D. instead (Adventures in Dinosaur Swamp printed 60; New West printed 163 gave no female figure)'
 WHERE owner_kind = 'creature' AND owner_slug = 'tiger-claw-raptor' AND name = 'Small Fore Claws'
   AND note IS NULL;

UPDATE stat_attacks
   SET note = 'Counts as two melee attacks; 01-70% chance of knocking an opponent up to 20 feet (6.1 m) tall off its feet (01-40% against larger foes), costing it two melee attacks and initiative; opponents up to about 10 feet (3 m) tall are thrown 4D4 yards; armored humans must save vs coma/death or take 5D6 damage, break 1D4 ribs, and be knocked out 1D4x10 minutes. Adventures in Dinosaur Swamp printed 64; New West printed 165 gave no knockdown roll and threw human to Ostrosaurus-sized foes 4D4 yards.'
 WHERE owner_kind = 'creature' AND owner_slug = 'tri-tops' AND name = 'Running Head/Horn Ram'
   AND instr(note, 'Adventures in Dinosaur Swamp') = 0;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'the seven rows carry the Dinosaur Swamp note and still cite New West' AS assertion, count(*) AS got, 7 AS want
  FROM creatures
 WHERE slug IN ('devil-unicorn', 'duckbilled-honker', 'leatherwing', 'panthera-tereon', 'tiger-claw-raptor', 'tri-tops', 'tyrannosaurus-rex')
   AND instr(description, 'Adventures in Dinosaur Swamp printed') > 0
   AND instr(description, '~256') > 0
   AND source_book LIKE 'Rifts World Book 14: New West p.%';

SELECT 'the figures landed' AS assertion, count(*) AS got, 7 AS want
  FROM creatures
 WHERE (slug = 'devil-unicorn' AND instr(combat, '"perception":1') > 0 AND instr(habitat, 'Georgia') > 0)
    OR (slug = 'duckbilled-honker' AND instr(attributes, '"Spd":"3D6+35 min 38"') > 0)
    OR (slug = 'leatherwing' AND mdc = '1D4x100+PE' AND instr(pools_note, 'Wing Membrane (2) 38 each') > 0 AND enemies = 'Humans; D-bees; pack dinosaurs')
    OR (slug = 'panthera-tereon' AND instr(pools_note, '2D4x10 H.P. plus the P.E. attribute number') > 0 AND instr(enemies, 'Tree Prowlers') > 0)
    OR (slug = 'tiger-claw-raptor' AND instr(attributes, '"IQ":"1D6+7"') > 0 AND instr(combat, '"perception":2') > 0 AND instr(pools_note, 'Head 70') > 0 AND instr(natural_abilities, 'blood scent 85%') > 0)
    OR (slug = 'tri-tops' AND instr(attributes, '"IQ":"1D4+4"') > 0 AND instr(attributes, '"PB":"2D6+6"') > 0 AND allies LIKE 'None as such%')
    OR (slug = 'tyrannosaurus-rex' AND horror_factor IS NULL AND instr(combat, '"attacks":5') > 0);

SELECT 'the five attack notes landed' AS assertion, count(*) AS got, 5 AS want
  FROM stat_attacks
 WHERE owner_kind = 'creature'
   AND ((owner_slug = 'tiger-claw-raptor' AND name IN ('Bite', 'Clawed Feet', 'Tail Slash', 'Small Fore Claws'))
     OR (owner_slug = 'tri-tops' AND name = 'Running Head/Horn Ram'))
   AND instr(note, 'Adventures in Dinosaur Swamp printed') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~256-adventures-in-dinosaur-swamp-new-west.sql');
