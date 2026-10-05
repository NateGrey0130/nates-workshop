-- Move eighteen classes' roll tables from prose onto the roll-table mechanic
-- 18 classes, each replaced whole: oni-of-the-one-hundred, pseudo-men, amphib, tattooed-man, t-monster-man, maxi-man, splugorth-conservator, rifts-gigantes, norse-giant, maxi-killer, dragon-juicer, necromancer, african-witch, lyvorrk, dewtani, anti-monster, wired-gunslinger, hu-mutants.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~161-roll-tables-on-eighteen-classes.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C2: tables the books roll on, moved from prose onto the
-- roll-table mechanic (BOOK-INGEST-AUDIT F116 at_levels, F119 signed dice,
-- F120 rolls and attribute_dice on an option).
--
-- Rolled at creation:
--   oni-of-the-one-hundred (Japan printed 201-202): the Legs rows set the Spd
--     dice; Body, Nose, Eyes and Skin become pick-one groups, so all nine
--     appearance tables are picks, in the book's order.
--   pseudo-men (Madhaven printed 71-72): the 21-row oddities table, rolled 1D4
--     times, with every unconditional number on its row.
--   amphib (Underseas printed 99): each Appearance row sets its P.B. dice.
--   tattooed-man, t-monster-man, maxi-man (Atlantis printed 94, 95, 97): the
--     insanity tables, rolled twice, three times and once.
--   splugorth-conservator (Atlantis printed 46-47): rolled twice.
--   maxi-killer (Juicer Uprising printed 54), rifts-gigantes (Conversion Book
--     One printed 92), norse-giant (Pantheons printed 163), anti-monster (South
--     America printed 36): rolled once.
-- Rolled at set levels:
--   necromancer (Africa printed 104) at 4, 8, 10, 12, 15; african-witch (Africa
--     printed 74) at 3, 7, 9, 13; lyvorrk (D-Bees printed 132) at every even
--     level to 14; dewtani (D-Bees printed 66), four tables at 3 and 7, 5 and
--     11, 9, and 13; wired-gunslinger (New West printed 108-109) at 3, 5, 7,
--     10, 13.
-- A branch:
--   hu-mutants (Revised Heroes Unlimited printed 110, 127): Step Four is a
--     required pick of super abilities or psionics, each option carrying its
--     own power block.
-- A note only:
--   dragon-juicer (Juicer Uprising printed 49): its table is rolled "after two
--     years", a trigger in play, so it stays prose and the note says why.
--
-- Every table was read off a page render by one agent and checked row by row
-- against a render by book-reconcile, which did not write it: no wrong band,
-- count, level or figure in any of the eighteen. Production held no saved
-- character on any of them (queried 2026-10-05). No existing option is renamed.

-- == oni-of-the-one-hundred ==
UPDATE imported_classes
   SET markdown = '---
id: oni-of-the-one-hundred
name: Oni of the One Hundred
system: rifts
source_book: Rifts World Book 8: Japan p.199-203
category: rcc
tags: [supernatural]
men_of_arms: false
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
attribute_dice:
  IQ: "2d6"
  ME: "2d6"
  MA: "2d6"
  PS: "2d6+22"
  PP: "2d6+12"
  PE: "2d6+16"
  PB: "1d6"
  Spd: "6d6"
mdc_base: "2d6x10+40"
ppe_base: "5d6"
horror_factor: 11
bonuses:
  combat: { attacks_base: 4, initiative: 1, strike: 2, parry: 2, dodge: 2, pull_punch: 2, roll: 1 }
  saves: { horror_factor: 6 }
  at_level:
    - { level: 6, combat: { attacks: 1 } }
    - { level: 12, combat: { attacks: 1 } }
magic:
  type: "spell"
  spells: ["Tongues"]
skills:
  occ_skills:
    - { name: "Intelligence", base: 36, per_level: 4, note: "+4%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the book prints track humanoids." }
    - { name: "Land Navigation", base: 51, per_level: 4, note: "+15%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "The book: W.P. blunt, W.P. sword and two of choice (any)." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks Japanese at 98%." }
    - { name: "Language: Gobblely", base: 98, per_level: 0, note: "98%." }
    - { choose: 1, from: ["Language: Other"], base: 98, note: "Faerie at 98%. The catalog has no Faerie language row; take Language: Other and name it Faerie." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Can learn two other languages (+10%). Taken once per language - the picker asks which." }
  secondary_skills:
    count: 4
    categories: ["Espionage", "Physical", "Technical", "Rogue", "Wilderness"]
trackable_resources:
  - { key: spell-casts, label: "Natural spell casts", max: 8, reset_on: day, note: "As many as 8 spells from the oni''s power group (and Tongues) per 24 hours. Natural abilities, not learned spell magic." }
special_abilities:
  - choose: 1
    from: ["Oni Powers (01-25): Curses", "Oni Powers (26-50): Blight", "Oni Powers (51-75): Fire", "Oni Powers (76-00): Wind and Storm"]
    note: "Every Oni of the One Hundred has one of four sets of natural magic powers (printed 202). Select one, or roll percentile dice. All four include Tongues."
  - name: "Oni Powers (01-25): Curses"
    description: "Percentile 01-25. Natural spell-like powers: Fear, Compulsion, Luck Curse, Minor Curse, Repel Animals and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Fear", "Compulsion", "Luck Curse", "Minor Curse", "Repel Animals"] }
  - name: "Oni Powers (26-50): Blight"
    description: "Percentile 26-50. Natural spell-like powers: Befuddle, Blind, Sickness, Spoil (food and water), Animate and Control Dead, and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Befuddle", "Blind", "Sickness", "Spoil", "Animate and Control Dead"] }
  - name: "Oni Powers (51-75): Fire"
    description: "Percentile 51-75. Natural spell-like powers: Globe of Daylight, Ignite Fire, Cloud of Smoke, Fire Ball, Fool''s Gold and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Globe of Daylight", "Ignite Fire", "Cloud of Smoke", "Fire Ball", "Fool''s Gold"] }
  - name: "Oni Powers (76-00): Wind and Storm"
    description: "Percentile 76-00. Natural spell-like powers: Breathe Without Air, Fly as the Eagle, Wind Rush, Summon Fog, Summon Storm and Tongues. Up to 8 casts per 24 hours in total."
    magic: { spells: ["Breathe Without Air", "Fly as the Eagle", "Wind Rush", "Summon Fog", "Summon Storm"] }
  - { choose: 1, from: ["Body (01-20): Perfectly Human", "Body (21-50): Broad, Muscular Human", "Body (51-60): Skeletal Human", "Body (61-65): Snail-like Blob", "Body (66-70): Buddha", "Body (71-80): Toad", "Body (81-90): Bird", "Body (91-95): Giant", "Body (96-00): Fish"], note: "General Body Shape (printed 201), rolled once. Appearance only: no result carries a number the sheet adds. The giant (91-95) changes the oni''s size." }
  - name: "Body (01-20): Perfectly Human"
    description: "Roll 01-20 or choose. A perfectly human body."
  - name: "Body (21-50): Broad, Muscular Human"
    description: "Roll 21-50 or choose. A broad, muscular human body."
  - name: "Body (51-60): Skeletal Human"
    description: "Roll 51-60 or choose. A skeletal human body."
  - name: "Body (61-65): Snail-like Blob"
    description: "Roll 61-65 or choose. A lumpy blob, like a snail."
  - name: "Body (66-70): Buddha"
    description: "Roll 66-70 or choose. Looks like a buddha: fat and bald."
  - name: "Body (71-80): Toad"
    description: "Roll 71-80 or choose. Toad-like: large, round, fat and flabby, with no neck."
  - name: "Body (81-90): Bird"
    description: "Roll 81-90 or choose. Bird-like: barrel chested, a broad upper body, a narrow lower abdomen and a short, thick neck."
  - name: "Body (91-95): Giant"
    description: "Roll 91-95 or choose. Humanoid but giant: 8 feet (2.4 m) plus 1D4 additional feet (0.3 to 1.2 m), so 9 to 12 feet tall in place of the usual 4 to 5 feet. The height is a figure to read and roll; the pick changes no number on the sheet."
  - name: "Body (96-00): Fish"
    description: "Roll 96-00 or choose. Fish-like: a long body complete with scales, fins and tail."
  - { choose: 1, from: ["Head (01-05): Wild Boar", "Head (06-15): Lion or Cat", "Head (16-30): Human", "Head (31-40): Skeletal Human", "Head (41-45): Monkey", "Head (46-55): Melon", "Head (56-60): Fish", "Head (61-65): Snake", "Head (66-70): Bird", "Head (71-80): Rotting Skeleton", "Head (81-90): Neanderthal", "Head (91-95): Fox or Canine", "Head (96-00): Rat"], note: "Oni Head Shape (printed 201), rolled once. The result adds to the Horror Factor of 11, and the pick adds it." }
  - name: "Head (01-05): Wild Boar"
    description: "Roll 01-05 or choose. The head of a wild boar. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (06-15): Lion or Cat"
    description: "Roll 06-15 or choose. The head of a lion or cat. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (16-30): Human"
    description: "Roll 16-30 or choose. A human head. No Horror Factor bonus (11)."
  - name: "Head (31-40): Skeletal Human"
    description: "Roll 31-40 or choose. A skeletal human head with sunken features. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (41-45): Monkey"
    description: "Roll 41-45 or choose. The head of a monkey. Applied: +1 Horror Factor (12)."
    horror_factor_bonus: 1
  - name: "Head (46-55): Melon"
    description: "Roll 46-55 or choose. A large head, round like a melon. Applied: +3 Horror Factor (14)."
    horror_factor_bonus: 3
  - name: "Head (56-60): Fish"
    description: "Roll 56-60 or choose. A fish-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (61-65): Snake"
    description: "Roll 61-65 or choose. A snake-like head. Applied: +3 Horror Factor (14)."
    horror_factor_bonus: 3
  - name: "Head (66-70): Bird"
    description: "Roll 66-70 or choose. A bird-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (71-80): Rotting Skeleton"
    description: "Roll 71-80 or choose. A human head that looks like a rotting skeleton. Applied: +4 Horror Factor (15)."
    horror_factor_bonus: 4
  - name: "Head (81-90): Neanderthal"
    description: "Roll 81-90 or choose. A larger, thicker human skull with heavy brow ridges and a square chin. Applied: +1 Horror Factor (12)."
    horror_factor_bonus: 1
  - name: "Head (91-95): Fox or Canine"
    description: "Roll 91-95 or choose. The head of a fox or other canine. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - name: "Head (96-00): Rat"
    description: "Roll 96-00 or choose. A rat-like head. Applied: +2 Horror Factor (13)."
    horror_factor_bonus: 2
  - { choose: 1, from: ["Nose (01-10): Normal Human", "Nose (11-20): Bulbous", "Nose (21-30): Pointed", "Nose (31-50): Ape-like", "Nose (51-60): Bird", "Nose (61-70): Animal Snout", "Nose (71-80): Tiny", "Nose (81-85): Snake", "Nose (86-90): Rat", "Nose (91-00): None"], note: "Oni Nose (printed 201), rolled once. Appearance only. A roll of 71-80 is a tiny nose of one of the types above it: choose the type or roll again on this table for it." }
  - name: "Nose (01-10): Normal Human"
    description: "Roll 01-10 or choose. A normal human nose."
  - name: "Nose (11-20): Bulbous"
    description: "Roll 11-20 or choose. A bulbous nose three times larger than a normal human''s."
  - name: "Nose (21-30): Pointed"
    description: "Roll 21-30 or choose. A pointed nose three times larger than a normal human''s."
  - name: "Nose (31-50): Ape-like"
    description: "Roll 31-50 or choose. A large, wide, flat nose like an ape''s, two times larger than a normal human''s."
  - name: "Nose (51-60): Bird"
    description: "Roll 51-60 or choose. A bird nose; it can be shaped like a hawk''s or a sparrow''s."
  - name: "Nose (61-70): Animal Snout"
    description: "Roll 61-70 or choose. An animal snout, like that of a boar, hog or fox."
  - name: "Nose (71-80): Tiny"
    description: "Roll 71-80 or choose. A tiny nose: any of the types above it on this table (choose one, or roll again on the table for the type), but two times smaller than normal. Note the type beside the pick."
  - name: "Nose (81-85): Snake"
    description: "Roll 81-85 or choose. A snake nose: two small holes or slits above the mouth."
  - name: "Nose (86-90): Rat"
    description: "Roll 86-90 or choose. A rat nose."
  - name: "Nose (91-00): None"
    description: "Roll 91-00 or choose. No nose, not even an opening for one."
  - { choose: 1, from: ["Eyes (01-10): Wild Human", "Eyes (11-20): Glowing Almond", "Eyes (21-40): Large Round", "Eyes (41-50): Small, Unnatural", "Eyes (51-60): Snake", "Eyes (61-70): Bird", "Eyes (71-80): Normal Human", "Eyes (81-90): Four Eyes", "Eyes (91-00): One Large Eye"], note: "Oni Eyes (printed 201), rolled once. Appearance only. A roll of 81-90 is four eyes: roll again on this table (or pick) for their shape." }
  - name: "Eyes (01-10): Wild Human"
    description: "Roll 01-10 or choose. Large human eyes with a wild or crazed look to them."
  - name: "Eyes (11-20): Glowing Almond"
    description: "Roll 11-20 or choose. Huge almond-shaped eyes that glow red like a fire, or sparkling gold, yellow, amber or orange."
  - name: "Eyes (21-40): Large Round"
    description: "Roll 21-40 or choose. Large round eyes that are white, pink, pale blue, green, or clear like a crystal ball."
  - name: "Eyes (41-50): Small, Unnatural"
    description: "Roll 41-50 or choose. Small eyes of an unnatural red, yellow or black."
  - name: "Eyes (51-60): Snake"
    description: "Roll 51-60 or choose. Snake eyes that sparkle gold or silver."
  - name: "Eyes (61-70): Bird"
    description: "Roll 61-70 or choose. Bird eyes that look like jade."
  - name: "Eyes (71-80): Normal Human"
    description: "Roll 71-80 or choose. Normal human eyes."
  - name: "Eyes (81-90): Four Eyes"
    description: "Roll 81-90 or choose. Four eyes. Roll again on this table for the eye shape, or pick one, and note the shape beside the pick."
  - name: "Eyes (91-00): One Large Eye"
    description: "Roll 91-00 or choose. One large round eye that is a pale blue or violet."
  - { choose: 1, from: ["Mouth (01-10): Toad Mouth, Flat Teeth", "Mouth (11-20): Human, Crooked Teeth", "Mouth (21-30): Human, Fangs", "Mouth (31-40): Oversized Human", "Mouth (41-50): Monkey", "Mouth (51-60): Lipless Toad Slit", "Mouth (61-70): Canine Muzzle", "Mouth (71-80): Flabby, Flat Teeth", "Mouth (81-90): Flabby, Toothless", "Mouth (91-00): Tiny Slit"], note: "Oni Mouth (printed 201), rolled once. The result sets the bite damage, which is a figure to read rather than a number the sheet adds." }
  - name: "Mouth (01-10): Toad Mouth, Flat Teeth"
    description: "Roll 01-10 or choose. A large toad-like mouth with flabby lips and an even row of large, flat teeth. Bite: 2D4 M.D."
  - name: "Mouth (11-20): Human, Crooked Teeth"
    description: "Roll 11-20 or choose. A human mouth with crooked teeth. Bite: 1D4 M.D."
  - name: "Mouth (21-30): Human, Fangs"
    description: "Roll 21-30 or choose. A human mouth with fangs and sharp teeth. Bite: 2D4 M.D."
  - name: "Mouth (31-40): Oversized Human"
    description: "Roll 31-40 or choose. A human mouth twice the normal size, with large, pointed, crooked teeth. Bite: 3D4 M.D."
  - name: "Mouth (41-50): Monkey"
    description: "Roll 41-50 or choose. A large monkey-like mouth of sharp teeth and big fangs. Bite: 3D6 M.D."
  - name: "Mouth (51-60): Lipless Toad Slit"
    description: "Roll 51-60 or choose. A large toad mouth with no lips, a long slit full of tiny, sharp teeth. Bite: 2D6 M.D."
  - name: "Mouth (61-70): Canine Muzzle"
    description: "Roll 61-70 or choose. A canine mouth and short muzzle with a dog''s teeth and fangs. Bite: 3D6 M.D."
  - name: "Mouth (71-80): Flabby, Flat Teeth"
    description: "Roll 71-80 or choose. A large mouth with flabby, quivering lips and large, flat, crooked teeth. Bite: 2D4 M.D."
  - name: "Mouth (81-90): Flabby, Toothless"
    description: "Roll 81-90 or choose. A large mouth with flabby, quivering lips and no teeth at all. Bite: one point of mega-damage."
  - name: "Mouth (91-00): Tiny Slit"
    description: "Roll 91-00 or choose. A tiny slit half the size of a human mouth, lipless, with tiny teeth and a thin snake''s tongue. Bite: 1D4 M.D."
  - { choose: 1, from: ["Arms (01-20): Human", "Arms (21-30): Oversized Pair and a Third Arm", "Arms (31-45): Two-Fingered Claws", "Arms (46-56): Gnarled, Skeletal Hands", "Arms (57-67): Monkey-like Claws", "Arms (68-75): Squirrel or Rat-like", "Arms (76-85): Five Arms", "Arms (86-95): Bird Claws", "Arms (96-00): Tentacles"], note: "Oni Arms & Hands (printed 201), rolled once. The M.D. figure is the hand attack for that kind of arm; an extra attack per melee is added by the pick." }
  - name: "Arms (01-20): Human"
    description: "Roll 01-20 or choose. Perfectly human arms and hands, no claws. 1D6 M.D."
  - name: "Arms (21-30): Oversized Pair and a Third Arm"
    description: "Roll 21-30 or choose. A pair of large, oversized, muscular arms (3D6 M.D.) and a third, smaller arm with two clawed fingers and a thumb (2D6 M.D.). Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Arms (31-45): Two-Fingered Claws"
    description: "Roll 31-45 or choose. Muscular human arms ending in clawed hands of two fingers and a thumb. 3D6 M.D."
  - name: "Arms (46-56): Gnarled, Skeletal Hands"
    description: "Roll 46-56 or choose. Thin, gnarled arms, muscular but misshapen, with skeletal hands and long clawed fingers. 2D6 M.D."
  - name: "Arms (57-67): Monkey-like Claws"
    description: "Roll 57-67 or choose. Muscular arms, monkey-like in shape and length, with three-fingered claws and a thumb. 2D4 M.D."
  - name: "Arms (68-75): Squirrel or Rat-like"
    description: "Roll 68-75 or choose. Short, spindly arms like a squirrel''s or rat''s, with small articulated hands and fingers. 1D4 M.D."
  - name: "Arms (76-85): Five Arms"
    description: "Roll 76-85 or choose. Five arms of equal size and proportion. 3D6 M.D. Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Arms (86-95): Bird Claws"
    description: "Roll 86-95 or choose. Powerful arms with bird-like clawed hands. 3D6 M.D."
  - name: "Arms (96-00): Tentacles"
    description: "Roll 96-00 or choose. Octopus-like tentacles in place of arms, twice the length of human arms. 2D6 M.D. from a whip attack. Applied: +4 to entangle, which the book prints as +4 to entangle, grab or hold."
    bonuses: { combat: { entangle: 4 } }
  - { choose: 1, from: ["Legs (01-15): Human", "Legs (16-25): Monkey-like", "Legs (26-50): Classic Oni", "Legs (51-60): Skeletal, Two-Toed", "Legs (61-70): Bird-like", "Legs (71-80): Human, Clawed Toes", "Legs (81-90): Animal-like", "Legs (91-00): Snail Trunk"], note: "Oni Legs (printed 201), rolled once. The result sets the Spd attribute: every row prints its own Spd dice and the pick sets them, so Spd is rolled on the picked row''s dice (from 3D6 to 6D6+10)." }
  - name: "Legs (01-15): Human"
    description: "Roll 01-15 or choose. Perfectly human legs, no claws. Applied: Spd is rolled on 5D6."
    attribute_dice: { Spd: "5d6" }
  - name: "Legs (16-25): Monkey-like"
    description: "Roll 16-25 or choose. Short, stubby monkey-like legs; waddles when walking and lopes on all fours to run. Prehensile feet add +10% to balance and climbing, by hand. Applied: Spd is rolled on 4D6."
    attribute_dice: { Spd: "4d6" }
  - name: "Legs (26-50): Classic Oni"
    description: "Roll 26-50 or choose. Powerfully built upper legs, rather thin lower legs, and feet with two large clawed toes. Applied: Spd is rolled on 6D6+10."
    attribute_dice: { Spd: "6d6+10" }
  - name: "Legs (51-60): Skeletal, Two-Toed"
    description: "Roll 51-60 or choose. Skeletal legs with the classic two-toed, clawed feet. Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (61-70): Bird-like"
    description: "Roll 61-70 or choose. Spindly stick legs and clawed bird feet. Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (71-80): Human, Clawed Toes"
    description: "Roll 71-80 or choose. Human feet with clawed toes. Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (81-90): Animal-like"
    description: "Roll 81-90 or choose. Animal legs, hooved or like a bear''s (the book prints ''hover''). Spd is 6D6, the class''s own roll."
    attribute_dice: { Spd: "6d6" }
  - name: "Legs (91-00): Snail Trunk"
    description: "Roll 91-00 or choose. No feet or legs: a snail-like trunk that slithers. +4 to maintain balance, by hand. Applied: Spd is rolled on 3D6."
    attribute_dice: { Spd: "3d6" }
  - { choose: 1, from: ["Feature (01-07): Rat Tail", "Feature (08-14): Tiny Scales", "Feature (15-21): Small Horns", "Feature (22-28): Large Horns", "Feature (29-35): Large Mane", "Feature (36-42): Bushy Eyebrows and Beard", "Feature (43-49): Lumpy Flesh", "Feature (50-56): Hairy Body", "Feature (57-64): Hairless, Pale Skin", "Feature (65-72): Boils or Scabs", "Feature (73-80): Pot Belly", "Feature (81-87): Hunchback", "Feature (88-94): Lizard Tail", "Feature (95-00): Fur"], note: "Other Features (printed 201-202), rolled once. Seven of the results add to M.D.C. and the pick adds them." }
  - name: "Feature (01-07): Rat Tail"
    description: "Roll 01-07 or choose. The tail of a rat."
  - name: "Feature (08-14): Tiny Scales"
    description: "Roll 08-14 or choose. Skin covered in tiny scales. Applied: +35 M.D.C."
    bonuses: { pools: { mdc: 35 } }
  - name: "Feature (15-21): Small Horns"
    description: "Roll 15-21 or choose. A pair of small horns. Head butt: 1D4 M.D."
  - name: "Feature (22-28): Large Horns"
    description: "Roll 22-28 or choose. A pair of large horns. Head butt: 2D6 M.D."
  - name: "Feature (29-35): Large Mane"
    description: "Roll 29-35 or choose. A large mane of black, red, gold or green hair."
  - name: "Feature (36-42): Bushy Eyebrows and Beard"
    description: "Roll 36-42 or choose. Bushy eyebrows and a scraggly beard."
  - name: "Feature (43-49): Lumpy Flesh"
    description: "Roll 43-49 or choose. Lumpy pink or white flesh. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - name: "Feature (50-56): Hairy Body"
    description: "Roll 50-56 or choose. A hairy body with tan or red skin. Applied: +20 M.D.C."
    bonuses: { pools: { mdc: 20 } }
  - name: "Feature (57-64): Hairless, Pale Skin"
    description: "Roll 57-64 or choose. No hair anywhere on the body, and pale skin."
  - name: "Feature (65-72): Boils or Scabs"
    description: "Roll 65-72 or choose. Boils or scabs cover the body. Applied: +25 M.D.C."
    bonuses: { pools: { mdc: 25 } }
  - name: "Feature (73-80): Pot Belly"
    description: "Roll 73-80 or choose. A pot belly on an otherwise muscular body. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - name: "Feature (81-87): Hunchback"
    description: "Roll 81-87 or choose. A hunchback. Applied: +5 M.D.C."
    bonuses: { pools: { mdc: 5 } }
  - name: "Feature (88-94): Lizard Tail"
    description: "Roll 88-94 or choose. The tail of a lizard."
  - name: "Feature (95-00): Fur"
    description: "Roll 95-00 or choose. Covered in fur. Applied: +10 M.D.C."
    bonuses: { pools: { mdc: 10 } }
  - { choose: 1, from: ["Skin (01-10): Brown or Tan", "Skin (11-20): Reddish Brown", "Skin (21-30): Light or Dark Red", "Skin (31-40): Fiery Red", "Skin (41-50): Light Green", "Skin (51-60): Jade Green", "Skin (61-70): Light Blue", "Skin (71-80): Pale Grey", "Skin (81-90): Stark White or Ivory", "Skin (91-00): Mustard or Yellow Brown"], note: "Skin Color (printed 202), rolled once. Appearance only." }
  - name: "Skin (01-10): Brown or Tan"
    description: "Roll 01-10 or choose. Brown or tan skin."
  - name: "Skin (11-20): Reddish Brown"
    description: "Roll 11-20 or choose. Reddish brown skin."
  - name: "Skin (21-30): Light or Dark Red"
    description: "Roll 21-30 or choose. Light or dark red skin."
  - name: "Skin (31-40): Fiery Red"
    description: "Roll 31-40 or choose. Fiery red skin."
  - name: "Skin (41-50): Light Green"
    description: "Roll 41-50 or choose. Light green skin."
  - name: "Skin (51-60): Jade Green"
    description: "Roll 51-60 or choose. Jade green skin."
  - name: "Skin (61-70): Light Blue"
    description: "Roll 61-70 or choose. Light blue skin."
  - name: "Skin (71-80): Pale Grey"
    description: "Roll 71-80 or choose. Pale grey skin."
  - name: "Skin (81-90): Stark White or Ivory"
    description: "Roll 81-90 or choose. Stark white or ivory skin."
  - name: "Skin (91-00): Mustard or Yellow Brown"
    description: "Roll 91-00 or choose. Mustard or yellow brown skin."
natural_abilities:
  - { name: "Nightvision", description: "500 feet (152 m); can see even in total darkness." }
  - { name: "Fire and Cold Resistant", description: "Fire and cold do half damage." }
  - { name: "Impervious to Disease", description: "Cannot catch or suffer from disease." }
  - { name: "Bio-Regeneration", description: "2D6 M.D. per hour." }
  - { name: "Supernatural Attributes", description: "All attributes are considered supernatural, including P.S. and P.E." }
  - { name: "Mega-Damage Creature", description: "A supernatural being from another dimension. M.D.C. 2D6x10+40, plus any M.D.C. from the Other Features appearance table; no hit points or S.D.C." }
  - { name: "Natural Attacks", description: "Restrained claw 5D6 S.D.C. plus P.S. damage bonus; full strength claw, punch or kick 3D6 M.D.; gore with horns 2D6+6 M.D.; power punch 6D6 M.D. (counts as two attacks); leap kick 1D4x10 M.D. (counts as two attacks); body flip/throw 2D6 M.D. The appearance tables give bite, arm and head butt damage that varies by oni." }
restrictions:
  - "Primarily an N.P.C. villain. A player character is entirely at the G.M.''s discretion, and is likely an outcast among its kind - possibly because of an anarchist, unprincipled or scrupulous alignment."
  - "Alignment: 45% miscreant, 30% diabolic, 5% aberrant, 15% anarchist and 5% other."
  - "Psionics: none."
  - "Magic: the four power sets are natural abilities; the oni knows no spell magic and cannot learn it as a spell caster does."
  - "Technology: too ignorant and impatient to learn to operate power armor, computers and vehicles. Fewer than 15% use energy weapons, rail guns or human body armor, and those only at a rudimentary level."
  - "Size: 4 to 5 feet (1.2 to 1.5 m), unless the body shape table makes it a giant. Weight: 100 to 250 pounds (45 to 112.5 kg)."
  - "Average life span: 250+ years."
  - "Average experience level for N.P.C.s: third level for a typical warrior, 1D4+2 for elite warriors, 1D4+4 for a war chief or clan leader."
  - "Horror Factor 11 is the factor the oni projects, plus the bonus from its head shape; its +6 to save vs Horror Factor is in bonuses."
side_effects: "Weakness for alcohol, which can be used as a bribe or to gather information. Carnivores who prefer human flesh. Money and equipment: none printed. Oni favor clubs, swords and axes, prize captured vibro-blades, rune weapons and magic arms and armor, and increasingly steal M.D. body armor and energy weapons; oni masters know a secret ritual that makes melee weapons inflict mega-damage and armor gain M.D.C. Appearance is rolled on the nine oni creation tables (see Appearance below), and all nine - body shape, head, nose, eyes, mouth, arms and hands, legs, other features and skin color - are picks under special abilities, in the book''s order."
extraction_notes: "Rifts World Book 8: Japan printed 199-203 (text layer, page_offset +1: cache p200-p204). General oni rules on printed 199-200 (cache p200 is WELDED and was checked against a render; the text layer reads cleanly in column order). The appearance tables run printed 201-202 (cache p202-p203). The stat block is Oni of the One Hundred (Lesser Oni) on printed 202, right column, continued to the top of printed 203 (habitat, war band, clan, village, enemies, allies), read off a render of printed 202. || NPC: the book''s note makes these primarily N.P.C. villains, a player character at the G.M.''s discretion; stated in restrictions and GM Notes. || XP: the ''Sura-Kappa, Oni of the One Hundred'' column on the Experience Point Tables page (cache p217, printed 216, read off a render; third column, middle): lower bounds 0 / 2,001 / 4,001 / 8,201 / 16,401 / 24,501 / 34,601 / 49,701 / 69,801 / 94,901 / 129,001 / 179,101 / 229,201 / 279,301 / 329,401. || GROUP: a race, so men_of_arms: false (heading Oni of the One Hundred (Lesser Oni), an R.C.C.). No supersedes_race: this is a race, not a transformation. || ATTRIBUTES: I.Q., M.E., M.A. 2D6; P.S. 22+2D6; P.P. 12+2D6; P.E. 16+2D6; P.B. 1D6; all supernatural (prose). Spd is not a fixed roll: it comes from the Oni Legs table (5D6 human legs 01-15, 4D6 monkey 16-25, 6D6+10 classic oni 26-50, 6D6 for 51-90, 3D6 snail trunk 91-00). The class states 6D6, the figure of four of the eight rows, and since 2026-10-05 every Legs option states its own row''s dice as attribute_dice, so the pick sets Spd. || POOLS: M.D.C. 2D6x10+40, plus Other Features additions (prose). P.P.E. 5D6 for a typical warrior. No hit points or S.D.C. (mega-damage creature). No starting money or equipment is printed. || HORROR FACTOR 11 plus the head shape bonus (+0 to +4), carried since 2026-10-05 as horror_factor_bonus on each Head option (BOOK-INGEST-AUDIT.md F119) and read off a render of printed 201: +2 boar, lion/cat, skeletal, fish, bird, fox/canine and rat; +1 monkey and neanderthal; +3 melon and snake; +4 rotting skeleton; none for the human head. || COMBAT: four attacks per melee as attacks_base 4, plus one at levels 6 and 12 as at_level. No hand to hand skill is printed and no price for one, so no hand_to_hand block. Bonuses as printed: +1 initiative, +2 strike, parry and dodge, +2 pull punch, +1 roll with punch/fall/impact, +6 vs horror factor. Damage figures are a natural ability (prose). || MAGIC: four sets of natural powers, one chosen or rolled, up to 8 casts per 24 hours. Each set is a chosen special ability carrying its spells; Tongues, common to all four, is granted by the class. The 8 casts are a trackable resource. Spoil (food & water) is the catalog''s Spoil; animate/control dead is Animate and Control Dead; fly as the eagle and fire ball as catalogued. || SKILLS: catalog base + printed bonus: Intelligence 32+4, track humanoids as Tracking (people) 25+10, Land Navigation 36+15, Climbing 40+10, Swimming 50+10; W.P. Blunt, W.P. Sword and two W.P.s of choice (any). Japanese as Language: Native Tongue at 98%, Gobblely at 98%, Faerie as a Language: Other pick at 98% (no Faerie row), and two other languages (+10%) as Language: Other picks. Four secondary skills from espionage, physical, technical, rogue and wilderness, as printed on the race. || APPEARANCE: the oni creation tables (body shape, head, nose, eyes, mouth, arms and hands, legs, other features, skin color) are random appearance tables, nine of them on printed 201-202 under ''Roll once on each unless indicated otherwise'', paraphrased in the body. Since 2026-10-03 the five single-roll tables whose results carry a number have been banded choose-1 groups in special_abilities: Head Shape (Horror Factor +0 to +4, as horror_factor_bonus), Mouth (bite damage, prose), Arms & Hands (hand damage as prose; +1 attack at 21-30 and 76-85 and +4 entangle at 96-00 as bonuses), Legs (Spd dice; see 2026-10-05 below) and Other Features (M.D.C. +35, +10, +20, +25, +10, +5, +10 as pool bonuses; head butt damage prose). The four power-set options were renamed with their bands the same day so the wizard can roll them. || 2026-10-05, LEGS (printed 201, read off a render): the eight rows print 5D6 (01-15), 4D6 (16-25), 6D6+10 (26-50), 6D6 (51-60, 61-70, 71-80, 81-90) and 3D6 (91-00) speed attribute. Each option now carries that as attribute_dice for Spd (BOOK-INGEST-AUDIT.md F119), and the classic oni''s +10 Spd bonus was removed because its row''s dice state 6D6+10. The monkey legs'' +10% to balance and climbing and the snail trunk''s +4 to maintain balance stay prose. || 2026-10-05, THE OTHER FOUR TABLES: General Body Shape (nine rows), Oni Nose (ten) and Oni Eyes (nine) on printed 201 and Skin Color (ten) on printed 202, all read off renders, are now banded choose-1 groups too, one definition per row, so all nine tables can be rolled. None of their rows carries a number the sheet adds. Kept as the row''s prose: Nose 71-80 (a tiny nose of any type above, choose or roll again), Eyes 81-90 (four eyes, roll again or pick for the shape) and Body 91-95 (a giant, 8 feet +1D4 feet). The groups are ordered as the book prints them, after the power sets: body, head, nose, eyes, mouth, arms and hands, legs, other features, skin color. No existing option was renamed."
---

## Lore

Oni is the Japanese word for demon, and Japanese legend knows hundreds of kinds, most without a proper name: an oni is called by its look ("the three-armed oni"), its temper, its deeds or its master. They stand for the nameless terrors of the night and are always ugly or frightening: animal heads, misshapen faces with huge noses and crooked teeth, manes of wild black or red hair, big clawed two-toed feet, horns on at least half of them, hunched and oddly shaped bodies. Most are small and goblin-like, four or five feet tall, though the occasional giant turns up.

The Oni of the One Hundred are the commonest oni: dull-witted, cruel beings who delight in murder, torture, kidnapping, robbery and vandalism against anything weaker. Tens of thousands of them roam the wilderness of the islands and dominate The Zone. They come from a dimension long linked to Japan; only a few hundred lived there in ancient times, where they became the demons, ghosts and goblins of old tales, but when the Rifts opened they flooded in by the thousands.

They travel in small tribal war bands that raid villages, waylay travelers and even slip into the reborn cities of the Republic. They enslave humans, sometimes rule whole villages, and carry off women and children as slaves, sacrifices or food. Power is the only authority they respect: the strongest warrior or mightiest magic-wielder leads, and every leader is challenged the moment he looks weak. Outsiders - wizards, warlords, pirates, greater demons - gain oni minions by beating the chief and his rivals, and keep them only by terror. Clans war on each other constantly, and nearly every oni boasts that he will one day rule Japan.

Oni are bold in numbers but easily cowed: feats of magic, great strength or courage can scatter a band, and defeating its one to five ringleaders usually sends the rest fleeing. Not all of them frighten, though, and some fight to the death. All are liars and backstabbers. They fear and covet "man''s technology" - power armor, cyborgs, robots and energy weapons - and steal M.D. body armor, vibro-blades and guns, but are too impatient to learn machines. Most still fight with tooth and claw, sheer strength and natural magic. They eat any humanoid or animal they kill and have a notorious weakness for alcohol.

## Appearance

Oni are rolled on the book''s creation tables, one roll per table. Each of the nine is a pick under special abilities that can be rolled or chosen. In summary:

- **Body shape:** from perfectly human, broad and muscular, or skeletal, through a lumpy snail-like blob, a fat bald buddha, a neckless toad, a barrel-chested bird-body, a giant of 9 to 12 feet, to a scaled fish with fins and tail.
- **Head:** boar, lion or cat, human, sunken skeletal, monkey, huge melon-round, fish, snake, bird, rotting skull, neanderthal, fox or rat. Each non-human head adds +1 to +4 to Horror Factor (the rotting skull +4, melon and snake +3).
- **Nose:** normal, huge bulbous or pointed, broad and ape-like, a bird''s beak, an animal snout, a tiny version of any of these, snake slits, a rat''s nose, or none at all.
- **Eyes:** wild and crazed, huge glowing almond eyes, large pale or crystal-clear orbs, small red, yellow or black eyes, sparkling snake eyes, jade bird eyes, ordinary human eyes, four eyes, or a single large pale blue or violet eye.
- **Mouth:** from toad-like mouths of flat teeth to fanged monkey and canine muzzles, a toothless flabby mouth or a lipless slit with a snake''s tongue; the bite does from 1 M.D. up to 3D6 M.D. depending on the mouth.
- **Arms and hands:** human hands, a third small clawed arm (an extra attack), two-fingered claws, skeletal talons, monkey or rat-like limbs, five arms (an extra attack), bird claws, or tentacles that whip and grab. Claw damage runs from 1D4 to 3D6 M.D. by type.
- **Legs:** human legs, stubby monkey legs, the classic oni legs with two clawed toes, skeletal or bird legs, clawed human feet, bear-like animal legs, or a slithering snail trunk. The leg type sets Spd, from 3D6 to 6D6+10.
- **Other features:** rat or lizard tail, fine scales, small or large horns (head butts), a great mane, bushy brows and beard, lumpy pink flesh, a hairy red or tan hide, hairlessness, boils and scabs, a pot belly, a hunchback, or fur. Several of these add 5 to 35 M.D.C.
- **Skin color:** brown or tan, reddish brown, red, fiery red, light or jade green, light blue, pale grey, stark white or ivory, or mustard yellow-brown.

## Society

A small war band is 1D6+4 oni, a medium one 3D6+12, and the largest seldom pass 80. Clans run from 20 to 40 members up to 300 to 500. An oni village holds several hundred oni from more than one clan, some goblins, imps and other supernatural hangers-on, a few human or D-bee allies, and hundreds of human and D-bee slaves. They live in wilderness, mountains, slums, sewers and ruins across Japan, Taiwan, Korea, China, and parts of India and Southeast Asia, mostly in The Zone and the Freelands, with a few tribes in the New Empire''s backwaters and the Republic''s alleys.

Their ancient enemies are tengu, yamabushi, bishamon, demon quellers, samurai, psi-stalkers, Atlantean Undead Slayers and a handful of gods. They avoid faerie folk, elementals, dragons and the kilin as threats rather than foes. Their allies are other oni and demons, vampires, goblins and goblin spiders, ogres, trolls, gargoyles, evil dragons, priests and sorcerers; the Horune pirates have traded with them for decades.

## GM Notes

The book makes the Oni of the One Hundred primarily an N.P.C. villain and leaves a player character entirely to the G.M.''s discretion. Such a character is probably an outcast from its tribe, often for an anarchist, unprincipled or scrupulous alignment. The average N.P.C. warrior is third level; elite warriors 1D4+2, war chiefs and clan leaders 1D4+4. One oni in ten is an oni master and one in fifty an oni mystic (separate entries).
',
       updated_at = datetime('now')
 WHERE class_id = 'oni-of-the-one-hundred'
   AND instr(markdown, 'the three slower kinds are rerolled by hand') > 0
   AND length(markdown) = 28679;

-- == pseudo-men ==
UPDATE imported_classes
   SET markdown = '---
id: pseudo-men
name: Pseudo Men
system: rifts
source_book: Rifts World Book 29: Madhaven p.71-73
category: rcc
tags: [wilderness]
attribute_dice:
  IQ: "1d6+10"
  ME: "1d6+10"
  MA: "1d6+10"
  PS: "2d6+13"
  PP: "2d6+9"
  PE: "2d6+10"
  PB: "1d6+4"
  Spd: "2d6+8"
mdc_base: "2d4x10 plus the P.E. attribute number, +2d4 per level of experience"
ppe_base: "P.E. attribute number +1d6"
psionics_allowed: false
xp_table: [0, 2241, 4481, 8961, 17921, 25921, 35921, 50921, 70921, 95921, 135921, 185921, 225921, 275921, 335921]
bonuses:
  combat: { initiative: 1, strike: 1, parry: 1, dodge: 1, pull_punch: 2, roll: 4, perception: 1 }
  saves: { horror_factor: 5, mind_control: 6, possession: 6 }
variants:
  - id: standard
    name: "Pseudo Man"
  - id: shaman
    xp_table: [0, 2351, 4701, 9401, 18801, 28001, 38001, 53001, 77001, 102001, 143001, 195201, 240401, 310601, 360801]
    name: "Pseudo Man Shaman"
    ppe_base: "P.E. attribute number +1d6, +1d6 per level of experience"
    bonuses:
      attributes: { IQ: 2, MA: "1d4+2" }
      pools: { ppe: "3d6+10" }
      combat: { initiative: 1, strike: 1, parry: 1, dodge: 1, pull_punch: 2, roll: 4, perception: 1 }
      saves: { horror_factor: 5, mind_control: 6, possession: 6 }
    skills_additional:
      occ_skills:
        - { name: "Animal Husbandry", base: 45, per_level: 5, note: "+10%" }
        - { name: "Literacy: Native Language", base: 55, per_level: 5, note: "+15%. Printed as Literacy: Native Language (American)." }
        - { name: "Brewing: Medicinal", base: 40, per_level: 5, note: "+15%" }
        - { name: "Dance", base: 40, per_level: 5, note: "+10%" }
        - { name: "Fasting", base: 60, per_level: 3, note: "+20%" }
        - { name: "History: Pre-Rifts", base: 42, per_level: 4, note: "+10%" }
        - { name: "History: Post-Apocalypse", base: 55, per_level: 5, note: "+20%" }
        - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
        - { name: "Public Speaking", base: 50, per_level: 5, note: "+20%" }
        - { name: "Sing", base: 45, per_level: 5, note: "+10%" }
        - { name: "Veterinary Science", base: 60, per_level: 4, note: "+10%" }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Climbing", base: 55, per_level: 5, note: "+15%" }
    - { name: "Fishing", base: 50, per_level: 5, note: "+10%" }
    - { name: "First Aid", base: 55, per_level: 5, note: "+10%" }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20, printed without a percent sign." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Printed as Language (Native): American." }
    - { name: "Leather Working", base: 55, per_level: 5, note: "+15%" }
    - { name: "Mathematics: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Prowl", base: 35, per_level: 5, note: "+10%" }
    - { name: "Salvage", base: 45, per_level: 5, note: "+10%" }
    - { name: "Skin & Prepare Animal Hides", base: 45, per_level: 5, note: "+15%" }
    - { name: "Spelunking", base: 50, per_level: 5, note: "+15%" }
    - { name: "Tailing", base: 40, per_level: 5, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%. Printed as Tracking." }
    - { name: "Track & Trap Animals", base: 35, per_level: 5, note: "+15%. Printed as Trap & Track Animals." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, from: ["W.P. Spear", "W.P. Knife"], note: "W.P. Spear or W.P. Knife." }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two Ancient of choice." }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two Modern of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Cannot be changed." }
  secondary_skills:
    count: 8
    schedule:
      - { level: 2, count: 2 }
      - { level: 5, count: 2 }
      - { level: 8, count: 2 }
      - { level: 11, count: 2 }
      - { level: 14, count: 2 }
special_abilities:
  - { rolls: "1d4", from: ["Oddity (01-10): Great Speed and Reflexes", "Oddity (11-20): Muscular, Supernatural P.S.", "Oddity (21-30): 1D4 Extra Arms and Hands", "Oddity (31-35): Superior Climbing Ability", "Oddity (36-40): Fangs or Alligator Teeth", "Oddity (41-45): 1D4+1 Extra Horns, Two Large", "Oddity (46-50): Tech-Master", "Oddity (51-54): One Extra Eye, Sees the Invisible", "Oddity (55-58): One Extra Eye, Night Sight", "Oddity (59-62): One Extra Eye, Infrared", "Oddity (63-66): Rough, Hard Skin", "Oddity (67-70): Lizard Scales", "Oddity (71-74): Silky Bronze Skin", "Oddity (75-78): Natural Clown", "Oddity (79-82): Natural Hunter", "Oddity (83-86): Superior Intellect", "Oddity (87-89): Angelic Beauty", "Oddity (90-92): Nightstalker", "Oddity (93-95): Demon Slayer", "Oddity (96-97): Ghost Charmer", "Oddity (98-00): Divine Mutant"], note: "Random Unusual Abilities and Oddities (table printed 72, its rule printed 71): roll 1D4 for the number of rolls; a result rolled twice is ignored and rolled again. With the G.M.''s permission the player may choose instead, taking only one from 87-00." }
  - name: "Oddity (01-10): Great Speed and Reflexes"
    description: "Roll 01-10 or choose. Thin and fast: +3D6+10 Spd, +1 initiative, +1 strike and +1 attack per melee, all applied. Also Automatic Dodge at +3 (dodging uses up no melee attack or action), which is not applied."
    bonuses: { attributes: { Spd: "3d6+10" }, combat: { initiative: 1, strike: 1, attacks: 1 } }
  - name: "Oddity (11-20): Muscular, Supernatural P.S."
    description: "Roll 11-20 or choose. +2D6 P.S. and +4D6 M.D.C., both applied; the strength becomes Supernatural. Oddity, rolled on percentile dice by hand: 01-50 one extra arm, thin and puny beside the others (that arm alone has a total P.S. of 1D6+6 and none of the bonuses); 51-75 1D4 extra eyes, all on the front of the face; 76-00 a long, cat-like tail."
    bonuses: { attributes: { PS: "2d6" }, pools: { mdc: "4d6" } }
  - name: "Oddity (21-30): 1D4 Extra Arms and Hands"
    description: "Roll 21-30 or choose. +1D6 P.S., applied. Roll 1D4 for the number of extra arms by hand: +1 parry and +1 entangle for each extra arm and +1 attack per melee for each extra PAIR of arms, none of which is applied because it depends on that roll."
    bonuses: { attributes: { PS: "1d6" } }
  - name: "Oddity (31-35): Superior Climbing Ability"
    description: "Roll 31-35 or choose. +2 to roll with impact, applied. Also a further +15% to Climbing and Spelunking and the Acrobatics skill at +20%, which are added by hand."
    bonuses: { combat: { roll: 2 } }
  - name: "Oddity (36-40): Fangs or Alligator Teeth"
    description: "Roll 36-40 or choose. A bite that does 2D4+2 damage, Mega-Damage if the character has Supernatural P.S."
  - name: "Oddity (41-45): 1D4+1 Extra Horns, Two Large"
    description: "Roll 41-45 or choose. +3D6 M.D.C., applied. A head butt does 2D6 damage (Mega-Damage with Supernatural P.S.), and the horns can block and parry attacks at the usual bonuses."
    bonuses: { pools: { mdc: "3d6" } }
  - name: "Oddity (46-50): Tech-Master"
    description: "Roll 46-50 or choose. An affinity for machines: Basic Mechanics, Basic Electronics, General Repair & Maintenance and Jury-Rig, all at +15%, plus one extra modern W.P. Add the skills by hand."
  - name: "Oddity (51-54): One Extra Eye, Sees the Invisible"
    description: "Roll 51-54 or choose. One extra eye that can see the invisible."
  - name: "Oddity (55-58): One Extra Eye, Night Sight"
    description: "Roll 55-58 or choose. One extra eye with perfect day vision and Nightvision of 2000 feet (610 m)."
  - name: "Oddity (59-62): One Extra Eye, Infrared"
    description: "Roll 59-62 or choose. One extra eye with polarized vision that sees the infrared spectrum, including heat signatures and infrared light beams."
  - name: "Oddity (63-66): Rough, Hard Skin"
    description: "Roll 63-66 or choose. +1D6x10+45 M.D.C., applied. The skin feels like sandpaper."
    bonuses: { pools: { mdc: "1d6x10+45" } }
  - name: "Oddity (67-70): Lizard Scales"
    description: "Roll 67-70 or choose. Skin scaly like a lizard''s: +5D6+18 M.D.C., applied."
    bonuses: { pools: { mdc: "5d6+18" } }
  - name: "Oddity (71-74): Silky Bronze Skin"
    description: "Roll 71-74 or choose. Silky soft, bronze-colored skin: +2D6+8 M.D.C. and +1D4 to each of P.B. and M.A., all applied."
    bonuses: { attributes: { PB: "1d4", MA: "1d4" }, pools: { mdc: "2d6+8" } }
  - name: "Oddity (75-78): Natural Clown"
    description: "Roll 75-78 or choose. The extra skills Concealment, Imitate Voices & Sounds, Juggling, Palming and Public Speaking, all at +10%. Add them by hand."
  - name: "Oddity (79-82): Natural Hunter"
    description: "Roll 79-82 or choose. +1 strike, applied. Also +10% to all Tracking skills and the extra skills Camouflage, Detect Ambush, Recognize Weapon Quality and Wilderness Survival at +10%, which are added by hand."
    bonuses: { combat: { strike: 1 } }
  - name: "Oddity (83-86): Superior Intellect"
    description: "Roll 83-86 or choose. +2D4+4 I.Q., +1D4 M.E. and +2 to Perception Rolls. Oddity: an extra large skull with 1D4 medium-sized, crooked horns, -2 P.E. and -1D4 P.B. All five numbers are applied."
    bonuses: { attributes: { IQ: "2d4+4", ME: "1d4", PE: -2, PB: "-1d4" }, combat: { perception: 2 } }
  - name: "Oddity (87-89): Angelic Beauty"
    description: "Roll 87-89 or choose (when choosing, only one option from 87-00). Looks completely human and stunningly attractive: +2D6+4 P.B. and +1 M.A., but -1 M.E., -1D4 P.E. and -1D6 Spd, all applied. Also Seduction and I.D. Undercover Agent at +20%, which are added by hand."
    bonuses: { attributes: { PB: "2d6+4", MA: 1, ME: -1, PE: "-1d4", Spd: "-1d6" } }
  - name: "Oddity (90-92): Nightstalker"
    description: "Roll 90-92 or choose (when choosing, only one option from 87-00). A natural night predator. Only at night after sunset and in pitch darkness: +1 attack per melee, +3 initiative, +3 to strike, parry and dodge, +2 pull punch and +10% Prowl. Has Nightvision of 600 feet (183 m), prefers to sleep by day, and two of the eyes are large like an owl''s. Oddity: in the daytime and in brightly lit places the regular bonuses and skill performance are halved and the character has one attack per melee fewer. Nothing here is applied, because every number depends on the light."
  - name: "Oddity (93-95): Demon Slayer"
    description: "Roll 93-95 or choose (when choosing, only one option from 87-00). Only when battling supernatural beings, the undead, Entities or evil creatures of magic: +1 attack per melee, +100 M.D.C., +2 initiative, +1 to strike, parry and dodge and +5% Interrogation; none of those is applied. Hunts such creatures by instinct, is cocky and a loose cannon around the supernatural, and is impervious to all mind control and possession. Oddities: small, sharp teeth and eyes that glow red under strong emotion and when fighting the supernatural; -1D4 P.B. (applied), -20% to Disguise, Seduction and Public Speaking and -10% to Tailing, Prowl and Begging (by hand)."
    bonuses: { attributes: { PB: "-1d4" } }
  - name: "Oddity (96-97): Ghost Charmer"
    description: "Roll 96-97 or choose (when choosing, only one option from 87-00). Ghosts and all Entities take the character for a kindred spirit and never attack unless attacked first, and then fight only enough to escape. Sees the invisible; recognizes an Entity''s type even in its energy form at 01-80% +1% per level; impervious to possession by Entities and +5 to save vs their psionic and magical attacks. Beautiful Ghosts, Gluttonous Entities and Haunting Entities talk freely and answer truthfully, and come unasked with favors and complaints. Oddities: 1D4 extra eyes, pale skin and -1D4 P.B. (applied)."
    bonuses: { attributes: { PB: "-1d4" } }
  - name: "Oddity (98-00): Divine Mutant"
    description: "Roll 98-00 or choose (when choosing, only one option from 87-00). Punches and all physical attacks, handheld melee weapons included, do their S.D.C./Hit Point damage as Mega-Damage to Mega-Damage creatures and can touch and hurt Entities, Astral Beings and the ethereal. See Aura shows a pure white aura. +2 to save vs Horror Factor and +1 to save vs magic, both applied. Oddities: saves vs possession and vs mind control psionics and magic are permanently halved (by hand), and 01-90% of Divine Mutants have golden skin."
    bonuses: { saves: { horror_factor: 2, spell_magic: 1 } }
natural_abilities:
  - { name: "Robotic Strength", description: "Robotic P.S., so a full-strength punch or a power punch inflicts M.D. (Rifts Ultimate Edition p.285). Endurance is extraordinary." }
  - { name: "Minor Mega-Damage Being", description: "M.D.C. hide and bones; recovers 3D6 lost M.D.C. per 24 hours. Often wears body armor for extra protection." }
  - { name: "Kinship with Head Worms", description: "Head Worms, and most worms, snakes and serpents of animal or low intelligence, treat a Pseudo Man as one of their own: they never attack or bite him and let him handle, ride and command them. 1D4 Head Worms will gladly serve one as attack animals and guards. A Giant Ruin Worm is the exception, though it tends to attack a Pseudo Man last." }
  - { name: "Unusual Abilities and Oddities", description: "Roll 1D4 times on the Random Unusual Abilities and Oddities table (printed 72), or choose with the G.M.''s permission. The rolls are made in the Oddity pick group, which applies each row''s unconditional numbers." }
  - { name: "Horror Factor", description: "None for a Pseudo Man who looks human, 10 for one with horns, extra eyes or limbs or other oddities, 14 when commanding one or more Head Worms." }
  - { name: "Haven Mutant Psionic Immunity", description: "Immune to the psychic imprint of Madhaven, to Empathic Transmission, and to the fear and Horror Factor of Entities; emotion and mind affecting psionics and magic do not work on the character. Physical psionic attacks, most magic, energy weapons and physical attacks still harm it." }
  - { name: "Balance", description: "+5 to maintain balance." }
restrictions:
  - "An R.C.C. that takes NO O.C.C. Playable only with the G.M.''s approval."
  - "Can never pilot power armor or robot vehicles."
  - "Juicer conversion does not work; M.O.M. implants kill a Haven Mutant after 1D6 days."
  - "Psionics: none."
  - "Magic: none, and it shuns both learning and using it. Distrusts magic items, men of magic and creatures of magic."
  - "Cybernetics: none to start. Allowed, but few are interested and Madhaven has no Cyber-Doc."
  - "Hand to Hand: Expert, which cannot be changed."
side_effects: "Stands 5 to 7 feet tall (1.5-2.1 m) and weighs 100 to 300 lbs (45 to 135 kg). P.B. is 1D6+4, or +18 for one of the rare beauties. Could live to 100, but the warrior life puts average life expectancy at 1D6+40 for males and 2D6+50 for females."
level_progression:
  - { level: 2, grants: ["+2 Secondary Skills"] }
  - { level: 5, grants: ["+2 Secondary Skills"] }
  - { level: 8, grants: ["+2 Secondary Skills"] }
  - { level: 11, grants: ["+2 Secondary Skills"] }
  - { level: 14, grants: ["+2 Secondary Skills"] }
extraction_notes: |
  - Read from the text-layer cache (p072-p074, printed 71-73) and checked against 170 dpi renders of the ability table and the stat block.
  - Shaman variant: its skills are added by the variant; the removal of Secondary, Piloting and modern W.P. skills and the prayers are prose only (a variant cannot take a skill away). The Shaman XP ladder, the Gateway Knight & Mutant Shaman column of printed 79, was prose until BOOK-INGEST-AUDIT.md F108 made xp_table a variant key; ~030-f108-shaman-ladders.sql put it on the variant.
  - The Shaman variant restates the parent''s whole bonuses block, because a variant''s bonuses replace the parent''s; the +2 I.Q., +1D4+2 M.A. and +3D6+10 P.P.E. are added in it, and its ppe_base adds the +1D6 P.P.E. per level.
  - RANDOM UNUSUAL ABILITIES AND ODDITIES TABLE (2026-10-05, BOOK-INGEST-AUDIT.md F120 and F119): the rule is the last paragraph of printed 71 and the table is printed 72. The page prints 1D4 rolls on a percentile table, a result rolled twice ignored and rolled again, or a G.M.-approved choice with only one from 87-00. The table has 21 rows, counted on a 300 dpi render (01-10, 11-20, 21-30, 31-35, 36-40, 41-45, 46-50, 51-54, 55-58, 59-62, 63-66, 67-70, 71-74, 75-78, 79-82, 83-86, 87-89, 90-92, 93-95, 96-97, 98-00); the bands cover 01-00 with no gap or overlap. An earlier note here said 19 rows, which was a miscount. Stored as one special_abilities group with rolls 1d4 and 21 band-named options, one definition each.
  - What each row carries as keys is only what the page prints without a condition: Spd, initiative, strike and attacks (01-10); P.S. and M.D.C. (11-20); P.S. (21-30); roll with impact (31-35); M.D.C. (41-45, 63-66, 67-70); M.D.C., P.B. and M.A. (71-74); strike (79-82); I.Q., M.E., Perception, -2 P.E. and -1D4 P.B. (83-86); P.B., M.A., -1 M.E., -1D4 P.E. and -1D6 Spd (87-89); -1D4 P.B. (93-95 and 96-97); saves vs Horror Factor and magic (98-00, the +1 vs magic stored as spell_magic). Left in the descriptions: every skill and skill percentage, Automatic Dodge, the per-arm parry, entangle and attack of 21-30 (they hang on a 1D4 roll), the 11-20 sub-table of oddities, all of Nightstalker (night only) and the Demon Slayer combat bonuses and +100 M.D.C. (only against the supernatural), the halved saves of the Divine Mutant, and the limit of one choice from 87-00, which is in the group''s note.
  - The three 51-62 rows are all printed as One Extra Eye; the option names add what each eye does so the three can be told apart. The body''s list keeps its earlier headings for them.
  - M.D.C.: the stat block (printed 73) says +2D4 per level; natural ability 1 (printed 71) says +2D4+2. The stat block is stored; the other figure is noted here.
  - SECONDARY SKILLS ARE ROLLED: the book says 1D6+2. Stored as the maximum, 8, so any legitimately rolled count is within the allowance; the player takes what they roll.
  - Psionics: "Psionics: None" is psionics_allowed false, the convention for a race whose page prints None.
  - Tracking is the catalog row Tracking (people); Trap & Track Animals is the catalog row Track & Trap Animals.
  - Attacks come from Hand to Hand: Expert (four at level one), which is how the book states them.
  - Money: none in credits, so no starting_money. The 2D4x1000 in tradable goods is prose in the Equipment section.
  - Equipment is prose. It names a bone spear and a shiv (the Mutant Bone gear rows arrive with the Madhaven gear PR).
  - M.D.C. being, so mdc_base carries the pool and there is no S.D.C.
---

## Lore

Pseudo Men look the most human of the Haven Mutants, keeping a normal human
build and size, but almost every one carries some mark of the mutation. Most
wear a ring of gnarled horns along the hairline - red and black on males,
smaller and pink and white on females - and red or black hair, often grown into
dreadlocks. Many have a heavy lower jaw, a large mouth and a small chin, and
the least human have three to six eyes. About one in five has only two eyes and
small or no horns and can pass for human. One in twenty is flawlessly, angelically
beautiful, and uses that face, and hidden powers, to lure and trick outsiders.
No two look alike.

They are fond of technology: they wear whatever M.D.C. armor they can find or
take, and prize energy weapons and Vibro-Blades. Magic, its users and creatures
of magic they distrust. By temperament they are brash warriors and daredevils,
quick to take up any challenge of strength, nerve or cunning.

They trade regularly with Horune Pirates and slavers without trusting them,
hold to a wary peace with the White Rose knights, and dislike
barbarians and the Minions of Splugorth. Many live high up in the few buildings
still standing in the ruins.

## Random Unusual Abilities and Oddities

Roll 1D4 to see how many times to roll on this table; an NPC usually has two or
three. With the G.M.''s permission a player may choose instead, taking no more
than one from 87-00. A repeated result is rerolled. The table is the Oddity
pick group: the wizard rolls it, and each row''s unconditional numbers are
applied. Skills, and anything that holds only under a condition, are added to
the sheet by hand.

- **01-10 Great Speed and Reflexes:** +3D6+10 Spd, +1 initiative, +1 strike,
  Automatic Dodge (+3; dodging costs no melee action), +1 attack per melee.
- **11-20 Muscular, Supernatural P.S.:** +2D6 P.S., which becomes Supernatural,
  and +4D6 M.D.C. Oddity (percentile): 01-50 one thin, puny extra arm (total
  P.S. 1D6+6, no bonuses); 51-75 1D4 extra eyes on the face; 76-00 a long,
  cat-like tail.
- **21-30 1D4 Extra Arms and Hands:** +1 parry and +1 entangle per extra arm,
  +1 attack per extra pair of arms, +1D6 P.S.
- **31-35 Superior Climbing:** +15% more to Climbing and Spelunking, +2 roll
  with impact, and gains Acrobatics (+20%).
- **36-40 Fangs or Alligator Teeth:** a bite for 2D4+2 (M.D. with Supernatural
  P.S.).
- **41-45 1D4+1 Extra Horns, Two Large:** +3D6 M.D.C.; head butts for 2D6 (M.D.
  with Supernatural P.S.); may block and parry with the horns at the usual
  bonuses.
- **46-50 Tech-Master:** gains Jury-Rig, Basic Electronics, Basic Mechanics
  and General Repair & Maintenance at +15%, plus one extra modern W.P.
- **51-54 Third Eye, True Sight:** sees the invisible.
- **55-58 Third Eye, Night Sight:** Nightvision 2000 feet (610 m) and perfect
  day vision.
- **59-62 Third Eye, Infrared:** polarized vision; sees infrared, including heat
  signatures and infrared beams.
- **63-66 Rough, Hard Skin:** +1D6x10+45 M.D.C.; sandpaper to the touch.
- **67-70 Lizard Scales:** +5D6+18 M.D.C.
- **71-74 Silky Bronze Skin:** +2D6+8 M.D.C., +1D4 each to P.B. and M.A.
- **75-78 Natural Clown:** gains Juggling, Palming, Concealment, Public
  Speaking and Imitate Voices & Sounds at +10%.
- **79-82 Natural Hunter:** +1 strike, +10% to all Tracking skills, and gains
  Wilderness Survival, Camouflage, Recognize Weapon Quality and Detect Ambush
  at +10%.
- **83-86 Superior Intellect:** +2D4+4 I.Q., +1D4 M.E., +2 Perception. Oddity:
  an oversized skull with 1D4 crooked horns; -2 P.E. and -1D4 P.B.
- **87-89 Angelic Beauty:** fully human and stunning. +2D6+4 P.B., +1 M.A.,
  gains Seduction and I.D. Undercover Agent at +20%; but -1 M.E., -1D4 P.E. and
  -1D6 Spd.
- **90-92 Nightstalker:** at night and in darkness only: +1 attack, +3
  initiative, +3 strike, parry and dodge, +2 pull punch, +10% Prowl, and
  Nightvision 600 feet (183 m). Sleeps by day; two owl-like eyes. Oddity: in
  daylight or bright light, halve his normal bonuses and skills and -1 attack.
- **93-95 Demon Slayer:** against supernatural beings, undead, Entities and
  evil creatures of magic: +1 attack, +100 M.D.C., +2 initiative, +1 strike,
  parry and dodge, +5% Interrogation. Driven to hunt such things, cocky around
  them, and impervious to mind control and possession. Oddities: small sharp
  teeth, eyes that glow red under strong emotion or in such fights; -1D4 P.B.,
  -20% to Disguise, Seduction and Public Speaking, -10% to Tailing, Prowl and
  Begging.
- **96-97 Ghost Charmer:** ghosts and Entities treat him as kin and never attack
  unless he attacks first, and then only to escape. Sees the invisible;
  identifies an Entity''s type even in energy form at 01-80% +1% per level;
  impervious to possession by Entities; +5 to save vs their psionics and magic.
  Beautiful Ghosts, Gluttonous and Haunting Entities talk to him freely and
  truthfully, and come to him with favors and complaints. Oddities: 1D4 extra
  eyes, pale skin, -1D4 P.B.
- **98-00 Divine Mutant:** punches, physical attacks and handheld melee weapons
  deal their normal S.D.C. or Hit Point damage as Mega-Damage to M.D. beings,
  and can hurt Entities, Astral Beings and other ethereal things. See Aura shows a pure white
  aura. +2 vs Horror Factor, +1 vs magic. Oddities: saves vs possession and mind
  control are permanently halved; 01-90% have golden skin.

## Equipment

A bone spear and a shiv, one weapon for each W.P. with 1D4+1 extra E-Clips,
2D4 days of food and water, a suit of light patchwork armor of 4D6+6 M.D.C.,
boots, pants, leather gloves and vest, a jacket or cloak, a utility belt, a
backpack, a large sack or satchel, a waterskin or canteen, 50 feet (15.2 m) of
climbing rope, 1D6+3 metal spikes, a small mallet and personal items.

Money: no credits, but 2D4x1000 worth of tradable goods - pre-Rifts trinkets
and artifacts, or loot taken from outsiders.

## Mutant Shaman

A large clan is led by a Shaman, who may be of any Haven Mutant race. The
`shaman` variant adds the attribute and P.P.E. bonuses and the Shaman''s skills.
What the app does not apply:

- The Shaman skill list REPLACES all Secondary Skills, Piloting skills and
  modern W.P. skills. A Shaman never uses a modern weapon, vehicle or machine.
  Drop the secondary picks, W.P. Energy Pistol and the two modern W.P. picks by
  hand.
- Shamans are the clan''s lawgivers, judges and leaders.
- **Prayer of Strength** to Isis, the Mighty Lady: 01-20% +5% per level to be
  heard, up to six times a year. If answered: +6 P.S., +1D4x10 M.D.C., and 48
  hours without food or water with no ill effect.
- **Prayer of Inspiration or Wisdom:** 01-12% +3% per level (+10% after a week
  of fasting). If answered, a dream brings insight, an idea or a warning about
  the matter prayed over.
- A Shaman levels on the Gateway Knight & Mutant Shaman ladder (printed 79):
  0 / 2,351 / 4,701 / 9,401 / 18,801 / 28,001 / 38,001 / 53,001 / 77,001 /
  102,001 / 143,001 / 195,201 / 240,401 / 310,601 / 360,801.

## GM Notes

Average level of experience 1D6+3. Alignment runs Anarchist 30%, Scrupulous 20%, Unprincipled
20%, Principled 10%, Aberrant 10%, and other evil alignments 10%.
',
       updated_at = datetime('now')
 WHERE class_id = 'pseudo-men'
   AND instr(markdown, 'the frontmatter has no random-table construct') > 0
   AND length(markdown) = 15834;

-- == amphib ==
UPDATE imported_classes
   SET markdown = '---
id: amphib
name: Amphib
system: rifts
source_book: Rifts World Book 7: Underseas p.98-100
category: rcc
tags: [aquatic]
xp_table: [0, 1971, 3941, 7881, 14881, 21881, 31881, 41221, 54441, 74661, 104881, 139221, 189441, 239661, 290881]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "4d6"
  PS: "3d6+12"
  PP: "4d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "3d6"
hit_points_base: "P.E. x2, +1d6 per level"
sdc_base: "3d6x10"
ppe_base: "3d6"
yields_to_occupation: { ppe_base: [magic] }
bonuses:
  combat: { dodge: 2, roll: 1, pull_punch: 1 }
restrictions:
  - "Alignment: any, but most tend to good or selfish alignments."
  - "SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. Printed 100 has the player select either the Sea Wolf or the Tritonian Scientist O.C.C., or any other appropriate O.C.C. at the G.M.''s call including a magic O.C.C., and then REDUCE the number of available O.C.C. skills by three. The app has no way to say that; see BOOK-INGEST-AUDIT.md F23(a). Pick a second class by hand and drop three of its O.C.C. skills."
  - "Experience: use the Amphib table or the chosen O.C.C.''s table, whichever is HIGHER."
  - "THE STORED COMBAT BONUSES ARE ALL UNDERWATER-ONLY. Printed 100 gives +2 to dodge and +1 to roll with impact and pull punch underwater, and nothing on land. They are stored unconditionally because an amphib is an aquatic character and the sheet has no conditional slot - but a G.M. running an amphib on dry land should ignore all three."
  - "P.B. AND SWIMMING SPEED ARE ROLLED ON AN APPEARANCE TABLE: roll or pick the Appearance ability, whose seven options are the seven rows. Each row carries its own P.B. dice (3D6, 3D4, 2D6, 2D4, 2D6, 1D6, 1D6) and P.B. is rolled on the picked row''s dice; the class''s own 3D6 is the first row''s and is what shows before a row is picked. Spd 3D6 is the LAND speed; underwater it is 6D6 plus the row''s swimming bonus, which stays prose on the option because there is no swimming-speed field."
  - "S.D.C. is 3D6x10 plus skill, O.C.C. and appearance bonuses. The appearance bonus alone runs from nothing to 2D4x10."
  - "M.D.C.: by armour or magic only. The amphib is an S.D.C. creature."
  - "Horror Factor: 8, and only for those not used to the more unusual specimens."
  - "P.P.E. is 3D6 unless the character takes a magic O.C.C., whose own P.P.E. then applies (printed 99; yields_to_occupation, BOOK-INGEST-AUDIT F111)."
  - "Average life span: 90 years."
  - "Psionics: normal, the same as a human''s. No psionic block is granted."
  - "Magic: only if a magic O.C.C. is selected."
  - "There are over 100,000 amphibs living in the floating city of Tritonia."
special_abilities:
  - { choose: 1, from: ["Appearance (01-20): Perfect Human", "Appearance (21-40): Webbed Hands and Feet", "Appearance (41-60): Frog Skin", "Appearance (61-70): Fish Face", "Appearance (71-80): Scaly Skin", "Appearance (81-90): Scaly Skin and Fish Face", "Appearance (91-00): Oversized, Fish or Frog-Like"], note: "Appearance table (printed 99): roll percentile or, with the G.M.''s leave, pick one." }
  - name: "Appearance (01-20): Perfect Human"
    description: "Printed 99, roll 01-20. Looks entirely human, with no visible aquatic feature. No underwater speed bonus and no S.D.C. bonus. Holds its breath rather than breathing water. Applied: P.B. is rolled on 3D6."
    attribute_dice: { PB: "3d6" }
  - name: "Appearance (21-40): Webbed Hands and Feet"
    description: "Printed 99, roll 21-40. Flat webbed feet and webbing between the fingers; shoes and armoured footwear must be custom-made. Underwater speed +3D6, and +10 more when swimming with little or no clothing (prose: there is no swimming-speed field). No S.D.C. bonus. About 40% have gills as well as lungs; the other 60% hold their breath for inhumanly long periods. Applied: P.B. is rolled on 3D4."
    attribute_dice: { PB: "3d4" }
  - name: "Appearance (41-60): Frog Skin"
    description: "Printed 99, roll 41-60. Hairless, with unnaturally smooth, slick skin that is usually greenish-grey. Swimming speed +2D6, and +6 more with little or no clothing (prose: there is no swimming-speed field). Holds its breath. Applied: P.B. is rolled on 2D6, and +4D6 S.D.C."
    attribute_dice: { PB: "2d6" }
    bonuses: { pools: { sdc: "4d6" } }
  - name: "Appearance (61-70): Fish Face"
    description: "Printed 99, roll 61-70. A fish-shaped head with large, round, dark eyes and a wide mouth; the head may be finely scaled while the body keeps ordinary skin. Helmets and headgear must be custom-made. Swimming speed +2D6, and +8 more with little or no clothing (prose: there is no swimming-speed field). Breathes air and has gills for water. Applied: P.B. is rolled on 2D4, and +3D6 S.D.C."
    attribute_dice: { PB: "2d4" }
    bonuses: { pools: { sdc: "3d6" } }
  - name: "Appearance (71-80): Scaly Skin"
    description: "Printed 99, roll 71-80. Hairless and covered in scales. Swimming speed +2D6, and +8 more with little or no clothing (prose: there is no swimming-speed field). Breathes air and has gills for water. Applied: P.B. is rolled on 2D6, and +5D6 S.D.C."
    attribute_dice: { PB: "2d6" }
    bonuses: { pools: { sdc: "5d6" } }
  - name: "Appearance (81-90): Scaly Skin and Fish Face"
    description: "Printed 99, roll 81-90. Hairless, fish-scaled, with webbed hands and feet and the head of a fish on an otherwise humanoid body. Swimming speed +4D6, and +10 more with little or no clothing (prose: there is no swimming-speed field). Breathes air and has gills for water. Applied: P.B. is rolled on 1D6, and +6D6 S.D.C."
    attribute_dice: { PB: "1d6" }
    bonuses: { pools: { sdc: "6d6" } }
  - name: "Appearance (91-00): Oversized, Fish or Frog-Like"
    description: "Printed 99, roll 91-00. More frog or fish than human, and big: 8 feet (2.4 m) plus 4D6 inches tall, and 300 lbs (136 kg) plus 2D6x10 lbs. Swimming speed +4D6, and +20 more with little or no clothing (prose: there is no swimming-speed field). The row prints no breathing line. Applied: P.B. is rolled on 1D6, and +2D4x10 S.D.C."
    attribute_dice: { PB: "1d6" }
    bonuses: { pools: { sdc: "2d4x10" } }
natural_abilities:
  - name: "Appearance"
    description: "Rolled on a percentile table at creation (printed 99), from 01-20 Perfect Human to 91-00 Oversized. Each of the seven rows sets the P.B. dice, an underwater speed bonus, an S.D.C. bonus and whether the amphib has gills. Roll or pick the row under the Appearance choice; each row''s figures are on its own entry there. Shoes, headgear and armour need custom fitting for most of these, and Tritonia has facilities for exactly that."
  - name: "Breathe Underwater"
    description: "A human-looking or frog-like amphib holds its breath for 5D6x3 minutes and must eventually surface, like a dolphin; using any artificial breathing apparatus it consumes less oxygen, effectively doubling the air and the time. A scaly, fish-like amphib has both lungs and gills and stays under indefinitely."
  - name: "Nightvision"
    description: "Excellent vision, seeing clearly in the near-total absence of light to 200 feet (61 m)."
  - name: "Resistant to Cold"
    description: "Survives indefinitely at freezing or near-freezing temperatures and takes half damage from cold-based attacks."
  - name: "Depth Tolerance"
    description: "Endures pressure at one mile (1.6 km) plus 300 feet (91.5 m) per level of experience without ill effect, and never gets the bends."
  - name: "Acute Underwater Senses"
    description: "Taste, hearing and smell are about four times as acute as a human''s underwater, letting the amphib taste or smell blood, death and decay, and foreign chemicals in the water at roughly 1000 yards/metres plus 100 per level of experience."
  - name: "Natural Combat"
    description: "As a human''s, depending on training. A restrained punch does 1D6 S.D.C. plus P.S. bonus, a full strength punch 3D6 S.D.C. plus P.S. bonus, and a power punch 1D4 M.D. counting as two attacks - the one mega-damage attack an otherwise S.D.C. race has."
extraction_notes: |
  - Underseas, printed 98-100. A race rather than an occupation: the product
    of pre-Rifts genetic experiments crossing humans with frogs and fish, of
    which 90% of the strains were crippling or lethal and the surviving 10%
    bred true.
  - ITS SKILLS ARE ANOTHER CLASS''S AND ARE NOT STORED. This is the SECOND
    Underseas class to hit BOOK-INGEST-AUDIT.md F23(a), after the Sea
    Inquisitor, and it is the harder of the two: printed 100 does not merely
    borrow a list, it borrows one AND REDUCES IT BY THREE. There is no key for
    "use that class''s list" and none for "minus three from it". Added to
    F23(a)''s affected rows rather than filed as a new finding, per the batch
    rule. A character built from this row alone has no skills at all, which is
    the book''s shape rather than a dropped count.
  - THE STORED COMBAT BONUSES ARE UNDERWATER-ONLY AND ARE STORED ANYWAY. This
    is a deliberate exception to the rule that a conditional bonus is prose.
    Every other conditional in this book - a speed burst, a combat form, a
    bonus against supernatural beings - is a temporary state. Being underwater
    is this race''s normal condition, and a character sheet showing an amphib
    with no bonuses at all would be wrong more often than it was right. The
    condition is stated plainly in the restrictions.
  - THE APPEARANCE TABLE IS A CHOOSE-1 SPECIAL ABILITY WITH SEVEN BANDED
    OPTIONS, one per row of printed 99, each named for its band so the wizard
    can roll it. A row''s S.D.C. bonus is the option''s `bonuses.pools.sdc` and is
    applied. Its P.B. dice are the option''s own `attribute_dice` (see the
    2026-10-05 note below). Its swimming-speed bonus stays prose in the
    option''s description, because swimming speed has no attribute of its own.
    NOT modelled as `variants`: a variant replaces a block, and this is a roll
    rather than a choice.
  - 2026-10-05: EACH APPEARANCE ROW NOW CARRIES ITS P.B. DICE
    (BOOK-INGEST-AUDIT.md F119). All seven rows were re-read off a render of
    printed 99: 01-20 "P.B. is rolled on 3D6", 21-40 "P.B. is 3D4", 41-60
    "The P.B. is 2D6", 61-70 "P.B. is 2D4", 71-80 "P.B. is 2D6", 81-90 "P.B.
    is 1D6", 91-00 "P.B. is 1D6". Stored as `attribute_dice: { PB: ... }` on
    each option, the first row''s 3D6 included so that every row states its
    own. The class-level P.B. 3D6 is kept as the first row''s figure; the
    Attributes line itself prints only "P.B. varies with appearance". The
    sentences telling the player to roll P.B. again on the row''s dice
    themselves are gone. The S.D.C. bonuses (none, none, 4D6, 3D6, 5D6, 6D6,
    2D4x10) and the swimming bonuses (none, 3D6 +10, 2D6 +6, 2D6 +8, 2D6 +8,
    4D6 +10, 4D6 +20) were checked against the same render and all agree with
    what was already stored. The swimming bonuses remain prose: there is no
    swimming-speed field.
  - ALL SEVEN APPEARANCE ROWS ARE PRESENT AND ARE TRANSCRIBED. A first draft of
    this class claimed the table skipped 41-70 and called it OCR loss. THAT WAS
    WRONG, and it was wrong because the page was read through too short a
    window rather than because the cache was damaged: rows 41-60 (Frog Skin)
    and 61-70 (Fish Face) sit exactly where they should on printed 99. The same
    short read also conflated row 21-40 with row 61-70, giving the webbed-feet
    result the fish-face numbers. Both were caught by going back to the page
    before shipping. The table covers 01-00 with no gap.
  - SPD IS THE LAND SPEED of 3D6. Underwater it is 6D6 plus the appearance
    bonus, which can be another 4D6+20.
  - IT HAS ONE MEGA-DAMAGE ATTACK AND IS OTHERWISE AN S.D.C. RACE: the power
    punch does 1D4 M.D. `mdc_base` is absent and `sdc_base` is used, per
    printed 99, which says M.D.C. is by armour or magic only.
---

# Amphib

## Lore

The amphib race is the product of illegal genetic experiments dating from before the Coming of the Rifts - humans crossed with frogs and fish by scientists who wanted beings that looked entirely human and could breathe and swim underwater without equipment.

The mutations were unstable. Ninety percent of the strains were crippling or lethal, and hundreds of volunteers died horribly. When the atrocities became public the project was shut down and those responsible were punished for crimes against humanity.

That left the surviving ten percent: highly capable undersea creatures with superior strength, resistance to pressure and the ability to breathe both air and water. Most were humanoid, many were not human-looking, and most could reproduce - which meant mankind had accidentally created a new race. Under public scrutiny the government made them heroes rather than an embarrassment, and assigned them to the Tritonia project to explore and harness the last great wilderness on Earth.

## GM Notes

Over the centuries the amphibs have prospered on Tritonia, where more than a hundred thousand of them live. They get on with most intelligent creatures, have strong ties to Tritonia''s naut''yll community, and have a special relationship with dolphins - who regard them as friends and playmates closer than humans, able to swim alongside them while keeping the best human traits. Some dolphins and amphibs insist they are kindred spirits and children of the sea, and the two are often sent out together on exploration and rescue.

Because most amphibs need no breathing equipment and endure great depths, they take the jobs that require it: deep sea diving, underwater construction and exploration. Many join the Sea Wolves as scouts, others become scientists, marine biologists and researchers, and a few learn water magic from dolphins, whale singers and other aquatic races.
',
       updated_at = datetime('now')
 WHERE class_id = 'amphib'
   AND instr(markdown, 're-roll it by hand, the sheet rolls 3D6') > 0
   AND length(markdown) = 12468;

-- == tattooed-man ==
UPDATE imported_classes
   SET markdown = '---
id: tattooed-man
occ_group: men-of-arms
name: Tattooed Man
system: rifts
source_book: Rifts World Book 2: Atlantis p.93-94
category: occ
tags: [combat]
race_restrictions: { only: ["none"], note: "The book''s T-Men are human (83%), ogre (5%) or elf (12%). Played with no R.C.C.: the catalog''s ogre and elf races are Palladium Fantasy rows whose own P.P.E. would replace the tattoo pools, so ogres take the ogre variants here and an elf takes a human variant with the elven tattoo penalties in the body." }
mdc_base: 60
ppe_base: "5d6+82, +10 per level of experience"
xp_table: [0, 2501, 5001, 10001, 20001, 30001, 45001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
variants:
  - id: "human-male"
    name: "Tattooed Man (human or elf, male)"
    # 12 starting tattoos, six above six: 6 x 10 M.D.C.
    mdc_base: 60
    ppe_base: "5d6+82, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { choose: 3, categories: ["Domestic"], bonus: 10, note: "Select three domestic skills (+10%)." }
        - { choose: 2, categories: ["Weapon Proficiencies"], note: "Select two W.P." }
        - { choose: 2, categories: ["Wilderness"], bonus: 5, note: "Select two wilderness skills (+5%)." }
        - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Learned as a slave. The book prints no change or upgrade price." }
  - id: "human-female"
    name: "Tattooed Woman (human or elf, female)"
    # 12 starting tattoos, six above six: 6 x 11 M.D.C.; P.P.E. six higher.
    mdc_base: 66
    ppe_base: "5d6+88, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { choose: 3, categories: ["Domestic"], bonus: 10, note: "Select three domestic skills (+10%)." }
        - { choose: 2, categories: ["Weapon Proficiencies"], note: "Select two W.P." }
        - { choose: 2, categories: ["Wilderness"], bonus: 5, note: "Select two wilderness skills (+5%)." }
        - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Learned as a slave. The book prints no change or upgrade price." }
  - id: "ogre-male"
    name: "Tattooed Man (ogre, male)"
    mdc_base: 60
    ppe_base: "5d6+82, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { choose: 2, categories: [{ name: "Rogue", except: ["Computer Hacking"] }], bonus: 10, note: "Select two rogue skills (+10%; excluding computer skills)." }
        - { choose: 4, categories: ["Weapon Proficiencies"], note: "Select four W.P." }
        - { choose: 3, categories: ["Wilderness"], bonus: 5, note: "Select three wilderness skills (+5%)." }
        - { choose: 1, from: ["Hand to Hand: Expert", "Hand to Hand: Assassin"], base: 0, note: "Hand to Hand: Expert or Assassin." }
  - id: "ogre-female"
    name: "Tattooed Woman (ogre, female)"
    mdc_base: 66
    ppe_base: "5d6+88, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { choose: 2, categories: [{ name: "Rogue", except: ["Computer Hacking"] }], bonus: 10, note: "Select two rogue skills (+10%; excluding computer skills)." }
        - { choose: 4, categories: ["Weapon Proficiencies"], note: "Select four W.P." }
        - { choose: 3, categories: ["Wilderness"], bonus: 5, note: "Select three wilderness skills (+5%)." }
        - { choose: 1, from: ["Hand to Hand: Expert", "Hand to Hand: Assassin"], base: 0, note: "Hand to Hand: Expert or Assassin." }
bonuses:
  attributes: { ME: 2, PS: 1, PE: 2, Spd: 6 }
  saves: { spell_magic: 2, ritual_magic: 2, horror_factor: 6 }
  pools: { mdc: 10 }
skills:
  occ_skills:
    - { choose: 2, categories: ["Physical"], note: "Select two physical skills." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Select two languages (+15%)." }
  occ_related_skills:
    count: 8
    minimums:
      - { count: 2, category: "Weapon Proficiencies" }
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"], bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5, except: ["Robots & Power Armor", "Air Assault Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Cyberjacking"] }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 8
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Air Assault Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Cyberjacking"] }
      - "Weapon Proficiencies"
      - "Wilderness"
magic:
  type: "spell"
  spell_traditions_allowed: ["tattoo"]
  spells: ["Tattoo: All Simple Weapons", "Tattoo: Animals", "Tattoo: Monsters"]
  spells_starting: 6
  spells_starting_groups:
    - { count: 2, from_list: "magic_weapons", note: "Two magic weapon tattoos." }
    - { count: 2, from_list: "powers", note: "Two power tattoos." }
    - { count: 2, from_list: "any", note: "Two more tattoos from any of the five categories. An extra simple weapon, animal or monster is one more image under the row already held: note it on the sheet and take nothing here for it." }
  spell_lists:
    magic_weapons: ["Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield"]
    powers: ["Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    any: ["Tattoo: S.D.C. Shield", "Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    major: ["Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)", "Tattoo: S.D.C. Shield"]
  spells_schedule:
    - { level: 2, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 3, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 4, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 5, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 6, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 7, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 8, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 9, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 10, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 11, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 12, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 13, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 14, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 15, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
special_abilities:
  - name: "Magic Tattoos"
    description: "Starts with 12 tattoos: two simple weapons, two magic weapons, two animals, two monsters, two powers, and two more from any of the five categories. The simple weapons are two images under the All Simple Weapons row (or one of them may be the S.D.C. Shield), the two animals two images under the Animals row, and the two monsters two images under the Monsters row. Each level from second the master adds two simple tattoos (animal or simple weapon) or one major tattoo (power, monster or magic weapon). No more than two tattoos at a time, at least six months between pairs, and no tattoo may be duplicated on one body. Activating a tattoo counts as one melee action; from seventh level a T-Man activates by concentration alone, without touching the image. No more than six tattoos may be active at once."
  - name: "M.D.C. Transformation"
    description: "Each tattoo above six gives a male T-Man 10 M.D.C. and a female 11, making the character a mega-damage creature. The variants store this for the 12 starting tattoos (60 or 66); add 10 or 11 for every tattoo gained later. One to six tattoos do not change an ordinary human''s body. The class bonus of +10 M.D.C. is added on top."
  - name: "Increased P.P.E."
    description: "Base P.P.E. 5D6 for an adult male, plus six for an adult female; 1D4x10 for a child or teenage male and 1D4x10+8 for a female. Add 10 per level of experience and six per tattoo. The 12 starting tattoos and the first level are the +82 in ppe_base; add 10 more each level and six for every tattoo gained later. Can also draw energy from ley lines and nexus points, but cannot draw P.P.E. from other living beings or from a death."
  - name: "Increased P.P.E. Recovery"
    description: "Recovers 10 P.P.E. per hour of rest or sleep, twice the normal rate."
  - name: "Tattoos Only"
    description: "Cannot cast spells, make circles or perform rituals, and cannot learn to. A practitioner of magic who receives seven or more tattoos loses all other mystic powers for good and starts as a first level T-Man, keeping his old skills frozen until he reaches their level again."
  - { rolls: 2, from: ["T-Man Insanity (01-30): No Insanity", "T-Man Insanity (31-40): Obsession, Fighting and Competition", "T-Man Insanity (41-43): Obsession, Hates Fighting", "T-Man Insanity (44-50): Obsession, Danger", "T-Man Insanity (51-55): Phobia, Tattoos", "T-Man Insanity (56-60): Phobia, Splugorth", "T-Man Insanity (61-63): Phobia, Alchemists", "T-Man Insanity (64-65): Phobia, Ancient Dragons", "T-Man Insanity (66-73): Random Affective Disorder", "T-Man Insanity (74-80): Random Phobia", "T-Man Insanity (81-88): Random Obsession", "T-Man Insanity (89-00): Random Insanity"], note: "T-Men Insanity Table (printed 94): roll twice, or pick two. Roll once more on this table for every five additional tattoos and note that result on the sheet." }
  - name: "T-Man Insanity (01-30): No Insanity"
    description: "Roll 01-30 or choose. No insanity from this roll."
  - name: "T-Man Insanity (31-40): Obsession, Fighting and Competition"
    description: "Roll 31-40 or choose. Obsessed with fighting and competition, and loves both."
  - name: "T-Man Insanity (41-43): Obsession, Hates Fighting"
    description: "Roll 41-43 or choose. Obsessed with fighting, but hates it and tries to avoid it."
  - name: "T-Man Insanity (44-50): Obsession, Danger"
    description: "Roll 44-50 or choose. Obsessed with danger: loves it and takes needless risks."
  - name: "T-Man Insanity (51-55): Phobia, Tattoos"
    description: "Roll 51-55 or choose. Phobia of tattoos: cannot stand to get another and must be restrained to receive a new one, even an ordinary tattoo."
  - name: "T-Man Insanity (56-60): Phobia, Splugorth"
    description: "Roll 56-60 or choose. Phobia of the Splugorth."
  - name: "T-Man Insanity (61-63): Phobia, Alchemists"
    description: "Roll 61-63 or choose. Phobia of alchemists."
  - name: "T-Man Insanity (64-65): Phobia, Ancient Dragons"
    description: "Roll 64-65 or choose. Phobia of ancient dragons."
  - name: "T-Man Insanity (66-73): Random Affective Disorder"
    description: "Roll 66-73 or choose. Roll for a random affective disorder on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
  - name: "T-Man Insanity (74-80): Random Phobia"
    description: "Roll 74-80 or choose. Roll for a random phobia on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
  - name: "T-Man Insanity (81-88): Random Obsession"
    description: "Roll 81-88 or choose. Roll for a random obsession on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
  - name: "T-Man Insanity (89-00): Random Insanity"
    description: "Roll 89-00 or choose. Roll for a random insanity on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
restrictions:
  - "No other forms of magic: tattoos only."
  - "Cybernetics: none. Bio-systems only if a replacement is needed; even one mechanical arm or leg reduces the effects, range, damage and duration of all tattoo magic by 25%."
  - "No two identical tattoos on the same body."
side_effects: "Insanity: two results from the T-Men Insanity Table, rolled or picked in the class''s T-Man Insanity group, and one more roll on that table for every five additional tattoos. Receiving tattoos: each simple weapon or animal tattoo does 2D6 S.D.C./H.P. damage with 1D4 days of penalties (-1 strike, parry and dodge, one melee action lost); each magic weapon or monster 4D6 with 1D4+1 days at half actions, speed and bonuses; each power 6D6 with a day of near incapacity and 1D4+3 more at half. Children 12 and under suffer half. Elves suffer double damage and double the days, lose one P.B. and age 10 years for each magic weapon or monster tattoo, lose one I.Q. and age 30 years for each power tattoo, and get half the effect, duration, range and damage from all tattoo magic."
extraction_notes: "Rifts World Book 2: Atlantis printed 93-94 (cache p093-p094; both pages rendered and match the OCR, including the item 2 P.P.E. paragraph whose number the OCR dropped). The O.C.C. starts in the right column of printed 93 and ends with the insanity table on printed 94; the T-Monster Men begin printed 95. Tattoo rules from printed 84-86. || XP: Tattooed Men ladder, printed 68, read off a render. || GROUP: the book files the T-Man under no group heading; stored as men-of-arms, a warrior slave whose magic comes from tattoos, following the Atlantean Monster Hunter. mdc_base is stated, so no men_of_arms line. || VARIANTS: the book prints a human and an ogre skill list, and different M.D.C. and P.P.E. for males and females, so four variants: human-male, human-female, ogre-male, ogre-female. Elves (12% of T-Men) have no list of their own; they are told to take the human one (judgement call). The parent holds the skills both lists share (two physical, two languages +15%). Hand to hand is per variant: human Expert, ogre Expert or Assassin; no upgrade price printed, so no hand_to_hand block. Children and teenagers (1D4x10 P.P.E.) are not stored. || POOLS: M.D.C. 10 (male) or 11 (female) per tattoo above six; 12 starting tattoos give 60 or 66 as mdc_base, plus the class bonus of +10 M.D.C. stored as a pool bonus. P.P.E. 5D6 +6 per tattoo +10 per level: 5d6+72+10 = 5d6+82 at first level, matching the book''s own worked range of 87-112 for a male; the female is 5d6+88 (93-118), though the book prints 95 to 130 for her, which no reading of its formula produces. The flat +10 per level and +6 per later tattoo do not roll on level-up, so they are prose on the P.P.E. ability. No hit points or S.D.C. stored; the race supplies them. || BONUSES: +2 save vs magic of all kinds (spell_magic and ritual_magic), +6 vs horror factor, +2 M.E., +2 P.E., +1 P.S., +6 Spd. || SKILLS: the class is the Typical Tattooed Man (printed 94). The general paragraph before it, for a captive who had another O.C.C. (old skills frozen, five new secondary skills from communications, domestic, physical, pilot, rogue, technical, W.P. and wilderness), is in the body, not modelled. Two languages as two Language: Other picks at +15. Ogre rogue skills excluding computer skills: except Computer Hacking. RELATED: six other skills and two additional W.P., stored as count 8 with a floor of two W.P.; two more at each of levels 4, 8 and 12. Electrical: Basic Electronics only; Mechanical: Automotive only (Automotive Mechanics); Medical: First Aid or Paramedic only +5% (Paramedic counts as two selections, prose in the body, not enforced); Military: none (omitted); Pilot except robot, power armor and spacecraft excludes Robots & Power Armor, Air Assault Armor, every Robot Combat row and Space: Small Spacecraft, Space Fighter and Starship; Science: Math only, both Mathematics rows; Technical except computer excludes Computer Operation, Computer Programming and Cyberjacking. SECONDARY: eight from the same list without its bonuses. || TATTOOS: catalog spells, tradition tattoo. All Simple Weapons, Animals and Monsters are one row each and granted outright; how many images each covers is in the Magic Tattoos ability. The two magic weapons and two powers are picks from named lists; the two of any category from a list of every row not already granted. Per level, one pick from the major list; the book''s alternative of two simple tattoos adds images to rows already held and is in the schedule note. The S.D.C. Shield is a simple weapon; it is offered in the any and major lists because the simple-weapon row is granted rather than picked (judgement call). GM option: a first or second level runaway may take up to six more tattoos, never to get another; not stored. || MONEY: none, slaves are provided for; starting_money omitted. EQUIPMENT: provided by the owner as needed; none stored. || RACE: race_restrictions none (a human, played with no R.C.C.), ogre and elf, the three the book''s divisions name. The catalog''s ogre and elf races are Palladium Fantasy rows that state their own P.P.E.; paired with one, the race''s P.P.E. wins and this class''s is dropped (class-check warns), which the book does not intend - its T-Man P.P.E. replaces the base by transformation. Not solved here. Printed 85 also lets True Atlanteans and Chiang-Ku receive tattoos, but not as this slave O.C.C.; not added. || INSANITY (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 94 says Roll twice on the following table, or pick two, and to roll on the T-Men Insanity Table once for every five additional tattoos. Read off a render of printed 94: twelve rows, 01-30, 31-40, 41-43, 44-50, 51-55, 56-60, 61-63, 64-65, 66-73, 74-80, 81-88, 89-00, covering 01-00 with no gap or overlap. Stored as one group, rolls 2, of twelve band-named options prefixed T-Man Insanity so they cannot collide with the T-Monster Man''s or the Maxi-Man''s. The roll per five additional tattoos is in the group''s note, not offered. The four rows that send the player to the main game''s tables (random affective disorder, phobia, obsession, insanity) stay as that row''s prose. No row prints a number, so none carries bonuses."
---

## Lore

Tattooed Men, or T-Men, are warrior slaves made by the Splugorth. The term covers every mystic warrior empowered by magic tattoos, male or female, human, ogre or elf. The typical T-Man was captured by Splugorth slavers, torn from family, forced through the agony of being tattooed, trained to use the tattoos, conditioned for a life of servitude and sold, usually to an inhuman master. Most see the tattoos as a curse that brands them slave, freak or monster, whatever power they bring.

Forced to hunt and kill, most T-Men carry deep psychological scars: about 70% have at least one insanity, and nearly all harbor anger, despair and a hunger for violence. A quarter of the captives chosen for the process take their own lives before it is finished. Only a quarter of T-Men are women, because buyers want an imposing warrior, although women tend to have more magical potential. Ogre T-Men are mostly bred in the Splugorth''s slave kennels, one of them in Atlantis; the rest are wild ogres captured on the Palladium world.

Typical divisions: 58% human males, 25% human females, 5% ogre males (mostly wild), 8% elf males, 4% elf females.

About 55% of T-Men were once farmers, villagers and vagabonds with little knowledge of science or technology. A captive who had another O.C.C. keeps those old skills frozen at the level they were when he was taken, and instead of the typical skill list learns five new secondary skills (from communications, domestic, physical, pilot, rogue, technical, W.P. and wilderness) that are the only ones to keep improving.

Equipment is supplied by the owner as needed: weapons, ammunition, field gear and vehicles. Long-serving loyal slaves may keep personal weapons and possessions. Renegades have only what they escaped with or can steal. Slaves receive no money, though a loyal, high-ranking slave may get an allowance.

A typical T-Man sells for 100,000 to 300,000 credits, twice that for a seasoned warrior of 8th level or higher.

## Skill Notes

Medical: First Aid or Paramedic only; Paramedic counts as two skill selections.

## T-Men Insanity Table

Two results are rolled or picked at creation in the T-Man Insanity group. One more roll for every five additional tattoos is made on the same table and noted on the sheet.

- 01-30 No insanity.
- 31-40 Obsession: fighting and competition; loves it.
- 41-43 Obsession: fighting; hates it and tries to avoid it.
- 44-50 Obsession: danger; loves it and takes needless risks.
- 51-55 Phobia: tattoos; must be restrained to receive another, even an ordinary one.
- 56-60 Phobia: Splugorth.
- 61-63 Phobia: alchemists.
- 64-65 Phobia: ancient dragons.
- 66-73 Random affective disorder.
- 74-80 Random phobia.
- 81-88 Random obsession.
- 89-00 Random insanity.

## Magic Tattoos

Twelve to start: two simple weapons, two magic weapons, two animals, two monsters, two powers, and two more of the player''s choice. From second level the master adds two simple tattoos (animal or simple weapon) or one major one (power, monster or magic weapon) per level; no more than two at a time, six months between pairs. A renegade can almost never get new ones, since very few beings know the secret. GM option: a first or second level runaway may be allowed up to six extra tattoos, on the understanding that he will likely never get another.

Every tattoo costs double P.P.E. for anyone who is not a full Tattooed Man. Destroying a tattoo animal does 3D6 damage direct to its creator''s hit points, a monster 5D6. A destroyed item or creature costs double to recreate, or the T-Man waits four hours (eight for monsters and magic armor).
',
       updated_at = datetime('now')
 WHERE class_id = 'tattooed-man'
   AND instr(markdown, 'Insanity: roll twice on the T-Men Insanity Table (or pick two)') > 0
   AND length(markdown) = 26722;

-- == t-monster-man ==
UPDATE imported_classes
   SET markdown = '---
id: t-monster-man
occ_group: men-of-arms
name: T-Monster Man
system: rifts
source_book: Rifts World Book 2: Atlantis p.95
category: occ
tags: [combat]
race_restrictions: { only: ["none"], note: "The book''s T-Monster Men are human (64%), ogre (26%) or elf (10%). Played with no R.C.C.: the catalog''s ogre and elf races are Palladium Fantasy rows whose own P.P.E. would replace the tattoo pools, so ogres take the ogre variants here and an elf takes a human variant with the elven tattoo penalties in the body." }
mdc_base: 80
ppe_base: "5d6+94, +10 per level of experience"
xp_table: [0, 2501, 5501, 10501, 21501, 31501, 46501, 64001, 85001, 110001, 160001, 210001, 285001, 360001, 440001]
variants:
  - id: "human-male"
    name: "T-Monster Man (human or elf, male)"
    # 14 starting tattoos, eight above six: 8 x 10 M.D.C.
    mdc_base: 80
    ppe_base: "5d6+94, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%; the book prints both lore skills." }
        - { name: "Lore: Faeries & Creatures of Magic", base: 35, per_level: 5, note: "+10%; the book prints both lore skills, read as Demons & Monsters and Faerie." }
        - { choose: 2, categories: ["Domestic"], bonus: 10, note: "Select two domestic skills (+10%)." }
        - { choose: 2, categories: ["Wilderness"], bonus: 5, note: "Select two wilderness skills (+5%)." }
        - { choose: 3, categories: ["Weapon Proficiencies"], note: "Select three W.P." }
        - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Learned as a slave. The book prints no change or upgrade price." }
  - id: "human-female"
    name: "T-Monster Woman (human or elf, female)"
    # 14 starting tattoos, eight above six: 8 x 11 M.D.C.; P.P.E. six higher.
    mdc_base: 88
    ppe_base: "5d6+100, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "+10%; the book prints both lore skills." }
        - { name: "Lore: Faeries & Creatures of Magic", base: 35, per_level: 5, note: "+10%; the book prints both lore skills, read as Demons & Monsters and Faerie." }
        - { choose: 2, categories: ["Domestic"], bonus: 10, note: "Select two domestic skills (+10%)." }
        - { choose: 2, categories: ["Wilderness"], bonus: 5, note: "Select two wilderness skills (+5%)." }
        - { choose: 3, categories: ["Weapon Proficiencies"], note: "Select three W.P." }
        - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Learned as a slave. The book prints no change or upgrade price." }
  - id: "ogre-male"
    name: "T-Monster Man (ogre, male)"
    # 8 x 10 M.D.C.
    mdc_base: 80
    ppe_base: "5d6+94, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints both lore skills." }
        - { name: "Lore: Faeries & Creatures of Magic", base: 40, per_level: 5, note: "+15%; the book prints both lore skills, read as Demons & Monsters and Faerie." }
        - { choose: 2, categories: [{ name: "Rogue", except: ["Computer Hacking"] }], bonus: 10, note: "Select two rogue skills (+10%; excluding computer skills)." }
        - { choose: 3, categories: ["Wilderness"], bonus: 5, note: "Select three wilderness skills (+5%)." }
        - { choose: 4, categories: ["Weapon Proficiencies"], note: "Select four W.P." }
        - { choose: 1, from: ["Hand to Hand: Expert", "Hand to Hand: Assassin"], base: 0, note: "Hand to Hand: Expert or Assassin." }
  - id: "ogre-female"
    name: "T-Monster Woman (ogre, female)"
    # 8 x 11 M.D.C.; P.P.E. six higher.
    mdc_base: 88
    ppe_base: "5d6+100, +10 per level of experience"
    skills_additional:
      occ_skills:
        - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints both lore skills." }
        - { name: "Lore: Faeries & Creatures of Magic", base: 40, per_level: 5, note: "+15%; the book prints both lore skills, read as Demons & Monsters and Faerie." }
        - { choose: 2, categories: [{ name: "Rogue", except: ["Computer Hacking"] }], bonus: 10, note: "Select two rogue skills (+10%; excluding computer skills)." }
        - { choose: 3, categories: ["Wilderness"], bonus: 5, note: "Select three wilderness skills (+5%)." }
        - { choose: 4, categories: ["Weapon Proficiencies"], note: "Select four W.P." }
        - { choose: 1, from: ["Hand to Hand: Expert", "Hand to Hand: Assassin"], base: 0, note: "Hand to Hand: Expert or Assassin." }
bonuses:
  attributes: { ME: 2, PS: 1, PE: 2, Spd: 6 }
  saves: { spell_magic: 2, ritual_magic: 2, horror_factor: 6 }
  pools: { mdc: 10 }
skills:
  occ_skills:
    - { choose: 2, categories: ["Physical"], note: "Select two physical skills." }
    - { choose: 2, from: ["Language: Other"], bonus: 15, note: "Select two languages (+15%)." }
  occ_related_skills:
    count: 8
    minimums:
      - { count: 2, category: "Weapon Proficiencies" }
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"], bonus: 5 }
      - "Physical"
      - { name: "Pilot", bonus: 5, except: ["Robots & Power Armor", "Air Assault Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 5 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Cyberjacking"] }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 2 }
      - { level: 8, count: 2 }
      - { level: 12, count: 2 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - "Physical"
      - { name: "Pilot", except: ["Robots & Power Armor", "Air Assault Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming", "Cyberjacking"] }
      - "Weapon Proficiencies"
      - "Wilderness"
magic:
  type: "spell"
  spell_traditions_allowed: ["tattoo"]
  spells: ["Tattoo: All Simple Weapons", "Tattoo: Animals", "Tattoo: Monsters"]
  spells_starting: 6
  spells_starting_groups:
    - { count: 2, from_list: "magic_weapons", note: "Two magic weapon tattoos." }
    - { count: 1, from_list: "undead", note: "Power: Animate & Control Dead (Skull with Bat Wings) or Protection from Vampires (Heart Pierced by a Wooden Stake)." }
    - { count: 1, from_list: "armor", note: "Power: Invulnerability (Heart Encircled by Chains) or Magic Armor (Knight in Full Body Armor)." }
    - { count: 2, from_list: "any", note: "Two more tattoos from any of the categories. An extra simple weapon, animal or monster is one more image under the row already held: note it on the sheet and take nothing here for it." }
  spell_lists:
    magic_weapons: ["Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield"]
    powers: ["Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    any: ["Tattoo: S.D.C. Shield", "Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    major: ["Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)", "Tattoo: S.D.C. Shield"]
    undead: ["Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Heart Pierced by a Wooden Stake (protection)"]
    armor: ["Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Knight in Full Body Armor"]
  spells_schedule:
    - { level: 2, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 3, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 4, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 5, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 6, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 7, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 8, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 9, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 10, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 11, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 12, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 13, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 14, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
    - { level: 15, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or two simple ones (animal or simple weapon) instead. A new monster, animal or simple weapon is another image under the row already held: note it on the sheet. Given by the master; a renegade can almost never get new tattoos." }
special_abilities:
  - name: "Magic Tattoos"
    description: "Starts with 14 tattoos: one simple weapon, two magic weapons, three animals (usually predators or big ones), four monsters, Animate & Control Dead or Protection from Vampires, Invulnerability or Magic Armor, and two more from any category. The simple weapon is one image under the All Simple Weapons row, the three animals three images under the Animals row, and the four monsters four images under the Monsters row. Each level from second the master adds two simple tattoos (animal or simple weapon) or one major tattoo (power, monster or magic weapon). No more than two tattoos at a time, at least six months between pairs, and no tattoo may be duplicated on one body. Activating a tattoo counts as one melee action; from seventh level a T-Man activates by concentration alone, without touching the image. No more than six tattoos may be active at once."
  - name: "Monster Tattoos at Half Cost"
    description: "Activates and creates every monster tattoo at half the usual P.P.E. cost: 25 for a minor monster, 40 for a major one, 50 for a super monster."
  - name: "M.D.C. Transformation"
    description: "Same as the Tattooed Man: each tattoo above six gives a male 10 M.D.C. and a female 11, making the character a mega-damage creature. The variants store this for the 14 starting tattoos (80 or 88); add 10 or 11 for every tattoo gained later. The class bonus of +10 M.D.C. is added on top."
  - name: "Increased P.P.E."
    description: "Same as the Tattooed Man: base 5D6 for an adult male, plus six for an adult female, plus 10 per level of experience and six per tattoo. The 14 starting tattoos and the first level are the +94 in ppe_base; add 10 more each level and six for every tattoo gained later. Can also draw energy from ley lines and nexus points, but cannot draw P.P.E. from other living beings or from a death."
  - name: "Increased P.P.E. Recovery"
    description: "Recovers 10 P.P.E. per hour of rest or sleep, twice the normal rate."
  - name: "Tattoos Only"
    description: "Cannot cast spells, make circles or perform rituals, and cannot learn to. A practitioner of magic who receives seven or more tattoos loses all other mystic powers for good."
  - { rolls: 3, from: ["T-Monster Insanity (01-30): No Insanity", "T-Monster Insanity (31-40): Obsession, Fighting and Competition", "T-Monster Insanity (41-42): Obsession, Hates Fighting", "T-Monster Insanity (43-46): Obsession, Monsters", "T-Monster Insanity (47-51): Obsession, Danger", "T-Monster Insanity (52-55): Phobia, Tattoos", "T-Monster Insanity (56-60): Phobia, Splugorth", "T-Monster Insanity (61-62): Phobia, Alchemists", "T-Monster Insanity (63-65): Phobia, Elder and Ancient Dragons", "T-Monster Insanity (66-71): Random Affective Disorder", "T-Monster Insanity (72-79): Random Phobia", "T-Monster Insanity (80-88): Random Obsession", "T-Monster Insanity (89-00): Random Insanity"], note: "T-Monster Men Insanity Table (printed 95): roll three times, or pick three. Roll once more on this table for every five additional tattoos and note that result on the sheet." }
  - name: "T-Monster Insanity (01-30): No Insanity"
    description: "Roll 01-30 or choose. No insanity from this roll."
  - name: "T-Monster Insanity (31-40): Obsession, Fighting and Competition"
    description: "Roll 31-40 or choose. Obsessed with fighting and competition, and loves both."
  - name: "T-Monster Insanity (41-42): Obsession, Hates Fighting"
    description: "Roll 41-42 or choose. Obsessed with fighting, but hates it and tries to avoid it."
  - name: "T-Monster Insanity (43-46): Obsession, Monsters"
    description: "Roll 43-46 or choose. Obsessed with monsters: loves them and has no fear of them. +2 to save vs horror factor (applied), and +1 to all saves against attacks by monsters, including parry, dodge, poison, magic and psionics (only against monsters, so not applied)."
    bonuses: { saves: { horror_factor: 2 } }
  - name: "T-Monster Insanity (47-51): Obsession, Danger"
    description: "Roll 47-51 or choose. Obsessed with danger: loves it and takes needless risks."
  - name: "T-Monster Insanity (52-55): Phobia, Tattoos"
    description: "Roll 52-55 or choose. Phobia of tattoos: cannot stand to get another and must be restrained to receive a new one, even an ordinary tattoo."
  - name: "T-Monster Insanity (56-60): Phobia, Splugorth"
    description: "Roll 56-60 or choose. Phobia of the Splugorth."
  - name: "T-Monster Insanity (61-62): Phobia, Alchemists"
    description: "Roll 61-62 or choose. Phobia of alchemists."
  - name: "T-Monster Insanity (63-65): Phobia, Elder and Ancient Dragons"
    description: "Roll 63-65 or choose. Phobia of elder and ancient dragons."
  - name: "T-Monster Insanity (66-71): Random Affective Disorder"
    description: "Roll 66-71 or choose. Roll for a random affective disorder on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
  - name: "T-Monster Insanity (72-79): Random Phobia"
    description: "Roll 72-79 or choose. Roll for a random phobia on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
  - name: "T-Monster Insanity (80-88): Random Obsession"
    description: "Roll 80-88 or choose. Roll for a random obsession on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
  - name: "T-Monster Insanity (89-00): Random Insanity"
    description: "Roll 89-00 or choose. Roll for a random insanity on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
restrictions:
  - "No other forms of magic: tattoos only."
  - "Cybernetics: none, same as the Tattooed Man. Even one mechanical arm or leg reduces the effects, range, damage and duration of all tattoo magic by 25%."
  - "No two identical tattoos on the same body."
side_effects: "Insanity: three results from the T-Monster Men Insanity Table, rolled or picked in the class''s T-Monster Insanity group, and one more roll on that table for every five additional tattoos. Receiving tattoos hurts as for the Tattooed Man: 2D6 S.D.C./H.P. per simple weapon or animal, 4D6 per magic weapon or monster, 6D6 per power, with days of penalties; half for children, double for elves. Elves also lose P.B. and age 10 years per magic weapon or monster tattoo, lose I.Q. and age 30 years per power tattoo, and get half the effect of all tattoo magic."
extraction_notes: "Rifts World Book 2: Atlantis printed 95 (cache p095; rendered, matches the OCR). The entry fills printed 95 and ends with its insanity table; the Maxi-Man begins at the foot of the same page and is not part of it. It is a subclass of the Tattooed Man (printed 93-94): magic powers, bonuses, related skills, equipment, money and cybernetics are same as the T-Man, so those are copied from tattooed-man. || XP: T-Monster Men ladder, printed 68, read off a render. || GROUP: men-of-arms, as the Tattooed Man. mdc_base stated, so no men_of_arms line. || VARIANTS: human and ogre skill lists, male and female pools: four variants as on tattooed-man. Elves take the human list (judgement call). No upgrade price for hand to hand, so no hand_to_hand block. || POOLS: 14 starting tattoos, eight above six: M.D.C. 80 (male) or 88 (female), plus the inherited +10 M.D.C. as a pool bonus. P.P.E. 5D6 + 14 x 6 + 10 = 5d6+94 (male), 5d6+100 (female). The flat +10 per level and +6 per later tattoo are prose. || BONUSES: the T-Man''s, inherited: +2 save vs magic (spell_magic and ritual_magic), +6 vs horror factor, +2 M.E., +2 P.E., +1 P.S., +6 Spd. || SKILLS: Both lore skills, +10% (human) or +15% (ogre): read as Lore: Demons & Monsters and Lore: Faeries & Creatures of Magic, the two lore skills the book itself prints elsewhere (Demons & Monsters and Faerie, printed 17 and 70); judgement call. Human: two domestic +10, two wilderness +5, three W.P., Hand to Hand: Expert. Ogre: two rogue +10 excluding computer skills (except Computer Hacking), three wilderness +5, four W.P., Hand to Hand: Expert or Assassin. Shared in the parent: two physical, two languages +15. RELATED: same as the T-Man, six other skills and two additional W.P. (count 8 with a floor of two W.P.), two more at levels 4, 8 and 12, same category list and exclusions. SECONDARY: six, not the T-Man''s eight, as printed. || TATTOOS: catalog spells, tradition tattoo. All Simple Weapons, Animals and Monsters granted outright, counts in the Magic Tattoos ability. Animate & Control Dead is Skull with Bat Wings and Protection from Vampires is Heart Pierced by a Wooden Stake (index on printed 91); Invulnerability is Heart Encircled by Chains and Magic Armor is Knight in Full Body Armor (index: Armor, figure of a knight). The two any-category picks and the level schedule are as on tattooed-man. Half P.P.E. for monster tattoos is prose; the Monsters row''s own cost is unchanged. GM option: a first or second level runaway may take up to four more tattoos; not stored. || MONEY and EQUIPMENT: same as the T-Man, none stored. || RACE: none (human), ogre, elf; the same Palladium Fantasy race P.P.E. caveat as tattooed-man applies (class-check warns). || INSANITY (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 95 says Roll three times on the insanity table that follows, or pick three, and to roll again on the TM-Men Insanity Table once for every five additional tattoos. Read off a render of printed 95: thirteen rows, 01-30, 31-40, 41-42, 43-46, 47-51, 52-55, 56-60, 61-62, 63-65, 66-71, 72-79, 80-88, 89-00, covering 01-00 with no gap or overlap. Stored as one group, rolls 3, of thirteen band-named options prefixed T-Monster Insanity so they cannot collide with the Tattooed Man''s or the Maxi-Man''s. The roll per five additional tattoos is in the group''s note, not offered. Row 43-46 (obsession: monsters) prints +2 to save vs horror factor, stored as that option''s bonus (BOOK-INGEST-AUDIT.md F119); its +1 to all saves from attacks by monsters, including parry and dodge, applies only against monsters and stays prose. The four rows that send the player to the main game''s tables stay as that row''s prose."
---

## Lore

T-Monster Men (TM-Men) are Tattooed Men who concentrate on monster and animal tattoos. Their tattoos lean toward the monstrous: creating and fighting monsters, animating and commanding the dead, warding off vampires. In every other respect their training, skills and abilities match the ordinary Tattooed Man, and like all T-Men they are Splugorth warrior slaves. Ogres are especially fond of monster tattoos.

Typical divisions: 54% human males, 10% human females, 26% ogre males, 8% elf males, 2% elf females.

Equipment, money and cybernetics are as for the Tattooed Man: gear is supplied by the owner, slaves are paid nothing, and mechanical bionics weaken tattoo magic.

## Skill Notes

Medical: First Aid or Paramedic only; Paramedic counts as two skill selections.

## T-Monster Men Insanity Table

TM-Men are even crazier than ordinary T-Men. Three results are rolled or picked at creation in the T-Monster Insanity group. One more roll for every five additional tattoos is made on the same table and noted on the sheet.

- 01-30 No insanity.
- 31-40 Obsession: fighting and competition; loves it.
- 41-42 Obsession: fighting; hates it and tries to avoid it.
- 43-46 Obsession: monsters; loves them and has no fear of them: +2 to save vs horror factor and +1 to all saves against attacks by monsters, including parry, dodge, poison, magic and psionics.
- 47-51 Obsession: danger; loves it and takes needless risks.
- 52-55 Phobia: tattoos; must be restrained to receive another, even an ordinary one.
- 56-60 Phobia: Splugorth.
- 61-62 Phobia: alchemists.
- 63-65 Phobia: elder and ancient dragons.
- 66-71 Random affective disorder.
- 72-79 Random phobia.
- 80-88 Random obsession.
- 89-00 Random insanity.

## Magic Tattoos

Fourteen to start: one simple weapon, two magic weapons, three animals, four monsters, Animate & Control Dead or Protection from Vampires, Invulnerability or Magic Armor, and two more of any category. Every monster tattoo costs the TM-Man half the usual P.P.E. From second level the master adds two simple tattoos or one major one per level, no more than two at a time and six months apart; a runaway can almost never get new ones. GM option: a first or second level runaway may be allowed up to four extra tattoos, likely never to get another.
',
       updated_at = datetime('now')
 WHERE class_id = 't-monster-man'
   AND instr(markdown, 'Insanity: roll three times on the T-Monster Men Insanity Table (or pick three)') > 0
   AND length(markdown) = 25237;

-- == maxi-man ==
UPDATE imported_classes
   SET markdown = '---
id: maxi-man
occ_group: men-of-arms
name: Maxi-Man
system: rifts
source_book: Rifts World Book 2: Atlantis p.95-97
category: occ
tags: [combat]
race_restrictions: { only: ["none"], note: "Human, ogre or elf: the book gives 62% human males, 15% human females, 15% ogre males and 3% ogre females (mostly domestic stock), 3% elf males and 2% elf females. Played with no R.C.C.: the catalog''s human, ogre and elf races are Palladium Fantasy rows whose own P.P.E. would replace the tattoo pools." }
mdc_base: "1d4x10+120"
ppe_base: "5d6+138, +10 per level"
variants:
  - id: "adult-male"
    name: "Adult Male Maxi-Man"
    # +1D4x10 M.D.C. bonus, plus 10 M.D.C. for each of the 12 starting tattoos beyond six.
    mdc_base: "1d4x10+120"
    # 5D6+10, plus six for each of the 18 starting tattoos (108).
    ppe_base: "5d6+138, +10 per level"
  - id: "adult-female"
    name: "Adult Female Maxi-Man"
    # +1D4x10 M.D.C. bonus, plus 11 M.D.C. for each of the 12 starting tattoos beyond six.
    mdc_base: "1d4x10+132"
    # 5D6+10 plus six for an adult female, plus 108 for the tattoos.
    ppe_base: "5d6+144, +10 per level"
  - id: "teen-male"
    name: "Teenage Male Maxi-Man"
    mdc_base: "1d4x10+120"
    # 1D4x10+10 for a male child or teenager, plus 108 for the tattoos.
    ppe_base: "1d4x10+138, +10 per level"
  - id: "teen-female"
    name: "Teenage Female Maxi-Man"
    mdc_base: "1d4x10+132"
    # 1D4x10+15 for a female child or teenager, plus 108 for the tattoos.
    ppe_base: "1d4x10+143, +10 per level"
starting_money: 0
bonuses:
  attributes: { ME: 2, PS: "1d6", PP: "1d4", PE: 3, Spd: "2d6+6" }
  saves: { spell_magic: 3, ritual_magic: 3, horror_factor: 6 }
skills:
  hand_to_hand: { costs: { martial_arts: 0 } }
  occ_skills:
    - { name: "First Aid", base: 50, per_level: 5, note: "+5%" }
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Speaks Dragonese/Elf at 98%." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "The book prints this as speaks American at 98%." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "+10%; the book prints Tracking." }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Body Building & Weight Lifting", base: 0, per_level: 0, note: "The book prints Body Building." }
    - { name: "Boxing", base: 0, per_level: 0 }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 55, per_level: 5, note: "+5%" }
    - { name: "W.P. Archery", base: 0, per_level: 0, note: "The book prints W.P. Archery & Targeting." }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "Hand to Hand: Assassin", base: 0, per_level: 0, note: "Can be changed to Hand to Hand: Martial Arts at no additional cost." }
  occ_related_skills:
    count: 5
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 10 }
      - { name: "Mechanical", bonus: 5, only: ["Automotive Mechanics"] }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", bonus: 5, except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - { name: "Science", bonus: 10, only: ["Mathematics: Basic", "Mathematics: Advanced"] }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"] }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    schedule:
      - { level: 4, count: 1 }
      - { level: 8, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
magic:
  type: "spell"
  spell_traditions_allowed: ["tattoo"]
  spells: ["Tattoo: All Simple Weapons", "Tattoo: Animals", "Tattoo: Monsters"]
  spells_starting: 12
  spells_starting_groups:
    - { count: 2, from_list: "magic_weapons", note: "Two magic weapon tattoos." }
    - { count: 4, from_list: "powers", note: "Four power tattoos." }
    - { count: 6, from_list: "any", note: "Six tattoos of choice from any category. A choice of a further simple weapon, animal or monster is recorded under the single row the class already holds; count it in the Magic Tattoos ability." }
  spell_lists:
    magic_weapons: ["Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield"]
    powers: ["Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    major: ["Tattoo: Monsters", "Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
    any: ["Tattoo: All Simple Weapons", "Tattoo: S.D.C. Shield", "Tattoo: Animals", "Tattoo: Monsters", "Tattoo: Two Weapons Crossed", "Tattoo: Weapon Dripping Blood", "Tattoo: Weapon Covered in Flames", "Tattoo: Weapon Covered in Flames and a Coiled Snake/Serpent", "Tattoo: Weapon with Wings", "Tattoo: Flaming Shield", "Tattoo: Chain Encircling a Skull or Brain (psionic save)", "Tattoo: Chain with a Broken Link (strength)", "Tattoo: Chain Wrapped Around a Cloud (air powers)", "Tattoo: Cross (turn dead)", "Tattoo: Eye with a Dagger In It (blind)", "Tattoo: Eye of Knowledge (language)", "Tattoo: Eye of Mystic Knowledge (magic)", "Tattoo: Eye With Tears (empathy & transmission)", "Tattoo: Eyes: Three (supernatural vision)", "Tattoo: Heart Pierced by a Wooden Stake (protection)", "Tattoo: Heart Encircled by Chains (invulnerability)", "Tattoo: Heart with Large Wings (fly)", "Tattoo: Heart with Tiny Wings (run)", "Tattoo: Knight in Full Body Armor", "Tattoo: Lightning Bolts (shoot lightning)", "Tattoo: Phoenix Rising From the Flames (resurrection)", "Tattoo: Rose and Thorny Stem & Dripping Blood (heal)", "Tattoo: Shark or Dolphin (swim)", "Tattoo: Skull with Bat Wings (animate dead)", "Tattoo: Skull Coiled with Thorns (death touch)", "Tattoo: Skull Engulfed in Flames (fire powers)", "Tattoo: Thorns or Ball of Thorns (protection: poison)"]
  spells_schedule:
    - { level: 3, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 4, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 5, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 6, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 7, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 8, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 9, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 10, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 11, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 12, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 13, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 14, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
    - { level: 15, count: 1, from_list: "major", note: "One major tattoo (power, monster or magic weapon), or instead two simple tattoos (animal or simple weapon), recorded in the Magic Tattoos ability. Added by the master; a runaway slave gets none." }
special_abilities:
  - name: "Magic Tattoos"
    description: "A typical second level Maxi-Man starts with 18 tattoos: two simple weapons, two magic weapons, two animals, two monsters, four powers, and six of choice from any category. Simple weapons, animals and monsters are one row each (All Simple Weapons, Animals, Monsters), so the specific weapons, beasts and monsters depicted, and any extra simple, animal or monster tattoos taken among the six of choice, are recorded here. From level three the master adds two simple tattoos (animal or simple weapon) or one major tattoo (power, monster or magic weapon) each level. No T-Man may receive more than two tattoos at one time, with at least six months between pairs. Runaway slaves almost never get new tattoos. GM option: a second level runaway may select up to five more tattoos from any category at creation, on the understanding that no more will ever come."
  - name: "M.D.C. Transformation"
    description: "Each tattoo above six gives a male 10 and a female 11 physical M.D.C., making the Maxi-Man a mega-damage creature; one to six tattoos do not change an ordinary human. The class also grants +1D4x10 M.D.C. The variants apply both for the 18 starting tattoos (12 beyond six); add 10 or 11 M.D.C. for each tattoo gained later."
  - name: "P.P.E. from Magic Tattoos"
    description: "Base P.P.E. is 5D6+10 for an adult male and six more for an adult female; 1D4x10+10 for a male child or teenager and 1D4x10+15 for a female one. Add 10 per level of experience and six for each tattoo. The stored figures are the transformation base, the 18 starting tattoos (+108) and two levels of experience (+20, because a Maxi-Man starts at second level), so an adult male is 5D6+138; add six for every tattoo gained later. A typical second level adult male starts with about 143 to 168 P.P.E. Can also draw energy from ley lines and nexus points."
  - name: "Increased P.P.E. Recovery"
    description: "Recovers 12 P.P.E. per hour of rest or sleep, a bit more than twice the normal human rate."
  - { choose: 1, from: ["Maxi-Man Insanity (01-60): No Insanity", "Maxi-Man Insanity (61-75): Obsession, Fighting and Competition", "Maxi-Man Insanity (76-78): Obsession, Hates Fighting", "Maxi-Man Insanity (79-84): Obsession, Danger", "Maxi-Man Insanity (85-86): Phobia, Tattoos", "Maxi-Man Insanity (87-90): Phobia, Splugorth", "Maxi-Man Insanity (91-00): Random Insanity"], note: "Maxi-men Insanity Table (printed 97): roll once, or pick one. Roll once more on this table for every six additional tattoos and note that result on the sheet." }
  - name: "Maxi-Man Insanity (01-60): No Insanity"
    description: "Roll 01-60 or choose. No insanity from this roll."
  - name: "Maxi-Man Insanity (61-75): Obsession, Fighting and Competition"
    description: "Roll 61-75 or choose. Obsessed with fighting and competition, and loves both."
  - name: "Maxi-Man Insanity (76-78): Obsession, Hates Fighting"
    description: "Roll 76-78 or choose. Obsessed with fighting, but hates it and tries to avoid it."
  - name: "Maxi-Man Insanity (79-84): Obsession, Danger"
    description: "Roll 79-84 or choose. Obsessed with danger: loves it and takes needless risks."
  - name: "Maxi-Man Insanity (85-86): Phobia, Tattoos"
    description: "Roll 85-86 or choose. Phobia of tattoos: cannot stand to get another and must be restrained to receive a new one, even an ordinary tattoo."
  - name: "Maxi-Man Insanity (87-90): Phobia, Splugorth"
    description: "Roll 87-90 or choose. Phobia of the Splugorth."
  - name: "Maxi-Man Insanity (91-00): Random Insanity"
    description: "Roll 91-00 or choose. Roll for a random insanity on the main game''s insanity tables; the result is not stored here, so note it on the sheet."
restrictions:
  - "Starts at second level of experience, aged 16 or 17. The 18 starting tattoos are the second level allotment."
  - "Cybernetics: none. Bio-systems only if ever needed; even one mechanical arm or leg reduces the effects, range, damage and duration of the character''s magic by 25%."
  - "No more than two new tattoos at one time, and at least six months between pairs."
side_effects: "Insanity: one result from the Maxi-men Insanity Table, rolled or picked in the class''s Maxi-Man Insanity group, and one more roll on that table for every six additional tattoos. 01-60 no insanity; 61-75 obsessed with fighting and competition, loves it; 76-78 obsession: fighting, hates it and tries to avoid it; 79-84 obsession: danger, loves it and takes needless risks; 85-86 phobia: tattoos, must be restrained to receive another; 87-90 phobia: Splugorth; 91-00 roll for random insanity."
extraction_notes: "WB2 printed 95-97 (cache p095-p097, page_offset 0): the entry starts on printed 95 after the T-Monster Man and ends on 97 before the Undead Slayer. Printed 96 rendered and checked. || XP: the entry names no experience table, and printed 68 prints none for the Maxi-Man; its only mention there is Also see the Maxi-men and Tattooed Men in the section on Tattoo Magic. The entry calls the class The Elite Tattooed Man, so the Tattooed Men ladder is the likely one, but the book does not say so; xp_table is omitted rather than guessed. A Rifts O.C.C. needs none. || GROUP: the book files no group heading. Stored as men-of-arms: a warrior slave whose magic comes from tattoos. mdc_base is stated, so no men_of_arms line. || POOLS: the book gives separate P.P.E. formulas for adult males, adult females (six more), male children or teens (1D4x10+10) and female children or teens (1D4x10+15), and M.D.C. per tattoo beyond six of 10 (male) or 11 (female). Four variants carry them; the top-level pools are the adult male ones. All 18 starting tattoos are counted (12 beyond six, 108 P.P.E.); the book''s example, 143 to 168 P.P.E. for a second level adult male, is 5D6+10 plus 108 plus 10 per level for two levels, which confirms the reading. The book says Maxi-Men start at 16 or 17 yet its example uses the adult formula; both are offered. The +1D4x10 M.D.C. bonus is folded into mdc_base rather than a dice pool bonus. No hit points or S.D.C. stored, following atlantean-monster-hunter. || BONUSES: +3 save vs magic of all kinds (spell_magic and ritual_magic, following atlantean-monster-hunter), +6 save vs horror factor, +2 M.E., +1D6 P.S., +1D4 P.P., +3 P.E., +2D6+6 Spd, unconditional. || TATTOOS are catalog spells, tradition tattoo. All Simple Weapons, Animals and Monsters are granted once each, and how many of each the class starts with is in the Magic Tattoos ability; magic weapons (2), powers (4) and six of choice are starting groups on named lists. The level-up grant is modelled as one major tattoo per level from 3 to 15 (the 18 are the level 2 allotment); the alternative of two simple tattoos adds no row, since the class already holds All Simple Weapons and Animals, and is prose. || SKILLS: Tracking is the catalog Tracking (people) 25+10; Body Building is Body Building & Weight Lifting; W.P. Archery & Targeting is W.P. Archery; speaks Dragonese/Elf and American at 98% is Language: Dragonese and Language: Native Tongue at 98 (no literacy is printed). First Aid 45+5, Radio: Basic 45+5, Intelligence 32+10, Wilderness Survival 30+10, Climbing 40+10, Swimming 50+5. Hand to Hand: Assassin, changeable to Martial Arts at no cost: hand_to_hand prices martial_arts at 0. || RELATED: five, plus three additional skills at levels four, eight and twelve, read as one at each of those levels (three in all), following atlantean-monster-hunter''s reading of the same sentence; three at each is the alternative. Electrical basic electronics only, Mechanical automotive only (+5%), Science math only (+10%), Medical none other than First Aid (omitted), Pilot any except robot and power armor (+5%) excludes Robots & Power Armor and every Robot Combat row, Technical any except computer. Rogue +2% is as printed. || MONEY: the book prints Money: None (slaves are provided for; loyal ones may get an allowance); stored as 0, as maxi-killer does. || EQUIPMENT: issued by the owner on the basis of need; a runaway has only what he escaped with. Nothing stored. || INSANITY (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 97 says Roll once on the following insanity table, or pick one, and to roll on the Maxi-men Insanity Table once for every six additional tattoos. Read off a render of printed 97: seven rows, 01-60, 61-75, 76-78, 79-84, 85-86, 87-90, 91-00, covering 01-00 with no gap or overlap. Stored as one pick-one group of seven band-named options prefixed Maxi-Man Insanity so they cannot collide with the Tattooed Man''s or the T-Monster Man''s. The roll per six additional tattoos is in the group''s note, not offered. Row 91-00 (roll for random insanity) sends the player to the main game''s tables and stays as that row''s prose. No row prints a number, so none carries bonuses."
---

## Lore

The Maxi-Men are the elite of the Tattooed Men: the most savage and powerful of the human and ogre warrior slaves, and masters of tattoo magic. Most were captured as children, seldom older than nine, and raised to accept their lot as warrior slaves. Unlike other slaves they are trained with patience and rewarded with privilege and freedom for loyalty and courage, and they can rise to high rank among the Minions of Splugorth: officers up to general, spies, advisors to governors and kings, even governors of distant provinces. Most are content with their slavery, and many show an unsettling devotion to their inhuman masters.

Years of indoctrination teach them to be aggressive, merciless and proud, to thrive on combat and competition, and to be loyal, protective, obedient and honorable toward their owners. By 16 or 17 a Maxi-Man is already second level and ready for the field or the slave market. It takes a great deal, usually cruelty, to turn one against his master. Deserters are hunted down; a first or minor offender is re-indoctrinated, while repeat or serious offenders face the arena, the Preserve, experimentation or hard labor, and the most dangerous are killed on sight.

Maxi-Men prefer their tattoos to modern weapons and gear. Most wear little or no armor and often go into combat apparently unarmed, and a favorite ploy is to pose as a helpless victim.

## Magic Tattoos

A typical second level Maxi-Man carries 18 tattoos: two simple weapons, two magic weapons, two animals, two monsters, four powers and six of choice. From third level the master adds two simple tattoos or one major tattoo each level, never more than two at once and at least six months apart. A runaway will almost never find anyone able to add more.

## Equipment and Money

Equipment, weapons, vehicles and money are issued by the owner as needed, and their quality depends on the owner''s wealth. Long-serving loyal slaves may keep personal weapons and gear. A runaway has only what he escaped with. Slaves receive no money, though loyal and high-ranking ones may be given an allowance.
',
       updated_at = datetime('now')
 WHERE class_id = 'maxi-man'
   AND instr(markdown, 'Insanity: roll once on the Maxi-men Insanity Table (or pick one)') > 0
   AND length(markdown) = 20806;

-- == splugorth-conservator ==
UPDATE imported_classes
   SET markdown = '---
id: splugorth-conservator
name: Splugorth Conservator
system: rifts
source_book: Rifts World Book 2: Atlantis p.45-47
category: rcc
tags: [supernatural, augmented, hunter]
attribute_dice:
  IQ: "3d6+2"
  ME: "18"
  MA: "3d6"
  PS: "50"
  PP: "21"
  PE: "21"
  PB: "1d6"
  Spd: "44"
mdc_base: "1d4x100+350"
ppe_base: "1d4x100+20"
horror_factor: 16
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
bonuses:
  combat: { attacks_base: 8, strike: 9, parry: 9, dodge: 6, roll: 4, pull_punch: 4 }
  saves: { psionics: 2, spell_magic: 2, ritual_magic: 2, horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%; the book prints Basic Math." }
    - { name: "Radio: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Radio: Scramblers", base: 45, per_level: 5, note: "+10%" }
    - { name: "Boat: Motor, Race & Hydrofoil", base: 65, per_level: 5, note: "+10%; the book prints pilot all boats." }
    - { name: "Boat: Sail Type", base: 70, per_level: 5, note: "+10%; the book prints pilot all boats." }
    - { name: "Boat: Ships", base: 55, per_level: 5, note: "+10%; the book prints pilot all boats." }
    - { name: "Boat: Paddle Types/Canoe/Kayak", base: 60, per_level: 5, note: "+10%; the book prints pilot all boats." }
    - { name: "Boat: Submersibles", base: 50, per_level: 4, note: "+10%; the book prints pilot all boats." }
    - { name: "Hover Craft (ground)", base: 60, per_level: 5, note: "+10%; the book prints pilot hover vehicles." }
    - { name: "Climbing", base: 60, per_level: 5, note: "+20%" }
    - { name: "Swimming", base: 60, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 50, per_level: 5, note: "+20%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { choose: 6, categories: ["Weapon Proficiencies"], note: "Select six W.P.s." }
    - { choose: 4, categories: ["Wilderness"], note: "Select four wilderness skills." }
psionics:
  type: "major"
  isp_base: "2d4x10"
  powers: ["Astral Projection", "Empathy", "Mind Block", "Object Read (Psychometry)", "Sense Magic", "Speed Reading", "Telepathy", "Total Recall"]
magic:
  type: "spell"
  spells_starting: 8
  spell_levels_allowed: [1, 2, 3]
equipment_starting:
  - { choose: 1, label: "lesser or greater rune weapon", qty: 1, from: ["lesser-rune-weapon", "greater-rune-weapon"] }
  - { item_id: "aerobes", qty: 2 }
  - { item_id: "aquarobes", qty: 2 }
  - { item_id: "dehibicila", qty: 2 }
  - { item_id: "purirobes", qty: 2 }
  - { item_id: "stasirobes", qty: 2 }
  - { item_id: "mystic-leech", qty: "1d4" }
  - { item_id: "zombitron", qty: "1d4+1" }
special_abilities:
  - name: "Four Arms"
    description: "Bio-wizard augmentation: an extra pair of over-sized, elongated humanoid arms. Its extra melee attack is already in the eight attacks."
  - name: "Stinger Tail"
    description: "Bio-wizard augmentation: a prehensile tail whose strikes inflict 2D6 M.D. The stinger paralyzes for 1D4 minutes per sting; the victim saves on a 14 or higher. Its extra melee attack is already in the eight attacks."
  - name: "Scent Spray"
    description: "Bio-wizard augmentation: a chemical sprayed from the mouth marks a target with scent; range 20 ft (6 m), covers a 10 ft (3 m) area, and lasts 2D4 days even after washing or rain."
  - name: "Natural Body Armor"
    description: "Bio-wizard medium plate: 350 M.D.C., included in mdc_base. May also use magic to create additional armor or force fields, but never wears artificial body armor."
  - name: "Claws and Spikes"
    description: "Finger claws 2D4 M.D.; knuckle spikes add 1D6 M.D. to a punch; elbow spike 1D6 M.D."
  - name: "Sensors"
    description: "A molecular analyzer in the mouth and motion detection."
  - name: "Third Eye (Eye of Eylor)"
    description: "A third eye, the eye of Eylor, which is the source of +20 P.P.E. (in ppe_base)."
  - name: "Body Block/Tackle"
    description: "+3 to strike with a body block or tackle, which does 1D4 M.D."
  - name: "Supernatural Strength"
    description: "P.S. 50: 1D6x10 S.D.C. on a restrained punch, 6D6 M.D. on a full strength punch or kick, 2D6x10 M.D. on a power punch. Critical strike on a natural 19 or 20."
  - name: "Spell Casting"
    description: "Eight spells from levels 1-3, most of them related to hunting. Spell strength is frozen at 4th level. In combat: eight physical attacks per melee, or two by spell magic and three physical; prefers physical."
  - { rolls: 2, from: ["Insanity (01-10): Compulsive Liar", "Insanity (11-20): Kleptomaniac", "Insanity (21-30): Obsession, Hates Songbirds", "Insanity (31-40): Obsession, Loves Fighting and Competition", "Insanity (41-42): Obsession, Hates Fighting", "Insanity (43-50): Obsession, Loves Danger", "Insanity (51-60): Obsession, Hates Tattooed Men", "Insanity (61-65): Obsession, Hates Dragons", "Insanity (66-68): Phobia, Adult Dragons", "Insanity (69-71): Phobia, Splugorth High Lords", "Insanity (72-74): Phobia, Splugorth", "Insanity (75-82): Compulsive Braggart", "Insanity (83-87): Random Affective Disorder", "Insanity (88-94): Random Neurosis", "Insanity (95-00): Random Psychosis"], note: "Conservator Insanity Table (printed 46-47): the page says to roll percentile dice twice; it prints no option to pick and does not say what a repeated result means." }
  - name: "Insanity (01-10): Compulsive Liar"
    description: "Roll 01-10. A compulsive liar, even if of a good alignment."
  - name: "Insanity (11-20): Kleptomaniac"
    description: "Roll 11-20. A kleptomaniac: a compulsive thief, even if of a good alignment."
  - name: "Insanity (21-30): Obsession, Hates Songbirds"
    description: "Roll 21-30. Obsession: hates songbirds, grumbles about their terrible squawking and tries to kill them whenever possible."
  - name: "Insanity (31-40): Obsession, Loves Fighting and Competition"
    description: "Roll 31-40. Obsession: fighting and competition; loves it."
  - name: "Insanity (41-42): Obsession, Hates Fighting"
    description: "Roll 41-42. Obsession: fighting; hates it and tries to avoid it."
  - name: "Insanity (43-50): Obsession, Loves Danger"
    description: "Roll 43-50. Obsession: danger; loves it and takes needless risks."
  - name: "Insanity (51-60): Obsession, Hates Tattooed Men"
    description: "Roll 51-60. Obsession: Tattooed Men. Hates them as competitors, constantly strives to compete with them and show them up, and is in constant verbal and physical confrontation with them. Always elects to fight a T-Man whenever one is among the group''s opponents, and may fight to the death. Feels the same, though not nearly as aggressively, toward crazies, juicers and borgs."
  - name: "Insanity (61-65): Obsession, Hates Dragons"
    description: "Roll 61-65. Obsession: dragons. Hates them as competitors, strives to compete with them and show them up, and is in constant verbal and physical confrontation with them. Always wants to take on a dragon whenever one is available as an opponent, and may fight to the death."
  - name: "Insanity (66-68): Phobia, Adult Dragons"
    description: "Roll 66-68. Phobia: adult dragons."
  - name: "Insanity (69-71): Phobia, Splugorth High Lords"
    description: "Roll 69-71. Phobia: Splugorth High Lords."
  - name: "Insanity (72-74): Phobia, Splugorth"
    description: "Roll 72-74. Phobia: the Splugorth."
  - name: "Insanity (75-82): Compulsive Braggart"
    description: "Roll 75-82. A compulsive braggart, constantly boasting about its superior fighting abilities and its triumphs in combat. Its own foes were always bigger, stronger and more dangerous than anybody else''s, and it meets every fight with a belittling question followed by a story about its prowess."
  - name: "Insanity (83-87): Random Affective Disorder"
    description: "Roll 83-87. Roll for a random affective disorder on the affective disorder table of the Rifts RPG insanity rules; that roll is made by hand."
  - name: "Insanity (88-94): Random Neurosis"
    description: "Roll 88-94. Roll for a random neurosis on the neurosis table of the Rifts RPG insanity rules; that roll is made by hand."
  - name: "Insanity (95-00): Random Psychosis"
    description: "Roll 95-00. Roll for a random psychosis on the psychosis table of the Rifts RPG insanity rules; that roll is made by hand."
natural_abilities:
  - { name: "Nightvision", description: "1000 ft (305 m), with excellent color vision." }
  - { name: "Turn Invisible", description: "At will." }
  - { name: "See the Invisible", description: "Always." }
  - { name: "Bio-Regeneration", description: "1D4x10 M.D.C. per minute." }
  - { name: "Dimensional Teleport", description: "98%, but only to its master the Splugorth, as often as once every 24 hours." }
  - { name: "P.P.E. Feeder", description: "A supernatural being that feeds on the P.P.E. of other living beings, like the psi-stalker, without the psi-stalker''s other powers. Half of its P.P.E. is drawn from the Splugorth." }
restrictions:
  - "A player character Conservator must be a freak and a renegade, and should not be easily available. Renegades are considered insane and dangerous and are killed on sight by any minion."
  - "Never wears artificial body armor."
side_effects: "INSANITY: every Conservator is obsessed with hunting, tracking and combat, and the hunt thrills it more than the kill. The training and bio-wizard augmentation also leave mental illness: roll twice on the Conservator Insanity Table (percentile), which is the two-roll Insanity group under special_abilities. Its last three rows (83-87, 88-94, 95-00) each send the player on to a random table of the Rifts RPG."
extraction_notes: "WB2 printed 45-47 (cache p045-p047, page_offset 0): the entry starts at the Splugorth Conservators heading on printed 45 after the High Lord (NPC-only, not imported) and ends on printed 47 after the Conservator Insanity Table, at the Splugorth Overlords heading. Printed 45 rendered and checked. || XP: printed 68 says the Conservator uses the Borg E.P. table in the Rifts RPG. Read off a render of Rifts Ultimate Edition printed 295 (pymupdf d[297]), the column headed Combat Cyborg, Headhunter and Robot Pilot, which is RUE''s borg ladder: 0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401. || KIND: stored as an R.C.C. (printed R.C.C. Skills). M.E. 18, P.S. 50, P.P. 21, P.E. 21 and Spd 44 are fixed by transmutation and stored as fixed values. || POOLS: M.D.C. 1D4x100+350 (the 350 is the natural bio-wizard plate). P.P.E. printed 1D4x100+20 under P.P.E. and 1D4x100 (+20 from eye of Eylor) under Magic; the same total, stored once. I.S.P. 2D4x10. Horror Factor 16. No hit points or S.D.C. printed. || COMBAT: eight physical attacks per melee including all augmentation is attacks_base 8; no Hand to Hand skill is granted or purchasable. || BONUSES are printed including augmentation bonuses; the book does not say whether attribute bonuses are included (the High Lord on 44 says in addition). Stored as printed, and the app adds its own P.P. 21, M.E. 18 and P.E. 21 figures on top. The printed +2 save vs magic is smaller than P.E. 21''s own +3, which is why the printed figures are read as in addition to attributes rather than inclusive. Save vs all types of magic is spell_magic and ritual_magic +2 each. Body block +3 strike is an ability. JUDGEMENT CALL for review. || PSIONICS: major, powers limited to eight named powers; read as having all eight, granted by name (Object read is the catalog Object Read (Psychometry)). || MAGIC: select eight spells from levels 1-3, most relating to hunting (a note only); spell strength frozen at 4th level is prose. No spell gain per level is printed. || SKILLS: Basic Math is Mathematics: Basic 45+30; Radio: Scrambler is Radio: Scramblers 35+10. Pilot all boats +10% is the five Boat: rows (Motor Race & Hydrofoil, Sail Type, Ships, Paddle Types, Submersibles); Military: Warships & Patrol Boats and Water Scooters are left out. Pilot hover vehicles +10% is Hover Craft (ground) 50+10. Climbing 40+20, Swimming 50+10, Wilderness Survival 30+20, Land Navigation 36+20. Six W.P.s and four wilderness skills are choice groups. No related or secondary skills are printed; none stored. || MONEY: none printed; omitted. || EQUIPMENT: one lesser or greater rune weapon, two doses each of aerobes, aquarobes, dehibicila, purirobes and stasirobes, 1D4 mystic leeches, 1D4+1 zombitrons, and a 50% chance of a pathic healer at camp. Stored in equipment_starting since fix-atlantis-minion-class-gear.sql: the rune weapon choice and the microbe, leech and zombitron doses (the zombitron row is priced as a pair; the qty is the book''s count). The 50% pathic healer stays in the body. || The average experience level 1D4+4 is NPC guidance, in the GM notes. || INSANITY TABLE (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 46 says to roll twice on the Conservator Insanity Table, which runs from printed 46 (01-10 to 61-65) onto printed 47 (66-68 to 95-00); both pages rendered and the folios checked. Fifteen rows are printed: 01-10, 11-20, 21-30, 31-40, 41-42, 43-50, 51-60, 61-65, 66-68, 69-71, 72-74, 75-82, 83-87, 88-94, 95-00, covering 01-00 with no gap or overlap. Stored as one rolls: 2 group of fifteen band-named Insanity options, one definition per row; side_effects keeps the universal hunting obsession and points at the group. No row prints a number, so no option carries bonuses. The three rows that send the player to a random affective disorder, neurosis or psychosis stay as that row''s prose. The book does not say whether the same result may come up twice; the group note says so."
---

## Lore

Conservators begin life as Splugorth High Lords, but some High Lords are driven by an insatiable lust to hunt and grow bored with the life of dignitaries, scholars and sorcerers. Early on they choose to become the bio-borg called the Conservator: a crazed predator that loves to stalk, track and fight, pumped up by bio-wizard augmentation much as a Crazy or a Juicer is by human science. They are the least common of the Splugorth elite, a few million across the whole empire.

A normal Conservator is a fanatically loyal, evil fiend who loves to hunt runaway slaves and enemies of the empire. The transmutation sometimes makes one more independent, more tolerant of other life, less loyal to its masters and hungry for adventure beyond the Splugorth''s realm. Such freaks are the only Conservators a player may portray.

## Appearance

A tall, ugly humanoid, 8 to 10 feet tall and 250 to 400 lbs, with grey or dusty brown, rhinoceros-like skin and armor, four over-sized arms with clawed fingers, a stinger tail and three eyes. The huge mouth is full of sharp teeth and holds the chemical spray. It never wears body armor, and lives more than 1000 years.

## Weapons and Gear

Each Conservator has one lesser or greater rune weapon. They favor hand to hand weapons made by bio-wizardry or techno-wizardry, vibro-blades and ancient weapons of every kind, and usually carry at least one long-range energy weapon despite preferring to close in. The average Conservator carries two doses each of aerobes, aquarobes, dehibicila, purirobes and stasirobes, 1D4 mystic leeches and 1D4+1 zombitrons, and half keep a pathic healer at camp.

## GM Notes

The book says the Conservator should not be easily available as a player character; one who is must be a renegade freak, considered insane and dangerous and killed on sight by any minion. Powerlords who turn against the Splugorth are typically hunted by one or two Conservators. NPC Conservators average level 1D4+4.
',
       updated_at = datetime('now')
 WHERE class_id = 'splugorth-conservator'
   AND instr(markdown, '01-10 compulsive liar, even if of good alignment; 11-20 kleptomaniac') > 0
   AND length(markdown) = 11633;

-- == rifts-gigantes ==
UPDATE imported_classes
   SET markdown = '---
id: rifts-gigantes
name: Gigantes
system: rifts
source_book: Rifts Conversion Book One p.91-92
category: rcc
tags: []
men_of_arms: false
occ_restrictions:
  only: ["bandit", "highwayman", "saddle-tramp", "vagabond", "merc-soldier", "freelancer", "tribal-warrior", "cowboy", "gaucho", "pirate", "gunfighter"]
  note: "Any basic Man at Arms O.C.C. that does not involve high technology (no robot pilots and the like), and simple ones like Raider, Bandit, Vagabond or Saddle Tramp. The catalog has no Raider O.C.C. The ids are a reading of ''basic, low-tech Man at Arms'': the Bandit, Highwayman, Saddle Tramp, Vagabond, Merc Soldier, Freelancer, Tribal Warrior, Cowboy, Gaucho, Pirate and Gunfighter."
attribute_dice:
  IQ: "2d6"
  ME: "1d6"
  MA: "2d6"
  PS: "4d6+8"
  PP: "3d6+6"
  PE: "4d6+6"
  PB: "2d6"
  Spd: "4d6"
mdc_base: "P.E. attribute number +1d6x10"
ppe_base: "2d4x10"
horror_factor: 13
bonuses:
  combat: { attacks_base: 3 }
  saves: { horror_factor: 4 }
skills:
  occ_skills:
    - { name: "Language: Troll/Giant", base: 90, per_level: 0, note: "Troll/Giant at 90%." }
    - { name: "Language: Gobblely", base: 90, per_level: 0, note: "Gobblely at 90%." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "One additional W.P. of choice." }
    - { name: "Swimming", base: 60, per_level: 5, note: "Instinctive swimmers, 60%." }
natural_abilities:
  - name: "Mega-Damage Creature"
    description: "On Rifts Earth a Gigante becomes a Mega-Damage creature with 1D6x10 M.D.C. plus the P.E. attribute number, plus any M.D.C. its mutations add. A.R. does not apply on Rifts Earth. In an S.D.C. setting it is a Hit Point and S.D.C. being instead: Hit Points P.E. attribute number +1D6 per level of experience, S.D.C. 1D6x10 plus possible mutation bonuses."
  - name: "Supernatural Strength and Endurance"
    description: "Supernatural P.S. and P.E.: every punch, kick or bite does Mega-Damage according to the individual Gigante''s P.S., read off the Supernatural P.S. Table; a bite usually does one quarter damage unless a mutation says otherwise. Three attacks per melee without combat training, or those from Hand to Hand and other physical skills."
  - name: "Nightvision"
    description: "40 feet (12.2 m); can see in total darkness. Good overall vision and hearing."
special_abilities:
  - { choose: 4, from: ["Keen Nightvision", "See the Invisible", "Turn Invisible", "Fire-Proof Hide", "Poisonous Bite", "Second Mouth", "Single Large Horn", "Additional Arm and Hand", "Scaly Skin", "Thick, Lumpy Skin", "Leather Wings", "Additional Eye", "Large, Heavy Tail", "Large Fangs", "Ape-like Body", "Feather Wings", "Claws", "Large, Flat Teeth", "Breathe Fire", "Spit Acid", "Additional Leg"], note: "The book''s Rifts Gigante Mutation & Special Abilities Table, printed 91-92: roll percentile FOUR times. Pick the four results here; the percentile band heads each entry so the roll can still be made at the table. The book does not say what a repeated result means, and a choice group cannot take one entry twice." }
  - { name: "Keen Nightvision", description: "01-05. Nightvision 3D6x20 yards/meters." }
  - { name: "See the Invisible", description: "06-10. See the invisible." }
  - { name: "Turn Invisible", description: "11-15. Turn invisible at will." }
  - { name: "Fire-Proof Hide", description: "16-20. Impervious to Mega-Damage fire, and add 20 M.D.C. to the creature.", bonuses: { pools: { mdc: 20 } } }
  - { name: "Poisonous Bite", description: "21-22. Poisonous bite: 4D6 S.D.C. damage." }
  - { name: "Second Mouth", description: "23-24. A second mouth: its bite does 1D6 M.D." }
  - { name: "Single Large Horn", description: "25-26. A single large horn: add 1D6 M.D. to a ram attack." }
  - { name: "Additional Arm and Hand", description: "27-32. An additional arm and hand: adds one melee attack.", bonuses: { combat: { attacks: 1 } } }
  - { name: "Scaly Skin", description: "33-40. Scaly skin: 2D6x10 additional M.D.C.", bonuses: { pools: { mdc: "2d6x10" } } }
  - { name: "Thick, Lumpy Skin", description: "41-45. Thick, lumpy skin: 1D6x10 additional M.D.C.", bonuses: { pools: { mdc: "1d6x10" } } }
  - { name: "Leather Wings", description: "46-50. Leather wings: a 01-50% chance they can fly, at a speed of 2D6x10; otherwise they are vestigial." }
  - { name: "Additional Eye", description: "51-54. An additional eye: +2 to initiative and Nightvision 40 feet (12.2 m).", bonuses: { combat: { initiative: 2 } } }
  - { name: "Large, Heavy Tail", description: "55-59. A large, heavy tail: can strike with it for 3D6 M.D." }
  - { name: "Large Fangs", description: "60-64. Large fangs: bite does 3D6 M.D." }
  - { name: "Ape-like Body", description: "65-69. An ape-like body covered in fur: +10 M.D.C.", bonuses: { pools: { mdc: 10 } } }
  - { name: "Feather Wings", description: "70-75. Feather wings: a 01-50% chance they can fly, at a speed of 3D6x10." }
  - { name: "Claws", description: "76-80. Claws: +1D6 M.D. to punch and clawing attacks." }
  - { name: "Large, Flat Teeth", description: "81-84. Large, flat teeth: bite does 2D4 M.D." }
  - { name: "Breathe Fire", description: "85-90. Breathe fire: 20 foot (6.1 m) range, 3D6 M.D." }
  - { name: "Spit Acid", description: "91-95. Spit acid: 20 foot (6.1 m) range, 4D6 M.D." }
  - { name: "Additional Leg", description: "96-00. An additional leg: adds 20% to balance and +1D4x10 to speed." }
  - { choose: 1, from: ["Insanity (01-10): Random Psychosis", "Insanity (11-20): No Insanity, but Aggressive", "Insanity (21-30): Hyper-Aggressive", "Insanity (31-40): Random Obsession", "Insanity (41-50): Random Phobia", "Insanity (51-60): Thinks It Is a Demigod", "Insanity (61-70): Psychotic Reliance", "Insanity (71-90): Random Insanity", "Insanity (91-00): Random Affective Disorder"], note: "Rifts Gigante Insanity Table (printed 92): the page says to roll once." }
  - { name: "Insanity (01-10): Random Psychosis", description: "Roll 01-10. Roll for a random psychosis on the Rifts RPG''s psychosis table; that roll is made by hand." }
  - { name: "Insanity (11-20): No Insanity, but Aggressive", description: "Roll 11-20. No insanity, but aggressive." }
  - { name: "Insanity (21-30): Hyper-Aggressive", description: "Roll 21-30. Easily provoked over the slightest thing. Tries to solve all problems with violence, and smashes things or pounds on the wall or ground when frustrated or angry and unable to act on it. +1 on initiative (applied), but reduce M.A. by 25% (a percentage of the rolled attribute, so worked by hand).", bonuses: { combat: { initiative: 1 } } }
  - { name: "Insanity (31-40): Random Obsession", description: "Roll 31-40. Make a random roll on the Obsession Table in the Rifts RPG (hates or loves something, perhaps literally to death); that roll is made by hand." }
  - { name: "Insanity (41-50): Random Phobia", description: "Roll 41-50. Make a random roll on the Phobia Table in the Rifts RPG; that roll is made by hand." }
  - { name: "Insanity (51-60): Thinks It Is a Demigod", description: "Roll 51-60. Thinks he or she is a demigod and indestructible, takes stupid risks, and demands worshipers and tribute." }
  - { name: "Insanity (61-70): Psychotic Reliance", description: "Roll 61-70. Completely convinced that it draws its power and strength from a particular object, usually a piece of junk. If the item is lost or stolen, all bonuses and P.S. damage are reduced by half; nothing is changed while the object is held." }
  - { name: "Insanity (71-90): Random Insanity", description: "Roll 71-90. Roll on the Random Insanity Table in the Rifts RPG; that roll is made by hand." }
  - { name: "Insanity (91-00): Random Affective Disorder", description: "Roll 91-00. Roll for a random affective disorder in the Rifts RPG; that roll is made by hand." }
side_effects: "Insanity plagues the Gigantes. Roll once on the Rifts Gigante Insanity Table (printed 92), which is the pick-one Insanity group under special_abilities; five of its nine rows send the player on to a table in the Rifts RPG."
extraction_notes: |
  - Rifts Conversion Book One printed 91-92 (file p092-p093). No Palladium Fantasy Gigantes row exists in the catalog on 2026-09-26; the id takes the `rifts-` prefix batch 1 set. The book uses "Gigantes" for the race and "Gigante" for one of them; the id and name are the race''s.
  - THE MUTATION TABLE IS A `choose: 4` OVER TWENTY-ONE `special_abilities` ENTRIES, the shape `keeper-of-the-desert` set for a random powers table: the book rolls percentile four times, a d100 roll is not something the schema expresses, and the percentile band heads each entry so the roll can still be made. The table prints 21 bands. Four entries carry the flat numbers the book states - +20 M.D.C., +1 attack, +2 initiative, +10 M.D.C. - and the two skin entries carry their M.D.C. dice as pool bonuses, which rollPoolFormula rolls once at creation. Every other entry''s mechanics are in its text: the bite, horn, tail, claw, breath and acid damages, the flight chances and speeds, and the extra leg''s +1D4x10 speed, which is an attribute dice bonus and so prose.
  - THE INSANITY TABLE IS A `choose: 1` GROUP OF NINE BAND-NAMED OPTIONS (2026-10-05, BOOK-INGEST-AUDIT.md F120). Printed 92 (file p093, folio checked on the render) heads it "Roll once" and prints nine rows: 01-10 random psychosis, 11-20 no insanity but aggressive, 21-30 hyper-aggressive, 31-40 the Obsession Table, 41-50 the Phobia Table, 51-60 thinks it is a demigod, 61-70 psychotic reliance, 71-90 the Random Insanity Table, 91-00 random affective disorder - 01-00 with no gap or overlap. One option per row, one definition each; side_effects now points at the group. Five rows (01-10, 31-40, 41-50, 71-90, 91-00) send the player to the Rifts RPG''s own tables, which this catalog does not hold as rows, so each stays as its row''s prose. Hyper-Aggressive''s +1 on initiative is printed flat and is stored as a bonus; its "reduce M.A. by 25%" is a percentage of a rolled attribute and stays prose. Psychotic Reliance''s halving of all bonuses and P.S. damage applies only if the object is lost or stolen, so it is prose.
  - A MEGA-DAMAGE BEING ON RIFTS EARTH: mdc_base is the page''s "1D6x10 M.D.C. plus P.E. attribute number", mutation M.D.C. added by the chosen entries. The S.D.C.-world figures are a natural ability, as on `rifts-troll`.
  - Attacks per Melee (Rifts): "Three without any combat training, or those gained from hand to hand combat" - an OR, so `attacks_base: 3`, which a Hand to Hand style''s four replaces rather than adds to.
  - Supernatural P.S. is prose; the app has no P.S. class key. Instinctive swimming at 60% is a Swimming grant, as on `rifts-troll`.
  - Psionics: "Standard, about the same as humans", so no psionics block.
  - occ_restrictions is an `only`, and it is a JUDGEMENT: "Any basic Man at Arms O.C.C., except those involving the use of high technology like robot pilot, and simple ones like Raider, Bandit, Vagabond, or Saddle Tramp" is read as low-tech Men of Arms plus the simple wanderers it names. The eleven ids are the low-tech fighters and drifters the catalog holds; Raider has no row. A matching O.C.C. imported after this is refused until it is added.
  - Height 12 to 20 feet; weight 1,000 to 2,000 pounds; life span 150 years. In the Lore.
  - The section-wide rule on printed 74 - a new arrival from the Palladium World picks up the regional language and two Modern W.P.s within weeks, then three Rifts skills from Communications, Pilot (basic vehicles), Technical and W.P. Modern after 2D4+4 months or one level, and one more language or skill every two levels - applies to a character who came from Palladium rather than one raised on Rifts Earth. It is not stored; the survey carries it.
---

# Gigantes

## Lore

The Gigantes, the Mutant Giants, are perhaps the most feared and bizarre giants of the Palladium World: mutants whose ever-shifting genes throw up a host of monstrous sub-species, no two alike. They are typically ignorant, aggressive misanthropes with a lust for bloodletting, preying on humans and Elves first but on anyone they think they can beat - other giants, dragons and demons included - and insanity plagues them. They are most numerous in the Yin-Sloth Jungles and the Northern Mountains.

They are uncommon on Rifts Earth, where the magic-rich environment makes them powerful Mega-Damage beings; they are known around the Calgary Rift, the Detroit-Windsor Rifts and parts of Europe and Asia. Their simple-mindedness, senseless savagery and small numbers keep them from becoming a serious threat.

**Alignment:** Any, but leans toward Anarchist (30%), Miscreant (30%) and Diabolic (30%).

**Appearance:** Varies dramatically, but always strange and monstrous.

**Height:** 12 to 20 feet (3.6 to 6.1 m); size varies dramatically. **Weight:** 1,000 to 2,000 pounds (450 to 900 kg).

**Average Life Span:** 150 years.

## GM Notes

Most Gigantes are wild, merciless fighters given to berserker rages and slaughter; they eat the flesh of their enemies, and villainous Gigantes attack Titans, their arch-enemies, on sight. Traditional enemies are Titans, Elves, Dwarves, humans and most non-giants; allies are Cyclops, Nimro, Trolls, Ogres, Orcs and Goblins, and on Rifts Earth they get along wonderfully with Daemonix, Brodkil, Gargoyles, Witchlings, Black Faeries, Simvan and Shifters, often joining evildoers and supernatural horrors.
',
       updated_at = datetime('now')
 WHERE class_id = 'rifts-gigantes'
   AND instr(markdown, 'THE INSANITY TABLE IS PROSE in side_effects.') > 0
   AND length(markdown) = 10796;

-- == norse-giant ==
UPDATE imported_classes
   SET markdown = '---
id: norse-giant
name: Greater Norse Giant
system: rifts
source_book: pantheons-of-the-megaverse p.163-166
category: rcc
tags: [supernatural]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 230001, 300001, 380001, 470001, 600001]
attribute_dice:
  IQ: "4d4"
  ME: "3d6"
  MA: "3d6"
  PS: "6d6+20"
  PP: "4d6+2"
  PE: "4d6+3"
  Spd: "6d6+10"
mdc_base: "2D6x100 plus 10 per level of experience"
ppe_base: "2d6x10"
occ_restrictions:
  only: ["combat-cyborg", "crazy", "cyber-knight", "glitter-boy", "headhunter-techno-warrior", "merc-soldier", "robot-pilot", "witch", "warlock-air", "warlock-earth", "warlock-fire", "warlock-water", "warlock-air-earth", "warlock-air-fire", "warlock-air-water", "warlock-earth-fire", "warlock-earth-water", "warlock-fire-water", "ley-line-walker"]
  note: "80% are warriors - any man of arms EXCEPT Coalition or NGR military. The other 20% study magic, limited to witch, warlock, necromancer or ley line walker; the catalog holds two Necromancer O.C.C.s now (necromancer and necromancer-russian) and this list names neither. The Warlock is ten classes here, one per Elemental Force and one per pair (RETRO-AUDIT R3, 2026-09-04), and all ten are open to a norse giant because the book restricts being a Warlock rather than which Force."
bonuses:
  combat: { initiative: 2 }
  saves: { horror_factor: 4 }
natural_abilities:
  - { name: "Nightvision", description: "60 ft (18.3 m); can see in total darkness." }
  - { name: "Resistant to cold or heat", description: "Half damage - cold for a frost giant, heat for a fire giant." }
  - { name: "Bio-regeneration", description: "1D4x10 M.D.C. per minute." }
special_abilities:
  - name: "Additional M.D.C."
    description: "An additional 1D6x1000 M.D.C., or 2D4x100 S.D.C. in a non-mega-damage world. Rolled 01-05."
  - name: "Great Nightvision"
    description: "Nightvision to 1000 ft (305 m). Rolled 06-10."
  - name: "Turn Invisible at Will"
    description: "Turn invisible at will. Rolled 11-15."
  - name: "Impervious to Heat and Fire"
    description: "Impervious to heat and fire. Rolled 16-20."
  - name: "Fangs and Poisonous Bite"
    description: "3D6 damage per melee for 1D6 rounds. Rolled 21-24."
  - name: "Change Size at Will"
    description: "Change size at will, from 6 to 40 feet (1.8 to 12.2 m). Rolled 25-30."
  - name: "Pair of Tentacles"
    description: "+1 attack per melee and +1 to parry. Rolled 31-33."
    bonuses: { combat: { attacks: 1, parry: 1 } }
  - name: "Giant''s Strength"
    description: "Add 10 to the P.S. attribute. Rolled 34-40."
    bonuses: { attributes: { PS: 10 } }
  - name: "Thick, Lumpy Skin"
    description: "Add 1D4x100 M.D.C., or S.D.C. in a non-mega-damage world. Rolled 41-45."
    bonuses: { pools: { mdc: "1d4x100" } }
  - name: "Pair of Additional Arms"
    description: "+2 attacks per melee and +2 to parry. Rolled 46-50."
    bonuses: { combat: { attacks: 2, parry: 2 } }
  - name: "Additional Eye"
    description: "Hawk-like vision and see the invisible. Rolled 51-54."
  - name: "Prehensile Tail"
    description: "Adds one attack per melee round. Rolled 55-59."
    bonuses: { combat: { attacks: 1 } }
  - name: "Battle-Hardened"
    description: "+2 on initiative, +2 to roll with impact, +4 to save vs horror factor. Rolled 60-64."
    bonuses: { combat: { initiative: 2, roll: 2 }, saves: { horror_factor: 4 } }
  - name: "Great Speed"
    description: "Add 1D4x10 to the Spd attribute. Rolled 65-69."
    bonuses: { attributes: { Spd: "1d4x10" } }
  - name: "Metamorphosis into Animal"
    description: "Metamorphosis into an animal at will. Rolled 70-75."
  - name: "Retractable Claws"
    description: "Add 2D6 to all hand to hand attacks. Rolled 76-80."
  - name: "Increased Healing"
    description: "Regenerates 1D4x100 M.D.C. per minute. Rolled 81-84."
  - name: "Create Fire Ball"
    description: "Once per melee round at will. Range 1000 feet (305 m), does 1D4x10 M.D. Rolled 85-90."
  - name: "Create Lightning Bolt"
    description: "Once per melee round at will. Range 1000 feet (305 m), does 6D6 M.D. Rolled 91-95."
  - name: "Third Monstrous Eye and Ugly Head"
    description: "Psionic with ALL sensitive powers and six super-psionic powers of choice. Rolled 96-00."
    psionics: { type: "master" }
  - { choose: 3, from: ["Additional M.D.C.", "Great Nightvision", "Turn Invisible at Will", "Impervious to Heat and Fire", "Fangs and Poisonous Bite", "Change Size at Will", "Pair of Tentacles", "Giant''s Strength", "Thick, Lumpy Skin", "Pair of Additional Arms", "Additional Eye", "Prehensile Tail", "Battle-Hardened", "Great Speed", "Metamorphosis into Animal", "Retractable Claws", "Increased Healing", "Create Fire Ball", "Create Lightning Bolt", "Third Monstrous Eye and Ugly Head"] }
  - { choose: 1, from: ["Insanity (01-15): No Insanity", "Insanity (16-40): Phobia", "Insanity (41-70): Obsession", "Insanity (71-80): Neurosis", "Insanity (81-90): Psychosis", "Insanity (91-00): Affective Disorder"], note: "Insanity (printed 163): the page says to roll one time." }
  - name: "Insanity (01-15): No Insanity"
    description: "Roll 01-15. No insanity."
  - name: "Insanity (16-40): Phobia"
    description: "Roll 16-40. A phobia. The page prints only the category; which phobia is rolled by hand on the phobia table of the Rifts RPG insanity rules."
  - name: "Insanity (41-70): Obsession"
    description: "Roll 41-70. An obsession. The page prints only the category; which obsession is rolled by hand on the obsession table of the Rifts RPG insanity rules."
  - name: "Insanity (71-80): Neurosis"
    description: "Roll 71-80. A neurosis. The page prints only the category; which neurosis is rolled by hand on the neurosis table of the Rifts RPG insanity rules."
  - name: "Insanity (81-90): Psychosis"
    description: "Roll 81-90. A psychosis. The page prints only the category; which psychosis is rolled by hand on the psychosis table of the Rifts RPG insanity rules."
  - name: "Insanity (91-00): Affective Disorder"
    description: "Roll 91-00. An affective disorder. The page prints only the category; which one is rolled by hand on the affective disorder table of the Rifts RPG insanity rules."
restrictions:
  - "Alignment: any, but leans towards anarchist and evil. A Norse giant of a scrupulous or principled alignment is likely to be thought untrustworthy and a freak, and probably tormented as well."
  - "Horror Factor: 10+1D6."
  - "Attacks per melee: two without any combat training, or two plus those gained from hand to hand combat and/or boxing."
  - "The +4 to save vs horror factor does NOT apply when dealing with Thor. No bonus then."
  - "Some greater giants are the equivalent of gods, at 3D6x1000 M.D.C., but they are rare - perhaps one in ten thousand - and serve as the warrior lords and leaders of the other giants. Not a player character."
  - "Insanity: roll one time on the giant''s insanity table (printed 163), which is the pick-one Insanity group under special_abilities."
  - "Size is 1D4x10 feet (3 to 12.2 m). Changing size is one of the special powers rather than something every giant can do."
  - "Occupations: 80% are warriors - any men of arms other than Coalition or NGR type military - and 20% study magic, limited to witch, warlock, necromancer or ley line walker. The CS and NGR exclusion is prose because the format cannot express an exception inside an `only` list."
side_effects: "The giants of Norse myth were more than overly large humanoids. The Old Norse word for them was iotnar, which means demon or monster: supernatural creatures whose powers were almost the match of the gods, many with shape shifting and magical powers. Average life span 2000+ years. The LESSER Norse giants are the Algor frost giants, Nimro fire giants, Jotan earth giants and Gigantes described in Rifts Conversion Book One; this entry is the greater giants, who are far more powerful."
extraction_notes: |
  Read from Pantheons of the Megaverse printed p.163 with
  scripts/read-columns.py. Text layer; printed 163 is cache p164 (page_offset 1).

  Five things worth recording:

  1. THE BOOK PRINTS NO P.B. It lists I.Q., M.E., M.A., P.S., P.P., P.E. and
     Spd and simply stops. That is the page, not a dropped line - checked
     against the raw text. No P.B. die is invented here, so the attribute is
     left for the G.M. to set.
  2. NO SKILLS OF ANY KIND, and that is correct rather than missing. The giant
     takes an O.C.C. and every skill comes from there - the pure
     race-plus-occupation case, the same as the Demigod.
  3. "Experience: Use same table as the Dragon R.C.C." The dragon ladder is stored,
     copied 2026-09-26 from dragon-hatchling, which has carried RUE''s since #1415.
     The import stored none, because that row then stored none and both fell
     through to DEFAULT_XP_TABLE in js/leveling.js; Nate, 2026-09-26: a class whose book says to use another class''s experience table copies that class''s ladder.
     A correction to the dragon ladder has to be copied here by hand.
  4. The twenty special abilities are the book''s random table, kept in its
     printed order with each entry''s roll range in its description. The book
     says "Roll for (or GM pick) three random abilities or pick three", so a
     choose-three group covers both readings; the percentiles are recorded so
     a G.M. who wants to roll still can.
  5. "Psionics: Standard" means NO psionics block at all, which is the opposite
     of what it looks like. Declaring a tier would fix the giant at that tier
     and stop him rolling on the Random Psionics Table; staying silent is what
     lets the roll happen, and "standard" is the roll. Same reading the Demigod
     already records. Ability 96-00 is the exception and carries `psionics:
     master` on itself, where it belongs, rather than on the class.

  THE OCCUPATION LIST IS ENUMERATED, AND IT IS THE ONE PLACE THIS CLASS COULD
  GO STALE. The book says "any men of arms OTHER THAN CS or NGR type military",
  and a `group:` token cannot carve out an exception - `only:
  ["group:men-of-arms"]` would have admitted coalition-grunt,
  coalition-samas-pilot and coalition-technical-officer, which is the exact
  thing the sentence excludes. So the eight non-Coalition men of arms are
  listed by id, checked against production, and a Rifts man of arms imported
  later will need adding here by hand. That is a real cost and it is the
  cheaper of the two errors.

  JUICER IS LEFT OUT although it is a man of arms, because the other direction
  already refuses it. `race_restrictions` closes the Juicer - along with the
  Dog Boy, both Psi-Stalkers and the three Coalition classes - to every Rifts
  race, human only, and that rule reaches this class the moment it exists.
  Listing it here would have been a permission that silently does nothing: the
  wizard would offer it and the pairing would be refused. Same smell as a
  restriction that silently does nothing, pointed the other way.

  combat-cyborg and crazy ARE left available. The book does not repeat the
  Demigod''s rule that those treatments fail on a supernatural being, and
  nothing in the catalog closes them, so both directions agree. Odd for a
  2D6x100 M.D.C. creature, and deliberate: this entry says men of arms and
  stops.

  NECROMANCER IS OMITTED FROM THE LIST, and the omission is the interesting
  part. The book allows witch, warlock, necromancer or ley line walker; this
  catalog held no Necromancer O.C.C. when the list was drafted. Two exist now,
  `necromancer` (Rifts World Book 4: Africa) and `necromancer-russian` (Mystic
  Russia), and the list still names neither. A dangling name in an `only` list is
  harmless on its own - it never matches, so the occupation stays unavailable
  for the honest reason that it does not exist - but `occ_restrictions` is held
  to a stricter rule than skill restrictions are: regression asserts that every
  occupation a race names is a real O.C.C., because in an `except` list the
  same dangling name silently ALLOWS what it meant to forbid. One rule for both
  list kinds is the right trade, so the name comes out and the note records
  what to add when a Necromancer O.C.C. exists. The other three were checked
  against production.

  THE INSANITY TABLE IS A PICK-ONE GROUP (2026-10-05, BOOK-INGEST-AUDIT.md
  F120). Printed 163 (file p164, folio checked on the render) prints, after
  the twenty abilities, "Insanity (roll one time)" and six rows: 01-15 no
  insanity, 16-40 phobia, 41-70 obsession, 71-80 neurosis, 81-90 psychosis,
  91-00 affective disorder - 01-00 with no gap or overlap. Stored as one
  `choose: 1` group of six band-named Insanity options, one definition per
  row, beside the three-ability group, which is untouched. The restrictions
  line that carried the bands is now a pointer. Each row names a category
  only, so which phobia, obsession, neurosis, psychosis or affective disorder
  it is stays a hand roll on the Rifts RPG''s tables, said in each row. No row
  prints a number, so no option carries bonuses.
---

## Lore

The giants of Norse myth were more than overly large humanoids. The Old Norse
word used to name them was *iotnar* - demon, or monster. These were
supernatural creatures whose powers were almost the match of the gods, and many
of them had shape shifting and magical powers of their own.

Their abilities are quite varied, which is why no two greater giants are alike.
The lesser Norse giants - the Algor frost giants, Nimro fire giants, Jotan earth
giants and the Gigantes - are described in Rifts Conversion Book One. These are
the greater giants, and they are far more powerful.

A giant of a scrupulous or principled alignment is a freak among his own kind:
untrustworthy in their eyes, and likely tormented for it.

## GM Notes

Two things to hold onto. The first is that a greater giant is a walking
exception - the twenty-entry ability table means the giant the players meet may
be able to do something no other giant they have met could, and the book means
that. Roll, or pick to fit the story.

The second is Thor. The giant''s +4 to save vs horror factor is void when he is
dealing with Thor, and that single line is the whole relationship between this
race and the Aesir: they are frightened of him specifically. It is worth playing.

The rare god-equivalent giants at 3D6x1000 M.D.C. are warrior lords, roughly one
in ten thousand, and are not player characters.
',
       updated_at = datetime('now')
 WHERE class_id = 'norse-giant'
   AND instr(markdown, 'Roll once on the insanity table, or have the G.M. pick: 01-15 none') > 0
   AND length(markdown) = 12409;

-- == maxi-killer ==
UPDATE imported_classes
   SET markdown = '---
id: maxi-killer
name: Maxi-Killer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.53-55
category: occ
tags: [combat, augmented]
xp_table: [0, 2601, 5001, 10001, 20001, 30001, 49001, 62001, 80001, 110001, 150001, 200001, 250001, 310001, 370001]
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre", "wolfen"]
  note: "This is the one Juicer conversion with its own printed racial list, and it is the widest in the book - Juicer Uprising p.54 names humans, True Atlanteans (but not Tattooed Men, and fewer than six magic tattoos), Kittani, Kydians, Wolfen, Elves, Dwarves, Simvan, Hawrk-duhk, Hawrk-ka, Hawrk-ofil, a variety of human-like D-Bees, and Splugorth High Lords who rarely bother. Most Maxi-Killers are humans, ogres or elves raised in slavery. Only the races this catalog actually holds can be named here; the rest are recorded in the prose and will start working by themselves if they are ever imported. Barred outright: shapeshifters, major or master psychics, practitioners of magic, creatures of magic and supernatural beings."
mdc_base: "2d4x10+60, +10 per level"
starting_money: "0"
bonuses:
  attributes: { PS: 8, PE: "1d4", PP: "1d4+1", Spd: "1d6x10" }
  attribute_minimums: { PS: 21 }
  combat: { initiative: 3, roll: 3, attacks: 1 }
  saves: { spell_magic: 4, psionics: 2, possession: 2, toxins_poisons: 4, disease: 4, horror_factor: 4, coma_death_pct: 30 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Language: Dragonese", base: 98, per_level: 0, note: "Dragonese/Elf at 98%." }
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "American at 98%." }
    - { name: "Intelligence", base: 42, per_level: 4, note: "+10%" }
    - { name: "Tracking (people)", base: 35, per_level: 5, note: "Printed as Tracking (+10%)." }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { name: "Climbing", base: 50, per_level: 5, note: "+10%" }
    - { name: "Swimming", base: 55, per_level: 5, note: "+5%" }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { name: "W.P. Sword", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two weapons of choice." }
    - { choose: 1, from: ["Hand to Hand: Martial Arts", "Hand to Hand: Assassin"], note: "The Maxi-Killer starts at Martial Arts or Assassin - the only class in this book that does not begin at Expert, and the only one with nothing to trade for the upgrade." }
  occ_related_skills:
    count: 4
    schedule: [{ level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Military", bonus: 10 }
      - { name: "Physical", bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod"], bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", bonus: 2 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced"], bonus: 10 }
      - { name: "Technical", except: ["Computer Operation", "Computer Programming"], bonus: 5 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "The book prints Pilot as any EXCEPT robot and power armor skills, and Technical as any EXCEPT computer; both are spelled out as the catalog rows they exclude, because an unmatched name in an except list excludes nothing and does so silently. Computer Repair is filed under Electrical here, which the Maxi-Killer restricts to Basic Electronics anyway."
  secondary_skills:
    count: 6
special_abilities:
  - name: "The Maxi-Inducer Symbiote"
    description: "Not a bio-comp and harness but a living thing, attached to the recipient''s back and resembling a chest amalgamate without a mouth or sensory organs. Its roots grow inside the body as well as outside, wrapping tendrils around the limbs and invading the internal organs. It both enhances and regulates the host''s metabolism, raising his attributes to supernatural levels. REMOVING IT IS IMPOSSIBLE WITHOUT INSTANTLY KILLING THE PATIENT."
  - name: "Grafted Armor"
    description: "A second symbiote linked to the Maxi-Inducer grows over the character like a living shell: 120 M.D.C. that regenerates 1D4x10 M.D.C. per hour, covered in a dozen or so small protective spines. It grows one forearm blade per level of experience up to three per arm, each an M.D.C. structure inflicting 2D6 M.D. If its M.D.C. is driven to zero it disappears, its roots retreating into the body - and until it has regenerated 50 M.D.C. the Juicer cannot regenerate at all and takes 3D6 M.D. per hour as the symbiote feeds on him to rebuild itself. Every point he loses goes into the symbiote. Past 50 M.D.C. both recover normally, and the armour regrows completely ten hours after that mark. If the Maxi-Killer dies before the creature reaches 50, THEY BOTH DIE."
  - name: "Supernatural Strength and Endurance"
    description: "A flat +8 to P.S., minimum 21, and it is supernatural. Damage follows the supernatural strength table reprinted in the Titan Juicer entry."
  - name: "Regeneration"
    description: "Regenerates 1D4x10 M.D.C. per hour and can REGROW SEVERED LIMBS AND LOST ORGANS - which no other Juicer in this book can do. Virtually impervious to pain. The +30% to save versus coma and death is in the bonuses block, and is the highest in the book."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Further Bio-Wizard Implants"
    description: "A Maxi-Killer who shows great loyalty and combat prowess, or who was made for the arena, may be granted one or two additional Bio-Wizard implants or appendages - rarely before third level. Kittani and Kydian volunteers get three automatically. A player character who escaped Atlantis will never be given any."
  - { choose: 1, from: ["Insanity (01-60): No Insanity", "Insanity (61-75): Loves Fighting and Competition", "Insanity (76-78): Hates Fighting", "Insanity (79-84): Obsession with Danger", "Insanity (85-90): Fear of Tattoos", "Insanity (91-95): Phobia of Splugorth", "Insanity (96-00): Phobia of High Lords"], note: "Maxi-Killer Insanity Table (printed 54), rolled once at creation or picked. The page has it rolled AGAIN every time a new bio-wizard enhancement is acquired: make that later roll by hand and record the result, it is not offered here." }
  - name: "Insanity (01-60): No Insanity"
    description: "Roll 01-60 or choose. No insanity: the conditioning held."
  - name: "Insanity (61-75): Loves Fighting and Competition"
    description: "Roll 61-75 or choose. Obsessed with fighting and competition, and loves it."
  - name: "Insanity (76-78): Hates Fighting"
    description: "Roll 76-78 or choose. Obsession with fighting: hates it and tries to avoid it."
  - name: "Insanity (79-84): Obsession with Danger"
    description: "Roll 79-84 or choose. Obsession with danger: loves it and takes needless risks."
  - name: "Insanity (85-90): Fear of Tattoos"
    description: "Roll 85-90 or choose. Not exactly a phobia, but a slight fear and paranoia about tattoos and those who have them: cannot stand to get any, distrusts anyone who has even one, and is very suspicious of Tattooed Men."
  - name: "Insanity (91-95): Phobia of Splugorth"
    description: "Roll 91-95 or choose. Phobia: Splugorth."
  - name: "Insanity (96-00): Phobia of High Lords"
    description: "Roll 96-00 or choose. Phobia: High Lords."
side_effects: "The human body is not meant to hold this state for long. Life span is the recipient''s own average divided by TWENTY, plus 4D6 months - so an average human or ogre lasts four years plus 4D6 months, a True Atlantean 25 years plus 4D6 months, and a Splugorth High Lord with a 1,200-year span would get 60 years plus 4D6 months, a long time for a human and a fraction of a lifetime for him. On top of the usual Juicer anxieties, insomnia, restlessness and impatience: the Maxi-Killer insanity table is rolled once at creation - that roll is the Insanity pick among the abilities - and again, by hand, every time a new bio-wizard enhancement is acquired. 01-60 no insanity; 61-75 obsessed with fighting and competition and loves it; 76-78 obsession with fighting, hates it and avoids it; 79-84 obsession with danger, takes needless risks; 85-90 a slight fear and paranoia about tattoos and those who have them, cannot stand to get any and distrusts anyone who has even one, very suspicious of Tattooed Men; 91-95 phobia of Splugorth; 96-00 phobia of High Lords."
restrictions: ["No cybernetics, ever.", "Available only to slaves and minions of the Splugorth.", "Cannot be transformed into a Murder-Wraith: the bio-wizardry prevents the necromantic ritual from taking effect.", "Shapeshifters, major or master psychics, practitioners of magic, creatures of magic and supernatural beings cannot take this conversion at all.", "True Atlanteans may take it only if they are not Tattooed Men and carry fewer than six magic tattoos."]
extraction_notes: "starting_money is 0 because the book prints Money: None - a Maxi-Killer is a slave and is issued what he needs, with a monthly allowance only at his master''s discretion. The life span is a FORMULA against the recipient''s own species rather than a fixed span, which is unique in this book and is stated in side_effects rather than computed. The +8 to P.S. is a flat integer, not dice, which is also unique here. The racial list is the widest in the book and most of it names races this catalog does not hold - Kittani, Kydians, Simvan, the three Hawrk peoples, True Atlanteans and Splugorth High Lords - so those are prose, and race_restrictions names only wolfen, dwarf, elf, ogre and the human case. An `only` fails closed, so this is a conservative reading that will widen by itself if any of those races is ever imported. 2026-10-05 (BOOK-INGEST-AUDIT.md F120): the Maxi-Killer Insanity Table, printed p.54 item 10, is seven rows - 01-60 no insanity, 61-75, 76-78, 79-84, 85-90, 91-95, 96-00 - covering 01-00 with no gap or overlap. The page says to roll once, and to roll again every time a new bio-wizard enhancement is acquired. Stored as one pick-one group of seven band-named Insanity options for the creation roll; the roll per later enhancement is stated in the group note and in side_effects and is made by hand, because it is earned in play rather than at a level. No row prints a number, so no option carries bonuses."
---

## Lore

The Splugorth of Atlantis have their own Juicer, and they built it to work on
people the human process kills.

The Atlantean conversion combines high technology - much of it copied directly
from human systems - with bio-wizardry. Officially it is the Bio-Wizard Juicer.
Everyone calls it the Maxi-Killer. Instead of a bio-comp and a drug harness
there is a Juicer Symbiote, the Maxi-Inducer, which attaches to the recipient''s
back, monitors his biology, and manipulates it.

Most Maxi-Killers are humans, ogres or elves raised in slavery, born to it or
taken young, and trained in combat since early childhood. Only the toughest and
most ruthless are chosen for the enhancement, or for similar "elite" gifts like
the Tattooed Maxi-Man. At sixteen or seventeen the loyal slave is united with the
symbiote and becomes a warrior in the service of the Splugorth.

They are teamed with Tattooed Men, Maxi-Men, Power Lords and other slave
warriors, and they are a popular attraction in the arenas of Atlantis. Trusted
servants are rewarded with as many as two more bio-wizard implants or limbs.
Some have been exported across the Megaverse, reaching Phase World and other
transdimensional markets as the property of a High Lord or as gladiators.

A few have escaped. None of them can ever live a normal life, covered as they
are by the symbiote - and there is no taking it off.

## GM Notes

**Demographics.** The Maxi-Killer does not appear in the book''s North American
Juicer breakdown at all; it is Splugorth technology, and its numbers belong to
Atlantis.

**This is the widest-open Juicer in the book and the most owned.** Fourteen
named peoples can take it, against the human-plus-three of everything else - and
the price is that you are a slave. An escaped Maxi-Killer is a strong character
concept with a symbiote on his back that everyone can see.

**The armour is a second creature with its own hit points and its own agenda.**
Drive it to zero and it does not just stop protecting him: it starts eating him,
3D6 M.D. an hour, until it has rebuilt 50 M.D.C. And if he dies first, it dies.
That is a fight with a third party in it.

**The life span formula is the cruellest thing here.** Divide by twenty. A human
gets four years. A True Atlantean gets twenty-five - and loses four hundred and
seventy-five.
',
       updated_at = datetime('now')
 WHERE class_id = 'maxi-killer'
   AND instr(markdown, 'roll once on the Maxi-Killer insanity table, and again every time') > 0
   AND length(markdown) = 11045;

-- == dragon-juicer ==
UPDATE imported_classes
   SET markdown = '---
id: dragon-juicer
name: Dragon Juicer
system: rifts
source_book: Rifts World Book 10: Juicer Uprising p.47-50
category: occ
tags: [combat, augmented, supernatural, high-power]
xp_table: [0, 3001, 5001, 10001, 20001, 30001, 50001, 80001, 120001, 170001, 250001, 325001, 400001, 525001, 650001]
occ_group: men-of-arms
race_restrictions:
  only: ["none", "dwarf", "elf", "ogre"]
  note: "Juicer Uprising p.17 names the Dragon Blood Juicer as one of the three variants a Dwarf may take, along with Titan and Mega, and the standard conversion. Elves may be any Juicer type; Ogres are close enough to human for any conversion. True Atlanteans qualify but have no R.C.C. row in this catalog yet. Note the book''s other warning: dragon''s blood causes a lethal allergic reaction in some humans, which is a separate hazard from race."
mdc_base: "P.E. + 3d6x10, +10 per level"
ppe_base: "2d4x10"
starting_money: "6d6x100"
bonuses:
  attributes: { PS: "2d6", PE: "2d6", PP: "1d6", Spd: "1d4x10" }
  attribute_minimums: { PS: 20, PP: 18 }
  combat: { initiative: 2, roll: 2, attacks: 2 }
  saves: { psionics: 2, mind_control: 4, toxins_poisons: 6, harmful_drugs: 6, horror_factor: 5, coma_death_pct: 20 }
equipment_starting:
  - { item_id: "bio-comp-system", qty: 1 }
  - { item_id: "drug-injection-harness", qty: 1 }
  - { item_id: "portable-irmss-kit", qty: 1 }
  - { item_id: "fatigues", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "sunglasses", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "compass", qty: 1 }
  - { item_id: "super-hide-armor", qty: 1 }
  - { choose: 1, label: "energy rifle of choice", qty: 1, from: ["ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle", "ng-p7-northern-gun-particle-beam-rifle", "l-20-pulse-rifle", "ng-ip7-ion-pulse-rifle", "ja-12-laser-rifle"] }
  - { choose: 1, label: "energy pistol of choice", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "c-18-laser-pistol", "ng-45lp-long-pistol", "ng-h5-holdout-ion-pistol"] }
  - { item_id: "e-clip", qty: 10 }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 50, per_level: 5, note: "+5%" }
    - { name: "Wilderness Survival", base: 35, per_level: 5, note: "+5%" }
    - { name: "Land Navigation", base: 41, per_level: 4, note: "+5%" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Piloting: one of choice (+10%)." }
    - { name: "Lore: Demons & Monsters", base: 35, per_level: 5, note: "Printed as Demon and monster lore (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 10, note: "Language: two of choice (+10%). Taken once per language - the picker asks which." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P.: two of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be changed to Hand to Hand: Martial Arts (or Assassin, if an evil alignment) at the cost of one O.C.C. Related Skill." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Espionage", only: ["Intelligence", "Escape Artist", "Detect Ambush", "Detect Concealment"], bonus: 5 }
      - "Military"
      - { name: "Physical", bonus: 5 }
      - "Pilot"
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5 }
    note: "Electrical, Mechanical and Medical are all None for a Dragon Juicer and are therefore absent from this list rather than restricted - the widest set of closed categories of any Juicer in the book. Rogue is printed with +5% to Prowl only; this catalog files Prowl under Physical, so a Dragon Juicer taking Prowl reads it at +5% from Physical anyway."
  secondary_skills:
    count: 4
special_abilities:
  - name: "Supernatural Being"
    description: "The dragon''s blood makes the Juicer a supernatural creature outright, with M.D.C. equal to P.E. plus 3D6x10 and another 10 M.D.C. per level. Endurance is supernatural as well as strength."
  - name: "Supernatural Strength"
    description: "Damage follows the supernatural strength table reprinted in the Titan Juicer entry. At the minimum P.S. of 20 that is 3D6 S.D.C. restrained, 1D6 M.D. full strength, 2D6 M.D. on a power punch counting as two attacks."
  - name: "Supernatural Dragon Senses"
    description: "Nightvision to 100 feet (30.5 m), See the Invisible, perfect hawk-like vision, and a keen sense of smell."
  - name: "Dragon P.P.E."
    description: "A base of 2D4x10 P.P.E. - and the Dragon Juicer can do NOTHING with it: he cannot learn magic and cannot use psionic powers. It sits there being large, which some think is why a dragon vampire can survive on untreated blood."
  - name: "Super Speed"
    description: "Leap 40 feet (12.2 m) across after a short run, half from a standstill, and 20 feet (6.1 m) high, half without a run. The longest leap of any Juicer in the book."
  - name: "Super Reflexes and Reaction Time"
    description: "Gets an automatic parry or dodge against ALL attacks, including from behind and from surprise."
  - name: "Regeneration"
    description: "Regenerates 4D6 M.D.C. per minute - once every four melee rounds. Impervious to disease and to normal cold and heat. The +20% to save versus coma and death is in the bonuses block."
  - name: "Extending the Clock"
    description: "The blood of an ANCIENT dragon, 5,000 years or older, properly treated by an alchemist, adds 6D6 months to the Dragon Juicer''s life. The alchemist needs at least a gallon, the process takes 1D6 months and costs 3D6x100,000 credits - a quarter of that if the Juicer supplies the blood himself. Which is the problem."
side_effects: "TERMINAL ADDICTION TO DRAGON''S BLOOD. Life span is a normal Juicer''s, 5 years plus 4D6 months, but blood from another dragon must be provided EVERY SIX MONTHS, typically at 10,000-40,000 credits. Miss it and M.D.C. and all combat bonuses drop by half, two melee attacks are lost, and stomach cramps and fever strike 1D4 times a day - each bout lasts 2D6 minutes at -6 on initiative and one further attack lost. Miss it for another six months and the character DIES. Most Dragon Juicers never get the chance to solve this the direct way: as soon as word gets around that somebody is hunting ancient dragons, one or more of those dragons takes action. INSANITY. Nightmares about dragons 1D4 times a week for life. After two years, roll: 01-30 paranoia and phobia of dragons (perhaps for good reason); 31-60 obsessed with fighting and killing dragons and other supernatural beings; 61-90 delusional, believes he IS a dragon, and roll on the Juicer Psychosis table for disposition; 91-00 DRAGON VAMPIRE - drinks the untreated blood of slain dragons, which strangely keeps him alive, spares him the alchemist every six months, and adds another 1D6 months to his life. Dragon vampires are usually quite mad."
restrictions: ["No cybernetics, ever.", "Cannot learn magic and cannot use psionic powers, despite carrying 2D4x10 P.P.E.", "Cannot be transformed into a Murder-Wraith: the magic in the conversion prevents the necromantic ritual from taking effect.", "Very rare. Only one shop in Kingsdale and select members of the Federation of Magic are known to make them, and the conversion runs 600,000 to one million credits and takes three months."]
extraction_notes: "The book prints +1D4 on initiative; the bonuses block stores integers for combat, so the average of 2 is carried and the printed dice are recorded here. Impervious to disease and to normal cold and heat is prose rather than a save, because it is an immunity rather than a bonus. The class is an O.C.C. rather than an R.C.C. even though the character becomes a supernatural being - the book prints O.C.C. Skills, O.C.C. Related Skills and Secondary Skills for it, and the transformation happens to a person who already had an occupation. Standard equipment names Dragon Skin Combat Armor at 100 M.D.C., which has no gear row yet. 2026-10-05 (BOOK-INGEST-AUDIT.md F120): the insanity table is printed on p.49 under Insanity - four rows, 01-30, 31-60, 61-90, 91-00 - and the page says to roll on it AFTER TWO YEARS as a Dragon Juicer. Nothing is rolled at creation and nothing is tied to a level, so it is deliberately NOT a pick group: it stays in side_effects, to be rolled by hand when the two years are up. The page adds two things side_effects words briefly: on 61-90 the Juicer Psychosis roll is made again if either phobia comes up, and a 91-00 dragon vampire also rolls once on the neurosis table and once on the obsession table of the Rifts RPG."
---

## Lore

In 78 P.A. a band of adventurers killed an adult dragon that had been plaguing
the outskirts of Kingsdale. Among them was a techno-wizard and amateur alchemist
called Regius, who had heard the stories about the magical properties of
dragon''s blood and drew off several gallons for his experiments.

He tested it for years. He drank some himself, early on, and it nearly killed
him - dragon''s blood turns out to cause a lethal allergic reaction in some
humans. Eventually he presented his findings to a gathering of magicians and
technocrats at Kingsdale: laced with the right Juicer chemicals, dragon blood
grants humans supernatural power.

The price was steep. The mundane chemicals bring all the usual Juicer side
effects, including the short life. Worse, the transformed become terminally
addicted to the blood of dragons - and while the maintenance dose is small,
going without for even a week can kill. And most dragons will not part with
their blood willingly.

They made them anyway. One of the sorcerers involved was a dragon herself, and
she volunteered the blood; highly individualistic and driven, she saw no moral
problem in creating beings who might one day hunt and kill her own kind. The
first full Dragon Juicers, all volunteers, were made in 89 P.A. In 100 P.A. the
Federation of Magic bought exclusive rights to Regius''s secrets for a fortune,
on the condition that his Kingsdale shop could keep making them too. By 101 P.A.
the Federation was making Dragon Juicers beyond Kingsdale''s borders.

There are rumours of an ancient dragon who has made himself a small army of
bodyguards and feeds them from his own veins.

## GM Notes

**Demographics.** Dragon Juicers are 1% of all Juicers in North America.

**The six-month clock is the campaign.** Every other Juicer''s deadline is
measured in years and cannot be moved. This one is measured in months and can be
moved - by finding a dragon, and paying it, or killing it. The book closes that
door as fast as it opens it: hunt ancient dragons openly and ancient dragons
notice.

**Read the insanity table as four different characters.** A Dragon Juicer who
rolls 01-30 spends the campaign afraid of the thing he needs. One who rolls 91-00
has solved his addiction and lost his mind doing it, and is the most stable
Dragon Juicer at the table by the numbers.

**He carries 2D4x10 P.P.E. and cannot spend a point of it.** Which makes him
worth a great deal to anyone who can.
',
       updated_at = datetime('now')
 WHERE class_id = 'dragon-juicer'
   AND instr(markdown, 'which has no gear row yet."') > 0
   AND length(markdown) = 10792;

-- == necromancer ==
UPDATE imported_classes
   SET markdown = '---
id: necromancer
name: Necromancer
system: rifts
source_book: Rifts World Book 4: Africa p.99-104
category: occ
tags: []
occ_group: magic
men_of_arms: false
xp_table: [0, 2201, 4401, 8801, 17601, 27701, 37801, 53901, 75101, 100201, 140301, 200401, 250501, 300601, 350921]
attribute_requirements: { IQ: 10, ME: 10, PE: 12 }
ppe_base: "2d4x10 plus the P.E. attribute number, and 2d6 more per additional level of experience"
starting_money: "2d6x1000"
skills:
  hand_to_hand: { costs: { basic: 1, expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Language: Euro", bonus: 20, note: "Speaks and is literate in Euro (+20%)" }
    - { name: "Literacy: Euro", bonus: 20, note: "Speaks and is literate in Euro (+20%)" }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "One additional language spoken and read, plus one more language spoken only (+20% each)" }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literacy in the first of the two additional languages (+20%)" }
    - { name: "Lore: Demons & Monsters", bonus: 20, note: "The book prints ''Lore: Monsters & Demons (+20%)''; the catalog row is Lore: Demons & Monsters." }
    - { name: "Mathematics: Basic", bonus: 20, note: "The book prints ''Basic Math (+20%)''." }
    - { name: "Wilderness Survival", bonus: 5, note: "Wilderness Survival (+5%)" }
    - { name: "Skin & Prepare Animal Hides", bonus: 5, note: "The book prints ''Skin and Prepare Animal Hides & Bones (+5%)''; the catalog row is Skin & Prepare Animal Hides." }
    - { choose: 1, from: ["Hover Craft (ground)", "Horsemanship: General"], bonus: 10, note: "Pilot Hover Craft or Horsemanship (+10%)" }
    - { choose: 1, from: ["W.P. Knife", "W.P. Sword"], note: "W.P. Knife or Sword" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Energy Weapon of choice" }
  occ_related_skills:
    count: 7
    categories:
      - { name: "Communications", note: "+5%" }
      - { name: "Domestic", note: "+5%" }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], note: "Disguise, forgery and intelligence only." }
      - { name: "Medical", only: ["First Aid"], note: "First Aid only (+5%)" }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Wrestling"] }
      - { name: "Pilot", note: "+2%" }
      - { name: "Pilot Related", note: "+2%" }
      - { name: "Rogue", note: "+5%" }
      - "Science"
      - { name: "Technical", note: "+10% on lore, literacy, language or writing" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 6
    schedule: []
magic:
  type: "spell"
  spells_starting: 12
  spells_starting_groups:
    - { count: 6, from_list: "necromancy", note: "Six necromancy spells, regardless of level." }
    - { count: 6, from_list: "necro_common", note: "Six common spells associated with necromancy, from the book''s Available Common Spell Magic list (levels 1-15). The book states no level cap on these picks." }
  spell_lists:
    necromancy:
      - "Necromancy: Stench of the Dead"
      - "Necromancy: Object Read the Dead"
      - "Necromancy: Recognize the Undead"
      - "Necromancy: Command Ghouls"
      - "Necromancy: Kill Plants"
      - "Necromancy: Consuming Power & Knowledge"
      - "Necromancy: Death Mask"
      - "Necromancy: Divining: Tombs & Graves"
      - "Necromancy: Maggots"
      - "Necromancy: Death Strike"
      - "Necromancy: Shadows of Death"
      - "Necromancy: Shadows of Doom"
      - "Necromancy: Strength of the Dead"
      - "Necromancy: Summon Insect Swarm"
      - "Necromancy: Summon Vampires"
      - "Necromancy: Transfer Life Force"
      - "Necromancy: Summon Worms of Taut"
      - "Necromancy: Summon Magot"
    necro_common:
      - "Death Trance"
      - "Globe of Daylight"
      - "Sense Evil"
      - "Sense Magic"
      - "Concealment"
      - "Detect Concealment"
      - "Fear"
      - "Turn Dead"
      - "Breathe Without Air"
      - "Fuel Flame"
      - "Ignite Fire"
      - "Ley Line Transmission"
      - "Magic Net"
      - "Repel Animals"
      - "Shadow Meld"
      - "Trance"
      - "Circle of Flame"
      - "Horrific Illusion"
      - "Fire Ball"
      - "Mask of Deceit"
      - "Tongues"
      - "Animate and Control Dead"
      - "Constrain Being"
      - "Life Drain"
      - "Commune with Spirits"
      - "Exorcism"
      - "Luck Curse"
      - "Minor Curse"
      - "Sickness"
      - "Spoil"
      - "Protection Circle: Simple"
      - "Banishment"
      - "Control & Enslave Entity"
      - "Create Mummy"
      - "Create Zombie"
      - "Sanctum"
      - "Restoration"
      - "Transformation"
bonuses:
  attributes: { ME: 1, PE: 1, PS: 1, Spd: 4 }
  pools: { sdc: 10 }
  saves: { horror_factor: 6, spell_magic: 1, ritual_magic: 1 }
equipment_starting:
  - { item_id: "robe", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "disposable-surgical-gloves", qty: 100 }
  - { item_id: "clothing", qty: 2 }
  - { item_id: "boots", qty: 1 }
  - { item_id: "large-sack", qty: "2d4" }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-ammo-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }
  - { item_id: "infrared-distancing-binoculars", qty: 1 }
  - { item_id: "shovel", qty: 2 }
  - { item_id: "hand-axe", qty: 1 }
  - { item_id: "wilk-s-laser-scalpel", qty: 1 }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "short-sword", qty: 1 }
  - { item_id: "wooden-stake", qty: "2d4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "hand-held-flares", qty: 12 }
  - { choose: 1, label: "energy pistol", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol"] }
  - { item_id: "e-clip", qty: "1d6" }
special_abilities:
  - name: "Union with the Dead"
    description: "By tying an animal''s claw, hoof or tentacle (skeletal, or freshly slain and severed) to his own hand, forearm or foot and speaking an incantation known only to this O.C.C., the necromancer transforms that limb into the creature''s appendage, gaining its combat bonuses and abilities. P.P.E. cost varies by type (see the options below); self only by touch, and from 5th level he can do it to others at half duration. Duration 10 minutes per level; ends early if he is killed or knocked out, or at will. Takes one full melee round (15 seconds). Works only on the living. The limb is always proportional to the mage; any combination of limbs may be transformed. The options are the fifteen abilities that follow, each with its own P.P.E. cost (printed 100-101)."
  - name: "Union: Tentacle (10 P.P.E.)"
    description: "10 P.P.E.. Covers octopus, squid and a variety of monsters. +1 to strike, +20% to climb using suction cups, +3 to damage, and can pin or entangle an opponent. (Printed 100.)"
  - name: "Union: Rodent''s Claws/Feet (10 P.P.E.)"
    description: "10 P.P.E.. Covers rats, mice, squirrels, rabbits and similar small animals. +1 to strike and parry, +2 to damage (S.D.C.), +10% to climb. The claws have an opposable thumb and fingers, so tools and weapons can be used, roughly equal to human hands. (Printed 100.)"
  - name: "Union: Cat and Other Feline Claws (20 P.P.E.)"
    description: "20 P.P.E.. +2 to strike and parry, +8 to damage (S.D.C.), +20% to climb and +10% to prowl. The claws retract but have no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Canine Claws (10 P.P.E.)"
    description: "10 P.P.E.. +1 to parry and +4 to damage (S.D.C.). No opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bear, Badger, Wolverine and Similar Large Claws (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and +1 to parry, +10 to damage (S.D.C.), and +5% to climb. Excellent for digging, but no opposable thumb, so weapons and tools cannot be grasped or used. (Printed 101.)"
  - name: "Union: Bird Claws/Talons (15 P.P.E.)"
    description: "15 P.P.E.. +1 to strike and parry, +8 to damage (S.D.C.). The claws can grasp tools and use weapons at -1 to strike or parry; using modern or complicated devices carries a skill penalty of -20%. (Printed 101.)"
  - name: "Union: Dragon Claws (50 P.P.E.)"
    description: "50 P.P.E.. Dragon claws of any kind: +1 to strike, +1 to parry, inflict 4D6 M.D., make the necromancer impervious to fire, and give a physical M.D.C. of 12 from hatchlings and 30 from adult dragons. (Printed 101.)"
  - name: "Union: Claws of Other Creatures of Magic and Supernatural Monsters (35 P.P.E.)"
    description: "35 P.P.E.. Claws of other creatures of magic and supernatural monsters, including manticore, sphinx, za, sowki, mindolar, ghouls, gargoyles and other so-called demons and others: inflict 2D6 M.D. and give the necromancer 8 M.D.C.; no strike or parry bonuses. (Printed 101.)"
  - name: "Union: Claws of a Non-Supernatural Mega-Damage Creature (20 P.P.E.)"
    description: "20 P.P.E.. Claws of a non-supernatural mega-damage creature such as the melech, peryton and loogaroo: inflict 1D6 mega-damage points; no M.D.C. or bonuses. (Printed 101.)"
  - name: "Union: Hooves (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option. Hooves of any kind (horse, ox, cow, deer, etc.) add +20 to the speed attribute and allow a leap of 10 feet (3 m) high or lengthwise. (Printed 101.)"
  - name: "Union: Rhinoceros or Elephant Feet (20 P.P.E.)"
    description: "20 P.P.E.. Feet/legs option. +10 to the normal speed attribute, but can also run for a short period of 30 seconds (two melee rounds) at +40. A kick or stomp inflicts 4D6 S.D.C. damage. (Printed 101.)"
  - name: "Union: Kilin Hooves (25 P.P.E.)"
    description: "25 P.P.E.. Feet/legs option. +30 to the speed attribute, can leap 10 feet (3 m) high or lengthwise, and kick attacks inflict 1D6 M.D. (Printed 101.)"
  - name: "Union: Unicorn Hooves (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +40 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 2D6 M.D. (Printed 101.)"
  - name: "Union: Dragon Feet/Claws (30 P.P.E.)"
    description: "30 P.P.E.. Feet/legs option. +20 to the speed attribute, can leap 20 feet (6 m) high or lengthwise, and kick attacks inflict 4D6 M.D. (Printed 101.)"
  - name: "Union: Monkey, Ape or Humanoid Hands (15 P.P.E.)"
    description: "15 P.P.E.. Feet/legs option: hands in place of feet. +20% to climb, +5% to acrobatics, and the feet are equivalent to hands and can grasp and use weapons, tools and devices. The character''s normal speed is reduced by half. (Printed 101.)"
  - name: "Augmentation and Additional Appendages"
    description: "The necromancer can temporarily strap limbs of dead creatures, people and animals to his body and animate them as his own: up to three additional pairs of arms and two additional pairs of legs, or wings, a tail and horns in any combination, to a total of six additional appendages (a tail or a single horn counts as one, a pair of wings as two, one giant limb as two normal ones). The sight adds +2 to his Horror Factor. P.P.E. cost varies (options below); self only by touch, and from 8th level he can do it to others at half duration. Duration five minutes per level; ends early if he is killed or knocked out, or at will. Takes one full melee round. The added dead limbs keep their dead appearance and cannot themselves be transformed by Union with the Dead, though his own limbs can. The options are the eleven abilities that follow, each with its own P.P.E. cost (printed 101-102)."
  - name: "Augmentation: Additional Arms or Tentacles (10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs)"
    description: "10 P.P.E. per pair, 5 for one, 20 for M.D.C. limbs. Each additional pair of arms or tentacles adds one physical attack or action per melee round and a bonus of +1 to strike and parry. Three additional pairs can be added, for a possible total of eight arms (two natural and six skeleton limbs); limbs can be human, D-bee, ape or animal, and one giant limb counts as two normal sized limbs. Limbs of a mega-damage creature carry that creature''s strength and inflict its usual mega-damage. (Printed 101.)"
  - name: "Augmentation: Horn(s) (4 P.P.E. each)"
    description: "4 P.P.E. each. Horns are a weapon for head-butting and ramming. A single horn inflicts 1D4 S.D.C. and a pair does 2D4 damage; both add six points to the character''s physical S.D.C. (Printed 102.)"
  - name: "Augmentation: Rhinoceros Horn (8 P.P.E.)"
    description: "8 P.P.E.. The horn inflicts 3D6 S.D.C. and gives keen hearing (+1 on initiative) and a keen sense of smell (55% to track by smell), plus an extra 20 S.D.C. to the wearer. (Printed 102.)"
  - name: "Augmentation: Unicorn Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D6 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), keen color vision, prowl 50%, +1 on initiative, and never tiring. (Printed 102.)"
  - name: "Augmentation: Kilin Horn (10 P.P.E.)"
    description: "10 P.P.E.. The horn inflicts 1D4 M.D. and gives the abilities to see the invisible, nightvision 90 ft (27.4 m), healing touch (four times, restoring 1D8 HP and 2D8 S.D.C.), and sense evil as an automatic sensation. (Printed 102.)"
  - name: "Augmentation: Dragon Horn (30 P.P.E.)"
    description: "30 P.P.E.. One horn inflicts 2D4 M.D. and gives 25 M.D.C. to the character wearing it. Two or more horns do 2D6 M.D. and each additional horn adds another 10 M.D.C. points. (Printed 102.)"
  - name: "Augmentation: Dragon Tail (20 P.P.E.)"
    description: "20 P.P.E.. Provides one additional attack per melee and inflicts 2D6 M.D. per strike. (Printed 102.)"
  - name: "Augmentation: Dragon Skull (50 P.P.E.)"
    description: "50 P.P.E.. Often worn as a helmet or ceremonial headdress called the dragon helm. Gives 20 M.D.C., understanding and speech of all languages, reading and writing dragonese/elf, imperviousness to fire, resistance to cold, and whatever breath weapon (if any) the dragon had (fire, cold, acid, etc.). The mage can also cast any spell the dragon once knew, as a 5th level spell caster. (Printed 102.)"
  - name: "Augmentation: Skull of a Powerful Supernatural Monster (120 P.P.E.)"
    description: "120 P.P.E.. Skull of a god, godling, greater demon/being or demon lord (elementals, vampires, alien intelligences and energy beings do not qualify). Gives 40 M.D.C., the ability to speak that creature''s language, and all its magic powers and spell knowledge, only while the skull is activated, at half the level of ability it had alive: 10th level in life gives fifth level power, sixth gives third. (Printed 102.)"
  - name: "Augmentation: Wings of a Bird or Bat (30 P.P.E.)"
    description: "30 P.P.E.. Wings are strapped to the mage''s back and may be undersized or over-sized; when the magic engages they grow or shrink to fit the user. Flying speed is limited to 20 mph (32 km) for most songbirds and bats, game and large birds, and 35 mph (56 km) from the wings of birds of prey. Large monstrous wings (pegasus, peryton, harpy, gargoyle, gryphon, gromek, loogaroo, waternix and similar) give 45 mph (72 km). (Printed 102.)"
  - name: "Augmentation: Wings of a Dragon or Powerful Supernatural Creature (90 P.P.E.)"
    description: "90 P.P.E.. Flight at a speed of 60 mph (96 km) and a bonus of 10 M.D.C. to the flyer; the wings themselves have 2D4x10 M.D.C. (Printed 102.)"
  - name: "Animate and Control the Dead"
    description: "Like the common spell but considerably more powerful. 10 P.P.E. Range 300 ft (91.5 m) plus 20 ft (6 m) per level; duration 10 minutes per level. Controls four corpses or skeletons (humanoid, animal or monster) per level of experience; each must be in line of sight to animate, and more can be added as they are found. They can be sent out of sight on simple missions such as ''destroy'' or ''kill'' and follow the command until destroyed or the duration ends. Each has Spd 7, two attacks per melee, 1D6 S.D.C. damage from punches, kicks, claws and bites, and can use only the simplest mega-damage weapons (flaming sword, vibro-blade), never guns; giant ones have double speed and damage and one more attack. They feel no pain, fear or emotion. Only total destruction stops them, or slaying or knocking out their creator. S.D.C.: small 50, human-sized 80, giant 140. Bullets and stabbing weapons do 1/3 damage, blunt and smashing attacks full damage, fire double damage. (Printed 102.)"
  - name: "Impervious to Vampires"
    description: "Impervious to a vampire''s mind-controlling bite and cannot be turned into a vampire, though vampires can still slay him. Knows all the legends about vampires and other undead and how to combat them. (Printed 102.)"
  - name: "Horror Factor"
    description: "The necromancer is frightening. Horror Factor 6 at first level, +1 at levels 3, 5, 7, 9, 11, 13 and 15 (and +2 more while Augmentation appendages are attached). A Horror Factor the character PROJECTS is not a save the character makes, so it is recorded here; the +6 to save vs Horror Factor in bonuses is a separate thing."
  - name: "Learning New Spells"
    description: "Additional spells and rituals related to necromancy (see the necromancy and common lists) can be learned or purchased at any time, regardless of the character''s experience level. See The Pursuit of Magic, Rifts Ultimate Edition page 190."
  - name: "Common Spells Cost Double"
    description: "The necromancer can learn any spell, but any common spell NOT on the book''s Available Common Spell Magic list (printed 108) costs him twice its normal P.P.E. to cast - Armor of Ithan costs 20 rather than 10, Befuddle 6 rather than 3. The spells on that list, which are the necro_common list of this class, are cast at their normal cost. Other spell casters (a line walker, a shifter) can learn necromancy spells but pay double to cast them; techno-wizards and mystics never learn necro-magic."
  - name: "Insanity"
    description: "The necromancer often becomes deranged with the passage of time: one roll on the Necromancer Insanity Table at each of levels 4, 8, 10, 12 and 15. The table is the Insanity pick group that follows, one banked roll or pick per listed level. The book also lets a player who wants the character crazy simply pick one or two results. (Printed 104.)"
  - { choose: 1, at_levels: [4, 8, 10, 12, 15], from: ["Insanity (01-30): No Insanity", "Insanity (31-40): Obsession - Torture and Killing", "Insanity (41-45): Obsession - Hates the Light of Day", "Insanity (46-50): Obsession - Danger", "Insanity (51-55): Phobia - Gods of Light", "Insanity (56-60): Obsession - Hates Good Druids", "Insanity (61-65): Obsession - Dead Things", "Insanity (66-70): Phobia - Ancient Dragons", "Insanity (71-75): Phobia - High Level Shamans and Priests of Light", "Insanity (76-80): Phobia - Spirits of Light", "Insanity (81-85): Random Affective Disorder", "Insanity (86-90): Random Phobia", "Insanity (91-95): Random Obsession", "Insanity (96-00): Random Insanity"], note: "Necromancer Insanity Table (printed 104): roll once, or pick, at each of levels 4, 8, 10, 12 and 15. Rows 81-00 send the player to another table." }
  - name: "Insanity (01-30): No Insanity"
    description: "Roll 01-30 or choose. No insanity this time; the necromancer''s mind holds. (Printed 104.)"
  - name: "Insanity (31-40): Obsession - Torture and Killing"
    description: "Roll 31-40 or choose. Obsession: he likes to torture, hurt and kill others. (Printed 104.)"
  - name: "Insanity (41-45): Obsession - Hates the Light of Day"
    description: "Roll 41-45 or choose. Obsession: he hates the light of day and tries to avoid it. (Printed 104.)"
  - name: "Insanity (46-50): Obsession - Danger"
    description: "Roll 46-50 or choose. Obsession: he loves danger and takes needless risks. (Printed 104.)"
  - name: "Insanity (51-55): Phobia - Gods of Light"
    description: "Roll 51-55 or choose. Phobia: Gods of Light. (Printed 104.)"
  - name: "Insanity (56-60): Obsession - Hates Good Druids"
    description: "Roll 56-60 or choose. Obsession: he hates good druids, especially Millennium druids. (Printed 104.)"
  - name: "Insanity (61-65): Obsession - Dead Things"
    description: "Roll 61-65 or choose. Obsession: he loves dead things and surrounds himself with skeletons, mummies, zombies and the like. (Printed 104.)"
  - name: "Insanity (66-70): Phobia - Ancient Dragons"
    description: "Roll 66-70 or choose. Phobia: ancient dragons. (Printed 104.)"
  - name: "Insanity (71-75): Phobia - High Level Shamans and Priests of Light"
    description: "Roll 71-75 or choose. Phobia: high level shamans and priests of light. (Printed 104.)"
  - name: "Insanity (76-80): Phobia - Spirits of Light"
    description: "Roll 76-80 or choose. Phobia: spirits of light/angels. (Printed 104.)"
  - name: "Insanity (81-85): Random Affective Disorder"
    description: "Roll 81-85 or choose. The row sends the player to roll for a random affective disorder; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (86-90): Random Phobia"
    description: "Roll 86-90 or choose. The row sends the player to roll for a random phobia; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (91-95): Random Obsession"
    description: "Roll 91-95 or choose. The row sends the player to roll for a random obsession; that second roll is made by hand and its result is not stored here. (Printed 104.)"
  - name: "Insanity (96-00): Random Insanity"
    description: "Roll 96-00 or choose. The row sends the player to roll for a random insanity; that second roll is made by hand and its result is not stored here. (Printed 104.)"
restrictions:
  - "Optional O.C.C.: the book calls the necromancer a better NPC villain than player character and leaves its use as a player character to the Game Master''s discretion."
  - "Selfish or evil alignment only (unprincipled, anarchist, or any evil); a good necromancer is not possible. Most are anarchist or evil. Attribute requirements are I.Q. 10, M.E. 10 and P.E. 12 or higher."
  - "Race: any that may master death magic - humans, D-Bees, ogres and many monster races. Faerie folk, spirits of light, elementals and kilin are never necromancers, and dragons generally avoid it."
  - "Cybernetics: starts with none and avoids them because they interfere with magic. Only cybernetic bio-systems for health reasons will be considered."
  - "Vehicle is limited to NON-MILITARY transportation - a hover vehicle, a motorcycle or a riding animal."
  - "Hand to Hand is NOT free: Basic costs one O.C.C. Related Skill, Expert two, and Martial Arts or Assassin (if evil) three."
  - "The character also starts with 3D6x1000 credits'' worth of sellable black-market items, over and above the coin in starting_money. That field is coin only, so the goods are recorded here."
  - "Secondary skills are chosen from the O.C.C. Related list EXCLUDING the categories marked None - Electrical, Mechanical and Military - and take no category bonus."
  - "Starting gear the catalog has no row for: a box of 50 large zip-lock plastic bags, a large satchel or suitcase, a wooden knife, and one or two other weapons of choice. The sacrificial short sword is usually ornate and plated in a precious metal; the necromancer prefers magic weapons and devices over technological ones."
extraction_notes: "Rifts World Book 4: Africa pp.99-104, with the necromancy spell list and the Available Common Spell Magic rule on printed 108 and the ladder on printed 160. This is the original Necromancer; necromancer-russian (Mystic Russia) is a separate later class and its Bone Magic is not part of this one. XP: the Necromancer & Phoenixi column, stored as lower bounds; level 15 is printed as 350,921-425,800 although level 14 ends at 350,700, so 350,921 is stored as printed rather than 350,701 - a book anomaly. men_of_arms is false: the class sits in the book''s magic section beside the African Witch and Priest and prints no S.D.C. formula of its own, only the +10 S.D.C. bonus. STARTING SPELLS: the six necromancy picks come from a named list of the 18 Necromancy rows (the book says regardless of level, and a named list replaces the level gate). The six common picks come from a named list of the book''s Available Common Spell Magic list, the spells the book treats as associated with necromancy and casts at normal cost; no level cap is applied to that group because the book states none (necromancer-russian capped its common six at 1-5; a spell_levels key beside a named list in a starting group is not applied by startingGroups in js/leveling.js, so a cap would need a second list). The book''s list names Animate & Control Dead, Control/Enslave Entity and Protection: Simple; the catalog rows are Animate and Control Dead, Control & Enslave Entity and Protection Circle: Simple. The double P.P.E. cost of every other common spell has no key and is prose in special_abilities. Union with the Dead and Augmentation each keep one special ability for the general rule, and since ~118 every option of their tables is its own special ability named with its P.P.E. cost (fifteen unions, eleven augmentations), by the ruling of 2026-10-04 that they are class abilities and not spell rows. The 35 and 20 P.P.E. claws are paragraphs of the dragon claws entry on the page and are separate abilities here because each prints its own cost; Additional Arms or Tentacles is one ability with its three printed costs. None of their bonuses go in bonuses because each applies only while a limb is attached. The projected Horror Factor is prose; the +1 save vs magic of all kinds is carried as spell_magic and ritual_magic. Two additional languages: the book''s first additional language is spoken and literate, so the class takes two Language: Other picks and one Literacy: Other pick. Skill names needing the catalog''s spelling: Lore: Monsters & Demons is Lore: Demons & Monsters; Basic Math is Mathematics: Basic; Skin and Prepare Animal Hides & Bones is Skin & Prepare Animal Hides; Pilot Hover Craft is Hover Craft (ground). Gear judgement calls: leather gloves are gloves, the robe-or-cloak is robe, the two hand shovels are shovel, the palm size mirror is pocket-mirror, the sacrificial short sword is short-sword, the dozen flares are hand-held-flares, and a week''s food rations are one food-rations entry. The text layer prints the human-sized animated corpse S.D.C. as SO; the rendered page reads 80. 2026-10-05: the Necromancer Insanity Table (printed 104, read off the rendered page) is a pick-one group at levels 4, 8, 10, 12 and 15, the levels the page prints (four, eight, ten, twelve and fifteen), by BOOK-INGEST-AUDIT.md F116. Its fourteen rows are band-named options, 01-30 through 96-00, covering 01-00 with no gap or overlap as printed, each its own special ability. No row prints a number, so none carries bonuses. The four rows that send the player to another table (81-85 random affective disorder, 86-90 random phobia, 91-95 random obsession, 96-00 random insanity) stay as that row''s prose. The Insanity ability is kept as a pointer and holds the book''s allowance to pick one or two results outright."
---

# Necromancer

## Lore

The necromancer practises the magic of death, the dead and the monstrous. It is
an obscure art in most of the world, but by far most common in Africa and
southern Europe, spread by the influence of Egypt and its insane Pharaoh
Rama-Set, the Gods of Darkness, many death cults and the monster races and evil
supernatural beings that dominate those lands.

The heart of the necromancer''s power is the ability to animate, control and draw
power from the remains of the dead. So these mages carry bones, claws, hooves,
wings and preserved limbs in satchels, trunks and sacks, and keep the rarest -
a dragon''s claw - on their person at all times. Some travel with an entourage of
skeletons and zombies, a common sight in the Phoenix Empire, and a necromancer''s
lair is guarded by the animated dead.

Much of the magic calls for enslavement, torture, blood sacrifice and murder as
a source of P.P.E.; to the evil necromancer, death is simply a resource.

## Alignment

Selfish or evil only. An unprincipled or anarchist necromancer shows restraint:
avoids torture and wanton killing, prefers scavenging and grave-robbing to blood
sacrifice, and shuns pacts with supernatural beings and dealings with other
necromancers - which limits both P.P.E. and the spells he will use. An aberrant
one keeps his own code and kills quickly and with discretion. The rest suffer no
such scruples.

## GM Notes

The book presents the necromancer as a better NPC villain than player character
and leaves it to the Game Master whether one may be played. Roughly a quarter of
known necromancers are human; ogres and other monster races make up over half.
The five special powers - Union with the Dead, Augmentation, Animate and Control
the Dead, immunity to vampires and a Horror Factor - come in addition to the
starting spells.
',
       updated_at = datetime('now')
 WHERE class_id = 'necromancer'
   AND instr(markdown, 'The Insanity Table (printed 104) is prose in special_abilities.') > 0
   AND length(markdown) = 25907;

-- == african-witch ==
UPDATE imported_classes
   SET markdown = '---
id: african-witch
name: African Witch
system: rifts
source_book: Rifts World Book 4: Africa p.72-78
category: occ
tags: [shapeshifter, evil]
occ_group: magic
men_of_arms: false
xp_table: [0, 1951, 3901, 7801, 15601, 30201, 45401, 60601, 85801, 110201, 150401, 210601, 265801, 325201, 375401]
attribute_requirements: { IQ: 10, ME: 10, PE: 12 }
ppe_base: "P.E. x3, plus 2d6 per level of experience"
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: { basic: 1, expert: 1, martial_arts: 2, assassin: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", bonus: 20, note: "Speaks and is literate in native tongue (+20%)." }
    - { name: "Literacy: Native Language", bonus: 20, note: "Speaks and is literate in native tongue (+20%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "One language of choice with literacy, plus one additional language (+20%). Taken once per language - the picker asks which." }
    - { choose: 1, from: ["Literacy: Other"], bonus: 20, note: "Literate in the language of choice above (+20%)." }
    - { name: "Lore: Demons & Monsters", bonus: 10, note: "The book prints ''Lore: Monsters & Demons (+10%)''; the catalog row is Lore: Demons & Monsters." }
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored." }
    - { name: "Wilderness Survival", bonus: 5, note: "Wilderness Survival (+5%)" }
    - { name: "Carpentry", bonus: 10, note: "Carpentry (+10%)" }
    - { name: "Skin & Prepare Animal Hides", bonus: 10, note: "The book prints ''Skin and Prepare Animal Hides (+10%)''." }
    - { name: "W.P. Knife", base: 0, per_level: 0 }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. of choice." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", only: ["Disguise", "Forgery", "Intelligence"], bonus: 5, note: "Disguise, forgery and intelligence only (+5%)." }
      - { name: "Medical", only: ["First Aid", "Holistic Medicine"], bonus: 5, note: "First aid or holistic medicine only (+5%)." }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing"] }
      - { name: "Pilot", note: "Any; horsemanship +5%." }
      - "Pilot Related"
      - { name: "Rogue", bonus: 5 }
      - "Science"
      - { name: "Technical", note: "+10% on lore, literacy, language or writing skills only." }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Electrical, Mechanical and Military: none. All new skills start at level one proficiency. Hand to Hand is not free: Basic costs one of these picks, Expert one, Martial Arts or Assassin two."
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 3, count: 4 }, { level: 9, count: 4 }]
    note: "From the related list, excluding the categories marked None, without the bonuses in parentheses; all start at the base skill level."
equipment_starting:
  - { item_id: "clothing", qty: 1 }
  - { item_id: "small-sack", qty: "1d4" }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { choose: 1, label: "sunglasses or tinted goggles", qty: 1, from: ["sunglasses", "tinted-goggles"] }
  - { choose: 1, label: "air filter or gas mask", qty: 1, from: ["air-filter", "gas-mask"] }
  - { item_id: "food-rations", qty: 1, note: "One week''s rations." }
  - { item_id: "knife-silver-plated", qty: 1 }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { choose: 1, label: "war club or staff", qty: 1, from: ["war-club", "quarterstaff"] }
  - { item_id: "african-throwing-knives", qty: "1d6" }
  - { choose: 1, label: "energy pistol or rifle", qty: 1, from: ["ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle"], note: "The book says an energy pistol or rifle without naming one; this is the catalog''s common set." }
magic:
  type: "spell"
  spells_starting: 3
  spells_starting_groups:
    - { count: 1, from_list: "bad", note: "One witch spell (Bad Medicine) at level one." }
    - { count: 2, from: ["Death Trance", "Globe of Daylight", "See Aura", "Sense Magic", "Thunderclap"], note: "Two common spells, level one spells only, from the witch''s Available Common Spell Magic list. She casts them at DOUBLE the listed P.P.E." }
  spell_lists:
    bad:
      - "Bad Medicine: Charge Object with Evil"
      - "Bad Medicine: Delirium"
      - "Bad Medicine: Evil Eye"
      - "Bad Medicine: Magic Drums"
      - "Bad Medicine: Money Doubling"
      - "Bad Medicine: Pestilence Touch"
      - "Bad Medicine: Poison Touch"
      - "Bad Medicine: Summon & Control Biting Insect Swarm"
      - "Bad Medicine: Summon & Control Locust Swarm"
      - "Bad Medicine: Summon & Control Drought"
      - "Bad Medicine: Summon & Control Heat Wave"
      - "Bad Medicine: Taboo"
    common:
      - "Death Trance"
      - "Globe of Daylight"
      - "See Aura"
      - "Sense Magic"
      - "Thunderclap"
      - "Befuddle"
      - "Concealment"
      - "Detect Concealment"
      - "Fear"
      - "Turn Dead"
      - "Armor of Ithan"
      - "Breathe Without Air"
      - "Fingers of the Wind"
      - "Fuel Flame"
      - "Ignite Fire"
      - "Negate Poison/Toxin"
      - "Ley Line Transmission"
      - "Fool''s Gold"
      - "Repel Animals"
      - "Trance"
      - "Calling"
      - "Circle of Flame"
      - "Escape"
      - "Fly"
      - "Horrific Illusion"
      - "Compulsion"
      - "Magic Pigeon"
      - "Tongues"
      - "Agony"
      - "Animate and Control Dead"
      - "Constrain Being"
      - "Invisibility (Superior)"
      - "Life Drain"
      - "Wind Rush"
      - "Commune with Spirits"
      - "Exorcism"
      - "Locate"
      - "Luck Curse"
      - "Minor Curse"
      - "Oracle"
      - "Sickness"
      - "Spoil"
      - "Curse: Phobia"
      - "Protection Circle: Simple"
      - "Summon and Control Canines"
      - "Banishment"
      - "Control & Enslave Entity"
      - "Summon Shadow Beast"
      - "Summon and Control Rodents"
      - "Summon and Control Animals"
      - "Summon Fog"
      - "Summon and Control Entity"
      - "Summon Lesser Being"
      - "Talisman"
  spells_schedule:
    - { level: 2, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 3, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 3, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 4, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 5, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 5, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 6, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 7, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 7, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 8, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 9, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 9, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 10, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 11, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 11, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 12, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 13, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list, no higher than her own level. Cast at double P.P.E." }
    - { level: 13, count: 1, from_list: "bad", note: "One new witch spell (Bad Medicine)." }
    - { level: 14, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list. Cast at double P.P.E." }
    - { level: 15, count: 2, from_list: "common", spell_levels: "up_to_character_level", note: "Two common spells per level, from her list. Cast at double P.P.E." }
bonuses:
  attributes: { ME: 1, PE: 2, PS: 2 }
  pools: { sdc: 25 }
  saves: { spell_magic: 1, ritual_magic: 1, horror_factor: 4 }
special_abilities:
  - name: "Creature of the night"
    description: "Nightvision 200 feet (61 m), and she can see the invisible. Witches shun daylight and are most active at night. A natural ability; no P.P.E. is spent."
  - name: "Lycanthropy"
    description: "At night only, she can turn into a large snake, dog, panther, ram or goat. In animal form she keeps her mental attributes, hit points and powers, and can still speak and cast magic; she gains +10 to Spd and a base 50% Prowl, and her S.D.C. becomes M.D.C. (only at night and only in animal form). Conditional, so it is prose rather than a bonus line."
  - name: "Create magic snakes"
    description: "She can create up to seven magic snakes whose only purpose is to kill a chosen victim (or that person''s animals). Each drains her of 10 hit points or S.D.C. while it exists, and she cannot go below 10 hit points; the points return when the snake is killed or comes back. Each snake is about 3 feet (0.9 m) long: 10 hit points, two attacks per melee, +1 initiative, +4 to strike, parry and dodge, Prowl 63%, Spd 44 (30 mph/48 km). Its bite is magic venom: save 15 or higher (13 for M.D.C. creatures) or take 6D6 damage, S.D.C./hit points or M.D. by the victim''s nature, and -1 initiative and -1 Spd per bite for 2D4 minutes. The bite leaves no mark or trace of poison, so deaths look natural; only a true Medicine Man can see the bites."
  - name: "Spit kills snakes"
    description: "Her ordinary spit kills a snake instantly by splitting it open. She is impervious to all snake venom, but not to other poisons and drugs."
  - name: "Eat away at the life of her enemies"
    description: "Nocturnal, in human or animal form. While the victim sleeps she breathes in 4D6 S.D.C./hit points of life essence once per night (no effect on mega-damage creatures) and adds the stolen S.D.C. to her own; each visit also lowers the victim''s combat and saving throw bonuses by one. The loss does not heal, even by magic, and the victim tires twice as fast and looks pale and sickly. At 30% of normal hit points the victim is in her power: she senses his location within 500 miles (804 km), can mentally call him, and he cannot raise a hand against her. No saving throw, except a Medicine Man''s charm or protection magic keeping her away. The victim is saved by being taken far away (losing what was taken for good), by persuading her to return it, or by slaying her."
  - name: "Double-cost common magic"
    description: "Her common (non-Bad Medicine) spells cost TWICE the normal P.P.E. - Armor of Ithan, normally 10, costs her 20. The app stores catalog costs, so the doubling is recorded here."
  - name: "Extra P.P.E."
    description: "She can draw additional P.P.E. from ritual magic and blood sacrifices, the same as most practitioners of magic."
  - name: "Insanity"
    description: "The witch is often mentally unbalanced: one roll on the Witch Insanity Table (printed 74) at each of levels 3, 7, 9 and 13, or simply a pick at that time. The table is the Insanity pick group that follows, one banked roll or pick per listed level."
  - { choose: 1, at_levels: [3, 7, 9, 13], from: ["Insanity (01-20): No Insanity", "Insanity (21-25): Phobia - Medicine Men", "Insanity (26-30): Obsession - Tormenting Medicine Men", "Insanity (31-40): Obsession - Torture and Killing", "Insanity (41-45): Obsession - Wealth", "Insanity (46-50): Obsession - Danger", "Insanity (51-55): Phobia - Gods of Light", "Insanity (56-60): Obsession - Hates the Light of Day", "Insanity (61-65): Obsession - Dead Things", "Insanity (66-70): Phobia - Millennium Trees", "Insanity (71-75): Obsession - Hates Good Priests", "Insanity (76-80): Phobia - Spirits of Light", "Insanity (81-85): Phobia - Psychic Healing", "Insanity (86-90): Random Affective Disorder", "Insanity (91-95): Random Insanity", "Insanity (96-00): Psychosis"], note: "Witch Insanity Table (printed 74): roll once, or pick, at each of levels 3, 7, 9 and 13. Rows 86-00 send the player to another table." }
  - name: "Insanity (01-20): No Insanity"
    description: "Roll 01-20 or choose. No insanity this time. (Printed 74.)"
  - name: "Insanity (21-25): Phobia - Medicine Men"
    description: "Roll 21-25 or choose. Phobia: medicine men. (Printed 74.)"
  - name: "Insanity (26-30): Obsession - Tormenting Medicine Men"
    description: "Roll 26-30 or choose. Obsession: she likes to hurt and torture medicine men and to make them look foolish, incompetent or untrustworthy. (Printed 74.)"
  - name: "Insanity (31-40): Obsession - Torture and Killing"
    description: "Roll 31-40 or choose. Obsession: she likes to torture, hurt and kill others. (Printed 74.)"
  - name: "Insanity (41-45): Obsession - Wealth"
    description: "Roll 41-45 or choose. Obsession: she loves wealth and craves riches. (Printed 74.)"
  - name: "Insanity (46-50): Obsession - Danger"
    description: "Roll 46-50 or choose. Obsession: she loves danger and takes needless risks. (Printed 74.)"
  - name: "Insanity (51-55): Phobia - Gods of Light"
    description: "Roll 51-55 or choose. Phobia: Gods of Light. (Printed 74.)"
  - name: "Insanity (56-60): Obsession - Hates the Light of Day"
    description: "Roll 56-60 or choose. Obsession: she hates the light of day and tries to avoid it. (Printed 74.)"
  - name: "Insanity (61-65): Obsession - Dead Things"
    description: "Roll 61-65 or choose. Obsession: she loves dead things and surrounds herself with skeletons, mummies, zombies and the like. (Printed 74.)"
  - name: "Insanity (66-70): Phobia - Millennium Trees"
    description: "Roll 66-70 or choose. Phobia: Millennium Trees, which she avoids at all costs. (Printed 74.)"
  - name: "Insanity (71-75): Obsession - Hates Good Priests"
    description: "Roll 71-75 or choose. Obsession: she hates good priests of all kinds. (Printed 74.)"
  - name: "Insanity (76-80): Phobia - Spirits of Light"
    description: "Roll 76-80 or choose. Phobia: spirits of light/angels. (Printed 74.)"
  - name: "Insanity (81-85): Phobia - Psychic Healing"
    description: "Roll 81-85 or choose. Phobia: psychic healing. (Printed 74.)"
  - name: "Insanity (86-90): Random Affective Disorder"
    description: "Roll 86-90 or choose. The row sends the player to roll for a random affective disorder; that second roll is made by hand and its result is not stored here. (Printed 74.)"
  - name: "Insanity (91-95): Random Insanity"
    description: "Roll 91-95 or choose. The row sends the player to the random insanity table of the Rifts RPG; that second roll is made by hand and its result is not stored here. (Printed 74.)"
  - name: "Insanity (96-00): Psychosis"
    description: "Roll 96-00 or choose. The row sends the player to roll for a psychosis; that second roll is made by hand and its result is not stored here. (Printed 74.)"
trackable_resources: []
restrictions:
  - "The book presents this O.C.C. as a Non-Player Character villain and says it is ideal as an N.P.C. but NOT recommended as a player character. It is imported so a Game Master can build her; player use is at the Game Master''s discretion."
  - "Always evil. The African witch is an agent of evil by definition, and is feared, hunted and destroyed without mercy wherever witchcraft is recognized."
  - "Cybernetics: starts with none and avoids them because they interfere with magic. Only cybernetic bio-systems for health reasons will be considered."
  - "Vehicle is limited to non-military transportation: a hover vehicle, motorcycle or riding animal."
  - "The character also starts with 6D6x1000 credits'' worth of precious stones, gems, gold and other items, over and above the coin in starting_money. That field is coin only, so the valuables are recorded here."
  - "Bad Medicine spells are available only to the African Witch; they are a tradition of their own in the catalog. Her common spells are limited to the Available Common Spell Magic list."
extraction_notes: "Rifts World Book 4: Africa pp.72-74 (the class) and 78 (the alphabetical Bad Medicine list and the Available Common Spell Magic list); the Bad Medicine spell descriptions on 74-78 were imported separately as the african-witch tradition. The book heads her ''African Witch - Non-Player Character Villain'' and advises against player use; she is imported as an ordinary published class at the user''s decision, with the warning carried as a restriction and in GM Notes, the way add-night-witch-class.sql carries its N.P.C. villain line. men_of_arms is false: she sits under the book''s African Magic O.C.C. heading on printed 72, with the Medicine Man, Rain Maker and Priest. The book states no S.D.C. formula, only a +25 S.D.C. bonus, stored as a pool bonus. XP ladder read off the rendered printed 160, African Witch column; the book prints upper bounds and each is stored plus one. Spells: one witch spell at levels 1, 3, 5, 7, 9, 11 and 13; two common spells at level one (level one only) and two more each level, capped at her own level, all from the page-78 list. The level-one picks are starting groups and every later pick is a schedule entry drawing on a named list, because a flat spells_per_level cannot be bound to a list. Page-78 names mapped to catalog rows: ''Tum Dead'' (text layer) is Turn Dead; Fingers of Wind is Fingers of the Wind; Negate Poison is Negate Poison/Toxin; Animate & Control Dead is Animate and Control Dead; Invisibility: Superior is Invisibility (Superior); Summon & Control Canine is Summon and Control Canines; Control/Enslave Entity is Control & Enslave Entity; Summon & Control Rodents and Animals are the ''and'' spellings; Summon Entity (250, level 12) is Summon and Control Entity. Every one of the 54 sits at the catalog level the book lists it under. The book''s base costs differ from the catalog on four: Befuddle 3 (catalog 6), Ignite Fire 5 (catalog 6), Exorcism 25 (catalog 30), Summon Lesser Being 420 (catalog 425); not corrected here. The doubled P.P.E. cost of her common spells is prose. Hand to Hand is not granted: the book sells Basic or Expert for one related pick and Martial Arts or Assassin for two, carried as hand_to_hand costs. JUDGEMENT: the secondary skills line reads ''select four secondary skills at levels three and nine''; stored as four at EACH of levels 3 and 9 and none at level one, the reading used across this book''s O.C.C. drafts (the Agogwe entry on printed 118 states the same rule per level). The wooden knife, torture picks and pins and the beaded jewellery have no fitting catalog row; scalpels (a scalpel row exists) are unquantified; the book offers 1D6 throwing sticks OR throwing knives and only the knives are stored, because a choice cannot carry a rolled quantity. The 50% chance of one or two magic weapons is not stored. 2026-10-05: the Witch Insanity Table (printed 74, read off the rendered page) is a pick-one group at levels 3, 7, 9 and 13, the levels the page prints (three, seven, nine and thirteen), by BOOK-INGEST-AUDIT.md F116. Its sixteen rows are band-named options, 01-20 through 96-00, covering 01-00 with no gap or overlap as printed, each its own special ability. No row prints a number, so none carries bonuses. The three rows that send the player to another table (86-90 random affective disorder, 91-95 the Rifts RPG random insanity table, 96-00 psychosis) stay as that row''s prose. The Insanity ability is kept as a pointer to the group."
---

# African Witch

## Lore

In the tribal societies of Rifts Africa, the witch is the most despised and
feared creature there is. She creates "bad medicine" to hurt others, to take
revenge, to profit at others'' expense or to upset the harmony of nature, and she
keeps company with evil spirits - demons, devils and other evil forces. Calling
a medicine man or priest a "witch doctor" is the worst insult there is.

Most African witches (75%) are female. Her special powers are natural abilities
rather than spells: she is a creature of the night, a shapechanger, a maker of
killing snakes and an eater of life. Her spells are not studied the way a
wizard''s are - they are taught to her by a demon, or simply come to her as she
gains experience.

Where a witch rules a tribe, its people are either enslaved to her or are her
willing, evil minions; the rightful king, medicine man and priest are usually
dead or made ill. Medicine men and priests hunt witches wherever witchcraft is
recognized, and slay them without mercy.

## Alignment

Always evil.

## GM Notes

The book marks this O.C.C. as a Non-Player Character villain: ideal as an
N.P.C., and not recommended as a player character. She is available here so a
Game Master can build one.

Witches are extremely self-serving, manipulative and dangerous, have little
regard for the living, and seek wealth and power. They work alone or in groups
of 2D4. The book also counts evil practitioners of other magic - necromancers,
blood druids, shifters, stone masters, mind melters, mind bleeders - as
"witches" in the eyes of the tribes.
',
       updated_at = datetime('now')
 WHERE class_id = 'african-witch'
   AND instr(markdown, 'The Witch Insanity Table is summarized in special_abilities, not stored as data.') > 0
   AND length(markdown) = 18781;

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
extraction_notes: "WB30 D-Bees of North America printed 130-133 (cache p131-p134), read off 200 dpi renders. Lore starts on printed 130 under the heading Lyvorrk; the stat block is headed Lyvorrk - Optional Player Character and NPC (printed 130) and ends on printed 133 with a note that the race first appeared in World Book One: Vampire Kingdoms. Printed 131 is an art plate. || CATEGORY: a race whose R.C.C. is a full skill package, or which may instead take the Body Doc or any Magic O.C.C. || XP: the book says a Lyvorrk who pursues R.C.C. skills uses the Psi-Stalker table, and a mage uses the magic O.C.C.''s table. Not stored, per this import''s brief (no xp_table for this book); the Psi-Stalker ladder is the one to copy if that is revisited. || M.D.C.: 2D6 +P.E. attribute number, plus 2D4 M.D. per level, stored as mdc_base, so no men_of_arms line. P.P.E. 2D6+12, added to a mage''s P.P.E. base: stored as ppe_base, no yields_to_occupation. Horror Factor 12. || PSIONICS: I.S.P. printed M.E. attribute number x3, +10 I.S.P. per melee round; per melee round is read as a slip for per level of experience. Considered a Major Psychic. The six conventional powers are granted by name (printed levels Death Trance 1, Mind Block 4, Nightvision 4, Resist Fatigue 4, Resist Hunger 2, Resist Thirst 6 are the powers'' own I.S.P. costs). The four reptile powers have no catalog rows and are special abilities with their printed numbers. || BONUSES: +2 initiative, +3 strike, +4 parry, +5 dodge, +4 S.D.C. damage (damage_bonus), +5 roll, +3 pull punch, +3 vs psionics, +5 vs magic (spell_magic), +7 vs poison, drugs and disease (toxins_poisons, harmful_drugs, disease), +18% vs coma. Impervious to snake venoms is ability text. Heat bonuses are conditional and a special ability. || SKILLS: catalog base plus the printed bonus. Language: Native (adopted) Tongue: Spanish is Language: Spanish at 98, the native-tongue convention. Math: Basic is printed (20%) with no plus sign; read as +20%, 65. W.P. Targeting (Sling) is the catalog W.P. Targeting. Hand to Hand: Assassin is granted with no upgrade price, so no hand_to_hand block. || RELATED: three at level one and one more at levels 3, 5, 8, 10, 13 and 15. Espionage +5% and Rogue +5% stored as bonuses; Rogue +10% to Seduction only and Pilot basic vehicles only are a restriction line. || SECONDARY: two from the Secondary Skill List at levels 1, 3, 8 and 12, read as two at each of those levels. || OCCUPATIONS: Body Doc is stored as body-fixer, the catalog''s Rifts medical O.C.C.; there is no Body Doc class. Any Magic O.C.C. is group:magic. The skill swap such a character makes is a restriction line, not pairing_skills (regression pins its carriers). || EQUIPMENT: the list is for a Lyvorrk R.C.C. (By O.C.C. otherwise). Silver cross is small-silver-cross; 1D6+6 wooden stakes; mallet is hammer-and-mallet; silver dagger (1D6 S.D.C.) is knife-silver-plated; skinning knife; 1D4+1 high explosive grenades as explosive-grenade; 1D4 plasma grenades as triax-plasma-grenade (Plasma Grenade); 1D4+1 smoke grenades; backpack; 1D4+1 large sacks; 1D4+1 medium sacks as sack. Granted since ~116 and ~117, to every Lyvorrk although the book gives them to one taking the R.C.C. and not to one who takes the Body Doc or a Magic O.C.C., who has that O.C.C.''s equipment instead (the condition is the player''s to honour): the sling with normal and silver bullets (1D6 S.D.C., double damage to vampires; may also throw grenades) as sling, the satchel as purse-satchel, and the waterskin and the blood bottle as two water-skin. NOT STORED, no catalog row: one M.D. weapon (probably a Vibro-Blade or energy pistol), 2D6+4 live poisonous snakes, a Gila Monster and 1D6+2 lizards; they are in GM Notes. || MONEY: R.C.C. starts with 2D6x1000 credits and 1D6x100 in tradeable goods, or by O.C.C.; the credits are starting_money, the goods are GM Notes. || INSANITY (printed 132, cache p133, re-read off 200 and 300 dpi renders 2026-10-05): the entry prints Roll on the following table at levels 2, 4, 6, 8, 10, 12 and 14 for additional insanities, and no roll at creation; the two insanities every Lyvorrk has (the fondness for poisonous snakes and lizards, the fear of drowning and bodies of water) stay in side_effects. The table has ten rows of ten points each, 01-10 to 91-00, alternating obsession and phobia. Stored as one pick-one group at levels 2, 4, 6, 8, 10, 12 and 14 with band-named options Insanity (NN-NN), replacing the level 2 level_progression line that only said to roll (BOOK-INGEST-AUDIT.md F116). No row prints a number, so no option carries bonuses. Row 81-90 Obsession: Magic sends the player to a second percentile roll (01-70 covets magic, 71-00 hates it): that sub-roll is the row''s prose. GM Notes keeps its one-paragraph summary of the table. || NOT STORED: size 5-6 feet with a 6-7 foot tail, weight 140-170 pounds, life span 6D6+100 years, breeding, habitat, slave market value 1D4x10,000 credits, allies and enemies; in GM Notes."
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
   AND instr(markdown, 'the level-gated roll at levels 2-14 is prose') > 0
   AND length(markdown) = 16552;

-- == dewtani ==
UPDATE imported_classes
   SET markdown = '---
id: dewtani
name: Dewtani
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.64-66
category: rcc
tags: []
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+4"
  MA: "2d6"
  PS: "2d4+4"
  PP: "2d6+4"
  PE: "3d6+2"
  PB: "3d6+2"
  Spd: "3d6"
mdc_base: "P.E. + 6, +1d6 per level"
ppe_base: "P.E. attribute number +1d4x10"
psionics_allowed: false
occ_restrictions:
  only: ["ley-line-walker", "mystic", "shifter", "stone-master", "ocean-wizard", "conjurer", "mystic-knight", "old-believer", "russian-fire-sorcerer", "techno-wizard", "russian-mystic-kuznya"]
  note: "Every Dewtani takes a magic O.C.C.: Ley Line Walker, Mystic, Shifter, Stone Mage/Stone Master, Ocean Wizard, Conjurer, Mystic Knight (evil), Old Believer/Nature Magic or Russian Fire Sorcerer; fewer than one percent practice Techno-Wizardry or Mystic Kuznya. Never a Witch, Necromancer or Bio-Wizard, and they avoid Warlock elemental magic."
bonuses:
  saves: { disease: 2, horror_factor: 2 }
special_abilities:
  - name: "Gifted spell strength"
    description: "+1 to Spell Strength, starting at level one."
  - name: "Gift marks"
    description: "Light blue tattoo-like markings run from the back of the neck over the shoulders and down the arms, unique to each Dewtani like a fingerprint. They turn dark blue, almost black, while the Dewtani casts a spell, absorbs P.P.E. or uses a magic device."
  - { choose: 1, at_levels: [3, 7], from: ["Phobia (01-07): Faerie Folk", "Phobia (08-14): Ghosts and Entities", "Phobia (15-21): Psychic Healing", "Phobia (22-28): Mind Melters", "Phobia (29-35): Necromancers and Necromancy", "Phobia (36-41): Zombies and Animated Dead", "Phobia (42-48): Bursters and Zappers", "Phobia (49-54): Mind Bleeders", "Phobia (55-60): Being Touched", "Phobia (61-66): Vampires and Any Undead", "Phobia (67-71): Clowns", "Phobia (72-76): Symbiotes and Parasites", "Phobia (77-79): Slimes and Gooey Substances", "Phobia (80-81): Techno-Wizard Devices", "Phobia (82-83): Fortune Tellers", "Phobia (84-86): Water", "Phobia (87-88): Psi-Stalkers", "Phobia (89-91): Bio-Wizard Devices and Bio-Wizards", "Phobia (92-94): Techno-Wizards", "Phobia (95-97): Haunted Places", "Phobia (98-00): Rifts"], note: "Dewtani phobia table (printed 66): rolled at level 3 and a second time at level 7. No save." }
  - name: "Phobia (01-07): Faerie Folk"
    description: "Roll 01-07. Phobia: Faerie Folk."
  - name: "Phobia (08-14): Ghosts and Entities"
    description: "Roll 08-14. Phobia: Ghosts and Entities, including Astral Beings."
  - name: "Phobia (15-21): Psychic Healing"
    description: "Roll 15-21. Phobia: Psychic healing."
  - name: "Phobia (22-28): Mind Melters"
    description: "Roll 22-28. Phobia: Mind Melters."
  - name: "Phobia (29-35): Necromancers and Necromancy"
    description: "Roll 29-35. Phobia: Necromancers, Necromancy, and any magic involving animated skeletons, bones and burial places."
  - name: "Phobia (36-41): Zombies and Animated Dead"
    description: "Roll 36-41. Phobia: Zombies and animated dead."
  - name: "Phobia (42-48): Bursters and Zappers"
    description: "Roll 42-48. Phobia: Bursters and Zappers."
  - name: "Phobia (49-54): Mind Bleeders"
    description: "Roll 49-54. Phobia: Mind Bleeders."
  - name: "Phobia (55-60): Being Touched"
    description: "Roll 55-60. Phobia: Being touched."
  - name: "Phobia (61-66): Vampires and Any Undead"
    description: "Roll 61-66. Phobia: Vampires and any undead."
  - name: "Phobia (67-71): Clowns"
    description: "Roll 67-71. Phobia: Clowns."
  - name: "Phobia (72-76): Symbiotes and Parasites"
    description: "Roll 72-76. Phobia: Symbiotes and parasites."
  - name: "Phobia (77-79): Slimes and Gooey Substances"
    description: "Roll 77-79. Phobia: Slimes and gooey substances."
  - name: "Phobia (80-81): Techno-Wizard Devices"
    description: "Roll 80-81. Phobia: Techno-Wizard devices."
  - name: "Phobia (82-83): Fortune Tellers"
    description: "Roll 82-83. Phobia: Fortune tellers."
  - name: "Phobia (84-86): Water"
    description: "Roll 84-86. Phobia: Water."
  - name: "Phobia (87-88): Psi-Stalkers"
    description: "Roll 87-88. Phobia: Psi-Stalkers."
  - name: "Phobia (89-91): Bio-Wizard Devices and Bio-Wizards"
    description: "Roll 89-91. Phobia: Bio-Wizard devices and Bio-Wizards."
  - name: "Phobia (92-94): Techno-Wizards"
    description: "Roll 92-94. Phobia: Techno-Wizards."
  - name: "Phobia (95-97): Haunted Places"
    description: "Roll 95-97. Phobia: Any place reputed to be haunted by ghosts."
  - name: "Phobia (98-00): Rifts"
    description: "Roll 98-00. Phobia: Rifts: does not mind ley lines, but hates dimensional portals."
  - { choose: 1, at_levels: [5, 11], from: ["Obsession (01-05): High Technology", "Obsession (06-10): Rifts and Dimensional Travel", "Obsession (11-15): Power", "Obsession (16-20): Magic Weapons", "Obsession (21-25): Self", "Obsession (26-30): Privacy", "Obsession (31-35): Combat", "Obsession (36-40): Magic and Magic Items", "Obsession (41-45): Studying Other D-Bees", "Obsession (46-50): Hates Being Mind Controlled", "Obsession (51-55): Better Than Any Psychic", "Obsession (56-60): Psychics Who Control Machines", "Obsession (61-65): Justice", "Obsession (66-70): Being Good", "Obsession (71-75): Truth", "Obsession (76-80): Secrecy", "Obsession (81-85): Danger", "Obsession (86-90): Fame and Glory", "Obsession (91-95): Undead", "Obsession (96-00): Meeting the Creator"], note: "Dewtani obsession table (printed 66): rolled at level 5 and a second time at level 11. In many cases an obsession can be either for or against, love or hate, the category listed, unless the row says which. No save." }
  - name: "Obsession (01-05): High Technology"
    description: "Roll 01-05. Obsession with high technology: loathes and avoids it."
  - name: "Obsession (06-10): Rifts and Dimensional Travel"
    description: "Roll 06-10. Obsession with Rifts and dimensional travel. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (11-15): Power"
    description: "Roll 11-15. Obsession with power: covets it for himself."
  - name: "Obsession (16-20): Magic Weapons"
    description: "Roll 16-20. Obsession with magic weapons. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (21-25): Self"
    description: "Roll 21-25. Obsession with self, and his own best welfare."
  - name: "Obsession (26-30): Privacy"
    description: "Roll 26-30. Obsession with privacy: hates being bothered or asked lots of questions."
  - name: "Obsession (31-35): Combat"
    description: "Roll 31-35. Obsession with combat. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (36-40): Magic and Magic Items"
    description: "Roll 36-40. Obsession with magic and magic items: loves them and wants to acquire all he can."
  - name: "Obsession (41-45): Studying Other D-Bees"
    description: "Roll 41-45. Obsession with studying other D-Bees. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (46-50): Hates Being Mind Controlled"
    description: "Roll 46-50. Hates being mind controlled: +2 to save vs mind control and possession, but is paranoid and hates beings who possess such powers."
    bonuses: { saves: { mind_control: 2, possession: 2 } }
  - name: "Obsession (51-55): Better Than Any Psychic"
    description: "Roll 51-55. Loves proving he is better than any psychic."
  - name: "Obsession (56-60): Psychics Who Control Machines"
    description: "Roll 56-60. Hates and distrusts all psychics who can control machines."
  - name: "Obsession (61-65): Justice"
    description: "Roll 61-65. Obsession with justice. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (66-70): Being Good"
    description: "Roll 66-70. Obsession with being good, not becoming evil."
  - name: "Obsession (71-75): Truth"
    description: "Roll 71-75. Obsession with truth. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (76-80): Secrecy"
    description: "Roll 76-80. Obsession with secrecy. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (81-85): Danger"
    description: "Roll 81-85. Obsession with danger. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (86-90): Fame and Glory"
    description: "Roll 86-90. Obsession with fame and glory. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (91-95): Undead"
    description: "Roll 91-95. Obsession with the undead. As the table''s note says, this may be for or against, love or hate."
  - name: "Obsession (96-00): Meeting the Creator"
    description: "Roll 96-00. Obsession with meeting the Creator. As the table''s note says, this may be for or against, love or hate."
  - { choose: 1, at_levels: [9], from: ["Psychosis (01-17): Mindless Aggression", "Psychosis (18-30): Become a Psychiatrist", "Psychosis (31-45): Paranoid Schizophrenic", "Psychosis (46-55): God Syndrome", "Psychosis (56-65): Superman Syndrome", "Psychosis (66-75): The Avenger", "Psychosis (76-85): The Destroyer", "Psychosis (86-95): The Purifier", "Psychosis (96-00): Fascination with Death"], note: "Dewtani psychosis table (printed 66): rolled or selected at level 9. Rifts Ultimate Edition p.334 describes the insanities the row does not. No save." }
  - name: "Psychosis (01-17): Mindless Aggression"
    description: "Roll 01-17. Psychosis: mindless aggression."
  - name: "Psychosis (18-30): Become a Psychiatrist"
    description: "Roll 18-30. Psychosis: become a psychiatrist."
  - name: "Psychosis (31-45): Paranoid Schizophrenic"
    description: "Roll 31-45. Psychosis: paranoid schizophrenic who hears the voice of the Creator."
  - name: "Psychosis (46-55): God Syndrome"
    description: "Roll 46-55. Psychosis: God syndrome, believing himself an avatar or personification of the Creator."
  - name: "Psychosis (56-65): Superman Syndrome"
    description: "Roll 56-65. Psychosis: Superman Syndrome. Believes he is better, smarter and more powerful than others, as a chosen holy warrior for the Creator."
  - name: "Psychosis (66-75): The Avenger"
    description: "Roll 66-75. Psychosis: believes he has been appointed to avenge injustice done to the innocent by supernatural beings and monsters, dragons and the Minions of Splugorth included."
  - name: "Psychosis (76-85): The Destroyer"
    description: "Roll 76-85. Psychosis: believes he is to keep the lands north of Mexico out of the clutches of the undead. Seeks them out and destroys them whenever he can, other demonic beings as well."
  - name: "Psychosis (86-95): The Purifier"
    description: "Roll 86-95. Psychosis: believes psychic powers are evil and dangerous and must be purged from the world, starting with the most obvious psychics such as Mind Melters, Mind Bleeders and Bursters."
  - name: "Psychosis (96-00): Fascination with Death"
    description: "Roll 96-00. Psychosis: fascination with death in all of its forms."
  - { choose: 1, at_levels: [13], from: ["Affective Disorder (01-20): Death Wish", "Affective Disorder (21-40): Mania", "Affective Disorder (41-60): Outraged by Acts of Violence", "Affective Disorder (61-80): Hysterical Blindness", "Affective Disorder (81-00): Autonomic Reaction"], note: "Dewtani affective disorder table (printed 66): rolled or selected at level 13. No save." }
  - name: "Affective Disorder (01-20): Death Wish"
    description: "Roll 01-20. Affective disorder: death wish."
  - name: "Affective Disorder (21-40): Mania"
    description: "Roll 21-40. Affective disorder: mania."
  - name: "Affective Disorder (41-60): Outraged by Acts of Violence"
    description: "Roll 41-60. Affective disorder: outraged by acts of violence."
  - name: "Affective Disorder (61-80): Hysterical Blindness"
    description: "Roll 61-80. Affective disorder: hysterical blindness."
  - name: "Affective Disorder (81-00): Autonomic Reaction"
    description: "Roll 81-00. Affective disorder: autonomic reaction."
natural_abilities:
  - name: "Minor Mega-Damage being"
    description: "Their magical nature and attunement to ley lines make them minor M.D.C. beings: M.D.C. is the P.E. attribute number +6, plus 1D6 per level of experience."
  - name: "Sense magic"
    description: "Naturally adept at magic. Senses ley lines, nexus points, Rifts and magic in use as a first level Ley Line Walker does, regardless of O.C.C."
  - name: "Impervious to vampires"
    description: "Impervious to the Vampire''s bite and charms."
trackable_resources: []
level_progression:
  - { level: 15, grants: ["Insanity: roll once on the random insanity table (Rifts Ultimate Edition p.332); played past 15, roll on it every three levels."] }
restrictions:
  - "P.P.E.: 1D4x10 plus the P.E. attribute number, ADDED to the base P.P.E. of the chosen magic O.C.C. Add the O.C.C.''s base by hand: a race''s P.P.E. replaces the occupation''s in a pairing."
  - "A Dewtani who takes a class that calls for psychic powers, such as the Mystic Knight or Mystic, is created without psionic ability and gets one additional magic spell per level of advancement instead."
  - "Psionic powers: none. Magic: knows the principles of magic but no spells unless a magic O.C.C. is selected."
  - "Alignment: starts life Principled or Scrupulous; by middle age most are Unprincipled (40%), Anarchist (30%) or Aberrant (15%); in the last two decades of life many are Anarchist (40%) or Aberrant (40%). Those who turn evil are always Aberrant."
  - "Cybernetics and bionics: will consider Bio-Systems for medical reasons only."
  - "Standard equipment and money: as per O.C.C."
side_effects: "Over the course of their lives the Dewtani slowly gain insanities and become less moral and good. There is no save against these inherent insanities; they just happen. More may come from emotional or physical trauma."
extraction_notes: "Rifts World Book 30: D-Bees of North America printed 64-66 (cache p065-p067, cache page = printed folio + 1), a scan, every number read off 200 dpi renders. Heading Dewtani on printed 64; tag line Dewtani - Optional Player Character or NPC on printed 65; the insanity tables run onto printed 66 and end before Dirari Ecto-Men. New to this book. || CATEGORY: a race that takes a magic O.C.C. No xp_table: the book prints none and names none for the race; the occupation''s ladder applies. No men_of_arms line, since mdc_base is stated. || ATTRIBUTES as printed. M.D.C. P.E. +6, +1D6 per level. Horror Factor: not applicable, so none stored. || P.P.E.: 1D4x10 plus P.E., added to the magic O.C.C.''s base. Stored as ppe_base with a restriction line telling the player to add the O.C.C.''s base by hand (the rifts-cyclops precedent); not yields_to_occupation, which is for a race whose figure gives way rather than adds. || BONUSES: +2 vs disease and +2 vs Horror Factor stored. +1 to Spell Strength from level one has no sheet field: special ability. Impervious to the Vampire''s bite and charms: ability text. || PSIONICS: none, psionics_allowed false. The rule for a psychic O.C.C. (no psionics, one extra spell per level) is a restriction line; not modelled. || AVAILABLE O.C.C.s (printed 65): stored as only with the ids that resolve: ley-line-walker, mystic, shifter, stone-master (for Stone Mage/Stone Master), ocean-wizard, conjurer, mystic-knight, old-believer (for Old Believer/Nature Magic), russian-fire-sorcerer, and techno-wizard and russian-mystic-kuznya (fewer than 1%). Regional variants such as russian-ley-line-walker are not named by the book and are left out. || INSANITIES (printed 66, cache p067, re-read off 200 and 300 dpi renders 2026-10-05): the entry prints four tables of its own. Level 3: a phobia, 21 rows, 01-07 Faerie Folk to 98-00 Rifts; level 7: the phobia table a second time. Level 5: a random obsession, 20 rows of five points each, 01-05 High technology to 96-00 Meeting the Creator, under a note that an obsession can be for or against unless the row says; level 11: the obsession table a second time. Level 9: roll or select a psychosis, 9 rows, 01-17 Mindless aggression to 96-00 Fascination with death. Level 13: roll or select an affective disorder, 5 rows of twenty points each. Every table''s bands run 01-00 with no gap or overlap. Stored as four pick-one groups with band-named options, at levels 3 and 7, 5 and 11, 9, and 13 (BOOK-INGEST-AUDIT.md F116), replacing the six level_progression lines that only said to roll. The 2026-10-03 note counted 20, 19 and 8 rows for the first three tables; the page has 21, 20 and 9. One row prints a number: obsession 46-50 Hates being mind controlled, +2 to save vs mind control and possession, stored on that option as saves mind_control 2 and possession 2. The psychosis table''s Note: See page 334 in Rifts Ultimate Edition for insanities not described here is in that group''s note. Level 15, roll once on the random insanity table (page 332 of Rifts Ultimate Edition), and every three levels past 15: another book''s table, left as the level 15 level_progression line. The GM Notes keep a short list of each table. || NOT STORED: pronunciation doo-TAH-nee, also known as The Gifted or Receivers of the Gift, size (males 6-7 feet, females 5 feet to 5 feet 10 inches), weight (males 110-170 lbs, females 90-140 lbs), life span 6D6+160, reproduction, slave market value 6D6x10,000, habitat, allies and enemies are in GM Notes. Experience Level 1D8+2 for NPCs is a population figure."
---

## Lore

The Dewtani come from a world much like Rifts Earth, rich in ambient magic,
whose short, stable ley lines were held in check by ancient monoliths at
every nexus. When those stones shattered without warning, the released
energy tore open every nexus at once and flung the Dewtani across the
Megaverse; many landed on Earth. Unknown to them, the disaster was a ripple
of Earth''s own Great Cataclysm.

They look much like handsome, slender humans with bronze skin, black hair
that silvers in middle age, narrow jaws and tall pointed ears that get them
mistaken for Elves. Each bears unique blue "gift marks" down the neck,
shoulders and arms, which darken when the Dewtani works magic.

Devoutly religious, they see their bond with ley line energy as the Gift of
the Creator, and casting spells as an act of worship, so nearly all become
practitioners of magic. Many study Necromancy only to understand how it
twists the Gift; none practice it. Many become Shifters in hope of finding
their lost home.

Earth''s ley lines carry a price. From adulthood the Dewtani hear "Dark
Whispers" urging selfish and evil acts, and as they age they slowly go mad.
They treat that madness as a holy trial that draws them closer to their
god, and some of their most revered clerics are among the most deranged.

## GM Notes

Pronounced doo-TAH-nee; also known as The Gifted or Receivers of the Gift.
Males 6-7 feet (1.8 to 2.1 m), 110-170 lbs (49.5 to 76.5 kg); females 5 feet
to 5 feet 10 inches (1.5 to 1.78 m), 90-140 lbs (40.5 to 63 kg).

Life span 6D6+160 years. Mature at 20, when the voices start; middle age is
90, an elder 145 or older. One child after a 20 month gestation; sterile by
middle age.

Disposition: cold and aloof, visibly happy only when casting or near ley
lines; they open up only to other magic users and proven equals.

Insanity tables (each is a pick group among the special abilities, rolled at
the level named; the level 15 roll is in the level progression):

- Level 3 phobia: Faerie Folk; ghosts and entities including Astral Beings;
  psychic healing; Mind Melters; Necromancy and anything of animated bones and
  burial places; zombies and animated dead; Bursters and Zappers; Mind
  Bleeders; being touched; vampires and any undead; clowns; symbiotes and
  parasites; slimes and gooey substances; Techno-Wizard devices; fortune
  tellers; water; Psi-Stalkers; Bio-Wizard devices and Bio-Wizards;
  Techno-Wizards; places reputed haunted; Rifts (not ley lines).
- Level 5 obsession (for or against): high technology; Rifts and dimensional
  travel; power; magic weapons; self; privacy; combat; magic and magic items;
  studying other D-Bees; hating mind control (+2 to save vs mind control and
  possession, but paranoid); proving himself better than any psychic;
  psychics who control machines; justice; being good; truth; secrecy; danger;
  fame and glory; undead; meeting the Creator.
- Level 9 psychosis: mindless aggression; becomes a psychiatrist; paranoid
  schizophrenic hearing the Creator; god syndrome; superman syndrome as the
  Creator''s holy warrior; the avenger against supernatural evil; the
  destroyer of the undead north of Mexico; the purifier of psychics;
  fascination with death.
- Level 13 affective disorder: death wish; mania; outraged by violence;
  hysterical blindness; autonomic reaction.

Habitat: mostly North America, especially the Magic Zone, Minnesota,
Colorado and Lazlo, and anywhere with ley lines, including England, France,
Poland, Russia and China. Slave market value 6D6x10,000 credits.

Allies: none natural, but they trust other mages, renowned heroes,
Cyber-Knights and proven associates. Enemies: none known, though they view
psychics as untrustworthy rivals and rarely accept one as an equal.
',
       updated_at = datetime('now')
 WHERE class_id = 'dewtani'
   AND instr(markdown, 'The format cannot roll a table by level: prose in level_progression') > 0
   AND length(markdown) = 10005;

-- == anti-monster ==
UPDATE imported_classes
   SET markdown = '---
id: anti-monster
occ_group: men-of-arms
name: Anti-Monster
system: rifts
source_book: Rifts World Book 6: South America p.34-37
category: occ
tags: [combat, hunter, augmented]
xp_table: [0, 2601, 5001, 9001, 18001, 25001, 35001, 60001, 85001, 100001, 150001, 200001, 270001, 370001, 470001]
attribute_dice:
  MA: "1d6+19"
  PS: "2d6+28"
  PP: "1d6+19"
  PE: "2d6+18"
  PB: "2d4"
  Spd: "3d4x10"
mdc_base: "1d6x10+400"
ppe_base: "1d4"
horror_factor: "2D4+6"
starting_money: "1d6x1000"
bonuses:
  combat: { initiative: 2, strike: 1, parry: 1, dodge: 1, pull_punch: 4, roll: 2 }
  saves: { spell_magic: 3, psionics: 3, horror_factor: 5 }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Radio: Basic", base: 55, per_level: 5, note: "+10%" }
    - { name: "Wilderness Survival", base: 40, per_level: 5, note: "+10%" }
    - { choose: 1, categories: [{ name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }], bonus: 10, note: "Piloting: any one, except robots and power armor (+10%)." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Language: two of choice (+20%). Taken once per language." }
    - { name: "Lore: Demons & Monsters", base: 40, per_level: 5, note: "+15%; the book prints Demon and Monster Lore." }
    - { name: "W.P. Energy Rifle", base: 0, per_level: 0 }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: three of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "Can be changed to Martial Arts, or Assassin if an evil alignment, for the cost of one other skill." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"], bonus: 10 }
      - { name: "Pilot Related", bonus: 10 }
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - { name: "Technical", bonus: 5 }
      - "Weapon Proficiencies"
      - "Wilderness"
    note: "Military: none. Medical: First Aid and Paramedic only, and Paramedic counts as two skills. Physical: any except Acrobatics. Pilot: any except robot and power armor."
    schedule:
      - { level: 3, count: 2 }
      - { level: 6, count: 2 }
      - { level: 9, count: 1 }
      - { level: 12, count: 1 }
  secondary_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - "Espionage"
      - { name: "Mechanical", only: ["Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Robot Combat Elite: T-31 Super Trooper", "Robot Combat Elite: X-10A Predator", "Robot Combat Elite: X-535 Jager", "Robot Combat Elite: X-545 Super Jager", "Robot Combat Elite: X-1000 Ulti-Max", "Robot Combat Elite: X-2000 Dyna-Max", "Robot Combat Elite: X-2500 Black Knight", "Robot Combat Elite: X-60 Flanker", "Robot Combat Elite: X-500 Forager"] }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", only: ["Mathematics: Basic"] }
      - "Technical"
      - "Weapon Proficiencies"
      - "Wilderness"
equipment_starting:
  - { choose: 1, label: "suit of medium or heavy M.D.C. armor", qty: 1, from: ["personalized-light-or-medium-mdc-body-armor", "gladiator-body-armor", "crusader-body-armor", "ca-1-heavy-dead-boy-armor"], note: "The book says medium or heavy M.D.C. armor, or any suit of cyborg armor, without naming one; this is the catalog set." }
  - { choose: 2, label: "energy weapons of choice", qty: 1, from: ["rc-10-laser-pistol", "rc-15-laser-rifle", "dragon-1-plasma-projector", "ng-33-northern-gun-laser-pistol", "wilk-s-320-laser-pistol", "ng-l5-northern-gun-laser-rifle", "wilk-s-447-laser-rifle"], note: "The book says two energy weapons of choice without enumerating; the Colombian RC-10, RC-15 and Dragon-1 from this book lead the catalog set." }
  - { choose: 3, label: "hand to hand or archaic weapons of choice", qty: 1, from: ["broadsword", "axe-battle", "axe-throwing", "bo-staff", "club-stick-pipe", "arab-mace", "cross-bow", "beaked-axe", "vibro-knife"], note: "The book says three other hand to hand or archaic weapons of choice without enumerating; this is the catalog set." }
psionics:
  type: "major"
magic:
  type: "spell"
  spells: ["Blinding Flash", "Globe of Daylight", "Chameleon", "Armor of Ithan", "Magic Net", "Shadow Meld"]
trackable_resources:
  - { key: blinding-flash, label: "Blinding Flash", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: globe-of-daylight, label: "Globe of Daylight", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: chameleon, label: "Chameleon", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: armor-of-ithan, label: "Armor of Ithan", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: magic-net, label: "Magic Net", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
  - { key: shadow-meld, label: "Shadow Meld", max: 3, reset_on: day, note: "Built-in spell, cast as a 5th level wizard; no P.P.E. spent." }
special_abilities:
  - name: "M.D.C. Transformation"
    description: "A magical flesh-and-metal creature of 1D6x10+400 M.D.C. Regenerates 4D6 M.D.C. per minute (1D6 per melee). The metal parts are alive and heal on their own."
  - name: "Burned-Out P.P.E. and I.S.P."
    description: "The inner energies are spent in the transformation: P.P.E. and I.S.P. drop to 1D4 each, and neither can be tapped in any way - not by the Anti-Monster, by magic practitioners, or by Mind Bleeders."
  - name: "Supernatural Attributes"
    description: "M.A. 19+1D6, P.S. 28+2D6 (supernatural), P.P. 19+1D6, P.E. 18+2D6, P.B. 2D4 and Spd 3D4x10. The other attributes are rolled normally for the race of origin. Hand to hand Mega-Damage follows the supernatural P.S. table (Rifts Conversion Book One p.22). Against vampires the blows inflict Hit Point damage: 1D4 restrained, 2D6 full strength, 4D6 power punch (counts as two attacks), plus the P.S. damage bonus."
  - name: "Supernatural Powers"
    description: "Unaffected by normal (non-M.D.C.) heat, cold and weapons. Does not eat or breathe, and can survive indefinitely in space, underwater or buried alive. Mega-Damage heat, fire, plasma and cold do half damage; lasers, particle beams, ion blasts, electricity, M.D. explosions, psionics and magic do full damage. Impervious to poisons, drugs and magic potions. Immune to the vampire''s mind control bite (but not its killing bite) and cannot be turned into a vampire."
  - name: "Built-in Spells"
    description: "Blinding Flash, Globe of Daylight, Chameleon, Armor of Ithan, Magic Net and Shadow Meld, each castable up to three times per 24 hours at the strength of a 5th level wizard. No further spells are ever gained and these never increase in level. Can use rune weapons, scrolls, and techno-wizard or enchanted items, but not magic potions or ointments."
  - name: "Sense Psychic and Magic Energy"
    description: "Works like the Psi-Stalker''s ability but less developed: constantly and automatically senses psionic energy and P.P.E. directed at spells, circles, wards, techno-wizardry and magic devices. Range 50 feet (15.2 m)."
  - name: "Sense Supernatural Beings"
    description: "Senses the distinctive psychic scent of the supernatural at 60% +2% per level. Identifying the specific type of creature - demons, vampires and dragons included - is 58% +2% per level."
  - name: "No Psionic Powers"
    description: "All psychic potential is burned out, but the character saves vs psionics as a major psionic (12 or higher)."
  - name: "Initiative Against Undead"
    description: "+4 to initiative against ghouls, vampires and all forms of undead, in place of the usual +2."
  - name: "Cybernetics"
    description: "Mystical bionic lungs, retractable claws or retractable forearm vibro-blades, and 1D4+1 cybernetic implants of the player''s choice, all built in during the transformation. None can be added afterwards. Each implant adds 3% to the chance of rejection."
  - { choose: 1, from: ["Obsession (01-20): Destroying the Undead", "Obsession (21-40): Destroying Evil Supernatural Beings", "Obsession (41-60): Protecting Humans and D-Bees from Evil Gods", "Obsession (61-80): Random Obsession", "Obsession (81-00): One of the Above and a Random Obsession", "Obsession: None"], note: "Insanities (printed 36): the page says 80% of all Anti-Monsters develop an Obsession, and to roll or pick one. It prints no roll for the 80% itself; an Anti-Monster the G.M. rules is among the rest takes Obsession: None, which the Roll button never lands on." }
  - name: "Obsession: None"
    description: "For an Anti-Monster outside the 80% the page says develop an Obsession. Nothing is rolled."
  - name: "Obsession (01-20): Destroying the Undead"
    description: "Roll 01-20 or pick. Obsessed with destroying vampires, ghouls, necromancers and every form of undead."
  - name: "Obsession (21-40): Destroying Evil Supernatural Beings"
    description: "Roll 21-40 or pick. Obsessed with destroying all evil supernatural beings. Dislikes and distrusts any supernatural being, even one of good alignment, and has little liking for creatures of magic or for men of magic who summon or control the supernatural."
  - name: "Obsession (41-60): Protecting Humans and D-Bees from Evil Gods"
    description: "Roll 41-60 or pick. Obsessed with protecting humans and innocent D-bees against evil and manipulative gods and their minions - priests, acolytes, shamans, warlocks and witches included."
  - name: "Obsession (61-80): Random Obsession"
    description: "Roll 61-80. The book sends the player to the random obsession table in the Rifts RPG, page 20; roll there by hand and record the result. That table is not stored here."
  - name: "Obsession (81-00): One of the Above and a Random Obsession"
    description: "Roll 81-00. Pick one of the obsessions above (the book''s wording; record which in the character''s notes) AND roll one additional random obsession on the Rifts RPG table, page 20, by hand."
restrictions:
  - "Can never gain further spells, and the built-in spells never increase in level."
  - "Cannot use magic potions or ointments."
  - "Cannot receive cybernetics or bionics after the transformation."
side_effects: "Inhuman appearance: a towering metallic brute, 7 feet (2.1 m) tall and 400 lbs (180 kg), Horror Factor 2D4+6. Takes DOUBLE damage from rune weapons, Wormwood crystal magic, and Millennium Tree wands, staves and weapons, good or evil. -20% to all Prowl rolls. REJECTION: after 1D4 years there is a 5% chance (+3% per cybernetic implant) that the body rejects the magical grafts, calling for an immediate save vs Coma/Death at -15%. Even on a success the character is crippled for 1D6 months (-7 to strike, parry and dodge, attacks and speed halved), then recovers to -2 on all combat bonuses with speed and attacks reduced by 25%. The rejection chance recurs 1D6 years later and again 2D4 years after the second crisis; after the third the character is safe and returns to full strength. Few survive more than 15 years of active duty. LOSS OF HUMANITY: forgets human needs such as rest, sleep and food; about 50% grow impatient with human frailty and 90% seem cold, brutal and merciless, especially against monsters. INSANITY: 80% develop an Obsession, rolled or picked once from the Obsession group in the special abilities - 01-20 destroying vampires, ghouls, necromancers and all undead; 21-40 destroying all evil supernatural beings, distrusting even good ones; 41-60 protecting humans and innocent D-bees from evil gods and their minions (priests, acolytes, shamans, warlocks and witches); 61-80 roll on the random obsession table in the Rifts RPG p.20; 81-00 pick one of the above and roll one additional random obsession."
extraction_notes: "WB6 printed 34-37 (cache p035-p038). || XP: the Anti-Monster and Amazon ladder, printed 168, lower bounds 0 / 2,601 / 5,001 / 9,001 / 18,001 / 25,001 / 35,001 / 60,001 / 85,001 / 100,001 / 150,001 / 200,001 / 270,001 / 370,001 / 470,001, stored as printed. || GROUP: the book files no O.C.C. under a group heading - it sits in the Republic of Colombia chapter after the vehicles. Stored as men-of-arms: a combat cyborg built to hunt monsters, whose built-in spells are fixed and never grow; it is not a spell caster by training. mdc_base is stated, so no men_of_arms line. || NOT supersedes_race. The book says the other attributes are rolled normally for the race of origin, so the character keeps its race; the six supernatural attributes, the M.D.C. body and the burned-out P.P.E./I.S.P. are stored as attribute_dice, mdc_base and ppe_base, which a race stating its own will override in a pairing. For a human (no R.C.C.) they apply as printed. This is a judgement call and the one to revisit if a D-bee Anti-Monster comes out with the wrong body. || P.S. is supernatural; attribute_dice holds 2d6+28 and the supernatural damage table is prose. P.B. 2D4 is stored as printed (the book lowers it). || SPELL USES: the introduction says the spells can be used up to four times per 24 hours; the O.C.C. ability 5 says up to three times each. The ability entry is the rule and is what trackable_resources stores (max 3, reset daily, one per spell); the four is recorded here. All six are existing general invocations (Blinding Flash, Globe of Daylight, Chameleon, Armor of Ithan, Magic Net, Shadow Meld); granted by name, no spells_starting. Casting level fixed at 5th is prose. || PSIONICS: no powers; stored as type major with no picks, because the book makes the character a major psionic for save purposes (12 or higher). Printed 36 drops P.P.E. and I.S.P. to 1D4 each and says neither can be tapped; ppe_base carries the 1D4 and isp_base is left unstated, so the I.S.P. figure is recorded here only (regression also refuses a class whose two pool formulas are the same string, the shape of a copying error). || BONUSES: +2 initiative, +1 strike/parry/dodge, +4 pull punch, +2 roll, +3 save vs magic, +3 vs psionics, +5 vs horror factor stored unconditionally. The +4 initiative vs undead is conditional and is prose. Imperviousness to poison, drugs and potions is total immunity, left in prose rather than a save bonus. || horror_factor stored as the printed phrase 2D4+6. || SKILLS: Radio: Basic 45+10; Wilderness Survival 30+10; Demon and Monster Lore is the catalog Lore: Demons & Monsters 25+15; Language two of choice +20 as two Language: Other picks. The book prints no Native Tongue line and none was added. Hand to Hand: Expert changes to Martial Arts or Assassin (evil) for one other skill each. Paramedic counting as two skills is a note, not enforced. Military: none, so the category is omitted. Secondary skills carry the same limits without the bonuses, as the book directs. || EQUIPMENT: armor, two energy weapons and three hand to hand or archaic weapons are all of choice; each is a choice from a catalog set. The book''s Heavy Infantry Armor (420 M.D.C.) cyborg armor has no catalog row and is not stubbed. Cybernetics (bionic lungs, claws or forearm vibro-blades, 1D4+1 implants) are prose. || Rejection, loss of humanity and the vulnerabilities are side_effects. || OBSESSION TABLE (2026-10-05, BOOK-INGEST-AUDIT.md F120): printed 36, item 4 Insanities, prints a percentile table of its own - 80% of all Anti-Monsters develop an Obsession, roll or pick one - in five bands, 01-20, 21-40, 41-60, 61-80 and 81-00, which cover 01-00 with no gap or overlap. It is rolled once, at creation, and the page gives no later roll, so it is stored as one pick-one group of five band-named options (Obsession (NN-NN): ...), one definition each. No row prints a number, so no option carries bonuses. The 80% gate is in the group note: the one-in-five character with no obsession leaves the pick empty. 61-80 sends the player to the random table on Rifts RPG p.20 and 81-00 asks for one of the rows above plus one random obsession; both stay as the row prose and are rolled by hand. side_effects keeps its summary of the five bands and now points at the group."
---

## Lore

The Anti-Monster is a mystic cyborg, the product of an advanced and secret
trans-dimensional techno-wizardry found on Earth only in the Republic of
Colombia. Captured Anti-Monsters have been studied by others, Atlantis
included, and nobody has managed to reproduce the process; some suspect a god
or supernatural intelligence is behind it, others a link to the Holy Terrors of
Wormwood or to Doctor Articulus''s home dimension.

A candidate must have some magic or psionic ability. Most of the bone and
organs are replaced with techno-wizard bionics during a long ritual that
consumes nearly all of the candidate''s P.P.E. and I.S.P. to bind flesh and
machine; afterwards the metal parts are alive and heal themselves. The result
is a supernatural warrior able to devastate vampires, demons and creatures of
magic, with a handful of spells built into the body.

Vampires and monsters see Anti-Monsters as their deadliest enemies, while many
humans and D-bees fear the cold, inhuman giants. They are tragic heroes who
defend a world that does not fully accept them, and an evil Anti-Monster
serving the supernatural is extremely rare.

## GM Notes

Alignment: any, but usually scrupulous, selfish or aberrant. There are no
attribute requirements beyond a willingness to become inhuman and some prior
magic or minor psionic ability. Few survive more than fifteen years of active
duty, and the rejection crises (see side effects) are the GM''s to roll.
',
       updated_at = datetime('now')
 WHERE class_id = 'anti-monster'
   AND instr(markdown, 'Rejection, loss of humanity, the obsession table and the vulnerabilities are side_effects.') > 0
   AND length(markdown) = 16251;

-- == wired-gunslinger ==
UPDATE imported_classes
   SET markdown = '---
id: wired-gunslinger
men_of_arms: true
name: Wired Gunslinger
system: rifts
source_book: Rifts World Book 14: New West p.107-110
category: occ
tags: [combat, ranged, augmented]
xp_table: [0, 2161, 4321, 8641, 18001, 27001, 38501, 54701, 77001, 100301, 140501, 210001, 250701, 325001, 395501]
occ_group: men-of-arms
attribute_dice:
  PP: "1d6+17"
hit_points_base: "P.E. + 1d6 per level"
starting_money: "4d6x100 in universal credits; the rest is already spent on fancy clothes, weapons and vehicles"
horror_factor: "8; +1 at levels 2, 4, 5, 6, 8, 10, 11, 13 and 15, and +2 against ordinary folk"
bonuses:
  attributes: { PS: "1d4", Spd: "2d6" }
  combat: { attacks: 1, automatic_dodge: 1, pull_punch: 2, initiative: "1d4+3" }
  saves: { horror_factor: 1 }
  pools: { sdc: "2d6+16" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 6, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 10, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 14, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1, assassin: 1, commando: 2 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 95, per_level: 0, note: "American, at 95%." }
    - { choose: 1, from: ["Language: Other"], bonus: 45, note: "One language of choice, also at 95%. The catalog holds Language: Other at 50%, so 95% is stated here as +45." }
    - { name: "Find Contraband", base: 32, per_level: 4, note: "+6%" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "One piloting skill of choice (+10%), OR Horsemanship: General, which may then be traded for Horsemanship: Cowboy at the cost of one O.C.C. Related skill." }
    - { name: "Interrogation", base: 45, per_level: 5, note: "+15%" }
    - { name: "Streetwise", base: 30, per_level: 4, note: "+10%" }
    - { name: "Palming", base: 30, per_level: 5, note: "+10%" }
    - { name: "Prowl", base: 30, per_level: 5, note: "+5%" }
    - { name: "Recognize Weapon Quality", base: 40, per_level: 5, note: "+15%" }
    - { name: "W.P. Revolver", base: 0, per_level: 0, note: "Includes Derringers." }
    - { name: "W.P. Automatic Pistol", base: 0, per_level: 0 }
    - { name: "W.P. Energy Pistol", base: 0, per_level: 0 }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "W.P. two of choice." }
    - { name: "W.P. Sharpshooting", base: 0, per_level: 0, with: ["W.P. Revolver", "W.P. Energy Pistol"], note: "TWO specialties, one per weapon, and the class grants both weapons separately. BOOK-INGEST-AUDIT.md F49." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be traded up to Martial Arts or Assassin for one O.C.C. Related skill, or to Commando for two." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 10, count: 1 }, { level: 12, count: 1 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - "Domestic"
      - { name: "Electrical", only: ["Basic Electronics"] }
      - { name: "Espionage", bonus: 5 }
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"] }
      - { name: "Medical", only: ["First Aid", "Paramedic"] }
      - { name: "Physical", except: ["Acrobatics"] }
      - { name: "Pilot", bonus: 5 }
      - "Pilot Related"
      - { name: "Rogue", except: ["Computer Hacking", "Seduction"], bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", only: ["Land Navigation"], bonus: 10, note: "Any Wilderness skill may be taken; the +10% is printed against Land Navigation only." }
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 11, count: 2 }]
special_abilities:
  - name: "Danger Response"
    description: "Automatically notices and reacts to movement, especially at the edge of vision. The reflex is to draw and point the gun at whatever moved, and in many situations the response to even overwhelming odds is to shoot, dodge and keep shooting until the danger is gone. It kills a great many Wired Gunslingers - and one in four takes his own life after 10+2D4 years, unless of a miscreant or diabolic alignment, from the constant anxiety or after accidentally injuring or killing an innocent."
  - name: "Crazies Augmentation"
    description: "Modified M.O.M. brain and optic implants, a limited version of the Crazy''s. Increases P.S. by 1D4, sets P.P. to 17+1D6, and adds 2D6 to Speed. It also grants +3+1D4 to initiative with any weapon and in hand to hand. The P.S., Speed and initiative dice are rolled once at creation, and P.P. is rolled as 17+1D6 in place of the usual 3D6. The extra melee attack and the automatic dodge from the same augmentation are fixed."
  - name: "Expertise with all handguns"
    description: "The use of every type of revolver and pistol, whether it fires bullets or energy - effectively the same ability the Gunslinger has."
  - name: "Paired Weapons: Revolvers & Pistols"
    description: "Can draw and fire two handguns, or throw two knives, simultaneously at one target for full damage from both, at the cost of a single melee attack. The attack may instead be split between two targets in view and within peripheral vision, still as one action, rolling to strike separately for each at half the strike bonus. Parrying is impossible while two handguns are in use; the character may dodge, which costs an attack, and counter by shooting."
  - name: "W.P. Sharpshooting Specialties (2)"
    description: "Sharpshooting: Revolver and Sharpshooting: Energy Pistol. Each grants one extra melee attack with that specific weapon for the whole round, the shooting bonuses, and trick shooting: firing a two-handed weapon one-handed without penalty; shooting over the shoulder using a mirror at full strike bonus; shooting from a moving horse or vehicle at half bonuses with no called shot; shooting while upside down at full bonuses; coming up shooting out of a dodge or roll at no bonus or penalty; and the ricochet shot, which bounces a projectile off a surface into a second target for one point to the first and full damage to the second, at half strike bonus, and works with lasers only off a mirrored or highly polished surface."
  - name: "Reputation & Horror Factor"
    description: "The occupation alone carries a stigma and an air of fear, +2 against ordinary folk. Wired Gunslingers are known to be crazed killers and project a Horror Factor of 8, rising by 1 at levels 2, 4, 5, 6, 8, 10, 11, 13 and 15. Opponents save against it whenever he makes a serious threat, when he first draws on a character, in any one-on-one showdown, and whenever an opponent makes his first move to attack - even if the Wired Slinger does not know it is coming. A failed save costs the opponent initiative and one melee attack. This is a Horror Factor the character IMPOSES; the sheet shows it as the class''s Horror Factor. The most famous cannot go anywhere unrecognised, which makes anonymity impossible for anyone travelling with them."
  - name: "Extra attack with a handgun"
    description: "One additional melee attack at levels 5, 10 and 15, when using a revolver or pistol only. This is on top of the unconditional extra attack from the augmentation, and is conditional on the weapon, so it is not added to the sheet''s attacks."
  - { choose: 1, at_levels: [3, 5, 7, 10, 13], from: ["Insanity (01-15): Phobia of Gunslingers and Crazies", "Insanity (16-30): Paranoia", "Insanity (31-40): Ordinary Laws Are for Ordinary Men", "Insanity (41-45): Bold Daredevil", "Insanity (46-50): Manic Depressive", "Insanity (51-55): Compulsive Liar", "Insanity (56-60): Obsession with Cleanliness", "Insanity (61-65): Kleptomaniac", "Insanity (66-70): Phobia of Heights", "Insanity (71-75): Obsessive Hatred of a Race", "Insanity (76-80): Obsessive Disdain for the Law and Lawmen", "Insanity (81-85): Random Obsession", "Insanity (86-90): Random Phobia", "Insanity (91-95): Frenzy", "Insanity (96-00): Multiple Personality"], note: "Insanities of the Wired Gunslinger (printed 108-109): one percentile roll at each of levels 3, 5, 7, 10 and 13. The page does not say what a repeated result does." }
  - name: "Insanity (01-15): Phobia of Gunslingers and Crazies"
    description: "Roll 01-15. Fears other Gunslingers, rival Brain Fry and Crazies, sure that they are out to get him. Avoids their company, usually takes their mockery, backs down from their challenges and stays out of showdowns with them; fights them only when cornered."
  - name: "Insanity (16-30): Paranoia"
    description: "Roll 16-30. ''They''re all out to get me!'' Believes most people hate him from jealousy or dislike him from fear, and so mean to kill, jail, cheat, rob, overcharge, short-change or discredit him and to lie to and about him. Blames every misfortune on the ill will of others and sees conspiracies everywhere. Especially leery of other professional gunmen, lawmen and bounty hunters."
  - name: "Insanity (31-40): Ordinary Laws Are for Ordinary Men"
    description: "Roll 31-40. So sure of his superiority that he ignores the laws of any place he visits. Not necessarily mean about it, but he blatantly and deliberately breaks the law (often in little things), does as he pleases, and refuses to pay the consequences when accused."
  - name: "Insanity (41-45): Bold Daredevil"
    description: "Roll 41-45. ''I can do anything.'' Usually a friendly, cheerful braggart who accepts any challenge, takes stupid risks, and fights at the drop of a hat for his honor or that of his friends and allies, even when they ask him not to. His antics often land him in trouble and endanger those around him."
  - name: "Insanity (46-50): Manic Depressive"
    description: "Roll 46-50. Alternates week by week. Depressed week: -10% on all skills and all combat bonuses halved. Manic week: +5% on all skills and +2 on initiative. Both sets of numbers apply only in their own week, so neither is added to the sheet."
  - name: "Insanity (51-55): Compulsive Liar"
    description: "Roll 51-55. Lies compulsively, even if of a good alignment."
  - name: "Insanity (56-60): Obsession with Cleanliness"
    description: "Roll 56-60. Keeps himself as clean as possible: washes his hands a dozen times a day, bathes and launders often, always cleans up after himself and avoids getting dirty. Finds anyone who does not keep his regimen foul and may refuse to shake hands. Adds to his equipment three dozen disposable plastic surgical gloves, a box of 144 Wet Wipes, six bars of soap, a washcloth and a box of clothing detergent (not stored as gear; write them in)."
  - name: "Insanity (61-65): Kleptomaniac"
    description: "Roll 61-65. A compulsion to steal - often small and insignificant things, but expensive or important items too - even if of a good alignment."
  - name: "Insanity (66-70): Phobia of Heights"
    description: "Roll 66-70. Will not willingly climb higher than 10 feet (3 m). If forced, either fights and runs away or freezes in terror, with no initiative and no attacks. Hates to fly."
  - name: "Insanity (71-75): Obsessive Hatred of a Race"
    description: "Roll 71-75. Hates one particular monster or D-bee race (name it in the character''s notes). Will not trust or associate with its members for any reason, treats them with disdain, and will beat or kill one at the tiniest provocation - an accidental bump, a disapproving look, snoring."
  - name: "Insanity (76-80): Obsessive Disdain for the Law and Lawmen"
    description: "Roll 76-80. Ignores all laws and breaks them deliberately, often with great fanfare. Openly belittles, defies and challenges lawmen, and loves a showdown with one."
  - name: "Insanity (81-85): Random Obsession"
    description: "Roll 81-85. The book sends the player to the random obsession table in the Rifts RPG, page 20; roll there by hand and record the result. That table is not stored here."
  - name: "Insanity (86-90): Random Phobia"
    description: "Roll 86-90. The book sends the player to the random phobia table in the Rifts RPG, page 20; roll there by hand and record the result. That table is not stored here."
  - name: "Insanity (91-95): Frenzy"
    description: "Roll 91-95. Frenzy, as described under Crazies in the Rifts RPG, page 57; the book gives no rule of its own here, only the page reference."
  - name: "Insanity (96-00): Multiple Personality"
    description: "Roll 96-00. Multiple Personality, as described under Crazies in the Rifts RPG, page 59; the book gives no rule of its own here, only the page reference. The page spells the heading ''Multiple Personalty''."
equipment_starting:
  - { item_id: "binoculars", qty: 1 }
  - { item_id: "flashlight", qty: 1 }
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 2 }
restrictions:
  - "RACIAL RESTRICTION the schema cannot enforce: humans and very human-like D-bees only, the book naming Elves, Ogres and True Atlanteans without magical tattoos. `race_restrictions` matches a race id and this is a restriction by KIND - see BOOK-INGEST-AUDIT.md F51."
  - "Cowboy and Military are closed as related categories."
  - "Starts with a clock calendar and one multi-optic eye on top of the M.O.M. implants. Any further augmentation must be acquired later, and most Wired Slingers avoid it except for medical reasons."
side_effects: "The augmentation brings the Crazy''s side effects with it, if not quite as extreme. Wired Gunslingers are jumpy and fidgety and turn paranoid quickly, because the smallest motion catches the eye and starts the adrenaline. Sleep and concentration are difficult and the character can never really relax. Most suffer mild paranoia and delusions of power, are constantly looking around, have trouble concentrating on skills and subjects, are easily distracted, and like killing - to a Wired Gunslinger the thrill of combat is like a drug. Most embrace it. The best become daring heroes and the worst cold-blooded killers who fight at the slightest provocation. ON TOP OF ALL THAT, roll on the book''s fifteen-band insanity table at levels 3, 5, 7, 10 and 13 (printed 108-109); it is the Insanity pick group in the special abilities, one pick banked at each of those levels."
extraction_notes: "FOUR OF THIS CLASS''S AUGMENTATION BONUSES ARE DICE. P.S. +1D4, Speed +2D6 and +3+1D4 to initiative are `bonuses` (PS "1d4", Spd "2d6", initiative "1d4+3"), rolled once at creation. P.P. is SET to 17+1D6 rather than raised, so it is `attribute_dice` PP "1d6+17", rolled in place of 3D6 - the shape the Anti-Monster uses; a race that states its own attribute_dice replaces it in a pairing. On import (PR #886) all four were prose in the Crazies Augmentation ability, on the belief that a dice expression in bonuses was not applied and that nothing expressed a set attribute; BOOK-INGEST-AUDIT F52 falsified that belief on 2026-09-10, and the New West backfill moved all four. The extra attack and the automatic dodge from the same paragraph are fixed and ARE in bonuses. THE INSANITY TABLE IS STORED (2026-10-05, BOOK-INGEST-AUDIT.md F116). Printed 108-109, under the heading Insanities of the Wired Gunslinger, says to roll on the table at levels 3, 5, 7, 10 and 13, and prints FIFTEEN percentile bands, not twenty entries as this note said before: 01-15, 16-30, 31-40, then twelve bands of five from 41-45 to 96-00. They cover 01-00 with no gap or overlap; the die is percentile, read off the bands, and the page names no other. Stored as one pick group, choose 1 at_levels 3, 5, 7, 10 and 13, of fifteen band-named options (Insanity (NN-NN): ...), one definition each, the descriptions paraphrased. No option carries bonuses: the only numbers printed are the Manic Depressive row''s (-10% skills and halved combat bonuses one week, +5% skills and +2 initiative the next), which alternate and so are conditional, and the Fear of Heights row''s loss of initiative and attacks when forced above 10 feet. 81-85 and 86-90 send the player to the random obsession and phobia tables on Rifts RPG p.20, and 91-95 Frenzy and 96-00 Multiple Personality give only a page reference to the Crazies (Rifts RPG p.57 and p.59); all four stay as the row prose and are resolved by hand. The Cleanliness row''s extra equipment is prose in its option. The page does not say what a repeated result does, and the group note says so. The O.C.C. Skills list on printed 109 is set in TWO COLUMNS; read off a 320 dpi render to confirm which entries pair with which, the same fault the Highwayman''s list has on printed 86. Standard Equipment stores only the catalog rows that exist; the book also lists M.D.C. body armour of choice, tinted goggles, a quality cowboy hat, riding clothes, an expensive town suit, a multi-optics band, a laser distancer and a pocket translator."
---

# Wired Gunslinger

**Alignments.** Any, but often anarchist or evil. Those who are honourable and
live by the Code of the New West may be any alignment, including good,
unprincipled or aberrant.

The Wired Gunslinger has been mechanically hardwired for reflexes, reaction time
and response movement - programmed to react to motion, identify a hostile
quickly, and answer by targeting, drawing and shooting him dead.

The original idea was to use modified, limited M.O.M. brain and optic implants
like the Crazy''s, without the full range of powers and, hopefully, without the
side effects. The side effects came anyway.

## The price

There is no attribute requirement - only a willingness to be augmented and the
money to pay for it, which runs 150,000 to 200,000 credits. Most cannot pay,
and arrange instead to be wired by a body-chop-shop proprietor or a sponsor: a
wealthy rancher, a business tycoon, the Black Market, sometimes a town or a
gang wanting an enforcer. Three or four years of servitude usually clears the
debt. Those who renege are generally hunted down and killed.

## Lore

Also known as Brain Fry, the Wired Killer, the Wired Slinger and simply the
Slinger. Regarded much as the ordinary Gunslinger is, only more violent and
less predictable.
',
       updated_at = datetime('now')
 WHERE class_id = 'wired-gunslinger'
   AND instr(markdown, 'THE INSANITY TABLE IS NOT STORED.') > 0
   AND length(markdown) = 12257;

-- == hu-mutants ==
UPDATE imported_classes
   SET markdown = '---
id: hu-mutants
name: Mutants
system: heroes-unlimited
source_book: Revised Heroes Unlimited p.108-123
category: rcc
tags: []
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130101, 180201, 230301, 280401, 340501]
occ_restrictions:
  except: ["hu-alien-edu-general-studies", "hu-alien-edu-military-specialist", "hu-alien-edu-science-specialist", "hu-alien-edu-combat-specialist", "hu-alien-edu-engineer"]
hit_points_base: "P.E. + 1D6 per level"
sdc_base: "30"
starting_money: "4d4x100"
special_abilities:
  - name: "No unusual physical traits"
    description: "Unusual Characteristics, 01-30. The commonest outcome by a wide margin: most mutants pass for ordinary human beings, and only their powers set them apart."
  - name: "Pointy or Large Ears"
    description: "Unusual Characteristics, 31-34."
  - name: "Odd Skin Color"
    description: "Unusual Characteristics, 35-39. Yellow, green, red, grey, light blue, stark white, dark blue, coal black, purple or orange."
  - name: "Ambidextrous"
    description: "Unusual Characteristics, 40-43. Uses the right and left hand with equal skill and dexterity. Also +10% to climbing, +5% to escape artist, pick locks, and mechanical and electrical repair."
    bonuses: { combat: { attacks: 1, parry: 1 } }
  - name: "Odd Hair Color"
    description: "Unusual Characteristics, 44-48. Green, light blue, white streaked, flame red, stark white, bright yellow, metallic silver, dark blue, purple or orange."
  - name: "Double-Jointed"
    description: "Unusual Characteristics, 49-53. Limber enough to collapse the bones of the hands and slip out of handcuffs, dislocate joints painlessly, and fit through small openings. One escape attempt per melee: 79% from rope, handcuffs or chains on the hands and feet, 46% when arms, legs and body are bound or a straightjacket is used. A locked room, trunk or compartment still holds him. He can contort to half his shoulder width and half his chest-to-back depth, and curl into a ball 20% of his height and half his width."
    bonuses: { combat: { roll: 2 } }
  - name: "Unusual Eyes"
    description: "Unusual Characteristics, 54-58. Very small, round, very large, an odd colour, very elliptical, or glowing."
  - name: "Extreme Amount of Body Hair"
    description: "Unusual Characteristics, 59-64. From a very bushy head of hair, through three and six times the normal amount all over, to half-inch fur or 1D4-inch fur covering most of the body except the face, feet and palms."
  - name: "Prehensile Feet and Toes"
    description: "Unusual Characteristics, 65-68. Monkey-like feet with long, finger-like toes and a thumb for grabbing. Not developed enough to throw or fire a gun accurately (-6 to strike), but they pick up and carry 30lbs or less, press buttons, untie rope, turn doorknobs and pull levers. Barefoot: +30 to climb rope or wall, or 30% as a base if there is no climbing skill. Skills like computer operation or pick pockets suffer -25% done with the feet; mechanics, electronics, robotics, medical, demolitions and piloting are effectively impossible, 10% being the best base."
    bonuses: { combat: { dodge: 1 } }
  - name: "Scaly Skin"
    description: "Unusual Characteristics, 69-72. Tough, smooth reptilian skin with small scales."
    bonuses: { pools: { sdc: 30 } }
  - name: "No Body Hair"
    description: "Unusual Characteristics, 73-76. None at all."
  - name: "Small Horns"
    description: "Unusual Characteristics, 77-79. 1D4 inches long, protruding from the forehead."
  - name: "Tough, Lumpy Skin"
    description: "Unusual Characteristics, 80-84."
    bonuses: { pools: { sdc: 30 } }
  - name: "Prehensile Tail"
    description: "Unusual Characteristics, 85-89. 3D4 feet long, of any appearance. It seizes and grasps like a monkey''s - it can turn knobs, press buttons, hold a blunt object as a club, and snare an opponent''s feet or hands - but it cannot untie rope or fire a weapon. It supports the character''s full body weight when dangling, carries about a third of it, and drags up to half at two thirds speed. No hand to hand skill or attribute bonus applies to a strike or parry made with the tail. Also +5 to dodge with the tail itself and +20% to climb when it is used."
    bonuses: { combat: { attacks: 1, strike: 1, parry: 1 } }
  - name: "Retractable Claws"
    description: "Unusual Characteristics, 90-94. Cat-like, in the fingers. About equal to a knife: 2D4 per swipe plus the P.S. damage bonus if any. Adds +10% to climb."
  - name: "Stocky Build"
    description: "Unusual Characteristics, 95-00. Exceptionally broad or husky, about twice as broad as a normal human. Add 50lbs to weight."
    bonuses: { attributes: { PS: "1d4" }, pools: { sdc: "4d4" } }
  - { choose: 1, from: ["No unusual physical traits", "Pointy or Large Ears", "Odd Skin Color", "Ambidextrous", "Odd Hair Color", "Double-Jointed", "Unusual Eyes", "Extreme Amount of Body Hair", "Prehensile Feet and Toes", "Scaly Skin", "No Body Hair", "Small Horns", "Tough, Lumpy Skin", "Prehensile Tail", "Retractable Claws", "Stocky Build"] }
  - name: "Step Four: Super Abilities"
    description: "Step Four, printed 110. One major super ability and one minor, selected or rolled on the Random Super Ability Selection Table."
    super_abilities:
      abilities_starting: 2
      abilities_starting_groups:
        - { count: 1, tiers: ["major"] }
        - { count: 1, tiers: ["minor"] }
  - name: "Step Four: Psionics"
    description: "Step Four, printed 110: the mutant opts for psionics in place of super abilities and takes none of them. Printed 127, Mutants and Aliens: not quite the equal of a natural psionic - two major psi-powers and four secondary ones, selected by the player, chosen once and never changed or added to. Base I.S.P. is M.E. x2 plus one eight-sided die, and it grows by 10 per level of experience; add that by hand. M.E. +2D4 and M.A. +1D4. Printed 127 gives psionic attacks per melee (two at level one, one more at each of levels three, five, seven, nine and twelve) under the Psionics category''s own heading and does not repeat them for a mutant; the G.M. rules on whether they apply."
    bonuses: { attributes: { ME: "2d4", MA: "1d4" } }
    psionics: { type: "master", isp_base: "M.E. x2 + 1d8", powers_starting: 6, powers_starting_groups: [{ count: 2, from: ["Astral Projection", "Bio-Manipulation (the evil eye)", "Bio-Regeneration", "Ectoplasmic Arm", "Empathy", "Empathic Transmission", "Hydrokinesis", "Hypnosis/Mesmerism", "Levitation", "Mind Bolt", "Mind Bond", "Mind Control", "Mind Wipe", "Object Read (Psychometry)", "Presence Sense", "Pyrokinesis", "Telekinesis", "Telemechanics", "Telepathy"], note: "Major psi-powers, printed 128." }, { count: 4, from: ["Alter Aura", "Detect Psionics", "Death Trance", "Hypnotic Suggestion", "Mind Block", "Resist Cold", "Resist Fatigue", "Resist Hunger", "Resist Thirst", "See Aura", "Sixth Sense", "Speed Reading", "Summon Inner Strength", "Total Recall"], note: "Secondary psi-powers, printed 133." }] }
  - { choose: 1, from: ["Step Four: Super Abilities", "Step Four: Psionics"], note: "Step Four (printed 110): super abilities, or psionics instead (printed 127). One or the other, never both." }
restrictions: ["Magic is not a mutant power"]
extraction_notes: "STEP FOUR IS A REQUIRED PICK OF ONE, stored 2026-10-05 off renders of printed 110 and 127. Printed 110: ''Players may select one major super ability and one minor super ability or roll on the Random Super Ability Selection Table. Or you may opt for psionics (see pg. 127). Magic is not a mutant power.'' The two branches are the options ''Step Four: Super Abilities'' and ''Step Four: Psionics'', each carrying its own power block, and the class states no super abilities of its own, so a mutant has the one picked and not the other. The super-abilities option holds the grant the class carried before, unchanged: two, one major and one minor. The psionics option is printed 127''s MUTANTS AND ALIENS paragraph, which rolls no table and prints no tier: base I.S.P. M.E. x2 plus one eight-sided die, +2D4 M.E. and +1D4 M.A., two major and four secondary psi-powers selected by the player, no changes or additions afterwards. It is written exactly as the Alien''s ''Alien Psionics'' option is, for the same page: the two lists are named rather than gated by category, and the type is `master` so that no listed power is filtered out. NOT STORED, and stated in the option''s description instead: the +10 I.S.P. per experience level (rolled-once base, no per-level field, and a class-level progression line would be false for a mutant with super abilities) and the psionic attacks per melee, which printed 127 lists under the Psionics category''s own heading for ''psionic characters'' and does not repeat for a mutant. The natural psionic''s sentence that the 10 I.S.P. ''starts at level one'' is NOT printed in the mutant''s paragraph and is not claimed here. `psionics_allowed` is not stated: this is a choice, not a table of the book''s own odds replacing a roll, and the Alien does not state it either. This replaces a 2026-09 note that said the alternative could not be stored and sent a psionic mutant to the Psionics power category; Nate ruled the branch is imported. Step two, the CAUSE of the mutation, is a background table recorded in the body. MUTANT ANIMALS (printed 111-123) are deliberately NOT imported: they are a BIO-E point-buy construction system with per-species templates, twenty-odd animals each carrying its own table of mutant changes and costs, and the catalog has no builder of any kind. Same argument that kept the robot and super-vehicle systems out - survey D7, BOOK-INGEST-AUDIT F3."
---

## Lore

Mutants are men and women whose normal human physiology has been changed through
some sort of mutation - genetic, or induced by chemicals, radiation, or a
combination of the three. In real life mutations are usually physically impaired
and die. These are the other kind: characters who possess natural, to them,
powers and abilities that far surpass normal humans.

Whatever the cause, their physical and genetic structure is permanently altered.
Mutants are no longer human in the conventional sense, even where the character
was an ordinary person before the mutation occurred. In many cases the powers,
the physiology and the cause alike defy known science.

Sadly it is that x-factor, that inhuman aspect, that terrifies normal human
beings. Fear of the unknown, and a few evil mutants who have used their
extraordinary power in crime, has created an air of suspicion and prejudice
toward all mutants, hero and villain.

Most mutants are humanoid and quite often appear to be ordinary people; only
their unique powers set them apart. Many carry a distinctive characteristic
as well. Odd hair or eye colour is easily hidden; unusual skin colour or an
extra appendage is not.

## GM Notes

**Step two, the cause of the mutation**, is rolled and remembered rather than
stored:

- **01-20** an unknown, random element. A complete mystery.
- **21-40** an accidental encounter with strange stuff - industrial waste,
  chemicals, radiation, an alien substance, energy, or other strangeness.
- **41-60** a genetic aberration; a mutant gene structure, a million-to-one
  chance of fate.
- **61-80** deliberate experimentation. Recreating that experiment to make a
  second, nearly identical mutant is a **2%** chance; recreating a random
  mutating agent that makes some other super being is **4%**; and the chance of
  killing the subject is **53%**.
- **81-00** radiation, usually accidental - and likely not the direct cause so
  much as the trigger for a mutating agent that lay dormant in the individual.

Hand to hand combat is not automatic and must be selected as a learned skill.
Every hero gets two attacks per melee; more come from combat or physical skills,
or from an unusual characteristic. Unless the character is extremely wealthy,
only conventional weaponry and armour are available. Any alignment may be
chosen, though heroes should generally be of good alignment, unprincipled
included.

**Mutant animals** are printed 111-123 and are not in the catalog. They are a
separate construction system - BIO-E points spent across human features, animal
powers and size, against a per-species template - and this app has no builder
for one. The section is condensed from Erick Wujcik''s work in *Teenage Mutant
Ninja Turtles and Other Strangeness*.
',
       updated_at = datetime('now')
 WHERE class_id = 'hu-mutants'
   AND instr(markdown, 'Build a psionic mutant as the Psionics power category instead') > 0
   AND length(markdown) = 8989;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 18 classes carry their new text' AS assertion, count(*) AS got, 18 AS want
  FROM imported_classes
 WHERE (class_id = 'oni-of-the-one-hundred' AND instr(markdown, 'Body (91-95): Giant') > 0)
    OR (class_id = 'pseudo-men' AND instr(markdown, 'Oddity (98-00): Divine Mutant') > 0)
    OR (class_id = 'amphib' AND instr(markdown, 'EACH APPEARANCE ROW NOW CARRIES ITS P.B. DICE') > 0)
    OR (class_id = 'tattooed-man' AND instr(markdown, 'T-Man Insanity (01-30): No Insanity') > 0)
    OR (class_id = 't-monster-man' AND instr(markdown, 'T-Monster Insanity (01-30): No Insanity') > 0)
    OR (class_id = 'maxi-man' AND instr(markdown, 'Maxi-Man Insanity (01-60): No Insanity') > 0)
    OR (class_id = 'splugorth-conservator' AND instr(markdown, 'Insanity (41-42): Obsession, Hates Fighting') > 0)
    OR (class_id = 'rifts-gigantes' AND instr(markdown, 'Insanity (61-70): Psychotic Reliance') > 0)
    OR (class_id = 'norse-giant' AND instr(markdown, 'Insanity (41-70): Obsession') > 0)
    OR (class_id = 'maxi-killer' AND instr(markdown, 'Insanity (85-90): Fear of Tattoos') > 0)
    OR (class_id = 'dragon-juicer' AND instr(markdown, 'deliberately NOT a pick group') > 0)
    OR (class_id = 'necromancer' AND instr(markdown, 'Insanity (61-65): Obsession - Dead Things') > 0)
    OR (class_id = 'african-witch' AND instr(markdown, 'Insanity (66-70): Phobia - Millennium Trees') > 0)
    OR (class_id = 'lyvorrk' AND instr(markdown, 'Insanity (91-00): Phobia - Demons of Hades') > 0)
    OR (class_id = 'dewtani' AND instr(markdown, 'Affective Disorder (81-00): Autonomic Reaction') > 0)
    OR (class_id = 'anti-monster' AND instr(markdown, 'Obsession (01-20): Destroying the Undead') > 0)
    OR (class_id = 'wired-gunslinger' AND instr(markdown, 'Insanity (01-15): Phobia of Gunslingers and Crazies') > 0)
    OR (class_id = 'hu-mutants' AND instr(markdown, 'Step Four: Psionics') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'oni-of-the-one-hundred' AND instr(markdown, 'the three slower kinds are rerolled by hand') > 0)
    OR (class_id = 'pseudo-men' AND instr(markdown, 'the frontmatter has no random-table construct') > 0)
    OR (class_id = 'amphib' AND instr(markdown, 're-roll it by hand, the sheet rolls 3D6') > 0)
    OR (class_id = 'tattooed-man' AND instr(markdown, 'Insanity: roll twice on the T-Men Insanity Table (or pick two)') > 0)
    OR (class_id = 't-monster-man' AND instr(markdown, 'Insanity: roll three times on the T-Monster Men Insanity Table (or pick three)') > 0)
    OR (class_id = 'maxi-man' AND instr(markdown, 'Insanity: roll once on the Maxi-men Insanity Table (or pick one)') > 0)
    OR (class_id = 'splugorth-conservator' AND instr(markdown, '01-10 compulsive liar, even if of good alignment; 11-20 kleptomaniac') > 0)
    OR (class_id = 'rifts-gigantes' AND instr(markdown, 'THE INSANITY TABLE IS PROSE in side_effects.') > 0)
    OR (class_id = 'norse-giant' AND instr(markdown, 'Roll once on the insanity table, or have the G.M. pick: 01-15 none') > 0)
    OR (class_id = 'maxi-killer' AND instr(markdown, 'roll once on the Maxi-Killer insanity table, and again every time') > 0)
    OR (class_id = 'dragon-juicer' AND instr(markdown, 'which has no gear row yet."') > 0)
    OR (class_id = 'necromancer' AND instr(markdown, 'The Insanity Table (printed 104) is prose in special_abilities.') > 0)
    OR (class_id = 'african-witch' AND instr(markdown, 'The Witch Insanity Table is summarized in special_abilities, not stored as data.') > 0)
    OR (class_id = 'lyvorrk' AND instr(markdown, 'the level-gated roll at levels 2-14 is prose') > 0)
    OR (class_id = 'dewtani' AND instr(markdown, 'The format cannot roll a table by level: prose in level_progression') > 0)
    OR (class_id = 'anti-monster' AND instr(markdown, 'Rejection, loss of humanity, the obsession table and the vulnerabilities are side_effects.') > 0)
    OR (class_id = 'wired-gunslinger' AND instr(markdown, 'THE INSANITY TABLE IS NOT STORED.') > 0)
    OR (class_id = 'hu-mutants' AND instr(markdown, 'Build a psionic mutant as the Psionics power category instead') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('oni-of-the-one-hundred', 'pseudo-men', 'amphib', 'tattooed-man', 't-monster-man', 'maxi-man', 'splugorth-conservator', 'rifts-gigantes', 'norse-giant', 'maxi-killer', 'dragon-juicer', 'necromancer', 'african-witch', 'lyvorrk', 'dewtani', 'anti-monster', 'wired-gunslinger', 'hu-mutants') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~161-roll-tables-on-eighteen-classes.sql');
