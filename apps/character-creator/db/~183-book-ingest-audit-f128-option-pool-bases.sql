-- Two classes take their M.D.C. base from the option picked (BOOK-INGEST-AUDIT F128)
-- 2 classes, each replaced whole: phase-world-alien, gene-splicer-mutant.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~183-book-ingest-audit-f128-option-pool-bases.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT F128, the data. The mechanic (an ability option may state
-- mdc_base, sdc_base or hit_points_base) merged in #1789; this converts the two
-- classes the finding names.
--
-- phase-world-alien (Phase World printed 104-105, Step Two: Damage Capacity).
-- The four M.D.C. rows now state the race's base on the option, in the page's
-- own words, per-level gain included:
--   61-70  P.E. plus 1D6 per level of experience      (was prose, "by hand")
--   71-80  1D6x10 plus 2D4 per level of experience    (was pools.mdc 1d6x10)
--   81-90  3D6x10 plus 2D6 per level of experience    (was pools.mdc 3d6x10)
--   91-00  2D6x100 plus 1D4x10 per level of experience (was pools.mdc 2d6x100)
-- The three pool bonuses sat on a class with no M.D.C. base and rolled nothing.
-- The two S.D.C. rows (41-50, 51-60) are NOT touched: they are pool bonuses on
-- the S.D.C. every character has, and they work.
--
-- gene-splicer-mutant (Underseas printed 39, Random Body Type/Appearance).
-- Each of the thirteen Body rows that prints an M.D.C. states it as mdc_base
-- instead of a pool bonus. NO NUMBER MOVES: the class-level base of zero already
-- gave each bonus something to add to. That zero is printed nowhere and STAYS,
-- for the one row (96-00 Other) that prints no M.D.C.: without it that creature
-- would be given hit points and S.D.C., and printed 39 says every one of them is
-- a mega-damage creature. Too Big's 2D4x10 stays a pool bonus; it adds.
--
-- No figure changes. Each was already stored and agrees with the cached page
-- text; the pages were not re-rendered for this script.

-- == phase-world-alien ==
UPDATE imported_classes
   SET markdown = '---
id: phase-world-alien
name: Alien (Phase World race builder)
system: rifts
category: rcc
tags: []
source_book: Rifts Dimension Book 2: Phase World p.104-108
men_of_arms: false
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "3d6"
  PB: "3d6"
  Spd: "3d6"
special_abilities:
  - { choose: 1, from: ["Attributes (01-20): Below Galactic Average, Mental", "Attributes (01-20): Below Galactic Average, Physical", "Attributes (21-50): Galactic Average", "Attributes (51-60): Superior", "Attributes (61-70): Excellent", "Attributes (71-80): Superhuman", "Attributes (81-90): Supernatural", "Attributes (91-00): Incredible Supernatural"], note: "Step One: Attributes (printed 104), rolled once or picked. Every race starts from 3D6 in all eight attributes and the row''s bonuses are added to that. 01-20 prints two results, mental or physical; choose one. The G.M. may instead simply decide the race''s attributes." }
  - name: "Attributes (01-20): Below Galactic Average, Mental"
    description: "Roll 01-20 or choose, and take the mental half of the row: three mental attributes are rolled on 2D4 and the remaining five on 3D6. The page says three mental attributes without naming them; I.Q., M.E. and M.A. is the reading stored."
    attribute_dice: { IQ: "2d4", ME: "2d4", MA: "2d4" }
  - name: "Attributes (01-20): Below Galactic Average, Physical"
    description: "Roll 01-20 or choose, and take the physical half of the row: three physical attributes are rolled on 2D4 and the remaining five on 3D6. The page does not say which three of the five physical attributes (P.S., P.P., P.E., P.B., Spd), so the dice here are left at 3D6: pick the three with the G.M. and re-roll them on 2D4 by hand."
  - name: "Attributes (21-50): Galactic Average"
    description: "Roll 21-50 or choose. All attributes are rolled on 3D6."
  - name: "Attributes (51-60): Superior"
    description: "Roll 51-60 or choose. Add 1D4 to any three attributes. Which three is the builder''s choice, so the bonus is added by hand."
  - name: "Attributes (61-70): Excellent"
    description: "Roll 61-70 or choose. Add 1D6+1 to any three attributes. Which three is the builder''s choice, so the bonus is added by hand."
  - name: "Attributes (71-80): Superhuman"
    description: "Roll 71-80 or choose. Add 1D6+6 to any three attributes. Which three is the builder''s choice, so the bonus is added by hand."
  - name: "Attributes (81-90): Supernatural"
    description: "Roll 81-90 or choose. Add 1D6+6 to any four attributes, by hand. P.S. and P.E. are considered supernatural."
  - name: "Attributes (91-00): Incredible Supernatural"
    description: "Roll 91-00 or choose. Add 1D6+6 to any four attributes, by hand. The page then prints 2D6+10 to P.S. and Spd or P.B., once: the P.S. bonus is stored here, and whether Spd or P.B. takes the same roll or a second one is not printed, so that part is added by hand. P.S. and P.E. are considered supernatural."
    bonuses: { attributes: { PS: "2d6+10" } }
  - { choose: 1, from: ["Damage Capacity (01-40): Galactic Average", "Damage Capacity (41-50): Above Average", "Damage Capacity (51-60): Almost Superhuman", "Damage Capacity (61-70): Minor M.D.C. Being", "Damage Capacity (71-80): M.D.C. Being", "Damage Capacity (81-90): Major M.D.C. Being", "Damage Capacity (91-00): Supernatural M.D.C. Being"], note: "Step Two: Damage Capacity (printed 104-105), rolled once or picked. The page prints 41-60 as plain S.D.C. figures and 61-00 as the race''s BASE M.D.C.; the two S.D.C. rows are stored as pool bonuses and land on the S.D.C. every character has. The four M.D.C. rows each state the race''s M.D.C. base with its per-level gain (BOOK-INGEST-AUDIT.md F128), so a race given one is an M.D.C. being, with no hit points and no S.D.C. of its own. Each row also says whether the appearance and physiological bonuses (Steps Three and Four) are S.D.C. or M.D.C. points; those are stored as S.D.C., so a race given an M.D.C. row moves them to M.D.C. by hand." }
  - name: "Damage Capacity (01-40): Galactic Average"
    description: "Roll 01-40 or choose. S.D.C. and hit points are determined normally. Appearance and physiological bonuses are S.D.C. points."
  - name: "Damage Capacity (41-50): Above Average"
    description: "Roll 41-50 or choose. 1D6x10 S.D.C. The page prints the figure plainly and does not say whether it replaces or adds to S.D.C. determined normally; it is stored as a pool bonus because the class itself states no base. Appearance and physiological bonuses are S.D.C. points."
    bonuses: { pools: { sdc: "1d6x10" } }
  - name: "Damage Capacity (51-60): Almost Superhuman"
    description: "Roll 51-60 or choose. 1D4x100 S.D.C. The page prints the figure plainly and does not say whether it replaces or adds to S.D.C. determined normally; it is stored as a pool bonus because the class itself states no base. Appearance and physiological bonuses are S.D.C. points."
    bonuses: { pools: { sdc: "1d4x100" } }
  - name: "Damage Capacity (61-70): Minor M.D.C. Being"
    description: "Roll 61-70 or choose. Base M.D.C. equal to the P.E. attribute, plus 1D6 per level of experience. Appearance and physiological bonuses are mega-damage points but every one of them is HALVED. Strength and endurance are not supernatural: a punch does normal S.D.C. damage and a power punch 1D4 M.D."
    mdc_base: "P.E. plus 1D6 per level of experience"
  - name: "Damage Capacity (71-80): M.D.C. Being"
    description: "Roll 71-80 or choose. Base M.D.C. of 1D6x10, plus 2D4 per level of experience. Appearance and physiological bonuses are M.D.C. points. Strength and endurance are supernatural."
    mdc_base: "1D6x10 plus 2D4 per level of experience"
  - name: "Damage Capacity (81-90): Major M.D.C. Being"
    description: "Roll 81-90 or choose. As the M.D.C. Being, but base M.D.C. is 3D6x10, plus 2D6 per level of experience."
    mdc_base: "3D6x10 plus 2D6 per level of experience"
  - name: "Damage Capacity (91-00): Supernatural M.D.C. Being"
    description: "Roll 91-00 or choose. As the M.D.C. Being, but base M.D.C. is 2D6x100, plus 1D4x10 per level of experience."
    mdc_base: "2D6x100 plus 1D4x10 per level of experience"
  - { choose: 1, from: ["Appearance (01-30): Human-like", "Appearance (31-50): Humanoid", "Appearance (51-55): Insectoid", "Appearance (56-60): Humanoid Amphibian", "Appearance (61-65): Vegetation", "Appearance (66-70): Humanoid Reptilian", "Appearance (71-75): Humanoid Canine", "Appearance (76-80): Humanoid Avian", "Appearance (81-85): Humanoid Mineral", "Appearance (86-90): Humanoid Feline", "Appearance (91-95): Humanoid Ape", "Appearance (96-00): Humanoid Aquatic"], note: "Step Three: Alien Appearance (printed 105), rolled once or picked. Each S.D.C./M.D.C. bonus is stored as S.D.C.; the Step Two row says whether appearance bonuses are S.D.C. or M.D.C. points." }
  - name: "Appearance (01-30): Human-like"
    description: "Roll 01-30 or choose. A humanoid alien that cannot be told apart from a human."
  - name: "Appearance (31-50): Humanoid"
    description: "Roll 31-50 or choose. A biped with human-like features and a distinguishing physical characteristic of its own: roll on the Unusual Characteristics table (Step Five)."
  - name: "Appearance (51-55): Insectoid"
    description: "Roll 51-55 or choose. Large eyes, antennae, claw-like hands and feet and an exo-skeleton are common. Add 100 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 100 } }
  - name: "Appearance (56-60): Humanoid Amphibian"
    description: "Roll 56-60 or choose. Soft, smooth skin and webbed hands and feet. Semi-aquatic: can hold its breath up to 20 minutes, swims automatically at 90% proficiency, and swims at six times the race''s running speed. Skin is typically green, tan or yellow-blotchy, but varies."
  - name: "Appearance (61-65): Vegetation"
    description: "Roll 61-65 or choose. Made of the same essence as terrestrial plant life, usually green or yellow in various shades. A cold life form that does not register on normal heat sensors or infrared, and it heals twice as fast as normal. +40 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 40 } }
  - name: "Appearance (66-70): Humanoid Reptilian"
    description: "Roll 66-70 or choose. Lizard-like features, leathery or scaly skin, no body hair, dark eyes. +2 to P.P. and +40 S.D.C./M.D.C."
    bonuses: { attributes: { PP: 2 }, pools: { sdc: 40 } }
  - name: "Appearance (71-75): Humanoid Canine"
    description: "Roll 71-75 or choose. Dog-like features, body fur or extreme body hair, dark eyes. +4 to P.S., +2D6 to Speed and +15 S.D.C./M.D.C."
    bonuses: { attributes: { PS: 4, Spd: "2d6" }, pools: { sdc: 15 } }
  - name: "Appearance (76-80): Humanoid Avian"
    description: "Roll 76-80 or choose. Bird-like features, large round eyes, clawed feet and hands, feathers for hair. Whether the race has wings and can fly depends on the special abilities selected (Step Six)."
  - name: "Appearance (81-85): Humanoid Mineral"
    description: "Roll 81-85 or choose. Rocky or crystalline appearance, in any colour. Natural body armor of 3D6x10 S.D.C./M.D.C."
    bonuses: { pools: { sdc: "3d6x10" } }
  - name: "Appearance (86-90): Humanoid Feline"
    description: "Roll 86-90 or choose. Cat-like features, bright oval eyes, a fur-covered body, pointy ears. +2 to P.P. and to Speed, and +10 S.D.C./M.D.C."
    bonuses: { attributes: { PP: 2, Spd: 2 }, pools: { sdc: 10 } }
  - name: "Appearance (91-95): Humanoid Ape"
    description: "Roll 91-95 or choose. Resembles a gorilla or ape: long arms, a fur-covered or extremely hairy body. +1D6 to P.S. and +5D6 S.D.C./M.D.C."
    bonuses: { attributes: { PS: "1d6" }, pools: { sdc: "5d6" } }
  - name: "Appearance (96-00): Humanoid Aquatic"
    description: "Roll 96-00 or choose. Fish or sea-mammal like (dolphin or whale), with webbed feet and hands, smooth or scaly skin, a blowhole or gills, no body hair, brightly coloured. Swims naturally at 90% and at 10 times normal running speed. +20 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 20 } }
  - { choose: 1, from: ["Environment: Earth-like World", "Environment (01-15): High Gravity", "Environment (16-29): Low Gravity", "Environment (30-44): High Radiation", "Environment (45-58): Frozen Planet", "Environment (59-73): Thermo World", "Environment (74-88): Twilight World", "Environment (89-00): Abrasive Atmosphere"], note: "Step Four: Physiological Modifications (printed 105-106). FIRST roll percentile dice: 01-65 the homeworld is Earth-like and there is no modification - take Earth-like World and do not roll here; 66-00 roll once on this table. Each S.D.C./M.D.C. bonus is stored as S.D.C.; the Step Two row says whether physiological bonuses are S.D.C. or M.D.C. points." }
  - name: "Environment: Earth-like World"
    description: "First roll 01-65. Over 60% of the alien species of the Three Galaxies evolved on Earth-like worlds: no modifications."
  - name: "Environment (01-15): High Gravity"
    description: "Roll 01-15 or choose. A homeworld with gravity above the galactic average (0.9 to 1.2 G covers 80% of inhabited planets) gave the race greater mass and endurance, and on normal planets it is much faster and lighter than at home. Average height 4 to 5 feet. S.D.C./M.D.C. bonus 3D4x10. Add 2D4 to P.S., -2 to P.P. Normal speed is increased three times, by hand."
    bonuses: { attributes: { PS: "2d4", PP: -2 }, pools: { sdc: "3d4x10" } }
  - name: "Environment (16-29): Low Gravity"
    description: "Roll 16-29 or choose. Below-average gravity made the race taller than typical humans; the stronger pull of normal planets slows it but gives it somewhat greater mass. Average height 6 to 10 feet, weight 1D4x100 lbs. S.D.C./M.D.C. bonus 1D4x10. Reduce P.S. by 1D6, add 1D4 to P.P. Normal speed is reduced by half, by hand."
    bonuses: { attributes: { PS: "-1d6", PP: "1d4" }, pools: { sdc: "1d4x10" } }
  - name: "Environment (30-44): High Radiation"
    description: "Roll 30-44 or choose. Impervious to radiation levels that would kill most humanoids. There is a 01-50% chance that every member of the race radiates low-level radioactivity that harms humanoids exposed for long periods (a few weeks), in which case its members must wear radiation proof suits to protect other races. Average height 5 to 7 feet, weight 180 to 200 lbs. S.D.C./M.D.C. bonus 1D4x10, and invulnerable to radiation. Can see into the ultraviolet range of light."
    bonuses: { pools: { sdc: "1d4x10" } }
  - name: "Environment (45-58): Frozen Planet"
    description: "Roll 45-58 or choose. Evolved on a far colder planet, or one in an Ice Age; withstands cold, ice and harsh frozen environments, and is impervious to cold. There is a 01-70% chance the race cannot tolerate warmth (35 degrees Fahrenheit / 2 C or higher): at those temperatures its members are -2 P.S. and P.P., speed is reduced by one third and S.D.C./M.D.C. is at -8, cumulative for every 10 hours of exposure above freezing, and when all S.D.C./M.D.C. and hit points are gone the alien dies. A life support suit keeps it alive, and any environmental armor can be reconfigured to keep it cold indefinitely. Average height 5 to 6 feet, weight 100 to 300 lbs. S.D.C./M.D.C. bonus 40."
    bonuses: { pools: { sdc: 40 } }
  - name: "Environment (59-73): Thermo World"
    description: "Roll 59-73 or choose. A steaming-hot homeworld, from a greenhouse atmosphere or closeness to its star. Impervious to heat and fire; lasers and energy blasts do half damage. There is a 01-80% chance the race cannot survive below 98 degrees Fahrenheit / 37 C (200 F / 93 C is comfortable): exposed to lower temperatures it sickens and dies with the same effects as the Frozen Planet''s. Environmental suits can be reconfigured to keep it warm. Average height 5 to 7 feet, weight 100 to 200 lbs. S.D.C./M.D.C. bonus 30."
    bonuses: { pools: { sdc: 30 } }
  - name: "Environment (74-88): Twilight World"
    description: "Roll 74-88 or choose. An extremely dark, night-like world. Nightvision 600 feet (183 m) and sensitive hearing, about 20 percent beyond the human range; but the race is sensitive to average light and is blinded by 100 watts of light (normal sunlight). While blinded it is -8 to strike, parry and dodge; helmets with polarized lenses relieve the problem. Average height 4 to 5 feet, weight 100 to 200 lbs. S.D.C./M.D.C. bonus 10."
    bonuses: { pools: { sdc: 10 } }
  - name: "Environment (89-00): Abrasive Atmosphere"
    description: "Roll 89-00 or choose. High scathing winds or a corrosive atmosphere gave the race a tough, thick skin or leather plating, like an Earth rhinoceros. Average height 5 to 10 feet, weight 200 to 400 lbs. S.D.C./M.D.C. bonus 3D6x10. No other bonuses or penalties."
    bonuses: { pools: { sdc: "3d6x10" } }
  - { choose: 1, from: ["Characteristic: None", "Characteristic (01-16): Pointy or Large Facial Feature", "Characteristic (17-39): Odd Skin Color", "Characteristic (40-48): Odd Hair Color", "Characteristic (49-53): Double-Jointed", "Characteristic (54-58): Unusual Eyes", "Characteristic (59-64): Fur-Covered", "Characteristic (65-68): Prehensile Feet", "Characteristic (69-72): Scaly Skin", "Characteristic (73-76): No Body Hair", "Characteristic (77-79): Small Horns", "Characteristic (80-84): Tough, Lumpy Skin", "Characteristic (85-89): Prehensile Tail", "Characteristic (90-94): Retractable Claws", "Characteristic (95-00): Stocky"], note: "Step Five: Unusual Characteristics (printed 106). Humanoid races that are not human-like can roll here; the Humanoid appearance (31-50) is sent to it. A race that does not use the table takes None. Each S.D.C./M.D.C. figure is stored as S.D.C.; printed 104 leaves the choice between the two to the G.M., and the page does not tie this step to Step Two." }
  - name: "Characteristic: None"
    description: "The table is not used: a human-like race, or one the G.M. gives no unusual characteristic."
  - name: "Characteristic (01-16): Pointy or Large Facial Feature"
    description: "Roll 01-16 or choose. Pointy or large ears, nose or other facial feature."
  - name: "Characteristic (17-39): Odd Skin Color"
    description: "Roll 17-39 or choose. Roll percentile dice again for the colour: 01-10 yellow, 11-20 green, 21-30 red, 31-40 gray, 41-50 light blue, 51-60 stark white, 61-70 dark blue, 71-80 coal black, 81-90 purple, 91-00 orange."
  - name: "Characteristic (40-48): Odd Hair Color"
    description: "Roll 40-48 or choose. Roll percentile dice again for the colour: 01-10 green, 11-20 light blue, 21-30 white streaked, 31-40 bright flame red, 41-50 stark white, 51-60 bright yellow, 61-70 metallic silver, 71-80 dark blue, 81-90 purple, 91-00 orange."
  - name: "Characteristic (49-53): Double-Jointed"
    description: "Roll 49-53 or choose. Extremely flexible bones. Slips handcuffs, manacles and other bonds: 79% when hands and/or feet are tied with rope, handcuffed or chained, 46% when the whole body is bound with rope, chains, straps or a straitjacket. Can narrow the body to half its width shoulder to shoulder, or curl into a ball 20% of normal height and half normal width. +2 to roll with fall or impact."
    bonuses: { combat: { roll: 2 } }
  - name: "Characteristic (54-58): Unusual Eyes"
    description: "Roll 54-58 or choose. Roll percentile dice again: 01-17 very small (at least twice as small as average), 18-34 round, 35-55 very large (at least twice as large as average), 56-75 odd colour (red, yellow, white and so on), 76-89 very elliptical, 90-00 glowing eyes."
  - name: "Characteristic (59-64): Fur-Covered"
    description: "Roll 59-64 or choose. The race is covered in fur."
  - name: "Characteristic (65-68): Prehensile Feet"
    description: "Roll 65-68 or choose. Prehensile feet and toes like a monkey''s, able to grasp objects and climb. Not developed enough to throw an object or fire a gun (-6 to strike), but they pick up and carry small items, push buttons, pull levers, untie ropes and even work a console, poorly. When barefoot: +30% on climbing rolls, +10% on acrobatic skills and +1 to dodge. Skills such as computer operation or pick pockets done with the feet are at -25%; complicated skills such as mechanics, demolitions and piloting cannot be done with any accuracy (10% is the best possible base proficiency with feet)."
  - name: "Characteristic (69-72): Scaly Skin"
    description: "Roll 69-72 or choose. A tough, smooth, reptilian skin with small scales. Adds 30 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 30 } }
  - name: "Characteristic (73-76): No Body Hair"
    description: "Roll 73-76 or choose. The race has no body hair."
  - name: "Characteristic (77-79): Small Horns"
    description: "Roll 77-79 or choose. Vestigial horns 1D4 inches (1D10 cm) long protruding from the forehead."
  - name: "Characteristic (80-84): Tough, Lumpy Skin"
    description: "Roll 80-84 or choose. Adds 30 S.D.C./M.D.C."
    bonuses: { pools: { sdc: 30 } }
  - name: "Characteristic (85-89): Prehensile Tail"
    description: "Roll 85-89 or choose. An extra appendage, more limited than prehensile feet: it can grasp and carry things or help climb, but cannot untie rope or fire a weapon. +1 to strike and parry with the tail; the tail itself is +5 to dodge; +20% on climbing rolls when the tail is used. Length 3D4 feet (0.9 to 3.7 m); its look follows the race''s overall appearance."
  - name: "Characteristic (90-94): Retractable Claws"
    description: "Roll 90-94 or choose. Claws like a cat''s that add 2D4 S.D.C. to hand to hand damage, or 2D4 M.D. if the race has supernatural P.S."
  - name: "Characteristic (95-00): Stocky"
    description: "Roll 95-00 or choose. Exceptionally broad or husky, about twice as broad as the average humanoid of the same height. Add 50 lbs (23 kg) to weight, +1D4 to P.S. and 4D4 to S.D.C./M.D.C."
    bonuses: { attributes: { PS: "1d4" }, pools: { sdc: "4d4" } }
  - { choose: 1, from: ["Power: None", "Power (01-10): Lesser Psionics", "Power (11-20): Greater Psionics", "Power (21-30): Superhuman Attributes", "Power (31-40): Winged Flight", "Power (41-50): Psionic Flight", "Power (51-60): Energy Attack", "Power (61-70): Giant Size, M.D.C.", "Power (61-70): Giant Size, S.D.C.", "Power (71-90): Resistance to Damage", "Power (91-00): Special"], note: "Step Six: Unusual Powers (printed 106-107), an optional step. Only about 20% of races have unusual powers: the G.M. decides, or roll percentile dice first - 01-20 the race has one, roll or pick here; 21-00 it has none, take None. 61-70 prints an M.D.C. figure and an S.D.C. figure; the choice between them is the G.M.''s. 91-00 (roll twice more) is worked out with the G.M.; this group holds one result." }
  - name: "Power: None"
    description: "First roll 21-00, or the G.M.''s decision: the race has no unusual powers."
  - name: "Power (01-10): Lesser Psionics"
    description: "Roll 01-10 or choose. Six psionic powers, all from ONE of the healing, sensitive or physical categories - keep to a single category. The powers are the same for every member of the race, and no new ones are gained unless a psychic O.C.C. is chosen for the race. I.S.P. is the M.E. attribute number plus 5D6 at first level, plus 1D6 per additional level. Every member of the race is treated as a major psionic for saving throws vs psionic attack."
    psionics: { type: "major", isp_base: "M.E. attribute number plus 5d6, +1d6 per additional level of experience", powers_starting: 6, categories_allowed: ["Healing", "Sensitive", "Physical"] }
  - name: "Power (11-20): Greater Psionics"
    description: "Roll 11-20 or choose. Nine psionic powers from any of the healing, sensitive or physical categories plus two super-psionic powers. They are the same for every member of the race and should follow a pattern (for example all related to telepathy: the sense powers, mind block, hypnotic suggestion and the like). No new powers are gained at higher levels unless a psychic O.C.C. is chosen for the race. I.S.P. is 1D4x10 plus the M.E. attribute number, plus 10 per level. The page names no psionic tier for this row, so the powers and I.S.P. are recorded by hand; see extraction_notes."
  - name: "Power (21-30): Superhuman Attributes"
    description: "Roll 21-30 or choose. Add +12 to any one racial attribute, or +6 to any two, by hand. P.S. excepted, no combination of bonuses that would take an attribute above 30 should be allowed."
  - name: "Power (31-40): Winged Flight"
    description: "Roll 31-40 or choose. The race has wings and can fly. Flying speed is normal running speed plus 2D4x10. The race''s average weight should not exceed 120 lbs (54 kg)."
  - name: "Power (41-50): Psionic Flight"
    description: "Roll 41-50 or choose. The race flies without wings, levitating at high speed by psionic power. Flying speed is 1D6x10 plus the race''s Spd attribute."
  - name: "Power (51-60): Energy Attack"
    description: "Roll 51-60 or choose. The race fires energy blasts, bolts of flame, electrical arcs or some other energy attack. Damage is 1D6 M.D., plus 1D6 M.D. at levels three, six, seven and ten."
  - name: "Power (61-70): Giant Size, M.D.C."
    description: "Roll 61-70 or choose, for an M.D.C. race. At least twice the galactic average of 5 to 7 feet: add 4D6 feet to height (minimum average height 12 feet / 3.7 m) and 2D4x100+100 lbs to weight. A bonus of 100+2D6x10 M.D.C. (it lands only on a character who already has an M.D.C. pool; otherwise enter it by hand), and P.S. is increased by 1D6."
    bonuses: { attributes: { PS: "1d6" }, pools: { mdc: "2d6x10+100" } }
  - name: "Power (61-70): Giant Size, S.D.C."
    description: "Roll 61-70 or choose, for an S.D.C. race. At least twice the galactic average of 5 to 7 feet: add 4D6 feet to height (minimum average height 12 feet / 3.7 m) and 2D4x100+100 lbs to weight. A bonus of 1D4x100+400 S.D.C., and P.S. is increased by 1D6."
    bonuses: { attributes: { PS: "1d6" }, pools: { sdc: "1d4x100+400" } }
  - name: "Power (71-90): Resistance to Damage"
    description: "Roll 71-90 or choose. Resistant to one particular form of damage (energy, physical attacks, fire/heat, magic and so on): one quarter damage from those attacks and half damage from related ones - a race impervious or resistant to normal fire and heat takes half damage from magic fires."
  - name: "Power (91-00): Special"
    description: "Roll 91-00 or choose. Roll twice on the table, re-rolling repeats, or pick two different powers. This entry holds neither: settle the two with the G.M. and note them on the sheet."
  - { choose: 1, from: ["Technology (01-20): Stone Age Primitives", "Technology (21-30): Metal Users, Pre-Industrial Age", "Technology (31-40): Industrial Age, Pre-Space Age", "Technology (41-60): Atomic Age, Early Space Age", "Technology (61-75): Mature Space Age", "Technology (76-90): Advanced Space Age", "Technology (91-98): Highly Advanced Civilization", "Technology (99-00): Amazing Civilization"], note: "Step Seven: Technological Level (printed 107), rolled once or picked. It is the level of the most advanced nation or culture on the homeworld. Coming from a primitive race does not bar a character from tech skills, provided the training is explained in the character''s story." }
  - name: "Technology (01-20): Stone Age Primitives"
    description: "Roll 01-20 or choose. Only very simple tools (sticks, stone axes); the wheel may or may not have been discovered. Mostly nomadic hunter-gatherers or, at best, early farming settlements."
  - name: "Technology (21-30): Metal Users, Pre-Industrial Age"
    description: "Roll 21-30 or choose. Anything between Earth''s Bronze Age and its Renaissance: metal working, stone buildings and, at the highest levels, crude firearms."
  - name: "Technology (31-40): Industrial Age, Pre-Space Age"
    description: "Roll 31-40 or choose. Gunpowder weapons and explosives, sophisticated metallurgy, machinery - the equivalent of Earth''s 19th century to the first half of the 20th. Railroads, steam ships, early combustion engines and even airships and early prop airplanes, but no way to travel beyond the planet''s atmosphere."
  - name: "Technology (41-60): Atomic Age, Early Space Age"
    description: "Roll 41-60 or choose. The equivalent of late 20th and probably early 21st century Earth: atomic power and weapons, crude spaceships and satellites able to reach other planets of the home system. No faster-than-light ships."
  - name: "Technology (61-75): Mature Space Age"
    description: "Roll 61-75 or choose. Sophisticated robots and computers, self-sustaining space stations, relatively easy sublight travel and true starships. Rifts Earth fits here. Past this level advancement levels off: this culture''s combat robot or vehicle is second rate beside a higher-tech one, but not completely outmatched."
  - name: "Technology (76-90): Advanced Space Age"
    description: "Roll 76-90 or choose. Faster-than-light travel, usually by gravitonic drives, and the exploration of other stars. The largest civilizations of the Three Galaxies are all at this level."
  - name: "Technology (91-98): Highly Advanced Civilization"
    description: "Roll 91-98 or choose. Beyond the average technological limits in one field of knowledge, the G.M.''s choice (space drive, weapons technology, robotics, bionics and so on). The race''s culture should explain why it is not yet an important player in galactic politics."
  - name: "Technology (99-00): Amazing Civilization"
    description: "Roll 99-00 or choose. An ultra-tech race clearly superior to every known galactic culture, perhaps from a far-off galaxy or another dimension. The G.M. designs its technology; the book''s weapons and equipment can be modified by raising M.D.C., damage, overall performance and/or range by 20 to 60%."
  - { choose: 1, from: ["Magic (01-60): No Magic", "Magic (61-70): Limited Magic", "Magic (71-94): Magic-Using Culture", "Magic (95-00): Superhuman Magical Capabilities"], note: "Step Eight: Magical Level (printed 107-108), rolled once or picked. It describes the race''s magical knowledge and potential; the page prints no spells or P.P.E. for any row." }
  - name: "Magic (01-60): No Magic"
    description: "Roll 01-60 or choose. The race does not practice magic, either because it has no magical potential whatsoever (printed as 1-30) or because it does not know of or believe in magic (31-00), in which case a member could learn it from a teacher. The page prints the two as sub-cases and gives no instruction to roll again."
  - name: "Magic (61-70): Limited Magic"
    description: "Roll 61-70 or choose. Magic-capable, but only a small percentage of the population, or a few nations or subcultures, know how to use it. Wizards, magic items and techno-wizardry are very rare, expensive and out of reach of the population at large."
  - name: "Magic (71-94): Magic-Using Culture"
    description: "Roll 71-94 or choose. Magic is an important part of life for the whole race: every village, tribe or clan has at least one or two powerful shamans or mages, and magic items and techno-wizardry are common and widely applied. The race may achieve things far beyond its mundane technology."
  - name: "Magic (95-00): Superhuman Magical Capabilities"
    description: "Roll 95-00 or choose. The entire race is mage-capable, with the abilities of a mystic or ley line walker, or of a magical O.C.C. of the G.M.''s choice; take that O.C.C. for the character with the G.M.''s agreement. Conventional science and technology are likely to be at low levels."
  - { choose: 1, from: ["Culture (01-10): Genocidal Xenophobes", "Culture (11-25): Aggressive Racial Supremacists", "Culture (26-40): Warrior Race", "Culture (41-55): Enlightened Imperialists", "Culture (56-70): Peaceful Expansionists", "Culture (71-85): Non-Interventionists", "Culture (86-00): Pacifists"], note: "Step Nine: General Attitude/Culture (printed 108), rolled once or picked. It is the outlook of the race''s dominant culture, not the alignment of any one member." }
  - name: "Culture (01-10): Genocidal Xenophobes"
    description: "Roll 01-10 or choose. Roughly equivalent to diabolic. Every other species is a mortal enemy to be destroyed, or deceived and manipulated into harming itself. Few such races last long: their neighbours unite to destroy or conquer them."
  - name: "Culture (11-25): Aggressive Racial Supremacists"
    description: "Roll 11-25 or choose. Roughly equivalent to miscreant or aberrant. The race holds itself superior to all others and means to dominate them, usually by enslaving or subjugating them, turning to diplomacy only when it is too weak to use force. It keeps an agreement while watched or while the agreement serves it."
  - name: "Culture (26-40): Warrior Race"
    description: "Roll 26-40 or choose. Typically anarchist or aberrant, but can be any alignment. Values combat prowess and is very aggressive, but has a sense of honour: it keeps treaties even against its interests and gives its word rarely, and it goes to war readily at any sign of treachery."
  - name: "Culture (41-55): Enlightened Imperialists"
    description: "Roll 41-55 or choose. The race wishes to expand and grow and may use violence to do it, but prefers diplomacy and economic and cultural dominance to outright conquest."
  - name: "Culture (56-70): Peaceful Expansionists"
    description: "Roll 56-70 or choose. The race wishes to expand and grow but will never attack or settle on an inhabited planet; it goes only to uninhabited worlds and fights only in self-defense."
  - name: "Culture (71-85): Non-Interventionists"
    description: "Roll 71-85 or choose. As the Peaceful Expansionists, but the race prefers not to get involved in the affairs of other peoples."
  - name: "Culture (86-00): Pacifists"
    description: "Roll 86-00 or choose. The race as a whole, though perhaps not every individual, holds violence wrong under any circumstances. When diplomacy fails it tries to escape its enemies or resists passively rather than defend itself actively."
extraction_notes: "NEW CLASS, written 2026-10-05 from 200 dpi renders of Phase World printed 104-108 (cache p104-p108, page_offset 0); every figure was read off the renders. The book prints this as Creating More Alien Races, a nine-step generator for a whole RACE that a G.M. uses or lets a player use; the survey listed it as a generator, not a class, and Nate ruled it is imported as a class whose steps are pick groups, after the Heroes Unlimited alien (hu-aliens). men_of_arms is false because this is a race. ATTRIBUTES: printed 104 says the character starts with base attributes of 3D6 and all bonuses are added to that base, so attribute_dice holds 3D6 for all eight; that is also the 21-50 Galactic Average row. Step One 01-20 prints 2D4 on EITHER three mental OR three physical attributes: stored as two options sharing the band; the mental one sets I.Q., M.E. and M.A. to 2D4, which is a reading, since the page says three mental attributes without naming them, and the physical one stays prose because the page does not say which three of the five physical attributes. Rows 51-60 to 91-00 add dice to ANY three or four attributes and stay prose; the one figure stored is 91-00''s 2D6+10 to P.S.; the page prints 2D6+10 to P.S. and Spd or P.B. once, and whether Spd or P.B. takes the same roll or a second one is not printed. DAMAGE CAPACITY: the page prints 41-50 and 51-60 as plain S.D.C. figures, without saying whether they replace or add to S.D.C. determined normally, and 71-80, 81-90 and 91-00 as a Base M.D.C. (1D6x10, 3D6x10, 2D6x100); the two S.D.C. rows are stored as pool bonuses, which add to the S.D.C. every character has. The four M.D.C. rows - 61-70 (base M.D.C. equal to P.E. plus 1D6 per level) with the three above - each state mdc_base on the option, with the printed per-level gain (1D6, 2D4, 2D6, 1D4x10) in the same formula, since 2026-10-13 (BOOK-INGEST-AUDIT.md F128, branch pal/data/book-ingest-audit-f128-two-classes); until then the three were pool bonuses on no base, which added nothing, and 61-70 was prose. Still prose: the halving of every later bonus under 61-70. Giant Size''s M.D.C. option (Step Six) is still a pool bonus and lands only on a race given an M.D.C. row. No mdc_base is stated on the class because the page gives M.D.C. to four rows of seven. S.D.C./M.D.C.: printed 104 says most bonuses carry an S.D.C./M.D.C. option, leaving the G.M. a choice between the two; only Step Two''s own rows tie the appearance and physiological bonuses (Steps Three and Four) to its result, and Steps Five and Six are never tied to it. Every such figure in Steps Three, Four and Five is stored as an S.D.C. pool bonus and the group notes say so. Step Six 61-70 Giant Size prints two different figures (100+2D6x10 M.D.C. or 1D4x100+400 S.D.C.) and is stored as two options sharing the band. STEPS FOUR, FIVE AND SIX each sit behind a condition: Four behind a first roll (01-65 Earth-like, no modifications), Five is for humanoid but not human-like races, Six is optional with a first roll (01-20 has powers). Each group carries one option with no band for the result where the table is not used. SUB-TABLES (odd skin colour, odd hair colour, unusual eyes, and the two sub-cases of No Magic) are in the row descriptions. PSIONICS: the Lesser Psionics row carries a psionics block: six powers, Healing, Sensitive and Physical allowed, tier major because the page says its members are considered major psionics for saving throws. psionics_allowed is not stated, because the pages never mention the standard psionics roll. The page limits the six to ONE of the three categories, which is stated in the description. The Greater Psionics row (nine from the three categories plus two super, I.S.P. 1D4x10 plus M.E. plus 10 per level) prints no tier and carries no block. CONDITIONAL NUMBERS left in prose: Double-Jointed''s +2 to roll is stored; Prehensile Feet''s +1 dodge (barefoot), the Prehensile Tail''s strike, parry and dodge (with the tail), Retractable Claws'' damage, the Twilight World''s -8 while blinded and the Frozen Planet''s exposure penalties are not. Speed multipliers (High Gravity x3, Low Gravity half) are prose. NO SKILLS, NO EXPERIENCE TABLE AND NO MONEY are stored: the pages print none and name none, and refer to an O.C.C. chosen for the race. Steps Seven, Eight and Nine print no numbers and are stored as pick groups so the race''s technology, magic and culture are on the sheet."
---

## Lore

The Three Galaxies hold thousands of alien peoples, far more than any book
could list. This entry is for one of the unlisted ones: a race built step by
step with the G.M., who has the last word on what exists in the campaign.

Nine steps describe the whole race rather than one person: how gifted its
people are, how much punishment their bodies take, what they look like, what
their homeworld did to them, any odd feature or power they share, and how far
their technology, magic and culture have come. Each step is a table that can
be rolled or simply chosen.

## GM Notes

The tables are guidelines, not rules. The G.M. may pick results, roll them,
invent others, or set the race''s attributes outright by comparison with other
non-human races. Most races in the book itself were not made with these
tables.

**Added by hand.** Step One''s bonuses to "any three" or "any four" attributes,
and the Spd or P.B. part of the 91-00 row, are for the builder to place. The
Minor M.D.C. Being''s halved bonuses, speed multipliers and flying speeds are
worked out at the table.

**S.D.C. or M.D.C.** Printed 104 says most bonuses carry an S.D.C./M.D.C.
option and leaves the choice to the G.M. Step Two''s own rows say which the
appearance and physiological bonuses (Steps Three and Four) are; the page does
not tie Steps Five and Six to it. Every "S.D.C./M.D.C." figure is stored as
S.D.C.: where it is M.D.C., move those points by hand (appearance and
physiological bonuses are halved for the Minor M.D.C. Being). The M.D.C. rows
also make P.S. and P.E. supernatural, except the Minor one.

**Steps that may not apply.** Step Four is rolled only on a first roll of
66-00, Step Five only for humanoid races that are not human-like, and Step Six
only on a first roll of 01-20 or the G.M.''s say-so. Each has a "none" choice.

**Step Six, 91-00** gives two powers, and **Greater Psionics** gives nine
powers plus two super-psionic powers with I.S.P. of 1D4x10 plus M.E. and 10
per level; neither is applied automatically.

**Percentage chances inside a row** - the radiating High Radiation race
(01-50%), the Frozen Planet race that cannot bear warmth (01-70%), the Thermo
World race that cannot bear cold (01-80%) - are in the row descriptions and
are not applied.

**Step Eight** prints no spells or P.P.E. for any row. A race of Superhuman Magical
Capabilities is mage-capable with the abilities of a mystic or ley line
walker, or another magical O.C.C. of the G.M.''s choice.
',
       updated_at = datetime('now')
 WHERE class_id = 'phase-world-alien'
   AND instr(markdown, 'so this pick adds NOTHING by itself') > 0
   AND length(markdown) = 39562;

-- == gene-splicer-mutant ==
UPDATE imported_classes
   SET markdown = '---
id: gene-splicer-mutant
name: Gene-Splicer Mutant
system: rifts
source_book: Rifts World Book 7: Underseas p.38-40
category: rcc
tags: [aquatic]
men_of_arms: false
mdc_base: "0"
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
restrictions:
  - "THIS CREATURE IS ROLLED, NOT READ OFF A STAT BLOCK. Printed 39-40 give eight percentile tables and the instruction to roll once on each; they are the eight pick groups below, in the book''s order. The page says only to roll once on each and prints nothing about choosing; being able to pick a row is the wizard''s allowance, not the book''s."
  - "THE BOOK PRINTS NO ATTRIBUTE DICE EXCEPT I.Q. The Intelligence & Aggression table sets I.Q.; M.E., M.A., P.S., P.P., P.E., P.B. and Spd are printed nowhere on printed 38-40. The G.M. sets them, from the animal the body is built on or as he sees fit. Until he does, the sheet''s default dice stand for those seven and they are NOT the book''s."
  - "M.D.C. comes from the Body table alone (and the Too Big! defect adds to it). Printed 39 says every one of these creatures is a mega-damage creature. Each Body row states its printed M.D.C. as the creature''s M.D.C. base, and Too Big! adds to that (BOOK-INGEST-AUDIT.md F128). The class itself states an M.D.C. base of zero, which no page prints: a Body row replaces it, and it is left only for the Other row, which prints no M.D.C. at all, so that creature is still a mega-damage being whose M.D.C. the G.M. sets."
  - "ATTACKS PER MELEE come from the Body row. A row printing two attacks stores nothing, a row printing three stores one extra and the Manta Ray''s single attack stores one fewer, so the sheet''s total is the row''s number before appendages. The book prints no hand to hand skill for the creature."
  - "Type of Head is rolled once FOR EACH HEAD when the Number of Heads table gives more than one (printed 39). The group holds one pick; note the other heads by hand."
  - "No alignment, no skills, no O.C.C. rule, no P.P.E., no Horror Factor, no equipment, no money and no life span are printed for the gene-splicer mutant. None is stored. Printed 214 gives it an experience ladder and so makes it playable; everything else is the G.M.''s to rule."
  - "Size, where a Body row prints one, is in that row''s description. Most are far larger than a human."
special_abilities:
  - { choose: 1, from: ["Body (01-10): Sea Snake, Oarfish or Eel", "Body (11-20): Large Fish", "Body (21-30): Humanoid/Bipedal", "Body (31-40): Tiger or Great White Shark", "Body (41-50): Dolphin or Porpoise", "Body (51-55): Giant Squid or Octopus", "Body (56-60): Manta Ray", "Body (61-65): Lobster or Crab", "Body (66-70): Crocodile", "Body (71-75): Sea Lion or Walrus", "Body (76-84): Sea Turtle", "Body (85-90): Aquatic Bird", "Body (91-95): Sea Horse", "Body (96-00): Other"], note: "Random Body Type/Appearance (printed 39), rolled once. Every body breathes underwater and has the senses of its kind, is a mega-damage creature, and is full-size to giant-size." }
  - name: "Body (01-10): Sea Snake, Oarfish or Eel"
    description: "Roll 01-10 or choose. M.D.C. 1D6x10. Size: 15-20 feet (4.6-6.1 m) long. Two attacks per melee round and +2 to dodge."
    bonuses: { combat: { dodge: 2 } }
    mdc_base: "1d6x10"
  - name: "Body (11-20): Large Fish"
    description: "Roll 11-20 or choose. A fish like a tuna, mackerel, sailfish or swordfish. M.D.C. 2D4x10. Size: 4+1D4 feet (1.2 to 2.4 m) long. Two attacks per melee round and +2 to dodge."
    bonuses: { combat: { dodge: 2 } }
    mdc_base: "2d4x10"
  - name: "Body (21-30): Humanoid/Bipedal"
    description: "Roll 21-30 or choose. Two legs, feet, arms and hands. M.D.C. 3D4x10. Size: 6 feet (1.8 m) tall. Three attacks per melee round, +1 to strike and +2 to parry."
    bonuses: { combat: { attacks: 1, strike: 1, parry: 2 } }
    mdc_base: "3d4x10"
  - name: "Body (31-40): Tiger or Great White Shark"
    description: "Roll 31-40 or choose. M.D.C. 5D6x10. Size: 20-30 feet (6-9 m). Two attacks per melee round and +2 to strike and dodge."
    bonuses: { combat: { strike: 2, dodge: 2 } }
    mdc_base: "5d6x10"
  - name: "Body (41-50): Dolphin or Porpoise"
    description: "Roll 41-50 or choose. M.D.C. 3D4x10. Size: 7-11 feet (2.1-3.3 m) long. Two attacks per melee round and +2 to parry and dodge."
    bonuses: { combat: { parry: 2, dodge: 2 } }
    mdc_base: "3d4x10"
  - name: "Body (51-55): Giant Squid or Octopus"
    description: "Roll 51-55 or choose. M.D.C. 4D4x10. Size: 40-50 feet (12.2-15.5 m). Three attacks per melee round and +8 to parry."
    bonuses: { combat: { attacks: 1, parry: 8 } }
    mdc_base: "4d4x10"
  - name: "Body (56-60): Manta Ray"
    description: "Roll 56-60 or choose. M.D.C. 2D4x10. Size: 10-15 feet (3-4.6 m). One attack per melee round."
    bonuses: { combat: { attacks: -1 } }
    mdc_base: "2d4x10"
  - name: "Body (61-65): Lobster or Crab"
    description: "Roll 61-65 or choose. M.D.C. 4D6x10. Size: 3-5 feet (0.9-1.5 m) long. Three attacks per melee round and +4 to strike, parry and dodge."
    bonuses: { combat: { attacks: 1, strike: 4, parry: 4, dodge: 4 } }
    mdc_base: "4d6x10"
  - name: "Body (66-70): Crocodile"
    description: "Roll 66-70 or choose. M.D.C. 4D6x10. Size: 20 feet (6.1 m). Two attacks per melee round and +1 to strike."
    bonuses: { combat: { strike: 1 } }
    mdc_base: "4d6x10"
  - name: "Body (71-75): Sea Lion or Walrus"
    description: "Roll 71-75 or choose. M.D.C. 2D4x100 - the one row printed in hundreds. Size: 12-15 feet (3.6 to 4.6 m). Two attacks per melee round and +1 to strike."
    bonuses: { combat: { strike: 1 } }
    mdc_base: "2d4x100"
  - name: "Body (76-84): Sea Turtle"
    description: "Roll 76-84 or choose. M.D.C. 3D6x10. Size: 6 feet (1.8 m). Two attacks per melee round."
    mdc_base: "3d6x10"
  - name: "Body (85-90): Aquatic Bird"
    description: "Roll 85-90 or choose. M.D.C. 1D6x10. Size: 5 feet (1.5 m) long. Two attacks per melee round and +1 to strike."
    bonuses: { combat: { strike: 1 } }
    mdc_base: "1d6x10"
  - name: "Body (91-95): Sea Horse"
    description: "Roll 91-95 or choose. M.D.C. 1D6x10. Size: 6 feet (1.8 m) long. Two attacks per melee round and +2 to dodge."
    bonuses: { combat: { dodge: 2 } }
    mdc_base: "1d6x10"
  - name: "Body (96-00): Other"
    description: "Roll 96-00 or choose. The G.M.''s choice of any kind of strange critter: polar bear, sea lamprey, whale, deep-sea fish, alien animal, or an aquatic or surface D-bee. The row prints NO M.D.C., size, attacks or bonuses - the G.M. sets them all, and nothing is stored."
  - { choose: 1, from: ["Heads (01-60): One", "Heads (61-80): Two", "Heads (81-90): Three", "Heads (91-00): Four"], note: "Number of heads (printed 39), rolled once." }
  - name: "Heads (01-60): One"
    description: "Roll 01-60 or choose. One head."
  - name: "Heads (61-80): Two"
    description: "Roll 61-80 or choose. Two heads. Roll Type of Head once for each."
  - name: "Heads (81-90): Three"
    description: "Roll 81-90 or choose. Three heads. Roll Type of Head once for each."
  - name: "Heads (91-00): Four"
    description: "Roll 91-00 or choose. Four heads. Roll Type of Head once for each."
  - { choose: 1, from: ["Head Type (01-35): Same as the Natural Animal", "Head Type (36-40): Fish", "Head Type (41-45): Tiger or Great White Shark", "Head Type (46-50): Squid or Octopus", "Head Type (51-55): Lobster or Shrimp", "Head Type (56-60): Turtle", "Head Type (61-65): Sea Horse", "Head Type (66-70): Crocodile", "Head Type (71-75): Eel or Lamprey", "Head Type (76-80): Sea Lion or Walrus", "Head Type (81-85): Hammerhead Shark", "Head Type (86-90): Dolphin or Beaked Whale", "Head Type (91-95): Human", "Head Type (96-00): Other"], note: "Type of Head (printed 39). The book rolls it once FOR EACH HEAD; this group holds the first head, and a creature with two, three or four heads rolls the rest by hand. No row prints a number." }
  - name: "Head Type (01-35): Same as the Natural Animal"
    description: "Roll 01-35 or choose. The head is that of the animal the body came from."
  - name: "Head Type (36-40): Fish"
    description: "Roll 36-40 or choose. A fish''s head."
  - name: "Head Type (41-45): Tiger or Great White Shark"
    description: "Roll 41-45 or choose. The head of a tiger shark or great white shark."
  - name: "Head Type (46-50): Squid or Octopus"
    description: "Roll 46-50 or choose. The head of a squid or octopus."
  - name: "Head Type (51-55): Lobster or Shrimp"
    description: "Roll 51-55 or choose. The head of a lobster or shrimp."
  - name: "Head Type (56-60): Turtle"
    description: "Roll 56-60 or choose. A turtle''s head."
  - name: "Head Type (61-65): Sea Horse"
    description: "Roll 61-65 or choose. A sea horse''s head."
  - name: "Head Type (66-70): Crocodile"
    description: "Roll 66-70 or choose. A crocodile''s head."
  - name: "Head Type (71-75): Eel or Lamprey"
    description: "Roll 71-75 or choose. The head of an eel or lamprey."
  - name: "Head Type (76-80): Sea Lion or Walrus"
    description: "Roll 76-80 or choose. The head of a sea lion or walrus."
  - name: "Head Type (81-85): Hammerhead Shark"
    description: "Roll 81-85 or choose. A hammerhead shark''s head."
  - name: "Head Type (86-90): Dolphin or Beaked Whale"
    description: "Roll 86-90 or choose. The head of a dolphin or beaked whale."
  - name: "Head Type (91-95): Human"
    description: "Roll 91-95 or choose. A human head: a 50% chance it looks normal and a 50% chance it looks monstrous."
  - name: "Head Type (96-00): Other"
    description: "Roll 96-00 or choose. The G.M.''s choice of any kind of strange critter: polar bear, penguin, whale, deep-sea fish, alien animal, or an aquatic or surface D-bee."
  - { choose: 1, from: ["Intelligence (01-20): Human, Curious", "Intelligence (21-40): Human, Cruel Predator", "Intelligence (41-60): Human, Opportunist Predator", "Intelligence (61-80): High Animal", "Intelligence (81-00): Low Animal"], note: "Intelligence & Aggression (printed 39), rolled once. Each row sets the I.Q. dice - the only attribute dice the book prints for this creature." }
  - name: "Intelligence (01-20): Human, Curious"
    description: "Roll 01-20 or choose. I.Q. 1D6+10, human intelligence. Curious and resourceful and not particularly aggressive, much like a dolphin. Eats fish, crustaceans and invertebrates."
    attribute_dice: { IQ: "1d6+10" }
  - name: "Intelligence (21-40): Human, Cruel Predator"
    description: "Roll 21-40 or choose. I.Q. 1D4+10, human intelligence. A very aggressive and cruel predator that kills humanoids, mammals and fish for pleasure as well as for food."
    attribute_dice: { IQ: "1d4+10" }
  - name: "Intelligence (41-60): Human, Opportunist Predator"
    description: "Roll 41-60 or choose. I.Q. 2D4, which the book still calls human intelligence. A predator always looking for easy prey, humanoids and sick or weak animals included."
    attribute_dice: { IQ: "2d4" }
  - name: "Intelligence (61-80): High Animal"
    description: "Roll 61-80 or choose. I.Q. 1D6+8, high animal intelligence. A ruthless predator."
    attribute_dice: { IQ: "1d6+8" }
  - name: "Intelligence (81-00): Low Animal"
    description: "Roll 81-00 or choose. I.Q. 1D4, low animal intelligence. Works on instinct and brute strength; otherwise dull witted. May try to eat just about anything, but gives up on prey that is too big or fights too hard."
    attribute_dice: { IQ: "1d4" }
  - { choose: 1, from: ["Depth (01-10): 500 Feet", "Depth (11-20): 1000 Feet", "Depth (21-30): 2000 Feet", "Depth (31-50): 4000 Feet", "Depth (51-70): 1 Mile", "Depth (71-80): 2 Miles", "Depth (81-90): 3 Miles", "Depth (91-00): Unlimited"], note: "Depth Tolerance (printed 39), rolled once. It may be greater or less than the original creature''s." }
  - name: "Depth (01-10): 500 Feet"
    description: "Roll 01-10 or choose. Depth tolerance 500 feet (152 m)."
  - name: "Depth (11-20): 1000 Feet"
    description: "Roll 11-20 or choose. Depth tolerance 1000 feet (305 m)."
  - name: "Depth (21-30): 2000 Feet"
    description: "Roll 21-30 or choose. Depth tolerance 2000 feet (610 m)."
  - name: "Depth (31-50): 4000 Feet"
    description: "Roll 31-50 or choose. Depth tolerance 4000 feet (1220 m)."
  - name: "Depth (51-70): 1 Mile"
    description: "Roll 51-70 or choose. Depth tolerance 1 mile (1.6 km)."
  - name: "Depth (71-80): 2 Miles"
    description: "Roll 71-80 or choose. Depth tolerance 2 miles (3.2 km)."
  - name: "Depth (81-90): 3 Miles"
    description: "Roll 81-90 or choose. Depth tolerance 3 miles (4.8 km)."
  - name: "Depth (91-00): Unlimited"
    description: "Roll 91-00 or choose. No depth limit at all."
  - { choose: 1, from: ["Appendage (01-20): Tentacles", "Appendage (21-40): Clawed Arms", "Appendage (41-50): Spiked Prehensile Tail", "Appendage (51-60): Rhino-Like Horns", "Appendage (61-71): Crab Claws", "Appendage (72-80): Fish Tail or Extra Fins", "Appendage (81-90): Chemoreceptor Antennae", "Appendage (91-00): Giant Maw with Tentacle Tongues"], note: "Additional appendages (printed 39-40), rolled once. All are proportional to the size of the creature. The bands 61-71 and 72-80 are as printed." }
  - name: "Appendage (01-20): Tentacles"
    description: "Roll 01-20 or choose. 1D6 tentacles. Each PAIR adds one attack per melee round, +1 on initiative and +1 to parry. The numbers depend on the count rolled, so they are added by hand and nothing is stored."
  - name: "Appendage (21-40): Clawed Arms"
    description: "Roll 21-40 or choose. Two arms with clawed hands and webbed fingers - an extra pair on a humanoid. The row prints no damage and no bonus."
  - name: "Appendage (41-50): Spiked Prehensile Tail"
    description: "Roll 41-50 or choose. A spiked, prehensile tail at least half the length of the body. It does 2D6 M.D. and gives +1 to parry."
    bonuses: { combat: { parry: 1 } }
  - name: "Appendage (51-60): Rhino-Like Horns"
    description: "Roll 51-60 or choose. 1D4 rhino-like horns for stabbing and impaling, each doing 1D6 M.D."
  - name: "Appendage (61-71): Crab Claws"
    description: "Roll 61-71 or choose. A pair of crab claws doing 3D6 M.D. per strike. Adds one attack per melee round and +2 to parry."
    bonuses: { combat: { attacks: 1, parry: 2 } }
  - name: "Appendage (72-80): Fish Tail or Extra Fins"
    description: "Roll 72-80 or choose. A fish tail or extra fins that add to manoeuvrability underwater; +1 to dodge and +12 to the creature''s normal Spd attribute. The page sets both numbers beside ''underwater''; they are stored unconditionally because this is an aquatic creature, and a G.M. may limit them to the water."
    bonuses: { attributes: { Spd: 12 }, combat: { dodge: 1 } }
  - name: "Appendage (81-90): Chemoreceptor Antennae"
    description: "Roll 81-90 or choose. 1D4 antennae that sense minute changes in the salinity and chemistry of the water, so the creature can taste oil, fuel, sulfur and nitrates from explosions, pollution, and blood. Identify chemicals by taste 68%; track by taste 64%. Range: one mile (1.6 km)."
  - name: "Appendage (91-00): Giant Maw with Tentacle Tongues"
    description: "Roll 91-00 or choose. A giant maw with 1D6 tentacle-like tongues, used to swallow prey whole. Each PAIR of tongues adds one attack per melee and +1 to strike. The numbers depend on the count rolled, so they are added by hand and nothing is stored."
  - { choose: 1, from: ["Feature (01-10): Ley Line Power", "Feature (11-20): Silent", "Feature (21-30): Teeth", "Feature (31-40): Sonic Blast", "Feature (41-50): Incredible Underwater Speed", "Feature (51-60): Regeneration", "Feature (61-70): Turn Invisible and See the Invisible", "Feature (71-80): Echo-Location", "Feature (81-90): Psionic Empathy", "Feature (91-00): Super Regeneration"], note: "Additional Features & Abilities (printed 40), rolled once." }
  - name: "Feature (01-10): Ley Line Power"
    description: "Roll 01-10 or choose. Has the ley line charging ability, the same as the dolphin''s (Dolphin R.C.C., printed 77-80)."
  - name: "Feature (11-20): Silent"
    description: "Roll 11-20 or choose. Prowl at 80% and +2 on initiative. A sneak attack is a critical strike, doing double damage."
    bonuses: { combat: { initiative: 2 } }
  - name: "Feature (21-30): Teeth"
    description: "Roll 21-30 or choose. Every head''s mouth is filled with razor sharp, shark-like teeth and the bite does 2D4 M.D. If the creature has naturally sharp teeth already, they are extra large and do 3D6 M.D."
  - name: "Feature (31-40): Sonic Blast"
    description: "Roll 31-40 or choose. A sonic attack doing 4D6 M.D. underwater or 1D6 M.D. above water. Range is printed as 120 feet (366 m). Usable only once per melee, but it counts as an extra melee attack - an attack that can only be the blast, so it is not added to the attack count."
  - name: "Feature (41-50): Incredible Underwater Speed"
    description: "Roll 41-50 or choose. Up to 120 mph (192 kmph; 103 knots) underwater and on the surface of the water."
  - name: "Feature (51-60): Regeneration"
    description: "Roll 51-60 or choose. Regenerates 3D6 M.D.C. per melee round."
  - name: "Feature (61-70): Turn Invisible and See the Invisible"
    description: "Roll 61-70 or choose. Turns itself invisible and sees the invisible at will - basically the same as the spells, but with no limit on duration or on how often the powers can be used."
  - name: "Feature (71-80): Echo-Location"
    description: "Roll 71-80 or choose. Echo-location, the same as the dolphin''s (Dolphin R.C.C., printed 77-80)."
  - name: "Feature (81-90): Psionic Empathy"
    description: "Roll 81-90 or choose. Telepathy, empathy and empathic transmission. I.S.P. 3D4x10 points; the creature is equal to a third level psychic, with double the normal range. The stored type of minor is the catalog''s choice, because the page names no class of psychic."
    psionics: { type: "minor", isp_base: "3d4x10", powers: ["Telepathy", "Empathy", "Empathic Transmission"] }
  - name: "Feature (91-00): Super Regeneration"
    description: "Roll 91-00 or choose. Regenerates 1D4x10 M.D.C. per melee round, and grows back severed limbs and appendages within 3D4 days."
  - { choose: 1, from: ["Defect (01-10): Insatiable Hunger", "Defect (11-20): Magic", "Defect (21-30): Garbage Eater", "Defect (31-40): Bad Luck Aura", "Defect (41-50): Obsessive Imprint", "Defect (51-60): Energy Sponge", "Defect (61-70): Too Big! And Growing", "Defect (71-80): Spasmatic Shape-Changer", "Defect (81-90): Stinks!!", "Defect (91-00): Psychopathic Killer"], note: "Genetic Defect Table (printed 40), rolled once. The defect is likely to be at least one of the reasons the creature was dumped." }
  - name: "Defect (01-10): Insatiable Hunger"
    description: "Roll 01-10 or choose. Must eat ten times its normal body weight in food to survive. Very aggressive; +1 on initiative."
    bonuses: { combat: { initiative: 1 } }
  - name: "Defect (11-20): Magic"
    description: "Roll 11-20 or choose. Select 1D6 Ocean magic spells. The creature casts them at random moments - usually when hunting, fighting or cornered, but at almost any time the G.M. fairly chooses - and each casting is at a strength of 1D6 levels, rolled when it goes off. The creature tends to be jumpy and unstable. The spells are a rolled count and are not stored; choose them by hand from the book''s Ocean Magic list (printed 63)."
  - name: "Defect (21-30): Garbage Eater"
    description: "Roll 21-30 or choose. Can metabolize almost anything as food - organic matter fresh or spoiled, bone, teeth, plants, leather, rubber, plastic, cloth and paper - but not gems, stone, clay, metal, ceramic compounds or electronics. It has a knack for finding and eating the most valuable item first, and must eat the equivalent of its own body weight every day."
  - name: "Defect (31-40): Bad Luck Aura"
    description: "Roll 31-40 or choose. Anyone within twenty feet is -2 on all die rolls, and stays so for 2D4 hours after the creature leaves the area; twice as long for anyone who actually touched it. Anyone who eats part of the creature is -2 on all die rolls for the next 1D6 days."
  - name: "Defect (41-50): Obsessive Imprint"
    description: "Roll 41-50 or choose. The creature imprints on one person and follows and watches him or her for 3D6 months, then chooses again - possibly the same person, more likely a new one. It neither attacks nor defends the object of its attention, though it may leave small, worthless and smelly gifts. Being noisy, big and in the way, it makes the person followed -30% to prowl and -2 on initiative. Attacked or threatened, it defends itself fiercely, even against the one it follows."
  - name: "Defect (51-60): Energy Sponge"
    description: "Roll 51-60 or choose. Fairly harmless in the wild, but its body soaks up energy and disrupts electrical devices. Clinging to a submarine or boat it makes the lights flicker, garbles radio, cuts the range of radios and sensors by 50%, and drops the vessel''s overall power by 20% and then by a further 1% an hour until it is chased off. It is impervious to electrical energy and takes half damage from most other energy, plasma and magic included; explosives and projectiles do full damage."
  - name: "Defect (61-70): Too Big! And Growing"
    description: "Roll 61-70 or choose. 2D4x10% bigger and heavier than normal. Adds 2D4x10 to M.D.C. but halves normal speed, and it eats twice as much as normal. It grows a further 10% for 2D6 months. The halved speed is applied by hand."
    bonuses: { pools: { mdc: "2d4x10" } }
  - name: "Defect (71-80): Spasmatic Shape-Changer"
    description: "Roll 71-80 or choose. Every four hours the creature metamorphoses into a variation of itself: it shrinks or grows 1D4x10%, breaks out in blotches or boils, changes colour, gains or loses spines, its teeth grow or shrink 100%, and mucus or slime runs from nose, eyes or mouth. The change takes one minute and is ugly enough that those watching must save versus Horror Factor 16. Each transformation is unique."
  - name: "Defect (81-90): Stinks!!"
    description: "Roll 81-90 or choose. Body oils give off a repugnant odour that cannot be stopped, covered or disguised, smelled within 500 feet (152 m) in air and 4000 feet (1220 m) underwater. Companions find people avoid them, enemies and predators notice the group unless it is downwind or downstream, and sneak attacks are impossible."
  - name: "Defect (91-00): Psychopathic Killer"
    description: "Roll 91-00 or choose. A killing machine that cannot be reasoned with: it spends its time hunting, killing, torturing, eating or waiting for the next victim. It knows no fear and attacks anything, fleeing only when its M.D.C. is down by 85%. Reduce intelligence by 25% - a fraction of a rolled number, applied by hand."
extraction_notes: "NEW 2026-10-05, Rifts World Book 7: Underseas printed 38-40 (cache p038-p040; this book''s cache page equals the printed folio through printed 130, and folios 38, 39 and 40 were read on the renders) and the experience ladder on printed 214 (cache p213, folio read). Every figure was read off a page render. THE SURVEY DECLINED THIS CLASS on 2026-09-07 because printed 39-40 is a random-creature generator with no stat block; Nate ruled on 2026-10-04 that it is imported on the band-named pick-group mechanic (BOOK-INGEST-AUDIT.md F119, F120). WHAT THE PAGES PRINT: an introduction to the gene-splicers (printed 38), the heading Random Creation of Gene-Splicer Monsters, the instruction ''Roll once on each of the following tables'', and EIGHT tables - Random Body Type/Appearance (14 rows), Number of heads (4), Type of Head (14), Intelligence & Aggression (5), Depth Tolerance (8), Additional appendages (8), Additional Features & Abilities (10) and the Genetic Defect Table (10). The survey counted six; Intelligence & Aggression and Depth Tolerance are the two it missed. All eight are stored as choose-1 groups in the book''s order, every row its own band-named option; all eight cover 01-00 with no gap or overlap as printed. STORED AS NUMBERS: each Body row''s M.D.C. as that row''s own mdc_base (BOOK-INGEST-AUDIT.md F128, branch pal/data/book-ingest-audit-f128-two-classes, 2026-10-13; before that a pool bonus on the class''s base of zero), the class keeping a base of zero that no page prints for the Other row, which prints none; each Body row''s strike, parry and dodge; the I.Q. dice of all five Intelligence rows as attribute_dice; the tail''s +1 parry, the crab claws'' one attack and +2 parry, and the fish tail''s +1 dodge and +12 Spd; Silent''s +2 initiative; Insatiable Hunger''s +1 initiative; Too Big''s 2D4x10 M.D.C.; and Psionic Empathy as a psionics block with its three named powers and I.S.P. 3D4x10. ATTACKS PER MELEE: the Body rows print a total (one, two or three), not a bonus. Stored as the difference from the two attacks every character starts with - nothing for two, attacks 1 for three, attacks -1 for the Manta Ray''s one - because no option anywhere in the catalog states an attack total and the class has no hand to hand skill to collide with. NOT STORED, PROSE IN THE ROW: per-pair bonuses that depend on a rolled count (tentacles, tentacle tongues); the Sonic Blast''s extra attack, which can only be the blast; the 1D6 Ocean spells of the Magic defect; halved speed (Too Big); ''reduce intelligence by 25%'' (Psychopathic Killer); the save versus Horror Factor 16 that onlookers make during a Shape-Changer''s metamorphosis, which is conditional and is not the creature''s Horror Factor; all sizes, damages, ranges and percentages. Type of Head is rolled once per head; the group holds one. PSIONIC EMPATHY''s type is stored as minor: the row prints three powers, an I.S.P. formula and ''equal to a third level psychic'', and no class of psychic. THE BOOK PRINTS NONE OF THESE AND NONE IS STORED: attribute dice other than I.Q., hit points, S.D.C., P.P.E., Horror Factor, alignment, any skill, any O.C.C. rule, equipment, money, life span. men_of_arms is false because this is a race stating no sdc_base and no mdc_base; the section heading is ''Gene-Splicers & Sea Monsters'' (printed 38). XP: the printed 214 column headed ''Dolphin, Humpback Whale, Gene-Splicer Mutants'', fifteen lower bounds, identical to the dolphin''s stored ladder. ONE ODDITY AS PRINTED: the Sonic Blast''s range reads ''120 feet (366 m)'', and 120 feet is 36.6 m; both figures are kept in the row. Ley Line Mutations, which begins lower on printed 40, is a different table for natural sea creatures and is not part of this class."
---

## Lore

The Gene-Splicers are a race of malevolent aliens. The New German Republic
believes they keep to outposts in Germany and Poland; in fact they are just as
well established in the seas, with two long-standing bases older than the
European one - one in the Black Sea and a mobile one in the North Pacific.

They capture animals and abduct intelligent beings for genetic experiments, and
when an experiment fails or stops being interesting the living result is simply
flushed into the ocean. Others are made and released on purpose, to be watched.
Either way the seas of Rifts Earth now hold mutants that prey on the native
life, humans included, and about 45% of them can breed.

The New Navy under Captain Nemo-2, Tritonia and Lemuria hunt the gene-splicers
and their creations; a large undersea base near Kure in the Hawaiian islands
was destroyed by the USS Ticonderoga and the 2nd Fleet with Lemurian help.
Dolphins, Whale Singers, aquatic D-bees and sailors kill the mutants where they
find them.

A gene-splicer mutant is whatever the tables make it: the body of one sea
animal, perhaps the head of another, perhaps several heads, an extra limb, one
strange ability, and one defect that may be why it was thrown away.

## GM Notes

**This class is a generator.** Printed 39-40 have the creature rolled once on
each of eight tables, and those tables are the class''s eight pick groups. The
book gives the mutant an experience ladder (printed 214) and nothing else a
character normally has.

**What the G.M. must supply, because the book does not:** seven of the eight
attributes (only I.Q. is printed, by the Intelligence & Aggression table),
alignment, skills, whether an O.C.C. may be taken at all, P.P.E., Horror
Factor, equipment and money. The natural animal the body is built on is the
obvious guide. The sheet''s default attribute dice, hit points and S.D.C. are
placeholders, not the book''s figures; the creature is a mega-damage being and
its M.D.C. is the Body row''s.

**Rolled by hand:**

- Type of Head for the second, third and fourth head.
- The attack, initiative, parry or strike bonus for each PAIR of tentacles or
  tentacle tongues.
- The 1D6 Ocean magic spells of the Magic defect, and the 1D6 level strength
  of each casting.
- Halved speed for a creature that is Too Big, and the 25% intelligence
  reduction of the Psychopathic Killer.

**The two Other rows** (Body 96-00, Head Type 96-00) are the G.M.''s choice of
creature and print no numbers. A Body of Other has no stored M.D.C. at all.

**Attacks per melee.** The Body row prints the total: one for the Manta Ray,
three for the Humanoid, the Squid or Octopus and the Lobster or Crab, and two
for the rest. Crab claws add one more; tentacles and tentacle tongues add one
per pair.

Ley Line Mutations, on the same page, is a separate table for ordinary sharks,
rays, fish, octopus, squid, eels and crustaceans born near ley lines. It is not
part of the gene-splicer mutant.
',
       updated_at = datetime('now')
 WHERE class_id = 'gene-splicer-mutant'
   AND instr(markdown, 'has a base to add to (without one the pick added nothing') > 0
   AND length(markdown) = 29353;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 2 classes carry their new text' AS assertion, count(*) AS got, 2 AS want
  FROM imported_classes
 WHERE (class_id = 'phase-world-alien' AND instr(markdown, 'mdc_base: "1D6x10 plus 2D4 per level of experience"') > 0)
    OR (class_id = 'gene-splicer-mutant' AND instr(markdown, 'mdc_base: "2d4x100"') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'phase-world-alien' AND instr(markdown, 'so this pick adds NOTHING by itself') > 0)
    OR (class_id = 'gene-splicer-mutant' AND instr(markdown, 'has a base to add to (without one the pick added nothing') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('phase-world-alien', 'gene-splicer-mutant') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~183-book-ingest-audit-f128-option-pool-bases.sql');
