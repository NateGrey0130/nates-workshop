-- Thirteen classes' own psionics tables replace the standard Random Psionics roll
-- 13 classes, each replaced whole: dolphin, killer-whale, pneuma-biform-dolphin, pneuma-biform-killer-whale, nautyll-soldier, humpback-whale, amaki-stone-man, arkhon, larmac, mutant-rat, momano-headhunter, outback-mutie, phreaker-military-grunt.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~163-own-psionics-tables-replace-the-standard-roll.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C5: psionics_allowed: false on every class whose own
-- psionics table stands in place of the standard Random Psionics roll
-- (BOOK-INGEST-AUDIT F118). Until now a character who rolled "None" on the
-- class's own table was still offered the standard roll.
--
-- Each page was read off a render for exactly this question, and each class's
-- bands were checked against the page while it was open: no band disagreed.
--
--   The page's own psionics line or table, with its own "none" result:
--     dolphin, killer-whale (Underseas printed 80, 88), larmac (D-Bees printed
--     120), amaki-stone-man (South America 2 printed 155), momano-headhunter
--     (Canada printed 124).
--   The same, with the "none" remainder implied rather than printed:
--     nautyll-soldier (Underseas printed 149), arkhon (South America 2 printed
--     72), mutant-rat (Lone Star printed 88).
--   By reference to another class's table:
--     pneuma-biform-dolphin, pneuma-biform-killer-whale (Underseas printed 52,
--     54: "same as the normal" animal).
--   A table on which every result is psionic:
--     humpback-whale (Underseas printed 92).
--   A READING, not a printed rule:
--     outback-mutie, phreaker-military-grunt (Australia printed 128-132). The
--     pages print no Psionics line for a mutant and never mention the standard
--     roll; the Special Mutant Powers table is the only mechanism given. Each
--     class's note says this is a reading.
--
-- Not flagged, by Nate's word of 2026-10-04: operator, demigod, norse-giant,
-- hu-aliens. Not flagged because the pages are silent: phase-world-alien.
--
-- Nothing else in any of the thirteen changes: the flag, and one note.

-- == dolphin ==
UPDATE imported_classes
   SET markdown = '---
id: dolphin
name: Dolphin
system: rifts
source_book: Rifts World Book 7: Underseas p.77-80
category: rcc
psionics_allowed: false
tags: [aquatic]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_dice:
  IQ: "2d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "4d6+6"
  PP: "3d6+10"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "2d6+45"
hit_points_base: "P.E. + 6d6, +1d6 per level"
sdc_base: "2d4x10"
ppe_base: "P.E. + 2d4x10, +1d6 per level"
bonuses:
  combat: { attacks_base: 2, initiative: 3, strike: 2, dodge: 2, pull_punch: 2, roll: 2 }
  saves: { horror_factor: 4, disease: 1, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 4, combat: { attacks: 1 } }
    - { level: 6, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    dolphin:
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
  spells_starting_groups:
    - { count: 2, from_list: "dolphin" }
  spells_schedule:
    - { level: 2, count: 1, from_list: "dolphin" }
    - { level: 4, count: 1, from_list: "dolphin" }
    - { level: 6, count: 1, from_list: "dolphin" }
    - { level: 8, count: 1, from_list: "dolphin" }
    - { level: 10, count: 1, from_list: "dolphin" }
    - { level: 12, count: 1, from_list: "dolphin" }
    - { level: 14, count: 1, from_list: "dolphin" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 55, per_level: 5, note: "+20%" }
    - { name: "Navigation: Underwater", base: 40, per_level: 4, note: "Printed as Underwater Navigation (+10%)." }
    - { name: "Undersea & Sea Survival", base: 25, per_level: 5, note: "Printed as Undersea Survival, with no bonus - the one cetacean entry that prints none." }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One human language of choice (+20%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 2 }, { level: 7, count: 2 }, { level: 11, count: 2 }, { level: 15, count: 2 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Escape Artist", "Intelligence", "Pick Pockets"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 45% scrupulous, 25% principled, 15% unprincipled, 10% anarchist and 5% other. Diabolic and miscreant dolphins are uncommon."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one - unlike almost everything else imported from this book. It becomes mega-damage only while ley line charged."
  - "Horror Factor: NONE. The dolphin is the one cetacean in this chapter with no horror factor at all."
  - "Size: 5 to 7 feet (1.5 to 2.1 m) for most; 6 to 8 feet (1.8 to 2.4 m) for the bottle-nosed dolphin and pygmy killer whale; 8 to 20 feet (2.4 to 6.1 m) for most other toothed whales in the dolphin family. Weight 150 to 300 lbs (67.5 to 135 kg), plus 100 lbs for the bottle-nose and pygmy killer whale, which also gets +10 S.D.C."
  - "Average life span: 50 to 100 years. Dolphins are found world wide."
  - "Speed 2D6+45 is the SPRINT, roughly 32 to 38 mph. A cruising dolphin holds 25 to 30 mph for an hour or two, covering 150 to 250 miles a day - up to 350 if pushed to exhaustion, which then halves speed and range for following days until it rests a day or two."
  - "Spell strength - the number others must save against - is +1 at levels three, seven and eleven. The dolphin is also +2 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "A DOLPHIN THAT DECLINES FURTHER MAGIC IS PAID FOR IT. Printed 80 lets a dolphin learn two ocean magic spells or one whale spellsong at levels three, six, nine and eleven; one that chooses not to - and many do not - instead gains +1D4x10 S.D.C., +1 on initiative, +1 to strike and dodge, +1 to pull punch and roll with impact, and +1D6 to Spd. Neither branch is stored; the dolphin-magic ladder is."
  - "Porpoises are not dolphins here: they start with two attacks, get half the sonic-stun range, and cannot cast dolphin magic at all."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none, though some humans and D-bees experiment on dolphins with implants and bionics."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Dolphin Psionics (printed 80): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Healing or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Healing", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Automatic Dodge"
    description: "Dodges without using up a melee action - the only cetacean in this chapter that can."
  - name: "Sonic Stun"
    description: "An S.D.C. sonic attack doing 2D6 S.D.C. underwater or 1D4 in air, with a 1-60% chance of knocking the victim out for 1D4 melee rounds. A victim who stays conscious but fails to save has a splitting headache and is disoriented: -6 on initiative, -6 to strike, parry and dodge, speed, attacks and skill performance halved, and no sense of direction, depth or which way is up, for 1D4 melee rounds. The saving throw scales with the target: small fish need 19 or better, man-sized fish and sharks 10, humans and most intelligent life 3. Other cetaceans are impervious, as are dragons, giants, creatures of magic, supernatural beings and most mega-damage creatures. It does not damage or penetrate mega-damage armour, vehicles or structures. Only dolphins and porpoises have it."
  - name: "Dolphin Combat"
    description: "Two attacks per melee round at level one, and one more at levels two, four, six, ten and fourteen. A warning nip does 1 S.D.C. and a full bite 1D4; a nose jab 1D4; a head or nose strike 1D4 restrained or 2D4 at full strength; a power strike 3D6 with a 70% chance of costing the victim initiative and one action, counting as two attacks; a tail slap 1D6. Parries with nose or tail."
  - name: "Dive"
    description: "A high-speed dive at double normal speed, to 500 feet (152 m) plus 100 feet (30.5 m) per level."
  - name: "Mid-Air Leap and Precision Leaping"
    description: "Leaps six feet (1.8 m) plus one foot (0.3 m) per level out of the water, to show off or to grab or knock an item from a hand at +2 to strike. The precision leap counts as three melee actions. Also somersaults, breaches, swims backwards and does backward flips."
  - name: "Quick Turns & Stops"
    description: "Rolled as an automatic dodge or parry; 14 or higher succeeds. A failed roll means it could not stop in time and takes 2D6 impact damage."
  - name: "Speed Burst"
    description: "Double speed for one minute, six times an hour. Used for a quick dodge at +2, a quick strike at +1, or to close or break away. Conditional, so not in the stored bonuses."
  - name: "Tight Circle & Turn"
    description: "Turns within an area as small as 12 feet (3.65 m) across."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 77-80. The first of four cetacean R.C.C.s in this
    chapter, and the only one of the four that is not a whale.
  - IT IS AN S.D.C. CREATURE. Every other class imported from this book so far
    is mega-damage; this one has hit points and S.D.C. and becomes
    mega-damage only while ley line charged. `hit_points_base` and `sdc_base`
    are both used, and `mdc_base` is deliberately absent.
  - THE BOOK SPELLS ONE OF ITS OWN SPELLS THREE WAYS. Printed 70''s
    alphabetical list says Electromagnetic Pulse, the description heading on
    the same page says Electro-Magnetic Pulse, and this class''s own list on
    printed 80 says Electromagnetic BLAST. The spell chapter''s alphabetical
    list is the authority for membership, so the catalog row is
    `Dolphin: Electromagnetic Pulse` and all three readings are recorded -
    here and on the spell row''s `variant_note`.
  - THREE RELATED-SKILL LINES REACH ACROSS THE CATALOG''S FILING, and each
    needed checking rather than transcribing:
      * The book grants SING under Domestic; the catalog files Sing under
        Communications. It is named in the Communications entry so it is
        actually takeable - an `only` naming a skill whose real category the
        class does not grant is unreachable.
      * The Technical line is language, lores and underwater skills only,
        which is a PREFIX restriction rather than a name list.
        `only_prefix: [Language, Lore]` covers 21 language rows and the lore
        family without enumerating either, and `only` adds the two underwater
        Technical rows this book itself created.
      * The -10% the book prints on the Communications line applies to Radio:
        Basic alone. It is NOT stored as a category bonus, because a category
        bonus would apply it to Sing as well.
  - THE ROGUE `except` DROPS ONE OF THE BOOK''S TWO NAMES. Printed 77 bars
    computer hacking and pick locks; the catalog files Pick Locks under
    Espionage, whose `only` list here does not include it, so it is already
    unreachable and an `except` naming it would exclude nothing. Only
    Computer Hacking is stored.
  - THE ''DECLINE MAGIC FOR BONUSES'' BRANCH IS NOT MODELLED. Printed 80 offers
    a dolphin extra S.D.C., speed and five combat bonuses in exchange for
    never learning ocean magic or spellsongs. That is a character-creation
    either/or across two unrelated blocks, and nothing here can express it.
    The magic ladder is stored and the alternative is a restriction line.
  - PSIONICS ARE A PERCENTILE ROLL, printed 80, and were not stored at all until
    2026-10: 77% have none, so there is no class-level block. The roll is a
    choose-1 special ability with four options named for their bands, each
    psychic option carrying its own tier and picks. The counts are printed as
    dice (1D4+1, 1D4+3) and are stored at the maximum with the roll in the
    pick''s note, the Demon and Dead Slaver precedent. The master''s "one psionic
    category" has no printed count and is left to the description. No I.S.P.
    formula is printed for any tier, so none is stored.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 80 heads its own section Dolphin Psionics (Special), says to roll on that table and prints its own no-psionic-powers result at 01-77; nothing sends the reader to the standard rule.
---

# Dolphin

## Lore

Playing a dolphin can be a blast. There is something magical about a creature so alien and so familiar at once, and the character is at its best when the player plays it in character - a different view of life, thinking in pictures rather than words, high morals, innocence, and broken speech.

Dolphins are natural ley line walkers with some abilities a ley line walker does not have. They can charge themselves on a line until they glow blue and turn temporarily mega-damage, fire mystic bolts, and hop between neighbouring lines through a Rift of their own making.

They are also the only cetaceans besides porpoises with the sonic stun - a blast that scales its effect to the size of what it hits, and that other cetaceans are entirely immune to.

## GM Notes

Do not forget that through advanced technology and magic, dolphins and other sea creatures can travel and survive on dry land for short periods, and for long ones where water and the right magic are constantly available.

A dolphin out of water is helpless - it can only flop and squirm - and it is on a clock: about fifteen minutes before the skin dries and it weakens, dead in half an hour or so unless it is sprinkled or immersed.

Many dolphins decline to learn any magic beyond their own. The book pays them for it in raw physical bonuses, which is worth knowing before a player picks.
',
       updated_at = datetime('now')
 WHERE class_id = 'dolphin'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 19936;

-- == killer-whale ==
UPDATE imported_classes
   SET markdown = '---
id: killer-whale
name: Killer Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.85-88
category: rcc
psionics_allowed: false
tags: [aquatic]
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 365001]
attribute_dice:
  IQ: "2d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "4d6+6"
  PP: "3d6+10"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "2d6+14"
hit_points_base: "P.E. + 1d4x10, +10 per level"
sdc_base: "2d6x10"
ppe_base: "P.E. + 1d6x10, +2d6 per level"
bonuses:
  combat: { attacks_base: 3, initiative: 2, strike: 3, dodge: 1, pull_punch: 3, roll: 1 }
  saves: { horror_factor: 6, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 7, combat: { attacks: 1 } }
    - { level: 10, combat: { attacks: 1 } }
    - { level: 13, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    any_magic:
      - "Ocean: Abilities of a Snail"
      - "Ocean: Air Swim"
      - "Ocean: Armor of Neptune"
      - "Ocean: Black Water"
      - "Ocean: Breathe Air"
      - "Ocean: Calm Waters"
      - "Ocean: Change Current"
      - "Ocean: Communicate with Sea Creature"
      - "Ocean: Coral Armor"
      - "Ocean: Float Underwater"
      - "Ocean: Float on Water"
      - "Ocean: Flying Fish"
      - "Ocean: Grow Tentacles"
      - "Ocean: Healing Waters"
      - "Ocean: Impervious to Cold"
      - "Ocean: Impervious to Electricity"
      - "Ocean: Impervious to Ocean Depths"
      - "Ocean: Metamorphosis Crustacean"
      - "Ocean: Metamorphosis Fish"
      - "Ocean: Metamorphosis Shark"
      - "Ocean: Mystic Sea Horse"
      - "Ocean: Ride the Waves"
      - "Ocean: Sense Direction Underwater"
      - "Ocean: Senses of the Shark"
      - "Ocean: Sonar Hearing"
      - "Ocean: Sound Sponge"
      - "Ocean: Speak Underwater"
      - "Ocean: Strength of the Whale"
      - "Ocean: Summon Sea Friend"
      - "Ocean: Transmute Water"
      - "Ocean: Travel Above Water"
      - "Ocean: Walk Like a Humanoid"
      - "Ocean: Water Envelope"
      - "Ocean: Water Nourishment"
      - "Ocean: Water Pulse"
      - "Ocean: Water Rush"
      - "Ocean: Water Seal"
      - "Ocean: Water Spout"
      - "Ocean: Water Wall"
      - "Ocean: Weed Snare"
      - "Ocean: Whirlpool"
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 2, from_list: "any_magic", note: "Ocean magic, dolphin magic or whale spellsongs in any combination - the book offers all three from one pool." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "any_magic" }
    - { level: 4, count: 1, from_list: "any_magic" }
    - { level: 6, count: 1, from_list: "any_magic" }
    - { level: 8, count: 1, from_list: "any_magic" }
    - { level: 10, count: 1, from_list: "any_magic" }
    - { level: 12, count: 1, from_list: "any_magic" }
    - { level: 14, count: 1, from_list: "any_magic" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 55, per_level: 5, note: "+20%" }
    - { name: "Navigation: Underwater", base: 40, per_level: 4, note: "Printed as Underwater Navigation (+10%)." }
    - { name: "Undersea & Sea Survival", base: 35, per_level: 5, note: "Printed as Undersea Survival (+10%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One human language of choice (+15%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Medical", only: ["Sea Holistic Medicine"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 1 }, { level: 7, count: 1 }, { level: 12, count: 1 }, { level: 14, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 45% scrupulous, 25% principled, 15% unprincipled, 10% anarchist and 5% other. Diabolic and miscreant orca are uncommon."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 1D4+3."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. plus 1D4x10 for females and young, and P.E. plus 4D4x10 for a full-grown male, +10 per level either way. S.D.C. is 2D6x10 for females and young, 4D6x10 for a full-grown male. A full-grown male character should use the larger of each."
  - "Horror Factor: 14 when angry or attacking. The stored save bonus is +6; the horror factor itself is a number others save against."
  - "Size: males average 25 to 33 feet (7.6 to 10 m), females 14 to 21 feet (4.2 to 6.4 m). The upright angular fin is 5 to 7 feet (1.5 to 2.1 m) tall, larger than any other whale''s. Weight 2 to 5 tons; the male is about twice the size of the female."
  - "Average life span: 60 to 100 years, maturity at 8 to 12. There are an estimated 11 million on Rifts Earth."
  - "Spell strength is +1 at levels four, eight and twelve. The orca is +3 to save against whale spellsongs specifically, on top of +1 against magic generally."
  - "NO AUTOMATIC DODGE, unlike the dolphin."
  - "The killer whale is the ONLY cetacean that preys on warm-blooded animals. It hunts dolphins, porpoises, seals, sea lions, penguins and sea birds as well as fish and squid, and a hunting pair or pod occasionally takes baleen, beluga, narwhal and grey whales. It never feeds on other orca."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Killer Whale Psionics (printed 88): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Orca Combat"
    description: "Three attacks per melee round at level one, and one more at levels two, five, seven, ten and thirteen. Parries with nose or tail. NO automatic dodge."
  - name: "Dive"
    description: "A high-speed dive at double normal speed, to 800 feet (182 m) plus 100 feet (30.5 m) per level, at +2 to strike on a diving attack."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 85-88. An S.D.C. creature like the dolphin, and the
    largest species in the dolphin family - the book files it as its own
    R.C.C. rather than as a dolphin variant.
  - ITS MAGIC IS THE WIDEST OF THE FOUR CETACEANS and is stored as a single
    merged pool. Printed 88 lets the orca learn ocean magic, dolphin magic or
    whale spellsongs IN ANY COMBINATION, which is one pool of 72 rather than
    three lists with separate counts - so `any_magic` is the union, and that
    is the honest reading of the sentence rather than a convenience.
  - HIT POINTS AND S.D.C. EACH HAVE A FEMALE/YOUNG FIGURE AND A FULL-GROWN
    MALE FIGURE, and the smaller is stored, consistently across all three
    whales in this batch. Both are in the restrictions. A single column
    cannot hold a sex-and-age branch, and storing the larger would over-roll
    every young or female character.
  - SEE THE DOLPHIN''S NOTES for the three related-skill lines that reach
    across the catalog''s filing - Sing, the Technical prefix restriction, and
    why the -10% is not a category bonus. All four cetaceans share them.
  - ITS ESPIONAGE LIST IS SHORTER THAN THE DOLPHIN''S: no escape artist and no
    pick pockets. Transcribed as printed.
  - PSIONICS ARE A PERCENTILE ROLL, printed 88, and were not stored at all until
    2026-10: 77% have none, so there is no class-level block. The roll is a
    choose-1 special ability with four options named for their bands, each
    psychic option carrying its own tier and picks. The counts are printed as
    dice (1D4+1, 1D4+3) and are stored at the maximum with the roll in the
    pick''s note, the Demon and Dead Slaver precedent. The master''s "one psionic
    category" has no printed count and is left to the description. No I.S.P.
    formula is printed for any tier, so none is stored.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 88 heads its own section Killer Whale Psionics (Special), says to roll on that table and prints its own no-psionic-powers result at 01-77; nothing sends the reader to the standard rule.
---

# Killer Whale

## Lore

With hundreds of years and no commercial whaling behind it, the killer whale has regained its place as a power in the oceans of Rifts Earth. It does not prey on humans, but it is aloof and suspicious of them - until it befriends one, at which point it gives that person the same loyalty, playfulness and affection it gives its own kind, and its pod is likely to follow suit.

It extends the same friendship to D-bees and mutants that are very human-like: sea titans, True Atlanteans, psi-stalkers, kittani, changelings, ogres, elves, dwarves, dog boys, wolfen, simvan and Lemurians.

Aquatic humanoids are another matter. Orcas view amphibs and most aquatic D-bees with suspicion and animosity, and while no killer whale has ever slain a human, they regularly bite and kill aquatic humanoids, D-bees, aliens and mutants. Naut''yll, horune, gene-splicers and their mutants, sea monsters, minions of the Lord of the Deep and demons are treated as natural prey and attacked without provocation.

## GM Notes

Among their own kind orcas are intelligent, compassionate and gentle, much like their smaller dolphin cousins - protecting the young and sick, working in groups, showing affection, and seldom fighting each other.

A typical pod runs 50 to 300 members and usually stays together for life. A pod that outgrows that splits into two or three groups of 8 to 50, which grow into pods themselves. Family ties survive the split and pass down the generations: an orca can recognise immediate family, its own pod, other pods, rogues and even relatives it has never met, from the accent of a pod''s language and from physical marks.

The killer whale is the only cetacean that preys on warm-blooded animals. A settled orca''s hunting range spans 200 to 600 miles.
',
       updated_at = datetime('now')
 WHERE class_id = 'killer-whale'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 19085;

-- == pneuma-biform-dolphin ==
UPDATE imported_classes
   SET markdown = '---
id: pneuma-biform-dolphin
name: Pneuma-Biform Dolphin
system: rifts
source_book: Rifts World Book 7: Underseas p.51-53
category: rcc
psionics_allowed: false
tags: [supernatural, shapeshifter, aquatic]
xp_table: [0, 2601, 5301, 10701, 20601, 30601, 41801, 61001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]
attribute_dice:
  IQ: "3d6+3"
  ME: "3d6+10"
  MA: "3d6+6"
  PS: "4d6+6"
  PP: "3d6+6"
  PE: "3d6+6"
  PB: "3d6+6"
  Spd: "3d6+6"
mdc_base: "2d6x10"
ppe_base: "3d6x10"
ignores_style_attacks: true
bonuses:
  combat: { attacks_base: 3, initiative: 2, dodge: 1 }
  saves: { horror_factor: 6, disease: 4, illusionary_magic: 4, mind_control: 4 }
magic:
  type: "spell"
  spell_lists:
    spellsongs:
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
    ocean:
      - "Ocean: Abilities of a Snail"
      - "Ocean: Air Swim"
      - "Ocean: Armor of Neptune"
      - "Ocean: Black Water"
      - "Ocean: Breathe Air"
      - "Ocean: Calm Waters"
      - "Ocean: Change Current"
      - "Ocean: Communicate with Sea Creature"
      - "Ocean: Coral Armor"
      - "Ocean: Float Underwater"
      - "Ocean: Float on Water"
      - "Ocean: Flying Fish"
      - "Ocean: Grow Tentacles"
      - "Ocean: Healing Waters"
      - "Ocean: Impervious to Cold"
      - "Ocean: Impervious to Electricity"
      - "Ocean: Impervious to Ocean Depths"
      - "Ocean: Metamorphosis Crustacean"
      - "Ocean: Metamorphosis Fish"
      - "Ocean: Metamorphosis Shark"
      - "Ocean: Mystic Sea Horse"
      - "Ocean: Ride the Waves"
      - "Ocean: Sense Direction Underwater"
      - "Ocean: Senses of the Shark"
      - "Ocean: Sonar Hearing"
      - "Ocean: Sound Sponge"
      - "Ocean: Speak Underwater"
      - "Ocean: Strength of the Whale"
      - "Ocean: Summon Sea Friend"
      - "Ocean: Transmute Water"
      - "Ocean: Travel Above Water"
      - "Ocean: Walk Like a Humanoid"
      - "Ocean: Water Envelope"
      - "Ocean: Water Nourishment"
      - "Ocean: Water Pulse"
      - "Ocean: Water Rush"
      - "Ocean: Water Seal"
      - "Ocean: Water Spout"
      - "Ocean: Water Wall"
      - "Ocean: Weed Snare"
      - "Ocean: Whirlpool"
    dolphin:
      - "Dolphin: Air Doubler"
      - "Dolphin: Electromagnetic Pulse"
      - "Dolphin: Psi-Flash Warning"
      - "Dolphin: Ride Ley Lines"
      - "Dolphin: Sense Food"
      - "Dolphin: Sense Predator"
      - "Dolphin: Sense Weather"
      - "Dolphin: Sonic Blast"
      - "Dolphin: Sonic Stun"
      - "Dolphin: Speed Doubler"
  spells_starting_groups:
    - { count: 1, from_list: "ocean" }
    - { count: 10, from_list: "dolphin", note: "The PB-dolphin has ALL dolphin magic, not a choice from it - printed 52 item 3. Listed as a group of ten so the ten rows land on the sheet." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "ocean" }
    - { level: 3, count: 1, from_list: "ocean" }
    - { level: 4, count: 1, from_list: "ocean" }
    - { level: 5, count: 1, from_list: "ocean" }
    - { level: 6, count: 1, from_list: "ocean" }
    - { level: 7, count: 1, from_list: "ocean" }
    - { level: 8, count: 1, from_list: "ocean" }
    - { level: 9, count: 1, from_list: "ocean" }
    - { level: 10, count: 1, from_list: "ocean" }
    - { level: 11, count: 1, from_list: "ocean" }
    - { level: 12, count: 1, from_list: "ocean" }
    - { level: 13, count: 1, from_list: "ocean" }
    - { level: 14, count: 1, from_list: "ocean" }
    - { level: 15, count: 1, from_list: "ocean" }
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 4, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 9, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 11, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 13, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
    - { level: 15, count: 1, from_list: "spellsongs" }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2 } }
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Language: Dolphin/Whale", base: 98, per_level: 0, note: "Printed as Dolphin/Whale Language 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "One human language at 98%." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Two other languages (+15%). Taken once per language - the picker asks which." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "Printed as Demon and Monster Lore (+15%)." }
    - { name: "Track & Hunt Sea Animals", base: 45, per_level: 5, note: "+10%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Sing", base: 50, per_level: 5, note: "+15%" }
    - { name: "Acrobatics", base: 30, per_level: 5 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One W.P. of choice, applicable when human." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Applicable when human. Can be raised to expert for one other skill selection, or to martial arts for two." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", except: ["Forgery", "Sniper"] }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5 }
      - "Physical"
      - "Pilot Related"
      - "Rogue"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical, Military, Pilot and Science are barred entirely. All new skills start at level one proficiency."
  secondary_skills:
    count: 5
    note: "Chosen from the same categories as the related skills, excluding those the book marks None, and without the bonuses in parentheses."
restrictions:
  - "Alignment: 70% are scrupulous or unprincipled; the rest tend to principled, anarchist or aberrant. Diabolic or miscreant PB-dolphins are almost unknown."
  - "Size: 6 to 7.5 feet (1.8 to 2.25 m) in combat form. In swimming form it is about 20% larger than an average dolphin."
  - "Average life span: at least 400 years. No pneuma-biform has yet died of old age."
  - "STRENGTH AND ENDURANCE ARE SUPERNATURAL, so punches do mega-damage in either form."
  - "Horror Factor: 10, and ONLY in combat form."
  - "Speed is the HUMAN form speed of 3D6+6. Underwater it is 1D4x10+60 in dolphin form and 1D4x10+20 in dolphin combat form."
  - "M.D.C. gains 2D6 per level of experience and P.P.E. gains 3D6 per level, on top of the bases stored here."
  - "Spell strength - the number others must save against - is +1 at levels three, seven and eleven."
  - "DO NOT ADD THE HAND TO HAND SKILL''S ATTACKS PER MELEE. The stored 3 is the dolphin form''s; human form gets 4, and either form gets 2 more via magic or psionics. Hand to hand supplies bonuses and techniques only."
  - "Psionics are the normal dolphin''s, which printed 80 gives as a percentile roll rather than a grant: 77% have none, 11% are minor, 9% major and 3% master. The roll is the pick-one Psionics group under special abilities, the normal dolphin''s own."
  - "Cybernetics: never."
  - "In its cetacean form the character dehydrates quickly out of water. Every hour on dry land without soaking, it loses 4D6 M.D.C. and cannot heal or regenerate until it has soaked for six hours; after five hours without water it becomes weak, halving attacks per melee round and all combat bonuses. In human form it is uncomfortable away from water, because it needs to immerse itself to change back."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Dolphin Psionics (printed 80): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Healing or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Healing", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic dolphin also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Metamorphosis: Human"
    description: "The normal form is a dolphin; it can become an attractive light-skinned human of its own gender twice per 24 hours, for one hour per level of experience. The appearance is always the same - it cannot assume another guise, age or gender. As a human it gains articulated hands, survives on land without dehydrating, walks, runs, climbs and speaks in a deep clear voice - and LOSES the dolphin''s physical and natural abilities, including its sonic abilities, electromagnetic sensitivity, dolphin magic and ley line abilities. Swimming speed equals running speed, breath holds only 1D4+2 minutes, and depth tolerance drops to 300 feet. Spellsongs are retained at half range; ocean magic works normally."
  - name: "Metamorphosis: Combat Form"
    description: "Size increases by one foot and the skin turns hard, grey and metallic like polished chrome. +10 M.D.C. per level of experience, +6 M.D. on every physical attack, +1 attack per melee round, +1 on initiative, +1 to strike, +1 to roll with impact, +2 to pull punch, and a horror factor of 10. Usable from dolphin or human form, for 30 minutes per level, three times per 24 hours. These bonuses are conditional and are NOT in the stored block."
  - name: "Mystic Regeneration"
    description: "Regenerates 1D4x10 M.D.C. per minute."
  - name: "Deep Endurance"
    description: "Maximum depth endurance is four miles (6.4 km), against one mile for a normal dolphin."
  - name: "Human Intelligence"
    description: "Human intelligence, resourcefulness and communication. The voice is high-pitched and guttural as a dolphin, deep and clear in human form."
  - name: "Impervious to Cold"
    description: "Takes no damage from cold."
  - name: "Permanent Fusion"
    description: "The character stays a pneuma-biform even if the Lord of the Deep is slain, and 88% want to. A character who chooses to become a normal human or dolphin again can never have the fusion restored."
extraction_notes: |
  - Underseas, printed 51-53. The first of the three Pneuma-Biform R.C.C.s -
    humans and cetaceans magically fused by the Lord of the Deep, who then
    rebelled against it. All three share a stat-block shape and differ in
    numbers; each is imported separately because the book prints three
    entries.
  - ALL TEN DOLPHIN SPELLS ARE GRANTED, NOT CHOSEN. Printed 52 item 3 says
    the character possesses dolphin magic outright. It is written as a
    starting group of ten drawn from a ten-name list, which is a grant
    expressed through the picker, because `spells` grants by name and a
    starting group is what puts them on the sheet as picks the player sees.
  - THE MAGIC LADDER IS TWO LADDERS AT ONCE and the schedule carries both.
    Printed 52 gives one ocean spell per level of experience and one whale
    spellsong per level STARTING AT THIRD. Entries are matched by level and
    slot, so levels three and up carry one of each. The level-1 ocean pick is
    a `spells_starting_groups` entry rather than a schedule entry, because a
    level-1 schedule entry does not fire at creation.
  - ATTACKS ARE THE DOLPHIN FORM''S. The book gives four in human form and
    three in dolphin form, and the dolphin is the normal form, so 3 is
    stored. Both figures and the two magic/psionic attacks are in the
    restrictions.
  - NO CLASS-LEVEL PSIONICS BLOCK. The entry says psionic powers are the
    normal dolphin''s, and printed 80 makes those a percentile roll where 77%
    have none. Since ~114 the roll is a pick-one group of four banded
    options, copied from the dolphin class as ~090 gave it; each psychic
    option carries its own block, and the None option carries nothing.
    psionics_allowed is not set, as it is not on the dolphin class: whether
    the table replaces the standard roll is a page read left to close-out
    package C5, which takes both classes together.
  - SPEED IS THE HUMAN FORM''S, which is the only one `Spd` can hold. The two
    swimming speeds are in the restrictions.
  - THE COMBAT-FORM BONUSES ARE NOT STORED. They are conditional on a
    transformation with a duration and a daily limit, and `bonuses` applies
    unconditionally.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 52 gives psionic powers as the same as the normal dolphin, whose own table (printed 80, with its no-psionic-powers result at 01-77) is the whole rule.
---

# Pneuma-Biform Dolphin

## Lore

Pneuma-biforms are creatures of magic - humans and cetaceans fused by the Lord of the Deep, who then rebelled against their maker and joined the Whale Singers. The dolphin biforms carry attributes and abilities of both halves, plus a good deal that belongs to neither.

They are the quickest and most playful of the three, and the most inclined to walk among humans. Their normal shape is a dolphin about a fifth larger than the ordinary kind; twice a day they can take the shape of an attractive, light-skinned human, always the same one.

Most of them - 88% - like being what they are, and will stay pneuma-biforms whether or not the Lord of the Deep is ever destroyed.

## GM Notes

Besides the Whale Singers, PB-dolphins often team up with normal dolphins and whales, humans, sea titans, amphibs, sea inquisitors and anyone of good alignment or good intentions.

They rely on their natural powers, especially in dolphin form, and may carry one or two weapons and a few personal items for use when they take human shape. A few own magical, techno-wizard or rune weapons. Body armour is usually none, though some wear magically woven kelp armour of 90 M.D.C. made with the Song of Weaving.

Most keep a small cache for walking among men - a weapon or four, a water scooter or surfboard, a set of clothes, some precious metals and gems, and assorted trinkets.
',
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-dolphin'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 16780;

-- == pneuma-biform-killer-whale ==
UPDATE imported_classes
   SET markdown = '---
id: pneuma-biform-killer-whale
name: Pneuma-Biform Killer Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.53-55
category: rcc
psionics_allowed: false
tags: [supernatural, shapeshifter, aquatic]
xp_table: [0, 2601, 5301, 10701, 20601, 30601, 41801, 61001, 90001, 120001, 170001, 220001, 290001, 400001, 500001]
attribute_dice:
  IQ: "3d6+1"
  ME: "4d6+3"
  MA: "3d6+3"
  PS: "5d6+20"
  PP: "3d6+6"
  PE: "4d6+6"
  PB: "3d6+4"
  Spd: "3d6"
mdc_base: "1d4x100"
ppe_base: "2d6x10"
ignores_style_attacks: true
bonuses:
  combat: { attacks_base: 5, initiative: 2, strike: 1, dodge: 1 }
  saves: { horror_factor: 7, disease: 4, illusionary_magic: 3, mind_control: 3 }
magic:
  type: "spell"
  spell_lists:
    spellsongs:
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
    ocean:
      - "Ocean: Abilities of a Snail"
      - "Ocean: Air Swim"
      - "Ocean: Armor of Neptune"
      - "Ocean: Black Water"
      - "Ocean: Breathe Air"
      - "Ocean: Calm Waters"
      - "Ocean: Change Current"
      - "Ocean: Communicate with Sea Creature"
      - "Ocean: Coral Armor"
      - "Ocean: Float Underwater"
      - "Ocean: Float on Water"
      - "Ocean: Flying Fish"
      - "Ocean: Grow Tentacles"
      - "Ocean: Healing Waters"
      - "Ocean: Impervious to Cold"
      - "Ocean: Impervious to Electricity"
      - "Ocean: Impervious to Ocean Depths"
      - "Ocean: Metamorphosis Crustacean"
      - "Ocean: Metamorphosis Fish"
      - "Ocean: Metamorphosis Shark"
      - "Ocean: Mystic Sea Horse"
      - "Ocean: Ride the Waves"
      - "Ocean: Sense Direction Underwater"
      - "Ocean: Senses of the Shark"
      - "Ocean: Sonar Hearing"
      - "Ocean: Sound Sponge"
      - "Ocean: Speak Underwater"
      - "Ocean: Strength of the Whale"
      - "Ocean: Summon Sea Friend"
      - "Ocean: Transmute Water"
      - "Ocean: Travel Above Water"
      - "Ocean: Walk Like a Humanoid"
      - "Ocean: Water Envelope"
      - "Ocean: Water Nourishment"
      - "Ocean: Water Pulse"
      - "Ocean: Water Rush"
      - "Ocean: Water Seal"
      - "Ocean: Water Spout"
      - "Ocean: Water Wall"
      - "Ocean: Weed Snare"
      - "Ocean: Whirlpool"
  spells_starting_groups:
    - { count: 2, from_list: "spellsongs" }
  spells_schedule:
    - { level: 2, count: 1, from_list: "spellsongs" }
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 4, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 9, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 11, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 13, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
    - { level: 15, count: 1, from_list: "spellsongs" }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Language: Dolphin/Whale", base: 98, per_level: 0, note: "Printed as Dolphin/Whale Language 98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "One human language at 98%." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "One other language (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "Printed as Demon and Monster Lore (+15%)." }
    - { name: "Track & Hunt Sea Animals", base: 50, per_level: 5, note: "+15%" }
    - { name: "Navigation: Underwater", base: 45, per_level: 4, note: "Printed as Underwater Navigation (+15%)." }
    - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice, applicable when human." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Applicable when human. Can be changed to martial arts, or assassin if evil, for one other skill selection." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5 }
      - "Espionage"
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"] }
      - "Physical"
      - "Pilot Related"
      - "Rogue"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical, Military, Pilot and Science are barred entirely. All new skills start at level one proficiency."
  secondary_skills:
    count: 4
    note: "Chosen from the same categories as the related skills, excluding those the book marks None, and without the bonuses in parentheses."
restrictions:
  - "Alignment: 60% are scrupulous or unprincipled; the rest tend to principled or anarchist, but can be any alignment, including evil."
  - "Size: biform males average 30 to 40 feet (9.1 to 12.2 m) long, females 20 to 25 feet (6.1 to 7.6 m). The upright angular fin is 7 to 10 feet (2.1 to 3.0 m) tall. Weight 4 to 7 tons for a full-sized adult; the male is about twice the size of the female."
  - "Average life span: at least 400 years. No pneuma-biform has yet died of old age."
  - "STRENGTH AND ENDURANCE ARE SUPERNATURAL, so punches do mega-damage in either form."
  - "Horror Factor: 11 when angry or attacking, and 14 in combat form. The stored save bonus is +7; the horror factor itself is a number others save against."
  - "Speed is the HUMAN form speed of 3D6. Underwater it is 1D4x10+30 in whale form and 1D4x10+10 in whale combat form."
  - "M.D.C. gains 4D6 per level of experience and P.P.E. gains 2D6 per level, on top of the bases stored here."
  - "Spell strength - the number others must save against - is +1 at levels four, eight and twelve."
  - "DO NOT ADD THE HAND TO HAND SKILL''S ATTACKS PER MELEE. The stored 5 is the orca form''s; human form gets 6, and either form gets 2 more via magic or psionics. A bite does 1D4x10 M.D."
  - "NO DOLPHIN MAGIC. Printed 54 gives this class ley line abilities the same as the Dolphin R.C.C. but states outright that it does not have dolphin magic - the one PB that does not. It is also the least magically inclined of the three."
  - "Psionics are the normal killer whale''s, which printed 88 gives as a percentile roll rather than a grant. The roll is the pick-one Psionics group under special abilities, the normal killer whale''s own."
  - "Cybernetics: never."
  - "In its cetacean form the character dehydrates quickly out of water. Every hour on dry land without soaking, it loses 4D6 M.D.C. and cannot heal or regenerate until it has soaked for six hours; after five hours without water it becomes weak, halving attacks per melee round and all combat bonuses. In human form it is uncomfortable away from water, because it needs to immerse itself to change back."
special_abilities:
  - { choose: 1, from: ["Psionics (01-77): None", "Psionics (78-88): Minor Psionic", "Psionics (89-97): Major Psionic", "Psionics (98-00): Master Psionic"], note: "Killer Whale Psionics (printed 88): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-77): None"
    description: "Roll 01-77. No psionic powers and no I.S.P."
  - name: "Psionics (78-88): Minor Psionic"
    description: "Roll 78-88. A minor psionic with 1D4+1 powers from the Physical or Sensitive categories: roll the die and take that many of the five picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "minor"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Physical", "Sensitive"], note: "Roll 1D4+1 and take that many (up to five)." }
  - name: "Psionics (89-97): Major Psionic"
    description: "Roll 89-97. A major psionic with 1D4+3 powers in total from the Healing, Sensitive and Physical categories, in any mix: roll the die and take that many of the seven picks offered. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "major"
      powers_starting: 7
      powers_starting_groups:
        - { count: 7, categories: ["Healing", "Sensitive", "Physical"], note: "Roll 1D4+3 and take that many (up to seven)." }
  - name: "Psionics (98-00): Master Psionic"
    description: "Roll 98-00. A master psionic with one psionic category of the player''s choice from the three lesser ones (Healing, Physical or Sensitive) and 1D4+1 Super powers. Only the Super picks are offered: roll the die and take that many of the five. The page gives no count for the lesser category, so record those powers by hand as the G.M. reads it. The page prints no I.S.P. formula for the tier, so record I.S.P. by hand from the psionics rules in use. A psychic orca also has Psychic Family Imprint: it recognises family and pod members, offspring and descendants."
    psionics:
      type: "master"
      powers_starting: 5
      powers_starting_groups:
        - { count: 5, categories: ["Super"], note: "Roll 1D4+1 and take that many (up to five)." }
natural_abilities:
  - name: "Metamorphosis: Human"
    description: "The normal form is a killer whale; it can become a tall, attractive, dark-skinned human of its own gender twice per 24 hours, for one hour per level of experience. The appearance is always the same. As a human it gains articulated hands, survives on land without dehydrating, walks, runs and climbs - and loses the orca physical abilities. Swimming speed equals running speed, breath holds only 1D4+2 minutes, and depth tolerance drops to 300 feet. Spellsongs are retained at half range."
  - name: "Metamorphosis: Combat Form"
    description: "Size increases by 10% and the skin turns hard, glossy black and metallic like polished chrome. +20 M.D.C. per level of experience, +10 M.D. on every physical attack, +1 attack per melee round, +2 on initiative, +1 to strike, +2 to roll with impact, +3 to pull punch, and a horror factor of 14. Usable from orca or human form, for 30 minutes per level, FOUR times per 24 hours - more than either other biform. These bonuses are conditional and are NOT in the stored block."
  - name: "Mystic Regeneration"
    description: "Regenerates 1D6x10 M.D.C. per minute."
  - name: "Deep Endurance"
    description: "Maximum depth endurance is four miles (6.4 km)."
  - name: "Ley Line Abilities"
    description: "The same ley line abilities as the Dolphin R.C.C. Dolphin magic is NOT included."
  - name: "Human Intelligence"
    description: "Human intelligence, resourcefulness and communication. The voice is high-pitched and guttural as an orca, deep and clear in human form."
  - name: "Impervious to Cold"
    description: "Takes no damage from cold."
  - name: "Permanent Fusion"
    description: "The character stays a pneuma-biform even if the Lord of the Deep is slain, and 83% want to. A character who chooses to become a normal human or orca again can never have the fusion restored."
extraction_notes: |
  - Underseas, printed 53-55. The fighter of the three Pneuma-Biforms and the
    least magically inclined - superior strength, M.D.C. and combat skills,
    and good strategists. The disastrous expedition against the Lord of the
    Deep was led by PB-orcas.
  - IT IS THE ONE PB WITHOUT DOLPHIN MAGIC, and printed 54 says so outright
    rather than leaving it out. Its spell list is spellsongs alone; the ocean
    list is carried in `spell_lists` for the schedule shape and nothing draws
    from it. That is deliberate, so a later correction adding ocean magic has
    a list to point at rather than reason to invent one.
  - ATTACKS ARE THE ORCA FORM''S, five, where human form gets six. Both are in
    the restrictions, with the two magic/psionic attacks and the bite.
  - NO CLASS-LEVEL PSIONICS BLOCK, for the same reason as the PB-dolphin:
    the entry defers to the normal killer whale, whose powers are a
    percentile roll. Since ~114 the roll is a pick-one group of four banded
    options, copied from the killer-whale class as ~090 gave it.
    psionics_allowed is not set, as it is not on the killer-whale class;
    close-out package C5 reads the page for both.
  - ITS MEDICAL GRANT CARRIES NO BONUS where the PB-dolphin carries +5%.
    Printed 54 prints Medical as First aid and Holistic Medicine only, with
    no percentage, and printed 52 prints the same two with (+5%). Transcribed
    as printed rather than harmonised.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 54 gives psionic powers as the same as the normal killer whale, whose own table (printed 88, with its no-psionic-powers result at 01-77) is the whole rule.
---

# Pneuma-Biform Killer Whale

## Lore

The Lord of the Deep must have thought that fusing humans with killer whales would produce superior predators - orcas being ferocious hunters and humans resourceful and treacherous. Like all the pneuma-biforms, the PB-orcas rebelled against their overlord, and most joined the Whale Singers.

Orcas hunt dolphins, porpoises and other whales, but three quarters of the biforms are tolerant of and friendly toward all intelligent life, normal cetaceans included. Only rogues still feed on their smaller cousins. The most vile of those - always anarchist or evil - have little regard for any life but their own, and attack Whale Singers, humans and anyone else they please. They seem to have kept the worst traits of both halves.

Their ferocity and power make them the most feared of the pneuma-biform cetaceans, with the most explosive tempers and the most predatory nature of the three - though the book is careful to add that they are no worse than humans.

## GM Notes

Besides the Whale Singers, PB-killer whales often team up with normal dolphins and whales, humans, sea titans, amphibs, sea inquisitors and anyone of good alignment or good intentions.

They rely on their natural powers, especially in orca form, but may keep as many as a dozen weapons and some personal items for use in human shape - noticeably more than the PB-dolphin. A few own magical, techno-wizard or rune weapons. Body armour is usually none except when in human disguise; some use magically woven kelp armour of 90 M.D.C. from the Song of Weaving.

Despite their failings they remain heroic, compassionate and very influential among the Whale Singers.
',
       updated_at = datetime('now')
 WHERE class_id = 'pneuma-biform-killer-whale'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 15339;

-- == nautyll-soldier ==
UPDATE imported_classes
   SET markdown = '---
id: nautyll-soldier
name: Naut''Yll Soldier
system: rifts
source_book: Rifts World Book 7: Underseas p.148-150
category: rcc
psionics_allowed: false
tags: [combat, pilot, aquatic]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "4d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6+8"
  PP: "3d6"
  PE: "3d6+4"
  PB: "2d6"
  Spd: "3d4"
mdc_base: "1d4x10"
bonuses:
  combat: { attacks: 1, initiative: 2, strike: 1, parry: 1, dodge: 2, roll: 2, pull_punch: 2 }
  pools: { mdc: "1d4x10" }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 } }
  occ_skills:
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Printed as Basic Math (+10%)." }
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Navigation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Boat: Submersibles", base: 50, per_level: 4, note: "Printed as Pilot: Submersible (+10%)." }
    - { name: "Robots & Power Armor", base: 56, per_level: 3, note: "Printed as Pilot Robots and Power Armor, with no bonus." }
    - { name: "Robot Combat Elite", base: 0, per_level: 0, note: "Printed as Power Armor Combat: Elite, naming no model." }
    - { name: "Weapon Systems", base: 50, per_level: 5, note: "+10%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. knife or sword, pick one." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two additional W.P.s of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to martial arts or assassin for one other skill selection." }
  occ_related_skills:
    count: 10
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - "Espionage"
      - { name: "Medical", only: ["Paramedic"], bonus: 5 }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"], bonus: 10 }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
    note: "Electrical, Mechanical and Wilderness are barred entirely."
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 4 }, { level: 6, count: 2 }, { level: 12, count: 2 }]
    note: "NONE at first level: four arrive at level two, then two each at levels six and twelve."
restrictions:
  - "Alignment: any, but the naut''yll lean toward aberrant evil - about 50%."
  - "Size: 6 to 7 feet (1.8 to 2.1 m). Weight 150 to 300 lbs (67.5 to 135 kg). Average life span 120 Earth years."
  - "SUPERNATURAL STRENGTH AND ENDURANCE. A restrained punch does 3D6 S.D.C., a full strength punch 1D6 M.D., a power punch 2D6 M.D."
  - "M.D.C. gains 1D6 per level of experience on top of the stored base. The naut''yll became minor supernatural creatures on a P.P.E.-rich world and turn mega-damage on any planet with a high magical background."
  - "Horror Factor: 8, and 11 for naut''yll mages and mind melters."
  - "SPD IS THE LAND SPEED of 3D4, which is barely a walk. Underwater it is 6D6+10."
  - "THE COMBAT BONUSES ARE UNDERWATER-ONLY: +2 on initiative, +1 to strike and parry, +2 to dodge and to roll or pull a punch. Stored unconditionally, as on the Amphib, because the water is this race''s normal condition - a G.M. running a naut''yll on dry land should ignore them."
  - "WATER DEPENDENCY. A naut''yll survives out of water only while kept wet. After 12 hours out of it, even with drinking water, speed and skill performance drop 10%; after another 12, a further 20% with one attack per melee lost and all combat bonuses halved; each day after that costs 2D6 M.D.C. Double the damage and penalties in desert or savanna conditions. It dies of dehydration after about a week, or of thirst in 24 hours with no water at all. One or two hours'' bathing per 12 prevents the damage, and a water-filled suit keeps it well for weeks with no penalty."
  - "VULNERABLE TO MAGIC AS A SUPERNATURAL BEING: double damage from most rune and Millennium Tree weapons, from magical heat and fire, and from mega-damage plasma and fire. Cold-based magic does half damage. Psychic sensitives detect it easily."
  - "Depth tolerance is two miles (3.2 km), or 2.5 miles (4 km) in Korallyte armour. Every 200 feet beyond costs 1D6x10 M.D., again for every five minutes at that depth, and halves skills, speed, combat bonuses and attacks - the pain is terrible."
  - "Psionics are rolled, not granted (printed 149): 01-10 minor, 11-24 major, 25-30 master (a natural mind melter) and 31-50 mystics with both psionics and magic. The page prints nothing for 51-00, which is read as none. Roll or pick the Psionics ability, which carries the tier; no class-level psionics block is stored, because half of all naut''yll have none."
  - "Cybernetics: none. The naut''yll do not use them; their regeneration is why."
  - "Attribute requirements: P.S. and P.E. 12 or higher are strongly suggested but NOT an absolute requirement - any naut''yll with a fighting spirit can join the military. Stored as no minimum, because the book explicitly declines to make it one."
  - "O.C.C. ABILITIES: +1D4x10 M.D.C. on top of the racial base, and ONE ADDITIONAL ATTACK per melee round."
  - "Money: 1D6x1000 Naut''Yll credits, which are WORTHLESS to anyone else. An NPC officer may hold 3D6x1000 universal credits'' worth of human artifacts, gemstones or precious metal. No `starting_money` is stored, because the currency does not convert."
special_abilities:
  - { choose: 1, from: ["Psionics (01-10): Minor Psionic", "Psionics (11-24): Major Psionic", "Psionics (25-30): Master Psionic", "Psionics (31-50): Mystic", "Psionics (51-00): None"], note: "Naut''Yll Psionic Powers (printed 149): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-10): Minor Psionic"
    description: "Roll 01-10. A minor psionic. Printed 149 names the tier and prints no powers and no I.S.P. formula for it, so record both by hand from the psionics rules in use."
    psionics: { type: "minor" }
  - name: "Psionics (11-24): Major Psionic"
    description: "Roll 11-24. A major psionic. Printed 149 names the tier and prints no powers and no I.S.P. formula for it, so record both by hand from the psionics rules in use."
    psionics: { type: "major" }
  - name: "Psionics (25-30): Master Psionic"
    description: "Roll 25-30. A master psionic, which the page calls a natural mind melter. Printed 149 names the tier and prints no powers and no I.S.P. formula for it, so record both by hand from the psionics rules in use."
    psionics: { type: "master" }
  - name: "Psionics (31-50): Mystic"
    description: "Roll 31-50. A mystic, with both psionic and magic abilities as the standard Mystic class gives them. Nothing is granted here: the page names no tier, no powers and no spells of its own, so take them from the Mystic class by hand. Magic is otherwise open to a naut''yll only through a magical class or this result."
  - name: "Psionics (51-00): None"
    description: "Roll 51-00. No psionic powers. The page prints bands only up to 50 and says nothing of the rest, which is read as none."
natural_abilities:
  - name: "Amphibious"
    description: "Breathes underwater and on dry land indefinitely, with no apparatus. Lungs and gills both, adapting equally to salt or fresh water."
  - name: "Nightvision"
    description: "Sees 300 feet (91.5 m) in near-total darkness."
  - name: "Excellent Hearing"
    description: "Equivalent to bionic hearing."
  - name: "Bio-Regeneration"
    description: "Regains 1D6 M.D.C. per six hours of rest or meditation. Regrows fingers, toes, webbing and nose tentacles in 1D6 weeks, and restores damaged internal organs in the same time. A hand or foot takes 2D4 months; an arm, leg or eye takes 4D4."
  - name: "Resistant to Cold"
    description: "Cold-based attacks do half damage and the naut''yll withstands freezing temperatures without difficulty."
  - name: "Taste and Smell Tentacles"
    description: "Three tentacle-like trunks where a human nose would be, each ending in three tiny tentacles carrying taste and smell receptors far more acute than a human''s. A naut''yll leans over its plate and lets the nine tentacles taste food before it eats."
  - name: "Buoyancy Bladders"
    description: "Internal air and water bladders control buoyancy, letting the naut''yll float to the surface or sink to the bottom at will. It swims in an undulating, snake-like fashion."
extraction_notes: |
  - THE NAUT''YLL RACIAL STAT BLOCK IS PRINTED 148 AND IS FOLDED INTO EACH OF
    THE THREE CLASSES rather than shipped as a fourth row. The Experience
    Tables on printed 214 name the Soldier, the Devastator and the Koral
    Shaper separately and give the bare race no ladder; printed 148 is a
    shared preamble - attributes, M.D.C., depth tolerance, water dependency,
    the amphibious abilities - that all three build on. Every one of them
    carries the same racial restrictions and natural abilities, deliberately,
    so a reader of one class never has to go and find the other page.
  - ITS COMBAT BONUSES ARE UNDERWATER-ONLY AND ARE STORED ANYWAY, the same
    exception made for the Amphib and for the same reason: the water is this
    race''s normal condition rather than a temporary state, and a sheet showing
    no bonuses at all would be wrong more often than right.
  - NO CLASS-LEVEL PSIONICS BLOCK. The racial block runs from printed 148 on
    to 149, and its Psionic Powers line - on 149 - rolls the tier and leaves
    half of all naut''yll with nothing. The roll is a choose-1 special ability
    with five options named for their bands. The page prints four bands, 01-10
    to 31-50, and stops; 51-00 is stored as None so the table has no hole. It
    prints no powers and no I.S.P. for any tier, so the three psychic options
    carry a bare tier (the Momano Headhunter precedent) and the Mystic option
    carries nothing.
  - SPD IS THE LAND SPEED, which for this race is 3D4 - barely a walk. The
    underwater speed of 6D6+10 is in the restrictions.
  - ITS ATTRIBUTE REQUIREMENT IS STORED AS NONE, deliberately. Printed 149
    says P.S. and P.E. of 12 or higher are strongly suggested but not an
    absolute requirement, and that any naut''yll with a fighting spirit can
    join. `attribute_minimums` would enforce what the book declines to.
  - ITS MONEY DOES NOT CONVERT. Printed 149 gives 1D6x1000 Naut''Yll credits
    and says outright they are worthless to anyone else, so `starting_money` -
    which the sheet treats as spendable credits - is left unset and the figure
    is a restriction line. The same is true of the Devastator and the Koral
    Shaper.
  - THE +1D4x10 M.D.C. FROM THE OCCUPATION is a `pools` bonus on top of the
    racial `mdc_base`, which is the shape a race-plus-occupation grant takes.
    The extra attack per melee is `attacks: 1`, a bonus on top of the hand to
    hand skill''s own count. It was stored as a starting number until
    2026-09-25, which worked only because a class''s was then added to the
    skill''s.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 149 prints the race''s own Psionic Powers line as a percentile split (minor, major, master, mystic) that stops at 50; the remainder is read as none, and nothing sends the reader to the standard rule. A Mystic result takes its psionics from the Mystic class, not from a roll.
---

# Naut''Yll Soldier

## Lore

The naut''yll are taught from birth to feel contempt and hatred for every other intelligent life form. Their word for outsider or foreigner is *H''Keezh*, which also means enemy and evil. Every other species is considered inferior or fearsome, and meant to be used and conquered.

That is what the typical naut''yll grunt carries into the field. Raised in a warrior society, most are inspired by tales of heroism, honour and obedience - to great causes and to one''s leaders, even at the cost of one''s life. They value bravery and loyalty above everything and thrive on danger and the acquisition of military power, and it shows in a genuine love of military weapons, armour, vehicles, tactics and fighting skills. These troopers regard a favourite gun roughly the way a human regards a puppy or a sports car.

## GM Notes

A soldier''s duty is to defend the race against the H''Keezh and to build the naut''yll people''s power and reputation. They feel they are doing it when they raid a helpless human settlement or enslave or exterminate a band of kreel-lok or D-bee nomads: anything taken from the H''Keezh makes the empire stronger, and a dead or enslaved enemy is no longer a threat.

Small operations use squads of eight called warbands, which handle exploration, reconnaissance, intelligence, patrols, seek-and-destroy, sabotage, defence and special forces work. A war-tribe is 80 troops, a war-legion 800, a war-front 2400, a war-troop 4800, and a full corps 32,000.

They fight undersea with precision and structure, and are almost as good on dry land - except that a surface campaign needs water-filled environmental suits or ready access to water, exactly as a surface dweller needs air tanks and diving gear to come down.
',
       updated_at = datetime('now')
 WHERE class_id = 'nautyll-soldier'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 13132;

-- == humpback-whale ==
UPDATE imported_classes
   SET markdown = '---
id: humpback-whale
name: Humpback Whale
system: rifts
source_book: Rifts World Book 7: Underseas p.90-92
category: rcc
psionics_allowed: false
tags: [aquatic]
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6+10"
  MA: "2d6+10"
  PS: "3d6+30"
  PP: "3d6+6"
  PE: "3d6+10"
  PB: "2d6"
  Spd: "2d6+14"
hit_points_base: "P.E. x8, +10 per level"
sdc_base: "3d6x10"
ppe_base: "P.E. + 4d4x10, +20 per level"
bonuses:
  combat: { attacks_base: 1, strike: 1, dodge: 1, pull_punch: 1, roll: 2 }
  saves: { horror_factor: 5, toxins_poisons: 2, disease: 2, mind_control: 2 }
  at_level:
    - { level: 2, combat: { attacks: 1 } }
    - { level: 5, combat: { attacks: 1 } }
    - { level: 8, combat: { attacks: 1 } }
    - { level: 11, combat: { attacks: 1 } }
    - { level: 14, combat: { attacks: 1 } }
magic:
  type: "spell"
  spell_lists:
    spellsongs:
      - "Spellsong: Song of Calling"
      - "Spellsong: Song of Danger"
      - "Spellsong: Song of Doubt"
      - "Spellsong: Song of Fear"
      - "Spellsong: Song of Grief"
      - "Spellsong: Song of Joy"
      - "Spellsong: Song of Life"
      - "Spellsong: Song of Protection"
      - "Spellsong: Song of Revenge"
      - "Spellsong: Song of Reversal"
      - "Spellsong: Song of Sea Sickness"
      - "Spellsong: Song of Severing"
      - "Spellsong: Song of Sleep"
      - "Spellsong: Song of Strength"
      - "Spellsong: Song of Summoning"
      - "Spellsong: Song of Weaving"
      - "Spellsong: Sonic Boom"
      - "Spellsong: Sound Blast"
      - "Spellsong: Sound Spike"
      - "Spellsong: Stormsong"
      - "Spellsong: Valorsong"
  spells_starting_groups:
    - { count: 4, from_list: "spellsongs" }
  spells_schedule:
    - { level: 2, count: 2, from_list: "spellsongs" }
    - { level: 3, count: 1, from_list: "spellsongs" }
    - { level: 4, count: 1, from_list: "spellsongs" }
    - { level: 5, count: 1, from_list: "spellsongs" }
    - { level: 6, count: 1, from_list: "spellsongs" }
    - { level: 7, count: 1, from_list: "spellsongs" }
    - { level: 8, count: 1, from_list: "spellsongs" }
    - { level: 9, count: 1, from_list: "spellsongs" }
    - { level: 10, count: 1, from_list: "spellsongs" }
    - { level: 11, count: 1, from_list: "spellsongs" }
    - { level: 12, count: 1, from_list: "spellsongs" }
    - { level: 13, count: 1, from_list: "spellsongs" }
    - { level: 14, count: 1, from_list: "spellsongs" }
    - { level: 15, count: 1, from_list: "spellsongs" }
skills:
  occ_skills:
    - { name: "Swimming", base: 98, per_level: 0, note: "At 98%, a fixed figure." }
    - { name: "Track & Hunt Sea Animals", base: 40, per_level: 5, note: "+5%" }
    - { name: "Navigation: Underwater", base: 50, per_level: 4, note: "Printed as Underwater Navigation (+20%)." }
    - { name: "Undersea & Sea Survival", base: 35, per_level: 5, note: "Printed as Undersea Survival (+10%)." }
    - { choose: 1, from: ["Language: Other"], bonus: 5, note: "One human language of choice (+5%), probably American/English." }
  occ_related_skills:
    count: 3
    schedule: [{ level: 3, count: 1 }, { level: 7, count: 1 }, { level: 11, count: 1 }, { level: 15, count: 1 }]
    categories:
      - { name: "Communications", only: ["Radio: Basic", "Sing"] }
      - { name: "Domestic", only: ["Dance", "Fishing"] }
      - { name: "Espionage", only: ["Detect Ambush", "Detect Concealment", "Intelligence"] }
      - { name: "Pilot", only: ["Robots & Power Armor"] }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 4 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: -10 }
      - { name: "Technical", only_prefix: ["Language", "Lore"], only: ["Advanced Fishing", "Undersea Salvage"] }
      - { name: "Wilderness", only: ["Undersea & Sea Survival", "Track & Hunt Sea Animals"] }
    note: "Electrical, Mechanical, Military, Physical, Pilot Related and W.P. are barred entirely. Three of these entries reach across the catalog''s filing: the book grants SING under Domestic and the catalog files it under Communications; it grants PROWL under Rogue where the catalog files it under Physical; and its Technical line - language, lores and underwater skills only - is a prefix restriction rather than a name list. See extraction_notes. The -10% the book prints on the Communications line applies to Radio: Basic only and is NOT stored as a category bonus, because that would apply it to Sing as well. Pilot is barred except specially designed power armour. Medical is barred entirely here, unlike the dolphin, orca and sperm whale, which all get Sea Holistic Medicine."
  secondary_skills:
    count: 0
    schedule: [{ level: 3, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }, { level: 15, count: 1 }]
    note: "The character starts with NO secondary skills and gains one on the schedule above, without bonuses. Chosen from the same categories as the related skills."
restrictions:
  - "Alignment: any, but usually good - typically 50% scrupulous, 15% principled, 15% unprincipled, 10% anarchist and 10% other. The most reliably good-aligned of the four."
  - "THIS IS AN S.D.C. CREATURE, not a mega-damage one. It becomes mega-damage only while ley line charged."
  - "Natural A.R. 1D6+5."
  - "HIT POINTS AND S.D.C. BOTH HAVE TWO FIGURES AND THE SMALLER IS STORED. Hit points are P.E. x8 for females and young and P.E. x10 for a full-grown male, +10 per level either way. S.D.C. is 3D6x10 for females and young, 5D6x10 for a full-grown male."
  - "Horror Factor: 10 when angry or attacking."
  - "Size: males average 60 to 70 feet (18.3 to 21.3 m), females 40 to 48 feet (12.2 to 14.6 m). Weight 60 to 70 tons for a full-sized adult, 30 to 40 for a female."
  - "Average life span: 70 to 100 years, maturity at 11 to 13."
  - "ALL HUMPBACKS HAVE SOME PSIONIC POWER. Printed 92 rolls the degree on a table rather than granting one set: 01-90 minor, 91-00 major. Roll or pick the Psionics ability, which carries the tier, I.S.P. and powers - unlike the dolphin and the orca, where most have none, here every character has something."
  - "Spellsong strength is +1 at levels two, five, eight and twelve. It is +6 to save against whale spellsongs specifically - the highest in the book - on top of +1 against magic generally."
  - "NO AUTOMATIC DODGE. It parries with nose or tail at +1."
  - "It is a filter feeder, straining krill and shrimp through baleen plates."
  - "The humpback gets +20% to Sing where other classes get +10%, and DOUBLE range on any spellsong that lists a doubled range for humpbacks."
  - "Speed is the CRUISE, not a sprint: the whale holds 10 to 12 mph for hours, covering 100 to 120 miles a day - up to 150 if pushed to exhaustion, which then halves speed and range for following days until it rests."
  - "Standard equipment: NONE, and money: none. Cetaceans neither need nor want possessions. One may keep a piece of artwork, a magic item or a keepsake - a toy, tool, weapon, article of clothing or photograph - to remember a friend or an occasion by."
  - "Cybernetics: none."
  - "DEHYDRATES OUT OF WATER AND IS ALL BUT IMMOBILE THERE - it can only flop and squirm. It survives about 15 minutes before the skin dries and it weakens, and dies in 30+3D4 minutes. Continuously bathed or sprinkled it lasts 60+6D6 minutes. Kept in a saltwater container with room to swim and fed, it can live indefinitely in theory - though many stop eating in captivity and die after 6D6 days unless they have a reason to live."
special_abilities:
  - { choose: 1, from: ["Psionics (01-90): Minor Psionic", "Psionics (91-00): Major Psionic"], note: "Humpback Whale Psionics (printed 92): every humpback has some psionic power. Roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Psionics (01-90): Minor Psionic"
    description: "Roll 01-90. A minor psionic limited to See Aura, Sense Magic and Mind Block, plus one power of choice from the Sensitive category. Base I.S.P. is M.E. x2, plus 1D6 per level."
    psionics:
      type: "minor"
      isp_base: "M.E. x2, +1d6 per level"
      powers: ["See Aura", "Sense Magic", "Mind Block"]
      powers_starting: 1
      categories_allowed: ["Sensitive"]
  - name: "Psionics (91-00): Major Psionic"
    description: "Roll 91-00. A major psionic limited to See Aura, Sense Magic and Mind Block, plus two powers of choice from the Healing or Sensitive categories. Base I.S.P. is M.E. x3, plus 1D6+2 per level."
    psionics:
      type: "major"
      isp_base: "M.E. x3, +1d6+2 per level"
      powers: ["See Aura", "Sense Magic", "Mind Block"]
      powers_starting: 2
      categories_allowed: ["Healing", "Sensitive"]
natural_abilities:
  - name: "Master of Spellsongs"
    description: "Other than the pneuma-biforms, the humpback is the most powerful of the Whale Singers. It selects four spellsongs at level one, two at level two, and one more every level after."
  - name: "True Song"
    description: "No other whale has the same variety or complexity of sound. A humpback''s songs are true songs - an ordered sequence of themes, motifs and phrases like a bird''s - which can be repeated exactly and taught to others. Clicks, chirps, yups, cries, moans and roars, mostly between 40Hz and 5kHz. One song lasts 6 to 40 minutes and can carry up to 116 miles (185 km), though most sounds reach 50 to 60 miles."
  - name: "Humpback Combat"
    description: "ONE attack per melee round at level one, and one more at levels two, five, eight, eleven and fourteen. Parries with nose or tail at +1. No automatic dodge."
  - name: "Resistant to Cold"
    description: "Cold does half damage."
  - name: "Depth Tolerance"
    description: "Survives the pressure and cold at depth. A dolphin manages a mile (1.6 km); of all the cetaceans only the sperm whale reaches the ocean floor, at two to three miles (3.2 to 4.8 km)."
  - name: "Hold Breath Underwater"
    description: "Most dolphins and porpoises hold their breath 2D4+10 minutes. Large whales of 20 to 40 feet manage 2D6+14 minutes; the Rorqual whales - blue, fin, humpback, minke, sei, Bryde''s - plus grey and sperm whales manage 2D6+24."
  - name: "Sense Magnetic North"
    description: "Unless injured or sick, always knows precisely where magnetic north lies. A powerful blow to the head knocks the ability out for 3D4 minutes."
  - name: "Electromagnetic Sensitivity"
    description: "Senses the electromagnetic activity in a living brain and nervous system like a living E.E.G. - detecting blood clots, tumours, brain or spinal damage, heart problems, paralysis, injury, fatigue and pain, and telling whether a creature is a minor, major or master psychic. It also sees electromagnetic energy directly, following energy trails in the earth like marked roads even in total darkness, and following the trail a ship or submarine leaves for up to twenty minutes after it passes."
  - name: "Sonic Echo-Location"
    description: "Natural sonar. Locates and identifies objects, terrain and creatures underwater without sight."
  - name: "Ultrasonic Probe"
    description: "A focused ultrasonic examination, used among other things to recognise a specific individual."
  - name: "Recognize Family Heritage"
    description: "Recognises relatives and descendants by song, appearance and ultrasonic probe. Base skill 50% +3% per level of experience."
  - name: "Ley Line Charged"
    description: "Absorbs ley line energy until the creature glows blue and becomes TEMPORARILY MEGA-DAMAGE: every available S.D.C. point and hit point converts at two M.D.C. per point. Swimming speed rises 25% and breath capacity 50%. It takes 1D4 melee rounds to charge, lasts while travelling along a ley line and for 3D4 melee rounds after leaving it, and can be done twice an hour. While charged the creature loses one attack per melee, all ultrasonic abilities are cut 40%, and it is +1 to save against all magic with any magic affecting it at half potency. Costs 5 P.P.E."
  - name: "Ley Line Energy Blast"
    description: "Creates and fires mystic energy bolts while on a ley line, at 1000 feet (305 m) plus 400 feet (122 m) per level. Damage is S.D.C. or M.D.C. as desired, regulated in 1D6 increments: 2D6 at levels one and two, and a further 1D6 every two levels after. Costs 1 P.P.E. for an S.D.C. bolt or 5 for M.D.C., whatever the damage."
  - name: "Ley Line Hopping"
    description: "At top speed, creates a small Rift that pops the creature and one passenger from one ley line to a neighbouring one, or between two points on the same line. Takes 1D4 melee rounds to focus; the neighbouring line can be no more than one mile per level away. Costs 10 P.P.E."
  - name: "Ley Line Speed Doubler"
    description: "Doubles natural swimming speed while travelling directly along a ley line, and costs NO P.P.E."
  - name: "Sense Ley Line and Magic Energy"
    description: "The same as the ley line walker''s."
  - name: "Read Ley Lines"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Transmission"
    description: "The same as the ley line walker''s."
  - name: "Ley Line Rejuvenation"
    description: "Doubles the natural healing rate, the same as the ley line walker''s ability."
extraction_notes: |
  - Underseas, printed 90-92. The master of spellsongs: other than the
    pneuma-biforms, the most powerful of the Whale Singers, and the only
    cetacean here whose magic is spellsongs alone.
  - ITS SPELLSONG LADDER IS THE FULLEST IN THE BOOK - four at level one, two
    at level two, and one every level after - which is the same shape the
    Whale Singer O.C.C. uses. That is not a coincidence and it is why this
    class is worth having.
  - EVERY HUMPBACK IS PSIONIC TO SOME DEGREE, which is different from the
    dolphin and orca, where printed 80 and 88 leave 77% with nothing. No
    class-level psionics block is stored either way, because printed 92 still
    rolls the degree rather than granting one set: the roll is a choose-1
    special ability with two options named for their bands, 01-90 minor and
    91-00 major, each carrying its own tier, I.S.P. formula and powers.
  - MEDICAL IS BARRED ENTIRELY, where the other three cetaceans all get Sea
    Holistic Medicine. Transcribed as printed 91 gives it.
  - ITS SING BONUS AND ITS SPELLSONG RANGES ARE BOTH DOUBLED relative to the
    other cetaceans, and several spellsong rows name the humpback explicitly
    in their range lines. Neither is stored on this class: the Sing bonus
    belongs to whichever class grants the skill, and the doubled range lives
    on the spell rows.
  - HIT POINTS AND S.D.C. STORE THE FEMALE/YOUNG FIGURE, as on the other two
    whales.
  - PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Underseas printed 92 says all humpbacks have some degree of psionic power and gives the race''s own two-row table, so that table is the whole rule.
---

# Humpback Whale

## Lore

There has always been something magical about the humpback whale and its haunting songs. No other whale has the same variety or complexity of sound, and the humpback''s are true songs - an ordered sequence of themes, motifs and phrases like a bird''s, which can be repeated exactly and taught to others.

A single song lasts between six and forty minutes and can be heard up to a hundred and sixteen miles away.

Since the development of Whale Singer spellsongs, the humpback has become one of their masters. Other than the pneuma-biforms, it is the most powerful of the Whale Singers.

## GM Notes

Humpbacks, like all baleen whales, are filter feeders. The whale opens its mouth wide to engulf water full of krill and shrimp, and the baleen plates growing down from the roof of its mouth strain them out as the water passes through.

Every humpback has some degree of psionic power - which is not true of dolphins or killer whales, where most have none at all.

Several spellsongs name the humpback explicitly in their range lines, doubling or in one case multiplying by ten what any other singer gets. A humpback in a party changes what the spellsong list is worth.
',
       updated_at = datetime('now')
 WHERE class_id = 'humpback-whale'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 15879;

-- == amaki-stone-man ==
UPDATE imported_classes
   SET markdown = '---
id: amaki-stone-man
men_of_arms: false
name: Amaki Stone-Man
system: rifts
source_book: Rifts World Book 9: South America 2 p.154-155
category: rcc
psionics_allowed: false
tags: []
xp_table: [0, 2121, 4281, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]
attribute_dice:
  IQ: "3d6"
  ME: "3d6+2"
  MA: "3d6+2"
  PS: "2d6+12"
  PP: "3d4+10"
  PE: "3d6+6"
  PB: "3d6+2"
  Spd: "3d6"
hit_points_base: "P.E. x10 plus 4d6 per level of experience"
ppe_base: "4d6"
horror_factor: 6
bonuses:
  pools: { sdc: "3d6x100" }
  combat: { initiative: 1, parry: 1, dodge: 1, roll: 2 }
  saves: { horror_factor: 2 }
skills:
  occ_skills:
    - { name: "Language: Amaki", base: 98, per_level: 0, note: "Amaki (98%); known by about 95% of adult Amaki on Rifts Earth." }
    - { name: "Language: Spanish", base: 70, per_level: 5, note: "Spanish (+20%)." }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "Almost all adult Amaki; one of the two skills the Amaki blast-sword needs." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0, note: "Almost all adult Amaki; the other skill the blast-sword needs." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%; most Amaki are great dancers." }
    - { choose: 1, from: ["Play Musical Instrument", "Sing"], bonus: 10, note: "One musical instrument or singing (+10%)." }
natural_abilities:
  - { name: "Stone Skin", description: "Natural Armor Rating (A.R.) 16. Not an M.D.C. being, but 3D6x100 S.D.C. and P.E. x10 hit points (1 M.D.C. equals 100 S.D.C.) let an Amaki survive minor Mega-Damage and shrug off small arms." }
  - { name: "Damage Resistance", description: "All non-magical attacks, physical and energy alike, do only half damage. Magic and psionic attacks do full damage." }
  - { name: "Nightvision", description: "1000 feet (305 m)." }
  - { name: "Keen Senses", description: "Hearing and vision slightly above the best human levels." }
  - { name: "Rapid Healing", description: "Heals damage five times as fast as a human." }
  - { name: "Stone Fists", description: "Restrained punch 1D4 S.D.C., full strength punch 4D6 S.D.C. (both plus P.S. bonus), power punch 1D6 M.D. (counts as two attacks)." }
  - { name: "Size and Life Span", description: "5 to 7 feet (1.5 to 2.1 m) tall, 120 to 200 lbs (54 to 90 kg); average life span 300 years." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-20): Major Psionic", "Psionics (21-50): Minor Psionic", "Psionics (51-64): Master Psionic", "Psionics (65-00): None"], note: "Psionic Powers (printed 155): roll percentile dice or pick one." }
  - name: "Psionics (01-20): Major Psionic"
    description: "Percentile roll 01-20. A major psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "major" }
  - name: "Psionics (21-50): Minor Psionic"
    description: "Percentile roll 21-50. A minor psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "minor" }
  - name: "Psionics (51-64): Master Psionic"
    description: "Percentile roll 51-64. A master psionic. The entry prints no powers or I.S.P. for the tier; its Psionic O.C.C.s line says many Amaki are master psionics, with mind melters the commonest (50%) and duelists and bursters besides, so a master normally takes one of those O.C.C.s, whose page states the powers and I.S.P."
    psionics: { type: "master" }
  - name: "Psionics (65-00): None"
    description: "Percentile roll 65-00. No psionic powers. This table stands in place of the standard psionics roll."
restrictions:
  - "Psionics: the Amaki roll on their own table, not the standard one - 01-20 Major, 21-50 Minor, 51-64 Master, 65-00 none. It is the Psionics pick under special abilities; hold the race to it rather than to the standard roll."
  - "Magic: none of the race''s own; an Amaki magician gets magic from a magical O.C.C."
side_effects: "Vulnerabilities/Penalties: none, as printed. Typical NPC is level 1D4+1."
extraction_notes: "Rifts World Book 9: South America 2 printed 154-155 (cache p154-p155, page_offset 0). The heading and first paragraph are at the foot of 154; the whole stat block is on 155. OCR on 155 reads 8.D.C. for S.D.C. and [1.Q. for I.Q.; the numbers were taken from the OCR as briefed. No amaki-stone-man class was in production on 2026-09-25. || A RACE THAT TAKES AN O.C.C.: the R.C.C. prints only a racial skill paragraph (''these are in addition to O.C.C. skills''), no related or secondary lists, no Hand to Hand, no money, no cybernetics line and ''Weapons and Equipment: varies with O.C.C.'', and names its common O.C.C.s (Duelist, Gizmoteer, and a long list of core and Mercenaries O.C.C.s). So it grants no related or secondary skills, which is what makes needsOccupation() mark it normally paired; no occ_restrictions is stored because the book names no forbidden occupation. No equipment_starting and no starting_money: equipment and money sum or fall through across a pairing, and the race issues none (the book''s Amaki blast-sword, blast rifle, combat armor and TW psi-blade rows exist and are issued by the Duelist and Gizmoteer, not by the race). || XP: the Amaki Stone Man ladder on printed 192, as briefed (the same figures as the Arkhon ladder). The book prints a ladder for the race; it applies when the race is paired with an occupation that states none, which is most Rifts O.C.C.s, so it is stored. || POOLS: 3D6x100 S.D.C. is a racial S.D.C. and stored as a POOL BONUS (bonuses.pools.sdc), never sdc_base, so an occupation''s S.D.C. adds to it. Hit Points P.E. x10 plus 4D6 per level as printed. P.P.E. 4D6. Horror Factor 6. M.D.C. none; the ''survives minor M.D.'' note and A.R. 16 are natural_abilities text, since no class key carries a natural A.R. men_of_arms: false, as for every race. || ATTRIBUTES as printed: I.Q. 3D6, M.E. 3D6+2, M.A. 3D6+2, P.S. 2D6+12, P.P. 3D4+10, P.E. 3D6+6, P.B. 3D6+2, Spd 3D6. || BONUSES: +1 initiative, +1 parry and dodge, +2 roll with impact, +2 save vs horror factor, unconditional. The half damage from non-magical attacks is a natural ability, not a number. || PSIONICS: the book gives a race-specific percentile table (20% major, 30% minor, 14% master, 36% none). Stored since 2026-10-03 as a banded choose-1 group in special_abilities, one option per printed band. No class-level psionics block is stored (psionics_allowed was left unset until 2026-10-05; see the end of these notes); the tiers carry a type only, because the page prints no powers or I.S.P. for them. A psychic O.C.C. states its own block and wins. || SKILLS: Amaki (98%) as Language: Amaki 98 (the language only; the book says Amaki, not language and literacy); Spanish (+20%) as Language: Spanish 50+20; W.P. Sword and W.P. Energy Pistol; dancing (+15%) as Dance 30+15; one musical instrument or singing (+10%) as a choose 1 of Play Musical Instrument or Sing with bonus 10. The book says 95% of adult Amaki know these; stored as known, the percentage in the notes. || Alignment (any, leaning good and selfish), alliances with True Atlanteans, and the O.C.C. distribution lists are lore and GM notes. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. South America 2 printed 155 prints the race''s own Psionic Powers line, framed as its incidence against humans, with its own No Psionics band at 65-00."
---

## Lore

The Amaki are humanoids whose skin looks like polished marble: cool, smooth,
hairless and as hard as stone, yet flexible enough to move like flesh. Most
males grow a stony chin-crest shaped like the carved beards of ancient
Babylonian statues, which is where the humans of South America got the name
"Babylonians" for them. Their natural colour is grey or black, but Amaki love
to paint themselves in every shade and to dress extravagantly.

They came through the Rifts about a century after the Cataclysm, colonists
from a crowded but prosperous homeworld ruled by guild Houses, and built New
Babylon in partnership with the human survivors. They find humans the most
Amaki-like people they have ever met; friendships and even marriages between
the two are common.

## GM Notes

An Amaki is tough enough to shrug off small arms and survive light
Mega-Damage, and non-magical attacks do only half damage to one. Common
occupations are the Duelist and Gizmoteer, plus headhunters, wilderness
scouts, rogue scholars, operators, city rats and the Coalition-style military
O.C.C.s; their magicians are mostly techno-wizards, and their psychics mostly
mind melters.
',
       updated_at = datetime('now')
 WHERE class_id = 'amaki-stone-man'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 8420;

-- == arkhon ==
UPDATE imported_classes
   SET markdown = '---
id: arkhon
men_of_arms: false
name: Arkhon
system: rifts
source_book: Rifts World Book 9: South America 2 p.71-73
category: rcc
psionics_allowed: false
tags: []
xp_table: [0, 2121, 4281, 8481, 16961, 24961, 34961, 49961, 69961, 94961, 129961, 179961, 229961, 279961, 329961]
attribute_dice:
  IQ: "2d6+6"
  ME: "3d6"
  MA: "3d6"
  PS: "2d6+12"
  PP: "2d6+12"
  PE: "3d6+4"
  PB: "3d6+6"
  Spd: "3d6+10"
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d6x1000"
bonuses:
  pools: { sdc: "2d6x10" }
  combat: { initiative: 1, roll: 2, pull_punch: 2 }
  saves: { spell_magic: 2, horror_factor: 3 }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Arkhon", base: 98, per_level: 0, note: "Language and Literacy: Arkhon (98%): the speaking half." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "The literacy half of Language and Literacy: Arkhon (98%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Language: two of choice (+15%). Taken once per language - the picker asks which." }
    - { name: "Computer Operation", base: 55, per_level: 5, note: "+15%" }
    - { name: "Radio: Basic", base: 60, per_level: 5, note: "+15%" }
    - { name: "Running", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Sword", "W.P. Knife"], note: "W.P. Sword or W.P. Knife (choose one)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts at the cost of one other skill." }
  occ_related_skills:
    count: 8
    categories:
      - { name: "Communications", bonus: 10 }
      - "Domestic"
      - { name: "Electrical", bonus: 5 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", note: "+5% on Paramedic only." }
      - { name: "Medical", only: ["Paramedic"], bonus: 5, note: "+5% on Paramedic only." }
      - { name: "Military", bonus: 10 }
      - "Physical"
      - { name: "Pilot", bonus: 5 }
      - { name: "Pilot Related", bonus: 5 }
      - "Rogue"
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Every category is Any. Medical carries +5% on Paramedic only: the second Medical entry carries it."
    schedule:
      - { level: 3, count: 1 }
      - { level: 5, count: 1 }
      - { level: 8, count: 1 }
      - { level: 11, count: 1 }
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
  - { item_id: "tb-prime-tri-beam-energy-rifle", qty: 1, note: "Arkhon energy rifle of choice; the TB-Prime is the book''s one tri-beam rifle (printed 80-81)." }
  - { choose: 1, label: "Arkhon energy pistol of choice", qty: 1, from: ["tb-3-tri-beam-energy-pistol", "tb-9-auto-pistol"], note: "The book''s two tri-beam pistols (printed 80)." }
  - { item_id: "arkhon-body-armor", qty: 1, note: "A suit of combat armor." }
  - { item_id: "walkie-talkie", qty: 1, note: "The book says a communicator." }
  - { item_id: "survival-kit", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "archaic or modern weapon of choice", qty: 1, from: ["tri-blade-energy-sword", "vibro-knife", "vibro-sword", "broadsword", "fr-5-flechette-rifle"], note: "The book says an archaic or modern weapon of choice without enumerating; the Arkhon tri-blade and flechette rifle lead the catalog set." }
natural_abilities:
  - { name: "Bite and Claws", description: "Bite does 2D6 S.D.C.; claws add 1D6 S.D.C. to hand to hand punches and kicks." }
  - { name: "Senses", description: "Roughly equivalent to a human''s; no special senses." }
  - { name: "Psionic Potential", description: "A higher incidence of psionics than humans. The race''s own percentile table is the Psionics pick under special abilities, taken in place of the standard psionics roll." }
  - { name: "Disbelief in Magic", description: "Their culture abandoned magic millennia ago and still does not believe in it, which is where the +2 save vs magic comes from. Some Arkhons may learn magic anyway." }
  - { name: "Life Span", description: "200 years with advanced medical technology, half that without; some wealthy Arkhons have added as much as 500 years with chemical treatments, cloned organs and anti-aging techniques." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-18): Major Psionic", "Psionics (19-50): Minor Psionic", "Psionics (51-56): Master Psionic", "Psionics (57-00): None"], note: "Psionic Powers (printed 72): roll percentile dice or pick one. The book prints the first three bands only; 57-00 is what they leave." }
  - name: "Psionics (01-18): Major Psionic"
    description: "Percentile roll 01-18. A major psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "major" }
  - name: "Psionics (19-50): Minor Psionic"
    description: "Percentile roll 19-50. A minor psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "minor" }
  - name: "Psionics (51-56): Master Psionic"
    description: "Percentile roll 51-56. A master psionic. The book says these become Arkhon ESP Specialists, so choosing this asks for that O.C.C. as the paired occupation, and its page states the powers and I.S.P. The band is stored as printed, six points wide, although the next sentence of the entry calls master psionics a tiny percentage."
    psionics: { type: "master" }
    occ_options: ["arkhon-esp-specialist"]
  - name: "Psionics (57-00): None"
    description: "Percentile roll 57-00. No psionic powers. The book prints no band for this result: it is the remainder after the three printed bands (01-56). This table stands in place of the standard psionics roll."
restrictions:
  - "Credits: the 1D6x1000 are Arkhon credits, useful only within the Freehold. A renegade who has lived outside the Freehold has 2D6x100 standard credits instead."
side_effects: "HUMIDITY: at 60% humidity or higher the character is weak and easily exhausted: -4 to initiative, -2 to all combat actions, and one fewer attack per melee. Arkhons avoid jungles unless wearing environmental armor. Otherwise they tolerate heat and cold about as well as humans, and are better adapted than humans to the thin air of high mountains."
extraction_notes: "WB9 South America 2 printed 71-73 (cache p071-p073, page_offset 0); the stat block starts at the foot of printed 71, the attributes, pools, bonuses and psionics are printed 72, the skills, equipment and money printed 73. Printed 72 checked against a 200 dpi render; OCR and render agree. || XP: the Arkhon ladder on printed 192, read off a render, as briefed; lower bounds stored as printed. A race carries a ladder only when its book prints one for it, and this one does. In a pairing the occupation''s ladder wins. || POOLS: S.D.C. 2D6x10 in addition to skill bonuses - stored as a pool bonus (bonuses.pools.sdc), never sdc_base, because it adds to whatever an occupation grants. Hit points are printed as standard, same as humans; stored as the human formula P.E. + 1D6 per level. P.P.E. is printed as standard (same as humans) and is not stated. M.D.C.: by armor only. men_of_arms: false, as for every race. Horror Factor: none, not stored. || ATTRIBUTES: I.Q. 2D6+6, M.E. 3D6, M.A. 3D6, P.S. 2D6+12, P.P. 2D6+12, P.E. 3D6+4, P.B. 3D6+6, Spd 3D6+10, as printed. || BONUSES: +1 initiative, +2 roll with impact, +2 pull punch, +2 save vs magic (spell_magic), +3 save vs Horror Factor, all unconditional. || PSIONICS: the book prints its own odds (01-18 major, 19-50 minor, 51-56 master, a tiny percentage master). Stored since 2026-10-03 as a banded choose-1 group in special_abilities: one option per printed band and a 57-00 None, which the book does not print and which is the remainder of the three printed bands. No class-level psionics block; the major and minor options carry a type only, because the page prints no powers or I.S.P. for them, and the master option names the ESP Specialist in occ_options. The master result points at the Arkhon ESP Specialist O.C.C., which states its own master block. Note the printed ranges are odd - 51-56 is six percent for master, which the next sentence calls tiny - and are transcribed as printed. || MAGIC: none by culture, but not forbidden (some Arkhons might learn it); not stored as a restriction. || SKILLS: the book prints R.C.C. Skills plus R.C.C. Related and Secondary lists, so the race carries all three; an occupation''s related and secondary allowances replace these in a pairing. Language and Literacy: Arkhon (98%) -> Language: Arkhon 98 and Literacy: Native Language 98, both flat, the convention this book''s Inca Sun Priest uses for Quechua. Language two of choice +15 as two Language: Other picks. Computer Operations -> Computer Operation 40+15 = 55. Basic Radio -> Radio: Basic 45+15 = 60. Running. Pilot one of choice +10 as a Pilot choice group with bonus 10. W.P. Energy Rifle, W.P. Energy Pistol, W.P. Sword or Knife as a two-way choice. Hand to Hand: Expert, to Martial Arts for one other skill (costs martial_arts 1). || RELATED: 8, plus one at levels 3, 5, 8, 11 and 14. Every category Any: Communications +10, Electrical +5, Espionage +5, Mechanical +5, Military +10, Pilot +5, Pilot Related +5, Science +5, Technical +10; Domestic, Physical, Rogue, W.P. and Wilderness with none. Medical prints +5% on paramedic only; a category bonus applies to every pick in it, so the second Medical entry, limited to Paramedic, carries the +5. Secondary: 5, same categories, no bonuses. || EQUIPMENT: energy rifle of choice -> TB-Prime (the only Arkhon tri-beam rifle; the M-100 is crew served); energy pistol of choice -> TB-3 or TB-9; a suit of combat armor -> arkhon-body-armor; communicator -> walkie-talkie (judgement, as the Inca Warrior''s radio); survival kit; survival knife; an archaic or modern weapon of choice -> a choice set led by the Arkhon Tri-Blade and FR-5. Power armor, special weapons and vehicles assigned for missions are not starting gear. || MONEY: 1D6x1000 Arkhon credits stored; the renegade alternative of 2D6x100 standard credits and the Freehold-only currency are a restriction line. In a pairing the race''s starting_money wins over an occupation''s, except the Arkhon Spectral Hunter''s and ESP Specialist''s: both are Arkhon-only, both print their own money, and both carry overrides_race: [starting_money] (BOOK-INGEST-AUDIT F111, taken 2026-09-27), so they start with 2D4x1000 and 2D6x1000. || Alliances (the Fallam, human and D-Bee servants) and alignment (any; 65% anarchist or evil) are lore. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. South America 2 printed 72 prints the race''s own Psionic Powers line with three bands to 56; the remainder is read as none, and nothing sends the reader to the standard rule."
---

## Lore

Arkhons are slender alien humanoids with a blend of feline and reptilian
features: yellow-grey hairless skin, human-like eyes, large pointed ears and a
slightly crouched stance. They tend to be wiry rather than bulky, yet stronger
than the average human. Soldiers wear red, spiked armor built around a single
central eye; civilians dress in every style, and some have taken to Earth
fashions.

Their homeworld resembled Earth, so they breathe its air and thrive in the
high, thin air of the mountains, but humid places sap them badly. Only the
bionic Spectral Hunters patrol the jungles as a matter of course.

Arkhon culture prizes success above everything: winning matters however it is
achieved, a loser deserved to lose, and bad luck is treated as a personal
flaw. Obedience to superiors is the other pillar - a failed leader is removed
by his equals, never questioned by those below him. The exiled Tlo-Arkhon clan,
beaten at home and battered on arrival, is desperate to redeem itself, and its
code excuses lies and betrayal so long as the Arkhons win.

## GM Notes

Alignment: any; about 65% of the invaders are anarchist or evil, usually
miscreant or aberrant. Good-aligned Arkhons are often shunned, and a few have
deserted to found small settlements in the far south.
',
       updated_at = datetime('now')
 WHERE class_id = 'arkhon'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 12610;

-- == larmac ==
UPDATE imported_classes
   SET markdown = '---
id: larmac
name: Larmac
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.118-120
category: rcc
psionics_allowed: false
tags: []
horror_factor: 12
attribute_dice:
  IQ: "2d6+3"
  ME: "2d6+3"
  MA: "2d6"
  PS: "4d6+16"
  PP: "3d6"
  PE: "3d6+5"
  PB: "1d6+3"
  Spd: "2d6+5"
mdc_base: "P.E. + 5d6, +2d4 per level"
ppe_base: "1d6"
bonuses:
  saves: { horror_factor: 5, toxins_poisons: 6, disease: 6, harmful_drugs: 6, other: [ { label: "vs illusions", bonus: -3 } ] }
skills:
  occ_skills:
    - { name: "Cook", base: 55, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
natural_abilities:
  - name: "Mega-Damage hide"
    description: "M.D.C. 5D6 plus the P.E. attribute number, +2D4 per level of experience. Recovers M.D.C. at 2D6+3 per day. On an S.D.C. world: 6D6 plus P.E. Hit Points and 6D6 S.D.C. plus skill bonuses, natural A.R. 12. The thick hide and blubber let a Larmac cross a desert by day without heat exhaustion or dehydration and shrug off cold down to -40 degrees Fahrenheit."
  - name: "Robot Strength"
    description: "P.S. 4D6+16 is equivalent to Robot Strength; damage is by Robot P.S. or weapon."
  - name: "Nightvision and endurance"
    description: "Nightvision 300 feet (91.5 m). Can go a week without food and four days without water before feeling the effects."
special_abilities:
  - name: "Highly motivated"
    description: "When highly motivated or fighting for his own life, the Larmac gets +1 melee action/attack, +1 on initiative and +1 to parry or dodge. Otherwise he is -1 on initiative."
  - { choose: 1, from: ["Psionics (01-02): Master Psionic", "Psionics (03-07): Major Psionic", "Psionics (08-15): Minor Psionic", "Psionics (16-00): None"], note: "Psionics (printed 120): psychic abilities are rare among Larmac. Roll percentile dice or pick one." }
  - name: "Psionics (01-02): Master Psionic"
    description: "Percentile roll 01-02. A master psionic: the table says to select a psionic O.C.C., whose page states the powers and I.S.P. This is the table''s own exception to the occupation line that bars most psionic O.C.C.s."
    psionics: { type: "master" }
  - name: "Psionics (03-07): Major Psionic"
    description: "Percentile roll 03-07. A major psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "major" }
  - name: "Psionics (08-15): Minor Psionic"
    description: "Percentile roll 08-15. A minor psionic. The entry prints no power count, no categories and no I.S.P. for the tier, so take them from the psionics rules in use and record powers and I.S.P. by hand."
    psionics: { type: "minor" }
  - name: "Psionics (16-00): None"
    description: "Percentile roll 16-00. No psionic powers, like most Larmac. This table stands in place of the standard psionics roll."
trackable_resources: []
restrictions:
  - "Alignment: any, but the majority are Unprincipled (30%), Anarchist (30%), Aberrant (10%) or Miscreant (20%)."
  - "Available O.C.C.s: typically one of Bandit, Thief, Gambler, Highway Man, Sailor, Pirate, Grunt (thug/muscleman), Saloon Bum, Barmaid (if female), Saddle Tramp, Stoolie or Vagabond; only the most ambitious become a Wilderness Scout, Trapper-Woodsman, Professional Gambler, Pecos Raider, Merc Soldier or Sheriff''s Deputy. Can NOT select most Men at Arms or psionic O.C.C.s, including the Mystic."
  - "Magic: none; too lazy to study it, though they love magic items."
  - "Cybernetics: most avoid them, but may take minor implants and bionic prosthetics to repair injuries; human systems must be modified and always look mechanical. Bio-Systems are out of the question."
side_effects: "-1 on initiative unless highly motivated, and always -3 to save vs illusions. Hand to hand skill is rarely better than Basic. Many are addicted to Psi-Cola (an estimated 25-30% by 109 P.A.)."
extraction_notes: "WB30 D-Bees of North America printed 118-120 (cache p119-p121), every number read off 200 dpi renders; the entry ends at its Note on printed 120, above the Loaks heading (the brief gave 118-119; the stat block continues onto 120). A reprint: the Note says it first appeared in Coalition Wars Three: Sorcerers'' Revenge; not held, imported from here. TAG LINE: the heading reads only Larmac R.C.C.; no Optional Player Character or NPC line is printed. || CATEGORY: a race that takes an O.C.C.; Standard Equipment and Money As per O.C.C. No xp_table: the entry says to use the experience table of the chosen O.C.C. || POOLS: Mega-Damage printed 5D6 plus P.E. attribute number and +2D4 M.D.C. per level, stored as mdc_base, so no men_of_arms line. The S.D.C.-world figures are ability text. P.P.E. 1D6. Horror Factor 12. || ATTRIBUTES as printed; P.S. 4D6+16 Robot Strength (ability text). || BONUSES: +5 save vs Horror Factor; +6 to save vs poison, disease and drugs (printed under Natural Abilities) as toxins_poisons, disease and harmful_drugs; -3 to save vs illusions as saves.other (always, printed under Vulnerabilities). The +1 attack, +1 initiative and +1 parry or dodge when highly motivated are conditional, and so is the -1 initiative unless highly motivated: both are prose. || SKILLS: Cook 35+20, Land Navigation 36+20, Wilderness Survival 30+20, W.P. Blunt, in addition to an O.C.C. || PSIONICS: percentile table, stored since 2026-10-03 as a banded choose-1 group of four options in special_abilities, one per printed band; no class-level block (most Larmac have none), and the tiers carry a type only because the page prints no powers or I.S.P. for them. || OCCUPATIONS: a typical list plus a vague bar on most Men at Arms and psionic O.C.C.s; not stored as occ_restrictions (judgement), kept as a restriction line. || NOT STORED: size 6 to 7 feet, weight 250 to 500 lbs, life span 5D6+90, the 40-70 M.D.C. patchwork armor most wear (no stats beyond M.D.C.), habitat, allies and enemies; GM Notes. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. D-Bees of North America printed 120 says to roll on its own table to determine whether a character has psionics, with its own No Psionics band at 16-00."
---

## Lore

The Larmac are big, beefy D-Bees who look like giant horned toads: rough,
blotchy tan or greenish gray skin, a pair of small horns on top of the head
and two more behind, ear holes, small eyes, a long muzzle and a mouth of
jagged teeth. For all that, they are mammals, and the males are hairy.

They are reasonably smart and very strong, and could be fearsome warriors,
but most are cheerfully lazy. A typical Larmac wants to eat, drink, party,
gamble and sleep, and does only as much work as that takes, which often
means scavenging, panhandling, petty crime, muscle work or simply sponging
off friends. They are hard to insult and slow to anger, but when one
finally gets up, expect a serious fight. Dangle the promise of a big score
or easy street, though, and a Larmac will work hard, stay awake for days
and fight to the death for it. Good-hearted ones are fiercely loyal
friends; the anarchist and evil ones will sell anyone out for a payday.

## GM Notes

The book prints the heading as Larmac R.C.C., with no player character
line. Also called Lard Butts, Lazy Lards and Lazy Lizards.

Size 6 to 7 feet (1.8 to 2.1 m). Weight 250 to 500 pounds (112.5 to 225
kg), looking 40% to 100% overweight. Life span 5D6+90 years; physical
maturity by 17. Females bear litters of 1D4+1 after a 12 month pregnancy.

Most wear patchwork homespun M.D.C. armor of 40 to 70 M.D.C. with no
environmental systems. They like blunt weapons, heavy weapons, energy
weapons and explosives.

Habitat: from the St. Louis and Detroit-Windsor Rifts across lower Canada,
the Pecos Empire and the central and eastern old United States, in cities,
slums and the ''Burbs. Many Tolkeen refugees among them have sobered up and
some joined the resistance.

Allies: humans, Floopers, D''norr Devilmen, Kraks and anyone easygoing.
Enemies: the Coalition States, the Federation of Magic, Greot Hunters and
Vanguard Brawlers; they dislike know-it-alls, driven go-getters, tyrants
and slavers.
',
       updated_at = datetime('now')
 WHERE class_id = 'larmac'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 8078;

-- == mutant-rat ==
UPDATE imported_classes
   SET markdown = '---
id: mutant-rat
name: Mutant Rat
system: rifts
source_book: Rifts World Book 13: Lone Star p.85-88
category: rcc
psionics_allowed: false
tags: [stealth]
xp_table: [0, 1901, 3601, 7201, 14401, 24501, 35001, 45001, 65001, 85001, 115001, 145001, 185001, 250001, 310001]
attribute_dice:
  IQ: "2d6+6"
  ME: "2d6"
  MA: "2d6"
  PS: "3d6"
  PP: "2d6+8"
  PE: "3d6"
  PB: "2d6"
  Spd: "4d6+6"
hit_points_base: "P.E. + 1d6 per level"
sdc_base: "P.E. + 4d6"
ppe_base: "3d6"
bonuses:
  combat: { attacks: 1, initiative: 3, dodge: 1, pull_punch: 1, roll: 2 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "The book prints: speaks American at 90% efficiency." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Escape Artist", base: 50, per_level: 5, note: "+20%" }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Pick Locks", base: 40, per_level: 5, note: "+10%" }
    - { name: "Pick Pockets", base: 35, per_level: 5, note: "+10%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Sniper", base: 0, per_level: 0 }
    - { name: "Climbing", base: 85, per_level: 5, note: "Natural ability: the book prints Climb 85%/80%." }
    - { name: "Swimming", base: 75, per_level: 5, note: "Natural ability: the book prints Swim 75%." }
    - { name: "Prowl", base: 60, per_level: 2, note: "Natural ability: the book prints Prowl 60% +2% per level of experience." }
    - { name: "W.P. Knife", base: 0, per_level: 0, note: "W.P. Knife (Vibro-Blade)." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P.: one of choice." }
    - { name: "Hand to Hand: Assassin", base: 0, per_level: 0 }
  occ_related_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 5 }
      - "Physical"
      - { name: "Pilot", only: ["Hover Craft (ground)", "Truck", "Boat: Sail Type", "Boat: Motor, Race & Hydrofoil"], bonus: 5 }
      - { name: "Rogue", except: ["Computer Hacking"], bonus: 10 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"], bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "The book calls these other skills. Electrical: Basic Electronics only. Espionage +10%. Mechanical: Basic Mechanics and Automotive only. Medical: First Aid only. Military +5%. Pilot: Hovercraft, truck, sail and motorboats only (+5%). Pilot Related and Science: none. Rogue: any except Computer Hacking (+10%). Technical: any except Computer Operation and Programming (+10%). Wilderness +5%. Mutant rats in the service of the CS are never taught to read."
    schedule:
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - "Physical"
      - { name: "Pilot", only: ["Hover Craft (ground)", "Truck", "Boat: Sail Type", "Boat: Motor, Race & Hydrofoil"] }
      - { name: "Rogue", except: ["Computer Hacking"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule:
      - { level: 2, count: 2 }
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
equipment_starting:
  - { item_id: "dog-pack-dpm-riot-armor", qty: 1, note: "DPM riot armor. Full environmental suits are never available." }
  - { choose: 1, label: "tinted goggles or non-environmental helmet", qty: 1, from: ["tinted-goggles", "helmet"], note: "The helmet comes with or without a visor." }
  - { item_id: "walkie-talkie", qty: 1, note: "The book says a radio." }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "lightweight-rope", qty: 5, note: "100 ft (30.5 m) of lightweight rope; the catalog row is a 20 foot length." }
  - { item_id: "spike", qty: 4 }
  - { item_id: "small-hammer", qty: 1, note: "Four spikes and a hammer." }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { choose: 1, label: "pair of Vibro-Knives and/or Vibro-Claws", qty: 2, from: ["vibro-knife", "vibro-claws"], note: "The book prints a pair of Vibro-knives and/or Vibro-claws." }
  - { item_id: "c-12-laser-rifle", qty: 1, note: "C-12 assault laser rifle." }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "canteen", qty: 1 }
natural_abilities:
  - { name: "Size and Build", description: "About 5 feet (1.5 m) tall and 120 to 160 pounds (54 to 72 kg). No human looks: an animal''s appearance with only a vaguely human, bipedal shape and a rat-like head. 85% have human legs, arms and builds, 15% have animal-like legs; all have a long, hairless tail, and most are thin and wiry. The hands are fully articulated with an opposable thumb and long, sharp nails. Stands and walks upright. Armor Rating: not applicable. Reduce Spd by 30% when climbing. Human speech is typically full but a bit guttural, with hissing, growling and squealing when excited, angry or scared. Reaches full physical maturity within one year; life span an estimated 20 to 30 years." }
  - { name: "Climb, Swim and Prowl", description: "Climb 85%/80%, Swim 75%, Prowl 60% +2% per level of experience." }
  - { name: "Identify Scents", description: "44% +2% per level of experience." }
  - { name: "Track by Scent", description: "40% +2% per level of experience." }
  - { name: "Leap", description: "6 feet (1.8 m) up and 10 feet (3 m) across; increase lengthwise leaps by 30% with a running or swing start." }
  - { name: "Bite, Claws and Blows", description: "Bite 2D6 S.D.C./H.P.; claw strike (with fingernails) 2D4 S.D.C.; punch 1D6; kick 2D6." }
  - { name: "Tail", description: "The tail is not like prehensile feet." }
  - { name: "Double Jointed", description: "The rat is double jointed." }
  - { name: "Ambidextrous", description: "The rat is ambidextrous." }
  - { name: "Combat Bonuses", description: "+1 attack per melee round, +3 on initiative, +1 to dodge, +1 to pull punch and +2 to roll with fall or impact, plus any skill bonuses." }
  - { name: "Gnawing", description: "Rats and most rodents must chew on wood, concrete or metal to wear down their ever growing teeth; otherwise the fangs grow through the jaws." }
  - { name: "Psionics", description: "01-25%: the rat is a minor psionic and selects four powers from the Sensitive category. 26-00%: no psionics. The entry prints no I.S.P. figure." }
special_abilities:
  - { choose: 1, from: ["Psionics (01-25): Minor Psionic", "Psionics (26-00): None"], note: "Psionics (printed 88): roll percentile dice or pick one. The book prints the 01-25 band only; 26-00 is what it leaves." }
  - name: "Psionics (01-25): Minor Psionic"
    description: "Percentile roll 01-25. A minor psionic who selects four powers from the Sensitive category. The entry prints no I.S.P. figure, so the G.M. sets one and it is recorded by hand."
    psionics:
      type: "minor"
      powers_starting: 4
      categories_allowed: ["Sensitive"]
  - name: "Psionics (26-00): None"
    description: "Percentile roll 26-00. No psionic powers. The book prints no band for this result: it is the remainder after 01-25. This table stands in place of the standard psionics roll."
trackable_resources: []
restrictions:
  - "Psionics: only 25% of mutant rats (01-25%) are psionic; those are minor psionics with four Sensitive powers."
  - "Magic: none. The study of magic does not appeal to mutant rats, although they like magic items and weapons."
  - "Mutant rats in the service of the CS are never taught to read."
  - "Money: no starting sum is printed. The CS military provides all basic needs (a place to sleep, food, clothing, medical treatment, basic supplies and equipment, limited access to military facilities) and a token monthly salary of 50-70 credits for personal items. Rats do not get the freedoms, privileges or trust given to Dog Boys."
  - "Full environmental suits are never available. Equipment on assignment is basically the Dog Boys'', but heavy weapons, explosives, environmental armor, vehicles and special equipment are much more limited and restricted to mutants with at least two years of proven service."
  - "Cybernetics: none."
  - "Maximum rank: non-commissioned officer up to Sergeant."
  - "Escaped rats can learn a number of new secondary skills. A free-born rat can select any adventurer or men of arms O.C.C., but halves that O.C.C.''s selection of other skills."
  - "A player character who is not a CS agent (spy, infiltrator, scout, soldier) is a feral renegade (a runaway or deserter, treated as a dangerous traitor to be terminated) or the free-born offspring of runaways (destroyed whenever encountered). Any rat that goes AWOL or feral is hunted down and destroyed."
  - "Alignment: any, but anarchist (30%), miscreant (30%) and diabolic (30%) are the most common."
  - "R.C.C. requirements: none, other than being a relatively intelligent, loyal and obedient mutant (60% are female); substandard creations are destroyed."
extraction_notes: "WB13 Lone Star printed 85-88 (cache p086-p089, cache page = printed folio + 1). The Mutant Rodents heading and the Mutant Rats heading are in the right column of printed 85, after the end of the Monkey Boy Tech; the lore runs through 86 to the top of 87; the stat block is headed CS Mutant Rats on 87 and runs through the left column and the top of the right column of 88, ending at Maximum Rank, above the Mutant Bats heading. Every number was read off 170 dpi renders of cache p086-p089. || XP: the column headed Mutant Bat, Mutant Rat on the unnumbered Experience Tables page after printed 174 (cache p176), read off the render, lower bound of each band. || HEADING: CS Mutant Rats, under Mutant Rodents / Mutant Rats; an engineered mutant animal and a race. The Experience Tables index on printed 174 calls it Mutant Rat R.C.C. 85. || ATTRIBUTES as printed (Average Attribute Range, Typical Mutant Rat): I.Q. 2D6+6, M.E. 2D6, M.A. 2D6, P.S. 3D6, P.P. 2D6+8, P.E. 3D6, P.B. 2D6, Spd 4D6+6 running (reduce by 30% when climbing, text). || POOLS: Hit points P.E. plus 1D6 per level. S.D.C. is printed as ''P.E. attribute number plus 4D6 plus those gained from physical skills''. Stored as sdc_base ''P.E. + 4d6'' and NOT as bonuses.pools.sdc, the convention of the sibling Lone Star drafts for a printed formula that contains the P.E. number; because sdc_base is stated there is no men_of_arms line. P.P.E. 3D6 (Permanent P.P.E. Base). Armor Rating: not applicable. || BONUSES (natural abilities, top of printed 88): +1 attack per melee round, +3 initiative, +1 dodge, +1 pull punch, +2 roll with fall or impact; stored in bonuses.combat and restated as natural ability text. || NATURAL ABILITIES: Climb 85%/80% is stored as Climbing 85 with the catalog''s 5% per level (the book prints no per level figure for it; judgement, as the battle-cat draft), the second figure in the note. Swim 75% is Swimming 75 with the catalog''s 5% per level (none printed). Prowl 60% +2% per level is Prowl 60, per_level 2, as printed. None of the three is in the printed R.C.C. skill list; they are stored as skills because the natural abilities print them as percentages. Identify scents 44% +2% and track by scent 40% +2% are natural ability text. Damage as printed: bite 2D6 S.D.C./H.P., claw 2D4 S.D.C., punch 1D6, kick 2D6. || PSIONICS: ''01-25% are minor psionics; select four sensitive powers''. A percentile chance, so no class-level psionics block is stored; since 2026-10-03 it is a banded choose-1 group in special_abilities (01-25 minor with four Sensitive picks, and a 26-00 None the book leaves unprinted), and the line stays as natural ability text and a restriction. The entry prints no I.S.P. figure and none is stored. || SKILLS: Speaks American at 90% is Language: Native Tongue 90, per_level 0. Radio: Basic 45+10 = 55. Escape Artist 30+20 = 50. Intelligence 32+10 = 42. Pick Locks 30+10 = 40. Pick Pockets 25+10 = 35. Land Navigation 36+20 = 56. Wilderness Survival 30+10 = 40. Sniper, W.P. Knife (Vibro-Blade), W.P. Energy Rifle, one W.P. of choice. Hand to Hand: Assassin is granted outright; no change or price is printed, so no hand_to_hand block. || RELATED: four at level one, plus one at levels 3, 6, 9 and 12. Communications, Domestic, Physical and W.P. any; Electrical Basic Electronics only; Espionage any +10; Mechanical Basic Mechanics and Automotive only; Medical First Aid only; Military any +5; Pilot hovercraft, truck, sail and motorboats only +5 (Hover Craft (ground), Truck, Boat: Sail Type, Boat: Motor, Race & Hydrofoil); Pilot Related none; Rogue any except Computer Hacking +10; Science none; Technical any +10 except Computer Operation and Computer Programming; Wilderness any +5. ''Never taught to read'' applies to rats in CS service and is a restriction line, not an exclusion. SECONDARY: six at level one plus TWO at each of levels 2, 4, 8 and 12, same lists without bonuses. || FREE-BORN: the skills paragraph says escaped rats can learn new secondary skills and free-borns can select any adventurer or men of arms O.C.C. with the selection of other skills halved; stored as a restriction line. || EQUIPMENT: ''basically the same as Dog Boys, although full environmental suits are never available'', then the entry prints its own basic list, which is what is stored: DPM riot armor (dog-pack-dpm-riot-armor), tinted goggles or non-environmental helmet, radio as walkie-talkie, flashlight, pocket mirror, 100 ft of lightweight rope as five 20 ft lengths, four spikes and a hammer, portable language translator, survival knife, a pair of Vibro-knives and/or Vibro-claws as a choice at qty 2, C-12 assault laser rifle (c-12-laser-rifle), knapsack, backpack, utility belt, air filter, gas mask, canteen. The printed comb is a trivial personal item with no catalog row and is NOT stored. Equipment available upon assignment is a restriction line. || MONEY: the entry prints only a token monthly salary of 50-70 credits with all basic needs provided by the CS military, and no starting sum; it says rats do not have the Dog Boys'' freedoms, privileges or trust. No starting_money is stored; the salary is a restriction line. || OPTIONAL DOG BOY TABLES: the entry says nothing about them; nothing stored. || Identification coding (the Dog Boys'' dual I.D. system), typical missions (reconnaissance, undercover, extortion, espionage, intelligence), litter size (3D4 young), the desertion rate and the Rift escape are lore. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Lone Star printed 88 prints the entry''s own Psionics line: 01-25 are minor psionics with four sensitive powers; the remainder is read as none."
---

## Lore

The mutant rat was the Lone Star complex''s attempt at a cheap, fast-breeding
army: a wiry, five foot rodent with a long bare tail that is fully grown in a
year. The plan was to throw them at an enemy in swarms ahead of the real
troops. The rats worked out what they were for almost at once, and have
despised their makers ever since.

They are sharp, adaptable and thoroughly self-interested. A rat will join a
pack, swear loyalty and then sell the pack out to save its skin or turn a
profit. In numbers they grow loud, reckless and cruel; alone they are careful
survivors with an eye on the next deal. They want rank, fame and above all
wealth, and army life offers none of it, so they desert more than any other
mutant.

The Coalition has written the experiment off. Most rats were destroyed, a few
hundred were sterilized and kept as spies, infiltrators and assassins attached
to special units, and the ones that escaped through a freak Rift now infest the
complex''s lower levels and the Pecos Badlands. Feral rats are killed on sight.

## GM Notes

A rat in Coalition service is watched constantly and trusted by nobody: it has
no starting money, only a token 50-70 credits a month, is never taught to
read, never gets a full environmental suit and tops out at Sergeant.

Roll percentile for psionics at creation: only 01-25% are minor psionics, with
four Sensitive powers; the book gives no I.S.P. figure, so the G.M. sets one.

A character outside CS service is a feral deserter or a free-born. A free-born
may take an adventurer or men of arms O.C.C. at half its other-skill
selections. Either kind is hunted by Dog Packs and mutant cats.
',
       updated_at = datetime('now')
 WHERE class_id = 'mutant-rat'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 17034;

-- == momano-headhunter ==
UPDATE imported_classes
   SET markdown = '---
id: momano-headhunter
name: Momano Headhunter
system: rifts
source_book: Rifts World Book 20: Canada p.122-126
category: occ
psionics_allowed: false
tags: [combat, hunter, augmented, scholar]
occ_group: men-of-arms
men_of_arms: true
xp_table: [0, 2151, 4301, 8601, 17201, 25501, 36001, 52001, 73001, 98001, 134001, 184001, 240001, 295001, 385001]
attribute_requirements: { IQ: 10, ME: 12, PE: 12 }
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d4x100"
bonuses:
  pools: { sdc: "2d6+4" }
  combat: { initiative: 1 }
  saves: { horror_factor: 1 }
  at_level:
    - { level: 2, saves: { possession: 1, illusionary_magic: 1 } }
    - { level: 3, combat: { initiative: 1 }, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1, possession: 1, illusionary_magic: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, combat: { initiative: 1 }, saves: { horror_factor: 1, possession: 1, illusionary_magic: 1 } }
    - { level: 8, saves: { horror_factor: 1, possession: 1, illusionary_magic: 1 } }
    - { level: 9, combat: { initiative: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, combat: { initiative: 1 }, saves: { horror_factor: 1, possession: 1, illusionary_magic: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
    - { level: 15, saves: { possession: 1, illusionary_magic: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "anarchist or evil alignment" } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 80, per_level: 1, note: "Language: Native (80% +1% per level of experience)." }
    - { name: "Language: Demongogian", base: 70, per_level: 2, note: "70% +2% per level of experience." }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "Language: one of choice (+15%)." }
    - { choose: 2, from: ["Literacy", "Literacy: Native Language", "Literacy: Other", "Literacy: Dragonese/Elven", "Literacy: Euro", "Literacy: Gypsy", "Literacy: Russian"], bonus: 15, note: "Literacy: choose two (+15%)." }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: Demon & Monster (+20%)." }
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "Lore: Magic & Ley Lines (+15%)." }
    - { choose: 1, from: ["Lore: American Indians", "Lore: Astral", "Lore: Cattle & Animals", "Lore: Cities", "Lore: D-Bee", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: General Law", "Lore: Juicers", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Aborigines", "Lore: Dreamtime Culture", "Lore: History of Russia", "Lore: Wormwood"], bonus: 10, note: "Lore: one of choice (+10%)." }
    - { choose: 1, from: ["Art", "Whittling & Sculpting", "Creative Writing", "Dance", "Sing"], bonus: 15, note: "Pick one: Art, Sculpting, Writing, Dance or Sing (+15%)." }
    - { choose: 1, from: ["Play Musical Instrument", "Photography", "Botany", "Astronomy"], bonus: 15, note: "Pick one: Play Musical Instrument, Photography, Botany or Astronomy (+15%)." }
    - { name: "Mathematics: Basic", base: 60, per_level: 5, note: "Basic Math (+15%)." }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Computer Operation", base: 50, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 40, per_level: 5, note: "Tracking: Humanoids (+15%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Sensory Equipment", "Optic Systems"], bonus: 10, note: "Read Sensory Equipment (+10%) or Optic Systems (+15%); choose one. The sheet adds +10% to either: add 5% more by hand if Optic Systems is taken." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot: one of choice (+10%)." }
    - { name: "W.P. Sword", base: 0, per_level: 0, note: "Includes Vibro-Blades." }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Expert can be changed to Martial Arts or Assassin (if anarchist or evil alignment) at the cost of one O.C.C. Related skill." }
  occ_related_skills:
    count: 2
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Cowboy", only: ["Lore: American Indians", "Lore: Cattle & Animals"], bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5 }
      - "Medical"
      - { name: "Military", bonus: 5 }
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - { name: "Science", bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Select two other skills at levels 1, 4, 10 and 15. A psychic Momano selects half as many. Communications: any (+5%; +10% to Performance). Cowboy: Lore: Indians and Lore: Cattle/Animals (+10%) only. Domestic: any (+10%). Electrical: Basic only. Espionage: none. Mechanical: Basic and Automotive (+5%) only. Medical: any. Military: any (+5%). Physical: any. Pilot: any (this book files horsemanship under Pilot). Pilot Related: any. Rogue: none. Science: any (+5%). Technical: any (+10%). W.P.: any, including Paired Firearms and Sharpshooting from Rifts New West, but each of those two counts as two O.C.C. Related skills. Wilderness: any (+5%)."
    schedule:
      - { level: 4, count: 2 }
      - { level: 10, count: 2 }
      - { level: 15, count: 2 }
  secondary_skills:
    count: 3
    categories:
      - "Communications"
      - { name: "Cowboy", only: ["Lore: American Indians", "Lore: Cattle & Animals"] }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - "Medical"
      - "Military"
      - "Physical"
      - "Pilot"
      - "Pilot Related"
      - "Science"
      - "Technical"
      - { name: "Weapon Proficiencies", except: ["W.P. Paired Weapons", "W.P. Sharpshooting"] }
      - "Wilderness"
    note: "A total of three Secondary Skills from the same list, limited by its categories and without the bonuses in parentheses. A psychic Momano takes half as many. The two New West skills (Paired Firearms, Sharpshooting) cannot be taken as Secondary Skills."
special_abilities:
  - { choose: 1, from: ["Psionics (01-50): None", "Psionics (51-70): Minor Psychic", "Psionics (71-90): Major Psychic", "Psionics (91-95): Burster or Zapper", "Psionics (96-98): Nega-Psychic", "Psionics (99-00): Mind Melter"], note: "Random Determination of Psionics (printed 124): roll percentile dice or, if the G.M. authorizes it, pick one." }
  - name: "Psionics (01-50): None"
    description: "No psionics whatsoever. P.P.E. base for a non-psychic is 2D6+6, +2 per level of experience; the sheet rolls the 2D6+6 and the +2 per level is added by hand. P.P.E. powers any Techno-Wizard bionics."
    bonuses: { pools: { ppe: "2d6+6" } }
  - name: "Psionics (51-70): Minor Psychic"
    description: "A Minor Psychic, with a base P.P.E. of 1D6; I.S.P. operates any Techno-Wizard bionics. This book prints no power count and no I.S.P. formula for the tier, so record powers and I.S.P. by hand from the psionics rules in use. Duration, range and damage of the powers are halved for any psychic carrying over three implants or one bionic limb (bio-systems aside), and full or near-full conversion wipes them out. O.C.C. Related and Secondary Skills are halved: one related skill at levels 1, 4, 10 and 15."
    psionics: { type: "minor" }
    bonuses: { pools: { ppe: "1d6" } }
    related_skills_count: 1
  - name: "Psionics (71-90): Major Psychic"
    description: "A Major Psychic, with a base P.P.E. of 1D6; I.S.P. operates any Techno-Wizard bionics. This book prints no power count and no I.S.P. formula for the tier, so record powers and I.S.P. by hand from the psionics rules in use. Duration, range and damage of the powers are halved for any psychic carrying over three implants or one bionic limb (bio-systems aside), and full or near-full conversion wipes them out. O.C.C. Related and Secondary Skills are halved: one related skill at levels 1, 4, 10 and 15."
    psionics: { type: "major" }
    bonuses: { pools: { ppe: "1d6" } }
    related_skills_count: 1
  - name: "Psionics (91-95): Burster or Zapper"
    description: "The psychic abilities of a Burster or a Zapper (see Rifts Psyscape), with the Momano skills rather than that class''s own. Base P.P.E. 1D6. Record the powers and I.S.P. by hand; nothing but the P.P.E. is applied. Duration, range and damage are halved by over three implants or by one bionic limb, and full or near-full conversion wipes the powers out. O.C.C. Related and Secondary Skills are halved: one related skill at levels 1, 4, 10 and 15."
    bonuses: { pools: { ppe: "1d6" } }
    related_skills_count: 1
  - name: "Psionics (96-98): Nega-Psychic"
    description: "The abilities of a Nega-Psychic (see Rifts Psyscape), with the Momano skills rather than that class''s own. Base P.P.E. 1D6. Record the abilities by hand; nothing but the P.P.E. is applied. Duration, range and damage are halved by over three implants or by one bionic limb, and full or near-full conversion wipes the powers out. O.C.C. Related and Secondary Skills are halved: one related skill at levels 1, 4, 10 and 15."
    bonuses: { pools: { ppe: "1d6" } }
    related_skills_count: 1
  - name: "Psionics (99-00): Mind Melter"
    description: "The rarest and strongest Momano, a hybrid Master Psionic. Has every special Mind Melter O.C.C. psi-ability, that class''s initial I.S.P. and its level one powers, but: all O.C.C. bonuses are half, the I.S.P. gained at each new level is half, and new powers come at only one lesser power for each experience level, or a single Super-Psionic power per two levels. Techno-Wizard bionics cost 30% more P.P.E. or I.S.P. to use, at half range and duration. Base P.P.E. 1D6. Record powers and I.S.P. by hand from the Mind Melter class; the halved O.C.C. bonuses are not applied by the sheet. O.C.C. Related and Secondary Skills are halved: one related skill at levels 1, 4, 10 and 15."
    psionics: { type: "master" }
    bonuses: { pools: { ppe: "1d6" } }
    related_skills_count: 1
  - { name: "Techno-Wizard Bionics", description: "Unlike other Headhunters the Momano uses Techno-Wizard devices, including TW bionic weapons built into a bionic limb (printed 126-129), powered by P.P.E. or I.S.P. A typical Momano (70%) keeps to no more than seven implants, 2-4 bionic features and one bionic limb, and uses them at full effect. A partially reconstructed Momano (about 30%: 8-12 implants or features and two bionic limbs) pays 30% more P.P.E. or I.S.P. at half range and duration; any more bionics than that prevents their use. Each bionic limb holds four weapons or features in total and can mix conventional and TW systems." }
equipment_starting:
  - { item_id: "knife-silver-plated", qty: 2, note: "A pair of silver daggers." }
  - { item_id: "vibro-sword", qty: 1, note: "Silver plated." }
  - { item_id: "wooden-stake", qty: 12, note: "A dozen wooden stakes." }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-silver-cross", qty: 1, note: "A silver cross." }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "clothing", qty: 2, note: "Two sets of street clothes." }
  - { item_id: "portable-tool-kit", qty: 1 }
  - { item_id: "hand-held-computer", qty: 1, note: "PC-3000 hand-held computer." }
  - { item_id: "portable-language-translator", qty: 1 }
  - { item_id: "pdd-pocket-audio-digital-disc-recorder-player", qty: 1, note: "The text layer reads FDD; the page prints PDD pocket audio recorder/player." }
  - { item_id: "pocket-laser-distancer", qty: 1 }
  - { item_id: "field-radio", qty: 1 }
  - { item_id: "pocket-flashlight", qty: 1 }
  - { item_id: "pocket-or-signal-mirror", qty: 1 }
  - { item_id: "rmk-robot-medical-kit-or-knitter", qty: 1 }
  - { item_id: "irmss-internal-robot-medical-surgeon-system", qty: 1 }
  - { item_id: "tinted-goggles", qty: 1 }
  - { item_id: "hatchet", qty: 1, note: "For cutting wood." }
  - { item_id: "knapsack", qty: 1 }
  - { item_id: "tent", qty: 1 }
  - { item_id: "backpack", qty: 1, note: "Backpack or NG-S2 survival pack." }
  - { item_id: "saddlebags", qty: 1, note: "Saddle bags or containers." }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "duffle-bag", qty: 1, note: "One large satchel or duffle bag." }
  - { item_id: "small-sack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "food-rations", qty: 3, note: "Three weeks of freeze-dried combat rations." }
trackable_resources: []
restrictions:
  - "Attribute requirements: I.Q. 10, M.E. 12 and P.E. 12 or higher, and a P.P.E. of 8 or higher and/or I.S.P. from at least minor psychic abilities. A high M.A., P.S. and P.P. help but are not mandatory."
  - "Hand to Hand: Assassin requires an anarchist or evil alignment."
  - "A psychic Momano selects half the O.C.C. Related and Secondary Skills."
  - "Psionic powers lose half their duration, range and damage with over three implants or one bionic limb (bio-systems aside), and are lost entirely to full or near-full bionic conversion."
  - "Techno-Wizard bionics need a low level of bionics: over two bionic limbs or 12 implants and features prevents their use."
  - "Mode of transportation: starts with none."
extraction_notes: "WB20 Canada printed 122-126 (cache p123-p127, cache page = printed folio + 1), read off the text layer; the bonuses and psionics block on printed 124 and the Money line on printed 125 were checked against renders. Headhunters Defined, printed 107-109, read for the common rules; it prints no shared stat block. || GROUP: Headhunters Defined calls all Headhunters men of arms; occ_group men-of-arms, men_of_arms true. The class prints +2D6+4 to S.D.C. as a bonus and no base, stored in bonuses.pools. No alignment line is printed for the class; not tagged evil. || XP: the Momano Headhunter ladder on the Experience Tables, printed 192, read off a render by the importing session. || BONUSES (printed 124): +1 initiative at levels 1, 3, 6, 9 and 12; +1 vs Horror Factor at levels 1, 3, 4, 5, 6, 8, 10, 12 and 14; +1 vs possession and illusions at levels 2, 4, 6, 8, 12 and 15, the illusions half stored as illusionary_magic. || REQUIREMENTS: I.Q. 10, M.E. 12, P.E. 12 stored; the P.P.E. 8 and/or I.S.P. requirement is in restrictions. || PSIONICS: the book rolls one of six outcomes (01-50 none, 51-70 Minor, 71-90 Major, 91-95 Burster or Zapper, 96-98 Nega-Psychic, 99-00 Mind Melter); stored as a pick-one special_abilities group with no class-level psionics block. Minor, Major and Mind Melter carry a psionics type only (the Mind Melter text prints Master Psionic). The book prints NO power count and NO I.S.P. formula for any tier and sends the reader to Rifts Psyscape, so none is stored. Burster or Zapper and Nega-Psychic carry no psionics block: the book names another class and prints no tier. The Mind Melter half O.C.C. bonuses, half I.S.P. per level and one lesser power per level or one Super every two levels are in the option text only. || P.P.E.: non-psychic 2D6+6 +2 per level, psychic 1D6; stored as a pool bonus on each option, so the non-psychic +2 per level is NOT stored. No class-level ppe_base. || SKILLS HALVED: a psychic halves O.C.C. Related and Secondary Skills; each psychic option carries related_skills_count 1, which halves the level-one picks only. The later grants (two at levels 4, 10 and 15) and the three Secondary Skills are not halved by the sheet; the book does not say how to round half of three. || SKILL READINGS: Language: Native is Language: Native Tongue at 80 +1; Lore: Magic & Ley Lines is Lore: Magic; Tracking: Humanoids is Tracking (people); Read Sensory Equipment is Sensory Equipment; Sculpting is Whittling & Sculpting; Writing is Creative Writing; Basic Math is Mathematics: Basic. The Lore pick lists the catalog Lore rows other than the two granted. Read Sensory Equipment (+10%) or Optic Systems (+15%) is one pick stored at +10; the Optic Systems extra 5 is in the note. Communications is +5 with Performance at +10; the Performance extra 5 is in the note only. Cowboy Lore: Indians is Lore: American Indians and Lore: Cattle/Animals is Lore: Cattle & Animals. Electrical Basic is Basic Electronics; Mechanical Basic and Automotive are Basic Mechanics and Automotive Mechanics. This book files horsemanship under Pilot (the Angakoq list, printed 183, says Pilot Skills: Sail Boat and Horsemanship only); Pilot: any is stored with Horsemanship: General and Exotic Animals beside the Pilot category. Paired Firearms and Sharpshooting from New West count as two related skills each and are barred as Secondary Skills; the catalog rows W.P. Paired Weapons and W.P. Sharpshooting are excepted from the secondary list, and the double cost is in the note. || MONEY: 1D4x100 credits (text layer !D4xlOO, confirmed on a render) is starting_money; the 1D6x1000 in black market items (text layer !D6xlOOO, confirmed on a render) is goods, in GM Notes. || EQUIPMENT: NOT stored as rows, in GM Notes: one weapon per W.P. with five reloads, the squirtgun (no catalog row), the full suit of personalized environmental M.D. armor of any kind, the black jumpsuit, the NG-S2 survival pack alternative, and personal items. The text layer reads FDD pocket audio recorder/player; a render of cache p125 (doc[124], dpi 150 plus a 300 dpi crop) shows the page prints PDD, and it is stored as the PDD pocket audio recorder/player row. CYBERNETICS (printed 125): the book lists these under Most Momano have the following, so none of them is a fixed grant and none is stored as an equipment row. That includes the Clock Calendar and Gyro-Compass, which do have catalog rows (cyber-clock-calendar, cyber-gyro-compass) but stand in the same list as cybernetics that are not stored. All are named in GM Notes: the Multi-Optics Eye, Bionic Lung with Toxic Filter and Storage Cell, sensor hand or forearm, Clock Calendar, Gyro-Compass, the one bionic limb with two weapons or features and the 3-5 other implants. The optional weapon modifications (printed 125-126) and Techno-Wizard bionics (printed 126-129) are purchases, not starting gear; their catalog rows are named in GM Notes. || trackable_resources: none printed for the class itself. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. Canada printed 124 heads its own Random Determination of Psionics, whose first band is no psionics whatsoever; a Burster, Zapper or Nega-Psychic result is a psychic by that table, not by a second roll."
---

## Lore

The Momano, or Devil Hunters, are the Headhunters who make the supernatural
their trade. The name is borrowed from Japanese, and the people who carry it
track, fight and destroy demons, monstrous D-Bees and creatures of magic,
which they call "soupies". They turn up as demon slayers and cocky guns for
hire in the most hostile corners of the continent: Calgary, the Magic Zone,
the ruins of Windsor and Detroit, and the old borderlands between the northern
United States and southern Canada.

Where most Headhunters distrust magic, the "Moes" study it. They understand
its principles, recognise possession, charms, illusions, enchantments and ley
line storms when they see them, and fight their quarry with Techno-Wizard
devices, including TW weapons built into their own bionics. Roughly half have
some psychic gift, which also serves to power those devices.

They are scholars as much as soldiers. A Momano''s first job is to know the
enemy, so they read up on the paranormal, on places of power and on old
Eastern philosophy, and many keep a quiet passion for an art, for poetry, for
plants or for a board game. They hold knowledge, history and honour in high
regard and do not betray a friend or a sworn word, whatever the threat.

That mix sets them apart. Other fighting men find them odd, and plenty of
ordinary folk think them a little mad: who else walks out smiling and joking
to meet something unspeakable?

## GM Notes

Psionics: roll percentile (or pick, with the G.M.''s leave) on the table the
sheet offers as a choice. This book prints no power counts or I.S.P. for the
tiers and points to Rifts Psyscape, so powers and I.S.P. are recorded by hand.
A psychic Momano halves O.C.C. Related and Secondary Skills at every step; the
sheet halves only the level-one related picks. A non-psychic adds +2 P.P.E.
per level by hand. A Mind Melter halves all O.C.C. bonuses.

Starting kit beyond what the sheet lists: one weapon for each W.P. with five
complete reloads, a squirtgun, one full suit of personalized environmental
M.D. body armor of any kind, a black jumpsuit and some personal items. The
backpack may instead be an NG-S2 survival pack. Magic and further
Techno-Wizard items come later, through play.

Money: besides the credits, 1D6x1000 credits in black market items.

Cybernetics most Momano have (printed 125): one or two Multi-Optics Eyes with
infrared and thermo-imaging; a Bionic Lung (Toxic Filter, Storage Cell); a sensor
hand or forearm with motion and heat detection; Clock Calendar; Gyro-Compass;
one bionic limb (typically arm and hand) carrying two bionic weapons or
features; and 3-5 other implants or Black Market cybernetics, or instead a
second bionic limb with two weapons or features, which makes the character a
Partial Cyborg. None of these is on the sheet, the Clock Calendar and
Gyro-Compass included: the book gives the list as what most Momano have, not
as a fixed grant, so record whichever the character has by hand.

Optional weapon modifications (printed 125-126), bought in play: a bionic
chemical spray loaded with ordinary water, holy water, garlic or wolfbay spray
or salt spray; silver plating for bionic blades and spikes; silver bullets;
the hydraulic stake driver. Techno-Wizard bionics (printed 126-129): TW
magical silver-plated blades, finger blaster, sunbeam blaster, hydraulic stake
driver, watergun, flaming shooting knuckle spikes, electro-blaster and flaming
retractable sword.
',
       updated_at = datetime('now')
 WHERE class_id = 'momano-headhunter'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 22246;

-- == outback-mutie ==
UPDATE imported_classes
   SET markdown = '---
id: outback-mutie
name: Outback Mutie
system: rifts
source_book: Rifts World Book 19: Australia p.126-131
category: rcc
psionics_allowed: false
tags: []
men_of_arms: false
xp_table: [0, 2151, 4301, 8601, 18601, 26601, 36601, 54601, 75601, 99601, 135601, 185601, 240601, 290601, 343601]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
starting_money: "2d6x100"
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Australian English", base: 80, per_level: 0, note: "Speaks Australian at 80% +2D4% (roll the 2D4 and add it by hand); most are illiterate." }
    - { choose: 2, categories: ["Domestic"], bonus: 10, note: "Two Domestic skills of choice (+10%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Law", base: 45, per_level: 5, note: "+10%" }
    - { choose: 2, from: ["Lore: Aborigines", "Lore: American Indians", "Lore: Astral", "Lore: Cattle & Animals", "Lore: Cities", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Dreamtime Culture", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: General Law", "Lore: Geomancy or Lines of Power", "Lore: History of Russia", "Lore: Juicers", "Lore: Magic", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 10, note: "Lore: two of choice (+10%)." }
    - { choose: 1, from: ["Horsemanship: General", "Automobile", "Truck", "Motorcycles & Snowmobiles"], bonus: 10, note: "Horsemanship: General/Standard or Pilot Automobile, Truck or Motorcycle (+10%; pick one)." }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "General Athletics." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three of choice (any)." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Expert at the cost of one O.C.C. Related Skill, or to Martial Arts (or Assassin, if evil) for the cost of two skills." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", except: ["Laser Communications"], bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"], bonus: 5 }
      - "Military"
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite"], bonus: 10 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - "Science"
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Six additional skills at level one, three additional at level two and one additional at levels 3, 6, 9 and 12. Communication: any (+5%), except Laser. Cowboy: none. Domestic: any (+10%). Electrical: Basic only. Espionage: none. Mechanical: Basic and Automotive only. Medical: First Aid only (+5%). Military: any. Physical: any except Gymnastics and Acrobatics. Pilot: any (+10%), except Robot Elite, Power Armor and military vehicles. Pilot Related: any. Rogue: any (+2%). Science: any. Technical: any (+10%). W.P.: any. Wilderness: any (+5%)."
    schedule:
      - { level: 2, count: 3 }
      - { level: 3, count: 1 }
      - { level: 6, count: 1 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 2
    categories:
      - { name: "Communications", except: ["Laser Communications"] }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-500 Forager", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-60 Flanker", "Air Assault Armor", "Combat Pod", "Flight System Combat", "Military: Combat Helicopter", "Military: Jet Fighters", "Military: Submersibles", "Military: Tanks & APCs", "Military: Warships & Patrol Boats", "Fighter Combat: Basic", "Fighter Combat: Elite"] }
      - "Pilot Related"
      - "Rogue"
      - "Science"
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Two Secondary Skills from the same list at levels 1, 3, 6, 8 and 11, limited the same way, without the bonuses in parentheses."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 8, count: 2 }
      - { level: 11, count: 2 }
special_abilities:
  - { choose: 1, from: ["Deformity (01-05): Looks completely human", "Deformity (06-08): Unusually tall and thin", "Deformity (09-10): Wallaby-like build", "Deformity (11-15): Third arm and hand", "Deformity (16-20): Multiple animal features", "Deformity (21-25): Serpent or snake", "Deformity (26-30): Koala", "Deformity (31-35): Platypus", "Deformity (31-35): Platypus, full platypus features", "Deformity (36-45): Feline", "Deformity (36-45): Feline, prominent features", "Deformity (46-55): Canine", "Deformity (46-55): Canine, prominent features", "Deformity (56-65): Bat", "Deformity (56-65): Bat, bat-like face and short legs", "Deformity (66-75): Kangaroo or Wallaby", "Deformity (66-75): Kangaroo or Wallaby, the animal''s legs and feet", "Deformity (76-80): Lizard", "Deformity (76-80): Lizard, scaled body and tail", "Deformity (76-80): Lizard, crocodile-like", "Deformity (81-85): Bandicoot or Bilby", "Deformity (86-90): Tasmanian Devil (rare)", "Deformity (91-95): Thylacine (rare)", "Deformity (96-00): Echidna (rare)"] }
  - { choose: 1, from: ["Mutant Power (01-05): Effectively a Mind Bleeder", "Mutant Power (06-10): Effectively a Mind Melter", "Mutant Power (11-20): Psi-Healer", "Mutant Power (21-30): Psychic Prognosticator (Psike-Eyes)", "Mutant Power (31-40): Psychic Fighter (Zap-Sack)", "Mutant Power (41-50): Ectoplasmic Master (Ecto-Freak)", "Mutant Power (51-55): Psychic Sensitive (Feelie)", "Mutant Power (56-60): TK-Master (Mover)", "Mutant Power (61-80): Natural Spell Caster (Nate)", "Mutant Power (81-90): Impervious to Magic (Magic Back Rounder)", "Mutant Power (91-00): Mega-Damage Mutant (Tanker)"] }
  - { choose: 1, from: ["Special Ability (01-10): Naturally Smart", "Special Ability (11-20): Naturally Quick & Alert", "Special Ability (21-30): Supernatural Strength", "Special Ability (31-40): Minor M.D.C. creature", "Special Ability (41-50): Major M.D.C. creature", "Special Ability (51-55): Impervious to disease and poisons", "Special Ability (56-60): Natural at hiding", "Special Ability (61-65): Natural Swimmer", "Special Ability (66-70): Natural Climber", "Special Ability (71-80): Natural Runner", "Special Ability (81-85): Impervious to fire", "Special Ability (86-90): Energy Expulsion", "Special Ability (91-00): Wings"] }
  - name: "Deformity (01-05): Looks completely human"
    description: "Roll 01-05 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). No visible deformity at all; a rarity among mutants."
  - name: "Deformity (06-08): Unusually tall and thin"
    description: "Roll 06-08 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). Stands 6 feet (1.8 m) plus 3D6 inches and is very thin, with something of an insect or skeletal look, but is otherwise human in appearance."
  - name: "Deformity (09-10): Wallaby-like build"
    description: "Roll 09-10 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). Narrow shoulders, a barrel chest and a hunched back give the outline of a wallaby or bettong standing on its hind legs. The face and everything else look human."
  - name: "Deformity (11-15): Third arm and hand"
    description: "Roll 11-15 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). A fully formed extra arm and hand, usually set below one of the other arms; otherwise looks completely human. Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Deformity (16-20): Multiple animal features"
    description: "Roll 16-20 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). One arm and hand and one leg are those of a different animal. 50-65% also have one of these: a tail, fur or scales, a third limb (like one of the others or different again), or a head that is animal-like or wholly animal. A pair of wings is possible only if the G.M. allows it and flight is the result on the Additional Special Abilities table."
  - name: "Deformity (21-25): Serpent or snake"
    description: "Roll 21-25 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). No legs: a serpentine body 1D4+3 feet (1.2 to 2.1 m) long, scaled in half of these mutants. Small or flat nose, a round head without pronounced features, and half the hair of a normal human. Half have thin or shrivelled arms and hands (-15% on all skills that need the hands). NOT APPLIED AUTOMATICALLY: Spd becomes 1D6+6 crawling (or travel by psionics), natural A.R. 10, and a natural prowl of 50% +4% per level of experience."
  - name: "Deformity (26-30): Koala"
    description: "Roll 26-30 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Short (4-5 feet), pudgy and hairy, with large fur-covered ears and a large flat nose. Half are covered in short grey and white fur and have short fingers with pointed nails. Either kind climbs as the Climbing skill with a +10% bonus, improving with experience like any skill (not added to the skill list automatically)."
  - name: "Deformity (31-35): Platypus"
    description: "Roll 31-35 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Barrel chest, short neck, short legs, small eyes, thick lips, and webbed fingers and toes. At home in water: swims as the Swimming skill with a +10% bonus, is resistant to cold, holds the breath for 1D4+3 minutes and survives depths of 300 feet (91 m) without breathing gear. Applied: -4 Spd. Half of these mutants have full platypus features; that is the other option on this band."
    bonuses: { attributes: { Spd: -4 } }
  - name: "Deformity (31-35): Platypus, full platypus features"
    description: "Roll 31-35 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band covered in waterproof fur, with small dark eyes, a round head and a duckbill-like mouth, on top of the barrel chest, short legs and webbed fingers and toes. Swims as the Swimming skill with a +10% bonus, is resistant to cold, holds the breath for 1D4+3 minutes and survives depths of 300 feet (91 m). Applied: -4 Spd, -3 P.B."
    bonuses: { attributes: { Spd: -4, PB: -3 } }
  - name: "Deformity (36-45): Feline"
    description: "Roll 36-45 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Almond-shaped eyes (often green, blue, yellow or gold), striking mane-like or streaked hair, small pointed ears and small canines, but otherwise reasonably human. About 33% are unnaturally beautiful and slender: +8 P.B. and +1D4+1 to any one physical attribute other than P.B. (roll for it; not applied automatically). Half of this band have more prominent feline features; that is the other option."
  - name: "Deformity (36-45): Feline, prominent features"
    description: "Roll 36-45 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band with a fur-covered body, tail, cat-like muzzle, pointed feline teeth and retractable claws (2D6 damage plus any P.S. damage bonus), and the equivalent of a natural Acrobatics skill. About 33% are unnaturally beautiful and slender: +8 P.B. and +1D4+1 to any one physical attribute other than P.B. (roll for it; not applied automatically). Applied: +1D4 P.S., +1D4 P.P."
    bonuses: { attributes: { PS: "1d4", PP: "1d4" } }
  - name: "Deformity (46-55): Canine"
    description: "Roll 46-55 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Warm brown or hazel eyes, large and often pointed ears, striking mane-like, bushy or streaked hair, large canine teeth and often a dog- or wolf-like muzzle. About 33% are unnaturally charismatic and likeable: +8 M.A. and +1D4+2 to any one physical attribute (roll for it; not applied automatically). Half of this band have more prominent canine features; that is the other option."
  - name: "Deformity (46-55): Canine, prominent features"
    description: "Roll 46-55 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band with a fur-covered body, tail, dog-like muzzle, canine teeth and a keen sense of smell: identifies and tracks scents at 40% +5% per level of experience. About 33% are unnaturally charismatic and likeable: +8 M.A. and +1D4+2 to any one physical attribute (roll for it; not applied automatically). Applied: +1D4 P.S., +1D6+2 Spd."
    bonuses: { attributes: { PS: "1d4", Spd: "1d6+2" } }
  - name: "Deformity (56-65): Bat"
    description: "Roll 56-65 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). A leathery membrane under each arm, long pointed fingers, prominent pointed ears, pointed teeth and dark eyes. Half of this band are far more bat-like; that is the other option."
  - name: "Deformity (56-65): Bat, bat-like face and short legs"
    description: "Roll 56-65 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band with a bat-like face (muzzle, canine teeth, large pointed ears, small dark eyes), clawed fingers and toes and a large membrane under the arms. The legs work but are about half the normal length and bowed, so the mutant waddles. Hearing is equal to the bionic Amplified Hearing and Ultra-Ear (Rifts RPG p.231). Applied: -2 Spd, +1 to parry, +2 to dodge, +3 on initiative."
    bonuses: { attributes: { Spd: -2 }, combat: { parry: 1, dodge: 2, initiative: 3 } }
  - name: "Deformity (66-75): Kangaroo or Wallaby"
    description: "Roll 66-75 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Narrow shoulders and a slender upper body over wide hips, beefy powerful legs and large feet. Leaps 6 feet (1.8 m) high and 10 feet (3 m) across. Applied: +1D6 Spd. About half of this band have the animal''s own legs and feet; that is the other option."
    bonuses: { attributes: { Spd: "1d6" } }
  - name: "Deformity (66-75): Kangaroo or Wallaby, the animal''s legs and feet"
    description: "Roll 66-75 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band whose legs and feet have the exact shape and function of the animal''s, with large pointed ears and a somewhat muzzle-like mouth. Leaps 10 feet (3 m) high and 15 feet (4.6 m) across, 20% further with a running start. Applied: +1D6+6 Spd (in place of the +1D6 of the other option)."
    bonuses: { attributes: { Spd: "1d6+6" } }
  - name: "Deformity (76-80): Lizard"
    description: "Roll 76-80 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Rough scaly skin, little body hair even on the head (usually light in color), a thick neck with loose skin and a small nose. A natural climber: +10% on the Climbing skill. About 50% of this band have a scaled body and tail, and 20% resemble a crocodile; those are the other two options."
  - name: "Deformity (76-80): Lizard, scaled body and tail"
    description: "Roll 76-80 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The roughly 50% of this band with no hair, a lizard-like shape and features, a tail and a scale-covered body: natural A.R. 12. A natural climber: +10% on the Climbing skill. Applied: +2D6 S.D.C."
    bonuses: { pools: { sdc: "2d6" } }
  - name: "Deformity (76-80): Lizard, crocodile-like"
    description: "Roll 76-80 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The 20% of this band that resemble a crocodile, with thick lumpy skin: natural A.R. 13. A natural climber: +10% on the Climbing skill. Applied: +2D6+6 S.D.C."
    bonuses: { pools: { sdc: "2d6+6" } }
  - name: "Deformity (81-85): Bandicoot or Bilby"
    description: "Roll 81-85 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Short (4.5 to 5 feet / 1.35 to 1.5 m), with a large, narrow and often pointed nose, small dark eyes, round ears and large feet. About one third look just like a giant version of the animal with longer, stronger, human-like arms and hands. Either kind has natural nightvision to 600 feet (183 m). Applied: +1D4 Spd."
    bonuses: { attributes: { Spd: "1d4" } }
  - name: "Deformity (86-90): Tasmanian Devil (rare)"
    description: "Roll 86-90 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Stocky, with a thick neck, black hair, a large nose, a muzzle-like mouth, canine teeth and a short but robust stature (5 feet to 5 feet 6 inches / 1.5 to 1.65 m). 25% are covered in black fur with prominent animal features and a bushy tail. Either kind has nightvision to 300 feet (91.5 m). Applied: +1D4 P.S., +1D4 Spd."
    bonuses: { attributes: { PS: "1d4", Spd: "1d4" } }
  - name: "Deformity (91-95): Thylacine (rare)"
    description: "Roll 91-95 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Always a humanoid version of the marsupial wolf: short fur, tiger stripes over the rear half, a long narrow tail, a muzzle and canine teeth. Applied: +2D6 Spd, +2 P.S."
    bonuses: { attributes: { Spd: "2d6", PS: 2 } }
  - name: "Deformity (96-00): Echidna (rare)"
    description: "Roll 96-00 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Half have a small round head with a long pointed nose and hair that feathers into spikes; the other half look like a giant echidna with longer, stronger, human-like arms and hands and a head and back covered in long, thick quills. Natural A.R. 14, and anyone who grabs or wrestles the mutant is stabbed by 1D4+1 quills, each doing 1D6 S.D.C. (M.D. if the mutant is a Mega-Damage being). The book prints the A.R. and quills after the quilled half, without saying whether the first half share them."
  - name: "Mutant Power (01-05): Effectively a Mind Bleeder"
    description: "Roll 01-05 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). The mutant has the powers of the Mind Bleeder: build the psionics from that class. Choosing this asks for the Mind Bleeder as the paired occupation, which also brings that class''s skills; drop them if the G.M. reads the result as powers only."
    psionics: { type: "master" }
    occ_options: ["mind-bleeder"]
  - name: "Mutant Power (06-10): Effectively a Mind Melter"
    description: "Roll 06-10 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). The mutant has the powers of the Mind Melter: build the psionics from that class. Choosing this asks for the Mind Melter as the paired occupation, which also brings that class''s skills; drop them if the G.M. reads the result as powers only."
    psionics: { type: "master" }
    occ_options: ["mind-melter"]
  - name: "Mutant Power (11-20): Psi-Healer"
    description: "Roll 11-20 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Has every psionic Healing power, plus 1D4 Sensitive or Physical powers: roll 1D4 and take only that many (four is the most the roll can give). The book prints neither a tier nor an I.S.P. figure for this result; it is stored as a major psychic with the standard major I.S.P. of M.E. + 4D6, +1D6+1 per level, which is a reading."
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Attack Disease", "Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear", "Transfer I.S.P."], powers_starting: 4, categories_allowed: ["Sensitive", "Physical"] }
  - name: "Mutant Power (21-30): Psychic Prognosticator (Psike-Eyes)"
    description: "Roll 21-30 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Clairvoyance, Commune with Spirits, See the Invisible, See Aura, Read Dimensional Portal, Remote Viewing, Object Read, Psychic Diagnosis, Detect Psionics and Mind Block, plus two Sensitive powers of choice. Gains Mind Bolt at level 4, Mind Bond at level 8 and Psychic Omni-Sight at level 12. A master psychic, though far more limited than a Mind Melter. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers: ["Clairvoyance", "Commune with Spirit", "See The Invisible", "See Aura", "Read Dimensional Portal", "Remote Viewing", "Object Read (Psychometry)", "Psychic Diagnosis", "Detect Psionics", "Mind Block"], powers_starting: 2, categories_allowed: ["Sensitive"], powers_schedule: [{ level: 4, count: 1, from: ["Mind Bolt"] }, { level: 8, count: 1, from: ["Mind Bond"] }, { level: 12, count: 1, from: ["Psychic Omni-Sight"] }] }
  - name: "Mutant Power (31-40): Psychic Fighter (Zap-Sack)"
    description: "Roll 31-40 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Intuitive Combat and Sixth Sense, either Electrokinesis or Pyrokinesis, and two offensive Super-Psionic powers of choice. From level two on, selects two Physical powers at each level of experience. A master psychic, though far more limited than a Mind Melter; the G.M. may substitute a Burster or Zapper from Psyscape. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers: ["Intuitive Combat", "Sixth Sense"], powers_starting: 3, powers_starting_groups: [{ count: 1, from: ["Electrokinesis", "Pyrokinesis"], note: "Either Electrokinesis or Pyrokinesis." }, { count: 2, categories: ["Super"], note: "Two offensive Super-Psionic powers of choice." }], powers_per_level: 2, categories_allowed: ["Physical"] }
  - name: "Mutant Power (41-50): Ectoplasmic Master (Ecto-Freak)"
    description: "Roll 41-50 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Especially common among mutants with missing or diminished limbs, who shape ectoplasmic arms, hands and legs. Has all ectoplasmic powers at double the usual duration and range and with 10% more S.D.C., plus Levitation, 1D4 Physical powers and 1D4 Sensitive powers: roll 1D4 for each and take only that many. A major psychic; the I.S.P. formula stored is the standard major one, M.E. + 4D6, +1D6+1 per level. Applied: +4D6 I.S.P."
    bonuses: { pools: { isp: "4d6" } }
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Ectoplasm", "Ectoplasmic Disguise", "Levitation"], powers_starting: 8, powers_starting_groups: [{ count: 4, categories: ["Physical"], note: "The book grants 1D4 Physical powers: roll 1D4 and take only that many." }, { count: 4, categories: ["Sensitive"], note: "The book grants 1D4 Sensitive powers: roll 1D4 and take only that many." }], categories_allowed: ["Physical", "Sensitive"] }
  - name: "Mutant Power (51-55): Psychic Sensitive (Feelie)"
    description: "Roll 51-55 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Selects two Sensitive powers at every level of experience, level one included, and makes two selections from this list: Empathic Transmission, Mentally Possess Others, Mind Bolt, Mind Block Auto-Defense, Radiate Horror Factor, Telemechanic Operation or Psychic Omni-Sight. A master psychic, though far more limited than a Mind Melter. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers_starting: 4, powers_starting_groups: [{ count: 2, categories: ["Sensitive"], note: "Two Sensitive powers at level one." }, { count: 2, from: ["Empathic Transmission", "Mentally Possess Others", "Mind Bolt", "Mind Block Auto-Defense", "Radiate Horror Factor", "Telemechanic Mental Operation", "Psychic Omni-Sight"], note: "Two selections from the printed list of seven." }], powers_per_level: 2, categories_allowed: ["Sensitive"] }
  - name: "Mutant Power (56-60): TK-Master (Mover)"
    description: "Roll 56-60 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Has every Telekinetic power of the Physical category and the Super-Psionic powers Psychic Body Field, Telekinesis (Super) and Telekinetic Force Field, plus two Physical powers of choice. A master psychic, though far more limited than a Mind Melter. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers: ["Telekinesis", "Telekinetic Leap", "Telekinetic Lift", "Telekinetic Punch", "Telekinetic Push", "Psychic Body Field", "Telekinesis (Super)", "Telekinetic Force Field"], powers_starting: 2, categories_allowed: ["Physical"] }
  - name: "Mutant Power (61-80): Natural Spell Caster (Nate)"
    description: "Roll 61-80 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Innately magical, like Faerie Folk and other creatures of magic. Uses magic items by instinct and heals at ley lines as the Ley Line Walker''s Ley Line Rejuvenation (healing doubled). Knows one spell of choice from the common wizard spells of levels 1 to 6, and at each later level of experience intuitively learns one more spell of a spell level equal to the new level of experience (the picker offers levels up to it). NOT APPLIED AUTOMATICALLY: hit points (only) count as M.D.C., making the mutant a light Mega-Damage being; and P.P.E. is 6D6 plus the P.E. attribute number, +2D6 per level of experience (the class states no base P.P.E., so the sheet shows no pool until it is entered). Applied: +2 to save vs spell magic, +3 to save vs Horror Factor, +4 to save vs possession."
    bonuses: { saves: { spell_magic: 2, horror_factor: 3, possession: 4 } }
    magic: { type: "spell", spells_starting: 1, spell_levels_allowed: [1, 2, 3, 4, 5, 6], spells_per_level: 1, spells_per_level_levels: up_to_character_level }
  - name: "Mutant Power (81-90): Impervious to Magic (Magic Back Rounder)"
    description: "Roll 81-90 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Magical charms, augmentation, control, sickness, curses, illusions and influence have no effect at all, and neither does helpful magic such as healing, flight or invisibility. Impervious to the effects of Ley Line Storms; magic weapons and damaging spells such as Fire Ball and Lightning Bolt do one tenth of their normal damage. NOT APPLIED AUTOMATICALLY: hit points (only) count as M.D.C., making the mutant a light Mega-Damage being."
  - name: "Mutant Power (91-00): Mega-Damage Mutant (Tanker)"
    description: "Roll 91-00 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). A natural Mega-Damage being whose P.S. is supernatural. NOT APPLIED AUTOMATICALLY: natural M.D.C. is 4D4x10 plus the P.E. attribute number, +2D6 M.D.C. per level of experience, recovering 2D6 points per 24 hours. The class states no M.D.C. base for a bonus to add to, so the pool is entered by hand."
  - name: "Special Ability (01-10): Naturally Smart"
    description: "Roll 01-10 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Applied: +1D4+4 I.Q."
    bonuses: { attributes: { IQ: "1d4+4" } }
  - name: "Special Ability (11-20): Naturally Quick & Alert"
    description: "Roll 11-20 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Applied: +2 on initiative, +1 attack per melee round."
    bonuses: { combat: { initiative: 2, attacks: 1 } }
  - name: "Special Ability (21-30): Supernatural Strength"
    description: "Roll 21-30 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). The book heads this result Supernatural Strength and prints only the bonus. Applied: +1D4 P.S."
    bonuses: { attributes: { PS: "1d4" } }
  - name: "Special Ability (31-40): Minor M.D.C. creature"
    description: "Roll 31-40 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). NOT APPLIED AUTOMATICALLY: hit points (only) become physical M.D.C., and +2 is added to any one attribute of choice."
  - name: "Special Ability (41-50): Major M.D.C. creature"
    description: "Roll 41-50 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). NOT APPLIED AUTOMATICALLY: hit points (only) plus 1D4x10 become physical M.D.C."
  - name: "Special Ability (51-55): Impervious to disease and poisons"
    description: "Roll 51-55 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Disease and poison have no effect; modern drugs and magic potions are half as effective."
  - name: "Special Ability (56-60): Natural at hiding"
    description: "Roll 56-60 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Equal to the Blend skill at 78% +2% per level of experience, Camouflage at 70% +2% per level and Escape Artist at 50% +2% per level (not added to the skill list automatically)."
  - name: "Special Ability (61-65): Natural Swimmer"
    description: "Roll 61-65 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Swims at 80% +2% per level of experience, holds the breath for 1D4x10 minutes, withstands depths of 500 feet (152 m) and swims at twice normal speed without fatigue for the first four hours (not added to the skill list automatically)."
  - name: "Special Ability (66-70): Natural Climber"
    description: "Roll 66-70 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Has the equivalent of the Acrobatics and Climbing skills at +20% (not added to the skill list automatically)."
  - name: "Special Ability (71-80): Natural Runner"
    description: "Roll 71-80 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Runs at maximum speed for 30 minutes per level of experience without fatigue. Applied: +22 Spd, +1 P.S., +1 P.E."
    bonuses: { attributes: { Spd: 22, PS: 1, PE: 1 } }
  - name: "Special Ability (81-85): Impervious to fire"
    description: "Roll 81-85 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Fire does no damage, Mega-Damage and magical fire included."
  - name: "Special Ability (86-90): Energy Expulsion"
    description: "Roll 86-90 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Fires blasts from the eyes or a hand: 1D6 M.D. +2 M.D. per level of experience, range 200 feet (61 m) +40 feet (12.2 m) per level."
  - name: "Special Ability (91-00): Wings"
    description: "Roll 91-00 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Wings or bat-like webbed membranes: flies at 20 mph (32 km), or double that for a mutant whose deformity was bat (or bird) to begin with."
equipment_starting:
  - { item_id: "traveling-clothes", qty: 1, note: "A basic set of travelling clothes." }
  - { choose: 1, label: "light to medium homemade M.D.C. armor", qty: 1, from: ["homespun-salvaged-md-body-armor", "homespun-mdc-chain-mail-with-leather-and-rubber", "homespun-mdc-metal-chain-mail-or-ceramic", "homespun-mdc-metal-alloy-armor", "homespun-mdc-composite-animal-armor"] }
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon for each W.P., plus an S.D.C. sidearm." }
  - { item_id: "billy", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "water-skin-1-gallon", qty: 1, note: "The book says a large water skin." }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { item_id: "utility-belt", qty: 1 }
  - { choose: 1, label: "backpack or saddle-bags", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "bedroll", qty: 1, note: "Bedroll or sleeping bag." }
  - { item_id: "cigarette-lighter-refillable", qty: 1 }
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Attribute requirements: none; the character just has to be a mutant. Only humans born in Australia mutate (25% Aboriginal, 75% non-Aboriginal)."
  - "Rolls or picks one result on each of the three mutant tables: Physical Deformity, Special Mutant Powers and Additional Special Abilities."
  - "Cybernetics: none, and avoids them as unnatural; most mutants avoid bionics because they interfere with their powers."
  - "Mode of transportation: none to start."
extraction_notes: "WB19 Australia printed 126-131 (cache p127-p132, cache page = printed folio + 1), read off the text layer in column order; the tables on printed 128-130 were checked against 150 dpi renders. The Mutants section opens on printed 126, Mutant R.C.C.s and the tables are printed 128-130, and the block headed Outback Mutie R.C.C. (also known as Outbacker Mutant or just mutant) is printed 131. || CATEGORY: the book heads it an R.C.C. and it is stored as category rcc that is its own occupation (it prints O.C.C. Related and Secondary skills), so it can also be paired with an occupation, which then supplies the related and secondary skills. The block prints no attributes; the mutants are humans, so the eight attribute dice are the human 3D6 and hit points are the human P.E. + 1D6 per level, neither printed in this block. It states no S.D.C. base; a race is men_of_arms false. || XP: the Mutants, Road Sentinel & Special Ops Soldier ladder on the Experience Tables, printed 224, read off a render. || SKILLS: headed Common Outback Skills. Speaks Australian at 80%+2D4% is stored as Language: Australian English at 80 with per_level 0 (the convention for a language printed as a flat percentage); the 2D4 is not stored. Law (+10%) is the catalog row Law (35/5). The Horsemanship-or-Pilot pick is a four-way choice at +10. Hand to Hand: Expert costs one related skill, Martial Arts or Assassin (if evil) two. || RELATED: six at level one, three at level two, one at levels 3, 6, 9 and 12. Communication except Laser is Laser Communications. Electrical Basic only is Basic Electronics; Mechanical Basic and Automotive only is Basic Mechanics and Automotive Mechanics. Pilot except Robot Elite, Power Armor and military vehicles is stored as the robot and power armor rows, the five Military: rows and the two Fighter Combat rows. Cowboy and Espionage are printed None and left out; the book lists no Horsemanship category. || SECONDARY: two at levels 1, 3, 6, 8 and 11, stored as count 2 plus four schedule entries of 2. || MONEY: 2D6x100 dollars stored (printed 2D6x$100); the 1D6x100 dollars in tradeable goods (printed lD6x$100) is in GM Notes. Australian dollars equal credits. || EQUIPMENT not stored as rows: the fancy Sunday clothes, the S.D.C. sidearm, 1D4 ammo clips and the 1D4 old style books of matches have no catalog row and are in GM Notes. The armor choice offers this book''s five homespun M.D.C. rows. || MUTANT TABLES (Nate''s decision 2 in the survey, 2026-10-01: held by the class, not prose): the three percentile tables of the Mutant R.C.C.s section are three pick-one special_abilities groups whose option names carry the band, read off the text layer and checked against 150 dpi renders of printed 128, 129 and 130. Each table is headed Pick one or make a random roll and neither class block states a number of rolls, so each class takes ONE result on each table. Physical Deformity, printed 128-129: 17 bands, 01-05 to 96-00, stored as 24 options because six bands print a half or a share of the mutants with further features and figures (31-35, 36-45, 46-55, 56-65 and 66-75 are two options each, 76-80 is three); the options of one band share its band, so a roll returns all of them and the player rolls the split. Special Mutant Powers, printed 130: 11 bands, 11 options. Additional Special Abilities, printed 130: 13 bands, 13 options. All three run 01 to 00 with no gap or overlap (41 bands in all, the survey''s count). APPLIED AS NUMBERS: attribute dice and flat attribute changes (the -4 Spd, -3 P.B. and -2 Spd are negative bonuses), S.D.C., attacks, initiative, parry, dodge, saves, the Ecto-Freak''s +4D6 I.S.P., and the psionics and magic blocks. IN THE OPTION''S TEXT ONLY: natural A.R., skill-equivalent percentages, leap distances, nightvision, claws and quills, the one-third sub-rolls of the feline and canine bands (+8 P.B. or M.A. and a die added to one attribute of choice), the serpent''s replaced Spd, and every Mega-Damage result. M.D.C. NOT STORED: Hit Points (only) count as M.D.C. (bands 61-80 and 81-90 of the powers table, 31-40 and 41-50 of the abilities table) and the Tanker''s 4D4x10 + P.E. M.D.C. (the text layer prints 4D4xlO; the render shows 4D4x10) are text, because the conversion flag the format has turns S.D.C. into M.D.C. as well and a pool bonus needs a base the class does not state. PSIONICS: the book prints an I.S.P. figure for none of the psychic results. The two it calls or implies major (Psi-Healer, a reading, and Ecto-Freak, printed Major) store the standard major formula; the four it calls Master (Prognosticator, Fighter, Sensitive, TK-Master) store no isp_base. A dice-valued number of powers (1D4) is stored as its maximum with a note to roll, as the Hunter Cat does. Mind Bleeder and Mind Melter (roll for that R.C.C.) are stored as a master tier with occ_options naming the production class, the Godling''s mechanism. Power names follow the catalog: Commune with Spirit, See The Invisible, Object Read (Psychometry), Psychic Omni-Sight, Telemechanic Mental Operation (printed Telemechanic Operation); all psionic Healing abilities is the 17 general Healing rows; all Telekinetic abilities from the physical category is Telekinesis, Telekinetic Leap, Lift, Punch and Push; all ectoplasmic abilities is Ectoplasm and Ectoplasmic Disguise. The Nate''s P.P.E. (6D6 + P.E., +2D6 per level) is text, and its one spell per level equal to the character''s level is stored as up_to_character_level. The G.M. options (substitute other animals; Psyscape classes) are in GM Notes. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. A READING, not a printed rule: Australia printed 128-131 print no Psionics line for a mutant and never mention the standard roll, where the same book prints one when it means it (the Mokoloi on printed 141: standard, same as humans). Printed 128 gives mutants psionic OR magical enhancement and the Special Mutant Powers table of printed 130 is the only mechanism given for either, so the table is taken as the whole answer and a Nate, Magic Back Rounder or Tanker is not also offered the standard roll."
---

## Lore

Human mutation is one of the stranger facts of Rifts Australia, and nobody
can say for certain what causes it. City scientists blame radiation, alien
energy from the Dark Ages or an escaped biological weapon; others point at
the Songlines; the Aborigines say it is the Dreamtime at work, and honor
well-meaning mutants as good Animal Men spirits chosen by the Rainbow
Serpent. Only humans born in Australia are affected. Most mutants carry
some animal or bestial feature, about half look more animal than human, and
most have psionic or magical power as well.

In the Outback the everyday word is Mutie, and it carries no insult. Many
Outback communities take mutants as friends, neighbours and equals, because
out there a mutant''s powers can be the difference between life and death;
some become town leaders, lawmen, heroes and notorious adventurers.
Phreaker, the city word, is kept in the Outback for evil mutants and for
those who serve the Tech-Cities.

## GM Notes

Every mutant rolls or picks one result on each of three tables (printed
128-130): Physical Deformity, Special Mutant Powers and Additional Special
Abilities. Each is a pick-one group on the sheet with a roll button. Where
a band prints a half or a share of the mutants with further features, the
band has two or three options and the player rolls that split by hand.

Not applied by the sheet: every Mega-Damage result (hit points counted as
M.D.C., the Tanker''s 4D4x10 + P.E. M.D.C.), natural A.R., the skill-like
percentages, the Nate''s P.P.E. (6D6 + P.E., +2D6 per level) and the
one-attribute bonuses of the feline and canine bands. The four master
psychic results print no I.S.P. figure.

G.M. options the book offers: other animals may be substituted on the
deformity table as long as their powers and bonuses stay minor; Rifts World
Book 12: Psyscape has more psionic powers, and its psychic classes may be
added to or substituted on the powers table.

Starting kit beyond what the sheet lists: a set of fancy Sunday clothes, an
S.D.C. sidearm, one weapon for each W.P. with 1D4 ammo clips, and 1D4 old
style books of matches. Everyday items such as soap, a comb, a flashlight
or lantern, aspirin and candy are not included and have to be bought.

Money is 2D6x100 dollars plus 1D6x100 dollars in tradeable goods.
Australian dollars equal credits.
',
       updated_at = datetime('now')
 WHERE class_id = 'outback-mutie'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 42233;

-- == phreaker-military-grunt ==
UPDATE imported_classes
   SET markdown = '---
id: phreaker-military-grunt
name: Phreaker Military Grunt
system: rifts
source_book: Rifts World Book 19: Australia p.126-132
category: rcc
psionics_allowed: false
tags: [combat]
men_of_arms: false
xp_table: [0, 2151, 4301, 8601, 18601, 26601, 36601, 54601, 75601, 99601, 135601, 185601, 240601, 290601, 343601]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Australian English", base: 86, per_level: 0, note: "Speaks English at 86% +3D4% (roll the 3D4 and add it by hand)." }
    - { name: "Literacy: Native Language", base: 55, per_level: 5, note: "+15%; the book prints Literacy." }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "Basic Math (+10%)." }
    - { name: "Military Etiquette", base: 45, per_level: 5, note: "+10%" }
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["Jet Packs", "Hovercycles, Skycycles & Rocket Bikes"], bonus: 15, note: "Pilot: Jet Pack or Hovercycle (+15%)." }
    - { choose: 1, from: ["Automobile", "Hover Craft (ground)"], bonus: 10, note: "Pilot: Automobile or Hovercraft (+10%)." }
    - { name: "Sensory Equipment", base: 40, per_level: 5, note: "Read Sensory Equipment (+10%)." }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "Body Building." }
    - { name: "Climbing", base: 45, per_level: 5, note: "+5%" }
    - { name: "Athletics (general)", base: 0, per_level: 0, note: "General Athletics." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Heavy Military Weapons", base: 0, per_level: 0, note: "The book prints W.P. Heavy Weapons." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice (any)." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be upgraded to Martial Arts at the cost of one O.C.C. Related skill." }
  occ_related_skills:
    count: 9
    minimums:
      - { count: 4, category: "Military" }
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 15 }
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Outback Survival", "Carpentry", "Hunting", "Land Navigation"] }
    note: "Four Military skills and five other skills at level one; two additional skills at levels 3, 7, 11 and 15. Communication: any (+5%). Cowboy: none. Domestic: any. Electrical: Basic only. Espionage: none. Mechanical: Automotive and Basic only. Medical: First Aid only. Military: any (+15%). Physical: any, except Acrobatics. Pilot: any. Pilot Related: any. Rogue: none. Science: Astronomy and Math only (+10%). Technical: any (+10%). W.P.: any. Wilderness: Outback Survival, Carpentry, Hunting and Land Navigation only."
    schedule:
      - { level: 3, count: 2 }
      - { level: 7, count: 2 }
      - { level: 11, count: 2 }
      - { level: 15, count: 2 }
  secondary_skills:
    count: 4
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Mechanical", only: ["Automotive Mechanics", "Basic Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - "Military"
      - { name: "Physical", except: ["Acrobatics"] }
      - "Pilot"
      - "Pilot Related"
      - { name: "Science", only: ["Astronomy", "Mathematics: Basic", "Mathematics: Advanced"] }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Outback Survival", "Carpentry", "Hunting", "Land Navigation"] }
    note: "Four Secondary Skills from the same list, limited the same way, without the bonuses in parentheses."
special_abilities:
  - { choose: 1, from: ["Deformity (01-05): Looks completely human", "Deformity (06-08): Unusually tall and thin", "Deformity (09-10): Wallaby-like build", "Deformity (11-15): Third arm and hand", "Deformity (16-20): Multiple animal features", "Deformity (21-25): Serpent or snake", "Deformity (26-30): Koala", "Deformity (31-35): Platypus", "Deformity (31-35): Platypus, full platypus features", "Deformity (36-45): Feline", "Deformity (36-45): Feline, prominent features", "Deformity (46-55): Canine", "Deformity (46-55): Canine, prominent features", "Deformity (56-65): Bat", "Deformity (56-65): Bat, bat-like face and short legs", "Deformity (66-75): Kangaroo or Wallaby", "Deformity (66-75): Kangaroo or Wallaby, the animal''s legs and feet", "Deformity (76-80): Lizard", "Deformity (76-80): Lizard, scaled body and tail", "Deformity (76-80): Lizard, crocodile-like", "Deformity (81-85): Bandicoot or Bilby", "Deformity (86-90): Tasmanian Devil (rare)", "Deformity (91-95): Thylacine (rare)", "Deformity (96-00): Echidna (rare)"] }
  - { choose: 1, from: ["Mutant Power (01-05): Effectively a Mind Bleeder", "Mutant Power (06-10): Effectively a Mind Melter", "Mutant Power (11-20): Psi-Healer", "Mutant Power (21-30): Psychic Prognosticator (Psike-Eyes)", "Mutant Power (31-40): Psychic Fighter (Zap-Sack)", "Mutant Power (41-50): Ectoplasmic Master (Ecto-Freak)", "Mutant Power (51-55): Psychic Sensitive (Feelie)", "Mutant Power (56-60): TK-Master (Mover)", "Mutant Power (61-80): Natural Spell Caster (Nate)", "Mutant Power (81-90): Impervious to Magic (Magic Back Rounder)", "Mutant Power (91-00): Mega-Damage Mutant (Tanker)"] }
  - { choose: 1, from: ["Special Ability (01-10): Naturally Smart", "Special Ability (11-20): Naturally Quick & Alert", "Special Ability (21-30): Supernatural Strength", "Special Ability (31-40): Minor M.D.C. creature", "Special Ability (41-50): Major M.D.C. creature", "Special Ability (51-55): Impervious to disease and poisons", "Special Ability (56-60): Natural at hiding", "Special Ability (61-65): Natural Swimmer", "Special Ability (66-70): Natural Climber", "Special Ability (71-80): Natural Runner", "Special Ability (81-85): Impervious to fire", "Special Ability (86-90): Energy Expulsion", "Special Ability (91-00): Wings"] }
  - name: "Deformity (01-05): Looks completely human"
    description: "Roll 01-05 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). No visible deformity at all; a rarity among mutants."
  - name: "Deformity (06-08): Unusually tall and thin"
    description: "Roll 06-08 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). Stands 6 feet (1.8 m) plus 3D6 inches and is very thin, with something of an insect or skeletal look, but is otherwise human in appearance."
  - name: "Deformity (09-10): Wallaby-like build"
    description: "Roll 09-10 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). Narrow shoulders, a barrel chest and a hunched back give the outline of a wallaby or bettong standing on its hind legs. The face and everything else look human."
  - name: "Deformity (11-15): Third arm and hand"
    description: "Roll 11-15 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). A fully formed extra arm and hand, usually set below one of the other arms; otherwise looks completely human. Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Deformity (16-20): Multiple animal features"
    description: "Roll 16-20 or choose (Rifts World Book 19: Australia p.128, Physical Deformity table). One arm and hand and one leg are those of a different animal. 50-65% also have one of these: a tail, fur or scales, a third limb (like one of the others or different again), or a head that is animal-like or wholly animal. A pair of wings is possible only if the G.M. allows it and flight is the result on the Additional Special Abilities table."
  - name: "Deformity (21-25): Serpent or snake"
    description: "Roll 21-25 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). No legs: a serpentine body 1D4+3 feet (1.2 to 2.1 m) long, scaled in half of these mutants. Small or flat nose, a round head without pronounced features, and half the hair of a normal human. Half have thin or shrivelled arms and hands (-15% on all skills that need the hands). NOT APPLIED AUTOMATICALLY: Spd becomes 1D6+6 crawling (or travel by psionics), natural A.R. 10, and a natural prowl of 50% +4% per level of experience."
  - name: "Deformity (26-30): Koala"
    description: "Roll 26-30 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Short (4-5 feet), pudgy and hairy, with large fur-covered ears and a large flat nose. Half are covered in short grey and white fur and have short fingers with pointed nails. Either kind climbs as the Climbing skill with a +10% bonus, improving with experience like any skill (not added to the skill list automatically)."
  - name: "Deformity (31-35): Platypus"
    description: "Roll 31-35 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Barrel chest, short neck, short legs, small eyes, thick lips, and webbed fingers and toes. At home in water: swims as the Swimming skill with a +10% bonus, is resistant to cold, holds the breath for 1D4+3 minutes and survives depths of 300 feet (91 m) without breathing gear. Applied: -4 Spd. Half of these mutants have full platypus features; that is the other option on this band."
    bonuses: { attributes: { Spd: -4 } }
  - name: "Deformity (31-35): Platypus, full platypus features"
    description: "Roll 31-35 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band covered in waterproof fur, with small dark eyes, a round head and a duckbill-like mouth, on top of the barrel chest, short legs and webbed fingers and toes. Swims as the Swimming skill with a +10% bonus, is resistant to cold, holds the breath for 1D4+3 minutes and survives depths of 300 feet (91 m). Applied: -4 Spd, -3 P.B."
    bonuses: { attributes: { Spd: -4, PB: -3 } }
  - name: "Deformity (36-45): Feline"
    description: "Roll 36-45 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Almond-shaped eyes (often green, blue, yellow or gold), striking mane-like or streaked hair, small pointed ears and small canines, but otherwise reasonably human. About 33% are unnaturally beautiful and slender: +8 P.B. and +1D4+1 to any one physical attribute other than P.B. (roll for it; not applied automatically). Half of this band have more prominent feline features; that is the other option."
  - name: "Deformity (36-45): Feline, prominent features"
    description: "Roll 36-45 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band with a fur-covered body, tail, cat-like muzzle, pointed feline teeth and retractable claws (2D6 damage plus any P.S. damage bonus), and the equivalent of a natural Acrobatics skill. About 33% are unnaturally beautiful and slender: +8 P.B. and +1D4+1 to any one physical attribute other than P.B. (roll for it; not applied automatically). Applied: +1D4 P.S., +1D4 P.P."
    bonuses: { attributes: { PS: "1d4", PP: "1d4" } }
  - name: "Deformity (46-55): Canine"
    description: "Roll 46-55 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Warm brown or hazel eyes, large and often pointed ears, striking mane-like, bushy or streaked hair, large canine teeth and often a dog- or wolf-like muzzle. About 33% are unnaturally charismatic and likeable: +8 M.A. and +1D4+2 to any one physical attribute (roll for it; not applied automatically). Half of this band have more prominent canine features; that is the other option."
  - name: "Deformity (46-55): Canine, prominent features"
    description: "Roll 46-55 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band with a fur-covered body, tail, dog-like muzzle, canine teeth and a keen sense of smell: identifies and tracks scents at 40% +5% per level of experience. About 33% are unnaturally charismatic and likeable: +8 M.A. and +1D4+2 to any one physical attribute (roll for it; not applied automatically). Applied: +1D4 P.S., +1D6+2 Spd."
    bonuses: { attributes: { PS: "1d4", Spd: "1d6+2" } }
  - name: "Deformity (56-65): Bat"
    description: "Roll 56-65 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). A leathery membrane under each arm, long pointed fingers, prominent pointed ears, pointed teeth and dark eyes. Half of this band are far more bat-like; that is the other option."
  - name: "Deformity (56-65): Bat, bat-like face and short legs"
    description: "Roll 56-65 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band with a bat-like face (muzzle, canine teeth, large pointed ears, small dark eyes), clawed fingers and toes and a large membrane under the arms. The legs work but are about half the normal length and bowed, so the mutant waddles. Hearing is equal to the bionic Amplified Hearing and Ultra-Ear (Rifts RPG p.231). Applied: -2 Spd, +1 to parry, +2 to dodge, +3 on initiative."
    bonuses: { attributes: { Spd: -2 }, combat: { parry: 1, dodge: 2, initiative: 3 } }
  - name: "Deformity (66-75): Kangaroo or Wallaby"
    description: "Roll 66-75 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Narrow shoulders and a slender upper body over wide hips, beefy powerful legs and large feet. Leaps 6 feet (1.8 m) high and 10 feet (3 m) across. Applied: +1D6 Spd. About half of this band have the animal''s own legs and feet; that is the other option."
    bonuses: { attributes: { Spd: "1d6" } }
  - name: "Deformity (66-75): Kangaroo or Wallaby, the animal''s legs and feet"
    description: "Roll 66-75 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The half of this band whose legs and feet have the exact shape and function of the animal''s, with large pointed ears and a somewhat muzzle-like mouth. Leaps 10 feet (3 m) high and 15 feet (4.6 m) across, 20% further with a running start. Applied: +1D6+6 Spd (in place of the +1D6 of the other option)."
    bonuses: { attributes: { Spd: "1d6+6" } }
  - name: "Deformity (76-80): Lizard"
    description: "Roll 76-80 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Rough scaly skin, little body hair even on the head (usually light in color), a thick neck with loose skin and a small nose. A natural climber: +10% on the Climbing skill. About 50% of this band have a scaled body and tail, and 20% resemble a crocodile; those are the other two options."
  - name: "Deformity (76-80): Lizard, scaled body and tail"
    description: "Roll 76-80 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The roughly 50% of this band with no hair, a lizard-like shape and features, a tail and a scale-covered body: natural A.R. 12. A natural climber: +10% on the Climbing skill. Applied: +2D6 S.D.C."
    bonuses: { pools: { sdc: "2d6" } }
  - name: "Deformity (76-80): Lizard, crocodile-like"
    description: "Roll 76-80 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). The 20% of this band that resemble a crocodile, with thick lumpy skin: natural A.R. 13. A natural climber: +10% on the Climbing skill. Applied: +2D6+6 S.D.C."
    bonuses: { pools: { sdc: "2d6+6" } }
  - name: "Deformity (81-85): Bandicoot or Bilby"
    description: "Roll 81-85 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Short (4.5 to 5 feet / 1.35 to 1.5 m), with a large, narrow and often pointed nose, small dark eyes, round ears and large feet. About one third look just like a giant version of the animal with longer, stronger, human-like arms and hands. Either kind has natural nightvision to 600 feet (183 m). Applied: +1D4 Spd."
    bonuses: { attributes: { Spd: "1d4" } }
  - name: "Deformity (86-90): Tasmanian Devil (rare)"
    description: "Roll 86-90 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Stocky, with a thick neck, black hair, a large nose, a muzzle-like mouth, canine teeth and a short but robust stature (5 feet to 5 feet 6 inches / 1.5 to 1.65 m). 25% are covered in black fur with prominent animal features and a bushy tail. Either kind has nightvision to 300 feet (91.5 m). Applied: +1D4 P.S., +1D4 Spd."
    bonuses: { attributes: { PS: "1d4", Spd: "1d4" } }
  - name: "Deformity (91-95): Thylacine (rare)"
    description: "Roll 91-95 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Always a humanoid version of the marsupial wolf: short fur, tiger stripes over the rear half, a long narrow tail, a muzzle and canine teeth. Applied: +2D6 Spd, +2 P.S."
    bonuses: { attributes: { Spd: "2d6", PS: 2 } }
  - name: "Deformity (96-00): Echidna (rare)"
    description: "Roll 96-00 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). Half have a small round head with a long pointed nose and hair that feathers into spikes; the other half look like a giant echidna with longer, stronger, human-like arms and hands and a head and back covered in long, thick quills. Natural A.R. 14, and anyone who grabs or wrestles the mutant is stabbed by 1D4+1 quills, each doing 1D6 S.D.C. (M.D. if the mutant is a Mega-Damage being). The book prints the A.R. and quills after the quilled half, without saying whether the first half share them."
  - name: "Mutant Power (01-05): Effectively a Mind Bleeder"
    description: "Roll 01-05 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). The mutant has the powers of the Mind Bleeder: build the psionics from that class. Choosing this asks for the Mind Bleeder as the paired occupation, which also brings that class''s skills; drop them if the G.M. reads the result as powers only."
    psionics: { type: "master" }
    occ_options: ["mind-bleeder"]
  - name: "Mutant Power (06-10): Effectively a Mind Melter"
    description: "Roll 06-10 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). The mutant has the powers of the Mind Melter: build the psionics from that class. Choosing this asks for the Mind Melter as the paired occupation, which also brings that class''s skills; drop them if the G.M. reads the result as powers only."
    psionics: { type: "master" }
    occ_options: ["mind-melter"]
  - name: "Mutant Power (11-20): Psi-Healer"
    description: "Roll 11-20 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Has every psionic Healing power, plus 1D4 Sensitive or Physical powers: roll 1D4 and take only that many (four is the most the roll can give). The book prints neither a tier nor an I.S.P. figure for this result; it is stored as a major psychic with the standard major I.S.P. of M.E. + 4D6, +1D6+1 per level, which is a reading."
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Attack Disease", "Bio-Regeneration", "Deaden Pain", "Detect Psionics", "Exorcism", "Healing Touch", "Increased Healing", "Induce Sleep", "Lust for Life", "Psychic Diagnosis", "Psychic Purification", "Psychic Surgery", "Resist Fatigue", "Restore P.P.E.", "Stop Bleeding", "Suppress Fear", "Transfer I.S.P."], powers_starting: 4, categories_allowed: ["Sensitive", "Physical"] }
  - name: "Mutant Power (21-30): Psychic Prognosticator (Psike-Eyes)"
    description: "Roll 21-30 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Clairvoyance, Commune with Spirits, See the Invisible, See Aura, Read Dimensional Portal, Remote Viewing, Object Read, Psychic Diagnosis, Detect Psionics and Mind Block, plus two Sensitive powers of choice. Gains Mind Bolt at level 4, Mind Bond at level 8 and Psychic Omni-Sight at level 12. A master psychic, though far more limited than a Mind Melter. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers: ["Clairvoyance", "Commune with Spirit", "See The Invisible", "See Aura", "Read Dimensional Portal", "Remote Viewing", "Object Read (Psychometry)", "Psychic Diagnosis", "Detect Psionics", "Mind Block"], powers_starting: 2, categories_allowed: ["Sensitive"], powers_schedule: [{ level: 4, count: 1, from: ["Mind Bolt"] }, { level: 8, count: 1, from: ["Mind Bond"] }, { level: 12, count: 1, from: ["Psychic Omni-Sight"] }] }
  - name: "Mutant Power (31-40): Psychic Fighter (Zap-Sack)"
    description: "Roll 31-40 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Intuitive Combat and Sixth Sense, either Electrokinesis or Pyrokinesis, and two offensive Super-Psionic powers of choice. From level two on, selects two Physical powers at each level of experience. A master psychic, though far more limited than a Mind Melter; the G.M. may substitute a Burster or Zapper from Psyscape. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers: ["Intuitive Combat", "Sixth Sense"], powers_starting: 3, powers_starting_groups: [{ count: 1, from: ["Electrokinesis", "Pyrokinesis"], note: "Either Electrokinesis or Pyrokinesis." }, { count: 2, categories: ["Super"], note: "Two offensive Super-Psionic powers of choice." }], powers_per_level: 2, categories_allowed: ["Physical"] }
  - name: "Mutant Power (41-50): Ectoplasmic Master (Ecto-Freak)"
    description: "Roll 41-50 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Especially common among mutants with missing or diminished limbs, who shape ectoplasmic arms, hands and legs. Has all ectoplasmic powers at double the usual duration and range and with 10% more S.D.C., plus Levitation, 1D4 Physical powers and 1D4 Sensitive powers: roll 1D4 for each and take only that many. A major psychic; the I.S.P. formula stored is the standard major one, M.E. + 4D6, +1D6+1 per level. Applied: +4D6 I.S.P."
    bonuses: { pools: { isp: "4d6" } }
    psionics: { type: "major", isp_base: "M.E. + 4d6, +1d6+1 per level", powers: ["Ectoplasm", "Ectoplasmic Disguise", "Levitation"], powers_starting: 8, powers_starting_groups: [{ count: 4, categories: ["Physical"], note: "The book grants 1D4 Physical powers: roll 1D4 and take only that many." }, { count: 4, categories: ["Sensitive"], note: "The book grants 1D4 Sensitive powers: roll 1D4 and take only that many." }], categories_allowed: ["Physical", "Sensitive"] }
  - name: "Mutant Power (51-55): Psychic Sensitive (Feelie)"
    description: "Roll 51-55 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Selects two Sensitive powers at every level of experience, level one included, and makes two selections from this list: Empathic Transmission, Mentally Possess Others, Mind Bolt, Mind Block Auto-Defense, Radiate Horror Factor, Telemechanic Operation or Psychic Omni-Sight. A master psychic, though far more limited than a Mind Melter. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers_starting: 4, powers_starting_groups: [{ count: 2, categories: ["Sensitive"], note: "Two Sensitive powers at level one." }, { count: 2, from: ["Empathic Transmission", "Mentally Possess Others", "Mind Bolt", "Mind Block Auto-Defense", "Radiate Horror Factor", "Telemechanic Mental Operation", "Psychic Omni-Sight"], note: "Two selections from the printed list of seven." }], powers_per_level: 2, categories_allowed: ["Sensitive"] }
  - name: "Mutant Power (56-60): TK-Master (Mover)"
    description: "Roll 56-60 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Has every Telekinetic power of the Physical category and the Super-Psionic powers Psychic Body Field, Telekinesis (Super) and Telekinetic Force Field, plus two Physical powers of choice. A master psychic, though far more limited than a Mind Melter. The book prints no I.S.P. figure for this result, so none is stored and the sheet shows no I.S.P. pool until the G.M. sets one."
    psionics: { type: "master", powers: ["Telekinesis", "Telekinetic Leap", "Telekinetic Lift", "Telekinetic Punch", "Telekinetic Push", "Psychic Body Field", "Telekinesis (Super)", "Telekinetic Force Field"], powers_starting: 2, categories_allowed: ["Physical"] }
  - name: "Mutant Power (61-80): Natural Spell Caster (Nate)"
    description: "Roll 61-80 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Innately magical, like Faerie Folk and other creatures of magic. Uses magic items by instinct and heals at ley lines as the Ley Line Walker''s Ley Line Rejuvenation (healing doubled). Knows one spell of choice from the common wizard spells of levels 1 to 6, and at each later level of experience intuitively learns one more spell of a spell level equal to the new level of experience (the picker offers levels up to it). NOT APPLIED AUTOMATICALLY: hit points (only) count as M.D.C., making the mutant a light Mega-Damage being; and P.P.E. is 6D6 plus the P.E. attribute number, +2D6 per level of experience (the class states no base P.P.E., so the sheet shows no pool until it is entered). Applied: +2 to save vs spell magic, +3 to save vs Horror Factor, +4 to save vs possession."
    bonuses: { saves: { spell_magic: 2, horror_factor: 3, possession: 4 } }
    magic: { type: "spell", spells_starting: 1, spell_levels_allowed: [1, 2, 3, 4, 5, 6], spells_per_level: 1, spells_per_level_levels: up_to_character_level }
  - name: "Mutant Power (81-90): Impervious to Magic (Magic Back Rounder)"
    description: "Roll 81-90 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). Magical charms, augmentation, control, sickness, curses, illusions and influence have no effect at all, and neither does helpful magic such as healing, flight or invisibility. Impervious to the effects of Ley Line Storms; magic weapons and damaging spells such as Fire Ball and Lightning Bolt do one tenth of their normal damage. NOT APPLIED AUTOMATICALLY: hit points (only) count as M.D.C., making the mutant a light Mega-Damage being."
  - name: "Mutant Power (91-00): Mega-Damage Mutant (Tanker)"
    description: "Roll 91-00 or choose (Rifts World Book 19: Australia p.130, Special Mutant Powers table). A natural Mega-Damage being whose P.S. is supernatural. NOT APPLIED AUTOMATICALLY: natural M.D.C. is 4D4x10 plus the P.E. attribute number, +2D6 M.D.C. per level of experience, recovering 2D6 points per 24 hours. The class states no M.D.C. base for a bonus to add to, so the pool is entered by hand."
  - name: "Special Ability (01-10): Naturally Smart"
    description: "Roll 01-10 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Applied: +1D4+4 I.Q."
    bonuses: { attributes: { IQ: "1d4+4" } }
  - name: "Special Ability (11-20): Naturally Quick & Alert"
    description: "Roll 11-20 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Applied: +2 on initiative, +1 attack per melee round."
    bonuses: { combat: { initiative: 2, attacks: 1 } }
  - name: "Special Ability (21-30): Supernatural Strength"
    description: "Roll 21-30 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). The book heads this result Supernatural Strength and prints only the bonus. Applied: +1D4 P.S."
    bonuses: { attributes: { PS: "1d4" } }
  - name: "Special Ability (31-40): Minor M.D.C. creature"
    description: "Roll 31-40 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). NOT APPLIED AUTOMATICALLY: hit points (only) become physical M.D.C., and +2 is added to any one attribute of choice."
  - name: "Special Ability (41-50): Major M.D.C. creature"
    description: "Roll 41-50 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). NOT APPLIED AUTOMATICALLY: hit points (only) plus 1D4x10 become physical M.D.C."
  - name: "Special Ability (51-55): Impervious to disease and poisons"
    description: "Roll 51-55 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Disease and poison have no effect; modern drugs and magic potions are half as effective."
  - name: "Special Ability (56-60): Natural at hiding"
    description: "Roll 56-60 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Equal to the Blend skill at 78% +2% per level of experience, Camouflage at 70% +2% per level and Escape Artist at 50% +2% per level (not added to the skill list automatically)."
  - name: "Special Ability (61-65): Natural Swimmer"
    description: "Roll 61-65 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Swims at 80% +2% per level of experience, holds the breath for 1D4x10 minutes, withstands depths of 500 feet (152 m) and swims at twice normal speed without fatigue for the first four hours (not added to the skill list automatically)."
  - name: "Special Ability (66-70): Natural Climber"
    description: "Roll 66-70 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Has the equivalent of the Acrobatics and Climbing skills at +20% (not added to the skill list automatically)."
  - name: "Special Ability (71-80): Natural Runner"
    description: "Roll 71-80 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Runs at maximum speed for 30 minutes per level of experience without fatigue. Applied: +22 Spd, +1 P.S., +1 P.E."
    bonuses: { attributes: { Spd: 22, PS: 1, PE: 1 } }
  - name: "Special Ability (81-85): Impervious to fire"
    description: "Roll 81-85 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Fire does no damage, Mega-Damage and magical fire included."
  - name: "Special Ability (86-90): Energy Expulsion"
    description: "Roll 86-90 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Fires blasts from the eyes or a hand: 1D6 M.D. +2 M.D. per level of experience, range 200 feet (61 m) +40 feet (12.2 m) per level."
  - name: "Special Ability (91-00): Wings"
    description: "Roll 91-00 or choose (Rifts World Book 19: Australia p.130, Additional Special Abilities table). Wings or bat-like webbed membranes: flies at 20 mph (32 km), or double that for a mutant whose deformity was bat (or bird) to begin with."
equipment_starting:
  - { item_id: "fatigues", qty: 1, note: "A set of combat fatigues." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "uniform", qty: 1 }
  - { item_id: "dress-uniform", qty: 1 }
  - { item_id: "baseball-cap", qty: 1 }
  - { item_id: "trencher-body-armor", qty: 1, note: "Trencher military body armor." }
  - { item_id: "web-belt-military", qty: 1 }
  - { item_id: "gun-holster", qty: 1 }
  - { item_id: "first-aid-kit", qty: 1, note: "Small first aid kit." }
  - { item_id: "hand-held-communicator", qty: 1, note: "5 mile (8 km) range radio communicator." }
  - { item_id: "food-rations", qty: 5, note: "Five days of rations in a small pouch." }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "survival-knife", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "gas-mask", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "signal-flare", qty: 3 }
  - { item_id: "hand-grenade", qty: 4, note: "Four grenades of choice." }
  - { choose: 1, label: "tinted goggles or sunglasses", qty: 1, from: ["tinted-goggles", "sunglasses"] }
  - { item_id: "weapons-matching-w-p-skills", qty: 1, note: "One weapon for each W.P." }
  - { item_id: "e-clip", qty: 6, note: "Six reloads." }
trackable_resources: []
restrictions:
  - "Alignment: any, but they lean toward selfish and evil. Most are reasonably loyal to their city, yet so ruthless toward outsiders that they are likely to seem evil even when they are not."
  - "Attribute requirements: none, other than being a mutant willing to defend the City."
  - "Rolls or picks one result on each of the three mutant tables: Physical Deformity, Special Mutant Powers and Additional Special Abilities."
  - "Cybernetics: none, and avoids them as unnatural; most mutants avoid bionics because they interfere with their powers."
  - "Mutants are not allowed on the City Police force; the City Military is the one place a Phreaker finds equality, and it posts them outside the walls."
extraction_notes: "WB19 Australia printed 126-132 (cache p127-p133, cache page = printed folio + 1), read off the text layer in column order; the tables on printed 128-130 were checked against 150 dpi renders. The Mutants section opens on printed 126, Phreakers is printed 127-128, the tables are printed 128-130, and the block headed Phreaker Military Grunt R.C.C. starts at the foot of printed 131 and fills the first column of printed 132. The City O.C.C. list on printed 105 files it under Other as Phreaker/Mutant R.C.C. || CATEGORY: the book heads it an R.C.C. and it is stored as category rcc that is its own occupation (it prints O.C.C. Related and Secondary skills). The block prints no attributes; the mutants are humans, so the eight attribute dice are the human 3D6 and hit points are the human P.E. + 1D6 per level, neither printed in this block. It states no S.D.C. base; a race is men_of_arms false, although the class is a soldier. || XP: the Mutants, Road Sentinel & Special Ops Soldier ladder on the Experience Tables, printed 224, read off a render. || SKILLS: headed Typical Skills. Speaks English at 86%+3D4% is stored as Language: Australian English at 86 with per_level 0; the 3D4 is not stored. The note on printed 105 gives every Tech-City character English at a minimum of 84+1D6% and literacy at +20%; the class block''s own 86%+3D4% and Literacy (+15%) are what is stored. Literacy is Literacy: Native Language; Read Sensory Equipment is Sensory Equipment; Body Building is Body Building & Weight Lifting; W.P. Heavy Weapons is W.P. Heavy Military Weapons; Pilot Jet Pack or Hovercycle is a choice between Jet Packs and Hovercycles, Skycycles & Rocket Bikes; Automobile or Hovercraft is a choice between Automobile and Hover Craft (ground). Hand to Hand: Martial Arts costs one related skill; the book offers no other style. || RELATED: four Military and five others are stored as count 9 with a floor of four Military; two more at levels 3, 7, 11 and 15. Science Astronomy and Math only is read as Astronomy and both Mathematics rows. Cowboy, Espionage and Rogue are printed None and left out; the book lists no Horsemanship category. || MONEY: 1D6x1000 dollars in personal savings stored (printed lD6x$1000); the monthly salary of 1500 dollars +100 per level, with room, board and medical care, is in GM Notes. || EQUIPMENT not stored as rows: jacket, full brimmed hat and entrenching tool have no catalog row and are in GM Notes. Six reloads are stored as six E-Clips. || MUTANT TABLES (Nate''s decision 2 in the survey, 2026-10-01: held by the class, not prose): the three percentile tables of the Mutant R.C.C.s section are three pick-one special_abilities groups whose option names carry the band, read off the text layer and checked against 150 dpi renders of printed 128, 129 and 130. Each table is headed Pick one or make a random roll and neither class block states a number of rolls, so each class takes ONE result on each table. Physical Deformity, printed 128-129: 17 bands, 01-05 to 96-00, stored as 24 options because six bands print a half or a share of the mutants with further features and figures (31-35, 36-45, 46-55, 56-65 and 66-75 are two options each, 76-80 is three); the options of one band share its band, so a roll returns all of them and the player rolls the split. Special Mutant Powers, printed 130: 11 bands, 11 options. Additional Special Abilities, printed 130: 13 bands, 13 options. All three run 01 to 00 with no gap or overlap (41 bands in all, the survey''s count). APPLIED AS NUMBERS: attribute dice and flat attribute changes (the -4 Spd, -3 P.B. and -2 Spd are negative bonuses), S.D.C., attacks, initiative, parry, dodge, saves, the Ecto-Freak''s +4D6 I.S.P., and the psionics and magic blocks. IN THE OPTION''S TEXT ONLY: natural A.R., skill-equivalent percentages, leap distances, nightvision, claws and quills, the one-third sub-rolls of the feline and canine bands (+8 P.B. or M.A. and a die added to one attribute of choice), the serpent''s replaced Spd, and every Mega-Damage result. M.D.C. NOT STORED: Hit Points (only) count as M.D.C. (bands 61-80 and 81-90 of the powers table, 31-40 and 41-50 of the abilities table) and the Tanker''s 4D4x10 + P.E. M.D.C. (the text layer prints 4D4xlO; the render shows 4D4x10) are text, because the conversion flag the format has turns S.D.C. into M.D.C. as well and a pool bonus needs a base the class does not state. PSIONICS: the book prints an I.S.P. figure for none of the psychic results. The two it calls or implies major (Psi-Healer, a reading, and Ecto-Freak, printed Major) store the standard major formula; the four it calls Master (Prognosticator, Fighter, Sensitive, TK-Master) store no isp_base. A dice-valued number of powers (1D4) is stored as its maximum with a note to roll, as the Hunter Cat does. Mind Bleeder and Mind Melter (roll for that R.C.C.) are stored as a master tier with occ_options naming the production class, the Godling''s mechanism. Power names follow the catalog: Commune with Spirit, See The Invisible, Object Read (Psychometry), Psychic Omni-Sight, Telemechanic Mental Operation (printed Telemechanic Operation); all psionic Healing abilities is the 17 general Healing rows; all Telekinetic abilities from the physical category is Telekinesis, Telekinetic Leap, Lift, Punch and Push; all ectoplasmic abilities is Ectoplasm and Ectoplasmic Disguise. The Nate''s P.P.E. (6D6 + P.E., +2D6 per level) is text, and its one spell per level equal to the character''s level is stored as up_to_character_level. The G.M. options (substitute other animals; Psyscape classes) are in GM Notes. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. A READING, not a printed rule: Australia printed 128-132 print no Psionics line for a mutant and never mention the standard roll, where the same book prints one when it means it (the Mokoloi on printed 141: standard, same as humans). Printed 128 gives mutants psionic OR magical enhancement and the Special Mutant Powers table of printed 130 is the only mechanism given for either, so the table is taken as the whole answer and a Nate, Magic Back Rounder or Tanker is not also offered the standard roll."
---

## Lore

Mutants born inside the Tech-Cities are called Phreakers, a hard word for
people most City-Goers fear and look down on. Nearly all are held at the
bottom of the citizen ladder and given the most menial work, on the
assumption that anyone who looks part animal must be dim, ill-mannered and
dangerous. The frustration that produces only feeds the stereotype.

The one place a Phreaker can find equality, freedom and some power is the
City Military; the police will not have them. Because ordinary citizens
would rather not see them, mutant soldiers are posted outside the walls:
perimeter patrols, guard posts, reconnaissance, rescue, raids and covert
work among the Outback communities. They see more of Australia than most
citizens ever will, and they are handed the most dangerous missions so that
human lives are not risked. Many take their anger out on Outbackers,
Aboriginals and anyone else beyond the walls, and they tend to treat
Outback Muties with the same prejudice the city shows them.

## GM Notes

Every mutant rolls or picks one result on each of three tables (printed
128-130): Physical Deformity, Special Mutant Powers and Additional Special
Abilities. Each is a pick-one group on the sheet with a roll button. Where
a band prints a half or a share of the mutants with further features, the
band has two or three options and the player rolls that split by hand.

Not applied by the sheet: every Mega-Damage result (hit points counted as
M.D.C., the Tanker''s 4D4x10 + P.E. M.D.C.), natural A.R., the skill-like
percentages, the Nate''s P.P.E. (6D6 + P.E., +2D6 per level) and the
one-attribute bonuses of the feline and canine bands. The four master
psychic results print no I.S.P. figure.

G.M. options the book offers: other animals may be substituted on the
deformity table as long as their powers and bonuses stay minor; Rifts World
Book 12: Psyscape has more psionic powers, and its psychic classes may be
added to or substituted on the powers table.

About 20% of the Phreakers in Perth''s armed forces and 33% of those in
Melbourne''s are as ruthless and bloodthirsty as any Roadganger.

Starting kit beyond what the sheet lists: a jacket, a full brimmed hat and
an entrenching tool.

Pay is 1500 dollars a month, +100 per level of experience, with military
room and board, paid medical treatment and the run of the base. Quarters
are a barracks dorm shared by 8-16 soldiers; officers get a small apartment.
Australian dollars equal credits.
',
       updated_at = datetime('now')
 WHERE class_id = 'phreaker-military-grunt'
   AND instr(markdown, 'psionics_allowed: false') = 0
   AND length(markdown) = 41237;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 13 classes carry their new text' AS assertion, count(*) AS got, 13 AS want
  FROM imported_classes
 WHERE (class_id = 'dolphin' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'killer-whale' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'pneuma-biform-dolphin' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'pneuma-biform-killer-whale' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'nautyll-soldier' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'humpback-whale' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'amaki-stone-man' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'arkhon' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'larmac' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'mutant-rat' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'momano-headhunter' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'outback-mutie' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0)
    OR (class_id = 'phreaker-military-grunt' AND instr(markdown, 'PSIONICS_ALLOWED IS FALSE since 2026-10-05') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('dolphin', 'killer-whale', 'pneuma-biform-dolphin', 'pneuma-biform-killer-whale', 'nautyll-soldier', 'humpback-whale', 'amaki-stone-man', 'arkhon', 'larmac', 'mutant-rat', 'momano-headhunter', 'outback-mutie', 'phreaker-military-grunt') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~163-own-psionics-tables-replace-the-standard-roll.sql');
