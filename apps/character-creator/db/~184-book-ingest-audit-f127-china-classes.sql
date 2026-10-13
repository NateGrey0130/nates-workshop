-- Three China 2 classes state their Body Hardening schedule per level.
-- 3 classes, each replaced whole: fu-yao-da-chia, demon-and-dead-slaver, goblin-wrangler.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~184-book-ingest-audit-f127-china-classes.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
--
-- BOOK-INGEST-AUDIT F127, the data half. The three Demon Queller classes kept
-- their later Body Hardening picks by hand, because a pick group held one count
-- for every level it listed. An at_levels entry may now state its own count
-- (#1791), so each group states the page's whole schedule:
--
--   fu-yao-da-chia         four at level 1, one at 3, 6, 9, 12, 15  (printed 79)
--   demon-and-dead-slaver  two at level 1, one at 4, 8, 12          (printed 84)
--   goblin-wrangler        two at level 1, one at 3, 6, 9, 12, 15   (printed 90;
--                          its Vital Breath group is untouched)
--
-- The schedules were re-read 2026-10-13 in the OCR cache (cache pages 80, 85 and
-- 91) and agree with what each class's notes already recorded. In each class:
-- the group line, its note, and the two extraction_notes passages that said the
-- later picks were made by hand. Nothing else in the three classes moves.

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
  - { choose: 1, at_levels: [{ level: 1, count: 4 }, 3, 6, 9, 12, 15], from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Vital Breath", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: four to start, then one more at each of levels 3, 6, 9, 12 and 15, from this same list (printed 79)." }
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
    levels 3, 6, 9, 12 and 15 (printed 79). One group over the shared block
    states the whole schedule, four at level 1 and one at each later level
    (BOOK-INGEST-AUDIT.md F127). Mystic Martial Art Power: one of Cotton Fist, Touch
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
    the eleven exercises, unchanged that day. On 2026-10-13 the exercise group
    took the five later picks as well, each level stating its own count
    (BOOK-INGEST-AUDIT.md F127; the schedule re-read on printed 79, cache
    p080). The chosen power''s later levels are shown on the sheet as text
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
   AND instr(markdown, 'so four-then-one cannot be stated') > 0
   AND length(markdown) = 41193;

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
  - { choose: 1, at_levels: [{ level: 1, count: 2 }, 4, 8, 12], from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Vital Breath", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: two to start, then one more at each of levels 4, 8 and 12, from this same list (printed 84)." }
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
    levels 4, 8 and 12 (printed 84). One group over the shared block states
    the whole schedule, two at level 1 and one at each later level
    (BOOK-INGEST-AUDIT.md F127). The Slaver takes no Mystic Martial Art Power.
  - 2026-10-05, re-read off renders of printed 84-85 and 92-94. Printed 84, item
    4 (Demon Hunter Body Hardening Exercises): select two Demon Queller Body
    Hardening Exercises to start, then one additional at levels 4, 8 and 12.
    The page''s eight numbered items (Undead Entrepreneur, the Binding Stamp,
    Green Scarf gear, Body Hardening, Psionics, Docile Demonic Slave, O.C.C.
    Bonuses, Base S.D.C.) give the Slaver NO Mystic Martial Art Power, so there
    is no power level table to show and nothing of that kind is missing. The
    only other picks at set levels are the psionic powers of the three highest
    bands of item 5, already stored as each option''s powers_schedule. Stored:
    the choose 2 over the eleven exercises, unchanged that day. On 2026-10-13
    the exercise group took the three later picks as well, each level stating
    its own count (BOOK-INGEST-AUDIT.md F127; the schedule re-read on printed
    84, cache p085).
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
   AND instr(markdown, 'so two-then-one cannot be stated') > 0
   AND length(markdown) = 31338;

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
  - { choose: 1, at_levels: [{ level: 1, count: 2 }, 3, 6, 9, 12, 15], from: ["Body Hardening: Control Revulsion", "Body Hardening: Demon Digestion", "Body Hardening: Dislocation Training", "Body Hardening: Feign Death", "Body Hardening: Hardened Internal Organs", "Body Hardening: Heal Internal Organs and Injury", "Body Hardening: Laugh at Pain", "Body Hardening: Life Stone", "Body Hardening: Resist Psychic Drain", "Body Hardening: Yung Chin (Eternal Clarity)"], note: "Demon Queller Body Hardening: two more to start, then one more at each of levels 3, 6, 9, 12 and 15, from this same list (printed 90)." }
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
    other two and the five later picks are one group over the remaining ten,
    two at level 1 and one at each later level (BOOK-INGEST-AUDIT.md F127).
  - 2026-10-05, re-read off renders of printed 89-90 and 92-94. Printed 90, item
    4 (Demon Hunter Body Hardening Exercises): start with Vital Breath, select
    another two Demon Queller Body Hardening Exercises to start, then one
    additional at levels 3, 6, 9, 12 and 15. The page''s eleven numbered items
    give the Wrangler NO Mystic Martial Art Power (item 9: no psionic powers
    beyond using the Steel Whip as a mega-damage weapon), and nothing else is
    picked at set levels apart from skills. Stored: Vital Breath as a
    one-option choose 1 and a choose 2 over the other ten, both unchanged that
    day. On 2026-10-13 the group over the other ten took the five later picks
    as well, each level stating its own count (BOOK-INGEST-AUDIT.md F127; the
    schedule re-read on printed 90, cache p091).
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
   AND instr(markdown, 'so two-then-one cannot be stated') > 0
   AND length(markdown) = 25560;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 3 classes carry their new text' AS assertion, count(*) AS got, 3 AS want
  FROM imported_classes
 WHERE (class_id = 'fu-yao-da-chia' AND instr(markdown, 'at_levels: [{ level: 1, count: 4 }, 3, 6, 9, 12, 15]') > 0)
    OR (class_id = 'demon-and-dead-slaver' AND instr(markdown, 'at_levels: [{ level: 1, count: 2 }, 4, 8, 12]') > 0)
    OR (class_id = 'goblin-wrangler' AND instr(markdown, 'at_levels: [{ level: 1, count: 2 }, 3, 6, 9, 12, 15]') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'fu-yao-da-chia' AND instr(markdown, 'so four-then-one cannot be stated') > 0)
    OR (class_id = 'demon-and-dead-slaver' AND instr(markdown, 'so two-then-one cannot be stated') > 0)
    OR (class_id = 'goblin-wrangler' AND instr(markdown, 'so two-then-one cannot be stated') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('fu-yao-da-chia', 'demon-and-dead-slaver', 'goblin-wrangler') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~184-book-ingest-audit-f127-china-classes.sql');
