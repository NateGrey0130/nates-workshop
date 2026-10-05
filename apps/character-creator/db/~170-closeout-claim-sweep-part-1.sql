-- Correct sentences the close-out's claim sweep found false, part 1 of 2
-- 14 classes, each replaced whole: condoroid, falconoid, apok, gypsy-enforcer, gypsy-thief-russian, hidden-witch, gypsy-thief, lyvorrk, malvoren, mraghiile-tree-man, obsedai, ngr-robot-soldier, slayer-russian, totem-warrior.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~170-closeout-claim-sweep-part-1.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- The close-out's final claim sweep, part 1 of 2. claim-capability-verifier
-- judged 988 sentences that claim a limit ("by hand", "not applied", "is
-- prose", "cannot", a finding number) in the 218 classes the retrospective
-- close-out touched: 73 no longer true, 8 citing a finding for a gap it never
-- covered, 36 unsettled. These two scripts take the ones that need no page
-- read:
--
--   The sentence was wrong and the class's DATA was already right (17
--   classes): a bonus said to be "rolled by hand" that sits in bonuses as
--   dice; a scoped category bonus said to be "not stored" that a second
--   category entry carries; an experience table said to be "not stored" that
--   is; a save "with no field" that is in saves. Only the sentence changes.
--
--   A finding cited for the wrong gap (9 classes): seven D-Bees classes cited
--   F116 for per-level growth, past-ladder levels or category-limited skill
--   picks, which F116 (an ability picked from a named list at set levels)
--   does not cover; the Oni and the Amphib cited F119 for attribute_dice,
--   which F120 built.
--
--   Two classes close-out package C2 added, corrected: a pool bonus adds only
--   to a base the class states (js/dice.js), so the Gene-Splicer Mutant's
--   Body-row M.D.C. and the Phase World alien's M.D.C. rows added nothing.
--   The Gene-Splicer, every one of which is a mega-damage creature (printed
--   39), now states an M.D.C. base of zero for the Body row to add to. The
--   alien builder, most of whose races are S.D.C. beings, cannot state one;
--   its rows and notes now say the M.D.C. is entered by hand.
--
-- Nothing a class grants changes except the Gene-Splicer Mutant's mdc_base.
-- The stale claims that need a page read or a ruling before the DATA can
-- move are listed in the pull request, not changed here.

-- == condoroid ==
UPDATE imported_classes
   SET markdown = '---
id: condoroid
name: Condoroid
system: rifts
source_book: Rifts World Book 9: South America 2 p.146-148
category: rcc
tags: [wilderness, flyer]
horror_factor: 8
xp_table: [0, 2401, 4801, 9601, 19201, 29001, 38001, 55001, 78001, 99001, 132001, 182001, 232001, 282001, 343001]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+6"
  MA: "3d4"
  PS: "3d6+4"
  PP: "2d6+10"
  PE: "3d6+8"
  PB: "2d4"
  Spd: "3d6"
hit_points_base: "P.E. x2 + 2d4 per level"
sdc_base: "2d4x10+20"
ppe_base: "2d6"
starting_money: "2d6x100"
psionics:
  type: "master"
  isp_base: "2d4x10+10 plus M.E. attribute number, +2d6 per level of experience"
  powers: ["Psi-Sword", "Psi-Shield"]
  powers_starting: 6
  categories_allowed: ["Physical", "Sensitive", "Healing"]
  powers_per_level: 1
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Language: Spanish", base: 98, per_level: 0, note: "Language and Literacy: Spanish (98%): the speaking half." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Spanish literacy, the literacy half of Language and Literacy: Spanish (98%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: one of choice (+15%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%; printed as Radio Basic." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Detect Ambush", base: 40, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the humans half of Track Humans and Animals." }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "+10%; the animals half of Track Humans and Animals." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts or Assassin at the cost of one other skill." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - "Electrical"
      - { name: "Espionage", bonus: 5 }
      - "Mechanical"
      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "The book calls these other skills. Every category is Any. Medical carries +5% on Paramedic only, which the second Medical entry applies."
    schedule:
      - { level: 3, count: 2 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 14, count: 1 }
  secondary_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Mechanical"
      - "Medical"
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { choose: 1, label: "rifle", qty: 1, from: ["equalizer-combat-shotgun", "lightbringer-laser-rifle"], note: "Equalizer combat shotgun or light striker laser rifle (see extraction notes)." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["ip-7-ion-pistol", "rc-10-laser-pistol", "wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }
  - { item_id: "e-clip", qty: 8, note: "Four full reloads/E-clips for each of the two weapons." }
  - { item_id: "customizable-armor", qty: 1, note: "Customizable combat armor, M.D.C. 75." }
  - { item_id: "walkie-talkie", qty: 1, note: "The book says a hand radio." }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "survival-kit", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "survival-knife", qty: 1 }
natural_abilities:
  - { name: "Wings", description: "Wings on the back, separate from the humanoid arms, used for gliding, steering and maneuvering; the body is too heavy for winged flight, so the condoroid flies psionically." }
  - { name: "Beak", description: "A beak attack does 2D4 S.D.C." }
  - { name: "Build", description: "4 to 6 feet (1.2 to 1.8 m) tall, wingspan typically three times the height; 100 to 200 lbs (45 to 90 kg). Average life span 100 years." }
special_abilities:
  - name: "Psionic Flight"
    description: "Flies at up to about 500 mph (800 km/h). Within 100 feet (30.5 m) of the center of a ley line the condoroid can boost to Mach 2 (1340 mph / 2160 km/h), costing 2 I.S.P. per minute, but at that speed it can only fly in a straight line and cannot maneuver well. While flying the condoroid is +1 to strike and +2 to dodge (not added to the sheet)."
  - name: "Psionic Invisibility"
    description: "Matter and energy manipulation obstruct sensors and normal vision while a telepathic impulse convinces people the condoroid is not there. Sensor operator rolls are -40% to detect it, and living beings must save vs psionics to notice it. Costs 15 I.S.P.; lasts one minute per level of experience."
  - name: "Psionic Force Field"
    description: "A telekinetic force field of 30 M.D.C. at level one, plus 10 M.D.C. per additional level of experience. Costs 10 I.S.P.; lasts until its M.D.C. is depleted or two minutes per level of experience. This field is the condoroid''s only M.D.C.; the body itself is S.D.C."
restrictions:
  - "Psionics: Psi-Sword and Psi-Shield plus six powers from Physical, Sensitive and Healing at creation; one more power per level from any category except Super."
side_effects: "The in-flight bonuses (+1 to strike, +2 to dodge) apply only in the air and are not added to the sheet. Player characters start at first or second level of experience; NPCs average 1D4+1."
extraction_notes: "WB9 South America 2 printed 146-148 (cache p146-p148, page_offset 0). The class opens at the foot of printed 146 (the lines above it, custom barding and all, belong to the Equinoid Psi-Taur); the stat block, abilities and skills are printed 147, the equipment and money printed 148. Printed 147 read off a 110 dpi render as well as the OCR. || XP: the Condoroid/Falconoid ladder, printed 192, as briefed. || ATTRIBUTES as printed; Spd 3D6 is ground speed, flight is the Psionic Flight ability. || POOLS: hit points P.E. x2 plus 2D4 per level; S.D.C. 2D4x10+20 stored as sdc_base because the R.C.C. is the character''s whole class (it prints its own skills and related list), so no men_of_arms line - the convention of the Flying Tiger (WB6), the same family of Achilles-style psionic mutants. M.D.C. is only the psionic force field (30 + 10 per additional level, 10 I.S.P.), a special ability rather than mdc_base, as the Flying Tiger''s field was. P.P.E. 2D6: the OCR prints a stray closing quote after it, not part of the value. || PSIONICS: the book states no tier; stored master (judgement) because the class is granted two Super powers by name (Psi-Sword, Psi-Shield) and carries an I.S.P. pool of master size, as the Flying Tiger is stored. I.S.P. 2D4x10+10 plus M.E., +2D6 per level. Six picks from Physical, Sensitive and Healing; one more per level from any category excluding Super, which is the same three categories, so powers_per_level 1 under the class-wide gate. Flight, invisibility and the force field are this page''s own powers, not catalog rows, so they are special_abilities, never stubbed psionic powers. || BONUSES: +1 strike and +2 dodge while flying are conditional and are prose; nothing else is printed, so no bonuses block. Horror Factor 8. || SKILLS: Language and Literacy: Spanish (98%) as Language: Spanish 98 plus Literacy: Native Language 98, this book''s convention for a Language and Literacy line. Language: one of choice (+15%) is a Language: Other pick. Radio Basic is Radio: Basic 45+10. Wilderness Survival 30+10; Detect Ambush 30+10. Track Humans and Animals (+10%) names both, so both rows are granted (judgement): Tracking (people) 25+10 and Track & Trap Animals 20+10. W.P. Energy Rifle plus one W.P. of choice. Hand to Hand: Expert changes to Martial Arts or Assassin for one other skill; the book prints no alignment condition, so none is stored. || RELATED: the book''s R.C.C. Related Skills, six plus two at level 3 and one at levels 5, 7, 10 and 14. Communications, Domestic, Espionage, Rogue and Technical +5; Wilderness +10; Medical +5% on Paramedic only is a note, as on the Spectral Hunter; Electrical, Mechanical, Military, Physical, Pilot, Pilot Related, Science and W.P. any. Horsemanship and Cowboy are not on the printed list and are not granted (this book''s convention). SECONDARY: five, same list without bonuses. || EQUIPMENT: Equalizer combat shotgun or light striker laser rifle - no catalog row is named Striker; the rifle is mapped to lightbringer-laser-rifle (judgement), the Achilles Republic''s own laser rifle, whose entry (printed 165) says half of Achilles soldiers carry it and the other half Equalizer shotguns. Energy sidearm of choice is a choice of the IP-7 (issued to the Achilles militia, printed 163) and the usual Rifts energy pistols. 4 full reloads/E-clips for each: e-clip x8. Customizable combat armor (M.D.C. 75) is customizable-armor. Hand radio is walkie-talkie. One week''s rations is food-rations (about a week). Gas mask, survival kit, bedroll and survival knife are their catalog rows. || MONEY: 2D6x100 credits. || No Cybernetics line is printed and none is stored. Alignment: any, 30% anarchist and 20% unprincipled - GM notes."
---

## Lore

Project Achilles researchers wanted soldiers who could carry themselves into
battle through the air, and the condor strain was one of their two best
results. The birds were gathered in large numbers on the pretext of saving an
endangered species, and the experiments killed or maimed nearly all of them,
leaving only a few hundred condors in the wild by the time of the Cataclysm.

The condoroid is a man-sized bird-person: a condor''s head, a feathered body,
humanoid arms and legs, and wings on the back that are too weak to lift a body
built for human muscle. It flies by psionics instead, and since the Coming of
the Rifts those powers have grown - along a ley line it can pass Mach 2. It
can also hide itself behind a psychic illusion and wrap itself in a force
field, a gift common to the Achilles mutants.

In the Republic condoroids serve as scouts and commandos who slip past sensors
and sentries. Many others turn bandit, living in mountain communities and
preying on travelers - usually humans and D-Bees rather than fellow mutants.

## GM Notes

Alignment: any, but 30% are anarchist and 20% unprincipled. Condoroid bandits
often ride with Larhold barbarians, Arkhon renegades and human and D-Bee
outlaws.
',
       updated_at = datetime('now')
 WHERE class_id = 'condoroid'
   AND instr(markdown, 'Paramedic only: add it to that skill by hand') > 0
   AND length(markdown) = 11120;

-- == falconoid ==
UPDATE imported_classes
   SET markdown = '---
id: falconoid
name: Falconoid
system: rifts
source_book: Rifts World Book 9: South America 2 p.148-149
category: rcc
tags: [wilderness, flyer]
horror_factor: 7
xp_table: [0, 2401, 4801, 9601, 19201, 29001, 38001, 55001, 78001, 99001, 132001, 182001, 232001, 282001, 343001]
attribute_dice:
  IQ: "4d6"
  ME: "3d6+6"
  MA: "4d6"
  PS: "3d6+6"
  PP: "4d6+6"
  PE: "3d6+6"
  PB: "3d6"
  Spd: "1d6x10"
hit_points_base: "P.E. x2 + 1d6 per level"
sdc_base: "2d4x100"
ppe_base: "2d6"
starting_money: "2d6x100"
psionics:
  type: "master"
  isp_base: "2d6x10 plus M.E. attribute number, +8 per additional level of experience"
  powers_starting: 6
  categories_allowed: ["Physical", "Sensitive"]
bonuses:
  combat: { initiative: 1, roll: 3, pull_punch: 2 }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Language: Spanish", base: 98, per_level: 0, note: "Language and Literacy: Spanish (98%): the speaking half." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Spanish literacy, the literacy half of Language and Literacy: Spanish (98%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: one of choice (+15%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%; printed as Radio Basic." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the humans half of Track Humans and Animals." }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "+10%; the animals half of Track Humans and Animals." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts or Assassin at the cost of one other skill." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 5 }
      - "Electrical"
      - "Espionage"
      - "Mechanical"
      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
      - "Military"
      - "Physical"
      - { name: "Pilot", bonus: 10 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
    note: "The book calls these other skills. Every category is Any. Medical carries +5% on Paramedic only, which the second Medical entry applies."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 7, count: 1 }
      - { level: 10, count: 1 }
      - { level: 14, count: 1 }
  secondary_skills:
    count: 5
    categories:
      - "Communications"
      - "Domestic"
      - "Electrical"
      - "Espionage"
      - "Mechanical"
      - "Medical"
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { choose: 1, label: "rifle", qty: 1, from: ["equalizer-combat-shotgun", "lightbringer-laser-rifle"], note: "Equalizer combat shotgun or light striker laser rifle (see extraction notes)." }
  - { choose: 1, label: "energy sidearm of choice", qty: 1, from: ["ip-7-ion-pistol", "rc-10-laser-pistol", "wilk-s-320-laser-pistol", "ng-33-northern-gun-laser-pistol", "ng-57-northern-gun-heavy-duty-ion-blaster", "c-18-laser-pistol"] }
  - { item_id: "e-clip", qty: 8, note: "Four full reloads/E-clips for each of the two weapons." }
  - { item_id: "customizable-armor", qty: 1, note: "Customizable combat armor, M.D.C. 75." }
  - { item_id: "walkie-talkie", qty: 1, note: "The book says a hand radio." }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "survival-kit", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "survival-knife", qty: 1 }
natural_abilities:
  - { name: "Beak", description: "A beak attack inflicts 1D6 S.D.C." }
  - { name: "Build", description: "5 to 6 feet (1.5 to 1.8 m) tall; 90 to 120 lbs (41 to 54 kg). Average life span 120 years." }
special_abilities:
  - name: "Psionic Flight"
    description: "Flies at up to Mach 2, but at that speed only in a straight line and unable to maneuver. Cruising speed is typically Mach 1 (670 mph / 1078 km/h) or less. In the air the falconoid is +1 to strike and +1 to dodge (not added to the sheet)."
  - name: "Psionic Force Field"
    description: "A protective force field of 80 M.D.C. at level one, plus 20 M.D.C. per additional level of experience. Costs 15 I.S.P.; lasts two minutes per level of experience. This field is the falconoid''s only M.D.C.; the body itself is S.D.C."
  - name: "Psi-Blasts"
    description: "Psionic bolts from the head or eyes, +3 to strike, range 2000 feet (610 m), 6 I.S.P. per blast. Damage 2D6 M.D. at level one, +1D6 M.D. at levels 3, 5, 7, 9, 11 and 13. Any living being struck, even if armor absorbs the damage, must save vs psionics or suffer 2D6 S.D.C. (M.D.C. if supernatural) and be stunned for 1D4 rounds (-1 on initiative, strike, parry and dodge, -10% on skills)."
level_progression:
  - { level: 3, grants: ["Psi-Blasts: +1D6 M.D. (3D6)"] }
  - { level: 5, grants: ["Psi-Blasts: +1D6 M.D. (4D6)"] }
  - { level: 7, grants: ["Psi-Blasts: +1D6 M.D. (5D6)"] }
  - { level: 9, grants: ["Psi-Blasts: +1D6 M.D. (6D6)"] }
  - { level: 11, grants: ["Psi-Blasts: +1D6 M.D. (7D6)"] }
  - { level: 13, grants: ["Psi-Blasts: +1D6 M.D. (8D6)"] }
restrictions:
  - "Psionics: six powers from Physical or Sensitive at creation; the book grants no further picks by level."
side_effects: "The in-air bonuses (+1 to strike and dodge) apply only while flying and are not added to the sheet. Player characters start at first or second level of experience; NPCs average 1D4+1."
extraction_notes: "WB9 South America 2 printed 148-149 (cache p148-p149, page_offset 0). The class opens on printed 148 after the Condoroid''s equipment and money; the stat block and first two abilities are printed 148, the psi-blasts, I.S.P., bonuses, skills, equipment and money printed 149. Printed 149 read off a 110 dpi render: the OCR''s I.S.P. line ''2D6xX10'' is 2D6x10 on the page. || XP: the Condoroid/Falconoid ladder, printed 192, as briefed. || ATTRIBUTES as printed; Spd 1D6x10 is running speed, flight (up to Mach 2) is the Psionic Flight ability. || POOLS: 2D4x100 S.D.C. and P.E. x2 hit points, +1D6 hit points per level. S.D.C. stored as sdc_base because the R.C.C. is the character''s whole class (its own skills and related list), so no men_of_arms line - the Flying Tiger''s (WB6) convention. M.D.C. is only the force field (80 + 20 per additional level, 15 I.S.P.), a special ability rather than mdc_base, as the Flying Tiger''s and Condoroid''s fields are. P.P.E. 2D6. || PSIONICS: the book states no tier; stored master (judgement), matching the Condoroid and the Flying Tiger - psionic flight, a heavy force field and an M.D. psi-blast are Super-grade powers - and a 2D6x10 plus M.E. pool. +8 I.S.P. per additional level. Six picks from Physical or Sensitive in any mix; the book prints no picks at later levels, so none are stored. Flight, the force field and the psi-blasts are this page''s own powers, not catalog rows, so they are special_abilities, never stubbed psionic powers; the psi-blast damage steps are level_progression text. || BONUSES stored: +1 initiative, +3 roll with punch, fall or impact, +2 pull punch. +1 strike and dodge ''in the air'' is conditional and is prose. Horror Factor 7. || SKILLS: Language and Literacy: Spanish (98%) as Language: Spanish 98 plus Literacy: Native Language 98, this book''s convention. Language: one of choice (+15%) is a Language: Other pick. Radio Basic is Radio: Basic 45+10. Wilderness Survival 30+10. Track Humans and Animals (+10%) names both, so both rows are granted (judgement): Tracking (people) 25+10 and Track & Trap Animals 20+10. W.P. Energy Rifle plus two W.P. of choice. Hand to Hand: Expert changes to Martial Arts or Assassin for one other skill; no alignment condition is printed. || RELATED: six plus one at levels 3, 5, 7, 10 and 14. Communications, Domestic, Rogue and Technical +5; Pilot and Wilderness +10; Medical +5% on Paramedic only is a note; Electrical, Espionage, Mechanical, Military, Physical, Pilot Related, Science and W.P. any. Horsemanship and Cowboy are not printed and not granted. SECONDARY: five, same list without bonuses. || EQUIPMENT: printed word for word as the Condoroid''s. Light striker laser rifle has no catalog row; mapped to lightbringer-laser-rifle (judgement), the Achilles laser rifle carried by half the Republic''s soldiers beside the Equalizer shotgun (printed 165). Energy sidearm of choice: the IP-7 (Achilles militia issue, printed 163) or the usual Rifts energy pistols. E-clip x8 (four each). customizable-armor (M.D.C. 75), walkie-talkie for the hand radio, food-rations for one week''s rations, gas-mask, survival-kit, bedroll, survival-knife. || MONEY: 2D6x100 credits. || No Cybernetics line is printed and none is stored. Alignment: any - GM notes."
---

## Lore

While the condoroid proved a solid success, other Achilles teams wanted a
deadlier flier. The feline group produced the Flying Tiger; another group bred
and altered hundreds of falcon varieties, and among many lesser strains its
great result was the falconoid. It carries both the telekinetic-flight and
force-field genes, and it can also fire bolts of mental energy that wreck
machines and stun minds.

Falconoids are central to the Republic''s defense. Achilles has almost no air
force, so these lightly equipped mutants are often all that stands between it
and enemy aircraft and flying power armor, and aerial duels over the plains
are common. A few become skilled pilots and fly the Republic''s handful of
aircraft.

## GM Notes

Alignment: any.
',
       updated_at = datetime('now')
 WHERE class_id = 'falconoid'
   AND instr(markdown, 'Paramedic only: add it to that skill by hand') > 0
   AND length(markdown) = 10126;

-- == apok ==
UPDATE imported_classes
   SET markdown = '---
id: apok
name: Apok
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.55-59
category: occ
tags: [combat, divine]
occ_group: clergy
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
mdc_base: "40, plus 1d6 per level of experience, plus the mask''s 200"
ppe_base: "1d4x10+20, plus 2d6 per level of experience"
bonuses:
  combat: { attacks: 1, initiative: 1 }
  saves: { spell_magic: 2, disease: 2 }
  attributes: { PS: "2d6", Spd: "3d6" }
  pools: { mdc: 200 }
skills:
  occ_skills:
    - { name: "Lore: Demons & Monsters", base: 50, per_level: 5, note: "+25%; the book prints Lore: Monsters & Demons" }
    - { name: "Lore: Wormwood", base: 25, per_level: 5, note: "25% +5% per level; includes the history, legends and world information in this book" }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as Language: American (at 98%)." }
    - { name: "Language: Demongogian", base: 98, per_level: 5, note: "at 98%" }
    - { name: "Language: Gobblely", base: 98, per_level: 5, note: "at 98%" }
    - { name: "Literacy: Native Language", base: 60, per_level: 5, note: "+20%; the book prints Literacy: American" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Math: Basic" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Blunt" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Three of choice" }
    - { name: "Hand to Hand: Expert" }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Espionage", bonus: 10 }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
magic:
  type: "spell"
  spells: ["Close an Opening", "Create an Opening", "Create Shelter", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Locate Home Town", "Locate Places of Evil", "Repel Symbiotes"]
  spells_from: ["Close an Opening", "Control Temperature", "Create Life Force Cauldron", "Create Magic Slime", "Create Shelter", "Create Stairs", "Create Tunnel", "Create Wall", "Create Worm Zombies", "Create a Burial Place", "Create a Fountain of Water", "Create a Pillar", "Create an Opening", "Destroy Life Force Cauldron", "Heat Point", "Hell Fire", "Impervious to Symbiotes", "Invisible to Magic Seeing", "Life Fuel", "Locate Food & Resources", "Locate Home Town", "Locate Places of Evil", "Mold Structures", "Open & Close Dimensional Rifts", "Remove Symbiotes", "Repel Symbiotes", "Ride Giant Parasites"]
  spells_schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
equipment_starting:
  - { item_id: "hooded-cloak", qty: 2 }
  - { item_id: "clothing", qty: 2, note: "Two shirts and two pairs of pants." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "small-sack", qty: 1, note: "The book says one medium size sack. A medium sack row exists now (sack-medium); the class still stores the small sack." }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "50 feet (15 m)." }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - name: "The Demon Mask"
    description: "A living symbiotic organism created by the living planet and molded by the repentant warrior, worn as a brand rather than a badge. It sticks to the face like magic and cannot be forcibly removed - only the apok himself can take it off. Horror factor 16 to all demons and evildoers of Wormwood including the Unholy, and 10 to characters of good alignment. All the apok''s attacks inflict DOUBLE damage to supernatural beings and creatures of magic - demons, vampires, dragons, alien intelligences - whatever the weapon, so a dagger doing 1D4 does 2D4 and a laser rifle doing 4D6 M.D. does 4D6x2; even S.D.C. weapons inflict mega-damage against supernatural evil in his hands. +1 attack per melee, +1 on initiative, +200 physical M.D.C., and he heals ten times faster than normal. The mask itself is indestructible and radiates magic. It is said that when the Unholy is slain and his minions destroyed or cast off Wormwood, the mask will become powerless and the apok can finally live in peace."
  - name: "Impervious to Horror Factor"
    description: "Always saves. The apok has walked with monsters and stared into the blackness of his own soul and his own potential for evil - there is nothing more frightening."
  - name: "Impervious to Possession and Mind Control"
    description: "All forms. Having seen the depths of his own potential for evil has given the apok an iron will, great determination and an unbreakable spirit."
  - name: "Supernatural Strength and Endurance"
    description: "The strength of the apok''s resolve has given both spirit and body superhuman strength. Add +2D6 to P.S., which is considered SUPERNATURAL, and +3D6 to Spd, plus +2 to save vs poison, disease and all types of magic."
  - name: "Meditation"
    description: "Focusing his thoughts in prayer regains spent P.P.E. at ten points per hour, against four points an hour of ordinary rest, and gives the apok the ability to pilot battle saints and battle saint orbs."
  - name: "Invisible to Magic Seeing"
    description: "Constantly on, with no P.P.E. cost. This is a standing exception to the way the prayer normally works."
  - name: "Hell Fire"
    description: "Inflicts 3D4x10 damage when cast by an apok, rather than the prayer''s ordinary damage."
restrictions: ["Never uses any symbiote except the demon mask, the battle saint and the battle saint orb", "Will not draw P.P.E. from other beings and will not engage in blood sacrifice, even of the most foul villain", "May not select summoning magic as a level-up prayer", "Cybernetics and bionics are virtually non-existent"]
side_effects: "Alignment is GOOD ONLY - 40% principled and 60% scrupulous - and the reborn character always starts at first level with all his original O.C.C. skills lost. Impervious to Symbiotes does not exclude the demon mask, the battle saint or the battle saint orb."
extraction_notes: "THE PAGE RANGE IS 55-59, NOT THE SURVEY AND CONTENTS'' 55-58. Printed 56 and 58 are FULL-PAGE ART - the OCR cache holds 16 bytes for p056 and 9 bytes for p058, and neither is text. The Apok''s text runs 55 -> 57 -> 59, and printed 59 is not optional: it carries the SECOND HALF of the O.C.C. related skill category list (Medical through Wilderness), the whole Standard Equipment line, the Weapons, Armor, Transportation, Money, Cybernetics and Symbiotes entries. Reading only 55-58 would have lost a third of the class. Printed 59 also opens the Monk, so the two share it. || Money: Not applicable, read whole on p.59 - the apok are feared, disliked and on the bottom of the social totem-pole. No starting_money is stored. || Attribute bonuses ARE stored, as dice: bonuses.attributes takes a dice expression and rolls it once at creation, so the sheet carries what this character rolled rather than an average the book never prints. This note said the block took flat numbers only, which stopped being true before it was written - RETRO-AUDIT R11, 2026-09-04, and R6 made the same correction on the freelancer. Both are recorded on the Supernatural Strength and Endurance ability; they are also dice in bonuses, which the sheet rolls, so nothing is rolled by hand. The ability text follows the same rule the Freelancer follows for its d100 chart in #355. The P.S. is SUPERNATURAL, which the sheet does not model either. || M.D.C.: 40 plus 1D6 per level from the class and a flat +200 from the mask. The 200 is a pool bonus so that it reads as coming from the mask, which is where the book puts it. || Technical: the book prints Any (+10%; +20% on any language or literacy). The +20% clause is not stored: the catalog files Literacy under Communications, and this class grants NO Communications at all, so half of that clause reaches a category the apok cannot pick from. The languages it can reach are already granted at 98% as O.C.C. skills. || The level-up prayer list excludes summoning magic per p.57, which removes all ten Summon prayers from the 37 - leaving 27."
---

## Lore

The Apok is the most notorious of the Cathedral''s legion of warriors and
protectors: men and women who started life as Champions of Light, fell prey to
greed, hate or envy, and joined the Forces of Darkness. They served the Unholy
for years. Then they saw the light, forsook evil, and dedicated their lives to
eradicating the Unholy and his dark minions from Wormwood.

They have stared into the face of evil and seen their own reflection. They
walked that path and hurt, if not killed, many people. They are truly sorry, and
they are dedicated one hundred percent to the destruction of evil - they cannot
be bribed, tempted or diverted. That same keen eye for recognizing evil is
turned on everyone, which has given them a clear view of the corruption spreading
in the heart of the Cathedral.

Despite their courage and sacrifice they are feared and viewed with great
suspicion. They were evil once, so people fear they may be lured back. The apok
understand and accept this. They do not blame the people for their fear or even
their hate - they betrayed them once and they have earned the distrust. That is
why they wear the demon mask: as a brand, so all may know they were once fallen
champions, and have risen to become the living nightmare of the Forces of
Darkness.

To become an apok, a villain must be truly sorry, one hundred percent committed,
and willing to die for it. He prays, concentrates, and steps into a life vat
cauldron. If he is sincere he emerges 2D4 minutes later reborn as a Champion of
Light - all of his old O.C.C. skills lost, a new experience table begun, his
alignment now principled or scrupulous, and the demon mask in his hand.

## GM Notes

The typical player character starts at level one or two. The average non-player
apok is 1D4+3 level, fewer than 10% are above 7th, and there are estimated to be
fewer than a thousand of them alive.

**The apok is the lowest of the low socially and the most feared thing on the
board.** p.52 puts him at the very bottom of the human hierarchy, below
criminals and traitors, feared more than the dreaded Dark Priests. Inside the
Cathedral''s own hierarchy he sits fifth, above the monks. The Unholy and his
minions hate and fear the apok above all others, because he knows their cities,
their tactics and their dark secrets from the inside.

Some, like the infamous Confessor, have defied orders and even attacked a high
priest after pointing an accusing finger at the evil and selfish among them.
Those have been branded dangerous rogues, heretics or traitors, and are said to
have become servants of evil again. For now the apok turn their attention to the
greater evil.
',
       updated_at = datetime('now')
 WHERE class_id = 'apok'
   AND instr(markdown, 'ability and rolled by hand, which is the same rule') > 0
   AND length(markdown) = 11599;

-- == gypsy-enforcer ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-enforcer
men_of_arms: true
name: Gypsy Enforcer
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.155-157
category: occ
tags: [combat]
occ_group: men-of-arms
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_requirements: { PS: 14 }
starting_money: "2d6x100"
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Gypsy", base: 63, per_level: 5, note: "Speaks Gypsy (starts at 63%) - the flat figure the Thief, Fortune Teller and Beguiler also use." }
    - { name: "Language: Russian", bonus: 20, note: "Part of ''Russian and two of choice (+20%)''. NOTE this class is granted no Euro, which every other Gypsy O.C.C. in the book gets." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "The ''two of choice (+20%)'' half of that line." }
    - { name: "Streetwise", bonus: 14, note: "The book grants ''Streetwise (includes Streetwise: Drugs, both are +14%)'' as one line; both rows are granted." }
    - { name: "Streetwise: Drugs", bonus: 14, note: "The other half of that line." }
    - { name: "Horsemanship: General", bonus: 10, note: "Horsemanship: General (+10%)" }
    - { name: "Horsemanship: Exotic Animals", note: "The book prints ''Horsemanship: Exotic''." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%; typically small and fast)." }
    - { name: "Land Navigation", bonus: 10, note: "Land Navigation (+10%)" }
    - { name: "Dance", bonus: 10, note: "Dance (+10%)" }
    - { name: "Palming", bonus: 5, note: "Palming (+5%)" }
    - { name: "Pick Locks", bonus: 5, note: "Pick Locks (+5%)" }
    - { name: "Boxing", note: "Boxing" }
    - { name: "Climbing", bonus: 10, note: "Climbing (+10%)" }
    - { name: "Prowl", bonus: 10, note: "Prowl (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Ancient: two of choice (any)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern: two of choice (any). The book prints ''Modem'', a text-layer misread of ''Modern''." }
    - { name: "Hand to Hand: Expert", note: "Expert to start, and can be changed to Martial Arts or Assassin for the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 6
    minimums:
      - { count: 3, categories: ["Military"] }
    categories:
      - { name: "Communications", bonus: 10, note: "+10%" }
      - { name: "Espionage", bonus: 5, note: "+5%" }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive only (+5%)" }
      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First aid only (+5%)" }
      - { name: "Military", bonus: 10, note: "+10%; THREE of the six must come from this category." }
      - "Physical"
      - { name: "Pilot", note: "+10%, except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5, note: "+5%" }
      - { name: "Technical", bonus: 5, note: "+5%; language and lore +15%" }
      - { name: "Technical", only_prefix: ["Language", "Lore"], bonus: 15, note: "Language and lore +15%." }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 4, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
bonuses:
  attributes: { PP: 1, PE: 2, PS: "1d6", Spd: "1d6" }
  pools: { sdc: "3d6" }
  combat: { initiative: 3, pull_punch: 4 }
  saves: { horror_factor: 3 }
special_abilities:
  - name: "Rolled O.C.C. bonuses"
    description: "+1D6 to P.S., +1D6 to Spd, and +3D6 to S.D.C., on top of the fixed +1 to P.P. and +2 to P.E. carried in bonuses. All three are rolled by the sheet, from bonuses. The S.D.C. bonus is a POOL bonus on top of the core formula, not a replacement for it."
  - name: "The band provides"
    description: "The Gypsy band the Enforcer serves provides for most of his needs, including a place to stay - which is why his starting coin is the smallest in the book at 2D6x100, an order of magnitude below the other Gypsy classes."
  - name: "A sign of station"
    description: "All Gypsy Enforcers wear beards and moustaches, and most have long hair pulled back into a ponytail. He carries magic weapons and ''acquired'' Mystic Kuznya items alongside modern weapons and body armour."
restrictions:
  - "ALIGNMENT LIMITATIONS: unprincipled, anarchist or any evil. The book uses the Gypsy Thief''s wording - ''a thief cannot be of a good alignment'' - even though this class is a bodyguard and enforcer rather than a thief."
  - "Racial restrictions: none, although the vast majority (70%) are human."
  - "Attribute requirement is P.S. 14 or higher; a high I.Q., M.A. and P.E. are helpful but not a requirement."
  - "THREE of the six O.C.C. Related Skills must be Military skills. Carried as occ_related_skills.minimums and refused on save when it cannot be reached."
  - "NO EURO. Every other Gypsy O.C.C. in this book is granted Euro; this one is granted Russian and two of choice instead."
  - "Domestic and Science are BOTH None for this class - it is the only Gypsy O.C.C. in the book denied Domestic."
  - "The character also starts with 1D4x1000 credits'' worth of TRADE GOODS, over and above the coin in starting_money. That field is coin only, and the book prices the coin in credits OR RUBLES."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.155-157. THE LAST OF THE BOOK''S EIGHTEEN CLASSES. Filed occ_group men-of-arms, the second and last class in the book so classified after the Slayer: a bodyguard and enforcer with Boxing, Hand to Hand: Expert, four weapon proficiencies and a three-skill Military floor. That classification also sets its S.D.C. to 3D6 through its `men_of_arms: true` line (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js), where every caster and psychic here takes 1D6. Three of the six related skills must be Military, carried as occ_related_skills.minimums so it is refused on save rather than merely described. Three bonuses are ROLLED - +1D6 P.S., +1D6 Spd and +3D6 S.D.C. - and are stored as dice in bonuses, which the sheet rolls; the fixed +1 P.P. and +2 P.E. are in bonuses, and the S.D.C. is a pool bonus on top of the core 3D6 rather than a replacement. The book prints ''W.P. Modem'' where it means Modern, a text-layer misread of the same family as ''ox'' for ''or'' in the Wizard-Thief and ''leams'' for ''learns'' in the Seer. Two things set this class apart from the other Gypsy O.C.C.s and both are recorded as restrictions: it is granted NO EURO, where every other one is, and it is denied DOMESTIC. Its starting coin is 2D6x100, an order of magnitude below the rest, because the band it serves provides for it."
---

# Gypsy Enforcer

## Lore

The Gypsy Enforcer is the muscle of the band - a bodyguard who protects its
elders, women and children, and who carries out whatever threats and acts of
retribution the band decides its enemies have earned.

He carries magic weapons and "acquired" Mystic Kuznya items alongside modern
guns and body armour. As a sign of station, all Enforcers wear beards and
moustaches, and most wear their hair long and pulled back.

## Alignment

Unprincipled, anarchist or any evil.

## GM Notes

He owns almost nothing. His starting coin is 2D6x100 - an order of magnitude
below any other Gypsy class in the book - because the band provides for him,
including somewhere to live. What he does have is weapons.

He is also the only Gypsy O.C.C. here granted no Euro, and the only one denied
Domestic skills entirely. The book gives him Russian, two languages of his
choosing, and a great many ways to hurt people.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-enforcer'
   AND instr(markdown, 'Three attribute bonuses are ROLLED and are prose') > 0
   AND length(markdown) = 8064;

-- == gypsy-thief-russian ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-thief-russian
men_of_arms: false
name: Traditional Gypsy Thief (Russian)
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.143-144
category: occ
tags: [stealth]
occ_group: optional
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_requirements: { PP: 12 }
starting_money: "1d4x1000"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 20, note: "The book prints ''Basic Math (+20%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Gypsy", base: 63, per_level: 5, note: "The book says ''Speaks Gypsy (starts at 63%)'' - an unusual starting percentage, neither the catalog''s 50 nor a native 98." }
    - { name: "Language: Euro", bonus: 20, note: "Speaks Euro (+20%)" }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two other languages of choice (+20%)" }
    - { name: "Streetwise", bonus: 14, note: "The book grants ''Streetwise (includes Streetwise: Drugs, both are +14%)'' as one line; both rows are granted." }
    - { name: "Streetwise: Drugs", bonus: 14, note: "The other half of the book''s combined Streetwise line." }
    - { name: "Horsemanship: General", bonus: 20, note: "Horsemanship: General (+20%)" }
    - { name: "Horsemanship: Exotic Animals", note: "The book prints ''Horsemanship: Exotic''." }
    - { name: "Play Musical Instrument", bonus: 10, note: "Play Musical Instrument: one of choice (+10%)" }
    - { name: "Dance", bonus: 15, note: "Dance (+15%)" }
    - { name: "Concealment", bonus: 10, note: "Concealment (+10%)" }
    - { name: "Palming", bonus: 20, note: "Palming (+20%)" }
    - { name: "Pick Locks", bonus: 15, note: "Pick Locks (+15%)" }
    - { name: "Pick Pockets", bonus: 15, note: "Pick Pockets (+15%)" }
    - { name: "Find Contraband", bonus: 14, note: "Find Contraband (+14%)" }
    - { name: "Escape Artist", bonus: 20, note: "Escape Artist (+20%)" }
    - { name: "Acrobatics", note: "Acrobatics" }
    - { name: "Climbing", bonus: 10, note: "Climbing (+10%)" }
    - { name: "Prowl", bonus: 10, note: "Prowl (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: choice of two (any)" }
    - { name: "Hand to Hand: Basic", note: "Can be changed to Expert for the cost of one O.C.C. Related Skill, or Martial Arts (or Assassin, if evil) for two." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Radio: Scramblers", "Optic Systems", "Surveillance"], bonus: 5, note: "The book allows ''Radio: Basic, Scramblers & Optics and Surveillance only (+5%)''; the catalog files those as Radio: Scramblers and Optic Systems." }
      - { name: "Domestic", bonus: 10, note: "+10%" }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence", "Wilderness Survival"], bonus: 10, note: "Disguise, Forgery, Intelligence and Wilderness Survival only (+10%). Wilderness Survival is a WILDERNESS skill in this catalog, so naming it here is cross-category - deliberate, and it works." }
      - { name: "Medical", only: ["First Aid"], bonus: 5, note: "First Aid only (+5%)" }
      - { name: "Physical", except: ["Wrestling", "Gymnastics"] }
      - { name: "Pilot", note: "+10%, except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - { name: "Rogue", bonus: 10, note: "+10%, particularly Cardsharp and Seduction" }
      - { name: "Technical", bonus: 10, note: "+10%; languages +15%" }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "Languages +15%." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10, note: "+10%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 4, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
bonuses:
  attributes: { PP: 1, MA: "1d4", Spd: "1d6" }
  combat: { initiative: 2, dodge: 1, roll: 1, pull_punch: 3 }
  saves: { horror_factor: 1 }
special_abilities:
  - name: "Rolled O.C.C. bonuses"
    description: "+1D4 to the M.A. attribute and +1D6 to Spd, on top of the fixed +1 to P.P. carried in bonuses. Both are rolled by the sheet, from bonuses."
  - name: "One big family"
    description: "Most Gypsies regard each other as members of one big family or elite brotherhood, so one Gypsy will typically help another - a secret resource the character starts with rather than earns."
restrictions:
  - "ALIGNMENT LIMITATIONS: unprincipled, anarchist or any evil. A thief CANNOT be of a good alignment - the book states it outright."
  - "Racial restrictions: none, although the vast majority (70%) are human."
  - "Psionic abilities are not a requirement."
  - "The character also starts with 2D4x1000 credits'' worth of TRADE GOODS - most of it stolen - over and above the coin in starting_money. That field is coin only, and the book prices the coin in credits OR RUBLES. The Gypsy enjoys the good life and spends quickly and freely."
  - "Starts with one vehicle of choice: a horse, robot horse, hovercycle or land buggy."
  - "All Gypsies are snappy and stylish dressers. Thieves tend toward black and dark blue with splashes of gold and red, and they love leather."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.143-144. THE ID IS `gypsy-thief-russian` BECAUSE `gypsy-thief` IS ALREADY TAKEN, by the Gypsy Thief of Rifts World Book 5: Triax and the NGR p.180-181. That collision was found the expensive way and is worth recording: `INSERT ... WHERE NOT EXISTS` guards on class_id, so applying a colliding class SILENTLY INSERTS NOTHING and reports success - the live count simply does not move, which is the only symptom. Worse, `--emit-script gypsy-thief` writes to `add-gypsy-thief-class.sql`, WHICH WAS TRIAX''S EXISTING FILE, and overwrote it in the worktree. CHECK WHETHER AN ID IS TAKEN BEFORE EMITTING, not after applying. THE TWO PRINTINGS GENUINELY DIFFER, which is why this is a second row rather than a correction to the first: Triax starts Gypsy at 98% and grants three languages of choice, while this book starts it at 63%, grants two plus Euro, and adds Horsemanship: Exotic. The 63% is not a misread - it appears four times across four different Gypsy classes in this book. Four of this book''s eight Gypsy O.C.C.s already exist from Triax (Thief, Wizard-Thief, Seer and the Gifted One); the other four do not. The first of the book''s eight Gypsy O.C.C.s, and they head their stat blocks `Alignment Limitations:` rather than `Alignment:` - which is why a scan for class blocks missed four of them until it learned both spellings. Filed occ_group optional: a thief is neither a man of arms nor a caster, and `occ_group` is a closed set of clergy, men-of-arms, optional, magic and psychic. `Language: Gypsy` STARTS AT 63%, which is neither the catalog''s 50 for an ordinary language nor a native 98 - the book gives that exact figure, so `base` carries it. Four names needed the catalog''s spelling: Scramblers is Radio: Scramblers, Optics is Optic Systems, Card Sharp is Cardsharp, and Basic Math is Mathematics: Basic. THE ESPIONAGE ONLY-LIST NAMES WILDERNESS SURVIVAL, which this catalog files under Wilderness - a cross-category `only`, which class-check reports as deliberate rather than broken because the class does grant Wilderness. Two bonuses are ROLLED and are stored as dice in bonuses: +1D4 M.A. and +1D6 Spd. The fixed +1 P.P. is in bonuses. THE ROLL-WITH-IMPACT BONUS IS KEYED roll, NOT roll_with_impact: the combat block is open at the validator and CLOSED at the sheet, which draws a literal list, so an invented key stores fine, validates fine, composes fine and renders NOWHERE. The smoke test catches it by name. No P.P.E. and no magic: this is the first class in the book that casts nothing at all."
---

# Traditional Gypsy Thief

## Lore

The Traditional Gypsy Thief is a master of the light-fingered crafts - palming,
pockets, locks and concealment - wrapped in the showmanship of music, dance and
flashy clothes. The two halves are not separate: the performance is what makes
the theft possible.

Most Gypsies regard each other as one big family, so a Gypsy Thief is rarely
without somewhere to go.

## Alignment

Unprincipled, anarchist or any evil. A thief cannot be of a good alignment, and
the book is explicit about it.

## GM Notes

This is the first class in the book with no magic at all - no P.P.E., no spells,
no psionics. It is also the first of eight Gypsy O.C.C.s, which between them
make up half the book''s roster.

Thieves tend toward black and dark blue with splashes of gold and red, and they
love leather.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief-russian'
   AND instr(markdown, 'Two bonuses are ROLLED and are prose') > 0
   AND length(markdown) = 8937;

-- == hidden-witch ==
UPDATE imported_classes
   SET markdown = '---
id: hidden-witch
name: Hidden Witch
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.79-82
category: occ
tags: [shapeshifter]
occ_group: magic
xp_table: [0, 1976, 3951, 7901, 15801, 31601, 46401, 61801, 87001, 112201, 152401, 212601, 267801, 330201, 400401]
attribute_requirements: { IQ: 9, ME: 9 }
mdc_base: "P.E. x2 for physical M.D.C., plus 1d6 M.D. per level of experience"
ppe_base: "2d4x10 plus the P.E. attribute number, and 1d6+2 more per level of experience"
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 20, note: "The book prints ''Basic Math (+20%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Russian", base: 95, per_level: 0, note: "Speaks Russian at 95%" }
    - { name: "Language: Euro", bonus: 20, note: "Speaks Euro (+20%)" }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%)" }
    - { name: "Lore: Demons & Monsters", bonus: 15, note: "Lore: Demons & Monsters (+15%)" }
    - { choose: 1, from: ["Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 10, note: "Lore: one of choice (+10%)" }
    - { name: "Animal Husbandry", bonus: 10, note: "Animal Husbandry (+10%)" }
    - { name: "Paramedic", bonus: 10, note: "Paramedic (+10%)" }
    - { name: "Cook", bonus: 20, note: "Cook (+20%)" }
    - { name: "Brewing", bonus: 15, note: "Brewing (+15%)" }
    - { name: "Seduction", bonus: 13, note: "Seduction (+13%)" }
    - { name: "Land Navigation", bonus: 10, note: "Land Navigation (+10%)" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, one of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Weapon, one of choice (any)." }
    - { name: "Hand to Hand: Basic", note: "Can be changed to Expert for the cost of one O.C.C. Related Skill, or to Martial Arts (or Assassin, if evil) for two." }
  occ_related_skills:
    count: 9
    minimums:
      - { count: 3, categories: ["Rogue"] }
    categories:
      - { name: "Communications", bonus: 5, note: "+5%" }
      - { name: "Domestic", bonus: 10, note: "+10%" }
      - "Espionage"
      - { name: "Medical", bonus: 10, note: "+10%" }
      - { name: "Physical", except: ["Boxing", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5, note: "+5%; THREE of the nine must come from this category." }
      - { name: "Science", bonus: 10, note: "+10%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "+5%" }
    schedule: [{ level: 3, count: 1 }, { level: 5, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
magic:
  type: "spell"
  spells:
    - "Sense Evil"
    - "Fear"
    - "Domination"
    - "Agony"
    - "Life Drain"
    - "Minor Curse"
    - "Sickness"
    - "Spoil"
    - "Blind"
  spell_traditions_allowed: ["spoiling"]
  spells_schedule:
    - { level: 3, count: 6, from: ["Negate Poison/Toxin", "Cure Minor Disorders", "Cure Illness", "Heal Wounds", "Purification", "Remove Curse"], note: "Granted outright, not chosen: the count equals the list. The book prints ''Cure Illness'' twice in this sentence and ''Purification (of food and water)'', which is the catalog''s Purification." }
    - { level: 5, count: 6, from: ["Cleanse", "Mend the Broken", "Life Source", "Fortify Against Disease", "Heal Self", "Greater Healing"], note: "Granted outright. The book cites Rifts Federation of Magic for these six." }
    - { level: 7, count: 5, from: ["Second Sight", "Charismatic Aura", "Mask of Deceit", "Multiple Image", "Fool''s Gold"], note: "Granted outright." }
    - { level: 9, count: 2, from: ["Metamorphosis: Animal", "Negate Magic"], note: "Granted outright." }
    - { level: 11, count: 3, from: ["Oracle", "Exorcism", "Commune with Spirits"], note: "Granted outright." }
    - { level: 13, count: 2, from: ["Constrain Being", "Curse: Phobia"], note: "Granted outright. The book prints ''Curse Phobia''; the catalog row is Curse: Phobia." }
    - { level: 15, count: 3, from: ["Death Curse", "Deathword", "Restore Life"], note: "Granted outright. The book cites Rifts Federation of Magic for these three." }
bonuses:
  attributes: { PB: "1d4" }
  combat: { attacks: 1, initiative: 1 }
  saves: { horror_factor: 4, possession: 4, spell_magic: 1, ritual_magic: 1 }
special_abilities:
  - name: "Minor Mega-Damage creature"
    description: "P.E. x2 for physical M.D.C., plus 1D6 M.D. per level of experience. Unlike the Night Witch her P.S. is NOT supernatural and her life is not extended - the Hidden Witch ages naturally."
  - name: "Bio-Regeneration"
    description: "Bio-regenerates 1D6 M.D. per hour, day or night. She cannot regrow severed limbs."
  - name: "Shapechanging"
    description: "Once per 24 hours she can become a black cat, a black magpie or raven, or a grey fox, for up to one hour per level. She can speak in animal form but cannot cast spells, and skills are performed at -80% because of the inappropriate body. Otherwise she looks, acts and has all the natural abilities of that animal."
  - name: "Beauty"
    description: "+1D4 to the P.B. attribute, rolled by the sheet from bonuses."
  - name: "Limited & Specialized Mystic Knowledge"
    description: "The Hidden Witch is not the trained adept the Night Witch is. She knows the sets of spells listed on her schedule and rarely learns more than one additional common wizard spell every other level, if that. She is more like a Mystic, instinctively knowing a new set of spells at junctions in her life."
  - name: "Starting Spoiling spells"
    description: "At level one she also knows 1D4+2 Spoiling Magic spells of her choice, EXCLUDING any of 8th level or higher. The count is rolled, and a rolled count of starting spells is not something the wizard can express, so the allotment is recorded here rather than as a spells_starting number that would have to invent a figure. `spell_traditions_allowed` names the Spoiling tradition so the pool is reachable."
  - name: "Animal Familiar"
    description: "At level two she gains an animal familiar - typically a cat, dog, fox, ferret, ermine or rat - via the Familiar Link spell. NOTE: she does NOT have Demon Helpers or a Demon Familiar, which is what separates her from the Night Witch."
  - name: "Spell strength"
    description: "+1 to spell strength at levels 3, 7 and 11."
restrictions:
  - "Any alignment, but most are anarchist (40%), unprincipled (20%), aberrant (15%) or miscreant (15%). Unlike the Night Witch this class is not restricted to evil."
  - "Racial restrictions: none, although the vast majority (80%) are human."
  - "Cybernetics: none. The Hidden Witch avoids them as unnatural and unnecessary."
  - "The character also starts with 1D6x100 credits'' worth of TRADEABLE GOODS, over and above the coin in starting_money. That field is coin only and the goods are not a named catalog item, so they are recorded here. N.P.C.s start with 1D6x10,000 instead."
  - "THREE of the nine O.C.C. Related Skills must be Rogue skills. Carried as occ_related_skills.minimums and refused on save when it cannot be reached."
  - "Spoiling Magic is exclusive to the Witch O.C.C.s and no other class, which is why it is a tradition of its own in the catalog."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.79-82. Also known as the Gypsy Witch and Mistress of Life and Death. The per-level spell sets are GRANTS rather than picks - the book says she ''possesses'' or ''knows'' them - so each schedule entry''s count equals the length of its own list, which hands over the whole set. Two names needed the catalog''s spelling: the book''s ''Cure Minor Disorder'' is Cure Minor Disorders and its ''Purification (of food and water)'' is Purification; the book also prints ''Cure Illness'' twice in the level three sentence, which is a typesetting repeat rather than two spells. The book''s ''Curse Phobia'' is the catalog''s Curse: Phobia. The level one allotment of 1D4+2 Spoiling spells is a ROLLED count and `spells_starting` takes an integer, so it is recorded in special_abilities; `spell_traditions_allowed` names the tradition so the pool is reachable. The +1D4 to P.B. is likewise rolled, and is a dice entry in bonuses. The N.P.C. money figure reads ''106x10,000'' in the text layer - the digit substitution this cache carries on 72 pages, and it is 1D6x10,000."
---

# Hidden Witch

## Lore

The Hidden Witch, also called the Gypsy Witch and the Mistress of Life and
Death, is a practitioner of dark magic who appears to be a completely ordinary
person - but possesses supernatural and magical powers. Most (90%) are female,
and they hold the powers both to heal and to hurt.

She does not derive her powers from a pact with a demon the way the Night Witch
does, and she keeps no Demon Helpers. Her familiar is an ordinary animal, and
her knowledge is instinctive rather than studied: she is more like a Mystic,
learning a new set of spells at junctions in her life rather than training for
them.

## Alignment

Any. Most are anarchist (40%), unprincipled (20%), aberrant (15%) or miscreant
(15%) - so unlike the Night Witch, this class is not restricted to evil, and a
Hidden Witch can be a healer as readily as a menace.

## GM Notes

The majority are human, and the character is built to pass unnoticed - the point
of the name. Her most dangerous asset is not her magic but that nobody knows she
has any.
',
       updated_at = datetime('now')
 WHERE class_id = 'hidden-witch'
   AND instr(markdown, 'is likewise rolled and is prose rather than a bonuses line') > 0
   AND length(markdown) = 10007;

-- == gypsy-thief ==
UPDATE imported_classes
   SET markdown = '---
id: gypsy-thief
men_of_arms: false
occ_group: optional
name: Gypsy Thief
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.180-181
category: occ
tags: [stealth]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_requirements: { PP: 12 }
starting_money: "1d4x1000"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Basic Math (+20%)" }
    - { name: "Language: Gypsy", base: 98, per_level: 0, note: "At 98%. The gypsy secret language, never spoken in front of non-gypsies and never taught to strangers." }
    - { choose: 3, from: ["Language: Other"], bonus: 20, note: "Language: select three of choice (+20%). Taken once per language - the picker asks which. All gypsies also speak Euro." }
    - { name: "Streetwise", base: 34, per_level: 4, note: "+14%" }
    - { name: "Streetwise: Drugs", base: 39, per_level: 5, note: "+14%; the entry grants Streetwise and Streetwise: Drugs together, both at +14%." }
    - { name: "Horsemanship: General", base: 60, per_level: 4, note: "Horsemanship (+20%)" }
    - { name: "Play Musical Instrument", base: 45, per_level: 5, note: "One of choice (+10%)" }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%" }
    - { name: "Concealment", base: 30, per_level: 4, note: "+10%" }
    - { name: "Palming", base: 40, per_level: 5, note: "+20%" }
    - { name: "Pick Locks", base: 45, per_level: 5, note: "+15%" }
    - { name: "Pick Pockets", base: 40, per_level: 5, note: "+15%" }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%" }
    - { name: "Acrobatics", base: 30, per_level: 5, note: "Printed with no percentage beside it, so it stands at the catalog base." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: choice of two." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of one other skill, or Expert/Assassin (if evil) for the cost of two. The book prints Expert twice (Triax printed 180); the second is read as Martial Arts, the style the Gypsy Seer and Gypsy - The Gifted print in that position, so Martial Arts or Assassin (if evil) costs two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Radio: Scramblers", "Optic Systems"], bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], bonus: 10 }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - { name: "Physical", except: ["Wrestling", "Gymnastics"] }
      - { name: "Pilot", bonus: 10, except: ["Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Military: Tanks & APCs", "Jet Aircraft", "Military: Jet Fighters", "Boat: Ships", "Military: Warships & Patrol Boats"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 10 }
      - { name: "Technical", bonus: 10, note: "+10%, and +15% on languages, which the next line carries." }
      - { name: "Technical", only_prefix: ["Language"], bonus: 15, note: "+15% on languages." }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10, note: "Wilderness Survival is also named on the book''s Espionage line at +10%; it is a Wilderness skill in this catalog and is taken here at the same +10%." }
    note: "Electrical, Mechanical, Military and Science: none."
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 4, count: 1 }, { level: 7, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }]
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "jacket-leather", qty: 1 }
  - { item_id: "boots-soft-leather", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { choose: 1, label: "light M.D.C. body armor", qty: 1, from: ["dog-pack-dpm-riot-armor", "plastic-man-body-armor", "ca-2-light-dead-boy-armor", "urban-warrior-body-armor"] }
  - { item_id: "scarf", qty: 2 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "knife", qty: 2 }
  - { item_id: "lock-picking-tools", qty: 1 }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "magnifying-glass", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "large-flashlight", qty: 1 }
  - { item_id: "lightweight-cord", qty: 1 }
  - { item_id: "grappling-hook", qty: 1 }
  - { choose: 1, label: "note pad or sketch book", qty: 1, from: ["note-pad", "sketch-pad"] }
  - { item_id: "pen", qty: "1d4" }
  - { choose: 1, label: "vehicle", qty: 1, from: ["riding-horse", "hovercycle"] }
restrictions:
  - "Alignment: Unprincipled, Anarchist or any evil. A thief cannot be of a good alignment."
  - "Cybernetics: starts with none. Most gypsies avoid cybernetics except for medical reasons."
extraction_notes: |
  - Triax and the NGR, printed 180-181. The first of the book''s four Gypsy
    O.C.C.s, and the first entry in this book outside the NGR military, so it
    takes no `ngr-` prefix. The id is `gypsy-thief` rather than `thief`, which
    is already the Palladium Fantasy class - the survey called this collision.
  - LANGUAGE: GYPSY IS A NEW CATALOG ROW, created by this batch and cited to
    printed 179, where the book describes the gypsies'' secret spoken language
    and its dozen symbols. It is not one of the seven new skills printed 155
    lists; it is a language named only inside the O.C.C. entries.
  - The book prints "Streetwise (includes Streetwise: Drugs, both are + 14%)"
    as one line. Stored as two skills, because the catalog holds two rows.
  - THE ESPIONAGE LINE NAMES WILDERNESS SURVIVAL AND THIS CATALOG FILES THAT
    SKILL UNDER WILDERNESS. Unlike the Police O.C.C. two entries earlier, this
    class also grants "Wilderness: Any (+10%)", so the skill is reachable
    without any special handling and is simply left to the Wilderness line -
    which carries the same +10% the Espionage line prints, so nothing is lost.
    It is NOT listed in the Espionage `only`, because a cross-category `only`
    that duplicates a category the class already grants adds nothing.
  - THE PILOT EXCLUSION LIST WILL ROT. The book says "except robot combat:
    elite, tanks & APCs, jets, jet fighters, and ships". `except` matches exact
    catalog names and has no prefix form, so every `Robot Combat Elite:` row is
    named individually - twelve of them today. A thirteenth machine imported
    from this book''s gear chapter, or from Triax 2, will be offered to this
    class unless it is added here. An unmatched or missing `except` fails OPEN.
  - "Ships" is mapped to BOTH `Boat: Ships` and `Military: Warships & Patrol
    Boats`. The catalog splits into two rows what the book names once, and a
    warship is a ship; excluding only the first would leave the larger vessel
    offered to a class the book bars from ships altogether.
  - The +15% the Technical line prints for languages IS stored: Technical is
    listed twice, once at +10% and once limited to the Language rows at +15%
    (the twice-listed category shape of BOOK-INGEST-AUDIT.md F109).
  - Money is 1D4x1000 credits. The entry also grants 2D4x1000 in jewelry,
    artifacts and other stolen goods, which `starting_money` cannot hold - it
    is coin only - so it is recorded in the body and here.
  - NOT GIVEN CATALOG ROWS, and left out of `equipment_starting`: the bright
    coloured bandanna (the catalog has a scarf and no bandanna; two scarves are
    stored and the bandanna is prose), the energy rifle and energy pistol,
    which are unresolved choices this book''s batches record as prose rather
    than stub, and the robot horse and land buggy, two of the
    four vehicle options, which have no rows - the horse and the hovercycle do
    and are the stored choice.
    T-40 "plain clothes" armour is left out of `equipment_starting` as well,
    but it has rows now: `t-40-urban-businessman-suit`,
    `t-40-ultra-businessman-suit`, `t-40-jump-suit`, `t-40-outdoorsman`,
    `t-40-long-coat`, `t-40-standard-jacket` and `t-40-standard-vest`. The
    class does not list them, and the armour stays prose.
  - S.D.C. is 1D6 by the core rule, stated as `men_of_arms: false` (until 2026-09-25 a `CORE_SDC_BY_CLASS` entry in js/compose.js). The entry
    prints no S.D.C. formula, and the book files it under Gypsy O.C.C.s rather
    than with the Military O.C.C.s of printed 156 - the same reading the City
    Rat already gets on the Rifts side.
---

# Gypsy Thief

## Lore

The gypsy thief is a thug, cat-burglar and con-man all rolled into one. Some are slimy little weasels or mean looking punks; others are suave, bold, James Bond types. Regardless of how the thief may look or act, timid or bold, crude or debonair, male or female, all are master thieves.

The gypsies of Rifts Earth are not the gypsies of the world before it. About half are human, forty percent D-bees and one in ten a supernatural monster or alien. They are wanderers with no one place they call home, most common in Central Europe and found as far east as Mongolia and northern China. Most clans are several related families plus whoever has been accepted in, and they seldom squabble among themselves or steal from each other - the hundreds of clans behave like one enormous fraternity whose members treat each other as brothers. Like any fraternity they wear their colours: bright bandannas and scarves in yellow, orange, red, pink and purple. They love gold and jewelry, and they have a secret spoken language that is never used in front of outsiders, let alone taught to them.

Being a gypsy is a lifestyle and not a racial factor. A gypsy may also be a headhunter, juicer, vagabond, wilderness scout, witch, traditional mystic, mind melter or any of the psychic R.C.C.s, but will not consider the soldier, knight, techno-wizard, druid or scholar - they are too disciplined and fit poorly into gypsy society. Most gypsies avoid cybernetics, power armour, robots and formal training in magic.

## Equipment and Money

Standard issue beyond the stored equipment: an energy rifle and an energy pistol, both unresolved choices; a bright coloured bandanna worn with the scarf; and T-40 "plain clothes" armour as the alternative to light mega-damage body armour. Thieves dress in black and dark blue with splashes of gold and red, and they love leather.

Notable additional equipment a thief may want to acquire: special clothing with concealed pockets, weapons and items with false or hollow handles and bottoms, disguises, a better vehicle, a jet pack, magic items, a vibro-blade, a laser scalpel, signal flares, smoke, tear gas grenades, a mini-tool kit, multi-optic bands, handcuffs, surveillance items, a pocket mirror, a pocket laser distancer, a pocket digital disc recorder for his observations, and a hand-held computer.

Money: 1D4x1000 credits, plus 2D4x1000 in jewelry, artifacts and other stolen goods. The gypsy enjoys the good life and spends his money quickly and freely on life''s many pleasures and extravagances.

## GM Notes

The rules for travelling shows and carnivals in Rifts World Book One: Vampire Kingdoms are a useful aid when a gypsy clan arrives to make trouble. Vampires plague parts of Europe, Romania in particular, and may work with unscrupulous gypsies or prey upon the clans themselves.

A gypsy caravan, or even one gypsy, means trouble. When valuables disappear the gypsy is the first suspect and is probably guilty. Beyond commonplace robbery and mugging they favour elaborate schemes and charades: disguises, forgery, distractions, magic illusions, mirrors, smoke, and every con-game in the book. Many clans arrive with the fanfare of a carnival, pitch camp outside town, and sell fortune-telling, healing, magic shows, minstrels, dancing girls and alleged magic potions - and use every transaction to size up the buyer, his friends and his town for plundering later.
',
       updated_at = datetime('now')
 WHERE class_id = 'gypsy-thief'
   AND instr(markdown, 'The +15% the Technical line prints for languages is not stored') > 0
   AND length(markdown) = 12815;

-- == lyvorrk ==
UPDATE imported_classes
   SET markdown = '---
id: lyvorrk
name: Lyvorrk
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.130-133
category: rcc
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
tags: [wilderness, stealth]
attribute_dice:
  IQ: "3d6+2"
  ME: "4d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6+2"
  PE: "5d6"
  PB: "2d6"
  Spd: "4d6"
mdc_base: "P.E. + 2d6, +2d4 per level"
ppe_base: "2d6+12"
horror_factor: 12
starting_money: "2d6x1000"
occ_restrictions:
  only: ["group:magic", "body-fixer"]
  note: "A Lyvorrk who follows the R.C.C. takes no O.C.C. One who forsakes the R.C.C. skills may take the Body Doc (stored as the Body Fixer) or any Magic O.C.C.; Shifter, Necromancer, Mystic, Ley Line Walker, Temporal Wizard and Elemental Fusionist appeal most, roughly in that order. Such a character uses only the O.C.C.''s skills and ignores the R.C.C., R.C.C. Related and Secondary Skills; the picker does not drop them."
psionics:
  type: "major"
  isp_base: "M.E. x3, +10 per level"
  powers: ["Death Trance", "Mind Block", "Nightvision", "Resist Fatigue", "Resist Hunger", "Resist Thirst"]
bonuses:
  combat: { initiative: 2, strike: 3, parry: 4, dodge: 5, damage_bonus: 4, roll: 5, pull_punch: 3 }
  saves: { psionics: 3, spell_magic: 5, toxins_poisons: 7, harmful_drugs: 7, disease: 7, coma_death_pct: 18 }
skills:
  occ_skills:
    - { name: "Animal Husbandry", base: 50, per_level: 5, note: "+15%, but limited to rodents and reptiles." }
    - { name: "Barter", base: 40, per_level: 4, note: "+10%." }
    - { name: "Camouflage", base: 40, per_level: 5, note: "+20%." }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%. Natural climbers." }
    - { name: "Detect Concealment", base: 35, per_level: 5, note: "+10%." }
    - { name: "Gemology", base: 40, per_level: 5, note: "+15%." }
    - { name: "Hand to Hand: Assassin", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%." }
    - { name: "Language: Spanish", base: 98, per_level: 0, note: "Native (adopted) tongue." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "Language: Other of choice (+10%)." }
    - { name: "Lore: D-Bee", base: 35, per_level: 5, note: "Lore: D-Bees (+10%)." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "Printed Math: Basic (20%), read as +20%." }
    - { name: "Mining", base: 45, per_level: 5, note: "+10%." }
    - { name: "Prowl", base: 40, per_level: 5, note: "+15%." }
    - { name: "Skin & Prepare Animal Hides", base: 40, per_level: 5, note: "+10%." }
    - { name: "Tracking (people)", base: 30, per_level: 5, note: "+5%." }
    - { name: "Track & Trap Animals", base: 30, per_level: 5, note: "+10%; +20% more to catch small animals such as rabbits, squirrels and other rodents." }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Targeting", base: 0, per_level: 0, note: "Targeting (Sling)." }
  occ_related_skills:
    count: 3
    categories:
      - "Communications"
      - { name: "Espionage", bonus: 5 }
      - "Medical"
      - "Physical"
      - "Pilot"
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 1 }, { level: 5, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 13, count: 1 }, { level: 15, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
equipment_starting:
  - { item_id: "small-silver-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: "1d6+6" }
  - { item_id: "hammer-and-mallet", qty: 1 }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "knife-skinning", qty: 1 }
  - { item_id: "explosive-grenade", qty: "1d4+1" }
  - { item_id: "triax-plasma-grenade", qty: "1d4" }
  - { item_id: "smoke-grenade", qty: "1d4+1" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "large-sack", qty: "1d4+1" }
  - { item_id: "sack", qty: "1d4+1" }
  - { item_id: "sling", qty: 1, note: "With normal and silver bullets (1D6 S.D.C., double damage to vampires); grenades can also be thrown with it." }
  - { item_id: "purse-satchel", qty: 1, note: "Satchel." }
  - { item_id: "water-skin", qty: 2, note: "A waterskin, and a second kept as a blood bottle: a waterskin holding blood for drinking." }
natural_abilities:
  - name: "Mega-Damage being"
    description: "M.D.C. is 2D6 plus the P.E. attribute number, plus 2D4 M.D. per level of experience. Recovers lost M.D.C. at 1D6+6 points every four hours (twice as long in cold weather)."
  - name: "Regeneration"
    description: "Regrows a lost finger, toe, hand, foot or tail in 3D4+6 weeks, and lost teeth or a tongue in 1D4+4 weeks. Cannot regenerate an eye."
  - name: "Desert body"
    description: "Needs very little water and survives on as little as one pint a month, taking moisture from the fluids of raw food. A remarkable stomach handles raw meat, blood and spoiled meat. Not adversely affected by heat up to 140 degrees Fahrenheit. Good burrowers, keeping warm on cold desert nights by burrowing under rocks or dirt."
  - name: "Senses and body"
    description: "Natural climbers with keen hearing, polarized vision that is not affected by glare, and quick reflexes. A semi-prehensile tail is used for balance and for swatting opponents attacking from behind or the sides. Long hooked fingernails slice human flesh like knives. Impervious to all snake venoms."
special_abilities:
  - name: "Heat bonuses"
    description: "In temperatures of 90-140 degrees Fahrenheit the Lyvorrk adds +1 attack per melee round, +2 on initiative, +1 to strike and parry, and +2 to dodge to its other bonuses. Not applied by the sheet."
  - name: "Psionic Empathy with Reptiles"
    description: "Reptiles, snakes and reptilian dinosaurs take an immediate liking to a Lyvorrk and never stalk, hunt, bite or kill one. They are friendly and docile toward it, try to please it, and poisonous snakes and dinosaurs make loyal watchdogs and pets that fight to the death for their master."
  - name: "Telepathy with Reptiles"
    description: "Like normal Telepathy, but works only on cold-blooded animals of a reptilian nature, up to 1000 feet (305 m) away."
  - name: "Control Reptiles"
    description: "A blend of Empathy and Telepathy that controls the minds of cold-blooded reptiles: lizards, snakes, turtles and the few cold-blooded reptilian dinosaurs. They understand and obey every verbal or mental command. Range: 100 feet (30.5 m) per level of experience. Duration: as long as desired. Number controlled: 40 plus 10 per level of experience, regardless of size. Bonus: +10% to ride untamed dinosaur reptiles. I.S.P.: 3."
  - name: "Control Intelligent Reptilian Life Forms"
    description: "As Control Reptiles, but against intelligent reptilian D-Bees, who save vs psionic mind control at -2 (-5 if the Lyvorrk only asks harmless questions that betray no secret or confidence). A controlled victim does anything commanded except kill himself, kill a friend or loved one, or destroy or sell favorite possessions, and cannot be forced to do something completely abhorrent. Range: 50 feet (15.2 m). Duration: one minute (4 melee rounds) per level of experience. Number controlled: one per level of experience, regardless of size. Does not work on warm-blooded beings. I.S.P.: 5."
  - { choose: 1, at_levels: [2, 4, 6, 8, 10, 12, 14], from: ["Insanity (01-10): Obsession - Being Mysterious and Scary", "Insanity (11-20): Phobia - Scientists", "Insanity (21-30): Obsession - Craves Power and Wealth", "Insanity (31-40): Phobia - Cages and Being Locked Up", "Insanity (41-50): Obsession - Secrets", "Insanity (51-60): Phobia - Large Mammals", "Insanity (61-70): Obsession - Superiority", "Insanity (71-80): Phobia - Undead", "Insanity (81-90): Obsession - Magic", "Insanity (91-00): Phobia - Demons of Hades"], note: "Lyvorrk insanity table (printed 132): the page says to roll for one additional insanity at each of levels 2, 4, 6, 8, 10, 12 and 14. None is rolled at creation. The page does not say what a repeated result gives." }
  - name: "Insanity (01-10): Obsession - Being Mysterious and Scary"
    description: "Roll 01-10. Obsession. Likes to frighten and gross people out with his reptiles and behavior (drinks spilled blood, fondles snakes and so on). Cryptic in what he says, smiles menacingly, makes threatening remarks, mostly to enemies and strangers, and acts cool, calm and mysterious."
  - name: "Insanity (11-20): Phobia - Scientists"
    description: "Roll 11-20. Phobia. Dislikes and distrusts scientists no matter what, and will never let one examine him."
  - name: "Insanity (21-30): Obsession - Craves Power and Wealth"
    description: "Roll 21-30. Obsession. Willing to wait and work for power and wealth, but turns greedy, reckless and short-sighted when large amounts of money are at stake."
  - name: "Insanity (31-40): Phobia - Cages and Being Locked Up"
    description: "Roll 31-40. Phobia of cages and being locked up behind bars. Cannot stand the idea of imprisonment and hates zoos, slavers and slavery. May free slaves and even penned animals, starting with reptilians."
  - name: "Insanity (41-50): Obsession - Secrets"
    description: "Roll 41-50. Obsession. Collects secrets like rare gems and uses them to his advantage whenever possible. Keeps his own well guarded."
  - name: "Insanity (51-60): Phobia - Large Mammals"
    description: "Roll 51-60. Phobia. Finds large mammals, other D-Bees such as the Mastadonoid included, unnerving and creepy. Never trusts them and dislikes having to be around them."
  - name: "Insanity (61-70): Obsession - Superiority"
    description: "Roll 61-70. Obsession. Feels he must prove the superiority of intelligent reptiles over humans and mammals. Tends to be an arrogant show-off."
  - name: "Insanity (71-80): Phobia - Undead"
    description: "Roll 71-80. Phobia. Hates the undead and wants them destroyed, but hates doing it himself: tries to get others to kill vampires while he works to avoid them."
  - name: "Insanity (81-90): Obsession - Magic"
    description: "Roll 81-90. Obsession with magic. Roll percentile again: 01-70 covets magic weapons, artifacts, potions and items of all kinds, appreciates and trusts mages and finds creatures of magic fascinating; 71-00 hates magic, likes to steal and hide or destroy magic weapons, artifacts, potions and items of all kinds, and trusts neither mages nor creatures of magic. The second roll is made by hand."
  - name: "Insanity (91-00): Phobia - Demons of Hades"
    description: "Roll 91-00. Phobia. Finds the demons of Hades troubling and dangerous, the Gargoyle sub-demons and Lesser Demons included."
trackable_resources: []
side_effects: "Cold: in climates colder than 50 degrees Fahrenheit for more than four hours, or below freezing for more than one hour, bonuses, the number of attacks and the Spd attribute are reduced by half; they return to full after two hours of warmth (70 degrees or hotter). Cold-based attacks do double damage. Hates water, cannot swim and refuses to learn. Insanity: all Lyvorrk are insane to some degree, with an obsessive fondness for poisonous snakes and lizards, and most have a fear of drowning and bodies of water; they roll on the Lyvorrk insanity table (the Insanity group among the special abilities) for one more at each of levels 2, 4, 6, 8, 10, 12 and 14."
restrictions:
  - "Alignment: any, but Anarchist (30%), Aberrant (10%), Diabolic (20%) and Miscreant (20%) are most common."
  - "Magic: none, unless a Magic O.C.C. is selected; P.P.E. 2D6+12 is added to the base of one who becomes a practitioner of magic."
  - "Cybernetics: none, though Lyvorrk are not opposed to bionics as such."
  - "A Lyvorrk that takes the Body Doc or a Magic O.C.C. uses only that O.C.C.''s skills and ignores the R.C.C., R.C.C. Related and Secondary Skills. Not applied by the picker."
  - "Pilot related picks: basic vehicles only, like car, truck and hovercycle; avoids water vessels. Rogue picks: +10% to Seduction only, in place of +5%. Not enforced."
extraction_notes: "WB30 D-Bees of North America printed 130-133 (cache p131-p134), read off 200 dpi renders. Lore starts on printed 130 under the heading Lyvorrk; the stat block is headed Lyvorrk - Optional Player Character and NPC (printed 130) and ends on printed 133 with a note that the race first appeared in World Book One: Vampire Kingdoms. Printed 131 is an art plate. || CATEGORY: a race whose R.C.C. is a full skill package, or which may instead take the Body Doc or any Magic O.C.C. || XP: the book says a Lyvorrk who pursues R.C.C. skills uses the Psi-Stalker table, and a mage uses the magic O.C.C.''s table. It was left out at import, per that import''s brief, and an xp_table is stored now. || M.D.C.: 2D6 +P.E. attribute number, plus 2D4 M.D. per level, stored as mdc_base, so no men_of_arms line. P.P.E. 2D6+12, added to a mage''s P.P.E. base: stored as ppe_base, no yields_to_occupation. Horror Factor 12. || PSIONICS: I.S.P. printed M.E. attribute number x3, +10 I.S.P. per melee round; per melee round is read as a slip for per level of experience. Considered a Major Psychic. The six conventional powers are granted by name (printed levels Death Trance 1, Mind Block 4, Nightvision 4, Resist Fatigue 4, Resist Hunger 2, Resist Thirst 6 are the powers'' own I.S.P. costs). The four reptile powers have no catalog rows and are special abilities with their printed numbers. || BONUSES: +2 initiative, +3 strike, +4 parry, +5 dodge, +4 S.D.C. damage (damage_bonus), +5 roll, +3 pull punch, +3 vs psionics, +5 vs magic (spell_magic), +7 vs poison, drugs and disease (toxins_poisons, harmful_drugs, disease), +18% vs coma. Impervious to snake venoms is ability text. Heat bonuses are conditional and a special ability. || SKILLS: catalog base plus the printed bonus. Language: Native (adopted) Tongue: Spanish is Language: Spanish at 98, the native-tongue convention. Math: Basic is printed (20%) with no plus sign; read as +20%, 65. W.P. Targeting (Sling) is the catalog W.P. Targeting. Hand to Hand: Assassin is granted with no upgrade price, so no hand_to_hand block. || RELATED: three at level one and one more at levels 3, 5, 8, 10, 13 and 15. Espionage +5% and Rogue +5% stored as bonuses; Rogue +10% to Seduction only and Pilot basic vehicles only are a restriction line. || SECONDARY: two from the Secondary Skill List at levels 1, 3, 8 and 12, read as two at each of those levels. || OCCUPATIONS: Body Doc is stored as body-fixer, the catalog''s Rifts medical O.C.C.; there is no Body Doc class. Any Magic O.C.C. is group:magic. The skill swap such a character makes is a restriction line, not pairing_skills (regression pins its carriers). || EQUIPMENT: the list is for a Lyvorrk R.C.C. (By O.C.C. otherwise). Silver cross is small-silver-cross; 1D6+6 wooden stakes; mallet is hammer-and-mallet; silver dagger (1D6 S.D.C.) is knife-silver-plated; skinning knife; 1D4+1 high explosive grenades as explosive-grenade; 1D4 plasma grenades as triax-plasma-grenade (Plasma Grenade); 1D4+1 smoke grenades; backpack; 1D4+1 large sacks; 1D4+1 medium sacks as sack. Granted since ~116 and ~117, to every Lyvorrk although the book gives them to one taking the R.C.C. and not to one who takes the Body Doc or a Magic O.C.C., who has that O.C.C.''s equipment instead (the condition is the player''s to honour): the sling with normal and silver bullets (1D6 S.D.C., double damage to vampires; may also throw grenades) as sling, the satchel as purse-satchel, and the waterskin and the blood bottle as two water-skin. NOT STORED, no catalog row: one M.D. weapon (probably a Vibro-Blade or energy pistol), 2D6+4 live poisonous snakes, a Gila Monster and 1D6+2 lizards; they are in GM Notes. || MONEY: R.C.C. starts with 2D6x1000 credits and 1D6x100 in tradeable goods, or by O.C.C.; the credits are starting_money, the goods are GM Notes. || INSANITY (printed 132, cache p133, re-read off 200 and 300 dpi renders 2026-10-05): the entry prints Roll on the following table at levels 2, 4, 6, 8, 10, 12 and 14 for additional insanities, and no roll at creation; the two insanities every Lyvorrk has (the fondness for poisonous snakes and lizards, the fear of drowning and bodies of water) stay in side_effects. The table has ten rows of ten points each, 01-10 to 91-00, alternating obsession and phobia. Stored as one pick-one group at levels 2, 4, 6, 8, 10, 12 and 14 with band-named options Insanity (NN-NN), replacing the level 2 level_progression line that only said to roll (BOOK-INGEST-AUDIT.md F116). No row prints a number, so no option carries bonuses. Row 81-90 Obsession: Magic sends the player to a second percentile roll (01-70 covets magic, 71-00 hates it): that sub-roll is the row''s prose. GM Notes keeps its one-paragraph summary of the table. || NOT STORED: size 5-6 feet with a 6-7 foot tail, weight 140-170 pounds, life span 6D6+100 years, breeding, habitat, slave market value 1D4x10,000 credits, allies and enemies; in GM Notes."
---

## Lore

The Lyvorrk (said "lie vork") look like a velociraptor that learned to walk
upright and dress itself. Under the ponchos, hooded cloaks and robes they
favor there is a long serpentine tail, clawed four-toed feet, a finned saurian
head and a wide mouth full of sharp teeth. The eyes are clever, though, and
the arms and hands are close to human, apart from long hooked nails that cut
like knives. They like jewelry and belts, and many wear live snakes the way
others wear necklaces.

Only a few hundred live in North America. Invasions, plagues and other
disasters over the last couple of centuries have pushed them to the edge of
extinction, most of the survivors are young by their own measure, and none
remember where they came from. They are cold-blooded, hate cold and water,
and keep to the hot dry Southwest, drifting into Lone Star, Mexico or the
Deep South in winter.

Most live as hunter-scavengers on small game, though a nasty few hunt people.
Their psionic hold over snakes and reptiles makes them good at finding prey,
and also makes them dangerous snake charmers, show performers, bandits,
interrogators and, above all, assassins who can send venomous creatures to
do the killing. Magic is a recent passion: about a third have become mages,
and they quietly hope to rebuild their numbers and one day become a power on
the continent.

## GM Notes

Experience: the entry names the Psi-Stalker experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Disposition: arrogant toward mammals, whom they tolerate as the dominant life
on Earth. Even good ones like to frighten people; evil ones are cruel and
vindictive. Excellent liars with fine poker faces, sluggish and grumpy in the
cold.

Insanity table, rolled at levels 2, 4, 6, 8, 10, 12 and 14 (d100):
01-10 obsession with being mysterious and scary; 11-20 phobia of scientists;
21-30 obsession with power and wealth; 31-40 phobia of cages and being locked
up; 41-50 obsession with secrets; 51-60 phobia of large mammals; 61-70
obsession with reptilian superiority; 71-80 phobia of undead; 81-90 obsession
with magic (01-70 covets magic items, 71-00 hates magic and steals or destroys
it); 91-00 phobia of the demons of Hades.

R.C.C. equipment the catalog has no row for: one M.D. weapon (probably a
Vibro-Blade or energy pistol), 2D6+4 live poisonous snakes (probably
rattlers), a Gila Monster and 1D6+2 lizards. Also 1D6x100 credits in
tradeable goods.

The sling, satchel, waterskin and blood bottle (a waterskin of blood for
drinking) are the kit of a Lyvorrk taking the R.C.C.; one who takes the Body
Doc or a Magic O.C.C. has that O.C.C.''s equipment instead. The sling''s normal
and silver bullets do 1D6 S.D.C. (double damage to vampires), and it can also
throw grenades.

Size 5-6 feet (1.5 to 1.8 m) tall with a 6-7 foot (1.8 to 2.1 m) tail.
Weight 140-170 pounds (63 to 76.5 kg). Life span 6D6+100 years; mature at 12.
Females lay 1D4 eggs after a three month pregnancy, which hatch three months
later; the male raises the young.

Habitat: the American Southwest and the Mexican border. Slave market value
1D4x10,000 credits. Allies: their own kind and those subservient to them.
Enemies: dislike humans, mutants and most warm-blooded D-Bees, especially
bird, rodent, feline and canine ones, and regard other reptilian races as
rivals.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyvorrk'
   AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0
   AND length(markdown) = 20604;

-- == malvoren ==
UPDATE imported_classes
   SET markdown = '---
id: malvoren
name: Malvoren
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.138-142
category: rcc
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
tags: [combat, tech]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+2"
  MA: "2d6"
  PS: "4d6+10"
  PP: "3d6+4"
  PE: "3d6+4"
  PB: "2d4"
  Spd: "3d6+4"
hit_points_base: "P.E. x3, +2d6 per level"
sdc_base: "3d4x10+20"
ppe_base: "6d6x10 + P.E., +10 per level"
horror_factor: 10
starting_money: "6d6x1000"
psionics:
  type: "major"
  isp_base: "2d4x10 + M.E., +10 per level"
  powers: ["Telemechanics", "Telemechanic Paralysis", "Telemechanic Mental Operation"]
  powers_starting: 3
  powers_per_level: 3
  categories_allowed: ["Physical", "Sensitive"]
bonuses:
  combat: { attacks: 1, initiative: 3, strike: 1, parry: 2, dodge: 2, disarm: 3, entangle: 2, roll: 1 }
  saves: { disease: 2, toxins_poisons: 2, horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Native tongue at 98%." }
    - { name: "Language: Trade Four", base: 80, per_level: 5, note: "+30%." }
    - { name: "Language: Techno-Can", base: 80, per_level: 5, note: "+30%." }
    - { name: "Literacy: Native Language", base: 40, per_level: 5, note: "Literacy: Native Tongue; no figure printed." }
    - { name: "Literacy: Techno-Can", base: 50, per_level: 5, note: "+20%." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literacy in Trade Four (+20%); the catalog has no Trade Four literacy row." }
    - { name: "Basic Electronics", base: 35, per_level: 5, note: "+5%." }
    - { name: "Bioware Mechanics", base: 30, per_level: 5 }
    - { name: "Mathematics: Basic", base: 98, per_level: 0, note: "At 98%." }
    - { name: "Mathematics: Advanced", base: 65, per_level: 5, note: "+20%." }
    - { name: "Mechanical Engineer", base: 25, per_level: 5, note: "Mechanical Engineering." }
    - { name: "Sensory Equipment", base: 35, per_level: 5, note: "+5%." }
    - { name: "Vehicle Armorer", base: 50, per_level: 5, note: "+20%." }
    - { name: "Weapon Systems", base: 55, per_level: 5, note: "+15%." }
    - { name: "Weapons Engineer", base: 75, per_level: 5, note: "+50%." }
    - { choose: 2, categories: ["Pilot"], note: "Pilot: two of choice." }
    - { choose: 6, categories: ["Weapon Proficiencies"], note: "W.P.: six of choice." }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin"], note: "Hand to Hand: Martial Arts, or Assassin if evil; player''s choice." }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - { name: "Electrical", only: ["Robot Electronics"] }
      - "Espionage"
      - "Horsemanship"
      - { name: "Mechanical", bonus: -5 }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Chemistry", "Astrophysics"] }
      - { name: "Technical", only: ["Language: Other", "Computer Operation", "Computer Programming", "Jury-Rig"] }
      - { name: "Communications", only: ["Literacy: Other"] }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation"] }
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 3, count: 1 }, { level: 9, count: 1 }]
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1 }
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "field-radio", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "food-rations", qty: 1 }
  - { item_id: "tool-kit", qty: 1 }
  - { item_id: "wilk-s-portable-laser-torch-tool", qty: 1, note: "The book says a portable laser-welding torch and names no maker." }
natural_abilities:
  - name: "Body of muscle cords"
    description: "No skin: a body of dark red muscle cords wrapped into humanoid form, with small black eyes that glow red then white in combat and no visible mouth, nose or ears. M.D.C. comes only from armor and machines melded into the body."
  - name: "Regeneration"
    description: "Regenerates 1D6 Hit Points or S.D.C. per minute and a lost limb within 72 hours. While melded with any weapon, armor or device it cannot be physically transformed by any means, even magic. Regains P.P.E. at 10 per hour of sleep or meditation, and cannot draw P.P.E. from any other source such as batteries, ley lines or other beings."
  - name: "Weapon mechanic"
    description: "Repairs, rebuilds and upgrades weapons, even ones not melded, in half the time an Operator needs. Work on non-combat machines takes at least twice as long and is poor quality."
special_abilities:
  - name: "Meld with Weapons"
    description: "Muscle tendrils fuse with a weapon, which is then used as if with a W.P. six levels above the character''s experience level, plus one extra attack per melee with it and +3 to strike; bonuses from melded telescopic, laser or other targeting systems also apply. Several melded weapons can be fire-linked to shoot together at one target as one melee attack. Takes one melee action; lasts until disconnected. P.P.E.: 5 per item."
  - name: "Meld with Weapon Systems"
    description: "Merges with weapon systems, targeting and combat computers, radar and sensor clusters and turrets in any power armor, robot, combat vehicle, ship, spacecraft or fortification, using it at full bonuses and a skill of 95%, plus +2 to strike. Takes 2 melee actions; lasts indefinitely. P.P.E.: 8."
  - name: "Meld with Armor"
    description: "Melds with body armor, cyborg armor, an exoskeleton or a patchwork of M.D.C. plating (6D6+52 M.D.C. as patchwork armor). Melded armor gains 20% damage capacity, fits like a glove, and halves its prowl, strike, parry, dodge and other penalties. Melded with a complete suit, P.S. becomes the equivalent of Robotic Strength and punches and kicks do Mega-Damage. Takes three melee actions; lasts indefinitely. P.P.E.: 10. Power armor counts as a war machine."
  - name: "Meld with Cybernetics"
    description: "Snaps on cybernetic and bionic parts with no surgery: organs, eyes, ears, limbs, weapons, extra arms or tentacles, even a vehicle or animal frame as a lower body. Each meld or un-meld does 1D6 S.D.C. and 1D4 Hit Points of damage; a full limb or torso frame does triple damage, takes triple the time and costs triple P.P.E., and un-melding one takes a full minute. Takes one melee round; lasts indefinitely. P.P.E.: 10."
  - name: "Power Weapons"
    description: "Charges or powers a melded weapon with P.P.E.: standard E-Clip 10 P.P.E., long E-Clip 15, canister or FSE-type cell 25, large backpack-sized cell 40; directly powering a weapon costs 1 P.P.E. per die of damage per shot or blast. Rail gun ammunition is made from the Malvoren''s own body: 10 P.P.E. and 1D6 S.D.C. or Hit Points per slug, or 20 P.P.E. and 3D6 S.D.C. or Hit Points per flechette or burst. Bullets, grenades and missiles cannot be made. A weapon melded with and powered by a Malvoren does full damage to any creature that can be harmed by magic or psionics, even one normally immune. Instant; a charge lasts until used."
  - name: "Heal and Repair Weapons and Armor"
    description: "Mends a melded weapon, armor or war machine with its own body and P.P.E.; cannot replace missing parts, and armor must have 20% of its capacity left. One melee attack per 10 M.D.C. or S.D.C. healed, permanent. Cost: 1 P.P.E. and 1 S.D.C. or Hit Point per S.D.C. restored, or 5 P.P.E. and 10 S.D.C. or Hit Points per M.D.C. restored. Melded items also heal 1D6 M.D.C. per hour in total between them, cybernetics first, then armor, then weapons."
  - name: "Meld with War Machines"
    description: "Becomes one with a power armor, tank or other combat vehicle, robot vehicle or fighter craft, with the equivalent of Pilot: Robot Combat Elite, Tanks, Fighter, Patrol Boat or the appropriate skill at four levels above the character''s experience level. Takes one full melee round; lasts indefinitely. P.P.E.: 15."
  - name: "Meld with Non-Combat Machines"
    description: "Rare and painful: 2D6 S.D.C. and 1D6 Hit Points of damage to meld and again to un-meld. Gives a basic understanding of how to operate or pilot the machine at level one proficiency. Takes one full melee round; lasts 1D6 minutes per level of experience. P.P.E.: 25."
  - name: "Un-Melding"
    description: "Un-melding from each item takes one melee action, except some cybernetics as above. P.P.E., S.D.C. and Hit Points spent on a meld are not recovered until the item is un-melded."
  - name: "Telemechanic psionics"
    description: "Telemechanics (10 I.S.P.), Telemechanic Paralysis (20) and Telemechanic Mental Operation (12) work only while melded with a weapon, armor or machine. On a weapon, suit of armor, or the sensors and power systems of a weapon or combat computer they cost half the I.S.P. and last twice as long; on a non-combat machine they cost twice the I.S.P. and last half as long."
trackable_resources: []
side_effects: "Poor natural vision that sees only in the ultraviolet and infrared spectrums, and poor hearing. Melding with too many items (more than 50% machine: four or more extra or replacement limbs plus four cybernetics, a cyborg torso plus four cybernetics, 12 or more cybernetic items, or more than 12 weapons plus cybernetics and armor, as the G.M. sees fit) costs the non-Telemechanic psionic powers and 50% of the base I.S.P. Horror Factor 10 applies only when one can tell what they are, none if sealed in environmental armor."
restrictions:
  - "Alignment: any, but typically Aberrant (40%), Scrupulous (30%) or Principled (10%); even the others tend to show some honor."
  - "Available O.C.C.s: none. A Malvoren does not choose an O.C.C. and relies on R.C.C. skills and natural abilities."
  - "Magic: none. No magic potential, cannot use Techno-Wizard items, and never picks up a magic weapon or melds with a TW device."
  - "Cybernetics and bionics: starts with up to 1D4 cybernetic implants and may have one bionic limb (additional or replacement) with up to two weapon systems, all melded rather than implanted."
  - "Equipment choices: any medium or heavy body armor or a light exoskeleton; three energy or heavy energy weapons of choice with three spare clips each, and two melee weapons; a heavy-duty truck, jeep, motorcycle or hovercycle."
  - "Related skill notes: Pilot +10% on combat vehicles; Electrical Generation is also allowed but has no catalog row. Not enforced."
extraction_notes: "WB30 D-Bees of North America printed 138-142 (cache p139-p143), read off 200 dpi renders; the P.P.E. line was re-read at 300 dpi. The heading Malvoren is on printed 138; lore runs to printed 139, where the stat block headed Malvoren R.C.C. - Optional Player Character or NPC starts, and it ends on printed 142. || CATEGORY: a race that is its own class; Available O.C.C.s: None is a restriction line with no occ_restrictions block (the armored-slayer precedent). || XP: the book says to use the Robot Pilot table. It was left out at import, per that import''s brief, and an xp_table is stored now. || POOLS: Hit Points P.E. attribute number x3 plus 2D6 per level. S.D.C. 3D4x10+20 is the class''s whole S.D.C., stated with no O.C.C. to add to, so it is sdc_base and no men_of_arms line is written. M.D.C. by armor and melded machines only. P.P.E. is printed 3D6x10 +P.E. attribute number +3D6x10, plus 10 per level; the two 3D6x10 terms sum exactly to 6D6x10, stored as 6d6x10 + P.E., because the pool roller reads only one dice term. Horror Factor 10, only when one can tell what they are. || PSIONICS: Considered a Major Psychic. I.S.P. 2D4x10 +M.E. attribute number, plus 10 per level. Telemechanics, Telemechanic Paralysis and Telemechanic Mental Operation granted by name (catalog Super rows); their melded-only use and cost changes are ability text. Three powers from Physical or Sensitive at each level of experience starting at level one is powers_starting 3 and powers_per_level 3 with categories_allowed Physical and Sensitive. || BONUSES: +1 attack, +3 initiative, +1 strike, +2 parry and dodge, +3 disarm, +2 entangle, +1 roll, +2 vs disease and poison (disease, toxins_poisons), +4 vs Horror Factor. Meld bonuses are conditional and ability text. || SKILLS: catalog base plus the printed bonus. Language: Native Tongue (Trade Four and Techno-Can at +30%) is read as the native tongue at 98 plus Trade Four and Techno-Can at 80. Literacy: Native Tongue (Trade Four and Techno-Can at +20%) is Literacy: Native Language at the catalog 40 (no figure printed), Literacy: Techno-Can 50, and a Literacy: Other pick at +20 for Trade Four (no such row). Mathematics: Basic at 98% is a flat 98. Mechanical Engineering is the catalog Mechanical Engineer. Pilot two and W.P. six of choice are choice groups. Hand to Hand: Martial Arts or Assassin if evil is a one-of-two choice; no upgrade price, so no hand_to_hand block. || RELATED: four at level one, plus one at levels 4, 8 and 12. Cowboy, Domestic and Medical: None are omitted. Electrical: Electrical Generation and Robot Electronics only; Electrical Generation has no catalog row, so only Robot Electronics is stored and the omission is a restriction line. Mechanical: Any (-5%) is bonus -5 as printed. Physical except Acrobatics. Science: Chemistry and Astrophysics only. Technical: Language, Literacy, Computer Operation, Computer Programming and Jury-Rig only: Language is Language: Other (Technical) and Literacy is Literacy: Other, filed under Communications, so it is a second Communications entry. Rouge: Any is read as Rogue. Pilot +10% on combat vehicles is a restriction line. || SECONDARY: four, plus two additional at levels 3 and 9, read as one at each of those levels. || EQUIPMENT: traveling clothes, binoculars, gas mask, sunglasses, canteen, tent, sleeping bag, utility belt, flashlight, radio (field-radio), backpack, survival knife, food rations and a quality tool kit (tool-kit). The portable laser-welding torch is granted since ~116 and ~117 as wilk-s-portable-laser-torch-tool (the book names no maker). NOT STORED, no catalog row: basic electrical tools and personal items. The vehicle, armor and weapons are choices with no named item, and the starting cybernetics are prose. || MONEY: 6D6x1,000 credits. || NOT STORED: size 7 feet 4 inches to 8 feet 8 inches, weight 270-330 pounds, life span 4D6+135 years, the Splugorth bounty of one million credits, slave market value, habitat, allies and enemies; in GM Notes."
---

## Lore

The Malvoren are a warrior race from somewhere in the Megaverse, so long on the
move that even they no longer remember a home world. They sell their services
to almost any war as bounty hunters, bodyguards, mercenaries and assassins, yet
most live by a strict code of honor: a worthy foe is met with equal weapons and
never cheated, while a foe without honor may be put down by any means at all.

A Malvoren has no skin. Its tall, powerful body is a bundle of dark red muscle
cords wrapped into human shape, with small black eyes that burn red and then
white in battle. Those cords can unwind and fuse with technology: guns, armor,
cybernetics, power armor and the weapon systems of vehicles all become part of
its living body, run at the speed of thought. Most go about sealed inside heavy
armor bristling with melded weapons, and are often taken for cyborgs or living
robots.

They love weapons, tinker with them constantly, and can repair and upgrade them
faster than any Operator, though non-combat machinery bores them. They cannot
use magic at all and scorn it as a kind of cheating, refusing even
Techno-Wizard devices. The Splugorth prize them as living weapon controllers
and pay a fortune for captives, so Malvoren hate the Splugorth and their
minions above all others and will gladly fight them, sometimes for less than
their usual fee.

## GM Notes

Experience: the entry names the Robot Pilot experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Disposition: honorable and trustworthy; they respect those who respect them.
Allies without honor are pitied and used; Malvoren without honor are a
disgrace.

Size 7 feet 4 inches to 8 feet 8 inches (2.2 to 2.6 m). Weight 270 to 330
pounds (122 to 149 kg). Life span 4D6+135 years.

Starting equipment the catalog has no row for: basic electrical tools and
personal items.

Slave market value: the Splugorth pay one million credits or the equivalent
in trade for a live Malvoren; other slavers pay 1D4x100,000 credits. Habitat:
anywhere, preferring high-tech war zones; on Rifts Earth mostly North America,
working for one mercenary company or another. Allies: anyone with courage,
honesty and honor, such as Cyber-Knights, Blucies, Kraks and Lyn-Srial, and
they know many dimension travelers. Enemies: the Splugorth, Sunaj and other
Minions of Splugorth above all; they also dislike Dirari Ecto-Men, Ganka,
Lanotaur Hunters, Loaks and anyone without honor.
',
       updated_at = datetime('now')
 WHERE class_id = 'malvoren'
   AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0
   AND length(markdown) = 17412;

-- == mraghiile-tree-man ==
UPDATE imported_classes
   SET markdown = '---
id: mraghiile-tree-man
name: M''Raghiile Tree Man
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.135-138
category: rcc
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
tags: [wilderness, stealth]
men_of_arms: false
attribute_dice:
  IQ: "3d6"
  ME: "2d6+3"
  MA: "3d6+3"
  PS: "1d6+5"
  PP: "3d6+10"
  PE: "3d6"
  PB: "3d6+3"
  Spd: "3d6"
hit_points_base: "P.E., +1d4 per level"
ppe_base: "4d6"
occ_restrictions:
  only: ["healing-shaman", "plant-shaman", "elemental-fusionist-fire-water", "elemental-fusionist-earth-air", "mystic", "group:psychic", "group:magic"]
  note: "Nearly every M''Raghiile met outside the forests is a young wanderer who uses the R.C.C. skills and takes no O.C.C. A tribe''s one or two Shamans are a Healing or Plant Shaman, or an Elemental Fusionist, Mystic or Psychic in that role; any Magic O.C.C. is allowed as well. Such a character uses that O.C.C.''s skills and powers rather than the R.C.C. skills; the picker does not drop them."
bonuses:
  pools: { sdc: "3d6+8" }
  combat: { initiative: 2, strike: 1, automatic_dodge: 4, disarm: 1, entangle: 2, pull_punch: 2, roll: 6, perception: 4 }
skills:
  occ_skills:
    - { name: "Acrobatics", base: 60, per_level: 5, note: "+30%." }
    - { name: "Camouflage", base: 50, per_level: 5, note: "+30%." }
    - { name: "Climbing", base: 75, per_level: 5, note: "+35%." }
    - { name: "Escape Artist", base: 55, per_level: 5, note: "Printed (25%), read as +25%." }
    - { name: "Gymnastics", base: 55, per_level: 5, note: "+25%." }
    - { choose: 1, from: ["Hand to Hand: Basic", "Hand to Hand: Expert"], note: "Hand to Hand: Basic for females, Hand to Hand: Expert for males." }
    - { name: "Identify Plants & Fruit", base: 50, per_level: 5, note: "+25%." }
    - { name: "Land Navigation", base: 60, per_level: 4, note: "+24%." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%." }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%, and an additional +20% when in trees." }
    - { name: "Swimming", base: 50, per_level: 5 }
    - { name: "Wilderness Survival", base: 60, per_level: 5, note: "+30%." }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Domestic"], note: "Two Domestic skills of choice." }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "Three W.P. Ancient Weapons of choice." }
equipment_starting:
  - { item_id: "bandoleer-with-pouches-and-or-belt-loops", qty: 1 }
  - { item_id: "water-skin-half-gallon", qty: 1 }
  - { item_id: "mraghiile-patchwork-armor", qty: 1, note: "M.D.C. is rolled: 2D6+17." }
natural_abilities:
  - name: "An S.D.C. being"
    description: "Hit Points are the P.E. attribute number plus 1D4 per level of experience. S.D.C. is 3D6+8. M.D.C. only from armor (typically patchwork with 2D6+17 M.D.C.) or magic."
  - name: "Multi-Hand Dexterity"
    description: "Ambidextrous with both hands and feet, which are really a second pair of hands. Has the equivalent of Paired Weapons with all four hands and can strike or parry in any combination, though at least one hand usually supports the body from a hanging or standing position."
  - name: "Natural Contortionist"
    description: "Bends in half, curls into a ball, walks backwards on hands and feet, fights with any of its four hands from almost any angle, and squeezes through a hole as small as 5 inches (13 cm) across."
  - name: "Natural Camouflage"
    description: "Striped hide, a pelt whose hairs can stand or flatten to make or break patterns, and small size let it hide in the wild very well; see the R.C.C. skill bonuses."
  - name: "Prehensile Tail"
    description: "Used for balance, to swing and hang from branches and to grab and carry small items. It can hold a knife or club, or even fire a handgun at -6 to strike (no penalty with small melee weapons)."
  - name: "Natural Acrobat and Gymnast"
    description: "Runs and jumps through trees as easily as a human walks, with the equivalent of the Gymnastics and Acrobatics skills; do not add their attribute, combat or S.D.C. bonuses, which are already factored in. Leap distances and heights from those skills are doubled, and falls do half damage. No penalty to shoot, throw or strike while moving, leaping, swinging, balanced on one hand or foot, or hanging by the tail."
  - name: "Superior Senses and Perception"
    description: "The equivalent of 20-05 vision, Nightvision 200 feet (61 m), Advanced Hearing, and Advanced Smell: track by scent at 57% +3% per level of experience. +4 to visual, olfactory and auditory Perception Rolls."
  - name: "Natural attacks"
    description: "Punch 1D4 S.D.C., bite 1D4 S.D.C., kick 1D6 S.D.C., and a swing or leap kick 2D6 S.D.C. +2 to strike on leap attacks and kicks."
level_progression:
  - { level: 2, grants: ["Select two Language: Other skills (+20%). Picked by hand: a pick limited to a category at a set level is not modelled."] }
  - { level: 3, grants: ["Select two Wilderness skills (+15%)."] }
  - { level: 4, grants: ["Select two Communications skills (+10%)."] }
  - { level: 5, grants: ["Select two Rogue skills (+5%), excluding all tech skills, Seduction and Streetwise."] }
  - { level: 7, grants: ["Select two Technical skills."] }
  - { level: 9, grants: ["Select two Modern W.P. or two Piloting skills (basic vehicles only, no robots, power armor or military)."] }
  - { level: 11, grants: ["Select two more Domestic or Technical skills."] }
trackable_resources: []
side_effects: "Their small size, ordinary strength and gentle nature can all work against them."
restrictions:
  - "Alignment: any, but most are Principled (25%), Scrupulous (35%) or Unprincipled (20%)."
  - "Psionics: same probability as a human, tending toward Sensitive and Physical powers. Magic: none, unless a Magic O.C.C. is selected."
  - "Cybernetics and bionics: none; the whole idea seems crazy to them."
  - "A Shaman (Healing or Plant Shaman, or an Elemental Fusionist, Mystic or Psychic in that role) uses the skills and powers of that O.C.C. rather than the R.C.C. skills. Not applied by the picker."
  - "Standard equipment: one weapon for each W.P., a waterskin, a belt or bandoleer with pockets and belt loops, and makeshift patchwork M.D.C. armor (not environmental) with 2D6+17 M.D.C. Player characters start with no TW, magic or M.D.C. melee weapons."
extraction_notes: "WB30 D-Bees of North America printed 135-138 (cache p136-p139), read off 200 dpi renders. The heading M''Raghiile Tree Men, Mammalian Forest Dwellers of the Sequoia Forest, is at the foot of printed 135; the stat block headed M''Raghiile Tree Men - Optional Player Character or NPC starts at the foot of printed 136 and ends at the top of printed 138 (Money to Rivals and Enemies), before Malvoren. || CATEGORY: a race whose R.C.C. skills are the kit of a young wanderer; Shamans take an O.C.C. instead. || XP: the book says to use the Wilderness Scout experience table. It was left out at import, per that import''s brief, and an xp_table is stored now. || POOLS: Hit Points P.E. attribute number plus 1D4 per level, as hit_points_base. S.D.C. 3D6+8 is a racial S.D.C. stored as a pool bonus with men_of_arms false. M.D.C. by armor or magic only. P.P.E. 4D6. Horror Factor not applicable. || ATTRIBUTES as printed; Spd 3D6 is running on two legs, doubled on all fours, x10 leaping and swinging through trees (ability text). || BONUSES: +2 initiative, +1 strike, +4 automatic dodge, +1 disarm, +2 entangle, +2 pull punch, +6 roll stored. +2 to strike on leap attacks and kicks is conditional and ability text. +4 to visual, olfactory and auditory Perception Rolls is stored as perception 4. || SKILLS: catalog base plus the printed bonus. Escape Artist is printed (25%) with no plus sign; read as +25%, 55, like its neighbours. Identify Plants and Fruits is the catalog Identify Plants & Fruit. Hand to Hand: Basic for females and Expert for males is a one-of-two choice; no upgrade price is printed, so no hand_to_hand block. Two Domestic skills and three W.P. Ancient Weapons of choice are choice groups; Ancient is in the note, not enforced. || ADDITIONAL SKILLS at levels 2, 3, 4, 5, 7, 9 and 11 are level-gated picks restricted by category, which the related-skill schedule cannot narrow per level: prose in level_progression. Not modelled; BOOK-INGEST-AUDIT.md F116, since built, covers an ability picked from a named list at set levels and not a skill pick narrowed by category. No R.C.C. Related or Secondary skills are printed. || OCCUPATIONS: the Shaman Note names Healing or Plant Shaman (Spirit West), Elemental Fusionist, Mystic or Psychic; stored as healing-shaman, plant-shaman, both Elemental Fusionist classes, mystic and group:psychic, with group:magic for Magic: None, unless a Magic O.C.C. is selected. The skill swap is a restriction line, not pairing_skills (regression pins its carriers). || EQUIPMENT: belt or bandoleer is bandoleer-with-pouches-and-or-belt-loops. Granted since ~116 and ~117: the waterskin as water-skin-half-gallon and the makeshift patchwork M.D.C. armor (not environmental, 2D6+17 M.D.C.) as mraghiile-patchwork-armor; one weapon per W.P. names no item. No money is printed. || NOT STORED: size 3-4 feet plus a tail as long as the body, weight 45-80 pounds, life span 2D4+34 years, slave market value 3D4x1,000 credits, the names Raghiile Climbers, Sequoia Men, Tiger-Squirrel Men and Roggies, habitat, allies and enemies; in GM Notes."
---

## Lore

The M''Raghiile (said "em - rog - HEEL") are small, wiry forest people who live
high in the Sequoia and Giant Redwood forests of the Pacific Coast, with a band
of escaped Horune slaves settled in Dinosaur Swamp. They look part cat and part
monkey: tan fur striped with black, big yellow eyes, tufted lynx ears, a long
snout and a whip-like tail ending in a tuft. All four limbs end in real hands,
each with three fingers and two thumbs, and they swing and leap through the
branches like the most gifted acrobats.

Tribes are small and egalitarian, guided by elders, warriors and shamans, and
live in woven-stick shelters in the treetops on nuts, fruit, eggs, honey and
insects. They distrust outsiders, magic and technology alike, which to them are
the same loud, dangerous thing, and they flee into the canopy rather than
fight, though they fight savagely when cornered.

Most outsiders only ever meet a young M''Raghiile on its "wandering time", a
rite of passage in which youths leave the forest to find themselves before
coming home to a feast and a lifetime with the clan. Their own language of
clicks, purrs and chirps is hard for others to speak, so wanderers often pick
up American, Spanish or Nunnehi. Of their origin they keep only legends of the
"original forests" and the "great lightning" that brought them here.

## GM Notes

Experience: the entry names the Wilderness Scout experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Disposition: cheerful, friendly, compassionate and playful, but reserved and
skittish around strangers; fierce once provoked and very loyal to clan, kin
and friends. Many youngsters have wanderlust.

Size 3-4 feet (0.9 to 1.2 m) long, plus a tail as long as the body. Weight
45-80 pounds (20 to 36 kg). Life span 2D4+34 years; mature by 12. Also known
as Raghiile Climbers, Sequoia Men, Tiger-Squirrel Men and Roggies.

Money: little need for it; only young warriors on an adventure tend to carry
credits or trade goods, and they may bring magic or tech weapons home.

Habitat: the Sequoia forests of central and northern California, with scattered
communities in the rainforests of Oregon, Washington, British Columbia and
Dinosaur Swamp. Slave market value 3D4x1,000 credits. Allies: tribal peoples
such as traditional Native Americans, Psi-Stalkers, Druids and Wilderness
Scouts, and anyone who respects them. Enemies: they hate Horune Pirates and
other slavers, and dislike militant peoples such as the Coalition Army and the
Simvan.
',
       updated_at = datetime('now')
 WHERE class_id = 'mraghiile-tree-man'
   AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0
   AND length(markdown) = 11944;

-- == obsedai ==
UPDATE imported_classes
   SET markdown = '---
id: obsedai
name: Obsedai
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.151-154
category: rcc
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
tags: [combat]
attribute_dice:
  IQ: "2d6+4"
  ME: "2d6+4"
  MA: "2d6+2"
  PS: "3d6+20"
  PP: "3d6"
  PE: "2d6+12"
  PB: "2d4+1"
  Spd: "2d6+3"
mdc_base: "P.E. x10, +3d6 per level"
ppe_base: "5d6 + P.E."
horror_factor: 12
psionics_allowed: false
bonuses:
  combat: { disarm: 2, pull_punch: 3, roll: 4 }
  saves: { horror_factor: 1, other: [ { label: "vs airborne toxins", bonus: 2 } ] }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Obsedai, at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 80, note: "American at 80%; the catalog has no American row." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "Language: Other, one of choice (+5%)." }
    - { name: "Mathematics: Basic", base: 70, per_level: 5, note: "+25%." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%." }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%." }
    - { name: "Law", base: 45, per_level: 5, note: "Law: General (+10%)." }
    - { name: "Philosophy", base: 50, per_level: 5, note: "+20%." }
    - { name: "Calligraphy", base: 45, per_level: 5, note: "+10%." }
    - { name: "Camouflage", base: 35, per_level: 5, note: "+15%." }
    - { name: "Physical Labor", base: 0, per_level: 0 }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Body Building." }
    - { name: "Excavation", base: 55, per_level: 5, note: "+15%." }
    - { name: "Gemology", base: 45, per_level: 5, note: "+20%." }
    - { name: "Mining", base: 50, per_level: 5, note: "+15%." }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three Ancient of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts at the cost of one R.C.C. Related Skill. It plays as the Rifts Ultimate Edition skill, but is a style unique to the Obsedai that any martial artist recognizes as not native to Earth." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", only: ["Language: Other", "Literacy: Other"] }
      - { name: "Domestic", only: ["Dance", "Gardening", "Play Musical Instrument"], bonus: 5 }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Interrogation", "Tracking (people)", "Wilderness Survival"], bonus: 10 }
      - { name: "Horsemanship", only: ["Horsemanship: Exotic Animals"], bonus: 5 }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5 }
      - { name: "Military", only: ["Military Etiquette", "Military Fortification", "Trap/Mine Detection"], bonus: 5 }
      - { name: "Physical", only: ["Climbing", "Juggling", "Physical Labor"] }
      - { name: "Pilot Related", only: ["Navigation"], bonus: 5 }
      - { name: "Rogue", only: ["Concealment", "Imitate Voices & Sounds", "Prowl", "Tailing"], bonus: 5 }
      - { name: "Science", only: ["Anthropology", "Astronomy & Navigation", "Botany"], bonus: 10 }
      - { name: "Technical", only: ["Appraise Goods", "Art", "Breed Dogs", "Lore: Aborigines", "Lore: Astral", "Lore: Chinese Classical Studies", "Lore: Chinese Mythology: Buddhist", "Lore: Chinese Mythology: Taoist", "Lore: Cities", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Dreamtime Culture", "Lore: Faeries & Creatures of Magic", "Lore: Feng Shui/Geomancy", "Lore: Galactic/Alien", "Lore: General Law", "Lore: History of Russia", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Rifts China", "Lore: Vampires", "Lore: Western World", "Lore: Wormwood", "Masonry", "Recycling", "Rope Works", "Salvage", "Ventriloquism", "Whittling & Sculpting"], bonus: 10 }
      - { name: "Weapon Proficiencies", except: ["W.P. Deadball"] }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
natural_abilities:
  - name: "Mega-Damage stone body"
    description: "M.D.C. is the P.E. attribute number x10, plus 3D6 per level of experience. Never wears artificial armor or uses force fields. In S.D.C. environments: Hit Points of P.E. x4 plus 3D6 per level, 1D4x100 S.D.C. and a natural A.R. of 16. Not a creature of magic: a silicon-based being that breathes, rests and eats (wood, limestone, granite, coal or any stone)."
  - name: "Stone hardiness"
    description: "Fatigues at 10% the rate of humans. Robot-equivalent P.S. from birth, which becomes Supernatural when enraged, in combat or in Stone Armor. Bio-regenerates 2D6 M.D.C. per hour, double for an hour of meditation. Impervious to pain, S.D.C. weapons, heat and cold, and to poison and toxins; M.D. fire and cold do half damage."
  - name: "Juveniles"
    description: "All stats and bonuses, including Stone Armor, are half for an Obsedai under the age of 200."
special_abilities:
  - name: "Stone Armor (Fury Armor)"
    description: "When enraged or entering combat, stone armor seems to form out of thin air and clamp onto the body: +120 M.D.C. per level of experience, double weight and +50% size. Robot P.S. and P.E. become Supernatural Strength and Endurance, and the fury adds +1 attack per melee, +3 to strike, +2 to parry and +5 to save vs Horror Factor on top of R.C.C., skill and attribute bonuses. Horror Factor rises to 16. Duration: 20 minutes per level of experience, or until the fighting stops and the rage cools. Not applied by the sheet."
  - name: "Stone Weapon"
    description: "Formed from the Obsedai''s own body during its coming of age: a stone axe, sword or maul, supernaturally hard enough to parry Mega-Damage attacks. Does 6D6 S.D.C. normally, and adds 3D6 M.D. to the Obsedai''s punch damage during its Berserker Rage. 200 M.D.C.; destroyed only if specifically targeted. A lost weapon is replaced after 6D6+48 hours of concentration, meditation and fasting. Only one can exist at a time."
trackable_resources: []
side_effects: "Frightening appearance, size and weight can be a liability, especially in towns. Healing magic and healing psionics have no effect on an Obsedai. The Stone to Flesh warlock spell does not work on them, but does 1D6 M.D. per level of the caster."
equipment_starting:
  - { item_id: "obsedai-stone-weapon", qty: 1, note: "A stone axe, sword or maul, the player''s pick of form." }
restrictions:
  - "Alignment: any, but mostly Principled (48%), Scrupulous (30%), Unprincipled (10%) or Aberrant (8%)."
  - "Available O.C.C.s: none. Obsedai are creatures of instinct and habit and use the R.C.C. skills."
  - "Psionic powers: none. Magic knowledge: none."
  - "Cybernetics and bionics: none; incompatible with Obsedai physiology."
  - "Secondary Skills: none."
extraction_notes: "WB30 D-Bees of North America printed 151-154 (cache p152-p155), read off 200 dpi renders. The heading Obsedai is on printed 151; the stat block headed Obsedai R.C.C. - Optional Player Character or NPC starts on printed 152 and ends at the top of printed 154 (the Stone Weapon close, Money to Rivals and Enemies) before Phlebus, so the entry runs one page past the 151-153 the brief lists. || CATEGORY: a race that is its own class; Available O.C.C.s: None is a restriction line with no occ_restrictions block (the armored-slayer precedent). || XP: the book says to use the Combat Cyborg table. It was left out at import, per that import''s brief, and an xp_table is stored now. || POOLS: M.D.C. P.E. attribute number x10 plus 3D6 per level, as mdc_base; the S.D.C.-environment figures are ability text. P.P.E. 5D6 +P.E. attribute number. Horror Factor 12, 16 enraged in Stone Armor. || ATTRIBUTES as printed; P.S. 3D6+20 is Robotic, Supernatural when enraged (ability text). || BONUSES: +2 disarm, +3 pull punch, +4 roll, +2 vs airborne toxins (saves.other), and +1 vs Horror Factor at levels 1, 3, 5, 7, 9, 13 and 15 (level 11 is not in the printed list): level 1 in saves, the rest as at_level entries. Impervious to poison and toxins is ability text. Stone Armor bonuses are conditional and a special ability. || PSIONICS: None, stored as psionics_allowed false (the yeno precedent). Magic: none. || SKILLS: catalog base plus the printed bonus. Language: Native Tongue (Obsedai) at 98. Language: American at 80% is a one-pick Language: Other at 80, the catalog having no American row. Law: General is the catalog Law. Body Building is Body Building & Weight Lifting. W.P.: Three Ancient of choice is a choice group; Ancient is in the note. Hand to Hand: Expert can be changed to Martial Arts for one R.C.C. Related Skill: hand_to_hand costs martial_arts 1. || RELATED: six at level one plus one at levels 3, 6, 9, 12 and 15. Cowboy, Electrical, Mechanical and Pilot: None are omitted. Each only-list is as printed with its bonus; Communications Language and Literacy only is Language: Other (filed Technical, which the class grants) and Literacy: Other. Espionage names Wilderness Survival, filed Wilderness, which the class grants. Rogue names Prowl, filed Physical. Astronomy and Navigation is the catalog Astronomy & Navigation. Technical all Lore skills is every Technical Lore row in the catalog on 2026-10-03. W.P. any except Dead Ball (W.P. Deadball). Secondary Skills: None, so no secondary block. || EQUIPMENT: the stone weapon is granted since ~116 and ~117 as obsedai-stone-weapon (a stone axe, sword or maul, the player''s pick of form); the special ability keeps its stats. || MONEY: printed as earthly possessions that would fetch 1D6x1,000 credits, not money; not stored as starting_money, in GM Notes. || NOT STORED: size 10 feet growing a foot per 100 years, weight 1,200 pounds plus 200 per 100 years, life span 1D6x100+300 years, the names Stone Men, Hardbodies and Stone Fury, slave market value 3D6x100,000 credits, habitat, allies and enemies; in GM Notes."
---

## Lore

The Obsedai (said "OB - seh - die") are giant D-Bees of living stone who keep
to the remote heights of the Rockies and the Appalachians. Their hides are
Mega-Damage rock, black as obsidian, tan, brown or ash white depending on the
minerals of the land they eat from, and their eyes glow like magma under a
cooled crust. They eat wood, limestone, granite and coal, make superb miners,
and are coveted by the Splugorth as laborers, gladiators and enforcers.

Every Obsedai is raised as a warrior, and at its fortieth "Cooling Day" proves
itself in a hard trial of strength and endurance, during which it shapes a
great weapon of stone from its own body over thirteen days of fasting and
meditation. Their teachings resemble Taoism: calm, meditation and the natural
order of things, together with the idea that all things are one yet separate
in the world. Some sit in meditation for years until moss grows over them.

They are very slow to anger, shrugging off insults, theft and violence done
for a good cause, but a crime against life, such as slavery, murder, torture
or cruelty for its own sake, sends them into a fury. Then stone armor forms
over them and they become walking juggernauts that will charge any odds to
protect the innocent. That makes them natural champions, and they count
Psi-Warriors, Cyber-Knights, Knights of the White Rose and Blucies as kindred
spirits.

## GM Notes

Experience: the entry names the Combat Cyborg experience table, whose stored ladder this class copies (class-import rule, Nate 2026-09-26).

Player character note: part philosopher, part barbarian; they can learn the
laws of other lands but fall back on brute force as their form of diplomacy,
and in any group they draw concern, fear and the first attacks in a fight.

Disposition: quiet and reflective with a strong sense of justice and
compassion; slow to trust.

Size starts at 10 feet (3 m) and grows a foot every 100 years. Weight starts
at 1,200 pounds (540 kg) plus 200 pounds (90 kg) per 100 years or foot of
height; size grows 50% in Stone Armor. Life span 1D6x100+300 years; mature at
200. Females bear one young every 1D4x10+50 years. Also known as Stone Men,
Hardbodies and Stone Fury.

Money: little need for it, but may own possessions worth 1D6x1,000 credits.

Habitat: any mountains, most of all the Rockies and the Appalachians. Slave
market value 3D6x100,000 credits as thugs, enforcers or gladiators. Allies:
Psi-Warriors, Cyber-Knights, Knights of the White Rose, Blucies and Lyn-Srial,
and anyone good and kind. Enemies: Splugorth slavers, Mystic Knights, the
Coalition and all evil and cruel beings; they dislike robots, automatons and
golems, find Elementals baffling, fear Warlocks and Elemental Fusionists, and
never trust Anarchist or evil characters.
',
       updated_at = datetime('now')
 WHERE class_id = 'obsedai'
   AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0
   AND length(markdown) = 13367;

-- == ngr-robot-soldier ==
UPDATE imported_classes
   SET markdown = '---
id: ngr-robot-soldier
men_of_arms: true
occ_group: men-of-arms
name: NGR Robot Soldier
system: rifts
source_book: Rifts World Book 5: Triax and the NGR p.166-170
category: occ
tags: [combat, augmented]
xp_table: [0, 2501, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 160001, 190001, 240001, 300001, 370001, 440001]
starting_money: "2d6x1000"
skills:
  skill_programs:
    choose: 3
    base: 38
    per_level: 0
    note: "Printed 170. Choose up to three; each grants EVERY skill it lists at a flat 38% with no bonuses and no gain per level, and every task takes 1D4 times longer. Rogue is offered as None by the book and is not listed. W.P. is printed as ''All Modern'': the whole Weapon Proficiencies category is offered because the catalog does not mark a W.P. ancient or modern - the same convention the Crazy, the Burster and both Elemental Fusionists use - so a G.M. should hold the player to modern W.P.s only."
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics", "Computer Repair"] }
      - { name: "Espionage", only: ["Tracking (people)", "Intelligence", "Wilderness Survival"] }
      - { name: "Mechanical", except: ["Mechanical Engineer", "Robot Mechanics"] }
      - { name: "Medical", only: ["Paramedic", "Forensics"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling", "Prowl"] }
      - { name: "Pilot", except: ["Robots & Power Armor"], except_prefix: ["Robot Combat"] }
      - "Science"
      - { name: "Technical", except_prefix: ["Lore"] }
      - "Weapon Proficiencies"
      - "Wilderness"
bonuses:
  combat: { initiative: 2, strike: 1, parry: 1, roll: 2, pull_punch: 2 }
  saves: { horror_factor: 3, illusionary_magic: 2, psionics: 2, spell_magic: 2, ritual_magic: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
variants:
  - id: x-545-super-hunter
    name: "X-545 Super Hunter"
    mdc_base: 500
    attribute_dice: { PS: "50" }
  - id: x-2000-dyna-max
    name: "X-2000 Dyna-Max"
    mdc_base: 550
    attribute_dice: { PS: "50" }
  - id: x-2500-black-knight
    name: "X-2500 Black Knight"
    mdc_base: 750
    attribute_dice: { PS: "50" }
  - id: x-2700-dragonwing
    name: "X-2700 Dragonwing"
    mdc_base: 525
    attribute_dice: { PS: "50" }
  - id: dv-12-dyna-bot
    name: "DV-12 Dyna-Bot"
    mdc_base: 130
    attribute_dice: { PS: "40" }
  - id: dv-15-sentry-bot
    name: "DV-15 Sentry-Bot"
    mdc_base: 160
    attribute_dice: { PS: "40" }
  - id: dv-40-hunter-killer-drone
    name: "DV-40 Hunter/Killer Drone"
    mdc_base: 300
    attribute_dice: { PS: "40" }
  - id: eir-10-gargoyle-drone
    name: "EIR-10 Gargoyle Drone"
    mdc_base: 250
    attribute_dice: { PS: "40" }
  - id: eir-15-gargoyle-manned-robot
    name: "EIR-15 Gargoyle Manned Robot"
    mdc_base: 280
    attribute_dice: { PS: "40" }
  - id: eir-20-gurgoyle-drone
    name: "EIR-20 Gurgoyle Drone"
    mdc_base: 200
    attribute_dice: { PS: "30" }
  - id: eir-30-gargoylite-drone
    name: "EIR-30 Gargoylite Drone"
    mdc_base: 50
    attribute_dice: { PS: "20" }
  - id: eir-50-gurgoyle-android
    name: "EIR-50 Gurgoyle Android"
    mdc_base: "1d4x100"
    attribute_dice: { PS: "30", Spd: "33" }
restrictions:
  - "THE BODY IS ONE OF THE ROBOTS PRINTED 169 LISTS, CHOSEN AS THE VARIANT, each a vessel row: any EIR (`eir-10-gargoyle-drone`, `eir-15-gargoyle-manned-robot`, `eir-20-gurgoyle-drone`, `eir-30-gargoylite-drone`, `eir-50-gurgoyle-android`), `dv-12-dyna-bot`, `dv-15-sentry-bot`, `dv-40-hunter-killer-drone`, and a modified `x-545-super-hunter`, `x-2000-dyna-max`, `x-2500-black-knight` or `x-2700-dragonwing`. The DV-13 Dyna-Bot the page also names is statted nowhere in the book."
extraction_notes: |
  - THIS CLASS GRANTS NO SKILLS AND THAT IS THE BOOK''S OWN RULE, not a gap in
    the reading. Printed 170 says the character''s past O.C.C. training - one of
    the military O.C.C.s - IS the robot soldier''s range of skills, frozen at the
    level held when the conversion happened, and that those skills do not
    improve again until the character reaches the same level as a robot soldier.
    The app has no shape for an occupation that inherits a DIFFERENT
    occupation''s skill list, so no occ_skills, occ_related_skills or
    secondary_skills block is written rather than inventing one. Filed as
    BOOK-INGEST-AUDIT.md F23.
  - THE THREE SKILL PROGRAMS ARE STORED, and the app grew a shape for them.
    Printed 170 lets the character select up to three skill CATEGORIES, and
    every skill in a selected category is then available at a flat 38% with no
    bonuses and no improvement with experience, at 1D4 times the normal time.
    occ_related_skills picks N SKILLS from listed categories; this picks N
    CATEGORIES and grants all of them, which is why it is its own block rather
    than a large count. See BOOK-INGEST-AUDIT.md F23(b).
  - THIRTEEN CATEGORIES ARE OFFERED WHERE THE BOOK PRINTS FOURTEEN LINES. The
    fourteenth is Rogue: None - a refusal, not an offer - so Rogue is absent
    rather than present and empty.
  - W.P. IS PRINTED AS "All Modern" AND THE WHOLE CATEGORY IS OFFERED, which is
    the one place this grant is wider than the page. The catalog does not mark
    a W.P. ancient or modern, and CLASS-AUDIT.md records that those splits ride
    in notes; the Crazy, the Burster and both Elemental Fusionists all grant
    the whole category and say so in prose. The block note tells the player.
  - The book''s fourteen skill-program categories carry their own exclusions,
    all recorded in the body: Rogue is None, Electrical is basic electronics and
    computer repair only, Espionage is tracking, intelligence and wilderness
    survival only, Medical is paramedic and forensics only, Mechanical excludes
    mechanical engineer and robot mechanics, Physical excludes acrobatics,
    gymnastics, wrestling and prowl, Pilot excludes robots & power armor and
    robot combat, Technical excludes lore, and W.P. is All Modern.
  - "+2 to save vs magic" is stored as BOTH spell_magic and ritual_magic. The
    book writes one line for magic and the sheet draws the two separately, so
    granting one would silently halve a bonus the book states without
    qualification.
  - The three extra melee attacks are at_level entries. The book states them as
    the robot body providing one additional attack at levels two, six and
    twelve, on top of whatever the human''s hand to hand training gives - and the
    hand to hand training is inherited with the rest of the previous O.C.C., so
    the class states no base attacks of its own.
  - THE BODY IS A CHOICE OF VESSEL ROWS, and a restriction line names them
    since 2026-09-27 (~029-class-vessel-notes.sql). Printed 169 lists the nine lines a
    robot soldier may be built from - any EIR, the DV-12, DV-13, DV-15 and DV-40
    bots, and modified X-545, X-2000, X-2500 and X-2700 robot vehicles - and
    twelve `vehicles` rows answer them since #791: the five EIR units, three DV
    bots and four X-series robots. THE DV-13 HAS NO ROW because the book stats
    none; its robot section prints the DV-12, DV-15 and DV-40 only. The body is
    the character, not issued kit, so there is no gear pointer, as with the
    Mining ''Borg. Since ~115 each of the twelve is a VARIANT of the class,
    by Nate''s ruling of 2026-10-04: the variant sets the main body M.D.C. and
    the robot P.S. its page prints, read off renders. No page prints a P.P.,
    and only the EIR-50 prints a Spd, so nothing else is set: printed 169
    says strength, speed, leaping, flight and weapon systems are exactly the
    robot''s own, and those are read from the vessel row. A variant carries
    no bonuses: a drone''s printed bonuses are its program''s, the four
    X-series print theirs as pilot combat training, and the class''s own
    bonuses are what the human mind adds. The EIR-50''s main body is rolled,
    1D4x100. Until ~029
    this note said every one of the nine was a BOOK-INGEST-AUDIT.md F3 vessel
    the catalog could not hold.
  - The book marks this O.C.C. "(optional)" on its roster on printed 156. It is
    imported like the rest: it has its own experience ladder on printed 224 and
    a full set of stats and bonuses. The marking is a GM note.
  - It states no Attribute Requirements. Printed 169-170 gives eligibility as a
    volunteer standard rather than as attribute floors, so no block is written.
  - starting_money is the first-level savings the book prints, 2D6x1000. The
    3500 credit monthly salary and the 5000 to 9000 a month for 9th level and
    higher are pay rather than starting coin and are in the body.
---

## Lore

Triax experimentation, and the one robot that can be a player character. The typical NGR combat robot is a non-living, non-sentient tool with a computer brain, deliberately given no simulated emotion, no human voice and little character so that soldiers do not become attached to it. Printed 166 says those machines are not available as player characters.

A robot soldier is different: a human intelligence placed in direct control of a robot body without being physically part of it. Triax is pursuing three routes - virtual reality, M.O.M. transmission of intelligence, and brain transplant. The brain or transferred essence sits in a protective environmental housing inside the mega-damage body, impervious to heat, cold, gases, drugs, toxins, pollution and radiation, and it survives underwater and in space. If the body is destroyed the housing can usually be retrieved and installed in a new one; only atomising the robot - double its main body in damage - destroys the brain. A brain can survive two weeks without a body and power supply.

Alignment: Any. Fewer than 0.02% of NGR troops have been converted.

## Skills come from the life before

This class grants no skills of its own. Printed 170: the character''s previous O.C.C. training, presumably one of the military O.C.C.s, is the robot soldier''s range of skills, frozen at the experience level held at conversion. They begin improving again only once the character reaches that same level as a robot soldier - a sixth level soldier does not improve until seventh level as a robot.

The app cannot express an occupation that inherits another occupation''s skill list, so build the character''s previous O.C.C. and carry its skills across by hand.

## The three skill programs

Up to three skill categories may be programmed into the robot''s supplemental computer and accessed by the human brain, the way a city rat or borg links to a computer through a headjack. Every skill in a selected category becomes available at a flat **38%**, with no bonuses, no improvement with experience, and every task taking 1D4 times longer.

The categories, with the book''s own exclusions:

| category | available |
|---|---|
| Communications | all |
| Domestic | all |
| Electrical | basic electronics and computer repair only |
| Espionage | tracking, intelligence and wilderness survival only |
| Mechanical | all except mechanical engineer and robot mechanics |
| Medical | paramedic and forensics only |
| Military | all, though the book does not recommend it |
| Physical | all except acrobatics, gymnastics, wrestling and prowl |
| Pilot | all except robots & power armor and robot combat |
| Rogue | none |
| Science | all |
| Technical | all except lore |
| Weapon Proficiencies | all modern |
| Wilderness | all |

Stored: the class''s skill_programs block picks three of these categories and grants each one whole.

## The body

Printed 169 lists what a robot soldier may be built into: any EIR, the DV-12 Dyna-Bot, DV-13 Dyna-Bot, DV-15 Sentry Bot, DV-40 Hunter/Killer Bot, and modified X-545 Jager Super Hunter, X-2000 Dyna-Max, X-2500 Black Knight and X-2700 Dragonwing. The X-series machines are modified so no pilot is needed and none can override the bot; the transplanted brain controls every function, though seats remain usable by passengers. No other bodies are available, and a soldier rarely changes body once chosen.

Each is a vessel row, named in the restrictions, except the DV-13, which the book never stats. The body is chosen as the variant, which sets the main body M.D.C. and the robot P.S.; speed, leaping, flight and weapon systems are the robot''s own, from that row. The bonuses on this class are only what the human mind adds on top.

## Pay

Salary is 3500 credits a month, rising to 5000 to 9000 for ninth level and higher, with complete maintenance, repairs and equipment free. Human-size bots share human quarters; giant robots are assigned a private garage or hangar.

## GM Notes

The robot soldier gets the equipment and weapons assigned to that particular robot. Most human-size bots can use rail guns and heavy weapons and pilot vehicles. Larger bots usually arrive with their own array of sensors, weapons and features. Access to most military bases at mid to high security clearance, and top priority for robot parts, weapon systems, repairs and maintenance.

Virtual reality pilots - one of the three routes - carry psychological risks the book details on printed 167: roughly 50% develop some degree of adventure addiction, about 10% become schizoid, and manic depression and phobias also occur. A VR pilot directs only one robot at a time, at a maximum range of 500 miles, and suffers -3 on initiative, no combat bonuses and half the melee actions when the link is disrupted by jamming, solar flares, unusual ley line activity or a dimensional rift.
',
       updated_at = datetime('now')
 WHERE class_id = 'ngr-robot-soldier'
   AND instr(markdown, 'Not stored: the app picks skills from categories, not categories wholesale') > 0
   AND length(markdown) = 13618;

-- == slayer-russian ==
UPDATE imported_classes
   SET markdown = '---
id: slayer-russian
men_of_arms: true
name: Slayer
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.136-140
category: occ
tags: [combat, wilderness, hunter]
occ_group: men-of-arms
xp_table: [0, 2101, 4201, 8401, 16801, 25001, 35001, 50001, 70001, 95001, 130001, 180001, 234001, 285001, 345001]
attribute_requirements: { ME: 14, PS: 12 }
ppe_base: "1d4x10+10 plus the P.E. attribute number, and 2d4+1 more per level of experience"
starting_money: "2d4x1000"
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Russian", base: 95, per_level: 0, note: "Speaks Russian at 95%" }
    - { name: "Language: Chinese", bonus: 20, note: "Speaks Chinese (+20%). The book grants CHINESE rather than Euro here, which no other class in it does - the Slayer is ''sometimes confused with the Demon Queller'' of Rifts Japan, and hunts east as well as west." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%)" }
    - { name: "Lore: Demons & Monsters", bonus: 30, note: "Lore: Demons & Monsters (+30%)" }
    - { choose: 1, from: ["Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 20, note: "Lore: one of choice (+20%)" }
    - { name: "Intelligence", bonus: 10, note: "Intelligence (+10%)" }
    - { name: "Tracking (people)", bonus: 15, note: "The book prints ''Tracking (+15%; humans and demons)''; the catalog row is Tracking (people)." }
    - { name: "Land Navigation", bonus: 10, note: "Land Navigation (+10%)" }
    - { name: "Wilderness Survival", bonus: 10, note: "Wilderness Survival (+10%)" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot Skill: one of choice (+10%)" }
    - { name: "Climbing", bonus: 5, note: "Climbing (+5%)" }
    - { name: "Swimming", note: "Swimming" }
    - { name: "Boxing", note: "Boxing" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, three of choice (any)." }
    - { name: "W.P. Automatic and Semi-automatic Rifles", note: "The book prints ''W.P. Automatic and Semi-Automatic Rifles (including shotguns)''; the catalog row is spelled with a lower-case ''automatic'' in the second word." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapons, two of choice (any)." }
    - { name: "Hand to Hand: Expert", note: "Expert to start, and can be changed to Martial Arts or Assassin for the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 5
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - "Espionage"
      - { name: "Medical", only: ["First Aid"], note: "First Aid only." }
      - { name: "Physical", except: ["Gymnastics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
  secondary_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 9, count: 1 }, { level: 13, count: 1 }]
magic:
  type: "spell"
  spells:
    - "Globe of Daylight"
    - "Turn Dead"
    - "Armor of Ithan"
    - "Fire Bolt"
    - "Fire Ball"
    - "Call Lightning"
    - "Magic Net"
    - "Magic Pigeon"
    - "Tongues"
    - "Magic Shield"
    - "Fist of Fury"
    - "Deflect"
    - "Targeted Deflection"
    - "Ricochet Strike"
    - "Frostblade"
    - "Lightblade"
bonuses:
  combat: { pull_punch: 4 }
  saves: { possession: 3, spell_magic: 1, ritual_magic: 1, mind_control: 3, disease: 4 }
  at_level:
    - { level: 1, saves: { horror_factor: 1 } }
    - { level: 2, combat: { initiative: 1 } }
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
special_abilities:
  - name: "Sense the supernatural"
    description: "The Slayer can tell a supernatural being from a human. A failed roll means he knows the thing is more than human but cannot tell exactly what it is."
  - name: "Impervious to Vampires"
    description: "The Slayer CANNOT be turned into a vampire, nor mind controlled by one in any way. The +3 to save vs all mind control, hypnosis and mind-altering chemicals is carried in bonuses; the immunity itself is absolute rather than a bonus, and seduction is at -30% against him."
  - name: "Nightvision & See the Invisible"
    description: "Both are a regular and constant part of the Slayer''s vision. Nightvision 500 feet (152 m)."
  - name: "Ley Line Healing/Rejuvenation"
    description: "Resting at a ley line for several days DOUBLES the natural healing rate. Once every 48 hours he can also heal instantly by meditating while sitting on a ley line: after 15+1D6 minutes, 2D6 Hit Points and 2D6 S.D.C. are restored."
  - name: "Horror Factor"
    description: "The Slayer PROJECTS a Horror Factor of 13 to lesser demons and 9 to greater demons. A Horror Factor the character projects is not a save the character makes, so it is recorded here; the +1 to SAVE vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 10, 12 and 14 is carried in bonuses.at_level."
  - name: "Save vs disease"
    description: "+4 to save vs disease. It is carried in bonuses, as the +1 to save vs magic and +3 vs possession are; do not add it a second time."
  - name: "Spell strength"
    description: "+1 to spell strength at levels 3, 7, 11 and 15."
  - name: "Learning New Spells"
    description: "At best, every two levels of experience the Slayer learns one or two spells for his demon-fighting repertoire. Additional common Wizard spells of ANY level can also be learned or purchased at any time regardless of experience level. Both the pace and the count are vague in the book - ''at best'', ''one or two'' - so neither is expressed as a per-level number."
  - name: "The Slayer''s Code"
    description: "Destroy supernatural evil. He mostly (90%) knows combat and offensive spells useful against the supernatural and really is not interested in learning more."
restrictions:
  - "Any alignment, but typically scrupulous (33%), unprincipled (24%), anarchist (20%), aberrant (8%) or other (15%)."
  - "Racial requirements: none, although predominately human males. Also known as the Demon and Serpent Slayer or Demon Hunter, and sometimes confused with the Demon Queller of Rifts Japan, who is also found in southern and eastern Russia."
  - "The character also starts with 1D6x1000 credits'' worth of TRADEABLE GOODS, over and above the coin in starting_money. That field is coin only, and the book prices the coin in credits OR RUBLES."
  - "Starts with a horse, or a rickety old hovercycle or similar vehicle with only HALF its M.D.C."
  - "Most Slayers avoid blood sacrifices for P.P.E. unless the victim is an evil supernatural being."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.136-140. THE FIRST MEN-OF-ARMS CLASS IN THIS BOOK, and occ_group turns out to be a CLOSED SET the parser enforces - clergy, men-of-arms, optional, magic, psychic. A first attempt at ''adventurer'' was rejected outright, which is the right kind of failure. The Slayer is a warrior who casts rather than a practitioner of magic: the book calls him ''a modest spell caster'' with a ''strong understanding of magic'', and gives him Boxing, Hand to Hand: Expert and six weapon proficiencies. That classification also settles his S.D.C., since its own `men_of_arms: true` line gives a man of arms 3D6 (until 2026-09-25 a CORE_SDC_BY_CLASS entry in js/compose.js) where every other class in this book takes 1D6. The sixteen starting spells are granted by name and none needs a tradition: all are common Wizard spells from the Rifts RPG and Federation of Magic. THE BONUS SCHEDULE IS THE MOST GRANULAR IN THE BOOK and is carried in bonuses.at_level: +1 initiative at levels 2, 4, 8 and 12, and +1 to SAVE vs Horror Factor at levels 1, 3, 4, 5, 7, 8, 10, 12 and 14 - nine separate levels, which is why it is a schedule rather than a flat number. The Horror Factor the Slayer PROJECTS (13 to lesser demons, 9 to greater) is a different thing and is prose. +4 to save vs disease is stored in bonuses as saves.disease. Four names needed the catalog''s spelling: Tracking is Tracking (people), Fists of Fury is Fist of Fury, W.P. Automatic and Semi-Automatic Rifles is spelled with a lower-case second ''automatic'', and Basic Math is Mathematics: Basic. `Language: Chinese` is CREATED, Technical 50/+5 on the same convention as Language: Russian - this is the only class in the book that grants Chinese rather than Euro, which fits a hunter who works east as well as west."
---

# Slayer

## Lore

The Demon and Serpent Slayer - more commonly just the Slayer - is dedicated to
exterminating evil supernatural beings, dragons, dangerous Woodland spirits and
monsters of all sorts, including witches, Necromancers and evil practitioners of
magic. They specialise in demons and serpents.

He is a warrior first and a spell caster second: sixteen spells, almost all of
them combat magic, and no real interest in learning more. What he has instead is
sight that pierces the dark and the invisible, an immunity to vampirism that
cannot be taken from him, and the ability to heal himself on a ley line.

## Alignment

Any, but typically scrupulous, unprincipled or anarchist.

## GM Notes

The Slayer projects a Horror Factor at demons rather than the other way round -
13 to lesser demons and 9 to greater ones. He is the thing under their bed.

His code is one line: destroy supernatural evil. Most do not care about money or
fame provided they have enough to keep hunting - though demon hunting is
exhausting and expensive, and they are not shy about demanding fair pay in
supplies, silver and ammunition.
',
       updated_at = datetime('now')
 WHERE class_id = 'slayer-russian'
   AND instr(markdown, '+4 to save vs disease has no field and is prose') > 0
   AND length(markdown) = 10541;

-- == totem-warrior ==
UPDATE imported_classes
   SET markdown = '---
id: totem-warrior
men_of_arms: true
name: Totem Warrior
system: rifts
source_book: Rifts World Book 15: Spirit West p.42-44
category: occ
tags: [combat, wilderness, shapeshifter]
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
occ_group: men-of-arms
attribute_requirements: { IQ: 9, ME: 9 }
starting_money: "3d6x100 in trade goods"
psionics:
  type: "minor"
  isp_base: "M.E. attribute + 1d6 per level of experience"
  powers_starting: 1
  categories_allowed:
    - { name: "Sensitive", except: ["Astral Projection", "Clairvoyance"] }
  powers_schedule:
    - { level: 3, count: 1 }
    - { level: 6, count: 1 }
    - { level: 9, count: 1 }
    - { level: 12, count: 1 }
    - { level: 15, count: 1 }
mdc_from_hp_sdc: true
ppe_base: "1d4x10 + P.E. attribute, +10 per level of experience"
bonuses:
  combat: { initiative: 2, strike: 1, disarm: 1, dodge: 1, roll: 1 }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The character''s native tribal language, at 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "English (American), at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 10, note: "One additional language of choice (+10%)." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. The book''s Tracking." }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: Cowboy", base: 66, per_level: 3 }
    - { name: "Trick Riding", base: 0, per_level: 0 }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 65, per_level: 5, note: "+15%" }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%" }
    - { name: "Lore: Cattle & Animals", base: 45, per_level: 5, note: "+15%. The book''s Lore: Animals/Cattle." }
    - { name: "Animal Husbandry", base: 45, per_level: 5, note: "+10%" }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book''s W.P. Archery and Targeting." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be upgraded to Martial Arts for one O.C.C. Related skill." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Cowboy", bonus: 5 }
      - { name: "Domestic", note: "The book prints +10% to Sing only; this catalog files Sing under Communications, which the class does not grant, so no Domestic skill takes a bonus." }
      - { name: "Espionage", except: ["Forgery", "Sniper"], bonus: 10 }
      - { name: "Horsemanship", note: "The book''s Pilot line allows horsemanship; this catalog files it as a category of its own." }
      - { name: "Medical", only: ["Holistic Medicine", "Brewing"], note: "The book prints +10% against Holistic Medicine only; the next line carries it." }
      - { name: "Medical", only: ["Holistic Medicine"], bonus: 10, note: "+10% against Holistic Medicine only." }
      - { name: "Military", except: ["Demolitions", "Demolitions Disposal", "Demolitions: Underwater", "Parachuting", "NBC Warfare"], bonus: 10 }
      - { name: "Physical", bonus: 10, note: "+10% where the skill carries a percentage." }
      - { name: "Pilot", only: ["Boat: Sail Type", "Boat: Paddle Types/Canoe/Kayak"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 5 }
      - { name: "Science", only: ["Astronomy", "Astronomy & Navigation", "Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", bonus: 10, note: "Art, language and lore skills only." }
      - { name: "Weapon Proficiencies", note: "Ancient weapons. A revolver or bolt-action rifle only with the G.M.''s leave, and never for a Pure One." }
      - { name: "Wilderness", bonus: 10 }
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
totem: { from: "animal", powers: true }
special_abilities:
  - name: "Supernatural Attributes"
    description: "From the moment of infusion the Totem Warrior''s P.S. and P.E. are supernatural even in human form: the P.S. does supernatural damage, and the supernatural P.E. makes him a mega-damage creature - his combined S.D.C. and hit points become an M.D.C. total. He bio-regenerates 5D6 of it per 24 hours."
  - name: "Animal Totem"
    description: "Must pick one animal totem, whose skills and bonuses he has in human form; in giant animal form he also gains that totem''s Totem Warrior powers, which only this class can draw on. Most pick a predator or a medium to large animal. The totems, with their skills, bonuses and powers, are printed 96-105. Chosen in the wizard from the shared totems catalog; see BOOK-INGEST-AUDIT.md F56."
  - name: "Animal Totem Form"
    description: "Transforms into his totem species in two versions. Normal size: an ordinary-looking animal with its natural abilities, keeping his mind and his mega-damage body but none of the totem powers - for spying, sneaking and escape. Giant: two or three times normal size for medium and large animals, ten times for small ones such as birds and mice, with every totem power. Either form costs 10 P.P.E. to assume, going from small to giant another 10, returning to human form 5; the animal form lasts indefinitely, and he can speak any language he knows."
  - name: "Animal Psionic Senses"
    description: "In animal form he has the predator''s innate ability to sense psychic and magic energy and supernatural beings, as a Dog Boy does, constantly and at no I.S.P. cost."
  - name: "Limited Magic"
    description: "Kinship with his Totem Spirit gives him the equivalent of Fear (5 P.P.E.), Repel Animals (7 P.P.E.), and summoning and controlling animals of his own totem species, 1D4 per level (50 P.P.E.)."
equipment_starting:
  - { choose: 1, label: "minor fetish", qty: 1, from: ["armor-fetish", "body-fetish", "climbing-fetish", "damage-fetish", "ear-fetish", "healing-fetish", "heritage-and-self-fetish", "luck-fetish", "porcupine-quill-fetish", "prowl-fetish", "song-fetish", "speed-fetish", "strength-fetish", "sure-footedness-fetish", "swimming-fetish", "tooth-and-claw-fetish-minor", "tracking-fetish", "wind-wing-fetish"] }
  - { choose: 1, label: "major hunting or combat fetish", qty: 1, from: ["supernatural-damage-fetish", "great-armor-fetish", "great-body-fetish", "great-ear-fetish", "great-speed-fetish", "great-tracking-fetish", "superhuman-strength-fetish", "great-tooth-and-claw-fetish", "weapon-fetish", "wing-flight-fetish", "tattoo-war-fetish", "tattoo-steady-hand-fetish"] }
  - { choose: 1, label: "extra set of clothes", qty: 1, from: ["buckskin-clothing", "traveling-clothes", "dress-clothing"] }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "small-sack", qty: 2 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "saddlebags", qty: 1 }
  - { item_id: "bedroll", qty: 1 }
  - { choose: 1, label: "canteen or waterskin", qty: 1, from: ["canteen", "water-skin"] }
  - { item_id: "animal-snare", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { item_id: "knife", qty: 2 }
  - { item_id: "riding-horse", qty: 1 }
restrictions:
  - "Must be of Native American descent: printed 43 says other races lack the spirit potential for totems or fetishes."
  - "Characters who are not devoted Traditionalists or Pure Ones receive none of the starting fetishes."
  - "Technical related skills are limited to art, language and lore skills."
  - "Cybernetics: none, and will never consider any, with the possible exception of bio-systems to repair grievous injury."
extraction_notes: "Rifts World Book 15: Spirit West printed 42-44, read from the text layer. No hit point or S.D.C. formula is printed, so compose.js supplies both (3D6 S.D.C. as a man of arms); the book then converts the combined S.D.C. and hit points into M.D.C., which mdc_from_hp_sdc: true does: both are rolled as usual and stored as one M.D.C. maximum (BOOK-INGEST-AUDIT F62). P.P.E. prints as !D4xlO+P.E., the digit substitution of BOOK-INGEST-AUDIT F53, read as 1D4x10; the trade goods read as 3D6x100. Psionics: the book states no tier; minor is stored because the class gains one Sensitive power at levels 1, 3, 6, 9, 12 and 15 and no more, never Astral Projection or Clairvoyance. The major starting fetish is any hunting or combat one, typically a damage fetish; the list offered is that reading of the book''s phrase, with the Supernatural Damage Fetish first. The Medical line carries the +10% the book prints against Holistic Medicine, on a second Medical entry limited to that skill. The Domestic line loses its +10%, printed against Sing, because this catalog files Sing under Communications, which the class does not grant; that is under-granted and said so on the line rather than over-granted. The totem pick is the class''s totem key with powers: true, so the sheet shows the chosen animal''s Totem Warrior powers (BOOK-INGEST-AUDIT.md F56). Equipment with no Rifts row stays in the body."
---

# Totem Warrior

**Alignments.** Any, but selfish alignments are the rarest.

Unlike a Shaman, who shares his spirit potential with the spirits, the Totem
Warrior permanently trades a small part of his own for a part of a Greater Totem
Spirit''s life essence - always the spirit of his chosen totem animal. It makes
him more than human: a supernatural being in human form who can take the shape
of his totem, without losing his own mind or will. Some non-Indians call the
class Indian Knights.

The most free-roaming of the Native American O.C.C.s, Totem Warriors range from
Mexico to Alaska, fighting vampires, Xiticix, dragons, demons and evil sorcerers,
and are the most likely of all to be guided by visions from their Totem Spirits.

## Fetishes

Totem Warriors start with one minor fetish of choice and one major hunting or
combat fetish, typically a damage fetish. Further minor fetishes are typically
awarded at levels 3, 6 and 10, a second major one at level 6, and another for
great heroism no sooner than level 9.

## Lore

Totem Warriors remain mostly male (printed 37). Printed 84 sets the limit on
what they trade: no more than three-quarters of a person''s spirit potential can
ever be replaced by another spirit''s, and the Totem and Spirit Warriors stand
close to that line. Past it, the book says, a person becomes a mindless and evil
fusion of man and spirit - which is where some of its monsters come from.

## Equipment the catalog cannot hold yet

A pair of tomahawks or knives, a spear or bow and arrows, a war club, soft
moccasins, a hat or hooded cloak, 50 feet of rope, a week of dried meat and
fruit, and war and camouflage paint. Weapons are few, since the warrior can
become a supernatural animal.
',
       updated_at = datetime('now')
 WHERE class_id = 'totem-warrior'
   AND instr(markdown, 'which a category bonus cannot express') > 0
   AND length(markdown) = 11069;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 14 classes carry their new text' AS assertion, count(*) AS got, 14 AS want
  FROM imported_classes
 WHERE (class_id = 'condoroid' AND instr(markdown, 'which the second Medical entry applies') > 0)
    OR (class_id = 'falconoid' AND instr(markdown, 'which the second Medical entry applies') > 0)
    OR (class_id = 'apok' AND instr(markdown, 'so nothing is rolled by hand') > 0)
    OR (class_id = 'gypsy-enforcer' AND instr(markdown, 'and are stored as dice in bonuses, which the sheet rolls') > 0)
    OR (class_id = 'gypsy-thief-russian' AND instr(markdown, 'Two bonuses are ROLLED and are stored as dice in bonuses') > 0)
    OR (class_id = 'hidden-witch' AND instr(markdown, 'is likewise rolled, and is a dice entry in bonuses') > 0)
    OR (class_id = 'gypsy-thief' AND instr(markdown, 'The +15% the Technical line prints for languages IS stored') > 0)
    OR (class_id = 'lyvorrk' AND instr(markdown, 'It was left out at import, per that import''s brief, and an xp_table is stored now.') > 0)
    OR (class_id = 'malvoren' AND instr(markdown, 'It was left out at import, per that import''s brief, and an xp_table is stored now.') > 0)
    OR (class_id = 'mraghiile-tree-man' AND instr(markdown, 'It was left out at import, per that import''s brief, and an xp_table is stored now.') > 0)
    OR (class_id = 'obsedai' AND instr(markdown, 'It was left out at import, per that import''s brief, and an xp_table is stored now.') > 0)
    OR (class_id = 'ngr-robot-soldier' AND instr(markdown, 'Stored: the class''s skill_programs block picks three') > 0)
    OR (class_id = 'slayer-russian' AND instr(markdown, '+4 to save vs disease is stored in bonuses as saves.disease') > 0)
    OR (class_id = 'totem-warrior' AND instr(markdown, 'on a second Medical entry limited to that skill') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'condoroid' AND instr(markdown, 'Paramedic only: add it to that skill by hand') > 0)
    OR (class_id = 'falconoid' AND instr(markdown, 'Paramedic only: add it to that skill by hand') > 0)
    OR (class_id = 'apok' AND instr(markdown, 'ability and rolled by hand, which is the same rule') > 0)
    OR (class_id = 'gypsy-enforcer' AND instr(markdown, 'Three attribute bonuses are ROLLED and are prose') > 0)
    OR (class_id = 'gypsy-thief-russian' AND instr(markdown, 'Two bonuses are ROLLED and are prose') > 0)
    OR (class_id = 'hidden-witch' AND instr(markdown, 'is likewise rolled and is prose rather than a bonuses line') > 0)
    OR (class_id = 'gypsy-thief' AND instr(markdown, 'The +15% the Technical line prints for languages is not stored') > 0)
    OR (class_id = 'lyvorrk' AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0)
    OR (class_id = 'malvoren' AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0)
    OR (class_id = 'mraghiile-tree-man' AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0)
    OR (class_id = 'obsedai' AND instr(markdown, 'Not stored, per this import''s brief (no xp_table for this book)') > 0)
    OR (class_id = 'ngr-robot-soldier' AND instr(markdown, 'Not stored: the app picks skills from categories, not categories wholesale') > 0)
    OR (class_id = 'slayer-russian' AND instr(markdown, '+4 to save vs disease has no field and is prose') > 0)
    OR (class_id = 'totem-warrior' AND instr(markdown, 'which a category bonus cannot express') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('condoroid', 'falconoid', 'apok', 'gypsy-enforcer', 'gypsy-thief-russian', 'hidden-witch', 'gypsy-thief', 'lyvorrk', 'malvoren', 'mraghiile-tree-man', 'obsedai', 'ngr-robot-soldier', 'slayer-russian', 'totem-warrior') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~170-closeout-claim-sweep-part-1.sql');
