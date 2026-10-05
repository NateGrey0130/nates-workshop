-- Give China 2's Mystic Martial Art Powers their later levels, part 1 of 2
-- 11 classes, each replaced whole: chun-tzu, blind-mystic, spirit-host, jian-shih, nei-chia-wu-shih, wai-chia-wu-shih, geofront-chi-commando, geofront-chi-warrior, geofront-metal-warrior, geofront-military-specialist, geofront-scout-ranger.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~168-china-2-martial-art-power-levels-part-1.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Part 1 of 2 (the read-backs of all twenty-two classes outrun one command).
--
-- Close-out package C4, the China 2 half: the Mystic Martial Art Powers of
-- Rifts World Book 25: China 2 printed 25-41 beyond level 1, and Body Hardening
-- (printed 92-94).
--
-- The eleven powers each print a table of fifteen levels. The classes were
-- imported with level 1 only. Since BOOK-INGEST-AUDIT F117 an ability
-- definition takes `progression`, its later levels as text the sheet shows
-- for a held ability (display only: nothing a later level says is added to
-- the character's numbers; F117 was closed without a powers table, on Nate's
-- word). Each of the 48 definitions across fourteen classes now carries its
-- power's levels 2-15, and five more are added to the Enlightened Demon; the
-- copies are identical, generated from one set read off renders and checked
-- level by level against renders.
--
--   The fourteen that hold a power: chun-tzu, blind-mystic, spirit-host,
--     jian-shih, nei-chia-wu-shih, wai-chia-wu-shih, fu-yao-da-chia and the
--     seven Geofront classes. wai-chia-wu-shih's fixed power gains a
--     one-option group, because only a HELD ability's table is shown.
--   enlightened-demon (printed 99): picks one of five powers at 10th level
--     and starts it at the tenth level of advancement: a group at_levels [10].
--   geofront-gun-master (printed 138-140): its own art, Tao Jen Qiang, gains a
--     definition with its own levels 2-15.
--   soothsayer and the three Geo-Borgs: their pages print no power; their
--     notes stop citing F117 as a gap.
--   demon-and-dead-slaver, goblin-wrangler: their pages give no power either
--     (the notes said F117); the eleven Body Hardening definitions they and
--     fu-yao-da-chia carry take three corrections and Feign Death's
--     held-breath steps.
--
-- NOT DONE, and each class says so: the body hardening picks after creation
-- (fu-yao-da-chia one more at 3, 6, 9, 12, 15; demon-and-dead-slaver at 4, 8,
-- 12; goblin-wrangler at 3, 6, 9, 12, 15). A pick group holds one count for
-- every level it lists, and these classes take several at creation and one at
-- each later level from the same list.
--
-- Production held no saved character on any of the twenty-two (queried
-- 2026-10-05). No option is renamed.

-- == chun-tzu ==
UPDATE imported_classes
   SET markdown = '---
id: chun-tzu
name: Chun Tzu
system: rifts
source_book: Rifts World Book 25: China 2 p.45-48
category: occ
tags: [combat, scholar, leader]
occ_group: men-of-arms
xp_table: [0, 2241, 4481, 9101, 18301, 30601, 42901, 62301, 85601, 105901, 155001, 210001, 285001, 370001, 440001]
attribute_requirements: { IQ: 12, ME: 10 }
sdc_base: "6d6+32"
starting_money: "3d6x100"
bonuses:
  attributes: { PS: 1, PE: 1, PP: 1 }
  combat: { strike: 2, pull_punch: 2 }
  saves: { spell_magic: 1, pain: 3, horror_factor: 3, possession: 1 }
  at_level:
    - { level: 3, combat: { initiative: 1 } }
    - { level: 4, saves: { possession: 1 } }
    - { level: 6, combat: { initiative: 1 } }
    - { level: 7, saves: { possession: 1 } }
    - { level: 9, combat: { initiative: 1 } }
    - { level: 11, saves: { possession: 1 } }
    - { level: 12, combat: { initiative: 1 } }
    - { level: 15, combat: { initiative: 1 }, saves: { possession: 1 } }
psionics:
  type: "none"
  isp_base: "M.E. attribute number plus 3d6, +5 per level of experience"
skills:
  occ_skills:
    - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%" }
    - { name: "Detect Ambush", base: 50, per_level: 5, note: "+20%" }
    - { name: "Go", base: 45, per_level: 5, note: "+15%; the book prints Games: Wei Qi (the Game of Go)." }
    - { name: "Imperial Bureaucracy & Administration", base: 20, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 95%." }
    - { name: "Literacy: Chinese", base: 90, per_level: 5, note: "The book prints Literacy: Chinese characters/ideograms at 90%." }
    - { name: "Literacy: Ancient & Classical Chinese", base: 75, per_level: 5, note: "+25%" }
    - { name: "Lore: Chinese Classical Studies", base: 65, per_level: 5, note: "+25%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Paramedic", base: 50, per_level: 5, note: "+10%" }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { choose: 4, from: ["Field Armorer & Munitions Expert", "Camouflage", "Demolitions", "Military Etiquette", "Military Fortification", "Recognize Weapon Quality", "Trap Construction", "Trap/Mine Detection"], bonus: 10, note: "Military skills: any four (+10% each). The book''s two Armorer/Field Armorer entries (Traditional Chinese Weapons, Modern Weapons) are both the catalog''s Field Armorer & Munitions Expert." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Calligraphic Forgery", base: 35, per_level: 5, note: "+10%; the printed bonus is cut off after +10." }
    - { name: "Dickering", base: 20, per_level: 4 }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming", "Wrestling"], note: "Physical skills: any two. The book offers Aerobic Athletics or General Athletics as one choice." }
    - { choose: 3, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.s: any three of Battle Axe, Paired Weapons, Pole Arm, Siege Weapons, Spear, Large Sword, Small Sword or Trident. Battle Axe is the catalog''s W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.s: any two." }
    - { choose: 2, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.s: any two. The book''s Spear (Throwing) is the catalog''s W.P. Spear." }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.s: any two." }
    - { name: "W.P. Chiang Zhu Spear", base: 0, per_level: 0, note: "Granted by the Chun Tzu''s chi training." }
    - { choose: 1, from: ["Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Jade Fan (Chi Hsuan Men)", "Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Any of the Advanced Chinese Hand to Hand martial arts. The character starts at the 5th level of advancement in the chosen style; apply its level 2-5 bonuses by hand. The book prints no price for changing it." }
  occ_related_skills:
    count: 3
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Jump Bike Combat", "Fighter Combat: Basic", "Fighter Combat: Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", only: ["Begging", "Computer Hacking", "Concealment", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Games: Tiao Qi (Chinese Checkers), Xiang Qi (Shogi) or Western Chess; the first two are Domestic rows, and the catalog holds no Western Chess row. Military: none other than those above. Physical: any except Acrobatics, Gymnastics and Boxing, unless selected previously. Pilot: any except military vehicles, robots and power armor. Pilot Related: none. W.P.: any except Heavy Weapons, Heavy Energy Weapons or Sharpshooting. All new skills start at level one proficiency."
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 6, count: 2 }
      - { level: 8, count: 2 }
      - { level: 10, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Jump Bike Combat", "Fighter Combat: Basic", "Fighter Combat: Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", only: ["Begging", "Computer Hacking", "Concealment", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 5, 7, 9, 11 and 13, from the related list and its limits, at base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 11, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 2, note: "Two traditional Chinese weapons besides the special spear, with 3D6 units or rounds of ammunition for each projectile weapon." }
  - { item_id: "energy-weapon-of-choice", qty: 1, note: "One pistol-sized energy weapon." }
  - { item_id: "e-clip", qty: 3 }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged traveling clothes of cotton, wool and leather." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "dress-clothing", qty: 1, note: "A complete suit of lightweight embroidered silk indoor clothing: slippers, pants, shirt, long jacket, robe, scarf and hat." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book." }
  - { item_id: "pencil", qty: 1 }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block; just add water." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "utensil-kit", qty: 1, note: "Two sets of chopsticks, one rough, the other delicate." }
  - { item_id: "knife", qty: 1, note: "A cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "A small meat cleaver." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "A belt pouch." }
  - { item_id: "climbing-rope-per-foot", qty: 30, note: "30 feet (9.1 m) of climbing rope." }
  - { item_id: "canteen", qty: 2, note: "Bamboo canteens of water." }
special_abilities:
  - { choose: 1, from: ["Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)", "Mystic Martial Art Power: Pao Chih (Animus Development)", "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)", "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)", "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)", "Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"], note: "Choose one Mystic Martial Art Power (printed 47); the chosen power''s level table is shown on the sheet." }
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"
    description: "No Sword Chi technique works without a blade the character knows and has named. Level 1: after at least 24 hours with the blade, awaken it as a personal Chi Blade with its own 2D6+8 I.S.P. (rolled once). Blade Chi Healing restores 3D6 points (1D6 M.D.C. to a mega-damage being) for 8 I.S.P.; Blade Chi Awareness warns of potential enemies within a range of less than 10 ft (3 m), through walls, floors and ceilings, for 2 I.S.P.; Blade Chi Mega-Damage turns the blade''s normal damage into M.D. against supernatural beings and M.D.C. technology (a 1D8 short sword does 1D8 M.D.). (printed 29-30.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Double the Chi Blade''s I.S.P." }
      - { level: 4, text: "The personal Chi Blade does an extra +1D6+2 M.D." }
      - { level: 5, text: "Blade Chi Resonance: the Chi Blade senses other significant weapons, above all self-aware or strongly magical ones, up to one mile (1.6 km) away, with their general direction and distance, whether they are stronger, weaker or about its equal, and whether one is wielded by great evil." }
      - { level: 6, text: "Blade Chi Power of Return: a lost or stolen Chi Blade teleports back to its owner, usually within 24 to 48 hours, arriving with just 1 I.S.P." }
      - { level: 7, text: "Awaken Other Chi Blades: a second Chi Blade can be awakened after the same 24 hours with it. 20 I.S.P. an attempt; roll under M.A. on a D20, a failed attempt may be repeated after no less than 24 hours, and a blade that fails three times is lifeless." }
      - { level: 8, text: "The personal Chi Blade does a further +1D6+2 M.D." }
      - { level: 9, text: "A second Chi Blade, if the character has one, gains all the bonuses and abilities of the first, and the two can be used as Paired Weapons." }
      - { level: 10, text: "Double the Chi Blade''s I.S.P." }
      - { level: 11, text: "A third Chi Blade can be awakened, as at level 7." }
      - { level: 12, text: "The first personal Chi Blade does an extra +10 M.D." }
      - { level: 13, text: "Personal Chi Blade Sentience: the primary blade (the first or second awakened) becomes fully aware, speaks telepathically with its wielder while held, has a 01-20% chance (rolled once) of spoken speech, and mirrors its owner''s alignment." }
      - { level: 14, text: "The Chi Blade can hide its I.S.P. and its sentience from psychics, See Aura and other ways of detecting psychic energy or emotion." }
      - { level: 15, text: "Add 6D6+6 to the primary Chi Blade''s I.S.P. and the same amount to the wielder''s I.S.P. Base." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Pao Chih (Animus Development)"
    description: "Level 1: in four melee rounds (one minute) of full concentration (no other action, and no other use of his I.S.P., while evoking), evoke an Animus, a living double made of whatever I.S.P. the character invests. It lives inside the body with its own separate I.S.P. pool, burning 1 I.S.P. an hour (1 per half hour once it can be detached, at level 10); what is left returns when it is reabsorbed and is lost if the Animus is destroyed. It is perpetually alert, tries to wake the character when he sleeps or is knocked out, can move the body out of danger, and knows and can use all his I.S.P. abilities from its own pool. Once it is evoked the character perceives through the Animus''s senses. (printed 33.)"
    progression:
      - { level: 2, text: "Animus Sense P.P.E. and Dragon Lines: senses the amount, type and direction of any flow of P.P.E., I.S.P. or Chi, and creatures disrupting or consuming it, within one mile (1.6 km)." }
      - { level: 3, text: "Animus Spectral Defense: the Animus automatically absorbs incoming energy, I.S.P.-based and magical P.P.E.-based attacks, so they do half damage to the character." }
      - { level: 4, text: "Animus Sense Souls and Spirits: senses the P.P.E., I.S.P. and Chi inside spirits, beings and mystical objects within 30 ft (9.1 m), with its type, amount, location and movement." }
      - { level: 5, text: "Animus M.D.C. Defense: a magical barrier of 30 M.D.C. for 3 I.S.P. a melee round, taken from the Animus." }
      - { level: 6, text: "Evoke the Animus in three melee rounds." }
      - { level: 7, text: "Animus Sense Life: feels every living creature within 30 ft (9.1 m), even in darkness or smoke, each one''s health, injury, poison or hunger, and its position (half the usual penalties for being blind)." }
      - { level: 8, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 9, text: "Evoke the Animus in two melee rounds." }
      - { level: 10, text: "Detach Animus: while the character stays still in meditation the Animus walks out, up to 300 ft (91.5 m) from the body, at his normal Spd, using its Chi senses and his Chi abilities. It cannot handle or pass through physical objects, teleports back into the body at will, and returns at once if contact is lost. Detached, it burns 1 I.S.P. every half hour." }
      - { level: 11, text: "Add 1D6x10+10 to the character''s Permanent I.S.P. Base." }
      - { level: 12, text: "Evoke the Animus in one melee round." }
      - { level: 13, text: "Animus Absorb: the Animus draws on dragon lines and other P.P.E. sources at 1 I.S.P. a melee round, up to double the character''s maximum I.S.P. Base. Only the Animus can use it; on merging, the character gets back no more than he first placed in it." }
      - { level: 14, text: "Add 1D6x10+30 to the character''s Permanent I.S.P. Base." }
      - { level: 15, text: "Evoke the Animus instantly, at will." }
  - name: "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)"
    description: "Stance bonuses apply only in that stance. Level 1: Viper Stance (thermal vision 60 ft; Fang Fingers 3D6 M.D. or 5D6 S.D.C.; no M.D.C.; six attacks a melee in all, +5 strike, +4 parry, +5 damage, +4 roll; no pulled punches); Rat Snake Stance (Knuckle Punch 2D6+10 M.D. or 3D6 S.D.C.; M.D.C. equal to P.E. +20; +1 attack, +4 strike, +3 parry, +3 roll); Art of Melting (silent movement as Prowl 60% +3% per level; escape once detected 70% +2% per level); and one Art of Invisibility, with one more at each of levels 3, 7, 10 and 13: Clouding the Mind (vanish for one melee action, 2 I.S.P. per person who looks into the character''s eyes or face, and for that moment also hidden from those who track P.P.E., I.S.P. or living spirits), Deception (silent movement, automatic while unsuspected, 60% +3% per level under inspection), Evasion (stay behind a foe and keep attacking unseen, or shadow someone for up to two melee rounds per level; automatic if the foe is unaware, otherwise 60% +3% per level; it fails if a friend of the victim can call a warning or the victim''s back is to a wall, and once sighted the character must vanish first, by Clouding the Mind or Vanishing, to resume it), Hiding (undetected unless the area is well lit and carefully inspected, then 60% +4% per level) or Vanishing (disappear from plain view, 90% +1% per level in darkness with obstructions, -25% in good light and a further -15% on clear, flat ground). (printed 34-35.)"
    progression:
      - { level: 2, text: "Knockout or stun from behind, and Critical Strike on a Natural 18 or better." }
      - { level: 3, text: "Select one more Art of Invisibility." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Chilling Touch (The Vapor): claws do 5D6 M.D. a strike; or the Chilling Touch, which uses four melee attacks, does 3D6 direct to hit points (4D6 M.D. to mega-damage creatures), turns the skin gray and shriveled, and costs the victim initiative and half his attacks for the next two melee rounds." }
      - { level: 6, text: "Spitting Python Stance: Python Jab Long Distance, one a melee, hits up to 100 ft (30.5 m) away for 4D6 M.D. or 3D6 S.D.C.; Python Jab Hand to Hand does 5D6 M.D. or 4D6 S.D.C.; a Natural 20 with either is a Death Blow. M.D.C. equal to P.E. +30. +6 strike, +3 parry, +3 damage, +3 roll with impact; no pulled punches." }
      - { level: 7, text: "Select one more Art of Invisibility." }
      - { level: 8, text: "+1 attack per melee round and +1 on initiative." }
      - { level: 9, text: "Add 4D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 10, text: "Select one more Art of Invisibility." }
      - { level: 11, text: "Cobra Stance: every strike is a paralysis attack. A victim who fails to avoid or roll with it takes no damage but the body or the targeted limb is paralyzed for 3D6 melee rounds; one who rolls with it takes 2D8 M.D. or 1D8 direct to hit points instead. M.D.C. equal to P.E. +20. Four attacks a melee in all, +5 strike, +3 parry, +3 roll with impact." }
      - { level: 12, text: "Knockout, stun or Critical Strike (the character''s choice) from behind on a Natural 17 or better." }
      - { level: 13, text: "Select one more Art of Invisibility." }
      - { level: 14, text: "Add 2D4x10+24 to the character''s Permanent I.S.P. Base." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)"
    description: "Requires the Acupuncture skill. Level 1: Healing Tien-Hsueh for 6 I.S.P. a healing, each one melee action - 4D6 hit points, 2D6+10 S.D.C. or 3D8 M.D.C. restored, or a 40% +4% per level chance to cure illness, infection, fever or coma at once, or to repair, install or remove a cybernetic device, engine or machine. Tien-Hsueh Reversal for 5 I.S.P. - undoes any Tien-Hsueh effect, or a knockout, stun, dizziness, blindness, paralysis or other temporary shock, in one melee round; against the work of a higher-level master it takes 2D6 melee rounds per level of difference. One Finger Touch - no damage, +4 to strike, the delivery for every Tien-Hsueh attack. Tien-Hsueh Powers, one chosen at each of levels 3, 6, 8, 11 and 13: Blindness (2D6 hours blind at -10 to strike, parry, dodge and other combat rolls, 2D6 melee rounds if the victim rolls with the blow, nothing if parried or dodged; 8 I.S.P.), Blood Flow (2D8 direct to hit points past S.D.C. or S.D.C. armor, 1D8 past M.D.C. armor, or 1D8 M.D. or 2D8 P.P.E. dispelled against a supernatural creature; 10 I.S.P.), Electronic (start or stop any machine, device or vehicle by touch; 10 I.S.P.), Enlightenment Strike (frees a victim within 30 ft and in line of sight from possession, Chi control or mind control, taking a full melee round; 20 I.S.P.), Neural (paralyzes a declared limb for 3D6 minutes with no roll with impact, needing an 8 or better to strike, though the victim may still parry or dodge, the defender winning ties, and an arm or foot used to parry is itself paralyzed; 8 I.S.P.), Puppet-Dance (a grip on the back of the neck and a strike roll of 10 or higher makes the victim a living puppet with two attacks a melee and no bonuses, while the master''s own bonuses are halved and his skills are -20%; 15 I.S.P. on a natural being, 20 on a lesser supernatural being, 30 on a Fox or Monkey Spirit or a dragon hatchling, 50 on most Greater Demons, Immortals, Ghosts and Entities; it does not work on adult dragons, Elementals, Demon Lords, Demigods, Godlings or deities, the victim cannot be made to speak, and while he holds the puppet the master can perform no other Tien-Hsueh and nothing that spends I.S.P. or P.P.E.), Demon Strike (leaves a supernatural M.D.C. being or lesser creature of magic with only 1D4x10% of its M.D.C.; 32 I.S.P.) or Withering Flesh (removes all natural S.D.C., or only 1D6 S.D.C. if the victim rolls with impact, never touching hit points; 12 I.S.P.). (printed 35-37.)"
    progression:
      - { level: 2, text: "Internal Practice Advancement #1: +2 to M.E. and +1 to I.Q." }
      - { level: 3, text: "Select one Tien-Hsueh Power from the list." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Penetrating Tien-Hsueh: for 12 I.S.P. the character''s Tien-Hsueh powers reach through an M.D.C. body or M.D.C. armor, which no longer acts as a barrier." }
      - { level: 6, text: "Select one more Tien-Hsueh Power." }
      - { level: 7, text: "Internal Practice Advancement #2: +2 to P.P. and +1 to M.A." }
      - { level: 8, text: "Select one more Tien-Hsueh Power." }
      - { level: 9, text: "Long-Distance Tien-Hsueh: for 24 I.S.P. any Tien-Hsueh can be projected up to 400 ft (122 m) per level at a victim the character can see (binoculars, a scope or a monitor count) or is speaking with over a phone or radio; through contact with a detached spirit or animus it reaches that being''s body at any distance." }
      - { level: 10, text: "Add 5D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Select one more Tien-Hsueh Power." }
      - { level: 12, text: "Internal Practice Advancement #3: +2 to I.Q. and +1 to M.E." }
      - { level: 13, text: "Select one more Tien-Hsueh Power." }
      - { level: 14, text: "Knockout or stun on a Natural 17 or better." }
      - { level: 15, text: "Add 1D6x10+24 to the character''s Permanent I.S.P. Base." }
  - name: "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)"
    description: "Level 1: Mantis Armor for 5 I.S.P. - chitin plates with M.D.C. equal to the character''s S.D.C. +20 per level (hit points stay hit points), every attack able to do mega-damage, +4 parry, +2 disarm, +3 entangle. Mantis Hook Attack - 3D6 M.D. or 5D6 S.D.C. Spectral Praying Mantis for 20 I.S.P. - a human-sized (6 ft) animus evoked in three melee rounds of full concentration, burning 1 I.S.P. an hour and costing its maker 1 I.S.P. for each M.D.C. point of damage it takes. As a separate animus it has two attacks a melee, +4 strike, 2D6 M.D. or 4D6 S.D.C., +2 to save vs dispel, M.D.C. equal to its maker''s S.D.C. (20% of the M.D.C. of a mega-damage character) and may go no more than 1000 ft away; worn as power armor it gives +1 initiative, +1 disarm, +1 entangle, +2D6 damage and M.D.C. equal to the maker''s S.D.C. +20 (25% of the M.D.C. of a mega-damage character). Giant Mantis: it can be doubled in size up to three times (12, 24, 48 ft), each doubling giving +5 Supernatural P.S., +40 M.D.C. and +1D6 damage at -10% Spd and -1 dodge; the book prices each doubling at both 15 and 10 I.S.P. (printed 37-39.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Spectral Praying Mantis Advancement #1: the separate animus has four attacks a melee in all, +10 M.D.C., +2 to damage and +1 to Spd." }
      - { level: 4, text: "Tong Lun Body Hardening #1: +2 to P.P., +1 to M.E. and +14 S.D.C." }
      - { level: 5, text: "Evoke the Spectral Praying Mantis in two melee rounds." }
      - { level: 6, text: "Spectral Praying Mantis Advancement #2: the separate animus moves as fast as its maker with the same attacks per melee and may go up to 10 miles (16 km) away. Worn as power armor it gives +1 attack per melee, +20 M.D.C. to the armor, +6 to damage, +2 to Spd, +1 initiative, +1 disarm and +1 entangle." }
      - { level: 7, text: "Tong Lun Body Hardening #2: +16 S.D.C., +2 to Spd and +1 to P.P." }
      - { level: 8, text: "The combat moves of the Wrestling skill (pin, incapacitate, crush and bear hug) and +3D6 S.D.C., without Wrestling''s other bonuses." }
      - { level: 9, text: "Evoke the Spectral Praying Mantis in one melee round." }
      - { level: 10, text: "Add 4D6+20 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Spectral Praying Mantis Advancement #3: the animus no longer needs dispelling and stays around all the time, with its maker''s physical attributes, attacks and combat bonuses plus +30 M.D.C., +10 to damage and +4 to Spd. It remains even at zero I.S.P. (its attacks, Spd, M.D.C. and combat bonuses halved) and may go up to 50 miles (80 km) away. Worn as power armor it adds two extra melee attacks and +40 M.D.C." }
      - { level: 12, text: "Tong Lun Body Hardening #3: +14 S.D.C., +1 to M.E. and +1 to Spd." }
      - { level: 13, text: "Add 5D6+30 to the character''s Permanent I.S.P. Base." }
      - { level: 14, text: "Evoke the Spectral Praying Mantis instantly." }
      - { level: 15, text: "Spectral Praying Mantis Advancement #4: the mantis is now solid, cannot return to spectral form or be worn as power armor, and must eat and drink daily. Its usual size is about 24 ft (doubled twice) and it can be doubled four times (96 ft). Separate animus: +80 M.D.C., +10 to damage, +2 attacks per melee, +3 strike, +2 automatic dodge, +2 disarm, +2 entangle; at zero I.S.P. it stays, with attacks and combat bonuses halved. It may be up to 200 miles (320 km) from its maker." }
  - name: "Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"
    description: "Level 1: Chi Ball. Four full melee rounds (one minute) to evoke, then each melee round of gathering adds 1D4 I.S.P. to it, with no maximum but too hard to control past the character''s base I.S.P.; the amount gathered is held as long as the kata continues. Held in the hand and used to strike, it is harmless to mortals, living creatures, devices, machines and robots, but against demons, disembodied entities and other creatures of supernatural evil it does 1D6 M.D. per 10 I.S.P. stored (1D6x10 M.D. at 100). (printed 40-41.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Chi Ball Lens: for 3 I.S.P., looking through the Ball shows all I.S.P., Chi-bearing creatures, dragon lines and supernatural or spiritual entities within about 60 ft (18.3 m), for as long as the character keeps looking through an intact Ball." }
      - { level: 4, text: "Meditation Advancement #1: +2 to I.Q., M.E. and M.A." }
      - { level: 5, text: "Chi Ball Defense: for 4 I.S.P. the Ball is a shield against psychic, magical, spiritual and demonic energies, with M.D.C. equal to the I.S.P. stored in it; useless against physical weapons, bullets, lasers and non-magical energy blasts." }
      - { level: 6, text: "Evoke the Chi Ball in one melee round." }
      - { level: 7, text: "Chi Ball Calm: for 2 I.S.P., +5 to save vs Horror Factor and other fear while holding the Ball." }
      - { level: 8, text: "Add 5D6+30 to the character''s Permanent I.S.P. Base." }
      - { level: 9, text: "Meditation Advancement #2: +1 to M.A. and +2 to save vs Horror Factor." }
      - { level: 10, text: "Second Chi Ball Formation: two Chi Balls can be created at once." }
      - { level: 11, text: "Chi Ball Levitation: for 10 I.S.P. the character rises with the Ball, holding it or standing on it, to a maximum height of 500 ft (152 m) per level." }
      - { level: 12, text: "Add 4D6+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Throwing the Chi Ball: for 10 I.S.P. a throw, the Ball arcs through a target and returns; against demons and creatures of supernatural evil it does 2D8 M.D. on a glancing blow and 5D10 M.D. on a solid hit, and is harmless to anything else. +2 to strike; range 100 ft (30.5 m) per level." }
      - { level: 14, text: "Meditation Advancement #3: +1 to M.E. and M.A., +2 to save vs disease and +2 to save vs Horror Factor." }
      - { level: 15, text: "Impervious to mental illusions while holding the Chi Ball, and +5 to save vs magical illusions." }
  - name: "Special Weapon: Chiang Zhu Spear"
    description: "A length of flexible bamboo exactly one and a half times the character''s height, engraved with Mystic Cloud Characters that give it 80 M.D.C.; it is damaged only when an opponent deliberately tries to damage or destroy it. Its triangular point does only 1D6 S.D.C. in unskilled hands but holds energies that inflict 2D6 damage (M.D. against mega-damage targets, S.D.C. against S.D.C. targets) in skilled ones. The butt can carry iron, steel or stone tips, sometimes magical."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Gathers and directs chi, the life force present even where P.P.E. is weak, to add Mega-Damage to otherwise ordinary weapons. Grants W.P. Chiang Zhu Spear."
  - name: "Powers of Meditation"
    description: "Has the Meditation skill and an I.S.P. base of M.E. +3D6, +5 per level. Will never gain psionic powers other than those earned through the character''s Mystic Martial Art Power."
  - name: "Hand to Hand: Starts at 5th Level"
    description: "The chosen Advanced Chinese Hand to Hand martial art starts at its 5th level of advancement. The sheet applies the style at the character''s own level; add the style''s level 2-5 bonuses by hand."
  - name: "Philosophical Warrior"
    description: "Prepares for the coming all-out war with the Yama Kings, modelled on Sun Tzu, the Tai Kung Wang and Wu Tzu: learn everything about China, the wider world, the Yama Kings and the Mist; fight the Yama Kings and their minions whenever the risk allows, studying their strengths and weaknesses; and give ordinary people hope that their enemies will one day fall."
level_progression:
  - { level: 3, grants: ["+1 on initiative"] }
  - { level: 4, grants: ["+1 to save vs possession"] }
  - { level: 6, grants: ["+1 on initiative"] }
  - { level: 7, grants: ["+1 to save vs possession"] }
  - { level: 9, grants: ["+1 on initiative"] }
  - { level: 11, grants: ["+1 to save vs possession"] }
  - { level: 12, grants: ["+1 on initiative"] }
  - { level: 15, grants: ["+1 on initiative", "+1 to save vs possession"] }
restrictions:
  - "Cybernetics: none."
  - "No psionic powers beyond those earned through the Mystic Martial Art Power."
trackable_resources: []
side_effects: "Money is 3D6x100 in credits. The book''s equipment list also carries a Geofront officer''s shirt and jacket with the insignia torn off and sewn inside the lining, identification documents (a passport from one of the Yama Kingdoms and letters of recommendation praising the character as a good worker), blank paper, a well-worn copy of Sun Tzu''s The Art of War (known by heart), a complete set of the Classics of Confucius and a couple of other reference or technical books, a collection of herbs for tea, flavoring and emergency medicine, a traveler''s tea bottle, 30 cups of uncooked rice, a large traveler''s shoulder bag and a small neck pouch; these have no catalog rows and are not given as items."
extraction_notes: "Rifts World Book 25: China 2 printed 45-48 (cache p046-p049, a scan; every number read off 200 dpi renders). Printed 43 lists the class under Rifts China Martial Art Warriors O.C.C.s, a warrior heading, so occ_group men-of-arms; the class prints its own S.D.C. (6D6+32), so no men_of_arms line. XP ladder: printed 160 (cache p161), column Monk: Wai Chia Wu Shih / Warrior: Chun Tzu, read off a render. Attribute requirements: I.Q. at least 12 and M.E. above 9 (stored as 10); high M.A. and P.P. desirable, not required. Psionics: the book gives an I.S.P. base (M.E. +3D6, +5 per level) but no psychic tier and no powers, so psionics type none carries the pool. Save vs magic is stored as spell_magic. Initiative: +1 at levels 3, 6, 9, 12 and 15, none at level 1. Possession: +1 at levels 1, 4, 7, 11 and 15. Mystic Martial Art Power: choose one of the eight printed on 47 (not Ba Gua, Hsien Hsia or Xian Pu); the chosen power is held from level 1 and its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). Hand to Hand: any of the Advanced Chinese martial arts, which printed 19 lists as Dog Boxing, Drunken Style, Eighteen Weapons, White Jade Fan, Monkey Style and Shao-Lin (Tai Chi is the Basic one); the character starts at the 5th level of advancement in it, which is not stored and is an ability for the player to apply. The book prints no price to change, so no hand_to_hand block. Skills: Calligraphic Forgery prints (+10 with the closing %) cut off, stored as +10%. W.P. mapping: Battle Axe to W.P. Axe, Large Sword and Small Sword to W.P. Sword, Spear (Throwing) to W.P. Spear, Crossbow to W.P. Cross Bow; Heavy Weapons to W.P. Heavy Military Weapons and Heavy Energy Weapons to W.P. Heavy M.D. Weapons. Language: Native Chinese Speaker is Language: Native Tongue at the printed 95%; Literacy: Chinese is its own row at the printed 90% with the catalog''s per-level gain. Games: Wei Qi is the catalog''s Go; Western Chess has no catalog row. Rogue Gambling is both catalog Gambling rows. The special spear has no gear row and is an ability; the items without catalog rows are listed in side_effects. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 47 (cache p048), read off a render. Ability 3 reads ''Choose one of the following'' and names eight powers: Bok Pai, Gui Long, Mien-Ch''uan, Pao Chih, She Shen, Tien-Hsueh, Tong Lun and Xian Tai Chi Chuan. One power, picked once at creation; the page prints no later pick. Stored as the one choose-1 group over those eight, unchanged. The sentence ''Character starts at the 5th level of advancement'' is the last sentence of ability 2, Hand to Hand Martial Arts Skill, the numbered paragraph above; it is about the hand to hand style, not the power, so the power starts at level 1 with the character."
---

## Lore

The Chun Tzu, the Seeker of Perfection, means to be both a scholar of military classics and a fighter who leads from the front rank. Where others think a general belongs safely behind the lines, the Chun Tzu wants to see every problem first-hand and set an example for common soldiers.

The Chun Tzu wants to know everything: tanks, power armor, robots and energy weapons on one hand, and the mystic and spiritual powers needed to face the supernatural on the other. Field-stripping an assault cannon and mastering a martial art power are equally worthy goals, and an ancient treatise on war is studied as closely as a technical file on the latest Geofront armor.

They are a bundle of contradictions: bookish yet restless without hard daily exercise, content alone yet eager to join a good company, careful to keep fit without carrying more muscle than a month of hardship would support. All of it is preparation for the war with the Yama Kings that the Chun Tzu is certain will come, and for a general''s rank should it ever be offered.

Standard equipment: the special spear, two other traditional Chinese weapons with ammunition, a pistol-sized energy weapon with three E-Clips, rugged traveling and winter clothes, a stripped Geofront officer''s shirt and jacket, a suit of embroidered silk indoor clothing, travel documents, writing materials and books including The Art of War and the Confucian classics, tea and herbs, cooking gear and rice, bags and pouches, 30 ft of climbing rope and two bamboo canteens.
',
       updated_at = datetime('now')
 WHERE class_id = 'chun-tzu'
   AND instr(markdown, 'the abilities a power grants at levels 2-15 are not imported') > 0
   AND length(markdown) = 22900;

-- == blind-mystic ==
UPDATE imported_classes
   SET markdown = '---
id: blind-mystic
name: Blind Mystic (Mang Wu)
system: rifts
source_book: Rifts World Book 25: China 2 p.72-77
category: occ
tags: [scholar]
occ_group: psychic
xp_table: [0, 2141, 4281, 8561, 17521, 25541, 35581, 52601, 72801, 98201, 136401, 188801, 236201, 288401, 342801]
attribute_requirements: { IQ: 8, PP: 8 }
sdc_base: "5d6+24"
ppe_base: "P.E. x3, +1d6+2 per level"
starting_money: "4d6x100"
bonuses:
  attributes: { ME: 2, MA: 2 }
  saves: { spell_magic: 2, possession: 1, curses: 1, horror_factor: 4 }
  at_level:
    - { level: 2, saves: { possession: 1, curses: 1 } }
    - { level: 4, saves: { possession: 1, curses: 1 } }
    - { level: 6, saves: { possession: 1, curses: 1 } }
    - { level: 7, saves: { possession: 1, curses: 1 } }
    - { level: 8, saves: { possession: 1, curses: 1 } }
    - { level: 10, saves: { possession: 1, curses: 1 } }
    - { level: 12, saves: { possession: 1, curses: 1 } }
    - { level: 13, saves: { possession: 1, curses: 1 } }
    - { level: 15, saves: { possession: 1, curses: 1 } }
psionics:
  type: "master"
  isp_base: "M.E. x3, +10 per level"
  powers: ["Commune with Spirit", "Presence Sense", "Empathy", "Alter Aura", "Mask I.S.P. & Psionics", "Mask P.P.E.", "Meditation"]
  powers_starting: 0
  powers_schedule:
    - { level: 2, count: 3, from: ["See Aura", "Object Read (Psychometry)", "Mind Block"], note: "See Aura (of supernatural beings revealed by Chi), Object Read and Mind Block are all granted at second level." }
    - { level: 3, count: 2, from: ["Sense Evil", "Sense Magic"], note: "Sense Evil and Sense Magic are both granted at third level." }
    - { level: 3, count: 1, categories: ["Healing"], note: "One Healing power of choice at third level." }
    - { level: 4, count: 2, from: ["Intuitive Combat", "Exorcism"], note: "Intuitive Combat and Exorcism are both granted at fourth level." }
    - { level: 5, count: 2, from: ["Resist Fatigue", "Death Trance"], note: "Resist Fatigue and Death Trance are both granted at fifth level." }
    - { level: 6, count: 2, from: ["Resist Thirst", "Impervious to Cold"], note: "Resist Thirst and Impervious to Cold are both granted at sixth level." }
    - { level: 7, count: 1, from: ["Summon Inner Strength"], note: "Summon Inner Strength is granted at seventh level." }
    - { level: 7, count: 1, categories: ["Healing"], note: "One Healing power of choice at seventh level." }
    - { level: 8, count: 1, from: ["Impervious to Fire"], note: "Impervious to Fire is granted at eighth level." }
    - { level: 8, count: 1, categories: ["Healing"], note: "One Healing power of choice at eighth level." }
    - { level: 9, count: 1, from: ["Levitation"], note: "Levitation is granted at ninth level." }
    - { level: 9, count: 1, categories: ["Sensitive"], note: "One Sensitive power of choice at ninth level." }
    - { level: 10, count: 1, from: ["Ectoplasm"], note: "Ectoplasm is granted at tenth level." }
    - { level: 10, count: 1, categories: ["Healing"], note: "One Healing power of choice at tenth level." }
    - { level: 11, count: 1, from: ["Ectoplasmic Disguise"], note: "Ectoplasmic Disguise is granted at eleventh level." }
    - { level: 11, count: 1, categories: ["Sensitive"], note: "One Sensitive power of choice at eleventh level." }
    - { level: 12, count: 1, from: ["Group Mind Block"], note: "Group Mind Block (super) is granted at twelfth level." }
    - { level: 13, count: 1, from: ["Electrokinesis"], note: "Electrokinesis (super, usually performed by touch) is granted at thirteenth level." }
    - { level: 14, count: 1, from: ["Mind Bolt"], note: "Mind Bolt (super) is granted at fourteenth level." }
    - { level: 15, count: 1, from: ["Mind Bond", "Mind Wipe"], note: "Mind Bond or Mind Wipe (super), pick one, at fifteenth level." }
magic:
  type: "intuitive"
  spells_starting: 4
  spells_from: ["Armor of Ithan", "Calling", "Chameleon", "Chromatic Protection", "Cleanse", "Cloak of Darkness", "Crushing Fist", "Deflect", "Desiccate the Supernatural", "Distant Voice", "Energy Bolt", "Escape", "Extinguish Fire", "Featherlight", "Float in Air", "Forcebonds", "Globe of Daylight", "Greater Healing", "Heal Wounds", "Ignite Fire", "Influence the Beast", "Instill Knowledge", "Light Target", "Life Source", "Memory Bank", "Mental Shock", "Mystic Alarm", "Mystic Fulcrum", "Mystic Portal", "Plane Skip", "Purge Self", "Repel Animals", "Second Sight", "Seal", "Sheltering Force", "Sustain", "Swim as a Fish (lesser)", "Tame Beast", "Telekinesis", "Thunderclap", "Tongues", "Turn Dead"]
  spells_per_level_from: ["Armor of Ithan", "Calling", "Chameleon", "Chromatic Protection", "Cleanse", "Cloak of Darkness", "Crushing Fist", "Deflect", "Desiccate the Supernatural", "Distant Voice", "Energy Bolt", "Escape", "Extinguish Fire", "Featherlight", "Float in Air", "Forcebonds", "Globe of Daylight", "Greater Healing", "Heal Wounds", "Ignite Fire", "Influence the Beast", "Instill Knowledge", "Light Target", "Life Source", "Memory Bank", "Mental Shock", "Mystic Alarm", "Mystic Fulcrum", "Mystic Portal", "Plane Skip", "Purge Self", "Repel Animals", "Second Sight", "Seal", "Sheltering Force", "Sustain", "Swim as a Fish (lesser)", "Tame Beast", "Telekinesis", "Thunderclap", "Tongues", "Turn Dead"]
  spells_schedule:
    - { level: 3, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
    - { level: 5, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
    - { level: 7, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
    - { level: 9, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
    - { level: 11, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
    - { level: 13, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
    - { level: 15, count: 2, from_list: true, note: "Two more from the Blind Mystic''s list." }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Begging", base: 46, per_level: 3, note: "+16%" }
    - { name: "Fasting", base: 50, per_level: 3, note: "+10%" }
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 90%; spoken only, completely ignorant of written characters." }
    - { name: "Paramedic", base: 45, per_level: 5, note: "+5%" }
    - { choose: 2, from: ["Play Musical Instrument", "Play Chinese Musical Instrument: Flute"], bonus: 10, note: "Play Musical Instrument: two of choice (+10%; professional quality)." }
    - { name: "Swimming", base: 50, per_level: 5 }
    - { name: "Tea Appreciation", base: 74, per_level: 2, note: "+4%" }
    - { choose: 2, categories: ["Technical"], bonus: 10, note: "Technical skills: select two of choice (+10%)." }
    - { name: "Wrestling", base: 0, per_level: 0 }
    - { choose: 1, from: ["Hand to Hand: Tai-Chi Ch''uan", "Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Jade Fan (Chi Hsuan Men)"], note: "Usually a simple or deceptive style: Tai-Chi (Basic), Drunken Style Kung Fu or Jade Fan (Chi Hsuan Men)." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", only: ["Radio: Basic"] }
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Disguise", "Escape Artist", "Imitate Voices & Sounds", "Palming", "Pick Locks", "Pick Pockets", "Wilderness Survival"] }
      - { name: "Physical", only: ["Athletics (general)", "Body Building & Weight Lifting"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Mathematics: Advanced"] }
      - { name: "Technical", only_prefix: ["History", "Language", "Law", "Lore", "Mythology", "Photography"], bonus: 5 }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Bamboo Staff", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chiang Zhu Spear", "W.P. Cross Bow", "W.P. Forked", "W.P. Gien Bian (Steel Whip)", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Net", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Wen Jen (Scholar''s Sword)"] }
      - "Wilderness"
    note: "Communications: Basic Radio only; the character cannot see read-outs on most equipment. Espionage: Disguise, Escape Artist, Imitate Voice, Palming, Pick Locks, Pick Pockets and Wilderness Survival only. Physical: Athletics General and Body Building & Weightlifting only. Science: Advanced Math only. Technical: History, Language, Law, any Lore, Mythology and Photography only (+5%); photography documents supernatural beings for the sighted. W.P. Ancient: any except Chain, Deadball and Whip. Electrical, Horsemanship, Mechanical, Medical, Military, Pilot and Pilot Related: none. All new skills start at level one proficiency."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - { name: "Communications", only: ["Radio: Basic"] }
      - "Domestic"
      - { name: "Espionage", only: ["Disguise", "Escape Artist", "Imitate Voices & Sounds", "Palming", "Pick Locks", "Pick Pockets", "Wilderness Survival"] }
      - { name: "Physical", only: ["Athletics (general)", "Body Building & Weight Lifting"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", only: ["Mathematics: Advanced"] }
      - { name: "Technical", only_prefix: ["History", "Language", "Law", "Lore", "Mythology", "Photography"] }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Bamboo Staff", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chiang Zhu Spear", "W.P. Cross Bow", "W.P. Forked", "W.P. Gien Bian (Steel Whip)", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Net", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Wen Jen (Scholar''s Sword)"] }
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 7, 9 and 13, from the related list and its limits, at base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon of choice." }
  - { item_id: "walking-stick-nb", qty: 1, note: "A flexible cane for feeling obstructions while walking." }
  - { item_id: "quarterstaff", qty: 1, note: "Wooden staff for use as a weapon, 2D6 S.D.C. damage." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged traveling clothes of cotton, wool and/or leather, with a set of heavy winter/mountain over-garments." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sunglasses-or-goggles-cheap", qty: 1, note: "A pair of sunglasses or tinted goggles." }
  - { item_id: "bottle-pint", qty: 2, note: "Two empty bottles of booze, used as blunt weapons (1D4 S.D.C. damage)." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block (just add water)." }
  - { item_id: "brushes-low-quality", qty: "1d4", note: "Bamboo brushes." }
  - { item_id: "tinder-box", qty: 1, note: "Fire starter kit (or cigarette lighter)." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "food-rations", qty: 1, note: "30 cups of uncooked rice." }
  - { item_id: "cheese-various-types-cost-more-2-lbs", qty: 1, note: "One pound of cheese." }
  - { item_id: "shoulder-purse-large", qty: 1, note: "Large traveler''s shoulder bag." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "sack", qty: 1, note: "One medium sack." }
  - { item_id: "belt-purse", qty: 1, note: "Belt pouch." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "Small neck pouch." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "soap-per-ounce", qty: 1, note: "A bar of soap." }
  - { item_id: "water-skin", qty: 1, note: "A wine skin." }
  - { item_id: "canteen", qty: 1, note: "Bamboo canteen of water." }
  - { item_id: "tape-recorder", qty: 1, note: "A high-quality micro-cassette recorder." }
special_abilities:
  - name: "The Mind Is Strong"
    description: "Though the eyes cannot see, opening the Third Eye shows the Blind Mystic the supernatural world most sighted people cannot see, so he understands the monsters who prey on mortals better than most. Goals: to see with heart and mind and lead by example, to crush evil in all its forms (above all the demon hordes, Goblins and Ghosts), and to protect the weak from the supernatural invaders and the Yama Kings."
  - name: "Chi Sight"
    description: "The default condition. Any supernatural being, including Ghosts and Astral Travelers, within 20 feet (6.1 m) in any direction is noticed as a faint, hazy light, with a bad feeling that suggests the supernatural. He also feels the Chi of anyone, mortal or supernatural, within 5 feet (1.5 m): he cannot see a mortal there but knows he is there. Automatic, no I.S.P. cost."
  - name: "Third Eye"
    description: "Sees the forces of Chi: all supernatural beings (the Dead and Damned, undead, demons, Goblins, Ghosts, Entities and other spectral forms) shine like neon signs, the brighter the more powerful; Immortals, creatures of magic, enchanted weapons, magic items, Dragon Lines and dimensional portals glow more faintly. Demonic beings radiate orange and red, magical beings such as dragons white and blue, mortal men of magic a dim turquoise; martial artists and others who draw on Chi show as a pale flutter within 30 feet (9.1 m). Mortal people, animals, plants and buildings stay invisible, now and then outlined as shadows. Anything visible to him can be targeted normally. Duration: one minute per level. Range: 100 foot (30.5 m) radius, +10 feet (3 m) per level. I.S.P. Cost: 3 to activate for one minute per level."
  - name: "Sense Chi Movement"
    description: "Senses the exact movement of Chi within about twelve feet (3.6 m): the amount and type of Chi in anyone nearby, and the movement of bodies, hands and feet well enough to fight in close combat with no penalties, at that range only. Also sees the Chi worked by Xian Tai Chi Chuan or Ba Gua Kung Fu, the growing energy of a spell being recited before it is cast, and the faint glow around anyone protected by or under the influence of magic. I.S.P. Cost: 2 per minute."
  - name: "Spirit Sight"
    description: "Concentrating on a Chi image for one melee round (15 seconds) identifies the exact type of Infernal or specter, whether it is male or female, disguised in human form by metamorphosis or possessing a mortal; psionics also reveal its alignment, approximate power level (low, medium or high) and sometimes its name, and whether it realizes it is seen. I.S.P. Cost: 4 per minute."
  - name: "Prophetic Dreams"
    description: "Occasionally dreams of events far away, warnings, visions from the gods and glimpses of the future, and always has a good idea what they mean; in dreams he sees the faces and details denied him awake. Random and uncontrolled. I.S.P. Cost: none."
  - name: "Divination (Mo Ku)"
    description: "Touch Bones: foretells the future of another person by feeling the bones of the hands and fingers, giving warnings and impressions rather than certainties. Also reads from calluses the kind of work the person does, and gets a sense of age, physical condition, strength (P.S.), general alignment, level of experience (low, middle, high, very high) and race; Chi Sight reveals a Spirit Host or a possessed person before the touch. Cannot be used on himself. Duration: 1D6 minutes. Base Skill: 50% +3% per level. I.S.P. Cost: 5."
  - name: "Sculpture/Identify Features by Touch"
    description: "A special skill: memorizes facial, hand and body features by touch and renders them in sculpture. A rough clay sketch of a person takes about fifteen minutes, and a roll on this skill decides whether it is recognizable. Base Skill: 24% +4% per level."
  - name: "Impervious to Magic Illusions and Unseen Horror"
    description: "Impervious to magic illusions (but vulnerable to psionic ones) and to Horror Factor from things he cannot see; the +4 save vs Horror Factor applies to horror based on sounds, smells and what he perceives with the Third Eye or psionics."
  - { choose: 1, from: ["Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)", "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"] }
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)"
    description: "Requires the Acupuncture skill. Level 1: Healing Tien-Hsueh for 6 I.S.P. a healing, each one melee action - 4D6 hit points, 2D6+10 S.D.C. or 3D8 M.D.C. restored, or a 40% +4% per level chance to cure illness, infection, fever or coma at once, or to repair, install or remove a cybernetic device, engine or machine. Tien-Hsueh Reversal for 5 I.S.P. - undoes any Tien-Hsueh effect, or a knockout, stun, dizziness, blindness, paralysis or other temporary shock, in one melee round; against the work of a higher-level master it takes 2D6 melee rounds per level of difference. One Finger Touch - no damage, +4 to strike, the delivery for every Tien-Hsueh attack. Tien-Hsueh Powers, one chosen at each of levels 3, 6, 8, 11 and 13: Blindness (2D6 hours blind at -10 to strike, parry, dodge and other combat rolls, 2D6 melee rounds if the victim rolls with the blow, nothing if parried or dodged; 8 I.S.P.), Blood Flow (2D8 direct to hit points past S.D.C. or S.D.C. armor, 1D8 past M.D.C. armor, or 1D8 M.D. or 2D8 P.P.E. dispelled against a supernatural creature; 10 I.S.P.), Electronic (start or stop any machine, device or vehicle by touch; 10 I.S.P.), Enlightenment Strike (frees a victim within 30 ft and in line of sight from possession, Chi control or mind control, taking a full melee round; 20 I.S.P.), Neural (paralyzes a declared limb for 3D6 minutes with no roll with impact, needing an 8 or better to strike, though the victim may still parry or dodge, the defender winning ties, and an arm or foot used to parry is itself paralyzed; 8 I.S.P.), Puppet-Dance (a grip on the back of the neck and a strike roll of 10 or higher makes the victim a living puppet with two attacks a melee and no bonuses, while the master''s own bonuses are halved and his skills are -20%; 15 I.S.P. on a natural being, 20 on a lesser supernatural being, 30 on a Fox or Monkey Spirit or a dragon hatchling, 50 on most Greater Demons, Immortals, Ghosts and Entities; it does not work on adult dragons, Elementals, Demon Lords, Demigods, Godlings or deities, the victim cannot be made to speak, and while he holds the puppet the master can perform no other Tien-Hsueh and nothing that spends I.S.P. or P.P.E.), Demon Strike (leaves a supernatural M.D.C. being or lesser creature of magic with only 1D4x10% of its M.D.C.; 32 I.S.P.) or Withering Flesh (removes all natural S.D.C., or only 1D6 S.D.C. if the victim rolls with impact, never touching hit points; 12 I.S.P.). (printed 35-37.)"
    progression:
      - { level: 2, text: "Internal Practice Advancement #1: +2 to M.E. and +1 to I.Q." }
      - { level: 3, text: "Select one Tien-Hsueh Power from the list." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Penetrating Tien-Hsueh: for 12 I.S.P. the character''s Tien-Hsueh powers reach through an M.D.C. body or M.D.C. armor, which no longer acts as a barrier." }
      - { level: 6, text: "Select one more Tien-Hsueh Power." }
      - { level: 7, text: "Internal Practice Advancement #2: +2 to P.P. and +1 to M.A." }
      - { level: 8, text: "Select one more Tien-Hsueh Power." }
      - { level: 9, text: "Long-Distance Tien-Hsueh: for 24 I.S.P. any Tien-Hsueh can be projected up to 400 ft (122 m) per level at a victim the character can see (binoculars, a scope or a monitor count) or is speaking with over a phone or radio; through contact with a detached spirit or animus it reaches that being''s body at any distance." }
      - { level: 10, text: "Add 5D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Select one more Tien-Hsueh Power." }
      - { level: 12, text: "Internal Practice Advancement #3: +2 to I.Q. and +1 to M.E." }
      - { level: 13, text: "Select one more Tien-Hsueh Power." }
      - { level: 14, text: "Knockout or stun on a Natural 17 or better." }
      - { level: 15, text: "Add 1D6x10+24 to the character''s Permanent I.S.P. Base." }
  - name: "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"
    description: "Level 1: Falling Technique - no damage from a fall of 50 ft or less, 1 point per 50 ft from 51 to 400 ft, 1 point per 20 ft beyond 400 ft, and never more than 60 points (terminal velocity past 1200 ft); +1 to roll with punch or impact (other than a fall) at levels 1, 3, 4, 6, 8, 9, 11, 13 and 15. Light-Body Climbing - climb up or down at walking speed with no skill roll, carrying only basic gear and no passenger; requires the Climbing skill, which gains +10%. (printed 39-40.)"
    progression:
      - { level: 2, text: "Drunkard''s Staff: for 22 I.S.P. an ordinary staff, broomstick, pole or branch does 2D8 M.D. (2D8 S.D.C. to S.D.C. targets) and has 1D6x10 M.D.C. if attacked itself. It lasts at least one day; at the end of each 24 hours a roll under 10 on a D20 ends it, and seven saves in a row make it permanent." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+2 in all)." }
      - { level: 4, text: "Mystic Slime: for 10 I.S.P. an invisible slippery coating makes the character, his clothing, gear and weapons next to impossible to grab or hold. Falling Technique: +1 to roll with punch or impact (+3 in all)." }
      - { level: 5, text: "Neutralize Toxins: for 7 I.S.P., used mostly to drink great amounts of alcohol without being seriously affected." }
      - { level: 6, text: "Belch Toxic Vapor: for 10 I.S.P., at most twice a melee and one attack each, a belch in the face forces a save vs non-lethal poison (16 or higher). Failure: loses initiative and one attack and is -2 to strike, parry, dodge and all combat moves for 1D4 melee rounds. Success: loses one attack that round. Falling Technique: +1 to roll with punch or impact (+4 in all)." }
      - { level: 7, text: "Drunken Stranger (Qiao Zhuang): for 20 I.S.P. the character moves and looks like a different drunk and is not recognized unless seen full in the face in good light, for 24 hours per level." }
      - { level: 8, text: "Blind Drunk: for 12 I.S.P. the character blinds himself for 8 hours per level (cancelled at will) and suffers only a third of the blindness penalties (-3 to strike, parry, dodge and disarm). Falling Technique: +1 to roll with punch or impact (+5 in all)." }
      - { level: 9, text: "Drunken Style Meditation Advancement #1: +15 S.D.C., +2 to M.E. and P.P., +1 to save vs possession. Falling Technique: +1 to roll with punch or impact (+6 in all)." }
      - { level: 10, text: "Add 5D6+22 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Drunken Mind Cloak: for 6 I.S.P. per listener, up to 10 people per level, gibberish holds listeners oblivious to everything around them for as long as the character keeps talking and they are not attacked, robbed or shaken. Or, for 5 I.S.P. per person (also up to 10 people per level), up to four topics are planted in their memory for good after 2D12 melee rounds of confusion. Falling Technique: +1 to roll with punch or impact (+7 in all)." }
      - { level: 12, text: "Drunken Dragon Walk: for 10 I.S.P. the character staggers along the paths of any nearby dragon lines (ley lines) for 1D6 hours." }
      - { level: 13, text: "Inflict Mystic Drunkenness: one breath (one attack) on up to six victims at 10 I.S.P. each; a failed save vs non-lethal poison (16 or higher) leaves them drunk for 2D6 melee rounds, with Spd, skills and combat bonuses halved and -2 attacks per melee. Falling Technique: +1 to roll with punch or impact (+8 in all)." }
      - { level: 14, text: "Drunken Style Meditation Advancement #2: +2 to M.E. and M.A." }
      - { level: 15, text: "Add 1D6x10+33 to the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+9 in all)." }
level_progression:
  - { level: 2, grants: ["Psionics: See Aura, Object Read, Mind Block", "+1 save vs possession and Demonic Curses"] }
  - { level: 3, grants: ["Psionics: Sense Evil, Sense Magic and one Healing power of choice", "Two spells from the Blind Mystic''s list"] }
  - { level: 4, grants: ["Psionics: Intuitive Combat, Exorcism", "+1 to Spell Strength", "+1 save vs possession and Demonic Curses"] }
  - { level: 5, grants: ["Psionics: Resist Fatigue, Death Trance", "Two spells from the Blind Mystic''s list"] }
  - { level: 6, grants: ["Psionics: Resist Thirst, Impervious to Cold", "+1 save vs possession and Demonic Curses"] }
  - { level: 7, grants: ["Psionics: Summon Inner Strength and one Healing power of choice", "Two spells from the Blind Mystic''s list", "+1 save vs possession and Demonic Curses"] }
  - { level: 8, grants: ["Psionics: Impervious to Fire and one Healing power of choice", "+1 to Spell Strength", "+1 save vs possession and Demonic Curses"] }
  - { level: 9, grants: ["Psionics: Levitation and one Sensitive power of choice", "Two spells from the Blind Mystic''s list"] }
  - { level: 10, grants: ["Psionics: Ectoplasm and one Healing power of choice", "+1 save vs possession and Demonic Curses"] }
  - { level: 11, grants: ["Psionics: Ectoplasmic Disguise and one Sensitive power of choice", "Two spells from the Blind Mystic''s list"] }
  - { level: 12, grants: ["Psionics: Group Mind Block", "+1 to Spell Strength", "+1 save vs possession and Demonic Curses"] }
  - { level: 13, grants: ["Psionics: Electrokinesis", "Two spells from the Blind Mystic''s list", "+1 save vs possession and Demonic Curses"] }
  - { level: 14, grants: ["Psionics: Mind Bolt"] }
  - { level: 15, grants: ["Psionics: Mind Bond or Mind Wipe", "Two spells from the Blind Mystic''s list", "+1 to Spell Strength", "+1 save vs possession and Demonic Curses"] }
restrictions:
  - "Blind: cannot see light, color, text, signs, screens or instrument panels, cannot read at all, and can never drive a vehicle."
  - "Cybernetics: none, avoided like the plague."
trackable_resources: []
side_effects: "Combat penalties whenever the Blind Mystic is blind in combat - against a sighted mortal or mechanical opponent that is not visible to Chi, or when he cannot use the Third Eye or another mystic means of detection: -4 initiative; -4 to strike (-7 to throw or fire a weapon); -3 to parry, dodge and entangle; -4 to pull punch or disarm (only -2 to disarm when entangled or wrestling); -2 to roll with punch, fall or impact. No penalties against supernatural beings or creatures of magic, within Sense Chi Movement''s range, or in wrestling, which is why a common tactic is to grab the attacker. A pair of fans comes with the kit if the character has Jade Fan. Also carried and not stored as items: lightweight embroidered silk indoor clothing, six blindfolds, an ugly folding fan, 1D6 silk handkerchiefs, identification documents including a passport from one of the Yama Kingdoms and letters praising him as a teacher or teller of stories, 5D6 sheets of blank paper for others to write on, a collection of herbs, a traveler''s tea bottle, two sets of chopsticks, a large wooden spoon (1D4 S.D.C. as a weapon) and a hairbrush or comb. Income: state support or charity for the blind gives a dormitory bed, meals and about 25 credits a week, but a Blind Mystic can always earn a living as a fortune-teller, healer and teacher, respected nearly as much as a Soothsayer."
extraction_notes: "Rifts World Book 25: China 2 printed 72-77 (cache p073-p078, scan, page_offset +1); every number read off 200 dpi renders. The heading Blind Mystic P.C.C. - Mang Wu is on printed 72 (right column); powers 1-14 run 72-75, the stat block starts at the foot of 75, skills and equipment fill 76, and money and cybernetics end at the top of 77, where Demon Quellers begins. GROUP: printed 62 heads the section Chinese Diviner Psychic Character Classes, so occ_group psychic; a P.C.C. is category occ. sdc_base is stated (S.D.C. 5D6+24), so no men_of_arms line. Hit points are not printed. XP: printed 160, the ladder headed Blind Mystic / Geofront Chi Commando / Geofront Lightning Warriors, read off a render of cache p161. ATTRIBUTES: I.Q. 8 and P.P. 8 or higher. RACE: none; about 30% are D-Bees. PSIONICS: a Master Psychic (saves vs psionics on 10); I.S.P. M.E. x3, +10 per level. The level 1 line is misprinted Empathy (4)ter Aura (2); read as Empathy (4) and Alter Aura (2), both granted (judgement). Commune with Spirits is the catalog''s Commune with Spirit; Mask I.S.P. & Psionics and Mask P.P.E. as catalogued; Object Read is Object Read (Psychometry). Levels 2-15 are schedule entries. MAGIC: Intuitive Mystic Abilities, four spells at level one and two at levels 3, 5, 7, 9, 11, 13 and 15, from a printed list of 42; stored as spells_from and spells_per_level_from with from_list schedule entries. The book prints Dessicate the Supernatural (catalog Desiccate the Supernatural), Force Bonds (catalog Forcebonds) and Swim as a Fish at 6 P.P.E. (catalog Swim as a Fish (lesser); judgement). P.P.E. P.E. x3 +1D6+2 per level. BONUSES: +2 M.E. and M.A.; +2 save vs magic (spell_magic only, as plain save vs magic is stored elsewhere); +1 save vs possession and Demonic Curses (stored as curses) at levels 1, 2, 4, 6, 7, 8, 10, 12, 13 and 15. +1 to Spell Strength at levels 4, 8, 12 and 15 has no sheet field and is in level_progression. The +4 save vs Horror Factor applies to horror based on sounds, smells and what he senses with the Third Eye or psionics, while he is impervious to horror from things he cannot see; since every Horror Factor he meets is one or the other, it is stored unconditionally as horror_factor 4 (judgement). Impervious to magic illusions is an ability, not a save. Combat penalties when blind are conditional and are side_effects. HAND TO HAND: the book says the character usually selects Tai-Chi (Basic), Drunken Style Kung Fu or Jade Fan; stored as a choice of those three with no printed price for any other, costs {} (judgement). MYSTIC MARTIAL ART POWER: the book says the character usually prefers Bok Pai, Mien-Ch''uan, Tien-Hsueh or Xian Pu; stored as a choice of those four; the chosen power is held from level 1 and its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). Tien-Hsueh requires Acupuncture, which this class''s skills do not grant (Medical: none); the requirement stays in that power''s text. SKILLS: Begging and Fasting are the RUE rows plus the printed bonus (30+16, 40+10). Language: Native Chinese Speaker 90% is Language: Native Tongue at 90, spoken only; no literacy. Play Musical Instrument two of choice is a choice of the two instrument rows. Sculpture/Identify Features by Touch (24% +4% per level) has no catalog row and is stored as an ability. Technical skills two of choice (+10%) is a Technical choice. Related: Espionage''s Imitate Voice is Imitate Voices & Sounds and with Palming is filed under Rogue in the catalog, Wilderness Survival under Wilderness; both are admitted cross-category. Technical is narrowed by prefix to History, Language, Law, Lore, Mythology and Photography. W.P. Ancient excludes Chain, Deadball and Whip; W.P. Modern is not listed and is not offered. Secondary skills take the related limits without the bonuses. EQUIPMENT: the weapon of choice is weapons-matching-w-p-skills; the cane is the walking stick row; the micro-cassette recorder is tape-recorder; the wine skin is water-skin. Silk clothes, blindfolds, fans, handkerchiefs, documents, paper, herbs, chopsticks, spoon and comb are in side_effects. MONEY: 4D6x100 credits. CYBERNETICS: none. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 73 (cache p074), read off a render. Ability 3 says the character usually prefers a power that is deceptive and surprising and names four: Bok Pai Kung Fu (Crane Style), Mien-Ch''uan Kung Fu (Cotton Fist), Tien-Hsueh Kung Fu (Touch Mastery) and Xian Pu Kung Fu (Drunken Style), the last two being favorites. One power, picked at creation; no later pick is printed. Stored as the one choose-1 group over those four, unchanged."
---

## Lore

In Rifts China the blind have a particular bond with the spirit world. Those who develop psychic gifts and master the mystic martial arts are far more dangerous than they look: where a Blind Mystic cannot see an ordinary person, the approach of a ghost, a walking corpse, an Infernal or any other being of negative Chi stands out plainly.

The disadvantages are real. The character truly cannot see light, color, signs, screens or instrument panels, cannot read and will never drive. What he has instead is an intuitive grasp of both psychic and magical power, a gift some call a sign that the blind have special work to do on Rifts Earth.

His own frailty has made him patient with other people''s weaknesses and fears. To the world he may play the wizened scholar, the cryptic fortune teller, the kindly mentor, the clumsy weakling, the harmless drunk or the impossible taskmaster, and every one of these is a mask to make enemies underestimate him. Demons like to prey on those who seem helpless, which suits the Blind Mystic perfectly. Underneath, most are tough, sober, compassionate and kind.
',
       updated_at = datetime('now')
 WHERE class_id = 'blind-mystic'
   AND instr(markdown, 'pasted from the shared level-1 block; level 1 only, levels 2-15 not imported') > 0
   AND length(markdown) = 28300;

-- == spirit-host ==
UPDATE imported_classes
   SET markdown = '---
id: spirit-host
name: Spirit Host
system: rifts
source_book: Rifts World Book 25: China 2 p.67-72
category: occ
tags: [shapeshifter, wilderness, combat]
occ_group: psychic
men_of_arms: false
mdc_from_hp_sdc: true
xp_table: [0, 2201, 4401, 9001, 18001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
starting_money: "1d6x1000"
psionics:
  type: "master"
  isp_base: "M.E. x3, +1d6+6 per level"
  powers: ["Commune with Spirit", "See The Invisible", "Meditation"]
  powers_starting: 0
  powers_schedule:
    - { level: 2, count: 3, from: ["See Aura", "Sense Evil", "Sense Magic"], note: "See Aura, Sense Evil and Sense Magic are all granted at second level." }
    - { level: 3, count: 2, from: ["Intuitive Combat", "Presence Sense"], note: "Intuitive Combat and Presence Sense are both granted at third level." }
    - { level: 4, count: 2, from: ["Mind Block", "Resist Fatigue"], note: "Mind Block and Resist Fatigue are both granted at fourth level." }
    - { level: 5, count: 1, from: ["Resist Thirst"], note: "Resist Thirst at fifth level, plus 1D10 to the permanent I.S.P. base (add by hand)." }
    - { level: 6, count: 1, from: ["Resist Hunger"], note: "Resist Hunger is granted at sixth level." }
    - { level: 6, count: 1, categories: ["Physical"], note: "One Physical power of choice at sixth level." }
    - { level: 7, count: 2, from: ["Impervious to Cold", "Death Trance"], note: "Impervious to Cold and Death Trance are both granted at seventh level." }
    - { level: 8, count: 2, from: ["Object Read (Psychometry)", "Alter Aura"], note: "Object Read and Alter Aura at eighth level, plus 2D10 to the permanent I.S.P. base (add by hand)." }
    - { level: 9, count: 1, from: ["Remote Viewing"], note: "Remote Viewing is granted at ninth level." }
    - { level: 9, count: 1, categories: ["Physical"], note: "One Physical power of choice at ninth level." }
    - { level: 10, count: 1, from: ["Impervious to Fire"], note: "Impervious to Fire is granted at tenth level." }
    - { level: 10, count: 1, categories: ["Sensitive"], note: "One Sensitive power of choice at tenth level." }
    - { level: 11, count: 1, from: ["Bio-Manipulation (the evil eye)"], note: "Bio-Manipulation (super) is granted at eleventh level." }
    - { level: 12, count: 1, from: ["Empathic Transmission"], note: "Empathic Transmission (super) at twelfth level, plus 3D10 to the permanent I.S.P. base (add by hand)." }
    - { level: 13, count: 1, from: ["Radiate Horror Factor"], note: "Radiate Horror Factor (super) is granted at thirteenth level." }
    - { level: 14, count: 1, from: ["Electrokinesis", "Hydrokinesis"], note: "Electrokinesis or Hydrokinesis (super), pick one, at fourteenth level." }
    - { level: 15, count: 1, categories: [{ name: "Super", except: ["Psi-Sword", "Psi-Shield", "Telemechanics", "Telemechanic Mental Operation", "Telemechanic Paralysis", "Telemechanic Possession"] }], note: "One Super-Psionic power of choice at fifteenth level, excluding Psi-Sword, Psi-Shield and any Telemechanics power." }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Basic Math (+15%)" }
    - { name: "Begging", base: 42, per_level: 3, note: "+12%" }
    - { name: "Fasting", base: 50, per_level: 3, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 90%." }
    - { name: "Language: Demongogian", base: 80, per_level: 0, note: "The native language of demonkind; the book prints 80%." }
    - { name: "Literacy: Chinese", base: 85, per_level: 0, note: "Chinese characters/ideograms; the book prints 85%." }
    - { name: "Lore: Cattle & Animals", base: 50, per_level: 5, note: "+20%" }
    - { choose: 2, from: ["Lore: Aborigines", "Lore: Astral", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Buddhist", "Lore: Chinese Mythology: Taoist", "Lore: Cities", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Dreamtime Culture", "Lore: Faeries & Creatures of Magic", "Lore: Feng Shui/Geomancy", "Lore: Galactic/Alien", "Lore: General Law", "Lore: Geomancy or Lines of Power", "Lore: History of Russia", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Rifts China", "Lore: Vampires", "Lore: Western World", "Lore: Wormwood", "Language: Other"], bonus: 15, note: "Lore or Language: two of choice (+15%). Any Lore row, or Language: Other for a language, which may be taken more than once." }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Tea Appreciation", base: 74, per_level: 2, note: "+4%" }
    - { name: "Track & Trap Animals", base: 35, per_level: 5, note: "The book prints Track Animals (+15%)." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { choose: 1, from: ["W.P. Chiang Zhu Spear", "W.P. Bamboo Staff"], note: "Born to Sense and Manipulate Chi: automatically gets W.P. Chiang Zhu Spear or W.P. Bamboo Staff, pick one." }
    - { choose: 1, from: ["Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Tai-Chi Ch''uan"], note: "Select one of Dog Boxing Kung Fu, Monkey Style Kung Fu or Tai-Chi as the basis of the character''s combat skills." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Surveillance"] }
      - { name: "Domestic", bonus: 5 }
      - "Espionage"
      - { name: "Horsemanship", bonus: 10 }
      - { name: "Medical", only: ["Animal Husbandry"], bonus: 10 }
      - { name: "Medical", only: ["Brewing", "First Aid", "Holistic Medicine"], bonus: 5 }
      - { name: "Military", only: ["Camouflage", "Trap/Mine Detection"], bonus: 5 }
      - { name: "Physical", except: ["Juicer Football", "Murderthon", "Space: Extra-Vehicular Activity", "Space: Oxygen Conservation", "Space: Zero Gravity Movement & Combat"] }
      - { name: "Pilot", except_prefix: ["Military:", "Robot", "Combat Pod", "Air Assault Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Bamboo Staff", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Chiang Zhu Spear", "W.P. Cross Bow", "W.P. Deadball", "W.P. Forked", "W.P. Gien Bian (Steel Whip)", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Net", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Wen Jen (Scholar''s Sword)", "W.P. Whip", "W.P. Handguns", "W.P. Automatic Pistol", "W.P. Revolver", "W.P. Energy Pistol", "W.P. Bolt Action Rifle", "W.P. Energy Rifle"] }
      - { name: "Wilderness", bonus: 5 }
    note: "Communications: Radio Basic and Surveillance Systems only. Medical: Animal Husbandry (+10%), Brewing, First Aid, Holistic Medicine only (+5%). Military: Camouflage and Trap/Mine Detection only (+5%). Physical: any fundamental abilities (no Juicer or Space abilities). Pilot: any except military vehicles, robots and power armor. W.P. Ancient: any. W.P. Modern: the basic pistols (bullet or energy) and W.P. Bolt Action/Hunting Rifle or Energy Rifle only. Electrical, Mechanical and Pilot Related: none. All new skills start at level one proficiency."
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Surveillance"] }
      - "Domestic"
      - "Espionage"
      - "Horsemanship"
      - { name: "Medical", only: ["Animal Husbandry", "Brewing", "First Aid", "Holistic Medicine"] }
      - { name: "Military", only: ["Camouflage", "Trap/Mine Detection"] }
      - { name: "Physical", except: ["Juicer Football", "Murderthon", "Space: Extra-Vehicular Activity", "Space: Oxygen Conservation", "Space: Zero Gravity Movement & Combat"] }
      - { name: "Pilot", except_prefix: ["Military:", "Robot", "Combat Pod", "Air Assault Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Bamboo Staff", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Chiang Zhu Spear", "W.P. Cross Bow", "W.P. Deadball", "W.P. Forked", "W.P. Gien Bian (Steel Whip)", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Net", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Wen Jen (Scholar''s Sword)", "W.P. Whip", "W.P. Handguns", "W.P. Automatic Pistol", "W.P. Revolver", "W.P. Energy Pistol", "W.P. Bolt Action Rifle", "W.P. Energy Rifle"] }
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 7, 9 and 13, from the related list and its limits, at base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One magic weapon, often a sword (see the Green Scarf Sect)." }
  - { item_id: "china-bone-swords-and-weapons", qty: 1, note: "One bone or stone weapon." }
  - { choose: 1, label: "walking stick or staff", qty: 1, from: ["walking-stick-nb", "quarterstaff"] }
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "May have a pistol and one extra ammo clip or E-Clip, or a hunting rifle and two extra ammo clips." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged traveling clothes of cotton, wool and/or leather, with a set of heavy winter/mountain over-garments." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "robe", qty: 1, note: "A brown robe or cloak." }
  - { item_id: "light-mdc-body-armor", qty: 1, note: "Light suit of armor, rarely with more than 30 M.D.C." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book with 100 pages." }
  - { item_id: "pencil", qty: "1d6+4", note: "Half made from peach wood." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block (just add water)." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "tinder-box", qty: 1, note: "Fire starter kit (or cigarette lighter)." }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4", note: "Scented candles." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "Small meat cleaver." }
  - { item_id: "knife-large", qty: 1, note: "Butcher knife." }
  - { item_id: "knife-skinning", qty: 1, note: "Knife for cleaning and skinning." }
  - { item_id: "pot-metal", qty: 1, note: "Small pot for brewing and boiling." }
  - { item_id: "frying-pan", qty: 1, note: "2D4 S.D.C. damage as a weapon." }
  - { item_id: "food-rations", qty: 1, note: "30 cups of uncooked rice." }
  - { item_id: "jerked-beef-lasts-months", qty: "1d4", note: "1D4 pounds of jerked or smoked meat." }
  - { item_id: "shoulder-purse-large", qty: 1, note: "Large traveler''s shoulder bag." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "large-sack", qty: 1 }
  - { item_id: "belt-purse", qty: 1, note: "Belt pouch." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "Small neck pouch." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "soap-per-ounce", qty: 1, note: "A bar of soap." }
  - { item_id: "canteen", qty: 1, note: "Bamboo canteen of water." }
special_abilities:
  - name: "An Avatar of Nature"
    description: "A hero of the Celestial Court who walks among people as both flesh and spirit, man and animal. Goals: put the natural order right by culling the chief architects of evil with cunning and sudden strikes; help mankind find the way by training and leading any who oppose the Yama Kings; and save and protect the weak and innocent."
  - name: "Born to Sense and Manipulate Chi"
    description: "Intuitively gathers and directs Chi so that he can add Mega-Damage to otherwise ordinary weapons. Also grants W.P. Chiang Zhu Spear or W.P. Bamboo Staff (a skill pick)."
  - name: "Spirit Writing"
    description: "Lets a deceased ancestor, stranger, Ghost, Entity or Nature Spirit enter his body to convey information (he cannot be possessed by it, as a Nature Spirit already lives there). Holding a T-shaped peach-wood pencil he falls into a trance within 1D4 melee rounds of meditation; one other character may then ask three questions, which the spirit answers simply, in writing. Ends when all three are asked or after five minutes. Best performed at a temple, ancestral shrine, grave or where a spirit is known or suspected to be; done anywhere else it usually does nothing, though the I.S.P. is spent. I.S.P. Cost: 4."
  - name: "View Ghost Drama"
    description: "Pours Chi into a scene of death so that observers clearly see and hear the haunting: the ghost re-enacts the minutes before its death with the other people and the physical surroundings as they were then. What is seen is the spirit''s own recollection and may be wrong. Range: 50 feet (15.2 m). Duration: five minutes per level. Saving Throw: 12 or higher, though most Ghosts and Entities will not resist. Cost: the book prints I.S.P. Cost: Eight P.P.E."
  - name: "Metamorphosis: Animal"
    description: "Turns into the animal of the Nature Spirit he is merged with. Spd is doubled, M.D.C. increases by 50%, and the animal''s instincts and abilities (flight, swim, leap and so on) are available, but attacks per melee are reduced by two; he thinks as a human and keeps his memories but cannot speak."
  - name: "Metamorphosis: Human"
    description: "His natural form is half-man, half-animal, much like a were-beast. Assuming his original human form costs 5 I.S.P. and lasts 30 minutes per level; he can return to the animal-man form at will (two melee actions, about six seconds). In human form he loses Supernatural P.S., M.D.C. and all bonuses and abilities of the union, becoming a normal mortal with Hit Points and S.D.C."
  - name: "Union of Flesh & Spirit"
    description: "In half-man, half-animal form (and in animal form) P.S. becomes Supernatural and Hit Points and S.D.C. combine into M.D.C. All animal-man forms bio-regenerate 1D6 M.D.C. per melee round. Unless the totem says otherwise, understands and speaks all dialects of Chinese. The totem animal chosen below sets the rest; other animals are at the G.M.''s discretion."
  - { choose: 1, from: ["Animal Totem: Dog/Wolf", "Animal Totem: Dragon", "Animal Totem: Hare/Rabbit", "Animal Totem: Horse", "Animal Totem: Monkey", "Animal Totem: Ox/Bull", "Animal Totem: Panda", "Animal Totem: Pig/Boar", "Animal Totem: Rat/Rodent", "Animal Totem: Rooster/Cock", "Animal Totem: Sheep/Goat", "Animal Totem: Snake", "Animal Totem: Stag/Deer", "Animal Totem: Tiger"] }
  - name: "Animal Totem: Dog/Wolf"
    description: "Symbol of idealism. Fatigues at half the usual rate, nightvision 60 feet (18.3 m), Swim equal to a skill of 60%, keen sense of smell; +10% to Tracking (+15% to follow a blood trail or scent) and +5% to Tailing."
    bonuses: { attributes: { IQ: 1, PS: "1d4+4", Spd: "2d6+12" }, combat: { attacks: 1, strike: 3, parry: 2, dodge: 3 }, saves: { toxins_poisons: 3, disease: 3, curses: 1, possession: 1, horror_factor: 3 }, pools: { mdc: "6d6+45" } }
  - name: "Animal Totem: Dragon"
    description: "Symbol of health, strong-mindedness and protection from evil spirits. +1D6 to I.Q. or M.E. (player''s choice; add by hand). Fatigues at one tenth the usual rate, nightvision 1000 feet (305 m), understands and speaks all languages (98%), Swim equal to a skill of 70%, +5% to all Communication, History and Lore skills."
    bonuses: { attributes: { PS: "1d10+10" }, combat: { attacks: 1, strike: 2, parry: 2, dodge: 1 }, saves: { spell_magic: 4, toxins_poisons: 2, disease: 2, curses: 5, possession: 6, horror_factor: 7 }, pools: { mdc: "1d10x10+100" } }
  - name: "Animal Totem: Hare/Rabbit"
    description: "Symbol of virtue, selflessness and magic. Automatic dodge: dodging does not use up a melee attack, though the roll is still made. Can leap 10 feet (3 m) high and 20 feet (6.1 m) across."
    bonuses: { attributes: { PP: "1d4", Spd: "2d6+12" }, combat: { strike: 1, parry: 1, automatic_dodge: 4 }, saves: { spell_magic: 2, curses: 2, possession: 3, horror_factor: 1 }, pools: { mdc: "4d6+20", isp: "1d20" } }
  - name: "Animal Totem: Horse"
    description: "Symbol of practicality and compassion. Can leap 12 feet (3.6 m) high and 20 feet (6.1 m) across, 50% more with a running start, and can pull 50% more weight than usual for its P.S."
    bonuses: { attributes: { PS: "1d6", PE: 2, Spd: "2d10+24" }, combat: { strike: 1, parry: 1, dodge: 2 }, saves: { illusionary_magic: 2, psionics: 2, curses: 1, possession: 2, horror_factor: 2 }, pools: { mdc: "6d6+50" } }
  - name: "Animal Totem: Monkey"
    description: "Symbol of intelligence and cleverness. Prehensile tail serves as an extra limb (can use simple weapons and tools and drive a vehicle); prehensile feet work as a second pair of hands; together +15% to Climb and +5% to Acrobatics, Gymnastics, Palming and Concealment. Understands and speaks all Asian languages, including Mongolian and Russian (90%)."
    bonuses: { attributes: { IQ: 2, MA: "1d4", PP: 2, Spd: "1d6" }, combat: { attacks: 1, initiative: 2, strike: 1, parry: 2, dodge: 3 }, saves: { curses: 1, possession: 4, horror_factor: 3 }, pools: { mdc: "5d6+30", isp: "2d10" } }
  - name: "Animal Totem: Ox/Bull"
    description: "Symbol of balance and endurance. Does an extra 2D6 damage (S.D.C. or M.D. by the nature of the target) with punches and head butts; can lift and pull double the usual weight for his Supernatural P.S."
    bonuses: { attributes: { PS: "1d6+8", PE: "1d4", Spd: "1d10+10" }, combat: { strike: 2, parry: 1, dodge: 1 }, saves: { spell_magic: 1, curses: 2, possession: 3, horror_factor: 4 }, pools: { mdc: "6d6+70" } }
  - name: "Animal Totem: Panda"
    description: "Symbol of patience, stability and secret or forgotten knowledge. Nightvision 500 feet (152 m), natural Climbing equal to a skill of 80%, bio-regenerates double the usual M.D.C. (2D6) per melee round; +10% to Science, Magic, Myth and Lore skills. Understands and speaks all languages (96%)."
    bonuses: { attributes: { PS: "1d4", PE: 1, PB: "1d6" }, combat: { parry: 1, disarm: 1, pull_punch: 2 }, saves: { mind_control: 2, curses: 1, possession: 2, horror_factor: 3 }, pools: { mdc: "5d6+40", isp: "3d10" } }
  - name: "Animal Totem: Pig/Boar"
    description: "Symbol of honesty and strength. +20% to Imitate Voices & Impersonation, Recognize Plants and Fruit and Preserve Food; keen hearing and sense of smell. Understands and speaks all Asian languages, Gobblely and Faerie Speak (88%)."
    bonuses: { attributes: { PS: "1d6", PE: 2, Spd: "1d10+6" }, combat: { strike: 3, parry: 1, dodge: 1 }, saves: { toxins_poisons: 5, disease: 5, curses: 3, possession: 4, horror_factor: 3 }, pools: { mdc: "5d6+50" } }
  - name: "Animal Totem: Rat/Rodent"
    description: "Symbol of charm and prosperity. Nightvision 1000 feet (305 m), natural Prowl of 70% +2% per level; +10% to Climb and Begging, +10% to Streetwise, +5% to Intelligence, Interrogation and Seduction. Understands and speaks all Asian languages and Gobblely (88%)."
    bonuses: { attributes: { MA: "1d6", PP: 2, Spd: "2d6+4" }, combat: { strike: 2, parry: 1, dodge: 1 }, saves: { spell_magic: 1, psionics: 1, curses: 2, possession: 1, horror_factor: 5 }, pools: { mdc: "4d6+35" } }
  - name: "Animal Totem: Rooster/Cock"
    description: "Symbol of courage and brazenness, arrogance and war. Double damage from kick and leap attacks; +10% to all Literary, Language and Math skills (including Yarrow Stick Counting and Gambling)."
    bonuses: { attributes: { PS: "1d6", PP: 2, PB: "1d4", Spd: "1d8+6" }, combat: { initiative: 2, strike: 3, parry: 2, dodge: 2, disarm: 2 }, saves: { illusionary_magic: 4, curses: 1, possession: 3, horror_factor: 6 }, pools: { mdc: "4d6+35" } }
  - name: "Animal Totem: Sheep/Goat"
    description: "Symbol of creativity and harmony. +10% to any Domestic skills, Art, and Whittling/Sculpting."
    bonuses: { attributes: { ME: "1d4", PS: "1d4", PE: "1d4", Spd: "2d10" }, combat: { strike: 2, parry: 2, dodge: 2, pull_punch: 4 }, saves: { spell_magic: 2, psionics: 2, curses: 2, possession: 4, horror_factor: 4 }, pools: { mdc: "5d6+35", isp: "2d6" } }
  - name: "Animal Totem: Snake"
    description: "Symbol of wisdom and cunning. Automatic dodge: dodging does not use up a melee attack, though the roll is still made. Nightvision 100 feet (30.5 m), natural Swim and Climb equal to a skill of 74% +2% per level, +5% on all Medical and Science skills. Understands and speaks all Asian languages and the tongues of Faeries, dragons and demons (95%)."
    bonuses: { attributes: { IQ: "1d4", ME: "1d6", PP: 1, PE: 1 }, combat: { initiative: 3, strike: 3, parry: 1, entangle: 3, pull_punch: 1, automatic_dodge: 3 }, saves: { toxins_poisons: 5, harmful_drugs: 5, spell_magic: 1, curses: 4, possession: 3, horror_factor: 5 }, pools: { mdc: "5d6+40" } }
  - name: "Animal Totem: Stag/Deer"
    description: "Symbol of vigor, power and contentedness. Nightvision 500 feet (152 m), sees the invisible, superb balance, can leap 25 feet (7.6 m) high and 50 feet (15.2 m) across (50% more with a running start); +10% to all Wilderness skills. Understands and speaks all Asian languages (88%)."
    bonuses: { attributes: { PS: "1d6", PE: 2, Spd: "3d10+30" }, combat: { strike: 2, parry: 4, dodge: 2 }, saves: { spell_magic: 3, curses: 2, possession: 4, horror_factor: 4 }, pools: { mdc: "6d6+60" } }
  - name: "Animal Totem: Tiger"
    description: "The king of beasts, symbol of vital energy, power, ferocity and hunting. Fatigues at half the usual rate, nightvision 1000 feet (305 m), can leap 20 feet (6.1 m) high and 40 feet (12.2 m) across from a standing position, Swim equal to a skill of 66%, natural Prowl of 80% +1% per level; +10% to Climb and Seduction, +5% to all Rogue and Wilderness skills. Understands and speaks all Asian languages (88%, including Indian)."
    bonuses: { attributes: { IQ: 1, PS: "1d6+10", PP: 2, Spd: "2d6+10" }, combat: { attacks: 1, initiative: 2, strike: 3, parry: 2, dodge: 2, pull_punch: 3 }, saves: { curses: 4, possession: 2, horror_factor: 6 }, pools: { mdc: "6d6+70" } }
  - { choose: 1, from: ["Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)", "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"] }
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"
    description: "No Sword Chi technique works without a blade the character knows and has named. Level 1: after at least 24 hours with the blade, awaken it as a personal Chi Blade with its own 2D6+8 I.S.P. (rolled once). Blade Chi Healing restores 3D6 points (1D6 M.D.C. to a mega-damage being) for 8 I.S.P.; Blade Chi Awareness warns of potential enemies within a range of less than 10 ft (3 m), through walls, floors and ceilings, for 2 I.S.P.; Blade Chi Mega-Damage turns the blade''s normal damage into M.D. against supernatural beings and M.D.C. technology (a 1D8 short sword does 1D8 M.D.). (printed 29-30.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Double the Chi Blade''s I.S.P." }
      - { level: 4, text: "The personal Chi Blade does an extra +1D6+2 M.D." }
      - { level: 5, text: "Blade Chi Resonance: the Chi Blade senses other significant weapons, above all self-aware or strongly magical ones, up to one mile (1.6 km) away, with their general direction and distance, whether they are stronger, weaker or about its equal, and whether one is wielded by great evil." }
      - { level: 6, text: "Blade Chi Power of Return: a lost or stolen Chi Blade teleports back to its owner, usually within 24 to 48 hours, arriving with just 1 I.S.P." }
      - { level: 7, text: "Awaken Other Chi Blades: a second Chi Blade can be awakened after the same 24 hours with it. 20 I.S.P. an attempt; roll under M.A. on a D20, a failed attempt may be repeated after no less than 24 hours, and a blade that fails three times is lifeless." }
      - { level: 8, text: "The personal Chi Blade does a further +1D6+2 M.D." }
      - { level: 9, text: "A second Chi Blade, if the character has one, gains all the bonuses and abilities of the first, and the two can be used as Paired Weapons." }
      - { level: 10, text: "Double the Chi Blade''s I.S.P." }
      - { level: 11, text: "A third Chi Blade can be awakened, as at level 7." }
      - { level: 12, text: "The first personal Chi Blade does an extra +10 M.D." }
      - { level: 13, text: "Personal Chi Blade Sentience: the primary blade (the first or second awakened) becomes fully aware, speaks telepathically with its wielder while held, has a 01-20% chance (rolled once) of spoken speech, and mirrors its owner''s alignment." }
      - { level: 14, text: "The Chi Blade can hide its I.S.P. and its sentience from psychics, See Aura and other ways of detecting psychic energy or emotion." }
      - { level: 15, text: "Add 6D6+6 to the primary Chi Blade''s I.S.P. and the same amount to the wielder''s I.S.P. Base." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)"
    description: "Stance bonuses apply only in that stance. Level 1: Viper Stance (thermal vision 60 ft; Fang Fingers 3D6 M.D. or 5D6 S.D.C.; no M.D.C.; six attacks a melee in all, +5 strike, +4 parry, +5 damage, +4 roll; no pulled punches); Rat Snake Stance (Knuckle Punch 2D6+10 M.D. or 3D6 S.D.C.; M.D.C. equal to P.E. +20; +1 attack, +4 strike, +3 parry, +3 roll); Art of Melting (silent movement as Prowl 60% +3% per level; escape once detected 70% +2% per level); and one Art of Invisibility, with one more at each of levels 3, 7, 10 and 13: Clouding the Mind (vanish for one melee action, 2 I.S.P. per person who looks into the character''s eyes or face, and for that moment also hidden from those who track P.P.E., I.S.P. or living spirits), Deception (silent movement, automatic while unsuspected, 60% +3% per level under inspection), Evasion (stay behind a foe and keep attacking unseen, or shadow someone for up to two melee rounds per level; automatic if the foe is unaware, otherwise 60% +3% per level; it fails if a friend of the victim can call a warning or the victim''s back is to a wall, and once sighted the character must vanish first, by Clouding the Mind or Vanishing, to resume it), Hiding (undetected unless the area is well lit and carefully inspected, then 60% +4% per level) or Vanishing (disappear from plain view, 90% +1% per level in darkness with obstructions, -25% in good light and a further -15% on clear, flat ground). (printed 34-35.)"
    progression:
      - { level: 2, text: "Knockout or stun from behind, and Critical Strike on a Natural 18 or better." }
      - { level: 3, text: "Select one more Art of Invisibility." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Chilling Touch (The Vapor): claws do 5D6 M.D. a strike; or the Chilling Touch, which uses four melee attacks, does 3D6 direct to hit points (4D6 M.D. to mega-damage creatures), turns the skin gray and shriveled, and costs the victim initiative and half his attacks for the next two melee rounds." }
      - { level: 6, text: "Spitting Python Stance: Python Jab Long Distance, one a melee, hits up to 100 ft (30.5 m) away for 4D6 M.D. or 3D6 S.D.C.; Python Jab Hand to Hand does 5D6 M.D. or 4D6 S.D.C.; a Natural 20 with either is a Death Blow. M.D.C. equal to P.E. +30. +6 strike, +3 parry, +3 damage, +3 roll with impact; no pulled punches." }
      - { level: 7, text: "Select one more Art of Invisibility." }
      - { level: 8, text: "+1 attack per melee round and +1 on initiative." }
      - { level: 9, text: "Add 4D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 10, text: "Select one more Art of Invisibility." }
      - { level: 11, text: "Cobra Stance: every strike is a paralysis attack. A victim who fails to avoid or roll with it takes no damage but the body or the targeted limb is paralyzed for 3D6 melee rounds; one who rolls with it takes 2D8 M.D. or 1D8 direct to hit points instead. M.D.C. equal to P.E. +20. Four attacks a melee in all, +5 strike, +3 parry, +3 roll with impact." }
      - { level: 12, text: "Knockout, stun or Critical Strike (the character''s choice) from behind on a Natural 17 or better." }
      - { level: 13, text: "Select one more Art of Invisibility." }
      - { level: 14, text: "Add 2D4x10+24 to the character''s Permanent I.S.P. Base." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"
    description: "Level 1: Falling Technique - no damage from a fall of 50 ft or less, 1 point per 50 ft from 51 to 400 ft, 1 point per 20 ft beyond 400 ft, and never more than 60 points (terminal velocity past 1200 ft); +1 to roll with punch or impact (other than a fall) at levels 1, 3, 4, 6, 8, 9, 11, 13 and 15. Light-Body Climbing - climb up or down at walking speed with no skill roll, carrying only basic gear and no passenger; requires the Climbing skill, which gains +10%. (printed 39-40.)"
    progression:
      - { level: 2, text: "Drunkard''s Staff: for 22 I.S.P. an ordinary staff, broomstick, pole or branch does 2D8 M.D. (2D8 S.D.C. to S.D.C. targets) and has 1D6x10 M.D.C. if attacked itself. It lasts at least one day; at the end of each 24 hours a roll under 10 on a D20 ends it, and seven saves in a row make it permanent." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+2 in all)." }
      - { level: 4, text: "Mystic Slime: for 10 I.S.P. an invisible slippery coating makes the character, his clothing, gear and weapons next to impossible to grab or hold. Falling Technique: +1 to roll with punch or impact (+3 in all)." }
      - { level: 5, text: "Neutralize Toxins: for 7 I.S.P., used mostly to drink great amounts of alcohol without being seriously affected." }
      - { level: 6, text: "Belch Toxic Vapor: for 10 I.S.P., at most twice a melee and one attack each, a belch in the face forces a save vs non-lethal poison (16 or higher). Failure: loses initiative and one attack and is -2 to strike, parry, dodge and all combat moves for 1D4 melee rounds. Success: loses one attack that round. Falling Technique: +1 to roll with punch or impact (+4 in all)." }
      - { level: 7, text: "Drunken Stranger (Qiao Zhuang): for 20 I.S.P. the character moves and looks like a different drunk and is not recognized unless seen full in the face in good light, for 24 hours per level." }
      - { level: 8, text: "Blind Drunk: for 12 I.S.P. the character blinds himself for 8 hours per level (cancelled at will) and suffers only a third of the blindness penalties (-3 to strike, parry, dodge and disarm). Falling Technique: +1 to roll with punch or impact (+5 in all)." }
      - { level: 9, text: "Drunken Style Meditation Advancement #1: +15 S.D.C., +2 to M.E. and P.P., +1 to save vs possession. Falling Technique: +1 to roll with punch or impact (+6 in all)." }
      - { level: 10, text: "Add 5D6+22 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Drunken Mind Cloak: for 6 I.S.P. per listener, up to 10 people per level, gibberish holds listeners oblivious to everything around them for as long as the character keeps talking and they are not attacked, robbed or shaken. Or, for 5 I.S.P. per person (also up to 10 people per level), up to four topics are planted in their memory for good after 2D12 melee rounds of confusion. Falling Technique: +1 to roll with punch or impact (+7 in all)." }
      - { level: 12, text: "Drunken Dragon Walk: for 10 I.S.P. the character staggers along the paths of any nearby dragon lines (ley lines) for 1D6 hours." }
      - { level: 13, text: "Inflict Mystic Drunkenness: one breath (one attack) on up to six victims at 10 I.S.P. each; a failed save vs non-lethal poison (16 or higher) leaves them drunk for 2D6 melee rounds, with Spd, skills and combat bonuses halved and -2 attacks per melee. Falling Technique: +1 to roll with punch or impact (+8 in all)." }
      - { level: 14, text: "Drunken Style Meditation Advancement #2: +2 to M.E. and M.A." }
      - { level: 15, text: "Add 1D6x10+33 to the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+9 in all)." }
level_progression:
  - { level: 2, grants: ["Psionics: See Aura, Sense Evil, Sense Magic"] }
  - { level: 3, grants: ["Psionics: Intuitive Combat, Presence Sense"] }
  - { level: 4, grants: ["Psionics: Mind Block, Resist Fatigue"] }
  - { level: 5, grants: ["Psionics: Resist Thirst", "+1D10 to permanent I.S.P. base"] }
  - { level: 6, grants: ["Psionics: Resist Hunger and one Physical power of choice"] }
  - { level: 7, grants: ["Psionics: Impervious to Cold, Death Trance"] }
  - { level: 8, grants: ["Psionics: Object Read, Alter Aura", "+2D10 to permanent I.S.P. base"] }
  - { level: 9, grants: ["Psionics: Remote Viewing and one Physical power of choice"] }
  - { level: 10, grants: ["Psionics: Impervious to Fire and one Sensitive power of choice"] }
  - { level: 11, grants: ["Psionics: Bio-Manipulation"] }
  - { level: 12, grants: ["Psionics: Empathic Transmission", "+3D10 to permanent I.S.P. base"] }
  - { level: 13, grants: ["Psionics: Radiate Horror Factor"] }
  - { level: 14, grants: ["Psionics: Electrokinesis or Hydrokinesis"] }
  - { level: 15, grants: ["Psionics: one Super power of choice, excluding Psi-Sword, Psi-Shield and Telemechanics"] }
restrictions:
  - "Hand to Hand: Dog Boxing, Monkey Style or Tai-Chi only."
  - "Cybernetics: none, avoided like the plague as unnatural."
trackable_resources: []
side_effects: "The animal totem''s bonuses, M.D.C. and Supernatural P.S. apply in the half-man, half-animal form, which is the Spirit Host''s natural form and the one stored; all of them are lost in human form (Metamorphosis: Human). In full animal form attacks per melee drop by two. Standard equipment also includes a complete suit of lightweight embroidered silk indoor clothing with silk scarf and hat, identification documents including a passport from one of the Yama Kingdoms and letters of recommendation praising the character as a farmer, worker or woodsman, 5D6 sheets of blank paper, 2D6+2 pieces of incense and a small incense burner, a collection of herbs, a traveler''s tea bottle, two sets of chopsticks, a large wooden spoon (1D4 S.D.C. as a weapon), a hairbrush and a nail file; these are not stored as items."
extraction_notes: "Rifts World Book 25: China 2 printed 67-72 (cache p068-p073, scan, page_offset +1); every number read off 200 dpi renders. The heading Spirit Host P.C.C. is on printed 67 (right column); powers 1-10 and the fourteen animal totems run 68-71, the stat block starts on 71 and the skills, equipment, money and cybernetics end at the top of 72, where the Blind Mystic P.C.C. begins. GROUP: printed 62 heads the section Chinese Diviner Psychic Character Classes, so occ_group psychic; a P.C.C. is category occ. No S.D.C. or hit points are printed, so men_of_arms: false (the core 1D6 S.D.C.), read off that psychic heading. XP: printed 160, the ladder headed Warrior: Jian Shih / Gun Master / Spirit Host, read off a render of cache p161. ATTRIBUTES: none required. RACE: none; predominantly human, 30% other races. MDC: Hit Points and S.D.C. combine into M.D.C. in the half-man, half-animal form, stored as mdc_from_hp_sdc true with the totem''s M.D.C. as a pool bonus; that form is the character''s natural one, so the totem bonuses are stored unconditionally and the human form''s loss of them is prose (judgement). Supernatural P.S. and 1D6 M.D.C. bio-regeneration per melee are prose. PSIONICS: Master Psychic (saves vs psionics on 10); I.S.P. M.E. x3, +1D6+6 per level. The level 1 powers are granted by name; levels 2-15 are schedule entries. The +1D10, +2D10 and +3D10 to the permanent I.S.P. base at levels 5, 8 and 12 are not in the pool formula and are added by hand (level_progression and the schedule notes). Commune with Spirits is the catalog''s Commune with Spirit; Object Read is Object Read (Psychometry); Bio-Manipulation is Bio-Manipulation (the evil eye). The level 15 Super pick excludes Psi-Sword, Psi-Shield and the four Telemechanic rows. Spirit Writing and View Ghost Drama are special psionic abilities with no catalog row and are stored as abilities. View Ghost Drama prints its cost as Eight P.P.E. under an I.S.P. Cost label; the description records it as printed, unresolved. ANIMAL TOTEM (printed 70-71): a choice of the fourteen printed animals, each carrying its M.D.C., I.S.P., attribute, combat and save bonuses; skill percentages and other specials are in each description. Demonic Curse saves are stored as curses; save vs poison and disease as toxins_poisons and disease; plain save vs magic as spell_magic; magic illusions as illusionary_magic; psionic attacks as psionics; Snake''s poison and drugs as toxins_poisons and harmful_drugs. The Dragon''s +1D6 to I.Q. or M.E. is a player''s choice and is prose. HAND TO HAND: a choice of Dog Boxing, Monkey Style or Tai-Chi, with no printed price for any other style, so costs {} (judgement). MYSTIC MARTIAL ART POWER: one of Bok Pai, Gui Long, She Shen, Mien-Ch''uan or Xian Pu; the chosen power is held from level 1 and its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). SKILLS: Begging and Fasting are the RUE rows plus the printed bonus (30+12, 40+10). Language: Native Chinese Speaker 90% is Language: Native Tongue at 90; Demongogian 80% and Literacy: Chinese 85% are flat figures with no per-level gain. Lore: Cattle and Animals is the Cowboy row Lore: Cattle & Animals. Track Animals is the catalog''s Track & Trap Animals (20+15). Lore or Language two of choice (+15%) is a Technical choice of two, the restriction in its note. The W.P. Chiang Zhu Spear or Bamboo Staff of ability 4 is a skill choice. Related: Medical is two entries, Animal Husbandry at +10% and the other three at +5%. Physical: fundamental abilities excludes Juicer Football, Murderthon and the three Space rows. Pilot: excludes the rows beginning Military:, Robot, Combat Pod and Air Assault Armor (military vehicles, robots and power armor; judgement). Weapon Proficiencies: ancient any, plus the basic pistols (W.P. Handguns, Automatic Pistol, Revolver, Energy Pistol) and W.P. Bolt Action Rifle and Energy Rifle. Secondary skills take the related limits without the bonuses. EQUIPMENT: the magic weapon and the pistol or rifle are weapons-matching-w-p-skills; the bone or stone weapon is the Green Scarf bone weapon row; walking stick or staff is a choice; the light armor is light-mdc-body-armor. Silk clothes, documents, paper, incense, herbs, chopsticks, spoon, hairbrush and nail file are in side_effects. MONEY: 1D6x1000 credits. CYBERNETICS: none. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 69 (cache p070), read off a render. Ability 3 reads ''Select one of the following'' and names five: Bok Pai Kung Fu (Crane Style), Gui Long Kung Fu (Dragon Blade), She Shen Kung Fu (Snake Style), Mien-Ch''uan Kung Fu (Cotton Fist) or Xian Pu Kung Fu (Drunken Style). One power, picked at creation; no later pick is printed. Stored as the one choose-1 group over those five, unchanged."
---

## Lore

The spirit host is a psychic diviner whose body can become a vessel for benevolent spirits. Beyond speaking with ancestors and the dead, the host bonds with one Nature Spirit above all, an animal totem, and the union reshapes him into a humanoid animal: a man with a stag''s head and antlers, a panda-like figure, a tiger-man and so on. In that form the spirit fills the mortal shell with the animus of its animal, making the host a mega-damage being of supernatural strength and keen senses, but also lending him wisdom and an insight into people and the spirit world.

This is no ordinary possession. Mortal and spirit truly merge: the human, or D-Bee, keeps his own mind and memories and hears no other voice. The mortal brings the heart and the drive to fight supernatural evil, the spirit brings the means, and together they are stronger than either. The blended form is the host''s natural state; returning to plain human shape takes concentration.

Most hosts felt drawn to the forest from childhood and one day simply opened themselves to it. They see the demons the Yama Kings have loosed as predators that do not belong in the natural world, and they mean to do something about it. Bold and versatile, compassionate toward mortals and merciless toward the demonic, they often join bands of Celestial heroes; others teach martial arts at monasteries and rouse people to defend their homeland, or wander the wilds protecting the innocent.
',
       updated_at = datetime('now')
 WHERE class_id = 'spirit-host'
   AND instr(markdown, 'pasted from the shared level-1 block; level 1 only, levels 2-15 not imported') > 0
   AND length(markdown) = 34746;

-- == jian-shih ==
UPDATE imported_classes
   SET markdown = '---
id: jian-shih
name: Jian Shih
system: rifts
source_book: Rifts World Book 25: China 2 p.43-45
category: occ
tags: [combat]
occ_group: men-of-arms
xp_table: [0, 2201, 4401, 9001, 18001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
sdc_base: "4d10+35"
starting_money: "4d6x100"
bonuses:
  attributes: { PS: 2, PE: 2, PP: 2 }
  combat: { initiative: 1, strike: 2, parry: 1, disarm: 2, pull_punch: 3, attacks: 1 }
  saves: { spell_magic: 1, horror_factor: 3, possession: 1 }
  at_level:
    - { level: 3, combat: { initiative: 1 }, saves: { possession: 1 } }
    - { level: 5, combat: { initiative: 1 }, saves: { possession: 1 } }
    - { level: 7, saves: { possession: 1 } }
    - { level: 8, combat: { initiative: 1 } }
    - { level: 9, saves: { possession: 1 } }
    - { level: 10, combat: { initiative: 1 } }
    - { level: 11, saves: { possession: 1 } }
    - { level: 12, combat: { initiative: 1 } }
    - { level: 13, saves: { possession: 1 } }
    - { level: 14, combat: { initiative: 1 } }
    - { level: 15, saves: { possession: 1 } }
psionics:
  type: "none"
  isp_base: "M.E. attribute number plus 3d6, +5 per level of experience"
skills:
  occ_skills:
    - { name: "Calligraphy", base: 50, per_level: 5, note: "+15%" }
    - { name: "Imperial Bureaucracy & Administration", base: 15, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 95%." }
    - { name: "Literacy: Chinese", base: 85, per_level: 5, note: "The book prints Literacy: Chinese characters/ideograms at 85%." }
    - { choose: 2, from: ["Literacy: Ancient & Classical Chinese", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Taoist", "Lore: Demons & Monsters", "Lore: Feng Shui/Geomancy"], bonus: 10, note: "Lore: any two (+10% each)." }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { choose: 2, from: ["Field Armorer & Munitions Expert", "Camouflage", "Demolitions", "Military Etiquette", "Military Fortification", "Recognize Weapon Quality", "Trap Construction", "Trap/Mine Detection"], note: "Military skills: any two. The book''s two Armorer/Field Armorer entries (Traditional Chinese Weapons, Modern Weapons) are both the catalog''s Field Armorer & Munitions Expert." }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming", "Wrestling"], note: "Physical skills: any two. The book offers Aerobic Athletics or General Athletics as one choice." }
    - { choose: 2, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.s: any two of Battle Axe, Paired Weapons, Pole Arm, Siege Weapons, Spear, Large Sword, Small Sword or Trident. Battle Axe is the catalog''s W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.s: any two." }
    - { choose: 2, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.s: any two. The book''s Spear (Throwing) is the catalog''s W.P. Spear." }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.s: any two." }
    - { name: "W.P. Wen Jen (Scholar''s Sword)", base: 0, per_level: 0, note: "Granted by the Jian Shih''s chi training." }
    - { choose: 1, from: ["Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Shao-Lin Kung Fu", "Hand to Hand: Tai-Chi Ch''uan"], note: "Select Eighteen Weapons Kung Fu, Shao-Lin Kung Fu or Tai-Chi Ch''uan as the basis of the character''s combat skills. The book prints no price for changing it." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Horsemanship", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Jump Bike Combat", "Fighter Combat: Basic", "Fighter Combat: Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Military: none. Pilot: any except military vehicles, robots and power armor. Pilot Related: none. W.P.: any except Heavy Weapons, Heavy Energy Weapons or Sharpshooting. All new skills start at level one proficiency."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Jump Bike Combat", "Fighter Combat: Basic", "Fighter Combat: Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 7, 9 and 13, from the related list and its limits, at base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 3, note: "Three traditional Chinese weapons besides the special sword, typically matching W.P.s, with 3D6 units or rounds of ammunition for each projectile weapon." }
  - { item_id: "energy-weapon-of-choice", qty: 1, note: "One pistol-sized energy weapon." }
  - { item_id: "e-clip", qty: 2 }
  - { item_id: "traveling-clothes", qty: 1, note: "Rough traveling clothes of cotton, wool and leather." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "dress-clothing", qty: 1, note: "A complete suit of lightweight embroidered silk indoor clothing: slippers, pants, shirt, long jacket, robe, scarf and hat." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book." }
  - { item_id: "pencil", qty: 1 }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block; just add water." }
  - { item_id: "brushes-low-quality", qty: "1d4+4", note: "Bamboo brushes." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "utensil-kit", qty: 1, note: "Two sets of chopsticks, one plain and sturdy, the other delicate." }
  - { item_id: "knife", qty: 1, note: "A cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "A small meat cleaver." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "A belt pouch." }
  - { item_id: "climbing-rope-per-foot", qty: 30, note: "30 feet (9.1 m) of climbing rope." }
  - { item_id: "canteen", qty: 2, note: "Bamboo canteens of water." }
special_abilities:
  - { choose: 1, from: ["Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"], note: "Granted outright (printed 44): the Jian Shih is initiated into Gui Long Kung Fu; the pick only puts its level table on the sheet." }
  - name: "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"
    description: "No Sword Chi technique works without a blade the character knows and has named. Level 1: after at least 24 hours with the blade, awaken it as a personal Chi Blade with its own 2D6+8 I.S.P. (rolled once). Blade Chi Healing restores 3D6 points (1D6 M.D.C. to a mega-damage being) for 8 I.S.P.; Blade Chi Awareness warns of potential enemies within a range of less than 10 ft (3 m), through walls, floors and ceilings, for 2 I.S.P.; Blade Chi Mega-Damage turns the blade''s normal damage into M.D. against supernatural beings and M.D.C. technology (a 1D8 short sword does 1D8 M.D.). (printed 29-30.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Double the Chi Blade''s I.S.P." }
      - { level: 4, text: "The personal Chi Blade does an extra +1D6+2 M.D." }
      - { level: 5, text: "Blade Chi Resonance: the Chi Blade senses other significant weapons, above all self-aware or strongly magical ones, up to one mile (1.6 km) away, with their general direction and distance, whether they are stronger, weaker or about its equal, and whether one is wielded by great evil." }
      - { level: 6, text: "Blade Chi Power of Return: a lost or stolen Chi Blade teleports back to its owner, usually within 24 to 48 hours, arriving with just 1 I.S.P." }
      - { level: 7, text: "Awaken Other Chi Blades: a second Chi Blade can be awakened after the same 24 hours with it. 20 I.S.P. an attempt; roll under M.A. on a D20, a failed attempt may be repeated after no less than 24 hours, and a blade that fails three times is lifeless." }
      - { level: 8, text: "The personal Chi Blade does a further +1D6+2 M.D." }
      - { level: 9, text: "A second Chi Blade, if the character has one, gains all the bonuses and abilities of the first, and the two can be used as Paired Weapons." }
      - { level: 10, text: "Double the Chi Blade''s I.S.P." }
      - { level: 11, text: "A third Chi Blade can be awakened, as at level 7." }
      - { level: 12, text: "The first personal Chi Blade does an extra +10 M.D." }
      - { level: 13, text: "Personal Chi Blade Sentience: the primary blade (the first or second awakened) becomes fully aware, speaks telepathically with its wielder while held, has a 01-20% chance (rolled once) of spoken speech, and mirrors its owner''s alignment." }
      - { level: 14, text: "The Chi Blade can hide its I.S.P. and its sentience from psychics, See Aura and other ways of detecting psychic energy or emotion." }
      - { level: 15, text: "Add 6D6+6 to the primary Chi Blade''s I.S.P. and the same amount to the wielder''s I.S.P. Base." }
  - name: "Special Weapon: Taoist Sword"
    description: "A custom sword forged by a Taoist artisan. It does 3D6 damage even in inexpert hands, has 200 M.D.C., and is damaged only when an opponent deliberately tries to damage or destroy it. Not indestructible."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Gathers and directs chi, the life force present even where P.P.E. is weak, to add Mega-Damage to otherwise ordinary weapons. Grants W.P. Wen Jen (Scholar''s Sword)."
  - name: "Powers of Meditation"
    description: "Has the Meditation skill and an I.S.P. base of M.E. +3D6, +5 per level. Will never gain psionic powers other than the abilities of Gui Long Kung Fu."
  - name: "Champion of the Celestial Court"
    description: "Sees the Yama Kings as part of the Celestial Order who have strayed from their place, to be returned rather than destroyed. Aims to dispel the Mist that hides China from the Jade Emperor''s court, keep the Yama Kings'' hells from spreading, and save the innocent from the demons loosed on the land."
level_progression:
  - { level: 3, grants: ["+1 on initiative", "+1 to save vs possession"] }
  - { level: 5, grants: ["+1 on initiative", "+1 to save vs possession"] }
  - { level: 7, grants: ["+1 to save vs possession"] }
  - { level: 8, grants: ["+1 on initiative"] }
  - { level: 9, grants: ["+1 to save vs possession"] }
  - { level: 10, grants: ["+1 on initiative"] }
  - { level: 11, grants: ["+1 to save vs possession"] }
  - { level: 12, grants: ["+1 on initiative"] }
  - { level: 13, grants: ["+1 to save vs possession"] }
  - { level: 14, grants: ["+1 on initiative"] }
  - { level: 15, grants: ["+1 to save vs possession"] }
restrictions:
  - "Either M.A. or M.E. should be above 11; high P.P. and P.E. are helpful but not required."
  - "Cybernetics: none."
  - "No psionic powers beyond the abilities of Gui Long Kung Fu."
trackable_resources: []
side_effects: "Money is 4D6x100 in credits. The book''s equipment list also carries identification documents (a passport from one of the Yama Kingdoms and letters of recommendation praising the character as a good worker), 6D6 sheets of blank paper, a collection of herbs for tea, flavoring and emergency medicine, a traveler''s tea bottle, 30 cups of uncooked rice, a large traveler''s shoulder bag and a small neck pouch; these have no catalog rows and are not given as items."
extraction_notes: "Rifts World Book 25: China 2 printed 43-45 (cache p044-p046, a scan; every number read off 200 dpi renders). Printed 43 lists the class under Rifts China Martial Art Warriors O.C.C.s, a warrior heading, so occ_group men-of-arms; the class prints its own S.D.C. (4D10+35), so no men_of_arms line. XP ladder: printed 160 (cache p161), column Warrior: Jian Shih / Gun Master / Spirit Host, read off a render. Attribute requirements: the book says either M.A. or M.E. should be above 11, an either/or the frontmatter cannot enforce, so it is a restriction line and no attribute_requirements are stored. Psionics: the book gives an I.S.P. base (M.E. +3D6, +5 per level) but no psychic tier and no powers, so psionics type none carries the pool. Save vs magic is stored as spell_magic. Mystic Martial Art Power: Gui Long Kung Fu, confirmed on printed 44; it is held from level 1 and its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). Hand to Hand: a choice of Eighteen Weapons Kung Fu, Shao-Lin Kung Fu or Tai-Chi Ch''uan; the book prints no price to change, so no hand_to_hand block. W.P. mapping: Battle Axe to W.P. Axe, Large Sword and Small Sword to W.P. Sword, Spear (Throwing) to W.P. Spear, Crossbow to W.P. Cross Bow; Heavy Weapons to W.P. Heavy Military Weapons and Heavy Energy Weapons to W.P. Heavy M.D. Weapons. Language: Native Chinese Speaker is Language: Native Tongue at the printed 95%; Literacy: Chinese is its own row at the printed 85% with the catalog''s per-level gain. Rogue Gambling is both catalog Gambling rows. The special sword has no gear row and is an ability; the items without catalog rows are listed in side_effects. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 44 (cache p045), read off a render. Ability 3 says the character has been initiated into the practice of Gui Long Kung Fu; there is no choice and no later pick. Stored as a one-option choose-1 group over Gui Long Kung Fu (Dragon Blade), which is what puts the power''s level table on the sheet."
---

## Lore

The Jian Shih are the knights-errant of Rifts China, warriors who carry themselves like heroes out of old tales and believe that righteousness wins in the end. They serve the Jade Emperor''s Celestial Court in spirit, if not in any recognized office, and cannot easily walk away from anyone who is being persecuted or preyed upon.

That idealism is tempered by a hard lesson: in a land overrun by the Yama Kings, staying alive often means hiding rather than charging a demon army. The Jian Shih trains mind, body and spirit together - strategy and weaponry, a strong and precise body, and meditation and mystic martial arts. Each is initiated into Gui Long Kung Fu, the way of the Dragon Blade, which treats the sword as the most perfect of weapons and a thing that can come alive.

A Jian Shih goes armed to the teeth with blades and at least one mega-damage sidearm, but dresses to look harmless, since showing one''s true colors in the Yama Kings'' lands brings trouble on everyone nearby. Most are Principled, many Scrupulous, and almost a third are women.

Standard equipment: the special sword, three other traditional Chinese weapons with ammunition, a pistol-sized energy weapon with two E-Clips, rough traveling and winter clothes, a suit of embroidered silk indoor clothing, travel documents, writing materials, tea and herbs, cooking gear and rice, bags and pouches, 30 ft of climbing rope and two bamboo canteens.
',
       updated_at = datetime('now')
 WHERE class_id = 'jian-shih'
   AND instr(markdown, 'the abilities it grants at levels 2-15 are not imported') > 0
   AND length(markdown) = 15976;

-- == nei-chia-wu-shih ==
UPDATE imported_classes
   SET markdown = '---
id: nei-chia-wu-shih
name: Nei Chia Wu Shih
system: rifts
source_book: Rifts World Book 25: China 2 p.48-51
category: occ
tags: [combat]
occ_group: men-of-arms
xp_table: [0, 2401, 4801, 9601, 19201, 32801, 43201, 62801, 85401, 108601, 165201, 220401, 290601, 380201, 470401]
attribute_requirements: { PP: 13 }
sdc_base: "1d6x10+P.E."
starting_money: "3d6x100"
bonuses:
  attributes: { PP: 4, ME: 3, PS: 4, PE: 2 }
  combat: { pull_punch: 5 }
  saves: { spell_magic: 1, horror_factor: 3 }
  at_level:
    - { level: 2, combat: { initiative: 1 } }
    - { level: 3, combat: { initiative: 1, strike: 1 }, saves: { possession: 2 } }
    - { level: 4, combat: { initiative: 1 } }
    - { level: 6, combat: { initiative: 1, strike: 1 }, saves: { possession: 2 } }
    - { level: 7, combat: { initiative: 1 } }
    - { level: 9, combat: { initiative: 1, strike: 1 }, saves: { possession: 2 } }
    - { level: 11, combat: { initiative: 1 } }
    - { level: 12, combat: { strike: 1 }, saves: { possession: 2 } }
    - { level: 13, combat: { initiative: 1 } }
    - { level: 15, combat: { initiative: 1, strike: 1 }, saves: { possession: 2 } }
psionics:
  type: "none"
  isp_base: "M.E. attribute number plus 5d6, +7 per level of experience"
skills:
  occ_skills:
    - { name: "Fasting", base: 50, per_level: 3, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 40, per_level: 5, note: "+15%. Most are vegetarians who eke out a meager diet with wild plants." }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 95%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "The book prints Literacy: Chinese characters/ideograms at 75%." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%" }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Acrobatics", base: 50, per_level: 5, note: "+20%" }
    - { choose: 4, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming", "Wrestling"], note: "Physical skills: any four. The book offers Aerobic Athletics or General Athletics as one choice, and lists Acrobatics here although the class already has it at +20%." }
    - { choose: 4, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.s: any four of Battle Axe, Paired Weapons, Pole Arm, Siege Weapons, Spear, Large Sword, Small Sword or Trident. Battle Axe is the catalog''s W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.s: any two." }
    - { choose: 3, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.s: any three. The book''s Spear (Throwing) is the catalog''s W.P. Spear." }
    - { choose: 1, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.s: any one." }
    - { name: "W.P. Bamboo Staff", base: 0, per_level: 0, note: "Granted by the Nei Chia Wu Shih''s chi training." }
    - { name: "W.P. Gien Bian (Steel Whip)", base: 0, per_level: 0, note: "Granted by the Nei Chia Wu Shih''s chi training." }
    - { name: "Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", base: 0, per_level: 0, note: "The primary style. The class also trains a second, empty-hand style, chosen under special abilities. The book prints no price for changing either." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Jump Bike Combat", "Fighter Combat: Basic", "Fighter Combat: Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Military: none. Pilot: any except military vehicles, robots and power armor. Pilot Related: none. Science: none. W.P.: any except Heavy Weapons, Heavy Energy Weapons or Sharpshooting. All new skills start at level one proficiency."
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Jump Bike Combat", "Fighter Combat: Basic", "Fighter Combat: Elite", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 7, 9 and 13, from the related list and its limits, at base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 5, note: "Five traditional Chinese weapons besides the special sword, usually reflecting W.P.s, with 3D6 units or rounds of ammunition for each projectile weapon." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged traveling clothes of cotton, wool and leather." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "robe", qty: 1, note: "Simple temple garb: robe." }
  - { item_id: "hooded-cloak", qty: 1, note: "Simple temple garb: a warm cloak." }
  - { item_id: "sandals", qty: 1 }
  - { item_id: "bowl-earthenware", qty: 1, note: "A begging bowl." }
  - { item_id: "dress-clothing", qty: 1, note: "A complete suit of lightweight embroidered silk indoor clothing: slippers, pants, shirt, long jacket, robe, scarf and hat." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book." }
  - { item_id: "pencil", qty: 1, note: "Pen or pencil." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "utensil-kit", qty: 1, note: "Two sets of chopsticks, one rough, the other delicate." }
  - { item_id: "knife", qty: 1, note: "A cooking knife." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "A belt pouch." }
  - { item_id: "climbing-rope-per-foot", qty: 30, note: "30 feet (9.1 m) of climbing rope." }
  - { item_id: "canteen", qty: 1, note: "One bamboo canteen of water." }
special_abilities:
  - { choose: 1, from: ["Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"], note: "Granted outright (printed 50): like the Jian Shih, initiated into Gui Long Kung Fu; the pick only puts its level table on the sheet." }
  - name: "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"
    description: "No Sword Chi technique works without a blade the character knows and has named. Level 1: after at least 24 hours with the blade, awaken it as a personal Chi Blade with its own 2D6+8 I.S.P. (rolled once). Blade Chi Healing restores 3D6 points (1D6 M.D.C. to a mega-damage being) for 8 I.S.P.; Blade Chi Awareness warns of potential enemies within a range of less than 10 ft (3 m), through walls, floors and ceilings, for 2 I.S.P.; Blade Chi Mega-Damage turns the blade''s normal damage into M.D. against supernatural beings and M.D.C. technology (a 1D8 short sword does 1D8 M.D.). (printed 29-30.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Double the Chi Blade''s I.S.P." }
      - { level: 4, text: "The personal Chi Blade does an extra +1D6+2 M.D." }
      - { level: 5, text: "Blade Chi Resonance: the Chi Blade senses other significant weapons, above all self-aware or strongly magical ones, up to one mile (1.6 km) away, with their general direction and distance, whether they are stronger, weaker or about its equal, and whether one is wielded by great evil." }
      - { level: 6, text: "Blade Chi Power of Return: a lost or stolen Chi Blade teleports back to its owner, usually within 24 to 48 hours, arriving with just 1 I.S.P." }
      - { level: 7, text: "Awaken Other Chi Blades: a second Chi Blade can be awakened after the same 24 hours with it. 20 I.S.P. an attempt; roll under M.A. on a D20, a failed attempt may be repeated after no less than 24 hours, and a blade that fails three times is lifeless." }
      - { level: 8, text: "The personal Chi Blade does a further +1D6+2 M.D." }
      - { level: 9, text: "A second Chi Blade, if the character has one, gains all the bonuses and abilities of the first, and the two can be used as Paired Weapons." }
      - { level: 10, text: "Double the Chi Blade''s I.S.P." }
      - { level: 11, text: "A third Chi Blade can be awakened, as at level 7." }
      - { level: 12, text: "The first personal Chi Blade does an extra +10 M.D." }
      - { level: 13, text: "Personal Chi Blade Sentience: the primary blade (the first or second awakened) becomes fully aware, speaks telepathically with its wielder while held, has a 01-20% chance (rolled once) of spoken speech, and mirrors its owner''s alignment." }
      - { level: 14, text: "The Chi Blade can hide its I.S.P. and its sentience from psychics, See Aura and other ways of detecting psychic energy or emotion." }
      - { level: 15, text: "Add 6D6+6 to the primary Chi Blade''s I.S.P. and the same amount to the wielder''s I.S.P. Base." }
  - { choose: 1, from: ["Secondary Hand to Hand: Dog Boxing Kung Fu", "Secondary Hand to Hand: Drunken Style Kung Fu", "Secondary Hand to Hand: Monkey Style Kung Fu"], note: "The second, empty-hand martial art the class trains for fun and relaxation (see extraction_notes)." }
  - name: "Secondary Hand to Hand: Dog Boxing Kung Fu"
    description: "Trains and advances in Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan) as a second, empty-hand style alongside Eighteen Weapons Kung Fu. Recorded here rather than as a skill: the sheet holds one Hand to Hand style and applies Eighteen Weapons; use this style''s table by hand when fighting without weapons."
  - name: "Secondary Hand to Hand: Drunken Style Kung Fu"
    description: "Trains and advances in Hand to Hand: Drunken Style Kung Fu as a second, empty-hand style alongside Eighteen Weapons Kung Fu. Recorded here rather than as a skill: the sheet holds one Hand to Hand style and applies Eighteen Weapons; use this style''s table by hand when fighting without weapons."
  - name: "Secondary Hand to Hand: Monkey Style Kung Fu"
    description: "Trains and advances in Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar) as a second, empty-hand style alongside Eighteen Weapons Kung Fu. Recorded here rather than as a skill: the sheet holds one Hand to Hand style and applies Eighteen Weapons; use this style''s table by hand when fighting without weapons."
  - name: "Special Weapon: Taoist Sword"
    description: "A custom sword forged by a Taoist artisan. It does 3D6 damage (M.D. against mega-damage targets, S.D.C. against S.D.C. targets) even in inexpert hands, has 200 M.D.C., and is damaged only when an opponent deliberately tries to damage or destroy it. Not indestructible. The Nei Chia Wu Shih saves swords for truly challenging fights and likes to awaken the Chi Blade of other weapons."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Gathers and directs chi, the life force present even where P.P.E. is weak, so that ordinary weapons deliver Mega-Damage to M.D.C. opponents. Grants W.P. Bamboo Staff and W.P. Gien Bian (Steel Whip)."
  - name: "Powers of Meditation"
    description: "Has the Meditation skill and an I.S.P. base of M.E. +5D6, +7 per level. Will never gain psionic powers other than the abilities of Gui Long Kung Fu."
  - name: "Warrior of the Body, Warrior of the Mind"
    description: "Believes this time and place were chosen for the chance to meet worthy foes, and that the Yama Kings exist to be met in battle one at a time. Seeks a worthy band with a leader who plans challenging battles, engages the most dangerous enemies, and fights only for just causes."
level_progression:
  - { level: 2, grants: ["+1 on initiative"] }
  - { level: 3, grants: ["+1 on initiative", "+1 to strike", "+2 to save vs possession"] }
  - { level: 4, grants: ["+1 on initiative"] }
  - { level: 6, grants: ["+1 on initiative", "+1 to strike", "+2 to save vs possession"] }
  - { level: 7, grants: ["+1 on initiative"] }
  - { level: 9, grants: ["+1 on initiative", "+1 to strike", "+2 to save vs possession"] }
  - { level: 11, grants: ["+1 on initiative"] }
  - { level: 12, grants: ["+1 to strike", "+2 to save vs possession"] }
  - { level: 13, grants: ["+1 on initiative"] }
  - { level: 15, grants: ["+1 on initiative", "+1 to strike", "+2 to save vs possession"] }
restrictions:
  - "Cybernetics: none."
  - "No psionic powers beyond the abilities of Gui Long Kung Fu."
trackable_resources: []
side_effects: "Money is 3D6x100 in credits. The book''s equipment list also carries identification documents (a passport from one of the Yama Kingdoms), a collection of herbs for tea, flavoring and emergency medicine, a traveler''s tea bottle, 10 cups of uncooked rice and a large traveler''s shoulder bag; these have no catalog rows and are not given as items."
extraction_notes: "Rifts World Book 25: China 2 printed 48-51 (cache p049-p052, a scan; every number read off 200 dpi renders). Printed 43 lists the class under Rifts China Martial Art Warriors O.C.C.s, a warrior heading, so occ_group men-of-arms; the class prints its own S.D.C. (1D6x10 + P.E. attribute number), so no men_of_arms line. XP ladder: printed 160 (cache p161), column Enlightened Demon / Monk: Chi-Gung Sen Ren / Warrior: Nei Chia Wu Shih, read off a render. The book numbers both Powers of Meditation and O.C.C. Bonuses as 6. Psionics: the book gives an I.S.P. base (M.E. +5D6, +7 per level) but no psychic tier and no powers, so psionics type none carries the pool. Save vs magic is stored as spell_magic. Initiative +1 at levels 2, 3, 4, 6, 7, 9, 11, 13 and 15 (none at level 1); strike +1 at levels 3, 6, 9, 12 and 15; possession +2 at levels 3, 6, 9, 12 and 15. Mystic Martial Art Power: Gui Long Kung Fu (printed 50); it is held from level 1 and its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). Hand to Hand: the book calls this the only class with two advanced styles, Eighteen Weapons Kung Fu plus one empty-hand style (Dog Boxing, Drunken Style or Monkey Style). The app holds one style per character and a second Hand to Hand skill would replace the first, so Eighteen Weapons is the skill and the second style is a special-ability choice applied by hand. The book prints no price to change, so no hand_to_hand block. Skills: the Physical choice lists Acrobatics, which the class already holds at +20%. W.P. mapping: Battle Axe (printed without its W.P. prefix) to W.P. Axe, Large Sword and Small Sword to W.P. Sword, Spear (Throwing) to W.P. Spear, Crossbow to W.P. Cross Bow; Heavy Weapons to W.P. Heavy Military Weapons and Heavy Energy Weapons to W.P. Heavy M.D. Weapons. Language: Native Chinese Speaker is Language: Native Tongue at the printed 95%; Literacy: Chinese is its own row at the printed 75% with the catalog''s per-level gain. Identify Plants & Fruits is the catalog''s Identify Plants & Fruit. Rogue Gambling is both catalog Gambling rows. The book''s equipment gives no energy weapon or E-Clips. The special sword has no gear row and is an ability; the items without catalog rows are listed in side_effects. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 50 (cache p051), read off a render. Ability 4 says that, like the Jian Shih, the character has been initiated into the practice of Gui Long Kung Fu (and prefers to awaken the Chi Blade of weapons other than swords in lesser fights); there is no choice and no later pick. Stored as a one-option choose-1 group over Gui Long Kung Fu (Dragon Blade), which is what puts the power''s level table on the sheet."
---

## Lore

Calm, clear and committed, the Nei Chia Wu Shih tries to be a smooth stone in the river of life, letting trouble wash past without being moved. What separates this warrior from a monk is one word: deadly. In battle the Nei Chia Wu Shih''s mind goes still, combat becomes a moving meditation, and foes fall like cut grass.

These warriors are part of the world rather than apart from it. They are unpretentious, happy to admit what they do not know, and most at home when they have found an honest leader who will plan the battles and leave them free to fight. Some are graceful and striking; others are awkward and rumpled until the first step into a fight, when every inner voice falls silent.

They see this age of the Yama Kings as the perfect time to be alive: a chance to meet the worthiest foes one by one and fight without restraint, but only in a just cause. Each studies two martial arts - Eighteen Weapons Kung Fu as a serious discipline and an empty-hand style for pleasure - and the Gui Long way of the sword. Many are not human, and women slightly outnumber men.

Standard equipment: the special sword and five other traditional Chinese weapons with ammunition, rugged traveling and winter clothes, simple temple garb with a begging bowl, a suit of embroidered silk indoor clothing, travel documents, a blank book, tea and herbs, cooking gear and rice, a bag and pouch, 30 ft of climbing rope and a bamboo canteen.
',
       updated_at = datetime('now')
 WHERE class_id = 'nei-chia-wu-shih'
   AND instr(markdown, 'the abilities it grants at levels 2-15 are not imported') > 0
   AND length(markdown) = 17471;

-- == wai-chia-wu-shih ==
UPDATE imported_classes
   SET markdown = '---
id: wai-chia-wu-shih
name: Wai Chia Wu Shih
system: rifts
source_book: Rifts World Book 25: China 2 p.52-54
category: occ
tags: [combat, healer]
occ_group: psychic
xp_table: [0, 2241, 4481, 9101, 18301, 30601, 42901, 62301, 85601, 105901, 155001, 210001, 285001, 370001, 440001]
race_restrictions: { only: ["none"], note: "Human, or a race so close to human in appearance that even an elder Wai Chia Wu Shih cannot tell the difference (GM''s call). Very few women are drawn to the order (under 2%)." }
attribute_requirements: { ME: 12 }
sdc_base: "4d6+38"
starting_money: "1d6x100"
bonuses:
  attributes: { ME: 4, MA: 2, PP: 2 }
  combat: { attacks_base: 4, strike: 1, dodge: 2, roll: 3, pull_punch: 4 }
  saves: { spell_magic: 3, horror_factor: 4, possession: 1, curses: 1 }
  at_level:
    - { level: 2, combat: { parry: 2, dodge: 2 } }
    - { level: 3, combat: { strike: 2, roll: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 4, combat: { parry: 1, dodge: 1, initiative: 1 }, saves: { possession: 1, curses: 1 } }
    - { level: 5, combat: { attacks: 1 }, saves: { possession: 1, curses: 1 } }
    - { level: 6, combat: { roll: 2, parry: 1, dodge: 1, disarm: 1 } }
    - { level: 7, combat: { strike: 1, damage_bonus: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 8, combat: { attacks: 1, initiative: 1 } }
    - { level: 9, saves: { possession: 1, curses: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 11, combat: { strike: 1, damage_bonus: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 12, combat: { roll: 1, parry: 1, dodge: 1, initiative: 1 } }
    - { level: 13, combat: { disarm: 2, entangle: 2 }, saves: { possession: 1, curses: 1 } }
    - { level: 14, combat: { attacks: 1 } }
    - { level: 15, combat: { strike: 2, damage_bonus: 4 }, saves: { possession: 1, curses: 1 } }
psionics:
  type: "minor"
  isp_base: "M.E. attribute number plus 6d6, +6 per level of experience"
  powers: ["Levitation"]
  powers_starting: 6
  categories_allowed: ["Healing", "Physical"]
  powers_starting_groups:
    - { count: 3, categories: ["Healing"], note: "Three psionic Healing abilities of choice." }
    - { count: 3, categories: ["Physical"], note: "Three psionic Physical abilities of choice." }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%" }
    - { name: "Fasting", base: 45, per_level: 3, note: "+5%" }
    - { name: "Identify Plants & Fruit", base: 30, per_level: 5, note: "+5%. They live off the land, adding weeds, roots and mushrooms to their dinner; about 80% are strict vegetarians." }
    - { name: "Imperial Bureaucracy & Administration", base: 20, per_level: 5, note: "+10%; the book prints Imperial Bureaucracy & Administrative." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker (95%)." }
    - { name: "Literacy: Chinese", base: 90, per_level: 5, note: "The book prints Literacy: Chinese characters/ideograms (90%)." }
    - { choose: 3, from: ["Literacy: Ancient & Classical Chinese", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Taoist", "Lore: Demons & Monsters", "Lore: Feng Shui/Geomancy"], bonus: 10, note: "Lore: any three of Literacy: Ancient & Classical Chinese, Chinese Classical Studies, Chinese Mythology - Taoist, Demons & Monsters, or Feng Shui/Geomancy (+10% each)." }
    - { name: "Meditation", base: 0, per_level: 0, note: "The character is highly skilled in Meditation." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming", "Wrestling"], note: "Physical Skills: any two of Acrobatics, Aerobic or General Athletics, Body Building & Weight Lifting, Boxing, Climbing, Gymnastics, Running, Swimming or Wrestling." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Domestic", bonus: 5 }
      - { name: "Espionage", only: ["Pick Locks"] }
      - "Horsemanship"
      - { name: "Medical", only: ["Acupuncture", "Chinese Herbal Medicine"], bonus: 10 }
      - { name: "Medical", except: ["Acupuncture", "Chinese Herbal Medicine"] }
      - { name: "Physical", except: ["Boxing"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Bicycling"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - { name: "Technical", bonus: 5 }
      - "Wilderness"
    note: "Communications, Electrical, Espionage, Mechanical, Military, Pilot Related and W.P.: none. Medical: any (+10% to Acupuncture and Chinese Herbal Medicine). Pilot: sail and row boats, bicycle and other very basic vehicles only; they prefer Horsemanship. Rogue: Begging, Calligraphic Forgery, Concealment, Dickering, Gambling, Palming, Pick Locks and Streetwise only. Technical: any (+5%; +10% to Lore and History skills). All new skills start at level one proficiency."
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Domestic"
      - { name: "Espionage", only: ["Pick Locks"] }
      - "Horsemanship"
      - "Medical"
      - { name: "Physical", except: ["Boxing"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Bicycling"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Concealment", "Dickering", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Streetwise"] }
      - "Science"
      - "Technical"
      - "Wilderness"
    note: "Three at level one and one more at levels 3, 7, 9 and 13, from the related list and its limits, at the base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1, note: "Simple but sturdy traveling clothes of cotton, wool and leather." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "dress-clothing", qty: 1, note: "A complete suit of lightweight embroidered silk indoor clothing: slippers, pants, shirt, long jacket and robe." }
  - { item_id: "scarf", qty: 1, note: "Goes with the silk indoor clothing, with a hat." }
  - { item_id: "paper-dz-9x12-inch-sheets", qty: 1, note: "2D4x10 blank sheets of paper." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block (just add water)." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "bottle-pint", qty: 1, note: "A traveler''s tea bottle." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "A cooking knife." }
  - { item_id: "shoulder-purse-large", qty: 1, note: "A large traveler''s shoulder bag." }
  - { item_id: "belt-purse", qty: 1, note: "A belt pouch." }
  - { item_id: "pocket-mirror", qty: 1, note: "A small mirror." }
  - { item_id: "climbing-rope-per-foot", qty: 30, note: "30 feet (9.1 m) of climbing rope." }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - name: "Preacher of the Way of Chi"
    description: "The Yama Kings will only be driven off when enough people come to hate evil itself, not just its demons. The Wai Chia preaches to that end: to dispel the Mist that hides Rifts China from the Jade Emperor''s Celestial Court, to show that the way of the empty hand can prevail even against the demons of the Ten Hells, and to stand with the innocent, the helpless, children and the elderly against any oppressor, human or demon."
  - name: "Hand to Hand: Xian Tai Chi Chuan (Immortal and Eternal, Mind and Body)"
    description: "The order''s single combined study of physical martial arts, mystic martial arts and chi manipulation, taken in place of Hand to Hand: Basic Tai Chi. Level 1: four attacks per melee round, +3 to roll with punch, fall or impact, +2 to dodge; Grab & Throw (1D4 damage; the victim loses initiative and its next melee attack/action); Open Hand Push (1D4 damage; the victim loses initiative and its next two melee attacks/actions). Level 4: Critical Strike on a natural 19 or 20. Level 9: Knockout/Stun on a natural 19 or 20. Level 13: Critical Strike on a natural 17 or better. Every numeric bonus of the table (levels 1-15) is in the class bonuses."
  - { choose: 1, from: ["Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"], note: "Granted outright (printed 52); the pick only puts its level table on the sheet." }
  - name: "Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"
    description: "Level 1: Chi Ball. Four full melee rounds (one minute) to evoke, then each melee round of gathering adds 1D4 I.S.P. to it, with no maximum but too hard to control past the character''s base I.S.P.; the amount gathered is held as long as the kata continues. Held in the hand and used to strike, it is harmless to mortals, living creatures, devices, machines and robots, but against demons, disembodied entities and other creatures of supernatural evil it does 1D6 M.D. per 10 I.S.P. stored (1D6x10 M.D. at 100). (printed 40-41.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Chi Ball Lens: for 3 I.S.P., looking through the Ball shows all I.S.P., Chi-bearing creatures, dragon lines and supernatural or spiritual entities within about 60 ft (18.3 m), for as long as the character keeps looking through an intact Ball." }
      - { level: 4, text: "Meditation Advancement #1: +2 to I.Q., M.E. and M.A." }
      - { level: 5, text: "Chi Ball Defense: for 4 I.S.P. the Ball is a shield against psychic, magical, spiritual and demonic energies, with M.D.C. equal to the I.S.P. stored in it; useless against physical weapons, bullets, lasers and non-magical energy blasts." }
      - { level: 6, text: "Evoke the Chi Ball in one melee round." }
      - { level: 7, text: "Chi Ball Calm: for 2 I.S.P., +5 to save vs Horror Factor and other fear while holding the Ball." }
      - { level: 8, text: "Add 5D6+30 to the character''s Permanent I.S.P. Base." }
      - { level: 9, text: "Meditation Advancement #2: +1 to M.A. and +2 to save vs Horror Factor." }
      - { level: 10, text: "Second Chi Ball Formation: two Chi Balls can be created at once." }
      - { level: 11, text: "Chi Ball Levitation: for 10 I.S.P. the character rises with the Ball, holding it or standing on it, to a maximum height of 500 ft (152 m) per level." }
      - { level: 12, text: "Add 4D6+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Throwing the Chi Ball: for 10 I.S.P. a throw, the Ball arcs through a target and returns; against demons and creatures of supernatural evil it does 2D8 M.D. on a glancing blow and 5D10 M.D. on a solid hit, and is harmless to anything else. +2 to strike; range 100 ft (30.5 m) per level." }
      - { level: 14, text: "Meditation Advancement #3: +1 to M.E. and M.A., +2 to save vs disease and +2 to save vs Horror Factor." }
      - { level: 15, text: "Impervious to mental illusions while holding the Chi Ball, and +5 to save vs magical illusions." }
  - name: "Chi Healing"
    description: "Using internal energy alone or the Chi Ball. Laying on hands without the Chi Ball heals 2D6 S.D.C./hit points, or 1D6 M.D.C. on a superhuman creature, for 6 I.S.P. per healing per individual. Passing the Chi Ball over or through the injured or ill heals 4D6 S.D.C./hit points, or 2D6 M.D.C. (living flesh only), for 3 I.S.P. per healing per individual. Illness, infection and chronic disease: lay hands on the patient for at least 12 melee rounds (3 minutes); once the problem is identified (usually by the patient''s aura coloring) the chance of a cure is 22% +2% per level, for 30 I.S.P. per attempt per individual."
  - name: "Powers of Meditation"
    description: "From an early age the character has focused all inner strength into meditation, contemplation and sensitivity to the stirring of chi, which gives the Xian Tai Chi Chuan mystic martial arts abilities and a handful of psychic abilities. Highly skilled in Meditation."
level_progression:
  - { level: 2, grants: ["+2 to parry and dodge"] }
  - { level: 3, grants: ["+2 to strike, +2 to roll with punch/fall/impact", "+1 to save vs possession and Demonic Curses"] }
  - { level: 4, grants: ["+1 to parry and dodge, Critical Strike on a natural 19 or 20", "+1 on initiative", "+1 to save vs possession and Demonic Curses"] }
  - { level: 5, grants: ["+1 attack/action per melee round", "+1 to save vs possession and Demonic Curses"] }
  - { level: 6, grants: ["+2 to roll with punch/fall/impact, +1 to parry and dodge, +1 to disarm"] }
  - { level: 7, grants: ["+1 to strike and +2 to damage", "+1 to save vs possession and Demonic Curses"] }
  - { level: 8, grants: ["+1 attack/action per melee round", "+1 on initiative"] }
  - { level: 9, grants: ["Knockout/Stun on a natural 19 or 20", "+1 to save vs possession and Demonic Curses"] }
  - { level: 10, grants: ["+1 attack/action per melee round"] }
  - { level: 11, grants: ["+1 to strike and +2 to damage", "+1 to save vs possession and Demonic Curses"] }
  - { level: 12, grants: ["+1 to roll with punch/fall/impact, +1 to parry and dodge", "+1 on initiative"] }
  - { level: 13, grants: ["+2 to disarm, +2 to entangle, Critical Strike on a natural 17 or better", "+1 to save vs possession and Demonic Curses"] }
  - { level: 14, grants: ["+1 attack/action per melee round"] }
  - { level: 15, grants: ["+2 to strike and +4 to damage", "+1 to save vs possession and Demonic Curses"] }
restrictions:
  - "Never learns any Weapon Proficiency, nor any martial art that promotes the use of weapons."
  - "Carries no weapons, and no mechanical or electronic devices of any kind."
  - "Cybernetics: none, and will never accept any for any reason. 01-55% chance to refuse even Bio-Systems."
trackable_resources: []
extraction_notes: "Rifts World Book 25: China 2 printed 52-54 (cache p053-p055, scan, page_offset +1), read off 200 dpi renders. The section heading is Mystic Monks (printed 52), so occ_group is psychic per the China 2 brief; the class states its own S.D.C. (4D6+38), so no men_of_arms line. The book subtitles it Open Hand Martial Artist, also known as Monk of the Elder Path. XP ladder: printed 160 (cache p161), the block headed Monk: Wai Chia Wu Shih / Warrior: Chun Tzu, read off a render. Hand to hand: the class takes the combined Hand to Hand: Xian Tai Chi Chuan in place of Hand to Hand: Basic Tai Chi (printed 53). The catalog holds no row for it, so it is stored as the class''s own: its four starting attacks as combat attacks_base, every numeric bonus of its table in bonuses and at_level, and its moves and critical/knockout ranges in a special ability and level_progression. No style is granted and none is sold (hand_to_hand costs {}), because the book allows no other martial art. Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation) is granted at level 1; its later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers; BOOK-INGEST-AUDIT.md F117). Psionics: the book does not name a tier; printed 55 says most martial arts masters are Minor Psychics unless stated otherwise, so minor. Levitation is granted; three Healing and three Physical are picked. The book prints no new powers at later levels. O.C.C. bonuses (printed 53): +4 M.E., +2 M.A., +2 P.P., +1 strike, +4 pull punch, +3 save vs magic (stored as spell_magic only), +4 vs Horror Factor, +1 initiative at levels 4, 8 and 12, +1 save vs possession and Demonic Curses (curses) at levels 1, 3, 4, 5, 7, 9, 11, 13 and 15. Skills: Language: Native Chinese Speaker (95%) is Language: Native Tongue at 95 with no per-level gain; Literacy: Chinese characters (90%) is Literacy: Chinese at 90 keeping the catalog''s +5 per level; the book''s Litercy: Ancient & Classical Chinese in the Lore list is the Literacy row; Aerobic Athletics or General Athletics are both offered, General as Athletics (general). Related: Medical is two entries so the +10% reaches only Acupuncture and Chinese Herbal Medicine; Technical''s +10% to Lore and History skills is in the note, the +5% stored; Rogue names Pick Locks, an Espionage skill, so Espionage carries only Pick Locks; Gambling is both catalog Gambling rows; Pilot''s other very basic vehicles have no row. The secondary list repeats the related limits without bonuses. Equipment: herbs (tea, flavoring, emergency medicine), two sets of chopsticks, 20 cups of uncooked rice and a small neck pouch have no catalog row and are in the Lore. The silk suit is dress-clothing with its parts in the note. || 2026-10-05, MYSTIC MARTIAL ART POWER: printed 52 (cache p053), read off a render. Ability 2 (Combined Hand to Hand Martial Art, Martial Art Power, and Sense and Manipulate Chi) says the combined study gives the character the Mystic Martial Art Power Xian Tai Chi Chuan (Chi Manipulation) and, in place of Hand to Hand: Basic Tai Chi, the class''s own Hand to Hand: Xian Tai Chi Chuan table; there is no choice and no later pick. The power was a plain definition, which the sheet does not show; it now sits in a one-option choose-1 group so that it is held and its level table appears."
---

## Lore

The Wai Chia Wu Shih believe that picking up any weapon, for any reason, is weakness and a surrender to the barbarism the unjust Yama Kings brought into the world. When a fight cannot be avoided, the human body is the only weapon a civilized person should need, so these monks never learn a weapon proficiency and never study a fighting art built around arms.

They are deeply suspicious of anything new. The great innovations, rice, writing and silk, have proved themselves over thousands of years; the endless stream of gadgets that followed is, in their view, what ruined the world long before the Rifts. China fell, they say, when its temples and monasteries were destroyed and its Taoists and mystics scorned; had it stayed righteous there would be no Mist and no opening for the Yama Kings.

So the Wai Chia grumbles. Rifts China is full of new weapons from the outside world, from the Geofront and from mad Yama Kings, and the monk looks back on centuries of golden ages with little hope that the Celestial Court will ever restore them. Yet he keeps at it, determined to show by example that a single human being with nothing but bare hands can right wrongs, defeat evil and change the world.

To the Wai Chia the separation of physical martial arts, mystic martial arts and chi manipulation is blindness. The order fuses all three into one study, Immortal and Eternal, Mind and Body, and its monks are healers as much as fighters, laying hands on the sick or passing a ball of gathered chi through the wounded.

Standard equipment: sturdy traveling clothes with boots, hat and gloves and heavy winter over-garments; a suit of embroidered silk indoor clothing with slippers, robe, scarf and hat; 2D4x10 sheets of paper, solid ink and an ink block, bamboo brushes; several packages of tea and a collection of herbs for tea, cooking and emergency medicine; a tea bottle, a kettle, two sets of chopsticks (one rough, one delicate), a cooking knife and 20 cups of uncooked rice; a large shoulder bag, a belt pouch, a small neck pouch, a small mirror, 30 feet of climbing rope and two bamboo canteens of water. Never weapons, and never anything mechanical or electronic.
',
       updated_at = datetime('now')
 WHERE class_id = 'wai-chia-wu-shih'
   AND instr(markdown, 'level 1 only, levels 2-15 not imported, see BOOK-INGEST-AUDIT.md F117') > 0
   AND length(markdown) = 17086;

-- == geofront-chi-commando ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-chi-commando
name: Geofront Chi Commando
system: rifts
source_book: Rifts World Book 25: China 2 p.123-124
category: occ
tags: [combat, stealth]
occ_group: men-of-arms
xp_table: [0, 2141, 4281, 8561, 17521, 25541, 35581, 52601, 72801, 98201, 136401, 188801, 236201, 288401, 342801]
attribute_requirements: { IQ: 10, ME: 10, PS: 12, PP: 14 }
sdc_base: "6d6+40"
starting_money: "1000"
psionics:
  isp_base: "M.E. x4, +1d8 per level of experience"
  powers_starting: 0
bonuses:
  attributes: { ME: 2, PS: "1d4" }
  combat: { attacks: 1, pull_punch: 2 }
  saves: { possession: 1, horror_factor: 4 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Math: Basic (+20%) for the CS Commando; China adds Mathematics: Basic (+10%), and the higher figure is kept." }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Radio: Scramblers", base: 45, per_level: 5, note: "+10%. Printed as Radio: Scrambler." }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Printed as Language: Chinese at 95%. Stands in for the CS Commando''s American." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One language of choice (+20%), through the repeatable Language: Other row." }
    - { name: "Literacy: Chinese", base: 70, per_level: 5, note: "+15%. A Geofront addition." }
    - { name: "Bicycling", base: 54, per_level: 4, note: "Printed as Pilot: Bicycle (+10%). A Geofront addition." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Parachuting", base: 60, per_level: 5, note: "+20%" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%)." }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed as Pilot Hover Vehicle (i.e. Police Cruiser; +10%). With Motorcycle, replaces the CS Commando''s Pilot: Robots & Power Armor." }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "Printed as Motorcycle (including Cave Bike; +10%)." }
    - { name: "Recognize Weapon Quality", base: 37, per_level: 5, note: "+12%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { choose: 1, from: ["Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Replaces Hand to Hand: Commando. All advanced; pick only one. Half (50%) of Chi Commandos take Eighteen Weapons Kung Fu." }
    - { choose: 4, categories: ["Espionage", "Mechanical", "Military", "Pilot", "Wilderness"], bonus: 10, note: "MOS special training: four skills, all from ONE of Espionage, Mechanical, Military (typically demolitions and traps), Piloting or Wilderness, each at +10%. The picker cannot hold the four to a single area; keep them together." }
  occ_related_skills:
    count: 0
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Espionage", bonus: 15 }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics", "Locksmith"] }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 4 }
      - "Science"
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Same as the CS Commando. The book''s level-one related picks are the four MOS skills, which are stored as an O.C.C. skill choice because they carry their own +10% and their own category limit; these categories are for the two further picks at levels two, five, nine and twelve. Technical is printed +5%, and +10% for Literacy and Language skills; the category bonus stores the +5%. Electrical is printed as Basic only."
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 2
    schedule:
      - { level: 4, count: 2 }
      - { level: 7, count: 2 }
      - { level: 10, count: 2 }
special_abilities:
  - name: "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)"
    description: "No Sword Chi technique works without a blade the character knows and has named. Level 1: after at least 24 hours with the blade, awaken it as a personal Chi Blade with its own 2D6+8 I.S.P. (rolled once). Blade Chi Healing restores 3D6 points (1D6 M.D.C. to a mega-damage being) for 8 I.S.P.; Blade Chi Awareness warns of potential enemies within a range of less than 10 ft (3 m), through walls, floors and ceilings, for 2 I.S.P.; Blade Chi Mega-Damage turns the blade''s normal damage into M.D. against supernatural beings and M.D.C. technology (a 1D8 short sword does 1D8 M.D.). (printed 29-30.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Double the Chi Blade''s I.S.P." }
      - { level: 4, text: "The personal Chi Blade does an extra +1D6+2 M.D." }
      - { level: 5, text: "Blade Chi Resonance: the Chi Blade senses other significant weapons, above all self-aware or strongly magical ones, up to one mile (1.6 km) away, with their general direction and distance, whether they are stronger, weaker or about its equal, and whether one is wielded by great evil." }
      - { level: 6, text: "Blade Chi Power of Return: a lost or stolen Chi Blade teleports back to its owner, usually within 24 to 48 hours, arriving with just 1 I.S.P." }
      - { level: 7, text: "Awaken Other Chi Blades: a second Chi Blade can be awakened after the same 24 hours with it. 20 I.S.P. an attempt; roll under M.A. on a D20, a failed attempt may be repeated after no less than 24 hours, and a blade that fails three times is lifeless." }
      - { level: 8, text: "The personal Chi Blade does a further +1D6+2 M.D." }
      - { level: 9, text: "A second Chi Blade, if the character has one, gains all the bonuses and abilities of the first, and the two can be used as Paired Weapons." }
      - { level: 10, text: "Double the Chi Blade''s I.S.P." }
      - { level: 11, text: "A third Chi Blade can be awakened, as at level 7." }
      - { level: 12, text: "The first personal Chi Blade does an extra +10 M.D." }
      - { level: 13, text: "Personal Chi Blade Sentience: the primary blade (the first or second awakened) becomes fully aware, speaks telepathically with its wielder while held, has a 01-20% chance (rolled once) of spoken speech, and mirrors its owner''s alignment." }
      - { level: 14, text: "The Chi Blade can hide its I.S.P. and its sentience from psychics, See Aura and other ways of detecting psychic energy or emotion." }
      - { level: 15, text: "Add 6D6+6 to the primary Chi Blade''s I.S.P. and the same amount to the wielder''s I.S.P. Base." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)"
    description: "Stance bonuses apply only in that stance. Level 1: Viper Stance (thermal vision 60 ft; Fang Fingers 3D6 M.D. or 5D6 S.D.C.; no M.D.C.; six attacks a melee in all, +5 strike, +4 parry, +5 damage, +4 roll; no pulled punches); Rat Snake Stance (Knuckle Punch 2D6+10 M.D. or 3D6 S.D.C.; M.D.C. equal to P.E. +20; +1 attack, +4 strike, +3 parry, +3 roll); Art of Melting (silent movement as Prowl 60% +3% per level; escape once detected 70% +2% per level); and one Art of Invisibility, with one more at each of levels 3, 7, 10 and 13: Clouding the Mind (vanish for one melee action, 2 I.S.P. per person who looks into the character''s eyes or face, and for that moment also hidden from those who track P.P.E., I.S.P. or living spirits), Deception (silent movement, automatic while unsuspected, 60% +3% per level under inspection), Evasion (stay behind a foe and keep attacking unseen, or shadow someone for up to two melee rounds per level; automatic if the foe is unaware, otherwise 60% +3% per level; it fails if a friend of the victim can call a warning or the victim''s back is to a wall, and once sighted the character must vanish first, by Clouding the Mind or Vanishing, to resume it), Hiding (undetected unless the area is well lit and carefully inspected, then 60% +4% per level) or Vanishing (disappear from plain view, 90% +1% per level in darkness with obstructions, -25% in good light and a further -15% on clear, flat ground). (printed 34-35.)"
    progression:
      - { level: 2, text: "Knockout or stun from behind, and Critical Strike on a Natural 18 or better." }
      - { level: 3, text: "Select one more Art of Invisibility." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Chilling Touch (The Vapor): claws do 5D6 M.D. a strike; or the Chilling Touch, which uses four melee attacks, does 3D6 direct to hit points (4D6 M.D. to mega-damage creatures), turns the skin gray and shriveled, and costs the victim initiative and half his attacks for the next two melee rounds." }
      - { level: 6, text: "Spitting Python Stance: Python Jab Long Distance, one a melee, hits up to 100 ft (30.5 m) away for 4D6 M.D. or 3D6 S.D.C.; Python Jab Hand to Hand does 5D6 M.D. or 4D6 S.D.C.; a Natural 20 with either is a Death Blow. M.D.C. equal to P.E. +30. +6 strike, +3 parry, +3 damage, +3 roll with impact; no pulled punches." }
      - { level: 7, text: "Select one more Art of Invisibility." }
      - { level: 8, text: "+1 attack per melee round and +1 on initiative." }
      - { level: 9, text: "Add 4D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 10, text: "Select one more Art of Invisibility." }
      - { level: 11, text: "Cobra Stance: every strike is a paralysis attack. A victim who fails to avoid or roll with it takes no damage but the body or the targeted limb is paralyzed for 3D6 melee rounds; one who rolls with it takes 2D8 M.D. or 1D8 direct to hit points instead. M.D.C. equal to P.E. +20. Four attacks a melee in all, +5 strike, +3 parry, +3 roll with impact." }
      - { level: 12, text: "Knockout, stun or Critical Strike (the character''s choice) from behind on a Natural 17 or better." }
      - { level: 13, text: "Select one more Art of Invisibility." }
      - { level: 14, text: "Add 2D4x10+24 to the character''s Permanent I.S.P. Base." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)"
    description: "Requires the Acupuncture skill. Level 1: Healing Tien-Hsueh for 6 I.S.P. a healing, each one melee action - 4D6 hit points, 2D6+10 S.D.C. or 3D8 M.D.C. restored, or a 40% +4% per level chance to cure illness, infection, fever or coma at once, or to repair, install or remove a cybernetic device, engine or machine. Tien-Hsueh Reversal for 5 I.S.P. - undoes any Tien-Hsueh effect, or a knockout, stun, dizziness, blindness, paralysis or other temporary shock, in one melee round; against the work of a higher-level master it takes 2D6 melee rounds per level of difference. One Finger Touch - no damage, +4 to strike, the delivery for every Tien-Hsueh attack. Tien-Hsueh Powers, one chosen at each of levels 3, 6, 8, 11 and 13: Blindness (2D6 hours blind at -10 to strike, parry, dodge and other combat rolls, 2D6 melee rounds if the victim rolls with the blow, nothing if parried or dodged; 8 I.S.P.), Blood Flow (2D8 direct to hit points past S.D.C. or S.D.C. armor, 1D8 past M.D.C. armor, or 1D8 M.D. or 2D8 P.P.E. dispelled against a supernatural creature; 10 I.S.P.), Electronic (start or stop any machine, device or vehicle by touch; 10 I.S.P.), Enlightenment Strike (frees a victim within 30 ft and in line of sight from possession, Chi control or mind control, taking a full melee round; 20 I.S.P.), Neural (paralyzes a declared limb for 3D6 minutes with no roll with impact, needing an 8 or better to strike, though the victim may still parry or dodge, the defender winning ties, and an arm or foot used to parry is itself paralyzed; 8 I.S.P.), Puppet-Dance (a grip on the back of the neck and a strike roll of 10 or higher makes the victim a living puppet with two attacks a melee and no bonuses, while the master''s own bonuses are halved and his skills are -20%; 15 I.S.P. on a natural being, 20 on a lesser supernatural being, 30 on a Fox or Monkey Spirit or a dragon hatchling, 50 on most Greater Demons, Immortals, Ghosts and Entities; it does not work on adult dragons, Elementals, Demon Lords, Demigods, Godlings or deities, the victim cannot be made to speak, and while he holds the puppet the master can perform no other Tien-Hsueh and nothing that spends I.S.P. or P.P.E.), Demon Strike (leaves a supernatural M.D.C. being or lesser creature of magic with only 1D4x10% of its M.D.C.; 32 I.S.P.) or Withering Flesh (removes all natural S.D.C., or only 1D6 S.D.C. if the victim rolls with impact, never touching hit points; 12 I.S.P.). (printed 35-37.)"
    progression:
      - { level: 2, text: "Internal Practice Advancement #1: +2 to M.E. and +1 to I.Q." }
      - { level: 3, text: "Select one Tien-Hsueh Power from the list." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Penetrating Tien-Hsueh: for 12 I.S.P. the character''s Tien-Hsueh powers reach through an M.D.C. body or M.D.C. armor, which no longer acts as a barrier." }
      - { level: 6, text: "Select one more Tien-Hsueh Power." }
      - { level: 7, text: "Internal Practice Advancement #2: +2 to P.P. and +1 to M.A." }
      - { level: 8, text: "Select one more Tien-Hsueh Power." }
      - { level: 9, text: "Long-Distance Tien-Hsueh: for 24 I.S.P. any Tien-Hsueh can be projected up to 400 ft (122 m) per level at a victim the character can see (binoculars, a scope or a monitor count) or is speaking with over a phone or radio; through contact with a detached spirit or animus it reaches that being''s body at any distance." }
      - { level: 10, text: "Add 5D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Select one more Tien-Hsueh Power." }
      - { level: 12, text: "Internal Practice Advancement #3: +2 to I.Q. and +1 to M.E." }
      - { level: 13, text: "Select one more Tien-Hsueh Power." }
      - { level: 14, text: "Knockout or stun on a Natural 17 or better." }
      - { level: 15, text: "Add 1D6x10+24 to the character''s Permanent I.S.P. Base." }
  - name: "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"
    description: "Level 1: Falling Technique - no damage from a fall of 50 ft or less, 1 point per 50 ft from 51 to 400 ft, 1 point per 20 ft beyond 400 ft, and never more than 60 points (terminal velocity past 1200 ft); +1 to roll with punch or impact (other than a fall) at levels 1, 3, 4, 6, 8, 9, 11, 13 and 15. Light-Body Climbing - climb up or down at walking speed with no skill roll, carrying only basic gear and no passenger; requires the Climbing skill, which gains +10%. (printed 39-40.)"
    progression:
      - { level: 2, text: "Drunkard''s Staff: for 22 I.S.P. an ordinary staff, broomstick, pole or branch does 2D8 M.D. (2D8 S.D.C. to S.D.C. targets) and has 1D6x10 M.D.C. if attacked itself. It lasts at least one day; at the end of each 24 hours a roll under 10 on a D20 ends it, and seven saves in a row make it permanent." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+2 in all)." }
      - { level: 4, text: "Mystic Slime: for 10 I.S.P. an invisible slippery coating makes the character, his clothing, gear and weapons next to impossible to grab or hold. Falling Technique: +1 to roll with punch or impact (+3 in all)." }
      - { level: 5, text: "Neutralize Toxins: for 7 I.S.P., used mostly to drink great amounts of alcohol without being seriously affected." }
      - { level: 6, text: "Belch Toxic Vapor: for 10 I.S.P., at most twice a melee and one attack each, a belch in the face forces a save vs non-lethal poison (16 or higher). Failure: loses initiative and one attack and is -2 to strike, parry, dodge and all combat moves for 1D4 melee rounds. Success: loses one attack that round. Falling Technique: +1 to roll with punch or impact (+4 in all)." }
      - { level: 7, text: "Drunken Stranger (Qiao Zhuang): for 20 I.S.P. the character moves and looks like a different drunk and is not recognized unless seen full in the face in good light, for 24 hours per level." }
      - { level: 8, text: "Blind Drunk: for 12 I.S.P. the character blinds himself for 8 hours per level (cancelled at will) and suffers only a third of the blindness penalties (-3 to strike, parry, dodge and disarm). Falling Technique: +1 to roll with punch or impact (+5 in all)." }
      - { level: 9, text: "Drunken Style Meditation Advancement #1: +15 S.D.C., +2 to M.E. and P.P., +1 to save vs possession. Falling Technique: +1 to roll with punch or impact (+6 in all)." }
      - { level: 10, text: "Add 5D6+22 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Drunken Mind Cloak: for 6 I.S.P. per listener, up to 10 people per level, gibberish holds listeners oblivious to everything around them for as long as the character keeps talking and they are not attacked, robbed or shaken. Or, for 5 I.S.P. per person (also up to 10 people per level), up to four topics are planted in their memory for good after 2D12 melee rounds of confusion. Falling Technique: +1 to roll with punch or impact (+7 in all)." }
      - { level: 12, text: "Drunken Dragon Walk: for 10 I.S.P. the character staggers along the paths of any nearby dragon lines (ley lines) for 1D6 hours." }
      - { level: 13, text: "Inflict Mystic Drunkenness: one breath (one attack) on up to six victims at 10 I.S.P. each; a failed save vs non-lethal poison (16 or higher) leaves them drunk for 2D6 melee rounds, with Spd, skills and combat bonuses halved and -2 attacks per melee. Falling Technique: +1 to roll with punch or impact (+8 in all)." }
      - { level: 14, text: "Drunken Style Meditation Advancement #2: +2 to M.E. and M.A." }
      - { level: 15, text: "Add 1D6x10+33 to the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+9 in all)." }
  - { choose: 1, from: ["Mystic Martial Art Power: She Shen Kung Fu (Snake Style)", "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)", "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"], note: "Half (50%) of Chi Commandos take She Shen, 25% Gui Long and 20% Xian Pu." }
equipment_starting:
  - { item_id: "china-mo-fuqian-demon-skin", qty: 1, note: "Special Feature: Mo Fuqian Demon Skin graft, 4D6+18 M.D.C." }
  - { item_id: "china-shadow-armor", qty: 1, note: "M.D.C. Shadow Armor, worn as the basic uniform." }
  - { item_id: "dress-uniform", qty: 1, note: "An M.D.C. dress uniform." }
  - { choose: 1, label: "combat armor", qty: 1, from: ["china-standard-brigandine-armor", "china-heavy-brigandine-armor", "china-mo-fuqian-kai-demon-skin-armor"] }
  - { item_id: "china-ghf-ak47-hounds-fang-assault-rifle", qty: 1 }
  - { item_id: "china-chi-sniper-rifle-demons-eye", qty: 1 }
  - { choose: 1, label: "Chi Auto-Mag (Demon Claw) or handgun of choice", qty: 1, from: ["china-chi-auto-mag-demon-claw", "china-ght-85-hounds-tooth-auto-mag", "china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter"] }
  - { item_id: "ammunition-clips", qty: 18, note: "Six ammo clips for each of the three weapons." }
  - { item_id: "explosive-grenade", qty: 4 }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 2 }
  - { choose: 1, label: "vibro-knife or saber", qty: 1, from: ["vibro-knife", "vibro-saber"] }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1 }
  - { item_id: "pocket-computer", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Implant." }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Implant; printed Clock Calender." }
  - { item_id: "security-clearance-chip", qty: 1, note: "Implant; printed Security Clearance Access Chip." }
restrictions:
  - "May use the Mo Fuqian Kai Demon Skin Armor as a disguise on the surface."
  - "Also gets a conventional military vehicle of choice for daily use - motorcycle, jeep, hovercycle or similar."
  - "More weapons, gear and vehicles may be issued on assignment, and the commando may acquire, use and keep weapons, armor and items from outside the Geofront, demon-slaying and magic items included, for missions away from home."
  - "Starts at the rank of corporal or sergeant, depending on performance in training."
  - "Money is half the CS Commando''s; housing, food, medical care and every basic need are provided by the government, and the character is highly respected."
extraction_notes: "TEMPLATE CLASS: printed 123-124 says the Chi Commando is the CS Commando with additions and substitutions; its skills, related and secondary skills, equipment and money are stated as ''same as the CS Commando''. The base is production''s cs-commando (Rifts World Book 11: Coalition War Campaign p.71-72), written out here in full (a same-as class ships a full copy). No copy_of is declared: nearly every top-level key differs (pools, bonuses, attributes, skills, equipment, money, xp_table). GROUP: the Geofront Military O.C.C.s section, Regular Army (printed 121), so men-of-arms; S.D.C. 6D6+40 is printed, so no men_of_arms line. XP: the Geofront Chi Commando column of printed 160. I.S.P.: ''Permanent I.S.P. Base (Chi)'', M.E. x4 +1D8 per level, stored without a psionic tier (Chi, no powers, no psionic save). ATTRIBUTES AND BONUSES: China prints its own (I.Q. 10, M.E. 10, P.S. 12, P.P. 14; +2 M.E., +1D4 P.S., +1 attack, +2 pull punch, +1 vs possession, +4 vs Horror Factor) and they replace the CS Commando''s (which adds P.E. 12, +1 M.E. and +2D6 S.D.C.). SKILLS: China adds Mathematics: Basic +10% (the CS Commando already has +20%; the higher is kept), Language: Chinese at 95% (stands in for American; the extra language of choice stays), Literacy: Chinese +15% and Pilot: Bicycle +10% (Bicycling), and swaps Pilot: Robots & Power Armor for Pilot Hover Vehicle +10% (Hover Craft (ground)) and Motorcycle +10% (Motorcycles & Snowmobiles). The CS line about being trained in most CS power armor is dropped with that skill. HAND TO HAND: Commando is replaced by one of Eighteen Weapons, Drunken Style, Dog Boxing or Shao-lin Kung Fu (all advanced, pick only one); a choose group, costs empty. MYSTIC MARTIAL ART POWER: one of She Shen, Gui Long, Xian Pu, Tien-Hsueh or Mien-Ch''uan Kung Fu, selected once at creation (printed 123-124), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). Tien-Hsueh requires the Acupuncture skill, which this class does not grant. EQUIPMENT: China''s armor line (Shadow Armor, an M.D.C. dress uniform, and Standard or Heavy Brigandine or Demon Skin Armor) and weapons line (GHF-AK47, Demon''s Eye Chi Sniper Rifle, Chi Auto-Mag or handgun of choice, six clips each) replace the CS armor, energy rifle, sidearm, E-Clips and non-energy weapon; the handgun choice is the Geofront pistols in the catalog; the clips are stored as 18 ammunition-clips. Everything else is ''basically the same as the CS Commando'' and copied. The Mo Fuqian Demon Skin (Special Feature) and the three implants of the Cybernetics line are gear rows; China''s Cybernetics line replaces the CS ''none to start''. MONEY: the CS Commando draws 2,000 credits a month and starts with one month''s pay; half is 1,000. No racial line is printed; none is stored. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p124-p125): the paragraph starts at the foot of printed 123 and its list is at the top of printed 124: ''select one of the following: She Shen Kung Fu (Snake Style; 50% of all Commandos take this one), Gui Long Kung Fu (Dragon Blade; 25% take this one), Xian Pu Kung Fu (Drunken Style; 20% take this one), Tien-Hsueh Kung Fu (Touch Mastery), or Mien-Ch''uan Kung Fu (Cotton Fist)''. It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those five names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

The Chi Commando belongs to the Geofront''s elite strike forces. Commandos run
infiltrations, surgical strikes, sabotage, search-and-destroy and rescue
missions, often deep behind enemy lines, and they are among the few soldiers
the army trusts to go out alone or in pairs.

Like every Geofront soldier they build on a Chinese martial art and a Mystic
Martial Art Power, but the commando''s training goes further, and many carry
the army''s demon-built Chi weapons into the field. Most have the hearts of
heroes, though selfish and aberrant commandos are not rare.

## GM Notes

On assignment use the CS Commando''s notes as the template; Chi Commandos may
also keep demon-slaying and magic items they pick up on the surface.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-chi-commando'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0
   AND length(markdown) = 14696;

-- == geofront-chi-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-chi-warrior
name: Geofront Chi Warrior
system: rifts
source_book: Rifts World Book 25: China 2 p.123
category: occ
tags: [combat, beginner]
occ_group: men-of-arms
xp_table: [0, 1926, 3851, 7451, 14901, 21001, 31001, 41601, 53001, 73001, 103501, 139001, 189001, 239001, 289001]
attribute_requirements: { IQ: 7, PS: 7, PP: 7, PE: 7 }
sdc_base: "4d6+24"
starting_money: "850"
psionics:
  isp_base: "M.E. x2, +1d6 per level of experience"
  powers_starting: 0
bonuses:
  combat: { initiative: 1 }
  saves: { spell_magic: 1, possession: 2, horror_factor: 1 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Printed as Language: Chinese at 95%. Stands in for the Grunt''s Language: Native Tongue (American) at 92%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%. A Geofront addition: every soldier reads and writes." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%. A Geofront addition." }
    - { name: "Bicycling", base: 64, per_level: 4, note: "Printed as Pilot: Bicycle (+20%). A Geofront addition." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Printed as Body Building." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed as Pilot: Hovercraft (+10%)." }
    - { name: "Motorcycles & Snowmobiles", base: 65, per_level: 4, note: "Printed as Pilot Motorcycle (Cave Bike; +5%), which replaces the Grunt''s Pilot: Tank & APCs (+14%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0 }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "+10%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (Ancient or Modern)." }
    - { choose: 1, from: ["Hand to Hand: Tai-Chi Ch''uan", "Hand to Hand: Shao-Lin Kung Fu"], note: "Replaces the Grunt''s hand to hand: Tai-Chi (basic, and the standard for a character with a P.P. of 10 or less) or Shao-lin Kung Fu (advanced). No other style is offered." }
  occ_related_skills:
    count: 7
    schedule: [{ level: 2, count: 1 }, { level: 5, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy & Navigation"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Carpentry", "Hunting", "Land Navigation"] }
    note: "Same as the CS Grunt (RUE p.233): seven at level one, one more at levels 2, 5, 9 and 12. Cowboy, Espionage and Horsemanship: none. Electrical: Basic Electronics only. Mechanical: Automotive and Basic Mechanics only. Medical: First Aid only. Science: math skills and Astronomy & Navigation only. Wilderness: Carpentry, Hunting and Land Navigation only."
  secondary_skills:
    count: 5
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
special_abilities:
  - name: "Chi Weapon Charging"
    description: "Geofront soldiers, who all hold Chi through their Mystic Martial Art training, can charge Chi Demon Weapons. A Chi projectile weapon: the whole clip is charged, for 10 I.S.P. per minute (4 melee rounds) of M.D. capability, and each blast counts as one melee attack; P.P.E. can be spent instead at double the cost (20 P.P.E. a minute). A blade planted to become a Chi melee weapon does its usual damage as S.D.C. to S.D.C. foes and the same damage as M.D. plus one extra die to Mega-Damage beings, for 5 I.S.P. per minute. The weapons are bulky: anyone with a P.S. of 17 or less is -3 to strike with them. Custom holds it dishonorable to charge a weapon unless facing a Mega-Damage opponent. (printed 146)"
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - { choose: 1, from: ["Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"] }
equipment_starting:
  - { item_id: "china-mo-fuqian-demon-skin", qty: 1, note: "Special Feature: Mo Fuqian Demon Skin graft, 4D6+18 M.D.C." }
  - { item_id: "china-shadow-armor", qty: 1, note: "M.D.C. Shadow Armor, worn as the basic uniform." }
  - { item_id: "dress-uniform", qty: 1, note: "An M.D.C. dress uniform." }
  - { item_id: "china-standard-brigandine-armor", qty: 1, note: "90 M.D.C. main body; for combat operations and surface missions." }
  - { item_id: "china-ghf-ak47-hounds-fang-assault-rifle", qty: 1 }
  - { item_id: "china-ght-85-hounds-tooth-auto-mag", qty: 1 }
  - { item_id: "ammunition-clips", qty: 5, note: "Five ammo clips." }
  - { item_id: "fragmentation-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Implant." }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Implant; printed Clock Calender." }
  - { item_id: "security-clearance-chip", qty: 1, note: "Implant; printed Security Clearance Access Chip." }
restrictions:
  - "Officers also get a GHT-88 Brilliant Light Heavy Laser Pistol or a Geo-Blaster/Phased Emitter as a second sidearm; Military Police get a Phased Emitter as a second sidearm."
  - "Money is half the CS Grunt''s; housing, food, medical care and every basic need are provided by the government."
extraction_notes: "TEMPLATE CLASS: printed 123 says the Chi Warrior (Soldier/Grunt) is the CS Grunt with additions and substitutions; its skills, related and secondary skills, equipment and money are stated as ''same as the CS Grunt''. The base is the Coalition Grunt O.C.C. of Rifts Ultimate Edition p.233, written out here in full (a same-as class ships a full copy). Production''s coalition-grunt row holds no skills (it was imported from the lore pages only), so the base was read from the RUE render, not copied from that row, and no copy_of is declared: almost every key differs. GROUP: the book''s Geofront Military O.C.C.s section, Regular Army (printed 121), so men-of-arms; S.D.C. 4D6+24 is printed, so no men_of_arms line. XP: the Geofront Chi Warrior column of printed 160. I.S.P.: ''Permanent I.S.P. Base (Chi)'', M.E. x2 +1D6 per level; more Chi comes from the Mystic Martial Art Power. Stored without a psionic tier: the book calls it Chi, grants no psionic powers and gives no psionic save. BONUSES: China''s own line (+1 initiative, +1 vs magic, +2 vs possession, +1 vs Horror Factor) - the RUE Grunt prints none. SKILLS: China adds Mathematics: Basic +10%, Language: Chinese at 95%, Literacy: Chinese +20% and Pilot: Bicycle +20% (the catalog''s Bicycling), and swaps Pilot: Tank & APCs (+14%) for Pilot Motorcycle (Cave Bike; +5%), the catalog''s Motorcycles & Snowmobiles. Language: Chinese at 95% stands in for the Grunt''s American at 92%: a judgement, since the book adds Chinese without naming what it replaces. HAND TO HAND: printed ''Substitute Basic Hand to Hand with Tai-Chi or Shao-lin Kung Fu'', though the RUE Grunt prints Expert (changeable to Martial Arts or Assassin for two related skills); the substitution replaces the Grunt''s style and its upgrade sentence, so the choice is a choose group and costs is empty. MYSTIC MARTIAL ART POWER: one of Bok Pai Kung Fu (Crane Style) or Mien-Ch''uan Kung Fu (Cotton Fist), selected once at creation (printed 123), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). CHI WEAPONS: the charging rule (printed 146) is prose under Chi Weapon Charging; the melee charge is printed 5 I.S.P. a minute and the projectile charge 10. EQUIPMENT: the armor and weapons lines are China''s substitutions (Shadow Armor, an M.D.C. dress uniform stored as the dress-uniform row, Standard Brigandine, the GHF-AK47 and GHT-85, five ammo clips stored as ammunition-clips); the Weapons substitution is read as replacing the Grunt''s energy rifle, sidearm, E-Clips and non-energy weapon of choice, while the grenades, flares, knife and kit stay as ''basically the same as the CS Grunt''. The Mo Fuqian Demon Skin (Special Feature) and the three implants of the Cybernetics line are gear rows. MONEY: the RUE Grunt draws 1,700 credits a month and starts with one month''s pay; half is 850. No racial line is printed; none is stored. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p124): printed 123: ''select one of the following: Bok Pai Kung Fu (Crane Style) or Mien-Ch''uan Kung Fu (Cotton Fist)''. It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those two names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

The rank and file of the Geofront army are its Chi Warriors. They are devoted
first to guarding the hidden cities beneath the Yin Caverns and second to
driving the Yama Kings and their demons out of China, and most of them are
cheerful, idealistic people rather than hardened killers.

What sets an ordinary Geofront soldier apart from a Western grunt is training:
every recruit learns a foundation martial art and then a Mystic Martial Art
Power, the kind of discipline other armies reserve for special forces. That
training wakes the soldier''s Chi, letting bare hands strike with mega-damage
force and turning ordinary weapons into ones that can hurt a demon. Some
wonder whether soldiers like these are where the old Demon Queller legends
began.

## GM Notes

Geofront soldiers are given a Mo Fuqian demon-skin graft on entering service,
and a few basic implants. Use the CS Grunt as the template for anything the
book does not change.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-chi-warrior'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0
   AND length(markdown) = 11570;

-- == geofront-metal-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-metal-warrior
occ_group: men-of-arms
race_restrictions:
  only: ["none"]
  note: "The entry prints no racial line. The Geofront military is the army of a human nation, and the base class (the Coalition SAMAS Pilot, RUE p.233) is human only; in Rifts a human character takes no R.C.C., so \"none\" is the human case."
name: Geofront Metal Warrior
system: rifts
source_book: Rifts World Book 25: China 2 p.134-135
category: occ
tags: [combat, pilot]
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 94401, 129601, 179801, 230001, 280201, 332401]
attribute_requirements:
  IQ: 10
  PP: 10
sdc_base: "4d6+20"
starting_money: "1000"
psionics:
  isp_base: "M.E. attribute number x2, +1d8 per level of experience"
  powers_starting: 0
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Printed as Language: Chinese at 95%; it takes the place of the base''s American at 94%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%; this book''s figure, in place of the base''s +10%." }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Automobile", base: 75, per_level: 2, note: "Printed as Pilot: Automobile (+15%)." }
    - { name: "Hover Craft (ground)", base: 65, per_level: 5, note: "Printed as Pilot: Hovercraft (+15%)." }
    - { name: "Robots & Power Armor", base: 76, per_level: 3, note: "+20%; this book''s figure, in place of the base''s +15%." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0, note: "All other types." }
    - { name: "Robot Combat Elite", base: 0, per_level: 0, note: "Printed as Pilot: Robot Combat: Elite: Black Tiger & Red Falcon, in place of the base''s Robot Combat Elite: SAMAS. The catalog has no row for either Geofront suit, so the generic row is granted and the two types are recorded on the sheet." }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "Printed as Read & Operate Sensory Equipment (+20%); this book''s figure, in place of the base''s +15%." }
    - { name: "Weapon Systems", base: 55, per_level: 5, note: "+15%" }
    - { name: "Navigation", base: 60, per_level: 5, note: "+20%" }
    - { name: "Bicycling", base: 54, per_level: 4, note: "Printed as Pilot: Bicycle (+10%)." }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hover Craft (ground)"], bonus: 5, note: "Printed as Pilot: Motorcycle (+5%) or Hover Vehicles (includes the Police Cruiser, +5%). Hover Craft (ground) is already granted at +15%, so a player who picks it gains nothing; the motorcycle is the useful pick." }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice (Ancient or Modern)." }
    - { choose: 1, from: ["Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Substituted for the base''s Hand to Hand: Expert; both are advanced styles. Pick one." }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: -5 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Mechanical", only: ["Aircraft Mechanics", "Automotive Mechanics", "Basic Mechanics"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 15 }
      - { name: "Pilot Related", bonus: 10 }
      - { name: "Rogue", only: ["Streetwise"] }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy & Navigation"] }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation", "Hunting", "Wilderness Survival"] }
    note: "Seven at level one (this book: seven instead of the Elite RPA Pilot''s ten), two more at levels 3, 6, 9 and 12. Communications: Any (+10%). Cowboy: None. Domestic: Any (-5% penalty). Electrical: Basic Electronics only (+5%). Espionage: None. Horsemanship: None. Mechanical: Aircraft, Automotive and Basic only (+10%). Medical: First Aid only. Military: Any (+10%). Physical: Any, except Acrobatics. Pilot: Any (+15%). Pilot Related: Any (+10%). Rogue: Streetwise only. Science: Math and Astronomy & Navigation skills only. Technical: Any. W.P.: Any. Wilderness: Land Navigation, Hunting and Wilderness Survival only."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 5
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
equipment_starting:
  - { item_id: "china-mo-fuqian-demon-skin", qty: 1, note: "Special Feature: Mo Fuqian Demon Skin (4D6+18 M.D.C.), grafted onto every Geofront soldier." }
  - { item_id: "china-shadow-armor", qty: 1, note: "M.D.C. Shadow Armor as a basic uniform." }
  - { item_id: "dress-uniform", qty: 1, note: "An M.D.C. dress uniform." }
  - { item_id: "china-standard-brigandine-armor", qty: 1, note: "For combat operations and missions on the surface (90 M.D.C. main body)." }
  - { item_id: "china-ghf-ak47-hounds-fang-assault-rifle", qty: 1 }
  - { item_id: "china-ght-85-hounds-tooth-auto-mag", qty: 1 }
  - { item_id: "magazine-clips", qty: 8, note: "Four ammo clips for each of the two weapons." }
  - { item_id: "fragmentation-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "conventional military vehicle for daily use", qty: 1, from: ["hovercycle", "jeep"] }
special_abilities:
  - name: "Mo Fuqian: Demon Skin"
    description: "Special Feature: an artificial M.D. skin graft with 4D6+18 M.D.C. that heals quickly (see the gear row)."
  - { choose: 1, from: ["Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"] }
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
restrictions:
  - "Issued Black Tiger and Red Falcon power armor (only one can be used at a time). Both are Geofront machines in the vehicles catalog, not gear, and are not in equipment_starting."
  - "Cybernetics: Gyro-Compass, Clock Calendar and Security Clearance Access Chip."
  - "Specializes in piloting all Geofront power armor (the Black Tiger and Red Falcon included) and robot vehicles (the Gun Dragon included). Rank typically starts at Corporal."
level_progression:
  - { level: 3, grants: ["+2 O.C.C. Related Skills"] }
  - { level: 4, grants: ["+1 Secondary Skill"] }
  - { level: 6, grants: ["+2 O.C.C. Related Skills"] }
  - { level: 8, grants: ["+1 Secondary Skill"] }
  - { level: 9, grants: ["+2 O.C.C. Related Skills"] }
  - { level: 12, grants: ["+2 O.C.C. Related Skills", "+1 Secondary Skill"] }
  - { level: 15, grants: ["+1 Secondary Skill"] }
extraction_notes: "DECLARED COPY: printed 134-135 calls the Metal Warrior the equivalent of the CS Elite RPA SAMAS Pilot of the Rifts RPG, with O.C.C. Skills the same as the CS RPA Pilot and related skills, secondary skills and equipment the same as the CS Elite RPA Pilot, each with changes. The class meant is the Rifts RPG''s Coalition SAMAS Pilot (Elite Robot & Power Armor Pilot), which production holds as coalition-samas-pilot (RUE p.233-235), NOT cs-rpa-fly-boy-ace (Coalition War Campaign''s aircraft-focused Ace, a different class). This is a full copy of that class with the printed changes applied, transcribed against a render of RUE printed 233-235 rather than production''s row, because production''s coalition-samas-pilot disagrees with its page: it states I.Q. 12, M.E. 12, P.E. 10 (the next class''s, the Military Specialist; the SAMAS Pilot prints I.Q. 10, P.P. 10), it files the Pilot, Pilot Related, Rogue, Science, Technical, W.P. and Wilderness related-skill lines as O.C.C. skill picks, it drops the Mechanical and Medical related lines, it has no secondary skills, and it issues three smoke grenades the page does not print. No copy_of is declared. GROUP: the book''s Elite Geofront Forces section (printed 128), so men-of-arms. SKILLS: Language: Chinese at 95% replaces American at 94%; Mathematics: Basic +20% (base +10%), Robots & Power Armor +20% (base +15%) and Read & Operate Sensory Equipment +20% (base +15%) take this book''s figures; Literacy: Chinese (+20%), Pilot: Bicycle (+10%), Navigation (+20%) and Pilot: Motorcycle or Hover Vehicles (+5%) are added; Robot Combat Basic is kept for all other types and Robot Combat Elite becomes the Black Tiger and Red Falcon. The book adds \"plus the usual MOS and other skills for an Elite RPA Pilot\", but the RUE SAMAS Pilot prints no MOS, so none is stored. HAND TO HAND: Expert substituted by a pick of Monkey Style or Shao-Lin; the base''s Martial Arts or Assassin upgrade is not carried, since the substitution replaces the style it priced, so costs is empty. RELATED AND SECONDARY: this book says seven related instead of ten and five secondary instead of eight; RUE prints eight and four, so the book is reading an earlier printing. The book''s own seven and five are stored, with RUE''s schedules (+2 related at 3, 6, 9, 12; +1 secondary at 4, 8, 12, 15). MYSTIC MARTIAL ART POWER: Bok Pai or Mien-Ch''uan, selected once at creation (printed 135), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). I.S.P.: M.E. x2 +1D8 per level is the Chi pool; additional Chi from the Mystic Martial Art Power is in that power''s text. EQUIPMENT: the base''s list with the printed substitutions - Shadow Armor, an M.D.C. dress uniform and Standard Brigandine Armor in place of the Dead Boy armor; the GHF-AK47 and GHT-85 with four clips each in place of the energy rifle, sidearm, E-clips and non-energy weapon; the Black Tiger and Red Falcon in place of the SAMAS, as a restriction line because they are vehicle rows. MONEY: half that of the CS character, whose monthly salary is 2,000 credits and who starts with one month''s pay, so 1,000 credits is stored; basic needs are provided by the government. S.D.C. 4D6+20 is stored as sdc_base. ALIGNMENT: any, mostly good and selfish. XP: the Goblin Wrangler, Metal Warrior and Whack Job Scientist ladder, printed 160, read off a render. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p136): printed 135: ''select one of the following: Bok Pai Kung Fu (Crane Style) or Mien-Ch''uan Kung Fu (Cotton Fist)''. It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those two names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

Metal Warriors pilot the Geofront''s power armor and robots, from the Black
Tiger and Red Falcon suits to the Gun Dragon. They are respected and highly
trained, yet few have fought: the Geofront keeps its armored legions hidden,
and only a small fraction have taken a suit to the surface. Some have fought
in robots in the Yin Caverns, and most have seen the surface on foot.

Their kung fu is a foundation; each also learns one Mystic Martial Art Power,
the Crane Style or the Cotton Fist.

## GM Notes

Outside China every Chi-based power weakens (printed 141): the Chi pool, the
Chi a character can draw on, and the range, duration and damage of Chi powers
are halved, M.D.C. from a Mystic Martial Art Power drops by 30%, combat bonuses
from those powers drop by one, and characters above sixth level lose one attack
per melee. None of this is stored.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-metal-warrior'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported (BOOK-INGEST-AUDIT.md F117).') > 0
   AND length(markdown) = 13050;

-- == geofront-military-specialist ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-military-specialist
name: Geofront Military Specialist
system: rifts
source_book: Rifts World Book 25: China 2 p.124
category: occ
tags: [stealth, leader]
occ_group: men-of-arms
xp_table: [0, 2121, 4241, 8481, 17001, 24901, 36301, 52601, 72901, 96001, 132301, 181601, 232901, 282301, 334601]
attribute_requirements: { IQ: 12, ME: 12, PE: 10 }
sdc_base: "5d6+25"
starting_money: "1100"
psionics:
  isp_base: "M.E. x4, +1d8 per level of experience"
  powers_starting: 0
bonuses:
  combat: { pull_punch: 2 }
  saves: { possession: 2 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Printed as Language: Chinese at 95%. Stands in for the CS Military Specialist''s Language: Native Tongue (American) at 98%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%. Stands in for the CS Military Specialist''s Literacy: Native Language (+10%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Math: Basic (+20%) for the CS Military Specialist; China adds Mathematics: Basic (+10%), and the higher figure is kept." }
    - { name: "Bicycling", base: 54, per_level: 4, note: "Printed as Pilot: Bicycle (+10%). A Geofront addition." }
    - { name: "Computer Operation", base: 55, per_level: 5, note: "+15%" }
    - { name: "Electronic Countermeasures", base: 50, per_level: 5, note: "+20%" }
    - { name: "Intelligence", base: 52, per_level: 4, note: "+20%. The CS Military Specialist has Intelligence (+10%); China adds it at +20%, and the higher figure is kept." }
    - { name: "Automobile", base: 75, per_level: 2, note: "Printed as Pilot: Automobile (+15%)." }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed as Pilot: Hovercraft (+10%); China repeats it as Pilot Hover Craft/Vehicle, which includes the Police Cruiser (+10%)." }
    - { name: "Robots & Power Armor", base: 66, per_level: 3, note: "Printed as Pilot: Robots & Power Armor (+10%)." }
    - { name: "Robot Combat: Basic", base: 0, per_level: 0, note: "Printed as Pilot: Robot Combat: Basic." }
    - { name: "Robot Combat Elite", base: 0, per_level: 0, note: "Printed as Robot Combat Elite: Black Tiger & Red Falcon Power Armors, the Geofront''s own suits. A Geofront addition." }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "Dickering", base: 30, per_level: 4, note: "+10%. A Geofront addition." }
    - { name: "Disguise", base: 45, per_level: 5, note: "+20%. A Geofront addition." }
    - { name: "Interrogation Techniques", base: 55, per_level: 5, note: "+15%. A Geofront addition." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three of choice (Ancient or Modern)." }
    - { choose: 1, from: ["Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Replaces the CS Military Specialist''s Hand to Hand: Expert (and its offer of Martial Arts or Assassin for one related skill, or Commando for two). All advanced; pick only one." }
  occ_related_skills:
    count: 9
    minimums:
      - { count: 5, category: "Espionage" }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Espionage", bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: General"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"], bonus: 5 }
      - { name: "Medical", only: ["Paramedic"] }
      - { name: "Military", bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Chemistry"], bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "China: ''same as the CS Military Specialist, but select 9, not 12, additional skills''. The RUE base selects five Espionage skills and five others at level one; the five-Espionage floor is kept inside the nine. Two more at levels 3, 6, 9 and 12, one of which must always be Espionage or Military (not enforced). Cowboy: none. Electrical: Basic Electronics only. Horsemanship: General only. Mechanical: Automotive and Basic Mechanics only. Medical: Paramedic only. Science: math skills and Chemistry only."
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
special_abilities:
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)"
    description: "Requires the Acupuncture skill. Level 1: Healing Tien-Hsueh for 6 I.S.P. a healing, each one melee action - 4D6 hit points, 2D6+10 S.D.C. or 3D8 M.D.C. restored, or a 40% +4% per level chance to cure illness, infection, fever or coma at once, or to repair, install or remove a cybernetic device, engine or machine. Tien-Hsueh Reversal for 5 I.S.P. - undoes any Tien-Hsueh effect, or a knockout, stun, dizziness, blindness, paralysis or other temporary shock, in one melee round; against the work of a higher-level master it takes 2D6 melee rounds per level of difference. One Finger Touch - no damage, +4 to strike, the delivery for every Tien-Hsueh attack. Tien-Hsueh Powers, one chosen at each of levels 3, 6, 8, 11 and 13: Blindness (2D6 hours blind at -10 to strike, parry, dodge and other combat rolls, 2D6 melee rounds if the victim rolls with the blow, nothing if parried or dodged; 8 I.S.P.), Blood Flow (2D8 direct to hit points past S.D.C. or S.D.C. armor, 1D8 past M.D.C. armor, or 1D8 M.D. or 2D8 P.P.E. dispelled against a supernatural creature; 10 I.S.P.), Electronic (start or stop any machine, device or vehicle by touch; 10 I.S.P.), Enlightenment Strike (frees a victim within 30 ft and in line of sight from possession, Chi control or mind control, taking a full melee round; 20 I.S.P.), Neural (paralyzes a declared limb for 3D6 minutes with no roll with impact, needing an 8 or better to strike, though the victim may still parry or dodge, the defender winning ties, and an arm or foot used to parry is itself paralyzed; 8 I.S.P.), Puppet-Dance (a grip on the back of the neck and a strike roll of 10 or higher makes the victim a living puppet with two attacks a melee and no bonuses, while the master''s own bonuses are halved and his skills are -20%; 15 I.S.P. on a natural being, 20 on a lesser supernatural being, 30 on a Fox or Monkey Spirit or a dragon hatchling, 50 on most Greater Demons, Immortals, Ghosts and Entities; it does not work on adult dragons, Elementals, Demon Lords, Demigods, Godlings or deities, the victim cannot be made to speak, and while he holds the puppet the master can perform no other Tien-Hsueh and nothing that spends I.S.P. or P.P.E.), Demon Strike (leaves a supernatural M.D.C. being or lesser creature of magic with only 1D4x10% of its M.D.C.; 32 I.S.P.) or Withering Flesh (removes all natural S.D.C., or only 1D6 S.D.C. if the victim rolls with impact, never touching hit points; 12 I.S.P.). (printed 35-37.)"
    progression:
      - { level: 2, text: "Internal Practice Advancement #1: +2 to M.E. and +1 to I.Q." }
      - { level: 3, text: "Select one Tien-Hsueh Power from the list." }
      - { level: 4, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 5, text: "Penetrating Tien-Hsueh: for 12 I.S.P. the character''s Tien-Hsueh powers reach through an M.D.C. body or M.D.C. armor, which no longer acts as a barrier." }
      - { level: 6, text: "Select one more Tien-Hsueh Power." }
      - { level: 7, text: "Internal Practice Advancement #2: +2 to P.P. and +1 to M.A." }
      - { level: 8, text: "Select one more Tien-Hsueh Power." }
      - { level: 9, text: "Long-Distance Tien-Hsueh: for 24 I.S.P. any Tien-Hsueh can be projected up to 400 ft (122 m) per level at a victim the character can see (binoculars, a scope or a monitor count) or is speaking with over a phone or radio; through contact with a detached spirit or animus it reaches that being''s body at any distance." }
      - { level: 10, text: "Add 5D6+12 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Select one more Tien-Hsueh Power." }
      - { level: 12, text: "Internal Practice Advancement #3: +2 to I.Q. and +1 to M.E." }
      - { level: 13, text: "Select one more Tien-Hsueh Power." }
      - { level: 14, text: "Knockout or stun on a Natural 17 or better." }
      - { level: 15, text: "Add 1D6x10+24 to the character''s Permanent I.S.P. Base." }
  - name: "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"
    description: "Level 1: Falling Technique - no damage from a fall of 50 ft or less, 1 point per 50 ft from 51 to 400 ft, 1 point per 20 ft beyond 400 ft, and never more than 60 points (terminal velocity past 1200 ft); +1 to roll with punch or impact (other than a fall) at levels 1, 3, 4, 6, 8, 9, 11, 13 and 15. Light-Body Climbing - climb up or down at walking speed with no skill roll, carrying only basic gear and no passenger; requires the Climbing skill, which gains +10%. (printed 39-40.)"
    progression:
      - { level: 2, text: "Drunkard''s Staff: for 22 I.S.P. an ordinary staff, broomstick, pole or branch does 2D8 M.D. (2D8 S.D.C. to S.D.C. targets) and has 1D6x10 M.D.C. if attacked itself. It lasts at least one day; at the end of each 24 hours a roll under 10 on a D20 ends it, and seven saves in a row make it permanent." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+2 in all)." }
      - { level: 4, text: "Mystic Slime: for 10 I.S.P. an invisible slippery coating makes the character, his clothing, gear and weapons next to impossible to grab or hold. Falling Technique: +1 to roll with punch or impact (+3 in all)." }
      - { level: 5, text: "Neutralize Toxins: for 7 I.S.P., used mostly to drink great amounts of alcohol without being seriously affected." }
      - { level: 6, text: "Belch Toxic Vapor: for 10 I.S.P., at most twice a melee and one attack each, a belch in the face forces a save vs non-lethal poison (16 or higher). Failure: loses initiative and one attack and is -2 to strike, parry, dodge and all combat moves for 1D4 melee rounds. Success: loses one attack that round. Falling Technique: +1 to roll with punch or impact (+4 in all)." }
      - { level: 7, text: "Drunken Stranger (Qiao Zhuang): for 20 I.S.P. the character moves and looks like a different drunk and is not recognized unless seen full in the face in good light, for 24 hours per level." }
      - { level: 8, text: "Blind Drunk: for 12 I.S.P. the character blinds himself for 8 hours per level (cancelled at will) and suffers only a third of the blindness penalties (-3 to strike, parry, dodge and disarm). Falling Technique: +1 to roll with punch or impact (+5 in all)." }
      - { level: 9, text: "Drunken Style Meditation Advancement #1: +15 S.D.C., +2 to M.E. and P.P., +1 to save vs possession. Falling Technique: +1 to roll with punch or impact (+6 in all)." }
      - { level: 10, text: "Add 5D6+22 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Drunken Mind Cloak: for 6 I.S.P. per listener, up to 10 people per level, gibberish holds listeners oblivious to everything around them for as long as the character keeps talking and they are not attacked, robbed or shaken. Or, for 5 I.S.P. per person (also up to 10 people per level), up to four topics are planted in their memory for good after 2D12 melee rounds of confusion. Falling Technique: +1 to roll with punch or impact (+7 in all)." }
      - { level: 12, text: "Drunken Dragon Walk: for 10 I.S.P. the character staggers along the paths of any nearby dragon lines (ley lines) for 1D6 hours." }
      - { level: 13, text: "Inflict Mystic Drunkenness: one breath (one attack) on up to six victims at 10 I.S.P. each; a failed save vs non-lethal poison (16 or higher) leaves them drunk for 2D6 melee rounds, with Spd, skills and combat bonuses halved and -2 attacks per melee. Falling Technique: +1 to roll with punch or impact (+8 in all)." }
      - { level: 14, text: "Drunken Style Meditation Advancement #2: +2 to M.E. and M.A." }
      - { level: 15, text: "Add 1D6x10+33 to the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+9 in all)." }
  - { choose: 1, from: ["Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)", "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)"], note: "Forty percent of Military Specialists take Xian Pu." }
equipment_starting:
  - { item_id: "china-mo-fuqian-demon-skin", qty: 1, note: "Special Feature: Mo Fuqian Demon Skin graft, 4D6+18 M.D.C." }
  - { item_id: "china-shadow-armor", qty: 1, note: "M.D.C. Shadow Armor, worn as the basic uniform." }
  - { item_id: "dress-uniform", qty: 1, note: "An M.D.C. dress uniform." }
  - { item_id: "china-standard-brigandine-armor", qty: 1, note: "90 M.D.C. main body; for combat operations and surface missions." }
  - { item_id: "china-chi-sniper-rifle-demons-eye", qty: 1 }
  - { item_id: "china-ghf-ak47-hounds-fang-assault-rifle", qty: 1, note: "A rifle of choice; the Hound''s Fang is the Geofront''s standard rifle and the only other one in the catalog." }
  - { choose: 1, label: "handgun of choice (may be a Chi weapon)", qty: 1, from: ["china-ght-85-hounds-tooth-auto-mag", "china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter", "china-chi-auto-mag-demon-claw", "china-chi-energy-pistol-demons-fury"] }
  - { item_id: "ammunition-clips", qty: 18, note: "Six ammo clips for each of the three weapons." }
  - { item_id: "vibro-knife", qty: 1 }
  - { item_id: "explosive-grenade", qty: 4, note: "Printed as four high explosive grenades." }
  - { item_id: "smoke-grenade", qty: 2 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "binoculars", qty: 1, note: "Distancing binoculars." }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1, note: "Robot medical kit." }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1, note: "Disc recorder." }
  - { item_id: "pocket-computer", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "combat-boots", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Implant." }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Implant; printed Clock Calender." }
  - { item_id: "security-clearance-chip", qty: 1, note: "Implant; printed Security Clearance Access Chip." }
restrictions:
  - "Always an officer: starts at the rank of Lieutenant even at first level."
  - "May also be assigned Heavy Brigandine Armor, Demon Skin Armor and power armor, and more weapons, gear and vehicles on assignment."
  - "Also gets a conventional military vehicle of choice for daily use (motorcycle, jeep, hovercycle or similar) and a robot vehicle for field use only."
  - "May use the Mo Fuqian Kai Demon Skin Armor as a disguise on the surface."
  - "Money is half the CS Military Specialist''s; housing, food, medical care and every basic need are provided by the government, and the character is highly respected."
extraction_notes: "TEMPLATE CLASS: printed 124 says the Geofront Military Specialist is the CS Military Specialist with additions and substitutions; its skills, related and secondary skills, equipment and money are stated as ''same as the CS Military Specialist''. The CS Military Specialist is NOT in production (it was never imported); the base is the Coalition Military Specialist O.C.C. of Rifts Ultimate Edition p.235-236 (cache p238-p239), read from renders and written out here in full. The CS class itself was not imported when this was written; it has been since 2026-10-04 as coalition-military-specialist. No copy_of is declared here: this class was written out in full before that row existed, and the two have not been compared line by line. GROUP: the Geofront Military O.C.C.s section, Regular Army (printed 121), so men-of-arms; S.D.C. 5D6+25 is printed, so no men_of_arms line. XP: the Geofront Military Specialist column of printed 160 (shared with the Technical Officer and the Geo-Borgs). I.S.P.: ''Permanent I.S.P. Base (Chi)'', M.E. x4 +1D8 per level, stored without a psionic tier (Chi, no powers, no psionic save). ATTRIBUTES: China prints the same minimums as RUE (I.Q. 12, M.E. 12, P.E. 10). BONUSES: China''s own, +2 pull punch and +2 vs possession; RUE prints none. SKILLS: RUE''s list with China''s additions: Mathematics: Basic +10% (RUE already +20%, kept), Language: Chinese at 95% and Literacy: Chinese +20% in place of American and Literacy: Native Language, Pilot: Bicycle +10% (Bicycling), Robot Combat Elite: Black Tiger & Red Falcon Power Armors (no machine-specific row exists, so the generic Robot Combat Elite row with the names in the note), Dickering +10%, Disguise +20%, Intelligence +20% (RUE has +10%; the higher is kept), Interrogation Techniques +15%, and Pilot Hover Craft/Vehicle +10% (RUE''s Pilot: Hovercraft +10%, the same row). HAND TO HAND: printed ''Substitute Expert Hand to Hand with Drunken Style, Monkey Style or Shao-lin Kung Fu (all advanced; only pick one)''; a choose group, costs empty. RELATED SKILLS: China says 9, ''not 12''; RUE prints five Espionage plus five other, so the 12 China refers to is from a printing not checked here (possibly Coalition War Campaign). Stored as nine with RUE''s five-Espionage floor and RUE''s categories and schedule. MYSTIC MARTIAL ART POWER: one of Xian Pu, Bok Pai or Tien-Hsueh Kung Fu, selected once at creation (printed 124), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). Tien-Hsueh requires the Acupuncture skill, which this class does not grant. EQUIPMENT: China''s armor line (Shadow Armor, M.D.C. dress uniform, Standard Brigandine) and weapons line (Demon''s Eye Chi Sniper Rifle, a rifle of choice, a handgun of choice which may be a Chi weapon, six clips each) replace RUE''s Dead Boy armor, ''one weapon for every W.P.'', the E-Clips and the non-energy weapon; the rifle of choice is stored as the GHF-AK47 (the catalog''s only other Geofront rifle besides the Demon''s Eye), the handgun choice is the Geofront pistols and Chi pistols in the catalog, the clips 18 ammunition-clips. The rest of RUE''s standard equipment is ''basically the same'' and copied. RUE''s Spider-Skull Walker for field use is written as a robot vehicle in restrictions. The Mo Fuqian Demon Skin (Special Feature) and the three implants of China''s Cybernetics line are gear rows; that line replaces RUE''s 1D4 implants plus a bionic limb. The Mo Fuqian Kai disguise sentence is printed under this class''s Special Feature. MONEY: RUE prints 2,200 credits a month, starting with one month''s pay; half is 1,100. No racial line is printed by China; RUE''s ''Human'' is the Coalition''s bar and is not stored. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p125): printed 124: ''select one of the following: Xian Pu Kung Fu (Drunken Style; 40% take this one), Bok Pai Kung Fu (Crane Style), or Tien-Hsueh Kung Fu (Touch Mastery)''. It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those three names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

The Geofront Military Specialist is military intelligence, and always an
officer: even a first-level specialist holds the rank of lieutenant. These
soldiers gather information, run espionage operations and scout enemy ground,
and like the commandos they are trusted to work alone or in pairs.

Their training mixes the spy''s craft with the Geofront''s martial disciplines,
and they field the army''s Black Tiger and Red Falcon power armor when a job
calls for it.

## GM Notes

Use the Coalition Military Specialist of Rifts Ultimate Edition as the
template for anything the book does not change.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-military-specialist'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0
   AND length(markdown) = 13768;

-- == geofront-scout-ranger ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-scout-ranger
name: Geofront Scout/Ranger
system: rifts
source_book: Rifts World Book 25: China 2 p.124-125
category: occ
tags: [wilderness, stealth, combat]
occ_group: men-of-arms
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
attribute_requirements: { IQ: 10, PS: 10, PE: 12 }
sdc_base: "5d6+30"
starting_money: "850"
psionics:
  isp_base: "M.E. x3, +1d8 per level of experience"
  powers_starting: 0
bonuses:
  attributes: { ME: 1, PE: 2, Spd: "1d10" }
  saves: { horror_factor: 2, toxins_poisons: 1 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 97, per_level: 0, note: "Printed as Language: Chinese at 97%. Stands in for the CS Ranger''s American at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 25, note: "One additional language of choice (+25%)." }
    - { name: "Literacy: Chinese", base: 70, per_level: 5, note: "+15%. A Geofront addition." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%. A Geofront addition." }
    - { name: "Bicycling", base: 64, per_level: 4, note: "Printed as Pilot: Bicycle (+20%). A Geofront addition." }
    - { name: "Intelligence", base: 52, per_level: 4, note: "+20%. A Geofront addition." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "+20%. A Geofront addition." }
    - { name: "Navigation", base: 55, per_level: 5, note: "+15%. A Geofront addition." }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "Printed as Pilot: Motorcycle (+10%). A Geofront addition." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "A Geofront addition: a vehicle of choice (+10%)." }
    - { name: "Surveillance", base: 45, per_level: 5, note: "Printed as Surveillance Systems (& Tailing; +15%). A Geofront addition." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "Printed as (10%) with no plus sign, read as +10% like the rest of the list." }
    - { name: "Camouflage", base: 30, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 55, per_level: 5, note: "Printed as Climb (+15%)." }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "Printed as Identify Plants (20%) with no plus sign, read as +20%." }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "Printed as Track Animals (+10%)." }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "Printed as Track Humanoids (+15%)." }
    - { name: "Trap Construction", base: 35, per_level: 4, note: "+15%" }
    - { name: "Trap/Mine Detection", base: 30, per_level: 5, note: "Printed as (10%) with no plus sign, read as +10%." }
    - { choose: 1, categories: ["Pilot"], bonus: 15, note: "Pilot: one of choice (+15%)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["Hand to Hand: Tai-Chi Ch''uan", "Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Shao-Lin Kung Fu"], note: "Replaces the CS Ranger''s Hand to Hand: Basic and its upgrade offer: Tai-Chi (basic, and the standard for a character with a P.P. of 10 or less), Drunken Style or Shao-lin Kung Fu." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - { name: "Military", bonus: 10, except: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater"] }
      - { name: "Physical", except: ["Acrobatics", "Wrestling"] }
      - { name: "Pilot", bonus: 5, except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Jet Fighters", "Military: Combat Helicopter"] }
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 15 }
    note: "Five other skills instead of the CS Ranger''s seven; the same categories and later picks. Electrical: None. Mechanical: None. Military excludes every demolitions skill. Pilot excludes robots, power armor and combat aircraft."
  secondary_skills:
    count: 4
    note: "Four instead of the CS Ranger''s six."
special_abilities:
  - name: "Mystic Martial Art Power: Ba Gua Kung Fu (Eight Trigrams)"
    description: "Level 1: Walk the Circle for four full melee rounds to create a Ba Gua Map, always six feet (1.8 m) across, holding as many I.S.P. as the character invests (at least 4; masters put in 200-600) and never added to afterwards. Standing on it the maker is aware of every attack and approach from every direction and may parry or dodge them all: +4 initiative, +2 parry, +4 dodge, never surprised from behind, at range or by the unseen. Stepping off, even by a toe, unravels it at 100 I.S.P. a melee round until he steps back on. Tap Map I.S.P.: the maker draws on the Map''s I.S.P. to fuel powers or refill his own; it works while 1 I.S.P. remains and he stands on it, conscious. The Map has 1 M.D.C. per I.S.P. stored, harmed only by magical, psionic or mystical attacks aimed at the Map itself. P.P.E. Absorption: made at a dragon line, nexus or other P.P.E. source, the Map turns P.P.E. into I.S.P. one for one for the maker''s use, up to ten times his Permanent I.S.P. Base; this I.S.P. adds nothing to the Map''s M.D.C. Others on the Map get none of its bonuses. (printed 25-28.)"
    progression:
      - { level: 2, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 3, text: "Eight Pillars of Darkness: 4 I.S.P. to raise and 1 I.S.P. a melee round, and the maker gives up one attack a melee while it lasts. A black column 10 ft (3 m) +2 ft (0.6 m) per level high hides everything on the Map, its I.S.P. and P.P.E. included, from sight, optics, sensors, magic and psionic sensing. The maker and his allies see out normally; enemies and the uninvited inside it fight blind (-10 to strike, parry, dodge and disarm)." }
      - { level: 4, text: "Weave the Ba Gua Map in two melee rounds." }
      - { level: 5, text: "Map Illusions: for 4 I.S.P. a melee round, anyone stepping on the Map other than its maker or another Ba Gua Master enters whatever place the maker imagines and can be led, held or turned about in it as in a maze. No saving throw. The illusions cannot harm or kill, and they end when the Map runs out of I.S.P., is destroyed, or the maker offers a way out." }
      - { level: 6, text: "Map I.S.P.: a bonus 100 I.S.P. that can only be placed into the Map as it is created; once stored it can be drawn on for other abilities." }
      - { level: 7, text: "Map Voice: for 1 I.S.P. a melee round the maker speaks to anyone caught in the illusion, at any volume from a whisper to the voice of a god, and listens in on one place on the Map at a time." }
      - { level: 8, text: "Weave the Ba Gua Map in one melee round." }
      - { level: 9, text: "Map Mystical Defense: for 5 I.S.P. a melee round every magical or psionic attack (anything powered by I.S.P. or P.P.E.) dissipates before it reaches anyone on the Map, and supernatural creatures and creatures of magic cannot enter or reach into it. Physical attacks, bullets and energy beams are not stopped. It cannot run together with an Illusion or the Pillars of Darkness." }
      - { level: 10, text: "Combat in the Illusion: for 4 I.S.P. a melee round the maker appears inside his illusion to fight those in it one on one; the damage dealt and taken is real, and it is the only way they can find and attack him." }
      - { level: 11, text: "Charm of Memory: one Map Illusion is woven into the Map as the default every time a Map is made; 3 I.S.P. is drained from the Map''s reserve for each intruder who enters it." }
      - { level: 12, text: "Zone of Destruction: for 20 I.S.P. a melee round, whoever or whatever tries to enter the Map takes M.D. equal to 10% of the I.S.P. then stored in it (15 M.D. at 150 I.S.P.) on each attempt." }
      - { level: 13, text: "Map I.S.P.: a further bonus 100 I.S.P. (200 in all) that can only be placed into the Map as it is created." }
      - { level: 14, text: "Illusionary Peoples: for 20 I.S.P. a race of the maker''s design fills the illusion, moving, speaking and acting convincingly; 10 I.S.P. each time when it is part of a Charm of Memory." }
      - { level: 15, text: "Independent and Sustained Map: for 150 I.S.P. a Map set on a renewable source of I.S.P. or P.P.E. persists after its maker leaves, for as long as the energy lasts. Without him it has none of its powers: intruders only walk a marked trail that circles back to the entry point, and its exit, in 1D6+4 minutes." }
  - name: "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)"
    description: "Level 1: Crane Fist 4D6 S.D.C. and Crescent Kick 3D6 S.D.C. The one-legged Immortal Crane Alert Stance makes them 1D6 M.D. and 2D4 M.D. and combines S.D.C. and hit points into M.D.C. while it is held. Combat bonuses: +2 strike, +4 parry, +2 dodge, +1 disarm. One stance at a time; no weapons, though weapons can be parried with bare hands and feet. (printed 28-29.)"
    progression:
      - { level: 2, text: "Immortal Crane Beak Fist (Energy Fist): for 10 I.S.P. a melee round, an additional +1 to strike and a punching motion hits any target up to 25 ft (7.6 m) away for 6D6 S.D.C. to mortal foes or 4D6 M.D. to mega-damage beings and M.D.C. structures. Each one counts as a melee attack, hit or miss." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 4, text: "Immortal Crane Body Hardening #1: +1D6 S.D.C., +2 to P.P., +2 to P.S. and +2 to Spd." }
      - { level: 5, text: "Immortal Crane Gathering Energy Stance: while it is held the character is a mega-damage being (hit points and S.D.C. combined, plus 10 M.D.C. per level). He cannot start an attack in it but can parry and dodge at +1 each over other bonuses and counterstrike anyone who attacks him first, and is +2 to roll with impact. From it he can shift to any Crane Stance he knows." }
      - { level: 6, text: "+1 on initiative, +2 to pull punch or kick, and incredible balance: dodges without penalty when off balance, on one foot or with both feet tied, and may kick from there at half the usual strike bonus and land on his feet." }
      - { level: 7, text: "Immortal Crane Sweeping Enemies Stance: Crescent Kick 4D6+4 M.D. and Beak Claws punch 6D6+8 M.D., half that as S.D.C. damage to mortal foes and S.D.C. structures; S.D.C. and hit points combine into M.D.C.; 2 extra melee attacks a round if the stance is held the whole round, +3 to strike and parry. No pull punch or disarm in this stance." }
      - { level: 8, text: "Immortal Crane Body Hardening #2: +10 S.D.C. and +4 to Spd." }
      - { level: 9, text: "Immortal Crane Flight: for 5 I.S.P. a melee round the character flies on invisible wings at up to Spd 132 (90 mph/144 km); what he can carry depends on his P.S." }
      - { level: 10, text: "+3D6+6 to the character''s I.S.P. Base, +1 to pull punch, and the Crane Beak Fist''s range becomes 50 ft (15.2 m)." }
      - { level: 11, text: "Immortal Crane Serpent Destruction Stance: a two-handed Grab and Thrust punch does 2D6x10 M.D. to dragons and to supernatural or magical worms, snakes and reptilian creatures, and uses three melee attacks. S.D.C. and hit points combine into M.D.C. +3 on initiative, +1 to strike and +3 to parry, against such creatures only." }
      - { level: 12, text: "Immortal Crane Body Hardening #3: +20 S.D.C. and +4 to Spd." }
      - { level: 13, text: "Immortal Crane Transformation: for 80 I.S.P. the character becomes a huge Immortal White Crane for one melee round per level (it may hold until the enemy is beaten or allies are safe). Use only the Crane''s numbers: P.S. 40 Supernatural, P.P. 30, P.E. 30, P.B. 30, Spd 80 running or 220 flying, 600 M.D.C., 120 I.S.P., 250 P.P.E., 9 attacks a melee, +7 initiative, +12 strike, +11 parry, +10 dodge, +7 roll, +9 pull punch, +5 to save vs psionics and insanity, +8 vs magic, +8 vs poison, half damage from fire and cold. Restrained Claw 2D6x10 S.D.C., Full Strength Claw 4D6+20 M.D., Beak 6D6+40 M.D., Kick 1D4x10+10 M.D., Wing Swipe 2D6+10 M.D. On returning, his own S.D.C. and hit points are fully restored and damage the Crane took is not his; if all 600 M.D.C. is lost, he dies." }
      - { level: 14, text: "+4D6 to the character''s I.S.P. Base and +1 on initiative." }
      - { level: 15, text: "Immortal Crane Body Hardening #4: +30 S.D.C., and P.S. becomes Supernatural." }
  - name: "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"
    description: "Level 1: Dragonskin, a mystic hide raised in one full melee round (all attacks spent, parries allowed) against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch at no I.S.P. cost that, if it lands unparried, undodged and not rolled with, tells the striker what the target is (mortal or immortal, human or D-Bee, living or dead, solid or ethereal, demon, dead and damned, supernatural); and one Specialty Attack, with one more at each of levels 3, 7, 10 and 14: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P. a punch or kick), Hammer Fist (1D6x10 to S.D.C. structures only, and on a D20 roll of 16 or higher the target cracks and takes 20 extra from later Hammer Fists; 10 I.S.P.), Internal Strike (2D6 direct to hit points past S.D.C., mortals without M.D.C. armor, 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, which shatters at zero M.D.C.; 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. or P.P.E. drained, spirits and ethereal beings only, not the Discorporated, 30 I.S.P.). (printed 31-33.)"
    progression:
      - { level: 2, text: "Mien-Ch''uan Body Hardening #1: +10 S.D.C., +2 P.P., +2 P.E." }
      - { level: 3, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 4, text: "Critical Strike to supernatural beings on a Natural 19 or 20." }
      - { level: 5, text: "Mien-Ch''uan Body Hardening #2: +20 S.D.C." }
      - { level: 6, text: "Double the character''s Permanent I.S.P. Base." }
      - { level: 7, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 8, text: "Critical Strike to supernatural beings on a Natural 17 or more." }
      - { level: 9, text: "Mien-Ch''uan Body Hardening #3: the Dragonskin''s M.D.C. is doubled, and so is its duration (two melee rounds per level for the same 4 I.S.P. a round)." }
      - { level: 10, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 11, text: "Critical Strike to supernatural beings on a Natural 15 or more." }
      - { level: 12, text: "Add 1D6x10+20 to the character''s Permanent I.S.P. Base." }
      - { level: 13, text: "Mien-Ch''uan Body Hardening #4: +4 P.E." }
      - { level: 14, text: "Select one more Mien-Ch''uan Specialty Attack." }
      - { level: 15, text: "+1 attack per melee round." }
  - name: "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"
    description: "Level 1: Falling Technique - no damage from a fall of 50 ft or less, 1 point per 50 ft from 51 to 400 ft, 1 point per 20 ft beyond 400 ft, and never more than 60 points (terminal velocity past 1200 ft); +1 to roll with punch or impact (other than a fall) at levels 1, 3, 4, 6, 8, 9, 11, 13 and 15. Light-Body Climbing - climb up or down at walking speed with no skill roll, carrying only basic gear and no passenger; requires the Climbing skill, which gains +10%. (printed 39-40.)"
    progression:
      - { level: 2, text: "Drunkard''s Staff: for 22 I.S.P. an ordinary staff, broomstick, pole or branch does 2D8 M.D. (2D8 S.D.C. to S.D.C. targets) and has 1D6x10 M.D.C. if attacked itself. It lasts at least one day; at the end of each 24 hours a roll under 10 on a D20 ends it, and seven saves in a row make it permanent." }
      - { level: 3, text: "Double the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+2 in all)." }
      - { level: 4, text: "Mystic Slime: for 10 I.S.P. an invisible slippery coating makes the character, his clothing, gear and weapons next to impossible to grab or hold. Falling Technique: +1 to roll with punch or impact (+3 in all)." }
      - { level: 5, text: "Neutralize Toxins: for 7 I.S.P., used mostly to drink great amounts of alcohol without being seriously affected." }
      - { level: 6, text: "Belch Toxic Vapor: for 10 I.S.P., at most twice a melee and one attack each, a belch in the face forces a save vs non-lethal poison (16 or higher). Failure: loses initiative and one attack and is -2 to strike, parry, dodge and all combat moves for 1D4 melee rounds. Success: loses one attack that round. Falling Technique: +1 to roll with punch or impact (+4 in all)." }
      - { level: 7, text: "Drunken Stranger (Qiao Zhuang): for 20 I.S.P. the character moves and looks like a different drunk and is not recognized unless seen full in the face in good light, for 24 hours per level." }
      - { level: 8, text: "Blind Drunk: for 12 I.S.P. the character blinds himself for 8 hours per level (cancelled at will) and suffers only a third of the blindness penalties (-3 to strike, parry, dodge and disarm). Falling Technique: +1 to roll with punch or impact (+5 in all)." }
      - { level: 9, text: "Drunken Style Meditation Advancement #1: +15 S.D.C., +2 to M.E. and P.P., +1 to save vs possession. Falling Technique: +1 to roll with punch or impact (+6 in all)." }
      - { level: 10, text: "Add 5D6+22 to the character''s Permanent I.S.P. Base." }
      - { level: 11, text: "Drunken Mind Cloak: for 6 I.S.P. per listener, up to 10 people per level, gibberish holds listeners oblivious to everything around them for as long as the character keeps talking and they are not attacked, robbed or shaken. Or, for 5 I.S.P. per person (also up to 10 people per level), up to four topics are planted in their memory for good after 2D12 melee rounds of confusion. Falling Technique: +1 to roll with punch or impact (+7 in all)." }
      - { level: 12, text: "Drunken Dragon Walk: for 10 I.S.P. the character staggers along the paths of any nearby dragon lines (ley lines) for 1D6 hours." }
      - { level: 13, text: "Inflict Mystic Drunkenness: one breath (one attack) on up to six victims at 10 I.S.P. each; a failed save vs non-lethal poison (16 or higher) leaves them drunk for 2D6 melee rounds, with Spd, skills and combat bonuses halved and -2 attacks per melee. Falling Technique: +1 to roll with punch or impact (+8 in all)." }
      - { level: 14, text: "Drunken Style Meditation Advancement #2: +2 to M.E. and M.A." }
      - { level: 15, text: "Add 1D6x10+33 to the character''s Permanent I.S.P. Base. Falling Technique: +1 to roll with punch or impact (+9 in all)." }
  - { choose: 1, from: ["Mystic Martial Art Power: Ba Gua Kung Fu (Eight Trigrams)", "Mystic Martial Art Power: Bok Pai Kung Fu (Crane Style)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"], note: "Half (50%) of Scouts study Ba Gua." }
equipment_starting:
  - { item_id: "china-mo-fuqian-demon-skin", qty: 1, note: "Special Feature: Mo Fuqian Demon Skin graft, 4D6+18 M.D.C." }
  - { item_id: "china-shadow-armor", qty: 1, note: "M.D.C. Shadow Armor, worn as the basic uniform." }
  - { item_id: "dress-uniform", qty: 1, note: "An M.D.C. dress uniform." }
  - { item_id: "china-standard-brigandine-armor", qty: 1, note: "90 M.D.C. main body; for combat operations and surface missions. May wear the clothing and armor of local surface people instead, as a disguise." }
  - { choose: 1, label: "energy pistol of choice (may be a Chi weapon)", qty: 1, from: ["china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter", "china-chi-energy-pistol-demons-fury", "china-chi-auto-mag-demon-claw"] }
  - { choose: 1, label: "rifle of choice (may be a Chi weapon)", qty: 1, from: ["china-ghf-ak47-hounds-fang-assault-rifle", "china-chi-sniper-rifle-demons-eye"] }
  - { item_id: "ammunition-clips", qty: 10, note: "Five ammo clips for each weapon." }
  - { item_id: "telescopic-scope", qty: 1 }
  - { choose: 1, label: "vibro-knife or saber", qty: 1, from: ["vibro-knife", "vibro-saber"] }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1 }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "rope-per-20-feet-6-m", qty: 5 }
  - { item_id: "hammer-tool", qty: 1 }
  - { item_id: "spike", qty: 4 }
  - { item_id: "animal-snare", qty: "1d6" }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "cyber-gyro-compass", qty: 1, note: "Implant." }
  - { item_id: "cyber-clock-calendar", qty: 1, note: "Implant; printed Clock Calender." }
  - { item_id: "security-clearance-chip", qty: 1, note: "Implant; printed Security Clearance Access Chip." }
restrictions:
  - "Officers get an extra weapon of choice."
  - "May acquire, use and keep weapons, armor and items from the outside world, demon-slaying and magic items included, for missions away from the Geofront."
  - "On assignment: 1D4 hand grenades, 1D4 smoke grenades and/or 1D4 signal flares, heavy weapons, optical enhancements, camera equipment, a light vehicle, food rations, and non-regulation weapons and armor, mainly for disguise and infiltration of enemy territory."
  - "Money is half the CS Ranger''s; housing, food, medical care and every basic need are provided by the government."
extraction_notes: "TEMPLATE CLASS: printed 124-125 says the Geofront Scout/Ranger is the CS Ranger with additions and substitutions; its skills and equipment are stated as ''same as the CS Ranger'', its money as half the CS Ranger''s. The base is production''s cs-ranger (Rifts World Book 11: Coalition War Campaign p.80-82), written out here in full (a same-as class ships a full copy). No copy_of is declared: nearly every top-level key differs. PAGE SPAN: the heading is printed 124; the stats run on printed 125 under a full-column illustration. GROUP: the Geofront Military O.C.C.s section, Regular Army (printed 121), so men-of-arms; S.D.C. 5D6+30 is printed, so no men_of_arms line. XP: the Geofront Scout/Ranger column of printed 160. I.S.P.: ''Permanent I.S.P. Base (Chi)'', M.E. x3 +1D8 per level, stored without a psionic tier (Chi, no powers, no psionic save). ATTRIBUTES AND BONUSES: China''s own (I.Q. 10, P.S. 10, P.E. 12; +1 M.E., +2 P.E., +1D10 Spd, +2 vs Horror Factor, +1 vs poison, stored as toxins_poisons); the CS Ranger prints I.Q. 9, P.E. 12 and no bonuses. SKILLS: the CS Ranger''s list plus China''s additions: Mathematics: Basic +20%, Language: Chinese at 97% (in place of American at 98%; the extra language of choice stays), Literacy: Chinese +15%, Pilot: Bicycle +20% (Bicycling), Intelligence +20%, Lore: Demons & Monsters +20%, Navigation +15%, Pilot: Motorcycle +10% (Motorcycles & Snowmobiles), a vehicle of choice +10% (a second Pilot choice beside the CS Ranger''s own +15% one; the book lists both), and Surveillance Systems (& Tailing) +15%, stored as the Surveillance row. HAND TO HAND: printed ''Substitute Basic Hand to Hand with Tai-Chi, Drunken Style or Shao-lin Kung Fu''; the CS upgrade offer (Expert for two, Martial Arts for three) goes with the replaced style, so a choose group and costs empty. RELATED AND SECONDARY: five related instead of seven and four secondary instead of six, as printed; the CS categories and later-level picks are kept. MYSTIC MARTIAL ART POWER: one of Ba Gua, Bok Pai, Xian Pu or Mien-Ch''uan Kung Fu, selected once at creation (printed 125), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). EQUIPMENT: China''s armor line (Shadow Armor, M.D.C. dress uniform, Standard Brigandine, or local surface clothing as disguise) replaces the CS Dead Boy armor; its weapons line (an energy pistol and a rifle of choice, which may be Chi weapons, five clips each) replaces the CS energy rifle and its E-Clips. The pistol choice is the Geofront and Chi pistols in the catalog, the rifle choice the GHF-AK47 and the Demon''s Eye; the ten clips are stored as ammunition-clips. The CS telescopic sight and the rest of the CS kit are ''basically the same'' and copied; the CS dress uniform is the M.D.C. one. The Mo Fuqian Demon Skin (Special Feature) and the three implants of the Cybernetics line are gear rows; that line replaces the CS ''no cybernetics to start''. MONEY: the CS Ranger draws 1,700 credits a month and starts with one month''s pay; half is 850. No racial line is printed; none is stored. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p126): printed 125: ''select one of the following: Ba Gua Kung Fu (Eight Trigrams; 50% study this power), Bok Pai Kung Fu (Crane Style), Xian Pu Kung Fu (Drunken Stye) or Mien-Ch''uan Kung Fu (Cotton Fist)'' (Stye is the page''s own spelling of Style). It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those four names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

The Geofront Scout is half wilderness scout and half intelligence agent. Scouts
are sent out into the world to reconnoitre, gather intelligence, blaze and mark
trails for the troops behind them, and search for the lost.

Generations of Scouts mapped the Yin Caverns before the Geofront turned its
eyes to the surface, and they are honored for it. No branch of the army knows
the world above as well as they do, and they are among the few soldiers sent
out alone or in pairs.

## GM Notes

Scouts often travel in local surface clothing and armor to hide where they come
from. Use the CS Ranger as the template for anything the book does not change.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-scout-ranger'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0
   AND length(markdown) = 14586;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 11 classes carry their new text' AS assertion, count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE (class_id = 'chun-tzu' AND instr(markdown, 'is the last sentence of ability 2, Hand to Hand Martial Arts Skill') > 0)
    OR (class_id = 'blind-mystic' AND instr(markdown, '2026-10-05, MYSTIC MARTIAL ART POWER: printed 73 (cache p074)') > 0)
    OR (class_id = 'spirit-host' AND instr(markdown, '2026-10-05, MYSTIC MARTIAL ART POWER: printed 69 (cache p070)') > 0)
    OR (class_id = 'jian-shih' AND instr(markdown, '2026-10-05, MYSTIC MARTIAL ART POWER: printed 44 (cache p045)') > 0)
    OR (class_id = 'nei-chia-wu-shih' AND instr(markdown, '2026-10-05, MYSTIC MARTIAL ART POWER: printed 50 (cache p051)') > 0)
    OR (class_id = 'wai-chia-wu-shih' AND instr(markdown, '"], note: "Granted outright (printed 52); the pick only puts its level table on the sheet." }') > 0)
    OR (class_id = 'geofront-chi-commando' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p124-p125)') > 0)
    OR (class_id = 'geofront-chi-warrior' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p124)') > 0)
    OR (class_id = 'geofront-metal-warrior' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p136)') > 0)
    OR (class_id = 'geofront-military-specialist' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p125)') > 0)
    OR (class_id = 'geofront-scout-ranger' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p126)') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'chun-tzu' AND instr(markdown, 'the abilities a power grants at levels 2-15 are not imported') > 0)
    OR (class_id = 'blind-mystic' AND instr(markdown, 'pasted from the shared level-1 block; level 1 only, levels 2-15 not imported') > 0)
    OR (class_id = 'spirit-host' AND instr(markdown, 'pasted from the shared level-1 block; level 1 only, levels 2-15 not imported') > 0)
    OR (class_id = 'jian-shih' AND instr(markdown, 'the abilities it grants at levels 2-15 are not imported') > 0)
    OR (class_id = 'nei-chia-wu-shih' AND instr(markdown, 'the abilities it grants at levels 2-15 are not imported') > 0)
    OR (class_id = 'wai-chia-wu-shih' AND instr(markdown, 'level 1 only, levels 2-15 not imported, see BOOK-INGEST-AUDIT.md F117') > 0)
    OR (class_id = 'geofront-chi-commando' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0)
    OR (class_id = 'geofront-chi-warrior' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0)
    OR (class_id = 'geofront-metal-warrior' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported (BOOK-INGEST-AUDIT.md F117).') > 0)
    OR (class_id = 'geofront-military-specialist' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0)
    OR (class_id = 'geofront-scout-ranger' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('chun-tzu', 'blind-mystic', 'spirit-host', 'jian-shih', 'nei-chia-wu-shih', 'wai-chia-wu-shih', 'geofront-chi-commando', 'geofront-chi-warrior', 'geofront-metal-warrior', 'geofront-military-specialist', 'geofront-scout-ranger') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~168-china-2-martial-art-power-levels-part-1.sql');
