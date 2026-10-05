-- Name eight classes' percentile-table options for their bands, so the wizard can roll them
-- 8 classes, each replaced whole: hu-aliens, hu-experiments, hu-mutants, rifts-gigantes, norse-giant, keeper-of-the-desert, freelancer, nb-doppleganger.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~162-band-names-on-eight-classes-percentile-tables.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- Close-out package C2, second script: eight classes whose pick groups were
-- already the book's percentile tables but whose option names carried no band,
-- so the wizard offered no Roll button. Each option is renamed
-- "Label (NN-NN): Old Name" and each group's count restated from its page.
--
--   hu-aliens (Revised Heroes Unlimited printed 55-57): Appearance, Environment,
--     Power and Familiarity, each rolled once. Frozen World's speed loss is one
--     third, as printed 55 has it, not -4.
--   hu-experiments (printed 69-70): Tables C and D; the Super-Soldier Option
--     keeps its unbanded name. Must Physically Transform's S.D.C. holds only
--     while transformed and is no longer a stored bonus.
--   hu-mutants (printed 109-110): Unusual Characteristics, rolled once. The
--     Prehensile Tail keeps its extra attack; its +1 strike and parry are with
--     the tail only, and the Prehensile Feet's +1 dodge is barefoot only, so
--     both move from stored bonuses to the rows' prose.
--   rifts-gigantes (Conversion Book One printed 91-92): rolls 4, and the
--     additional leg's +1D4x10 Spd is stored.
--   norse-giant (Pantheons printed 163): rolls 3.
--   keeper-of-the-desert (New West printed 132-133): the page rolls once at
--     first level and again at levels 6 and 12, so the choose-3 group becomes
--     choose 1 at_levels [1, 6, 12]; five rows gain the unconditional numbers
--     they print.
--   freelancer (Wormwood printed 68), nb-doppleganger (Nightbane printed 160):
--     rolled once. The Doppleganger's page prints "40%", not bands.
--
-- Every band was read off a render by one agent and checked against a render by
-- book-reconcile. Production held no saved character on any of the eight
-- (queried 2026-10-05), which is what makes the renames safe; no test or code
-- names any of these options.

-- == hu-aliens ==
UPDATE imported_classes
   SET markdown = '---
id: hu-aliens
name: Aliens
system: heroes-unlimited
source_book: Revised Heroes Unlimited p.55-59
category: rcc
tags: []
xp_table: [0, 2101, 4201, 8401, 17201, 25401, 35801, 51001, 71201, 96401, 131601, 181801, 232001, 282201, 342401]
occ_restrictions:
  only: ["hu-alien-edu-general-studies", "hu-alien-edu-military-specialist", "hu-alien-edu-science-specialist", "hu-alien-edu-combat-specialist", "hu-alien-edu-engineer"]
hit_points_base: "P.E. + 1D6 per level"
sdc_base: "20"
special_abilities:
  - name: "Appearance (01-30): Human-Like"
    description: "Roll 01-30 or choose. A humanoid alien so like a human as to be indistinguishable from Earth people."
  - name: "Appearance (31-50): Humanoid with a Distinguishing Characteristic"
    description: "Roll 31-50 or choose. Resembles Earthlings closely but carries one unusual feature - roll on the Mutant Unusual Characteristics table, where 01-16 is pointy or large ears and 17-39 an odd skin colour; 40-00 is unchanged."
  - name: "Appearance (51-55): Insect Appearance"
    description: "Roll 51-55 or choose. Large eyes, antennae, claw-like hands and feet, no body hair, an exoskeleton, any skin colour. Does 1D6 damage in hand to hand combat."
    bonuses: { pools: { sdc: 100 } }
  - name: "Appearance (56-60): Humanoid Amphibian"
    description: "Roll 56-60 or choose. Soft, smooth skin; webbed hands and feet; semi-aquatic - can hold its breath up to 20 minutes, swims automatically at 90% proficiency, and swims at six times its running speed. Skin green, brown, tan, yellow or blotchy. No S.D.C. bonus."
  - name: "Appearance (61-65): Vegetation"
    description: "Roll 61-65 or choose. Composed of the same essence as Earth plant life, in shades of green or yellow. A cold lifeform: it does NOT register on heat sensors or infrared, and it heals twice as fast as a normal human."
    bonuses: { pools: { sdc: 40 } }
  - name: "Appearance (66-70): Humanoid Reptilian"
    description: "Roll 66-70 or choose. Lizard-like features, leathery or scaly skin, little or no body hair, long fingers."
    bonuses: { attributes: { PP: 2 }, pools: { sdc: 40 } }
  - name: "Appearance (71-75): Humanoid Canine"
    description: "Roll 71-75 or choose. Dog-like features, body fur or extreme body hair, dark eyes."
    bonuses: { attributes: { PS: "1d4", Spd: "1d4" }, pools: { sdc: 10 } }
  - name: "Appearance (76-80): Humanoid Avian"
    description: "Roll 76-80 or choose. Bird-like features; large round eyes; clawed feet and hands; feathers for hair; no wings, or tiny useless ones. Any colour of skin and feathers. Keen hearing, twice as good as a human''s. Does 1D6 damage in hand to hand combat."
  - name: "Appearance (81-85): Humanoid Mineral"
    description: "Roll 81-85 or choose. Rocky or crystalline, in any colour, with natural body armour - A.R. 14, and the page prints S.D.C. 180 for this row without the word bonus. Stored as +180 on the base 20, because printed 58 says the base is in addition to appearance bonuses."
    bonuses: { pools: { sdc: 180 } }
  - name: "Appearance (86-90): Humanoid Feline"
    description: "Roll 86-90 or choose. Cat-like features, bright oval eyes, a fur-covered body, pointy ears."
    bonuses: { attributes: { PP: 2, Spd: 2 }, pools: { sdc: 10 } }
  - name: "Appearance (91-95): Humanoid Ape"
    description: "Roll 91-95 or choose. Resembles a tailless ape; long arms, a fur-covered or extremely hairy body."
    bonuses: { attributes: { PS: "1d6" }, pools: { sdc: 20 } }
  - name: "Appearance (96-00): Humanoid Aquatic"
    description: "Roll 96-00 or choose. Fish or sea mammal - dolphin or whale - with webbed feet and hands, smooth or scaly skin, a blowhole or gills, no body hair, brightly coloured. Swims at 90% proficiency and at ten times its normal running speed."
    bonuses: { pools: { sdc: 20 } }
  - { choose: 1, from: ["Appearance (01-30): Human-Like", "Appearance (31-50): Humanoid with a Distinguishing Characteristic", "Appearance (51-55): Insect Appearance", "Appearance (56-60): Humanoid Amphibian", "Appearance (61-65): Vegetation", "Appearance (66-70): Humanoid Reptilian", "Appearance (71-75): Humanoid Canine", "Appearance (76-80): Humanoid Avian", "Appearance (81-85): Humanoid Mineral", "Appearance (86-90): Humanoid Feline", "Appearance (91-95): Humanoid Ape", "Appearance (96-00): Humanoid Aquatic"], note: "Step Two: the alien''s appearance (printed 55), rolled once or picked." }
  - name: "Environment (01-15): High Gravity World"
    description: "Roll 01-15 or choose. A homeworld pulling far harder than Earth has given the alien greater mass and endurance, and on our planet he is much faster and lighter than he was at home. Height 5ft plus 1D6 inches. Speed is increased by three times."
    bonuses: { attributes: { PS: "2d4" }, pools: { sdc: "3d4x10" } }
  - name: "Environment (16-29): Low Gravity World"
    description: "Roll 16-29 or choose. A much lighter homeworld gravity has made the alien far taller than a typical human; Earth''s pull slows him but gives him somewhat greater mass. Height 5ft 5in plus 1D6 additional FEET, weight 1D4x100lbs. Speed is reduced by half."
    bonuses: { attributes: { PP: "1d4" }, pools: { sdc: "1d4x10" } }
  - name: "Environment (30-44): High Radiation World"
    description: "Roll 30-44 or choose. Constant exposure has made the alien impervious to radiation levels that would kill a human, and radiation does him no damage. He radiates low-level radioactivity himself, harmful to humans exposed for a few weeks, so he must wear a radiation-proof suit to protect his allies. Height 6ft plus 1D6 inches, weight 190 plus 1D6lbs. Can see into the ultraviolet."
    bonuses: { pools: { sdc: "1d4x10" } }
  - name: "Environment (45-58): Frozen World"
    description: "Roll 45-58 or choose. Impervious to even deadly cold, and unable to tolerate warmth: he must always wear an insulated suit with a refrigerator unit. Above freezing he suffers -2 P.S. and P.P., Speed reduced by one third and -8 S.D.C. for every ten hours of exposure, cumulative; when the S.D.C. is gone he loses 8 hit points and will die unless the suit is repaired or frozen conditions are made. Height 5ft plus 3D6 inches, weight 120 plus 2D6x10lbs."
    bonuses: { pools: { sdc: 40 } }
  - name: "Environment (59-73): Thermo World"
    description: "Roll 59-73 or choose. A homeworld that makes a sauna feel cool. Impervious to heat and fire - though lasers and energy blasts do full damage - and unable to tolerate anything below 98 degrees Fahrenheit; 200 degrees is comfortable. He wears a protective suit with a heating unit, and exposed to Earth''s cold he weakens and dies within days, exactly as the frozen-world alien does in the warmth. Height 5ft plus 4D6 inches, weight 100 plus 2D6x10lbs."
    bonuses: { pools: { sdc: 30 } }
  - name: "Environment (74-88): Twilight World"
    description: "Roll 74-88 or choose. An extremely dark, night-like world. Nightvision to 600ft and hearing about 20 decibels beyond the human range; but light above 60 watts is bright and 100 watts or more - sunlight - is blinding, so photosensitive goggles or eye shields must be worn to see in the light. Blinded by light he is -8 to strike, parry and dodge. Height 4ft plus 1D4ft, weight 100 plus 2D4x10lbs."
    bonuses: { pools: { sdc: 10 } }
  - name: "Environment (89-00): Abrasive Atmosphere"
    description: "Roll 89-00 or choose. High scathing winds or a corrosive atmosphere have given this being tough, thick skin or leathery plating, like an Earth rhinoceros: a natural Armour Rating of 12, so a strike roll of 12 or less may hit but does no damage. Height 4ft plus 1D6 feet, weight 200 plus 4D6x10lbs."
    bonuses: { pools: { sdc: "3d6x10" } }
  - { choose: 1, from: ["Environment (01-15): High Gravity World", "Environment (16-29): Low Gravity World", "Environment (30-44): High Radiation World", "Environment (45-58): Frozen World", "Environment (59-73): Thermo World", "Environment (74-88): Twilight World", "Environment (89-00): Abrasive Atmosphere"], note: "Step Three: physiological modification due to unearthly environments (printed 55-56), rolled once or picked. All bonuses are accumulative." }
  - name: "Power (01-49): Alien Super Abilities"
    description: "Roll 01-49 or choose. One major super ability and one minor, selected or rolled."
    super_abilities: { abilities_starting: 2, abilities_starting_groups: [{ count: 1, tiers: ["major"] }, { count: 1, tiers: ["minor"] }] }
  - name: "Power (50-60): Alien Psionics"
    description: "Roll 50-60 or choose. The alien psychic is not quite the equal of a natural psionic: two major psi-powers and four secondary ones, chosen once and never added to. I.S.P. grows by 10 per level of experience. Printed 127."
    bonuses: { attributes: { ME: "2d4", MA: "1d4" } }
    psionics: { type: "master", isp_base: "M.E. x2 + 1d8", powers_starting: 6, powers_starting_groups: [{ count: 2, from: ["Astral Projection", "Bio-Manipulation (the evil eye)", "Bio-Regeneration", "Ectoplasmic Arm", "Empathy", "Empathic Transmission", "Hydrokinesis", "Hypnosis/Mesmerism", "Levitation", "Mind Bolt", "Mind Bond", "Mind Control", "Mind Wipe", "Object Read (Psychometry)", "Presence Sense", "Pyrokinesis", "Telekinesis", "Telemechanics", "Telepathy"], note: "Major psi-powers, printed 128." }, { count: 4, from: ["Alter Aura", "Detect Psionics", "Death Trance", "Hypnotic Suggestion", "Mind Block", "Resist Cold", "Resist Fatigue", "Resist Hunger", "Resist Thirst", "See Aura", "Sixth Sense", "Speed Reading", "Summon Inner Strength", "Total Recall"], note: "Secondary psi-powers, printed 133." }] }
  - name: "Power (61-69): Alien Experiment"
    description: "Roll 61-69 or choose. Four minor super abilities, selected or rolled."
    super_abilities: { abilities_starting: 4, abilities_starting_groups: [{ count: 4, tiers: ["minor"] }] }
  - name: "Power (70-79): Alien Robotics"
    description: "Roll 70-79 or choose. Designed as usual, with Earth-equivalent value and abilities, using the robot budget of printed 136-152. The catalog has no builder for one; see extraction_notes."
  - name: "Power (80-89): Alien Mystic"
    description: "Roll 80-89 or choose. Wizardry and spell magic only - no illusionary magic, no enchanted object. Fourteen spells known, eight castable per day at first level with two more at levels three, six, nine and twelve. Printed 91-93."
    magic: { type: "spell", spells_starting: 14, spells_from: ["Anti-Magic Cloud", "Armor of Ithan", "Blind", "Breathe Without Air", "Call Lightning", "Chameleon", "Carpet of Adhesion", "Decipher Magic", "Dimensional Teleport", "Diminish Others", "Dispel Magic Barriers", "Exorcism", "Expel Demons", "Extinguish Fire", "Eyes of the Wolf", "Fire Ball", "Fly as the Eagle", "Globe of Daylight", "Globe of Silence", "Impenetrable Wall", "Invisibility: Simple", "Levitate (self or others)", "Magic Net", "Mesmerism", "Mute", "Mystic Alarm", "Mystic Portal", "Mystic Shield", "Negate Magic", "Paralysis Bolt", "Reduce Self (6 inches)", "Resist Fire", "Restoration", "Sanctuary", "See the Invisible", "Shadow Beast", "Sphere of Invisibility", "Speed of the Snail", "Sorcerer''s Seal", "Stone to Flesh", "Swim as a Fish (lesser)", "Teleport: Lesser", "Teleport: Superior", "Tongues", "Turn Dead", "Wall of Flame", "Wind Rush", "Words of Truth"] }
  - name: "Power (90-00): Alien Bionics"
    description: "Roll 90-00 or choose. Built as usual, with Earth-equivalent value and abilities, using the bionic budget of printed 60-68. The catalog has no builder for one; see extraction_notes."
  - { choose: 1, from: ["Power (01-49): Alien Super Abilities", "Power (50-60): Alien Psionics", "Power (61-69): Alien Experiment", "Power (70-79): Alien Robotics", "Power (80-89): Alien Mystic", "Power (90-00): Alien Bionics"], note: "Step Four: where the alien''s power comes from (printed 56), selected or rolled once." }
  - name: "Familiarity (01-20): No Familiarity with Earth"
    description: "Roll 01-20 or choose. No familiarity with Earth''s culture, science or laws, but understands, speaks and writes ONE Earth language at 88% proficiency."
  - name: "Familiarity (21-60): Some Familiarity with Earth"
    description: "Roll 21-60 or choose. Knows Earth''s major nations, cultures and laws, and speaks, reads and writes FOUR Earth languages at 90% proficiency."
  - name: "Familiarity (61-00): Has Studied Earth Intensely"
    description: "Roll 61-00 or choose. As knowledgeable as a well-informed native, and speaks, reads and writes SIX Earth languages fluently at 98% proficiency."
  - { choose: 1, from: ["Familiarity (01-20): No Familiarity with Earth", "Familiarity (21-60): Some Familiarity with Earth", "Familiarity (61-00): Has Studied Earth Intensely"], note: "Step Seven: familiarity with Earth (printed 57), rolled once or picked. The languages are stated as a count and a percentage rather than as named skills, so they are described rather than granted." }
extraction_notes: "XP: stored 2026-09-27 as xp_table, printed 17''s column headed Alien, read off a render. It prints level 5 as 17,200 - 25,400, the lower bound repeating level 4''s top of 17,200; stored as 17,201. AN ALIEN DOES NOT ROLL ON THE EDUCATIONAL LEVEL TABLE. Its STEP FIVE prints five education packages of its own - General Studies, Military Specialist, Science Specialist, Combat Specialist and Engineer - which REPLACE printed 27''s eleven. Printed 27 exempts only Special Training and Physical Training, so this is a third exemption the exemption note does not mention. Those five ship as O.C.C.s beside the standard eleven and this class names them in `occ_restrictions`, written by zzzzzz-hu-education-occ-restrictions.sql once those five class ids existed. STARTING MONEY IS NOT STORED because it is a seven-outcome table in precious metals or stones (printed 58) - 1D4x$1000 through 6D6x$1000 - and `starting_money` holds ONE formula. Choosing the middle row would be inventing a number the book does not state. The table is in the body. STEP EIGHT''S EQUIPMENT is likewise not stored: Earth clothes, a Special Weapons table and a Special Vehicles table of alien manufacture, none of which the gear catalog holds and none of which should be stubbed - same argument as BOOK-INGEST-AUDIT F3. Three of the six power categories point at construction systems the catalog has no builder for: Robotics, Bionics, and the alien''s own vehicles. Survey D7. THE PSIONIC OPTION USES A NAMED LIST rather than a category gate, which is how survey G8''s taxonomy mismatch stops mattering: this book files a power as Major or Secondary and the catalog files one as Healing, Physical, Sensitive or Super, and `powers_from` replaces the category gate outright. `psionics.type` is `master` because nothing here gates on tier and a lower tier would have filtered the list. 2026-10-05: THE FOUR TABLES ARE BAND-NAMED so each can be rolled or picked - Appearance (printed 55, twelve rows 01-00), Environment (printed 55-56, seven rows 01-00), Power category (printed 56, six rows 01-00, ''select or randomly roll'') and Familiarity with Earth (printed 57, three rows 01-00). Every band was read off a render and each table covers 01-00 with no gap or overlap; the page prints the first band of each as 1-NN and it is stored 01-NN. Each is rolled once. In the same pass the Frozen World exposure penalty was corrected from -4 Speed to the printed Speed reduced by one third (printed 55)."
---

## Lore

Aliens are beings from another planet who possess unusual and extraordinary
powers. Some look very much like humans while others are clearly inhuman. Their
motives for coming to Earth vary, as do their attitudes and physical appearance.

Not all aliens are from a superior culture, nor are all of them peaceful or
wise.

An alien is built in eight steps, and four of them are tables: what it looks
like, what its homeworld did to it, where its power comes from, and how well it
knows this planet. Its education is its own as well - the standard Educational
Level table does not apply.

## GM Notes

**Step Six, the reason for coming to Earth**, is rolled and remembered rather
than stored. 01-19 the last of a race of people; 20-38 crash landed and trapped
here, the ship destroyed; 39-55 an outcast, a fugitive from his own world for
political, social, racial or criminal reasons; 56-70 an intergalactic champion
of justice, sometimes assigned here for a tour of 4D4 years; 71-85 a glory hound
after fame and fortune on what looked like an easy, primitive world; 86-00 came
to study Earth and could not help getting emotionally involved. Each entry has
its own sub-table of feelings about the place.

**Step Eight, equipment.** Earth clothes or a disguise on 41-00 and none on
01-40, then a Special Weapons table and a Special Vehicles table of alien
manufacture - hover cycles, hover platforms, jet packs, antigravity discs,
flight rings and an A.T.V. hover vehicle, each with its own speed, hover ceiling
and S.D.C. None of it is in the gear catalog.

**Money, in precious metals or stones** (printed 58), which is why the class
states none:

| roll | | roll | |
|---|---|---|---|
| 01-14 | 1D4x$1000 | 60-74 | 4D4x$1000 |
| 15-29 | 1D6x$1000 | 75-88 | 4D6x$1000 |
| 30-44 | 2D4x$1000 | 89-00 | 6D6x$1000 |
| 45-59 | 3D4x$1000 | | |

Hand to hand combat is not automatic and must be selected as a learned skill.
Every hero gets two attacks per melee. Except for whatever the Special Weapons
table produced, only conventional Earth weaponry, body armour and equipment are
available. Where a protective suit is needed to survive here, assume the
creature has one plus 1D4 spares; a typical environmental suit stops working
after 30 S.D.C. of damage.

Any alignment may be chosen, though alien heroes should generally be of good or
anarchist alignment. It is probably best to assume the alien hero does not have
a spacecraft at his disposal.
',
       updated_at = datetime('now')
 WHERE class_id = 'hu-aliens'
   AND instr(markdown, 'from: ["Human-Like", "Humanoid with') > 0
   AND length(markdown) = 15823;

-- == hu-experiments ==
UPDATE imported_classes
   SET markdown = '---
id: hu-experiments
name: Experiments
system: heroes-unlimited
source_book: Revised Heroes Unlimited p.69-72
category: rcc
tags: []
xp_table: [0, 2001, 4001, 8201, 16401, 24501, 34601, 49701, 69801, 94901, 129001, 179101, 229201, 279301, 329401]
occ_restrictions:
  except: ["hu-alien-edu-general-studies", "hu-alien-edu-military-specialist", "hu-alien-edu-science-specialist", "hu-alien-edu-combat-specialist", "hu-alien-edu-engineer"]
hit_points_base: "P.E. + 1D6 per level"
sdc_base: "30"
starting_money: "4d4x100"
special_abilities:
  - name: "Powers (01-15): One major super ability and three minor"
    description: "Roll 01-15 or choose. The experiment produced a major power and three lesser ones."
    super_abilities: { abilities_starting: 4, abilities_starting_groups: [{ count: 1, tiers: ["major"] }, { count: 3, tiers: ["minor"] }] }
  - name: "Powers (16-32): Four minor super abilities"
    description: "Roll 16-32 or choose. No major powers."
    super_abilities: { abilities_starting: 4, abilities_starting_groups: [{ count: 4, tiers: ["minor"] }] }
  - name: "Powers (33-50): One major super ability and one minor"
    description: "Roll 33-50 or choose."
    super_abilities: { abilities_starting: 2, abilities_starting_groups: [{ count: 1, tiers: ["major"] }, { count: 1, tiers: ["minor"] }] }
  - name: "Powers (51-69): One major super ability and two minor"
    description: "Roll 51-69 or choose."
    super_abilities: { abilities_starting: 3, abilities_starting_groups: [{ count: 1, tiers: ["major"] }, { count: 2, tiers: ["minor"] }] }
  - name: "Powers (70-86): Five minor super abilities"
    description: "Roll 70-86 or choose. No major powers."
    super_abilities: { abilities_starting: 5, abilities_starting_groups: [{ count: 5, tiers: ["minor"] }] }
  - name: "Powers (87-00): Two major super abilities"
    description: "Roll 87-00 or choose. No minor powers."
    super_abilities: { abilities_starting: 2, abilities_starting_groups: [{ count: 2, tiers: ["major"] }] }
  - name: "The Super-Soldier Option"
    description: "Printed 71. Built rather than rolled: one minor super ability, and THREE of the nine enhancements offered below. Take the enhancements only with this option - nothing in the app can tie one choice group to another."
    super_abilities: { abilities_starting: 1, abilities_starting_groups: [{ count: 1, tiers: ["minor"] }] }
  - { choose: 1, from: ["Powers (01-15): One major super ability and three minor", "Powers (16-32): Four minor super abilities", "Powers (33-50): One major super ability and one minor", "Powers (51-69): One major super ability and two minor", "Powers (70-86): Five minor super abilities", "Powers (87-00): Two major super abilities", "The Super-Soldier Option"], note: "Table C, the number of super abilities (printed 69): roll percentile dice once, or choose. The Super-Soldier Option carries no band - it is the choice the page offers in place of rolling on this table." }
  - name: "Side Effect (01-08): Hair Growth Stimulated"
    description: "Roll 01-08 or choose. All body hair tripled."
  - name: "Side Effect (09-16): Odd Skin Pigmentation"
    description: "Roll 09-16 or choose. Light green, pale bluish white, light grey, pale white or dark brown - roll or choose."
  - name: "Side Effect (17-24): Odd Skin Texture"
    description: "Roll 17-24 or choose. Detracts from physical beauty."
    bonuses: { attributes: { PB: -2 } }
  - name: "Side Effect (25-33): Whole Body Glows"
    description: "Roll 25-33 or choose. Glows faintly in the dark; makes a great target at night."
  - name: "Side Effect (34-40): Vulnerable to Radioactivity"
    description: "Roll 34-40 or choose. Reduce all physical attributes by half while exposed to radioactivity, even the tiniest levels."
  - name: "Side Effect (41-47): Must Physically Transform"
    description: "Roll 41-47 or choose. Every time the power is used: add 1D4 feet to height, add 3D4x10 to weight, and the skin colour changes. On the good side the transformed body has 2D4x10 more S.D.C. and +2 to damage; both hold only while transformed, so add them by hand."
  - name: "Side Effect (48-54): Requires Energy for Nourishment"
    description: "Roll 48-54 or choose. Cannot eat or drink; must absorb 200,000 volts per day of electrical or heat energy, not organic life energy. Never gets hungry, does not tire in sunlight or heat, and electrical blasts do half damage."
  - name: "Side Effect (55-63): Increased Mass"
    description: "Roll 55-63 or choose. Physical proportions unchanged, mass increased: add 2D4x10lbs to weight and decrease the Speed attribute by 20%."
    bonuses: { pools: { sdc: "1d6x10" } }
  - name: "Side Effect (64-70): Chemical Resistance"
    description: "Roll 64-70 or choose. An automatic saving throw against ALL chemicals, drugs and toxins - which applies to lifesaving drugs as well as to deadly ones."
    bonuses: { saves: { toxins_poisons: 5, harmful_drugs: 5 } }
  - name: "Side Effect (71-77): Breathe Without Air"
    description: "Roll 71-77 or choose. The character does not seem to breathe but functions normally even in an airless environment, and is impervious to gases. No sense of smell or taste. None."
  - name: "Side Effect (78-84): Chronic Pain"
    description: "Roll 78-84 or choose."
    bonuses: { attributes: { PE: -1 }, combat: { initiative: -1 } }
  - name: "Side Effect (85-93): Hair Permanently Falls Out"
    description: "Roll 85-93 or choose. All hair on the head and face."
  - name: "Side Effect (94-00): No Facial Features"
    description: "Roll 94-00 or choose. A slit for a mouth, two holes for nostrils, a ridge above what were eye sockets, button-sized ears. The character breathes, hears, speaks and sees as well as ever or better: perfect 20/20 vision even if glasses were needed before, natural infrared and ultraviolet sight to 600ft, and much sharper hearing and smell. Reduce physical beauty by half, and roll on the random insanity table for the trauma."
    bonuses: { combat: { initiative: 2 } }
  - { choose: 1, from: ["Side Effect (01-08): Hair Growth Stimulated", "Side Effect (09-16): Odd Skin Pigmentation", "Side Effect (17-24): Odd Skin Texture", "Side Effect (25-33): Whole Body Glows", "Side Effect (34-40): Vulnerable to Radioactivity", "Side Effect (41-47): Must Physically Transform", "Side Effect (48-54): Requires Energy for Nourishment", "Side Effect (55-63): Increased Mass", "Side Effect (64-70): Chemical Resistance", "Side Effect (71-77): Breathe Without Air", "Side Effect (78-84): Chronic Pain", "Side Effect (85-93): Hair Permanently Falls Out", "Side Effect (94-00): No Facial Features"], note: "Table D, the permanent side-effect (printed 69-70): roll percentile dice once, or choose." }
  - name: "Attempted Invulnerability"
    description: "Super-soldier 1. Adds 80lbs of muscle and a natural A.R. of 13: a strike roll under 14 can hit but does no damage."
    bonuses: { pools: { sdc: "4d6x10" } }
  - name: "Increased Agility and Dexterity"
    description: "Super-soldier 2. Raise the P.P. attribute to 20 if it is not already higher, and add +5% to skills needing agility or dexterity - acrobatics, pick locks, computer operation."
  - name: "Increased Physical Speed"
    description: "Super-soldier 3. Triples the Speed attribute and allows a 15ft standing leap up and 20ft across. The character is hyperactive and has trouble relaxing and sleeping."
  - name: "Mind and Body Attuned"
    description: "Super-soldier 4. Reaction time and alertness increased."
    bonuses: { combat: { attacks: 1, initiative: 2 } }
  - name: "Bionic Endurance Implants"
    description: "Super-soldier 5. Implants in the head stimulate brain chemicals and glandular activity: raise the P.E. attribute to 18 if it is not already higher. Not affected by exhaustion for the first two hours of strenuous activity. Chronic headaches, and eats four times as much as normal without gaining weight."
    bonuses: { attributes: { PS: "1d6", Spd: "1d6" } }
  - name: "Brain Boost"
    description: "Super-soldier 6. Raises the I.Q. attribute to 14. Will not increase an I.Q. already 14 or higher."
  - name: "Physical Transformation"
    description: "Super-soldier 7. Fat becomes lean muscle, bones strengthen, hair fills out, and impairments such as poor vision and hearing improve."
    bonuses: { attributes: { PS: "1d4", PB: "2d4", Spd: "1d6" }, pools: { sdc: "4d6" } }
  - name: "Bionic Weapon System"
    description: "Super-soldier 8. An implant in one hand and arm, not an artificial limb, responding to bioelectrical impulses from the brain. Ten blasts per hour at most. Select one: Electrical Discharge, 1D6, 2D6 or 4D6 damage at the character''s choice, range 50ft; or Energy Blast, 1D6 or 2D6 damage, range 150ft."
  - name: "Bionic Sensor System"
    description: "Super-soldier 9. An implant in one hand and arm. Select one: electronic bug detector (20ft), explosives detector (8ft), heat sensor (30ft), radiation detector, radio scrambler, radio meter (40ft), or infrared warning system."
  - { choose: 3, from: ["Attempted Invulnerability", "Increased Agility and Dexterity", "Increased Physical Speed", "Mind and Body Attuned", "Bionic Endurance Implants", "Brain Boost", "Physical Transformation", "Bionic Weapon System", "Bionic Sensor System"], note: "The Super-Soldier''s three enhancements, printed 71. Take these ONLY with the Super-Soldier Option above." }
extraction_notes: "Tables A, B, E and F - the nature of the experiment, its result, the sponsoring organization and the character''s standing with it - are background rather than mechanics and are recorded in the body rather than stored. Table F''s last entry does carry a number: a character still employed earns double the usual income for the position, no less than $50,000 a year, which has no field. The Super-Soldier''s three enhancements are a second choice group and NOTHING TIES IT TO THE FIRST: a build that did not take the Super-Soldier Option can still open it. The book''s own text is the only rule, as it is at the table. Currency is dollars; js/rules.js returns Credits for rifts and gold otherwise, so this figure will be labelled wrongly until that is settled - survey G10. Two bonus keys were corrected against what the SHEET renders rather than against what the parser accepts, which takes any key: the extra attack is `combat.attacks`, not `attacks_per_melee`, and there is no `chemicals` save - the book''s "+5 to save vs all chemicals/toxins" is filed as `toxins_poisons` AND `harmful_drugs`, the two rows the sheet has that it covers. 2026-10-05, TABLES C AND D ARE BAND-NAMED, read off renders of printed 69 and 70 (BOOK-INGEST-AUDIT.md F120). Printed 69, step three: roll percentile dice for all of the tables, each once. Table C prints 1-15, 16-32, 33-50, 51-69, 70-86 and 87-00 and Table D prints 1-8, 9-16, 17-24, 25-33, 34-40, 41-47, 48-54, 55-63, 64-70, 71-77, 78-84, 85-93 and 94-00; each covers 01-00 with no gap or overlap, and every band already typed in a description agreed with the page. The rows of both pick-one groups are renamed `Powers (NN-NN): ...` and `Side Effect (NN-NN): ...` so that either can be rolled or chosen, and the band that led each description is replaced by the roll-or-choose wording. The Super-Soldier Option is the seventh entry of the Table C group and keeps its unbanded name: the page prints it under Table C as the alternative to rolling, with no band. Table D row 9-16 sends the player to a five-row colour sub-table (1-20, 21-40, 41-60, 61-80, 81-00) and row 41-47 sends back to it; both stay in the row prose. Tables A, B, E and F also print bands and stay as prose in the body, for the reason given at the head of this note."
---

## Lore

The super villain or hero created by scientific experimentation is a bit
different from most of the other power categories in that his or her
extraordinary powers are man-made. Presumably the character was an ordinary
human being before the experiment, perhaps even a physically impaired or
underdeveloped specimen. It is the experiment that instilled the super human
abilities.

That complicates matters. A dozen or more people know about the experiment, the
powers and the true identity. In most likelihood the creating organization has
some legal right over the person, forcing him to work with, if not for, the
organization; a military project may conscript him outright. The character may
have to flee his creators to operate on his own, making him a fugitive or even a
criminal.

On favourable terms with the sponsoring organization it runs the other way:
support, access to superior scientific facilities and data, and a substantial
salary. The character''s activities may be openly promoted by the organization,
or kept secret and officially disavowed.

These experiments also produce unintentional side-effects that can help and
hinder the individual, and every experiment character carries one.

## GM Notes

**Four background tables are rolled at the table and stored nowhere.**

**Table A, the nature of the experiment:** 01-33 chemical, 34-67 radiation,
68-00 both combined.

**Table B, the result:** 01-20 a total success that cannot be duplicated; 21-50
an accident, the ability completely unintentional; 51-70 the unexpected
side-effect of some other experiment; 71-00 an attempt to alter or improve the
human body where an unknown x-factor produced staggering results.

**Table E, the sponsoring organization:** 01-24 private industry, 25-50 a
medical research facility, 51-75 the military, 76-00 a secret organization -
roll again for its motive: 01-20 medical, 21-50 criminal, 51-80 crime fighting,
81-00 military.

**Table F, standing with that organization:** 01-21 allowed to leave on good
terms; 22-45 the power is unknown to them, having manifested long after the
incident; 46-58 allowed to leave after great antagonism; 59-64 ran away and is
secretly hunted for further research, hostile but not deadly; 65-77 thrown out
of the program, all ties dissolved, very angry; 78-89 ran away and is considered
a criminal, hunted by law enforcement and the organization; 90-00 currently
employed, at double the usual income for the position and never less than
$50,000 a year.

Hand to hand combat is not automatic and must be selected as a learned skill.
Every hero gets two attacks per melee; more come from combat or physical skills,
or from the Super-Soldier''s fourth enhancement.

Unless the character is wealthy, only conventional weaponry and body armour are
available. A character on good terms with the organization that made him, or in
its employ, may reach specialized equipment at the G.M.''s discretion.
',
       updated_at = datetime('now')
 WHERE class_id = 'hu-experiments'
   AND instr(markdown, 'from: ["One major super ability and three minor", "Four minor super abilities"') > 0
   AND length(markdown) = 12311;

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
  - name: "Characteristic (01-30): No unusual physical traits"
    description: "Roll 01-30 or choose. The commonest outcome by a wide margin: most mutants pass for ordinary human beings, and only their powers set them apart."
  - name: "Characteristic (31-34): Pointy or Large Ears"
    description: "Roll 31-34 or choose."
  - name: "Characteristic (35-39): Odd Skin Color"
    description: "Roll 35-39 or choose. Yellow, green, red, grey, light blue, stark white, dark blue, coal black, purple or orange."
  - name: "Characteristic (40-43): Ambidextrous"
    description: "Roll 40-43 or choose. Uses the right and left hand with equal skill and dexterity. Also +10% to climbing, +5% to escape artist, pick locks, and mechanical and electrical repair."
    bonuses: { combat: { attacks: 1, parry: 1 } }
  - name: "Characteristic (44-48): Odd Hair Color"
    description: "Roll 44-48 or choose. Green, light blue, white streaked, flame red, stark white, bright yellow, metallic silver, dark blue, purple or orange."
  - name: "Characteristic (49-53): Double-Jointed"
    description: "Roll 49-53 or choose. Limber enough to collapse the bones of the hands and slip out of handcuffs, dislocate joints painlessly, and fit through small openings. One escape attempt per melee: 79% from rope, handcuffs or chains on the hands and feet, 46% when arms, legs and body are bound or a straightjacket is used. A locked room, trunk or compartment still holds him. He can contort to half his shoulder width and half his chest-to-back depth, and curl into a ball 20% of his height and half his width."
    bonuses: { combat: { roll: 2 } }
  - name: "Characteristic (54-58): Unusual Eyes"
    description: "Roll 54-58 or choose. Very small, round, very large, an odd colour, very elliptical, or glowing."
  - name: "Characteristic (59-64): Extreme Amount of Body Hair"
    description: "Roll 59-64 or choose. From a very bushy head of hair, through three and six times the normal amount all over, to half-inch fur or 1D4-inch fur covering most of the body except the face, feet and palms."
  - name: "Characteristic (65-68): Prehensile Feet and Toes"
    description: "Roll 65-68 or choose. Monkey-like feet with long, finger-like toes and a thumb for grabbing. Not developed enough to throw or fire a gun accurately (-6 to strike), but they pick up and carry 30lbs or less, press buttons, untie rope, turn doorknobs and pull levers. Barefoot only, so by hand: +1 to dodge, and +30 to climb rope or wall, or 30% as a base if there is no climbing skill. Skills like computer operation or pick pockets suffer -25% done with the feet; mechanics, electronics, robotics, medical, demolitions and piloting are effectively impossible, 10% being the best base."
  - name: "Characteristic (69-72): Scaly Skin"
    description: "Roll 69-72 or choose. Tough, smooth reptilian skin with small scales."
    bonuses: { pools: { sdc: 30 } }
  - name: "Characteristic (73-76): No Body Hair"
    description: "Roll 73-76 or choose. None at all."
  - name: "Characteristic (77-79): Small Horns"
    description: "Roll 77-79 or choose. 1D4 inches long, protruding from the forehead."
  - name: "Characteristic (80-84): Tough, Lumpy Skin"
    description: "Roll 80-84 or choose."
    bonuses: { pools: { sdc: 30 } }
  - name: "Characteristic (85-89): Prehensile Tail"
    description: "Roll 85-89 or choose. 3D4 feet long, of any appearance. It seizes and grasps like a monkey''s - it can turn knobs, press buttons, hold a blunt object as a club, and snare an opponent''s feet or hands - but it cannot untie rope or fire a weapon. It supports the character''s full body weight when dangling, carries about a third of it, and drags up to half at two thirds speed. No hand to hand skill or attribute bonus applies to a strike or parry made with the tail. One extra attack per melee, which the pick applies. Used with the tail only, so by hand: +1 to strike and parry with the tail, +5 to dodge with the tail itself and +20% to climb when it is used."
    bonuses: { combat: { attacks: 1 } }
  - name: "Characteristic (90-94): Retractable Claws"
    description: "Roll 90-94 or choose. Cat-like, in the fingers. About equal to a knife: 2D4 per swipe plus the P.S. damage bonus if any. Adds +10% to climb."
  - name: "Characteristic (95-00): Stocky Build"
    description: "Roll 95-00 or choose. Exceptionally broad or husky, about twice as broad as a normal human. Add 50lbs to weight."
    bonuses: { attributes: { PS: "1d4" }, pools: { sdc: "4d4" } }
  - { choose: 1, from: ["Characteristic (01-30): No unusual physical traits", "Characteristic (31-34): Pointy or Large Ears", "Characteristic (35-39): Odd Skin Color", "Characteristic (40-43): Ambidextrous", "Characteristic (44-48): Odd Hair Color", "Characteristic (49-53): Double-Jointed", "Characteristic (54-58): Unusual Eyes", "Characteristic (59-64): Extreme Amount of Body Hair", "Characteristic (65-68): Prehensile Feet and Toes", "Characteristic (69-72): Scaly Skin", "Characteristic (73-76): No Body Hair", "Characteristic (77-79): Small Horns", "Characteristic (80-84): Tough, Lumpy Skin", "Characteristic (85-89): Prehensile Tail", "Characteristic (90-94): Retractable Claws", "Characteristic (95-00): Stocky Build"], note: "Unusual Characteristics Table, step three (printed 109-110): roll percentile dice once, or choose. The page lets players and G.M.s adjust or add characteristics as they see fit." }
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
extraction_notes: "STEP FOUR IS A REQUIRED PICK OF ONE, stored 2026-10-05 off renders of printed 110 and 127. Printed 110: ''Players may select one major super ability and one minor super ability or roll on the Random Super Ability Selection Table. Or you may opt for psionics (see pg. 127). Magic is not a mutant power.'' The two branches are the options ''Step Four: Super Abilities'' and ''Step Four: Psionics'', each carrying its own power block, and the class states no super abilities of its own, so a mutant has the one picked and not the other. The super-abilities option holds the grant the class carried before, unchanged: two, one major and one minor. The psionics option is printed 127''s MUTANTS AND ALIENS paragraph, which rolls no table and prints no tier: base I.S.P. M.E. x2 plus one eight-sided die, +2D4 M.E. and +1D4 M.A., two major and four secondary psi-powers selected by the player, no changes or additions afterwards. It is written exactly as the Alien''s ''Alien Psionics'' option is, for the same page: the two lists are named rather than gated by category, and the type is `master` so that no listed power is filtered out. NOT STORED, and stated in the option''s description instead: the +10 I.S.P. per experience level (rolled-once base, no per-level field, and a class-level progression line would be false for a mutant with super abilities) and the psionic attacks per melee, which printed 127 lists under the Psionics category''s own heading for ''psionic characters'' and does not repeat for a mutant. The natural psionic''s sentence that the 10 I.S.P. ''starts at level one'' is NOT printed in the mutant''s paragraph and is not claimed here. `psionics_allowed` is not stated: this is a choice, not a table of the book''s own odds replacing a roll, and the Alien does not state it either. This replaces a 2026-09 note that said the alternative could not be stored and sent a psionic mutant to the Psionics power category; Nate ruled the branch is imported. Step two, the CAUSE of the mutation, is a background table recorded in the body. MUTANT ANIMALS (printed 111-123) are deliberately NOT imported: they are a BIO-E point-buy construction system with per-species templates, twenty-odd animals each carrying its own table of mutant changes and costs, and the catalog has no builder of any kind. Same argument that kept the robot and super-vehicle systems out - survey D7, BOOK-INGEST-AUDIT F3. 2026-10-05, THE UNUSUAL CHARACTERISTICS TABLE IS BAND-NAMED, read off renders of printed 109 and 110 (BOOK-INGEST-AUDIT.md F120). The table is headed Roll Percentile Dice once to determine odd characteristic, and prints 1-30, 31-34, 35-39, 40-43, 44-48, 49-53, 54-58, 59-64, 65-68, 69-72, 73-76, 77-79, 80-84, 85-89, 90-94 and 95-00: sixteen rows covering 01-00 with no gap or overlap, and every band already typed in a description agreed with the page. The sixteen options of the pick-one group are renamed `Characteristic (NN-NN): ...` so the table can be rolled or chosen, and the band that led each description is replaced by the roll-or-choose wording. Four rows (35-39 skin colour, 44-48 hair colour, 54-58 eyes, 59-64 body hair) send the player to a sub-table of their own; those stay in the row prose."
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
   AND instr(markdown, 'from: ["No unusual physical traits", "Pointy or Large Ears"') > 0
   AND length(markdown) = 12442;

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
  - { rolls: 4, from: ["Mutation (01-05): Keen Nightvision", "Mutation (06-10): See the Invisible", "Mutation (11-15): Turn Invisible", "Mutation (16-20): Fire-Proof Hide", "Mutation (21-22): Poisonous Bite", "Mutation (23-24): Second Mouth", "Mutation (25-26): Single Large Horn", "Mutation (27-32): Additional Arm and Hand", "Mutation (33-40): Scaly Skin", "Mutation (41-45): Thick, Lumpy Skin", "Mutation (46-50): Leather Wings", "Mutation (51-54): Additional Eye", "Mutation (55-59): Large, Heavy Tail", "Mutation (60-64): Large Fangs", "Mutation (65-69): Ape-like Body", "Mutation (70-75): Feather Wings", "Mutation (76-80): Claws", "Mutation (81-84): Large, Flat Teeth", "Mutation (85-90): Breathe Fire", "Mutation (91-95): Spit Acid", "Mutation (96-00): Additional Leg"], note: "Rifts Gigante Mutation & Special Abilities Table (printed 91-92): the page says to roll four times. It does not say what a repeated result means." }
  - { name: "Mutation (01-05): Keen Nightvision", description: "Roll 01-05 or choose. Nightvision 3D6x20 yards/meters." }
  - { name: "Mutation (06-10): See the Invisible", description: "Roll 06-10 or choose. See the invisible." }
  - { name: "Mutation (11-15): Turn Invisible", description: "Roll 11-15 or choose. Turn invisible at will." }
  - { name: "Mutation (16-20): Fire-Proof Hide", description: "Roll 16-20 or choose. Impervious to Mega-Damage fire, and add 20 M.D.C. to the creature.", bonuses: { pools: { mdc: 20 } } }
  - { name: "Mutation (21-22): Poisonous Bite", description: "Roll 21-22 or choose. Poisonous bite: 4D6 S.D.C. damage." }
  - { name: "Mutation (23-24): Second Mouth", description: "Roll 23-24 or choose. A second mouth: its bite does 1D6 M.D." }
  - { name: "Mutation (25-26): Single Large Horn", description: "Roll 25-26 or choose. A single large horn: add 1D6 M.D. to a ram attack." }
  - { name: "Mutation (27-32): Additional Arm and Hand", description: "Roll 27-32 or choose. An additional arm and hand: adds one melee attack.", bonuses: { combat: { attacks: 1 } } }
  - { name: "Mutation (33-40): Scaly Skin", description: "Roll 33-40 or choose. Scaly skin: 2D6x10 additional M.D.C.", bonuses: { pools: { mdc: "2d6x10" } } }
  - { name: "Mutation (41-45): Thick, Lumpy Skin", description: "Roll 41-45 or choose. Thick, lumpy skin: 1D6x10 additional M.D.C.", bonuses: { pools: { mdc: "1d6x10" } } }
  - { name: "Mutation (46-50): Leather Wings", description: "Roll 46-50 or choose. Leather wings: a 01-50% chance they can fly, at a speed of 2D6x10; otherwise they are vestigial." }
  - { name: "Mutation (51-54): Additional Eye", description: "Roll 51-54 or choose. An additional eye: +2 to initiative and Nightvision 40 feet (12.2 m).", bonuses: { combat: { initiative: 2 } } }
  - { name: "Mutation (55-59): Large, Heavy Tail", description: "Roll 55-59 or choose. A large, heavy tail: can strike with it for 3D6 M.D." }
  - { name: "Mutation (60-64): Large Fangs", description: "Roll 60-64 or choose. Large fangs: bite does 3D6 M.D." }
  - { name: "Mutation (65-69): Ape-like Body", description: "Roll 65-69 or choose. An ape-like body covered in fur: +10 M.D.C.", bonuses: { pools: { mdc: 10 } } }
  - { name: "Mutation (70-75): Feather Wings", description: "Roll 70-75 or choose. Feather wings: a 01-50% chance they can fly, at a speed of 3D6x10." }
  - { name: "Mutation (76-80): Claws", description: "Roll 76-80 or choose. Claws: +1D6 M.D. to punch and clawing attacks." }
  - { name: "Mutation (81-84): Large, Flat Teeth", description: "Roll 81-84 or choose. Large, flat teeth: bite does 2D4 M.D." }
  - { name: "Mutation (85-90): Breathe Fire", description: "Roll 85-90 or choose. Breathe fire: 20 foot (6.1 m) range, 3D6 M.D." }
  - { name: "Mutation (91-95): Spit Acid", description: "Roll 91-95 or choose. Spit acid: 20 foot (6.1 m) range, 4D6 M.D." }
  - { name: "Mutation (96-00): Additional Leg", description: "Roll 96-00 or choose. An additional leg: adds 20% to balance, by hand, and +1D4x10 to speed, which the pick applies.", bonuses: { attributes: { Spd: "1d4x10" } } }
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
  - THE MUTATION TABLE IS A `rolls: 4` GROUP OF TWENTY-ONE BAND-NAMED OPTIONS (2026-10-05, BOOK-INGEST-AUDIT.md F120). Printed 91-92 (file p092-p093, folios checked on the renders) heads it "Roll four times to determine random abilities and features" and prints 21 rows: 01-05, 06-10, 11-15, 16-20, 21-22, 23-24, 25-26, 27-32, 33-40, 41-45, 46-50, 51-54, 55-59, 60-64, 65-69, 70-75, 76-80, 81-84, 85-90, 91-95, 96-00 - 01-00 with no gap or overlap, each band read off the render. Each option is named `Mutation (NN-NN): ...` so the four rolls can be made or the four results picked; before this date it was a `choose: 4` whose names carried no band. The page says nothing about a repeated result, and the group''s note says so. Four entries carry the flat numbers the book states - +20 M.D.C., +1 attack, +2 initiative, +10 M.D.C. - and the two skin entries carry their M.D.C. dice as pool bonuses, which rollPoolFormula rolls once at creation. Every other entry''s mechanics are in its text: the bite, horn, tail, claw, breath and acid damages, and the flight chances and speeds. The extra leg''s +1D4x10 speed, which the page prints without a condition, is an attribute bonus on its row since 2026-10-05.
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
   AND instr(markdown, 'from: ["Keen Nightvision", "See the Invisible"') > 0
   AND length(markdown) = 13403;

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
  - name: "Ability (01-05): Additional M.D.C."
    description: "Roll 01-05 or choose. An additional 1D6x1000 M.D.C., or 2D4x100 S.D.C. in a non-mega-damage world."
  - name: "Ability (06-10): Great Nightvision"
    description: "Roll 06-10 or choose. Nightvision to 1000 ft (305 m)."
  - name: "Ability (11-15): Turn Invisible at Will"
    description: "Roll 11-15 or choose. Turn invisible at will."
  - name: "Ability (16-20): Impervious to Heat and Fire"
    description: "Roll 16-20 or choose. Impervious to heat and fire."
  - name: "Ability (21-24): Fangs and Poisonous Bite"
    description: "Roll 21-24 or choose. 3D6 damage per melee for 1D6 rounds."
  - name: "Ability (25-30): Change Size at Will"
    description: "Roll 25-30 or choose. Change size at will, from 6 to 40 feet (1.8 to 12.2 m)."
  - name: "Ability (31-33): Pair of Tentacles"
    description: "Roll 31-33 or choose. +1 attack per melee and +1 to parry."
    bonuses: { combat: { attacks: 1, parry: 1 } }
  - name: "Ability (34-40): Giant''s Strength"
    description: "Roll 34-40 or choose. Add 10 to the P.S. attribute."
    bonuses: { attributes: { PS: 10 } }
  - name: "Ability (41-45): Thick, Lumpy Skin"
    description: "Roll 41-45 or choose. Add 1D4x100 M.D.C., or S.D.C. in a non-mega-damage world."
    bonuses: { pools: { mdc: "1d4x100" } }
  - name: "Ability (46-50): Pair of Additional Arms"
    description: "Roll 46-50 or choose. +2 attacks per melee and +2 to parry."
    bonuses: { combat: { attacks: 2, parry: 2 } }
  - name: "Ability (51-54): Additional Eye"
    description: "Roll 51-54 or choose. Hawk-like vision and see the invisible."
  - name: "Ability (55-59): Prehensile Tail"
    description: "Roll 55-59 or choose. Adds one attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Ability (60-64): Battle-Hardened"
    description: "Roll 60-64 or choose. +2 on initiative, +2 to roll (the page prints only "roll"; stored as roll with punch, fall or impact), +4 to save vs horror factor."
    bonuses: { combat: { initiative: 2, roll: 2 }, saves: { horror_factor: 4 } }
  - name: "Ability (65-69): Great Speed"
    description: "Roll 65-69 or choose. Add 1D4x10 to the Spd attribute."
    bonuses: { attributes: { Spd: "1d4x10" } }
  - name: "Ability (70-75): Metamorphosis into Animal"
    description: "Roll 70-75 or choose. Metamorphosis into an animal at will."
  - name: "Ability (76-80): Retractable Claws"
    description: "Roll 76-80 or choose. Add 2D6 to all hand to hand attacks."
  - name: "Ability (81-84): Increased Healing"
    description: "Roll 81-84 or choose. Regenerates 1D4x100 M.D.C. per minute."
  - name: "Ability (85-90): Create Fire Ball"
    description: "Roll 85-90 or choose. Once per melee round at will. Range 1000 feet (305 m), does 1D4x10 M.D."
  - name: "Ability (91-95): Create Lightning Bolt"
    description: "Roll 91-95 or choose. Once per melee round at will. Range 1000 feet (305 m), does 6D6 M.D."
  - name: "Ability (96-00): Third Monstrous Eye and Ugly Head"
    description: "Roll 96-00 or choose. Psionic with ALL sensitive powers and six super-psionic powers of choice."
    psionics: { type: "master" }
  - { rolls: 3, from: ["Ability (01-05): Additional M.D.C.", "Ability (06-10): Great Nightvision", "Ability (11-15): Turn Invisible at Will", "Ability (16-20): Impervious to Heat and Fire", "Ability (21-24): Fangs and Poisonous Bite", "Ability (25-30): Change Size at Will", "Ability (31-33): Pair of Tentacles", "Ability (34-40): Giant''s Strength", "Ability (41-45): Thick, Lumpy Skin", "Ability (46-50): Pair of Additional Arms", "Ability (51-54): Additional Eye", "Ability (55-59): Prehensile Tail", "Ability (60-64): Battle-Hardened", "Ability (65-69): Great Speed", "Ability (70-75): Metamorphosis into Animal", "Ability (76-80): Retractable Claws", "Ability (81-84): Increased Healing", "Ability (85-90): Create Fire Ball", "Ability (91-95): Create Lightning Bolt", "Ability (96-00): Third Monstrous Eye and Ugly Head"], note: "Special/Natural abilities (printed 163): the page says to roll for (or the G.M. picks) three random abilities, or pick three. It does not say what a repeated result means." }
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
     printed order. The book says "Roll for (or GM pick) three random
     abilities or pick three", so it is a `rolls: 3` group of twenty
     band-named options, `Ability (NN-NN): ...`, which can be rolled or
     picked (2026-10-05, BOOK-INGEST-AUDIT.md F120; before that a choose-three
     whose names carried no band). All twenty bands were read off the render
     of printed 163: 01-05, 06-10, 11-15, 16-20, 21-24, 25-30, 31-33, 34-40,
     41-45, 46-50, 51-54, 55-59, 60-64, 65-69, 70-75, 76-80, 81-84, 85-90,
     91-95, 96-00 - 01-00 with no gap or overlap. The page says nothing about
     a repeated result, and the group''s note says so.
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
  row, beside the three-ability group. The restrictions
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
   AND instr(markdown, 'from: ["Additional M.D.C.", "Great Nightvision"') > 0
   AND length(markdown) = 14458;

-- == keeper-of-the-desert ==
UPDATE imported_classes
   SET markdown = '---
id: keeper-of-the-desert
name: Keeper of the Desert
system: rifts
source_book: Rifts World Book 14: New West p.130-133
category: rcc
tags: [wilderness]
xp_table: [0, 2111, 4221, 8441, 16881, 24881, 34881, 48441, 68441, 92481, 128481, 178481, 228881, 278881, 324481]
attribute_dice:
  IQ: "3d6"
  ME: "3d6"
  MA: "3d6"
  PS: "4d6"
  PP: "3d6"
  PE: "3d6+6"
  PB: "2d4"
  Spd: "3d6"
hit_points_base: "P.E. attribute number plus 2d6 per level of experience"
sdc_base: "1d6x10"
ppe_base: "3d4x10, +1d6 per level of experience"
horror_factor: "10+1D4"
bonuses:
  saves: { horror_factor: 4, possession: 5 }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 96, per_level: 0, note: "American, at 96%." }
    - { name: "Wilderness Survival", base: 70, per_level: 5, note: "+40%" }
    - { name: "Land Navigation", base: 56, per_level: 4, note: "+20%" }
    - { name: "Astronomy", base: 40, per_level: 5, note: "+15%" }
    - { name: "Botany", base: 40, per_level: 5, note: "+15%, desert plants only." }
    - { name: "Mathematics: Basic", base: 65, per_level: 5, note: "+20%" }
    - { name: "Hunting", base: 0, per_level: 0 }
    - { name: "Track & Trap Animals", base: 40, per_level: 5, note: "Printed as track animals (20%), read as +20%." }
    - { name: "Skin & Prepare Animal Hides", base: 45, per_level: 5, note: "+15%. Printed as skin and prepare animal hides; the catalog holds it at 30% with an ampersand." }
    - { name: "Preserve Food", base: 40, per_level: 5, note: "+15%" }
    - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two W.P.s of choice." }
    - { choose: 5, categories: ["Domestic", "Physical", "Technical", "Weapon Proficiencies", "Wilderness"], note: "Five additional skills from Domestic, Physical, Technical, W.P. or Wilderness." }
natural_abilities:
  - { name: "Nightvision", description: "600 feet." }
  - { name: "Impervious to radiation", description: "Their own included." }
  - { name: "Resistant to heat and fire", description: "Both do half damage." }
  - { name: "Sense water", description: "Locates water, surface or underground, at 52% +4% per level of experience." }
  - { name: "Radioactive", description: "Gives off low-level radiation that becomes dangerous to anyone exposed for more than a few weeks. A radiation suit or environmental body armour contains it and makes the Keeper safe to be around. This is why, as a rule, they cannot live among other races - they may cause sickness and death without meaning to, exactly as the legends warn." }
  - { name: "Horror Factor 10+1D4", description: "This is a Horror Factor the character IMPOSES, not a save; the sheet shows it as the class''s Horror Factor." }
special_abilities:
  - { choose: 1, at_levels: [1, 6, 12], from: ["Mutation (01-07): Super Psionics", "Mutation (08-12): No Psionics but Immune", "Mutation (13-18): Indestructible Beauty", "Mutation (19-22): Fire Magic", "Mutation (23-26): Metamorph", "Mutation (27-30): Supernatural Speed and Reflexes", "Mutation (31-35): Teleporter", "Mutation (36-40): Supernatural Strength", "Mutation (41-45): Summoner of Nature", "Mutation (46-55): Supernatural Endurance & M.D.C.", "Mutation (56-60): Despoiler", "Mutation (61-65): Holy One", "Mutation (66-70): Mystic Hunter", "Mutation (71-77): Extremely Radioactive", "Mutation (78-83): Camouflage and Escape", "Mutation (84-90): Energy Expulsion", "Mutation (91-95): Mega-Damage Being", "Mutation (96-00): Impervious to Magic"], note: "The book''s Random Powers and Deformities table, printed 132-133. Rolled once at first level and again at levels 6 and 12, one result each time; if preferred and the G.M. allows it, a power category or two may be selected instead. The page says nothing about a repeated result. Wherever magic is granted the character has a sorcerer''s usual limits and spends the usual P.P.E., but knows the spells intuitively." }
  - { name: "Mutation (01-07): Super Psionics", description: "Roll 01-07 or choose. I.S.P. is M.E. x10 plus 2D4 per level. One power from the Super Psionics category at levels 1, 3, 4, 6, 9, 12 and 15, and six skills of choice from the Sensitive or Physical categories. The head looks larger and slightly bumpy, or the skin and bone of the cranium is transparent and the brain shows through; +2 to the character''s Horror Factor, applied by this pick.", horror_factor_bonus: 2 }
  - { name: "Mutation (08-12): No Psionics but Immune", description: "Roll 08-12 or choose. Totally devoid of psionic power, and strangely immune to all psionic attack, magic illusion and possession." }
  - { name: "Mutation (13-18): Indestructible Beauty", description: "Roll 13-18 or choose. Physically beautiful: add 1D6+12 to P.B., rolled and applied by this pick. A mega-damage being with 1D6x10 M.D.C. +2D6 per level instead of the usual hit points and S.D.C. Horror Factor does not apply, except perhaps as awe.", bonuses: { attributes: { PB: "1d6+12" } } }
  - { name: "Mutation (19-22): Fire Magic", description: "Roll 19-22 or choose. Knows all the fire magic spells usually available to the Ley Line Walker, and is impervious to fire and heat including magical and mega-damage fire and plasma." }
  - { name: "Mutation (23-26): Metamorph", description: "Roll 23-26 or choose. Knows all the metamorphosis spells usually available to the Ley Line Walker, at double the usual duration." }
  - { name: "Mutation (27-30): Supernatural Speed and Reflexes", description: "Roll 27-30 or choose. As fast as a Juicer, and needs ten times the food and twenty times the water. Speed attribute multiplied by ten, +1 attack per melee round, +2 to initiative, +1D6 to P.P., and an automatic dodge. The attack, the initiative and the P.P. are applied by this pick; the Speed multiplier and the automatic dodge are not.", bonuses: { attributes: { PP: "1d6" }, combat: { attacks: 1, initiative: 2 } } }
  - { name: "Mutation (31-35): Teleporter", description: "Roll 31-35 or choose. Knows teleport: lesser, teleport: superior and mystic portal, and casts them at half the usual P.P.E. cost." }
  - { name: "Mutation (36-40): Supernatural Strength", description: "Roll 36-40 or choose. Bigger and bulkier: add one foot of height and 2D4x10 pounds, and P.S. becomes supernatural, so punches and kicks do mega-damage and the character can lift and carry enormously. Also a minor mega-damage creature with 1D4x10 M.D.C. +1D6 per level." }
  - { name: "Mutation (41-45): Summoner of Nature", description: "Roll 41-45 or choose. Knows the summoning spells the page lists as summon and control canines, rodents, animals, fog and rain, plus wind rush, call lightning, float in air and breathe without air, all at half the usual P.P.E. cost." }
  - { name: "Mutation (46-55): Supernatural Endurance & M.D.C.", description: "Roll 46-55 or choose. The skin is lumpy and leathery. All hit points and S.D.C. become M.D.C., the character never fatigues, needs only three or four hours of sleep, and is impervious to disease and radiation. Movement is slightly impaired: -2 to speed and -1 to strike, parry and dodge, all four applied by this pick; the M.D.C. conversion is not.", bonuses: { attributes: { Spd: -2 }, combat: { strike: -1, parry: -1, dodge: -1 } } }
  - { name: "Mutation (56-60): Despoiler", description: "Roll 56-60 or choose. Can cast fool''s gold, befuddle, energy disruption, repel animals, sickness, spoil, blind and negate magic." }
  - { name: "Mutation (61-65): Holy One", description: "Roll 61-65 or choose. Can cast sense evil, sense magic, exorcism, turn dead, heal wounds, cure minor disorders, cure illness, water to wine, tongues and dispel magic barriers." }
  - { name: "Mutation (66-70): Mystic Hunter", description: "Roll 66-70 or choose. Gains track (humanoids), intelligence, climb and prowl, all at +10%, plus the magic abilities chameleon, levitation, magic net, swim as a fish, see the invisible and armor of Ithan." }
  - { name: "Mutation (71-77): Extremely Radioactive", description: "Roll 71-77 or choose. Radiates extreme radiation to about 10 feet; anyone inside that radius takes 1D6 hit points per hour of exposure. Sees infrared and ultraviolet, and senses radioactive material and fusion reactors and engines - power armour, robots, vehicles - at 600 feet +100 feet per level." }
  - { name: "Mutation (78-83): Camouflage and Escape", description: "Roll 78-83 or choose. Horribly disfigured, with a P.B. of only 1D4 (not applied: set it by hand) and +2 to the character''s Horror Factor, applied by this pick. Changes colour like a chameleon at will and at no P.P.E. cost, contorts and dislocates joints without pain or injury, and is double-jointed and ambidextrous - which grants prowl (+10%) and escape artist (+20%) - plus the spells chameleon, shadow meld, escape, multiple image, mask of deceit and reduce self.", horror_factor_bonus: 2 }
  - { name: "Mutation (84-90): Energy Expulsion", description: "Roll 84-90 or choose. Shoots beams of radiation-based energy from the hands and eyes at +1 to strike, on top of the character''s P.P. and combat bonuses. Each beam does 2D6 M.D., or 4D6 for two simultaneous beams from both hands or both eyes, at 300 feet +100 feet per level. Each blast, single or dual, is one melee attack." }
  - { name: "Mutation (91-95): Mega-Damage Being", description: "Roll 91-95 or choose. Hit points and S.D.C. become M.D.C., and add another 1D4x100 M.D.C." }
  - { name: "Mutation (96-00): Impervious to Magic", description: "Roll 96-00 or choose. Cannot be harmed by most magic - spells, illusions, circles, wards, curses - and magic and Techno-Wizard weapons do half damage. Beneficial magic has no effect either, and P.P.E. drops to 6D6." }
equipment_starting: []
restrictions:
  - "They do not ride animals and do not pilot vehicles."
  - "Desert Keepers do not study magic; whatever magic they have comes from the mutation table."
  - "Their radioactivity means they cannot as a rule coexist with most races without a radiation suit or environmental armour."
side_effects: "Most people, human and D-bee, assume the Keepers hate all humans and loathe all beautiful things. It is not true - the majority fear humans rather than hate them, seek no vengeance for ancient wrongs, and appreciate beauty - but their isolation, appearance, powers and beliefs make for fear, misunderstanding and bloodshed. They are killed on sight out of fear, which has provoked terrible retribution and fed the legends further. So they avoid contact, frighten off travellers and intruders, and kill anyone who harms their people."
extraction_notes: "THE RANDOM POWERS AND DEFORMITIES TABLE IS A BAND-NAMED PICK-ONE GROUP TAKEN AT LEVELS 1, 6 AND 12, OVER EIGHTEEN `special_abilities` ENTRIES (2026-10-05, retrospective close-out C2; BOOK-INGEST-AUDIT.md F116). Printed 132 reads ''Roll once at first level and again at levels 6 and 12. If preferred, and allowed by the G.M., a power category or two may be selected'', so the group is `choose: 1, at_levels: [1, 6, 12]` and not three results at creation, which is what the earlier `choose: 3` gave a first-level character. Every option is named `Mutation (NN-NN): ...` with the band read off the renders of printed 132 and 133: 01-07, 08-12, 13-18, 19-22, 23-26, 27-30, 31-35, 36-40, 41-45, 46-55, 56-60, 61-65, 66-70, 71-77, 78-83, 84-90, 91-95, 96-00, which cover 01-00 with no gap or overlap. The page prints no rule for a repeated result. Earlier text here counted seventeen entries; the table prints eighteen. WHAT IS NOT MODELLED, and this is the substantial drop: eight of the eighteen grant SPELLS, and six of those name a list rather than the spells - ''all the fire magic spells usually available to the Ley Line Walker'', ''all the metamorphosis spells'', and four explicit lists. `special_abilities` CAN carry a `magic` block (ABILITY_GRANTS in js/parser.js:1644), but resolving ''all the fire magic spells available to a Ley Line Walker'' means deriving a list this book does not print, and inventing one would be worse than recording the sentence. The named lists - Despoiler, Holy One, Mystic Hunter, Summoner of Nature, Teleporter, Camouflage and Escape - could be enumerated against the catalog and are not, because doing six and not the other two would look complete and be half. Every entry''s full mechanics are in its description. FIVE ROWS CARRY THEIR UNCONDITIONAL NUMBERS AS KEYS (2026-10-05, each read off the renders of printed 132-133): 01-07 and 78-83 `horror_factor_bonus: 2`; 13-18 `bonuses.attributes.PB: 1d6+12` (the page ADDS it); 27-30 P.P. 1d6, +1 attack, +2 initiative; 46-55 Spd -2 and -1 to strike, parry and dodge. Everything else stays prose: per-level figures, every conversion of hit points and S.D.C. to M.D.C., skill percentages and ranges are not flat numbers, the 84-90 beam''s +1 to strike is conditional on the beam, Speed x10 and the automatic dodge have no key, and 78-83''s P.B. of 1D4 SETS the attribute, which a pick banked at level 6 or 12 does not apply. BOOK-INGEST-AUDIT.md F52 claimed the opposite and was falsified and closed on 2026-09-10. THE ATTRIBUTE LINE HAS NO BONUS AT ALL and the Bonuses line reads ''None'', so `bonuses` carries only the two saves from Natural Abilities. `M.D.C.: Not necessarily applicable` - whether this is a mega-damage being depends on the mutation roll, so `mdc_base` is deliberately absent and hit points and S.D.C. are stored as the default. This class grants NO related or secondary skills, which is correct for an R.C.C.; the five free picks are inside occ_skills because the book prints them there. The book gives no starting money and no equipment list; `equipment_starting` is empty rather than invented. Printed 130 is the WELDED page in this book''s cache manifest - both columns in one text block - but the stat block sits on printed 132 and the welded page is lore, so nothing was read from it. Printed 131 is a blank page in the cache, verified as a full-page art plate during the survey."
---

# Keeper of the Desert

**Alignments.** Any.

The Keepers of the Desert are nomads, considered outcasts by every civilised
human and feared as the enemy of man.

Legend says that after the Great Cataclysm the people of Salt Lake City were
subjected to terrible levels of alien radiation and magical energy from a
dimensional anomaly. Tens of thousands died. Those who survived sickened and
deformed - hair fell out, open sores covered them, their bones seemed to twist -
and those who were unaffected slaughtered thousands more for fear they carried
an alien plague. The rest were driven into the Salt Lake Desert to die.

Many did. Hundreds did not, and within a few generations began to show strange
powers. Three centuries on, the outcasts have grown in number and in inhuman
power, each one different.

## The legend, and what actually happened

The story goes that the people who drove them out were besieged - assailants who
killed hundreds in their sleep, then disaster after disaster, then demons, then
plague, until none were left - and that the Desert Outcasts did all of it in
vengeance.

They did not. Their powers did not begin to manifest with any regularity until
two generations after the exile, some thirty years after the last of their
tormentors had died. Those people died the way millions of other Cataclysm
survivors died. The irony is that driving the Outcasts into the desert is what
saved their lives.

## Manner

The typical Keeper wears a hooded robe or poncho, a hat, and a scarf across the
face. Most are close to nature, respect its power and worship its forces. They
have learned to survive in the desert and love its harsh beauty, and they
protect all life in *their* desert - humans and D-bees passing through
included - against cruelty and pointless destruction. In that they are something
like druids. Their view of justice is hard, though: anyone judged wicked or a
destroyer is destroyed in turn.

There are also stories of prospectors and adventurers lost or dying in the
desert who were rescued and magically restored by mysterious saviours, and who
swear it was the Keepers, and were shown great kindness. Few believe them.

## Lore

Also known as the Desert Keeper, the Desert Outcast and the Outcast. About four
thousand are thought to live in scattered nomadic tribes of 2D4x100 in the Salt
Lake Desert; fewer than a hundred have ever gone out into the world of men.
Average lifespan is forty to fifty years, and anyone past thirty-five is an
elder.
',
       updated_at = datetime('now')
 WHERE class_id = 'keeper-of-the-desert'
   AND instr(markdown, '- { choose: 3, from: ["Super Psionics", "No Psionics but Immune"') > 0
   AND length(markdown) = 14122;

-- == freelancer ==
UPDATE imported_classes
   SET markdown = '---
id: freelancer
name: Freelancer
system: rifts
source_book: Rifts Dimension Book 1: Wormwood p.68-70
category: occ
tags: [combat]
occ_group: men-of-arms
xp_table: [0, 1901, 3701, 7401, 14801, 22101, 31201, 41301, 54401, 75501, 105601, 140701, 190801, 240901, 292001]
mdc_base: "1d4x10+20"
bonuses:
  saves: { horror_factor: 1 }
skills:
  hand_to_hand: { costs: { expert: 1, martial_arts: 2, assassin: 2 } }
  occ_skills:
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Horsemanship: General", base: 45, per_level: 4, note: "+5%; the book calls it the general animal riding skill" }
    - { name: "Mathematics: Basic", base: 55, per_level: 5, note: "+10%; the book prints Math: Basic" }
    - { name: "Language: Native Tongue", base: 90, per_level: 0, note: "The book prints this as Language: American (90%)." }
    - { name: "Language: Demongogian", base: 80, per_level: 5, note: "80%" }
    - { choose: 1, from: ["Language: Other"], bonus: 15, note: "+15%; the book grants one language of choice" }
    - { name: "W.P. Sword" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P.: Select three of choice." }
    - { name: "Hand to Hand: Basic", note: "May be raised to Hand to Hand: Expert for one O.C.C. related skill, or to Hand to Hand: Martial Arts or Hand to Hand: Assassin for two." }
  occ_related_skills:
    count: 6
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Espionage", bonus: 5 }
      - { name: "Medical", only: ["First Aid"] }
      - { name: "Physical", except: ["Acrobatics"], bonus: 5 }
      - { name: "Pilot", except: ["Robots & Power Armor", "Robot Combat: Basic", "Robot Combat Elite", "Robot Combat Elite: Glitter Boy", "Robot Combat Elite: SAMAS", "Air Assault Armor", "Combat Pod", "Military: Tanks & APCs", "Space: Small Spacecraft", "Space: Space Fighter", "Space: Starship"], bonus: 5 }
      - { name: "Rogue", bonus: 5 }
      - { name: "Science", only: ["Mathematics: Basic", "Mathematics: Advanced", "Astronomy"], bonus: 5 }
      - { name: "Technical", bonus: 10 }
      - { name: "Weapon Proficiencies" }
      - { name: "Wilderness", bonus: 10 }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
equipment_starting:
  - { item_id: "clothing", qty: 1, note: "Travelling clothes." }
  - { item_id: "boots", qty: 1 }
  - { item_id: "gloves", qty: 1 }
  - { item_id: "hat-short-brim", qty: 1 }
  - { item_id: "sleeping-bag", qty: 1 }
  - { item_id: "blanket-light", qty: 1 }
  - { choose: 1, label: "backpack or saddlebag", qty: 1, from: ["backpack", "saddlebags"] }
  - { item_id: "utility-belt", qty: "1d4" }
  - { item_id: "angel-hair-rope", qty: 1, note: "100 feet (30.5 m)." }
  - { item_id: "grappling-hook", qty: 1 }
  - { item_id: "resin-spike", qty: "2d4" }
  - { item_id: "food-rations", qty: 1, note: "2D4 weeks of rations." }
special_abilities:
  - choose: 1
    from: ["Special (01-20): Off-World Technological Weapon", "Special (21-40): Magic Weapon or Item of Medium Power", "Special (41-60): Extraordinary Physical Strength and Endurance", "Special (61-80): Extraordinary Physical Prowess and Speed", "Special (81-00): Symbiotic Organisms"]
    note: "The Special Freelancer''s Weapons or Abilities Chart, printed 68: roll once or pick one and consult with the Game Master."
  - name: "Special (01-20): Off-World Technological Weapon"
    description: "Roll 01-20 or choose. A technological weapon or gun from another dimension - Kittani plasma weapons, energy pistols and rifles, rail guns, automatic firearms, a pair of vibro-blades. Power armor, cybernetics and bio-wizardry only if the G.M. allows it, and he has absolute say as to what these items are. The weapon''s power source has most likely been modified by Wormwood techno-wizardry to make it rechargeable or self-generating."
  - name: "Special (21-40): Magic Weapon or Item of Medium Power"
    description: "Roll 21-40 or choose. Game Master''s choice. 60% chance it was created on Wormwood, 40% chance it is a magic item from another dimension - any of the Rifts or Palladium RPG magic weapons or items."
  - name: "Special (41-60): Extraordinary Physical Strength and Endurance"
    description: "Roll 41-60 or choose. +6 to P.S. and +1D4 to P.E., plus an M.D.C. bonus of 1D4x10."
    bonuses: { attributes: { PS: 6, PE: "1d4" }, pools: { mdc: "1d4x10" } }
  - name: "Special (61-80): Extraordinary Physical Prowess and Speed"
    description: "Roll 61-80 or choose. +1D4 to P.P. and +4D6 to Spd, plus +1 on initiative and +2 to roll with impact."
    bonuses: { attributes: { PP: "1d4", Spd: "4d6" }, combat: { initiative: 1, roll: 2 } }
  - name: "Special (81-00): Symbiotic Organisms"
    description: "Roll 81-00 or choose. Symbiotic organisms are the root of this character''s powers: select one star, one worm, and one other symbiote from the claw or crawler category. A freelancer may carry as many as four symbiotic organisms in all."
restrictions: ["Cybernetics and bionics are virtually non-existent"]
side_effects: "Freelancers may carry up to four symbiotic organisms, but are looked down on as low-brow and less noble for it, especially by the knights of the Temple and the priests of light."
extraction_notes: "Money: the book states outright that money is Not applicable on Wormwood - valuables, weapons, food and services are exchanged by barter and a character is judged by his standing in the community - so no starting_money is stored. The Money paragraph runs across the p.69/p.70 break and both halves were read; it names no figure on either page. || The class states no P.P.E. at all, unlike the two knight orders in the same section, so no ppe_base is stored. || The Special Freelancer''s Weapons or Abilities Chart on printed 68 is the book''s d100 table (''Roll once or pick one and consult with the Game Master''), kept in printed order as a pick-one group whose options are named `Special (NN-NN): ...` so it can be rolled or picked (2026-10-05, retrospective close-out C2). The bands were read off the render of printed 68: 01-20, 21-40, 41-60, 61-80, 81-00, covering 01-00 with no gap or overlap. The two attribute entries carry BOTH halves now: bonuses.attributes takes a dice string and bonuses.pools takes a dice expression, the shape the Godling''s abilities already use, and the roll is made once at creation and stored as attribute_bonuses. Until RETRO-AUDIT R6 (2026-09-04) only the flat bonuses were stored and the dice halves (+1D4 P.E., +1D4 P.P., +4D6 Spd, 1D4x10 M.D.C.) were rolled by hand. || Weapons and armor are described rather than issued: the book gives ranges (four to seven different weapons; padded through full plate at 20 to 100 M.D.C.) rather than a list. || The Optional Background Table on p.69 is flavour with no mechanics and is kept as prose."
---

## Lore

The classic freelancer is a man at arms - a fighter dedicated to fighting evil
and winning back freedom for others, officially allied to the Cathedral or
another force of good. In the broadest sense the word covers any good-intentioned
mercenary or adventurer, wizard, cyborg from another world, even a dragon or
supernatural being, but the classic is a human from the lower, if not the lowest,
class of society.

Few can read or write and none has noble heritage, but most have the heart of a
lion. Human freelancers native to Wormwood might be thought of as a peasant army
dedicated to destroying the Unholy and bringing freedom to their people. Most
learned to fight from other freelancers and from friendly knights, particularly
Hospitallers and monks.

Many look to the knights of the Temple and the Hospital as their ideals and try
to be like them; some adopt a knight''s code of ethics and live up to its lofty
goals. In some cases these lowly freelancers are more true to the code of
chivalry and honor than the true knights. Just as many are lone wolves roaming
the world in search of evil, operating by their own codes and beliefs.

## GM Notes

The typical player character starts at level one or two. The average non-player
freelancer is 1D4+2 level; about 30% are 7th to 10th level and 5% are 11th to
15th.

The Optional Background Table on p.69 rolls up where the character came from:
the illegitimate child of a knight, nobleman, priest or famous hero (01-10); the
child of an apok, and regarded as a bad seed for it (11-20); a labourer''s child
who craves adventure (21-30); the child of a career freelancer (31-40); the child
of a vagabond family (41-50); a lowly D-bee trying to rise above the disdain of
being non-human (51-60); a character of high or low social class whose family was
destroyed by supernatural monsters and who wants revenge above all (61-80); a
D-bee who sees freelancing as the only way to make a good living and dislikes the
Knights of the Temple, who dislike him back (81-90); or a devout follower of the
Cathedral supporting the church with a sword (91-00).

Good characters not affiliated with any arm of the Cathedral are simply
adventurers or mercenaries and can be any O.C.C. or R.C.C.
',
       updated_at = datetime('now')
 WHERE class_id = 'freelancer'
   AND instr(markdown, 'from: ["Off-World Technological Weapon", "Magic Weapon or Item of Medium Power"') > 0
   AND length(markdown) = 8771;

-- == nb-doppleganger ==
UPDATE imported_classes
   SET markdown = '---
id: nb-doppleganger
men_of_arms: true
name: Doppleganger
system: nightbane
source_book: Nightbane RPG p.158-160
category: rcc
tags: [supernatural]
xp_table: [0, 1901, 3801, 7301, 14601, 21001, 30001, 40001, 55001, 75001, 105001, 140001, 190001, 245001, 300001]
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
ppe_base: "1d4"
horror_factor: "9 when their true nature is revealed"
psionics_allowed: false
bonuses:
  saves: { horror_factor: 2 }
  pools: { sdc: 20 }
special_abilities:
  - name: "Psionics (01-40): Awakened Psionics: Physical"
    description: "Roll 01-40 or choose, after awakening: minor psionic abilities. Two powers from the Physical category. I.S.P. is M.E. plus 2D6."
    psionics: { type: "minor", isp_base: "M.E. + 2d6", powers_starting: 2, categories_allowed: ["Physical"] }
  - name: "Psionics (01-40): Awakened Psionics: Healing"
    description: "Roll 01-40 or choose, after awakening: minor psionic abilities. Two powers from the Healing category. I.S.P. is M.E. plus 2D6."
    psionics: { type: "minor", isp_base: "M.E. + 2d6", powers_starting: 2, categories_allowed: ["Healing"] }
  - name: "Psionics (01-40): Awakened Psionics: Sensitive"
    description: "Roll 01-40 or choose, after awakening: minor psionic abilities. Two powers from the Sensitive category. I.S.P. is M.E. plus 2D6."
    psionics: { type: "minor", isp_base: "M.E. + 2d6", powers_starting: 2, categories_allowed: ["Sensitive"] }
  - name: "Psionics (41-00): No Psionic Powers"
    description: "Roll 41-00 or choose, after awakening: the Doppleganger gains no psionic abilities."
  - { choose: 1, from: ["Psionics (01-40): Awakened Psionics: Physical", "Psionics (01-40): Awakened Psionics: Healing", "Psionics (01-40): Awakened Psionics: Sensitive", "Psionics (41-00): No Psionic Powers"], note: "Roll percentiles: 40% of awakened Dopplegangers gain minor psionics, two powers from ONE of physical, healing or sensitive. A Doppleganger of a psychic character instead has all of that human''s powers and two-thirds of the human''s I.S.P. - GM''s call." }
natural_abilities:
  - name: "A Double of a Living Human"
    description: "Looks exactly like a specific person living on Earth, if slightly paler, and knows most of what that person knows. Its skills correspond to the double''s: determine the O.C.C. of the counterpart to see what skills are available."
  - name: "Supernatural Strength"
    description: "Hand to hand damage is read off the Supernatural Strength Table. Combat is otherwise the same as a human''s."
  - name: "Lives on Ambient P.P.E."
    description: "Needs no food or water, although it enjoys tasting food; it lives by absorbing ambient P.P.E."
  - name: "Rapid Healing"
    description: "Heals 1 Hit Point/S.D.C., plus P.E. bonuses if any, every hour."
  - name: "Immune to the Vampire''s Bite"
    description: "Immune to the vampire''s slow kill bite and cannot be turned into a vampire, though vampires can still kill one."
  - name: "Magic"
    description: "Dopplegangers of human magicians can use magic, and have two-thirds of their counterpart''s P.P.E. in place of 1D4 (a human sorcerer with 120 P.P.E. has a Doppleganger with 80). All others are mundane and have no magic abilities."
  - name: "Long-Lived"
    description: "Average life span 200 years after appearing in the Nightlands, usually fully grown. Ages at its double''s rate until the double dies, then stops ageing; stays fully active until the last few years of life."
restrictions: ["Nightbane never have Dopplegangers."]
side_effects: "Magic artifacts and magic weapons inflict double damage; magic spells do not. On Earth a Doppleganger dies - it shrivels up and vanishes - within 48 hours of arriving unless its human double is dead, or one of the two (human or Doppleganger) goes to the Nightlands. An awakened Doppleganger can live in the Nightlands indefinitely without harming its double. One who opposes the Nightlords is considered a traitor or a fool, and if captured by Dark minions is tortured before being slain."
extraction_notes: "PLAYABILITY: the heading on printed 158 reads Optional Player Character, and printed 159 says player character Dopplegangers are rolled up normally, noting that one player running a human and another his Doppleganger is recommended only for mature role-players. Survey D3 lists it among the entries tagged playable. EXPERIENCE: the ladder is Dopplegangar (sic) on printed 233 - 0, 1,901, 3,801, 7,301, 14,600 (sic, not 14,601), 21,001, 30,001, 40,001, 55,001, 75,001, 105,001, 140,001, 190,001, 245,001, 300,001, top of level 15 at 335,000. Stored as xp_table (Nate, 2026-09-17: an R.C.C. may carry the ladder its book prints; an O.C.C.''s ladder still wins a pairing), each overlapping lower bound stored plus one. The entry''s Experience Level line (same as humans; starts at its double''s level if the double is killed) is prose. S.D.C./HIT POINTS: printed 160 says use normal rules and add 20 to the total S.D.C. Hit points are the normal rule of printed 36 (P.E., plus 1D6, plus 1D6 per level). The +20 is a racial S.D.C. bonus and is stored as bonuses.pools.sdc, not sdc_base; the base S.D.C. (printed 36: 1D4x10 for a military, police, detective or athletic background, 3D6 for everyone else) comes from the occupation. SKILLS: printed 160 prints R.C.C. Skills as same as normal humans, taken from the counterpart''s O.C.C., so the class grants no skills and no related or secondary skills - an occupation supplies them. AWAKENED: the +2 save vs horror factor and the psionics are printed for AWAKENED Dopplegangers only. Both are stored unconditionally because a player character is necessarily awakened - printed 158 describes the unawakened as in a permanent daze, unaware of their own nature. PSIONICS: printed 160 gives Dopplegangers their own rule (before awakening none; after, 40% gain minor psionics, two powers from one of physical, healing or sensitive; I.S.P. M.E. plus 2D6), stored as a pick-one group of four options named `Psionics (NN-NN): ...` so it can be rolled or picked (2026-10-05, retrospective close-out C2). The page prints the odds as a sentence (''40% of all Dopplegangers gain minor psionic abilities''), not as a banded table: 01-40 and 41-00 are that 40% written as bands, and the three 01-40 options share the band because the page has the player select the one category. psionics_allowed is false (BOOK-INGEST-AUDIT.md F118) so the general random psionics roll is not offered on top of the entry''s own rule: printed 160''s Psionic Powers line is the whole of what the entry gives a Doppleganger - none before awakening, 40% minor after, or the psychic counterpart''s powers - and its I.S.P. line prints its own base. The psychic-counterpart case (all the human''s powers, two-thirds of its I.S.P.) is left to the GM in the note. HORROR FACTOR: 9, only when the true nature is revealed; stored as the printed phrase. P.P.E.: 1D4; the two-thirds rule for magicians'' doubles is prose under Magic. ALIGNMENT: Any; the percentile table for a specific person''s double is in the body. CREATING A SPECIFIC PERSON''S DOUBLE (same attributes as the person, 1D6 per skill) is in the body. No equipment and no money are printed."
---

## Lore

Dopplegangers are the most common inhabitants of the Nightlands. Each one looks
exactly like a particular human being living on Earth, if a little paler, and
some students of the Nightlands believe that a fifth to a third of all adult
humans have one. Children and pre-teens are very rare among them.

The resemblance runs deeper than looks. A Doppleganger knows most of what its
double knows and has the same skills and capabilities, and its personality and
alignment are related to the double''s: sometimes the same, sometimes a twisted
version that shows everything the human keeps buried, and sometimes the exact
opposite, so that the double of an evil person may be a decent being. Theories
about where they come from range from psychic energy made flesh, to living
counterparts on an alternate Earth, to a race of pseudo-humans the Nightlords
shaped using living people as models.

They are not born. They appear spontaneously in the Nightlands, usually during
the double''s youth or early adulthood, and age with the double until the double
dies. Most live in a permanent daze, acting out nightmarish mockeries of their
doubles'' lives while stronger Nightlands dwellers bully and prey on them.

When the Nightlords need one, they awaken it through psionic stimulation and
torture. An awakened Doppleganger knows what it is, longs for Earth - the World
of Light - and usually hates and envies its double enough to murder it and take
its place, because on Earth it will die within two days unless the double does.
A few awaken on their own, through the psychic backlash of the double''s death or
by being swept to Earth. Not all of them are monsters: some awakened
Dopplegangers resist the urge to kill, and some join the underground in the
City-States or fight beside Nightbane and other enemies of the Ba''al.

## GM Notes

As villains, Dopplegangers make ideal spies and assassins, and their numbers
feed the paranoia of the setting: anyone might be a visiting double, or a double
who has already killed and replaced a friend.

**Creating a Doppleganger.** A random Doppleganger is rolled up as this class,
with skills determined randomly or as the GM sees fit. For the double of a
specific person, use that person''s attributes (or roll as a typical human), and
for each of the person''s skills roll 1D6: 1-2 the Doppleganger does not know it,
3-4 it knows it at -10% of the human''s level, 5-6 it knows it at the same level.

**Alignment.** Any. For the double of a specific individual, roll percentiles or
choose:

| roll | alignment |
|---|---|
| 01-20 | the same alignment |
| 21-50 | one category down the scale (principled becomes scrupulous, aberrant becomes miscreant) |
| 51-70 | one category up the scale (anarchist becomes unprincipled; principled stays the same) |
| 71-80 | total opposite: principled and scrupulous become diabolic, anarchist becomes aberrant, unprincipled becomes miscreant, and vice versa |
| 81-00 | random: roll 1D6 and count onward from the double''s alignment, wrapping from the bottom back to principled |

**Experience.** Same as humans. If the counterpart is killed, the Doppleganger
starts at the double''s level and advances normally from there; an awakened one
can outgrow its double''s level if it is more active.

**Allies.** Dopplegangers serving the Nightlords work under Hounds, Hound
Masters, Night Princes, Hollow Men and human cultists. Those who turn on their
overlords often work with Nightbane, vampires, humans and even Guardians.
',
       updated_at = datetime('now')
 WHERE class_id = 'nb-doppleganger'
   AND instr(markdown, '- name: "Awakened Psionics: Physical"') > 0
   AND length(markdown) = 10042;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 8 classes carry their new text' AS assertion, count(*) AS got, 8 AS want
  FROM imported_classes
 WHERE (class_id = 'hu-aliens' AND instr(markdown, 'Appearance (01-30): Human-Like') > 0)
    OR (class_id = 'hu-experiments' AND instr(markdown, 'Powers (01-15): One major super ability and three minor') > 0)
    OR (class_id = 'hu-mutants' AND instr(markdown, 'Characteristic (01-30): No unusual physical traits') > 0)
    OR (class_id = 'rifts-gigantes' AND instr(markdown, 'Mutation (96-00): Additional Leg') > 0)
    OR (class_id = 'norse-giant' AND instr(markdown, 'Ability (96-00): Third Monstrous Eye and Ugly Head') > 0)
    OR (class_id = 'keeper-of-the-desert' AND instr(markdown, 'Mutation (01-07): Super Psionics') > 0)
    OR (class_id = 'freelancer' AND instr(markdown, 'Special (01-20): Off-World Technological Weapon') > 0)
    OR (class_id = 'nb-doppleganger' AND instr(markdown, 'Psionics (41-00): No Psionic Powers') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'hu-aliens' AND instr(markdown, 'from: ["Human-Like", "Humanoid with') > 0)
    OR (class_id = 'hu-experiments' AND instr(markdown, 'from: ["One major super ability and three minor", "Four minor super abilities"') > 0)
    OR (class_id = 'hu-mutants' AND instr(markdown, 'from: ["No unusual physical traits", "Pointy or Large Ears"') > 0)
    OR (class_id = 'rifts-gigantes' AND instr(markdown, 'from: ["Keen Nightvision", "See the Invisible"') > 0)
    OR (class_id = 'norse-giant' AND instr(markdown, 'from: ["Additional M.D.C.", "Great Nightvision"') > 0)
    OR (class_id = 'keeper-of-the-desert' AND instr(markdown, '- { choose: 3, from: ["Super Psionics", "No Psionics but Immune"') > 0)
    OR (class_id = 'freelancer' AND instr(markdown, 'from: ["Off-World Technological Weapon", "Magic Weapon or Item of Medium Power"') > 0)
    OR (class_id = 'nb-doppleganger' AND instr(markdown, '- name: "Awakened Psionics: Physical"') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('hu-aliens', 'hu-experiments', 'hu-mutants', 'rifts-gigantes', 'norse-giant', 'keeper-of-the-desert', 'freelancer', 'nb-doppleganger') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~162-band-names-on-eight-classes-percentile-tables.sql');
