-- Experience ladders for the Rifts Ultimate Edition and Juicer Uprising
-- classes that stored none, so production ran them on the app's house-rule
-- DEFAULT_XP_TABLE (js/leveling.js).
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~008-rue-ju-xp-ladders.sql
--
-- WHAT WAS MISSING. Measured --remote 2026-09-26: 23 live published classes
-- citing Rifts Ultimate Edition and 14 citing Juicer Uprising had no
-- xp_table line (anchored on a newline, so prose does not count).
-- ~006-rue-xp-ladders.sql (#1415) took 15 of RUE's columns; this takes the
-- rest of RUE's printed 295 and every column of JU's printed 156.
--
-- READ OFF RENDERS. RUE is a scan and its cache sets printed 295's columns
-- out of order under the wrong headings (Merc level 7 reads 34301 there; the
-- page prints 31,301). JU has a text layer but its cache is one book-survey
-- names as welded. Every figure below was read from a 200 dpi render of the
-- PDF page (RUE PDF p298, JU PDF p157). Each column heading names the
-- classes it covers; a class takes the column that names it.
--
-- Stored as each band's LOWER bound, 0 first, as xp_table requires. Two
-- printed lower bounds repeat the previous band's upper bound and are stored
-- plus one - the convention fix-nb-race-xp-ladders.sql follows: JU's Dragon
-- Juicer level 11 (printed 250,000) and JU's Juicer Wannabe & Gambler level 5
-- (printed 14,100). Every other misprint is stored as printed, because the
-- printed figure is still a valid lower bound: RUE's Cyber-Doc level 11
-- (129,101 after a band ending 129,000), RUE's Techno-Wizard level 12
-- (188,001 inside a band ending 188,100), JU's Titan level 6 (25,501 inside a
-- band ending 26,500), and JU's Wannabe levels 13 and 15 (186,001 and
-- 286,001, where RUE's City Rat column the Wannabe's otherwise matches reads
-- 186,501 and 286,501).
--
-- JU's "Standard Juicer & Gladiator Juicer" column is NOT RUE's Juicer
-- column: it matches RUE's Combat Cyborg, Headhunter & Robot Pilot column
-- digit for digit. RUE's juicer class takes RUE's own Cyber-Knight, Crazy &
-- Juicer column; JU's Gladiator takes JU's column, which names it.
--
-- NOT STORED: murder-wraith. JU printed 156 lists "Murder Wraith: NPC
-- Villain" with no column, and the class's own text says its experience
-- level is frozen at the moment of death. There is no ladder to store.
--
-- ONE CLASS OUTSIDE THESE BOOKS IS TOUCHED, AND ONLY ITS copy_of LINE.
-- euro-juicer (Triax and the NGR) is a declared copy_of juicer, and
-- regression holds a copy pair equal outside its except list. Triax printed
-- 224 prints the Euro-Juicer its OWN ladder, which differs from RUE's Juicer
-- column at level 10 (96,001 against 96,101), so the two legitimately
-- differ on xp_table and the key joins the except list. Storing the Triax
-- ladder on euro-juicer is left to the Triax work.
--
-- MECHANICS. Each class's frontmatter gets one xp_table line after its single
-- "category:" line, guarded on the class having no xp_table LINE, so a re-run
-- does nothing. The ~ prefix sorts after every script that writes these
-- classes, including ~001-men-of-arms-frontmatter.sql; check with the
-- class-import sort command before renaming it.

-- RUE printed 295, "CS Grunt & Dog Boys"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-grunt'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1951, 3901, 8801, 17601, 25601, 35601, 50601, 70601, 95601, 125601, 175601, 225601, 275601, 325601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'dog-boy'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "CS SAMAS Pilot & Body Fixer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-samas-pilot'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'body-fixer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Merc Soldier"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1931, 3861, 7721, 15201, 21301, 31301, 41601, 53301, 73601, 103301, 140001, 190001, 240001, 290001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'merc-soldier'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Burster, Psi-Stalker & Mystic"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wild-psi-stalker'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "CS Technical Officer, CS Military Specialist & Shifter"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'coalition-technical-officer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2121, 4241, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'shifter'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Elemental Fusionist"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-earth-air'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'elemental-fusionist-fire-water'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Cyber-Doc, Rogue Scholar & Rogue Scientist"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129101, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-doc'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129101, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rogue-scholar'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129101, 179101, 229201, 279301, 329401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'rogue-scientist'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Techno-Wizard"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 71801, 96901, 137001, 188001, 229201, 279301, 340401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'techno-wizard'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Cyber-Knight, Crazy & Juicer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'cyber-knight'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'crazy'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Combat Cyborg, Headhunter & Robot Pilot"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'combat-cyborg'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'headhunter-techno-warrior'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'robot-pilot'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Glitter Boy Pilot"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2151, 4301, 8401, 17501, 25601, 35701, 52801, 72901, 98501, 132501, 183501, 235001, 285001, 345001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'glitter-boy'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- RUE printed 295, "Operator, Wilderness Scout"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'operator'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'wilderness-scout'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Standard Juicer & Gladiator Juicer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2141, 4281, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-gladiator'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Juicer Scout"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2181, 4381, 8501, 18201, 26401, 36801, 52001, 72201, 97401, 132601, 183801, 234001, 284201, 344401]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-scout'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Titan, Hyperion, Delphi, Phaeton Juicer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2251, 4501, 9001, 18001, 25501, 36001, 52001, 75001, 100001, 140001, 200001, 260001, 320001, 400001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'titan-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2251, 4501, 9001, 18001, 25501, 36001, 52001, 75001, 100001, 140001, 200001, 260001, 320001, 400001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'hyperion-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2251, 4501, 9001, 18001, 25501, 36001, 52001, 75001, 100001, 140001, 200001, 260001, 320001, 400001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'delphi-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2251, 4501, 9001, 18001, 25501, 36001, 52001, 75001, 100001, 140001, 200001, 260001, 320001, 400001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'phaeton-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Psycho-Stalker, Juicer Assassin, Coalition Juicer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2201, 4401, 8901, 17001, 25001, 35001, 51001, 75001, 100001, 150001, 200001, 250001, 325001, 400001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'psycho-stalker'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2201, 4401, 8901, 17001, 25001, 35001, 51001, 75001, 100001, 150001, 200001, 250001, 325001, 400001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-assassin'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Mega-Juicer, Maxi-Killer"
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2601, 5001, 10001, 20001, 30001, 49001, 62001, 80001, 110001, 150001, 200001, 250001, 310001, 370001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'mega-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 2601, 5001, 10001, 20001, 30001, 49001, 62001, 80001, 110001, 150001, 200001, 250001, 310001, 370001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'maxi-killer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Dragon Juicer" (level 11 printed 250,000, stored 250,001)
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 250001, 325001, 400001, 525001, 650001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'dragon-juicer'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- JU printed 156, "Juicer Wannabe, and Gambler" (level 5 printed 14,100, stored 14,101)
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186001, 236501, 286001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'juicer-wannabe'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;
UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'category: occ' || char(10),
         char(10) || 'category: occ' || char(10) || 'xp_table: [0, 1876, 3751, 7251, 14101, 21201, 31201, 41201, 51201, 71201, 101501, 136501, 186001, 236501, 286001]' || char(10)),
       updated_at = datetime('now')
 WHERE class_id = 'gambler'
   AND instr(markdown, char(10) || 'xp_table:') = 0
   AND instr(markdown, char(10) || 'category: occ' || char(10)) > 0;

-- euro-juicer: Triax printed 224 prints its own ladder, so xp_table may differ.
UPDATE imported_classes
   SET markdown = replace(markdown, 'copy_of: { class: "juicer", except: ["race_restrictions", "restrictions", "skills"] }',
         'copy_of: { class: "juicer", except: ["race_restrictions", "restrictions", "skills", "xp_table"] }'),
       updated_at = datetime('now')
 WHERE class_id = 'euro-juicer'
   AND instr(markdown, 'copy_of: { class: "juicer", except: ["race_restrictions", "restrictions", "skills"] }') > 0;

-- Read the result back: its own rows, plus one invariant over every class.
SELECT 'no class anywhere carries two xp_table lines' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE instr(substr(markdown, instr(markdown, char(10) || 'xp_table:') + 1), char(10) || 'xp_table:') > 0;
-- One per printed column (its first four and last bounds); together they cover all 36 classes.
SELECT 'grunt: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('coalition-grunt', 'dog-boy') AND instr(markdown, 'xp_table: [0, 1951, 3901, 8801,') > 0 AND instr(markdown, ', 325601]') > 0;
SELECT 'samas: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('coalition-samas-pilot', 'body-fixer') AND instr(markdown, 'xp_table: [0, 1926, 3851, 7451,') > 0 AND instr(markdown, ', 289001]') > 0;
SELECT 'merc: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('merc-soldier') AND instr(markdown, 'xp_table: [0, 1931, 3861, 7721,') > 0 AND instr(markdown, ', 290001]') > 0;
SELECT 'mystic: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('wild-psi-stalker') AND instr(markdown, 'xp_table: [0, 2051, 4101, 8251,') > 0 AND instr(markdown, ', 340501]') > 0;
SELECT 'cstech: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('coalition-technical-officer', 'shifter') AND instr(markdown, 'xp_table: [0, 2121, 4241, 8481,') > 0 AND instr(markdown, ', 329961]') > 0;
SELECT 'fusion: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('elemental-fusionist-earth-air', 'elemental-fusionist-fire-water') AND instr(markdown, 'xp_table: [0, 2241, 4481, 8961,') > 0 AND instr(markdown, ', 335921]') > 0;
SELECT 'cyberdoc: 3' AS assertion, count(*) AS got, 3 AS want FROM imported_classes WHERE class_id IN ('cyber-doc', 'rogue-scholar', 'rogue-scientist') AND instr(markdown, 'xp_table: [0, 2001, 4001, 8201,') > 0 AND instr(markdown, ', 329401]') > 0;
SELECT 'tw: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('techno-wizard') AND instr(markdown, 'xp_table: [0, 2301, 4601, 9201,') > 0 AND instr(markdown, ', 340401]') > 0;
SELECT 'ck: 3' AS assertion, count(*) AS got, 3 AS want FROM imported_classes WHERE class_id IN ('cyber-knight', 'crazy', 'juicer') AND instr(markdown, 'xp_table: [0, 2141, 4281, 8561,') > 0 AND instr(markdown, ', 341601]') > 0;
SELECT 'cyborg: 3' AS assertion, count(*) AS got, 3 AS want FROM imported_classes WHERE class_id IN ('combat-cyborg', 'headhunter-techno-warrior', 'robot-pilot') AND instr(markdown, 'xp_table: [0, 2101, 4201, 8401,') > 0 AND instr(markdown, ', 342401]') > 0;
SELECT 'gb: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('glitter-boy') AND instr(markdown, 'xp_table: [0, 2151, 4301, 8401,') > 0 AND instr(markdown, ', 345001]') > 0;
SELECT 'op: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('operator', 'wilderness-scout') AND instr(markdown, 'xp_table: [0, 1901, 3801, 7301,') > 0 AND instr(markdown, ', 288001]') > 0;
SELECT 'justd: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('juicer-gladiator') AND instr(markdown, 'xp_table: [0, 2141, 4281, 8401,') > 0 AND instr(markdown, ', 342401]') > 0;
SELECT 'juscout: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('juicer-scout') AND instr(markdown, 'xp_table: [0, 2181, 4381, 8501,') > 0 AND instr(markdown, ', 344401]') > 0;
SELECT 'titan: 4' AS assertion, count(*) AS got, 4 AS want FROM imported_classes WHERE class_id IN ('titan-juicer', 'hyperion-juicer', 'delphi-juicer', 'phaeton-juicer') AND instr(markdown, 'xp_table: [0, 2251, 4501, 9001,') > 0 AND instr(markdown, ', 400001]') > 0;
SELECT 'psycho: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('psycho-stalker', 'juicer-assassin') AND instr(markdown, 'xp_table: [0, 2201, 4401, 8901,') > 0 AND instr(markdown, ', 400001]') > 0;
SELECT 'mega: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('mega-juicer', 'maxi-killer') AND instr(markdown, 'xp_table: [0, 2601, 5001, 10001,') > 0 AND instr(markdown, ', 370001]') > 0;
SELECT 'dragon: 1' AS assertion, count(*) AS got, 1 AS want FROM imported_classes WHERE class_id IN ('dragon-juicer') AND instr(markdown, 'xp_table: [0, 3001, 5001, 10001,') > 0 AND instr(markdown, ', 650001]') > 0;
SELECT 'wannabe: 2' AS assertion, count(*) AS got, 2 AS want FROM imported_classes WHERE class_id IN ('juicer-wannabe', 'gambler') AND instr(markdown, 'xp_table: [0, 1876, 3751, 7251,') > 0 AND instr(markdown, ', 286001]') > 0;
SELECT 'the Murder-Wraith stays without a ladder' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id = 'murder-wraith' AND instr(markdown, char(10) || 'xp_table:') > 0;
SELECT 'euro-juicer excepts xp_table from its copy pair' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'euro-juicer' AND instr(markdown, '"skills", "xp_table"] }') > 0;

INSERT INTO data_script_runs (filename) VALUES ('~008-rue-ju-xp-ladders.sql');
