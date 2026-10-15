-- BOOK-INGEST-AUDIT F140: settle the unsettled sentences on the China 2 Enlightened Demon
-- 1 class, each replaced whole: enlightened-demon.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~209-book-ingest-audit-f140-china-2.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Three sentences on the Enlightened Demon (Rifts World Book 25: China 2,
-- printed 96-101) were false on 2026-10-15, each tested against a 150 dpi
-- render of printed 98 to 101 and against production:
-- - the extraction note said the 5th-level Hand to Hand styles were stored at
--   cost 0 with conditions; the class stores hand_to_hand costs {}, which
--   handToHandCost() reads as null (not offered) for every style;
-- - the GM note said the app offers those styles free at any level; the wizard
--   offers none and the sheet refuses one outside Show all skills;
-- - the extraction note's count of rows citing China 1 (production held 86 on
--   2026-10-15: 39 creatures, 24 spells, 23 notable NPCs). The count is
--   replaced by the seven creature slugs and a pointer to the china-1 survey.
-- No grant, key or catalog row changes.

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
extraction_notes: "Rifts World Book 25: China 2 printed 96-101 (cache p097-p102, a scan, page_offset +1), every number read off 200 and 300 dpi renders. The section opens under Enlightened Demon R.C.C. - Optional at the foot of printed 96 and ends at the top of the right column of printed 101 (Starting Age); the Green Scarf magic items follow. The book marks the R.C.C. optional. DEMON FORM: the book takes the demon type and its base statistics from Rifts China One (Lesser Demons, pages 84-105; Unique Demonic Powers, 145-149). The Lesser Demons of 84-105 are creature rows now (all seven named below: chuan-ti, falcon-demon, ma-tou, monkey-wolf, ox-head-demon, pig-demon and yang-ching; the china-1 survey''s Rows line counts every row citing that book); the class does not grant or list them and still keeps the demon form in prose. The Unique Demonic Powers of 145-149 still have no rows. Nate''s decision, 2026-10-01 (survey china-2.md, Agreed with Nate, item 3): import it now with the demon form in prose. Use the Lesser Demon''s statistics from Rifts China One for the Demon Form; no demon attribute dice, M.D.C., attacks or powers are invented here. The per-demon retentions of printed 98 (Ch''uan Ti keeps Prehensile Tongue and Alter Scent; Falcon Demon keeps Winged Flight, loses Metamorphosis: Firefly at 6th; Ma T-ou keeps Weapon Master: Small Blades in both forms, loses Metamorphosis: White Steed at 5th; Monkey-Wolf''s Human Form is its Metamorphosis: Human form, keeps Prehensile Tail and Run with the Wind, loses Metamorphosis: Wolf at 8th; Ox-Head keeps its horns in Human Form, shrinking to nubs by 15th, keeps Heightened Hearing and Fantastic Endurance, loses Metamorphosis: Black Bull at 7th; Pig Demon keeps Weapon Master: Peasant Tools and Contacts & Connections in both forms and Heightened Smell in Demon Form, loses Metamorphosis: Pig at 7th; Yang Ching keeps Weapon Master in both forms and Turns Invisible in Fog or Mist in Demon Form; Ch''uan Ti is also reduced to 1st level at enlightenment) are in the Demon Origins section. HUMAN FORM is what is stored: the book says to roll the eight attributes (Human Form) as normal for human characters, stored as 3D6 each. Base S.D.C. 4D6+20 (once converted from M.D.C.) is stored as sdc_base, because the book prints it as this R.C.C.''s own base with its own O.C.C. skill list rather than as a bonus added to an occupation''s; hit points are not printed and take the core rule. No men_of_arms line, because sdc_base is stated. P.P.E.: 6D6 + P.E., +1D4 per level (printed 100). Bonuses (printed 100, headed O.C.C. Bonuses): +3 I.Q., +2 M.A., +1D6 P.S., +3 save vs magic (stored as spell and ritual magic), +6 save vs Horror Factor, +2 save vs possession at levels 2, 6, 12 and 14. HUMAN FORM I.S.P. (printed 98): M.E. +4D6, +4 per level, gained at 3rd level, when the character also loses the use of psionic powers in Human Form; no psionics block is stored, because the pool does not exist at creation and no powers come with it, so it is in the level progression to record by hand. XP: cache p161 (printed 160), column headed Enlightened Demon / Monk: Chi-Gung Sen Ren / Warrior: Nei Chia Wu Shih, read off a render. Skills (printed 100-101): Language: Native Chinese Speaker 95% is the catalog''s Language: Chinese at a flat 95; Games: Tiao Qi +15% is Tiao Qi/Chinese Checkers (24+15); Lore: Demons & Monsters +40% (25+40); Lore: any two is a choice over the catalog''s Lore rows; Hand to Hand: Demon Wrestling (+25%) is the catalog''s Demon Wrestling percentile skill (30+25), not a Hand to Hand style. Torment (Base Skill 88%) has no catalog row and is a special ability. Meditation (3rd level) and the 2nd-level Chi weapon W.P. are level-gated grants and are in the level progression, to add by hand. HAND TO HAND (printed 98-99): none at first level; at 5th level one Advanced Hand to Hand Chinese Martial Art is gained free and begun at its own 5th level, or optionally Basic Hand to Hand: Tai Chi (catalog Hand to Hand: Tai-Chi Ch''uan) plus two more O.C.C. skills. Stored as hand_to_hand costs {}, a class that sells no style (BOOK-INGEST-AUDIT.md F140, 2026-10-15: no price, timing or condition is stored for the seven), so the 5th-level style and the two extra skills are recorded by hand. Related skills: two at level 1, one more at 2, 3, 4, 5, 6, 7, 8, 10, 12 and 14. The categories marked none at first level, but any thereafter are offered, with that limit in the note; Military and Rogue are none and are left out. W.P. Heavy Weapons and Heavy Energy Weapons are read as the catalog''s W.P. Heavy Military Weapons and W.P. Heavy M.D. Weapons. Secondary: three at level 1, one more at 2, 4, 8, 10, 12 and 14. MYSTIC MARTIAL ART POWER at 10th level (2026-10-05, printed 99, read off a 200 dpi render of cache p100): the page heads the entry 10th Level: Human Martial Art Powers and says to choose one of Mien-Ch''uan Kung Fu (Cotton Fist), Pao Chih (Animus Development), She Shen Kung Fu (Snake Style), Tong Lun Kung Fu (Praying Mantis Style) or Xian Tai Chi Chuan (Chi Manipulation), and that the Enlightened Demon, now 10th level, will start the Martial Art Power at the 10th level of advancement and then level up in the usual way. Stored as a pick of one from those five at level 10 (BOOK-INGEST-AUDIT.md F116), each option the book''s power under its shared name. A power''s level table is keyed to the character''s level (BOOK-INGEST-AUDIT.md F117), so a power taken at 10th level shows its lines through level 10 at once and the 11th next, which is the printed start at the power''s 10th level. The table is shown on the sheet as text, display only: nothing a later level says is added to the character''s numbers. The Mystic Martial Art Power section below is a short summary of each option''s first level. EQUIPMENT (printed 101): the neck pouch, hairbrush and personal items have no catalog rows and are noted on the small sack rather than stubbed. The Human Form Advancement and Demon Form Dissolution ladders (printed 98-100) are in level_progression."
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

The Demon Form is not modelled: look up the chosen Lesser Demon in Rifts China One and track its M.D.C., attacks and powers by hand, applying the losses in the level progression. The Human Form I.S.P. (from 3rd level), the 2nd-level Chi weapon W.P., Meditation at 3rd level and the two extra O.C.C. skills of the Tai Chi option are recorded by hand. The 10th-level Mystic Martial Art Power is a pick the sheet banks at 10th level. The class sells no Hand to Hand style, so the wizard offers none at creation and the sheet refuses one outside its Show all skills override: at 5th level, record the chosen Chinese Martial Art (or Tai Chi) by hand.
',
       updated_at = datetime('now')
 WHERE class_id = 'enlightened-demon'
   AND instr(markdown, 'Stored as cost 0 for those seven styles') > 0
   AND length(markdown) = 43594;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 1 classes carry their new text' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes
 WHERE (class_id = 'enlightened-demon' AND instr(markdown, 'a class that sells no style') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'enlightened-demon' AND instr(markdown, 'Stored as cost 0 for those seven styles') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('enlightened-demon') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~209-book-ingest-audit-f140-china-2.sql');
