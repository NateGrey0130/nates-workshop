-- Give China 2's Mystic Martial Art Powers their later levels, part 2 of 2
-- 11 classes, each replaced whole: geofront-shadow-warrior, geofront-technical-officer, fu-yao-da-chia, demon-and-dead-slaver, goblin-wrangler, enlightened-demon, soothsayer, geofront-assault-geo-borg, geofront-demon-eater-geo-borg, geofront-lion-geo-borg, geofront-gun-master.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~169-china-2-martial-art-power-levels-part-2.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Part 2 of 2; ~168 carries the account of the whole change.

-- == geofront-shadow-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-shadow-warrior
name: Geofront Shadow Warrior
system: rifts
source_book: Rifts World Book 25: China 2 p.135-136
category: occ
tags: [combat, stealth]
xp_table: [0, 2161, 4321, 8641, 17201, 27301, 37401, 55501, 76001, 102001, 146001, 192001, 248001, 298801, 356901]
occ_group: men-of-arms
race_restrictions:
  only: ["none"]
  note: "The entry prints no racial line. The Geofront military is the army of a human nation, and the base class (CS Special Forces) is human only; in Rifts a human character takes no R.C.C., so \"none\" is the human case."
starting_money: "1d6x500"
attribute_requirements:
  IQ: 10
  ME: 10
  PS: 12
  PP: 14
sdc_base: "6d6+50"
bonuses:
  attributes: { ME: 2, PS: "1d6", Spd: "1d6" }
  combat: { pull_punch: 2 }
  saves: { possession: 2, horror_factor: 4 }
psionics:
  isp_base: "M.E. attribute number x4, +1d10 per level of experience"
  powers_starting: 0
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed as Mathematics: Basic (+20%), the same as the base''s Math: Basic." }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Radio: Scramblers", base: 45, per_level: 5, note: "Printed as Radio: Scrambler (+10%)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Printed as Language: Chinese at 98%; it takes the place of the base''s American." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%), from the base." }
    - { name: "Literacy: Chinese", base: 70, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Streetwise", base: 36, per_level: 4, note: "+16%, as the base prints it." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "Printed as Lore: Demon/Monster (+10%)." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%)." }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "Printed as Pilot Hover Vehicle (i.e., Police Cruiser; +10%), substituted for the base''s Pilot: Robots & Power Armor. The base''s Robot Combat Elite is thrown out." }
    - { name: "Bicycling", base: 54, per_level: 4, note: "Printed as Pilot: Bicycle (+10%)." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 45, per_level: 5, note: "+20%; this book''s figure, in place of the base''s +15%." }
    - { name: "Disguise", base: 40, per_level: 5, note: "+15%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice." }
    - { choose: 1, from: ["Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Substituted for the base''s Hand to Hand: Commando. Pick only one; all are advanced styles. Half of Shadow Warriors pick Eighteen Weapons." }
  mos:
    choose: 1
    note: "Area of special training, as the base''s (\"plus the usual for Special Forces\"): select FOUR skills from one of these categories, each at +15%. They come in addition to the O.C.C. skills."
    options:
      - id: "communications"
        name: "Communications MOS"
        skills:
          - { choose: 4, categories: ["Communications"], bonus: 15 }
      - id: "espionage"
        name: "Espionage MOS"
        skills:
          - { choose: 4, categories: ["Espionage"], bonus: 15 }
      - id: "mechanical"
        name: "Mechanical MOS"
        skills:
          - { choose: 4, categories: ["Mechanical"], bonus: 15 }
      - id: "military"
        name: "Military MOS"
        skills:
          - { choose: 4, categories: ["Military"], bonus: 15 }
      - id: "piloting"
        name: "Piloting MOS"
        skills:
          - { choose: 4, categories: ["Pilot"], bonus: 15 }
      - id: "rogue"
        name: "Rogue MOS"
        skills:
          - { choose: 4, categories: ["Rogue"], bonus: 15 }
      - id: "weapon-proficiencies"
        name: "Weapon Proficiencies MOS"
        skills:
          - { choose: 4, categories: ["Weapon Proficiencies"], note: "The +15% has nothing to add to a W.P." }
      - id: "wilderness"
        name: "Wilderness MOS"
        skills:
          - { choose: 4, categories: ["Wilderness"], bonus: 15 }
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
    note: "Same as the CS Commando: two picks at levels two, five, nine and twelve. The Commando''s level-one related picks are its four MOS skills, which this class already has from Special Forces, so none are added at level one. Technical is printed +5%, and +10% for Literacy and Language skills; the category bonus stores the +5%. Electrical is Basic Electronics only."
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
equipment_starting:
  - { item_id: "china-mo-fuqian-demon-skin", qty: 1, note: "Special Feature: Mo Fuqian Demon Skin (4D6+18 M.D.C.), grafted onto every Geofront soldier." }
  - { item_id: "china-shadow-armor", qty: 1, note: "M.D.C. Shadow Armor as a basic uniform." }
  - { item_id: "dress-uniform", qty: 1, note: "An M.D.C. dress uniform." }
  - { choose: 1, label: "combat armor for the surface", qty: 1, from: ["china-standard-brigandine-armor", "china-heavy-brigandine-armor", "china-mo-fuqian-kai-demon-skin-armor"] }
  - { choose: 1, label: "pistol of choice (first of two)", qty: 1, from: ["china-ght-85-hounds-tooth-auto-mag", "china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter"] }
  - { choose: 1, label: "pistol of choice (second of two)", qty: 1, from: ["china-ght-85-hounds-tooth-auto-mag", "china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter"] }
  - { item_id: "china-ghf-ak47-hounds-fang-assault-rifle", qty: 1, note: "The book prints one conventional M.D. rifle; the Hound''s Fang is the Geofront''s standard-issue rifle." }
  - { choose: 1, label: "Chi Rifle or heavy weapon", qty: 1, from: ["china-chi-sniper-rifle-demons-eye", "china-chi-mini-gun-vengeance"] }
  - { item_id: "magazine-clips", qty: 24, note: "Six ammo clips for each of the four weapons." }
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
special_abilities:
  - name: "Mo Fuqian: Demon Skin"
    description: "Special Feature: an artificial M.D. skin graft with 4D6+18 M.D.C. that heals quickly (see the gear row). May also wear the Mo Fuqian Kai Demon Skin Armor as a disguise on the surface."
  - { choose: 1, from: ["Mystic Martial Art Power: Pao Chih (Animus Development)", "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)", "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)", "Mystic Martial Art Power: Gui Long Kung Fu (Dragon Blade)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)", "Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)"] }
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
  - "Issued a conventional military vehicle of choice for daily use, as the CS Commando is. Additional weapons, gear and vehicles may be issued on assignment, and the Shadow Warrior may acquire and keep weapons, armor and items from the outside world, demon slaying and magic items included, for missions away from the Geofront."
  - "Cybernetics optional, except for the Security Access Chip (top security). About 80% decline; one who accepts selects four implants."
  - "Pao Chih and Tong Lun (the animus powers) are exclusive to Shadow Warriors: only Geofront Special Forces learn a Mystic Martial Art Power that wields an animus."
  - "Begins at the rank of Corporal or Sergeant, depending on performance in training."
level_progression:
  - { level: 2, grants: ["+2 O.C.C. Related Skills"] }
  - { level: 4, grants: ["+2 Secondary Skills"] }
  - { level: 5, grants: ["+2 O.C.C. Related Skills"] }
  - { level: 7, grants: ["+2 Secondary Skills"] }
  - { level: 9, grants: ["+2 O.C.C. Related Skills"] }
  - { level: 10, grants: ["+2 Secondary Skills"] }
  - { level: 12, grants: ["+2 O.C.C. Related Skills"] }
extraction_notes: "DECLARED COPY: printed 135-136 says O.C.C. Skills are the same as CS Special Forces with additions and substitutions, and related skills, secondary skills and equipment the same as the CS Commando with substitutions. This is a full copy of production''s cs-special-forces (O.C.C. skills and MOS) and cs-commando (related, secondary, equipment) with the printed changes applied. No copy_of is declared: the book changes most blocks, and a declaration would except nearly every key. GROUP: the book''s Elite Geofront Forces section (printed 128), so men-of-arms. CHANGES APPLIED to the Special Forces skills: Language: Chinese at 98% replaces the native American; Literacy: Chinese (+15%), Pilot: Bicycle (+10%) and Disguise (+15%) added; Prowl at +20% replaces the base''s +15%; Mathematics: Basic (+20%) equals the base''s; Pilot: Robots & Power Armor substituted by Pilot Hover Vehicle (+10%), stored as Hover Craft (ground); Robot Combat Elite thrown out; Hand to Hand: Commando substituted by a pick of five China styles. HAND TO HAND: the style is a pick of one and the book sells no other, so costs is empty. RELATED SKILLS: the Commando''s are stored with count zero and its schedule, because the Commando''s level-one related picks are its MOS, and this class already takes the Special Forces MOS; a reader who takes the Commando''s four MOS picks as well is reading it the other way. EQUIPMENT: the Commando''s list with the printed substitutions - Shadow Armor, a dress uniform, and Standard or Heavy Brigandine or Demon Skin Armor in place of the Dead Boy armor; two pistols of choice (the Geofront handguns), one conventional M.D. rifle (the GHF-AK47, the only Geofront rifle in the catalog), one Chi Rifle or heavy weapon (the Chi sniper rifle or the Chi mini-gun) and six clips for each, as 24 magazine clips, in place of the Commando''s energy rifle, sidearm, E-clips and non-energy weapon. Grenades, flares, knives and the rest of the Commando''s kit are kept. MONEY: half that of the CS character; the Special Forces start with 1D6x1000 credits and earn 1,900 a month, so 1D6x500 is stored; basic needs are provided by the government. S.D.C. 6D6+50 is stored as sdc_base. I.S.P.: M.E. x4 +1D10 per level is the Chi pool; additional Chi from the Mystic Martial Art Power is in that power''s text. MYSTIC MARTIAL ART POWER: one of six, selected once at creation (printed 136), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). The book''s percentages (Pao Chih 30%, Tong Lun 30%, She Shen 30%; Eighteen Weapons 50%) are distribution notes, not rules. ALIGNMENT: any; the book notes 30% Anarchist and 30% Aberrant. XP: the Demon Catching Hero, Soothsayer and Shadow Warrior ladder, printed 160, read off a render. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p137): printed 136: ''select one of the following: Pao Chih (Animus Development; exclusive to Shadow Warriors, 30% take this one), Tong Lun King Fu (Praying Mantis Animus; exclusive to Shadow Warriors, 30% take this one), She Shen Kung Fu (Snake Style; 30% take this one), Gui Long Kung Fu (Dragon Blade), Xian Pu Kung Fu (Drunken Style), or Mien-Ch''uan Kung Fu (Cotton Fist)''. This page spells the second ''Tong Lun King Fu (Praying Mantis Animus)''; the option keeps the name it already has, Tong Lun Kung Fu (Praying Mantis Style), so saved picks still match. It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those six names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

Shadow Warriors are the Geofront''s special forces: its enforcers, assassins
and super-commandos. They are sent on espionage and sabotage, seek-and-destroy
raids, assassinations, prison breaks and rescues deep inside hostile ground.

They are the only Geofront soldiers taught the mystic arts that raise an
animus, a Mega-Damage spirit double of the warrior that fights at his side.

## GM Notes

Outside China every Chi-based power weakens (printed 141): the Chi pool, the
Chi a character can draw on, and the range, duration and damage of Chi powers
are halved, M.D.C. from a Mystic Martial Art Power drops by 30%, combat bonuses
from those powers drop by one, and characters above sixth level lose one attack
per melee. None of this is stored.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-shadow-warrior'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported (BOOK-INGEST-AUDIT.md F117).') > 0
   AND length(markdown) = 17781;

-- == geofront-technical-officer ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-technical-officer
name: Geofront Technical Officer
system: rifts
source_book: Rifts World Book 25: China 2 p.125-126
category: occ
tags: [tech]
occ_group: men-of-arms
xp_table: [0, 2121, 4241, 8481, 17001, 24901, 36301, 52601, 72901, 96001, 132301, 181601, 232901, 282301, 334601]
attribute_requirements: { IQ: 9, PS: 8, PP: 8, PE: 8 }
sdc_base: "4d6+20"
starting_money: "1100"
psionics:
  isp_base: "M.E. x2, +1d6 per level of experience"
  powers_starting: 0
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Printed as Language: Chinese at 95%. Stands in for the CS Technical Officer''s Language: Native Tongue." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%. Stands in for the CS Technical Officer''s Literacy: Native Language." }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "The CS Technical Officer''s figure; China adds Mathematics: Basic (+20%), which is lower, so the CS figure is kept." }
    - { name: "Bicycling", base: 64, per_level: 4, note: "Printed as Pilot: Bicycle (+20%). A Geofront addition." }
    - { name: "Sensory Equipment", base: 50, per_level: 5, note: "Printed as Read & Operate Sensory Equipment (+20%). A Geofront addition." }
    - { name: "Navigation", base: 55, per_level: 5, note: "+15%. A Geofront addition." }
    - { choose: 1, from: ["Motorcycles & Snowmobiles", "Hover Craft (ground)"], bonus: 5, note: "Printed as Pilot: Motorcycle (+5%) or Hover Vehicles (includes the Police Cruiser, +5%). A Geofront addition. Hover Craft (ground) is already an O.C.C. skill at 60%." }
    - { name: "Military Etiquette", base: 55, per_level: 5 }
    - { name: "Computer Operation", base: 55, per_level: 5 }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5 }
    - { name: "Radio: Basic", base: 55, per_level: 5 }
    - { name: "Running", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["Hand to Hand: Tai-Chi Ch''uan", "Hand to Hand: Shao-Lin Kung Fu"], note: "Replaces the CS Technical Officer''s Hand to Hand: Basic (and its offer of Expert for one related skill): Tai-Chi (basic, and the standard for a character with a P.P. of 10 or less) or Shao-lin Kung Fu (advanced)." }
  mos:
    choose: 1
    note: "Same as the CS Technical Officer: select one area of specialty. Every skill under it is granted in addition to the O.C.C. skills."
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
    note: "Same as the CS Technical Officer. Communications Any (+5%). Domestic Any. Electrical, Science and Wilderness: none unless part of his MOS. Espionage, Horsemanship and Cowboy: none."
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
  - { item_id: "ammunition-clips", qty: 8, note: "Four ammo clips for each weapon." }
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
  - { choose: 1, label: "radio and scrambler ear implant or headjack", qty: 1, from: ["radio-and-scrambler-implant", "universal-headjack-and-ear-implant"], note: "Printed as Radio & Scrambler Ear Implant (1000 channels, 100 mile/160 km range) or Headjack." }
restrictions:
  - "Rank typically starts at Corporal."
  - "Officers get a Geo-Blaster/Phased Emitter or pistol of choice as a second sidearm."
  - "Equipment on assignment is whatever the mission needs, at the commanding officer''s discretion."
  - "Money is half the CS soldier''s; housing, food, medical care and every basic need are provided by the government."
extraction_notes: "TEMPLATE CLASS: printed 125-126 says the Technical/Communications Officer is the CS Technical Officer with additions and substitutions; its skills, MOS, related and secondary skills, equipment and money are stated as ''same as the CS Technical Officer''. The base is production''s coalition-technical-officer (Rifts Ultimate Edition p.236-237), written out here in full (a same-as class ships a full copy); its MOS block is copied verbatim. No copy_of is declared: nearly every top-level key differs. NAME: printed as Technical/Communications Officer (no O.C.C. in the heading); the experience chart and the Regular Army list call it Geofront Technical Officer and Technical/Communications Officer O.C.C. GROUP: the Geofront Military O.C.C.s section, Regular Army (printed 121), so men-of-arms; S.D.C. 4D6+20 is printed, so no men_of_arms line. XP: the Geofront Technical Officer column of printed 160. I.S.P.: ''Permanent I.S.P. Base (Chi)'', M.E. x2 +1D6 per level, stored without a psionic tier (Chi, no powers, no psionic save). ATTRIBUTES: China''s (I.Q. 9, P.S. 8, P.P. 8, P.E. 8). BONUSES: China prints no Bonuses line for this class, and neither does the base; none stored. SKILLS: the CS list plus China''s additions: Mathematics: Basic +20% (the CS row already stands at 75%, kept), Language: Chinese at 95% and Literacy: Chinese +20% in place of the CS native language and literacy, Pilot: Bicycle +20% (Bicycling), Read & Operate Sensory Equipment +20% (Sensory Equipment), Navigation +15%, and Pilot: Motorcycle +5% or Hover Vehicles +5% as a choice (Hover Craft (ground) is already a CS O.C.C. skill at 60%, so picking it duplicates a held skill). HAND TO HAND: printed ''Substitute Basic Hand to Hand with Tai-Chi or Shao-lin Kung Fu''; a choose group, and the CS offer of Expert goes with the replaced style, so costs is empty. MYSTIC MARTIAL ART POWER: one of Bok Pai or Mien-Ch''uan Kung Fu, selected once at creation (printed 126), one choose-1 group. Each power''s later levels are shown on the sheet as text since 2026-10-05 (display only; nothing a later level says is added to the character''s numbers). EQUIPMENT: China''s armor line (Shadow Armor, M.D.C. dress uniform, Standard Brigandine) replaces the base''s Dead Boy armor, and its weapons line adds the GHF-AK47 and GHT-85 with four clips each (8 ammunition-clips); the base row carries no weapons. The rest is ''basically the same'' and copied. The Mo Fuqian Demon Skin (Special Feature) and the Cybernetics line (three implants plus a Radio & Scrambler Ear Implant or Headjack, a choice) are gear rows; that line replaces the CS one. MONEY: the CS Technical Officer draws 2,200 credits a month and starts with one month''s pay; half is 1,100. No racial line is printed; none is stored. 2026-10-05, MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p127): printed 126: ''select one of the following: Bok Pai Kung Fu (Crane Style) or Mien-Ch''uan Kung Fu (Cotton Fist)''. It follows the Hand to Hand style and is a single selection: the page states no level for it, grants no power outright, and gives no further power at a later level; a percentage beside a power is how many soldiers take it, not a roll. Stored: the one choose-1 group over those two names, as it was. The class''s own pages print no Body Hardening exercise."
---

## Lore

The Geofront''s Technical/Communications Officers keep the army talking and
its equipment running. They specialize in communications, information
gathering, and the operation and upkeep of the machines that go with them,
and most start at the rank of corporal.

Like every Geofront soldier they are trained in a Chinese martial art and a
Mystic Martial Art Power, so a technician can still hold a line against a
demon when the fighting reaches the signal post.

## GM Notes

Use the CS Technical Officer as the template for anything the book does not
change, including the choice of specialty.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-technical-officer'
   AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0
   AND length(markdown) = 13161;

-- == fu-yao-da-chia ==
UPDATE imported_classes
   SET markdown = '---
id: fu-yao-da-chia
name: "Fu Yao Da Chia (Great Demon Catching Hero)"
system: rifts
source_book: Rifts World Book 25: China 2 p.77-83
category: occ
tags: [hunter, combat, wilderness]
occ_group: men-of-arms
attribute_requirements: { ME: 12, PE: 12 }
sdc_base: "1d6x10 + P.E."
starting_money: "6d6x100"
xp_table: [0, 2161, 4321, 8641, 17201, 27301, 37401, 55501, 76001, 102001, 146001, 192001, 248001, 298801, 356901]
psionics:
  isp_base: "M.E. + 2d6, +2 per level of experience"
bonuses:
  attributes: { PS: 2, PE: 2, PP: 2 }
  combat: { pull_punch: 2, entangle: 2 }
  saves: { spell_magic: 1, horror_factor: 3, possession: 1, curses: 1 }
  at_level:
    - { level: 3, saves: { possession: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 5, saves: { possession: 1 } }
    - { level: 7, saves: { possession: 1 } }
    - { level: 8, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 9, saves: { possession: 1 } }
    - { level: 12, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 13, saves: { possession: 1 } }
    - { level: 15, saves: { possession: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 20, note: "Printed as Basic Math (+20%)." }
    - { name: "Calligraphy", bonus: 5, note: "+5%" }
    - { name: "Demon Wrestling", base: 30, per_level: 5, note: "No bonus printed; catalog base." }
    - { name: "Fasting", bonus: 5, note: "+5%" }
    - { name: "Tiao Qi/Chinese Checkers", bonus: 15, note: "Printed as Games: Tiao Qi (+15%). Knows how to cheat or throw a game, at -10% to the skill." }
    - { name: "Imperial Bureaucracy & Administration", bonus: 5, note: "+5%" }
    - { name: "Land Navigation", bonus: 20, note: "+20%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Native Chinese speaker, 95%." }
    - { name: "Language: Demongogian", base: 80, per_level: 0, note: "The native language of demonkind, 80%." }
    - { name: "Literacy: Chinese", base: 85, per_level: 0, note: "Chinese characters/ideograms, 85%." }
    - { choose: 1, from: ["Literacy: Ancient & Classical Chinese", "Lore: Chinese Mythology: Taoist", "Lore: Demons & Monsters"], bonus: 20, note: "Lore: one of Literacy: Ancient & Classical Chinese, Taoist Chinese Mythology or Demons & Monsters (+20%)." }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { choose: 2, from: ["Field Armorer & Munitions Expert", "Camouflage", "Demolitions", "Military Etiquette", "Military Fortification", "Recognize Weapon Quality", "Trap Construction", "Trap/Mine Detection"], bonus: 15, note: "Military: any two (+15% each). The book offers Armorer/Field Armorer for traditional Chinese weapons or for modern weapons; both are the catalog''s Field Armorer & Munitions Expert." }
    - { name: "Radio: Basic", bonus: 10, note: "+10%" }
    - { name: "Tracking (people)", bonus: 15, note: "Printed as Tracking (humanoids and all forms of demons; +15%)." }
    - { name: "Wilderness Survival", bonus: 15, note: "+15%" }
    - { choose: 3, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming"], note: "Physical: any three; Aerobic Athletics or General Athletics, not both." }
    - { choose: 2, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.: any two. Battle Axe is W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.: any two." }
    - { choose: 1, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.: any one. Spear (Throwing) is W.P. Spear." }
    - { choose: 1, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.: any one." }
    - { name: "W.P. Gien Bian (Steel Whip)", base: 0, per_level: 0, note: "Automatic; the chi-trained character can make it a mega-damage weapon." }
    - { choose: 1, from: ["Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Select one as the basis of the character''s combat skills. No other style is offered." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", except: ["Juicer Technology", "M.D. in Cybernetics", "Pathology"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Cardsharp", "Concealment", "Dickering", "Find Contraband", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Pick Locks", "Prowl", "Streetwise"] }
      - "Science"
      - { name: "Technical", note: "Any; +15% to Art, Rope Works, Mythology and Lore skills only, so no category bonus is stored." }
      - { name: "Weapon Proficiencies", except: ["W.P. Sharpshooting"] }
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
    note: "Five at level one, plus one at levels 4, 8 and 12. Pilot Related: none. All new skills start at level one proficiency."
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", except: ["Juicer Technology", "M.D. in Cybernetics", "Pathology"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", only: ["Begging", "Calligraphic Forgery", "Cardsharp", "Concealment", "Dickering", "Find Contraband", "Gambling (Standard)", "Gambling (Dirty Tricks)", "Palming", "Pick Locks", "Prowl", "Streetwise"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Sharpshooting"] }
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
    note: "Three at level one, plus one at levels 3, 7, 9 and 13, from the related list and its limits, at the base skill level."
equipment_starting:
  - { item_id: "china-book-of-ten-thousand-demons-wan-gui-yao", qty: 1, note: "The Wan Gui Yao, Essentials of the 10,000 Infernals." }
  - { choose: 1, label: "Demon Hunter Sword", qty: 1, from: ["china-sword-of-demon-hunting-the-hunter-blade", "china-sword-of-demon-hunting-the-hunter-slayer-blade", "china-sword-of-demon-hunting-the-demon-hunter-defender", "china-sword-of-demon-hunting-the-demon-hunters-vengeance"] }
  - { item_id: "china-binding-demon-catching-mirror", qty: 1, note: "The eight-sided Demon Catching Mirror." }
  - { item_id: "china-binding-demon-snare", qty: 2, note: "Two demon snares." }
  - { item_id: "china-bone-swords-and-weapons", qty: 1, note: "One S.D.C. weapon of bone: typically a knife (1D6) or a short sword or club (2D4)." }
  - { item_id: "knife-silver-plated", qty: 1, note: "One S.D.C. weapon of silver: typically a knife (1D6) or a short sword or club (2D4)." }
  - { item_id: "e-clip", qty: 2, note: "For the energy weapon of choice." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged cotton, wool and leather traveling clothes, with hat." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "Heavy winter/mountain over-garments." }
  - { item_id: "clothing", qty: 1, note: "Embroidered silk indoor suit: slippers, pants, shirt, long jacket, scarf and hat." }
  - { item_id: "robe", qty: 1, note: "Silk robe." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book of 3D6x10 pages." }
  - { item_id: "pencil", qty: "1d4" }
  - { item_id: "paper-dz-9x12-inch-sheets", qty: 1, note: "4D6 sheets of blank paper." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "Fire starter kit or cigarette lighter." }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4", note: "Scented candles." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "Small meat cleaver." }
  - { item_id: "backpack", qty: 1, note: "Large traveler''s shoulder bag." }
  - { item_id: "multi-purpose-pouch", qty: 2, note: "A belt pouch and a small neck pouch." }
  - { item_id: "rope-per-foot", qty: 30, note: "30 feet (9.1 m) of rope." }
  - { item_id: "leg-manacles", qty: 2, note: "Two sets of leg irons for binding demons, each with four feet (1.2 m) of chain." }
  - { item_id: "chain-per-foot-rifts", qty: 8, note: "The leg irons'' chain, four feet a set." }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - { choose: 4, from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Vital Breath", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: four to start (printed 79). One more at each of levels 3, 6, 9, 12 and 15 is picked by hand from this same list, because one group holds one count for every level and the page gives four at creation and one at each later level." }
  - name: "Body Hardening: Control Revulsion"
    description: "Trained by exposure to gore and filth: +3 to save vs Horror Factor and vs the vomit and gag response to terrible smells, slime, blood and gore. (printed 92.)"
    bonuses: { saves: { horror_factor: 3 } }
  - name: "Body Hardening: Demon Digestion"
    description: "Can eat nearly anything, belch, retch or rumble at will (a gross-out Horror Factor 13 at worst), senses poison in the system and expels it in 10 minutes to 2 hours. +1 P.E.; damage, penalties and duration of poisons and drugs are halved. (printed 92.)"
    bonuses: { attributes: { PE: 1 } }
  - name: "Body Hardening: Dislocation Training"
    description: "Joints deliberately dislocated in training: +2 to save vs pain, +1 P.E., +1 to roll with impact, +5% to Escape Artist if the character has it, and +2D6+12 S.D.C. (rolled by the player, not applied). (printed 92.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 2 }, combat: { roll: 1 } }
  - name: "Body Hardening: Feign Death"
    description: "Plays dead convincingly: +2 to save vs pain, +10 S.D.C., +5% vs coma/death, +1 vs Horror Factor; holds breath five minutes, +1 minute at levels 3, 6, 9 and 12. Feign death or coma 40% +4% per level (+10% against a simple examination). (printed 93.)"
    bonuses: { saves: { pain: 2, horror_factor: 1, coma_death_pct: 5 }, pools: { sdc: 10 } }
    progression:
      - { level: 3, text: "Holds breath for six minutes." }
      - { level: 6, text: "Holds breath for seven minutes." }
      - { level: 9, text: "Holds breath for eight minutes." }
      - { level: 12, text: "Holds breath for nine minutes." }
  - name: "Body Hardening: Hardened Internal Organs"
    description: "Moves vital organs out of a blade''s path: a successful roll (40% +4% per level) holds the hit point damage of a piercing wound it can anticipate to 1 point (S.D.C. damage is taken normally). +1 P.E., +1 to save vs pain, and recovers hit points and S.D.C. twice as fast. (printed 93.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 1 } }
  - name: "Body Hardening: Heal Internal Organs and Injury"
    description: "Healing meditation: restores 1D6 hit points an hour, up to a third of the total (25% of M.D.C. for a mega-damage being), stops bleeding in 2D4 melee rounds; +10% vs coma/death. (printed 93.)"
    bonuses: { saves: { coma_death_pct: 10 } }
  - name: "Body Hardening: Laugh at Pain"
    description: "The Lau Re maneuver: +2 to save vs pain, +1 M.E., M.A. and P.E., +5% vs coma/death, and +8% (+2% per level) to intimidate when showing off pain resistance; the skill is 50% +4% per level and scares ordinary people as Horror Factor 13. (printed 93.)"
    bonuses: { attributes: { ME: 1, MA: 1, PE: 1 }, saves: { pain: 2, coma_death_pct: 5 } }
  - name: "Body Hardening: Life Stone"
    description: "A stone fused beside the heart makes the character a minor mega-damage being with 1D6+6 M.D.C. that is always there and is lost before S.D.C. (attacks direct to hit points bypass it); +1 to roll with impact, +5% vs coma/death and +4D6 S.D.C. (both dice rolled by the player, not applied). (printed 93.)"
    bonuses: { saves: { coma_death_pct: 5 }, combat: { roll: 1 } }
  - name: "Body Hardening: Resist Psychic Drain"
    description: "Fatigues at half the normal rate; +2 to save vs possession and psychic drain, +1 vs Demonic Curses, magic vapors and breath attacks, and magic illness. (printed 93.)"
    bonuses: { saves: { possession: 2, curses: 1 } }
  - name: "Body Hardening: Vital Breath"
    description: "Senses foul air and holds breath at once: +2 to save vs breath attacks, gases, poisoned air and sudden loss of pressure, +2 initiative to hold breath in time, three extra minutes of held breath, and can share air. (printed 93.)"
    bonuses: { saves: { other: [ { label: "vs breath attacks, gases and poisoned air", bonus: 2 } ] } }
  - name: "Body Hardening: Yung Chin (Eternal Clarity)"
    description: "Resists alcohol at +20% (+4% per level) and suffers half the penalties of drunkenness (-2 initiative, -1 strike, parry and dodge, Spd down one quarter, skills down 6%). (printed 94.)"
  - { choose: 1, from: ["Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)", "Mystic Martial Art Power: Tien-Hsueh Kung Fu (Touch Mastery)", "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)", "Mystic Martial Art Power: Xian Pu Kung Fu (Drunken Style)"], note: "Mystic Martial Art Power: one of these four (printed 79). The chosen power''s later levels are shown on the sheet as text (display only; nothing a later level says is added to the character''s numbers)." }
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
  - name: "Pest Exterminator for the Celestial Court"
    description: "The Celestials regard demon hunters as their royal rat catchers. The character hunts, captures, reforms or permanently binds demons, exterminating them only when nothing else serves; helps those who would depose the Yama Kings; and ranks his targets by the harm they do to the helpless and innocent."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Can gather and direct chi, even in very weak P.P.E. environments, to give otherwise ordinary weapons mega-damage. Comes with W.P. Gien Bian (Steel Whip), a favoured weapon for entrapping demons."
  - name: "Powers of Meditation"
    description: "The character''s inner strength is given over to meditation and sensing chi, so he never gains psionic powers beyond those of his Mystic Martial Art; I.S.P. is M.E. +2D6, +2 per level. Skilled in Meditation and resistant to Demonic Curses: curses with a time limit last half as long for him."
  - name: "W.P. Demon Snare"
    description: "A special proficiency used only to entrap: a snare catches an opponent''s neck, wrist or ankle, cannot parry and does no damage on impact, but pinches and gouges as it tightens, hurting susceptible demons. Includes braiding snares from string, rope, cloth or leather."
  - name: "Affliction: Demonic Curses"
    description: "Starts with none, but many demon catchers carry 1-4 Demonic Curses at any time, handed out by their adversaries (Rifts China One, pages 54-60). Most are temporary or removable, and the catcher knows the means."
  - name: "Demonic Entourage"
    description: "Usually has, or soon acquires, one captive demon (typically a Lesser Demon, Goblin or Nature Spirit) in rehabilitation, kept in chains and set to hard labour; Greater Demons come after three or four levels, and seldom more than 4-6 are kept. Roll 1D6 for a captive''s outlook: 1-2 Belligerent Captive, 3 Plays the Game, 4 Frightened Hater, 5 Searching for the Path to Enlightenment, 6 an Enlightened Demon. The G.M. plays captives as N.P.C.s and most catchers start with none."
  - name: "Other Demon Queller Equipment"
    description: "May buy useful magic items worth up to 5,000 credits in all from the Green Scarf list, acquired from elder catchers or other Taoist artisans rather than the Green Scarf Sect, which the character despises. Also starts with four other traditional Chinese weapons (3D6 rounds of ammunition for each projectile weapon), one S.D.C. gun with 100 rounds (half may be silver coated), one energy weapon of choice, identification documents and a Yama Kingdom passport, 2D6+2 pieces of incense and a small incense burner, herbs, a tea bottle, two sets of chopsticks and 30 cups of uncooked rice."
restrictions:
  - "Cybernetics: none."
  - "Never gains psionic powers beyond the abilities of the chosen Mystic Martial Art."
trackable_resources: []
extraction_notes: |
  - Printed 77-83 (cache p078-p084; p079 is a full-page illustration, printed
    78). Every number read off a 200 dpi render. The section heading is Demon
    Quellers (printed 77), Rifts China Demon Queller O.C.C.s; the brief files
    the Demon Quellers as men-of-arms (occ_group). S.D.C. is printed
    (1D6x10 + P.E.), so no men_of_arms line. No hit point formula is printed.
  - Name: the book''s header is Fu Yao Da Chia O.C.C., also known as Great Demon
    Catching Hero, Demon Hunter, Demon Queller and Champion Demon Catcher. Not
    named plain Demon Queller (Japan''s class holds that id).
  - xp_table: the Demon Catching Hero / Soothsayer / Shadow Warrior column,
    printed 160 (cache p161), read off a render; lower bounds stored.
  - attribute_requirements: "M.E. should be above 11, with a P.E. of 12 or
    better" stored as minimums of 12 and 12 (JUDGEMENT: "should" read as a
    requirement).
  - I.S.P.: M.E. +2D6, +2 per level. No psionic tier is printed and the class
    never gains powers beyond its Mystic Martial Art, so psionics states only
    isp_base.
  - Bonuses: +2 P.S., P.E., P.P.; +2 pull punch, +2 entangle; +1 save vs magic
    (spell_magic only, as the Anti-Monster''s plain save vs magic was stored);
    +3 vs Horror Factor; +1 initiative at 4, 8 and 12; +1 vs possession at
    1, 3, 5, 7, 9, 13 and 15 (the book skips 11); +1 vs Demonic Curses (the
    curses save) at 1, 4, 8 and 12. Curses with a time limit lasting half as
    long is prose.
  - Mystic Body Hardening Exercises (printed 92-94): four to start, then one at
    levels 3, 6, 9, 12 and 15 (printed 79). The level-1 picks are a choose 4 over
    the shared block; the later picks are made by hand from the same list (see
    the 2026-10-05 note). Mystic Martial Art Power: one of Cotton Fist, Touch
    Mastery, Praying Mantis or Drunken Style, a choose 1. Touch Mastery
    requires Acupuncture, which this class can reach only as a Medical related
    pick.
  - 2026-10-05, re-read off renders of printed 79 and 92-94. Printed 79, item 2:
    select four Demon Queller Body Hardening Exercises to start, then one
    additional at levels 3, 6, 9, 12 and 15. Item 4: select either Mien-Ch''uan
    (Cotton Fist), Tien-Hsueh (Touch Mastery), Tong Lun (Praying Mantis Style)
    or Xian Pu (Drunken Style) Kung Fu for the character''s Martial Art Powers;
    one power, chosen once, and the page gives no later pick of a second.
    Stored: the choose 1 over the four powers, unchanged, and the choose 4 over
    the eleven exercises, unchanged. The five later exercise picks are NOT a
    group: a group holds one count for every level it lists
    (BOOK-INGEST-AUDIT.md F116) and an exercise may sit in only one group of a
    class, so four-then-one cannot be stated; they are picked by hand from the
    same list. The chosen power''s later levels are shown on the sheet as text
    since 2026-10-05 (BOOK-INGEST-AUDIT.md F117; display only, nothing a later
    level says is added to the character''s numbers).
    The section''s own lead-in (printed 92, Mystic Body Hardening Notes) sets no
    schedule of its own: it says only that the bonuses work with any martial art
    and that trainers are sadistic when a Demon Queller adds a new exercise, so
    the count and the levels are each class''s. No exercise prints a level table;
    the only thing tied to named levels is Feign Death''s held breath (+1 minute
    at levels 3, 6, 9 and 12, printed 93), and four exercises carry a per-level
    percentage (Feign Death, Hardened Internal Organs, Laugh at Pain, Yung Chin).
  - Hand to Hand: one of Dog Boxing, Eighteen Weapons or Shao-Lin Kung Fu is a
    choose 1 in occ_skills. The page prints no exchange price and offers no other
    style, so hand_to_hand costs is empty (no style sold).
  - Skills: Basic Math -> Mathematics: Basic; Games: Tiao Qi -> Tiao Qi/Chinese
    Checkers; Tracking (humanoids and demons) -> Tracking (people); Lore: Taoist
    Chinese Mythology -> Lore: Chinese Mythology: Taoist. Language: Native
    Chinese 95%, Demongogian 80% and Literacy: Chinese 85% are stored flat at the
    printed figure (JUDGEMENT, as the Adarok stored its printed language figures).
    Calligraphy and Fasting are the RUE rows plus the printed bonus. The military
    choice''s two Armorer lines (traditional Chinese weapons, modern weapons) both
    map to Field Armorer & Munitions Expert, so the list holds it once.
    W.P.s: Battle Axe -> W.P. Axe; Large Sword and Small Sword -> W.P. Sword;
    Spear (Throwing) -> W.P. Spear; Crossbow -> W.P. Cross Bow; Bolt-Action ->
    W.P. Bolt Action Rifle. The catalog holds none of the book''s finer W.P.s.
  - W.P. Demon Snare (Special!) has no catalog row and is not stubbed; it is a
    special ability (JUDGEMENT: no stubs in this batch, and a W.P. carries no
    percentage).
  - Related: five, plus one at 4, 8 and 12. Rogue''s only-list: Card Shark is the
    catalog''s Cardsharp; Find Contraband, Weapons & Cybernetics is Find
    Contraband (filed Military); Gambling is both catalog Gambling rows; Begging
    (Technical), Pick Locks (Espionage) and Prowl (Physical) are cross-category
    and reachable because those categories are granted. Technical''s +15% applies
    to Art, Rope Works, Mythology and Lore only and is a note. Pilot: any except
    military vehicles, robots and power armor, as the precedent except-list.
    Pilot Related: none, omitted.
  - Secondary: three, plus one at 3, 7, 9 and 13, the same limits without
    bonuses.
  - Equipment: Book of Ten Thousand Demons, one of the four Swords of Demon
    Hunting (choose), the Demon Catching Mirror. "Two demon snares" -> two
    china-binding-demon-snare rows (JUDGEMENT; the brief names that row, though
    the class can also braid ordinary snares). Bone and silver S.D.C. weapons ->
    china-bone-swords-and-weapons and knife-silver-plated. Leg irons ->
    leg-manacles x2 and 8 ft of chain. 30 ft rope -> rope-per-foot x30.
    Shoulder bag -> backpack; belt and neck pouch -> multi-purpose-pouch x2.
    The weapons of choice, S.D.C. gun, papers, incense and burner, herbs, tea
    bottle, chopsticks and rice have no row or no fixed choice and are prose in
    Other Demon Queller Equipment. The 5,000 credits of magic items is a
    purchase allowance, not coin, so it is prose and not in starting_money.
  - Secrets and Tricks of the Trade (printed 94-95) are play advice; one
    sentence of the lore paraphrases them.
  - Demonic Entourage''s 1D6 table and the G.M. note are prose.
---

## Lore

The Fu Yao Da Chia, the Great Demon Catching Hero, carries a tradition older than the Coming of the Rifts: a demon hunter''s craft passed from one poor teacher to one or two pupils across thousands of years, kept alive long after the world stopped believing in demons. In Rifts China, with the Yama Kings'' hordes everywhere, the old profession has finally found its moment, and its practitioners are cheered as heroes rather than dismissed as cranks.

What sets the Demon Catcher apart is his goal. Killing a demon is the last resort; the best outcome is a demon bound, humbled and, ideally, rehabilitated. He takes captives into a kind of harsh tutelage, hard labour, discipline, long lectures and, above all, fairness, teaching them trust and a sense of wonder until a few turn toward enlightenment. He has no illusions about how dangerous demons are, and when he is surrounded he fights without mercy.

He knows the enemy better than anyone: their weaknesses, their vanity, their greed and how to bluff, bribe or bully them, the sort of lore that Demon Quellers pass on as secrets and tricks of the trade. His tools are the Wan Gui Yao, a book naming ten thousand demons, a Demon Hunter Sword suited to his own nature, and a Demon Catching Mirror that traps any demon who looks into it, backed by years of brutal body hardening.
',
       updated_at = datetime('now')
 WHERE class_id = 'fu-yao-da-chia'
   AND instr(markdown, 'Mystic Martial Art Power: one of these four. Level 1 abilities only.') > 0
   AND length(markdown) = 27626;

-- == demon-and-dead-slaver ==
UPDATE imported_classes
   SET markdown = '---
id: demon-and-dead-slaver
name: "Demon & Dead Slaver (Nu Li Zhang Wo)"
system: rifts
source_book: Rifts World Book 25: China 2 p.83-86
category: occ
tags: [hunter, combat]
occ_group: men-of-arms
attribute_requirements: { ME: 12 }
sdc_base: "6d6+32"
starting_money: "1d6x1000"
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
psionics:
  isp_base: "M.E. + 3d6, +7 per level of experience"
bonuses:
  attributes: { PS: "1d6", ME: 1, MA: 2 }
  combat: { strike: 2, pull_punch: 3, entangle: 2 }
  saves: { disease: 2, spell_magic: 1, horror_factor: 1, possession: 1 }
  at_level:
    - { level: 2, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 3, saves: { horror_factor: 1, possession: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { horror_factor: 1, curses: 1 } }
    - { level: 5, saves: { possession: 1 } }
    - { level: 6, saves: { curses: 1 } }
    - { level: 7, saves: { possession: 1 } }
    - { level: 8, combat: { initiative: 1 }, saves: { horror_factor: 1, curses: 1 } }
    - { level: 9, saves: { possession: 1 } }
    - { level: 10, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 11, saves: { possession: 1 } }
    - { level: 12, combat: { initiative: 1 }, saves: { horror_factor: 1, curses: 1 } }
    - { level: 13, saves: { possession: 1 } }
    - { level: 14, combat: { initiative: 1 }, saves: { curses: 1 } }
    - { level: 15, saves: { possession: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, tai_chi_ch_uan: 1, dog_boxing_kung_fu_kuo_ch_uan_: 3, drunken_style_kung_fu: 3, shao_lin_kung_fu: 3 } }
  occ_skills:
    - { name: "Camouflage", bonus: 10, note: "Knowledge of Imprisonment & Escape (+10%)." }
    - { name: "Climbing", bonus: 10, note: "Knowledge of Imprisonment & Escape (+10%)." }
    - { name: "Escape Artist", bonus: 20, note: "Knowledge of Imprisonment & Escape (+20%)." }
    - { name: "Pick Locks", bonus: 15, note: "Knowledge of Imprisonment & Escape (+15%)." }
    - { name: "Rope Works", bonus: 20, note: "Knowledge of Imprisonment & Escape (+20%)." }
    - { name: "Trap/Mine Detection", bonus: 10, note: "Knowledge of Imprisonment & Escape (+10%)." }
    - { name: "Mathematics: Basic", bonus: 30, note: "Printed as Basic Math (+30%)." }
    - { name: "Tiao Qi/Chinese Checkers", bonus: 20, note: "Printed as Games: Tiao Qi (+20%). Knows how to cheat or throw a game, at -15% to the base skill." }
    - { name: "Land Navigation", bonus: 10, note: "+10%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Native Chinese, 95%." }
    - { name: "Literacy: Chinese", base: 70, per_level: 0, note: "Chinese characters/ideograms, 70%." }
    - { name: "Radio: Basic", bonus: 10, note: "+10%" }
    - { choose: 3, categories: ["Rogue"], bonus: 5, note: "Rogue: any three (+5%)." }
    - { name: "Tracking (people)", bonus: 10, note: "Printed as Tracking (+10% people, +15% demons); the demon figure is conditional." }
    - { name: "Demon Wrestling", bonus: 5, note: "+5%" }
    - { choose: 3, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming"], note: "Physical: any three; Aerobic Athletics or General Athletics, not both." }
    - { choose: 2, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.: any two. Battle Axe is W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.: any two." }
    - { choose: 2, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.: any two. Spear (Throwing) is W.P. Spear." }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.: any two." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Expert to start. Can be exchanged for Martial Arts, Assassin or Tai Chi at the cost of one O.C.C. Related Skill, or for Dog Boxing Kung Fu, Drunken Style Kung Fu or Shao-Lin Kung Fu at the cost of three." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Horsemanship", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Brewing"], bonus: 5 }
      - "Military"
      - { name: "Physical", except: ["Wrestling"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", bonus: 5, note: "+5%; Find Contraband and Streetwise get a further +10%, recorded here rather than stored." }
      - { name: "Science", only: ["Anthropology", "Biology", "Mathematics: Advanced"], bonus: 5 }
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Sharpshooting"] }
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 8, count: 1 }
      - { level: 11, count: 1 }
      - { level: 14, count: 1 }
    note: "Five at level one, plus one at levels 3, 5, 8, 11 and 14. Pilot Related: none. All new skills start at level one proficiency."
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Brewing"] }
      - "Military"
      - { name: "Physical", except: ["Wrestling"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - "Rogue"
      - { name: "Science", only: ["Anthropology", "Biology", "Mathematics: Advanced"] }
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Sharpshooting"] }
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 11, count: 1 }
      - { level: 13, count: 1 }
    note: "Three at level one, plus one at levels 3, 5, 7, 9, 11 and 13, from the related list and its limits, at the base skill level."
equipment_starting:
  - { item_id: "china-binding-demon-stamp", qty: 1, note: "The Personalized Demon Binding Stamp; yearly dues of 40,000 to 80,000 credits keep it working." }
  - { item_id: "china-binding-chains", qty: 2, note: "Two sets of Binding Chains." }
  - { item_id: "china-binding-demon-snare", qty: 1 }
  - { item_id: "china-binding-demon-choker-snare", qty: 1 }
  - { choose: 2, label: "Green Scarf magic item (any, regardless of cost)", qty: 1, from: ["china-binding-chains", "china-binding-demon-snare", "china-binding-hand-stock", "china-black-cloud-pearl-single-use", "china-fire-pearl", "china-pearl-of-recuperation", "china-pink-cloud-pearl-four-flights", "china-bone-swords-and-weapons", "china-demon-armor-partial-s-d-c", "china-binding-blinders", "china-binding-demon-choker-snare", "china-binding-head-hand-stock", "china-binding-leash-collar", "china-binding-demonic-mirror-of-truth", "china-binding-ivory-faerie-blossom", "china-white-fans-winds-of-submission", "china-black-scarf", "china-pearl-of-demon-strength", "china-pearls-of-knowledge", "china-climbing-scarf", "china-green-yellow-scarf", "china-scarf-of-entrancement", "china-scarf-of-the-python", "china-tigers-claw-club", "china-demon-fighter-sword", "china-monster-slayer-swords-of-the-three-virtuous-ways", "china-demon-armor-environmental-system", "china-demon-armor-full-suit", "china-demon-armor-partial-m-d-c", "china-green-scarf-light-armor", "china-green-scarf-medium-armor", "china-green-scarf-heavy-armor", "china-binding-bell-of-bliss", "china-binding-demon-catching-mirror", "china-black-cloud-pearl-six-uses-a-day", "china-binding-lotus-petal-circle", "china-binding-pipe-of-ling-lun", "china-binding-seal-of-the-green-scarf-celestial-master", "china-phoenix-eye-or-peacock-tail-fan", "china-pink-cloud-pearl-unlimited", "china-scarf-of-demon-binding", "china-viper-scarf-or-silk-vipers", "china-cobras-tooth-dagger", "china-classic-demon-slayer-sword", "china-demon-possessed-slayer-immortal-blade", "china-sword-of-heavenly-light", "china-demon-armor-self-healing-enchantment", "china-sword-of-demon-hunting-the-hunter-blade", "china-sword-of-demon-hunting-the-hunter-slayer-blade", "china-sword-of-demon-hunting-the-demon-hunter-defender", "china-sword-of-demon-hunting-the-demon-hunters-vengeance"] }
  - { item_id: "knife-silver-plated", qty: 1, note: "Silver dagger, 1D6 S.D.C." }
  - { item_id: "china-bone-swords-and-weapons", qty: 1, note: "A club of (non-human) bone, 2D6 S.D.C." }
  - { item_id: "e-clip", qty: 2, note: "For the energy weapon of choice." }
  - { item_id: "traveling-clothes", qty: 1, note: "Sturdy cotton, wool and leather traveling clothes, with hat." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "Heavy winter/mountain over-garments." }
  - { item_id: "clothing", qty: 1, note: "Embroidered silk indoor suit: slippers, pants, shirt, long jacket, scarf and hat." }
  - { item_id: "robe", qty: 1, note: "Silk robe." }
  - { item_id: "book-paper-glued-100-sheets", qty: 2, note: "A 200 page blank book." }
  - { item_id: "pencil", qty: "1d4+2" }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "Small meat cleaver." }
  - { item_id: "backpack", qty: 1, note: "Large traveler''s shoulder bag." }
  - { item_id: "multi-purpose-pouch", qty: 2, note: "A belt pouch and a small neck pouch." }
  - { item_id: "rope", qty: 1, note: "40 feet (12.2 m) of rope." }
  - { item_id: "chain-per-foot-rifts", qty: 10, note: "Two five foot (1.5 m) lengths of chain." }
  - { item_id: "hand-manacles", qty: 2, note: "Manacles for the two lengths of chain." }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-10): Minor Psychic", "Psionics (11-20): Major Psychic, Healing", "Psionics (21-40): Major Psychic, Physical", "Psionics (41-60): Major Psychic, Sensitive", "Psionics (61-80): Master Psychic, Physical and Sensitive", "Psionics (81-90): Master Psychic, Super", "Psionics (91-00): Mind Bleeder"], note: "Every Slaver has some psychic ability: roll percentile or pick one. I.S.P. is M.E. +3D6, +7 per level whatever the tier." }
  - name: "Psionics (01-10): Minor Psychic"
    description: "Two powers from the Healing, Physical or Sensitive categories, +1D4 to M.E. and +2D6+3 I.S.P."
    psionics: { type: "minor", powers_starting: 2, categories_allowed: ["Healing", "Physical", "Sensitive"] }
    bonuses: { attributes: { ME: "1d4" }, pools: { isp: "2d6+3" } }
  - name: "Psionics (11-20): Major Psychic, Healing"
    description: "Eight powers from the Healing category and +2D6 I.S.P."
    psionics: { type: "major", powers_starting: 8, categories_allowed: ["Healing"] }
    bonuses: { pools: { isp: "2d6" } }
  - name: "Psionics (21-40): Major Psychic, Physical"
    description: "Eight powers from the Physical category and +2D4 I.S.P."
    psionics: { type: "major", powers_starting: 8, categories_allowed: ["Physical"] }
    bonuses: { pools: { isp: "2d4" } }
  - name: "Psionics (41-60): Major Psychic, Sensitive"
    description: "Eight powers from the Sensitive category and +1D6+1 I.S.P."
    psionics: { type: "major", powers_starting: 8, categories_allowed: ["Sensitive"] }
    bonuses: { pools: { isp: "1d6+1" } }
  - name: "Psionics (61-80): Master Psychic, Physical and Sensitive"
    description: "Not a Mind Melter. Four Physical, four Sensitive and 1D4+1 Super Psionic powers; the rest of the psychic energy goes into body hardening and resistance to demons and the Dead and Damned. One more Physical or Sensitive power at levels 2, 4, 8, 10, 12 and 14, and one more Super Psionic power at levels 4, 7, 10 and 13."
    psionics:
      type: "master"
      powers_starting: 13
      powers_starting_groups:
        - { count: 4, categories: ["Physical"] }
        - { count: 4, categories: ["Sensitive"] }
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
      powers_schedule:
        - { level: 2, count: 1, categories: ["Physical", "Sensitive"] }
        - { level: 4, count: 1, categories: ["Physical", "Sensitive"] }
        - { level: 8, count: 1, categories: ["Physical", "Sensitive"] }
        - { level: 10, count: 1, categories: ["Physical", "Sensitive"] }
        - { level: 12, count: 1, categories: ["Physical", "Sensitive"] }
        - { level: 14, count: 1, categories: ["Physical", "Sensitive"] }
        - { level: 4, count: 1, categories: ["Super"] }
        - { level: 7, count: 1, categories: ["Super"] }
        - { level: 10, count: 1, categories: ["Super"] }
        - { level: 13, count: 1, categories: ["Super"] }
  - name: "Psionics (81-90): Master Psychic, Super"
    description: "Not a Mind Melter. Two Physical, two Sensitive and 1D4+3 Super Psionic powers; most of the remaining psychic energy goes into body hardening and resistance to demons and the Dead and Damned. One more Super Psionic power at levels 2, 4, 8, 10, 12 and 14, and one Healing power at levels 4, 7 and 11."
    psionics:
      type: "master"
      powers_starting: 11
      powers_starting_groups:
        - { count: 2, categories: ["Physical"] }
        - { count: 2, categories: ["Sensitive"] }
        - { count: 7, categories: ["Super"], note: "Roll 1D4+3 and take that many (up to seven)." }
      powers_schedule:
        - { level: 2, count: 1, categories: ["Super"] }
        - { level: 4, count: 1, categories: ["Super"] }
        - { level: 8, count: 1, categories: ["Super"] }
        - { level: 10, count: 1, categories: ["Super"] }
        - { level: 12, count: 1, categories: ["Super"] }
        - { level: 14, count: 1, categories: ["Super"] }
        - { level: 4, count: 1, categories: ["Healing"] }
        - { level: 7, count: 1, categories: ["Healing"] }
        - { level: 11, count: 1, categories: ["Healing"] }
  - name: "Psionics (91-00): Mind Bleeder"
    description: "A Mind Bleeder human mutant, or simply has 1D4+2 Mind Bleeder powers at level one. One more Mind Bleeder power at levels 3, 6, 9, 12 and 15, and one Super Psionic power at levels 4, 7, 10 and 13."
    psionics:
      type: "master"
      powers_starting: 6
      powers_starting_groups:
        - { count: 6, categories: ["Mind Bleeder"], note: "Roll 1D4+2 and take that many (up to six)." }
      powers_schedule:
        - { level: 3, count: 1, categories: ["Mind Bleeder"] }
        - { level: 6, count: 1, categories: ["Mind Bleeder"] }
        - { level: 9, count: 1, categories: ["Mind Bleeder"] }
        - { level: 12, count: 1, categories: ["Mind Bleeder"] }
        - { level: 15, count: 1, categories: ["Mind Bleeder"] }
        - { level: 4, count: 1, categories: ["Super"] }
        - { level: 7, count: 1, categories: ["Super"] }
        - { level: 10, count: 1, categories: ["Super"] }
        - { level: 13, count: 1, categories: ["Super"] }
  - { choose: 2, from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Vital Breath", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: two to start (printed 84). One more at each of levels 4, 8 and 12 is picked by hand from this same list, because one group holds one count for every level and the page gives two at creation and one at each later level." }
  - name: "Body Hardening: Control Revulsion"
    description: "Trained by exposure to gore and filth: +3 to save vs Horror Factor and vs the vomit and gag response to terrible smells, slime, blood and gore. (printed 92.)"
    bonuses: { saves: { horror_factor: 3 } }
  - name: "Body Hardening: Demon Digestion"
    description: "Can eat nearly anything, belch, retch or rumble at will (a gross-out Horror Factor 13 at worst), senses poison in the system and expels it in 10 minutes to 2 hours. +1 P.E.; damage, penalties and duration of poisons and drugs are halved. (printed 92.)"
    bonuses: { attributes: { PE: 1 } }
  - name: "Body Hardening: Dislocation Training"
    description: "Joints deliberately dislocated in training: +2 to save vs pain, +1 P.E., +1 to roll with impact, +5% to Escape Artist if the character has it, and +2D6+12 S.D.C. (rolled by the player, not applied). (printed 92.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 2 }, combat: { roll: 1 } }
  - name: "Body Hardening: Feign Death"
    description: "Plays dead convincingly: +2 to save vs pain, +10 S.D.C., +5% vs coma/death, +1 vs Horror Factor; holds breath five minutes, +1 minute at levels 3, 6, 9 and 12. Feign death or coma 40% +4% per level (+10% against a simple examination). (printed 93.)"
    bonuses: { saves: { pain: 2, horror_factor: 1, coma_death_pct: 5 }, pools: { sdc: 10 } }
    progression:
      - { level: 3, text: "Holds breath for six minutes." }
      - { level: 6, text: "Holds breath for seven minutes." }
      - { level: 9, text: "Holds breath for eight minutes." }
      - { level: 12, text: "Holds breath for nine minutes." }
  - name: "Body Hardening: Hardened Internal Organs"
    description: "Moves vital organs out of a blade''s path: a successful roll (40% +4% per level) holds the hit point damage of a piercing wound it can anticipate to 1 point (S.D.C. damage is taken normally). +1 P.E., +1 to save vs pain, and recovers hit points and S.D.C. twice as fast. (printed 93.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 1 } }
  - name: "Body Hardening: Heal Internal Organs and Injury"
    description: "Healing meditation: restores 1D6 hit points an hour, up to a third of the total (25% of M.D.C. for a mega-damage being), stops bleeding in 2D4 melee rounds; +10% vs coma/death. (printed 93.)"
    bonuses: { saves: { coma_death_pct: 10 } }
  - name: "Body Hardening: Laugh at Pain"
    description: "The Lau Re maneuver: +2 to save vs pain, +1 M.E., M.A. and P.E., +5% vs coma/death, and +8% (+2% per level) to intimidate when showing off pain resistance; the skill is 50% +4% per level and scares ordinary people as Horror Factor 13. (printed 93.)"
    bonuses: { attributes: { ME: 1, MA: 1, PE: 1 }, saves: { pain: 2, coma_death_pct: 5 } }
  - name: "Body Hardening: Life Stone"
    description: "A stone fused beside the heart makes the character a minor mega-damage being with 1D6+6 M.D.C. that is always there and is lost before S.D.C. (attacks direct to hit points bypass it); +1 to roll with impact, +5% vs coma/death and +4D6 S.D.C. (both dice rolled by the player, not applied). (printed 93.)"
    bonuses: { saves: { coma_death_pct: 5 }, combat: { roll: 1 } }
  - name: "Body Hardening: Resist Psychic Drain"
    description: "Fatigues at half the normal rate; +2 to save vs possession and psychic drain, +1 vs Demonic Curses, magic vapors and breath attacks, and magic illness. (printed 93.)"
    bonuses: { saves: { possession: 2, curses: 1 } }
  - name: "Body Hardening: Vital Breath"
    description: "Senses foul air and holds breath at once: +2 to save vs breath attacks, gases, poisoned air and sudden loss of pressure, +2 initiative to hold breath in time, three extra minutes of held breath, and can share air. (printed 93.)"
    bonuses: { saves: { other: [ { label: "vs breath attacks, gases and poisoned air", bonus: 2 } ] } }
  - name: "Body Hardening: Yung Chin (Eternal Clarity)"
    description: "Resists alcohol at +20% (+4% per level) and suffers half the penalties of drunkenness (-2 initiative, -1 strike, parry and dodge, Spd down one quarter, skills down 6%). (printed 94.)"
  - name: "Undead Entrepreneur"
    description: "Has no love for the Yama Kings and no hatred either: they are a market. The Slaver aims to thin the ranks of the Yama Kings'' servants, wreck their ability to make war or meddle with the Free Lands, and give the poor an even break when that can be combined with gathering product."
  - name: "Personalized Demon Binding Stamp"
    description: "The prized magic stamp marks a demon, binds it to the mortal plane and to the Slaver, and makes it docile and manageable, something like a draft animal or a pet. Unless renewal dues of 40,000 to 80,000 credits a year (by the number and type of slaves collected) are paid to the Green Scarf Taoists it becomes a paperweight."
  - name: "Green Scarf Business Relationship"
    description: "Starts with a running account of 20,000 credits at the Green Scarf Sect''s bank in Kunming, Free Yunnan, reserved for the stamp''s dues and other annual fees and not available as cash. The Sect buys his demon slaves at 60% less than retail and gets first pick; no account means no business at all."
  - name: "Docile Demonic Slave"
    description: "Usually has a stamped, docile Lesser Demon at his side as a porter. Its mind is so empty it can only fetch and carry, do simple chores, and stand guard, howling or growling at danger."
  - name: "W.P. Demon Snare"
    description: "A special proficiency used only to entrap: a snare catches an opponent''s neck, wrist or ankle, cannot parry and does no damage on impact, but pinches and gouges as it tightens, hurting susceptible demons. Includes braiding snares from string, rope, cloth or leather."
  - name: "Other Starting Gear"
    description: "Also starts with two other traditional Chinese weapons of choice (3D6 rounds for each projectile weapon, half may be silver coated), one energy weapon of choice, identification documents including a Yama Kingdom passport and letters of recommendation, herbs, a tea bottle, two sets of chopsticks and 30 cups of uncooked rice."
restrictions:
  - "Cybernetics: none."
trackable_resources: []
extraction_notes: |
  - Printed 83-86 (cache p084-p087). Every number read off a 200 dpi render.
    Filed under the Demon Quellers heading (printed 77, Rifts China Demon
    Queller O.C.C.s), men-of-arms (occ_group) per the brief. S.D.C. is printed
    (6D6+32), so no men_of_arms line.
  - Name: Demon & Dead Slaver O.C.C., Nu Li Zhang Wo; also Slaver and Green
    Scarf Lap Dog.
  - xp_table: the Demon & Dead Slaver column, printed 160 (cache p161), read off
    a render; lower bounds stored.
  - attribute_requirements: "M.E. should be above 11" -> ME 12 (JUDGEMENT);
    high P.S., P.P. and P.E. are helpful only.
  - Psionics (printed 84-85): roll or pick one of seven bands, stored as a
    choose 1 whose option names carry the bands so the wizard can roll. The
    class block states only the I.S.P. formula, M.E. +3D6, +7 per level for
    every tier; each option carries its own tier, powers and I.S.P. bonus.
    Super Psionic counts printed as dice (1D4+1, 1D4+3, Mind Bleeder 1D4+2) are
    stored at the maximum because a count is a number, with the roll in the
    group note (JUDGEMENT, the Anti-Monster secondary-skill precedent). The
    Mind Bleeder band is stored as a master psionic (JUDGEMENT; the book names
    no tier, and the Mind Bleeder is a master psychic in the core rules). Its
    "or just happens to have" alternative is the same picks.
  - Bonuses: +1D6 P.S., +1 M.E., +2 M.A.; +2 strike, +3 pull punch, +2 entangle;
    +2 vs disease; +1 vs magic (spell_magic only, the Anti-Monster precedent);
    +1 initiative at 2, 4, 8, 10, 12 and 14; +1 vs Horror Factor at 1, 3, 4, 8
    and 12; +1 vs possession at 1, 3, 5, 7, 9, 11, 13 and 15; +1 vs Demonic
    Curses (the curses save) at 2, 4, 6, 8, 10, 12 and 14.
  - Mystic Body Hardening Exercises (printed 92-94): two to start, then one at
    levels 4, 8 and 12 (printed 84). The level-1 picks are a choose 2 over the
    shared block; the later picks are made by hand from the same list (see the
    2026-10-05 note). The Slaver takes no Mystic Martial Art Power.
  - 2026-10-05, re-read off renders of printed 84-85 and 92-94. Printed 84, item
    4 (Demon Hunter Body Hardening Exercises): select two Demon Queller Body
    Hardening Exercises to start, then one additional at levels 4, 8 and 12.
    The page''s eight numbered items (Undead Entrepreneur, the Binding Stamp,
    Green Scarf gear, Body Hardening, Psionics, Docile Demonic Slave, O.C.C.
    Bonuses, Base S.D.C.) give the Slaver NO Mystic Martial Art Power, so there
    is no power level table to show and nothing of that kind is missing. The
    only other picks at set levels are the psionic powers of the three highest
    bands of item 5, already stored as each option''s powers_schedule. Stored:
    the choose 2 over the eleven exercises, unchanged. The three later exercise
    picks are NOT a group: a group holds one count for every level it lists
    (BOOK-INGEST-AUDIT.md F116) and an exercise may sit in only one group of a
    class, so two-then-one cannot be stated; they are picked by hand from the
    same list.
    The section''s own lead-in (printed 92, Mystic Body Hardening Notes) sets no
    schedule of its own: it says only that the bonuses work with any martial art
    and that trainers are sadistic when a Demon Queller adds a new exercise, so
    the count and the levels are each class''s. No exercise prints a level table;
    the only thing tied to named levels is Feign Death''s held breath (+1 minute
    at levels 3, 6, 9 and 12, printed 93), and four exercises carry a per-level
    percentage (Feign Death, Hardened Internal Organs, Laugh at Pain, Yung Chin).
  - Hand to Hand: Expert. Martial Arts, Assassin or Tai Chi (the catalog''s
    Hand to Hand: Tai-Chi Ch''uan, key tai_chi_ch_uan) for one related skill;
    Dog Boxing, Drunken Style or Shao-Lin Kung Fu for three. Keys as styleKey()
    computes them.
  - Knowledge of Imprisonment & Escape: Camouflage +10, Climbing +10, Escape
    Artist +20, Pick Locks +15, Rope Works +20, Trap/Mine Detection +10, stored
    as O.C.C. skills. Climbing also sits in the Physical choose; a duplicate
    pick is the player''s to avoid.
  - Skills: Basic Math -> Mathematics: Basic (+30); Games: Tiao Qi -> Tiao
    Qi/Chinese Checkers (+20); Tracking -> Tracking (people) +10, the +15 vs
    demons is conditional and in the note. Language: Native Chinese 95% and
    Literacy: Chinese 70% stored flat at the printed figure (JUDGEMENT).
    Rogue any three (+5%) is a category choose. W.P.s map as for the Fu Yao Da
    Chia: Battle Axe -> W.P. Axe, Large/Small Sword -> W.P. Sword, Spear
    (Throwing) -> W.P. Spear.
  - W.P. Demon Snare has no catalog row and is not stubbed; it is a special
    ability (JUDGEMENT).
  - Related: five, plus one at 3, 5, 8, 11 and 14. Medical: First Aid and
    Brewing only (+5%); Physical: any except conventional Wrestling; Rogue +5%,
    with a further +10% to Find Contraband and Streetwise only, which is a note
    (Find Contraband is filed Military, so a bonus there is not expressible on
    the Rogue entry); Science: Anthropology, Biology and Math: Advanced only
    (+5%). Pilot Related: none, omitted.
  - Secondary: three, plus one at 3, 5, 7, 9, 11 and 13; the same limits without
    bonuses.
  - Equipment: the Binding Demon Stamp, two Binding Chains, one Demon Snare and
    one Choker Snare are the catalog''s Green Scarf rows. "Any two Green Scarf
    magic items regardless of cost" is a choose 2 over every gear row this book
    files on printed 102-114 except the stamp itself and the Fake Demon Catching
    Mirror (not magic). Silver dagger -> knife-silver-plated; bone club ->
    china-bone-swords-and-weapons; 200 page blank book -> two 100-sheet books;
    40 ft rope -> rope (40 ft row); two five foot chains and manacles -> 10 ft
    of chain and two hand-manacles. Weapons of choice, papers, herbs, tea
    bottle, chopsticks and rice are prose.
  - Stamp dues: printed 84 says 40,000 to 80,000 credits a year; the gear row
    records that printed 103 says 40,000 to 120,000. The class page is followed.
  - The 20,000 credit running account is not cash and is not in starting_money.
  - Secrets and Tricks of the Trade (printed 94-95) are play advice; one
    sentence of the lore paraphrases them.
---

## Lore

The Nu Li Zhang Wo, the Demon & Dead Slaver, is a businessman first. Killing a demon in Rifts China only sends it back to its Yama King to fight again, so the Slaver catches demons and the Dead and Damned instead, stamps them with a magical brand that cuts them off from their masters and leaves them meek, and sells them as labour. In his own telling he is no monster: his product is not people, and every demon hauling a plough is one less in the Yama Kings'' armies and one more pair of hands for the hard-pressed Free Lands.

His trade ties him to the Green Scarf Taoist Sect of Free Yunnan, which makes his stamp, sells him his gear, buys his catch at a steep discount and keeps his account. Without them he has no business, and other demon hunters despise him as the Green Scarves'' lap dog. Slavers are a rough, often shady lot, many of them out-of-work D-Bees with debts to pay, and they learn to slip chains and locks as readily as they apply them.

Like every Demon Queller he trains his body to endure demonic filth and fury, carries some psychic gift, and knows the demons'' vanity, greed and weak spots as the tricks of his trade.
',
       updated_at = datetime('now')
 WHERE class_id = 'demon-and-dead-slaver'
   AND instr(markdown, 'and F117 (later levels). The Slaver takes no Mystic Martial Art Power.') > 0
   AND length(markdown) = 29253;

-- == goblin-wrangler ==
UPDATE imported_classes
   SET markdown = '---
id: goblin-wrangler
name: "Goblin Wrangler (Mo Di Mu Yang)"
system: rifts
source_book: Rifts World Book 25: China 2 p.86-91
category: occ
tags: [hunter, leader, combat]
occ_group: men-of-arms
attribute_requirements: { IQ: 12, MA: 12 }
sdc_base: "5d6+24"
starting_money: "5d6x100"
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 94401, 129601, 179801, 230001, 280201, 332401]
psionics:
  isp_base: "M.E. + 3d6, +5 per level of experience"
bonuses:
  attributes: { PS: 2, PE: 1, PP: 1, PB: 1 }
  combat: { strike: 1, pull_punch: 2, disarm: 2 }
  saves: { spell_magic: 1, curses: 2, horror_factor: 2, possession: 1 }
  at_level:
    - { level: 3, saves: { possession: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { possession: 1 } }
    - { level: 5, saves: { possession: 1 } }
    - { level: 7, saves: { possession: 1 } }
    - { level: 8, combat: { initiative: 1 } }
    - { level: 9, saves: { possession: 1 } }
    - { level: 11, saves: { possession: 1 } }
    - { level: 12, combat: { initiative: 1 } }
    - { level: 13, saves: { possession: 1 } }
    - { level: 15, saves: { possession: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Anthropology", bonus: 10, note: "+10%" }
    - { name: "Mathematics: Basic", bonus: 20, note: "Printed as Basic Math (+20%)." }
    - { name: "Calligraphy", bonus: 15, note: "+15%" }
    - { name: "Imperial Bureaucracy & Administration", bonus: 5, note: "+5%" }
    - { name: "Intelligence", bonus: 14, note: "+14%" }
    - { name: "Interrogation", bonus: 5, note: "+5% for all; +20% instead on Goblins and Lesser Demons." }
    - { name: "Land Navigation", bonus: 10, note: "+10%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Native Chinese speaker, 95%." }
    - { name: "Literacy: Chinese", base: 85, per_level: 0, note: "Chinese characters/ideograms, 85%." }
    - { choose: 2, from: ["Literacy: Ancient & Classical Chinese", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Taoist", "Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Feng Shui/Geomancy"], bonus: 15, note: "Lore: any two (+15% each)." }
    - { name: "Meditation", base: 0, per_level: 0 }
    - { name: "Performance", bonus: 20, note: "+20%" }
    - { name: "Radio: Basic", bonus: 10, note: "+10%" }
    - { name: "Seduction", bonus: 5, note: "+5% for all; +16% instead on Goblins and Lesser Demons." }
    - { name: "Sing", bonus: 10, note: "+10%" }
    - { name: "Surveillance", base: 30, per_level: 5, note: "Printed as Surveillance Systems (+20% to Tailing only); the bonus is conditional and not stored." }
    - { name: "Demon Wrestling", base: 30, per_level: 5, note: "No bonus printed; catalog base." }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming", "Wrestling"], note: "Physical: any two; Aerobic Athletics or General Athletics, not both." }
    - { choose: 2, from: ["W.P. Axe", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Siege Weapons", "W.P. Spear", "W.P. Sword", "W.P. Trident"], note: "Traditional Chinese battlefield W.P.: any two. Battle Axe is W.P. Axe; Large Sword and Small Sword are both W.P. Sword." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Chain", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff", "W.P. Whip"], note: "Traditional Chinese makeshift or peasant W.P.: any two." }
    - { choose: 2, from: ["W.P. Bow", "W.P. Cross Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear"], note: "Traditional Chinese projectile W.P.: any two. Spear (Throwing) is W.P. Spear." }
    - { choose: 2, from: ["W.P. Automatic Pistol", "W.P. Bolt Action Rifle", "W.P. Automatic and Semi-automatic Rifles", "W.P. Energy Pistol", "W.P. Energy Rifle"], note: "Modern W.P.: any two." }
    - { name: "W.P. Gien Bian (Steel Whip)", base: 0, per_level: 0, note: "Automatic; the chi-trained character can make it a mega-damage weapon." }
    - { choose: 1, from: ["Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Eighteen Weapons Kung Fu (Shih Ba Ban Wu Yi)", "Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Shao-Lin Kung Fu"], note: "Select one as the basis of the character''s combat skills. No other style is offered." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - "Horsemanship"
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"], bonus: 10 }
      - { name: "Military", only: ["Camouflage", "Military Etiquette", "Recognize Weapon Quality", "Trap/Mine Detection"], bonus: 5 }
      - { name: "Physical", except: ["Wrestling"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - { name: "Rogue", note: "Any, but used for a good end against villains." }
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Harpoon & Spear Gun", "W.P. Torpedo", "W.P. Sharpshooting"] }
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
    note: "Five at level one, plus two at levels 4, 8 and 12. Pilot Related: none. All new skills start at level one proficiency."
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
      - { name: "Military", only: ["Camouflage", "Military Etiquette", "Recognize Weapon Quality", "Trap/Mine Detection"] }
      - { name: "Physical", except: ["Wrestling"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Warships & Patrol Boats", "Military: Tanks & APCs"] }
      - "Rogue"
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Harpoon & Spear Gun", "W.P. Torpedo", "W.P. Sharpshooting"] }
      - "Wilderness"
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
    note: "Three at level one, plus one at levels 3, 7, 9 and 13, from the related list and its limits, at the base skill level."
equipment_starting:
  - { choose: 1, label: "Demon Hunter Sword", qty: 1, from: ["china-sword-of-demon-hunting-the-hunter-blade", "china-sword-of-demon-hunting-the-hunter-slayer-blade", "china-sword-of-demon-hunting-the-demon-hunter-defender", "china-sword-of-demon-hunting-the-demon-hunters-vengeance"], note: "The Demon Hunter''s Vengeance is found among only 10% of Goblin Wranglers." }
  - { choose: 1, label: "Green Scarf magic item worth under 10,000 credits", qty: 1, from: ["china-binding-chains", "china-binding-demon-snare", "china-binding-hand-stock", "china-black-cloud-pearl-single-use", "china-fire-pearl", "china-pearl-of-recuperation", "china-pink-cloud-pearl-four-flights", "china-bone-swords-and-weapons", "china-demon-armor-partial-s-d-c"] }
  - { choose: 1, label: "Green Scarf magic item worth 10,000 to 50,000 credits", qty: 1, from: ["china-binding-blinders", "china-binding-demon-choker-snare", "china-binding-head-hand-stock", "china-binding-leash-collar", "china-binding-demonic-mirror-of-truth", "china-binding-ivory-faerie-blossom", "china-white-fans-winds-of-submission", "china-black-scarf", "china-pearl-of-demon-strength", "china-pearls-of-knowledge", "china-climbing-scarf", "china-green-yellow-scarf", "china-scarf-of-entrancement", "china-scarf-of-the-python", "china-tigers-claw-club", "china-demon-fighter-sword", "china-monster-slayer-swords-of-the-three-virtuous-ways", "china-demon-armor-environmental-system", "china-demon-armor-full-suit", "china-demon-armor-partial-m-d-c", "china-green-scarf-light-armor", "china-green-scarf-medium-armor", "china-green-scarf-heavy-armor"] }
  - { item_id: "china-bone-swords-and-weapons", qty: 1, note: "One S.D.C. weapon of bone: typically a knife (1D6) or a short sword or club (2D4)." }
  - { item_id: "knife-silver-plated", qty: 1, note: "One S.D.C. weapon of silver: typically a knife (1D6) or a short sword or club (2D4)." }
  - { item_id: "e-clip", qty: 2, note: "For the energy weapon of choice." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged cotton, wool and leather traveling clothes, with hat." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "Heavy winter/mountain over-garments." }
  - { item_id: "clothing", qty: 1, note: "Embroidered silk indoor suit: slippers, pants, shirt, long jacket, scarf and hat." }
  - { item_id: "robe", qty: 1, note: "Silk robe." }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "Blank book of 3D6x10 pages." }
  - { item_id: "pencil", qty: "1d4+1" }
  - { item_id: "paper-dz-9x12-inch-sheets", qty: 1, note: "4D6 sheets of blank paper." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block." }
  - { item_id: "brushes-low-quality", qty: 1, note: "Bamboo brushes." }
  - { item_id: "disposable-lighter-or-box-of-200-matches", qty: 1, note: "Fire starter kit or cigarette lighter." }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4", note: "Scented candles." }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "meat-cleaver", qty: 1, note: "Small meat cleaver." }
  - { item_id: "backpack", qty: 1, note: "Large traveler''s shoulder bag." }
  - { item_id: "multi-purpose-pouch", qty: 2, note: "A belt pouch and a small neck pouch." }
  - { item_id: "rope-per-foot", qty: 30, note: "30 feet (9.1 m) of rope." }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - { choose: 1, from: ["Body Hardening: Vital Breath"], note: "Every Goblin Wrangler starts with Vital Breath (granted outright, printed 90)." }
  - { choose: 2, from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: two more to start (printed 90). One more at each of levels 3, 6, 9, 12 and 15 is picked by hand from this same list, because one group holds one count for every level and the page gives two at creation and one at each later level." }
  - name: "Body Hardening: Control Revulsion"
    description: "Trained by exposure to gore and filth: +3 to save vs Horror Factor and vs the vomit and gag response to terrible smells, slime, blood and gore. (printed 92.)"
    bonuses: { saves: { horror_factor: 3 } }
  - name: "Body Hardening: Demon Digestion"
    description: "Can eat nearly anything, belch, retch or rumble at will (a gross-out Horror Factor 13 at worst), senses poison in the system and expels it in 10 minutes to 2 hours. +1 P.E.; damage, penalties and duration of poisons and drugs are halved. (printed 92.)"
    bonuses: { attributes: { PE: 1 } }
  - name: "Body Hardening: Dislocation Training"
    description: "Joints deliberately dislocated in training: +2 to save vs pain, +1 P.E., +1 to roll with impact, +5% to Escape Artist if the character has it, and +2D6+12 S.D.C. (rolled by the player, not applied). (printed 92.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 2 }, combat: { roll: 1 } }
  - name: "Body Hardening: Feign Death"
    description: "Plays dead convincingly: +2 to save vs pain, +10 S.D.C., +5% vs coma/death, +1 vs Horror Factor; holds breath five minutes, +1 minute at levels 3, 6, 9 and 12. Feign death or coma 40% +4% per level (+10% against a simple examination). (printed 93.)"
    bonuses: { saves: { pain: 2, horror_factor: 1, coma_death_pct: 5 }, pools: { sdc: 10 } }
    progression:
      - { level: 3, text: "Holds breath for six minutes." }
      - { level: 6, text: "Holds breath for seven minutes." }
      - { level: 9, text: "Holds breath for eight minutes." }
      - { level: 12, text: "Holds breath for nine minutes." }
  - name: "Body Hardening: Hardened Internal Organs"
    description: "Moves vital organs out of a blade''s path: a successful roll (40% +4% per level) holds the hit point damage of a piercing wound it can anticipate to 1 point (S.D.C. damage is taken normally). +1 P.E., +1 to save vs pain, and recovers hit points and S.D.C. twice as fast. (printed 93.)"
    bonuses: { attributes: { PE: 1 }, saves: { pain: 1 } }
  - name: "Body Hardening: Heal Internal Organs and Injury"
    description: "Healing meditation: restores 1D6 hit points an hour, up to a third of the total (25% of M.D.C. for a mega-damage being), stops bleeding in 2D4 melee rounds; +10% vs coma/death. (printed 93.)"
    bonuses: { saves: { coma_death_pct: 10 } }
  - name: "Body Hardening: Laugh at Pain"
    description: "The Lau Re maneuver: +2 to save vs pain, +1 M.E., M.A. and P.E., +5% vs coma/death, and +8% (+2% per level) to intimidate when showing off pain resistance; the skill is 50% +4% per level and scares ordinary people as Horror Factor 13. (printed 93.)"
    bonuses: { attributes: { ME: 1, MA: 1, PE: 1 }, saves: { pain: 2, coma_death_pct: 5 } }
  - name: "Body Hardening: Life Stone"
    description: "A stone fused beside the heart makes the character a minor mega-damage being with 1D6+6 M.D.C. that is always there and is lost before S.D.C. (attacks direct to hit points bypass it); +1 to roll with impact, +5% vs coma/death and +4D6 S.D.C. (both dice rolled by the player, not applied). (printed 93.)"
    bonuses: { saves: { coma_death_pct: 5 }, combat: { roll: 1 } }
  - name: "Body Hardening: Resist Psychic Drain"
    description: "Fatigues at half the normal rate; +2 to save vs possession and psychic drain, +1 vs Demonic Curses, magic vapors and breath attacks, and magic illness. (printed 93.)"
    bonuses: { saves: { possession: 2, curses: 1 } }
  - name: "Body Hardening: Vital Breath"
    description: "Senses foul air and holds breath at once: +2 to save vs breath attacks, gases, poisoned air and sudden loss of pressure, +2 initiative to hold breath in time, three extra minutes of held breath, and can share air. (printed 93.)"
    bonuses: { saves: { other: [ { label: "vs breath attacks, gases and poisoned air", bonus: 2 } ] } }
  - name: "Body Hardening: Yung Chin (Eternal Clarity)"
    description: "Resists alcohol at +20% (+4% per level) and suffers half the penalties of drunkenness (-2 initiative, -1 strike, parry and dodge, Spd down one quarter, skills down 6%). (printed 94.)"
  - name: "Rapport and Influence with Goblins and Lesser Demons"
    description: "Understands how Goblins and, to a lesser degree, Lesser Demons think and what they want, and how to approach and manipulate them without hostility: part exterminator, part con artist, part behavioural therapist. Increased Trust and Charm: +10 to M.A. and P.B. as seen by Goblins and Lesser Demons only (including most simple nature spirits), letting him calmly talk to them singly or in groups without raising alarm. The best Wranglers never lie outright and never cheat, rob or capture Goblins for profit."
  - name: "Goblin Songs"
    description: "Knows and sings a wide range of Goblin and Lesser Demon songs, calming Goblins and some demons as he approaches, and reads the songs sung back to judge their type and number, their mood, and their health and temper, including wounds and whether they serve a higher power and like it."
  - name: "Deals with Lesser Evil"
    description: "Knows he is not built to take on major demons alone, but understands local infernals and how a motivated group of ordinary people can beat a powerful one. Aims to deal with the bad eggs among Goblins and other wild races and help communities cope, keep the Yama Kings from expanding, and help those the Celestial Court appoints against them."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Can gather and direct chi, even in very weak P.P.E. environments, to give otherwise ordinary weapons mega-damage. Comes with W.P. Gien Bian (Steel Whip), a favoured weapon for entrapping demons."
  - name: "Powers of Meditation"
    description: "The character''s inner strength is given over to meditation and sensing chi, so he never gains psionic powers beyond using the Steel Whip as a mega-damage weapon; I.S.P. is M.E. +3D6, +5 per level. Skilled in Meditation."
  - name: "Fees and Other Starting Gear"
    description: "Usually charges 300-1000 credits for each Goblin or Lesser Demon removed, plus room and board for the job, and often works for trade or on the cheap. Also starts with four other traditional Chinese weapons of choice (3D6 rounds for each projectile weapon, half may be silver coated), one S.D.C. gun with 100 rounds (half silver coated), one energy weapon of choice, identification documents including a Yama Kingdom passport and letters of recommendation, 2D6+2 pieces of incense and a small incense burner, herbs, a tea bottle, two sets of chopsticks and 30 cups of uncooked rice. Knows of the Green Scarf Sect''s goods but need not be affiliated with it, and dislikes Slavers and fanatics."
restrictions:
  - "Cybernetics: none."
  - "Never gains psionic powers beyond using the Steel Whip as a mega-damage weapon."
trackable_resources: []
extraction_notes: |
  - Printed 86-91 (cache p087-p092). Every number read off a 200 dpi render.
    Filed under the Demon Quellers heading (printed 77, Rifts China Demon
    Queller O.C.C.s), men-of-arms (occ_group) per the brief. S.D.C. is printed
    (5D6+24), so no men_of_arms line.
  - Name: Goblin Wrangler O.C.C., Mo Di Mu Yang; also Demon Talker.
  - xp_table: the Goblin Wrangler / Geofront Metal Warrior / Whack Job
    Scientist column, printed 160 (cache p161), read off a render; lower bounds
    stored.
  - attribute_requirements: "I.Q. and M.A. should be above 11" -> IQ 12, MA 12
    (JUDGEMENT); high M.E., P.P. and P.E. are helpful only.
  - I.S.P.: M.E. +3D6, +5 per level; no psionic powers beyond the Steel Whip''s
    mega-damage, so psionics states only isp_base. No Mystic Martial Art Power.
  - Bonuses: +2 P.S., +1 P.E., P.P. and P.B.; +1 strike, +2 pull punch, +2
    disarm; +1 vs magic (spell_magic only, the Anti-Monster precedent); +2 vs
    Demonic Curses (curses); +2 vs Horror Factor; +1 initiative at 4, 8 and 12;
    +1 vs possession at 1, 3, 4, 5, 7, 9, 11, 13 and 15, as printed. The +10
    M.A. and P.B. with Goblins and Lesser Demons is conditional and is prose.
  - Mystic Body Hardening Exercises (printed 92-94): Vital Breath plus two
    others to start, then one at levels 3, 6, 9, 12 and 15 (printed 90). Vital
    Breath is a choose 1 with one option so the shared entry''s bonus applies; the
    other two are a choose 2 over the remaining ten. The later picks are made by
    hand from the same list (see the 2026-10-05 note).
  - 2026-10-05, re-read off renders of printed 89-90 and 92-94. Printed 90, item
    4 (Demon Hunter Body Hardening Exercises): start with Vital Breath, select
    another two Demon Queller Body Hardening Exercises to start, then one
    additional at levels 3, 6, 9, 12 and 15. The page''s eleven numbered items
    give the Wrangler NO Mystic Martial Art Power (item 9: no psionic powers
    beyond using the Steel Whip as a mega-damage weapon), and nothing else is
    picked at set levels apart from skills. Stored: Vital Breath as a
    one-option choose 1 and a choose 2 over the other ten, both unchanged. The
    five later exercise picks are NOT a group: a group holds one count for
    every level it lists (BOOK-INGEST-AUDIT.md F116) and an exercise may sit in
    only one group of a class, so two-then-one cannot be stated; they are
    picked by hand from the same list.
    The section''s own lead-in (printed 92, Mystic Body Hardening Notes) sets no
    schedule of its own: it says only that the bonuses work with any martial art
    and that trainers are sadistic when a Demon Queller adds a new exercise, so
    the count and the levels are each class''s. No exercise prints a level table;
    the only thing tied to named levels is Feign Death''s held breath (+1 minute
    at levels 3, 6, 9 and 12, printed 93), and four exercises carry a per-level
    percentage (Feign Death, Hardened Internal Organs, Laugh at Pain, Yung Chin).
  - Hand to Hand: one of Dog Boxing, Drunken Style, Eighteen Weapons, Monkey
    Style or Shao-Lin Kung Fu is a choose 1; no price and no other style, so
    hand_to_hand costs is empty.
  - Skills: Basic Math -> Mathematics: Basic; Interrogation and Seduction store
    the +5% for all, the +20%/+16% on Goblins and Lesser Demons being
    conditional; Surveillance Systems -> Surveillance with its Tailing-only +20%
    in the note; Lore: Faerie -> Lore: Faeries & Creatures of Magic; Lore:
    Chinese Mythology: Taoist as printed. Language: Native Chinese 95% and
    Literacy: Chinese 85% stored flat at the printed figure (JUDGEMENT).
    Physical choose two includes Wrestling as printed here, though the related
    list excludes it. W.P.s map as for the Fu Yao Da Chia.
  - Related: five, plus TWO at levels 4, 8 and 12 (printed 91). Medical: First
    Aid only (+10%); Military: Camouflage, Military Etiquette, Recognize Weapon
    Quality and Trap/Mine Detection only (+5%); Physical: any except Wrestling;
    Rogue: any; W.P.: any except Harpoon (the catalog''s W.P. Harpoon & Spear
    Gun), Torpedo and Sharpshooting. Pilot Related: none, omitted.
  - Secondary: three, plus one at 3, 7, 9 and 13; the same limits without
    bonuses.
  - Equipment: one of the four Swords of Demon Hunting (printed 90 gives a
    replacement cost of 500,000 to 2 million, against 650,000 on printed 80).
    The two Green Scarf items are choose 1 groups split by the gear rows'' stored
    cost (under 10,000; 10,000 to 50,000) over the rows this book files on
    printed 102-114, the Fake Demon Catching Mirror left out as not magic
    (JUDGEMENT: the split uses the catalog cost, not a re-read of 102-114).
    Bone and silver S.D.C. weapons, 30 ft rope, bag and pouches map as for the
    Fu Yao Da Chia. Weapons of choice, the S.D.C. gun, papers, incense and
    burner, herbs, tea bottle, chopsticks and rice are prose.
  - Money: 5D6x100 credits; fees of 300-1000 credits a head and room and board
    are prose.
  - Secrets and Tricks of the Trade (printed 94-95) are play advice; one
    sentence of the lore paraphrases them.
---

## Lore

The Mo Di Mu Yang, the Goblin Wrangler, is the Demon Queller as consultant. Where the Demon Catcher goes after demons one at a time and the Slaver uses whatever pays, the Wrangler is called in by a troubled village, listens to everyone, raises a posse of locals, scouts the trouble and then works out who is really causing it, why, and whether a deal can be struck before anyone gets hurt.

He specialises in Goblins, Lesser Demons and the simpler nature spirits, and he leaves the greater horrors to others. Goblins are vain, greedy and easily fooled, and the Wrangler plays on exactly that, treating them with flattering respect, singing their songs and bluffing them with the threat of an angry mob, so that a troublemaker can be talked into repairing the damage and leaving town for a keg of wine. When talk fails he fights, and he is well trained to, but he counts a job done without bloodshed as the best kind.

Most Wranglers are sociable, honourable folk who work for modest fees, room and board, or trade, and who keep their distance from Slavers and fanatics. Like all Demon Quellers they harden their bodies against demonic filth and know the infernals'' tricks and weaknesses as well as their own.
',
       updated_at = datetime('now')
 WHERE class_id = 'goblin-wrangler'
   AND instr(markdown, 'Later picks are prose, per') > 0
   AND length(markdown) = 23549;

-- == enlightened-demon ==
UPDATE imported_classes
   SET markdown = '---
id: enlightened-demon
name: Enlightened Demon
system: rifts
source_book: Rifts World Book 25: China 2 p.96-101
category: rcc
tags: [supernatural]
xp_table: [0, 2401, 4801, 9601, 19201, 32801, 43201, 62801, 85401, 108601, 165201, 220401, 290601, 380201, 470401]
attribute_dice: { IQ: "3d6", ME: "3d6", MA: "3d6", PS: "3d6", PP: "3d6", PE: "3d6", PB: "3d6", Spd: "3d6" }
sdc_base: "4d6+20"
ppe_base: "6d6 + P.E. attribute number, +1d4 per level of experience"
starting_money: "2d6x10"
bonuses:
  attributes: { IQ: 3, MA: 2, PS: "1d6" }
  saves: { spell_magic: 3, ritual_magic: 3, horror_factor: 6 }
  at_level:
    - { level: 2, saves: { possession: 2 } }
    - { level: 6, saves: { possession: 2 } }
    - { level: 12, saves: { possession: 2 } }
    - { level: 14, saves: { possession: 2 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Chinese", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 95%." }
    - { name: "Tiao Qi/Chinese Checkers", base: 39, per_level: 4, note: "+15%; the favorite game of demons throughout Rifts China." }
    - { name: "Lore: Demons & Monsters", base: 65, per_level: 5, note: "+40%" }
    - { choose: 2, from: ["Lore: Magic", "Lore: Faeries & Creatures of Magic", "Lore: Religion", "Lore: American Indians", "Lore: Cattle & Animals", "Lore: D-Bee", "Lore: Juicers", "Lore: Psychics & Psionics", "Lore: Dimensions", "Lore: Astral", "Lore: Nightbane", "Lore: Nightlands", "Lore: Vampires", "Lore: Galactic/Alien", "Lore: Wormwood", "Lore: Geomancy or Lines of Power", "Lore: History of Russia", "Lore: General Law", "Lore: Aborigines", "Lore: Cities", "Lore: Dreamtime Culture", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Taoist", "Lore: Chinese Mythology: Buddhist", "Lore: Feng Shui/Geomancy", "Lore: Rifts China", "Lore: Western World"], note: "Lore: choose any two." }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Running", "Swimming"], note: "Physical Skills (Human): choose two. The book offers Aerobic Athletics OR General Athletics as one option, so take at most one of those two." }
    - { choose: 2, from: ["W.P. Blunt", "W.P. Grappling Hook", "W.P. Knife", "W.P. Staff"], note: "Traditional Chinese Makeshift or Peasant Weapon Proficiencies: choose any two." }
    - { choose: 1, from: ["W.P. Bow", "W.P. Slingshot", "W.P. Small Thrown Weapons"], note: "Traditional Chinese Projectile Weapon Proficiencies: choose any one." }
    - { name: "Demon Wrestling", base: 55, per_level: 5, note: "+25%; the book prints Hand to Hand: Demon Wrestling (+25%)." }
  occ_related_skills:
    count: 2
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - "Electrical"
      - "Espionage"
      - "Horsemanship"
      - "Mechanical"
      - "Medical"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Science"
      - { name: "Technical", bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Communications, Electrical, Espionage, Mechanical, Pilot, Pilot Related and Science: none at first level, but any thereafter. Military and Rogue: none. W.P.: any except Heavy Weapons, Heavy Energy Weapons or Sharpshooting. The character cannot read unless a Literacy skill is selected. All new skills start at first level proficiency."
    schedule:
      - { level: 2, count: 1 }
      - { level: 3, count: 1 }
      - { level: 4, count: 1 }
      - { level: 5, count: 1 }
      - { level: 6, count: 1 }
      - { level: 7, count: 1 }
      - { level: 8, count: 1 }
      - { level: 10, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 1 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Horsemanship"
      - "Mechanical"
      - "Medical"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "From the related list and its limits (any, only, none), without its bonuses. All secondary skills start at the base skill level."
    schedule:
      - { level: 2, count: 1 }
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 10, count: 1 }
      - { level: 12, count: 1 }
      - { level: 14, count: 1 }
equipment_starting:
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One Ancient Chinese weapon of choice; may be magical if circumstances are right." }
  - { item_id: "traveling-clothes", qty: 1, note: "Rugged traveling clothes of cotton, wool and/or leather." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "cold-weather-clothing", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "clothing", qty: 1, note: "A complete suit of lightweight, embroidered silk indoor clothing: slippers, pants, shirt, long jacket and a wide hat." }
  - { item_id: "shoulder-purse-large", qty: 1, note: "A large traveler''s shoulder bag." }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "Also a small neck pouch, a hairbrush and a handful of personal items, which have no catalog rows." }
  - { item_id: "canteen", qty: 1, note: "A bamboo canteen of water." }
special_abilities:
  - name: "Demon Form"
    description: "Each Enlightened Demon begins as one of the Lesser Demons of Rifts China One (pages 84-105): Ch''uan Ti the Earth Hound, Falcon Demon, Ma T-ou (Horse-Head Demon), Monkey-Wolf, Ox-Head Demon, Pig Demon or Yang Ching (Goat-Head Demon), plus one Unique Demonic Power rolled from Rifts China One pages 145-149. Use that Lesser Demon''s statistics from Rifts China One for the Demon Form. The book names what each demon keeps through 15th level and when it loses its Metamorphosis (see Demon Origins below). The Demon Form weakens level by level (see the level progression) and is gone at 15th level."
  - name: "Human Form"
    description: "A Permanent Human Form, gained at first level, with one human appearance chosen and kept. The eight attributes rolled for the character are the Human Form''s. In Human Form the character has the Demon Form''s skills but Hit Points and S.D.C. in place of demonic M.D.C. and power. Changing to Human Form takes two full melee rounds at level 1, one full melee round at level 3, one melee attack/action at level 5, and is instantaneous and automatic from level 7. If knocked unconscious before 7th level, the character resumes Demon Form at once; from 7th level a knocked-out Demon Form becomes human instead."
  - name: "Torment"
    description: "Base Skill: 88%. A master of the demonic art of torture: almost any information, or a confession to any crime whether or not the victim is guilty, can be extracted with 2D4 melee rounds (30-120 seconds) of inflicted pain. Should the character''s former colleagues learn it has been used, the likely result is a one-way trip to eternal torment. A character of good or Unprincipled alignment will not use this skill."
  - name: "Sense Sinner"
    description: "By concentrating, senses anyone who has committed serious sins: murderers, rapists and torturers up to 600 feet (183 m) away, those who harmed others through greed up to 3000 feet (914 m). Lesser sins have shorter ranges, down to 25 feet (7.6 m) for someone who insulted a parent or sibling. Kept after the full transformation to human."
  - name: "Identify Sin"
    description: "With a touch, instantly detects and identifies the top sins committed by any person. Big ones, like murder or armed robbery, tend to drown out the others; even the purest person has some small sin to detect. Kept after the full transformation to human."
  - name: "Rouse the Dead and Damned"
    description: "Can gain the attention of any of the Dead and Damned, even comatose ones. Communication is automatic: they understand whatever the character says and answer in the same language. While the character stays in the immediate area they obey any order or request, falling back into stillness if left behind. Kept after the full transformation to human."
  - name: "Mind Walk"
    description: "Gained at 4th level. The spirit leaves the body and moves about the world as pure Chi (pure I.S.P.). It sees and hears normally and can use any I.S.P.-driven power, but is invisible and insubstantial except to Taoists, Diviners and others aware of the spirit world or able to see the invisible, and cannot use weapons, carry possessions, or touch or influence the physical world."
  - name: "Absorb Curses"
    description: "Gained at 9th level. I.S.P. Cost: 40. The character takes on everything cursed within 1,000 feet (305 m): everyone and everything in range is freed of all curses, which land on the character and take full effect at once. Each day the character rolls 1D20 for each curse still active; 16 or less sheds that curse."
  - { choose: 1, at_levels: [10], from: ["Mystic Martial Art Power: Mien-Ch''uan Kung Fu (Cotton Fist)", "Mystic Martial Art Power: Pao Chih (Animus Development)", "Mystic Martial Art Power: She Shen Kung Fu (Snake Style)", "Mystic Martial Art Power: Tong Lun Kung Fu (Praying Mantis Style)", "Mystic Martial Art Power: Xian Tai Chi Chuan (Chi Manipulation)"], note: "Human Martial Art Powers (printed 99): at 10th level choose one of these five. The power starts at its 10th level of advancement and levels up in the usual way from there, so its level table is read at the character''s own level." }
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
natural_abilities:
  - { name: "Chi Weapon", description: "From 2nd level: manipulates Chi in Human Form to add Mega-Damage to one otherwise ordinary weapon, chosen with one of W.P. Bamboo Staff, W.P. Chiang Zhu Spear, W.P. Gien Bian (Steel Whip) or W.P. Wen Jen (Scholar''s Sword)." }
  - { name: "Demonic Linguistic Ability", description: "Understands and speaks every language until 5th level; from then on only Chinese and its dialects, and other languages must be learned as skills." }
level_progression:
  - { level: 1, grants: ["Gain Human Form; the Demon Form keeps its full powers and abilities", "Demonic hungers and instincts in both forms", "Returning to Demon Form is instantaneous and effortless"] }
  - { level: 2, grants: ["Human Sense and Manipulate Chi: choose one of W.P. Bamboo Staff, W.P. Chiang Zhu Spear, W.P. Gien Bian (Steel Whip) or W.P. Wen Jen (Scholar''s Sword) and give that weapon Mega-Damage (add the W.P. by hand)", "Demon Form loses all bonuses on initiative", "+2 to save vs possession"] }
  - { level: 3, grants: ["Human Powers of Meditation: becomes skilled in Meditation (add by hand); can no longer use psionic or mind powers in Human Form", "Human Form I.S.P.: M.E. attribute number +4D6, +4 I.S.P. per level of advancement (record by hand)", "Human transformation takes one full melee round", "Loses the ability to inflict curses of any kind"] }
  - { level: 4, grants: ["Human Hungers & Instincts: normal human tastes and desires, sensitive to the feelings of other humans", "Mind Walk power"] }
  - { level: 5, grants: ["Learn Human Combat: one Advanced Hand to Hand Chinese Martial Art (Dog Boxing, Drunken Style, Eighteen Weapons, Jade Fan, Monkey Style or Shao-Lin Kung Fu), begun at its 5th level; or, optionally, Basic Hand to Hand: Tai Chi plus two more O.C.C. skills", "Human transformation takes one melee attack/action", "Loses demonic linguistic ability: Chinese only"] }
  - { level: 6, grants: ["Human Wants & Needs: the demonic blood urges are gone for good", "Loses the Unique Demonic Power", "+2 to save vs possession"] }
  - { level: 7, grants: ["Human Form Default: forced into True Form or knocked out, the character becomes human; human transformation is instantaneous and automatic", "Loses demonic magic: no spells known as a demon", "Going to Demon Form takes a melee attack/action and no longer happens on unconsciousness"] }
  - { level: 8, grants: ["Human Form Aesthetics: appreciates human art and culture", "Demon Form loses Supernatural Strength: now the equivalent of Augmented/Bionic Strength, M.D. only with power punches (two melee attacks)"] }
  - { level: 9, grants: ["Human Vulnerability: vulnerable to disease, illness, curses and afflictions like any human; old bonuses against them are gone", "Loses demonic psionics", "Absorb Curses", "Going to Demon Form takes one full melee round"] }
  - { level: 10, grants: ["Human Martial Art Powers: choose one Mystic Martial Art Power from the class''s five, begun at its 10th level of advancement (a banked pick, spent from the sheet)", "Demon Form loses two attacks per melee round"] }
  - { level: 11, grants: ["Human Sympathy & Empathy", "Demon Form loses See the Invisible and Nightvision; eyesight becomes ordinary human"] }
  - { level: 12, grants: ["Human Music Appreciation", "Loses demonic invulnerability: vulnerable to ordinary S.D.C. weapons", "Going to Demon Form takes two full melee rounds", "+2 to save vs possession"] }
  - { level: 13, grants: ["Human Sense of Humor", "Loses demonic bio-regeneration: heals only in Human Form, 1D6 Hit Points/S.D.C. per hour"] }
  - { level: 14, grants: ["Human Capacity for Love", "Loses demonic presence: other supernatural beings sense the Demon Form is a fraud", "+2 to save vs possession"] }
  - { level: 15, grants: ["Fully Human: loses the Demon Form altogether"] }
restrictions:
  - "Racial Requirements: Lesser Demon (one of the seven named in Rifts China One). Attribute Requirements: none."
  - "Alignment: Principled (3%), Scrupulous (28%), Unprincipled (35%), Anarchist (25%) or Aberrant (9%)."
  - "Must keep any word of honor, must not be caught in a lie, must obey any Mandate of Heaven, must never harm, torture or kill for pleasure, and must respect local laws and authorities. Caught breaking any rule, the Yama Kings may recapture the character, which then leaves play for good."
  - "Additional P.P.E. cannot be drawn from dragon lines (ley lines) or other naturally occurring sources of magic."
  - "From 3rd level: no psionic or mind powers in Human Form."
  - "Cybernetics: none, and will probably always avoid them."
trackable_resources: []
side_effects: "Hated and hunted by nearly the whole population of the character''s former Yama King Hell, from its master to its lowliest servant; while it keeps away and obeys the law they can do little. A recaptured deserter may face centuries of punishment, during which no progress toward human form is possible. Money: 2D6x10 in credits or tradeable goods. Optional starting age: 500 years + 1D12x1,000 + 1D10x100 + 1D100."
extraction_notes: "Rifts World Book 25: China 2 printed 96-101 (cache p097-p102, a scan, page_offset +1), every number read off 200 and 300 dpi renders. The section opens under Enlightened Demon R.C.C. - Optional at the foot of printed 96 and ends at the top of the right column of printed 101 (Starting Age); the Green Scarf magic items follow. The book marks the R.C.C. optional. DEMON FORM: the book takes the demon type and its base statistics from Rifts China One (Lesser Demons, pages 84-105; Unique Demonic Powers, 145-149). The Lesser Demons of 84-105 are creature rows now (about 45 rows cite Rifts World Book 24: China 1, chuan-ti, ma-tou and ox-head-demon among them); the class does not grant or list them and still keeps the demon form in prose. The Unique Demonic Powers of 145-149 still have no rows. Nate''s decision, 2026-10-01 (survey china-2.md, Agreed with Nate, item 3): import it now with the demon form in prose. Use the Lesser Demon''s statistics from Rifts China One for the Demon Form; no demon attribute dice, M.D.C., attacks or powers are invented here. The per-demon retentions of printed 98 (Ch''uan Ti keeps Prehensile Tongue and Alter Scent; Falcon Demon keeps Winged Flight, loses Metamorphosis: Firefly at 6th; Ma T-ou keeps Weapon Master: Small Blades in both forms, loses Metamorphosis: White Steed at 5th; Monkey-Wolf''s Human Form is its Metamorphosis: Human form, keeps Prehensile Tail and Run with the Wind, loses Metamorphosis: Wolf at 8th; Ox-Head keeps its horns in Human Form, shrinking to nubs by 15th, keeps Heightened Hearing and Fantastic Endurance, loses Metamorphosis: Black Bull at 7th; Pig Demon keeps Weapon Master: Peasant Tools and Contacts & Connections in both forms and Heightened Smell in Demon Form, loses Metamorphosis: Pig at 7th; Yang Ching keeps Weapon Master in both forms and Turns Invisible in Fog or Mist in Demon Form; Ch''uan Ti is also reduced to 1st level at enlightenment) are in the Demon Origins section. HUMAN FORM is what is stored: the book says to roll the eight attributes (Human Form) as normal for human characters, stored as 3D6 each. Base S.D.C. 4D6+20 (once converted from M.D.C.) is stored as sdc_base, because the book prints it as this R.C.C.''s own base with its own O.C.C. skill list rather than as a bonus added to an occupation''s; hit points are not printed and take the core rule. No men_of_arms line, because sdc_base is stated. P.P.E.: 6D6 + P.E., +1D4 per level (printed 100). Bonuses (printed 100, headed O.C.C. Bonuses): +3 I.Q., +2 M.A., +1D6 P.S., +3 save vs magic (stored as spell and ritual magic), +6 save vs Horror Factor, +2 save vs possession at levels 2, 6, 12 and 14. HUMAN FORM I.S.P. (printed 98): M.E. +4D6, +4 per level, gained at 3rd level, when the character also loses the use of psionic powers in Human Form; no psionics block is stored, because the pool does not exist at creation and no powers come with it, so it is in the level progression to record by hand. XP: cache p161 (printed 160), column headed Enlightened Demon / Monk: Chi-Gung Sen Ren / Warrior: Nei Chia Wu Shih, read off a render. Skills (printed 100-101): Language: Native Chinese Speaker 95% is the catalog''s Language: Chinese at a flat 95; Games: Tiao Qi +15% is Tiao Qi/Chinese Checkers (24+15); Lore: Demons & Monsters +40% (25+40); Lore: any two is a choice over the catalog''s Lore rows; Hand to Hand: Demon Wrestling (+25%) is the catalog''s Demon Wrestling percentile skill (30+25), not a Hand to Hand style. Torment (Base Skill 88%) has no catalog row and is a special ability. Meditation (3rd level) and the 2nd-level Chi weapon W.P. are level-gated grants and are in the level progression, to add by hand. HAND TO HAND (printed 98-99): none at first level; at 5th level one Advanced Hand to Hand Chinese Martial Art is gained free and begun at its own 5th level, or optionally Basic Hand to Hand: Tai Chi (catalog Hand to Hand: Tai-Chi Ch''uan) plus two more O.C.C. skills. Stored as cost 0 for those seven styles, with the 5th-level timing and the two extra skills as conditions; the app does not hold the pick until 5th level or add the two skills. Related skills: two at level 1, one more at 2, 3, 4, 5, 6, 7, 8, 10, 12 and 14. The categories marked none at first level, but any thereafter are offered, with that limit in the note; Military and Rogue are none and are left out. W.P. Heavy Weapons and Heavy Energy Weapons are read as the catalog''s W.P. Heavy Military Weapons and W.P. Heavy M.D. Weapons. Secondary: three at level 1, one more at 2, 4, 8, 10, 12 and 14. MYSTIC MARTIAL ART POWER at 10th level (2026-10-05, printed 99, read off a 200 dpi render of cache p100): the page heads the entry 10th Level: Human Martial Art Powers and says to choose one of Mien-Ch''uan Kung Fu (Cotton Fist), Pao Chih (Animus Development), She Shen Kung Fu (Snake Style), Tong Lun Kung Fu (Praying Mantis Style) or Xian Tai Chi Chuan (Chi Manipulation), and that the Enlightened Demon, now 10th level, will start the Martial Art Power at the 10th level of advancement and then level up in the usual way. Stored as a pick of one from those five at level 10 (BOOK-INGEST-AUDIT.md F116), each option the book''s power under its shared name. A power''s level table is keyed to the character''s level (BOOK-INGEST-AUDIT.md F117), so a power taken at 10th level shows its lines through level 10 at once and the 11th next, which is the printed start at the power''s 10th level. The table is shown on the sheet as text, display only: nothing a later level says is added to the character''s numbers. The Mystic Martial Art Power section below is a short summary of each option''s first level. EQUIPMENT (printed 101): the neck pouch, hairbrush and personal items have no catalog rows and are noted on the small sack rather than stubbed. The Human Form Advancement and Demon Form Dissolution ladders (printed 98-100) are in level_progression."
---

## Lore

The return of magic and the arrival of the Yama Kings upended human lives across China, and, less obviously, the lives of the demons who serve those Kings. For untold ages a demon could climb its rigid hierarchy only by betraying those above it, or sink to the bottom to be trodden on by those below. Then whole legions were marched out of the torture pits and furnaces of Hell onto the human plane, to fight strange creatures under strange skies, and some of them began to ask why.

Some of those confused and disillusioned demons have listened to the Demon Catching Heroes, who speak of enlightenment, transformation and a different kind of life. The ones who turn their backs on the old ways become Enlightened Demons, also called Shan Muo, Initiates to Mortality or Renegade Demons. They are caught between two worlds: still able to take a demon''s shape and still hunted and tempted by their former masters, yet drifting steadily into the world of humans. Every step toward humanity strengthens the human form and weakens the demonic one, until the last trace of the demon is gone and the character is simply human.

An Enlightened Demon wants to live as a human, feeling and learning and doing good where it can, to help the Demon Quellers who try to enlighten other demons, and to frustrate the Yama Kings whenever possible. Ghosts, undead, goblins, animal spirits, faerie folk and were-beasts can find enlightenment of a kind, but none of them undergoes this transformation; it is open only to Lesser Demons.

The newly reformed demon is unused to owning things, so it starts with little: an ancient Chinese weapon, rugged travel clothes with boots, hat and gloves, winter over-garments, a suit of embroidered silk indoor clothing, a large shoulder bag, a bedroll, a small sack and a neck pouch, a hairbrush, a bamboo canteen and a few personal items.

## Demon Origins

The character starts with the original characteristics of one of these Lesser Demons from Rifts China One (pages 84-105), plus one Unique Demonic Power rolled on percentile from Rifts China One (pages 145-149). Use that Lesser Demon''s statistics from Rifts China One for the Demon Form.

- Ch''uan Ti, the Earth Hound: reduced to 1st level at enlightenment. Keeps Prehensile Tongue and Alter Scent in Demon Form through 15th level.
- Falcon Demon: keeps Winged Flight in Demon Form through 15th level; loses Metamorphosis: Firefly at 6th level.
- Ma T-ou (Horse-Head Demon): keeps Weapon Master: Small Blades in both forms through 15th level; loses Metamorphosis: White Steed at 5th level.
- Monkey-Wolf: the Human Form is the creature''s Metamorphosis: Human form (blonde or golden hair, sparkling green eyes). Keeps Prehensile Tail and Run with the Wind in Demon Form through 15th level; loses Metamorphosis: Wolf at 8th level.
- Ox-Head Demon: its horns show even in Human Form, a full rack at 1st level shrinking to tiny nubs by 15th. Keeps Heightened Sense of Hearing and Fantastic Endurance in Demon Form through 15th level; loses Metamorphosis: Black Bull at 7th level.
- Pig Demon: keeps Weapon Master: Peasant Tools and its Contacts & Connections skill in both forms through 15th level, and Heightened Sense of Smell in Demon Form; loses Metamorphosis: Pig at 7th level.
- Yang Ching (Goat-Head Demon): keeps Weapon Master in both forms through 15th level, and Turns Invisible in Fog or Mist in Demon Form.

## Mystic Martial Art Power (10th level)

At 10th level the character chooses one of these five (printed 99), a pick the sheet banks at that level. The power starts at its 10th level of advancement and levels up in the usual way from there, so the sheet shows its whole level table up to the character''s level. The table is shown as text, display only: nothing a later level says is added to the character''s numbers. First-level summaries:

- Mien-Ch''uan Kung Fu (Cotton Fist). Level 1: Dragonskin, a mystic hide raised in one full melee round against mega-damage foes, 6D6 M.D.C. +10 per level, 4 I.S.P. a melee round; Trial Strike, a harmless +7 punch that tells the striker what the target is (mortal, demon, supernatural, ethereal and so on); and one Specialty Attack: Demon Combination Punch (5D6 M.D. and 5D6 I.S.P. or P.P.E. drained, supernatural beings only, 20 I.S.P.), Dragon Whack (1D6x10 M.D. to a dragon, not bio-regenerated for 1D4 hours, 40 I.S.P.), Hammer Fist (1D6x10 to S.D.C. structures, 10 I.S.P.), Internal Strike (2D6 direct to hit points through S.D.C., 10 I.S.P.), Shatter Jab (8D6 M.D. at a seam of M.D.C. armor or machinery, 20 I.S.P.) or Spirit Blow (5D6 M.D. and 4D6 I.S.P. drained, spirits and ethereal beings only). (printed 31-33.)
- Pao Chih (Animus Development). Level 1: in four melee rounds, evoke an Animus, a living double made of invested I.S.P. that lives inside the body with its own I.S.P. pool, burning 1 I.S.P. an hour. It is perpetually alert, tries to wake the character when he sleeps or is knocked out, can move the body out of danger, and knows all his I.S.P. abilities. (printed 33.)
- She Shen Kung Fu (Snake Style). Level 1: Viper Stance (thermal vision 60 ft; Fang Fingers 3D6 M.D. or 5D6 S.D.C.; six attacks a melee in all, +5 strike, +4 parry, +5 damage, +4 roll; no pulled punches); Rat Snake Stance (Knuckle Punch 2D6+10 M.D. or 3D6 S.D.C.; M.D.C. equal to P.E. +20; +1 attack, +4 strike, +3 parry, +3 roll); Art of Melting (silent movement as Prowl 60% +3% per level; escape 70% +2% per level); and one Art of Invisibility: Clouding the Mind (vanish for one action, 2 I.S.P. per person), Deception (prowl, 60% +3% per level under inspection), Evasion (stay behind a foe, 60% +3% per level), Hiding (60% +4% per level in good light) or Vanishing (90% +1% per level in darkness, -25% in good light). Stance bonuses apply only in that stance. (printed 34-35.)
- Tong Lun Kung Fu (Praying Mantis Style). Level 1: Mantis Armor for 5 I.S.P. - chitin plates with M.D.C. equal to the character''s S.D.C. +20 per level, all attacks mega-damage, +4 parry, +2 disarm, +3 entangle; Mantis Hook Attack, 3D6 M.D. or 5D6 S.D.C.; and the Spectral Praying Mantis for 20 I.S.P., evoked in three melee rounds as a separate human-sized animus (two attacks, +4 strike, 2D6 M.D., M.D.C. equal to the creator''s S.D.C., up to 1000 ft away) or worn as power armor (+1 initiative, disarm and entangle, +2D6 damage, M.D.C. equal to S.D.C. +20). It can be doubled in size up to three times; the book prices each doubling at both 15 and 10 I.S.P. (printed 37-39.)
- Xian Tai Chi Chuan (Chi Manipulation). Level 1: Chi Ball. Four melee rounds to evoke, then each melee round of gathering adds 1D4 I.S.P. to it, with no maximum but hard to control past the character''s base I.S.P. Harmless to mortals, living creatures and machines; against demons, disembodied entities and evil supernatural beings it does 1D6 M.D. per 10 I.S.P. stored (1D6x10 at 100). (printed 40-41.)

## GM Notes

The Demon Form is not modelled: look up the chosen Lesser Demon in Rifts China One and track its M.D.C., attacks and powers by hand, applying the losses in the level progression. The Human Form I.S.P. (from 3rd level), the 2nd-level Chi weapon W.P., Meditation at 3rd level and the two extra O.C.C. skills of the Tai Chi option are recorded by hand. The 10th-level Mystic Martial Art Power is a pick the sheet banks at 10th level. The app offers the 5th-level Hand to Hand styles free at any level; hold the player to 5th.
',
       updated_at = datetime('now')
 WHERE class_id = 'enlightened-demon'
   AND instr(markdown, 'level 1 only, per Nate 2026-10-01; see BOOK-INGEST-AUDIT.md F117') > 0
   AND length(markdown) = 26822;

-- == soothsayer ==
UPDATE imported_classes
   SET markdown = '---
id: soothsayer
name: Soothsayer
system: rifts
source_book: Rifts World Book 25: China 2 p.63-67
category: occ
tags: [scholar, healer]
occ_group: psychic
xp_table: [0, 2161, 4321, 8641, 17201, 27301, 37401, 55501, 76001, 102001, 146001, 192001, 248001, 298801, 356901]
race_restrictions: { only: ["none"], note: "Always human; 50% are female." }
attribute_requirements: { IQ: 11, MA: 11, ME: 11 }
sdc_base: "5d6+28"
starting_money: "6d6x100"
bonuses:
  attributes: { MA: "1d4+1", ME: 3, PE: 1 }
  combat: { initiative: 1, pull_punch: 2 }
  saves: { spell_magic: 2, horror_factor: 1, curses: 1 }
  at_level:
    - { level: 3, saves: { horror_factor: 1, curses: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1, curses: 1 } }
    - { level: 7, saves: { horror_factor: 1, curses: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1, curses: 1 } }
    - { level: 11, saves: { horror_factor: 1, curses: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 13, saves: { curses: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1, curses: 1 } }
psionics:
  type: "master"
  isp_base: "M.E. x3, +10 per level"
  powers: ["Alter Aura", "Clairvoyance", "Death Trance", "Empathy", "Exorcism", "Mask I.S.P. & Psionics", "Meditation", "Mind Block", "Psychic Diagnosis", "See Aura", "Sense Evil"]
  powers_starting: 0
  powers_schedule:
    - { level: 2, count: 3, from: ["Sense Magic", "Sense Time", "Commune with Spirit"], note: "Sense Magic, Sense Time and Commune with Spirits are all granted at second level." }
    - { level: 3, count: 3, from: ["Deaden Senses", "Sixth Sense", "Summon Inner Strength"], note: "Deaden Senses, Sixth Sense and Summon Inner Strength are all granted at third level." }
    - { level: 4, count: 2, from: ["Suppress Fear", "Detect Psionics"], note: "Suppress Fear and Detect Psionics are both granted at fourth level." }
    - { level: 5, count: 2, from: ["Intuitive Combat", "Resist Fatigue"], note: "Intuitive Combat and Resist Fatigue at fifth level, OR an additional 2D10+30 I.S.P. instead of both; a player who takes the I.S.P. skips this pick and adds it by hand." }
    - { level: 6, count: 1, from: ["Empathic Transmission"], note: "Empathic Transmission (super) is granted at sixth level." }
    - { level: 7, count: 1, from: ["Psychic Purification"], note: "Psychic Purification is granted at seventh level." }
    - { level: 7, count: 1, categories: ["Healing"], note: "One Healing power of choice at seventh level." }
    - { level: 8, count: 1, from: ["Bio-Regeneration"], note: "Bio-Regeneration (self) is granted at eighth level." }
    - { level: 8, count: 1, categories: ["Physical"], note: "One Physical power of choice at eighth level." }
    - { level: 9, count: 1, from: ["Remote Viewing"], note: "Remote Viewing is granted at ninth level." }
    - { level: 9, count: 1, categories: ["Sensitive"], note: "One Sensitive power of choice at ninth level." }
    - { level: 10, count: 2, from: ["Read Dimensional Portal", "Sense Dimensional Anomaly"], note: "Read Dimensional Portal and Sense Dimensional Anomaly are both granted at tenth level." }
    - { level: 11, count: 1, from: ["Group Trance"], note: "Group Trance (super) at eleventh level, OR an additional 2D10+50 I.S.P. instead; a player who takes the I.S.P. skips this pick and adds it by hand." }
    - { level: 12, count: 1, categories: ["Healing"], note: "One Healing power of choice at twelfth level." }
    - { level: 12, count: 1, categories: ["Physical"], note: "One Physical power of choice at twelfth level." }
    - { level: 13, count: 1, from: ["Radiate Horror Factor"], note: "Radiate Horror Factor (super) is granted at thirteenth level." }
    - { level: 14, count: 1, from: ["Psychic Body Field"], note: "Psychic Body Field (super) is granted at fourteenth level." }
    - { level: 15, count: 1, from: ["Psychic Omni-Sight"], note: "Psychic Omni-Sight (super) is granted at fifteenth level." }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Art", base: 50, per_level: 5, note: "+15%; drawing and painting." }
    - { name: "Brewing", base: 40, per_level: 5, note: "+15%" }
    - { name: "Carpentry", base: 30, per_level: 5, note: "+5%" }
    - { name: "Dowsing", base: 30, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "The book prints Language: Native Chinese Speaker at 95%." }
    - { choose: 1, from: ["Lore: Chinese Mythology: Taoist", "Lore: Chinese Mythology: Buddhist"], bonus: 15, note: "The book prints Lore: Chinese Mythology (+15%); the catalog holds it as two rows, Taoist and Buddhist." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Feng Shui/Geomancy", base: 25, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Play Chinese Musical Instrument: Flute", "Play Musical Instrument"], bonus: 10, note: "Play Chinese Musical Instrument: flute/pipes or string instrument, pick one (+10%). The catalog holds the flute as its own row; a string instrument is the general Play Musical Instrument row." }
    - { name: "Roadwise", base: 36, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%. The book lists Wilderness Survival twice, at +15% and +10%; stored once at the higher." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["W.P. Archery", "W.P. Axe", "W.P. Bamboo Staff", "W.P. Blunt", "W.P. Bola", "W.P. Bow", "W.P. Chain", "W.P. Chiang Zhu Spear", "W.P. Cross Bow", "W.P. Forked", "W.P. Gien Bian (Steel Whip)", "W.P. Knife", "W.P. Lance", "W.P. Mouth Weapons (Blow Guns)", "W.P. Net", "W.P. Paired Weapons", "W.P. Pole Arm", "W.P. Rope", "W.P. Shield", "W.P. Slingshot", "W.P. Small Thrown Weapons", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Tomahawk", "W.P. Trident", "W.P. Wen Jen (Scholar''s Sword)", "W.P. Whip"], note: "Weapon Proficiencies: choice of any two ancient weapons." }
    - { name: "Whittling & Sculpting", base: 45, per_level: 5, note: "+15%" }
    - { name: "Yarrow Stick Counting", base: 34, per_level: 3, note: "+10%" }
    - { name: "Hand to Hand: Tai-Chi Ch''uan", base: 0, per_level: 0, note: "Only the most basic of fighting skills, Tai-Chi, and no Mystic Martial Art Power." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", bonus: 10 }
      - { name: "Physical", only: ["Athletics (general)", "Body Building & Weight Lifting", "Fasting", "Prowl", "Running"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Bicycling"] }
      - { name: "Science", only: ["Astronomy", "Astronomy & Navigation", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Science", except: ["Astronomy", "Astronomy & Navigation", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", only_prefix: ["Lore", "History"], bonus: 10 }
      - { name: "Technical", except_prefix: ["Lore", "History"], bonus: 5 }
      - { name: "Weapon Proficiencies", except: ["W.P. Torpedo", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - { name: "Wilderness", bonus: 5 }
    note: "Horsemanship: General and Exotic only; may use a mule or donkey as a pack animal. Pilot: sail and row boats, bicycle and other basic, quiet vehicles only; many prefer to walk. Science: +10% to Astronomy and Math only. Technical: +5%, or +10% to Lore and History skills. Electrical, Espionage, Mechanical, Military, Pilot Related and Rogue: none. All new skills start at level one proficiency."
    schedule:
      - { level: 3, count: 2 }
      - { level: 7, count: 2 }
      - { level: 13, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - "Medical"
      - { name: "Physical", only: ["Athletics (general)", "Body Building & Weight Lifting", "Fasting", "Prowl", "Running"] }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak", "Bicycling"] }
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Torpedo", "W.P. Heavy Military Weapons", "W.P. Heavy M.D. Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "Three at level one and one more at levels 4, 8, 10 and 12, from the related list and its limits, at base skill level."
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 10, count: 1 }
      - { level: 12, count: 1 }
equipment_starting:
  - { item_id: "china-stalks-of-fortune", qty: 1, note: "Fifty milfoil stalks." }
  - { item_id: "china-soothsayer-stone-ax", qty: 1 }
  - { choose: 1, label: "peach-wood blade", qty: 1, from: ["china-peach-wood-knife", "china-peach-wood-sword"] }
  - { item_id: "china-peach-pits", qty: "1d6+4" }
  - { item_id: "china-peach-tree-protection-charm", qty: 1 }
  - { item_id: "china-peach-tree-wood-branches", qty: "2d6+6" }
  - { item_id: "china-peach-blossom-petals", qty: "2d6+20" }
  - { item_id: "china-sweeping-broom", qty: 1 }
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "A pistol or rifle of choice, S.D.C. or energy." }
  - { item_id: "e-clip", qty: "1d4", note: "1D4 ammo clips or E-Clips for the pistol or rifle." }
  - { item_id: "traveling-clothes", qty: 1, note: "Simple but sturdy traveling clothes of cotton, wool and leather, with a set of heavy winter/mountain over-garments." }
  - { item_id: "hooded-cloak", qty: 1 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1, note: "The book prints a hat." }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "A 100 page notebook." }
  - { item_id: "pencil", qty: "1d6+4" }
  - { item_id: "charcoal", qty: "1d4+1", note: "Pieces of charcoal." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "Solid ink and ink block (just add water)." }
  - { item_id: "brushes-low-quality", qty: "1d6+4", note: "Bamboo brushes of various sizes." }
  - { item_id: "knife-small", qty: 1, note: "Whittling knife." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife", qty: 1, note: "Cooking knife." }
  - { item_id: "food-rations", qty: 1, note: "20 cups of uncooked rice." }
  - { item_id: "shoulder-purse-large", qty: 1, note: "Medium-size satchel with shoulder strap." }
  - { item_id: "duffle-bag", qty: 1, note: "Large duffle bag with shoulder strap." }
  - { item_id: "belt", qty: 1, note: "A belt with many pouches." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "Small neck pouch." }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "garlic-cloves", qty: "1d4" }
  - { item_id: "lotus-petals", qty: "1d4" }
  - { item_id: "canteen", qty: 2, note: "Two bamboo canteens of water." }
special_abilities:
  - name: "The Path to Destiny"
    description: "Every Soothsayer believes he has a destiny to fulfil: to help others find and fulfil theirs, to help restore China''s balance by undermining supernatural evil, and to stand with the innocent and helpless against any oppressor, above all the demonic and the Yama Kings."
  - name: "The Hand of Destiny"
    description: "Receives impressions, insights and glimpses of things that could change the world if brought to the right person - never the Soothsayer himself but someone else, a hero. He may dream of, learn of or sense another''s fate. He can hear magic weapons that whisper for a hero to wield them, and the call of magical places, Dragon Lines and places of danger. Often a temporary custodian of magic weapons, charms and books placed in his care by the Celestial Court until the right hero is found; that hero may be revealed in a dream, Vision Dream or flash of Clairvoyance, especially at a Dragon Line, place of magic, temple or place of reflection."
  - name: "Read Chi"
    description: "Sees and reads the flow of Chi, though he cannot affect it like a Chi Mage: sees, senses and follows Dragon Lines, finds places of power, recognizes supernatural beings and mages, and recognizes magic items on sight (they glow with energy). Learning more about a place, item or person requires See Aura or a similar power. No I.S.P. cost."
  - name: "Recognize the Face of Evil"
    description: "Sees the true face and nature of evil shape shifters and demonic beings in disguise (Fox Faeries, Demonic Ghosts, Goblins, demons, and any evil dragon, spirit, supernatural being or creature of magic). Cannot see through the guises of good and selfish beings. Sees Chi (I.S.P.) and P.P.E. radiating from every living thing. Also sees Ghosts and demonic creatures that are normally invisible, and can tell when a Ghost, demon or evil spirit possesses a mortal, seeing its image superimposed on the victim."
  - name: "Vision Dream"
    description: "Sleeps focused on a person, place, item, event or goal to receive a dream of a possible future or a sudden insight. Chance of success: 20% +5% per level; +10% if done on behalf of someone else or a noble cause; an additional +20% if 20 I.S.P. is spent. Requires at least four hours of sleep, during which lost I.S.P., Hit Points and S.D.C. do not recover."
  - name: "Impervious to Demonic Possession"
    description: "The Soothsayer cannot be possessed by demons."
level_progression:
  - { level: 2, grants: ["Psionics: Sense Magic, Sense Time, Commune with Spirits"] }
  - { level: 3, grants: ["Psionics: Deaden Senses, Sixth Sense, Summon Inner Strength", "+1 save vs Horror Factor", "+1 save vs Demonic Curses"] }
  - { level: 4, grants: ["Psionics: Suppress Fear, Detect Psionics", "+1 save vs Horror Factor"] }
  - { level: 5, grants: ["Psionics: Intuitive Combat and Resist Fatigue, or an additional 2D10+30 I.S.P.", "+1 save vs Horror Factor", "+1 save vs Demonic Curses"] }
  - { level: 6, grants: ["Psionics: Empathic Transmission"] }
  - { level: 7, grants: ["Psionics: Psychic Purification and one Healing power of choice", "+1 save vs Horror Factor", "+1 save vs Demonic Curses"] }
  - { level: 8, grants: ["Psionics: Bio-Regeneration (self) and one Physical power of choice", "+1 save vs Horror Factor"] }
  - { level: 9, grants: ["Psionics: Remote Viewing and one Sensitive power of choice", "+1 save vs Horror Factor", "+1 save vs Demonic Curses"] }
  - { level: 10, grants: ["Psionics: Read Dimensional Portal, Sense Dimensional Anomaly"] }
  - { level: 11, grants: ["Psionics: Group Trance, or an additional 2D10+50 I.S.P.", "+1 save vs Horror Factor", "+1 save vs Demonic Curses"] }
  - { level: 12, grants: ["Psionics: one Healing and one Physical power of choice", "+1 save vs Horror Factor"] }
  - { level: 13, grants: ["Psionics: Radiate Horror Factor", "+1 save vs Demonic Curses"] }
  - { level: 14, grants: ["Psionics: Psychic Body Field", "+1 save vs Horror Factor"] }
  - { level: 15, grants: ["Psionics: Psychic Omni-Sight", "+1 save vs Horror Factor", "+1 save vs Demonic Curses"] }
restrictions:
  - "Always human."
  - "Hand to Hand: Tai-Chi only, and no Mystic Martial Art Power."
  - "Cybernetics: none."
trackable_resources: []
side_effects: "Ceremonial soothsaying costume (fierce mask, red pants, white shirt, red cloak, red slippers, fringed rope belt and the broom), a complete suit of lightweight embroidered silk indoor clothing with scarf and hat, 1D6+2 colors of paint in small re-sealable jars plus the same number of dry pigments, a collection of herbs for tea, flavoring and emergency medicine, a traveler''s tea bottle, two sets of chopsticks and a whole turtle shell are part of the standard kit and are not stored as items. Weapons are limited to the special Soothsayer gear plus the pistol or rifle. Communities welcome the Soothsayer with free food, drink and lodging; companions may be treated kindly too, at second-rate accommodation."
extraction_notes: "Rifts World Book 25: China 2 printed 63-67 (cache p064-p068, scan, page_offset +1); every number read off 200 dpi renders. The entry heading Soothsayer P.C.C. is on printed 63; powers 1-10 run 63-66, the stat block starts at the foot of 66 and the skills, equipment, money and cybernetics end on 67, where the Spirit Host P.C.C. begins. GROUP: printed 62 heads the section Chinese Diviner Psychic Character Classes, so occ_group psychic; a P.C.C. is category occ. sdc_base is stated (Base S.D.C. 5D6+28), so no men_of_arms line. Hit points are not printed. The powers section is headed Soothsayer O.C.C. Powers, Abilities & Bonuses. XP: printed 160, the ladder headed Demon Catching Hero / Soothsayer / Geofront Shadow Warrior, read off a render of cache p161. ATTRIBUTES: I.Q., M.A. and M.E. should be at least 11; stored as minimums of 11. PSIONICS: a Master Psychic (saves vs psionics on 10 or higher); I.S.P. M.E. x3, +10 per level. The level 1 powers are granted by name; levels 2-15 are schedule entries, the named ones as from-lists equal to their count. Commune with Spirits is the catalog''s Commune with Spirit; Mask I.S.P. and Psionics is Mask I.S.P. & Psionics; Bio-Regeneration (self) is the Healing row. Levels 5 and 11 print an alternative of 2D10+30 and 2D10+50 extra I.S.P.; stored as the powers, the I.S.P. option in each entry''s note. BONUSES: +1D4+1 M.A., +3 M.E., +1 P.E., +1 initiative, +2 pull punch, +2 save vs magic (spell_magic only, as plain save vs magic is stored elsewhere), +1 save vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 9, 11, 12, 14 and 15, +1 save vs Demonic Curses (stored as curses) at levels 1, 3, 5, 7, 9, 11, 13 and 15; impervious to demonic possession is an ability. HAND TO HAND: Tai-Chi is the catalog''s Hand to Hand: Tai-Chi Ch''uan; the book prints no price to change it and says the character has only that style, so costs {} (no upgrade offered); judgement. MYSTIC MARTIAL ART POWER (2026-10-05, printed 63, read off a 200 dpi render of cache p064): power 2, Hand to Hand Martial Arts Skill, prints that the Soothsayer possesses only the most basic of fighting skills, Tai-Chi, and no Martial Art Power. The class is given none and prints no body hardening exercise, so none is stored and there is no level table to show. SKILLS: Language: Native Chinese Speaker 95% is the catalog''s Language: Native Tongue at 95 with no per-level gain, the book printing a flat figure. Lore: Chinese Mythology is a choice of the catalog''s Taoist and Buddhist rows. Wilderness Survival is printed twice (+15% and +10%); stored once at +15%. Play Chinese Musical Instrument: flute/pipes or string is a choice of the flute row and the general instrument row. Two ancient W.P.s are a choice over the catalog''s ancient weapon proficiencies, the four China ones among them. Related: Science''s +10% to Astronomy and Math only, and Technical''s +5% with +10% to Lore and History, are each written as two entries for the one category. W.P.: any except Torpedo, Heavy Weapons, Heavy Energy Weapons and Sharpshooter, read as W.P. Torpedo, W.P. Heavy Military Weapons, W.P. Heavy M.D. Weapons and W.P. Sharpshooting. Physical: Fasting is filed under Wilderness in the catalog and is admitted cross-category. Secondary skills take the related limits without the bonuses. EQUIPMENT: the Soothsayer''s weapons and tools of the trade (printed 65-66) are their china- gear rows; peach-wood knife or sword is a choice. The pistol or rifle is weapons-matching-w-p-skills; the 1D4 clips are stored as e-clip whether bullet or energy. The costume, silk clothes, paints, herbs, tea bottle, chopsticks and turtle shell have no fitting row and are in side_effects. MONEY: 6D6x100 credits. CYBERNETICS: none."
---

## Lore

China''s soothsayers are far more than fortune tellers. Each is part diviner, part sage, part healer, part demon fighter and part counsellor, reading glimpses of what may come in the stars, in straws and sticks and in the I Ching, while also seeing possession by demons and ghosts and knowing how to drive evil spirits away. Their methods look odd but they work, and common folk find them easier to approach than learned magicians or Immortals, so a soothsayer is welcomed in almost any village, fed, housed and treated like a visiting dignitary.

The calling is as old as China. A soothsayer usually rises from humble beginnings, an ordinary person born with second sight, and that common origin is why the masses accept them so readily and why they understand what ordinary people must endure. Most live modestly, think honesty and sincerity matter most, and treat their gifts as a heavy responsibility.

Not all of them are heroes. About one in ten is a blackguard who uses the reputation of prophecy to win fame, fortune and power, to frighten or mislead, or to sell help only to those who can pay; a false prophecy of flood, famine or a ruler''s crimes can start a riot. Even these help people now and then, if only to keep their credibility.

Good or evil, every soothsayer believes he has a destiny. He follows gut feelings, an inner voice, the stars, the dragon lines and his dreams, and sees the world in broad strokes of color and sensation, standing on the line between the physical and the supernatural, between now and tomorrow.

## GM Notes

The book frames divination as a storytelling tool: the soothsayer never sees absolutes, only a glimpse of one possible future, so give clues, hints and warnings that move the story along rather than settle it.
',
       updated_at = datetime('now')
 WHERE class_id = 'soothsayer'
   AND instr(markdown, 'so nothing from BOOK-INGEST-AUDIT.md F117 applies') > 0
   AND length(markdown) = 21678;

-- == geofront-assault-geo-borg ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-assault-geo-borg
name: "Geo-Borg: Assault Geo-Borg"
system: rifts
source_book: Rifts World Book 25: China 2 p.130-131
category: occ
tags: [combat, augmented, stealth]
men_of_arms: true
occ_group: men-of-arms
xp_table: [0, 2121, 4241, 8481, 17001, 24901, 36301, 52601, 72901, 96001, 132301, 181601, 232901, 282301, 334601]
attribute_requirements: { IQ: 10, ME: 14 }
attribute_dice:
  PS: "30"
  PP: "24"
  Spd: "144"
mdc_base: 180
starting_money: "1d6x500"
psionics:
  isp_base: "M.E. attribute number, +1d6 per level of experience"
  powers_starting: 0
bonuses:
  combat: { initiative: 2, strike: 2, parry: 1, disarm: 3, pull_punch: 3, roll: 1 }
  saves: { spell_magic: 4, ritual_magic: 4, possession: 2, horror_factor: 3, other: [ { label: "vs Demonic Curses", bonus: 4 } ] }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%. Replaces the CS cyborg''s +10%." }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Chinese at 95%. Replaces the CS cyborg''s American at 98%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%" }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "+10%. Printed as Pilot: Motorcycle." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%. The CS cyborg and the Geofront addition both print +10%; granted once." }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "Printed as W.P. Throwing & Targeting." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "Printed as W.P. Knives." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%. From the CS Cyborg Strike Trooper." }
    - { choose: 1, categories: ["Pilot"], bonus: 20, note: "Pilot skill of choice (+20%). From the CS Cyborg Strike Trooper." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0, note: "From the CS Cyborg Strike Trooper." }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "Printed in the CS Cyborg Strike Trooper as W.P. Heavy Energy Weapons." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. one of choice. From the CS Cyborg Strike Trooper." }
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%. Light CS cyborg skill." }
    - { name: "Gymnastics", base: 40, per_level: 5, note: "+10%. Light CS cyborg skill." }
    - { name: "Acrobatics", base: 35, per_level: 5, note: "+5%. Light CS cyborg skill." }
    - { name: "Swimming", base: 65, per_level: 5, note: "+15%. Light CS cyborg skill." }
    - { name: "Escape Artist", base: 40, per_level: 5, note: "+10%. Light CS cyborg skill." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%. Light CS cyborg skill." }
    - { name: "Find Contraband", base: 36, per_level: 4, note: "+10%. Light CS cyborg skill, printed there as Find Contraband, Weapons & Cybernetics." }
    - { name: "Jet Packs", base: 62, per_level: 4, note: "+20%. Light CS cyborg skill, printed there as Pilot Jet Pack." }
    - { choose: 1, from: ["Hand to Hand: Drunken Style Kung Fu", "Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Monkey Style Kung Fu (Tai Sing Pek Kwar)", "Hand to Hand: Shao-Lin Kung Fu"], note: "One of Drunken Style, Dog Boxing, Monkey Style or Shao-lin Kung Fu. Replaces the CS cyborg''s Hand to Hand: Expert; no other style is offered." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Espionage", bonus: 10 }
      - { name: "Rogue", bonus: 5 }
      - { name: "Technical", bonus: 5 }
    note: "Completely different from the CS Light Cyborg. Select EITHER four Espionage (+10%) and two Rogue (+5%), OR three Rogue (+10%) and three Technical (+5%). The picker offers the three categories at six picks; keep to one package. Rogue carries the first package''s +5%; in the second package the Rogue picks are +10%, so add 5% to each by hand."
  secondary_skills:
    count: 0
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 13, count: 2 }
equipment_starting:
  - { item_id: "ab-830-assault-geo-borg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "vibro-knife", qty: 2, note: "A pair of Vibro-Knives, 1D6 M.D. each." }
  - { choose: 1, label: "pair of pistols", qty: 2, from: ["china-ght-85-hounds-tooth-auto-mag", "china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter"], note: "A pair of pistols of the player''s choice, with six ammo clips; the clips are not a catalog item. The list is this book''s Geofront pistols." }
  - { item_id: "china-chi-sniper-rifle-demons-eye", qty: 1, note: "The Demon''s Eye Chi Rifle." }
special_abilities:
  - name: "Assault Geo-Borg Body (AB-830 Full Conversion Cyborg)"
    description: "A stealth and infiltration full conversion ''borg that keeps human proportions and features: no tentacles, extra arms or obvious machine parts, and a human face under the combat helmet''s face plate (the character''s own, or a more heroic one with P.B. 20-24). 7 ft (2.1 m) tall, 2.5 ft (0.7 m) wide, 600 lbs (270 kg). Main body 180 M.D.C. (stored), plus an additional 140 M.D.C. of light espionage armor that hooks onto the body. M.D.C. by location: hands (2) 10 each, arms (2) 40 each, legs (2) 80 each, head 90 (reinforced). The head is a small target: a called shot at -3 to strike, and destroying it kills the character. Depleting the main body destroys the artificial body, but emergency systems keep the brain and vital organs alive for 18 plus 2D6 hours; recovered in time they can go on life support, otherwise the character dies. More than 100 M.D.C. below zero destroys the unit beyond recovery. Running: 120 mph (192 km) in light armor, 140 mph (224 km) without armor. Enhanced jumping with micro-boosters in the back and legs: leaps 60 ft (18.3 m) high and 100 ft (30.5 m) across, half that without the boosters. Flies only with a jet pack. Bionic P.S. 30, P.P. 24 and Spd 144 (140 mph without armor), stored as fixed attributes. Nuclear power. Market cost 8 million credits."
  - name: "Bionic Strength and Damage"
    description: "Bionic P.S. 30: 2D6+8 S.D.C. damage, or 1D4 M.D. with a power punch or kick, which counts as two melee attacks."
  - name: "Concealed Forearm Laser Beam Weapons (2)"
    description: "Above the wrists of both forearms; point and shoot, for long range and close combat. 2D6 M.D. per single blast, 4D6 M.D. if both arms fire at the same target; a dual blast counts as two rapid melee attacks, but the opponent dodges it as one. Each individual blast is one melee attack. Range 2000 ft (610 m). Payload effectively unlimited, tied to the power supply."
  - name: "Concealed Compartments and Exploding Throwing Irons"
    description: "Two compartments in the hips, each holding three exploding, crescent-shaped throwing irons, set to explode on contact, after a three second delay, or on a signal from the transmitter on the left wrist. 1D4 M.D. as a Vibro-Blade weapon only, +4D6 M.D. explosive damage. The character can throw two at once as one melee attack; each throw of one or two is one melee attack. Range 300 ft (91.5 m). Payload three in each leg, plus 6-12 usually hooked inside the long vest; more irons, grenades and weapons may be carried on a belt or in a pack or satchel."
  - name: "Handheld Weapons"
    description: "May use any Geofront weapon, and typically carries a pair of Vibro-Knives (1D6 M.D. each), a pair of pistols of choice with six ammo clips, and the Demon''s Eye Chi Rifle. May acquire, use and keep weapons, armor and items from the outside world, demon slaying and magic items included, for missions away from Geofront."
  - name: "Standard Bionic Features"
    description: "A) Bionic lung with gas filter and oxygen storage cell. B) Built-in language translator and 80 decibel loudspeaker. C) Surveillance/listening package: built-in radio receiver, scrambler and transmitter, range 100 miles (160 km), amplified hearing, sound filtration system, sound identifier and universal headjack. D) Climb cord concealed in the left hand, 200 ft (61 m), with a retractable winch. E) Clock calendar, gyro-compass and depth gauge. F) Concealed garrote wrist wire. G) Multi-optic eyes. H) Four additional non-weapon enhancements of the player''s choice. I) Five additional bionic weapons or special features of the player''s choice (Rifts Bionics Sourcebook)."
  - name: "Combat Regimen (in place of a Mystic Martial Art Power)"
    description: "Assault Geo-Borgs learn no Mystic Martial Art Power. They follow a special combat regimen combined with Shao-lin practice: +1 extra attack per melee at levels 2, 6 and 12 (in addition to those from Hand to Hand Kung Fu), +2 on initiative, +2 to strike, +1 to parry, +3 to disarm, +3 to pull punch, +1 to roll with punch/fall/impact, +4 to save vs magic and Demonic Curses, +2 to save vs possession and +3 to save vs Horror Factor. Stored in the class bonuses."
trackable_resources: []
restrictions:
  - "REQUIRES FULL BIONIC CONVERSION. In Geofront, partial and full conversion is done only for the military, and usually only for career soldiers who mean to serve for life."
  - "The hand to hand style is one of Drunken Style, Dog Boxing, Monkey Style or Shao-lin Kung Fu; no other is offered."
  - "Heavy armor gives 240 M.D.C. of protection but halves the ''Borg''s speed (70 mph/112 km) and gives Prowl -50%, which is why the Assault Geo-Borg seldom wears it."
level_progression:
  - { level: 2, grants: ["+1 attack per melee (combat regimen)", "+2 Secondary Skills"] }
  - { level: 5, grants: ["+2 Secondary Skills"] }
  - { level: 6, grants: ["+1 attack per melee (combat regimen)"] }
  - { level: 8, grants: ["+2 Secondary Skills"] }
  - { level: 12, grants: ["+1 attack per melee (combat regimen)"] }
  - { level: 13, grants: ["+2 Secondary Skills"] }
extraction_notes: "Rifts World Book 25: China 2 printed 130-131 (cache p131-p132, a scan, every figure read off 200 dpi renders). The Assault Geo-Borg opens on printed 130 after the Demon-Eater and its standard bionic features end on printed 131, where the Lion Geo-Borg begins. It is one of the Elite Military O.C.C.s of the Geofront Army (printed 128, heading Elite Geofront Forces), so occ_group men-of-arms and men_of_arms true. || XP: Geofront Technical Officer / Military Specialist / Geo-Borgs (all) ladder, printed 160 (cache p161), read off a render. || BASE CLASS: the book calls it roughly equivalent to the CS Light Cyborg and says plus the usual for the CS Light Cyborg Strike Trooper; printed 128 introduces the Geo-Borgs as the CS Cyborg Strike Trooper of the Geofront (Coalition War Campaign). So the base is cs-cyborg-strike-trooper (Rifts World Book 11: Coalition War Campaign p.69-70), its basic skills for all CS cyborgs plus its Light CS Cyborg supplement (its light variant), written out in full. Secondary skills are that class''s. || SUBSTITUTIONS: Mathematics: Basic +20% replaces the CS +10%; Language: Chinese at 95% replaces the CS American at 98% (stored fixed); the hand to hand choice replaces Hand to Hand: Expert and its upgrades, so hand_to_hand costs are empty and the style is a one-of-four occ_skills choice. Land Navigation +10% is printed by both and granted once. Pilot: Motorcycle is Motorcycles & Snowmobiles (60+10); Literacy: Chinese is 55+20; W.P. Throwing & Targeting is W.P. Targeting; W.P. Knives is W.P. Knife. || RELATED SKILLS: completely different from the CS Light Cyborg, printed as either four Espionage (+10%) and two Rogue (+5%) or three Rogue (+10%) and three Technical (+5%). The either/or with a different Rogue bonus per package is not expressible; stored as six picks over the three categories with the first package''s bonuses and the rule in the note. No extra picks at later levels are printed, so the CS schedule (levels 4, 8, 12) is not carried over. || MYSTIC MARTIAL ART POWER: none; the class follows a combat regimen instead, whose bonuses are unconditional and stored. 2026-10-05, printed 130, read off a 200 dpi render of cache p131: the page''s own line reads Mystic Martial Art Power: None, so the Assault Geo-Borg is given no power, none is stored and there is no level table to show. Save vs magic is stored as both spell_magic and ritual_magic; Demonic Curses is saves.other. || BODY: main body 180 M.D.C. is mdc_base; the 140 M.D.C. hook-on light espionage armor and the optional 240 M.D.C. heavy armor are prose. The body is also the vehicles row ab-830-assault-geo-borg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it. Bionic P.S. 30, P.P. 24 and Spd 144 are fixed attribute_dice, the dragon-borg precedent. || I.S.P.: Permanent I.S.P. Base (Chi), M.E. attribute number +1D6 per level, is a psionics block with no type and no powers. || MONEY: half that of the CS character; the CS class''s 1D6x1000 savings halved, stored as 1d6x500. || EQUIPMENT: same as the CS Light Cyborg, but armor, weapons and bionic features are this class''s: the CS issue''s utility belt, backpack and walkie-talkie are kept, its armor, rifle, E-clips and grenades left out. The weapons it typically carries (printed 131) are given: two vibro-knife rows, a pair of pistols chosen from this book''s Geofront pistols (six ammo clips in the note, no catalog row), and the Demon''s Eye Chi Rifle (china-chi-sniper-rifle-demons-eye). The throwing irons are built in and prose. || NOT STORED: the H and I bionic picks (four non-weapon enhancements, five weapons or features) are prose in Standard Bionic Features."
---

## Lore

The Assault Geo-Borg is a full conversion cyborg that still looks like a man.
Its makers avoided tentacles, extra limbs and visible machinery, and beneath
the face plate of its helmet is a human face, its own or a handsomer one built
for the part. Where the Demon-Eater keeps apart, the Assault Geo-Borg mixes
with ordinary people and likes to pass for an average soldier.

He is anything but. Every Assault Geo-Borg is a trained fighter in a body as
tough as a tank, and many specialize in stealth, espionage and assassination,
carrying forearm lasers, exploding throwing irons hidden in the hips and a
Demon''s Eye Chi Rifle. They work alongside Lightning Warriors, Gun Masters,
commandos, special forces and Demon-Eaters, in mixed teams, or alone. They hold
on to more of their humanity than the Demon-Eaters, and work easily with D-Bees
and other non-humans.

## GM Notes

The government provides housing, food and medical care, and the citizens of
Geofront respect and accept the Assault Geo-Borgs.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-assault-geo-borg'
   AND instr(markdown, 'Nothing from the level-1-only rule (BOOK-INGEST-AUDIT.md F117) applies') > 0
   AND length(markdown) = 15027;

-- == geofront-demon-eater-geo-borg ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-demon-eater-geo-borg
name: "Geo-Borg: Demon-Eater Cyborg"
system: rifts
source_book: Rifts World Book 25: China 2 p.128-130
category: occ
tags: [combat, augmented, hunter]
men_of_arms: true
occ_group: men-of-arms
xp_table: [0, 2121, 4241, 8481, 17001, 24901, 36301, 52601, 72901, 96001, 132301, 181601, 232901, 282301, 334601]
attribute_requirements: { IQ: 9, ME: 12 }
attribute_dice:
  PS: "35"
  PP: "24"
  Spd: "98"
mdc_base: 220
starting_money: "1d6x500"
psionics:
  isp_base: "M.E. attribute number, +1d6 per level of experience"
  powers_starting: 0
bonuses:
  combat: { attacks: 2, initiative: 2, strike: 4, parry: 4, disarm: 3, entangle: 5, pull_punch: 3, roll: 2 }
  saves: { spell_magic: 5, ritual_magic: 5, possession: 2, horror_factor: 5, other: [ { label: "vs Demonic Curses", bonus: 5 } ] }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 9, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%. The CS cyborg and the Geofront addition both print +10%; granted once." }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Chinese at 95%. Replaces the CS cyborg''s American at 98%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%" }
    - { name: "Motorcycles & Snowmobiles", base: 70, per_level: 4, note: "+10%. Printed as Pilot: Motorcycle." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%. The CS cyborg and the Geofront addition both print +10%; granted once." }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. Printed as Tracking (Humanoids/Demons); the CS heavy cyborg''s Tracking (humanoids) +10% is the same skill, granted once." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%. From the CS Cyborg Strike Trooper." }
    - { choose: 1, categories: ["Pilot"], bonus: 20, note: "Pilot skill of choice (+20%). From the CS Cyborg Strike Trooper." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0, note: "From the CS Cyborg Strike Trooper." }
    - { name: "W.P. Heavy M.D. Weapons", base: 0, per_level: 0, note: "Printed in the CS Cyborg Strike Trooper as W.P. Heavy Energy Weapons." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. one of choice. From the CS Cyborg Strike Trooper." }
    - { name: "Boxing", base: 0, per_level: 0, note: "Heavy CS cyborg skill." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%. Heavy CS cyborg skill." }
    - { name: "Gymnastics", base: 35, per_level: 5, note: "+5%. Heavy CS cyborg skill." }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%. Heavy CS cyborg skill." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%. Heavy CS cyborg skill." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%. Heavy CS cyborg skill, printed there as Demon & Monster Lore." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "Another W.P. of choice. Heavy CS cyborg skill." }
    - { name: "Hand to Hand: Shao-Lin Kung Fu", base: 0, per_level: 0, note: "Shao-lin Kung Fu only. Replaces the CS cyborg''s Hand to Hand: Expert; no other style is offered." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Intelligence", "Detect Concealment"] }
      - { name: "Mechanical", only: ["Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Military", except: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater"], bonus: 10 }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Military: Tanks & APCs", "Military: Jet Fighters", "Military: Combat Helicopter", "Fighter Combat: Basic", "Fighter Combat: Elite"], bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - { name: "Rogue", bonus: 2 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Same as the CS Heavy Cyborg: the CS Cyborg Strike Trooper''s related skills (Coalition War Campaign printed 70), copied from cs-cyborg-strike-trooper. Science is printed None and is omitted. Physical is any that are still appropriate. Military excludes every Demolitions skill. The Pilot exclusion covers robot, power armor, tank and APC, and combat aircraft skills."
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 0
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 13, count: 2 }
equipment_starting:
  - { item_id: "db-800-demon-eater-cyborg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
special_abilities:
  - name: "Demon-Eater Body (DB-800 Heavy Full Conversion Cyborg)"
    description: "A 12 ft (3.7 m) tall, 4 ft (1.2 m) wide, one-ton full conversion ''borg with the look of a demon or monster. Main body 220 M.D.C. (stored), plus an additional 340 M.D.C. of heavy armor that hooks onto the body. M.D.C. by location: hands (2) 35 each, arms (2) 100 each, legs (2) 170 each, feet (2) 100 each, tails (2) 80 each, head 140 (reinforced). The head is a small target: a called shot at -3 to strike, and destroying it kills the character. Depleting the main body destroys the artificial body, but emergency systems keep the brain and vital organs alive for 18 plus 2D6 hours; recovered in time they can go on life support, otherwise the character dies. More than 100 M.D.C. below zero destroys the unit beyond recovery. Running: 60 mph (96 km) in the heavy armor, 100 mph (160 km) in light or no armor. Leaps 50 ft (15.2 m) up or across, double with a running start at full speed. Flies only with a jet pack. Bionic P.S. 35, P.P. 24 and Spd 98 (100 mph without armor), stored as fixed attributes. Nuclear power. Market cost 12 million credits."
  - name: "Bionic Strength and Damage"
    description: "Bionic P.S. 35: 2D6+13 S.D.C. damage, or 2D4 M.D. with a power punch or kick, which counts as two melee attacks."
  - name: "Concealed Forearm Particle Beam Weapons (2)"
    description: "Above the wrists of both forearms; point and shoot, a heavy close combat weapon. 5D6 M.D. per single blast, 1D6x10 M.D. if both arms fire at the same target; a dual blast counts as two rapid melee attacks, but the opponent dodges it as one. Each individual blast is one melee attack. Range 300 ft (91.5 m). Payload effectively unlimited, tied to the power supply."
  - name: "Concealed Laser Eyes (2)"
    description: "Under the eyes. 2D6 M.D. per single blast, 4D6 M.D. if both eyes fire at the same target; an individual or simultaneous dual blast counts as one melee attack. Range 1000 ft (305 m). Payload effectively unlimited, tied to the power supply."
  - name: "Dual Prehensile Tails (2)"
    description: "For climbing, scaling walls, swinging like a monkey and close combat; each ends in a curved blade that stabs, cuts and slashes and can be driven into rock and concrete to climb. Reach 12 ft (3.6 m). Blunt tail strike 1D8 M.D.; blade strike 2D6+2 (printed without a unit, read as M.D. under the Mega-Damage heading). Each tail strike is one melee attack. The tails add two attacks per melee round, +1 to strike, +2 to parry, +2 to disarm and +5 to entangle; these are stored in the class bonuses."
  - name: "Prehensile Tongue"
    description: "Mostly for dramatic effect; it extends up to 2.5 ft (0.76 m) to strike or stab in close combat. 5D6 S.D.C., or 1D6x10 S.D.C. on a power punch/strike."
  - name: "Bionic Jaws and Teeth"
    description: "For close combat with demons and supernatural predators that bite and claw: 1D4 M.D. from a nip, 2D6 M.D. from a bite."
  - name: "Enhanced Climbing"
    description: "Electro-magnets, retractable finger and foot climbing fibers and flexible joints let the Demon-Eater climb mountainsides, walls and most textured surfaces, and cling to and move along walls and ceilings at half its maximum running speed. Prowl 70% on ceilings, walls and other high places while moving slower than Spd 22 (15 mph/24 km). +2 on initiative and +2 to strike when attacking from above with surprise (conditional, not stored)."
  - name: "Handheld Weapons"
    description: "May use any Geofront weapon modified for the cyborg''s oversized hand, and may acquire, use and keep weapons, armor and items from the outside world, demon slaying and magic items included, for missions away from Geofront."
  - name: "Standard Bionic Features"
    description: "A) Bionic lung with gas filter and oxygen storage cell. B) Built-in language translator and 80 decibel loudspeaker. C) Built-in radio receiver and transmitter, range 5 miles (8 km). D) Climb cord concealed in the left hand, 200 ft (61 m), with a retractable winch. E) Clock calendar and gyro-compass. F) Concealed garrote wrist wire. G) Multi-optic eyes. H) Three additional non-weapon enhancements of the player''s choice. I) Four additional bionic weapons, limbs or special features of the player''s choice (Rifts Bionics Sourcebook)."
  - name: "Combat Regimen (in place of a Mystic Martial Art Power)"
    description: "Demon-Eaters learn no Mystic Martial Art Power. They follow a special combat regimen combined with their Shao-lin practice: +1 extra attack per melee at levels 2, 5, 9 and 12 (in addition to those from Shao-lin Kung Fu and the tails), +2 on initiative, +3 to strike, +2 to parry, +1 to disarm, +3 to pull punch, +2 to roll with punch/fall/impact, +5 to save vs magic and Demonic Curses, +2 to save vs possession and +5 to save vs Horror Factor. Stored in the class bonuses."
trackable_resources: []
restrictions:
  - "REQUIRES FULL BIONIC CONVERSION. In Geofront, partial and full conversion is done only for the military, and usually only for career soldiers who mean to serve for life."
  - "Shao-lin Kung Fu is the only hand to hand style."
  - "The heavy armor reduces running speed to 60 mph and gives Prowl -50% on the ground (Prowl along walls and ceilings is the climbing system''s)."
level_progression:
  - { level: 2, grants: ["+1 attack per melee (combat regimen)", "+2 Secondary Skills"] }
  - { level: 4, grants: ["+1 O.C.C. Related Skill"] }
  - { level: 5, grants: ["+1 attack per melee (combat regimen)", "+2 Secondary Skills"] }
  - { level: 8, grants: ["+1 O.C.C. Related Skill", "+2 Secondary Skills"] }
  - { level: 9, grants: ["+1 attack per melee (combat regimen)"] }
  - { level: 12, grants: ["+1 attack per melee (combat regimen)", "+1 O.C.C. Related Skill"] }
  - { level: 13, grants: ["+2 Secondary Skills"] }
extraction_notes: "Rifts World Book 25: China 2 printed 128-130 (cache p129-p131, a scan, every figure read off 200 dpi renders). The Geo-Borgs section opens on printed 128 under the heading Elite Geofront Forces, Elite Military O.C.C.s of the Geofront Army; occ_group men-of-arms and men_of_arms true follow from that heading. The Demon-Eater opens on printed 128 and its standard bionic features end at the top of printed 130, where the Assault Geo-Borg begins. || XP: Geofront Technical Officer / Military Specialist / Geo-Borgs (all) ladder, printed 160 (cache p161), read off a render. || BASE CLASS: the book calls it roughly equivalent to the CS Heavy Cyborg, and introduces the Geo-Borgs as the CS Cyborg Strike Trooper of the Geofront (Coalition War Campaign); the skill list says plus the usual for the CS Heavy Cyborg Strike Trooper. So the base is cs-cyborg-strike-trooper (Rifts World Book 11: Coalition War Campaign p.69-70), its basic skills for all CS cyborgs plus its Heavy CS Cyborg supplement (its heavy variant), written out in full. Related skills, secondary skills and the hand to hand rule are that class''s. || SUBSTITUTIONS: Language: Chinese at 95% replaces the CS American at 98% (stored fixed, as the CS figure is); Shao-lin Kung Fu only replaces Hand to Hand: Expert and its upgrades, so hand_to_hand costs are empty. Mathematics: Basic +10%, Land Navigation +10% and Tracking +10% are printed by both the CS class and this one and are granted once. Pilot: Motorcycle is Motorcycles & Snowmobiles (60+10). Literacy: Chinese is 55+20. || MYSTIC MARTIAL ART POWER: none; the class follows a combat regimen instead, whose bonuses are unconditional and stored. 2026-10-05, printed 128, read off a 200 dpi render of cache p129: the page''s own line reads Mystic Martial Art Power: None, so the Demon-Eater is given no power, none is stored and there is no level table to show. Save vs magic is stored as both spell_magic and ritual_magic; Demonic Curses is saves.other, not the general curses field. || TAILS: the tails'' printed bonuses (two attacks, +1 strike, +2 parry, +2 disarm, +5 entangle) are folded into the class bonuses with the regimen''s, the tails being part of every Demon-Eater body: attacks 2, initiative 2, strike 3+1, parry 2+2, disarm 1+2, entangle 5, pull punch 3, roll 2. The climbing system''s +2 initiative and +2 strike from above with surprise are conditional and prose. || BODY: main body 220 M.D.C. is mdc_base; the 340 M.D.C. hook-on heavy armor is armor, not body, and is prose with the M.D.C. by location. The body is also the vehicles row db-800-demon-eater-cyborg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it. Bionic P.S. 35, P.P. 24 and Spd 98 are fixed attribute_dice, the dragon-borg precedent. Speed: printed Running 60 (96 km) in heavy armor, read as 60 mph. || I.S.P.: Permanent I.S.P. Base (Chi), M.E. attribute number +1D6 per level, is a psionics block with no type and no powers: the class is not a psychic. || MONEY: half that of the CS character; the CS class''s 1D6x1000 savings halved, stored as 1d6x500. Basic needs are provided by the government. || EQUIPMENT: same as the CS Heavy Cyborg, but armor, weapons and bionic features are those printed for this class. The CS issue''s non-armor, non-weapon items are kept (utility belt, backpack, walkie-talkie); its CA-6C armor, energy rifle, E-clips and grenades are left out as the armor and weapons this class replaces. The heavy armor is part of the body entry. || NOT STORED: the H and I bionic picks (three non-weapon enhancements, four weapons or features) are prose in Standard Bionic Features."
---

## Lore

The Demon-Eater is the Geofront''s heavy full conversion cyborg, its answer to
the Coalition''s heavy ''borg. Its body is deliberately built to look like a
demon or a monster: twin bladed tails, a lashing tongue, fanged jaws and a
hulking armored frame. The point is to unsettle the very creatures it hunts.
Demon-Eaters are made for stalking, ambushing and tearing apart demons at close
quarters, and some demons and Demon Lords, mistaking them for alien hunters
come through a Rift, have learned to fear them.

Like every Geofront cyborg, the Demon-Eater is a career soldier who chose to
give up his body for life in the army. Many become ruthless, single-minded
demon killers, and some carry a contempt for D-Bees and non-humans that is rare
among Geofront troops.

## GM Notes

Bionic conversion is rare in Geofront. Most citizens avoid bionics beyond
minor medical implants, and partial or full conversion is offered only to the
military. The government provides housing, food and medical care, and the
Demon-Eaters are respected and a little feared by the people they protect.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-demon-eater-geo-borg'
   AND instr(markdown, 'Nothing from the level-1-only rule (BOOK-INGEST-AUDIT.md F117) applies') > 0
   AND length(markdown) = 16231;

-- == geofront-lion-geo-borg ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-lion-geo-borg
name: "Geo-Borg: Lion Geo-Borg"
system: rifts
source_book: Rifts World Book 25: China 2 p.131-132
category: occ
tags: [augmented, wilderness, stealth, combat]
men_of_arms: true
occ_group: men-of-arms
xp_table: [0, 2121, 4241, 8481, 17001, 24901, 36301, 52601, 72901, 96001, 132301, 181601, 232901, 282301, 334601]
race_restrictions: { only: ["none"], note: "The Lion Geo-Borg is a giant lion body carrying the brain of a human (printed 131). In Rifts a human takes no R.C.C., so \"none\" is the human case." }
attribute_requirements: { IQ: 10, ME: 14 }
attribute_dice:
  PS: "44"
  PP: "24"
  Spd: "144"
mdc_base: 280
psionics:
  isp_base: "M.E. attribute number, +1d4 per level of experience"
  powers_starting: 0
bonuses:
  combat: { initiative: 2, strike: 3, parry: 1, dodge: 2, disarm: 4, pull_punch: 3, roll: 1 }
  saves: { spell_magic: 4, ritual_magic: 4, possession: 3, horror_factor: 3, other: [ { label: "vs Demonic Curses", bonus: 6 } ] }
  at_level:
    - { level: 3, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Chinese at 95%." }
    - { name: "Literacy: Chinese", base: 75, per_level: 5, note: "+20%" }
    - { name: "Camouflage", base: 30, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Intelligence", base: 48, per_level: 4, note: "+16%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 50, per_level: 5, note: "+25%. Printed as Tracking (people and demons)." }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "+10%. Printed as Track Animals." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Hand to Hand: Shao-Lin Kung Fu", base: 0, per_level: 0, note: "Shao-lin Kung Fu, though the book says it is not particularly applicable to the lion body. No other style is offered." }
  occ_related_skills:
    count: 9
    categories:
      - { name: "Espionage", bonus: 5 }
      - { name: "Technical", bonus: 5 }
      - { name: "Wilderness", bonus: 10 }
    minimums:
      - { count: 3, category: "Espionage" }
      - { count: 3, category: "Technical" }
      - { count: 3, category: "Wilderness" }
    note: "Three Espionage (+5%), three Technical (+5%) and three Wilderness (+10%) skills of choice."
  secondary_skills:
    count: 3
    categories: ["Domestic"]
    note: "Three selected from Domestic skills only."
equipment_starting:
  - { item_id: "ab-955-lion-geo-borg", qty: 1, note: "The cyborg body itself. This row points at the vessel of the same slug, which holds the body''s M.D.C. by location and its built-in weapons." }
special_abilities:
  - name: "Lion Body (AB-955 Full Conversion Cyborg)"
    description: "A reconnaissance and stealth full conversion cyborg: a human brain in the body of a giant lion, which may be taken for a Nature Spirit in forest and jungle. 4 ft (1.2 m) tall, 3 ft (0.9 m) wide at the hips, 2 tons. Main body 280 M.D.C. (reinforced; stored). M.D.C. by location: claws (2) 25 each, arms/front legs (2) 70 each, hind legs (2) 120 each, head 150 (reinforced). The head is a small target: a called shot at -3 to strike, and destroying it kills the character. Depleting the main body destroys the artificial body, but emergency systems keep the brain and vital organs alive for 18 plus 2D6 hours; recovered in time they can go on life support, otherwise the character dies. More than 100 M.D.C. below zero destroys the unit beyond recovery. Runs at 140 mph (224 km). Leaps 20 ft (6.1 m) high and 30 ft (9.1 m) across, 50% more with a running start. Cannot fly; swims at 40 mph (64 km) and survives depths to 800 ft (244 m). Bionic P.S. 44, P.P. 24 and Spd 144 (140 mph/224 km), stored as fixed attributes. Nuclear power. Mass production should bring the market cost to about 8-10 million credits; about 200 prototypes are in the field and a thousand more in production."
  - name: "Lion Natural Attacks"
    description: "Bionic P.S. 44: blunt pawing strike 2D6+22 S.D.C.; blunt power punch 3D4 M.D. (counts as two attacks); Vibro-Claw strike or kick 3D6+3 M.D.; bite 3D6 M.D."
  - name: "Concealed Forehead Lasers (2)"
    description: "Two small gem-like lasers in the forehead between the eyes. 2D6 M.D. per single blast, 4D6 M.D. if both fire at the same target; an individual or dual blast counts as one melee attack. Range 1000 ft (305 m). Payload effectively unlimited, tied to the power supply."
  - name: "Concealed Extendible Arms (2)"
    description: "A pair of light mechanical arms that extend from the chest to work machines, use weapons and even drive a car (at -25% to the skill). P.S. 10, P.P. 10, reach 3.5 ft (printed as 0.1 m). They can use any light Geofront weapons and tools, limited by weight and size."
  - name: "Standard Bionic Features"
    description: "All the same features as the Assault Geo-Borg''s A to H: bionic lung with gas filter and oxygen storage cell; language translator and 80 decibel loudspeaker; surveillance/listening package (radio receiver, scrambler and transmitter with a 100 mile/160 km range, amplified hearing, sound filtration system, sound identifier, universal headjack); climb cord with retractable winch, 200 ft (61 m); clock calendar, gyro-compass and depth gauge; concealed garrote wrist wire; multi-optic eyes; and four additional non-weapon enhancements of the player''s choice. Plus a full optical array (the same as the Scientist''s, only concealed), a Cyber-Camera concealed in one of the coils of the mane, and a skin and flesh hide that feels real (warm to the touch, fur and so on)."
  - name: "Combat Regimen (in place of a Mystic Martial Art Power)"
    description: "Lion Geo-Borgs learn no Mystic Martial Art Power, but have these bonuses: +1 extra attack per melee at levels 3, 5, 8 and 12 (in addition to those from Shao-lin Kung Fu), +2 on initiative, +3 to strike, +1 to parry, +2 to dodge, +4 to disarm, +3 to pull punch, +1 to roll with punch/fall/impact, +3 to save vs magic and Demonic Curses, +3 to save vs possession and +3 to save vs Horror Factor. With the class''s own +1 to save vs magic and +3 to save vs Demonic Curses, stored in the class bonuses."
trackable_resources: []
restrictions:
  - "REQUIRES FULL BIONIC CONVERSION into the lion body."
  - "The animal body cannot use handheld weapons; only the concealed extendible arms can, and only light weapons and tools."
  - "-60% to perform skills with the paws where hands are required."
  - "Shao-lin Kung Fu is the only hand to hand style."
level_progression:
  - { level: 3, grants: ["+1 attack per melee (combat regimen)"] }
  - { level: 5, grants: ["+1 attack per melee (combat regimen)"] }
  - { level: 8, grants: ["+1 attack per melee (combat regimen)"] }
  - { level: 12, grants: ["+1 attack per melee (combat regimen)"] }
extraction_notes: "Rifts World Book 25: China 2 printed 131-132 (cache p132-p133, a scan, every figure read off 200 dpi renders). The Lion Geo-Borg opens on printed 131 after the Assault Geo-Borg and ends on printed 132, where the Lightning Warriors begin. It is one of the Elite Military O.C.C.s of the Geofront Army (printed 128, heading Elite Geofront Forces), so occ_group men-of-arms and men_of_arms true. || XP: Geofront Technical Officer / Military Specialist / Geo-Borgs (all) ladder, printed 160 (cache p161), read off a render. || SKILLS: printed in full, no base class. Catalog base plus printed bonus: Mathematics: Basic 45+20, Literacy: Chinese 55+20, Camouflage 20+10, Climbing 40+5, Intelligence 32+16, Land Navigation 36+20, Lore: Demons & Monsters 25+15, Prowl 25+10, Swimming 50+10, Tracking (people) 25+25 (printed people and demons), Track & Trap Animals 20+10 (printed Track Animals), Wilderness Survival 30+15. Language: Chinese at 95% stored fixed. Related: three each of Espionage (+5%), Technical (+5%) and Wilderness (+10%), stored as nine picks with a floor of three per category, which fixes the split. Secondary: three, Domestic only; no later secondary or related picks are printed. || MYSTIC MARTIAL ART POWER: none; the class has bonuses instead, unconditional and stored. 2026-10-05, printed 132, read off a 200 dpi render of cache p133: the page''s own line reads Mystic Martial Art Power: None, so the Lion Geo-Borg is given no power, none is stored and there is no level table to show. The class''s own Bonuses line (+1 save vs magic, +3 save vs Demonic Curses) adds to the regimen''s (+3 vs magic and Demonic Curses): save vs magic 4, stored as both spell_magic and ritual_magic; Demonic Curses 6, as saves.other. || BODY: main body 280 M.D.C. is mdc_base. The body is also the vehicles row ab-955-lion-geo-borg (since ~085), and equipment_starting lists the gear pointer of the same slug (since ~113), which is how the sheet reaches it. Bionic P.S. 44, P.P. 24 and Spd 144 are fixed attribute_dice, the dragon-borg precedent. The extendible arms'' reach is printed 3.5 feet (0.1 m); the metric is a misprint (about 1.1 m) and the feet figure is kept. || I.S.P.: Permanent I.S.P. Base (Chi), M.E. attribute number +1D4 per level (not the other Geo-Borgs'' 1D6), is a psionics block with no type and no powers. || RACE: human only, from the human brain in the lion body. || MONEY: the military pays 1,200 credits a month and provides food, medical care, supplies and a private apartment; the book prints no starting savings, so starting_money is not stated. || EQUIPMENT: typically none in the field; a saddle exists for ceremonies and marches and is not starting kit, so equipment_starting holds the body''s own pointer and nothing else."
---

## Lore

The Lion Geo-Borg is the newest idea from Geofront''s Whack Job Scientists: a
human brain housed in the cyborg body of a giant lion, built for deep
reconnaissance in forest and jungle, where locals may take it for a Nature
Spirit. Lions are not native to China and the designers first planned a tiger,
but most of the volunteers asked for a lion, because the stone lions at temple
gates are there to keep demons out.

The beast body gives more raw power than a humanlike frame but cannot hold a
weapon; a pair of small mechanical arms folded into the chest handles tools and
light guns. Only a couple of hundred are in service, with many more being
built, and they have proven effective scouts and fighters and are popular with
the troops. Something about the lion seems to bring out the best in the people
who become one.

## GM Notes

A saddle has been designed so the Lion can be ridden, mostly for ceremonies
and military parades. The military pays 1,200 credits a month and provides
food, medical care, supplies and a private apartment.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-lion-geo-borg'
   AND instr(markdown, 'Nothing from the level-1-only rule (BOOK-INGEST-AUDIT.md F117) applies') > 0
   AND length(markdown) = 11067;

-- == geofront-gun-master ==
UPDATE imported_classes
   SET markdown = '---
id: geofront-gun-master
occ_group: men-of-arms
name: Geofront Gun Master
system: rifts
source_book: Rifts World Book 25: China 2 p.136-141
category: occ
tags: [combat, ranged]
xp_table: [0, 2201, 4401, 9001, 18001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_requirements:
  IQ: 9
sdc_base: "5d6+32"
starting_money: "5d6x100"
bonuses:
  attributes: { PS: "1d4", PE: 1, PP: 3, Spd: "1d6" }
  combat: { attacks: 1, parry: 1, dodge: 1, disarm: 2, roll: 2 }
  saves: { horror_factor: 2, possession: 1 }
psionics:
  isp_base: "M.E. attribute number +4d6, +5 per level of experience"
  powers_starting: 0
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Printed as Basic Math (+15%)." }
    - { name: "Camouflage", base: 30, per_level: 5, note: "+10%" }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Disguise", base: 35, per_level: 5, note: "+10%" }
    - { name: "Find Contraband", base: 38, per_level: 4, note: "+12%" }
    - { name: "Land Navigation", base: 48, per_level: 4, note: "+12%" }
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "Printed as Language: Native Chinese Speaker (95%)." }
    - { name: "Literacy: Chinese", base: 85, per_level: 5, note: "Printed as Literacy: Chinese characters/ideograms (85%)." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Meditation", base: 0, per_level: 0, note: "Powers of Meditation: the character is skilled in Meditation. Not a percentile skill; see the skill row." }
    - { name: "Military Etiquette", base: 50, per_level: 5, note: "+15%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Radio: Scramblers", base: 45, per_level: 5, note: "+10%" }
    - { name: "Recognize Weapon Quality", base: 45, per_level: 5, note: "+20%" }
    - { choose: 2, from: ["Acrobatics", "Aerobic Athletics", "Athletics (general)", "Body Building & Weight Lifting", "Boxing", "Climbing", "Gymnastics", "Prowl", "Running", "Swimming", "SCUBA"], bonus: 5, note: "Physical Skills: any two (+5% where applicable). The book prints Aerobic Athletics or General Athletics as one option." }
    - { choose: 1, from: ["Hand to Hand: Shao-Lin Kung Fu", "Hand to Hand: Dog Boxing Kung Fu (Kuo-Ch''uan)", "Hand to Hand: Drunken Style Kung Fu"], note: "Hand to Hand Martial Arts Skill: one as the basis of the character''s combat skills. Shao-Lin 60%, Dog Boxing 20%, Drunken Style 20%." }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0, note: "Tao Jen Qiang, level 1: W.P. Paired Weapons: Gun, two guns fired or used at once at the same or two different targets." }
    - { name: "W.P. Sharpshooting", base: 0, per_level: 0, note: "Tao Jen Qiang, level 1: W.P. Sharpshooting Gun Kata (Special), covering all ancient and modern firearms; see the special ability." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Communications", only: ["Surveillance"], bonus: 10 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Detect Concealment", "Intelligence", "Interrogation"], bonus: 2 }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Boxing", "Wrestling"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Air Assault Armor", "Flight System Combat", "Fighter Combat: Basic", "Fighter Combat: Elite"] }
      - { name: "Rogue", only: ["Gambling (Standard)", "Gambling (Dirty Tricks)", "Seduction", "Streetwise"] }
      - { name: "Science", only: ["Mathematics: Advanced", "Astronomy", "Astronomy & Navigation"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Wilderness", bonus: 5 }
    note: "Six at level one, one more at levels 3, 6, 9, 12 and 15. All new skills start at level one proficiency. Communications: Any (+5%, but +10% to Surveillance Systems). Domestic: Any. Electrical: Basic Electronics only. Espionage: Detect Concealment, Intelligence and Interrogation Techniques only (+2%). Horsemanship: General and Exotic Animals only. Mechanical: Automotive and Basic Mechanics only. Medical: First Aid only. Military: None. Physical: Any, except Boxing and Wrestling. Pilot: Any, except military vehicles, robots and power armor (tends to favor motorcycles, hovercycles, jeeps and hover cars). Pilot Related: None. Rogue: Gambling, Seduction and Streetwise only. Science: Mathematics: Advanced and Astronomy only (+5%). Technical: Any (+10%). W.P.: None! Never studies other types of weapons, uses only guns. Wilderness: Any (+5%)."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
      - { level: 15, count: 1 }
  secondary_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", only: ["Detect Concealment", "Intelligence", "Interrogation"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Boxing", "Wrestling"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Air Assault Armor", "Flight System Combat", "Fighter Combat: Basic", "Fighter Combat: Elite"] }
      - { name: "Rogue", only: ["Gambling (Standard)", "Gambling (Dirty Tricks)", "Seduction", "Streetwise"] }
      - { name: "Science", only: ["Mathematics: Advanced", "Astronomy", "Astronomy & Navigation"] }
      - "Technical"
      - "Wilderness"
    note: "Four at level one, one more at levels 3, 7, 9 and 13, from the related list and its limits (any, only, none), at base skill level."
    schedule:
      - { level: 3, count: 1 }
      - { level: 7, count: 1 }
      - { level: 9, count: 1 }
      - { level: 13, count: 1 }
equipment_starting:
  - { choose: 1, label: "S.D.C. pistol, revolver or submachine-gun (first of a pair)", qty: 1, from: ["china-ght-85-hounds-tooth-auto-mag", "9mm-model-p5-walther", "1878-colt-45-caliber-revolver", "1899-smith-wesson-38-revolver", "submachine-gun", "9mm-uzi"] }
  - { choose: 1, label: "S.D.C. pistol, revolver or submachine-gun (second of a pair)", qty: 1, from: ["china-ght-85-hounds-tooth-auto-mag", "9mm-model-p5-walther", "1878-colt-45-caliber-revolver", "1899-smith-wesson-38-revolver", "submachine-gun", "9mm-uzi"] }
  - { choose: 1, label: "energy pistol (first of two)", qty: 1, from: ["china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter"] }
  - { choose: 1, label: "energy pistol (second of two)", qty: 1, from: ["china-ght-88-brilliant-light-heavy-laser-pistol", "china-ght-89-double-tap-dual-laser-pistol", "china-ght-93-demon-knocker-ion-pulse-pistol", "china-ght-95-vaporizer-particle-beam-pistol", "china-g-91-geo-blaster-phased-emitter"] }
  - { item_id: "china-ghf-ak47-hounds-fang-assault-rifle", qty: 1, note: "The book prints one S.D.C. rifle; the Hound''s Fang is the Geofront''s standard-issue rifle." }
  - { choose: 1, label: "energy rifle", qty: 1, from: ["china-chi-sniper-rifle-demons-eye", "l-20-pulse-rifle", "ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle"] }
  - { item_id: "magazine-clips", qty: 48, note: "Eight clips for each of the six weapons; one third of the bullets are coated in silver." }
  - { item_id: "traveling-clothes", qty: 1, note: "Sturdy traveling clothes of cotton, wool and leather, part of his disguise for operations in the world." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "winter-jacket-hip-length", qty: 1, note: "A set of heavy winter/mountain over-garments." }
  - { item_id: "uniform", qty: 2, note: "Two everyday uniforms, kept at base." }
  - { item_id: "dress-uniform", qty: 1, note: "Kept at base, with one set of Lightning Strike armor." }
  - { item_id: "personalized-light-or-medium-mdc-body-armor", qty: 1, note: "Light (25-40 M.D.C.) or medium (50-70 M.D.C.) body armor with helmet; environmental, homespun or even magic armor, with a visor and built-in radio, worn as part of his disguise outside the Geofront." }
  - { item_id: "fake-identification", qty: 1, note: "Forged papers, including a passport from one of the Yama Kingdoms and letters of recommendation praising him as a good worker or freelance gun for hire." }
  - { item_id: "flare", qty: 6 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1, note: "Web vest or bandoleer with pouches and loops for ammo clips." }
  - { item_id: "multi-purpose-pouch", qty: 1, note: "A satchel with shoulder strap and a small neck pouch." }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "duffle-bag", qty: 1 }
  - { item_id: "gas-mask", qty: 1, note: "Gas mask or air filter." }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "passive-nightvision", qty: 1, note: "Passive nightvision scope." }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "book-paper-glued-100-sheets", qty: 1, note: "A small 100 page blank book for notes." }
  - { item_id: "pencil", qty: 1, note: "Pencil or pen." }
  - { item_id: "brushes-low-quality", qty: "1d4", note: "Calligraphy brushes; he does not know how to use them, they are part of the disguise." }
  - { item_id: "ink-black-6-ounces", qty: 1, note: "A block of ink." }
  - { item_id: "tea-per-lb", qty: 1, note: "Several packages of tea." }
  - { item_id: "kettle", qty: 1 }
  - { item_id: "knife-small", qty: 1, note: "A cooking knife." }
  - { item_id: "mini-tool-kit", qty: 1 }
  - { item_id: "field-gun-cleaning-kit", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "walkie-talkie", qty: 1 }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
  - { item_id: "canteen", qty: 2, note: "One modern canteen and one bamboo canteen of water." }
  - { item_id: "pocket-mirror", qty: 1 }
special_abilities:
  - { choose: 1, from: ["Tao Jen Qiang: The Way of the Patient Gun"], note: "Granted outright (printed 138); the pick only puts its level table on the sheet." }
  - name: "Tao Jen Qiang: The Way of the Patient Gun"
    description: "The Gun Master''s own Mystic Martial Art Power (special), in place of one of the book''s eleven. Level 1: W.P. Paired Weapons: Gun, One With the Gun, S.D.C. Bullets into M.D. Rounds and W.P. Sharpshooting Gun Kata (Special), each stored as its own ability or skill row on this class. The lines below are what each later level adds (printed 139-140). They are shown as text: none of it is added to the character''s numbers, the Permanent I.S.P. Base additions included, and every bonus applies only with a gun."
    progression:
      - { level: 2, text: "Sense if Gun is in Working Condition and Loaded: knows instantly whether a weapon works (though it may be imperfect) and is loaded; takes apart, cleans, unjams, reloads and repairs any gun in one tenth the usual time - two melee actions to reload, unjam or take apart a handgun (double for rifles), 1D6+1 minutes for basic repairs or a thorough cleaning. Extended Range: +10% range per level of experience, or instantly double the range of one weapon; I.S.P. Cost: 15 per melee round; not for weapons used by other people. Bonuses: +1 attack per melee when using a gun for the entire melee round, and +2D6 to Permanent I.S.P. Base." }
      - { level: 3, text: "Hand Strike with Gun: the handgun or rifle used as a blunt weapon adds +2D6 S.D.C./Hit Point damage to punch attacks against mortal foes, or does 2D4 M.D. (total) against demons, other supernatural beings, creatures of magic and any Mega-Damage opponent; I.S.P. Cost: 4 per melee round to inflict M.D. Parry with Gun: parries hand to hand and melee weapons (knife, sword, club) with the gun without damaging it; the usual parrying bonuses apply." }
      - { level: 4, text: "Sense Exact Ammunition Count: always knows exactly how much ammunition his weapons hold, and when a weapon has been fired by someone else, about how long ago, and whether it has been tampered with, booby-trapped or damaged. Conceal Weapon: palms handguns (revolvers, pistols and energy blasters) to keep them from being found when frisked, Base Skill 66% +2% per level of experience (-20% when frisked by another Gun Master, a Professional Thief or a Master Psychic); can also make up to two weapons invisible to metal and gunpowder detectors, X-ray machines and similar devices, I.S.P. Cost: 6 per melee round. Cannot conceal any other item." }
      - { level: 5, text: "Use Flawed Guns: as long as the weapon can fire, suffers no penalty from an old, flawed or damaged weapon. Fire Broken Guns: makes a broken weapon fire as if it were 100% operational; I.S.P. Cost: 6 per melee round. Bonuses: +1 attack per melee when using a gun, and +2D6 to Permanent I.S.P. Base." }
      - { level: 6, text: "Pull Gun Shot: shoots to nick or wing, doing as little as one point of damage and never more than 40% of the usual damage. Bullet Punch: a two-finger stabbing strike with the impact of a bullet, 5D6 S.D.C./Hit Point damage to mortals or 4D6 M.D. to Mega-Damage beings and structures; the hand must be empty; I.S.P. Cost: 4 per strike." }
      - { level: 7, text: "Telekinesis Guns: any loose gun he can see (not held, secured, tied down or locked up) flies into his hand; one melee attack/action, line of sight, 100 feet (30.5 m) at most; I.S.P. Cost: 6. Bonuses: +2 attacks per melee when using a gun for the entire melee round, and +2D6+6 to Permanent I.S.P. Base." }
      - { level: 8, text: "Shooting Blind: the usual penalty for shooting blind (-10 to strike) is halved (-5 to strike), and penalties for striking invisible targets are also halved. Create Bullets in Weapon: the weapon fires bolts of energy that inflict 3D6 S.D.C. or M.D., depending on the target, +2 points of damage for each additional level of experience; I.S.P. Cost: 10 per gun, per melee round." }
      - { level: 9, text: "Dodge Bullets: can attempt to dodge or parry any attack he can see aimed at him, at half his usual dodge and parry bonuses, with no other penalty (the -10 to dodge rule included)." }
      - { level: 10, text: "+1 to strike with guns, +2 to disarm with guns, +3 to perform a pulled gunshot, and +3D6+6 to Permanent I.S.P. Base." }
      - { level: 11, text: "Explosive Kick: a snapping kick that does 4D10 (or 1D4x10) damage plus any P.S. attribute damage, as S.D.C. or M.D. depending on the target. Does not work on Ghosts, Entities or energy beings; counts as one attack." }
      - { level: 12, text: "S.D.C. or M.D. Bullets/Rounds to Strike Spirits: any projectile or Chi-created bullet fired from a gun can hit and hurt Undead, Ghosts, Entities, Astral Beings, the intangible and energy beings; damage as per the ammunition, S.D.C. or M.D. depending on the target. I.S.P. Cost: 20 per melee round, per gun." }
      - { level: 13, text: "Bonuses: +1 attack per melee when using a gun, and +4D6+10 to Permanent I.S.P. Base." }
      - { level: 14, text: "Teleport Guns: makes two of his own guns, loaded and ready (or just two full ammo clips), appear in his hands; counts as two melee attacks/actions. The guns must belong to him and be stored or concealed within a 10 mile (16 km) radius. Can also teleport his guns to one secret location (home or supply depot). Guns only, nothing tied to them. I.S.P. Cost: 30." }
      - { level: 15, text: "The Patient Shot: spends one full melee round (15 seconds) aiming at one target for +6 to strike or disarm (with bullet), in addition to all other bonuses, for one precision shot; a hit is always a Critical Strike (double damage). On a Natural 19 or 20 the shot is either a Bull''s Eye, hitting the exact spot aimed at and shooting a weapon out of a hand if that was the aim, at normal damage, or a Critical Strike doing triple damage. Against a mortal target, a strike roll above the Armor Rating does damage direct to Hit Points. I.S.P. Cost: 10." }
  - name: "Tao Jen Qiang: One With the Gun"
    description: "Level 1 of The Way of the Patient Gun. Uses any kind of gun, projectile or energy, as if trained with it for years; heavy weapons excepted. When using a gun in combat, shooting or as a blunt weapon: +2 on initiative, +2 to strike (hand to hand or gunfire), and +1 to disarm with firearms (shooting a weapon out of a hand) at levels 1, 4, 8, 12 and 15. The bonuses apply only with a gun, so they are not in the class bonuses."
  - name: "Tao Jen Qiang: S.D.C. Bullets into M.D. Rounds"
    description: "Level 1. Channels Chi into the rounds of any gun so they do Mega-Damage equal to their S.D.C. damage (a 4D6 S.D.C. bullet does 4D6 M.D.). Works on M.D.C. armor, vehicles, dragons, demons, goblins and Mega-Damage beings with a physical body; not on the Undead, ghosts, entities, the intangible or energy beings. I.S.P. Cost: 2 per melee round of shooting per gun (4 if two guns fire that round)."
  - name: "W.P. Sharpshooting Gun Kata (Special)"
    description: "Level 1. Covers all ancient and modern firearms: revolvers, pistols, rifles, shotguns, submachine-guns and rifle-style grenade launchers; not machine-guns, rail guns, flame throwers, bazookas, rocket and mini-missile launchers or other heavy weapons, not melee or thrown weapons, not bows. Bonuses, in addition to all others: Aimed shot (single or aimed burst) +1 to strike, plus +1 for every five P.P. points above 20, aimed, burst and Called Shots only. Called Shot: in place of the aimed bonus, +1 to strike plus +1 for every three P.P. points above 18, with a gun only; counts as two melee attacks. Quick Draw: +2 to initiative, plus +1 for every four P.P. points above 18. +1 melee attack when using one or two guns for the entire melee round. Gets ALL six Trick Shots: fire a two-handed weapon one-handed without penalty; shoot over the shoulder with a mirror at full strike bonuses; shoot accurately from a horse or moving vehicle at half strike bonuses (no Called Shot); shoot upside down or hanging at full bonuses; dodge, roll or somersault and come up shooting on a straight roll; and the ricochet shot, one point to the first surface and full damage to a second target at half strike bonuses (lasers need a mirrored or polished surface; no particle beams, ion blasters, rail guns or missiles)."
  - name: "Trained to Sense and Manipulate Chi"
    description: "Gathers and directs Chi, the life force present even where P.P.E. is weak, to add Mega-Damage to ordinary weapons through Tao Jen Qiang."
  - name: "Powers of Meditation"
    description: "Skilled in Meditation, focusing inner strength and sensing the stirring of subtle Chi. Will never have psionic powers other than the abilities of Tao Jen Qiang. Permanent I.S.P. Base: M.E. attribute number +4D6, +5 I.S.P. per level of advancement, plus the Tao Jen Qiang additions at levels 2, 5, 7, 10 and 13."
  - name: "Guns Only"
    description: "Trains only with guns and never uses any other weapon. Without a gun, anything at hand gets no bonuses beyond attributes and physical skills; heavy weapons such as bazookas and rail guns are used on unmodified dice rolls."
level_progression:
  - { level: 2, grants: ["Tao Jen Qiang: Sense if Gun is in Working Condition and Loaded; strip, clean, unjam, reload and repair any gun in a tenth of the usual time", "Extended Range: +10% range per level, or double one weapon''s range for 15 I.S.P. a melee round", "+1 attack per melee when using a gun for the entire melee round; +2D6 to Permanent I.S.P. Base"] }
  - { level: 3, grants: ["Tao Jen Qiang: Hand Strike with Gun, +2D6 S.D.C. to punches, or 2D4 M.D. against supernatural and Mega-Damage foes for 4 I.S.P. a melee round", "Parry with Gun", "+1 O.C.C. Related Skill", "+1 Secondary Skill"] }
  - { level: 4, grants: ["Tao Jen Qiang: Sense Exact Ammunition Count", "Conceal Weapon: palm handguns, 66% +2% per level; hide up to two from detectors for 6 I.S.P. a melee round", "+1 to disarm with firearms"] }
  - { level: 5, grants: ["Tao Jen Qiang: Use Flawed Guns without penalty", "Fire Broken Guns as if fully working, 6 I.S.P. a melee round", "+1 attack per melee when using a gun; +2D6 to Permanent I.S.P. Base"] }
  - { level: 6, grants: ["Tao Jen Qiang: Pull Gun Shot, as little as one point and never more than 40% of normal damage", "Bullet Punch: empty-handed two-finger strike, 5D6 S.D.C. or 4D6 M.D., 4 I.S.P. a strike", "+1 O.C.C. Related Skill"] }
  - { level: 7, grants: ["Tao Jen Qiang: Telekinesis Guns, a loose gun in sight flies to his hand, 100 ft, one action, 6 I.S.P.", "+2 attacks per melee when using a gun for the entire melee round; +2D6+6 to Permanent I.S.P. Base", "+1 Secondary Skill"] }
  - { level: 8, grants: ["Tao Jen Qiang: Shooting Blind at half the usual penalty (-5), and half the penalty against invisible targets", "Create Bullets in Weapon: energy bolts of 3D6 S.D.C. or M.D., +2 per further level, 10 I.S.P. per gun per melee round", "+1 to disarm with firearms"] }
  - { level: 9, grants: ["Tao Jen Qiang: Dodge Bullets, dodge or parry any attack he can see at half his usual bonuses, with no -10 penalty", "+1 O.C.C. Related Skill", "+1 Secondary Skill"] }
  - { level: 10, grants: ["Tao Jen Qiang: +1 to strike with guns, +2 to disarm with guns, +3 to a pulled gunshot; +3D6+6 to Permanent I.S.P. Base"] }
  - { level: 11, grants: ["Tao Jen Qiang: Explosive Kick, 4D10 (or 1D4x10) plus P.S. damage, S.D.C. or M.D. by target; one attack; not on ghosts, entities or energy beings"] }
  - { level: 12, grants: ["Tao Jen Qiang: S.D.C. or M.D. Bullets to Strike Spirits, hitting the Undead, ghosts, entities, astral beings, the intangible and energy beings, 20 I.S.P. per gun per melee round", "+1 to disarm with firearms", "+1 O.C.C. Related Skill"] }
  - { level: 13, grants: ["Tao Jen Qiang: +1 attack per melee when using a gun; +4D6+10 to Permanent I.S.P. Base", "+1 Secondary Skill"] }
  - { level: 14, grants: ["Tao Jen Qiang: Teleport Guns, two of his own guns (or two full clips) from within 10 miles appear in his hands, or send them to one secret location; two actions, 30 I.S.P."] }
  - { level: 15, grants: ["Tao Jen Qiang: The Patient Shot, a full melee round aiming for +6 to strike or disarm and an automatic Critical Strike; a natural 19 or 20 is a Bull''s Eye or triple damage; 10 I.S.P.", "+1 to disarm with firearms", "+1 O.C.C. Related Skill"] }
restrictions:
  - "Never uses any weapon but guns: no W.P.s other than those of Tao Jen Qiang, and no knife, sword, club or other melee weapon."
  - "Cybernetics: none to start. Tends to avoid bionics and even simple implants; takes pride in all his skills being natural."
  - "Will never have additional psionic powers beyond the abilities of Tao Jen Qiang."
  - "One set of Lightning Strike armor, kept at base, has no gear row."
extraction_notes: "OWN CLASS: printed 136-141 prints its own full skill list; no base class. GROUP: the book''s Elite Geofront Forces section (printed 128), so men-of-arms. ATTRIBUTE REQUIREMENTS: I.Q. 9 minimum; P.P. \"should be above 13\" with a high M.E. and P.E. helpful but not required, which is advice, so only I.Q. is stored. RACE: none, though predominately human; female Gun Masters are under 20%. BONUSES: the O.C.C. bonuses (+1D4 P.S., +1 P.E., +3 P.P., +1D6 Spd, +1 attack, +1 parry and dodge, +2 disarm, +2 roll, +2 vs Horror Factor, +1 vs possession) are unconditional and stored. Every Tao Jen Qiang and Sharpshooting bonus applies only with a gun, so none is in bonuses: they are in the special abilities and level_progression. TAO JEN QIANG (2026-10-05, printed 138-140, read off 200 dpi renders of cache p139-p141): the page''s power 3 is headed Mystic Martial Art Power (special) and says the character has been initiated into the practice of Tao Jen Qiang; the class is given this art of its own and none of the book''s eleven Mystic Martial Art Powers, with no choice. Its table, headed Tao Jen Qiang - The Way of the Patient Gun, runs 1st to 15th level. Level 1 is stored as granted special abilities and the W.P. Paired Weapons and W.P. Sharpshooting skill rows. Levels 2-15 are the progression of the ability Tao Jen Qiang: The Way of the Patient Gun (BOOK-INGEST-AUDIT.md F117), held through a one-option pick so that the sheet shows the lines reached and the next one; it is display only, so nothing a later level says is added to the character''s numbers. The same levels are also still listed in level_progression beside the skill picks. The Permanent I.S.P. additions at levels 2, 5, 7, 10 and 13 (+2D6, +2D6, +2D6+6, +3D6+6, +4D6+10) are text and not added to the pool. I.S.P.: M.E. +4D6, +5 per level. S.D.C.: 5D6+32. HAND TO HAND: a pick of Shao-Lin, Dog Boxing or Drunken Style; the book sells no other, so costs is empty. SKILLS: Basic Math is Mathematics: Basic; Language: Native Chinese Speaker 95% is Language: Native Tongue; Literacy: Chinese is printed at 85%, stored as the base with the catalog''s per-level gain; Meditation is the China row. Physical: any two from the printed list at +5%; Aerobic Athletics or General Athletics is printed as one option and both rows are offered. RELATED: Communications +5% with a second entry giving Surveillance its +10%; Interrogation Techniques is the catalog''s Espionage Interrogation row, since the Military row of that name is unreachable to a class with Military: None; Gambling is both catalog Gambling rows; Science''s Astronomy is both Astronomy and Astronomy & Navigation; Pilot excludes every robot, power armor, military vehicle and fighter-combat row in the catalog by name, so a new such row will be offered until it is added; Military, Pilot Related and W.P. are None and absent. SECONDARY: four plus one at 3, 7, 9 and 13, limited by the same list without its bonuses. EQUIPMENT: the pair of S.D.C. pistols, revolvers or submachine-guns, two energy pistols and the energy rifle are choices over the Geofront guns and catalog samples; the S.D.C. rifle is the GHF-AK47; eight clips per weapon as 48 magazine clips. The light or medium armor is the catalog''s Personalized Light or Medium M.D.C. Body Armor. The satchel and neck pouch are one multi-purpose pouch; herbs, a traveler''s tea bottle, two sets of chopsticks, 30 cups of uncooked rice, a comb and personal items have no rows and are left out. Six flares are the plain flare row. MONEY: 5D6x100 credits; monthly pay 1,200 credits with all needs provided. NPC average level 1D6+3. ALIGNMENT: any; Principled 20%, Scrupulous 40%, Unprincipled 20%, Aberrant 10%. XP: the Jian Shih, Gun Master and Spirit Host ladder, printed 160, read off a render."
---

## Lore

The Gun Master belongs to the Phoenix Division, an elite strike force of the
Geofront, and practises Tao Jen Qiang, the Way of the Patient Gun: a mystic
martial art that channels Chi through modern firearms. He trains with guns and
nothing else, and is rarely seen with fewer than several handguns and a pair
of rifles, with a trunk of spares close by.

Gun Masters are among the Geofront''s most aggressive soldiers and the ones
most often sent to the surface, in squads and platoons that hunt demons, raid
enemy supply lines, defend besieged villages and rescue captive humans. They
often go out disguised as mercenaries, bandits, lawmen or peasants, carrying
nothing that ties them to the Geofront.

They see themselves as patriots first: defenders of the true China and its
people, sworn to free the land from the Yama Kings, and ready to fight beside
anyone, dragon, spirit or D-Bee, who opposes them.

## GM Notes

Outside China every Chi-based power weakens (printed 141): the Chi pool, the
Chi a character can draw on, and the range, duration and damage of Chi powers
are halved, combat bonuses from Mystic Martial Art Powers drop by one, and
characters above sixth level lose one attack per melee. None of this is
stored.
',
       updated_at = datetime('now')
 WHERE class_id = 'geofront-gun-master'
   AND instr(markdown, 'levels 2-15 are prose in level_progression, not modelled (BOOK-INGEST-AUDIT.md F117)') > 0
   AND length(markdown) = 23048;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 11 classes carry their new text' AS assertion, count(*) AS got, 11 AS want
  FROM imported_classes
 WHERE (class_id = 'geofront-shadow-warrior' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p137)') > 0)
    OR (class_id = 'geofront-technical-officer' AND instr(markdown, 'MYSTIC MARTIAL ART POWER CHECKED AGAINST A RENDER (cache p127)') > 0)
    OR (class_id = 'fu-yao-da-chia' AND instr(markdown, 'one power, chosen once, and the page gives no later pick of a second') > 0)
    OR (class_id = 'demon-and-dead-slaver' AND instr(markdown, 'give the Slaver NO Mystic Martial Art Power, so there') > 0)
    OR (class_id = 'goblin-wrangler' AND instr(markdown, 'give the Wrangler NO Mystic Martial Art Power (item 9') > 0)
    OR (class_id = 'enlightened-demon' AND instr(markdown, 'at_levels: [10]') > 0)
    OR (class_id = 'soothsayer' AND instr(markdown, 'and there is no level table to show') > 0)
    OR (class_id = 'geofront-assault-geo-borg' AND instr(markdown, 'the page''s own line reads Mystic Martial Art Power: None') > 0)
    OR (class_id = 'geofront-demon-eater-geo-borg' AND instr(markdown, 'the page''s own line reads Mystic Martial Art Power: None') > 0)
    OR (class_id = 'geofront-lion-geo-borg' AND instr(markdown, 'the page''s own line reads Mystic Martial Art Power: None') > 0)
    OR (class_id = 'geofront-gun-master' AND instr(markdown, 'Tao Jen Qiang: The Way of the Patient Gun') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'geofront-shadow-warrior' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported (BOOK-INGEST-AUDIT.md F117).') > 0)
    OR (class_id = 'geofront-technical-officer' AND instr(markdown, 'the abilities each power grants at levels 2-15 are not imported, BOOK-INGEST-AUDIT.md F117.') > 0)
    OR (class_id = 'fu-yao-da-chia' AND instr(markdown, 'Mystic Martial Art Power: one of these four. Level 1 abilities only.') > 0)
    OR (class_id = 'demon-and-dead-slaver' AND instr(markdown, 'and F117 (later levels). The Slaver takes no Mystic Martial Art Power.') > 0)
    OR (class_id = 'goblin-wrangler' AND instr(markdown, 'Later picks are prose, per') > 0)
    OR (class_id = 'enlightened-demon' AND instr(markdown, 'level 1 only, per Nate 2026-10-01; see BOOK-INGEST-AUDIT.md F117') > 0)
    OR (class_id = 'soothsayer' AND instr(markdown, 'so nothing from BOOK-INGEST-AUDIT.md F117 applies') > 0)
    OR (class_id = 'geofront-assault-geo-borg' AND instr(markdown, 'Nothing from the level-1-only rule (BOOK-INGEST-AUDIT.md F117) applies') > 0)
    OR (class_id = 'geofront-demon-eater-geo-borg' AND instr(markdown, 'Nothing from the level-1-only rule (BOOK-INGEST-AUDIT.md F117) applies') > 0)
    OR (class_id = 'geofront-lion-geo-borg' AND instr(markdown, 'Nothing from the level-1-only rule (BOOK-INGEST-AUDIT.md F117) applies') > 0)
    OR (class_id = 'geofront-gun-master' AND instr(markdown, 'levels 2-15 are prose in level_progression, not modelled (BOOK-INGEST-AUDIT.md F117)') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('geofront-shadow-warrior', 'geofront-technical-officer', 'fu-yao-da-chia', 'demon-and-dead-slaver', 'goblin-wrangler', 'enlightened-demon', 'soothsayer', 'geofront-assault-geo-borg', 'geofront-demon-eater-geo-borg', 'geofront-lion-geo-borg', 'geofront-gun-master') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~169-china-2-martial-art-power-levels-part-2.sql');
