-- Six Coalition War Campaign classes follow their D-Bees of North America
-- printing.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local  apps/character-creator/db/~095-d-bees-updates-six-cwc-classes.sql
--   node scripts/d1-apply.mjs --remote apps/character-creator/db/~095-d-bees-updates-six-cwc-classes.sql
--
-- Rifts World Book 30: D-Bees of North America (2007) reprints and updates
-- classes the catalog held from older books. Nate's ruling of 2026-10-04: the
-- newest printing that states a figure wins, the row keeps the older figure
-- in a note, and a D-Bees-updated class moves its source_book to D-Bees with
-- the original named in the notes. This is the first of four batches, by
-- original book: the six held from Coalition War Campaign (1996).
--
--   nmbyr-gorilla-man   D-Bees printed 143-144 (CWC 202-203)
--   tirrvol-sword-fist  D-Bees printed 201-203 (CWC 203-205)
--   quick-flex-alien    D-Bees printed 168-170 (CWC 205-206)
--   vanguard-brawler    D-Bees printed 208-210 (CWC 206-208)
--   trimadore           D-Bees printed 206-208 (CWC 208-209)
--   kremin-cyborg       D-Bees printed 111-114 (CWC 209-211)
--
-- Each class was read against BOTH books off page renders, so that a
-- difference is known to be D-Bees revising the entry (taken, with the CWC
-- figure kept in extraction_notes) and not something the held row had
-- dropped. A second reader that did not write the drafts checked every
-- figure against renders again and found no disagreement.
--
-- THREE KEEP THE SHAPE THEY HAD. D-Bees prints the Quick-Flex Alien, the
-- Vanguard Brawler and the Kremin as races that take an O.C.C., with the
-- O.C.C.'s experience table, equipment and money; the catalog holds each as
-- an R.C.C. with its own skill program and ladder. Every figure D-Bees
-- states is taken; the program and ladder Coalition War Campaign prints are
-- kept, and each class's notes say so. Converting them is a decision about
-- saved characters and is left to Nate.
--
-- Each draft reads `ready` in class-check --remote. No ability, option or
-- variant is renamed. The trimadore loses three language pick-one groups
-- D-Bees replaces; production held no saved character on any of the six
-- when this was written.
--
-- Each UPDATE is guarded on the class's old source_book line and on the
-- exact stored length (trailing newline counted), so it cannot fire against
-- a row edited since. THIS SCRIPT CHANGES PRODUCTION: six class rows. The
-- tilde number is claimed at merge.

-- == nmbyr-gorilla-man ==
UPDATE imported_classes
   SET markdown = '---
id: nmbyr-gorilla-man
name: N''mbyr Gorilla Man
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.143-144
category: rcc
tags: []
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+2"
  MA: "2d6"
  PS: "4d6+10"
  PP: "3d6"
  PE: "3d6+6"
  PB: "2d6"
  Spd: "2d6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "3d4x10"
ppe_base: "6d6"
horror_factor: 10
occ_restrictions:
  only: ["group:men-of-arms", "group:optional"]
  note: "Any Men of Arms or Adventurer O.C.C.; in each case the O.C.C. Related and Secondary skill selections are cut in half. Never a magic O.C.C. Crazy conversion does not work on this alien physiology, though the group token still offers it. Juicer augmentation is tragic: it gives all the powers of a Juicer but also 1D6 random insanities, the character cannot detox, and burns out (dies) in 1D4 years."
psionics:
  type: "major"
  isp_base: "P.E., +10 per level"
  powers_starting: 6
  categories_allowed: ["Physical"]
bonuses:
  combat: { strike: 1, parry: 1, pull_punch: 2, damage_bonus: 4 }
  saves: { horror_factor: 1, harmful_drugs: -6 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "N''mbyr at 95%." }
    - { name: "Wrestling", base: 0, per_level: 0 }
    - { name: "Physical Labor", base: 0, per_level: 0 }
    - { name: "Athletics (general)", base: 0, per_level: 0 }
natural_abilities:
  - { name: "Keen Vision and Nightvision", description: "Keen vision; nightvision 120 feet (36.5 m)." }
  - { name: "Augmented P.S.", description: "P.S. is Augmented Strength; damage is as per Augmented P.S., or Supernatural P.S. during a violent outburst, or by weapon." }
special_abilities:
  - name: "Violent Outburst"
    description: "When seriously angry, embarrassed, frightened or frustrated the N''mbyr loses his temper and self-control and beats on the person or thing (computer, vehicle, machine) responsible. While it lasts: +1 attack per melee round, +2 on initiative, +1 to strike, +10 P.S., and P.S. goes from Augmented to the equivalent of a Supernatural P.S. of 1D4+21 (2D6 M.D. punch or kick, 4D6 M.D. power punch, 1 M.D. bite), +6 to save vs horror factor, +2 to save vs mind control, possession and psionic attack. Penalties: -30% on skill performance, -2 to dodge, cannot pull punches, fears nothing, and forgets its mission, its friends, its own well-being and its enhanced P.S. The race''s Horror Factor of 10 (15 to children and women) applies only while it is enraged."
  - name: "Eruptor"
    description: "20% of N''mbyr are Psychic Eruptors, considered Master Psychics: instead of the usual allowance they hold 1D4+1 Physical powers of choice plus ONE Super power from Electrokinesis, Hydrokinesis, Pyrokinesis, Telekinesis (Super) or Telekinetic Force Field, and those powers have double the normal range and duration and +1D6 M.D. damage. Eruptor I.S.P. is P.E. x3, +10 per level of experience starting with level one, and an Eruptor gets no additional psionic abilities as it advances in level. Rolled at creation; the G.M. adjusts the psionic picks and I.S.P. by hand."
restrictions:
  - "Needs an O.C.C.: the R.C.C. skills are in addition to O.C.C. skills."
  - "O.C.C. Related and Secondary skill selections are reduced by half; apply by hand."
  - "Crazy conversion does not work on this race."
  - "Juicer augmentation: all the powers of a Juicer, plus 1D6 random insanities (Rifts Ultimate Edition p.332); cannot detox, and burns out (dies) in 1D4 years."
  - "Magic: none, and never a magic O.C.C."
  - "Equipment and money: as per O.C.C.; slave wages are one third to half of what a human or other D-Bee would make."
  - "Cybernetics and bionics: as per O.C.C., but generally avoided; a lost limb may be replaced by a stronger prosthetic."
side_effects: "Prone to violent outbursts (see the ability). Low tolerance for alcohol and drugs: drunk after two drinks and high quickly and profoundly, -6 to save vs drugs, and 40% are addicted to drugs or alcohol, which worsen the mood swings; resistant to poisons and other toxins through high P.E. The inhuman appearance is hard to disguise."
extraction_notes: "This class followed Rifts World Book 11: Coalition War Campaign printed 202-203 until this update; it now follows the newer printing, Rifts World Book 30: D-Bees of North America printed 143-144, which says the race originally appeared in Coalition War Campaign (ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here). Both entries were read off page renders (D-Bees cache p144-p145, Coalition War Campaign cache p203-p204). || Unchanged between the two printings: the eight attribute dice, Hit Points P.E. plus 1D6 per level, S.D.C. a bare 3D4x10 (no plus-O.C.C. clause, so stored as sdc_base; no men_of_arms line because the race states its pool), P.P.E. 6D6, nightvision 120 feet, the outburst''s +10 P.S., +1 attack, +6 vs Horror Factor, +2 vs mind control, possession and psionic attack, -2 dodge and -30% skills, 1D4+2 Physical powers, the Eruptor''s 1D4+1 Physical powers plus one Super power with doubled range and duration, no magic, and the halving of O.C.C. Related and Secondary skills. || Violent Outburst: D-Bees prints a Supernatural P.S. of 1D4+21 doing 2D6 M.D. from a punch or kick and 4D6 M.D. with a power punch, and adds +2 on initiative and +1 to strike. Coalition War Campaign printed 203 gave a supernatural P.S. of 19, 1D6 M.D. from a punch or kick and 2D6 M.D. with a power punch, and no initiative or strike bonus. The bite is one M.D. in both. || P.S.: D-Bees marks P.S. 4D6+10 as Augmented Strength and lists Augmented P.S. among the natural abilities; Coalition War Campaign printed 202 gave the same dice with no strength class. Stored as a natural ability. || Horror Factor: D-Bees prints 10 (15 to children and women), but only when they are enraged; Coalition War Campaign printed 202 gave a bare 10. horror_factor stays 10 and the condition and the 15 are in the Violent Outburst ability. || Bonuses: D-Bees prints, in addition to those from attributes and skills, +1 to strike and parry, +2 to pull punch, +4 to damage and +1 to save vs Horror Factor, stored in bonuses. Coalition War Campaign printed no bonus line at all. D-Bees also prints -6 to save vs drugs under Vulnerabilities, stored as saves harmful_drugs -6; Coalition War Campaign printed only that many are attracted to drugs and alcohol. The outburst bonuses are conditional and stay in the ability. || Psionics: D-Bees prints the average N''mbyr as a Major Psychic with 1D4+2 Physical powers of choice and I.S.P. equal to the P.E. attribute number +10 per level of experience starting at level one. Coalition War Campaign printed 203 gave I.S.P. as M.E. attribute number x3 plus 10 per level for the whole race and named no tier for the average member (only that 20% are major or master psychics), which was stored as minor. powers_starting holds the ceiling 6 of the 1D4+2 roll and the roll is the player''s to honour. Eruptors (20%): D-Bees prints them as Master Psychics with I.S.P. P.E. x3 +10 per level starting with level one, +1D6 M.D. damage, and no additional psionic abilities as they advance; Coalition War Campaign printed major or master, damage +1D6 points, and the same M.E. x3 I.S.P. as everyone else. The Eruptor stays a special ability in prose, with Telekinesis (10+) read as the catalog''s Telekinesis (Super). || Available O.C.C.s: D-Bees prints any Men of Arms or Adventurer O.C.C., stored as occ_restrictions only [group:men-of-arms, group:optional]; the catalog''s optional group is the Adventurers and Scholars section. Coalition War Campaign printed 203 gave any Men of Arms or vagabond or wilderness scout, both of which sit inside that group. Juicer: D-Bees prints that those who insist on Juicer augmentation receive all the powers of a Juicer but also 1D6 random insanities, cannot detox and burn out in 1D4 years; Coalition War Campaign printed that Juicer and Crazy conversions do not work on the alien physiology, and in its Bionics line that some have elected to get Juicer augmentation. Crazy conversion does not work in either printing; a race states only or except, not both, so that exclusion is in the note and restrictions. || Skills: D-Bees prints R.C.C. Skills as Language: Native Tongue (N''mbyr at 95%), Wrestling, Physical Labor and Athletics (General), in addition to O.C.C. skills. Coalition War Campaign printed no R.C.C. skill list and no percentage for the native language (it was stored at the catalog''s 98); its closing note gave American (+20%) and one language of choice (+15%). D-Bees restates the R.C.C. skills as a complete line without them, so they are not stored; languages come from the O.C.C. || Equipment and money: D-Bees prints Standard Equipment as per O.C.C. and Money as per O.C.C. (slave wages are one third to half of what a human or other D-Bee would make), so the class states no equipment_starting and no starting_money. Coalition War Campaign printed 203 gave the clothes on their back, a knife or mace, an energy weapon of choice and some personal items, and 2D6x10 credits. Favorite weapons (Neural-Mace, Vibro-Blades, heavy weapons) and any armor are the same in both. || Cybernetics: D-Bees prints as per O.C.C., but tend to avoid them. Coalition War Campaign printed that a more powerful prosthetic limb is considered if the natural one is lost and that most avoid M.O.M. implants; D-Bees does not restate either and the prosthetic line is kept. || XP: D-Bees prints use the Experience Table of the chosen O.C.C.; Coalition War Campaign''s tables (printed 224) print no N''mbyr ladder. No xp_table. || Not stored as mechanics, D-Bees only: alignments lean Scrupulous (20%), Unprincipled (20%) and Anarchist (35%); life span 3D6+50 years; 40% are addicted to drugs or alcohol; slave market value 4D4x1,000."
---

## Lore

The N''mbyr, pronounced Nim-beer, are called Gorilla Men for their ape-like
look: simian faces, long powerful arms and short legs. They are strong,
emotional and quick to anger, love hard labor, wrestling and football, and
make fine climbers, laborers and warriors. Most are good-natured, but even a
friendly one can fly into a rage and maul a comrade. They came through an
anomaly at the Old Chicago ruins and are most common in the Midwest and the
Magic Zone.

## GM Notes

Any alignment. Six to seven feet, 160 to 250 lbs. They rely on physical
strength and psionics rather than magic, favor neural maces, vibro-blades
and heavy weapons, and can wear any armor. As downtrodden Burbs D-bees they
earn slave wages. Rage outbursts make them dangerous allies as well as
enemies.
',
       updated_at = datetime('now')
 WHERE class_id = 'nmbyr-gorilla-man'
   AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.202-203') > 0
   AND length(markdown) = 5565;

-- == tirrvol-sword-fist ==
UPDATE imported_classes
   SET markdown = '---
id: tirrvol-sword-fist
name: Tirrvol Sword Fist
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.201-203
category: rcc
tags: []
attribute_dice:
  IQ: "3d6+1"
  ME: "3d6+1"
  MA: "3d6+1"
  PS: "5d6+6"
  PP: "3d6+6"
  PE: "3d6+6"
  PB: "1d6+1"
  Spd: "3d6"
mdc_base: "P.E. x3, +2d6 per level"
ppe_base: "4d6"
horror_factor: 12
starting_money: "3d4x1000"
occ_restrictions:
  except: ["group:magic", "group:psychic", "group:clergy", "juicer", "coalition-juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "mega-juicer", "phaeton-juicer", "titan-juicer", "crazy", "glitter-boy", "robot-pilot"]
  note: "Any Men of Arms or Adventurers & Scholars O.C.C., except Juicer, Crazy, Glitter Boy and Robot Pilot. Leans toward soldier types."
psionics:
  type: "minor"
  isp_base: "M.E. x2, +1d6 per level"
  powers: ["See The Invisible", "Sense Evil", "Sixth Sense"]
  powers_starting: 1
  categories_allowed: ["Sensitive"]
bonuses:
  combat: { initiative: 2, roll: 1, attacks: 1, pull_punch: 1 }
  saves: { horror_factor: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 }, combat: { pull_punch: 1 } }
    - { level: 3, combat: { pull_punch: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, combat: { pull_punch: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 7, combat: { pull_punch: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, combat: { pull_punch: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 }, combat: { pull_punch: 1 } }
    - { level: 15, saves: { horror_factor: 1 }, combat: { pull_punch: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The Tirrvol''s own whistle-and-click language." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "American (+20%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One other language of choice (+15%)." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0, note: "Printed among the R.C.C. skills." }
natural_abilities:
  - { name: "Supernatural Strength", description: "P.S. is supernatural and does mega-damage." }
  - { name: "Sword Fists", description: "A mega-damage bone blade grows where the fingers would be, with a bony hook in place of the thumb. As a blade a sword fist does 2D6 M.D. in addition to the character''s supernatural P.S. punch damage, or 1D4 M.D. in addition when striking with the blunt, flat side. A power punch does double damage but counts as two melee attacks. All undead, and those demons and supernatural beings vulnerable to bone, take double damage from the sword fist. Can still work a computer and simple machines, clumsily." }
  - { name: "Senses and Healing", description: "Keen vision and good hearing. Heals twice as fast as a human; sword hands and other limbs regrow within 3D4 weeks if broken or severed." }
  - { name: "Prehensile Feet", description: "Double-jointed legs and prehensile feet and toes let it use its feet as hands, even to drive a vehicle, but less precisely: every skill needing manual dexterity or precision (piloting, mechanics, medical, demolitions and the like) is -10%, and firing a gun with the feet is -2 to strike." }
special_abilities:
  - name: "Natural W.P. Sword (Sword Fists)"
    description: "With its sword fists: +1 to strike, parry and disarm at levels 1, 3, 4, 6, 8, 10, 12 and 14, and +1 to pull punch/sword strike at levels 1, 2, 3, 5, 7, 9, 12 and 15. Critical strike (double damage) on a natural 17-20, and a critical strike from behind. Normal cutting and stabbing damage is the character''s supernatural P.S. punch damage +2D6 M.D.; a power punch does double damage but counts as two melee attacks. A successful pulled punch/strike can do whatever reduced damage the warrior likes, down to S.D.C./hit point damage as low as 2D6 S.D.C."
restrictions:
  - "Needs an O.C.C.: the race''s own skills are only its languages, Dance and W.P. Paired Weapons, in addition to O.C.C. skills."
  - "Juicer, Crazy, Glitter Boy and Robot Pilot O.C.C.s are not available to this race."
  - "Magic: none; human languages are hard for it, which makes spell casting difficult."
  - "Bionics: avoided, except cyber-armor and a few basic implants; will consider bionics for prosthetics."
  - "70% are also literate in American or a written language of choice (+15%)."
  - "Standard equipment is as per the O.C.C.; favorite weapons are the natural sword fists and items that can be used with the feet."
side_effects: "Skills needing manual dexterity or precision are -10% and firing a gun with the feet is -2 to strike (see Prehensile Feet). Difficulty speaking most humanoid languages; no fingers or thumb."
extraction_notes: "First imported from Rifts World Book 11: Coalition War Campaign printed 203-205, which this class followed until it was brought up to its D-Bees of North America printing (printed 201-203, cache p202-p204) under the ruling of 2026-10-04: the newest printing that states a figure wins and the older figure is kept here. Both entries were read off page renders. || Revised by D-Bees: P.B. 1D6+1 (Coalition War Campaign printed 204 gave 1D6). Language of choice +15% (Coalition War Campaign printed 205 gave +20%); American stays +20%. Dance +15% is new in D-Bees, stored at 45% (catalog 30% plus 15%). The literate 70% get +15% in D-Bees (Coalition War Campaign printed 205 gave 01-70% can read, with no bonus); it is a chance, so it is prose. Available O.C.C.s now also exclude Glitter Boy and Robot Pilot (Coalition War Campaign printed 205 excepted only Juicer and Crazy conversions); stored as the glitter-boy and robot-pilot ids only, the two O.C.C.s the book names. Sword fist damage: D-Bees printed 203 gives supernatural P.S. damage plus 2D6 M.D. as a blade, plus 1D4 M.D. with the flat, double damage to undead and to beings vulnerable to bone, and a power punch counting as two attacks (Coalition War Campaign printed 204 gave damage equal to supernatural P.S. with no addition, and none of the rest). Firing a gun with the feet at -2 to strike is new in D-Bees. Bionics: D-Bees adds a few basic implants and prosthetics (Coalition War Campaign printed 205 gave cyber-armor only). Standard equipment: D-Bees printed 203 gives as per O.C.C., so no equipment_starting is stored; Coalition War Campaign printed 205 listed the clothes on their back, light to heavy body armor, utility belt, backpack or satchel, flashlight, portable language translator, knife, an energy weapon of choice (typically a pistol) and some personal items, and the class stored those until this update. || Coalition War Campaign printed 204 also gave an unconditional +1 to parry among its R.C.C. Combat Bonuses; the D-Bees bonus line restates the bonuses as +1 attack, +2 initiative, +1 roll with impact and the horror factor ladder without it, so it is not stored (the sword fists'' own +1 parry ladder is in the ability). || Unchanged between the printings: the other seven attributes, M.D.C. P.E. x3 plus 2D6 per level (a mega-damage creature with no hit points or S.D.C.; stored as mdc_base, so no men_of_arms line), Horror Factor 12, P.P.E. 4D6, 3D4x1000 credits, I.S.P. and the psionic powers, and both level ladders. || Bonuses: +2 initiative, +1 roll, +1 attack are unconditional. Save vs horror factor +1 at levels 1, 2, 4, 6, 8, 10, 12, 15 is stored as level 1 plus at_level. Pull punch +1 at levels 1, 2, 3, 5, 7, 9, 12, 15 is stored the same way; D-Bees prints it inside the Natural W.P. Sword Ability as pull punch/sword strike, and the ability''s description repeats it. The strike/parry/disarm ladder is printed for the sword fists specifically, so it is a special ability, as are the 17-20 critical and the damage rules. D-Bees prints W.P. Paired Weapons among the R.C.C. skills (Coalition War Campaign printed it among the combat bonuses). || Psionics: D-Bees calls them Minor Psychics; See the Invisible, Sense Evil and Sixth Sense granted, plus one sensitive power of choice. || Available O.C.C.s: any Men of Arms or Adventurers & Scholars, which are the men-of-arms and optional groups; stored as except the three other groups plus the Juicer and Crazy conversion O.C.C.s listed at the first import, plus Glitter Boy and Robot Pilot. The Maxi-Killer (Atlantean bio-wizard Juicer, built for bodies the human process kills) is left allowed. || XP: D-Bees says to use the experience table of the chosen O.C.C.; no xp_table."
---

## Lore

The Tirrvol, pronounced tear-vol, are huge barrel-chested humanoids with a
long, snake-like neck, a small round head and grey, wrinkled, elephant-like
skin. In place of fingers each hand ends in a long ivory blade of
mega-damage bone, with a hook for a thumb, which is where the name Sword
Fist comes from. Double-jointed legs and prehensile feet make up for the
clumsy hands. Most are honorable, good-hearted warriors and masterful
swordsmen who stand against tyranny; several are rumored to have joined the
Cyber-Knights. They are bright but speak in short, simple sentences, their
own tongue being whistles and clicks. Their origin is unknown and fewer than
a thousand live in the Americas.

## GM Notes

Any alignment, 60% good; aberrant is the most common evil one. Eight to
twelve feet, 250 to 500 lbs. They find work easily as enforcers, soldiers,
bodyguards, detectives and heroes and are among the better-off nonhumans.
Warriors often add cyber-armor over chest, shoulders and neck.
',
       updated_at = datetime('now')
 WHERE class_id = 'tirrvol-sword-fist'
   AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.203-205') > 0
   AND length(markdown) = 7166;

-- == quick-flex-alien ==
UPDATE imported_classes
   SET markdown = '---
id: quick-flex-alien
men_of_arms: false
name: Quick-Flex Alien
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.168-170
category: rcc
tags: [stealth]
xp_table: [0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 74801, 100901, 140001, 193101, 235201, 290401, 350601]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6+6"
  PE: "3d6"
  PB: "2d6"
  Spd: "6d6+25"
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "2d6"
psionics_allowed: false
starting_money: "1d6x100"
occ_restrictions:
  except: ["group:magic", "group:psychic", "group:clergy", "combat-cyborg", "cs-cyborg-strike-trooper", "destroyer-borg", "fq-cyborg-soldier", "fq-cyborg-dervish", "fq-cyborg-imprimer", "fq-cyborg-leviathan", "fq-cyborg-slasher", "mining-borg", "ngr-cyborg-soldier", "ojahee-borg", "plains-borg", "republic-cyborg-soldier", "cyborg-shocktrooper", "ninja-borg", "warlord-heavy-machine", "warlord-light-machine", "crazy", "ultra-crazy", "ninja-crazy", "juicer", "coalition-juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "maxi-killer", "mega-juicer", "phaeton-juicer", "titan-juicer", "ninja-juicer"]
  note: "Limited to physically oriented O.C.C.s: Bandit, Bounty Hunter, City Rat, Cyber-Knight, Gunfighter, Gunslinger, Headhunter, Highwayman, Merc Soldier, Soldier (any), Sailor, Pirate, Pecos Raider, Professional Thief, Master Spy, Super Spy, Smuggler, Saddle Tramp/Drifter, Vagabond (any), Wilderness Scout (any), and any adventurer, lawman or soldier type O.C.C. that does not require dramatic bionic conversion (partial and a few implants is okay) or other physiological change (no Juicer or Crazy). Robot Pilot is acceptable but rarely chosen; fast-vehicle specialists are favored. They NEVER study magic."
bonuses:
  pools: { sdc: "3d6" }
  combat: { initiative: 2, attacks: 1, perception: 3, strike: 1, parry: 2, automatic_dodge: 3, roll: 2, pull_punch: 2 }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "American (+20%); the catalog has no American row." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One language of choice (+10%)." }
    - { name: "Combat Driving", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%. R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "W.P. Quick Draw", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Find Contraband", base: 36, per_level: 4, note: "+10%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { choose: 1, categories: ["Physical"], note: "Physical skill of choice." }
    - { name: "Streetwise", base: 34, per_level: 4, note: "+14%" }
    - { name: "Pick Locks", base: 50, per_level: 5, note: "+20%" }
    - { name: "Pick Pockets", base: 40, per_level: 5, note: "+15%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Automatic Pistol", "W.P. Submachine-Gun"], note: "W.P. Automatic Pistol or Sub-machinegun." }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0, note: "R.C.C. skill, in addition to those of the chosen O.C.C." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for one R.C.C. Related skill, or to Martial Arts (or Assassin if evil) for two." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Espionage", only: ["Sniper", "Wilderness Survival"] }
      - { name: "Mechanical", only: ["Basic Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", only: ["Military Etiquette", "Recognize Weapon Quality"], bonus: 10 }
      - "Physical"
      - "Pilot"
      - { name: "Rogue", bonus: 6 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 10, count: 1 }, { level: 14, count: 1 }]
    note: "Pilot Related is printed None and omitted."
  secondary_skills:
    count: 6
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }]
    note: "At the base skill level, without the bonuses in parentheses; the any/only/none limits above still apply."
equipment_starting:
  - { item_id: "urban-warrior-padded-environmental-body-armor", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { choose: 2, label: "a pair of energy pistols of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }
natural_abilities:
  - { name: "Hyperactive Reflexes and Speed", description: "Higher metabolism, enhanced reflexes and great running speed, roughly equal to a Juicer or Crazy. Ambidextrous: uses both hands with equal skill, precision and agility." }
  - { name: "Double-Jointed", description: "Can pop joints, which aids in slipping out of confinement, rope and the like." }
  - { name: "Leaping", description: "Leaps eight feet (2.4 m) high or across from a standstill, four feet (1.2 m) more with a running start." }
  - { name: "Automatic Dodge", description: "+3 to automatic dodge: roll to dodge as usual, but the act of dodging does not use up a melee attack." }
special_abilities:
  - name: "Gunman''s Eye"
    description: "+1 to strike using modern weapons and guns or any type of bow and arrow, even if the character does not have a W.P. in that weapon. This is on top of the +1 to strike that always applies."
restrictions:
  - "D-Bees of North America prints the Quick-Flex Alien as a race that takes an O.C.C.: its experience table, standard equipment and money are as per the chosen O.C.C. The Quick-Flex Rogue R.C.C. skill list, related and secondary skills, equipment and money kept here are from Coalition War Campaign, which printed them as the alternative to an O.C.C.; see extraction_notes."
  - "Short attention span, skill penalty: -10% on all skills (regardless of O.C.C. bonuses) except those in the categories of Espionage, Physical, Pilot, Rogue and W.P. Coalition War Campaign exempted the Quick-Flex Rogue R.C.C.''s own skills and related skills."
  - "Magic: none. The attention deficit makes the study of magic too demanding; they NEVER study magic."
  - "Bionics: avoided, because they slow the D-bee down."
  - "Most Quick-Flex are illiterate (Coalition War Campaign: 90%)."
side_effects: "Thrill-seekers who enjoy a fast pace and taking risks. A bit jumpy and hyper; cannot sit still for more than 1D4 hours; easily bored."
extraction_notes: "Originally Rifts World Book 11: Coalition War Campaign printed 205-206; the class followed that printing until this update to Rifts World Book 30: D-Bees of North America printed 168-170 (ruling of 2026-10-04: the newest printing that states a figure wins, and the older figure is kept in a note). Both books were read off page renders (D-Bees cache p169-p171, Coalition War Campaign cache p206-p207). || Shape: D-Bees prints the race with an O.C.C. always - R.C.C. skills in addition to those of the chosen O.C.C., experience table of the chosen O.C.C., Standard Equipment as per O.C.C., Money as per O.C.C. - and does not restate the Quick-Flex Rogue R.C.C. that Coalition War Campaign printed as the alternative to an optional O.C.C. The category stays rcc and the Rogue R.C.C. material is kept as Coalition War Campaign printed it: the nine Rogue skills (Land Navigation +10%, Find Contraband +10%, Prowl +10%, a Physical skill of choice, Streetwise +14%, Pick Locks +20%, Pick Pockets +15%, W.P. Energy Pistol, W.P. Automatic Pistol or Sub-machinegun), Hand to Hand: Basic and its upgrade prices, six related skills plus one at 3, 6, 10 and 14, six secondary skills plus one at 3, 7 and 10, the starting equipment, 1D6x100 credits, and the Quick Flex Rogue R.C.C. ladder from Coalition War Campaign printed 224 stored as xp_table (lower bounds 0, 2,301, 4,601, 9,201, 18,401, 26,501, 36,601, 51,701, 74,801, 100,901, 140,001, 193,101, 235,201, 290,401, 350,601). D-Bees does not restate any of these. || Unchanged between the two printings: the eight attribute dice, hit points P.E. plus 1D6 per level, S.D.C. 3D6 plus physical skills and O.C.C. (a pool bonus, men_of_arms false, a race), P.P.E. 2D6, psionics none, magic none, the eight-foot leap plus four feet from a run, weight 100-150 pounds. || Bonuses, D-Bees printed 169: +1 attack, +2 initiative, +3 Perception Rolls, +1 to strike, +2 to parry, +3 to automatic dodge, +2 roll with impact, +2 pull punch are stored; +1 to strike with modern weapons/guns or any bow even without the W.P. is conditional and is the Gunman''s Eye special ability. Coalition War Campaign printed 205 gave +2 initiative, +1 attack, +1 strike with modern weapons/guns or bow and arrow, +2 roll, +2 pull punch, paired weapons and automatic dodge (same as the Commando hand to hand ability) with no figure; it printed no Perception, no general strike and no parry bonus. || R.C.C. skills, D-Bees printed 169: Combat Driving, Escape Artist (+20%), W.P. Paired Weapons, W.P. Quick Draw and W.P. Targeting, plus American (+20%) and one language of choice (+10%), both through Language: Other. Combat Driving, W.P. Quick Draw and W.P. Targeting are new in D-Bees; Coalition War Campaign printed paired weapons among the bonuses and Escape Artist (+20%) in the Rogue list. Languages: the Coalition War Campaign Rogue list printed American and one language of choice (+20%) and the row stored both at +20%; its closing Note printed American (+20%) and one of choice (+10%), the figures D-Bees prints. || Available O.C.C.s: D-Bees names a list of physically oriented O.C.C.s plus any adventurer, lawman or soldier type that needs no dramatic bionic conversion or other physiological change (no Juicer or Crazy), and says they never study magic. Stored as except the magic, psychic and clergy groups plus the Juicer, Crazy and full-conversion cyborg O.C.C.s by id; the named list is in the note. Coalition War Campaign printed 206 gave any Men of Arms, scholar or adventurer O.C.C. and said Juicer and Crazy conversions will work with life expectancy 25% less than usual. || Skill penalty: D-Bees gives -10% on all skills except the Espionage, Physical, Pilot, Rogue and W.P. categories; Coalition War Campaign printed 205 gave -10% except physical and rogue skills, with the Rogue R.C.C.''s skills exempt. D-Bees adds that the character cannot sit still for more than 1D4 hours. || Natural abilities: D-Bees adds double-jointed and spells out ambidextrous; Coalition War Campaign named ambidextrous in the description only. || Size: D-Bees 5 feet 4 inches to 5 feet 10 inches (1.6 to 1.75 m); Coalition War Campaign 5 to 5 feet 6 inches (1.5 to 1.65 m). Alignments: D-Bees any, leaning Scrupulous 20%, Unprincipled 30%, Anarchist 30%; Coalition War Campaign any. Literacy: D-Bees says most are illiterate; Coalition War Campaign said 90%. The lore and GM notes carry the D-Bees size, alignment and armor preference (light or medium body armor or Naruni force fields; Coalition War Campaign said light body armor or a Naruni force field). || Equipment as Coalition War Campaign printed it: light body armor stored as the Urban Warrior; the pair of energy pistols is a choice of two; backpack or satchel is the backpack. Electrical and Mechanical Basic only are Basic Electronics and Basic Mechanics; Science Math only is both Mathematics rows; Wilderness Survival under Espionage is a cross-category only. Psionics none: psionics_allowed false."
---

## Lore

The Quick-Flex Alien is the classic D-bee: at a glance it passes for human,
until you notice the large eyes, long face and pinhole nose. A racing
metabolism keeps them small, rarely over five feet ten, and makes them
alert, agile and startlingly fast, with reflexes to match a Juicer and both
hands equally good. That makes them superb gunmen, snipers, thieves, pilots
and acrobats. They love adventure, fast vehicles and tattoos. About a
million live across North America, mostly in the Midwest.

The Quick-Flex Rogue is their own street class, somewhere between a thief
and a city rat.

## GM Notes

Any alignment, leaning scrupulous (20%), unprincipled (30%) and
anarchist (30%). Five feet four to five feet ten, 100 to 150 lbs. Most have
forgotten their native tongue; nine in ten are illiterate scavengers,
vagabonds, thieves, mercenaries or adventurers. Burbs wages are pitiful.
They favor pistols and vibro-knives, and light or medium armor or a Naruni
force field over anything that slows them.
',
       updated_at = datetime('now')
 WHERE class_id = 'quick-flex-alien'
   AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.205-206') > 0
   AND length(markdown) = 8063;

-- == vanguard-brawler ==
UPDATE imported_classes
   SET markdown = '---
id: vanguard-brawler
name: Vanguard Brawler
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.208-210
category: rcc
tags: [combat]
xp_table: [0, 2051, 4101, 8401, 16801, 25561, 35801, 50401, 70801, 95401, 130801, 180401, 230801, 280401, 331801]
attribute_dice:
  IQ: "3d6+2"
  ME: "3d6"
  MA: "2d6"
  PS: "4d6+4"
  PP: "3d6+4"
  PE: "4d6+4"
  PB: "2d6"
  Spd: "3d6"
mdc_base: "P.E. x2, +1d6 per level"
ppe_base: "1d6"
horror_factor: 11
psionics_allowed: false
starting_money: "1d4x1000"
occ_restrictions:
  except: ["group:psychic", "group:clergy", "group:magic", "juicer", "coalition-juicer", "delphi-juicer", "dragon-juicer", "euro-juicer", "hyperion-juicer", "juicer-assassin", "juicer-gladiator", "juicer-scout", "mega-juicer", "phaeton-juicer", "titan-juicer", "crazy"]
  note: "Drawn to physical rather than intellectual O.C.C.s: Bandit, Gunfighter, Gunslinger, City Rat (any), Headhunter, Highwayman, Pirate, Sailor, Saloon Bum, Bounty Hunter, Master Assassin, Safecracker, Smuggler, Professional Thief, Freelance Spy, Super-Spy, Sheriff, Saddle Tramp, Merc Soldier, Vagabond, Vagabond Fighter/Street Thug, and most any soldier or criminal O.C.C. No interest in magic (Magic: None), nor in scholarly occupations such as Body Fixer, Rogue Scientist or Operator, nor Professional Gambler, Glitter Boy or Robot Pilot. Cannot become a Juicer or Crazy: the alien physiology is incompatible."
bonuses:
  combat: { initiative: 2, attacks: 1, disarm: 1, roll: 2, pull_punch: 2 }
  saves: { disease: 1, toxins_poisons: 1, possession: 1, horror_factor: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Vanguard Brawler." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Speaks American and one language of choice (+20%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Find Contraband", base: 41, per_level: 4, note: "+15%" }
    - { name: "Intelligence", base: 48, per_level: 4, note: "+16%" }
    - { name: "Streetwise", base: 40, per_level: 4, note: "+20%" }
    - { name: "Roadwise", base: 46, per_level: 4, note: "+20%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed Track (humanoids; +10%)." }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed Pilot Hover Vehicle (+10%)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Printed Body Building." }
    - { choose: 1, from: ["Boxing", "Wrestling"], note: "Boxing or Wrestling (pick one)." }
    - { choose: 1, from: ["Gymnastics", "Acrobatics"], note: "Gymnastics or Acrobatics (pick one)." }
    - { name: "Climbing", base: 60, per_level: 5, note: "+20%; a natural climber." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can upgrade to Hand to Hand: Expert, Martial Arts or Assassin for the cost of only one O.C.C. Related Skill, regardless of what the O.C.C. might allow." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - "Pilot"
      - { name: "Rogue", bonus: 6 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 2, count: 2 }, { level: 5, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
    note: "Pilot Related is printed None and omitted."
  secondary_skills:
    count: 5
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    note: "At the base skill level, without the bonuses in parentheses; the any/only/none limits above still apply."
equipment_starting:
  - { item_id: "urban-warrior-padded-environmental-body-armor", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { choose: 2, label: "a pair of energy pistols of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }
natural_abilities:
  - { name: "Robotic Strength", description: "P.S. is equivalent to Robot Strength; damage is as per Robot Strength or by weapon." }
  - { name: "Mega-Damage Hide", description: "Tough, scaly M.D.C. skin; a physically powerful mega-damage creature." }
  - { name: "Keen Hearing and Smell", description: "Tracks by scent at 30% +2% per level, +10% to follow a blood scent. A natural climber." }
  - { name: "Infrared Vision", description: "Sees the infrared spectrum of light." }
  - { name: "Back Spines", description: "Two rows of 3-6 hook-like spines; anything leaping onto its back impales or gouges itself. Their shape is unique to each Brawler and identifies individuals." }
  - { name: "Hardy", description: "The high P.E. makes most Brawlers resistant to magic, disease and poison." }
restrictions:
  - "D-Bees of North America prints no Thug R.C.C.: a Brawler takes an O.C.C., keeps Climbing, Boxing, Roadwise and Streetwise whatever that O.C.C. is, and takes its equipment, money and experience table from the chosen O.C.C. The rest of the skill list, the equipment and the credits stored here are the Coalition War Campaign Thug R.C.C.; see extraction_notes."
  - "Clearly inhuman: disguise is difficult, and the Brawler is a target of human supremacists."
  - "The back spines make it difficult to wear full human body armor or clothing without costly customization."
  - "Cannot become a Juicer or Crazy: the alien physiology is incompatible. Partial bionic reconstruction is fairly common; most who undergo full conversion become incredibly bitter and mean."
  - "90% are completely illiterate."
  - "The aggressive nature can work against them, and a Brawler is bored out of its mind after a day or two of sitting still or routine work."
extraction_notes: "Followed Rifts World Book 11: Coalition War Campaign printed 206-208 until this update; brought to the Rifts World Book 30: D-Bees of North America printing, printed 208-210 (cache p209-p211), under the ruling of 2026-10-04 that the newest printing stating a figure wins. Both entries were read off 170 dpi renders. || Shape: Coalition War Campaign prints a Vanguard Brawler Thug R.C.C. with its own skill list, related and secondary skills, equipment and 1D4x1000 credits, and makes an O.C.C. the optional alternative. D-Bees prints no Thug R.C.C.: the entry is headed Optional Player Character and NPC, an O.C.C. is chosen, four R.C.C. skills are kept regardless of it, and Standard Equipment, Money and the experience table are as per the chosen O.C.C. The category stays rcc and the Thug R.C.C. package stays stored; D-Bees does not restate it. || Revisions taken from D-Bees: Streetwise +20% (Coalition War Campaign printed 207 gave +16%); Climbing +20%, stored 60 and 5 (Coalition War Campaign printed 206 gave a natural climb of 68/56% +2% per level, held as 68 and 2); +1 to disarm added to the bonuses (Coalition War Campaign printed 206 gave none); P.S. equivalent to Robot Strength, damage as per Robot Strength (Coalition War Campaign printed 206 gave plain P.S. 4D6+4); 90% completely illiterate (Coalition War Campaign printed 208 gave 70%); disguise difficult (Coalition War Campaign printed 206 gave impossible); Magic None (Coalition War Campaign printed 206 gave by O.C.C. only), so the magic group joins the O.C.C. exceptions; the Hand to Hand upgrade to Martial Arts or Assassin costs one O.C.C. Related Skill with no alignment condition printed (Coalition War Campaign printed 207 gave assassin if evil); alignments Anarchist 33%, Aberrant 20%, Miscreant 26%, Diabolic 15% (Coalition War Campaign printed 206 gave 33% anarchist and 66% evil); 500,000 to 800,000 in North America (Coalition War Campaign printed 206 gave less than half a million). || Added from D-Bees: Roadwise +20%, one of the four R.C.C. skills, which Coalition War Campaign does not print. || D-Bees gives Boxing to every Brawler; the Coalition War Campaign Thug list prints Boxing or Wrestling (pick one) and that pick-one is kept as stored. Needs Nate''s call. || M.D.C.: P.E. x2 plus 1D6 per level in both books, a mega-damage creature, so mdc_base and no men_of_arms line. || Bonuses: +2 initiative, +1 attack, +1 disarm, +2 roll, +2 pull punch, +1 save vs disease and poison (disease and toxins_poisons), +1 vs possession; horror factor +1 at levels 1, 2, 3, 4, 5, 6, 8, 10, 12, 14. || Skills: catalog base plus printed bonus. Original only, not restated by D-Bees: the languages, Basic Math (Mathematics: Basic), Land Navigation, Find Contraband, Intelligence +16%, Track (humanoids) as Tracking (people), Pilot Hover Vehicle as Hover Craft (ground), the two W.P.s, Prowl, Body Building as Body Building & Weight Lifting, Gymnastics or Acrobatics, Hand to Hand: Expert, the related list (five plus two at 2, 5, 8, 12) and the secondary skills (five plus one at 3, 6, 9, 12). The Coalition War Campaign Note''s American +20% and one other +10% reads as the O.C.C. path and is not stored twice. || Available O.C.C.s: D-Bees names physical O.C.C.s and most any soldier or criminal O.C.C., and prints the rest as dislikes (magic, scholarly occupations, Professional Gambler, Glitter Boy, Robot Pilot) except Juicer and Crazy, which it prints as cannot. Stored as except psychic (psionics none), clergy and magic (Magic: None) plus every Juicer and Crazy conversion O.C.C. in the catalog (the Maxi-Killer, built for bodies the human process kills, is left allowed); the dislikes are in the note. Coalition War Campaign printed 207 gave most any Men of Arms, scholar or adventurer O.C.C. || XP: D-Bees printed 209 says to use the experience table of the chosen O.C.C. The stored ladder is the Thug R.C.C.''s from Coalition War Campaign printed 224, headed NTSET Psi-Hound, Vanguard Brawler Thug, CS EOD Specialist, CS Nautical Specialist, read off a 200 dpi render; D-Bees does not restate it. Two lower bounds disagree with the band before: level 6 is printed 24,561 after level 5 ends at 25,560, and level 15 is printed 331,401 after level 14 ends at 331,800. Stored as the previous top plus one, 25,561 and 331,801, so the bands do not overlap; the printed bounds are both still strictly rising and would also pass. Needs Nate''s call. || Equipment and money: D-Bees prints as per chosen O.C.C. for both. The stored kit and 1D4x1000 credits are the Thug R.C.C.''s from Coalition War Campaign printed 207-208: light body armor stored as the Urban Warrior; pair of energy pistols is a choice of two; backpack or satchel is the backpack. Psionics none in both books: psionics_allowed false. || Not stored, D-Bees printed 209-210: average life span 3D6+48 years, slave market value 1D6x10,000 credits."
---

## Lore

Vanguard Brawlers are notorious street-gang bosses who hire out as bounty
hunters, slavers, hit men, enforcers, bouncers, bodyguards and mercenaries,
and gather in family clans and gangs of their own kind. They are tough,
streetwise thugs who win with fists, violence and intimidation, yet they are
also cunning strategists and capable leaders in a kingpin way. Their scaly
blue-green hide is mega-damage, though only good for a few blasts, and two
rows of hooked spines run down the back. As many as 500,000 to 800,000 live
in North America, most in the American Midwest and the Domain of Man.

## GM Notes

Alignment any, but Anarchist (33%), Aberrant (20%), Miscreant (26%) and
Diabolic (15%) are the norm. Six to seven
feet, 220 to 320 lbs. They like rail guns, plasma and other heavy weapons,
vibro-blades and magic weapons. Poorly paid for labor, they do well as
mercenaries and thugs.
',
       updated_at = datetime('now')
 WHERE class_id = 'vanguard-brawler'
   AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.206-208') > 0
   AND length(markdown) = 8910;

-- == trimadore ==
UPDATE imported_classes
   SET markdown = '---
id: trimadore
name: Trimadore
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.206-208
category: rcc
tags: [tech]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "2d4"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "2d6"
ppe_base: "1d6"
horror_factor: 9
starting_money: "2d6x1000"
occ_restrictions:
  only: ["headhunter-techno-warrior", "headhunter-assassin", "headhunter-anti-robot-specialist", "headhunter-techno-hound", "merc-soldier", "city-rat", "cyber-doc", "operator", "preacher", "rogue-scholar", "techno-wizard", "vagabond"]
  note: "Optional: instead of the Trimadore Mechanic R.C.C. one of these O.C.C.s may be selected: Headhunter, Merc Soldier, City Rat, Cyber-Doc, Operator, Preacher, Rogue Scholar, Techno-Wizard, Vagabond (any) or similar O.C.C.s (the similar ones are the G.M.''s call)."
psionics:
  type: "major"
  isp_base: "2d4x10 + M.E., +2d4 per level"
  powers: ["Mind Block", "Object Read (Psychometry)", "Speed Reading", "Telemechanics"]
bonuses:
  combat: { initiative: 2, attacks: 1, roll: 2, pull_punch: 2 }
  saves: { disease: 1, toxins_poisons: 1, possession: 1, horror_factor: 1 }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American (adopted language)." }
    - { name: "Literacy: Native Language", base: 55, per_level: 5, note: "+15%; printed Literacy: Native Tongue: American." }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Mathematics: Advanced", base: 75, per_level: 5, note: "+30%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed Pilot Hover Vehicle (+10%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot of choice (+10%)." }
    - { name: "Military Fortification", base: 40, per_level: 5, note: "+10%; printed Military Fortifications." }
    - { name: "Computer Operation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Computer Programming", base: 40, per_level: 5, note: "+10%" }
    - { name: "Electrical Engineer", base: 40, per_level: 5, note: "+10%" }
    - { name: "Mechanical Engineer", base: 40, per_level: 5, note: "+15%" }
    - { name: "Field Armorer & Munitions Expert", base: 60, per_level: 5, note: "Printed Field Armorer (+20%)." }
    - { name: "Jury-Rig", base: 45, per_level: 5, note: "+20%" }
    - { name: "Salvage", base: 55, per_level: 5, note: "+20%" }
    - { name: "Sensory Equipment", base: 45, per_level: 5, note: "+15%" }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for one R.C.C. Related skill, or to Martial Arts (or Assassin if evil) for two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", bonus: 10 }
      - { name: "Mechanical", bonus: 15 }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Computer Hacking"], bonus: 6 }
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    note: "Military: any, with +10% to all Demolitions and Trap skills only; add that by hand. Espionage and Wilderness are printed None and omitted."
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    note: "From the Secondary Skills List on page 300 of Rifts Ultimate Edition, at the base skill level; no bonuses other than a high I.Q."
equipment_starting:
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "multi-optics-band", qty: 1 }
  - { item_id: "sunglasses-or-tinted-visor", qty: 1 }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "pocket-computer", qty: 1 }
  - { item_id: "knife", qty: 1 }
  - { choose: 1, label: "energy weapon of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-l5-northern-gun-laser-rifle", "ng-57-northern-gun-heavy-duty-ion-blaster"] }
natural_abilities:
  - { name: "Keen Senses", description: "Perfect 20/20 vision, good hearing and a keen sense of touch." }
  - { name: "Mechanical Aptitude", description: "An innate, near-savant knack for mechanics, electronics, building and jury-rigging." }
  - { name: "Long Reach", description: "The long arms give an extended reach (5-6 feet/1.5 to 1.8 m)." }
restrictions:
  - "The Mechanic R.C.C. skill list and the optional O.C.C. are alternatives: an O.C.C. taken instead replaces the R.C.C. skills; see extraction_notes."
  - "Clearly inhuman appearance can be a liability."
  - "Starting money: besides the 2D6x1,000 credits, the Mechanic starts with 2D6x1,000 credits worth of spare parts. With an O.C.C. taken instead, money and equipment are by that O.C.C."
  - "M.D.C.: by armor or other external means only."
  - "Magic: Techno-Wizardry only; other magic is not pursued."
  - "Bionics: avoids major reconstruction, but may take numerous implants and augmentation."
  - "Body armor is home-built from scrap, 50-100 M.D.C."
extraction_notes: "Followed Rifts World Book 11: Coalition War Campaign printed 208-209 until this update; moved to its 2007 reprint in Rifts World Book 30: D-Bees of North America printed 206-208 under the ruling of 2026-10-04 (the newest printing that states a figure wins, the older figure kept here). Both entries were read off page renders (D-Bees cache p207-p209, Coalition War Campaign cache p209-p210 and p225). || Unchanged between the two printings: attribute dice, hit points P.E. plus 1D6 per level, S.D.C. 2D6 plus physical-skill S.D.C. (no plus-O.C.C. clause; stored as sdc_base, so no men_of_arms line), P.P.E. 1D6, Horror Factor 9, the four powers and the I.S.P. line, the bonus line, the equipment list, the 50-100 M.D.C. home-built armor, and the Magic and Bionics lines. || Bonuses: the bonus and horror-factor lines are word for word the Vanguard Brawler''s in both books (+2 initiative, +1 attack, +2 roll, +2 pull punch, +1 vs disease and poison, +1 vs possession, horror factor +1 at 1, 2, 3, 4, 5, 6, 8, 10, 12, 14). Transcribed as printed; D-Bees printed 208 repeats them unchanged. || Psionics: D-Bees adds Considered a Major Psychic; Coalition War Campaign printed 208 gave only Limited with no tier, and the class was stored minor. Mind Block, Object Read, Speed Reading and Telemechanics granted; Telemechanics is a Super power in the catalog, granted by name. D-Bees prints I.S.P. costs beside them, Speed Reading as 92), a misprint for (2). || R.C.C. skills: catalog base plus printed bonus. D-Bees adds Jury-Rig (+20%), Salvage (+20%) and Sensory Equipment (+15%), which Coalition War Campaign printed 209 does not list. Languages: D-Bees prints Language: Native Tongue: American (adopted language) and Literacy: Native Tongue: American (+15%), stored as Language: Native Tongue and Literacy: Native Language; Coalition War Campaign printed 209 gave Speaks American and one language of choice (+20%) and Literate in Earth language of choice (+15%), which were stored as a Trimadore native tongue, two Language: Other picks and one Literacy: Other pick. D-Bees does not restate the language of choice or a Trimadore tongue. Field Armorer (Coalition War Campaign: Armorer) is Field Armorer & Munitions Expert, Pilot: Hover Vehicle is Hover Craft (ground), Military Fortifications is Military Fortification. || Related skills: D-Bees gives five plus two at 3, 6, 9, 12; Coalition War Campaign printed 209 gave six. Mechanical is +15% (Coalition War Campaign +10%). Military is Any (+10% to all Demolitions and Trap skills) where Coalition War Campaign gave Military: Any (+10%); stored as the plain category with the bonus in the note. Secondary: D-Bees gives four plus one at 4, 8, 12 from the Rifts Ultimate Edition list; Coalition War Campaign gave five, limited by the related any/only/none list. || Available O.C.C.s (optional): D-Bees names Headhunter, Merc Soldier, City Rat, Cyber-Doc, Operator, Preacher, Rogue Scholar, Techno-Wizard, Vagabond (any) or similar O.C.C.s; Coalition War Campaign printed 209 named Scholar, Cyber-Doc, Operator or Techno-Wizard. Stored as only; Headhunter is stored as the four Headhunter O.C.C.s; or similar O.C.C.s is left to the note. In both books the O.C.C. is taken instead of the Mechanic R.C.C. and its skill list; see the first restriction. || XP: D-Bees printed 207 says the Trimadore Mechanic uses the same Experience Table as the Operator, and the O.C.C.''s table when one is taken; xp_table is a copy of the stored operator ladder. Coalition War Campaign printed 224 printed a Trimadore Mechanic R.C.C. ladder shared with the Quick Flex Rogue: 0, 2301, 4601, 9201, 18401, 26501, 36601, 51701, 74801, 100901, 140001, 193101, 235201, 290401, 350601. || Money: D-Bees gives 2D6x1,000 credits and 2D6x1,000 credits worth of spare parts, otherwise by chosen O.C.C.; Coalition War Campaign printed 209 gave 2D4x1,000 credits or equivalent in stolen valuables as well as some basic supplies. The spare parts are a restrictions line, not coin. || Vulnerabilities: D-Bees prints Clearly inhuman appearance can be a liability; Coalition War Campaign printed 208 gave R.C.C. Penalties: clearly inhuman in appearance, making disguise impossible. D-Bees adds the 5-6 foot reach, and M.D.C. by armor or other external means (Coalition War Campaign: by armor only). || Equipment: home-built armor is the Personalized Light or Medium M.D.C. Body Armor row, the nearest in the catalog; the visor is the Sunglasses or Tinted Visor row; backpack or satchel is the backpack. The energy weapon of choice is stored as four catalog options. || Not carried into the body, which is kept as written from Coalition War Campaign: D-Bees gives alignments as Scrupulous (25%), Unprincipled (30%) or Anarchist (25%), says half of the under quarter million are in America and Canada, and adds a life span of 3D6+56 years and a slave market value of 5D6x1,000 credits."
---

## Lore

The Trimadore are tall, lanky D-bees with a long thick neck, a small head,
long thin limbs, two-fingered hands and wide feet. They are quiet, peaceful
tinkerers with an uncanny gift for electronics, mechanics and building:
always taking something apart to see how it works and putting it back
together, and wonderful at jury-rigging. Most build their own armor from
scrap. They make natural Operators and Techno-Wizards, and are also known as
Fixers. Fewer than a quarter million exist, perhaps under 100,000 on Earth.

## GM Notes

Any alignment, mostly anarchist or unprincipled. Seven to eight feet, 180
to 220 lbs. Most avoid combat. Their skill earns good money as Operators and
mechanical engineers. All are literate in at least one language besides
their own. Favorite weapons are lasers and multi-weapon systems.
',
       updated_at = datetime('now')
 WHERE class_id = 'trimadore'
   AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.208-209') > 0
   AND length(markdown) = 8338;

-- == kremin-cyborg ==
UPDATE imported_classes
   SET markdown = '---
id: kremin-cyborg
name: Kremin Cyborg
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.111-114
category: rcc
tags: [combat, augmented]
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+4"
  MA: "3d6+2"
  PS: "2d6+24"
  PP: "1d4+22"
  PE: "N/A"
  PB: "1d6+6"
  Spd: "4d6+108"
mdc_base: "280"
ppe_base: "1d4"
horror_factor: 9
psionics_allowed: false
starting_money: "1d4x1000"
bonuses:
  combat: { attacks: 1, disarm: 2, entangle: 1, pull_punch: 3 }
  saves: { psionics: 2, possession: 6, other: [ { label: "vs illusions and hypnosis", bonus: 3 } ] }
  at_level:
    - { level: 2, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Kremin. The built-in translator speaks every Earth language at 96% (see natural abilities)." }
    - { name: "Literacy: Native Language", base: 96, per_level: 0, note: "Literate in the Kremin language at 96%." }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%" }
    - { name: "Philosophy", base: 45, per_level: 5, note: "+15%" }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "By tradition every Kremin is trained in the sword and self-defense." }
    - { name: "Military Etiquette", base: 55, per_level: 5 }
    - { name: "Computer Operation", base: 55, per_level: 5 }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5 }
    - { name: "Radio: Basic", base: 55, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Expert for explorers and lawmen, the line stored here. Civilian Kremin have Hand to Hand: Basic instead." }
  mos:
    choose: 1
    note: "Select one area of specialty, as the CS Technical Officer does. Every skill under it is granted in addition to the R.C.C. skills."
    options:
      - id: "communications"
        name: "Communications MOS"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5 }
          - { name: "Cryptography", base: 35, per_level: 5 }
          - { name: "Electronic Countermeasures", base: 45, per_level: 5 }
          - { name: "Laser Communications", base: 45, per_level: 5 }
          - { name: "Radio: Basic", base: 70, per_level: 5 }
          - { name: "T.V./Video", base: 35, per_level: 4 }
          - { choose: 1, categories: ["Communications"], bonus: 10 }
      - id: "electrician"
        name: "Electrician MOS"
        skills:
          - { name: "Mathematics: Advanced", base: 55, per_level: 5 }
          - { name: "Basic Mechanics", base: 45, per_level: 5 }
          - { name: "Electrical Engineer", base: 45, per_level: 5 }
          - { name: "Computer Operation", base: 60, per_level: 5 }
          - { name: "Computer Programming", base: 40, per_level: 5 }
          - { name: "Computer Repair", base: 40, per_level: 5 }
          - { choose: 1, categories: ["Communications", "Electrical"], bonus: 10 }
      - id: "mechanic"
        name: "Mechanic MOS"
        skills:
          - { name: "Automotive Mechanics", base: 45, per_level: 5 }
          - { name: "Basic Electronics", base: 45, per_level: 5 }
          - { name: "Computer Operation", base: 50, per_level: 5 }
          - { name: "Locksmith", base: 35, per_level: 5 }
          - { name: "Mechanical Engineer", base: 40, per_level: 5 }
          - { name: "Vehicle Armorer", base: 40, per_level: 5 }
          - { choose: 1, categories: ["Mechanical", "Electrical"], bonus: 10 }
      - id: "robotics"
        name: "Robotics MOS"
        skills:
          - { name: "Computer Programming", base: 40, per_level: 5 }
          - { name: "Robots & Power Armor", base: 71, per_level: 3 }
          - { name: "Robot Electronics", base: 50, per_level: 5 }
          - { name: "Robot Mechanics", base: 35, per_level: 5 }
          - { name: "Vehicle Armorer", base: 35, per_level: 5 }
          - { choose: 2, categories: ["Mechanical", "Electrical"], bonus: 10 }
      - id: "technician"
        name: "Technician MOS"
        skills:
          - { name: "Basic Electronics", base: 40, per_level: 5 }
          - { name: "General Repair & Maintenance", base: 50, per_level: 5 }
          - { name: "Research", base: 50, per_level: 5 }
          - { name: "Sensory Equipment", base: 45, per_level: 5 }
          - { choose: 4, categories: ["Technical", "Science"], bonus: 15 }
      - id: "medic"
        name: "Medic MOS"
        skills:
          - { name: "Biology", base: 45, per_level: 5 }
          - { name: "Field Surgery", base: 31, per_level: 4 }
          - { name: "Medical Doctor", base: 65, per_level: 5 }
          - { name: "Paramedic", base: 55, per_level: 5 }
          - { choose: 2, categories: ["Medical"], bonus: 10 }
      - id: "weapons"
        name: "Weapons MOS"
        skills:
          - { name: "Mathematics: Advanced", base: 60, per_level: 5 }
          - { name: "Demolitions", base: 70, per_level: 3 }
          - { name: "Demolitions Disposal", base: 75, per_level: 3 }
          - { choose: 4, categories: ["Weapon Proficiencies"] }
  occ_related_skills:
    count: 3
    categories: ["Communications", "Domestic", "Medical", "Military", "Physical", "Pilot", "Pilot Related", "Rogue", "Science", "Technical", "Weapon Proficiencies"]
    note: "As the CS Technical Officer: Communications Any (+5%). Domestic Any. Electrical, Science and Wilderness: none unless part of the MOS. Espionage, Horsemanship and Cowboy: none."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 8, count: 1 }
      - { level: 10, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
  secondary_skills:
    count: 3
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "clothing", qty: "1d6" }
  - { item_id: "vibro-katana", qty: 1 }
  - { choose: 1, label: "an Earth energy weapon of choice", qty: 1, from: ["wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "ng-l5-northern-gun-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle"] }
natural_abilities:
  - { name: "Full Conversion Alien Cyborg", description: "No hit points or S.D.C.; a mega-damage cyborg of alien alloys. P.S., P.P. and Spd are bionic; P.E. does not apply. Spd 4D6+108 is 76 to 90 mph (121.6 to 144 km). The figures stored are those of explorers, law enforcement officers and combat based Kremin, with some males in construction, heavy labor or mining (about 20% of the people)." }
  - { name: "Civilian Kremin", description: "Civilian males, females and children roll P.S. 1D6+20, P.P. 1D6+16, P.B. 1D6+8 and Spd 2D6+77 (53 to 60 mph, 85 to 96 km) instead, with P.E. not applicable. Reduce the M.D.C. of civilian males by 20%, civilian females by 30% and teenagers and children by 50%. Level of conversion, roll or pick: 01-55% both arms and legs bionic with a reinforced spine; 56-85% full conversion except the head, a reinforced skull likely; 86-00% full conversion including the head, made to look natural and alive. Common features: built-in radio/receiver, clock calendar, fingerjack, gyro-compass and one of choice. The head and natural senses are not usually augmented: 20/20 color vision, hearing twice as keen as a human''s. Civilians also have the psionic dampers, nano restorers and energy fist. Males average 8 feet and 600 to 800 pounds, females 7 feet and 400 to 500 pounds; the +1 attack per melee is for adults only." }
  - { name: "M.D.C. by Location", description: "Head 110, hands 30 each, arms 95 each, feet 50 each, legs 130 each, Multi-Weapon Blade and sheath 60, main body 280." }
  - { name: "Psionic Dampers and Blockers", description: "Implants in the living brain stop psychics reading surface thoughts, emotions or aura, sensing good or evil, or making a full telepathic probe: in effect a permanent mind block." }
  - { name: "Retro-Mechanic Nano Restorers", description: "Rechargeable internal nano-machines repair internal and external damage. Severe damage needs raw materials (M.D.C. plating, circuitry, even whole bionic limbs from Earth), which the nanites integrate into the more advanced Kremin body until it is as good as new. The traditional vest and cowl is a soft M.D. metal with the look of thin vinyl (25 M.D.) and is repaired the same way, even when ripped to shreds." }
  - { name: "Energy Fist", description: "Studs behind each hand''s knuckles generate a field: a 4D6 M.D. punch, or a short blast of 2D6, 3D6 or 4D6 M.D. as desired to 500 feet (152 m); limited to four punches or two blasts per melee round, however many attacks the character has, while the field recharges." }
  - { name: "Multi-Weapon Blade", description: "Every Kremin carries one by tradition; it strongly resembles a Japanese short sword: cuts like a vibro-blade for 2D6 M.D., stuns by touch (5D6 S.D.C., victim knocked down, loses two melee attacks and initiative), or fires a 6D6 M.D. blast to 1200 feet (366 m), 12 blasts before recharging in its special sheath." }
  - { name: "Bionic Systems of Note", description: "Finger jack and headjack, amplified hearing, built-in language translator (speaks every Earth language at 96%), full optics, molecular analyzer, voice amplification, built-in radio receiver and transmitter, laser finger tool, climb cord, 1D4 secret compartments and three more features of choice (any, including weapons). A Kremin may acquire any cybernetics or bionics available in North America." }
restrictions:
  - "Stored as its own R.C.C. with the skill program Coalition War Campaign gave it. D-Bees of North America instead has a Kremin take an O.C.C.: nearly any Adventurer or Scholar O.C.C. or a basic soldier or law enforcement O.C.C.; Combat Cyborg, Headhunter and military O.C.C.s are rare."
  - "Clearly a cyborg; disguise is impossible."
  - "Magic: none. Psionics: none. Magic and psionic O.C.C.s are out of the question."
  - "The Coalition States have a standing order to destroy every Kremin on sight; thanks to the CS, Kremin are widely believed to be hostile alien invaders on the run."
  - "Also starts with a satchel, some personal items and the Multi-Weapon Blade (a natural ability here); the vibro-katana stands for the one long, Japanese-style Vibro-Sword (3D6 M.D.) the book lists."
extraction_notes: "Until this update the class followed Rifts World Book 11: Coalition War Campaign printed 209-211; it now follows Rifts World Book 30: D-Bees of North America printed 111-114 (stat block on 113-114), the newer printing, by the ruling of 2026-10-04. Both entries were read off page renders. What follows this first part is the Coalition War Campaign record, corrected below where D-Bees prints another figure. || D-Bees revisions taken: M.A. 3D6+2 (Coalition War Campaign printed 209 gave 3D6). The stored physical line is the one D-Bees prints for explorers, law enforcement officers and combat based Kremin: P.S. 2D6+24 (Coalition War Campaign printed 209 gave 22+1D6), Spd 4D6+108 (Coalition War Campaign printed 209 gave a fixed 132), P.P. 1D4+22 and P.B. 1D6+6 unchanged. D-Bees also prints a civilian line (P.S. 1D6+20, P.P. 1D6+16, P.B. 1D6+8, Spd 2D6+77), the civilian M.D.C. reductions and a level-of-conversion table; these are prose in the Civilian Kremin natural ability. I.Q., M.E., the M.D.C. by location, Horror Factor 9 and P.P.E. 1D4 are the same in both books. || Bonuses: D-Bees printed 113 adds +1 melee attack (adults only), +2 to disarm, +1 to entangle and +3 to pull punch, none of which Coalition War Campaign prints; all four are stored in bonuses.combat, the attack on the reading that a played Kremin is an adult. The Horror Factor ladder and the psionic blocker saves are the same in both books. || R.C.C. skills, D-Bees printed 113: W.P. Sword and Philosophy (+15%, stored 45) are added; Literacy in the native language is 96% flat (60 was stored from the Technical Officer list); Math: Basic is +25%, stored 70 (75 was stored from the Technical Officer list); native language 98% unchanged; Hand to Hand is Basic for civilians and Expert for explorers and lawmen, Expert kept (Coalition War Campaign printed 210: Hand to hand: expert). || Class shape: D-Bees no longer prints the CS Technical Officer skill program or the ''Borg experience table. It has the Kremin take an O.C.C. and use that O.C.C.''s experience table, its R.C.C. skills being in addition to the O.C.C.''s. The category, the Technical Officer skills, MOS, related and secondary skills and the ''Borg xp_table are kept as Coalition War Campaign printed 210 gave them; D-Bees does not restate them. || Bionics: the Energy Fist blast is 2D6, 3D6 or 4D6 M.D. as desired (Coalition War Campaign printed 210 gave 4D6 only); D-Bees prints 1D4 secret compartments and three features of choice (Coalition War Campaign printed 210 gave various secret compartments), a 25 M.D. vest and cowl, and any additional cybernetics. The translator''s 96% in every Earth language and the lines Hit Points not applicable and S.D.C. a mega-damage cyborg are Coalition War Campaign only; D-Bees does not restate them and calls Kremin partial (55%) or full conversion (45%) cyborgs. || Equipment, D-Bees printed 113: 1D6 sets of clothing, a canteen and one long Japanese-style Vibro-Sword (3D6 M.D.) are added to the Coalition War Campaign list; the sword is stored as the Vibro-Katana row (Rifts World Book 8: Japan printed 117, 3D6 M.D.), the catalog row matching the printed description and damage. The satchel and personal items stay prose. Money: both books print 1D4x1000; D-Bees words it as credits worth of tradeable goods. || Other D-Bees lines, not stored as fields: alignments any, with Principled 25%, Scrupulous 35%, Unprincipled 15% and Anarchist 15% common (Coalition War Campaign printed 209 gave unknown, most anarchist and unprincipled); life span 5D6+70 years; males 8 feet and 600-800 pounds, females 7 feet and 400-500 pounds (Coalition War Campaign gave 8 feet, 600 pounds); slave market value 2D4x10,000; 20,000-30,000 Kremin refugees are loose in North America after 109 P.A., where Coalition War Campaign knew three dozen explorers. The Lore and GM Notes below are still the Coalition War Campaign account. || COALITION WAR CAMPAIGN RECORD: Read from printed 209-211 (cache p210-p212); the stat block on printed 209, the M.D.C. locations, bionics and bonuses on printed 210 and the 1D4x1000 credits on printed 211 were checked against 200 dpi renders. || Attributes: P.S. 22+1D6 and P.P. 22+1D4 are stored as rolled dice; P.E. is printed not applicable (N/A); Spd is a fixed 132. || M.D.C.: by location; mdc_base holds the main body''s 280 and the other locations are listed as a natural ability. No hit points, no S.D.C., so no men_of_arms line. || Bonuses: the psionic blockers give +2 vs psionic attack, +3 vs illusions and hypnosis (saves.other) and +6 vs possession, unconditional. The page heads the horror-factor line R.C.C. Skills but it is a save bonus: +1 at levels 2, 4, 6, 8, 10, 12, 14. || Skills: the book says they are fundamentally the same as the CS Technical Officer of the Rifts RPG. The Technical Officer row in the catalog (Rifts Ultimate Edition p.236-237) is copied here: its O.C.C. skills, the seven-MOS choice, three related plus its schedule and three secondary plus its schedule. Its Hand to Hand: Basic is replaced by Expert, which the Kremin page states; no hand_to_hand block, as no price is printed. Language: Native Tongue is the Kremin tongue; the translator''s 96% in every Earth language is prose. The Technical Officer itself is humans-only, so pairing the two is not the route. || XP: the page says to use the ''Borg experience table, which is in the Rifts RPG, not in this book; printed 224 prints no Kremin ladder. The import stored none under the rule then (a race carries a ladder only when its own book prints one for it). Since 2026-09-26 xp_table carries the ''Borg ladder, copied from combat-cyborg (RUE printed 295, the Combat Cyborg, Headhunter and Robot Pilot column), the ladder splugorth-conservator and hawrk-ka also carry; Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder, and that rule replaced the own-book-only one. || Equipment: the utility belt, backpack (the satchel printed beside it is not stored), tool kit, flashlight and an Earth energy weapon of choice; the Multi-Weapon Blade and energy fists are built in and are natural abilities, not gear. Psionics none: psionics_allowed false."
---

## Lore

The Kremin are alien cyborg explorers who came through a Rift, drawn by
Earth''s magic and its many life forms. Minutes after they arrived their
homeworld reported that the dimensional portal was tearing itself apart, so
the explorers are stranded until it can be repaired. Confident of rescue, they
carry on their mission to observe strange new worlds. They say they are
peaceful ambassadors, fight mostly in self-defence and keep their distance
from humans and D-bees alike, but nobody really knows what they want. Their
bionics are a little more advanced than Triax''s.

## GM Notes

Alignment unknown; most seem anarchist or unprincipled, and their brain
implants block any reading of their thoughts. Eight feet, 600 lbs. Only
about three dozen came through; the CS has destroyed and dissected nine and
orders the rest shot on sight, so they have fled to the western wilderness,
Texas, Minnesota, Free Quebec and Michigan. Perhaps 30, at most 100, roam
the Americas. They favor heavy weapons, variable lasers and vibro-blades.
',
       updated_at = datetime('now')
 WHERE class_id = 'kremin-cyborg'
   AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.209-211') > 0
   AND length(markdown) = 11771;

-- Read the result back. A guard that matched nothing must fail here, not pass.

SELECT 'all 6 classes cite D-Bees of North America' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE (class_id = 'nmbyr-gorilla-man' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.143-144') > 0)
    OR (class_id = 'tirrvol-sword-fist' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.201-203') > 0)
    OR (class_id = 'quick-flex-alien' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.168-170') > 0)
    OR (class_id = 'vanguard-brawler' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.208-210') > 0)
    OR (class_id = 'trimadore' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.206-208') > 0)
    OR (class_id = 'kremin-cyborg' AND instr(markdown, 'source_book: Rifts World Book 30: D-Bees of North America p.111-114') > 0);

SELECT 'none still carries its old source line' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'nmbyr-gorilla-man' AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.202-203') > 0)
    OR (class_id = 'tirrvol-sword-fist' AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.203-205') > 0)
    OR (class_id = 'quick-flex-alien' AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.205-206') > 0)
    OR (class_id = 'vanguard-brawler' AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.206-208') > 0)
    OR (class_id = 'trimadore' AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.208-209') > 0)
    OR (class_id = 'kremin-cyborg' AND instr(markdown, 'source_book: Rifts World Book 11: Coalition War Campaign p.209-211') > 0);

SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('nmbyr-gorilla-man', 'tirrvol-sword-fist', 'quick-flex-alien', 'vanguard-brawler', 'trimadore', 'kremin-cyborg') AND instr(markdown, char(13)) > 0;

SELECT 'all 6 are still live and published' AS assertion, count(*) AS got, 6 AS want
  FROM imported_classes
 WHERE class_id IN ('nmbyr-gorilla-man', 'tirrvol-sword-fist', 'quick-flex-alien', 'vanguard-brawler', 'trimadore', 'kremin-cyborg') AND deleted_at IS NULL AND status = 'published';

INSERT INTO data_script_runs (filename) VALUES ('~095-d-bees-updates-six-cwc-classes.sql');
