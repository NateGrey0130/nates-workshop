-- The Mutant Dog race takes the Dog Boy's two optional tables: Type/Breed of
-- Dog (20 bands) and Mutation Abnormality (15 bands), Rifts Ultimate Edition
-- printed 148-149. Nate asked for the Dog Boy material on 2026-10-01; see
-- apps/character-creator/docs/surveys/lone-star.md, "The Dog Boy, in full".
--
-- One-off data script, run once per environment. NOT a migration.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~055-dog-boy-breeds-and-mutations.sql
--
-- Runs AFTER add-mutant-dog-class.sql, add-dog-boy-class.sql and
-- ~039-f110-psi-stalker-and-dog-races.sql, which create and split the two rows
-- this edits; all three sort before this file.
--
-- WHICH BOOK. Lone Star (1997) printed 37-38 and Rifts Ultimate Edition (2005)
-- printed 148-149 both print these tables. RUE is the later printing and the
-- book the Dog Boy already cites, and it differs: it adds a Perception bonus
-- to 17 breeds and to one abnormality, gives the Coonhound +5% where Lone Star
-- gives +2%, the Wolf a 5D6 bite where Lone Star gives 4D6, and band 86-90 a
-- +2 save vs possession. RUE's figures are stored. book-reconcile read both
-- printings off 170 dpi renders: no disagreement with either.
--
-- WHAT. Two pick-one special_abilities groups on mutant-dog, so every
-- occupation paired with the race gets them: the breeds plus "other or mixed",
-- and the abnormalities plus "none". Band 66-70 prints two breeds with
-- different S.D.C. and is two options. No code change: an R.C.C. already
-- carries pick-one groups, and an ability already grants bonuses and psionics.
--
-- APPLIED AS NUMBERS: attribute dice, S.D.C., hit points, I.S.P., initiative,
-- Perception, strike, attacks and saves. IN THE ABILITY'S TEXT: swim
-- percentages, track-by-smell changes, bite damage, size, skill bonuses, a
-- dice-valued initiative bonus and a penalty. The two "more psionics" bands
-- raise the race's one Sensitive pick to two and four. Band 96-00 (no
-- Sensitive powers) is text only and says so.
--
-- ALSO. A Free Born line on the race's restrictions (Lone Star printed 39),
-- as text; a Feral Dog Boy line on the dog-boy occupation's (Lone Star printed
-- 38-39), as text; and that occupation's note that no field holds the tables
-- is brought up to date.
--
-- MEASURED BEFORE WRITING (2026-10-01, production's rows through
-- js/compose.js composeClass): mutant-dog + dog-boy with no picks composes to
-- exactly what it did; with picks the bonuses sum, the pick count takes the
-- higher and the I.S.P. formula is unchanged.
--
-- MECHANICS. Each statement is guarded on its own new text being absent, so a
-- second run changes nothing.

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'restrictions:' || char(10), char(10) || 'special_abilities:
  - { choose: 1, from: ["Breed (01-05): Irish Water Spaniel", "Breed (06-10): Wolfhound", "Breed (11-15): Irish or English Setter", "Breed (16-20): Coonhound", "Breed (21-25): Golden Retriever", "Breed (26-30): Cocker Spaniel", "Breed (31-35): Airedale Terrier", "Breed (36-40): Beagle or Foxhound", "Breed (41-50): German Shepherd", "Breed (51-55): Bloodhound", "Breed (56-60): Boxer", "Breed (61-65): Bull Terrier or Pit Bull", "Breed (66-70): American Water Spaniel", "Breed (66-70): American Setter", "Breed (71-75): Elkhound or Malamute", "Breed (76-80): Lakeland Terrier", "Breed (81-85): Greyhound", "Breed (86-90): Bull Dog or Bullmastiff", "Breed (91-95): Rottweiler or Doberman", "Breed (96-00): Wolf", "Breed: other or mixed (table not used)"] }
  - { choose: 1, from: ["Mutation (01-15): Unusually small", "Mutation (16-30): Unusually large", "Mutation (31-35): Nearly human appearance", "Mutation (36-40): Exceptional sense of direction and balance", "Mutation (41-45): Disease scent", "Mutation (46-50): Ambidextrous", "Mutation (51-60): Tough hide", "Mutation (61-65): Keen vision", "Mutation (66-70): Rat catcher", "Mutation (71-75): Super-predator", "Mutation (76-80): Long, thick fur of an unusual color", "Mutation (81-85): Supernatural endurance", "Mutation (86-90): Additional psionics", "Mutation (91-95): Great psionic power", "Mutation (96-00): Recessive gene fluke", "Mutation: none (table not used)"] }
  - name: "Breed (01-05): Irish Water Spaniel"
    description: "Roll 01-05 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Good tracker and an excellent swimmer (base Swimming 90%); the coat is almost totally waterproof. Applied: +1 on Perception Rolls."
    bonuses: { combat: { perception: 1 } }
  - name: "Breed (06-10): Wolfhound"
    description: "Roll 06-10 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Tracks by sight, not scent: -40% to track by smell. Bite does +2D6 damage. Applied: +1D4 P.S., +1D4 P.E., +3D6 Spd, +30 S.D.C., +2 on initiative, +1 on Perception Rolls."
    bonuses: { attributes: { PS: "1d4", PE: "1d4", Spd: "3d6" }, pools: { sdc: 30 }, combat: { initiative: 2, perception: 1 } }
  - name: "Breed (11-15): Irish or English Setter"
    description: "Roll 11-15 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Good tracker and a fair swimmer (55%). Applied: +1 P.E., +2D6 S.D.C., +1 on Perception Rolls."
    bonuses: { attributes: { PE: 1 }, pools: { sdc: "2d6" }, combat: { perception: 1 } }
  - name: "Breed (16-20): Coonhound"
    description: "Roll 16-20 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). A superior sniffer: +5% to track by smell. Applied: +3 on Perception Rolls."
    bonuses: { combat: { perception: 3 } }
  - name: "Breed (21-25): Golden Retriever"
    description: "Roll 21-25 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Good tracker, hardy, and a natural swimmer (base 80%). Applied: +1 P.S., +1 P.E., +3D6 S.D.C., +2 on Perception Rolls."
    bonuses: { attributes: { PS: 1, PE: 1 }, pools: { sdc: "3d6" }, combat: { perception: 2 } }
  - name: "Breed (26-30): Cocker Spaniel"
    description: "Roll 26-30 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Excellent tracker: +4% to track by smell. Hardy, and an excellent swimmer (base 80%). Applied: +2D6 S.D.C., +1 on Perception Rolls."
    bonuses: { pools: { sdc: "2d6" }, combat: { perception: 1 } }
  - name: "Breed (31-35): Airedale Terrier"
    description: "Roll 31-35 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Very good tracker: +2% to track by smell. Alert and aggressive hunter; fair swimmer (base 40%). Applied: +10 S.D.C., +1 on initiative, +2 on Perception Rolls."
    bonuses: { pools: { sdc: 10 }, combat: { initiative: 1, perception: 2 } }
  - name: "Breed (36-40): Beagle or Foxhound"
    description: "Roll 36-40 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Excellent tracker: +6% to all tracking by smell. Reduce average size by 10% (never taller than 4 feet / 1.2 m). Bite does 1D4 on a nip and 2D4 at full strength. Applied: +3 on Perception Rolls."
    bonuses: { combat: { perception: 3 } }
  - name: "Breed (41-50): German Shepherd"
    description: "Roll 41-50 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Good tracker; alert, highly intelligent, friendly and extremely loyal, and loves to work with humans. Good swimmer (60%). Applied: +1D6 I.Q., +1D6 P.E., +1D6 Spd, +15 S.D.C., +1 on initiative, +2 on Perception Rolls."
    bonuses: { attributes: { IQ: "1d6", PE: "1d6", Spd: "1d6" }, pools: { sdc: 15 }, combat: { initiative: 1, perception: 2 } }
  - name: "Breed (51-55): Bloodhound"
    description: "Roll 51-55 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). The super-scent tracker: +12% to all scent abilities. Fair swimmer (45%). Applied: +1D6 S.D.C., +2 on Perception Rolls."
    bonuses: { pools: { sdc: "1d6" }, combat: { perception: 2 } }
  - name: "Breed (56-60): Boxer"
    description: "Roll 56-60 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Very good tracker: +4% to all track by smell skills. Stocky and powerful; can leap 15 feet (4.6 m) high or long after a short running start. Bite does 2D4 on a nip and 3D6 S.D.C. at full strength. Applied: +1 I.Q., +1D4 P.E., +1D4 P.S., +20 S.D.C., +1 on Perception Rolls."
    bonuses: { attributes: { IQ: 1, PE: "1d4", PS: "1d4" }, pools: { sdc: 20 }, combat: { perception: 1 } }
  - name: "Breed (61-65): Bull Terrier or Pit Bull"
    description: "Roll 61-65 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Reduce size by 10% (never taller than 5 feet / 1.5 m). Only a fair tracker: -30% to track by smell. Bite does 2D6 S.D.C. on a nip and 4D6 at full strength. Applied: +2D6 P.E., +2D4 P.S., +40 S.D.C.."
    bonuses: { attributes: { PE: "2d6", PS: "2d4" }, pools: { sdc: 40 } }
  - name: "Breed (66-70): American Water Spaniel"
    description: "Roll 66-70 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Very good tracker: +2 to track by smell. Very good swimmer (70%). Good natured and loyal, with an independent streak. Applied: +1D6 S.D.C., +2 on Perception Rolls."
    bonuses: { pools: { sdc: "1d6" }, combat: { perception: 2 } }
  - name: "Breed (66-70): American Setter"
    description: "Roll 66-70 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Very good tracker: +2 to track by smell. Very good swimmer (70%). Good natured and loyal, with an independent streak. The band is shared with the American Water Spaniel, which gets 1D6 S.D.C. where the Setter gets 2D6. Applied: +2D6 S.D.C., +2 on Perception Rolls."
    bonuses: { pools: { sdc: "2d6" }, combat: { perception: 2 } }
  - name: "Breed (71-75): Elkhound or Malamute"
    description: "Roll 71-75 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Good tracker, big and powerful. Bite does +1D6 damage. An Elkhound typically stands 1D6+1 inches over six feet (1.8 m). Applied: +1D4 P.S., +1D4 P.E., +3D6 Spd, +20 S.D.C., +2 on initiative, +1 on Perception Rolls."
    bonuses: { attributes: { PS: "1d4", PE: "1d4", Spd: "3d6" }, pools: { sdc: 20 }, combat: { initiative: 2, perception: 1 } }
  - name: "Breed (76-80): Lakeland Terrier"
    description: "Roll 76-80 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Reduce size by 10% (rarely taller than 4 feet / 1.2 m), but tough and aggressive. Fair swimmer (40%). Applied: +2D6 S.D.C., +2 on initiative, +1 to strike, +2 on Perception Rolls."
    bonuses: { pools: { sdc: "2d6" }, combat: { initiative: 2, strike: 1, perception: 2 } }
  - name: "Breed (81-85): Greyhound"
    description: "Roll 81-85 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Tracks by sight, not scent, equal to the human sight tracking skill at 74%; -40% to track by smell. +1D4 on initiative, rolled once (not applied automatically). Applied: +1D4X10 Spd, +1D4 P.E., +2 on Perception Rolls."
    bonuses: { attributes: { Spd: "1d4x10", PE: "1d4" }, combat: { perception: 2 } }
  - name: "Breed (86-90): Bull Dog or Bullmastiff"
    description: "Roll 86-90 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Poor tracker: -30% to track by smell, but tough and powerfully built. Reduce the Spd attribute by 1D4 points (not applied automatically). The Bullmastiff adds 1D6 damage to its bite. Applied: +1D6 P.S., +1D6 P.E., +20 S.D.C.."
    bonuses: { attributes: { PS: "1d6", PE: "1d6" }, pools: { sdc: 20 } }
  - name: "Breed (91-95): Rottweiler or Doberman"
    description: "Roll 91-95 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). A fair tracker by smell (-5%), but powerfully built, clever and loyal; ideal for outdoor work and as a guard dog. Applied: +1 I.Q., +1D6 P.S., +1D6 P.E., +2D6 Spd, +20 S.D.C., +1 on Perception Rolls."
    bonuses: { attributes: { IQ: 1, PS: "1d6", PE: "1d6", Spd: "2d6" }, pools: { sdc: 20 }, combat: { perception: 1 } }
  - name: "Breed (96-00): Wolf"
    description: "Roll 96-00 or choose (Rifts Ultimate Edition p.148-149, optional Type/Breed of Dog table). Good tracker and powerfully built. Bite does 2D6 S.D.C. on a nip and 5D6 at full strength. Wolves and wild canines are not a regular part of the Psi-Hound forces: only a handful of experimental mutants exist, and they challenge a weak leader rather than revere humans. Applied: +1D6 P.S., +2D4 P.E., +3D6 Spd, +30 S.D.C., +2 on initiative, +3 on Perception Rolls."
    bonuses: { attributes: { PS: "1d6", PE: "2d4", Spd: "3d6" }, pools: { sdc: 30 }, combat: { initiative: 2, perception: 3 } }
  - name: "Breed: other or mixed (table not used)"
    description: "The breed table is optional. Choose this for a breed it does not list, a mixed breed, or when the table is not in use: the standard Dog Boy figures stand. The same page gives an optional height table: 01-10 four feet, 11-30 five feet, 31-50 five feet six inches, 51-65 five feet ten inches, 66-80 six feet, 81-90 six feet four inches, 91-00 six feet eight inches."
  - name: "Mutation (01-15): Unusually small"
    description: "Roll 01-15 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Three feet, four inches tall (one meter) and about 45 lbs (20 kg). +5% to the Prowl and Climbing skills where the character has them."
  - name: "Mutation (16-30): Unusually large"
    description: "Roll 16-30 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Seven feet, three inches tall (2.2 m) and 400 lbs (180 kg). Applied: +2 P.S., +2D6+10 S.D.C.."
    bonuses: { attributes: { PS: 2 }, pools: { sdc: "2d6+10" } }
  - name: "Mutation (31-35): Nearly human appearance"
    description: "Roll 31-35 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Large pug nose, little or no body hair, excellent color vision and full human speech. Reduce the scent skill abilities by 25%."
  - name: "Mutation (36-40): Exceptional sense of direction and balance"
    description: "Roll 36-40 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). +20% to Land Navigation, +10% to Wilderness Survival and +5% to gymnastic skills. Applied: +1 on Perception Rolls."
    bonuses: { combat: { perception: 1 } }
  - name: "Mutation (41-45): Disease scent"
    description: "Roll 41-45 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). A heightened sense of smell focused on disease: +10% to track by scent and to recognize scent, and can smell the chemical changes of cancer and malignant tumors, epilepsy, diabetes and brain damage in humans and fellow canines (not D-Bees). Also has the psionic power of Psychic Diagnosis. May be recruited to the Sniffer Special Forces."
    psionics: { type: "master", isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience", powers: ["Sense Evil", "Sense Magic", "Sixth Sense", "Empathy", "Psychic Diagnosis"] }
  - name: "Mutation (46-50): Ambidextrous"
    description: "Roll 46-50 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Uses either hand with equal skill; the Paired Weapons skill is automatic. +10% to Climbing and +5% to Pick Locks, Pick Pockets, Palming and Concealment. Applied: +1 attack per melee round."
    bonuses: { combat: { attacks: 1 } }
  - name: "Mutation (51-60): Tough hide"
    description: "Roll 51-60 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Tough, thick or scaly skin. Applied: +30 S.D.C.."
    bonuses: { pools: { sdc: 30 } }
  - name: "Mutation (61-65): Keen vision"
    description: "Roll 61-65 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Keen 20/20 color vision; alert and observant. Applied: +1 on initiative."
    bonuses: { combat: { initiative: 1 } }
  - name: "Mutation (66-70): Rat catcher"
    description: "Roll 66-70 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). +10% to tracking and prowling skills, and +2 on initiative and +4 to damage when hunting rats and rodent-like creatures, rodent-like D-Bees included."
  - name: "Mutation (71-75): Super-predator"
    description: "Roll 71-75 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Built like a rock, and mean tempered, quick to brawl, strong willed, defiant and independent. +1D6 S.D.C. damage to punches, kicks and bites. Applied: +3D6 hit points, +16 S.D.C., +1 attack per melee round, +6 to save vs horror factor."
    bonuses: { pools: { hp: "3d6", sdc: 16 }, combat: { attacks: 1 }, saves: { horror_factor: 6 } }
  - name: "Mutation (76-80): Long, thick fur of an unusual color"
    description: "Roll 76-80 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Stark white, light green, bright red, grayish blue, metallic silver or the like (pick one). Water resistant, and warm without extra clothing down to 30 degrees below zero, but hot and uncomfortable above 72 degrees Fahrenheit."
  - name: "Mutation (81-85): Supernatural endurance"
    description: "Roll 81-85 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Lifts and carries 100 times the P.S. attribute number and rarely fatigues (active for six hours without tiring). Applied: +3 to save vs poison, +3 to save vs drugs, +3 to save vs disease."
    bonuses: { saves: { toxins_poisons: 3, harmful_drugs: 3, disease: 3 } }
  - name: "Mutation (86-90): Additional psionics"
    description: "Roll 86-90 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). One more psychic Sensitive power of choice, for two in all. Applied: +2D6 I.S.P., +2 to save vs possession."
    bonuses: { pools: { isp: "2d6" }, saves: { possession: 2 } }
    psionics: { type: "master", isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience", powers_starting: 2 }
  - name: "Mutation (91-95): Great psionic power"
    description: "Roll 91-95 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). Three more psychic Sensitive powers of choice, for four in all. Applied: +2D6+6 I.S.P.."
    bonuses: { pools: { isp: "2d6+6" } }
    psionics: { type: "master", isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience", powers_starting: 4 }
  - name: "Mutation (96-00): Recessive gene fluke"
    description: "Roll 96-00 or choose (Rifts Ultimate Edition p.149, optional Mutation Abnormality table). No Sensitive powers at all, and none of the Dog Boy sensing abilities (sense supernatural, sense magic, sense and track by psychic scent). Instead select seven Physical psionic powers, or one Super power and three Physical. NOT APPLIED AUTOMATICALLY: the race still lists its Sensitive powers; leave them unused and record the Physical picks by hand."
  - name: "Mutation: none (table not used)"
    description: "The mutation table is optional. Choose this when it is not in use: no abnormality."' || char(10) || 'restrictions:' || char(10) || '  - "Free Born (Rifts World Book 13: Lone Star p.39): the offspring of runaways take an ordinary occupation in place of the Dog Boy O.C.C. - typically Wilderness Scout, Headhunter, mercenary soldier, City Rat, Vagabond, spy, Rogue Scholar, Rogue Scientist, Body Fixer or Operator - and about half still learn the Dog Boy''s skills from a relative. Whatever the occupation, the book gives a Free Born eight secondary skills at level one and two more at levels 2, 4, 8, 10 and 12; no credits, but 4D6x1000 credits in sellable black market items; and little equipment: clothes, perhaps light M.D.C. or DPM armor, one vibro-blade and two other weapons, and no vehicle. NOT APPLIED AUTOMATICALLY: the occupation''s own skill counts, money and equipment are what the sheet shows."' || char(10))
 WHERE class_id = 'mutant-dog' AND instr(markdown, 'special_abilities:') = 0
   AND instr(markdown, char(10) || 'restrictions:' || char(10)) > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - The optional Height and Type/Breed tables stay summarised in the Dog Boy
    O.C.C.''s GM Notes; no schema field holds them.', '  - The optional Type/Breed of Dog and Mutation Abnormality tables (RUE
    printed 148-149) are two pick-one special_abilities groups, each with a
    table-not-used option; the Height table is in the breed group''s last
    option. A band''s attribute, S.D.C., hit point, I.S.P., initiative,
    Perception, strike, attack, save and psionic figures are applied; its
    swim, scent, bite, size and skill figures are in the ability''s text.
    Rifts World Book 13: Lone Star printed 37-38 carries an earlier printing
    of both tables without the Perception bonuses; RUE''s figures are stored.
    Added 2026-10-01 (docs/surveys/lone-star.md, The Dog Boy, in full).')
 WHERE class_id = 'mutant-dog' AND instr(markdown, 'Breed (96-00): Wolf') > 0
   AND instr(markdown, 'stay summarised in the Dog Boy') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, '  - The optional Height and Type/Breed percentile tables (and their per-breed
    bonuses) are player options that no schema field holds; they are
    summarised in GM Notes.', '  - The optional Height, Type/Breed and Mutation Abnormality tables are
    pick-one choices on the mutant-dog race since 2026-10-01; the GM Notes
    summary below predates that and is kept as a reading aid.')
 WHERE class_id = 'dog-boy' AND instr(markdown, 'player options that no schema field holds') > 0;

UPDATE imported_classes
   SET markdown = replace(markdown, char(10) || 'restrictions:' || char(10), char(10) || 'restrictions:' || char(10) || '  - "Feral Dog Boy (Rifts World Book 13: Lone Star p.38-39): a runaway from the Dog Packs is still this class, with the same skills and abilities, and is hunted by the CS as a traitor. One who has left keeps or replaces the issued kit with an adventurer''s: clothing or M.D.C. body armor (Coalition or otherwise), backpack, sleeping bag, a couple of sacks, utility belt, sunglasses or tinted goggles, air filter or gas mask, personal items, vibro-blades, a neuro-mace and two other weapons of choice, and perhaps a hover vehicle, jet pack or souped-up motorcycle or car; no power armor or robots. NOT APPLIED AUTOMATICALLY: the equipment list below is the soldier''s."' || char(10))
 WHERE class_id = 'dog-boy' AND instr(markdown, 'Feral Dog Boy (Rifts World Book 13') = 0
   AND instr(markdown, char(10) || 'restrictions:' || char(10)) > 0;

-- Read the result back.
SELECT 'mutant-dog carries both pick-one groups' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-dog'
   AND instr(markdown, 'Breed (96-00): Wolf') > 0 AND instr(markdown, 'Mutation: none (table not used)') > 0
   AND instr(markdown, 'Mutation (96-00): Recessive gene fluke') > 0;
SELECT 'the block sits before restrictions, once' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-dog'
   AND instr(markdown, 'special_abilities:') > 0
   AND instr(markdown, 'special_abilities:') < instr(markdown, char(10) || 'restrictions:')
   AND length(markdown) - length(replace(markdown, 'special_abilities:', '')) = length('special_abilities:');
SELECT 'the Free Born line is on the race' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'mutant-dog' AND instr(markdown, '  - "Free Born (Rifts World Book 13: Lone Star p.39)') > 0;
SELECT 'the Feral line is on the occupation' AS assertion, count(*) AS got, 1 AS want
  FROM imported_classes WHERE class_id = 'dog-boy' AND instr(markdown, '  - "Feral Dog Boy (Rifts World Book 13: Lone Star p.38-39)') > 0;
SELECT 'neither class still says no field holds the tables' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes WHERE class_id IN ('mutant-dog', 'dog-boy')
   AND (instr(markdown, 'stay summarised in the Dog Boy') > 0 OR instr(markdown, 'player options that no schema field holds') > 0);

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~055-dog-boy-breeds-and-mutations.sql');
