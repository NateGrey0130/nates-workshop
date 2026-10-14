-- Take BOOK-INGEST-AUDIT F138: bonuses that are not skill bonuses move from prose to keys
-- 13 classes, each replaced whole: dragon-juicer, outback-mutie, phreaker-military-grunt, mutant-psi-stalker, pseudo-men, russian-fire-sorcerer, russian-mystic-kuznya, gifted-one-russian, roane-piper, witch, lyn-srial, lyn-srial-cloudweaver, lyn-srial-sky-knight.
--
-- One-off data script, run once per environment. NOT a migration - it changes
-- rows, not schema.
--
--   node scripts/d1-apply.mjs --local apps/character-creator/db/~193-book-ingest-audit-f138-other-keys.sql
--
-- Written by scripts/class-fix-sql.mjs. Each UPDATE is guarded on a sentence
-- of the text it replaces (or on the absence of a string only the new text
-- has) AND on the old text's exact length, so it cannot fire
-- against a row edited since, and a second run is a no-op. Every markdown
-- parsed clean before this was written.
-- BOOK-INGEST-AUDIT F138, the other keys. Each figure read off a render of its cited page, 2026-10-14:
-- - dragon-juicer: +1D4 initiative (Juicer Uprising printed 47) stored as combat.initiative "1d4", rolled once at creation.
-- - outback-mutie, phreaker-military-grunt: the Serpent option's Spd 1D6+6 (Australia printed 129) as attribute_dice on the option.
-- - mutant-psi-stalker: +4 on Perception Rolls (RUE printed 153) as combat.perception.
-- - pseudo-men: Automatic Dodge +3 on band 01-10 (Madhaven printed 72) as combat.automatic_dodge on the option.
-- - russian-fire-sorcerer: +4 to save vs magic fumes (Mystic Russia printed 109) as a saves.other entry.
-- - russian-mystic-kuznya: +1D6+12 P.S. (Mystic Russia printed 120) as an attribute dice bonus.
-- - gifted-one-russian: a Master Psionic selects no O.C.C. Related skills (Mystic Russia printed 151): related_skills_count 0 on both Master gifts.
-- - roane-piper: the psionics percentile (D-Bees of North America printed 172) as a banded pick group, with psionics_allowed false.
-- - witch, lyn-srial, lyn-srial-cloudweaver, lyn-srial-sky-knight: values stay prose (the witch's Sixth Sense has no tier; the Awe Factor by Nate's ruling of 2026-10-12); only the sentence giving a false reason is rewritten.

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
  combat: { initiative: "1d4", roll: 2, attacks: 2 }
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
extraction_notes: "The book prints +1D4 on initiative (printed 47), stored as dice and rolled once at creation (BOOK-INGEST-AUDIT F138). Impervious to disease and to normal cold and heat is prose rather than a save, because it is an immunity rather than a bonus. The class is an O.C.C. rather than an R.C.C. even though the character becomes a supernatural being - the book prints O.C.C. Skills, O.C.C. Related Skills and Secondary Skills for it, and the transformation happens to a person who already had an occupation. Standard equipment names Dragon Skin Combat Armor at 100 M.D.C., which has no gear row yet. 2026-10-05 (BOOK-INGEST-AUDIT.md F120): the insanity table is printed on p.49 under Insanity - four rows, 01-30, 31-60, 61-90, 91-00 - and the page says to roll on it AFTER TWO YEARS as a Dragon Juicer. Nothing is rolled at creation and nothing is tied to a level, so it is deliberately NOT a pick group: it stays in side_effects, to be rolled by hand when the two years are up. The page adds two things side_effects words briefly: on 61-90 the Juicer Psychosis roll is made again if either phobia comes up, and a 91-00 dragon vampire also rolls once on the neurosis table and once on the obsession table of the Rifts RPG."
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
   AND instr(markdown, 'the bonuses block stores integers for combat') > 0
   AND length(markdown) = 11415;

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
    description: "Roll 21-25 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). No legs: a serpentine body 1D4+3 feet (1.2 to 2.1 m) long, scaled in half of these mutants. Small or flat nose, a round head without pronounced features, and half the hair of a normal human. Half have thin or shrivelled arms and hands (-15% on all skills that need the hands). Applied: Spd is rolled on 1D6+6 in place of the usual dice, crawling (or travel by psionics). NOT APPLIED AUTOMATICALLY: natural A.R. 10, and a natural prowl of 50% +4% per level of experience."
    attribute_dice: { Spd: "1d6+6" }
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
extraction_notes: "WB19 Australia printed 126-131 (cache p127-p132, cache page = printed folio + 1), read off the text layer in column order; the tables on printed 128-130 were checked against 150 dpi renders. The Mutants section opens on printed 126, Mutant R.C.C.s and the tables are printed 128-130, and the block headed Outback Mutie R.C.C. (also known as Outbacker Mutant or just mutant) is printed 131. || CATEGORY: the book heads it an R.C.C. and it is stored as category rcc that is its own occupation (it prints O.C.C. Related and Secondary skills), so it can also be paired with an occupation, which then supplies the related and secondary skills. The block prints no attributes; the mutants are humans, so the eight attribute dice are the human 3D6 and hit points are the human P.E. + 1D6 per level, neither printed in this block. It states no S.D.C. base; a race is men_of_arms false. || XP: the Mutants, Road Sentinel & Special Ops Soldier ladder on the Experience Tables, printed 224, read off a render. || SKILLS: headed Common Outback Skills. Speaks Australian at 80%+2D4% is stored as Language: Australian English at 80 with per_level 0 (the convention for a language printed as a flat percentage); the 2D4 is not stored. Law (+10%) is the catalog row Law (35/5). The Horsemanship-or-Pilot pick is a four-way choice at +10. Hand to Hand: Expert costs one related skill, Martial Arts or Assassin (if evil) two. || RELATED: six at level one, three at level two, one at levels 3, 6, 9 and 12. Communication except Laser is Laser Communications. Electrical Basic only is Basic Electronics; Mechanical Basic and Automotive only is Basic Mechanics and Automotive Mechanics. Pilot except Robot Elite, Power Armor and military vehicles is stored as the robot and power armor rows, the five Military: rows and the two Fighter Combat rows. Cowboy and Espionage are printed None and left out; the book lists no Horsemanship category. || SECONDARY: two at levels 1, 3, 6, 8 and 11, stored as count 2 plus four schedule entries of 2. || MONEY: 2D6x100 dollars stored (printed 2D6x$100); the 1D6x100 dollars in tradeable goods (printed lD6x$100) is in GM Notes. Australian dollars equal credits. || EQUIPMENT not stored as rows: the fancy Sunday clothes, the S.D.C. sidearm, 1D4 ammo clips and the 1D4 old style books of matches have no catalog row and are in GM Notes. The armor choice offers this book''s five homespun M.D.C. rows. || MUTANT TABLES (Nate''s decision 2 in the survey, 2026-10-01: held by the class, not prose): the three percentile tables of the Mutant R.C.C.s section are three pick-one special_abilities groups whose option names carry the band, read off the text layer and checked against 150 dpi renders of printed 128, 129 and 130. Each table is headed Pick one or make a random roll and neither class block states a number of rolls, so each class takes ONE result on each table. Physical Deformity, printed 128-129: 17 bands, 01-05 to 96-00, stored as 24 options because six bands print a half or a share of the mutants with further features and figures (31-35, 36-45, 46-55, 56-65 and 66-75 are two options each, 76-80 is three); the options of one band share its band, so a roll returns all of them and the player rolls the split. Special Mutant Powers, printed 130: 11 bands, 11 options. Additional Special Abilities, printed 130: 13 bands, 13 options. All three run 01 to 00 with no gap or overlap (41 bands in all, the survey''s count). APPLIED AS NUMBERS: attribute dice and flat attribute changes (the -4 Spd, -3 P.B. and -2 Spd are negative bonuses), S.D.C., attacks, initiative, parry, dodge, saves, the Ecto-Freak''s +4D6 I.S.P., and the psionics and magic blocks. IN THE OPTION''S TEXT ONLY: natural A.R., skill-equivalent percentages, leap distances, nightvision, claws and quills, the one-third sub-rolls of the feline and canine bands (+8 P.B. or M.A. and a die added to one attribute of choice), and every Mega-Damage result. M.D.C. NOT STORED: Hit Points (only) count as M.D.C. (bands 61-80 and 81-90 of the powers table, 31-40 and 41-50 of the abilities table) and the Tanker''s 4D4x10 + P.E. M.D.C. (the text layer prints 4D4xlO; the render shows 4D4x10) are text, because the conversion flag the format has turns S.D.C. into M.D.C. as well and a pool bonus needs a base the class does not state. PSIONICS: the book prints an I.S.P. figure for none of the psychic results. The two it calls or implies major (Psi-Healer, a reading, and Ecto-Freak, printed Major) store the standard major formula; the four it calls Master (Prognosticator, Fighter, Sensitive, TK-Master) store no isp_base. A dice-valued number of powers (1D4) is stored as its maximum with a note to roll, as the Hunter Cat does. Mind Bleeder and Mind Melter (roll for that R.C.C.) are stored as a master tier with occ_options naming the production class, the Godling''s mechanism. Power names follow the catalog: Commune with Spirit, See The Invisible, Object Read (Psychometry), Psychic Omni-Sight, Telemechanic Mental Operation (printed Telemechanic Operation); all psionic Healing abilities is the 17 general Healing rows; all Telekinetic abilities from the physical category is Telekinesis, Telekinetic Leap, Lift, Punch and Push; all ectoplasmic abilities is Ectoplasm and Ectoplasmic Disguise. The Nate''s P.P.E. (6D6 + P.E., +2D6 per level) is text, and its one spell per level equal to the character''s level is stored as up_to_character_level. The G.M. options (substitute other animals; Psyscape classes) are in GM Notes. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. A READING, not a printed rule: Australia printed 128-131 print no Psionics line for a mutant and never mention the standard roll, where the same book prints one when it means it (the Mokoloi on printed 141: standard, same as humans). Printed 128 gives mutants psionic OR magical enhancement and the Special Mutant Powers table of printed 130 is the only mechanism given for either, so the table is taken as the whole answer and a Nate, Magic Back Rounder or Tanker is not also offered the standard roll."
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
   AND instr(markdown, 'NOT APPLIED AUTOMATICALLY: Spd becomes 1D6+6') > 0
   AND length(markdown) = 42921;

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
    description: "Roll 21-25 or choose (Rifts World Book 19: Australia p.129, Physical Deformity table). No legs: a serpentine body 1D4+3 feet (1.2 to 2.1 m) long, scaled in half of these mutants. Small or flat nose, a round head without pronounced features, and half the hair of a normal human. Half have thin or shrivelled arms and hands (-15% on all skills that need the hands). Applied: Spd is rolled on 1D6+6 in place of the usual dice, crawling (or travel by psionics). NOT APPLIED AUTOMATICALLY: natural A.R. 10, and a natural prowl of 50% +4% per level of experience."
    attribute_dice: { Spd: "1d6+6" }
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
extraction_notes: "WB19 Australia printed 126-132 (cache p127-p133, cache page = printed folio + 1), read off the text layer in column order; the tables on printed 128-130 were checked against 150 dpi renders. The Mutants section opens on printed 126, Phreakers is printed 127-128, the tables are printed 128-130, and the block headed Phreaker Military Grunt R.C.C. starts at the foot of printed 131 and fills the first column of printed 132. The City O.C.C. list on printed 105 files it under Other as Phreaker/Mutant R.C.C. || CATEGORY: the book heads it an R.C.C. and it is stored as category rcc that is its own occupation (it prints O.C.C. Related and Secondary skills). The block prints no attributes; the mutants are humans, so the eight attribute dice are the human 3D6 and hit points are the human P.E. + 1D6 per level, neither printed in this block. It states no S.D.C. base; a race is men_of_arms false, although the class is a soldier. || XP: the Mutants, Road Sentinel & Special Ops Soldier ladder on the Experience Tables, printed 224, read off a render. || SKILLS: headed Typical Skills. Speaks English at 86%+3D4% is stored as Language: Australian English at 86 with per_level 0; the 3D4 is not stored. The note on printed 105 gives every Tech-City character English at a minimum of 84+1D6% and literacy at +20%; the class block''s own 86%+3D4% and Literacy (+15%) are what is stored. Literacy is Literacy: Native Language; Read Sensory Equipment is Sensory Equipment; Body Building is Body Building & Weight Lifting; W.P. Heavy Weapons is W.P. Heavy Military Weapons; Pilot Jet Pack or Hovercycle is a choice between Jet Packs and Hovercycles, Skycycles & Rocket Bikes; Automobile or Hovercraft is a choice between Automobile and Hover Craft (ground). Hand to Hand: Martial Arts costs one related skill; the book offers no other style. || RELATED: four Military and five others are stored as count 9 with a floor of four Military; two more at levels 3, 7, 11 and 15. Science Astronomy and Math only is read as Astronomy and both Mathematics rows. Cowboy, Espionage and Rogue are printed None and left out; the book lists no Horsemanship category. || MONEY: 1D6x1000 dollars in personal savings stored (printed lD6x$1000); the monthly salary of 1500 dollars +100 per level, with room, board and medical care, is in GM Notes. || EQUIPMENT not stored as rows: jacket, full brimmed hat and entrenching tool have no catalog row and are in GM Notes. Six reloads are stored as six E-Clips. || MUTANT TABLES (Nate''s decision 2 in the survey, 2026-10-01: held by the class, not prose): the three percentile tables of the Mutant R.C.C.s section are three pick-one special_abilities groups whose option names carry the band, read off the text layer and checked against 150 dpi renders of printed 128, 129 and 130. Each table is headed Pick one or make a random roll and neither class block states a number of rolls, so each class takes ONE result on each table. Physical Deformity, printed 128-129: 17 bands, 01-05 to 96-00, stored as 24 options because six bands print a half or a share of the mutants with further features and figures (31-35, 36-45, 46-55, 56-65 and 66-75 are two options each, 76-80 is three); the options of one band share its band, so a roll returns all of them and the player rolls the split. Special Mutant Powers, printed 130: 11 bands, 11 options. Additional Special Abilities, printed 130: 13 bands, 13 options. All three run 01 to 00 with no gap or overlap (41 bands in all, the survey''s count). APPLIED AS NUMBERS: attribute dice and flat attribute changes (the -4 Spd, -3 P.B. and -2 Spd are negative bonuses), S.D.C., attacks, initiative, parry, dodge, saves, the Ecto-Freak''s +4D6 I.S.P., and the psionics and magic blocks. IN THE OPTION''S TEXT ONLY: natural A.R., skill-equivalent percentages, leap distances, nightvision, claws and quills, the one-third sub-rolls of the feline and canine bands (+8 P.B. or M.A. and a die added to one attribute of choice), and every Mega-Damage result. M.D.C. NOT STORED: Hit Points (only) count as M.D.C. (bands 61-80 and 81-90 of the powers table, 31-40 and 41-50 of the abilities table) and the Tanker''s 4D4x10 + P.E. M.D.C. (the text layer prints 4D4xlO; the render shows 4D4x10) are text, because the conversion flag the format has turns S.D.C. into M.D.C. as well and a pool bonus needs a base the class does not state. PSIONICS: the book prints an I.S.P. figure for none of the psychic results. The two it calls or implies major (Psi-Healer, a reading, and Ecto-Freak, printed Major) store the standard major formula; the four it calls Master (Prognosticator, Fighter, Sensitive, TK-Master) store no isp_base. A dice-valued number of powers (1D4) is stored as its maximum with a note to roll, as the Hunter Cat does. Mind Bleeder and Mind Melter (roll for that R.C.C.) are stored as a master tier with occ_options naming the production class, the Godling''s mechanism. Power names follow the catalog: Commune with Spirit, See The Invisible, Object Read (Psychometry), Psychic Omni-Sight, Telemechanic Mental Operation (printed Telemechanic Operation); all psionic Healing abilities is the 17 general Healing rows; all Telekinetic abilities from the physical category is Telekinesis, Telekinetic Leap, Lift, Punch and Push; all ectoplasmic abilities is Ectoplasm and Ectoplasmic Disguise. The Nate''s P.P.E. (6D6 + P.E., +2D6 per level) is text, and its one spell per level equal to the character''s level is stored as up_to_character_level. The G.M. options (substitute other animals; Psyscape classes) are in GM Notes. || PSIONICS_ALLOWED IS FALSE since 2026-10-05 (BOOK-INGEST-AUDIT.md F118): the class''s own psionics table stands in place of the standard Random Psionics roll. A READING, not a printed rule: Australia printed 128-132 print no Psionics line for a mutant and never mention the standard roll, where the same book prints one when it means it (the Mokoloi on printed 141: standard, same as humans). Printed 128 gives mutants psionic OR magical enhancement and the Special Mutant Powers table of printed 130 is the only mechanism given for either, so the table is taken as the whole answer and a Nate, Magic Back Rounder or Tanker is not also offered the standard roll."
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
   AND instr(markdown, 'NOT APPLIED AUTOMATICALLY: Spd becomes 1D6+6') > 0
   AND length(markdown) = 41925;

-- == mutant-psi-stalker ==
UPDATE imported_classes
   SET markdown = '---
id: mutant-psi-stalker
men_of_arms: false
name: Psi-Stalker
system: rifts
source_book: Rifts Ultimate Edition p.152-154
category: rcc
tags: []
attribute_dice:
  IQ: "3d6"
  ME: "3d6+5"
  MA: "3d6"
  PS: "3d6"
  PP: "3d6"
  PE: "4d6"
  PB: "3d6"
  Spd: "4d6+6"
ppe_base: "2d6"
psionics:
  type: "master"
  isp_base: "1d6x10 plus M.E. attribute number, +10 per additional level of experience"
  powers_starting: 6
  categories_allowed: ["Sensitive"]
bonuses:
  pools: { hp: "1d6+1", sdc: 10 }
  combat: { attacks: 1, perception: 4 }
  saves: { mind_control: 5, possession: 3, horror_factor: 6, spell_magic: "1d4", ritual_magic: "1d4" }
natural_abilities:
  - name: "Sense Psychic and Magic Energy"
    description: "Like a bloodhound smelling a familiar scent, the Psi-Stalker detects psychic energy - fellow psionics (I.S.P.) and magic and the supernatural (both with high P.P.E.). A natural ability like a human''s sense of smell: the moment a psychic scent is within range he recognizes it and can trace it to the specific individual. Base Skill: 60% +5% per level (roll once every melee) to track energy in use; 20% +5% per level to recognize a specific scent again, +20% with a bit of hair, skin, blood or clothing worn within four hours. Ranges: a practitioner NOT using powers, 50 feet (15 m) +20 feet (6 m) per level; powers BEING USED, 600 feet (182 m) +100 feet (30.5 m) per level. Other P.P.E. sources confuse the scent (-10%, -20% if numerous). Close proximity to a ley line (2 miles) halves specific-scent tracking; a nexus point (4 miles) obliterates it entirely. He can sense ley lines or a nexus point from up to 10 miles (16 km) away, plus one mile (1.6 km) per level. When tracking a psychic scent, roll percentile dice every 1000 feet (305 m)."
  - name: "Sense Supernatural Beings"
    description: "As above, but attuned to the distinctive scent of the supernatural (demons, Elementals, Godlings). Base Skill: 40% +5% per level, including demons, vampires and Entities. Tracking by psychic scent alone: 30% +5% per level when the being is in disguise and not using its abilities, 70% +3% per level if it is expending psionic or magic energy or is a Greater Demon, god or Alien Intelligence. Ranges: a supernatural being not using powers, 50 feet (15 m) per level; powers being expended, 1000 feet (305 m) +100 feet (30.5 m) per level. Ley lines and nexus points have the same adverse effects."
  - name: "Nourishment - the P.P.E. Vampire"
    description: "The Psi-Stalker must feed on a minimum of 50 P.P.E. or I.S.P. a week, preferably 80 to 100. To feed without killing, the predator hunts down a psychic, practitioner of magic, creature of magic or supernatural monster, physically captures the prey, cuts it (1D6 S.D.C. or 1D4 M.D.) and drains all available P.P.E. - up to 300 points in a single sitting. Against creatures of great magic he feasts on 300 points and causes another 1D4x100 to dissipate into the area for other Psi-Stalkers. Psychics temporarily lose HALF their I.S.P. and ALL their P.P.E. Once feeding begins he cannot stop until all the P.P.E. is absorbed (about five seconds). CANNOT feed on beings who are not practitioners of magic, creatures of magic, psychic or supernatural. Ley line energy can sustain him in an emergency but tastes foul (-1 on all combat bonuses for 1D6x10 minutes). When he kills his prey, ALL the victim''s P.P.E. is doubled at the moment of death and expelled, and other Psi-Stalkers can absorb the extra from as far as 300 yards/meters away."
  - name: "No Need for Normal Food or Water"
    description: "Needs no more than one pound (0.45 kg) of meat and eight ounces (0.23 liters) of water a week, and can go three weeks without either. But deprivation of P.P.E. inflicts real damage: for every week with less than 50 P.P.E. he suffers 6D6 points to BOTH Hit Points and S.D.C. until down to a minimum of two each, and combat bonuses and attacks per melee are halved. After three weeks of starvation, unless P.P.E. becomes available, he dies within 1D6 days."
  - name: "Psionic Empathy with Animals"
    description: "An automatic affinity with animals of all kinds. Domesticated animals take an immediate liking to him and do their best to please; he can ride any horse (wild or tame) or non-predatory animal at +15% and work with any domestic animals. Wild animals - excepting felines and mutant or alien predators - react to him as a fellow woodland creature and allow him to walk among them without fear, so birds do not fly and animals do not run to betray his approach. Even watchdogs do not bark. Most feline, mutant and alien predators, however, see the Psi-Stalker as a rival and will frequently select him as their first target in battle. The affinity means the character hunts and eats meat only for food, never pleasure."
  - name: "Mega-Damage Combat"
    description: "A closely guarded secret: whenever a Psi-Stalker locks horns with an M.D.C. supernatural being or creature of magic, his Hit Points turn into M.D.C., temporarily making him a minor Mega-Damage creature. This also occurs on a ley line (50% more M.D.C.) and at a nexus point (M.D.C. doubled). Note: although H.P. becomes M.D.C., he still inflicts S.D.C. damage with his bare hands."
  - name: "Psionics and I.S.P."
    description: "Master Psychic who needs only a 6 or higher to save vs psionic attack. Chooses SIX psi-powers from the Sensitive category only. I.S.P. Base: M.E. attribute plus 1D6x10, +10 per additional level. Recovery: two I.S.P. per hour of activity or 12 per hour of meditation or sleep."
special_abilities:
  - { choose: 1, from: ["Tribe: Spider Tribe", "Tribe: Pony-Tail Tribe", "Tribe: Deathbringer Cult", "Tribe: other or none"] }
  - name: "Tribe: Spider Tribe"
    description: "A Canadian Psi-Stalker tribe of about 120,000 to 140,000 (Rifts World Book 23: Xiticix Invasion p.101-104). Its bonuses are added to those from attributes, skills and the R.C.C. Also +5% to sense and track the supernatural and the Xiticix. Alignments run 45% good, 20% Unprincipled, 20% Anarchist and 15% other. Weapons: 25% carry magic weapons (mostly Techno-Wizard), 25% Xiticix resin weapons, the rest modern weapons. Rivals of the Pony-Tail Tribe and frequent enemies of the Simvan. Applied: +2 M.A., +2 M.E., +2 P.S., +3 on initiative, +1 to strike, +2 to save vs possession, +2 to save vs Horror Factor."
    bonuses: { attributes: { MA: 2, ME: 2, PS: 2 }, combat: { initiative: 3, strike: 1 }, saves: { possession: 2, horror_factor: 2 } }
  - name: "Tribe: Pony-Tail Tribe"
    description: "One of the largest Psi-Stalker tribes, an estimated 160,000 to 200,000 in over six dozen clans (Rifts World Book 23: Xiticix Invasion p.103-104); its members fix long strands of hair to their scalps. Its bonuses are added to those from attributes, skills and the R.C.C. Typical level 4-7 (20% are 1-3, 25% are 8-10, 3% are 11 or higher). Alignments run 30% good, 15% Unprincipled, 35% Anarchist and 20% other. Weapons: 30% carry magic weapons (mostly Techno-Wizard melee weapons), 35% Xiticix resin weapons, the rest modern weapons, Vibro-Blades above all. Friendly with the Simvan; distrusts technology, D-Bees and the Coalition. Applied: +3 P.S., +3 Spd, +1 P.B., +14 S.D.C., +2 on initiative."
    bonuses: { attributes: { PS: 3, Spd: 3, PB: 1 }, pools: { sdc: 14 }, combat: { initiative: 2 } }
  - name: "Tribe: Deathbringer Cult"
    description: "A tribe of 860 Wild Psi-Stalkers around Thunder Bay led by a cult of 31 Necromancers (Rifts World Book 23: Xiticix Invasion p.104-105). Its bonuses are added to those from attributes, skills and the R.C.C. Hand to Hand is Expert (01-50%) or Martial Arts (51-00%), with 5-6 attacks per melee round on average. Typical level 3-6 (15% are 1-2, 15% are 7-9); all are practicing cannibals. Alignments run 15% Unprincipled, 40% Anarchist, 25% Aberrant, 10% Miscreant and 10% other. Weapons: 85% carry Xiticix resin weapons, 10% magic weapons, 5% Vibro-Blades and other modern weapons beside a resin weapon or two. Wears non-environmental armor cut from the exoskeletons of Xiticix Warriors or Leapers, typically 3D6+50 M.D.C., with a Xiticix skull helmet, and can pass for a Xiticix at a distance. Applied: +20 S.D.C., +1D6 Hit Points, +1 on initiative, +1 to save vs Horror Factor, +1 to save vs possession, +3 to save vs poisons and drugs."
    bonuses: { pools: { sdc: 20, hp: "1d6" }, combat: { initiative: 1 }, saves: { horror_factor: 1, possession: 1, toxins_poisons: 3, harmful_drugs: 3 } }
  - name: "Tribe: other or none"
    description: "Choose this for a Coalition or civilized Psi-Stalker, or for a Wild Psi-Stalker of any other tribe or of none (the northern tribes of Rifts World Book 23: Xiticix Invasion p.112 print no bonuses): no tribe bonus."
restrictions:
  - "Tribes (Rifts World Book 23: Xiticix Invasion p.101-105): the Spider Tribe, the Pony-Tail Tribe and the Deathbringer cult are Psi-Stalker tribes of the northern wilds (only the Deathbringer block says Wild outright), offered as one pick-one ability group with an other-or-none option. The group sits on the race because that is where the wizard offers an ability pick; a Coalition or civilized Psi-Stalker takes the other-or-none option."
  - "Psi-Stalkers are mutant humans: the book gives the Racial Requirement as mutant humans only, for the Civilized and the Wild Psi-Stalker alike (RUE p.152, 155)."
  - "Racial bonuses beyond the modeled saves: ambidextrous and Paired Weapons; can leap six feet (1.8 m) high or 10 feet (3 m) long (+20% to length with a running start); excellent balance (80% +2% per level)."
  - "Cybernetics: starts with none; tends to avoid implants in favor of natural powers."
extraction_notes: |
  - The racial half of the Psi-Stalker, split out of the psi-stalker and
    wild-psi-stalker O.C.C.s on 2026-09-27 (BOOK-INGEST-AUDIT F110). RUE
    prints only the Psi-Stalker O.C.C. (printed 152), but lists these powers
    as the ones every Psi-Stalker has - "CS, civilized or wild" (printed 153)
    - so they are stored once, here, and each occupation pairs with this race.
  - Stored as printed on printed 153-154: the attribute dice are the Civilized
    Psi-Stalker''s (the Wild one adds +2 to P.S. and P.P. as an occupation
    bonus), P.P.E. 2D6, master psionics with six Sensitive powers, the
    psionic, magic and physical bonuses, and the nine numbered abilities.
  - Save vs psionic attack is 6 or higher, better than the Master Psychic''s
    10; the app has one psionic save target per tier, so the 6+ is recorded
    in the abilities rather than as a bonus key.
  - "+1D4 to save versus magic attacks of any kind" is stored as dice on the
    spell_magic and ritual_magic save keys.
  - +4 on Perception Rolls (printed 153) is stored as combat.perception
    (BOOK-INGEST-AUDIT F138); the Wild Psi-Stalker''s +5 (printed 155) is
    its occupation''s to state. Ambidexterity, Paired Weapons, the leap and
    the balance skill have no bonus key and are prose.
  - No occ_restrictions. The book names the occupations a Psi-Stalker takes
    from the occupation''s side (Coalition Grunt, NTSET Protector, Psi-Net,
    Psi-Slinger, Biomancer), and each occupation''s own race_restrictions
    governs the pairing, as for any race.
  - The Psycho-Stalker (Juicer Uprising) is NOT paired with this race: its
    printed numbers already include the Psi-Stalker''s physical and saving
    throw bonuses, and a pairing adds a race''s bonuses to an occupation''s, so
    it would count them twice. It stays a class that carries its own package.
---

# Psi-Stalker

## Lore

Psi-Stalkers are human mutants, transformed over the centuries since the
Great Cataclysm by the magic and dimensional energies loose on Rifts Earth.
They look human but hairless, and every one of them - Coalition soldier,
civilized mercenary or wilderness tribesman - shares the same predator''s gift:
they sense psychic energy, magic and the supernatural the way a hound follows
a scent, and they feed on Potential Psychic Energy rather than on food.

This is the race. What a Psi-Stalker learned is the occupation paired with it:
the Civilized or the Wild Psi-Stalker O.C.C., or one of the occupations that
take Psi-Stalkers by name, such as the Coalition Grunt.
',
       updated_at = datetime('now')
 WHERE class_id = 'mutant-psi-stalker'
   AND instr(markdown, '+4 Perception (+5 for the Wild Psi-Stalker)') > 0
   AND length(markdown) = 12112;

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
    description: "Roll 01-10 or choose. Thin and fast: +3D6+10 Spd, +1 initiative, +1 strike, +1 attack per melee and Automatic Dodge at +3 (dodging uses up no melee attack or action), all applied."
    bonuses: { attributes: { Spd: "3d6+10" }, combat: { initiative: 1, strike: 1, attacks: 1, automatic_dodge: 3 } }
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
  - What each row carries as keys is only what the page prints without a condition: Spd, initiative, strike, attacks and Automatic Dodge (01-10); P.S. and M.D.C. (11-20); P.S. (21-30); roll with impact (31-35); M.D.C. (41-45, 63-66, 67-70); M.D.C., P.B. and M.A. (71-74); strike (79-82); I.Q., M.E., Perception, -2 P.E. and -1D4 P.B. (83-86); P.B., M.A., -1 M.E., -1D4 P.E. and -1D6 Spd (87-89); -1D4 P.B. (93-95 and 96-97); saves vs Horror Factor and magic (98-00, the +1 vs magic stored as spell_magic). Left in the descriptions: every skill and skill percentage, the per-arm parry, entangle and attack of 21-30 (they hang on a 1D4 roll), the 11-20 sub-table of oddities, all of Nightstalker (night only) and the Demon Slayer combat bonuses and +100 M.D.C. (only against the supernatural), the halved saves of the Divine Mutant, and the limit of one choice from 87-00, which is in the group''s note.
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
   AND instr(markdown, 'Automatic Dodge at +3 (dodging uses up no melee attack or action), which is not applied.') > 0
   AND length(markdown) = 26026;

-- == russian-fire-sorcerer ==
UPDATE imported_classes
   SET markdown = '---
id: russian-fire-sorcerer
men_of_arms: false
name: Russian Fire Sorcerer
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.109-111
category: occ
tags: []
occ_group: magic
xp_table: [0, 2201, 4401, 9001, 19001, 28001, 40001, 60001, 80001, 100001, 150001, 200001, 275001, 350001, 425001]
attribute_requirements: { IQ: 9, ME: 9 }
ppe_base: "2d4x10 plus the P.E. attribute number, and 1d6 more per level of experience"
starting_money: "3d6x100"
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%" }
    - { name: "Language: Euro", bonus: 20, note: "Speaks Euro (+20%)" }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%)" }
    - { choose: 1, from: ["Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 10, note: "Lore: one of choice (+10%)" }
    - { name: "Cook", bonus: 15, note: "Cook (+15%)" }
    - { name: "Brewing", bonus: 15, note: "Brewing (+15%)" }
    - { name: "Land Navigation", bonus: 10, note: "Land Navigation (+10%)" }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot Skill: one of choice (+10%)" }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Ancient, one of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapon, one of choice (any)." }
    - { name: "Hand to Hand: Basic", note: "Can be changed to Expert for the cost of two O.C.C. Related Skills, or Martial Arts (or Assassin, if evil) for three." }
  occ_related_skills:
    count: 7
    categories:
      - "Communications"
      - { name: "Domestic", bonus: 5, note: "+5%" }
      - { name: "Espionage", only: ["Intelligence"], bonus: 5, note: "Intelligence only (+5%)" }
      - { name: "Medical", only: ["First Aid"], note: "First Aid only." }
      - { name: "Physical", except: ["Wrestling", "Acrobatics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft." }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", bonus: 5, note: "+5%" }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - "Wilderness"
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
magic:
  type: "spell"
  spells_starting: 3
  spells_starting_groups:
    - { count: 3, from_list: "living-fire-low", note: "Three Fire Magic spells from levels 1-4. A named list rather than a level range, so this group reaches Living Fire and only Living Fire." }
  spells_per_level: 1
  spells_per_level_levels: up_to_character_level
  spell_traditions_allowed: ["living-fire"]
  spell_lists:
    living-fire-low:
      - "Living Fire: Cloud of Smoke"
      - "Living Fire: Finger Sparks"
      - "Living Fire: New Fire"
      - "Living Fire: Pluck & Handle Flame"
      - "Living Fire: Smoke Smell"
      - "Living Fire: Bright Sun"
      - "Living Fire: Column of Smoke"
      - "Living Fire: Extinguish Fire"
      - "Living Fire: Locate & Identify Fire"
      - "Living Fire: Toxic Smoke Cloud"
      - "Living Fire: Circle of Flame"
      - "Living Fire: Fire Fists"
      - "Living Fire: Ignite Fire"
      - "Living Fire: Impervious to Fire"
      - "Living Fire: Insect Chaser"
      - "Living Fire: M.D. Torchfire"
      - "Living Fire: Blessing from Svarozhich"
      - "Living Fire: Climb Smoke"
      - "Living Fire: Fire Bolt"
      - "Living Fire: Fire Meld"
      - "Living Fire: Fire Shield"
      - "Living Fire: Fireblast"
bonuses:
  saves: { horror_factor: 3, possession: 1, spell_magic: 2, ritual_magic: 2, other: [ { label: "vs magic fumes", bonus: 4 } ] }
special_abilities:
  - name: "Immune to smoke"
    description: "The Fire Sorcerer can see clearly through smoke and is unaffected by it - no coughing, choking or streaming eyes, and no penalties."
  - name: "Impervious to normal fire & heat"
    description: "Ordinary fire and heat do the Fire Sorcerer no harm. Magical and Mega-Damage fire are not covered by this."
  - name: "Impervious to brilliant light"
    description: "The mage can see through brilliant light without being blinded or penalised."
  - name: "Spell strength"
    description: "+1 to spell strength at levels 3, 7, 11 and 15."
  - name: "Learning New Spells"
    description: "Additional Living Fire Magic spells, or common Wizard spells of ANY level, can be learned or purchased at any time regardless of the character''s experience level - the ordinary level gate does not apply to this class''s own tradition. See The Pursuit of Magic in the Rifts RPG."
restrictions:
  - "Any alignment, but the most common is anarchist (35%). Also known as the Fire Lord."
  - "Racial restrictions: none, although the vast majority (80%) are human."
  - "Cybernetics: none, and the character avoids them like the plague - any cybernetics or physical augmentation interferes with magic. Cybernetic prosthetics and bio-systems for medical reasons will be considered."
  - "The character also starts with 2D4x1000 credits'' worth of TRADEABLE GOODS, over and above the coin in starting_money. That field is coin only. The book prices the coin in credits OR RUBLES."
  - "LIVING FIRE MAGIC IS EXCLUSIVE TO THIS O.C.C., other than the few spells that are also common Wizard spells. The book states it outright, and adds that the O.C.C. itself is exclusive to Russia and is typically passed from parent to child, occasionally teacher to student, its secrets closely guarded."
  - "Starts with no vehicle."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.109-111. THE SAME DELIBERATE TRADE-OFF AS THE BORN MYSTIC, and for the same reason. `spell_traditions_allowed` is class-wide and identical for every group; this class needs it set to living-fire because its per-level pick is explicitly one new spell ''from Living Fire Magic or common Wizard spells''. The cost is that the three STARTING picks could also see Living Fire spells outside their stated 1-4 band - except they cannot, because that group uses a named list, and a named list wins over both the tradition gate and the level gate. So here the trade-off costs nothing at creation and only widens the per-level pick, which is what the book asks for. The two-tier pricing this tradition carries - ''6 for Fire Sorcerers, 10 for other magic O.C.C.s'' - lives on the SPELL rows, where `ppe` holds the Fire Sorcerer price and `ppe_note` the schedule; nothing about it belongs on the class. The +4 to save vs magic fumes is a saves.other entry (BOOK-INGEST-AUDIT F138), beside the general +2 to save vs magic."
---

# Russian Fire Sorcerer

## Lore

The Russian Fire Sorcerer, also called the Fire Lord, commands Living Fire
Magic - a tradition exclusive to this O.C.C. and to Russia, typically passed
from parent to child and occasionally from teacher to student. Its mystic
secrets are closely guarded.

Smoke does not blind him, ordinary fire does not burn him, and brilliant light
does not dazzle him. He is at home in exactly the conditions that put everyone
else at a disadvantage.

## Alignment

Any, though the most common is anarchist.

## GM Notes

The tradition is the point of the class. Living Fire Magic prices most of its
spells twice - one cost for a Fire Sorcerer, a higher one for any other
practitioner of magic - so a Fire Sorcerer casting his own tradition is
materially cheaper than anyone else casting the same spell. That pricing sits on
the spell rows rather than here.

Like the Necromancer, this class is not level-gated within its own tradition:
additional Living Fire or common Wizard spells of any level can be learned or
purchased at any time.
',
       updated_at = datetime('now')
 WHERE class_id = 'russian-fire-sorcerer'
   AND instr(markdown, 'The +4 to save vs magic fumes has no field') > 0
   AND length(markdown) = 8552;

-- == russian-mystic-kuznya ==
UPDATE imported_classes
   SET markdown = '---
id: russian-mystic-kuznya
name: Russian Mystic Kuznya
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.118-125
category: occ
tags: [combat]
occ_group: magic
xp_table: [0, 2081, 4161, 8801, 18001, 33001, 48001, 65001, 90001, 120001, 150001, 200001, 250001, 300001, 400001]
attribute_requirements: { IQ: 9, ME: 12, PE: 14 }
mdc_base: "P.E. x3 as the base M.D.C., plus 2d6 M.D.C. per level of experience"
ppe_base: "1d4x10+25, and 1d6+15 more per level of experience"
starting_money: "3d6x1000"
skills:
  hand_to_hand: { costs: { martial_arts: 2 } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 30, note: "The book prints ''Basic Math (+30%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Russian", base: 98, per_level: 0, note: "Speaks Russian at 98%" }
    - { name: "Language: Euro", bonus: 20, note: "Speaks Euro (+20%)" }
    - { choose: 1, from: ["Language: Other"], bonus: 20, note: "One other language of choice (+20%)" }
    - { choose: 1, from: ["Lore: Demons & Monsters", "Lore: Faeries & Creatures of Magic", "Lore: Magic", "Lore: Religion"], bonus: 10, note: "Lore: one of choice (+10%)" }
    - { name: "Field Armorer & Munitions Expert", bonus: 30, note: "The book prints ''Armorer (Field Armorer; +30%)''." }
    - { name: "Recognize Weapon Quality", bonus: 30, note: "Recognize Weapon Quality (+30%)" }
    - { name: "General Repair & Maintenance", bonus: 15, note: "The book prints ''General Repair/Maintenance (+15%)''." }
    - { name: "Find Contraband", bonus: 10, note: "Find Contraband (+10%)" }
    - { name: "Cook", bonus: 10, note: "Cook (+10%)" }
    - { name: "Art", bonus: 10, note: "Art (+10%)" }
    - { name: "Prospecting", bonus: 10, note: "Prospecting (+10%)" }
    - { name: "Land Navigation", bonus: 10, note: "Land Navigation (+10%)" }
    - { name: "Gemology", base: 50, per_level: 5, note: "A SPECIAL O.C.C. SKILL. The book gives the Mystic Kuznya its own base - 50% +5% per level - where the catalog row is 25%. `base` fixes the percentage for this class without disturbing the catalog, which is what that field is for. Identifying fakes is at -10%." }
    - { name: "Metalwork and Forge", base: 60, per_level: 3, note: "A SPECIAL O.C.C. SKILL this book defines, 60% +3% per level. A success means a superior item: an S.D.C. weapon gains +1 strike, +1 parry and +1D6 damage; metal S.D.C. armour gains +1 A.R. and 40% more S.D.C. at no extra weight; craft goods command 50-100% more, 5-10x if exquisite." }
    - { name: "Shape, Engrave, Etch & Emboss Metal", base: 70, per_level: 3, note: "A SPECIAL O.C.C. SKILL this book defines, 70% +3% per level. Decorative metalwork - inlay, etching, embossing, gem-setting, high polish - in any metal from iron to gold." }
    - { choose: 1, categories: ["Pilot"], bonus: 10, note: "Pilot Skill: one of choice (+10%); may select Horsemanship." }
    - { name: "W.P. Blunt", note: "W.P. Ancient: Blunt" }
    - { choose: 3, categories: ["Weapon Proficiencies"], note: "W.P. three Ancient of choice (any)." }
    - { choose: 1, categories: ["Weapon Proficiencies"], note: "W.P. Modern Weapon, one of choice (any)." }
    - { name: "Hand to Hand: Expert", note: "Expert to start, and can be changed to Martial Arts - NEVER Assassin - for the cost of two O.C.C. Related Skills." }
  occ_related_skills:
    count: 6
    categories:
      - "Communications"
      - "Domestic"
      - { name: "Mechanical", only: ["Basic Mechanics", "Automotive Mechanics"], bonus: 5, note: "Basic and Automotive Mechanics only (+5%)" }
      - { name: "Medical", only: ["First Aid"], note: "First Aid only." }
      - "Military"
      - { name: "Physical", except: ["Gymnastics", "Acrobatics"] }
      - { name: "Pilot", note: "Any except robots, power armor, military vehicles, ships and aircraft - Horsemanship is most likely." }
      - "Pilot Related"
      - { name: "Science", note: "+10% on chemistry skills" }
      - { name: "Science", only_prefix: ["Chemistry"], bonus: 10, note: "+10% on chemistry skills." }
      - { name: "Technical", bonus: 10, note: "+10%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 5, note: "+5%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 4
    schedule: [{ level: 2, count: 1 }, { level: 4, count: 1 }, { level: 6, count: 1 }, { level: 8, count: 1 }, { level: 12, count: 1 }]
magic:
  type: "spell"
  spells:
    - "Ignite Fire"
    - "Fuel Flame"
    - "Extinguish Fire"
    - "Superhuman Strength"
    - "Manipulate Objects"
    - "Deflect"
    - "Ricochet Strike"
    - "Implosion Neutralizer"
    - "Create Steel"
    - "Power Weapon"
    - "Speed Weapon"
    - "Enchant Weapon (Minor)"
bonuses:
  attributes: { PE: 2, ME: "1d4", MA: "1d4", PS: "1d6+12" }
  combat: { initiative: 1, strike: 1, parry: 1, disarm: 1, pull_punch: 6 }
  saves: { horror_factor: 2, possession: 2 }
special_abilities:
  - name: "The Mettle of Kuznya Sorcery"
    description: "The magic of the Mystic Smith transforms them into creatures not unlike metal - lesser M.D.C. beings with P.E. x3 as base M.D.C. plus 2D6 M.D.C. per level. The cost is that their skin is as hard and cold as steel."
  - name: "Limited Invulnerability"
    description: "Impervious to S.D.C. weapons and to natural cold, heat and fire. MAGICAL FIRE DOES FULL DAMAGE and magical cold does half. All M.D. weapons, explosives and energy blasts inflict full damage."
  - name: "Supernatural P.S."
    description: "Roll the P.S. attribute as usual, then ADD 1D6+12 and make it supernatural. Punches and kicks inflict M.D. and the smith can carry 100x his P.S. in pounds. The 1D6+12 is in bonuses and rolled once at creation."
  - name: "Rolled O.C.C. bonuses"
    description: "+1D4 to M.E. and +1D4 to M.A., on top of the fixed +2 to P.E. carried in bonuses. Both are rolled by the sheet, from bonuses."
  - name: "A closed spell list"
    description: "The Mystic Kuznya does not know spell magic or cast spells in the ordinary sense, other than a handful of weapon-related ones; the true power is creating magic weapons and items from metal. The twelve spells granted above are the whole of it - THE BOOK STATES OUTRIGHT THAT NO OTHER SPELLS CAN BE LEARNED, which is why this class has no spell gate, no per-level growth and no tradition."
  - name: "P.P.E. from ley lines only"
    description: "Additional P.P.E. can be drawn from ley lines and from P.P.E. willingly offered, but NO KUZNYA CAN DRAW P.P.E. FROM BLOOD SACRIFICES - the magic will not work with death energy. That is a restriction the other casters in this book do not share."
  - name: "Magical Equipment"
    description: "Every Mystic Kuznya carries an indestructible giant sledgehammer, three indestructible hammers of gold, three indestructible tongs of gold, and a full suit of M.D.C. chain mail. They are both weapons and the tools for making magic metal items."
restrictions:
  - "Any alignment EXCEPT miscreant or diabolic, and even anarchist is rare (5%). Most are principled (32%), scrupulous (31%), unprincipled (23%) or aberrant (9%)."
  - "RACIAL RESTRICTION: HUMANS ONLY, 35% of them female. Also known as the Hands of Svarog."
  - "PSIONICS: NONE. The book is emphatic - any psychic abilities that might have developed are consumed fuelling Kuznya magic and the superhuman abilities."
  - "No other spells can be learned, ever. The twelve granted are the entire repertoire."
  - "No Kuznya can draw P.P.E. from blood sacrifices; the magic will not work with death energy."
  - "Hand to Hand: Expert to start, and it can be raised to Martial Arts but NEVER to Assassin."
  - "Cybernetics: none, and the character avoids them like the plague because they interfere with magic."
  - "The character also starts with 3D6x1000 credits'' worth of TRADEABLE GOODS, over and above the coin in starting_money. That field is coin only. The book prices the coin in credits OR RUBLES."
  - "Do not roll Hit Points or S.D.C. for this class - it is an M.D.C. being from creation."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.118-125. THIS CLASS FALSIFIES THE SURVEY''S ''ZERO NEW SKILLS'' READING, and it is the caveat that survey carried from spirit-west firing exactly as written: the book has no new-skills SECTION, which is what the zero was measured from, but it defines skills inside a class. Three are Special O.C.C. Skills with their own percentages. Gemology already exists in the catalog at 25%; the book gives this class 50% +5%, so `base` fixes it here without disturbing the row. Metalwork and Forge (60% +3%) and Shape, Engrave, Etch & Emboss Metal (70% +3%) do not exist and are created, filed Technical beside Gemology, Art and Prospecting. Their percentages come from the page, not from a convention. THE SPELL LIST IS CLOSED - twelve named spells and the book says no others can ever be learned - so there is no gate, no per-level growth and no tradition on this class; it is the only caster in the book shaped that way. The book''s ''Enchant Weapon'' is stored as the catalog''s Enchant Weapon (Minor), the only row of that name here. Three attribute bonuses are ROLLED (+1D6+12 supernatural P.S., +1D4 M.E., +1D4 M.A.): all three dice are stored in bonuses and rolled at creation (the P.S. since BOOK-INGEST-AUDIT F138); the fixed +2 to P.E. is in bonuses. Four skill names needed the catalog''s spelling: Armorer (Field Armorer) is Field Armorer & Munitions Expert, General Repair/Maintenance is General Repair & Maintenance, W.P. Ancient: Blunt is W.P. Blunt, and Basic Math is Mathematics: Basic."
---

# Russian Mystic Kuznya

## Lore

"Kuznya" is Russian for smith. The Mystic Kuznya are men and women with
supernatural powers and the ability to forge superior metal weapons - and a
number of magic ones. These are not Techno-Wizard devices but melee weapons of
metal and magic, said to be empowered by Svarog the Divine, Highest of the Gods
and the first Mystic Kuznya.

The magic transforms the smith into something not unlike metal: a lesser
Mega-Damage being, invulnerable to ordinary weapons and to natural fire and
cold, with skin as hard and cold as steel. They can forge any metal object, from
nails and horseshoes to swords and chalices, in a tenth the time an ordinary
smith would take on a worse item.

## Alignment

Any except miscreant or diabolic, and even anarchist is rare. Most are
principled or scrupulous.

## GM Notes

This is the book''s odd caster. It has twelve spells and will never have
thirteen - the book says so outright - because its power is not casting but
making. Its P.P.E. is large and grows fast, and it exists to be spent on metal.

It is also the one caster here that cannot draw P.P.E. from blood sacrifice at
all: the magic will not work with death energy, which places it squarely
opposite the Necromancer and the Night Witch.
',
       updated_at = datetime('now')
 WHERE class_id = 'russian-mystic-kuznya'
   AND instr(markdown, 'and the P.S. is still only on its ability') > 0
   AND length(markdown) = 11029;

-- == gifted-one-russian ==
UPDATE imported_classes
   SET markdown = '---
id: gifted-one-russian
men_of_arms: false
name: The Gifted One (Russian)
system: rifts
source_book: Rifts World Book 18: Mystic Russia p.150-153
category: occ
tags: [healer, psionics]
occ_group: psychic
xp_table: [0, 2051, 4101, 8251, 16501, 24601, 34701, 49801, 69901, 95001, 130001, 180201, 230001, 280401, 340501]
attribute_requirements: { ME: 14 }
starting_money: "1d6x1000"
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3, assassin: 3 }, conditions: { assassin: "evil alignment" } }
  occ_skills:
    - { name: "Mathematics: Basic", bonus: 10, note: "The book prints ''Basic Math (+10%)''; the catalog renamed that row and keeps a redirect, but the current name is stored so the string stays live in an only/except, where redirects are skipped." }
    - { name: "Language: Gypsy", bonus: 9, note: "Speaks Gypsy (+9%) - a FOURTH pricing of the same language in this book, against the Thief''s and Fortune Teller''s flat 63%, the Wizard-Thief''s +10% and the Seer''s +6%." }
    - { name: "Language: Euro", bonus: 30, note: "Part of ''Speaks Euro and Russian (+30%)''." }
    - { name: "Language: Russian", bonus: 30, note: "The other half of that line." }
    - { choose: 2, from: ["Language: Other"], bonus: 20, note: "Two more of choice (+20%) - a DIFFERENT bonus from the two named above." }
    - { name: "Streetwise", bonus: 20, note: "The book grants ''Streetwise & Streetwise Drugs (both are +20%)'' as one line; both rows are granted." }
    - { name: "Streetwise: Drugs", bonus: 20, note: "The other half of that line." }
    - { name: "Dance", bonus: 20, note: "Dance (+20%)" }
    - { name: "Cook", bonus: 20, note: "Cook (+20%)" }
    - { name: "Preserve Food", bonus: 20, note: "The book prints ''Preserve Food (+20%)''." }
    - { name: "Identify Plants & Fruit", bonus: 20, note: "The book prints ''Identify Plants & Fruits (+20%)''; the catalog row is singular." }
    - { name: "Biology", bonus: 20, note: "Biology (+20%)" }
    - { name: "Pathology", bonus: 20, note: "Pathology (+20%)" }
    - { name: "Medical Doctor", bonus: 15, note: "Medical Doctor (+15%)" }
    - { name: "Holistic Medicine", bonus: 30, note: "Holistic Medicine (+30%). The book adds a note: with the Game Master''s approval this skill can include the skills and powers of the Herbalist/Herbology skill from Rifts World Book Three: England, including curative teas and potions. That is the same equivalence the Night Witch import relies on, and this is the page it comes from." }
    - { name: "W.P. Knife", note: "W.P. Knife" }
    - { name: "W.P. Targeting", note: "W.P. Targeting - typically throwing knives and sling." }
    - { name: "Hand to Hand: Basic", note: "Can be changed to Expert for the cost of two O.C.C. Related Skills, or Martial Arts (or Assassin, if evil) for three." }
  occ_related_skills:
    count: 4
    categories:
      - { name: "Communications", bonus: 5, note: "+5%" }
      - { name: "Domestic", bonus: 10, note: "+10%" }
      - { name: "Espionage", bonus: 5, note: "+5%" }
      - { name: "Medical", note: "See O.C.C. skills - the book points back rather than granting a category here." }
      - { name: "Physical", except: ["Boxing", "Wrestling", "Gymnastics", "Acrobatics"] }
      - { name: "Pilot", note: "Hover vehicles, automobiles, horsemanship and boats only (+10%)" }
      - "Pilot Related"
      - "Rogue"
      - { name: "Science", bonus: 10, note: "+10%" }
      - { name: "Technical", bonus: 15, note: "+15%" }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10, note: "+10%" }
    schedule: [{ level: 3, count: 1 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 0
    schedule: [{ level: 2, count: 2 }, { level: 4, count: 2 }, { level: 8, count: 2 }, { level: 12, count: 2 }]
special_abilities:
  - name: "The Gift is rolled, not chosen"
    description: "The book opens this class with ''Randomly roll or select one of the following'' and gives four outcomes on a percentile: 01-25 and 26-50 are Major Psionic, 51-75 and 76-00 are Master Psionic. Each brings its own powers, its own I.S.P. formula and its own saving throws, so the four are modelled as CHOSEN ABILITIES rather than as variants - a variant cannot carry a psionics block, and an ability can. Pick exactly one."
  - { choose: 1, from: ["The Gift (01-25): Major", "The Gift (26-50): Major", "The Gift (51-75): Master", "The Gift (76-00): Master"] }
  - name: "The Gift (01-25): Major"
    description: "Six powers from any TWO of the Healing, Sensitive and Physical categories."
    psionics:
      type: "major"
      isp_base: "1d4x10 plus the M.E. attribute number, and 1d6+1 more per level of experience"
      powers_starting: 6
      categories_allowed: ["Healing", "Sensitive", "Physical"]
    bonuses:
      saves: { disease: 2, toxins_poisons: 2, spell_magic: 1, ritual_magic: 1, curses: 1, horror_factor: 2 }
  - name: "The Gift (26-50): Major"
    description: "Eight powers, all from the Healing category."
    psionics:
      type: "major"
      isp_base: "1d4x10 plus the M.E. attribute number, and 1d6+1 more per level of experience"
      powers_starting: 8
      categories_allowed: ["Healing"]
    bonuses:
      saves: { disease: 3, toxins_poisons: 3, spell_magic: 1, ritual_magic: 1, curses: 2, horror_factor: 3 }
  - name: "The Gift (51-75): Master"
    description: "Five Healing powers, two Sensitive, two Physical, the Super Psionic power of Bio-Regeneration, and one further Super Psionic of choice. At levels 4, 7, 10 and 13 the character takes one more Super Psionic power OR two lesser powers from any of the three categories - an either/or the schedule cannot express, so the schedule carries the single Super Psionic and the two-lesser alternative is stated here."
    related_skills_count: 0
    psionics:
      type: "master"
      isp_base: "2d6x10 plus the M.E. attribute number, and 10 more per level of experience"
      powers: ["Bio-Regeneration (Super)"]
      powers_starting: 10
      categories_allowed: ["Healing", "Sensitive", "Physical", "Super"]
      powers_schedule:
        - { level: 4, count: 1, categories: ["Super"] }
        - { level: 7, count: 1, categories: ["Super"] }
        - { level: 10, count: 1, categories: ["Super"] }
        - { level: 13, count: 1, categories: ["Super"] }
    bonuses:
      saves: { disease: 2, toxins_poisons: 2, spell_magic: 1, ritual_magic: 1, curses: 1, horror_factor: 3 }
  - name: "The Gift (76-00): Master"
    description: "ALL Healing powers, plus four Super Psionic powers of choice. At levels 2, 4, 6, 9 and 12 the character takes one more Super Psionic power OR two lesser powers from any of the three categories - the same either/or, and the schedule carries the Super Psionic half. The strongest of the four outcomes by a wide margin."
    related_skills_count: 0
    psionics:
      type: "master"
      isp_base: "2d6x10 plus the M.E. attribute number, and 10 more per level of experience"
      powers_starting: 4
      categories_allowed: ["Super"]
      powers_schedule:
        - { level: 2, count: 1, categories: ["Super"] }
        - { level: 4, count: 1, categories: ["Super"] }
        - { level: 6, count: 1, categories: ["Super"] }
        - { level: 9, count: 1, categories: ["Super"] }
        - { level: 12, count: 1, categories: ["Super"] }
    bonuses:
      saves: { disease: 4, toxins_poisons: 4, spell_magic: 1, ritual_magic: 1, curses: 2, horror_factor: 4 }
restrictions:
  - "Also known as The Gifted and the Psychic Healer. Any alignment."
  - "Racial restrictions: none, although the vast majority (80%) are human MALES."
  - "Attribute requirement is M.E. 14 or higher; a high I.Q. and P.P. are ideal but not mandatory, so they are not requirements."
  - "LESS THAN 5% OF THE GIFTED ARE LITERATE in any language - the lowest rate in a book full of low ones, below even the Gypsy Medium''s 6%."
  - "O.C.C. RELATED SKILLS DEPEND ON THE ROLLED GIFT: a MAJOR Psionic selects four, a MASTER Psionic selects NONE AT ALL. The four are carried on the class, and each Master gift sets related_skills_count: 0 (BOOK-INGEST-AUDIT F138). The one more at levels 3, 6, 9 and 12 is printed in the Major sentence; that schedule is on the class and a Master gift does not remove it."
  - "The 76-00 outcome selects ALL Healing powers, which no count can express; `powers_starting` there carries only the four Super Psionic picks and the Healing sweep is stated in the ability''s description."
  - "The character also starts with 3D4x1000 credits'' worth of gold, jewellery and tradeable goods, over and above the coin in starting_money. That field is coin only, and the book prices the coin in credits OR RUBLES."
  - "The Gifted are among the most revered of the Gypsies and often hold a high place among the clans. They tend to be the least violent and have few thief or rogue skills."
extraction_notes: "Rifts World Book 18: Mystic Russia pp.150-153. The id carries a `-russian` suffix because `gypsy-gifted` belongs to Rifts World Book 5: Triax and the NGR p.184. THE FOUR ROLLED PSIONIC TIERS ARE MODELLED AS CHOSEN ABILITIES, NOT AS VARIANTS, and the reason is a real limit: `VARIANT_OVERRIDES` does not include `psionics`, so a variant cannot carry a psionic tier - but `applyAbilities` merges both `psionics` and `bonuses` from a chosen ability, and parser.js says so in as many words where it notes that an ability making you a master psychic is what a rolled tier is. Each of the four carries its own type, I.S.P. formula, power allotment and saving throws. A Major Psionic gets four related skills and a Master gets none at all: the four are on the class and each Master gift carries related_skills_count: 0 (BOOK-INGEST-AUDIT F138). Two of the four tiers offer ''one additional Super Psionic power OR two lesser psi-powers'' at set levels - an either/or across different counts, which no schedule entry expresses, so the schedule carries the Super Psionic half and the alternative is in the description. The 76-00 outcome takes ALL Healing powers, which no count expresses either. THIS PAGE IS THE SOURCE OF THE HERBOLOGY EQUIVALENCE the Night Witch import relies on: the book''s own note that Holistic Medicine can include the Herbalist/Herbology skill from Rifts World Book Three: England. A FOURTH pricing of Language: Gypsy appears here at +9%."
---

# The Gifted One (Russian)

## Lore

The Gifted One - The Gifted, the Psychic Healer - is a healer whose power is not
learned but received. The book does not let the player choose how much of it
arrives: you roll, and you get one of four gifts, ranging from six powers across
two categories to every Healing power there is plus four Super Psionics.

They are among the most revered of the Gypsies and often hold high place among
the clans. They are also the least violent, with almost no thief or rogue
skills, and fewer than one in twenty can read.

## Alignment

Any.

## GM Notes

The roll matters more than anything else about this class. A 01-25 Gifted One is
a competent psychic healer; a 76-00 Gifted One knows the entire Healing
discipline and four Super Psionic powers, and gets no ordinary skills at all
outside the O.C.C. list.

That last point is easy to miss: **a Master Psionic Gifted One selects no
O.C.C. Related Skills whatsoever.** The gift is the whole character.
',
       updated_at = datetime('now')
 WHERE class_id = 'gifted-one-russian'
   AND instr(markdown, 'ONE THING THE ABILITY ROUTE CANNOT CARRY') > 0
   AND length(markdown) = 11310;

-- == roane-piper ==
UPDATE imported_classes
   SET markdown = '---
id: roane-piper
name: Roane Piper
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.170-172
category: rcc
tags: []
men_of_arms: false
attribute_dice:
  IQ: "3d6+1"
  ME: "3d6"
  MA: "3d6+6"
  PS: "3d4"
  PP: "3d6+3"
  PE: "3d4"
  PB: "2d6+3"
  Spd: "3d6"
hit_points_base: "P.E. + 1d6 per level"
ppe_base: "1d4"
psionics_allowed: false
occ_restrictions:
  except: ["group:magic", "group:psychic", "juicer", "hyperion-juicer", "titan-juicer", "phaeton-juicer", "mega-juicer", "delphi-juicer", "coalition-juicer", "dragon-juicer", "juicer-gladiator", "juicer-assassin", "juicer-scout", "euro-juicer", "ninja-juicer", "songjuicer", "combat-cyborg", "ngr-cyborg-soldier", "fq-cyborg-soldier", "fq-cyborg-imprimer", "fq-cyborg-dervish", "fq-cyborg-slasher", "fq-cyborg-leviathan", "mining-borg", "cs-cyborg-strike-trooper", "destroyer-borg", "ojahee-borg", "plains-borg", "ninja-borg", "republic-cyborg-soldier", "cyborg-shocktrooper", "geofront-demon-eater-geo-borg", "geofront-assault-geo-borg", "geofront-lion-geo-borg"]
  note: "Virtually any O.C.C. except practitioners of magic, psychics and any kind of Juicer (M.O.M. and Crazy conversion is possible, if rare), and never a full-conversion ''Borg. About 45% are Roane Musicians and 20% thieves, spies or assassins, usually Bounty Hunter, Freelance Spy, Master Assassin, Professional Thief, Safecracker or Super-Spy."
bonuses:
  pools: { sdc: "3d6+9" }
  combat: { initiative: 2, perception: 2 }
skills:
  occ_skills:
    - { name: "Play Musical Instrument", base: 50, per_level: 5, note: "Rinaluo (Roane pipe), +15%, professional quality." }
    - { name: "Sing", base: 50, per_level: 5, note: "+15%, professional quality." }
equipment_starting:
  - { item_id: "musical-instrument", qty: 1 }
natural_abilities:
  - name: "Musical senses"
    description: "Extraordinary hearing range and clarity, perfect pitch when singing or playing an instrument, can hold its breath for 10 minutes, and an extraordinary sense of touch. A complex inner ear and three sets of vocal cords let it voice almost any note or sound and hum a harmony to its own singing or playing; seven digits on each hand (five fingers and two opposed thumbs) suit keyed and valved instruments."
  - name: "An S.D.C. being"
    description: "Hit Points are the P.E. attribute number plus 1D6 per level of experience. S.D.C. is 3D6+9 plus any from the O.C.C. and physical skills."
special_abilities:
  - name: "Racial skill bonuses"
    description: "Every Roane gets +5% to Language: Other, +5% Public Speaking, +10% Impersonate (Imitate) Voices & Sounds, +10% Palming, +10% Computer Operation, and +5% to skills needing a delicate or light touch such as Demolitions, Pick Pockets, Pick Locks and Cardsharp. Any further Play Musical Instrument skill gets at least +10%, even as a Secondary Skill. Applied only where the character has the skill; not added by the sheet."
  - { choose: 1, from: ["Psionics (01-06): One Power", "Psionics (07-10): Two Powers", "Psionics (11-00): None"], note: "Roll percentile at creation (Rifts World Book 30: D-Bees of North America p.172)." }
  - name: "Psionics (01-06): One Power"
    description: "One psionic ability from the Healing or Sensitive categories. A Minor Psychic with I.S.P. equal to the M.E. attribute number +1D4, plus 1D4 per level of experience."
    psionics:
      type: "minor"
      isp_base: "M.E. attribute number plus 1d4, +1d4 per level of experience"
      powers_starting: 1
      categories_allowed: ["Healing", "Sensitive"]
  - name: "Psionics (07-10): Two Powers"
    description: "Two psionic abilities from the Healing or Sensitive categories. A Minor Psychic with I.S.P. equal to the M.E. attribute number +1D4, plus 1D4 per level of experience."
    psionics:
      type: "minor"
      isp_base: "M.E. attribute number plus 1d4, +1d4 per level of experience"
      powers_starting: 2
      categories_allowed: ["Healing", "Sensitive"]
  - name: "Psionics (11-00): None"
    description: "No psychic aptitude."
  - name: "Rinaluo (Roane pipe)"
    description: "Every Roane starts with a rinaluo, its people''s crooked, multi-keyed, end-blown flute: a long bent cylinder with two long protrusions for working the keys. Races without the extra digits and thumbs are -20% to play it."
trackable_resources: []
restrictions:
  - "Alignment: any."
  - "Never willingly accepts cybernetics or bionics in the lungs, throat/neck, ears, jaw/mouth or hands; generally averse to augmentation, though a few become partial cyborgs."
  - "The racial Play Musical Instrument: Rinaluo and Sing skills are for a Roane NOT taking the Roane Musician O.C.C., which builds them in."
extraction_notes: "WB30 D-Bees of North America printed 170-172 (cache p171-p173), every number read off 200 dpi renders. Tag line: Roane Pipers - Optional Player Character or NPC; the class is named in the singular. The entry continues with a Roane Musician O.C.C. (printed 172-173: O.C.C. skills, eight related skills, six secondary, equipment and 5D6x1,000 credits plus 3D6x1,000 in goods); that is an occupation, not this race, and is NOT imported here. || CATEGORY: a race that takes an occupation; men_of_arms false. No xp_table: the book prints no ladder for the race and names none. Money and equipment: as per O.C.C. (stored: the racial rinaluo). Non-musicians earn 300 to 1,000 credits a week playing in clubs; prose. || POOLS: Hit Points P.E. plus 1D6 per level. S.D.C. printed bare as 3D6+9 on a race that takes an O.C.C., stored as a pool bonus. P.P.E. 1D4. Horror Factor not applicable. || SKILLS: printed for Roane not taking the Roane Musician O.C.C.: Play Musical Instrument: Rinaluo and Sing, +15% each. Catalog Play Musical Instrument 35+15=50 with the rinaluo in the note; Sing 35+15=50. The Roane Musician O.C.C. is in the catalog now (roane-musician); the race still grants both skills on every pairing. The across-the-board skill bonuses apply only to skills the character has, so they are ability text. || BONUSES: +2 initiative and +2 Perception stored. || PSIONICS: a percentile roll (6% one power, 4% two, else none), Healing or Sensitive, Minor Psychic, I.S.P. M.E. +1D4 plus 1D4 per level: a banded pick group, its two psychic rows each carrying a minor psionics block, and psionics_allowed: false because this table replaces the standard Random Psionics roll (BOOK-INGEST-AUDIT F138). || OCCUPATIONS: stored as occ_restrictions.except: group:magic, group:psychic, every Juicer O.C.C. in production on 2026-10-03, and every full-conversion cyborg O.C.C. there (combat-cyborg, the NGR, Free Quebec, CS, Republic and Geofront cyborgs, mining, destroyer, ojahee, plains and ninja borgs, cyborg-shocktrooper). dragon-borg O.C.C.s are human-only already and not listed. A Juicer or ''Borg O.C.C. added later is not excluded until this list is extended. M.O.M./Crazy conversion is allowed, so the Crazies are not excluded. || EQUIPMENT: the rinaluo is the catalog musical-instrument row; its description is a special ability. || NOT STORED: size 5 ft 6 in to 6 ft 6 in, weight 115-190 lbs, life span 2D6+75 years, NPC experience level 2D4, Also known as (Pipers, Piper Aliens, Pipe-Players), habitat, slave market value 4D6x10,000 credits, allies and enemies; they are in GM Notes."
---

## Lore

Wherever travellers go in the Megaverse, they seem to meet the Roane, a
slender salmon-skinned people with long faces who are famous as
musicians. The first of them to leave their world went as slaves of
interstellar traders who sold them as entertainers; as their fame spread
they were hired and invited instead, and though the Roane have no way to
cross dimensions themselves, they are now among the most widespread
beings anywhere.

Their hearing is extraordinary: small ears behind the jaw and resonating
cavities in the skull give them near-perfect pitch, and extra sets of
vocal cords let them hum a harmony to their own singing or playing. Each
hand has five fingers and two thumbs, ideal for keyed instruments. Their
traditional instrument is the rinaluo, a crooked, many-keyed flute
everyone else calls the Roane pipe.

Not every Roane is a musician by trade, but nearly all can play. Many
away from home turn to theft, spying or murder, and a wandering musician
makes a perfect cover: nobody suspects the piper who played three sets
at the restaurant when a safe is cracked or a local boss has an
accident. On Rifts Earth they turn up in the Coalition ''Burbs, Lazlo,
New Lazlo, the Pecos Empire, Ciudad Juarez and anywhere music or spies
are in demand.

## GM Notes

The book heads the race an optional player character or NPC.

The Roane Musician O.C.C. printed with the race (printed 172-173) is a
separate class.

Size 5 feet 6 inches to 6 feet 6 inches (1.7 to 2 m). Weight 115 to 190
pounds (52 to 86 kg). Life span 2D6+75 years; mature at 17. NPC
experience level 2D4. Also called Pipers, Piper Aliens and Pipe-Players.
Charismatic and friendly to outsiders, with an odd sensuality; among
their own kind they range from sullen to cruel.

Habitat: anywhere in the Megaverse, on Earth mostly the ''Burbs and major
cities of North America. Slave market value 4D6x10,000 credits; slavers
have raided their home world for centuries.

Allies: humans and most races, especially those with rich cultures and a
love of music. Enemies: the Splugorth, Sunaj, Naruni, Horune and anyone
who deals in slaves.
',
       updated_at = datetime('now')
 WHERE class_id = 'roane-piper'
   AND instr(markdown, 'Random, so not a psionics block: ability text.') > 0
   AND length(markdown) = 8446;

-- == witch ==
UPDATE imported_classes
   SET markdown = '---
id: witch
men_of_arms: false
occ_group: magic
xp_table: [0, 1871, 3741, 8481, 16901, 24901, 36801, 54701, 75601, 100501, 140401, 190301, 250201, 300101, 370201]
name: Witch
system: palladium-fantasy
source_book: palladium-fantasy-core p.112-116
category: occ
tags: [evil]
starting_money: "100"
variants:
  - id: gift-of-power
    name: "Witch (Gift of Power)"
  - id: gift-of-magic
    name: "Witch (Gift of Magic)"
    ppe_base: "1d6x10+10, plus 100 more available from the familiar while it is within 300 feet (91.5 m)"
    bonuses:
      saves: { spell_magic: 1, ritual_magic: 1, horror_factor: 1 }
  - id: gift-of-union
    name: "Witch (Gift of Union)"
    ppe_base: "100, combined with any the character already has and shared with the co-possessing essence"
    bonuses:
      attributes: { PS: 6, PE: 6 }
      combat: { initiative: 2, attacks: 1 }
      saves: { horror_factor: 4, illusionary_magic: 4 }
      pools: { isp: "3d4x10", sdc: "3d4x10" }
skills:
  hand_to_hand: { costs: { expert: 2, martial_arts: 3 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { choose: 2, from: ["Language: Other", "Language: Dragonese"], bonus: 10, note: "Speaks two additional languages (+10%)" }
    - { name: "Lore: Demons & Monsters", base: 45, per_level: 5, note: "Lore: Demon & Monster (+20%)" }
    - { name: "Lore: Faeries & Creatures of Magic", base: 35, per_level: 5, note: "Lore: Faerie Folk (+10%)" }
    - { choose: 2, categories: ["Weapon Proficiencies"], note: "Two weapons of choice" }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Can be changed to Expert for the cost of two other skills, or Martial Arts for the cost of three." }
  occ_related_skills:
    count: 10
    # PF printed 116: "Select 10 other skills, but two must be from wilderness
    # or domestic". ONE floor across the pair, satisfied by any two of them,
    # and the ten INCLUDES the two. RETRO-AUDIT R14.
    minimums:
      - { count: 2, categories: ["Wilderness", "Domestic"] }
    categories:
      - { name: "Domestic", bonus: 10, note: "+10%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Wilderness - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
      - { name: "Espionage", bonus: 5, note: "+5%" }
      - { name: "Horsemanship", only: ["Horsemanship: General", "Horsemanship: Exotic Animals"] }
      - { name: "Medical", bonus: 5, note: "+5%" }
      - { name: "Military", only: ["Interrogation Techniques"], note: "The book says Interrogation and Surveillance only. Surveillance is a Communications skill in the catalog and this class grants no Communications at all, so naming it here would offer nothing - see extraction_notes." }
      - { name: "Physical", except: ["Acrobatics", "Gymnastics", "Boxing", "Wrestling"] }
      - { name: "Rogue", bonus: 6, note: "+6%" }
      - "Science"
      - { name: "Technical", note: "+10% on lore and language skills only" }
      - { name: "Technical", only_prefix: ["Lore", "Language"], bonus: 10, note: "+10% on lore and language skills only." }
      - { name: "Weapon Proficiencies", except: ["W.P. Lance"], note: "Any except the Lance and the Long Bow; the catalog has no separate long bow proficiency, only W.P. Archery." }
      - { name: "Wilderness", bonus: 5, note: "+5%; two of the ten must come from Wilderness or Domestic. ONE union floor across the pair - not two of these and two more under Domestic - carried as occ_related_skills.minimums since RETRO-AUDIT R14 and refused on save when it cannot be reached." }
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 1 }, { level: 9, count: 1 }, { level: 12, count: 1 }]
  secondary_skills:
    count: 2
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 13, count: 2 }]
special_abilities:
  - name: "The Pact"
    description: "Everything the witch has comes from a signed pact with a demon lord, an occasional dark god, or an alien intelligence including the Old Ones and the Splugorth. The signing must be of the character''s own free will. Most such beings are surprisingly straightforward about the conditions, powers and price, and do not cheat - a mortal who tries to cheat THEM is likely to be possessed, or tortured and killed. A witch who forsakes the master loses every witch power and the familiar, and becomes the target of a vengeful demonic lord."
  - name: "Minor Pact: 40 Years of Loyal Servitude"
    description: "The most common minor pact. Complete loyalty and allegiance for forty years, obedience, no other master, no interference with fellow minions, and furthering the master''s goals wherever possible. If the master asks the witch to betray the party or kill a friend, the witch does it without question. A witch has one true friend, and it is the demonic master."
  - name: "Lesser Familiar"
    description: "Granted at second level once the witch has proven himself, identical to the wizard''s Familiar Link spell. A greater familiar may follow after years of loyal service, or as the result of a major pact."
  - name: "Gift of Power: select four"
    description: "The Gift of Power grants FOUR abilities chosen from eleven, and they never improve - skills rise with experience, the gifts do not. Four of the eleven are recorded as prose because what they grant has no field to hold it: an immunity, a constant sense, a flight speed that applies only while flying, and a healing rate. A demon familiar may be added later at fourth level or higher if the monster feels generous."
  - { choose: 4, from: ["Gift: I.S.P.", "Gift: P.P.E.", "Gift: Impervious", "Gift: Super Tough", "Gift: Resist Magic", "Gift: See the Invisible", "Gift: Mental Endurance", "Gift: Flight", "Gift: Supernatural Strength", "Gift: Physical Prowess", "Gift: Bio-Regeneration"] }
  - name: "Gift: I.S.P."
    description: "Add 1D6x10+40 I.S.P."
    bonuses:
      pools: { isp: "1d6x10+40" }
  - name: "Gift: P.P.E."
    description: "Add 2D4x10+20 P.P.E. The gift-of-power variant used to state this conditionally in ppe_base, where the condition could not be enforced; it arrives with the pick instead."
    bonuses:
      pools: { ppe: "2d4x10+20" }
  - name: "Gift: Impervious"
    description: "Impervious to poisons, toxins, drugs, gases and disease. An immunity rather than a bonus to save against them, so it is not written as one."
  - name: "Gift: Super Tough"
    description: "Adds 200 physical S.D.C. and heals twice as fast. The S.D.C. is modelled; the healing rate is prose, because no field holds a rate."
    bonuses:
      pools: { sdc: 200 }
  - name: "Gift: Resist Magic"
    description: "+2 to save vs all magic and possession. Written against the two magic saves the schema holds, spell and ritual, plus possession."
    bonuses:
      saves: { spell_magic: 2, ritual_magic: 2, possession: 2 }
  - name: "Gift: See the Invisible"
    description: "See the invisible and sense magic, both automatic and constant."
  - name: "Gift: Mental Endurance"
    description: "+3 vs horror factor, +1 vs psionic attack and all mind control, plus the psionic power of Sixth Sense. The three saves are modelled. The Sixth Sense grant is not: the book makes the witch no psychic and states no tier, so it is not stored as a psionics block (BOOK-INGEST-AUDIT F138)."
    bonuses:
      saves: { horror_factor: 3, psionics: 1, mind_control: 1 }
  - name: "Gift: Flight"
    description: "Flight at will and without limit at Spd 1D6x10+44. The Spd applies only while flying, and a conditional bonus is prose by rule."
  - name: "Gift: Supernatural Strength"
    description: "Supernatural strength and endurance: +10 P.S., rarely fatigues, double damage to mortals, and normal damage to demons and creatures of magic otherwise vulnerable only to magic. The +10 P.S. is modelled; the damage riders are prose."
    bonuses:
      attributes: { PS: 10 }
  - name: "Gift: Physical Prowess"
    description: "Increased physical prowess: +10 P.P. with the appropriate bonuses, and +2 initiative."
    bonuses:
      attributes: { PP: 10 }
      combat: { initiative: 2 }
  - name: "Gift: Bio-Regeneration"
    description: "Bio-regeneration restoring 1D4x10 S.D.C. and 4D6 hit points per hour. A rate, which no field holds."
  - name: "Gift of Magic: the spell allotment"
    description: "The Gift of Magic bestows magic outright: 1D6x10+10 P.P.E., a demon familiar, and another 100 P.P.E. the familiar gives freely while within 300 feet (91.5 m) and while the witch is doing what it and its master want. SPELLS: six from level one, four from level two, two from level three and one from level four, chosen once and never changed. One new spell at each level of experience, and the available range widens by one level each time - a second level witch may select from levels 1-5, a third level witch from 1-6, and so on. Bonuses: +1 to save vs magic, +1 to save vs horror factor, and +1 spell strength at levels three, seven and thirteen."
  - name: "Gift of Union: the creature shares the body"
    description: "The supposed ultimate reward. The creature shares the witch''s body while allowing the human essence to share control. The character''s alignment immediately becomes the master''s, and a voice in the head implants suggestions, urges violence and entices cruelty. The witch gains all the magic the master knows but at ONE THIRD the creature''s range of knowledge and spell strength, and it is the supernatural essence that controls its use - not the witch. The essence keeps its psionic powers at half strength. Plus 3D4x10 I.S.P., 3D4x10 S.D.C., 100 P.P.E. shared both ways, one extra hand to hand attack, +6 to P.S. and P.E., impervious to further possession and mind control, +4 to save vs horror factor, +4 vs illusionary magic and +2 on initiative. The creature can cancel any or all of it if the witch disappoints."
equipment_starting:
  - { item_id: "clothing", qty: 2 }
  - { item_id: "bedroll", qty: 1 }
  - { item_id: "back-pack-pf", qty: 1 }
  - { item_id: "small-sack-pf", qty: "1d4" }
  - { item_id: "large-sack-pf", qty: 2 }
  - { item_id: "water-skin", qty: 1 }
  - { item_id: "flint-steel", qty: 1 }
  - { item_id: "tinder-box", qty: 1 }
  - { item_id: "candle-long-burning-3-hours", qty: "1d4" }
  - { item_id: "candle-fast-burning-45-minutes", qty: "1d4" }
  - { item_id: "holy-symbol", qty: 1 }
  - { item_id: "wooden-spike", qty: "1d4" }
  - { item_id: "small-mallet", qty: 1 }
  - { item_id: "small-mirror", qty: 1 }
  - { item_id: "garlic-cloves", qty: "1d4" }
  - { item_id: "soft-leather", qty: 1 }
  - { item_id: "daggers-and-knives", qty: 2 }
  - { choose: 2, label: "weapon of choice", qty: 1, from: ["arab-mace", "awl-pike", "axe-battle", "axe-bipennis", "axe-stone", "axe-throwing", "ball-and-chain", "bastard-sword", "beaked-axe", "beaked-axe-short", "berdiche", "black-jack", "bo-staff", "broadsword", "bull-whip", "cat-o-nine-tails", "claymore", "club-stick-pipe", "cross-bow", "cudgel", "cutlass", "daggers-and-knives", "dart", "espandon", "falchion", "flail", "flamberge", "frying-pan", "glaive", "goupillon-flail", "guisarme", "halberd", "hammer-tool", "hand-pick", "hercules-club", "hippe", "horseman-hammer", "iron-staff", "javelin", "large-pick-mattock", "long-bow", "long-spear", "long-staff", "long-sword", "lucerne-hammer", "mace", "mace-and-chain", "maul", "meat-cleaver", "military-fork", "morning-star", "nunchaku", "oncin-pick", "pike", "quarterstaff", "runka", "sabre", "sabre-halberd", "scimitar", "scythe", "short-bow", "short-spear", "short-staff", "short-sword", "shovel", "sling", "trident", "voulge", "war-club", "war-hammer"] }
restrictions:
  - "EVIL ONLY - miscreant, aberrant or diabolic. The book instructs Game Masters to be unbending about it. A witch is not somebody bending a demon to good ends or even to selfish ones; a witch has joined a demonic monster as one of its faithful servants."
  - "No attribute requirements at all. The only requirement is to serve the dark master faithfully, to the letter of the pact, so anyone can become a witch regardless of physical or mental deficiency - and it is often the bitter or mocked individual who does."
  - "A witch must be allied to and serve a monstrous supernatural being. One who forsakes the master loses ALL witch powers and the familiar, and becomes the target of a vengeful demonic lord."
  - "Race: common among Orcs, Ogres, Trolls, Coyles and Humans. Elves, Dwarves, Bearmen, Wolfen, Kankorans, Titans and most giants almost never consider witchcraft - a dwarf who does is regarded as a traitor to the race. Faerie folk, dragons and other creatures of magic CANNOT become a witch."
  - "Armour is soft leather (A.R. 10, 20 S.D.C.), with the same restrictions as the wizard and warlock."
  - "The starting knives are a small SILVER dagger doing 1D4 and a normal knife doing 1D6; the catalog has one Daggers and Knives row and no silver-coated Palladium weapon, so it stands in for both. Favourite weapons are throwing knives, swords, axes, staves and cross bows."
  - "The kit also lists 1D4 black candles and 1D4 sticks of incense. The catalog prices neither; the ordinary long and fast burning candles cover the first and the incense is dropped."
  - "Witches living near a community are feared and respected, and often paid tribute in livestock, food, alcohol and treasure. Among Orcs, Ogres, Trolls and Goblins they are often shamans or leaders. Humans, elves and dwarves avoid them, and the military rarely hires them."
extraction_notes: "Surveillance is dropped from the Military only-list. The book allows Interrogation and Surveillance; the catalog files Surveillance under Communications, and this class is one of the few that grants NO Communications at all, so the name would have been admitted nowhere - a dead restriction of exactly the kind the regression audit pins a floor for. The three gifts are real variants and are modelled as variants for what VARIANT_OVERRIDES can carry - ppe_base and bonuses. It cannot carry `magic`, so the Gift of Magic''s spell allotment (six level one, four level two, two level three, one level four, then one per level with a widening range) is recorded as prose in special_abilities rather than as a magic block. Putting that block on the base class would hand the same thirteen spells to a Gift of Power witch, who gets none, and to a Gift of Union witch, whose magic belongs to the creature sharing the body and is explicitly not the character''s to select. The Gift of Power''s four-from-eleven is a real choose group: eleven ability definitions and a choose-four over them, with bonuses on the seven that grant something the schema holds. Four stay prose because what they grant has no field - an immunity, a constant sense, a flight speed that applies only while flying, and a healing rate. The Sixth Sense grant stays prose for a different reason: the book makes the witch no psychic and states no tier, so it is not stored as a psionics block (BOOK-INGEST-AUDIT F138). The long bow exclusion is dropped because the catalog has no separate long bow proficiency, only W.P. Archery, which the book does allow."
---

# Witch

## Lore

A witch is a man or woman who draws power from, and confers with, an evil
supernatural force. They are feared and powerful practitioners of magic,
renowned for dark secrets, illicit unions and associations with supernatural
monsters, and they are generally foul, vengeful beings with little regard for
anyone else.

Everything a witch has is borrowed. The pact grants one of three gifts - power,
magic, or union - and the creature that granted it can switch any of them off
the moment the witch stops being useful. It is the witch who is a slave to the
power and the creature who holds it.

Witchcraft is common among Orcs, Ogres, Trolls, Coyles and Humans. Elves,
Dwarves, Bearmen, Wolfen, Kankorans, Titans and most giants almost never
consider it; a dwarf who does is treated by his own people as a traitor and a
corrupt monster to be destroyed. Faerie folk, dragons and other creatures of
magic cannot become witches at all.

## Alignment

Evil only: miscreant, aberrant or diabolic. The book is explicit that Game
Masters should be unbending here.

## GM Notes

The book suggests this O.C.C. as a non-player villain, and the reason is
structural rather than squeamish: a witch has one true friend, the demonic
master, and if that master asks the witch to betray the party or kill a friend,
the witch does it without question. A player character witch is a party member
with a standing instruction to turn on them.

The design note at the head of this section is worth passing on: Palladium
states that its treatment of witchcraft is entirely fictional and inspired by
horror films rather than by history or myth, that historical pagan practice was
largely druid-like earth magic concerned with healing, harvest and prophecy,
and that nobody at Palladium Books encourages or condones the occult.
',
       updated_at = datetime('now')
 WHERE class_id = 'witch'
   AND instr(markdown, 'an ability-level psionics block replaces the character block rather than merging with it') > 0
   AND length(markdown) = 17206;

-- == lyn-srial ==
UPDATE imported_classes
   SET markdown = '---
id: lyn-srial
name: Lyn-Srial
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.127-129
category: rcc
tags: [flyer]
xp_table: [0, 1901, 3801, 7301, 14301, 21001, 30001, 40001, 53001, 73001, 103001, 138001, 188001, 238001, 288001]
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "3d6+8"
  Spd: "3d6+4"
mdc_base: "P.E. attribute x10, plus 1d6 per level of experience"
ppe_base: "1d6x10, +15 per level of experience"
magic:
  type: "spell"
  spells: ["Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Surfing", "Clouds of Survival: Aerial Navigation", "Clouds of Survival: Globe of Daylight"]
  spells_from: ["Clouds of Defense: Blinding Flash", "Clouds of Defense: Clouds of Light Deflection", "Clouds of Defense: Cloud of Darkness", "Clouds of Defense: Cloud Rider Armor", "Clouds of Defense: Cloud Shield", "Clouds of Defense: Fog of War", "Clouds of Defense: Storm Rider Armor", "Clouds of Travel: Blink of an Eye", "Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Portal", "Clouds of Travel: Cloud of Speed", "Clouds of Travel: Cloud Surfing", "Clouds of Travel: Fly Like The Wind", "Clouds of Travel: Portal to the Beyond", "Clouds of Survival: Aerial Navigation", "Clouds of Survival: Breath of Life", "Clouds of Survival: Calm Storms", "Clouds of Survival: Cloud of Healing", "Clouds of Survival: Globe of Daylight", "Clouds of Survival: Hunter''s Instinct", "Clouds of Survival: See the Invisible", "Clouds of Survival: See the Light", "Clouds of Survival: Tongues", "Clouds of Survival: Warmth of the Sun"]
bonuses:
  combat: { attacks: 3, initiative: 1, perception: 1, parry: 1, pull_punch: 2, roll: 3 }
  saves: { horror_factor: 4 }
skills:
  hand_to_hand: { costs: {} }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0, note: "Speaks the Lyn-Srial tongue at 98%." }
    - { name: "Literacy: Native Language", base: 98, per_level: 0, note: "Reads it at 98% too." }
    - { name: "History", base: 90, per_level: 0, note: "Printed as History of their People at a flat 90% - the Lyn-Srial''s own history rather than Earth''s. Stored on the generic History row rather than inventing a Lyn-Srial one." }
    - { choose: 3, from: ["Language: Other"], bonus: 30, note: "Language: Other: American and two of choice (+30%). One of the three picks is American." }
    - { choose: 2, from: ["Literacy: Other"], bonus: 10, note: "Literacy: Other: two of choice (+10%)." }
    - { name: "Lore: Magic", base: 40, per_level: 5, note: "+10%. Printed as Lore: Ley Lines & Magic." }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%, professional quality. Printed as Sing & Whistle." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%, professional quality." }
    - { name: "Art", base: 55, per_level: 5, note: "+20%, professional quality." }
    - { name: "Whittling & Sculpting", base: 45, per_level: 5, note: "+15%. Printed as Whittle/Sculpt." }
    - { name: "Hand to Hand: Basic", base: 0, per_level: 0, note: "Hand to Hand: Basic; cannot be changed." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", bonus: 10 }
      - { name: "Physical", except: ["Boxing"], note: "Any Physical skill except Boxing. Hand to Hand: Basic is an R.C.C. skill and cannot be changed." }
      - { name: "Pilot Related", only: ["Sensory Equipment", "Navigation"], note: "Printed as Read Sensory Equipment and Navigation only; the catalog row is Sensory Equipment." }
      - { name: "Rogue", only: ["Ventriloquism", "Computer Hacking"] }
      - { name: "Science", bonus: 15 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies", only: ["W.P. Handguns", "W.P. Energy Pistol", "W.P. Energy Rifle", "W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Whip"], note: "Any ANCIENT W.P.; of the MODERN ones, Handguns, Energy Pistol and Energy Rifle only. The catalog does not mark a W.P. ancient or modern, so the ancient ones are listed." }
      - { name: "Wilderness", bonus: 5 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Supernatural strength and endurance", description: "" }
  - { name: "Glow", description: "Glows with the light of the sun when happy or angry." }
  - { name: "Bio-regeneration", description: "1D6 M.D.C. per hour, and regrows a lost limb in four months - an eye or a tongue in a year." }
  - { name: "Hawk-like vision", description: "Can see a prairie dog up to three miles away." }
  - { name: "Nightvision", description: "1000 feet." }
  - { name: "Excellent hearing", description: "" }
  - { name: "Four arms", description: "A bat-like membrane between one pair of them allows flight, and gliding at half flying speed. Flying speed is 3D6+20 against the 3D6+4 on the ground." }
  - { name: "Awe Factor 9+1D4", description: "An Awe Factor rather than a Horror Factor, which is what the book prints. It is one the character IMPOSES. Kept here rather than in horror_factor, because the book prints Awe (BOOK-INGEST-AUDIT F138)." }
special_abilities:
  - { name: "Dodge in flight", description: "+2 to dodge when in flight." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "canteen", qty: 1 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "sculpting-tools-case", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "knife-small", qty: 1, note: "Whittling knife; a tool, the page lists Weapons: None." }
  - { item_id: "pocket-purse-small", qty: 1, note: "Purse; the page prints no size." }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
restrictions:
  - "Cowboy, Espionage, Military and Pilot are closed as related categories."
  - "Never uses a vehicle or a riding animal."
  - "No psionics at all."
  - "Avoids cybernetics; they bio-regenerate."
  - "Starts with no weapons."
  - "Also starts with personal jewelry (armbands, bracelets, necklaces, mantles and similar), a loincloth, a whittling knife and a purse; the canteen may be a water skin instead."
side_effects: "Vulnerabilities: an inhuman appearance, four arms and wings make it impossible for a Lyn-Srial to disguise itself. Their compassion and generosity sometimes get them into trouble."
extraction_notes: "This class followed Rifts World Book 14: New West printed 133-134 (experience table on its unnumbered page 224) until it was updated to the 2007 printing in Rifts World Book 30: D-Bees of North America printed 127-129 (ruling of 2026-10-04: the newest printing that states a figure wins). WHAT D-BEES REVISED. Bonus line: D-Bees printed 129 gives +3 attacks per melee round in addition to those of the Hand to Hand skill, and +1 on Perception Rolls; New West printed 133 gave three attacks per melee round plus those gained from optional Hand to Hand: Basic (stored then as attacks: 1) and printed no Perception bonus. Hand to Hand: D-Bees printed 128 lists Hand to Hand: Basic among the R.C.C. skills and says it cannot be changed, stored as the skill with an empty hand_to_hand cost list; New West printed 134 left it optional, a related Physical pick (only Hand to Hand: Basic can be selected from the combat skills). Languages: D-Bees prints Language: Other: American and two of choice (+30%); New West printed 134 gave speak three Earth languages (+30%). The catalog holds no American language row, so the group stays three picks of Language: Other and the note names American as one of them. W.P.: D-Bees adds Handguns to the modern proficiencies; New West printed 134 gave Any W.P. Ancient, and W.P. Energy Pistol and Rifle only. Experience: D-Bees printed 129 says to use the same Experience Table as the Operator, so xp_table is copied from the stored operator class (Rifts Ultimate Edition); New West printed 224 gave the Lyn-Srial Average Citizen its own column, shared with the Cowboy, which differs only at level 6: 21,301 where the Operator has 21,001. Secondary skills: both books give two at levels 1, 4, 8, 10 and 12; D-Bees draws them from the Secondary Skill List on page 300 of Rifts Ultimate Edition, where New West drew them from the related list above, excluding the categories marked None. Life span: D-Bees gives 1D6x10+135 years, physical maturity by 17, 1D4 live young after a 10 month pregnancy, and child-bearing until 70; New West printed 133 gave approximately 150-200 years, some living to 350, most elders 160 and up. Alignment: D-Bees splits New West''s 80% principled or scrupulous into Principled 50% and Scrupulous 30%, with Aberrant 10%. D-Bees marks P.S. and P.E. as Supernatural on the attribute line and prints Damage: as per Supernatural P.S. or by weapon or magic; the dice are unchanged. NEW IN D-BEES, no field: Vulnerabilities (stored as side_effects); experience level 1D6 for NPCs; Slave Market Value 3D4x10,000 credits, valued as warriors, guards and gladiators; allies are Cyber-Knights, Justice Rangers, Arzno and the Tolkeen refugees; they regard the Coalition States and the Federation of Magic with disappointment and apprehension; most numerous in Arizona, Utah and New Mexico. Available O.C.C.s: not applicable. BOTH BOOKS PRINT, added with this update: +2 to dodge when in flight (a conditional bonus, stored as a special ability), and the pocket mirror, sculpting tools and air filter of the equipment line. The whittling knife and purse of that line are granted since ~116 and ~117, as knife-small (a tool; the page lists Weapons: None) and pocket-purse-small (the page prints no size). The personal jewelry and loincloth of that line have no catalog row; all four are named in a restrictions line; the canteen or water skin is stored as the canteen. UNCHANGED BETWEEN THE PRINTINGS: attribute dice, M.D.C., Awe Factor, P.P.E., natural abilities, the four known spells and the one-per-3-I.Q. picks, the other R.C.C. skills and their bonuses, the related categories and their bonuses, the related-skill schedule, money, and the cybernetics line. FROM THE ORIGINAL IMPORT: THIS IS THE FIRST CLASS TO CONSUME THE CLOUD MAGIC SPELLS imported in PR #881, and the category prefix is what makes its magic expressible. The four granted spells are named outright. The additional picks are ONE PER 3 POINTS OF I.Q. from Clouds of Defense, Travel and Survival - an attribute-derived COUNT, which `spells_starting` cannot express because it takes a number. The three categories are given as `spells_from`, which per the frontmatter reference REPLACES the spell-level gate, so the pool is exactly right and only the count is prose. Divide the character''s I.Q. by three at creation. The Globe of Daylight granted is the Clouds of Survival one, because the character''s three categories are Defense, Travel and Survival and the Creation copy is out of scope for them. `attribute_dice.Spd` is the GROUND speed; flying is 3D6+20 and is in the four-arms natural ability, since one attribute cannot hold two values. AWE FACTOR, not Horror Factor - the book prints Awe, so it is a natural ability rather than horror_factor (BOOK-INGEST-AUDIT F138). ''History of their People at 90%'' is stored on the generic `History` row at a flat 90 rather than inventing a Lyn-Srial history row. This catalog does not mark a proficiency ancient or modern, so the ancient ones are enumerated and the three modern ones added. 55% of all Lyn-Srial females become Cloudweavers, which is a fact about the race rather than a mechanic."
---

# Lyn-Srial

**Alignments.** Any, but four in five are principled or scrupulous, one in ten
aberrant and one in ten something else. Very few ever turn selfish, and a
diabolic or miscreant Lyn-Srial is almost unheard of.

The Lyn-Srial - the Golden Ones - are a race of bird-like, golden-skinned
humanoids from a dimension of mountains, towering bluffs, cloud cities and
endless blue-green sky. They are a peaceful people who have given their lives to
helping others end violence and find peace as they have.

Not every Lyn-Srial is a Sky-Knight, a Cloudweaver or an adventurer, but nearly
all share the same ethics and goals. Many are artists of one kind or another and
all of them are creative and imaginative. Most have dedicated themselves to
helping others and to the pursuit of knowledge, art, beauty, and peace of mind
and spirit.

## Body

Seven to eight feet tall and two hundred to three hundred and twenty pounds,
with four arms - a bat-like membrane between one pair lets them fly, and glide
at half that speed. The average life span is 1D6x10+135 years, and
physical maturity comes by the age of seventeen.

They can be found anywhere in the Americas but are most numerous in the
Southwest, and keep a hidden city in the Grand Canyon. They are most at home
among canyons, buttes, mountains and clouds.

## Lore

Also known as the Golden Ones. Their magic is Cloud Magic, which is theirs
alone - the section on Arizona covers the people, their society and their hidden
city in more detail. The average Lyn-Srial is not trained to fight and shies
away from violence.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial'
   AND instr(markdown, 'the sheet has no field for either') > 0
   AND length(markdown) = 14024;

-- == lyn-srial-cloudweaver ==
UPDATE imported_classes
   SET markdown = '---
id: lyn-srial-cloudweaver
name: Lyn-Srial Cloudweaver
system: rifts
source_book: Rifts World Book 14: New West p.135-136
category: rcc
tags: [flyer]
xp_table: [0, 2151, 4301, 9601, 18201, 28401, 38601, 54801, 75201, 100401, 132601, 185801, 240201, 295401, 365601]
copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions", "xp_table"] }
attribute_requirements: { IQ: 18, MA: 18, ME: 18 }
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "3d6+8"
  Spd: "3d6+4"
mdc_base: "P.E. attribute x10, plus 1d6 per level of experience"
ppe_base: "1d6x10, +15 per level of experience"
magic:
  type: "spell"
  spell_traditions_allowed: ["cloud"]
  spells: ["Clouds of Defense: Blinding Flash", "Clouds of Defense: Clouds of Light Deflection", "Clouds of Defense: Cloud of Darkness", "Clouds of Defense: Cloud Rider Armor", "Clouds of Defense: Cloud Shield", "Clouds of Defense: Fog of War", "Clouds of Defense: Storm Rider Armor", "Clouds of Travel: Blink of an Eye", "Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Portal", "Clouds of Travel: Cloud of Speed", "Clouds of Travel: Cloud Surfing", "Clouds of Travel: Fly Like The Wind", "Clouds of Travel: Portal to the Beyond", "Clouds of Creation: Cloudweaving", "Clouds of Creation: Cloud Castles", "Clouds of Creation: Create Cloud Figures", "Clouds of Creation: Create Water", "Clouds of Creation: Flying Chariot", "Clouds of Creation: Food from the Heavens", "Clouds of Creation: Globe of Daylight", "Clouds of Creation: Paint the Sky"]
  spell_lists:
    any_but_war:
      - "Clouds of Defense: Blinding Flash"
      - "Clouds of Defense: Clouds of Light Deflection"
      - "Clouds of Defense: Cloud of Darkness"
      - "Clouds of Defense: Cloud Rider Armor"
      - "Clouds of Defense: Cloud Shield"
      - "Clouds of Defense: Fog of War"
      - "Clouds of Defense: Storm Rider Armor"
      - "Clouds of Peace: Cloud of Harmony"
      - "Clouds of Peace: Cloud Haven"
      - "Clouds of Peace: Fog of Peace"
      - "Clouds of Peace: Healing Rain"
      - "Clouds of Peace: Winds of Change"
      - "Clouds of Peace: Winds of Regret"
      - "Clouds of Travel: Blink of an Eye"
      - "Clouds of Travel: Cloud of Ascension"
      - "Clouds of Travel: Cloud Portal"
      - "Clouds of Travel: Cloud of Speed"
      - "Clouds of Travel: Cloud Surfing"
      - "Clouds of Travel: Fly Like The Wind"
      - "Clouds of Travel: Portal to the Beyond"
      - "Clouds of Survival: Aerial Navigation"
      - "Clouds of Survival: Breath of Life"
      - "Clouds of Survival: Calm Storms"
      - "Clouds of Survival: Cloud of Healing"
      - "Clouds of Survival: Globe of Daylight"
      - "Clouds of Survival: Hunter''s Instinct"
      - "Clouds of Survival: See the Invisible"
      - "Clouds of Survival: See the Light"
      - "Clouds of Survival: Tongues"
      - "Clouds of Survival: Warmth of the Sun"
      - "Clouds of the Mind: Cloud of Insanity"
      - "Clouds of the Mind: Clouds of Truth"
      - "Clouds of the Mind: Mind Fog"
      - "Clouds of the Mind: Mind Over Matter"
      - "Clouds of the Mind: Mist of Illusion"
      - "Clouds of the Mind: Spirit Mist"
      - "Clouds of the Mind: Warrior''s Mist"
      - "Clouds of Creation: Cloudweaving"
      - "Clouds of Creation: Cloud Castles"
      - "Clouds of Creation: Create Cloud Figures"
      - "Clouds of Creation: Create Water"
      - "Clouds of Creation: Flying Chariot"
      - "Clouds of Creation: Food from the Heavens"
      - "Clouds of Creation: Globe of Daylight"
      - "Clouds of Creation: Paint the Sky"
  spells_starting: 2
  spells_starting_groups:
    - { count: 2, from_list: "any_but_war", note: "Two more Cloud spells from any category except Clouds of War, from level one (printed 135)." }
  spells_schedule:
    - { level: 2, count: 2, from_list: "any_but_war" }
    - { level: 3, count: 2, from_list: "any_but_war" }
    - { level: 4, count: 2, from_list: "any_but_war" }
    - { level: 5, count: 2, from_list: "any_but_war" }
    - { level: 6, count: 2, from_list: "any_but_war" }
    - { level: 7, count: 2, from_list: "any_but_war" }
    - { level: 8, count: 2, from_list: "any_but_war" }
    - { level: 9, count: 2, from_list: "any_but_war" }
    - { level: 10, count: 2, from_list: "any_but_war" }
    - { level: 11, count: 2, from_list: "any_but_war" }
    - { level: 12, count: 2, from_list: "any_but_war" }
    - { level: 13, count: 2, from_list: "any_but_war" }
    - { level: 14, count: 2, from_list: "any_but_war" }
    - { level: 15, count: 2, from_list: "any_but_war" }
bonuses:
  combat: { attacks: 1, initiative: 2, parry: 1, dodge: 2, pull_punch: 3, roll: 2 }
  pools: { ppe: "2d4x10" }
skills:
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { name: "Literacy: Native Language", base: 98, per_level: 0 }
    - { name: "History", base: 98, per_level: 0, note: "Printed as History of their People at a flat 98%." }
    - { choose: 3, from: ["Language: Other"], bonus: 48, note: "Speak three Earth languages at 98%. The catalog holds Language: Other at 50%, so 98% is stated as +48." }
    - { choose: 3, from: ["Literacy: Other"], bonus: 20, note: "Literate in the same three Earth languages (+20%)." }
    - { name: "Lore: Magic", base: 45, per_level: 5, note: "+15%. Printed as Lore: Ley Lines & Magic." }
    - { choose: 2, from: ["Lore: American Indians", "Lore: Astral", "Lore: Cattle & Animals", "Lore: D-Bee", "Lore: Demons & Monsters", "Lore: Dimensions", "Lore: Faeries & Creatures of Magic", "Lore: Galactic/Alien", "Lore: Juicers", "Lore: Nightbane", "Lore: Nightlands", "Lore: Psychics & Psionics", "Lore: Religion", "Lore: Vampires", "Lore: Wormwood"], bonus: 15, note: "Lore: two of choice (+15%). Lore: Magic is granted outright above and is not one of the two." }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Holistic Medicine", base: 40, per_level: 5, note: "+20%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Sing", base: 50, per_level: 5, note: "+15%, professional quality. Printed as Sing & Whistle." }
    - { name: "Dance", base: 45, per_level: 5, note: "+15%, professional quality." }
    - { name: "Art", base: 55, per_level: 5, note: "+20%, professional quality." }
    - { name: "Calligraphy", base: 55, per_level: 5, note: "+20%, professional quality. The book prints this as Write; the catalog''s nearest row is Calligraphy and no Writing row exists." }
  occ_related_skills:
    count: 6
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 5 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", bonus: 5 }
      - { name: "Mechanical", bonus: 5 }
      - { name: "Medical", bonus: 15 }
      - { name: "Physical", except: ["Boxing", "Wrestling"], note: "Any Physical skill except boxing and wrestling, and only Hand to Hand: Basic from the combat skills." }
      - { name: "Pilot Related", only: ["Sensory Equipment", "Navigation"], note: "Printed as Read Sensory Equipment and Navigation only; the catalog row is Sensory Equipment." }
      - { name: "Science", bonus: 20 }
      - { name: "Technical", bonus: 15 }
      - { name: "Weapon Proficiencies", only: ["W.P. Archery", "W.P. Axe", "W.P. Blunt", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Whip"], note: "Any W.P. ANCIENT only. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
      - { name: "Wilderness", bonus: 5 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Supernatural strength and endurance", description: "" }
  - { name: "Glow", description: "Glows with the light of the sun when happy or angry." }
  - { name: "Bio-regeneration", description: "1D6 M.D.C. per hour, and regrows a lost limb in four months - an eye or a tongue in a year." }
  - { name: "Hawk-like vision", description: "Can see a prairie dog up to three miles away." }
  - { name: "Nightvision", description: "1000 feet." }
  - { name: "Excellent hearing", description: "" }
  - { name: "Four arms", description: "A bat-like membrane between one pair of them allows flight, and gliding at half flying speed. Flying speed is 3D6+20 against the 3D6+4 on the ground." }
  - { name: "Awe Factor 9+1D4", description: "An Awe Factor rather than a Horror Factor, which is what the book prints. It is one the character IMPOSES. Kept here rather than in horror_factor, because the book prints Awe (BOOK-INGEST-AUDIT F138)." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 1 }
starting_money: "2d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits unless adventuring"
restrictions:
  - "Impervious to Horror Factor and to possession - not a bonus but an immunity, and there is no field for either, so it is recorded here."
  - "Cowboy, Espionage, Military, Pilot and Rogue are closed as related categories."
  - "Never uses a vehicle or a riding animal, and starts with no weapons."
  - "No psionics at all."
  - "Avoids cybernetics; they bio-regenerate."
special_abilities:
  - { name: "Dodge in flight", description: "+2 to dodge when in flight." }
side_effects: "Vulnerabilities: an inhuman appearance, four arms and wings make it impossible for a Lyn-Srial to disguise itself. Their compassion and generosity sometimes get them into trouble."
extraction_notes: "`copy_of` records that printed 135 defines this class as the Average Lyn-Srial for alignment, attributes and all basic stats, then replaces magic, skills, bonuses and equipment. The copied halves are repeated in full because nothing composes one class from another. THE MAGIC IS THE POINT: all seven Clouds of Defense, all seven Clouds of Travel and all eight Clouds of Creation outright - 22 spells - plus TWO more per level from any category EXCEPT Clouds of War, which is 45 of the 58 rows, declared once as `spell_lists.any_but_war`. That exclusion is only expressible because the spells carry their category in the name. The level-one pair is a starting group and levels 2-15 are `spells_schedule` entries of two, all drawing from that list; until BOOK-INGEST-AUDIT.md F59 the list was `spells_from` with no starting count, so it bounded nothing and every level-up could reach Clouds of War. IMPERVIOUS TO HORROR FACTOR AND POSSESSION is an immunity rather than a bonus; `bonuses.saves` holds numbers and there is no field for an immunity, so it is in `restrictions` where a reader will meet it. The +2D4x10 P.P.E. IS in `bonuses.pools`, which takes dice. The book prints a skill called Write at professional quality; there is no Writing row in this catalog and Calligraphy is the nearest, so that is what is stored, with the book''s own word in the note. Standard Equipment stores only the catalog rows that exist; the book also lists personal jewelry, a loin cloth, a pocket mirror and a purse, and states outright that the Cloudweaver starts with no weapons."
---

# Lyn-Srial Cloudweaver

**Alignments.** As the Average Lyn-Srial: four in five principled or scrupulous,
one in ten aberrant.

Cloudweavers are the Lyn-Srial - women in about eleven cases in twenty, and men
- who have become adept at casting and understanding Cloud Magic. They are
highly prized in the Golden Ones'' society and are treated as nobility or high
priests.

Most spend decades developing the skill and learning the theory and history of
magic and of Cloudweaving itself. The average Cloudweaver is not a warrior and
stays close to the city of Tryth-Sal, serving as historian, philosopher, healer,
diplomat and wise counsel - half the Council of Elders are Cloudweavers.
Occasionally one is sent into the wilderness to accompany a party of Sky-Knights
or to advise and help others in need.

## Lore

Also known as the Wise One and the Golden Creator. Fifty-five percent of all
Lyn-Srial women become Cloudweavers.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-cloudweaver'
   AND instr(markdown, 'the sheet has no field for either') > 0
   AND length(markdown) = 12644;

-- == lyn-srial-sky-knight ==
UPDATE imported_classes
   SET markdown = '---
id: lyn-srial-sky-knight
name: Lyn-Srial Sky-Knight
system: rifts
source_book: Rifts World Book 30: D-Bees of North America p.129-130
category: rcc
tags: [combat, flyer]
xp_table: [0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96101, 131201, 181301, 231401, 281501, 341601]
copy_of: { class: "lyn-srial", except: ["attribute_requirements", "bonuses", "magic", "skills", "equipment_starting", "starting_money", "restrictions", "xp_table"] }
attribute_requirements: { IQ: 18, ME: 18 }
attribute_dice:
  IQ: "3d6+4"
  ME: "3d6+10"
  MA: "3d6+10"
  PS: "3d6+6"
  PP: "3d6"
  PE: "3d6+4"
  PB: "3d6+8"
  Spd: "3d6+4"
mdc_base: "P.E. attribute x10, plus 1d6 per level of experience"
ppe_base: "1d6x10, +15 per level of experience"
magic:
  type: "spell"
  spell_traditions_allowed: ["cloud"]
  spells: ["Clouds of Travel: Cloud of Ascension", "Clouds of Travel: Cloud Surfing", "Clouds of Survival: Aerial Navigation", "Clouds of Survival: Globe of Daylight", "Clouds of Defense: Storm Rider Armor", "Clouds of War: Cloud Blast", "Clouds of War: Cloud Disc", "Clouds of War: Clouds of Imprisonment", "Clouds of War: Cloud Lance", "Clouds of War: Cloud Sword", "Clouds of War: Cloud Whip", "Clouds of War: Fiery Cloud", "Clouds of War: Poisonous Cloud", "Clouds of War: Rolling Thunder", "Clouds of War: Storm Cloud", "Clouds of War: Storm Cloud Sword", "Clouds of War: Wind Hammer", "Clouds of War: Wind Spear", "Clouds of Peace: Cloud of Harmony", "Clouds of Peace: Cloud Haven", "Clouds of Peace: Fog of Peace", "Clouds of Peace: Healing Rain", "Clouds of Peace: Winds of Change", "Clouds of Peace: Winds of Regret"]
  spell_lists:
    any_but_creation:
      - "Clouds of War: Cloud Blast"
      - "Clouds of War: Cloud Disc"
      - "Clouds of War: Clouds of Imprisonment"
      - "Clouds of War: Cloud Lance"
      - "Clouds of War: Cloud Sword"
      - "Clouds of War: Cloud Whip"
      - "Clouds of War: Fiery Cloud"
      - "Clouds of War: Poisonous Cloud"
      - "Clouds of War: Rolling Thunder"
      - "Clouds of War: Storm Cloud"
      - "Clouds of War: Storm Cloud Sword"
      - "Clouds of War: Wind Hammer"
      - "Clouds of War: Wind Spear"
      - "Clouds of Defense: Blinding Flash"
      - "Clouds of Defense: Clouds of Light Deflection"
      - "Clouds of Defense: Cloud of Darkness"
      - "Clouds of Defense: Cloud Rider Armor"
      - "Clouds of Defense: Cloud Shield"
      - "Clouds of Defense: Fog of War"
      - "Clouds of Defense: Storm Rider Armor"
      - "Clouds of Peace: Cloud of Harmony"
      - "Clouds of Peace: Cloud Haven"
      - "Clouds of Peace: Fog of Peace"
      - "Clouds of Peace: Healing Rain"
      - "Clouds of Peace: Winds of Change"
      - "Clouds of Peace: Winds of Regret"
      - "Clouds of Travel: Blink of an Eye"
      - "Clouds of Travel: Cloud of Ascension"
      - "Clouds of Travel: Cloud Portal"
      - "Clouds of Travel: Cloud of Speed"
      - "Clouds of Travel: Cloud Surfing"
      - "Clouds of Travel: Fly Like The Wind"
      - "Clouds of Travel: Portal to the Beyond"
      - "Clouds of Survival: Aerial Navigation"
      - "Clouds of Survival: Breath of Life"
      - "Clouds of Survival: Calm Storms"
      - "Clouds of Survival: Cloud of Healing"
      - "Clouds of Survival: Globe of Daylight"
      - "Clouds of Survival: Hunter''s Instinct"
      - "Clouds of Survival: See the Invisible"
      - "Clouds of Survival: See the Light"
      - "Clouds of Survival: Tongues"
      - "Clouds of Survival: Warmth of the Sun"
      - "Clouds of the Mind: Cloud of Insanity"
      - "Clouds of the Mind: Clouds of Truth"
      - "Clouds of the Mind: Mind Fog"
      - "Clouds of the Mind: Mind Over Matter"
      - "Clouds of the Mind: Mist of Illusion"
      - "Clouds of the Mind: Spirit Mist"
      - "Clouds of the Mind: Warrior''s Mist"
  spells_starting: 1
  spells_starting_groups:
    - { count: 1, from_list: "any_but_creation", note: "One more spell from any category except Clouds of Creation, from level one (D-Bees printed 129)." }
  spells_schedule:
    - { level: 2, count: 1, from_list: "any_but_creation" }
    - { level: 3, count: 1, from_list: "any_but_creation" }
    - { level: 4, count: 1, from_list: "any_but_creation" }
    - { level: 5, count: 1, from_list: "any_but_creation" }
    - { level: 6, count: 1, from_list: "any_but_creation" }
    - { level: 7, count: 1, from_list: "any_but_creation" }
    - { level: 8, count: 1, from_list: "any_but_creation" }
    - { level: 9, count: 1, from_list: "any_but_creation" }
    - { level: 10, count: 1, from_list: "any_but_creation" }
    - { level: 11, count: 1, from_list: "any_but_creation" }
    - { level: 12, count: 1, from_list: "any_but_creation" }
    - { level: 13, count: 1, from_list: "any_but_creation" }
    - { level: 14, count: 1, from_list: "any_but_creation" }
    - { level: 15, count: 1, from_list: "any_but_creation" }
bonuses:
  attributes: { PS: "1d6" }
  combat: { attacks: 4, initiative: 3, perception: 4, parry: 1, roll: 4, pull_punch: 4, disarm: 3 }
  saves: { horror_factor: 1 }
  pools: { mdc: "2d6+6", ppe: "1d4x10" }
  at_level:
    - { level: 3, saves: { horror_factor: 1 } }
    - { level: 4, saves: { horror_factor: 1 } }
    - { level: 5, saves: { horror_factor: 1 } }
    - { level: 7, saves: { horror_factor: 1 } }
    - { level: 8, saves: { horror_factor: 1 } }
    - { level: 9, saves: { horror_factor: 1 } }
    - { level: 11, saves: { horror_factor: 1 } }
    - { level: 12, saves: { horror_factor: 1 } }
    - { level: 13, saves: { horror_factor: 1 } }
    - { level: 15, saves: { horror_factor: 1 } }
skills:
  hand_to_hand: { costs: { martial_arts: 1 } }
  occ_skills:
    - { name: "Language: Native Tongue", base: 98, per_level: 0 }
    - { name: "Literacy: Native Language", base: 98, per_level: 0 }
    - { name: "History", base: 90, per_level: 0, note: "Printed as History of their People at a flat 90%." }
    - { choose: 3, from: ["Language: Other"], bonus: 30, note: "Language: Other: American and two of choice (+30%)." }
    - { choose: 2, from: ["Literacy: Other"], bonus: 10, note: "Literacy: Other: two of choice (+10%)." }
    - { name: "Lore: Magic", base: 35, per_level: 5, note: "+10%. Printed as Lore: Ley Lines & Magic." }
    - { name: "Law", base: 55, per_level: 5, note: "+20%" }
    - { name: "Mathematics: Basic", base: 75, per_level: 5, note: "+30%" }
    - { name: "Holistic Medicine", base: 30, per_level: 5, note: "+10%" }
    - { name: "Identify Plants & Fruit", base: 45, per_level: 5, note: "+20%. Printed as Identify Fruit and Plants." }
    - { name: "Wilderness Survival", base: 45, per_level: 5, note: "+15%" }
    - { name: "Land Navigation", base: 46, per_level: 4, note: "+10%" }
    - { name: "Sing", base: 55, per_level: 5, note: "+20%, professional quality. Printed as Sing & Whistle." }
    - { name: "Dance", base: 50, per_level: 5, note: "+20%, professional quality." }
    - { name: "Art", base: 55, per_level: 5, note: "+20%, professional quality." }
    - { name: "Whittling & Sculpting", base: 45, per_level: 5, note: "+15%. Printed as Whittle/Sculpt." }
    - { name: "W.P. Blunt", base: 0, per_level: 0 }
    - { name: "W.P. Paired Weapons", base: 0, per_level: 0 }
    - { choose: 1, from: ["W.P. Archery", "W.P. Axe", "W.P. Chain", "W.P. Forked", "W.P. Knife", "W.P. Lance", "W.P. Pole Arm", "W.P. Shield", "W.P. Spear", "W.P. Staff", "W.P. Sword", "W.P. Targeting", "W.P. Whip"], note: "W.P. one ANCIENT weapon of choice. The catalog does not mark a proficiency ancient or modern, so the ancient ones are listed." }
    - { choose: 1, from: ["W.P. Energy Pistol", "W.P. Energy Rifle"], note: "W.P. one energy weapon of choice." }
    - { name: "Hand to Hand: Expert", base: 0, per_level: 0, note: "May be traded up to Martial Arts for one R.C.C. Related skill." }
  occ_related_skills:
    count: 5
    schedule: [{ level: 3, count: 2 }, { level: 6, count: 2 }, { level: 9, count: 2 }, { level: 12, count: 2 }]
    categories:
      - { name: "Communications", bonus: 10 }
      - { name: "Domestic", bonus: 10 }
      - { name: "Electrical", only: ["Basic Electronics"], bonus: 5 }
      - { name: "Espionage", only: ["Intelligence", "Tracking (people)"], bonus: 10 }
      - { name: "Mechanical", only: ["Basic Mechanics"], bonus: 5 }
      - { name: "Medical", bonus: 10 }
      - { name: "Military", except: ["Trap Construction", "Trap/Mine Detection", "Parachuting", "NBC Warfare"], bonus: 5 }
      - "Physical"
      - { name: "Pilot Related", only: ["Sensory Equipment", "Navigation"], bonus: 10, note: "Printed as Read Sensory Equipment & Navigation only; the catalog row is Sensory Equipment." }
      - { name: "Rogue", only: ["Ventriloquism", "Streetwise", "Computer Hacking"] }
      - { name: "Science", bonus: 10 }
      - { name: "Technical", bonus: 15 }
      - "Weapon Proficiencies"
      - { name: "Wilderness", bonus: 10 }
  secondary_skills:
    count: 2
    schedule: [{ level: 4, count: 2 }, { level: 8, count: 2 }, { level: 10, count: 2 }, { level: 12, count: 2 }]
natural_abilities:
  - { name: "Supernatural strength and endurance", description: "" }
  - { name: "Glow", description: "Glows with the light of the sun when happy or angry." }
  - { name: "Bio-regeneration", description: "1D6 M.D.C. per hour, and regrows a lost limb in four months - an eye or a tongue in a year." }
  - { name: "Hawk-like vision", description: "Can see a prairie dog up to three miles away." }
  - { name: "Nightvision", description: "1000 feet." }
  - { name: "Excellent hearing", description: "" }
  - { name: "Four arms", description: "A bat-like membrane between one pair of them allows flight, and gliding at half flying speed. Flying speed is 3D6+20 against the 3D6+4 on the ground." }
  - { name: "Awe Factor 9+1D4", description: "An Awe Factor rather than a Horror Factor, which is what the book prints. It is one the character IMPOSES. Kept here rather than in horror_factor, because the book prints Awe (BOOK-INGEST-AUDIT F138)." }
equipment_starting:
  - { item_id: "utility-belt", qty: 1 }
  - { item_id: "backpack", qty: 1 }
  - { item_id: "air-filter", qty: 1 }
  - { item_id: "canteen", qty: 2 }
  - { item_id: "pocket-mirror", qty: 1 }
  - { item_id: "wooden-cross", qty: 1 }
  - { item_id: "wooden-stake", qty: 12 }
starting_money: "3d6x100 credits worth of tradeable goods; a Lyn-Srial has no need of universal credits"
restrictions:
  - "Cowboy and Pilot are closed as related categories, and Military excludes the trap skills, Parachuting and NBC Warfare."
  - "Rarely uses a vehicle or a riding animal."
  - "No psionics at all."
  - "Avoids cybernetics; they bio-regenerate."
  - "The +2 to dodge applies only when in flight, and the book prints a +3 to disarm on a called shot beside the plain +3 to disarm. Neither of those two conditional figures (the dodge in flight and the called-shot disarm) is in the bonus totals; the plain +3 to disarm is."
special_abilities:
  - { name: "Dodge in flight", description: "+2 to dodge when in flight." }
side_effects: "Vulnerabilities: an inhuman appearance, four arms and wings make it impossible for a Lyn-Srial to disguise itself. Their compassion and generosity sometimes get them into trouble."
extraction_notes: "This class followed Rifts World Book 14: New West printed 134-135 (experience table on its printed 224) until it was brought up to the 2007 reprint, D-Bees of North America printed 129-130, under the ruling of 2026-10-04 that the newest printing which states a figure wins. WHAT D-BEES REVISED, with the New West figure kept here. ATTACKS: New West printed 135 gave four attacks per melee round, plus those gained from hand to hand combat, stored as attacks 2; D-Bees prints Attacks per Melee as per Hand to Hand Combat skill and bonuses and puts +4 attacks per melee round in the bonus line, stored as attacks 4. M.D.C. BONUS: New West +2D6, D-Bees +2D6+6. PERCEPTION: New West printed none, D-Bees +4 to Perception Rolls. DISARM: New West printed only +3 to disarm on a called shot; D-Bees prints +3 to disarm and then +3 to disarm on a called shot, so the plain +3 is the stored bonus and the called-shot line is a restriction line. DODGE: both books print +2 to dodge when in flight; it is conditional, so it is a restriction line and not a bonus (the row stored it as an unconditional dodge 2 until this update). R.C.C. SKILLS: New West printed 135 gave the Sky-Knight its own list - three Earth languages (+30%), Lore: one of choice (+10%), Land Navigation (+20%), Sing & Whistle (+15%), Art (+15%), and neither Holistic Medicine nor Identify Fruit and Plants. D-Bees printed 129 says same as the average Lyn-Srial citizen plus the two fixed W.P.s, the two W.P.s of choice and Hand to Hand: Expert, so the list is now the average citizen list of D-Bees printed 128: Language: Other: American and two of choice (+30%), Lore: Ley Lines & Magic (+10%) on the Lore: Magic row, Land Navigation (+10%), Sing & Whistle (+20%), Art (+20%), Holistic Medicine (+10%), Identify Fruit and Plants (+20%). The catalog holds no American language row, so the three languages stay three picks of Language: Other with the printed wording in the note. The average citizen line Hand to Hand: Basic, cannot be changed, is replaced by the Sky-Knight line Hand to Hand: Expert. RELATED SKILLS: New West printed Physical: Any, except boxing; D-Bees prints Physical: Any. Every other category line is the same in both books. SECONDARY SKILLS: D-Bees says same as above, which is the average citizen line - two from the Secondary Skill List on page 300 of Rifts Ultimate Edition at levels 1, 4, 8, 10 and 12; New West drew them from the related list above, excluding the categories marked None. The counts are the same. EXPERIENCE: New West printed 224 gives a Lyn-Srial Sky-Knight ladder of its own - 0, 2141, 4281, 8561, 17521, 25521, 35521, 50521, 71001, 96001, 131201, 181301 (misprinted 18,301), 231401, 281501, 341601. D-Bees printed 130 says to use the same experience table as the Cyber-Knight, so `xp_table` is copied from the stored `cyber-knight` row (Rifts Ultimate Edition); the two ladders differ only at level 10, 96101 against 96001. D-Bees also prints an N.P.C. experience level of 2D4. WHAT D-BEES DOES NOT RESTATE, kept from New West: Money (3D6x100 in tradeable goods, New West printed 135; the average citizen in D-Bees printed 129 has 2D6x100), rarely uses a vehicle or riding animal (the average citizen in D-Bees never does), and the cybernetics line. Attributes, M.D.C., P.P.E., Awe Factor and natural abilities are the average citizen figures in both books and are the same in both. MAGIC: both books open the list with Cloud of Ascension, Cloud Surfing, Aerial Navigation, Globe of Daylight and Storm Rider Armor before all Clouds of War and Clouds of Peace; those five were missing from `spells` until this update. EQUIPMENT is the same list in both books; the pocket mirror, the large wooden cross and the twelve wooden stakes were added in this update from catalog rows. `copy_of` records that New West printed 134 and D-Bees printed 129 define this class as the Average Lyn-Srial for alignment, attributes and all basic stats, and then replaces magic, skills, bonuses and equipment. The copied halves are repeated in full because nothing composes one class from another; the `except` list names what differs. THE MAGIC IS THE POINT OF THIS CLASS: the five named spells, all thirteen Clouds of War and all six Clouds of Peace outright, plus one more spell per level from any category EXCEPT Clouds of Creation - which is 50 of the 58 rows, declared once as `spell_lists.any_but_creation`. That exclusion is only expressible because the spells carry their category in the name; under a tradition prefix it could not be written at all. The level-one pick is a starting group and levels 2-15 are `spells_schedule` entries, both drawing from that list; until BOOK-INGEST-AUDIT.md F59 the list was `spells_from` with no starting count, so it bounded nothing and every level-up could reach Clouds of Creation. THE +1D6 TO P.S. IS IN `bonuses.attributes`, where a dice string is rolled once at creation and stored on the character - the same path a Juicer''s +2D6 P.S. takes. It was first stored as `special_abilities` prose on the strength of BOOK-INGEST-AUDIT.md F52, which claimed a dice bonus there was silently dropped; F52 was FALSIFIED and closed on 2026-09-10 and this class was corrected in the same PR. The +2D6+6 M.D.C. and +1D4x10 P.P.E. ARE in `bonuses.pools`, which does take dice (js/dice.js:221, js/parser.js:1454). Standard Equipment stores only the catalog rows that exist; the book also lists personal jewelry, the Sky-Knight''s golden chest plate at 25 M.D.C. (more symbolic than functional), a chain mail loin cloth, a whittling knife, and one weapon per W.P. plus a matched pair of one type."
---

# Lyn-Srial Sky-Knight

**Alignments.** As the Average Lyn-Srial: four in five principled or scrupulous,
one in ten aberrant.

The Sky-Knight is the Lyn-Srial warrior for peace. These noble fighters battle
only to protect others, to destroy evil and the supernatural, and to bring
justice and wisdom to the world in the pursuit of peace.

In many ways they are philosopher knights, trying to instil values in everyone
they meet and to be living examples of what friendship, brotherhood and love can
achieve. They are often taken for avenging angels or warriors of light who fight
for the innocent and the underdog. They stand against evil in all its forms, and
while they show respect and understanding to all peoples, religions and nations,
they will stand against any of them known to be evil or to crush people''s
spirits.

All Sky-Knights are accomplished magic users, and will use magic to avoid or
defuse a fight before using force to finish one. They are courageous in battle
and tender in life.

## Lore

Also known as the Philosopher Knight, the Golden One and the Hope Bringer. They
are the personification of the ideal the word *knight* stands for.
',
       updated_at = datetime('now')
 WHERE class_id = 'lyn-srial-sky-knight'
   AND instr(markdown, 'the sheet has no field for either') > 0
   AND length(markdown) = 17960;

-- Read the result back. A guard that matched nothing must fail here, not pass.
SELECT 'all 13 classes carry their new text' AS assertion, count(*) AS got, 13 AS want
  FROM imported_classes
 WHERE (class_id = 'dragon-juicer' AND instr(markdown, 'combat: { initiative: "1d4", roll: 2, attacks: 2 }') > 0)
    OR (class_id = 'outback-mutie' AND instr(markdown, 'attribute_dice: { Spd: "1d6+6" }') > 0)
    OR (class_id = 'phreaker-military-grunt' AND instr(markdown, 'attribute_dice: { Spd: "1d6+6" }') > 0)
    OR (class_id = 'mutant-psi-stalker' AND instr(markdown, 'combat: { attacks: 1, perception: 4 }') > 0)
    OR (class_id = 'pseudo-men' AND instr(markdown, 'attacks: 1, automatic_dodge: 3 }') > 0)
    OR (class_id = 'russian-fire-sorcerer' AND instr(markdown, 'other: [ { label: "vs magic fumes", bonus: 4 } ]') > 0)
    OR (class_id = 'russian-mystic-kuznya' AND instr(markdown, 'MA: "1d4", PS: "1d6+12" }') > 0)
    OR (class_id = 'gifted-one-russian' AND instr(markdown, 'each Master gift sets related_skills_count: 0') > 0)
    OR (class_id = 'roane-piper' AND instr(markdown, 'Psionics (07-10): Two Powers') > 0)
    OR (class_id = 'witch' AND instr(markdown, 'the book makes the witch no psychic and states no tier') > 0)
    OR (class_id = 'lyn-srial' AND instr(markdown, 'Kept here rather than in horror_factor') > 0)
    OR (class_id = 'lyn-srial-cloudweaver' AND instr(markdown, 'Kept here rather than in horror_factor') > 0)
    OR (class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'Kept here rather than in horror_factor') > 0);
SELECT 'none still carries the sentence it replaced' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE (class_id = 'dragon-juicer' AND instr(markdown, 'the bonuses block stores integers for combat') > 0)
    OR (class_id = 'outback-mutie' AND instr(markdown, 'NOT APPLIED AUTOMATICALLY: Spd becomes 1D6+6') > 0)
    OR (class_id = 'phreaker-military-grunt' AND instr(markdown, 'NOT APPLIED AUTOMATICALLY: Spd becomes 1D6+6') > 0)
    OR (class_id = 'mutant-psi-stalker' AND instr(markdown, '+4 Perception (+5 for the Wild Psi-Stalker)') > 0)
    OR (class_id = 'pseudo-men' AND instr(markdown, 'Automatic Dodge at +3 (dodging uses up no melee attack or action), which is not applied.') > 0)
    OR (class_id = 'russian-fire-sorcerer' AND instr(markdown, 'The +4 to save vs magic fumes has no field') > 0)
    OR (class_id = 'russian-mystic-kuznya' AND instr(markdown, 'and the P.S. is still only on its ability') > 0)
    OR (class_id = 'gifted-one-russian' AND instr(markdown, 'ONE THING THE ABILITY ROUTE CANNOT CARRY') > 0)
    OR (class_id = 'roane-piper' AND instr(markdown, 'Random, so not a psionics block: ability text.') > 0)
    OR (class_id = 'witch' AND instr(markdown, 'an ability-level psionics block replaces the character block rather than merging with it') > 0)
    OR (class_id = 'lyn-srial' AND instr(markdown, 'the sheet has no field for either') > 0)
    OR (class_id = 'lyn-srial-cloudweaver' AND instr(markdown, 'the sheet has no field for either') > 0)
    OR (class_id = 'lyn-srial-sky-knight' AND instr(markdown, 'the sheet has no field for either') > 0);
SELECT 'no CR in any of them' AS assertion, count(*) AS got, 0 AS want
  FROM imported_classes
 WHERE class_id IN ('dragon-juicer', 'outback-mutie', 'phreaker-military-grunt', 'mutant-psi-stalker', 'pseudo-men', 'russian-fire-sorcerer', 'russian-mystic-kuznya', 'gifted-one-russian', 'roane-piper', 'witch', 'lyn-srial', 'lyn-srial-cloudweaver', 'lyn-srial-sky-knight') AND instr(markdown, char(13)) > 0;

-- Records this run. See db/migrations/024-data-script-runs.sql.
INSERT INTO data_script_runs (filename) VALUES ('~193-book-ingest-audit-f138-other-keys.sql');
